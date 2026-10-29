*** Settings ***
Documentation
...   Author:   Terhi Talvitie
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Library          testsuite.Oulu.TrunkEng.OMKPI.Python.Interfaces.OmkpiStartupTimesInterface  WITH NAME  Startup
Library          testsuite.Oulu.TrunkEng.OMKPI.Python.Interfaces.OmkpiCommonInterface
Resource         testsuite/Oulu/TrunkEng/OMKPI/Robot/Resources/OMKPI_common.robot

Library          taf.fdsw.rc  WITH NAME  RC
Library          testsuite.Oulu.TrunkEng.RecoveryAndAlarms.Python.Interfaces.FDSW  WITH NAME  FDSW
Library          testsuite.Oulu.TrunkEng.RecoveryAndAlarms.Python.Interfaces.RescueConsole
Resource         testsuite/Oulu/TrunkEng/RecoveryAndAlarms/Robot/TestKeywords/failsafe_boot_ute.robot

*** Keywords ***
Configuration Reset SW Rollback
    [Documentation]    Do configuration reset that activates FDSW. Do SW rollback to active SW from RescueConsole.
    [Arguments]        ${WAIT}  ${SYSLOG_LIST}  ${WAIT_RC_CONNECTION}    ${ALLOWED_RC_ALARM}  ${UNALLOWED_SYSLOGS}
    Run Keyword And Continue On Failure    Start Syslog Print Search To Background   ${SYSLOG_LIST}
#    Run Keyword And Continue On Failure    Check If Netboot Is Active And Deactivate It
# check if fdsw is installed
    Run Keyword And Continue On Failure    Failsafe Pre Checks  ${SYSLOG_LIST}
    Run Keyword and Continue On Failure    Stop RT Alarm Listener
# configuration reset
    Print Step Text                      3  Perform configuration reset   automatic=${True}
    Run Keyword And Continue On Failure    Perform Configuration Reset
    Run Keyword And Continue On Failure    Close BTS SSH Connection
    Wait Time And Reason                   ${WAIT_RC_CONNECTION}     before connecting to RescueConsole
    Run Keyword And Continue On Failure    Connect To RC
    Print Step Text                      4  Check partition and SW   automatic=${True}
    Run Keyword And Continue On Failure    Check Partition And SW
    Print Step Text                      5  Check alarms from Rescue Console   automatic=${True}
    Run Keyword And Continue On Failure     Check Alarms From Rescue Console    allowed_alarms=${ALLOWED_RC_ALARM}
    Run Keyword And Continue On Failure    Failsafe Activate Previous SW
    Print Step Text                      6  Wait for BTS connection, then wait ${WAIT} before postconditions check  automatic=${True}
    Run Keyword And Continue On Failure    Ping Ip Until Disconnection Or Reconnection
    ...                                    ip_to_ping=192.168.255.129  disconnection=True    time_to_wait=300
    Run Keyword And Continue On Failure    Ping Ip Until Disconnection Or Reconnection
    ...                                    ip_to_ping=192.168.255.129  time_to_wait=300
    Run Keyword And Continue On Failure    Check If Admin Connection Available    360
    Start Rt Alarm Listener
    # Reset admin connections after SWDL
    Print Text To Eventlog    Reset admin connections after returning to normal partition
    Run Keyword and Continue On Failure    Reset Admin Connection
    Run Keyword and Continue On Failure    Reset Admin Connection    admin=default
    Wait Time And Reason                    ${WAIT}    before checking post-conditions
    Print Step Text                      7  Check Postconditions   automatic=${True}
    Run Keyword And Continue On Failure    Close SSH Log
    Run Keyword And Continue On Failure    Stop Background Syslog Print Search
    Run Keyword And Continue On Failure    Common Postconditions
#    Run Keyword And Continue On Failure    Check If Netboot Is Deactive And Activate It
    Run Keyword And Continue On Failure    Check If Unexpected Syslog Print  ${UNALLOWED_SYSLOGS}
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}  ${False}
