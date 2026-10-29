*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           SISO Coam Test Setup
Test Teardown        SISO Coam Test Teardown
Test Timeout         150 min

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_RF_module_reset_from_GUI.robot

Documentation
...    Author: shifu.lan@nokia-sbell.com
...    Group: VRF_HAZ4_T04
...    Feature Owner: Zhendong Chen
...    Feature CB012502  AQQY in trunk program

Force Tags            5G_RAN    5G_RAN_TDD    RAN_5G_TDD    RAN_5G    STATE_SW_UPLOADED    CLOUD_5G_CLASSICAL_SA_ASIBL_ABIOB1_AVQC
...   PY310    HAZ4_T04


*** Test Cases ***
[1]CB012502_SR_A_05_General_SiSo_RU_module_reset_from_GUI
    [Tags]  1S-4CC-8D-4U_12502    RF50
    General_SiSo_RF_module_reset_from_GUI    with_call=${True}    ue_num_each_call=2
