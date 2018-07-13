/* ======================================================================== */
/* PeopleRelay: replicator.sql Version: 0.4.3.6                             */
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
create procedure P_Pong(
  r TInt32,
  PeerId TNodeId,
  HShake THandshake,
  Puzzle TSysStr255)
returns
  (Result TInt32,
   AHash1 TIntHash, --Prime
   AHash2 TIntHash, --Cluster
   AHash3 TIntHash, --NodeSig
   PeerIP TIPV6str,
   Proof TSysStr255)
as
  declare Online TBoolean;
begin
  select Online,SigHash from P_TParams into :Online,:AHash3;
  if (Online = 0)
  then
    Result = -1;
  else
    begin
      Result = r;
      select HPrime,HCluster from P_TTransponder into :AHash1,:AHash2;
      if (AHash2 is null) then AHash2 = 0;
      select IP from P_TSesIP into :PeerIP;
      execute procedure P_Handshake(PeerId,HShake,Puzzle) returning_values Proof;
    end

  when any do
  begin
    Result = 0;
    execute procedure P_LogErr(-9,sqlcode,gdscode,sqlstate,'P_Pong',PeerId,PeerIP,null);
  end
      
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_Ping(
  Cnt TUInt1,
  AHash1 TIntHash, --Prime
  AHash2 TIntHash, --Cluster
  AHash3 TIntHash, --NodeSig
  A_DB TFullPath,
  A_USR TUserName,
  A_PWD TPWD,
  PeerId TNodeId)
returns(
  Result TBoolean,
  MyIP TIPV6str)
as
  declare r TInt32;
  declare rr TInt32;
  declare n SmallInt;
  declare sn TSysStr32;
  declare stm TSysStr64;
  declare NodeId TNodeId;
  declare Time1 TTimeMark;
  declare Time2 TTimeMark;
  declare SDelay TTimeGap;
  declare PDelay TTimeGap;
  declare Proof TSysStr255;
  declare Puzzle TSysStr255;
  declare HShake THandshake;
  declare AHash11 TIntHash; --Prime
  declare AHash22 TIntHash; --Cluster
  declare AHash33 TIntHash; --NodeSig
begin
  n = 0;
  SDelay = 0;
  sn = 'P_Ping';
  stm = 'execute procedure P_Pong(?,?,?,?)';

  select NodeId,PingDelay from P_TParams into :NodeId,:PDelay;

  while (n < Cnt) do
  begin
    rr = -1;
    n = n + 1;

    execute procedure P_NewHShake(PeerId) returning_values HShake,Puzzle;
    execute procedure Rand32(10000000) returning_values r;
    Time1 = 'Now';
    execute statement
      (stm) (:r,:NodeId,:HShake,:Puzzle)
      with autonomous transaction        
      on external A_DB as user A_USR password A_PWD
      into
        :rr,
        :AHash11,
        :AHash22,
        :AHash33,
        :MyIP,
        :Proof;
    Time2 = 'Now';  

    if (rr = -1) then
    begin
      execute procedure P_LogErr(-7,0,0,null,sn,PeerId,'Peer offline',null);
      exit;
    end

    if (rr <> r) then
    begin
      execute procedure P_LogErr(-7,r,rr,null,sn,PeerId,'Rand Distortion',null);
      exit;
    end

    if (AHash33 <> AHash3) then
    begin
      execute procedure P_LogErr(-7,0,0,null,sn,PeerId,'Hash Distortion',null);
      exit;
    end

    if (AHash11 <> AHash1) then
    begin
      execute procedure P_LogErr(-7,0,0,null,sn,PeerId,'Unknown Prime',null);
      exit;
    end
    if (AHash22 <> AHash2
      and not (AHash22 = 0 or AHash2 = 0))
    then
      begin
        execute procedure P_LogErr(-7,0,0,null,sn,PeerId,'Unknown Cluster',null);
        exit;
      end

    if ((select Result from  P_CheckHShake(:PeerId,:HShake,:Puzzle,:Proof)) = 0) then
    begin
      execute procedure P_LogErr(-7,0,0,null,sn,PeerId,'Bad Handshake',null);
      exit;
    end
    
    Result = 1;
    SDelay = SDelay + datediff(second, Time1, Time2);
  end

  if ((SDelay / Cnt) > PDelay) then
  begin
    Result = 0;
    execute procedure P_LogErr(-7,0,0,null,sn,PeerId,'Ping timeout',null);
  end

  when any do
  begin
    Result = 0;
    execute procedure P_LogErr(-7,sqlcode,gdscode,sqlstate,sn,PeerId,'Error',null);
  end
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_CorrNode(
  RecId TRef,
  Alias TNdAlias,
  Status TNdStatus,
  Acceptor TBoolean,
  EditTime TTimeMark,
  NodeSig TSig,
  PubKey TKey)
as
  declare NodeId TNodeId;
begin
  select NodeId from P_TPeer where RecId = :RecId into :NodeId;

  update P_TPeerLog /* To prevent overwriting */
    set
      Alias = :Alias,
      Status = :Status,
      Acceptor = :Acceptor,
      EditTime = :EditTime,
      NodeSig = :NodeSig,
      PubKey = :PubKey
    where NodeId = :NodeId
      and (Alias <> :Alias
        or Status <> :Status
        or Acceptor <> :Acceptor
        or EditTime <> :EditTime
        or NodeSig <> :NodeSig
        or PubKey <> :PubKey);

  update P_TRegInq /* To prevent overwriting */
    set
      Alias = :Alias,
      Status = :Status,
      Acceptor = :Acceptor,
      EditTime = :EditTime,
      NodeSig = :NodeSig,
      PubKey = :PubKey
    where NodeId = :NodeId
      and (Alias <> :Alias
        or Status <> :Status
        or Acceptor <> :Acceptor
        or EditTime <> :EditTime
        or NodeSig <> :NodeSig
        or PubKey <> :PubKey);

  update P_TPeer
    set
      Alias = :Alias,
      Status = :Status,
      Acceptor = :Acceptor,
      EditTime = :EditTime,
      NodeSig = :NodeSig,
      PubKey = :PubKey
    where RecId = :RecId
      and (Alias <> :Alias
        or Status <> :Status
        or Acceptor <> :Acceptor
        or EditTime <> :EditTime
        or NodeSig <> :NodeSig
        or PubKey <> :PubKey);
  when any do
    execute procedure P_LogErr(-54,sqlcode,gdscode,sqlstate,'P_CorrNode',null,'Error',null);
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_HasNode(
  Status TNdStatus,
  NodeId TNodeId,
  IP TIPV6str,
  NodeSig TSig)
returns
  (Result TBoolean)
as
begin
  if (exists (select 1 from P_TParams where NodeId = :NodeId)
    or exists (select 1 from P_TRegInq where NodeId = :NodeId)
    or exists (select 1 from P_TPeer
      where NodeId = :NodeId
        and NodeSig = :NodeSig
        and Status = :Status
        and IP = :IP))
  then
    Result = 1;
  suspend;  
end^
/*-----------------------------------------------------------------------------------------------*/
/*
  BlockNo           TRid,
  Checksum          TIntHash not null,
  BHash             TChHash not null,


*/
/*
create procedure P_PeerProps()
as
  declare stm TSysStr512;
begin
  stm = 'select max()';

end^
*/
/*-----------------------------------------------------------------------------------------------*/
create procedure P_RegNode(
  SigHash TIntHash,
  NodeId TNodeId,
  Alias TNdAlias,
  Status TNdStatus,
  Acceptor TBoolean,
  StaticIP TIPV6str,
  APort TPort,
  APath TPath,
  ExtAcc TUserName,
  ExtPWD TPWD,
  EditTime TTimeMark,
  NodeSig TSig,
  PubKey TKey)
returns
  (Result TBoolean,
  R_Alias TNdAlias,
  R_Status TNdStatus,
  R_Acceptor TBoolean,
  R_EditTime TTimeMark,
  R_NodeSig TSig,
  R_PubKey TKey)
as
  declare SizeO TCount;
  declare SizeA TCount;
  declare HoldO TNdLsHold;
  declare HoldA TNdLsHold;
  declare NSize TCount;
  declare NHold TNdLsHold;
  declare RFlt TNdFilter;
  declare IP TIPV6str;
  declare AHash TChHash;
  declare SSgHsh TIntHash;  
begin
  if ((select Online from P_TParams) > 0) then
  begin

    Result = 1;
    ExtAcc = Upper(ExtAcc);

    if (StaticIP is null or char_length(Trim(StaticIP)) < 7) /* 0.0.0.0 */
    then
      select IP from P_TSesIP into :IP;
    else
      IP = StaticIP;

    if ((select Result from P_HasNode(:Status,:NodeId,:IP,:NodeSig)) = 0) then
    begin
      select
          NdRegFilter,
          NdLstSizeAcc,
          NdLstHoldAcc,
          NdLstSizeOrd,
          NdLstHoldOrd,
          Alias,
          Status,
          Acceptor,
          coalesce(AlteredAt,ChangedAt),
          SigHash,
          NodeSig,
          PubKey
        from P_TParams
          into
            :RFlt,
            :SizeA,
            :HoldA,
            :SizeO,
            :HoldO,
            :R_Alias,
            :R_Status,
            :R_Acceptor,
            :R_EditTime,
            :SSgHsh,
            :R_NodeSig,
            :R_PubKey;

      if ((select Result
        from P_CheckNode(1,:NodeId,:Alias,:Acceptor,
          :APort,:APath,:ExtAcc,:ExtPWD,:NodeSig,null,:PubKey,null)) = 0)
      then
        exit;

      if (RFlt = 3
        or (RFlt = 1 and Acceptor = 1)
        or (RFlt = 2 and Acceptor = 0))
      then
        begin
          if (Acceptor = 0)
          then
            begin
              NSize = SizeO;
              NHold = HoldO;
            end
          else
            begin
              NSize = SizeA;
              NHold = HoldA;
            end

          if (NSize > 0 and NHold = 1
            and (select (count(*) - :NSize)
              from P_TPeer where Acceptor = :Acceptor) > 0)
          then
            exit;

          if (exists (select 1 from P_TRegInq where NodeId = :NodeId))
          then
            update P_TRegInq set
                Alias = :Alias,
                Status = :Status,
                Acceptor = :Acceptor,
                IP = :IP,
                APort = :APort,
                APath = :APath,
                ExtAcc = :ExtAcc,
                ExtPWD = :ExtPWD,
                EditTime = :EditTime,
                NodeSig = :NodeSig,
                PubKey = :PubKey
              where NodeId = :NodeId;
          else
            insert into
              P_TRegInq(
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
                PubKey)
              values(
                :NodeId,
                :Alias,
                :Status,
                :Acceptor,
                :IP,
                :APort,
                :APath,
                :ExtAcc,
                :ExtPWD,
                :EditTime,
                :NodeSig,
                :PubKey);

          execute procedure P_LogMsg(3,0,0,null,'P_RegNode',NodeId,'Registering Node',null);

          if (SigHash is not distinct from SSgHsh) then
          begin
            R_EditTime = null;
            R_NodeSig = null;
            R_PubKey = null;
          end

          when any do
          begin
            Result = 0;
            if (sqlcode <> -803) then
              execute procedure P_LogErr(-15,sqlcode,gdscode,sqlstate,'P_RegNode',NodeId,null,null);
          end
        end
    end
  end
end^
/*-----------------------------------------------------------------------------------------------*/
alter procedure P_Register
as
  declare flag TBoolean;
  declare ATest TBoolean;

  declare Pros TCount;
  declare Voting TCount;
  declare Quorum TCount;
  declare Assent TCount;

  declare Acceptor TBoolean;
  declare MtCheck TBoolean;
  declare ChkRslt TTrilean;
  declare NRecId TRef;
  declare EditTime TTimeMark;
  declare StaticIP TIPV6str;
  declare APort TPort;
  declare APath TPath;
  declare ExtAcc TUserName;
  declare ExtPWD TPWD;
  declare NodeId TNodeId;

  declare Alias TNdAlias;
  declare Status TNdStatus;
  declare PeerId TNodeId;

  declare PeerIP TIPV6str;
  declare PeerPort TPort;

  declare A_USR TUserName;
  declare A_PWD TPWD;
  declare A_DB TFullPath;

  declare pn TSysStr31;
  declare NodeSig TSig;
  declare PubKey TKey;
  declare stm TSysStr512;

  declare SigHash TIntHash;
  declare R_Alias TNdAlias;
  declare R_Status TNdStatus;
  declare R_Acceptor TBoolean;
  declare R_EditTime TTimeMark;
  declare R_NodeSig TSig;
  declare R_PubKey TKey;

begin
  pn = 'P_Register';
  execute procedure P_BegRepl returning_values ATest;
  execute procedure P_LogMsg(4,0,0,null,pn,null,'Start',null);
  execute procedure SYS_DBName returning_values APath;
  select
      NodeId,
      Alias,
      Status,
      Acceptor,
      StaticIP,
      APort,
      ExtAcc,
      ExtPWD,
      MetaCheckPut,
      NodeSig,
      PubKey,
      coalesce(AlteredAt,ChangedAt)
    from
      P_TParams
    into
      :NodeId,
      :Alias,
      :Status,
      :Acceptor,
      :StaticIP,
      :APort,
      :ExtAcc,
      :ExtPWD,
      :MtCheck,
      :NodeSig,
      :PubKey,
      :EditTime;
  if (NodeId = '-'
    or ExtAcc = '-'
    or ExtPWD = '-'
    or Char_Length(APort) < 3
    or APath is null or APath = ''
    or NodeSig is null
    or PubKey is null)
  then
    begin
      execute procedure P_LogErr(-16,1,0,null,pn,null,'Incorrect self data',null);
      exit;
    end
  stm = 'execute procedure P_RegNode(?,?,?,?,?,?,?,?,?,?,?,?,?)';
  execute procedure P_GetQuorum(3,Acceptor,-1) returning_values Quorum;
  execute procedure P_GetAssent(3,Acceptor,Quorum) returning_values Assent;

  for select
      RecId,
      NodeId,
      SigHash,
      Ip,
      APort,
      ExtAcc,
      ExtPWD,
      FullPath
    from
      P_PeerList(3,:Acceptor)
    into
      :NRecId,
      :PeerId,
      :SigHash,
      :PeerIp,
      :PeerPort,
      :A_USR,
      :A_PWD,
      :A_DB
  do
    if ((select Result
      from P_IsOnline(:PeerIP,:PeerPort)) = 0)
    then
      execute procedure P_LogErr(-17,0,0,0,'P_IsOnline',PeerId,null,null);
    else
      begin
        if (MtCheck = 1)
        then
          execute procedure SYS_CheckDB(A_DB,A_USR,A_PWD) returning_values ChkRslt;
        else
          ChkRslt = 1;
        if (ChkRslt = 1)
        then
          begin
            begin
              flag = 0;
              execute statement
                (stm) (:SigHash,:NodeId,:Alias,:Status,:Acceptor,:StaticIP,
                  :APort,:APath,:ExtAcc,:ExtPWD,:EditTime,:NodeSig,:PubKey)
                with autonomous transaction
                on external A_DB as user A_USR password A_PWD
                into
                  :flag,
                  :R_Alias,
                  :R_Status,
                  :R_Acceptor,
                  :R_EditTime,
                  :R_NodeSig,
                  :R_PubKey;
              Voting = Voting + 1;
              when any do flag = 0;
            end
            if (flag = 1) then
            begin
              Pros = Pros + 1;
              if (R_EditTime is not null) then
                execute procedure P_CorrNode(
                  NRecId,
                  R_Alias,
                  R_Status,
                  R_Acceptor,
                  R_EditTime,
                  R_NodeSig,
                  R_PubKey);
            end

            if (Pros >= Assent
              or Voting >= Quorum)
            then
              begin
                execute procedure P_Unaltered;
                Leave;
              end

            when any do
              execute procedure P_LogErr(-18,sqlcode,gdscode,sqlstate,pn,PeerId,null,null);
          end
        else
          execute procedure P_BadMeta(NRecId,PeerId,pn);
      end
  execute procedure P_LogMsg(4,0,0,null,pn,null,'Finish',null);
  if (ATest = 1) then execute procedure P_EndRepl;

  when any do
  begin
    if (ATest = 1) then execute procedure P_EndRepl;
    execute procedure P_LogErr(-19,sqlcode,gdscode,sqlstate,pn,null,null,null);
  end  
end^
/*-----------------------------------------------------------------------------------------------*/
--execute procedure PG_Node(1,'127.0.0.1:c:\database\relaymail.fb','SYSDBA','masterkey')

create procedure PG_Node(
  A_RId TRef,
  A_SRC TFullPath,
  A_USR TPWD,
  A_PWD TUserName)
returns
  (Rec_Cnt TCount)
as
  declare NDO TUInt;
  declare RFlt TNdFilter;
  declare OldSid TRef;  
  declare StartSid TRef;
  declare SrcSid TRef;
  declare NewSid TRef;
  declare aFlag TBoolean;
  declare Acceptor TBoolean;
  declare PeerIP TIPV6str;
  declare IP TIPV6str;
  declare PeerId TNodeId;
  declare NodeId TNodeId;
  declare Alias TNdAlias;
  declare Status TNdStatus;
  declare APort TPort;
  declare APath TPath;
  declare ExtAcc TUserName;
  declare ExtPWD TPWD;
  declare EditTime TTimeMark;
  declare NodeSig TSig;
  declare TmpSig TSig;
  declare PubKey TKey;
  declare PeerKey TKey;
  declare sstm TSysStr64;
  declare stm TSysStr1K;
begin
  Rec_Cnt = 0;
  select NDOverlap,PeersSync from P_TParams into :NDO,:RFlt;

  select NodeId,Acceptor,IP,PubKey from P_TPeer
    where RecId = :A_RId into :PeerId,:aFlag,:PeerIP,:PeerKey;

  select first 1 Sid from P_TNDidLog
    where ParId = :A_RId order by RecId desc into :StartSid;
  if (StartSid is null) then StartSid = 0;
  OldSid = StartSid;
  NewSid = StartSid;
  if (StartSid >= NDO) then StartSid = StartSid - NDO;

  if (RFlt = 1)
  then
    sstm = ' Acceptor = 1 and';
  else
    if (RFlt = 2)
    then
      sstm = ' Acceptor = 0 and';
    else
      sstm = '';

  stm = 'select Sid,NodeId,Alias,Status,Acceptor,IP,APort,APath,ExtAcc,ExtPWD,EditTime,NodeSig,'
    || 'TmpSig,PubKey from P_Peer where' || sstm || ' Sid > ? order by Sid';

  for execute statement (stm) (:StartSid)
    on external A_SRC as user A_USR password A_PWD
    into
      :SrcSid,
      :NodeId,
      :Alias,
      :Status,
      :Acceptor,
      :IP,
      :APort,
      :APath,
      :ExtAcc,
      :ExtPWD,
      :EditTime,
      :NodeSig,
      :TmpSig,
      :PubKey
  do
    if ((select Result from P_CheckNode(2,:NodeId,:Alias,:Acceptor,
        :APort,:APath,:ExtAcc,:ExtPWD,:NodeSig,:TmpSig,:PubKey,:PeerKey)) = 1)
    then
      begin
        if (not exists (select 1 from P_TPeerLog where ParId = :A_RId and NodeId = :NodeId))
        then
          insert into
            P_TPeerLog(
              ParId,
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
              PubKey)
            values(
              :A_RId,
              :NodeId,
              :Alias,
              :Status,
              :Acceptor,
              :IP,
              :APort,
              :APath,
              :ExtAcc,
              :ExtPWD,
              :EditTime,
              :NodeSig,
              :PubKey);
        else
          update P_TPeerLog
            set
              Alias = :Alias,
              Status = :Status,
              Acceptor = :Acceptor,
              IP = :IP,
              APort = :APort,
              APath = :APath,
              ExtAcc = :ExtAcc,
              ExtPWD = :ExtPWD,
              EditTime = :EditTime,
              NodeSig = :NodeSig,
              PubKey = :PubKey
            where ParId = :A_RId and NodeId = :NodeId
              and (Alias <> :Alias
                or Status <> :Status
                or Acceptor <> :Acceptor
                or IP <> :IP
                or APort <> :APort
                or APath <> :APath
                or ExtAcc <> :ExtAcc
                or ExtPWD <> :ExtPWD
                or EditTime <> :EditTime
                or NodeSig <> :NodeSig
                or PubKey <> :PubKey);
        NewSid = MaxValue(NewSid,SrcSid);

        when any do
          if (sqlcode not in (-803,-530)) then
            execute procedure P_LogErr(-151,sqlcode,gdscode,sqlstate,'PG_Node',NodeId,'Error',null);
      end
    else
      NewSid = MaxValue(NewSid,SrcSid);

  if (NewSid > OldSid) then execute procedure P_UpdNDid(A_RId,NewSid);

  when any do
    execute procedure P_LogErr(-152,sqlcode,gdscode,sqlstate,'PG_Node',NodeId,'Error',null);

end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_FixNodes
as
  declare NodeId TNodeId;
  declare Alias TNdAlias;
  declare Status TNdStatus;
  declare Acceptor TBoolean;
  declare IP TIPV6str;
  declare APort TPort;
  declare APath TPath;
  declare ExtAcc TUserName;
  declare ExtPWD TPWD;
  declare EditTime TTimeMark;
  declare NodeSig TSig;
  declare PubKey TKey;
begin
  for select
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
      P_PeerLog
    order by
      Voting
    into
      :NodeId,
      :Alias,
      :Status,
      :Acceptor,
      :IP,
      :APort,
      :APath,
      :ExtAcc,
      :ExtPWD,
      :EditTime,
      :NodeSig,
      :PubKey
  do
    begin
      if (exists (select 1 from P_TPeer where NodeId = :NodeId))
      then
        update P_TPeer
          set
            Alias = :Alias,
            Status = :Status,
            Acceptor = :Acceptor,
            IP = :IP,
            APort = :APort,
            APath = :APath,
            ExtAcc = :ExtAcc,
            ExtPWD = :ExtPWD,
            EditTime = :EditTime,
            NodeSig = :NodeSig,
            PubKey = :PubKey
          where NodeId = :NodeId
            and (Alias <> :Alias
              or Status <> :Status
              or Acceptor <> :Acceptor
              or IP <> :IP
              or APort <> :APort
              or APath <> :APath
              or ExtAcc <> :ExtAcc
              or ExtPWD <> :ExtPWD
              or EditTime <> :EditTime
              or NodeSig <> :NodeSig
              or PubKey <> :PubKey);
      else
        insert into
          P_TPeer(
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
            PubKey)
          values(
            :NodeId,
            :Alias,
            :Status,
            :Acceptor,
            :IP,
            :APort,
            :APath,
            :ExtAcc,
            :ExtPWD,
            :EditTime,
            :NodeSig,
            :PubKey);
    end

  delete from P_TPeerLog;

  when any do
    execute procedure P_LogErr(-10,sqlcode,gdscode,sqlstate,'P_FixNodes',null,null,null);
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_DoPullData(Acceptor TBoolean, RepKind TRepKind, ProcName TSysStr32)
as
  declare flag TBoolean;
  declare PeerRId TRef;
  declare Voting TCount;
  declare Quorum TCount;
  declare AHash1 TIntHash;
  declare AHash2 TIntHash;
  declare AHash3 TIntHash;
  declare Rec_Cnt TCount;
  declare TMSlice TInt32;
  declare ChkRslt TTrilean;
  declare PingCount TUInt1;
  declare MtCheck TBoolean;
  declare TM0 TTimeMark;
  declare StartTM TTimeMark;
  declare PeerIP TIPV6str;
  declare PeerPort TPort;
  declare A_USR TUserName;
  declare A_PWD TPWD;
  declare A_DB TFullPath;
  declare MyIP TIPV6str;
  declare PeerId TNodeId;
  declare sn TSysStr32;
begin
  sn = 'P_DoPullData';
  Voting = 0;
  Rec_Cnt = 0;
  TM0 = CURRENT_TIMESTAMP;
  select PingCount,MetaCheckGet,TimeSlice from P_TParams into :PingCount,:MtCheck,:TMSlice;
  select HPrime,HCluster from P_TTransponder into :AHash1,:AHash2;
  if (AHash2 is null) then AHash2 = 0;

  execute procedure P_GetQuorum(RepKind,Acceptor,-1) returning_values Quorum;

  for select
      RecId,
      NodeId,
      SigHash,
      Ip,
      APort,
      ExtAcc,
      ExtPWD,
      FullPath
    from
      P_PeerList(:RepKind,:Acceptor)
    into
      :PeerRId,
      :PeerId,
      :AHash3,
      :PeerIp,
      :PeerPort,
      :A_USR,
      :A_PWD,
      :A_DB
  do
    if ((select Result
      from P_IsOnline(:PeerIP,:PeerPort)) = 0)
    then
      execute procedure P_LogErr(-101,RepKind,PeerRId,null,ProcName,PeerId,'P_IsOnline',null);
    else
      begin
        execute procedure P_Ping(PingCount,AHash1,AHash2,AHash3,
          A_DB,A_USR,A_PWD,PeerId) returning_values flag,MyIP;
        execute procedure P_LogIp(PeerId,MyIP);

        if (flag = 1) then
        begin
          if (MtCheck = 1)
          then
            execute procedure SYS_CheckDB(A_DB,A_USR,A_PWD) returning_values ChkRslt;
          else
            ChkRslt = 1;

          if (ChkRslt = 1)
          then
            begin
              StartTM = UTCTime();

              if (RepKind = 0)
              then
                execute procedure PG_Node(PeerRId,A_DB,A_USR,A_PWD) returning_values Rec_Cnt;
              else
                if (RepKind = 1)
                then
                  execute procedure PG_Chain(PeerRId,A_DB,A_USR,A_PWD) returning_values Rec_Cnt;
                else
                  execute procedure PG_MeltingPot(PeerRId,A_DB,A_USR,A_PWD) returning_values Rec_Cnt;

              if (Rec_Cnt > 0) then
                execute procedure P_ReplMsg(PeerRId,RepKind,Rec_Cnt,StartTM,0,null);

              Voting = Voting + 1;
              if (Voting >= Quorum) then Leave;
              when any do
                execute procedure P_LogErr(-102,sqlcode,gdscode,sqlstate,ProcName,PeerId,null,null);
            end
          else
            execute procedure P_BadMeta(PeerRId,PeerId,ProcName);
        end

        if(TMSlice > 0
          and datediff(minute,TM0,cast('Now' as TimeStamp)) > TMSlice)
        then
          begin
            execute procedure P_LogErr(-103,RepKind,Rec_Cnt,null,ProcName,PeerId,'Long duration',null);
            Leave;
          end

        when any do
          execute procedure P_LogErr(-104,sqlcode,gdscode,sqlstate,sn,PeerId,ProcName,null);
      end

  execute procedure P_LogMsg(8,Voting,0,null,sn,ProcName,null,null);

  when any do
    execute procedure P_LogErr(-100,sqlcode,gdscode,sqlstate,sn,ProcName,null,null);

end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_PullData
as
  declare QA TCount;
  declare QAcc TBoolean;
  declare flag TBoolean;
  declare Rec_Cnt TCount;
  declare OnLine TBoolean;
  declare Acceptor TBoolean;
  declare NDQuorumAcc TBoolean;
  declare CHQuorumAcc TBoolean;
  declare PeersSync TNdFilter;
  declare ChainSync TBoolean;
begin
  execute procedure P_BegRepl returning_values flag;
  if (flag = 1) then
  begin
    select
        OnLine,
        Acceptor,
        NDQuorumAcc,
        CHQuorumAcc,
        PeersSync,
        ChainSync
      from
        P_TParams
      into
        :OnLine,
        :Acceptor,
        :NDQuorumAcc,
        :CHQuorumAcc,
        :PeersSync,
        :ChainSync;

    if (OnLine = 0)
    then
      execute procedure P_LogMsg(7,0,0,null,'P_PullData',null,'DB is Offline',null);
    else
      begin
        execute procedure P_LogMsg(2,0,0,null,'P_PullData',null,'Start',null);

        if (PeersSync > 0) then
        begin
          execute procedure P_DoPullData(Acceptor,0,'PG_Node');
          if (Acceptor = 1 and NDQuorumAcc = 0) then QAcc = 1; else QAcc = 0;
          execute procedure P_FixNodes;
        end

        if (ChainSync > 0) then
        begin
          execute procedure P_DoPullData(Acceptor,1,'PG_Chain');
          if (Acceptor = 1 and CHQuorumAcc = 0) then QAcc = 1; else QAcc = 0;
          execute procedure P_FixChain(QAcc) returning_values Rec_Cnt;

          if (Acceptor = 1) then
            execute procedure P_DoPullData(Acceptor,2,'PG_MeltingPot');

/* debug, test for P_TPeer concurrent updates
          if (Acceptor = 1) then
            in autonomous transaction do --debug, test for P_TPeer concurrent updates
              execute procedure P_DoPullData(Acceptor,2,'PG_MeltingPot');
*/
        end

        execute procedure P_LogMsg(2,0,0,null,'P_PullData',null,'Finish',null);
        when any do
          execute procedure P_LogErr(-80,sqlcode,gdscode,sqlstate,'P_PullData',null,'Error',null);
      end
    execute procedure P_EndRepl;
  end    
end^
/*-----------------------------------------------------------------------------------------------*/
set term ; ^
/*-----------------------------------------------------------------------------------------------*/
grant select on P_TParams to procedure P_Pong;
grant select on P_TTransponder to procedure P_Pong;
grant execute on procedure P_LogErr to procedure P_Pong;
grant execute on procedure P_Handshake to procedure P_Pong;

grant select on P_TParams to procedure P_Ping;
grant execute on procedure Rand32 to procedure P_Ping;
grant execute on procedure P_LogErr to procedure P_Ping;
grant execute on procedure P_NewHShake to procedure P_Ping;
grant execute on procedure P_CheckHShake to procedure P_Ping;

grant all on P_TPeer to procedure P_CorrNode;
grant all on P_TRegInq to procedure P_CorrNode;
grant all on P_TPeerLog to procedure P_CorrNode;
grant execute on procedure P_LogErr to procedure P_CorrNode;

grant select on P_TPeer to procedure P_HasNode;
grant select on P_TParams to procedure P_HasNode;
grant select on P_TRegInq to procedure P_HasNode;

grant all on P_TRegInq to procedure P_RegNode;
grant select on P_TPeer to procedure P_RegNode;
grant select on P_TParams to procedure P_RegNode;
grant execute on procedure P_LogMsg to procedure P_RegNode;
grant execute on procedure P_LogErr to procedure P_RegNode;
grant execute on procedure P_HasNode to procedure P_RegNode;
grant execute on procedure P_CheckNode to procedure P_RegNode;

grant select on P_TParams to procedure P_Register;
grant execute on procedure P_LogMsg to procedure P_Register;
grant execute on procedure P_LogErr to procedure P_Register;
grant execute on procedure P_BadMeta to procedure P_Register;
grant execute on procedure P_BegRepl to procedure P_Register;
grant execute on procedure P_EndRepl to procedure P_Register;
grant execute on procedure SYS_DBName to procedure P_Register;
grant execute on procedure P_IsOnline to procedure P_Register;
grant execute on procedure P_PeerList to procedure P_Register;
grant execute on procedure P_CorrNode to procedure P_Register;
grant execute on procedure P_GetQuorum to procedure P_Register;
grant execute on procedure P_GetAssent to procedure P_Register;
grant execute on procedure SYS_CheckDB to procedure P_Register;
grant execute on procedure P_Unaltered to procedure P_Register;

grant all on P_TPeerLog to procedure PG_Node;
grant select on P_TPeer to procedure PG_Node;
grant select on P_TParams to procedure PG_Node;
grant select on P_TNDidLog to procedure PG_Node;
grant execute on procedure P_LogErr to procedure PG_Node;
grant execute on procedure P_UpdNDid to procedure PG_Node;
grant execute on procedure P_CheckNode to procedure PG_Node;

grant select on P_TParams to procedure P_DoPullData;
grant select on P_TTransponder to procedure P_DoPullData;
grant execute on procedure P_Ping to procedure P_DoPullData;
grant execute on procedure P_LogIp to procedure P_DoPullData;
grant execute on procedure P_LogMsg to procedure P_DoPullData;
grant execute on procedure P_LogErr to procedure P_DoPullData;
grant execute on procedure P_ReplMsg to procedure P_DoPullData;
grant execute on procedure P_BadMeta to procedure P_DoPullData;
grant execute on procedure P_PeerList to procedure P_DoPullData;
grant execute on procedure P_IsOnline to procedure P_DoPullData;
grant execute on procedure P_GetQuorum to procedure P_DoPullData;
grant execute on procedure SYS_CheckDB to procedure P_DoPullData;

grant execute on procedure PG_Node to procedure P_DoPullData;
grant execute on procedure PG_Chain to procedure P_DoPullData;
grant execute on procedure PG_MeltingPot to procedure P_DoPullData;

grant all on P_TPeer to procedure P_FixNodes;
grant all on P_TPeerLog to procedure P_FixNodes;
grant select on P_PeerLog to procedure P_FixNodes;
grant execute on procedure P_LogErr to procedure P_FixNodes;

grant select on P_TParams to procedure P_PullData;
grant execute on procedure P_LogMsg to procedure P_PullData;
grant execute on procedure P_LogErr to procedure P_PullData;
grant execute on procedure P_BegRepl to procedure P_PullData;
grant execute on procedure P_EndRepl to procedure P_PullData;
grant execute on procedure P_FixNodes to procedure P_PullData;
grant execute on procedure P_FixChain to procedure P_PullData;
grant execute on procedure P_AssentAcc to procedure P_PullData;
grant execute on procedure P_DoPullData to procedure P_PullData;

grant all on P_TBacklog to procedure PG_Chain;
grant all on P_TSMVoter to procedure PG_Chain;
grant select on P_TPeer to procedure PG_Chain;
grant select on P_TChain to procedure PG_Chain;
grant select on P_TParams to procedure PG_Chain;
grant execute on procedure P_IsHash to procedure PG_Chain;
grant execute on procedure P_LogErr to procedure PG_Chain;
grant execute on procedure P_BadTmS to procedure PG_Chain;
grant execute on procedure P_BadHash to procedure PG_Chain;
grant execute on procedure P_BadSign to procedure PG_Chain;
grant execute on procedure P_IsSysSig to procedure PG_Chain;
grant execute on procedure P_CalcHash to procedure PG_Chain;
grant execute on procedure P_IsBlockSig to procedure PG_Chain;

grant all on P_TChain to procedure P_FixChain;
grant select on P_TBacklog to procedure P_FixChain;
grant execute on procedure P_Dehorn to procedure P_FixChain;
grant execute on procedure P_Repair to procedure P_FixChain;
grant execute on procedure P_LogErr to procedure P_FixChain;
grant execute on procedure P_AssentAcc to procedure P_FixChain;
grant execute on procedure P_AssentTot to procedure P_FixChain;

grant all on P_TMPVoter to procedure PG_MeltingPot;
grant select on P_TPeer to procedure PG_MeltingPot;
grant select on P_TParams to procedure PG_MeltingPot;
grant select on P_TMPidLog to procedure PG_MeltingPot;
grant all on P_TMeltingPot to procedure PG_MeltingPot;
grant execute on procedure P_IsHash to procedure PG_MeltingPot;
grant execute on procedure P_LogMsg to procedure PG_MeltingPot;
grant execute on procedure P_LogErr to procedure PG_MeltingPot;
grant execute on procedure P_BadTmS to procedure PG_MeltingPot;
grant execute on procedure P_BadHash to procedure PG_MeltingPot;
grant execute on procedure P_BadSign to procedure PG_MeltingPot;
grant execute on procedure P_UpdMPId to procedure PG_MeltingPot;
grant execute on procedure P_IsSysSig to procedure PG_MeltingPot;
grant execute on procedure P_CalcHash to procedure PG_MeltingPot;
grant execute on procedure P_BegReplEx to procedure PG_MeltingPot;
grant execute on procedure P_IsBlockSig to procedure PG_MeltingPot;

grant select on P_TChain to procedure P_RevertBlock;
grant all on P_TMeltingPot to procedure P_RevertBlock;
grant execute on procedure P_LogErr to procedure P_RevertBlock;
grant execute on procedure P_BegAddB to procedure P_RevertBlock;
grant execute on procedure P_EndAddB to procedure P_RevertBlock;

grant all on P_TChain to procedure P_Commit;
grant select on P_TParams to procedure P_Commit;
grant select on P_TBackLog to procedure P_Commit;
grant execute on procedure P_LogMsg to procedure P_Commit;
grant execute on procedure P_LogErr to procedure P_Commit;
grant execute on procedure P_AssentAcc to procedure P_Commit;
grant execute on procedure P_BegCommit to procedure P_Commit;
grant execute on procedure P_EndCommit to procedure P_Commit;
/*-----------------------------------------------------------------------------------------------*/

