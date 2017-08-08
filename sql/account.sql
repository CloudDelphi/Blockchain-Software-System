/* ************************************************************************ */
/* PeopleRelay: account.sql Version: see version.sql                        */
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
create generator P_G$ACL;
create generator P_G$ACLIp;
/*-----------------------------------------------------------------------------------------------*/
create table P_TACL(
  RecId             TRid,
  Kind              TAccKind,
  LogAttach         TBoolean default 1,
  Suspended         TBoolean,
  Name              TUserName not null,
  APWD              TPWD,
  Comment           TComment,
  CreatedBy         TOperName,
  ChangedBy         TOperName,
  CreatedAt         TTimeMark,
  ChangedAt         TTimeMark,
  primary key       (RecId));
/*-----------------------------------------------------------------------------------------------*/
create unique index P_XU$ACL1 on P_TACL(Name);
create unique index P_XU$ACL2 on P_TACL(Name,Kind);
/*-----------------------------------------------------------------------------------------------*/
set term ^ ;
/*-----------------------------------------------------------------------------------------------*/
alter procedure P_NewSndAcc(AUser TSysStr31)
as
begin
  execute procedure SYS_GrantExec('P_AddBlock',AUser);
  execute procedure SYS_GrantExec('P_HasBlock',AUser);
  execute procedure SYS_GrantExec('P_FindBlock',AUser);
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_NewSyncAcc(AUser TSysStr31)
as
begin
  execute procedure SYS_GrantExec('P_Sync',AUser);
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_NewViewerAcc(AUser TSysStr31)
as
begin
  execute procedure SYS_GrantView('P_Chain',AUser);
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_CreateAcc(
  newKind TAccKind,
  oldKind SmallInt,  
  newName TUserName,
  oldName TUserName,
  newPWD TPWD)
as
begin
  if (newName is distinct from oldName
    or newKind is distinct from oldKind)
  then
    execute procedure SYS_DropAcc(oldName);
  if (newName <> 'SYSDBA'
    and (select Result from SYS_IsDBOwner(:newName)) = 0)
  then
    if (newKind = 0) -- Sender
    then
      begin
        execute procedure SYS_AltAcc(newName,newPWD);
        execute procedure P_NewSndAcc(newName);
      end
    else
      if (newKind = 1) -- Viewer
      then
        begin
          execute procedure SYS_AltAcc(newName,newPWD);
          execute procedure P_NewViewerAcc(newName);
        end
      else
        if (newKind = 2) -- SyncBot
        then
          begin
            execute procedure SYS_AltAcc(newName,newPWD);
            execute procedure P_NewSyncAcc(newName);
          end
        else
          if (newKind = 3) then -- Admin
            execute procedure SYS_AltAdmAcc(newName,newPWD);
end^
/*-----------------------------------------------------------------------------------------------*/
create trigger P_TBI$TACL for P_TACL active before insert position 0
as
  declare mpl TUInt;
begin
  if (new.Kind = 2
    and (exists (select 1 from P_TACL where Kind = 2)))
  then
    exception P_E$SyncBotAcc;
  new.Name = Upper(new.Name);
  new.CreatedBy = CURRENT_USER;
  new.CreatedAt = CURRENT_TIMESTAMP;
  new.ChangedBy = new.CreatedBy;
  new.ChangedAt = new.CreatedAt;
  select MinPWDLen from P_TParams into :mpl;
  if (mpl > 0) then
  begin
    if (new.APWD is null or char_length(new.APWD) < mpl) then exception P_E$ShortPWD;
    execute procedure P_CreateAcc(new.Kind,null,new.Name,null,new.APWD);
    new.APWD = null;
    when any do
    begin
      new.APWD = null;
      exception;
    end
  end
  if (new.RecId is null) then new.RecId = gen_id(P_G$ACL,1);  
end^
/*-----------------------------------------------------------------------------------------------*/
create trigger P_TBU$TACL for P_TACL active before update position 0
as
  declare mpl TUInt;
begin
  new.Name = Upper(new.Name);
  new.RecId = old.RecId;
  new.CreatedBy = old.CreatedBy;
  new.CreatedAt = old.CreatedAt;
  new.ChangedBy = CURRENT_USER;
  new.ChangedAt = CURRENT_TIMESTAMP;
  select MinPWDLen from P_TParams into :mpl;
  if (mpl > 0) then
  begin
    if (new.APWD is null or char_length(new.APWD) < mpl) then exception P_E$ShortPWD;
    execute procedure P_CreateAcc(new.Kind,old.Kind,new.Name,old.Name,new.APWD);
    new.APWD = null;
    when any do
    begin
      new.APWD = null;
      Exception;
    end
  end
end^
/*-----------------------------------------------------------------------------------------------*/
create trigger P_TAD$TACL for P_TACL active after delete position 0
as
begin
  execute procedure SYS_DropAcc(old.Name);
end^
/*-----------------------------------------------------------------------------------------------*/
set term ; ^
/*-----------------------------------------------------------------------------------------------*/
create table P_TACLIp(
  RecId             TRid,
  ACLId             TRid,
  IP                TIPV6str not null,
  Comment           TComment,
  CreatedBy         TOperName,
  ChangedBy         TOperName,
  CreatedAt         TTimeMark,
  ChangedAt         TTimeMark,
  primary key       (RecId),
  foreign key       (ACLId) references P_TACL(RecId)
    on update       CASCADE
    on delete       CASCADE);
/*-----------------------------------------------------------------------------------------------*/
create unique index P_XU$ACLIp on P_TACLIp(ACLId,Ip);
/*-----------------------------------------------------------------------------------------------*/
set term ^ ;
/*-----------------------------------------------------------------------------------------------*/
create trigger P_TBI$TACLIp for P_TACLIp active before insert position 0
as
begin
  if (new.RecId is null) then new.RecId = gen_id(P_G$ACLIp,1);
  new.IP = Upper(new.IP);
  new.CreatedBy = CURRENT_USER;
  new.CreatedAt = CURRENT_TIMESTAMP;
  new.ChangedBy = new.CreatedBy;
  new.ChangedAt = new.CreatedAt;
end^
/*-----------------------------------------------------------------------------------------------*/
create trigger P_TBU$TACLIp for P_TACLIp active before update position 0
as
begin
  new.RecId = old.RecId;
  new.IP = Upper(new.IP);
  new.CreatedBy = old.CreatedBy;
  new.CreatedAt = old.CreatedAt;
  new.ChangedBy = CURRENT_USER;
  new.ChangedAt = CURRENT_TIMESTAMP;
end^
/*-----------------------------------------------------------------------------------------------*/
create trigger P_TAI$TACL for P_TACL active after insert position 0
as
begin
  insert into P_TACLIp(ACLId,IP) values(new.RecId,'IPC');
  insert into P_TACLIp(ACLId,IP) values(new.RecId,'XNET');
  insert into P_TACLIp(ACLId,IP) values(new.RecId,'WNET');
  insert into P_TACLIp(ACLId,IP) values(new.RecId,'127.0.0.1');
  insert into P_TACLIp(ACLId,IP) values(new.RecId,'localhost');
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_IsIpValid
returns
  (Result TBoolean,
   LogAtch TBoolean)
as
  declare IP TIPV6str;
  declare Proto TProto;
begin
  select IP from P_TSesIP into :IP;
  select Result from SYS_Proto into :Proto;
  select
      1,
      U.LogAttach
    from
      P_TACL U
    where U.Name = CURRENT_USER
      and U.Suspended = 0
      and exists
        (select 1 from P_TACLIp I
          where I.ACLId = U.RecId
            and (I.IP = :IP
              or :IP like I.IP || '%'
              or I.IP = :Proto))
    into
      :Result,
      :LogAtch;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_IsSender
returns
  (Result TBoolean)
as
begin
  if ((select SndControl from P_TParams) = 0)
  then
    Result = 1;
  else
    select 1 from P_TACL where Name = CURRENT_USER and Kind = 0 into :Result;
  suspend;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_IsSyncBot
returns
  (Result TBoolean)
as
begin
  select 1 from P_TACL where Name = CURRENT_USER and Kind = 2 into :Result;
  suspend;
end^
/*-----------------------------------------------------------------------------------------------*/
set term ; ^
/*-----------------------------------------------------------------------------------------------*/
create view P_ACL as select * from P_TACL;
create view P_ACLIp as select * from P_TACLIp;
/*-----------------------------------------------------------------------------------------------*/
grant select on P_TACL to trigger P_TBI$TACL;
grant select on P_TParams to trigger P_TBI$TACL;

grant execute on procedure P_CreateAcc to trigger P_TBI$TACL;
grant select on P_TParams to trigger P_TBU$TACL;
grant execute on procedure P_CreateAcc to trigger P_TBU$TACL;

grant all on P_TACLIp to trigger P_TAI$TACL;
grant execute on procedure SYS_DropAcc to trigger P_TAD$TACL;

grant execute on procedure SYS_GrantExec to procedure P_NewSndAcc;
grant execute on procedure SYS_GrantExec to procedure P_NewSyncAcc;
grant execute on procedure SYS_GrantView to procedure P_NewViewerAcc;

grant execute on procedure SYS_AltAcc to procedure P_CreateAcc;
grant execute on procedure SYS_DropAcc to procedure P_CreateAcc;
grant execute on procedure P_NewSndAcc to procedure P_CreateAcc;
grant execute on procedure P_NewSyncAcc to procedure P_CreateAcc;
grant execute on procedure SYS_AltAdmAcc to procedure P_CreateAcc;
grant execute on procedure SYS_IsDBOwner to procedure P_CreateAcc;
grant execute on procedure P_NewViewerAcc to procedure P_CreateAcc;

grant select on P_TACL to procedure P_IsIpValid;
grant select on P_TACLIp to procedure P_IsIpValid;
grant execute on procedure SYS_Proto to procedure P_IsIpValid;

grant select on P_TACL to procedure P_IsSender;
grant select on P_TParams to procedure P_IsSender;

grant select on P_TACL to procedure P_IsSyncBot;
/*-----------------------------------------------------------------------------------------------*/

