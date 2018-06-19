/* ======================================================================== */
/* PeopleRelay: reglog.sql Version: 0.4.1.8                                 */
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
/*
To register incoming requests.
*/

create table P_TRegInq(
  NodeId            TNodeId,
  Alias             TNdAlias,
  Status            TNdStatus,
  Acceptor          TBoolean,
  IpMaskLen         TUInt,
  IP                TIPV6str,
  APort             TPort,
  APath             TPath,
  ExtAcc            TUserName,
  ExtPWD            TPWD,
  EditTime          TTimeMark,
  LoadSig           TSig,
  PubKey            TKey,
  primary key       (NodeId));
/*-----------------------------------------------------------------------------------------------*/
set term ^ ;
/*-----------------------------------------------------------------------------------------------*/
create procedure P_Unaltered
as
  declare ATest TTimeMark;
begin
  if ((select Result from P_BegAlt)= 1) then
  begin
    select AlteredAt from P_TParams
      for update of AlteredAt WITH LOCK into :ATest; /* error here if record locked */
    update P_TParams set AlteredAt = null;
    execute procedure P_EndAlt;
    when any do
    begin
      execute procedure P_EndAlt;
      execute procedure P_LogErr(-27,sqlcode,gdscode,sqlstate,'P_Unaltered',null,null,null);
    end
  end
end^
/*-----------------------------------------------------------------------------------------------*/
create trigger P_TBI$TRegInq for P_TRegInq active before insert position 0
as
begin
  new.ExtAcc = Upper(new.ExtAcc);
end^
/*-----------------------------------------------------------------------------------------------*/
set term ; ^
/*-----------------------------------------------------------------------------------------------*/
/*
To register outgoing (Self) requests.
*/
create table P_TRegAim(
  NodeId            TNodeId,
  RT                TCount,
  primary key       (NodeId));
/*-----------------------------------------------------------------------------------------------*/
set term ^ ;
/*-----------------------------------------------------------------------------------------------*/
create trigger P_TBI$TRegAim for P_TRegAim active before insert position 0
as
begin
  new.RT = Gen_Id(P_G$RTT,0);
end^
/*-----------------------------------------------------------------------------------------------*/
create trigger P_TAD$TRegAim for P_TRegAim active after delete position 0
as
begin
  if ((select count(*) from P_TRegAim) = 0) then execute procedure P_Unaltered;
end^
/*-----------------------------------------------------------------------------------------------*/
alter procedure P_ClearRegAim
as
  declare RLL TCount;
begin
  select RLLinger from P_TParams into :RLL;
  if (RLL > 0) then
  begin
    RLL = Gen_Id(P_G$RTT,0) - RLL;
    delete from P_TRegAim where RT < :RLL;
  end
end^
/*-----------------------------------------------------------------------------------------------*/
/*
"all or nothing" approach:
*/
alter procedure P_ResetRegAim(Acceptor TBoolean)
as
begin
  if ((select count(*) from P_TRegAim) = 0) then
  begin
    insert into P_TRegAim(NodeId) select NodeId from P_NodeList(3,:Acceptor);

    when any do
      execute procedure P_LogErr(-23,sqlcode,gdscode,sqlstate,'P_ResetRegAim',null,null,null);
  end
end^

/*
alter procedure P_ResetRegAim(Acceptor TBoolean)
as
  declare NodeId TNodeId;
begin
  if ((select count(*) from P_TRegAim) = 0) then
    for select
        NodeId
      from
        P_NodeList(3,:Acceptor)
      into
        :NodeId
    do
      begin
        insert into P_TRegAim(NodeId) values(:NodeId);

        when any do
          execute procedure P_LogErr(-23,sqlcode,gdscode,sqlstate,'P_ResetRegAim',null,null,null);
      end
end^
*/
/*-----------------------------------------------------------------------------------------------*/
create procedure P_SweepRegAim(NodeId TNodeId)
as
begin
  delete from P_TRegAim where NodeId = :NodeId;
  when any do
    execute procedure P_LogErr(-20,sqlcode,gdscode,sqlstate,'P_SweepRegAim',NodeId,'Error',null);
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_FixReg
as
  declare flag TBoolean;

  declare NodeId TNodeId;
  declare Alias TNdAlias;
  declare Status TNdStatus;
  declare Acceptor TBoolean;
  declare IpMaskLen TUInt;
  declare IP TIPV6str;
  declare APort TPort;
  declare APath TPath;
  declare ExtAcc TUserName;
  declare ExtPWD TPWD;
  declare EditTime TTimeMark;
  declare LoadSig TSig;
  declare PubKey TKey;
begin
  if ((select Result from P_BegFixReg) = 1) then
  begin
    for select
        NodeId,
        Alias,
        Status,
        Acceptor,
        IpMaskLen,
        IP,
        APort,
        APath,
        ExtAcc,
        ExtPWD,
        EditTime,
        LoadSig,
        PubKey
      from
        P_TRegInq
      into
        :NodeId,
        :Alias,
        :Status,
        :Acceptor,
        :IpMaskLen,
        :IP,
        :APort,
        :APath,
        :ExtAcc,
        :ExtPWD,
        :EditTime,
        :LoadSig,
        :PubKey
    do
      begin
        update P_TNodeLog /* To prevent overwriting */
          set
            Alias = :Alias,
            Status = :Status,
            Acceptor = :Acceptor,
            IpMaskLen = :IpMaskLen,
            IP = :IP,
            APort = :APort,
            APath = :APath,
            ExtAcc = :ExtAcc,
            ExtPWD = :ExtPWD,
            EditTime = :EditTime,
            LoadSig = :LoadSig,
            PubKey = :PubKey
          where NodeId = :NodeId
            and (Alias <> :Alias
              or Status <> :Status
              or Acceptor <> :Acceptor
              or IpMaskLen <> :IpMaskLen
              or IP <> :IP
              or APort <> :APort
              or APath <> :APath
              or ExtAcc <> :ExtAcc
              or ExtPWD <> :ExtPWD
              or EditTime <> :EditTime
              or LoadSig <> :LoadSig
              or PubKey <> :PubKey);

        if (exists (select 1 from P_TNode where NodeId = :NodeId))
        then
          update P_TNode
            set
              Alias = :Alias,
              Status = :Status,
              Acceptor = :Acceptor,
              IpMaskLen = :IpMaskLen,
              IP = :IP,
              APort = :APort,
              APath = :APath,
              ExtAcc = :ExtAcc,
              ExtPWD = :ExtPWD,
              EditTime = :EditTime,
              LoadSig = :LoadSig,
              PubKey = :PubKey
            where NodeId = :NodeId
              and (Alias <> :Alias
                or Status <> :Status
                or Acceptor <> :Acceptor
                or IpMaskLen <> :IpMaskLen
                or IP <> :IP
                or APort <> :APort
                or APath <> :APath
                or ExtAcc <> :ExtAcc
                or ExtPWD <> :ExtPWD
                or EditTime <> :EditTime
                or LoadSig <> :LoadSig
                or PubKey <> :PubKey);
        else
          insert into
            P_TNode(
              NodeId,
              Alias,
              Status,
              Acceptor,
              IpMaskLen,
              IP,
              APort,
              APath,
              ExtAcc,
              ExtPWD,
              EditTime,
              LoadSig,
              PubKey)
            values(
              :NodeId,
              :Alias,
              :Status,
              :Acceptor,
              :IpMaskLen,
              :IP,
              :APort,
              :APath,
              :ExtAcc,
              :ExtPWD,
              :EditTime,
              :LoadSig,
              :PubKey);
      end

    delete from P_TRegInq;
    flag = 1;
    execute procedure P_EndFixReg;
    when any do
    begin
      if (flag = 0) then execute procedure P_EndFixReg;
      execute procedure P_LogErr(-22,sqlcode,gdscode,sqlstate,'P_FixReg',null,null,null);
    end
  end
end^
/*-----------------------------------------------------------------------------------------------*/
set term ; ^
/*-----------------------------------------------------------------------------------------------*/
create view P_RegInq as select * from P_TRegInq;
create view P_RegAim as select * from P_TRegAim;
/*-----------------------------------------------------------------------------------------------*/
grant all on P_TParams to procedure P_Unaltered;
grant execute on procedure P_BegAlt to procedure P_Unaltered;
grant execute on procedure P_EndAlt to procedure P_Unaltered;
grant execute on procedure P_LogErr to procedure P_Unaltered;

grant select on P_TRegAim to trigger P_TAD$TRegAim;
grant execute on procedure P_Unaltered to trigger P_TAD$TRegAim;

grant all on P_TRegAim to procedure P_ClearRegAim;
grant select on P_TParams to procedure P_ClearRegAim;

grant all on P_TRegAim to procedure P_ResetRegAim;
grant execute on procedure P_LogErr to procedure P_ResetRegAim;
grant execute on procedure P_NodeList to procedure P_ResetRegAim;

grant all on P_TNode to procedure P_FixReg;
grant all on P_TRegInq to procedure P_FixReg;
grant all on P_TNodeLog to procedure P_FixReg;
grant execute on procedure P_LogErr to procedure P_FixReg;
grant execute on procedure P_BegFixReg to procedure P_FixReg;
grant execute on procedure P_EndFixReg to procedure P_FixReg;

grant all on P_TRegAim to procedure P_SweepRegAim;
grant execute on procedure P_LogErr to procedure P_SweepRegAim;
/*-----------------------------------------------------------------------------------------------*/

