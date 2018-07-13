/* ======================================================================== */
/* PeopleRelay: fields.sql Version: 0.4.3.6                                 */
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

/* Example; replace the filed list with app field list */
insert into P_TFields(FieldName,DataType,DefVal,Constr)
  values('Int_Field','Integer','0','not null');
insert into P_TFields(FieldName,DataType,DefVal,Constr)
  values('DT_Field','TimeStamp','CURRENT_TIMESTAMP','not null');
insert into P_TFields(FieldName,DataType,DefVal,Constr)
  values('Float_Field','Float', '0', 'not null');
insert into P_TFields(FieldName,DataType,DefVal,Constr)
  values('Str_Field','VarChar(42)',null,null);
insert into P_TFields(FieldName,DataType,DefVal,Constr)
  values('Memo_Field','BLOB SUB_TYPE TEXT',null,null);
