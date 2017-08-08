/* ************************************************************************ */
/* PeopleRelay: str_util.sql Version: see version.sql                       */
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
set term ^ ;
/*-----------------------------------------------------------------------------------------------*/
create procedure P_GenPwd(Len Integer)
returns
  (Result TRndPwd)
as
  declare i Integer;
  declare n Integer;
  declare s VarChar(512) character set OCTETS;
begin
  i = 0;
  s = '';
  if (Len <= 0) then Len = 8;
  n = Len / 16;
  while (i <= n) do
  begin
    s = s || gen_uuid();
    i = i + 1;
  end
  Result = Substring(s from 1 for Len);
  suspend;
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
create procedure P_ExpandIPv6(IP TSysStr255)
returns
 (Result TSysStr255)
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
set term ; ^
/*-----------------------------------------------------------------------------------------------*/
grant execute on procedure SymbList to procedure P_SymbCount;
grant execute on procedure P_SymbCount to procedure P_ExpandIPv6;
/*-----------------------------------------------------------------------------------------------*/
