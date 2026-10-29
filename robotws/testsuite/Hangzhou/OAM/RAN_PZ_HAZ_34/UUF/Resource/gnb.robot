*** Settings ***
Documentation     author: Ruiyu Han
...               contact: ruiyu.han@nokia-sbell.com
...               Upgrade and Rollback UUF case.
Library   taf.transport.ssh   WITH NAME   csn

Library    ../../libraries/utils/csv_operation.py
Library    ../../libraries/utils/netact_swing.py
Library    ../../libraries/utils/swconfig.py
Library    ../../libraries/utils/throughput.py
Variables   gnb_commands_var.py
Resource   testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_env.robot
Library           ../../libraries/TestCaseRequirement.py
Variables   testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/libraries/global_vars.py
Resource      testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/UUF/Resource/common.robot
Resource      testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/UUF/Resource/netact_swm.robot
Library     OperatingSystem
Library     XML
Library     Process
Library     String
Library     Collections
Library     DateTime

*** Variables ***
@{clean_loner_commands}   0xDF50200C 32 0x3   0xDF502018   0xDF502020   0xDF502028   0xDF502030   0xDF502068
...   0xDF50C154 32 0x100   0xDF50C150   0xDF50C14C   0xDF50C154 32 0x1   0xDF50054C

*** Keywords ***
Start Tcpdump RU Log Through Local IP
    [Arguments]   ${command}
    log to console    Start Tcpdump RU Log Through Local IP
    ${index}   set variable  0
    FOR   ${value}   IN   @{rus}
       set suite variable  ${TAF_ADDR}   ${value['ctrl_addr']}
       set suite variable  ${TAF_USERNAME}   ${value['ctrl_username']}
       set suite variable  ${TAF_PASSWORD}   ${value['ctrl_password']}
       set suite variable  ${RU_ADDR}   ${value['addr']}
       set suite variable  ${RU_USERNAME}   ${value['username']}
       set suite variable  ${RU_PASSWORD}   ${value['password']}
       ${index}   evaluate  ${index}+1
       run keyword and ignore error  Start Tcpdump RU Log Through Local IP Separately   RU_ADDR=${RU_ADDR}   RU_USERNAME=${RU_USERNAME}
       ...   RU_PASSWORD=${RU_PASSWORD}   TAF_ADDR=${TAF_ADDR}   command=${command}   index=${index}
    END

Start Tcpdump RU Log Through Local IP Separately
    [Arguments]   ${RU_ADDR}   ${RU_USERNAME}   ${RU_PASSWORD}   ${TAF_ADDR}   ${command}   ${index}
    ${connection_taf}=  csn.connect_to    hostname=${TAF_ADDR}    username=${TAF_USERNAME}    password=${TAF_PASSWORD}    alias=taf_${index}
    ${connection_ru}=  wait until keyword succeeds  10 min   10s   csn.Connect To    hostname=${RU_ADDR}    username=${RU_USERNAME}
    ...   password=${RU_PASSWORD}   proxy=taf_${index}   alias=RU_${index}
    run keyword and ignore error   wait until keyword succeeds  5 times   10s   csn.Send Command   command=${command} &> /dev/null &
    ...   timeout=100000000   connection=RU_${index}
    sleep   10s
    [Teardown]  run keywords  run keyword and ignore error  csn.disconnect    connection=RU_${index}
    ...   AND   run keyword and ignore error  csn.disconnect    connection=taf_${index}

Save Tcpdump RU Log Through Local IP
    [Arguments]   ${dir}   ${filename}
    log to console    Save Tcpdump RU Log Through Local IP
    FOR   ${value}   IN   @{rus}
       set suite variable  ${TAF_ADDR}   ${value['ctrl_addr']}
       set suite variable  ${TAF_USERNAME}   ${value['ctrl_username']}
       set suite variable  ${TAF_PASSWORD}   ${value['ctrl_password']}
       set suite variable  ${RU_ADDR}   ${value['addr']}
       set suite variable  ${RU_USERNAME}   ${value['username']}
       set suite variable  ${RU_PASSWORD}   ${value['password']}
       run keyword and ignore error  Save Tcpdump RU Log Through Local IP Separately   RU_ADDR=${RU_ADDR}   RU_USERNAME=${RU_USERNAME}
       ...   RU_PASSWORD=${RU_PASSWORD}   TAF_ADDR=${TAF_ADDR}   dir=${dir}  filename=${filename}
    END

Save Tcpdump RU Log Through Local IP Separately
    [Arguments]   ${RU_ADDR}   ${RU_USERNAME}   ${RU_PASSWORD}   ${TAF_ADDR}   ${dir}   ${filename}
    ${connection_taf}=  csn.connect_to    hostname=${TAF_ADDR}    username=${TAF_USERNAME}    password=${TAF_PASSWORD}    alias=taf
    ${connection_ru}=  wait until keyword succeeds  10 min   10s   csn.Connect To    hostname=${RU_ADDR}    username=${RU_USERNAME}
    ...   password=${RU_PASSWORD}   proxy=taf   alias=RU
    sleep   10s
    run keyword and ignore error   wait until keyword succeeds  3 times   10s   csn.Download File    remote_path=/ram/${filename}
    ...    local_path=${OUTPUT_DIR}/${dir}/${TAF_ADDR}_${filename}   connection=RU
    [Teardown]  run keywords  run keyword and ignore error   csn.execute   command=rm -rf /ram/${filename}  connection=RU
    ...   AND   run keyword and ignore error   csn.disconnect    connection=RU
    ...   AND   run keyword and ignore error   csn.disconnect    connection=taf

Remove Tcpdump RU Log Through Local IP
    [Arguments]   ${filename}
    log to console   Remove Tcpdump RU Log Through Local IP
    FOR   ${value}   IN   @{rus}
       set suite variable  ${TAF_ADDR}   ${value['ctrl_addr']}
       set suite variable  ${TAF_USERNAME}   ${value['ctrl_username']}
       set suite variable  ${TAF_PASSWORD}   ${value['ctrl_password']}
       set suite variable  ${RU_ADDR}   ${value['addr']}
       set suite variable  ${RU_USERNAME}   ${value['username']}
       set suite variable  ${RU_PASSWORD}   ${value['password']}
       run keyword and ignore error  Remove Tcpdump RU Log Through Local IP Separately   RU_ADDR=${RU_ADDR}   RU_USERNAME=${RU_USERNAME}
       ...   RU_PASSWORD=${RU_PASSWORD}   TAF_ADDR=${TAF_ADDR}   filename=${filename}
    END

Remove Tcpdump RU Log Through Local IP Separately
    [Arguments]   ${RU_ADDR}   ${RU_USERNAME}   ${RU_PASSWORD}   ${TAF_ADDR}   ${filename}
    ${connection_taf}=  csn.connect_to    hostname=${TAF_ADDR}    username=${TAF_USERNAME}    password=${TAF_PASSWORD}    alias=taf
    ${connection_ru}=  wait until keyword succeeds  10 min   10s   csn.Connect To    hostname=${RU_ADDR}    username=${RU_USERNAME}
    ...   password=${RU_PASSWORD}   proxy=taf   alias=RU
    run keyword and ignore error   wait until keyword succeeds  3 times   10s   csn.execute   command=rm -rf /ram/${filename}  connection=RU
    ...   connection=RU
    [Teardown]  run keywords  run keyword and ignore error   csn.disconnect    connection=RU
    ...   AND   run keyword and ignore error   csn.disconnect    connection=taf

Download tcpdump data
    [Arguments]   ${file_dir}    ${tcpdumfile}=rom    ${gnb_tcpdump_file}=netact    ${local_name}=netact
    ${status}    run keyword and return status    csn.Assert file exists    remote_path=/${tcpdumfile}/${gnb_tcpdump_file}.pcap    connection=gnb
    run keyword if    ${status}    csn.Download File   remote_path=/${tcpdumfile}/${gnb_tcpdump_file}.pcap
    ...   local_path=${file_dir}/${local_name}.pcap   connection=gnb

Get RU type
    [Arguments]   ${alias}=webui
    ${ru_info}   megazone.get_frm   attribute=name   frm_id=1   session=${alias}
    [Return]   ${ru_info}

Check gNB memory
    log to console    Check gNB memory
    csn.Connect to   hostname=${asik_addr}   username=${asik_username}   password=${asik_password}    alias=gnb
    ${totalmem}    csn.execute    command=free -h    connection=gnb
    set suite variable    ${totalmem}
    ${memory_info}  csn.execute    command=free -h | grep Mem    connection=gnb
    Strip String    ${memory_info}
    ${stripped}=	Strip String   ${memory_info}   characters=${SPACE}\r\n
    @{available_list} =    Split String   ${stripped}    ${SPACE}
    set suite variable     ${availablevalue}    ${available_list[-1]}
    ${mem_value}     Get Regexp Matches   ${availablevalue}    [0-9][0-9]*.[0-9]*
    run keyword if     'G' in '${availablevalue}'
    ...   run keyword if    ${${mem_value}[0]} < ${1.0}    run keywords
        ...    Log    available mem smaller than 1G! need reboot gNB!    WARN
        ...    AND    csn.execute    command=ddal -s ddal_reboot_sm_site_graceful DDAL_REBOOT_SM_SHELF_SIDE_OWN    connection=gnb
        ...    AND    megazone.wait_for_site_unavailability    url=${WEBUI_URL}    timeout=1200    interval=60.0
        ...    AND    run keyword    Check Cell Setup in COAM
    run keyword if     'G' not in '${availablevalue}'    run keywords
           ...    Log    available mem smaller than 1G! need reboot gNB!    WARN
           ...    AND    csn.execute    command=ddal -s ddal_reboot_sm_site_graceful DDAL_REBOOT_SM_SHELF_SIDE_OWN    connection=gnb
           ...    AND    megazone.wait_for_site_unavailability    url=${WEBUI_URL}    timeout=1200    interval=60.0
           ...    AND    run keyword    Check Cell Setup in COAM
    [Teardown]    run keyword and ignore error   csn.Disconnect   connection=gnb

Start Abil log collection
    [Arguments]   ${log_file_dir}   ${ip_ending}   ${alias}
    Start Process   python   ${CURDIR}/../Scripts/collect_abil_general_logs.py    ${asik_addr}   ${log_file_dir}    ${ip_ending}
    ...   alias=${alias}

Stop Abil log collection
    [Arguments]   ${alias}
    Terminate Process   handle=${alias}   kill=true

Unit IP reachable
    [Arguments]   ${host}   ${username}   ${password}   ${ip_addr}
    Wait Until Keyword Succeeds    5 min    1 min
    ...   csn.Connect To   hostname=${host}   username=${username}   password=${password}   alias=ping_reachable
    ${ping_res}   csn.Execute   command=sudo ping ${ip_addr} -c 3   connection=ping_reachable   timeout=60
    ${result}   Run Keyword and Return Status   should not match regexp   ${ping_res}   100% packet loss
    [Return]   ${result}
    [Teardown]   csn.Disconnect   connection=ping_reachable

Start eNB TRS Tcpdump
    ${ENBs}    Remove Duplicates    ${ENBs}
    FOR   ${enb}   IN   @{ENBs}
        Start Tcpdump 62003   ne_ip=${enb['addr']}   type=enb
    END

Stop eNB TRS Tcpdump
     [Arguments]   ${dir}=./   ${save}=${True}
    ${ENBs}    Remove Duplicates    ${ENBs}
    FOR   ${enb}   IN   @{ENBs}
        Stop Tcpdump 62003   ne_ip=${enb['addr']}   type=enb   dir=${dir}   save=${save}
    END

Start Tcpdump 62003
    [Arguments]   ${ne_ip}=${asik_addr}   ${type}=gnb
    ${connection_asik}=  csn.Connect to   hostname=${ne_ip}   username=${asik_username}   password=${asik_password}    alias=${type}
    run keyword and ignore error    csn.execute   connection=${type}
    ...   command=ps -ef | grep DSS_${type}.pcap | grep -v grep | awk '{print $2}' | xargs kill -9
    run keyword and ignore error    csn.execute   command=rm -f /tmp/DSS_${type}.pcap   connection=${type}
    run keyword and ignore error    csn.send_command
    ...   command=nohup tcpdump -i any port 32742 -w /tmp/DSS_${type}.pcap &>/dev/null &
    ...   timeout=10   connection=${type}
    Sleep   10s
    [Teardown]    run keyword and ignore error    csn.Disconnect   connection=${type}

Stop Tcpdump 62003
    [Arguments]   ${ne_ip}=${asik_addr}   ${type}=gnb   ${save}=${True}   ${dir}=./
    ${connection_asik}=  csn.Connect to   hostname=${ne_ip}   username=${asik_username}   password=${asik_password}    alias=${type}
    run keyword and ignore error    csn.execute
    ...   command=ps -ef | grep DSS_${type}.pcap | grep -v grep | awk '{print $2}' | xargs kill -9
    ...   connection=${type}
    run keyword if   ${save}    csn.Download File   remote_path=/tmp/DSS_${type}.pcap
    ...   local_path=${OUTPUT_DIR}/${dir}/DSS_${type}.pcap   connection=${type}
    [Teardown]    run keyword and ignore error    csn.Disconnect   connection=${type}
