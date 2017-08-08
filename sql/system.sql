/* ************************************************************************ */
/* PeopleRelay: system.sql Version: see version.sql                         */
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
create view SYS_FieldInfo(
  TABLE_NAME,
  FIELD_NAME,
  FIELD_POSITION,
  FIELD_TYPE,
  FIELD_NULL,
  FIELD_CHARSET,
  FIELD_COLLATION,
  FIELD_DEFAULT,
  FIELD_CHECK,
  FIELD_DESCRIPTION
)
as
select
  Trim(RF.RDB$RELATION_NAME),
  Trim(RF.RDB$FIELD_NAME),
  RF.RDB$FIELD_POSITION,
  Trim(case F.RDB$FIELD_TYPE
    when 7 then
      case F.RDB$FIELD_SUB_TYPE
        when 0 then 'SMALLINT'
        when 1 then 'NUMERIC(' || F.RDB$FIELD_PRECISION || ', ' || (-F.RDB$FIELD_SCALE) || ')'
        when 2 then 'DECIMAL'
      end
    when 8 then
      case F.RDB$FIELD_SUB_TYPE
        when 0 then 'INTEGER'
        when 1 then 'NUMERIC('  || F.RDB$FIELD_PRECISION || ', ' || (-F.RDB$FIELD_SCALE) || ')'
        when 2 then 'DECIMAL'
      end
    when 9 then 'QUAD'
    when 10 then 'FLOAT'
    when 12 then 'DATE'
    when 13 then 'TIME'
    when 14 then 'CHAR(' || (TRUNC(F.RDB$FIELD_LENGTH / CH.RDB$BYTES_PER_CHARACTER)) || ') '
    when 16 then
      case F.RDB$FIELD_SUB_TYPE
        when 0 then 'BIGINT'
        when 1 then 'NUMERIC(' || F.RDB$FIELD_PRECISION || ', ' || (-F.RDB$FIELD_SCALE) || ')'
        when 2 then 'DECIMAL'
      end
    when 27 then 'DOUBLE PRECISION'
    when 35 then 'TIMESTAMP'
    when 37 then
     IIF (COALESCE(f.RDB$COMPUTED_SOURCE,'')<>'',
      'COMPUTED BY ' || cast(f.RDB$COMPUTED_SOURCE as VARCHAR(250)),
      'VARCHAR(' || (TRUNC(F.RDB$FIELD_LENGTH / CH.RDB$BYTES_PER_CHARACTER)) || ')')
    when 40 then 'CSTRING' || (TRUNC(F.RDB$FIELD_LENGTH / CH.RDB$BYTES_PER_CHARACTER)) || ')'
    when 45 then 'BLOB_ID'
    when 261 then 'BLOB SUB_TYPE ' || F.RDB$FIELD_SUB_TYPE
    else 'RDB$FIELD_TYPE: ' || F.RDB$FIELD_TYPE || '?'
  end),
  IIF(COALESCE(RF.RDB$NULL_FLAG, 0) = 0, null, 'NOT NULL'),
  Trim(CH.RDB$CHARACTER_SET_NAME),
  Trim(DCO.RDB$COLLATION_NAME),
  COALESCE(RF.RDB$DEFAULT_SOURCE, F.RDB$DEFAULT_SOURCE),
  F.RDB$VALIDATION_SOURCE,
  RF.RDB$DESCRIPTION
from RDB$RELATION_FIELDS RF
  join RDB$FIELDS F
    on F.RDB$FIELD_NAME = RF.RDB$FIELD_SOURCE
  left outer join RDB$CHARACTER_SETS CH
    on CH.RDB$CHARACTER_SET_ID = F.RDB$CHARACTER_SET_ID
  left outer join RDB$COLLATIONS DCO
    on DCO.RDB$COLLATION_ID = F.RDB$COLLATION_ID
      and DCO.RDB$CHARACTER_SET_ID = F.RDB$CHARACTER_SET_ID
  where
    COALESCE(RF.RDB$SYSTEM_FLAG, 0) = 0
  order by
    RF.RDB$FIELD_POSITION;
/*-----------------------------------------------------------------------------------------------*/
set term ^ ;
/*-----------------------------------------------------------------------------------------------*/
create procedure SYS_FieldType(TableName VarChar(31), FieldName VarChar(31))
returns
  (Result VarChar(64))
as
begin
  select FIELD_TYPE from SYS_FieldInfo
    where TABLE_NAME = Upper(:TableName) and FIELD_NAME = Upper(:FieldName) into :Result;
  suspend;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure SYS_OnlyObj(Obj TSysStr32)
returns
  (Result TBoolean)
as
begin
  Obj = Upper(Obj);
  in autonomous transaction do
    if ((select count(*) from mon$call_stack where mon$object_name = :Obj) < 2)
    then
      Result = 1;
    else
      Result = 0;
  suspend;    
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure SYS_OnlyUser
returns
  (Result TBoolean)
as
begin
  in autonomous transaction do
    if ((select count(*) from mon$attachments where mon$user = CURRENT_USER) < 2)
    then
      Result = 1;
    else
      Result = 0;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure SYS_IP
returns
  (Result TIPV6str)
as
  declare p Integer;
  declare s TSysStr255;
begin
  select
      Upper(Substring(Trim(mon$remote_address) from 1 for 39))
    from
      mon$attachments
    where
      mon$attachment_id = CURRENT_CONNECTION
    into :s;

  p = Position('/',s);
  if (p > 0)
  then
    Result = Substring(s from 1 for p - 1);
  else
    Result = s;
  suspend;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure SYS_Proto
returns
  (Result TProto)
as
begin
  select
      Upper(Trim(mon$remote_protocol))
    from
      mon$attachments
    where
      mon$attachment_id = CURRENT_CONNECTION
    into :Result;
  suspend;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure SYS_DBName
returns
  (Result TPath)
as
begin
  select
      Upper(Trim(mon$database_name))
    from
      mon$database
    into :Result;
  suspend;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure SYS_DBOwner
returns
  (Result TSysStr31)
as
begin
  select first 1 Trim(rdb$owner_name)
    from rdb$relations where (rdb$system_flag = 1) into :Result;
  suspend;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure SYS_IsDBOwner(AUser TSysStr31)
returns
  (Result TBoolean)
as
begin
  if (AUser is null)
  then
    AUser = CURRENT_USER;
  else
    AUser = Upper(AUser);
  if (exists (select 1
    from
      rdb$relations
    where (rdb$system_flag = 1)
      and rdb$owner_name = :AUser))
  then
    Result = 1;
  suspend;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure SYS_IsRDB$ADMIN(AUser TSysStr31)
returns
  (Result TBoolean)
as
begin
  if (AUser is null)
  then
    AUser = CURRENT_USER;
  else
    AUser = Upper(AUser);
  if (exists (select 1
    from
      rdb$user_privileges P
    where P.rdb$privilege = 'M'
      and P.rdb$relation_name = 'RDB$ADMIN'
      and P.rdb$user = :AUser))
  then
    Result = 1;
  suspend;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure SYS_IsAuxSU(AUser TSysStr31)
returns
  (Result TBoolean)
as
begin
  if (AUser is null)
  then
    AUser = CURRENT_USER;
  else
    AUser = Upper(AUser);
  if (exists (select 1
    from
      rdb$user_privileges P
    where P.rdb$user = :AUser
      and P.rdb$privilege in ('A','I','D','U')
      and P.rdb$relation_name starting with 'P_T'))
  then
    Result = 1;
  suspend;    
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure SYS_IsSU(AUser TSysStr31)
returns
  (Result TBoolean)
as
begin
  if (AUser is null)
  then
    AUser = CURRENT_USER;
  else
    AUser = Upper(AUser);
  if (AUser = 'SYSDBA'
    or (select Result from SYS_IsDbOwner(:AUser)) = 1
    or (select Result from SYS_IsRDB$ADMIN(:AUser)) = 1
    or (select Result from SYS_IsAuxSU(:AUser)) = 1)
  then
    Result = 1;
  suspend;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure SYS_CheckExtAcc(AUser TSysStr31)
as
begin
  if (AUser is null)
  then
    AUser = CURRENT_USER;
  else
    AUser = Upper(AUser);
  if ((select Result from SYS_IsSU(:AUser)) = 1) then exception P_E$ExtAcc;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure SYS_CheckDB(
  DB TFullPath,
  Usr TUserName,
  PWD TPWD)
returns
  (Result TTrilean)
as
  declare h BigInt;
  declare h0 BigInt;
  declare pid SmallInt;
  declare tia SmallInt;
  declare pnm TSysStr31;
  declare stm TSysStr128;
begin
  stm = 'select rdb$procedure_name,rdb$procedure_id,Hash(rdb$procedure_blr) from rdb$procedures';
  for execute statement stm
    on external DB as user Usr password PWD
    into :pnm,:pid,:h
  do
    if (not exists (
      select 1
        from
          rdb$procedures
        where rdb$procedure_name = :pnm
          and rdb$procedure_id = :pid
          and Hash(rdb$procedure_blr) = :h))
    then
      begin
        Result = 0;
        exit;
      end
  stm = 'select rdb$trigger_name,rdb$trigger_type,rdb$trigger_inactive,Hash(rdb$trigger_blr) from rdb$triggers';
  for execute statement stm
    on external DB as user Usr password PWD
    into :pnm,:pid,:tia,:h
  do
    if (not exists (
      select 1
        from
          rdb$triggers
        where rdb$trigger_name = :pnm
          and rdb$trigger_type = :pid
          and rdb$trigger_inactive is not distinct from :tia
          and Hash(rdb$trigger_blr) = :h))
    then
      begin
        Result = 0;
        exit;
      end
  Result = 1;
  when any do Result = -1;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure SYS_RevokeAll(AUser TSysStr31)
as
begin
  if (AUser is not null) then
    execute statement 'revoke all on all from ' || AUser;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure SYS_DropAcc(AUser TSysStr31)
as
begin
  if (AUser is not null) then
  begin
    AUser = Upper(AUser);
    if (AUser <> 'SYSDBA'
      and (select Result from SYS_IsDBOwner(:AUser)) = 0)
    then
      in autonomous transaction do
      begin
        execute procedure SYS_RevokeAll(AUser);
        execute statement 'drop user '|| AUser;
      end
    when any do exit;
  end
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure SYS_AltAcc(AUser TSysStr31,APWD TSysStr31)
as
begin
  if (AUser is not null and APWD is not null) then
  begin
    in autonomous transaction do
      execute statement 'create user ' || AUser || ' password ''' || APWD ||'''';
    when any do
      execute statement 'alter user ' || AUser || ' password ''' || APWD ||'''';
  end
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure SYS_AltAdmAcc(AUser TSysStr31,APWD TSysStr31)
as
  declare sg TsysStr32;
begin
  if (AUser is not null and APWD is not null) then
  begin
    AUser = Upper(AUser);
    if (AUser <> 'SYSDBA'
      and (select Result from SYS_IsDBOwner(:AUser)) = 0)
    then
      begin
        begin
          sg = ' grant admin role';
          in autonomous transaction do
            execute statement 'create user '|| AUser ||' password ''' || APWD || '''' || sg;
          when any do
            execute statement 'alter user ' || AUser ||' password ''' || APWD || '''' || sg;
        end
        execute statement 'grant RDB$ADMIN to ' || AUser;
      end
  end
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure SYS_GrantExec(AProc TSysStr31, AUser TSysStr31)
as
begin
  if (AProc is not null and AUser is not null) then
    execute statement 'grant execute on procedure ' || AProc || ' to ' || AUser;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure SYS_GrantView(ARel TSysStr31, AUser TSysStr31)
as
begin
  if (ARel is not null and AUser is not null) then
    execute statement 'grant select on ' || ARel || ' to ' || AUser;
end^
/*-----------------------------------------------------------------------------------------------*/
-- TimeZone
create procedure SYS_UnixTMNow
returns
  (Result BigInt)
as
begin
  Result = DateDiff(Second,TimeStamp '1970-01-01 00:00:00',cast('NOW' as TimeStamp));
  suspend;
end^
/*-----------------------------------------------------------------------------------------------*/
-- TimeZone
create procedure SYS_UnixTMTran
returns
  (Result BigInt)
as
begin
  Result = DateDiff(Second,TimeStamp '1970-01-01 00:00:00',CURRENT_TIMESTAMP);
  suspend;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure SYS_UnixDays
returns
  (Result BigInt)
as
begin
  Result = DateDiff(Day,DATE '1970-01-01',CURRENT_DATE);
  suspend;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure SYS_IpStrToBin(IP TSysStr255)
returns
  (Result TSysStr255)
as
  declare pd Integer;
  declare d TIpDelim;
  declare px TSysStr2;
  declare tmp TSysStr255;
begin
  Result = '';
  execute procedure P_ExtractIPv4(IP) returning_values IP;
  if (Position(':',IP) = 0)
  then
    begin
      pd = 8;
      d ='.';
      px = '';
    end
  else
    begin
      pd = 16;
      d =':';
      px = '0x';
      execute procedure P_ExpandIPv6(IP) returning_values IP;
    end
  for select Result from SymbList(:d,:IP) into :tmp do
  begin
    execute procedure Math_IntToBin(px || tmp) returning_values tmp;
    Result = Result || LPad(tmp,pd,'0');
  end
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure SYS_Ip4StrToInt(IP TSysStr255)
returns
  (Result BigInt)
as
  declare tmp TSysStr255;
begin
  execute procedure SYS_IpStrToBin(IP) returning_values tmp;
  execute procedure Math_BinToInt(tmp) returning_values Result;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure SYS_IsLocalHost(IP TIPV6str)
returns
  (Result TBoolean)
as
begin
  if (Position('127.0.0.1',IP) > 0 /* ::ffff:127.0.0.1 */
    or Position('LOCALHOST',Upper(IP)) > 0)
  then
    Result = 1;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure SYS_IsSubNet(IP1 TIPV6str,IP2 TIPV6str, MLen SmallInt)
returns
  (Result TBoolean)
as
  declare f1 TBoolean;
  declare f2 TBoolean;  
  declare i1 TSysStr255;
  declare i2 TSysStr255;
begin
  if (MLen = 0)
  then
    begin
      execute procedure SYS_IsLocalHost(IP1) returning_values f1;
      execute procedure SYS_IsLocalHost(IP2) returning_values f2;      
      if (f1 = f2)
      then
        Result = 0;
      else
        Result = 1;
    end
  else
    begin
      execute procedure SYS_IpStrToBin(IP1) returning_values i1;
      execute procedure SYS_IpStrToBin(IP2) returning_values i2;
      if (Substring(i1 from 1 for MLen) <> Substring(i2 from 1 for MLen)) then Result = 1;
    end
end^
/*-----------------------------------------------------------------------------------------------*/
set term ; ^
/*-----------------------------------------------------------------------------------------------*/
create view SYS_CallStack(
  attachment_id,
  object_name,
  object_type)
as
  with recursive
    head as (
      select
        call.mon$statement_id, call.mon$call_id,
        call.mon$object_name, call.mon$object_type
      from mon$call_stack call
      where call.mon$caller_id is null
      union all
      select
        call.mon$statement_id, call.mon$call_id,
        call.mon$object_name, call.mon$object_type
      from mon$call_stack call
        join head
          on call.mon$caller_id = head.mon$call_id
    )
  select
    mon$attachment_id,
    Trim(mon$object_name),
    mon$object_type
  from head
    join mon$statements stmt
      on stmt.mon$statement_id = head.mon$statement_id
    where stmt.mon$attachment_id <> CURRENT_CONNECTION;
/*-----------------------------------------------------------------------------------------------*/
grant select on SYS_FieldInfo to procedure SYS_FieldType;

grant execute on procedure SYS_IsDBOwner to procedure SYS_DropAcc;
grant execute on procedure SYS_RevokeAll to procedure SYS_DropAcc;

grant execute on procedure SYS_IsDBOwner to procedure SYS_AltAdmAcc;

grant execute on procedure SYS_IsAuxSU to procedure SYS_IsSU;
grant execute on procedure SYS_IsDbOwner to procedure SYS_IsSU;
grant execute on procedure SYS_IsRDB$ADMIN to procedure SYS_IsSU;

grant execute on procedure SYS_IsSU to procedure SYS_CheckExtAcc;
grant execute on procedure SYS_UnixTMNow to PUBLIC;

grant execute on procedure SymbList to procedure SYS_IpStrToBin;
grant execute on procedure Math_IntToBin to procedure SYS_IpStrToBin;
grant execute on procedure P_ExpandIPv6 to procedure SYS_IpStrToBin;
grant execute on procedure P_ExtractIPv4 to procedure SYS_IpStrToBin;

grant execute on procedure Math_BinToInt to procedure SYS_Ip4StrToInt;
grant execute on procedure SYS_IpStrToBin to procedure SYS_Ip4StrToInt;

grant execute on procedure SYS_IpStrToBin to procedure SYS_IsSubNet;
grant execute on procedure SYS_IsLocalHost to procedure SYS_IsSubNet;

/*-----------------------------------------------------------------------------------------------*/
/*
grant select on RDB$TRIGGERS to procedure SYS_CHECKDB;
grant select on RDB$PROCEDURES to procedure SYS_CHECKDB;
grant select on RDB$RELATIONS to procedure SYS_DBOWNER;
grant select on RDB$USER_PRIVILEGES to procedure SYS_ISAUXSU;
grant select on RDB$RELATIONS to procedure SYS_ISDBOWNER;
grant select on RDB$USER_PRIVILEGES to procedure SYS_ISRDB$ADMIN;
grant select on MON$ATTACHMENTS to procedure SYS_ONLYUSER;
*/

