/* ************************************************************************ */
/* PeopleRelay: grants.sql Version: see version.sql                         */
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
grant execute on procedure P_Info to PUBLIC;
/*-----------------------------------------------------------------------------------------------*/
grant all on P_Quorum to PUBLIC;
/*-----------------------------------------------------------------------------------------------*/
/* Test case */
--grant execute on procedure P_Sync to PUBLIC;
--grant all on P_Node to PUBLIC;
--grant all on P_Checks to PUBLIC;
--grant all on P_ChkLog to PUBLIC;
--grant all on P_DBLogLegal to PUBLIC;
--grant all on P_DBLogFrotz to PUBLIC;
--grant all on P_DBLogFrDir to PUBLIC;
--grant all on P_DBLogLgDir to PUBLIC;
--grant all on P_Log to PUBLIC;
--grant all on P_ErrorLog to PUBLIC;
--grant all on P_Fields to PUBLIC;
--grant all on P_ReplLog to PUBLIC;
--grant all on P_SyncTM to PUBLIC;
--grant all on P_Params to PUBLIC;
--grant all on P_IpBan to PUBLIC;
--grant all on SYS_FieldInfo to PUBLIC;
--grant all on SYS_CallStack to PUBLIC;
--grant all on P_Users to PUBLIC;
/*-----------------------------------------------------------------------------------------------*/
--grant execute on procedure P_Echo to PUBLIC;
--grant execute on procedure P_Build to PUBLIC;
--grant execute on procedure P_RegNode to PUBLIC;
--grant execute on procedure P_IsBlock to PUBLIC;
--grant execute on procedure P_Register to PUBLIC;
--grant execute on procedure P_DailyJob to PUBLIC;
--grant execute on procedure P_CheckBlock to PUBLIC;
/*-----------------------------------------------------------------------------------------------*/

