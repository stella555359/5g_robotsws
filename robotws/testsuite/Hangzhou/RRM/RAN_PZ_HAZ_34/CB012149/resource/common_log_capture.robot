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
Library     ../lib/tti_stream_mode_convert.py    WITH NAME    TtiSMConvert




*** Variables ***
&{TTITRACE_CONFIG_L2PS}            up_sw=L2Ps    trace_type=Component
&{TTITRACE_CONFIG_L2LO}            up_sw=L2Lo    trace_type=Component
&{TTITRACE_CONFIG_L2HIPDCP}        up_sw=L2HiPdcp    trace_type=Component
&{TTITRACE_CONFIG_L2HIRLC}         up_sw=L2HiRlc    trace_type=Component
@{L2STREAM_COMPONENT_CONFIG}       &{TTITRACE_CONFIG_L2HIPDCP}    &{TTITRACE_CONFIG_L2HIRLC}    &{TTITRACE_CONFIG_L2PS}    &{TTITRACE_CONFIG_L2LO}
@{L2STREAM_L2_PS_CONFIG}           &{TTITRACE_CONFIG_L2PS}
${SSH_CMD}                         sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.129

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
    [Arguments]    ${collector_names}=l2stream3_ttitrace    ${l2_stream_configuration}=${L2STREAM_L2_PS_CONFIG}
    ...    ${gnb_index}=0   ${SW_BRANCH}=None
    ...    ${eth_port_on_ute}=eth0
    ...    ${eth_ip_addr_on_ute}=${tl.test_pc.default_ssh_connection_details.addr}
    ...    ${localIpAddr}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    log to console    setup admin for ttitrace...

    Run Keyword If    '${SW_BRANCH}'=='None'    common_log_capture.Get Software Version
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
    [Arguments]    ${collector_names}=l2stream3_ttitrace    ${log_dir}=${OUTPUT_DIR}/ttitrace_streaming/
    log to console    stop catching ttitrace...
    CORE.stop_collectors
    ...  names=${collector_names}
    CORE.collect_collectors
    ...  names=${collector_names}    target_dir=${log_dir}
    CORE.teardown_collectors
    ...  names=${collector_names}

Decode Ttitrace Log
    [Documentation]    Author: Wang Yixiang   Migrate from ET
    [Arguments]    ${collector_names}=l2stream3_ttitrace    ${log_dir}=${TEST_LOG_DIRECTORY}/ttitrace_streaming    ${format_tti_log}=${False}
    log to console    Start to decode ttitrace...
    # ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
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
    [Arguments]    ${collector_names}=l2stream3_ttitrace    ${log_id}=1    ${duration}=3
    Start Ttitrace With Streaming Mode    collector_names=${collector_names}
    Sleep    ${duration}s    reason=Wait for logs
    Stop Ttitrace    collector_names=${collector_names}    log_dir=${TEST_LOG_DIRECTORY}/tcpdump_ttitrace/${log_id}
    ${csv_file_path}    Decode Ttitrace Log    collector_names=${collector_names}    log_dir=${TEST_LOG_DIRECTORY}/tcpdump_ttitrace/${log_id}
    [Return]    ${csv_file_path}

Convert Ttitrace From Pcap To Excelcsv
    [Documentation]    Author: Wang Yixiang   Migrate from ET
    [Arguments]    ${log_path}=${TEST_LOG_DIRECTORY}/ttitrace_streaming    ${collector_names}=l2stream3_ttitrace
    ${file_path}=    Set Variable    ${log_path}/${collector_names}/tcpdump_ttitrace/tcpdump_ttitrace.pcap
    OperatingSystem.Run    mkdir -p ${log_path}; cp -r "${file_path}" ${log_path}

    EVENTDECODER.Create Eventdecoder Converter
    ...    name=converter
    ...    input_file_path=${file_path}
    ...    output_file_format=excelCsv
    ...    excel_csv_options=-w
    EVENTDECODER.Convert
    ...    name=converter
    OperatingSystem.Run    mkdir -p ${log_path}
    OperatingSystem.Run    cp ${EXECDIR}/output_dl*.csv ${log_path};cp ${EXECDIR}/output_ul*.csv ${log_path}
    List Files In Directory    ${log_path}

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
    #${ENB_BUILD}=    Set Variable    ${words[0][0:4]}
    ${IS_SOFTWARE_KNIFE}=    Set Variable If    "${words[-1][0:3]}"=="000"    ${False}    ${True}
    #${ENB_BUILD}=    String.Get Substring    ${SOFTWARE_INFO}    0    4
    #Set Suite Variable    ${ENB_BUILD}
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
    Run Keyword If    '${status}'=='True'    Set Suite Variable    ${SW_BRANCH}    ${SW_VERSION}
    ...    ELSE    Set Suite Variable    ${SW_BRANCH}    ${sw_list[0]}
    Log    Software Version Total: ${SW_VERSION_TOTAL}    console=${True}

Start GNB BIP By Admin Method
    [Arguments]    ${mirroring_time}=600    ${interface}=L1-L2    ${destination}=Local
    [Documentation]    this keyword is used for catch gnb bip log on webem:Diagnosis -> Mirroring -> Interface Mirroring
    ...    now it doesn't support ASOE. Note: L2-PS,L2lo <-> L1,L2hi <-> L2lo,L2hi doesn't have message with L2-PS and L1,
    ...    | Input Parameters | Man. | Description |
    ...    | ${interface} | No | bip type: L1-L2/L2Hi-L2Lo,for l1bypss testine, choose L2Hi-L2Lo |
    ...    | ${destination} | No | Local/Remote |
    ...    | ${mirroring_time} | No | 0~2147483647 |
    #Run Keyword And Ignore Error    Stop Gnb BIP By Admin Method
    Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.129 rm -rf /tmp/CCSPacketCapture/*
    COAM.Setup Admin    timeout=120
    COAM.Interface mirroring    interface=${interface}    destination=${destination}    mirroring_time=${mirroring_time}    operation=Start
    [Teardown]    COAM.Teardown

Stop Gnb BIP By Admin Method
    [Arguments]    ${log_path}=${OUTPUT_DIR}    ${interface}=L1-L2    ${destination}=Local    ${mirroring_time}=600
    COAM.Setup Admin    timeout=120
    COAM.Interface mirroring    interface=${interface}    destination=${destination}    mirroring_time=${mirroring_time}    operation=Stop
    Collect GNB BIP By Admin Method    ${log_path}
    [Teardown]    COAM.Teardown

Collect GNB BIP By Admin Method
    [Arguments]    ${log_path}=${OUTPUT_DIR}
    Run    mkdir -p ${log_path}
    Run Keyword And Ignore Error    Run    rm -rf ${log_path}/mirroring_L2L1*
    Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.129 ls -al /tmp/CCSPacketCapture
    Run    sshpass -p oZPS0POrRieRtu scp toor4nsn@192.168.255.129:/tmp/CCSPacketCapture/* ${log_path}
    Run    ls -l ${log_path}
    Run    mergecap -a -w ${log_path}/5GBipL2L1_filtering_off.pcap ${log_path}/mirroring_L2L1*
    ${bip_file}=    Set Variable    ${log_path}/5GBipL2L1_filtering_off.pcap
    OperatingSystem.File Should Exist    ${bip_file}
    Log To Console    bip log:${bip_file}
    [Return]    ${bip_file}

Check Ttitrace DTXNACK Rate
    [Arguments]    ${log_id}=dtxnack    ${expect_rate}=0.1
    Check Rate    dlFdSchedData.ackNack    ["ACK", "NACK","DTX"]    ["NACK","DTX"]    ${log_id}    ${expect_rate}
    Check Rate    dlFdSchedData.speculativeDtxAckDtx    ["ACK", "NACK","DTX"]    ["NACK","DTX"]    ${log_id}    ${expect_rate}
    Check Rate    dlHarqRxDataArray.dtx    ["NON_DTX","DTX"]    ["DTX"]    ${log_id}    ${expect_rate}


Check Ttitrace UL DTXCRC Rate
    [Arguments]    ${log_id}    ${expect_rate}=0.1
    Check Rate    ulHarqRxData.crcResult    ["OK","NOK"]    ["NOK"]    ${log_id}    ${expect_rate}
    Check Rate    ulHarqRxData.dtx    ["NON_DTX","DTX"]    ["DTX"]    ${log_id}    ${expect_rate}

Check Rate
    [Arguments]    ${name}=dlFdSchedData.ackNack    ${total}=["ACK", "NACK","DTX"]    ${failed}=["NACK","DTX"]    ${log_id}=dtxnack
    ...    ${expect_rate}=0.1
    [Documentation]    This keyword is to check rate.
    ...    | Input Parameters | Man. | Description |
    ...    | name | Yes |the column title to check, default is dlFdSchedData.ackNack |
    ...    | total | Yes | all the status , default is ["ACK", "NACK","DTX"]|
    ...    | failed  | Yes | failed status, default is ["NACK","DTX"] |
    ...    Example:
    ...    | Check Rate | dlFdSchedData.ackNack | ["ACK", "NACK","DTX"] | ["NACK","DTX"] |
    ${total_number}    Get Total Number from Ttitrace    ${name}    ${total}    ${log_id}
    ${failed_number}    Get Total Failed Number from Ttitrace    ${name}    ${failed}    ${log_id}
    ${rate}    Evaluate    float(${failed_number})/(${total_number})
    Log To Console    \n${name} rate is ${rate}\n
    Should Be True    ${rate}<${expect_rate}

Get Total Number from Ttitrace
    [Arguments]    ${name}=dlFdSchedData.ackNack    ${total}=["ACK", "NACK","DTX"]    ${log_id}=dtxnack
    ${sub_name}=    Get Substring    ${name}    0    2
    ${csv_file_name}=    Set Variable If    "${sub_name}"=="dl"    output_dl.csv    output_ul.csv
    ${data_list}=    TTITRACEANALYZER.Filter Source Column Return Self
    ...    ${TEST_LOG_DIRECTORY}/tcpdump_ttitrace/${log_id}/${csv_file_name}    ${name}    ${total}    include    no
    ${count}    Get Length    ${data_list}
    [Return]    ${count}

Get Total Failed Number from Ttitrace
    [Arguments]    ${name}=dlFdSchedData.ackNack    ${failed}=["NACK","DTX"]    ${log_id}=dtxnack
    ${sub_name}=    Get Substring    ${name}    0    2
    ${csv_file_name}=    Set Variable If    "${sub_name}"=="dl"    output_dl.csv    output_ul.csv
    ${data_list}=    TTITRACEANALYZER.Filter Source Column Return Self
    ...    ${TEST_LOG_DIRECTORY}/tcpdump_ttitrace/${log_id}/${csv_file_name}    ${name}     ${failed}    include    no
    ${count}    Get Length    ${data_list}
    [Return]    ${count}
