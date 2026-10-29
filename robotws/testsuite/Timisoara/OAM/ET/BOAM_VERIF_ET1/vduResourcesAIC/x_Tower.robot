*** Settings ***
Documentation    author: Wang Lijuan
...              contact: lijuan.1.wang@nokia-sbell.com

Library           OperatingSystem


#*** Variables ***

*** Keywords ***

Start neSim
    [Arguments]     ${ne_type}=du
       ...           ${enable_firewall}=no
    #   ...           ${user_ini_path}=${EMPTY}
       ...           ${server_ip}=${CU_FRONTHAUL_IP}
       ...           ${client_IP}=${x_Tower_IP}
       ...           ${alias}=default
    [Documentation]  Start vDU Simulator or eNB Simualtor
    ...    author: lijuan.1.wang@nokia-sbell.com
    ...    modified by:        <12-4-2021>, <lijuwang>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    |  ne_type | Yes | select the ne to start, can be du/eNB, default: du  |
    ...    |  server_ip | Yes |  server(cu) f1-c sctp ip-address |
    ...    |  client_IP | Yes | client(vdu) f1-c sctp ip-address, default: host ip  |
    ...    |  enable_firewall | No |  If to enable cu acl rule to open more sctp ports,no/yes, no in default|
    ...    |  user_ini_path | No |  user_config.ini absolute path,empty in default.Not used.|
    ...    *RETURN VALUE*
    ...    Example:  | Connect To UTE and inter x-tower path|
    ...    | Start neSim / ne_type=du / server_ip=${CU_FRONTHAUL_IP} / client_IP=${x_Tower_IP} / alias=${alias}/

    ${start_cmd}=  set variable   ./x_tower_client_CLI
    ${ne_type_option}=  run keyword if   '${ne_type}'=='du'  set variable   -t duSimMain -s ${server_ip} -c ${client_IP} -a start
    ...   ELSE IF   '${ne_type}'=='eNB'   set variable   -t x2SimMain -s ${server_ip} -c ${client_IP} -a start
    ...   ELSE    Fail   The NE type is not correct.

    ${enable_firewall}=  Convert to Lower case    ${enable_firewall}
    ${enable_firewall_option}=  run keyword if   '${enable_firewall}'=='${EMPTY}'   set variable  -f no
    ...   ELSE   set variable   -f ${enable_firewall}
    ${cmd}=  set variable  ${start_cmd} ${ne_type_option} ${enable_firewall_option}
    log to console   ${cmd}
    issh.execute   command= > nohup.out    alias=${alias}
    ${out}   issh.execute   command= ${cmd}   check_result=False  alias=${alias}
    log to console   ${out}
    sleep  10s
    wait until keyword succeeds    2 min  10s  _neSim Should Be Started From neSim Log   ${ne_type}  alias=${alias}

_neSim Should Be Started From neSim Log
    [Arguments]    ${ne_type}=du  ${alias}=default

    ${log_filter}=  run keyword if   '${ne_type}'=='du'   set variable  f1Setup is successfully
    ...   ELSE IF   '${ne_type}'=='eNB'   set variable   Receive message: ENDCX2SetupResponse
    ...   ELSE   Return From Keyword
    ${out}  issh.execute   command=cat nohup.out| grep '${log_filter}'    alias=${alias}
    Should contain   ${out}   ${log_filter}    Start neSim failed

Stop neSim
    [Arguments]     ${ne_type}=du
    #   ...           ${user_ini_path}=${EMPTY}
       ...           ${server_ip}=${CU_FRONTHAUL_IP}
       ...           ${client_IP}=${x_Tower_IP}
       ...           ${alias}=default
    [Documentation]  Stop vDU Simulator or eNB Simualtor
    ...    author: lijuan.1.wang@nokia-sbell.com
    ...    modified by:        <12-4-2021>, <lijuwang>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    |  ne_type | Yes | select the ne to start.default: du  |
    ...    |  server_ip | Yes |  server(cu) f1-c sctp ip-address |
    ...    |  client_IP | Yes | client(vdu) f1-c sctp ip-address, default: host ip  |
    ...    *RETURN VALUE*
    ...    Example:  | Connect To UTE and inter x-tower path|
    ...    | Stop neSim / ne_type=du / server_ip=${CU_FRONTHAUL_IP} / client_IP=${x_Tower_IP} / alias=${alias}/
    ${start_cmd}=  set variable   ./x_tower_client_CLI
    ${ne_type_option}=  run keyword if   '${ne_type}'=='du'  set variable   -t duSimMain -s ${server_ip} -c ${client_IP} -a exit
    ...   ELSE IF   '${ne_type}'=='eNB'   set variable   -t x2SimMain -s ${server_ip} -c ${client_IP} -a exit
    ...   ELSE    Fail   The NE type is not correct.
    ${cmd}=  set variable  ${start_cmd} ${ne_type_option}
    log to console   ${cmd}
    ${out}   issh.execute   command= ${cmd}   check_result=False   alias=${alias}
    sleep  2s
    ${enter}    Evaluate    chr(int(\r))
    ${out}   issh.Execute_Bare   command=${enter}    alias=${alias}


CU Get F1C and X2C IPv6 Address
    [Arguments]
    [Documentation]    Get VCU F1C and X2C Ipv6 Address
    ...    *AUTHOR* lijuan.1.wang@nokia-sbell.com
    ...    modified by:        <12-4-2021>, <lijuwang>, <initial created>
    ...    *RETURN VALUE*  f1c_ip, x2c_ip
    ...    Example
    ...   | ${CU_F1_C_IP} | ${CU_X2_C_IP} | CU Get F1C and X2C IPv6 Address |
    ${alias_cpif}   get unique id
    CU SSH To CPIF    alias=${alias_cpif}
    ${f1c_out}  issh.Execute  ifconfig fronthaul   alias=${alias_cpif}
    ${x2c_out}  issh.Execute  ifconfig x2   alias=${alias_cpif}
    ${f1c_ip}  ${f1c_mask}  Parse Ipv6 Address From Ifconfig    content=${f1c_out}
    ${x2c_ip}  ${x2c_mask}  Parse Ipv6 Address From Ifconfig    content=${x2c_out}
    [Return]  ${f1c_ip}   ${x2c_ip}

CU Get F1C and X2C IPv4 Address
    [Arguments]
    [Documentation]    Get VCU F1C and X2C Ipv4 Address
    ...    *AUTHOR* lijuan.1.wang@nokia-sbell.com
    ...    *RETURN VALUE*  f1c_ip, x2c_ip
    ...    Example
    ...   | ${CU_F1_C_IP} | ${CU_X2_C_IP} | CU Get F1C and X2C IPv4 Address |
    ${alias_cpif}   get unique id
    CU SSH To CPIF    alias=${alias_cpif}
    ${f1c_out}  issh.Execute  ifconfig fronthaul   alias=${alias_cpif}
    ${x2c_out}  issh.Execute  ifconfig x2   alias=${alias_cpif}
    ${f1c_ip}  ${f1c_mask}  ${broadcast}  Parse Ipv4 Address From Ifconfig    content=${f1c_out}
    ${x2c_ip}  ${x2c_mask}  ${broadcast}  Parse Ipv4 Address From Ifconfig    content=${x2c_out}
    [Return]  ${f1c_ip}   ${x2c_ip}

Check If vCU SCF Exist
    [Arguments]    ${x_Tower_Path}
    [Documentation]  Check if vCU SCF file exist in x_tower
    ...    author: lijuan.1.wang@nokia-sbell.com
    ...    modified by:        <12-4-2021>, <lijuwang>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    |  x_Tower_Path | Yes | The path of tool x_tower  |
    ...    *RETURN VALUE*
    ...    Example:  | Connect To UTE and inter x-tower path|
    ...    | Check If vCU SCF Exist  / ${x_Tower_Path}/
    ${alias}   Set Variable   scf
    Set test variable   ${alias}
    Connect To UTE Locally   alias=${alias}
    issh.execute   command=cd ${x_Tower_Path}  alias=${alias}
    ${out}  issh.execute   command=cat user_input.ini | grep "cu_SCF_File_Path="    alias=${alias}
    ${matches}   split string  ${out}  \r
    ${matches}   split string  ${matches[0]}  =
    ${default_SCF_Path}   OperatingSystem.Join Path  ${x_Tower_Path}  cu_scf
    run keyword if   '${matches[-1]}'=='NA'   _Check Default SCF    ${default_SCF_Path}
    ...   ELSE    file should exist   ${matches[-1]}

_Check Default SCF
  [Arguments]    ${path}
  ${out}   list_files_in_directory  ${path}
  ${xml_list}=   create list
  FOR  ${file}  IN   @{out}
     ${name}  ${ext}  split extension   ${file}
     run keyword if   '${ext}'=='xml'   append_to_list   ${xml_list}  ${file}
  END
  ${length}  Get Length    ${xml_list}
  Should be true   ${length}==1    The xml file in default path ${path}is not exist or not unique

Check If eNB Configuration File Exist
    [Arguments]    ${x_Tower_Path}
    [Documentation]  Check if eNB configuration file exist in x_tower
    ...    author: lijuan.1.wang@nokia-sbell.com
    ...    modified by:        <12-4-2021>, <lijuwang>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    |  x_Tower_Path | Yes | The path of tool x_tower  |
    ...    *RETURN VALUE*
    ...    Example:  | Connect To UTE and inter x-tower path|
    ...    | Check If eNB Configuration File Exist  / ${x_Tower_Path}/
    ${eNB_Cfg_file_name}   OperatingSystem.Join Path  ${x_Tower_Path}  x2ap   enbCfg  eNBNetworkPlan.csv
    OperatingSystem.File Should Exist   ${eNB_Cfg_file_name}









