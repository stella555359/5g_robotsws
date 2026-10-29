*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           SISO Coam Test Setup    fail_with_alarms=${True}
Test Teardown        SISO Coam Test Teardown
Test Timeout         24h

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_RU_Minimum_information_in_Black_Box.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_RU_installation_time_optical_signal_level_in_BBOX5.robot

Documentation
...    Author:zhihao shi
...    contact:zhihao.shi@nokia-sbell.com
...    squad group:SG_04
...    Feature CB007833 in SBTS22R2 program

Force Tags            5G_RAN    5G_RAN_TDD
...    PY36

*** Variables ***

*** Test Cases ***
# add 05 check points to 07
[1]CB007833-5G-A_07_RU_Minimum_information_in_Black_Box
    [Tags]    CRT_22R4    CRT_22R3    CRT_TRUNK    RF50
    General_SiSo_RU_Minimum_information_in_Black_Box

# add 08 and 09 check points to 10
[1]CB007833-5G-A_10_RU_installation_time_optical_signal_level_in_BBOX5
    [Tags]    CRT_22R4    CRT_22R3    CRT_TRUNK
    General_SiSo_RU_installation_time_optical_signal_level_in_BBOX5

*** Keywords ***
