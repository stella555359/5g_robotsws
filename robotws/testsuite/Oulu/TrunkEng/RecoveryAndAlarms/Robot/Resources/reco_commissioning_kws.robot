*** Settings ***
Documentation
...   Author:   Jere Jacklin
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Library     testsuite.Oulu.TrunkEng.Common.Python.Interfaces.ParameterChange


*** Keywords ***
Enable Maintenance Window
    [Arguments]    ${USER_GIVEN_TIME}
    Print Step Text                      1  Enabling Maintenance Window
    ${WINDOW}=                              Get Variable Value  ${WINDOW_DURATION}  30
    ${START_TIME}=                          Update Maintenance Window Values  user_given_time=${USER_GIVEN_TIME}
    ...                                     window_duration=${WINDOW}
    [Return]    ${START_TIME}

Disable Maintenance Window
    Print Step Text                      1  Disabling Maintenance Window
    Run Keyword And Continue On Failure     Update Maintenance Window Values  enable=${False}
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'   Set Suite Variable  ${KW_SUCCESS}  ${False}

Disable Maintenance Window And Wait
    [Arguments]    ${USER_GIVEN_TIME}  ${START_TIME}
    Print Step Text                      1  Waiting until maintenance window is over and disabling it
    ${WINDOW}=                              Get Variable Value  ${WINDOW_DURATION}  120
    Run Keyword And Continue On Failure     Update Maintenance Window Values  enable=${False}  user_given_time=${USER_GIVEN_TIME}
    ...                                     start_time_for_disabling=${START_TIME}  window_duration=${WINDOW}
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'   Set Suite Variable  ${KW_SUCCESS}  ${False}

Enable Power Saving Acts
    [Documentation]  Enable power savings mode by setting in LTE actLBPowerSaving to true in class NOKLTE:LNBTS
    ...              and in 5G actNrLBPowerSaving to true in class com.nokia.srbts.nrbts:NRBTS
    Print Text To Eventlog    Enabling power saving mode
    Run Keyword And Continue On Failure  Enable Or Disable Power Saving Mode   ${True}
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'   Set Suite Variable  ${KW_SUCCESS}  ${False}

Disable Power Saving Acts
    [Documentation]  Disable power savings mode by setting in LTE actLBPowerSaving to false in class NOKLTE:LNBTS
    ...              and in 5G actNrLBPowerSaving to false in class com.nokia.srbts.nrbts:NRBTS
    Print Text To Eventlog    Disabling power saving mode
    Run Keyword And Continue On Failure  Enable Or Disable Power Saving Mode   ${False}
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'   Set Suite Variable  ${KW_SUCCESS}  ${False}

Modify Power Saving Window
    [Arguments]    ${POWER_SAVING_START_TIME}=15min    ${POWER_SAVING_DURATION}=10    ${SUSPEND_CELL_ENERGY_SAVING}=${False}
    ...            ${SELECTED_CELLS}=All    ${AFFECTED_RAT}=LTE
    [Documentation]  Modify power saving window to start in ${POWER_SAVING_START_TIME} and last for ${POWER_SAVING_DURATION} minutes
    Print Text To Eventlog    Modify power saving window to start in ${POWER_SAVING_START_TIME} and last for ${POWER_SAVING_DURATION}min
    Run Keyword And Continue On Failure  Update Power Saving Window   when_to_start=${POWER_SAVING_START_TIME}
    ...                                                               power_saving_duration=${POWER_SAVING_DURATION}
    ...                                                               suspend_cell_energy_saving=${SUSPEND_CELL_ENERGY_SAVING}
    ...                                                               affected_cells=${SELECTED_CELLS}  affected_rat=${AFFECTED_RAT}
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'   Set Suite Variable  ${KW_SUCCESS}  ${False}
