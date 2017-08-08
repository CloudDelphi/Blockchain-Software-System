/* ************************************************************************ */
/* PeopleRelay: vars.sql Version: see version.sql                                 */
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
create generator P_G$DTM;
create generator P_G$STM;
create generator P_G$SDU;
create generator P_G$RTT;
/*-----------------------------------------------------------------------------------------------*/
create global temporary table P_TSesIP(
  IP              TIPV6str not null
) on commit preserve rows;
/*-----------------------------------------------------------------------------------------------*/
set term ^ ;
/*-----------------------------------------------------------------------------------------------*/
create procedure P_RoundTrip
as
  declare t BigInt;
  declare t0 BigInt;
  declare tn BigInt;
begin
  execute procedure SYS_UnixTMNow returning_values tn;
  t = Gen_Id(P_G$STM,tn - Gen_Id(P_G$STM,0));
  execute procedure SYS_UnixTMTran returning_values t;
  t0 = Gen_Id(P_G$SDU,0);
  t = Round((t0 + (tn - t)) / 2.0) - t0;
  t = Gen_Id(P_G$SDU,t);
  t = Gen_Id(P_G$RTT,1);
  when any do exit;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_IsSyncSpan
returns
  (Result TBoolean)
as
  declare t BigInt;
  declare SyncSpan TUInt1;  
begin
  select SyncSpan from P_TParams into :SyncSpan;
  execute procedure SYS_UnixTMNow returning_values t;

  if (Abs(t - Gen_Id(P_G$STM,0)) >= SyncSpan) then Result = 1;
  suspend;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_SyncPOR(AGap BigInt)
returns
  (Result TBoolean)
as
  declare t BigInt;
begin
  if (AGap > 0) then
  begin
    execute procedure SYS_UnixTMNow returning_values t;
    if (Abs(t - Gen_Id(P_G$STM,0)) >= AGap) then Result = 1;
  end
  suspend;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_SetVars
as
begin
  insert into P_TSesIP(IP) select Result from SYS_IP;
end^
/*-----------------------------------------------------------------------------------------------*/
set term ; ^
/*-----------------------------------------------------------------------------------------------*/
grant all on P_TSesIP to PUBLIC;
grant execute on procedure SYS_UnixTMNow to procedure P_RoundTrip;
grant execute on procedure SYS_UnixTMTran to procedure P_RoundTrip;
grant select on P_TParams to procedure P_IsSyncSpan;
grant execute on procedure SYS_UnixTMNow to procedure P_IsSyncSpan;
grant execute on procedure SYS_UnixTMNow to procedure P_SyncPOR;
grant execute on procedure SYS_IP to procedure P_SetVars;
/*-----------------------------------------------------------------------------------------------*/

