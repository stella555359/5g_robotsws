*** Settings ***
Documentation    :copyright       : Nokia
                 ...              :author       : Vadivelan Manickavasagam
                 ...              :contact      : vadivlean.manickavasagam@nokia.com
                 ...              :Description  : This file contains ap and gnb TTI
                 ...                              log operation related keywords
                 ...              :history change, <date>,<who>,<what and how>
                 ...              :Drafted,11.01.2025,vadivelan.manickavasagam@nokia.com

Library    BuiltIn
Library    Process
Library    OperatingSystem
Library    String
Library    Collections
Library    DateTime
Library    taf.sbts.oam.coam.admin    WITH NAME    admin
Library    taf.collectors.tcpdump    WITH NAME    tcpdump
Library    taf.collectors.l2stream3    WITH NAME    l2stream3
Library    taf.collectors.core    WITH NAME    core
Library    taf.converters.eventdecoder  WITH NAME    eventdecoder
Library    ../Python/tti_stream_mode_convert.py    WITH NAME    TtiSMConvert
Library    ../Python/tti_validation.py     WITH NAME     TtiValidation
Library     ta_a2a.interface
#Library    taf.wts.runner    WITH NAME    wtsrunner
#Resource     ./5G_SW_Keywords.robot


*** Variables ***
${sosReportScript}     sosReport.sh
${sosReportLogDir}     /tmp/sosreport
${VMsosReportLogDir}   /tmp/sosReport
${sosReportCfg}        sosReport.cfg
${sosReportMainDir}    /ffs/run/config/toor4nsn/logs
${sosReportStbDir}     /ffs/stb/config/to
${collector_alias}     l2stream3
&{TTITRACE_CONFIG_L2PS}            up_sw=L2Ps    trace_type=Component
#&{TTITRACE_CONFIG_L2LO}            up_sw=L2Lo    trace_type=Component
#&{TTITRACE_CONFIG_L2HIPDCP}        up_sw=L2HiPdcp    trace_type=Component
#&{TTITRACE_CONFIG_L2HIRLC}         up_sw=L2HiRlc    trace_type=Component
#@{L2STREAM_COMPONENT_CONFIG}       &{TTITRACE_CONFIG_L2HIPDCP}    &{TTITRACE_CONFIG_L2HIRLC}
#...         &{TTITRACE_CONFIG_L2PS}    &{TTITRACE_CONFIG_L2LO}
@{L2STREAM_COMPONENT_CONFIG}       &{TTITRACE_CONFIG_L2PS}

*** Keywords ***

Kill Deleted Process
    Run And Return Rc And Output    sudo pkill tcpdump
    Run And Return Rc And Output    sudo ps -aef | grep -i tcpdump
    Run And Return Rc And Output    lsof +L1

AP Activate TTI Trace Streaming
#    wtsrunner.sim_tti_trace    on_mask=0xff    enb=2    cell=1
    Execute Egate Command   cmd=sim_tti_trace    on_mask=0xff    enb=2    cell=1

AP Trigger TTI traces
#    RUN    mkdir -p ${EXECDIR}/logs/TTI_TRACES/
    RUN    mkdir -p /tmp/AP_TTI_TRACES/
    RUN    sudo tcpdump -i any -s0 -C 100 udp port 5678 -w /tmp/AP_TTI_TRACES/AP_ttiTraces.pcap > /dev/null 2>&1 &

AP Deactivate TTI Streaming
#    wtsrunner.sim_tti_trace    on_mask=0    enb=2    cell=1
    Execute Egate Command   cmd=sim_tti_trace    on_mask=0    enb=2    cell=1

AP Stop and Copy TTI Traces
    RUN    sudo pkill tcpdump
    Kill Deleted Process
    AP Deactivate TTI Streaming
    RUN    cd /tmp/ && tar -czvf AP_TTI_TRACES.tar.gz AP_TTI_TRACES/
    RUN    mv /tmp/AP_TTI_TRACES.tar.gz /home/ute/logs/

Common Format Tti In Stream Mode
    [Arguments]    ${input_csv_name}    ${output_csv_name}    ${filters}=${EMPTY}
    ...            ${exe_dir}=/home/ute/logs/
    [Documentation]    This keyword is to convert tti collected by stream mode.
    ...    Parameters same as keyword: Format Tti In Snapshot Mode
#    ${filters}    set variable     "dlHarqRxDataArray"
    Run Keyword If    '${filters}'=='${EMPTY}'    TtiSMConvert.format_tti_stream_mode_no_filters
    ...    ${input_csv_name}    ${output_csv_name}
    ...    ELSE    TtiSMConvert.format_tti_stream_mode_with_filters    ${input_csv_name}
    ...    ${output_csv_name}    ${filters}
    RUN    mv *.csv ${exe_dir}/GNB_TTI/

Start AP and GNB sys logs
    RUN    cli_syslog.py -d "/home/ute/" -l "default_syslog_iphyNone.log" -i "192.168.200.126" -s 0 -p 51011 > /dev/null 2>&1 &
    RUN    cli_syslog.py -d "/home/ute/" -l "default_syslog_enbNone.log" -i "192.168.255.126" -s 0 -p 51000 51001 51003 50011 > /dev/null 2>&1 &

Stop AP and GNB sys logs
    [Arguments]     ${output_folder}=/home/ute/logs/
    RUN     sudo pkill cli_syslog
    RUN     mv /home/ute/default_syslog_iphyNone.log ${output_folder}
    RUN     mv /home/ute/default_syslog_enbNone.log ${output_folder}
    RUN     cd ${output_folder} && tar -czvf ap_sys_log.tgz default_syslog_iphyNone.log
    RUN     cd ${output_folder} && tar -czvf gnb_sys_log.tgz default_syslog_enbNone.log

tti count element in coloumn
    [Arguments]     ${file_path}     ${column_name}     ${target_string}
     ${col_count}     set variable     0
     ${col_count}=     TtiValidation.count_string_in_column       ${file_path}
     ...     ${column_name}      ${target_string}
     [Return]     ${col_count}


Convert TTI trace from pcap to excelCsv
    [Arguments]    ${pcap_path}=/home/ute/logs/l2stream3/tcpdump/tcpdump.pcap      ${output_path_with_tag}=/home/ute/logs/l2stream3/tcpdump/
    ...            ${decode_format}=excelCsv
    [Documentation]    This keyword will decode pcap file to csv.
    ...    | Input Parameters          | Man. | Description |
    ...    | ${pcap_path}              | Yes  | pcap file path. |
    ...    | ${output_path_with_tag}   | Yes  | Decode output file save path. |
    ...    | ${output_file_format}     |  No  | output file format can be "json", "legacyCsv" or "excelCsv", default is "excelCsv" |
    ...   Example:
    ...    | Start GNB Ttitrace With Streaming Mode | | |
    ...    | some action | | |
    ...    | ${pacp}=  |  Stop GNB Ttitrace With Streaming Mode  |  save_path=${TEST_LOG_DIRECTORY()} |
    ...    | Download Ttitrace Decode Tool  | | |
    ...    | Decoder Tttirace From Pcap To Csv  | pcap_path=${pacp} | output_path_with_tag=${TEST_LOG_DIRECTORY()}nsa_tti |
    EVENTDECODER.Create Eventdecoder Converter    name=converter    input_file_path=${pcap_path}    output_file_format=${decode_format}
    ...    output_file_path=${output_path_with_tag}    excel_csv_options=-w
    EVENTDECODER.Convert    name=converter
#    GNB_TTI.Is Csv File Generated     ${output_path_with_tag}
#    ${path}    ${tag}    Split Path    ${output_path_with_tag}
    #GNB_TTI.Decode Ttitrace File    ${pcap_path}    ${output_path_with_tag}    ${output_file_format}    ${excel_csv_options}    ${conversion_filter}
#    [Return]    ${path}


start gNB tti stream
    [Arguments]     ${name}=l2stream3
    &{asik_vm}=         Create Dictionary
    ...    host=192.168.255.129
    ...    user=Nemuadmin
    ...    password=nemuuser
    ...    port=443
    ...    release=SBTS25R2
    ${l2_stream_config_1}=    Create Dictionary       nr_phy_cell_ids=50     up_sw=L2Ps
    @{l2_stream_configuration}=    Create List    ${l2_stream_config_1}
    TCPDUMP.Create Tcpdump Collector
    ...  name=tcpdump
    ...  options=-i eth3 udp and dst 10.0.1.1 and dst port 5678
    ...  sudo_password=ute
    L2STREAM3.Create Sbts L2stream Collector
    ...  name=${name}
    ...  destination_ip_addr=10.0.1.1
    ...  collector=tcpdump
    ...  l2_stream_configuration=${l2_stream_configuration}
    ...  webservice=${asik_vm}
    ...  dscp=15
    L2STREAM3.Set Suite Alias    alias=${name}
    CORE.setup_collectors    names=${name}
    CORE.start_collectors    names=${name}

stop gNB tti stream
    [Arguments]    ${save_path}=/home/ute/logs/    ${name}=l2stream3
    [Documentation]    This keyword will stop collect gnb ttitrace log.
    CORE.stop_collectors    names=${name}
    CORE.collect_collectors    names=${name}     target_dir=${save_path}
    CORE.teardown_collectors    names=${name}

Validate GNB TTI
     [Arguments]    ${tti_pcap_path}=/home/ute/logs/l2stream3/tcpdump/tcpdump.pcap
     ...     ${validation_ini_path}=none
     Convert TTI trace from pcap to excelCsv      pcap_path=${tti_pcap_path}
     ...      output_path_with_tag=/home/ute/logs/l2stream3/tcpdump/     decode_format=excelCsv
     ta_a2a.interface.Check Logs With Au2anlysis      ini_path=${validation_ini_path}    log_need_to_check=i
     ...    save_log_directory=/home/ute/logs/l2stream3/
