*** Settings ***
Documentation    These are regression cases for feature CB009936
...              Contact: shifu.lan@nokia-sbell.com
...              Squard: VRF4_SG4

Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           SISO Coam Test Setup    fail_with_alarms=${True}    is_ru_log_collecting_enable=${True}
Test Teardown        SISO Coam Test Teardown
Test Timeout         8h

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    ${BASIC_PATH_5G}/RF/General_SiSo_RF_Fault_Signature_FID_4590.robot
Resource    ${BASIC_PATH_5G}/RF/General_SiSo_different_Capture_type_select_RF_scan_test_with_full_mode_in_online_mode.robot
Resource    ${BASIC_PATH_5G}/Test_Model/General_SiSo_DL_Test_Model_Verification.robot
Resource    ./Resource/CB009936_common_keyword.robot
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB008941_SG4/Resources/CB008941_common_keyword.robot

Force Tags    RF50    HAZ4_T04

*** Test Cases ***
[1]CB009936-SR-B_CB012091_02_Returning_from_Extreme_Deep_Sleep_Mode_to_normal_operation
    [Tags]    1S-2CC-CB012091
    ${fault_list}    Create List    49
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    Returning From Extreme DeepSleep Mode To Normal Via RU Operation    with_call=${True}    with_peak=${True}
    ...    call_duration=${300}    ue_num_each_call=${2}
    [Teardown]    SISO Coam Test Teardown    perform_case_scf=${True}

[1]CB009936-SR-B_CB012091_04_SWMGMNT_interworking_with_CB012091
    [Tags]    1S-2CC-CB012091    HAZ4_T04
    [Setup]    SISO Coam Test Setup    fail_with_alarms=${True}   enable_err_wrn=${True}    is_ru_log_collecting_enable=${True}
    ${fault_list}    Create List    49
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    Rollback Software During RU Entering Extreme DeepSleep Mode
    [Teardown]    SISO Coam Test Teardown    perform_case_scf=${True}

[1]CB009936-SR-A_CB008782_02_General_SiSo_RF_Fault_Signature_FID_4590
    [Tags]    1S-2CC-72E
    General_SiSo_RF_Fault_Signature_FID_4590

[1]CB009936-SR-A_CB011148_01_different_Capture_type_select_RF_scan_test_with_full_Mode_in_online_mode
    [Tags]    1S-2CC-72E
    General_SiSo_different_Capture_type_select_RF_scan_test_with_full_mode_in_online_mode

[1]CB009936-SR-B_CB008941_01_L3call_with_UL_PRB_muting_active
    [Tags]    1S-2CC-72E
    L3call_with_UL_PRB_muting_active_FDBF_72E_RF7    with_call=${True}    with_peak=${False}
    ...    call_duration=${300}    ue_num_each_call=${2}

[1]CB009936-SR-F_CB009794_01_RTWP_counters_reflects_high_interference_during_a_specific_period
    [Tags]    2S-2CC-16D-2U-72E
    RTWP_counters_reflects_high_interference_during_a_specific_period    with_call=${True}    call_duration=${600}    ue_num_each_call=${1}
    [Teardown]  SISO Coam Test Teardown    perform_case_scf=${True}

[1]CB009936-SR-I_01_General_SiSo_DL_Test_Model_Verification
    [Tags]    1S-2CC-TDS
    ${test_model_list}    create list    NR-FR1-TM1.1    NR-FR1-TM1.2    NR-FR1-TM2    NR-FR1-TM2a
    ...    NR-FR1-TM3.1    NR-FR1-TM3.1a    NR-FR1-TM3.2    NR-FR1-TM3.3
    General_SiSo_DL_Test_Model_Verification    test_model_list=${test_model_list}
    [Teardown]  SISO Coam Test Teardown    perform_case_scf=${True}

[1]CB009936-SR-B_CB008693_02_RF_sharing_configuration_to_validate_the_backward_compatibility_72a
    [Tags]    1S-2CC-72E
    [Setup]   RF sharing Test Setup
    [Teardown]   RF sharing Test Teardown
    RF_Sharing_Configuration_to_Validate_the_Backward_Compatibility_72a
