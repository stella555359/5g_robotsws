*** Settings ***
Documentation
...    Author: Lan Shifu
...    Squad group: VRF_HAZ4_T04
...    Contact: shifu.lan@nokia-sbell.com
...    Feature CB012449 in trunk program

Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           SISO Coam Test Setup    fail_with_alarms=${True}
Test Teardown        SISO Coam Test Teardown
Test Timeout         8h

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    Resource/CB012449_common_keywords.robot

Force Tags    HAZ4_T04


*** Test Cases ***
[1]CB012449_SR_A_31_Verify_Tput_Stability_With_SrsSubbandBm
    [Documentation]    Verify throughput stability with SrsSubbandBm parameter change
    [Tags]    4S-1CC_CB012449
    Verify Throughput Stability With SRS Subband BM    duration=900    check_duration=60    ue_num_each_call=1
