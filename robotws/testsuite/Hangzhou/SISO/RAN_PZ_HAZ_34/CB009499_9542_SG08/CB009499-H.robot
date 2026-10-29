*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           SISO Coam Test Setup
Test Teardown        SISO Coam Test Teardown

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    Resources/CB009499_Common_Keywords.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common_keywords.robot
Variables    TestData/CB009499_variables.py

Documentation
...    Author:renzhenzhen
...    contact:zhenzhen.ren@nokia-sbell.com
...    squad group:SG_08
...    Feature CB009499

Force Tags            RAN_5G_TDD    5G_RAN_TDD    RAN_5G    5G_RAN    CRT_UTE    STATE_SW_UPLOADED    SBTS00    SBTS24R1
...    PY36
...    CLOUD_5G_CLASSICAL_ANDROID_ASOF_4xAWHQE

*** Variables ***


*** Test Cases ***
[1][2.0] General_SiSo_E2E_system_setup_with_data_transfer_conducted
    [Tags]    CRT_TRUNK    CRT_24R1
    L3 call peak for CB009499_H supercell

[1][1.0] General_SiSo_E2E_system_setup_with_data_transfer
    [Tags]    CRT_TRUNK    CRT_24R2
    L3 call peak for CB009499_H supercell

[1][3.0] General_SiSo_Cell_block_and_unblock
    [Tags]    CRT_TRUNK    CRT_24R1
    General_SiSo_Cell_block_and_unblock_for_CB009499_H

[1][2.0] Manual_SiSo_SM_BTS_Site_Reset
    [Tags]    CRT_TRUNK    CRT_24R1
    Manual_SiSo_SM_BTS_Site_Reset_for_CB009499_H

[1][1.0] General_SiSo_RU_lock_unlock
    [Tags]    CRT_TRUNK    CRT_24R1
    General_SiSo_RU_lock_unlock_for_CB009499_H
