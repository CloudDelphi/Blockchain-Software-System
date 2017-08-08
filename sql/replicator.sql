/* ************************************************************************ */
/* PeopleRelay: replicator.sql Version: see version.sql                     */
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
set term ^ ;
/*-----------------------------------------------------------------------------------------------*/
create procedure P_Echo(r TInt32)
returns
  (Result TInt32,
   AHash1 TIntHash, --Prime
   AHash2 TIntHash, --Cluster
   AHash3 TIntHash, --LoadSig
   NdTime TTimeMark)
as
begin
  Result = r;
  select HPrime,HCluster from P_TTransponder into :AHash1,:AHash2;
  select SigHash from P_TParams into :AHash3;
  if (AHash2 is null) then AHash2 = 0;
  NdTime = 'Now';

/*
TO DO: Sybil attack prevention
--execute procedure P_CalcSig(AHash,new.PvtKey) returning_values new.LoadSig;
*/
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_Ping(
  Cnt TUInt1,
  AHash1 TIntHash, --Prime
  AHash2 TIntHash, --Cluster
  AHash3 TIntHash, --LoadSig
  DB TFullPath,
  Usr TUserName,
  PWD TPWD,
  NodeId TNodeId)
returns(
  Result TBoolean,
  SDelay TTimeGap,
  NdTime TTimeMark)
as
  declare r TInt32;
  declare rr TInt32;
  declare n SmallInt;
  declare stm TSysStr64;
  declare Time1 TTimeMark;
  declare Time2 TTimeMark;
  declare AHash11 TIntHash; --Prime
  declare AHash22 TIntHash; --Cluster
  declare AHash33 TIntHash; --LoadSig
begin
  n = 0;
  Result = 0;
  SDelay = 0;
  stm = 'execute procedure P_Echo(?)';
  while (n < Cnt) do
  begin
    rr = -1;
    n = n + 1;
    execute procedure Rand32(10000000) returning_values r;
    Time1 = 'Now';
    execute statement
      (stm) (:r)
      with autonomous transaction        
      on external DB as user Usr password PWD
      into :rr,:AHash11,:AHash22,:AHash33,:NdTime;
    Time2 = 'Now';  
    if (rr <> r) then
    begin
      Result = 0;
      execute procedure P_LogErr(-7,r,rr,null,'P_Ping',NodeId,'Rand Distortion',null);
      exit;
    end

    if (AHash33 <> AHash3
      and (select ChckSigNdPng from P_TParams) = 1)
    then
      begin
        Result = 0;
        execute procedure P_LogErr(-7,0,0,null,'P_Ping',NodeId,'Hash Distortion',null);
        exit;
      end

    if (AHash11 <> AHash1) then
    begin
      Result = 0;
      execute procedure P_LogErr(-7,r,rr,null,'P_Ping',NodeId,'Unknown Node Prime',null);
      exit;
    end
    if (AHash22 <> AHash2
      and not (AHash22 = 0 or AHash2 = 0))
    then
      begin
        Result = 0;
        execute procedure P_LogErr(-7,r,rr,null,'P_Ping',NodeId,'Unknown Node Cluster',null);
        exit;
      end
    Result = 1;
    SDelay = SDelay + datediff(second, Time1, Time2);
  end
  SDelay = SDelay / Cnt;
  when any do
  begin
    Result = 0;
    execute procedure P_LogErr(-7,sqlcode,gdscode,sqlstate,'P_Ping',NodeId,'Error:',null);
  end
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_HasNode(Status TNdStatus, NodeId TNodeId, LoadSig TSig)
returns
  (Result TBoolean)
as
begin
  if (exists (select 1 from P_TParams where NodeId = :NodeId)
    or exists (select 1 from P_TRegLog1 where NodeId = :NodeId)
    or exists (select 1 from P_TNode
      where NodeId = :NodeId
        and LoadSig = :LoadSig
        and Status = :Status))
  then
    Result = 1;
  suspend;  
end^
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
  AUser TUserName,
  APWD TPWD,
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
  declare ATest TBoolean;
  declare ChckAcc TBoolean;
  declare ChckOrd TBoolean;
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
  APort = Upper(APort);
  APath = Upper(APath);
  AUser = Upper(AUser);
  NodeId = Upper(NodeId);
  if ((select Result from P_HasNode(:Status,:NodeId,:LoadSig)) = 0) then
  begin
    select
        NdRegFilter,
        NdLstSizeAcc,
        NdLstHoldAcc,
        NdLstSizeOrd,
        NdLstHoldOrd,
        ChckSigNdAcc,
        ChckSigNdOrd,
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
          :ChckAcc,
          :ChckOrd,
          :R_Alias,
          :R_Status,
          :R_Acceptor,
          :R_IpMaskLen,
          :R_EditTime,
          :SSgHsh,
          :R_LoadSig,
          :R_PubKey;

    if ((Acceptor = 1 and ChckAcc = 1) or (Acceptor = 0 and ChckOrd = 1)) then
    begin
      execute procedure P_GetNodeHash(NodeId,Alias,Acceptor,APort,AUser,APWD) returning_values AHash;
      execute procedure P_IsSigValid(AHash,LoadSig,PubKey) returning_values ATest;
      if (ATest = 0) then
      begin
        Result = 0;
        execute procedure P_LogErr(-15,0,0,0,'P_RegNode',NodeId,'Bad Signature',null);
        exit;
      end
    end
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

        if (StaticIP is null or StaticIP = '')
        then
          select IP from P_TSesIP into :IP;
        else
          IP = StaticIP;

        if (exists (select 1 from P_TRegLog1 where NodeId = :NodeId))
        then
          update P_TRegLog1 set
              Alias = :Alias,
              Status = :Status,
              Acceptor = :Acceptor,
              IpMaskLen = :IpMaskLen,
              IP = :IP,
              APort = :APort,
              APath = :APath,
              AUser = :AUser,
              APWD = :APWD,
              EditTime = :EditTime,
              LoadSig = :LoadSig,
              PubKey = :PubKey
            where NodeId = :NodeId;
        else
          insert into
            P_TRegLog1(
              NodeId,
              Alias,
              Status,
              Acceptor,
              IpMaskLen,
              IP,
              APort,
              APath,
              AUser,
              APWD,
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
              :AUser,
              :APWD,
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
  declare AUser TUserName;
  declare APWD TPWD;
  declare NodeId TNodeId;

  declare SelfIPML TUInt;

  declare Alias TNdAlias;
  declare Status TNdStatus;
  declare TgNdId TNodeId;

  declare PeerIP TIPV6str;
  declare PeerPort TPort;

  declare Usr TUserName;
  declare PWD TPWD;
  declare DB TFullPath;
  
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
      :AUser,
      :APWD,
      :MtCheck,
      :LoadSig,
      :PubKey,
      :EditTime;
  if (NodeId is null or NodeId = ''
    or APort is null or APort = ''
    or APath is null or APath = ''
    or AUser is null or AUser = ''
    or APWD is null or APWD = ''
    or LoadSig is null
    or PubKey is null)
  then
    begin
      execute procedure P_LogErr(-16,1,0,null,'P_Register',null,'Incorrect self data',null);
      exit;
    end
  stm = 'execute procedure P_RegNode(?,?,?,?,?,?,?,?,?,?,?,?,?,?)';
  execute procedure P_FillNodeCahe(3,Acceptor) returning_values VoteLim;
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
      P_NodeCahe C
    where not exists
      (select 1 from P_TRegLog2 L where L.NodeId = C.NodeId)
    into
      :NRecId,
      :TgNdId,
      :SigHash,
      :PeerIp,
      :PeerPort,
      :Usr,
      :PWD,
      :DB
  do
    if ((select Result
      from P_IsOnline(:PeerIP,:PeerPort)) = 0)
    then
      execute procedure P_DecRate(NRecId);
    else
      begin
        if (MtCheck = 1)
        then
          execute procedure SYS_CheckDB(DB,AUser,APWD) returning_values ChkRslt;
        else
          ChkRslt = 1;
        if (ChkRslt = 1)
        then
          begin
            begin
              execute statement
                (stm) (:SigHash,:NodeId,:Alias,:Status,:Acceptor,:SelfIPML,:StaticIP,
                  :APort,:APath,:AUser,:APWD,:EditTime,:LoadSig,:PubKey)
                with autonomous transaction
                on external DB as user Usr password PWD
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
              execute procedure P_UpdateRL2(TgNdId);
              execute procedure P_IncRate(NRecId);

              if (R_EditTime is not null) then
                execute procedure P_CorrNode(NRecId,R_Alias,R_Status,
                  R_Acceptor,R_IpMaskLen,R_EditTime,R_LoadSig,R_PubKey);

              if (TotOk >= VoteLim) then Leave;
            end

            when any do
            begin
              execute procedure P_DecRate(NRecId);
              execute procedure P_LogErr(-17,sqlcode,gdscode,sqlstate,'P_Register',TgNdId,null,null);
            end
          end
        else
          if (ChkRslt = 0)
          then
            begin
              execute procedure P_BadMeta(NRecId);
              execute procedure P_LogErr(-18,0,0,null,'P_Register',TgNdId,'Metadata corrupt',null);
            end
          else
            execute procedure P_DecRate(NRecId);
      end
  execute procedure P_LogMsg(4,0,0,null,'P_Register',null,'Finish',null);
  if (ATest = 1) then execute procedure P_EndRepl;
  when any do
    execute procedure P_LogErr(-19,sqlcode,gdscode,sqlstate,'P_Register',null,'Error',null);
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure PG_Node(
  A_RId TRef,
  A_SRC TFullPath,
  A_USR TPWD,
  A_PWD TUserName)
returns
  (Rec_Cnt TCount)
as
  declare TMO Float;
  declare LogId TRef;
  declare RFlt TNdFilter;
  declare NdId TRef;
  declare SrcRId TRef;
  declare MaxNdId TRef;
  declare Proxy TBoolean;
  declare aFlag TBoolean;
  declare ATest TBoolean;
  declare ChckAcc TBoolean;
  declare ChckOrd TBoolean;
  declare Acceptor TBoolean;
  declare Dimmed TBoolean;
  declare ReplTM TTimeMark;

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
  declare AUser TUserName;
  declare APWD TPWD;
  declare EditTime TTimeMark;
  declare LoadSig TSig;
  declare PubKey TKey;
  declare AHash TChHash;
  declare sstm TSysStr64;
  declare stm TSysStr1K;
begin
  Rec_Cnt = 0;
  MaxNdId = 0;
  select NodeId,(TMOverlap / 1440.000000),NodeListSync,ChckSigNdAcc,ChckSigNdOrd
    from P_TParams into :SelfId,:TMO,:RFlt,:ChckAcc,:ChckOrd;

  select NodeId,Acceptor,(ReplTime - :TMO),NdId,IP from P_TNode
    where RecId = :A_RId into :VtId,:aFlag,:ReplTM,:NdId,:HostIP;

  if (RFlt = 1)
  then
    sstm = ' and Acceptor = 1';
  else
    if (RFlt = 2)
    then
      sstm = ' and Acceptor = 0';
    else
      sstm = '';

  stm = 'select RecId,NodeId,Alias,Status,Acceptor,IpMaskLen,IP,APort,APath,ExtAcc,ExtPWD,EditTime,LoadSig,PubKey '
    || 'from P_Node where Enabled = 1' || sstm || ' and (RecId > ? or EditTime >= ?)';

  for execute statement (stm) (:NdId,:ReplTM)
    on external A_SRC as user A_USR password A_PWD
    into
      :SrcRId,
      :NodeId,
      :Alias,
      :Status,
      :Acceptor,
      :IpMaskLen,
      :IP,
      :APort,
      :APath,
      :AUser,
      :APWD,
      :EditTime,
      :LoadSig,
      :PubKey
  do
    if (NodeId <> SelfId)
    then
      begin
        if ((Acceptor = 1 and ChckAcc = 1) or (Acceptor = 0 and ChckOrd = 1)) then
        begin
          execute procedure P_GetNodeHash(NodeId,Alias,Acceptor,APort,AUser,APWD) returning_values AHash;
          execute procedure P_IsSigValid(AHash,LoadSig,PubKey) returning_values ATest;
          if (ATest = 0) then
          begin
            execute procedure P_LogErr(-150,0,0,0,'PG_Node',NodeId,'Bad Signature',null);
            exit;
          end
        end

        execute procedure SYS_IsSubNet(HostIP,IP,IpMaskLen) returning_values Dimmed;
        if (Dimmed = 1 and Proxy = 0) then Proxy = 1;

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
              AUser,
              APWD,
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
              :AUser,
              :APWD,
              :EditTime,
              :LoadSig,
              :PubKey) returning RecId into :LogId;
        MaxNdId = MaxValue(MaxNdId,SrcRId);

        if (not exists (select 1 from P_TNDVoter where ParId = :LogId and NodeId = :VtId)) then
          insert into P_TNDVoter(ParId,NodeId,Acceptor) values(:LogId,:VtId,:aFlag);

        when any do
          if (sqlcode not in (-803,-530)) then
            execute procedure P_LogErr(-151,sqlcode,gdscode,sqlstate,'PG_Node',NodeId,'Error',null);
      end
    else
      MaxNdId = MaxValue(MaxNdId,SrcRId);
      
  execute procedure P_UpdNodeRec(A_RId,MaxNdId,NdId,Proxy);

  when any do
    execute procedure P_LogErr(-152,sqlcode,gdscode,sqlstate,'PG_Node',NodeId,'Error',null);

end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_FixNodes(A_Acc TBoolean)
as
  declare QA TCount;
  declare QT TCount;
begin
  if (A_Acc = 1)
  then
    begin
      merge into P_TNode N
        using (select * from P_TNodeLog where State = 0) L
          on N.NodeId = L.NodeId
        when matched then
          update set
            N.Alias = L.Alias,
            N.Status = L.Status,
            N.Acceptor = L.Acceptor,
            N.Dimmed = L.Dimmed,
            N.IpMaskLen = L.IpMaskLen,
            N.IP = L.IP,
            N.APort = L.APort,
            N.APath = L.APath,
            N.ExtAcc = L.AUser,
            N.ExtPWD = L.APWD,
            N.EditTime = L.EditTime,
            N.LoadSig = L.LoadSig,
            N.PubKey = L.PubKey
        when not matched then
          insert (N.NodeId,N.Alias,N.Status,N.Acceptor,N.Dimmed,N.IpMaskLen,N.IP,N.APort,N.APath,N.ExtAcc,N.ExtPWD,N.EditTime,N.LoadSig,N.PubKey)
            values (L.NodeId,L.Alias,L.Status,L.Acceptor,L.Dimmed,L.IpMaskLen,L.IP,L.APort,L.APath,L.AUser,L.APWD,L.EditTime,L.LoadSig,L.PubKey);
      update P_TNodeLog L set State = 1 where State = 0;
    end
  else
    begin
      execute procedure P_QuorumAcc(0) returning_values QA;
      execute procedure P_QuorumTot(0) returning_values QT;
      merge into P_TNode N
        using (select * from P_NDV where ACnt >= :QA or Voters >= :QT) L
          on N.NodeId = L.NodeId
        when matched then
          update set
            N.Alias = L.Alias,
            N.Status = L.Status,
            N.Acceptor = L.Acceptor,
            N.Dimmed = L.Dimmed,
            N.IpMaskLen = L.IpMaskLen,
            N.IP = L.IP,
            N.APort = L.APort,
            N.APath = L.APath,
            N.ExtAcc = L.AUser,
            N.ExtPWD = L.APWD,
            N.EditTime = L.EditTime,
            N.LoadSig = L.LoadSig,
            N.PubKey = L.PubKey
        when not matched then
          insert (N.NodeId,N.Alias,N.Status,N.Acceptor,N.Dimmed,N.IpMaskLen,N.IP,N.APort,N.APath,N.ExtAcc,N.ExtPWD,N.EditTime,N.LoadSig,N.PubKey)
            values (L.NodeId,L.Alias,L.Status,L.Acceptor,L.Dimmed,L.IpMaskLen,L.IP,L.APort,L.APath,L.AUser,L.APWD,L.EditTime,L.LoadSig,L.PubKey);

      update P_TNodeLog L set State = 1 where exists (select 1 from P_NDV V
        where V.RecId = L.RecId and (V.ACnt >= :QA or V.Voters >= :QT));

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
  declare NodeRId TRef;
  declare VoteLim TCount;
  declare AHash1 TIntHash;
  declare AHash2 TIntHash;
  declare AHash3 TIntHash;
  declare Rec_Cnt TCount;
  declare TMSlice TInt32;
  declare ChkRslt TTrilean;
  declare PingCount TUInt1;
  declare MtCheck TBoolean;
  declare PingDelay SmallInt;
  declare TM0 TTimeMark;
  declare StartTM TTimeMark;
  declare PeerIP TIPV6str;
  declare PeerPort TPort;
  declare APWD TPWD;
  declare AUser TUserName;
  declare FullPath TFullPath;
  declare SDelay TTimeGap;
  declare NdTime TTimeMark;
  declare NodeId TNodeId;
begin
  Quorum = 0;
  Rec_Cnt = 0;
  TM0 = CURRENT_TIMESTAMP;
  select PingDelay,PingCount,MetaCheckGet,TimeSlice
    from P_TParams into :PingDelay,:PingCount,:MtCheck,:TMSlice;
  select HPrime,HCluster from P_TTransponder into :AHash1,:AHash2;
  if (AHash2 is null) then AHash2 = 0;
  execute procedure P_FillNodeCahe(RepKind,Acceptor) returning_values VoteLim;
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
      P_NodeCahe
    into
      :NodeRId,
      :NodeId,
      :AHash3,
      :PeerIp,
      :PeerPort,
      :AUser,
      :APWD,
      :FullPath
  do
    if ((select Result
      from P_IsOnline(:PeerIP,:PeerPort)) = 0)
    then
      execute procedure P_DecRate(NodeRId);
    else
      begin
        execute procedure P_Ping(PingCount,AHash1,AHash2,AHash3,FullPath,AUser,APWD,NodeId)
          returning_values flag,SDelay,NdTime;
        if (flag = 0)
        then
          begin
            execute procedure P_DecRate(NodeRId);
            execute procedure P_LogErr(-101,RepKind,NodeRId,null,ProcName,NodeId,'Ping error',null);
          end
        else
          if (SDelay > PingDelay)
          then
            begin
              execute procedure P_DecRate(NodeRId);
              execute procedure P_LogErr(-102,RepKind,NodeRId,null,ProcName,NodeId,'Ping timeout',null);
            end
          else
            begin
              if (MtCheck = 1)
              then
                execute procedure SYS_CheckDB(FullPath,AUser,APWD) returning_values ChkRslt;
              else
                ChkRslt = 1;

              if (ChkRslt = 1)
              then
                begin
                  execute procedure P_UpdTMOffset(NodeRId,NdTime);
                  StartTM = 'Now';

                  if (RepKind = 0)
                  then
                    execute procedure PG_Node(NodeRId,FullPath,AUser,APWD) returning_values Rec_Cnt;
                  else
                    if (RepKind = 1)
                    then
                      execute procedure PG_Chain(NodeRId,FullPath,AUser,APWD) returning_values Rec_Cnt;
                    else
                      execute procedure PG_MeltingPot(NodeRId,FullPath,AUser,APWD) returning_values Rec_Cnt;
                  execute procedure P_ReplMsg(NodeRId,RepKind,Rec_Cnt,StartTM,0,null);
                  execute procedure P_IncRate(NodeRId);
                  execute procedure P_UpdReplTime(NodeRId,NdTime);
                  Quorum = Quorum + 1;
                  if (Quorum >= VoteLim) then Leave;
                  when any do
                  begin
                    execute procedure P_DecRate(NodeRId);
                    execute procedure P_LogErr(-11,sqlcode,gdscode,sqlstate,ProcName,NodeId,null,null);
                  end
                end
              else
                if (ChkRslt = 0)
                then
                  begin
                    execute procedure P_BadMeta(NodeRId);
                    execute procedure P_LogErr(-101,RepKind,NodeRId,null,ProcName,NodeId,'Metadata corrupt',null);
                  end
                else
                  execute procedure P_DecRate(NodeRId);
            end
        if(TMSlice > 0
          and datediff(minute,TM0,cast('Now' as TimeStamp)) > TMSlice)
        then
          begin
            execute procedure P_LogErr(-12,RepKind,Rec_Cnt,null,ProcName,NodeId,'Long duration',null);
            Leave;
          end

        when any do
          execute procedure P_LogErr(-100,sqlcode,gdscode,sqlstate,'P_DoPullData',NodeId,ProcName,null);
      end

  execute procedure P_LogMsg(8,Quorum,0,null,ProcName,null,'Round trip',null);
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

--        if (Acceptor = 1 and Rec_Cnt >= 0) then
        if (Acceptor = 1) then
        begin
          execute procedure P_DoPullData(Acceptor,2,'PG_MeltingPot') returning_values Quorum;
          update P_TMeltingPot set Loop = Loop + 1;
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
grant select on P_TParams to procedure P_Echo;
grant select on P_TTransponder to procedure P_Echo;

grant select on P_TParams to procedure P_Ping;
grant execute on procedure Rand32 to procedure P_Ping;
grant execute on procedure P_LogErr to procedure P_Ping;

grant select on P_TNode to procedure P_HasNode;
grant select on P_TParams to procedure P_HasNode;
grant select on P_TRegLog1 to procedure P_HasNode;

grant all on P_TRegLog1 to procedure P_RegNode;
grant select on P_TNode to procedure P_RegNode;
grant select on P_TParams to procedure P_RegNode;
grant execute on procedure P_LogMsg to procedure P_RegNode;
grant execute on procedure P_LogErr to procedure P_RegNode;
grant execute on procedure P_HasNode to procedure P_RegNode;
grant execute on procedure P_IsSigValid to procedure P_RegNode;
grant execute on procedure P_GetNodeHash to procedure P_RegNode;

grant all on P_TRegLog2 to procedure P_Register;
grant select on P_TParams to procedure P_Register;
grant execute on procedure P_LogMsg to procedure P_Register;
grant execute on procedure P_LogErr to procedure P_Register;
grant execute on procedure SYS_DBName to procedure P_Register;
grant execute on procedure P_IncRate to procedure P_Register;
grant execute on procedure P_DecRate to procedure P_Register;
grant execute on procedure P_BadMeta to procedure P_Register;
grant execute on procedure P_BegRepl to procedure P_Register;
grant execute on procedure P_EndRepl to procedure P_Register;
grant execute on procedure P_IsOnline to procedure P_Register;
grant execute on procedure SYS_CheckDB to procedure P_Register;
grant execute on procedure P_CorrNode to procedure P_Register;
grant execute on procedure P_UpdateRL2 to procedure P_Register;
grant execute on procedure P_FillNodeCahe to procedure P_Register;

grant all on P_TNodeLog to procedure PG_Node;
grant all on P_TNDVoter to procedure PG_Node;
grant select on P_TNode to procedure PG_Node;
grant select on P_TParams to procedure PG_Node;
grant execute on procedure P_LogErr to procedure PG_Node;
grant execute on procedure SYS_IsSubNet to procedure PG_Node;
grant execute on procedure P_IsSigValid to procedure PG_Node;
grant execute on procedure P_UpdNodeRec to procedure PG_Node;
grant execute on procedure P_GetNodeHash to procedure PG_Node;

grant select on P_TParams to procedure P_DoPullData;
grant select on P_TTransponder to procedure P_DoPullData;
grant execute on procedure P_Ping to procedure P_DoPullData;
grant execute on procedure P_LogMsg to procedure P_DoPullData;
grant execute on procedure P_LogErr to procedure P_DoPullData;
grant execute on procedure P_IncRate to procedure P_DoPullData;
grant execute on procedure P_DecRate to procedure P_DoPullData;
grant execute on procedure P_ReplMsg to procedure P_DoPullData;
grant execute on procedure P_BadMeta to procedure P_DoPullData;
grant execute on procedure SYS_CheckDB to procedure P_DoPullData;
grant execute on procedure P_IsOnline to procedure P_DoPullData;
grant execute on procedure P_UpdTMOffset to procedure P_DoPullData;
grant execute on procedure P_UpdReplTime to procedure P_DoPullData;
grant execute on procedure P_FillNodeCahe to procedure P_DoPullData;

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
grant all on P_TMeltingPot to procedure P_PullData;
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
grant execute on procedure P_LogErr to procedure PG_Chain;
grant execute on procedure P_BadHash to procedure PG_Chain;
grant execute on procedure P_CalcHash to procedure PG_Chain;
grant execute on procedure P_IsSigValid to procedure PG_Chain;

grant all on P_TChain to procedure P_FixChain;
grant all on P_TBacklog to procedure P_FixChain;
grant select on P_TParams to procedure P_FixChain;
grant execute on procedure P_Dehorn to procedure P_FixChain;
grant execute on procedure P_LogErr to procedure P_FixChain;
grant execute on procedure P_QuorumAcc to procedure P_FixChain;
grant execute on procedure P_QuorumTot to procedure P_FixChain;

grant all on P_TMPVoter to procedure PG_MeltingPot;
grant select on P_TNode to procedure PG_MeltingPot;
grant select on P_TParams to procedure PG_MeltingPot;
grant all on P_TMeltingPot to procedure PG_MeltingPot;
grant execute on procedure P_LogErr to procedure PG_MeltingPot;
grant execute on procedure P_BadHash to procedure PG_MeltingPot;
grant execute on procedure P_UpdMPId to procedure PG_MeltingPot;
grant execute on procedure P_CalcHash to procedure PG_MeltingPot;
grant execute on procedure P_IsSigValid to procedure PG_MeltingPot;

grant select on P_TChain to procedure P_RevertBlock;
grant all on P_TMeltingPot to procedure P_RevertBlock;
grant execute on procedure P_LogErr to procedure P_RevertBlock;
grant execute on procedure P_BegAddB to procedure P_RevertBlock;
grant execute on procedure P_EndAddB to procedure P_RevertBlock;

grant all on P_TChain to procedure P_Commit;
grant select on P_TNode to procedure P_Commit;
grant select on P_TParams to procedure P_Commit;
grant select on P_TBackLog to procedure P_Commit;
grant all on P_TMeltingPot to procedure P_Commit;
grant execute on procedure P_LogMsg to procedure P_Commit;
grant execute on procedure P_LogErr to procedure P_Commit;
grant execute on procedure P_QuorumAcc to procedure P_Commit;
grant execute on procedure P_BegCommit to procedure P_Commit;
grant execute on procedure P_EndCommit to procedure P_Commit;

/*-----------------------------------------------------------------------------------------------*/


