#!/bin/bash

read -p "path to runtime_sysinfo.zip: " path_to_runtime
read -p "path to logs: " path_to_logs
read -p "repository target path : " repository_target_path

if [ ! -d "$repository_target_path" ] || [ -z "$(ls -A $repository_target_path)" ]; then
  read -p "login: " login
  read -s -p "password: " password

  git clone "https://gerrit.ext.net.nokia.com/gerrit/MN/RPSW/CCS/ccs" -c http.extraheader="Authorization: Basic $(echo -n "$login:$password" | base64)" $repository_target_path/ccs
  git clone "https://gerrit.ext.net.nokia.com/gerrit/MN/RPSW/UPHWAPI/uphwapi" -c http.extraheader="Authorization: Basic $(echo -n "$login:$password" | base64)" $repository_target_path/uphwapi

  cp -r $repository_target_path/uphwapi/T_Tools/SC_UPHWAPI/Technical_Log_Decoder_Analyzer/common/tlda_common $repository_target_path/ccs/T_Tools/SC_CCS/Technical_Log_Decoder_Analyzer/common
fi

SYSINFOPARSER_CONF=verbose python3 $repository_target_path/ccs/T_Tools/SC_CCS/Technical_Log_Decoder_Analyzer/common/CCS_SysInfoParser.py --analyze $path_to_runtime --output $path_to_logs

if [ -d "$path_to_logs" ]; then
  echo "Operation done, file list: "
  find "$path_to_logs" -type f
fi
