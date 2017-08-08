/* ************************************************************************ */
/* PeopleRelay: security.sql Version: see version.sql                       */
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
create procedure P_CheckAttach
as
  declare MaxConnIdl TUInt;
  declare MaxConnAct TUInt;
  declare MaxAgeIdlCn TTimeGap;
  declare MaxAgeActCn TTimeGap;
begin
  select MaxConnIdl,MaxConnAct,MaxAgeIdlCn,MaxAgeActCn
    from P_TParams into :MaxConnIdl,:MaxConnAct,:MaxAgeIdlCn,MaxAgeActCn;

  if (MaxAgeIdlCn > 0) then
    delete from mon$attachments
      where mon$attachment_id <> CURRENT_CONNECTION and mon$state = 0
        and mon$timestamp < (CURRENT_TIMESTAMP - (:MaxAgeIdlCn / 1440.000000));

  if (MaxAgeActCn > 0) then
    delete from mon$attachments
      where mon$attachment_id <> CURRENT_CONNECTION and mon$state = 1
        and mon$timestamp < (CURRENT_TIMESTAMP - (:MaxAgeActCn / 1440.000000));

  if (MaxConnIdl > 0 and (select count(*) from mon$attachments
    where mon$attachment_id <> CURRENT_CONNECTION and mon$state = 0) > MaxConnIdl)
  then
    exception P_E$MaxIdlConn;
  if (MaxConnAct > 0 and (select count(*) from mon$attachments
    where mon$attachment_id <> CURRENT_CONNECTION and mon$state = 1) > MaxConnAct)
  then
    exception P_E$MaxActConn;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_IsUser
returns
  (Result TBoolean,
   LogAttach TBoolean)
as
  declare LA TLogMode;
  declare ULA TBoolean;
  declare IpBan TBoolean;  
  declare AccountDb TRef;
  declare AccountId TRef;
  declare Online TBoolean;
  declare LogIpBan TBoolean;
  declare ExtAcc TUserName;
begin
  select Online,ExtUsrLg,ExtAcc,LogIpBan,LogAttach
    from P_TParams into :Online,:ULA,:ExtAcc,:LogIpBan,:LA;
  execute procedure P_IsIpBanned returning_values IpBan;
  if (IpBan = 1)
  then
    LogAttach = LogIpBan;
  else
    if (CURRENT_USER = ExtAcc) /* External User, do not check IP */
    then
      begin
        if (Online = 1 and (select Result from SYS_IsSU(null)) = 0) then
        begin /* prevent Ext User from connect with the adm privileges */
          Result = 1;
          LogAttach = ULA;
        end
      end
    else
      begin
        execute procedure P_IsIpValid returning_values Result,ULA;
        if (LA = 1 and Result = 0)
        then
          LogAttach = 1;
        else
          if (LA = 2 and Result = 1)
          then
            LogAttach = ULA;
          else
            if (LA = 3) then
              if (Result = 0)
              then
                LogAttach = 1;
              else
                LogAttach = ULA;
      end
end^
/*-----------------------------------------------------------------------------------------------*/
create trigger P_T$Connect on connect
as
  declare RFlag TBoolean;
  declare IsUser TBoolean;
  declare LogAttach TBoolean;
  declare LogId TRef;
begin
  execute procedure P_SetVars;
  execute procedure P_IsUser returning_values IsUser,LogAttach;
  if (LogAttach = 1) then
  begin
    in autonomous transaction do
      insert into P_TDBLog
        select
            null,
            mon$attachment_id,
            mon$server_pid,
            mon$attachment_name,
            CURRENT_USER,
            mon$role,
            mon$remote_protocol,
            Upper(Substring(Trim(mon$remote_address) from 1 for 39)),
            mon$remote_pid,
            mon$character_set_id,
            mon$remote_process,
            iif(:IsUser = 0,1,0),
            null,
            null,
            null,
            null,
            null
          from
            mon$attachments
          where
            mon$attachment_id = CURRENT_CONNECTION
          returning RecId into :LogId;
    execute procedure P_SetSesFlag(100,LogId) returning_values RFlag;
  end
  if (IsUser = 0) then exception P_E$UnknownUser;
  execute procedure P_CheckAttach;
  execute procedure P_DailyJob;
end^
/*-----------------------------------------------------------------------------------------------*/
create trigger P_T$Disconnect on disconnect
as
  declare R TBoolean;
  declare IVal TRef;
  declare TVal TTimeMark;
  declare d DOUBLE PRECISION;
begin
  execute procedure P_GetSesFlag(100) returning_values R,IVal,TVal;
  if (R > 0) then
  begin
    d =datediff(millisecond,TVal,CURRENT_TIMESTAMP);
    update
        P_TDBLog
      set
        MntDuration = round(:d / 60000.000000,3),
        SecDuration = :d / 1000.000000
      where RecId = :IVal;
  end
  execute procedure P_TryEndSync;
  when any do exit;
end^
/*-----------------------------------------------------------------------------------------------*/
set term ; ^
/*-----------------------------------------------------------------------------------------------*/
grant select on P_TParams to procedure P_CheckAttach;

grant select on P_TParams to procedure P_IsUser;
grant execute on procedure SYS_IsSU to procedure P_IsUser;
grant execute on procedure P_IsIpValid to procedure P_IsUser;
grant execute on procedure P_IsIpBanned to procedure P_IsUser;

grant execute on procedure P_IsIpBanned to trigger P_T$Connect;

grant all on P_TDBLog to trigger P_T$Connect;
grant select on P_TParams to trigger P_T$Connect;
grant execute on procedure P_IsUser to trigger P_T$Connect;
grant execute on procedure P_SetVars to trigger P_T$Connect;
grant execute on procedure P_DailyJob to trigger P_T$Connect;
grant execute on procedure P_SetSesFlag to trigger P_T$Connect;
grant execute on procedure P_CheckAttach to trigger P_T$Connect;

grant all on P_TDBLog to trigger P_T$Disconnect;
grant execute on procedure P_GetSesFlag to trigger P_T$Disconnect;
grant execute on procedure P_TryEndSync to trigger P_T$Disconnect;

/*-----------------------------------------------------------------------------------------------*/

