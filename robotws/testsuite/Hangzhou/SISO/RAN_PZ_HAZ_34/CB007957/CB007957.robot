*** Settings ***
Suite Setup          SBTS Suite Setup
Suite Teardown       SBTS Suite Teardown
Test Setup           SBTS Test Setup
Test Teardown        SBTS Test Teardown
Test Timeout         12h

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_COMMON}/SBTS_Setup_And_Teardown.robot
Resource    ${BASIC_PATH_LTE}/General_Power_consumption_checking_with_activate_micro-DTx_function_under_idle_load.robot
Resource    ${BASIC_PATH_LTE}/General_Micro-DTx_activate_with_traffic_concentration_and_CRG_activate_together.robot

Documentation
...    Author:zhihao shi
...    contact:zhihao.shi@nokia-sbell.com
...    squad group:SG_04
...    Feature CB007957 in 23R3 program

Force Tags            5G_RAN    5G_RAN_TDD    RAN_5G_TDD    RAN_5G    STATE_SW_UPLOADED   CLOUD_5G_CLASSICAL_ASOE_AZNA_AZHA
...    PY36

*** Variables ***
${cell_type}   lte

*** Test Cases ***
#TL604(LTE)  -- ASOE+AZNA+AZHA+1*SUMSANG -- 2S-2CC-2D-2U + 5MHz
[1]CB007957-A_SISO_1_Power_consumption_checking_with_activate_micro-DTx_function_under_idle_load
    [Tags]    2S-2CC-2D-2U    CRT_TRUNK    RF50
    General_Power_consumption_checking_with_activate_micro-DTx_function_under_idle_load

[1]CB007957-A_RRM_02_Micro-DTx_activate_with_traffic_concentration_and_CRG_activate_together
    [Tags]    2S-2CC-2D-2U    CRT_TRUNK    RF50
    General_Micro-DTx_activate_with_traffic_concentration_and_CRG_activate_together

*** Keywords ***
