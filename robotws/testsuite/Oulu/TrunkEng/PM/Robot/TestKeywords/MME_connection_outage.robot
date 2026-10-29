*** Settings ***

Documentation
...   Author:   Pekka Lonnakko
...   Contact:  I_MN_RAN_RD_TV_TRUNK_OUL1_GMS <I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com>

Library     Collections
Library     testsuite.Oulu.TrunkEng.PM.Python.Interfaces.PMCommonInterface      WITH NAME  PmCommon
Library     testsuite.Oulu.TrunkEng.PM.Python.Interfaces.PmCommissioningInterface      WITH NAME  PmCommissioning

*** Variables ***
&{state_dict_unlock}   administrativeState=unlocked  operationalState=enabled  blockingState=unblocked
&{state_dict_lock}     administrativeState=unlocked  availabilityStatus=off line  operationalState=disabled
                  ...  blockingState=unblocked
&{lnbts_commission}    s1InducedCellDeactDelayTime=300

*** Keywords ***

PM MME Connection Outage
    [Arguments]    ${UPLOAD_INTERVAL}  ${MEAS_INTERVAL}  ${WAIT_FOR_CELLS_UP}  ${IGNORED_MEAS}  ${IGNORED_COUNTERS}
    ...            ${IGNORED_MEAS2}  ${IGNORED_COUNTERS2}
    Print Step Text                      1   Check Preconditions  automatic=${True}
    Run Keyword                              Common Preconditions
    Run Keyword And Continue On Failure      PmCommissioning.Update PM Data  period=${MEAS_INTERVAL}  interval=${UPLOAD_INTERVAL}
    ...                                      lnbts_dict=${lnbts_commission}
    Print Step Text                      2   Unlock MME  automatic=${True}
    Run Keyword And Continue On Failure      Unlock MME
    &{cell_state_dict}                       Create Dictionary  All_cells=${state_dict_unlock}
    Print Step Text                      3   Wait for next 15min interval  automatic=${True}
    Run Keyword And Continue On Failure      PmCommon.Wait For Interval  wait_after=0s
    Print Step Text                      4   Lock MME  automatic=${True}
    Run Keyword And Continue On Failure      Lock MME
    Print Step Text                      5   Check alarms  automatic=${True}
    Run Keyword And Continue On Failure      Check Expected Alarms  wait_active_timeout=300
    Print Step Text                      6   Check cell states  automatic=${True}
    Run Keyword And Continue On Failure      Check Cell States  ${cell_state_dict}
    Print Step Text                      7   Wait 12 min before next interval  automatic=${True}  # ~3min for MME to be locked
    Run Keyword And Continue On Failure      PmCommon.Wait For Interval  delta=${-720}  wait_after=0s
    Print Step Text                      8   Unlock MME  automatic=${True}
    Run Keyword And Continue On Failure      Unlock MME
    Print Step Text                      9   Wait for all cells up  automatic=${True}
    Run Keyword And Continue On Failure      Wait For All Cells Up  time_limit=${WAIT_FOR_CELLS_UP}
    Print Step Text                      10  Check alarm history  automatic=${True}
    Run Keyword And Continue On Failure      Check Alarm History
    Print Step Text                      11  Check cell states  automatic=${True}
    Run Keyword And Continue On Failure      Check Cell States  ${cell_state_dict}
    Print Step Text                      12  Wait for next 15min interval  automatic=${True}
    Run Keyword And Continue On Failure      PmCommon.Wait For Interval
    Print Step Text                      13  Check PM File  automatic=${True}
    ${M8020X_counters}=                      Run Keyword And Continue On Failure  PmCommon.Calculate M8020x MME Counters  occasion=1
    Run Keyword And Continue On Failure      PmCommon.Check Pm File  interval=${MEAS_INTERVAL}  upload_interval=${UPLOAD_INTERVAL}
    ...                                      m8020_counters=${M8020X_counters}
    Print Step Text                      14  Lock MME  automatic=${True}
    Run Keyword And Continue On Failure      Lock MME
    Wait Time And Reason                     360  until s1InducedCellDeactDelayTime has elapsed
    Print Step Text                      15  Check alarms  automatic=${True}
    Run Keyword And Continue On Failure      Check Expected Alarms  wait_active_timeout=300
    Print Step Text                      16  Check that cells are disabled  automatic=${True}
    Set To Dictionary                        ${cell_state_dict}  All_cells  ${state_dict_lock}
    Run Keyword And Continue On Failure      Check Cell States  ${cell_state_dict}
    Print Step Text                      17  Wait for next 15min interval  automatic=${True}
    Run Keyword And Continue On Failure      PmCommon.Wait For Interval
    Print Step Text                      18  Check PM File  automatic=${True}
    ${M8020X_counters}=                      Run Keyword And Continue On Failure  PmCommon.Calculate M8020x MME Counters  occasion=2
    Set Ignored Measurements And Counters    ${IGNORED_MEAS2}  ${IGNORED_COUNTERS2}
    Run Keyword And Continue On Failure      PmCommon.Check Pm File  interval=${MEAS_INTERVAL}  upload_interval=${UPLOAD_INTERVAL}
    ...                                      m8020_counters=${M8020X_counters}
    Wait Time And Reason                     60  before unlocking MME
    Print Step Text                      19  Unlock MME  automatic=${True}
    Run Keyword And Continue On Failure      Unlock MME
    Print Step Text                      20  Wait for all cells up  automatic=${True}
    Run Keyword And Continue On Failure      Wait For All Cells Up  time_limit=${WAIT_FOR_CELLS_UP}
    Print Step Text                      21  Check alarm history  automatic=${True}
    Run Keyword And Continue On Failure      Check Alarm History
    Print Step Text                      22  Check cell states  automatic=${True}
    Set To Dictionary                        ${cell_state_dict}  All_cells  ${state_dict_unlock}
    Run Keyword And Continue On Failure      Check Cell States  ${cell_state_dict}
    Print Step Text                      23  Wait for next 15min interval  automatic=${True}
    Run Keyword And Continue On Failure      PmCommon.Wait For Interval
    Print Step Text                      24  Check PM File  automatic=${True}
    ${M8020X_counters}=                      Run Keyword And Continue On Failure  PmCommon.Calculate M8020x MME Counters  occasion=3
    Set Ignored Measurements And Counters    ${IGNORED_MEAS}  ${IGNORED_COUNTERS}
    Run Keyword And Continue On Failure      PmCommon.Check Pm File  interval=${MEAS_INTERVAL}  upload_interval=${UPLOAD_INTERVAL}
    ...                                      m8020_counters=${M8020X_counters}
    Print Step Text                      25  Check Postconditions  automatic=${True}
    Run Keyword And Continue On Failure      Common Postconditions
