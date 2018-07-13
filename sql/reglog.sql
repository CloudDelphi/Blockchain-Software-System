/* ======================================================================== */
/* PeopleRelay: reglog.sql Version: 0.4.3.6                                 */
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
  IP                TIPV6str,
  APort             TPort,
  APath             TPath,
  ExtAcc            TUserName,
  ExtPWD            TPWD,
  EditTime          TTimeMark,
  NodeSig           TSig,
  PubKey            TKey,
  primary key       (NodeId));
/*-----------------------------------------------------------------------------------------------*/
set term ^ ;
/*-----------------------------------------------------------------------------------------------*/
create trigger P_TBI$TRegInq for P_TRegInq active before insert position 0
as
begin
  new.ExtAcc = Upper(new.ExtAcc);
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_FixReg
as
  declare flag TBoolean;

  declare NodeId TNodeId;
  declare Alias TNdAlias;
  declare Status TNdStatus;
  declare Acceptor TBoolean;
  declare IP TIPV6str;
  declare APort TPort;
  declare APath TPath;
  declare ExtAcc TUserName;
  declare ExtPWD TPWD;
  declare EditTime TTimeMark;
  declare NodeSig TSig;
  declare PubKey TKey;
begin
  if ((select Result from P_BegFixReg) = 1) then
  begin
    for select
        NodeId,
        Alias,
        Status,
        Acceptor,
        IP,
        APort,
        APath,
        ExtAcc,
        ExtPWD,
        EditTime,
        NodeSig,
        PubKey
      from
        P_TRegInq
      into
        :NodeId,
        :Alias,
        :Status,
        :Acceptor,
        :IP,
        :APort,
        :APath,
        :ExtAcc,
        :ExtPWD,
        :EditTime,
        :NodeSig,
        :PubKey
    do
      begin
        update P_TPeerLog /* To prevent overwriting */
          set
            Alias = :Alias,
            Status = :Status,
            Acceptor = :Acceptor,
            IP = :IP,
            APort = :APort,
            APath = :APath,
            ExtAcc = :ExtAcc,
            ExtPWD = :ExtPWD,
            EditTime = :EditTime,
            NodeSig = :NodeSig,
            PubKey = :PubKey
          where NodeId = :NodeId
            and (Alias <> :Alias
              or Status <> :Status
              or Acceptor <> :Acceptor
              or IP <> :IP
              or APort <> :APort
              or APath <> :APath
              or ExtAcc <> :ExtAcc
              or ExtPWD <> :ExtPWD
              or EditTime <> :EditTime
              or NodeSig <> :NodeSig
              or PubKey <> :PubKey);

        if (exists (select 1 from P_TPeer where NodeId = :NodeId))
        then
          update P_TPeer
            set
              Alias = :Alias,
              Status = :Status,
              Acceptor = :Acceptor,
              IP = :IP,
              APort = :APort,
              APath = :APath,
              ExtAcc = :ExtAcc,
              ExtPWD = :ExtPWD,
              EditTime = :EditTime,
              NodeSig = :NodeSig,
              PubKey = :PubKey
            where NodeId = :NodeId
              and (Alias <> :Alias
                or Status <> :Status
                or Acceptor <> :Acceptor
                or IP <> :IP
                or APort <> :APort
                or APath <> :APath
                or ExtAcc <> :ExtAcc
                or ExtPWD <> :ExtPWD
                or EditTime <> :EditTime
                or NodeSig <> :NodeSig
                or PubKey <> :PubKey);
        else
          insert into
            P_TPeer(
              NodeId,
              Alias,
              Status,
              Acceptor,
              IP,
              APort,
              APath,
              ExtAcc,
              ExtPWD,
              EditTime,
              NodeSig,
              PubKey)
            values(
              :NodeId,
              :Alias,
              :Status,
              :Acceptor,
              :IP,
              :APort,
              :APath,
              :ExtAcc,
              :ExtPWD,
              :EditTime,
              :NodeSig,
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
/*-----------------------------------------------------------------------------------------------*/
grant all on P_TPeer to procedure P_FixReg;
grant all on P_TRegInq to procedure P_FixReg;
grant all on P_TPeerLog to procedure P_FixReg;
grant execute on procedure P_LogErr to procedure P_FixReg;
grant execute on procedure P_BegFixReg to procedure P_FixReg;
grant execute on procedure P_EndFixReg to procedure P_FixReg;
/*-----------------------------------------------------------------------------------------------*/

