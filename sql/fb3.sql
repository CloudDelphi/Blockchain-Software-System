/* ************************************************************************ */
/* PeopleRelay: fb3.sql Version: see version.sql                            */
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

--Not in use.

/*-----------------------------------------------------------------------------------------------*/
grant execute on function sha_blob to procedure P_CalcHash;
grant execute on function rsasig to procedure P_CalcSig;
grant execute on function sigver to procedure P_IsSigValid;
grant execute on function rsakey to procedure P_RsaKey;
grant execute on function StrToUTF_256 to procedure P_StrToUTF;
grant execute on function StrToAnsi_256 to procedure P_StrToAnsi;
grant execute on function CanConnect to procedure P_IsOnline;
grant execute on function GetMutex to procedure P_BeginSync;
grant execute on function FreeMutex to procedure P_FinishSync;

/* To use, Move it to iside P_DoGrants procedure body */
--execute statement 'grant execute on function StrToUTF to procedure P_NewBlock';
--execute statement 'grant execute on function BlobToUTF to procedure P_NewBlock';
--execute statement 'grant execute on function rsaEncrypt to procedure P_NewBlock';
--execute statement 'grant execute on function rsaEncBlob to procedure P_NewBlock';
/*-----------------------------------------------------------------------------------------------*/
grant usage on exception P_E$ShortPWD to PUBLIC;
grant usage on exception P_E$Recursion to PUBLIC;
grant usage on exception P_E$Forbidden to PUBLIC;
grant usage on exception P_E$TableHasData to PUBLIC;
grant usage on exception P_E$OneRecNeeded to PUBLIC;
grant usage on exception P_E$MaxIdlConn to PUBLIC;
grant usage on exception P_E$MaxActConn to PUBLIC;
grant usage on exception P_E$UnknownUser to PUBLIC;
grant usage on exception P_E$ServiceNA to PUBLIC;
grant usage on exception P_E$ExtAcc to PUBLIC;

grant usage on exception PE$KeyWord to trigger P_TBI$TFields;
grant usage on exception PE$KeyWord to trigger P_TBU$TFields;
grant usage on exception P_E$SyncBotAcc to trigger P_TBI$TACL;
grant usage on exception P_E$NewBlock to procedure P_NewBlock;
/*-----------------------------------------------------------------------------------------------*/
grant usage on sequence P_G$MP to trigger P_TBI$TMeltingPot;
grant usage on sequence P_G$Checks to trigger P_TBI$TChecks;
grant usage on sequence P_G$ChkLog to trigger P_TBI$TChkLog;
grant usage on sequence P_G$DBLog to trigger P_TBI$TDBLog;
grant usage on sequence P_G$Quorum to trigger P_TBI$TQuorum;
grant usage on sequence P_G$IpBan to trigger P_TBI$TIpBan;
grant usage on sequence P_G$MPV to trigger P_TBI$TMPVoter;
grant usage on sequence P_G$NDV to trigger P_TBI$TNDVoter;
grant usage on sequence P_G$Node to trigger P_TBI$TNode;
grant usage on sequence P_G$ReplLog to trigger P_TBI$TReplLog;
grant usage on sequence P_G$NodeLog to trigger P_TBI$TNodeLog;
grant usage on sequence P_G$DBLog to trigger P_T$Connect;
grant usage on sequence P_G$SMV to trigger P_TBI$TSMVoter;
grant usage on sequence P_G$ACL to trigger P_TBI$TACL;
grant usage on sequence P_G$ACLIp to trigger P_TBI$TACLIp;
grant usage on sequence P_G$Log to trigger P_TBI$TLog;

grant usage on sequence P_G$DTM to procedure P_IsNewDay;

grant usage on sequence P_G$STM to procedure P_SyncPOR;
grant usage on sequence P_G$STM to procedure P_RoundTrip;
grant usage on sequence P_G$STM to procedure P_IsSyncSpan;

grant usage on sequence P_G$SDU to procedure P_CheckPOR;
grant usage on sequence P_G$SDU to procedure P_RoundTrip;

grant usage on sequence P_G$RTT to procedure P_RoundTrip;
grant usage on sequence P_G$RTT to procedure P_CheckLimbo;
grant usage on sequence P_G$RTT to trigger P_TBI$TBacklog;
grant usage on sequence P_G$RTT to trigger P_TBI$TNodeLog;
grant usage on sequence P_G$RTT to trigger P_TBI$TMeltingPot;
/*-----------------------------------------------------------------------------------------------*/
/*
Firebird 3.0
To work with legacy clients:

1. Edit "firebird.conf"
WireCrypt = Disabled
AuthServer = Legacy_Auth, Srp, Win_Sspi
AuthClient = Legacy_Auth, Srp, Win_Sspi

SecurityDatabase = $(root)/security3.fdb
SecurityDatabase = $(root)/security2.fdb

2. Get "fbclient.dll" from 32 bit fb3.0 version and rename it to "gds32.dll"
*/ 
