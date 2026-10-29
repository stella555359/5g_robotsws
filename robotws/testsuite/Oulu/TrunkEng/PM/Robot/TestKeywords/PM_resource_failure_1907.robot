*** Settings ***
Documentation
...     Author:     Valtteri Lamberg
...     Contact:    I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com


Library     Collections
Library     testsuite.Oulu.TrunkEng.PM.Python.Interfaces.PMCommonInterface      WITH NAME  PmCommon
Library     testsuite.Oulu.TrunkEng.PM.Python.Interfaces.PmCommissioningInterface      WITH NAME  PmCommissioning
Library     testsuite.Oulu.TrunkEng.RecoveryAndAlarms.Python.Interfaces.FaultingRmod    WITH NAME  FaultingRmod

*** Keywords ***
PM resource failure 1907
    [Arguments]    ${SELECTED_CELL}  ${USED_RAT}  ${MEAS_INTERVAL}  ${UPLOAD_INTERVAL}  ${RMOD}  ${WAIT_FOR_CELLS_UP}

    Print Step Text                             1  Check Preconditions
    Run Keyword And Continue On Failure            Common Preconditions
    ${RMOD_OBJ}                                    Get RMOD Object From User Given Values  ${RMOD}
    Run Keyword And Continue On Failure            PmCommissioning.Update PM Data  period=${MEAS_INTERVAL}
    ...                                            interval=${UPLOAD_INTERVAL}
    Run Keyword And Continue On Failure            PmCommon.Add Expected Alarm Based On Number Of Cells  r1
    Print Step Text                             2  Wait for next 15min interval
    Run Keyword And Continue On Failure            PmCommon.Wait For Interval
    Print Step Text                             3  Send fault 1907 to RMOD
    Run Keyword And Continue On Failure            FaultingRmod.Raise Fault To Rmod   1907  ${RMOD_OBJ}  TX1  False
    Run Keyword And Continue On Failure            PmCommon.Check Cells And Clear Fault 1907  r1
    Print Step Text                             4  Wait For All Cells Up max ${WAIT_FOR_CELLS_UP} seconds
    Run Keyword And Continue On Failure            Wait For All Cells Up  time_limit=${WAIT_FOR_CELLS_UP}
    Print Step Text                             5  Check alarm history
    Run Keyword And Continue On Failure            Check Alarm History
    Print Step Text                             6  Wait for next 15min interval
    Run Keyword And Continue On Failure            PmCommon.Wait For Interval
    Print Step Text                             7  Calculate M8020x Counters
    ${M8020X_counters}=                            PmCommon.Calculate 1907 M8020x Counters  ${SELECTED_CELL}  ${USED_RAT}
    Print Step Text                             8  Check PM File
    Run Keyword And Continue On Failure            PmCommon.Check Pm File  interval=${MEAS_INTERVAL}  upload_interval=${UPLOAD_INTERVAL}
    ...                                            m8020_counters=${M8020X_counters}
    Print Step Text                             9  Check Postconditions
    Run Keyword And Continue On Failure            Common Postconditions

    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}  ${False}

