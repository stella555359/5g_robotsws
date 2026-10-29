*** Settings ***
Documentation
...   Author:   Terhi Talvitie
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Library     testsuite.Oulu.TrunkEng.Common.Python.Interfaces.ParameterChange

*** Keywords ***
Change commissioning parameter
    [Arguments]    ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${SYSLOG_LIST}  ${PARAMETER}  ${VALUE_OF_PARAMETER}
    Print Step Text                      1  Check Preconditions and start syslog monitoring
    Run Keyword And Continue On Failure     Common Preconditions
    Run Keyword And Continue On Failure     Start Syslog Print Search To Background  ${SYSLOG_LIST}
    Print Step Text                      2  Change ${PARAMETER} to ${VALUE_OF_PARAMETER}
    Run Keyword And Continue On Failure     Select Parameter Changing Method   ${PARAMETER}    ${VALUE_OF_PARAMETER}
    Print Step Text                      3  Wait for all cells up
    Run Keyword And Continue On Failure     Wait For All Cells Up   time_limit=${WAIT_FOR_CELLS_UP}
    Run Keyword And Continue On Failure     Wait Time And Reason  ${WAIT_CHECKS}  before stopping syslog and postconditions checks
    Print Step Text                      4  Check Postconditions and stop syslog monitoring
    Run Keyword And Continue On Failure     Stop Background Syslog Print Search
    Run Keyword And Continue On Failure     SCF.Get Scf
#    Run Keyword And Continue On Failure     Check If Category Alarms Active
    Run Keyword And Continue On Failure     Common Postconditions

Change commissioning parameters of object
    [Arguments]    ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${SYSLOG_LIST}  ${OBJECT_TO_CHANGE}  ${MULTIPLE_PARAMETERS}
    Print Step Text                      1  Check Preconditions and start syslog monitoring
    Run Keyword And Continue On Failure     Common Preconditions
    Run Keyword And Continue On Failure     Start Syslog Print Search To Background  ${SYSLOG_LIST}
    Print Step Text                      2  Change elements ${MULTIPLE_PARAMETERS} of ${OBJECT_TO_CHANGE}
    Run Keyword And Continue On Failure     Change Multiple Parameters For Object   ${OBJECT_TO_CHANGE}  ${MULTIPLE_PARAMETERS}
    Print Step Text                      3  Wait for all cells up
    Run Keyword And Continue On Failure     Wait For All Cells Up   time_limit=${WAIT_FOR_CELLS_UP}
    Run Keyword And Continue On Failure     Wait Time And Reason  ${WAIT_CHECKS}  before stopping syslog and postconditions checks
    Print Step Text                      4  Check Postconditions and stop syslog monitoring
    Run Keyword And Continue On Failure     Stop Background Syslog Print Search
    Run Keyword And Continue On Failure     SCF.Get Scf
#    Run Keyword And Continue On Failure     Check If Category Alarms Active
    Run Keyword And Continue On Failure     Common Postconditions

Do commissioning with delta file
    [Arguments]    ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${SYSLOG_LIST}  ${COMMISSIONING_PARAMETERS}
    Print Step Text                      1  Check Preconditions and start syslog monitoring
    Run Keyword And Continue On Failure     Common Preconditions
    Run Keyword And Continue On Failure     Start Syslog Print Search To Background  ${SYSLOG_LIST}
    Print Step Text                      2  Create delta file
    Run Keyword And Continue On Failure     Create Delta File And Perform Recommissioning    ${COMMISSIONING_PARAMETERS}
    Print Step Text                      3  Wait for all cells up
    Run Keyword And Continue On Failure     Wait For All Cells Up   time_limit=${WAIT_FOR_CELLS_UP}
    Run Keyword And Continue On Failure     Wait Time And Reason  ${WAIT_CHECKS}  before stopping syslog and postconditions checks
    Print Step Text                      4  Check Postconditions and stop syslog monitoring
    Run Keyword And Continue On Failure     Stop Background Syslog Print Search
    Run Keyword And Continue On Failure     SCF.Get Scf
#    Run Keyword And Continue On Failure     Check If Category Alarms Active
    Run Keyword And Continue On Failure     Common Postconditions

Change Parameter Of Cell Or BBMOD
    [Arguments]    ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${SYSLOG_LIST}  ${PARAMETER}  ${VALUE_OF_PARAMETER}    ${CELL_OR_BBMOD}
    Print Step Text                      1  Check Preconditions and start syslog monitoring
    Run Keyword And Continue On Failure     Common Preconditions
    Run Keyword And Continue On Failure     Start Syslog Print Search To Background  ${SYSLOG_LIST}
    Print Step Text                      2  Change ${PARAMETER} to ${VALUE_OF_PARAMETER}
    Run Keyword And Continue On Failure     Select Parameter Changing Method   ${PARAMETER}  ${VALUE_OF_PARAMETER}  ${CELL_OR_BBMOD}
    Print Step Text                      3  Wait for all cells up
    Run Keyword And Continue On Failure     Wait For All Cells Up   time_limit=${WAIT_FOR_CELLS_UP}
    Run Keyword And Continue On Failure     Wait Time And Reason  ${WAIT_CHECKS}  before stopping syslog and postconditions checks
    Print Step Text                      4  Check Postconditions and stop syslog monitoring
    Run Keyword And Continue On Failure     Stop Background Syslog Print Search
    Run Keyword And Continue On Failure     SCF.Get Scf
#    Run Keyword And Continue On Failure     Check If Category Alarms Active
    Run Keyword And Continue On Failure     Common Postconditions
