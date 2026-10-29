*** Settings ***
Documentation
...   Author:   Essi Passoja / Mirka Kyllönen
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Library     testsuite.Oulu.TrunkEng.Common.Python.Interfaces.FspIP  WITH NAME  FSP
Library     testsuite.Oulu.TrunkEng.Common.Python.Interfaces.Applications  WITH NAME  APPLICATIONS
Library     testsuite.Oulu.TrunkEng.RecoveryAndAlarms.Python.Interfaces.FaultingBBMOD
Resource    testsuite/Oulu/TrunkEng/RecoveryAndAlarms/Robot/TestKeywords/bbmod_soc_test_kws.robot


*** Keywords ***
Crash During Startup For All Primary SOCs
    [Arguments]       ${WAIT_FOR_CELLS_UP}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}  ${GRACEFUL_REBOOT}

    @{UNITS}=                            Get All BBMODs
    ${STEP}=                             Check If Step Smaller Or Same As Saved If Is Increase    ${0}

    FOR  ${UNIT}  IN  @{UNITS}
        ${is_abia}=    Evaluate    'ABIA' in '${UNIT}' and ${GRACEFUL_REBOOT}
        IF    ${is_abia}
            Print Text To Eventlog     Skipping ${UNIT} because graceful reboot is ${GRACEFUL_REBOOT}
        ELSE
            Run Keyword And Continue On Failure  Crash Primary SoC During Startup
            ...          ${WAIT_FOR_CELLS_UP}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}  ${UNIT}  ${GRACEFUL_REBOOT}  ${STEP}
        END
    END
    Print Step Text                      ${STEP}  Make site reset and wait for all cells up
    Print Text To Eventlog               Request site reset
    Run Keyword And Continue On Failure  Reset Site  detailed_output=True
    Run Keyword And Continue On Failure  Wait For All Cells Up  ${WAIT_FOR_CELLS_UP}
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}  ${False}


Crash Primary SoC During Startup
    [Arguments]       ${WAIT_FOR_CELLS_UP}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}  ${UNIT}  ${GRACEFUL_REBOOT}  ${STEP}

    ${STEP}=                          Check If Step Smaller Or Same As Saved If Is Increase    ${STEP}
    Print Step Text                   ${STEP}  Check Preconditions
    Run Keyword And Continue On Failure  Start Syslog Print Search To Background  ${SYSLOG_LIST}
    Run Keyword                          Common Preconditions
    Run Keyword                          Check That Max Allowed FSP Recovery Is Set To Default
    Run Keyword And Continue On Failure  ALARMS.Add Allowed Alarm   fault_id=4748
#    Run Keyword And Continue On Failure  Make SSH Log
    ${STEP}=                          Check If Step Smaller Or Same As Saved If Is Increase    ${STEP}
    Print Step Text                   ${STEP}  Make site reset
    Print Text To Eventlog               Request site reset
    Run Keyword And Continue On Failure  Reset Site  detailed_output=True
    Run Keyword And Continue On Failure  Ping IP Until Disconnection Or Reconnection  time_to_wait=900

    ${STEP}=                          Check If Step Smaller Or Same As Saved If Is Increase    ${STEP}
    Print Step Text                   ${STEP}  Generate fault to tested FSP ${UNIT}
    ${bbmod}=                            Get BBMOD Object From User Given Values  ${UNIT}
    Run Keyword And Continue On Failure  Generate Fault To FSP  ${bbmod}  graceful_reboot=${GRACEFUL_REBOOT}
    ...                                  during_startup=${True}
    Run Keyword And Continue On Failure  Check Expected Alarms  wait_active_timeout=600
    Wait Time and Reason                 15  Wait before checking cells

    ${STEP}=                          Check If Step Smaller Or Same As Saved If Is Increase    ${STEP}
    Print Step Text                   ${STEP}  Wait for all cells up, then check syslog prints
    Run Keyword And Continue On Failure  Wait For All Cells Up  ${WAIT_FOR_CELLS_UP}
    Run Keyword And Continue On Failure  Check If Unexpected Syslog Print  ${UNALLOWED_SYSLOGS}

    ${STEP}=                          Check If Step Smaller Or Same As Saved If Is Increase    ${STEP}
    Print Step Text                   ${STEP}  Check Postconditions, alarms
    Run Keyword And Continue On Failure  Common Postconditions
    Run Keyword And Continue On Failure  ALARMS.Remove Allowed Alarm  fault_id=4748
    Run Keyword And Continue On Failure  Check Active Alarms
#    Close SSH Log
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}  ${False}

Crash During Startup For All Secondary SOCs
    [Arguments]       ${WAIT_FOR_CELLS_UP}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}

    @{UNITS}=                            Get All BBMODs
    ${STEP}=                             Check If Step Smaller Or Same As Saved If Is Increase    ${0}

    FOR  ${UNIT}  IN  @{UNITS}
        ${BBMOD_OBJ}=                        Get BBMOD Object From User Given Values    ${UNIT}
        ${SOC}=                              Set Variable  ${BBMOD_OBJ.secondary_socs}[0]
        Run Keyword And Continue On Failure  Crash Secondary SoC During Startup
        ...             ${WAIT_FOR_CELLS_UP}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}  ${UNIT}  ${SOC}  ${STEP}
    END
    Print Step Text                      ${STEP}  Make site reset and wait for all cells up
    Print Text To Eventlog               Request site reset
    Run Keyword And Continue On Failure  Reset Site  detailed_output=True
    Run Keyword And Continue On Failure  Wait For All Cells Up  ${WAIT_FOR_CELLS_UP}
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}  ${False}

Crash Secondary SoC During Startup
    [Arguments]       ${WAIT_FOR_CELLS_UP}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}  ${UNIT}  ${SOC}  ${STEP}

    ${STEP}=                             Check If Step Smaller Or Same As Saved If Is Increase  ${STEP}
    Print Step Text                      ${STEP}  Check Preconditions
    Run Keyword And Continue On Failure  Start Syslog Print Search To Background  ${SYSLOG_LIST}
    Run Keyword                          Common Preconditions
    Run Keyword                          Check That Max Allowed FSP Recovery Is Set To Default
    Run Keyword And Continue On Failure  Make SSH Log

    ${STEP}=                             Check If Step Smaller Or Same As Saved If Is Increase  ${STEP}
    Print Step Text                      ${STEP}  Make site reset
    Print Text To Eventlog               Request site reset
    Run Keyword And Continue On Failure  Reset Site  detailed_output=True
    Run Keyword And Continue On Failure  Ping IP Until Disconnection Or Reconnection  time_to_wait=900

    ${STEP}=                             Check If Step Smaller Or Same As Saved If Is Increase  ${STEP}
    Print Step Text                      ${STEP}  Generate fault to tested FSP ${UNIT}
    ${bbmod}=                            Get BBMOD Object From User Given Values  ${UNIT}
    Run Keyword And Continue On Failure  Generate Fault To FSP  ${bbmod}  primary=${False}  secondary_soc=${SOC}
    ...                                  during_startup=${True}
    Run Keyword And Continue On Failure  Check Expected Alarms  wait_active_timeout=300
    Wait Time and Reason                 15  Wait before checking cells

    ${STEP}=                             Check If Step Smaller Or Same As Saved If Is Increase  ${STEP}
    Print Step Text                      ${STEP}  Wait for all cells up, then check syslog prints
    Run Keyword And Continue On Failure  Wait For All Cells Up  ${WAIT_FOR_CELLS_UP}
    Run Keyword And Continue On Failure  Check If Unexpected Syslog Print  ${UNALLOWED_SYSLOGS}

    ${STEP}=                             Check If Step Smaller Or Same As Saved If Is Increase  ${STEP}
    Print Step Text                      ${STEP}  Check Postconditions and alarms
    Run Keyword And Continue On Failure  Common Postconditions
    Close SSH Log
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}  ${False}
