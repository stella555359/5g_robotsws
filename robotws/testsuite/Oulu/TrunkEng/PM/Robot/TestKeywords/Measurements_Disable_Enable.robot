*** Settings ***

Documentation
...   Author:   Pekka Lonnakko
...   Contact:  I_MN_RAN_RD_TV_TRUNK_OUL1_GMS <I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com>

Library     testsuite.Oulu.TrunkEng.PM.Python.Interfaces.PMCommonInterface      WITH NAME  PmCommon
Library     testsuite.Oulu.TrunkEng.PM.Python.Interfaces.PmCommissioningInterface      WITH NAME  PmCommissioning


*** Keywords ***

Measurements Disable And Enable
    [Arguments]    ${UPLOAD_PERIOD}  ${MEAS_INTERVAL}  ${DISABLED_MEASUREMENTS}
    Print Step Text                      1   Check Preconditions  automatic=${True}
    Run Keyword and Continue On Failure      Common Preconditions
    Run Keyword And Continue On Failure      PmCommissioning.Update PM Data  period=${UPLOAD_PERIOD}  interval=${MEAS_INTERVAL}
    Print Step Text                      2   Wait for next ${UPLOAD_PERIOD}min interval to start test  automatic=${True}
    Run Keyword And Continue On Failure      PmCommon.Wait For Interval
    Print Step Text                      3   Wait for next ${UPLOAD_PERIOD}min interval  automatic=${True}
    Run Keyword And Continue On Failure      PmCommon.Wait For Interval
    Print Step Text                      4   Check PM File  automatic=${True}
    Run Keyword And Continue On Failure      PmCommon.Check Pm File  interval=${MEAS_INTERVAL}  upload_interval=${UPLOAD_PERIOD}
    Print Step Text                      5   Wait 10min before next interval  automatic=${True}
    Run Keyword And Continue On Failure      PmCommon.Wait For Interval  delta=${-600}
    Print Step Text                      6   Time to change measurement intervals  automatic=${True}
    Run Keyword And Continue On Failure      PmCommissioning.Update PM Data  period=${UPLOAD_PERIOD}  interval=${MEAS_INTERVAL}
    ...                                      meas_intervals=${DISABLED_MEASUREMENTS}
    Print Step Text                      7   Wait for next ${UPLOAD_PERIOD}min interval  automatic=${True}
    Run Keyword And Continue On Failure      PmCommon.Wait For Interval
    Print Step Text                      8   Check PM File  automatic=${True}
    Run Keyword And Continue On Failure      PmCommon.Check Pm File  interval=${MEAS_INTERVAL}  upload_interval=${UPLOAD_PERIOD}
    ...                                      incomplete_intervals=${False}  measurements_disabled=${True}
    Print Step Text                      9   Wait for next ${UPLOAD_PERIOD}min interval  automatic=${True}
    Run Keyword And Continue On Failure      PmCommon.Wait For Interval  interval=${UPLOAD_PERIOD}
    Print Step Text                      10  Check PM File  automatic=${True}
    Run Keyword And Continue On Failure      PmCommon.Check Pm File  interval=${MEAS_INTERVAL}  upload_interval=${UPLOAD_PERIOD}
    ...                                      incomplete_intervals=${False}  measurements_disabled=${True}
    Print Step Text                      11  Wait 10min before next interval  automatic=${True}
    Run Keyword And Continue On Failure      PmCommon.Wait For Interval  delta=${-600}
    Print Step Text                      12  Update PM data back to 15min  automatic=${True}
    ${15min_measurements}=                   PmCommissioning.Set All Values To  ${15}  ${DISABLED_MEASUREMENTS}
    Run Keyword And Continue On Failure      PmCommissioning.Update PM Data  period=${15}  interval=${15}
    ...                                      meas_intervals=${15min_measurements}
    Print Step Text                      13  Wait for next ${UPLOAD_PERIOD}min interval  automatic=${True}
    Run Keyword And Continue On Failure      PmCommon.Wait For Interval  interval=${UPLOAD_PERIOD}
    Print Step Text                      14  Check PM File  automatic=${True}
    Run Keyword And Continue On Failure      PmCommon.Check Pm File  interval=${MEAS_INTERVAL}  upload_interval=${UPLOAD_PERIOD}
    ...                                      incomplete_intervals=${True}  measurements_disabled=${False}
    Print Step Text                      15  Wait for next ${UPLOAD_PERIOD}min interval  automatic=${True}
    Run Keyword And Continue On Failure      PmCommon.Wait For Interval  interval=${UPLOAD_PERIOD}
    Print Step Text                      16  Check PM File  automatic=${True}
    Run Keyword And Continue On Failure      PmCommon.Check Pm File  interval=${UPLOAD_PERIOD}  upload_interval=${UPLOAD_PERIOD}
    Print Step Text                      17  Check Postconditions  automatic=${True}
    Run Keyword And Continue On Failure      Common Postconditions
