/* ======================================================================== */
/* PeopleRelay: inet.sql Version: 0.4.3.6                                   */
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
/*
select Result from P_IsOnline('google.com',80)
*/
create procedure P_IsOnline(IP TIPV6str,APort TUInt)
returns
  (Result TBoolean)
as
  declare Timeout TUInt;
begin
  select IpTimeout from P_TParams into :Timeout;
  if (Timeout > 0)
  then
    Result = CanConnect(Ip,APort,Timeout);
  else
    Result = 1;
  suspend;  
end^
/*-----------------------------------------------------------------------------------------------*/
set term ; ^
/*-----------------------------------------------------------------------------------------------*/
grant select on P_TParams to procedure P_IsOnline;
/*-----------------------------------------------------------------------------------------------*/

