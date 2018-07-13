/* ======================================================================== */
/* PeopleRelay: security.sql Version: 0.4.3.6                               */
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
/* Kind = 4 for Guest (Replicator) */
create procedure P_CheckAttach(Kind TAccKind)
as
  declare MaxConnIdl TUInt;
  declare MaxConnAct TUInt;
  declare MaxAgeIdlCn TTimeGap;
  declare MaxAgeActCn TTimeGap;
begin
  select MaxConnIdl,MaxConnAct,MaxAgeIdlCn,MaxAgeActCn
    from P_TParams into :MaxConnIdl,:MaxConnAct,:MaxAgeIdlCn,MaxAgeActCn;

  if (MaxAgeIdlCn > 0) then
    delete from mon$attachments A
      where A.mon$attachment_id <> CURRENT_CONNECTION
        and A.mon$state = 0
        and A.mon$timestamp < (CURRENT_TIMESTAMP - (:MaxAgeIdlCn / 1440.000000))
        and exists (select 1 from P_TACL L where L.Name = A.mon$user and L.Kind = 4);

  if (MaxAgeActCn > 0) then
    delete from mon$attachments A
      where A.mon$attachment_id <> CURRENT_CONNECTION
        and A.mon$state = 1
        and A.mon$timestamp < (CURRENT_TIMESTAMP - (:MaxAgeActCn / 1440.000000))
        and exists (select 1 from P_TACL L where L.Name = A.mon$user and L.Kind = 4);

  if (Kind = 4) then
  begin
    if (MaxConnIdl > 0 and (select count(*) from mon$attachments
      where mon$attachment_id <> CURRENT_CONNECTION and mon$state = 0) > MaxConnIdl)
    then
      exception P_E$MaxIdlConn;
    if (MaxConnAct > 0 and (select count(*) from mon$attachments
      where mon$attachment_id <> CURRENT_CONNECTION and mon$state = 1) > MaxConnAct)
    then
      exception P_E$MaxActConn;
  end
end^
/*-----------------------------------------------------------------------------------------------*/
/* 1=Ip banned 2=OffLine 3=Acc or Ip is not registered */

create procedure P_IsUser
returns
  (Result TAttErr,
   LogAttach TBoolean,
   Kind TAccKind)
as
  declare ULA TBoolean;
  declare LAE TBoolean;
  declare IsUser TBoolean;
  declare Online TBoolean;
  declare ExtAcc TUserName;
begin
  select Online,ExtAcc,LogAttErr from P_TParams into :Online,:ExtAcc,:LAE;

  if ((select Result from P_IsIpBanned) = 1)
  then
    begin
      Result = 1;
      LogAttach = LAE;
    end
  else
    if (CURRENT_USER = ExtAcc and Online = 0)
    then
      begin
        Result = 2;
        LogAttach = LAE;
      end
    else
      begin
        execute procedure P_IsIpValid returning_values IsUser,ULA,Kind;
        if (IsUser = 0)
        then
          begin
            Result = 3;
            LogAttach = LAE;
          end
        else
          LogAttach = ULA;
      end
end^
/*-----------------------------------------------------------------------------------------------*/
create trigger P_T$Connect on connect
as
  declare RFlag TBoolean;
  declare ErrorId TAttErr;
  declare LogAttach TBoolean;
  declare LogId TRef;
  declare Kind TAccKind;
begin
  execute procedure P_SetVars;
  execute procedure P_IsUser returning_values ErrorId,LogAttach,Kind;
  if (LogAttach = 1) then
  begin
    in autonomous transaction do
      insert into P_TDBLog
        select
            null,
            :Kind,
            mon$attachment_id,
            mon$server_pid,
            mon$attachment_name,
            CURRENT_USER,
            mon$role,
            mon$remote_protocol,
            mon$remote_address,
            mon$remote_pid,
            mon$character_set_id,
            mon$remote_process,
            :ErrorId,
            null,
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
  if (ErrorId > 0) then exception P_E$Connection;
  execute procedure P_CheckAttach(Kind);
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
    d =datediff(millisecond,TVal,UTCTime());
    update P_TDBLog
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
grant select on P_TACL to procedure P_CheckAttach;
grant select on P_TParams to procedure P_CheckAttach;

grant select on P_TParams to procedure P_IsUser;
grant execute on procedure P_IsIpValid to procedure P_IsUser;
grant execute on procedure P_IsIpBanned to procedure P_IsUser;

grant all on P_TDBLog to trigger P_T$Connect;
grant execute on procedure P_IsUser to trigger P_T$Connect;
grant execute on procedure P_SetVars to trigger P_T$Connect;
grant execute on procedure P_DailyJob to trigger P_T$Connect;
grant execute on procedure P_SetSesFlag to trigger P_T$Connect;
grant execute on procedure P_CheckAttach to trigger P_T$Connect;

grant all on P_TDBLog to trigger P_T$Disconnect;
grant execute on procedure P_GetSesFlag to trigger P_T$Disconnect;
grant execute on procedure P_TryEndSync to trigger P_T$Disconnect;

/*-----------------------------------------------------------------------------------------------*/

