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
TC01_Alarm_Operation_Wrong_Operation_enb
    [Tags]    TC01    Abnormal
    ${case_result}    ${out}    Run Keyword And Ignore Error    Alarm Operation    operation=asdf
    ...                                                                            product_type=enb
    ...                                                                            bts_index=0
    ...                                                                            cudu_index=0
    Log To Console    \nOutput is: ${out}
    Log To Console    \nCase Result: ${case_result}
    Should Be Equal    ${case_result}    FAIL

TC02_Alarm_Operation_Wrong_Product_Type
    [Tags]    TC02    Abnormal
    ${case_result}    ${out}    Run Keyword And Ignore Error    Alarm Operation    operation=get_active_alarms
    ...                                                                            product_type=asdf
    ...                                                                            bts_index=0
    ...                                                                            cudu_index=0
    Log To Console    \nOutput is: ${out}
    Log To Console    \nCase Result: ${case_result}
    Should Be Equal    ${case_result}    FAIL

TC03_Alarm_Operation_Get_Active_Alarms
    [Tags]    TC03    GetAlarm
    ${out}    Alarm Operation    operation=get_active_alarms
    ...                          product_type=enb
    ...                          bts_index=0
    ...                          cudu_index=0
    Log To Console    \nActive Alarms: ${out}

TC04_Alarm_Operation_Get_Historical_Alarms
    [Tags]    TC04    GetAlarm
    ${out}    Alarm Operation    operation=get_historical_alarms
    ...                          product_type=enb
    ...                          bts_index=0
    ...                          cudu_index=0
    Log To Console    \nHistorical Alarms: ${out}


TC05_Alarm_Operation_Check_Expected_Alarms
    [Tags]    TC05    CheckAlarm
    &{expected_alarms}        Create Dictionary    faultId=2401    faultName=TRX control plane link failure
    @{expected_list}          Create List     ${expected_alarms}
    &{ignored_alarms}         Create Dictionary    faultId=49    faultName=Cell blocked
    @{ignored_alarms_list}    Create List     ${ignored_alarms}
    &{CRITICAL_ALARM1}        Create Dictionary    severity=Critical
    @{CRITICAL}               Create List     ${CRITICAL_ALARM1}
    _Classical_Alarm_Operation.StartAdmin
    coam.block all cells    rat=WCDMA    timeout=60
    sleep  30s
    ${res}    Alarm Operation    operation=check_active_alarms    product_type=enb    bts_index=0
    ...                          expected_alarms=${expected_list}
    ...                          ignored_alarms=${ignored_alarms_list}
    ...                          critical_alarms=${CRITICAL}
    coam.unblock all cells    rat=WCDMA    timeout=60

    Log To Console    \nCheck Expected Alarms Result: ${res}
    [Teardown]    Run keyword and ignore error    _Classical_Alarm_Operation.StopAdmin

TC06_Alarm_Operation_Watch_Alarms_On_enb
    [Tags]    TC06    WatchAlarm
    &{ignored_alarm}        Create Dictionary    alarm_id=7102    fault_id=49
    @{ignored_alarm}     Create list    ${ignored_alarm}
    set test variable    ${ignored_alarm}
    add_crt_allowed_alarms     ${CRT_ALLOWED_ALARMS}    ${ignored_alarm}
    Alarm Operation    operation=start_watch_alarms    ignored_alarms=${CRT_ALLOWED_ALARMS}
    ...     product_type=enb    bts_index=0    cudu_index=0
    _Classical_Alarm_Operation.StartAdmin
    coam.block all cells    rat=WCDMA    timeout=60
    sleep  30s
    coam.unblock all cells    rat=WCDMA    timeout=60
    ${res}    Alarm Operation    operation=get_detected_alarms    product_type=enb    bts_index=0
    Delete ignored alarm
    [Teardown]    Run keywords    _Classical_Alarm_Operation.StopAdmin
    ...    AND    Alarm Operation    operation=stop_watch_alarms   product_type=enb    bts_index=0


T7_Alarm_Operation_Analyze_Active_Alarms
    [Tags]    TC07    AnalyzeAlarm
    &{expected_alarms1}        Create Dictionary    fault_id=49
    &{expected_alarms2}        Create Dictionary    fault_name=Service account root access is enabled
    &{expected_alarms3}        Create Dictionary    fault_id=4654
    &{expected_alarms4}        Create Dictionary    fault_name=XXXXXX
    @{expected_list}           Create List     ${expected_alarms1}    ${expected_alarms2}    ${expected_alarms3}
    ...    ${expected_alarms4}
    ${res}    Alarm Operation    operation=analyze_active_alarms    product_type=enb    bts_index=0
    ...                          expected_alarms=${expected_list}
    Log To Console    \nAnalyze Active Alarms Result: ${res}
***Keywords ***
Delete ignored alarm
    del_crt_allowed_alarms     ${CRT_ALLOWED_ALARMS}    ${ignored_alarm}
    Alarm Operation    operation=start_watch_alarms    ignored_alarms=${CRT_ALLOWED_ALARMS}
    ...     product_type=enb    bts_index=0    cudu_index=0
    _Classical_Alarm_Operation.StartAdmin
    coam.block all cells    rat=WCDMA    timeout=60
    sleep  30s
    coam.unblock all cells    rat=WCDMA    timeout=60
    ${res}    Alarm Operation    operation=get_detected_alarms    product_type=enb    bts_index=0

