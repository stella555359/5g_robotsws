*** Settings ***
Documentation
...   This is for tti logs collect and decode keywords
...   Tti decoder install guide:https://confluence.ext.net.nokia.com/display/5GRANHZ/03_TTI+Trace+TA
...   install tti decoder manually:
...       sh testsuite/Hangzhou/RRM/RAN_L2_SW_CN_1/CUDU_L2/tools/local_testline/update_ttitrace.sh
...   During manually install tti decoder cannot install python package pandas and numpy
...       create file with content below:/home/ute/.pip/pip.conf
...          [global]
...          index-url = https://artifactory-hz1.int.net.nokia.com/artifactory/api/pypi/ute-pypi-virtual/simple
...          disable-pip-version-check = True

Library     taf.collectors.l2stream3    WITH NAME    L2STREAM3
Library     taf.converters.eventdecoder    WITH NAME    EVENTDECODER
Library     ./lib/tti_stream_mode_convert.py    WITH NAME    TtiSMConvert


*** Variables ***
&{TTITRACE_CONFIG_L2PS}            up_sw=L2Ps    trace_type=Component
&{TTITRACE_CONFIG_L2LO}            up_sw=L2Lo    trace_type=Component
&{TTITRACE_CONFIG_L2HIPDCP}        up_sw=L2HiPdcp    trace_type=Component
&{TTITRACE_CONFIG_L2HIRLC}         up_sw=L2HiRlc    trace_type=Component
@{L2STREAM_COMPONENT_CONFIG}       &{TTITRACE_CONFIG_L2HIPDCP}    &{TTITRACE_CONFIG_L2HIRLC}    &{TTITRACE_CONFIG_L2PS}    &{TTITRACE_CONFIG_L2LO}
@{L2STREAM_L2_PS_CONFIG}           &{TTITRACE_CONFIG_L2PS}
${SSH_CMD}                         sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1

*** Keywords ***
__Keywords only for searching should not use
    [Documentation]    this keyword only for searching keywords in the robot, should not use.
    Start Ttitrace With Streaming Mode
    Stop Ttitrace
    Decode Ttitrace Log

Start Ttitrace With Streaming Mode
    [Documentation]    Author: Wang Yixiang   Migrate from ET
    ...    This keyword is used to start ttitrace with streaming mode.
    ...    Start Ttitrace With Streaming Mode
    [Arguments]    ${collector_names}=l2stream3_ttitrace    ${l2_stream_configuration}=${L2STREAM_COMPONENT_CONFIG}
    ...    ${gnb_index}=0   ${SW_BRANCH}=None
    ...    ${eth_port_on_ute}=eth0
    ...    ${eth_ip_addr_on_ute}=${tl.test_pc.default_ssh_connection_details.addr}
    ...    ${localIpAddr}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    log to console    setup admin for ttitrace...

    Run Keyword If    '${SW_BRANCH}'=='None'    tti_logs.Get Software Version
    ${executor}=  Create Dictionary
    ...  host=${localIpAddr}
    ...  user=Nemuadmin
    ...  password=nemuuser
    ...  port=443
    ...  release=${SW_BRANCH}

    TCPDUMP.create tcpdump collector
    ...  name=tcpdump_ttitrace
    ...  options=-i ${eth_port_on_ute} udp and dst ${eth_ip_addr_on_ute} and dst port 5678
    ...  sudo_password=${tl.test_pc.default_ssh_connection_details.password}
    L2STREAM3.create_sbts_l2stream_collector
    ...  name=${collector_names}
    ...  destination_ip_addr=${eth_ip_addr_on_ute}
    ...  collector=tcpdump_ttitrace
    ...  l2_stream_configuration=${l2_stream_configuration}
    ...  webservice=${executor}
    ...  dscp=10
    L2STREAM3.Set Suite Alias
    ...  alias=${collector_names}
    CORE.setup_collectors
    ...  names=${collector_names}
    CORE.start_collectors
    ...  names=${collector_names}
    log to console    finish admin process for ttitrace,start to catch ttitrace log...

Stop Ttitrace
    [Documentation]    Author: Wang Yixiang   Migrate from ET
    [Arguments]    ${collector_names}=l2stream3_ttitrace    ${log_dir}=${TS_CASE_LOG_PATH}/ttitrace_streaming/
    log to console    stop catching ttitrace...
    CORE.stop_collectors
    ...  names=${collector_names}
    CORE.collect_collectors
    ...  names=${collector_names}    target_dir=${log_dir}
    CORE.teardown_collectors
    ...  names=${collector_names}
    ${file_path}    Set Variable    ${log_dir}/${collector_names}/tcpdump_ttitrace/tcpdump_ttitrace.pcap
    [Return]   ${file_path}

Decode Ttitrace Log
    [Documentation]    Author: Wang Yixiang   Migrate from ET
    [Arguments]    ${collector_names}=l2stream3_ttitrace    ${log_dir}=${TS_CASE_LOG_PATH}/ttitrace_streaming    ${format_tti_log}=${False}
    log to console    Start to decode ttitrace...
    ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    ${csv_file_path}   Convert Ttitrace From Pcap To Excelcsv    log_path=${log_dir}    collector_names=${collector_names}
    run keyword if   ${format_tti_log}   log to console    Start to format ttitrace...
    run keyword if   ${format_tti_log}   Format Tti In Stream Mode    ${csv_file_path}/tcpdump_ttitrace_dl.csv
    ...    ${csv_file_path}/format_output_dl.csv
    run keyword if   ${format_tti_log}   Format Tti In Stream Mode    ${csv_file_path}/tcpdump_ttitrace_ul.csv
    ...    ${csv_file_path}/format_output_ul.csv
    log to console    decode ttitrace finished.
    [Return]    ${csv_file_path}

Capture And Decode TTitrace
    [Documentation]    Author: Wang Yixiang   Migrate from ET
    [Arguments]    ${collector_names}=l2stream3_ttitrace    ${duration}=3
    Start Ttitrace With Streaming Mode    collector_names=${collector_names}
    Sleep    ${duration}s    reason=Wait for logs
    Stop Ttitrace    collector_names=${collector_names}
    ${csv_file_path}    Decode Ttitrace Log    collector_names=${collector_names}
    [Return]    ${csv_file_path}

Convert Ttitrace From Pcap To Excelcsv
    [Documentation]    Author: Wang Yixiang   Migrate from ET
    [Arguments]    ${log_path}=${TS_CASE_LOG_PATH}/ttitrace_streaming    ${collector_names}=l2stream3_ttitrace
    ${file_path}=    Set Variable    ${log_path}/${collector_names}/tcpdump_ttitrace/tcpdump_ttitrace.pcap
    ${output_file_path}   ${file_name}    OperatingSystem.Split Path    ${file_path}

    EVENTDECODER.Create Eventdecoder Converter
    ...    name=converter
    ...    input_file_path=${file_path}
    ...    output_file_format=excelCsv
    ...    excel_csv_options=-w
    ...    output_file_path=${output_file_path}
    EVENTDECODER.Convert
    ...    name=converter
    ${csv_file_path}    Set Variable    ${log_path}/${collector_names}
    [Return]     ${csv_file_path}

Format Tti In Stream Mode
    [Documentation]    Author: Wang Yixiang   Migrate from ET
    ...   This keyword is to convert tti collected by stream mode.
    [Arguments]    ${input_csv_name}    ${output_csv_name}    ${filters}=${EMPTY}
    Run Keyword If    '${filters}'=='${EMPTY}'    TtiSMConvert.Format Tti Stream Mode No Filters    ${input_csv_name}    ${output_csv_name}
    ...    ELSE    TtiSMConvert.Format Tti Stream Mode With Filters    ${input_csv_name}    ${output_csv_name}    ${filters}

Get Software Version
    [Documentation]    Author: Wang Yixiang   Migrate from ET
    [Arguments]    ${coam_connection}=GNB_OAM
    ${software_info_1}=    coam.Get Sw Version    connection=${coam_connection}
    Set Suite Variable    ${SOFTWARE_INFO}    ${software_info_1}
    Log    Software Version: ${SOFTWARE_INFO}    console=${True}    #5G21B_GNB_0000_000800_004084_0oeo9    5G21A_GNB_0011_000800_000601
    @{words}=    String.Split String    ${SOFTWARE_INFO}    _
    ${ENB_BUILD}=    Set Variable    ${words[0][0:4]}
    ${IS_SOFTWARE_KNIFE}=    Set Variable If    "${words[-1][0:3]}"=="000"    ${False}    ${True}
    #${ENB_BUILD}=    String.Get Substring    ${SOFTWARE_INFO}    0    4
    Set Suite Variable    ${ENB_BUILD}
    Set Suite Variable    ${IS_SOFTWARE_KNIFE}
    Get Software Version Total

Get Software Version Total
    [Documentation]    Author: Wang Yixiang   Migrate from ET
    ...    This keyword is to get gNB software version including below 3 suite variables.
    ...
    ...    | Suite variable | Example | Description |
    ...    | ${SW_VERSION} | SBTS00 | get the QT config files with the related version |
    ...    | ${SW_VERSION_TOTAL} | SBTS21B_ENB_9999_210324_000019 | total sw version |
    ...    | ${SW_BRANCH} | SBTS21B | the folder to stort config files for case |
    ...
    @{sw_list}    String.Split String    ${SOFTWARE_INFO}    _
    ${status}    Run Keyword And Return Status    Should Be True    ${sw_list[2]}==9999 or ${sw_list[2]}==9990
    Run Keyword If    '${status}'=='True'    Set Suite Variable    ${SW_VERSION}    SBTS00
    ...    ELSE    Set Suite Variable    ${SW_VERSION}    ${sw_list[0]}
    Run Keyword If    '${status}'=='True'    Set Suite Variable    ${SW_VERSION_TOTAL}
    ...    SBTS00_${sw_list[1]}_${sw_list[2]}_${sw_list[3]}_${sw_list[4]}
    ...    ELSE    Set Suite Variable    ${SW_VERSION_TOTAL}    ${SOFTWARE_INFO}
    Set Suite Variable    ${SW_BRANCH}    ${sw_list[0]}
    Log    Software Version Total: ${SW_VERSION_TOTAL}    console=${True}

