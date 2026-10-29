*** Settings ***
Documentation    Author: xiang.5.li@nokia-sbell.com
...              \n Please do not edit the existing keywords in this file without testing.
...              \n list of available keywords in CORE.
...              \n https://docs.taf.nsn-rdnet.net/taf.collectors.core/2.0.10/1/robot.collector_keywords/
Library          ${EXECDIR}/testsuite/Beijing/ET/common/resources/lib/common4egate.py
Library          ${EXECDIR}/testsuite/Beijing/ET/common/resources/lib/common4syslog.py

*** Keywords ***
_keywords_all
    Common Analysis For Egate
    Common Analysis For syslog
    Find Gnb Syslog By Log Path
    Tar Gnb syslog by log path


Common Analysis For Egate
    [Arguments]         ${log_path}=${TEST_LOG_DIRECTORY}    ${egate_log_path}=${EMPTY}    ${cfg_path}=${EMPTY}
    [Documentation]     This keyword use for analysis egate log
    ...                 ${log_path} = ${TEST_LOG_DIRECTORY}
    ...                 ${egate_log_path}=/home/ute/result/xxxxxx/xxxxx/egate_console.log
    ...                 ${cfg_path}=/home/ute/MN/UTE/robotws/testsuite/Beijing/ET/CB007601/CB007601-A_2-1/resources/cfg_egate.json
    ...                 example: Common Analysis For Egate    ${egate_log_path}    ${cfg_path}
    egate_checker_py       ${log_path}    ${egate_log_path}    ${cfg_path}

Common Analysis For Syslog
    [Arguments]         ${log_path}    ${syslog}    ${cfg_path}
    [Documentation]     This keyword use for analysis syslog
    ...
    ...                 ${syslog}=['/home/ute/result/xxx/xxx/Gnb_syslog_20220427132513_0', '/home/ute/result/xxx/xxx/Gnb_syslog_20220427132519_0']
    ...                 ${cfg_path}=/home/ute/MN/UTE/robotws/testsuite/Beijing/ET/CB007601/CB007601-A_2-1/resources/cfg_syslog.json
    ...                 example: Common Analysis For Egate    ${syslog}    ${cfg_path}
    syslog_checker_py      ${log_path}    ${syslog}    ${cfg_path}


Find Gnb Syslog By Log Path
    [Arguments]    ${log_path}
    [Documentation]    This keyword is used to find syslog path.
    ...    | Input Parameters | Man. | Description |
    ...    | ${log_path} | Yes | absolute log path, for example: ${SUITE_LOG_DIRECTORY} |
    ...    Examples:
    ...    | Find Gnb Syslog By Log Path | ${SUITE_LOG_DIRECTORY}
    ${rc}    ${output}=    OperatingSystem.Run And Return Rc And Output    find ${log_path} -maxdepth 1 -name Gnb*syslog.tar.gz
    [return]    ${output}

Tar Gnb syslog by log path
    [Arguments]    ${log_path}
    [Documentation]   This keyword is used to find syslog and tar.
    ...    Examples:
    ...    | Find Gnb Syslog By Log Path | ${SUITE_LOG_DIRECTORY}
    ${rc}    ${output}=    OperatingSystem.Run And Return Rc And Output    find ${log_path} -maxdepth 1 -name Gnb*syslog.tar.gz
    ${files_list}=    String.Split To Lines    ${output}
    ${syslog_list}    Create List
    FOR    ${file}    IN    @{files_list}
         ${rc}    ${output}=    OperatingSystem.Run And Return Rc And Output    cd ${log_path};tar -xzvf ${file}
         Log    ${output}
         Append To List    ${syslog_list}    ${log_path}/${output}
    END
    Set Suite Variable    ${SYSLOG_LIST}    ${syslog_list}

Convert Ttitrace From Pcap To Excelcsv bj
    [Arguments]    ${log_path}=${TEST_LOG_DIRECTORY}/ttitrace_streaming/    ${names}=l2stream3_ttitrace
    ${file_path}=    Set Variable    ${log_path}/${names}/tcpdump_ttitrace/tcpdump_ttitrace.pcap
    OperatingSystem.Run    mkdir -p ${log_path}; cp -r "${file_path}" ${log_path}
    EVENTDECODER.Create Eventdecoder Converter
    ...    name=converter
    ...    input_file_path=${file_path}
    ...    output_file_format=excelCsv
    ...    excel_csv_options=-w
    EVENTDECODER.Convert
    ...    name=converter
    OperatingSystem.Run    mkdir -p ${log_path}
    OperatingSystem.Run    cp ${EXECDIR}/output_dl.csv ${log_path};cp ${EXECDIR}/output_ul.csv ${log_path}

Format Tti In Stream Mode bj
    [Arguments]    ${input_csv_name}    ${output_csv_name}    ${filters}=${EMPTY}
    [Documentation]    This keyword is to convert tti collected by stream mode.
    ...    Parameters same as keyword: Format Tti In Snapshot Mode
    Run Keyword If    '${filters}'=='${EMPTY}'    TtiSMConvert.Format Tti Stream Mode No Filters    ${input_csv_name}    ${output_csv_name}
    ...    ELSE    TtiSMConvert.Format Tti Stream Mode With Filters    ${input_csv_name}    ${output_csv_name}    ${filters}

Decode Ttitrace Log bj
    [Arguments]    ${log_dir}=${TEST_LOG_DIRECTORY}/ttitrace_streaming/
    Log To Console        convert tti trace...
    Convert Ttitrace From Pcap To Excelcsv bj    ${log_dir}
    Log To Console        format tti trace...
    Format Tti In Stream Mode bj    ${log_dir}/output_dl.csv        ${log_dir}/format_output_dl.csv
    Format Tti In Stream Mode bj    ${log_dir}/output_ul.csv        ${log_dir}/format_output_ul.csv
