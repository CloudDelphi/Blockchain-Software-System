/* ======================================================================== */
/* PeopleRelay: sync.sql Version: 0.4.1.8                                   */
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
create table P_TSyncTest(N BigInt);
insert into P_TSyncTest(N) values(0);
/*-----------------------------------------------------------------------------------------------*/
set term ^ ;
/*-----------------------------------------------------------------------------------------------*/
create procedure P_Lock
returns
  (Result TBoolean)
as
begin
  begin
    update P_TSyncTest set N = N + 1;
    Result = 1;
    when any do Result = 0;
  end
  suspend;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_BeginSync
returns
  (Mutex BigInt)
as
  declare Dummy TBoolean;
  declare MName TSysStr128;
begin
  select 'P_' || Hash(NodeId) || '_' || Hash(Alias) from P_TParams into :MName;
  /* Cannot use a NodeId as is because of an inadmissible characters. */
  Mutex = GetMutex(MName,100);
  if (Mutex > 0) then
    execute procedure P_SetSesFlag(700,Mutex) returning_values Dummy;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_FinishSync(Mutex BigInt)
as
  declare Dummy Integer;
begin
  if (Mutex > 0) then Dummy = FreeMutex(Mutex);
  execute procedure P_DelSesFlag(700);
  when any do exit;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_TryEndSync
as
  declare R TBoolean;
  declare Mtx Integer;
  declare TVal TTimeMark;
begin
  execute procedure P_GetSesFlag(700) returning_values R,Mtx,TVal;
  if (R > 0) then execute procedure P_FinishSync(Mtx);
  when any do exit;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_IsNewDay
returns
  (Mutex BigInt)
as
  declare t BigInt;
begin
  Mutex = 0;
  execute procedure SYS_UnixDays returning_values t;
  t = t - Gen_Id(P_G$DTM,0);
  if (Abs(t) > 0) then
  begin
    execute procedure P_BeginSync returning_values Mutex;
    if (Mutex > 0) then t = Gen_Id(P_G$DTM,t);
  end
  when any do
    if (Mutex > 0) then
    begin
      execute procedure P_FinishSync(Mutex);
      Mutex = 0;
    end
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_IsNewHour
returns
  (Result TBoolean)
as
  declare h THour;
  declare h0 THour;
begin
  h0 = Gen_Id(P_G$HTM,0);
  h = extract(HOUR from CURRENT_TIMESTAMP);
  if (h <> h0) then
  begin
    h = Gen_Id(P_G$HTM,h - h0);
    Result = 1;
  end
  suspend;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_ClearWorkLogs
as
begin
  exit;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_HourJob
as
begin
  exit;
/*
  execute procedure P_LogMsg(501,0,0,null,'P_HourJob',null,'Start',null);
  execute procedure P_ClearWorkLogs;
  execute procedure P_LogMsg(502,0,0,null,'P_HourJob',null,'Finish',null);
*/
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_CanRunRepair
returns
  (Result TBoolean)
as
  declare rs TUInt;
begin
  select RepairSpan from P_TParams into :rs;
  if (rs > 0 and Mod(Gen_Id(P_G$RTT,0),rs) = 0) then Result = 1;
  suspend;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_DoSync
as
  declare s TSysStr16;
begin
  s = 'P_DoSync';

  begin
    if ((select Result from P_IsNewHour) = 1) then execute procedure P_HourJob;
    when any do
      execute procedure P_LogErr(-91,sqlcode,gdscode,sqlstate,s,null,'P_HourJob',null);
  end

  begin
    execute procedure P_FixReg;
    when any do
      execute procedure P_LogErr(-92,sqlcode,gdscode,sqlstate,s,null,'P_FixReg',null);
  end

  begin
    execute procedure P_CheckPOR;
    when any do
      execute procedure P_LogErr(-93,sqlcode,gdscode,sqlstate,s,null,'P_CheckPOR',null);
  end

  begin
    execute procedure P_ClearLogs;
    when any do
      execute procedure P_LogErr(-94,sqlcode,gdscode,sqlstate,s,null,'P_ClearLogs',null);
  end

  if ((select Result from P_CanRunRepair) = 1) then
  begin
    execute procedure P_Repair(0,0);
    when any do
      execute procedure P_LogErr(-95,sqlcode,gdscode,sqlstate,s,null,'P_Repair',null);
  end

  begin
    execute procedure P_PullData;
    when any do
      execute procedure P_LogErr(-96,sqlcode,gdscode,sqlstate,s,null,'P_PullData',null);
  end

  begin
    execute procedure P_Commit;
    when any do
      execute procedure P_LogErr(-97,sqlcode,gdscode,sqlstate,s,null,'P_Commit',null);
  end
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_Sync
as
  declare Mutex BigInt;
begin
  Mutex = 0;
  if ((select Result from P_IsSyncBot) = 0)
  then
    execute procedure P_LogErr(-6,0,0,null,'P_Sync',null,'Account is not registered as a Sync Bot.',null);
  else
    if ((select Result from P_IsSyncSpan) = 1)
    then
      begin
        execute procedure P_BeginSync returning_values Mutex;
        if (Mutex > 0) then
        begin
          if ((select Result from P_Lock) = 1) then
          begin
            execute procedure P_LogMsg(701,0,0,null,'P_Sync',null,'Start',null);
            execute procedure P_DoSync;
            execute procedure P_RoundTrip;
            execute procedure P_LogMsg(702,0,0,null,'P_Sync',null,'Finish',null);
          end
          execute procedure P_FinishSync(Mutex);
        end
      end
  when any do
  begin
    if (Mutex > 0) then execute procedure P_FinishSync(Mutex);
    execute procedure P_LogErr(-90,sqlcode,gdscode,sqlstate,'P_Sync',null,'Error',null);
    when any do exit;
  end  
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_ClearAuxLogs
as
  declare RecCnt TCount;
  declare ChkLogSize TCount;
  declare AttLogSize TCount;
  declare SysLogSize TCount;
  declare CtrLogSize TCount;
begin
  select
      ChkLogSize,
      AttLogSize,
      SysLogSize,
      CtrLogSize
    from
      P_TParams
    into
      :ChkLogSize,
      :AttLogSize,
      :SysLogSize,
      :CtrLogSize;
  begin
    select count(*) from P_TChecks into :RecCnt;
    if (RecCnt > ChkLogSize) then
      delete from P_TChecks
        order by RecId
        rows (:RecCnt - :ChkLogSize);
    when any do
      execute procedure P_LogErr(-4,sqlcode,gdscode,sqlstate,'P_ClearAuxLogs','P_TChecks',null,null);
  end
  begin
    select count(*) from P_TDBLog into :RecCnt;
    if (RecCnt > AttLogSize) then
      delete from P_TDBLog
        order by RecId
        rows (:RecCnt - :AttLogSize);
    when any do
      execute procedure P_LogErr(-4,sqlcode,gdscode,sqlstate,'P_ClearAuxLogs','P_TDBLog',null,null);
  end
  begin
    select count(*) from P_TLog into :RecCnt;
    if (RecCnt > SysLogSize) then
      delete from P_TLog
        order by RecId
        rows (:RecCnt - :SysLogSize);
    when any do exit;
  end
  begin
    select count(*) from P_TIpLog into :RecCnt;
    if (RecCnt > CtrLogSize) then
      delete from P_TIpLog
        order by RecId
        rows (:RecCnt - :CtrLogSize);
    when any do
      execute procedure P_LogErr(-4,sqlcode,gdscode,sqlstate,'P_ClearAuxLogs','P_TIpLog',null,null);
  end
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_DoDailyJob
as
begin
  execute procedure P_EnterDJ;
  execute procedure P_Sweep;
  execute procedure P_ClearReplLog;  
  execute procedure P_ClearAuxLogs;
  execute procedure P_ClearNodeList;
  execute procedure P_ExitDJ;
  when any do
    execute procedure P_LogErr(-5,sqlcode,gdscode,sqlstate,'P_DoDailyJob',null,null,null);
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_DailyJob
as
  declare Mutex BigInt;
begin
  Mutex = 0;
  execute procedure P_IsNewDay returning_values Mutex;
  if (Mutex > 0) then
  begin
    execute procedure P_LogMsg(221,0,0,null,'P_DailyJob',null,'Start',null);
    execute procedure P_DoDailyJob;
    execute procedure P_LogMsg(222,0,0,null,'P_DailyJob',null,'Finish',null);
    execute procedure P_FinishSync(Mutex);
  end
  when any do
  begin
    if (Mutex > 0) then execute procedure P_FinishSync(Mutex);
    execute procedure P_LogErr(-3,sqlcode,gdscode,sqlstate,'P_DailyJob',null,null,null);
    when any do exit;
  end
end^
/*-----------------------------------------------------------------------------------------------*/
set term ; ^
/*-----------------------------------------------------------------------------------------------*/
grant all on P_TSyncTest to procedure P_Lock;

grant execute on procedure P_FinishSync to procedure P_TryEndSync;

grant execute on procedure SYS_UnixDays to procedure P_IsNewDay;
grant execute on procedure P_BeginSync to procedure P_IsNewDay;
grant execute on procedure P_FinishSync to procedure P_IsNewDay;

grant all on P_TLog to procedure P_ClearAuxLogs;
grant all on P_TDBLog to procedure P_ClearAuxLogs;
grant all on P_TIpLog to procedure P_ClearAuxLogs;
grant all on P_TChecks to procedure P_ClearAuxLogs;
grant select on P_TParams to procedure P_ClearAuxLogs;
grant execute on procedure P_LogErr to procedure P_ClearAuxLogs;

/*
grant select on P_TParams to procedure P_ClearWorkLogs;
grant execute on procedure P_LogErr to procedure P_ClearWorkLogs;
*/
grant execute on procedure P_Sweep to procedure P_DoDailyJob;
grant execute on procedure P_LogErr to procedure P_DoDailyJob;
grant execute on procedure P_ExitDJ to procedure P_DoDailyJob;
grant execute on procedure P_EnterDJ to procedure P_DoDailyJob;
grant execute on procedure P_ClearReplLog to procedure P_DoDailyJob;
grant execute on procedure P_ClearAuxLogs to procedure P_DoDailyJob;
grant execute on procedure P_ClearNodeList to procedure P_DoDailyJob;

grant execute on procedure P_LogMsg to procedure P_DailyJob;
grant execute on procedure P_LogErr to procedure P_DailyJob;
grant execute on procedure P_IsNewDay to procedure P_DailyJob;
grant execute on procedure P_FinishSync to procedure P_DailyJob;
grant execute on procedure P_DoDailyJob to procedure P_DailyJob;

grant execute on procedure P_LogMsg to procedure P_HourJob;
--grant execute on procedure P_ClearWorkLogs to procedure P_HourJob;

grant select on P_TParams to procedure P_CanRunRepair;

grant execute on procedure P_LogErr to procedure P_DoSync;
grant execute on procedure P_FixReg to procedure P_DoSync;
grant execute on procedure P_Commit to procedure P_DoSync;
grant execute on procedure P_Repair to procedure P_DoSync;
grant execute on procedure P_HourJob to procedure P_DoSync;
grant execute on procedure P_CheckPOR to procedure P_DoSync;
grant execute on procedure P_PullData to procedure P_DoSync;
grant execute on procedure P_IsNewHour to procedure P_DoSync;
grant execute on procedure P_ClearLogs to procedure P_DoSync;
grant execute on procedure P_CanRunRepair to procedure P_DoSync;

grant execute on procedure P_Lock to procedure P_Sync;
grant execute on procedure P_DoSync to procedure P_Sync;
grant execute on procedure P_LogMsg to procedure P_Sync;
grant execute on procedure P_LogErr to procedure P_Sync;
--grant execute on procedure SYS_OnlyObj to procedure P_Sync;
grant execute on procedure P_RoundTrip to procedure P_Sync;
grant execute on procedure P_IsSyncBot to procedure P_Sync;
grant execute on procedure P_BeginSync to procedure P_Sync;
grant execute on procedure P_FinishSync to procedure P_Sync;
grant execute on procedure P_IsSyncSpan to procedure P_Sync;

grant select on P_TParams to procedure P_BeginSync;
/*-----------------------------------------------------------------------------------------------*/
