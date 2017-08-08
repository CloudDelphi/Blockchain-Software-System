/* ************************************************************************ */
/* PeopleRelay: nodecache.sql Version: see version.sql                      */
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
create global temporary table P_TNodeCahe(
  NRecId            TRid,
  SortId            DOUBLE PRECISION not null,
  NodeId            TNodeId not null,
  SigHash           TIntHash, /* do not check is null, can be null on very first iteration */

  IP                TIPV6str not null,
  APort             TPort default '3050',

  ExtAcc            TUserName not null,
  ExtPWD            TPWD not null,
  FullPath          TFullPath not null,
  primary key       (NRecId)
) on commit preserve rows;
/*-----------------------------------------------------------------------------------------------*/
create descending index P_X$NCahe on P_TNodeCahe(SortId);
/*-----------------------------------------------------------------------------------------------*/
create view P_NodeCahe as select * from P_TNodeCahe order by SortId desc;
/*-----------------------------------------------------------------------------------------------*/
set term ^ ;
/*-----------------------------------------------------------------------------------------------*/

create procedure P_FillNodeCahe(RepKind TRepKind,Acceptor TBoolean)
returns
  (Result TCount)
as
begin
  execute procedure P_VoteLim(RepKind,Acceptor,0) returning_values Result;

  if (RepKind <> 2
    and (select Broadband from P_TParams) = 1)
  then
    Acceptor = 0;

  delete from P_TNodeCahe;

  insert into
    P_TNodeCahe(
      NRecId,
      SortId,
      NodeId,
      SigHash,
      Ip,
      APort,
      ExtAcc,
      ExtPWD,
      FullPath)
    select
      RecId,
      (Rating + rand()),
      NodeId,
      Hash(LoadSig),
      Ip,
      APort,
      ExtAcc,
      ExtPWD,
      FullPath
    from
      P_TNode
    where Enabled = 1
      and Status >= 0
      and Dimmed = 0
      and (:Acceptor = 0 or Acceptor = 1);
end^
/*-----------------------------------------------------------------------------------------------*/
set term ; ^
/*-----------------------------------------------------------------------------------------------*/
grant select on P_TNode to procedure P_FillNodeCahe;
grant select on P_TParams to procedure P_FillNodeCahe;
grant execute on procedure P_VoteLim to procedure P_FillNodeCahe;

grant all on P_TNodeCahe to PUBLIC;
grant select on P_NodeCahe to PUBLIC;

/*-----------------------------------------------------------------------------------------------*/
