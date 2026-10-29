*** Settings ***
Documentation    Common keyword for all PZ robot cases.
...              Please do not modify the file without notification to author
...              Author: Civen Chen
...              Contact: civen.chen@nokia-sbell.com
Resource    ./alarm_checking.robot
Resource    ./configuration_id.robot
Resource    ./common_log_manager.robot
#Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/ERR_WRN_Check.robot
#Library    testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.python.gnb_alarm.AlarmWatchdog    WITH NAME    AlarmWatchdog
#Library    ./../test_line_specific/SBTS_10823_McLaren/Resource/robot_common_operations/utils.py
#Library    testsuite.Timisoara.SBTS.test_line_specific.SBTS_10823_McLaren.Library.gnb_alarm.AlarmWatchdog    WITH NAME    AlarmWatchdog
#Library    /../test_line_specific/SBTS_10823_McLaren/Library/gnb_alarm.py    WITH NAME    AlarmWatchdog
Library    gnb_alarm.py    WITH NAME    AlarmWatchdog
#testsuite/Timisoara/SBTS/test_line_specific/SBTS_10823_McLaren/Resource/robot_common_operations/interface.robot:GnbAlarmAnalyzer
Library    OperatingSystem
#Library    testsuite.Timisoara.SBTS.test_line_specific.SBTS_10823_McLaren.Resource.robot_common_operations.utils
#/home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS_10823_McLaren/Resource/robot_common_operations/utils.py
*** Keywords ***
######################### INTERFACE #########################
robot_common_operations.Common Case Setup
    [Documentation]    Common keyword to set in Case Setup for tribe level common operations.
    ...                Author: Civen Chen
    ...                maintainer: Civen Chen
    [Timeout]          20 min
    [Arguments]    ${gnb_index}=0    ${fail_with_alarms}=${True}    ${allowed_faults_ids}=${None}
    ...            ${enable_ru_log}=${False}
    Check Alarm and stop robot testing when unexpected alarm raised
    run keyword and ignore error    Trigger start collect ru logs    enable=${enable_ru_log}
    run keyword and ignore error    Add Gnb Rad Flag For Syslog
#    ${execution_env_type}    get_execution_env_type
    ${execution_env_type}    Set Variable    CI
    Set Test Variable    ${execution_env_type}
#    IF    ${{$tl.gnbs is not None}}
#        AlarmWatchdog.init_watchdog
#        ...    interval=5 sec
#        ...    bts_config=${tl.gnbs[${gnb_index}]}
#        ...    fail_with_alarms=${fail_with_alarms}
#        ...    allowed_alarms=${allowed_faults_ids}
#    ELSE IF    ${{$tl.enbs is not None}}
#        AlarmWatchdog.init_watchdog
#        ...    interval=5 sec
#        ...    bts_config=${tl.enbs[${gnb_index}]}
#        ...    fail_with_alarms=${fail_with_alarms}
#        ...    allowed_alarms=${allowed_faults_ids}
#    ELSE
#        Builtin.log    This environment type is not adapted, please contact Civen Chen.
#    END
#    IF    ('HAZ4_T04' in ${TEST TAGS} or 'HAZ3_T03' in ${TEST TAGS}) and '${execution_env_type}' != 'DEBUG'
#        Run Keyword And Ignore Error    ERR_WRN_Check.Start BTSlogs Collection In Log Server    Login_UTE=${True}
#    END
#    Run Keyword And Ignore Error    get_running_case_qc_id
    IF    ${{$tl.gnbs is not None}}
        AlarmWatchdog.Init Watchdog
        ...    interval=5 sec
        ...    bts_config=${tl.gnbs[${gnb_index}]}
        ...    fail_with_alarms=${fail_with_alarms}
        ...    allowed_alarms=${allowed_faults_ids}
    ELSE IF    ${{$tl.enbs is not None}}
        AlarmWatchdog.Init Watchdog
        ...    interval=5 sec
        ...    bts_config=${tl.enbs[${gnb_index}]}
        ...    fail_with_alarms=${fail_with_alarms}
        ...    allowed_alarms=${allowed_faults_ids}
    ELSE
        BuiltIn.Log    This environment type is not adapted, please contact Civen Chen.
    END

robot_common_operations.Common Case Teardown
    [Documentation]    Common keyword to set in Case Teardown for tribe level common operations.
    ...                Author: Civen Chen
    ...                maintainer: Civen Chen
    [Timeout]          20 min
    run keyword and ignore error    AlarmWatchdog.teardown_watchdog
    ${result}    ${testline_name}    run keyword and ignore error    Requset Configuration Id Report
    run keyword and ignore error    Stop to Collect and Save RU Logs
    IF    ('HAZ4_T04' in ${TEST TAGS} or 'HAZ3_T03' in ${TEST TAGS}) and '${execution_env_type}' != 'DEBUG'
        ${run_status}    ${sys_logs_path}    Run Keyword And Ignore Error
        ...    ERR_WRN_Check.Stop BTSlogs Collection And Download Logs To Log Server    Login_UTE=${True}
    END
    IF    ('HAZ4_T04' in ${TEST TAGS} or 'HAZ3_T03' in ${TEST TAGS}) and '${execution_env_type}' != 'DEBUG' and '${TEST STATUS}' == 'PASS'
        Run Keyword And Ignore Error    ERR_WRN_Check.Check ERR Or WRN From Syslog
        ...    sys_logs_path=${sys_logs_path}[1]    testline=${testline_name}    server_type=remote
    END
    Check Alarm and stop robot testing when unexpected alarm raised

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
