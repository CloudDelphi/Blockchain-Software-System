/* ************************************************************************ */
/* PeopleRelay: nodelog.sql Version: see version.sql                        */
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
create generator P_G$NodeLog;
/*-----------------------------------------------------------------------------------------------*/
create table P_TNodeLog(
  RecId             TRid,
  NodeId            TNodeId not null,
  Alias             TNdAlias,
  Status            TNdStatus,
  Acceptor          TBoolean,
  Dimmed            TBoolean,
  IpMaskLen         TUInt,
  IP                TIPV6str not null,
  APort             TPort default '3050',
  APath             TPath not null,
  AUser             TUserName not null,
  APWD              TPWD not null,
  EditTime          TTimeMark not null,
  State             TState,
  RT                TCount,
  LoadSig           TSig,
  PubKey            TKey,
  primary key       (RecId));
/*-----------------------------------------------------------------------------------------------*/
create index P_X$NBL1 on P_TNodeLog(NodeId);
create index P_X$NBL2 on P_TNodeLog(State);
create index P_X$NBL3 on P_TNodeLog(RT);
/*-----------------------------------------------------------------------------------------------*/
set term ^ ;
/*-----------------------------------------------------------------------------------------------*/
create trigger P_TBI$TNodeLog for P_TNodeLog active before insert position 0
as
  declare flag TBoolean;
begin
  new.IP = Upper(new.IP);
  new.APort = Upper(new.APort);
  new.APath = Upper(new.APath);
  new.AUser = Upper(new.AUser);
  new.RecId = gen_id(P_G$NodeLog,1);
  new.RT = Gen_Id(P_G$RTT,0);
end^
/*-----------------------------------------------------------------------------------------------*/
create trigger P_TBU$TNodeLog for P_TNodeLog active before update position 0
as
begin
  new.RecId = old.RecId;
  new.IP = Upper(new.IP);
  new.APort = Upper(new.APort);
  new.APath = Upper(new.APath);
  new.AUser = Upper(new.AUser);
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_ClearNodeBL
as
begin
  delete from P_TNodeLog where State > 0;
  when any do
    execute procedure P_LogErr(-32,sqlcode,gdscode,sqlstate,'P_ClearNodeBL',null,'Error',null);
end^
/*-----------------------------------------------------------------------------------------------*/
set term ; ^
/*-----------------------------------------------------------------------------------------------*/
grant all on P_TNodeLog to procedure P_ClearNodeBL;
grant execute on procedure P_LogErr to procedure P_ClearNodeBL;
/*-----------------------------------------------------------------------------------------------*/

