/* ======================================================================== */
/* PeopleRelay: nodelist.sql Version: 0.4.1.8                               */
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
set term ^ ;
/*-----------------------------------------------------------------------------------------------*/
create procedure P_NodeList(RepKind TRepKind,Acceptor TBoolean)
returns
 (NRecId            TRef,
  Accept            TBoolean,
  NodeId            TNodeId,
  SigHash           TIntHash,
  IP                TIPV6str,
  APort             TPort,
  ExtAcc            TUserName,
  ExtPWD            TPWD,
  FullPath          TFullPath)
as
begin
  if ((RepKind <> 2
      and (select Broadband from P_TParams) = 1)
    or (RepKind = 3
      and not exists (select 1 from P_TNode where Acceptor = 1)))
  then
    Acceptor = 0;

  for select
     RecId,
     Acceptor,
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
      and (:Acceptor = 0 or Acceptor = 1)
    order by
      (select Result from P_NodeRating(RecId,NodeId)) desc,rand()
    into
      :NRecId,
      :Accept,
      :NodeId,
      :SigHash,
      :IP,
      :APort,
      :ExtAcc,
      :ExtPWD,
      :FullPath
  do
    suspend;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_NodeCacheHit(Acceptor TBoolean,NodeId TNodeId)
returns
  (Result TBoolean)
as
begin
  if (exists (select 1 from P_NodeList(0,:Acceptor) where NodeId = :NodeId)) then Result = 1;
end^
/*-----------------------------------------------------------------------------------------------*/
set term ; ^
/*-----------------------------------------------------------------------------------------------*/
grant select on P_TNode to procedure P_NodeList;
grant select on P_TParams to procedure P_NodeList;
grant execute on procedure P_NodeRating to procedure P_NodeList;

grant execute on procedure P_NodeList to procedure P_NodeCacheHit;
/*-----------------------------------------------------------------------------------------------*/
