*** Settings ***

Documentation
...   Author:   Pekka Lonnakko
...   Contact:  I_MN_RAN_RD_TV_TRUNK_OUL1_GMS <I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com>

Library     testsuite.Oulu.TrunkEng.PM.Python.Interfaces.PMCommonInterface      WITH NAME  PmCommon
Library     testsuite.Oulu.TrunkEng.PM.Python.Interfaces.PmCommissioningInterface      WITH NAME  PmCommissioning

*** Keywords ***

Measurement Period 15min
    [Arguments]    ${UPLOAD_INTERVAL}  ${MEAS_INTERVAL}
    Print Step Text                      1   Check Preconditions  automatic=${True}
    Run Keyword                              Common Preconditions
    Run Keyword And Continue On Failure      PmCommissioning.Update PM Data  period=${MEAS_INTERVAL}  interval=${UPLOAD_INTERVAL}
    Print Step Text                      2   Wait for next 15min interval  automatic=${True}
    Run Keyword And Continue On Failure      PmCommon.Wait For Interval
    Run Keyword And Continue On Failure      Repeat Keyword  2 times
    ...                                      Wait For Interval And Check PM File  ${UPLOAD_INTERVAL}  ${MEAS_INTERVAL}
    Print Step Text                      7   Check Postconditions  automatic=${True}
    Run Keyword And Continue On Failure      Common Postconditions

Wait For Interval And Check PM File
    [Arguments]    ${UPLOAD_INTERVAL}  ${MEAS_INTERVAL}
    Print Step Text                      3   Wait for next 15min interval  automatic=${True}
    Run Keyword And Continue On Failure      PmCommon.Wait For Interval
    Print Step Text                      4   Check PM File  automatic=${True}
    Run Keyword And Continue On Failure      PmCommon.Check Pm File  interval=${MEAS_INTERVAL}  upload_interval=${UPLOAD_INTERVAL}
