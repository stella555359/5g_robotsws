*** Settings ***

Documentation
...   Author:   Terhi Talvitie
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

*** Keywords ***
Remote power reset
    [Arguments]    ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}  ${WAIT_CHECKS}  ${RESET_WITH_SNAPSHOT}  ${WAIT_FOR_CELLS_UP}  ${OAM_KPI_TARGETS}

    ${KPIS}=                              Create Dictionary
    Run Keyword And Continue On Failure   Start Syslog Print Search To Background  ${SYSLOG_LIST}
    Print Step Text                    1  Check Preconditions
    Run Keyword And Continue On Failure   Common Preconditions
#    Run Keyword And Continue On Failure   Check If Netboot Is Active And Deactivate It
    # Run Keyword And Continue On Failure   Check If Graceful Cell Shutdown
    Print Step Text                    2  Make remote power reset
    Print Text To Eventlog                Request remote power reset
    Run Keyword And Continue On Failure   ADMIN.Power Reset  reset_with_snapshot=${RESET_WITH_SNAPSHOT}  wait_for_reconnection=${True}
    ...                                   timeout=1200  detailed_output=${True}  connection=log_admin
    Run Keyword And Continue On Failure   Wait For Cells Faulty    600
    Print Step Text                    3  Wait for all cells up
    Run Keyword And Continue On Failure   Wait For All Cells Up  time_limit=${WAIT_FOR_CELLS_UP}
#    Print Step Text                    4  Check from history that SMOD, RMODs and BBMODs were reseted
#    Run Keyword And Continue On Failure   Check SMOD RMOD And BBMOD States
    Wait Time And Reason                  ${WAIT_CHECKS}  before checking post conditions
    Print Step Text                    4  Check Postconditions
    Run Keyword And Continue On Failure   Check If Unexpected Syslog Print  ${UNALLOWED_SYSLOGS}
    Run Keyword And Continue On Failure   Stop Background Syslog Print Search
    Run Keyword And Continue On Failure   Common Postconditions
    Print Step Text                    5  Collect KPIs
    Run Keyword and Continue On Failure   Collect KPIs  Remote power reset
    Run Keyword And Continue On Failure   Check Loop Kpi  Remote power reset  ${OAM_KPI_TARGETS}
    Print Step Text                    6  Print extra KPIs
    Run Keyword And Continue On Failure   Print Extra KPIs  Remote power reset

    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}  ${False}
