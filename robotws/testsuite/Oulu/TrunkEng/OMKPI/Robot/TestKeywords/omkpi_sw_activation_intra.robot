*** Settings ***

Documentation
...   Author:   Terhi Talvitie
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

*** Keywords ***
Omkpi Sw Activation Intra
    [Arguments]    ${SAVE_BUILD_TO_PC}  ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}  ${RELEASE}

    ${KPIS}=                              Create Dictionary
    Run Keyword And Continue On Failure   Start Syslog Print Search To Background  ${SYSLOG_LIST}
    Print Step Text                    1  Check Preconditions
    Run Keyword And Continue On Failure   Common Preconditions
#    Run Keyword And Continue On Failure   Check If Netboot Is Active And Deactivate It

    ${BUILD_T1}=   Get Build That Is Currently Active On Bts   ${RELEASE}   save_to_pc=${SAVE_BUILD_TO_PC}   testpackage=T1
    ${BUILD_T2}=   Get Build That Is Currently Active On Bts   ${RELEASE}   save_to_pc=${SAVE_BUILD_TO_PC}   testpackage=T2
    ${BUILD_N}=    Get Build That Is Currently Active On Bts   ${RELEASE}   save_to_pc=${SAVE_BUILD_TO_PC}

    Run Keyword And Continue On Failure   Update Sw And Make Checks  ${BUILD_T1}  T1 testpackage  2  ${WAIT_CHECKS}  ${WAIT_FOR_CELLS_UP}
    Run Keyword And Continue On Failure   Update Sw And Make Checks  ${BUILD_T2}  T2 testpackage  7  ${WAIT_CHECKS}  ${WAIT_FOR_CELLS_UP}
    Run Keyword And Continue On Failure   Update Sw And Make Checks  ${BUILD_N}  normal build    12  ${WAIT_CHECKS}  ${WAIT_FOR_CELLS_UP}

    Run Keyword And Continue On Failure   Check If Unexpected Syslog Print  ${UNALLOWED_SYSLOGS}
# this is needed for checking which KPI method needs to selected
    @{FIRMWARE_UPDATE}=                   Create List  FirmwareActivationColdReset  BW.bin updated  status = 70426 UPDATED
    ${firmware_was_updated}=              Check If Found From Syslog  ${FIRMWARE_UPDATE}  print_eventlog=${False}
    ${kpi_method}=                        select_text_depending_on_value  ${firmware_was_updated}
    ...                                   Sw intra activation with firmware update  Sw intra activation without firmware update
    Run Keyword And Continue On Failure   Stop Background Syslog Print Search
    Print Step Text                   17  Collect KPIs
    Run Keyword and Continue On Failure   Collect KPIs  ${kpi_method}
    Run Keyword And Continue On Failure   Check Loop Kpi  ${kpi_method}  ${OAM_KPI_TARGETS}

    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}  ${False}
