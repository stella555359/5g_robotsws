*** Settings ***
Suite Setup       SISO Coam Suite Setup
Suite Teardown    SISO Coam Suite Teardown
#Test Setup
#Test Teardown
Test Timeout      1 hours

Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource     ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource     ${BASIC_PATH_5G}/General_SiSo_RF_module_reset_from_GUI.robot
Resource     ${BASIC_PATH_5G}/BTS/Manual_SiSo_SM_NR_RAT_reset.robot
Resource     ${BASIC_PATH_5G}/BTS/General_SiSo_RAT_Block_Unblock.robot
Resource     ${BASIC_PATH_5G}/E2E_SiSo_RAT_block_unblock_via_WEBUI.robot

Documentation
...    Author: Zhang Xuewen
...    Contact: xuewen.zhang@nokia-sbell.com
...    Squad group:SG_05

Force Tags    RAN_5G    RAN_5G_TDD    SBTS00    PY310

*** Test Cases ***
[1]CB012685-SR-C_05_General_SiSo_RAT_Reset_with_Robustness
    [Tags]    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    ${fault_list}    Create List    16    7311
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    Manual_SiSo_SM_NR_RAT_reset    is_bb_reset_expected=${false}    with_call=${false}    loop_times=${2}
    [Teardown]    Run Keywords    add fault to allowed history fault list    faultId=${16}
    ...    AND    add fault to allowed history fault list    faultId=${7311}
    ...    AND    SISO Coam Test Teardown

[1]CB012685-SR-C_07_General_SiSo_RU_module_reset_from_GUI
    [Tags]    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    General_SiSo_RF_module_reset_from_GUI    with_call=${false}
    [Teardown]    SISO Coam Test Teardown

[1]CB012685-SR-C_10_General_SiSo_RAT_Block_Unblock_with_L3call
    [Tags]    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    General_SiSo_RAT_Block_Unblock_with_L3call    with_call=${false}
    [Teardown]    SISO Coam Test Teardown