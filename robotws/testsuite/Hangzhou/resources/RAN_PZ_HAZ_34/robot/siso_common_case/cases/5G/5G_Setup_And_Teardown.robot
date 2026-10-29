*** Settings ***
Documentation    This is common keywords for siso RRH related cases
...              Please do not modify the file without notification to author
...              Author: Civen Chen
...              Contact: civen.chen@nokia-sbell.com

Library    Process
Library    ../../lib/made_lib.py
Library    ../../lib/get_ru_variables.py
Variables  ../../variable/made_variable.py
# Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/collect_ru_logs.py

Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/common/btslog.robot
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/common/csn.robot
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/ERR_WRN_Check.robot
Resource   ../../step_keywords/5G/basic/bts_coam.robot
Resource   ../../step_keywords/5G/ru_log.robot
Resource   ../../step_keywords/5G/basic/pre_analysis.robot


*** Keywords ***
SISO Coam Suite Setup
    [Arguments]    ${gnb_index}=0
    robot_common_operations.Common Suite Setup
    log to console    \n*** SISO Coam Suite Setup***
    run keyword and ignore error    clear vm pid before run case
    set suite variable    ${suite_setup_fail_flag}    ${True}
    Run Keyword And Ignore Error   Add Syslog Flag To Swconfig If Not Exist
    run keyword if     ${if_commissioning}    Run Keyword And Ignore Error   Start Btslog With Path Check
    run keyword if     ${if_commissioning}    CI_interface.Common Suite Setup    gnb_index=${gnb_index}
    ${connection}    set variable if    ${gnb_index}==0    GNB_OAM    GNB_OAM_${gnb_index}
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${Active_SW_version}    Get Active SW Version    connection=${connection}
    set suite variable      ${Active_SW_version}
    ${Golden_SCF_Path}    Get Golden SCF Path    gnb_index=${gnb_index}
    set suite variable      ${Golden_SCF_Path}
    ${gNb_CuType}   Get gNB CU type    connection=${connection}
    set suite variable      ${gNb_CuType}
    run keyword if     ${if_update_swconfig}    update swconfig for gNB    connection=${connection}
    Generate suite log path
    set suite variable      ${SAVE LOG DIRECTORY}    ${SUITE_LOG_PATH}
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
    ...    connection=${connection}    gnb_index=${gnb_index}
    ${scf_path}    Download SCF Download Via Rest Api    scf_dir_path=${SAVE LOG DIRECTORY}    connection=${connection}
    set suite variable    ${scf_path}
    ${mrbtsID}    ${nrbtsID}   Get mrbtsID and nrbtsID via SCF for gNB    scf_path=${scf_path}
    log to console  MRBTS_ID:${mrbtsID}, NRBTS_ID:${nrbtsID}
    set suite variable  ${mrbtsID}
    set suite variable  ${nrbtsID}
    ${ru_type_init}    get_ru_type_from_init    ru_type=${ru_type}
    set suite variable    ${ru_type_init}
    run keyword if     '${ru_type_init}'=='AEQN'    remove fault 4687 from allowed fault list
    run keyword if     '${testline_name}' == 'null'    add fault to the allowed fault list    faultId=${4681}
    run keyword if     '${gNb_CuType}'=='NSA' or '${gNb_CuType}'=='SA+NSA'
    ...    Run Keyword And Ignore Error    get eNB active version
    set suite variable    ${suite_setup_fail_flag}    ${False}
    run keyword if     ${if_commissioning}    Run Keyword And Ignore Error  Stop Btslog With Path Check    target_dir=${SAVE LOG DIRECTORY}
    # https://jiradc.ext.net.nokia.com/browse/REX-25419
    [Teardown]    Run Keyword If    '${suite_setup_fail_flag}'=='${True}'    run keyword and ignore error        Requset Configuration Id Report

SISO Coam Suite Teardown
    [Arguments]    ${gnb_index}=0
    robot_common_operations.Common Suite Teardown
    log to console    \n***SISO Coam Suite Teardown***
    ${connection}    set variable if    ${gnb_index}==0    GNB_OAM    GNB_OAM_${gnb_index}
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
    ...    connection=${connection}    gnb_index=${gnb_index}
    run keyword if    ${save_snapshot} and ${suite_setup_fail_flag}    run keywords
    ...    Generate suite log path                         AND
    ...    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}    AND
    ...    Capture RU logs    target_dir=${SUITE_LOG_PATH}    connection=${connection}     gnb_index=${gnb_index}    AND
    ...    Save Coam Snapshot    target_dir=${SUITE_LOG_PATH}    connection=${connection}    AND
    ...    Save Coam im snapshot    target_dir=${SUITE_LOG_PATH}    connection=${connection}    AND
    ...    Run Keyword And Ignore Error   Stop Btslog With Path Check    target_dir=${SUITE_LOG_PATH}
    ...    ELSE
    ...    log to console    don't collect snapshot in suite teardown!!!
    COAM Teardown gnb connections    connection=${connection}
    Run Keyword And Ignore Error    process.Terminate All Processes    kill=True

SISO Coam Test Setup
    [Arguments]    ${gnb_index}=0    ${fail_with_alarms}=${False}    ${allowed_faults_ids}=${None}
    ...    ${enable_err_wrn}=${False}    ${is_ru_log_collecting_enable}=${False}
    Log    message=\nArgument is_ru_log_collecting_enable=${is_ru_log_collecting_enable} is not used and will be removed in the future.
    Set Test Variable    ${enable_err_wrn}
    log to console    \n***SISO Coam Test Setup***
    log to console    gNB CU type:${gNb_CuType}
    log to console    Active_SW_version(gNB):${Active_SW_version}
    run keyword if    '${gNb_CuType}'=='NSA' or '${gNb_CuType}'=='SA+NSA'
    ...    Run Keyword And Ignore Error    Log to console    Active_SW_version(eNB):${enb_active_version}
    Generate test case log path
    ${time_stamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    set test variable  ${TS_CASE_LOG_PATH}    ${TS_CASE_LOG_PATH}/${time_stamp}/
    create directory   ${TS_CASE_LOG_PATH}
    Set Test Variable    ${SAVE LOG DIRECTORY}    ${TS_CASE_LOG_PATH}
    log to console  case log path:${TS_CASE_LOG_PATH}
    ${connection}    set variable if    ${gnb_index}==0    GNB_OAM    GNB_OAM_${gnb_index}
    run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
    ...    connection=${connection}    gnb_index=${gnb_index}
    ${ru_info}    COAM get all ru detail info    connection=${connection}
    ${ru_value}    get dictionary values    ${ru_info}
    ${ru_info}    Set variable    ${ru_value}[0]
    run keyword and ignore error  should contain  ${TEST_NAME}  ${ru_info}[productName]
    ${ru_status}    Run Keyword And Return Status    COAM Check GNB RU status    connection=${connection}
    ${cell_status}    Run Keyword And Return Status    Check all cells info should be onair    connection=${connection}
    ${Status}    ${key}   run keyword and ignore error   get specified scf
    ${SCF_Path}    set variable if      '${Status}'=='PASS'    ${key}[0]    ${Golden_SCF_Path}
    ${SCF_Status}    set variable if      '${Status}'=='PASS'    ${key}[1]    ${False}
    Set Test Variable    ${Case_SCF_Path}    ${SCF_Path}
    Run Keyword If    ${ru_status}==${False} or ${cell_status}==${False} or ${SCF_Status}==${True} and ${gnb_index}==0
    ...    Commissioning SCF And Check On Air      scf_path=${SCF_Path}
    # WESTLAKE-10940 restore the blocked BTS by the alarm in previous case before initiating watchdog tool
    # WESTLAKE-12508 restore CONFIGURATION before initiating watchdog tool
    robot_common_operations.Common Case Setup    gnb_index=${gnb_index}    fail_with_alarms=${fail_with_alarms}
    ...    allowed_faults_ids=${allowed_faults_ids}    enable_ru_log=${is_ru_log_collecting_enable}
    IF    ${enable_err_wrn}
        Start BTSlogs Collection In Log Server    Test_PC_IP=${Test_PC_IP}
        ...    Test_PC_username=${Test_PC_username}    Test_PC_password=${Test_PC_password}    btslog_path=/tmp/btslog2
        ...    btslog_launcher=/opt/btslog/btslog_launcher    btslog_launcher_path=/opt/btslog/btslog
        sleep     3s
    ELSE
        Start Btslog With Path Check
    END
    Run Keyword And Ignore Error    Config load RMOD Serial log by Common KW
    Run Keyword And Ignore Error    selenium_coam.close_browser
    ${ue_reboot_dict}    create dictionary
    set test variable    ${ue_reboot_dict}


SISO Coam Test Teardown
    [Arguments]    ${gnb_index}=0    ${is_case_teardown}=${True}    ${is_check_historyalarm}=${False}
    ...    ${perform_case_scf}=${False}    ${allowed_faults_ids}=${None}
    log to console    \n***SISO Coam Test Teardown***
    # LEOPARD-2235 teardown the watchdog tool earlier to reduce the logs collection failure probability
    robot_common_operations.Common Case Teardown
    ${connection}    set variable if    ${gnb_index}==0    GNB_OAM    GNB_OAM_${gnb_index}
    run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
    ...    connection=${connection}    gnb_index=${gnb_index}
    ${ru_status}   run keyword and ignore error   COAM Check GNB RU status    connection=${connection}
    log to console  RU status: ${ru_status}
    ${cell_status}    Run Keyword And Return Status    Check all cells info should be onair    connection=${connection}
    should be true    ${cell_status}
    ${allowed_faults}    Copy List    ${ALLOWED_FAULT}
    IF    ${allowed_faults_ids} != ${None}
        @{fault_ids_list}=    Split String    ${allowed_faults_ids}    ,
        FOR    ${fault_id}    IN    @{fault_ids_list}
            ${fault_id_stripped}=    Strip String    ${fault_id}
            ${fault_id_int}=    Convert To Integer    ${fault_id_stripped}
            ${fault_dict}=    Create Dictionary    faultId=${fault_id_int}
            Append To List    ${allowed_faults}    ${fault_dict}
        END
    END
    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${allowed_faults}
    ...    connection=${connection}
    should be true    ${alarm_status}
    ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist
    ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}    connection=${connection}
    run keyword if    ${is_check_historyalarm}    should be true    ${history_alarm_status}
    IF    ${enable_err_wrn}
        Stop BTSlogs Collection And Download Logs To Log Server
        ${ute_env}    run keyword and return status    run keywords
        ...    Variable Should Exist    ${CONFIGURATION}    AND    Variable Should Exist    ${ENB_BUILD}
        ${files_system}   Set Variable If    ${ute_env}    /dev/mapper/vg_sys-lv_home    /dev/vda2
        Run Keyword And Continue On Failure    Check ERR Or WRN From Syslog    sys_logs_path=${UTE_syslogs_path}    UTE_logs_path=${UTE_logs_path}
        ...    base_file=${Base_ERR_WRN_csv_path}   Expected_ERR_WRN_diff_number=0    Expected_ERR_WRN_deviation=0    Delete_old_ERR_WRN=20
        ...    filter_list=[ERR]    Fail_Case=True    Clear_log=True    FilesSystem=${files_system}    Max_used_space_ratio=0.7
    ELSE
        Stop Btslog With Path Check    target_dir=${SAVE LOG DIRECTORY}
    END
    Run Keyword And Ignore Error    Get RMOD Serial log download by Common KW
    ...    rmod_serial_config_load=${RMOD_SERIAL_INFO}    target_dir=${SAVE LOG DIRECTORY}
    ${test_fail_flag}    run keyword if    ${is_case_teardown}    run keyword if test failed
    ...    set variable    ${True}
    ${test_fail_flag}    set variable if    ${test_fail_flag}    ${True}    ${False}
    run keyword if    ${save_snapshot} and ${test_fail_flag}    run keywords
    ...    Capture RU logs    target_dir=${SAVE LOG DIRECTORY}    connection=${connection}     gnb_index=${gnb_index}    AND
    ...    Save Coam Snapshot    target_dir=${SAVE LOG DIRECTORY}    connection=${connection}    AND
    ...    Save Coam im snapshot    target_dir=${SAVE LOG DIRECTORY}    connection=${connection}
    ...    ELSE
    ...    log to console    don't collect snapshot in test teardown!!!
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    Run Keyword If    ${perform_case_scf} and ${gnb_index}==0
    ...    Commissioning SCF And Check On Air      scf_path=${Case_SCF_Path}
    run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}
    run keyword and ignore error    csn.Disconnect    connection=ASIK Master
    CI_interface.Common Case Teardown    connection=${connection}    gnb_index=${gnb_index}
    log to console   \nget ue reboot dict:${ue_reboot_dict}

    # Stop to Collect and Save RU Logs
