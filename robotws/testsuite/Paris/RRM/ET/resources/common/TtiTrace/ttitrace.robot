*** Settings ***
Documentation     Keywords related to collection of TTI Traces
...  author: Srihari Janardhan, 5G SW&SC Ulm Sqd66 / Modfied by Ch SAMSON
...  contact: srihari.janardhan@nokia.com
...  Description: Resources to collect TTI Traces in Streaming mode
...  following variables need to be assigned:
...  ${gnb_id}  gnb number from which the TTI trace should be captured, id = 0 if only 1 gnb is configured
...             refer to the __init__.py configuration of the testline
...  ${du_id}   DU id if several DUs are connected to the gNB. If only 1 DU is configured du_id = 0.
...             refer to the __init__.py configuration of the testline
...  ${common_unit_id}   ASIK id if several ASIKs are connected to the DU. If only 1 ASIK is configured
...             By default all above values are configured as 0
...             refer to the __init__.py configuration of the testline

Library       BuiltIn
Library    taf.collectors.tcpdump             WITH NAME    tcpdump
Library    taf.collectors.l2stream3           WITH NAME    l2stream3
Library    taf.collectors.core                WITH NAME    core

Library    taf.gnb.oam.coam.admin             WITH NAME    admin
Library    taf.gnb.oam.coam.cu                WITH NAME    coam_cu
Library    taf.transport.ssh                  WITH NAME    ssh
Library    taf.converters.eventdecoder        WITH NAME    tce

Library    ./python/ttitrace.py               WITH NAME    ttitrace_tools
Library    ./python/TTI_Converter.py          WITH NAME    TtiConvert

Resource   ../../../../../resources/SWENG/robot/Connect.robot
Resource   ../../../../../resources/SWENG/robot/Oam.robot
# Library    ./python/tti_analyzer_framework/tti_extractor_framework.py  WITH NAME  tti_trace_analyzer

*** Variables ***
#Tagged for further improvement -> to capture the values from SCF
${fronthaul_ip_oam}  192.168.2.112
${P_console}        ${True}           # output to console can be enabled via "Set Console Output" from testline.robot
#@{default_cell_dist_id}  /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-1/NRCELL_R-1
#@{default_cell_dist_id}  /MRBTS-${MRBTS_ID}/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-1/NRCELL_R-1

*** Keywords ***

Connect to TestPC
    [Documentation]   :Author: Soenke Kullberg
    ...     Setup ssh connection to Test PC and returns connection handle/alias
    ...
    ...     **Note:** KW sould be called without arguments
    ...
    ...     :param alias: (optional) alias used for ssh connection
    ...
    ...     :return alias: for ssh connection to Testpc
    ...
    ...     **Example:**
    ...
    ...     | ${tpc_alias}=  ttitrace.Connect to TestPC
    ...     | ssh.execute  command=ls  connection=${tpc_alias}
    ...
    [Arguments]    ${alias}=ssh-test-pc
    ssh.Connect_to      hostname=${tl.test_pc.default_ssh_connection_details.addr}
    ...                 username=${tl.test_pc.default_ssh_connection_details.username}
    ...                 password=${tl.test_pc.default_ssh_connection_details.password}
    ...                 alias=${alias}
    [Return]    ${alias}

Start Tcpdump on TestPc
    [Documentation]    :Author: Soenke Kullberg
    ...     Start Tcpdump on test PC
    ...
    ...     :param option: (default="") Addtional options for tcpdump
    ...     :param interface: (default=fronthaul) Interface tcpdump
    ...     :param collector: (default gnb-${gnb_id}-oam-${interface}-tcpdump)  Name of collector **Impact on log filename**
    ...
    ...     **Example:**
    ...
    ...         | Start Tcpdump on TestPc     interface=eth0
    ...         | BuiltIn.Sleep     10 sec
    ...         | Stop Tcpdump on TestPc     interface=eth0
    [Arguments]     ${interface}  ${option}=${EMPTY}      ${collector}=testpc-${interface}-tcpdump
    ${testpc_ssh_config}=  Create Dictionary
    ...     host=${tl.test_pc.default_ssh_connection_details.addr}
    ...     user=${tl.test_pc.default_ssh_connection_details.username}
    ...     password=${tl.test_pc.default_ssh_connection_details.password}
    tcpdump.create_tcpdump_collector
    ...     name=${collector}
    ...     options=-i ${interface} ${option}
    ...     executor=${testpc_ssh_config}
    tcpdump.setup_collectors    names=${collector}
    tcpdump.start_collectors    names=${collector}
    tcpdump.set_suite_alias     ${collector}
    [RETURN]    ${collector}

Identify Interface with IP
    [Documentation]  :Author: Srihari Janardhan | The keyword returns the interface name associated with an IP.
    ...    If no interface is found with the corrosponding IP, None is returned
    ...
    ...    :param ip: the ip address for which the corrosponding interface name needs to be found
    ...    :param connection: the alias to an ssh connection to the machine on which the interface name has to be determined
    ...    :return: interface name
    ...
    [Arguments]    ${ip}    ${connection}
    ${cl_output}=    ssh.execute  ip -o -4 addr show | awk '{print $2" "$4}' | grep ${ip}     connection=${connection}
    @{words}=    Split String    ${cl_output}
    ${if_name}=    Run keyword and ignore error    Set variable    ${words[0]}
    ${interface_name}=    Set variable if    '${if_name[0]}'=='PASS'    ${if_name[1]}
    [Return]    ${interface_name}

Connect to gNB Common Unit
    [Documentation]    :
    ...     setup ssh connection to Airscale (ASXX) and returns connection handle/alias
    ...
    ...     :param gnb_id:         Id of gnb                       [0.. ]  default=0
    ...     :param du_id:          Id of DU                        [0.. ]  default=0
    ...     :param comu_id:        Id of Common Unit               [0..1]  default=0
    ...     :param alias:       (optional) connection alias  !! should not be used
    ...
    ...     :returns alias:     alias for ssh connection to Common Unit
    ...
    ...     **Example:**
    ...
    ...     | ${asxx_alias}=   connect.Connect to gNB Common Unit    gnb_id=0  du_id=0  comu_id=0
    ...     | ssh.execute     command=uptime  connection=${asxx_alias}
    ...
    [Arguments]    ${gnb_id}=${0}  ${du_id}=${0}  ${comu_id}=${0}  ${alias}=ssh-gnb-${gnb_id}-${du_id}-${comu_id}
    ${proxy}=      Set variable    ${None}
    ssh.Connect_to      hostname=${tl.gnbs[${gnb_id}].dus[${du_id}].airscale.common_units[${comu_id}].lmp_connection.addr}
    ...                 username=${tl.gnbs[${gnb_id}].dus[${du_id}].airscale.common_units[${comu_id}].lmp_connection.username}
    ...                 password=${tl.gnbs[${gnb_id}].dus[${du_id}].airscale.common_units[${comu_id}].lmp_connection.password}
    ...                 alias=${alias}
    ...                 proxy=${proxy}
    ssh.Force Reconnect    ${alias}
    [Return]    ${alias}

Get source IP address
    [Documentation]     [PRIVATE]
    ...  :Author: Valentin Hirzel
    [Arguments]    ${gnb_id}=${0}  ${du_id}=${0}  ${comu_id}=${0}
    ${asik_alias}=    ttitrace.Connect to gNB Common Unit  gnb_id=${gnb_id}  du_id=${du_id}  comu_id=${comu_id}
    ${raw_ip}=  ssh.execute  ip -o -4 addr show | grep [b,f][p,r][0,1]  connection=${asik_alias}
    ${source_ip}=  ttitrace_tools.get source IP address  raw_ip=${raw_ip}
    [return]  ${source_ip}

Determine Output File Path
    [Documentation]     [PRIVATE]
    ...  :Author: Srihari Janardhan
    [Arguments]  ${input_file_path}=${EMPTY}  ${output_file_path}=${EMPTY}
    ${output_file_path}=  Run Keyword if   '${output_file_path}'=='${EMPTY}'  Generate default output file path  input_file_path=${input_file_path}
    ...  ELSE  Set Variable  ${output_file_path}
    [Return]  ${output_file_path}

Generate default output file path
    [Documentation]     [PRIVATE]
    ...  :Author: Srihari Janardhan
    [Arguments]  ${input_file_path}=${EMPTY}
    ${output_file_path}=  Split Path	${input_file_path}
    [Return]  ${output_file_path[0]}

Get tc log directory
    [Documentation]     [PRIVATE]
    ${status}  ${message}=   Run Keyword And Ignore Error      Variable Should Exist       ${LOG_PATH}
    Should not contain    ${status}    FAIL     variable LOG_PATH doesnt exists!
    [Return]  ${LOG_PATH}

Collect TTI Traces in Streaming mode
    [Documentation]  :Author: Srihari Janardhan (Modified by Ch SAMSON) | This keyword detects collects TTI traces
    ...  for a defined period of time.
    ...  PS: Works only for Classical TL.
    ...    :param tti_trace_path:     Directory where TTI Trace is placed     default - Test Case Log directory
    ...    :param tti_trace_filename: Name of tti trace file                  default - ttitrace_streaming.pcap
    ...    :param tti_trace_duration: Length of trace capture in seconds      [1.. ]  default 10
    ...    :param gnb_id:             Id of gNB                               [0.. ]  default 0
    ...    :param du_id:              Id of DU                                [0..16] default 0
    ...    :param comu_id:            Id of Common Unit                       [0...1] default 0
    ...    :param capu_id:            Id of Capcity Unit                      [1...3] default 0
    ...    :param filter_bitmap1:     Filter bitmap1 for TTI Trace filtering  [0x...] default 0xFFFFFFFF
    ...    :param filter_bitmap2:     Filter bitmap2 for TTI Trace filtering  [0x...] default 0xFFFFFFFF
    ...    :param trace_ip:           Destination IP where TTI Trace is captured      default x2c Network address on Test PC
    ...    :param cell_distid:        DistName id of the cell                 [List of cell distnames]
    ...    default  ['/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-1/NRCELL_R-1']
    ...
    [Arguments]  ${tti_trace_path}=None
    ...  ${tti_trace_duration}=10
    ...  ${gnb_id}=${0}
    ...  ${du_id}=${0}
    ...  ${comu_id}=${0}
    ...  ${capu_id}=${0}
    ...  ${filter_bitmap1}=0xFFFFFFFF
    ...  ${filter_bitmap2}=0xFFFFFFFF
    ...  ${tti_trace_filename}=ttitrace_streaming
    ...  ${trace_ip}=${EMPTY}
    ...  ${cell_distid}=${EMPTY}
    ${filter_bitmap1}=    Set Variable    ${filter_bitmap1}
    ${filter_bitmap2}=    Set Variable    ${filter_bitmap2}
    #${cell_distid}=  Set Variable if  '${cell_distid}'=='${EMPTY}'  ${default_cell_dist_id}  ${cell_distid}
    # Set SW Config On Common Module  rad_param=0x580115  rad_param_value=${filter_bitmap1}  gnb_id=${gnb_id}
    # ...  du_id=${du_id}  comu_id=${comu_id}
    # Set SW Config On Common Module  rad_param=0x580116  rad_param_value=${filter_bitmap2}  gnb_id=${gnb_id}
    # ...  du_id=${du_id}  comu_id=${comu_id}
    # ${bts_type}=  Get gNB type  gnb_id=${gnb_id}
    ${bts_type}  set variable   'classical'
    BuiltIn.Log  BTS Type Identified : ${bts_type}
    ${dest_ip}=  Identify Destination IP for tti trace capture  ${bts_type}  ${trace_ip}
    BuiltIn.Log  TTI Traces are forwarded to IP: ${dest_ip}
    ${dir_tti_trace}=  run keyword if  '${tti_trace_path}'=='None'  Get tc log directory
    ...  ELSE  Set Variable  ${tti_trace_path}
    ${collector}=   Identify TTI Trace Capture Location and start TCPDump
    ...  bts_type=${bts_type}  gnb_id=${gnb_id}  tti_trace_filename=${tti_trace_filename}
    Start Generation of TTI Trace Using TAF Lib   gnb_id=${gnb_id}  du_id=${du_id}  comu_id=${comu_id}  capu_id=${capu_id}
    ...  dest_ip=${dest_ip}  collector=${collector}  cell_dist_id=${cell_distid}  bts_type=${bts_type}
    Sleep  ${tti_trace_duration}s
    BuiltIn.Log    Sleep ${tti_trace_duration}s
    Stop Generation of TTI Trace Using TAF Lib  desired_storage_directory=${dir_tti_trace}  desired_file_name=${tti_trace_filename}
    ...  collector=${collector}


Start TTI Traces in Streaming mode Multi
    [Documentation]  :Author: Srihari Janardhan | This keyword detects the type of 5g bts and starts TTI traces.
    ...      Modified in order to work with AIC - dont forget to perform first in your test the add of the
    ...        uplane route from -  SCF.robot - Add TTI Route in SCF for AIC - and then commission your gnb with this scf
    ...    :param gnb_id:             Id of gNB                               [0.. ]  default 0
    ...    :param du_id:              Id of DU                                [0..16] default 0
    ...    :param comu_id:            Id of Common Unit                       [0...1] default 0
    ...    :param capu_id:            Id of Capcity Unit                      [1...3] default 0
    ...    :param filter_bitmap1:     Filter bitmap1 for TTI Trace filtering  [0x...] default 0xFFFFFFFF
    ...    :param filter_bitmap2:     Filter bitmap2 for TTI Trace filtering  [0x...] default 0xFFFFFFFF
    ...    :param trace_ip:           Destination IP where TTI Trace is captured      default x2c Network address on Test PC
    ...    :param cell_distid:        DistName id of the cell                 [List of cell distnames]
    ...    default  ['/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-1/NRCELL_R-1']
    ...    src_ip : by default capacity_unit from init.py,but for for some cases must be set to 10.0.1.2
    [Arguments]
    ...  ${gnb_id}=${0}
    ...  ${du_id}=${0}
    ...  ${comu_id}=${0}
    ...  ${capu_id}=${0}
    ...  ${filter_bitmap1}=0xFFFFFFFF
    ...  ${filter_bitmap2}=0xFFFFFFFF
    ...  ${trace_ip}=${EMPTY}
    ...  ${cell_distid}=${EMPTY}
    ...  ${src_ip}=${EMPTY}
    ...  ${up_destIpAddr_aic}=10.0.1.1
    ...  ${up_port_aic}=5678
    ...  ${nrcell_id_list_aic}=${None}
    ...  ${dscp_aic}=0
    ${gnb_id}=  Set Variable    ${gnb_id}
    ${du_id}=  Set Variable    ${du_id}
    ${comu_id}=  Set Variable    ${comu_id}
    ${capu_id}=  Set Variable    ${capu_id}
    ${filter_bitmap1}=    Set Variable    ${filter_bitmap1}
    ${filter_bitmap2}=    Set Variable    ${filter_bitmap2}
    ${cell_distid_2}=  Set Variable    ${cell_distid}
    ${trace_ip}=    Set Variable    ${trace_ip}
    ${src_ip}=  Set Variable    ${src_ip}
    ${up_port_aic}=  Set Variable    ${up_port_aic}
    ${up_destIpAddr_aic}=  Set Variable    ${up_destIpAddr_aic}
    Run Keyword If      ${isAic}             Run Keywords
    ...                 Start To Collect TTI Trace On AIC Multi    nrcell_id_list=${nrcell_id_list_aic}    dscp=${dscp_aic}
#    ...                 up_destIpAddr=${up_destIpAddr_aic}     up_port=${up_port_aic}
    ...    AND          Return from Keyword

Start TTI Traces in Streaming mode
    [Documentation]  :Author: Srihari Janardhan | This keyword detects the type of 5g bts and starts TTI traces.
    ...      Modified in order to work with AIC - dont forget to perform first in your test the add of the
    ...        uplane route from -  SCF.robot - Add TTI Route in SCF for AIC - and then commission your gnb with this scf
    ...    :param gnb_id:             Id of gNB                               [0.. ]  default 0
    ...    :param du_id:              Id of DU                                [0..16] default 0
    ...    :param comu_id:            Id of Common Unit                       [0...1] default 0
    ...    :param capu_id:            Id of Capcity Unit                      [1...3] default 0
    ...    :param filter_bitmap1:     Filter bitmap1 for TTI Trace filtering  [0x...] default 0xFFFFFFFF
    ...    :param filter_bitmap2:     Filter bitmap2 for TTI Trace filtering  [0x...] default 0xFFFFFFFF
    ...    :param trace_ip:           Destination IP where TTI Trace is captured      default x2c Network address on Test PC
    ...    :param cell_distid:        DistName id of the cell                 [List of cell distnames]
    ...    default  ['/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-1/NRCELL_R-1']
    ...    src_ip : by default capacity_unit from init.py,but for for some cases must be set to 10.0.1.2
    [Arguments]
    ...  ${gnb_id}=${0}
    ...  ${du_id}=${0}
    ...  ${comu_id}=${0}
    ...  ${capu_id}=${0}
    ...  ${filter_bitmap1}=0xFFFFFFFF
    ...  ${filter_bitmap2}=0xFFFFFFFF
    ...  ${trace_ip}=${EMPTY}
    ...  ${cell_distid}=${EMPTY}
    ...  ${src_ip}=${EMPTY}
    ...  ${up_destIpAddr_aic}=10.0.1.1
    ...  ${up_port_aic}=5678
    ...  ${nrcell_id_list_aic}=${None}
    ...  ${dscp_aic}=0
    ${up_port_aic}=  Set Variable    ${up_port_aic}
    ${up_destIpAddr_aic}=  Set Variable    ${up_destIpAddr_aic}
    ${filter_bitmap1}=    Set Variable    ${filter_bitmap1}
    ${filter_bitmap2}=    Set Variable    ${filter_bitmap2}
    Run Keyword If      ${isAic}             Run Keywords
    ...                 Start To Collect TTI Trace On AIC    nrcell_id_list=${nrcell_id_list_aic}    dscp=${dscp_aic}
#    ...                 up_destIpAddr=${up_destIpAddr_aic}     up_port=${up_port_aic}
    ...    AND          Return from Keyword
    #${cell_distid}=  Set Variable if  '${cell_distid}'=='${EMPTY}'  ${default_cell_dist_id}  ${cell_distid}
    # Set SW Config On Common Module  rad_param=0x580115  rad_param_value=${filter_bitmap1}  gnb_id=${gnb_id}
    # ...  du_id=${du_id}  comu_id=${comu_id}
    # Set SW Config On Common Module  rad_param=0x580116  rad_param_value=${filter_bitmap2}  gnb_id=${gnb_id}
    # ...  du_id=${du_id}  comu_id=${comu_id}
    # ${bts_type}=  Get gNB type  gnb_id=${gnb_id}
    ${bts_type}  set variable   classical
    BuiltIn.Log  BTS Type Identified : ${bts_type}
    ${dest_ip}=  Identify Destination IP for tti trace capture  ${bts_type}  ${trace_ip}
    BuiltIn.Log  TTI Traces are forwarded to IP: ${dest_ip}
    ${collector_tti_trace_pcap}=   Identify TTI Trace Capture Location and start TCPDump
    ...  bts_type=${bts_type}  gnb_id=${gnb_id}  tti_trace_filename=ttitrace_streaming
    Start Generation of TTI Trace Using TAF Lib   gnb_id=${gnb_id}  du_id=${du_id}  comu_id=${comu_id}  capu_id=${capu_id}
    ...  dest_ip=${dest_ip}  collector=${collector_tti_trace_pcap}  cell_dist_id=${cell_distid}  bts_type=${bts_type}
    ...    src_ip=${src_ip}
    Set Suite Variable  ${collector_tti_trace_pcap}

Stop TTI Traces in Streaming Mode
    [Documentation]  :Author: Srihari Janardhan | Stops TTI traces and stores the .pcap in the output directory by default
    ...  with the filename ttitrace_streaming.pcap. The output directory and file can be specified using the name parameters
    ...  tti_trace_path and tti_trace_filename respectively.
    ...  PS: Works only for Classical TL. Work in progress for cloud coam TLs
    [Arguments]  ${tti_trace_path}=${EMPTY}  ${tti_trace_filename}=ttitrace_streaming
    Run Keyword If      ${isAic}             Run Keywords
    ...                 Stop And Download TTI Trace On AIC
    ...                         desired_storage_directory=${tti_trace_path}
    ...                         desired_file_name=${tti_trace_filename}
    ...    AND          Return from Keyword          ${tti_trace_path}/${tti_trace_filename}.pcap
    ${dir_tti_trace}=  run keyword if  '${tti_trace_path}'=='${EMPTY}'  Get tc log directory
    ...  ELSE  Set Variable  ${tti_trace_path}
    Stop Generation of TTI Trace Using TAF Lib  desired_storage_directory=${dir_tti_trace}  desired_file_name=${tti_trace_filename}
    ...  collector=${collector_tti_trace_pcap}
    [Return]  ${dir_tti_trace}/${tti_trace_filename}.pcap

Convert pcap to udp
    [Documentation]  Author : Srihari Janardhan
    ...  This keyword strips tcp header and converts a pcap to a udp
    ...  The keyword accepts source and target as mandatory arguments.
    ...  :param source is the path to the pcap file
    ...  :param target is the path to the destination udp file
    ...  :param connection is the alias of the connection to a machine on which the conversion operates
    [Arguments]  ${source}   ${target}  ${connection}
    ssh.send_command
    ...  tshark -r ${source} --disable-protocol swe --disable-protocol syscom -T fields -e data | perl -0ne's/\n//g;print pack"H*",$_' > ${target}
    ...  connection=${connection}
    ssh.await execution end  connection=${connection}  timeout=30min

Convert TTI trace from pcap to excelCsv
    [Documentation]  Author : Valentin Hirzel
    ...  This keyword convertes TTi traces to CSV and requires the Library taf.converters.eventdecoder
    ...  :param input_file_path  -> Path to the input file (full Path with Filename) Example ${targed_Dir}/ttitraceStreaming.pcap
    ...  The creatd files will be saved at the Test Bese Directory. The name of the File is <folder Name>_{up/dl} for the uplink and downlink files.
    ...  Example: if the input is ttitrace_streaming.pcap, the Output Files will be in the same directory and called ttitrace_streaming_dl_and_ul.csv
    ...  and ttitrace_streming.pcap.up.csv

    [Arguments]  ${input_file_path}=${EMPTY}  ${output_file_path}=${EMPTY}  ${options}=-d combineDlAndUl
    ${input_file_path}=  ttitrace_tools.add File ending if missing  file_path=${input_file_path}  file_ending=.pcap
    ${output_file_path}=  Determine Output File Path  input_file_path=${input_file_path}  output_file_path=${output_file_path}
    tce.Create eventDecoder Converter
    ...  name=converter
    ...  input_file_path=${input_file_path}
    ...  output_file_format=excelCsv
    ...  output_file_path=${output_file_path}
    ...  excel_csv_options=${options}
    tce.Convert
    ...  name=converter

Convert TTI trace from pcap to others
    [Documentation]  Author : Alina Roman
    ...  This keyword convertes TTi traces to Json or others and requires the Library taf.converters.eventdecoder
    ...  :param input_file_path  -> Path to the input file (full Path with Filename) Example targed_Dir/ttitraceStreaming.pcap
    ...  output file format: can be "json", "legacyCsv" or "excelCsv", default is "legacyCsv"

    [Arguments]  ${input_file_path}
    ...          ${output_file_format}=json
    ${pathOfOutput}	   ${fileName}          	Split Path	                   ${input_file_path}
    @{words} 	Split String	${fileName}	        .pcap
    ${output_file_path}           set variable      ${pathOfOutput}/${words[0]}
    tce.Create eventDecoder Converter
    ...  name=converter
    ...  input_file_path=${input_file_path}
    ...  output_file_format=${output_file_format}
    ...  output_file_path=${output_file_path}
    tce.Convert
    ...  name=converter
    Dated Log     The ${output_file_format} file is generated here: ${output_file_path}.${output_file_format}
    [Return]     ${output_file_path}.${output_file_format}

Get TTI Trace Path
    [Documentation]  Author : Alina Roman
    ...  Creates dir TTITraces+suffix user is giving. And returns the path where tti traces will be saved
    [Arguments]                  ${dir_suffix}=${EMPTY}
    ${alias}                     SSH Connect           ${HOST_EPCSIM}
    Run Keyword If               '${dir_suffix}'=='${EMPTY}'
    ...                          Set Suite Variable           ${nps_tti_trace_dir}         ${LOG_PATH}/TTITraces
    ...     ELSE                 Set Suite Variable           ${nps_tti_trace_dir}         ${LOG_PATH}/TTITraces_${dir_suffix}
    ${outMkdir}                  csn.execute                  mkdir -p ${nps_tti_trace_dir}
    ...                          connection=${alias}
    Dated Log                    Output tti traces path is: ${nps_tti_trace_dir}
    [Return]                     ${nps_tti_trace_dir}


#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
# AIC Keywords
#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

Start To Collect TTI Trace On AIC
    [Documentation]
    ...    ATTENTION : the keyword "Scf.Add TTI Route in SCF for AIC" must be called to update the SCF with the route
    ...                before calling this keyword
    ...    Start to collect TTI traces for AIC
    ...    |  nrcell_id_list     |   the nr cell id list, ${None} is the default and means the 1st cell |
    ...    |  dscp               |   the dscp value,  "0" by default |
    ...    |  up_destIpAddr      |   the IP address where TTI traces are sent to, "10.0.1.1" by default |
    ...    |  up_port            |   the port where TTI traces are sent to, "5678" by default |
    ...    |  interface          |   the network interface where TTI traces are sent to, "eth3" by default |
    ...    |  option             |   options to be passed to tcpdump providing the path where TTI .pcap file is generated |
    ...    Example
    ...    |  @{cellList} =  Create List |  1            |
    ...    |  Start To Collect TTI Trace |  ${cellList}  |
    [Arguments]    ${nrcell_id_list}=${None}
    ...            ${dscp}=0
    ...            ${up_destIpAddr}=172.16.2.10
    ...            ${up_port}=5678
    ...            ${interface}=eth9
    ...            ${option}=port ${up_port}
    Start Tcpdump on VM AIC           interface=${interface}            option=${option}   collectorAIC=TTItcpdumpAic
    ${default_nrcell_id_list}         get slice from list               ${NRCELL_ID_LIST_DU}   end=1
    ${tmp_nrcell_id_list}             set variable if                   ${nrcell_id_list} is ${None}
    ...                               ${default_nrcell_id_list}         ${nrcell_id_list}
    ${tti_activ_trace_id}             _Start TTI Trace Via UPTrace AIC       nr_cell_list=${tmp_nrcell_id_list}   dscp=${dscp}
    ...                               up_destIpAddr=${up_destIpAddr}    up_port=${up_port}

Start To Collect TTI Trace On AIC Multi
    [Documentation]
    ...    ATTENTION : the keyword "Scf.Add TTI Route in SCF for AIC" must be called to update the SCF with the route
    ...                before calling this keyword
    ...    Start to collect TTI traces for AIC on Multi Cells
    ...    |  nrcell_id_list     |   the nr cell id list, ${None} is the default and means the 1st cell |
    ...    |  dscp               |   the dscp value,  "0" by default |
    ...    |  up_destIpAddr      |   the IP address where TTI traces are sent to, "10.0.1.1" by default |
    ...    |  up_port            |   the port where TTI traces are sent to, "5678" by default |
    ...    |  interface          |   the network interface where TTI traces are sent to, "eth3" by default |
    ...    |  option             |   options to be passed to tcpdump providing the path where TTI .pcap file is generated |
    ...    Example
    ...    |  @{cellList} =  Create List |  1            |
    ...    |  Start To Collect TTI Trace |  ${cellList}  |
    [Arguments]    ${nrcell_id_list}=${None}
    ...            ${dscp}=0
    ...            ${up_destIpAddr}=172.16.2.10
    ...            ${up_port}=5678
    ...            ${interface}=eth9
    ...            ${option}=port ${up_port}
    Start Tcpdump on VM AIC           interface=${interface}            option=${option}   collectorAIC=TTItcpdumpAic
    @{default_nrcell_id_list}=    Create List
    FOR    ${item}    IN    @{NRCELL_ID_LIST_DU}
        Run Keyword If    '${item}' != 'None'    Append To List    ${default_nrcell_id_list}    ${item}
    END
    ${tmp_nrcell_id_list}             set variable if                   ${nrcell_id_list} is ${None}
    ...                               ${default_nrcell_id_list}         ${nrcell_id_list}
    ${tti_activ_trace_id}             _Start TTI Trace Via UPTrace AIC       nr_cell_list=${tmp_nrcell_id_list}   dscp=${dscp}
    ...                               up_destIpAddr=${up_destIpAddr}    up_port=${up_port}

_Start TTI Trace Via UPTrace AIC
    [Documentation]  INTERNAL USAGE
    ...    Start TTI trace using UPLANE trace on VDU
    ...    |  nrcell_id_list     |   the nr cell id list, ${None} is the default and means the 1st cell |
    ...    |  dscp               |   the dscp value,  "0" by default |
    ...    |  up_destIpAddr      |   the destination IP address, "10.0.1.1" by default |
    ...    |  up_port            |   the UP port, "5678" by default |
    [Arguments]    ${nr_cell_list}
    ...            ${dscp}=0
    ...            ${up_destIpAddr}=10.0.1.1
    ...            ${up_port}=5678

    ${cell_list}    create list
    FOR   ${cell_id}    IN    @{nr_cell_list}
         ${cell_dn}    set variable   MRBTS-${MRBTS_ID_DU}/NRBTS-${NRBTS_ID_DU}/NRCELL-${cell_id}
         append to list   ${cell_list}    ${cell_dn}
    END
    _Update User Plane Trace Configuration For vDU AIC    uplane_ip_addr=${up_destIpAddr}    uplane_port=${up_port}    dscp=${dscp}
    ${tti_activ_trace_id}=    _Start Uplane Trace For vDU AIC    target_component=L2Ps     nr_cell_dn_list=${cell_list}    trace_type=Component
    Set Suite Variable        ${tti_activ_trace_id}
    Dated Log            Activated TTI trace Id is: ${tti_activ_trace_id}
    [Return]     ${tti_activ_trace_id}

_Update User Plane Trace Configuration For vDU AIC
    [Documentation]  INTERNAL USAGE
    ...    Update user plane configuration
    ...    |  dscp               |   the dscp value,  "0" by default |
    ...    |  up_destIpAddr      |   the destination IP address, "10.0.1.1" by default |
    ...    |  up_port            |   the UP port, "5678" by default |
    [Arguments]   ${uplane_ip_addr}=10.0.1.1
    ...           ${uplane_port}=5678
    ...           ${dscp}=0
    ${uplane_port_1}    Convert To Integer    ${uplane_port}
    ${dscp_1}    Convert To Integer    ${dscp}
    &{args}      Create Dictionary     uplane_ip_addr="${uplane_ip_addr}"
    ...                                uplane_port=${uplane_port_1}
    ...                                dscp=${dscp_1}
    ${res1}      OAM Run Command    oam=${GNB_DU.oam}
    ...                             cmd=update_uplane_configuration
    ...                             cmd_args=${args}
    sleep    10s
    &{args}      Create Dictionary     operation_id="${res1}"
    ${res2}      OAM Run Command    oam=${GNB_DU.oam}
    ...                             cmd=get_trs_api_operation_status
    ...                             cmd_args=${args}
    [Return]    ${res2}

_Start Uplane Trace For vDU AIC
    [Documentation]  INTERNAL USAGE
    ...    Start Uplane TTI stream inside GNB
    ...    |  target_component   |   the component who generates the traces, "L2Ps" by default |
    ...    |  nr_cell_dn_list    |   list of cells which are monitored, 1st cell in the configured cells list by default |
    ...    |  trace_type         |   "Component" by default |
    [Arguments]    ${target_component}=L2Ps
    ...            ${nr_cell_dn_list}=${None}
    ...            ${trace_type}=Component

    &{args}      Create Dictionary     target_component="${target_component}"
    ...                                nr_cell_dn_list=${nr_cell_dn_list}
    ...                                trace_type="${trace_type}"
    ${res1}      OAM Run Command    oam=${GNB_DU.oam}
    ...                             cmd=start_uplane_trace_stream
    ...                             cmd_args=${args}
    Log To Console    ${res1}
    sleep    3s
    ${res2}      OAM Run Command    oam=${GNB_DU.oam}
    ...                             cmd=get_active_trace_streams
    Log To Console             TTI active_trace_streams: ${res2[0]['trace_id']}
    [Return]    ${res2[0]['trace_id']}

Start Tcpdump on VM AIC
    [Documentation]  INTERNAL USAGE
    ...    Start tcpdump to capture TTI traces on the test line VM
    ...    |  interface     |   network interface where to capture the traces, "eth3" by default |
    ...    |  option        |   option to be used by tcpdump for capturing traces (output filename, ...) |
    ...    |  collectorAIC  |   string representing the name of the collector, "TTItcpdumpAic" by default |
    [Arguments]     ${interface}=eth3
    ...             ${option}=port 5678
    ...             ${collectorAIC}=TTItcpdumpAic
    ${testpc_ssh_config}=  Create Dictionary
    ...     host=${HOST_EPCSIM.sshConnection.addr}
    ...     user=${HOST_EPCSIM.sshConnection.username}
    ...     password=${HOST_EPCSIM.sshConnection.password}
    tcpdump.create_tcpdump_collector
    ...     name=${collectorAIC}
    ...     options=-i ${interface} ${option}
    ...     executor=${testpc_ssh_config}
    core.setup_collectors    names=${collectorAIC}
    core.start_collectors    names=${collectorAIC}
    core.set_suite_alias     ${collectorAIC}
    Set Suite Variable           ${collectorAIC}
    [Return]    ${collectorAIC}

Stop Tcpdump on VM AIC
    [Documentation]  INTERNAL USAGE
    ...    Stop tcpdump on the test line VM
    ...    |  desired_storage_directory     |   path where to store TTI traces, test path by default |
    ...    |  desired_file_name             |   TTI trace filename, "ttitrace_streaming" by default |
    [Arguments]     ${desired_storage_directory}=${EMPTY}
    ...             ${desired_file_name}=ttitrace_streaming
    Dated Log        desired_storage_directory: ${desired_storage_directory}
    Dated Log        desired_file_name: ${desired_file_name}
    ${desired_storage_directory}=                set variable if    '${desired_storage_directory}'=='${EMPTY}'
    ...                                           ${LOG_PATH}                         ${desired_storage_directory}
    core.stop_collectors    names=${collectorAIC}
    core.collect_collectors    names=${collectorAIC}     target_dir=${desired_storage_directory}
    core.teardown_collectors    names=${collectorAIC}
    Move Trace File to Desired Directory AIC    desired_storage_directory=${desired_storage_directory}
    ...                                         desired_file_name=${desired_file_name}    collector=${collectorAIC}

Stop And Download TTI Trace On AIC
    [Documentation]
    ...    Stop tcpdump and Uplane streaming
    ...    |  desired_storage_directory     |   path where to store TTI traces, test path by default |
    ...    |  desired_file_name             |   TTI trace filename, "ttitrace_streaming" by default |
    [Arguments]          ${desired_storage_directory}=${LOG_PATH}
    ...                  ${desired_file_name}=ttitrace_streaming
    log to console             Stop L2PS TTI trace(uplane trace stream) in AIC

    ${res2}      OAM Run Command    oam=${GNB_DU.oam}
    ...                             cmd=get_active_trace_streams
    Log To Console    Active trace is: ${res2[0]['trace_id']}

    &{args}      Create Dictionary     trace_id="${res2[0]['trace_id']}"

    ${res1}      OAM Run Command    oam=${GNB_DU.oam}
    ...                             cmd=stop_uplane_trace_stream
    ...                             cmd_args=${args}
    Stop Tcpdump on VM AIC      desired_storage_directory=${desired_storage_directory}
    ...                         desired_file_name=${desired_file_name}

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
# Private keywords --> must not used outside of this file!
#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

Identify Destination IP for tti trace capture
    [Documentation]     [PRIVATE]
    ...  :Author: Srihari Janardhan
    [Arguments]  ${bts_type}  ${trace_ip}
    ${trace_ip}=  Set Variable if  '${tl.gnbs[${0}].cu.x2c.v4}'=='10.1.1.1'  10.0.1.1  ${trace_ip}
    ${backhaul_ip}=  Set Variable if  '${bts_type}'=='classical' and '${trace_ip}'=='${EMPTY}'  ${tl.gnbs[${0}].cu.x2c.v4}  ${trace_ip}
    # ${backhaul_ip}=  Set Variable if  '${bts_type}'=='classical' and '${trace_ip}'=='${EMPTY}'  10.0.1.1  ${trace_ip}
    Set Test Variable  ${backhaul_ip}
    ${dest_ip}=  set variable if  '${bts_type}'=='classical'  ${backhaul_ip}  ${fronthaul_ip_oam}
    [Return]  ${dest_ip}


Identify TTI Trace Capture Location and start TCPDump
    [Documentation]     [PRIVATE]
    ...  :Author: Srihari Janardhan ; Mofified by Ch SAMSON
    [Arguments]  ${bts_type}  ${tti_trace_filename}=${EMPTY}  ${gnb_id}=0
    ${collector}=     Connect to test pc and start TCPDump on backhaul interface    backhaul_ip=${backhaul_ip}  tcpdump_name=${tti_trace_filename}
    ${bts_type}=  Set Variable    ${bts_type}
    ${gnb_id}=  Set Variable    ${gnb_id}
    [Return]    ${collector}

Connect to test pc and start TCPDump on backhaul interface
    [Documentation]     [PRIVATE]
    ...  :Author: Srihari Janardhan
    [Arguments]  ${backhaul_ip}=192.168.4.1  ${tcpdump_name}=${EMPTY}
    ${connection}=  ttitrace.Connect to TestPC
    ${interface_name}=  ttitrace.Identify Interface with IP  ip=${backhaul_ip}  connection=${connection}
    BuiltIn.Log  Identifed interface on for TCP Dump on Test PC is : ${interface_name}   console=${P_console}
    ${collector}=    ttitrace.Start Tcpdump on TestPc     interface=${interface_name}  option=port 5678
    ...  collector=${tcpdump_name}
    [Return]    ${collector}

Connect to CPIF and Start TCP Dump on fronthaul
    [Documentation]     [PRIVATE]
    ...  :Author: Srihari Janardhan
    [Arguments]  ${gnb_id}=0  ${tti_trace_filename}=${EMPTY}
    ${collector}=   tcpdump.Start TCPdump on gNB VM    vm_name=cpif    gnb_id=${gnb_id}    interface=fronthaul    option=port 5678
    ...  collector=${tti_trace_filename}
    [Return]    ${collector}

Start Generation of TTI Trace Using TAF Lib
    [Documentation]     [PRIVATE]
    ...  :Author: Srihari Janardhan
    ...    src_ip : by default capacity_unit from init.py,but for for some cases as LOLO it doesnt work and should be set to 10.0.1.2
    ...    src_ip not needed anymore =>  replaced by Get source IP address
    [Arguments]  ${dest_ip}  ${collector}  ${cell_dist_id}  ${bts_type}
    ...  ${gnb_id}=${0}  ${du_id}=${0}  ${comu_id}=${0}  ${capu_id}=${0}
    ...     ${src_ip}=${EMPTY}
    ${_collector_name}=  Set variable  l2stream3
    ${src_ip_2}=    Set variable   ${src_ip}
    ${capu_id}=    Set Variable    ${capu_id}
    ${executor}=  Run Keyword if  '${bts_type}'=='classical'  Get OAM Webservice connection for Classical gNB  gnb_id=${gnb_id}
    ...  ELSE  Get OAM Webservice connection for Cloud gNB  gnb_id=${gnb_id}  du_id=${du_id}

    IF    "${cell_distid}"=="${EMPTY}"
        @{internalDNs}    Create List
        @{cellsNr}    OAM Get Cells Nr    oam=${GNB_DU.oam}
        FOR    ${c}    IN    @{cellsNr}
             ${cell_status_}=    Set variable  ${c['status']}
             ${operationalState}=   Set Variable   ${cell_status_['operationalState']}
             run Keyword if    '${operationalState.lower()}'=='enabled'    Append to List    ${internalDNs}    ${c['id']['internal']}
        END
        ${nr_cell_dns}=  Set Variable    ${internalDNs}
    ELSE
        ${nr_cell_dns}=  Set Variable    ${cell_distid}
    END
    Dated Log    nr_cell_dns for TTI Trace: ${nr_cell_dns}
    ${l2_stream_config_1}=  Create Dictionary
    ...  nr_cell_dns=${nr_cell_dns}
    @{l2_stream_configuration}    Create List    ${l2_stream_config_1}
    ${source_ip_addr}=  Get source IP address  gnb_id=${gnb_id}  du_id=${du_id}  comu_id=${comu_id}
    l2stream3.create_sbts_l2stream_collector
    ...  name=${_collector_name}
    ...  webservice=${executor}
    ...  source_ip_addr=${source_ip_addr}
    ...  destination_ip_addr=${dest_ip}
    ...  dscp=15
    ...  collector=${collector}
    ...  l2_stream_configuration=${l2_stream_configuration}
    core.setup_collectors    names=${_collector_name}
    core.start_collectors    names=${_collector_name}
    core.Set Suite Alias     ${_collector_name}

Stop Generation of TTI Trace Using TAF Lib
    [Documentation]     [PRIVATE]
    ...  :Author: Srihari Janardhan
    [Arguments]  ${desired_storage_directory}=${EMPTY}  ${desired_file_name}=ttitrace_streaming  ${collector}=${EMPTY}
    core.stop_collectors    names=l2stream3
    core.collect_collectors    names=l2stream3  target_dir=${desired_storage_directory}
    core.teardown_collectors    names=l2stream3
    Move Trace File to Desired Directory  desired_storage_directory=${desired_storage_directory}  desired_file_name=${desired_file_name}
    ...  collector=${collector}

Move Trace File to Desired Directory
    [Documentation]     [PRIVATE]
    ...  :Author: Srihari Janardhan
    [Arguments]  ${desired_storage_directory}  ${desired_file_name}  ${collector}
    Move file  ${desired_storage_directory}/l2stream3/${collector}/${collector}.pcap
    ...  ${desired_storage_directory}/${desired_file_name}.pcap
    Remove Directory  ${desired_storage_directory}/l2stream3/  recursive=True

Move Trace File to Desired Directory AIC
    [Documentation]     [PRIVATE]
    [Arguments]     ${desired_storage_directory}      ${desired_file_name}        ${collector}
    ${desired_storage_directory}     Set Variable If       '${desired_storage_directory}'=='${EMPTY}'
    ...                              ${LOG_PATH}      ${desired_storage_directory}
    Move file  ${desired_storage_directory}/${collector}/${collector}.pcap
    ...        ${desired_storage_directory}/${desired_file_name}.pcap
    Remove Directory  ${desired_storage_directory}/${collector}/  recursive=True

Get OAM Webservice connection for Classical gNB
    [Documentation]     [PRIVATE]
    ...  :Author: Srihari Janardhan
    [Arguments]  ${gnb_id}
    ${executor_classical}=  Create Dictionary
    ...  host=${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.addr}
    ...  user=${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.username}
    ...  password=${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.password}
    ...  port=443
    [Return]  ${executor_classical}

Get OAM Webservice connection for Cloud gNB
    [Documentation]     [PRIVATE]
    ...  :Author: Srihari Janardhan
    [Arguments]  ${gnb_id}  ${du_id}
    ${executor_cloud_coam}=  Create Dictionary
    ...  host=${tl.gnbs[${gnb_id}].dus[${du_id}].f1_m_ip_addr}
    ...  user=${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.username}
    ...  password=${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.password}
    ...  port=443
    [Return]  ${executor_cloud_coam}

Get Control Board Type
    [Documentation]    this keyword is used to get control board Type, ASIK, ASIB, ASIL etc.
    ...    Examples:
    ...    | ${control_board_type}= | Get Control Board Type |
    ute_fsmaccess.Setup Enb Fsm Access
    ${cmd}=    Set Variable    cat /proc/device-tree/module-identity/unit-id
    ${board_type}=    ute_fsmaccess.Execute Command On Enb    ${cmd}
    ${board_type}=    String.Replace String Using Regexp    ${board_type}    \x00    ${EMPTY}
    Log    Control Board Type is ${board_type}    console=${True}
    Set Global Variable    ${FCT_BOARD_TYPE}    ${board_type}
    [Teardown]    ute_fsmaccess.Teardown Enb Fsm Access
    [Return]    ${board_type}

Get Base Band Board Type
    [Documentation]    this keyword is used to get base band board Type, ABIL??ABIO??ABIN etc.
    ...    Examples:
    ...    | ${base_band_type}= | Get Base Band Board Type |
    ute_fsmaccess.Setup Enb Fsm Access
    ${board_type_list}    Create List
    FOR    ${loop}    IN RANGE    1    4
        ${cmd}=    Set Variable    bsh ${loop}:0 cat /proc/device-tree/module-identity/unit-id
        ${board_type}=     Run Keyword And Ignore Error    ute_fsmaccess.Execute Command On Enb    ${cmd}
        Exit For Loop If   'FAIL' in ${board_type}
        ${board_type}=    String.Replace String Using Regexp    ${board_type[1]}    \x00    ${EMPTY}
        Log    Base Band Board Type is ${board_type}    console=${True}
        Append To List    ${board_type_list}    ${board_type}
    END
    Set Global Variable    ${ASP_BOARD_TYPE}    ${board_type_list}
    [Teardown]    ute_fsmaccess.Teardown Enb Fsm Access
    [Return]   ${board_type_list}

Cath and Decode Ttitrace With Snapshot Mode Catch Continously
    [Arguments]    ${log_path}   ${time}=1s
    Catch Ttitrace Log     ${time}
    Decode TTI Trace And Send To Control PC One By One     ${log_path}/

Catch Ttitrace Log
    [Arguments]    ${wait_time}=5
    [Documentation]    This keyword is to start gnb ttitrace.
    ...    Examples:
    ...    | Catch Ttitrace Log | wait_time=5s |
    Log To Console    INFO:start tti trace on asp...
    ${cpu_id}=    Set Variable If    "${ASP_BOARD_TYPE}"=="ABIO"    0    1
    OperatingSystem.Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.129 bsh 1:${cpu_id} rm -rf /var/eventsTrace/*
    ${cmd}=    Catenate    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.129
    ...    bsh 1:${cpu_id} ls -l /tmp/ 2>/dev/null|grep -e ".*ram.*L2RT20"|awk -F "node_" '{print $2}'|awk -F " " '{print $1}'
    ${ret}    ${output}=    OperatingSystem.Run And Return Rc And Output    ${cmd}
    ${container_id}=    Set Variable    ${output}
    ${ttitrace_cmd}=    Set Variable    sh /opt/tools/ttiTrace/eventsCollect.sh
    ${cmd}=    Catenate    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.129
    ...    bsh 1:${cpu_id} timeout ${wait_time} lxc-attach -n ${container_id} ${ttitrace_cmd}
    OperatingSystem.Run    ${cmd}
    Show Ttitrace Log On ASP

Show Ttitrace Log On ASP
    ${cpu_id}=    Set Variable If    "${ASP_BOARD_TYPE}"=="ABIO"    0    1
    ${ttitrace_bin_log}=    Catenate    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.129
    ...    bsh 1:${cpu_id} ls -lrt /var/eventsTrace/
    ${rc}    ${output}=    OperatingSystem.Run And Return Rc And Output    ${ttitrace_bin_log}
    Log To Console    INFO:ttitrace log list:${output}


Start GNB TTI Trace
    [Arguments]    ${band_id}=1    ${L2RT_id}=20
    [Documentation]    This keyword is to start gnb ttitrace.
    ...    [2021.11.19] add two variables
    ...     ${band_id} for cell on which board, ABIO, ABIL
    ...     ${L2RT_id} for the id for L2RT, as for ABIO, there are L2RT20 & L2RT21.
    ...
    ...    Examples:
    ...    | Start GNB TTI Trace | wait_time=5s |
    ...
    Log To Console    INFO:start tti trace on asp...
    ${cpu_id}=    Set Variable If    "${ASP_BOARD_TYPE}"=="ABIO"    0    1
    OperatingSystem.Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.129 bsh ${band_id}:${cpu_id} rm -rf /var/eventsTrace/*
    ${cmd}=    Catenate    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.129 bsh ${band_id}:${cpu_id} ls -l /tmp/
    ...    2>/dev/null|grep -e ".*ram.*L2RT${L2RT_id}"|awk -F "node_" '{print $2}'|awk -F " " '{print $1}'
    ${ret}    ${output}=    OperatingSystem.Run And Return Rc And Output    ${cmd}
    ${container_id}=    Set Variable    ${output}
    Set Suite Variable    ${TTITRACE_START_CMD}    sh /opt/tools/ttiTrace/eventsCollect.sh
    ${ssh_connect}=    Set Variable    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.129
    ${cmd}=    Set Variable     ${ssh_connect} bsh 1:${cpu_id} lxc-attach -n ${container_id} ${TTITRACE_START_CMD}
    ${TTITRACE_HANDLE}=    Process.Start Process    ${cmd}    shell=True
    Set Suite Variable    ${TTITRACE_HANDLE}


Stop And Decode GNB TTI Trace
    [Arguments]    ${log_dir}=${TEST_LOG_DIRECTORY}
    Stop GNB TTI Trace
    Decode TTI Trace And Send To Control PC One By One    ${log_dir}

Stop GNB TTI Trace
    [Documentation]    This keyword is to stop gnb ttitrace.
    ...
    ...    Examples:
    ...    | Stop GNB TTI Trace |
    ...
    ${result}=    Process.Terminate Process    ${TTITRACE_HANDLE}
    Log To Console    INFO:TTI trace end success...
    Kill Ttitrace Process On ASP
    Show Ttitrace Log On ASP

Show Ttitrace Process On Control PC
    OperatingSystem.Run    ps -ef|grep eventsCollect.sh

Show Ttitrace Process On ASP
    ${cpu_id}=    Set Variable If    "${ASP_BOARD_TYPE}"=="ABIO"    0    1
    ${ssh_cmd}=    Set Variable    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.129
    ${rc}    ${output}=    OperatingSystem.Run And Return Rc And Output    ${ssh_cmd} bsh 1:${cpu_id} ps aux|grep eventsCollect.sh

Kill Ttitrace Process On ASP
    ${cpu_id}=    Set Variable If    "${ASP_BOARD_TYPE}"=="ABIO"    0    1
    ${ssh_cmd}=    Set Variable    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.129
    ${rc}    ${output}=    OperatingSystem.Run And Return Rc And Output    ${ssh_cmd} bsh 1:${cpu_id} ps aux|grep eventsCollect.sh
    ${rc}    ${pids}=    OperatingSystem.Run And Return Rc And Output    ${ssh_cmd} bsh 1:${cpu_id} ps aux|grep eventsCollect.sh|awk '{print $2}'
    Log    ${pids}
    @{lines}=    String.Split To Lines    ${pids}
    :FOR   ${pid}    IN    @{lines}
    \    ${rc}    ${output}=    OperatingSystem.Run And Return Rc And Output    ${ssh_cmd} bsh 1:${cpu_id} kill -2 ${pid}
    Show Ttitrace Process On Control PC
    Show Ttitrace Process On ASP

Decode TTI Trace And Send To Control PC One By One
    [Arguments]    ${log_dir}=${TEST_LOG_DIRECTORY}
    [Documentation]    This keyword is to decode tti trace logs collected by keyword Start GNB TTI Trace
    ...    and put the result csv files in to ${log_dir}. In this process, one .sh script is used.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${log_dir} | No | default value is ${TEST_LOG_DIRECTORY} |
    ...
    ...    Examples:
    ...    | Decode TTI Trace And Send To Control PC One By One | log_dir=/home/ute/logs/ |
    ...
    Log To Console    INFO:start to decode tti .bin logs to csv
    OperatingSystem.Run And Return Rc And Output    sh ${CURDIR}/scripts/decode_ttitrace_on_PC.sh ${log_dir}
    Log To Console    INFO:finish to decode tti .bin logs to csv


Format Tti In Snapshot Mode
    [Arguments]    ${input_csv_name}    ${output_csv_name}    ${filters}=${EMPTY}
    [Documentation]    This keyword is to convert tti collected by eventsCollect.sh(snapshot mode)
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${input_csv_name} | Yes | str, ${CURDIR}/TtiFiles/L2TtiTrace_EventsSnapshot.bin.01.dl.csv |
    ...    | ${output_csv_name} | Yes | str, ${CURDIR}/TtiFiles/tti_snapshot.csv |
    ...    | ${filters} | No | str with separator ;, dlFdSchedData;dlFlowControlData |
    ...
    ...    Examples:
    ...    | Format Tti In Snapshot Mode | ${input_csv_name} | ${output_csv_name} |
    ...    | Format Tti In Snapshot Mode | ${input_csv_name} | ${output_csv_name} | ${filters} |
    ...
    Run Keyword If    '${filters}'=='${EMPTY}'    TtiConvert.Format Tti No Filters    ${input_csv_name}    ${output_csv_name}
    ...    ELSE    TtiConvert.Format Tti With Filters    ${input_csv_name}    ${output_csv_name}    ${filters}

Download TTI bin files to VM
    [Arguments]     ${tti_folder}
    create directory     ${LOG_PATH}/${tti_folder}
    ${ASP_board}=     Get BB Board Type        airscale=${AIRSCALE_GNB}
    ${CPU_ID}    set variable if    '${ASP_board}'=='ABIO'     ${0}    ${1}
    ${check_tti}=    Catenate    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.129
	...      bsh 1:${CPU_ID} ls -1rt /var/eventsTrace/*L2TtiTrace_EventsSnapshot.bin.*.tar.gz
    ${Result}=      Run Keyword And Ignore Error    Process.Run Process    command=${check_tti}    shell=yes
    ${download_tti}=    Catenate    sudo sshpass -p oZPS0POrRieRtu scp -p
    ...             toor4nsn@192.168.255.129 bsh 1:${CPU_ID}:/var/eventsTrace/*L2TtiTrace_EventsSnapshot.bin.*.tar.gz ${LOG_PATH}/${tti_folder}/
    Run Keyword And Ignore Error    Process.Run Process    command=${download_tti}     shell=yes

Download ASOE TTI bin files to VM
    [Arguments]     ${tti_folder}
    create directory     ${LOG_PATH}/${tti_folder}
	${check_tti}=    Catenate    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.129
	...      ls -1rt /var/eventsTrace/*L2TtiTrace_EventsSnapshot.bin.*.tar.gz
    ${Result}=      Run Keyword And Ignore Error    Process.Run Process    command=${check_tti}    shell=yes
    ${download_tti}=    Catenate    sudo sshpass -p oZPS0POrRieRtu scp -p
    ...             toor4nsn@192.168.255.129:/var/eventsTrace/*L2TtiTrace_EventsSnapshot.bin.*.tar.gz ${LOG_PATH}/${tti_folder}/
    Run Keyword And Ignore Error    Process.Run Process    command=${download_tti}     shell=yes

Generate DL CSV TTI File based on filters
    [Arguments]    ${tti_csv_dir}=${LOG_PATH}    ${filters}=${EMPTY}
    [Documentation]    | ${filters} | No | str with separator ;, dlFdSchedData;dlFlowControlData |
    ${out_file_name}    Set Variable    ${tti_csv_dir}/TTI_Traces_Filterd_DL.csv
    ${tti_csv_files}    OperatingSystem.List Files In Directory    ${tti_csv_dir}    *L2TtiTrace_EventsSnapshot.bin.*dl.csv    ${True}
    Should Not Be Empty    ${tti_csv_files}
    FOR    ${file}    IN    @{tti_csv_files}
        Format Tti In Snapshot Mode    ${file}    ${out_file_name}    ${filters}
    END

Generate UL CSV TTI File based on filters
    [Arguments]    ${tti_csv_dir}    ${filters}=${EMPTY}
    ${out_file_name}    Set Variable    ${tti_csv_dir}/TTI_Traces_Filterd_UL.csv
    ${tti_csv_files}    OperatingSystem.List Files In Directory    ${tti_csv_dir}    *L2TtiTrace_EventsSnapshot.bin.*ul.csv    ${True}
    Should Not Be Empty    ${tti_csv_files}
    FOR    ${file}    IN    @{tti_csv_files}
        Format Tti In Snapshot Mode    ${file}    ${out_file_name}    ${filters}
    END

Verify DL Per Slot Ue Numbers In Target File
    [Arguments]    ${tti_csv_name}    ${number}
    [Documentation]    tti csv file contains only dlFdSchedData msg, please refer to tti_convert.py for more infos
    ${times}    Evaluate    ${number}-1
    ${full_patt}    Set Variable    dlFdSchedData,(?P<sfn>\\d+),(?P<slot>\\d+).+\\n(?:dlFdSchedData,(?P=sfn),(?P=slot).+\\n){${times}}
    ${rnti_patt}    Set Variable    dlFdSchedData,\\d+,\\d+,(?P<rnti>\\d+)
    ${content}    OperatingSystem.Get File    ${tti_csv_name}
    ${matches}    String.Get Regexp Matches    ${content}    ${full_patt}
    ${check_result}    Set Variable    ${False}
    FOR    ${item}    IN    @{matches}
        ${rnti_vals}    String.Get Regexp Matches    ${item}    ${rnti_patt}    rnti
        ${count}    Evaluate    len(set(${rnti_vals}))
        ${check_result}    Run Keyword And Return Status    Should Be Equal As Integers    ${count}    ${number}
        Exit For Loop If    ${check_result}==${True}
    END
    [Return]    ${check_result}

Verify UL Per Slot Ue Numbers In Target File
    [Arguments]    ${tti_csv_name}    ${number}
    [Documentation]    tti csv file contains only ulFdSchedData msg, please refer to tti_convert.py for more infos
    ${times}    Evaluate    ${number}-1
    ${full_patt}    Set Variable    ulFdSchedData,(?P<sfn>\\d+),(?P<slot>\\d+).+\\n(?:ulFdSchedData,(?P=sfn),(?P=slot).+\\n){${times}}
    ${rnti_patt}    Set Variable    ulFdSchedData,\\d+,\\d+,(?P<rnti>\\d+)
    ${content}    OperatingSystem.Get File    ${tti_csv_name}
    ${matches}    String.Get Regexp Matches    ${content}    ${full_patt}
    ${check_result}    Set Variable    ${False}
    FOR    ${item}    IN    @{matches}
        ${rnti_vals}    String.Get Regexp Matches    ${item}    ${rnti_patt}    rnti
        ${count}    Evaluate    len(set(${rnti_vals}))
        ${check_result}    Run Keyword And Return Status    Should Be Equal As Integers    ${count}    ${number}
        Exit For Loop If    ${check_result}==${True}
    END
    [Return]    ${check_result}




