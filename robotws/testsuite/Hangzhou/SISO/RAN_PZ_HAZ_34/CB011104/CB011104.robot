*** Settings ***
Documentation
...    Author:shifu.lan@nokia-sbell.com
...    Team group: VRF_HAZ4_T04
...    Feature Owner: Shi Gaofan
...    Feature CB011104 AVHQB in trunk program

Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           SISO Coam Test Setup    fail_with_alarms=${True}    is_ru_log_collecting_enable=${True}
Test Teardown        SISO Coam Test Teardown
Test Timeout         8h

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    ${BASIC_PATH_5G}/E2E_SiSo_RU_lock_and_unlock_gNB.robot
Resource    ${BASIC_PATH_5G}/RF/Genaral_SiSo_MAA_radio_Pipe_failure_alarm_handling_validation_dualband.robot
Resource    ${BASIC_PATH_COMMON}/Manual_SiSo_Validating_max_allowed_power_on_RU.robot
Resource    ./Resource/CB011104_common_keywords.robot
Resource    ../CB009936/Resource/CB009936_common_keyword.robot

Force Tags    HAZ4_T04


*** Test Cases ***
[1]CB011104-SR-A_10_Manual_SiSo_Validating_max_allowed_power_on_RU
    [Tags]    RF50
    ${fault_list}    Create List    1900
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    Manual_SiSo_Validating_max_allowed_power_on_RU  with_call=${True}    ue_num_each_call=2
    # WESTLAKE-12463, This is an abnormal alarm test. The "teardown" operation requires a forced restoration.
    [Teardown]    SISO Coam Test Teardown    perform_case_scf=${True}

[1]CB011104-SR-B_01_Manual_SiSo_SM_RF_Module_lock_unlock
    [Tags]    RF50    HAZ4_T04
    [Setup]    SISO Coam Test Setup    fail_with_alarms=${True}   enable_err_wrn=${True}
    E2E_SiSo_RU_lock_and_unlock_gNB  with_call=${True}    ue_num_each_call=2

[1]CB011104-SR-C_07_General_SiSo_Cell_block_and_unblock
    ${fault_list}    Create List    49
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    Commissioning SCF And Check On Air      scf_path=${Case_SCF_Path}
    CB011104_SiSo_Cell_block_and_unblock_4CC    ue_num_each_call=${4}    suite_name=${SUITE NAME}    test_name=${TEST NAME}

[1]CB011104-SR-C_13_General_SiSo_E2E_system_setup_with_data_transfer_conducted_100+100+20+20Mhz
    [Tags]    1S-2CC-16D-8U
    L3Call_setup_with_data_transfer_conducted_100M_20M_100M_20M    with_call=${True}    ue_num_each_call=${2}
    [Teardown]    SISO Coam Test Teardown    perform_case_scf=${True}

[1]CB011104-SR-D_01_Genaral_SiSo_MAA_radio_Pipe_failure_alarm_handling_validation_based_on_CNI-51714
    ${fault_list}    Create List    2922    2923
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    Genaral_SiSo_MAA_radio_Pipe_failure_alarm_handling_validation_dualband
    [Teardown]    SISO Coam Test Teardown    perform_case_scf=${True}

[1]CB011104-SR-D_06_Manual_SiSo_TEST_UL_Time_Domain_IQ_Raw_Data_snapshot_for_eCPRI
    [Documentation]    Verify that UL direction IQ data meets expectations during L3 call
    ${fault_list}    Create List    8101
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    Commissioning SCF And Check On Air    scf_path=${Case_SCF_Path}
    TEST_UL_Time_Domain_IQ_Raw_Data_snapshot_for_eCPRI    with_call=${True}    with_peak=${True}
    ...    duration=${300}    ue_num_each_call=${1}    cell_id=${141}    direction=UL
    [Teardown]    SISO Coam Test Teardown    perform_case_scf=${True}

[1]CB011104-SR-E_23_KPI_counter_check_with_Radio_realted_parameter_adjustment_in_dual_band_radio
    Log    \nPerforming commission to generate counter data for case only    console=yes
    Commissioning SCF And Check On Air      scf_path=${Case_SCF_Path}
    KPI_counter_check_in_dual_band_radio    with_call=${True}    with_peak=${True}    call_duration=${300}    ue_num_each_call=${2}
    [Teardown]    SISO Coam Test Teardown    perform_case_scf=${True}

[1]CB011104-SR-M_CB012091_Returning_from_Extreme_Deep_Sleep_Mode_to_normal_operation
    [Tags]    1S-4CC-CB012091
    ${fault_list}    Create List    49
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    Returning From Extreme DeepSleep Mode To Normal Via RU Operation    with_call=${True}    with_peak=${True}
    ...    call_duration=${300}    ue_num_each_call=${2}
    [Teardown]    SISO Coam Test Teardown    perform_case_scf=${True}

[1]CB011104-SR-N_CB009301_measure_eCPRI_delay_with_MSG5
    Commissioning SCF And Check On Air      scf_path=${Case_SCF_Path}
    CB009301_measure_eCPRI_delay_with_MSG5    with_call=${True}    with_peak=${True}    call_duration=${300}    ue_num_each_call=${2}

[1]CB011104-SR-N_CB007935_Assisted_SyncE_HO_Estimate_No_impairment
    [Timeout]    8h
    Log    \nPerforming commission to initial estimatedHoldoverTime value for case only    console=yes
    Commissioning SCF And Check On Air      scf_path=${Case_SCF_Path}
    CB007935_Assisted_SyncE_HO_Estimate_No_impairment    with_call=${True}    ue_num_each_call=${2}
