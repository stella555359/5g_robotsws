*** Settings ***
Documentation   Author: jingmin.he@nokia-sbell.com
Library   taf.transport.ssh   WITH NAME   csn
Resource   ../common/taf_coam.robot
Resource   ../common/gnb.robot
Library   Collections
Library    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/UUF/Scripts/UUF_common.py
Library   testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/libraries/switch_to_other_node_ru.py
Variables    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/libraries/global_vars.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG7/siso_common.robot


*** Variables ***
${switch_node_ru_script}    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/libraries/switch_to_other_node_ru.py
${ru_index}   0
@{cmd_list}

*** Keywords ***
Get gNB detected RUs
    [Arguments]   ${is_dual_core}=${False}   ${login_ip}=${asik_addr}
    csn.Connect to
    ...   hostname=${login_ip}   username=${asik_username}   password=${asik_password}   alias=gNB
    ${gNB_connected_RUs}   Get Detected RU list from DU   connection=gNB
    ${gnb_left}    Run Keyword If   ${is_dual_core}   If GNB In Left Side    connection=gNB
    ${hostname}   Set Variable If   ${gnb_left}   fct-4a   fct-0a
    Run Keyword If   ${is_dual_core}   csn.Connect to   hostname=${hostname}   username=${asik_username}
    ...   password=${asik_password}   proxy=gNB   alias=dual
    ${dual_connected}   Run Keyword If   ${is_dual_core}   Get Detected RU list from DU   connection=dual
    ...   ELSE   Create Dictionary
    Run Keyword If   ${dual_connected}   Set to Dictionary   ${gNB_connected_RUs}   &{dual_connected}
    [Return]   ${gNB_connected_RUs}
    [Teardown]   Run Keywords
    ...   Run Keyword And Ignore Error   Run Keyword If   ${is_dual_core}   csn.Disconnect   connection=dual   AND
    ...   Run Keyword And Ignore Error   csn.Disconnect   connection=gNB

Get Detected RU list from DU
    [Arguments]   ${connection}=gNB
    ${connected_RU}   Create Dictionary
    ${detected_RUs}   csn.Execute   cat /ffs/run/config/FRIps.txt   connection=${connection}
    FOR   ${ru}   IN   @{detected_RUs.splitlines()}
        ${check_ru_info}    run keyword and return status    should contain    ${ru}    ;
        continue for loop if   '${check_ru_info}' == '${False}'
        ${sn}   Set Variable   ${ru.split(";")[3]}
        ${ip}   Set Variable   ${ru.split(";")[2]}
        ${type}   Set Variable   ${ru.split(";")[4]}
        ${ru_info}   Create Dictionary   ip=${ip}   type=${type}  source=${connection}
        run keyword if  not $ip == "0.0.0.0"   Set to Dictionary   ${connected_RU}   ${sn}=${ru_info}
    END
    [Return]   ${connected_RU}

Get not detected RU index
    [Arguments]    ${detected_RUs}
    ${ru_index_list}   Create List
    ${not_detected_RUs}   Create List
    ${disconnect_list}   Create List
    ${configured_RUs}   COAM get RUs details
    FOR   ${RU}   IN   @{configured_RUs}
        ${ru_index}   Set Variable   ${RU['id']['configuration'].split("/")[-1].split("-")[1]}
        Append to List   ${ru_index_list}   ${ru_index}
        Run Keyword If   'serialNumber' not in @{RU.keys()}   Run Keywords
        ...   Append to List   ${not_detected_RUs}   ${RU['id']['configuration'].split("/")[-1].split("-")[1]}
        ...   AND   Continue for Loop
        Run Keyword If   '${RU['serialNumber']}' in @{detected_RUs.keys()}   Set To Dictionary
        ...   ${detected_RUs['${RU['serialNumber']}']}   index=${ru_index}
        Continue For Loop If   '${RU['serialNumber']}' in @{detected_RUs.keys()}
        Append to List   ${not_detected_RUs}   ${RU['id']['configuration'].split("/")[-1].split("-")[1]}
    END
    Sort List   ${ru_index_list}
    FOR   ${ru_index}   IN   @{not_detected_RUs}
        ${disconnect_list}   Append Not Detected RU Index   ${ru_index}   ${ru_index_list}   ${disconnect_list}
    END
    [Return]    ${detected_RUs}   ${disconnect_list}   ${ru_index_list}

COAM get RUs details
    [Arguments]    ${connection}=COAM
    &{hw_info}    coam.get_detected_hw_info    connection=${connection}
    [Return]  ${hw_info['radioModules']['rmod']}

Append Not Detected RU Index
    [Arguments]   ${ru_index}   ${ru_index_list}   ${disconnect_list}
    ${config_index}   Get Index From List   ${ru_index_list}   ${ru_index}
    Append to List   ${disconnect_list}   ${${config_index}}
    [Return]   ${disconnect_list}

Clear RU BTSLOG
    [Arguments]    ${ctrl_pc}=${rus[${ru_index}]['ctrl_addr']}   ${ctrl_username}=${rus[${ru_index}]['ctrl_username']}
    ...    ${ctrl_password}=${rus[${ru_index}]['ctrl_password']}
    log to console    Clear RU BTSLOG from ${ctrl_pc}
    ${connection_taf}=  csn.connect_to    hostname=${ctrl_pc}  username=${ctrl_username}
    ...   password=${ctrl_password}   alias=testpc
    csn.execute   command=cd /tmp/btslog2;sudo rm -rf *  connection=testpc
    csn.execute   command=cd /tmp;sudo rm -rf RU_snapshot.tar  connection=testpc
    csn.execute   command=cd /tmp;sudo rm -rf ru_btslog_${ctrl_pc}.zip  connection=testpc
    [Teardown]    csn.disconnect    connection=testpc

Clear ALL RUs BTSLOG
    log to console    Clear ALL RUs BTSLOG
    FOR   ${value}   IN   @{rus}
        run keyword if  '${value['ctrl_addr']}' != '1.1.1.1'
        ...   Clear RU BTSLOG   ctrl_pc=${value['ctrl_addr']}   ctrl_username=${value['ctrl_username']}
        ...   ctrl_password=${value['ctrl_password']}
    END

Save RU BTSLOG
    [Arguments]    ${ctrl_pc}=${rus[${ru_index}]['ctrl_addr']}   ${ctrl_username}=${rus[${ru_index}]['ctrl_username']}
    ...    ${ctrl_password}=${rus[${ru_index}]['ctrl_password']}    ${logpath}=${OUTPUT_DIR}
    log to console   Save RU BTSLOG from ${ctrl_pc}
    ${connection_taf}=  csn.connect_to    hostname=${ctrl_pc}    username=${ctrl_username}    password=${ctrl_password}    alias=testpc
    csn.execute   cd /tmp;zip -q -r ru_btslog_${ctrl_pc}.zip /tmp/btslog2   connection=testpc
    csn.Download File    remote_path=/tmp/ru_btslog_${ctrl_pc}.zip
    ...    local_path=${logpath}/ru_btslog_${ctrl_pc}.zip   connection=testpc
    [Teardown]    csn.disconnect    connection=testpc

Save ALL RUs BTSLOG
    [Arguments]    ${logpath}=${OUTPUT_DIR}
    FOR   ${value}   IN   @{rus}
        run keyword if  '${value['ctrl_addr']}' != '1.1.1.1'
        ...   Save RU BTSLOG  ctrl_pc=${value['ctrl_addr']}   ctrl_username=${value['ctrl_username']}
        ...   ctrl_password=${value['ctrl_password']}    logpath=${logpath}
    END


Save RU Serial Log
    [Arguments]    ${ctrl_pc}=${rus[${ru_index}]['ctrl_addr']}   ${ctrl_username}=${rus[${ru_index}]['ctrl_username']}
    ...    ${ctrl_password}=${rus[${ru_index}]['ctrl_password']}    ${logpath}=${OUTPUT_DIR}
    log to console   Save RU Serial Log from ${ctrl_pc}
    ${connection_taf}=  csn.connect_to    hostname=${ctrl_pc}    username=${ctrl_username}    password=${ctrl_password}    alias=testpc
    csn.Download File    remote_path=/tmp/putty.txt
    ...    local_path=${logpath}/RU_serial_${ctrl_pc}.txt   connection=testpc
    [Teardown]    csn.disconnect    connection=testpc

Save ALL RUs Serial Log
    [Arguments]    ${logpath}=${OUTPUT_DIR}
    log to console     Save ALL RUs Serial Log
    FOR   ${value}   IN   @{rus}
        run keyword if  '${value['ctrl_addr']}' != '1.1.1.1'
        ...   Save RU Serial Log    ctrl_pc=${value['ctrl_addr']}   ctrl_username=${value['ctrl_username']}
        ...   ctrl_password=${value['ctrl_password']}    logpath=${logpath}
    END

Clear RU Serial Log
    [Arguments]    ${ctrl_pc}=${rus[${ru_index}]['ctrl_addr']}   ${ctrl_username}=${rus[${ru_index}]['ctrl_username']}
    ...    ${ctrl_password}=${rus[${ru_index}]['ctrl_password']}
    log to console   Clear RU Serial Log from ${ctrl_pc}
    ${connection_taf}=  csn.connect_to    hostname=${ctrl_pc}  username=${ctrl_username}
    ...   password=${ctrl_password}   alias=testpc
    run keyword and ignore error   csn.execute   command=sudo chmod 777 /tmp/putty.txt   connection=testpc
    run keyword and ignore error   csn.execute   command=cat /dev/null > /tmp/putty.txt  connection=testpc
    [Teardown]    csn.disconnect    connection=testpc

Clear ALL RUs Serial Log
    log to console    clear all rus serial log
    FOR   ${value}   IN   @{rus}
        run keyword if  '${value['ctrl_addr']}' != '1.1.1.1'
        ...   Clear RU Serial Log   ctrl_pc=${value['ctrl_addr']}   ctrl_username=${value['ctrl_username']}
        ...   ctrl_password=${value['ctrl_password']}
    END


Check and Upload RU btslog Flag in Swconfig File
    FOR   ${ru}   IN   @{rus}
        continue for loop if     '${ru['ctrl_addr']}' == '1.1.1.1'
        Check and Upload Single RU btslog Flag in Swconfig File    ru=${ru}
    END



Check and Upload Single RU btslog Flag in Swconfig File
    [Arguments]    ${ru}
    log to console    Check and Upload Single RU btslog Flag in Swconfig File from ${ru['ctrl_addr']}
    ${username}   Set Variable   ${ru['username']}
    ${password}   Set Variable   ${ru['password']}
    ${ru_addr}    Set Variable   ${ru['addr']}
    ${ctrl_pc}    Set Variable   ${ru['ctrl_addr']}
    ${ctrl_username}    Set Variable   ${ru['ctrl_username']}
    ${ctrl_password}    Set Variable   ${ru['ctrl_password']}

    csn.connect_to    hostname=${ctrl_pc}    username=${ctrl_username}    password=${ctrl_password}    alias=testpc

    ${ru_ip_segment}   Should Match Regexp   ${ru_addr}   \\d+.\\d+.\\d+
    ${output}   csn.Execute   command=sudo cat /etc/network/interfaces | grep ${ru_ip_segment}   connection=testpc
    ${test_pc_192_ip}    Should Match Regexp   ${output}   (\\d+).(\\d+).(\\d+).(\\d+)
    ${segment1}   Convert To Hex   ${test_pc_192_ip[1]}   length=2
    ${segment2}   Convert To Hex   ${test_pc_192_ip[2]}   length=2
    ${segment3}   Convert To Hex   ${test_pc_192_ip[3]}   length=2
    ${segment4}   Convert To Hex   ${test_pc_192_ip[4]}   length=2
    ${test_pc_192_ip_hex}   Set Variable   0x${segment1}${segment2}${segment3}${segment4}

    ${ru_swconfig_command}   Set Variable   ccsShell.sh rad -mpw 0x10042 ${test_pc_192_ip_hex}

    csn.connect_to    hostname=${ru_addr}    username=${username}    password=${password}    alias=RU    proxy=testpc

    ${sudo}   Set Variable If   "${username}"!="root"   sudo${SPACE}   ${EMPTY}
    Run Keyword If   "${TEST_MODE}"=="UUF"   Run Keywords
    ...   csn.Send Command   command=${sudo} rm -rf /rom/swconfig.txt   connection=RU
    ...   AND
    ...   csn.Send Command   command=${sudo} rm -rf /rom/swconfig_local.txt   connection=RU
    ...   AND
    ...   Sleep   1s

    csn.Send Command   command=${ru_swconfig_command}   connection=RU
    Sleep   1s
    Log To Console   Command: ${ru_swconfig_command}

    csn.Send Command   command=ccsShell.sh rad -mpw 0x10043 0xC739   connection=RU
    Sleep   1s
    Log To Console   Command: ccsShell.sh rad -mpw 0x10043 0xC739

    csn.Send Command   command=ccsShell.sh rad -mpw 0x10041 2   connection=RU
    Sleep   1s
    Log To Console   Command: ccsShell.sh rad -mpw 0x10041 2
    [Teardown]   Run Keyword And Ignore Error   Run Keywords
    ...   Run Keyword And Ignore Error   csn.Disconnect   connection=RU   AND
    ...   Run Keyword And Ignore Error   csn.Disconnect   connection=testpc

Get SBTS detected RUs
    [Arguments]   ${is_dual_core}=${False}   ${login_ip}=${asik_addr}
    csn.Connect to
    ...   hostname=${login_ip}   username=${asik_username}   password=${asik_password}   alias=gNB
    ${gNB_connected_RUs}   Get Detected RU list from SBTS  connection=gNB
    ${gnb_left}    Run Keyword If   ${is_dual_core}   If GNB In Left Side    connection=gNB
    ${hostname}   Set Variable If   ${gnb_left}   fct-4a   fct-0a
    Run Keyword If   ${is_dual_core}   csn.Connect to   hostname=${hostname}   username=${asik_username}
    ...   password=${asik_password}   proxy=gNB   alias=dual
    ${dual_connected}   Run Keyword If   ${is_dual_core}   Get Detected RU list from SBTS   connection=dual
    ...   ELSE   Create Dictionary
    ${gNB_connected_RUs}     Run Keyword If   ${dual_connected}   combine lists    ${gNB_connected_RUs}   ${dual_connected}
    ...    ELSE     set variable    ${gNB_connected_RUs}
    [Return]   ${gNB_connected_RUs}
    [Teardown]   Run Keywords
    ...   Run Keyword And Ignore Error   Run Keyword If   ${is_dual_core}   csn.Disconnect   connection=dual   AND
    ...   Run Keyword And Ignore Error   csn.Disconnect   connection=gNB

Get Detected RU list from SBTS
    [Arguments]   ${connection}=gNB
    ${connected_RU}   Create List
    ${detected_RUs}   csn.Execute   cat /ffs/run/config/FRIps.txt   connection=${connection}
    FOR   ${ru}   IN   @{detected_RUs.splitlines()}
        ${check_ru_info}    run keyword and return status    should contain    ${ru}    ;
        continue for loop if   '${check_ru_info}' == '${False}'
        ${sn}   Set Variable   ${ru.split(";")[3]}
        ${ip}   Set Variable   ${ru.split(";")[2]}
        ${type}   Set Variable   ${ru.split(";")[4]}
        ${ru_info}   Create Dictionary   ip=${ip}   type=${type}  source=${connection}
        ${ru_sn}     create dictionary    ${sn}=${ru_info}
        run keyword if  not $ip == "0.0.0.0"   append to list  ${connected_RU}   ${ru_sn}
    END
    [Return]   ${connected_RU}

Swith to other node in RU
    [Arguments]    ${coam_connection}=COAM    ${ru_node}=dfe0
    ${detected_RUs}   Get gNB detected RUs
    csn.Connect to
    ...   hostname=${asik_addr}   username=${asik_username}   password=${asik_password}   alias=ASIK Master
    ${container_id}   Get FHNET Container ID
    FOR   ${ru_info}   IN   @{detected_RUs.items()}
        ${ru_ip}    Set Variable     ${ru_info[1]['ip']}
        run keyword if   '${ru_info[0]}'=='CV192702348'    _CMD to Swith to other node    ru_ip=${ru_ip}
        ...   counterid=${container_id}    ru_node=${ru_node}    coam_connection=${coam_connection}
    END
    [Teardown]   csn.Disconnect   connection=ASIK Master

_CMD to Swith to other node
     [Arguments]    ${ru_ip}    ${container_id}    ${ru_node}=dfe0   ${coam_connection}=COAM
      ${username}   Set Variable   ${rus[0]['username']}
      ${password}   Set Variable   ${rus[0]['password']}
      Connect To RU Via FHNET Container   ru_ip_addr=${ru_ip}   ru_username=${username}   ru_password=${password}
        ...   counterid=${container_id}    coam_connection=${coam_connection}
      csn.execute    ps aux    connection=RU
      csn.execute    sudo -i;echo ${ru_node} > /sys/bus/i2c/drivers/mico32/3-003c/uart_mu    connection=RU
      run keyword and ignore error    csn.execute    cat /sys/bus/i2c/drivers/mico32/3-003c/uart_mux    connection=RU
      run keyword and ignore error    csn.execute    ps    connection=RU

Swith to other node RU at ControlPC
    log to console  Swith to other node RU at ControlPC
#    run keyword and ignore error  Run   ps -ef|grep ${switch_node_ru_script}|grep -v grep| awk '{print $2}' |xargs kill -9
    FOR   ${value}   IN   @{rus}
        run keyword if  '${value['ctrl_addr']}' != '1.1.1.1'
        ...   switch_to_other_node_ru   ip=${value['ctrl_addr']}   username=${value['ctrl_username']}
        ...   password=${value['ctrl_password']}   ru_ip=${value['addr']}   ru_username=${value['username']}
        ...   ru_password=${value['password']}
    END

Enable LMI RU at ControlPC
    log to console  Enable LMI RU at ControlPC
#    run keyword and ignore error  Run   ps -ef|grep ${switch_node_ru_script}|grep -v grep| awk '{print $2}' |xargs kill -9
    FOR   ${value}   IN   @{rus}
        run keyword if  '${value['ctrl_addr']}' != '1.1.1.1'
        ...   enable_lmi_on_ru   ip=${value['ctrl_addr']}   username=${value['ctrl_username']}
        ...   password=${value['ctrl_password']}   ru_ip=${value['addr']}   ru_username=${value['username']}
        ...   ru_password=${value['password']}
    END


Enable Single LMI RU at ControlPC
    [Arguments]     ${host}=${rus[${ru_index}]['ctrl_addr']}
    ...             ${user}=${rus[${ru_index}]['ctrl_username']}
    ...             ${password}=${rus[${ru_index}]['ctrl_password']}
    ...              ${ru_ip}=${rus[${ru_index}]['addr']}
    ...    ${ru_username}=${rus[${ru_index}]['username']}    ${ru_password}=${rus[${ru_index}]['password']}
    log to console  Enable Single LMI RU at ControlPC
    csn.Connect to   hostname=${host}   username=${user}   password=${password}  alias=testpc
    ${connection}    csn.get_connection_by_alias    alias=testpc
    ${channel}    Call Method    ${connection}    invoke_shell
    Call Method    ${channel}    send    sudo -i\n
    Sleep    2 sec
    Call Method    ${channel}    recv    ${65535}
    ${pingcmd}    catenate   SEPARATOR=
    ...   ping${SPACE}
    ...   ${ru_ip}
    ...   ${SPACE}-c 3\n
    Call Method    ${channel}    send    ${pingcmd}
    Sleep    10 sec
    ${output}    Call Method    ${channel}    recv    ${65535}
    ${output}    Convert To String    ${output}
    ${enable}    set variable   3 packets transmitted, 3 received
    Return From Keyword If    ${output.count('${enable}')}>0
    Call Method    ${channel}    send    stty -F /dev/ttyUSB0 115200 parodd\n
    Sleep    10 sec
    ${output}    Call Method    ${channel}    recv    ${65535}
    ${command1}    catenate   SEPARATOR=
    ...   echo${SPACE}"
    ...   ${ru_username}"
    ...   ${SPACE}> /dev/ttyUSB0\n
    ${command2}    catenate   SEPARATOR=
    ...   echo${SPACE}"
    ...   ${ru_password}"
    ...   ${SPACE}> /dev/ttyUSB0\n
    Call Method    ${channel}    send    ${command1}
    Sleep    3 sec
    Call Method    ${channel}    recv    ${65535}
    Call Method    ${channel}    send    ${command2}
    Sleep    3 sec
    Call Method    ${channel}    recv    ${65535}
    Call Method    ${channel}    send    echo "sudo lmi-eth on" > /dev/ttyUSB0\n
    Sleep    1 sec
    Call Method    ${channel}    recv    ${65535}
    Call Method    ${channel}    send    echo "sudo lmi-eth on" > /dev/ttyUSB0\n
    Sleep    1 sec
    Call Method    ${channel}    recv    ${65535}
    Call Method    ${channel}    send    ${pingcmd}
    Sleep    10 sec
    ${output}    Call Method    ${channel}    recv    ${65535}
    ${output}    Convert To String    ${output}
    run keyword if   ${output.count('${enable}')}<=0    FAIL   msg=Enable LMI RU at ControlPC failed!


Check All RU PM Log
    FOR   ${ru}   IN   @{rus}
        continue for loop if     '${ru['ctrl_addr']}' == '1.1.1.1'
        Check Single RU PM Log    ru=${ru}
    END



Check Single RU PM Log
    [Arguments]    ${ru}
    log to console    Check Single RU PM Log from ${ru['ctrl_addr']}
    ${username}   Set Variable   ${ru['username']}
    ${password}   Set Variable   ${ru['password']}
    ${ru_addr}    Set Variable   ${ru['addr']}
    ${ctrl_pc}    Set Variable   ${ru['ctrl_addr']}
    ${ctrl_username}    Set Variable   ${ru['ctrl_username']}
    ${ctrl_password}    Set Variable   ${ru['ctrl_password']}

    csn.connect_to    hostname=${ctrl_pc}    username=${ctrl_username}    password=${ctrl_password}    alias=testpc
    csn.connect_to    hostname=${ru_addr}    username=${username}    password=${password}    alias=RU    proxy=testpc


    ${output}    csn.execute  command=cd /mnt/runtime/pmflashlogs;ls  connection=RU
    Sleep   1s
    should contain    ${output}    pm2
    should contain    ${output}    pm3
    should contain    ${output}    pm4
    should contain    ${output}    pm5

    ${output}    csn.execute    command=cd /tmp;ls   connection=RU
    Sleep   1s
    should contain    ${output}    pm5

    [Teardown]   Run Keyword And Ignore Error   Run Keywords
    ...   Run Keyword And Ignore Error   csn.Disconnect   connection=RU   AND
    ...   Run Keyword And Ignore Error   csn.Disconnect   connection=testpc


Send Special CMD to RU at ControlPC
    [Arguments]    ${cmd_list}
    log to console  Send Special CMD to RU at ControlPC:${cmd_list}
#    run keyword and ignore error  Run   ps -ef|grep ${switch_node_ru_script}|grep -v grep| awk '{print $2}' |xargs kill -9
    FOR   ${value}   IN   @{rus}
        run keyword if  '${value['ctrl_addr']}' != '1.1.1.1'
        ...   send_cmd_to_ru   ip=${value['ctrl_addr']}   username=${value['ctrl_username']}
        ...   password=${value['ctrl_password']}   ru_ip=${value['addr']}   ru_username=${value['username']}
        ...   ru_password=${value['password']}
        ...   cmds=${cmd_list}
    END


Validate RU IP Reachability from Control PC by SN
        [Arguments]    ${ru_sn}    ${exp_status}
        Log To Console    Validate RU IP Reachability from Control PC by SN
        FOR   ${value}   IN   @{rus}
             run keyword if  '${value['ctrl_addr']}' != '1.1.1.1' and '${value['serial_number']}' == '${ru_sn}'
                ...   Validate IP Reachability from Control PC
                ...   ip_addr=${value['addr']}
                ...   exp_status=${exp_status}
                ...   ctrl_addr=${value['ctrl_addr']}
                ...   ctrl_username=${value['ctrl_username']}
                ...   ctrl_password=${value['ctrl_password']}
        END


Enable Single LMI RU at ControlPC by SN
    [Arguments]    ${ru_sn}
    log to console  Enable Single LMI RU at ControlPC by SN:${ru_sn}
#    run keyword and ignore error  Run   ps -ef|grep ${switch_node_ru_script}|grep -v grep| awk '{print $2}' |xargs kill -9
    FOR   ${value}   IN   @{rus}
        run keyword if  '${value['ctrl_addr']}' != '1.1.1.1' and '${value['serial_number']}' == '${ru_sn}'
        ...   enable_lmi_on_ru   ip=${value['ctrl_addr']}   username=${value['ctrl_username']}
        ...   password=${value['ctrl_password']}   ru_ip=${value['addr']}   ru_username=${value['username']}
        ...   ru_password=${value['password']}
    END

Start BTSLOG at RU Control PC
    [Arguments]    ${name}=btslog    ${btslog_path}=/opt/btslog/btslog
    ...             ${btslog_launcher_path}=/opt/btslog/btslog_launcher          ${log_dir}=/tmp/btslog2
    ...             ${host}=${rus[${ru_index}]['ctrl_addr']}
    ...             ${user}=${rus[${ru_index}]['ctrl_username']}
    ...             ${password}=${rus[${ru_index}]['ctrl_password']}
    log to console    start btslog at ru control pc from ${host}
    run keyword and ignore error   Clear RU BTSLOG   ctrl_pc=${host}   ctrl_username=${user}   ctrl_password=${password}
    &{executor}=    create dictionary    host=${host}
    ...                                  user=${user}
    ...                                  password=${password}
    btslog.create_btslog_collector       name=${name}
    ...                                  btslog_path=${btslog_path}
    ...                                  btslog_launcher_path=${btslog_launcher_path}
    ...                                  executor=${executor}
    ...                                  log_dir=${log_dir}
    btslog.Set Global Alias               ${name}
    core.setup_collectors                names=${name}
    core.start_collectors                names=${name}

Start ALL RUs BTSLOG at RU PC
    log to console      Start ALL RUs BTSLOG at RU PC
    FOR   ${value}   IN   @{rus}
        run keyword if  '${value['ctrl_addr']}' != '1.1.1.1'
        ...   Start BTSLOG at RU Control PC  name=btslog_${value['ctrl_addr']}
        ...    host=${value['ctrl_addr']}   user=${value['ctrl_username']}
        ...   password=${value['ctrl_password']}
    END

Stop BTSlog at RU Control PC
    [Arguments]    ${ctrl_pc}=${rus[${ru_index}]['ctrl_addr']}   ${ctrl_username}=${rus[${ru_index}]['ctrl_username']}
    ...    ${ctrl_password}=${rus[${ru_index}]['ctrl_password']}
#    ${cmd_prefix}   Set Variable If   '${user}'=='root'   ${EMPTY}   sudo${SPACE}
    log to console    stop btslog at ru control pc ${ctrl_pc}
    csn.Connect to   hostname=${ctrl_pc}   username=${ctrl_username}   password=${ctrl_password}  alias=testpc
    csn.Execute   command=sudo pkill -9 -f -x '/opt/btslog/btslog -NOGUI'   timeout=60   connection=testpc
    csn.Execute   command=sudo rm -rf /tmp/BTSLogCommandsLocalServer   timeout=60    connection=testpc
    [Teardown]   csn.Disconnect   connection=testpc

Stop ALL RUs BTSLOG at RU PC
    log to console      Stop ALL RUs BTSLOG at RU PC
    FOR   ${value}   IN   @{rus}
        run keyword if  '${value['ctrl_addr']}' != '1.1.1.1'
        ...   Stop BTSlog at RU Control PC   ctrl_pc=${value['ctrl_addr']}   ctrl_username=${value['ctrl_username']}
        ...   ctrl_password=${value['ctrl_password']}
    END

Save RU Snapshot
    [Timeout]    20min
    [Arguments]    ${ctrl_pc}=${rus[${ru_index}]['ctrl_addr']}   ${ctrl_username}=${rus[${ru_index}]['ctrl_username']}
    ...    ${ctrl_password}=${rus[${ru_index}]['ctrl_password']}   ${ru_ip}=${rus[${ru_index}]['addr']}
    ...    ${ru_username}=${rus[${ru_index}]['username']}    ${ru_password}=${rus[${ru_index}]['password']}
    ...    ${logpath}=${OUTPUT_DIR}
    log to console    save ru snapshot at ${ctrl_pc}
#    run keyword if  '${ctrl_pc}' != '1.1.1.1'
#    ...   save_ru_log  ip=${ctrl_pc}   username=${ctrl_username}
#    ...   password=${ctrl_password}  ru_ip=${ru_ip}  ru_username=${ru_username}
#    ...   ru_password=${ru_password}
    run keyword if  '${ctrl_pc}' != '1.1.1.1'
    ...   enable_lmi_on_ru   ip=${ctrl_pc}   username=${ctrl_username}
    ...   password=${ctrl_password}   ru_ip=${ru_ip}   ru_username=${ru_username}
    ...   ru_password=${ru_password}

    csn.Connect to   hostname=${ctrl_pc}   username=${ctrl_username}   password=${ctrl_password}  alias=testpc
    csn.Connect to   hostname=${ru_ip}   username=${ru_username}   password=${ru_password}  alias=RU    proxy=testpc
    csn.execute   command=ccsShell.sh log -a -c full -z RU_snapshot.tar   connection=RU
    Wait Until Keyword Succeeds    3min    10s    _Check if remote file size not update
    ...  file_path=/ram/RU_snapshot.tar   connection=RU
    csn.Download File    remote_path=/ram/RU_snapshot.tar
    ...    local_path=${logpath}/RU_snapshot_${ctrl_pc}.tar   connection=RU
    [Teardown]   csn.Disconnect   connection=testpc


_Check if remote file size not update
    [Arguments]   ${file_path}   ${connection}   ${timeout}=120s
    Wait Until Keyword Succeeds   ${timeout}   5s   csn.File Exists
    ...   remote_path=${file_path}   connection=${connection}   timeout=${30}
    ${prev_size}   Get File Size   file_path=${file_path}   connection=${connection}
    Sleep   1s
    ${final_size}   Get File Size   file_path=${file_path}   connection=${connection}
    Should Be Equal   ${prev_size}    ${final_size}


Save ALL RUs Snapshot
    [Arguments]    ${logpath}=${OUTPUT_DIR}
    log to console    Save ALL RUs Snapshot
    FOR   ${value}   IN   @{rus}
        run keyword if  '${value['ctrl_addr']}' != '1.1.1.1'
        ...   Save RU Snapshot  ctrl_pc=${value['ctrl_addr']}   ctrl_username=${value['ctrl_username']}
        ...   ctrl_password=${value['ctrl_password']}  ru_ip=${value['addr']}   ru_username=${value['username']}
        ...   ru_password=${value['password']}    logpath=${logpath}
    END

If GNB In Left Side
    [Arguments]    ${connection}=ASIK Master
    ${cmd_output0}    ssh.Execute    command=hostname   connection=${connection}
    ${fctid}    get regexp matches      ${cmd_output0}     fct-(\\d+)a    1
    ${is_left_enabled}    Set Variable If    '0' in ${fctid}    ${True}    ${False}
    [Return]    ${is_left_enabled}


ALL RUs Switch to other node and Send CMD to RU
    [Arguments]    ${node_ip}    ${cmd_list_1}    ${cmd_list_2}
    log to console  Switch to other node and Send CMD to RU
#    run keyword and ignore error  Run   ps -ef|grep ${switch_node_ru_script}|grep -v grep| awk '{print $2}' |xargs kill -9
    FOR   ${value}   IN   @{rus}
        run keyword if  '${value['ctrl_addr']}' != '1.1.1.1'
        ...   Switch to other node and Send CMD to RU
        ...   node_ip=${node_ip}    cmd_list_1=${cmd_list_1}    cmd_list_2=${cmd_list_2}
        ...   ctrl_pc=${value['ctrl_addr']}   ctrl_username=${value['ctrl_username']}
        ...   ctrl_password=${value['ctrl_password']}   ru_ip=${value['addr']}   ru_username=${value['username']}
        ...   ru_password=${value['password']}
    END


Switch to other node and Send CMD to RU
    [Timeout]    20min
    [Arguments]    ${node_ip}    ${cmd_list_1}   ${cmd_list_2}   ${ctrl_pc}=${rus[${ru_index}]['ctrl_addr']}
    ...   ${ctrl_username}=${rus[${ru_index}]['ctrl_username']}
    ...    ${ctrl_password}=${rus[${ru_index}]['ctrl_password']}   ${ru_ip}=${rus[${ru_index}]['addr']}
    ...    ${ru_username}=${rus[${ru_index}]['username']}    ${ru_password}=${rus[${ru_index}]['password']}
    log to console  Switch to other node and Send CMD to RU at ${ctrl_pc}

    csn.Connect to   hostname=${ctrl_pc}   username=${ctrl_username}   password=${ctrl_password}  alias=testpc
    csn.Connect to   hostname=${ru_ip}   username=${ru_username}   password=${ru_password}  alias=RU    proxy=testpc
    ${hostname}    csn.execute   command=hostname  connection=RU
    FOR   ${cmd}   IN   @{cmd_list_1}
        csn.send command   command=${cmd}  connection=RU
        sleep    5s
    END
    csn.Connect to   hostname=${node_ip}  username=${ru_username}   password=${ru_password}  alias=RU_thor    proxy=RU
    ${hostname}    csn.execute   command=hostname   connection=RU_thor
    FOR   ${cmd}   IN   @{cmd_list_2}
        csn.send command   command=${cmd}  connection=RU_thor
        sleep    5s
    END
#    [Teardown]   Run Keywords   csn.Disconnect   connection=RU_thor    AND    csn.Disconnect   connection=RU
#    ...   AND   csn.Disconnect   connection=testpc


Stop ALL RUs tcpdumps
    [Arguments]    ${node_ip}
    log to console  Switch to other node and Send CMD to RU
#    run keyword and ignore error  Run   ps -ef|grep ${switch_node_ru_script}|grep -v grep| awk '{print $2}' |xargs kill -9
    FOR   ${value}   IN   @{rus}
        run keyword if  '${value['ctrl_addr']}' != '1.1.1.1'
        ...   Stop RU tcpdumps
        ...   node_ip=${node_ip}
        ...   ctrl_pc=${value['ctrl_addr']}   ctrl_username=${value['ctrl_username']}
        ...   ctrl_password=${value['ctrl_password']}   ru_ip=${value['addr']}   ru_username=${value['username']}
        ...   ru_password=${value['password']}
    END


Stop RU tcpdumps
    [Timeout]    20min
    [Arguments]    ${node_ip}    ${ctrl_pc}=${rus[${ru_index}]['ctrl_addr']}
    ...   ${ctrl_username}=${rus[${ru_index}]['ctrl_username']}
    ...    ${ctrl_password}=${rus[${ru_index}]['ctrl_password']}   ${ru_ip}=${rus[${ru_index}]['addr']}
    ...    ${ru_username}=${rus[${ru_index}]['username']}    ${ru_password}=${rus[${ru_index}]['password']}
    log to console  Stop RU tcpdumps ${ctrl_username}

    csn.Connect to   hostname=${ctrl_pc}   username=${ctrl_username}   password=${ctrl_password}  alias=testpc
    csn.Connect to   hostname=${ru_ip}   username=${ru_username}   password=${ru_password}  alias=RU    proxy=testpc
    csn.execute  command=sudo killall tcpdump  connection=RU
    csn.Connect to   hostname=${node_ip}  username=${ru_username}   password=${ru_password}  alias=RU_thor    proxy=RU
    csn.execute   command=sudo killall tcpdump  connection=RU_thor
    [Teardown]   Run Keywords   csn.Disconnect   connection=RU_thor    AND    csn.Disconnect   connection=RU
    ...   AND   csn.Disconnect   connection=testpc


Stop and Save ALL RUs tcpdumps
    [Arguments]    ${node_ip}    ${cmd_list_1}   ${cmd_list_2}    ${logpath}=${OUTPUT_DIR}
    log to console  Stop and Save ALL RUs tcpdumps
    FOR   ${value}   IN   @{rus}
        run keyword if  '${value['ctrl_addr']}' != '1.1.1.1'
        ...   Stop and Save RU tcpdumps
        ...   node_ip=${node_ip}    cmd_list_1=${cmd_list_1}    cmd_list_2=${cmd_list_2}
        ...   ctrl_pc=${value['ctrl_addr']}   ctrl_username=${value['ctrl_username']}
        ...   ctrl_password=${value['ctrl_password']}   ru_ip=${value['addr']}   ru_username=${value['username']}
        ...   ru_password=${value['password']}    logpath=${logpath}
    END


Stop and Save RU tcpdumps
    [Timeout]    20min
    [Arguments]    ${node_ip}    ${cmd_list_1}   ${cmd_list_2}    ${ctrl_pc}=${rus[${ru_index}]['ctrl_addr']}
    ...   ${ctrl_username}=${rus[${ru_index}]['ctrl_username']}
    ...    ${ctrl_password}=${rus[${ru_index}]['ctrl_password']}   ${ru_ip}=${rus[${ru_index}]['addr']}
    ...    ${ru_username}=${rus[${ru_index}]['username']}    ${ru_password}=${rus[${ru_index}]['password']}
    ...    ${logpath}=${OUTPUT_DIR}
    log to console  Stop and Save RU tcpdumps ${rus[${ru_index}]['ctrl_addr']}
    #stop tcpdump
    csn.Connect to   hostname=${ctrl_pc}   username=${ctrl_username}   password=${ctrl_password}  alias=testpc
    csn.Connect to   hostname=${ru_ip}   username=${ru_username}   password=${ru_password}  alias=RU    proxy=testpc
    csn.execute   command=sudo killall tcpdump  connection=RU

    FOR  ${cmd}   IN   @{cmd_list_1}
        ${file_names}    Get Regexp Matches    ${cmd}    \\/ram\\/(\\w+\\.pcap)   1
    END
    FOR  ${file_name}   IN   @{file_names}
        run keyword and ignore error    csn.send command    command=sudo chmod 777 /ram/${file_name}  connection=RU
        sleep  2s
        run keyword and ignore error    csn.Download File    remote_path=/ram/${file_name}
    ...    local_path=${logpath}/${file_name}_${ctrl_pc}.tar   connection=RU
    END



    csn.Connect to   hostname=${node_ip}  username=${ru_username}   password=${ru_password}  alias=RU_thor    proxy=RU
    csn.execute  command=sudo killall tcpdump  connection=RU_thor

    FOR  ${cmd}   IN   @{cmd_list_2}
        ${file_names}    Get Regexp Matches    ${cmd}    \\/ram\\/(\\w+\\.pcap)   1
    END
    FOR  ${file_name}   IN   @{file_names}
        run keyword and ignore error    csn.send command    command=sudo chmod 777 /ram/${file_name}  connection=RU_thor
        sleep  2s
        run keyword and ignore error    csn.Download File    remote_path=/ram/${file_name}
        ...    local_path=${logpath}/${file_name}_${ctrl_pc}.tar   connection=RU_thor
    END


    [Teardown]   Run Keywords   csn.Disconnect   connection=RU_thor    AND    csn.Disconnect   connection=RU
    ...   AND   csn.Disconnect   connection=testpc

Check ALL RUs Syslog Error
    log to console    Check ALL RUs Syslog Error
    FOR   ${value}   IN   @{rus}
        run keyword if  '${value['ctrl_addr']}' != '1.1.1.1'
        ...   Siso Common Check Single RU Syslog Error  ctrl_pc=${value['ctrl_addr']}   ctrl_username=${value['ctrl_username']}
        ...   ctrl_password=${value['ctrl_password']}
    END

Siso Common Check Single RU Syslog Error
    [Arguments]    ${ctrl_pc}=${rus[${ru_index}]['ctrl_addr']}
    ...   ${ctrl_username}=${rus[${ru_index}]['ctrl_username']}
    ...    ${ctrl_password}=${rus[${ru_index}]['ctrl_password']}
    Log To Console   //TODO: Siso Common Check RU Syslog Error at ${ctrl_pc}

    Return From Keyword If   "${ctrl_username}"=="" or "${ctrl_pc}"=="${None}" or "${ctrl_pc}"=="1.1.1.1"

    ${connection_status}   Run Keyword And Return Status   csn.Connect to
    ...   hostname=${ctrl_pc}   username=${ctrl_username}   password=${ctrl_password}   alias=${ctrl_pc}   timeout=${10}
    Run Keyword If   not ${connection_status}   Log To Console   Test PC Can Not Connect: ${ctrl_pc}
    Return From Keyword If   not ${connection_status}

    ${output}   csn.Execute   command=ls -al /tmp/btslog2/SYSLOG*.LOG   connection=${ctrl_pc}
    ${syslog_exist}   Run Keyword And Return Status   Should Not Contain   ${output}   No such file or directory
    Return From Keyword If   not ${syslog_exist}

    Log To Console   Check Syslog Error On TestPC: ${ctrl_pc}
    Log To Console   Syslog File List:
    Log To Console   ${output}



    ${offline_output}   csn.Execute
    ...   command=cat /tmp/btslog2/SYSLOG*.LOG | grep '\\-\\=\\-\\='   connection=${ctrl_pc}
    ${status1}   Run Keyword And Return Status   Should Be Empty   ${offline_output}   Syslog Crash verification failed


    ${cmd_errorallowed}     Evaluate     '| '.join(@{SYSLOG_ERROR_allowed})
    ${command}   Catenate   SEPARATOR=
    ...   cat /tmp/btslog2/SYSLOG*.LOG
    ...   | grep -iE 'ERR/'
    ...   | ${cmd_errorallowed}
    ${offline_output}   csn.Execute    command=${command}   connection=${ctrl_pc}
    ${status2}   Run Keyword And Return Status   Should Be Empty   ${offline_output}   RU btslog has error Print!


    ${status_list}   Create List   ${status1}   ${status2}
    Run Keyword And Continue On Failure   List Should Not Contain Value   ${status_list}   ${False}

    [Teardown]   Run Keyword And Ignore Error   csn.Disconnect   connection=${ctrl_pc}