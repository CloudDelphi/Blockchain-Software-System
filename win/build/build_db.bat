@echo off
Rem ======================================================================== Rem
Rem PeopleRelay: build_db.bat Version: 0.4.3.6                               Rem
Rem                                                                          Rem
Rem Copyright 2017-2018 Aleksei Ilin & Igor Ilin                             Rem
Rem                                                                          Rem
Rem Licensed under the Apache License, Version 2.0 (the "License");          Rem
Rem you may not use this file except in compliance with the License.         Rem
Rem You may obtain a copy of the License at                                  Rem
Rem                                                                          Rem
Rem     http://www.apache.org/licenses/LICENSE-2.0                           Rem
Rem                                                                          Rem
Rem Unless required by applicable law or agreed to in writing, software      Rem
Rem distributed under the License is distributed on an "AS IS" BASIS,        Rem
Rem WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. Rem
Rem See the License for the specific language governing permissions and      Rem
Rem limitations under the License.                                           Rem
Rem ======================================================================== Rem
@echo on

Rem cls

@echo off

set dt=%time%
set std=%cd%
set go_sql=.\create.sql
set log=%~dp0..\tmp\db_log.txt

if %1.==. (
  set prm=.\build.conf
) else (
  set prm=%1
)

cd %~dp0

if not exist %prm% goto :err
for /f "delims== tokens=1,2" %%G in (%prm%) do set %%G=%%H

if exist %log% del %log%

cd ..\..\sql

@echo SET SQL DIALECT 3; > %go_sql%
@echo SET NAMES %charset%; >> %go_sql%
@echo SET AUTODDL ON; >> %go_sql%
@echo create database '%ip%/%ip_port%:%db_path%%db_file%' PAGE_SIZE 8192 >> %go_sql%
@echo USER 'SYSDBA' PASSWORD '%password%' DEFAULT CHARACTER SET %charset%; >> %go_sql%
@echo create domain TComment as VarChar(64) COLLATE %collate%; >> %go_sql%
@echo create domain TString16 as VarChar(16) COLLATE %collate%; >> %go_sql%
@echo create domain TString32 as VarChar(32) COLLATE %collate%; >> %go_sql%
@echo create domain TString64 as VarChar(64) COLLATE %collate%; >> %go_sql%
@echo create domain TString128 as VarChar(128) COLLATE %collate%; >> %go_sql%
@echo create domain TString512 as VarChar(512) COLLATE %collate%; >> %go_sql%
@echo create domain TString4K as VarChar(4096) COLLATE %collate%; >> %go_sql%

@echo on
%util_path%%util_isql% -e -b -q -i .\_build.sql -m -o %log%
@echo off

@echo %dt% - %time% >> %log%
start notepad.exe %log%

goto :end

:err
Rem cls
@echo on
@echo Could not find file "%prm%"
@echo -----------------------
@echo off
pause

:end
cd %std%
