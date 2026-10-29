*** Settings ***

Documentation
...   Author:   Terhi Talvitie
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com


*** Keywords ***
Block Unblock Bts
    [Arguments]    ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}    ${WAIT_CHECKS}    ${WAIT_FOR_CELLS_UP}

    Run Keyword and Continue On Failure     Start Syslog Print Search To Background     ${SYSLOG_LIST}
    Print Step Text                      1  Check Preconditions
    Run Keyword and Continue On Failure     Common Preconditions
#    Run Keyword And Continue On Failure     Check If Netboot Is Active And Deactivate It
    # Run Keyword and Continue On Failure     Check If Graceful Cell Shutdown
    ${unit_path}=                           Get Unit Path Of Smod
    ALARMS.Add Expected Alarm               unit_path=${unit_path}  alarm_id=7650  fault_id=50  fault_name=BTS blocked  severity=Critical
    ALARMS.Add Expected Alarm To Allowed
    Print Step Text                      2  Block Bts
    Print Text To Eventlog                  Request BTS block
    Run Keyword and Continue On Failure     ADMIN.Block
    Print Step Text                      3  Wait for all cells disabled and check expected alarms
    Run Keyword And Continue On Failure     Wait For Cells Faulty  600
    Run Keyword And Continue On Failure     ALARMS.Check Expected Alarms  wait_active_timeout=120
    Print Step Text                      4  Unblock Bts
    Print Text To Eventlog                  Request BTS unblock
    Run Keyword and Continue On Failure     ADMIN.Unblock  timeout=300
    Print Step Text                      5  Wait for all cells up
    Run Keyword and Continue On Failure     Wait For All Cells Up  time_limit=${WAIT_FOR_CELLS_UP}
    Wait Time And Reason                    ${WAIT_CHECKS}  before checking post conditions
    Print Step Text                      6  Check Postconditions
    Run Keyword and Continue On Failure     Common Postconditions
    Run Keyword and Continue On Failure     Check If Unexpected Syslog Print  ${UNALLOWED_SYSLOGS}
    Run Keyword And Continue On Failure     Stop Background Syslog Print Search

    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}  ${False}
