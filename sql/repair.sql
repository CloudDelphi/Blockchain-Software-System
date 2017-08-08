/* ************************************************************************ */
/* PeopleRelay: repair.sql Version: see version.sql                         */
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
set term ^ ;
/*-----------------------------------------------------------------------------------------------*/
create procedure P_Dehorn(RecId TRef)
as
  declare tmp TCount;
begin
  if ((select Result from P_BegDehorn) = 1) then
  begin
    RecId = RecId - (select DehornPower from P_TParams); --debug
    if (RecId < 1) then RecId = 1;

    delete from P_TChain
      where RecId >= (:RecId)
      order by RecId desc; --we can delete only last record

    tmp = row_count;
    delete from P_TBackLog;
    execute procedure P_LogMsg(300,RecId,tmp,null,'P_Dehorn',null,null,null);
    execute procedure P_EndDehorn;
    when any do
    begin
      execute procedure P_EndDehorn;
      execute procedure P_LogErr(-300,sqlcode,gdscode,sqlstate,'P_Dehorn',RecId,null,null);
    end
  end
end^
/*-----------------------------------------------------------------------------------------------*/
set term ; ^
/*-----------------------------------------------------------------------------------------------*/
grant all on P_TChain to procedure P_Dehorn;
grant all on P_TBackLog to procedure P_Dehorn;
grant select on P_TParams to procedure P_Dehorn;
grant execute on procedure P_LogMsg to procedure P_Dehorn;
grant execute on procedure P_LogErr to procedure P_Dehorn;
grant execute on procedure P_BegDehorn to procedure P_Dehorn;
grant execute on procedure P_EndDehorn to procedure P_Dehorn;
/*-----------------------------------------------------------------------------------------------*/
