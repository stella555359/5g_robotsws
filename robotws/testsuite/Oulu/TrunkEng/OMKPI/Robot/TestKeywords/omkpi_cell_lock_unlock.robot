*** Settings ***

Documentation
...   Author:   Terhi Talvitie
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Resource     testsuite/Oulu/TrunkEng/OMKPI/Robot/Resources/OMKPI_common.robot

*** Variables ***
&{state_dict_unlock}   administrativeState=unlocked  operationalState=enabled  blockingState=unblocked
&{state_dict_lock}     administrativeState=locked  availabilityStatus=off line  operationalState=disabled
                  ...  blockingState=unblocked

*** Keywords ***
Cell lock and unlock
    [Arguments]    ${CELL_TO_LOCK}  ${USED_RAT}  ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}

    Run Keyword And Continue On Failure   Start Syslog Print Search To Background  ${SYSLOG_LIST}
    Print Step Text                    1  Check Preconditions
    Run Keyword And Continue On Failure   Common Preconditions
    ${cell_dist_name}=                    Get Cell DistName By LocalId  ${CELL_TO_LOCK}
    ${used_id}=                           Get Cell Used Id By Local Id  ${CELL_TO_LOCK}  ${USED_RAT}
    Print Step Text                    2  Check cell states
    &{cell_state_dict}                    Create Dictionary  All_cells=${state_dict_unlock}
    Run Keyword And Continue On Failure   Check Cell States  ${cell_state_dict}
    Print Step Text                    3  Lock cell ${CELL_TO_LOCK}
    Run Keyword And Continue On Failure   ADMIN.Lock  dist_name=${cell_dist_name}  timeout=180  detailed_output=True
    @{FAULTY_CELL}=                       Create List  ${USED_RAT}Cell-${CELL_TO_LOCK}
    Run Keyword And Continue On Failure   Wait For Cells Faulty  600  ${FAULTY_CELL}
    Print Step Text                    4  Check alarms
    Run Keyword And Continue On Failure   Check Expected Alarms  wait_active_timeout=300
    Wait Time And Reason                  ${WAIT_CHECKS}  before checking cell states
    Print Step Text                   5   Check cell states
    Remove From Dictionary                ${cell_state_dict}  All_cells
    Set To Dictionary                     ${cell_state_dict}  ${USED_RAT}Cell-${used_id}  ${state_dict_lock}
    Run Keyword And Continue On Failure   Check Cell States  ${cell_state_dict}  states_of_other_cells=${state_dict_unlock}
    Print Step Text                   6   Unlock cell ${CELL_TO_LOCK}
    Run Keyword And Continue On Failure   ADMIN.Unlock  dist_name=${cell_dist_name}  timeout=300  detailed_output=True
    Run Keyword And Continue On Failure   Wait For All Cells Up  time_limit=${WAIT_FOR_CELLS_UP}
    Wait Time And Reason                  ${WAIT_CHECKS}  before checking alarm history
    Print Step Text                   7   Check alarm history
    Run Keyword And Continue On Failure   Check Alarm History
    Print Step Text                   8   Check cell states
    Set To Dictionary                     ${cell_state_dict}  ${USED_RAT}Cell-${used_id}  ${state_dict_unlock}
    Run Keyword And Continue On Failure   Check Cell States  ${cell_state_dict}
    ...                                   states_of_other_cells=${state_dict_unlock}
    Wait Time And Reason                  ${WAIT_CHECKS}  before checking post conditions
    Run Keyword And Continue On Failure   Check If Unexpected Syslog Print  ${UNALLOWED_SYSLOGS}
    Print Step Text                   9   Check Postconditions
    Run Keyword And Continue On Failure   Stop Background Syslog Print Search
    Run Keyword And Continue On Failure   Common Postconditions
    Print Step Text                   10  Collect KPIs
    Run Keyword and Continue On Failure   Collect KPIs  Cell lock and unlock  ${CELL_TO_LOCK}  ${USED_RAT}
    Run Keyword And Continue On Failure   Check Loop Kpi  Cell lock and unlock  ${OAM_KPI_TARGETS}

    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}  ${False}
