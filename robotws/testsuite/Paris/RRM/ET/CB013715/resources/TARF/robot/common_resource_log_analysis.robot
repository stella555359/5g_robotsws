*** Settings ***
Documentation    log analysis

Library    ute_syslog
Library    OperatingSystem
Library    String

Library    ./../python/syslog_checker.py
Library    ../../../../resources/DSS/python/robot_extension.py          WITH NAME          robot_extension

*** Variables ***
@{L1_ERR_whitelist}     Received unexpected PDCCH send request message
@{L1_WRN_whitelist}     nrDl DU Stats<0> part
...    HB/StartStop/processStartStopHbRequestOnThisProcess more conditional
...    drop_alias_client_msg: Master node ID unknown
...    nbOfEventsToTrigAutoBTSSnapshot RAD should be set to 1 by operator for BBURU capture type

*** Keywords ***
###################syslog###########################
Get L1 ${err_wrn} with alias ${alias}
    ${output}    ute_syslog.Message Should Exist In Syslog File    regexp=${err_wrn}    alias=${alias}
    BuiltIn.log    L1 ${err_wrn} is ${output}
    Run Keyword If    'ERR' in '${err_wrn}'    Set Test Variable    ${err_info}    ${output}
    Run Keyword If    'WRN' in '${err_wrn}'    Set Test Variable    ${wrn_info}    ${output}

Check L1 ERR and WRN in syslog
    [Arguments]    ${alias}=iphy1
    ${err_status}=    Run Keyword And Return Status    Get L1 ERR/l1_application with alias ${alias}
    ${wrn_status}=    Run Keyword And Return Status    Get L1 WRN/l1_application with alias ${alias}
    ${ignore_err_dicts}    ${final_err_list}    Run Keyword If    ${err_status}    syslog_checker.Get_ERR_and_WRN_info
    ...    ${err_info}    ${L1_ERR_whitelist}
    ${ignore_wrn_dicts}    ${final_wrn_list}    Run Keyword If    ${wrn_status}    syslog_checker.Get_ERR_and_WRN_info
    ...    ${wrn_info}    ${L1_WRN_whitelist}

    Run Keyword And Continue On Failure    Should Be True    '''${final_err_list}'''=='None'
    ...    [ ERROR ] /ERR is visible in ${alias} SYSLOG, , Plz Check log\n${final_err_list}\n
    robot_extension.Run Keyword And Warn On Failure   Should Be True    '''${final_wrn_list}'''=='None'
    ...    [ WARN ] /WRN is visible in ${alias} SYSLOG, Plz Check log\n
    # Run Keyword And Warn On Failure    Should Be True    '''${ignore_err_dicts}'''=='None'
    # ...    [ ERROR ] /ERR in white list is visible in SYSLOG:\n${ignore_err_dicts}
    # Run Keyword And Warn On Failure    Should Be True    '''${ignore_wrn_dicts}'''=='None'
    # ...    [ ERROR ] /WRN in white list is visible in SYSLOG:\n${ignore_wrn_dicts}
    [return]    ${final_err_list}    ${final_wrn_list}

Filter ERR WRN Message From Syslog By Log Path
    [Arguments]    ${log_path}    ${filter_message_file}    ${output_file_path}
    [Documentation]    This keyword is used to filter error and warnning message from syslog path.
    ...    | Input Parameters | Man. | Description |
    ...    | ${log_path} | Yes | absolute log path, for example: ${SUITE_LOG_DIRECTORY} |
    ...    | ${filter_message_file} | Yes | txt file which contains filterred message |
    ...    | ${output_file} | Yes | txt file which contains output message |
    ...    Examples:
    ...    | Filter ERR WRN Message From Syslog By Log Path | ${SUITE_LOG_DIRECTORY} ${CURDIR}/filter_msg.txt ${CURDIR}/output_log.txt |
    OperatingSystem.Run And Return Rc And Output    rm -f ${output_file_path}
    ${rc}    ${output}=    OperatingSystem.Run And Return Rc And Output    find ${log_path} -maxdepth 1 -name Gnb*syslog.tar.gz
    Run Keyword If    "${output}"!=""    Filter Gnb_syslog    ${output}    ${filter_message_file}    ${output_file_path}

Filter Gnb_syslog
    [Arguments]    ${output}    ${filter_message_file}    ${output_file_path}
    ${files_list}=    String.Split To Lines    ${output}
    FOR    ${file}    IN    @{files_list}
        ${rc}    ${output}=    OperatingSystem.Run And Return Rc And Output    tar -xzvf ${file}
        BuiltIn.Log    ${output}
        Filter ERR WRN Message From Syslog By One File    ${output}    ${filter_message_file}    ${output_file_path}
    END
    ${status}=    Run Keyword And Return Status    File Should Be Empty    ${output_file_path}
    Set Suite Variable    ${FILTER_SYSLOG_STATUS}    ${status}
    #    Run Keyword If    "${status}"=="${False}"    Show Fatal Log    ${output_file_path}

Show Fatal Log
    [Arguments]    ${output_file}
    ${output}=    Get File    ${output_file}
    BuiltIn.Log    ---In ${output_file}:---${output}    WARN

Filter ERR WRN Message From Syslog By One File
    [Arguments]    ${log_file}    ${filter_message_file}    ${output_file}
    [Documentation]    This keyword is used to filter error and warnning message from one file.
    ...    | Input Parameters | Man. | Description |
    ...    | ${log_file} | Yes | log file which needs to be filterred. |
    ...    | ${filter_message_file} | Yes | txt file which contains filterred message |
    ...    | ${output_file} | Yes | txt file which contains output message |
    ...    Examples:
    ...    | Filter ERR WRN Message From Syslog By One File | ${CURDIR}/syslog.txt ${CURDIR}/filter_log.txt ${CURDIR}/output_log.txt |
    OperatingSystem.File Should Exist    ${filter_message_file}
    ${content}=    Get File    ${filter_message_file}
    ${content_list}=    String.Split To Lines    ${content}
    FOR    ${filter_item}    IN    @{content_list}
        OperatingSystem.Run And Return Rc And Output    egrep "${filter_item}" ${log_file}>>${output_file}
    END
