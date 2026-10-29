# @Time    : 2023/1/29 14:50
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @File    : siso_common_keywords.robot
# @Software: PyCharm
*** Settings ***
Documentation    This is common keywords about siso
Library     taf.selenium.sbts    WITH NAME    selenium_sbts
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/common_variables.robot
# General SISO cases
Resource    ${GENERAL_SISO_CASES_PATH}/General_SiSo_Cell_block_and_unblock.robot
Resource    ${GENERAL_SISO_CASES_PATH}/General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot.robot
Resource    ${GENERAL_SISO_CASES_PATH}/General_SiSo_RF_module_power_reset.robot
Resource    ${GENERAL_SISO_CASES_PATH}/General_SiSo_RU_module_reset_from_GUI.robot
Resource    ${GENERAL_SISO_CASES_PATH}/General_SiSo_Static_HW_Capabilities_Validation.robot
Resource    ${GENERAL_SISO_CASES_PATH}/Manual_SiSo_CM_Recommissioning.robot
Resource    ${GENERAL_SISO_CASES_PATH}/Manual_SiSo_REC_hot_remove_insert_RU_links.robot
Resource    ${GENERAL_SISO_CASES_PATH}/Manual_SiSo_SM_BTS_Block_Site.robot
Resource    ${GENERAL_SISO_CASES_PATH}/Manual_SiSo_SM_BTS_Site_Reset.robot
Resource    ${GENERAL_SISO_CASES_PATH}/Manual_SiSo_SM_NR_RAT_reset.robot
Resource    ${GENERAL_SISO_CASES_PATH}/Manual_SiSo_SM_RF_Module_lock_unlock.robot
Resource    ${GENERAL_SISO_CASES_PATH}/Manual_SiSo_SM_cell_lock_unlock_administrative_state_change_from_GUI.robot
Resource    ${GENERAL_SISO_CASES_PATH}/Manual_SiSo_STARTUP_Start-up_and_Detection_of_RF_Module.robot

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/class_monitor.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/snapshot_check.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/operate_cell_and_check.robot

*** Variables ***
${BASIC_PATH_5G}    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/5G

*** Keywords ***
SISO Common L3 CALL
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Arguments]    ${ul_tp}=100M    ${dl_tp}=300M    ${call_time}=200
    ...    ${ul_tp_threshold}=0.1    ${dl_tp_threshold}=0.1
    ...    ${log_time}=1m      ${cell_id}=0
    ...    ${actCarrierAggregation}=${True}
    ...    ${attach_mode}=SA    ${ue_index}=0

    @{list_of_cell_ids}    Create List    ${cell_id}
    # attach UE
    Run Keyword And Ignore Error    UE Attach With Verify Attach    attach_mode=${attach_mode}    ue_index=${ue_index}
    # wait 15s
    sleep    15s
    # start data transfer
    UE Start UL&DL UDP Traffic    ul_tp=${ul_tp}    dl_tp=${dl_tp}    duration=${call_time}
    ...    ue_index=${ue_index}
    # check tput
    ${list_of_cell_ids_temp}    Get All Cell Id
    Run Keyword If    ${actCarrierAggregation}==${True}
    ...    Set Suite Variable    ${list_of_cell_ids}    ${list_of_cell_ids_temp}

    ${ul_tp}    ${dl_tp}    UE Check Muiti Cells UL&DL Throughput    cells=${list_of_cell_ids}
    ...    ultarget_throughput=0
    ...    dltarget_throughput=0
    ...    ul_sum_throughput=${ul_tp_threshold}    dl_sum_throughput=${dl_tp_threshold}
    ...    duration=${log_time}    ignore_time=10s    ue_index=${ue_index}
    # stop data transfer and detach UE
    UE Stop Traffic And Release UE    sleep_time=10    ue_index=${ue_index}

#    ${ul_tp}    ${dl_tp}    SISO Common L3 CALL Without Detach    ul_tp=${ul_tp}    dl_tp=${dl_tp}    call_time=${call_time}
#    ...    ul_tp_threshold=${ul_tp_threshold}    dl_tp_threshold=${dl_tp_threshold}
#    ...    log_time=${log_time}    cell_id=${cell_id}    actCarrierAggregation=${actCarrierAggregation}
#    ...    iperf_type=${iperf_type}    attach_mode=${attach_mode}    ue_index=${ue_index}    protocol=${protocol}
#    ${ue_type}    translate power ue type from testline    ${ue_index}
#    [Teardown]    power_ue.UE Detach    ue_type=${ue_type}   ue_index=${ue_index}
    [Return]    ${ul_tp}    ${dl_tp}

SISO Common L3 CALL Without Detach
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Arguments]    ${ul_tp}=100M    ${dl_tp}=300M    ${call_time}=200
    ...    ${ul_tp_threshold}=0.1    ${dl_tp_threshold}=0.1
    ...    ${log_time}=1m      ${cell_id}=0
    ...    ${actCarrierAggregation}=${True}
    ...    ${iperf_type}=via_command    ${attach_mode}=SA    ${ue_index}=0    ${protocol}=udp
    ${ue_type}    translate power ue type from testline    ${ue_index}
    Run Keyword And Ignore Error    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}
    Run Keyword If    '${attach_mode}'=='NSA'    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    4G_check=True
    ...    ELSE    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    4G_check=False

    Run Keyword If    '${iperf_type}'=='via_command'    UE Start UL Traffic    throughput=${ul_tp}    ul_time=${call_time}
    ...    ELSE        power_ue.Start traffic    ue_index=${ue_index}    direction=ul    throughput=${ul_tp}    duration=${call_time}
  	...    ue_type=${ue_type}    iperf_type=${iperf_type}    protocol=${protocol}
    sleep    1s
    Run Keyword If    '${iperf_type}'=='via_command'    UE Start DL Traffic    throughput=${dl_tp}    dl_time=${call_time}
    ...    ELSE         power_ue.Start traffic    ue_index=${ue_index}    direction=dl    throughput=${dl_tp}    duration=${call_time}
  	...    ue_type=${ue_type}    protocol=${protocol}    buffer_size=1400B    process_num=${1}    seg_size=1350    window=16M
    sleep    2s

    ${log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=${log_time}    filter=L2Lo   ue_index=${ue_index}    check_source=aasyslog

    Connect to gnb coam via ssl
    &{NR_CELL_ID_MAPPING}    get_relation_mapping_between_cell_index_and_other_ids    connection_alias=GNB_OAM
    Set suite variable    ${NR_CELL_ID_MAPPING}
    ${list_of_cell_ids}    Get List of NR Cell ID

    ${cell_list}    create list

    Run Keyword If    ${actCarrierAggregation} == ${False}      Run Keywords
    ...        Append To List    ${cell_list}    ${list_of_cell_ids}[${cell_id}]    AND
    ...   set suite variable      ${list_of_cell_ids}       ${cell_list}


    ${ul_tp}    ${dl_tp}    power_ue.Check Bi Tput    ue_type=${ue_type}    log=${log}    cells=${list_of_cell_ids}   ue_index=${ue_index}
    ...    ultarget_throughput=${ul_tp_threshold}    dltarget_throughput=${dl_tp_threshold}
    ...    actCarrierAggregation=${actCarrierAggregation}   min_percent=0

    power_ue.Stop traffic    direction=ul    ue_index=${ue_index}    ue_type=${ue_type}    iperf_type=${iperf_type}
    power_ue.Stop traffic    direction=dl    ue_index=${ue_index}    ue_type=${ue_type}    iperf_type=${iperf_type}
    [Return]    ${ul_tp}    ${dl_tp}

MMW5_General_SiSo_Cell_block_and_unblock
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Arguments]    ${with_call}=${True}    ${with_peak}=${False}    ${iperf_type}=via_command
    Get X2 link shutdown waiting time
    Selenium Login And Disable Screen Lock
    ${cell_id_list}    Get All Cell Id
    ${cell_num}    get length    ${cell_id_list}
    MMW5 Block and UnBlock Cells and L3call    block_list=${cell_id_list}   with_call=${with_call}  with_peak=${with_peak}
    ...    iperf_type=${iperf_type}
    run keyword if    ${cell_num}>1    MMW5 Block and UnBlock Cells    block_list=${cell_id_list}
    [Teardown]    Run keywords    Run Keyword And Ignore Error    MMW5 UnBlock Cells and check status    block_list=${cell_id_list}
    ...    check_alarm=${True}    gnb_type='${gNb_CuType}'    AND    Selenium Logout And Close Browser

MMW5 Block and UnBlock Cells and L3call
    [Arguments]  ${block_list}   ${with_call}=${True}    ${iperf_type}=via_command
    ${block_num}    get length  ${block_list}
    # ${cell_id} denotes order in the {list_of_cell_ids}
    ${cell_id}  set variable  0
    FOR  ${block_id}  IN  @{block_list}
        ${check_alarm}  set variable if  ${block_num}==1  ${True}  ${False}
        ${other_cells}  Get Other Ids    id_list=${block_list}    given_id=${block_id}
        ${check_cell}  create list  ${block_id}
        ${operate_list}    set variable if  ${block_num}==1  ${check_cell}  ${other_cells}

        MMW5 Block cells and check status   block_list=${operate_list}   check_alarm=${check_alarm}    gnb_type='${gNb_CuType}'
        run keyword if  ${with_call} and ${block_num}>1
        ...    SISO Common L3 CALL   iperf_type=${iperf_type}    cell_id=${cell_id}    actCarrierAggregation=False
        ${cell_id}  Evaluate  ${cell_id}+1

        MMW5 UnBlock Cells and check status   block_list=${operate_list}   check_alarm=${check_alarm}    gnb_type='${gNb_CuType}'
    END

MMW5 Block and UnBlock Cells
    [Arguments]  ${block_list}
    MMW5 Block cells and check status    block_list=${block_list}   check_alarm=${True}  gnb_type='${gNb_CuType}'
    MMW5 UnBlock Cells and check status   block_list=${block_list}   check_alarm=${True}  gnb_type='${gNb_CuType}'

MMW5 Block cells and check status
    [Arguments]  ${block_list}   ${check_alarm}=${True}    ${gnb_type}='NSA'    ${connection}=GNB_OAM
    connect to gnb coam via ssl    connection=${connection}
    log to console  \n***Block cells and check status***
    FOR    ${idx}  IN  @{block_list}
        selenium_sbts.block_cell    cell_idx=${idx}
        ${cellgrp_id}   Get Cell Group From Cell   cell_id=${idx}
        Wait Until Keyword Succeeds   3 min  10 sec   Cell Should Be Blocked   cell_idx=${idx}   cell_group_idx=${cellgrp_id}
        Wait For Expect Fault Present    faultId=49    timeout=30
    END
    ${sleep_time}       Evaluate    ${X2_link_shutdown_time}-1
    run keyword if  ${check_alarm}==${True} and ${gNB_type}=='NSA'
    ...    run keywords  sleep    ${sleep_time}min   AND
    ...    Wait For Expect Fault Present  faultId=7300   timeout=180   AND
    ...    Wait For Expect Fault Present  faultId=7319   timeout=180

MMW5 UnBlock Cells and check status
    [Arguments]  ${block_list}  ${check_alarm}=${True}    ${gnb_type}='NSA'    ${connection}=GNB_OAM
    connect to gnb coam via ssl    connection=${connection}
    log to console  \n***unLock cells and check status***
    FOR    ${idx}  IN  @{block_list}
        selenium_sbts.unblock_cell    cell_idx=${idx}
        ${cellgrp_id}   Get Cell Group From Cell   cell_id=${idx}
        Wait Until Keyword Succeeds   5 min  10 sec   cell should be unblocked   cell_idx=${idx}    cell_group_idx=${cellgrp_id}
    END
    Wait For Expect Fault To Disappear  faultId=49    timeout=60
    run keyword if  ${check_alarm}==${True} and ${gNB_type}=='NSA'
    ...    run keywords  Wait For Expect Fault To Disappear  faultId=7300   timeout=600   AND
    ...    Wait For Expect Fault To Disappear  faultId=7319   timeout=300
    Wait Until Keyword Succeeds    10min    30s    Verify all cells should be onair

MMW5_General_SiSo_Cell_lock_and_unlock
    [Documentation]    Author: Xudong.1.li@nokia-sbell.com
    [Arguments]    ${with_call}=${True}    ${with_peak}=${False}    ${iperf_type}=via_command    ${is_group}=${False}
    Get X2 link shutdown waiting time
    Selenium Login And Disable Screen Lock
    ${cell_id_list}    Get All Cell Id
    ${cell_num}    get length    ${cell_id_list}
    MMW5 Lock and UnLock Cells and L3call    lock_list=${cell_id_list}   with_call=${with_call}  with_peak=${with_peak}
    ...    iperf_type=${iperf_type}
    run keyword if    ${cell_num}>1    Lock and Unlock all Cells or Groups  lock_list=${cell_id_list}  is_group=${False}
    [Teardown]    Run keywords    Run Keyword And Ignore Error    Unlock cells or groups and check status  lock_list=${cell_id_list}
    ...    is_group=${is_group}  check_alarm=${True}    gnb_type='${gNb_CuType}'    AND    Selenium Logout And Close Browser

MMW5_General_SiSo_Cell_lock_and_unlock_every_cells
    [Documentation]    Author: Xudong.1.li@nokia-sbell.com
    [Arguments]    ${with_call}=${True}    ${with_peak}=${False}    ${iperf_type}=via_command    ${is_group}=${False}
    Get X2 link shutdown waiting time
    Selenium Login And Disable Screen Lock
    ${cell_id_list}    Get All Cell Id
    ${cell_num}    get length    ${cell_id_list}
    MMW5 Lock and UnLock Cells and L3call    lock_list=${cell_id_list}   with_call=${with_call}  with_peak=${with_peak}
    ...    iperf_type=${iperf_type}
    [Teardown]    Run keywords    Run Keyword And Ignore Error    Unlock cells or groups and check status  lock_list=${cell_id_list}
    ...    is_group=${is_group}  check_alarm=${True}    gnb_type='${gNb_CuType}'    AND    Selenium Logout And Close Browser

MMW5 Lock and UnLock Cells and L3call
    [Documentation]    Author: Xudong.1.li@nokia-sbell.com
    [Arguments]  ${lock_list}   ${with_call}=${True}    ${iperf_type}=via_command    ${is_group}=${False}
    ${lock_num}    get length  ${lock_list}
    # ${cell_id} denotes order in the {list_of_cell_ids}
    ${cell_id}  set variable  0
    FOR  ${lock_id}  IN  @{lock_list}
        ${check_alarm}  set variable if  ${lock_num}==1  ${True}  ${False}
        ${other_cells}  Get Other Ids    id_list=${lock_list}    given_id=${lock_id}
        ${check_cell}  create list  ${lock_id}
        ${operate_list}    set variable if  ${lock_num}==1  ${check_cell}  ${other_cells}

        Lock cells or groups and check status  lock_list=${operate_list}  is_group=${is_group}  check_alarm=${check_alarm}
        ...    gnb_type='${gNb_CuType}'
        run keyword if  ${with_call} and ${lock_num}>1
        ...    SISO Common L3 CALL   iperf_type=${iperf_type}    cell_id=${cell_id}    actCarrierAggregation=False
        ${cell_id}  Evaluate  ${cell_id}+1
        Unlock cells or groups and check status  lock_list=${operate_list}  is_group=${is_group}  check_alarm=${check_alarm}
        ...    gnb_type='${gNb_CuType}'
    END

MMW5_Manual_SiSo_STARTUP_BTS_Power_Reset
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Arguments]      ${range_time}=${1}    ${iperf_type}=via_command
    FOR    ${i}    IN RANGE    ${range_time}
        Perform Site Power Off
        sleep    180s
        Perform Site Power On
        sleep    600s
        Connect to gnb coam via ssl
        Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair
        Wait Until Keyword Succeeds    10min    20 sec    COAM Check X2 link status from GNB
        csn.reset_cache
        Run Keyword And Ignore Error    SISO Common L3 CALL    iperf_type=${iperf_type}
    END

MMW5_Manual_SiSo_REC_Radio_Module_power_reset
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Arguments]    ${ru_index}=1    ${iperf_type}=via_command
    ${ru_index_list}  Get All RU Index
    FOR  ${ru_index}  IN  @{ru_index_list}
        Perform RU Power Off    ru_index=${ru_index}    model=${tl.gnbs[0].dus[0].rus[${ru_index}-1].pdu_port.pdu.vendor}
        Wait Until Keyword Succeeds    10min    1min    RU Should Be Power Off    ru_index=${ru_index}
    END
    Power On RU And Check    ru_index_list=${ru_index_list}
    Wait Until Keyword Succeeds    10min    20 sec    COAM Check X2 link status from GNB
    FOR  ${ru_index}  IN  @{ru_index_list}
        csn.reset_cache
        SISO Common L3 CALL    iperf_type=${iperf_type}
    END
    [Teardown]    Selenium Logout And Close Browser

Get Target Rmod RealTime Power Measurement
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Arguments]    ${rmod}    ${energy_efficiencys}
    FOR    ${energy_efficiency}    IN    @{energy_efficiencys}
        ${object_names}    Get Dictionary Keys    ${energy_efficiency}
        ${is_target_rmod}    Run Keyword And Return Status    Should Contain    ${object_names[0]}    ${rmod}
        ${rmod_power}    Run Keyword If    ${is_target_rmod}
        ...    Set Variable    ${energy_efficiency['${rmod}']['power']}
        Run Keyword If    ${is_target_rmod}    Exit For Loop
    END
    [Return]    ${rmod_power}

Get Once Rmod RealTime Power Measurement
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ${rmod_list}    Create List
    ${rmod_values}    Create List
    ${energy_efficiencys}    coam.get_measurements    measurement_type=realTime    connection=GNB_OAM
    FOR    ${energy_efficiency}    IN    @{energy_efficiencys}
        ${object_names}    Get Dictionary Keys    ${energy_efficiency}
        ${is_rmod}    Run Keyword And Return Status    Should Contain    ${object_names[0]}
        ...    ENERGY_EFFICIENCY/RMOD
        Run Keyword If    ${is_rmod}    Append To List    ${rmod_list}    ${object_names[0]}
    END
    Sort List    ${rmod_list}
    Log to console    ${rmod_list}
    FOR    ${rmod}    IN    @{rmod_list}
        ${rmod_value}    Get Target Rmod RealTime Power Measurement
        ...    rmod=${rmod}    energy_efficiencys=${energy_efficiencys}
        Log to console    ${rmod_value}
        Run Keyword If    '${rmod_value}'!='-'    Append To List    ${rmod_values}    ${rmod_value}
    END
    Log to console    ${rmod_values}
    [Return]    ${rmod_values}

Get Average Rmod RealTime Power Measurement
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    default number of cycles is 3
    Sleep    60s
    ${1_rmod_values}    Get Once Rmod RealTime Power Measurement
    Sleep    60s
    ${2_rmod_values}    Get Once Rmod RealTime Power Measurement
    Sleep    60s
    ${3_rmod_values}    Get Once Rmod RealTime Power Measurement
    ${average_rmod_values}    Create List
    ${rmod_length}    Get Length    ${1_rmod_values}
    FOR    ${i}    IN RANGE    ${rmod_length}
        ${average_rmod_value}    Evaluate    (${1_rmod_values[${i}]}+${2_rmod_values[${i}]}+${3_rmod_values[${i}]})/3
        Append To List    ${average_rmod_values}    ${average_rmod_value}
    END
    Log to console    ${average_rmod_values}
    [Return]    ${average_rmod_values}

MMW5_Manual_Siso_PM_5G_uDTX
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2023/09/20 14:38
    ${uDTX_false}=    create dictionary    parameterName=actMicroDTX
    ...                                         operation=update
    ...                                         value=false
    ${uDTXAdvance_false}=    create dictionary    parameterName=actMicroDTXAdvanced
    ...                                         operation=update
    ...                                         value=false
    @{parameter_false}=    create list    ${uDTX_false}    ${uDTXAdvance_false}
    Modify Parameters in the Same Object With Activate    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...    parameter=@{parameter_false}
    Sleep    100s
    ${high_rmod_powers}    Get Average Rmod RealTime Power Measurement
    ${uDTX_true}=    create dictionary    parameterName=actMicroDTX
    ...                                         operation=update
    ...                                         value=true
    ${uDTXAdvance_true}=    create dictionary    parameterName=actMicroDTXAdvanced
    ...                                         operation=update
    ...                                         value=true
    @{parameter_true}=    create list    ${uDTX_true}    ${uDTXAdvance_true}
    Modify Parameters in the Same Object With Activate    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...    parameter=@{parameter_true}
    Sleep    100s
    ${low_rmod_powers}    Get Average Rmod RealTime Power Measurement

    ${rmod_length}    Get Length    ${high_rmod_powers}
    FOR    ${i}    IN RANGE    ${rmod_length}
        ${result}    Evaluate    ${high_rmod_powers[${i}]}/${low_rmod_powers[${i}]}
        Should Be True    ${result}>1.05
    END

Check RU Info From Target Core
    [Arguments]    ${position}=left
    ...    ${asik_alias}=ASIK Master
    ...    ${core_alias}=core_alia
    ...    ${container_host_ip}=192.168.255.254
    ...    ${container_alias}=container_alia
    ...    ${ru_alias}=ru_alia
    ...    ${check_soap_file}=${False}
    ...    ${check_rfsw_log}=${False}
    ...    ${snapshot_file_list}=${EMPTY}
    Run Keyword If    '${position}'=='left'    Run Keywords
    ...    Set Test Variable    ${core_name}    fct-0a    AND
    ...    Set Test Variable    ${core_host}    0x1018

    Run Keyword If    '${position}'=='right'    Run Keywords
    ...    Set Test Variable    ${core_name}    fct-4a    AND
    ...    Set Test Variable    ${core_host}    0x2018

    # Step 1: ssh to target core (support primary core and secondary core)
    Connect To BTS Csn Via Lmp
    csn.connect_to    hostname=${core_name}
    ...               username=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    ...               password=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
    ...               alias=${core_alias}
    ...               proxy=${asik_alias}
    ${connection_service}    csn.get_connection_by_alias    alias=${core_alias}
    ${channel}    Call Method    ${connection_service}    invoke_shell

    # Step 2: get ru count
    Call Method    ${channel}    send    wc -l /ffs/run/config/FRIps.txt | awk '{print$1}'\n
    Sleep    1 sec
    ${ru_count}    Call Method    ${channel}    recv    ${65535}
    ${ru_count}    Get Line    ${ru_count}    -2
    ${ru_count_tmp}    Convert To String    ${ru_count}
    Return From Keyword If    '${ru_count_tmp}' == 'wc: /ffs/run/config/FRIps.txt: No such file or directory'
    ${ru_count}    Convert To Integer    ${ru_count}
    Call Method    ${channel}    close

    Run Keyword And Ignore Error    csn.disconnect    connection=${core_alias}
    Run Keyword And Ignore Error    csn.disconnect    connection=${asik_alias}

    FOR    ${index}    IN RANGE    ${ru_count}

        Connect To BTS Csn Via Lmp
        csn.connect_to    hostname=${core_name}
        ...               username=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
        ...               password=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
        ...               alias=${core_alias}
        ...               proxy=${asik_alias}
        ${connection_service}    csn.get_connection_by_alias    alias=${core_alias}
        ${channel}    Call Method    ${connection_service}    invoke_shell

        # Step 3: get ru ip
        ${index}    Evaluate    ${index} + 1
        Call Method    ${channel}    send    sed -n '${index}p' /ffs/run/config/FRIps.txt | awk -F';' '{print$3}'\n
        Sleep    1 sec
        ${ru_ip_addr}    Call Method    ${channel}    recv    ${65535}
        ${ru_ip_addr}    Get Line    ${ru_ip_addr}    -2
        ${ru_ip_addr}    Convert To String    ${ru_ip_addr}
        Run Keyword If    '${ru_ip_addr}'=='0.0.0.0'    Exit For Loop

        # Step 3.1: get ru serial number
        Call Method    ${channel}    send    sed -n '${index}p' /ffs/run/config/FRIps.txt | awk -F';' '{print$4}'\n
        Sleep    1 sec
        ${ru_serial_number}    Call Method    ${channel}    recv    ${65535}
        ${ru_serial_number}    Get Line    ${ru_serial_number}    1
        ${ru_serial_number}    Convert To String    ${ru_serial_number}
        ${snapshot_ru_file_list}   Get Regexp Matches   ${snapshot_file_list}   BTS\\_${ru_serial_number}\\_.*

        # Step 4: get ru type
        Call Method    ${channel}    send    sed -n '${index}p' /ffs/run/config/FRIps.txt | awk -F';' '{print$5}'\n
        Sleep    1 sec
        ${ru_type}    Call Method    ${channel}    recv    ${65535}
        ${ru_type}    Get Line    ${ru_type}    1
        ${ru_type}    Convert To String    ${ru_type}

        # Step 5: get ru username&password
        ${ru_username}    ${ru_password}    Get RU Login Info From Config Via RU Type    ${ru_type}

        # Step 6: get ru hw_group and BBmod position which RU connected to  by RU SN
        ${ru_hwGroup}    ${bb_position}    Get FH Protocol And BB Position Via RU SN    ${ru_serial_number}
        ${bb_position}    Convert To String    ${bb_position}

        #Step 7 check RU log
        &{ru_properties}    Create Dictionary    username=${ru_username}
        ...    password=${ru_password}    sn=${ru_serial_number}
        ...    ip=${ru_ip_addr}    type=${ru_type}

        Run keyword if   'obsai' in '${ru_hwGroup}'    Check OBSAI RU log
        ...    ru_ip_addr=${ru_ip_addr}    channel=${channel}
        ...    core_name=${core_name}    bb_position=${bb_position}    core_alias=${core_alias}
        ...    snapshot_file_list=${snapshot_ru_file_list}
        ...    ELSE    Check Ecpri and Cpri RU log   ru_properties=${ru_properties}
        ...    snapshot_file_list=${snapshot_ru_file_list}    channel=${channel}
        ...    check_soap_file=${check_soap_file}
        ...    check_rfsw_log=${check_rfsw_log}
        ...    container_host_ip=${container_host_ip}
        ...    container_alias=${container_alias}
        ...    ru_alias=${ru_alias}    core_alias=${core_alias}
        ...    core_host=${core_host}

        #Step 8 disconnect ssh for asik_alias and core_alias
        Run Keyword And Ignore Error    csn.disconnect    connection=${core_alias}
        Run Keyword And Ignore Error    csn.disconnect    connection=${asik_alias}
    END

    Run Keyword And Ignore Error    csn.disconnect    connection=${core_alias}
    [Teardown]    Restore Env    channel=${channel}    connection=${asik_alias}

Restore Env
    [Documentation]    author: yinhua.zhang@nokia-sbell.com
    [Arguments]    ${channel}    ${connection}
    Call Method    ${channel}    close
    Run Keyword And Ignore Error    csn.disconnect    connection=${connection}

Check OBSAI RU log
    [Documentation]    author: yinhua.zhang@nokia-sbell.com
    ...    method of login OBSAI is different from ecpri&cpri. the keyword is for OBSAI ru.
    [Arguments]    ${ru_ip_addr}    ${channel}
    ...    ${core_name}=fct-0a    ${bb_position}=1    ${core_alias}=core_alias
    ...    ${snapshot_file_list}=${EMPTY}

    # login BBMod
    Call Method    ${channel}    send    bsh ${bb_position}:0\n
    Sleep    1 sec
    ${result}    Call Method    ${channel}    recv    ${65535}
    ${result}    convert to string    ${result}
    Should contain    ${result}    asp

    # login Rmod
    Call Method    ${channel}    send    telnet ${ru_ip_addr} 2323\n
    Sleep    1 sec
    Call Method    ${channel}    recv    ${65535}

    # collect RU log
    ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    ${rfsw_log_name}    Set Variable    obsai_rfsw_log_${timestamp}.zip
    Call Method    ${channel}    send    log -c full -z ${rfsw_log_name}\n
    Sleep    180 sec
    Call Method    ${channel}    recv    ${65535}
    Call Method    ${channel}    send    ls -l\n
    Sleep    1 sec
    ${result}    Call Method    ${channel}    recv    ${65535}
    ${result}    convert to string    ${result}
    Should contain    ${result}    ${rfsw_log_name}

    # exit to BBmod
    Call Method    ${channel}    send    exit\n
    Sleep    1 sec
    ${result}    Call Method    ${channel}    recv    ${65535}
    ${result}    convert to string    ${result}
    Should contain    ${result}    asp

    # copy RU log from RU to SMOD
    Call Method    ${channel}    send    curl ftp://${ru_ip_addr}/${rfsw_log_name} -o ${rfsw_log_name}\n
    Sleep    5 sec
    Call Method    ${channel}    recv    ${65535}
    ${username}    set variable    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    ${password}    set variable    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
    Call Method    ${channel}    send    scp ${rfsw_log_name} ${username}@${core_name}:/ffs/run/config/toor4nsn/\n
    Sleep    2 sec
    ${result}    Call Method    ${channel}    recv    ${65535}
    # check if need input YES
    ${result}    convert to string    ${result}
    ${status}    Run keyword and return status    should contain    ${result}    yes/no/[fingerprint]
    Run keyword if    ${status}    Establish To Smod    channel=${channel}
    # input password
    Call Method    ${channel}    send    ${password}\n
    Sleep    2 sec
    ${result}    Call Method    ${channel}    recv    ${65535}
    Sleep    60 sec
    ${result}    convert to string    ${result}
    Should contain    ${result}    100%

    # download ru log to testPC, then will delete file from smod
    ${ru_file_path}    Set variable    /ffs/run/config/toor4nsn/${rfsw_log_name}
    ${rfsw_log_path_on_testPC}    Download RU File To TestPC    ru_file_path=${ru_file_path}
    ...    download_dir=${SUITE_LOG_PATH}    connection=${core_alias}
    ${log_on_ru}    Get RFSW Log File List On OBASI RU    rfsw_log_path_on_testPC=${rfsw_log_path_on_testPC}

    #compare RU log with in snapshot
    Sub_Check_Content_OF_Radio_Unit_Logs_IN_Snapshot    rfsw_log_names_in_snapshot=${snapshot_file_list}
    ...    log_on_ru=${log_on_ru}
    [Teardown]    Run Keyword And Ignore Error    Remove Ru Logs File from RU and BB    channel=${channel}
    ...    rfsw_log_name=${rfsw_log_name}    ru_ip_addr=${ru_ip_addr}

Establish To Smod
    [Arguments]    ${channel}
    Call Method    ${channel}    send    yes\n
    Sleep    1 sec
    ${result}    Call Method    ${channel}    recv    ${65535}
    ${result}    convert to string    ${result}
    Should contain    ${result}    Password:

Remove Ru Logs File from RU and BB
    [Documentation]    author: yinhua.zhang@nokia-sbell.com
    [Arguments]    ${channel}    ${rfsw_log_name}    ${ru_ip_addr}
    Call Method    ${channel}    send    rm ${rfsw_log_name}\n
    Sleep    1 sec
    Call Method    ${channel}    recv    ${65535}
    Call Method    ${channel}    send    telnet ${ru_ip_addr} 2323\n
    Sleep    1 sec
    Call Method    ${channel}    recv    ${65535}
    Call Method    ${channel}    send    rm ${rfsw_log_name}\n
    Sleep    1 sec
    Call Method    ${channel}    recv    ${65535}

Get RFSW Log File List On OBASI RU
    [Documentation]    author: yinhua.zhang@nokia-sbell.com
    [Arguments]    ${rfsw_log_path_on_testPC}
    Set Task Variable      ${rfsw_log_path_on_testPC}
    ${unzip_result}    Run     unzip -l ${rfsw_log_path_on_testPC} |tail -n +2
    ${vaild_lines}      Get Lines Matching Regexp    ${unzip_result}     [A-Z]\\d+_.*    partial_match=true
    ${rfsw_log_name_on_ru}    Get Regexp Matches      ${vaild_lines}    _[a-zA-Z]?.*
    [Return]    ${rfsw_log_name_on_ru}

Check Ecpri and Cpri RU log
    [Arguments]    ${ru_properties}
    ...    ${snapshot_file_list}    ${channel}
    ...    ${check_soap_file}=${False}
    ...    ${check_rfsw_log}=${False}
    ...    ${container_host_ip}=192.168.255.254
    ...    ${container_alias}=container_alia
    ...    ${ru_alias}=ru_alia    ${core_alias}=core_alia
    ...    ${core_host}=0x1018

    ${ru_username}    Set Variable    ${ru_properties['username']}
    ${ru_password}    Set Variable    ${ru_properties['password']}
    ${ru_serial_number}    Set Variable    ${ru_properties['sn']}
    ${ru_ip_addr}    Set Variable    ${ru_properties['ip']}
    ${ru_type}    Set Variable    ${ru_properties['type']}

    # Step 1: connect to container
    Call Method    ${channel}    send    lxc-attach -n ${core_host}\n
    Sleep    1 sec
    Call Method    ${channel}    recv    ${65535}

    # Step 2: check ru ping success
    Call Method    ${channel}    send    ping -c 30 -W 10 ${ru_ip_addr}\n
    Sleep    35 sec
    ${ping_result}    Call Method    ${channel}    recv    ${65535}
    ${ping_result}    Convert To String    ${ping_result}
    Should contain    ${ping_result}    30 packets transmitted, 30 received

    # Step 3: enable container ssh
    Call Method    ${channel}    send    ps -ef|grep sshd\n
    Sleep    3 sec
    ${output}    Call Method    ${channel}    recv    ${65535}
    ${output}    Convert To String    ${output}
    ${status}    Run Keyword And Return Status    Should Not Contain    ${output}    PermitRootLogin yes
    ${sshd_command}    Set Variable    /usr/sbin/sshd -p 22 -f /dev/null -o "PermitRootLogin yes" > /tmp/sshd_debug.log
    Run Keyword If    ${status}    Run Keywords    Call Method    ${channel}    send    ${sshd_command}\n    AND
    ...                                            Sleep    3 sec    AND
    ...                                            Call Method    ${channel}    recv    ${65535}
#    Call Method    ${channel}    close

    # Step 4: ssh to container
    csn.connect_to    hostname=${container_host_ip}
    ...               username=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    ...               password=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
    ...               alias=${container_alias}
    ...               proxy=${core_alias}

    # Step 5: ssh to ru
    csn.connect_to    hostname=${ru_ip_addr}
    ...               username=${ru_username}
    ...               password=${ru_password}
    ...               alias=${ru_alias}
    ...               proxy=${container_alias}

    # Step 6: check ru soapfile
    Run Keyword If    ${check_soap_file}==${True}    Check RU Soap File
    ...    ru_serial_number=${ru_serial_number}    connection=${ru_alias}

    # Step 7: check rfsw log
    Run Keyword If    ${check_rfsw_log}==${True} and '${ru_type}'!='AZQO'   Check RU RFSW Log    connection=${ru_alias}
    ...    snapshot_file_list=${snapshot_file_list}

    # Step 8: disconnect ssh
    Run Keyword And Ignore Error    csn.disconnect    connection=${ru_alias}
    Run Keyword And Ignore Error    csn.disconnect    connection=${container_alias}

Check RU RFSW Log
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2023/08/18 16:47
    [Arguments]    ${connection}    ${snapshot_file_list}=${EMPTY}
    ${log_on_ru}   Get RFSW Log File List On RU   connection=${connection}    download_dir=${SUITE_LOG_PATH}
    Sub_Check_Content_OF_Radio_Unit_Logs_IN_Snapshot    rfsw_log_names_in_snapshot=${snapshot_file_list}
    ...    log_on_ru=${log_on_ru}

Sub_Check_Content_OF_Radio_Unit_Logs_IN_Snapshot
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2023/08/10 17:18
    [Arguments]    ${rfsw_log_names_in_snapshot}    ${log_on_ru}
    ${not_include_list}    Create List
    FOR    ${item}    IN    @{log_on_ru}
       ${item_new}    String.Split String    ${item}    .
       ${status}    Run Keyword And Return Status    Should Contain Match    ${rfsw_log_names_in_snapshot}
       ...    regexp=.*${item_new}[0].*
       Run Keyword If    ${status}==${False}    Append to List    ${not_include_list}    ${item_new}[0]
    END
    ${length}    Get Length    ${not_include_list}
    Should Be Equal As Integers   ${length}   ${0}   msg=Item ${not_include_list} not include in snapshot logs

Check RU Soap File
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2023/08/18 14:57
    [Arguments]    ${ru_serial_number}    ${connection}    ${PC_soap_path}=/tmp/UnitOAM_SOAP.xml
    # Step 1: get soap file
    Wait Until Keyword Succeeds   3x   10s    getsoapfile    connection=${connection}

    # Step 2: check productCode serialNum bldVersion from soap file
    ${productCode_cmd_cat}=    Catenate    cat ${PC_soap_path} | grep productCode
    ...    | sed -n '1p' | awk -F'productCode>' '{print$2}' | awk -F'<' '{print$1}' | tr -d '\r\n'
    ${output_productCode_cmd_catSOAP}    run    command=${productCode_cmd_cat}
    ${serialNum_cmd_cat}=    Catenate    cat ${PC_soap_path} | grep serialNum |
    ...    sed -n '1p' | awk -F'serialNum>' '{print$2}' | awk -F'<' '{print$1}' | tr -d '\r\n'
    ${output_serialNum_cmd_catSOAP}    run    command=${serialNum_cmd_cat}
    ${bldVersion_cmd_cat}=    Catenate    cat ${PC_soap_path} | grep bldVersion |
    ...    sed -n '1p' | awk -F'bldVersion>' '{print$2}' | awk -F'<' '{print$1}' | tr -d '\r\n'
    ${output_bldVersion_cmd_catSOAP}    run    command=${bldVersion_cmd_cat}

    # Step 3: check rf config form webui
    Selenium Login And Disable Screen Lock
    ${ru_index_list}    Get All RU Index
    FOR    ${ru_index}    IN    @{ru_index_list}
        ${pCode_webui}  ${pName_webui}  ${pName_webui}  ${serNum_webui}  ${hwVer_webui}  ${nrBand_webui}
        ...    ${ruSW_webui}  get RF configuration from webui  ru_index=${ru_index}
        Run Keyword If    '${serNum_webui}'=='${ru_serial_number}'
        ...    Run Keywords    Set Test Variable    ${true_ru_index}    ${ru_index}    AND    Exit For Loop
    END
    ${radio_type}    get ru type    ru_index=${true_ru_index}
    ${Radio_Protocol_Type}    Get Radio Protocol    ru_index=${true_ru_index}
    ${active_version}     coam.get_sw_version    connection=GNB_OAM
    ${ruSW_expect}=    get RFSW version from TargetBD    radio_type=${radio_type}   Radio_Protocol_Type=${Radio_Protocol_Type}
    ...    active_version=${active_version}
    Should Be Equal As Strings    ${output_productCode_cmd_catSOAP}    ${pCode_webui}
    Should Be Equal As Strings    ${output_serialNum_cmd_catSOAP}    ${serNum_webui}
    Should Contain    ${output_bldVersion_cmd_catSOAP}    ${ruSW_expect}
    [Teardown]    Selenium Logout And Close Browser

Get RU Login Info From Config Via RU Type
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2023/08/17 16:53
    [Arguments]    ${ru_type}
    ${ru_index_list}    Get All RU Index
    Set Test Variable    ${username}    ${EMPTY}
    Set Test Variable    ${password}    ${EMPTY}
    FOR    ${ru_index}    IN    @{ru_index_list}
        Run Keyword If    '${tl.gnbs[0].dus[0].rus[${ru_index}-1].radio_type}'=='RadioTypes.${ru_type}'
        ...    Set Test Variable    ${username}    ${tl.gnbs[0].dus[0].rus[${ru_index}-1].default_ssh_connection_details.username}
        Run Keyword If    '${tl.gnbs[0].dus[0].rus[${ru_index}-1].radio_type}'=='RadioTypes.${ru_type}'
        ...    Set Test Variable    ${password}    ${tl.gnbs[0].dus[0].rus[${ru_index}-1].default_ssh_connection_details.password}
    END
    [Return]    ${username}    ${password}

Get FH Protocol And BB Position Via RU SN
    [Documentation]    Author: yinhua.zhang@nokia-sbell.com
    ...    obtain fronthaul protocol and bbmod position from init file.
    ...    positioner is used to indicate BB position
    [Arguments]    ${ru_sn}
    ${ru_num_in_init}    Get Length    ${tl.gnbs[0].dus[0].rus}
    FOR    ${ru_index}    IN RANGE   ${ru_num_in_init}
        ${ru_hw_group}    Set Variable If
        ...    '${tl.gnbs[0].dus[0].rus[${ru_index}].serial_number}'=='${ru_sn}'
        ...    ${tl.gnbs[0].dus[0].rus[${ru_index}].ru_hw_group}
        ${positioner}    Set Variable If
        ...    '${tl.gnbs[0].dus[0].rus[${ru_index}].serial_number}'=='${ru_sn}'
        ...    ${tl.gnbs[0].dus[0].rus[${ru_index}].positioner}
    END
    [Return]    ${ru_hw_group}    ${positioner}

MMW5_Online_Cell_addition_deletion
    [Documentation]  xudong.1.li@nokia-sbell.com
    [Arguments]  ${addition_deletion_cell}=1    ${connection}=GNB_OAM
    ${activate_plan_despite_errors}    set variable if    ${if_pdl_check}    ${False}    ${True}
    Connect to gnb coam via ssl    connection=${connection}
    ${addition_deletion_cellgrp}    Get Cell Group From Cell    cell_id=${addition_deletion_cell}    connection=${connection}
    ${cell_grp}  Get All Cell Group Id    connection=${connection}
    ${scf_path}    Download SCF Download Via Rest Api    scf_dir_path=${SAVE LOG DIRECTORY}
    selenium login and disable screen lock
    ${lcrid}    Get lcrId via webem    cell_id=${addition_deletion_cell}
    log to console  delete object
    selenium_sbts.remove_object    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${addition_deletion_cell}    timeout=15
    selenium_sbts.remove_object    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${addition_deletion_cell}    timeout=15
    selenium_sbts.remove_object    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELLGRP-${addition_deletion_cellgrp}    timeout=15
    ${cell_grp_len}    get length    ${cell_grp}
    FOR    ${index}    IN RANGE    ${cell_grp_len}
        ${value}    selenium_sbts.get_parameter_value     dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRDU-1
        ...    abbr=refNrCellGroup    filter_param=Reference to cell group
        ...    node_index=${index}
        run keyword if    '${value}'=='${addition_deletion_cellgrp}'    selenium_sbts.remove_element
        ...    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRDU-1
        ...    abbr=refNrCellGroup    filter_param=Reference to cell group
        ...    node_index=${index}
    END
    selenium_sbts.validate_plan
    selenium_sbts.activate_plan    activate_plan_despite_errors=${activate_plan_despite_errors}
    COAM Check GNB cell on air
    selenium_sbts.load_commissioning_file_and_check_load_status    file_path=${scf_path}
    selenium_sbts.get_planned_parameter_value    dist_name=MRBTS-${mrbtsID}  filter_param=BTS name  abbr=btsName
    ...    bts_configuration=Current
    log to console  add object
    selenium_sbts.add_object    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1
    ...    object_class_name=LCELNR    plan_to_copy_from=CONF-1
    ...    copy_from=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${addition_deletion_cell}
    ...    include_subobject=${True}   id_value=${addition_deletion_cell}    timeout=15
    selenium_sbts.add_object    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    ...    object_class_name=NRCELL    plan_to_copy_from=CONF-1
    ...    copy_from=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${addition_deletion_cell}
    ...    include_subobject=${True}   id_value=${addition_deletion_cell}    timeout=15
    selenium_sbts.add_object    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    ...    object_class_name=NRCELLGRP    plan_to_copy_from=CONF-1
    ...    copy_from=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELLGRP-${addition_deletion_cellgrp}
    ...    id_value=${addition_deletion_cellgrp}    timeout=15
    selenium_sbts.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${addition_deletion_cell}
    ...    filter_param=Local cell resource ID    abbr=lcrId    new_value=${lcrid}
    # recover NRDU-1 as prev
    selenium_sbts.add_element    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRDU-1
    ...    abbr=refNrCellGroup    filter_param=Reference to cell group
    ...    timeout=15
    FOR    ${index}    IN RANGE    ${cell_grp_len}
        selenium_sbts.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRDU-1
        ...    filter_param=Reference to cell group     new_value=${cell_grp[${index}]}
        ...    node_index=${index}
    END
    selenium_sbts.validate_plan
    selenium_sbts.activate_plan    activate_plan_despite_errors=${activate_plan_despite_errors}
    [Teardown]  Run Keyword And Ignore Error    selenium logout and close browser

MMW5_Online_OneCell_Deletion
    [Documentation]  xudong.1.li@nokia-sbell.com
    [Arguments]  ${deletion_cell}=1    ${connection}=GNB_OAM
    ${activate_plan_despite_errors}    set variable if    ${if_pdl_check}    ${False}    ${True}
    Connect to gnb coam via ssl    connection=${connection}
    ${deletion_cellgrp}    Get Cell Group From Cell    cell_id=${deletion_cell}    connection=${connection}
    ${cell_grp}  Get All Cell Group Id    connection=${connection}
#    ${scf_path}    Download SCF Download Via Rest Api    scf_dir_path=${SAVE LOG DIRECTORY}
    selenium login and disable screen lock
    ${lcrid}    Get lcrId via webem    cell_id=${deletion_cell}
    log to console  delete object
    selenium_sbts.remove_object    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${deletion_cell}    timeout=15
    selenium_sbts.remove_object    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${deletion_cell}    timeout=15
    selenium_sbts.remove_object    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELLGRP-${deletion_cell}    timeout=15
    ${cell_grp_len}    get length    ${cell_grp}
    FOR    ${index}    IN RANGE    ${cell_grp_len}
        ${value}    selenium_sbts.get_parameter_value     dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRDU-1
        ...    abbr=refNrCellGroup    filter_param=Reference to cell group
        ...    node_index=${index}
        run keyword if    '${value}'=='${deletion_cellgrp}'    selenium_sbts.remove_element
        ...    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRDU-1
        ...    abbr=refNrCellGroup    filter_param=Reference to cell group
        ...    node_index=${index}
    END
    selenium_sbts.validate_plan
    selenium_sbts.activate_plan    activate_plan_despite_errors=${activate_plan_despite_errors}
    COAM Check GNB cell on air
    [Teardown]  Run Keyword And Ignore Error    selenium logout and close browser

MMW5_Manual_SiSo_Online_Cell_addition_deletion_and_L3call
    [Documentation]    Author: xudong.1.li@nokia-sbell.com
    [Arguments]      ${addition_deletion_cell}=${1}  ${iperf_type}=via_command    ${attach_mode}=SA
    MMW5_Online_Cell_addition_deletion    addition_deletion_cell=${addition_deletion_cell}
    Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair
    ${status}    Run Keyword And Return Status    Should Be Equal As Strings    ${attach_mode}    NSA
    Run Keyword If    ${status}    Wait Until Keyword Succeeds    10min    20 sec    COAM Check X2 link status from GNB
    SISO Common L3 CALL    iperf_type=${iperf_type}    attach_mode=${attach_mode}
    [Teardown]    Run Keyword And Ignore Error    Selenium Logout And Close Browser
