*** Settings ***
Documentation    Author: Zhang Andy
...    Squad group: VRF_HAZ4_T04
...    Contact: andy.zhang@nokia-sbell.com
...    Feature CB013355 in trunk program

Resource    Resource/CB013355_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/5G/5G_Setup_And_Teardown.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_Common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot

Suite Setup       SISO Coam Suite Setup    # Temporarily disabled for debugging
Suite Teardown    SISO Coam Suite Teardown
Test Setup        SISO Coam Test Setup    fail_with_alarms=${True}
Test Teardown     SISO Coam Test Teardown
Test Timeout      8h

*** Variables ***
${if_commissioning}    False

*** Test Cases ***
[1]CB013355-SR-B_07_DU_Uplane_counter_Combined_Verification
    [Documentation]    Test DU Uplane counter combined verification
    [Tags]    CB013355    SR-B_07    DU_Uplane    counter    verification
    DU_Uplane_counter_Combined_Verification
