/* ======================================================================== */
/* PeopleRelay: grantsys.sql Version: 0.4.3.6                               */
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
grant select on mon$database to procedure SYS_DBName;
grant select on mon$call_stack to procedure SYS_OnlyObj;

grant select on mon$attachments to procedure SYS_IP;
grant select on mon$attachments to procedure SYS_Proto;
grant select on mon$attachments to trigger P_T$Connect;
grant all on mon$attachments to procedure P_CheckAttach;
/*-----------------------------------------------------------------------------------------------*/

