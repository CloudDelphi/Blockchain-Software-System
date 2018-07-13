/* ======================================================================== */
/* PeopleRelay: nodeutil.sql Version: 0.4.3.6                               */
/*                                                                          */
/* Copyright 2017-2018 Aleksei Ilin & Igor Ilin                             */
/*                                                                          */
/* Licensed under the Apache License, Version 2.0 (the "License");          */
/* you may not use this file except in compliance with the License.         */
/* You may obtain a copy of the License at                                  */
/*                                                                          */
/*     http://www.apache.org/licenses/LICENSE-2.0                           */
/*                                                                          */
/* Unless required by applicable law or agreed to in writing, software      */
/* distributed under the License is distributed on an "AS IS" BASIS,        */
/* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. */
/* See the License for the specific language governing permissions and      */
/* limitations under the License.                                           */
/* ======================================================================== */

/*-----------------------------------------------------------------------------------------------*/
set term ^ ;
/*-----------------------------------------------------------------------------------------------*/
/*
Cause
1 - bad db metadata
2 - bad block hash
3 - bad block signature
*/
create procedure P_ExpelNode(RecId TRef, Expel TBoolean, Cause SmallInt, NodeId TNodeId, Source TSysStr32)
as
  declare ATest TRef;
  declare Msg TSysStr32;
begin
  if ((select Enabled from P_TPeer where RecId = :RecId) = 1) then
  begin
    if (Cause = 1)
    then
      Msg = 'db metadata';
    else
      if (Cause = 2)
      then
        Msg = 'block hash';
      else
        if (Cause = 3)
        then
          Msg = 'Local sig';
        else
          Msg = 'block sig';

    Msg = 'bad ' || Msg;

    execute procedure P_LogErr(-21,RecId,Cause,'P_ExpelNode',Source,NodeId,Msg,null);
    if (Expel = 1) then
    begin
      select RecId from P_TPeer
        where RecId = :RecId
        for update of Enabled,ExpelCause WITH LOCK into :ATest; /* error here if record locked */
      update P_TPeer
        set
          Enabled = 0,
          ExpelCause = :Cause
        where RecId = :RecId;
    end

    when any do
      execute procedure P_LogErr(-53,sqlcode,gdscode,sqlstate,'P_ExpelNode',NodeId,'Error',null);
  end
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_BadMeta(RecId TRef, NodeId TNodeId, Source TSysStr32)
as
begin
  execute procedure P_ExpelNode(RecId,(select ExpelBadMeta from P_TParams),1,NodeId,Source);
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_BadHash(RecId TRef, NodeId TNodeId, Source TSysStr32)
as
begin
  execute procedure P_ExpelNode(RecId,(select ExpelBadHash from P_TParams),2,NodeId,Source);
end^
/*-----------------------------------------------------------------------------------------------*/
/*
Bad LocalSig
*/
create procedure P_BadTmS(RecId TRef, NodeId TNodeId, Source TSysStr32)
as
begin
  execute procedure P_ExpelNode(RecId,(select ExpelBadTmS from P_TParams),3,NodeId,Source);
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_BadSign(RecId TRef, NodeId TNodeId, Source TSysStr32)
as
begin
  execute procedure P_ExpelNode(RecId,(select ExpelBadSign from P_TParams),4,NodeId,Source);
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_UpdMPId(RecId TRef, MPId TRef)
as
begin
  insert into P_TMPidLog(ParId,MPId) values(:RecId,:MPId);

  when any do
    execute procedure P_LogErr(-56,sqlcode,gdscode,sqlstate,'P_UpdMPId',null,'Error',null);
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_UpdNDid(
  RecId TRef,
  MaxSid TRef)
as
begin
  insert into P_TNDidLog(ParId,Sid) values(:RecId,:MaxSid);
  when any do
    execute procedure P_LogErr(-50,sqlcode,gdscode,sqlstate,'P_UpdNDid','P_TNDidLog',null,null);
end^
/*-----------------------------------------------------------------------------------------------*/
set term ; ^
/*-----------------------------------------------------------------------------------------------*/
grant all on P_TPeer to procedure P_ExpelNode;
grant execute on procedure P_LogErr to procedure P_ExpelNode;

grant select on P_TParams to procedure P_BadMeta;
grant execute on procedure P_ExpelNode to procedure P_BadMeta;

grant select on P_TParams to procedure P_BadHash;
grant execute on procedure P_ExpelNode to procedure P_BadHash;

grant select on P_TParams to procedure P_BadTmS;
grant execute on procedure P_ExpelNode to procedure P_BadTmS;

grant select on P_TParams to procedure P_BadSign;
grant execute on procedure P_ExpelNode to procedure P_BadSign;

grant all on P_TMPidLog to procedure P_UpdMPId;
grant execute on procedure P_LogErr to procedure P_UpdMPId;

grant all on P_TNDidLog to procedure P_UpdNDid;
grant execute on procedure P_LogErr to procedure P_UpdNDid;

/*-----------------------------------------------------------------------------------------------*/
