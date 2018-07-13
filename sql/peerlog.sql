/* ======================================================================== */
/* PeopleRelay: peerlog.sql Version: 0.4.3.6                                */
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
/*
Node List Replicator buffer. 
*/
create table P_TPeerLog(
  ParId             TRid,
  NodeId            TNodeId not null,
  Alias             TNdAlias,
  Status            TNdStatus,
  Acceptor          TBoolean,
  IP                TIPV6str not null,
  APort             TPort default '3050',
  APath             TPath not null,
  ExtAcc            TUserName not null,
  ExtPWD            TPWD not null,
  EditTime          TTimeMark not null,
  NodeSig           TSig,
  PubKey            TKey,
  primary key       (ParId,NodeId),
  foreign key       (ParId) references P_TPeer(RecId)
    on update       CASCADE
    on delete       CASCADE);
/*-----------------------------------------------------------------------------------------------*/
set term ^ ;
/*-----------------------------------------------------------------------------------------------*/
create trigger P_TBI$TPeerLog for P_TPeerLog active before insert position 0
as
  declare flag TBoolean;
begin
  new.ExtAcc = Upper(new.ExtAcc);
end^
/*-----------------------------------------------------------------------------------------------*/
create trigger P_TBU$TPeerLog for P_TPeerLog active before update position 0
as
begin
  new.ExtAcc = Upper(new.ExtAcc);
end^
/*-----------------------------------------------------------------------------------------------*/
set term ; ^
/*-----------------------------------------------------------------------------------------------*/
create view P_PeerLog
as
  select
    count(*) as Voting,
    NodeId,
    Alias,
    Status,
    Acceptor,
    IP,
    APort,
    APath,
    ExtAcc,
    ExtPWD,
    EditTime,
    NodeSig,
    PubKey
  from
    P_TPeerLog
  where
    NodeId <> (select NodeId from P_TParams)
  group by
    NodeId,
    Alias,
    Status,
    Acceptor,
    IP,
    APort,
    APath,
    ExtAcc,
    ExtPWD,
    EditTime,
    NodeSig,
    PubKey;
/*-----------------------------------------------------------------------------------------------*/

/*-----------------------------------------------------------------------------------------------*/

