*** Settings ***
Documentation
...     Author:     Valtteri Lamberg
...     Contact:    I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Library     testsuite.Oulu.TrunkEng.Common.Python.Interfaces.LedControl

*** Keywords ***
FCT and FSP led control
    [Arguments]   ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}  ${RMOD_TO_RESET}  ${WAIT_TIME_AFTER_POWER_OFF}  ${WAIT_FOR_CELLS_UP}
    Run Keyword And Continue On Failure         Start Syslog Print Search To Background     ${SYSLOG_LIST}
    Print Step Text                             1  Check Preconditions
    Run Keyword And Continue On Failure            Common Preconditions
    ${RMOD_OBJ}=                                   Get RMOD Object From User Given Values  ${RMOD_TO_RESET}
    Setup Power Breaker Controller                 rmod
# This is needed if new Nokia radio that name starts with A and there are cells on the radio
    ${cells_of_rmod}=                              Get Cells Of Radio  ${RMOD_OBJ.name}
    Run Keyword And Continue On Failure            Check If Fault 1815 Should Be Allowed  ${RMOD_OBJ.name}
    ...                                            ${cells_of_rmod}  ${RMOD_OBJ.hw_path}
    Print Step Text                             2  Check LED colors
    Run Keyword And Continue On Failure            Check Colors Of Leds  expected_colors=${LED_COLORS_WHEN_POWER_ON}
    Print Step Text                             3  Power off
    Run Keyword And Continue On Failure            Turn Power Off From Chosen Units  ${RMOD_OBJ.name}
    Wait Time And Reason                           ${WAIT_TIME_AFTER_POWER_OFF}  after power off
    Print Step Text                             4  Check LED colors
    Run Keyword And Continue On Failure            Check Colors Of Leds  expected_colors=${LED_COLORS_WHEN_POWER_OFF}
    Print Step Text                             5  Power on
    Run Keyword And Continue On Failure            Turn Power On To Chosen Units  ${RMOD_OBJ.name}
    Print Step Text                             6  Wait For All Cells Up max ${WAIT_FOR_CELLS_UP} seconds
    Run Keyword And Continue On Failure            Wait For All Cells Up  time_limit=${WAIT_FOR_CELLS_UP}
    Print Step Text                             7  Check LED colors
    Run Keyword And Continue On Failure            Check Colors Of Leds  expected_colors=${LED_COLORS_WHEN_POWER_ON}
    Print Step Text                             8  Check Postconditions
    Run Keyword And Continue On Failure            Common Postconditions
    Run Keyword And Continue On Failure            Check If Unexpected Syslog Print  ${UNALLOWED_SYSLOGS}
    Run Keyword And Continue On Failure         Stop Background Syslog Print Search
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}  ${False}
