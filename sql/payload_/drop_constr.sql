/* ************************************************************************ */
/* PeopleRelay: drop_constr.sql Version: see version.sql                    */
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

drop procedure P_Build;
drop procedure P_FinishBuild;
drop procedure P_DoGrants;
drop procedure P_BeginBuild;
drop procedure P_BuildRepl;
drop procedure P_S$SenderSQL;
drop procedure P_S$NewBlock;
drop procedure P_S$GetHash;
drop procedure P_S$Commit;
drop procedure P_S$MPRep;
drop procedure P_S$FixChain;
drop procedure P_S$ReplChain;
drop procedure P_S$AddBlock;
drop procedure P_S$RevertBlock;
drop procedure P_StmFields;
drop procedure P_FieldHash;
drop procedure P_BlArgFlt;
drop procedure P_Vars;
drop procedure P_FieldArgs;
drop procedure P_Decl;
drop procedure P_Args_x;
drop procedure P_Args;
drop procedure P_CreateField;
drop procedure P_IsQuoted;
drop procedure P_DropFields;
drop procedure P_DropField;
drop procedure P_FieldCount;
drop procedure P_EnumFields;

drop procedure P$EncStm;
drop procedure P$UTFStm;
drop procedure P$EncType;

drop view P_Fields;
drop table P_TFields;
drop exception PE$KeyWord;
drop table P$TSysNames;
drop table P$TKeyWords;
drop table P$TFldFlt;

