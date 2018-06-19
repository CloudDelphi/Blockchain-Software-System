/* ======================================================================== */
/* PeopleRelay: ipban.sql Version: 0.4.1.8                                  */
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
create generator P_G$IpBan;
/*-----------------------------------------------------------------------------------------------*/
create table P_TIpBan(
  RecId             TRid,
  IP                TIPV6str not null,
  Comment           TComment,
  CreatedBy         TUserName,
  ChangedBy         TUserName,
  CreatedAt         TTimeMark not null,
  ChangedAt         TTimeMark not null,
  primary key       (RecId));
/*-----------------------------------------------------------------------------------------------*/
create unique index P_XU$IpBan on P_TIpBan(IP);
/*-----------------------------------------------------------------------------------------------*/
set term ^ ;
/*-----------------------------------------------------------------------------------------------*/
create trigger P_TBI$TIpBan for P_TIpBan active before insert position 0
as
begin
  if (new.RecId is null) then new.RecId = gen_id(P_G$IpBan,1);
  new.CreatedBy = CURRENT_USER;
  new.CreatedAt = UTCTime();
  new.ChangedBy = new.CreatedBy;
  new.ChangedAt = new.CreatedAt;
  if (new.IP = '')
  then
    new.IP = null;
  else
    new.IP = Upper(new.IP);
end^
/*-----------------------------------------------------------------------------------------------*/
create trigger P_TBU$TIpBan for P_TIpBan active before update position 0
as
begin
  new.RecId = old.RecId;
  new.CreatedBy = old.CreatedBy;
  new.CreatedAt = old.CreatedAt;
  new.ChangedBy = CURRENT_USER;
  new.ChangedAt = UTCTime();
  if (new.IP = '')
  then
    new.IP = null;
  else
    new.IP = Upper(new.IP);
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_IsIpBanned
returns
  (Result TBoolean)
as
  declare IP TIPV6str;
begin
  select IP from P_TSesIP into :IP;
  IP = Upper(IP);
  select 1 from P_TIpBan where IP = :IP or :IP like IP || '%' into :Result;
  suspend;
end^
/*-----------------------------------------------------------------------------------------------*/
set term ; ^
/*-----------------------------------------------------------------------------------------------*/
create view P_IpBan as select * from P_TIpBan;
/*-----------------------------------------------------------------------------------------------*/
grant select on P_TIpBan to procedure P_IsIpBanned;
/*-----------------------------------------------------------------------------------------------*/

