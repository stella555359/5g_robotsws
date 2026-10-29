*** Settings ***
Documentation      author: Bin Wang
...                contact: bin.3.wang@nokia-sbell.com

Suite Setup       KW.TestSuilt.Start_CB012611
Suite Teardown    KW.TestSuilt.Stop_CB012611
Test Timeout         300 min


Resource           testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB012611_SG1/Resources/CB012611_Resources.robot

*** Test Cases ***
CB012611_Site_reset_down_time
    [Documentation]     This case is to test CB012611-A. Site reset KPI1a with HW failure should not be degradation compared with no lokia failure
    [Tags]
    [Setup]    TestCase.Start_CB012611
    [Teardown]  Teardown Case_CB012611
    CB012611_Site_reset_down_time

CB012611_RAT_reset_down_time
    [Documentation]     This case is to test CB012611-G. RAT reset KPI with Loki failure should not be degradation compared with no loki failure
    [Tags]
    [Setup]    TestCase.Start_CB012611
    [Teardown]  Teardown Case_KPI10b_CB012611
    TC.CB012611_RAT_Hard_reset_down_time

[1][1.0] CB008181_SR_C_15_5G_RAT_reset_KPI10
    [Documentation]     This case is to test CB012611-G. RAT reset KPI with Loki failure should not be degradation compared with no loki failure
    [Tags]
    [Setup]    TestCase.Start_CB012611
    [Teardown]  Teardown Case_KPI10b_CB012611
    TC.CB012611_RAT_Hard_reset_down_time