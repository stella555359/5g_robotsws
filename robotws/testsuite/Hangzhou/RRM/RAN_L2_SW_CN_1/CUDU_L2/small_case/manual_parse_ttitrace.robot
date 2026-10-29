*** Settings ***
Documentation
...    to make TA work, actInternalTrace=true, actCli=true
...    mybot -v log_dir=*;manual_parse_ttitrace.robot
#Suite Setup    Run    sh /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_L2_SW_CN_1/CUDU_L2/tools/local_testline/update_ttitrace.sh
Resource    ./../common_setup_teardown.robot
*** Variables ***
${log_dir}    /home/ute/test_logs/test_log202211090719AM/log/
${file_path}    ${log_dir}/tcpdump_ttitrace.pcap
*** Test Cases ***
Decode Ttitrace
    [Tags]    case1
    ${start_time}=    Print Time    start to decode ttitrace...
    Decode Ttitrace Log    ${log_dir}
    ${stop_time}=    Print Time    stop to decode ttitrace.

*** Keywords ***
Decode Ttitrace Log
    [Arguments]    ${log_dir}=${OUTPUT_DIR}/ttitrace_streaming/
    Convert Ttitrace From Pcap To Excelcsv    ${log_dir}
    Format Tti In Stream Mode    ${log_dir}/output_dl.csv        ${log_dir}/format_output_dl.csv
    Format Tti In Stream Mode    ${log_dir}/output_ul.csv        ${log_dir}/format_output_ul.csv

Convert Ttitrace From Pcap To Excelcsv
    [Arguments]    ${log_path}=${OUTPUT_DIR}/ttitrace_streaming/    ${names}=l2stream3_ttitrace
    #${file_path}=    Set Variable    ${log_path}/${names}/tcpdump_ttitrace/tcpdump_ttitrace.pcap
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
