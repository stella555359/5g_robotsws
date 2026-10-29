*** Settings ***

Documentation
...   Author:   Pekka Lonnakko
...   Contact:  I_MN_RAN_RD_TV_TRUNK_OUL1_GMS <I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com>

Library     testsuite.Oulu.TrunkEng.PM.Python.Interfaces.PMCommonInterface      WITH NAME  PmCommon
Library     testsuite.Oulu.TrunkEng.PM.Python.Interfaces.PmCommissioningInterface      WITH NAME  PmCommissioning

*** Keywords ***

PM First Intermediate Period
    [Arguments]    ${UPLOAD_INTERVAL}  ${MEAS_INTERVAL}  ${WAIT_FOR_CELLS_UP}
    Print Step Text                      1   Check Preconditions  automatic=${True}
    Run Keyword                              Common Preconditions
    Run Keyword And Continue On Failure      PmCommissioning.Update PM Data  period=${MEAS_INTERVAL}  interval=${UPLOAD_INTERVAL}
    Print Step Text                      2   Wait for next 15min interval  automatic=${True}
    Run Keyword And Continue On Failure      PmCommon.Wait For Interval
    Print Step Text                      3   Perform site reset  automatic=${True}
    Run Keyword and Continue On Failure      ADMIN.Reset Site  detailed_output=True
    Print Step Text                      4   Wait for all cells up  automatic=${True}
    Run Keyword and Return Status            Wait For All Cells Up  time_limit=${WAIT_FOR_CELLS_UP}
    Print Step Text                      5   Wait for next 15min interval  automatic=${True}
    Run Keyword And Continue On Failure      PmCommon.Wait For Interval
    Print Step Text                      6   Check PM File  automatic=${True}
    Run Keyword And Continue On Failure      PmCommon.Check Pm File  interval=${MEAS_INTERVAL}  upload_interval=${UPLOAD_INTERVAL}
                                             ...  intermediate=${True}
    Print Step Text                      7   Check Postconditions  automatic=${True}
    Run Keyword And Continue On Failure      Common Postconditions
