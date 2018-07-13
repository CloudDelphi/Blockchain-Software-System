/* ======================================================================== */
/* PeopleRelay: chain.sql Version: 0.4.3.6                                  */
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
create generator P_G$BL;
create generator P_G$MP;
create generator P_G$MPSId;
/*-----------------------------------------------------------------------------------------------*/
/*
select
  DateDiff(Second,C.BTime,C.RecTime) as Delta,
  C.*
from P_TChain C
*/

create table P_TChain(
  BlockNo           TRid,
  Chsum             TIntHash not null, /* Block Check Sum */
  BHash             TChHash not null,
  ParBlkNo          TRid,
  ParChsum          TIntHash not null,
  ParBHash          TChHash not null,
  BlockId           TBlockId not null,
  BTime             TTimeMark not null, /* Block creation time */
  Address           TAddress not null,
  SenderId          TSenderId not null,
  Nonce             TNonce,
  RecTime           TTimeMark not null, /* Record time */
  BSig              TSig not null,
  TmpSig            TSig not null,
  /* Temporary Signature of This Node. To check sooth of the transmitter of every block on data trasfer. */
  /* Actually can be calculated dynamically by the calculated field of the P_Chain view. But such is very slow. */

  PubKey            TKey not null,
  primary key       (BlockNo,Chsum,BHash),
  foreign key       (ParBlkNo,ParChsum,ParBHash) references P_TChain(BlockNo,Chsum,BHash));
/*-----------------------------------------------------------------------------------------------*/
create unique index P_XU$Ch1 on P_TChain(BlockNo);
create unique descending index P_XU$Ch2 on P_TChain(BlockNo);
create unique index P_XU$Ch3 on P_TChain(BHash);
create unique descending index P_XU$Ch4 on P_TChain(BHash);
create unique index P_XU$Ch5 on P_TChain(BTime,BHash);
create unique index P_XU$Ch6 on P_TChain(SenderId,BlockId);
/*-----------------------------------------------------------------------------------------------*/
  insert into P_TChain(
    BlockNo,
    Chsum,
    BHash,
    ParBlkNo,
    ParChsum,
    ParBHash,
    BlockId,
    BTime,
    Address,
    SenderId,
    Nonce,
    RecTime,
    BSig,
    TmpSig,
    PubKey)
  values(
    0,   --BlockNo
    0,   --Chsum
    '0', --BHash
    0,   --ParBlkNo
    0,   --ParChsum
    '0', --ParBHash
    '0', --BlockId
    UTCTime(), --BTime
    'ROOT', --Address
    'ROOT', --SenderId
    0,      --TNonce
    UTCTime(), --RecTime
    '0',  --BSig
    '0',  --TmpSig
    '0'); --PubKey
commit work;
/*-----------------------------------------------------------------------------------------------*/
set term ^ ;
/*-----------------------------------------------------------------------------------------------*/
create trigger P_TBI$TChain for P_TChain active before insert position 0
as
  declare IsApp TBoolean;
  declare IsRepl TBoolean;
  declare ParChsum TIntHash;
  declare ParBHash TChHash;
begin
  execute procedure P_IsRepl returning_values IsRepl;
  execute procedure P_Commiting returning_values IsApp; /* Append records flag */
  if (IsApp = 0 and IsRepl = 0)
  then
    exception P_E$Forbidden;
  else
    begin
      select first 1 Chsum,ParBHash from P_TChain order by BlockNo desc into :ParChsum,:ParBHash;
      if (IsApp = 1) then
      begin
        new.BlockNo = new.ParBlkNo + 1;
        new.Chsum = Hash(ParChsum || '-' || ParBHash || '-' || new.BHash);
      end

      if (new.BHash is not null) then
        execute procedure P_SysSig(new.BHash,null) returning_values new.TmpSig;
      new.RecTime = UTCTime();
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
  if (old.BlockNo = 0) then exception P_E$Forbidden;
  if ((select Result from P_IsDehorn) = 1)
  then
    begin
      if ((select Acceptor from P_Params) = 1) then 
        execute procedure P_RevertBlock(old.BlockNo,old.SenderId,old.BlockId);
    end
  else
    if ((select Result from P_Trimming) = 0) then exception P_E$Forbidden;
end^
/*-----------------------------------------------------------------------------------------------*/
set term ; ^
/*-----------------------------------------------------------------------------------------------*/
create table P_TMeltingPot(
  RecId             TRid,
  BHash             TChHash not null,
  BlockId           TBlockId not null,
  BTime             TTimeMark,
  Address           TAddress not null,
  SenderId          TSenderId not null,
  Nonce             TNonce,
  BSig              TSig not null,
  TmpSig            TSig not null,
  PubKey            TKey not null,
  State             TState,
  RT                TCount,
  Own               TBoolean,
  Sid               TRid unique, /* Serial Id */  
  primary key       (RecId));
/*-----------------------------------------------------------------------------------------------*/
create unique index P_XU$MP1 on P_TMeltingPot(SenderId,BlockId);
create unique index P_XU$MP2 on P_TMeltingPot(BHash);
create index P_X$MP1 on P_TMeltingPot(BTime);
create index P_X$MP2 on P_TMeltingPot(State);
create index P_X$MP3 on P_TMeltingPot(Own);
create index P_X$MP4 on P_TMeltingPot(RT);
/*-----------------------------------------------------------------------------------------------*/
set term ^ ;
/*-----------------------------------------------------------------------------------------------*/
create trigger P_TBI$TMeltingPot for P_TMeltingPot active before insert position 0
as
  declare IsAddB TBoolean;
  declare IsRepl TBoolean;
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
      new.Sid = -new.RecId; /* Minus sign is here to prevent coinsedence of P_G$MP and P_G$MPSId */
      /* Cannot put Gen_Id(P_G$MPSId,1) here because of on exception, P_G$MPSId sequenced value will be lost */

      if (new.BHash is not null) then
        execute procedure P_SysSig(new.BHash,null) returning_values new.TmpSig;

      if (IsAddB = 1) then
      begin
        new.Own = 1;
        new.BTime = UTCTime();
        if (new.BlockId is null) then /* Sender can assign it. */
          new.BlockId = uuid_to_Char(gen_uuid());
      end
    end
end^
/*-----------------------------------------------------------------------------------------------*/
create trigger P_TAI$TMeltingPot for P_TMeltingPot active after insert position 0
as
begin
--  grant execute on procedure P_IsMPSid to trigger P_TAI$TMeltingPot;
--  if ((select Result from P_IsMPSid) = 0) then
--  begin

  execute procedure P_BegMPSid;

  update P_TMeltingPot set Sid = gen_id(P_G$MPSId,1) where RecId = new.RecId;
  /* Sid is continuous sequence; RecId sequence may contain gaps. */

  execute procedure P_EndMPSid;

  when any do
  begin
    execute procedure P_EndMPSid;
    Exception;
  end

end^
/*-----------------------------------------------------------------------------------------------*/
/*
grant execute on procedure P_IsMPSid to trigger P_TBU$TMeltingPot;
grant execute on procedure P_IsDehorn to trigger P_TBU$TMeltingPot;

create trigger P_TBU$TMeltingPot for P_TMeltingPot active before update position 0
as
begin
  if ((select Result from P_IsMPSid) = 0) then
  begin

    new.RecId = old.RecId;
    if ((select Result from P_IsDehorn) = 1)
    then
      new.RT = Gen_Id(P_G$RTT,0);
    else
      new.RT = old.RT;

    new.RT = old.RT;
    new.RecId = old.RecId;

  end
end^
*/
/*-----------------------------------------------------------------------------------------------*/
set term ; ^
/*-----------------------------------------------------------------------------------------------*/
create table P_TBacklog(
  RecId             TRid,
  BlockNo           TRid, -- unique,
  Chsum             TIntHash not null,
  BHash             TChHash not null,
  ParBlkNo          TRid,
  ParChsum          TIntHash not null,
  ParBHash          TChHash not null,
  BlockId           TBlockId not null,
  BTime             TTimeMark,
  Address           TAddress not null,
  SenderId          TSenderId not null,
  Nonce             TNonce,
  BSig              TSig not null,
  PubKey            TKey not null,
  RT                TCount,
  primary key       (RecId));
/*-----------------------------------------------------------------------------------------------*/
create unique index P_XU$BL1 on P_TBacklog(BlockNo,Chsum,BHash);
create index P_X$BL1 on P_TBacklog(BHash);
create index P_X$BL3 on P_TBacklog(RT);
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
  new.RecId = gen_id(P_G$BL,1);  
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
  delete from P_TBacklog L where exists (select 1 from P_TChain C where C.BHash = L.BHash);
  when any do
    execute procedure P_LogErr(-33,sqlcode,gdscode,sqlstate,'P_ClearBackLog',null,'Error',null);
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_ChainSize
returns
  (Result TCount)
as
begin
  select Max(BlockNo) from P_TChain into :Result;
  suspend;
end^
/*-----------------------------------------------------------------------------------------------*/
create trigger P_TAI$TChain for P_TChain active after insert position 0
as
begin
  update P_TMeltingPot
    set
      State = 1
    where SenderId = new.SenderId
      and BlockId = new.BlockId
      and State = 0;
end^
/*-----------------------------------------------------------------------------------------------*/
set term ; ^
/*-----------------------------------------------------------------------------------------------*/
create view P_Chain as select * from P_TChain where (select Online from P_TParams) > 0;
create view P_MeltingPot as select * from P_TMeltingPot where (select Online from P_TParams) > 0;
/*-----------------------------------------------------------------------------------------------*/
create view P_MyChain as select C.* from P_TChain C
  inner join P_MyScope S on C.Address = S.Address and C.SenderId = S.SenderId;
/*-----------------------------------------------------------------------------------------------*/
create view P_Backlog as select * from P_TBacklog;
/*-----------------------------------------------------------------------------------------------*/
create view P_AddrBook(Address) as select distinct(Address) from P_TChain where Address <> 'ROOT';
/*-----------------------------------------------------------------------------------------------*/
create view P_SndBook(SenderId) as select distinct(SenderId) from P_TChain where SenderId <> 'ROOT';
/*-----------------------------------------------------------------------------------------------*/
create view P_ChainInf(
  BlockNo,
  Chsum)
as
  select first 1
    BlockNo,
    Chsum
    from P_TChain
    order by BlockNo desc;
/*-----------------------------------------------------------------------------------------------*/
grant select on P_TChain to trigger P_TBI$TChain;
grant execute on procedure P_IsRepl to trigger P_TBI$TChain;
grant execute on procedure P_SysSig to trigger P_TBI$TChain;
grant execute on procedure P_Commiting to trigger P_TBI$TChain;
grant execute on procedure P_Trimming to trigger P_TBU$TChain;

grant select on P_Params to trigger P_TBD$TChain;
grant execute on procedure P_IsDehorn to trigger P_TBD$TChain;
grant execute on procedure P_Trimming to trigger P_TBD$TChain;
grant execute on procedure P_RevertBlock to trigger P_TBD$TChain;

grant all on P_TBacklog to trigger P_TAI$TChain;
grant all on P_TMeltingPot to trigger P_TAI$TChain;

grant select on P_TParams to trigger P_TBI$TMeltingPot;
grant execute on procedure P_IsRepl to trigger P_TBI$TMeltingPot;
grant execute on procedure P_IsAddB to trigger P_TBI$TMeltingPot;
grant execute on procedure P_SysSig to trigger P_TBI$TMeltingPot;

grant all on P_TMeltingPot to trigger P_TAI$TMeltingPot;
grant execute on procedure P_BegMPSid to trigger P_TAI$TMeltingPot;
grant execute on procedure P_EndMPSid to trigger P_TAI$TMeltingPot;

grant execute on procedure P_IsRepl to trigger P_TBI$TBacklog;
grant select on P_TChain to procedure P_HasBlock;
grant select on P_TMeltingPot to procedure P_HasBlock;

grant all on P_TMeltingPot to procedure P_OnGetBlock;

grant all on P_TBacklog to procedure P_ClearBackLog;
grant select on P_TChain to procedure P_ClearBackLog;
grant execute on procedure P_LogErr to procedure P_ClearBackLog;

grant select on P_TChain to procedure P_ChainSize;
/*-----------------------------------------------------------------------------------------------*/

