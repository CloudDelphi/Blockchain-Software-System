/* ======================================================================== */
/* PeopleRelay: declare.sql Version: 0.4.1.8                                */
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
set term ^ ;
/*-----------------------------------------------------------------------------------------------*/
create procedure P_GetNodeHash(
  NodeId TNodeId,
  Alias TNdAlias,
  Acceptor TBoolean,
  APort TPort,
  APath TPath,
  ExtAcc TUserName,
  ExtPWD TPWD)
returns
  (Result TChHash)
as
  declare AData TMemo;
begin
  exit;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_Register
as
begin
  exit;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_NewSndAcc(AUser TSysStr31)
as
begin
  exit;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_OnGetBlock(SenderId TSenderId,BlockId TBlockId)
as
begin
  exit;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_ClearRegAim
as
begin
  exit;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_ResetRegAim(Acceptor TBoolean)
as
  declare VoteLim TCount;
begin
  exit;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure PG_Chain(NodeRId TRef,A_DB TFullPath,A_USR TUserName,A_PWD TPWD)
returns(Rec_Cnt TCount)
as
begin
  exit;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_FixChain(A_Acc TBoolean)
returns (Rec_Cnt TCount)
as
begin
  exit;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure PG_MeltingPot(NodeRId TRef,A_DB TFullPath,A_USR TUserName,A_PWD TPWD)
returns(Rec_Cnt TCount)
as
begin
  exit;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_RevertBlock(BlockNo TRid,SndId TSenderId,BId TBlockId)
as
begin
  exit;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_Commit
as
begin
  exit;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_ClearMeltingPot
as
begin
  exit;
end^  
/*-----------------------------------------------------------------------------------------------*/
set term ; ^
/*-----------------------------------------------------------------------------------------------*/
