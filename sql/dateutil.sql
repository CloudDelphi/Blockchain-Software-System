/* ======================================================================== */
/* PeopleRelay: dateutil.sql Version: 0.4.1.8                               */
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
--cast(extract(MONTH from CURRENT_TIMESTAMP)/3 + 0.3 as Integer)
create procedure YearQuarter(ADate TimeStamp)
returns
  (Result Integer)
as
begin
  if (ADate is null) then ADate = CURRENT_TIMESTAMP;
  Result = (extract(MONTH from ADate) - 1) / 3 + 1;
  suspend;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure DayOfWeek(D DATE)
  returns (Result INTEGER)
as
begin
  Result = extract(WEEKDAY from D);
  if (Result=0) then Result = 7;
/*  suspend; */
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure DateInRange(ADate TimeStamp,EffDate TimeStamp,ExpDate TimeStamp)
returns
  (Result SmallInt)
as
begin
  if ((EffDate is null and ExpDate is null)
    or (EffDate is null and ExpDate >= ADate)
    or (EffDate <= ADate and ExpDate is null)
    or (EffDate <= ADate and ExpDate >= ADate))
  then
    Result = 1;
  else
    Result = 0;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure MinDate(Date1 TimeStamp, Date2 TimeStamp)
returns
  (Result TimeStamp)
as
begin
  if (Date1 is null)
  then
    Result = Date2;
  else
    if (Date2 is null)
    then
      Result = Date1;
    else
      if (Date1 < Date2)
      then
        Result = Date1;
      else
        Result = Date2;
end^

/*
create procedure MinDate(Date1 TimeStamp, Date2 TimeStamp)
returns
  (Result TimeStamp)
as
begin
  if (Date1 is null or Date2 is null)
  then
    Result = null;
  else
    if (Date1 < Date2)
    then
      Result = Date1;
    else
      Result = Date2;
end^
*/
/*-----------------------------------------------------------------------------------------------*/
create procedure MaxDate(Date1 TimeStamp, Date2 TimeStamp)
returns
  (Result TimeStamp)
as
begin
  if (Date1 is null)
  then
    Result = Date2;
  else
    if (Date2 is null)
    then
      Result = Date1;
    else
      if (Date1 > Date2)
      then
        Result = Date1;
      else
        Result = Date2;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure DateIntersect(
  FromDate1 TimeStamp,
  ToDate1 TimeStamp,
  FromDate2 TimeStamp,
  ToDate2 TimeStamp)
returns
  (FromDate TimeStamp,
   ToDate TimeStamp)
as
begin
  execute procedure MinDate(ToDate1,ToDate2) returning_values ToDate;
  execute procedure MaxDate(FromDate1,FromDate2) returning_values FromDate;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure GetDayNumberStr(ADate Date)
returns
  (Result VarChar(2))
as
  declare variable ANumber Integer;
begin
  ANumber = extract(DAY from ADate);
  if (ANumber < 10)
  then
    Result = '0' || cast(ANumber as VarChar(1));
  else
    Result = cast(ANumber as VarChar(2));
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure WeekNo(D TimeStamp)
returns
  (Y TYear,
   W TWeekNo)
as
  declare tD TimeStamp;
begin
  tD = D + 7;
  W = extract(WEEK from D);
  Y = extract(YEAR from D);
  if (extract(WEEK from tD) < W and extract(YEAR from tD) = Y) then Y = Y - 1;
  suspend;
end^
/*-----------------------------------------------------------------------------------------------*/
/*
create procedure GetWeekName(ADate Date)
returns
  (Result VarChar(12))
as
  declare variable ANumber Integer;
begin
  ANumber = extract(WEEKDAY from ADate);
  if (ANumber = 0) then ANumber = 7;
  ANumber = ANumber + 12;
  execute procedure NM_Lex(null,7,ANumber) returning_values Result;
end^
*/
/*-----------------------------------------------------------------------------------------------*/
/*
create procedure GetMonthName(ADate TimeStamp)
returns
  (Result VarChar(12))
as
  declare variable ANumber Integer;
begin
  ANumber = extract(MONTH from ADate);
  execute procedure NM_Lex(null,7,ANumber) returning_values Result;
end^
*/
/*-----------------------------------------------------------------------------------------------*/
/*
create procedure GetDayMonthStr(ADate TimeStamp)
returns
  (Result VarChar(16))
as
  declare variable ADay VarChar(2);
  declare variable AMonth VarChar(12);
begin
  if (ADate is null)
  then
    Result = '';
  else
    begin
      execute procedure GetDayNumberStr(ADate) returning_values ADay;
      execute procedure GetMonthName(ADate) returning_values AMonth;
      Result = ADay || ' ' || AMonth;
    end
end^
*/
/*-----------------------------------------------------------------------------------------------*/
/*
create procedure DMShortStr(ADate TimeStamp)
returns
  (Result VarChar(16))
as
  declare variable ADay VarChar(2);
  declare variable AMonth VarChar(12);
begin
  if (ADate is null)
  then
    Result = '';
  else
    begin
      execute procedure GetDayNumberStr(ADate) returning_values ADay;
      execute procedure GetMonthName(ADate) returning_values AMonth;
      Result = ADay || ' ' || Substring(AMonth from 1 for 3);
    end
end^
*/
/*-----------------------------------------------------------------------------------------------*/
/*
create procedure GetDMYStr(ADate TimeStamp)
returns
  (Result VarChar(16))
as
  declare variable ADay VarChar(2);
  declare variable AMonth VarChar(12);
begin
  if (ADate is null)
  then
    Result = '';
  else
    begin
      execute procedure GetDayNumberStr(ADate) returning_values ADay;
      execute procedure GetMonthName(ADate) returning_values AMonth;
      Result = ADay || ' ' || AMonth || ' ' || extract(YEAR from ADate);
    end
end^
*/
/*-----------------------------------------------------------------------------------------------*/
create procedure FormatTime(AHour SmallInt,AMin SmallInt)
returns
  (Result VarChar(5))
as
  declare variable AMinStr Char(2);
  declare variable AHourStr Char(2);
begin
  AHourStr = cast(AHour as VarChar(2));
  AMinStr = cast(AMin as VarChar(2));
  if (AHour < 10) then AHourStr = '0' || AHourStr;
  if (AMin < 10) then AMinStr = '0' || AMinStr;
  Result = AHourStr || ':' || AMinStr;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure FormatTimeMin(ATime Integer)
returns
  (Result VarChar(5))
as
  declare variable AHour SmallInt;
  declare variable AMin SmallInt;
begin
  AHour = ATime / 60;
  AMin = ATime - AHour * 60;
  execute procedure FormatTime(AHour,AMin) returning_values Result;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure HourMinStr(ADateTime TimeStamp)
returns
  (Result VarChar(5))
as
  declare variable AHour SmallInt;
  declare variable AMin SmallInt;
begin
  AHour = extract(HOUR from ADateTime);
  AMin = extract(MINUTE from ADateTime);
  execute procedure FormatTime(AHour,AMin) returning_values Result;
end^
/*-----------------------------------------------------------------------------------------------*/
/*
create procedure DayMonthHourMinStr(ADateTime TimeStamp)
returns
  (Result VarChar(32))
as
  declare variable ATemp Char(5);
begin
  execute procedure HourMinStr(ADateTime) returning_values ATemp;
  execute procedure GetDayMonthStr(ADateTime) returning_values Result;
  Result = Result || ' ' || ATemp;
end^
*/
/*-----------------------------------------------------------------------------------------------*/
/*
create procedure DMHMShortStr(ADateTime TimeStamp)
returns
  (Result VarChar(32))
as
  declare variable ATemp Char(5);
begin
  execute procedure HourMinStr(ADateTime) returning_values ATemp;
  execute procedure DMShortStr(ADateTime) returning_values Result;
  Result = Result || ' ' || ATemp;
end^
*/
/*-----------------------------------------------------------------------------------------------*/
/*
create procedure DMYHMStr(ADateTime TimeStamp)
returns
  (Result TDMYHMStr)
as
  declare variable ATemp Char(5);
begin
  execute procedure GetDMYStr(ADateTime) returning_values Result;
  execute procedure HourMinStr(ADateTime) returning_values ATemp;
  Result = Result || ' ' || ATemp;
end^
*/
/*-----------------------------------------------------------------------------------------------*/
/*
create procedure DMYWStr(ADate Date)
returns
  (Result TDMYWStr)
as
  declare variable AWeekDay TString23;
begin
  if (ADate is null)
  then
    Result = '';
  else
    begin
      execute procedure GetDMYStr(ADate) returning_values Result;
      execute procedure GetWeekName(ADate) returning_values AWeekDay;
      Result = Result || ' - ' || AWeekDay;
    end
  suspend;
end^
*/
/*-----------------------------------------------------------------------------------------------*/
/*
select Result from FormatMinRange(480,990);
*/
create procedure FormatMinRange(ATime1 Integer, ATime2 Integer)
returns
  (Result VarChar(16))
as
  declare variable AStr VarChar(5);
begin
  execute procedure FormatTimeMin(ATime1) returning_values Result;
  if (ATime1 <> ATime2) then
  begin
    execute procedure FormatTimeMin(ATime2) returning_values AStr;
    Result = Result || ' - ' || AStr;
  end
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure ShortYear(D TimeStamp)
returns
  (Result SmallInt)
as
begin
  if (D is null) then D = CURRENT_DATE;
  Result = cast(Substring(cast(extract(YEAR from D) as VarChar(5)) from 3 for 2) as SmallInt);
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure ShortYearStr(D TimeStamp)
returns
  (Result VarChar(3))
as
begin
  if (D is null) then D = CURRENT_DATE;
  Result = Substring(cast(extract(YEAR from D) as VarChar(5)) from 3 for 2);
end^
/*-----------------------------------------------------------------------------------------------*/
/*
create procedure MonthLastDay(ADate TimeStamp)
  returns (Result TimeStamp)
as
  declare variable tmp TimeStamp;
begin
  tmp = ADate - extract(DAY from ADate);
  Result = tmp - extract(DAY from tmp + 32) + 32;
  suspend;
end^
*/
/*-----------------------------------------------------------------------------------------------*/
set term ; ^
/*-----------------------------------------------------------------------------------------------*/
grant execute on procedure YearQuarter to PUBLIC;
grant execute on procedure MinDate to PUBLIC;
grant execute on procedure MaxDate to PUBLIC;
--grant execute on procedure DMYWStr to PUBLIC;
--grant execute on procedure DMYHMStr to PUBLIC;
grant execute on procedure ShortYear to PUBLIC;
grant execute on procedure DayOfWeek to PUBLIC;
--grant execute on procedure GetDMYStr to PUBLIC;
grant execute on procedure FormatTime to PUBLIC;
grant execute on procedure HourMinStr to PUBLIC;

grant execute on procedure DateInRange to PUBLIC;
--grant execute on procedure GetWeekName to PUBLIC;
--grant execute on procedure GetMonthName to PUBLIC;
grant execute on procedure ShortYearStr to PUBLIC;
grant execute on procedure FormatTimeMin to PUBLIC;
grant execute on procedure DateIntersect to PUBLIC;
grant execute on procedure FormatMinRange to PUBLIC;

grant execute on procedure WeekNo to PUBLIC;

--grant execute on procedure GetDayMonthStr to PUBLIC;
grant execute on procedure GetDayNumberStr to PUBLIC;
--grant execute on procedure DayMonthHourMinStr to PUBLIC;

--grant execute on procedure DMShortStr to PUBLIC;
--grant execute on procedure DMHMShortStr to PUBLIC;
/*-----------------------------------------------------------------------------------------------*/

