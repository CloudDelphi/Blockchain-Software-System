#!/bin/bash
# ======================================================================== #
# RelayMail: build_app.sh Version: 0.1.1.3                                 #
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
prm="./build.conf"
go_sql="${s_dir}/../tmp/app_tmp.sql"
log="${s_dir}/../tmp/app_log.txt"

cd "$s_dir"

if [ -r "$prm" ]
    then
        source "$prm"
        
        if [ -f "$log" ]
            then
                rm "$log"
        fi
        
        echo "SET SQL DIALECT 3;" > "$go_sql"
        echo "SET NAMES ${charset};" >> "$go_sql"
        echo "SET AUTODDL ON;" >> "$go_sql"
        echo "CONNECT '${ip}/${ip_port}:${db_path}${db_file}';" >> "$go_sql"
        echo "input ${pr_path}/sql/make_app.sql;" >> "$go_sql"
        echo -n "input ${pr_path}/sql/drop_constr.sql;" >> "$go_sql"
        
        cd ../../sql
        
        "$util_path$util_isql" -u sysdba -p "$password" -e -b -q -i "$go_sql" -m -o "$log"
        
        echo -n "Build time $SECONDS seconds." >> "$log"
        
    else
        echo "Could not find file $prm"
        
fi
