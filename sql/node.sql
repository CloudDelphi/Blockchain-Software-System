/* ======================================================================== */
/* PeopleRelay: node.sql Version: 0.4.1.8                                   */
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
create generator P_G$Node;
create generator P_G$NDSid;

create generator P_G$MPLid;
create generator P_G$NDLid;
create generator P_G$ReplLog;
/*-----------------------------------------------------------------------------------------------*/
create table P_TNode(
  RecId             TRid,
  Sid               TRid unique, /* Serial Id */
  NodeId            TNodeId not null,
  Alias             TNdAlias not null,
  Status            TNdStatus,
  Enabled           TBoolean default 1,
  Acceptor          TBoolean,
  Proxy             TBoolean, /* Has Dimmed nodes */
  Dimmed            TBoolean, /* SubNet */
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
  LocalSig          TSig,

  PubKey            TKey,
  CreatedBy         TOperName,
  ChangedBy         TOperName,
  CreatedAt         TTimeMark not null,
  ChangedAt         TTimeMark not null,
  primary key       (RecId));
/*-----------------------------------------------------------------------------------------------*/
create unique index P_XU$Node1 on P_TNode(NodeId);
create unique descending index P_XU$Node2 on P_TNode(NodeId);

create index P_X$Node1 on P_TNode(Acceptor);
create index P_X$Node2 on P_TNode(Enabled);
create index P_X$Node3 on P_TNode(Dimmed);
create index P_X$Node4 on P_TNode(NodeId,LoadSig,Status,IP); /* P_HasNode */
/*-----------------------------------------------------------------------------------------------*/
set term ^ ;
/*-----------------------------------------------------------------------------------------------*/
alter procedure P_GetNodeHash(
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
  if (Alias is null or Alias = '') then Alias = '0';
  AData = NodeId || '-'
    || Alias     || '-'
    || Acceptor  || '-'
    || APort     || '-'
    || APath     || '-'
    || ExtAcc    || '-'
    || ExtPWD;
  execute procedure P_CalcHash(AData) returning_values Result;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_CheckNode(
  Caller SmallInt,
  NodeId TNodeId,
  Alias TNdAlias,
  Acceptor TBoolean,
  APort TPort,
  APath TPath,
  ExtAcc TUserName,
  ExtPWD TPWD,
  LoadSig TSig,
  LocalSig TSig,
  PubKey TKey,
  PeerKey TKey)
returns
  (Result TBoolean)
as
  declare ATest TBoolean;

  declare ChckIdA TBoolean;
  declare ChckIdO TBoolean;
  declare ChckLcA TBoolean;
  declare ChckLcO TBoolean;
  declare ChckAcc TBoolean;
  declare ChckOrd TBoolean;
  declare s TSysStr32;
  declare nm TSysStr32;
  declare NdId TNodeId;
  declare AHash TChHash;
begin
  s = 'P_CheckNode';
  if (Caller = 1)
  then
    nm = 'P_RegNode';
  else
    if (Caller = 2)
    then
      nm = 'PG_Node';
    else
      nm = 'User Check';      

  if (NodeId is null or NodeId = ''
    or Alias is null or Alias = ''
    or APort is null or APort = ''
    or APath is null or APath = ''
    or ExtAcc is null or ExtAcc = ''
    or ExtPWD is null or ExtPWD = ''
    or LoadSig is null or LoadSig = ''
    or PubKey is null or PubKey = ''
    or (Caller > 1 and (PeerKey is null or PeerKey = ''))
    or (Caller > 1 and (LocalSig is null or LocalSig = '')))
  then
    execute procedure P_LogErr(-140,0,0,0,s,NodeId,'Data has NULLS',nm);
  else
    begin
      Result = 1;
      select
          ChckIdNdAcc,
          ChckIdNdOrd,
          ChckLcsNdAcc,
          ChckLcsNdOrd,
          ChckSigNdAcc,
          ChckSigNdOrd
        from
          P_TParams
        into
          :ChckIdA,
          :ChckIdO,
          :ChckLcA,
          :ChckLcO,
          :ChckAcc,
          :ChckOrd;

      if ((Acceptor = 1 and ChckIdA = 1) or (Acceptor = 0 and ChckIdO = 1)) then
      begin
        execute procedure P_CalcHash(PubKey) returning_values NdId;
        if (NodeId <> NdId) then
        begin
          Result = 0;
          execute procedure P_LogErr(-141,0,0,0,s,NodeId,'Bad NodeId',nm);
        end
      end

      if (Result = 1
        and Caller > 1
        and ((Acceptor = 1 and ChckLcA = 1) or (Acceptor = 0 and ChckLcO = 1))) then
      begin
        execute procedure P_IsSysSig(NodeId,LocalSig,PeerKey) returning_values ATest;
        if (ATest = 0) then
        begin
          Result = 0;
          execute procedure P_LogErr(-142,0,0,0,s,NodeId,'Bad LocalSig',nm);
        end
      end

      if (Result = 1
        and ((Acceptor = 1 and ChckAcc = 1) or (Acceptor = 0 and ChckOrd = 1))) then
      begin
        execute procedure P_GetNodeHash(
          NodeId,
          Alias,
          Acceptor,
          APort,
          APath,
          ExtAcc,
          ExtPWD) returning_values AHash;
        execute procedure P_IsSysSig(AHash,LoadSig,PubKey) returning_values ATest;
        if (ATest = 0) then
        begin
          Result = 0;
          execute procedure P_LogErr(-143,0,0,0,s,NodeId,'Bad LoadSig',nm);
        end
      end

      when any do
      begin
        Result = 0;
        execute procedure P_LogErr(-144,sqlcode,gdscode,sqlstate,s,NodeId,'Error',nm);
      end

    end
  suspend;
end^
/*-----------------------------------------------------------------------------------------------*/
create trigger P_TBI$TNode for P_TNode active before insert position 0
as
begin
  new.RecId = gen_id(P_G$Node,1);
  new.Sid = -new.RecId; /* Minus sign is here to prevent coinsedence of P_G$Node and P_G$NDSid */
  /* Cannot put Gen_Id(P_G$NDSid,1) here because of on exception, P_G$NDSid sequenced value will be lost */  

  new.ExtAcc = Upper(new.ExtAcc);

  new.CreatedAt = UTCTime();
  new.CreatedBy = CURRENT_USER;
  new.ChangedBy = new.CreatedBy;
  new.ChangedAt = new.CreatedAt;
  if ((select Result from P_IsRepl) = 0) then new.EditTime = UTCTime();

  if (new.NodeId is not null) then
    execute procedure P_SysSig(new.NodeId,null) returning_values new.LocalSig;
end^
/*-----------------------------------------------------------------------------------------------*/
create trigger P_TBU$TNode for P_TNode active before update position 0
as
begin
  if ((select Result from P_IsNdSid) = 0) then
  begin
    new.ExtAcc = Upper(new.ExtAcc);

    new.RecId = old.RecId;
    new.CreatedBy = old.CreatedBy;
    new.CreatedAt = old.CreatedAt;
    new.ChangedBy = CURRENT_USER;
    new.ChangedAt = UTCTime();

    if (new.Enabled is distinct from old.Enabled
      and new.Enabled = 0)
    then
      new.ExpelTime = UTCTime();
  end

  if (new.NodeId is distinct from old.NodeId) then
    if (new.NodeId is null)
    then
      new.LocalSig = null;
    else
      execute procedure P_SysSig(new.NodeId,null) returning_values new.LocalSig;
end^
/*-----------------------------------------------------------------------------------------------*/
set term ; ^
/*-----------------------------------------------------------------------------------------------*/
create table P_TReplLog(
  RecId             TRid,
  NodeRId           TRid,
  TransId           TInt32,
  RepKind           TRepKind default 0 not null, /* 0 = Repl Nodes; 1 = Repl Chain Blocks */
  RecCnt            TCount,
  StartTM           TTimeMark,
  FinishTM          TTimeMark,
  ErrorId           SmallInt default 0 not null,
  ErrState          Char(5), /* sqlstate */
  ErrSource         TSysStr64,
  CreatedBy         TOperName,
  CreatedAt         TTimeMark not null,
  primary key       (RecId),
  foreign key       (NodeRId) references P_TNode(RecId)
    on update       CASCADE
    on delete       CASCADE);
/*-----------------------------------------------------------------------------------------------*/
set term ^ ;
/*-----------------------------------------------------------------------------------------------*/
create trigger P_TBI$TReplLog for P_TReplLog active before insert position 0
as
begin
  if (new.RecId is null) then new.RecId = gen_id(P_G$ReplLog,1);
  if (new.ErrState = '') then new.ErrState = null;

  new.CreatedBy = CURRENT_USER;
  new.CreatedAt = UTCTime();
end^
/*-----------------------------------------------------------------------------------------------*/
create trigger P_TBU$TReplLog for P_TReplLog active before update position 0
as
begin
  exception P_E$Forbidden;
end^
/*-----------------------------------------------------------------------------------------------*/
set term ; ^
/*-----------------------------------------------------------------------------------------------*/
/*
Melting Pot Id Log
*/
create table P_TMPidLog(
  RecId             TRid,
  ParId             TRid,
  MPId              TRid,
  CreatedBy         TOperName,
  CreatedAt         TTimeMark not null,
  primary key       (RecId),
  foreign key       (ParId) references P_TNode(RecId)
    on update       CASCADE
    on delete       CASCADE);
/*-----------------------------------------------------------------------------------------------*/
create unique descending index P_XU$MPL1 on P_TMPidLog(RecId);
/*-----------------------------------------------------------------------------------------------*/
set term ^ ;
/*-----------------------------------------------------------------------------------------------*/
create trigger P_TBI$TMPidLog for P_TMPidLog active before insert position 0
as
begin
  new.CreatedAt = UTCTime();
  new.CreatedBy = CURRENT_USER;
  new.RecId = gen_id(P_G$MPLid,1);
end^
/*-----------------------------------------------------------------------------------------------*/
set term ; ^
/*-----------------------------------------------------------------------------------------------*/
create view MPidLog as select * from P_TMPidLog;
/*-----------------------------------------------------------------------------------------------*/
/*
Node Id Log
*/
create table P_TNDidLog(
  RecId             TRid,
  ParId             TRid,
  Sid               TRid,
  CreatedBy         TOperName,
  CreatedAt         TTimeMark not null,
  primary key       (RecId),
  foreign key       (ParId) references P_TNode(RecId)
    on update       CASCADE
    on delete       CASCADE);
/*-----------------------------------------------------------------------------------------------*/
create unique descending index P_XU$NDL1 on P_TNDidLog(RecId);
/*-----------------------------------------------------------------------------------------------*/
set term ^ ;
/*-----------------------------------------------------------------------------------------------*/
create trigger P_TBI$TNDidLog for P_TNDidLog active before insert position 0
as
begin
  new.CreatedAt = UTCTime();
  new.CreatedBy = CURRENT_USER;
  new.RecId = gen_id(P_G$NDLid,1);
end^
/*-----------------------------------------------------------------------------------------------*/
set term ; ^
/*-----------------------------------------------------------------------------------------------*/
create view NDidLog as select * from P_TNDidLog;
/*-----------------------------------------------------------------------------------------------*/
set term ^ ;
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
    insert into P_TReplLog(NodeRId,TransId,RepKind, RecCnt, StartTM, FinishTM, ErrorId, ErrSource)
      values(:NodeRId,CURRENT_TRANSACTION,:RepKind,:RecCnt,:StartTM,UTCTime(),:ErrorId,:ErrSource);
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_ClearReplLog
as
  declare RecCnt TCount;
  declare LogSize TCount;
  declare DatSize TCount;
  declare NodeRId TRid;
begin
  select NdDataSize,RepLogSize from P_TParams into :DatSize,:LogSize;

  for select
      RecId
    from
      P_TNode
    into
      :NodeRId
    do
      begin
        RecCnt = 0;
        select count(*) from P_TReplLog where NodeRId = :NodeRId into :RecCnt;
        if (RecCnt > LogSize) then
          delete from P_TReplLog
            where NodeRId = :NodeRId
            order by RecId
            rows (:RecCnt - :LogSize);

        RecCnt = 0;
        select count(*) from P_TNDidLog where ParId = :NodeRId into :RecCnt;
        if (RecCnt > DatSize) then
          delete from P_TNDidLog
            where ParId = :NodeRId
            order by RecId
            rows (:RecCnt - :DatSize);

        RecCnt = 0;
        select count(*) from P_TMPidLog where ParId = :NodeRId into :RecCnt;
        if (RecCnt > DatSize) then
          delete from P_TMPidLog
            where ParId = :NodeRId
            order by RecId
            rows (:RecCnt - :DatSize);
      end
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_NodeRating(RecId TRid, NodeId TNodeId)
returns
  (Result TRating)
as
begin
  suspend;
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
    DelTmLim = UTCTime() - DelayO;
    delete from P_TNode where Enabled = 0 and Acceptor = 0 and ExpelTime < :DelTmLim;
  end
  if (DelayA > 0) then
  begin
    DelTmLim = UTCTime() - DelayA;
    delete from P_TNode where Enabled = 0 and Acceptor = 1 and ExpelTime < :DelTmLim;
  end

  if (SizeO > 0 and HoldO = 2) then
  begin
    select count(*) from P_TNode where Acceptor = 0 into :RecCnt;
    if (RecCnt > SizeO) then
      delete from P_TNode
        where Acceptor = 0
        order by Enabled,(select Result from P_NodeRating(RecId,NodeId)) /* do not use desc here */
        rows (:RecCnt - :SizeO);
  end
  if (SizeA > 0 and HoldA = 2) then
  begin
    select count(*) from P_TNode where Acceptor = 1 into :RecCnt;
    if (RecCnt > SizeA) then
      delete from P_TNode
        where Acceptor = 1
        order by Enabled,(select Result from P_NodeRating(RecId,NodeId)) /* do not use desc here */
        rows (:RecCnt - :SizeA);
  end
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_SetNodeData(RecId TRef, AText TSysStr4K)
as
begin
  if (RecId is null or RecId = 0)
  then
    insert into
      P_TNode(
        NodeId,
        Alias,
        Acceptor,
        IP,
        APort,
        APath,
        ExtAcc,
        ExtPWD)
      values(
        (select Result from ParamValue('Main','NodeId',:AText)),
        (select Result from ParamValue('Main','Alias',:AText)),
        (select Result from ParamValue('Main','Acceptor',:AText)),
        (select Result from ParamValue('Main','IP',:AText)),
        (select Result from ParamValue('Main','Port',:AText)),
        (select Result from ParamValue('Main','Path',:AText)),
        (select Result from ParamValue('Main','Account',:AText)),
        (select Result from ParamValue('Main','Password',:AText)));
  else
    update P_TNode
      set
        NodeId = (select Result from ParamValue('Main','NodeId',:AText)),
        Alias = (select Result from ParamValue('Main','Alias',:AText)),
        Acceptor = (select Result from ParamValue('Main','Acceptor',:AText)),
        IP = (select Result from ParamValue('Main','IP',:AText)),
        APort = (select Result from ParamValue('Main','Port',:AText)),
        APath = (select Result from ParamValue('Main','Path',:AText)),
        ExtAcc = (select Result from ParamValue('Main','Account',:AText)),
        ExtPWD = (select Result from ParamValue('Main','Password',:AText))
      where RecId = :RecId;
end^
/*-----------------------------------------------------------------------------------------------*/
set term ; ^
/*-----------------------------------------------------------------------------------------------*/
create view P_Node
as
  select
      *
    from
      P_TNode
    where Enabled = 1
      and ((select NdPubFilter from P_TParams) = 3
        or (Acceptor = 0 and (select NdPubFilter from P_TParams) = 2)
        or (Acceptor = 1 and (select NdPubFilter from P_TParams) = 1));
/*-----------------------------------------------------------------------------------------------*/
create view P_ReplDir as select distinct NodeRId, RepKind from P_TReplLog;
create view P_ReplLog as select * from P_TReplLog;
/*-----------------------------------------------------------------------------------------------*/
grant execute on procedure P_SysSig to trigger P_TBI$TNode;
grant execute on procedure P_SysSig to trigger P_TBU$TNode;

grant execute on procedure P_IsRepl to trigger P_TBI$TNode;
grant execute on procedure P_IsNdSid to trigger P_TBU$TNode;

grant all on P_TReplLog to procedure P_ReplMsg;
grant select on P_TParams to procedure P_ReplMsg;

grant execute on procedure P_CalcHash to procedure P_GetNodeHash;

grant select on P_TParams to procedure P_CheckNode;
grant execute on procedure P_LogErr to procedure P_CheckNode;
grant execute on procedure P_CalcHash to procedure P_CheckNode;
grant execute on procedure P_IsSysSig to procedure P_CheckNode;
grant execute on procedure P_GetNodeHash to procedure P_CheckNode;

grant all on P_TReplLog to procedure P_ClearReplLog;
grant all on P_TNDidLog to procedure P_ClearReplLog;
grant all on P_TMPidLog to procedure P_ClearReplLog;
grant select on P_TNode to procedure P_ClearReplLog;
grant select on P_TParams to procedure P_ClearReplLog;

grant all on P_TNode to procedure P_ClearNodeList;
grant select on P_TParams to procedure P_ClearNodeList;
grant execute on procedure P_NodeRating to procedure P_ClearNodeList;

grant all on P_TNode to procedure P_SetNodeData;
grant execute on procedure ParamValue to procedure P_SetNodeData;
/*-----------------------------------------------------------------------------------------------*/

