/* ======================================================================== */
/* PeopleRelay: excepts.sql Version: 0.4.3.6                                */
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
create exception P_E$Init 'This Node is already Initialized, use P_Init procedure to Reinitialize Node.';
create exception P_E$Repack 'Database needs repack (backup / restore) before Initialization.';
create exception P_E$ShortAcc 'Account name is too short. Minimum Account name length is 5 symbols.';
create exception P_E$ShortPWD 'The password is too short. Minimum password length is 7 symbols.';

/*
create exception P_E$BadNodeData 'Incorrect Node Data.';
create exception P_E$BadNodeId 'Incorrect NodeId.';
create exception P_E$BadTmpSig 'Incorrect Temp Sig.';
create exception P_E$BadNodeSig 'Incorrect Node Sig.';
*/

create exception P_E$Recursion 'Recursive operation is not supported.';
create exception P_E$Forbidden 'Operation Forbidden.';
create exception P_E$TableHasData 'Cannot rebuild table containing data.';
create exception P_E$OneRecNeeded 'Table must has one record exactly.';
create exception P_E$MaxIdlConn 'Maximum count of idle connections exceeded.';
create exception P_E$MaxActConn 'Maximum count of active connections exceeded.';
create exception P_E$Connection 'Connection Error.';
create exception P_E$ServiceNA 'Service unavailable try it later on.';
create exception P_E$ExtAcc 'Cannot set SU as external Account.';
create exception P_E$ExtAccIns 'Cannot directly set an external Account - use P_TParams table.';
create exception P_E$SyncBotAcc 'Sync Bot account already exists.';
create exception P_E$NewBlock 'NewBlock error.';
create exception P_E$SelfNode 'Cannot use Self Node as a Peer Node.';
/*-----------------------------------------------------------------------------------------------*/
