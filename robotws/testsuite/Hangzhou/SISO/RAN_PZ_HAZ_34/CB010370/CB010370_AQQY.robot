*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           SISO Coam Test Setup    fail_with_alarms=${True}    is_ru_log_collecting_enable=${True}
Test Teardown        SISO Coam Test Teardown
Test Timeout         4h

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_RF_module_reset_from_GUI.robot
Resource    ${BASIC_PATH_5G}/Cell/E2E_SiSo_Cell_block_and_unblock_gNB.robot
Resource    ${BASIC_PATH_5G}/BTS/General_SiSo_RAT_Block_Unblock.robot
Resource    Resource/CB010370_common_keyword.robot

Documentation
...    Author:tingting zhong
...    contact:tingting.zhong@nokia-sbell.com
...    squad group:SG_04
...    Feature Owner: Shi Gaofan,Xu mingming
...    Feature CB010370  AQQY&AQQA in trunk program

Force Tags            5G_RAN    5G_RAN_TDD    RAN_5G_TDD    RAN_5G    STATE_SW_UPLOADED    CLOUD_5G_CLASSICAL_SA_ASIBL_ABIOB1_AVQC
...   PY310    HAZ4_T04


*** Test Cases ***
[1]CB010370_SR_E_03_General_SiSo_RAT_Block_Unblock_with_L3Call
    [Documentation]
    ...    History of changes
    ...    ******************
    ...    - 26.08.2024 - - Modified by Zeng Qunfang: Add MAX_LOOP parameter to control the number of iterations.LEOPARD-2152
    ...    *******************
    [Tags]    3S-1CC-16D-8U-2CC-8D-8U    RF50
    ${fault_list}    Create List    4614
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    General_SiSo_RAT_Block_Unblock    with_call=${True}    with_peak=${True}    duration=${300}    ue_num_each_call=2    MAX_LOOP=${3}

[1]CB010370_SR_F_02_General_SiSo_Cell_block_and_unblock
    [Tags]    3S-1CC-NR-2CC-LTE    RF50
    ${fault_list}    Create List    49
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    E2E_SiSo_Cell_block_and_unblock_gNB    with_call=${True}    with_peak=${True}    call_duration=${300}
    [Teardown]    SISO Coam Test Teardown    perform_case_scf=${True}

[1]CB010370_SR_H_02_General_SiSo_RU_module_reset_from_GUI
    [Tags]  3S-2CC-16D-8U    RF50
    General_SiSo_RF_module_reset_from_GUI    with_call=${True}    with_peak=${True}    duration=${300}    ue_num_each_call=2

[1]CB010370_SR_H_01_General_SiSo_Online_Data_Configuration
    [Tags]  3S-2CC-16D-8U    RF50
    General_SiSo_Online_Modify_Channel_Bandwidth    with_call=${True}    ue_num_each_call=2

[1]CB010370_SR_L_01_General_SiSo_Online_Cell_Addition_Deletion
    [Tags]  3S-2CC-16D-8U    RF50    HAZ4_T04
    [Setup]    SISO Coam Test Setup    fail_with_alarms=${True}   enable_err_wrn=${True}
    General_SiSo_Online_Cell_addition_deletion    with_call=${True}
    [Teardown]    SISO Coam Test Teardown    perform_case_scf=${True}
