/* ======================================================================== */
/* PeopleRelay: controlset.sql Version: 0.4.3.6                             */
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
create generator P_G$IpLog;
/*-----------------------------------------------------------------------------------------------*/
create table P_TIpLog(
  RecId             TRid,
  RT                TCount,
  DB                TIntHash not null, /* Self DB Path Hash */
  IP                TIPV6str not null, /* Self IP */
  PeerId            TNodeId not null,
  CreatedBy         TOperName,
  CreatedAt         TTimeMark,
  primary key       (RecId));
/*-----------------------------------------------------------------------------------------------*/
create unique descending index P_XU$IpLog on P_TIpLog(RecId);
/*-----------------------------------------------------------------------------------------------*/
set term ^ ;
/*-----------------------------------------------------------------------------------------------*/
create trigger P_TBI$TIpLog for P_TIpLog active before insert position 0
as
begin
  new.RT = Gen_Id(P_G$RTT,0);
  if (new.RecId is null) then new.RecId = gen_id(P_G$IpLog,1);
  new.CreatedBy = CURRENT_USER;
  new.CreatedAt = UTCTime();
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_LastDBIP
returns(
  DB_Prev TPath,
  DB_Last TPath,
  IP_Prev TIPV6str,
  IP_Last TIPV6str)
as
begin
  for select first 2
      DB,IP
    from P_TIpLog
    order by RecId desc
    into :DB_Prev,:IP_Prev
  do
    if (DB_Last is null) then
    begin
      DB_Last = DB_Prev;
      IP_Last = IP_Prev;
    end
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_LogIp(PeerId TNodeId,IP TIPV6str)
as
  declare DB TPath;
  declare DB_Prev TPath;
  declare DB_Last TPath;
  declare IP_Prev TIPV6str;
  declare IP_Last TIPV6str;
begin
  select Hash(Result) from SYS_DBName into :DB;
  execute procedure P_LastDBIP returning_values DB_Prev,DB_Last,IP_Prev,IP_Last;
  if (DB_Last is null
    or DB <> DB_Prev
    or DB <> DB_Last
    or IP <> IP_Prev
    or IP <> IP_Last)
  then
    insert into P_TIpLog(DB,IP,PeerId) values(:DB,:IP,:PeerId);
  when any do exit;
end^

/*
Do NOT check if last record having DB,IP is already exosts - it will lead to constant re-register.
*/
/*
create procedure P_LogIp(PeerId TNodeId,IP TIPV6str)
as
  declare DB_Prev TPath;
  declare DB_Last TPath;
begin
  insert into P_TIpLog(DB,IP,PeerId) values((select Hash(Result) from SYS_DBName),:IP,:PeerId);
  when any do exit;
end^
*/
/*-----------------------------------------------------------------------------------------------*/
create procedure P_IpOrDBChanged
returns
  (Result TBoolean)
as
  declare DB_Prev TPath;
  declare DB_Last TPath;
  declare IP_Prev TIPV6str;
  declare IP_Last TIPV6str;
begin
  execute procedure P_LastDBIP returning_values DB_Prev,DB_Last,IP_Prev,IP_Last;
  if (DB_Last <> DB_Prev or IP_Last <> IP_Prev) then Result = 1;
  suspend;

  when any do
  begin
    Result = 0;
    suspend;
  end
end^
/*-----------------------------------------------------------------------------------------------*/
set term ; ^
/*-----------------------------------------------------------------------------------------------*/
create view P_IpLog as select * from P_TIpLog; 
/*-----------------------------------------------------------------------------------------------*/
grant select on P_TIpLog to procedure P_LastDBIP;

grant insert on P_TIpLog to procedure P_LogIp;
grant execute on procedure SYS_DBName to procedure P_LogIp;
grant execute on procedure P_LastDBIP to procedure P_LogIp;

grant execute on procedure P_LastDBIP to procedure P_IpOrDBChanged;
/*-----------------------------------------------------------------------------------------------*/
