/* ************************************************************************ */
/* PeopleRelay: dbmon.sql Version: see version.sql                          */
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
create generator P_G$DBLog;
/*-----------------------------------------------------------------------------------------------*/
create table P_TDBLog(
  RecId               TRid,

  ATTACHMENT_ID       TRid,
  SERVER_PID         	TInt32,
  ATTACHMENT_NAME    	VarChar(255),
  FUSER              	VarChar(31) not null,
  FROLE              	VarChar(31),
  REMOTE_PROTOCOL    	TProto,
  REMOTE_ADDRESS     	VarChar(255),
  REMOTE_PID         	TInt32,
  CHARACTER_SET_ID   	SmallInt,
  REMOTE_PROCESS     	VarChar(255),

  Forbidden           TBoolean,
  MntDuration         DOUBLE PRECISION, /* Session duration in minutes. */
  SecDuration         DOUBLE PRECISION, /* Session duration in seconds. */

  ChangedBy           TOperName,
  CreatedAt           TTimeMark,
  ChangedAt           TTimeMark,
  primary key         (RecId));
/*-----------------------------------------------------------------------------------------------*/
set term ^ ;
/*-----------------------------------------------------------------------------------------------*/
create trigger P_TBI$TDBLog for P_TDBLog active before insert position 0
as
begin
  if (new.RecId is null) then new.RecId = gen_id(P_G$DBLog,1);
  if (new.Remote_Pid is null) then new.Remote_Pid = 0; /* for Java drivers */
  new.FRole = Trim(new.FRole);
  new.CreatedAt = CURRENT_TIMESTAMP;
  new.ChangedBy = CURRENT_USER;
  new.ChangedAt = new.CreatedAt;
end^
/*-----------------------------------------------------------------------------------------------*/
create trigger P_TBU$TDBLog for P_TDBLog active before update position 0
as
begin
  new.RecId = old.RecId;
  new.CreatedAt = old.CreatedAt;
  new.ChangedBy = CURRENT_USER;
  new.ChangedAt = CURRENT_TIMESTAMP;
end^
/*-----------------------------------------------------------------------------------------------*/
set term ; ^
/*-----------------------------------------------------------------------------------------------*/
create index P_X$DBLog1 on P_TDBLog(FUSER);
create index P_X$DBLog2 on P_TDBLog(ATTACHMENT_ID);
/*-----------------------------------------------------------------------------------------------*/
create view P_DBLogLegal as select * from P_TDBLog where Forbidden = 0;
create view P_DBLogFrotz as select * from P_TDBLog where Forbidden = 1;
/*-----------------------------------------------------------------------------------------------*/
create view P_DBLogFrDir(FUser) as select distinct(FUSER) from P_DBLogFrotz;
/*-----------------------------------------------------------------------------------------------*/
create view P_DBLogLgDir(FUser) as select distinct(FUSER) from P_DBLogLegal;
/*-----------------------------------------------------------------------------------------------*/
grant select on P_TParams to trigger P_TBI$TDBLog;
/*-----------------------------------------------------------------------------------------------*/

