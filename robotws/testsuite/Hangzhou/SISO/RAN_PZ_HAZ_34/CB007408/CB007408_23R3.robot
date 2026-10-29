*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           SISO Coam Test Setup
Test Teardown        SISO Coam Test Teardown

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    ${BASIC_PATH_5G}/BTS/General_SiSo_Peak_with_Given_Information.robot
Resource    ./Resources/CB007408_keywords.robot
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB006502_CB007833/Resources/CB006502_Keywords.robot
Variables    ./TestData/variables_7408.py


Documentation
...    Author: Melinda
...    Contact: meinda.gao@nokia-sbell.com
...    squad group:SG_08
...    Feature CB007408 AENB eCPRI

Force Tags    CRT_23R3
...    PY36

*** Variables ***
@{band1}    40M
@{band2}    60M
@{band3}    80M
*** Test Cases ***
[1]General_SiSo_Auto_E2E_system_setup_with_data_transfer_conducted_80M
    [Tags]    CRT_TRUNK    CRT_22R2
    7408_dataTransfer_80M

[1][2.0] Manual_SiSo_SM_RF_Module_lock_unlock
    CB009359_Manual_SiSo_SM_RF_Module_lock_unlock

#[1][2.1] General_SiSo_Cell_block_and_unblock
#    CB009359-SR-S_General_SiSo_Cell_block_and_unblock

[1][2.0] Manual_SiSo_SM_NR_RAT_reset
    CB009359-SR-T_Manual_SiSo_SM_NR RAT reset

*** Keywords ***
