*** Settings ***
Documentation
...   Author:   Essi Passoja
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Library     testsuite.Oulu.TrunkEng.Common.Python.Interfaces.FspIP  WITH NAME  FSP
Library     testsuite.Oulu.TrunkEng.Common.Python.Interfaces.Applications  WITH NAME  APPLICATIONS
Library     testsuite.Oulu.TrunkEng.RecoveryAndAlarms.Python.Interfaces.FaultingSMOD
Library     testsuite.Oulu.TrunkEng.OMKPI.Python.Interfaces.OmkpiCommonInterface

*** Variables ***
${name_of_the_fault_4383}   Virtual node not responding

*** Keywords ***
Crash controller SoC from SMOD
    [Arguments]                       ${STEP}  ${SMOD}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}
    ...                               ${WAIT_FOR_DISCONNECT}  ${WAIT_FOR_RECONNECT}  ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_ALARM}

    ${STEP}=                          Check If Step Smaller Or Same As Saved If Is Increase  ${STEP}
    Print Text To Eventlog               Check if SMOD in use is ASOG/H and add fault 61675 as allowed
    Run Keyword And Continue On Failure  Check If Fault 61675 Should Be Allowed
    Print Step Text                   ${STEP}  Check Preconditions
    Run Keyword And Continue On Failure  Start Syslog Print Search To Background  ${SYSLOG_LIST}
    Run Keyword                          Common Preconditions
    Run Keyword And Continue On Failure  Make SSH Log
    ${SMOD_OBJ}=                         Get SMOD Object  ${SMOD}
    Run Keyword And Continue On Failure  Check Rmod Uptimes

    ${STEP}=                          Check If Step Smaller Or Same As Saved If Is Increase  ${STEP}
    Print Step Text                   ${STEP}  Fault is generated to ${SMOD_OBJ.name} (Marlin)
    Run Keyword And Continue On Failure  Generate Fault to SMOD SoC  ${SMOD_OBJ}  Marlin

    ${STEP}=                          Check If Step Smaller Or Same As Saved If Is Increase  ${STEP}
    Print Step Text                   ${STEP}  Wait for BTS disconnection and reconnection
    Run Keyword And Continue On Failure  Ping Ip Until Disconnection Or Reconnection  ip_to_ping=192.168.255.129
    ...                                  disconnection=True  time_to_wait=${WAIT_FOR_DISCONNECT}
    Run Keyword And Continue On Failure  Ping Ip Until Disconnection Or Reconnection  ip_to_ping=192.168.255.129
    ...                                  disconnection=False  time_to_wait=${WAIT_FOR_RECONNECT}
    Run Keyword and Continue On Failure  Wait For All Cells Up  time_limit=${WAIT_FOR_CELLS_UP}
    Run Keyword And Continue On Failure  Check Rmod Uptimes

    ${STEP}=                          Check If Step Smaller Or Same As Saved If Is Increase  ${STEP}
    Print Step Text                   ${STEP}  Wait for the expected alarm to appear
    Run Keyword And Continue On Failure  Check Expected Alarms  wait_for_active=${True}  wait_active_timeout=${WAIT_FOR_ALARM}

    ${STEP}=                          Check If Step Smaller Or Same As Saved If Is Increase    ${STEP}
    Print Step Text                   ${STEP}  Check Postconditions and alarms
    Run Keyword And Continue On Failure  Common Postconditions
    Run Keyword And Continue On Failure  Check If Unexpected Syslog Print  ${UNALLOWED_SYSLOGS}
    Run Keyword And Continue On Failure  Stop Background Syslog Print Search

    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}  ${False}

Crash interface SoC from SMOD
    [Arguments]                       ${STEP}  ${SMOD}  ${APPLICATION}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}
    ...                               ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_ALARM}  ${ALL_CONTAINERS}  ${ONLY_FAULT_ID}

    ${CURRENT_LOOP}=                  Current Test Loop
    ${STEP}=                          Check If Step Smaller Or Same As Saved If Is Increase  ${STEP}
    Print Text To Eventlog               Check if SMOD in use is ASOG/H and add fault 61675 as allowed
    Run Keyword And Continue On Failure  Check If Fault 61675 Should Be Allowed
    Print Step Text                   ${STEP}  Check Preconditions
    Run Keyword And Continue On Failure  Start Syslog Print Search To Background  ${SYSLOG_LIST}
    Run Keyword                          Common Preconditions
    Run Keyword And Continue On Failure  Make SSH Log
    ${SMOD_OBJ}=                         Get SMOD Object  ${SMOD}
    Run Keyword And Continue On Failure  Check Rmod Uptimes

    ${STEP}=                          Check If Step Smaller Or Same As Saved If Is Increase  ${STEP}
    Print Step Text                   ${STEP}  Fault is generated to ${SMOD_OBJ.name} (Thor)
    Run Keyword And Continue On Failure  Generate Fault to SMOD SoC  ${SMOD_OBJ}  Thor  ${APPLICATION}
    ...                                  all_containers=${ALL_CONTAINERS}  only_fault_id=${ONLY_FAULT_ID}
    ${RESTART_COUNTER}=               Get Restart Counter
    ${STEP}=                          Check If Step Smaller Or Same As Saved If Is Increase  ${STEP}
    Print Step Text                   ${STEP}  Wait for the expected alarm to appear
    Run Keyword And Continue On Failure  Check Expected Alarms  wait_for_active=${True}  wait_active_timeout=${WAIT_FOR_ALARM}

    ${STEP}=                          Check If Step Smaller Or Same As Saved If Is Increase  ${STEP}
    IF  '${CURRENT_LOOP}' != '16'
        Print Step Text                   ${STEP}  Wait for BTS to recover
        Run Keyword and Continue On Failure  Wait For All Cells Up  time_limit=${WAIT_FOR_CELLS_UP}
        Run Keyword And Continue On Failure  Check Rmod Uptimes
        ${STEP}=                          Check If Step Smaller Or Same As Saved If Is Increase    ${STEP}
        Print Step Text                   ${STEP}  Check Postconditions and alarms
        Run Keyword And Continue On Failure  Common Postconditions
    ELSE
        Print Step Text                   ${STEP}  Check bts state
        &{disabled_failed}=                        Create Dictionary  operationalState=Disabled  availabilityStatus=NotInstalled
        Run Keyword And Continue On Failure        Check Bts State    ${disabled_failed}
        Run Keyword And Continue On Failure        Site reset cleaner    ${WAIT_FOR_CELLS_UP}  360    4
    END

    Run Keyword And Continue On Failure  Check If Unexpected Syslog Print  ${UNALLOWED_SYSLOGS}
    Run Keyword And Continue On Failure  Stop Background Syslog Print Search

    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}  ${False}


Crash interface SOC from SMOD looped
    [Arguments]                       ${SMOD}  ${APPLICATION}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}
    ...                               ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_ALARM}  ${ALL_CONTAINERS}  ${ONLY_FAULT_ID}

    FOR  ${outer_index}  IN RANGE  1  5
        Run Keyword And Continue On Failure  Crash interface looped inner loop  ${outer_index}  ${SMOD}  ${APPLICATION}
        ...                                  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}  ${WAIT_FOR_CELLS_UP}
        ...                                  ${WAIT_FOR_ALARM}  ${ALL_CONTAINERS}  ${ONLY_FAULT_ID}  ${WAIT_FOR_ALARM}
    END

    Print Step Text                      4.8.1  Check bts state
    &{integrated_to_ran}=                       Create Dictionary  proceduralState=IntegratedToRan
    Run Keyword And Continue On Failure         Check Bts State  ${integrated_to_ran}
    Print Step Text                      4.8.2  Reset site before checking postconditions
    Run Keyword and Continue On Failure         ADMIN.Reset Site  detailed_output=True
    Print Step Text                      4.8.3  Wait for cells after site reset
    Run Keyword and Continue On Failure         Wait For All Cells Up  time_limit=${WAIT_FOR_CELLS_UP}
    Print Step Text                      4.8.4  Check Postconditions and alarms
    Run Keyword And Continue On Failure         Common Postconditions

    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}  ${False}

Crash interface looped inner loop
    [Arguments]                       ${outer_index}  ${SMOD}  ${APPLICATION}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}
    ...                               ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_ALARM}  ${ALL_CONTAINERS}  ${ONLY_FAULT_ID}
    ...                               ${WAIT_FOR_ALARM}

    Print Step Text                      ${outer_index}.0.1  Start inner loop
    FOR  ${inner_index}  IN RANGE  1  4
        Run Keyword And Continue On Failure  Crash interface SOC from SMOD with expected alarm
        ...                                  Warning  7101  4383
        ...                                  Internal BTS processes autonomous reset as recovery action
        ...                                  ${outer_index}  ${inner_index}  ${SMOD}  ${APPLICATION}  ${SYSLOG_LIST}
        ...                                  ${UNALLOWED_SYSLOGS}  ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_ALARM}
        ...                                  ${ALL_CONTAINERS}  ${ONLY_FAULT_ID}  ${False}
    END

    FOR  ${inner_index}  IN RANGE  4  7
        Run Keyword And Continue On Failure  Crash interface SOC from SMOD with expected alarm
        ...                                  Warning  7101  4383
        ...                                  RAT autonomous reset as recovery action
        ...                                  ${outer_index}  ${inner_index}  ${SMOD}  ${APPLICATION}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}
        ...                                  ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_ALARM}  ${ALL_CONTAINERS}  ${ONLY_FAULT_ID}
        ...                                  ${False}
    END

    IF  ${outer_index} != 4
        Run Keyword And Continue On Failure  Crash interface SOC from SMOD with expected alarm
        ...                                  Warning  7101  4383
        ...                                  BTS site autonomous reset as recovery action
        ...                                  ${outer_index}  7  ${SMOD}  ${APPLICATION}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}
        ...                                  ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_ALARM}  ${ALL_CONTAINERS}  ${ONLY_FAULT_ID}
        ...                                  ${True}
    ELSE
        ${fault_name_changed}=               Get Branch And Check If Same Or Newer Than Given  SBTS26R2
        IF  ${fault_name_changed}
            Set Suite Variable   ${name_of_the_fault_4383}  Internal service not responding
        END
        Run Keyword And Continue On Failure  Crash interface SOC from SMOD with expected alarm
        ...                                  Critical  7116  4383
        ...                                  ${name_of_the_fault_4383}
        ...                                  ${outer_index}  7  ${SMOD}  ${APPLICATION}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}
        ...                                  ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_ALARM}  ${ALL_CONTAINERS}  ${ONLY_FAULT_ID}
        ...                                  ${True}
    END

Crash interface SOC from SMOD with expected alarm
    [Arguments]                       ${SEVERITY}  ${ALARM_ID}  ${FAULT_ID}  ${FAULT_NAME}  ${outer_index}  ${inner_index}  ${SMOD}  ${APPLICATION}
    ...                               ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}  ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_ALARM}
    ...                               ${ALL_CONTAINERS}  ${ONLY_FAULT_ID}  ${BTS_RESET}

    Print Step Text                      ${outer_index}.${inner_index}.1  Check Preconditions
    Run Keyword And Continue On Failure  Start Syslog Print Search To Background  ${SYSLOG_LIST}
    Run Keyword                          Common Preconditions
    Run Keyword And Continue On Failure  Make SSH Log
    ${SMOD_OBJ}=                         Get SMOD Object  ${SMOD}

    Print Step Text                      ${outer_index}.${inner_index}.2  Add expected alarm
    Run Keyword and Continue On Failure  Add Expected Alarm
        ...                              severity=${SEVERITY}  alarm_id=${ALARM_ID}  fault_id=${FAULT_ID}
        ...                              fault_name=${FAULT_NAME}
    Run Keyword And Continue On Failure  Check Rmod Uptimes

    Print Step Text                      ${outer_index}.${inner_index}.3  Fault is generated to ${SMOD_OBJ.name} (Thor)
    Run Keyword And Continue On Failure  Generate Fault to SMOD SoC  ${SMOD_OBJ}  Thor  ${APPLICATION}
    ...                                  all_containers=${ALL_CONTAINERS}  only_fault_id=${ONLY_FAULT_ID}

    Print Step Text                      ${outer_index}.${inner_index}.4  Wait for the expected alarm to appear
    Check Expected Alarms                wait_for_active=${True}  wait_active_timeout=${WAIT_FOR_ALARM}

    IF  ${BTS_RESET} != ${True}
        Check If Fault Active And Wait For It To Clear  fault_id=4383
    END

    ${is_last_loop}=  Evaluate  '${outer_index}' == '4' and '${inner_index}' == '7'

    IF  ${is_last_loop}
        Print Text To Eventlog               Internal service not responding is active so skipping waiting
    ELSE
        Print Step Text                      ${outer_index}.${inner_index}.5  Wait for BTS to recover
        Run Keyword and Continue On Failure  Wait For All Cells Up  time_limit=${WAIT_FOR_CELLS_UP}
        Run Keyword And Continue On Failure  Check Rmod Uptimes
    END

    IF  ${BTS_RESET} != ${True}
        Run Keyword And Continue On Failure      ALARMS.Add Allowed Alarm
        ...                                      severity=${SEVERITY}  alarm_id=${ALARM_ID}  fault_id=${FAULT_ID}
        ...                                      fault_name=${FAULT_NAME}
        Run Keyword And Continue On Failure      Common Postconditions
    END

    Print Step Text                      ${outer_index}.${inner_index}.6  Reset alarms and end-of-loop checks
    Run Keyword And Continue On Failure  Reset Alarms
    Run Keyword And Continue On Failure  Check If Unexpected Syslog Print  ${UNALLOWED_SYSLOGS}
    Run Keyword And Continue On Failure  Stop Background Syslog Print Search
    Wait Time And Reason                 60  Wait before starting the next loop

Simple Crash interface SOC from SMOD looped
    [Arguments]                       ${STEP}  ${SMOD}  ${APPLICATION}  ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_ALARM}
    ...                               ${ALL_CONTAINERS}  ${ONLY_FAULT_ID}

    Run Keyword And Continue On Failure  Crash interface looped inner loop  1  ${SMOD}  ${APPLICATION}  ${WAIT_FOR_CELLS_UP}
    ...                                  ${WAIT_FOR_ALARM}  ${ALL_CONTAINERS}  ${ONLY_FAULT_ID}  ${WAIT_FOR_ALARM}
    ${STEP}=                             Check If Step Smaller Or Same As Saved If Is Increase  ${STEP}
    Print Step Text                      ${STEP}  Check Postconditions and alarms
    Run Keyword And Continue On Failure  Common Postconditions
