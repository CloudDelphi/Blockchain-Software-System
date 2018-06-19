/* ======================================================================== */
/* PeopleRelay: stats.sql Version: 0.4.1.8                                  */
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
/*
select * from PS_Today;
*/
create or alter procedure PS_Today
returns
  (Val_1 DOUBLE PRECISION,
   Val_2 DOUBLE PRECISION,
   Param TSysStr64)
as
  declare cHour THour;
  declare tm TimeStamp;
  declare cDate TimeStamp;
begin
  tm = UTCTime();
  cDate = cast(tm as DATE);
  cHour = extract(HOUR from tm);

  Param = 'Chain: Size/Checksum';
  select first 1 BlockNo,Checksum from P_TChain order by BlockNo desc into :Val_1,:Val_2;
  suspend;

  Param = 'Node List: Size/Acceptors';
  select count(*) from P_TNode into :Val_1;
  select count(*) from P_TNode where Acceptor = 1 into :Val_2;
  suspend;

  Param = 'Chain Buffers: BackLog/MeltingPot';
  select count(*) from P_TBacklog into :Val_1;
  select count(*) from P_TMeltingPot into :Val_2;
  suspend;

  Param = 'Node Buffers: Incoming/OutGoing';
  select count(*) from P_TRegInq into :Val_1;
  select count(*) from P_TRegAim into :Val_2;
  suspend;

  Param = 'Dehorn: Today/Current hour';
  select count(*) from P_TLog where FDate = :cDate and MsgId = 302 into :Val_1;
  select count(*) from P_TLog where FDate = :cDate
    and MsgId = 302 and extract(HOUR from CreatedAt) = :cHour into :Val_2;
  suspend;

  Param = 'Errors: Today/Current hour';
  select count(*) from P_TLog where FDate = :cDate and IsError = 1 into :Val_1;
  select count(*) from P_TLog where FDate = :cDate
    and IsError = 1 and extract(HOUR from CreatedAt) = :cHour into :Val_2;
  suspend;

  Param = 'Sync: RTT/RTT-current hour';
  select count(*) from P_TLog where FDate = :cDate and MsgId = 701 into :Val_1;
  select count(*) from P_TLog where FDate = :cDate
    and MsgId = 701 and extract(HOUR from CreatedAt) = :cHour into :Val_2;
  suspend;

  Param = 'Client Connect: Today/Current hour';
  select count(*) from P_TDBLog where FDate = :cDate and Kind = 0 into :Val_1;
  select count(*) from P_TDBLog where FDate = :cDate
    and Kind = 0 and extract(HOUR from CreatedAt) = :cHour into :Val_2;
  suspend;

  Param = 'Viewer Connect: Today/Current hour';
  select count(*) from P_TDBLog where FDate = :cDate and Kind = 1 into :Val_1;
  select count(*) from P_TDBLog where FDate = :cDate
    and Kind = 1 and extract(HOUR from CreatedAt) = :cHour into :Val_2;
  suspend;

  Param = 'SyncBot Connect: Today/Current hour';
  select count(*) from P_TDBLog where FDate = :cDate and Kind = 2 into :Val_1;
  select count(*) from P_TDBLog where FDate = :cDate
    and Kind = 2 and extract(HOUR from CreatedAt) = :cHour into :Val_2;
  suspend;

  Param = 'Admin Connect: Today/Current hour';
  select count(*) from P_TDBLog where FDate = :cDate and Kind = 3 into :Val_1;
  select count(*) from P_TDBLog where FDate = :cDate
    and Kind = 3 and extract(HOUR from CreatedAt) = :cHour into :Val_2;
  suspend;

  Param = 'Guest Connect: Today/Current hour';
  select count(*) from P_TDBLog where FDate = :cDate and Kind = 4 into :Val_1;
  select count(*) from P_TDBLog where FDate = :cDate
    and Kind = 4 and extract(HOUR from CreatedAt) = :cHour into :Val_2;
  suspend;

end^

/*-----------------------------------------------------------------------------------------------*/
/*
select * from PS_Info;
*/
create or alter procedure PS_Info
returns
  (Sz_Dis_Chs TSysStr32,
   BL_MP_Sz TSysStr16,
   Nd_Log_Sz TSysStr16,   
   Inq_Aim_Sz TSysStr16,
   Err_Deh TSysStr16,
   Accepts TSysStr16)
as
  declare n_1 TCount;
  declare n_2 TCount;
  declare tmp Integer;
  declare BlockNo TCount;
  declare tm TimeStamp;
  declare cDate TimeStamp;
begin
  tm = UTCTime();
  cDate = cast(tm as DATE);

  execute procedure P_Discrepancy returning_values n_1,n_2;
  select first 1 BlockNo,Checksum from P_TChain order by BlockNo desc into :BlockNo,:n_1;
  Sz_Dis_Chs = BlockNo || '(' || n_2 || ')' || n_1;

  select count(*) from P_TBacklog into :n_1;
  select count(*) from P_TMeltingPot into :n_2;
  BL_MP_Sz = n_1 || '/' || n_2;

  select count(*) from P_TRegInq into :n_1;
  select count(*) from P_TRegAim into :n_2;
  Inq_Aim_Sz = n_1 || '/' || n_2;

  select count(*) from P_TLog where FDate = :cDate and IsError = 1 into :n_1;
  select count(*) from P_TLog where FDate = :cDate and MsgId = 302 into :n_2;
  Err_Deh = n_1 || '/' || n_2;

  select count(*) from P_TNode into :n_1;
  select count(*) from P_TNodeLog into :n_2;
  Nd_Log_Sz = n_1 || '/' || n_2;

  select count(*) from P_TNode where Acceptor = 1 into :n_2;
  if ((select Acceptor from P_TParams) = 1)
  then
    Accepts = 'A';
  else
    Accepts = 'R';
  Accepts = Accepts || '/A=' || n_2 || '/R=' || (n_1 - n_2);

  suspend;
end^
/*-----------------------------------------------------------------------------------------------*/
alter procedure P_NodeRating(RecId TRid, NodeId TNodeId)
returns
  (Result TRating)
as
  declare t1 TRating;
  declare t2 TRating;
  declare cDate TimeStamp;
begin
  cDate = UTCTime() - ((select RateRetro from P_TParams) / 1440.00000);

  select count(*) from P_TLog where FDate >= :cDate and MsgId = 702 into :t1;
  select count(*) from P_TLog
    where FDate >= :cDate and IsError = 1 and Obj = :NodeId into :t2;

  Result = t1 / (t2 + 1);
  suspend;
end^
/*-----------------------------------------------------------------------------------------------*/
set term ; ^
/*-----------------------------------------------------------------------------------------------*/
grant select on P_TLog to procedure PS_Today;
grant select on P_TNode to procedure PS_Today;
grant select on P_TDBLog to procedure PS_Today;
grant select on P_TChain to procedure PS_Today;

grant select on P_TLog to procedure PS_Info;
grant select on P_TNode to procedure PS_Info;
grant select on P_TChain to procedure PS_Info;
grant select on P_TRegInq to procedure PS_Info;
grant select on P_TRegAim to procedure PS_Info;
grant select on P_TParams to procedure PS_Info;
grant select on P_TNodeLog to procedure PS_Info;
grant select on P_TBacklog to procedure PS_Info;
grant select on P_TMeltingPot to procedure PS_Info;

grant select on P_TLog to procedure P_NodeRating;
grant select on P_TParams to procedure P_NodeRating;
/*-----------------------------------------------------------------------------------------------*/
