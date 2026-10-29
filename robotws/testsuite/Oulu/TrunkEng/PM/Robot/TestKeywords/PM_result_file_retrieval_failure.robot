*** Settings ***
Documentation
...     Author:     Valtteri Lamberg
...     Contact:    I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com


Library     Collections
Library     testsuite.Oulu.TrunkEng.PM.Python.Interfaces.PMCommonInterface      WITH NAME  PmCommon
Library     testsuite.Oulu.TrunkEng.PM.Python.Interfaces.PmCommissioningInterface      WITH NAME  PmCommissioning
Library     testsuite.Oulu.TrunkEng.PM.Python.Resources.PmCommonLib      WITH NAME  PmLib
Library     testsuite.Oulu.TrunkEng.PM.Python.Interfaces.NetActChecksInterface     WITH NAME  NetActCheck
Library     testsuite.Oulu.TrunkEng.PM.Python.Interfaces.OAMConnection      WITH NAME  OAMConnection
Library     testsuite.Oulu.TrunkEng.Common.Python.Interfaces.BTS      WITH NAME  BTS


*** Keywords ***
PM result file retrieval failure
    [Arguments]  ${MEAS_INTERVAL}  ${UPLOAD_INTERVAL}

    Print Step Text                             1  Check Preconditions  automatic=${True}
    Run Keyword And Continue On Failure            Common Preconditions
    ${PC_IP}  ${NETACT_IP}=                        OAMConnection.Get IPs From Resource File
    ${LATEST_FILE}=                                Create List
    Run Keyword And Continue On Failure            PmCommissioning.Update PM Data  period=${MEAS_INTERVAL}
    ...                                            interval=${UPLOAD_INTERVAL}
    Print Step Text                             2  Wait for next 15min interval  automatic=${True}
    Run Keyword And Continue On Failure            PmCommon.Wait For Interval
    Print Step Text                             3  Drop Oam Connection  automatic=${True}
    Run Keyword And Continue On Failure            OAMConnection.Check And Drop OAM Connection  ${PC_IP}  ${NETACT_IP}
    Run Keyword And Continue On Failure            BTS.Ping Ip From SMOD  ${NETACT_IP}  disconnection=${True}
    Print Step Text                             4  Wait for next 15min interval  automatic=${True}
    ${START_TIME}=                                 Run Keyword And Continue On Failure  PmCommon.Wait For Interval
    Print Step Text                             5  Check PM file  automatic=${True}
    Run Keyword And Continue On Failure            PmCommon.Check Pm File  interval=${MEAS_INTERVAL}
    ...                                            upload_interval=${UPLOAD_INTERVAL}
    ${latest_pm_file}=                             PmLib.Latest File  PM
    Append To List                                 ${LATEST_FILE}  ${latest_pm_file}
    Print Step Text                             6  Restore Oam Connection  automatic=${True}
    Run Keyword And Continue On Failure            OAMConnection.Check And restore OAM Connection  ${PC_IP}  ${NETACT_IP}
    Run Keyword And Continue On Failure            BTS.Ping Ip From SMOD  ${NETACT_IP}
    Print Step Text                             7  Wait for next 15min interval  automatic=${True}
    Run Keyword And Continue On Failure            PmCommon.Wait For Interval
    Print Step Text                             8  Check PM file  automatic=${True}
    Run Keyword And Continue On Failure            PmCommon.Check Pm File  interval=${MEAS_INTERVAL}
    ...                                            upload_interval=${UPLOAD_INTERVAL}
    ${latest_pm_file}=                             PmLib.Latest File  PM
    Append To List                                 ${LATEST_FILE}  ${latest_pm_file}
    Print Step Text                            9   Check NE3S establishment  automatic=${True}
    Run Keyword And Continue On Failure            NetActCheck.Check PM File Name From Netact  ${LATEST_FILE}  start_time=${START_TIME}
    Print Step Text                            10  Check Postconditions  automatic=${True}
    Run Keyword And Continue On Failure            Common Postconditions

    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}  ${False}
