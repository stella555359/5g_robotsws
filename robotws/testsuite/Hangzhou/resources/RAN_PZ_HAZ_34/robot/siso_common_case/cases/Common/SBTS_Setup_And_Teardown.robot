*** Settings ***
Documentation    This is common keywords for sran related cases
...              Please do not modify the file without notification to author
...              Author: Shi Zhihao
...              Contact: zhihao.shi@nokia-sbell.com

Library     taf.config.testline.info.testline_info.TestlineInfo    WITH NAME    testline_info
Library     testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.python.gnb_alarm.AlarmWatchdog    WITH NAME    AlarmWatchdog
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/common/selenium.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/pre_analysis.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/common/coam.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/common/csn.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/common/btslog.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/simple_keyword.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/scf_comm_operation.robot
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Variables   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/made_variable.py
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/ru_log.robot

*** Keywords ***
#common keyword for test suite and test cases
SBTS Suite Setup
    robot_common_operations.Common Suite Setup
    log to console    \n***SBTS Suite Setup***
    run keyword and ignore error    clear vm pid before run case
    Run Keyword And Ignore Error   Add Syslog Flag To Swconfig If Not Exist
    run keyword if     ${if_commissioning} and '${testline_name}' == 'null'    CI_interface.Common Suite Setup
    ${pingable}    Run Keyword And Return Status    Check SBTS Ping Enable    bts_host=${sbts_addr}
    ${sbts_addr_temp}    set variable if    ${pingable}==${False}    192.168.255.129   ${sbts_addr}
    Connect to gnb coam via ssl    bts_host=${sbts_addr_temp}    username=${http_username}
    ...    password=${http_password}
    ${Active_SW_version}    Get Active SW Version
    set suite variable      ${Active_SW_version}
    ${Golden_SCF_Path}    Get SBTS SCF File Path    sw_version=${Active_SW_version}
    run keyword if     ${if_commissioning} and '${testline_name}' != 'null'
    ...    Commissioning SCF And Check On Air for Common    scf_path=${Golden_SCF_Path}
    set suite variable      ${Golden_SCF_Path}
    Generate SBTS Suite Log Path
    run keyword and ignore error    COAM Teardown gnb connections
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl    bts_host=${sbts_addr}
    ...    username=${http_username}    password=${http_password}
    add fault to the allowed fault list    faultId=${4681}
    log to console  MRBTS_ID:${MRBTS_ID}, NRBTS_ID:${NRBTS_ID}

SBTS Suite Teardown
    robot_common_operations.Common Suite Teardown
    log to console    \n***SBTS Suite Teardown***
    run keyword and ignore error    COAM Teardown gnb connections

SBTS Test Setup
    [Arguments]    ${sbts_index}=${0}    ${fail_with_alarms}=${False}    ${enable_watchdog}=${False}
	...    ${allowed_faults_ids}=${None}
    robot_common_operations.Common Case Setup    allowed_faults_ids=${allowed_faults_ids}
    log to console    \n***SBTS Test Setup***
    log to console    Active_SW_version(SBTS):${Active_SW_version}
    log to console    Golden_SCF_Path:${Golden_SCF_Path}
    run keyword and ignore error    COAM Teardown gnb connections
    Connect to gnb coam via ssl    bts_host=${sbts_addr}    username=${http_username}
    ...    password=${http_password}
    Generate SBTS Test Case Log Path
    log to console  CASE_LOG_PATH:${CASE_LOG_PATH}
    ${ru_status}    Run Keyword And Return Status    COAM Check GNB RU status
    ${cell_status}    Run Keyword And Return Status    Verify all cells should be onair    cell_type=${cell_type}
    Run Keyword If    ${ru_status}==${False} or ${cell_status}==${False}
    ...    Commissioning SCF And Check On Air for Common    scf_path=${Golden_SCF_Path}
    ${enable_watchdog}    Set Variable If    '${fail_with_alarms}'=='${True}'    ${True}    ${enable_watchdog}
    Set Test Variable    ${enable_watchdog}
    ${gnbs}    testline_info.get_classicalbts_gnbs    ${tl}
    ${len}    Get Length    ${gnbs}
    run keyword if    ${enable_watchdog} and ${len}>0    AlarmWatchdog.init_watchdog
    ...    interval=5 sec
    ...    bts_config=${gnbs[${sbts_index}]}
    ...    fail_with_alarms=${fail_with_alarms}
    Start Btslog With Path Check
    Run Keyword And Ignore Error    Config load RMOD Serial log by Common KW
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    wait until keyword succeeds   3x    30 sec    Selenium Coam Login And Disable Screen Lock    version=${stream}

SBTS Test Teardown
    [Arguments]    ${allowed_faults_ids}=${None}
    robot_common_operations.Common Case Teardown
    log to console    \n***SBTS Test Teardown***
    Selenium Coam Logout And Close Browser
    run keyword and ignore error    COAM Teardown gnb connections
    Connect to gnb coam via ssl    bts_host=${sbts_addr}    username=${http_username}
    ...    password=${http_password}
    ${ru_status}    Run Keyword And Return Status    COAM Check GNB RU status
    should be true    ${ru_status}
    ${cell_status}    Run Keyword And Return Status    Verify all cells should be onair    cell_type=${cell_type}
    should be true    ${cell_status}
    ${allowed_faults}    Copy List    ${ALLOWED_FAULT}
    IF    ${allowed_faults_ids} != ${None}
        ${fault_id_int}=    Convert To Integer    ${allowed_faults_ids}
        ${fault_dict}=    Create Dictionary    faultId=${fault_id_int}
        Append To List    ${allowed_faults}    ${fault_dict}
    END
    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist    allowed_faults=${allowed_faults}
    ...    file_path=${CASE_LOG_PATH}   allowed_faults=@{ALLOWED_FAULT}
    should be true    ${alarm_status}
    ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist
    ...    file_path=${CASE_LOG_PATH}    allowed_faults=@{ALLOWED_HISTORY_FAULT}
    Stop Btslog With Path Check
    Run Keyword And Ignore Error    Get RMOD Serial log download by Common KW
	...    rmod_serial_config_load=${RMOD_SERIAL_INFO}    target_dir=${CASE_LOG_PATH}
	run keyword if    ${enable_watchdog}    AlarmWatchdog.teardown_watchdog
    run keyword if test failed    run keyword if    ${save_snapshot}    Save Coam Snapshot    target_dir=${CASE_LOG_PATH}
    CI_interface.Common Case Teardown
