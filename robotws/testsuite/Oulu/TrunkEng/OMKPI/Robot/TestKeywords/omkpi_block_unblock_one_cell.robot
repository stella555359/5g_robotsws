*** Settings ***

Documentation
...   Author:   Terhi Talvitie
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

*** Variables ***
&{state_dict_unblock}   administrativeState=unlocked  operationalState=enabled  blockingState=unblocked
&{state_dict_block}     administrativeState=unlocked  availabilityStatus=off line  operationalState=disabled
                   ...  blockingState=blocked

*** Keywords ***
Block unblock cell
    [Arguments]   ${CELL_TO_BLOCK}  ${USED_RAT}  ${WAIT_FOR_CELLS_UP}   ${WAIT_CHECKS}
    ...           ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}

    Run Keyword And Continue On Failure   Start Syslog Print Search To Background  ${SYSLOG_LIST}
    Print Step Text                    1  Check Preconditions
    Run Keyword And Continue On Failure   Common Preconditions
    ${cell_dist_name}=                    Get Cell DistName By LocalId  ${CELL_TO_BLOCK}
    @{cells_in_alarm}=                    Parse Cell Information For Alarm  ${cell_dist_name}
    ${used_id}=                           Get Cell Used Id By Local Id  ${CELL_TO_BLOCK}  ${USED_RAT}
    Print Step Text                    2  Check cell states
    &{cell_state_dict}                    Create Dictionary  All_cells=${state_dict_unblock}
    Run Keyword And Continue On Failure   Check Cell States  ${cell_state_dict}
    FOR  ${cell}  IN  @{cells_in_alarm}
        Add Expected Alarm                alarm_id=7653  fault_id=49  fault_name=Cell blocked  severity=Critical  unit_path=${cell}
    END
    Print Step Text                    3  Block cell ${CELL_TO_BLOCK}
    Run Keyword And Continue On Failure   ADMIN.Block Cell  dist_name=${cell_dist_name}  timeout=180  detailed_output=True
    Print Step Text                    4  Check alarms
    Run Keyword And Continue On Failure   Check Expected Alarms  wait_active_timeout=300
    Wait Time And Reason                  ${WAIT_CHECKS}  before checking cell states
    Print Step Text                    5  Check cell states
    Remove From Dictionary                ${cell_state_dict}  All_cells
    Set To Dictionary                     ${cell_state_dict}  ${USED_RAT}Cell-${used_id}  ${state_dict_block}
    Run Keyword And Continue On Failure   Check Cell States  ${cell_state_dict}  states_of_other_cells=${state_dict_unblock}
    Print Step Text                    6  Unblock cell ${CELL_TO_BLOCK}
    Run Keyword And Continue On Failure   ADMIN.Unblock Cell  dist_name=${cell_dist_name}  timeout=300  detailed_output=True
    Run Keyword And Continue On Failure   Wait For All Cells Up  time_limit=${WAIT_FOR_CELLS_UP}
    Wait Time And Reason                  ${WAIT_CHECKS}  before checking alarm history
    Print Step Text                    7  Check alarm history
    Run Keyword And Continue On Failure   Check Alarm History
    Print Step Text                    8  Check cell states
    Set To Dictionary                     ${cell_state_dict}  ${USED_RAT}Cell-${used_id}  ${state_dict_unblock}
    Run Keyword And Continue On Failure   Check Cell States  ${cell_state_dict}  states_of_other_cells=${state_dict_unblock}
    Wait Time And Reason                  ${WAIT_CHECKS}  before checking post conditions
    Run Keyword And Continue On Failure   Check If Unexpected Syslog Print  ${UNALLOWED_SYSLOGS}
    Print Step Text                    9  Check Postconditions
    Run Keyword And Continue On Failure   Stop Background Syslog Print Search
    Run Keyword And Continue On Failure   Common Postconditions
    Print Step Text                   10  Collect KPIs
    Run Keyword and Continue On Failure   Collect KPIs  Cell block and unblock  ${CELL_TO_BLOCK}  ${USED_RAT}
    Run Keyword And Continue On Failure   Check Loop Kpi  Cell block and unblock  ${OAM_KPI_TARGETS}

    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}  ${False}

