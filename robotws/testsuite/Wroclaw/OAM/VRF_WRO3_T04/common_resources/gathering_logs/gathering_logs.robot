*** Settings ***
Documentation   The KW for collecting logs

Library         taf.sw.syslog              WITH NAME   taf_syslog
Library         taf.sbts.oam.coam.admin    WITH NAME   coam_admin
Resource        ../scout/scout_operations.robot
Resource        ../alarms/alarm.robot
Resource        ../alarms/watchdog.robot
Resource        taf/rfrl/common_resources/common_step/interface.robot
Resource        taf/rfrl/scrambling_logs_collector/Keywords.robot

*** Keywords ***
Common Gathering Logs for Common Suite Setup
    Set Suite Variable    ${TEST_NAME}    ${SUITE_NAME}
    Create Global Directory For Gathering Logs
    gathering_logs._Collect Snapshot File    log_dir=${OUTPUT_DIR}/${SUITE_NAME}/snapshot/snapshot_suite_setup.zip
    Run Keyword and Ignore Error   No Faults Except Allowed Should Be Present On BTS

Common Gathering Logs for Test Setup
    Start Watchdog
    Set Test Variable       ${TEST_OUTPUT_DIR}          ${OUTPUT_DIR}/${TEST_NAME}
    gathering_logs._Setup Syslog
    Run Keyword and Ignore Error  Generate and Send Configuration ID to ReP

Airphone Gathering Logs for Test Setup
    Start Watchdog for Airphone
    gathering_logs._Setup Syslog
    Set Test Variable       ${TEST_OUTPUT_DIR}          ${OUTPUT_DIR}/${TEST_NAME}
    Run Keyword and Ignore Error  Generate and Send Configuration ID to ReP

Common Gathering Logs for Test Teardown
    Check if Disallowed Alarm was Detected during Watchdog
    Stop Watchdog
    No Faults Except Allowed Should Be Present On BTS
    gathering_logs._Collect Snapshot File   log_dir=${OUTPUT_DIR}/${TEST_NAME}/snapshot_test_teardown.zip
    gathering_logs._Collect Syslog Files
    gathering_logs._Collect Swconfig File
    Run Keyword And Ignore Error                  interface.Common Step Trigger

Airphone Gathering Logs for Test Teardown
    Check if Disallowed Alarm was Detected during Watchdog
    Stop Watchdog
    No Faults Except Allowed Should Be Present On BTS
    gathering_logs._Collect Snapshot File   log_dir=${OUTPUT_DIR}/${TEST_NAME}/snapshot_test_teardown.zip
    gathering_logs._Collect Syslog Files
    gathering_logs._Collect Swconfig File
    Run Keyword And Ignore Error                  interface.Common Step Trigger

Common Gathering Logs for Common Suite Teardown
    Run Keyword And Continue On Failure           Check BTS Status After Some Time  15min

_Setup Syslog
    [Arguments]  ${log_dir}=${OUTPUT_DIR}/${TEST_NAME}/syslog
    Run Keyword And Ignore Error  taf_syslog.Teardown All Aliases For Syslog
    Wait Until Keyword Succeeds  5m  30s  taf_syslog.start syslog  log_dir=${log_dir}  log_name=SYSLOG  file_limit=104857600  # 100MB
    ...  add_line_number=True  alias=taf_syslog

_Collect Snapshot File
    [Arguments]    ${connection}=${None}    ${log_dir}=None
    Log  Snapshot collecting  console=${true}
    ${connection}=                 create_connection_if_not_exist
    ...                            connection=${connection}
    ...                            alias=temporary_admin_connection_loop
    ${timestamp}=  DateTime.Get Current Date  result_format=%d%m%Y%H%M%S  exclude_millis=True
    Set Variable If    '${log_dir}'=='None'    ${TEST_NAME}/snapshot/snapshot_${timestamp}.zip
    coam_admin.Collect Snapshot  target_file_name=${log_dir}  timeout=1500    connection=${connection}
    [Teardown]            Run Keyword And Ignore Error
    ...                   Disconnect From Admin
    ...                   connection=temporary_admin_connection

_Collect Syslog Files
    [Arguments]    ${log_dir}=${OUTPUT_DIR}/${TEST_NAME}/syslog/syslog.tar.gz
    Log  Syslog collecting  console=${true}
    taf_syslog.Collect Syslog Results  destination=${log_dir}  unzip=False  alias=taf_syslog
    [Teardown]  taf_syslog.Teardown All Aliases For Syslog

_Collect Swconfig File
    Log  swconfig collecting  console=${true}
    ssh.Connect to    ${LMP_IP}    ${SSH_USERNAME}    ${SSH_PASSWORD}
    ssh.Download File    /ffs/run/swconfig.txt    ${OUTPUT_DIR}/${TEST_NAME}/swconfig.txt
    [Teardown]    ssh.Disconnect

Create Global Directory For Gathering Logs
    [Documentation]  This keyword please use one time on start your Suite Setup (or directly after James).
    ...    This keyword make the empty directory as logs container. If you use this keyword multiple
    ...    times - you will have a lot of folders with folder with logs - you should avoid this.
    ${date}=  DateTime.Get Current Date
    Set Global Variable  ${global_date}  ${date}
    Set Global Variable  ${logs_path}    ${OUTPUT DIR}/TRS_SEC_${date[0:10]}/${date[11:19]}
    Log  \nLOGS WILL BE GATHERED TO: ${logs_path}  console=True
    Run  mkdir -p ${logs_path}
