/* ======================================================================== */
/* PeopleRelay: check_log.sql Version: 0.4.1.8                              */
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
create generator P_G$Checks;
create generator P_G$ChkLog;
/*-----------------------------------------------------------------------------------------------*/
create table P_TChecks(
  RecId             TRid,
  ChainId           TRid,
  CreatedBy         TOperName,
  CreatedAt         TTimeMark,
  primary key       (RecId));
/*-----------------------------------------------------------------------------------------------*/
set term ^ ;
/*-----------------------------------------------------------------------------------------------*/
create trigger P_TBI$TChecks for P_TChecks active before insert position 0
as
begin
  new.RecId = gen_id(P_G$Checks,1);
  new.CreatedBy = CURRENT_USER;
  new.CreatedAt = UTCTime();
end^
/*-----------------------------------------------------------------------------------------------*/
create trigger P_TBU$TChecks for P_TChecks active before update position 0
as
begin
  exception P_E$Forbidden;
end^
/*-----------------------------------------------------------------------------------------------*/
set term ; ^
/*-----------------------------------------------------------------------------------------------*/
create table P_TChkLog(
  RecId             TRid,
  CheckId           TRid,
  NodeId            TNodeId not null,
  CreatedBy         TOperName,
  CreatedAt         TTimeMark,
  primary key       (RecId),
  foreign key       (CheckId) references P_TChecks(RecId)
    on update       CASCADE
    on delete       CASCADE);
/*-----------------------------------------------------------------------------------------------*/
set term ^ ;
/*-----------------------------------------------------------------------------------------------*/
create trigger P_TBI$TChkLog for P_TChkLog active before insert position 0
as
begin
  new.RecId = gen_id(P_G$ChkLog,1);
  new.CreatedBy = CURRENT_USER;
  new.CreatedAt = UTCTime();
end^
/*-----------------------------------------------------------------------------------------------*/
create trigger P_TBU$TChkLog for P_TChkLog active before update position 0
as
begin
  exception P_E$Forbidden;
end^
/*-----------------------------------------------------------------------------------------------*/
set term ; ^
/*-----------------------------------------------------------------------------------------------*/
create view P_Checks
as
  select
    C.*,
    (select count(*) from P_TChkLog L where L.CheckId = C.RecId) as Voters
  from P_TChecks C;
/*-----------------------------------------------------------------------------------------------*/
create view P_ChkLog as select * from P_TChkLog;
/*-----------------------------------------------------------------------------------------------*/

