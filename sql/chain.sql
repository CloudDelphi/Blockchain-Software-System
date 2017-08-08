/* ************************************************************************ */
/* PeopleRelay: chain.sql Version: see version.sql                          */
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
create generator P_G$MP;
/*-----------------------------------------------------------------------------------------------*/
create table P_TChain(
  RecId             TRid,
  Checksum          TIntHash not null,
  SelfHash          TChHash not null,
  ParRecId          TRid,
  ParChsum          TIntHash not null,
  PrntHash          TChHash not null,
  BlockId           TBlockId not null,
  TimeMark          TTimeMark not null,
  Address           TAddress not null,
  SenderId          TSenderId not null,
  CreatedBy         TOperName,
  CreatedAt         TTimeMark not null,
  LoadSig           TSig not null,
  PubKey            TKey not null,
  primary key       (RecId,Checksum,SelfHash),
  foreign key       (ParRecId,ParChsum,PrntHash) references P_TChain(RecId,Checksum,SelfHash));
/*-----------------------------------------------------------------------------------------------*/
create unique index P_XU$Ch1 on P_TChain(RecId);
create unique descending index P_XU$Ch2 on P_TChain(RecId);
create unique index P_XU$Ch3 on P_TChain(SenderId,BlockId);
/*-----------------------------------------------------------------------------------------------*/
  insert into P_TChain(
    RecId,
    Checksum,
    SelfHash,
    ParRecId,
    ParChsum,
    PrntHash,
    BlockId,
    TimeMark,
    Address,
    SenderId,
    CreatedBy,
    CreatedAt,
    LoadSig,
    PubKey)
  values(
    0,   --RecId
    0,   --Checksum
    '0', --SelfHash
    0,   --ParRecId
    0,   --ParChsum
    '0', --PrntHash
    '0', --BlockId
    CURRENT_TIMESTAMP, --TimeMark
    'ROOT', --Address
    'ROOT', --SenderId
    'ROOT', --CreatedBy
    CURRENT_TIMESTAMP, --CreatedAt
    '0', --LoadSig
    '0'); --PubKey
commit work;
/*-----------------------------------------------------------------------------------------------*/
set term ^ ;
/*-----------------------------------------------------------------------------------------------*/
create trigger P_TBI$TChain for P_TChain active before insert position 0
as
  declare IsApp TBoolean;
  declare IsRepl TBoolean;
  declare Checksum TIntHash;
begin
  execute procedure P_IsRepl returning_values IsRepl;
  execute procedure P_Commiting returning_values IsApp;
  if (IsApp = 0 and IsRepl = 0)
  then
    exception P_E$Forbidden;
  else
    begin
      select first 1 Checksum from P_TChain order by RecId desc into :Checksum;
      if (IsApp = 1) then
      begin
        new.RecId = new.ParRecId + 1;
        new.Checksum = Hash(Checksum || '-' || new.SelfHash);
      end
      new.CreatedBy = CURRENT_USER;
      new.CreatedAt = CURRENT_TIMESTAMP;
    end
end^
/*-----------------------------------------------------------------------------------------------*/
create trigger P_TBU$TChain for P_TChain active before update position 0
as
begin
  if ((select Result from P_Trimming) = 0) then exception P_E$Forbidden;
end^
/*-----------------------------------------------------------------------------------------------*/
create trigger P_TBD$TChain for P_TChain active before delete position 0
as
begin
  if ((select Result from P_IsDehorn) = 1)
  then
    begin
      if ((select Acceptor from P_Params) = 1) then 
        execute procedure P_RevertBlock(old.RecId,old.SenderId,old.BlockId);
    end
  else
    if ((select Result from P_Trimming) = 0) then exception P_E$Forbidden;
end^
/*-----------------------------------------------------------------------------------------------*/
set term ; ^
/*-----------------------------------------------------------------------------------------------*/
create table P_TMeltingPot(
  RecId             TRid,
  SelfHash          TChHash not null,
  BlockId           TBlockId not null,
  TimeMark          TTimeMark,
  Address           TAddress not null,
  SenderId          TSenderId not null,
  LoadSig           TSig not null,
  PubKey            TKey not null,
  State             TState,
  RT                TCount,
  Own               TBoolean,
  Loop              TUInt,  
  LocalTM           TTimeMark not null,
  primary key       (RecId));
/*-----------------------------------------------------------------------------------------------*/
create unique index P_XU$MP1 on P_TMeltingPot(SenderId,BlockId);
create index P_X$MP1 on P_TMeltingPot(SelfHash);
create index P_X$MP2 on P_TMeltingPot(State);
create index P_X$MP3 on P_TMeltingPot(Loop);
create index P_X$MP4 on P_TMeltingPot(Own);
create index P_X$MP5 on P_TMeltingPot(RT);
/*-----------------------------------------------------------------------------------------------*/
set term ^ ;
/*-----------------------------------------------------------------------------------------------*/
create trigger P_TBI$TMeltingPot for P_TMeltingPot active before insert position 0
as
  declare IsAddB TBoolean;
  declare IsRepl TBoolean;
  declare AuxHash TChHash;
  declare PvtKey TKey;
  declare AData TMemo;
begin
  execute procedure P_IsRepl returning_values IsRepl;
  execute procedure P_IsAddB returning_values IsAddB;
  if (IsAddB = 0 and IsRepl = 0)
  then
    exception P_E$Forbidden;
  else
    begin
      new.RecId = gen_id(P_G$MP,1);
      new.RT = Gen_Id(P_G$RTT,0);
      if (IsAddB = 1) then
      begin
        new.Own = 1;
        new.LocalTM = 'Now';
        new.TimeMark = new.LocalTM;
        if (new.BlockId is null) then /* Sender can assign it. */
          new.BlockId = uuid_to_Char(gen_uuid());
      end
    end
end^
/*-----------------------------------------------------------------------------------------------*/
set term ; ^
/*-----------------------------------------------------------------------------------------------*/
create table P_TBacklog(
  RecId             TRid,
  Checksum          TIntHash not null,
  SelfHash          TChHash not null,
  ParRecId          TRid,
  ParChsum          TIntHash not null,
  PrntHash          TChHash not null,
  BlockId           TBlockId not null,
  TimeMark          TTimeMark,
  Address           TAddress not null,
  SenderId          TSenderId not null,
  LoadSig           TSig not null,
  PubKey            TKey not null,
  State             TState,
  RT                TCount,    

  primary key       (RecId));
/*-----------------------------------------------------------------------------------------------*/
create index P_X$BL1 on P_TBacklog(State);
create index P_X$BL2 on P_TBacklog(RT);
/*-----------------------------------------------------------------------------------------------*/
set term ^ ;
/*-----------------------------------------------------------------------------------------------*/
create trigger P_TBI$TBacklog for P_TBacklog active before insert position 0
as
  declare ATest TBoolean;
begin
  execute procedure P_IsRepl returning_values ATest;
  if (ATest = 0) then exception P_E$Forbidden;
  new.RT = Gen_Id(P_G$RTT,0);
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_HasBlock(SenderId TSenderId,BlockId TBlockId)
returns
  (Result TTrilean)
as
begin
  if (exists (select 1 from P_TChain
    where SenderId = :SenderId
      and BlockId = :BlockId))
  then
    Result = 1;
  else
    if (exists (select 1 from P_TMeltingPot
      where SenderId = :SenderId
        and BlockId = :BlockId))
    then
      Result = 0;
  suspend;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_ClearBackLog
as
begin
  delete from P_TBacklog where State > 0;
  when any do
    execute procedure P_LogErr(-33,sqlcode,gdscode,sqlstate,'P_ClearBackLog',null,'Error',null);
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_ClearMeltingPot
as
  declare MPLinger TUInt1;
begin
  select MPDelLinger from P_TParams into :MPLinger;
  delete from P_TMeltingPot where State > 0 and Loop > :MPLinger;
  when any do
    execute procedure P_LogErr(-34,sqlcode,gdscode,sqlstate,'P_ClearMeltingPot',null,'Error',null);
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_UpdateMeltingPot
as
begin
  update P_TMeltingPot MP
    set MP.State = 1
    where MP.State = 0
      and exists (select 1 from P_TChain C
        where C.SenderId = MP.SenderId and C.BlockId = MP.BlockId);

  when any do
    execute procedure P_LogErr(-35,sqlcode,gdscode,sqlstate,'P_UpdateMeltingPot',null,'Error',null);
end^
/*-----------------------------------------------------------------------------------------------*/
set term ; ^
/*-----------------------------------------------------------------------------------------------*/
create view P_Chain as select * from P_TChain;
create view P_MeltingPot as select * from P_TMeltingPot;
/*-----------------------------------------------------------------------------------------------*/
create view P_MyChain as select C.* from P_TChain C
  inner join P_MyScope S on C.Address = S.Address and C.SenderId = S.SenderId;
/*-----------------------------------------------------------------------------------------------*/
create view P_AddrBook(Address) as select distinct(Address) from P_TChain where Address <> 'ROOT';
/*-----------------------------------------------------------------------------------------------*/
create view P_SndBook(SenderId) as select distinct(SenderId) from P_TChain where SenderId <> 'ROOT';
/*-----------------------------------------------------------------------------------------------*/
create view P_ChainInf(
  RecId,
  Checksum)
as
  select first 1
    RecId,
    Checksum
    from P_TChain
    order by RecId desc;
/*-----------------------------------------------------------------------------------------------*/
grant select on P_TChain to trigger P_TBI$TChain;
grant execute on procedure P_IsRepl to trigger P_TBI$TChain;
grant execute on procedure P_Commiting to trigger P_TBI$TChain;
grant execute on procedure P_Trimming to trigger P_TBU$TChain;

grant select on P_Params to trigger P_TBD$TChain;
grant execute on procedure P_IsDehorn to trigger P_TBD$TChain;
grant execute on procedure P_Trimming to trigger P_TBD$TChain;
grant execute on procedure P_RevertBlock to trigger P_TBD$TChain;

grant select on P_TParams to trigger P_TBI$TMeltingPot;
grant execute on procedure P_IsRepl to trigger P_TBI$TMeltingPot;
grant execute on procedure P_IsAddB to trigger P_TBI$TMeltingPot;
grant execute on procedure P_CalcSig to trigger P_TBI$TMeltingPot;
grant execute on procedure P_CalcHash to trigger P_TBI$TMeltingPot;
grant execute on procedure P_IsRepl to trigger P_TBI$TBacklog;
grant select on P_TChain to procedure P_HasBlock;
grant select on P_TMeltingPot to procedure P_HasBlock;

grant all on P_TMeltingPot to procedure P_OnGetBlock;

grant all on P_TBacklog to procedure P_ClearBackLog;
grant execute on procedure P_LogErr to procedure P_ClearBackLog;

grant select on P_TParams to procedure P_ClearMeltingPot;
grant all on P_TMeltingPot to procedure P_ClearMeltingPot;
grant execute on procedure P_LogErr to procedure P_ClearMeltingPot;

grant select on P_TChain to procedure P_UpdateMeltingPot;
grant all on P_TMeltingPot to procedure P_UpdateMeltingPot;
grant execute on procedure P_LogErr to procedure P_UpdateMeltingPot;
/*-----------------------------------------------------------------------------------------------*/

