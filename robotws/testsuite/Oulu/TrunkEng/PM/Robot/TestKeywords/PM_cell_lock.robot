*** Settings ***

Documentation
...   Author:   Pekka Lonnakko
...   Contact:  I_MN_RAN_RD_TV_TRUNK_OUL1_GMS <I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com>

Library     testsuite.Oulu.TrunkEng.PM.Python.Interfaces.PMCommonInterface      WITH NAME  PmCommon
Library     testsuite.Oulu.TrunkEng.PM.Python.Interfaces.PmCommissioningInterface      WITH NAME  PmCommissioning

*** Keywords ***

PM Cell Lock
    [Arguments]    ${CELL_TO_LOCK}  ${USED_RAT}  ${UPLOAD_INTERVAL}  ${MEAS_INTERVAL}  ${WAIT_BEFORE_LOCK}  ${WAIT_BEFORE_UNLOCK}
    Print Step Text                      1   Check Preconditions  automatic=${True}
    Run Keyword                              Common Preconditions
    Run Keyword And Continue On Failure      PmCommissioning.Update PM Data  period=${MEAS_INTERVAL}  interval=${UPLOAD_INTERVAL}
    Print Step Text                      2   Wait for next 15min interval  automatic=${True}
    Run Keyword And Continue On Failure      PmCommon.Wait For Interval
    Wait Time And Reason                     ${WAIT_BEFORE_LOCK}  before locking cell
    Print Step Text                      3   Lock cell ${CELL_TO_LOCK}  automatic=${True}
    ${cell_dist_name}=                       Get Cell DistName By LocalId  ${CELL_TO_LOCK}
    Run Keyword And Continue On Failure      ADMIN.Lock  dist_name=${cell_dist_name}  timeout=180  detailed_output=True
    @{FAULTY_CELL}=                          Create List  ${USED_RAT}Cell-${CELL_TO_LOCK}
    Run Keyword And Continue On Failure      Wait For Cells Faulty    600    ${FAULTY_CELL}
    Wait Time And Reason                     ${WAIT_BEFORE_UNLOCK}  before unlocking cell
    Print Step Text                      4   Unlock cell ${CELL_TO_LOCK}  automatic=${True}
    Run Keyword and Return Status            ADMIN.Unlock  dist_name=${cell_dist_name}  timeout=300    detailed_output=True
    Run Keyword and Return Status            Wait For All Cells Up  time_limit=${WAIT_FOR_CELLS_UP}
    Print Step Text                      5   Wait for next 15min interval  automatic=${True}
    Run Keyword And Continue On Failure      PmCommon.Wait For Interval
    Print Step Text                      6   Check PM File  automatic=${True}
    Run Keyword And Continue On Failure      PmCommon.Check Pm File  interval=${MEAS_INTERVAL}  upload_interval=${UPLOAD_INTERVAL}
    Print Step Text                      7   Check Postconditions  automatic=${True}
    Run Keyword And Continue On Failure      Common Postconditions
