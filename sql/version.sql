/* ======================================================================== */
/* PeopleRelay: version.sql Version: 0.4.3.6                                */
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
create generator P_G$SP;
create generator P_G$ProdSP;
/*-----------------------------------------------------------------------------------------------*/
/*-----------------------------------------------------------------------------------------------*/
create table P_TSP(
  RecId             TRid,
  SP                TSysStr32,
  Comment           TComment,
  CreatedBy         TUserName,
  CreatedAt         TTimeMark,
  primary key       (RecId));
/*-----------------------------------------------------------------------------------------------*/
create unique ascending index P_XU$SP on P_TSP(RecId);
/*-----------------------------------------------------------------------------------------------*/
set term ^ ;
/*-----------------------------------------------------------------------------------------------*/
create trigger P_TBI$TSP for P_TSP active before insert position 0
as
begin
  new.RecId = gen_id(P_G$SP,1);
  new.CreatedBy = CURRENT_USER;
  new.CreatedAt = UTCTime();
end^
/*-----------------------------------------------------------------------------------------------*/
create trigger P_TBU$TSP for P_TSP active before update position 0
as
begin
  exception P_E$Forbidden;
end^
/*-----------------------------------------------------------------------------------------------*/
create trigger P_TBD$TSP for P_TSP active before delete position 0
as
begin
  exception P_E$Forbidden;
end^
/*-----------------------------------------------------------------------------------------------*/
/*-----------------------------------------------------------------------------------------------*/
set term ; ^
/*-----------------------------------------------------------------------------------------------*/
create table P_TProdSP(
  RecId             TRid,
  SP                TSysStr32,
  Comment           TComment,
  CreatedBy         TUserName,
  CreatedAt         TTimeMark,
  primary key       (RecId));
/*-----------------------------------------------------------------------------------------------*/
create unique ascending index P_XU$ProdSP on P_TSP(RecId);
/*-----------------------------------------------------------------------------------------------*/
set term ^ ;
/*-----------------------------------------------------------------------------------------------*/
create trigger P_TBI$TProdSP for P_TProdSP active before insert position 0
as
begin
  new.RecId = gen_id(P_G$ProdSP,1);
  new.CreatedBy = CURRENT_USER;
  new.CreatedAt = UTCTime();
end^
/*-----------------------------------------------------------------------------------------------*/
create trigger P_TBU$TProdSP for P_TProdSP active before update position 0
as
begin
  exception P_E$Forbidden;
end^
/*-----------------------------------------------------------------------------------------------*/
create trigger P_TBD$TProdSP for P_TProdSP active before delete position 0
as
begin
  exception P_E$Forbidden;
end^
/*-----------------------------------------------------------------------------------------------*/
/*-----------------------------------------------------------------------------------------------*/
create procedure P_DBMSVer
returns
  (Result TString32)
as
begin
  Result = 'Firebird ' || rdb$get_context('SYSTEM','ENGINE_VERSION');
  suspend;
end^
/*-----------------------------------------------------------------------------------------------*/
/*-----------------------------------------------------------------------------------------------*/
create procedure P_CoreVer
returns
  (Result TString16)
as
begin
  Result = '0.4.3.6';
  suspend;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_CoreRights
returns
  (Result TString63)
as
begin
  Result = 'PeopleRelay Team';
  suspend;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_CoreName
returns
  (Result TString32)
as
begin
  Result = 'PeopleRelay';
  suspend;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_CoreSite
returns
  (Result TString63)
as
begin
  Result = 'www.peoplerelay.com';
  suspend;
end^
/*-----------------------------------------------------------------------------------------------*/
/*-----------------------------------------------------------------------------------------------*/
create procedure P_ProdVer
returns
  (Result TString16)
as
begin
  Result = '1.0.0.0';
  suspend;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_ProdRights
returns
  (Result TString63)
as
begin
  Result = 'PeopleRelay Team';
  suspend;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_ProdName
returns
  (Result TString63)
as
begin
  Result = 'PeopleRelay';
  suspend;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_ProdSite
returns
  (Result TString63)
as
begin
  Result = 'www.peoplerelay.com';
  suspend;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_Comments
returns
  (Result TString63)
as
begin
  Result = null;
  suspend;
end^
/*-----------------------------------------------------------------------------------------------*/
/*-----------------------------------------------------------------------------------------------*/
create procedure P_Info
returns
  (Name TString32,
  Data TString63)
as
  declare s TSysStr32;
begin
  Name = 'Comments';
  select Result from P_Comments into :Data;
  suspend;
  Name = 'DBMS Version';
  select Result from P_DBMSVer into :Data;
  suspend;
  Name = 'UDF Lib Version';
  Data = LibVer();
  suspend;
  Name = 'Identity Hash';
  select Result from SYS_IdentHash into :Data;
  suspend;
  Name = 'Metadata Hash';
  select Result from SYS_MetaHash into :Data;
  suspend;
---------------------------------------------
  Name = 'Core Name';
  select Result from P_CoreName into :Data;
  suspend;

  Name = 'Core Version';
  select Result from P_CoreVer into :Data;
  select first 1 SP from P_TSP order by RecId desc into :s;
  if (s is not null) then Data = Data || ' SP(' || s || ')';
  suspend;

  Name = 'Core Copyright';
  select Result from P_CoreRights into :Data;
  suspend;

  Name = 'Core Web Site';
  select Result from P_CoreSite into :Data;
  suspend;
---------------------------------------------
  Name = 'Product Name';
  select Result from P_ProdName into :Data;
  suspend;

  Name = 'Product Version';
  select Result from P_ProdVer into :Data;
  select first 1 SP from P_TProdSP order by RecId desc into :s;
  if (s is not null) then Data = Data || ' SP(' || s || ')';
  suspend;
  
  Name = 'Product Copyright';
  select Result from P_ProdRights into :Data;
  suspend;

  Name = 'Product Web Site';
  select Result from P_ProdSite into :Data;
  suspend;
end^
/*-----------------------------------------------------------------------------------------------*/
set term ; ^
/*-----------------------------------------------------------------------------------------------*/
grant select on P_TSP to procedure P_Info;
grant select on P_TProdSP to procedure P_Info;
grant execute on procedure P_DBMSVer to procedure P_Info;

grant execute on procedure P_CoreVer to procedure P_Info;
grant execute on procedure P_CoreSite to procedure P_Info;
grant execute on procedure P_CoreName to procedure P_Info;
grant execute on procedure P_Comments to procedure P_Info;
grant execute on procedure P_CoreRights to procedure P_Info;

grant execute on procedure P_ProdVer to procedure P_Info;
grant execute on procedure P_ProdSite to procedure P_Info;
grant execute on procedure P_ProdName to procedure P_Info;
grant execute on procedure P_ProdRights to procedure P_Info;

grant execute on procedure SYS_MetaHash to procedure P_Info;
grant execute on procedure SYS_IdentHash to procedure NM_Info;
grant execute on procedure P_Info to PUBLIC;
/*-----------------------------------------------------------------------------------------------*/
