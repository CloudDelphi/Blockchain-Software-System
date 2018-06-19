/* ======================================================================== */
/* PeopleRelay: mpvote.sql Version: 0.4.1.8                                 */
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
create generator P_G$MPV;
/*-----------------------------------------------------------------------------------------------*/
create table P_TMPVoter(
  RecId             TRid,
  ParId             TRid,
  SelfHash          TChHash not null,
  NodeId            TNodeId not null,
  RT                TCount,
  CreatedAt         TTimeMark not null,
  primary key       (RecId),
  foreign key       (ParId) references P_TMeltingPot(RecId)
    on update       CASCADE
    on delete       CASCADE);
/*-----------------------------------------------------------------------------------------------*/
create unique index P_XU$MPV1 on P_TMPVoter(ParId,NodeId);
create unique index P_XU$MPV2 on P_TMPVoter(ParId,SelfHash,NodeId);
/*-----------------------------------------------------------------------------------------------*/
set term ^ ;
/*-----------------------------------------------------------------------------------------------*/
create trigger P_TBI$TMPVoter for P_TMPVoter active before insert position 0
as
begin
  new.CreatedAt = UTCTime();
  new.RT = Gen_Id(P_G$RTT,0);
  new.RecId = gen_id(P_G$MPV,1);
end^
/*-----------------------------------------------------------------------------------------------*/
set term ; ^
/*-----------------------------------------------------------------------------------------------*/
create view P_MPVoter as select * from P_TMPVoter;
/*-----------------------------------------------------------------------------------------------*/
