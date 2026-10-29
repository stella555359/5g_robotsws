*** Settings ***

Documentation
...   Author:   Terhi Talvitie
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com


*** Variables ***
&{state_dict_unblock}    administrativeState=unlocked  operationalState=enabled  blockingState=unblocked

*** Keywords ***
Reset BBMOD
    [Arguments]    ${BBMOD_TO_RESET}  ${RESET_TYPE}  ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${SYSLOG_LIST}
    ...            ${UNALLOWED_SYSLOGS}  ${OAM_KPI_TARGETS}

    ${KPIS}=                              Create Dictionary
    Run Keyword And Continue On Failure   Start Syslog Print Search To Background     ${SYSLOG_LIST}
    Print Step Text                    1  Check Preconditions
    Run Keyword And Continue On Failure   Common Preconditions
    ${BBMOD_OBJ}=                         Get BBMOD Object From User Given Values    ${BBMOD_TO_RESET}
    ${rmod_list}=                         Get RMODs Connected to BBMOD  ${BBMOD_OBJ.name}  remove_multifibre=${True}
    ${cells}=                             Get Cells Of Bbmod  ${BBMOD_OBJ.name}
    Print Step Text                    2  Reset ${BBMOD_TO_RESET}
    Print Text To Eventlog                Request ${RESET_TYPE} to ${BBMOD_OBJ.scf_dist_name} (${BBMOD_OBJ.name})
    Run Keyword And Continue On Failure   ADMIN.Reset Unit  dist_name=${BBMOD_OBJ.scf_dist_name}
    ...                                   reset_type=${RESET_TYPE}  timeout=300  detailed_output=True
    Print Step Text                    3  Wait For All Cells Up max ${WAIT_FOR_CELLS_UP} seconds
    Run Keyword And Continue On Failure   Wait For All Cells Up  time_limit=${WAIT_FOR_CELLS_UP}
    Print Step Text                    4  Check alarm history
    Run Keyword And Continue On Failure   Check Alarm History  reset_alarms=True
    Print Step Text                    5  Check cell states
    &{cell_state_dict}                    Create Dictionary  All_cells=${state_dict_unblock}
    Run Keyword And Continue On Failure   Check Cell States  ${cell_state_dict}
    Wait Time And Reason                  ${WAIT_CHECKS}  before checking post conditions
    Run Keyword And Continue On Failure   Check If Unexpected Syslog Print  ${UNALLOWED_SYSLOGS}
    Print Step Text                    6  Check Postconditions
    Run Keyword And Continue On Failure   Stop Background Syslog Print Search
    Run Keyword And Continue On Failure   Common Postconditions
    Print Step Text                    7  Collect KPIs
    Run Keyword And Continue On Failure   Check If Selected Units Were Reset
    ...                                   selected_bbmods=${BBMOD_OBJ.name}  selected_rmods=${rmod_list}  selected_cells=${cells}
    Run Keyword and Continue On Failure   Collect KPIs  BBMOD ${RESET_TYPE}
    Run Keyword And Continue On Failure   Check Loop Kpi  BBMOD ${RESET_TYPE}  ${OAM_KPI_TARGETS}  cells=${cells}

    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}  ${False}
