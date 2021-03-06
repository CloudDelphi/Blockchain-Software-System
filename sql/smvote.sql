/* ======================================================================== */
/* PeopleRelay: smvote.sql Version: 0.4.3.6                                 */
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
create generator P_G$SMV;
/*-----------------------------------------------------------------------------------------------*/
create table P_TSMVoter(
  RecId             TRid,
  ParId             TRid,
  BlockNo           TRid,
  BHash             TChHash not null,
  NodeId            TNodeId not null,
  Acceptor          TBoolean,
  RT                TCount,
  CreatedAt         TTimeMark not null,
  primary key       (RecId),
  foreign key       (ParId) references P_TBackLog(RecId)
    on update       CASCADE
    on delete       CASCADE);
/*-----------------------------------------------------------------------------------------------*/
create unique index P_XU$SMV1 on P_TSMVoter(ParId,NodeId);
/*-----------------------------------------------------------------------------------------------*/
set term ^ ;
/*-----------------------------------------------------------------------------------------------*/
create trigger P_TBI$TSMVoter for P_TSMVoter active before insert position 0
as
begin
  new.CreatedAt = UTCTime();
  new.RT = Gen_Id(P_G$RTT,0);
  new.RecId = gen_id(P_G$SMV,1);
end^
/*-----------------------------------------------------------------------------------------------*/
set term ; ^
/*-----------------------------------------------------------------------------------------------*/
create view P_SMVoter as select * from P_TSMVoter;
/*-----------------------------------------------------------------------------------------------*/
