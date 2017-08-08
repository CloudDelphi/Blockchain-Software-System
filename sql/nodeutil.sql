/* ************************************************************************ */
/* PeopleRelay: nodeutil.sql Version: see version.sql                       */
/*                                                                          */
/* Copyright 2017 Aleksei Ilin & Igor Ilin                                  */
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
/* ************************************************************************ */

/*-----------------------------------------------------------------------------------------------*/
set term ^ ;
/*-----------------------------------------------------------------------------------------------*/
create procedure P_IncRate(RecId TRef)
as
  declare ATest TRef;
  declare RateInc Float;
  declare MaxRate TRating;
begin
  select RateInc,MaxRate from P_TParams into :RateInc,:MaxRate;
  
  select RecId from P_TNode
    where RecId = :RecId and Rating < :MaxRate
    for update WITH LOCK into :ATest;

  if (ATest is not null) then
    update P_TNode
      set
        Rating = Rating + :RateInc
      where RecId = :RecId
        and Rating < :MaxRate;

  when any do
    execute procedure P_LogErr(-51,sqlcode,gdscode,sqlstate,'P_IncRate',null,'Error',null);

end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_DecRate(RecId TRef)
as
  declare ATest TRef;
  declare RateDec Float;
  declare MinRate TRating;
begin

  select RateDec,MinRate from P_TParams into :RateDec,:MinRate;

  select RecId from P_TNode
    where RecId = :RecId and Rating > :MinRate
    for update WITH LOCK into :ATest;

  if (ATest is not null) then
    update P_TNode
      set
        Rating = Rating - :RateDec
      where RecId = :RecId
        and Rating > :MinRate;

  when any do
    execute procedure P_LogErr(-52,sqlcode,gdscode,sqlstate,'P_DecRate',null,'Error',null);

end^
/*-----------------------------------------------------------------------------------------------*/
/*
Cause
1 - bad metadata
2 - bad block hash or sig
*/
create procedure P_ExpelNode(RecId TRef, Fine TFine, Cause SmallInt)
as
  declare ATest TRef;
begin
  if (Fine in (2,3)) then
  begin
    select RecId from P_TNode
      where RecId = :RecId
      for update WITH LOCK into :ATest;
    update P_TNode
      set
        Enabled = 0,
        ExpelCause = :Cause
      where RecId = :RecId;
  end
  if (Fine in (1,3)) then execute procedure P_DecRate(RecId);
  execute procedure P_LogErr(-21,RecId,Cause,'','P_ExpelNode',null,null,null);

  when any do
    execute procedure P_LogErr(-53,sqlcode,gdscode,sqlstate,'P_ExpelNode',null,'Error',null);

end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_BadMeta(RecId TRef)
as
  declare Fine TFine;
begin
  select FineBadMeta from P_TParams into :Fine;
  execute procedure P_ExpelNode(RecId,Fine,1);
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_BadHash(RecId TRef)
as
  declare Fine TFine;
begin
  select FineBadHash from P_TParams into :Fine;
  execute procedure P_ExpelNode(RecId,Fine,2);
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_CorrNode(
  RecId TRef,
  Alias TNdAlias,
  Status TNdStatus,
  Acceptor TBoolean,
  IpMaskLen TUInt,
  EditTime TTimeMark,
  LoadSig TSig,
  PubKey TKey)
as
  declare ATest TRef;
begin
  select RecId from P_TNode
    where RecId = :RecId
      for update WITH LOCK into :ATest;

  update P_TNode
    set
      Alias = :Alias,
      Status = :Status,
      Acceptor = :Acceptor,
      IpMaskLen = :IpMaskLen,
      EditTime = :EditTime,
      LoadSig = :LoadSig,
      PubKey = :PubKey
    where RecId = :RecId;

  when any do
    execute procedure P_LogErr(-54,sqlcode,gdscode,sqlstate,'P_CorrNode',null,'Error',null);
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_UpdTMOffset(RecId TRef, NdTime TTimeMark)
as
  declare ATest TRef;
begin
  select RecId from P_TNode
    where RecId = :RecId for update WITH LOCK into :ATest;

  update P_TNode set TMOffset = CURRENT_TIMESTAMP - :NdTime where RecId = :RecId;

  when any do
    execute procedure P_LogErr(-55,sqlcode,gdscode,sqlstate,'P_UpdTMOffset',null,'Error',null);
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_UpdReplTime(RecId TRef, NdTime TTimeMark)
as
  declare ATest TRef;
begin
  select RecId from P_TNode
    where RecId = :RecId for update WITH LOCK into :ATest;

  update P_TNode set ReplTime = :NdTime where RecId = :RecId;

  when any do
    execute procedure P_LogErr(-56,sqlcode,gdscode,sqlstate,'P_UpdReplTime',null,'Error',null);
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_UpdMPId(RecId TRef, MPId TRef)
as
  declare ATest TRef;
begin
  select RecId from P_TNode
    where RecId = :RecId for update WITH LOCK into :ATest;

  update P_TNode set MPId = :MPId where RecId = :RecId;

  when any do
    execute procedure P_LogErr(-57,sqlcode,gdscode,sqlstate,'P_UpdMPId',null,'Error',null);
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_UpdNodeRec(RecId TRef, MaxNdId TRef, NdId TRef, Proxy TBoolean)
as
  declare ATest TRef;
begin
  if (MaxNdId > 0) then
  begin
    select RecId from P_TNode
      where RecId = :RecId for update WITH LOCK into :ATest;

    if (MaxNdId > NdId) then
      update P_TNode set NdId = :MaxNdId where RecId = :RecId;

    update P_TNode set Proxy = :Proxy where RecId = :RecId and Proxy <> :Proxy;

    when any do
      execute procedure P_LogErr(-50,sqlcode,gdscode,sqlstate,'P_UpdNodeRec',null,'Error',null);
  end
end^
/*-----------------------------------------------------------------------------------------------*/
set term ; ^
/*-----------------------------------------------------------------------------------------------*/
grant all on P_TNode to procedure P_IncRate;
grant select on P_TParams to procedure P_IncRate;
grant execute on procedure P_LogErr to procedure P_IncRate;

grant all on P_TNode to procedure P_DecRate;
grant select on P_TParams to procedure P_DecRate;
grant execute on procedure P_LogErr to procedure P_DecRate;

grant all on P_TNode to procedure P_ExpelNode;
grant execute on procedure P_LogErr to procedure P_ExpelNode;
grant execute on procedure P_DecRate to procedure P_ExpelNode;

grant select on P_TParams to procedure P_BadMeta;
grant execute on procedure P_ExpelNode to procedure P_BadMeta;

grant select on P_TParams to procedure P_BadHash;
grant execute on procedure P_ExpelNode to procedure P_BadHash;

grant all on P_TNode to procedure P_CorrNode;
grant execute on procedure P_LogErr to procedure P_CorrNode;

grant all on P_TNode to procedure P_UpdTMOffset;
grant execute on procedure P_LogErr to procedure P_UpdTMOffset;

grant all on P_TNode to procedure P_UpdReplTime;
grant execute on procedure P_LogErr to procedure P_UpdReplTime;

grant all on P_TNode to procedure P_UpdMPId;
grant execute on procedure P_LogErr to procedure P_UpdMPId;

grant all on P_TNode to procedure P_UpdNodeRec;
grant execute on procedure P_LogErr to procedure P_UpdNodeRec;

/*-----------------------------------------------------------------------------------------------*/
