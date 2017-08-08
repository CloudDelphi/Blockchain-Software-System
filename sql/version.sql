/* ************************************************************************ */
/* PeopleRelay: version.sql                                                 */
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
create procedure P_Version
returns
  (Result TSysStr12)
as
begin
  Result = '0.3.2.4';
  suspend;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_Copyright
returns
  (Result TSysStr64)
as
begin
  Result = '2017 Aleksei Ilin & Igor Ilin';
  suspend;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_ProductName
returns
  (Result TSysStr31)
as
begin
  Result = 'PeopleRelay Database';
  suspend;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_WebSite
returns
  (Result TSysStr31)
as
begin
  Result = 'peoplerelay.com';
  suspend;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_DBVersion
returns
  (Result TSysStr31)
as
begin
  Result = 'Firebird ' || rdb$get_context('SYSTEM','ENGINE_VERSION');
  suspend;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_Info
returns
  (Name TSysStr31,
  Data TSysStr64)
as
begin
  Name = 'Product Name';
  select Result from P_ProductName into :Data;
  suspend;

  Name = 'Product Copyright';
  select Result from P_Copyright into :Data;
  suspend;

  Name = 'Web Site';
  select Result from P_WebSite into :Data;
  suspend;

  Name = 'Product Version';
  select Result from P_Version into :Data;
  suspend;

  Name = 'DBMS Version';
  select Result from P_DBVersion into :Data;
  suspend;  
end^
/*-----------------------------------------------------------------------------------------------*/
set term ; ^
/*-----------------------------------------------------------------------------------------------*/
grant execute on procedure P_WebSite to procedure P_Info;
grant execute on procedure P_Version to procedure P_Info;
grant execute on procedure P_DBVersion to procedure P_Info;
grant execute on procedure P_Copyright to procedure P_Info;
grant execute on procedure P_ProductName to procedure P_Info;
/*-----------------------------------------------------------------------------------------------*/
