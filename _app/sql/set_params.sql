/* ======================================================================== */
/* PeopleRelay: set_params.sql Version: 0.4.3.6                             */
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
  update P_TTransponder
    set
      Prime = 'C2629B08-31A5-4616-A845-3BAA5377007B',
      Cluster = 'D68BEB82-0DA1-4058-A04D-E96946236FD4';
*/
/*-----------------------------------------------------------------------------------------------*/
/*
  update P_TParams 
  set
    Acceptor = 1,
    SndControl = 0,
    PowerOnReset = 3;
*/
/*-----------------------------------------------------------------------------------------------*/
commit work;
/*-----------------------------------------------------------------------------------------------*/