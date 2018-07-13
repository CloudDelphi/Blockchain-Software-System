/* ======================================================================== */
/* PeopleRelay: sys_sec.sql Version: 0.4.3.6                                */
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

insert into RDB$SECURITY_CLASSES(RDB$SECURITY_CLASS,RDB$ACL)
  values('DBA$1',
    cast(
    ASCII_CHAR(0x01) ||  /* Version 1*/
    ASCII_CHAR(0x01) ||  /* ACL_id_list */
    ASCII_CHAR(0x03) ||  /* id_person */
    ASCII_CHAR(0x06) ||  /* id_node */
    ASCII_CHAR(0x53) ||  /* S */
    ASCII_CHAR(0x59) ||  /* Y */
    ASCII_CHAR(0x53) ||  /* S */
    ASCII_CHAR(0x44) ||  /* D */
    ASCII_CHAR(0x42) ||  /* B */
    ASCII_CHAR(0x41) ||  /* A */
    ASCII_CHAR(0x00) ||
    ASCII_CHAR(0x02) ||  /* ACL_priv_list */
    ASCII_CHAR(0x06) ||  /* P priv_alter Alter object */
    ASCII_CHAR(0x01) ||  /* C priv_control */
    ASCII_CHAR(0x03) ||  /* D priv_drop */
    ASCII_CHAR(0x05) ||  /* W */
    ASCII_CHAR(0x04) ||  /* R */
    ASCII_CHAR(0x0B) ||  /* X */
    ASCII_CHAR(0x00) ||
    ASCII_CHAR(0x01) ||  /* id_group */
    ASCII_CHAR(0x00) ||
    ASCII_CHAR(0x02) ||  /* ACL_priv_list */
    ASCII_CHAR(0x05) ||  /* W */
    ASCII_CHAR(0x04) ||  /* R */
    ASCII_CHAR(0x0B) ||  /* X */
    ASCII_CHAR(0x00) ||
    ASCII_CHAR(0x00) as BLOB));
/*-----------------------------------------------------------------------------------------------*/
update rdb$database set rdb$security_class = 'DBA$1';
commit work;
/*-----------------------------------------------------------------------------------------------*/
