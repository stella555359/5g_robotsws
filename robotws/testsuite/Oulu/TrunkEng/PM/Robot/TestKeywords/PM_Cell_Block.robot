*** Settings ***

Documentation
...   Author:   Pekka Lonnakko
...   Contact:  I_MN_RAN_RD_TV_TRUNK_OUL1_GMS <I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com>

Library     Collections
Library     testsuite.Oulu.TrunkEng.PM.Python.Interfaces.PMCommonInterface      WITH NAME  PmCommon
Library     testsuite.Oulu.TrunkEng.PM.Python.Interfaces.PmCommissioningInterface      WITH NAME  PmCommissioning

*** Variables ***
&{state_dict_unblock}   administrativeState=unlocked  operationalState=enabled  blockingState=unblocked
&{state_dict_block}     administrativeState=unlocked  availabilityStatus=off line  operationalState=disabled
                   ...  blockingState=blocked

*** Keywords ***

PM Cell Block
    [Arguments]    ${CELL_TO_BLOCK}  ${USED_RAT}  ${UPLOAD_INTERVAL}  ${MEAS_INTERVAL}  ${WAIT_BEFORE_BLOCK}
    ...            ${WAIT_FOR_CELLS_UP}
    Print Step Text                      1   Check Preconditions  automatic=${True}
    Run Keyword                              Common Preconditions
    Run Keyword And Continue On Failure      PmCommissioning.Update PM Data  period=${MEAS_INTERVAL}  interval=${UPLOAD_INTERVAL}
    &{cell_state_dict}                       Create Dictionary  All_cells=${state_dict_unblock}
    @{cells_in_alarm}=                       Parse Cell Information For Alarm  ${CELL_TO_BLOCK}
    Run Keyword And Continue On Failure      Check Cell States  ${cell_state_dict}
    FOR  ${cell}  IN  @{cells_in_alarm}
        Add Expected Alarm                   alarm_id=7653  fault_id=49  fault_name=Cell blocked  severity=Critical  unit_path=${cell}
    END
    Print Step Text                      2   Wait for next 15min interval  automatic=${True}
    Run Keyword And Continue On Failure      PmCommon.Wait For Interval
    Wait Time And Reason                     ${WAIT_BEFORE_BLOCK}  before blocking cell
    Print Step Text                      3   Block cell ${CELL_TO_BLOCK}  automatic=${True}
    ${cell_dist_name}=                       Get Cell DistName By LocalId  ${CELL_TO_BLOCK}
    Run Keyword And Continue On Failure      ADMIN.Block Cell  dist_name=${cell_dist_name}  timeout=180  detailed_output=True
    Print Step Text                      4   Check alarms  automatic=${True}
    Run Keyword And Continue On Failure      Check Expected Alarms  wait_active_timeout=300
    Print Step Text                      5   Check cell states  automatic=${True}
    Remove From Dictionary                   ${cell_state_dict}  All_cells
    Set To Dictionary                        ${cell_state_dict}  ${USED_RAT}Cell-${CELL_TO_BLOCK}  ${state_dict_block}
    Run Keyword And Continue On Failure      Check Cell States  ${cell_state_dict}  states_of_other_cells=${state_dict_unblock}
    Print Step Text                      6   Wait 5 min before next interval  automatic=${True}
    Run Keyword And Continue On Failure      PmCommon.Wait For Interval  delta=${-300}
    Print Step Text                      7   Unblock cell ${CELL_TO_BLOCK}  automatic=${True}
    Run Keyword And Continue On Failure      ADMIN.Unblock Cell  dist_name=${cell_dist_name}  timeout=300  detailed_output=True
    Run Keyword And Continue On Failure      Wait For All Cells Up  time_limit=${WAIT_FOR_CELLS_UP}
    Print Step Text                      8   Check alarm history  automatic=${True}
    Run Keyword And Continue On Failure      Check Alarm History
    Print Step Text                      9   Check cell states  automatic=${True}
    Set To Dictionary                        ${cell_state_dict}  ${USED_RAT}Cell-${CELL_TO_BLOCK}  ${state_dict_unblock}
    Run Keyword And Continue On Failure      Check Cell States  ${cell_state_dict}  states_of_other_cells=${state_dict_unblock}
    Print Step Text                      10  Calculate M8020x Counters  automatic=${True}
    ${M8020X_counters}=                      PmCommon.Calculate M8020x Counters  ${CELL_TO_BLOCK}  ${USED_RAT}
    Print Step Text                      11  Wait for next 15min interval  automatic=${True}
    Run Keyword And Continue On Failure      PmCommon.Wait For Interval
    Print Step Text                      12  Check PM File  automatic=${True}
    Run Keyword And Continue On Failure      PmCommon.Check Pm File  interval=${MEAS_INTERVAL}  upload_interval=${UPLOAD_INTERVAL}
    ...                                      m8020_counters=${M8020X_counters}
    Print Step Text                      13  Check Postconditions  automatic=${True}
    Run Keyword And Continue On Failure      Common Postconditions
