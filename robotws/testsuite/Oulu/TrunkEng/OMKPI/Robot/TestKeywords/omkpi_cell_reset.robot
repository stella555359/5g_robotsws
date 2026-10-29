*** Settings ***

Documentation
...   Author:    Valtteri Lamberg
...   Contact:   I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com


*** Keywords ***
Cell reset
    [Arguments]  ${CELL_TO_RESET}  ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${SYSLOG_LIST}  ${USED_RAT}  ${UNALLOWED_SYSLOGS}  ${WAIT_CHECKS}

    Run Keyword And Continue On Failure   Start Syslog Print Search To Background  ${SYSLOG_LIST}
    Print Step Text                    1  Check Preconditions
    Run Keyword And Continue On Failure   Common Preconditions
    ${cell_dist_name}=                    Get Cell DistName By LocalId  ${CELL_TO_RESET}
    Print Step Text                    2  Reset cell ${CELL_TO_RESET}
    Run Keyword And Continue On Failure   ADMIN.Reset Cell  cell_id=${cell_dist_name}  timeout=180  detailed_output=True
    Run Keyword And Continue On Failure   Wait For All Cells Up  time_limit=${WAIT_FOR_CELLS_UP}
    Print Step Text                    3  Check alarm history
    Run Keyword And Continue On Failure   Check Alarm History
    Wait Time And Reason                  ${WAIT_CHECKS}  before checking post conditions
    Run Keyword And Continue On Failure   Check If Unexpected Syslog Print  ${UNALLOWED_SYSLOGS}
    Print Step Text                    4  Check from ims2 history that cells are reset
    @{FAULTY_CELL}=                       Create List  ${USED_RAT}Cell-${CELL_TO_RESET}
    Run Keyword And Continue On Failure   Check If Selected Cells Were Disabled And Enabled  ${FAULTY_CELL}  rat=${USED_RAT}
    Print Step Text                    5  Check Postconditions
    Run Keyword And Continue On Failure   Stop Background Syslog Print Search
    Run Keyword And Continue On Failure   Common Postconditions
    Print Step Text                    6  Collect KPIs
    Run Keyword and Continue On Failure   Collect KPIs  Cell reset  ${CELL_TO_RESET}  ${USED_RAT}
    Run Keyword And Continue On Failure   Check Loop Kpi  Cell reset  ${OAM_KPI_TARGETS}

    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}  ${False}
