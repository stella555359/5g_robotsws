*** Settings ***
Documentation
...    author: ming shi
...    contact: ming.shi@nokia-sbell.com

#Suite Setup    robot_common_operations.Common Suite Setup
#
#Suite Teardown    robot_common_operations.Common Suite Teardown
Test Setup    Upgrade Test setup
Test Teardown    Teardown for upgrade rollback and reset

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/upgrade_rollback_keywords.robot
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC001785/Resources/TDD_FDD_HO_common_keyword.robot
Variables   testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC001785/Resources/upgrade_and_rollback_parameters.py
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/ERR_WRN_Check.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Collect_logs.robot
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC001785/TDD_FDD_SFE_Regression/SISO_Resource/ping_pang_common_keywords.robot

*** Variables ***
${sys_logs_path}    /tmp/btslog2/
${UTE_logs_path}    /home/ute/ERR_WRN_logs/
${testline_name}          null
${base_file}    None
@{filter_list}    None

${Test_PC_IP}          ${tl.test_pc.default_ssh_connection_details.addr}
${Test_PC_username}    ${tl.test_pc.default_ssh_connection_details.username}
${Test_PC_password}    ${tl.test_pc.default_ssh_connection_details.password}

${MRBTS_ID}    ${tl.gnbs[0].instance_id}

${case_logs_path}    /opt/workspace/CRT/Master/Case_Logs/
${test_info_path}    /opt/workspace/SCF/

*** Test Cases ***
[1]E2E_gNB_SW_Upgrade_rollback_reset_loops_with_WebUI
    ${is_multi_bts_operation}    get_value_of_is_multi_bts_operation
    Run Keyword If    ${is_multi_bts_operation}==True    multi_bts_multi_times
    ...    ELSE    single_bts_multi_times


*** Keywords ***
single_bts_multi_times
    ${node_num}    get_bts_num
    Set Test Variable    ${node_num}
    FOR    ${num}    IN RANGE    ${node_num}
        ${node_index}    ${node_type}    ${node_upgrade_boolean}    ${node_rollback_boolean}    ${node_reset_boolean}
        ...    get_required_info    bts_index=${num}
        ${value_action_first}    get_value_of_action_first    bts_index=${num}
        Set Test Variable    ${node_index}
        Set Test Variable    ${node_type}
        Set Test Variable    ${node_upgrade_boolean}
        Set Test Variable    ${node_rollback_boolean}
        Set Test Variable    ${node_reset_boolean}
        ${run_times}    get_run_times    index=${num}
        Set Test Variable    ${test_round}    ${run_times}
        ${value_is_check_lower_version_to_upgrade}    get_value_of_value_is_check_lower_version_to_upgrade    bts_index=${num}
        IF    ${value_is_check_lower_version_to_upgrade} == True
            Check if lower version between active and passive via ssh    gnb_index=${num}
            IF    '${need_rollback_first_flag}' == '${True}'
                rollback    node_type=${node_type}    index=${node_index}
            END
            upgrade    node_type=${node_type}    index=${node_index}    node_no=${num}    v_index=${0}
        ELSE IF    ${value_is_check_lower_version_to_upgrade} == False
            IF    '${value_action_first}'=='upgrade'
                run actions    node_no=${num}
            ELSE IF    '${value_action_first}'=='rollback'
                run actions rollback first    node_no=${num}
            ELSE IF    '${value_action_first}'=='reset'
                run actions    node_no=${num}
            END
        END
    END

multi_bts_multi_times
    ${run_times}    get_run_times    index=${0}
    Set Test Variable    ${test_round}    ${run_times}
    FOR    ${count}    IN RANGE    ${test_round}
        multi bts upgrade
        multi bts rollback
        multi bts reset
    END

multi bts upgrade
    ${node_num}    get_bts_num
    Set Test Variable    ${node_num}
    FOR    ${num}    IN RANGE    ${node_num}
        ${node_index}    ${node_type}    ${node_upgrade_boolean}    ${node_rollback_boolean}    ${node_reset_boolean}
        ...    get_required_info    bts_index=${num}
        Set Test Variable    ${node_index}
        Set Test Variable    ${node_type}
        Set Test Variable    ${node_upgrade_boolean}
        Set Test Variable    ${node_rollback_boolean}
        Set Test Variable    ${node_reset_boolean}
        Run Keyword If    ${node_upgrade_boolean}==True
        ...    upgrade    node_type=${node_type}    index=${node_index}    node_no=${num}
    END

multi bts rollback
    ${node_num}    get_bts_num
    Set Test Variable    ${node_num}
    FOR    ${num}    IN RANGE    ${node_num}
        ${node_index}    ${node_type}    ${node_upgrade_boolean}    ${node_rollback_boolean}    ${node_reset_boolean}
        ...    get_required_info    bts_index=${num}
        Set Test Variable    ${node_index}
        Set Test Variable    ${node_type}
        Set Test Variable    ${node_upgrade_boolean}
        Set Test Variable    ${node_rollback_boolean}
        Set Test Variable    ${node_reset_boolean}
        Run Keyword If    ${node_rollback_boolean}==True
        ...    rollback    node_type=${node_type}    index=${node_index}
    END

multi bts reset
    ${node_num}    get_bts_num
    Set Test Variable    ${node_num}
    FOR    ${num}    IN RANGE    ${node_num}
        ${node_index}    ${node_type}    ${node_upgrade_boolean}    ${node_rollback_boolean}    ${node_reset_boolean}
        ...    get_required_info    bts_index=${num}
        Set Test Variable    ${node_index}
        Set Test Variable    ${node_type}
        Set Test Variable    ${node_upgrade_boolean}
        Set Test Variable    ${node_rollback_boolean}
        Set Test Variable    ${node_reset_boolean}
        Run Keyword If    ${node_reset_boolean}==True
        ...    reset    node_type=${node_type}    index=${node_index}
    END

run actions
    [Arguments]    ${node_no}=${0}
    Set Test Variable    ${initial_num}    ${0}
    @{version_list}=    get_version    index=${node_no}
    ${version_length}=    Get Length     ${version_list}
    FOR    ${count}    IN RANGE    ${test_round}
        Log To Console    This is ${count} loop
        Run Keyword If    ${initial_num} == ${version_length}    Run Keywords
        ...    Set Test Variable    ${version_index}    ${0}
        ...    AND    Set Test Variable    ${initial_num}    ${-1}
        ...    ELSE    Set Test Variable    ${version_index}    ${initial_num}
        Run Keyword If    ${node_upgrade_boolean}==True
        ...    upgrade    node_type=${node_type}    index=${node_index}    node_no=${node_no}
        ...    v_index=${version_index}
        Run Keyword If    ${node_rollback_boolean}==True    sleep    50s
        Run Keyword If    ${node_rollback_boolean}==True
        ...    rollback    node_type=${node_type}    index=${node_index}
        Run Keyword If    ${node_reset_boolean}==True    sleep    50s
        Run Keyword If    ${node_reset_boolean}==True
        ...    reset    node_type=${node_type}    index=${node_index}
        Run Keyword If    ${node_upgrade_boolean}==True    sleep    50s
        ${initial_num}    Evaluate    ${initial_num} + 1
    END

run actions rollback first
    [Arguments]    ${node_no}=${0}
    Set Test Variable    ${initial_num}    ${0}
    @{version_list}=    get_version    index=${node_no}
    ${version_length}=    Get Length     ${version_list}
    FOR    ${count}    IN RANGE    ${test_round}
        Log To Console    This is ${count} loop
        Run Keyword If    ${node_rollback_boolean}==True
        ...    rollback    node_type=${node_type}    index=${node_index}
        Run Keyword If    ${node_upgrade_boolean}==True    sleep    50s
        Run Keyword If    ${initial_num} == ${version_length}    Run Keywords
        ...    Set Test Variable    ${version_index}    ${0}
        ...    AND    Set Test Variable    ${initial_num}    ${-1}
        ...    ELSE    Set Test Variable    ${version_index}    ${initial_num}
        Run Keyword If    ${node_upgrade_boolean}==True
        ...    upgrade    node_type=${node_type}    index=${node_index}    node_no=${node_no}
        ...    v_index=${version_index}
        Run Keyword If    ${node_reset_boolean}==True    sleep    50s
        Run Keyword If    ${node_reset_boolean}==True
        ...    reset    node_type=${node_type}    index=${node_index}
        Run Keyword If    ${node_rollback_boolean}==True    sleep    50s
        ${initial_num}    Evaluate    ${initial_num} + 1
    END

upgrade
    [Arguments]    ${node_type}=gnb    ${index}=${0}    ${connection}=${node_type}_${index}
    ...    ${timeout}=10 min    ${retry_interval}=5 sec    ${du_index}=0
    ...    ${is_x2_check_from_gnb_needed}=${True}
    ...    ${check_tl_type_timeout}=5s    ${check_tl_type_retry_interval}=1s    ${node_no}=${0}
    ...    ${v_index}=${0}
    Wait Until Keyword Succeeds    10m    10s    check firmware upgrade ongoing fid 4420    gnb_index=${index}
    ${value_is_capture_syslog_enabled}=    get_value_of_is_capture_syslog_enabled
    Set Test Variable    ${value_is_capture_syslog_enabled}
    IF    ${value_is_capture_syslog_enabled} == True
        put btslog_ini file to ute
        ...    server_ip=${appserver_addr}    server_username=${appserver_username}    server_password=${appserver_password}
        Start capture syslog via btslog on ute
    END
    get_download_link_release_name
    get version info    index=${node_no}    v_index=${v_index}
    check_and_download_packet
    ${is_make_traffic}    get_value_of_is_make_traffic
    Run Keyword If    ${is_make_traffic}==True
    ...    Prepare all online UE with DL data start    cell_type=SA
    Set Test Variable    ${test_result}    ${False}
    Log to console    1.check current version
    Get current version to check    connection=${connection}    node_type=${node_type}    gnb_index=${index}    enb_index=${index}
    Log to console    2.upgrade
    Wait Until Keyword Succeeds    3x    1m    upgrade build    connection=${connection}
    ...    node_type=${node_type}    gnb_index=${index}    enb_index=${index}
    sleep    1m
    Log to console    3. check version after upgrade
    wait until keyword succeeds     40min    2min    Check if Upgrade Successfully    connection=${connection}
    ...    node_type=${node_type}    gnb_index=${index}    enb_index=${index}
    Log to console    4. check sw upgrade report
    Get upgrade report    connection=${connection}    node_type=${node_type}    gnb_index=${index}    enb_index=${index}
    Log to console    5. check site status
    Wait Until Keyword Succeeds    3x    1m
    ...    Get and check node detail info    connection=${connection}    timeout=${timeout}    retry_interval=${retry_interval}
    ...    du_index=${du_index}    node_type=${node_type}
    ...    is_x2_check_from_gnb_needed=${is_x2_check_from_gnb_needed}
    ...    check_tl_type_timeout=${check_tl_type_timeout}
    ...    check_tl_type_retry_interval=${check_tl_type_retry_interval}    gnb_index=${index}    enb_index=${index}
    sleep   10m
#    loop check alarms    connection=${connection}
    Set Test Variable    ${test_result}    ${True}
    [Teardown]    Run Keywords
    ...    Run Keyword If    ${value_is_capture_syslog_enabled} == True    Stop capture syslog via btslog on ute
    ...    AND    Run Keyword If    ${value_is_capture_syslog_enabled} == True
    ...    Run Keyword And Continue On Failure    syslog analysis via regex file
    ...    AND    Run Keyword If    '${KEYWORD STATUS}' == 'FAIL'    Save snapshot Teardown for SFE    connection=GNB_OAM    gnb_index=${index}

rollback
    [Arguments]    ${node_type}=gnb    ${index}=${0}    ${connection}=${node_type}_${index}
    ...    ${timeout}=15 min    ${retry_interval}=5 sec    ${du_index}=0
    ...    ${is_x2_check_from_gnb_needed}=${True}
    ...    ${check_tl_type_timeout}=5s    ${check_tl_type_retry_interval}=1s
    Wait Until Keyword Succeeds    10m    10s    check firmware upgrade ongoing fid 4420    gnb_index=${index}
    ${value_is_capture_syslog_enabled}=    get_value_of_is_capture_syslog_enabled
    Set Test Variable    ${value_is_capture_syslog_enabled}
    IF    ${value_is_capture_syslog_enabled} == True
        put btslog_ini file to ute
        ...    server_ip=${appserver_addr}    server_username=${appserver_username}    server_password=${appserver_password}
        Start capture syslog via btslog on ute
    END
    Set Test Variable    ${test_result}    ${False}
    Log to console    1.check current version
    Get current version to check    connection=${connection}    node_type=${node_type}    gnb_index=${index}    enb_index=${index}
    Log to console    2.rollback
    Wait Until Keyword Succeeds    3x    1m    rollback_build    connection=${connection}
    ...    node_type=${node_type}    gnb_index=${index}    enb_index=${index}
    sleep    1m
    Log to console    3. check version after rollback
    wait until keyword succeeds     40min    2min    Check if rollback Successfully    connection=${connection}
    ...    node_type=${node_type}    gnb_index=${index}    enb_index=${index}
    Log to console    4. check site status
    Wait Until Keyword Succeeds    3x    1m
    ...    Get and check node detail info    connection=${connection}    timeout=${timeout}    retry_interval=${retry_interval}
    ...    du_index=${du_index}    node_type=${node_type}
    ...    is_x2_check_from_gnb_needed=${is_x2_check_from_gnb_needed}
    ...    check_tl_type_timeout=${check_tl_type_timeout}
    ...    check_tl_type_retry_interval=${check_tl_type_retry_interval}    gnb_index=${index}    enb_index=${index}
    sleep    10m
#    loop check alarms    connection=${connection}
    Set Test Variable    ${test_result}    ${True}
    [Teardown]    Run Keywords
    ...    Run Keyword If    ${value_is_capture_syslog_enabled} == True    Stop capture syslog via btslog on ute
    ...    AND    Run Keyword If    ${value_is_capture_syslog_enabled} == True
    ...    Run Keyword And Continue On Failure    syslog analysis via regex file
    ...    AND    Run Keyword If    '${KEYWORD STATUS}' == 'FAIL'    Save snapshot Teardown for SFE    connection=GNB_OAM    gnb_index=${index}


reset
    [Arguments]    ${node_type}=gnb    ${index}=${0}    ${connection}=${node_type}_${index}
    ...    ${timeout}=10 min    ${retry_interval}=5 sec    ${du_index}=0
    ...    ${is_x2_check_from_gnb_needed}=${True}
    ...    ${check_tl_type_timeout}=5s    ${check_tl_type_retry_interval}=1s
    Wait Until Keyword Succeeds    10m    10s    check firmware upgrade ongoing fid 4420    gnb_index=${index}
    ${value_is_capture_syslog_enabled}=    get_value_of_is_capture_syslog_enabled
    Set Test Variable    ${value_is_capture_syslog_enabled}
    IF    ${value_is_capture_syslog_enabled} == True
        put btslog_ini file to ute
        ...    server_ip=${appserver_addr}    server_username=${appserver_username}    server_password=${appserver_password}
        Start capture syslog via btslog on ute
    END
    Set Test Variable    ${test_result}    ${False}
    Log to console    1.check current version
    Get current version to check    connection=${connection}    node_type=${node_type}    gnb_index=${index}    enb_index=${index}
    Log to console    2.reset
    Wait Until Keyword Succeeds    3x    1m    reset node    connection=${connection}    node_type=${node_type}
    ...    gnb_index=${index}    enb_index=${index}
    sleep    1m
    Log to console    3. check version after reset
    wait until keyword succeeds     40min    2min    Check if reset Successfully    connection=${connection}
    ...    node_type=${node_type}    gnb_index=${index}    enb_index=${index}
    Log to console    4. check site status
    Wait Until Keyword Succeeds    3x    1m    Get and check node detail info    connection=${connection}
    ...    timeout=${timeout}    retry_interval=${retry_interval}
    ...    du_index=${du_index}    node_type=${node_type}
    ...    is_x2_check_from_gnb_needed=${is_x2_check_from_gnb_needed}
    ...    check_tl_type_timeout=${check_tl_type_timeout}
    ...    check_tl_type_retry_interval=${check_tl_type_retry_interval}    gnb_index=${index}    enb_index=${index}
    sleep    10m
#    loop check alarms    connection=${connection}
    Set Test Variable    ${test_result}    ${True}
    [Teardown]    Run Keywords
    ...    Run Keyword If    ${value_is_capture_syslog_enabled} == True    Stop capture syslog via btslog on ute
    ...    AND    Run Keyword If    ${value_is_capture_syslog_enabled} == True
    ...    Run Keyword And Continue On Failure    syslog analysis via regex file
    ...    AND    Run Keyword If    '${KEYWORD STATUS}' == 'FAIL'    Save snapshot Teardown for SFE    connection=GNB_OAM    gnb_index=${index}

get and analysis syslog
    Check ERR Or WRN From Syslog
    ...    sys_logs_path=${sys_logs_path}      Expected_ERR_WRN_deviation=0.2
    ...    Expected_ERR_WRN_diff_number=0
    ...    UTE_logs_path=${UTE_logs_path}      testline=${testline_name}
    ...    base_file=None     Fail_Case=False       Clear_log=False     remove_ERR_WRN_excel=True
    ...    filter_list=None      ignore_list=None      Delete_old_ERR_WRN=20
    ...    FilesSystem=/dev/vda2      Max_used_space_ratio=0.9      check_diff=True
    ...    timeout=30 minutes      Expected_ERR_WRN_number=0
#    ...    Check_RF_Log=True

Start capture syslog via btslog on ute
    Start BTSlogs Collection In Log Server
    ...    Test_PC_IP=${Test_PC_IP}    Test_PC_username=${Test_PC_username}
    ...    Test_PC_password=${Test_PC_password}
    ...    btslog_path=/tmp/btslog2    btslog_launcher=/opt/btslog/btslog_launcher
    ...    btslog_launcher_path=/opt/btslog/btslog
    ...    Login_UTE=False

Stop capture syslog via btslog on ute
    Stop BTSlogs Collection And Download Logs To Log Server
    ...    UTE_syslogs_path=/home/ute/BTS_logs    btslog_path=/tmp/btslog2
    ...    btslog_launcher=/opt/btslog/btslog_launcher    btslog_launcher_path=/opt/btslog/btslog
    ...    Login_UTE=${False}

loop check alarms
    [Arguments]  ${connection}=GNB_OAM    ${node_type}=gnb    ${gnb_index}=${0}    ${enb_index}=${0}
    ${alarm_check_time}    get_value_of_alarm_check_time
    wait until keyword succeeds     10min    30s
    ...    login    node_type=${node_type}    connection=${connection}    gnb_index=${gnb_index}    enb_index=${enb_index}
    FOR    ${per_time}    IN RANGE    ${alarm_check_time}
#        Get alarms to check
        Get and check fault id    connection=${connection}
        Sleep    1m
    END
    [Teardown]    logout    connection=${connection}

Get and check fault id
    [Arguments]     ${connection}=GNB_OAM
    ${activate_alarms}=    coam.get_active_alarms    connection=${connection}
    ${count_alarm}    Get length    ${activate_alarms}
    Should be true    ${count_alarm}>=${1}    msg=Check cell status failed as total cell number is less than 1
    @{active_faultID_list}=    Create List
    @{history_faultID_list}=    Create List
    FOR  ${alarm}  IN  @{activate_alarms}
        Append To List    ${active_faultID_list}    ${alarm}[faultId]
    END
    ${history_alarms}=    coam.get_historic_alarms    timeout=${300}    connection=${connection}    load_history=${True}
    FOR  ${fault}  IN  @{history_alarms}
        Append To List    ${history_faultID_list}    ${fault}[faultId]
    END
    ${is_unexpected_active_fault}    ${unexpected_active_fault_id}=    check_fault_is_existed    detected_fault_id=${active_faultID_list}
    ${is_unexpected_history_fault}    ${unexpected_history_fault_id}=    check_fault_is_existed    detected_fault_id=${history_faultID_list}
    IF    ${is_unexpected_active_fault} == ${True}
        Fail    Unexpected active fault id is found: ${unexpected_active_fault_id}
    END
    IF    ${is_unexpected_history_fault} == ${True}
        Fail    Unexpected history fault id is found: ${unexpected_history_fault_id}
    END

Upgrade Test setup
    ${allowed_faults_ids_list}=    get_value_of_allowed_faults_ids    bts_index=${0}
    Set Test Variable    ${allowed_faults_ids_list}
    ${allowed_faults_ids_string}=    get_allowed_faults_ids_string    value_allowed_faults_ids_list=${allowed_faults_ids_list}
    robot_common_operations.Common Case Setup    allowed_faults_ids=${allowed_faults_ids_string}
    FOR    ${fault_id}    IN    @{allowed_faults_ids_list}
        AlarmWatchdog.add_allow_alarms    fault_id=${fault_id}
    END
    Set Test Variable    ${name}    ${TEST NAME}

Teardown for upgrade rollback and reset
    robot_common_operations.Common Case Teardown
    FOR    ${fault_id}    IN    @{allowed_faults_ids_list}
        AlarmWatchdog.remove_allow_alarms    fault_id=${fault_id}
    END
    Run Keyword If Test Failed    CI_interface.Common Case Teardown
