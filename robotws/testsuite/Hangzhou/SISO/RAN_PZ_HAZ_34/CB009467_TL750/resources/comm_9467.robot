*** Settings ***
Documentation
...   author: kaijia.chen@nokia-sbell.com
...   contact: kaijia.chen@nokia-sbell.com

Library    taf.transport.ssh            WITH NAME    ssh
Library    taf.collectors.core          WITH NAME    core
Library    taf.collectors.tcpdump       WITH NAME    tcpdump
Library    taf.analyzer.pdml            WITH NAME    cpdml
Library    taf.sbts.oam.coam.admin      WITH NAME    coam
Library    taf.collectors.btslog        WITH NAME    btslog
Library    String
Library    Collections
Library    OperatingSystem
Library    Process
Library    XML
Library    DateTime
Library    Telnet
Resource    ./9467_variables.robot
Resource    ../../../../resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    ../../../../resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot

*** Variables ***
${testline_name}        7_5_UTE5G402T750
${default_scf_path}     ${CURDIR}/../../../../../../commissionings/HGZ/${testline_name}/
${LOG_PATH}    ${output_dir}

*** Keywords ***
SBTS Login
    [Arguments]    ${ip_address}=${DU_OAM_IP}    ${username}=${DU_OAM_WEBUI_USER}
    ...    ${password}=${DU_OAM_WEBUI_PASSWORD}    ${alias}=default
    [Documentation]   Rest Login DU
    Connect to gnb coam via ssl    bts_host=${ip_address}    username=${username}    password=${password}    connection=${alias}
    ${connection}    set variable    ${alias}
    [Return]    ${connection}

SBTS Logout
    [Arguments]   ${alias}=default
    [Documentation]   SBTS Logout
    coam.Teardown    connection=${alias}

WEBUI Login
    [Arguments]      ${virtual_enable}=${True}     ${version}=5G21B
    [Documentation]   WEBUI Login
    Log To Console  START:WEBUI Login
    Log To Console  Try to login...
    selenium_coam.Enable_Virtual_Display
    selenium_coam.Login    url=${DU_OAM_WEBUI_URL}    username=${DU_OAM_WEBUI_USER}   password=${DU_OAM_WEBUI_PASSWORD}
    ...     version=${version}
    Log To Console  Login successfully...
    Run Keyword And Ignore Error      selenium_coam.Disable_Message_Box
    Sleep    15s
    selenium_coam.disable_screen_lock
    Log To Console  END:WEBUI Login!

WEBUI Logout
    [Arguments]     ${virtual_disable}=${True}
    [Documentation]   WEBUI Logout
    Log To Console  Try to logout...
    Run Keyword If      ${virtual_disable}    Run Keyword And Ignore Error    selenium_coam.Enable_Virtual_Display
    Run Keyword And Ignore Error  selenium_coam.Logout
    Log To Console  Logout successfully...
    Run Keyword If      ${virtual_disable}    Run Keyword And Ignore Error    selenium_coam.Disable_Virtual_Display
    Sleep    3s
    Log To Console  END:WEBUI Logout!

Check BTS Should Be Normal
    Log To Console  Check BTS Should Be Normal
    SBTS Login
    Wait Until BTS Should Be Normal
    [Teardown]   Run Keyword And Ignore Error   SBTS Logout

Check BTS Should Be Normal after sector addition/deletion
    Log To Console  Check BTS Should Be Normal
    SBTS Login
    Wait Until BTS Should Be Normal after sector addition/deletion
    [Teardown]   Run Keyword And Ignore Error   SBTS Logout

Wait Until BTS Should Be Normal
    [Arguments]    ${retry}=1000s    ${retry_interval}=10s
    [Documentation]   Wait Until CBTS Status Should Be Normal, if CBTS status is abnormal during retry time,
    Wait Until Keyword Succeeds   ${retry}     ${retry_interval}    Verify all cells should be onair    connection=default

Wait Until BTS Should Be Normal after sector addition/deletion
    [Arguments]    ${retry}=600s    ${retry_interval}=10s
    [Documentation]   Wait Until CBTS Status Should Be Normal, if CBTS status is abnormal during retry time,
    Wait Until Keyword Succeeds   ${retry}     ${retry_interval}    Verify all cells should be onair    connection=default

Gnb Cell Should Be Onair
    [Arguments]    ${alias}=default    ${cell_type }=nr
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
    FOR    ${item}    IN    @{cell_status}
        ${Status}    Get From Dictionary    ${item}    status
        ${tmp}   Get From Dictionary    ${status}    operationalState
        should be equal as strings    ${tmp}    Enabled    ignore_case=${True}
        ${tmp}   Get From Dictionary    ${status}  administrativeState
        should be equal as strings    ${tmp}    Unlocked    ignore_case=${True}
        ${tmp}   Get From Dictionary    ${status}  blockingState
        should be equal as strings    ${tmp}    Unblocked    ignore_case=${True}
        ${tmp}   Get From Dictionary    ${status}  usageState
        should be equal as strings    ${tmp}    Active    ignore_case=${True}
    END

suite setup to prepare default scf
    [Arguments]    ${SBTS_scf_name}    ${Branch_scf_name}    ${branch_version}=SBTS24R1
    Log To Console    Set Default Scf
    ${connection}    SBTS Login
    ${version}    coam.get_sw_version    connection=${connection}
    ${version_list}    split string    ${version}    _
    ${if_branch_load}     run keyword and return status    should contain    ${version_list[0]}    ${branch_version}
    ${default_scf}    set variable if    ${if_branch_load}    ${default_scf_path}${Branch_scf_name}
    ...    ${default_scf_path}${SBTS_scf_name}
    log to console   ${default_scf}
    [Teardown]    Run keyword and ignore error    coam.teardown      connection=${connection}
    [Return]    ${default_scf}

Commission Default SCF
    [Arguments]    ${default_scf}
    Log To Console    Commission Default SCF
    ${connection}    SBTS Login
    COAM Commission with scf file    scf_file_path=${default_scf}    connection=${connection}
    Wait Until BTS Should Be Normal
    [Teardown]    coam.Teardown   connection=${connection}

Judge Version If 24R1_version
    ${connection}    SBTS Login
    ${version}    coam.get_sw_version    connection=${connection}
    ${version_list}    split string    ${version}    _
    ${if_24R1_version}     run keyword and return status    should contain    ${version_list[0]}    SBTS24R1
    set suite variable    ${if_24R1_version}
    [Teardown]    Run keyword and ignore error    coam.teardown      connection=${connection}

block_cell
    [Arguments]    ${connection}=default   ${cell_idx}=${1}
    Log To Console    block cell
    coam.block    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_idx}    connection=${connection}
    sleep    3s

unblock_cell
    [Arguments]    ${connection}=default    ${cell_idx}=${1}
    Log To Console    unblock cell
    coam.unblock    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_idx}    connection=${connection}
    sleep    3s

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
    [Arguments]    ${faultID}    ${expected_alarmid}    ${expected_objectname}    ${connection}=default
    Log To Console    Check FaultID
    ${alarm_info}    coam.get_active_alarms    timeout=60    connection=${connection}
    ${dic_attribute}    set variable    ${None}
    FOR    ${item}    IN    @{alarm_info}
        ${fault_id_dic}    get from dictionary    ${item}    additionalFaultID
        ${alarm_id}    run keyword if    '${fault_id_dic}' == '${faultID}'
        ...    get from dictionary    ${item}    alarmId
        ${dic_objiectname}    run keyword if    '${fault_id_dic}' == '${faultID}'
        ...    get from dictionary    ${item}    configObjectName
        ${objectname_status}    run keyword and return status    should contain    ${dic_objiectname}    ${expected_objectname}
        exit for loop if    '${objectname_status}' == 'True'
    END
    should be true    '${alarm_id}' == '${expected_alarmid}'

Check RMOD Status
    [Arguments]    ${expected_RU}    ${connection}=default    ${expect_admin_status}=Unlocked
    ...    ${expect_operate_status}=Enabled    ${expect_usage_status}=Active    ${expect_procedure_status}=configured
    Log To Console    Check RMOD Status
    ${rf_list}    coam.get_frm    connection=${connection}
    FOR    ${item}    IN RANGE     ${5}
        ${serial_number}    get from dictionary    ${rf_list[${item}]}    serialNumber
        ${Fiber_status}    run keyword if    '${serial_number}' == '${expected_RU}'
        ...    get from dictionary    ${rf_list[${item}]}    status
        exit for loop if    '${serial_number}' == '${expected_RU}'
    END
    ${admin_status}    get from dictionary    ${Fiber_status}    administrativeState
    should be equal as strings   ${admin_status}    ${expect_admin_status}
    ${operate_status}    get from dictionary    ${Fiber_status}    operationalState
    should be equal as strings    ${operate_status}    ${expect_operate_status}
    ${usage_status}    get from dictionary    ${Fiber_status}    usageState
    should be equal as strings    ${usage_status}    ${expect_usage_status}
    ${procedure_status}    get from dictionary    ${Fiber_status}    proceduralStatus
    should be equal as strings    ${procedure_status}    ${expect_procedure_status}

Check Cells Status
    [Arguments]    ${cell_info}    ${all_cell_info}=${all_cell_info}    ${connection}=default    ${operational_status}=Enabled
    ...    ${usage_status}=Active    ${block_status}=Unblocked    ${lock_status}=Unlocked
    Log To Console    Check Cells Status
    ${cell_status}     coam.Get_Cells_Info   cell_type=nr    connection=${connection}
    FOR    ${item}    IN    @{all_cell_info}
        ${gcellid}    Get From Dictionary    ${cell_status[${item}]}    globalCellId
        ${gcellid_status}    run keyword and return status    list should contain value    ${cell_info}    ${gcellid}
        run keyword if    ${gcellid_status}    _check_cell_status    cells_status=${cell_status[${item}]}
        ...    operational_status=${operational_status}    usage_status=${usage_status}
        ...    block_status=${block_status}    lock_status=${lock_status}
    END

_check_cell_status
    [Arguments]    ${cells_status}    ${operational_status}    ${usage_status}    ${block_status}    ${lock_status}
    ${Status}    Get From Dictionary    ${cells_status}    status
    ${tmp}   Get From Dictionary    ${status}    operationalState
    should be equal as strings    ${tmp}    ${operational_status}    ignore_case=${True}
    ${tmp}   Get From Dictionary    ${status}   usageState
    should be equal as strings    ${tmp}    ${usage_status}
    ${tmp}   Get From Dictionary    ${status}   blockingState
    should be equal as strings    ${tmp}    ${block_status}
    ${tmp}   Get From Dictionary    ${status}   administrativeState
    should be equal as strings    ${tmp}    ${lock_status}

Reset BTS And Wait Until On Air
    [Arguments]    ${connection}=default
    Log To Console    Reset BTS And Wait Until On Air
    sleep    2s
    coam.reset_site    connection=${connection}
    Log To Console    wait until bts should be normal
    wait until bts should be normal    retry=648s

Reset BTS And Wait Until Login
    [Arguments]    ${connection}=default
    Log To Console    Reset BTS And Wait Until On Air
    sleep    2s
    SBTS Login
    coam.reset_site    connection=${connection}
    Log To Console    Try to login...
    wait until keyword succeeds    6min    10s    SBTS Login

Check if Unexpected History Alarm Exist
    ${fault_id_list}    Get BTS History Alarm FaultID
    return from keyword if    '${fault_id_list}' == '[]'
    ${ignore_fault}    set variable    ${ignore_history_fault}
    FOR    ${item}    IN    @{fault_id_list}
        run keyword and continue on failure    list should contain value    ${ignore_fault}    ${item}
    END

Get BTS History Alarm FaultID
    [Arguments]    ${connection}=default
    Log To Console    get history alarm faultid
    ${alarm_info}    coam.get_historic_alarms    timeout=60    connection=${connection}
    ${fault_id_list}    create list
    FOR    ${item}    IN    @{alarm_info}
        ${fault_id_dic}    get from dictionary    ${item}    additionalFaultID
        append to list    ${fault_id_list}    ${fault_id_dic}
    END
    sort list    ${fault_id_list}
    [Return]    ${fault_id_list}

Check No Expected Alarm
    [Arguments]    ${connection}=default    ${fault_id}=${10}
    Log To Console    Check No Expected Alarm
    ${alarm_info}    coam.get_active_alarms    timeout=60    connection=${connection}
    ${fault_id_list}    create list
    FOR    ${item}    IN    @{alarm_info}
        ${fault_id_dic}    get from dictionary    ${item}    additionalFaultID
        append to list    ${fault_id_list}    ${fault_id_dic}
    END
    sort list    ${fault_id_list}
    list should not contain value    ${fault_id_list}    ${fault_id}

Reset RMOD
    [Arguments]    ${RU_index}    ${connection}=default
    Log To Console    Reset RMOD
    sleep    2s
    coam.reset_unit    dist_name=MRBTS-${BTS_ID}/EQM-1/APEQM-1/RMOD-${RU_index}    force_radio_reset=${True}
    ...    timeout=${300}    connection=${connection}

Lock RMOD
    [Arguments]    ${RMOD_idx}    ${connection}=default
    sleep    2s
    Log To Console    Lock RMOD
    coam.lock    dist_name=MRBTS-${BTS_ID}/EQM-1/APEQM-1/RMOD-${RMOD_idx}    timeout=${60}    connection=${connection}
    sleep    5s

Unlock RMOD
    [Arguments]    ${RMOD_idx}    ${connection}=default
    Log To Console    Unlock RMOD
    coam.unlock    dist_name=MRBTS-${BTS_ID}/EQM-1/APEQM-1/RMOD-${RMOD_idx}    timeout=${60}    connection=${connection}
    sleep    5s

Save Snapshot Log
    [Arguments]    ${connection}=default    ${timeout}=600s
    Log To Console    Save Snapshot Log
    ${timestamp}    DateTime.Get current date    result_format=%Y%m%d%H%M%S
    ${snapshot_file_path}    set variable    ${CURDIR}/../snapshot/${timestamp}_snapshot.zip
    coam.get_snapshot    target_file_name=${snapshot_file_path}    connection=${connection}    timeout=${timeout}
    sleep    10s
    [Return]    ${snapshot_file_path}

Single UE Attach And Start Traffic And Check Throughput
    [Arguments]    ${ue_index}=${0}    ${port}=${0}    ${nrcell_id}=${nrcell_id}    ${throughput}=100MKbits/sec
    ...    ${ultarget_tp}=50    ${dltarget_tp}=50    ${iperf_type_ul}=via_app    ${iperf_type_dl}=via_command    ${ue_mode}=SA
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
    Log To Console    UE Attach
    ${5Grach_ed_0}    power_ue.UE Attach    ue_type=${ue_type}    attach_mode=5G_SA    ue_index=${ue_index}
    Log To Console    Verify attach
    power_ue.Verify attach    ue_type=${ue_type}    ue_index=${ue_index}    5Grach_ed=${5Grach_ed_0}    4G_check=False
    sleep    60s
    Log To Console    Start Traffic
    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=${throughput}    ue_index=${ue_index}
    ...    duration=200    ue_mode=${ue_mode}    iperf_port=${IPERF_portlist}[${port}]    iperf_type=${iperf_type_ul}    process_num=${3}
    sleep    5s
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${throughput}    ue_index=${ue_index}
    ...    duration=200    ue_mode=${ue_mode}    iperf_port=${IPERF_portlist}[${port}]    iperf_type=${iperf_type_dl}    process_num=${3}
    sleep    30s
    Log To Console    Check Throughput
    ${log_path}    power_ue.Collect Tput    ue_type=${ue_type}    duration=100s    ignore_time=10s
    ${cell_list}    create list    ${nrcell_id}
    run keyword and continue on failure    power_ue.Check Bi Tput    ue_type=${ue_type}    log=${log_path}    cells=${cell_list}
    ...    ultarget_throughput=${ultarget_tp}    dltarget_throughput=${dltarget_tp}
    Log To Console    Stop traffic
    run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    ue_index=${ue_index}
    ...    iperf_port=${IPERF_portlist}[${port}]    ue_mode=${ue_mode}
    run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    ue_index=${ue_index}
    ...    iperf_port=${IPERF_portlist}[${port}]    ue_mode=${ue_mode}
    Log To Console    UE Detach
    [Teardown]    run keyword and ignore error    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}

Check Mate30pro Peak Throughput
    [Arguments]    ${throughput}    ${target_tp_ul}    ${target_tp_dl}    ${duration}=60s    ${sleep_time}=30s    ${ue_mode}=SA
    ...    ${ue_index}=${0}    ${port}=${0}    ${nrcell_id}=${nrcell_id}    ${iperf_type_ul}=via_app    ${iperf_type_dl}=via_command
    Log To Console    Check Peak Throughput
    Single UE Attach    ue_index=${ue_index}
    Log To Console    start traffic
    power_ue.Start traffic    ue_type=${ue_type}    direction=ul   throughput=${throughput}   ue_index=${ue_index}
    ...    duration=600    ue_mode=${ue_mode}    iperf_port=${IPERF_portlist}[${port}]    iperf_type=${iperf_type_ul}    process_num=${3}
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl   throughput=${throughput}    ue_index=${ue_index}
    ...    duration=600    ue_mode=${ue_mode}    iperf_port=${IPERF_portlist}[${port}]    iperf_type=${iperf_type_dl}    process_num=${3}
    sleep    ${sleep_time}
    Log To Console    check throughput
    ${log_path}    power_ue.Collect Tput    ue_type=${ue_type}    duration=${duration}    ignore_time=5s
    ${cell_list}    create list    ${nrcell_id}
    run keyword and continue on failure    power_ue.Check Tput    ue_type=${ue_type}    direction=ul    log=${log_path}
    ...    cells=${cell_list}    target_throughput=${target_tp_ul}
    run keyword and continue on failure    power_ue.Check Tput    ue_type=${ue_type}    direction=dl    log=${log_path}
    ...    cells=${cell_list}    target_throughput=${target_tp_dl}
    Log To Console    stop traffic
    run keyword and continue on failure    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    ue_index=${ue_index}
    ...    iperf_port=${IPERF_portlist}[${port}]    ue_mode=${ue_mode}
    run keyword and continue on failure    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    ue_index=${ue_index}
    ...    iperf_port=${IPERF_portlist}[${port}]    ue_mode=${ue_mode}
    Log To Console    UE Detach
    [Teardown]   run keyword and ignore error    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}

Single UE Attach
    [Arguments]    ${ue_type}=${ue_type}    ${ue_index}=${0}
    Log To Console    Single UE Attach
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
    Log To Console    UE Attach
    ${5Grach_ed_0}    power_ue.UE Attach    ue_type=${ue_type}    attach_mode=5G_SA    ue_index=${ue_index}
    Log To Console    Verify attach
    power_ue.Verify attach    ue_type=${ue_type}    ue_index=${ue_index}    5Grach_ed=${5Grach_ed_0}    4G_check=False

Attach Test
    Log To Console    Attach Test
    Single UE Attach
    sleep    10s
    [Teardown]   power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}

Modify Bandwidth
    [Arguments]    ${cell_idx}    ${Actual_value}
    Log To Console    Modify bandwidth
    SBTS Login
    ${dict}    create dictionary    parameterName=chBw    operation=update    value=${Actual_value}
    ${list}    create list    ${dict}
    coam.perform_object_recommissioning    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_idx}
    ...    parameter=${list}    operation=update     skip_parameter_relation_errors=${True}    should_activate=${True}
    sleep    3s
    Log To Console    Wait Until BTS Should Be Normal
    Wait Until BTS Should Be Normal
    [Teardown]   SBTS Logout

Modify BWP_list And Bandwidth
    [Arguments]    ${cell_idx}    ${Bandwidth_value}    ${bwpDN_value}
    Log To Console    Modify BWP_list And Bandwidth
    SBTS Login
    ${cellBwpList1}    create dictionary    bwpDN=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/BWP_PROFILE-5    cellBwpId=0
    ${cellBwpList2}    create dictionary    bwpDN=${bwpDN_value}    cellBwpId=1
    ${cellBwpList_value}    create list    ${cellBwpList1}    ${cellBwpList2}
    ${dict1}    create dictionary    parameterName=chBw    operation=update    value=${Bandwidth_value}
    ${dict2}    create dictionary    parameterName=cellBwpList    operation=update    value=${cellBwpList_value}
    ${list}    create list    ${dict1}   ${dict2}
    coam.perform_object_recommissioning    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_idx}
    ...    parameter=${list}    operation=update     skip_parameter_relation_errors=${True}    should_activate=${True}
    sleep    3s
    Log To Console    Wait Until BTS Should Be Normal
    Wait Until BTS Should Be Normal
    [Teardown]   SBTS Logout

Get Active Alarm List
    [Arguments]    ${connection}=default
    Log To Console    Get Active Alarm List
    ${alarm_info}    coam.get_active_alarms    timeout=60    connection=${connection}
    ${faultid_list}    create list
    FOR    ${item}    IN    @{alarm_info}
        ${fault_id_dic}    get from dictionary    ${item}    additionalFaultID
        append to list    ${faultid_list}    ${fault_id_dic}
    END
    sort list    ${faultid_list}
    [Return]    ${faultid_list}

Number Of Times To Get History Alarm
    [Arguments]    ${expect_faultid}    ${expected_alarmid}    ${expect_objiectname}    ${connection}=default
    Log To Console    Number Of Times To Get History Alarm
    ${alarm_info}    coam.get_historic_alarms    timeout=60    connection=${connection}
    ${num}    set variable    ${0}
    FOR    ${item}    IN    @{alarm_info}
        ${fault_id}    get from dictionary    ${item}    additionalFaultID
        run keyword if    '${fault_id}' == '${expect_faultid}'    _check_alarm_id    item=${item}    expected_alarmid=${expected_alarmid}
        run keyword if    '${fault_id}' == '${expect_faultid}'    _check_objectname    item=${item}    expect_objiectname=${expect_objiectname}
        ${num}    run keyword if    '${fault_id}' == '${expect_faultid}'    evaluate    ${num}+1     ELSE    set variable    ${num}
    END
    [Return]    ${num}

_check_alarm_id
    [Arguments]    ${item}    ${expected_alarmid}
    ${alarm_id}    get from dictionary    ${item}    alarmId
    should be true    '${alarm_id}' == '${expected_alarmid}'

_check_objectname
    [Arguments]    ${item}    ${expect_objiectname}
    ${dic_objiectname}    get from dictionary    ${item}    configObjectName
    should contain    ${dic_objiectname}    ${expect_objiectname}

lock_cell
    [Arguments]    ${connection}=default   ${cell_idx}=${1}
    Log To Console    lock cell
    coam.lock    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_idx}    connection=${connection}    timeout=60s
    sleep    3s

unlock_cell
    [Arguments]    ${connection}=default    ${cell_idx}=${1}
    Log To Console    unlock cell
    coam.unlock    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_idx}    connection=${connection}    timeout=60s
    sleep    3s

Trigger Fault1937 On RMOD
    Log To Console    Trigger Fault1937 On RMOD
    ${connection}    ssh.connect to    hostname=${UTE_ADDRESS}   username=${UTE_USERNAME}
    ...    password=${UTE_PASSWORD}    alias=UTE
    ssh.send_command    command=chmod 777 ${CURDIR}/trigger_fault1937.sh    connection=${connection}
    ssh.send_command    command=cd ${CURDIR};./trigger_fault1937.sh    connection=${connection}
    sleep    5s
    [Teardown]    ssh.Disconnect     connection=${connection}

Cancle Fault1937 On RMOD
    Log To Console    Cancle Fault1937 On RMOD
    ${connection}    ssh.connect to    hostname=${UTE_ADDRESS}   username=${UTE_USERNAME}
    ...    password=${UTE_PASSWORD}    alias=UTE
    ssh.send_command    command=chmod 777 ${CURDIR}/cancel_fault1937.sh    connection=${connection}
    ssh.send_command    command=cd ${CURDIR};./cancel_fault1937.sh    connection=${connection}
    sleep    5s
    [Teardown]    ssh.Disconnect     connection=${connection}

Trigger Fault 1901 On RMOD
    Log To Console    Trigger Fault 1901 On RMOD
    ${connection}    ssh.connect to    hostname=${UTE_ADDRESS}   username=${UTE_USERNAME}
    ...    password=${UTE_PASSWORD}    alias=UTE
    ssh.send_command    command=chmod 777 ${CURDIR}/trigger_fault1901.sh    connection=${connection}
    ssh.send_command    command=cd ${CURDIR};./trigger_fault1901.sh    connection=${connection}
    sleep    5s
    [Teardown]    ssh.Disconnect     connection=${connection}

Cancel Fault 1901 On RMOD
    Log To Console    Cancel Fault 1901 On RMOD
    ${connection}    ssh.connect to    hostname=${UTE_ADDRESS}   username=${UTE_USERNAME}
    ...    password=${UTE_PASSWORD}    alias=UTE
    ssh.send_command    command=chmod 777 ${CURDIR}/cancel_fault1901.sh    connection=${connection}
    ssh.send_command    command=cd ${CURDIR};./cancel_fault1901.sh    connection=${connection}
    sleep    5s
    [Teardown]    ssh.Disconnect     connection=${connection}

Modify Parameter Success
    [Arguments]    ${Actual_value}    ${connection}=default
    Log To Console    Modify Parameter Success
    ${dict}    create dictionary    parameterName=timeZone    operation=update    value=${Actual_value}
    ${list}    create list    ${dict}
    coam.perform_object_recommissioning    dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SYNC-1/TIME-1    parameter=${list}
    ...    operation=update     skip_parameter_relation_errors=${True}    should_activate=${True}    connection=${connection}
    sleep    3s
    Wait Until BTS Should Be Normal

Check Parameter
    [Arguments]    ${expected_value}    ${dist_name}    ${pattern}    ${connection}=default
    Log To Console    Check Parameter
    ${pattern_dic}    coam.get_parameters    dist_name=${dist_name}    pattern=${pattern}    connection=${connection}
    ${pattern_value}    get from dictionary    ${pattern_dic}    ${pattern}
    should be true    '${expected_value}' == '${pattern_value}'

Modify Parameter Fail
    [Arguments]    ${Actual_value}    ${connection}=default
    Log To Console    Modify Parameter Fail
    ${dict}    create dictionary    parameterName=pMax    operation=update    value=${Actual_value}
    ${list}    create list    ${dict}
    run keyword and expect error    *VALUE_IS_TOO_BIG*    coam.perform_object_recommissioning
    ...    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1    parameter=${list}
    ...    operation=update     skip_parameter_relation_errors=${True}    should_activate=${True}    connection=${connection}
    sleep    3s

Start Traffic And Check Peak Throughput
    [Arguments]    ${throughput}    ${target_tp_ul}    ${target_tp_dl}    ${duration}=600    ${ue_mode}=SA
    ...    ${ue_index}=${0}    ${port}=${0}    ${nrcell_id}=${nrcell_id}    ${iperf_type_ul}=via_app    ${iperf_type_dl}=via_command
    Log To Console    Start Traffic And Check Peak Throughput
    Single UE Attach    ue_type=${ue_type}    ue_index=${ue_index}
    Log To Console    start traffic
    power_ue.Start traffic    ue_type=${ue_type}    direction=ul   throughput=${throughput}   ue_index=${ue_index}
    ...    duration=${duration}    ue_mode=${ue_mode}    iperf_port=${IPERF_portlist}[${port}]    iperf_type=${iperf_type_ul}    process_num=${3}
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl   throughput=${throughput}    ue_index=${ue_index}
    ...    duration=${duration}    ue_mode=${ue_mode}    iperf_port=${IPERF_portlist}[${port}]    iperf_type=${iperf_type_dl}    process_num=${3}
    sleep    30s
    Log To Console    check throughput
    ${log_path}    power_ue.Collect Tput    ue_type=${ue_type}    duration=60s    ignore_time=5s
    ${cell_list}    create list    ${nrcell_id}
    run keyword and continue on failure    power_ue.Check Tput    ue_type=${ue_type}    direction=ul    log=${log_path}
    ...    cells=${cell_list}    target_throughput=${target_tp_ul}
    run keyword and continue on failure    power_ue.Check Tput    ue_type=${ue_type}    direction=dl    log=${log_path}
    ...    cells=${cell_list}    target_throughput=${target_tp_dl}


Check Peak Throughput Only
    [Arguments]    ${target_tp_ul}    ${target_tp_dl}
    Log To Console    Peak Throughput
    ${log_path}    power_ue.Collect Tput    ue_type=${ue_type}    duration=60s    ignore_time=5s
    ${cell_list}    create list    ${nrcell_id}
    #run keyword and continue on failure    power_ue.Check Tput    ue_type=${ue_type}    direction=ul    log=${log_path}
    #...    cells=${cell_list}    target_throughput=${target_tp_ul}
    run keyword and continue on failure    power_ue.Check Tput    ue_type=${ue_type}    direction=dl    log=${log_path}
    ...    cells=${cell_list}    target_throughput=${target_tp_dl}



Stop Traffic And UE Detach
    [Arguments]    ${ue_index}=${0}    ${port}=${0}    ${ue_mode}=SA
    Log To Console    stop traffic
    run keyword and continue on failure    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    ue_index=${ue_index}
    ...    iperf_port=${IPERF_portlist}[${port}]    ue_mode=${ue_mode}
    run keyword and continue on failure    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    ue_index=${ue_index}
    ...    iperf_port=${IPERF_portlist}[${port}]    ue_mode=${ue_mode}
    Log To Console    UE Detach
    [Teardown]   run keyword and ignore error    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}

Block Cells And Check Status
    [Arguments]    ${cell_info}    ${all_cell_info}    ${operational_status}=disabled    ${usage_status}=Idle    ${block_status}=Blocked
    FOR    ${item}    IN    @{cell_info}
        block_cell    cell_idx=${item}
    END
    wait until keyword succeeds    5min    10s    Check Cells Status    cell_info=${cell_info}    all_cell_info=${all_cell_info}
        ...    operational_status=${operational_status}    usage_status=${usage_status}    block_status=${block_status}

Unblock Cells And Check Status
    [Arguments]    ${cell_info}   ${all_cell_info}    ${operational_status}=enabled    ${usage_status}=Active    ${block_status}=Unblocked
    FOR    ${item}    IN    @{cell_info}
        unblock_cell    cell_idx=${item}
    END
    wait until keyword succeeds    5min    10s    Check Cells Status    cell_info=${cell_info}    all_cell_info=${all_cell_info}
        ...    operational_status=${operational_status}    usage_status=${usage_status}    block_status=${block_status}

Start Catch BTS Log
    [Arguments]   ${name}=btslog    ${bts_logs_dir}=/tmp/btslog2
    Log To Console    Start Catch BTS Log
    __Make empty BTS logs dir      bts_logs_dir=${bts_logs_dir}
    btslog.create_btslog_collector    name=${name}    log_dir=${bts_logs_dir}
    core.setup_collectors        names=${name}
    core.start_collectors        names=${name}
    btslog.set_suite_alias       ${name}

__Make empty BTS logs dir
    [Arguments]     ${bts_logs_dir}
    Run  if [ ! -d ${bts_logs_dir} ]; then mkdir ${bts_logs_dir}; else rm ${bts_logs_dir}/*; fi

Stop and collect btslog on local machine
    [Arguments]   ${name}=btslog
    Log To Console    Stop and collect btslog on local machine
    core.stop_collectors         names=${name}
    core.collect_collectors      names=${name}
    core.teardown_collectors     names=${name}
