@echo off
Rem ======================================================================== Rem
Rem PeopleRelay: build.bat Version: 0.4.1.8                                  Rem
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

if not exist %prm% goto :err
for /f "delims== tokens=1,2" %%G in (%prm%) do set %%G=%%H

call .\build_pr.bat

cd %~dp0
call .\build_app.bat

cd %~dp0
call .\repack.bat

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
