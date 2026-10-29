*** Settings ***

Documentation
...     Author:     Valtteri Lamberg
...     Contact:    I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

*** Keywords ***
Energy Consumption
    [Arguments]    ${RMODS}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}  ${WAIT_CHECKS}  ${WAIT_FOR_CELLS_UP}  ${REFERENCE_TESTLINE}
    Run Keyword And Continue On Failure       Start Syslog Print Search To Background  ${SYSLOG_LIST}
    Print Step Text                        1  Check Preconditions  automatic=${True}
    Run Keyword And Continue On Failure       Common Preconditions
    ${is_string}=    Evaluate    isinstance(${RMODS}, str)
    IF   ${is_string}
        IF  'ALL' == '${RMODS}'
            ${RMODS}=   Get Configuration Names Of All Radios
        END
    ELSE
        IF  'ALL' in ${RMODS}
            ${RMODS}=   Get Configuration Names Of All Radios
        END
    END
    # Run Keyword And Continue On Failure       Check If Graceful Cell Shutdown
    Print Step Text                        2  Make site reset  automatic=${True}
    Run Keyword And Continue On Failure       ADMIN.Reset Site  detailed_output=True
    Print Step Text                        3  Wait for all cells up  automatic=${True}
    Run Keyword And Continue On Failure       Wait For All Cells Up  time_limit=${WAIT_FOR_CELLS_UP}
    Run Keyword And Continue On Failure       Repeat Keyword  2 times
    ...                                       Get Energy Consumption Counters From PM Files
    Print Step Text                        4  Calculate average values  automatic=${True}
    ${average_values}=                        Run Keyword And Continue On Failure  Calculate Average Values
    Print Step Text                        5  Report M4000x counters  automatic=${True}
    Run Keyword And Continue On Failure       Report M4000x Counters  ${RMODS}  ${average_values}  ${REFERENCE_TESTLINE}
    Wait Time And Reason                      ${WAIT_CHECKS}  before checking post conditions
    Print Step Text                        6  Check Postconditions  automatic=${True}
    Run Keyword And Continue On Failure       Check If Unexpected Syslog Print  ${UNALLOWED_SYSLOGS}
    Run Keyword And Continue On Failure       Stop Background Syslog Print Search
    Run Keyword And Continue On Failure       Common Postconditions

    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}  ${False}

Get Energy Consumption Counters From PM Files
    Print Step Text                        4  Wait for next interval  automatic=${True}
    Run Keyword And Continue On Failure       OmkpiEnergyConsumption.Wait For Interval
    Print Step Text                        5  Check if PM file exist on BTS  automatic=${True}
    Run Keyword And Continue On Failure       OmkpiEnergyConsumption.Check latest file existence   PM  exist=${True}
    Print Step Text                        6  Get energy consumption counters  automatic=${True}
    Run Keyword And Continue On Failure       OmkpiEnergyConsumption.Get Energy Consumption Counters