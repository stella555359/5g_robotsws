*** Settings ***
Documentation
...   Author:   Terhi Talvitie
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Library          testsuite.Oulu.TrunkEng.OMKPI.Python.Interfaces.OmkpiStartupTimesInterface  WITH NAME  Startup
Library          testsuite.Oulu.TrunkEng.OMKPI.Python.Interfaces.OmkpiCommonInterface


*** Keywords ***
OMKPI Loop RF SW Update
    [Documentation]    Update SW to RF unit and check KPIs
    [Arguments]    ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}   ${RF_SW_PATH}
    Run Keyword And Continue On Failure   Start Syslog Print Search To Background  ${SYSLOG_LIST}
    ${PATH_IN_PC}=                        Get Rf Sw Build  ${RF_SW_PATH}
    ${BRANCH_OF_SW}=                      Get Branch Of Active Build
    Run Keyword And Continue On Failure   Set Build Names And Get Packages That Will Be Used In Swdl
    ...                                   ${BRANCH_OF_SW}   save_build_to_pc=${True}
#    Run Keyword And Continue On Failure   Check If Netboot Is Active And Deactivate It
    ${RF_SW_VERSIONS}=                    Get Rf Sw Version
    ${SWDL_AFFECTED_CELLS}=               Get Cells That Are Affected By Swdl   ${PATH_IN_PC}
    ${collect_logs}=                      ${collect}=  Logs Should Be Collected
    Run Keyword and Continue On Failure   Check If Build In Passive Side Is Same That Is Planned To Be Downloaded  ${BUILD_T1}
# 1. RU SW update
    ${STEP}=                              Check If Step Smaller Or Same As Saved If Is Increase    ${0}
    Run Keyword And Continue On Failure   RU SW update  ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${UNALLOWED_SYSLOGS}  ${PATH_IN_PC}
    ...                                                 ${SWDL_AFFECTED_CELLS}  ${RF_SW_VERSIONS}  ${collect_logs}  1  ${STEP}
# 2. T1 SBTS update
    ${STEP}=                              Check If Step Smaller Or Same As Saved If Is Increase    ${STEP}
    Run Keyword and Continue On Failure   SW Update No KPI Calculations and Log Collection If Fail
    ...                                   ${BUILD_T1}  T${SWDL_FIRST} testpackage  ${STEP}  ${WAIT_CHECKS}   ${WAIT_FOR_CELLS_UP}
    ...                                   ${True}  SWDL_of_T${SWDL_FIRST}
    ${RF_SW_VERSIONS}=                    Get Rf Sw Version
# 3. RU SW update
    ${STEP}=                              Check If Step Smaller Or Same As Saved If Is Increase    ${STEP}
    Run Keyword And Continue On Failure   RU SW update  ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${UNALLOWED_SYSLOGS}  ${PATH_IN_PC}
    ...                                                 ${SWDL_AFFECTED_CELLS}  ${RF_SW_VERSIONS}  ${collect_logs}  2  ${STEP}
# 4. T2 SBTS update
    ${STEP}=                              Check If Step Smaller Or Same As Saved If Is Increase    ${STEP}
    Run Keyword and Continue On Failure   SW Update No KPI Calculations and Log Collection If Fail
    ...                                   ${BUILD_T2}  T${SWDL_SECOND} testpackage  ${STEP}  ${WAIT_CHECKS}   ${WAIT_FOR_CELLS_UP}
    ...                                   ${True}  SWDL_of_T${SWDL_SECOND}
    ${RF_SW_VERSIONS}=                    Get Rf Sw Version
# 5. RU SW update
    ${STEP}=                              Check If Step Smaller Or Same As Saved If Is Increase    ${STEP}
    Run Keyword And Continue On Failure   RU SW update  ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${UNALLOWED_SYSLOGS}  ${PATH_IN_PC}
    ...                                                 ${SWDL_AFFECTED_CELLS}  ${RF_SW_VERSIONS}  ${collect_logs}  3  ${STEP}
# 6. Baseline SBTS SW update
    ${STEP}=                              Check If Step Smaller Or Same As Saved If Is Increase    ${STEP}
    Run Keyword and Continue On Failure   SW Update No KPI Calculations and Log Collection If Fail
    ...                                   ${BUILD_N}  normal testpackage  ${STEP}  ${WAIT_CHECKS}   ${WAIT_FOR_CELLS_UP}
    ...                                   ${True}  SWDL_of_normal
    Run Keyword And Continue On Failure   Stop Background Syslog Print Search
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}  ${False}

RU SW update
    [Documentation]    Create RF SW update folder call Update Radio Software and collect logs and return log folder to original
    [Arguments]    ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${UNALLOWED_SYSLOGS}  ${PATH_IN_PC}
    ...            ${SWDL_AFFECTED_CELLS}  ${RF_SW_VERSIONS}  ${collect_logs}  ${RF_SWDL_loop}  ${STEP}
    Run Keyword And Continue On Failure   Create New Log Folder  RF_SWDL_${RF_SWDL_loop}
    ${START_LINE}=                        Get Last Line From Syslogs
    Run Keyword And Continue On Failure   Update Radio Software  ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${UNALLOWED_SYSLOGS}
    ...                                   ${PATH_IN_PC}  ${SWDL_AFFECTED_CELLS}  ${RF_SW_VERSIONS}  ${STEP}
# IMS log is already colected when KPIs are checked
    Run Keyword If  '${KW_SUCCESS}' == '${False}' or '${collect_logs}' == '${True}'  Run Keyword and Continue On Failure
    ...                                   COLLECTLOGS.Collect Snapshot  extra_name=RF_SWDL_${RF_SWDL_loop}
    ${END_LINE}=                          Get Last Line From Syslogs
    Run Keyword And Continue On Failure   Get Syslogs Between Two Lines  ${START_LINE}  ${END_LINE}  file_name=RF_SWDL_${RF_SWDL_loop}
    Run Keyword And Continue On Failure   Switch To Original Log Folder
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}  ${False}

Update Radio Software
    [Documentation]    Update RF SW to BTS and check KPIs
    [Arguments]    ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${UNALLOWED_SYSLOGS}  ${PATH_IN_PC}
    ...            ${SWDL_AFFECTED_CELLS}  ${RF_SW_VERSIONS}  ${STEP}
    Print Step Text                       ${STEP}.1  Check Preconditions
    Run Keyword And Continue On Failure   Common Preconditions
# Because of 4420 fault occasionally BTS is busy and it is not possible to get information from it before 4420 is cleared
    Run Keyword And Continue On Failure   Check If Fault Active And Wait For It To Clear  4420
    Print Step Text                       ${STEP}.2  Upload ${PATH_IN_PC} sw to BTS
    Print Text To Eventlog                Request RF software update to ${PATH_IN_PC}
    ${SWDL_START}=                        Get Start Time
    Run Keyword And Continue On Failure   Update Software On Bts  ${PATH_IN_PC}
    ...                                   timeout=${12000}  admin_connection=log_admin
    Print Text To Eventlog                RF Software update request done
    Run Keyword and Continue On Failure   Calculate Duration      ${SWDL_START}
    Print Step Text                       ${STEP}.3  Wait for cells ${SWDL_AFFECTED_CELLS} to be disabled
    Run Keyword And Continue On Failure   Wait For Cells Faulty  ${300}  cells_to_be_faulty=${SWDL_AFFECTED_CELLS}
    Print Step Text                       ${STEP}.4  Wait for all cells up
    Run Keyword And Continue On Failure   Wait For All Cells Up  time_limit=${WAIT_FOR_CELLS_UP}
    Run Keyword And Continue On Failure   Wait Time And Reason  sleep_time=${WAIT_CHECKS}
    Print Step Text                       ${STEP}.5  Check that radio software has been update
    Run Keyword And Continue On Failure   Compare Radio Sw Versions  ${RF_SW_VERSIONS}
    Print Step Text                       ${STEP}.6  Check Postconditions
    Run Keyword And Continue On Failure   Common Postconditions
    Run Keyword And Continue On Failure   Check If Unexpected Syslog Print  ${UNALLOWED_SYSLOGS}
    Print Step Text                       ${STEP}.7  Collect KPIs
    ${RESULT}=                            Run Keyword and Continue On Failure  Collect KPIs  Manual RU SW upgrade downtime
    Run Keyword And Continue On Failure   Check Loop Kpi  ${RESULT}  Manual RU SW upgrade downtime  ${OAM_KPI_TARGETS}
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}  ${False}
