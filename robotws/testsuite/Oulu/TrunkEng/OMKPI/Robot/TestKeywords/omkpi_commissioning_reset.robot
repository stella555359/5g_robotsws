*** Settings ***

Documentation
...   Author:   Pekka Lonnakko
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

*** Keywords ***
Commissioning reset
    [Arguments]    ${PARAMETER}  ${WAIT_FOR_CELLS_UP}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}

    Run Keyword And Continue On Failure     Start Syslog Print Search To Background  ${SYSLOG_LIST}
    Print Step Text                      1  Check Preconditions and start syslog monitoring  automatic=${True}
    Run Keyword And Continue On Failure     Common Preconditions
#    Run Keyword And Continue On Failure     Check If Netboot Is Active And Deactivate It
    Run Keyword And Continue On Failure     Start Syslog Print Search To Background  ${SYSLOG_LIST}
    Run Keyword And Continue On Failure     Repeat Keyword  2 times
    ...                                     Change Parameter And Report KPIs    ${PARAMETER}  ${WAIT_FOR_CELLS_UP}
    Print Step Text                      6  Check from history that SMOD, RMODs, BBMODs and cells were reseted  automatic=${True}
    Run Keyword And Continue On Failure     Check SMOD RMOD And BBMOD States  ignore_state=Commissioned
    Run Keyword And Continue On Failure     Check If Selected Cells Were Disabled And Enabled  all_cells=${True}
    Print Step Text                      7  Check Postconditions and stop syslog monitoring  automatic=${True}
    Run Keyword And Continue On Failure     Check If Unexpected Syslog Print  ${UNALLOWED_SYSLOGS}
    Run Keyword And Continue On Failure     Stop Background Syslog Print Search
    Run Keyword And Continue On Failure     Common Postconditions
    Print Step Text                      8  Collect KPIs  automatic=${True}  automatic=${True}
    Run Keyword and Continue On Failure     Collect KPIs  Commissioning reset
    Run Keyword And Continue On Failure     Check Loop Kpi  Commissioning reset  ${OAM_KPI_TARGETS}
    Print Step Text                      9  Print extra KPIs
    Run Keyword And Continue On Failure     Print Extra KPIs  Commissioning reset

    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}  ${False}

Change Parameter and Report KPIs
    [Arguments]    ${PARAMETER}  ${WAIT_FOR_CELLS_UP}

    Print Step Text                      2  Check opposite value for ${PARAMETER}  automatic=${True}
    ${VALUE_OF_PARAMETER}=                  Run Keyword And Continue On Failure  Opposite Boolean Commissioning Value  ${PARAMETER}
    Print Step Text                      3  Change ${PARAMETER} to ${VALUE_OF_PARAMETER}  automatic=${True}
    Run Keyword And Continue On Failure     Commission Value  ${PARAMETER}  ${VALUE_OF_PARAMETER}
    Print Step Text                      4  Wait for all cells up  automatic=${True}
    Run Keyword And Continue On Failure     Wait For All Cells Up  time_limit=${WAIT_FOR_CELLS_UP}
    Print Step Text                      5  Check that ${PARAMETER} is ${VALUE_OF_PARAMETER}  automatic=${True}
    Run Keyword And Continue On Failure     Check Value Is Changed  ${PARAMETER}  ${VALUE_OF_PARAMETER}
