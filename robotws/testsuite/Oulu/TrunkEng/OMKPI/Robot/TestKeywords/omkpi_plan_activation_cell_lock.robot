*** Settings ***

Documentation
...   Author:   Pekka Lonnakko
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

*** Variables ***
&{state_dict_unlock}   administrativeState=unlocked  operationalState=enabled  blockingState=unblocked
&{state_dict_lock}     administrativeState=locked  availabilityStatus=off line  operationalState=disabled
                       ...  blockingState=unblocked

*** Keywords ***
Plan activation cell lock
    [Arguments]    ${CELL_TO_LOCK}  ${USED_RAT}  ${PARAMETER}  ${WAIT_FOR_CELLS_UP}   ${WAIT_CHECKS}
    ...            ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}

    Run Keyword And Continue On Failure   Start Syslog Print Search To Background     ${SYSLOG_LIST}
    Print Step Text                    1  Check Preconditions  automatic=${True}
    Run Keyword And Continue On Failure   Common Preconditions
    ${CELL_TO_LOCK}                       Set Variable  ${USED_RAT}Cell-${CELL_TO_LOCK}
    ${cell_dist_name}=                    Get Cell DistName By LocalId  ${CELL_TO_LOCK}
    ${distname}  ${par}  ${value}=        Run Keyword and Continue On Failure  Get Cell Locking Parameters  ${PARAMETER}
                                     ...  ${CELL_TO_LOCK}  ${cell_dist_name}
    ${init_value}=                        Run Keyword and Continue On Failure  Get Current Value  ${par}  distname=${distname}
    Run Keyword And Continue On Failure   Check Current Parameter  ${par}  ${value}  ${distname}  negative_output=${True}
    Print Step Text                    2  Check cell states  automatic=${True}
    &{cell_state_dict}                    Create Dictionary  All_cells=${state_dict_unlock}
    Run Keyword And Continue On Failure   Check Cell States  ${cell_state_dict}
    Print Step Text                    3  Lock cell by commissioning ${PARAMETER} for cell-${CELL_TO_LOCK}  automatic=${True}
    Run Keyword And Continue On Failure   Commission Value  ${par}  ${value}  ${distname}  sleep=${False}
    Print Step Text                    4  Wait for cells to be faulty  automatic=${True}
    @{FAULTY_CELL}=                       Create List  ${CELL_TO_LOCK}
    Run Keyword And Continue On Failure   Wait For Cells Faulty    600    ${FAULTY_CELL}
    Print Step Text                    5  Wait for all cells up  automatic=${True}
    Run Keyword And Continue On Failure   Wait For All Cells Up  time_limit=${WAIT_FOR_CELLS_UP}
    Print Step Text                    6  Check alarms  automatic=${True}
    Run Keyword And Continue On Failure   Check Expected Alarms   wait_active_timeout=300
    Wait Time And Reason                  ${WAIT_CHECKS}  before checking cell states
    Print Step Text                    7  Check cell states  automatic=${True}
    Run Keyword And Continue On Failure   Check Cell States  ${cell_state_dict}
    Print Step Text                    8  Check current parameter  automatic=${True}
    Run Keyword And Continue On Failure   Check Current Parameter  ${par}  ${value}  ${distname}
    Wait Time And Reason                  ${WAIT_CHECKS}  before checking alarm history
    Print Step Text                    9  Check alarm history  automatic=${True}
    Run Keyword And Continue On Failure   Check Alarm History
    Wait Time And Reason                  ${WAIT_CHECKS}  before checking post conditions
    Run Keyword And Continue On Failure   Check If Unexpected Syslog Print  ${UNALLOWED_SYSLOGS}
    Print Step Text                   10  Check Postconditions  automatic=${True}
    Run Keyword And Continue On Failure   Stop Background Syslog Print Search
    Run Keyword And Continue On Failure   Common Postconditions
    Print Step Text                   11  Collect KPIs  automatic=${True}
    Run Keyword and Continue On Failure   Collect KPIs  Cell plan activation  ${CELL_TO_LOCK}  ${USED_RAT}
    Run Keyword And Continue On Failure   Check Loop Kpi  Cell plan activation  ${OAM_KPI_TARGETS}
    Run Keyword And Continue On Failure   COLLECTLOGS.Collect Ims  ims_file=${EMPTY}  connection=log_admin  extra_name=CellPlanActivation_test
    Run Keyword And Continue On Failure   BTS.Reset Admin Connection
    Print Step Text                   12  Commission original values. This doesn't affect to result  automatic=${True}
    Run Keyword And Continue On Failure   Commission Value  ${par}  ${init_value}  ${distname}
    Run Keyword And Continue On Failure   Wait Time And Reason   ${180}   before checking ims history
    Print Step Text                   13  Check from ims2 history that ${CELL_TO_LOCK} are reset  automatic=${True}
    Run Keyword And Continue On Failure   Check If Selected Cells Were Disabled And Enabled  ${FAULTY_CELL}  rat=${USED_RAT}
#    Print Step Text                   13  Wait for cells to be faulty  automatic=${True}
#    Run Keyword And Continue On Failure   Wait For Cells Faulty    600    ${FAULTY_CELL}
#    Print Step Text                   14  Wait for all cells up  automatic=${True}
#    Run Keyword And Continue On Failure   Wait For All Cells Up  time_limit=${WAIT_FOR_CELLS_UP}
    Print Step Text                   14  Check current parameter  automatic=${True}
    Run Keyword And Continue On Failure   Check Current Parameter  ${par}  ${init_value}  ${distname}

    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}  ${False}
