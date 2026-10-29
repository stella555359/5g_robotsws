*** Settings ***
Suite Setup          SBTS Suite Setup
Suite Teardown       SBTS Suite Teardown
Test Setup           SBTS Test Setup
Test Teardown        SBTS Test Teardown
Test Timeout         12h

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_COMMON}/SBTS_Setup_And_Teardown.robot
Resource    ${BASIC_PATH_LTE}/General_SiSo_CPRI_feature_fault_trigger_LTE_only.robot

Documentation
...    Author:zhihao shi
...    contact:zhihao.shi@nokia-sbell.com
...    squad group:SG_04
...    Feature CB008004 in SBTS00 program

Force Tags            5G_RAN    5G_RAN_TDD    RAN_5G_TDD    RAN_5G    STATE_SW_UPLOADED   CLOUD_5G_CLASSICAL_ASOE_AZNA_AZHA
...    PY36

*** Variables ***
${cell_type}   lte
${if_commissioning}   False

*** Test Cases ***
# TL604(NSA)  --  SBTS00
[1]CB008004-SR-CC_11_CPRI_feature_fault_trigger_LTE_only
    [Tags]    2S-2CC-2D-2U
    General_SiSo_CPRI_feature_fault_trigger_LTE_only

*** Keywords ***
