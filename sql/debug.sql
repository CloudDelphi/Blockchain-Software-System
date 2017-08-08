/* ************************************************************************ */
/* PeopleRelay: node.sql Version: see version.sql                           */
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
create generator P_G$Debug;
/*-----------------------------------------------------------------------------------------------*/
create table P_TDebug(
  RecId             TRid,
  TransId           TInt32,
  Comment           TComment,
  CallStack         TMemo,
  Statement         TMemo,

  CreatedBy         TOperName,
  ChangedBy         TOperName,
  CreatedAt         TTimeMark not null,
  ChangedAt         TTimeMark not null,
  primary key       (RecId));
/*-----------------------------------------------------------------------------------------------*/
set term ^ ;
/*-----------------------------------------------------------------------------------------------*/
create trigger P_TBI$TDebug for P_TDebug active before insert position 0
as
  declare attachment_id Integer;
  declare object_name TSysStr32;
  declare object_type SmallInt;
begin
  if (new.RecId is null) then new.RecId = gen_id(P_G$Debug,1);

  new.CreatedBy = CURRENT_USER;
  new.CreatedAt = CURRENT_TIMESTAMP;
  new.ChangedBy = new.CreatedBy;
  new.ChangedAt = new.CreatedAt;
  new.TransId = CURRENT_TRANSACTION;      

  new.CallStack = '';

  in autonomous transaction do
    for select
        attachment_id,
        object_name,
        object_type
      from
        SYS_CallStack
      into
        :attachment_id,
        :object_name,
        :object_type
    do
      new.CallStack = new.CallStack
        || attachment_id || '-'
        || object_type || '; '
        || object_name || ASCII_CHAR(10)
        || '----------' || ASCII_CHAR(10);

  if (new.CallStack = '') then new.CallStack = null;    

end^
/*-----------------------------------------------------------------------------------------------*/
set term ; ^
/*-----------------------------------------------------------------------------------------------*/
grant select on SYS_CallStack to trigger P_TBI$TDebug;
/*-----------------------------------------------------------------------------------------------*/
