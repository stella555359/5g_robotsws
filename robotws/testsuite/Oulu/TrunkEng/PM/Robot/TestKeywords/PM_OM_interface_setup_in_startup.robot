*** Settings ***
Documentation
...     Author:     Valtteri Lamberg
...     Contact:    I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com


Library     Collections
Library     testsuite.Oulu.TrunkEng.PM.Python.Interfaces.PMCommonInterface      WITH NAME  PmCommon
Library     testsuite.Oulu.TrunkEng.PM.Python.Interfaces.PmCommissioningInterface      WITH NAME  PmCommissioning
Library     testsuite.Oulu.TrunkEng.PM.Python.Interfaces.NetActChecksInterface     WITH NAME  NetActCheck

*** Keywords ***
PM O&M interface setup in startup
    [Arguments]  ${WAIT_FOR_CELLS_UP}

    Print Step Text                             1  Check Preconditions
    Run Keyword And Continue On Failure            Common Preconditions
    Print Step Text                             2  Reset site
    Run Keyword And Continue On Failure            BTS.Reset Site And Wait For Bts To Reply Ping
    Print Step Text                             3  Wait for all cells up
    Run Keyword And Continue On Failure            Wait For All Cells Up  time_limit=${WAIT_FOR_CELLS_UP}
    Print Step Text                             4  Check NE3S establishment
    Run Keyword And Continue On Failure            NetActCheck.Check NE3S If Establishment
    Print Step Text                             5  Check Postconditions
    Run Keyword And Continue On Failure            Common Postconditions

    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}  ${False}