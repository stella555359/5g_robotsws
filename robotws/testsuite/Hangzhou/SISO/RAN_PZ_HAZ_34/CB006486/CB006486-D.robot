*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           SISO Coam Test Setup
Test Teardown        SISO Coam Test Teardown
Test Timeout         100 min

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_RU_lock_unlock.robot
Variables    TestData/variables.py

Documentation
...    Author:shasha.liu
...    contact:shasha.liu@nokia-sbell.com
...    squad group:SG_05
...    Feature CB006486-D in 5G21A program
...    Configuration:A5G-TD-1S-(1CC+1CC)-8DL-4UL-FR1-eCPRI-CB006486-9

Force Tags      5G_RAN_TDD
...    PY36

*** Variables ***

*** Test Cases ***
[1]CB006486-D-5GC006486-9_5_General_SiSo_RU_lock_unlock_with_BF
    [Tags]    1S-2CC-8D4U_100-100M_C4_Split_6486-9   CIT_TRUNK    CRT_22R1   CRT_22R2   CRT_22R3   CIT_22R4
    General_SiSo_RU_lock_unlock    with_call=${False}

##80+80; 100+100
#[1]CB006486-D-5GC006486-9_8_General_SiSo_E2E_system_setup_with_data_transfer_conducted_with_different_BW
#    [Tags]    1S-2CC-8D4U_80-80M_C4_Split
#    General_SiSo_E2E_system_setup_with_data_transfer    band=80    cell_id=1

*** Keywords ***
