*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           SISO Coam Test Setup    fail_with_alarms=${True}
Test Teardown        SISO Coam Test Teardown
Test Timeout         24h

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
# Resource    ${BASIC_PATH_5G}/General_microDTXAdvanced_when_Cell_locked.robot
Resource    ${BASIC_PATH_5G}/General_Enabling_microDTXAdvanced_on_Galvatron_cMAAr62_32T32R_Radio.robot
# Resource    ${BASIC_PATH_5G}/General_microDTXAdvanced_when_medium_load_traffic.robot
# Resource    ${BASIC_PATH_5G}/General_microDTXAdvanced_when_diff_chBW.robot

Documentation
...    Author:zhihao shi
...    contact:zhihao.shi@nokia-sbell.com
...    squad group:SG_04
...    Feature Owner: Zhang andy
...    Feature CB008655 in SBTS00 program

Force Tags            5G_RAN    5G_RAN_TDD    RAN_5G_TDD    RAN_5G    STATE_SW_UPLOADED   CLOUD_5G_CLASSICAL_SA_ASILL_ABIOB1_AZNA
...    PY310

*** Test Cases ***
[1]CB008655-5G-A_01_02_Enabling_microDTXAdvanced_on_Galvatron_cMAAr6.2_32T32R_Radio
    [Tags]    CRT_TRUNK    CRT_22R4    RF50    1S-1CC-8D-4U_CHT
    General_Enabling_microDTXAdvanced_on_Galvatron_cMAAr62_32T32R_Radio

# [1]CB008655-5G-A_04_02_microDTXAdvanced_when_medium_load_traffic
#     [Tags]    CRT_TRUNK    CRT_22R4
#     General_microDTXAdvanced_when_medium_load_traffic
#
# [1]CB008655-5G-A_02_07_microDTXAdvanced_when_Cell_locked
#    General_microDTXAdvanced_when_Cell_locked
#
# [1]CB008655-5G-A_02_03_microDTXAdvanced_when_diff_chBW
#    General_microDTXAdvanced_when_diff_chBW