*** Settings ***
Force Tags        RAN_5G  RAN_5G_TDD   STATE_SW_UPLOADED  SBTS00  SBTS22R4
...    CLOUD_5G_CLASSICAL_FULLRACK_QC_SA_ASIBL_ABIOB1_AWHQN-ASIBR_ABINB4_AWHQX    PY36

Documentation
...    author: Jing.Qu@nokia-sbell.com
...    this case will verify keyword for TA of CNI81865 which for AWHQN extend frequency band from 3700~3800 to 3700~3980
...    case1: General_SiSo_RF_module_power_reset
...    case2: General_SiSo_Configuration_BPF_and_TargetBD_support_for_RF_module
...    case3: General_SiSo_Fault_1900_EFaultId_FrConfiguringFailed_PMAX
...    case4: General_SiSo_Cell_lock_and_unlock
...    case5: General_SiSo_NR-ARFCN_check


Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_RF_module_power_reset.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_Configuration_BPF_and_TargetBD_support_for_RF_module.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_Fault_1900_EFaultId_FrConfiguringFailed_PMAX.robot
Resource    ${BASIC_PATH_5G}/Cell/General_SiSo_Cell_lock_and_unlock.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_NR-ARFCN_check.robot


Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           SISO Coam Test Setup
Test Teardown        SISO Coam Test Teardown


*** Variables ***
${testline_name}    7_5_UTE5G402T881
@{ALL_TEST_STATUS}

*** Test Cases ***
case #1
    General_SiSo_RF_module_power_reset

[1]CNI-81865-A_General_SiSo_Configuration_BPF_and_TargetBD_support_for_RF_module
    [Tags]    CRT_TRUNK    CRT_23R2
    Append To List   ${ALL_TEST_STATUS}   ${PREV TEST STATUS}
    General_SiSo_Configuration_BPF_and_TargetBD_support_for_RF_module

case #3
    Append To List   ${ALL_TEST_STATUS}   ${PREV TEST STATUS}
    General_SiSo_Fault_1900_EFaultId_FrConfiguringFailed_PMAX

case #4
    Append To List   ${ALL_TEST_STATUS}   ${PREV TEST STATUS}
    General_SiSo_Cell_lock_and_unlock

[1]CNI-81865-A_General_SiSo_NR-ARFCN_check
    [Tags]    CRT_TRUNK    CRT_23R2
    Append To List   ${ALL_TEST_STATUS}   ${PREV TEST STATUS}
    General_SiSo_NR-ARFCN_check

CNI-81865-A_General_SiSo_E2E_system_setup_with_data_transfer_conducted_Middle_frequency
    [Documentation]   This Case used to fill result on QC
    Append To List   ${ALL_TEST_STATUS}   ${PREV TEST STATUS}
    List Should Not Contain Value    ${ALL_TEST_STATUS}    FAIL

*** Keywords ***
