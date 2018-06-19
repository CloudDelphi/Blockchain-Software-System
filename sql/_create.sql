/* ======================================================================== */
/* PeopleRelay: _create.sql Version: 0.4.1.8                                 */
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

SET SQL DIALECT 3;
SET NAMES UTF8;
SET AUTODDL ON;
create database '127.0.0.1/3050:peoplerelay.fb' PAGE_SIZE 8192
USER 'SYSDBA' PASSWORD 'masterkey' DEFAULT CHARACTER SET UTF8;
create domain TComment as VarChar(64) COLLATE UNICODE_CI;
create domain TString16 as VarChar(16) COLLATE UNICODE_CI;
create domain TString32 as VarChar(32) COLLATE UNICODE_CI;
create domain TString64 as VarChar(64) COLLATE UNICODE_CI;
create domain TString128 as VarChar(128) COLLATE UNICODE_CI;
create domain TString512 as VarChar(512) COLLATE UNICODE_CI;
create domain TString4K as VarChar(4096) COLLATE UNICODE_CI;
