/* ======================================================================== */
/* PeopleRelay: dbmon.sql Version: 0.4.1.8                                  */
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
create generator P_G$DBLog;
/*-----------------------------------------------------------------------------------------------*/
create table P_TDBLog(
  RecId               TRid,

  Kind                TAccKind,
  Attachment_Id       RDB$ATTACHMENT_ID,
  Server_PID         	RDB$PID,
  Attachment_Name    	RDB$FILE_NAME2,
  FUser              	RDB$USER not null,
  FRole              	RDB$USER,
  Remote_Proto      	TProto,
  Remote_Addr       	RDB$REMOTE_ADDRESS,
  Remote_PID         	RDB$PID,
  Charset_Id        	RDB$CHARACTER_SET_ID,
  Remote_Process     	RDB$FILE_NAME2,

  ErrorId             TAttErr,

  MntDuration         DOUBLE PRECISION, /* Session duration in minutes. */
  SecDuration         DOUBLE PRECISION, /* Session duration in seconds. */

  FDate               TTimeMark,
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
  if (new.Remote_PID is null) then new.Remote_PID = 0; /* for Java drivers */
  new.FRole = Trim(new.FRole);
  new.CreatedAt = UTCTime();
  new.ChangedBy = CURRENT_USER;
  new.ChangedAt = new.CreatedAt;
  new.FDate = cast(new.CreatedAt as Date);  
end^
/*-----------------------------------------------------------------------------------------------*/
create trigger P_TBU$TDBLog for P_TDBLog active before update position 0
as
begin
  new.RecId = old.RecId;
  new.FUser = old.FUser;
  new.CreatedAt = old.CreatedAt;
  new.ChangedBy = CURRENT_USER;
  new.ChangedAt = UTCTime();
end^
/*-----------------------------------------------------------------------------------------------*/
set term ; ^
/*-----------------------------------------------------------------------------------------------*/
create index P_X$DBLog1 on P_TDBLog(FUser);
create index P_X$DBLog2 on P_TDBLog(Attachment_Id);
/*-----------------------------------------------------------------------------------------------*/
create view P_DBLogLegal as select * from P_TDBLog where ErrorId = 0;
create view P_DBLogFrotz as select * from P_TDBLog where ErrorId > 0;
/*-----------------------------------------------------------------------------------------------*/
create view P_DBLogFrDir(FUser) as select distinct(FUser) from P_DBLogFrotz;
/*-----------------------------------------------------------------------------------------------*/
create view P_DBLogLgDir(FUser) as select distinct(FUser) from P_DBLogLegal;
/*-----------------------------------------------------------------------------------------------*/
grant select on P_TParams to trigger P_TBI$TDBLog;
/*-----------------------------------------------------------------------------------------------*/

