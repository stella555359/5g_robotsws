*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           SISO Coam Test Setup    fail_with_alarms=${True}
Test Teardown        SISO Coam Test Teardown
Test Timeout         24h

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    ${BASIC_PATH_5G}/Troubleshooting/General_SiSo_Running_the_troubleshooting_scripts.robot

Documentation
...    Author:Dai Xiangying
...    contact:zhihao.shi@nokia-sbell.com
...    squad group:SG_04
...    Feature CB007042 in SBTS22R4 program

Force Tags            5G_RAN    5G_RAN_TDD
...   PY36

*** Variables ***

*** Test Cases ***
# TL583
[1]CB007042_B-MVP_01_Running_the_troubleshooting_scripts
    [Tags]    CRT_TRUNK
    General_SiSo_Running_the_troubleshooting_scripts    iq_data_file_num=${4}

*** Keywords ***
