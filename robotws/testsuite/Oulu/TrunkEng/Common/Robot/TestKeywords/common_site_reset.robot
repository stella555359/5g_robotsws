*** Settings ***

Documentation
...   Author:   Jere Jacklin
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

*** Keywords ***
Site Reset
    [Arguments]    ${WAIT_CHECKS}  ${WAIT_FOR_CELLS_UP}

    Print Step Text                          1  Check Preconditions
    Run Keyword and Continue On Failure         Common Preconditions
    Print Step Text                          2  Make site reset
    Print Text To Eventlog                      Request sitereset
    Run Keyword and Continue On Failure         ADMIN.Reset Site    detailed_output=True
    Print Step Text                          3  Wait for all cells up
    Run Keyword and Continue On Failure         Wait For All Cells Up
    ...                                         time_limit=${WAIT_FOR_CELLS_UP}
    Wait Time And Reason                        ${WAIT_CHECKS}  before checking post conditions
    Print Step Text                          4  Check Postconditions
    Run Keyword and Continue On Failure         Common Postconditions

