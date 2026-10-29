*** Settings ***
Documentation
...     Author:     Valtteri Lamberg
...     Contact:    I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com


Library     Collections
Library     testsuite.Oulu.TrunkEng.PM.Python.Interfaces.OAMConnection      WITH NAME  OAMConnection
Library     testsuite.Oulu.TrunkEng.PM.Python.Interfaces.NetActChecksInterface     WITH NAME  NetActCheck
Library     testsuite.Oulu.TrunkEng.PM.Python.Interfaces.PmCommissioningInterface      WITH NAME  PmCommissioning
Library     testsuite.Oulu.TrunkEng.PM.Python.Interfaces.PMCommonInterface      WITH NAME  PmCommon
Library     testsuite.Oulu.TrunkEng.PM.Python.Resources.PmCommonLib      WITH NAME  PmLib

*** Keywords ***

Wait For Interval And Check PM File
    [Arguments]  ${UPLOAD_INTERVAL}  ${MEAS_INTERVAL}  ${LATEST_FILE}  ${CHECK_OAM}

    Print Step Text                             5  Wait for next 15min interval  automatic=${True}
    Run Keyword And Continue On Failure            PmCommon.Wait For Interval
    Print Step Text                             6  Check PM File  automatic=${True}
    Run Keyword And Continue On Failure            PmCommon.Check Pm File  interval=${MEAS_INTERVAL}  upload_interval=${UPLOAD_INTERVAL}
    ${latest_pm_file}=                             PmLib.Latest File  PM
    Append To List                                 ${LATEST_FILE}  ${latest_pm_file}
    IF                                             ${CHECK_OAM}
        Print Step Text                             7  Check that NE3S messages do not appear  automatic=${True}
        Run Keyword And Continue On Failure            NetActCheck.Verify No PM Files In Syslog From Netact  ${LATEST_FILE}
    END

PM result files upload after 25h break
    [Arguments]  ${MEAS_INTERVAL}  ${UPLOAD_INTERVAL}
    Print Step Text                             1  Check Preconditions  automatic=${True}
    Run Keyword And Continue On Failure            Common Preconditions
    ${CHECK_OAM}=                                  Get Variable Value   ${CHECK_OAM}  ${True}
    @{LATEST_FILE}=                                Create List
    ${REPEATS}=                                    Evaluate  25*60/${UPLOAD_INTERVAL}
    ${REPEATS}=                                    Convert To Integer    ${REPEATS}
    Run Keyword And Continue On Failure            PmCommissioning.Update PM Data  period=${MEAS_INTERVAL}
    ...                                            interval=${UPLOAD_INTERVAL}
    Print Step Text                             2  Wait for next 15min interval  automatic=${True}
    ${START_TIME}=                                 Run Keyword And Continue On Failure  PmCommon.Wait For Interval
    IF                                             ${CHECK_OAM}
        ${PC_IP}  ${NETACT_IP}=                        OAMConnection.Get IPs From Resource File
        Print Step Text                             3  Check and drop OAM connection  automatic=${True}
        Run Keyword And Continue On Failure            OAMConnection.Check And Drop OAM Connection  ${PC_IP}  ${NETACT_IP}
        Run Keyword And Continue On Failure            BTS.Ping Ip From SMOD  ${NETACT_IP}  disconnection=${True}
    END
    Print Step Text                             4  Wait 25h and check PM files  automatic=${True}
    Repeat Keyword  ${REPEATS}                     Run Keyword And Continue On Failure
    ...                                            Wait For Interval And Check PM File  ${UPLOAD_INTERVAL}  ${MEAS_INTERVAL}
    ...                                                                                 ${LATEST_FILE}  ${CHECK_OAM}

    ${24h_files}=                                  Run Keyword And Continue On Failure  Get Slice From List  ${LATEST_FILE}  4
    IF                                             ${CHECK_OAM}
        Print Step Text                            11  Restore Oam Connection  automatic=${True}
        Run Keyword And Continue On Failure            OAMConnection.Check And restore OAM Connection  ${PC_IP}  ${NETACT_IP}
        Run Keyword And Continue On Failure            BTS.Ping Ip From SMOD  ${NETACT_IP}
        Print Step Text                            12  Wait for next 15min interval  automatic=${True}
        Run Keyword And Continue On Failure            PmCommon.Wait For Interval
        Print Step Text                            13  Check NE3S establishment  automatic=${True}
        Run Keyword And Continue On Failure            NetActCheck.Check PM File Name From Netact  ${24h_files}  start_time=${START_TIME}
        ...                                                add_time=2
    END
    Print Step Text                            14  Check Postconditions  automatic=${True}
    Run Keyword And Continue On Failure            Common Postconditions

    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}  ${False}
