*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           SISO Coam Test Setup    fail_with_alarms=${True}    is_ru_log_collecting_enable=${True}
Test Teardown        SISO Coam Test Teardown
Test Timeout         100 min

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    Resource/CB012469_common_keyword.robot

Documentation
...    Author:kaihui fan
...    contact:kaihui.fan@nokia-sbell.com
...    squad group:SG_04
...    Feature Owner: Zhang Andy
...    Feature CB012469  AQQY in trunk program

Force Tags            5G_RAN    5G_RAN_TDD    RAN_5G_TDD    RAN_5G
...   PY310    HAZ4_T04

*** Test Cases ***
[1]CB012469_Peak_Throughput_Check_With_Static_DVM_2.5W_AQQY
    [Tags]    RF50
    General_SiSo_Peak_Throughput_Check_With_Static_DVM_2.5W_AQQY   ru_index=${1}

