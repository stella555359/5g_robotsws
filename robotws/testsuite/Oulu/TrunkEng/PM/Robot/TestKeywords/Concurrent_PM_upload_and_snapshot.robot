*** Settings ***

Documentation
...   Author:   Pekka Lonnakko
...   Contact:  I_MN_RAN_RD_TV_TRUNK_OUL1_GMS <I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com>

Library     testsuite.Oulu.TrunkEng.PM.Python.Interfaces.PMCommonInterface      WITH NAME  PmCommon
Library     testsuite.Oulu.TrunkEng.PM.Python.Interfaces.PmCommissioningInterface      WITH NAME  PmCommissioning
Library     testsuite.Oulu.TrunkEng.PM.Python.Interfaces.NetActChecksInterface      WITH NAME  NetActChecks

*** Keywords ***

Concurrent PM upload and snapshot
    [Arguments]    ${UPLOAD_INTERVAL}  ${MEAS_INTERVAL}
    Print Step Text                      1   Check Preconditions  automatic=${True}
    Run Keyword                              Common Preconditions
    Run Keyword And Continue On Failure      PmCommissioning.Update PM Data  period=${MEAS_INTERVAL}  interval=${UPLOAD_INTERVAL}
    Print Step Text                      2   Wait for next 15min interval  automatic=${True}
    Run Keyword And Continue On Failure      PmCommon.Wait For Interval
    Print Step Text                      5   Wait for 10s before next 15min interval  automatic=${True}
    Run Keyword And Continue On Failure      PmCommon.Wait For Interval  delta=${-10}  wait_after=0s
    Print Step Text                      6   Start collecting snapshot  automatic=${True}
    Run Keyword And Continue On Failure      PmCommon.Collect Snapshot  file_name=Snapshot_PM  remove_snapshot=${True}
    Wait Time and Reason                     60  before checking PM file
    Print Step Text                      7   Check PM File  automatic=${True}
    Run Keyword And Continue On Failure      PmCommon.Check Pm File  interval=${MEAS_INTERVAL}  upload_interval=${UPLOAD_INTERVAL}
    Print Step Text                      8   Ne3s Checks  automatic=${True}
    Run Keyword And Continue On Failure      NetActChecks.Check PM File Name From NetAct
    Print Step Text                      9   Check that PM file creation lasted less than 1min  automatic=${True}
    Run Keyword And Continue On Failure      PmCommon.Check PM File Creation Time
    Print Step Text                      10  Check Postconditions  automatic=${True}
    Run Keyword And Continue On Failure      Common Postconditions
