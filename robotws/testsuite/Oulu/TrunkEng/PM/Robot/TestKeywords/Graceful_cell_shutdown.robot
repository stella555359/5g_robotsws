*** Settings ***

Documentation
...   Author:   Pekka Lonnakko
...   Contact:  I_MN_RAN_RD_TV_TRUNK_OUL1_GMS <I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com>

Library     Collections
Library     testsuite.Oulu.TrunkEng.PM.Python.Interfaces.PMCommonInterface      WITH NAME  PmCommon
Library     testsuite.Oulu.TrunkEng.PM.Python.Interfaces.PmCommissioningInterface      WITH NAME  PmCommissioning

*** Variables ***
&{state_dict_unlock}   administrativeState=unlocked  operationalState=enabled  blockingState=unblocked
&{state_dict_lock}     administrativeState=locked  availabilityStatus=off line  operationalState=disabled
                  ...  blockingState=unblocked
&{lnbts_commission}    shutdownStepAmount=16  shutdownWindow=180  enableGrflShdn=Enabled
&{pmax_dict}           pMax=390

*** Keywords ***

PM Graceful Cell Shutdown
    [Arguments]    ${SELECTED_CELL}  ${USED_RAT}  ${UPLOAD_INTERVAL}  ${MEAS_INTERVAL}  ${WAIT_BEFORE_LOCK}
    ...            ${WAIT_FOR_CELLS_UP}  ${GCS_LIMITS}
    Print Step Text                      1   Check Preconditions  automatic=${True}
    Run Keyword                              Common Preconditions
    ${cell_dist_name}=                       Get Cell DistName By LocalId  ${SELECTED_CELL}
    ${used_id}=                              Get Cell Used Id By Local Id  ${SELECTED_CELL}  ${USED_RAT}
    &{cell_dict}                             Create Dictionary  ${cell_dist_name}=${pmax_dict}
    Run Keyword And Continue On Failure      PmCommissioning.Update PM Data  period=${MEAS_INTERVAL}  interval=${UPLOAD_INTERVAL}
    ...                                      lnbts_dict=${lnbts_commission}  cell_dict=${cell_dict}
    &{cell_state_dict}                       Create Dictionary  All_cells=${state_dict_unlock}
    Print Step Text                      2   Wait for next 15min interval  automatic=${True}
    Run Keyword And Continue On Failure      PmCommon.Wait For Interval
    Wait Time And Reason                     ${WAIT_BEFORE_LOCK}  before shutting down cell
    Print Step Text                      3   Graceful cell shutdown for cell-${SELECTED_CELL}  automatic=${True}
    Run Keyword And Continue On Failure      GCS Procedure  ${cell_dist_name}
    Print Step Text                      4   Check alarms  automatic=${True}
    Run Keyword And Continue On Failure      Check Expected Alarms  wait_active_timeout=300
    Print Step Text                      5   Check cell states  automatic=${True}
    Remove From Dictionary                   ${cell_state_dict}  All_cells
    Set To Dictionary                        ${cell_state_dict}  ${USED_RAT}Cell-${used_id}  ${state_dict_lock}
    Run Keyword And Continue On Failure      Check Cell States  ${cell_state_dict}  states_of_other_cells=${state_dict_unlock}
    Print Step Text                      6   Wait 5 min before next interval  automatic=${True}
    Run Keyword And Continue On Failure      PmCommon.Wait For Interval  delta=${-300}
    Print Step Text                      7   Unlock cell ${SELECTED_CELL}  automatic=${True}
    Run Keyword And Continue On Failure      PmCommissioning.Unlock Cell  ${cell_dist_name}
    Run Keyword And Continue On Failure      Wait For All Cells Up  time_limit=${WAIT_FOR_CELLS_UP}
    Print Step Text                      8   Check alarm history  automatic=${True}
    Run Keyword And Continue On Failure      Check Alarm History
    Print Step Text                      9   Check cell states  automatic=${True}
    Set To Dictionary                        ${cell_state_dict}  ${USED_RAT}Cell-${used_id}  ${state_dict_unlock}
    Run Keyword And Continue On Failure      Check Cell States  ${cell_state_dict}  states_of_other_cells=${state_dict_unlock}
    Print Step Text                      10  Calculate M8020x Counters  automatic=${True}
    ${M8020X_counters}=                      PmCommon.Calculate M8020x Counters  ${used_id}  ${USED_RAT}  cell_locked=${True}
    Print Step Text                      11  Wait for next 15min interval  automatic=${True}
    Run Keyword And Continue On Failure      PmCommon.Wait For Interval
    Print Step Text                      12  Check GCS time  automatic=${True}
    Run Keyword And Continue On Failure      Check GCS time  ${used_id}  rat=${USED_RAT}  limits=${GCS_LIMITS}
    Print Step Text                      12  Check PM File  automatic=${True}
    Run Keyword And Continue On Failure      PmCommon.Check Pm File  interval=${MEAS_INTERVAL}  upload_interval=${UPLOAD_INTERVAL}
    ...                                      m8020_counters=${M8020X_counters}
    Print Step Text                      13  Check Postconditions  automatic=${True}
    Run Keyword And Continue On Failure      Common Postconditions
