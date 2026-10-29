*** Settings ***
Library          taf.collectors.core    WITH NAME    core
Library          OperatingSystem
#Library         BuiltIn
Library          taf.collectors.btslog    WITH NAME    btslog
Library           taf.gnb.oam.coam.admin    WITH NAME    coam
Resource      ./testsuite/Bangalore/ORAN/resources/robot/expected_alarm.robot


*** Keywords ***
Filter Gnb_syslog
    [Arguments]    ${output}    ${filter_message_file}    ${output_file_path}
    ${files_list}=    String.Split To Lines    ${output}
    FOR    ${file}    IN    @{files_list}
         ${rc}    ${output}=    OperatingSystem.Run And Return Rc And Output    tar -xzvf ${file}
         Log    ${output}
         Filter ERR WRN Message From Syslog By One File    ${output}    ${filter_message_file}    ${output_file_path}
    END
    ${status}=    Run Keyword And Return Status    OperatingSystem.File Should Be Empty    ${output_file_path}
    Run Keyword If    "${status}"=="${False}"    Show Fatal Log    ${output_file_path}
    Run Keyword If    "${status}"=="${False}"    Fail     msg=There are fatal errors in Gnb syslog!!!

Show Fatal Log
    [Arguments]    ${output_file}
    ${output}=    OperatingSystem.Get File    ${output_file}
        Log    ---In ${output_file}:---${output}    WARN

Filter ERR WRN Message From Syslog By One File
    [Arguments]    ${log_file}    ${filter_message_file}    ${output_file}
    [Documentation]    This keyword is used to filter error and warnning message from one file.
    ...    | Input Parameters | Man. | Description |
    ...    | ${log_file} | Yes | log file which needs to be filterred. |
    ...    | ${filter_message_file} | Yes | txt file which contains filterred message |
    ...    | ${output_file} | Yes | txt file which contains output message |
    ...    Examples:
    ...    | Filter ERR WRN Message From Syslog By One File | ${CURDIR}/syslog.txt    ${CURDIR}/filter_log.txt    ${CURDIR}/output_log.txt |
    OperatingSystem.File Should Exist    ${filter_message_file}
    ${content}=    OperatingSystem.Get File    ${filter_message_file}
    BuiltIn.Log to Console   ${content}
    ${content_list}=    String.Split To Lines    ${content}
    BuiltIn.Log to console  ${content_list}
    FOR    ${filter_item}    IN    @{content_list}
         OperatingSystem.Run And Return Rc And Output    grep ${filter_item} ${log_file}>>${output_file}
    END
	
Verify Syslog Anomalies
#   [Arguments]    ${log_path}=${OUTPUT_DIR}/btslog    ${filter_message_file}=${CURDIR}/filter_msg.txt
#    ...    ${output_file_path}=${OUTPUT_DIR}/syslog_anamoly.txt
    OperatingSystem.Run And Return Rc And Output    rm -f ${OUTPUT_DIR}/syslog_anamoly.txt
    ${rc}    ${output}=    OperatingSystem.Run And Return Rc And Output    find ${OUTPUT_DIR}/btslog -maxdepth 1 -name syslog_files.tgz
    Run Keyword If    "${output}"==""    Fail     msg=There is no syslog_files.tgz caught!!!
    Run Keyword If    "${output}"!=""    Filter Gnb_syslog    ${output}    ${CURDIR}/filter_msg.txt    ${OUTPUT_DIR}/syslog_anamoly.txt
	
	
Collect BTS Syslog 

    btslog.create_btslog_collector
    ...    name=btslog
    ...    log_dir=/tmp/btslog2
    core.setup_collectors      names=btslog
    core.set_suite_alias      btslog
    core.start_collectors      names=btslog
    Sleep  10
Stop BTS Syslog
    core.stop_collectors      names=btslog
    core.collect_collectors      names=btslog      target_dir=${OUTPUT_DIR}
    core.teardown_collectors      names=btslog

Test Setup
    Log to console    \n--Test Setup--\n
    coam.setup_admin
    Log to console  \n sw_version \n
    ${sw_version}=    coam.get_sw_version
    Log To Console    \n--Active alarms--\n
    coam.Get Active alarms
    ${allowed_alarms}=    Expected_alarm
    Watch alarms           allowed_alarms=${allowed_alarms}
    Collect BTS Syslog
    current_memoryusage

Test Teardown
    Log to console   --Test teardown--
    post_memoryusage
    Stop BTS Syslog
    Verify Syslog Anomalies
    taf.sbts.oam.coam.admin.Teardown All Aliases For Admin

