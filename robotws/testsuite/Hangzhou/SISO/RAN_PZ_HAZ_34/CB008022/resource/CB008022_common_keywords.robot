*** Settings ***
Documentation    common kw for feature

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/Rus_Txpower_check.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Library         taf.pdu
Resource          ../../../../RRM/RAN_PZ_HAZ_34/5GC001937_OTA/resources/5GC001937_mmw4_common_keyword.robot
Resource          ../../../../SISO/RAN_PZ_HAZ_34/CB006487/resources/CB006487_common_keyword.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot


*** Variables ***
#${scf_path}          ${CURDIR}/../../../../../../commissionings/HGZ/${testline_name}/
${scf_22R3}            SCF_SBTS22R3_8022.xml
${scf_trunk}             SCF_Trunk_8022.xml
${DU_OAM_WEBUI_URL}    https://${tl.gnbs[0].dus[0].f1_m_ip_addr}/
${WEBEM_USERNAME}           ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBEM_PASSWORD}           ${tl.gnbs[0].cu.oam_http_connection_details.password}
${DU_OAM_IP}                ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${DU_OAM_SSH_USERNAME}      ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${DU_OAM_SSH_PASSWORD}      ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${btsname_id}       ${tl.gnbs[0].instance_id}
${btsname}     MRBTS-${tl.gnbs[0].instance_id}
${RU2_733}      CV193601214
${RU1_742}    K9195201558
${RU1_7421}    K9195201558
${RU1_7422}     AH204600118
${RU_PDU_IP}       ${tl.gnbs[0].dus[0].rus[0].pdu_port.pdu.addr}
${RU_PDU_PORT}     ${tl.gnbs[0].dus[0].rus[0].pdu_port.port_no}

*** Keywords ***
Adapt to ute cloud commission scf
    ${TL_NAME}   set variable if      '${testline_name}' == '${EMPTY}'    ${CONFIGURATION}    ${testline_name}
    ${pattern}   Set Variable    7_5(.*)
    ${TLNAME_TMP}    Get Regexp Matches     ${TL_NAME}    ${pattern}    1
    ${TLNAME_New}   Set Variable    7_5${TLNAME_TMP}[0]
    Set Suite Variable    ${scf_path}    ${CURDIR}/../../../../../../commissionings/HGZ/${TLNAME_New}/

Input default SCF
    [Timeout]  30 min
    [Arguments]      ${timeout}=15 min
    robot_common_operations.Common Suite Setup
    ${conn}    Rest Login DU
    ${version}    coam.get_sw_version    connection=${conn}
    ${version_list}    split string    ${version}    separator=_
    ${if_common_load}     run keyword and return status    Should Contain Any    ${version_list[2]}    9999    9990
    ${version_scf}    set variable if    ${if_common_load}    SBTS00    ${version_list[0]}
    ${default_scf}    set variable    ${scf_path}SCF_${version_scf}_8022.xml
    set suite variable    ${default_scf}
    BuiltIn.Log    \n Input default SCF \n    console=yes
    run keyword and ignore error    COAM Commission with scf file    scf_file_path=${default_scf}    connection=${conn}
    BuiltIn.Log    \n wait until gnb cell on air \n    console=yes
    wait until keyword succeeds    ${timeout}    30sec   Cloud DU connect to gnb coam via ssl    connection=${conn}
    wait until keyword succeeds    ${timeout}    30sec   Check GNB on air    connection=${conn}
    [Teardown]    CB008022_common_keywords.Disconnect from DU


Check GNB on air
    [Timeout]    20 min
    [Arguments]    ${connection}=GNB_OAM     ${time}=20min    ${interval}=20    ${check_lte_cell}=${False}
    Wait Until Keyword Succeeds    ${time}    ${interval}s    Verify all cells should be onair1
    ...    cell_type=nr    connection=${connection}    timeout=${interval}
    Run Keyword If    ${check_lte_cell}    Wait Until Keyword Succeeds    ${time}    ${interval}s    Verify all cells should be onair1


Verify all cells should be onair1
    [Documentation]    Description: verify all the cells status should be correct.
    [Arguments]    ${cell_type}=nr  ${connection}=GNB_OAM    ${timeout}=20
    Log to console    Verify all cells are on air
    ${administrative_expected}    Set Variable      Unlocked      # NR
    ${administrative_expected}    Set Variable If   '${cell_type}'=='lte'    unlocked    ${administrative_expected}
    ${cells_info}   coam.get_cells_info  cell_type=${cell_type}    timeout=${timeout}    connection=${connection}
    FOR    ${cell}    IN    @{cells_info}
        #Log To Console    nr cell type: ${cell_type}
        Run keyword and continue on failure    Should Be Equal As Strings    ${cell['status']['administrativeState']}
        ...      ${administrative_expected}
        Run keyword and continue on failure    Should Be Equal As Strings    ${cell['status']['operationalState']}    enabled
        Run keyword and continue on failure    Dictionary Should Not Contain Key    ${cell['status']}     availabilityStatus
    END

Rest Login DU
    [Arguments]    ${ip_address}=${DU_OAM_IP}    ${username}=${WEBEM_USERNAME}
    ...    ${password}=${WEBEM_PASSWORD}    ${alias}=default
    [Documentation]   Rest Login DU
    Connect to gnb coam via ssl    bts_host=${ip_address}    username=${username}    password=${password}    connection=${alias}
    ${conn}     set variable    ${alias}
    [Return]    ${conn}

Disconnect from DU
    [Arguments]    ${alias}=default
    coam.teardown     connection=${alias}

Modify parameter administrativeState
      [Arguments]     ${dist_name}     ${parameter}      ${value}       ${connection}
     Log To Console    Modify Parameter AdministrativeState with ${parameter} ${value} ${connection}
     ${conn}    Rest Login DU
     Modify scf parameter     dist_name=${dist_name}    parameter=administrativeState    value=Shutting Down    connection=${conn}
     CB008022_common_keywords.Disconnect from DU
     [Return]    ${conn}

Modify scf parameter
  [Arguments]    ${dist_name}    ${parameter}     ${value}     ${connection}=${None}
    coam.perform_parameter_recommissioning   dist_name=${dist_name}
    ...                                        parameter=${parameter}
    ...                                        operation=update
    ...                                        value=${value}
    ...                                        skip_parameter_relation_errors=${True}
    ...                                        should_activate=${True}
    ...                                        connection=${connection}
   sleep  10s

Check Cells Status
    [Arguments]       ${operational_status}    ${cell_index}
    ...      ${procedural_status}    ${administrative_status}
    Log To Console    Check Cells Status ${operational_status} ${procedural_status} ${administrative_status} for cell-${cell_index}
    ${conn}    Rest Login DU
    ${cell_info}     coam.Get_Cells_Info   cell_type=nr    connection=${conn}
    ${target_cell}     Set variable     ${None}
    FOR    ${item}    IN    @{cell_info}
        ${id}     get from dictionary     ${item}    id
        ${configuration}    get from dictionary     ${id}    configuration
        ${if_cell}    run keyword and return status    should contain     ${configuration}    NRCELL-${cell_index}
        ${target_cell}     Set variable if    ${if_cell}     ${item}    ${None}
        exit for loop if    ${if_cell}
    END
    ${cell_status}     get from dictionary     ${target_cell}    status
    _check_cell_status    cells_status=${cell_status}
    ...    operational_status=${operational_status2}
    ...    procedural_status=${procedural_status2}    administrative_status=${administrative_status2}
    [Teardown]    CB008022_common_keywords.Disconnect from DU

Check administrative status
   [Arguments]       ${operational_status}
    ...    ${procedural_status}      ${usage_status}     ${administrative_status}
    ...    ${cell_index}
    Log To Console    Check administrative status ${operational_status} ${procedural_status} ${administrative_status}
    ...    ${usage_status} for cell-${cell_index}
    ${conn}    Rest Login DU
    ${cell_info}     coam.Get_Cells_Info   cell_type=nr    connection=${conn}
    ${target_cell}     Set variable     ${None}
    FOR    ${item}    IN    @{cell_info}
        ${id}     get from dictionary     ${item}    id
        ${configuration}    get from dictionary     ${id}    configuration
        ${if_cell}    run keyword and return status    should contain     ${configuration}    NRCELL-${cell_index}
        ${target_cell}     Set variable if    ${if_cell}     ${item}    ${None}
        exit for loop if    ${if_cell}
    END
    ${cell_status}     get from dictionary     ${target_cell}    status
    _check_cell_status    cells_status=${cell_status}
    ...    operational_status=${operational_status1}
    ...    procedural_status=${procedural_status1}    administrative_status=${administrative_status1}
   [Teardown]    CB008022_common_keywords.Disconnect from DU

_check_cell_status
    [Arguments]    ${cells_status}    ${operational_status}       ${administrative_status}    ${procedural_status}
    ${tmp}   Get From Dictionary    ${cells_status}    operationalState
    should be equal as strings    ${tmp}    ${operational_status}
    ${tmp}   Get From Dictionary    ${cells_status}   proceduralStatus
    should be equal as strings    ${tmp}    ${procedural_status}
    ${tmp}   Get From Dictionary    ${cells_status}   administrativeState
    should be equal as strings    ${tmp}    ${administrative_status}

Power Off RU
    [Arguments]    ${expected_RU}     ${RU_PDU_IP}     ${RU_PDU_PORT}
    Log To Console    power off ru for ${expected_RU} ${RU_PDU_IP} ${RU_PDU_PORT}
    Power Off    model=TOPYOUNG    RU_PDU_IP=${RU_PDU_IP}    RU_PDU_PORT=${RU_PDU_PORT}

Power Off
    [Arguments]    ${model}    ${RU_PDU_IP}    ${RU_PDU_PORT}
    Log To Console    Power Off RU
    pdu.Setup Pdu    model=${model}    host=${RU_PDU_IP}    alias=pdu_alias
    pdu.Power Off    port=${RU_PDU_PORT}    pdu_device=pdu_alias
    pdu.Get Port Status    port=${RU_PDU_PORT}    pdu_device=pdu_alias
    Sleep    15s

Check RMOD Status
    [Arguments]    ${expected_RU}    ${connection}     ${expect_admin_status}=Unlocked
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

Delete RMOD-1 Relevant Object and get cell number
#    Log To Console    Delete RMOD And Relevant Object 742
    __UTE PC FireFox and Webdriver Checking
    Run Keyword And Ignore Error    WEBUI Logout
    __UTE PC FireFox and Webdriver Checking
    Wait Until Keyword Succeeds    3x    60s    WEBUI Login
    selenium_coam.remove_object    object_name=MRBTS-${btsname_id}/NRBTS-${btsname_id}/NRCELL-10
    selenium_coam.remove_object    object_name=MRBTS-${btsname_id}/NRBTS-${btsname_id}/NRCELLGRP-10
    selenium_coam.remove_object    object_name=MRBTS-${btsname_id}/EQM-1/APEQM-1/RMOD-11
    selenium_coam.remove_object    object_name=MRBTS-${btsname_id}/EQM-1/HWTOP-1/CABLINK-14
    selenium_coam.remove_object    object_name=MRBTS-${btsname_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-10
    selenium_coam.remove_element   dist_name=MRBTS-${btsname_id}/NRBTS-${btsname_id}/NRDU-1
    ...    filter_param=Reference to cell group    node_index=${2}    abbr=refNrCellGroup
#    selenium_coam.remove_element   dist_name=MRBTS-${btsname_id}/MNL-1/MNLENT-1/SYNC-2
#    ...    filter_param=List of Distinguished Names    node_index=${0}    abbr=targetDNList
    ${error}    selenium_coam.validate_plan
    Log To Console    ${error}
    Log To Console    Activate plan
    selenium_coam.activate_plan    download_plan_without_activation=${False}    activate_plan_despite_errors=${True}
    log to console      get current cell number
    sleep    30s
    ${total_cell_number}    selenium_coam.get_number_of_cells
    should be equal      ${total_cell_number}     ${3}
    [Teardown]    Run Keyword And Ignore Error    WEBUI Logout

Get BTS release
    ${conn}    Rest Login DU
    ${version}    coam.get_sw_version    connection=${conn}
    ${version_list}    split string    ${version}    separator=_
    ${bts_release}    set variable    ${version_list[0]}
    [Return]    ${bts_release}
    [Teardown]    CB008022_common_keywords.Disconnect from DU


WEBUI Login
    [Arguments]      ${virtual_enable}=${True}
    [Documentation]   WEBUI Login
    Log To Console  START:WEBUI Login with virtual_enable=${virtual_enable}
    Log To Console  Try to login...
    ${version}    Get BTS release
    selenium_coam.Enable_Virtual_Display
    selenium_coam.Login    url=${DU_OAM_WEBUI_URL}    username=${WEBEM_USERNAME}   password=${WEBEM_PASSWORD}
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


Get Alarm and fault Info
    [Arguments]   ${timeout}    ${connection}=default
    sleep    10s
    @{alarms}    coam.get_active_alarms    timeout=${timeout}    connection=${connection}
    sleep    1s
    log     ${alarms}
    ${fault_id_list}    create list
    ${alarmId_id_list}    create list
    ${object_list}    create list
    FOR    ${item}    IN    @{alarms}
        ${fault_id}    get from dictionary    ${item}    faultId
        ${alarm_Id}    get from dictionary    ${item}    alarmId
        ${object_name}    get from dictionary    ${item}    configObjectName
        append to list    ${fault_id_list}    ${fault_id}
        append to list    ${alarmId_id_list}    ${alarm_Id}
        append to list    ${object_list}      ${object_name}
    END
    [Return]    ${alarmId_id_list}    ${fault_id_list}       ${object_list}

#UE Attach And Start Traffic And Check Throughput
#    [Arguments]        ${ue_type}    ${dl_data_sam}    ${ul_data_sam}
#    ...    ${ultarget_tp}    ${dltarget_tp}     ${cell_id}
#   5GC001937_mmw4_common_keyword.attach multi power ue    ue_num=${1}
#   run keyword and ignore error    power_ue.UE Detach    ue_type=${ue_type}
#   Case precondition
#   5GC001937_mmw4_common_keyword.attach multi power ue    ue_num=${1}
#   5GC001937_mmw4_common_keyword.start multi power ue traffic ul and dl    ue_num=${1}
#     ...    ul_throughput=${ul_data_sam}    dl_throughput=${dl_data_sam}
#   run keyword and continue on failure    power_ue.Check throughput
#     ...    ue_type=samsung    direction=dl    throughput=${ultarget_tp}      cellid= ${cell_id}
#   run keyword and continue on failure    power_ue.Check throughput
#     ...    ue_type=samsung    direction=ul    throughput=${dltarget_tp}      cellid= ${cell_id}
#   [Teardown]    run keyword and ignore error    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}

UE Attach And Start Traffic And Check Throughput
    [Arguments]        ${dl_throughput}    ${ul_throughput}
    ...    ${ultarget_tp}    ${dltarget_tp}    ${cell_id}
    Log To Console    expected dl_throughput:${dl_throughput} and ul_throughput:${ul_throughput}
    Set Suite Variable    ${ue_type}    huawei
    honor attach
    UE start traffic hon       ue_index=${0}    tp_direction=both    time=100s
    ...    ul_throughput=${ul_data_hon}    dl_throughput=${dl_data_hon}    ue_type=${ue_type}
    ...    iperf_port_ul=${server_port_ul_hon}    iperf_port_dl=${server_port_dl_hon}
    run keyword and continue on failure    power_ue.Check throughput
    ...    ue_type=${ue_type}    direction=ul    throughput=${ultarget_tp}     cellid=${cell_id}
    run keyword and continue on failure    power_ue.Check throughput
    ...    ue_type=${ue_type}    direction=dl    throughput=${dltarget_tp}     cellid=${cell_id}
    power_ue.Stop traffic    ue_type=${ue_type}    direction=both    iperf_type=via_command
    [Teardown]    run keyword and ignore error    power_ue.UE Detach    ue_type=${ue_type}

xiaomi attach
    [Arguments]    ${ue_index}=${0}    ${ue_type}=xiaomi
    Log To Console   huawei attach
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
    ${5Grach_ed0}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}
    Log To Console    Verify attach
    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed0}    4G_check=False    ue_index=${ue_index}

UE start traffic xiaomi
    [Documentation]    used for UE start traffic, ul/dl/both.
    [Arguments]    ${ue_index}=${0}    ${protocol}=udp    ${tp_direction}=both    ${duration}=2000    ${iperf_type}=via_command
    ...    ${ul_throughput}=100M    ${dl_throughput}=2048M    ${time}=2s    ${ue_type}=xiaomi
    ...    ${iperf_port_ul}=default    ${iperf_port_dl}=default
    Run keyword if    '${tp_direction}'=='ul' or '${tp_direction}'=='both'    Start traffic xiaomi    ue_index=${ue_index}
    ...    direction=ul    throughput=${ul_throughput}    duration=${duration}    ue_type=${ue_type}    iperf_type=${iperf_type}
    ...    protocol=${protocol}    iperf_port=${iperf_port_ul}
    sleep    1s
    Run keyword if    '${tp_direction}'=='dl' or '${tp_direction}'=='both'   Start traffic hon    ue_index=${ue_index}
    ...     direction=dl    throughput=${dl_throughput}    duration=${duration}    ue_type=${ue_type}    protocol=${protocol}
    ...    iperf_port=${iperf_port_dl}
    sleep    ${time}

check Cell disabled
    [Arguments]    ${cell_index}   ${connection}=default
    ${cell_info}     coam.Get_Cells_Info   cell_type=nr    connection=${connection}
    ${target_cell}     Set variable     ${None}
    FOR    ${item}    IN    @{cell_info}
        ${id}     get from dictionary     ${item}    id
        ${configuration}    get from dictionary     ${id}    configuration
        ${if_cell}    run keyword and return status    should contain     ${configuration}    NRCELL-${cell_index}
        ${target_cell}     Set variable if    ${if_cell}     ${item}    ${None}
        exit for loop if    ${if_cell}
    END
    ${cell_status}     get from dictionary     ${target_cell}    status
    ${tmp}   Get From Dictionary    ${cell_status}    operationalState
    should be equal as strings    ${tmp}    disabled


Lock Ru and check ru and cell Status
    [Arguments]      ${ru_idx}    ${cell_index}   ${connection}=default
    Rest Login DU
    coam.lock    dist_name=MRBTS-${btsname_id}/EQM-1/APEQM-1/RMOD-${ru_idx}    timeout=60      connection=${connection}
    RU Should Be Locked     ru_index=${ru_idx}    connection=${connection}
    check Cell disabled     cell_index=${cell_index}     connection=${connection}
    [Teardown]    CB008022_common_keywords.Disconnect from DU

Power Off RU_2_HBTE
    [Arguments]    ${expected_RU}     ${RU_PDU_IP}     ${RU_PDU_PORT}
    Log To Console    power ru with expected_RU=${expected_RU}
    Power Off    model=HBTE    RU_PDU_IP=${RU_PDU_IP}    RU_PDU_PORT=${RU_PDU_PORT}

__UTE PC FireFox and Webdriver Checking
    [Arguments]    ${connection}=debug_0
    Log To Console    Start __UTE PC FireFox and Webdriver Checking
    ssh.Connect to    hostname=${tl.test_pc.default_ssh_connection_details.addr}
    ...    username=${tl.test_pc.default_ssh_connection_details.username}
    ...    password=${tl.test_pc.default_ssh_connection_details.password}    alias=${connection}
    sleep    2s
    ssh.send_command    command=ps auxf| grep firefox|awk '{print $2}'|xargs kill -9    connection=${connection}
    sleep    1s
    ${process_id}    ssh.read output    connection=${connection}
    Log To Console    get process id for firefox is ${process_id}
    sleep    1s
    ssh.send_command    command=ps auxf| grep geckodriver|awk '{print $2}'|xargs kill -9    connection=${connection}
    sleep    1s
    ${process_id}    ssh.read output    connection=${connection}
    Log To Console    get process id for geckodriver is ${process_id}
    [Teardown]    ssh.disconnect    connection=${connection}