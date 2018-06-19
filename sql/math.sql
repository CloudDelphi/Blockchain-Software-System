/* ======================================================================== */
/* PeopleRelay: math.sql Version: 0.4.1.8                                   */
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
create procedure Rand32(AMax TInt32)
returns
  (Result TInt32)
as
begin
  Result = cast((rand() * AMax) as TInt32);
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure Random(AMin TInt32,AMax TInt32)
returns
  (Result TInt32)
as
begin
  Result = rand() * (AMax - AMin) + AMin;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure Math_IntToBin(I BigInt)
returns
  (Result TSysStr255)
as
begin
  Result = '';
  while (I > 0) do
  begin
    Result = Mod(I,2) || Result;
    I = I / 2;
  end
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure Math_BinToInt(s TSysStr255)
returns
  (Result BigInt)
as
  declare Cnt Integer;
  declare Len Integer;
begin
  Cnt = 1;
  Len = char_Length(s);
  Result = cast(Substring(s from Len for 1) as bigint);
  while(Cnt < Len) do
  begin
    Result = Result + Power(cast(Substring(s from Len - Cnt for 1) as BigInt) * 2,Cnt);
    Cnt = Cnt + 1;
  end
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure Math_Interpret(f TExpression)
returns
  (Result BigInt)
as
begin
  execute statement 'select ' || f || ' from rdb$database' into :Result;
end^
/*-----------------------------------------------------------------------------------------------*/
set term ; ^
/*-----------------------------------------------------------------------------------------------*/


