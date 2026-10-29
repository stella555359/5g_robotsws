*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           SISO Coam Test Setup    fail_with_alarms=${True}
Test Teardown        SISO Coam Test Teardown
Test Timeout         24h

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_RF_module_reset_from_GUI.robot
Resource    ${BASIC_PATH_5G}/Cell/E2E_SiSo_Cell_block_and_unblock_gNB.robot
Resource    ${BASIC_PATH_5G}/BTS/General_SiSo_Peak_with_Given_Information.robot

Documentation
...    Author:zhihao shi
...    contact:zhihao.shi@nokia-sbell.com
...    squad group:SG_04
...    Feature CB008194 in trunk program

Force Tags            5G_RAN    5G_RAN_TDD    RAN_5G_TDD    RAN_5G    STATE_SW_UPLOADED   CLOUD_5G_CLASSICAL_ASIB_ABIO_AQQC_ENB
...    PY36

*** Variables ***

*** Test Cases ***
# TL582 default scf: 1S-2CC-8D-4U 100M
#NR 3CC (100M+50M+50M )
[1]CB008546_B_05_General_SiSo_RU_module_reset_from_GUI
    [Tags]    1S-3CC-8D-4U    SBTS00    CRT_UTE
    General_SiSo_RF_module_reset_from_GUI    with_call=${True}

[1]CB008546_B_14_General_SiSo_E2E_system_L3Call_setup_with_data_transfer_conducted_when_mixed-BW_100MHz_50MHz_20MHz
    [Tags]    1S-3CC-8D-4U    SBTS00    CRT_UTE
    General_SiSo_Peak_with_Given_Information    use_case_variable=${True}    suite_name=${SUITE NAME}    test_name=${TEST NAME}

#NR 4CC  (50M+40M+40M+30M)
[1]CB008546_F_B1_02_General_SiSo_Cell_block_and_unblock
    [Tags]    1S-4CC-8D-4U    SBTS00    CRT_UTE
    ${fault_list}    Create List    49
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    E2E_SiSo_Cell_block_and_unblock_gNB

[1]CB008546_F_B1_13_General_SiSo_E2E_system_L3Call_setup_with_data_transfer_conducted_when_mixed-BW_50MHz_30MHz_40MHz_20MHz
    [Tags]    1S-4CC-8D-4U    SBTS00    CRT_UTE
    General_SiSo_Peak_with_Given_Information    use_case_variable=${True}    suite_name=${SUITE NAME}    test_name=${TEST NAME}

*** Keywords ***
