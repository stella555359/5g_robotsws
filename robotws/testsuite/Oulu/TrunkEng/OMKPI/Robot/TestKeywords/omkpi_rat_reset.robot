*** Settings ***

Documentation
...   Author:   Terhi Talvitie
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

*** Variables ***
&{state_dict_unblock}    administrativeState=unlocked  operationalState=enabled  blockingState=unblocked

*** Keywords ***
Rat Reset
    [Arguments]    ${RAT_TO_RESET}  ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}  ${RESET_TYPE}  ${KPI}

    ${KPIS}=                              Create Dictionary
    ${CELLS_OF_RAT}=                      Get Cells Of RAT  ${RAT_TO_RESET}
    Run Keyword And Continue On Failure   Start Syslog Print Search To Background     ${SYSLOG_LIST}
    Print Step Text                    1  Check Preconditions
    Run Keyword And Continue On Failure   Common Preconditions
    Run Keyword And Continue On Failure   Commission RAT Reset Enhancement    ${RAT_TO_RESET}  ${KPI}
    Print Step Text                    2  Reset RAT ${RAT_TO_RESET}
    Print Text To Eventlog                Request rat reset
    Run Keyword And Continue On Failure   ADMIN.Rat Reset  rat_type=${RAT_TO_RESET}  timeout=600  reset_type=${RESET_TYPE}
    Run Keyword And Continue On Failure   Wait For Cells Faulty  600  ${CELLS_OF_RAT}
    Print Step Text                    3  Wait For All Cells Up max ${WAIT_FOR_CELLS_UP} seconds
    Run Keyword And Continue On Failure   Wait For All Cells Up  time_limit=${WAIT_FOR_CELLS_UP}
    Print Step Text                    4  Check alarm history
    Run Keyword And Continue On Failure   Check Alarm History  reset_alarms=True
    Print Step Text                    5  Check cell states
    &{cell_state_dict}                    Create Dictionary  All_cells=${state_dict_unblock}
    Run Keyword And Continue On Failure   Check Cell States  ${cell_state_dict}
    Wait Time And Reason                  ${WAIT_CHECKS}  before checking post conditions
    Run Keyword And Continue On Failure   Check If Unexpected Syslog Print  ${UNALLOWED_SYSLOGS}
    Print Step Text                    6  Check from history that DSPs were reseted
    Run Keyword And Continue On Failure   Check that DSPs Were Resetting  rat=${RAT_TO_RESET}
    Print Step Text                    7  Check Postconditions
    Run Keyword And Continue On Failure   Stop Background Syslog Print Search
    Run Keyword And Continue On Failure   Common Postconditions
    Print Step Text                    8  Collect KPIs
    Run Keyword and Continue On Failure   Collect KPIs  Rat reset ${RAT_TO_RESET} ${KPI}
    Run Keyword And Continue On Failure   Check Loop KPI  Rat reset ${RAT_TO_RESET} ${KPI}  ${OAM_KPI_TARGETS}

    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}  ${False}
