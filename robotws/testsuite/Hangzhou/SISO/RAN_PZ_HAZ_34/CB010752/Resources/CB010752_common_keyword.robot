*** Settings ***
Documentation
Library    taf.collectors.core      WITH NAME    core
Library    taf.collectors.btslog      WITH NAME    btslog
Library    taf.transport.ssh      WITH NAME   csn
Library    taf.sbts.oam.coam.admin      WITH NAME    coam
Library    taf.hw.pdu                   WITH NAME    pdu
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_coam.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/cpe.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/L3_Call.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Variables   CB010752_Alarms_Var.py

*** Variables ***
@{allowed_list}               ${61675}    ${4655}    ${61524}    ${4654}    ${61649}    ${4681}    ${61652}     ${7300}    ${7319}
...    ${4592}    ${6327}      ${4476}      ${7316}
${BTS_ID}                     ${tl.gnbs[0].instance_id}
${gNB_ip}                     ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${gNB_http_username}          ${tl.gnbs[0].cu.oam_http_connection_details.username}
${gNB_http_password}          ${tl.gnbs[0].cu.oam_http_connection_details.password}
${gnb_ssh_username}           ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
${gnb_ssh_password}           ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
${scf_path}     ${CURDIR}/../../../../../../commissionings/HGZ/${testline_name}
${gNB_username}               ${tl.gnbs[0].cu.oam_http_connection_details.username}
${gNB_password}               ${tl.gnbs[0].cu.oam_http_connection_details.password}
${control_pc}                 ${tl.ues[0].ssh_connection_details.addr}
${control_pc_name}            ${tl.ues[0].ssh_connection_details.username}
${control_pc_pass}            ${tl.ues[0].ssh_connection_details.password}
${UTE_ADDRESS}                ${tl.test_pc.default_ssh_connection_details.addr}
${UTE_USERNAME}               ${tl.test_pc.default_ssh_connection_details.username}
${UTE_PASSWORD}               ${tl.test_pc.default_ssh_connection_details.password}
${NRBTS_ID}                   ${tl.gnbs[0].global_bts_id}
@{physCellId_list}            74    75    76    77    84    85    60    61
#${config_path}                ${CURDIR}/../Delta_Config/10752_C_Case05.json
${config_path}                ${CURDIR}/../Delta_Config
#${ul_power_port_list}         ${tl.ues[0].iperf_details.ports[0:2]}

*** Keywords ***
Suite Setup
    robot_common_operations.Common Suite Setup

CB010752 Common Test Setup
    Log to console    //To do : CB010752 Common Test Setup for check gnb status and check alarm
    Check GNB on air
    Check Alarm List on BTS    allowed_list=${allowed_list}

Suite Teardown
    robot_common_operations.Common Suite Teardown
    Setup Commission SCF
    Check GNB on air
    Check Alarm List on BTS    allowed_list=${allowed_list}

Case Setup
    robot_common_operations.Common case Setup    allowed_faults_ids=61675,7316,4476
    Setup Commission SCF
    Check GNB on air
    Check Alarm List on BTS    allowed_list=${allowed_list}

Case Teardown
    Run Keyword if    "${TEST_STATUS}"=="FAIL"    Save Snapshot
    robot_common_operations.Common case Teardown
    CI_interface.Common Case Teardown



Suite Setup CB010752-C
    robot_common_operations.Common Suite Setup
    Setup Commission SCF    RAT=4G.xml
    Check GNB on air
    Check Alarm List on BTS    allowed_list=${allowed_list}

########### download SCF and check bts on air #################
Set default SCF
    [Arguments]    ${bts_host}=${gNB_ip}    ${connection}=GNB_OAM    ${RAT}=5G.xml    ${scf_path}=${scf_path}
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    ${version}    coam.get_sw_version    connection=${connection}
    ${version_list}    split string    ${version}    separator=_
    ${version_scf}    run keyword if    '${version_list[2]}'=='9999'    Set Variable    SBTS00
    ...    ELSE   Set Variable    ${version_list[0]}
    ${default_scf_path}    set variable    ${scf_path}/SCF_${version_scf}_${RAT}
    set suite variable    ${default_scf_path}
    log to console   ${default_scf_path}
    [Teardown]     Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}


Setup Commission SCF
    [Arguments]    ${bts_host}=${gNB_ip}    ${connection}=GNB_OAM    ${RAT}=5G.xml
    Set default SCF   bts_host=${bts_host}    RAT=${RAT}
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    COAM Commission with scf file    scf_file_path=${default_scf_path}    connection=${connection}
    ...    timeout=9min   is_pdl_checking_needed=${False}
    ...    skip_parameter_relation_errors=${True}
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Check GNB on air
    [Timeout]    30 min
    [Arguments]  ${bts_host}=${gnb_ip}    ${connection}=GNB_OAM
    Wait Until Keyword Succeeds    20min    20s
    ...    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    Wait Until Keyword Succeeds    30min    20s    COAM Check GNB cell on air    connection=${connection}
    Wait Until Keyword Succeeds    30min    20s    Verify all cells should be onair    connection=${connection}
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Get Alarm on BTS
    [Arguments]  ${bts_host}=${gnb_ip}    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    @{active_alarms}    coam.get_active_alarms    connection=${connection}
    @{history_alarms}    coam.get_historic_alarms    connection=${connection}
    ${active_id_list}    Get Alarm ID From BTS    output_alarms=${active_alarms}
    ${history_id_list}    Get Alarm ID From BTS    output_alarms=${history_alarms}
    [Return]  ${active_id_list}    ${history_id_list}
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Get Alarm ID From BTS
    [Arguments]  ${output_alarms}
    ${len}    Get Length    ${output_alarms}
    @{fault_id_list}    create list
    FOR    ${i}    IN RANGE    ${len}
        ${fault_id}     get from dictionary  ${output_alarms[${i}]}    additionalFaultID
        APPEND TO LIST  ${fault_id_list}    ${fault_id}
    END
    [Return]  ${fault_id_list}

Check Alarm List on BTS Temp
    [Arguments]  ${allowed_list}=None    ${not_allowed_list}=None    ${bts_host}=${gnb_ip}    ${connection}=GNB_OAM
    ${actual_fault_id_list}    ${history_id_list}    Get Alarm on BTS    bts_host=${bts_host}    connection=${connection}
    ${history_id_len}    Get Length    ${history_id_list}
    Run Keyword if    ${allowed_list} != None        Check List1 content in List2    list1=${actual_fault_id_list}    list2=${allowed_list}
    Run Keyword if    ${not_allowed_list} != None     Check List1 content not in List2    list1=${not_allowed_list}    list2=${actual_fault_id_list}
    Run Keyword if    ${history_id_len} != ${0}    Save Snapshot
    Should be equal    ${history_id_len}    ${0}

Check Alarm List on BTS
    [Arguments]  ${allowed_list}=None    ${not_allowed_list}=None    ${bts_host}=${gnb_ip}    ${connection}=GNB_OAM
    ${status}    Run Keyword And Return Status    Check Alarm List on BTS Temp    allowed_list=${allowed_list}
    ...    not_allowed_list=${not_allowed_list}    bts_host=${bts_host}    connection=${connection}
    Run Keyword if    ${status} == ${False}    Save Snapshot
    Should be equal    ${status}    ${True}

Check Cells info
    [Arguments]    ${expect_cell_info}     ${bts_host}=${gNB_ip}    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    ${cells_info_list}    coam.get_cells_info    connection=${connection}
    ${result}    Check_Cell_Id_Info    cells_info_list=${cells_info_list}    expect_cell_info=${expect_cell_info}
    Should be equal   ${result}    ${True}
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}


Check List1 content in List2
    [Arguments]  ${list1}    ${list2}
    ${len1}    Get Length    ${list1}
    ${len2}    Get Length    ${list2}
    Run Keyword And Continue On Failure    Should be true    ${len1}<=${len2}
    FOR  ${i}  IN  @{list1}
        Run Keyword And Continue On Failure    Should contain    ${list2}    ${i}
    END

Check List1 content not in List2
   [Arguments]  ${list1}    ${list2}
    FOR  ${i}  IN  @{list1}
        Run Keyword And Continue On Failure    Should not contain    ${list2}    ${i}
    END

Save Snapshot
    [Arguments]    ${connection}=cOAM    ${timeout}=10min
    log to console    Save Snapshot...
    run keyword and ignore error     coam.teardown    connection=${connection}
    Connect to gnb coam via ssl    bts_host=${gNB_ip}    username=${gNB_username}    password=${gNB_password}
    ...    connection=${connection}
    ${snapshot_path}    coam.Get Snapshot From BTS    alias=${connection}    timeout=${timeout}
    [Teardown]    Run keyword and ignore error    coam.teardown      connection=${connection}
    [Return]    ${snapshot_path}


RMOD Power OFF/ON Operation And Check GNB Status
    Log To Console     \nTo do : Power OFF Operation
    FOR   ${idex}   IN   @{ALL_RU_INFO_LIST}
        ${RU_PDU_IP}   Set Variable   ${idex['ru_pdu_ip']}
        ${RU_PDU_PORT}   Set Variable   ${idex['ru_pdu_port']}
        ${model}    Set Variable    ${idex['ru_pdu_model']}
        Power OFF/ON Operation    action=Power Off    RU_PDU_IP=${RU_PDU_IP}    RU_PDU_PORT=${RU_PDU_PORT}    model=${model}
    END
    sleep    30s
    Log To Console     \nTo do : Power ON Operation
    FOR   ${idex}   IN   @{ALL_RU_INFO_LIST}
        ${RU_PDU_IP}   Set Variable   ${idex['ru_pdu_ip']}
        ${RU_PDU_PORT}   Set Variable   ${idex['ru_pdu_port']}
        ${model}    Set Variable    ${idex['ru_pdu_model']}
        Power OFF/ON Operation    action=Power On    RU_PDU_IP=${RU_PDU_IP}    RU_PDU_PORT=${RU_PDU_PORT}    model=${model}
    END
    Check GNB on air
    Check Alarm List on BTS    allowed_list=${allowed_list}


Power OFF/ON Operation
    [Arguments]    ${RU_PDU_IP}    ${RU_PDU_PORT}    ${action}    ${model}=HBTE
    pdu.setup_pdu    model=${model}    host=${RU_PDU_IP}    alias=pdu_alias
    run keyword if  "${action}"=="Power Off"    pdu.power_off    port=${RU_PDU_PORT}    pdu_device=pdu_alias
    ...    ELSE   pdu.power_on    port=${RU_PDU_PORT}    pdu_device=pdu_alias
    sleep    5s
    Wait Until Keyword Succeeds    5min    20s    pdu.get_port_status    port=${RU_PDU_PORT}    pdu_device=pdu_alias

Reset ALL RMOD And Check GNB Status
    [Arguments]    ${bts_host}=${gnb_ip}    ${connection}=GNB_OAM
    Wait Until Keyword Succeeds    10min    20s    Connect to gnb coam via ssl
    ...    bts_host=${bts_host}    username=${gNB_http_username}     password=${gNB_http_password}    connection=${connection}
    ${ru_index_list}   Get RU index list    connection=${connection}
    FOR   ${index}  IN   @{ru_index_list}
        Log To Console    \nTo do : Reset RMOD dist_name=MRBTS-${BTS_ID}/EQM-1/APEQM-1/RMOD-${index}
        ${RU_reset_status}    coam.reset_unit    dist_name=MRBTS-${BTS_ID}/EQM-1/APEQM-1/RMOD-${index}    force_radio_reset=${True}
        ...    timeout=${300}    connection=${connection}
        sleep    30s
    END
    Check GNB on air
    Check Alarm List on BTS    allowed_list=${allowed_list}
    [Teardown]    Run keyword and ignore error    coam.teardown      connection=${connection}

Make CPE L3 Call And Check Peak Tput
    [Arguments]    ${dl_tp}    ${ul_tp}    ${target_avg_percent_DL}    ${target_avg_percent_UL}    ${protocol}=udp    ${duration}=180
    ...    ${ue_list}=${ALL_UE_INFO_LIST}    ${Cell_Pci}=${CALL_PCI_AND_NRCELLID_INFO}
    Start Receiver 5G19-A CPE L3 Call    ue_list=${ue_list}    Cell_Pci=${Cell_Pci}
    Start CPE Start Traffic And Check Peak Tput    dl_tp=${dl_tp}    ul_tp=${ul_tp}
    ...    target_avg_percent_DL=${target_avg_percent_DL}    target_avg_percent_UL=${target_avg_percent_UL}
    ...    duration=${duration}    protocol=${protocol}    ue_list=${ue_list}
    ...    Cell_Pci=${Cell_Pci}
    Stop CPE Dl Ul Traffic    ue_list=${ue_list}
    [Teardown]    CPE Call Teardown    ue_list=${ue_list}

Start Receiver 5G19-A CPE L3 Call
    [Arguments]    ${Cell_Pci}=${CALL_PCI_AND_NRCELLID_INFO}    ${ue_list}=${ALL_UE_INFO_LIST}
    FOR  ${idex}  IN  @{ue_list}
        ${ue_index}   Set Variable   ${idex['ue_cpe_index']}
        ${ue_serial_number}   Set Variable   ${idex['ue_serial_number']}
        ${pci}    Get Call PCI Info    ue_serial_number=${ue_serial_number}    Cell_Pci=${Cell_Pci}
        ${ue_type}    CPE Prepare UE    ue_index=${ue_index}
        CPE Attach and Verify State    ue_index=${ue_index}    pci=${pci}
    END

Start CPE Start Traffic And Check Peak Tput
    [Arguments]    ${dl_tp}    ${ul_tp}    ${duration}    ${protocol}    ${target_avg_percent_DL}    ${target_avg_percent_UL}
    ...    ${Cell_Pci}=${CALL_PCI_AND_NRCELLID_INFO}    ${ue_list}=${ALL_UE_INFO_LIST}
    FOR  ${idex}  IN  @{ue_list}
        ${ue_index}   Set Variable   ${idex['ue_cpe_index']}
        ${ue_serial_number}   Set Variable   ${idex['ue_serial_number']}
        ${nrcellid}    Get Call NrCellId Info    ue_serial_number=${ue_serial_number}    Cell_Pci=${Cell_Pci}
        log to console    \nCPE Start Traffic And Check Tput UE ${ue_index}
        power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${dl_tp}M
        ...    protocol=${protocol}    duration=${duration}    ue_index=${ue_index}      process_num=5
        power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=${ul_tp}M
        ...    protocol=${protocol}    duration=${duration}    ue_index=${ue_index}    process_num=5
        ${log_tput}    power_ue.Collect Tput    ue_type=${ue_type}    alias=log_${ue_index}
        ...    duration=30s    ignore_time=15s    check_source=Aasyslog
        ${cells}    Create List    ${nrcellid}
        log to console    \ncell id is ${cells}
        Check Throught From Asslog    ul_list=${cells}    dl_list=${cells}   ul_tp=${ul_tp}    dl_tp=${dl_tp}
        ...    target_avg_percent_UL=${target_avg_percent_UL}    log_path=${log_tput}
        ...    target_avg_percent_DL=${target_avg_percent_DL}
    END



Check Throught From Asslog
    [Arguments]  ${log_path}    ${ul_list}    ${dl_list}    ${target_avg_percent_DL}
    ...    ${ul_tp}=${500}    ${dl_tp}=${500}    ${if_ul}=${True}    ${if_dl}=${True}
    ...    ${target_avg_percent_UL}=0.90    ${ue_type}=samsung
    run keyword and continue on failure    run keyword if    ${if_ul}==${True}    power_ue.Check Tput    ue_type=${ue_type}
    ...    direction=UL    log=${log_path}    cells=${ul_list}    target_throughput=${ul_tp}    target_avg_percent=${target_avg_percent_UL}
    ...    actCarrierAggregation=${false}    min_percent=0
    run keyword and continue on failure    run keyword if    ${if_dl}==${True}    power_ue.Check Tput    ue_type=${ue_type}
    ...    direction=DL    log=${log_path}    cells=${dl_list}    target_throughput=${dl_tp}    target_avg_percent=${target_avg_percent_DL}
    ...    actCarrierAggregation=${false}   min_percent=0

Stop CPE Dl Ul Traffic
    [Arguments]    ${protocol}=udp    ${ue_list}=${ALL_UE_INFO_LIST}
    FOR  ${idex}  IN  @{ue_list}
        ${ue_index}   Set Variable   ${idex['ue_cpe_index']}
        log to console    \nStop CPE Dl Ul Traffic UE ${ue_index}
        run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    ue_index=${ue_index}
        ...    protocol=${protocol}
        run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    ue_index=${ue_index}
        ...    protocol=${protocol}    iperf_port=${tl.ues[${ue_index}].data_transfer[0].app_server.ports[0:5]}
    END


Get Call PCI Info
    [Arguments]  ${ue_serial_number}    ${Cell_Pci}=${CALL_PCI_AND_NRCELLID_INFO}
    FOR  ${idex}  IN  @{Cell_Pci}
        ${pci}    run keyword if  "${idex}"=="${ue_serial_number}"    Set Variable   ${Cell_Pci['${idex}']['pci']}
        exit for loop if    "${idex}"=="${ue_serial_number}"
    END
    [Return]    ${pci}

Get Call NrCellId Info
    [Arguments]  ${ue_serial_number}    ${Cell_Pci}=${CALL_PCI_AND_NRCELLID_INFO}
    FOR  ${idex}  IN  @{Cell_Pci}
        ${nrcellid}   run keyword if  "${idex}"=="${ue_serial_number}"    Set Variable   ${Cell_Pci['${idex}']['nrcellid']}
        exit for loop if    "${idex}"=="${ue_serial_number}"
    END
    [Return]    ${nrcellid}

CPE Prepare UE
    [Arguments]  ${ue_index}
    log to console    \nPrepare CPE UE ${ue_index}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    Set Test Variable    ${ue_type}
    power_ue.Prepare UE    ue_index=${ue_index}    ue_type=${ue_type}
    sleep    6s

CPE Attach and Verify State
    [Arguments]  ${ue_index}    ${pci}
    log to console    \nCPE Attach and Verify State UE ${ue_index}
    ${5Grach_ed_0}    power_ue.UE Attach
    ...    ue_index=${ue_index}    ue_type=${ue_type}    log_type=Iperf    pci=${pci}
    sleep    6s

CPE Call Teardown
    [Arguments]  ${ue_list}=${ALL_UE_INFO_LIST}
    FOR  ${idex}  IN  @{ue_list}
        ${ue_index}   Set Variable   ${idex['ue_cpe_index']}
        Log To Console    \nCall Teardown
        Run Keyword And Ignore Error    Power_ue.UE Detach    ue_index=${ue_index}    ue_type=${ue_type}
    END

########### modify parameter ###################
Rest Login DU
    [Arguments]    ${ip_address}=${gNB_ip}   ${username}=${gNB_username}
    ...    ${password}=${gNB_password}    ${alias}=default
    [Documentation]   Rest Login DU
    Connect to gnb coam via ssl    bts_host=${ip_address}    username=${username}    password=${password}    connection=${alias}
    ${conn}     set variable    ${alias}
    [Return]    ${conn}


Get BTS release
    ${conn}    Rest Login DU
    ${version}    coam.get_sw_version    connection=${conn}
    ${version_list}    split string    ${version}    separator=_
    ${bts_release}    set variable    ${version_list[0]}
    [Return]    ${bts_release}
    [Teardown]    coam.teardown     connection=${conn}



WEBUI Login
#    [Arguments]      ${virtual_enable}=${True}
    [Documentation]   WEBUI Login
    Log To Console  START:WEBUI Login
    Log To Console  Try to login...
    ${version}    Get BTS release
    selenium_coam.Enable_Virtual_Display
    selenium_coam.Login    url=https://${gNB_ip}    username=${gNB_username}   password=${gNB_password}
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


########### [1]CB010752-SR-A_001_004 case step#################
add cell for case A01
    [Arguments]
    WEBUI Login
#    @{physCellId_list}    create list     74    75    76    77    84    85
    Add Cell Object    physCellId_list=${physCellId_list[0:4]}   add_object_cell_num=${4}    start_cell_id=${14}
    Add Cell Object    physCellId_list=${physCellId_list[4:6]}   add_object_cell_num=${2}    start_cell_id=${24}    node_index_Diff=9
    ${error}    selenium_coam.validate_plan    timeout=120
    Log To Console    ${error}
    selenium_coam.activate_plan    download_plan_without_activation=${False}    activate_plan_despite_errors=${False}    timeout=${300}
    [Teardown]    WEBUI Logout

Add Cell Object
    [Arguments]  ${physCellId_list}    ${add_object_cell_num}    ${start_cell_id}    ${node_index_Diff}=5
    Log To Console    add cell
    ${end_cell_id}    evaluate    ${add_object_cell_num} + ${start_cell_id}
    ${total_cell_num}    evaluate    ${add_object_cell_num} + 1
    ${change_time}     evaluate    int(${6}/${total_cell_num})
    ${start_ru_id}    evaluate    ${change_time} + 1
    FOR    ${item}    IN RANGE    ${add_object_cell_num}
        ${cell_id}    Evaluate    ${item} + ${start_cell_id}
        ${copy_cell_id}    Evaluate    ${item}+4
        ${node_index}     Evaluate    ${item}+${node_index_Diff}
        ${physCellId}    Evaluate    ${item}+1
        selenium_coam.add_object    object_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}   object_class_name=NRCELL
        ...    plan_to_copy_from=CURRENT_BTS_CONF-1    copy_from=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${copy_cell_id}
        ...    include_subobject=${true}    id_value=${cell_id}
        selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
        ...    filter_param=Local cell resource ID   new_value=${cell_id}    abbr=lcrId
        selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
        ...    filter_param=Physical cell identifier   new_value=${physCellId_list[${item}]}   abbr=physCellId
        selenium_coam.add_object    object_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}   object_class_name=NRCELLGRP
        ...    plan_to_copy_from=CURRENT_BTS_CONF-1    copy_from=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELLGRP-${copy_cell_id}
        ...    include_subobject=${true}    id_value=${cell_id}
       selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELLGRP-${cell_id}
       ...    filter_param=List of NR cells assigned to cell group   node_index=${0}    new_value=${cell_id}    abbr=nrCellList
       selenium_coam.add_element    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRDU-1
       ...    filter_param=Reference to cell group    abbr=refNrCellGroup
       selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRDU-1
       ...    filter_param=Reference to cell group    new_value=${cell_id}   node_index=${node_index}  abbr=refNrCellGroup
       selenium_coam.add_object    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1   object_class_name=LCELNR
       ...    plan_to_copy_from=CURRENT_BTS_CONF-1    copy_from=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${copy_cell_id}
       ...    include_subobject=${true}    id_value=${cell_id}
    END



Set Channelgroup Parameter Mutil Times
    [Arguments]    ${ru_id}    ${cell_id}    ${times}=${2}
    ${group_id}    set variable    ${0}
    FOR    ${item}    IN RANGE    ${times}
        ${group_id}    Evaluate    ${group_id} + 1
        Set Channelgroup Parameter    group_id=${group_id}    ru_id=${ru_id}    cell_id=${cell_id}
        ${ru_id}    Evaluate    ${ru_id} + 1
    END

Set Channelgroup Parameter
    [Arguments]  ${group_id}    ${ru_id}    ${cell_id}=${6}
    Log To Console    set channelgrp parameter
    @{antl_value_list}    create list    ${1}    ${2}    ${3}    ${4}    ${5}    ${6}    ${7}    ${8}
    FOR    ${item}    IN RANGE    ${8}
        ${CHANNEL_id}    Evaluate    ${item} + 1
        ${antlDN_value}    set variable    MRBTS-${BTS_ID}/EQM-1/APEQM-1/RMOD-${ru_id}/ANTL-${antl_value_list}[${item}]
        selenium_coam.set_parameter_value
        ...    dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id}/CHANNELGROUP-${group_id}/CHANNEL-${CHANNEL_id}
        ...    filter_param=Distinguished Name of antenna line   new_value=${antlDN_value}    abbr=antlDN
    END


set chBwUl/DL
    [Arguments]    ${bts_host}=${gNB_ip}    ${connection}=GNB_OAM    ${input_list}=${json_update}
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    Modify Parameters with coam     input_list=${input_list}    connection=${connection}
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Modify Parameters with coam
    [Arguments]    ${input_list}    ${delta_id}=update_parameter    ${connection}=GNB_connection
    coam.create_delta    delta_id=${delta_id}
    FOR    ${item}  IN    @{input_list}
        ${operation}    get from dictionary    ${item}    operation
        Run keyword if    '${operation}'=='update'
        ...    coam.append_parameter_update_to_delta    dist_name=${item['dist_name']}    parameter=${item['parameter']}
        ...    value=${item['value']}    delta_id=${delta_id}
        Run keyword if    '${operation}'=='delete'
        ...    coam.append_parameter_delete_to_delta    dist_name=${item['dist_name']}    parameter=${item['parameter']}
        ...    delta_id=${delta_id}
#        Log to console    Add task - ${operation}: ${item['dist_name']}.
        Run keyword if    '${operation}'=='update_object'
        ...    coam.append_managed_object_to_delta    dist_name=${item['dist_name']}
        ...    operation=update    delta_id=${delta_id}
        Run keyword if    '${operation}'=='delete_object'
        ...    coam.append_managed_object_to_delta    dist_name=${item['dist_name']}
        ...    operation=delete    delta_id=${delta_id}
        Run keyword if    '${operation}'=='create_object'
        ...    coam.append_managed_object_to_delta    dist_name=${item['dist_name']}
        ...    operation=create    delta_id=${delta_id}
#        Log to console    Add task - ${operation}: ${item['dist_name']}
    END
    ${delta_file}    coam.get_delta    delta_id=${delta_id}
    log to console    ${delta_file}
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

Delete Nrcells Data
    [Arguments]  ${object_num}    ${start_id}    ${node_start_id}
    Log To Console    delete nrcell
    WEBUI Login
    FOR   ${item}    IN RANGE    ${object_num}
        ${cell_id}    Evaluate    ${item} + ${start_id}
        ${node_index}    Evaluate     ${node_start_id} - ${item}
        selenium_coam.remove_object    object_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
        selenium_coam.remove_object    object_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELLGRP-${cell_id}
        selenium_coam.remove_object    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id}
        selenium_coam.remove_element   dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRDU-1
        ...    filter_param=Reference to cell group    node_index= ${node_index}   abbr=refNrCellGroup
    END
    ${error}    selenium_coam.validate_plan    timeout=120
    Log To Console    ${error}
    selenium_coam.activate_plan    download_plan_without_activation=${False}    activate_plan_despite_errors=${False}    timeout=${300}
    [Teardown]    WEBUI Logout

modify the parameter case A01
    set chBwUl/DL
    Check GNB on air
    Check Alarm List on BTS    allowed_list=${allowed_list}
    add cell for case A01
    Check GNB on air
    Check Alarm List on BTS    allowed_list=${allowed_list}

modify the parameter case A04
    Delete Nrcells Data    object_num=${2}    start_id=${24}    node_start_id=${10}
    Check GNB on air
    Check Alarm List on BTS    allowed_list=${allowed_list}
    set chBwUl/DL    input_list=${json_update_40M}
    Check GNB on air
    Check Alarm List on BTS    allowed_list=${allowed_list}


########### [1]CB010752-SR-A_006 case step#################
configuration 1super3sub to 3nom
#    [Arguments]     ${add_object_cell_num}=${1}     ${start_cell_id}=${3}
    WEBUI Login
    selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-0
    ...    filter_param=Activate super cell   new_value=false   abbr=actSuperCell
    selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELLGRP-0
    ...    filter_param=Number of transmitted Synchronization Signal Blocks  new_value=1 beam   abbr=numberOfTransmittedSsBlocks
    super change to nomcell    physCellId_list=${physCellId_list[6:8]}    add_object_cell_num=${2}    start_cell_id=${1}
    Delete CHANNELGROUP    cell_id=1
    Delete CHANNELGROUP    cell_id=2
    selenium_coam.remove_object    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${0}/CHANNELGROUP-2
    selenium_coam.remove_object    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${0}/CHANNELGROUP-3
    ${error}    selenium_coam.validate_plan    timeout=120
    Log To Console    ${error}
    selenium_coam.activate_plan    download_plan_without_activation=${False}    activate_plan_despite_errors=${True}    timeout=${180}
    Check GNB on air
    Check Alarm List on BTS    allowed_list=${allowed_list}
    [Teardown]    WEBUI Logout

configuration 3nom to 1super3sub
    [Arguments]  ${object_num}=2    ${start_id}=1    ${node_start_id}=5
    WEBUI Login
    selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-0
    ...    filter_param=Activate super cell   new_value=true   abbr=actSuperCell
    FOR    ${item}    IN RANGE    ${2}
        ${LCELNR_id}    Evaluate    ${item} + 1
        ${CHANNELGROUP_id}  Evaluate    ${item} + 2
        selenium_coam.add_object    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-0   object_class_name=CHANNELGROUP
        ...    plan_to_copy_from=CURRENT_BTS_CONF-1
        ...    copy_from=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${LCELNR_id}/CHANNELGROUP-${CHANNELGROUP_id}
        ...    include_subobject=${TRUE}    id_value=${CHANNELGROUP_id}
    END
    Log To Console    delete nrcell
    FOR   ${item}    IN RANGE    ${object_num}
        ${cell_id}    Evaluate    ${item} + ${start_id}
        ${node_index}    Evaluate     ${item} + ${node_start_id}
        selenium_coam.remove_object    object_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
        selenium_coam.remove_object    object_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELLGRP-${cell_id}
        selenium_coam.remove_object    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id}
        selenium_coam.remove_element   dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRDU-1
        ...    filter_param=Reference to cell group    node_index= ${node_index}   abbr=refNrCellGroup
    END
    ${error}    selenium_coam.validate_plan    timeout=120
    Log To Console    ${error}
    selenium_coam.activate_plan    download_plan_without_activation=${False}    activate_plan_despite_errors=${True}    timeout=${180}
    Check GNB on air
    Check Alarm List on BTS    allowed_list=${allowed_list}
    [Teardown]    WEBUI Logout

super change to nomcell
    [Arguments]  ${physCellId_list}    ${add_object_cell_num}    ${start_cell_id}    ${node_index_Diff}=5    ${copy_cell_id}=0
    FOR    ${item}    IN RANGE    ${add_object_cell_num}
        ${cell_id}    Evaluate    ${item} + ${start_cell_id}
        ${node_index}     Evaluate    ${item}+${node_index_Diff}
        ${physCellId}    Evaluate    ${item}+1
        selenium_coam.add_object    object_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}   object_class_name=NRCELL
        ...    plan_to_copy_from=CURRENT_BTS_CONF-1    copy_from=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${copy_cell_id}
        ...    include_subobject=${TRUE}    id_value=${cell_id}
        selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
        ...    filter_param=Local cell resource ID   new_value=${cell_id}    abbr=lcrId
        selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
        ...    filter_param=Physical cell identifier   new_value=${physCellId_list[${item}]}   abbr=physCellId
        selenium_coam.add_object    object_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}   object_class_name=NRCELLGRP
        ...    plan_to_copy_from=CURRENT_BTS_CONF-1    copy_from=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELLGRP-${copy_cell_id}
        ...    include_subobject=${TRUE}    id_value=${cell_id}
       selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELLGRP-${cell_id}
       ...    filter_param=List of NR cells assigned to cell group   node_index=${0}    new_value=${cell_id}    abbr=nrCellList
       selenium_coam.add_element    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRDU-1
       ...    filter_param=Reference to cell group    abbr=refNrCellGroup
       selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRDU-1
       ...    filter_param=Reference to cell group    new_value=${cell_id}   node_index=${node_index}  abbr=refNrCellGroup
       selenium_coam.add_object    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1   object_class_name=LCELNR
       ...    plan_to_copy_from=CURRENT_BTS_CONF-1    copy_from=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${copy_cell_id}
       ...    include_subobject=${TRUE}    id_value=${cell_id}
    END

Delete CHANNELGROUP
    [Arguments]  ${CHANNELGROUP_id}=1    ${cell_id}=1
    FOR    ${item}    IN RANGE    ${2}
        selenium_coam.remove_object    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id}/CHANNELGROUP-${CHANNELGROUP_id}
        ${CHANNELGROUP_id}    Evaluate    4-${cell_id}
    END


########### [1]CB010752-SR-C_005 case step#################
Modify Parameters C_05
    [Arguments]    ${delta_file}=delta    ${bts_host}=${gNB_ip}    ${connection}=GNB_connection
    Set default SCF   bts_host=${bts_host}    scf_path=${config_path}    RAT=${delta_file}.json
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    coam.perform_delta_recommissioning
    ...    delta_file=${default_scf_path}
    ...    skip_parameter_relation_errors=${True}
    ...    should_activate=${True}
    ...    timeout=${300}
    ...    connection=${connection}
    Log to console    Perform parameters done.
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}
