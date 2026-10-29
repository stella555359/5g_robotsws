*** Settings ***
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Library         taf.pdu
Resource          ../../../../RRM/RAN_PZ_HAZ_34/5GC001937_OTA/resources/5GC001937_mmw4_common_keyword.robot
Resource          ../../../../SISO/RAN_PZ_HAZ_34/CB006487/resources/CB006487_common_keyword.robot

*** Variables ***
${scf_path}          ${CURDIR}/../../../../../../commissionings/HGZ/7_5_UTE5G402T7422/
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
${RU1_742}    EA205152510
${RU1_7421}    K9195201558
${RU1_7422}     AH204600118
${RU_PDU_IP}       ${tl.gnbs[0].dus[0].rus[0].pdu_port.pdu.addr}
${RU_PDU_PORT}     ${tl.gnbs[0].dus[0].rus[0].pdu_port.port_no}

*** Keywords ***
Input default SCF
     [Timeout]  20 min
    [Arguments]      ${timeout}=10 min
    CI_interface.Common Suite Setup
    ${conn}    Rest Login DU
    ${version}    coam.get_sw_version    connection=${conn}
#    ${version_list}    split string    ${version}
#    ${if_common_load}     run keyword and return status    should contain    ${version_list[0]}    SBTS22R3
#    ${default_scf}    set variable if    ${if_common_load}   ${scf_path}SCF_SBTS22R3_8022.xml
#    ...    ${scf_path}SCF_Trunk_8022.xml
    ${version_list}    split string    ${version}    separator=_
    ${if_common_load}     run keyword and return status    should contain    ${version_list[2]}    9999
    ${version_scf}    set variable if    ${if_common_load}    SBTS00    ${version_list[0]}
    ${default_scf}    set variable    ${scf_path}SCF_${version_scf}_8022.xml
    set suite variable    ${default_scf}
    BuiltIn.Log    \n Input default SCF \n    console=yes
    run keyword and ignore error    COAM Commission with scf file    scf_file_path=${default_scf}    connection=${conn}
    BuiltIn.Log    \n wait until gnb cell on air \n    console=yes
    wait until keyword succeeds    ${timeout}    30sec   Cloud DU connect to gnb coam via ssl    connection=${conn}
    wait until keyword succeeds    ${timeout}    30sec   COAM Check GNB cell on air    connection=${conn}
    [Teardown]    CB008022_common_keywords.Disconnect from DU

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
    ...    ${usage_status}    ${procedural_status}    ${administrative_status}
    Log To Console    Check Cells Status
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
    ...    operational_status=${operational_status2}    usage_status=${usage_status2}
    ...    procedural_status=${procedural_status2}    administrative_status=${administrative_status2}
    [Teardown]    CB008022_common_keywords.Disconnect from DU

Check administrative status
   [Arguments]       ${operational_status}
    ...    ${procedural_status}      ${usage_status}     ${administrative_status}
    ...    ${cell_index}
    Log To Console    Check administrative status
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
    ...    operational_status=${operational_status1}    usage_status=${usage_status1}
    ...    procedural_status=${procedural_status1}    administrative_status=${administrative_status1}
   [Teardown]    CB008022_common_keywords.Disconnect from DU

_check_cell_status
    [Arguments]    ${cells_status}    ${operational_status}    ${usage_status}    ${administrative_status}    ${procedural_status}
    ${tmp}   Get From Dictionary    ${cells_status}    operationalState
    should be equal as strings    ${tmp}    ${operational_status}
    ${tmp}   Get From Dictionary    ${cells_status}   usageState
    should be equal as strings    ${tmp}    ${usage_status}
    ${tmp}   Get From Dictionary    ${cells_status}   proceduralStatus
    should be equal as strings    ${tmp}    ${procedural_status}
    ${tmp}   Get From Dictionary    ${cells_status}   administrativeState
    should be equal as strings    ${tmp}    ${administrative_status}

Power Off RU
    [Arguments]    ${expected_RU}     ${RU_PDU_IP}     ${RU_PDU_PORT}
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
    Log To Console    Delete RMOD And Relevant Object
    WEBUI Login
    selenium_coam.remove_object    object_name=MRBTS-${btsname_id}/NRBTS-${btsname_id}/NRCELL-0
    selenium_coam.remove_object    object_name=MRBTS-${btsname_id}/NRBTS-${btsname_id}/NRCELLGRP-0
    selenium_coam.remove_object    object_name=MRBTS-${btsname_id}/EQM-1/APEQM-1/RMOD-1
    selenium_coam.remove_object    object_name=MRBTS-${btsname_id}/EQM-1/HWTOP-1/CABLINK-4
    selenium_coam.remove_object    object_name=MRBTS-${btsname_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-0
    selenium_coam.remove_element   dist_name=MRBTS-${btsname_id}/NRBTS-${btsname_id}/NRDU-1
    ...    filter_param=Reference to cell group    node_index=${0}    abbr=refNrCellGroup
    selenium_coam.remove_element   dist_name=MRBTS-${btsname_id}/MNL-1/MNLENT-1/SYNC-2
    ...    filter_param=List of Distinguished Names    node_index=${0}    abbr=targetDNList
    ${error}    selenium_coam.validate_plan
    Log To Console    ${error}
    Log To Console    Activate plan
    selenium_coam.activate_plan    download_plan_without_activation=${False}    activate_plan_despite_errors=${False}
    log to console      get current cell number
    sleep    30s
    ${total_cell_number}    selenium_coam.get_number_of_cells
    should be equal      ${total_cell_number}     ${1}
    [Teardown]    Run Keyword And Ignore Error    WEBUI Logout

WEBUI Login
    [Arguments]      ${virtual_enable}=${True}     ${version}=5G21B
    [Documentation]   WEBUI Login
    Log To Console  START:WEBUI Login
    Log To Console  Try to login...
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
    @{alarms}    coam.get_active_alarms    timeout=${timeout}    connection=default
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


UE Attach And Start Traffic And Check Throughput
    [Arguments]        ${dl_throughput}    ${ul_throughput}
    ...    ${ultarget_tp}    ${dltarget_tp}    ${cell_id}
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
    coam.lock    dist_name=MRBTS-${btsname_id}/EQM-1/APEQM-1/RMOD-${ru_idx}    timeout=60    connection=${connection}
#    RU Should Be Locked     ru_index=${ru_idx}    connection=${connection}
    check Cell disabled     cell_index=${cell_index}     connection=${connection}
    [Teardown]    CB008022_common_keywords.Disconnect from DU

Power Off RU_2_HBTE
    [Arguments]    ${expected_RU}     ${RU_PDU_IP}     ${RU_PDU_PORT}
    Power Off    model=HBTE    RU_PDU_IP=${RU_PDU_IP}    RU_PDU_PORT=${RU_PDU_PORT}

Logout DU via admin
    [Documentation]    logout DU via admin
    ...                Author: Shenrao
    [Arguments]  ${alias}=default
    coam.Teardown  connection=${alias}
