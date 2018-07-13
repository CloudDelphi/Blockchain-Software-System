@echo off
Rem ======================================================================== Rem
Rem PeopleRelay: repack.bat Version: 0.4.3.6                                 Rem
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

set std=%cd%
set prm=.\build.conf

cd %~dp0

if not exist %prm% goto :err1
for /f "delims== tokens=1,2" %%G in (%prm%) do set %%G=%%H

if not exist %db_path%%db_file% goto :err2

if exist %db_path%%db_file_bak% del %db_path%%db_file_bak%

@echo on
%util_path%%util_gbak% -b -USER SYSDBA -PAS %password% %ip%/%ip_port%:%db_path%%db_file% %db_path%%db_file_bak%
%util_path%%util_gbak% -REP -K -USER SYSDBA -PAS %password% %db_path%%db_file_bak% %ip%/%ip_port%:%db_path%%db_file%
@echo off

::rename to lowercase
cd %db_path%
ren %db_file% %db_file%

goto :end
:err1
Rem cls
@echo on
@echo Could not find file "%prm%"
@echo -----------------------
@echo off
pause
goto :end

:err2
Rem cls
@echo on
@echo Could not find file "%db_path%%db_file%"
@echo -----------------------
@echo off
pause

:end
cd %std%
