*** Settings ***
Documentation
...    Author: Slawomir Szopinski, slawomir.szopinski@nokia.com
...    Maintainer:


Library        DateTime
Library        taf.rfrl.bts.devices.ru.ru_operations.GenericRuOperations    WITH NAME   GnbRadio
Library        taf/rfrl/procedures/resources/python/common_allowed_alarms.py    WITH NAME     caa
Library        testsuite.Krakow.OAM.regression.RAN_PZ_KRK2.CB010611.resources.CellCustom.GnbCellCustom    WITH NAME    GnbCellCustom
Library        testsuite.Krakow.OAM.regression.RAN_PZ_KRK2.CB010611.resources.DuCustom.GnbDuCustom    WITH NAME    GnbDu
Library        testsuite.Krakow.OAM.regression.RAN_PZ_KRK2.CB010611.resources.AsirCustom.GnbAsirCustom    WITH NAME    GnbAsir
Library        testsuite.Krakow.resources.RAN_PZ_KRK2.SMAWave.SMAWaveTput   WITH NAME    SMAWave
Resource       taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource       ../../FR_CB009493_CB009055_CB009487/resources/keywords.robot
Variables      taf/rfrl/procedures/resources/python/common_allowed_alarms.py

*** Variables ***
${asir_scf_file}     /tmp/temp_asir_scf.xml
${lbpsSOffTrRule}    ${None}
${MaxValue}          ${False}
${SlidingValue}      ${False}

*** Keywords ***
Verify Parameters Are Set To Correct Value For Cell Lock/Unlock
    ${recommission}    Set Variable    ${False}
    GnbDu.check_if_parameter_is_set_to_correct_value
    ...    dist_name=MRBTS-{}/NRBTS-{}
    ...    parameter=Activate NR load-based power saving
    ...    param_abbr=actNrLBPowerSaving
    ...    value=true
    GnbAsir.download_asir_scf    asir_scf_path=${asir_scf_file}
    ${recommission_actLb}    GnbAsir.verify_scfc_parameters_and_set_to_value
    ...    class_name=com.nokia.asi:HUBMOD
    ...    param_name=actLbEnergySaving
    ...    expected_value=true
    ...    asir_scf_path=${asir_scf_file}
    ${recommission_lbEnergy}    GnbAsir.verify_scfc_parameters_and_set_to_value
    ...    class_name=com.nokia.asi:HUBMOD
    ...    param_name=lbEnergySavingActDelay
    ...    expected_value=5
    ...    asir_scf_path=${asir_scf_file}
    ${recommission_pRrhPower}    GnbAsir.verify_scfc_parameters_and_set_to_value
    ...    class_name=com.nokia.asi:HUBMOD
    ...    param_name=pRrhPowerOffDelay
    ...    expected_value=300
    ...    asir_scf_path=${asir_scf_file}
    ${recommission}    Is Recommissioning Needed    ${recommission_actLb}    ${recommission_lbEnergy}    ${recommission_pRrhPower}
    Run Keyword If    ${recommission}    GnbAsir.reset_configuration
    Run Keyword If    ${recommission}    Verify Disabled Status
    Run Keyword If    ${recommission}    Verify RU Status After Asir Configuration Reset
    Run Keyword If    ${recommission}    GnbAsir.perform_asir_commissioning    ${asir_scf_file}
    Run Keyword If    ${recommission}    Wait For All Cells To Be In onAir State After Asir Recommissioning

Is Recommissioning Needed
    [Arguments]    ${var1}=${VAR1}    ${var2}=${VAR2}    ${var3}=${VAR3}
    ${result}=    Evaluate    ${var1} or ${var2} or ${var3}
    [Return]    ${result}

Set Parameters To Correct Value For Low Traffic
    ${recommission}    Set Variable    ${False}
    GnbDu.check_if_parameter_is_set_to_correct_value
    ...    dist_name=MRBTS-{}/NRBTS-{}/NRPGRP-1
    ...    parameter=Load-based power saving minimum load
    ...    param_abbr=lbpsMinLoad
    ...    value=10
    GnbDu.check_if_parameter_is_set_to_correct_value
    ...    dist_name=MRBTS-{}/NRBTS-{}/NRPGRP-1
    ...    parameter=Load-based power saving last cell minimum load
    ...    param_abbr=lbpsLastCellMinLoad
    ...    value=10
    GnbDu.check_if_parameter_is_set_to_correct_value
    ...    dist_name=MRBTS-{}/NRBTS-{}/NRPGRP-1
    ...    parameter=Load-based power saving last cell switch off enabled
    ...    param_abbr=lbpsLastCellSOEnabled
    ...    value=true
    ${gnb_scf_file}    GnbDu.get_bts_configuration_file
    ${recommission}    GnbDu.verify_lbps_parameters_and_set_to_predefined_value
    ...    class_name=com.nokia.srbts.nrbts:NRPGRP
    ...    list_name=lbpsPeriodList
    ...    gnb_scf_path=${gnb_scf_file}
    Run Keyword If    ${recommission}    GnbDu.upload_bts_configuration_via_gui    path=${gnb_scf_file}
    Run Keyword If    ${recommission}    Wait For All Cells To Be In onAir State After BTS Commissioning
    GnbDu.check_if_parameter_is_set_to_correct_value
    ...    dist_name=MRBTS-{}/NRBTS-{}/NRPGRP-1
    ...    parameter=Load-Based Power Saving Suspended
    ...    param_abbr=lbpsSuspended
    ...    value=notSuspended

Run Tput And Wait For Cell To Be Disabled
    SMAWave.run_downlink_traffic_and_wait_for_0_tput
    ...    duration_time=900
    ...    tput_command=45

Verify MultiRAT Configuration
    GnbCellCustom.verify_multiRAT_configuration

Perform L3Call
    SMAWave.run_bidirectional_traffic    duration_time=300    parallel_streams=1

Verify Hostcell Bandwidth
    SMAWave.verify_nr_hostcell_bandwidth    bandwidth=20

Save Test Start Time
    ${saved_time}    DateTime.Get Current Date    result_format=epoch    exclude_millis=True
    Set Test Variable    ${TEST_START_TIME}    ${saved_time}

Verify If Cells Are Disabled During Traffic
    @{cell_ids}    Create List    ${2}    ${4}
    Run Keyword If    ${MaxValue}    Wait For Cells With MaxValueMethod
    Run Keyword If    ${SlidingValue}    Wait For Cells With SlidingAverageMethod

Wait For Cells With MaxValueMethod
    Wait Until Keyword Succeeds    1 min    15 sec    GnbCellCustom.compare_delta_cell_downtime
        ...    test_start_time=${START_TIME}
        ...    start_time=${TEST_START_TIME}
        ...    cell_ids=${cell_ids}
        ...    min_time=${300}
        ...    max_time=${480}

Wait For Cells With SlidingAverageMethod
    Wait Until Keyword Succeeds    1 min    15 sec    GnbCellCustom.compare_delta_cell_downtime
        ...    test_start_time=${START_TIME}
        ...    start_time=${TEST_START_TIME}
        ...    cell_ids=${cell_ids}
        ...    min_time=${50}
        ...    max_time=${480}

Set lbpsPeriodList To Be Suspended
    GnbDu.check_if_parameter_is_set_to_correct_value
    ...    dist_name=MRBTS-{}/NRBTS-{}/NRPGRP-1
    ...    parameter=Load-Based Power Saving Suspended
    ...    param_abbr=lbpsSuspended
    ...    value=suspended
    Wait For All Cells To Be In onAir State
    Common Postconditions

Verify Disabled Status
    Wait Until Keyword Succeeds    1 min    15 sec    GnbRadio.wait_for_all_radio_unit_statuses    radio_type=asirmod    operational_state=disabled

Verify RU Status After Asir Configuration Reset
    Wait Until Keyword Succeeds    5 min    15 sec    GnbRadio.verify_all_radio_units_are_online    radio_type=asirmod

Wait For All Cells To Be In onAir State After Cell Unlock
    Wait Until Keyword Succeeds    2 min    15 sec    GnbCellCustom.verify_all_cells_are_onair

Wait For All Cells To Be In onAir State After Asir Recommissioning
    Wait Until Keyword Succeeds    8 min    15 sec    GnbCellCustom.verify_all_cells_are_onair

Wait For All Cells To Be In onAir State After BTS Commissioning
    Wait Until Keyword Succeeds    15 min    15 sec    GnbCellCustom.verify_all_cells_are_onair

Wait For All Cells To Be In onAir State
    Wait Until Keyword Succeeds    5 min    15 sec    GnbCellCustom.verify_all_cells_are_onair

Reset ASIRMOD And Wait For All Cells To Be OnAir
    GnbRadio.reset_radio_unit    radio_unit_id=1    radio_type=asirmod
    Wait For All Cells To Be In onAir State

Reset ANTMOD In Loop And Wait For All Cells To Be OnAir
    FOR     ${index}    IN RANGE    20
        Save Test Start Time
        GnbAsir.reset_antenna    ant_id=2
        Wait For All Cells To Be In onAir State
        Check If Downtime Is Within KPI
    END

Verify lbpsSOffTrRule Value
    Set Test Variable    @{lbpsSOffTrRule}    GnbDu.verify_lbpsSOffTrRule_value
    ...    dist_name=MRBTS-{}/NRBTS-{}/NRPGRP-1
    ...    parameter=Load-based PS switch off triggering rule
    ...    param_abbr=lbpsSOffTrRule

Set Bool Parameteres for lbpsSOffTrRule
    IF    '@{lbpsSOffTrRule}' == 'MaxValueMethod'
        Set Test Variable    ${MaxValue}    ${True}
    ELSE IF    '@{lbpsSOffTrRule}' == 'SlidingAverageMethod'
        Set Test Variable    ${SlidingValue}    ${True}
    ELSE
        Fail    lbpsSOffTrRule is not equal to MaxValueMethod or SlidingAverageMethod

Check If Downtime Is Within KPI
    GnbCellCustom.check_KPI    test_start_time=${TEST_START_TIME}    #kpi_value=330

Lock NRCELL-2 And Wait 7 Minutes
    @{pRRH_ids}    Create List    ${3}
    GnbCellCustom.lock_cell    cell_id=2
    Wait Until Keyword Succeeds    1 min    15 sec    GnbCellCustom.verify_cell_is_locked    cell_id=2
    Wait Until Keyword Succeeds    7 min    15 sec    GnbAsir.verify_antennas_are_disabled    ${pRRH_ids}

Lock NRCELL-4 And Wait 7 Minutes
    @{pRRH_ids}    Create List    ${3}    ${4}
    GnbCellCustom.lock_cell    cell_id=4
    Wait Until Keyword Succeeds    1 min    15 sec    GnbCellCustom.verify_cell_is_locked    cell_id=4
    Wait Until Keyword Succeeds    7 min    15 sec    GnbAsir.verify_antennas_are_disabled    ${pRRH_ids}

Lock NRCELL-6 And Wait 7 Minutes
    @{pRRH_ids}    Create List    ${3}    ${4}    ${2}
    GnbCellCustom.lock_cell    cell_id=6
    Wait Until Keyword Succeeds    1 min    15 sec    GnbCellCustom.verify_cell_is_locked    cell_id=6
    Wait Until Keyword Succeeds    7 min    15 sec    GnbAsir.verify_antennas_are_disabled    ${pRRH_ids}

Unlock All Cells And Wait For All Cells To Be onAir
    @{cell_list}    Create List    2    4    6
    FOR    ${cell}    IN    @{cell_list}
        GnbCellCustom.unlock_cell    cell_id=${cell}
    END
    Wait For All Cells To Be In onAir State After Cell Unlock

Verify All pRRH Are Enabled
    GnbAsir.verify_all_antennas_are_enabled

Perform Lock Cell Test In Loop
    FOR    ${index}    IN RANGE    5
        Lock NRCELL-2 And Wait 7 Minutes
        Lock NRCELL-4 And Wait 7 Minutes
        Lock NRCELL-6 And Wait 7 Minutes
        Unlock All Cells And Wait For All Cells To Be onAir
        Verify All pRRH Are Enabled
    END

Verify Historic Alarms After Cell Lock
    [Arguments]    ${allowed_faults_sbts}=4654 61524 4655 61652 61649 7313 61648
    ...            ${allowed_faults_asir}=61648 4480
    Run Keyword and Continue On Failure    sbts_methods.check_sbts_history_alarm
    ...                                    appeared_time_later_than=${START_TIME}
    ...                                    allowed_fault_id_list=${allowed_faults_sbts}
    Run Keyword and Continue On Failure    GnbAsirOp.check_asir_history_alarm
    ...                                    appeared_time_later_than=${START_TIME}
    ...                                    allowed_fault_id_list=${allowed_faults_asir}

Verify Historic Alarms After BBMOD reset
    [Arguments]    ${allowed_faults_sbts}=4654 61524 4655 61652 61649 61648 7313
    ...            ${allowed_faults_asir}=61648 10 4480
    Run Keyword and Continue On Failure    sbts_methods.check_sbts_history_alarm
    ...                                    appeared_time_later_than=${START_TIME}
    ...                                    allowed_fault_id_list=${allowed_faults_sbts}
    Run Keyword and Continue On Failure    GnbAsirOp.check_asir_history_alarm
    ...                                    appeared_time_later_than=${START_TIME}
    ...                                    allowed_fault_id_list=${allowed_faults_asir}

Verify Historic Alarms After ANTMOD Reset
    [Arguments]    ${allowed_faults_sbts}=4654 61524 4655 61652 61649 4479 61648
    ...            ${allowed_faults_asir}=61648
    ...            ${required_history_asir_ResetANTMOD}=4480
    Run Keyword and Continue On Failure    sbts_methods.check_sbts_history_alarm
    ...                                    appeared_time_later_than=${START_TIME}
    ...                                    allowed_fault_id_list=${allowed_faults_sbts}
    Run Keyword and Continue On Failure    GnbAsirOp.check_asir_history_alarm
    ...                                    appeared_time_later_than=${START_TIME}
    ...                                    allowed_fault_id_list=${allowed_faults_asir}
    ...                                    required_fault_id_list=${required_history_asir_ResetANTMOD}

Verify Historic Alarms After ASIRMOD Reset
    [Arguments]    ${allowed_faults_sbts}=4654 61524 4655 61652 61649 4479 61648
    ...            ${allowed_faults_asir}=61648
    ...            ${required_history_asir_ResetASIRMOD}=10 4480
    Run Keyword and Continue On Failure    sbts_methods.check_sbts_history_alarm
    ...                                    appeared_time_later_than=${START_TIME}
    ...                                    allowed_fault_id_list=${allowed_faults_sbts}
    Run Keyword and Continue On Failure    GnbAsirOp.check_asir_history_alarm
    ...                                    appeared_time_later_than=${START_TIME}
    ...                                    allowed_fault_id_list=${allowed_faults_asir}
    ...                                    required_fault_id_list=${required_history_asir_ResetASIRMOD}

Verify Historic Alarms After L3Call
    [Arguments]    ${allowed_faults_sbts}=4654 61524 4655 61652 61649 4479 61648
    ...            ${allowed_faults_asir}=61648
    Run Keyword and Continue On Failure    sbts_methods.check_sbts_history_alarm
    ...                                    appeared_time_later_than=${START_TIME}
    ...                                    allowed_fault_id_list=${allowed_faults_sbts}
    Run Keyword and Continue On Failure    GnbAsirOp.check_asir_history_alarm
    ...                                    appeared_time_later_than=${START_TIME}
    ...                                    allowed_fault_id_list=${allowed_faults_asir}

Teardown For Cell Unlock
    Run Keyword If Test Failed    Unlock All Cells And Wait For All Cells To Be onAir
    GnbAsir.delete_backup_asir_scf    ${asir_scf_file}
    Common Postconditions
