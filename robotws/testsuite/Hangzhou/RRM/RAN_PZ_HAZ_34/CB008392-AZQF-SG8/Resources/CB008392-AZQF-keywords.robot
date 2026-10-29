*** Settings ***
Documentation    This is for CB007833-5G-A-td-Cpri-Amber keywords
...              Author: Gao melinda
...              Contact: melinda.gao@nokia-sbell.com
...              squad: 5G_PZ_HZ_8_SG


Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/recommissioning_and_make_throughput.robot
Library    ../TestData/variables_CB008392_AZQF.py
Library    taf.ul.oam.selenium_coam    WITH NAME    selenium_coam
Library    taf.sbts.oam.coam.admin    WITH NAME    coam
Library    String
Library    DateTime
Library    OperatingSystem
#Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/common/admin_operation.py
Variables    ../TestData/variables_CB008392_AZQF.py

*** Variables ***
@{cell_id1}    ${1}
@{cell_id3}    ${3}
*** Keywords ***
case_preparion_active_CB008392
#    [Arguments]    ${flag_activate}=true
    Selenium Login And Disable Screen Lock
    ${flag_status}    check_CB008392_feature_flag_status
    Selenium Logout And Close Browser
    Run Keyword If    '${flag_status}'=='false'
    ...    Run Keywords
    ...    selenium_set_8392_flag    AND    Log    ${flag_status}
    ...    ELSE    Log    ${flag_status}
#    set_lbps_time_by_selenium    lbpsDuration=720
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    [Teardown]    Selenium Logout And Close Browser

set_lbps_time_by_selenium
    [Arguments]    ${lbpsDuration}=60    ${NRPGRP}=1
    ${lbpsDayOfWeek}    ${lbpsStartTimeHour}    ${lbpsStartTimeMinute}    get_lbps_current_time
    log to console    start set lbps time duration:${lbpsDuration}, day:${lbpsDayOfWeek}, hour:${lbpsStartTimeHour}, min:${lbpsStartTimeMinute}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRPGRP-${NRPGRP}
    ...    filter_param=Load-based power saving day of week    abbr=lbpsDayOfWeek    new_value=${lbpsDayOfWeek}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRPGRP-${NRPGRP}
    ...    filter_param=Load-based power saving duration    abbr=lbpsDuration    new_value=${lbpsDuration}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRPGRP-${NRPGRP}
    ...    filter_param=Load-based power saving start time hour    abbr=lbpsStartTimeHour    new_value=${lbpsStartTimeHour}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRPGRP-${NRPGRP}
    ...    filter_param=Load-based power saving start time minute    abbr=lbpsStartTimeMinute    new_value=${lbpsStartTimeMinute}
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=${True}

set_lbps_time_by_selenium_without_validate
    [Arguments]    ${lbpsDuration}=60    ${NRPGRP}=1
    ${lbpsDayOfWeek}    ${lbpsStartTimeHour}    ${lbpsStartTimeMinute}    get_lbps_current_time
    log to console    start set lbps time duration:${lbpsDuration}, day:${lbpsDayOfWeek}, hour:${lbpsStartTimeHour}, min:${lbpsStartTimeMinute}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRPGRP-${NRPGRP}
    ...    filter_param=Load-based power saving day of week    abbr=lbpsDayOfWeek    new_value=${lbpsDayOfWeek}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRPGRP-${NRPGRP}
    ...    filter_param=Load-based power saving duration    abbr=lbpsDuration    new_value=${lbpsDuration}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRPGRP-${NRPGRP}
    ...    filter_param=Load-based power saving start time hour    abbr=lbpsStartTimeHour    new_value=${lbpsStartTimeHour}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRPGRP-${NRPGRP}
    ...    filter_param=Load-based power saving start time minute    abbr=lbpsStartTimeMinute    new_value=${lbpsStartTimeMinute}

#set_lbpstime_by_coam
#    [Arguments]    ${NRPGRP}=2    ${lbpsDuration}=60    ${connection}=GNB_OAM
#    ${lbpsDayOfWeek}    ${lbpsStartTimeHour}    ${lbpsStartTimeMinute}    get_lbps_current_time
#    coam.perform_parameter_recommissioning        dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRPGRP-${NRPGRP}
#    ...                                            parameter=lbpsDayOfWeek
#    ...                                            value=${lbpsDayOfWeek}
#    ...                                            operation=update
#    ...                                            connection=${connection}
#    coam.perform_parameter_recommissioning        dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRPGRP-${NRPGRP}
#    ...                                            parameter=lbpsDuration
#    ...                                            value=${lbpsDuration}
#    ...                                            operation=update
#    ...                                            connection=${connection}
#    coam.perform_parameter_recommissioning        dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRPGRP-${NRPGRP}
#    ...                                            parameter=lbpsStartTimeHour
#    ...                                            value=${lbpsStartTimeHour}
#    ...                                            operation=update
#    ...                                            connection=${connection}
#    coam.perform_parameter_recommissioning        dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRPGRP-${NRPGRP}
#    ...                                            parameter=lbpsStartTimeMinute
#    ...                                            value=${lbpsStartTimeMinute}
#    ...                                            operation=update
#    ...                                            connection=${connection}

CB008392 change fbMinThreshold_min value
    [Arguments]    ${init_value}    ${target_value}    ${ru_index}=1
    log to console    \n Modify fbMinThreshold_min Value In Json File
    Connect to Common Unit Master
    csn.send_command    command=rm /user/toor4nsn/.ssh/known_hosts    connection=ASIK Master
    Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}    asik_alias=ASIK Master
    ${cmd_temp}   Set Variable  echo "/ action create ConfigAccess /ca /module"|frmonShellClient 127.0.0.1 2000
    ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    Should Contain Any   ${output}    done ok    Path already taken
    sleep    2s
    ${cmd_temp}   Set Variable    echo '/ca action fetch DECODED "gc.bin" "/ram/gc.json"'|frmonShellClient 127.0.0.1 2000
    ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    Should Contain   ${output}    done ok
    sleep    2s
    ${cmd_temp}   Set Variable    cat /ram/gc.json | grep -i fbMinThreshold_min
    ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    log to console  before Modify fbMinThreshold_min:\n ${output}
    sleep    2s
    csn.Send command
    ...    command=sed -i 's/"fbMinThreshold_min": ${init_value},/"fbMinThreshold_min": ${target_value},/' /ram/gc.json
    ...    connection=RU_${ru_index}
    sleep    2s
    ${cmd_temp}   Set Variable    cat /ram/gc.json | grep -i fbMinThreshold_min
    ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    log to console  after Modify fbMinThreshold_min:\n ${output}
    sleep    2s
    ${cmd_temp}   Set Variable    echo '/ca action store DECODED "gc.bin" "/ram/gc.json"'|frmonShellClient 127.0.0.1 2000
    ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    Should Contain   ${output}    done ok
    sleep    2s
    ${cmd_temp}   Set Variable  echo "/ca action update"|frmonShellClient 127.0.0.1 2000
    ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    Should Contain   ${output}    done ok
    sleep    2s
    csn.disconnect    connection=RU_${ru_index}
    [Teardown]    csn.disconnect    connection=ASIK Master

CB008392-A Cell degraded due to cell and BTS level alarm
    case_preparion_active_CB008392
    Change lbpsPeriodList by Coam    NRPGRP_index=1
    Wait Until Keyword Succeeds    5min    30s    Check cell EnergySaving state via COAM    expect_energySavingState=reducedEnergySaving    cellID=1
    Wait Until Keyword Succeeds    5min    30s    Check cell EnergySaving state via COAM    expect_energySavingState=reducedEnergySaving    cellID=3
    CB008392 change fbMinThreshold_min value    init_value=-60.0    target_value=-10.0
    coam.lock    dist_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-1    timeout=${300}    connection=GNB_OAM
    sleep    5s
    wait until keyword succeeds    5min    20sec    RU Should Be Locked    ru_index=1
    sleep    30s
    coam.unlock    dist_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-1    timeout=${300}    connection=GNB_OAM
    sleep    3min
    log to console    reset ru1
    Selenium Login And Disable Screen Lock
    selenium_coam.reset_ru    ru_index=1
    sleep    10s
#    Wait until keyword succeeds    6min    20sec    Expect Fault Should Present    faultId=1907
#    Wait until keyword succeeds    6min    20sec    Expect Fault Should Present    faultId=4003
    Wait Until Keyword Succeeds    5min    30s    Check cell EnergySaving state via COAM    cellID=3
    sleep    12min
    Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair
    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
    should be true    ${alarm_status}
    Wait Until Keyword Succeeds    5min    30s    Check cell EnergySaving state via COAM    expect_energySavingState=reducedEnergySaving    cellID=1
    Wait Until Keyword Succeeds    5min    30s    Check cell EnergySaving state via COAM    expect_energySavingState=reducedEnergySaving    cellID=3
    [Teardown]    Selenium Logout And Close Browser

CB008392-A_3_Feature_CB008392_Deactivation_with_cell_in_reducedEnergySaving_state
    case_preparion_active_CB008392
    Selenium Login And Disable Screen Lock
    set_lbps_time_by_selenium    lbpsDuration=720
    Selenium Logout And Close Browser
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    sleep    5min
    ${cell1_energysaving_status}    check_cell_power_saving_status    cell_index=1
    should be equal    ${cell1_energysaving_status}    reducedEnergySaving
    ${cell3_energysaving_status}    check_cell_power_saving_status    cell_index=3
    should be equal    ${cell3_energysaving_status}    reducedEnergySaving
    selenium_set_8392_flag    8392-flag=false
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    sleep    1min
    ${cell1_off_energysaving_status}    check_cell_power_saving_status    cell_index=1
    should be equal    ${cell1_off_energysaving_status}    notEnergySaving
    ${cell3_off_energysaving_status}    check_cell_power_saving_status    cell_index=3
    should be equal    ${cell3_off_energysaving_status}    notEnergySaving
    [Teardown]    run keywords      selenium_set_8392_flag    8392-flag=false   AND    Selenium Logout And Close Browser

CB008392-A_15_View_Power_Saving_Performance_Management_Counters
    [Arguments]    ${counter1}=M55601C02001    ${counter2}=M55601C02002
    selenium_set_8392_flag    8392-flag=false
    sleep    5s
    case_preparion_active_CB008392
    Selenium Login And Disable Screen Lock
    set_lbps_time_by_selenium    lbpsDuration=30
    sleep    15min
    ${btsName}    selenium_coam.get_bts_name
    ${counter1_path_cell1}    Set Variable     [${btsName}] MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/[CellName1] NRCELL-1/NCAV/NR_CELL_RTX_PWR_SAVING_CHNG_TO
    ${counter2_path_cell1}    Set Variable     [${btsName}] MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/[CellName1] NRCELL-1/NCAV/NR_CELL_RTX_PWR_SAVING_SAMPLES
    ${counter1_cell1_dic}    selenium_coam.get_bts_counters_info    counter_id=${counter1}    full_path=${counter1_path_cell1}
    ${counter2_cell1_dic}    selenium_coam.get_bts_counters_info    counter_id=${counter2}    full_path=${counter2_path_cell1}
    Selenium Logout And Close Browser
    ${counter1_cell1_value}    Get Dictionary Values    ${counter1_cell1_dic}    sort_keys=False
    ${counter2_cell1_value}    Get Dictionary Values    ${counter2_cell1_dic}    sort_keys=False
    ${counter1_cell1_value_T4}    Get Slice From List    ${counter1_cell1_value}    0    8
    ${counter2_cell1_value_T4}    Get Slice From List    ${counter2_cell1_value}    0    4
    should contain    ${counter1_cell1_value_T4}    1
    should contain    ${counter2_cell1_value_T4}    300
    ${counter1_cell1_times}    get_item_times_in_list    item_list=${counter1_cell1_value_T4}    item=1
    ${counter2_cell1_times}    get_item_times_in_list    item_list=${counter2_cell1_value_T4}    item=300
    should be equal    ${counter1_cell1_times}    ${1}
    should be true    ${counter2_cell1_times}>=${1}
    [Teardown]    run keywords      selenium_set_8392_flag    8392-flag=false   AND    Selenium Logout And Close Browser

CB008392_A_5_Determine_Cell_TX_Path_Reduction_Power_Saving_Mode
    #[Arguments]    ${cell_1}=1    ${cell_3}=3
    case_preparion_active_CB008392
    Selenium Login And Disable Screen Lock
    set_lbps_time_by_selenium_without_validate    lbpsDuration=720
    set_lbps_load_by_selenium_without_validate    lbpsLastCellRTXMinLoad=30    lbpsRTXMinLoad=30    lbpsRTXMaxLoad=40
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=${True}
    Selenium Logout And Close Browser
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    case05_step1
    case05_step2
    case05_step3
    case05_step4
    [Teardown]    run keywords      selenium_set_8392_flag    8392-flag=false   AND    Selenium Logout And Close Browser

CB008392-B_1_8TX_Cell(non-BF_case)Switch_Off_Cell_TX_Paths
    case_preparion_active_CB008392
    Selenium Login And Disable Screen Lock
    set_lbps_time_by_selenium_without_validate    lbpsDuration=720
    set_lbps_load_by_selenium_without_validate    lbpsLastCellRTXMinLoad=20    lbpsRTXMinLoad=20    lbpsRTXMaxLoad=30
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=${True}
    Selenium Logout And Close Browser
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    sleep    40s
    ${cell3_energysaving_status}    check_cell_power_saving_status    cell_index=3
    should be equal    ${cell3_energysaving_status}    reducedEnergySaving
    sleep    30s
    ${cell1_energysaving_status}    check_cell_power_saving_status    cell_index=1
    should be equal    ${cell1_energysaving_status}    reducedEnergySaving
    log to console    start check RU TX status...
#    check_all_RUs_TX_status
    ${ru_index_list}    Get All RU Index
    FOR    ${ru_index}    IN    @{ru_index_list}
        Connect to Common Unit Master
        Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}
        csn.send command    command=dapd -sq | tail -n 5 | head -n 2 | awk '{print $9}'    connection=RU_${ru_index}
        Sleep    2s
        ${result_DPD_IN_OUT_pipe2}    csn.read output    connection=RU_${ru_index}
        csn.send command    command=dapd -sq | tail -n 5 | head -n 2 | awk '{print $12}'    connection=RU_${ru_index}
        Sleep    2s
        ${result_DPD_IN_OUT_pipe3}    csn.read output    connection=RU_${ru_index}
        csn.send command    command=dapd -sq | tail -n 3 | head -n 1 | awk '{print $8}'    connection=RU_${ru_index}
        Sleep    2s
        ${result_PS_pipe2}    csn.read output    connection=RU_${ru_index}
        csn.send command    command=dapd -sq | tail -n 3 | head -n 1 | awk '{print $11}'    connection=RU_${ru_index}
        Sleep    2s
        ${result_PS_pipe3}    csn.read output    connection=RU_${ru_index}
        csn.Disconnect    connection=RU_${ru_index}
        should be equal    ${result_DPD_IN_OUT_pipe2}    -inf\n-inf\n
        should be equal    ${result_DPD_IN_OUT_pipe3}    -inf\n-inf\n
        should be equal    ${result_PS_pipe2}    -inf\n
        should be equal    ${result_PS_pipe3}    -inf\n
    END
    [Teardown]    run keywords      selenium_set_8392_flag    8392-flag=false   AND    Selenium Logout And Close Browser

CB008392-B_2_8TX_Cell(non-BF_case)Switch_On_Cell_TX_Paths
    [Arguments]    ${cell_1}=${1}
    case_preparion_active_CB008392
    data_transfer_start    tput_info=${tput_define}    cell_id=${cell_1}     duration_call=${1800}    reset_sol=${True}
    ...    target_avg_percent=${0.9}    min_percent=${0.8}    duration=${120}    tput_from=self_define    ue_index=${0}
    Selenium Login And Disable Screen Lock
    set_lbps_time_by_selenium_without_validate    lbpsDuration=720
    set_lbps_load_by_selenium_without_validate    lbpsLastCellRTXMinLoad=20    lbpsRTXMinLoad=20    lbpsRTXMaxLoad=30
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=${True}
    Selenium Logout And Close Browser
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    sleep    40s
    ${cell3_energysaving_status}    check_cell_power_saving_status    cell_index=3
    should be equal    ${cell3_energysaving_status}    notEnergySaving
    sleep    30s
    ${cell1_energysaving_status}    check_cell_power_saving_status    cell_index=1
    should be equal    ${cell1_energysaving_status}    notEnergySaving
    log to console    start check RU TX status...
    ${ru_index_list}    Get All RU Index
    FOR    ${ru_index}    IN    @{ru_index_list}
        Connect to Common Unit Master
        Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}
        csn.send command    command=dapd -sq | tail -n 5 | head -n 2 | awk '{print $9}'    connection=RU_${ru_index}
        Sleep    2s
        ${result_DPD_IN_OUT_pipe2}    csn.read output    connection=RU_${ru_index}
        csn.send command    command=dapd -sq | tail -n 5 | head -n 2 | awk '{print $12}'    connection=RU_${ru_index}
        Sleep    2s
        ${result_DPD_IN_OUT_pipe3}    csn.read output    connection=RU_${ru_index}
        csn.send command    command=dapd -sq | tail -n 3 | head -n 1 | awk '{print $8}'    connection=RU_${ru_index}
        Sleep    2s
        ${result_PS_pipe2}    csn.read output    connection=RU_${ru_index}
        csn.send command    command=dapd -sq | tail -n 3 | head -n 1 | awk '{print $11}'    connection=RU_${ru_index}
        Sleep    2s
        ${result_PS_pipe3}    csn.read output    connection=RU_${ru_index}
        csn.Disconnect    connection=RU_${ru_index}
        should not be equal    ${result_DPD_IN_OUT_pipe2}    -inf\n-inf\n
        should not be equal    ${result_DPD_IN_OUT_pipe3}    -inf\n-inf\n
        should not be equal    ${result_PS_pipe2}    -inf\n
        should not be equal    ${result_PS_pipe3}    -inf\n
    END
#    run keyword and ignore error
    collect_check_tput_start    direction=DL   duration=${120}    ue_index=${0}    cell_id=${cell_1}    target_avg_percent=${0.95}
    ...    min_percent=${0.85}
    detach_UE_and_stop_traffic    ue_index=${0}
    [Teardown]    run keywords      selenium_set_8392_flag    8392-flag=false   AND    Selenium Logout And Close Browser

check_CB008392_feature_flag_status
    log to console    /n++++ check CB008392 feature flag status ++++
    ${flag_status}    selenium_coam.get_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    ...    filter_param=Activate NR load-based reduced TX power saving    abbr=actNrLBRTXPowerSaving
    [Return]    ${flag_status}

selenium_set_8392_flag
    [Arguments]    ${8392-flag}=true
    Selenium Login And Disable Screen Lock
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    ...    filter_param=Activate NR load-based reduced TX power saving    abbr=actNrLBRTXPowerSaving    new_value=${8392-flag}
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=${True}
    [Teardown]    Selenium Logout And Close Browser

#selenium_set_8392_flag_without_validate
#    [Arguments]    ${8392-flag}=true
#    log to console    start set CB008392 feature flag...
#    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
#    ...    filter_param=Activate NR load-based reduced TX power saving    abbr=actNrLBRTXPowerSaving    new_value=${8392-flag}

check_cell_power_saving_status
    [Arguments]      ${connection}=GNB_OAM    ${cell_index}=1
    ${cell_info}    coam.get_cell_specific_info    cell_id=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-${cell_index}    connection=${connection}
    ${energysaving_status}    Set Variable    ${cell_info['energySavingState']}
    log    cell_${cell_index}: ${energysaving_status}
    [Return]    ${energysaving_status}

check_cell_power_saving_status_equal_to_expected
    [Arguments]      ${expected_status}    ${connection}=GNB_OAM    ${cell_index}=1
    ${cell_info}    coam.get_cell_specific_info    cell_id=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-${cell_index}    connection=${connection}
    ${energysaving_status}    Set Variable    ${cell_info['energySavingState']}
    log    cell_${cell_index}: ${energysaving_status}
    should be equal    ${energysaving_status}    ${expected_status}

#set_lbps_load_by_selenium
#    [Arguments]      ${lbpsLastCellRTXMinLoad}=20    ${lbpsRTXMinLoad}=20    ${lbpsRTXMaxLoad}=30    ${NRPGRP_ID}=0
#    log to console    start set lbpsload value...
#    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRPGRP-${NRPGRP_ID}
#    ...    filter_param=Load-based power saving last cell reduced TX min load    abbr=lbpsLastCellRTXMinLoad
#    ...    new_value=${lbpsLastCellRTXMinLoad}
#    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRPGRP-${NRPGRP_ID}
#    ...    filter_param=Load-based power saving reduced TX minimum load    abbr=lbpsRTXMinLoad
#    ...    new_value=${lbpsRTXMinLoad}
#    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRPGRP-${NRPGRP_ID}
#    ...    filter_param=Load-based power saving reduced TX maximum load    abbr=lbpsRTXMaxLoad
#    ...    new_value=${lbpsRTXMaxLoad}
#    selenium_coam.validate_plan
#    selenium_coam.activate_plan    activate_plan_despite_errors=${True}

set_lbps_load_by_selenium_without_validate
    [Arguments]      ${lbpsLastCellRTXMinLoad}=20    ${lbpsRTXMinLoad}=20    ${lbpsRTXMaxLoad}=30    ${NRPGRP_ID}=1
    log to console    start set lbpsload value...
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRPGRP-${NRPGRP_ID}
    ...    filter_param=Load-based power saving last cell reduced TX min load    abbr=lbpsLastCellRTXMinLoad
    ...    new_value=${lbpsLastCellRTXMinLoad}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRPGRP-${NRPGRP_ID}
    ...    filter_param=Load-based power saving reduced TX minimum load    abbr=lbpsRTXMinLoad
    ...    new_value=${lbpsRTXMinLoad}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRPGRP-${NRPGRP_ID}
    ...    filter_param=Load-based power saving reduced TX maximum load    abbr=lbpsRTXMaxLoad
    ...    new_value=${lbpsRTXMaxLoad}

#set_lbpsRTX_On_time_without_validate
#    [Arguments]    ${lbpsRTXSOnTime}=30    ${NRPGRP_ID}=0
#    log to console    start set lbpsRTXOnTime...
#    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRPGRP-${NRPGRP_ID}
#    ...    filter_param=Load-based power saving reduced TX switch on time    abbr=lbpsRTXSOnTime
#    ...    new_value=${lbpsRTXSOnTime}

#set_lbpsRTX_Off_time_without_validate
#    [Arguments]    ${lbpsRTXSOffTime}=30    ${NRPGRP_ID}=0
#    log to console    start set lbpsRTXOffTime...
#    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRPGRP-${NRPGRP_ID}
#    ...    filter_param=Load-based power saving reduced TX switch off time    abbr=lbpsRTXSOffTime
#    ...    new_value=${lbpsRTXSOffTime}

data_transfer_start
    [Arguments]    ${tput_info}    ${reset_sol}=${False}    ${cell_id}=${None}    ${target_avg_percent}=${None}
    ...    ${min_percent}=${None}    ${protocol}=udp    ${duration}=${600}    ${gnb_index}=0    ${du_index}=0
    ...    ${tput_from}=tool    ${connection}=GNB_OAM    ${duration_call}=${1800}   ${ue_index}=${0}
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
    run keyword and ignore error    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}    reset_sol=${reset_sol}
    run keyword if    '${ue_type}'=='huawei_sigspark'   prepare_aasyslog    gnb_index=${gnb_index}    du_index=${du_index}
    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}    attach_mode=5G_${gNb_CuType}    timeout=900
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
#    log to console    start ul traffic...
#    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=${ul_tp}
#    ...    protocol=${protocol}    duration=${duration_call}    ue_index=${ue_index}    iperf_type=${iperf_type}
#    ...    data_amount=2M    ue_mode=${gNb_CuType}

prepare_aasyslog
    [Arguments]    ${gnb_index}=0    ${du_index}=0
    Teardown the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}
    Aasyslog precondition    gnb_index=${gnb_index}    du_index=${du_index}
    Start the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}    filter=L2   log_name=5Grach.txt

collect_check_tput_start
    [Arguments]    ${direction}=DL    ${duration}=${1200}    ${cell_id}=1    ${ue_index}=0
    ...    ${connection}=GNB_OAM    ${target_avg_percent}=${0.9}    ${min_percent}=${0.85}
     ${tput_log}    power_ue.Collect Tput    ue_type=huawei    duration=${duration}
    check_dl_tput_for_each_cell    direction=${direction}    cell_id=${cell_id}    ue_index=${ue_index}
    ...    tput_log=${tput_log}    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}    connection=${connection}

detach_UE_and_stop_traffic
    [Arguments]    ${ue_index}=${0}    ${protocol}=udp
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    ${iperf_type}  set variable if  '${ue_type}'=='huawei'    via_app    via_command
    run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    ue_index=${ue_index}
    ...    protocol=${protocol}
#    run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    ue_index=${ue_index}
#    ...    iperf_type=${iperf_type}    protocol=${protocol}
    power_ue.UE Detach  ue_type=${ue_type}    ue_index=${ue_index}

check_dl_tput_for_each_cell
    [Arguments]    ${direction}    ${cell_id}    ${ue_index}    ${tput_log}    ${target_avg_percent}=0.95
    ...    ${min_percent}=0.85    ${connection}=GNB_OAM
    ${tput_info}    get_tput_info_by_tool    cell_id=${cell_id}
    ${dl_exp}    set variable    ${tput_info['dl_exp']}
#    ${ul_exp}    set variable    ${tput_info[${cell_id}]['ul_exp']}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    ${cell_mapping}    get_relation_mapping_between_cell_index_and_nrCellIdentity    connection_alias=${connection}
    ${cell_id}    Convert To String    ${cell_mapping[${cell_id}]['nrCellIdentity']}
    ${cell_id}    Create List    ${cell_id}
    ${ue_type}    run keyword if    '${ue_type}'=='huawei_sigspark'    set variable    huawei    ELSE    set variable    ${ue_type}
#    ${output}    power_ue.Check Bi Tput   ue_type=${ue_type}    log=${tput_log}    cells=${cell_id}    ultarget_throughput=${ul_exp}
#    ...    dltarget_throughput=${dl_exp}    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    ${output}    power_ue.Check Tput   ue_type=${ue_type}    direction=${direction}    log=${tput_log}    cells=${cell_id}
    ...    target_throughput=${dl_exp}    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    log to console    \n${output}

case05_step1
    [Arguments]    ${cell_3}=${3}
#    log to console    step1: make call, cell1:40M cell3:150M ...
#    data_transfer_start    tput_info=${tput_define_step1_cell1}    cell_id=${cell_1}     duration_call=${3600}    reset_sol=${True}
#    ...    target_avg_percent=${0.9}    min_percent=${0.8}    duration=${120}    tput_from=self_define    ue_index=${0}
    log to console    step1: make call, cell3:410M ...
    data_transfer_start    tput_info=${tput_define_step1_cell3}    cell_id=${cell_3}     duration_call=${3600}    reset_sol=${True}
    ...    target_avg_percent=${0.9}    min_percent=${0.8}    duration=${120}    tput_from=self_define    ue_index=${0}
    log to console    start check cell powerSaving status...
    sleep    1min
    Wait until keyword succeeds    10min    5s    check_cell_power_saving_status_equal_to_expected
    ...    expected_status=reducedEnergySaving    cell_index=3
    Wait until keyword succeeds    10min    5s    check_cell_power_saving_status_equal_to_expected
    ...    expected_status=notEnergySaving    cell_index=1
#    run keyword and ignore error
#    ...    collect_check_tput_start  direction=DL   duration=${120}    ue_index=${0}
#    ...    cell_id=${cell_1}    target_avg_percent=${0.4}    min_percent=${0.3}
#    detach_UE_and_stop_traffic    ue_index=${0}
    log to console    start check tput
    run keyword and ignore error
    ...    collect_check_tput_start    direction=DL   duration=${120}    ue_index=${0}
    ...    cell_id=${cell_3}    target_avg_percent=${0.1}    min_percent=${0.08}
    detach_UE_and_stop_traffic    ue_index=${0}

case05_step2
    [Arguments]    ${cell_3}=${3}
#    log to console    step2: make call, cell1:150M cell3:150M ...
#    data_transfer_start    tput_info=${tput_define_step2_cell1}    cell_id=${cell_1}     duration_call=${3600}
#    ...    target_avg_percent=${0.9}    min_percent=${0.8}    duration=${120}    tput_from=self_define    ue_index=${0}
    log to console    step2: make call, cell3:933M ...
    data_transfer_start    tput_info=${tput_define_step2_cell3}    cell_id=${cell_3}     duration_call=${3600}
    ...    target_avg_percent=${0.9}    min_percent=${0.8}    duration=${120}    tput_from=self_define    ue_index=${0}
    log to console    start check cell powerSaving status...
    Wait until keyword succeeds    10min    5s    check_cell_power_saving_status_equal_to_expected
    ...    expected_status=notEnergySaving    cell_index=3
    Wait until keyword succeeds    10min    5s    check_cell_power_saving_status_equal_to_expected
    ...    expected_status=notEnergySaving    cell_index=1
#    run keyword and ignore error
#    ...    collect_check_tput_start    direction=DL   duration=${120}    ue_index=${0}
#    ...    cell_id=${cell_1}    target_avg_percent=${0.4}     min_percent=${0.3}
#    detach_UE_and_stop_traffic    ue_index=${0}
    log to console    start check tput
    run keyword and ignore error
    ...    collect_check_tput_start    direction=DL   duration=${120}    ue_index=${0}
    ...    cell_id=${cell_3}    target_avg_percent=${0.4}    min_percent=${0.3}
    detach_UE_and_stop_traffic    ue_index=${0}

case05_step3
    [Arguments]    ${cell_3}=${3}
#    log to console    step3: make call, cell1:150M cell3:1M ...
#    data_transfer_start    tput_info=${tput_define_step3_cell1}    cell_id=${cell_1}     duration_call=${3600}
#    ...    target_avg_percent=${0.9}    min_percent=${0.8}    duration=${120}    tput_from=self_define    ue_index=${0}
    log to console    step3: make call, cell3:1M ...
    data_transfer_start    tput_info=${tput_define_step3_cell3}    cell_id=${cell_3}     duration_call=${3600}
    ...    target_avg_percent=${0.9}    min_percent=${0.8}    duration=${120}    tput_from=self_define    ue_index=${0}
    log to console    start check cell powerSaving status...
    sleep    1min
    Wait until keyword succeeds    10min    5s    check_cell_power_saving_status_equal_to_expected
    ...    expected_status=reducedEnergySaving    cell_index=3
    sleep    1min
    Wait until keyword succeeds    10min    5s    check_cell_power_saving_status_equal_to_expected
    ...    expected_status=reducedEnergySaving    cell_index=1
#    run keyword and ignore error
#    ...    collect_check_tput_start    direction=DL   duration=${120}    ue_index=${0}
#    ...    cell_id=${cell_1}    target_avg_percent=${0.002}    min_percent=${0.001}
#    detach_UE_and_stop_traffic    ue_index=${0}
    log to console    start check tput
    run keyword and ignore error
    ...    collect_check_tput_start    direction=DL   duration=${120}    ue_index=${0}
    ...    cell_id=${cell_3}    target_avg_percent=${0.4}    min_percent=${0.3}
    detach_UE_and_stop_traffic    ue_index=${0}

case05_step4
    [Arguments]    ${cell_3}=${3}
#    log to console    step4: make call, cell1:150M cell3:150M ...
#    data_transfer_start    tput_info=${tput_define_step4_cell1}    cell_id=${cell_1}     duration_call=${3600}
#    ...    target_avg_percent=${0.9}    min_percent=${0.8}    duration=${120}    tput_from=self_define    ue_index=${0}
    log to console    step4: make call, cell3:933M ...
    data_transfer_start    tput_info=${tput_define_step4_cell3}    cell_id=${cell_3}     duration_call=${3600}
    ...    target_avg_percent=${0.9}    min_percent=${0.8}    duration=${120}    tput_from=self_define    ue_index=${0}
    log to console    start check cell powerSaving status...
    Wait until keyword succeeds    10min    5s    check_cell_power_saving_status_equal_to_expected
    ...    expected_status=notEnergySaving    cell_index=3
    Wait until keyword succeeds    10min    5s    check_cell_power_saving_status_equal_to_expected
    ...    expected_status=notEnergySaving    cell_index=1
#    run keyword and ignore error
#    ...    collect_check_tput_start    direction=DL   duration=${120}    ue_index=${0}
#    ...    cell_id=${cell_1}    target_avg_percent=${0.4}    min_percent=${0.3}
#    detach_UE_and_stop_traffic    ue_index=${0}
    log to console    start check tput
    run keyword and ignore error
    ...    collect_check_tput_start    direction=DL   duration=${120}    ue_index=${0}
    ...    cell_id=${cell_3}    target_avg_percent=${0.4}    min_percent=${0.3}
    detach_UE_and_stop_traffic    ue_index=${0}
