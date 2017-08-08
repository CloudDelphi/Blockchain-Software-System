/* ************************************************************************ */
/* PeopleRelay: domains.sql Version: see version.sql                        */
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
create domain TRid as BigInt not null;
create domain TRef as BigInt;
/*-----------------------------------------------------------------------------------------------*/
create domain TChHash as Char(44) CHARACTER SET WIN1252; -- 44 for SHA256
create domain TCount as BigInt default 0 not null;
create domain TIntHash as BigInt;
create domain TSig as Char(172) CHARACTER SET WIN1252; -- 172 for KeyLength = 1024
/*-----------------------------------------------------------------------------------------------*/
create domain TPercent as Float default 0.000 check(value >= 0 and value <= 100) not null;
create domain TBoolean as SmallInt default 0 check(value in (0,1)) not null;
create domain TTrilean as SmallInt default -1 check(value in (-1, 0, 1)) not null;
create domain TUInt as Integer default 0 check(value>=0) not null;
create domain TUInt1 as Integer default 1 check(value>=1) not null;
create domain TState as SmallInt default 0 not null;
create domain TLogMode as SmallInt default 3 not null;
create domain TNdLsHold as SmallInt default 2 check(value in (0,1,2,3)) not null; /* 3 - reserved */

create domain TAccKind as SmallInt default 1 check(value in (0,1,2,3)) not null;
/* 0 - Client; 1 - Viewer; 2 - SyncBot; 3 - Admin; */

create domain TFine as SmallInt default 2 check(value in (0,1,2,3)) not null;
/* 0 - nothing; 1 - dec rate; 2 - expel node; 3 - dec rate & expel */
create domain TNdFilter as SmallInt default 3 check(value in (0,1,2,3)) not null;
/* 0 - not allow register any Node in Self Node List at all; 1 - Acceptors; 2 - Ordinal; 3 - all Nodes are welcome */

create domain TString64 as VarChar(64) COLLATE UNICODE_CI;
create domain TString128 as VarChar(128) COLLATE UNICODE_CI;
create domain TString512 as VarChar(512) COLLATE UNICODE_CI;

create domain TComment as VarChar(64) COLLATE UNICODE_CI;

create domain TInt32 as Integer default 0 not null;
create domain TTimeMark as TimeStamp;
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
*/
create domain TRating as DOUBLE PRECISION default 0.0 not null;
create domain TTimeGap as DOUBLE PRECISION; /* Time gap */
/*-----------------------------------------------------------------------------------------------*/
create domain TUserName as VarChar(31) CHARACTER SET WIN1252;
create domain TOperName as VarChar(31) CHARACTER SET WIN1252 default CURRENT_USER not null;

create domain TPWD as VarChar(32) CHARACTER SET WIN1252;
create domain TPath as VarChar(255) CHARACTER SET WIN1252;
create domain TFullPath as VarChar(255) CHARACTER SET WIN1252;

create domain TIPDelim as Char(1) CHARACTER SET WIN1252;

create domain TProto as VarChar(10) CHARACTER SET WIN1252;
create domain TIPV6str as VarChar(128) CHARACTER SET WIN1252; /* 128, can be canonical name */
create domain TPort as VarChar(7) CHARACTER SET WIN1252;
create domain TNodeId as Char(36) CHARACTER SET WIN1252;
create domain TBlockId as Char(36) CHARACTER SET WIN1252;
create domain TSenderId as VarChar(36) CHARACTER SET WIN1252;
create domain TAddress as VarChar(64) CHARACTER SET WIN1252;
create domain TErrState as VarChar(5) CHARACTER SET WIN1252;
create domain TPrime as Char(36) CHARACTER SET WIN1252;
create domain TClusterId as Char(36) CHARACTER SET WIN1252;

create domain TNdAlias as VarChar(32) CHARACTER SET WIN1252;
create domain TNdStatus as SmallInt default 0 not null;

create domain TRndPwd as VarChar(512) CHARACTER SET NONE;

create domain TFormula as VarChar(128) CHARACTER SET WIN1252;
create domain TExpression as VarChar(256) CHARACTER SET WIN1252;

create domain TSysStr1 as VarChar(1) CHARACTER SET WIN1252;
create domain TSysStr2 as VarChar(2) CHARACTER SET WIN1252;
create domain TSysStr12 as VarChar(12) CHARACTER SET WIN1252;
create domain TSysStr16 as VarChar(16) CHARACTER SET WIN1252;
create domain TSysStr31 as VarChar(31) CHARACTER SET WIN1252;
create domain TSysStr32 as VarChar(32) CHARACTER SET WIN1252;
create domain TSysStr64 as VarChar(64) CHARACTER SET WIN1252;
create domain TSysStr127 as VarChar(127) CHARACTER SET WIN1252;
create domain TSysStr128 as VarChar(128) CHARACTER SET WIN1252;
create domain TSysStr172 as VarChar(172) CHARACTER SET WIN1252;
create domain TSysStr255 as VarChar(255) CHARACTER SET WIN1252;
create domain TSysStr512 as VarChar(512) CHARACTER SET WIN1252;
create domain TSysStr1K as VarChar(1024) CHARACTER SET WIN1252;
create domain TSysStr4K as VarChar(4096) CHARACTER SET WIN1252;
create domain TSysStr10K as VarChar(10240) CHARACTER SET WIN1252;

create domain TKey as BLOB SUB_TYPE TEXT SEGMENT SIZE 80 CHARACTER SET WIN1252;
create domain TText as BLOB SUB_TYPE TEXT SEGMENT SIZE 80 CHARACTER SET WIN1252;
/*-----------------------------------------------------------------------------------------------*/
create exception P_E$ShortPWD 'Error: the password is too short. See P_TParams.MinPWDLen...';
create exception P_E$Recursion 'Recursive operation is not supported.';
create exception P_E$Forbidden 'Operation Forbidden.';
create exception P_E$TableHasData 'Cannot rebuild table containing data.';
create exception P_E$OneRecNeeded 'Table must has one record exactly.';
create exception P_E$MaxIdlConn 'Maximum count of idle connections exceeded.';
create exception P_E$MaxActConn 'Maximum count of active connections exceeded.';
create exception P_E$UnknownUser 'Given login is not registered in database.';
create exception P_E$ServiceNA 'Service unavailable try it later on.';
create exception P_E$ExtAcc 'Cannot set SU as external Account.';
create exception P_E$SyncBotAcc 'Sync Bot account already exists.';
create exception P_E$NewBlock 'NewBlock error.';
/*-----------------------------------------------------------------------------------------------*/

