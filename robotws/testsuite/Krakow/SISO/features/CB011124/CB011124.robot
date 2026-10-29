*** Settings ***
Documentation
...   TC for CB011124 feature.
...   author: Szymon Skorupski, Damian Silkowski

Library      taf.rfrl.common_resources.python.counters_validation                   WITH NAME    cv
Library      testsuite.Krakow.SISO.features.CB011124.resources.py_res               WITH NAME    py_kw
Library      taf.rfrl.bts.devices.ru.ru_operations.GnbRuOperations                  WITH NAME    ru

Resource     taf/rfrl/bts/robot/common/gnb_scf.robot
Resource     taf/rfrl/bts/robot/common/gnb_counter.robot
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot

Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables    testsuite/Krakow/SISO/features/CB011124/resources/CB011124_values.py
Variables    testsuite/Krakow/SISO/features/CB011124/resources/additional_allowed_alarms.py

Suite Setup       common_setups_and_teardowns.Common Suite Setup With OnAir Test Line Preparation
...               list_of_additional_allowed_alarms=${additional_allowed_alarms}
Suite Teardown    common_setups_and_teardowns.Common Suite Teardown

Test Setup        common_setups_and_teardowns.Common Preconditions With Watching Alarms
Test Teardown     common_setups_and_teardowns.Common Postconditions With Watching Alarms

*** Test Cases ***
[1][1.0]_CB011124_A_1_CVR_SFP_monitoring_counters_TEC_Current_for_RMOD_RF7.1
    [Documentation]    Verify if counters (thermo-electric cooler current per SFP/QSFP module in RMOD) updated for
    ...                AVQQA L1250806865 RMOD-11 (SFP1).
    ...    1. Enable measurement for SFP RMOD counters - MNL.MNLENT.PMMNL.mtSBTSSfpRMOD = 5min
    ...    2. Wait until next pm counter period (5min).
    ...    3. Verify if counters updated for SFP-1 in RMOD-11.
    ...         TEC_CURRENT:
    ...             MIN_TEC_CURRENT_SFP_RM: M40005C7,
    ...             MAX_TEC_CURRENT_SFP_RM: M40005C8,
    ...             SUM_TEC_CURRENT_SFP_RM: M40005C9,
    ...             SBTS_SFPRM_DURATION:    M40005C3,
    ...    4. Verify if counters value is logically correct - MIN < MAX - (removed < SUM because of negative values)
    ...    5. Verify counter value is expected - lowest_expected < MIN < MAX < highest_expected
    ...    6. Calculate avarage value and verify it is logically correct:
    ...         AVG = SUM_TEC_CURRENT_SFP_RM/SBTS_SFPRM_DURATION
    ...         MIN<AVG<MAX
    ${lowest_expected_cnt_value}                    Set Variable    -800
    ${highest_expected_cnt_value}                   Set Variable    800
    @{all_counters_to_get}                          Create List     M40005C7    M40005C8    M40005C9    M40005C3
    @{min_max_counters}                             Create List     M40005C7    M40005C8
    @{sum_duration_counter}                         Create List     M40005C9    M40005C3
    @{elem}                                         Create List     RMOD-11     SFP-1       SBTS_SFP_RMOD
    ${sfp_rmod_dist_name}                           py_kw.prepare_distname_for_sfp_rmod
    gnb_scf.Perform Object Recommissioning On gNB
    ...                                             dist_name=${sfp_rmod_dist_name}
    ...                                             parameter=${mtSBTSSfpRMOD_update_5min}
    ...                                             operation=update
    ...                                             skip_parameter_relation_errors=${False}
    ...                                             should_activate=${True}
    gnb_counter.Wait for next PM period             5
    Sleep                                           180s    reason=Waiting for collect counters by BTS
    ${cnt_value}                                    cv.get_counters      ${all_counters_to_get}
    ${splited_cnt_value}                            cv.split_counter_output     ${cnt_value}            ${elem}
    FOR    ${cnt}    IN    @{splited_cnt_value}
        Verify logical correctness of counters      counter_values=${cnt}
        ...                                         cnt_to_verify=${min_max_counters}
        Verify counters value                       counter_values=${cnt}
        ...                                         cnt_to_verify=${min_max_counters}
        ...                                         low_expected=${lowest_expected_cnt_value}
        ...                                         high_expected=${highest_expected_cnt_value}
        Vefiry average value                        counter_values=${cnt}
        ...                                         cnt_to_verify=${sum_duration_counter}
        ...                                         low_expected=${lowest_expected_cnt_value}
        ...                                         high_expected=${highest_expected_cnt_value}
    END

[1][1.0] CB011124_A_15_CVR_SFP_monitoring_counters_TEC_Current_for_BBMOD_ABIP
    [Documentation]    Verify if counters updated for ABIP L1233704815 - BBMOD-6 SFP5 - cooled SFP connected.
    ...    1. Enable measurement for SFP RMOD counters - MNL.MNLENT.PMMNL.mtSBTSSfpRMOD = 5min
    ...    2. Wait until next pm counter period (5min).
    ...    3. Verify if counters updated for each SFP in RU.
    ...         TEC_CURRENT:
    ...             MIN_TEC_CURRENT_SFP_BB: M40007C7,
    ...             MAX_TEC_CURRENT_SFP_BB: M40007C8,
    ...             SUM_TEC_CURRENT_SFP_BB: M40007C9,
    ...             BTS_SFPBM_DURATION: M40007C3,
    ...    4. Verify if counters value is logically correct - MIN < MAX - (removed < SUM because of negative values)
    ...    5. Verify counter value is expected - lowest_expected < MIN < MAX < highest_expected
    ...    6. Calculate avarage value and verify it is logically correct:
    ...         AVG = SUM_TEC_CURRENT_SFP_RM/SBTS_SFPRM_DURATION
    ...         MIN<AVG<MAX
    ${lowest_expected_cnt_value}                    Set Variable    -800
    ${highest_expected_cnt_value}                   Set Variable    800
    @{all_counters_to_get}                          Create List     M40007C7    M40007C8    M40007C9    M40007C3
    @{min_max_counters}                             Create List     M40007C7    M40007C8
    @{sum_duration_counter}                         Create List     M40007C9    M40007C3
    @{elem}                                         Create List     BBMOD-6     SFP-5       SBTS_SFP_BBMOD
    ${sfp_rmod_dist_name}                           py_kw.prepare_distname_for_sfp_rmod
    gnb_scf.Perform Object Recommissioning On gNB
    ...    dist_name=${sfp_rmod_dist_name}
    ...    parameter=${mtSBTSSfpRMOD_update_5min}
    ...    operation=update
    ...    skip_parameter_relation_errors=${False}
    ...    should_activate=${True}
    gnb_counter.Wait for next PM period             5
    Sleep                                           180s    reason=Waiting for collect counters by BTS
    ${cnt_value}                                    cv.get_counters      ${all_counters_to_get}
    ${splited_cnt_value}                            cv.split_counter_output     ${cnt_value}            ${elem}
    FOR    ${cnt}    IN    @{splited_cnt_value}
        Verify logical correctness of counters      counter_values=${cnt}
        ...                                         cnt_to_verify=${min_max_counters}
        Verify counters value                       counter_values=${cnt}
        ...                                         cnt_to_verify=${min_max_counters}
        ...                                         low_expected=${lowest_expected_cnt_value}
        ...                                         high_expected=${highest_expected_cnt_value}
        Vefiry average value                        counter_values=${cnt}
        ...                                         cnt_to_verify=${sum_duration_counter}
        ...                                         low_expected=${lowest_expected_cnt_value}
        ...                                         high_expected=${highest_expected_cnt_value}
    END

[1][1.0] CB011124_B_10_CVR_SFP_monitoring_counters_Tx_Supply_Voltage_Current_for_SMOD_ASIM
    [Documentation]
    ...    1. Enable measurement for SFP SMOD counters - MNL.MNLENT.PMMNL.mtSBTSSfpSMOD = 5min,
    ...    2. Wait until next pm counter period (5min).
    ...    3. Verify if counters updated for ASIM L1233302542 (master) for EIF-1:
    ...         TX_SUPPLY_VOLT_SFP_MOD_SM: M40006C10
    ...    4. Verify counter value is expected - 3250mV < TX_SUPPLY_VOLT_SFP_MOD_SM<3350mV
    ...    5. Verify counters in WebEM:
    ...         SFP details/Measurements/Tx supply voltage - TX_SUPPLY_VOLT_SFP_MOD_SM +-5 mV
    ...         Diagnostic/SFP Monitoring - TX_SUPPLY_VOLT_SFP_MOD_SM +-5mV
    ${lowest_expected_cnt_value}            Set Variable    3250
    ${highest_expected_cnt_value}           Set Variable    3350
    @{counter_to_get}                       Create List     M40006C10
    @{elem}                                 Create List     SBTS_SFP_SMOD
    ${sfp_rmod_dist_name}                   py_kw.prepare_distname_for_sfp_rmod
    gnb_scf.Perform Object Recommissioning On gNB
    ...                                     dist_name=${sfp_rmod_dist_name}
    ...                                     parameter=${mtSBTSSfpSMOD_update_5min}
    ...                                     operation=update
    ...                                     skip_parameter_relation_errors=${False}
    ...                                     should_activate=${True}
    gnb_counter.Wait for next PM period     5
    Sleep                                   180s    reason=Waiting for collect counters by BTS
    ${cnt_value}                            cv.get_counters      ${counter_to_get}
    ${splited_cnt_value}                    cv.split_counter_output     ${cnt_value}        ${elem}
    FOR    ${cnt}    IN    @{splited_cnt_value}
        Verify counters value               counter_values=${cnt}
        ...                                 cnt_to_verify=${counter_to_get}
        ...                                 low_expected=${lowest_expected_cnt_value}
        ...                                 high_expected=${highest_expected_cnt_value}
    END

[1]CB011124_C_1_CVR_SFP_monitoring_counters_FEC_Current_for_RMOD_RF7.1
    [Documentation]
    ...    1. Enable measurement for SFP SMOD counters - MNL.MNLENT.PMMNL.mtSBTSSfpRMODlane = 5min,
    ...    2. Wait until next pm counter period (5min).
    ...    3. Verify if counters updated for AVQQA RMOD-11 (SFP1 and SF2)
    ...         ECPRI_RM_PHY_FEC_CW_COR: M40013C13
    ...         ECPRI_RM_PHY_FEC_CW_UNCOR: M40013C12
    ...    4. Verify counter value is expected) - both 0
    @{counter_to_get}                       Create List                 M40013C12           M40013C13
    @{elem}                                 Create List                 SFP-1               SBTS_SFP_RMOD_LANE
    ${sfp_rmod_dist_name}                   py_kw.prepare_distname_for_sfp_rmod
    gnb_scf.Perform Object Recommissioning On gNB
    ...                                     dist_name=${sfp_rmod_dist_name}
    ...                                     parameter=${mtSBTSSfpRMODlane_update_5min}
    ...                                     operation=update
    ...                                     skip_parameter_relation_errors=${False}
    ...                                     should_activate=${True}
    gnb_counter.Wait for next PM period     5
    Sleep                                   180s    reason=Waiting for collect counters by BTS
    ${cnt_value}                            cv.get_counters      ${counter_to_get}
    ${splited_cnt_value}                    cv.split_counter_output     ${cnt_value}        ${elem}
    FOR    ${cnt}    IN    @{splited_cnt_value}
        Compare counters value              counter_values=${cnt}
        ...                                 cnt_to_compare=${counter_to_get}
    END

[1][1.0] CB011124_C_8_CVR_SFP_monitoring_counters_FEC_BLER_Current_for_BBMOD_ABIP
    [Documentation]
    ...    1. Enable measurement for SFP SMOD counters - MNL.MNLENT.PMMNL.mtSBTSSfpBBMODlane = 5min,
    ...    2. Wait until next pm counter period (5min).
    ...    3. Verify if counters updated for AVQQA RMOD-11 (SFP1 and SF2)
    ...         ECPRI_BB_PHY_FEC_BL_UNCOR: M40015C14
    ...         ECPRI_BB_PHY_FEC_CW_UNCOR: M40015C15
    ...    4. Verify counter value is expected) - both 0
    @{counter_to_get}                       Create List                 M40015C14           M40015C15
    @{elem}                                 Create List                 SFP-1               SBTS_SFP_BBMOD_LANE
    ${sfp_rmod_dist_name}                   py_kw.prepare_distname_for_sfp_rmod
    gnb_scf.Perform Object Recommissioning On gNB
    ...                                     dist_name=${sfp_rmod_dist_name}
    ...                                     parameter=${mtSBTSSfpBBMODlane_update_5min}
    ...                                     operation=update
    ...                                     skip_parameter_relation_errors=${False}
    ...                                     should_activate=${True}
    gnb_counter.Wait for next PM period     5
    Sleep                                   180s    reason=Waiting for collect counters by BTS
    ${cnt_value}                            cv.get_counters      ${counter_to_get}
    ${splited_cnt_value}                    cv.split_counter_output     ${cnt_value}        ${elem}
    FOR    ${cnt}    IN    @{splited_cnt_value}
        Compare counters value              counter_values=${cnt}
        ...                                 cnt_to_compare=${counter_to_get}
    END

*** Keywords ***
Verify logical correctness of counters
    [Documentation]    Verify if counters value is logically correct - MIN < MAX < SUM
    [Arguments]    ${counter_values}    ${cnt_to_verify}    ${operator}=<=
    Run Keyword And Continue On Failure    cv.check_counters_logic
    ...                                    cnt_values=${counter_values}
    ...                                    counters_to_verify=${cnt_to_verify}
    ...                                    operator=${operator}

Verify counters value
    [Documentation]    Verify counter value is expected - lowest_expected < MIN < MAX < highest_expected
    [Arguments]    ${counter_values}    ${cnt_to_verify}    ${low_expected}    ${high_expected}    ${operator}=<=
    Run Keyword And Continue On Failure    cv.check_counters_logic
    ...                                    cnt_values=${counter_values}
    ...                                    counters_to_verify=${cnt_to_verify}
    ...                                    operator=${operator}
    ...                                    min_val=${low_expected}
    ...                                    max_val=${high_expected}

Vefiry average value
    [DOCUMENTATION]    Calculate avarage value and verify it is logically correct - MIN < AVG < MAX
    [Arguments]    ${counter_values}    ${cnt_to_verify}    ${low_expected}    ${high_expected}    ${operator}=<=
    ${data_to_compare_avg}    cv.calculate_and_compare_cnt_avg_value    cnt_values=${counter_values}
    ...                                                                 counters_to_verify=${cnt_to_verify}
    ...                                                                 operator=${operator}
    ...                                                                 min_val=${low_expected}
    ...                                                                 max_val=${high_expected}

Compare counters value
    [DOCUMENTATION]    Compare counters value from data
    [Arguments]    ${counter_values}    ${cnt_to_compare}
    Run Keyword And Continue On Failure    cv.check_counters_value_consistency
    ...                                    cnt_values=${counter_values}
    ...                                    counters_to_compare=${cnt_to_compare}
    ...                                    expected_val=0
