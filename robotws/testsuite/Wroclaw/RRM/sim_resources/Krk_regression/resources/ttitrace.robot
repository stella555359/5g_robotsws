*** Settings ***
Documentation     Keywords related to collection of TTI Traces on cloud Coam
...  author: Srihari Janardhan, 5G SW&SC Ulm Sqd66
...  cloud coam adaptations: Artur Ekert
...  contact: artur.ekert@nokia.com
...  Description: Resources to collect TTI Traces in Streaming mode
...  following variables need to be assigned:
...  ${gnb_id}  gnb number from which the TTI trace should be captured, id = 0 if only 1 gnb is configured
...             refer to the __init__.py configuration of the testline
...  ${du_id}   DU id if several DUs are connected to the gNB. If only 1 DU is configured du_id = 0.
...             refer to the __init__.py configuration of the testline
...  ${common_unit_id}   ASIK id if several ASIKs are connected to the DU. If only 1 ASIK is configured
...             By default all above values are configured as 0
...             refer to the __init__.py configuration of the testline

Resource   testline.robot
Resource   gnb.robot
Resource   connect.robot
Resource   tcpdump.robot
Resource   ../../../../resources/from_wroclaw/common/coam.robot


Library    ../python/ttitrace.py  WITH NAME  tti_streammode
Library    ../python/tti_analyzer_framework/tti_extractor_framework.py  WITH NAME  tti_trace_analyzer
Library    OperatingSystem
Library    String
Library    Collections
Library    taf.config.scf   WITH NAME  scf
Library    taf.collectors.tcpdump    WITH NAME    tcpdump
Library    taf.collectors.l2stream3    WITH NAME    l2stream3
Library    taf.collectors.core    WITH NAME    core

*** Variables ***
#Tagged for further improvement -> to capture the values from SCF
${fronthaul_ip_oam}  192.168.2.112
${P_console}        ${True}           # output to console can be enabled via "Set Console Output" from testline.robot
@{default_cell_dist_id}  /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-1/NRCELL_R-1

*** Keywords ***

Start TTI Traces in Streaming mode coam
    [Documentation]  :Author: Srihari Janardhan | This keyword detects the type of 5g bts and starts TTI traces.
    ...  PS: Works only for cloud TL
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
    [Arguments]
    ...  ${gnb_id}=${0}
    ...  ${du_id}=${0}
    ...  ${comu_id}=${0}
    ...  ${capu_id}=${0}
    ...  ${filter_bitmap1}=0xFFFFFFFF
    ...  ${filter_bitmap2}=0xFFFFFFFF
    ...  ${trace_ip}=${EMPTY}
    ...  ${cell_distid}=${EMPTY}
    ${cell_distid}=  Set Variable if  '${cell_distid}'=='${EMPTY}'  ${default_cell_dist_id}  ${cell_distid}
    Set SW Config On Common Module  rad_param=0x580115  rad_param_value=${filter_bitmap1}  gnb_id=${gnb_id}
    ...  du_id=${du_id}  comu_id=${comu_id}
    Set SW Config On Common Module  rad_param=0x580116  rad_param_value=${filter_bitmap2}  gnb_id=${gnb_id}
    ...  du_id=${du_id}  comu_id=${comu_id}
    ${bts_type}=  Get gNB type  gnb_id=${gnb_id}
    log to console  BTS Type Identified : ${bts_type}
    ${dest_ip}=  Identify Destination IP for tti trace capture coam  ${bts_type}  ${trace_ip}
    log to console  TTI Traces are forwarded to IP: ${dest_ip}
    ${collector_tti_trace_pcap}=   Identify TTI Trace Capture Location and start TCPDump coam
    ...  bts_type=${bts_type}  gnb_id=${gnb_id}  tti_trace_filename=ttitrace_streaming
    Start Generation of TTI Trace Using TAF Lib coam  gnb_id=${gnb_id}  du_id=${du_id}  comu_id=${comu_id}  capu_id=${capu_id}
    ...  dest_ip=${dest_ip}  collector=${collector_tti_trace_pcap}  cell_dist_id=${cell_distid}

Stop TTI Traces in Streaming mode coam
    [Documentation]  :Author: Srihari Janardhan | Stops TTI traces and stores the .pcap in the output directory by default
    ...  with the filename ttitrace_streaming.pcap. The output directory and file can be specified using the name parameters
    ...  tti_trace_path and tti_trace_filename respectively.
    ...  PS: Works only on cloud TL
    [Arguments]  ${tti_trace_path}=${EMPTY}  ${tti_trace_filename}=ttitrace_streaming
    ${dir_tti_trace}=  run keyword if  '${tti_trace_path}'=='${EMPTY}'  Get testcase log directory
    ...  ELSE  Set Variable  ${tti_trace_path}
    Stop Generation of TTI Trace Using TAF Lib coam  desired_storage_directory=${dir_tti_trace}  desired_file_name=${tti_trace_filename}
    [Return]  ${dir_tti_trace}/${tti_trace_filename}.pcap


Stop TTI Traces Decode and Download
    [Documentation]     [PRIVATE]
    ...  :Author: Artur Ekert
    [Arguments]  ${vmName}  ${local_dir}
    ...  ${eventDecoder_dir}=/home/robot/ttidec/tti-dec/bin
    ...  ${file_name}=tcpdump_gnb-0-cpif-fronthaul-tcpdump.pcap
    create directory   ${local_dir}
    core.stop_collectors    names=l2stream3
    core.collect_collectors    names=l2stream3  target_dir=${local_dir}
    log to console  TTI traces streaming stopped
    Decode TTI Trace On Vm Using tti-dec And Download
    ...  vmName=${vmName}
    ...  local_dir=${local_dir}
    ...  file_name=${file_name}
    ...  eventDecoder_dir=${eventDecoder_dir}
    core.teardown_collectors    names=l2stream3
    log to console  TTI traces downloaded

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
# Private keywords --> must not used outside of this file!
#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

Identify Destination IP for tti trace capture coam
    [Documentation]     [PRIVATE]
    ...  :Author: Srihari Janardhan
    [Arguments]  ${bts_type}  ${trace_ip}
    ${backhaul_ip}=  Set Variable if  '${bts_type}'=='classical' and '${trace_ip}'=='${EMPTY}'  ${tl.gnbs[${0}].cu.x2c.v4}  ${trace_ip}
    Set Test Variable  ${backhaul_ip}
    ${dest_ip}=  set variable if  '${bts_type}'=='classical'  ${backhaul_ip}  ${fronthaul_ip_oam}
    [Return]  ${dest_ip}


Identify TTI Trace Capture Location and start TCPDump coam
    [Documentation]     [PRIVATE]
    ...  :Author: Srihari Janardhan
    [Arguments]  ${bts_type}  ${tti_trace_filename}=${EMPTY}  ${gnb_id}=0
    ${collector}=   run keyword if  '${bts_type}'=="classical"  Connect to test pc and start TCPDump on backhaul interface coam
    ...  backhaul_ip=${backhaul_ip}  tcpdump_name=${tti_trace_filename}
    ...  ELSE  Connect to CPIF and Start TCP Dump on fronthaul coam  gnb_id=${gnb_id}  tti_trace_filename=${tti_trace_filename}
    [Return]    ${collector}

Connect to test pc and start TCPDump on backhaul interface coam
    [Documentation]     [PRIVATE]
    ...  :Author: Srihari Janardhan
    [Arguments]  ${backhaul_ip}=192.168.4.1  ${tcpdump_name}=${EMPTY}
    ${connection}=  connect.Connect to TestPC
    ${interface_name}=  Identify Interface with IP  ip=${backhaul_ip}  connection=${connection}
    BuiltIn.Log  Identifed interface on for TCP Dump on Test PC is : ${interface_name}   console=${P_console}
    ${collector}=    tcpdump.Start Tcpdump on TestPc     interface=${interface_name}  option=port 5678
    ...  collector=${tcpdump_name}
    [Return]    ${collector}
    [Teardown]  ssh.disconnect  connection=${connection}


Connect to CPIF and Start TCP Dump on fronthaul coam
    [Documentation]     [PRIVATE]
    ...  :Author: Srihari Janardhan
    [Arguments]  ${gnb_id}=0  ${tti_trace_filename}=${EMPTY}
    ${collector}=   tcpdump.Start TCPdump on gNB VM    vm_name=cpif    gnb_id=${gnb_id}    interface=fronthaul    option=port 5678
    ...  collector=${tti_trace_filename}
    [Return]    ${collector}


Start Generation of TTI Trace Using TAF Lib coam
    [Documentation]     [PRIVATE]
    ...  :Author: Srihari Janardhan
    [Arguments]  ${dest_ip}  ${collector}  ${cell_dist_id}  ${gnb_id}=${0}  ${du_id}=${0}  ${comu_id}=${0}  ${capu_id}=${0}
    ${_collector_name}=  Set variable  l2stream3
    ${executor}=  Create Dictionary
    ...  host=${tl.gnbs[${gnb_id}].dus[${du_id}].airscale.common_units[${comu_id}].lmp_connection.addr}
    ...  user=${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.username}
    ...  password=${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.password}
    ...  port=443
    ${l2_stream_config_1}=  Create Dictionary
    ...  nr_cell_dns=${cell_dist_id}
    @{l2_stream_configuration}    Create List    ${l2_stream_config_1}
    l2stream3.create_sbts_l2stream_collector
    ...  name=${_collector_name}
    ...  webservice=${executor}
    ...  vlan=1
    ...  source_ip_addr=${tl.gnbs[${gnb_id}].dus[${du_id}].airscale.common_units[${comu_id}].capacity_units[${capu_id}].addr}
    ...  destination_ip_addr=${dest_ip}
    ...  collector=${collector}
    ...  l2_stream_configuration=${l2_stream_configuration}
    core.setup_collectors    names=${_collector_name}
    core.start_collectors    names=${_collector_name}
    core.Set Suite Alias     ${_collector_name}
    log to console  TTI streaming started


Stop Generation of TTI Trace Using TAF Lib coam
    [Documentation]     [PRIVATE]
    ...  :Author: Srihari Janardhan
    [Arguments]  ${desired_storage_directory}=${EMPTY}  ${desired_file_name}=ttitrace_streaming
    Log    desired_file_name=${desired_file_name} not used in this method.
    core.stop_collectors    names=l2stream3
    core.collect_collectors    names=l2stream3  target_dir=${desired_storage_directory}
    core.teardown_collectors    names=l2stream3

Decode TTI Trace On Vm Using tti-dec And Download
    [Documentation]  [PRIVATE]
    ...  :Author: Artur Ekert
    [Arguments]  ${vmName}  ${file_name}  ${local_dir}  ${eventDecoder_dir}=/home/robot/ttidec/tti-dec/bin
    ...  ${pcap_dir}=/tmp  ${gnb_id}=${0}
    connect.Connect to gNB VM    vm_name=${vmName}    gnb_id=${gnb_id}    alias=${vmName}
    ssh.send_command
    ...  sudo mkdir /home/robot/ttidecoded; sudo chown -R robot:root /home/robot/ttidecoded
    ...  connection=${vmName}
    ssh.await execution end   connection=${vmName}  timeout=5min
    log to console  decoding TTI traces
    ssh.send_command  sudo ${eventDecoder_dir}/eventDecoder ${pcap_dir}/${file_name} /home/robot/ttidecoded/${file_name}
    ...  connection=${vmName}
    ssh.await execution end   connection=${vmName}  timeout=5min
    ssh.send_command
    ...  sudo tar zcvf /home/robot/ttidecoded.tgz /home/robot/ttidecoded/*; sudo chown -R robot:root /home/robot/
    ...  connection=${vmName}
    ssh.await execution end   connection=${vmName}   timeout=5min
    ssh.download file    remote_path=/home/robot/ttidecoded.tgz
    ...    local_path=${local_dir}/ttidecoded.tgz
    ...    connection=${vmName}
    ssh.disconnect   connection=${vmName}
    Connect to TestPC  alias=vm
    ssh.send_command
    ...  tar xf ${local_dir}/ttidecoded.tgz --directory ${local_dir}/
    ...  connection=vm
    ssh.await execution end   connection=vm   timeout=5min
    ssh.disconnect   connection=vm


Get gNB Sw version and split
    [Documentation]  [PRIVATE]
    ...  :Author: Artur Ekert
    [Arguments]   ${alias}=DU_OAM
    ${sw}=    admin.get_sw_version    connection=${alias}
    ${sw}=    testline.reform_coam_sw_version       ${sw}
    @{sw_ver}=  Split String From Right  ${sw}  _   1
    [Return]  @{sw_ver}[1]

Download luashark from artifactory
    [Documentation]  [PRIVATE]
    ...  :Author: Artur Ekert
    [Arguments]  ${alias}=DU_OAM    ${dir}=${OUTPUT_DIR}
    ${sw}=  Get gNB Sw version and split    alias=${alias}
    Connect to TestPC  alias=vm_tmp
    ssh.Execute     command=sudo rm -Rf ${dir}/*luashark*  connection=vm_tmp
    ssh.send_command
    ...  wget -P ${dir} https://artifactory-espoo1.ext.net.nokia.com/artifactory/mnp5g-central-public-local/System_Release/${sw}/luashark-${sw}.zip
    ...  connection=vm_tmp
    ssh.await execution end  connection=vm_tmp  timeout=5min
    ssh.send_command
    ...  unzip ${dir}/luashark-${sw}.zip -d ${dir}
    ...  connection=vm_tmp
    ssh.await execution end  connection=vm_tmp  timeout=5min
    ssh.disconnect  vm_tmp
    [Return]  luashark-${sw}.zip

Download ttidec from artifactory
    [Documentation]  [PRIVATE]
    ...  :Author: Artur Ekert
    [Arguments]  ${alias}=DU_OAM    ${dir}=${OUTPUT_DIR}
    ${sw}=  Get gNB Sw version and split    alias=${alias}
    Connect to TestPC  alias=vm_tmp
    ssh.Execute       command=sudo rm -Rf ${dir}/tti*  connection=vm_tmp
    ssh.send_command
    ...  wget -P ${dir} https://artifactory-espoo1.ext.net.nokia.com/artifactory/mnp5g-central-public-local/System_Release/${sw}/ttitrace-${sw}.txz
    ...  connection=vm_tmp
    ssh.await execution end  connection=vm_tmp  timeout=5min
    ssh.disconnect  vm_tmp
    [Return]  ttitrace-${sw}.txz

Upload ttidec To cpif
    [Documentation]   Uploads a tool to tti
    ...  :Author: Artur Ekert
    [Arguments]     ${vmName}  ${file_name}  ${target_dir}  ${local_dir}=${OUTPUT_DIR}  ${gnb_id}=${0}
    ...  ${eventDecoder_path}=/ttidec/tti-dec/bin/eventDeccoder
    connect.Connect to gNB VM    vm_name=${vmName}    gnb_id=${gnb_id}    alias=${vmName}
    ssh.send_command
    ...  sudo rm -Rf ${target_dir}/tti*; sudo mkdir ${target_dir}/ttidec; sudo chown robot:root ${target_dir}
    ...  connection=${vmName}
    ssh.Upload File   local_path=${local_dir}/${file_name}
    ...               remote_path=${target_dir}/${file_name}
    ...               connection=${vmName}
    ssh.Execute       command=sudo tar xf ${target_dir}/${file_name} --directory ${target_dir}/ttidec
    ...               connection=${vmName}
    ssh.Execute       command=sudo chmod +x ${target_dir}${eventDecoder_path}  connection=${vmName}
    ssh.Execute       command=sudo chown -R robot:root ${target_dir}/*  connection=${vmName}

Tools Download And Upload To Cpif
    [Documentation]  [PRIVATE]
    ...  :Author: Artur Ekert
    [Arguments]  ${target_dir}=/home/robot   ${alias}=DU_OAM   ${local_dir}=${OUTPUT_DIR}
    ...  ${eventDecoder_path}=/ttidec/tti-dec/bin/eventDeccoder
    ${tti_file}=  Download ttidec from artifactory  ${alias}    ${local_dir}
    #Download luashark from artifactory  ${alias}    ${local_dir}
    WAIT UNTIL KEYWORD SUCCEEDS   5min  10s   Upload ttidec To cpif  vmName=cpif   target_dir=${target_dir}
    ...     file_name=${tti_file}   local_dir=${local_dir}   eventDecoder_path=${eventDecoder_path}
