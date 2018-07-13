/* ======================================================================== */
/* PeopleRelay: peerlist.sql Version: 0.4.3.6                               */
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
create procedure P_PeerList(RepKind TRepKind,Acceptor TBoolean)
returns
 (RecId             TRef,
  Accept            TBoolean,
  NodeId            TNodeId,
  SigHash           TIntHash,
  IP                TIPV6str,
  APort             TPort,
  ExtAcc            TUserName,
  ExtPWD            TPWD,
  FullPath          TFullPath)
as
  declare BB TBoolean;
  declare SelfId TNodeId;
begin
  select NodeId,Broadband from P_TParams into :SelfId,:BB;
  if ((RepKind <> 2 and BB = 1)
    or (RepKind = 3 and not exists (select 1 from P_TPeer where Acceptor = 1)))
  then
    Acceptor = 0;

    for select
         RecId,
         Acceptor,
         NodeId,
         SigHash,
         Ip,
         APort,
         ExtAcc,
         ExtPWD,
         FullPath
       from
         P_TPeer
       where NodeId <> :SelfId
         and Enabled = 1
         and Dimmed = 0
         and Status >= 0
         and (:Acceptor = 0 or Acceptor = 1)
       order by
         rand()
       into
         :RecId,
         :Accept,
         :NodeId,
         :SigHash,
         :IP,
         :APort,
         :ExtAcc,
         :ExtPWD,
         :FullPath
    do
      suspend;
end^
/*-----------------------------------------------------------------------------------------------*/
set term ; ^
/*-----------------------------------------------------------------------------------------------*/
grant select on P_TPeer to procedure P_PeerList;
grant select on P_TParams to procedure P_PeerList;
/*-----------------------------------------------------------------------------------------------*/
