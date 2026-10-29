*** Settings ***
Suite Setup          SBTS Suite Setup
Suite Teardown       SBTS Suite Teardown
Test Setup           SBTS Test Setup    fail_with_alarms=${True}
Test Teardown        SBTS Test Teardown
Test Timeout         12h

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_COMMON}/SBTS_Setup_And_Teardown.robot
Resource    ./Resource/CB009217_common_keywords.robot

Documentation
...    Author:tingting zhong
...    contact:tingting.zhong@nokia-sbell.com
...    squad group:SG_04
...    Feature CB009127 in trunk program

Force Tags            5G_RAN    5G_RAN_TDD    RAN_5G_TDD    RAN_5G    STATE_SW_UPLOADED
...   PY36

*** Variables ***
${if_commissioning}   False

*** Test Cases ***
# TL593 1S-1CC-8D-4U
[1]CB009217_SR_D_B3_SISO_AQQY_03_Manual_SiSo_SM_RF_Module_lock_unlock
    Manual SiSo SM RF Module lock unlock

[1]CB009217_SR_J_B2_SISO_AQQY_01_General_SiSo_RU_module_reset_from_GUI
    [Tags]    RF50
    General SiSo RF module reset from GUI

*** Keywords ***

