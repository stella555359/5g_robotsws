*** Settings ***
Documentation
...   author: Krystian Wojakiewicz
...   contact: krystian.wojakiewicz@nokia.com
...   PZ_2_WRO_6 implementation for TTI collection in streaming mode
...
...   Preconditions:
...   * EventDecoder in /opt/tti-dec/tti-dec-bin. UTE VMs should be prepared by default.
...   * Mplane and VM IPs must be available from TL __init__.py
...   * tcpdump
...
...   Example usage:
...         Start TTI Traces in Streaming mode    filename=tti_streaming
...         Sleep   10s
...         ${tti_file_path}=    Stop TTI Traces in Streaming mode     tti_trace_dir=TTI    with_decode=true    output_file_format=legacyCsv

Library     OperatingSystem
Library     String
Library     Collections
Library     taf.config.scf   WITH NAME  scf
Library     taf.collectors.l2stream3    WITH NAME    l2stream3
Library     taf.collectors.core    WITH NAME    core
Library     taf.converters.eventdecoder    WITH NAME   EVENTDECODER
Resource    testsuite/Wroclaw/RRM/resources/tti_verification/tti_streaming/tcpdump_collector.robot
Resource    testsuite/Wroclaw/RRM/resources/preconditions.robot


*** Variables ***
@{default_cell_dist_id}  /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-1/NRCELL_R-1
${nr_phy_cell_ids}   50,51,52   # not necessary in case if we want to collect from all cells

*** Keywords ***
Start TTI Traces in Streaming mode
    [Arguments]   ${filename}=tti_streaming   ${collector_type}=coam
    Set global variable   ${tti_pcap_filename}    ${filename}
    ${src_ip}=          Set variable    ${tl.gnbs[0].cu.m.v4}                              # mplane
    ${dest_ip}=         Set variable    ${tl.test_pc.default_ssh_connection_details.addr}  # UTE VM
    Log to console  TTI Traces are forwarded to IP: ${dest_ip}
    ${collector_tti_trace_pcap}=   Start tcpdump on TTI interface    ${dest_ip}    filename=${filename}
    Run Keyword If   '${collector_type}' == 'coam'
    ...        Start Generation of TTI Trace Using TAF    dest_ip=${dest_ip}    collector=${collector_tti_trace_pcap}
    Run Keyword If   '${collector_type}' == 'sbts'
    ...        Start Generation of TTI Trace Using TAF SBTS    dest_ip=${dest_ip}    collector=${collector_tti_trace_pcap}


Start tcpdump on TTI interface
    [Arguments]  ${dest_ip}   ${filename}=tti_streaming
    ${connection}=  Connect to test PC
    ${interface_name}=  Identify Interface with IP    ip=${dest_ip}    connection=${connection}
    BuiltIn.Log  Identifed interface for TCP Dump on Test PC is : ${interface_name}    console=True
    ${collector}=    Start Tcpdump on TestPc    interface=${interface_name}    option=port 5678    collector=${filename}
    [Return]    ${collector}
    [Teardown]  ssh.disconnect  connection=${connection}


Start Generation of TTI Trace Using TAF
    [Arguments]   ${dest_ip}   ${collector}
    ${_collector_name}=  Set variable  l2stream3
    ${executor}=  Create Dictionary
    ...  host=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
    ...  user=${tl.gnbs[0].cu.oam_http_connection_details.username}
    ...  password=${tl.gnbs[0].cu.oam_http_connection_details.password}
    ...  port=443
    ${l2_stream_config_1}=  Create Dictionary
    ...  nr_cell_dns=${default_cell_dist_id}
    @{l2_stream_configuration}    Create List    ${l2_stream_config_1}
    l2stream3.create_sbts_l2stream_collector
    ...  name=${_collector_name}
    ...  webservice=${executor}
    ...  source_ip_addr=${tl.gnbs[0].cu.m.v4}
    ...  destination_ip_addr=${dest_ip}
    ...  collector=${collector}
    ...  l2_stream_configuration=${l2_stream_configuration}
    core.setup_collectors    names=${_collector_name}
    core.start_collectors    names=${_collector_name}
    core.Set Suite Alias     ${_collector_name}
    Log to console  TTI streaming started


Start Generation of TTI Trace Using TAF SBTS
    [Arguments]   ${dest_ip}   ${collector}
    ${release}=   Assign release version
    ${_collector_name}=  Set variable  l2stream3
    ${executor}=  Create Dictionary
    ...  host=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
    ...  user=${tl.gnbs[0].cu.oam_http_connection_details.username}
    ...  password=${tl.gnbs[0].cu.oam_http_connection_details.password}
    ...  port=443
    ...  release=${release}
    ${l2_stream_config_1}=  Create Dictionary
#    ...   nr_phy_cell_ids=${nr_phy_cell_ids}
    ...  trace_type=Component
    @{l2_stream_configuration}    Create List    ${l2_stream_config_1}
    l2stream3.create_sbts_l2stream_collector
    ...  name=${_collector_name}
    ...  webservice=${executor}
    ...  source_ip_addr=${tl.gnbs[0].cu.m.v4}
    ...  destination_ip_addr=${dest_ip}
    ...  collector=${collector}
    ...  l2_stream_configuration=${l2_stream_configuration}
    core.setup_collectors    names=${_collector_name}
    core.start_collectors    names=${_collector_name}
    core.Set Suite Alias     ${_collector_name}
    Log to console  TTI streaming started


Teardown TTI Traces in Streaming mode
    [Arguments]  ${tti_trace_dir}=TTI    ${output_file}=TTI/${test_name}_TTI    ${with_decode}=true    ${output_file_format}=legacyCsv
    Run Keyword and Ignore Error
    ...   Stop TTI Traces in Streaming mode    tti_trace_dir=${tti_trace_dir}    output_file=${output_file}
    ...                                        with_decode=${with_decode}        output_file_format=${output_file_format}


Stop TTI Traces in Streaming mode
    [Arguments]  ${tti_trace_dir}=TTI    ${output_file}=TTI/${test_name}_TTI    ${with_decode}=true    ${output_file_format}=legacyCsv
    Stop Generation of TTI Trace Using TAF    tti_output_dir=${LOG_PATH}/${tti_trace_dir}
    ${tti_pcap_path}=    Set variable   ${LOG_PATH}/${tti_trace_dir}/l2stream3/${tti_pcap_filename}/${tti_pcap_filename}.pcap
    Run Keyword if   '${with_decode}' == 'true'
    ...     Convert TTI to CSV
    ...     input_file_path=${tti_pcap_path}
    ...     output_file=${output_file}
    ...     output_file_format=${output_file_format}
    BuiltIn.Log     TTI streaming stopped!     console=True
    [Return]   ${LOG_PATH}/${output_file}.dlAndUl.csv


Stop Generation of TTI Trace Using TAF
    [Arguments]  ${tti_output_dir}=TTI
    core.stop_collectors        names=l2stream3
    core.collect_collectors     names=l2stream3    target_dir=${tti_output_dir}
    core.teardown_collectors    names=l2stream3


Convert TTI to CSV
    [Arguments]  ${input_file_path}=${EMPTY}    ${output_file}=decoded_tti    ${output_file_format}=legacyCsv
    EVENTDECODER.Create Eventdecoder Converter
    ...  name=converter
    ...  input_file_path=${input_file_path}
    ...  output_file_format=${output_file_format}
    ...  output_file_path=${LOG_PATH}/${output_file}
    EVENTDECODER.Convert
    ...  name=converter
    [Return]     ${LOG_PATH}/${output_file}


Identify Interface with IP
    [Arguments]    ${ip}    ${connection}
    ${cl_output}=    ssh.execute  ip -o -4 addr show | awk '{print $2" "$4}' | grep ${ip}     connection=${connection}
    @{words}=    Split String    ${cl_output}
    ${if_name}=    Run keyword and ignore error    Set variable    ${words[0]}
    ${interface_name}=    Set variable if    '${if_name[0]}'=='PASS'    ${if_name[1]}
    [Return]    ${interface_name}


Assign release version
    ${smod_con}   Connect to SMOD
    ${version_file}    ssh.execute   command=ls /ffs/run/TargetBD*.xml
    ...           connection=${smod_con}
    ${branch}     Set Variable   ${version_file.split()[-1].split('TargetBD_')[-1].split('_')[0]}
    ${to_set}     Set Variable If   '${branch}'=='SBTS22R4'   SBTS22R3   ${branch}
    [Return]      ${to_set}
