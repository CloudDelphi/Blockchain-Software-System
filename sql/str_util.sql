/* ======================================================================== */
/* PeopleRelay: str_util.sql Version: 0.4.3.6                               */
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
create procedure P_GenPwd
returns
  (Result TRndPwd)
as
  declare i Integer;
  declare p Integer;
  declare Len Integer;
begin
  i = 1;
  Result = '';
  Len = rand() * 32 + 32; /* max = 64 */
  while (i <= Len) do
  begin
    p = rand() * 223 + 32;
    Result = Result || ASCII_CHAR(p);
    i = i + 1;
  end
  suspend;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure StdStr(AText TString4K)
returns
  (Result TString4K)
as
begin
  AText = Trim(AText);
  if (AText is not null and AText <> '') then
  begin
    Result = Replace(AText,'"','');
    Result = Replace(Result,' ','');
    Result = Replace(Result,'.','');
    Result = Replace(Result,',','');
    Result = Replace(Result,';','');
    Result = Replace(Result,'''','');
    if (Result <> '') then Result = Upper(Result);
  end
end^
/*-----------------------------------------------------------------------------------------------*/
/*
select Result from TryStrToInt('123', -1)
*/
create procedure TryStrToInt(s TSysStr32, DefVal Integer)
returns
  (Result Integer)
as
begin
  begin
    Result = cast(s as Integer);
    when any do Result = DefVal;
  end
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure SymbList(Delim TSysStr1,AText TSysStr512)
returns
  (Result TSysStr512)
as
  declare variable i Integer;
  declare variable L Integer;
  declare variable c TSysStr1;
begin
  i = 0;
  Result = '';
  L = Char_length(AText);
  while (i < L) do
  begin
    i = i + 1;
    c = Substring(AText from i for 1);
    if (c = Delim)
    then
      begin
        if (Result <> '') then
        begin
          suspend;
          Result = '';
        end
      end
    else
      Result = Result || c;
  end
  if (Result <> '') then suspend;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_SymbCount(Delim TSysStr1,AText TSysStr512)
returns
  (Result Integer)
as
  declare s TSysStr512;
begin
  Result = 0;
  for select Result from SymbList(:Delim,:AText) into :s do Result = Result + 1;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_ExtractIPv4(s TSysStr255)
returns
 (Result TSysStr255)
as
  declare p4 Integer;
  declare p6 Integer;
begin
  p4 = Position('.',s);
  p6 = Position(':',s);
  if (p4 > 0 and p6 > 0)
  then
    begin
      s = Reverse(s);
      p6 = Position(':',s);
      s = Substring(s from 1 for p6 - 1);
      Result = Reverse(s);
    end
  else
    Result = s;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_ExpandIPv6(IP TIPV6str)
returns
 (Result TIPV6str)
as
  declare L Integer;
  declare sc Integer;
  declare p6 Integer;
  declare s TSysStr64;
begin
  p6 = Position('::',IP);
  if (p6 = 0)
  then
    Result = IP;
  else
    begin
      execute procedure P_SymbCount(':',IP) returning_values sc;
      s = ':' || LPad('',(8 - sc) * 5,'0000:');
      Result = Replace(IP,'::',s);
      L = char_Length(Result);
      if (Substring(Result from L for 1) = ':') then Result = Substring(Result from 1 for L - 1);
      if (Position(':',Result) = 1) then Result = Substring(Result from 2 for 64);
    end
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure WrapText(M Integer,AText TMemo)
returns
  (Result TMemo)
as
  declare i Integer;
  declare k Integer;  
  declare ALen Integer;
begin
  if (AText is not null) then
  begin
    i = 0;
    k = 0;
    Result = '';
    ALen = char_length(AText);
    while (i < ALen) do
    begin
      k = k + 1;
      i = i + 1;
      Result = Result || Substring(AText from i for 1);
      if (k >= M) then
      begin
        Result = Result || ASCII_CHAR(13) || ASCII_CHAR(10);
        k = 0;
      end
    end
  end
  suspend;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure ForEachStr(AText TMemo)
returns
  (Result VarChar(255))
as
  declare p Integer;
  declare n Integer;
begin
  AText = Replace(Trim(AText),ASCII_CHAR(13),ASCII_CHAR(10));
  AText = Replace(Trim(AText),ASCII_CHAR(10) || ASCII_CHAR(10),ASCII_CHAR(10)) || ASCII_CHAR(10);
  p = 1;
  n = position(ASCII_CHAR(10),AText,p);
  while (n > 0) do
  begin
    Result = Trim(Substring(AText from p for n - p));
    if (Result is not null and Result <> '') then suspend;
    p = n + 1;
    n = position(ASCII_CHAR(10),AText,p);
  end
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure SectionBody(Sect VarChar(32),AText TMemo)
returns
  (Result TMemo)
as
  declare L Integer;
  declare p Integer;
  declare flag Integer;
  declare s VarChar(255);
begin
  flag = 0;
  Sect = '[' || Upper(Sect) || ']';
  for
    select
      Result
    from
      ForEachStr(:AText)
    into
      :s
  do
    begin
      if (Sect = Upper(s))
      then
        flag = 1;
      else
        if (flag = 1) then
          if (s Like '[_%]')
          then
            Break;
          else
            if (Result is null)
            then
              Result = s || ASCII_CHAR(10);
            else
              Result = Result || s || ASCII_CHAR(10); /* is needed for the last string */
    end

  if (Result = '') then Result = null;
  suspend;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure ParamValue(Sect VarChar(32),Param VarChar(32),AText TMemo)
returns
  (Result VarChar(255))
as
  declare s VarChar(255);
  declare tmp TMemo;
begin
  execute procedure SectionBody(Sect,AText) returning_values tmp;
  if (tmp is not null) then
  begin
    Param = Upper(Param) || '=';
    for
      select
        Result
      from
        ForEachStr(:tmp)
      into
        :s
    do
      if (position(Param,Upper(s)) = 1) then
      begin
        Result = Trim(Substring(s from Char_Length(Param) + 1));
        Break;
      end
  end
  suspend;
end^
/*-----------------------------------------------------------------------------------------------*/
set term ; ^
/*-----------------------------------------------------------------------------------------------*/
grant execute on procedure SymbList to procedure P_SymbCount;
grant execute on procedure P_SymbCount to procedure P_ExpandIPv6;
/*-----------------------------------------------------------------------------------------------*/
