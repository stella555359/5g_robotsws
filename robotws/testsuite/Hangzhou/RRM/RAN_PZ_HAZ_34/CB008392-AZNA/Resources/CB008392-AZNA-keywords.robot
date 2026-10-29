*** Settings ***
Documentation    This is for CB007833-5G-A-td-Cpri-Amber keywords
...              Author: Gao melinda
...              Contact: melinda.gao@nokia-sbell.com
...              squad: 5G_PZ_HZ_8_SG


Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Library    variables_CB008392_AZNA.py
Library    taf.ul.oam.selenium_coam    WITH NAME    selenium_coam
Library    taf.sbts.oam.coam.admin    WITH NAME    coam
Library    String
Library    DateTime
Library    OperatingSystem
Variables    variables_CB008392_AZNA.py

*** Variables ***

*** Keywords ***
case_preparion_commision_SCF
    log to console    start commission CB008392 SCF...
    Selenium Login And Disable Screen Lock
    ${SCF_CB008392}    Replace String    ${Golden_SCF_Path}    .xml    _8392.xml
    COAM Commission with scf file    scf_file_path=${SCF_CB008392}    timeout=600    is_pdl_checking_needed=${if_pdl_check}
    Wait until keyword succeeds    10min    30s    verify all cells should be onair
    Selenium Logout And Close Browser

case_preparion_active_CB008392
    [Arguments]    ${flag_activate}=true
    Selenium Login And Disable Screen Lock
    ${flag_status}    check_CB008392_feature_flag_status
    Run Keyword If    '${flag_status}'=='false'
    ...    Run Keywords
    ...    selenium_set_8392_flag    AND    Log    ${flag_status}
    ...    ELSE    Log    ${flag_status}
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    [Teardown]    Selenium Logout And Close Browser

set_lbps_time_by_selenium
    [Arguments]    ${lbpsDuration}=60    ${NRPGRP}=1
    ${lbpsDayOfWeek}    ${lbpsStartTimeHour}    ${lbpsStartTimeMinute}    get_lbps_current_time_AZNA
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
    ${lbpsDayOfWeek}    ${lbpsStartTimeHour}    ${lbpsStartTimeMinute}    get_lbps_current_time_AZNA
    log to console    start set lbps time duration:${lbpsDuration}, day:${lbpsDayOfWeek}, hour:${lbpsStartTimeHour}, min:${lbpsStartTimeMinute}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRPGRP-${NRPGRP}
    ...    filter_param=Load-based power saving day of week    abbr=lbpsDayOfWeek    new_value=${lbpsDayOfWeek}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRPGRP-${NRPGRP}
    ...    filter_param=Load-based power saving duration    abbr=lbpsDuration    new_value=${lbpsDuration}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRPGRP-${NRPGRP}
    ...    filter_param=Load-based power saving start time hour    abbr=lbpsStartTimeHour    new_value=${lbpsStartTimeHour}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRPGRP-${NRPGRP}
    ...    filter_param=Load-based power saving start time minute    abbr=lbpsStartTimeMinute    new_value=${lbpsStartTimeMinute}

CB008392-A_3_Feature_CB008392_Deactivation_with_cell_in_reducedEnergySaving_state
    case_preparion_active_CB008392
    Selenium Login And Disable Screen Lock
    set_lbps_time_by_selenium    lbpsDuration=720
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    sleep    1min
    ${cell1_energysaving_status}    check_cell_power_saving_status    cell_index=1
    should be equal    ${cell1_energysaving_status}    reducedEnergySaving
    selenium_set_8392_flag    8392-flag=false
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    ${cell1_off_energysaving_status}    check_cell_power_saving_status    cell_index=1
    should be equal    ${cell1_off_energysaving_status}    notEnergySaving
    [Teardown]    run keywords      selenium_set_8392_flag    8392-flag=false   AND    Selenium Logout And Close Browser

CB008392-A_15_View_Power_Saving_Performance_Management_Counters
    [Arguments]    ${counter1}=M55601C02001    ${counter2}=M55601C02002
    ...    ${counter1_path_cell1}=CELLS/NRCELL-1/NCAV/NR_CELL_RTX_PWR_SAVING_CHNG_TO
    ...    ${counter2_path_cell1}=CELLS/NRCELL-1/NCAV/NR_CELL_RTX_PWR_SAVING_SAMPLES
    [Documentation]  miNrCellAvailability should be 5min
    case_preparion_active_CB008392
    Selenium Login And Disable Screen Lock
    set_lbps_time_by_selenium    lbpsDuration=30
    sleep    15min
#    ${counter1_cell1_dic}    selenium_coam.get_bts_counters_info    counter_id=${counter1}    full_path=${counter1_path_cell1}
#    ${counter2_cell1_dic}    selenium_coam.get_bts_counters_info    counter_id=${counter2}    full_path=${counter2_path_cell1}
#    ${counter1_cell1_value}    Get Dictionary Values    ${counter1_cell1_dic}    sort_keys=False
#    ${counter2_cell1_value}    Get Dictionary Values    ${counter2_cell1_dic}    sort_keys=False
#    ${counter1_cell1_value_T4}    Get Slice From List    ${counter1_cell1_value}    0    4
#    ${counter2_cell1_value_T4}    Get Slice From List    ${counter2_cell1_value}    0    4
    ${result}    ${release}    Run Keyword And Ignore Error
    ...    Wait Until Keyword Succeeds    1 min    2 sec    gnb_classical_hangzhou.Get sw build version
    ${release_sbts}    Replace String    string=${release}    search_for=5G    replace_with=SBTS
	${status}  run keyword and return status  Should Contain Any  ${release_sbts}  SBTS23R3  SBTS23R4  SBTS24R1
    ${counter1_cell1_value_T4}    Run keyword If  ${status}
    ...    get_power_saving_performance_management_counter_latest_value    BTS_or_TRS=BTS    counter_id=M55601C02001
    ...    counter_full_path=CELLS/NRCELL-1/NCAV/NR_CELL_RTX_PWR_SAVING_CHNG_TO
    ...    ELSE  get_power_saving_performance_management_counter_latest_value    BTS_or_TRS=BTS    counter_id=M55601C02001
    ...    counter_full_path=MRBTS-${mrbtsID}/NRBTS-${mrbtsID}/NRCELL-1/NCAV/NR_CELL_RTX_PWR_SAVING_CHNG_TO
    ${counter2_cell1_value_T4}    Run keyword If  ${status}
    ...    get_power_saving_performance_management_counter_latest_value    BTS_or_TRS=BTS    counter_id=M55601C02002
    ...    counter_full_path=CELLS/NRCELL-1/NCAV/NR_CELL_RTX_PWR_SAVING_SAMPLES
    ...    ELSE  get_power_saving_performance_management_counter_latest_value    BTS_or_TRS=BTS    counter_id=M55601C02002
    ...    counter_full_path=MRBTS-${mrbtsID}/NRBTS-${mrbtsID}/NRCELL-1/NCAV/NR_CELL_RTX_PWR_SAVING_SAMPLES
    ${item1}  convert to integer  ${1}
    ${item2}  convert to integer  ${300}
    should contain    ${counter1_cell1_value_T4}    ${item1}
    should contain    ${counter2_cell1_value_T4}    ${item2}
    ${counter1_cell1_times}    get_item_times_in_list    item_list=${counter1_cell1_value_T4}    item=${item1}
    ${counter2_cell1_times}    get_item_times_in_list    item_list=${counter2_cell1_value_T4}    item=${item2}
#    should contain    ${counter1_cell1_value_T4}    1
#    should contain    ${counter2_cell1_value_T4}    300
#    ${counter1_cell1_times}    get_item_times_in_list    item_list=${counter1_cell1_value_T4}    item=1
#    ${counter2_cell1_times}    get_item_times_in_list    item_list=${counter2_cell1_value_T4}    item=300
    should be equal    ${counter1_cell1_times}    ${1}
    should be true    ${counter2_cell1_times}>=${1}
    [Teardown]    run keywords      selenium_set_8392_flag    8392-flag=false   AND    Selenium Logout And Close Browser

CB008392-A_8_4TX_Cell_Switch_Off_Cell_TX_Paths
    case_preparion_active_CB008392
    Selenium Login And Disable Screen Lock
    set_lbps_time_by_selenium_without_validate    lbpsDuration=720
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=${True}
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    sleep    40s
    ${cell1_energysaving_status}    check_cell_power_saving_status    cell_index=1
    should be equal    ${cell1_energysaving_status}    reducedEnergySaving
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
        should be equal    ${result_DPD_IN_OUT_pipe2}    -inf\n-inf\n
        should be equal    ${result_DPD_IN_OUT_pipe3}    -inf\n-inf\n
        should be equal    ${result_PS_pipe2}    -inf\n
        should be equal    ${result_PS_pipe3}    -inf\n
    END
    [Teardown]    run keywords      selenium_set_8392_flag    8392-flag=false   AND    Selenium Logout And Close Browser

CB008392-A_9_4TX_Cell_Switch_On_Cell_TX_Paths
    [Arguments]    ${cell_1}=${1}    ${call_duration}=${120}
    case_preparion_active_CB008392
    data_transfer_start    tput_info=${tput_define_AZNA}    cell_id=${cell_1}     duration_call=${1800}
    ...    target_avg_percent=${0.9}    min_percent=${0.8}    duration=${call_duration}    tput_from=self_define    ue_index=${0}
    Selenium Login And Disable Screen Lock
    set_lbps_time_by_selenium_without_validate    lbpsDuration=720
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=${True}
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    sleep    40s
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
    run keyword and ignore error
    ...    collect_check_tput_start    direction=DL   duration=${call_duration}    ue_index=${0}    cell_id=${cell_1}
    ...    target_avg_percent=${0.95}    min_percent=${0.8}
    detach_UE_and_stop_traffic    ue_index=${0}
    [Teardown]    run keywords      selenium_set_8392_flag    8392-flag=false   AND    Selenium Logout And Close Browser

check_CB008392_feature_flag_status
    log to console    /n++++ check CB008392 feature flag status ++++
    ${flag_status}    selenium_coam.get_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    ...    filter_param=Activate NR load-based reduced TX power saving    abbr=actNrLBRTXPowerSaving
    [Return]    ${flag_status}

selenium_set_8392_flag
    [Arguments]    ${8392-flag}=true
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    ...    filter_param=Activate NR load-based reduced TX power saving    abbr=actNrLBRTXPowerSaving    new_value=${8392-flag}
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=${True}

check_cell_power_saving_status
    [Arguments]      ${connection}=GNB_OAM    ${cell_index}=1
    ${cell_info}    coam.get_cell_specific_info    cell_id=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-${cell_index}    connection=${connection}
    ${energysaving_status}    Set Variable    ${cell_info['energySavingState']}
    log    cell_${cell_index}: ${energysaving_status}
    [Return]    ${energysaving_status}

data_transfer_start
    [Arguments]    ${tput_info}    ${ru_index}=${None}    ${cell_id}=${None}    ${target_avg_percent}=${None}    ${min_percent}=${None}
    ...    ${protocol}=udp    ${duration}=${600}    ${gnb_index}=0    ${du_index}=0    ${ue_ul_layer}=1    ${tput_from}=tool
    ...    ${alias}=ASIK MASTER    ${connection}=GNB_OAM    ${duration_call}=${1800}   ${ue_index}=${0}
    ...    ${iperf_type}=${None}
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
    ${iperf_type}    Get Iperf Type    iperf_type=${iperf_type}    protocol=${protocol}
    ${ui_version}    Get UE UI Version
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    run keyword and ignore error    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}    ui_version=${ui_version}
    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}    attach_mode=5G_${gNb_CuType}
    ${dl_tp}    set variable    ${tput_info['dl_tp']}
    ${ul_tp}    set variable    ${tput_info['ul_tp']}
    ${process_num}    set variable if      '${protocol}'=='udp'    ${1}    ${16}
    log to console    start dl traffic...
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${dl_tp}
    ...    protocol=${protocol}    duration=${duration_call}    ue_index=${ue_index}    process_num=${process_num}    ue_mode=${gNb_CuType}
#    log to console    start ul traffic...
#    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=${ul_tp}
#    ...    protocol=${protocol}    duration=${duration_call}    ue_index=${ue_index}    iperf_type=${iperf_type}
#    ...    data_amount=2M    ue_mode=${gNb_CuType}

collect_check_tput_start
    [Arguments]    ${direction}=DL    ${duration}=${1200}    ${cell_id}=1    ${ue_index}=0    ${connection}=GNB_OAM
    ...    ${target_avg_percent}=${0.9}    ${min_percent}=${0.85}
     ${tput_log}    power_ue.Collect Tput    ue_type=huawei    duration=${duration}
    check_dl_tput_for_each_cell    direction=${direction}    tput_info=${tput_info_total}    cell_id=${cell_id}    ue_index=${ue_index}
    ...    tput_log=${tput_log}    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}    duration=${duration}
    ...    connection=${connection}

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
    [Arguments]    ${direction}    ${tput_info}    ${cell_id}    ${ue_index}    ${tput_log}    ${target_avg_percent}=0.95
    ...    ${min_percent}=0.85    ${duration}=600    ${connection}=GNB_OAM
    ${dl_exp}    set variable    ${tput_info[${cell_id}]['dl_exp']}
#    ${ul_exp}    set variable    ${tput_info[${cell_id}]['ul_exp']}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    ${cell_mapping}    get_relation_mapping_between_cell_index_and_nrCellIdentity    connection_alias=${connection}
    ${cell_id}    Convert To String    ${cell_mapping[${cell_id}]['nrCellIdentity']}
    ${cell_id}    Create List    ${cell_id}
    ${ue_type}    run keyword if    '${ue_type}'=='huawei_sigspark'    set variable    huawei    ELSE    set variable    ${ue_type}
#    ${output}    power_ue.Check Bi Tput   ue_type=${ue_type}    log=${tput_log}    cells=${cell_id}    ultarget_throughput=${ul_exp}
#    ...    dltarget_throughput=${dl_exp}    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    ${output}    power_ue.Check Tput   ue_type=${ue_type}    direction=DL    log=${tput_log}    cells=${cell_id}    target_throughput=${dl_exp}
    ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    log to console    \n${output}

get_power_saving_performance_management_counter_latest_value
    [Arguments]    ${BTS_or_TRS}    ${counter_id}    ${counter_full_path}    ${connection}=GNB_OAM
    Log to console    Gathering value of counter: "${counter_id}"
    ${counters_info} =    coam.get_counters_info    connection=${connection}    timeout=120
    ${counter_groups} =    Get From Dictionary    ${counters_info}    ${BTS_or_TRS}
    ${counter_group_keys} =    Split String    ${counter_full_path}    /
    ${counter_groups_length} =    Get Length    ${counter_group_keys}
    Remove From List    ${counter_group_keys}    ${counter_groups_length-1}
    FOR    ${group}    IN     @{counter_group_keys}
        ${counter_groups} =    Get From Dictionary    ${counter_groups}    ${group}
    END
    ${counter_values} =    Get From Dictionary    ${counter_groups}    ${counter_id}
    ${value_list} =     get dictionary values    ${counter_values}
    Reverse List    ${value_list}
    [return]    ${value_list}