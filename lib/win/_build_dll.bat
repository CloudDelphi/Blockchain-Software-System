echo off
Rem /************************************************************************** */
Rem /* PeopleRelay: build_dll.bat                                                 */
Rem /*                                                                          */
Rem /* Copyright 2017 Aleksei Ilin & Igor Ilin                                  */
Rem /*                                                                          */
Rem /* Licensed under the Apache License, Version 2.0 (the "License");          */
Rem /* you may not use this file except in compliance with the License.         */
Rem /* You may obtain a copy of the License at                                  */
Rem /*                                                                          */
Rem /*     http://www.apache.org/licenses/LICENSE-2.0                           */
Rem /*                                                                          */
Rem /* Unless required by applicable law or agreed to in writing, software      */
Rem /* distributed under the License is distributed on an "AS IS" BASIS,        */
Rem /* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. */
Rem /* See the License for the specific language governing permissions and      */
Rem /* limitations under the License.                                           */
Rem /* ************************************************************************ */
echo on

PATH=C:\lazarus\fpc\3.0.2\bin\x86_64-win64\;%PATH%

cd .\
fpc.exe -Mdelphi .\hudf.dpr > .\logs\build_log.txt

