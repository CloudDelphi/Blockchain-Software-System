/* ======================================================================== */
/* PeopleRelay: repair.sql Version: 0.4.1.8                                 */
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
create global temporary table P_TChainTest(
  Id                TRid,
  Val               TCount not null,
  primary key       (Id)
) on commit delete rows;
/*-----------------------------------------------------------------------------------------------*/
set term ^ ;
/*-----------------------------------------------------------------------------------------------*/
create procedure P_Dehorn(BlockNo TRef,Cause TInt32)
as
  declare tmp TCount;
begin
  if ((select Result from P_BegDehorn) = 1) then
  begin
    execute procedure P_LogMsg(301,BlockNo,tmp,Cause,'P_Dehorn',null,'Start',null);
    BlockNo = BlockNo - (select DehornPower from P_TParams);
    if (BlockNo < 1) then BlockNo = 1;

    delete from P_TChain
      where BlockNo >= :BlockNo
      order by BlockNo desc; --we can delete only last record

    tmp = row_count;
    delete from P_TBackLog;
    execute procedure P_LogMsg(302,BlockNo,tmp,Cause,'P_Dehorn',null,'Finish',null);
    execute procedure P_EndDehorn;
    when any do
    begin
      execute procedure P_EndDehorn;
      execute procedure P_LogErr(-300,sqlcode,gdscode,sqlstate,'P_Dehorn',BlockNo,null,null);
    end
  end
end^
/*-----------------------------------------------------------------------------------------------*/
create or alter procedure P_DiscrMedian
returns
  (Result TCount)
as
  declare CntVal Integer;
  declare RowsFrom Integer;
  declare RowsTo Integer;
begin
  select count(*) from P_TChainTest into :CntVal;
  RowsFrom = ((:CntVal - 1) / 2) + 1;
  RowsTo   = (:CntVal / 2) + 1;
  with tmp(Val) as
      (select
          Val
        from
          P_TChainTest
        order by Val
        rows :RowsFrom to :RowsTo)
    select
      sum(Val) / (:RowsTo - :RowsFrom + 1)
    from
      tmp
    into
      :Result;
end^
/*-----------------------------------------------------------------------------------------------*/
/*
execute procedure P_Discrepancy;
select * from P_TChainTest;
*/
create or alter procedure P_Discrepancy
returns
  (Size TCount,
   Delta TCount)
as
  declare Id TCount;
  declare BlockNo TRef;
  declare rslt TCheck;
  declare TM0 TTimeMark;
  declare flag TBoolean;
  declare VoteLim TCount;
  declare TMSlice TInt32;
  declare Acceptor TBoolean;
  declare Checksum TIntHash;
  declare SelfHash TChHash;
  declare NodeId TNodeId;
  declare PeerIP TIPV6str;
  declare PeerPort TPort;
  declare PWD TPWD;
  declare Usr TUserName;
  declare DB TFullPath;
begin
  TM0 = CURRENT_TIMESTAMP;
  delete from P_TChainTest;
  select Acceptor,TimeSlice from P_TParams into :Acceptor,:TMSlice;
  execute procedure P_ChainSize returning_values :Size;
  if (Size > 0) then
  begin
    execute procedure P_VoteLim(6,Acceptor) returning_values VoteLim;

    for select
        NodeId,
        Ip,
        APort,
        ExtAcc,
        ExtPWD,
        FullPath
      from
        P_NodeList(6,:Acceptor)
      into
        :NodeId,
        :PeerIp,
        :PeerPort,
        :Usr,
        :PWD,
        :DB
    do
      begin
        if ((select Result from P_IsOnline(:PeerIP,:PeerPort)) = 1) then
        begin
          flag = 0;
          for select
              BlockNo,
              Checksum,
              SelfHash
            from
              P_TChain
            where
              BlockNo > 0
            order by
              BlockNo desc
            into
              :BlockNo,
              :Checksum,
              :SelfHash
          do
            begin
              execute procedure P_DoCheckBlock(BlockNo,Checksum,SelfHash,DB,Usr,PWD,NodeId) returning_values rslt;
              if (rslt < 0)   /* Error */
              then
                begin
                  flag = 1;
                  Leave;
                end
              else
                if (rslt in (1,2)) then /* 2 - Peer Chain too short, we consider there is no discrepancy. */
                begin
                  flag = 1;
                  Id = Id + 1;
                  insert into P_TChainTest(Id,Val) values(:Id,(:Size - :BlockNo));
                  Leave;
                end

              when any do
              begin
                execute procedure P_LogErr(-301,sqlcode,gdscode,sqlstate,'P_Discrepancy',NodeId,null,null);
                Delta = -1;
                Leave;
              end
            end
          if (flag = 0) then
          begin
            Id = Id + 1;
            insert into P_TChainTest(Id,Val) values(:Id,:Size); /* No one Block found at all - full discrepancy */
          end

          if (Id >= VoteLim) then Leave;

          if(TMSlice > 0
            and datediff(minute,TM0,cast('Now' as TimeStamp)) > TMSlice)
          then
            begin
              execute procedure P_LogErr(-302,Id,VoteLim,null,'P_Discrepancy',NodeId,'Long duration',null);
              Delta = -2;
              exit;
            end

          when any do
          begin
            execute procedure P_LogErr(-303,sqlcode,gdscode,sqlstate,'P_Discrepancy',NodeId,null,null);
            Delta = -3;            
          end
        end

        if(TMSlice > 0
          and datediff(minute,TM0,cast('Now' as TimeStamp)) > TMSlice)
        then
          begin
            execute procedure P_LogErr(-304,Id,VoteLim,null,'P_Discrepancy',NodeId,'Long duration',null);
            Delta = -4;
            exit;
          end
      end

    if (Id > 0 and Id >= VoteLim) then
      execute procedure P_DiscrMedian returning_values Delta;

  end

  when any do
  begin
    execute procedure P_LogErr(-305,sqlcode,gdscode,sqlstate,'P_Discrepancy',null,null,null);
    Delta = -5;
  end
end^
/*-----------------------------------------------------------------------------------------------*/
create or alter procedure P_Repair(Cause TInt32,ABlockNo TRid)
as
  declare BlockNo TRef;
  declare Size TCount;
  declare Delta TCount;
begin
  execute procedure P_LogMsg(401,0,0,null,'P_Repair',null,'Start',null);
  execute procedure P_Discrepancy returning_values Size,Delta;

  if (Size > 0) then
  begin
    BlockNo = 0;
    if (Delta > 0)
    then
      if (Size = Delta)
      then
        BlockNo = 1;
      else
        select first 1
            BlockNo
          from
            P_TChain
          where
            BlockNo <= (:Size - :Delta) /* Do not use strong "<", could have (:Size - :Delta) = 1 */
            /* P_Discrepancy may return an intermediate (median) value, not the BlockNo */
          order by
            BlockNo desc
          into :BlockNo;
    else
      if (Cause <> 0) then BlockNo = ABlockNo;

    if (BlockNo > 0) then execute procedure P_Dehorn(BlockNo,Cause);
  end
  execute procedure P_LogMsg(402,0,0,null,'P_Repair',null,'Finish',null);
end^
/*-----------------------------------------------------------------------------------------------*/
alter procedure P_ClearMeltingPot
as
  declare MPL TCount;
begin
  select (Gen_Id(P_G$RTT,0) - MPLinger) from P_TParams into :MPL;
  delete from P_TMeltingPot where State > 0 and RT < :MPL;
  when any do
    execute procedure P_LogErr(-34,sqlcode,gdscode,sqlstate,'P_ClearMeltingPot',null,'Error',null);
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

grant select on P_TChainTest to procedure P_DiscrMedian;

grant select on P_TChain to procedure P_Discrepancy;
grant select on P_TParams to procedure P_Discrepancy;
grant all on P_TChainTest to procedure P_Discrepancy;
grant execute on procedure P_LogErr to procedure P_Discrepancy;
grant execute on procedure P_VoteLim to procedure P_Discrepancy;
grant execute on procedure P_IsOnline to procedure P_Discrepancy;
grant execute on procedure P_NodeList to procedure P_Discrepancy;
grant execute on procedure P_ChainSize to procedure P_Discrepancy;
grant execute on procedure P_DiscrMedian to procedure P_Discrepancy;
grant execute on procedure P_DoCheckBlock to procedure P_Discrepancy;

grant select on P_TChain to procedure P_Repair;
grant execute on procedure P_LogMsg to procedure P_Repair;
grant execute on procedure P_Dehorn to procedure P_Repair;
grant execute on procedure P_Discrepancy to procedure P_Repair;

grant select on P_TParams to procedure P_ClearMeltingPot;
grant all on P_TMeltingPot to procedure P_ClearMeltingPot;
grant execute on procedure P_LogErr to procedure P_ClearMeltingPot;
/*-----------------------------------------------------------------------------------------------*/

