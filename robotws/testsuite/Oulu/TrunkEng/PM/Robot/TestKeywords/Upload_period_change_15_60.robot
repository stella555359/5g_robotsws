*** Settings ***

Documentation
...   Author:   Pekka Lonnakko
...   Contact:  I_MN_RAN_RD_TV_TRUNK_OUL1_GMS <I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com>

Library     testsuite.Oulu.TrunkEng.PM.Python.Interfaces.PMCommonInterface      WITH NAME  PmCommon
Library     testsuite.Oulu.TrunkEng.PM.Python.Interfaces.PmCommissioningInterface      WITH NAME  PmCommissioning
Library     testsuite.Oulu.TrunkEng.PM.Python.Interfaces.NetActChecksInterface      WITH NAME  NetActChecks

*** Keywords ***

Upload Period Change From 15min to 60min
    Print Step Text                      1   Check Preconditions  automatic=${True}
    Run Keyword                              Common Preconditions
    Run Keyword And Continue On Failure      PmCommissioning.Update PM Data  period=${15}  interval=${15}
    Print Step Text                      2   Wait for next 60min interval to start the test  automatic=${True}
    Run Keyword And Continue On Failure      PmCommon.Wait For Interval  interval=${60}
    Print Step Text                      3   Wait for next 15min interval  automatic=${True}
    Run Keyword And Continue On Failure      PmCommon.Wait For Interval
    Print Step Text                      4   Check PM File  automatic=${True}
    Run Keyword And Continue On Failure      PmCommon.Check Pm File  interval=${15}  upload_interval=${15}
    Print Step Text                      5   Ne3s Checks  automatic=${True}
    Run Keyword And Continue On Failure      NetActChecks.Check PM File Name From NetAct
    Print Step Text                      3   Wait 5 min before next interval  automatic=${True}
    Run Keyword And Continue On Failure      PmCommon.Wait For Interval  delta=${-300}
    Print Step Text                      8   Commission upload interval to 60min  automatic=${True}
    Run Keyword And Continue On Failure      PmCommissioning.Update PM Data  period=${60}  interval=${15}
    Print Step Text                      3   Wait for next 15min interval  automatic=${True}
    Run Keyword And Continue On Failure      PmCommon.Wait For Interval
    Print Step Text                      4   Check PM File  automatic=${True}
    Run Keyword And Continue On Failure      PmCommon.Check Pm File  interval=${15}  upload_interval=${15}
    Print Step Text                      5   Ne3s Checks  automatic=${True}
    Run Keyword And Continue On Failure      NetActChecks.Check PM File Name From NetAct
    Print Step Text                      3   Wait for next 15min interval  automatic=${True}
    Run Keyword And Continue On Failure      PmCommon.Wait For Interval
    Print Step Text                      9   Check that PM file does not exist on BTS  automatic=${True}
    Run Keyword And Continue On Failure      PmCommon.Check latest file existence   PM  exist=${False}
    Print Step Text                      3   Wait for next 15min interval  automatic=${True}
    Run Keyword And Continue On Failure      PmCommon.Wait For Interval
    Print Step Text                      4   Check PM File  automatic=${True}
    Run Keyword And Continue On Failure      PmCommon.Check Pm File  interval=${15}  upload_interval=${60}  upload_period_change=${True}
    Print Step Text                      5   Ne3s Checks  automatic=${True}
    Run Keyword And Continue On Failure      NetActChecks.Check PM File Name From NetAct
    Print Step Text                      7   Check Postconditions  automatic=${True}
    Run Keyword And Continue On Failure      Common Postconditions
