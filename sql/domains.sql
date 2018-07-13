/* ======================================================================== */
/* PeopleRelay: domains.sql Version: 0.4.3.6                                */
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
/* ATTENTION!!! See create_fb.sql for LOCALIZATION */
/*-----------------------------------------------------------------------------------------------*/
create domain TRid as BigInt not null;
create domain TRef as BigInt;
/*-----------------------------------------------------------------------------------------------*/
create domain TIntHash as BigInt;
create domain TNonce as BigInt default 0 not null;
create domain TCount as BigInt default 0 not null;

create domain TSha1 as Char(28) CHARACTER SET WIN1252 COLLATE PXW_INTL;

create domain TChHash as Char(44) CHARACTER SET WIN1252 COLLATE PXW_INTL; -- 44 for SHA256
create domain TNodeId as Char(44) CHARACTER SET WIN1252 COLLATE PXW_INTL; -- 44 for SHA256
create domain TSig as VarChar(172) CHARACTER SET WIN1252 COLLATE PXW_INTL; -- 172 for KeyLength = 1024; 344 for KeyLength = 2048

create domain TSenderId as VarChar(44) CHARACTER SET WIN1252 COLLATE PXW_INTL;
/*-----------------------------------------------------------------------------------------------*/
create domain TBoolean as SmallInt default 0 check(value in (0,1)) not null;
create domain TTrilean as SmallInt default -1 check(value in (-1, 0, 1)) not null;
create domain TUInt as Integer default 0 check(value>=0) not null;
create domain TUInt1 as Integer default 1 check(value>=1) not null;
create domain TState as SmallInt default 0 not null;
create domain TLogMode as SmallInt default 3 not null;
create domain TNdLsHold as SmallInt default 2 check(value in (0,1,2,3)) not null; /* 3 - reserved */

create domain TCheck as SmallInt default -1 check(value in (-1, 0, 1, 2)) not null;
/*
-1=Any Error
0=Block not found
1=Block Found
2=Chain is Empty
*/

create domain THandshake as SmallInt default 0 check(value >= 0) not null;

create domain TAccKind as SmallInt default 1 check(value in (0,1,2,3,4)) not null;
/* 0 - Client; 1 - Viewer; 2 - SyncBot; 3 - Admin; 4 - Guest (Replicator) */

create domain TNdFilter as SmallInt default 3 check(value in (0,1,2,3)) not null;
/* 0 - not allow register any Node in Self Node List at all; 1 - Acceptors; 2 - Ordinal; 3 - all Nodes are welcome */

create domain TInt32 as Integer default 0 not null;
create domain TTimeMark as TimeStamp;
create domain TAttErr as SmallInt default 0 check(value >= 0) not null;
/* 1=Ip banned 2=OffLine 3=Acc or Ip is not registered */
/*-----------------------------------------------------------------------------------------------*/
create domain TBlob as BLOB SUB_TYPE 0 SEGMENT SIZE 80;
create domain TMemo as BLOB SUB_TYPE TEXT SEGMENT SIZE 80;
create domain TRepKind as SmallInt default 0 not null;
/*
0=Node List replication (pull)
1=Chain replication (pull)
2=Meltig Pot replication (pull)
3=Node registration (push)
4=Block Check (pull)
5=FindBlock (pull)
6=Get Discrepancy (pull)
*/
create domain TRating as DOUBLE PRECISION default 0.0 not null;
create domain TTimeGap as DOUBLE PRECISION; /* Time gap */
/*-----------------------------------------------------------------------------------------------*/
create domain TUserName as VarChar(31) CHARACTER SET WIN1252 COLLATE PXW_INTL;
create domain TOperName as VarChar(31) CHARACTER SET WIN1252 default CURRENT_USER not null COLLATE PXW_INTL;

create domain TPWD as VarChar(32) CHARACTER SET WIN1252 COLLATE PXW_INTL;
create domain TPath as VarChar(255) CHARACTER SET WIN1252 COLLATE PXW_INTL;
create domain TFullPath as VarChar(255) CHARACTER SET WIN1252 COLLATE PXW_INTL;

create domain TIPDelim as Char(1) CHARACTER SET WIN1252 COLLATE PXW_INTL;

create domain TProto as VarChar(10) CHARACTER SET WIN1252 COLLATE PXW_INTL;
create domain TIPV6str as VarChar(128) CHARACTER SET WIN1252 COLLATE PXW_INTL; /* 128, can be canonical name */
create domain TPort as VarChar(16) CHARACTER SET WIN1252 COLLATE PXW_INTL;

create domain TNdAlias as VarChar(36) CHARACTER SET WIN1252 COLLATE PXW_INTL;
create domain TBlockId as VarChar(36) CHARACTER SET WIN1252 COLLATE PXW_INTL;
create domain TAddress as VarChar(64) CHARACTER SET WIN1252 COLLATE PXW_INTL;
create domain TErrState as VarChar(5) CHARACTER SET WIN1252 COLLATE PXW_INTL;
create domain TPrime as Char(36) CHARACTER SET WIN1252 COLLATE PXW_INTL;
create domain TClusterId as Char(36) CHARACTER SET WIN1252 COLLATE PXW_INTL;
create domain TNdStatus as SmallInt default 0 not null;

create domain TRndPwd as VarChar(64) CHARACTER SET NONE;

create domain TFormula as VarChar(128) CHARACTER SET WIN1252 COLLATE PXW_INTL;
create domain TExpression as VarChar(256) CHARACTER SET WIN1252 COLLATE PXW_INTL;

create domain THour as SmallInt default 0 check(value>=0 and value < 24);
create domain TYear as SmallInt default 0 not null;
create domain TWeekNo as SmallInt default 1 check(value >= 0 and value <= 53) not null;
create domain TMonthNo as SmallInt default 1 check(value >= 1 and value <= 12) not null;
create domain THalfYear as SmallInt default 1 check(value in (1,2)) not null;
create domain TQuartNo as SmallInt default 1 check(value in (1,2,3,4)) not null;

create domain TSysStr1 as VarChar(1) CHARACTER SET WIN1252 COLLATE PXW_INTL;
create domain TSysStr2 as VarChar(2) CHARACTER SET WIN1252 COLLATE PXW_INTL;
create domain TSysStr12 as VarChar(12) CHARACTER SET WIN1252 COLLATE PXW_INTL;
create domain TSysStr16 as VarChar(16) CHARACTER SET WIN1252 COLLATE PXW_INTL;
create domain TSysStr31 as VarChar(31) CHARACTER SET WIN1252 COLLATE PXW_INTL;
create domain TSysStr32 as VarChar(32) CHARACTER SET WIN1252 COLLATE PXW_INTL;
create domain TSysStr36 as VarChar(36) CHARACTER SET WIN1252 COLLATE PXW_INTL;
create domain TSysStr64 as VarChar(64) CHARACTER SET WIN1252 COLLATE PXW_INTL;
create domain TSysStr127 as VarChar(127) CHARACTER SET WIN1252 COLLATE PXW_INTL;
create domain TSysStr128 as VarChar(128) CHARACTER SET WIN1252 COLLATE PXW_INTL;
create domain TSysStr172 as VarChar(172) CHARACTER SET WIN1252 COLLATE PXW_INTL;
create domain TSysStr255 as VarChar(255) CHARACTER SET WIN1252 COLLATE PXW_INTL;
create domain TSysStr512 as VarChar(512) CHARACTER SET WIN1252 COLLATE PXW_INTL;
create domain TSysStr1K as VarChar(1024) CHARACTER SET WIN1252 COLLATE PXW_INTL;
create domain TSysStr2K as VarChar(2048) CHARACTER SET WIN1252 COLLATE PXW_INTL;
create domain TSysStr4K as VarChar(4096) CHARACTER SET WIN1252 COLLATE PXW_INTL;
create domain TSysStr10K as VarChar(10240) CHARACTER SET WIN1252 COLLATE PXW_INTL;

create domain TKey as BLOB SUB_TYPE TEXT SEGMENT SIZE 80; -- CHARACTER SET WIN1252;
create domain TText as BLOB SUB_TYPE TEXT SEGMENT SIZE 80; --CHARACTER SET WIN1252;
/*-----------------------------------------------------------------------------------------------*/

