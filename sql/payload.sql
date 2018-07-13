/* ======================================================================== */
/* PeopleRelay: payload.sql Version: 0.4.3.6                                */
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

/*
-530=Foreign key reference...
-803=Attempt to store duplicate value (visible to active transactions)
-913 (335544320)= deadlock
*/

/*-----------------------------------------------------------------------------------------------*/
create exception PE$KeyWord 'Error: Cannot use Reserved Word as a user defined field name.';
/*-----------------------------------------------------------------------------------------------*/
create table P_TSndSQl(
  SQL               TMemo);
/*-----------------------------------------------------------------------------------------------*/
create global temporary table P$TFldFlt(
  Name              TSysStr32 not null,
  primary key       (Name)
) on commit delete rows;
/*-----------------------------------------------------------------------------------------------*/
set term ^ ;
/*-----------------------------------------------------------------------------------------------*/
create trigger P_TBI$TFldFlt for P$TFldFlt active before insert position 0
as
begin
  new.Name = Upper(new.Name);
end^
/*-----------------------------------------------------------------------------------------------*/
set term ; ^
/*-----------------------------------------------------------------------------------------------*/
create table P$TKeyWords(
  Name              TSysStr32 not null,
  primary key       (Name));
/*-----------------------------------------------------------------------------------------------*/
set term ^ ;
/*-----------------------------------------------------------------------------------------------*/
create trigger P_TBI$TKeyWords for P$TKeyWords active before insert position 0
as
begin
  new.Name = Upper(new.Name);
end^
/*-----------------------------------------------------------------------------------------------*/
create trigger P_TBU$TKeyWords for P$TKeyWords active before update position 0
as
begin
  new.Name = old.Name;
end^
/*-----------------------------------------------------------------------------------------------*/
create trigger P_TBD$TKeyWords for P$TKeyWords active before delete position 0
as
begin
  exception P_E$Forbidden;
end^
/*-----------------------------------------------------------------------------------------------*/
set term ; ^
/*-----------------------------------------------------------------------------------------------*/
create table P$TSysNames(
  TableName         TSysStr32 not null,
  Name              TSysStr32 not null,
  primary key       (TableName,Name));
/*-----------------------------------------------------------------------------------------------*/
set term ^ ;
/*-----------------------------------------------------------------------------------------------*/
create trigger P_TBI$TSysNames for P$TSysNames active before insert position 0
as
begin
  new.TableName = Upper(new.TableName);
  new.Name = Upper(new.Name);
end^
/*-----------------------------------------------------------------------------------------------*/
create trigger P_TBU$TSysNames for P$TSysNames active before update position 0
as
begin
  new.TableName = Upper(new.TableName);
  new.Name = old.Name;
end^
/*-----------------------------------------------------------------------------------------------*/
create trigger P_TBD$TSysNames for P$TSysNames active before delete position 0
as
begin
  exception P_E$Forbidden;
end^
/*-----------------------------------------------------------------------------------------------*/
set term ; ^
/*-----------------------------------------------------------------------------------------------*/
insert into P$TSysNames(TableName,Name) values('P_TChain','BlockNo');
insert into P$TSysNames(TableName,Name) values('P_TChain','BHash');
insert into P$TSysNames(TableName,Name) values('P_TChain','BlockId');
insert into P$TSysNames(TableName,Name) values('P_TChain','ParBlkNo');
insert into P$TSysNames(TableName,Name) values('P_TChain','ParBHash');
insert into P$TSysNames(TableName,Name) values('P_TChain','Chsum');
insert into P$TSysNames(TableName,Name) values('P_TChain','ParChsum');
insert into P$TSysNames(TableName,Name) values('P_TChain','BTime');
insert into P$TSysNames(TableName,Name) values('P_TChain','Address');
insert into P$TSysNames(TableName,Name) values('P_TChain','SenderId');
insert into P$TSysNames(TableName,Name) values('P_TChain','Nonce');
insert into P$TSysNames(TableName,Name) values('P_TChain','PubKey');
insert into P$TSysNames(TableName,Name) values('P_TChain','BSig');
insert into P$TSysNames(TableName,Name) values('P_TChain','TmpSig');
insert into P$TSysNames(TableName,Name) values('P_TChain','RecTime');
commit work;

insert into P$TSysNames(TableName,Name) values('P_TMeltingPot','RecId');
insert into P$TSysNames(TableName,Name) values('P_TMeltingPot','BHash');
insert into P$TSysNames(TableName,Name) values('P_TMeltingPot','BlockId');
insert into P$TSysNames(TableName,Name) values('P_TMeltingPot','ParBlkNo');
insert into P$TSysNames(TableName,Name) values('P_TMeltingPot','ParBHash');
insert into P$TSysNames(TableName,Name) values('P_TMeltingPot','Address');
insert into P$TSysNames(TableName,Name) values('P_TMeltingPot','SenderId');
insert into P$TSysNames(TableName,Name) values('P_TMeltingPot','Nonce');
insert into P$TSysNames(TableName,Name) values('P_TMeltingPot','PubKey');
insert into P$TSysNames(TableName,Name) values('P_TMeltingPot','BSig');
insert into P$TSysNames(TableName,Name) values('P_TMeltingPot','TmpSig');
insert into P$TSysNames(TableName,Name) values('P_TMeltingPot','State');
insert into P$TSysNames(TableName,Name) values('P_TMeltingPot','RT');
insert into P$TSysNames(TableName,Name) values('P_TMeltingPot','Own');
insert into P$TSysNames(TableName,Name) values('P_TMeltingPot','Sid');
commit work;

insert into P$TSysNames(TableName,Name) values('P_TBacklog','RecId');
insert into P$TSysNames(TableName,Name) values('P_TBacklog','BlockNo');
insert into P$TSysNames(TableName,Name) values('P_TBacklog','BHash');
insert into P$TSysNames(TableName,Name) values('P_TBacklog','BlockId');
insert into P$TSysNames(TableName,Name) values('P_TBacklog','ParBlkNo');
insert into P$TSysNames(TableName,Name) values('P_TBacklog','ParBHash');
insert into P$TSysNames(TableName,Name) values('P_TBacklog','Chsum');
insert into P$TSysNames(TableName,Name) values('P_TBacklog','ParChsum');
insert into P$TSysNames(TableName,Name) values('P_TBacklog','Address');
insert into P$TSysNames(TableName,Name) values('P_TBacklog','SenderId');
insert into P$TSysNames(TableName,Name) values('P_TBacklog','Nonce');
insert into P$TSysNames(TableName,Name) values('P_TBacklog','PubKey');
insert into P$TSysNames(TableName,Name) values('P_TBacklog','BSig');
insert into P$TSysNames(TableName,Name) values('P_TBacklog','RT');
commit work;
/*-----------------------------------------------------------------------------------------------*/
create table P_TFields(
  TableName         TSysStr31 default 'P_TCHAIN' not null,
  FieldName         TSysStr31 not null,
  TableBuf1         TSysStr31 default 'P_TMeltingPot' not null,
  TableBuf2         TSysStr31 default 'P_TBacklog' not null,
  DataType          TSysStr64 not null,
  DefVal            TString63,
  Constr            TSysStr127,
  CharSet           TSysStr64,  
  Encrypt           TBoolean,
  ToUTF             TBoolean,  
  primary key       (TableName,FieldName));
/*-----------------------------------------------------------------------------------------------*/
set term ^ ;
/*-----------------------------------------------------------------------------------------------*/
create trigger P_TBI$TFields for P_TFields active before insert position 0
as
begin
  if (exists (
    select 1 from P$TKeyWords where Name = Upper(new.FieldName)))
  then
    exception PE$KeyWord;
end^
/*-----------------------------------------------------------------------------------------------*/
create trigger P_TBU$TFields for P_TFields active before update position 0
as
begin
  if (exists (
    select 1 from P$TKeyWords where Name = Upper(new.FieldName)))
  then
    exception PE$KeyWord;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_EnumFields(RelName TSysStr31)
returns
  (Result TSysStr31)
as
begin
  RelName = Upper(RelName);
  for select
      Trim(rf.rdb$field_Name)
    from
      rdb$relation_fields rf
    where rf.rdb$relation_name = :RelName
      and rf.rdb$update_flag = 1
      and not exists (select 1 from P$TFldFlt F where F.Name = Trim(rf.rdb$field_Name))
    order by
      rf.rdb$field_position
    into :Result
  do
    suspend;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_FieldCount(RelName TSysStr31)
returns
  (Result TInt32)
as
begin
  select count(*) from P_EnumFields(:RelName) into :Result;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_DropField(TableName TSysStr31,FieldName TSysStr31)
as
begin
  TableName = Upper(TableName);
  FieldName = Upper(FieldName);
  if (not exists (select 1 from P$TSysNames
    where TableName = :TableName and Name = :FieldName)
      and exists(
        select 1 from rdb$relation_fields
        where rdb$relation_name = :TableName and rdb$field_name = :FieldName))
  then
    execute statement
      'alter table ' || TableName || ' drop ' || FieldName;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_DropFields(TableName TSysStr31)
as
  declare FieldName TSysStr31;
begin
  for select
    Result
    from
      P_EnumFields(:TableName)
    into
      :FieldName
  do
    execute procedure P_DropField(TableName,FieldName);
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_IsQuoted(DataType TSysStr64)
returns
  (Result TBoolean)
as
  declare ftype Smallint;
begin
  Result = 0;
  DataType = Upper(DataType);
  if (position('BLOB',DataType) = 1
    or position('CHAR',DataType) = 1
    or position('VARCHAR',DataType) = 1
    or DataType = 'DATE'
    or DataType = 'TIME'
    or DataType = 'TIMESTAMP'
    or DataType = 'TMEMO'
    or DataType = 'TTEXT'
    or DataType = 'TBLOB')
  then
    Result = 1;
  else
    begin
      select rdb$field_type from rdb$fields
        where rdb$field_name = :DataType into :ftype;
      if (ftype in (12, 13, 14, 35, 37, 40, 261)) then Result = 1;
    end
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P$EncType(DataType TSysStr64)
returns
  (Result SmallInt)
as
begin
  DataType = Upper(DataType);
  if (DataType starting with 'CHAR')
  then
    Result = 14;
  else
    if (DataType starting with 'VARCHAR')
    then
      Result = 37;
    else
      if (DataType starting with 'BLOB')
      then
        Result = 261;
      else
        select rdb$field_type from rdb$fields where rdb$field_name = :DataType into :Result;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P$EncStm(KeyName TSysStr31)
returns
  (Result TSysStr10k)
as
  declare AType SmallInt;
  declare AField TSysStr31;
  declare DataType TSysStr64;
begin
  Result = '';
  for select
       FieldName,
       DataType
     from
       P_TFields
     where
       Encrypt = 1
     into
       :AField,
       :DataType
  do
    begin
      execute procedure P$EncType(DataType) returning_values AType;
      if (AType = 14)
      then
        Result = Result || '  if(' || AField || ' is not null) then '
          || AField || ' = rsaEncrypt((select Result from P_BKeySz),' || KeyName || ',Trim(' || AField || '));' || ASCII_CHAR(10);
      else
        if (AType = 37)
        then
          Result = Result || '  if(' || AField || ' is not null) then '
            || AField || ' = rsaEncrypt((select Result from P_BKeySz),' || KeyName || ',' || AField || ');' || ASCII_CHAR(10);
        else
          if (AType = 261) then
            Result = Result || '  if(' || AField || ' is not null) then '
              || AField || ' = rsaEncBlob((select Result from P_BKeySz),' || KeyName || ',' || AField || ');' || ASCII_CHAR(10);
    end
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P$UTFStm
returns
  (Result TSysStr10k)
as
  declare AType TTrilean;
  declare AField TSysStr31;
  declare DataType TSysStr64;
begin
  Result = '';
  for select
       FieldName,
       DataType
     from
       P_TFields
     where
       ToUTF = 1
     into
       :AField,
       :DataType
  do
    begin
      execute procedure P$EncType(DataType) returning_values AType;
      if (AType = 0)
      then
        Result = Result || '  ' || AField || ' = StrToUTF(' || AField || ');' || ASCII_CHAR(10);
      else
        if (AType = 1) then
          Result = Result || '  ' || AField || ' = BlobToUTF(' || AField || ');' || ASCII_CHAR(10);
    end
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_CreateField(
  TableName TSysStr31,
  FieldName TSysStr31,
  DataType TSysStr64,
  DefVal TString63,
  Constr TSysStr128,
  CharSet TString63)
as
  declare f TBoolean;
  declare dv TString128;
  declare stm TString512;  
begin
  TableName = Upper(TableName);
  FieldName = Upper(FieldName);
  if (not exists(
    select 1 from rdb$relation_fields
      where rdb$relation_name = :TableName and rdb$field_name = :FieldName))
  then
    begin
      if (Constr is null or Constr = '')
      then
        Constr = '';
      else
        Constr = ' ' || Constr;
      if (CharSet is null or CharSet = '')
      then
        CharSet = '';
      else
        CharSet = ' ' || CharSet;
      if (DefVal is null or DefVal = '')
      then
        dv = '';
      else
        begin
          execute procedure P_IsQuoted(DataType) returning_values f;
          if (f = 0
            or position('''',DefVal) = 1
            or position('CURRENT_',DefVal) = 1)
          then
            dv = ' default ' || DefVal;
          else
            dv = ' default ''' || DefVal || '''';
        end
      stm = 'alter table ' || TableName
        || ' add ' || FieldName || ' '
        || DataType
        || dv
        || Constr
        || CharSet;
      execute statement stm;
    end
end^
/*-----------------------------------------------------------------------------------------------*/
create or alter procedure P_Args(RelName TSysStr31)
returns
  (Result TSysStr10k)
as
  declare s TSysStr31;
begin
  Result = '';
  for select
      Result
    from
      P_EnumFields(:RelName)
    into
      :s
  do
    Result = Result || '  ' || s || ' type of column ' || RelName || '.' || s || ',' || ASCII_CHAR(10);
  Result = Substring(Result from 1 for char_length(Result) - 2);
end^
/*-----------------------------------------------------------------------------------------------*/
create or alter procedure P_Args_x(RelName TSysStr31)
returns
  (Result TSysStr10k)
as
  declare s TSysStr31;
  declare ss TSysStr64;
begin
  Result = '';
  for select
      Result
    from
      P_EnumFields(:RelName)
    into
      :s
  do
    begin
      execute procedure SYS_FieldType(RelName,s) returning_values ss;
      Result = Result || '  ' || s || ' ' || ss || ',' || ASCII_CHAR(10);
    end
  Result = Substring(Result from 1 for char_length(Result) - 2);
end^
/*-----------------------------------------------------------------------------------------------*/
create or alter procedure P_Decl(RelName TSysStr31)
returns
  (Result TSysStr10k)
as
  declare s TSysStr31;
begin
  Result = '';
  for select
      Result
    from
      P_EnumFields(:RelName)
    into
      :s
  do
    Result = Result || '  declare ' || s || ' type of column ' || RelName || '.' || s || ';' || ASCII_CHAR(10);
end^
/*-----------------------------------------------------------------------------------------------*/
create or alter procedure P_FieldArgs(RelName TSysStr31)
returns
  (Result TSysStr10k)
as
begin
  Result = '';
  select List(Result, ',' || ASCII_CHAR(10) || '    ') from P_EnumFields(:RelName) into :Result;
  if (Result <> '') then Result = '    ' || Result;
end^
/*-----------------------------------------------------------------------------------------------*/
create or alter procedure P_Vars(RelName TSysStr31)
returns
  (Result TSysStr10k)
as
begin
  Result = '';
  select List(Result, ',' || ASCII_CHAR(10) || '    :') from P_EnumFields(:RelName) into :Result;
  if (Result <> '') then Result = '    :' || Result;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_MPArgFlt
as
begin
  delete from P$TFldFlt;
  insert into P$TFldFlt(Name) values('RecId');
  insert into P$TFldFlt(Name) values('BTime');
  insert into P$TFldFlt(Name) values('RecTime');
  insert into P$TFldFlt(Name) values('State');
  insert into P$TFldFlt(Name) values('RT');
  insert into P$TFldFlt(Name) values('Own');
  insert into P$TFldFlt(Name) values('Sid');
  insert into P$TFldFlt(Name) values('TmpSig');
end^
/*-----------------------------------------------------------------------------------------------*/
create or alter procedure P_FieldHash
returns
  (Result TSysStr10k)
as
begin
  Result = '';
  delete from P$TFldFlt;
  insert into P$TFldFlt(Name) values('Nonce');
  insert into P$TFldFlt(Name) values('PubKey');
  insert into P$TFldFlt(Name) values('BlockNo');
  insert into P$TFldFlt(Name) values('BSig');
  insert into P$TFldFlt(Name) values('TmpSig');
  insert into P$TFldFlt(Name) values('BHash');
  insert into P$TFldFlt(Name) values('BTime');
  insert into P$TFldFlt(Name) values('ParBlkNo');
  insert into P$TFldFlt(Name) values('ParBHash');
  insert into P$TFldFlt(Name) values('Chsum');
  insert into P$TFldFlt(Name) values('ParChsum');
  insert into P$TFldFlt(Name) values('RecTime');

  select List(Result, ',''0'') || ''-'' || ' || ASCII_CHAR(10) || '    coalesce(')
    from P_EnumFields('P_TChain') into :Result;
  if (Result <> '') then Result = 'A_Cast || coalesce(' || Result || ',''0'') || ''-'' || Nonce';
  /* You have to add: declare A_Cast VarChar(1) = ''''; into every PeopleRelay proc using P_FieldHash */

  /*
    You have to add these two strings into Client DB proc:
    1. declare A_Cast VarChar(1) character set <DEFAULT CHARACTER SET of PeopleRelay database> = '';
    2. A_Cast || coalesce(BlockId,'0')
  */
  delete from P$TFldFlt where Name = 'NONCE';

end^
/*-----------------------------------------------------------------------------------------------*/
create or alter procedure P_StmFields(RelName TSysStr31)
returns
  (Result TSysStr10k)
as
  declare s TSysStr31;
  declare delim TSysStr1;
  declare TextLen TInt32;
begin
  delim = '';
  Result = '';
  TextLen = 0;
  for select
      Result
    from
      P_EnumFields(:RelName)
    into
      :s
  do
    begin
      TextLen = TextLen + char_length(s);
      if (TextLen >= 96) then
      begin
        Result = Result || '''' || ASCII_CHAR(10) || '  || ''';
        TextLen = 0;
      end
      Result = Result || delim || s;
      delim = ',';
    end
end^
/*-----------------------------------------------------------------------------------------------*/
create or alter procedure P_S$AddBlock
as
  declare Script TMemo;
  declare args TSysStr10k;
  declare VarList TSysStr10k;
  declare FieldArgs TSysStr10k;
  declare FieldHash TSysStr10k;
begin
  execute procedure P_MPArgFlt;
  execute procedure P_Args('P_TMeltingPot') returning_values args;
  execute procedure P_Vars('P_TMeltingPot') returning_values VarList;
  execute procedure P_FieldArgs('P_TMeltingPot') returning_values FieldArgs;
  execute procedure P_FieldHash returning_values FieldHash;
  Script = 'create or alter procedure P_AddBlock(' || ASCII_CHAR(10) || args || ')' || ASCII_CHAR(10)
    || 'returns (Result TInt32,ErrState TErrState)' || ASCII_CHAR(10)
    || 'as' || ASCII_CHAR(10)
    || '  declare A_Cast VarChar(1) = '''';' || ASCII_CHAR(10)
    || '  declare A_Line TBoolean;' || ASCII_CHAR(10)
    || '  declare A_Acc TBoolean;' || ASCII_CHAR(10)
    || '  declare A_ChHsh TBoolean;' || ASCII_CHAR(10)
    || '  declare A_ChSig TBoolean;' || ASCII_CHAR(10)
    || '  declare A_Test TBoolean;' || ASCII_CHAR(10)
    || '  declare A_Hash TChHash;' || ASCII_CHAR(10)
    || '  declare A_Data TMemo;' || ASCII_CHAR(10)
    || 'begin' || ASCII_CHAR(10)
    || '  Result = 0;' || ASCII_CHAR(10)
    || '  execute procedure P_BegAddB returning_values A_Test;' || ASCII_CHAR(10)
    || '  if (A_Test = 0) then exit;' || ASCII_CHAR(10)

    || '  select Online,Acceptor,ChckHshCL,ChckSigCL from P_TParams' || ASCII_CHAR(10)
    || '    into :A_Line,:A_Acc,:A_ChHsh,:A_ChSig;' || ASCII_CHAR(10)

    || '  if ((select Result from P_IsSender) = 0) then' || ASCII_CHAR(10)
    || '  begin' || ASCII_CHAR(10)
    || '    Result = -1;' || ASCII_CHAR(10)
    || '    execute procedure P_LogSndErr(-1001,0,0,null,''P_AddBlock'',SenderId,''Unknown Sender'');' || ASCII_CHAR(10)
    || '    exit;' || ASCII_CHAR(10)
    || '  end' || ASCII_CHAR(10)

    || '  if (A_Line = 0) then' || ASCII_CHAR(10)
    || '  begin' || ASCII_CHAR(10)
    || '    Result = -2;' || ASCII_CHAR(10)
    || '    execute procedure P_LogSndErr(-1002,0,0,null,''P_AddBlock'',SenderId,''DB is Offline'');' || ASCII_CHAR(10)
    || '    exit;' || ASCII_CHAR(10)
    || '  end' || ASCII_CHAR(10)
    || '  if (A_Acc = 0) then' || ASCII_CHAR(10)
    || '  begin' || ASCII_CHAR(10)
    || '    Result = -3;' || ASCII_CHAR(10)
    || '    execute procedure P_LogSndErr(-1003,0,0,null,''P_AddBlock'',SenderId,''Can add block in Acceptor mode only'');' || ASCII_CHAR(10)
    || '    exit;' || ASCII_CHAR(10)
    || '  end' || ASCII_CHAR(10)

    || '  if ((select Result from P_HasBlock(:SenderId,:BlockId)) > -1) then' || ASCII_CHAR(10)
    || '  begin' || ASCII_CHAR(10)
    || '    Result = -4;' || ASCII_CHAR(10)
    || '    execute procedure P_LogSndErr(-1004,0,0,null,''P_AddBlock'',SenderId,''Block alredy exists'');' || ASCII_CHAR(10)
    || '    exit;' || ASCII_CHAR(10)
    || '  end' || ASCII_CHAR(10)

    || '  if ((select Result from P_IsHash(:BHash)) = 0) then' || ASCII_CHAR(10)
    || '  begin' || ASCII_CHAR(10)
    || '    Result = -5;' || ASCII_CHAR(10)    
    || '    execute procedure P_LogSndErr(-1005,0,0,null,''P_AddBlock'',SenderId,''Block PoW Error'');' || ASCII_CHAR(10)
    || '    exit;' || ASCII_CHAR(10)
    || '  end' || ASCII_CHAR(10)

    || '  if (A_ChHsh = 1) then' || ASCII_CHAR(10)
    || '  begin' || ASCII_CHAR(10)
    || '    A_Data = ' || FieldHash ||';' || ASCII_CHAR(10)
    || '    execute procedure P_CalcHash(A_Data) returning_values A_Hash;' || ASCII_CHAR(10)
    || '    if (A_Hash <> BHash) then' || ASCII_CHAR(10)
    || '    begin' || ASCII_CHAR(10)
    || '      Result = -6;' || ASCII_CHAR(10)
    || '      execute procedure P_LogSndErr(-1006,0,0,null,''P_AddBlock'',SenderId,''Block Hash Error'');' || ASCII_CHAR(10)
    || '      exit;' || ASCII_CHAR(10)
    || '    end' || ASCII_CHAR(10)
    || '  end' || ASCII_CHAR(10)
    || '  if (A_ChSig = 1) then' || ASCII_CHAR(10)
    || '  begin' || ASCII_CHAR(10)
    || '    execute procedure P_IsBlockSig(BHash,BSig,PubKey) returning_values A_Test;' || ASCII_CHAR(10)
    || '    if (A_Test = 0) then' || ASCII_CHAR(10)
    || '    begin' || ASCII_CHAR(10)
    || '      Result = -7;' || ASCII_CHAR(10)
    || '      execute procedure P_LogSndErr(-1007,0,0,null,''P_AddBlock'',SenderId,''Block Sig Error'');' || ASCII_CHAR(10)
    || '      exit;' || ASCII_CHAR(10)
    || '    end' || ASCII_CHAR(10)
    || '  end' || ASCII_CHAR(10)
    || '  begin' || ASCII_CHAR(10)
    || '    insert into P_TMeltingPot(' || ASCII_CHAR(10) || FieldArgs || ')' || ASCII_CHAR(10)
    || '    values(' || ASCII_CHAR(10) || VarList || ');' || ASCII_CHAR(10)
    || '    execute procedure P_LogSndMsg(100,0,0,null,''P_AddBlock'',SenderId,BlockId,''New block'');' || ASCII_CHAR(10)
    || '    when any do' || ASCII_CHAR(10)
    || '      if (sqlcode = -803)' || ASCII_CHAR(10)
    || '      then' || ASCII_CHAR(10)
    || '        begin' || ASCII_CHAR(10)
    || '          Result = -8;' || ASCII_CHAR(10)
    || '          execute procedure P_LogSndErr(-1008,0,0,null,''P_AddBlock'',SenderId,''Block alredy exists'');' || ASCII_CHAR(10)
    || '          exit;' || ASCII_CHAR(10)        
    || '        end' || ASCII_CHAR(10)
    || '      else' || ASCII_CHAR(10)
    || '        begin' || ASCII_CHAR(10)
    || '          Result = -9;' || ASCII_CHAR(10)
    || '          ErrState = sqlstate;' || ASCII_CHAR(10)
    || '          execute procedure P_LogSndErr(-1009,sqlcode,gdscode,sqlstate,''P_AddBlock'',SenderId,null);' || ASCII_CHAR(10)
    || '          exit;' || ASCII_CHAR(10)
    || '        end' || ASCII_CHAR(10)
    || '  end' || ASCII_CHAR(10)
    || '  Result = row_count;' || ASCII_CHAR(10)
    || '  execute procedure P_OnGetBlock(SenderId,BlockId);' || ASCII_CHAR(10)
    || '  execute procedure P_EndAddB;' || ASCII_CHAR(10)
    || '  when any do' || ASCII_CHAR(10)
    || '  begin' || ASCII_CHAR(10)
    || '    Result = -10;' || ASCII_CHAR(10)
    || '    ErrState = sqlstate;' || ASCII_CHAR(10)
    || '    execute procedure P_EndAddB;' || ASCII_CHAR(10)
    || '    execute procedure P_LogSndErr(-1010,sqlcode,gdscode,sqlstate,''P_AddBlock'',SenderId,null);' || ASCII_CHAR(10)
    || '  end' || ASCII_CHAR(10)
    || 'end';
  execute statement Script;
end^
/*-----------------------------------------------------------------------------------------------*/
create or alter procedure P_S$ReplChain(
  DeclVar TSysStr10k,
  VarList TSysStr10k,
  FieldList TSysStr10k,

  VarList1 TSysStr10k,
  FieldArgs TSysStr10k)
as
  declare CmpField TSysStr31;
  declare FieldHash TSysStr10k;
  declare Script TMemo;
begin
  execute procedure P_FieldHash returning_values FieldHash;
  FieldHash = Replace(FieldHash,'    ','        ');

  Script = 'create or alter procedure PG_Chain(NodeRId TRef,A_DB TFullPath,A_USR TUserName,A_PWD TPWD)' || ASCII_CHAR(10)
    || 'returns(Rec_Cnt TCount)' || ASCII_CHAR(10)
    || 'as' || ASCII_CHAR(10)
    || DeclVar || ASCII_CHAR(10)
    || '  declare A_Cast VarChar(1) = '''';' || ASCII_CHAR(10)    
    || '  declare A_Test TBoolean;' || ASCII_CHAR(10)
    || '  declare A_Skip TBoolean;' || ASCII_CHAR(10)
    || '  declare A_Acc TBoolean;' || ASCII_CHAR(10)
    || '  declare A_ChHsh TBoolean;' || ASCII_CHAR(10)
    || '  declare A_ChTmS TBoolean;' || ASCII_CHAR(10)
    || '  declare A_ChSig TBoolean;' || ASCII_CHAR(10)
    || '  declare A_TB TBoolean;' || ASCII_CHAR(10)
    || '  declare A_NdId TNodeId;' || ASCII_CHAR(10)
    || '  declare A_PNId TNodeId;' || ASCII_CHAR(10)
    || '  declare A_Hash TChHash;' || ASCII_CHAR(10)
    || '  declare A_Rid TRef;' || ASCII_CHAR(10)
    || '  declare A_Tmp TRef;' || ASCII_CHAR(10)    
    || '  declare PeerKey TKey;' || ASCII_CHAR(10)
    || '  declare stm TSysStr10K;' || ASCII_CHAR(10)
    || '  declare stm2 TSysStr255;' || ASCII_CHAR(10)
    || '  declare A_Data TMemo;' || ASCII_CHAR(10)
    || 'begin' || ASCII_CHAR(10)
    || '  Rec_Cnt = 0;' || ASCII_CHAR(10)
    || '  select NodeId,Acceptor,PubKey from P_TPeer where RecId = :NodeRId into :A_NdId,:A_Acc,:PeerKey;' || ASCII_CHAR(10)
    || '  select CHTokenBus,ChckHshCH,ChckTmSCH,ChckSigCH from P_TParams into :A_TB,:A_ChHsh,:A_ChTmS,:A_ChSig;' || ASCII_CHAR(10)
    || '  select max(BlockNo) from P_TChain into :A_Rid;' || ASCII_CHAR(10)
    || '  stm = ''select ' || FieldList || ' from P_Chain where BlockNo > ?'';' || ASCII_CHAR(10)
    || '  stm2 = ''select NodeId from P_TSMVoter where BHash = ?'';' || ASCII_CHAR(10)

    || '  for execute statement (stm) (:A_Rid)' || ASCII_CHAR(10)
    || '    on external A_DB as user A_USR password A_PWD' || ASCII_CHAR(10)
    || '  into' || ASCII_CHAR(10) || VarList || ASCII_CHAR(10)
    || '  do' || ASCII_CHAR(10)
    || '  begin' || ASCII_CHAR(10)
    || '    A_Skip = 0;' || ASCII_CHAR(10);
  VarList1 = Replace(VarList1,'    ','          ');
  FieldArgs = Replace(FieldArgs,'    ','          ');
  Script = Script

    || '    if (A_ChTmS = 1) then' || ASCII_CHAR(10)
    || '    begin' || ASCII_CHAR(10)
    || '      execute procedure P_IsSysSig(BHash,TmpSig,PeerKey) returning_values A_Test;' || ASCII_CHAR(10)
    || '      if (A_Test = 0) then' || ASCII_CHAR(10)
    || '      begin' || ASCII_CHAR(10)
    || '        A_Skip = 1;' || ASCII_CHAR(10)
    || '        execute procedure P_BadTmS(NodeRId,A_NdId,''PG_Chain'');' || ASCII_CHAR(10)
    || '      end' || ASCII_CHAR(10)
    || '    end' || ASCII_CHAR(10)

    || '    if (A_Skip = 0 and (select Result from P_IsHash(:BHash)) = 0) then' || ASCII_CHAR(10)
    || '    begin' || ASCII_CHAR(10)
    || '      A_Skip = 1;' || ASCII_CHAR(10)
    || '      execute procedure P_BadHash(NodeRId,A_NdId,''PG_Chain'');' || ASCII_CHAR(10)
    || '    end' || ASCII_CHAR(10)

    || '    if (A_Skip = 0 and A_ChHsh = 1) then' || ASCII_CHAR(10)
    || '    begin' || ASCII_CHAR(10)
    || '      A_Data = ' || FieldHash ||';' || ASCII_CHAR(10)
    || '      execute procedure P_CalcHash(A_Data) returning_values A_Hash;' || ASCII_CHAR(10)
    || '      if (A_Hash <> BHash) then' || ASCII_CHAR(10)
    || '      begin' || ASCII_CHAR(10)
    || '        A_Skip = 1;' || ASCII_CHAR(10)
    || '        execute procedure P_BadHash(NodeRId,A_NdId,''PG_Chain'');' || ASCII_CHAR(10)
    || '      end' || ASCII_CHAR(10)
    || '    end' || ASCII_CHAR(10)
    || '    if (A_Skip = 0) then' || ASCII_CHAR(10)
    || '    begin' || ASCII_CHAR(10)
    || '      if (A_ChSig = 1) then' || ASCII_CHAR(10)
    || '      begin' || ASCII_CHAR(10)
    || '        execute procedure P_IsBlockSig(BHash,BSig,PubKey) returning_values A_Test;' || ASCII_CHAR(10)
    || '        if (A_Test = 0) then' || ASCII_CHAR(10)
    || '        begin' || ASCII_CHAR(10)
    || '          A_Skip = 1;' || ASCII_CHAR(10)
    || '          execute procedure P_BadSign(NodeRId,A_NdId,''PG_Chain'');' || ASCII_CHAR(10)
    || '        end' || ASCII_CHAR(10)
    || '      end' || ASCII_CHAR(10)
    || '      if (A_Skip = 0) then' || ASCII_CHAR(10)
    || '      begin' || ASCII_CHAR(10)
    || '        A_Tmp = null;' || ASCII_CHAR(10)
    || '        select RecId from P_TBacklog' || ASCII_CHAR(10)
    || '          where BlockNo =:BlockNo and Chsum = :Chsum and BHash = :BHash' || ASCII_CHAR(10)
    || '          into :A_Tmp;' || ASCII_CHAR(10)

    || '        if (A_Tmp is null) then' || ASCII_CHAR(10)
    || '        begin' || ASCII_CHAR(10)
    || '          insert into P_TBacklog(' || ASCII_CHAR(10) || FieldArgs || ')' || ASCII_CHAR(10)
    || '            values(' || ASCII_CHAR(10) || VarList1 || ')' || ASCII_CHAR(10)
    || '            returning RecId into :A_Tmp;' || ASCII_CHAR(10)

    || '          Rec_Cnt = Rec_Cnt + 1;' || ASCII_CHAR(10)
    || '          when any do' || ASCII_CHAR(10)
    || '          begin' || ASCII_CHAR(10)
    || '            execute procedure P_LogErr(-161,sqlcode,gdscode,sqlstate,''PG_Chain'',A_NdId,''P_TBacklog'',null);' || ASCII_CHAR(10)
    || '            if (not (sqlcode in (-803,-530))) then Leave;' || ASCII_CHAR(10)
    || '          end' || ASCII_CHAR(10)
    || '        end' || ASCII_CHAR(10)

    || '        if (not exists (select 1 from P_TSMVoter' || ASCII_CHAR(10)
    || '          where ParId =:A_Tmp and NodeId = :A_NdId))' || ASCII_CHAR(10)

    || '        then' || ASCII_CHAR(10)
    || '          begin' || ASCII_CHAR(10)
    || '            insert into P_TSMVoter(ParId,BlockNo,BHash,NodeId,Acceptor)' || ASCII_CHAR(10)
    || '              values(:A_Tmp,:BlockNo,:BHash,:A_NdId,:A_Acc);' || ASCII_CHAR(10)
    || '            when any do' || ASCII_CHAR(10)
    || '            begin' || ASCII_CHAR(10)
    || '              execute procedure P_LogErr(-162,sqlcode,gdscode,sqlstate,''PG_Chain'',A_NdId,''P_TSMVoter'',null);' || ASCII_CHAR(10)
    || '              if (not (sqlcode in (-803,-530))) then Leave;' || ASCII_CHAR(10)
    || '            end' || ASCII_CHAR(10)
    || '          end' || ASCII_CHAR(10)
    || '        if (A_TB = 1) then' || ASCII_CHAR(10)
    || '          for execute statement (stm2) (:BHash)' || ASCII_CHAR(10)
    || '            on external A_DB as user A_USR password A_PWD' || ASCII_CHAR(10)
    || '            into :A_PNId' || ASCII_CHAR(10)
    || '          do' || ASCII_CHAR(10)
    || '            if (not exists (select 1 from P_TSMVoter' || ASCII_CHAR(10)
    || '              where BHash = :BHash and NodeId = :A_PNId))' || ASCII_CHAR(10)
    || '            then' || ASCII_CHAR(10)
    || '              begin' || ASCII_CHAR(10)
    || '                insert into P_TSMVoter(ParId,BlockNo,BHash,NodeId,Acceptor)' || ASCII_CHAR(10)
    || '                  values(:A_Tmp,:BlockNo,:BHash,:A_PNId,:A_Acc);' || ASCII_CHAR(10)
    || '                when any do' || ASCII_CHAR(10)
    || '                begin' || ASCII_CHAR(10)
    || '                  execute procedure P_LogErr(-163,sqlcode,gdscode,sqlstate,''PG_Chain'',A_NdId,''P_TSMVoter'',null);' || ASCII_CHAR(10)
    || '                  if (not (sqlcode in (-803,-530))) then exit;' || ASCII_CHAR(10)
    || '                end' || ASCII_CHAR(10)
    || '              end' || ASCII_CHAR(10)
    || '      end' || ASCII_CHAR(10)
    || '    end' || ASCII_CHAR(10)
    || '    when any do' || ASCII_CHAR(10)
    || '      execute procedure P_LogErr(-160,sqlcode,gdscode,sqlstate,''PG_Chain'',A_NdId,null,null);' || ASCII_CHAR(10)
    || '  end' || ASCII_CHAR(10)
    || 'end';
  execute statement Script;
end^
/*-----------------------------------------------------------------------------------------------*/
create or alter procedure P_S$FixChain(FieldArgs TSysStr10k)
as
  declare Script TMemo;
begin
  FieldArgs = Replace(FieldArgs,'    ','      ');

  Script =   'create or alter view P_BLV as' || ASCII_CHAR(10)
    || 'select' || ASCII_CHAR(10)  
    || '(select count(*) from P_TSMVoter V where V.BlockNo = B.BlockNo) as VtTot,' || ASCII_CHAR(10)
    || '(select count(*) from P_TSMVoter V where V.BlockNo = B.BlockNo and V.Acceptor = 1) as VtAcc,' || ASCII_CHAR(10)
    || '(select count(*) from P_TSMVoter V where V.ParId = B.RecId) as VtRec,' || ASCII_CHAR(10)
    || 'B.*' || ASCII_CHAR(10)
    || 'from P_TBackLog B' || ASCII_CHAR(10);
  execute statement Script;

  Script = 'create or alter procedure P_FixChain(A_Acc TBoolean)' || ASCII_CHAR(10)
    || 'returns(Rec_Cnt TCount)' || ASCII_CHAR(10)
    || 'as' || ASCII_CHAR(10)
    || '  declare A_Rid TRef;' || ASCII_CHAR(10)
    || '  declare A_Tmp TRef;' || ASCII_CHAR(10)
    || '  declare A_ChSm TIntHash;' || ASCII_CHAR(10)
    || '  declare A_Hash TChHash;' || ASCII_CHAR(10)
    || '  declare A_Tmp2 TCount;' || ASCII_CHAR(10)
    || '  declare A_QA TCount;' || ASCII_CHAR(10)
    || '  declare A_QT TCount;' || ASCII_CHAR(10)
    || 'begin' || ASCII_CHAR(10)
    || '  Rec_Cnt = 0;' || ASCII_CHAR(10)
    || '  execute procedure P_AssentAcc(1) returning_values A_QA;' || ASCII_CHAR(10)
    || '  execute procedure P_AssentTot(1) returning_values A_QT;' || ASCII_CHAR(10)
    || '  select first 1 BlockNo,Chsum,BHash from P_TChain' || ASCII_CHAR(10)
    || '    order by BlockNo desc into :A_Rid,:A_ChSm,:A_Hash;' || ASCII_CHAR(10)

    || '  if (not exists (select 1 from P_TBacklog' || ASCII_CHAR(10)
    || '        where ParBlkNo = :A_Rid and ParChsum = :A_ChSm and ParBHash = :A_Hash)' || ASCII_CHAR(10)
    || '    and exists (select 1 from P_TBacklog where ParBlkNo = :A_Rid)) then' || ASCII_CHAR(10)
    || '  begin' || ASCII_CHAR(10)
    || '    execute procedure P_Dehorn(A_Rid,1);' || ASCII_CHAR(10)
    || '    A_Rid = null;' || ASCII_CHAR(10)
    || '  end' || ASCII_CHAR(10)

    || '  while (A_Rid is not null) do' || ASCII_CHAR(10)
    || '  begin' || ASCII_CHAR(10)
    || '    A_Tmp = null;' || ASCII_CHAR(10)
    || '    insert into P_TChain(' || ASCII_CHAR(10) || FieldArgs || ')' || ASCII_CHAR(10)
    || '    select first 1' || ASCII_CHAR(10) || FieldArgs || ASCII_CHAR(10)
    || '      from P_BLV' || ASCII_CHAR(10)
    || '      where ParBlkNo = :A_Rid' || ASCII_CHAR(10)
    || '        and ParChsum = :A_ChSm' || ASCII_CHAR(10)
    || '        and ParBHash = :A_Hash' || ASCII_CHAR(10)
    || '        and (:A_Acc = 1 or VtTot >= :A_QT or VtAcc >= :A_QA)' || ASCII_CHAR(10)
    || '      order by BlockNo,VtTot desc,VtAcc desc,VtRec desc,Chsum,BHash' || ASCII_CHAR(10)
    || '      returning BlockNo,Chsum,BHash into :A_Tmp,:A_ChSm,:A_Hash;' || ASCII_CHAR(10)
    || '    A_Rid = A_Tmp;' || ASCII_CHAR(10)
    || '    if (A_Rid is not null) then Rec_Cnt = Rec_Cnt + 1;' || ASCII_CHAR(10)
    || '  end' || ASCII_CHAR(10)

    || '  when any do' || ASCII_CHAR(10)
    || '  begin' || ASCII_CHAR(10)
    || '    Rec_Cnt = sqlcode;' || ASCII_CHAR(10)
    || '    if (sqlcode in (-803,-530))' || ASCII_CHAR(10)
    || '    then' || ASCII_CHAR(10)
    || '      execute procedure P_Repair(sqlcode,A_Rid);' || ASCII_CHAR(10)
    || '    else' || ASCII_CHAR(10)
    || '      execute procedure P_LogErr(-170,sqlcode,gdscode,sqlstate,''P_FixChain'',null,null,null);' || ASCII_CHAR(10)
    || '  end' || ASCII_CHAR(10)

    || 'end';
  execute statement Script;
end^
/*-----------------------------------------------------------------------------------------------*/
create or alter procedure P_S$MPRep(
  DeclVar TSysStr10k,
  VarList TSysStr10k,
  FieldList TSysStr10k,
  VarList1 TSysStr10k,
  FieldArgs TSysStr10k)
as
  declare FieldHash TSysStr10k;
  declare Script TMemo;
begin
  execute procedure P_FieldHash returning_values FieldHash;
  Script = 'create or alter procedure PG_MeltingPot(NodeRId TRef,A_DB TFullPath,A_USR TUserName,A_PWD TPWD)' || ASCII_CHAR(10)
    || 'returns(Rec_Cnt TCount)' || ASCII_CHAR(10)
    || 'as' || ASCII_CHAR(10)
    || DeclVar || ASCII_CHAR(10)
    || '  declare A_Cast VarChar(1) = '''';' || ASCII_CHAR(10)
    || '  declare A_Test TBoolean;' || ASCII_CHAR(10)
    || '  declare A_Rid TRef;' || ASCII_CHAR(10)
    || '  declare A_Tmp3 TRef;' || ASCII_CHAR(10)
    || '  declare A_MPId TRef;' || ASCII_CHAR(10)
    || '  declare A_TB TBoolean;' || ASCII_CHAR(10)
    || '  declare A_RT TCount;' || ASCII_CHAR(10)
    || '  declare A_Tmp TRef;' || ASCII_CHAR(10)
    || '  declare A_ChHsh TBoolean;' || ASCII_CHAR(10)
    || '  declare A_ChTmS TBoolean;' || ASCII_CHAR(10)
    || '  declare A_ChSig TBoolean;' || ASCII_CHAR(10)
    || '  declare A_Skip TBoolean;' || ASCII_CHAR(10)
    || '  declare A_Tmp2 TSysStr32;' || ASCII_CHAR(10)
    || '  declare A_NdId TNodeId;' || ASCII_CHAR(10)
    || '  declare A_PNId TNodeId;' || ASCII_CHAR(10)
    || '  declare A_Hash TChHash;' || ASCII_CHAR(10)
    || '  declare PeerKey TKey;' || ASCII_CHAR(10)
    || '  declare A_Data TMemo;' || ASCII_CHAR(10)
    || '  declare stm TSysStr10K;' || ASCII_CHAR(10)
    || '  declare stm2 TSysStr255;' || ASCII_CHAR(10)
    || 'begin' || ASCII_CHAR(10)
    || '  Rec_Cnt = 0;' || ASCII_CHAR(10)
    || '  A_Tmp2 = ''PG_MeltingPot'';' || ASCII_CHAR(10)
    || '  stm = ''select ' || FieldList || ' from P_MeltingPot where Sid > ? order by Sid'';' || ASCII_CHAR(10)
    || '  stm2 = ''select NodeId from P_TMPVoter where BHash = ?'';' || ASCII_CHAR(10)
    || '  select NodeId,PubKey from P_TPeer where RecId = :NodeRId into :A_NdId,:PeerKey;' || ASCII_CHAR(10)
    || '  select first 1 MPId from P_TMPidLog' || ASCII_CHAR(10)
    || '    where ParId = :NodeRId order by RecId desc into :A_MPId;' || ASCII_CHAR(10)
    || '  if (A_MPId is null) then A_MPId = 0;' || ASCII_CHAR(10)
    || '  A_Tmp3 = A_MPId;' || ASCII_CHAR(10)
    || '  select (:A_MPId - MPOverlap),MPTokenBus,ChckHshMP,ChckTmSMP,ChckSigMP,(Gen_Id(P_G$RTT,0) - LacunaSpan)' || ASCII_CHAR(10)
    || '    from P_TParams into :A_MPId,:A_TB,:A_ChHsh,:A_ChTmS,:A_ChSig,:A_RT;' || ASCII_CHAR(10)
    || '  if (A_MPId < 0) then A_MPId = 0;' || ASCII_CHAR(10)
    || '  A_Tmp = A_MPId;' || ASCII_CHAR(10)
    || '  execute procedure P_BegReplEx;' || ASCII_CHAR(10)
    || '  for execute statement (stm) (:A_MPId)' || ASCII_CHAR(10)
    || '    on external A_DB as user A_USR password A_PWD' || ASCII_CHAR(10)
    || '  into' || ASCII_CHAR(10) || VarList || ASCII_CHAR(10)
    || '  do' || ASCII_CHAR(10)
    || '  begin' || ASCII_CHAR(10)
    || '    A_Skip = 0;' || ASCII_CHAR(10)
    || '    A_Rid = null;' || ASCII_CHAR(10)
    || '    if ((Sid - A_Tmp) = 1)' || ASCII_CHAR(10)
    || '    then' || ASCII_CHAR(10)
    || '      A_Tmp = Sid;' || ASCII_CHAR(10)
    || '    else' || ASCII_CHAR(10)
    || '      if (RT > A_RT)' || ASCII_CHAR(10) --Lacuna, wait for transaction commit.
    || '      then' || ASCII_CHAR(10)
    || '        begin' || ASCII_CHAR(10)
    || '          Sid = A_Tmp;' || ASCII_CHAR(10)
    || '          execute procedure P_LogMsg(340,Sid,A_Tmp,0,A_Tmp2,null,null,null);' || ASCII_CHAR(10)
    || '          Leave;' || ASCII_CHAR(10)
    || '        end' || ASCII_CHAR(10)
    || '      else' || ASCII_CHAR(10)
    || '        begin' || ASCII_CHAR(10)
    || '          A_Tmp = Sid;' || ASCII_CHAR(10)
    || '          execute procedure P_LogMsg(350,Sid,A_Tmp,0,A_Tmp2,null,null,null);' || ASCII_CHAR(10)
    || '        end' || ASCII_CHAR(10)
    || '    Rec_Cnt = Rec_Cnt + 1;' || ASCII_CHAR(10)
    || '    select RecId from P_TMeltingPot where BHash = :BHash into :A_Rid;' || ASCII_CHAR(10)
    || '    if (A_Rid is null) then' || ASCII_CHAR(10)
    || '    begin' || ASCII_CHAR(10)

    || '      if (A_ChTmS = 1) then' || ASCII_CHAR(10)
    || '      begin' || ASCII_CHAR(10)
    || '        execute procedure P_IsSysSig(BHash,TmpSig,PeerKey) returning_values A_Test;' || ASCII_CHAR(10)
    || '        if (A_Test = 0) then' || ASCII_CHAR(10)
    || '        begin' || ASCII_CHAR(10)
    || '          A_Skip = 1;' || ASCII_CHAR(10)
    || '          execute procedure P_BadTmS(NodeRId,A_NdId,A_Tmp2);' || ASCII_CHAR(10)
    || '        end' || ASCII_CHAR(10)
    || '      end' || ASCII_CHAR(10)

    || '      if (A_Skip = 0) then' || ASCII_CHAR(10)
    || '      begin' || ASCII_CHAR(10)

    || '        if ((select Result from P_IsHash(:BHash)) = 0) then' || ASCII_CHAR(10)
    || '        begin' || ASCII_CHAR(10)
    || '          A_Skip = 1;' || ASCII_CHAR(10)
    || '          execute procedure P_BadHash(NodeRId,A_NdId,A_Tmp2);' || ASCII_CHAR(10)
    || '        end' || ASCII_CHAR(10)

    || '        if (A_Skip = 0 and A_ChHsh = 1) then' || ASCII_CHAR(10)
    || '        begin' || ASCII_CHAR(10)
    || '          A_Data = ' || FieldHash ||';' || ASCII_CHAR(10)
    || '          execute procedure P_CalcHash(A_Data) returning_values A_Hash;' || ASCII_CHAR(10)
    || '          if (A_Hash <> BHash) then' || ASCII_CHAR(10)
    || '          begin' || ASCII_CHAR(10)
    || '            A_Skip = 1;' || ASCII_CHAR(10)
    || '            execute procedure P_BadHash(NodeRId,A_NdId,A_Tmp2);' || ASCII_CHAR(10)
    || '          end' || ASCII_CHAR(10)
    || '        end' || ASCII_CHAR(10)

    || '        if (A_Skip = 0 and A_ChSig = 1) then' || ASCII_CHAR(10)
    || '        begin' || ASCII_CHAR(10)
    || '          execute procedure P_IsBlockSig(BHash,BSig,PubKey) returning_values A_Test;' || ASCII_CHAR(10)
    || '          if (A_Test = 0) then' || ASCII_CHAR(10)
    || '          begin' || ASCII_CHAR(10)
    || '            A_Skip = 1;' || ASCII_CHAR(10)
    || '            execute procedure P_BadSign(NodeRId,A_NdId,A_Tmp2);' || ASCII_CHAR(10)
    || '          end' || ASCII_CHAR(10)
    || '        end' || ASCII_CHAR(10)
    || '        if (A_Skip = 0) then' || ASCII_CHAR(10)
    || '        begin' || ASCII_CHAR(10)
    || '          insert into P_TMeltingPot(' || ASCII_CHAR(10) || FieldArgs || ')' || ASCII_CHAR(10)
    || '            values(' || ASCII_CHAR(10) || VarList1 || ')' || ASCII_CHAR(10)
    || '            returning RecId into :A_Rid;' || ASCII_CHAR(10)
    || '          when any do' || ASCII_CHAR(10)
    || '          begin' || ASCII_CHAR(10)
    || '            execute procedure P_LogErr(-181,sqlcode,gdscode,sqlstate,A_Tmp2,A_NdId,''P_TMeltingPot'',null);' || ASCII_CHAR(10)
    || '            if (not (sqlcode in (-803,-530))) then Leave;' || ASCII_CHAR(10)
    || '          end' || ASCII_CHAR(10)
    || '        end' || ASCII_CHAR(10)
    || '      end' || ASCII_CHAR(10)
    || '    end' || ASCII_CHAR(10)

    || '    if (A_Skip = 0 and A_Rid is not null) then' || ASCII_CHAR(10)
    || '    begin' || ASCII_CHAR(10)
    || '      if (not exists (select 1 from P_TMPVoter' || ASCII_CHAR(10)
    || '        where ParId = :A_Rid and NodeId = :A_NdId))' || ASCII_CHAR(10)
    || '      then' || ASCII_CHAR(10)
    || '        begin' || ASCII_CHAR(10)
    || '          insert into P_TMPVoter(ParId,BHash,NodeId) values(:A_Rid,:BHash,:A_NdId);' || ASCII_CHAR(10)
    || '          when any do' || ASCII_CHAR(10)
    || '          begin' || ASCII_CHAR(10)
    || '            execute procedure P_LogErr(-182,sqlcode,gdscode,sqlstate,A_Tmp2,A_NdId,''P_TMPVoter'',null);' || ASCII_CHAR(10)
    || '            if (not (sqlcode in (-803,-530))) then Leave;' || ASCII_CHAR(10)
    || '          end' || ASCII_CHAR(10)
    || '        end' || ASCII_CHAR(10)

    || '      if (A_TB = 1) then' || ASCII_CHAR(10)
    || '        for execute statement (stm2) (:BHash)' || ASCII_CHAR(10)
    || '          on external A_DB as user A_USR password A_PWD' || ASCII_CHAR(10)
    || '          into :A_PNId' || ASCII_CHAR(10)
    || '        do' || ASCII_CHAR(10)
    || '          if (not exists (select 1 from P_TMPVoter' || ASCII_CHAR(10)
    || '            where BHash = :BHash and NodeId = :A_PNId))' || ASCII_CHAR(10)
    || '          then' || ASCII_CHAR(10)
    || '            begin' || ASCII_CHAR(10)
    || '              insert into P_TMPVoter(ParId,BHash,NodeId) values(:A_Rid,:BHash,:A_PNId);' || ASCII_CHAR(10)
    || '              when any do' || ASCII_CHAR(10)
    || '              begin' || ASCII_CHAR(10)
    || '                execute procedure P_LogErr(-183,sqlcode,gdscode,sqlstate,A_Tmp2,A_NdId,''P_TMPVoter'',null);' || ASCII_CHAR(10)
    || '                if (not (sqlcode in (-803,-530))) then exit;' || ASCII_CHAR(10)
    || '              end' || ASCII_CHAR(10)
    || '            end' || ASCII_CHAR(10)
    || '    end' || ASCII_CHAR(10)
    || '    when any do' || ASCII_CHAR(10)
    || '    begin' || ASCII_CHAR(10)
    || '      execute procedure P_LogErr(-180,sqlcode,gdscode,sqlstate,A_Tmp2,null,null,null);' || ASCII_CHAR(10)
    || '      if (not (sqlcode in (-803,-530))) then Leave;' || ASCII_CHAR(10)
    || '    end' || ASCII_CHAR(10)
    || '  end' || ASCII_CHAR(10)
    || '  if (Sid > A_Tmp3) then execute procedure P_UpdMPId(NodeRId,Sid);' || ASCII_CHAR(10)
    || 'end';
  execute statement Script;
end^
/*-----------------------------------------------------------------------------------------------*/
create or alter procedure P_S$Commit(
  DeclVar TSysStr10k,
  VarList TSysStr10k,
  FieldArgs TSysStr10k,
  VarList1 TSysStr10k,
  FieldArgs1 TSysStr10k)
as
  declare Script TMemo;
begin
  VarList = Replace(VarList,'    ','        ');
  FieldArgs = Replace(FieldArgs,'    ','        ');
  Script ='create or alter view P_MPV as' || ASCII_CHAR(10)
  || 'select MP.*,(select count(*) from P_TMPVoter V where V.ParId = MP.RecId) as Voters' || ASCII_CHAR(10)
  || 'from P_TMeltingPot MP' || ASCII_CHAR(10);
  execute statement Script;
  Script ='create or alter procedure P_Commit' || ASCII_CHAR(10)
    || 'as' || ASCII_CHAR(10) || DeclVar || ASCII_CHAR(10)
    || '  declare A_Acc TBoolean;' || ASCII_CHAR(10)
    || '  declare A_Wait TBoolean;' || ASCII_CHAR(10)
    || '  declare Rec_Cnt TCount;' || ASCII_CHAR(10)
    || '  declare A_Test TCount;' || ASCII_CHAR(10)    
    || '  declare A_Tmp TCount;' || ASCII_CHAR(10)
    || '  declare A_Tmp2 TCount;' || ASCII_CHAR(10)
    || '  declare A_RT TCount;' || ASCII_CHAR(10)
    || '  declare A_QA TCount;' || ASCII_CHAR(10)
    || '  declare A_Rid TRef;' || ASCII_CHAR(10)
    || '  declare A_Sum TIntHash;' || ASCII_CHAR(10)
    || '  declare A_Hash TChHash;' || ASCII_CHAR(10)
    || 'begin' || ASCII_CHAR(10)
    || '  Rec_Cnt = 0;' || ASCII_CHAR(10)
    || '  select Acceptor,(Gen_Id(P_G$RTT,0) - MPQFactor),WaitBackLog,LacunaSpan from P_TParams into :A_Acc,A_RT,:A_Wait,:A_Tmp2;' || ASCII_CHAR(10)
    || '  if (A_Acc = 0) then exit;' || ASCII_CHAR(10)
    || '  if (A_Wait = 1 and exists (select 1 from P_TBackLog)) then' || ASCII_CHAR(10)
    || '  begin' || ASCII_CHAR(10)
    || '    execute procedure P_LogMsg(6,Rec_Cnt,0,null,''P_Commit'',null,''Back Log is not empty'',null);' || ASCII_CHAR(10)
    || '    exit;' || ASCII_CHAR(10)
    || '  end' || ASCII_CHAR(10)
    || '  if ((select Result from P_BegCommit) = 0) then exit;' || ASCII_CHAR(10)
    || '  execute procedure P_AssentAcc(2) returning_values A_QA;' || ASCII_CHAR(10)
    || '  execute procedure P_LogMsg(10,0,0,null,''P_Commit'',null,''Start'',null);' || ASCII_CHAR(10)
    || '  select first 1 BlockNo,Chsum,BHash from P_TChain order by BlockNo desc into :A_Rid,:A_Sum,:A_Hash;' || ASCII_CHAR(10)
    || '  for select' || ASCII_CHAR(10) || FieldArgs1 || ',' || ASCII_CHAR(10) || '    RT,Voters' || ASCII_CHAR(10)
    || '    from P_MPV' || ASCII_CHAR(10)
    || '    where State = 0' || ASCII_CHAR(10)
    || '    order by BTime,BHash' || ASCII_CHAR(10)
    || '    into' || ASCII_CHAR(10) || VarList1 || ',' || ASCII_CHAR(10) || '    :A_Tmp,:A_Test' || ASCII_CHAR(10)
    || '  do' || ASCII_CHAR(10)
    || '    if (A_Tmp >= A_RT)' || ASCII_CHAR(10) --RT lacuna
    || '    then' || ASCII_CHAR(10)
    || '      begin' || ASCII_CHAR(10)
    || '        execute procedure P_LogMsg(310,A_Tmp,A_RT,0,''P_Commit'',null,null,null);' || ASCII_CHAR(10)
    || '        Leave;' || ASCII_CHAR(10)
    || '      end' || ASCII_CHAR(10)
    || '    else' || ASCII_CHAR(10)
    || '      if (A_Test < A_QA)' || ASCII_CHAR(10) --Quorum lacuna
    || '      then' || ASCII_CHAR(10)
    || '        begin' || ASCII_CHAR(10)
    || '          if (A_Tmp > (A_RT - A_Tmp2))' || ASCII_CHAR(10) --Do not stumble on very old Quorum lacunas.
    || '          then' || ASCII_CHAR(10)
    || '            begin' || ASCII_CHAR(10)
    || '              execute procedure P_LogMsg(320,A_Tmp,A_RT,0,''P_Commit'',null,null,null);' || ASCII_CHAR(10)
    || '              Leave;' || ASCII_CHAR(10)
    || '            end' || ASCII_CHAR(10)
    || '          else' || ASCII_CHAR(10)
    || '            execute procedure P_LogMsg(330,A_Tmp,A_RT,0,''P_Commit'',null,null,null);'
    || '        end' || ASCII_CHAR(10)
    || '      else' || ASCII_CHAR(10)
    || '        if (not exists (select 1 from P_TChain' || ASCII_CHAR(10)
    || '          where BHash = :BHash))' || ASCII_CHAR(10)
    || '        then' || ASCII_CHAR(10)
    || '          begin' || ASCII_CHAR(10)
    || '            ParBlkNo = A_Rid;' || ASCII_CHAR(10)
    || '            ParChsum = A_Sum;' || ASCII_CHAR(10)
    || '            ParBHash = A_Hash;' || ASCII_CHAR(10)
    || '            insert into P_TChain(' || ASCII_CHAR(10) || FieldArgs || ')' || ASCII_CHAR(10)
    || '            values(' || ASCII_CHAR(10) || VarList || ')' || ASCII_CHAR(10)
    || '            returning BlockNo,Chsum,BHash into :A_Rid,:A_Sum,:A_Hash;' || ASCII_CHAR(10)
    || '            Rec_Cnt = Rec_Cnt + 1;' || ASCII_CHAR(10)
    || '            when any do' || ASCII_CHAR(10)
    || '            begin' || ASCII_CHAR(10)
    || '              execute procedure P_LogErr(-7,sqlcode,gdscode,sqlstate,''P_Commit'',SenderId,BlockId,null);' || ASCII_CHAR(10)
    || '              if (not (sqlcode in (-803,-530))) then Leave;' || ASCII_CHAR(10)
    || '            end' || ASCII_CHAR(10)
    || '          end' || ASCII_CHAR(10)
    || '  execute procedure P_EndCommit;' || ASCII_CHAR(10)
    || '  execute procedure P_LogMsg(11,Rec_Cnt,0,null,''P_Commit'',null,''Finish'',null);' || ASCII_CHAR(10)
    || 'end';
  execute statement Script;
end^
/*-----------------------------------------------------------------------------------------------*/
/* Returns block to Melting Pot on execute P_Dehorn proc */
create or alter procedure P_S$RevertBlock
as
  declare Script TMemo;
  declare FieldArgs TSysStr10k;
begin
  execute procedure P_MPArgFlt;
  execute procedure P_FieldArgs('P_TMeltingPot') returning_values FieldArgs;
  Script = 'create or alter procedure P_RevertBlock(BlockNo TRid,SndId TSenderId,BId TBlockId)' || ASCII_CHAR(10)
    || 'as' || ASCII_CHAR(10)
    || '  declare A_Test TBoolean;' || ASCII_CHAR(10)
    || 'begin' || ASCII_CHAR(10)
    || '  execute procedure P_BegAddB returning_values A_Test;' || ASCII_CHAR(10)
    || '  if (A_Test = 0) then exit;' || ASCII_CHAR(10)
    || '  if (exists(select 1 from P_TMeltingPot where SenderId = :SndId and BlockId = :BId))' || ASCII_CHAR(10)
    || '  then' || ASCII_CHAR(10)
    || '    update P_TMeltingPot set State = 0 where SenderId = :SndId and BlockId = :BId;' || ASCII_CHAR(10)
    || '  else' || ASCII_CHAR(10)
    || '    insert into P_TMeltingPot(' || ASCII_CHAR(10) || FieldArgs || ')' || ASCII_CHAR(10)
    || '      select' || ASCII_CHAR(10) || FieldArgs || ASCII_CHAR(10)
    || '      from P_TChain where BlockNo = :BlockNo;' || ASCII_CHAR(10)
    || '  execute procedure P_EndAddB;' || ASCII_CHAR(10)
    || '  when any do' || ASCII_CHAR(10)
    || '    if (sqlcode <> -803) then' || ASCII_CHAR(10)
    || '    begin' || ASCII_CHAR(10)
    || '      execute procedure P_EndAddB;' || ASCII_CHAR(10)
    || '      execute procedure P_LogErr(-70,sqlcode,gdscode,sqlstate,''P_RevertBlock'',SndId,BId,null);' || ASCII_CHAR(10)
    || '      exit;' || ASCII_CHAR(10)
    || '    end' || ASCII_CHAR(10)
    || 'end';
  execute statement Script;
end^
/*-----------------------------------------------------------------------------------------------*/
create or alter procedure P_S$GetHash
as
  declare Script TMemo;
  declare DeclVar TSysStr10k;
  declare VarList TSysStr10k;
  declare FieldArgs TSysStr10k;
  declare FieldHash TSysStr10k;
begin
  execute procedure P_FieldHash returning_values FieldHash;
  execute procedure P_FieldArgs('P_TChain') returning_values FieldArgs;
  execute procedure P_Decl('P_TChain') returning_values DeclVar;
  execute procedure P_Vars('P_TChain') returning_values VarList;  

  Script = 'create or alter procedure P_GetHash(BlockNo TRid)' || ASCII_CHAR(10)
    || 'returns (Result TChHash)' || ASCII_CHAR(10)
    || 'as' || ASCII_CHAR(10)
    || DeclVar || ASCII_CHAR(10)
    || '  declare A_Cast VarChar(1) = '''';' || ASCII_CHAR(10)    
    || '  declare A_Data TMemo;' || ASCII_CHAR(10)
    || 'begin' || ASCII_CHAR(10)
    || '  select ' || ASCII_CHAR(10) || FieldArgs || ASCII_CHAR(10)
    || '  from P_TChain where BlockNo = :BlockNo' || ASCII_CHAR(10)
    || '  into' || ASCII_CHAR(10) || VarList || ';' || ASCII_CHAR(10)
    || '  A_Data = ' || FieldHash ||';' || ASCII_CHAR(10)
    || '  execute procedure P_CalcHash(A_Data) returning_values Result;' || ASCII_CHAR(10)
    || 'end';
  execute statement Script;
end^
/*-----------------------------------------------------------------------------------------------*/
create or alter procedure P_S$NewBlock
as
  declare args TSysStr10k;
  declare VarList TSysStr10k;
  declare FieldEnc TSysStr10k;
  declare FieldUTF TSysStr10k;
  declare FieldHash TSysStr10k;
  declare Script TMemo;
begin
  execute procedure P_MPArgFlt;
  execute procedure P_Vars('P_TChain') returning_values VarList;
  insert into P$TFldFlt(Name) values('PubKey');
  insert into P$TFldFlt(Name) values('BlockId');
  insert into P$TFldFlt(Name) values('Address');
  insert into P$TFldFlt(Name) values('BSig');
  insert into P$TFldFlt(Name) values('BHash');
  insert into P$TFldFlt(Name) values('SenderId');
  execute procedure P_Args('P_TChain') returning_values args;
  if (args is null or args = '') then exit;
  execute procedure P_FieldHash returning_values FieldHash;
  execute procedure P$UTFStm returning_values FieldUTF;
  execute procedure P$EncStm('EncKey') returning_values FieldEnc;
  Script = ''
    || 'create or alter procedure P_NewBlock(' || ASCII_CHAR(10)
    || args || ')' || ASCII_CHAR(10)
    || 'returns (BlockId TBlockId)' || ASCII_CHAR(10)
    || 'as' || ASCII_CHAR(10)
    || '  declare A_Cast VarChar(1) = '''';' || ASCII_CHAR(10)    
    || '  declare Result SmallInt;' || ASCII_CHAR(10)
    || '  declare ErrState TErrState;' || ASCII_CHAR(10)
    || '  declare BHash TChHash;' || ASCII_CHAR(10)
    || '  declare BSig TSig;' || ASCII_CHAR(10)
    || '  declare Address TAddress;' || ASCII_CHAR(10)
    || '  declare SenderId TSenderId;' || ASCII_CHAR(10)
    || '  declare EncKey TKey;' || ASCII_CHAR(10)
    || '  declare PubKey TKey;' || ASCII_CHAR(10)
    || '  declare PvtKey TKey;' || ASCII_CHAR(10)
    || '  declare A_Data TMemo;' || ASCII_CHAR(10)
    || 'begin' || ASCII_CHAR(10)
    || '  Result = 0;' || ASCII_CHAR(10)
    || '  BlockId = uuid_to_Char(gen_uuid());' || ASCII_CHAR(10)
    || '  execute procedure P_DefAddr returning_values Address;' || ASCII_CHAR(10)
    || '  execute procedure P_DefSndId returning_values SenderId;' || ASCII_CHAR(10)
    || '  select PubKey,PvtKey from P_TParams into :PubKey,:PvtKey;' || ASCII_CHAR(10)
    || '  -- EG: select PubKey from P_TPeer where NodeId = :RecipientId into :EncKey;' || ASCII_CHAR(10)
    || FieldUTF
    || FieldEnc
    || '  A_Data = ' || FieldHash ||';' || ASCII_CHAR(10)
    || '  execute procedure P_CalcHash(A_Data) returning_values BHash;' || ASCII_CHAR(10)
    || '  execute procedure P_BlockSig(BHash,PvtKey) returning_values BSig;' || ASCII_CHAR(10)
    || '  execute procedure P_AddBlock(' || ASCII_CHAR(10)
    ||      VarList || ')' || ASCII_CHAR(10)
    || '    returning_values Result,ErrState;' || ASCII_CHAR(10)
    || '  if (Result < 0 or ErrState is not null) then exception P_E$NewBlock;' || ASCII_CHAR(10)
    || 'end^' || ASCII_CHAR(10)
    || '/*-------------------------------------------------------------------*/' || ASCII_CHAR(10)
    || 'grant select on P_TPeer to procedure P_NewBlock;'               || ASCII_CHAR(10)
    || 'grant select on P_TParams to procedure P_NewBlock;'             || ASCII_CHAR(10)
    || 'grant execute on procedure P_DefAddr to procedure P_NewBlock;'  || ASCII_CHAR(10)
    || 'grant execute on procedure P_BlockSig to procedure P_NewBlock;'  || ASCII_CHAR(10)
    || 'grant execute on procedure P_DefSndId to procedure P_NewBlock;' || ASCII_CHAR(10)
    || 'grant execute on procedure P_AddBlock to procedure P_NewBlock;' || ASCII_CHAR(10)
    || 'grant execute on procedure P_CalcHash to procedure P_NewBlock;' || ASCII_CHAR(10);

  insert into P_TSndSQl(SQL) values(:Script);
end^
/*-----------------------------------------------------------------------------------------------*/
create or alter procedure P_S$SenderSQL
as
  declare cnt TInt32;
  declare s TSysStr255;
  declare args TSysStr10k;
  declare VarList TSysStr10k;
  declare FieldHash TSysStr10k;
  declare Script TMemo;
begin
  execute procedure P_MPArgFlt;
  execute procedure P_Vars('P_TChain') returning_values VarList;

  execute procedure P_FieldCount('P_TChain') returning_values cnt;
  cnt = cnt * 2 -1;
  s = LPad ('', cnt, '?,');
  
  insert into P$TFldFlt(Name) values('BSig');
  insert into P$TFldFlt(Name) values('BHash');

  execute procedure P_Args_x('P_TChain') returning_values args;
  if (args is null or args = '') then exit;

  execute procedure P_FieldHash returning_values FieldHash;

  Script = ''
    || 'create domain TSig as BLOB SUB_TYPE TEXT SEGMENT SIZE 80;' || ASCII_CHAR(10)
    || 'create domain TKey as BLOB SUB_TYPE TEXT SEGMENT SIZE 80;' || ASCII_CHAR(10)
    || 'create domain TMemo as BLOB SUB_TYPE TEXT SEGMENT SIZE 80;' || ASCII_CHAR(10)
    || 'create domain TErrState as VarChar(16) CHARACTER SET WIN1252;' || ASCII_CHAR(10)
    || '/*-----------------------------------------------------------------------------------------------*/' || ASCII_CHAR(10)
    || 'set term ^ ;' || ASCII_CHAR(10)    
    || '/*-----------------------------------------------------------------------------------------------*/' || ASCII_CHAR(10)
    || 'create or alter procedure P_ChainBlock(A_DB VarChar(180),A_USR VarChar(31),A_PWD VarChar(32),' || ASCII_CHAR(10)
    || args || ',' || ASCII_CHAR(10)
    || '  PvtKey TKey)' || ASCII_CHAR(10)
    || 'returns(Result SmallInt,ErrState TErrState)' || ASCII_CHAR(10)
    || 'as' || ASCII_CHAR(10)
    || '  declare A_Cast VarChar(1) = '''';' || ASCII_CHAR(10)
    || '  declare Nonce TNonce;' || ASCII_CHAR(10)
    || '  declare BHash TChHash;' || ASCII_CHAR(10)
    || '  declare BSig TSig;' || ASCII_CHAR(10)
    || '  declare A_Data TMemo;' || ASCII_CHAR(10)
    || '  declare stm VarChar(2048);' || ASCII_CHAR(10)
    || 'begin' || ASCII_CHAR(10)
    || '  Result = 0;' || ASCII_CHAR(10)
    || '  A_Data = ' || FieldHash ||';' || ASCII_CHAR(10)
    || '  execute procedure P_FindHash(A_Data) returning_values Nonce,BHash;' || ASCII_CHAR(10)
    || '  execute procedure P_BlockSig(BHash,PvtKey) returning_values BSig;' || ASCII_CHAR(10)
    || '  stm =''execute procedure P_AddBlock(' || s || ')'';' || ASCII_CHAR(10)
    || '  execute statement' || ASCII_CHAR(10)
    || '    (stm) (' || ASCII_CHAR(10) || VarList || ')' || ASCII_CHAR(10)
    || '    on external A_DB as user A_USR password A_PWD' || ASCII_CHAR(10)
    || '    into :Result,:ErrState;' || ASCII_CHAR(10)
    || '  when any do' || ASCII_CHAR(10)
    || '  begin' || ASCII_CHAR(10)
    || '    Result = 0;' || ASCII_CHAR(10)
    || '    execute procedure P_LogErr(-2,sqlcode,gdscode,sqlstate,''P_ChainBlock'',BlockId,Substring(A_DB from 1 for 128),null);' || ASCII_CHAR(10)
    || '  end' || ASCII_CHAR(10)
    || 'end^' || ASCII_CHAR(10)
    || '/*-----------------------------------------------------------------------------------------------*/' || ASCII_CHAR(10)
    || 'set term ; ^' || ASCII_CHAR(10)
    || '/*-----------------------------------------------------------------------------------------------*/' || ASCII_CHAR(10)
    || 'grant execute on procedure P_LogErr to procedure P_ChainBlock;' || ASCII_CHAR(10)
    || 'grant execute on procedure P_BlockSig to procedure P_ChainBlock;' || ASCII_CHAR(10)
    || 'grant execute on procedure P_FindHash to procedure P_ChainBlock;' || ASCII_CHAR(10);
  insert into P_TSndSQl(SQL) values(:Script);
end^
/*-----------------------------------------------------------------------------------------------*/
create or alter procedure P_BuildRepl
as
  declare RelName TSysStr31;
  declare DeclVar TSysStr10k;
  declare VarList TSysStr10k;
  declare FieldList TSysStr10k;
  declare FieldArgs TSysStr10k;
  declare VarList1 TSysStr10k;
  declare FieldArgs1 TSysStr10k;
begin
  delete from P$TFldFlt;
  RelName = 'P_TCHAIN';
  insert into P$TFldFlt(Name) values('TmpSig');
  insert into P$TFldFlt(Name) values('RecTime');

  execute procedure P_FieldArgs(RelName) returning_values FieldArgs;
  execute procedure P_S$FixChain(FieldArgs);
  ---------------------------------------
  execute procedure P_Vars(RelName) returning_values VarList1;

  delete from P$TFldFlt where Name = 'TMPSIG';
  execute procedure P_StmFields(RelName) returning_values FieldList;
  execute procedure P_Decl(RelName) returning_values DeclVar;
  execute procedure P_Vars(RelName) returning_values VarList;

  execute procedure P_S$ReplChain(DeclVar,VarList,FieldList,VarList1,FieldArgs);
  ---------------------------------------
  delete from P$TFldFlt;
  insert into P$TFldFlt(Name) values('BlockNo');
  insert into P$TFldFlt(Name) values('Chsum');
  insert into P$TFldFlt(Name) values('RecTime');
  execute procedure P_Decl(RelName) returning_values DeclVar;
  execute procedure P_Vars(RelName) returning_values VarList;
  execute procedure P_FieldArgs(RelName) returning_values FieldArgs;

  RelName = 'P_TMeltingPot';
  delete from P$TFldFlt;
  insert into P$TFldFlt(Name) values('RT');
  insert into P$TFldFlt(Name) values('Own');
  insert into P$TFldFlt(Name) values('Sid');
  insert into P$TFldFlt(Name) values('RecId');
  insert into P$TFldFlt(Name) values('State');
  insert into P$TFldFlt(Name) values('TmpSig');
  execute procedure P_Vars(RelName) returning_values VarList1;
  execute procedure P_FieldArgs(RelName) returning_values FieldArgs1;
  execute procedure P_S$Commit(DeclVar,VarList,FieldArgs,VarList1,FieldArgs1);
  ---------------------------------------
  delete from P$TFldFlt where Name = 'RT';
  delete from P$TFldFlt where Name = 'SID';
  delete from P$TFldFlt where Name = 'TMPSIG';
  execute procedure P_StmFields(RelName) returning_values FieldList;
  execute procedure P_Decl(RelName) returning_values DeclVar;
  execute procedure P_Vars(RelName) returning_values VarList;

  insert into P$TFldFlt(Name) values('RT');
  insert into P$TFldFlt(Name) values('Sid');
  insert into P$TFldFlt(Name) values('TmpSig');
  execute procedure P_Vars(RelName) returning_values VarList1;
  execute procedure P_FieldArgs(RelName) returning_values FieldArgs;
  execute procedure P_S$MPRep(DeclVar,VarList,FieldList,VarList1,FieldArgs);

end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_BeginBuild
as
  declare TableName TSysStr31;
  declare TableBuf1 TSysStr31;
  declare TableBuf2 TSysStr31;
begin
  for select
      distinct(TableName),
      TableBuf1,
      TableBuf2
    from
      P_TFields
    into
      :TableName,
      :TableBuf1,
      :TableBuf2
  do
    execute procedure P_DropFields(TableName);
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_DoGrants
as
begin
  execute statement 'grant select on P_TChain to procedure P_AddBlock';
  execute statement 'grant select on P_TParams to procedure P_AddBlock';
  execute statement 'grant all on P_TMeltingPot to procedure P_AddBlock';
  execute statement 'grant execute on procedure P_IsHash to procedure P_AddBlock';
  execute statement 'grant execute on procedure P_BegAddB to procedure P_AddBlock';
  execute statement 'grant execute on procedure P_EndAddB to procedure P_AddBlock';
  execute statement 'grant execute on procedure P_HasBlock to procedure P_AddBlock';
  execute statement 'grant execute on procedure P_IsSender to procedure P_AddBlock';
  execute statement 'grant execute on procedure P_CalcHash to procedure P_AddBlock';
  execute statement 'grant execute on procedure P_LogSndMsg to procedure P_AddBlock';
  execute statement 'grant execute on procedure P_LogSndErr to procedure P_AddBlock';
  execute statement 'grant execute on procedure P_IsBlockSig to procedure P_AddBlock';
  execute statement 'grant execute on procedure P_OnGetBlock to procedure P_AddBlock';

  execute statement 'grant select on P_BLV to procedure P_FixChain';
  execute statement 'grant select on P_MPV to procedure P_Commit';

end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_FinishBuild
as
  declare RelName TSysStr31;
  declare ProcName TSysStr64;
begin
  execute statement 'alter view P_Chain as select * from P_TChain where (select Online from P_TParams) > 0';
  execute statement 'alter view P_MeltingPot as select * from P_TMeltingPot where (select Online from P_TParams) > 0';
  execute statement
    'alter view P_AddrBook(Address) as select distinct(Address) from P_TChain where Address <> ''ROOT''';
  execute statement
    'alter view P_SndBook(SenderId) as select distinct(SenderId) from P_TChain where SenderId <> ''ROOT''';
  execute statement
    'alter view P_MyChain as select C.* from P_TChain C ' ||
    'inner join P_MyScope S on C.Address = S.Address and C.SenderId = S.SenderId';

  execute statement
    'alter view P_ChainInf(BlockNo,Chsum) as select first 1 BlockNo,Chsum from P_TChain order by BlockNo desc';

  execute procedure P_DoGrants;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_Build
as
  declare flag TBoolean;
  declare TableName TSysStr31;
  declare FieldName TSysStr31;
  declare TableBuf1 TSysStr31;
  declare TableBuf2 TSysStr31;
  declare DataType TSysStr64;
  declare DefVal TString63;
  declare Constr TSysStr255;
  declare CharSet TString63;
begin
  if ((select count(*) from P_TChain) > 1) then exception P_E$TableHasData;
  execute procedure P_Creating returning_values flag;
  if (flag = 0) then exception P_E$Recursion;
  delete from P_TSndSQl;

  in autonomous transaction do execute procedure P_BeginBuild;
  in autonomous transaction do
    for select
        TableName,
        FieldName,
        TableBuf1,
        TableBuf2,
        DataType,
        DefVal,
        Constr,
        CharSet
      from
        P_TFields
      into
        :TableName,
        :FieldName,
        :TableBuf1,
        :TableBuf2,
        :DataType,
        :DefVal,
        :Constr,
        :CharSet
    do
      begin
        execute procedure P_CreateField(TableName,FieldName,DataType,DefVal,Constr,CharSet);
        if (TableBuf1 <> '') then
          execute procedure P_CreateField(TableBuf1,FieldName,DataType,DefVal,Constr,CharSet);
        if (TableBuf2 <> '') then
          execute procedure P_CreateField(TableBuf2,FieldName,DataType,DefVal,Constr,CharSet);
      end

  in autonomous transaction do execute procedure P_S$AddBlock;
  in autonomous transaction do execute procedure P_S$RevertBlock;

  in autonomous transaction do execute procedure P_S$GetHash;
  in autonomous transaction do execute procedure P_BuildRepl;

  in autonomous transaction do execute procedure P_FinishBuild;
  in autonomous transaction do execute procedure P_S$NewBlock;
  in autonomous transaction do execute procedure P_S$SenderSQL;
end^
/*-----------------------------------------------------------------------------------------------*/
set term ; ^
/*-----------------------------------------------------------------------------------------------*/
create view P_Fields as select * from P_TFields;
/*-----------------------------------------------------------------------------------------------*/
insert into P$TKeyWords(Name) select distinct(Name) from P$TSysNames;
insert into P$TKeyWords(Name) values('REC_CNT');
insert into P$TKeyWords(Name) values('RESULT');
insert into P$TKeyWords(Name) values('ERRSTATE');
insert into P$TKeyWords(Name) values('A_DB');
insert into P$TKeyWords(Name) values('A_USR');
insert into P$TKeyWords(Name) values('A_PWD');
insert into P$TKeyWords(Name) values('A_LINE');
insert into P$TKeyWords(Name) values('A_TEST');
insert into P$TKeyWords(Name) values('A_HASH');
insert into P$TKeyWords(Name) values('A_DATA');
insert into P$TKeyWords(Name) values('A_CAST');
insert into P$TKeyWords(Name) values('A_CHHSH');
insert into P$TKeyWords(Name) values('A_CHTMS');
insert into P$TKeyWords(Name) values('A_CHSIG');
insert into P$TKeyWords(Name) values('A_ACC');
insert into P$TKeyWords(Name) values('A_NDID');
insert into P$TKeyWords(Name) values('A_PNID');
insert into P$TKeyWords(Name) values('A_SKIP');
insert into P$TKeyWords(Name) values('A_RID');
insert into P$TKeyWords(Name) values('A_QA');
insert into P$TKeyWords(Name) values('A_QT');
insert into P$TKeyWords(Name) values('A_TB');
insert into P$TKeyWords(Name) values('A_MPID');
insert into P$TKeyWords(Name) values('A_SUM');
insert into P$TKeyWords(Name) values('STM');
insert into P$TKeyWords(Name) values('STM2');
insert into P$TKeyWords(Name) values('A_RT');
insert into P$TKeyWords(Name) values('A_WAIT');
insert into P$TKeyWords(Name) values('A_TMP');
insert into P$TKeyWords(Name) values('A_TMP2');
insert into P$TKeyWords(Name) values('A_TMP3');
insert into P$TKeyWords(Name) values('PEERKEY');

commit work;
/*-----------------------------------------------------------------------------------------------*/
grant select on P_TChain to procedure P_GetHash;
grant execute on procedure P_CalcHash to procedure P_GetHash;
grant execute on procedure P_EnumFields to procedure P_FieldCount;

grant execute on procedure P_IsQuoted to procedure P_CreateField;

grant all on P$TFldFlt to procedure P_S$AddBlock;
grant execute on procedure P_Vars to procedure P_S$AddBlock;
grant execute on procedure P_Args to procedure P_S$AddBlock;
grant execute on procedure P_MPArgFlt to procedure P_S$AddBlock;
grant execute on procedure P_FieldArgs to procedure P_S$AddBlock;
grant execute on procedure P_FieldHash to procedure P_S$AddBlock;

grant all on P$TFldFlt to procedure P_FieldHash;

grant execute on procedure P_FieldHash to procedure P_S$MPRep;

grant all on P$TFldFlt to procedure P_S$GetHash;
grant execute on procedure P_Vars to procedure P_S$GetHash;
grant execute on procedure P_Args to procedure P_S$GetHash;
grant execute on procedure P_FieldArgs to procedure P_S$GetHash;
grant execute on procedure P_FieldHash to procedure P_S$GetHash;

grant select on P_TFields to procedure P_BeginBuild;
grant execute on procedure P_DropFields to procedure P_BeginBuild;

grant execute on procedure P_DoGrants to procedure P_FinishBuild;

grant all on P_TSndSQl to procedure P_Build;
grant all on P_TParams to procedure P_Build;
grant select on P_TChain to procedure P_Build;
grant select on P_TFields to procedure P_Build;
grant execute on procedure P_Creating to procedure P_Build;
grant execute on procedure P_S$GetHash to procedure P_Build;
grant execute on procedure P_BuildRepl to procedure P_Build;
grant execute on procedure P_S$NewBlock to procedure P_Build;
grant execute on procedure P_S$AddBlock to procedure P_Build;
grant execute on procedure P_BeginBuild to procedure P_Build;
grant execute on procedure P_CreateField to procedure P_Build;
grant execute on procedure P_FinishBuild to procedure P_Build;
grant execute on procedure P_S$SenderSQL to procedure P_Build;

grant select on P$TFldFlt to procedure P_EnumFields;

grant execute on procedure P_EnumFields to procedure P_Args_x;
grant execute on procedure SYS_FieldType to procedure P_Args_x;

grant execute on procedure P_EnumFields to procedure P_Vars;
grant execute on procedure P_EnumFields to procedure P_Args;
grant execute on procedure P_EnumFields to procedure P_Decl;
grant execute on procedure P_EnumFields to procedure P_FieldArgs;
grant execute on procedure P_EnumFields to procedure P_FieldArgs;
grant execute on procedure P_EnumFields to procedure P_StmFields;

grant execute on procedure P_DropField to procedure P_DropFields;
grant execute on procedure P_EnumFields to procedure P_DropFields;

grant all on P$TFldFlt to procedure P_BuildRepl;
grant execute on procedure P_Decl to procedure P_BuildRepl;
grant execute on procedure P_Vars to procedure P_BuildRepl;
grant execute on procedure P_S$Commit to procedure P_BuildRepl;
grant execute on procedure P_StmFields to procedure P_BuildRepl;
grant execute on procedure P_FieldArgs to procedure P_BuildRepl;
grant execute on procedure P_S$FixChain to procedure P_BuildRepl;
grant execute on procedure P_S$ReplChain to procedure P_BuildRepl;

grant select on P_TFields to procedure P$EncStm;
grant execute on procedure P$EncType to procedure P$EncStm;
grant select on P_TFields to procedure P$UTFStm;
grant execute on procedure P$EncType to procedure P$UTFStm;

grant execute on procedure P_MPArgFlt to procedure P_S$RevertBlock;
grant execute on procedure P_FieldArgs to procedure P_S$RevertBlock;

grant all on P$TFldFlt to procedure P_S$NewBlock;
grant execute on procedure P_Vars to procedure P_S$NewBlock;
grant execute on procedure P_Args to procedure P_S$NewBlock;
grant execute on procedure P$UTFStm to procedure P_S$NewBlock;
grant execute on procedure P$EncStm to procedure P_S$NewBlock;
grant execute on procedure P_MPArgFlt to procedure P_S$NewBlock;
grant execute on procedure P_FieldHash to procedure P_S$NewBlock;

grant all on P$TFldFlt to procedure P_S$SenderSQL;
grant all on P_TSndSQl to procedure P_S$SenderSQL;
grant execute on procedure P_Vars to procedure P_S$SenderSQL;
grant execute on procedure P_Args_x to procedure P_S$SenderSQL;
grant execute on procedure P_MPArgFlt to procedure P_S$SenderSQL;
grant execute on procedure P_FieldCount to procedure P_S$SenderSQL;

grant select on P$TKeyWords to trigger P_TBI$TFields;
grant select on P$TKeyWords to trigger P_TBU$TFields;
/*-----------------------------------------------------------------------------------------------*/

