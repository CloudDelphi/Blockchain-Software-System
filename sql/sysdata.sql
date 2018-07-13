/* ======================================================================== */
/* PeopleRelay: sysdata.sql Version: 0.4.3.6                                */
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
insert into P_TACL(Kind,IpCheck,Name,APWD) values(3,1,'SYSDBA','-');
update or insert into P_TACL(Kind,Name,APWD) values(3,(select Result from SYS_DBOwner),'-')
  matching(Name);
/*-----------------------------------------------------------------------------------------------*/
-- Vote
/*-----------------------------------------------------------------------------------------------*/
insert into P_TRepKind(RecId,Name) values(0,'Node List replication');
insert into P_TRepKind(RecId,Name) values(1,'Chain replication');
insert into P_TRepKind(RecId,Name) values(2,'Meltig Pot replication');
insert into P_TRepKind(RecId,Name) values(3,'Node registration');
insert into P_TRepKind(RecId,Name) values(4,'Check Block');
insert into P_TRepKind(RecId,Name) values(5,'Find Block');
insert into P_TRepKind(RecId,Name) values(6,'Get Discrepancy');

insert into P_TNodeKind(RepKind,Acceptor,Name) values(0,0,'Ordinary');
insert into P_TNodeKind(RepKind,Acceptor,Name) values(1,0,'Ordinary');
insert into P_TNodeKind(RepKind,Acceptor,Name) values(2,0,'Ordinary');
insert into P_TNodeKind(RepKind,Acceptor,Name) values(3,0,'Ordinary');
insert into P_TNodeKind(RepKind,Acceptor,Name) values(4,0,'Ordinary');
insert into P_TNodeKind(RepKind,Acceptor,Name) values(5,0,'Ordinary');
insert into P_TNodeKind(RepKind,Acceptor,Name) values(6,0,'Ordinary');

insert into P_TNodeKind(RepKind,Acceptor,Name) values(0,1,'Acceptor');
insert into P_TNodeKind(RepKind,Acceptor,Name) values(1,1,'Acceptor');
insert into P_TNodeKind(RepKind,Acceptor,Name) values(2,1,'Acceptor');
insert into P_TNodeKind(RepKind,Acceptor,Name) values(3,1,'Acceptor');
insert into P_TNodeKind(RepKind,Acceptor,Name) values(4,1,'Acceptor');
insert into P_TNodeKind(RepKind,Acceptor,Name) values(5,1,'Acceptor');
insert into P_TNodeKind(RepKind,Acceptor,Name) values(6,1,'Acceptor');
/*-----------------------------------------------------------------------------------------------*/
insert into P_TQuorum(RepKind,Acceptor,MinCount,MaxCount,Quorum,Assent) values(0,0,0,3,'N','Q');
insert into P_TQuorum(RepKind,Acceptor,MinCount,MaxCount,Quorum,Assent) values(0,0,3,5,'N','Q');
insert into P_TQuorum(RepKind,Acceptor,MinCount,MaxCount,Quorum,Assent) values(0,0,5,10,'N','Q'); /* 100% */
insert into P_TQuorum(RepKind,Acceptor,MinCount,MaxCount,Quorum,Assent) values(0,0,10,100,'N * 71 / 100','Q'); /* 71% */
insert into P_TQuorum(RepKind,Acceptor,MinCount,MaxCount,Quorum,Assent) values(0,0,100,1000,'N * 11 / 100','Q');
insert into P_TQuorum(RepKind,Acceptor,MinCount,MaxCount,Quorum,Assent) values(0,0,1000,1000000,'N * 5.1 / 100','Q');

insert into P_TQuorum(RepKind,Acceptor,MinCount,MaxCount,Quorum,Assent) values(0,1,0,3,'N','Q');
insert into P_TQuorum(RepKind,Acceptor,MinCount,MaxCount,Quorum,Assent) values(0,1,3,5,'N','Q');
insert into P_TQuorum(RepKind,Acceptor,MinCount,MaxCount,Quorum,Assent) values(0,1,5,10,'N','Q');
insert into P_TQuorum(RepKind,Acceptor,MinCount,MaxCount,Quorum,Assent) values(0,1,10,100,'N * 71 / 100','Q');
insert into P_TQuorum(RepKind,Acceptor,MinCount,MaxCount,Quorum,Assent) values(0,1,100,1000,'N * 11 / 100','Q');
insert into P_TQuorum(RepKind,Acceptor,MinCount,MaxCount,Quorum,Assent) values(0,1,1000,1000000,'N * 5.1 / 100','Q');
/*---------------------*/
insert into P_TQuorum(RepKind,Acceptor,MinCount,MaxCount,Quorum,Assent) values(1,0,0,3,'N','Q');
insert into P_TQuorum(RepKind,Acceptor,MinCount,MaxCount,Quorum,Assent) values(1,0,3,5,'N','Q');
insert into P_TQuorum(RepKind,Acceptor,MinCount,MaxCount,Quorum,Assent) values(1,0,5,10,'N','Q');
insert into P_TQuorum(RepKind,Acceptor,MinCount,MaxCount,Quorum,Assent) values(1,0,10,100,'N * 71 / 100','Q');
insert into P_TQuorum(RepKind,Acceptor,MinCount,MaxCount,Quorum,Assent) values(1,0,100,1000,'N * 11 / 100','Q');
insert into P_TQuorum(RepKind,Acceptor,MinCount,MaxCount,Quorum,Assent) values(1,0,1000,1000000,'N * 5.1 / 100','Q');

insert into P_TQuorum(RepKind,Acceptor,MinCount,MaxCount,Quorum,Assent) values(1,1,0,3,'N','Q');
insert into P_TQuorum(RepKind,Acceptor,MinCount,MaxCount,Quorum,Assent) values(1,1,3,5,'N','Q');
insert into P_TQuorum(RepKind,Acceptor,MinCount,MaxCount,Quorum,Assent) values(1,1,5,10,'N','Q');
insert into P_TQuorum(RepKind,Acceptor,MinCount,MaxCount,Quorum,Assent) values(1,1,10,100,'N * 71 / 100','Q');
insert into P_TQuorum(RepKind,Acceptor,MinCount,MaxCount,Quorum,Assent) values(1,1,100,1000,'N * 11 / 100','Q');
insert into P_TQuorum(RepKind,Acceptor,MinCount,MaxCount,Quorum,Assent) values(1,1,1000,1000000,'N * 5.1 / 100','Q');
/*---------------------*/
insert into P_TQuorum(RepKind,Acceptor,MinCount,MaxCount,Quorum,Assent) values(2,0,0,1000000,'0','0');
insert into P_TQuorum(RepKind,Acceptor,MinCount,MaxCount,Quorum,Assent) values(2,1,0,1000000,'N','Q');
/*---------------------*/
insert into P_TQuorum(RepKind,Acceptor,MinCount,MaxCount,Quorum,Assent) values(3,0,0,3,'N','Q');
insert into P_TQuorum(RepKind,Acceptor,MinCount,MaxCount,Quorum,Assent) values(3,0,3,5,'N','Q');
insert into P_TQuorum(RepKind,Acceptor,MinCount,MaxCount,Quorum,Assent) values(3,0,5,10,'N','Q');
insert into P_TQuorum(RepKind,Acceptor,MinCount,MaxCount,Quorum,Assent) values(3,0,10,100,'N * 71 / 100','Q');
insert into P_TQuorum(RepKind,Acceptor,MinCount,MaxCount,Quorum,Assent) values(3,0,100,1000,'N * 11 / 100','Q');
insert into P_TQuorum(RepKind,Acceptor,MinCount,MaxCount,Quorum,Assent) values(3,0,1000,1000000,'N * 5.1 / 100','Q');

insert into P_TQuorum(RepKind,Acceptor,MinCount,MaxCount,Quorum,Assent) values(3,1,0,3,'N','Q');
insert into P_TQuorum(RepKind,Acceptor,MinCount,MaxCount,Quorum,Assent) values(3,1,3,5,'N','Q');
insert into P_TQuorum(RepKind,Acceptor,MinCount,MaxCount,Quorum,Assent) values(3,1,5,10,'N','Q');
insert into P_TQuorum(RepKind,Acceptor,MinCount,MaxCount,Quorum,Assent) values(3,1,10,100,'N * 71 / 100','Q');
insert into P_TQuorum(RepKind,Acceptor,MinCount,MaxCount,Quorum,Assent) values(3,1,100,1000,'N * 11 / 100','Q');
insert into P_TQuorum(RepKind,Acceptor,MinCount,MaxCount,Quorum,Assent) values(3,1,1000,1000000,'N * 5.1 / 100','Q');
/*---------------------*/
insert into P_TQuorum(RepKind,Acceptor,MinCount,MaxCount,Quorum,Assent) values(4,0,0,3,'N','Q');
insert into P_TQuorum(RepKind,Acceptor,MinCount,MaxCount,Quorum,Assent) values(4,0,3,5,'N','Q');
insert into P_TQuorum(RepKind,Acceptor,MinCount,MaxCount,Quorum,Assent) values(4,0,5,10,'N','Q');
insert into P_TQuorum(RepKind,Acceptor,MinCount,MaxCount,Quorum,Assent) values(4,0,10,100,'N * 71 / 100','Q');
insert into P_TQuorum(RepKind,Acceptor,MinCount,MaxCount,Quorum,Assent) values(4,0,100,1000,'N * 11 / 100','Q');
insert into P_TQuorum(RepKind,Acceptor,MinCount,MaxCount,Quorum,Assent) values(4,0,1000,1000000,'N * 5.1 / 100','Q');

insert into P_TQuorum(RepKind,Acceptor,MinCount,MaxCount,Quorum,Assent) values(4,1,0,3,'N','Q');
insert into P_TQuorum(RepKind,Acceptor,MinCount,MaxCount,Quorum,Assent) values(4,1,3,5,'N','Q');
insert into P_TQuorum(RepKind,Acceptor,MinCount,MaxCount,Quorum,Assent) values(4,1,5,10,'N','Q');
insert into P_TQuorum(RepKind,Acceptor,MinCount,MaxCount,Quorum,Assent) values(4,1,10,100,'N * 71 / 100','Q');
insert into P_TQuorum(RepKind,Acceptor,MinCount,MaxCount,Quorum,Assent) values(4,1,100,1000,'N * 11 / 100','Q');
insert into P_TQuorum(RepKind,Acceptor,MinCount,MaxCount,Quorum,Assent) values(4,1,1000,1000000,'N * 5.1 / 100','Q');
/*---------------------*/
insert into P_TQuorum(RepKind,Acceptor,MinCount,MaxCount,Quorum,Assent) values(5,0,0,3,'N','Q');
insert into P_TQuorum(RepKind,Acceptor,MinCount,MaxCount,Quorum,Assent) values(5,0,3,5,'N','Q');
insert into P_TQuorum(RepKind,Acceptor,MinCount,MaxCount,Quorum,Assent) values(5,0,5,10,'N','Q');
insert into P_TQuorum(RepKind,Acceptor,MinCount,MaxCount,Quorum,Assent) values(5,0,10,100,'N * 71 / 100','Q');
insert into P_TQuorum(RepKind,Acceptor,MinCount,MaxCount,Quorum,Assent) values(5,0,100,1000,'N * 11 / 100','Q');
insert into P_TQuorum(RepKind,Acceptor,MinCount,MaxCount,Quorum,Assent) values(5,0,1000,1000000,'N * 5.1 / 100','Q');

insert into P_TQuorum(RepKind,Acceptor,MinCount,MaxCount,Quorum,Assent) values(5,1,0,3,'N','Q');
insert into P_TQuorum(RepKind,Acceptor,MinCount,MaxCount,Quorum,Assent) values(5,1,3,5,'N','Q');
insert into P_TQuorum(RepKind,Acceptor,MinCount,MaxCount,Quorum,Assent) values(5,1,5,10,'N','Q');
insert into P_TQuorum(RepKind,Acceptor,MinCount,MaxCount,Quorum,Assent) values(5,1,10,100,'N * 71 / 100','Q');
insert into P_TQuorum(RepKind,Acceptor,MinCount,MaxCount,Quorum,Assent) values(5,1,100,1000,'N * 11 / 100','Q');
insert into P_TQuorum(RepKind,Acceptor,MinCount,MaxCount,Quorum,Assent) values(5,1,1000,1000000,'N * 5.1 / 100','Q');
/*---------------------*/
insert into P_TQuorum(RepKind,Acceptor,MinCount,MaxCount,Quorum,Assent) values(6,0,0,3,'N','Q');
insert into P_TQuorum(RepKind,Acceptor,MinCount,MaxCount,Quorum,Assent) values(6,0,3,5,'N','Q');
insert into P_TQuorum(RepKind,Acceptor,MinCount,MaxCount,Quorum,Assent) values(6,0,5,10,'N','Q');
insert into P_TQuorum(RepKind,Acceptor,MinCount,MaxCount,Quorum,Assent) values(6,0,10,100,'N * 71 / 100','Q');
insert into P_TQuorum(RepKind,Acceptor,MinCount,MaxCount,Quorum,Assent) values(6,0,100,1000,'N * 11 / 100','Q');
insert into P_TQuorum(RepKind,Acceptor,MinCount,MaxCount,Quorum,Assent) values(6,0,1000,1000000,'N * 5.1 / 100','Q');

insert into P_TQuorum(RepKind,Acceptor,MinCount,MaxCount,Quorum,Assent) values(6,1,0,3,'N','Q');
insert into P_TQuorum(RepKind,Acceptor,MinCount,MaxCount,Quorum,Assent) values(6,1,3,5,'N','Q');
insert into P_TQuorum(RepKind,Acceptor,MinCount,MaxCount,Quorum,Assent) values(6,1,5,10,'N','Q');
insert into P_TQuorum(RepKind,Acceptor,MinCount,MaxCount,Quorum,Assent) values(6,1,10,100,'N * 71 / 100','Q');
insert into P_TQuorum(RepKind,Acceptor,MinCount,MaxCount,Quorum,Assent) values(6,1,100,1000,'N * 11 / 100','Q');
insert into P_TQuorum(RepKind,Acceptor,MinCount,MaxCount,Quorum,Assent) values(6,1,1000,1000000,'N * 5.1 / 100','Q');

commit work;
/*-----------------------------------------------------------------------------------------------*/

