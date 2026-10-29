*** Settings ***
Documentation   Author: jingmin.he@nokia-sbell.com
Library   taf.transport.ssh   WITH NAME   csn
Library   Collections
#Library    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/UUF/Scripts/UUF_common.py
#Library   testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/libraries/switch_to_other_node_ru.py
#Variables    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/libraries/global_vars.py
#Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG7/siso_common.robot


*** Variables ***
#${switch_node_ru_script}    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/libraries/switch_to_other_node_ru.py
${ru_index}   0
@{cmd_list}


*** Keywords ***
VDU Clear RU BTSLOG
    [Arguments]    ${ctrl_pc}=${rus[${ru_index}]['ctrl_addr']}   ${ctrl_username}=${rus[${ru_index}]['ctrl_username']}
    ...    ${ctrl_password}=${rus[${ru_index}]['ctrl_password']}
    log to console    Clear RU BTSLOG from ${ctrl_pc}
    ${connection_taf}=  csn.connect_to    hostname=${ctrl_pc}  username=${ctrl_username}
    ...   password=${ctrl_password}   alias=testpc
    csn.execute   command=cd /tmp/btslog2;rm -rf *  connection=testpc
    csn.execute   command=cd /tmp;rm -rf RU_snapshot.tar  connection=testpc
    [Teardown]    csn.disconnect    connection=testpc

VDU Clear ALL RUs BTSLOG
    [Arguments]    ${rus}=${rus_du[1]}
    log to console    Clear ALL RUs BTSLOG
    FOR   ${value}   IN   @{rus}
        run keyword if  '${value['ctrl_addr']}' != '1.1.1.1'
        ...   VDU Clear RU BTSLOG   ctrl_pc=${value['ctrl_addr']}   ctrl_username=${value['ctrl_username']}
        ...   ctrl_password=${value['ctrl_password']}
    END

VDU Save RU BTSLOG
    [Arguments]    ${ctrl_pc}=${rus[${ru_index}]['ctrl_addr']}   ${ctrl_username}=${rus[${ru_index}]['ctrl_username']}
    ...    ${ctrl_password}=${rus[${ru_index}]['ctrl_password']}
    log to console   Save RU BTSLOG from ${ctrl_pc}
    ${connection_taf}=  csn.connect_to    hostname=${ctrl_pc}    username=${ctrl_username}    password=${ctrl_password}    alias=testpc
    csn.execute   cd /tmp;zip -q -r ru_btslog_${ctrl_pc}.zip /tmp/btslog2   connection=testpc
    csn.Download File    remote_path=/tmp/ru_btslog_${ctrl_pc}.zip
    ...    local_path=${OUTPUT_DIR}/ru_btslog_${ctrl_pc}.zip   connection=testpc
    [Teardown]    csn.disconnect    connection=testpc

VDU Save ALL RUs BTSLOG
    [Arguments]    ${rus}=${rus_du[1]}
    FOR   ${value}   IN   @{rus}
        run keyword if  '${value['ctrl_addr']}' != '1.1.1.1'
        ...   VDU Save RU BTSLOG  ctrl_pc=${value['ctrl_addr']}   ctrl_username=${value['ctrl_username']}
        ...   ctrl_password=${value['ctrl_password']}
    END


VDU Save RU Serial Log
    [Arguments]    ${ctrl_pc}=${rus[${ru_index}]['ctrl_addr']}   ${ctrl_username}=${rus[${ru_index}]['ctrl_username']}
    ...    ${ctrl_password}=${rus[${ru_index}]['ctrl_password']}
    log to console   Save RU Serial Log from ${ctrl_pc}
    ${connection_taf}=  csn.connect_to    hostname=${ctrl_pc}    username=${ctrl_username}    password=${ctrl_password}    alias=testpc
    csn.Download File    remote_path=/tmp/putty.txt
    ...    local_path=${OUTPUT_DIR}/RU_serial_${ctrl_pc}.txt   connection=testpc
    [Teardown]    csn.disconnect    connection=testpc

VDU Save ALL RUs Serial Log
    [Arguments]    ${rus}=${rus_du[1]}
    log to console     Save ALL RUs Serial Log
    FOR   ${value}   IN   @{rus}
        run keyword if  '${value['ctrl_addr']}' != '1.1.1.1'
        ...   VDU Save RU Serial Log    ctrl_pc=${value['ctrl_addr']}   ctrl_username=${value['ctrl_username']}
        ...   ctrl_password=${value['ctrl_password']}
    END

VDU Clear RU Serial Log
    [Arguments]    ${ctrl_pc}=${rus[${ru_index}]['ctrl_addr']}   ${ctrl_username}=${rus[${ru_index}]['ctrl_username']}
    ...    ${ctrl_password}=${rus[${ru_index}]['ctrl_password']}
    log to console   Clear RU Serial Log from ${ctrl_pc}
    ${connection_taf}=  csn.connect_to    hostname=${ctrl_pc}  username=${ctrl_username}
    ...   password=${ctrl_password}   alias=testpc
    run keyword and ignore error   csn.execute   command=sudo chmod 777 /tmp/putty.txt   connection=testpc
    run keyword and ignore error   csn.execute   command=cat /dev/null > /tmp/putty.txt  connection=testpc
    [Teardown]    csn.disconnect    connection=testpc

VDU Clear ALL RUs Serial Log
    [Arguments]    ${rus}=${rus_du[1]}
    log to console    clear all rus serial log
    FOR   ${value}   IN   @{rus}
        run keyword if  '${value['ctrl_addr']}' != '1.1.1.1'
        ...   VDU Clear RU Serial Log   ctrl_pc=${value['ctrl_addr']}   ctrl_username=${value['ctrl_username']}
        ...   ctrl_password=${value['ctrl_password']}
    END


VDU Check and Upload RU btslog Flag in Swconfig File
    [Arguments]    ${rus}=${rus_du[1]}
    FOR   ${ru}   IN   @{rus}
        continue for loop if     '${ru['ctrl_addr']}' == '1.1.1.1'
        VDU Check and Upload Single RU btslog Flag in Swconfig File    ru=${ru}
    END



VDU Check and Upload Single RU btslog Flag in Swconfig File
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
    Run Keywords
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


VDU Enable LMI RU at ControlPC
    [Arguments]    ${rus}=${rus_du[1]}
    Log    ${rus_du}
    log to console  Enable LMI RU at ControlPC
#    run keyword and ignore error  Run   ps -ef|grep ${switch_node_ru_script}|grep -v grep| awk '{print $2}' |xargs kill -9
    FOR   ${value}   IN   @{rus}
        run keyword if  '${value['ctrl_addr']}' != '1.1.1.1'
        ...   VDU Enable Single LMI RU at ControlPC   host=${value['ctrl_addr']}   user=${value['ctrl_username']}
        ...   password=${value['ctrl_password']}   ru_ip=${value['addr']}   ru_username=${value['username']}
        ...   ru_password=${value['password']}
    END


VDU Send Special CMD to RU at ControlPC
    [Arguments]    ${cmd_list}    ${rus}=${rus_du[1]}
    log to console  Send Special CMD to RU at ControlPC:${cmd_list}
#    run keyword and ignore error  Run   ps -ef|grep ${switch_node_ru_script}|grep -v grep| awk '{print $2}' |xargs kill -9
    FOR   ${value}   IN   @{rus}
        run keyword if  '${value['ctrl_addr']}' != '1.1.1.1'
        ...   send_cmd_to_ru   ip=${value['ctrl_addr']}   username=${value['ctrl_username']}
        ...   password=${value['ctrl_password']}   ru_ip=${value['addr']}   ru_username=${value['username']}
        ...   ru_password=${value['password']}
        ...   cmds=${cmd_list}
    END


#Validate RU IP Reachability from Control PC by SN
#        [Arguments]    ${ru_sn}    ${exp_status}
#        Log To Console    Validate RU IP Reachability from Control PC by SN
#        FOR   ${value}   IN   @{rus}
#             run keyword if  '${value['ctrl_addr']}' != '1.1.1.1' and '${value['serial_number']}' == '${ru_sn}'
#                ...   Validate IP Reachability from Control PC
#                ...   ip_addr=${value['addr']}
#                ...   exp_status=${exp_status}
#                ...   ctrl_addr=${value['ctrl_addr']}
#                ...   ctrl_username=${value['ctrl_username']}
#                ...   ctrl_password=${value['ctrl_password']}
#        END


VDU Enable Single LMI RU at ControlPC
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

VDU Start BTSLOG at RU Control PC
    [Arguments]    ${name}=btslog    ${btslog_path}=/opt/btslog/btslog
    ...             ${btslog_launcher_path}=/opt/btslog/btslog_launcher          ${log_dir}=/tmp/btslog2
    ...             ${host}=${rus[${ru_index}]['ctrl_addr']}
    ...             ${user}=${rus[${ru_index}]['ctrl_username']}
    ...             ${password}=${rus[${ru_index}]['ctrl_password']}
    log to console    start btslog at ru control pc from ${host}
    run keyword and ignore error   VDU Clear RU BTSLOG   ctrl_pc=${host}   ctrl_username=${user}   ctrl_password=${password}
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

VDU Start ALL RUs BTSLOG at RU PC
    [Arguments]    ${rus}=${rus_du[1]}
    log to console      Start ALL RUs BTSLOG at RU PC
    FOR   ${value}   IN   @{rus}
        run keyword if  '${value['ctrl_addr']}' != '1.1.1.1'
        ...   VDU Start BTSLOG at RU Control PC  name=btslog_${value['ctrl_addr']}
        ...    host=${value['ctrl_addr']}   user=${value['ctrl_username']}
        ...   password=${value['ctrl_password']}
    END

VDU Stop BTSlog at RU Control PC
    [Arguments]    ${ctrl_pc}=${rus[${ru_index}]['ctrl_addr']}   ${ctrl_username}=${rus[${ru_index}]['ctrl_username']}
    ...    ${ctrl_password}=${rus[${ru_index}]['ctrl_password']}
#    ${cmd_prefix}   Set Variable If   '${user}'=='root'   ${EMPTY}   sudo${SPACE}
    log to console    stop btslog at ru control pc ${ctrl_pc}
    csn.Connect to   hostname=${ctrl_pc}   username=${ctrl_username}   password=${ctrl_password}  alias=testpc
    csn.Execute   command=pkill -9 -f -x '/opt/btslog/btslog -NOGUI'   timeout=60   connection=testpc
    csn.Execute   command=rm -rf /tmp/BTSLogCommandsLocalServer   timeout=60    connection=testpc
    [Teardown]   csn.Disconnect   connection=testpc

VDU Stop ALL RUs BTSLOG at RU PC
    [Arguments]    ${rus}=${rus_du[1]}
    log to console      Stop ALL RUs BTSLOG at RU PC
    FOR   ${value}   IN   @{rus}
        run keyword if  '${value['ctrl_addr']}' != '1.1.1.1'
        ...   VDU Stop BTSlog at RU Control PC   ctrl_pc=${value['ctrl_addr']}   ctrl_username=${value['ctrl_username']}
        ...   ctrl_password=${value['ctrl_password']}
    END

VDU Save RU Snapshot
    [Arguments]    ${ctrl_pc}=${rus[${ru_index}]['ctrl_addr']}   ${ctrl_username}=${rus[${ru_index}]['ctrl_username']}
    ...    ${ctrl_password}=${rus[${ru_index}]['ctrl_password']}   ${ru_ip}=${rus[${ru_index}]['addr']}
    ...    ${ru_username}=${rus[${ru_index}]['username']}    ${ru_password}=${rus[${ru_index}]['password']}
    log to console    save ru snapshot at ${ctrl_pc}
    run keyword if  '${ctrl_pc}' != '1.1.1.1'
    ...   VDU Enable Single LMI RU at ControlPC   ip=${ctrl_pc}   username=${ctrl_username}
    ...   password=${ctrl_password}   ru_ip=${ru_ip}   ru_username=${ru_username}
    ...   ru_password=${ru_password}

    csn.Connect to   hostname=${ctrl_pc}   username=${ctrl_username}   password=${ctrl_password}  alias=testpc
    csn.Connect to   hostname=${ru_ip}   username=${ru_username}   password=${ru_password}  alias=RU    proxy=testpc
    csn.execute   command=ccsShell.sh log -a -c full -z RU_snapshot.tar   connection=RU
    Wait Until Keyword Succeeds    3min    10s    _Check if remote file size not update
    ...  file_path=/ram/RU_snapshot.tar   connection=RU
    csn.Download File    remote_path=/ram/RU_snapshot.tar
    ...    local_path=${OUTPUT_DIR}/RU_snapshot_${ctrl_pc}.tar   connection=RU
    [Teardown]   csn.Disconnect   connection=testpc

_Check if remote file size not update
    [Arguments]   ${file_path}   ${connection}   ${timeout}=120s
    Wait Until Keyword Succeeds   ${timeout}   5s   csn.File Exists
    ...   remote_path=${file_path}   connection=${connection}   timeout=${30}
    ${prev_size}   VDU Get File Size   file_path=${file_path}   connection=${connection}
    Sleep   1s
    ${final_size}   VDU Get File Size   file_path=${file_path}   connection=${connection}
    Should Be Equal   ${prev_size}    ${final_size}

VDU Get File Size
    [Arguments]   ${file_path}   ${connection}
    ${file_info}   csn.Execute   command=ls -la ${file_path}   connection=${connection}
    [Return]   ${file_info.split()[4]}

VDU Save ALL RUs Snapshot
    [Arguments]    ${rus}=${rus_du[1]}
    log to console    Save ALL RUs Snapshot
    FOR   ${value}   IN   @{rus}
        run keyword if  '${value['ctrl_addr']}' != '1.1.1.1'
        ...   VDU Save RU Snapshot  ctrl_pc=${value['ctrl_addr']}   ctrl_username=${value['ctrl_username']}
        ...   ctrl_password=${value['ctrl_password']}  ru_ip=${value['addr']}   ru_username=${value['username']}
        ...   ru_password=${value['password']}
    END

VDU Siso Common Check ALL RU Syslog Error
    [Arguments]    ${rus}=${rus_du[1]}
    log to console    VDU Siso Common Check ALL RU Syslog Error
    FOR   ${value}   IN   @{rus}
        run keyword if  '${value['ctrl_addr']}' != '1.1.1.1'
        ...  VDU Siso Common Check Syslog Error
        ...   test_pc_addr=${value['ctrl_addr']}
        ...   test_pc_username=${value['ctrl_username']}
        ...   test_pc_password=${value['ctrl_password']}
    END


VDU RU Log Operation Setup in Siso Common
    run keyword and ignore error    VDU Enable LMI RU at ControlPC
#    run keyword and ignore error    Send Special CMD to RU at ControlPC    cmd_list=${RU_CMD_LIST}
    run keyword and ignore error    VDU Check and Upload RU btslog Flag in Swconfig File
    run keyword and ignore error    VDU Clear ALL RUs Serial Log
    run keyword and ignore error    VDU Clear ALL RUs BTSLOG
    Run Keyword and Ignore Error    VDU Start ALL RUs BTSLOG at RU PC

VDU RU Log Operation Teardown if keyword failed
    run keyword and ignore error    VDU Stop ALL RUs BTSLOG at RU PC
    run keyword and ignore error    VDU Save ALL RUs Serial Log
    run keyword and ignore error    VDU Save ALL RUs BTSLOG
    run keyword and ignore error    VDU Save ALL RUs Snapshot


VDU RU Log Operation Teardown if keyword passed
    run keyword and ignore error    VDU Stop ALL RUs BTSLOG at RU PC
    #######for debug############
#    run keyword and ignore error    VDU Save ALL RUs Serial Log
#    run keyword and ignore error    VDU Save ALL RUs BTSLOG
#    run keyword and ignore error    VDU Save ALL RUs Snapshot
    #######for debug############