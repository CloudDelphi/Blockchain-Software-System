/* ======================================================================== */
/* PeopleRelay: archive.sql Version: 0.4.3.6                                */
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
create table P_TArchLog(
  BlockNo           TRid,
  Chsum             TIntHash not null,
  BHash             TChHash not null,
  BlockId           TBlockId not null,
  SenderId          TSenderId not null,

  State             TState,
  CreatedBy         TOperName,
  ChangedBy         TOperName,
  CreatedAt         TTimeMark,
  ChangedAt         TTimeMark,
  primary key       (BlockNo),
  foreign key       (BlockNo,Chsum,BHash) references P_TChain(BlockNo,Chsum,BHash)
    on update       CASCADE
    on delete       CASCADE);
/*-----------------------------------------------------------------------------------------------*/
set term ^ ;
/*-----------------------------------------------------------------------------------------------*/
create or alter procedure P_Truncate(BlockNo TRid)
as
begin
  if ((select Result from P_BegTrim) = 1) then
  begin
    update P_TChain
      set
        ParBlkNo = 0,
        ParChsum = '0',
        ParBHash = '0'
      where BlockNo <= :BlockNo
        and BlockNo > 0
        and ParBlkNo > 0
      order by BlockNo desc;
    delete from P_TChain where BlockNo > 0 and BlockNo < :BlockNo;
    execute procedure P_EndTrim;
  end

  when any do
    execute procedure P_LogErr(-500,sqlcode,gdscode,sqlstate,'P_Truncate',null,'Error',null);

end^
/*-----------------------------------------------------------------------------------------------*/
set term ; ^
/*-----------------------------------------------------------------------------------------------*/
create view P_ArchLog as select * from P_TArchLog;
/*-----------------------------------------------------------------------------------------------*/
grant all on P_TChain to procedure P_Truncate;
grant execute on procedure P_LogErr to procedure P_Truncate;
grant execute on procedure P_BegTrim to procedure P_Truncate;
grant execute on procedure P_EndTrim to procedure P_Truncate;
/*-----------------------------------------------------------------------------------------------*/


