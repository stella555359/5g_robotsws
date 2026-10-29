*** Settings ***
Library     ./Power_Saving_cmW.py  WITH NAME  feature_resources
Library     ./Power_Saving.py
Library     Power_Saving.GnbPowerSaving    WITH NAME      gnbps
Library    taf.rfrl.bts.devices.du.commissioning.EnbCommissioning    WITH NAME      enbscf
Resource    taf/rfrl/bts/robot/gnb.robot
Resource    ./Power_Saving.robot

*** Variables ***
${throughput}=   250Mbits/sec
${dt_name}=   dt1
${deviation}  30%
${UE_alias}     ANDROID_UE_2
${capabilities}    REAL_UE
${direction}=  dl
${protocol}=  tcp
${packet_size}=  1400
${tput}=   250Mbits/sec
${buffer_server}=   4M
${buffer_client}=   4M
${dist_name_power_group}=       MRBTS-{}/NRBTS-{}/NRPGRP-0
${expect_error}=    ValueError: Plan activation is unsuccessful
${expect_error_2}=    *TimeoutException:*
${parameter_suspended}=  Load-Based Power Saving Suspended

*** Keywords ***
Check if Time Frame has ended
    [Arguments]    ${power_group_id}    ${node_index}
    [Documentation]    Check if time frame for feature activation has ended
    ...   :param power_group_id                     power group id value
    ...   :param node_index                         node index value
    gnbps.verify_time_frame_ended   power_group_id=${power_group_id}    node_index=${node_index}

Set last cell switch off value
    [Arguments]    ${value}    ${power_group_id}
    [Documentation]    Enable or disable last cell switch off in power group
    ...   :param value                              paramter lbpsLastCellSOEnabled value
    ...   :param power_group_id                     power group id value
    ...   :param node_index                         node index value
    gnbps.set_last_cell_switch_off_value    value=${value}    power_group_id=${power_group_id}

Perform Configuration Parameter Recommissioning On eNB
    [Arguments]   ${dist_name}    ${param_name}    ${param_value}    ${operation}=update    ${enb_id}=0
    ...    ${skip_parameter_relation_errors}=${false}    ${should_activate}=${true}    ${timeout}=${60}    ${du_id}=${0}
    [Documentation]    Perform recommissioning of specified configuration parameter on eNB bts.
    ...     :param dist_name:    object dist name ie. MRBTS-{}/LNBTS-{}/NRCELL-1
    ...     :param parameter:    parameter name ie. ipAddrPrim
    ...     :param operation:    parameter operation (update or delete)
    ...     :param value:        parameter value ie. locked or unlocked
    ...     :param bts_id:       gNB id - related to Test Line configuration, default 0
    ...     :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
    ...     :param skip_parameter_relation_errors:     If True then skip parameter relation errors, default False
    ...     :param should_activate:                    If True activate plan automatically, default True
    ...     :param timeout:                            Time to wait for positive procedure result, default 60
    enbscf.perform_configuration_parameter_recommissioning    dist_name=${dist_name}    parameter=${param_name}
    ...    value=${param_value}    operation=${operation}    bts_id=${enb_id}    timeout=${timeout}
    ...    skip_parameter_relation_errors=${skip_parameter_relation_errors}    should_activate=${should_activate}
    ...    du_id=${du_id}

Verify Feature Activation Time has ended
    [Arguments]    ${power_group_id}    ${node_index}
    [Documentation]    Wait until time frame for feature activation has ended
    ...   :param power_group_id                     power group id value
    ...   :param node_index                         node index value
    Wait Until Keyword Succeeds     35min   20s     Check if Time Frame has ended       power_group_id=${power_group_id}
    ...     node_index=${node_index}

Check if Time Frame has started
    [Arguments]    ${power_group_id}    ${node_index}
    [Documentation]    Check if time frame for feature activation has started
    ...   :param power_group_id                     power group id value
    ...   :param node_index                         node index value
    gnbps.verify_time_frame_started   power_group_id=${power_group_id}    node_index=${node_index}

Verify Feature Activation Time has started
    [Arguments]    ${power_group_id}    ${node_index}
    [Documentation]    Wait until time frame for feature activation has started
    ...   :param power_group_id                     power group id value
    ...   :param node_index                         node index value
    Wait Until Keyword Succeeds     35min   20s     Check if Time Frame has started       power_group_id=${power_group_id}
    ...     node_index=${node_index}

Prepare UE 2481
    [Arguments]     ${UE_alias}     ${capabilities}    ${timeout}
    ute_ue.Require UE   ue_alias=${UE_alias}   capabilities=${capabilities}
    ute_ue.Detach UE     ue_alias=${UE_alias}

Attach ue and run low throughput
    [Arguments]     ${UE_alias}   ${capabilities}    ${dt_name}  ${direction}  ${throughput}  ${duration}
    ...   ${protocol}    ${packet_size}     ${tput}    ${deviation}    ${buffer_client}     ${buffer_server}
    ute_ue.Attach UE     ue_alias=${UE_alias}
    Sleep     10
    ute_ue.start_data_transfer     dt_name=${dt_name}    ue_alias=${UE_alias}    direction=${direction}
    ...    throughput=${throughput}    duration=${duration}    protocol=${protocol}    packet_size=${packet_size}
    ...    buffer_client=${buffer_client}       buffer_server=${buffer_server}
    ute_ue.Check Data Transfer Is Alive    dt_name=${dt_name}
    Run Keyword And Ignore Error    ute_ue.Await Data Transfer Finish     dt_name=${dt_name}
    Run Keyword And Ignore Error    ute_ue. Verify Average Throughput With Deviation     dt_name=${dt_name}
    ...     tput=${tput}    deviation=${deviation}

Attach ue and run high throughput
    [Arguments]     ${UE_alias}   ${capabilities}    ${dt_name}  ${direction}  ${throughput}  ${duration}
    ...   ${protocol}    ${packet_size}     ${tput}    ${deviation}    ${buffer_client}     ${buffer_server}
    ute_ue.Attach UE     ue_alias=${UE_alias}
    Sleep     10
    ute_ue.start_data_transfer     dt_name=${dt_name}    ue_alias=${UE_alias}    direction=${direction}
    ...    throughput=${throughput}    duration=${duration}    protocol=${protocol}    packet_size=${packet_size}
    ...    buffer_client=${buffer_client}       buffer_server=${buffer_server}
    ute_ue.Check Data Transfer Is Alive    dt_name=${dt_name}
    ute_ue.Await Data Transfer Finish     dt_name=${dt_name}
    ute_ue. Verify Average Throughput With Deviation     dt_name=${dt_name}    tput=${tput}    deviation=${deviation}

Lock or block cell
    [Arguments]     ${gnb_id}=0    ${cell_id}=1    ${du_id}=0
    [Documentation]    Lock or block cell, depending on release
    ...   :param gnb_id:  ID of gNB/eNB, default 0
    ...   :param cell_id: id of the cell to be locked/blocked
    ...   :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
    feature_resources.lock_or_block_cell    bts_id=${gnb_id}      cell_id=${cell_id}    du_id=${du_id}

Unlock or unblock cell
    [Arguments]     ${gnb_id}=0    ${cell_id}=1    ${du_id}=0
    [Documentation]    Unlock or unblock cell, depending on release
    ...   :param gnb_id:  ID of gNB/eNB, default 0
    ...   :param cell_id: id of the cell to be unlocked/unblocked
    ...   :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
    feature_resources.unlock_or_unblock_cell    bts_id=${gnb_id}      cell_id=${cell_id}    du_id=${du_id}

Check if lbpsStartTimeHour values are out of range
    [Documentation]    Check if lbpsStartTimeHour values are out of range
    Log to console    \n----Check if lbpsStartTimeHour values are out of range ----
    Run Keyword And Expect Error    ${expect_error}   Turn on lbps for specific time step by step selenium
    ...    lbps_day_of_week=Wed
    ...    lbps_duration_in_min=5
    ...    lbps_start_time_hour=24
    ...    lbps_start_time_minute=5
    ...    node_index=0
    ...    power_group_id=1
    ...    activate_plan_despite_errors=${False}
    Run Keyword And Expect Error    ${expect_error}   Turn on lbps for specific time step by step selenium
    ...    lbps_day_of_week=Wed
    ...    lbps_duration_in_min=5
    ...    lbps_start_time_hour=-1
    ...    lbps_start_time_minute=5
    ...    node_index=0
    ...    power_group_id=1
    ...    activate_plan_despite_errors=${False}

Check if add same cell to two diffrent Power groups is not possible
    [Documentation]    Check if add same cell to two diffrent Power groups is not possible
    Log to console    \n----Check if add same cell to two diffrent Power groups is not possible----
    Run Keyword And Expect Error    ${expect_error_2}    Add new cell to power group
    ...    power_group_id=1
    ...    cell_id=1
    ...    cell_switch_off_order=60
    ...    node_index=1
    ...    activate_plan_despite_errors=${False}

Check if lbpsStartTimeMinute values are out of range
    [Documentation]    Check if lbpsStartTimeMinute values are out of range
    Log to console    \n----Check if lbpsStartTimeMinute values are out of range----
    Run Keyword And Expect Error    ${expect_error}   Turn on lbps for specific time step by step selenium
    ...    lbps_day_of_week=Wed
    ...    lbps_duration_in_min=5
    ...    lbps_start_time_hour=5
    ...    lbps_start_time_minute=60
    ...    node_index=0
    ...    power_group_id=1
    ...    activate_plan_despite_errors=${False}
    Run Keyword And Expect Error    ${expect_error}   Turn on lbps for specific time step by step selenium
    ...    lbps_day_of_week=Wed
    ...    lbps_duration_in_min=5
    ...    lbps_start_time_hour=5
    ...    lbps_start_time_minute=-1
    ...    node_index=0
    ...    power_group_id=1
    ...    activate_plan_despite_errors=${False}

Check if lbpsDuration values are out of range
    [Documentation]    Check if lbpsDuration values are out of range
    Log to console    \n----Check if lbpsDuration values are out of range----
    Run Keyword And Expect Error    ${expect_error}   Turn on lbps for specific time step by step selenium
    ...    lbps_day_of_week=Wed
    ...    lbps_duration_in_min=1441
    ...    lbps_start_time_hour=5
    ...    lbps_start_time_minute=5
    ...    node_index=0
    ...    power_group_id=1
    ...    activate_plan_despite_errors=${False}
    Run Keyword And Expect Error    ${expect_error}   Turn on lbps for specific time step by step selenium
    ...    lbps_day_of_week=Wed
    ...    lbps_duration_in_min=0
    ...    lbps_start_time_hour=5
    ...    lbps_start_time_minute=5
    ...    node_index=0
    ...    power_group_id=1
    ...    activate_plan_despite_errors=${False}

Check if lbpsMaxLoad percentage values are out of range
    [Documentation]    Check if lbpsMaxLoad percentage values are out of range
    Log to console    \n----Check if lbpsMaxLoad percentage values are out of range----
    Run Keyword And Expect Error    ${expect_error}    Turn on lbps for specific percentage step by step selenium
    ...    lbps_max_load=101
    ...    lbps_min_load=20
    ...    lbps_last_min_load=0
    ...    power_group_id=0
    ...    activate_plan_despite_errors=${False}
    Run Keyword And Expect Error    ${expect_error}    Turn on lbps for specific percentage step by step selenium
    ...    lbps_max_load=50.5
    ...    lbps_min_load=20
    ...    lbps_last_min_load=0
    ...    power_group_id=0
    ...    activate_plan_despite_errors=${False}

Check if lbpsMinLoad percentage values are out of range
    [Documentation]    Check if lbpsMinLoad percentage values are out of range
    Log to console    \n----Check if lbpsMinLoad percentage values are out of range----
    Run Keyword And Expect Error    ${expect_error}    Turn on lbps for specific percentage step by step selenium
    ...    lbps_max_load=70
    ...    lbps_min_load=101
    ...    lbps_last_min_load=0
    ...    power_group_id=0
    ...    activate_plan_despite_errors=${False}
    Run Keyword And Expect Error    ${expect_error}    Turn on lbps for specific percentage step by step selenium
    ...    lbps_max_load=70
    ...    lbps_min_load=50.5
    ...    lbps_last_min_load=0
    ...    power_group_id=0
    ...    activate_plan_despite_errors=${False}

Check if lbpsLastMinLoad percentage values are out of range
    [Documentation]    Check if lbpsLastMinLoad percentage values are out of range
    Log to console    \n----Check if lbpsLastMinLoad percentage values are out of range----
    Run Keyword And Expect Error    ${expect_error}    Turn on lbps for specific percentage step by step selenium
    ...    lbps_max_load=70
    ...    lbps_min_load=20
    ...    lbps_last_min_load=101
    ...    power_group_id=0
    ...    activate_plan_despite_errors=${False}
    Run Keyword And Expect Error    ${expect_error}    Turn on lbps for specific percentage step by step selenium
    ...    lbps_max_load=70
    ...    lbps_min_load=20
    ...    lbps_last_min_load=50.5
    ...    power_group_id=0
    ...    activate_plan_despite_errors=${False}

Check if set cell switch-off in wrong order is impossible
    [Documentation]    Check if set cell switch-off in wrong order is impossible
    Log to console    \n----Check if set cell switch-off in wrong order is impossible----
    Run Keyword And Expect Error    ${expect_error_2}   Add new cell to power group
    ...    power_group_id=1
    ...    cell_id=3
    ...    cell_switch_off_order=90
    ...    node_index=1
    ...    activate_plan_despite_errors=${False}

Check if proper values of each parameters will be accepted
     [Documentation]    Check if proper values of each parameters will be accepted-
    Log to console    \n----Check if proper values of each parameters will be accepted----
    Turn on lbps for specific time step by step selenium
    ...    lbps_day_of_week=Sun
    ...    lbps_duration_in_min=18
    ...    lbps_start_time_hour=19
    ...    lbps_start_time_minute=20
    ...    node_index=0
    ...    power_group_id=1
    ...    activate_plan_despite_errors=${False}
    Turn on lbps for specific percentage step by step selenium
    ...    lbps_max_load=61
    ...    lbps_min_load=21
    ...    lbps_last_min_load=1
    ...    power_group_id=1
    ...    activate_plan_despite_errors=${False}
    Add new cell to power group
    ...    power_group_id=1
    ...    cell_id=3
    ...    cell_switch_off_order=51
    ...    node_index=1
    ...    activate_plan_despite_errors=${False}
    Remove cell from power group
    ...    power_group_id=1
    ...    node_index=1

Adjust Parameters for Specific Power Group
    [Arguments]     ${min_load}     ${offset}
    Perform Configuration Parameter Recommissioning On gNB      dist_name=${dist_name_power_group}
    ...   param_name=lbpsLastCellMinLoad    operation=update    param_value=${min_load}
    ...   skip_parameter_relation_errors=${true}
    Perform Configuration Parameter Recommissioning On gNB      dist_name=${dist_name_power_group}
    ...   param_name=lbpsPdcchLoadOffset   operation=update    param_value=${offset}
    ...   skip_parameter_relation_errors=${true}
    Perform Configuration Parameter Recommissioning On gNB      dist_name=${dist_name_power_group}
    ...   param_name=lbpsLastCellSOEnabled    operation=update    param_value=true
    ...   skip_parameter_relation_errors=${true}

Perform Cell Level Measurement
    [Arguments]     ${min_load}     ${offset}    ${tput}    ${dec_tput}
    Adjust Parameters for Specific Power Group              min_load=${min_load}            offset=${offset}
    Perform Attach and Verify UE Properly Attached      ${UE_alias}
    Run Throughput                  UE_alias=${UE_alias}    capabilities=${capabilities}    dt_name=${dt_name}
    ...                             direction=${direction}  throughput=${tput}              duration=300s
    ...                             protocol=${protocol}    packet_size=${packet_size}      tput=${tput}
    ...                             deviation=${deviation}  buffer_client=${buffer_client}  buffer_server=${buffer_server}
    Wait Until Cell Will Be In State Not Energy Saving      cell_id=1
    Perform Attach and Verify UE Properly Attached      ${UE_alias}
    Run Throughput                  UE_alias=${UE_alias}    capabilities=${capabilities}    dt_name=${dt_name}
    ...                             direction=${direction}  throughput=${dec_tput}          duration=300s
    ...                             protocol=${protocol}    packet_size=${packet_size}      tput=${dec_tput}
    ...                             deviation=${deviation}  buffer_client=${buffer_client}  buffer_server=${buffer_server}
    Wait Until Cell Will Be In State Energy Saving          cell_id=1
    Verify gNB Cell is onAir    cell_id=2

Verify if Cell Has Recovered
    Perform Configuration Parameter Recommissioning On gNB      dist_name=${dist_name_power_group}
    ...   param_name=lbpsLastCellSOEnabled    operation=update    param_value=false
    ...   skip_parameter_relation_errors=${true}
    Verify if Parameter Changed to Correct Value via GUI     dist_name=${dist_name_power_group}
    ...    parameter=${parameter_suspended}     value=suspended    node_index=0
    Wait for cell to be OnAir    cell_id=1    timeout=600
    Verify if Parameter Changed to Correct Value via GUI     dist_name=${dist_name_power_group}
    ...    parameter=${parameter_suspended}     value=notSuspended    node_index=0
    Verify gNB Cell is onAir

Create and Prepare New Power Group
    Add new power group    power_group_id=0     cell_id=1
    Turn on lbps for specific time via GUI   how_many_mins_lbps_should_work=60     delay=0    node_index=0

Wait for measurements
    [Arguments]     ${interval}=1   ${measurements}=1
    [Documentation]  Wait for several intervals PM counters
    ...     :param interval: Interval for PM counters
    ...     :param measurements: Numbers of intervals, to wait one more intervals then specified
    ...     :return: None
    feature_resources.wait_for_measurement   interval=${interval}    measurements=${measurements}
