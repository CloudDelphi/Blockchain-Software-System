/* ======================================================================== */
/* PeopleRelay: scope.sql Version: 0.4.3.6                                  */
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
create generator P_G$Scope;
/*-----------------------------------------------------------------------------------------------*/
create table P_TScope(
  RecId             TRid,
  ACLId             TRid,
  Address           TAddress not null,
  SenderId          TSenderId not null,
  Comment           TComment,
  CreatedBy         TOperName,
  ChangedBy         TOperName,
  CreatedAt         TTimeMark,
  ChangedAt         TTimeMark,
  primary key       (RecId),
  foreign key       (ACLId) references P_TACL(RecId)
    on update       CASCADE
    on delete       CASCADE);
/*-----------------------------------------------------------------------------------------------*/
create unique index P_XU$Scope on P_TScope(ACLId,Address,SenderId);
/*-----------------------------------------------------------------------------------------------*/
set term ^ ;
/*-----------------------------------------------------------------------------------------------*/
create trigger P_TBI$TScope for P_TScope active before insert position 0
as
begin
  if (new.RecId is null) then new.RecId = gen_id(P_G$Scope,1);
  new.CreatedBy = CURRENT_USER;
  new.CreatedAt = UTCTime();
  new.ChangedBy = new.CreatedBy;
  new.ChangedAt = new.CreatedAt;
end^
/*-----------------------------------------------------------------------------------------------*/
create trigger P_TBU$TScope for P_TScope active before update position 0
as
begin
  new.RecId = old.RecId;
  new.CreatedBy = old.CreatedBy;
  new.CreatedAt = old.CreatedAt;
  new.ChangedBy = CURRENT_USER;
  new.ChangedAt = UTCTime();
end^
/*-----------------------------------------------------------------------------------------------*/
set term ; ^
/*-----------------------------------------------------------------------------------------------*/
create view P_MyScope(
  RecId,
  Address,
  SenderId,
  UserName)
as
  select
    S.RecId,
    S.Address,
    S.SenderId,
    L.Name
  from
    P_TScope S
  inner join P_TACL L
    on S.ACLId = L.RecId
  where L.Name = CURRENT_USER;
/*-----------------------------------------------------------------------------------------------*/

