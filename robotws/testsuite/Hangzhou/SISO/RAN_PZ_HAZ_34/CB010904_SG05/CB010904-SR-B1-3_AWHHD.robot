*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Timeout         120 min

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB008952_SG05/resource/resource.robot



Documentation
...    Author: Liu Yue
...    Contact: yue.2.liu@nokia-sbell.com
...    squad group:SG_05
...    Feature CB010904 in 5G24R3 program

Force Tags    5G_RAN_TDD
*** Variables ***

*** Test Cases ***
[1]CB010904-SR-B1-1_AWHHD_SplitMode&ConcurrentMode_2CC_2DL_256QAM_2UL_256QAM_70MHz_40MHz_with_Peak_CB008953_7
    [Tags]    1S-2CC-2DL2UL_70MHz_40MHz
    [Setup]    SISO Coam Test Setup
    sleep    2min
    ${cell_list}    create list    ${1}
    Get UE From Init File and Make call    cell_list=${cell_list}    with_peak=${True}    4G_check=${False}
    [Teardown]    SISO Coam Test Teardown
