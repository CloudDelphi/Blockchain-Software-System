/* ************************************************************************ */
/* PeopleRelay: sync.sql Version: see version.sql                           */
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
  (Mutex Integer)
as
  declare Dummy TBoolean;
  declare MName TSysStr128;
begin
  select 'P_' || NodeId from P_TParams into :MName;
  Mutex = GetMutex(MName,100);
  if (Mutex > 0) then
    execute procedure P_SetSesFlag(700,Mutex) returning_values Dummy;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_FinishSync(Mutex Integer)
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
  (Mutex Integer)
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
    if (Mutex > 0) then execute procedure P_FinishSync(Mutex);
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_DoSync
as
begin
  begin
    execute procedure P_FixReg;
    when any do
      execute procedure P_LogErr(-91,sqlcode,gdscode,sqlstate,'P_DoSync',null,'P_FixReg',null);
  end
  begin
    execute procedure P_CheckPOR;
    when any do
      execute procedure P_LogErr(-92,sqlcode,gdscode,sqlstate,'P_DoSync',null,'P_CheckPOR',null);
  end
  begin
    execute procedure P_ClearLogs;
    when any do
      execute procedure P_LogErr(-93,sqlcode,gdscode,sqlstate,'P_DoSync',null,'P_ClearLogs',null);
  end
  begin
    execute procedure P_UpdateLogs;
    when any do
      execute procedure P_LogErr(-94,sqlcode,gdscode,sqlstate,'P_DoSync',null,'P_UpdateLogs',null);
  end
  begin
    execute procedure P_PullData;
    when any do
      execute procedure P_LogErr(-95,sqlcode,gdscode,sqlstate,'P_DoSync',null,'P_PullData',null);
  end
  begin
    execute procedure P_Commit;
    when any do
      execute procedure P_LogErr(-96,sqlcode,gdscode,sqlstate,'P_DoSync',null,'P_Commit',null);
  end
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_Sync
as
  declare Mutex Integer;
begin
  Mutex = 0;
  if ((select Result from P_IsSyncBot) = 0)
  then
    execute procedure P_LogErr(-6,0,0,null,'P_Sync','Account is not registered as a Sync Bot.',null,null);
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
begin
  select ChkLogSize,AttLogSize,SysLogSize from P_TParams into :ChkLogSize,:AttLogSize,:SysLogSize;
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
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_DoDailyJob
as
begin
  execute procedure P_EnterDJ;
  execute procedure P_CheckLimbo;
  execute procedure P_ClearAuxLogs;
  execute procedure P_ClearReplLog;
  execute procedure P_ClearNodeList;
  execute procedure P_ExitDJ;
  when any do
    execute procedure P_LogErr(-5,sqlcode,gdscode,sqlstate,'P_DoDailyJob',null,null,null);
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_DailyJob
as
  declare Mutex Integer;
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
grant all on P_TChecks to procedure P_ClearAuxLogs;
grant select on P_TParams to procedure P_ClearAuxLogs;
grant execute on procedure P_LogErr to procedure P_ClearAuxLogs;

grant execute on procedure P_LogErr to procedure P_DoDailyJob;
grant execute on procedure P_ExitDJ to procedure P_DoDailyJob;
grant execute on procedure P_EnterDJ to procedure P_DoDailyJob;
grant execute on procedure P_CheckLimbo to procedure P_DoDailyJob;
grant execute on procedure P_ClearAuxLogs to procedure P_DoDailyJob;
grant execute on procedure P_ClearReplLog to procedure P_DoDailyJob;
grant execute on procedure P_ClearNodeList to procedure P_DoDailyJob;

grant execute on procedure P_LogMsg to procedure P_DailyJob;
grant execute on procedure P_LogErr to procedure P_DailyJob;
grant execute on procedure P_IsNewDay to procedure P_DailyJob;
grant execute on procedure P_FinishSync to procedure P_DailyJob;
grant execute on procedure P_DoDailyJob to procedure P_DailyJob;

grant execute on procedure P_LogErr to procedure P_DoSync;
grant execute on procedure P_FixReg to procedure P_DoSync;
grant execute on procedure P_Commit to procedure P_DoSync;
grant execute on procedure P_CheckPOR to procedure P_DoSync;
grant execute on procedure P_PullData to procedure P_DoSync;
grant execute on procedure P_ClearLogs to procedure P_DoSync;
grant execute on procedure P_UpdateLogs to procedure P_DoSync;

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
