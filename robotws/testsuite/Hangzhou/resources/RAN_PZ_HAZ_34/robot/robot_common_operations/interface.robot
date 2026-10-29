*** Settings ***
Documentation    Common keyword for all PZ robot cases.
...              Please do not modify the file without notification to author
...              Author: Civen Chen
...              Contact: civen.chen@nokia-sbell.com
Resource    ./alarm_checking.robot
Resource    ./configuration_id.robot
Resource    ./common_log_manager.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/ERR_WRN_Check.robot
Library    testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.python.gnb_alarm.AlarmWatchdog    WITH NAME    AlarmWatchdog
Library    OperatingSystem
Library    testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.robot.robot_common_operations.utils

*** Variables ***
${COMMON_CASE_SETUP_EXECUTED}    ${False}

*** Keywords ***
######################### INTERFACE #########################
robot_common_operations.Common Case Setup
    [Documentation]    Common keyword to set in Case Setup for tribe level common operations.
    ...                Author: Civen Chen
    ...                maintainer: Civen Chen
    [Timeout]          20 min
    [Arguments]    ${gnb_index}=0    ${fail_with_alarms}=${True}    ${allowed_faults_ids}=${None}
    ...            ${enable_ru_log}=${False}
    testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.robot.robot_common_operations.utils.initialize_case_environment
    # Alarm check and RU logs for Regression and e2e (skip for UUF, skip for cloud BTS)
    IF    '${execute_case_scope}' != 'UUF' and '${tl_bts_type}' != 'cloud'
        Check Alarm and stop robot testing when unexpected alarm raised
        run keyword and ignore error    Trigger start collect ru logs    enable=${enable_ru_log}
        run keyword and ignore error    Add Gnb Rad Flag For Syslog
    END
    # AlarmWatchdog for Regression and e2e (skip for UUF, skip for cloud BTS)
    IF    '${execute_case_scope}' != 'UUF' and '${tl_bts_type}' != 'cloud'
        IF    ${{$tl.gnbs is not None}}
            AlarmWatchdog.init_watchdog
            ...    interval=5 sec
            ...    bts_config=${tl.gnbs[${gnb_index}]}
            ...    fail_with_alarms=${fail_with_alarms}
            ...    allowed_alarms=${allowed_faults_ids}
        ELSE IF    ${{$tl.enbs is not None}}
            AlarmWatchdog.init_watchdog
            ...    interval=5 sec
            ...    bts_config=${tl.enbs[${gnb_index}]}
            ...    fail_with_alarms=${fail_with_alarms}
            ...    allowed_alarms=${allowed_faults_ids}
        ELSE
            Builtin.log    This environment type is not adapted, please contact Civen Chen.
        END
        # ERR_WRN_Check only for Regression scope (skip for e2e and UUF)
        IF    '${execute_case_scope}' == 'Regression' and '${execution_env_type}' != 'DEBUG'
            Run Keyword And Ignore Error    ERR_WRN_Check.Start BTSlogs Collection In Log Server    Login_UTE=${True}
        END
    END
    Set Test Variable    ${COMMON_CASE_SETUP_EXECUTED}    ${True}

robot_common_operations.Common Case Teardown
    [Documentation]    Common keyword to set in Case Teardown for tribe level common operations.
    ...                Author: Civen Chen
    ...                maintainer: Civen Chen
    [Timeout]          20 min
    testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.robot.robot_common_operations.utils.initialize_case_environment
    # AlarmWatchdog teardown for Regression and e2e (skip for UUF, skip for cloud BTS)
    IF    '${execute_case_scope}' != 'UUF' and '${tl_bts_type}' != 'cloud'
        run keyword and ignore error    AlarmWatchdog.teardown_watchdog
    END
    # Configuration ID report for all scopes (except DEBUG)
    IF    '${execution_env_type}' != 'DEBUG'
        ${result}    ${testline_name}    run keyword and ignore error    Requset Configuration Id Report
    END
    # RU logs and alarm check for Regression and e2e (skip for UUF, skip for cloud BTS)
    IF    '${execute_case_scope}' != 'UUF' and '${tl_bts_type}' != 'cloud'
        run keyword and ignore error    Stop to Collect and Save RU Logs
        # ERR_WRN_Check only for Regression scope (skip for e2e and UUF)
        IF    '${execute_case_scope}' == 'Regression' and '${execution_env_type}' != 'DEBUG'
            ${run_status}    ${sys_logs_path}    Run Keyword And Ignore Error
            ...    ERR_WRN_Check.Stop BTSlogs Collection And Download Logs To Log Server    Login_UTE=${True}
        END
        IF    '${execute_case_scope}' == 'Regression' and '${execution_env_type}' != 'DEBUG'
            IF    '${TEST STATUS}' == 'PASS' and '7_5' in '${testline_name}' and ${COMMON_CASE_SETUP_EXECUTED}
                Run Keyword And Ignore Error    ERR_WRN_Check.Check ERR Or WRN From Syslog
                ...    sys_logs_path=${sys_logs_path}[1]    testline=${testline_name}    server_type=remote
            END
        END
        Check Alarm and stop robot testing when unexpected alarm raised
    END
    Set Test Variable    ${COMMON_CASE_SETUP_EXECUTED}    ${False}

robot_common_operations.Common Suite Setup
    [Documentation]    Common keyword to set in Suite Setup for tribe level common operations.
    ...                Author: Civen Chen
    ...                maintainer: Civen Chen
    [Timeout]          20 min
    Check Alarm and stop robot testing when unexpected alarm raised

robot_common_operations.Common Suite Teardown
    [Documentation]    Common keyword to set in Suite Teardown for tribe level common operations.
    ...                Author: Civen Chen
    ...                maintainer: Civen Chen
    [Timeout]          20 min
    # Check Alarm and stop robot testing when unexpected alarm raised
    BuiltIn.Log    robot_common_operations.Common Suite Teardown
