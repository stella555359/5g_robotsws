*** Settings ***
Documentation
...   Author:   Terhi Talvitie
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Resource    testsuite/Oulu/TrunkEng/RecoveryAndAlarms/Robot/Resources/ssh_commands_kws.robot
Resource    testsuite/Oulu/TrunkEng/RecoveryAndAlarms/Robot/TestKeywords/kill_applications_reset.robot


*** Keywords ***
Application kill
    [Arguments]    ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_RECO_COUNTER_CLEAR}  ${APPLICATION}  ${SYSLOG_LIST}
    ...            ${SYSLOG_PRINT}    ${WAIT}
    Print Text To Eventlog                 Check if SMOD in use is ASOG/H and add fault 61675 as allowed
    Run Keyword And Continue On Failure    Check If Fault 61675 Should Be Allowed
    Print Step Text    1  Check Preconditions
    Run Keyword And Continue On Failure    Common Preconditions
    Run Keyword And Continue On Failure    Start Syslog Print Search To Background  ${SYSLOG_LIST}
# This is needed because it depends on commissioning if the fault is allowed or not
    Run Keyword And Continue On Failure    Check If Fault 4590 Should Be Allowed
    Run Keyword And Continue On Failure    Check If Fault 4589 Should Be Allowed
# Added because of PR740214, more info in https://jiradc.ext.net.nokia.com/browse/FCA_TATSCRIPTS-182327
    Run Keyword And Continue On Failure    List All Applications
    Run Keyword And Continue On Failure    Check Rmod Uptimes
    Run Keyword And Continue On Failure    Add Fault 7504 As Allowed If 5g
# check if fhs in environment and if is then add as allowed alarm
    ${FHS_10_as_allowed}=                  Check If Fault 10 Should Be Allowed To FHS
    ${WAIT_BEFORE_KILL}=                   Get Variable Value  ${WAIT_BEFORE_KILL}  0
    IF  '${WAIT_BEFORE_KILL}' != '0'
        Wait Time And Reason               sleep_time=${WAIT_BEFORE_KILL}    wait_reason=before killing application
    END
    Run Keyword And Continue On Failure    Ssh to bts and kill application    ${APPLICATION}    2
    Run Keyword And Continue On Failure    ALARMS.Add Allowed Alarm  severity=Major  alarm_id=7100  fault_id=4701
    ...                                                              fault_name=RX Power too low
    Run Keyword And Continue On Failure    Ping Ip Until Disconnection Or Reconnection    disconnection=True
    Run Keyword And Continue On Failure    Ping Ip Until Disconnection Or Reconnection
    Run Keyword And Continue On Failure    Check If Admin Connection Available    360
    Run Keyword And Continue On Failure    Wait For All Cells Up   time_limit=${WAIT_FOR_CELLS_UP}
    Run Keyword And Continue On Failure    Check Rmod Uptimes
    Run Keyword And Continue On Failure    Check Processes After Application Kill  application=${APPLICATION}
    Print Step Text    4  Check alarms after spurious reset
    Run Keyword And Continue On Failure    Check Alarm History
    Run Keyword And Continue On Failure    ALARMS.Remove Allowed Alarm  alarm_id=7100  fault_id=4701
    ...                                                                 fault_name=RX Power too low
    Print Step Text    5  Check syslog prints
    Run Keyword And Continue On Failure    Check If Syslog Print Is Found  ${SYSLOG_PRINT}
    Run Keyword And Continue On Failure    Check if Unexpected Syslog Print  ${Unexpected_Syslog}
    Run Keyword And Continue On Failure    Stop Background Syslog Print Search
    Wait Time And Reason                   sleep_time=${WAIT}    wait_reason=before checking post-conditions
    Run Keyword And Continue On Failure    ALARMS.Add Allowed Alarm  severity=Major  alarm_id=7100  fault_id=4701
    ...                                                              fault_name=RX Power too low
    Print Text To Eventlog                 Common Postconditions checks
    Run Keyword And Continue On Failure    Common Postconditions
# remove allowed allowed fhs alarm if it was added and check active alarms
    IF   ${FHS_10_as_allowed}
        Run Keyword And Continue On Failure    Remove Allowed Alarm   fault_id=10   fault_name=No connection to unit
        Run Keyword And Continue On Failure    Check Active Alarms    test_step_txt=after allowed 10 fault is removed
    END
# Executing site reset cleaner is done after successful test run so it is able to loop this test multiple times
   Run Keyword And Continue On Failure     Site reset cleaner    ${WAIT_FOR_CELLS_UP}
    ...              ${WAIT_FOR_RECO_COUNTER_CLEAR}  ${6}
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}    ${False}
