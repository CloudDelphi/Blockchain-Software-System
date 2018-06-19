/* ======================================================================== */
/* PeopleRelay: params.sql Version: 0.4.1.8                                 */
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
create table P_TTransponder(
  HPrime            TIntHash not null,
  HCluster          TIntHash,
  Prime             TPrime not null,
  Cluster           TClusterId
);
/*-----------------------------------------------------------------------------------------------*/
insert into P_TTransponder(HPrime,HCluster,Prime,Cluster) values(0,0,'','');
commit work;
/*-----------------------------------------------------------------------------------------------*/
set term ^ ;
/*-----------------------------------------------------------------------------------------------*/
create trigger P_TBI$TTrnspd for P_TTransponder active before insert position 0
as
begin
  exception P_E$Forbidden;
end^
/*-----------------------------------------------------------------------------------------------*/
create trigger P_TBU$TTrnspd for P_TTransponder active before update position 0
as
begin
  new.Prime = Upper(new.Prime);
  new.Cluster = Upper(new.Cluster);
  
  new.HPrime = Hash(new.Prime);
  new.HCluster = Hash(new.Cluster);
end^
/*-----------------------------------------------------------------------------------------------*/
create trigger P_TBD$TTrnspd for P_TTransponder active before delete position 0
as
begin
  exception P_E$Forbidden;
end^
/*-----------------------------------------------------------------------------------------------*/
set term ; ^
/*-----------------------------------------------------------------------------------------------*/
/*
 Connection management functionality is fully available for SYSDBA, DB Owner or
 User having role the name of RDB$ADMIN (use role argument when connecting to db
 or if user allways the same).
*/

create table P_TParams(
  NodeId            TNodeId default '-' not null,
  Alias             TNdAlias default '-' not null,
  Status            TNdStatus,
  Online            TBoolean default 1,
  Acceptor          TBoolean, /* set it = 1 to allow to receive Sender blocks */
  IpTimeout         TUInt default 5000, /* milliseconds, if = 0, then do not pretest peer Node availability */
  PingDelay         TTimeGap default 30.0 not null, /* seconds, Allowed Max Ping Time, do repl if Ping time <= PingDelay only */
  PingCount         TUInt1, /* How many times to call ping to get avg delay */

  IpMaskLen         TUInt, /* Ip Mask length CIDR Classless Inter-Domain Routing */
  StaticIP          TIPV6str,
  APort             TPort default '3050' not null,
  ExtAcc            TUserName default '-' not null, /* External User Name, to get data */
  ExtPWD            TPWD default '-' not null,
  NDOverlap         TUInt,            /* RecId overlap for repl P_TNode. Do not set it > 0 if you don't know wat you do exactly. */
  MPOverlap         TUInt,  /* RecId overlap for repl Melting Pot. */

  MPTokenBus        TBoolean, /* if = 1 then do Replicate P_TMPVoter */
  CHTokenBus        TBoolean, /* if = 1 then do Replicate P_TSMVoter */
  SndControl        TBoolean default 1, /* if = 1 then control whether user registered in the P_TACL as a Sender */

  NDQuorumAcc       TBoolean, /* if = 0, do not check quorum in P_FixNodes if Self is Acceptor */
  CHQuorumAcc       TBoolean, /* if = 0, do not check quorum if Self is Acceptor in P_FixChain */


  ChckHshCL         TBoolean default 1, /*(Client) If = 1 then verify block Hash while insert new Block into Acceptor DB */
  ChckSigCL         TBoolean default 1, /*(Client) If = 1 then verify LoadSig while insrt new Block into Acceptor DB */

  ChckHshCH         TBoolean default 1, /* If = 1 then verify block Hash while replicate Chain */
  ChckLcsCH         TBoolean default 1, /* If = 1 then verify LocalSig while replicate Chain */
  ChckSigCH         TBoolean default 1, /* If = 1 then verify LoadSig while replicate Chain */

  ChckHshMP         TBoolean default 1, /* If = 1 then verify block Hash while replicate Melting Pot */
  ChckLcsMP         TBoolean default 1, /* If = 1 then verify LocalSig while replicate Melting Pot */
  ChckSigMP         TBoolean default 1, /* If = 1 then verify LoadSig while replicate Melting Pot */

  ChckIdNdAcc       TBoolean default 1, /* If = 1 then verify NodeId while register Node and replicate Node List, if Node is Acceptor */
  ChckIdNdOrd       TBoolean default 1, /* If = 1 then verify NodeId while register Node and replicate Node List, if Node is not Acceptor */
  ChckLcsNdAcc      TBoolean default 1, /* If = 1 then verify LocalSig while replicate Node List, if Node is Acceptor */
  ChckLcsNdOrd      TBoolean default 1, /* If = 1 then verify LocalSig while replicate Node List, if Node is not Acceptor */
  ChckSigNdAcc      TBoolean default 1, /* If = 1 then verify LoadSig while register Node and replicate Node List, if Node is Acceptor */
  ChckSigNdOrd      TBoolean default 1, /* If = 1 then verify LoadSig while register Node and replicate Node List, if Node is not Acceptor */

  MetaCheckPut      TBoolean, /* If = 1 then do check a peer db objects identity before register */
  MetaCheckGet      TBoolean default 1, /* If = 1 then do check a peer db objects identity before pull data */
  TimeSlice         TInt32 default 10 not null, /* Work Time Slice in minutes */
  SyncSpan          TUInt1 default 5,  /* Sync interval in seconds. */

  RLLinger          TUInt1 default 7,  /* to delete records from P_TRegAim. */

  MPQFactor         TUInt1 default 7,    /* Minimum Sync rounds before do Chain Commit. */
  MPLinger          TUInt1 default 4096, /* delete records from Melting Pot. */

  DehornPower       TUInt1 default 16,
  WaitBackLog       TBoolean default 1, /* if = 1 then wait until chain back log hase State = 1 for all recs before exec P_Commit */
  PowerOnReset      TUInt default 16,   /* if = 0 do nothing; Detect inactive period measured in SyncSpan intervals. */

  AutoRegister      TBoolean default 1, /* If = 1 do Register Self if Node was inactive */
  RegisterSpan      TUInt default 1024, /* Round Trips to force Network re-register; if = 0 do nothing. */

  MaxConnIdl        TUInt default 128,  /* Reject new connect if Max allowed count of idle connections is exceeded. */
  MaxConnAct        TUInt default 64,   /* Reject new connect if Max allowed count of active connections is exceeded. */
  MaxAgeIdlCn       TTimeGap default 16 not null, /* Max age (minutes) of idle connections to be killed. */
  MaxAgeActCn       TTimeGap default 30 not null, /* Max age (minutes) of active connections to be killed. */

  LogBlockChk       TBoolean, /* 1 - log block checks; */
  LogAttErr         TBoolean default 1, /* if = 1 then log connection error */
  SndLogMode        TLogMode, /* If = 0, no log at all; If = 1, Err only; If = 2, Msg only; If = 3, Errs & Msgs */
  MsgLogMode        TLogMode, /* If = 0, no log at all; If = 1, Err only; If = 2, Msg only; If = 3, Errs & Msgs */
  RplLogMode        TLogMode, /* Replication Log; If = 0, no log at all; If = 1, Err only; If = 2, Msg only; If = 3, Errs & Msgs */

  ExpelBadLcs       TBoolean default 1, /* Expel node having Bad Local Signature. */
  ExpelBadMeta      TBoolean default 1, /* Expel node having Bad Node Metadata. */
  ExpelBadHash      TBoolean default 1, /* Expel node having Bad Bolock Hash. */
  ExpelBadSign      TBoolean default 1, /* Expel node having Bad Bolock Signature. */
  Broadband         TBoolean, /* if = 0 then Acceptors can communicate with ordinal nodes */

  Handshake         THandshake, /* if > 0 then perform Handshake protocol the version of Handshake value */
  NdPubFilter       TNdFilter,  /* 0 - Peer not allowed to get our Node List at all; 1 - Acceptors; 2 - Ordinal; 3 - all Nodes are welcome */
  NdRegFilter       TNdFilter,  /* 0 - not allow register any Node in Self Node List at all; 1 - Acceptors; 2 - Ordinal; 3 - all Nodes are welcome */
  NodeListSync      TNdFilter,  /* 0 - not allow sync any Node in Self Node List at all; 1 - Acceptors; 2 - Ordinal; 3 - all Nodes are welcome */
  NdLstSizeAcc      TCount default 4096, /* Max count of Acceptor nodes in the Node List in records */
  NdLstHoldAcc      TNdLsHold, /* 0 - not care at all; 1 - Do not add new Node; 2 - add new Node then del low rating Nodes */
  NdLstSizeOrd      TCount default 8192, /* Max count of ordinary nodes in the Node List in records */
  NdLstHoldOrd      TNdLsHold, /* 0 - not care at all; 1 - Do not add new Node; 2 - add new Node then del low rating Nodes */
  NdDelDelayAcc     TUInt default 7, /* Delay in days before delete Disabled Node from the Node List */
  NdDelDelayOrd     TUInt default 3, /* Delay in days before delete Disabled Node from the Node List */

  RateRetro         TTimeGap default 4320 not null, /* Stats retrospective in minutes before from now to calculate node rating. */

  ChkLogSize        TCount default 16384, /* Size of P_TChecks in records */
  AttLogSize        TCount default 16384, /* Size of P_TDBLog in records */
  SysLogSize        TCount default 16384,
  CtrLogSize        TCount default 64,
  NdDataSize        TCount default 64, /* Node Data Size */
  RepLogSize        TCount default 1024, /* Max size of the replication log in records */

  SweepSpan         TUInt default 10000, /* P_Sweep */
  LacunaSpan        TUInt default 16,    /* RT to wait items in ordered Lists. */
  RepairSpan        TUInt default 16,    /* Round Trips before run P_Repair proc. */

  DefAddress        TAddress,
  DefSenderId       TSenderId,
  SigHash           TIntHash,
  LoadSig           TSig,
  PubKey            TKey,
  PvtKey            TKey,
  AlteredAt         TTimeMark,
  ChangedBy         TOperName,
  ChangedAt         TTimeMark not null);
/*-----------------------------------------------------------------------------------------------*/
--insert into P_TParams default values;
insert into P_TParams(ChangedBy,ChangedAt) values(CURRENT_USER,UTCTime());
commit work;
/*-----------------------------------------------------------------------------------------------*/
set term ^ ;
/*-----------------------------------------------------------------------------------------------*/
create procedure P_GetPvtKey
returns
  (Result TKey)
as
begin
  select PvtKey from P_TParams into :Result;

  suspend;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_SysSig(AHash TChHash, PvtKey TKey)
returns
  (Result TSig)
as
begin
  if (AHash is not null) then
  begin
    if (PvtKey is null) then
      execute procedure P_GetPvtKey returning_values PvtKey;

    if (PvtKey is not null) then
      Result = rsasig((select Result from P_SKeySz),PvtKey,AHash);
  end
end^
/*-----------------------------------------------------------------------------------------------*/
create trigger P_TBI$TParams for P_TParams active before insert position 0
as
begin
  exception P_E$OneRecNeeded;
end^
/*-----------------------------------------------------------------------------------------------*/
create trigger P_TBU$TParams for P_TParams active before update position 0
as
  declare AHash TChHash;
begin
  if ((select Result from P_IsAlt) = 0) then
  begin

    if (new.PubKey is distinct from old.PubKey)
    then
      begin
        if (new.PubKey is null)
        then
          new.NodeId = '-';
        else
          execute procedure P_CalcHash(new.PubKey) returning_values new.NodeId;
      end
    else
      new.NodeId = old.NodeId;

    new.ExtAcc = Upper(new.ExtAcc);
    new.LoadSig = old.LoadSig;
    new.SigHash = old.SigHash;

    if (new.ExtAcc is distinct from old.ExtAcc) then
      execute procedure SYS_CheckExtAcc(new.ExtAcc);

    if (new.MPLinger < new.MPQFactor) then new.MPLinger = new.MPQFactor;
    if (new.AttLogSize is null or new.AttLogSize < 265) then new.AttLogSize = 265;
    if (new.SysLogSize is null or new.SysLogSize < 265) then new.SysLogSize = 265;
    if (new.CtrLogSize < 2) then new.CtrLogSize = 2;
    if (new.NdDataSize < 16) then new.NdDataSize = 16;
    if (new.LacunaSpan < 3) then new.LacunaSpan = 3;
    if (new.SweepSpan < 1024) then new.SweepSpan = 1024;

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
      or new.APort is distinct from old.APort)
    then
      begin
        new.AlteredAt = UTCTime();
/*
        if (new.PubKey is null) then new.PvtKey = null;
        if (new.PvtKey is null) then
        begin
          new.PubKey = null;
          new.LoadSig = null;
          new.SigHash = null;
        end
*/

        if (new.PvtKey is null)
        then
          begin
            new.LoadSig = null;
            new.SigHash = null;
          end
        else
          begin
            execute procedure P_GetNodeHash(
              new.NodeId,
              new.Alias,
              new.Acceptor,
              new.APort,
              (select Result from SYS_DBName),
              new.ExtAcc,
              new.ExtPWD) returning_values AHash;
            execute procedure P_SysSig(AHash,new.PvtKey) returning_values new.LoadSig;
            new.SigHash = Hash(new.LoadSig);
          end
      end
    else
      if (new.Status is distinct from old.Status
        or new.IpMaskLen is distinct from old.IpMaskLen
        or new.StaticIP is distinct from old.StaticIP)
      then
        new.AlteredAt = UTCTime();

  end
  new.ChangedBy = CURRENT_USER;
  new.ChangedAt = UTCTime();
end^
/*-----------------------------------------------------------------------------------------------*/
create trigger P_TBD$TParams for P_TParams active before delete position 0
as
begin
  exception P_E$OneRecNeeded;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_LoadKeys
as
  declare PvtKey TSysStr2K;
  declare PubKey TSysStr2K;
begin
  execute procedure P_SysKey returning_values PvtKey,PubKey;
  update P_TParams set PubKey = :PubKey,PvtKey = :PvtKey;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_NewKeys(Wrap TUInt)
returns(
  PvtKey TKey,
  PubKey TKey)
as
  declare Pvt TSysStr2K;
  declare Pub TSysStr2K;
begin
  execute procedure P_SysKey returning_values Pvt,Pub;
  if (Wrap > 0)
  then
    begin
      execute procedure WrapText(Wrap,Pvt) returning_values PvtKey;
      execute procedure WrapText(Wrap,Pub) returning_values PubKey;
    end
  else
    begin
      PvtKey = Pvt;
      PubKey = Pub;
    end
  suspend;
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
create procedure P_DoInit
as
begin
  exit;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_InitNode
as
begin
  update P_TParams
    set
      Alias = uuid_to_Char(gen_uuid());
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_InitTransponder
as
begin
  update P_TTransponder
    set
      Prime = uuid_to_Char(gen_uuid()),
      Cluster = uuid_to_Char(gen_uuid());
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_GetNodeData
returns
  (Result TMemo)
as
begin
  Result = '[Main]' || ASCII_CHAR(10)
    || 'NodeId=' || (select NodeId from P_TParams) || ASCII_CHAR(10)
    || 'Alias=' || (select Alias from P_TParams) || ASCII_CHAR(10)
    || 'Acceptor=' || (select Acceptor from P_TParams) || ASCII_CHAR(10)
    || 'IP=' || (select Result from SYS_IP) || ASCII_CHAR(10)
    || 'Port=' || (select APort from P_TParams) || ASCII_CHAR(10)
    || 'Path=' || (select Result from SYS_DBName) || ASCII_CHAR(10)
    || 'Account=' || (select ExtAcc from P_TParams) || ASCII_CHAR(10)
    || 'Password=' || (select ExtPWD from P_TParams);
  suspend;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_GetCliData
returns
  (Result TMemo)
as
  declare Sig TSig;
  declare AKey TKey;
begin
  select LoadSig,PubKey from P_TParams into :Sig,:AKey;
  Result = '[Main]' || ASCII_CHAR(10)
    || 'NodeId=' || (select NodeId from P_TParams) || ASCII_CHAR(10)
    || 'Alias=' || (select Alias from P_TParams) || ASCII_CHAR(10)
    || 'IP=' || (select Result from SYS_IP) || ASCII_CHAR(10)
    || 'Port=' || (select APort from P_TParams) || ASCII_CHAR(10)
    || 'Path=' || (select Result from SYS_DBName) || ASCII_CHAR(10)
    || 'Account=P_Client' || ASCII_CHAR(10)
    || 'Password=PeopleRelay' || ASCII_CHAR(10)
    || '[LoadSig]' || ASCII_CHAR(10) || (select Result from WrapText(64,:Sig)) || ASCII_CHAR(10)
    || '[PubKey]' || ASCII_CHAR(10) || (select Result from WrapText(64,:AKey));
  suspend;
end^
/*-----------------------------------------------------------------------------------------------*/
set term ; ^
/*-----------------------------------------------------------------------------------------------*/
create view P_Params as select * from P_TParams;
/*-----------------------------------------------------------------------------------------------*/
grant select on P_TParams to procedure P_GetPvtKey;

grant execute on procedure P_SKeySz to procedure P_SysSig;
grant execute on procedure P_GetPvtKey to procedure P_SysSig;

grant execute on procedure P_IsAlt to trigger P_TBU$TParams;
grant execute on procedure P_SysSig to trigger P_TBU$TParams;
grant execute on procedure SYS_DBName to trigger P_TBU$TParams;
grant execute on procedure P_CalcHash to trigger P_TBU$TParams;
grant execute on procedure P_GetNodeHash to trigger P_TBU$TParams;
grant execute on procedure SYS_CheckExtAcc to trigger P_TBU$TParams;

grant all on P_TParams to procedure P_LoadKeys;
grant execute on procedure P_SysKey to procedure P_LoadKeys;

grant execute on procedure P_SysKey to procedure P_NewKeys;
grant execute on procedure WrapText to procedure P_NewKeys;

grant all on P_TParams to procedure P_DefAddr;
grant all on P_TParams to procedure P_DefSndId;

grant all on P_TParams to procedure P_DoInit;
grant all on P_TParams to procedure P_InitNode;
grant all on P_TTransponder to procedure P_InitTransponder;

grant select on P_TParams to procedure P_GetNodeData;
grant execute on procedure SYS_IP to procedure P_GetNodeData;
grant execute on procedure SYS_DBName to procedure P_GetNodeData;

grant select on P_TParams to procedure P_GetCliData;
grant execute on procedure SYS_IP to procedure P_GetCliData;
grant execute on procedure SYS_DBName to procedure P_GetCliData;
/*-----------------------------------------------------------------------------------------------*/

