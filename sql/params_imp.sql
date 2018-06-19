/* ======================================================================== */
/* PeopleRelay: params_imp.sql Version: 0.4.1.8                             */
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
create procedure P_ExtAccGrant(AUser TSysStr31)
as
begin
  execute procedure SYS_GrantExec('P_Pong',AUser);
  execute procedure SYS_GrantExec('P_RegNode',AUser);
  execute procedure SYS_GrantExec('P_IsBlock',AUser);
  execute procedure SYS_GrantExec('P_HasBlock',AUser);  

  execute procedure SYS_GrantView('P_Node',AUser);
  execute procedure SYS_GrantView('P_Chain',AUser);
  execute procedure SYS_GrantView('P_TMPVoter',AUser);
  execute procedure SYS_GrantView('P_MeltingPot',AUser);

/*  execute procedure P_NewSndAcc(AUser); To allow work as a Sender should be needed. */
end^

/*-----------------------------------------------------------------------------------------------*/
create trigger P_TAU$TParams for P_TParams active after update position 0
as
begin
  if ((select Result from P_IsAlt) = 0) then
  begin
    if (new.ExtAcc is distinct from old.ExtAcc
      or new.ExtPWD is distinct from old.ExtPWD)
    then
      begin
        if (char_length(new.ExtPWD) < 7) then exception P_E$ShortPWD;
        if (new.ExtAcc <> '-'
          and char_length(new.ExtAcc) < 5)
        then
          exception P_E$ShortAcc;

        execute procedure P_EnterExtAcc;

        if (new.ExtAcc is distinct from old.ExtAcc) then
        begin
          execute procedure SYS_DropAcc(old.ExtAcc);
          delete from P_TACL where Name = old.ExtAcc;
        end
        if (new.ExtAcc <> '-') then
        begin
          execute procedure SYS_AltAcc(new.ExtAcc,new.ExtPWD);
          execute procedure P_ExtAccGrant(new.ExtAcc);
          update or insert into P_TACL(Kind,IpCheck,Name) values(4,0,new.ExtAcc) matching(Name);
        end

        execute procedure P_ExitExtAcc;
      end

    insert into
      P_TPrmLog(
        NodeId,
        Alias,
        Status,
        Online,
        Acceptor,
        IpTimeout,
        PingDelay,
        PingCount,
        IpMaskLen,
        StaticIP,
        APort,
        ExtAcc,
        ExtPWD,
        NDOverlap,
        MPOverlap,
        MPTokenBus,
        CHTokenBus,
        SndControl,
        NDQuorumAcc,
        CHQuorumAcc,
        ChckHshCL,
        ChckSigCL,
        ChckHshCH,
        ChckLcsCH,
        ChckSigCH,
        ChckHshMP,
        ChckLcsMP,
        ChckSigMP,
        ChckIdNdAcc,
        ChckIdNdOrd,
        ChckLcsNdAcc,
        ChckLcsNdOrd,
        ChckSigNdAcc,
        ChckSigNdOrd,
        MetaCheckPut,
        MetaCheckGet,
        TimeSlice,
        SyncSpan,
        RLLinger,
        MPQFactor,
        MPLinger,
        DehornPower,
        WaitBackLog,
        PowerOnReset,
        AutoRegister,
        RegisterSpan,
        MaxConnIdl,
        MaxConnAct,
        MaxAgeIdlCn,
        MaxAgeActCn,
        LogBlockChk,
        LogAttErr,
        SndLogMode,
        MsgLogMode,
        RplLogMode,
        ExpelBadLcs,
        ExpelBadMeta,
        ExpelBadHash,
        ExpelBadSign,
        Broadband,
        Handshake,
        NdPubFilter,
        NdRegFilter,
        NodeListSync,
        NdLstSizeAcc,
        NdLstHoldAcc,
        NdLstSizeOrd,
        NdLstHoldOrd,
        NdDelDelayAcc,
        NdDelDelayOrd,
        RateRetro,
        ChkLogSize,
        AttLogSize,
        SysLogSize,
        CtrLogSize,
        NdDataSize,
        RepLogSize,
        SweepSpan,
        LacunaSpan,
        RepairSpan,
        DefAddress,
        DefSenderId,
        SigHash,
        LoadSig,
        PubKey,
        PvtKey,
        AlteredAt,
        ChangedBy,
        ChangedAt)
      values(
        old.NodeId,
        old.Alias,
        old.Status,
        old.Online,
        old.Acceptor,
        old.IpTimeout,
        old.PingDelay,
        old.PingCount,
        old.IpMaskLen,
        old.StaticIP,
        old.APort,
        old.ExtAcc,
        old.ExtPWD,
        old.NDOverlap,
        old.MPOverlap,
        old.MPTokenBus,
        old.CHTokenBus,
        old.SndControl,
        old.NDQuorumAcc,
        old.CHQuorumAcc,
        old.ChckHshCL,
        old.ChckSigCL,
        old.ChckHshCH,
        old.ChckLcsCH,
        old.ChckSigCH,
        old.ChckHshMP,
        old.ChckLcsMP,
        old.ChckSigMP,
        old.ChckIdNdAcc,
        old.ChckIdNdOrd,
        old.ChckLcsNdAcc,
        old.ChckLcsNdOrd,
        old.ChckSigNdAcc,
        old.ChckSigNdOrd,
        old.MetaCheckPut,
        old.MetaCheckGet,
        old.TimeSlice,
        old.SyncSpan,
        old.RLLinger,
        old.MPQFactor,
        old.MPLinger,
        old.DehornPower,
        old.WaitBackLog,
        old.PowerOnReset,
        old.AutoRegister,
        old.RegisterSpan,
        old.MaxConnIdl,
        old.MaxConnAct,
        old.MaxAgeIdlCn,
        old.MaxAgeActCn,
        old.LogBlockChk,
        old.LogAttErr,
        old.SndLogMode,
        old.MsgLogMode,
        old.RplLogMode,
        old.ExpelBadLcs,
        old.ExpelBadMeta,
        old.ExpelBadHash,
        old.ExpelBadSign,
        old.Broadband,
        old.Handshake,
        old.NdPubFilter,
        old.NdRegFilter,
        old.NodeListSync,
        old.NdLstSizeAcc,
        old.NdLstHoldAcc,
        old.NdLstSizeOrd,
        old.NdLstHoldOrd,
        old.NdDelDelayAcc,
        old.NdDelDelayOrd,
        old.RateRetro,
        old.ChkLogSize,
        old.AttLogSize,
        old.SysLogSize,
        old.CtrLogSize,
        old.NdDataSize,
        old.RepLogSize,
        old.SweepSpan,
        old.LacunaSpan,
        old.RepairSpan,
        old.DefAddress,
        old.DefSenderId,
        old.SigHash,
        old.LoadSig,
        old.PubKey,
        old.PvtKey,
        old.AlteredAt,
        old.ChangedBy,
        old.ChangedAt);
  end
end^
/*-----------------------------------------------------------------------------------------------*/
set term ; ^
/*-----------------------------------------------------------------------------------------------*/
grant execute on procedure SYS_GrantExec to procedure P_ExtAccGrant;
grant execute on procedure SYS_GrantView to procedure P_ExtAccGrant;

grant all on P_TACL to trigger P_TAU$TParams;
grant all on P_TPrmLog to trigger P_TAU$TParams;
grant execute on procedure P_IsAlt to trigger P_TAU$TParams;
grant execute on procedure SYS_AltAcc to trigger P_TAU$TParams;
grant execute on procedure SYS_DBOwner to trigger P_TAU$TParams;
grant execute on procedure SYS_DropAcc to trigger P_TAU$TParams;
grant execute on procedure P_ExitExtAcc to trigger P_TAU$TParams;
grant execute on procedure P_EnterExtAcc to trigger P_TAU$TParams;
grant execute on procedure P_ExtAccGrant to trigger P_TAU$TParams;
/*-----------------------------------------------------------------------------------------------*/
