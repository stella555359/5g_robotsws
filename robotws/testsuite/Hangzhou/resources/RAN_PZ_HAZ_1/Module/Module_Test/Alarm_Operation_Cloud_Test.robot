*** Settings ***
Documentation
...   Author: Du Ning
...   Contact: ning.du@nokia-sbell.com
...   Description: This is the module test case

Resource          ../Module.robot
Resource          ../../../../RRM/RAN_PZ_HAZ_1/Resources/Cloud/AIC_Common_Resource.robot

# Suite Setup       Common Suite Setup For AIC
# Suite Teardown    Common Suite Teardown For AIC
# Test Setup        Common Test Setup For AIC
# Test Teardown     Common Test Teardown For AIC

Force Tags        RAN_VRF_HAZ1

Test Timeout      120 minutes

*** Variables ***
${wait_time}    300

*** Test Cases ***
TC01_Alarm_Operation_Wrong_Operation_Vdu
    [Tags]    TC01    Abnormal
    ${case_result}    ${out}    Run Keyword And Ignore Error    Alarm Operation    operation=asdf
    ...                                                                            product_type=vdu
    ...                                                                            bts_index=0
    ...                                                                            cudu_index=0
    Log To Console    \nOutput is: ${out}
    Log To Console    \nCase Result: ${case_result}
    Should Be Equal    ${case_result}    FAIL

TC02_Alarm_Operation_Wrong_Operation_Vcu
    [Tags]    TC02    Abnormal
    ${case_result}    ${out}    Run Keyword And Ignore Error    Alarm Operation    operation=asdf
    ...                                                                            product_type=vCU
    ...                                                                            bts_index=0
    ...                                                                            cudu_index=0
    Log To Console    \nOutput is: ${out}
    Log To Console    \nCase Result: ${case_result}
    Should Be Equal    ${case_result}    FAIL

TC03_Alarm_Operation_Wrong_Product_Type
    [Tags]    TC03    Abnormal
    ${case_result}    ${out}    Run Keyword And Ignore Error    Alarm Operation    operation=get_active_alarms
    ...                                                                            product_type=asdf
    ...                                                                            bts_index=0
    ...                                                                            cudu_index=0
    Log To Console    \nOutput is: ${out}
    Log To Console    \nCase Result: ${case_result}
    Should Be Equal    ${case_result}    FAIL

TC04_Alarm_Operation_Get_Active_Alarms
    [Tags]    TC04    GetAlarm
    ${out}    Alarm Operation    operation=get_active_alarms
    ...                          product_type=vcu
    ...                          bts_index=0
    ...                          cudu_index=0
    Log To Console    \nActive Alarms: ${out}

TC05_Alarm_Operation_Get_Historical_Alarms
    [Tags]    TC05    GetAlarm
    ${out}    Alarm Operation    operation=get_historical_alarms
    ...                          product_type=vcu
    ...                          bts_index=0
    ...                          cudu_index=0
    Log To Console    \nHistorical Alarms: ${out}

TC06_Alarm_Operation_Get_Historical_Alarms
    [Tags]    TC06    GetAlarm
    ${out}    Alarm Operation    operation=get_alarms
    ...                          product_type=vdu
    ...                          bts_index=0
    ...                          cudu_index=0
    Log To Console    \nActive and Historical Alarms: ${out}

TC07_Alarm_Operation_Check_Expected_Alarms
    [Tags]    TC07    CheckAlarm
    &{expected_alarms}        Create Dictionary    fault_id=7523    fault_name=Cell Activation timeout at gNB-vDU
    @{expected_list}          Create List     ${expected_alarms}
    &{ignored_alarms}         Create Dictionary    fault_id=4001    fault_name=BTS reset required
    @{ignored_alarms_list}    Create List     ${ignored_alarms}
    &{CRITICAL_ALARM1}        Create Dictionary    severity=critical
    @{CRITICAL}               Create List     ${CRITICAL_ALARM1}

    ${res}    Alarm Operation    operation=check_active_alarms    product_type=vdu    bts_index=0    cudu_index=0
    ...                          expected_alarms=${expected_list}
    ...                          ignored_alarms=${ignored_alarms_list}
    ...                          critical_alarms=${CRITICAL}
    Log To Console    \nCheck Expected Alarms Result: ${res}

TC08_Alarm_Operation_Watch_Alarms_On_Vcu
    [Tags]    TC08    WatchAlarm
    Alarm Operation    operation=start_watch_alarms    product_type=vcu    bts_index=0    cudu_index=0
    sleep  30s
    ${res}    Alarm Operation    operation=get_detected_alarms    product_type=vcu    bts_index=0    cudu_index=0
    Alarm Operation    operation=stop_watch_alarms   product_type=vcu    bts_index=0    cudu_index=0

T09_Alarm_Operation_Watch_Alarms_On_Vdu
    [Tags]    TC09    WatchAlarm
    Alarm Operation    operation=start_watch_alarms    product_type=vdu    bts_index=0    cudu_index=0
    sleep  30s
    ${res}    Alarm Operation    operation=get_detected_alarms    product_type=vdu    bts_index=0    cudu_index=0
    Alarm Operation    operation=stop_watch_alarms   product_type=vdu    bts_index=0    cudu_index=0

T10_Alarm_Operation_Analyze_Active_Alarms
    [Tags]    TC10    AnalyzeAlarm
    ${res}    Alarm Operation    operation=analyze_active_alarms    product_type=vdu    bts_index=0    cudu_index=0
    ...                          expected_alarms=Cell Activation timeout at gNB-vDU
    Log To Console    \nAnalyze Active Alarms Result: ${res}

T11_Alarm_Operation_Analyze_Active_Alarms
    [Tags]    TC11    AnalyzeAlarm
    &{expected_alarms1}        Create Dictionary    fault_id=4298
    &{expected_alarms2}        Create Dictionary    fault_name=ToP reference missing
    &{expected_alarms3}        Create Dictionary    fault_id=16
    &{expected_alarms4}        Create Dictionary    fault_name=Unit synchronization failed
    @{expected_list}           Create List     ${expected_alarms1}
    ...    ${expected_alarms2}
    ...    ${expected_alarms3}
    ...    ${expected_alarms4}
    ${res}    Alarm Operation    operation=analyze_active_alarms    product_type=vdu
    ...                          expected_alarms=${expected_list}
    Log To Console    \nAnalyze Active Alarms Result: ${res}


