/* ======================================================================== */
/* PeopleRelay: flags.sql Version: 0.4.3.6                                  */
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
create global temporary table P_TSesFlag(
  Flag              TInt32 not null,
  IVal              TRef,
  TVal              TTimeMark,
  primary key       (Flag)
) on commit preserve rows;
/*-----------------------------------------------------------------------------------------------*/
create global temporary table P_TTrFlag(
  Flag              TInt32 not null,
  primary key       (Flag)
) on commit delete rows;
/*-----------------------------------------------------------------------------------------------*/
set term ^ ;
/*-----------------------------------------------------------------------------------------------*/
create procedure P_GetSesFlag(Flag TInt32)
returns
  (Result TBoolean,
   IVal TRef,
   TVal TTimeMark)
as
begin
  Result = 0;
  select 1,IVal,TVal from P_TSesFlag where Flag = :Flag into :Result,:IVal,:TVal;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_SetSesFlag(Flag TInt32, IVal TRef)
returns
  (Result TBoolean)
as
begin
  insert into P_TSesFlag(Flag,IVal,TVal) values(:Flag,:IVal,UTCTime());
  Result = 1;
  when SQLCODE -803 do Result = 0;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_DelSesFlag(Flag TInt32)
as
begin
  delete from P_TSesFlag where Flag = :Flag;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_GetTranFlag(Flag TInt32)
returns
  (Result TBoolean)
as
begin
  select 1 from P_TTrFlag where Flag = :Flag into :Result;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_SetTranFlag(Flag TInt32)
returns
  (Result TBoolean)
as
begin
  insert into P_TTrFlag(Flag) values(:Flag);
  Result = 1;
  when SQLCODE -803 do Result = 0;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_DelTranFlag(Flag TInt32)
as
begin
  delete from P_TTrFlag where Flag = :Flag;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_EnterExtAcc
as
  declare flag TBoolean;
begin
  execute procedure P_SetTranFlag(487224) returning_values flag;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_ExitExtAcc
as
begin
  execute procedure P_DelTranFlag(487224);
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_IsExtAcc
returns
  (Result TBoolean)
as
begin
  execute procedure P_GetTranFlag(487224) returning_values Result;
  suspend;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_EnterDJ
as
  declare flag TBoolean;
begin
  execute procedure P_SetTranFlag(875302) returning_values flag;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_ExitDJ
as
begin
  execute procedure P_DelTranFlag(875302);
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_IsDJ
returns
  (Result TBoolean)
as
begin
  execute procedure P_GetTranFlag(875302) returning_values Result;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_BegAddB
returns
  (Result TBoolean)
as
begin
  execute procedure P_SetTranFlag(345615) returning_values Result;
end^
/*---------------------------------------0-------------------------------------------------------*/
create procedure P_EndAddB
as
begin
  execute procedure P_DelTranFlag(345615);
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_IsAddB
returns
  (Result TBoolean)
as
begin
  execute procedure P_GetTranFlag(345615) returning_values Result;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_BegCommit
returns
  (Result TBoolean)
as
begin
  execute procedure P_SetTranFlag(523847) returning_values Result;
  suspend;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_EndCommit
as
begin
  execute procedure P_DelTranFlag(523847);
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_Commiting
returns
  (Result TBoolean)
as
begin
  execute procedure P_GetTranFlag(523847) returning_values Result;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_BegRepl
returns
  (Result TBoolean)
as
begin
  execute procedure P_SetTranFlag(375914) returning_values Result;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_BegReplEx
as
  declare flag TBoolean;
begin
  execute procedure P_SetTranFlag(375914) returning_values flag;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_EndRepl
as
begin
  execute procedure P_DelTranFlag(375914);
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_IsRepl
returns
  (Result TBoolean)
as
begin
  execute procedure P_GetTranFlag(375914) returning_values Result;
  suspend;  
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_BegAlt
returns
  (Result TBoolean)
as
begin
  execute procedure P_SetTranFlag(458927) returning_values Result;
  suspend;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_EndAlt
as
begin
  execute procedure P_DelTranFlag(458927);
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_IsAlt
returns
  (Result TBoolean)
as
begin
  execute procedure P_GetTranFlag(458927) returning_values Result;
  suspend;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_BegFixReg
returns
  (Result TBoolean)
as
begin
  execute procedure P_SetTranFlag(545748) returning_values Result;
  suspend;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_EndFixReg
as
begin
  execute procedure P_DelTranFlag(545748);
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_IsFixReg
returns
  (Result TBoolean)
as
begin
  execute procedure P_GetTranFlag(545748) returning_values Result;
  suspend;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_BegNdSid
as
declare flag TBoolean;
begin
  execute procedure P_SetTranFlag(7485241) returning_values flag;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_EndNdSid
as
begin
  execute procedure P_DelTranFlag(7485241);
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_IsNdSid
returns
  (Result TBoolean)
as
begin
  execute procedure P_GetTranFlag(7485241) returning_values Result;
  suspend;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_BegMPSid
as
declare flag TBoolean;
begin
  execute procedure P_SetTranFlag(7485272) returning_values flag;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_EndMPSid
as
begin
  execute procedure P_DelTranFlag(7485272);
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_IsMPSid
returns
  (Result TBoolean)
as
begin
  execute procedure P_GetTranFlag(7485272) returning_values Result;
  suspend;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_BegDehorn
returns
  (Result TBoolean)
as
begin
  execute procedure P_SetTranFlag(549228) returning_values Result;
  suspend;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_EndDehorn
as
begin
  execute procedure P_DelTranFlag(549228);
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_IsDehorn
returns
  (Result TBoolean)
as
begin
  execute procedure P_GetTranFlag(549228) returning_values Result;
  suspend;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_BegTrim
returns
  (Result TBoolean)
as
begin
  execute procedure P_SetTranFlag(698743) returning_values Result;
  suspend;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_EndTrim
as
begin
  execute procedure P_DelTranFlag(698743);
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_Trimming
returns
  (Result TBoolean)
as
begin
  execute procedure P_GetTranFlag(698743) returning_values Result;
  suspend;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_Creating
returns
  (Result TBoolean)
as
begin
  execute procedure P_SetTranFlag(734522) returning_values Result;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_IsCreating
returns
  (Result TBoolean)
as
begin
  execute procedure P_GetTranFlag(734522) returning_values Result;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_Destroying
returns
  (Result TBoolean)
as
begin
  execute procedure P_SetTranFlag(734523) returning_values Result;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_GetDestroying
returns
  (Result TBoolean)
as
begin
  execute procedure P_GetTranFlag(734523) returning_values Result;
end^
/*-----------------------------------------------------------------------------------------------*/
set term ; ^
/*-----------------------------------------------------------------------------------------------*/
grant all on P_TTrFlag to PUBLIC;
grant all on P_TSesFlag to PUBLIC;
/* ^^^ fb v. >= 2.5.2 Do not grant perm to procs, it does not work if there are no PUBLIC rights. */

grant execute on procedure P_SetSesFlag to PUBLIC;
grant execute on procedure P_GetSesFlag to PUBLIC;
grant execute on procedure P_DelSesFlag to PUBLIC;

grant execute on procedure P_DelTranFlag to PUBLIC;
grant execute on procedure P_SetTranFlag to PUBLIC;
grant execute on procedure P_GetTranFlag to PUBLIC;
/*-----------------------------------------------------------------------------------------------*/
