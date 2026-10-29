*** Settings ***

Documentation
...   Author:   Terhi Talvitie
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

*** Variables ***
&{state_dict_unblock}    administrativeState=unlocked  operationalState=enabled  blockingState=unblocked

*** Keywords ***
Reset FHS
    [Arguments]    ${FHS_TO_RESET}  ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}

    ${KPIS}=                              Create Dictionary
    Run Keyword And Continue On Failure   Start Syslog Print Search To Background     ${SYSLOG_LIST}
    Print Step Text                    1  Check Preconditions
    Run Keyword And Continue On Failure   Common Preconditions
    ${FHS}=                               Get FHS From User Selection  ${FHS_TO_RESET}
    Print Step Text                    2  Reset ${FHS_TO_RESET}
    Print Text To Eventlog                Request warm reset to ${FHS_TO_RESET} (${FHS})
    Run Keyword And Continue On Failure   ADMIN.Reset Unit  dist_name=${FHS}  reset_type=Warm  timeout=600  detailed_output=True
    Print Step Text                    3  Wait For All Cells Up max ${WAIT_FOR_CELLS_UP} seconds
    Run Keyword And Continue On Failure   Wait For All Cells Up  time_limit=${WAIT_FOR_CELLS_UP}
    Print Step Text                    4  Check cell states
    &{cell_state_dict}                    Create Dictionary  All_cells=${state_dict_unblock}
    Run Keyword And Continue On Failure   Check If Selected Cells Were Disabled And Enabled  all_cells=${True}
    Run Keyword And Continue On Failure   Check Cell States  ${cell_state_dict}
    Wait Time And Reason                  ${WAIT_CHECKS}  before checking post conditions
    Run Keyword And Continue On Failure   Check If Unexpected Syslog Print  ${UNALLOWED_SYSLOGS}
    Print Step Text                    5  Check from history that FHS and RMODs were reseted
    Run Keyword And Continue On Failure   Check That Fhs And Rmods Were Reset
    Print Step Text                    6  Check Postconditions
    Run Keyword And Continue On Failure   Stop Background Syslog Print Search
    Run Keyword And Continue On Failure   Common Postconditions
    Print Step Text                    7  Collect KPIs
    Run Keyword and Continue On Failure   Collect KPIs  FHS reset
    Run Keyword And Continue On Failure   Check Loop Kpi  FHS reset  ${OAM_KPI_TARGETS}

    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}  ${False}
