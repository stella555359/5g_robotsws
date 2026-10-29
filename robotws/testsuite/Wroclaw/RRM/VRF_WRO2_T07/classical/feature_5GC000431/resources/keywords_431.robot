*** Settings ***
Documentation  keywords for 431 feature

Library       taf.ue
Library       taf.transport.ssh       WITH NAME    ssh
Library       testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/feature_5GC000431/resources/test_specific_keywords_431.py
Variables     testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/feature_5GC000431/resources/test_specific_keywords_431.py
Library       testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_utils.AdminUtils    WITH NAME    AdminUtils
Library       testsuite/Wroclaw/RRM/resources/scf_verification/scf_verifier.py
Library       testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/swconfig.py

*** Keywords ***
[1]5GC000431_A_1_Feature_5GC000431_Activation
    Feature activate      ${FALSE}
    ${feature_value}=     Check feature activation
    Should not be true    ${feature_value}

    Feature activate      ${TRUE}
    ${feature_value}=     Check feature activation
    Should be true        ${feature_value}


[1]5GC000431_A_3_Feature_5GC000431_Deactivation_with_cell_in_energySaving_state
    Feature activate      ${TRUE}
    ${feature_value}=     Check feature activation
    Should be true        ${feature_value}

    Update power saving period entrance   2
    AdminUtils.wait_for_all_cells_on_air_state
    Wait for cell to achieve energy saving state   ${2}

    Feature activate      ${FALSE}
    ${feature_value}=     Check feature activation
    Should not be true    ${feature_value}

    BuiltIn.Sleep   330   reason=Wait for potential energy saving entry state delay
    BuiltIn.Sleep   180   reason=Wait for gracefull cell shutdown switch off period

    Check if all cells are not saving energy


[1]5GC000431_A_4_Feature_5GC000431_Configure_Load-Based_Power_Saving_Controls
    Check Lpbsso parameters
    Check nrCellId
    Check lpbsLastCellMinLoad
    Check lpbsMaxLoad
    Check lpbsMinLoad
    Check lpbsPdcchOffset
    Check lbpsDayOfWeek
    Check lbpsDuration
    Check lbpsStartTimeHour
    Check lbpsStartTimeMinute


[1]5GC000431_A_7_Determine_Cell_Power_Saving_Mode
    Require UE     UE_1    capabilities=REAL_UE_NSA
    Attach UE      UE_1

    Update power saving period entrance   2
    AdminUtils.wait_for_all_cells_on_air_state

    Wait for cell to achieve energy saving state   ${2}
    Wait for cell to achieve energy saving state   ${3}

    Start Data Transfer
    ...     dt_name=DT_DL
    ...     ue_alias=UE_1
    ...     direction=DL
    ...     duration=480s
    ...     throughput=1 Gbits/sec
    ...     protocol=tcp
    ...     iperf_version=3
    ...     packet_size=1400

    BuiltIn.Sleep   360s

    ${cell_2_saving_energy}=   Is cell saving energy      cell_id=2
	${cell_3_saving_energy}=   Is cell saving energy      cell_id=3

    Should not be true   ${cell_2_saving_energy}
    Should not be true   ${cell_3_saving_energy}

    Await Data Transfer Finish    DT_DL
    [Teardown]   Teardown 431


[1]5GC000431_A_11_Handle_cell_outage_impact_on_capacity_cell_locking
    Set power saving period entrance   2
    AdminUtils.wait_for_all_cells_on_air_state

    Wait for cell to achieve energy saving state   ${3}
	${cell_1_saving_energy}=   Is cell saving energy   cell_id=1
    Should not be true   ${cell_1_saving_energy}

    test_specific_keywords_431.Lock Cell   1   ${TRUE}
    test_specific_keywords_431.Lock Cell   2   ${TRUE}

    BuiltIn.Sleep  60  reason=wait for third cell to nonEnergySaving after other cells have been locked

    ${cell_3_saving_energy}=   Is cell saving energy      cell_id=3
    Should not be true   ${cell_3_saving_energy}

    test_specific_keywords_431.Lock Cell   1   ${FALSE}
    test_specific_keywords_431.Lock Cell   2   ${FALSE}

    Require UE     UE_1    capabilities=REAL_ANDROID_UE
    Attach UE      UE_1

    [Teardown]   Teardown 431


[1]5GC000431_A_13_Suspend_Load-Based_Power_Saving
    Require UE     UE_1    capabilities=REAL_ANDROID_UE
    Attach UE      UE_1
    Update power saving period entrance   2
    AdminUtils.wait_for_all_cells_on_air_state
    Wait for cell to achieve energy saving state   ${2}
    Detach UE      UE_1
    Update second entrance period and suspend first one
    ${cell_2_saving_energy}=   Is cell saving energy      cell_id=2
    Should not be true   ${cell_2_saving_energy}
    Wait for cell to achieve energy saving state   ${2}
    Attach UE      UE_1
    [Teardown]   Teardown 431


[1]5GC000431_A_15_Un-suspend_Load-Based_Power_Saving
    Update power saving period entrance   5
    AdminUtils.wait_for_all_cells_on_air_state
    Wait for cell to achieve energy saving state   ${2}
    Wait for cell to achieve energy saving state   ${3}
    Change suspension
    BuiltIn.Sleep   60s
    ${cell_2_saving_energy}=   is cell saving energy      cell_id=2
	${cell_3_saving_energy}=   is cell saving energy      cell_id=3
    Should not be true   ${cell_2_saving_energy}
    Should not be true   ${cell_3_saving_energy}
    Change suspension    ${false}
    Wait for cell to achieve energy saving state   ${2}
    Wait for cell to achieve energy saving state   ${3}
    [Teardown]   Energy Saving Test Case Teardown

[1]5GC000431_A_20_Cell_Switch-off_Order_last_cell_switch_off_enabled
    Update power saving period entrance   5
    AdminUtils.wait_for_all_cells_on_air_state
    Change last cell energy saving possibility    ${TRUE}
    AdminUtils.wait_for_all_cells_on_air_state
    Test case A20 check
    [Teardown]   Energy Saving Test Case Teardown


Check Lpbsso parameters
    lpbsso_with_too_small_value
    lpbsso_with_correct_value
    lpbsso_with_too_big_value
    lpbsso_with_two_same_values
    lpbsso_with_two_hundreds


Check nrCellId
    lbps_nrcellid_correct
    lbps_nrcellid_two_same_values
    lbps_nrcellid_incorrect_value


Check lpbsLastCellMinLoad
    lpbs_last_cell_min_load_below_range
    lpbs_last_cell_min_load_in_range
    lpbs_last_cell_min_load_above_range


Check lpbsMaxLoad
    lpbs_max_load_below_range
    lpbs_max_load_in_range
    lpbs_max_load_above_range


Check lpbsMinLoad
    lpbs_min_load_below_range
    lpbs_min_load_in_range
    lpbs_min_load_above_range
    lpbs_min_load_higher_than_max_load


Check lpbsPdcchOffset
    lbps_pdcch_load_offset_below_range
    lbps_pdcch_load_offset_in_range
    lbps_pdcch_load_offset_above_range


Check lbpsDayOfWeek
    set_lbps_day_of_week_delta


Check lbpsDuration
    lbps_duration_below_range
    lbps_duration_in_range
    lbps_duration_above_range


Check lbpsStartTimeHour
    lbps_start_time_hour_below_range
    lbps_start_time_hour_in_range
    lbps_start_time_hour_above_range


Check lbpsStartTimeMinute
    lbps_start_time_minute_below_range
    lbps_start_time_minute_in_range
    lbps_start_time_minute_above_range


Setup A7
    [Documentation]   Additional swconfig flags added:
    ...               0x590072=1   ->  CP-RT log level (default 1 in 19B, 2 in 20A)
    ...               5GC000431 specific flags for time reduction (rdHighLoadSwitchOnDelay/rdHighLoadSwitchOnDelay),
    ...                 number of 10s periods Power Group load is higher than or equal Maximum Load threshold:
    ...                 0x5900a9=30  ->  after which gNB can switch on a cell, default 12=120s
    ...                 0x5900aa=12  ->  after which gNB can switch off a cell, default 30=300s
    prepare_swconfig   custom_swconfig_flags=${swconfig_flags_431}
    Set Test 7 Power Saving Mode Preconditions
    AdminUtils.wait_for_all_cells_on_air_state


Setup A11
    [Documentation]   Additional swconfig flags added:
    ...               0x590072=1   ->  CP-RT log level (default 1 in 19B, 2 in 20A)
    ...               5GC000431 specific flags for time reduction (rdHighLoadSwitchOnDelay/rdHighLoadSwitchOnDelay),
    ...                 number of 10s periods Power Group load is higher than or equal Maximum Load threshold:
    ...                 0x5900a9=30  ->  after which gNB can switch on a cell, default 12=120s
    ...                 0x5900aa=12  ->  after which gNB can switch off a cell, default 30=300s
    prepare_swconfig   custom_swconfig_flags=${swconfig_flags_431}
    Set Test 11 Power Saving Mode Preconditions
    AdminUtils.wait_for_all_cells_on_air_state


Wait for cell to achieve energy saving state
    [Arguments]   ${cell_id}
    Wait Until Keyword Succeeds    900s    10s   Assert cell saving energy is on
    ...                                          cell_id=${cell_id}


Teardown 431
    Detach UE      UE_1
    Energy Saving Test Case Teardown


Only second cell is saving energy
    ${first_cell_value}=    Is cell saving energy   cell_id=1
    ${second_cell_value}=   Is cell saving energy   cell_id=2
    ${third_cell_value}=    Is cell saving energy   cell_id=3
    Should be true          ${second_cell_value}
    Should not be true      ${first_cell_value}
    Should not be true      ${third_cell_value}


Only second and third cell are saving energy
    ${first_cell_value}=    Is cell saving energy   cell_id=1
    ${second_cell_value}=   Is cell saving energy   cell_id=2
    ${third_cell_value}=    Is cell saving energy   cell_id=3
    Should be true          ${second_cell_value}
    Should be true          ${third_cell_value}
    Should not be true      ${first_cell_value}


All cells saving energy
    ${first_cell_value}=    Is cell saving energy   cell_id=1
    ${second_cell_value}=   Is cell saving energy   cell_id=2
    ${third_cell_value}=    Is cell saving energy   cell_id=3
    Should be true          ${first_cell_value}
    Should be true          ${second_cell_value}
    Should be true          ${third_cell_value}


Test case A20 check
    Wait Until Keyword Succeeds    600s    10s    Only second cell is saving energy
    Wait Until Keyword Succeeds    600s    10s    Only second and third cell are saving energy
    Wait Until Keyword Succeeds    600s    10s    All cells saving energy
