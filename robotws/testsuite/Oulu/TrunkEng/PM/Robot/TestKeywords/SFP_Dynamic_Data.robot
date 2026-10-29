*** Settings ***

Documentation
...   Author:   Terhi Talvitie
...   Contact:  I_MN_RAN_RD_TV_TRUNK_OUL1_GMS <I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com>

Library     testsuite.Oulu.TrunkEng.PM.Python.Interfaces.PMCommonInterface      WITH NAME  PmCommon
Library     testsuite.Oulu.TrunkEng.PM.Python.Interfaces.PmCommissioningInterface      WITH NAME  PmCommissioning
Library     testsuite.Oulu.TrunkEng.PM.Python.Resources.PmSfp

*** Keywords ***

PM SFP Dynamic Data
    [Arguments]    ${UPLOAD_INTERVAL}  ${MEAS_INTERVAL}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}
    Run Keyword And Continue On Failure   Start Syslog Print Search To Background     ${SYSLOG_LIST}
    Print Step Text                      1   Check Preconditions  automatic=${True}
    Run Keyword And Continue On Failure      Common Preconditions
    Run Keyword And Continue On Failure      PmCommissioning.Enable Sfp Monitoring  period=${MEAS_INTERVAL}
    Run Keyword And Continue On Failure      PmCommissioning.Update PM Data  period=${MEAS_INTERVAL}  interval=${UPLOAD_INTERVAL}
    ...                                      pmmnl=${True}
    Print Step Text                      2   Wait for next 15min interval  automatic=${True}
    Run Keyword And Continue On Failure      PmCommon.Wait For Interval
    Print Step Text                      3   Check PM SFP Dynamic Data  automatic=${True}
    Run Keyword And Continue On Failure      PmCommon.Check Sfp Dynamic Data
    Print Step Text                      4   Check Postconditions  automatic=${True}
    Run Keyword And Continue On Failure      Common Postconditions
    Run Keyword And Continue On Failure   Check If Unexpected Syslog Print  ${UNALLOWED_SYSLOGS}
    Run Keyword And Continue On Failure   Stop Background Syslog Print Search
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}    ${False}