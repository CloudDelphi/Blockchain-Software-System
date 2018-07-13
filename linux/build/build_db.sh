#!/bin/bash
# ======================================================================== #
# PeopleRelay: build_db.sh Version: 0.4.3.6                                #
#                                                                          #
# Copyright 2017-2018 Aleksei Ilin & Igor Ilin                             #
#                                                                          #
# Licensed under the Apache License, Version 2.0 (the "License");          #
# you may not use this file except in compliance with the License.         #
# You may obtain a copy of the License at                                  #
#                                                                          #
#     http://www.apache.org/licenses/LICENSE-2.0                           #
#                                                                          #
# Unless required by applicable law or agreed to in writing, software      #
# distributed under the License is distributed on an "AS IS" BASIS,        #
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. #
# See the License for the specific language governing permissions and      #
# limitations under the License.                                           #
# ======================================================================== #

s_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
go_sql="./create.sql"
log="${s_dir}/../tmp/db_log.txt"

if [ -z $1 ]
    then
        prm="./build.conf"
    else
        prm="$1"
fi

cd "$s_dir"

if [ -r "$prm" ]
    then
        source "$prm"
        
        if [ -f "$log" ]
            then
                rm "$log"
        fi
        
        cd ../../sql
        
        echo "SET SQL DIALECT 3;" > "$go_sql"
        echo "SET NAMES ${charset};" >> "$go_sql"
        echo "SET AUTODDL ON;" >> "$go_sql"
        echo "create database '${ip}/${ip_port}:${db_path}${db_file}' PAGE_SIZE 8192" >> "$go_sql"
        echo "USER 'SYSDBA' PASSWORD '${password}' DEFAULT CHARACTER SET ${charset};" >> "$go_sql"
        echo "create domain TComment as VarChar(64) COLLATE ${collate};" >> "$go_sql"
        echo "create domain TString16 as VarChar(16) COLLATE ${collate};" >> "$go_sql"
        echo "create domain TString32 as VarChar(32) COLLATE ${collate};" >> "$go_sql"
        echo "create domain TString64 as VarChar(64) COLLATE ${collate};" >> "$go_sql"
        echo "create domain TString128 as VarChar(128) COLLATE ${collate};" >> "$go_sql"
        echo "create domain TString512 as VarChar(512) COLLATE ${collate};" >> "$go_sql"
        echo -n "create domain TString4K as VarChar(4096) COLLATE ${collate};" >> "$go_sql"
        
        "$util_path$util_isql" -e -b -q -i "./_build.sql" -m -o "$log"
        
        echo -n "Build time $SECONDS seconds." >> "$log"
        
    else
        echo "Could not find file $prm"
        
fi
