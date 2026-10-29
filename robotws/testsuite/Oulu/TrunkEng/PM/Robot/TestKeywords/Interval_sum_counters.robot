*** Settings ***

Documentation
...   Author:   Essi Passoja
...   Contact:  I_MN_RAN_RD_TV_TRUNK_OUL1_GMS <I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com>

Library     testsuite.Oulu.TrunkEng.PM.Python.Interfaces.PMCommonInterface  WITH NAME  PmCommon
Library     testsuite.Oulu.TrunkEng.PM.Python.Interfaces.PmCommissioningInterface  WITH NAME  PmCommissioning

*** Keywords ***
Interval Sum Counters
    [Arguments]    ${UPLOAD_INTERVAL}  ${MEAS_INTERVAL}  ${SUM_COUNTERS}
    Print Step Text                      1   Check Preconditions  automatic=${True}
    Run Keyword And Continue On Failure      Common Preconditions
    Run Keyword And Continue On Failure      PmCommissioning.Update PM Data  period=${MEAS_INTERVAL}  interval=${UPLOAD_INTERVAL}
    Print Step Text                      2   Wait for next 60min interval  automatic=${True}
    Run Keyword And Continue On Failure      PmCommon.Wait For Interval  interval=${60}
    Print Step Text                      3   Make a data transfer test for UEs (20s)  automatic=${True}
    Run Keyword And Continue On Failure      Make Data Transfer Test  duration=20s
    Print Step Text                      4   Wait for the next interval, then check PM file  automatic=${True}
    Set Test Variable                        ${INTERVAL_CTR}  0
    Run Keyword And Continue On Failure      Repeat Keyword  4 times
    ...                                      Wait For Interval And Check PM File  ${UPLOAD_INTERVAL}  ${MEAS_INTERVAL}
    ...                                      ${SUM_COUNTERS}
    Print Step Text                      8   Check Postconditions  automatic=${True}
    Run Keyword And Continue On Failure      Common Postconditions

Wait For Interval And Check PM File
    [Arguments]    ${UPLOAD_INTERVAL}  ${MEAS_INTERVAL}  ${SUM_COUNTERS}
    Print Step Text                      5   Wait for the next 15min interval  automatic=${True}
    Run Keyword And Continue On Failure      PmCommon.Wait For Interval
    Print Step Text                      6   Make a data transfer test for UEs (20s)  automatic=${True}
    Run Keyword And Continue On Failure      Make Data Transfer Test  duration=20s
    Print Step Text                      7   Check PM File  automatic=${True}
    ${INTERVAL_CTR}=                         Evaluate  ${INTERVAL_CTR} + 15
    Set Test Variable                        ${INTERVAL_CTR}
    ${INTERVAL_COUNTERS}=                    python_helper.Safe Get From Dictionary  ${SUM_COUNTERS}  ${INTERVAL_CTR}
    Run Keyword And Continue On Failure      PmCommon.Check PM File  interval=${MEAS_INTERVAL}  upload_interval=${UPLOAD_INTERVAL}
    ...                                      counter_values=${INTERVAL_COUNTERS}
