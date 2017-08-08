/* ************************************************************************ */
/* PeopleRelay: sysdata.sql Version: see version.sql                        */
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
insert into P_TACL(Kind,Name,APWD) values(3,'SYSDBA','-');
update or insert into P_TACL(Kind,Name) values(3,(select Result from SYS_DBOwner))
  matching(Name);
/*-----------------------------------------------------------------------------------------------*/
insert into P_TParams default values;
commit work;
/*-----------------------------------------------------------------------------------------------*/
-- Vote
insert into P_TQuorum(RepKind,Acceptor,Pct,MinNdCnt,MaxNdCnt) values(0,0,100,0,3);
insert into P_TQuorum(RepKind,Acceptor,Pct,MinNdCnt,MaxNdCnt) values(0,0,100,3,5);
insert into P_TQuorum(RepKind,Acceptor,Pct,MinNdCnt,MaxNdCnt) values(0,0,100,5,10);
insert into P_TQuorum(RepKind,Acceptor,Pct,MinNdCnt,MaxNdCnt) values(0,0,71,10,100);
insert into P_TQuorum(RepKind,Acceptor,Pct,MinNdCnt,MaxNdCnt) values(0,0,11,100,1000);
insert into P_TQuorum(RepKind,Acceptor,Pct,MinNdCnt,MaxNdCnt) values(0,0,5.1,1000,1000000);
insert into P_TQuorum(RepKind,Acceptor,Pct,MinNdCnt,MaxNdCnt) values(0,1,100,0,3);
insert into P_TQuorum(RepKind,Acceptor,Pct,MinNdCnt,MaxNdCnt) values(0,1,100,3,5);
insert into P_TQuorum(RepKind,Acceptor,Pct,MinNdCnt,MaxNdCnt) values(0,1,100,5,10);
insert into P_TQuorum(RepKind,Acceptor,Pct,MinNdCnt,MaxNdCnt) values(0,1,71,10,100);
insert into P_TQuorum(RepKind,Acceptor,Pct,MinNdCnt,MaxNdCnt) values(0,1,11,100,1000);
insert into P_TQuorum(RepKind,Acceptor,Pct,MinNdCnt,MaxNdCnt) values(0,1,5.1,1000,1000000);
/*---------------------*/
insert into P_TQuorum(RepKind,Acceptor,Pct,MinNdCnt,MaxNdCnt) values(1,0,100,0,3);
insert into P_TQuorum(RepKind,Acceptor,Pct,MinNdCnt,MaxNdCnt) values(1,0,100,3,5);
insert into P_TQuorum(RepKind,Acceptor,Pct,MinNdCnt,MaxNdCnt) values(1,0,100,5,10);
insert into P_TQuorum(RepKind,Acceptor,Pct,MinNdCnt,MaxNdCnt) values(1,0,71,10,100);
insert into P_TQuorum(RepKind,Acceptor,Pct,MinNdCnt,MaxNdCnt) values(1,0,11,100,1000);
insert into P_TQuorum(RepKind,Acceptor,Pct,MinNdCnt,MaxNdCnt) values(1,0,5.1,1000,1000000);

insert into P_TQuorum(RepKind,Acceptor,Pct,MinNdCnt,MaxNdCnt) values(1,1,100,0,3);
insert into P_TQuorum(RepKind,Acceptor,Pct,MinNdCnt,MaxNdCnt) values(1,1,100,3,5);
insert into P_TQuorum(RepKind,Acceptor,Pct,MinNdCnt,MaxNdCnt) values(1,1,100,5,10);
insert into P_TQuorum(RepKind,Acceptor,Pct,MinNdCnt,MaxNdCnt) values(1,1,71,10,100);
insert into P_TQuorum(RepKind,Acceptor,Pct,MinNdCnt,MaxNdCnt) values(1,1,11,100,1000);
insert into P_TQuorum(RepKind,Acceptor,Pct,MinNdCnt,MaxNdCnt) values(1,1,5.1,1000,1000000);
/*---------------------*/

insert into P_TQuorum(RepKind,Acceptor,Pct,MinNdCnt,MaxNdCnt) values(2,0,0,0,1000000);
insert into P_TQuorum(RepKind,Acceptor,Pct,MinNdCnt,MaxNdCnt) values(2,1,100,0,1000000);

/*---------------------*/
insert into P_TQuorum(RepKind,Acceptor,Pct,MinNdCnt,MaxNdCnt) values(3,0,100,0,3);
insert into P_TQuorum(RepKind,Acceptor,Pct,MinNdCnt,MaxNdCnt) values(3,0,100,3,5);
insert into P_TQuorum(RepKind,Acceptor,Pct,MinNdCnt,MaxNdCnt) values(3,0,100,5,10);
insert into P_TQuorum(RepKind,Acceptor,Pct,MinNdCnt,MaxNdCnt) values(3,0,71,10,100);
insert into P_TQuorum(RepKind,Acceptor,Pct,MinNdCnt,MaxNdCnt) values(3,0,11,100,1000);
insert into P_TQuorum(RepKind,Acceptor,Pct,MinNdCnt,MaxNdCnt) values(3,0,5.1,1000,1000000);

insert into P_TQuorum(RepKind,Acceptor,Pct,MinNdCnt,MaxNdCnt) values(3,1,100,0,3);
insert into P_TQuorum(RepKind,Acceptor,Pct,MinNdCnt,MaxNdCnt) values(3,1,100,3,5);
insert into P_TQuorum(RepKind,Acceptor,Pct,MinNdCnt,MaxNdCnt) values(3,1,100,5,10);
insert into P_TQuorum(RepKind,Acceptor,Pct,MinNdCnt,MaxNdCnt) values(3,1,71,10,100);
insert into P_TQuorum(RepKind,Acceptor,Pct,MinNdCnt,MaxNdCnt) values(3,1,11,100,1000);
insert into P_TQuorum(RepKind,Acceptor,Pct,MinNdCnt,MaxNdCnt) values(3,1,5.1,1000,1000000);
/*---------------------*/

insert into P_TQuorum(RepKind,Acceptor,Pct,MinNdCnt,MaxNdCnt) values(4,0,100,0,3);
insert into P_TQuorum(RepKind,Acceptor,Pct,MinNdCnt,MaxNdCnt) values(4,0,100,3,5);
insert into P_TQuorum(RepKind,Acceptor,Pct,MinNdCnt,MaxNdCnt) values(4,0,100,5,10);
insert into P_TQuorum(RepKind,Acceptor,Pct,MinNdCnt,MaxNdCnt) values(4,0,71,10,100);
insert into P_TQuorum(RepKind,Acceptor,Pct,MinNdCnt,MaxNdCnt) values(4,0,11,100,1000);
insert into P_TQuorum(RepKind,Acceptor,Pct,MinNdCnt,MaxNdCnt) values(4,0,5.1,1000,1000000);
insert into P_TQuorum(RepKind,Acceptor,Pct,MinNdCnt,MaxNdCnt) values(4,1,100,0,3);
insert into P_TQuorum(RepKind,Acceptor,Pct,MinNdCnt,MaxNdCnt) values(4,1,100,3,5);
insert into P_TQuorum(RepKind,Acceptor,Pct,MinNdCnt,MaxNdCnt) values(4,1,100,5,10);
insert into P_TQuorum(RepKind,Acceptor,Pct,MinNdCnt,MaxNdCnt) values(4,1,71,10,100);
insert into P_TQuorum(RepKind,Acceptor,Pct,MinNdCnt,MaxNdCnt) values(4,1,11,100,1000);
insert into P_TQuorum(RepKind,Acceptor,Pct,MinNdCnt,MaxNdCnt) values(4,1,5.1,1000,1000000);
/*---------------------*/
-- Quorum
insert into P_TQuorum(RepKind,Acceptor,IsQuorum,Pct,MinNdCnt,MaxNdCnt) values(0,0,1,100,0,3);
insert into P_TQuorum(RepKind,Acceptor,IsQuorum,Pct,MinNdCnt,MaxNdCnt) values(0,0,1,100,3,5);
insert into P_TQuorum(RepKind,Acceptor,IsQuorum,Pct,MinNdCnt,MaxNdCnt) values(0,0,1,100,5,10);
insert into P_TQuorum(RepKind,Acceptor,IsQuorum,Pct,MinNdCnt,MaxNdCnt) values(0,0,1,71,10,100);
insert into P_TQuorum(RepKind,Acceptor,IsQuorum,Pct,MinNdCnt,MaxNdCnt) values(0,0,1,11,100,1000);
insert into P_TQuorum(RepKind,Acceptor,IsQuorum,Pct,MinNdCnt,MaxNdCnt) values(0,0,1,5.1,1000,1000000);
insert into P_TQuorum(RepKind,Acceptor,IsQuorum,Pct,MinNdCnt,MaxNdCnt) values(0,1,1,100,0,3);
insert into P_TQuorum(RepKind,Acceptor,IsQuorum,Pct,MinNdCnt,MaxNdCnt) values(0,1,1,100,3,5);
insert into P_TQuorum(RepKind,Acceptor,IsQuorum,Pct,MinNdCnt,MaxNdCnt) values(0,1,1,100,5,10);
insert into P_TQuorum(RepKind,Acceptor,IsQuorum,Pct,MinNdCnt,MaxNdCnt) values(0,1,1,71,10,100);
insert into P_TQuorum(RepKind,Acceptor,IsQuorum,Pct,MinNdCnt,MaxNdCnt) values(0,1,1,11,100,1000);
insert into P_TQuorum(RepKind,Acceptor,IsQuorum,Pct,MinNdCnt,MaxNdCnt) values(0,1,1,5.1,1000,1000000);
/*---------------------*/
insert into P_TQuorum(RepKind,Acceptor,IsQuorum,Pct,MinNdCnt,MaxNdCnt) values(1,0,1,100,0,3);
insert into P_TQuorum(RepKind,Acceptor,IsQuorum,Pct,MinNdCnt,MaxNdCnt) values(1,0,1,100,3,5);
insert into P_TQuorum(RepKind,Acceptor,IsQuorum,Pct,MinNdCnt,MaxNdCnt) values(1,0,1,100,5,10);
insert into P_TQuorum(RepKind,Acceptor,IsQuorum,Pct,MinNdCnt,MaxNdCnt) values(1,0,1,71,10,100);
insert into P_TQuorum(RepKind,Acceptor,IsQuorum,Pct,MinNdCnt,MaxNdCnt) values(1,0,1,11,100,1000);
insert into P_TQuorum(RepKind,Acceptor,IsQuorum,Pct,MinNdCnt,MaxNdCnt) values(1,0,1,5.1,1000,1000000);

insert into P_TQuorum(RepKind,Acceptor,IsQuorum,Pct,MinNdCnt,MaxNdCnt) values(1,1,1,100,0,1000000);

/*---------------------*/
insert into P_TQuorum(RepKind,Acceptor,IsQuorum,Pct,MinNdCnt,MaxNdCnt) values(3,0,1,100,0,3);
insert into P_TQuorum(RepKind,Acceptor,IsQuorum,Pct,MinNdCnt,MaxNdCnt) values(3,0,1,100,3,5);
insert into P_TQuorum(RepKind,Acceptor,IsQuorum,Pct,MinNdCnt,MaxNdCnt) values(3,0,1,100,5,10);
insert into P_TQuorum(RepKind,Acceptor,IsQuorum,Pct,MinNdCnt,MaxNdCnt) values(3,0,1,71,10,100);
insert into P_TQuorum(RepKind,Acceptor,IsQuorum,Pct,MinNdCnt,MaxNdCnt) values(3,0,1,11,100,1000);
insert into P_TQuorum(RepKind,Acceptor,IsQuorum,Pct,MinNdCnt,MaxNdCnt) values(3,0,1,5.1,1000,1000000);

insert into P_TQuorum(RepKind,Acceptor,IsQuorum,Pct,MinNdCnt,MaxNdCnt) values(3,1,1,100,0,3);
insert into P_TQuorum(RepKind,Acceptor,IsQuorum,Pct,MinNdCnt,MaxNdCnt) values(3,1,1,100,3,5);
insert into P_TQuorum(RepKind,Acceptor,IsQuorum,Pct,MinNdCnt,MaxNdCnt) values(3,1,1,100,5,10);
insert into P_TQuorum(RepKind,Acceptor,IsQuorum,Pct,MinNdCnt,MaxNdCnt) values(3,1,1,71,10,100);
insert into P_TQuorum(RepKind,Acceptor,IsQuorum,Pct,MinNdCnt,MaxNdCnt) values(3,1,1,11,100,1000);
insert into P_TQuorum(RepKind,Acceptor,IsQuorum,Pct,MinNdCnt,MaxNdCnt) values(3,1,1,5.1,1000,1000000);

/*---------------------*/
--insert into P_TQuorum(RepKind,Acceptor,IsQuorum,Pct,MinNdCnt,MaxNdCnt) values(2,0,1,0,0,1000000);
insert into P_TQuorum(RepKind,Acceptor,IsQuorum,Pct,MinNdCnt,MaxNdCnt) values(2,1,1,100,0,1000000);
/*---------------------*/

commit work;
/*-----------------------------------------------------------------------------------------------*/

