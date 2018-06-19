/* ======================================================================== */
/* PeopleRelay: replicator.sql Version: 0.4.1.8                             */
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
   AHash3 TIntHash, --LoadSig
   PeerIP TIPV6str,
   Proof TSysStr255)
as
begin
  Result = r;
  select HPrime,HCluster from P_TTransponder into :AHash1,:AHash2;
  select SigHash from P_TParams into :AHash3;
  if (AHash2 is null) then AHash2 = 0;
  select IP from P_TSesIP into :PeerIP;

  execute procedure P_Handshake(PeerId,HShake,Puzzle) returning_values Proof;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_Ping(
  Cnt TUInt1,
  AHash1 TIntHash, --Prime
  AHash2 TIntHash, --Cluster
  AHash3 TIntHash, --LoadSig
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
  declare AHash33 TIntHash; --LoadSig
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
      execute procedure P_LogErr(-7,r,rr,null,sn,PeerId,'Unknown Prime',null);
      exit;
    end
    if (AHash22 <> AHash2
      and not (AHash22 = 0 or AHash2 = 0))
    then
      begin
        execute procedure P_LogErr(-7,r,rr,null,sn,PeerId,'Unknown Cluster',null);
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
  IpMaskLen TUInt,
  EditTime TTimeMark,
  LoadSig TSig,
  PubKey TKey)
as
  declare NodeId TNodeId;
begin
  select NodeId from P_TNode where RecId = :RecId into :NodeId;

  update P_TNodeLog /* To prevent overwriting */
    set
      Alias = :Alias,
      Status = :Status,
      Acceptor = :Acceptor,
      IpMaskLen = :IpMaskLen,
      EditTime = :EditTime,
      LoadSig = :LoadSig,
      PubKey = :PubKey
    where NodeId = :NodeId
      and (Alias <> :Alias
        or Status <> :Status
        or Acceptor <> :Acceptor
        or IpMaskLen <> :IpMaskLen
        or EditTime <> :EditTime
        or LoadSig <> :LoadSig
        or PubKey <> :PubKey);

  update P_TRegInq /* To prevent overwriting */
    set
      Alias = :Alias,
      Status = :Status,
      Acceptor = :Acceptor,
      IpMaskLen = :IpMaskLen,
      EditTime = :EditTime,
      LoadSig = :LoadSig,
      PubKey = :PubKey
    where NodeId = :NodeId
      and (Alias <> :Alias
        or Status <> :Status
        or Acceptor <> :Acceptor
        or IpMaskLen <> :IpMaskLen
        or EditTime <> :EditTime
        or LoadSig <> :LoadSig
        or PubKey <> :PubKey);

  update P_TNode
    set
      Alias = :Alias,
      Status = :Status,
      Acceptor = :Acceptor,
      IpMaskLen = :IpMaskLen,
      EditTime = :EditTime,
      LoadSig = :LoadSig,
      PubKey = :PubKey
    where RecId = :RecId
      and (Alias <> :Alias
        or Status <> :Status
        or Acceptor <> :Acceptor
        or IpMaskLen <> :IpMaskLen
        or EditTime <> :EditTime
        or LoadSig <> :LoadSig
        or PubKey <> :PubKey);
  when any do
    execute procedure P_LogErr(-54,sqlcode,gdscode,sqlstate,'P_CorrNode',null,'Error',null);
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_HasNode(
  Status TNdStatus,
  IpMaskLen TUInt,
  NodeId TNodeId,
  IP TIPV6str,
  LoadSig TSig)
returns
  (Result TBoolean)
as
begin
  if (exists (select 1 from P_TParams where NodeId = :NodeId)
    or exists (select 1 from P_TRegInq where NodeId = :NodeId)
    or exists (select 1 from P_TNode
      where NodeId = :NodeId
        and LoadSig = :LoadSig
        and Status = :Status
        and IpMaskLen = :IpMaskLen
        and IP = :IP))
  then
    Result = 1;
  suspend;  
end^
/*-----------------------------------------------------------------------------------------------*/
/*
  BlockNo           TRid,
  Checksum          TIntHash not null,
  SelfHash          TChHash not null,


*/
/*
create procedure P_PerrProps()
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
  IpMaskLen TUInt,
  StaticIP TIPV6str,
  APort TPort,
  APath TPath,
  ExtAcc TUserName,
  ExtPWD TPWD,
  EditTime TTimeMark,
  LoadSig TSig,
  PubKey TKey)
returns
  (Result TBoolean,
  R_Alias TNdAlias,
  R_Status TNdStatus,
  R_Acceptor TBoolean,
  R_IpMaskLen TUInt,
  R_EditTime TTimeMark,
  R_LoadSig TSig,
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
  Result = 1;
  ExtAcc = Upper(ExtAcc);

  if (StaticIP is null or StaticIP = '')
  then
    select IP from P_TSesIP into :IP;
  else
    IP = StaticIP;

  if ((select Result from P_HasNode(:Status,:IpMaskLen,:NodeId,:IP,:LoadSig)) = 0) then
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
        IpMaskLen,
        coalesce(AlteredAt,ChangedAt),
        SigHash,
        LoadSig,
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
          :R_IpMaskLen,
          :R_EditTime,
          :SSgHsh,
          :R_LoadSig,
          :R_PubKey;

    if ((select Result
      from P_CheckNode(1,:NodeId,:Alias,:Acceptor,
        :APort,:APath,:ExtAcc,:ExtPWD,:LoadSig,null,:PubKey,null)) = 0)
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
            from P_TNode where Acceptor = :Acceptor) > 0)
        then
          exit;

        if (exists (select 1 from P_TRegInq where NodeId = :NodeId))
        then
          update P_TRegInq set
              Alias = :Alias,
              Status = :Status,
              Acceptor = :Acceptor,
              IpMaskLen = :IpMaskLen,
              IP = :IP,
              APort = :APort,
              APath = :APath,
              ExtAcc = :ExtAcc,
              ExtPWD = :ExtPWD,
              EditTime = :EditTime,
              LoadSig = :LoadSig,
              PubKey = :PubKey
            where NodeId = :NodeId;
        else
          insert into
            P_TRegInq(
              NodeId,
              Alias,
              Status,
              Acceptor,
              IpMaskLen,
              IP,
              APort,
              APath,
              ExtAcc,
              ExtPWD,
              EditTime,
              LoadSig,
              PubKey)
            values(
              :NodeId,
              :Alias,
              :Status,
              :Acceptor,
              :IpMaskLen,
              :IP,
              :APort,
              :APath,
              :ExtAcc,
              :ExtPWD,
              :EditTime,
              :LoadSig,
              :PubKey);

        execute procedure P_LogMsg(3,0,0,null,'P_RegNode',NodeId,'Registering Node',null);

        if (SigHash is not distinct from SSgHsh) then
        begin
          R_EditTime = null;
          R_LoadSig = null;
          R_PubKey = null;
        end

        when any do
        begin
          Result = 0;
          if (sqlcode <> -803) then
            execute procedure P_LogErr(-15,sqlcode,gdscode,sqlstate,'P_RegNode',NodeId,'Error',null);
        end    
      end
  end
end^
/*-----------------------------------------------------------------------------------------------*/
alter procedure P_Register
as
  declare flag TBoolean;
  declare ATest TBoolean;
  declare TotOk  TCount;
  declare VoteLim TCount;
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

  declare SelfIPML TUInt;

  declare Alias TNdAlias;
  declare Status TNdStatus;
  declare TgNdId TNodeId;

  declare PeerIP TIPV6str;
  declare PeerPort TPort;

  declare A_USR TUserName;
  declare A_PWD TPWD;
  declare A_DB TFullPath;
  
  declare LoadSig TSig;
  declare PubKey TKey;
  declare stm TSysStr512;

  declare SigHash TIntHash;
  declare R_Alias TNdAlias;
  declare R_Status TNdStatus;
  declare R_Acceptor TBoolean;
  declare R_IpMaskLen TUInt;
  declare R_EditTime TTimeMark;
  declare R_LoadSig TSig;
  declare R_PubKey TKey;

begin
  execute procedure P_BegRepl returning_values ATest;
  execute procedure P_LogMsg(4,0,0,null,'P_Register',null,'Start',null);
  execute procedure SYS_DBName returning_values APath;
  select
      NodeId,
      Alias,
      Status,
      Acceptor,
      IpMaskLen,
      StaticIP,
      APort,
      ExtAcc,
      ExtPWD,
      MetaCheckPut,
      LoadSig,
      PubKey,
      coalesce(AlteredAt,ChangedAt)
    from
      P_TParams
    into
      :NodeId,
      :Alias,
      :Status,
      :Acceptor,
      :SelfIPML,
      :StaticIP,
      :APort,
      :ExtAcc,
      :ExtPWD,
      :MtCheck,
      :LoadSig,
      :PubKey,
      :EditTime;
  if (NodeId = '-'
    or ExtAcc = '-'
    or ExtPWD = '-'
    or Char_Length(APort) < 3
    or APath is null or APath = ''
    or LoadSig is null
    or PubKey is null)
  then
    begin
      execute procedure P_LogErr(-16,1,0,null,'P_Register',null,'Incorrect self data',null);
      exit;
    end
  stm = 'execute procedure P_RegNode(?,?,?,?,?,?,?,?,?,?,?,?,?,?)';

  execute procedure P_VoteLim(3,Acceptor) returning_values VoteLim;
  execute procedure P_ResetRegAim(Acceptor);

  for select
      C.NRecId,
      C.NodeId,
      C.SigHash,
      C.Ip,
      C.APort,
      C.ExtAcc,
      C.ExtPWD,
      C.FullPath
    from
      P_NodeList(3,:Acceptor) C
    inner join P_TRegAim
      using(NodeId)
    into
      :NRecId,
      :TgNdId,
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
      execute procedure P_LogErr(-17,0,0,0,'P_IsOnline',TgNdId,null,null);
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
              execute statement
                (stm) (:SigHash,:NodeId,:Alias,:Status,:Acceptor,:SelfIPML,:StaticIP,
                  :APort,:APath,:ExtAcc,:ExtPWD,:EditTime,:LoadSig,:PubKey)
                with autonomous transaction
                on external A_DB as user A_USR password A_PWD
                into
                  :flag,
                  :R_Alias,
                  :R_Status,
                  :R_Acceptor,
                  :R_IpMaskLen,
                  :R_EditTime,
                  :R_LoadSig,
                  :R_PubKey;
              when any do flag = 0;
            end
            if (flag = 1) then
            begin
              TotOk = TotOk + 1;
              execute procedure P_SweepRegAim(TgNdId);

              if (R_EditTime is not null) then
                execute procedure P_CorrNode(
                  NRecId,
                  R_Alias,
                  R_Status,
                  R_Acceptor,
                  R_IpMaskLen,
                  R_EditTime,
                  R_LoadSig,
                  R_PubKey);
              if (TotOk >= VoteLim) then Leave;
            end

            when any do
              execute procedure P_LogErr(-18,sqlcode,gdscode,sqlstate,'P_Register',TgNdId,null,null);
          end
        else
          execute procedure P_BadMeta(NRecId,TgNdId,'P_Register');
      end

  execute procedure P_LogMsg(4,0,0,null,'P_Register',null,'Finish',null);
  if (ATest = 1) then execute procedure P_EndRepl;
  when any do
    execute procedure P_LogErr(-19,sqlcode,gdscode,sqlstate,'P_Register',null,'Error',null);
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
  declare LogId TRef;
  declare RFlt TNdFilter;
  declare OldSid TRef;  
  declare StartSid TRef;
  declare SrcSid TRef;
  declare NewSid TRef;
  declare Proxy TBoolean;
  declare Proxy0 TBoolean;
  declare aFlag TBoolean;
  declare QrmAdmt TBoolean;
  declare Acceptor TBoolean;
  declare Dimmed TBoolean;
  declare HostIP TIPV6str;
  declare IpMaskLen TUInt;
  declare IP TIPV6str;
  declare VtId TNodeId;
  declare NodeId TNodeId;
  declare Alias TNdAlias;
  declare Status TNdStatus;
  declare SelfId TNodeId;
  declare APort TPort;
  declare APath TPath;
  declare ExtAcc TUserName;
  declare ExtPWD TPWD;
  declare EditTime TTimeMark;
  declare LoadSig TSig;
  declare LocalSig TSig;
  declare PubKey TKey;
  declare PeerKey TKey;
--  declare AHash TChHash;
  declare sstm TSysStr64;
  declare stm TSysStr1K;
begin
  Rec_Cnt = 0;
  select NodeId,NDOverlap,NodeListSync from P_TParams into :SelfId,:NDO,:RFlt;

  select NodeId,Acceptor,Proxy,IP,PubKey from P_TNode
    where RecId = :A_RId into :VtId,:aFlag,:Proxy0,:HostIP,:PeerKey;

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

  stm = 'select Sid,NodeId,Alias,Status,Acceptor,IpMaskLen,IP,APort,APath,ExtAcc,ExtPWD,EditTime,LoadSig,'
    || 'LocalSig,PubKey from P_Node where' || sstm || ' Sid > ? order by Sid';

  for execute statement (stm) (:StartSid)
    on external A_SRC as user A_USR password A_PWD
    into
      :SrcSid,
      :NodeId,
      :Alias,
      :Status,
      :Acceptor,
      :IpMaskLen,
      :IP,
      :APort,
      :APath,
      :ExtAcc,
      :ExtPWD,
      :EditTime,
      :LoadSig,
      :LocalSig,
      :PubKey
  do
    if (NodeId <> SelfId
      and (select Result from P_CheckNode(2,:NodeId,:Alias,:Acceptor,
        :APort,:APath,:ExtAcc,:ExtPWD,:LoadSig,:LocalSig,:PubKey,:PeerKey)) = 1)
    then
      begin
        execute procedure SYS_IsSubNet(HostIP,IP,IpMaskLen) returning_values Dimmed;
        if (Dimmed = 1 and Proxy = 0) then Proxy = 1;

        execute procedure P_NodeCacheHit(Acceptor,NodeId) returning_values QrmAdmt;

        LogId = null;
        select RecId from P_TNodeLog where NodeId = :NodeId into :LogId;
        if (LogId is null) then
          insert into
            P_TNodeLog(
              NodeId,
              Alias,
              Status,
              Acceptor,
              Dimmed,
              IpMaskLen,
              IP,
              APort,
              APath,
              ExtAcc,
              ExtPWD,
              EditTime,
              QrmAdmt,
              LoadSig,
              PubKey)
            values(
              :NodeId,
              :Alias,
              :Status,
              :Acceptor,
              :Dimmed,
              :IpMaskLen,
              :IP,
              :APort,
              :APath,
              :ExtAcc,
              :ExtPWD,
              :EditTime,
              :QrmAdmt,
              :LoadSig,
              :PubKey) returning RecId into :LogId;
        NewSid = MaxValue(NewSid,SrcSid);

        if (not exists (select 1 from P_TNDVoter where ParId = :LogId and NodeId = :VtId)) then
          insert into P_TNDVoter(ParId,NodeId,Acceptor) values(:LogId,:VtId,:aFlag);

        when any do
          if (sqlcode not in (-803,-530)) then
            execute procedure P_LogErr(-151,sqlcode,gdscode,sqlstate,'PG_Node',NodeId,'Error',null);
      end
    else
      NewSid = MaxValue(NewSid,SrcSid);

  if (NewSid > OldSid) then execute procedure P_UpdNDid(A_RId,NewSid);
  if (Proxy is distinct from Proxy0) then execute procedure P_UpdProxy(A_RId,Proxy);

  when any do
    execute procedure P_LogErr(-152,sqlcode,gdscode,sqlstate,'PG_Node',NodeId,'Error',null);

end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_FixNodes(A_Acc TBoolean)
as
  declare QA TCount;
  declare QT TCount;

  declare NodeId TNodeId;
  declare Alias TNdAlias;
  declare Status TNdStatus;
  declare Acceptor TBoolean;
  declare Dimmed TBoolean;
  declare IpMaskLen TUInt;
  declare IP TIPV6str;
  declare APort TPort;
  declare APath TPath;
  declare ExtAcc TUserName;
  declare ExtPWD TPWD;
  declare EditTime TTimeMark;
  declare LoadSig TSig;
  declare PubKey TKey;
begin
  if (A_Acc = 1)
  then
    begin
      for select
          NodeId,
          Alias,
          Status,
          Acceptor,
          Dimmed,
          IpMaskLen,
          IP,
          APort,
          APath,
          ExtAcc,
          ExtPWD,
          EditTime,
          LoadSig,
          PubKey
        from
          P_TNodeLog
        order by
          RecId
        into
          :NodeId,
          :Alias,
          :Status,
          :Acceptor,
          :Dimmed,
          :IpMaskLen,
          :IP,
          :APort,
          :APath,
          :ExtAcc,
          :ExtPWD,
          :EditTime,
          :LoadSig,
          :PubKey
      do
        begin
          if (exists (select 1 from P_TNode where NodeId = :NodeId))
          then
            update P_TNode
              set
                Alias = :Alias,
                Status = :Status,
                Acceptor = :Acceptor,
                Dimmed = :Dimmed,
                IpMaskLen = :IpMaskLen,
                IP = :IP,
                APort = :APort,
                APath = :APath,
                ExtAcc = :ExtAcc,
                ExtPWD = :ExtPWD,
                EditTime = :EditTime,
                LoadSig = :LoadSig,
                PubKey = :PubKey
              where NodeId = :NodeId
                and (Alias <> :Alias
                  or Status <> :Status
                  or Acceptor <> :Acceptor
                  or Dimmed <> :Dimmed
                  or IpMaskLen <> :IpMaskLen
                  or IP <> :IP
                  or APort <> :APort
                  or APath <> :APath
                  or ExtAcc <> :ExtAcc
                  or ExtPWD <> :ExtPWD
                  or EditTime <> :EditTime
                  or LoadSig <> :LoadSig
                  or PubKey <> :PubKey);
          else
            insert into
              P_TNode(
                NodeId,
                Alias,
                Status,
                Acceptor,
                Dimmed,
                IpMaskLen,
                IP,
                APort,
                APath,
                ExtAcc,
                ExtPWD,
                EditTime,
                LoadSig,
                PubKey)
              values(
                :NodeId,
                :Alias,
                :Status,
                :Acceptor,
                :Dimmed,
                :IpMaskLen,
                :IP,
                :APort,
                :APath,
                :ExtAcc,
                :ExtPWD,
                :EditTime,
                :LoadSig,
                :PubKey);
          delete from P_TNodeLog where NodeId = :NodeId;      
        end
    end
  else
    begin
      execute procedure P_QuorumAcc(0) returning_values QA;
      execute procedure P_QuorumTot(0) returning_values QT;

      for select
          NodeId,
          Alias,
          Status,
          Acceptor,
          Dimmed,
          IpMaskLen,
          IP,
          APort,
          APath,
          ExtAcc,
          ExtPWD,
          EditTime,
          LoadSig,
          PubKey
        from
          P_NDV
        where VA >= :QA
          or VT >= :QT
        order by
          RecId
        into
          :NodeId,
          :Alias,
          :Status,
          :Acceptor,
          :Dimmed,
          :IpMaskLen,
          :IP,
          :APort,
          :APath,
          :ExtAcc,
          :ExtPWD,
          :EditTime,
          :LoadSig,
          :PubKey
      do
      begin
        if (exists (select 1 from P_TNode where NodeId = :NodeId))
        then
          update P_TNode
            set
              Alias = :Alias,
              Status = :Status,
              Acceptor = :Acceptor,
              Dimmed = :Dimmed,
              IpMaskLen = :IpMaskLen,
              IP = :IP,
              APort = :APort,
              APath = :APath,
              ExtAcc = :ExtAcc,
              ExtPWD = :ExtPWD,
              EditTime = :EditTime,
              LoadSig = :LoadSig,
              PubKey = :PubKey
            where NodeId = :NodeId
              and (Alias <> :Alias
                or Status <> :Status
                or Acceptor <> :Acceptor
                or Dimmed <> :Dimmed
                or IpMaskLen <> :IpMaskLen
                or IP <> :IP
                or APort <> :APort
                or APath <> :APath
                or ExtAcc <> :ExtAcc
                or ExtPWD <> :ExtPWD
                or EditTime <> :EditTime
                or LoadSig <> :LoadSig
                or PubKey <> :PubKey);
        else
          insert into
            P_TNode(
              NodeId,
              Alias,
              Status,
              Acceptor,
              Dimmed,
              IpMaskLen,
              IP,
              APort,
              APath,
              ExtAcc,
              ExtPWD,
              EditTime,
              LoadSig,
              PubKey)
            values(
              :NodeId,
              :Alias,
              :Status,
              :Acceptor,
              :Dimmed,
              :IpMaskLen,
              :IP,
              :APort,
              :APath,
              :ExtAcc,
              :ExtPWD,
              :EditTime,
              :LoadSig,
              :PubKey);
        delete from P_TNodeLog where NodeId = :NodeId;
      end        
    end
  when any do
    execute procedure P_LogErr(-10,sqlcode,gdscode,sqlstate,'P_FixNodes',null,null,null);
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_DoPullData(Acceptor TBoolean, RepKind TRepKind, ProcName TSysStr32)
returns
  (Quorum TCount)
as
  declare flag TBoolean;
  declare PeerRId TRef;
  declare VoteLim TCount;
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
  Quorum = 0;
  Rec_Cnt = 0;
  TM0 = CURRENT_TIMESTAMP;
  select PingCount,MetaCheckGet,TimeSlice from P_TParams into :PingCount,:MtCheck,:TMSlice;
  select HPrime,HCluster from P_TTransponder into :AHash1,:AHash2;
  if (AHash2 is null) then AHash2 = 0;

  execute procedure P_VoteLim(RepKind,Acceptor) returning_values VoteLim;

  for select
      NRecId,
      NodeId,
      SigHash,
      Ip,
      APort,
      ExtAcc,
      ExtPWD,
      FullPath
    from
      P_NodeList(:RepKind,:Acceptor)
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

              Quorum = Quorum + 1;
              if (Quorum >= VoteLim) then Leave;
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

  execute procedure P_LogMsg(8,Quorum,0,null,sn,ProcName,null,null);

  when any do
    execute procedure P_LogErr(-100,sqlcode,gdscode,sqlstate,sn,ProcName,null,null);

end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_PullData
as
  declare QA TCount;
  declare QAcc TBoolean;
  declare flag TBoolean;
  declare Quorum TCount;
  declare Rec_Cnt TCount;
  declare OnLine TBoolean;
  declare Acceptor TBoolean;
  declare NDQuorumAcc TBoolean;
  declare CHQuorumAcc TBoolean;
  declare NdLstCtrl TNdFilter;
begin
  execute procedure P_BegRepl returning_values flag;
  if (flag = 1) then
  begin
    select
        OnLine,
        Acceptor,
        NDQuorumAcc,
        CHQuorumAcc,
        NodeListSync
      from
        P_TParams
      into
        :OnLine,
        :Acceptor,
        :NDQuorumAcc,
        :CHQuorumAcc,
        :NdLstCtrl;

    if (OnLine = 0)
    then
      execute procedure P_LogMsg(7,0,0,null,'P_PullData',null,'DB is Offline',null);
    else
      begin
        execute procedure P_LogMsg(2,0,0,null,'P_PullData',null,'Start',null);

        if (NdLstCtrl > 0) then
        begin
          execute procedure P_DoPullData(Acceptor,0,'PG_Node') returning_values Quorum;
          if (Acceptor = 1 and NDQuorumAcc = 0) then QAcc = 1; else QAcc = 0;
          execute procedure P_FixNodes(QAcc);
        end

        execute procedure P_DoPullData(Acceptor,1,'PG_Chain') returning_values Quorum;
        if (Acceptor = 1 and CHQuorumAcc = 0) then QAcc = 1; else QAcc = 0;
        execute procedure P_FixChain(QAcc) returning_values Rec_Cnt;

        if (Acceptor = 1) then
          execute procedure P_DoPullData(Acceptor,2,'PG_MeltingPot') returning_values Quorum;

/* debug, test for P_TNode concurrent updates
        if (Acceptor = 1) then
          in autonomous transaction do --debug, test for P_TNode concurrent updates
            execute procedure P_DoPullData(Acceptor,2,'PG_MeltingPot') returning_values Quorum;
*/
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
grant execute on procedure P_Handshake to procedure P_Pong;

grant select on P_TParams to procedure P_Ping;
grant execute on procedure Rand32 to procedure P_Ping;
grant execute on procedure P_LogErr to procedure P_Ping;
grant execute on procedure P_NewHShake to procedure P_Ping;
grant execute on procedure P_CheckHShake to procedure P_Ping;

grant all on P_TNode to procedure P_CorrNode;
grant all on P_TRegInq to procedure P_CorrNode;
grant all on P_TNodeLog to procedure P_CorrNode;
grant execute on procedure P_LogErr to procedure P_CorrNode;

grant select on P_TNode to procedure P_HasNode;
grant select on P_TParams to procedure P_HasNode;
grant select on P_TRegInq to procedure P_HasNode;

grant all on P_TRegInq to procedure P_RegNode;
grant select on P_TNode to procedure P_RegNode;
grant select on P_TParams to procedure P_RegNode;
grant execute on procedure P_LogMsg to procedure P_RegNode;
grant execute on procedure P_LogErr to procedure P_RegNode;
grant execute on procedure P_HasNode to procedure P_RegNode;
grant execute on procedure P_CheckNode to procedure P_RegNode;

grant all on P_TRegAim to procedure P_Register;
grant select on P_TParams to procedure P_Register;
grant execute on procedure P_LogMsg to procedure P_Register;
grant execute on procedure P_LogErr to procedure P_Register;
grant execute on procedure P_BadMeta to procedure P_Register;
grant execute on procedure P_BegRepl to procedure P_Register;
grant execute on procedure P_EndRepl to procedure P_Register;
grant execute on procedure P_VoteLim to procedure P_Register;
grant execute on procedure SYS_DBName to procedure P_Register;
grant execute on procedure P_IsOnline to procedure P_Register;
grant execute on procedure P_NodeList to procedure P_Register;
grant execute on procedure P_CorrNode to procedure P_Register;
grant execute on procedure SYS_CheckDB to procedure P_Register;
grant execute on procedure P_SweepRegAim to procedure P_Register;
grant execute on procedure P_ResetRegAim to procedure P_Register;

grant all on P_TNodeLog to procedure PG_Node;
grant all on P_TNDVoter to procedure PG_Node;
grant select on P_TNode to procedure PG_Node;
grant select on P_TParams to procedure PG_Node;
grant select on P_TNDidLog to procedure PG_Node;
grant execute on procedure P_LogErr to procedure PG_Node;
grant execute on procedure P_UpdNDid to procedure PG_Node;
grant execute on procedure P_UpdProxy to procedure PG_Node;
grant execute on procedure P_CheckNode to procedure PG_Node;
grant execute on procedure SYS_IsSubNet to procedure PG_Node;
grant execute on procedure P_NodeCacheHit to procedure PG_Node;

grant select on P_TParams to procedure P_DoPullData;
grant select on P_TTransponder to procedure P_DoPullData;
grant execute on procedure P_Ping to procedure P_DoPullData;
grant execute on procedure P_LogIp to procedure P_DoPullData;
grant execute on procedure P_LogMsg to procedure P_DoPullData;
grant execute on procedure P_LogErr to procedure P_DoPullData;
grant execute on procedure P_ReplMsg to procedure P_DoPullData;
grant execute on procedure P_BadMeta to procedure P_DoPullData;
grant execute on procedure P_VoteLim to procedure P_DoPullData;
grant execute on procedure P_NodeList to procedure P_DoPullData;
grant execute on procedure P_IsOnline to procedure P_DoPullData;
grant execute on procedure SYS_CheckDB to procedure P_DoPullData;

grant execute on procedure PG_Node to procedure P_DoPullData;
grant execute on procedure PG_Chain to procedure P_DoPullData;
grant execute on procedure PG_MeltingPot to procedure P_DoPullData;

grant all on P_TNode to procedure P_FixNodes;
grant select on P_NDV to procedure P_FixNodes;
grant all on P_TNodeLog to procedure P_FixNodes;
grant execute on procedure P_LogErr to procedure P_FixNodes;
grant execute on procedure P_QuorumAcc to procedure P_FixNodes;
grant execute on procedure P_QuorumTot to procedure P_FixNodes;

grant select on P_TParams to procedure P_PullData;
grant execute on procedure P_LogMsg to procedure P_PullData;
grant execute on procedure P_LogErr to procedure P_PullData;
grant execute on procedure P_BegRepl to procedure P_PullData;
grant execute on procedure P_EndRepl to procedure P_PullData;
grant execute on procedure P_FixNodes to procedure P_PullData;
grant execute on procedure P_FixChain to procedure P_PullData;
grant execute on procedure P_QuorumAcc to procedure P_PullData;
grant execute on procedure P_DoPullData to procedure P_PullData;

grant all on P_TBacklog to procedure PG_Chain;
grant all on P_TSMVoter to procedure PG_Chain;
grant select on P_TNode to procedure PG_Chain;
grant select on P_TChain to procedure PG_Chain;
grant select on P_TParams to procedure PG_Chain;
grant execute on procedure P_IsHash to procedure PG_Chain;
grant execute on procedure P_LogErr to procedure PG_Chain;
grant execute on procedure P_BadLcs to procedure PG_Chain;
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
grant execute on procedure P_QuorumAcc to procedure P_FixChain;
grant execute on procedure P_QuorumTot to procedure P_FixChain;

grant all on P_TMPVoter to procedure PG_MeltingPot;
grant select on P_TNode to procedure PG_MeltingPot;
grant select on P_TParams to procedure PG_MeltingPot;
grant select on P_TMPidLog to procedure PG_MeltingPot;
grant all on P_TMeltingPot to procedure PG_MeltingPot;
grant execute on procedure P_IsHash to procedure PG_MeltingPot;
grant execute on procedure P_LogMsg to procedure PG_MeltingPot;
grant execute on procedure P_LogErr to procedure PG_MeltingPot;
grant execute on procedure P_BadLcs to procedure PG_MeltingPot;
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
grant execute on procedure P_QuorumAcc to procedure P_Commit;
grant execute on procedure P_BegCommit to procedure P_Commit;
grant execute on procedure P_EndCommit to procedure P_Commit;
/*-----------------------------------------------------------------------------------------------*/

