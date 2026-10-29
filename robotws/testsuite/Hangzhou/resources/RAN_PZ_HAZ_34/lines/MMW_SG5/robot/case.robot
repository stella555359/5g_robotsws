*** Settings ***

Library  taf.selenium.sbts  WITH NAME  selenium_coam
Library           OperatingSystem
Library           Collections
Library           String
Library           BuiltIn
Library           taf.transport.ssh    WITH NAME    csn
Library            random
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/scf.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
# Resource  testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/android_ue.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/admin_sbts.robot
Resource  testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/siso_common_keywords.robot



Documentation
...    author: Liqin Yang
...    contact: liqin.yang@nokia-sbell.com
...    Group: HGZ_SG5

*** Variables ***
${PATH_Storage}    /home/ute

*** Keywords ***
Test Case Setup
    [Arguments]     ${case_name}
    ${TS_CASE_LOG_PATH}    catenate     SEPARATOR=/    ${PATH_Storage}    ${case_name}
    Set Test Variable    ${TS_CASE_LOG_PATH}
    Run keyword And Ignore Error  Remove Directory  ${TS_CASE_LOG_PATH}  recursive=True
    Run Keyword And Continue On Failure  create directory  ${PATH_Storage}
    Run Keyword And Continue On Failure  create directory  ${PATH_Storage}/${case_name}
    robot_common_operations.Common Case Setup
    Wait Until Keyword Succeeds    1 min    3 sec    Connect to gnb coam via ssl
    ${exist_fault}    coam_gnb_classical.COAM Get active alarms
    Set test variable    ${exist_fault}
    Set Suite Variable  ${CASE_LOG_PATH}  ${TS_CASE_LOG_PATH}

Test Case Teardown
    robot_common_operations.Common Case Teardown
    Wait Until Keyword Succeeds    1 min    3 sec    Connect to gnb coam via ssl
    Wait For Expect Fault To Disappear  faultId=4592    timeout=90
    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist    allowed_faults=${exist_fault}    file_path=${TS_CASE_LOG_PATH}
    Run keyword And Ignore Error    Run Keyword If Test Failed    COAM Save snapshot via rest api  timeout=900
    Run Keyword And Ignore Error    csn.disconnect    connection=ASIK Master
    run keyword and ignore error    COAM Teardown gnb connections
    Run Keyword If Test Passed  Run keyword And Ignore Error  Remove Directory  ${TS_CASE_LOG_PATH}  recursive=True
    Run Keyword And Ignore Error  taf.sbts.oam.coam.admin.Teardown All Aliases For Admin
	CI interface.Common Case Teardown


Suite Case Setup
    Run Keyword And Ignore Error    coam.teardown
    CI_interface.Common Suite Setup
    robot_common_operations.Common Suite Setup
    log to console  Get Active SW Version
    Connect to gnb coam via ssl
    ${Active_SW_version}    Get Active SW Version
    set suite variable      ${Active_SW_version}
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    set suite variable      ${stream}

Suite Case Teardown
    Wait Until Keyword Succeeds    1 min    3 sec    Connect to gnb coam via ssl
    Run keyword if    '${SUITE STATUS}' == 'FAIL'    Run keyword and continue on failure
    ...    COAM Save snapshot via rest api  timeout=900    log_path=${PATH_Storage}
    Check Alarm and stop robot testing when unexpected alarm raised
    run keyword and ignore error    COAM Teardown gnb connections
    robot_common_operations.Common Suite Teardown
    log to console    Suite Case Teardown
