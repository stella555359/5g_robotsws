*** Settings ***
Documentation  Script for TTI
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

start gNB tti stream
#    admin.Setup admin
    ${webservice}=  Create Dictionary
    ...  host=192.168.255.1
    ...  user=Nemuadmin
    ...  password=nemuuser
    ...  port=443
    ...  release=SBTS25R1
    ${l2_stream_config_1}=  Create Dictionary
    ...  nr_phy_cell_ids=50
    ...  up_sw=L2Ps
#    ...  profile_filter_list=PUCCH,CSI,PDSCH
#    @{l2_stream_configuration}    Create List    ${l2_stream_config_1}
#    tcpdump.create tcpdump collector
     tcpdump.create_tcpdump_collector
     ...  name=tcpdump
#    ...  options=-i eth3 udp and dst 10.0.1.1 and dst port 5678
     ...  options=-i eth3 port 5678
     ...  sudo_password=ute
     l2stream3.create sbts l2stream collector
     ...  name=${collector_alias}
     ...  webservice=${webservice}
     ...  dscp=10
     ...  destination_ip_addr=10.0.1.1
     ...  collector=tcpdump
     ...  l2_stream_configuration=${L2STREAM_COMPONENT_CONFIG}
     core.setup_collectors    names=${collector_alias}
     core.start_collectors    names=${collector_alias}
     core.set_suite_alias       ${collector_alias}

stop gNB tti stream
    RUN    mkdir -p /tmp/GNB_TTI_TRACES/
    core.stop_collectors    names=${collector_alias}
    core.collect_collectors    names=${collector_alias}
    ...      target_dir=/tmp/GNB_TTI_TRACES/
    core.teardown_collectors    names=${collector_alias}
#    admin.Teardown admin
    RUN    cd /tmp/GNB_TTI_TRACES/l2stream3/tcpdump/ && tar -czvf GNB_TTI_TRACES_pcap.tar.gz tcpdump.pcap
#    RUN    mv /tmp/GNB_TTI_TRACES/l2stream3/tcpdump/GNB_TTI_TRACES_pcap.tar.gz  /home/ute/logs/

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

Convert TTI trace from pcap to excelCsv
    [Arguments]    ${input}=/tmp/GNB_TTI_TRACES/l2stream3/tcpdump/tcpdump.pcap
    ...            ${output}=/tmp/GNB_TTI_TRACES/l2stream3/tcpdump/
    ...            ${exe_dir}=/home/ute/logs/
    [Documentation]    This keyword converts tti trace pcap to csv
    ...     -   :param input:           Path to tcpdump.pcap
    ...     -   :param output:          Target directory for generated csv

    eventdecoder.Create eventDecoder converter
    ...  name=ttitrace_converter
    ...  input_file_path=${input}
    ...  output_file_format=excelCsv
    ...  output_file_path=${output}
    eventdecoder.Convert
    ...  name=ttitrace_converter
    RUN    mkdir ${exe_dir}/GNB_TTI/
    RUN    mv /tmp/GNB_TTI_TRACES/l2stream3/tcpdump/GNB_TTI_TRACES_pcap.tar.gz ${exe_dir}/GNB_TTI/
    RUN    mv /tmp/GNB_TTI_TRACES/l2stream3/*.csv ${exe_dir}/GNB_TTI/
    RUN    mv ${exe_dir}/*.csv ${exe_dir}/GNB_TTI/
    RUN    rm -rf /tmp/AP_TTI_TRACES/ && rm -rf /tmp/GNB_TTI_TRACES/

Common Format Tti In Stream Mode
    [Arguments]    ${input_csv_name}    ${output_csv_name}    ${filters}=${EMPTY}
    ...            ${exe_dir}=/home/ute/logs/
    [Documentation]    This keyword is to convert tti collected by stream mode.
    ...    Parameters same as keyword: Format Tti In Snapshot Mode
    ${filters}    set variable     "dlHarqRxDataArray"
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

