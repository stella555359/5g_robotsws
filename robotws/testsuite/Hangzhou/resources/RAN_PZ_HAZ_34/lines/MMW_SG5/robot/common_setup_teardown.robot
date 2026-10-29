# @Time    : 2023/8/3 14:48
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @File    : common_setup_teardown.robot
# @Software: PyCharm
*** Settings ***
Documentation    This is common setup teardown keywords
Library     taf.sbts.oam.coam.admin    WITH NAME    coam
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/class_monitor.robot

*** Keywords ***
MMW5 Common Suite Setup
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2023/11/22 10:56
    robot_common_operations.Common Suite Setup
    CI_interface.Common Suite Setup

MMW5 Common Suite Teardown
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2023/11/22 10:57
    robot_common_operations.Common Suite Teardown

MMW5 Common Case Setup
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2023/08/24 11:25
    [Arguments]    ${allowed_faults_ids}=${None}
    robot_common_operations.Common Case Setup    allowed_faults_ids=${allowed_faults_ids}
    CI_interface.Common Case Setup
    Connect to gnb coam via ssl

MMW5 Common Case Teardown
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2023/08/03 11:16
    Run Keyword If    '${TEST STATUS}'=='FAIL'    MMW5 Collect Snapshot
    robot_common_operations.Common Case Teardown
    CI_interface.Common Case Teardown

MMW5 Collect Snapshot
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2023/08/03 10:30
    [Arguments]    ${snapshot_path}=${TS_CASE_LOG_PATH}    ${timeout}=600    ${connection}=GNB_OAM
    Connect to gnb coam via ssl
    ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    ${snapshot_zip_file_path}    Join Path    ${snapshot_path}    snapshot_${timestamp}.zip
    Run    rm -rf ${snapshot_zip_file_path}
    ${snapshot_file}    coam.get_snapshot    target_file_name=${snapshot_zip_file_path}    timeout=${timeout}    connection=${connection}
    Should Contain    ${snapshot_file}    has been successfully created.
    Run Keyword And Ignore Error    COAM Teardown gnb connections
    [Return]    ${snapshot_zip_file_path}
    
