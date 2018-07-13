#!/bin/bash
# ======================================================================== #
# PeopleRelay: repack.sh Version: 0.4.3.6                                  #
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

cd "$s_dir"

if [ -r "$prm" ]
    then
        source "$prm"
        
        if [ -f "$db_path$db_file" ]
            then
                "$util_path$util_gbak" -b -USER SYSDBA -PAS "$password" "${ip}/${ip_port}:$db_path$db_file" "$db_path$db_file_bak"
                "$util_path$util_gbak" -REP -K -USER SYSDBA -PAS "$password" "$db_path$db_file_bak" "${ip}/${ip_port}:$db_path$db_file"
                
            else
                echo "Could not find file $db_path$db_file"
            
        fi
        
    else
        echo "Could not find file $prm"
        
fi
