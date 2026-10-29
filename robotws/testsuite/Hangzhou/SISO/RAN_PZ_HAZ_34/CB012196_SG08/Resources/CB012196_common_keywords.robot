*** Settings ***
Documentation    This is for SG8 common SISO operation keywords
...              Author: zhenzhen.ren & qingqing.wang
...              Squard: HZ SG8

Library       taf.selenium.sbts    WITH NAME    selenium_coam
Library    taf.sbts.oam.coam.admin    WITH NAME    coam
Library    taf.ue    WITH NAME    taf_ue
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/operate_cell_and_check.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/BW_common_case/lib/BW_step_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/cell_addition_deletion_online.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG08_keywords_SISO_operation.robot
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common.py
Library    ../lib/CB012196_SG08.py
Variables    ../TestData/CB012196_variables.py

*** Variables ***
@{nr_cell_1}    ${1}
@{nr_cell_2}    ${2}
@{nr_cell_3}    ${3}
@{nr_cell_4}    ${4}
@{nr_cell_5}    ${5}
@{nr_cell_6}    ${6}
@{nr_cell_7}    ${7}
@{nr_cell_8}    ${8}
@{nr_cell_9}    ${9}
@{nr_cell_10}    ${10}
@{nr_cell_11}    ${11}
@{nr_cell_12}    ${12}


*** Keywords ***
Commissioning SCF And Check BTS On Air
    [Arguments]    ${scf_name}=config5
    log to console    import scf of ${scf_name}
    ${SCF_upload}    Replace String    ${Golden_SCF_Path}    .xml    _${scf_name}.xml
    COAM Commission with scf file    scf_file_path=${SCF_upload}    timeout=${600}
    Wait until keyword succeeds    15min    180s    Check all cells info should be onair
    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
    ...    connection=GNB_OAM
    should be true    ${alarm_status}
    ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist
    ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}
    should be true    ${history_alarm_status}


Config4_General_SiSo_E2E_system_setup_with_data_transfer_conducted
    log to console    make peak for cell3 under RU3
    Set qRxLevMin For cells under ru    ru_index=${3}    value=${-25}
    Set qRxLevMin For pointed NR cell    cell_id_list=${nr_cell_3}    value_call=${-40}
    data_transfer_common    tput_self_define=${tput_detail}    cell_id=${nr_cell_3}
    ...    duration=${300}
    Set qRxLevMin For pointed NR cell    cell_id_list=${nr_cell_3}    value_call=${-25}
    log to console    make peak for cell6 under RU3
    Set qRxLevMin For pointed NR cell    cell_id_list=${nr_cell_6}    value_call=${-40}
    data_transfer_common    tput_self_define=${tput_detail}    cell_id=${nr_cell_6}
    ...    duration=${600}
    Set qRxLevMin For pointed NR cell    cell_id_list=${nr_cell_6}    value_call=${-25}
    log to console    make peak for cell9 under RU3
    Set qRxLevMin For pointed NR cell    cell_id_list=${nr_cell_9}    value_call=${-40}
    data_transfer_common    tput_self_define=${tput_detail}    cell_id=${nr_cell_9}
    ...    duration=${300}
    Set qRxLevMin For pointed NR cell    cell_id_list=${nr_cell_9}    value_call=${-25}
#    log to console    make peak for cell12 under RU3
#    Set qRxLevMin For pointed NR cell    cell_id_list=${nr_cell_12}    value_call=${-40}
#    data_transfer_common    tput_self_define=${tput_detail}    cell_id=${nr_cell_12}
#    ...    duration=${600}
#    Set qRxLevMin For pointed NR cell    cell_id_list=${nr_cell_12}    value_call=${-25}


Config5_General_SiSo_E2E_system_setup_with_data_transfer_conducted
    Set PA Value For Pointed Port    PA_Port_List=${A1B1_A8B8_UE0}    value=${127}
    Set PA Value For Pointed Port    PA_Port_List=${A5B5_A8B8_RU2_UE0}   value=${20}
    log to console    make L3 call (peak is not needed) for cell2 under RU2
    Set qRxLevMin For cells under ru    ru_index=${2}    value=${-25}
    Set qRxLevMin For pointed NR cell    cell_id_list=${nr_cell_2}    value_call=${-40}
    data_transfer_common    tput_self_define=${tput_detail}    cell_id=${nr_cell_2}
    ...    duration=${600}
    Set qRxLevMin For pointed NR cell    cell_id_list=${nr_cell_2}    value_call=${-25}
    log to console    make L3 call (peak is not needed) for cell5 under RU2
    Set qRxLevMin For pointed NR cell    cell_id_list=${nr_cell_5}    value_call=${-40}
    data_transfer_common    tput_self_define=${tput_detail}    cell_id=${nr_cell_5}
    ...    duration=${300}
    Set qRxLevMin For pointed NR cell    cell_id_list=${nr_cell_5}    value_call=${-25}
    log to console    make L3 call (peak is not needed) for cell8 under RU2
    Set qRxLevMin For pointed NR cell    cell_id_list=${nr_cell_8}    value_call=${-40}
    data_transfer_common    tput_self_define=${tput_detail}    cell_id=${nr_cell_8}
    ...    duration=${600}
    Set qRxLevMin For pointed NR cell    cell_id_list=${nr_cell_8}    value_call=${-25}
    log to console    make L3 call (peak is not needed) for cell11 under RU2
    Set qRxLevMin For pointed NR cell    cell_id_list=${nr_cell_11}    value_call=${-40}
    data_transfer_common    tput_self_define=${tput_detail}    cell_id=${nr_cell_11}
    ...    duration=${300}
    Set PA Value For Pointed Port    PA_Port_List=${A5B5_A8B8_RU2_UE0}    value=${127}


Make L3 call in cell1
    Set PA Value For Pointed Port    PA_Port_List=${A1B1_A8B8_UE0}    value=${127}
    log to console    make L3 call (peak is not needed) for cell1 under RU1
    Set PA Value For Pointed Port    PA_Port_List=${A1B1_A4B4_RU1_UE0}   value=${10}
    Set qRxLevMin For cells under ru    ru_index=${1}    value=${-25}
    Set qRxLevMin For pointed NR cell    cell_id_list=${nr_cell_1}    value_call=${-40}
    data_transfer_common    tput_self_define=${tput_detail}    cell_id=${nr_cell_1}
    ...    duration=${300}    target_avg_percent=0.5    min_percent=0.3
    Set PA Value For Pointed Port    PA_Port_List=${A1B1_A4B4_RU1_UE0}    value=${127}


Make L3 call in cell2
    Set PA Value For Pointed Port    PA_Port_List=${A1B1_A8B8_UE0}    value=${127}
    log to console    make L3 call (peak is not needed) for cell2 under RU2
    Set PA Value For Pointed Port    PA_Port_List=${A5B5_A8B8_RU2_UE0}   value=${20}
    Set qRxLevMin For cells under ru    ru_index=${2}    value=${-25}
    Set qRxLevMin For pointed NR cell    cell_id_list=${nr_cell_2}    value_call=${-40}
    data_transfer_common    tput_self_define=${tput_detail}    cell_id=${nr_cell_2}
    ...    duration=${600}
    Set PA Value For Pointed Port    PA_Port_List=${A5B5_A8B8_RU2_UE0}    value=${127}


Make L3 call in cell3
    log to console    make L3 call (peak is not needed) for cell3 under RU3
    Set qRxLevMin For cells under ru    ru_index=${3}    value=${-25}
    Set qRxLevMin For pointed NR cell    cell_id_list=${nr_cell_3}    value_call=${-40}
    data_transfer_common    tput_self_define=${tput_detail}    cell_id=${nr_cell_3}
    ...    duration=${300}    target_avg_percent=0.5    min_percent=0.3


Set qRxLevMin For cells under ru
    [Arguments]    ${ru_index}=1    ${connection}=GNB_OAM    ${value}=${-25}
    log to console    start to set qrxlevmin
    ${cell_id_ru}    Get All Cell Id    ru_index=${ru_index}
    FOR  ${cell_id}  IN  @{cell_id_ru}
        wait until keyword succeeds    3x    30s    coam.perform_parameter_recommissioning
        ...    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_id}    parameter=qRxLevMin    value=${value}
        ...    operation=update    connection=${connection}
        Sleep    10s
    END


Set qRxLevMin For pointed NR cell
    [Arguments]    ${cell_id_list}    ${connection}=GNB_OAM    ${value_call}=${-40}
    log to console    start to set NR cell qrxlevmin
    FOR  ${cell_id_call}  IN  @{cell_id_list}
        wait until keyword succeeds    3x    30s    coam.perform_parameter_recommissioning
        ...    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_id_call}    parameter=qRxLevMin
        ...    value=${value_call}    operation=update    connection=${connection}
        sleep    10s
    END


Config1_General_SiSo_BB_sub_unit_lock_unlock_with_L3_call
    [Documentation]   Author:zhenzhen.ren@nokia-sbell.com;BB_Lock_Unlock and L3 call
    log to console    lock bbmod and check BTS status
    Lock BB and check status via coam
    log to console    unlock bbmod and check BTS status
    Unlock BB and check status via coam
    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
    ...    connection=GNB_OAM
    should be true    ${alarm_status}
    ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist
    ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}
    should be true    ${history_alarm_status}
    Make L3 call in cell1


Config2_General_SiSo_Online_Cell_Addition_Deletion
    Selenium Login And Disable Screen Lock
    ${ru_index_list}    Get All RU Index
    FOR  ${ru_index}  IN  @{ru_index_list}
        log to console    start to delete and add the 3rd cell of ru ${ru_index}
        ${cell_id_ru}    Get All Cell Id    ru_index=${ru_index}
        Online Cell addition deletion     addition_deletion_cell=${cell_id_ru[2]}
        ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
        should be true    ${alarm_status}
        ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist
        ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}
        should be true    ${history_alarm_status}
    END
    Make L3 call in cell2
    [Teardown]    run keyword and ignore error    Selenium Logout And Close Browser


Config4_General_SiSo_RU_lock_unlock
    ${ru_index_list}    Get All RU Index    connection=GNB_OAM
    FOR  ${ru_index}  IN  @{ru_index_list}
        ${ru_index}    Convert To Integer    ${ru_index}
        coam.lock    dist_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-${ru_index}    timeout=${300}    connection=GNB_OAM
        sleep    10s
        log to console    check Administrative state for radio unit MO is set to Locked,Operational state remains as Enabled
        run keyword and continue on failure    RU Should Be Locked    ru_index=${ru_index}
        coam.unlock    dist_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-${ru_index}    timeout=${300}    connection=GNB_OAM
        Sleep   10s
        log to console    check Administrative state for radio unit MO is set to Unlocked
        RU Should Be Unlocked    ru_index=${ru_index}
        Wait Until Keyword Succeeds    5 min    30 sec    Verify all cells should be onair
        ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
        ...    connection=GNB_OAM
        should be true    ${alarm_status}
        ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist
        ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}
        should be true    ${history_alarm_status}
    END
    Make L3 call in cell3


Config5_General_SiSo_RU_lock_unlock
    ${ru_index_list}    Get All RU Index    connection=GNB_OAM
    FOR  ${ru_index}  IN  @{ru_index_list}
        ${ru_index}    Convert To Integer    ${ru_index}
        coam.lock    dist_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-${ru_index}    timeout=${300}    connection=GNB_OAM
        sleep    10s
        log to console    check Administrative state for radio unit MO is set to Locked,Operational state remains as Enabled
        run keyword and continue on failure    RU Should Be Locked    ru_index=${ru_index}
        coam.unlock    dist_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-${ru_index}    timeout=${300}    connection=GNB_OAM
        Sleep   10s
        log to console    check Administrative state for radio unit MO is set to Unlocked
        RU Should Be Unlocked    ru_index=${ru_index}
        Wait Until Keyword Succeeds    5 min    30 sec    Verify all cells should be onair
        ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
        ...    connection=GNB_OAM
        should be true    ${alarm_status}
        ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist
        ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}
        should be true    ${history_alarm_status}
    END
    Make L3 call in cell1


Config4_General_SiSo_Cell_block_and_unblock
    ${cell_list_nr}    Get All Cell Id    cell_type=nr
    Set Test Variable    ${cell_list_nr}
    log to console    block cells and check status
    Block nr cells and check cell status
    log to console    unblock cells and check status
    Unblock nr cells and check cell status
    add fault to the allowed history fault list    faultId=${49}
    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
    should be true    ${alarm_status}
    ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist
    ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}
    should be true    ${history_alarm_status}
    Make L3 call in cell1


Config5_General_SiSo_Cell_block_and_unblock
    ${cell_list_nr}    Get All Cell Id    cell_type=nr
    Set Test Variable    ${cell_list_nr}
    Block nr cells and check cell status
    Unblock nr cells and check cell status
    add fault to the allowed history fault list    faultId=${49}
    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
    should be true    ${alarm_status}
    ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist
    ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}
    should be true    ${history_alarm_status}
    Make L3 call in cell2


add fault to the allowed history fault list
    [Arguments]    ${faultId}
    ${ALLOWED_HISTORY_FAULT_TEMP}    Copy List    ${ALLOWED_HISTORY_FAULT}
    ${fault_dic}    Create Dictionary    faultId=${faultId}
    Append To List     ${ALLOWED_HISTORY_FAULT_TEMP}    ${fault_dic}
    Set test Variable    ${ALLOWED_HISTORY_FAULT}    ${ALLOWED_HISTORY_FAULT_TEMP}


Config5_General_SiSo_BB_sub_unit_reset_with_L3_call
    Selenium Login And Disable Screen Lock
    ${bbmod_index_list}    Get All BBmod Index
    FOR  ${bbmod_index}  IN  @{bbmod_index_list}
        selenium_coam.reset_baseband    baseband_index=${bbmod_index}    timeout=30
        Wait Until Keyword Succeeds    2min    10s    bbmod Should Be Offline    bbmod_index=${bbmod_index}
    END
    Wait Until Keyword Succeeds    15 min    180 sec    Verify all cells should be onair
    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
    should be true    ${alarm_status}
    ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist
    ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}
    should be true    ${history_alarm_status}
    Make L3 call in cell3
    [Teardown]    run keyword and ignore error    Selenium Logout And Close Browser


Config5_Manual_SiSo_SM_NR_RAT_reset
    coam.rat_reset       rat_type=NR     timeout=300    connection=GNB_OAM
    Wait Until Keyword Succeeds    15 min    180 sec    Verify all cells should be onair
    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
    should be true    ${alarm_status}
    ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist
    ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}
    should be true    ${history_alarm_status}
    Make L3 call in cell1


Config5_Manual_SiSo_SM_BTS_Block_Site
    Selenium Login And Disable Screen Lock
    selenium_coam.block_site
    Wait For Expect Fault Present   faultId=${50}   timeout=300
    sleep    10s
    selenium_coam.unblock_site
    Wait Until Keyword Succeeds    15 min    180 sec    Verify all cells should be onair
    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
    should be true    ${alarm_status}
    ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist
    ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}
    should be true    ${history_alarm_status}
    Make L3 call in cell2
    [Teardown]    run keyword and ignore error    Selenium Logout And Close Browser


Config5_OAM_KPI_61a_SiSo_Auto_BTS_site_reset
    [Documentation]   site reset many times
    [Arguments]     ${Max_loop}=${20}
#    log to console    add special flag
#    add flag 0x4F0214 in swconfig file and sign    flag_0x4F0214=${0}
    FOR    ${index}    IN RANGE    ${Max_loop}
        log to console     site reset for time:${index}
        Connect to gnb coam via ssl
        coam.reset_site   connection=GNB_OAM
        sleep    120s
        Wait Until Keyword Succeeds    15 min    60 sec    Check all cells info should be onair
        log to console    check not exist unexpect active alarm and history alarm
        ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
        should be true    ${alarm_status}
        ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist
        ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}
        should be true    ${history_alarm_status}
        csn.reset_cache
    END
    [Teardown]    run keyword and ignore error   COAM Teardown gnb connections


Config5_new_case_for_cell_switching_off
    selenium login and disable screen lock
    ${activate_plan_despite_errors}    set variable if    ${if_pdl_check}    ${False}    ${True}
    ${nr_cell_id_list}    Get All Cell Id    cell_type=nr
    log to console    begin to modify some parameters,congDetectPeriod,maxNbrTrafficLimit,etc
    FOR  ${cell_id}  IN  @{nr_cell_id_list}
        log to console    begin to modify cell ${cell_id} congDetectPeriod,maxNbrTrafficLimit,etc
        wait until keyword succeeds    3x    30s    selenium_coam.set_parameter_value
        ...    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_id}
        ...    filter_param=Congestion detection period    abbr=congDetectPeriod    new_value=ms600
        wait until keyword succeeds    3x    30s    selenium_coam.set_parameter_value
        ...    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_id}
        ...    filter_param=Congestion weight algorithm    abbr=congWeightAlg    new_value=priorityLevel
        wait until keyword succeeds    3x    30s    selenium_coam.set_parameter_value
        ...    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_id}
        ...    filter_param=Maximum NBR traffic limit    abbr=maxNbrTrafficLimit    new_value=80
        wait until keyword succeeds    3x    30s    selenium_coam.set_parameter_value
        ...    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_id}
        ...    filter_param=Maximum NBR DRB PRBs per UE    abbr=maxPrbsPerNbrUe    new_value=40
        wait until keyword succeeds    3x    30s    selenium_coam.set_parameter_value
        ...    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_id}
        ...    filter_param=PDCCH congestion control for DL NBR traffic    abbr=nbrPdcchCongHandlingDl    new_value=true
        wait until keyword succeeds    3x    30s    selenium_coam.set_parameter_value
        ...    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_id}
        ...    filter_param=PDCCH congestion control for UL NBR traffic    abbr=nbrPdcchCongHandlingUl    new_value=true
        wait until keyword succeeds    3x    30s    selenium_coam.set_parameter_value
        ...    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_id}
        ...    filter_param=PDSCH congestion control for NBR traffic    abbr=nbrPdschCongHandling    new_value=true
        wait until keyword succeeds    3x    30s    selenium_coam.set_parameter_value
        ...    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_id}
        ...    filter_param=PUSCH congestion control for NBR traffic    abbr=nbrPuschCongHandling    new_value=true
    END
    log to console    begin to modify cell5 tracking area
    wait until keyword succeeds    3x    30s    selenium_coam.set_parameter_value
    ...    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-5
    ...    filter_param=Tracking Area distinguished name    abbr=trackingAreaDN
    ...    new_value=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/TRACKINGAREA-20000
    ${lbpsDayOfWeek}    ${lbpsStartTimeHour}    ${lbpsStartTimeMinute}    get_lbps_current_week_and_time
    ${Week}    ${startTime}    get_deepsleep_start_time    hour=${lbpsStartTimeHour}    minute=${lbpsStartTimeMinute}
    log to console    begin to modify lbpsDayOfWeek,lbpsStartTimeHour,etc to local time
    wait until keyword succeeds    3x    30s    selenium_coam.set_parameter_value
    ...    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRPGRP-1
    ...    filter_param=Load-based power saving day of week    abbr=lbpsDayOfWeek    new_value=${Week}
    wait until keyword succeeds    3x    30s    selenium_coam.set_parameter_value
    ...    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRPGRP-1
    ...    filter_param=Load-based power saving start time hour    abbr=lbpsStartTimeHour    new_value=${lbpsStartTimeHour}
    wait until keyword succeeds    3x    30s    selenium_coam.set_parameter_value
    ...    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRPGRP-1
    ...    filter_param=Load-based power saving start time minute    abbr=lbpsStartTimeMinute    new_value=${lbpsStartTimeMinute}
    log to console    begin to activate SCF
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=${activate_plan_despite_errors}
    log to console    begin to sleep 150s
    sleep    150s
    log to console    begin to check cell status should be energysaving
    Wait Until Keyword Succeeds    20min    5min    check all the nr cells enter energysaving
    ...    nr_cell_id_list=${nr_cell_id_list}
    log to console    begin to check cell exit sleep mode and on air
    wait until keyword succeeds    3x    30s    selenium_coam.set_parameter_value
    ...    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRPGRP-1
    ...    filter_param=Load-Based Power Saving Suspended    abbr=lbpsSuspended   new_value=suspended
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=${activate_plan_despite_errors}
    Wait Until Keyword Succeeds    5min    120s    Verify all cells should be onair    cell_type=nr
    [Teardown]    run keyword and ignore error    selenium logout and close browser


check all the nr cells enter energysaving
    [Arguments]    ${nr_cell_id_list}
    FOR    ${cell_index}    IN    @{nr_cell_id_list}
        ${cell_index}    Convert To Integer    ${cell_index}
        Check cell EnergySaving state via COAM    expect_energySavingState=energySaving    cellID=${cell_index}
    END


add flag 0x4F0214 in swconfig file and sign
    [Arguments]    ${flag_0x4F0214}
    Connect to Common Unit Master    alias=ASIK Master
    csn.download file    remote_path=/ffs/run/swconfig.txt    local_path=/tmp/swconfig.txt   connection=ASIK Master
    add_or_modify_flag_in_swconfig    flag_0x4F0214=${flag_0x4F0214}    swconfig_path=/tmp/swconfig.txt
    csn.Upload File    local_path=/tmp/swconfig.txt    remote_path=/ffs/run/swconfig.txt    connection=ASIK Master
    csn.execute    crasign /ffs/run/swconfig.txt    connection=ASIK Master
    sleep    5s
    coam.reset_site    connection=GNB_OAM
    sleep    120s
    Wait until keyword succeeds    10min    5s    verify all cells should be onair


delete flag 0x4F0214 in swconfig file and sign
    Connect to Common Unit Master    alias=ASIK Master
    csn.download file    remote_path=/ffs/run/swconfig.txt    local_path=/tmp/swconfig.txt   connection=ASIK Master
    remove_flag_in_swconfig    swconfig_path=/tmp/swconfig.txt
    csn.Upload File    local_path=/tmp/swconfig.txt    remote_path=/ffs/run/swconfig.txt    connection=ASIK Master
    csn.execute    crasign /ffs/run/swconfig.txt    connection=ASIK Master
    sleep    5s
    coam.reset_site    connection=GNB_OAM
    sleep    120s
    Wait until keyword succeeds    10min    5s    verify all cells should be onair
