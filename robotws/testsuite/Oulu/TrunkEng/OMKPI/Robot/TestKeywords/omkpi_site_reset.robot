*** Settings ***

Documentation
...   Author:   Pekka Lonnakko
...   Contact:  pekka.lonnakko@nokia.com

Library     testsuite.Oulu.TrunkEng.OMKPI.Python.Interfaces.CooledSfpCheck

*** Variables ***
${WAIT_DISABLED_CELLS}    300

*** Keywords ***
Site reset
    [Arguments]    ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}  ${WAIT_CHECKS}  ${WAIT_FOR_CELLS_UP}  ${OAM_KPI_TARGETS}

    Run Keyword And Continue On Failure   Start Syslog Print Search To Background  ${SYSLOG_LIST}
    ${suite_variables}=   Get variables
    Run Keyword If        "\${UPDATE_FHS_SW}" in $suite_variables   Update Software To Fhs   ${suite_variables}
    ${RESET_WITHOUT_RU}=  Get Variable Value  ${RESET_WITHOUT_RU}  ${False}
    ${site_reset_kpi}=    Set Variable If     ${RESET_WITHOUT_RU} == ${False}   Site reset   Site reset without RU reset
    Print Step Text                    1  Check Preconditions
    Run Keyword And Continue On Failure   Common Preconditions
#    Run Keyword And Continue On Failure   Check If Netboot Is Active And Deactivate It
#    Run Keyword And Continue On Failure   Check If Graceful Cell Shutdown
    Run Keyword If  ${RESET_WITHOUT_RU}   Run Keyword And Continue On Failure  Save Rmod Uptimes To Suite Variable
    Run Keyword And Continue On Failure   Check AaTraceRecordUsed Value  only_print=${True}
    Run Keyword And Continue On Failure   Change AaTraceRecordUsed Value
    Print Step Text                    2  Make site reset
    Print Text To Eventlog                Request sitereset
    Run Keyword And Continue On Failure   Perform Site Reset   wait_for_reconnection=${False}
    Run Keyword And Continue On Failure   Ping Ip Until Disconnection Or Reconnection  disconnection=${True}
    ...                                   time_to_wait=300   level_in_error=warning
    Run Keyword And Continue On Failure   ALARMS.Reset Alarms   only_rt_alarms=${True}
    Run Keyword And Continue On Failure   Ping Ip Until Disconnection Or Reconnection  disconnection=${False}
    ...                                   time_to_wait=600   level_in_error=warning
    Run Keyword And Continue On Failure   Special Logs And Or Ssh Commands After Reset Before Test   after_what=Site reset
    Run Keyword And Continue On Failure   Wait For Cells Faulty  ${WAIT_DISABLED_CELLS}
    Print Step Text                    3  Wait for all cells up
    Run Keyword And Continue On Failure   Wait For All Cells Up  time_limit=${WAIT_FOR_CELLS_UP}
    Run Keyword If  ${RESET_WITHOUT_RU}   Run Keyword And Continue On Failure   Check If Rmods Were Reset
    ...                                                                         ${RMOD_UPTIMES}
    Wait Time And Reason                  ${WAIT_CHECKS}  before checking post conditions
# Two lines Commented out because: FCA_TATSCRIPTS-182435 Robotization for Site reset: Remove states checkin
#    Print Step Text                    5  Check from history that SMOD, RMODs, BBMODs and cells were reseted
#    Run Keyword And Continue On Failure   Check SMOD RMOD And BBMOD States
#    Print Step Text                    4  Check from ims2 history that cells are reset
#    Run Keyword And Continue On Failure   Check If Selected Cells Were Disabled And Enabled  all_cells=${True}
    Print Step Text                    4  Check Postconditions
    Run Keyword And Continue On Failure   Check If Unexpected Syslog Print  ${UNALLOWED_SYSLOGS}
    Run Keyword And Continue On Failure   Stop Background Syslog Print Search
    Run Keyword And Continue On Failure   Common Postconditions
    Run Keyword And Continue On Failure   Check AaTraceRecordUsed Value
    ${suite_variables}=      Get variables
    IF  "\${COOLED_SFP_CHECK}" in $suite_variables
        Run Keyword And Continue On Failure   Check Cooled Sfps
    END
    Print Step Text                    5  Collect KPIs
    Run Keyword and Continue On Failure   Collect KPIs  ${site_reset_kpi}
    Run Keyword And Continue On Failure   Check Loop Kpi  ${site_reset_kpi}  ${OAM_KPI_TARGETS}
    Print Step Text                    6  Print extra KPIs
    Run Keyword And Continue On Failure   Print Extra KPIs  Site reset

    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}  ${False}
