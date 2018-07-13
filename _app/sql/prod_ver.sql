/* ======================================================================== */
/* PeopleRelay: prod_ver.sql Version: 0.4.3.6                               */
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
alter procedure P_Comments
returns
  (Result TString64)
as
begin
  Result = null;
  suspend;
end^
/*-----------------------------------------------------------------------------------------------*/
alter procedure P_ProdVer
returns
  (Result TString16)
as
begin
  Result = '1.0.0.0';
  suspend;
end^
/*-----------------------------------------------------------------------------------------------*/
alter procedure P_ProdRights
returns
  (Result TString64)
as
begin
  Result = 'PeopleRelay Team';
  suspend;
end^
/*-----------------------------------------------------------------------------------------------*/
alter procedure P_ProdName
returns
  (Result TString64)
as
begin
  Result = 'PeopleRelay';
  suspend;
end^
/*-----------------------------------------------------------------------------------------------*/
alter procedure P_ProdSite
returns
  (Result TString64)
as
begin
  Result = 'www.peoplerelay.com';
  suspend;
end^
/*-----------------------------------------------------------------------------------------------*/
set term ; ^
/*-----------------------------------------------------------------------------------------------*/
