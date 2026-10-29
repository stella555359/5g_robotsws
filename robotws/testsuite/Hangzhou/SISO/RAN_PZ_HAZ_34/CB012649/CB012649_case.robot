*** Settings ***
Suite Setup    Run Keywords    Run Keyword And Ignore Error    Check And Clear TestPC Space    AND
...                            12649 Common Suite SetUp
Suite Teardown    12649 Common Suite TearDown
Test Setup    12649 Common Case SetUp
Test Teardown     12649 Common Case TearDown

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    Resources/CB012649_common.robot

Documentation
...    Author:Ye Tianyi
...    contact:tianyi.ye@nokia-sbell.com
...    squad group:SG_06
...    Feature CB012649

*** Test Cases ***
[1][1.0] E2E_TL_Activation_Reset_with_OAM_KPI
    [Tags]    CRT_25R3    CRT_Trunk
    [1.0] E2E_TL_Activation_Reset_with_OAM_KPI

*** Keywords ***
12649 Common Suite SetUp
    ${gnb_index}    Set Variable    ${1}
    Set Suite Variable    ${gnb_index}
    ${coam_connection}    Set Variable    GNB_OAM_${gnb_index}
    Set Suite Variable    ${coam_connection}
    SISO Coam Suite Setup    gnb_index=${gnb_index}

12649 Common Suite TearDown
    SISO Coam Suite Teardown    gnb_index=${gnb_index}

12649 Common Case TearDown
    SISO Coam Test Teardown    gnb_index=${gnb_index}

12649 Common Case SetUp
    SISO Coam Test Setup    gnb_index=${gnb_index}
