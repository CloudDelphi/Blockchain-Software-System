/* ************************************************************************ */
/* PeopleRelay: node.sql Version: see version.sql                           */
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
create generator P_G$Node;
create generator P_G$ReplLog;
/*-----------------------------------------------------------------------------------------------*/
create table P_TNode(
  RecId             TRid,
  NodeId            TNodeId not null,
  Alias             TNdAlias,
  Status            TNdStatus,
  Enabled           TBoolean default 1,
  Acceptor          TBoolean,
  Proxy             TBoolean, /* Has Dimmed nodes */
  Dimmed            TBoolean, /* SubNet */

  Rating            TRating,

  ReplTime          TTimeMark default CURRENT_TIMESTAMP not null, /* Source Clock Stamp of last replication */
  TMOffset          TTimeGap default 0 not null, /* Source Clock offset = Self.CURRENT_TIMESTAMP - Source.CURRENT_TIMESTAMP */

  NdId              TRid default 0 not null, /* This Node Max RecId of Node List */
  MPId              TRid default 0 not null, /* This Node Max RecId of Melting Pot */

  IpMaskLen         TUInt, /* Ip Mask length CIDR Classless Inter-Domain Routing */

  IP                TIPV6str not null,
  APort             TPort default '3050',
  APath             TPath not null,
  ExtAcc            TUserName not null,
  ExtPWD            TPWD not null,
  FullPath          computed by (IP || iif(APort is null or APort = '','','/' || APort) || ':' || APath),
  ExpelTime         TTimeMark,
  ExpelCause        SmallInt,
  Comment           TComment,
  EditTime          TTimeMark, /* Time when id fields were edited */
  LoadSig           TSig,
  PubKey            TKey,
  CreatedBy         TOperName,
  ChangedBy         TOperName,
  CreatedAt         TTimeMark not null,
  ChangedAt         TTimeMark not null,
  primary key       (RecId));
/*-----------------------------------------------------------------------------------------------*/
create unique index P_XU$Node1 on P_TNode(NodeId);
create unique index P_XU$Node2 on P_TNode(NodeId,ExtAcc,ExtPWD);
create index P_X$Node1 on P_TNode(Acceptor);
create index P_X$Node2 on P_TNode(Enabled);
create index P_X$Node3 on P_TNode(Dimmed);
create index P_X$Node4 on P_TNode(NdId);
create index P_X$Node5 on P_TNode(MPId);
create descending index P_X$Node6 on P_TNode(Rating);
/*-----------------------------------------------------------------------------------------------*/
set term ^ ;
/*-----------------------------------------------------------------------------------------------*/
create trigger P_TBI$TNode for P_TNode active before insert position 0
as
  declare flag TBoolean;
begin
  if (new.RecId is null) then new.RecId = gen_id(P_G$Node,1);
  new.IP = Upper(new.IP);
  new.APort = Upper(new.APort);
  new.APath = Upper(new.APath);
  new.NodeId = Upper(new.NodeId);
  new.ExtAcc = Upper(new.ExtAcc);  

  new.CreatedBy = CURRENT_USER;
  new.CreatedAt = CURRENT_TIMESTAMP;
  new.ChangedBy = new.CreatedBy;
  new.ChangedAt = new.CreatedAt;
  execute procedure P_IsRepl returning_values flag;
  if (flag = 0) then new.EditTime = CURRENT_TIMESTAMP;
end^
/*-----------------------------------------------------------------------------------------------*/
create trigger P_TBU$TNode for P_TNode active before update position 0
as
  declare flag TBoolean;
begin
  new.IP = Upper(new.IP);
  new.APort = Upper(new.APort);
  new.APath = Upper(new.APath);
  new.NodeId = Upper(new.NodeId);
  new.ExtAcc = Upper(new.ExtAcc);
  
  new.RecId = old.RecId;
  new.CreatedBy = old.CreatedBy;
  new.CreatedAt = old.CreatedAt;
  new.ChangedBy = CURRENT_USER;
  new.ChangedAt = CURRENT_TIMESTAMP;

  if (new.Enabled is distinct from old.Enabled
    and new.Enabled = 0)
  then  
    new.ExpelTime = CURRENT_TIMESTAMP;

  execute procedure P_IsRepl returning_values flag;
  if (flag = 0
    and (new.NodeId is distinct from old.NodeId
      or new.Status is distinct from old.Status
      or new.LoadSig is distinct from old.LoadSig
      or (new.Enabled is distinct from old.Enabled
        and new.Enabled = 1)))
  then
    new.EditTime = CURRENT_TIMESTAMP;
end^
/*-----------------------------------------------------------------------------------------------*/
alter procedure P_GetNodeHash(
  NodeId TNodeId,
  Alias TNdAlias,
  Acceptor TBoolean,
  APort TPort,
  AUser TUserName,
  APWD TPWD)
returns
  (Result TChHash)
as
  declare AData TMemo;
begin
  if (Alias is null or Alias = '') then Alias = '0';
  AData = NodeId || '-' || Alias || '-' || Acceptor || '-' || APort || '-' || AUser || '-' || APWD;
  execute procedure P_CalcHash(AData) returning_values Result;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_NodeHash(RecId TRid)
returns
  (Result TChHash)
as
  declare NodeId TNodeId;
  declare Alias TNdAlias;
  declare Acceptor TBoolean;
  declare APort TPort;
  declare AUser TUserName;
  declare APWD TPWD;
begin
  select
      NodeId,
      Alias,
      Acceptor,
      APort,
      ExtAcc,
      ExtPWD
    from
      P_TNode
    where
      RecId = :RecId
    into
      :NodeId,
      :Alias,
      :Acceptor,
      :APort,
      :AUser,
      :APWD;
  if (NodeId is not null) then
    execute procedure P_GetNodeHash(NodeId,Alias,Acceptor,APort,AUser,APWD) returning_values Result;
end^
/*-----------------------------------------------------------------------------------------------*/
set term ; ^
/*-----------------------------------------------------------------------------------------------*/
create table P_TReplLog(
  RecId             TRid,
  NodeRId           TRid,
  ConnectId         TInt32,
  RepKind           TRepKind default 0 not null, /* 0 = Repl Nodes; 1 = Repl Chain Blocks */
  RecCnt            TCount,
  StartTM           TTimeMark,
  FinishTM          TTimeMark,
  ErrorId           SmallInt default 0 not null,
  ErrState          Char(5), /* sqlstate */
  ErrSource         TSysStr64,
  CreatedBy         TOperName,
  ChangedBy         TOperName,
  CreatedAt         TTimeMark not null,
  ChangedAt         TTimeMark not null,
  primary key       (RecId),
  foreign key       (NodeRId) references P_TNode(RecId)
    on update       CASCADE
    on delete       CASCADE);
/*-----------------------------------------------------------------------------------------------*/
create index P_X$ReplLog1 on P_TReplLog(ChangedAt);
/*-----------------------------------------------------------------------------------------------*/
set term ^ ;
/*-----------------------------------------------------------------------------------------------*/
create trigger P_TBI$TReplLog for P_TReplLog active before insert position 0
as
begin
  if (new.RecId is null) then new.RecId = gen_id(P_G$ReplLog,1);
  if (new.ErrState = '') then new.ErrState = null;

  new.CreatedBy = CURRENT_USER;
  new.CreatedAt = CURRENT_TIMESTAMP;
  new.ChangedBy = new.CreatedBy;
  new.ChangedAt = new.CreatedAt;
end^
/*-----------------------------------------------------------------------------------------------*/
create trigger P_TBU$TReplLog for P_TReplLog active before update position 0
as
begin
  new.RecId = old.RecId;
  new.CreatedBy = old.CreatedBy;
  new.CreatedAt = old.CreatedAt;
  new.ChangedBy = CURRENT_USER;
  new.ChangedAt = CURRENT_TIMESTAMP;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_ReplMsg(
  NodeRId TRid,
  RepKind TRepKind,
  RecCnt TCount,
  StartTM TTimeMark,
  ErrorId SmallInt,
  ErrSource TSysStr64)
as
begin
  if ((ErrorId = 0 and exists (select 1 from P_TParams where RplLogMode in (2,3)))
    or (ErrorId <> 0 and exists (select 1 from P_TParams where RplLogMode in (1,3))))
  then
    insert into P_TReplLog(NodeRId,ConnectId,RepKind, RecCnt, StartTM, FinishTM, ErrorId, ErrSource)
      values(:NodeRId,CURRENT_CONNECTION,:RepKind,:RecCnt,:StartTM,'Now',:ErrorId,:ErrSource);
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_ClearReplLog
as
  declare RecCnt TCount;
  declare LogSize TCount;
  declare NodeRId TRid;
begin
  select RepLogSize from P_TParams into :LogSize;

  for select
      RecId
    from
      P_TNode
    into
      :NodeRId
    do
      begin
        RecCnt = 0;
        select count(RecId) from P_TReplLog where NodeRId = :NodeRId into :RecCnt;
        if (RecCnt > LogSize) then
          delete from P_TReplLog
            where NodeRId = :NodeRId
            order by RecId
            rows (:RecCnt - :LogSize);
      end
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_ClearNodeList
as
  declare RecCnt TCount;
  declare DelayO TUInt;
  declare SizeO TCount;
  declare HoldO TNdLsHold;
  declare DelayA TUInt;
  declare SizeA TCount;
  declare HoldA TNdLsHold;
  declare DelTmLim Timestamp;
begin
  select NdLstSizeAcc,NdLstHoldAcc,NdDelDelayAcc,NdLstSizeOrd,NdLstHoldOrd,NdDelDelayOrd
    from P_TParams into :SizeA,:HoldA,:DelayO,:SizeO,:HoldO,:DelayA;

  delete from P_TNode where Status < 0;

  if (DelayO > 0) then
  begin
    DelTmLim = CURRENT_TIMESTAMP - DelayO;
    delete from P_TNode where Enabled = 0 and Acceptor = 0 and ExpelTime < :DelTmLim;
  end
  if (DelayA > 0) then
  begin
    DelTmLim = CURRENT_TIMESTAMP - DelayA;
    delete from P_TNode where Enabled = 0 and Acceptor = 1 and ExpelTime < :DelTmLim;
  end

  if (SizeO > 0 and HoldO = 2) then
  begin
    select count(*) from P_TNode where Acceptor = 0 into :RecCnt;
    if (RecCnt > SizeO) then
      delete from P_TNode
        where Acceptor = 0
        order by Enabled,Rating /* do not use desc here */
        rows (:RecCnt - :SizeO);
  end
  if (SizeA > 0 and HoldA = 2) then
  begin
    select count(*) from P_TNode where Acceptor = 1 into :RecCnt;
    if (RecCnt > SizeA) then
      delete from P_TNode
        where Acceptor = 1
        order by Enabled,Rating /* do not use desc here */
        rows (:RecCnt - :SizeA);
  end
end^
/*-----------------------------------------------------------------------------------------------*/
set term ; ^
/*-----------------------------------------------------------------------------------------------*/
create view P_Node as select * from P_TNode;
/*-----------------------------------------------------------------------------------------------*/
create view P_ReplLog as select * from P_TReplLog;
/*-----------------------------------------------------------------------------------------------*/
grant select on P_TNode to procedure P_NODEHASH;
grant execute on procedure P_GetNodeHash to procedure P_NODEHASH;

grant all on P_TReplLog to procedure P_ClearReplLog;
grant select on P_TNode to procedure P_ClearReplLog;
grant select on P_TParams to procedure P_ClearReplLog;
grant execute on procedure P_IsRepl to trigger P_TBI$TNode;
grant execute on procedure P_IsRepl to trigger P_TBU$TNode;

grant all on P_TReplLog to procedure P_ReplMsg;
grant select on P_TParams to procedure P_ReplMsg;

grant execute on procedure P_CalcHash to procedure P_GetNodeHash;

grant all on P_TNode to procedure P_ClearNodeList;
grant select on P_TParams to procedure P_ClearNodeList;
/*-----------------------------------------------------------------------------------------------*/

