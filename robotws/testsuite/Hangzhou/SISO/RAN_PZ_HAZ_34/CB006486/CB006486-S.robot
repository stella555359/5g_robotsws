*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           SISO Coam Test Setup
Test Teardown        SISO Coam Test Teardown
Test Timeout         100 min

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    ${BASIC_PATH_5G}/Cell/General_SiSo_Cell_lock_and_unlock.robot
#Resource    ${BASIC_PATH_5G}/General_SiSo_RU_lock_unlock.robot
Variables    ./TestData/variables.py

Documentation
...    Author:shasha.liu
...    contact:shasha.liu@nokia-sbell.com
...    squad group:SG_05
...    Feature CB006486-S in 5G21A program
...    Configuration:A5G-TD-1S-2CC-8DL-4UL-FR1-eCPRI-5GC002035-5
...    (i.e. A5G-TD-1S-2CC-8DL-4UL-FR1-eCPRI-CB006486-17)

Force Tags       5G_RAN_TDD
...    PY36

*** Variables ***

*** Test Cases ***
[1][1.0] 5GC002035-C-5GC002035-5_007_AEQE_General_SiSo_Cell_lock_and_unlock_with_BF
    [Tags]    1S-2CC-8D4U_40-50M_C4_CB007085_6486-17    CIT_TRUNK   CRT_22R1   CRT_22R2   CRT_22R3   CIT_22R4
    General_SiSo_Cell_lock_and_unlock    with_call=${False}

#[1][1.0] 5GC002035-C-5GC002035-5_009_AEQE_General_SiSo_RU_lock_unlock_with_BF
#    [Tags]    1S-2CC-8D4U_40-50M_C4_CB007085_6486-17    CRT_21B
#    General_SiSo_RU_lock_unlock    with_call=${False}

## 2CC full panel: 20+20; 40+40; 50+50 for CB006486; 40+50 for CB007085
#[1][1.0] 5GC002035-C-5GC002035-5_015_AEQE_General_SiSo_E2E_system_setup_with_data_transfer_conducted_with_different_BW
#    [Tags]    1S-2CC-8D4U_40-50M_C4
#    General_SiSo_E2E_system_setup_with_data_transfer    band=20    cell_id=1

*** Keywords ***
