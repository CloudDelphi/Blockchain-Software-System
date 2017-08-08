/* ************************************************************************ */
/* PeopleRelay: ndvote.sql Version: see version.sql                         */
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
create generator P_G$NDV;
/*-----------------------------------------------------------------------------------------------*/
create table P_TNDVoter(
  RecId             TRid,
  ParId             TRid,
  NodeId            TNodeId not null,
  Acceptor          TBoolean,  
  CreatedAt         TTimeMark default CURRENT_TIMESTAMP not null,
  primary key       (RecId),
  foreign key       (ParId) references P_TNodelog(RecId)
    on update       CASCADE
    on delete       CASCADE);
/*-----------------------------------------------------------------------------------------------*/
create unique index P_XU$NDV1 on P_TNDVoter(ParId,NodeId);
/*-----------------------------------------------------------------------------------------------*/
set term ^ ;
/*-----------------------------------------------------------------------------------------------*/
create trigger P_TBI$TNDVoter for P_TNDVoter active before insert position 0
as
begin
  new.RecId = gen_id(P_G$NDV,1);
end^
/*-----------------------------------------------------------------------------------------------*/
set term ; ^
/*-----------------------------------------------------------------------------------------------*/
create view P_NDV
as
  select
    NL.*,
    (select count(RecId) from P_TNDVoter V where V.ParId = NL.RecId ) as Voters,
    (select count(RecId) from P_TNDVoter V where V.ParId = NL.RecId and V.Acceptor = 1) as ACnt
  from
    P_TNodelog NL
  where State = 0;
/*-----------------------------------------------------------------------------------------------*/

