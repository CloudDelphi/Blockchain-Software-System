/* ======================================================================== */
/* PeopleRelay: quorum.sql Version: 0.4.1.8                                 */
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
create generator P_G$Quorum;
/*-----------------------------------------------------------------------------------------------*/
create table P_TRepKind(
  RecId             TRepKind,
  Name              TSysStr64 not null unique,
  Comment           TComment,
  CreatedBy         TOperName,
  ChangedBy         TOperName,
  CreatedAt         TTimeMark,
  ChangedAt         TTimeMark,
  primary key       (RecId));
/*-----------------------------------------------------------------------------------------------*/
set term ^ ;
/*-----------------------------------------------------------------------------------------------*/
create trigger P_TBI$TRepKind for P_TRepKind active before insert position 0
as
begin
  new.CreatedBy = CURRENT_USER;
  new.CreatedAt = UTCTime();
  new.ChangedBy = new.CreatedBy;
  new.ChangedAt = new.CreatedAt;
end^
/*-----------------------------------------------------------------------------------------------*/
create trigger P_TBU$TRepKind for P_TRepKind active before update position 0
as
begin
  new.RecId = old.RecId;
  new.CreatedBy = old.CreatedBy;
  new.CreatedAt = old.CreatedAt;
  new.ChangedBy = CURRENT_USER;
  new.ChangedAt = UTCTime();
end^
/*-----------------------------------------------------------------------------------------------*/
set term ; ^
/*-----------------------------------------------------------------------------------------------*/
create table P_TNodeKind(
  RepKind           TRepKind,
  Acceptor          TBoolean,
  Name              TSysStr64 not null,
  Comment           TComment,
  CreatedBy         TOperName,
  ChangedBy         TOperName,
  CreatedAt         TTimeMark,
  ChangedAt         TTimeMark,
  primary key       (RepKind,Acceptor),
  foreign key       (RepKind) references P_TRepKind(RecId));
/*-----------------------------------------------------------------------------------------------*/
create unique index P_XU$NdKnd on P_TNodeKind(RepKind,Acceptor,Name);
/*-----------------------------------------------------------------------------------------------*/
set term ^ ;
/*-----------------------------------------------------------------------------------------------*/
create trigger P_TBI$TNodeKind for P_TNodeKind active before insert position 0
as
begin
  new.CreatedBy = CURRENT_USER;
  new.CreatedAt = UTCTime();
  new.ChangedBy = new.CreatedBy;
  new.ChangedAt = new.CreatedAt;
end^
/*-----------------------------------------------------------------------------------------------*/
create trigger P_TBU$TNodeKind for P_TNodeKind active before update position 0
as
begin
  new.RepKind = old.RepKind;
  new.Acceptor = old.Acceptor;
  new.CreatedBy = old.CreatedBy;
  new.CreatedAt = old.CreatedAt;
  new.ChangedBy = CURRENT_USER;
  new.ChangedAt = UTCTime();
end^
/*-----------------------------------------------------------------------------------------------*/
set term ; ^
/*-----------------------------------------------------------------------------------------------*/
create table P_TQuorum(
  RecId             TRid,
  RepKind           TRepKind,
  Acceptor          TBoolean,
  Fortran           TBoolean, /* if = 1 do formula translation */
  Pct               TPercent,
  MinNdCnt          TCount,
  MaxNdCnt          TCount,
  Formula           TFormula, /* N is Node count, eg: N / 2 + 1 */
  Comment           TComment,
  CreatedBy         TOperName,
  ChangedBy         TOperName,
  CreatedAt         TTimeMark,
  ChangedAt         TTimeMark,
  primary key       (RecId),
  foreign key       (RepKind,Acceptor) references P_TNodeKind(RepKind,Acceptor));
/*-----------------------------------------------------------------------------------------------*/
create unique index P_XU$Quorum on P_TQuorum(RepKind,Acceptor,Pct,MinNdCnt,MaxNdCnt);
/*-----------------------------------------------------------------------------------------------*/
set term ^ ;
/*-----------------------------------------------------------------------------------------------*/
/*
To set to the Uppercase and do the formula test before do insert or update.
*/
create procedure P_TestFormula(Formula TFormula)
returns
  (Result TFormula)
as
  declare r BigInt;
  declare Expr TExpression;
begin
  if (Formula is null or Formula = '')
  then
    Result = null;
  else
    begin
      Result = Upper(Formula);
      Expr = Replace(Result,'N',1234567890);
      execute procedure Math_Interpret(Expr) returning_values r;
    end
end^
/*-----------------------------------------------------------------------------------------------*/
create trigger P_TBI$TQuorum for P_TQuorum active before insert position 0
as
begin
  if (new.RecId is null) then new.RecId = gen_id(P_G$Quorum,1);
  execute procedure P_TestFormula(new.Formula) returning_values new.Formula;
  new.CreatedBy = CURRENT_USER;
  new.CreatedAt = UTCTime();
  new.ChangedBy = new.CreatedBy;
  new.ChangedAt = new.CreatedAt;
end^
/*-----------------------------------------------------------------------------------------------*/
create trigger P_TBU$TQuorum for P_TQuorum active before update position 0
as
begin
  execute procedure P_TestFormula(new.Formula) returning_values new.Formula;

  new.RecId = old.RecId;
  new.CreatedBy = old.CreatedBy;
  new.CreatedAt = old.CreatedAt;
  new.ChangedBy = CURRENT_USER;
  new.ChangedAt = UTCTime();
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_VoteLim(
  RepKind TRepKind,
  Acceptor TTrilean)
returns
  (Result TCount)
as
  declare N TCount;
  declare ac TBoolean;
  declare bb TBoolean;
  declare Pct TPercent;
  declare Fortran TBoolean;
  declare Formula TFormula;
  declare Expr TExpression;
begin

  select Acceptor,Broadband from P_TParams into :ac,:bb;
  if (bb = 1 and RepKind <> 2)
  then
    Acceptor = 0;
  else
    if (Acceptor = -1) then Acceptor = ac;

  select
      count(*)
    from
      P_TNode
    where Enabled = 1
      and Status >= 0
      and (:Acceptor = 0 or Acceptor = 1)
    into :N;

  begin
    if (N <= 0)
    then
      Result = 0;
    else
      begin
        select first 1
            Pct,
            Fortran,
            Formula
          from
            P_TQuorum
          where RepKind = :RepKind
            and Acceptor = :Acceptor
            and MinNdCnt < :N
            and MaxNdCnt >= :N
          into
            :Pct,
            :Fortran,
            :Formula;

        if (Pct > 0 and Fortran = 0)
        then
          Result = Round((Pct * N) / 100.000,0);
        else
          if (Formula is null)
          then
            Result = N / 2 + 1;
          else
            begin
              Expr = Replace(Formula,'N',N);
              execute procedure Math_Interpret(Expr) returning_values Result;
              if (Result > N)
              then
                Result = N;
              else
                if (Result < 0)  then Result = 1;
            end
      end

    when any do
    begin
      if (N <= 0)
      then
        Result = 0;
      else
        Result = N / 2 + 1;
      execute procedure P_LogErr(-30,sqlcode,gdscode,sqlstate,'P_VoteLim','Error',null,null);
    end
  end
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_QuorumAcc(RepKind TRepKind)
returns
  (Result TCount)
as
begin
  execute procedure P_VoteLim(RepKind,1) returning_values Result;
end^
/*-----------------------------------------------------------------------------------------------*/
create procedure P_QuorumTot(RepKind TRepKind)
returns
  (Result TCount)
as
begin
  execute procedure P_VoteLim(RepKind,0) returning_values Result;
end^
/*-----------------------------------------------------------------------------------------------*/
set term ; ^
/*-----------------------------------------------------------------------------------------------*/
create view P_RepKind as select * from P_TRepKind;
create view P_NodeKind as select * from P_TNodeKind;
create view P_Quorum as select * from P_TQuorum;
/*-----------------------------------------------------------------------------------------------*/
grant execute on procedure P_TestFormula to trigger P_TBI$TQuorum;
grant execute on procedure P_TestFormula to trigger P_TBU$TQuorum;
grant execute on procedure Math_Interpret to procedure P_TestFormula;

grant select on P_TNode to procedure P_VoteLim;
grant select on P_TParams to procedure P_VoteLim;
grant select on P_TQuorum to procedure P_VoteLim;
grant execute on procedure P_LogErr to procedure P_VoteLim;
grant execute on procedure Math_Interpret to procedure P_VoteLim;

grant execute on procedure P_VoteLim to procedure P_QuorumAcc;
grant execute on procedure P_VoteLim to procedure P_QuorumTot;
/*-----------------------------------------------------------------------------------------------*/

