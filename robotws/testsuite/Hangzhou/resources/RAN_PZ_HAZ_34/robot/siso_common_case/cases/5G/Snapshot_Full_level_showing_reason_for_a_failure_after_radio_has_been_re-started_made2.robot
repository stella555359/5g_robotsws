*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
*** Variables ***

*** Keywords ***
Snapshot_Full_level_showing_reason_for_a_failure_after_radio_has_been_re-started_made2
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] Purpose of this case is to check Snapshot full level showing reason for a failure after
    ...     radio has been re-started.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 09.06.2021 - - Created
    ...    *******************
    ...    Owner_zhihao.shi@nokia-sbell.com
    ${snapshot_file_path}    COAM Save snapshot via rest api    timeout=1500
    ${timestamp}    robot.libraries.DateTime.Get Current Date    result_format=%Y-%m-%d%H:%M:%S
    ${zipout}    Set Variable    zipout_${timestamp}
    Extract Zip File    ${snapshot_file_path}    ${TS_CASE_LOG_PATH}/${zipout}
    ${faurt_log_file}    Run    command=cat ${TS_CASE_LOG_PATH}/${zipout}/snapshot_file_list.txt|grep faultLogs
    Should Contain    ${faurt_log_file}    faultLogs
#    [Arguments]    ${init_value}=-59.0    ${target_value}=-10.0    ${new_timeout}=240
#    ${original_value}    Get SnapshotTimeoutS original value
#    Trigger Fault 1920 and 1907    init_value=${init_value}    target_value=${target_value}
#    ...    SnapshotTimeoutS=${original_value}   new_timeout=${new_timeout}
#    log to console    \n    sleep   60min
#    sleep    60min
#    Check fault Exist in RU and snapshot    fault_filter=1298    ru_fault_log_path=/mnt/runtime/fault-log/snapshot_status.txt
#    [Teardown]  recovery Fault 1920 and 1907    init_value=${target_value}    target_value=${init_value}
#    ...    SnapshotTimeoutS=${new_timeout}   new_timeout=${original_value}
