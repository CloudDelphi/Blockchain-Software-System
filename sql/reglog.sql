/* ************************************************************************ */
/* PeopleRelay: reglog.sql Version: see version.sql                         */
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
create table P_TRegLog1(
  NodeId            TNodeId,
  Alias             TNdAlias,
  Status            TNdStatus,
  Acceptor          TBoolean,
  IpMaskLen         TUInt,
  IP                TIPV6str,
  APort             TPort,
  APath             TPath,
  AUser             TUserName,
  APWD              TPWD,
  EditTime          TTimeMark,
  LoadSig           TSig,
  PubKey            TKey,
  primary key (NodeId));
/*-----------------------------------------------------------------------------------------------*/
set term ^ ;
/*-----------------------------------------------------------------------------------------------*/
create trigger P_TBI$TRegLog1 for P_TRegLog1 active before insert position 0
as
begin
  new.IP = Upper(new.IP);
  new.APort = Upper(new.APort);
  new.APath = Upper(new.APath);
  new.AUser = Upper(new.AUser);
end^
/*-----------------------------------------------------------------------------------------------*/
set term ; ^
/*-----------------------------------------------------------------------------------------------*/
create table P_TRegLog2(
  NodeId            TNodeId,
  RT                TCount,
  primary key (NodeId));
/*-----------------------------------------------------------------------------------------------*/
set term ^ ;
/*-----------------------------------------------------------------------------------------------*/
create trigger P_TBI$TRegLog2 for P_TRegLog2 active before insert position 0
as
begin
  new.RT = Gen_Id(P_G$RTT,0);
end^
/*-----------------------------------------------------------------------------------------------*/
alter procedure P_ClearRegLog2
as
begin
  delete from P_TRegLog2;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_UpdateRL2(NodeId TNodeId)
as
begin
  if (not exists (select 1 from P_TRegLog2 where NodeId = :NodeId)) then
    insert into P_TRegLog2(NodeId) values(:NodeId);
  when any do
    if (sqlcode <> -803) then
      execute procedure P_LogErr(-20,sqlcode,gdscode,sqlstate,'P_UpdateRL2',NodeId,'Error',null);
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_FixReg
as
  declare Quorum TCount;
begin
  merge into P_TNode N
    using P_TRegLog1 L
      on L.NodeId = N.NodeId
    when matched then
      update set
        N.Alias = L.Alias,
        N.Status = L.Status,
        N.Acceptor = L.Acceptor,
        N.IpMaskLen = L.IpMaskLen,
        N.IP = L.IP,
        N.APort = L.APort,
        N.APath = L.APath,
        N.ExtAcc = L.AUser,
        N.ExtPWD = L.APWD,
        N.EditTime = L.EditTime,
        N.LoadSig = L.LoadSig,
        N.PubKey = L.PubKey
    when not matched then
      insert (N.NodeId,N.Alias,N.Status,N.Acceptor,N.IpMaskLen,N.IP,N.APort,N.APath,
          N.ExtAcc,N.ExtPWD,N.EditTime,N.LoadSig,N.PubKey)
        values (L.NodeId,L.Alias,L.Status,L.Acceptor,L.IpMaskLen,L.IP,L.APort,L.APath,
          L.AUser,L.APWD,L.EditTime,L.LoadSig,L.PubKey);

  begin
    delete from P_TRegLog1;
    when any do
      execute procedure P_LogErr(-22,sqlcode,gdscode,sqlstate,'P_FixReg','P_TRegLog1','Del Error',null);
  end

  execute procedure P_GetQuorum(3,-1) returning_values Quorum;
  if ((select count(*) from P_TRegLog2) >= Quorum) then
  begin
    execute procedure P_Altered(0);
    execute procedure P_ClearRegLog2; /* In case it is already Unaltered */
  end
end^
/*-----------------------------------------------------------------------------------------------*/
set term ; ^
/*-----------------------------------------------------------------------------------------------*/
create view P_RegLog1 as select * from P_TRegLog1;
create view P_RegLog2 as select * from P_TRegLog2;
/*-----------------------------------------------------------------------------------------------*/
grant all on P_TNode to procedure P_FixReg;
grant all on P_TRegLog1 to procedure P_FixReg;

grant select on P_TRegLog2 to procedure P_FixReg;
grant execute on procedure P_LogErr to procedure P_FixReg;
grant execute on procedure P_Altered to procedure P_FixReg;
grant execute on procedure P_GetQuorum to procedure P_FixReg;
grant execute on procedure P_ClearRegLog2 to procedure P_FixReg;

grant all on P_TRegLog2 to procedure P_ClearRegLog2;

grant all on P_TRegLog2 to procedure P_UpdateRL2;
grant execute on procedure P_LogErr to procedure P_UpdateRL2;
/*-----------------------------------------------------------------------------------------------*/

