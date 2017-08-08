/* ************************************************************************ */
/* PeopleRelay: params.sql Version: see version.sql                         */
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
create table P_TTransponder(
  HPrime            TIntHash not null,
  HCluster          TIntHash,
  Prime             TPrime not null,
  Cluster           TClusterId
);
/*-----------------------------------------------------------------------------------------------*/
set term ^ ;
/*-----------------------------------------------------------------------------------------------*/
create trigger P_TBI$TTrnspd for P_TTransponder active before insert position 0
as
begin
  new.HPrime = Hash(new.Prime);
  new.HCluster = Hash(new.Cluster);
end^
/*-----------------------------------------------------------------------------------------------*/
create trigger P_TBU$TTrnspd for P_TTransponder active before update position 0
as
begin
  new.HPrime = Hash(new.Prime);
  new.HCluster = Hash(new.Cluster);
end^
/*-----------------------------------------------------------------------------------------------*/
set term ; ^
/*-----------------------------------------------------------------------------------------------*/
create table P_TParams(
  NodeId            TNodeId default '-' not null,
  Alias             TNdAlias,
  Status            TNdStatus,
  Online            TBoolean default 1,
  Acceptor          TBoolean, /* set it = 1 to allow to receive Sender blocks */
  IpTimeout         TUInt default 5000, /* milliseconds, if = 0, then do not pretest peer Node availability */
  PingDelay         SmallInt default 30 not null, /* seconds, Allowed Max Ping Time, do repl if Ping time <= PingDelay only */
  PingCount         TUInt1, /* How many times to call ping to get avg delay */
  ExtUsrLg          TBoolean default 1, /* if = 1 then log external user attach */
  IpMaskLen         TUInt, /* Ip Mask length CIDR Classless Inter-Domain Routing */
  StaticIP          TIPV6str,
  APort             TPort default '3050',
  ExtAcc            TUserName default 'Replicator' not null, /* External User Name, to get data */
  ExtPWD            TPWD default '0' not null,
  MinPWDLen         TUInt default 5, /* if = 0 then do not auto manage user accounts. Max pwd length is depends on RDMS version */
  TMOverlap         Float default 3.0 not null, /* Time overlap for repl ops in minutes. */
  MPTokenBus        TBoolean default 1, /* if = 1 then do Replicate P_TMPVoter */
  CHTokenBus        TBoolean, /* if = 1 then do Replicate P_TSMVoter */
  SndControl        TBoolean default 1, /* if = 1 then control whether user registered in the P_TACL as a Sender */
  RateInc           Float default 0.5 not null, /* To add value to P_TNode.Rating */
  RateDec           Float default 1.0 not null, /* To substract value from P_TNode.Rating */
  MinRate           TRating default -128,
  MaxRate           TRating default 128,
  NDQuorumAcc       TBoolean, /* if = 0, do not check quorum if Self is Acceptor in P_FixNodes */
  CHQuorumAcc       TBoolean, /* if = 0, do not check quorum if Self is Acceptor in P_FixChain */

  ChckHshCL         TBoolean default 1, /*(Client) If = 1 then verify block Hash while insert new Block into Acceptor DB */
  ChckSigCL         TBoolean default 1, /*(Client) If = 1 then verify LoadSig while insrt new Block into Acceptor DB */
  ChckHshCH         TBoolean default 1, /* If = 1 then verify block Hash while replicate Chain */
  ChckSigCH         TBoolean default 1, /* If = 1 then verify LoadSig while replicate Chain */
  ChckHshMP         TBoolean default 1, /* (Must be the same for part/all Acceptors) If = 1 then verify block Hash while replicate Melting Pot */
  ChckSigMP         TBoolean default 1, /* (Must be the same for part/all Acceptors) If = 1 then verify LoadSig while replicate Melting Pot */
  ChckSigNdPng      TBoolean, /* If = 1 then verify Node LoadSig while ping Node */
  ChckSigNdAcc      TBoolean, /* If = 1 then verify LoadSig while register Node and replicate Node List, if Node is Acceptor */
  ChckSigNdOrd      TBoolean, /* If = 1 then verify LoadSig while register Node and replicate Node List, if Node is not Acceptor */
  MetaCheckPut      TBoolean, /* If = 1 then do check a peer db objects identity before register */
  MetaCheckGet      TBoolean default 1, /* If = 1 then do check a peer db objects identity before pull data */
  TimeSlice         TInt32 default 10 not null, /* Work Time Slice in minutes */
  SyncSpan          TUInt1 default 5, /* Sync interval in seconds. */

  MPQFactor         TUInt1 default 2, /* Minimum Sync rounds before do Chain Commit. RTC round_trip_count. */
  MPDelLinger       TUInt1 default 4, /* delete records from Melting Pot when Loop > MPDelLinger. */

  DehornPower       TUInt1 default 7,

  WaitBackLog       TBoolean default 1, /* if = 1 then wait until chain back log hase State = 1 for all recs before exec P_Commit */
  LimboLoop         TUInt, /* Get limbo records of peer(s) Melting pot if State = 0 and P_MeltingPot.Loop >= LimboLoop */
  -- Default value is 0, do NOT change it if you do not know exactly what purpose it is for.

  PowerOnReset      TUInt default 32,   /* if = 0 do nothing; Detect inactive period measured in SyncSpan intervals. */
  AutoRegister      TBoolean default 1, /* If = 1 do Register Self if Node was inactive */
  MaxConnIdl        TUInt default 128,  /* Reject new connect if Max allowed count of idle connections is exceeded. */
  MaxConnAct        TUInt default 64,   /* Reject new connect if Max allowed count of active connections is exceeded. */
  MaxAgeIdlCn       TTimeGap default 16 not null, /* Max age (minutes) of idle connections to be killed. */
  MaxAgeActCn       TTimeGap default 30 not null, /* Max age (minutes) of active connections to be killed. */
/*
 Connection management functionality is fully available for SYSDBA, DB Owner or
 User having role the name of RDB$ADMIN (use role argument when connecting to db
 or if user allways the same).
*/
  LogBlockChk       TBoolean, /* 1 - log block checks; */
  LogIpBan          TBoolean, /* if = 1 then log attempt to connect from banned ip as error */
  LogAttach         TLogMode, /* 0 - not at all; 1 - unknown users only; 2 - by P_TACL.LogAttach only; 3 - unknown & by P_TACL.LogAttach flag. */
  SndLogMode        TLogMode, /* If = 0, no log at all; If = 1, Err only; If = 2, Msg only; If = 3, Errs & Msgs */
  MsgLogMode        TLogMode, /* If = 0, no log at all; If = 1, Err only; If = 2, Msg only; If = 3, Errs & Msgs */
  RplLogMode        TLogMode, /* Replication Log; If = 0, no log at all; If = 1, Err only; If = 2, Msg only; If = 3, Errs & Msgs */
  FineBadMeta       TFine, /* Bad Node Metadata. 0 - nothing; 1 - dec rate; 2 - expel node; 3 - dec rate & expel */
  FineBadHash       TFine, /* Bad Bolock Hash. 0 - nothing; 1 - dec rate; 2 - expel node; 3 - dec rate & expel */
  Broadband         TBoolean, /* if = 0 then Acceptors can communicate with ordinal nodes */
  NdRegFilter       TNdFilter, /* 0 - not allow register any Node in Self Node List at all; 1 - Acceptors; 2 - Ordinal; 3 - all Nodes are welcome */
  NodeListSync      TNdFilter, /* 0 - not allow sync any Node in Self Node List at all; 1 - Acceptors; 2 - Ordinal; 3 - all Nodes are welcome */
  NdLstSizeAcc      TCount default 4096, /* Max count of Acceptor nodes in the Node List in records */
  NdLstHoldAcc      TNdLsHold, /* 0 - not care at all; 1 - Do not add new Node; 2 - add new Node then del low rating Nodes */
  NdDelDelayAcc     TUInt default 360, /* Delay in days before delete Disabled Node from the Node List */
  NdLstSizeOrd      TCount default 8192, /* Max count of ordinary nodes in the Node List in records */
  NdLstHoldOrd      TNdLsHold, /* 0 - not care at all; 1 - Do not add new Node; 2 - add new Node then del low rating Nodes */
  NdDelDelayOrd     TUInt default 96, /* Delay in days before delete Disabled Node from the Node List */
  ChkLogSize        TCount default 32000, /* Size of P_TDBLog in records */
  AttLogSize        TCount default 32000, /* Size of P_TDBLog in records */
  SysLogSize        TCount default 32000,
  RepLogSize        TCount default 5000, /* Max size of the replication log in records */
  LLimboSpan        TUInt default 10240, /* Back Log Limbo Span see P_CheckLimbo */
  DefAddress        TAddress,
  DefSenderId       TSenderId,
  SigHash           TIntHash,
  LoadSig           TSig,
  PubKey            TKey,
  PvtKey            TKey,
  AlteredAt         TTimeMark,
  CreatedBy         TOperName,
  ChangedBy         TOperName,
  CreatedAt         TTimeMark not null,
  ChangedAt         TTimeMark not null);
/*-----------------------------------------------------------------------------------------------*/
set term ^ ;
/*-----------------------------------------------------------------------------------------------*/
create procedure P_ExtAccGrant(AUser TSysStr31)
as
begin
  execute procedure SYS_GrantExec('P_Echo',AUser);
  execute procedure SYS_GrantExec('P_RegNode',AUser);
  execute procedure SYS_GrantExec('P_IsBlock',AUser);
  execute procedure SYS_GrantExec('P_HasBlock',AUser);  

  execute procedure SYS_GrantView('P_Node',AUser);
  execute procedure SYS_GrantView('P_Chain',AUser);
  execute procedure SYS_GrantView('P_TMPVoter',AUser);
  execute procedure SYS_GrantView('P_MeltingPot',AUser);

  execute procedure P_NewSndAcc(AUser); /* To allow work as a Sender should be needed. */
end^
/*-----------------------------------------------------------------------------------------------*/
create trigger P_TBI$TParams for P_TParams active before insert position 0
as
  declare ATest TInt32;
  declare AHash TChHash;
begin
  select count(*) from P_TParams into :ATest;
  if (ATest > 0) then exception P_E$OneRecNeeded;

  new.APort = Upper(new.APort);
  new.NodeId = Upper(new.NodeId);
  new.ExtAcc = Upper(new.ExtAcc);

  if (new.AttLogSize is null or new.AttLogSize < 265) then new.AttLogSize = 265;
  if (new.SysLogSize is null or new.SysLogSize < 265) then new.SysLogSize = 265;

  new.CreatedBy = CURRENT_USER;
  new.CreatedAt = CURRENT_TIMESTAMP;
  new.ChangedBy = new.CreatedBy;
  new.ChangedAt = new.CreatedAt;

  if (new.PvtKey is not null) then
  begin
    execute procedure P_GetNodeHash(
      new.NodeId,new.Alias,new.Acceptor,new.APort,new.ExtAcc,new.ExtPWD) returning_values AHash;
    execute procedure P_CalcSig(AHash,new.PvtKey) returning_values new.LoadSig;
    new.SigHash = Hash(new.LoadSig);
  end
end^
/*-----------------------------------------------------------------------------------------------*/
create trigger P_TBU$TParams for P_TParams active before update position 0
as
  declare AHash TChHash;
begin
  if ((select Result from P_IsAlt) = 0) then
  begin
    new.APort = Upper(new.APort);
    new.NodeId = Upper(new.NodeId);
    new.ExtAcc = Upper(new.ExtAcc);

    if (new.ExtAcc is distinct from old.ExtAcc) then
      execute procedure SYS_CheckExtAcc(new.ExtAcc);

    if (new.MPDelLinger < new.MPQFactor) then new.MPDelLinger = new.MPQFactor;

    if (new.AttLogSize is null or new.AttLogSize < 265) then new.AttLogSize = 265;
    if (new.SysLogSize is null or new.SysLogSize < 265) then new.SysLogSize = 265;
    if (new.LLimboSpan > 0 and new.LLimboSpan < 8) then new.LLimboSpan = 8;

    if (new.MinRate > -8) then new.MinRate = -8;
    if (new.MaxRate < 8) then new.MaxRate = 8;

    if (old.NodeId <> '-') then new.NodeId = old.NodeId;

    if (new.NdLstSizeAcc = 0)
    then
      new.NdLstHoldAcc = 0;
    else
      if (new.NdLstHoldAcc = 0) then new.NdLstSizeAcc = 0;

    if (new.NdLstSizeOrd = 0)
    then
      new.NdLstHoldOrd = 0;
    else
      if (new.NdLstHoldOrd = 0) then new.NdLstSizeOrd = 0;

    if (new.Acceptor is distinct from old.Acceptor
      or new.NodeId is distinct from old.NodeId
      or new.Alias is distinct from old.Alias
      or new.ExtAcc is distinct from old.ExtAcc
      or new.ExtPWD is distinct from old.ExtPWD
      or new.PubKey is distinct from old.PubKey
      or new.PvtKey is distinct from old.PvtKey
      or new.IpMaskLen is distinct from old.IpMaskLen
      or new.StaticIP is distinct from old.StaticIP
      or new.APort is distinct from old.APort)
    then
      begin
        new.AlteredAt = CURRENT_TIMESTAMP;
        if (new.PvtKey is not null) then
        begin
          execute procedure P_GetNodeHash(
            new.NodeId,new.Alias,new.Acceptor,new.APort,new.ExtAcc,new.ExtPWD) returning_values AHash;
          execute procedure P_CalcSig(AHash,new.PvtKey) returning_values new.LoadSig;
          new.SigHash = Hash(new.LoadSig);
        end
      end
    else
      if (new.Status is distinct from old.Status) then
        new.AlteredAt = CURRENT_TIMESTAMP;

  end
  new.CreatedBy = old.CreatedBy;
  new.CreatedAt = old.CreatedAt;
  new.ChangedBy = CURRENT_USER;
  new.ChangedAt = CURRENT_TIMESTAMP;
end^
/*-----------------------------------------------------------------------------------------------*/
create trigger P_TAU$TParams for P_TParams active after update position 0
as
  declare fN TBoolean;
begin
  if ((select Result from P_IsAlt) = 0
    and new.MinPWDLen > 0) then
  begin
    if (new.ExtPWD is distinct from old.ExtPWD
      and char_length(new.ExtPWD) < new.MinPWDLen)
    then
      exception P_E$ShortPWD;
    if (new.ExtAcc is distinct from old.ExtAcc) then fN = 1;
    if (fN = 1) then execute procedure SYS_DropAcc(old.ExtAcc);
    if (fN = 1
      or new.ExtPWD is distinct from old.ExtPWD)
    then
      begin
        execute procedure SYS_AltAcc(new.ExtAcc,new.ExtPWD);
        execute procedure P_ExtAccGrant(new.ExtAcc);
      end
  end

  if (new.AlteredAt is distinct from old.AlteredAt) then
    execute procedure P_ClearRegLog2;
end^
/*-----------------------------------------------------------------------------------------------*/
create trigger P_TBD$TParams for P_TParams active before delete position 0
as
begin
  exception P_E$OneRecNeeded;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_Altered(Flag TBoolean)
as
  declare ATest TTimeMark;
begin
  if ((select Result from P_BegAlt)= 1) then
  begin
    select AlteredAt from P_TParams
      for update of AlteredAt WITH LOCK into :ATest;

    if (ATest is not null) then
      if (Flag = 0)
      then
        update P_TParams set AlteredAt = null;
      else
        update P_TParams set AlteredAt = CURRENT_TIMESTAMP;

    execute procedure P_EndAlt;
  end
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_LoadKeys
as
  declare PvtKey TSysStr1K;
  declare PubKey TSysStr1K;
begin
  execute procedure P_RsaKey returning_values PvtKey,PubKey;
  update P_TParams set PubKey = :PubKey,PvtKey = :PvtKey;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_DefAddr
returns
  (Result TAddress)
as
begin
  select DefAddress from P_TParams into :Result;
  if (Result is null or Result = '') then
  begin
    Result = uuid_to_Char(gen_uuid());
    in autonomous transaction do
      update P_TParams set DefAddress = :Result;
  end
  suspend;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_DefSndId
returns
  (Result TSenderId)
as
begin
  select DefSenderId from P_TParams into :Result;
  if (Result is null or Result = '') then
  begin
    Result = uuid_to_Char(gen_uuid());
    in autonomous transaction do
      update P_TParams set DefSenderId = :Result;
  end
  suspend;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_DefAlias
returns
  (Result TNdAlias)
as
begin
  select Alias from P_TParams into :Result;
  if (Result is null or Result = '') then
  begin
    Result = '@' || Substring(uuid_to_Char(gen_uuid()) from 1 for 8);
    in autonomous transaction do
      update P_TParams set Alias = :Result;
  end
  suspend;
end^
/*-----------------------------------------------------------------------------------------------*/
set term ; ^
/*-----------------------------------------------------------------------------------------------*/
create view P_Params as select * from P_TParams;
/*-----------------------------------------------------------------------------------------------*/
grant select on P_TParams to trigger P_TBI$TParams;
grant execute on procedure P_CalcSig to trigger P_TBI$TParams;
grant execute on procedure P_GetNodeHash to trigger P_TBI$TParams;

grant execute on procedure P_IsAlt to trigger P_TBU$TParams;
grant execute on procedure P_CalcSig to trigger P_TBU$TParams;
grant execute on procedure P_GetNodeHash to trigger P_TBU$TParams;
grant execute on procedure SYS_CheckExtAcc to trigger P_TBU$TParams;

grant execute on procedure P_IsAlt to trigger P_TAU$TParams;
grant execute on procedure SYS_AltAcc to trigger P_TAU$TParams;
grant execute on procedure SYS_DBOwner to trigger P_TAU$TParams;
grant execute on procedure SYS_DropAcc to trigger P_TAU$TParams;
grant execute on procedure P_ExtAccGrant to trigger P_TAU$TParams;
grant execute on procedure P_ClearRegLog2 to trigger P_TAU$TParams;

grant execute on procedure P_NewSndAcc to procedure P_ExtAccGrant;
grant execute on procedure SYS_GrantExec to procedure P_ExtAccGrant;
grant execute on procedure SYS_GrantView to procedure P_ExtAccGrant;

grant all on P_TParams to procedure P_LoadKeys;
grant execute on procedure P_RsaKey to procedure P_LoadKeys;

grant all on P_TParams to procedure P_DefAddr;
grant all on P_TParams to procedure P_DefSndId;
grant all on P_TParams to procedure P_DefAlias;

grant all on P_TParams to procedure P_Altered;
grant execute on procedure P_BegAlt to procedure P_Altered;
grant execute on procedure P_EndAlt to procedure P_Altered;
/*-----------------------------------------------------------------------------------------------*/

