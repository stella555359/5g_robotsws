*** Settings ***
Documentation    Author: Wu Fangmin
...    Contact: fangmin.wu@nokia-sbell.com
...    squad group:PZ3_SG3
...    squad: 5G_PZ_HZ_3_SG


Resource    ../../../../../../testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common_keywords.robot
Resource    ../../../../../../testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot
Resource    ../../../../../../testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource    ../../../../../../testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/coam_check_status.robot
Resource    ../../../../../../testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
Variables   ../../../../../../testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/made_variable.py
Variables    ../TestData/Bharti_variables.py
Library     taf.hw.rf_attenuator    WITH NAME    att
Library    ../TestData/Bharti_variables.py
Library    taf.ul.oam.selenium_coam    WITH NAME    selenium_coam
Library    taf.sbts.oam.coam.admin    WITH NAME    coam
Library    taf.transport.ssh    WITH NAME    csn
Library    String
Library    DateTime
Library    OperatingSystem

*** Variables ***
@{cell_id62}    ${62}
@{cell_id63}    ${63}
@{cell_id72}    ${72}
@{cell_id63_72}    ${63}  ${72}
@{RU_1}    ${1}
${cell_63}    ${63}
${cell_72}    ${72}
${connection}   COAM
${global_bts_id}           ${tl.gnbs[0].global_bts_id}
${instance_id}              ${tl.gnbs[0].instance_id}
${DU_OAM}              ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${WEBUI_USER}              ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PWD}               ${tl.gnbs[0].cu.oam_http_connection_details.password}
${ue_type}                   ${tl.ues[-1].capabilities[-1]}
${att_ipaddr}               ${tl.attenuator[0].ip_addr}
${att_port_number}         ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
${att_port_0}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
${att_port_1}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[1].port_no}
${att_port_2}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[2].port_no}
${att_port_3}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[3].port_no}
${att_port_4}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[4].port_no}
${att_port_5}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[5].port_no}
${att_port_6}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[6].port_no}
${att_port_7}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[7].port_no}
${att_port_8}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[8].port_no}
${att_port_9}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[9].port_no}
${att_port_10}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[10].port_no}
${att_port_11}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[11].port_no}
${att_port_12}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[12].port_no}
${att_port_13}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[13].port_no}
${att_port_14}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[14].port_no}
${att_port_15}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[15].port_no}
${att_api_port}             ${tl.attenuator[0].port}
${vendor}                   HBTE
${HBTE_max_value}           ${127}    ##no signal
*** Keywords ***
RU_lock_unlock
    RU_lock_unlock_execute

cell_block_unblock
    cell_block_unblock_execute

RU_lock_unlock_execute
    log to console    ++++ start lock all RUs ++++
    Selenium Login And Disable Screen Lock
    Close Start Up View    timeout=60
    Get initial Alarm and fault
    ${ru_index_list}    Get All RU Index
    FOR    ${RU_idx}    IN    @{ru_index_list}
        selenium_coam.lock_ru    ru_index=${RU_idx}
        wait until keyword succeeds    5min    20sec    RU Should Be Locked    ru_index=${RU_idx}
    END
    log to console    ++++ start unlock all RUs ++++
    FOR    ${RU_idx}    IN    @{ru_index_list}
        selenium_coam.unlock_ru    ru_index=${RU_idx}
        wait until keyword succeeds    5min    20sec    RU Should Be Unlocked    ru_index=${RU_idx}
    END
    Wait until keyword succeeds    10min    30s    verify all cells should be onair
    Adjust HBTE ATT Values    ${ATTENUATION_VALUE_default}
    Make call on NR cell
    ${status}=    run keyword and return status    Check UE DL and UL peak TP
    ${fault_id_list_new}      Get Alarm Info from WebUI      timeout=10s
    ${fault_id_list_new_length}    Get Length    ${fault_id_list_new}
	Run keyword and continue on failure    should be true    ${fault_id_list_new_length}<=${fault_id_list_0_length}

    run keyword if  ${status}==${False}    Catch_BIP_log_ASOE
    [Teardown]    Selenium Logout And Close Browser

cell_block_unblock_execute
    [Arguments]    ${alias}=GNB_OAM
    Selenium Login And Disable Screen Lock
    ${NR_cell_block_list}    Create List    ${4}  ${5}  ${15}
    ${LTE_cell_block_list}    Create List    ${1}  ${2}  ${3}
    log to console    ++++ start block cells++++
    FOR    ${idx}  IN  @{NR_cell_block_list}
        selenium_coam.block_cell    cell_idx=${idx}
        ${cellgrp_id}   Get Cell Group From Cell   cell_id=${idx}
        Wait Until Keyword Succeeds   3 min  10 sec   Cell Should Be Blocked   cell_idx=${idx}   cell_group_idx=${cellgrp_id}
        Wait For Expect Fault Present    faultId=49    timeout=120
    END
    FOR    ${idx}  IN  @{LTE_cell_block_list}
        selenium_coam.block_cell    cell_idx=${idx}    technology=LTE
        ${cellgrp_id}   Get Cell Group From Cell   cell_id=${idx}
        Wait Until Keyword Succeeds   3 min  10 sec   Cell Should Be Blocked   cell_idx=${idx}   cell_group_idx=${cellgrp_id}
        Wait For Expect Fault Present    faultId=49    timeout=120
    END
    log to console    ++++ start unblock cells ++++
    FOR    ${idx}  IN  @{NR_cell_block_list}
        selenium_coam.unblock_cell    cell_idx=${idx}
        ${cellgrp_id}   Get Cell Group From Cell   cell_id=${idx}
        Wait Until Keyword Succeeds   5 min  10 sec   cell should be unblocked   cell_idx=${idx}    cell_group_idx=${cellgrp_id}
    END
    FOR    ${idx}  IN  @{LTE_cell_block_list}
        selenium_coam.Unblock_cell    cell_idx=${idx}    technology=LTE
        ${cellgrp_id}   Get Cell Group From Cell   cell_id=${idx}
        Wait Until Keyword Succeeds   5 min  10 sec   cell should be unblocked   cell_idx=${idx}    cell_group_idx=${cellgrp_id}
    END
    Wait For Expect Fault To Disappear    faultId=49    timeout=120
    Wait until keyword succeeds    10min    30s    verify all cells should be onair
    log to console    set PA to 127 and call for Cell63
    Set PA Port Value    value=${127}
    log to console    start traffic on cell63..
    ${status1}=    run keyword and return status
    ...    data_transfer_common    tput_self_define=${tput_define}    cell_id=${cell_id63}    target_avg_percent=${0.6}
    ...    min_percent=${0.6}    loop_times=${1}    duration=${120}    tput_from=self_define
    run keyword if  ${status1}==${False}    Catch_BIP_log_ASOE
    log to console    set PA to 30 and call for CA
    Set PA Port Value    value=${30}
    log to console    start traffic on cell72...
#    run keyword and ignore error
    ${status1}=    run keyword and return status
    ...    data_transfer_common    tput_self_define=${tput_define}    cell_id=${cell_id72}     target_avg_percent=${0.6}
    ...    min_percent=${0.6}    loop_times=${1}    duration=${120}    tput_from=self_define
    run keyword if  ${status1}==${False}    Catch_BIP_log_ASOE
    [Teardown]    Selenium Logout And Close Browser

Save Full Snapshot
    [Arguments]    ${snapshot_path}=${TS_CASE_LOG_PATH}    ${connection}=GNB_OAM
    ${timestamp}    DateTime.Get Current Date    result_format=%Y%m%d%H%M
    ${snapshot_zip_file_full}    Join Path    ${snapshot_path}    snapshot_${timestamp}.zip
    coam.get_snapshot    target_file_name=${snapshot_zip_file_full}    coverage=Full    timeout=1500    connection=${connection}
    [Return]    ${snapshot_zip_file_full}

check_unexpected_alarms
    ${cell_status}    Run Keyword And Return Status    Verify all cells should be onair
    should be true    ${cell_status}
    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist
    ...    file_path=${TS_CASE_LOG_PATH}   allowed_faults=@{ALLOWED_FAULT}
    should be true    ${alarm_status}
    ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist
    ...    file_path=${TS_CASE_LOG_PATH}    allowed_faults=@{ALLOWED_HISTORY_FAULT}

Connect to DU by ADMIN API
    [Arguments]      ${connection_AdminApi}=${connection}    ${StreamVersion}=SBTS22R3
    coam.connect_to
    ...    bts_host=${DU_OAM}    name=${connection_AdminApi}
    ...    username=${WEBUI_USER}
    ...    password=${WEBUI_PWD}
    ...    release=${StreamVersion}
    [Return]   ${connection_AdminApi}

DisConnect to DU by ADMIN API
     [Arguments]      ${connection_AdminApi}=${connection}
     coam.teardown    connection=${connection_AdminApi}

cell_block_unblock_execute_new
    ${connection}    Connect to DU by ADMIN API
    Get Cell distname and id
    Get initial Alarm and fault
    FOR    ${cell}    IN    @{cell_id_list}
        Block cell and unblock cell
        ...    cell_id=${cell}     connection=${connection}
    END
    ${fault_id_list_new}      Get Alarm Info from WebUI      timeout=10s
    ${fault_id_list_new_length}    Get Length    ${fault_id_list_new}
	Run keyword and continue on failure    should be true    ${fault_id_list_new_length}<=${fault_id_list_0_length}
    Adjust HBTE ATT Values    ${ATTENUATION_VALUE_default}
    Make call on NR cell
    Run Keyword And Continue On Failure    Check UE DL and UL peak TP
    [Teardown]  run keyword and ignore error  DisConnect to DU by ADMIN API

Get Cell distname and id
    [Arguments]    ${connection}=${connection}
    [Documentation]  This KW is for get cell distname and id list
    ${cell_info_nr}=    coam.get_cells_info    cell_type=nr    timeout=30    connection=${connection}
    ${cell_info_lte}=    coam.get_cells_info    cell_type=lte    timeout=30    connection=${connection}
    @{cell_id_list}    create list
    FOR    ${elem}    IN    @{cell_info_lte}
        #Append to list    ${cell_distname_list}   ${elem['id']['configuration']}
        Append to list    ${cell_id_list}   ${elem['id']}
    END
    FOR    ${elem}    IN    @{cell_info_nr}
        #Append to list    ${cell_distname_list}   ${elem['id']['configuration']}
        Append to list    ${cell_id_list}   ${elem['id']}
    END
    Set Suite Variable    ${cell_id_list}

Block cell and unblock cell
    [Documentation]  This KW is for blocking one cell and unblocking one cell by cell distname
    [Arguments]    ${cell_id}    ${connection}
    log to console    block cell start
    wait until keyword succeeds   1min   2s    coam.block_cell
    ...    dist_name=${cell_id['configuration']}    timeout=60    connection=${connection}
    FOR    ${i}    IN RANGE    ${60}
        ${res}    run keyword and ignore error   Check Cell status
        ...    cell_internal_id=${cell_id['internal']}
        ...    timeout=30   operational_State=Disabled    procedural_Status=configured
        ...    blockingState=Blocked    administrative_State=Unlocked
        Exit For Loop If    '${res[0]}'=='PASS'
    END
    should be true    '${res[0]}'=='PASS'
    Wait For Expect Fault Present    faultId=49    timeout=120
    log to console    unblock cell start
    wait until keyword succeeds   15s   5s    coam.unblock_cell
    ...    dist_name=${cell_id['configuration']}    timeout=60    connection=${connection}
    FOR    ${i}    IN RANGE    ${600}
        ${res}    run keyword and ignore error    Check Cell status
        ...    cell_internal_id=${cell_id['internal']}    timeout=30   operational_State=Enabled
        ...    procedural_Status=configured
        ...    blockingState=Unblocked    administrative_State=Unlocked
        Exit For Loop If    '${res[0]}'=='PASS'
    END
    should be true    '${res[0]}'=='PASS'
    Wait For Expect Fault To Disappear    faultId=49    timeout=120

Check Cell status
    [Documentation]  This KW is for get one cell status and check cell onair
    [Arguments]    ${cell_internal_id}    ${timeout}    ${operational_State}=${empty}
    ...    ${procedural_Status}=${empty}    ${availability_Status}=${empty}    ${blockingState}=${empty}
    ...    ${administrative_State}=${empty}
    ${cell_info}=    coam.get_cell_specific_info
    ...   cell_id=${cell_internal_id}   timeout=30    connection=${connection}
    Run keyword if   '${operational_State}' != '${empty}'
    ...   Should be equal    ${cell_info['status']['operationalState']}    ${operational_State}    ignore_case=true
#    Run keyword if   '${procedural_Status}' != '${empty}'
#    ...   Should be equal    ${cell_info['status']['proceduralStatus']}    ${procedural_Status}     ignore_case=true
    Run keyword if   '${availability_Status}' != '${empty}'
    ...   Should be equal    ${cell_info['status']['availabilityStatus']}    ${availability_Status}    ignore_case=true
    Run keyword if   '${blockingState}' != '${empty}'
    ...   Should be equal    ${cell_info['status']['blockingState']}    ${blockingState}    ignore_case=true
    Run keyword if   '${administrative_State}' != '${empty}'
    ...   Should be equal    ${cell_info['status']['administrativeState']}    ${administrative_State}    ignore_case=true

L3 call test
    [Arguments]    ${cell_used_in_test}=None    ${remote}=${False}
    Make call on NR cell
    Run Keyword And Continue On Failure    Check UE DL and UL peak TP

Make call on NR cell
    Log To Console    \n ### Prepare UE ###
    power_ue.Prepare UE    ue_index=${0}    ue_type=${UE_TYPE}
    Log To Console    \n ### UE Attach ###
    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${0}    ue_type=${UE_TYPE}    log_type=Aasyslog
    power_ue.Verify attach    ue_type=${UE_TYPE}   5Grach_ed=${5Grach_ed_0}    4G_check=False

Check UE DL and UL peak TP
    [Arguments]    ${expect_dl_tp}=1400    ${expect_ul_tp}=85    ${dl_traffic}=1600M    ${ul_traffic}=110M
    UE start traffic   tp_direction=both   ul_tp=${ul_traffic}    dl_tp=${dl_traffic}
    sleep    10s
   	UE check throughput by syslog    tp_direction=both    exp_ul_tp=${expect_ul_tp}    exp_dl_tp=${expect_dl_tp}    check_times=60s
	Stop UE traffic and detach UE


UE Prepare
    Log To Console    \n ### Prepare UE ###
    power_ue.Prepare UE    ue_index=${0}    ue_type=${UE_TYPE}

Attach UE
    Log To Console    \n ### UE Attach ###
    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${0}    ue_type=${UE_TYPE}    log_type=Aasyslog
    power_ue.Verify attach    ue_type=${UE_TYPE}   5Grach_ed=${5Grach_ed_0}    4G_check=False

UE start traffic
    [Arguments]    ${tp_direction}=both    ${ul_tp}=100M    ${dl_tp}=100M
    log to console    UE start traffic
    Run keyword if    '${tp_direction}'=='dl' or '${tp_direction}'=='both'   power_ue.Start traffic    ue_index=${0}
    ...     direction=dl    throughput=${dl_tp}   duration=800    ue_type=${ue_type}    buffer_size=1400B
    sleep    3s
    Run keyword if    '${tp_direction}'=='ul' or '${tp_direction}'=='both'    power_ue.Start traffic    ue_index=${0}
    ...    direction=ul    throughput=${ul_tp}    duration=800    ue_type=${ue_type}    iperf_type=via_command

UE check throughput by syslog
    [Arguments]    ${tp_direction}=both    ${exp_ul_tp}=100    ${exp_dl_tp}=100    ${check_times}=60s
    log to console    UE check throughput by syslog
    AAsys log captrue    stop_aasys_flag=${False}
    sleep    ${check_times}
    ${all_tp}    Get ul and dl peak and ave throughput and return result    aasys_start_flag=${False}
    Run keyword if    '${tp_direction}'=='dl' or '${tp_direction}'=='both'    Run keyword and continue on failure
    ...      should be true    ${all_tp[1]}>${exp_dl_tp}
    Run keyword if    '${tp_direction}'=='ul' or '${tp_direction}'=='both'    Run keyword and continue on failure
    ...     should be true    ${all_tp[4]}>${exp_ul_tp}
    Set Suite Variable    ${all_tp}

Get ul and dl peak and ave throughput and return result
    [Arguments]    ${gnb_index}=0    ${du_index}=0    ${aasys_start_flag}=${true}
    ${cell_number}    Get cell numbers in gnb    gnb_index=${gnb_index}    du_index=${du_index}
    run keyword if    '${aasys_start_flag}'=='${true}'    AAsys log captrue    gnb_index=${gnb_index}
    ...    du_index=${du_index}
    ${cell_id}    Get nrcellid from aasys log    gnb_index=${gnb_index}    du_index=${du_index}
    ${dl_traffic_data}    ${ul_traffic_data}    Get traffic data from aasys log for TRUNK
    ...    gnb_index=${gnb_index}    du_index=${du_index}
    ${dl_peak_tp}    ${dl_average_tp}    ${dl_minimum_tp}    Calculate Throughput and retrun result in gnb
    ...    data=${dl_traffic_data}
    ...    cell_numbers=${cell_number}
    ${ul_peak_tp}    ${ul_average_tp}    ${ul_minimum_tp}    Calculate Throughput and retrun result in gnb
    ...    data=${ul_traffic_data}
    ...    cell_numbers=${cell_number}
    [Return]    ${dl_peak_tp}    ${dl_average_tp}    ${dl_minimum_tp}    ${ul_peak_tp}
    ...    ${ul_average_tp}    ${ul_minimum_tp}
    [teardown]    Run Keyword and Ignore Error    admin_cli.teardown    connection=COAM

Stop UE traffic and detach UE
    Log To Console    Stop traffic
    run keyword and ignore error    power_ue.Stop traffic    direction=ul    ue_index=${0}    ue_type=${UE_TYPE}
    run keyword and ignore error    power_ue.Stop traffic    direction=dl    ue_index=${0}    ue_type=${UE_TYPE}
    Log To Console    \n ### UE Detach ###
    power_ue.UE Detach    ue_index=${0}    ue_type=${UE_TYPE}


Adjust HBTE ATT Values
    [Arguments]      ${attenuation_values_of_all_ports}
    log to console    Adjust HBTE ATT Value
    att.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
    ...    attenuation_port_numbers=${att_port_1}   max_attenuation=${HBTE_max_value}    vendor=${vendor}
    FOR  ${port_num}    IN RANGE    0    16
        ${att_value}    set variable    ${attenuation_values_of_all_ports['atten_value_of_port${port_num}']}
        att.set_attenuation    port=${att_port_${port_num}}    value=${att_value}
        ${value_port}    att.read_attenuation    port=${att_port_${port_num}}
        should be equal    ${value_port}    ${att_value}
    END

Adjust HBTE ATT Values seperate
    [Arguments]      ${attenuation_values_of_all_ports}
    log to console    Adjust HBTE ATT Value
    att.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
    ...    attenuation_port_numbers=${att_port_1}   max_attenuation=${HBTE_max_value}    vendor=${vendor}
    FOR  ${port_num}    IN RANGE    0    4
        ${att_value}    set variable    ${attenuation_values_of_all_ports['atten_value_of_port${port_num}']}
        att.set_attenuation    port=${att_port_${port_num}}    value=${att_value}
        ${value_port}    att.read_attenuation    port=${att_port_${port_num}}
        should be equal    ${value_port}    ${att_value}
    END
    FOR  ${port_num}    IN RANGE    8    12
        ${att_value}    set variable    ${attenuation_values_of_all_ports['atten_value_of_port${port_num}']}
        att.set_attenuation    port=${att_port_${port_num}}    value=${att_value}
        ${value_port}    att.read_attenuation    port=${att_port_${port_num}}
        should be equal    ${value_port}    ${att_value}
    END


Get initial Alarm and fault
    ${fault_id_list_0}      Get Alarm Info from WebUI      timeout=10s
	set suite variable      ${fault_id_list_0}
	${fault_id_list_0_length}    Get Length    ${fault_id_list_0}
	set suite variable      ${fault_id_list_0_length}

Get Alarm Info from WebUI
    [Arguments]   ${timeout}    ${alias}=GNB_OAM
    Connect to gnb coam via ssl
    @{alarms}    coam.get_active_alarms    timeout=${timeout}    connection=${alias}
    sleep    1s
    log     ${alarms}
    ${fault_id_list}    create list
    ${fault_name_list}    create list
    FOR    ${item}    IN    @{alarms}
        ${fault_id}    get from dictionary    ${item}    faultId
        ${fault_name}    get from dictionary    ${item}    faultName
        append to list    ${fault_id_list}    ${fault_id}
        append to list    ${fault_name_list}    ${fault_name}
    END
    sort list    ${fault_id_list}
    [Return]   ${fault_id_list}

collect_RFSW_log_Continuous_check_unexpected_alarms
    [Arguments]   ${snapshot_path}=${TS_CASE_LOG_PATH}
    Connect to Common Unit Master
    ${ru_index_list}  Get All RU Index
    FOR  ${ru_index}  IN  @{ru_index_list}
        Connect to RU With Allocated IP  ru_index=${ru_index}  ru_alias=RU_${ru_index}
        ${log_on_ru}   Get RFSW Log File List On RU    connection=RU_${ru_index}
        csn.Disconnect  connection=RU_${ru_index}
        check_unexpected_alarms
    END
    [Teardown]  csn.Disconnect  connection=ASIK Master

General_SiSo_Beamforming_calibration_ASOE
    [Arguments]  ${check_time}=15    ${connection}=GNB_OAM
    log to console    \n***SITE Reset from GUI***
    Connect to gnb coam via ssl    connection=${connection}
    coam.reset_site    connection=${connection}
    sleep    60s
    Wait Until Keyword Succeeds    3min    5s    Connect to gnb coam via ssl
    Check All Components Status ASOE    operation_component=site    gnb_type=${gNb_CuType}
    log to console    sleep ${check_time}min to get beamforming calibration
    sleep  ${check_time}min
    ${ru_index_list}    get all ru index    connection=${connection}
    ${ru_num}    get length    ${ru_index_list}
    ${collect_file_mum}    set variable    ${0}
    FOR    ${ru_index}    IN    @{ru_index_list}
        ${status}    run keyword and return status    Collect RF Logs To TestPC    ru_index=${ru_index}    log_name=ru_fault_history_log
        run keyword if    ${status}    run keyword and continue on failure    Check fault history log    log_name=ru_fault_history_log
        ${collect_file_mum}    set variable if    not ${status}    ${collect_file_mum+1}    ${collect_file_mum}
    END
    ${bf_status}    Run Keyword And Return Status    Check RU Beamforming Status    check_count=${True}
    ...    check_ru_connect=${True}    connection=${connection}
    should be true  ${bf_status}
    should be true  ${collect_file_mum}<${ru_num}

Check All Components Status ASOE
    [Arguments]    ${operation_component}=cell   ${connection}=GNB_OAM    ${gnb_type}=${gNb_CuType}
    ...    ${smod_checktime}=5min    ${bbmod_checktime}=5min    ${rmod_checktime}=10min    ${x2link_checktime}=5min    ${cell_checktime}=15min
    ...    ${interval}=10s
    ${component_list}    create list    site    smod    bbmod    rmod    cell    no
    ${component_index}    get index from list    ${component_list}    ${operation_component}
    ${smod_checktime}    set variable if    ${component_index}<=${1}   ${smod_checktime}    ${interval}
    ${bbmod_checktime}    set variable if    ${component_index}<=${2}   ${bbmod_checktime}    ${interval}
    ${rmod_checktime}    set variable if    ${component_index}<=${3}     ${rmod_checktime}    ${interval}
    ${cell_checktime}    set variable if    ${component_index}<=${4}     ${cell_checktime}    ${interval}
    ${x2link_checktime}    set variable if    ${component_index}<=${4}     ${x2link_checktime}    ${interval}
    Wait until keyword succeeds    ${smod_checktime}    ${interval}     COAM Check GNB ASIK status     connection=${connection}
    Wait until keyword succeeds    ${rmod_checktime}    ${interval}     COAM Check GNB RU status     connection=${connection}
    Run keyword if    '${gnb_type}'!='SA'
    ...    Wait until keyword succeeds    ${x2link_checktime}    ${interval}     COAM Check X2 link status from GNB    connection=${connection}
    Wait until keyword succeeds    ${cell_checktime}    ${interval}     verify all cells should be onair    connection=${connection}

Perform_SW_rollback
    [Arguments]  ${connection}=GNB_OAM
    log to console    start rollback...
    coam.rollback_software    connection=${connection}
    sleep    2min
    COAM Wait gnb And Cells ready    timeout=15min    gnb_type='${gNb_CuType}'

Rjio_Initiate_SFP_Monitoring_from_WebEM_for_RU(dynamic_data)
    ${links}    ${SMOD}    ${BBMOD}    ${RMOD}=    Get Information about SFP links
    ${dynamic_1}=    Check_if_dynamic_parameters_have_a_valid_value_for_ports   links=${links}    dict_of_links=${RMOD}
    Sleep    120s
    ${links}    ${SMOD}    ${BBMOD}    ${RMOD}=    Get Information about SFP links
    ${dynamic_2}=    Check_if_dynamic_parameters_have_a_valid_value_for_ports   links=${links}    dict_of_links=${RMOD}

Check_if_dynamic_parameters_have_a_valid_value_for_ports
    [Arguments]    ${links}    ${dict_of_links}
    ${list_of_links}    Get Dictionary Keys    ${dict_of_links}
    &{dynamic_port}=    Create Dictionary
    FOR    ${port}    IN    @{list_of_links}
        ${dynamic_direction}=    Check_if_dynamic_parameters_have_a_valid_value_for_directions   links=${links}
        ...    dict_of_links=${dict_of_links}    port=${port}
        Set To Dictionary    ${dynamic_port}    ${port}    ${dynamic_direction}
    END
    [Return]    ${dynamic_port}

Check_if_dynamic_parameters_have_a_valid_value_for_directions
    [Arguments]    ${links}    ${dict_of_links}    ${port}
    &{dynamic_direction}=    Create Dictionary
    @{list_of_dynamic_params}=    Create List
    ${list_of_directions}=    Get From Dictionary    ${dict_of_links}    ${port}
    FOR    ${direction}    IN    @{list_of_directions}
        Run Keyword If   '${direction}'=='source'    Set Suite Variable    ${initial_direction}    initialSource
        Run Keyword If   '${direction}'=='destination'    Set Suite Variable    ${initial_direction}    initialDestination
        Set Suite Variable   ${moduleTemperature}
        ...    ${links["connected"][${port}]["data"]["measurements"]["moduleTemperature"]["${direction}"]}
        Should Be True  20<=${moduleTemperature}<=65
        Set Suite Variable   ${TXSupplyVoltage}
        ...    ${links["connected"][${port}]["data"]["measurements"]["TXSupplyVoltage"]["${direction}"]}
        Should Be True  2000<=${TXSupplyVoltage}<=4500
        Set Suite Variable   ${TXBiasCurrent}
        ...    ${links["connected"][${port}]["data"]["measurements"]["TXBiasCurrent"]["${direction}"][0]}
        Should Be True  0<=${TXBiasCurrent}<=50
        Set Suite Variable   ${TXOpticalPower}
        ...    ${links["connected"][${port}]["data"]["measurements"]["TXOpticalPower"]["${initial_direction}"][0]}
        Should Be True  300<=${TXOpticalPower}<=2000
        Set Suite Variable   ${RXOpticalPower}
        ...    ${links["connected"][${port}]["data"]["measurements"]["RXOpticalPower"]["${initial_direction}"][0]}
        Should Be True    100<=${RXOpticalPower}<=2000
        Append To List    ${list_of_dynamic_params}    ${moduleTemperature}    ${TXSupplyVoltage}
        ...    ${TXBiasCurrent}    ${RXOpticalPower}
        ...    ${TXBiasCurrent}    ${TXOpticalPower}    ${RXOpticalPower}
        Set To Dictionary    ${dynamic_direction}    ${direction}    ${list_of_dynamic_params}
    END
    [Return]    ${dynamic_direction}

# Control PC:10.71.217.204--MTK_cell63_cell72
Site_reset_with_call
    General_SiSo_Auto_BTS_site_reset
    log to console    Control PC:10.71.217.204--MTK_cell63_cell72
#    log to console    set PA to 127 and call on cell63
#    Set PA Port Value    value=${127}
#    log to console    start traffic on cell63...
##    run keyword and ignore error
#    ${status1}=    run keyword and return status
#    ...    data_transfer_common    tput_self_define=${tput_define}    cell_id=${cell_id63}    target_avg_percent=${0.8}
#    ...    min_percent=${0.7}    loop_times=${1}    duration=${120}    tput_from=self_define
#    run keyword if  ${status1}==${False}    Catch_BIP_log_ASOE
    log to console    set PA to 30 and call for CA
    Set PA Port Value    value=${30}
    log to console    start traffic on cell72...
#    run keyword and ignore error
    ${status1}=    run keyword and return status
    ...    data_transfer_common    tput_self_define=${tput_define}    cell_id=${cell_id72}     target_avg_percent=${0.6}
    ...    min_percent=${0.6}    loop_times=${1}    duration=${120}    tput_from=self_define
    run keyword if  ${status1}==${False}    Catch_BIP_log_ASOE

prach_index_190_L3_call_cell63
    [Arguments]    ${cell_id}=63
    Selenium Login And Disable Screen Lock
    ${SCF_PRACH_190}    Replace String    ${Golden_SCF_Path}    .xml    _190_1116_3ms.xml
    COAM Commission with scf file    scf_file_path=${SCF_PRACH_190}    timeout=600    is_pdl_checking_needed=${if_pdl_check}
    Wait until keyword succeeds    10min    30s    verify all cells should be onair
    log to console    Control PC:10.71.217.204--MTK_cell63_cell72
    log to console    set PA to 127 and call on cell63
    Set PA Port Value    value=${127}
    log to console    start traffic on PRACH=190_cell63...
    ${status1}    run keyword and return status
    ...    data_transfer_common    tput_self_define=${tput_define}    cell_id=${cell_id63}    target_avg_percent=${0.6}
    ...    min_percent=${0.6}    loop_times=${1}    duration=${120}    tput_from=self_define
    run keyword if  ${status1}==${False}    Catch_BIP_log_ASOE
    [Teardown]    run keywords    Selenium Logout And Close Browser  AND
    ...           Commissioning SCF And Check On Air    scf_path=${Golden_SCF_Path}

PTP failure between SM and RM reference
    ${sync_old}    get sync info of GNB
    set suite variable  ${sync_old}
    set sync info of GNB
    check sync status change of GNB
    Wait For Expect Fault Present    faultId=${16}    timeout=1200
    Wait For Expect Fault Present    faultId=${4298}    timeout=1200
#    check sync info of RU    status='abnormal'
    set sync info of GNB    syncinput=${sync_old['syncinput']}    acceptclock=${sync_old['acceptclock']}
    Wait For Expect Fault To Disappear    faultId=${16}    timeout=1200
    Wait For Expect Fault To Disappear    faultId=${4298}    timeout=1200
#    check sync info of RU    status='normal'
    Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair
    log to console    Control PC:10.71.217.204--MTK_cell63_cell72
    log to console    set PA to 127 and call on cell63
    Set PA Port Value    value=${127}
    log to console    start traffic on cell63...
    ${status1}    run keyword and return status
    ...    data_transfer_common    tput_self_define=${tput_define}    cell_id=${cell_id63}    target_avg_percent=${0.6}
    ...    min_percent=${0.6}    loop_times=${1}    duration=${120}    tput_from=self_define
    run keyword if  ${status1}==${False}    Catch_BIP_log_ASOE
#    log to console    set PA to 30 and call for CA
#    Set PA Port Value    value=${30}
#    log to console    start traffic on cell72...
#    ${status1}    run keyword and return status
#    ...    data_transfer_common    tput_self_define=${tput_define}    cell_id=${cell_id72}    target_avg_percent=${0.9}
#    ...    min_percent=${0.8}    loop_times=${1}    duration=${120}    tput_from=self_define
#    run keyword if  ${status1}==${False}    run keywords  Catch_BIP_log_ASOE  AND  catch_IQ_Data_ASOE    LOKI-part=all

Set PA Port Value
    [Arguments]    ${value}    ${attenuator_index}=${1}
    ${ports_info}    set variable    ${tl.attenuators[${attenuator_index}].attenuator_ports}
    ${ports}    Get Dictionary Keys    ${ports_info}
    ${PA}    attenuator.setup_attenuator    attenuator=${tl.attenuators[${attenuator_index}]}    alias=HBTE
    FOR    ${port}    IN    @{ports}
        attenuator.set_attenuation    port=${port}    value=${value}    attenuator_device=${PA}
    END

replace_commission_scf_to_current_bts_scf
    [Arguments]    ${connection}=GNB_OAM
    log    ${Golden_SCF_Path}
    ${local_scf_path}    set variable    ${TS_CASE_LOG_PATH}/Current_SCF
    create directory    ${local_scf_path}
    log    ${local_scf_path}
    ${current_BTS_scf}    coam.get_current_scf_file    local_dir_path=${local_scf_path}    file_name=SCF_SBTS22R3.xml    connection=${connection}
    log    ${current_BTS_scf}
    replace_scf_file_to_current_bts    current_path_file=${Golden_SCF_Path}    new_file=${current_BTS_scf}

Catch_BIP_log_ASOE
    ${timestamp}    DateTime.Get Current Date    result_format=%Y-%m-%d-%-H:%M:%S
    ${connection}    csn.connect_to    hostname=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    ...    username=${tl.gnbs[0].cu.oam_ssh_connection_details.username}
    ...    password=${tl.gnbs[0].cu.oam_ssh_connection_details.password}
    ${bip_step1}    set variable    cd /usr/bin;./lfs-nw_switch-mirror-tool.sh -S 1010 -f L1_L2_LOKIA_SNF -d 2
    ${bip_step2}    set variable    ./lfs-nw_switch-mirror-tool.sh -L
    ${bip_step3}    set variable    timeout 10 tcpdump -i nac_eth2 -w /tmp/nac_eth2_BIP_${timestamp}.pcap
    log to console    start catch BIP log ${timestamp}......
    csn.execute     command=${bip_step1};${bip_step2};${bip_step3}    connection=${connection}
    csn.disconnect    connection=${connection}
#    ${BIP_log_remote_path}    set variable    /tmp/nac_eth2_BIP_${timestamp}.pcap
#    csn.download_file    remote_path=${BIP_log_remote_path}    local_path=${RU_SOAP_log_local_dir}    connection=${alias}

catch_IQ_Data_ASOE
    [Arguments]    ${LOKI-part}    ${ASOE}=SMOD_R-1(ASOE)    ${cell_id1}=63    ${cell_id2}=72    ${subcell_id1}=2    ${subcell_id1}=7
    ...    ${PCI1}=909    ${PCI2}=911
    ${Loki-A}    set variable    A
    ${Loki-B}    set variable    B
    ${Loki-all}    set variable    all
    ${ul_cell63_cell72_index}    create list    [PCI: ${PCI1}][TDD Cell3]NRCELL_R-${cell_id1}: Subcell ${subcell_id1}
    ...    [PCI: ${PCI2}][FDD Cell2]NRCELL_R-${cell_id2}: Subcell ${subcell_id1}
#    ${ul_cell63_index}    create list    [PCI: ${PCI2}][FDD Cell2]NRCELL_R-${cell_id2}: Subcell ${subcell_id1}
    ${LOKI-A_config}    set variable    bsh 1
    ${LOKI-B_config}    set variable    bsh 2
    ${ULconfig_1}    set variable    confmgmtbrowser write NrUlPhy phyEventEnable 16
    ${ULconfig_2}    set variable    confmgmtbrowser write NrUlPhy phyEventFilterSelection 0
    ${ULconfig_3}    set variable    confmgmtbrowser write NrUlPhy phyEventFilterA 15376
    ${ULconfig_4}    set variable    confmgmtbrowser write NrUlPhy phyEventSumFilter 15376
    ${ULconfig_5}    set variable    confmgmtbrowser write NrUlPhy puschGoodSinrThreshold 5
    ${ULconfig_Loki_A}    set variable    ${LOKI-A_config};${ULconfig_1};${ULconfig_2};${ULconfig_3};${ULconfig_4};${ULconfig_5}
    ${ULconfig_Loki_B}    set variable    ${LOKI-B_config};${ULconfig_1};${ULconfig_2};${ULconfig_3};${ULconfig_4};${ULconfig_5}
    ${connection}    csn.connect_to    hostname=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    ...    username=${tl.gnbs[0].cu.oam_ssh_connection_details.username}
    ...    password=${tl.gnbs[0].cu.oam_ssh_connection_details.password}
    log to console    start catch UL IQ data......
    log    ${LOKI-A_config};${ULconfig_1};${ULconfig_2};${ULconfig_3};${ULconfig_4};${ULconfig_5}
    run keyword and ignore error
    ...    run keyword if    '${LOKI-part}'=='${Loki-A}'
    ...    csn.execute    command=${LOKI-A_config};${ULconfig_1};${ULconfig_2};${ULconfig_3};${ULconfig_4};${ULconfig_5}
    ...    connection=${connection}
    run keyword and ignore error
    ...    run keyword if    '${LOKI-part}'=='${Loki-B}'
    ...    csn.execute    command=${LOKI-B_config};${ULconfig_1};${ULconfig_2};${ULconfig_3};${ULconfig_4};${ULconfig_5}
    ...    connection=${connection}
    run keyword and ignore error
    ...    run keyword if    '${LOKI-part}'=='all'    run keywords
    ...    csn.execute    command=${ULconfig_Loki_A}    AND
    ...    ${connection1}    csn.connect_to    hostname=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    ...    username=${tl.gnbs[0].cu.oam_ssh_connection_details.username}
    ...    password=${tl.gnbs[0].cu.oam_ssh_connection_details.password}    AND
    ...    csn.execute    command=${ULconfig_Loki_B}
    log to console   start catch on WebEM
    Selenium Login And Disable Screen Lock
    selenium_coam.configure_iq_capture    bbmod=${ASOE}  ul_subcell_index=${ul_cell63_cell72_index}
    ...    dl_subcell_index=${ul_cell63_cell72_index}    enable_capture_on_event=${true}
    selenium_coam.save_iq_capture    bbmod=${ASOE}   sfn_value=${0}   slot_value=${1}
    csn.Disconnect  connection=${connection1}
    [Teardown]    run keywords    Selenium Logout And Close Browser  AND  csn.Disconnect  connection=${connection}

commission_KPI_SCF
    ${SCF_KPI}    Replace String    ${Golden_SCF_Path}    .xml    _KPI.xml
    COAM Commission with scf file    scf_file_path=${SCF_KPI}    timeout=600    is_pdl_checking_needed=${True}
    Wait until keyword succeeds    10min    30s    verify all cells should be onair

commission_origin_SCF
    COAM Commission with scf file    scf_file_path=${Golden_SCF_Path}    timeout=600    is_pdl_checking_needed=${True}
    Wait until keyword succeeds    10min    30s    verify all cells should be onair

KPI_Counter_detach_attach_HO
    [Documentation]
    ...    *****************
    ...    PA_value: if PA_value=127, call for cell63
    ...              if PA_value=30, call for cell72
    FOR   ${index}   IN RANGE   0    5
        ${start_time}    DateTime.Get Current Date    result_format=timestamp
        log    ${start_time}
        detach_attach_UE_repeat    tput_self_define=${tput_define}    cell_id=${cell_id72}    loop_times=${10}
        ${end_time}    DateTime.Get Current Date    result_format=timestamp
        log    ${end_time}
        ${elapsed_time}    DateTime.Subtract Date From Date    ${end_time}    ${start_time}
        log    ${elapsed_time}
    END
    HandOver_KPI

detach_attach_UE_repeat
    [Arguments]    ${tput_self_define}    ${ru_index}=${None}    ${cell_id}=${None}
    ...    ${gnb_index}=0    ${du_index}=0    ${loop_times}=${2}    ${alias}=ASIK MASTER    ${connection}=GNB_OAM
    ${cell_list}    run keyword if    ${cell_id}!=${None}    set variable    ${cell_id}
    ...    ELSE    Get All Cell Id    ru_index=${ru_index}
    FOR  ${i}  IN RANGE  ${loop_times}
        ${status}    run keyword and return status    RJIO_attach_detach_UE_cells    tput_info=${tput_self_define}
        ...    cell_list=${cell_list}
        ...    gnb_index=${gnb_index}    du_index=${du_index}
        ...    alias=${alias}    connection=${connection}
        exit for loop if    ${status}==${False}
    END
    run keyword if      not ${status}    FAIL

RJIO_attach_detach_UE_cells
    [Arguments]    ${tput_info}    ${cell_list}    ${gnb_index}=0    ${du_index}=0
    ...    ${alias}=ASIK MASTER    ${connection}=GNB_OAM
    ${tput_info_total}    create dictionary
    FOR  ${cell_index}  IN  @{cell_list}
        ${ue_index}    set variable    ${tput_info[${cell_index}]['ue_index']}
        log to console    use ue${ue_index} to make call on cell${cell_index}
        attch_detach_UE   ue_index=${ue_index}
        ...    gnb_index=${gnb_index}    du_index=${du_index}    alias=${alias}    connection=${connection}
    END

attch_detach_UE
    [Arguments]   ${ue_index}=0    ${gnb_index}=0    ${du_index}=0    ${alias}=ASIK MASTER    ${connection}=GNB_OAM
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    run keyword and ignore error    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
    run keyword if    '${ue_type}'=='huawei_sigspark'   prepare_aasyslog_process_RJIO    gnb_index=${gnb_index}    du_index=${du_index}
    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}    attach_mode=5G_${gNb_CuType}
    #${cell_id}    get_ue_attached_cell_id    ue_index=${ue_index}    alias=${alias}    connection=${connection}
    #log to console    ue attached to cell ${cell_id}
    run keyword and ignore error    power_ue.verify attach    ue_type=${ue_type}  ue_index=${ue_index}    4G_check=False
    power_ue.UE Detach  ue_type=${ue_type}    ue_index=${ue_index}

data_transfer_KPI
    [Arguments]    ${tput_info}    ${ru_index}=${None}    ${cell_id}=${None}    ${target_avg_percent}=${None}    ${min_percent}=${None}
    ...    ${protocol}=udp    ${duration}=${600}    ${gnb_index}=0    ${du_index}=0    ${tput_from}=tool
    ...    ${alias}=ASIK MASTER    ${connection}=GNB_OAM    ${duration_call}=${1800}   ${ue_index}=${0}
    ${avg_expect_rate}    Run Keyword If    ${target_avg_percent}==${None}    get_avg_expect_rate    ELSE
    ...    set variable    ${target_avg_percent}
    ${min_expect_rate}    Run keyword If    ${min_percent}==${None}    get_min_expect_rate    ELSE
    ...    set variable    ${min_percent}
    ${tput_info_total}    create dictionary

    log to console    use ue${ue_index} to make call on cell${cell_id}
    ${tput_cell}    run keyword if    '${tput_from}'=='tool'    get_tput_info_by_tool
    ...    cell_id=${cell_id}    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    ...    duration=${duration}    connection=${connection}    ELSE    set variable    ${tput_info[${cell_id}]}
    log to console    tput info for cell ${cell_id} is: ${tput_cell}
    set to dictionary    ${tput_info_total}    ${cell_id}    ${tput_cell}
    Set Suite Variable    ${tput_info_total}
    ${tput_info}   set variable    ${tput_cell}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    run keyword and ignore error    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
    run keyword if    '${ue_type}'=='huawei_sigspark'   prepare_aasyslog_process_RJIO    gnb_index=${gnb_index}    du_index=${du_index}
    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}    attach_mode=5G_${gNb_CuType}
    ${iperf_type}  set variable if  '${ue_type}'=='huawei'    via_app    via_command
    ${dl_tp}    set variable    ${tput_info['dl_tp']}
    ${ul_tp}    set variable    ${tput_info['ul_tp']}
    ${tput_spark}    run keyword if    '${ue_type}'=='huawei_sigspark'    generate_tput_for_spark_ue    dl_tp=${dl_tp}    ul_tp=${ul_tp}
    ${dl_tp}    run keyword if    '${ue_type}'=='huawei_sigspark'    set variable     ${tput_spark[0]}   ELSE    set variable   ${dl_tp}
    ${ul_tp}    run keyword if    '${ue_type}'=='huawei_sigspark'    set variable    ${tput_spark[1]}    ELSE    set variable   ${ul_tp}
    ${process_num}    set variable if      '${protocol}'=='udp'    ${1}    ${16}
    log to console    start dl traffic...
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${dl_tp}
    ...    protocol=${protocol}    duration=${duration_call}    ue_index=${ue_index}    process_num=${process_num}    ue_mode=${gNb_CuType}
    log to console    start ul traffic...
    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=${ul_tp}
    ...    protocol=${protocol}    duration=${duration_call}    ue_index=${ue_index}    iperf_type=${iperf_type}
    ...    data_amount=2M    ue_mode=${gNb_CuType}

collect_check_tput
    [Arguments]    ${duration}=${1200}    ${cell_id}=1    ${ue_index}=0    ${connection}=GNB_OAM
    ...    ${target_avg_percent}=${0.9}    ${min_percent}=${0.85}
     ${tput_log}    power_ue.Collect Tput    ue_type=huawei    duration=${duration}
    check_tput_for_each_cell    tput_info=${tput_info_total}    cell_id=${cell_id}    ue_index=${ue_index}    tput_log=${tput_log}
    ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}    duration=${duration}    connection=${connection}

detach_UE_stop_traffic
    [Arguments]    ${ue_index}=${0}    ${protocol}=udp
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    ${iperf_type}  set variable if  '${ue_type}'=='huawei'    via_app    via_command
    run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    ue_index=${ue_index}
    ...    protocol=${protocol}
    run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    ue_index=${ue_index}
    ...    iperf_type=${iperf_type}    protocol=${protocol}
    power_ue.UE Detach  ue_type=${ue_type}    ue_index=${ue_index}

prepare_aasyslog_process_RJIO
    [Arguments]    ${gnb_index}=0    ${du_index}=0
    Teardown the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}
    Aasyslog precondition    gnb_index=${gnb_index}    du_index=${du_index}
    Start the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}    filter=L2   log_name=5Grach.txt

HandOver_KPI
    [Arguments]    ${target_avg_percent}=${0.4}    ${min_percent}=${0.4}
#    Set PA Port Value    value=${30}
    data_transfer_KPI    tput_info=${tput_define_HO}    cell_id=${cell_72}     duration_call=${1800}
    ...    target_avg_percent=${0.8}    min_percent=${0.7}    duration=${1200}    tput_from=self_define
    log to console    start HandOver...
    # 60-30-60-30
    FOR   ${index}   IN RANGE   0    45
        Set PA Port Value    value=${60}
        sleep    10s
        Set PA Port Value    value=${30}
        sleep    10s
    END
    run keyword and ignore error
    ...    collect_check_tput    duration=${1200}    cell_id=${cell_72}    target_avg_percent=${target_avg_percent}   min_percent=${min_percent}
    detach_UE_stop_traffic

Rjio_E2E_57_Parallel_Operation_RU_Lock_And_Site_Reset
    [Arguments]    ${RU_idx}=${1}
    Selenium Login And Disable Screen Lock
    Close Start Up View    timeout=60
    selenium_coam.lock_ru    ru_index=${RU_idx}
    wait until keyword succeeds    5min    20sec    RU Should Be Locked    ru_index=${RU_idx}
#    check_unexpected_alarms
    selenium_coam.reset_site
    sleep    10min
#    selenium_coam.unlock_ru    ru_index=${RU_idx}
#    check_unexpected_alarms
    selenium_coam.unlock_ru    ru_index=${RU_idx}
    wait until keyword succeeds    5min    20sec    RU Should Be Unlocked    ru_index=${RU_idx}
    wait until keyword succeeds    10min    30s    verify all cells should be onair
    check_unexpected_alarms
    [Teardown]    run keywords
    ...    run keyword and ignore error    selenium_coam.unlock_ru    ru_index=${RU_idx}  AND
#    ...    wait until keyword succeeds    5min    20sec    RU Should Be Unlocked    ru_index=${RU_idx}    AND
    ...    Selenium Logout And Close Browser

Rjio_E2E_58_Parallel_Operation_RU_Lock_And_Parameter_Change
    [Arguments]    ${RU_idx}=${1}    ${cellid}=61    ${connection}=GNB_OAM
    Selenium Login And Disable Screen Lock
    Close Start Up View    timeout=60
    selenium_coam.lock_ru    ru_index=${RU_idx}
    wait until keyword succeeds    5min    20sec    RU Should Be Locked    ru_index=${RU_idx}
#    check_unexpected_alarms
#    sleep    2min
    log to console    start modify parameter...
#    ${qRXLevMin_origin_value}    selenium_coam.Get Parameter Value
#    ...    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cellid}    filter_param=qRxLevMin
    ${qRXLevMin_origin_value}    coam.get_parameters   dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cellid}
    ...    pattern=qRxLevMin   connection=${connection}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cellid}
    ...    filter_param=Minimum required RX level in the cell (dBm)    abbr=qRxLevMin    new_value=-70
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=${True}
#    check_unexpected_alarms
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cellid}
    ...    filter_param=Minimum required RX level in the cell (dBm)    abbr=qRxLevMin    new_value=${qRXLevMin_origin_value}
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=${True}
    selenium_coam.unlock_ru    ru_index=${RU_idx}
    wait until keyword succeeds    5min    20sec    RU Should Be Unlocked    ru_index=${RU_idx}
    wait until keyword succeeds    10min    30s    verify all cells should be onair
    check_unexpected_alarms
    [Teardown]    run keywords
    ...    run keyword and ignore error    selenium_coam.unlock_ru    ru_index=${RU_idx}  AND
#    ...    wait until keyword succeeds    5min    20sec    RU Should Be Unlocked    ru_index=${RU_idx}    AND
    ...    Selenium Logout And Close Browser

Rjio_E2E_59_Parallel_Operation_RU_Lock_And_SW_Upgrade
    [Arguments]    ${RU_idx}=${1}
    Selenium Login And Disable Screen Lock
    Close Start Up View    timeout=60
    selenium_coam.lock_ru    ru_index=${RU_idx}
    wait until keyword succeeds    5min    20sec    RU Should Be Locked    ru_index=${RU_idx}
#    selenium_coam.unlock_ru
#    wait until keyword succeeds    5min    20sec    RU Should Be Unlocked    ru_index=${RU_idx}
#    check_unexpected_alarms
    log to console    start upgrade SW by rollback...
    Perform_SW_rollback
    Perform_SW_rollback
    selenium_coam.unlock_ru
    wait until keyword succeeds    5min    20sec    RU Should Be Unlocked    ru_index=${RU_idx}
#    selenium_coam.unlock_ru
    wait until keyword succeeds    10min    30s    verify all cells should be onair
    check_unexpected_alarms
    [Teardown]    run keywords
    ...    run keyword and ignore error    selenium_coam.unlock_ru    ru_index=${RU_idx}  AND
#    ...    wait until keyword succeeds    5min    20sec    RU Should Be Unlocked    ru_index=${RU_idx}    AND
    ...    Selenium Logout And Close Browser

Rjio_E2E_60_Parallel_Operation_RU_Lock_And_RU_reset
    [Arguments]    ${RU_idx}=${1}    ${connection}=GNB_OAM    ${gnb_index}=${0}
    Selenium Login And Disable Screen Lock
    Close Start Up View    timeout=60
    selenium_coam.lock_ru    ru_index=${RU_idx}
    wait until keyword succeeds    5min    20sec    RU Should Be Locked    ru_index=${RU_idx}
#    check_unexpected_alarms
    log to console    start RU reset after RU locked...
    selenium_coam.reset_ru  ru_index=${RU_idx}
    Wait Until Keyword Succeeds    5min    5s    RU Should Be Offline    ru_index=${RU_idx}   connection=${connection}
    selenium_coam.unlock_ru
    coam wait gnb and cells ready    timeout=15min    gnb_type='${gNb_CuType}'    gnb_index=${gnb_index}    connection=${connection}
    Check RF Startup and Gnb Status    ru_index_list=${RU_1}    gnb_index=${gnb_index}    connection=${connection}
    wait until keyword succeeds    10min    30s    verify all cells should be onair
    check_unexpected_alarms
    [Teardown]    run keywords
    ...    run keyword and ignore error    selenium_coam.unlock_ru    ru_index=${RU_idx}  AND
#    ...    wait until keyword succeeds    5min    20sec    RU Should Be Unlocked    ru_index=${RU_idx}    AND
    ...    Selenium Logout And Close Browser

Rjio_E2E_61_Parallel_Operation_RU_Lock_And_Snapshot
    [Arguments]    ${RU_idx}=${1}    ${connection}=GNB_OAM    ${gnb_index}=${0}
    Selenium Login And Disable Screen Lock
    Close Start Up View    timeout=60
    selenium_coam.lock_ru    ru_index=${RU_idx}
    wait until keyword succeeds    5min    20sec    RU Should Be Locked    ru_index=${RU_idx}
#    check_unexpected_alarms
    log to console    start check snapshot info...
    check_snapshot_info_compare_RU
    selenium_coam.unlock_ru    ru_index=${RU_idx}
    wait until keyword succeeds    5min    20sec    RU Should Be Unlocked    ru_index=${RU_idx}
#    check_unexpected_alarms
    wait until keyword succeeds    10min    30s    verify all cells should be onair
    check_snapshot_info_compare_RU
    check_unexpected_alarms
    [Teardown]    run keywords
    ...    run keyword and ignore error    selenium_coam.unlock_ru    ru_index=${RU_idx}  AND
#    ...    wait until keyword succeeds    5min    20sec    RU Should Be Unlocked    ru_index=${RU_idx}    AND
    ...    Selenium Logout And Close Browser

check_snapshot_info_compare_RU
    [Arguments]    ${ru_index}=${1}    ${is_get_snapshot_via_selenium}=${True}
    Connect to Common Unit Master
    Connect to RU With Allocated IP  ru_index=${ru_index}  ru_alias=RU_${ru_index}
    Verify RFSW Log Include In Snapshot  ru_index=${ru_index}  ru_alias=RU_${ru_index}  snapshot_path=${SAVE LOG DIRECTORY}
    ...    is_get_snapshot_via_selenium=${is_get_snapshot_via_selenium}
    csn.Disconnect  connection=RU_${ru_index}
    csn.Disconnect  connection=ASIK Master

Rjio_E2E_62_Parallel_Operation_Cell_Block_And_RU_Lock_Unlock
    [Arguments]    ${cellid}=${61}    ${RU_idx}=${1}
    Selenium Login And Disable Screen Lock
    selenium_coam.block_cell    cell_idx=${cellid}
    ${cellgrp_id}   Get Cell Group From Cell   cell_id=${cellid}
    Wait Until Keyword Succeeds   3 min  10 sec   Cell Should Be Blocked   cell_idx=${cellid}   cell_group_idx=${cellgrp_id}
    Wait For Expect Fault Present    faultId=49    timeout=120
    log to console    ++++ start lock RU ++++
    Selenium Login And Disable Screen Lock
    Close Start Up View    timeout=60
    selenium_coam.lock_ru    ru_index=${RU_idx}
    wait until keyword succeeds    5min    20sec    RU Should Be Locked    ru_index=${RU_idx}
    log to console    ++++ start unlock RU ++++
    selenium_coam.unlock_ru    ru_index=${RU_idx}
    wait until keyword succeeds    5min    20sec    RU Should Be Unlocked    ru_index=${RU_idx}
    cell_unblock
    Wait until keyword succeeds    10min    30s    verify all cells should be onair
    check_unexpected_alarms
    [Teardown]    run keywords    run keyword and ignore error    cell_unblock    AND
    ...    Selenium Logout And Close Browser

cell_unblock
    [Arguments]    ${cellid}=${61}
    selenium_coam.unblock_cell    cell_idx=${cellid}
    ${cellgrp_id}   Get Cell Group From Cell   cell_id=${cellid}
    Wait Until Keyword Succeeds   5 min  10 sec   cell should be unblocked   cell_idx=${cellid}    cell_group_idx=${cellgrp_id}

Rjio_E2E_18_Radio_Unit_Restart_After_The_Software_Upgrade(_Minor)
    Perform_SW_rollback
    Perform_SW_rollback
    Wait until keyword succeeds    10min    30s    verify all cells should be onair
    General_SiSo_RF_module_reset_from_GUI

Rjio_E2E_25_Data_Call_Dl_Ul_Throughput_Check
    [Arguments]    ${cellID}=${63}
    log to console    Control PC:10.71.217.204--MTK_cell63_cell72
    log to console    set PA to 127 and call on cell63
    Set PA Port Value    value=${127}
    log to console    start traffic on cell63...
    ${status1}    run keyword and return status
    ...    data_transfer_common    tput_self_define=${tput_define_single_cell}    cell_id=${cell_id63}    target_avg_percent=${0.8}
    ...    min_percent=${0.7}    loop_times=${1}    duration=${120}    tput_from=self_define
    run keyword if  ${status1}==${False}    Catch_BIP_log_ASOE
    log to console    start block cell63...
    Selenium Login And Disable Screen Lock
    selenium_coam.block_cell    cell_idx=${cellID}
    ${cellgrp_id}   Get Cell Group From Cell   cell_id=${cellID}
    Wait Until Keyword Succeeds   3 min  10 sec   Cell Should Be Blocked   cell_idx=${cellID}   cell_group_idx=${cellgrp_id}
    Wait For Expect Fault Present    faultId=49    timeout=120
    Set PA Port Value    value=${30}
    log to console    start traffic on cell72...
    ${status2}    run keyword and return status
    ...    data_transfer_common    tput_self_define=${tput_define_single_cell}    cell_id=${cell_id72}    target_avg_percent=${0.8}
    ...    min_percent=${0.7}    loop_times=${1}    duration=${120}    tput_from=self_define
    run keyword if  ${status2}==${False}    Catch_BIP_log_ASOE
    [Teardown]    run keywords    cell_unblock    cellid=${cellID}    AND    Selenium Logout And Close Browser

Get source sw version
    #Connect to gnb coam via ssl
    #uuf_rfrl_common.Get Admin Connection    False
    ${active_sw}    uuf_rfrl_common.Get Active Sw Version    connection=GNB_OAM
    log to console  [INFO] Active software version: ${active_sw}
    Set Suite Variable    ${5G_SOURCE_SW}    ${active_sw}
    Set Suite Variable    ${5G_TARGET_SW}    ${target_version}
    coam.teardown    connection=GNB_OAM
#    log to console   [INFO] Starting SW rollback
#    admin_cli.rollback_software
#    sleep   180
#    admin_cli.teardown
#    ${soft_release}    wait until keyword succeeds    20x    30s    Get software release from targetBD
#    admin_cli.connect to
#    ...    bts_host=${bts_host}
#    ...    bts_port=443
#    ...    username=Nemuadmin
#    ...    password=nemuuser
#    ...    use_ssl=True
#    ...    release=${soft_release}
#    log to console     [INFO] Waiting for GNB to be up
#    wait until keyword succeeds    20x   60s    Check if GNB is up
#    ${rollback_sw}  admin_cli.get_sw_version
#    log to console  [INFO] New software version: ${rollback_sw}
#

Decide Scf name
    ${active_sw}    uuf_rfrl_common.Get Active Sw Version    connection=GNB_OAM
    ${release}=    Get Release By Sw Version    sw=${active_sw}
    set suite variable    ${release_id}    ${release}
    ${required_scf}=    Set Variable If    "${release_id}" == "SBTS00"    SCF_SBTS00.xml
    ...                                    "${release_id}" == "SBTS23R1"    SCF_SBTS23R1.xml
    ...                                    "${release_id}" == "SBTS23R3"    SCF_SBTS23R3.xml
    [Return]    ${required_scf}

Get Release By Sw Version
    [Arguments]    ${sw}
    [Documentation]    Author: He Winnie
    ...                Contact: winnie.he@nokia-sbell.com
    ...                Get the release information (SBTS00, SBTS 22R1, etc.) from SWB version.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${sw} | Yes | The sw version |
    ...
    ...    | Return Value | Description |
    ...    | ${RELEASE} | Release info. (SBTS00, SBTS 22R1, etc.) |
    ...
    ...    Example
    ...    |  ${release}=  |  Get Release By Sw Version  |  sw=${sw}  |
    ...
    ${sw_list}    Split String    ${sw}    _
    ${Release}    Run Keyword If    "ENB_9999" in "${sw}"
    ...    Set Variable    SBTS00
    ...    ELSE    Set Variable    ${sw_list[0]}
    Log to Console    \n***Release ${Release}***
    Set Suite Variable    ${RELEASE}    ${Release}
    [Return]    ${RELEASE}
