*** Settings ***
Documentation    This file contains examples of the keywords defined in ttitrace.robot

Resource    gnb.robot
Library    taf.collectors.tcpdump                                    WITH NAME  tcpdump
Library    taf.collectors.l2stream3                                  WITH NAME  l2stream3
Library    taf.collectors.core                                       WITH NAME  core
Library    taf.converters.eventdecoder                               WITH NAME  tce

*** Variables ***
${bts_type}    classical
${dest_ip}    ${tl.test_pc.default_ssh_connection_details.addr}
${P_admin_console}              ${False}    # debug output to console for setup oam http connections
${package_web_service}
...   https://artifactory-espoo2.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-local/build/
${tce_path}    /opt/tti-dec

*** Keywords ***
Start Syve TTI Traces in Streaming mode
    [Documentation]  :Author: Zhang Xuewen | This keyword detects the type of 5g bts and starts TTI traces.
    ...  PS: Works only for Classical TL. Work in progress for cloud coam TLs
    ...    :param gnb_id:             Id of gNB                               [0.. ]  default 0
    ...    :param du_id:              Id of DU                                [0..16] default 0
    ...    :param comu_id:            Id of Common Unit                       [0...1] default 0
    ...    :param capu_id:            Id of Capcity Unit                      [1...3] default 0
    ...    :param filter_bitmap1:     Filter bitmap1 for TTI Trace filtering  [0x...] default 0xFFFFFFFF
    ...    :param filter_bitmap2:     Filter bitmap2 for TTI Trace filtering  [0x...] default 0xFFFFFFFF
    ...    :param trace_ip:           Destination IP where TTI Trace is captured      default x2c Network address on Test PC
    ...    :param nr_phy_cell_ids:    NR Physical cell ids                    50,51  default  All Cells
    [Arguments]
    ...  ${gnb_id}=${0}
    ...  ${du_id}=${0}
    ...  ${comu_id}=${0}
    ...  ${capu_id}=${0}
    ...  ${filter_bitmap1}=0xFFFFFFFF
    ...  ${filter_bitmap2}=0xFFFFFFFF
    ...  ${trace_ip}=${EMPTY}
    ...  ${nr_phy_cell_ids}=${EMPTY}
    ...  ${tti_trace_filename}=ttitrace_streaming
    ...  ${up_destIpAddr_aic}=10.0.1.1
    ...  ${up_port_aic}=5678
    ...  ${nrcell_id_list_aic}=${None}
    ...  ${dscp_aic}=0
    ${nr_phy_cell_ids}=  Syve Determine NR Cell IDs  nr_phy_cell_ids=${nr_phy_cell_ids}
    BuiltIn.Log  BTS Type Identified : ${bts_type}
    CB008238_Common_KW.Set SW Config On Common Module  rad_param=0x580115  rad_param_value=${filter_bitmap1}  gnb_id=${gnb_id}
    ...  du_id=${du_id}  comu_id=${comu_id}
    CB008238_Common_KW.Set SW Config On Common Module  rad_param=0x580116  rad_param_value=${filter_bitmap2}  gnb_id=${gnb_id}
    ...  du_id=${du_id}  comu_id=${comu_id}
    ${dest_ip}=  Identify Destination IP for tti trace capture  ${bts_type}  ${trace_ip}
    BuiltIn.Log  TTI Traces are forwarded to IP: ${dest_ip}
    Create collectors and Start Generation of TTI Trace  gnb_id=${gnb_id}  du_id=${du_id}  comu_id=${comu_id}
    ...  dest_ip=${dest_ip}  tti_trace_filename=${tti_trace_filename}  nr_phy_cell_ids=${nr_phy_cell_ids}  bts_type=${bts_type}

Identify Destination IP for tti trace capture
    [Documentation]
    ...  :Author: Srihari Janardhan
    ...  This keyword identifies the destination IP i.e the IP address where the trace is to be collected
    ...  The keyword accpets the following parameters
    ...    :param bts_type:             Type of bts                              cloud / classical
    ...    :param trace_ip:             User desired trace ip                    10.0.1.1
    ...  returns the destination ip where the trace is to be collected
    [Arguments]  ${bts_type}  ${trace_ip}
    ${trace_ip}=  Set Variable if  '${tl.gnbs[${0}].cu.x2c.v4}'=='10.1.1.1'  10.0.1.1  ${trace_ip}
    ${backhaul_ip}=  Set Variable if  '${bts_type}'=='classical' and '${trace_ip}'=='${EMPTY}'  ${tl.gnbs[${0}].cu.x2c.v4}  ${trace_ip}
    Set Test Variable  ${backhaul_ip}
    ${dest_ip}=  set variable if  '${bts_type}'=='classical'  ${backhaul_ip}  ${fronthaul_ip_oam}
    [Return]  ${dest_ip}

Create collectors and Start Generation of TTI Trace
    [Documentation]     
    ...  :Author: Srihari Janardhan
    ...  This keyword starts the generation of TTI Trace
    ...  The keyword accpets the following parameters
    ...    :param gnb_id:             Id of gNB                               [0.. ]  default 0
    ...    :param du_id:              Id of DU                                [0..16] default 0
    ...    :param comu_id:            Id of Common Unit                       [0...1] default 0
    ...    :param tti_trace_filename: Name of the pcap file                   default: ttitrace_streaming
    ...    :param bts_type:           Bts type                                classical / cloud
    ...    :param nr_phy_cell_ids:    NR Physical cell ids                    50,51  
    ...    :param dest_ip:            Destination IP where TTI Trace is captured      default x2c Network address on Test PC
    ...    [Return]  Returns the collector name
    [Arguments]  ${tti_trace_filename}  ${bts_type}  ${nr_phy_cell_ids}  ${dest_ip}
    ...  ${gnb_id}=${0}  ${du_id}=${0}  ${comu_id}=${0}
    ${tti_trace_collector}=  Create TTI Trace Collector  tti_trace_filename=${tti_trace_filename}  bts_type=${bts_type}
    ...  nr_phy_cell_ids=${nr_phy_cell_ids}  dest_ip=${dest_ip}
    ...  gnb_id=${gnb_id}  du_id=${du_id}  comu_id=${comu_id}
    core.start_collectors    names=${tti_trace_collector}
    [Return]  ${tti_trace_collector}
  
Stop TTI Traces in Streaming mode
    [Documentation]  :Author: Srihari Janardhan | Stops TTI traces and stores the .pcap in the output directory by default
    ...  with the filename ttitrace_streaming.pcap. The output directory and file can be specified using the name parameters
    ...  tti_trace_path and tti_trace_filename respectively.
    ...  PS: Works only for Classical TL. Work in progress for cloud coam TLs
    [Arguments]  ${tti_trace_path}=${EMPTY}  ${tti_trace_filename}=ttitrace_streaming
    ${dir_tti_trace}=  run keyword if  '${tti_trace_path}'=='${EMPTY}'  Get testcase log directory
    ...  ELSE  Set Variable  ${tti_trace_path}
    ${bts_type}=  Get Node Deployment Type
    BuiltIn.Log  BTS Type Identified : ${bts_type}
    Stop Generation and collect TTI Trace  desired_storage_directory=${dir_tti_trace}  desired_file_name=${tti_trace_filename}
    [Return]  ${dir_tti_trace}/${tti_trace_filename}.pcap
        
Syve Determine NR Cell IDs
    [Documentation]     [PRIVATE]
    ...  :Author: Srihari Janardhan
    [Arguments]  ${nr_phy_cell_ids}
    ${extracted_phy_cell_ids}=  Run Keyword If  '${nr_phy_cell_ids}'=='${EMPTY}'  Syve Extract Cell Ids if not known
    ${nr_phy_cell_ids}=  Set Variable If  '${nr_phy_cell_ids}'=='${EMPTY}'  ${extracted_phy_cell_ids}  ${nr_phy_cell_ids}
    [Return]  ${nr_phy_cell_ids}

Syve Extract Cell Ids if not known
    [Documentation]     [PRIVATE]
    ...  :Author: Srihari Janardhan
    ${cell_dist_ids}=  Get gNB Physical Cell ID
    ${phy_cell_ids}=  Get Dictionary Values  ${cell_dist_ids}  sort_keys=True
    ${phy_cell_ids}=    Catenate    SEPARATOR=,    @{phy_cell_ids}
    [Return]  ${phy_cell_ids}
    
    
Syve Setup OAM http session
    [Documentation]    :Author: Uli Schoeffel
    ...    set OAM http session for gNB|eNB
    ...    
    ...    :param node_id:                  Id of gNB|eNB      [0.. ]       default=0
    ...    :param node_type:                either enb or gnb  [gnb|enb]    default=gnb
    ...    :param admin_api_log_path:       directory path to store admin api logs
    ...    
    [Arguments]     ${node_id}=${0}  ${node_type}=gnb  ${admin_api_log_path}=${OUTPUT DIR}/admin_logs
    ${node_type}    Convert to lower case           ${node_type}
    ${oam_alias}    Set variable    ${node_type}-${node_id}-OAM-http-session
    ${alias_exist}  Run Keyword And return Status   admin.get_sw_release_name   connection=${oam_alias}
    Return From KeyWord If  ${alias_exist}          ${oam_alias}
    ${nb_test_pc}   Get Test PC for NodeB   ${tl}   ${tl.${node_type}s[${node_id}]}
    BuiltIn.Log     ${\n}nb_test_pc_ip: ${nb_test_pc.default_ssh_connection_details.addr}   console=${P_admin_console}
    BuiltIn.Log     VM_ip: ${tl.test_pc.default_ssh_connection_details.addr}                console=${P_admin_console}
    ${remote_ip}    Run Keyword If  "${nb_test_pc.default_ssh_connection_details.addr}"=="${tl.test_pc.default_ssh_connection_details.addr}"
    ...             Set Variable    ${None}
    ...     ELSE    Set Variable    ${nb_test_pc.default_ssh_connection_details.addr}
    Create directory    ${admin_api_log_path}
    BuiltIn.Log     Setup admin connection with Node ${node_type}${node_id} via ${remote_ip}   console=${P_admin_console}
    Wait Until Keyword Succeeds    3min    30sec    admin.setup_admin
    ...     bts_host=${asik_addr}  name=${oam_alias}  remote_host=${remote_ip}  admin_api_log_dir=${admin_api_log_path}
    [Return]        ${oam_alias} 
    
Get release name
    [Documentation]    :Author: Srihari Janardhan  | This keyword returns the name of the gNB SW release
    ...     :param node_id:      Id of gnb                       [0.. ]  default=0
    ...     :return: SBTS22R3
    [Arguments]  ${node_id}=${0}
    ${oam_alias}=  Syve Setup OAM http session  node_id=${node_id}
    ${release}=  admin.get_sw_release_name  connection=${oam_alias}
    [Return]  ${release}
    
      

Convert TTI trace from pcap to excelCsv
    [Documentation]  Author : Valentin Hirzel
    ...  This keyword convertes TTi traces to CSV and requires the Library taf.converters.eventdecoder
    ...  :param input_file_path  -> Path to the input file (full Path with Filename) Example ${targed_Dir}/ttitraceStreaming.pcap
    ...  The creatd files will be saved at the Test Bese Directory. The name of the File is <folder Name>_{up/dl} for the uplink and downlink files.
    ...  Example: if the input is ttitrace_streaming.pcap, the Output Files will be in the same directory and called ttitrace_streaming_dl_and_ul.csv
    ...  and ttitrace_streming.pcap.up.csv

    [Arguments]  ${input_file_path}=${EMPTY}  ${output_file_path}=${EMPTY}  ${options}=-d combineDlAndUl
    ${path}	${file} =	Split Path	${input_file_path}
    Run  sudo rm /tmp/ttitrace_streaming.*
    Run  cp ${input_file_path} /tmp/ttitrace_streaming.old
    Run  sudo chown root:root /tmp/ttitrace_streaming.old
    Run  sudo tcpdump -r /tmp/ttitrace_streaming.old -w /tmp/ttitrace_streaming.pcap -C 200M
    Run  sudo chown ute:ute /tmp/ttitrace_streaming.old
    ${input_file_path}=  Run  ls -l /tmp/ttitrace_streaming.pcap* | tail -n 2| awk '{print $9}' |head -1 
    Log to console    input_file_path:${input_file_path}

    ${output_file_path}=  Determine Output File Path  input_file_path=${input_file_path}  output_file_path=${output_file_path}
    ${ttidecoder_path}    Download and TAR TTI Decorder Tool to TAF VM
    tce.Create eventDecoder Converter
    ...  name=converter
    ...  input_file_path=${input_file_path}
    ...  output_file_format=legacyCsv
    ...  output_file_path=${output_file_path}
    ...  excel_csv_options=${options}
    tce.Convert
    ...  name=converter
    
Stop Generation and collect TTI Trace
    [Documentation]     [PRIVATE]
    ...  :Author: Srihari Janardhan
    [Arguments]  ${desired_storage_directory}=${EMPTY}  ${desired_file_name}=ttitrace_streaming
    core.stop_collectors    names=l2stream3_${desired_file_name}
    core.collect_collectors    names=l2stream3_${desired_file_name}  target_dir=${desired_storage_directory}
    core.teardown_collectors    names=${desired_file_name},l2stream3_${desired_file_name}
    Move Trace File to Desired Directory  desired_storage_directory=${desired_storage_directory}  desired_file_name=${desired_file_name}
   
Move Trace File to Desired Directory
    [Documentation]     [PRIVATE]
    ...  :Author: Srihari Janardhan
    [Arguments]  ${desired_storage_directory}  ${desired_file_name}
    Move file  ${desired_storage_directory}/l2stream3_${desired_file_name}/${desired_file_name}/${desired_file_name}.pcap
    ...  ${desired_storage_directory}/${desired_file_name}.pcap
    Remove Directory  ${desired_storage_directory}/l2stream3_${desired_file_name}/  recursive=True  
    
Create TTI Trace Collector
    [Documentation]  Author : Srihari Janardhan
    ...  This keyword creates a TTI Trace collector
    ...  The keyword accpets the following parameters
    ...    :param gnb_id:             Id of gNB                               [0.. ]  default 0
    ...    :param du_id:              Id of DU                                [0..16] default 0
    ...    :param comu_id:            Id of Common Unit                       [0...1] default 0
    ...    :param tti_trace_filename: Name of the pcap file                   default: ttitrace_streaming
    ...    :param bts_type:           Bts type                                classical / cloud
    ...    :param dest_ip:            Destination IP where TTI Trace is captured      default x2c Network address on Test PC
    ...    :param nr_phy_cell_ids:    NR Physical cell ids                    50,51  
    [Arguments]  ${bts_type}  ${nr_phy_cell_ids}  ${dest_ip}  ${tti_trace_filename}=ttitrace_streaming
    ...  ${gnb_id}=${0}  ${du_id}=${0}  ${comu_id}=${0}
    ${tti_trace_collector}=  Set variable  l2stream3_${tti_trace_filename}
    ${tcpdump_collector}=   Identify TTI Trace Capture Location and Create Collector
    ...  bts_type=${bts_type}  gnb_id=${gnb_id}  tti_trace_filename=${tti_trace_filename}
    ${executor}=  Get OAM Webservice connection for Classical gNB  gnb_id=${gnb_id}
    ${l2_stream_config_1}=  Create Dictionary
    ...  nr_phy_cell_ids=${nr_phy_cell_ids}
    @{l2_stream_configuration}    Create List    ${l2_stream_config_1}
    ${source_ip_addr}=  Get source IP address  gnb_id=${gnb_id}  du_id=${du_id}  comu_id=${comu_id}
    l2stream3.create_sbts_l2stream_collector
    ...  name=${tti_trace_collector}
    ...  webservice=${executor}
    ...  source_ip_addr=${source_ip_addr}
    ...  destination_ip_addr=${dest_ip}
    ...  collector=${tcpdump_collector}
    ...  l2_stream_configuration=${l2_stream_configuration}
    core.setup_collectors    names=${tti_trace_collector}
    core.Set Suite Alias     ${tti_trace_collector}
    [Return]  ${tti_trace_collector}       
    

Identify TTI Trace Capture Location and Create Collector
    [Documentation]     [PRIVATE]
    ...  :Author: Srihari Janardhan
    [Arguments]  ${bts_type}  ${tti_trace_filename}=${EMPTY}  ${gnb_id}=0
    ${collector}=    Connect to test pc and create TCPDump Collector on backhaul interface
    ...  backhaul_ip=${backhaul_ip}  tti_trace_filename=${tti_trace_filename}
    [Return]    ${collector}

Connect to test pc and create TCPDump Collector on backhaul interface
    [Documentation]     [PRIVATE]
    ...  :Author: Srihari Janardhan
    [Arguments]  ${tti_trace_filename}  ${backhaul_ip}=192.168.4.1
    ${connection}=  connect.Connect to TestPC
    ${interface_name}=  Identify Interface with IP  ip=${backhaul_ip}  connection=${connection}
    BuiltIn.Log  \nIdentified interface for TCP Dump on Test PC is: ${interface_name}   console=${P_console}
    ${collector}=  Create TCP Dump Collector  interface_name=${interface_name}  tti_trace_filename=${tti_trace_filename}
    [Return]    ${collector}
    [Teardown]  ssh.disconnect  connection=${connection}


Create TCP Dump Collector
    [Documentation]    [PRIVATE]
    ...  :Author: Valentin Hirzel
    [Arguments]  ${interface_name}  ${tti_trace_filename}=ttitrace_streaming
    ${connection}=  connect.Connect to TestPC
    ${testpc_ssh_config}=  Create Dictionary
    ...     host=${tl.test_pc.default_ssh_connection_details.addr}
    ...     user=${tl.test_pc.default_ssh_connection_details.username}
    ...     password=${tl.test_pc.default_ssh_connection_details.password}
    tcpdump.create_tcpdump_collector
    ...     name=${tti_trace_filename}
    ...     options=-i ${interface_name} port 5678
    ...     executor=${testpc_ssh_config}
    tcpdump.set_suite_alias     ${tti_trace_filename}
    [RETURN]    ${tti_trace_filename}    
      
Get OAM Webservice connection for Classical gNB
    [Documentation]     [PRIVATE]
    ...  :Author: Srihari Janardhan
    [Arguments]  ${gnb_id}
    ${release}=  Get release name  node_id=${gnb_id}
    ${executor_classical}=  Create Dictionary
    ...  host=${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.addr}
    ...  user=${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.username}
    ...  password=${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.password}
    ...  port=443
    ...  release=${release}
    [Return]  ${executor_classical}
    
Get source IP address
    [Documentation]     [PRIVATE]
    ...  :Author: Valentin Hirzel
    [Arguments]    ${gnb_id}=${0}  ${du_id}=${0}  ${comu_id}=${0}
    ${asik_alias}=    connect.Connect to gNB Common Unit  gnb_id=${gnb_id}  du_id=${du_id}  comu_id=${comu_id}
    ${raw_ip}=  ssh.execute  ip -o -4 addr show | grep [b,f][p,r][0,1]  connection=${asik_alias}
    ${resultRegexp}=    Evaluate    re.search("inet (.*)/(\\d+)", '''${raw_ip}''', flags=re.M)   re
    ${result}=    Get Regexp Matches    ${raw_ip}    inet (.*)/(\\d+)   1   2
    set test variable   ${source_ip}   ${result[0][0]}
    log   ${resultRegexp.group(1)}
    Log    The source ip is: ${source_ip}
    [return]  ${source_ip}  
    
Get Node Deployment Type
    [Documentation]    :Author: Jing Liang
    ...    The keyword accepts the gnb number as an argument and returns
    ...    the type of the BTS (aic, classical)
    ...    *Note:* supports classical and AiC vran2.0
    ...
    ...    :param node_type: type of node, either gnb or enb (default=gnb)
    ...    :param node_id:   Id/Number of node               (default=0)
    ...    :return: type of BTS    (classical|aic)
    ...
    [Arguments]     ${node_id}=0  ${node_type}=gnb
    ${bts_type}     Set Variable If
    ...    '${tl.${node_type}s[${node_id}].__class__.__name__}'=='ClassicalBts'                                                         classical
    ...    '${tl.${node_type}s[${node_id}].__class__.__name__}'=='RealEnb'                                                              classical
    ...    '${tl.${node_type}s[${node_id}].__class__.__name__}' and '${tl.${node_type}s[${node_id}].dus[0].__class__.__name__}'=='VDU'  aic
    [Return]  ${bts_type}   
    
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

Download and TAR TTI Decorder Tool to TAF VM
    ${coam_version}    _Get_gnb_version
    @{version_split}    split string    ${coam_version}    _
    ${package_version}=  Set Variable If  "${version_split}[-3]"=="9999"   SBTS00   ${version_split}[-5]
    ${coam_version}=   Run Keyword If   "${version_split}[-3]"=="9999"
    ...   Replace String    ${coam_version}    ${version_split}[-5]    SBTS00
    ...   ELSE  Set Variable   ${coam_version}

    Create Directory    /home/ute/Downloads
    Set Suite Variable   ${ttidecoder_path}   /home/ute/Downloads/ttitrace-${package_version}
    Run    rm -rf /home/ute/Downloads/ttitrace-*
    ${package_download_dir}=   Set Variable
    ...   ${package_web_service}/${package_version}
    ${package_download_path}=   Set Variable   ${package_download_dir}/${coam_version}/${coam_version}_tti-dec_qemux86-64-static.txz
    Log    \n Start to Download Package From WFT!    INFO
    Run   rm -f wget-log*
    Run   wget -b ${package_download_path} -P /home/ute/Downloads
    Wait Until Keyword Succeeds   10m   1m   Wait Until wget process done
    ...  ${coam_version}_tti-dec_qemux86-64-static.txz
    OperatingSystem.File Should Exist   /home/ute/Downloads/${coam_version}_tti-dec_qemux86-64-static.txz
    Log To Console    Download Package Finished!
    Run   mkdir ${ttidecoder_path}
    Run   tar xJvf /home/ute/Downloads/${coam_version}_tti-dec_qemux86-64-static.txz -C ${ttidecoder_path}
    Run keyword and ignore error    Run    sudo mkdir -p ${tce_path}
    Run keyword and ignore error    Run    sudo rm -rf ${tce_path}/tti-dec-bin
    Run    sudo cp -r ${ttidecoder_path}/* ${tce_path}/
    [Return]   ${ttidecoder_path}

_Get_gnb_version
    [Arguments]   ${host}=${asik_addr}   ${username}=${asik_username}   ${password}=${asik_password}
    csn.Connect To   ${host}   ${username}   ${password}   alias=release_info
    ${version}   csn.Execute    cd /ffs/run;ls TargetBD*.xml  connection=release_info
    ${version}    Fetch From Right    ${version}    TargetBD_
    ${version}    Fetch From Left    ${version}    .
    [Return]    ${version}
    [Teardown]   csn.Disconnect   connection=release_info

Wait Until Wget Process Done
    [Arguments]   ${package_name}
    ${output}   Run   cat wget-log | grep -i "saved"
    Should Contain   ${output}   ${package_name}
