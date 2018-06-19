/* ======================================================================== */
/* PeopleRelay: params_log.sql Version: 0.4.1.8                             */
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
create generator P_G$PrmLog;
/*-----------------------------------------------------------------------------------------------*/
create table P_TPrmLog(
  RecId             TRid,
-----------------------------

  NodeId            TNodeId default '-' not null,
  Alias             TNdAlias default '-' not null,
  Status            TNdStatus,
  Online            TBoolean default 1,
  Acceptor          TBoolean,
  IpTimeout         TUInt default 5000,
  PingDelay         TTimeGap default 30.0 not null,
  PingCount         TUInt1,

  IpMaskLen         TUInt,
  StaticIP          TIPV6str,
  APort             TPort default '3050' not null,
  ExtAcc            TUserName default '-' not null,
  ExtPWD            TPWD default '-' not null,
  NDOverlap         TUInt,
  MPOverlap         TUInt,

  MPTokenBus        TBoolean,
  CHTokenBus        TBoolean,
  SndControl        TBoolean default 1,

  NDQuorumAcc       TBoolean,
  CHQuorumAcc       TBoolean,


  ChckHshCL         TBoolean default 1,
  ChckSigCL         TBoolean default 1,

  ChckHshCH         TBoolean default 1,
  ChckLcsCH         TBoolean default 1,
  ChckSigCH         TBoolean default 1,

  ChckHshMP         TBoolean default 1,
  ChckLcsMP         TBoolean default 1,
  ChckSigMP         TBoolean default 1,

  ChckIdNdAcc       TBoolean default 1,
  ChckIdNdOrd       TBoolean default 1,
  ChckLcsNdAcc      TBoolean default 1,
  ChckLcsNdOrd      TBoolean default 1,
  ChckSigNdAcc      TBoolean default 1,
  ChckSigNdOrd      TBoolean default 1,

  MetaCheckPut      TBoolean,
  MetaCheckGet      TBoolean default 1,
  TimeSlice         TInt32 default 10 not null,
  SyncSpan          TUInt1 default 5,

  RLLinger          TUInt1 default 7,

  MPQFactor         TUInt1 default 7,
  MPLinger          TUInt1 default 4096,

  DehornPower       TUInt1 default 16,
  WaitBackLog       TBoolean default 1,
  PowerOnReset      TUInt default 16,

  AutoRegister      TBoolean default 1,
  RegisterSpan      TUInt default 1024,

  MaxConnIdl        TUInt default 128,
  MaxConnAct        TUInt default 64,
  MaxAgeIdlCn       TTimeGap default 16 not null,
  MaxAgeActCn       TTimeGap default 30 not null,

  LogBlockChk       TBoolean,
  LogAttErr         TBoolean default 1,
  SndLogMode        TLogMode,
  MsgLogMode        TLogMode,
  RplLogMode        TLogMode,
  ExpelBadLcs       TBoolean,
  ExpelBadMeta      TBoolean default 1,
  ExpelBadHash      TBoolean default 1,
  ExpelBadSign      TBoolean default 1,
  Broadband         TBoolean,

  Handshake         THandshake,
  NdPubFilter       TNdFilter,
  NdRegFilter       TNdFilter,
  NodeListSync      TNdFilter,
  NdLstSizeAcc      TCount default 4096,
  NdLstHoldAcc      TNdLsHold,
  NdLstSizeOrd      TCount default 8192,
  NdLstHoldOrd      TNdLsHold,
  NdDelDelayAcc     TUInt default 7,
  NdDelDelayOrd     TUInt default 3,

  RateRetro         TTimeGap default 4320 not null,

  ChkLogSize        TCount default 16384,
  AttLogSize        TCount default 16384,
  SysLogSize        TCount default 16384,
  CtrLogSize        TCount default 64,
  NdDataSize        TCount default 64,
  RepLogSize        TCount default 1024,

  SweepSpan         TUInt default 10000,
  LacunaSpan        TUInt default 16,
  RepairSpan        TUInt default 16,

  DefAddress        TAddress,
  DefSenderId       TSenderId,
  SigHash           TIntHash,
  LoadSig           TSig,
  PubKey            TKey,
  PvtKey            TKey,
  AlteredAt         TTimeMark,
  ChangedBy         TOperName,
  ChangedAt         TTimeMark,

-----------------------------
  SnappedBy         TOperName,
  SnappedAt         TTimeMark);
/*-----------------------------------------------------------------------------------------------*/
set term ^ ;
/*-----------------------------------------------------------------------------------------------*/
create trigger P_TBI$TPrmLog for P_TPrmLog active before insert position 0
as
begin
  new.RecId = gen_id(P_G$PrmLog,1);
  new.SnappedBy = CURRENT_USER;
  new.SnappedAt = UTCTime();
end^
/*-----------------------------------------------------------------------------------------------*/
create trigger P_TBU$TPrmLog for P_TPrmLog active before update position 0
as
begin
  exception P_E$Forbidden;
end^
/*-----------------------------------------------------------------------------------------------*/
set term ; ^
/*-----------------------------------------------------------------------------------------------*/
create view P_PrmLog as select * from P_TPrmLog;
/*-----------------------------------------------------------------------------------------------*/

