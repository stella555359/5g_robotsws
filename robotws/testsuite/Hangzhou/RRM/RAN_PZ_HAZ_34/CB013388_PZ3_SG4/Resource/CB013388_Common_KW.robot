*** Settings ***
Documentation    this is common keyword used for CB0101680-A siso opertation

Library    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB010680/Resource/CB010680_SRS_BIP.py
#Variables    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB010680/Resource/CB010680_A_Params.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG4/SISO_common_operation.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG4/common_variables.robot
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB010680/Resource/CB010680_BIP.robot
Library    taf.collectors.core   WITH NAME   core
Library    taf.collectors.btslog  WITH NAME   btslog

*** Keywords ***
Common Suit Setup
        robot_common_operations.Common Suite Setup
        CI_interface.Common Suite Setup
        Setup Commission SCF
        Run Keyword And Ignore Error    Check GNB on air And alarm    bts_host=${gNB_ip}
        ...    allowed_list=${allowed_alarm_list}    time=20min

Block or UnBlock Single Cell
    [Arguments]  ${cell_id}    ${block_flag}=${True}    ${bts_host}=${gnb_ip}    ${connection}=GNB_OAM    ${timeout}=60
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    ${dist_name}    Set Variable    MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
    Run keyword if    ${block_flag}==${True}    Log To Console    Block Cell-${cell_id}
    ...    ELSE    Log To Console    UnBlock Cell-${cell_id}
    Run keyword if    ${block_flag}==${True}    coam.block_cell    dist_name=${dist_name}    timeout=${timeout}    connection=${connection}
    ...    ELSE    coam.unblock_cell    dist_name=${dist_name}    timeout=${timeout}    connection=${connection}
    sleep    5s
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Attach MTK90 power UE and check throughput
    [Arguments]    ${ue_index}    ${ul_throughput}    ${cells}    ${dl_throughput}=${None}
    ...    ${target_avg_percent_UL}=0.93   ${target_avg_percent_DL}=0.3
    @{ue_index_list}    create list    ${ue_index}
    MTK UE Click on airplane mode    ue_mode=Attach   ue_index=${ue_index}
    UE Start Traffic    ue_index=${ue_index}    ue_type=samsung    ul_throughput=${ul_throughput}M    dl_throughput=${dl_throughput}M
    Check Throught From Asslog    ul_list=${cells}    dl_list=${cells}     ul_tp=${ul_throughput}    dl_tp=${dl_throughput}
    ...    target_avg_percent_UL=${target_avg_percent_UL}   target_avg_percent_DL=${target_avg_percent_DL}
#    UE Stop Traffic    ue_index=${ue_index}    ue_type=samsung
#    [Teardown]  MTK UE Click on airplane mode    ue_mode=Dettach    ue_index=${ue_index}

Dettach UE By Adb Command
    [Arguments]    ${ue_index}=${0}
    ${serial_number}    Set Variable    ${tl.ues[${ue_index}].serial_number}
    Run Keyword and Ignore Error   csn.send_command    command=adb -s ${serial_number} root    connection=cygwin
    sleep   4s
    Run Keyword and Ignore Error   csn.send_command    command=adb -s ${serial_number} shell settings put global airplane_mode_on 1
    ...    connection=cygwin
    sleep   4s
    Run Keyword and Ignore Error   csn.send_command
    ...    command=adb -s ${serial_number} shell am broadcast -a android.intent.action.AIRPLANE_MODE --ez state true    connection=cygwin
    sleep   4s

Attach UE By Adb Command
    [Arguments]    ${ue_index}=${0}
    ${serial_number}    Set Variable    ${tl.ues[${ue_index}].serial_number}
    Run Keyword and Ignore Error   csn.send_command    command=adb -s ${serial_number} root    connection=cygwin
    sleep   4s
    Run Keyword and Ignore Error   csn.send_command    command=adb -s ${serial_number} shell settings put global airplane_mode_on 0
    ...    connection=cygwin
    sleep   4s
    Run Keyword and Ignore Error   csn.send_command
    ...    command=adb -s ${serial_number} shell am broadcast -a android.intent.action.AIRPLANE_MODE --ez state false    connection=cygwin
    sleep   4s

UE Start Traffic
    [Arguments]    ${ue_index}    ${ue_type}=samsung_ue    ${ul_throughput}=${None}    ${dl_throughput}=${None}
    ...    ${ul_duration}=6000    ${dl_duration}=6000    ${protocol}=udp    ${if_ul}=${True}    ${if_dl}=${True}
    Run Keyword And Ignore Error    run keyword if     ${if_ul}    power_ue.Start traffic    direction=ul    duration=${ul_duration}
    ...    protocol=${protocol}    ue_index=${ue_index}    iperf_port=${ul_port_list[${ue_index}]}    throughput=${ul_throughput}
    ...    ue_type=${ue_type}    apn_address=dxdata1    iperf_type=via_command
    run keyword and continue on failure    run keyword if     ${if_dl}    power_ue.Start traffic    direction=dl    duration=${dl_duration}
    ...    protocol=${protocol}    ue_index=${ue_index}    iperf_port=${dl_port_list[${ue_index}]}    throughput=${dl_throughput}
    ...    ue_type=${ue_type}

UE Stop Traffic
    [Arguments]    ${ue_index}    ${ue_type}=samsung_ue    ${protocol}=udp    ${if_ul}=${True}    ${if_dl}=${True}
    Run Keyword And Ignore Error    run keyword if    ${if_ul}    power_ue.Stop traffic    direction=ul    ue_index=${ue_index}
    ...    ue_type=${ue_type}    protocol=${protocol}    iperf_port=${ul_port_list[${ue_index}]}    iperf_type=via_command
    run keyword and continue on failure    run keyword if    ${if_dl}    power_ue.Stop traffic    direction=dl    ue_index=${ue_index}
    ...    ue_type=${ue_type}    protocol=${protocol}    iperf_port=${dl_port_list[${ue_index}]}

Check Throught From Asslog
    [Arguments]  ${ul_list}    ${dl_list}      ${ul_tp}=${500}    ${dl_tp}=${500}    ${if_ul}=${True}    ${if_dl}=${True}
    ...    ${target_avg_percent_UL}=0.90    ${ue_type}=samsung   ${log_time}=60s    ${target_avg_percent_DL}=0.90
    ...    ${gnb_index}=0
    ${log_path}    power_ue.Collect Tput   ue_type=${ue_type}    duration=${log_time}    ignore_time=10s    gnb_index=${gnb_index}
    run keyword and continue on failure    run keyword if    ${if_ul}==${True}    power_ue.Check Tput    ue_type=${ue_type}
    ...    direction=UL    log=${log_path}    cells=${ul_list}    target_throughput=${ul_tp}    target_avg_percent=${target_avg_percent_UL}
    ...    actCarrierAggregation=${True}    min_percent=0
    run keyword and continue on failure    run keyword if    ${if_dl}==${True}    power_ue.Check Tput    ue_type=${ue_type}
    ...    direction=DL    log=${log_path}    cells=${dl_list}    target_throughput=${dl_tp}    target_avg_percent=${target_avg_percent_DL}
    ...    actCarrierAggregation=${True}    min_percent=0



MTK UE Click on airplane mode
    [Documentation]   click AIRPLANE
    ...    :param  ue_mode: Attach  or  Dettach
    [Arguments]   ${ue_mode}    ${ue_index}
    Get all UE pointer variable
    Connect to control pc via cygwin    ue_index=${ue_index}
    Run Keyword If    '${ue_mode}'=='Dettach'    Dettach UE By Adb Command    ue_index=${ue_index}
    Run Keyword If    '${ue_mode}'=='Attach'    Run Keywords    Dettach UE By Adb Command    ue_index=${ue_index}    AND
    ...    Attach UE By Adb Command    ue_index=${ue_index}
    [Teardown]    Run Keyword And Ignore Error    csn.disconnect      connection=cygwin


Pcap chang to txt
    [Arguments]    ${pcap_name}=Tcpdump.pcap    ${text_name}=Tcpdump.txt    ${logpath}=${OUTPUT_DIR}/${TEST NAME}
    Convert pcap to text    source=${logpath}/${pcap_name}    target=${logpath}/${text_name}

Convert pcap to text
    [Arguments]    ${source}    ${target}    ${filter}=ngap||f1ap
    ssh.Connect to    hostname=${UTE_ADDRESS}    username=${UTE_USERNAME}    password=${UTE_PASSWORD}    alias=UTE
    Log To Console    Convert pcap to text
    ssh.send_command
    ...    command=nice tshark -V -r ${source} -T text > ${target} -Y '${filter}'
    ...    connection=UTE
    sleep    10s
    ssh.await execution end    connection=UTE    timeout=10min
    [Teardown]    ssh.disconnect    connection=UTE

Modify Parameters with coam
    [Arguments]    ${input_list}    ${delta_id}=update_parameter    ${connection}=GNB_OAM
    coam.create_delta    delta_id=${delta_id}
    Log to console    start modify parameters:\n
    FOR    ${item}  IN    @{input_list}
        ${operation}    get from dictionary    ${item}    operation
        Run keyword if    '${operation}'=='update'
        ...    coam.append_parameter_update_to_delta    dist_name=${item['dist_name']}    parameter=${item['parameter']}
        ...    value=${item['value']}    delta_id=${delta_id}
        Run keyword if    '${operation}'=='delete'
        ...    coam.append_parameter_delete_to_delta    dist_name=${item['dist_name']}    parameter=${item['parameter']}
        ...    delta_id=${delta_id}
        Log to console    Add task - ${operation}: ${item['dist_name']}.${item['parameter']}
        Run keyword if    '${operation}'=='update_object'
        ...    coam.append_managed_object_to_delta    dist_name=${item['dist_name']}
        ...    operation=update    delta_id=${delta_id}
        Run keyword if    '${operation}'=='delete_object'
        ...    coam.append_managed_object_to_delta    dist_name=${item['dist_name']}
        ...    operation=delete    delta_id=${delta_id}
        Run keyword if    '${operation}'=='create_object'
        ...    coam.append_managed_object_to_delta    dist_name=${item['dist_name']}
        ...    operation=create    delta_id=${delta_id}
    END
    ${delta_file}    coam.get_delta    delta_id=${delta_id}
    ${timeout}    set variable    300
    Log to console    Perform parameters via delta_id:${delta_id} is ongoing, timeout ${timeout}s.
    coam.perform_delta_recommissioning
    ...    delta_file=${delta_file}
    ...    skip_parameter_relation_errors=${False}
    ...    should_activate=${True}
    ...    timeout=${timeout}
    ...    connection=${connection}
    Log to console    Perform parameters done.
    [Teardown]    run keyword and ignore error    coam.remove_delta    delta_id=${delta_id}

Get all UE pointer variable
    [Documentation]    Pixel range of X80 mobile phones
    ...                330b40af：（1530~1720）：1625
    ...                15be99f6：（1530~1720）：1625
    ...                ee5a4d5c：（1570~1770）：1670
    Set Suite Variable    ${home}    3
    Set Suite Variable    ${airplane}    953 1660
    Set Suite Variable    ${close_task}    523 272
    Set Suite Variable    ${Home_button}    3
    Set Suite Variable    ${swipe}    500 2050 500 800
    Set Suite Variable    ${open_iperf_location}    480 860
    Set Suite Variable    ${iperf_button}    720 312
    Set Suite Variable    ${iperf_space}    800 550
    Set Suite Variable    ${brand}    qti

attach X80 power ue
    [Arguments]    ${ue_index}    ${ue_type}=samsung    ${UE}=X80    ${gnb_index}=0
    log to console       Prepare UE
    @{ue_index_list}    create list    ${ue_index}
    FOR    ${item}   IN    @{ue_index_list}
        Run Keyword If    '${UE}'=='X80'    Get all UE pointer variable
        power_ue.Prepare UE    ue_index=${item}    ue_type=${ue_type}
        ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${item}    attach_mode=5G_NSA   ue_type=${ue_type}
        power_ue.Verify attach    ue_type=${ue_type}    ue_index=${item}   5Grach_ed=${5Grach_ed_0}    4G_check=False
        ...    gnb_index=${gnb_index}
    END
#    [Teardown]  Run Keyword And Ignore error    X80 detach multi power ue    ue_index=${ue_index}


X80 detach multi power ue
    [Timeout]    6min
    [Arguments]    ${ue_index}    ${ue_type}=samsung    ${UE}=X80
    log to console      UE Detach    console=yes
    @{ue_index_list}    create list    ${ue_index}
    FOR    ${item}    IN    @{ue_index_list}
        Run Keyword If    '${UE}'=='X80'    Get all UE pointer variable
        ...    ELSE    Get all Samsung pointer variable
        power_ue.UE Detach    ue_index=${item}    ue_type=${ue_type}
    END

attach X80 and check UL traffic
    [Arguments]    ${ue_index}    ${ul_throughput}    ${cells}    ${dl_throughput}=${None}
     ...    ${target_avg_percent_UL}=0.93   ${target_avg_percent_DL}=0.86
     Start Catch TCPDUMP SCTP Log 13388    filename=Tcpdump_X80.pcap
     attach X80 power ue    ue_index=${ue_index}
     Stop And Copy TCPDUMP To UTE 13388    filename=Tcpdump_X80.pcap
     UE Start Traffic    ue_index=${ue_index}    ue_type=samsung    ul_throughput=${ul_throughput}M    dl_throughput=${dl_throughput}M
     sleep    3s
     Check Throught From Asslog    ul_list=${cells}    dl_list=${cells}     ul_tp=${ul_throughput}    dl_tp=${dl_throughput}
     ...    target_avg_percent_UL=${target_avg_percent_UL}   target_avg_percent_DL=${target_avg_percent_DL}
     Pcap chang to txt    pcap_name=Tcpdump_X80.pcap    text_name=Tcpdump_X80.txt
     ${rnti_X80}    get_rnti_and_ca_info    txt_file_path=${OUTPUT_DIR}/${TEST NAME}/Tcpdump_X80.txt
     [Return]    ${rnti_X80}

#     UE Stop Traffic    ue_index=${ue_index}    ue_type=samsung
#    [Teardown]  Run Keyword And Ignore error    X80 detach multi power ue    ue_index=${ue_index}

Start Catch TCPDUMP SCTP Log 13388
    [Arguments]    ${filename}   ${time}=3s    ${connection}=GNB_SSH
    Log To Console    Start Catch Trace Log
    ssh.Connect to    hostname=${gNB_ip}    username=${gNB_ssh_username}   password=${gNB_ssh_password}    alias=${connection}
    sleep    2s
    ${pid_list}    wait until keyword succeeds    1min    2s    _get_PID 13388    connection=${connection}
    ...    command=ps -ef | grep tcpdump | grep -v grep|awk '{print $2}'
    ${index}    Get Length    ${pid_list}
    Log To Console    kill PID
    Run Keyword If    ${index}!=${0}    kill PID    pid_list=${pid_list}    connection=${connection}
#    ssh.send_command    command=tcpdump -t sctp -i any -w /tmp/${filename} &   connection=${connection}
    ssh.send_command    command=tcpdump sctp -i any -w /tmp/${filename} &   connection=${connection}
    sleep    ${time}
    [Teardown]    ssh.disconnect    connection=${connection}

_get_PID 13388
    [Arguments]    ${connection}    ${command}
    Log To Console    Get PID
    ssh.send_command    command=${command}   connection=${connection}
    ${PID}    ssh.read output    connection=${connection}
    ${pid_list}    Split String     ${PID}    \n
    [Return]    ${pid_list}

kill PID
    [Arguments]    ${connection}    ${pid_list}
    FOR    ${item}  IN    @{pid_list}
        ssh.send_command    command=kill -9 ${item}    connection=${connection}
    END

Stop And Copy TCPDUMP To UTE 13388
    [Arguments]    ${filename}    ${time}=10s     ${connection}=GNB_SSH
    Log To Console    Stop And Copy Log To UTE
    Create Directory    ${OUTPUT_DIR}/${TEST NAME}/
    ssh.Connect to    hostname=${gNB_ip}    username=${gNB_ssh_username}   password=${gNB_ssh_password}    alias=${connection}
    sleep    2s
    ${pid_list}    wait until keyword succeeds    1min    2s    _get_PID 13388    connection=${connection}
    ...    command=ps -ef | grep tcpdump | grep -v grep|awk '{print $2}'
    ${index}    Get Length    ${pid_list}
    Log To Console    kill PID
    Run Keyword If    ${index}!=${0}    kill PID    pid_list=${pid_list}    connection=${connection}
    Log To Console    download file to local
    ssh.download_file    remote_path=/tmp/${filename}    local_path=${OUTPUT_DIR}/${TEST NAME}/${filename}    connection=${connection}
    sleep    ${time}
    [Return]    ${OUTPUT_DIR}/${TEST NAME}/${filename}
    [Teardown]    ssh.disconnect    connection=${connection}

########################Start_BTSLOG_check###########################
BTSLOG Start btslog on remote machine
    [Arguments]    ${name}=btslog    ${bts_logs_dir}=/tmp/btslog2    ${alias}=ute
    csn.Connect to    hostname=${UTE_ADDRESS}   username=${UTE_USERNAME}    password=${UTE_PASSWORD}    alias=${alias}
    csn.Send Command  command=rm -rf /tmp/btslog2    connection=ute
    sleep    1s
    csn.send_command  command=if [ ! -d ${bts_logs_dir} ]; then mkdir ${bts_logs_dir}; else rm ${bts_logs_dir}/*; fi    connection=${alias}
    &{executor}=    create dictionary    host=${UTE_ADDRESS}    user=${UTE_USERNAME}    password=${UTE_PASSWORD}
    btslog.create_btslog_collector    name=${name}    log_dir=${bts_logs_dir}    executor=${executor}
    core.setup_collectors        names=${name}
    core.start_collectors        names=${name}
    btslog.set_suite_alias       ${name}

Stop BTSLOG Collect btslog on remote machine
    [Arguments]   ${name}=btslog
    core.stop_collectors         names=${name}
    Wait until keyword succeeds  3x  3s    core.collect_collectors      names=${name}
    core.teardown_collectors     names=${name}
    [Teardown]  Run Keyword And Ignore error    Csn.Disconnect	connection=ute



Check Btslog
    [Arguments]    ${rnti}    ${alias}=ute    ${CON_True}=False
#    ...    ${command}=grep "state:CGACTIVATED, rnti: ${rnti}"
    ...    ${btslog_path}=${OUTPUTDIR}/${SUITENAME}/${TESTNAME}/btslog
    ${command_1}   Set Variable  grep "state:CGACTIVATED, rnti: ${rnti}"
    ${command_2}   Set Variable  grep "state:CGCONFIGURED, rnti: ${rnti}"
    ${command}  Set Variable If  "${CON_True}"=="False"   ${command_1}    ${command_2}
#    ${command}   Set Variable  grep "state:CGACTIVATED, rnti: ${rnti}"
    csn.Connect to     hostname=${UTE_ADDRESS}   username=${UTE_USERNAME}    password=${UTE_PASSWORD}  alias=${alias}
    sleep    1s
    csn.execute    command=tar zxvf ${btslog_path}/syslog_files.tgz -C ${btslog_path}/    connection=${alias}
    sleep    1s
    csn.execute    command=cd ${btslog_path}; mv *.LOG ${btslog_path}/bts_log.log    connection=${alias}
    sleep    1s
    csn.Send Command  command=cat ${btslog_path}/bts_log.log|${command}    connection=ute
    sleep    1s
    ${data}    csn.Read Output    connection=ute
    ${data}    strip_string    ${data}
    csn.Send Command  command=rm -rf /tmp/btslog2    connection=ute
    sleep    1s
    [Return]    ${data}
    [Teardown]    csn.Disconnect   connection=ute

########################[1]CB013388_C_1_Online_enable_actULCgType2_success_TDD_step###########################