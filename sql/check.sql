/* ************************************************************************ */
/* PeopleRelay: check.sql Version: see version.sql                          */
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
create procedure P_GetHash(RecId TRid)
as
begin
  exit;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_IsBlock(
  RecId TRid,
  Checksum TIntHash,
  SelfHash TChHash)
returns
  (Result TBoolean)
as
begin
  Result = 0;
  if (exists (select 1 from P_TChain
    where RecId = :RecId
      and Checksum = :Checksum
      and SelfHash = :SelfHash))
  then
    Result = 1;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_DoCheckBlock(
  RecId TRid,
  Checksum TIntHash,
  SelfHash TChHash,

  DB TFullPath,
  Usr TUserName,
  PWD TPWD,
  NodeId TNodeId)
returns
  (Result TTrilean)
as
  declare stm TSysStr512;
begin
  stm = 'execute procedure P_IsBlock(?,?,?)';
  execute statement
    (stm) (:RecId,:Checksum,:SelfHash)
    on external DB as user Usr password PWD
  into :Result;

  when any do
  begin
    Result = -1;
    execute procedure P_LogErr(-1,sqlcode,gdscode,sqlstate,'DoCheckBlock',NodeId,'Error','');
  end
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_CheckBlock(RecId TRid)
returns
  (Result TBoolean,
   TotOk TInt32,
   TotFail TInt32)
as
  declare VoteLim TCount;
  declare CheckId TRef;
  declare rslt TTrilean;
  declare TM0 TTimeMark;
  declare TMSlice TInt32;
  declare DoLog TBoolean;
  declare Acceptor TBoolean;
  declare MtCheck TBoolean;
  declare Checksum TIntHash;
  declare SelfHash TChHash;
  declare NodeId TNodeId;
  declare PeerIP TIPV6str;
  declare PeerPort TPort;
  declare PWD TPWD;
  declare Usr TUserName;
  declare DB TFullPath;
begin
  TotOk = 0;
  TotFail = 0;
  TM0 = CURRENT_TIMESTAMP;
  select Acceptor,TimeSlice,LogBlockChk from P_TParams into :Acceptor,:TMSlice,:DoLog;
  select Checksum,SelfHash from P_TChain where RecId = :RecId into :Checksum,:SelfHash;

  if (DoLog = 1) then
    insert into P_TChecks(ChainId) values(:RecId) returning RecId into :CheckId;

  execute procedure P_FillNodeCahe(4,Acceptor) returning_values VoteLim;

  for select
      NodeId,
      Ip,
      APort,
      ExtAcc,
      ExtPWD,
      FullPath
    from
      P_NodeCahe
    into
      :NodeId,
      :PeerIp,
      :PeerPort,
      :Usr,
      :PWD,
      :DB
  do
    if ((select Result from P_IsOnline(:PeerIP,:PeerPort)) = 1) then
    begin
      execute procedure P_DoCheckBlock(RecId,Checksum,SelfHash,DB,Usr,PWD,NodeId) returning_values rslt;
      if (rslt <= 0)
      then
        TotFail = TotFail + 1;
      else
        if (rslt = 1) then
        begin
          TotOk = TotOk + 1;
          if (DoLog = 1) then
            insert into P_TChkLog(CheckId,NodeId) values(:CheckId,:NodeId);
        end
      if (TotOk >= VoteLim) then
      begin
        Result = 1;
        Leave;
      end
      if(TMSlice > 0
        and datediff(minute,TM0,cast('Now' as TimeStamp)) > TMSlice)
      then
        begin
          execute procedure P_LogErr(-8,TotOk,TotFail,null,'P_CheckBlock',NodeId,'Long duration',null);
          Leave;
        end
      when any do
        execute procedure P_LogErr(-8,sqlcode,gdscode,sqlstate,'P_CheckBlock',NodeId,'Error','');
    end
  suspend;  
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_Compare
returns
  (Result TBoolean,
   Size TRef,
   Delta TCount,
   TotOk TInt32,
   TotFail TInt32)
as
  declare RecId TRid;
  declare TM0 TTimeMark;
  declare TMSlice TInt32;
begin
  Delta = 0;
  TM0 = CURRENT_TIMESTAMP;
  select TimeSlice from P_TParams into :TMSlice;
  for select
      RecId
    from
      P_TChain
    order by
      RecId desc
    into
      :RecId
  do
    begin
      if (Size is null) then Size = RecId;
      execute procedure P_CheckBlock(RecId) returning_values Result,TotOk,TotFail;
      if (Result = 1) then
      begin
        Delta = RecId - Size;
        Leave;
      end
      if(TMSlice > 0
        and datediff(minute,TM0,cast('Now' as TimeStamp)) > TMSlice)
      then
        begin
          execute procedure P_LogErr(-400,RecId,Size,null,'P_Compare','Long duration',null,null);
          Leave;
        end
    end
  suspend;  
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_FindBlock(SenderId TSenderId,BlockId TBlockId,Quorum TCount = 1)
returns
  (Result TBoolean)
as
  declare q TCount;
  declare r TTrilean;
  declare Acceptor TBoolean;
  declare PeerIP TIPV6str;
  declare PeerPort TPort;
  declare PWD TPWD;
  declare Usr TUserName;
  declare DB TFullPath;
  declare stm TSysStr64;
begin
  stm = 'execute procedure P_HasBlock(?,?)';

  select Acceptor from P_TParams into :Acceptor;
  execute procedure P_FillNodeCahe(3,Acceptor) returning_values q; /* 3 is chosen arbitrary; we do not need a result at all. */
  q = 0;

  execute procedure P_HasBlock(SenderId,BlockId) returning_values r;
  if (r = 1) then q = q + 1;

  if (q < Quorum)
  then
    for select
        Ip,
        APort,
        ExtAcc,
        ExtPWD,
        FullPath
      from
        P_NodeCahe
      into
        :PeerIp,
        :PeerPort,
        :Usr,
        :PWD,
        :DB
    do
      if ((select Result from P_IsOnline(:PeerIP,:PeerPort)) = 1) then
      begin
        execute statement
          (stm) (:SenderId,:BlockId)
          on external DB as user Usr password PWD
          into :r;
        if (r = 1) then q = q + 1;
        if (q >= Quorum) then
        begin
          Result = 1;
          Leave;
        end
      end
  else
    Result = 1;
  suspend;
end^
/*-----------------------------------------------------------------------------------------------*/
set term ; ^
/*-----------------------------------------------------------------------------------------------*/
grant select on P_TChain to procedure P_IsBlock;
grant execute on procedure P_LogErr to procedure P_DoCheckBlock;

grant all on P_TChecks to procedure P_CheckBlock;
grant all on P_TChkLog to procedure P_CheckBlock;
grant select on P_TChain to procedure P_CheckBlock;
grant select on P_TParams to procedure P_CheckBlock;
grant execute on procedure P_LogErr to procedure P_CheckBlock;
grant execute on procedure P_IsOnline to procedure P_CheckBlock;
grant execute on procedure P_FillNodeCahe to procedure P_CheckBlock;
grant execute on procedure P_DoCheckBlock to procedure P_CheckBlock;

grant select on P_TChain to  procedure P_Compare;
grant select on P_TParams to  procedure P_Compare;
grant execute on procedure P_CheckBlock to procedure P_Compare;

grant select on P_TChain to procedure P_Compare;
grant select on P_TParams to procedure P_Compare;
grant execute on procedure P_LOGERR to procedure P_Compare;

grant select on P_TParams to procedure P_FindBlock;
grant execute on procedure P_IsOnline to procedure P_FindBlock;
grant execute on procedure P_HasBlock to procedure P_FindBlock;
grant execute on procedure P_FillNodeCahe to procedure P_FindBlock;

/*-----------------------------------------------------------------------------------------------*/

