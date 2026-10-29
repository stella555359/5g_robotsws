*** Settings ***
Suite Setup          CB012365 CBRS Suite Setup
Suite Teardown       CBRS Suite Teardown
Test Setup           CBRS Test Setup
Test Teardown        CBRS Test Teardown

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    resources/CB012365_common_keywords.robot

Documentation
...    Author:wangqingqing
...    contact:qingqing.wang@nokia-sbell.com
...    squad group:SG_08
...    Feature CB012365

Force Tags    SBTS00
...   PY36

*** Variables ***

*** Test Cases ***
[1]CB012365_2_Frequency_Selection_Algorithem_when_Both_Sides_GAA_with_PAL_not_Meet_desiredChBw
    [Tags]    CRT_TRUNK
    CB012365_2_Frequency_Selection_Algorithem_when_Both_Sides_GAA_with_PAL_not_Meet_desiredChBw

[1]CB012365_24_Behavior_when_CBSD_Initial_Heartbeat_Receives_GAA_Success_Response_but_PAL_ResponseCode_502_GAA_meet
    [Tags]    CRT_TRUNK
    CB012365_24_Behavior_when_CBSD_Initial_Heartbeat_Receives_GAA_Success_Response_but_PAL_ResponseCode_502_GAA_meet

[1]CB012365_10_Behavior_when_CBSD_Initial_Grant_receives_with_GAA_ResponseCode_400_PAL_need_drop
    [Tags]    CRT_TRUNK
    CB012365_10_Behavior_when_CBSD_Initial_Grant_receives_with_GAA_ResponseCode_400_PAL_need_drop

[1]CB012365_21_gNB_Behavior_when_CBSD_Initial_Heartbeat_Receives_PAL_Success_Response_but_GAA_ResponseCode_501_PAL_drop_part
    [Tags]    CRT_TRUNK
    CB012365_21_gNB_Behavior_when_CBSD_Initial_Heartbeat_Receives_PAL_Success_Response_but_GAA_ResponseCode_501_PAL_drop_part

[1]CB012365_34_Behavior_when_CBSD_Subsequent_Heartbeat_Receives_both_PAL_and_GAA_ResponseCode501_with_OperationParm
    [Tags]    CRT_TRUNK
    CB012365_34_Behavior_when_CBSD_Subsequent_Heartbeat_Receives_both_PAL_and_GAA_ResponseCode501_with_OperationParm

[1]CB012365_39_CBSD_Behaviors_after_online_change_of_palGaaPwrDiff_noimpact_impact
    [Tags]    CRT_TRUNK
    CB012365_39_CBSD_Behaviors_after_online_change_of_palGaaPwrDiff_noimpact_impact

*** Keywords ***
