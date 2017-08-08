/* ************************************************************************ */
/* PeopleRelay: fields.sql Version: see version.sql                         */
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
SET NAMES UTF8;
SET SQL DIALECT 3;
SET AUTODDL ON;
CONNECT '127.0.0.1:c:\database\peoplerelay.fb';
/*-----------------------------------------------------------------------------------------------*/
insert into P_TTransponder(Prime,Cluster) values(uuid_to_Char(gen_uuid()),uuid_to_Char(gen_uuid()));
commit work;
/*-----------------------------------------------------------------------------------------------*/
input fields.sql;
commit work;
/*-----------------------------------------------------------------------------------------------*/
execute procedure P_Build;
commit work;
/*-----------------------------------------------------------------------------------------------*/
input drop_constr.sql;
commit work;
/*-----------------------------------------------------------------------------------------------*/
