/* ======================================================================== */
/* PeopleRelay: log.sql Version: 0.4.3.6                                    */
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
create generator P_G$Log;
/*-----------------------------------------------------------------------------------------------*/
create table P_TLog(
  RecId             TRid,
  MsgId             TInt32 default 0 not null,
  TransId           TInt32,
  IsError           TBoolean,
  IntData           TInt32,
  FloatData         Float,
  StrData           TSysStr16,
  Source            TSysStr32,
  Obj               TSysStr64,
  Msg               TSysStr128,
  Comment           TSysStr128,

  FDate             TTimeMark,

  CreatedBy         TOperName,
  CreatedAt         TTimeMark,
  primary key       (RecId));
/*-----------------------------------------------------------------------------------------------*/
create index P_X$Log1 on P_TLog(Obj);
create index P_X$Log2 on P_TLog(MsgId);
create index P_X$Log3 on P_TLog(IsError);
/*-----------------------------------------------------------------------------------------------*/
set term ^ ;
/*-----------------------------------------------------------------------------------------------*/
/*
  WeekNo            TWeekNo,
  YMonth            TMonthNo,
  YQuarter          TQuartNo,
  HalfYear          THalfYear,
  AYear             TYear,
  WeekYear          TYear, WeekYear can be less by 1 than Year

  new.AYear = extract(YEAR from new.CreatedAt);
  new.YMonth = extract(MONTH from new.CreatedAt);
  new.HalfYear = iif(extract(MONTH from new.CreatedAt) <= 6,1,2);
  execute procedure YearQuarter(new.CreatedAt) returning_values new.YQuarter;
  execute procedure WeekNo(new.CreatedAt) returning_values new.WeekYear,new.WeekNo;
*/

create trigger P_TBI$TLog for P_TLog active before insert position 0
as
begin
  if (new.RecId is null) then new.RecId = gen_id(P_G$Log,1);
  new.CreatedBy = CURRENT_USER;
  new.CreatedAt = UTCTime();
  new.FDate = cast(new.CreatedAt as Date);
end^
/*-----------------------------------------------------------------------------------------------*/
create trigger P_TBU$TLog for P_TLog active before update position 0
as
begin
  exception P_E$Forbidden;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_ToLog(
  MsgId TInt32,
  IsError SmallInt,
  IntData TInt32,
  FloatData Float,
  StrData TSysStr16,
  Source  TSysStr32,
  Obj TSysStr64,  
  Msg TSysStr128,
  Comment TSysStr128)
as
  declare TransId TInt32;
begin
  TransId = CURRENT_TRANSACTION;
  in autonomous transaction do
    insert into
      P_TLog(MsgId,TransId,IsError,IntData,FloatData,StrData,Source,Obj,Msg,Comment)
        values(:MsgId,:TransId,:IsError,:IntData,:FloatData,:StrData,:Source,:Obj,:Msg,:Comment);
  when any do exit;        
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_LogErr(
  MsgId TInt32,
  IntData TInt32,
  FloatData Float,
  StrData TSysStr16,
  Source  TSysStr32,
  Obj TSysStr64,
  Msg TSysStr128,
  Comment TSysStr128)
as
begin
  if (exists (select 1 from P_TParams where MsgLogMode in (1,3))) then
    execute procedure P_ToLog(MsgId,1,IntData,FloatData,StrData,Source,Obj,Msg,Comment);
  when any do exit;  
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_LogMsg(
  MsgId TInt32,
  IntData TInt32,
  FloatData Float,
  StrData TSysStr16,
  Source  TSysStr32,
  Obj TSysStr64,
  Msg TSysStr128,
  Comment TSysStr128)
as
begin
  if (exists (select 1 from P_TParams where MsgLogMode in (2,3))) then
    execute procedure P_ToLog(MsgId,0,IntData,FloatData,StrData,Source,Obj,Msg,Comment);
  when any do exit;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_LogSndErr(
  MsgId TInt32,
  IntData TInt32,
  FloatData Float,
  StrData TSysStr16,
  Source  TSysStr32,
  Obj TSysStr64,
  Msg TSysStr128)
as
begin
  if (exists (select 1 from P_TParams where SndLogMode in (1,3))) then
    execute procedure P_ToLog(MsgId,1,IntData,FloatData,StrData,Source,Obj,Msg,null);
  when any do exit;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_LogSndMsg(
  MsgId TInt32,
  IntData TInt32,
  FloatData Float,
  StrData TSysStr16,
  Source  TSysStr32,
  Obj TSysStr64,
  Msg TSysStr128,
  Comment TSysStr128)
as
begin
  if (exists (select 1 from P_TParams where SndLogMode in (2,3))) then
    execute procedure P_ToLog(MsgId,0,IntData,FloatData,StrData,Source,Obj,Msg,Comment);
  when any do exit;    
end^
/*-----------------------------------------------------------------------------------------------*/
set term ; ^
/*-----------------------------------------------------------------------------------------------*/
create view P_Log as select * from P_TLog;
create view P_ErrorLog as select * from P_TLog where IsError > 0;
create view P_DehornLog as select * from P_TLog where MsgId = 300;
/*-----------------------------------------------------------------------------------------------*/
grant all on P_TLog to procedure P_ToLog;
grant select on P_TParams to procedure P_LogMsg;
grant execute on procedure P_ToLog to procedure P_LogMsg;
grant select on P_TParams to procedure P_LogErr;
grant execute on procedure P_ToLog to procedure P_LogErr;
grant select on P_TParams to procedure P_LogSndErr;
grant execute on procedure P_ToLog to procedure P_LogSndErr;
grant select on P_TParams to procedure P_LogSndMsg;
grant execute on procedure P_ToLog to procedure P_LogSndMsg;
/*-----------------------------------------------------------------------------------------------*/


