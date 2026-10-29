*** Settings ***
Documentation
...   author: zheyuan.chen@nokia-sbell.com
...   contact: zheyuan.chen@nokia-sbell.com

Library    taf.transport.ssh            WITH NAME    ssh
Library    taf.collectors.core          WITH NAME    core
Library    taf.collectors.tcpdump       WITH NAME    tcpdump
Library    taf.analyzer.pdml            WITH NAME    cpdml
Library    taf.sbts.oam.coam.admin       WITH NAME    coam
Library    taf.collectors.btslog        WITH NAME    btslog
Library    String
Library    Collections
Library    OperatingSystem
Library    Process
Library    XML
Library    DateTime
Library    Telnet
Resource    ./7876A_variables.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot

*** Variables ***
${default_scf_path}     ${CURDIR}/../../../../../../commissionings/HGZ/${testline_name}/
${luashark_path}    /opt/ute/luashark/luashark_script/generated_luashark
${LOG_PATH}    ${output_dir}

*** Keywords ***
Rest Login DU
    [Arguments]    ${ip_address}=${DU_OAM_IP}    ${username}=${DU_OAM_WEBUI_USER}
    ...    ${password}=${DU_OAM_WEBUI_PASSWORD}    ${alias}=default
    [Documentation]   Rest Login DU
    Connect to gnb coam via ssl    bts_host=${ip_address}    username=${username}    password=${password}    connection=${alias}
    ${connection}    set variable    ${alias}
    [Return]    ${connection}

Rest Logout DU
    [Arguments]  ${alias}=default
    [Documentation]   Rest Logout DU
    coam.Teardown    connection=${alias}

Check BTS Should Be Normal
    [Arguments]    ${all_cell_info}=${all_cell_info}
    Log To Console  Check BTS Should Be Normal
    Rest Login DU
    Wait Until BTS Should Be Normal    all_cell_info=${all_cell_info}
    [Teardown]   Run Keyword And Ignore Error   Rest Logout DU

Wait Until BTS Should Be Normal
    [Arguments]   ${all_cell_info}=${all_cell_info}    ${retry}=1000s    ${retry_interval}=10s
    [Documentation]   Wait Until CBTS Status Should Be Normal, if CBTS status is abnormal during retry time,
    Wait Until Keyword Succeeds   ${retry}     ${retry_interval}    Verify all cells should be onair    connection=default

Gnb Cell Should Be Onair
    [Arguments]    ${all_cell_info}=${all_cell_info}    ${alias}=default    ${cell_type }=nr
    [Documentation]  Gnb Cell Should Be Onair, check method is via REST
    ${status}      coam.Get_Bts_Statuses   connection=${alias}
    ${operationalState}    Get From Dictionary    ${status}    operationalState
    should be equal as strings    ${operationalState}    Enabled    ignore_case=${True}
    ${blockingState}   Get From Dictionary    ${status}    blockingState
    should be equal as strings    ${blockingState}    Unblocked    ignore_case=${True}
    ${proceduralState}   Get From Dictionary    ${status}   proceduralState
    should be equal as strings    ${proceduralState}    OnAir    ignore_case=${True}
    #cell info
    ${cell_status}     coam.Get_Cells_Info   cell_type=${cell_type}    connection=${alias}
    FOR    ${item}    IN    @{all_cell_info}
        ${Status}    Get From Dictionary    ${cell_status[${item}]}    status
        ${tmp}   Get From Dictionary    ${status}    operationalState
        should be equal as strings    ${tmp}    Enabled    ignore_case=${True}
        ${tmp}   Get From Dictionary    ${status}  administrativeState
        should be equal as strings    ${tmp}    Unlocked    ignore_case=${True}
        ${tmp}   Get From Dictionary    ${status}  blockingState
        should be equal as strings    ${tmp}    Unblocked    ignore_case=${True}
        #${tmp}   Get From Dictionary    ${status}  usageState
        #should be equal as strings    ${tmp}    Active    ignore_case=${True}
    END

suite setup to prepare default scf
    [Arguments]    ${SBTS_scf_name}    ${22R3_scf_name}    ${22R2_scf_name}
    Log To Console    Set Default Scf
    ${connection}    Rest Login DU
    ${version}    coam.get_sw_version    connection=${connection}
    ${version_list}    split string    ${version}    _
    ${if_common_load}     run keyword and return status    should contain    ${version_list[2]}    9999
    ${if_22R3_load}    run keyword and return status    should contain    ${version_list[0]}    SBTS22R3
    ${if_22R2_load}    run keyword and return status    should contain    ${version_list[0]}    SBTS22R2
    ${default_scf}    set variable if    ${if_common_load}    ${default_scf_path}${SBTS_scf_name}
    ...    ${if_22R3_load}    ${default_scf_path}${22R3_scf_name}
    ...    ${if_22R2_load}    ${default_scf_path}${22R2_scf_name}
    log to console   ${default_scf}
    [Teardown]    Run keyword and ignore error    coam.teardown      connection=${connection}
    [Return]    ${default_scf}

Commission Default SCF
    [Arguments]    ${default_scf}   ${ip_address}=${DU_OAM_IP}
    Log To Console    Commission Default SCF
    ${connection}    Rest Login DU    ip_address=${ip_address}
    COAM Commission with scf file    scf_file_path=${default_scf}    connection=${connection}
    Wait Until BTS Should Be Normal
    [Teardown]    Rest Logout DU

Judge Version
    ${connection}    Rest Login DU
    ${version}    coam.get_sw_version    connection=${connection}
    ${version_list}    split string    ${version}    _
    ${if_22R3_version}     run keyword and return status    should contain    ${version_list[0]}    SBTS22R3
    [Return]    ${if_22R3_version}
    [Teardown]    Run keyword and ignore error    coam.teardown      connection=${connection}

Power Off RU
    [Arguments]    ${model}    ${RU_PDU_IP}    ${RU_PDU_PORT}
    Log To Console    Power Off RU
    pdu.Setup Pdu    model=${model}    host=${RU_PDU_IP}    alias=pdu_alias
    pdu.Power Off    port=${RU_PDU_PORT}    pdu_device=pdu_alias
    pdu.Get Port Status    port=${RU_PDU_PORT}    pdu_device=pdu_alias
    Sleep    15s

Power On RU
    [Arguments]    ${model}    ${RU_PDU_IP}    ${RU_PDU_PORT}
    Log To Console    Power On RU
    pdu.Setup Pdu    model=${model}    host=${RU_PDU_IP}    alias=pdu_alias
    pdu.Power On    port=${RU_PDU_PORT}    pdu_device=pdu_alias
    pdu.Get Port Status    port=${RU_PDU_PORT}    pdu_device=pdu_alias
    sleep    3s

Check Expected Alarm
    [Arguments]    ${RMOD_index}    ${faultID}=${10}
    ${connection}    Rest Login DU
    Log To Console    Check FaultID
    ${alarm_info}    coam.get_active_alarms    timeout=60    connection=${connection}
    ${dic_attribute}    set variable    ${None}
    FOR    ${item}    IN    @{alarm_info}
        ${fault_id_dic}    get from dictionary    ${item}    additionalFaultID
        ${dic_objiectname}    run keyword if    '${fault_id_dic}' == '${faultID}'
        ...    get from dictionary    ${item}    configObjectName
        exit for loop if    '${fault_id_dic}' == '${faultID}'
    END
    should contain    ${dic_objiectname}    ${BTS_ID}/EQM-1/APEQM-1/RMOD-${RMOD_index}
    [Teardown]    Rest Logout DU

Check Fiber Status
    [Arguments]    ${expected_RU}    ${expect_admin_status}=Unlocked    ${expect_operate_status}=Enabled
    ...    ${expect_usage_status}=Active    ${expect_procedure_status}=configured
    Log To Console    Check Fiber Status
    ${connection}    Rest Login DU
    ${rf_list}    coam.get_frm    connection=${connection}
    FOR    ${item}    IN RANGE    ${5}
        ${serial_number}    get from dictionary    ${rf_list[${item}]}    serialNumber
        ${Fiber_status}    run keyword if    '${serial_number}' == '${expected_RU}'
        ...    get from dictionary    ${rf_list[${item}]}    status
        exit for loop if    '${serial_number}' == '${expected_RU}'
    END
    ${admin_status}    get from dictionary    ${Fiber_status}    administrativeState
    should be equal as strings   ${admin_status}    ${expect_admin_status}    ignore_case=${True}
    ${operate_status}    get from dictionary    ${Fiber_status}    operationalState
    should be equal as strings    ${operate_status}    ${expect_operate_status}    ignore_case=${True}
    #${usage_status}    get from dictionary    ${Fiber_status}    usageState
    #should be equal as strings    ${usage_status}    ${expect_usage_status}    ignore_case=${True}
    ${procedure_status}    get from dictionary    ${Fiber_status}    proceduralStatus
    should be equal as strings    ${procedure_status}    ${expect_procedure_status}    ignore_case=${True}
    [Teardown]    Rest Logout DU

Check Cells Status
    [Arguments]    ${cell_info}    ${operational_status}=Enabled    ${usage_status}=Active
    Log To Console    Check Cells Status
    Rest Login DU
    ${cell_status}     coam.Get_Cells_Info   cell_type=nr
    FOR    ${item}    IN    @{all_cell_info}
        ${gcellid}    Get From Dictionary    ${cell_status[${item}]}    globalCellId
        ${gcellid_status}    run keyword and return status    list should contain value    ${cell_info}    ${gcellid}
        run keyword if    ${gcellid_status}    _check_cell_status    cells_status=${cell_status[${item}]}
        ...    operational_status=${operational_status}    usage_status=${usage_status}
    END
    [Teardown]    Rest Logout DU

_check_cell_status
    [Arguments]    ${cells_status}    ${operational_status}    ${usage_status}
    ${Status}    Get From Dictionary    ${cells_status}    status
    ${tmp}   Get From Dictionary    ${status}    operationalState
    should be equal as strings    ${tmp}    ${operational_status}    ignore_case=${True}
    #${tmp}   Get From Dictionary    ${status}   usageState
    #should be equal as strings    ${tmp}    ${usage_status}    ignore_case=${True}

Reset BTS And Wait Until On Air
    Log To Console    Reset BTS And Wait Until On Air
    Rest Login DU
    sleep    2s
    coam.reset_site
    Log To Console    wait until bts should be normal
    wait until bts should be normal
    [Teardown]    Rest Logout DU

Lock And Unlock BTS And Wait Until On Air
    [Arguments]    ${NRDU_idx}=${1}    ${alias}=default
    Log To Console    Lock BTS
    Rest Login DU
    coam.lock_bts    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRDU-${NRDU_idx}    connection=${alias}
    sleep    5s
    Log To Console    Unlock BTS
    coam.unlock_bts    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRDU-${NRDU_idx}    connection=${alias}
    Log To Console    wait until bts should be normal
    wait until bts should be normal
    [Teardown]    Rest Logout DU

Check if Unexpected History Alarm Exist
    ${fault_id_list}    Get BTS History Alarm FaultID
    return from keyword if    '${fault_id_list}' == '[]'
    ${ignore_fault}    set variable    ${ignore_history_fault}
    FOR    ${item}    IN    @{fault_id_list}
        run keyword and continue on failure    list should contain value    ${ignore_fault}    ${item}
    END

Get BTS History Alarm FaultID
    ${connection}    Rest Login DU
    Log To Console    get history alarm faultid
    ${alarm_info}    coam.get_historic_alarms    timeout=60    connection=${connection}
    ${fault_id_list}    create list
    FOR    ${item}    IN    @{alarm_info}
        ${fault_id_dic}    get from dictionary    ${item}    additionalFaultID
        append to list    ${fault_id_list}    ${fault_id_dic}
    END
    sort list    ${fault_id_list}
    [Return]    ${fault_id_list}
    [Teardown]    Rest Logout DU

Check No Expected Alarm
    [Arguments]    ${fault_id}=${10}
    Log To Console    Check No Expected Alarm
    ${connection}    Rest Login DU
    ${alarm_info}    coam.get_active_alarms    timeout=60    connection=${connection}
    ${fault_id_list}    create list
    FOR    ${item}    IN    @{alarm_info}
        ${fault_id_dic}    get from dictionary    ${item}    additionalFaultID
        append to list    ${fault_id_list}    ${fault_id_dic}
    END
    sort list    ${fault_id_list}
    list should not contain value    ${fault_id_list}    ${fault_id}
    [Teardown]    Rest Logout DU

Restart BBMOD
    [Arguments]    ${BBMOD_idx}    ${alias}=default
    Log To Console    Restart BBMOD
    Rest Login DU
    coam.reset_unit    dist_name=MRBTS-${BTS_ID}/EQM-1/APEQM-1/CABINET-1/BBMOD-${BBMOD_idx}    reset_type=Warm    force_radio_reset=${True}
    ...    timeout=300s    connection=${alias}
    [Teardown]    Rest Logout DU

Reset RMOD
    [Arguments]    ${RU_index}
    Log To Console    Reset RMOD
    Rest Login DU
    sleep    2s
    coam.reset_unit    dist_name=MRBTS-${BTS_ID}/EQM-1/APEQM-1/RMOD-${RU_index}    force_radio_reset=${True}    timeout=${300}
    [Teardown]    Rest Logout DU

Lock RMOD
    [Arguments]    ${RMOD_idx}    ${ip_address}=${DU_OAM_IP}    ${BTS_ID}=${BTS_ID}
    Rest Login DU    ip_address=${ip_address}
    sleep    2s
    Log To Console    Lock RMOD
    run keyword and continue on failure    coam.lock    dist_name=MRBTS-${BTS_ID}/EQM-1/APEQM-1/RMOD-${RMOD_idx}    timeout=${60}
    sleep    5s
    [Teardown]    Rest Logout DU

Unlock RMOD
    [Arguments]    ${RMOD_idx}    ${ip_address}=${DU_OAM_IP}    ${BTS_ID}=${BTS_ID}
    Rest Login DU    ip_address=${ip_address}
    sleep    2s
    Log To Console    Unlock RMOD
    coam.unlock    dist_name=MRBTS-${BTS_ID}/EQM-1/APEQM-1/RMOD-${RMOD_idx}    timeout=${60}
    sleep    3s
    [Teardown]    Rest Logout DU

Lock Cellgroup
    [Arguments]    ${cellgrp_idx}    ${alias}=default
    Log To Console    Lock Cellgroup
    Rest Login DU
    coam.lock    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELLGRP-${cellgrp_idx}    timeout=60s    connection=${alias}
    sleep    25s
    [Teardown]    Rest Logout DU

Unlock Cellgroup
    [Arguments]    ${cellgrp_idx}    ${alias}=default
    Log To Console    Unlock Cellgroup
    Rest Login DU
    coam.unlock    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELLGRP-${cellgrp_idx}    timeout=60s    connection=${alias}
    sleep    3s
    [Teardown]    Rest Logout DU

Save Snapshot Log
    [Arguments]    ${alias}=default    ${timeout}=600s
    Log To Console    Save Snapshot Log
    Rest Login DU
    ${timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    ${snapshot_file_path}    set variable    ${CURDIR}/../snapshot/${timestamp}_snapshot.zip
    coam.get_snapshot    target_file_name=${snapshot_file_path}    connection=${alias}    timeout=${timeout}
    sleep    10s
    [Return]    ${snapshot_file_path}
    [Teardown]    Rest Logout DU

Single UE Attach And Start Traffic And Check Throughput
    [Arguments]    ${tp_nrcell_list}    ${ue_index}=${0}    ${port}=${0}
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
    Log To Console    UE Attach
    ${5Grach_ed_0}    power_ue.UE Attach    ue_type=${ue_type}    attach_mode=5G_NSA    ue_index=${ue_index}
    Log To Console    Verify attach
    power_ue.Verify attach    ue_type=${ue_type}    ue_index=${ue_index}    5Grach_ed=${5Grach_ed_0}    4G_check=False
    sleep    60s
    Log To Console    Start Traffic
    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=100M    ue_index=${ue_index}
    ...    duration=200    ue_mode=NSA    iperf_port=${IPERF_portlist}[${port}]    iperf_type=via_command    process_num=${1}
    sleep    5s
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=100M    ue_index=${ue_index}
    ...    duration=200    ue_mode=NSA    iperf_port=${IPERF_portlist}[${port}]    iperf_type=via_command    process_num=${1}
    sleep    20s
    Log To Console    Check Throughput
    ${log_path}    power_ue.Collect Tput    ue_type=${ue_type}    duration=100s    ignore_time=10s
    ${cell_list_0}    set variable    ${tp_nrcell_list[0:1]}
    ${cell_list_1}    set variable    ${tp_nrcell_list[1:4]}
    ${status_0}    run keyword and return status    power_ue.Check Bi Tput    ue_type=${ue_type}    log=${log_path}    cells=${cell_list_0}
    ...    ultarget_throughput=5    dltarget_throughput=5
    ${status_1}    run keyword and return status    power_ue.Check Bi Tput    ue_type=${ue_type}    log=${log_path}    cells=${cell_list_1}
    ...    ultarget_throughput=5    dltarget_throughput=5
    run keyword and continue on failure    should be true    ${status_0} or ${status_1}
    Log To Console    Stop traffic
    run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    ue_index=${ue_index}
    ...    iperf_port=${IPERF_portlist}[${port}]    ue_mode=NSA
    run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    ue_index=${ue_index}
    ...    iperf_port=${IPERF_portlist}[${port}]    ue_mode=NSA
    [Teardown]    run keyword and ignore error    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}

UE Attach Success
    [Arguments]    ${ue_index}=${0}
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
    run keyword and ignore error    spark.enable_ue_data_service    ue_alias=UE_${ue_index}
    Log To Console    UE Attach
    ${5Grach_ed_0}    power_ue.UE Attach    ue_type=${ue_type}    attach_mode=5G_NSA    ue_index=${ue_index}
    Log To Console    Verify attach
    power_ue.Verify attach    ue_type=${ue_type}    ue_index=${ue_index}
    ...    5Grach_ed=${5Grach_ed_0}    4G_check=False
    [Teardown]    run keyword and ignore error    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}

UE Attach Failed
    [Arguments]    ${ue_index}=${0}
    Log To Console    UE Attach Failed
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
    run keyword and ignore error    spark.enable_ue_data_service    ue_alias=UE_${ue_index}
    Log To Console    UE Attach
    ${5Grach_ed_0}   power_ue.UE Attach    ue_type=${ue_type}    attach_mode=5G_NSA    ue_index=${ue_index}
    Log To Console    Verify attach Failed
    run keyword and expect error    *5G RACH still not success after retry*    power_ue.Verify attach    ue_type=${ue_type}
    ...    ue_index=${ue_index}    5Grach_ed=${5Grach_ed_0}    4G_check=False
    [Teardown]    run keyword and ignore error    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}

Get NR_CELL PUSCH Counter
    [Arguments]    ${nrcell_index}    ${object}    ${counter_id}    ${alias}=default
    Log To Console    Get NR_CELL PUSCH Counter
    Rest Login DU
    ${result}    coam.get_PM_counters    couter_ids=${counter_id}    connection=${alias}
    ${counter_list}    get dictionary values    ${result['BTS']['CELLS']['NRCELL-${nrcell_index}']['${object}']['${counter_id}']}
    [Return]    ${counter_list}
    [Teardown]    Rest Logout DU

Check BTS Counters
    [Arguments]    ${BTS_counter_list}    ${nrcell_index}
    Log To Console   sleep 15min
    sleep    15min
    ${counter_dictionary}     create dictionary    M55302C00000=NULHQ     M55300C00000=NDLHQ
    ${counter_list1}    create list
    FOR    ${item}    IN    @{BTS_counter_list}
        ${object}    get from dictionary    ${counter_dictionary}   ${item}
        ${counter_list2}    Get NR_CELL PUSCH Counter    nrcell_index=${nrcell_index}    object=${object}    counter_id=${item}
        append to list    ${counter_list1}    ${counter_list2[-1]}
    END
    ${status}    run keyword and return status    list should contain value    ${counter_list1}    0
    run keyword if    ${status}   sleep   15min
    Log To Console    Check Counter
    FOR    ${item}    IN    @{BTS_counter_list}
        ${object}    get from dictionary    ${counter_dictionary}   ${item}
        ${counter_list}    Get NR_CELL PUSCH Counter    nrcell_index=${nrcell_index}    object=${object}    counter_id=${item}
        ${counter_list_length}    get length    ${counter_list}
        ${counter}    run keyword if    ${counter_list_length}>=2    evaluate    ${counter_list[-1]} + ${counter_list[-2]}
        ...    ELSE     evaluate    ${counter_list[-1]}
        should be true    ${counter} > ${0}
    END

Get PID
    [Arguments]    ${connection}    ${command}
    Log To Console    Get PID
    ssh.send_command    command=${command}   connection=${connection}
    ${PID}    ssh.read output    connection=${connection}
    ${PID}    strip_string    ${PID}
    should not be empty    ${PID}
    [Return]    ${PID}

Start Catch Trace Log And UE Attach
    [Arguments]    ${DU_OAM_IP}    ${connection}    ${command}   ${tp_nrcell_list}    ${ue_index}    ${port}
    Log To Console    Start Catch Trace Log
    ssh.Connect to    hostname=${DU_OAM_IP}    username=${DU_OAM_SSH_USERNAME}
    ...   password=${DU_OAM_SSH_PASSWORD}    alias=${connection}
    sleep    2s
    ssh.send_command    command=${command}   connection=${connection}
    Single UE Attach And Start Traffic And Check Throughput    tp_nrcell_list=${tp_nrcell_list}    ue_index=${ue_index}    port=${port}
    [Return]    ${connection}

Stop And Copy Log To UTE
    [Arguments]    ${connection}    ${filename}
    Log To Console    Stop And Copy Log To UTE
    ${PID}    wait until keyword succeeds    1min    2s    Get PID    connection=${connection}
    ...    command=ps -ef | grep tcpdump | grep -v grep | tail -n 1 |awk '{print $2}'
    ssh.send_command    command=kill -9 ${PID}    connection=${connection}
    ssh.download_file    remote_path=/tmp/${filename}    local_path=${LOG_PATH}/${filename}    connection=${connection}
    sleep    10s
    [Teardown]    ssh.disconnect    connection=${connection}

Convert Pcap To Text UTE
    [Arguments]  ${source}   ${target}   ${filter}   ${connection}
    Log To Console    Convert pcap to text
    ssh.send_command
    ...    command=tshark -X lua_script:${luashark_path} -V -r ${source} -T text -Y ${filter} > ${target}
    ...    connection=${connection}
    ssh.await execution end    connection=${connection}  timeout=30min

Grep Text Content
    [Arguments]    ${txt_filename}    ${item}    ${connection}
    ssh.send_command    command=cat ${LOG_PATH}/${txt_filename} | grep '${item}'    connection=${connection}
    sleep    2s
    ${output}    ssh.read output    connection=UTE
    [Return]    ${output}

Check eNB Detach Succeed
    [Arguments]    ${pcap_filename}    ${txt_filename}
    Log To Console    Check eNB Detach Succeed
    ssh.Connect to    hostname=${UTE_ADDRESS}    username=${UTE_USERNAME}
    ...   password=${UTE_PASSWORD}    alias=UTE
    ${filter1}=    CATENATE  s1ap.procedureCode == 23
    Check Sigalling    filter=${filter1}    pcap_filename=${pcap_filename}    txt_filename=${txt_filename}    item=UEContextReleaseCommand
    Check Sigalling    filter=${filter1}    pcap_filename=${pcap_filename}    txt_filename=${txt_filename}    item=UEContextReleaseComplete
    ${filter2}=    CATENATE  x2ap.procedureCode == 31
    Check Sigalling    filter=${filter2}    pcap_filename=${pcap_filename}    txt_filename=${txt_filename}    item=SgNBReleaseRequest
    Check Sigalling    filter=${filter2}    pcap_filename=${pcap_filename}    txt_filename=${txt_filename}
    ...    item=SgNBReleaseRequestAcknowledge
    ${filter3}=    CATENATE  x2ap.procedureCode == 5
    Check Sigalling    filter=${filter3}    pcap_filename=${pcap_filename}    txt_filename=${txt_filename}    item=UEContextRelease
    ${filter4}=    CATENATE  x2ap.procedureCode == 4
    Check Sigalling    filter=${filter4}    pcap_filename=${pcap_filename}    txt_filename=${txt_filename}    item=SNStatusTransfer
    [Teardown]    ssh.disconnect    connection=UTE

Check Sigalling
    [Arguments]    ${filter}    ${pcap_filename}    ${txt_filename}    ${item}
    Convert Pcap To Text UTE    source=${LOG_PATH}/${pcap_filename}
    ...  target=${LOG_PATH}/${txt_filename}    filter="${filter}"    connection=UTE
    ${output}    Grep Text Content    txt_filename=${txt_filename}    item=${item}   connection=UTE
    should not be empty    ${output}

Change eNB Nrcellid
    [Arguments]    ${Actual_value}    ${ip_address}=${eNB2_OAM_IP}
    Log To Console    Change eNB Nrcellid
    wait until keyword succeeds    10min    10s    Rest Login DU    ip_address=${ip_address}
    ${dict}    create dictionary    parameterName=carrierFreqNrCell    operation=update    value=${Actual_value}
    ${list}    create list    ${dict}
    coam.perform_object_recommissioning    dist_name=MRBTS-${eNB2_BTS_ID}/LNBTS-${eNB2_NRBTS_ID}/NRDCDPR-0/ENDCDMEASCONF-2
    ...    parameter=${list}    operation=update     skip_parameter_relation_errors=${True}    should_activate=${True}
    sleep    10s
    [Teardown]    Rest Logout DU

Reboot UE by ADB Command
    [Arguments]    ${ue_index}=${1}    ${time}=3min    ${connection}=cygwin
    Log To Console    reboot UE by adb command
    ssh.Connect to    hostname=${PC_addr}    username=${PC_username}    password=${PC_password}    alias=${connection}
    ssh.Send Command  command=adb reboot ${tl.ues[${ue_index}].serial_number}    connection=${connection}
    sleep    ${time}
    ssh.Send Command  command=adb devices    connection=${connection}
    ${data}    ssh.Read Output    connection=${connection}
    ${data}    strip_string    ${data}
    should contain    ${data}    ${tl.ues[${ue_index}].serial_number}
    [Teardown]    ssh.disconnect    connection=${connection}