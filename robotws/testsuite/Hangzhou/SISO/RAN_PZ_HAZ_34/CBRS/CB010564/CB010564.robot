*** Settings ***
Suite Setup          CBRS Suite Setup
Suite Teardown       CBRS Suite Teardown
Test Setup           CBRS Test Setup    actCbrsEnhMeas=${True}
Test Teardown        CBRS Test Teardown    actCbrsEnhMeas=${True}

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    resources/CB010564_common_keywords.robot

Documentation
...    Author:wangqingqing
...    contact:qingqing.wang@nokia-sbell.com
...    squad group:SG_08
...    Feature CB010564

Force Tags    SBTS00
...   PY36

*** Variables ***

*** Test Cases ***
[1]CB010564-E_16_General_SiSo_E2E_system_setup_with_data_transfer_conducted_(max_MCS_L3_call)_1CC_20MHz
    [Tags]    CRT_TRUNK
    CB010564-E_16_General_SiSo_E2E_system_setup_with_data_transfer_conducted_(max_MCS_L3_call)_1CC_20MHz

[1]CB010564-E_20_General_SiSo_E2E_system_setup_with_data_transfer_conducted_1CC_20MHz_when_one_RU_down
    [Tags]    CRT_TRUNK
    CB010564-E_20_General_SiSo_E2E_system_setup_with_data_transfer_conducted_1CC_20MHz_when_one_RU_down

[1]CB010564-E_11_Activation_of_NR_CBRS
    [Tags]    CRT_TRUNK
    start SAS server
    Wait until keyword succeeds    8min    30s    verify all cells should be onair

[1]CB010564-E_19_Verify_pre-TX_measurement_after_RU_reset
    [Tags]    CRT_TRUNK
    CB010564-E_19_Verify_pre-TX_measurement_after_RU_reset

[1]CB010564-E_17_Verify_cell_will_not_get_a_grant_after_one_of_the_RU_down
    [Tags]    CRT_TRUNK
    CB010564-E_17_Verify_cell_will_not_get_a_grant_after_one_of_the_RU_down

[1]CB010564-E_14_Verify_cell_will_not_get_second_grant_when_one_RU_down_and_heartbeat_with_Grant_Suspended
    [Tags]    CRT_TRUNK
    CB010564-E_14_Verify_cell_will_not_get_second_grant_when_one_RU_down_and_heartbeat_with_Grant_Suspended

[1]CB010564-E_12_Recommission_from_M_type_to_Ne_type
    [Tags]    CRT_TRUNK
    CB010564-E_12_Recommission_from_M_type_to_Ne_type

[1]CB010564-E_9_NR_RAT_reset_when_all_cells_are_onair_Concurrent_Mode
    [Tags]    CRT_TRUNK
    CB010564-E_9_NR_RAT_reset_when_all_cells_are_onair_Concurrent_Mode



10564_BB_reset
    10564_BB_reset

10564_RU_reset
    10564_RU_reset

*** Keywords ***
