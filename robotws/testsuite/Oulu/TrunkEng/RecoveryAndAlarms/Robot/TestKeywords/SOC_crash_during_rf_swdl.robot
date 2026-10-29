*** Settings ***
Documentation
...   Author:   Terhi Talvitie/Sirpa Passoja
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Library     testsuite.Oulu.TrunkEng.OMKPI.Python.Interfaces.OmkpiCommonInterface
Library     testsuite.Oulu.TrunkEng.Common.Python.Interfaces.FspIP  WITH NAME  FSP
Library     testsuite.Oulu.TrunkEng.Common.Python.Interfaces.Applications  WITH NAME  APPLICATIONS
Library     testsuite.Oulu.TrunkEng.RecoveryAndAlarms.Python.Interfaces.FaultingBBMOD

*** Keywords ***
BBMOD Crash During RF SWDL
    [Arguments]    ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}

    @{UNITS}=                            Get All BBMODs
    ${STEP}=                             Check If Step Smaller Or Same As Saved If Is Increase    ${0}

    FOR  ${UNIT}  IN  @{UNITS}
        Run Keyword And Continue On Failure  Crash Primary SoC During RF SWDL
        ...          ${UNIT}  ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}  ${STEP}
    END
    ${STEP}=                          Check If Step Smaller Or Same As Saved If Is Increase  ${STEP}
    Print Step Text                      ${STEP}  Make site reset and wait for all cells up
    Print Text To Eventlog               Request site reset
    Run Keyword And Continue On Failure  Reset Site  detailed_output=True
    Run Keyword And Continue On Failure  Wait For All Cells Up  ${WAIT_FOR_CELLS_UP}
    Run Keyword And Continue On Failure  Common Postconditions


Crash Primary SoC During RF SWDL
    [Arguments]    ${UNIT}  ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}
    ...            ${STEP}

    ${STEP}=                          Check If Step Smaller Or Same As Saved If Is Increase  ${STEP}
    ${affected_cells}=                Get Cells Of BBMOD  ${UNIT}
    Print Step Text                   ${STEP}  Check Preconditions
    Run Keyword                          Common Preconditions
    Run Keyword                          Check That Max Allowed FSP Recovery Is Set To Default
    Run Keyword And Continue On Failure  Make SSH Log
    Run Keyword And Continue On Failure  Reco RF SW Update
    ...           ${UNIT}  ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}

    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}  ${False}

Reco RF SW Update
    [Documentation]    Update SW to RF units and check KPIs. First T1, then T2 and finally normal build again.
    [Arguments]        ${UNIT}  ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}
    Run Keyword And Continue On Failure   Start Syslog Print Search To Background   ${SYSLOG_LIST}
#    ${BUILD_T1}=   Get Build That Is Currently Active On Bts   save_to_pc=${True}   testpackage=T1
#    ${BUILD_T2}=   Get Build That Is Currently Active On Bts   save_to_pc=${True}   testpackage=T2
#    ${BUILD_N}=    Get Build That Is Currently Active On Bts   save_to_pc=${True}
    Run Keyword                            Set Build Names And Get Packages That Will Be Used In Swdl   ${None}
    Run Keyword And Continue On Failure    Check If Build In Passive Side Is Same That Is Planned To Be Downloaded   ${BUILD_T1}   check_ru=${True}
# T1
    Run Keyword And Continue On Failure  Log Folders And Radio Software Update
    ...          ${UNIT}  ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${UNALLOWED_SYSLOGS}  ${BUILD_T1}  T1
# T2
    Run Keyword And Continue On Failure  Log Folders And Radio Software Update
    ...          ${UNIT}  ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${UNALLOWED_SYSLOGS}  ${BUILD_T2}  T2
# Normal build
    Run Keyword And Continue On Failure  Log Folders And Radio Software Update
    ...          ${UNIT}  ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${UNALLOWED_SYSLOGS}  ${BUILD_N}  Normal

    Run Keyword And Continue On Failure   Stop Background Syslog Print Search
    Set Suite Variable   ${LOGS_ALREADY_COLLECTED}   ${True}

    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}  ${False}

Log Folders And Radio Software Update
    [Documentation]    Create new sub log folder, update SW to RF units and collect logs if needed.
    [Arguments]    ${UNIT}  ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${UNALLOWED_SYSLOGS}  ${PATH_IN_PC}  ${BUILD}
    ${STEP}=                          Check If Step Smaller Or Same As Saved If Is Increase    0
    Run Keyword And Continue On Failure  Create New Log Folder  RF_SWDL_of_${BUILD}
    ${START_LINE}=                    Get Last Line From Syslogs
    Run Keyword And Continue On Failure  Update RF SWDL and Crash BBMOD
    ...              ${UNIT}  ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${UNALLOWED_SYSLOGS}  ${PATH_IN_PC}  ${STEP}
    ${log_collection}=                Logs Should Be Collected
    Run Keyword If                      '${log_collection}' == '${True}'   Run Keyword and Continue On Failure
    ...                                  COLLECTLOGS.Collect Snapshot  extra_name=${BUILD}
    ${END_LINE}=                      Get Last Line From Syslogs
    Run Keyword And Continue On Failure  Get Syslogs Between Two Lines  ${START_LINE}  ${END_LINE}  file_name=${BUILD}
    Run Keyword And Continue On Failure  Switch To Original Log Folder

    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'   Set Suite Variable  ${KW_SUCCESS}  ${False}

Update RF SWDL and Crash BBMOD
    [Documentation]    Update SW to RF units.
    [Arguments]        ${UNIT}  ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${UNALLOWED_SYSLOGS}  ${PATH_IN_PC}  ${STEP}
    ${STEP}=                          Check If Step Smaller Or Same As Saved If Is Increase    ${0}
    ${RU_SW_ACTIVATION}=              Get Variable Value  ${RU_SW_ACTIVATION}  ${True}

    ${STEP}=                          Check If Step Smaller Or Same As Saved If Is Increase  ${STEP}
    Print Step Text                       ${STEP}  Check Preconditions
    Run Keyword And Continue On Failure   Common Preconditions
    ${RF_SW_VERSIONS}=                Get Rf Sw Version
#   ${SWDL_AFFECTED_CELLS}=              Get Cells That Are Affected By Swdl   ${PATH_IN_PC}
#    Run Keyword And Continue On Failure   Check If Netboot Is Active And Deactivate It
# Because of 4420 fault occasionally BTS is busy and it is not possible to get information from it before 4420 is cleared
    Run Keyword And Continue On Failure   Check If Fault Active And Wait For It To Clear  4420
# ${TIME_IN_SYSLOG}=                     Get Time Of Last Syslog Line
    ${STEP}=                          Check If Step Smaller Or Same As Saved If Is Increase  ${STEP}
    Print Step Text                       ${STEP}  Upload ${PATH_IN_PC} sw to BTS and Request RF software update to ${PATH_IN_PC}
    ${SWDL_START}=                        Get Start Time
    Run Keyword And Continue On Failure   Update Software On Bts  ${PATH_IN_PC}  should_activate=${RU_SW_ACTIVATION}  ru_swdl_only=${True}
    ...                                   timeout=${12000}  admin_connection=log_admin
    Print Text To Eventlog                RF Software update request done
    Run Keyword and Continue On Failure   Calculate Duration      ${SWDL_START}

    ${STEP}=                          Check If Step Smaller Or Same As Saved If Is Increase    ${STEP}
    Print Step Text                      ${STEP}  Generate fault to tested FSP ${UNIT} During RF SWDL
    ${bbmod}=                         Get BBMOD Object From User Given Values  ${UNIT}
    Run Keyword And Continue On Failure  Generate Fault To FSP  ${bbmod}  during_startup=${True}

    Run Keyword If                      '${RU_SW_ACTIVATION}' == '${True}'  Run Keyword And Continue On Failure
    ...                                  Wait And Check Cells And Sw Version
    ...                                  ${UNIT}  ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${RF_SW_VERSIONS}  ${STEP}
    ${STEP}=                          Check If Step Smaller Or Same As Saved If Is Increase  ${STEP}
    Print Step Text                      ${STEP}  Check Postconditions and Unexpected syslog prints
    Run Keyword And Continue On Failure  Common Postconditions
    Run Keyword And Continue On Failure  Check If Unexpected Syslog Print  ${UNALLOWED_SYSLOGS}
    Run Keyword And Continue On Failure  Stop Background Syslog Print Search

    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}  ${False}

Wait And Check Cells And Sw Version
    [Documentation]    Wait for cells to be disabled, wait for all cells to be up and check that radio software has been updated.
    [Arguments]        ${UNIT}  ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${RF_SW_VERSIONS}  ${STEP}
    ${STEP}=                          Check If Step Smaller Or Same As Saved If Is Increase  ${STEP}
    Print Step Text                       ${STEP}  Wait for cells to be disabled
    ${affected_cells}=                Get Cells Of BBMOD  ${UNIT}
    Run Keyword And Continue On Failure   Wait For Cells Faulty   ${300}   cells_to_be_faulty=${affected_cells}

    ${STEP}=                          Check If Step Smaller Or Same As Saved If Is Increase  ${STEP}
    Print Step Text                       ${STEP}  Wait for all cells up
    Run Keyword And Continue On Failure   Wait For All Cells Up  ${WAIT_FOR_CELLS_UP}
    Wait Time And Reason                  ${WAIT_CHECKS}  after SWDL

    ${STEP}=                          Check If Step Smaller Or Same As Saved If Is Increase  ${STEP}
    Print Step Text                       ${STEP}  Check that radio software has been update
    Run Keyword And Continue On Failure   Compare Radio Sw Versions  ${RF_SW_VERSIONS}

    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}  ${False}
