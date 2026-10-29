*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           #SISO Coam Test Setup
Test Teardown        #SISO Coam Test Teardown
Test Timeout         60 min

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    ${BASIC_PATH_5G}/E2E_SiSo_RU_lock_and_unlock_gNB.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_RF_module_reset_from_GUI.robot
Resource    ${BASIC_PATH_5G}/Cell/General_SiSo_Cell_block_and_unblock.robot
Resource    ${BASIC_PATH_5G}/BTS/General_SiSo_Peak_with_Given_Information.robot

#Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/get_case_variables.py
#Variables   TestData/case_variables.yml

Documentation
...    Author: Liu Yue
...    Contact: yue.2.liu@nokia-sbell.com
...    squad group:SG_05
...    Feature CB007287 AQNA in SBTS22R4 program

Force Tags     RAN_5G     RAN_5G_TDD    STATE_SW_UPLOADED    SBTS00    PY36    master_classicalbts_all

*** Variables ***

*** Test Cases ***
## 50M+50M; l3call after lock/unlock if possible ##
#[1]CB007287_5G_AA_AQNA_General_SiSo_RU_lock_unlock
#    [Tags]    1S-2CC-4D4U_40-20M_7378-B3    CRT_22R4   CRT_TRUNK
#    [Setup]    SISO Coam Test Setup
#    E2E_SiSo_RU_lock_and_unlock_gNB    with_call=${True}  with_peak=${False}  call_duration=${180}
#    [Teardown]    SISO Coam Test Teardown

## 20M; l3call after radio reset if possible ##
#[1]CB007287_5G_AA_AQNA_General_SiSo_RU_module_reset_from_GUI
#    [Tags]    CRT_22R4   CRT_TRUNK
#    [Setup]    SISO Coam Test Setup
#    General_SiSo_RF_module_reset_from_GUI    with_call=${True}  with_peak=${False}  call_duration=${180}
#    [Teardown]    SISO Coam Test Teardown

## 100M; block/unblock no l3call (xiaomi 12 Pro not support) ##
#[1]CB007287_5G_AA_AQNA_General_SiSo_Cell_block_and_unblock
#    [Tags]    1S-2CC-8D4U_100-100M_7378-A2    CRT_22R4   CRT_TRUNK
#    [Setup]    SISO Coam Test Setup
#    General_SiSo_Cell_block_and_unblock    with_call=${False}
#    [Teardown]    SISO Coam Test Teardown

## 80M; peak ##
[1]CB007287_5G_AA_AQNA_eCPRI_peak_Tput_with_chbw_80Mhz
    [Tags]    CRT_22R4   CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    General_SiSo_Peak_with_Given_Information    use_case_variable=${True}
    ...                                         suite_name=${SUITE NAME}
    ...                                         test_name=${TEST NAME}
    [Teardown]    SISO Coam Test Teardown

## 60M; peak ##
#[1]CB007287_5G_AA_AQNA_eCPRI_peak_Tput_with_chbw_60Mhz
#    [Tags]    1S-2CC-4D4U_40-20M_7378-B3    CRT_22R4   CRT_TRUNK
#    [Setup]    SISO Coam Test Setup
#    General_SiSo_Peak_with_Given_Information    use_case_variable=${True}
#    ...                                         suite_name=${SUITE NAME}
#    ...                                         test_name=${TEST NAME}
#    [Teardown]    SISO Coam Test Teardown

*** Keywords ***
