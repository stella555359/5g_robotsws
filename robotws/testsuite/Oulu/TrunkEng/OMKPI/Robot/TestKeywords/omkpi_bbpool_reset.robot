*** Settings ***

Documentation
...   Author:   Terhi Talvitie
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

*** Variables ***
&{state_dict_unblock}     administrativeState=unlocked  operationalState=enabled  blockingState=unblocked
${BBPOOL_RESET_TIMEOUT}   300

*** Keywords ***
Reset BBPool
    [Documentation]    Makes pre checks, resets BBPool given by user and after reset checks that everything has worked as expected
    [Arguments]    ${BBPOOL_TO_RESET}  ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}
    ...            ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}

    Run Keyword And Continue On Failure   Start Syslog Print Search To Background  ${SYSLOG_LIST}
    Print Step Text                    1  Check Preconditions
    Run Keyword And Continue On Failure   Common Preconditions
    ${CELLS_OF_BBPOOL}  ${SOCS_OF_BBPOOL}=  Get Cell IDs And Socs Of BBPool  ${BBPOOL_TO_RESET}
    ${BBPOOL}=                            Get BBPool From User Given Values  ${BBPOOL_TO_RESET}
    Run Keyword And Continue On Failure   Check Correct BBPool  ${BBPOOL_TO_RESET}  ${CELLS_OF_BBPOOL}
    ${START_TIME}=                        Get Start Time
    Print Step Text                    2  Reset ${BBPOOL_TO_RESET}
    Print Text To Eventlog                Request reset to ${BBPOOL_TO_RESET} (${BBPOOL})
    # Run Keyword And Continue On Failure   ADMIN.Reset BBPool  ${BBPOOL}  timeout=300
    Run Keyword And Continue On Failure   Perform Bbpool Reset  ${BBPOOL}  timeout=${BBPOOL_RESET_TIMEOUT}
    Print Step Text                    3  Wait for all cells up max ${WAIT_FOR_CELLS_UP} seconds
    Run Keyword And Continue On Failure   Wait For All Cells Up  time_limit=${WAIT_FOR_CELLS_UP}
    Print Step Text                    4  Check cell states
    &{cell_state_dict}                    Create Dictionary  All_cells=${state_dict_unblock}
    Run Keyword And Continue On Failure   Check Cell States  ${cell_state_dict}
    Wait Time And Reason                  ${WAIT_CHECKS}  before checking post conditions
    Run Keyword And Continue On Failure   Check If Unexpected Syslog Print  ${UNALLOWED_SYSLOGS}
    Print Step Text                    5  Check from history that cells of ${BBPOOL_TO_RESET} were Disabled and Enabled
    Run Keyword And Continue On Failure   Check If Selected Cells Were Disabled And Enabled  ${CELLS_OF_BBPOOL}
    Print Step Text                    6  Check Postconditions
    Run Keyword And Continue On Failure   Stop Background Syslog Print Search
    Run Keyword And Continue On Failure   Check If Bbmod reset And Change Kpi target
    Run Keyword And Continue On Failure   Common Postconditions
    Print Step Text                    7  Collect KPIs
    Run Keyword and Continue On Failure   Collect KPIs  BBPool reset
    Run Keyword And Continue On Failure   Check Loop Kpi  BBPool reset  ${OAM_KPI_TARGETS}
    Run Keyword And Continue On Failure   Check Max Bbpool Duration  ${BBPOOL_TO_RESET}  ${START_TIME}  ${SOCS_OF_BBPOOL}
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}  ${False}
