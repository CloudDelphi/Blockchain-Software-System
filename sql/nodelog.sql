/* ======================================================================== */
/* PeopleRelay: nodelog.sql Version: 0.4.1.8                                */
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
create generator P_G$NodeLog;
/*-----------------------------------------------------------------------------------------------*/
/*
Node List Replicator buffer. 
*/
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
  ExtAcc            TUserName not null,
  ExtPWD            TPWD not null,
  EditTime          TTimeMark not null,
  RT                TCount,
  QrmAdmt           TBoolean, /* Quorum Amendment */
  LoadSig           TSig,
  PubKey            TKey,
  primary key       (RecId));
/*-----------------------------------------------------------------------------------------------*/
create index P_X$NBL1 on P_TNodeLog(NodeId);
create index P_X$NBL3 on P_TNodeLog(RT);
/*-----------------------------------------------------------------------------------------------*/
set term ^ ;
/*-----------------------------------------------------------------------------------------------*/
create trigger P_TBI$TNodeLog for P_TNodeLog active before insert position 0
as
  declare flag TBoolean;
begin
  new.ExtAcc = Upper(new.ExtAcc);
  new.RecId = gen_id(P_G$NodeLog,1);
  new.RT = Gen_Id(P_G$RTT,0);
end^
/*-----------------------------------------------------------------------------------------------*/
create trigger P_TBU$TNodeLog for P_TNodeLog active before update position 0
as
begin
  new.RecId = old.RecId;
  new.ExtAcc = Upper(new.ExtAcc);
end^
/*-----------------------------------------------------------------------------------------------*/
create trigger P_TAIU$TNode for P_TNode active after insert or update position 0
as
begin
  if ((select Result from P_IsNdSid) = 0) then
  begin
    execute procedure P_BegNdSid;
    update P_TNode set Sid = gen_id(P_G$NDSid,1) where RecId = new.RecId;
    /* Sid is continuous sequence; RecId sequence may contain gaps. */
    execute procedure P_EndNdSid;

    when any do
    begin
      execute procedure P_EndNdSid;
      Exception;
    end
  end
end^
/*-----------------------------------------------------------------------------------------------*/
set term ; ^
/*-----------------------------------------------------------------------------------------------*/
create view P_NodeLog as select * from P_TNodeLog;
/*-----------------------------------------------------------------------------------------------*/
grant all on P_TNode to trigger P_TAIU$TNode;

grant execute on procedure P_IsNdSid to trigger P_TAIU$TNode;
grant execute on procedure P_BegNdSid to trigger P_TAIU$TNode;
grant execute on procedure P_EndNdSid to trigger P_TAIU$TNode;
/*-----------------------------------------------------------------------------------------------*/

