*** Settings ***
Library       ./python/tti_stream_mode_convert.py    WITH NAME    TtiSMConvert

*** Keywords ***
Format Tti In Stream Mode
    [Arguments]    ${input_csv_name}    ${output_csv_name}    ${filters}=${EMPTY}
    [Documentation]    This keyword is to convert tti collected by stream mode.
    ...    Parameters same as keyword: Format Tti In Snapshot Mode
    Run Keyword If    '${filters}'=='${EMPTY}'    TtiSMConvert.Format Tti Stream Mode No Filters    ${input_csv_name}    ${output_csv_name}
    ...    ELSE    TtiSMConvert.Format Tti Stream Mode With Filters    ${input_csv_name}    ${output_csv_name}    ${filters}

Filter ERR WRN Message From Syslog By Log Path
    [Arguments]    ${log_path}    ${filter_message_file}    ${output_file_path}
    [Documentation]    This keyword is used to filter error and warnning message from syslog path.
    ...    | Input Parameters | Man. | Description |
    ...    | ${log_path} | Yes | absolute log path, for example: ${SUITE_LOG_DIRECTORY} |
    ...    | ${filter_message_file} | Yes | txt file which contains filterred message |
    ...    | ${output_file} | Yes | txt file which contains output message |
    ...    Examples:
    ...    | Filter ERR WRN Message From Syslog By Log Path | ${SUITE_LOG_DIRECTORY}    ${CURDIR}/filter_msg.txt    ${CURDIR}/output_log.txt |
    OperatingSystem.Run And Return Rc And Output    rm -f ${output_file_path}
    ${rc}    ${output}=    OperatingSystem.Run And Return Rc And Output    find ${log_path} -maxdepth 1 -name Gnb_syslog.tar.gz
    Set Suite Variable    ${FILTER_SYSLOG_STATUS}    ${FALSE}
    Run Keyword If    """${output}"""!=""    Unzip And Filter Gnb_syslog    ${output}    ${filter_message_file}    ${output_file_path}

Unzip And Filter Gnb_syslog
    [Arguments]    ${output}    ${filter_message_file}    ${output_file_path}
    ${files_list}=    String.Split To Lines    ${output}
    OperatingSystem.Run    rm -rf Gnb_syslog_*
    ${rc}    ${output}=    OperatingSystem.Run And Return Rc And Output    tar -xzvf ${files_list}[0]
    Log    ${output}
    ${files_list_1}=    String.Split To Lines    ${output}
    Run Keyword If    """${output}"""!=""    Filter ERR WRN Message From Syslog    Gnb_syslog_*
    ...    ${filter_message_file}    ${output_file_path}
    ${status}=    Run Keyword And Return Status    File Should Not Be Empty    ${output_file_path}
    Set Suite Variable    ${FILTER_SYSLOG_STATUS}    ${status}

Filter ERR WRN Message From Syslog
    [Arguments]    ${log_file}    ${filter_message_file}    ${output_file}
    [Documentation]    This keyword is used to filter error and warnning message from one file.
    ...    | Input Parameters | Man. | Description |
    ...    | ${log_file} | Yes | log file which needs to be filterred. |
    ...    | ${filter_message_file} | Yes | txt file which contains filterred message |
    ...    | ${output_file} | Yes | txt file which contains output message |
    ...    Examples:
    ...    | Filter ERR WRN Message From Syslog By One File | ${CURDIR}/syslog.txt    ${CURDIR}/filter_log.txt    ${CURDIR}/output_log.txt |
    OperatingSystem.File Should Exist    ${filter_message_file}
    ${content}=    Get File    ${filter_message_file}
    ${content_list}=    String.Split To Lines    ${content}
    FOR    ${filter_item}    IN    @{content_list}
         OperatingSystem.Run And Return Rc And Output    egrep "${filter_item}" ${log_file}>>${output_file}
    END
