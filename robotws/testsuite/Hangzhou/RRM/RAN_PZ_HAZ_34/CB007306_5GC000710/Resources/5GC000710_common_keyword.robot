*** Settings ***
Documentation
...              author: miao.1.lu@nokia-sbell.com


Library             DateTime
Library          taf.sbts.oam.coam.admin       WITH NAME    coam
Library          ./5GC000710_common_keyword.py
Resource         testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource         testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/traffic_via_iperf.robot
Library          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG4/Analysis_Viavi_Log.py
Library          Analysis_Viavi_Log.Viavi_Log_analysis     WITH NAME    Viavi_Log_analysis
Library          taf.transport.ssh                 WITH NAME       ssh
Library          ute_syslog


*** Variables ***
${epc_log_path}              /tmp
${filter_001}                x2ap.procedureCode == 27 && x2ap.X2AP_PDU == 1
${filter_002}                x2ap.procedureCode == 27 && x2ap.X2AP_PDU == 0
${filter_005}                x2ap.procedureCode == 27 && x2ap.X2AP_PDU == 1 && nr-rrc.physCellId == 50
${filter_meas1}              nr-rrc.rsrp == 75 && x2ap.procedureCode == 35 && x2ap.X2AP_PDU == 0
${filter_meas3}              nr-rrc.rsrp == 54 && x2ap.procedureCode == 35 && x2ap.X2AP_PDU == 0
${filter_A3}                 x2ap.procedureCode == 30 && x2ap.X2AP_PDU == 0
${filter_A3_ack}             x2ap.procedureCode == 30 && x2ap.X2AP_PDU == 1
${filter_gapoffset}          x2ap.procedureCode == 30 && x2ap.X2AP_PDU == 0 && nr-rrc.gapOffset == 0
${filter_ssb02}              x2ap.procedureCode == 30 && x2ap.X2AP_PDU == 0 && nr-rrc.physCellId == 51
${filter_meas5}              x2ap.procedureCode == 30 && x2ap.X2AP_PDU == 0 && nr-rrc.measId == 5
${filter_SRBID}              f1ap.F1AP_PDU == 0 && f1ap.procedureCode == 13 && nr-rrc.measId == 1
${filter_A3report}           f1ap.F1AP_PDU == 0 && f1ap.procedureCode == 12 && nr-rrc.rrc_TransactionIdentifier == 2
${filter_F1gapOffset}        f1ap.F1AP_PDU == 0 && f1ap.procedureCode == 12
${filter_F1A3}               f1ap.F1AP_PDU == 0 && f1ap.procedureCode == 7
${luashark_path}             /opt/ute/luashark/luashark_script/generated_luashark
${throughput}                100M
${TMA_APP_ALIAS}             e500
${Test_Case_Name}            5GC000710_BTSLOG
${ul_time}                   1800
${eventA1}                   eventA1
${eventA2}                   eventA2
${eventA3}                   eventA3
${SSB01}                     2073115
${SSB02}                     2073691
${SSB03}                     2074267
${gapFR2}                    gapFR2: release (0)
${rsrp}                      rsrp
${NUM}                       1
${port1}                     51000
${port2}                     51001


*** Keywords ***

Common setup for 710
    [Arguments]
     ${versiontitle}    Get Version
    Run keyword if    '${versiontitle}'=='SBTS22R1' or '${versiontitle}'=='SBTS22R2'
     ...    Setup gNB and eNB SCF      CURDIR_path1=${CURDIR_path1}     CURDIR_path2=${CURDIR_path2}
     ...   ELSE     Setup gNB and eNB SCF    CURDIR_path1=${CURDIR_path1_trunk}     CURDIR_path2=${CURDIR_path2_trunk}
    Check BTS Should Be Normal    index=${0}
    Check BTS Should Be Normal    index=${1}

Setup gNB and eNB SCF
    [Arguments]     ${CURDIR_path1}    ${CURDIR_path2}
    Setup Commission 701SCF    CURDIR_path=${CURDIR_path1}
    Setup Commission 701SCF    CURDIR_path=${CURDIR_path2}    bts_host=${tl.gnbs[1].dus[0].f1_m_ip_addr}

Get Version
    [Arguments]   ${connection}=GNB_OAM
    Log To Console    Get Version
    Connect to gnb coam via ssl    bts_host=${gNB_ip}    username=${DU_OAM_WEBUI_USER}
    ...    password=${DU_OAM_WEBUI_PASSWORD}    connection=${connection}
    ${version}    coam.get_sw_version    connection=${connection}
    ${version_list}    split string    ${version}    _
    ${versiontitle}    set variable    ${version_list[0]}
    [Return]    ${versiontitle}
    [Teardown]    coam.Teardown  connection=${connection}

Check BTS Should Be Normal
    Log To Console  Check BTS Should Be Normal
    [Arguments]    ${index}=${0}    ${enb}=${False}
    ${connection}    Rest Login DU    index=${index}    enb=${enb}
    Wait Until BTS Should Be Normal    connection=${connection}
    [Teardown]   Run Keyword And Ignore Error   Rest Logout DU    alias=${connection}

Rest Login DU
    [Arguments]    ${index}=${0}        ${alias}=default    ${enb}=${False}
    [Documentation]   Rest Login DU
    ${btsip}=    Set Variable If    ${enb}==${False}
    ...  ${tl.gnbs[${index}].dus[0].f1_m_ip_addr}    ${tl.enbs[${index}].airscale.common_units[0].lmp_connection.addr}
    Run Keyword And Ignore Error    Rest Logout DU   alias=${alias}
    Connect to gnb coam via ssl  bts_host=${btsip}
    ...                              username=${tl.gnbs[0].cu.oam_http_connection_details.username}
    ...                              password=${tl.gnbs[0].cu.oam_http_connection_details.password}
    ...                              connection=${alias}
    ${connection}    set variable    ${alias}
    [Return]  ${connection}

Wait Until BTS Should Be Normal
    [Arguments]   ${retry}=800s    ${retry_interval}=10s    ${connection}=default
    [Documentation]   Wait Until CBTS Status Should Be Normal, if CBTS status is abnormal during retry time,
    Wait Until Keyword Succeeds   ${retry}     ${retry_interval}    Gnb Cell Should Be Onair    alias=${connection}

Gnb Cell Should Be Onair
    [Arguments]    ${alias}=default    ${cell_type}=nr
    [Documentation]    Gnb Cell Should Be Onair, check method is via REST
    log to console    waiting for BTS onair
    ${status}      coam.get_bts_statuses   connection=${alias}
    ${bts_status}   Get From Dictionary    ${status}   proceduralState
    Should Be Equal as strings    ${bts_status}    OnAir

Online update paramters
    Log To Console  online check paramter
    [Arguments]    ${parameters}    ${index}=${0}    ${enb}=${False}
    ${connection}    Rest Login DU    index=${index}    enb=${enb}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${parameters}    connection=${connection}
    Wait Until BTS Should Be Normal    connection=${connection}
    [Teardown]   Run Keyword And Ignore Error   Rest Logout DU    alias=${connection}

Catch tcpdump log and attch UE
    [Arguments]  ${filename}=enb_tcpdump     ${E500_SCRIPTS_BASE}=${E500_SCRIPTS_BASE}
    Start wireshark capture from gNB or Enb      filename=${filename}    alias=enb2
    log to console    start attach...
    Cobham retry ue attach if failed    e500_script_path=${E500_SCRIPTS_BASE}     rrc_count=${2}
    log to console    ue attach successful,sleep:2s
    sleep    2s
    ${log_wireshark_path1}      Stop wireshark capture from gNB or Enb        filename=${filename}   alias=enb2
    [Teardown]    run keyword and ignore error       Case Teardown

Start tcpdump log attch UE and send UL and DL traffic
    [Arguments]   ${E500_SCRIPTS_BASE}=${E500_SCRIPTS_BASE}
    Start wireshark capture from gNB or Enb      filename=${pacp_filename}_1    alias=enb1
    log to console    start attach...
    Cobham retry ue attach if failed    e500_script_path=${E500_SCRIPTS_BASE}     rrc_count=${2}
    log to console    ue attach successful,sleep:2s
    sleep    2s
    ${log_wireshark_path1}      Stop wireshark capture from gNB or Enb        filename=${pacp_filename}_1   alias=enb1
    ${logs_path}    Start logging on cobham and Return Folder
    Start wireshark capture from gNB or Enb     filename=${pacp_filename}_2    alias=enb2
    Iperf send UL traffic VIAVI    throughput=${70}    traffic_time=${600}
    Iperf send DL traffic with real epc    throughput=${100}    traffic_time=${600}    port=${dl_port}
    sleep     5s
    run keyword and continue on failure     A2 measurement trigger
    sleep     10s
    run keyword and continue on failure     A3 measurement trigger
    sleep     10s
    Stop wireshark capture from gNB or Enb     filename=${pacp_filename}_2     alias=enb2
    Stop logging on cobham
    sleep    2min
    ${ute_path}    Download Viavi Log    logs_path=${logs_path}
    Check_TP_And_Bler    dir_path=${ute_path}    ul_min_tp=${10}    ul_max_tp=${50}   dl_min_tp=${10}    dl_max_tp=${90}
    ...    bler_value=${0.01}    row=${10}
    [Teardown]    run keyword and ignore error       Case Teardown

Start tcpdump log attch UE and send UL and DL traffic 008
    [Arguments]   ${E500_SCRIPTS_BASE}=${E500_SCRIPTS_BASE}
    Start wireshark capture from gNB or Enb      filename=${pacp_filename}_1     alias=enb1
    log to console    start attach...
    Cobham retry ue attach if failed    e500_script_path=${E500_SCRIPTS_BASE}     rrc_count=${2}
    log to console    ue attach successful,sleep:5s
    sleep    5s
    ${log_wireshark_path1}      Stop wireshark capture from gNB or Enb        filename=${pacp_filename}_1    alias=enb1
    Start wireshark capture from gNB or Enb     filename=${pacp_filename}_2     alias=enb2
    sleep     5s
    run keyword and continue on failure     A2 measurement trigger
    sleep     5s
    run keyword and continue on failure     A1 measurement trigger without rsrq
    sleep     5s
    run keyword and continue on failure     A1 measurement trigger with rsrq
    sleep     5s
    Stop wireshark capture from gNB or Enb     filename=${pacp_filename}_2     alias=enb2
    [Teardown]     Cobham UE detach

Start tcpdump log attch UE and send UL and DL traffic 011
    [Arguments]   ${E500_SCRIPTS_BASE}=${E500_SCRIPTS_BASE}
    Start wireshark capture from gNB or Enb      filename=${pacp_filename}_1   alias=enb1
    log to console    start attach...
    Cobham retry ue attach if failed    e500_script_path=${E500_SCRIPTS_BASE}     rrc_count=${2}
    log to console    ue attach successful,sleep:5s
    sleep    5s
    ${log_wireshark_path1}      Stop wireshark capture from gNB or Enb        filename=${pacp_filename}_1   alias=enb1
    Start wireshark capture from gNB or Enb     filename=${pacp_filename}_2    alias=enb2
    sleep     5s
    ${NRMOPRMA_NSA}     ${NRMOPR_NSA}    Delete NRMOPRMA_NSA-2 AND NRMOPR_NSA-2
    run keyword and continue on failure     A2 measurement trigger
    sleep     10s
    Stop wireshark capture from gNB or Enb     filename=${pacp_filename}_2     alias=enb2
    [Return]     ${NRMOPRMA_NSA}     ${NRMOPR_NSA}
    [Teardown]     Cobham UE detach

Start tcpdump log attch UE and send UL and DL traffic 009
    [Arguments]   ${E500_SCRIPTS_BASE}=${E500_SCRIPTS_BASE}
    Start wireshark capture from gNB or Enb      filename=${pacp_filename}_1    alias=enb1
    log to console    start attach...
    Cobham retry ue attach if failed    e500_script_path=${E500_SCRIPTS_BASE}     rrc_count=${1}
    log to console    ue attach successful,sleep:2s
    sleep    2s
    ${log_wireshark_path1}      Stop wireshark capture from gNB or Enb        filename=${pacp_filename}_1   alias=enb1
    ${logs_path}    Start logging on cobham and Return Folder
    start 009 tcpdump log
    start 009 tcpdump log    ip_address=${gNB2_ip}    pcap=gnb_tcpdump_2.pcap    alias=cOAM2_toor4nsn
    Iperf send UL traffic VIAVI    throughput=${70}    traffic_time=${600}
    Iperf send DL traffic with real epc    throughput=${100}    traffic_time=${600}    port=${dl_port}
    sleep     5s
    run keyword and continue on failure     A2_009 measurement trigger
    sleep     5s
    run keyword and continue on failure     A3 measurement trigger without rsrq
    sleep     5s
    run keyword and continue on failure     A3 measurement trigger with rsrq
    sleep     5s
    Stop 009 trace capturing
    Stop 009 trace capturing    ip_address=${gNB2_ip}   log_prefix=gnb_tcpdump_2.pcap    alias=cOAM2_toor4nsn
    Stop logging on cobham
    sleep    2min
    ${ute_path}    Download Viavi Log    logs_path=${logs_path}
    Check_TP_And_Bler    dir_path=${ute_path}    ul_min_tp=${10}    ul_max_tp=${50}   dl_min_tp=${10}    dl_max_tp=${90}
    ...    bler_value=${0.01}    row=${10}
    [Teardown]    run keyword and ignore error       Case Teardown

start 009 tcpdump log
    [Arguments]   ${pcap}=gnb_tcpdump_1.pcap    ${interface}=any
    ...    ${ip_address}=${gNB_ip}  ${alias}=cOAM_toor4nsn
    ${connection}    ssh connect to DU    ip_address=${ip_address}  alias=${alias}
    ssh.send command    command=ps -ef |grep tcpdump |grep -v grep |grep ${interface} |awk '{print $2}' |xargs kill -2    connection=${alias}
    sleep    2s
    ssh.send command                    command=cd /ram && ls -l | grep CPRT | cut -d "_" -f 2|cut -d " " -f 1|head -1
    ...                                 connection=${connection}
    ${readOutput}=         ssh.readOutput    connection=${connection}
    ssh.send command
    ...    command=cd /ram && lxc-attach -n ${readOutput.split("\n")[0]} && nohup tcpdump -i any -w ${pcap} &>/dev/null &
    ...                                 connection=${connection}
    [Teardown]  ssh.disconnect          connection=${connection}

Stop 009 trace capturing
    [Arguments]        ${log_prefix}=gnb_tcpdump_1.pcap    ${alias}=ASIK Slave    ${retry_time}=10
    ...    ${ip_address}=${gNB_ip}
    ${connection_alias}    ssh connect to DU    ip_address=${ip_address}  alias=${alias}
    FOR    ${i}    IN RANGE    ${retry_time}
        ssh.execute    ps -ef | grep tcpdump | grep -v grep | grep ${log_prefix} | awk '{print $2}' | xargs kill -2
        ...    connection=${connection_alias}
        ${is_trace_capture_stopped}    run keyword and return status    wait until keyword succeeds    5s    200ms
        ...    Trace capturing process should be stopped    log_prefix=${log_prefix}    connection_alias=${connection_alias}
        exit for loop if    ${is_trace_capture_stopped}==${True}
    END
    should be true    ${is_trace_capture_stopped}
    ssh.download_file                   remote_path=/ram/${log_prefix}
    ...                                 local_path=${LOG_PATH}/${log_prefix}
    ...                                 connection=${connection_alias}
    [Teardown]  ssh.disconnect          connection=${connection_alias}

ssh connect to DU
    [Arguments]  ${ip_address}=${tl.gnbs[0].dus[0].f1_m_ip_addr}  ${alias}=cOAM_toor4nsn
    ...    ${ROOT_USERNAME}=toor4nsn    ${ROOT_PASSWORD}=oZPS0POrRieRtu
    ${connection}=  ssh.Connect to  ${ip_address}
    ...                             ${ROOT_USERNAME}
    ...                             ${ROOT_PASSWORD}
    ...                             alias=${alias}
    [Return]  ${connection}

Start wireshark capture from gNB or Enb
    [Documentation]    Description: Start X2 log capture on gNB or Enb
    [Arguments]     ${filename}=enb_tcpdump   ${interface}=any    ${index}=${0}    ${alias}=ASIK Master    ${gnb}=${False}
    run keyword if    '${gnb}'=='True'    Connect to Common Unit Master    du_index=${index}    alias=${alias}
    run keyword if    '${gnb}'!='True'    Connect to ENB with ssh     alias=${alias}
    ${log_name}    Set variable    ${filename}.pcap
    ${log_full_path_gnb}    join path    /tmp    ${log_name}
    csn.send command    command=ps -ef |grep tcpdump |grep -v grep |grep ${interface} |awk '{print $2}' |xargs kill -2    connection=${alias}
    sleep    2s
    csn.send command    command=nohup tcpdump -i ${interface} -s 0 -w ${log_full_path_gnb}     connection=${alias}
    sleep    2s
    Trace capturing process should be triggered    log_prefix=${log_name}    connection_alias=${alias}
    [Return]    ${alias}
    [Teardown]    run keyword and ignore error    csn.Disconnect    connection=${alias}

Iperf send UL traffic VIAVI
    [Documentation]    Author: zhu xiaofeng
    ...                Description: ul_host_ip will default to 192.168.10.70
    ...                port=5410 is related with it used on cobham. Now dedicated to this value
    [Arguments]    ${throughput}=100    ${traffic_time}=${240}    ${ul_host_ip}=10.57.178.18
    ...    ${port}=${tl.ues[0].iperf_details.ssh_connection_details.port}
    Log to console    Start UL traffic with real epc
    wait until keyword succeeds    2 min    10 s    traffic_via_iperf.Connect to cobham control pc via ssh
    enable PPPoE connection    TMA_SSH_ALIAS=${TMA_SSH_ALIAS}
    ${cmd_start_iperf_client}    Catenate    iperf -u -c ${ul_host_ip} -b ${throughput}M -t ${traffic_time} -i 1 -p ${port}
    csn.send command     command=${cmd_start_iperf_client}    connection=${TMA_SSH_ALIAS}
    sleep    5s
    Log to console    Start to send UL traffic with real epc on UE side, traffic time is ${traffic_time}
    [Teardown]  Run keyword and ignore error    Run keywords    traffic_via_iperf.Disconnect from app server    AND
    ...    traffic_via_iperf.Disconnect from cobham control pc via ssh

enable PPPoE connection
    [Documentation]    activates the PPPoE tunnel with E500 thanks to ssh opened connection.
    ...                PPPoE tunnel is required to be able to launch DL iperf in reception on the Viavi PC
    ...                the PPPoE configured name under the PC shall be TM500
    ...                the alias of the ssh connection used is ViaviSshConnection from above Viavi PC connect keyword
    ...                PPPoE set up action in script must be performed in background as the UE attach under TMA should
    ...                be launch in // of the PPPoE set up
    [Arguments]    ${TMA_SSH_ALIAS}
    ssh.send command   rasdial TM500    connection=${TMA_SSH_ALIAS}
    ${output}    ssh.read output    connection=${TMA_SSH_ALIAS}
    Log to console    ${output}
    should contain    ${output}    Command completed successfully

Stop wireshark capture from gNB or Enb
    [Documentation]    Description: Stop X2 log capture on gNB or Enb, and download x2 log to testpc
    [Arguments]     ${filename}=enbX2    ${log_path}=${OUTPUT_DIR}    ${index}=${0}    ${alias}=ASIK Master    ${gnb}=${False}
    run keyword if    '${gnb}'=='True'    Connect to Common Unit Master    du_index=${index}    alias=${alias}
    run keyword if    '${gnb}'!='True'    Connect to ENB with ssh       alias=${alias}
    Stop trace capturing    log_prefix=${filename}    connection_alias=${alias}
    ${log_full_path_ute}    set variable     ${log_path}/${filename}.pcap
    csn.download_file   remote_path=/tmp/${filename}.pcap   local_path=${log_full_path_ute}   connection=${alias}
    csn.execute    command=rm /tmp/${filename}.pcap    connection=${alias}
    [Return]    ${log_full_path_ute}
    [Teardown]    run keyword and ignore error    csn.Disconnect    connection=${alias}

Setup Commission 701SCF
    [Arguments]    ${CURDIR_path}     ${bts_host}=${tl.gnbs[0].dus[0].f1_m_ip_addr}
    ...    ${username}=${tl.gnbs[0].cu.oam_http_connection_details.username}
    ...    ${password}=${tl.gnbs[0].cu.oam_http_connection_details.password}
    coam.connect_to    bts_host=${bts_host}    bts_port=${443}    username=${username}    password=${password}
    ...   name=${connection}
    log to console    connect successful
    COAM Commission with scf file     scf_file_path=${CURDIR_path}
    log to console    active DU scf successful
    Run Keyword And Ignore Error    coam.teardown
    [Teardown]    Run Keyword And Ignore Error    coam.teardown    connection=${connection}

match pattern in response
    [Arguments]    ${pattern}    ${response}    ${e500_alias}=${TMA_APP_ALIAS}
    ${response_extra}    tm500_remote.read_responses    alias=${e500_alias}
    ${response}    Catenate    ${response}    ${response_extra}
    Should contain    ${response}    ${pattern}    msg=String "${pattern}" is not found

A1 measurement trigger without rsrq
     [Arguments]    ${a1_meas_id}=2    ${report_interval}=0    ${serving_cell_pci}=50    ${serving_cell_rsrp}=107
    ...    ${serving_cell_rsrq}=53    ${serving_cell_sinr}=35    ${neigh_cell_pci}=51    ${neigh_cell_rsrp}=66    ${neigh_cell_rsrq}=57
    ...    ${neigh_cell_sinr}=44    ${tm500_alias}=e500
    log to console  Start to trigger A1 without rsrq measurement report
    ${cmd_a3_mr}    catenate
    ...    forw mte NrRrcAptTriggerMeasReport ${a1_meas_id} 0 0 ${report_interval} 1
    ...    {8 [${serving_cell_pci}] [[${serving_cell_rsrp}] [${serving_cell_rsrq}] [${serving_cell_sinr}]] [] [[1{0[[107] [53] []]}] []] [] []}
    ...    [0(1{[${neigh_cell_pci}] [[${neigh_cell_rsrp}] [${neigh_cell_rsrq}] [${neigh_cell_sinr}]] [][ [1{0[[66] [] []]}] [] ] })]
    ${response}    tm500_remote.send_command    command=${cmd_a3_mr}    alias=${tm500_alias}
    ${response1}    tm500_remote.send_command    command=forw mte Activate -1    alias=${tm500_alias}
    sleep    5s

A1 measurement trigger with rsrq
     [Arguments]    ${a1_meas_id}=2    ${report_interval}=0    ${serving_cell_pci}=50    ${serving_cell_rsrp}=107
    ...    ${serving_cell_rsrq}=107    ${serving_cell_sinr}=35    ${neigh_cell_pci}=51    ${neigh_cell_rsrp}=66    ${neigh_cell_rsrq}=57
    ...    ${neigh_cell_sinr}=44    ${tm500_alias}=e500
    log to console  Start to trigger A1 with rsrq measurement report
    ${cmd_a3_mr}    catenate
    ...    forw mte NrRrcAptTriggerMeasReport ${a1_meas_id} 0 0 ${report_interval} 1
    ...    {8 [${serving_cell_pci}] [[${serving_cell_rsrp}] [${serving_cell_rsrq}] [${serving_cell_sinr}]] [] [[1{0[[107] [71] []]}] []] [] []}
    ...    [0(1{[${neigh_cell_pci}] [[${neigh_cell_rsrp}] [${neigh_cell_rsrq}] [${neigh_cell_sinr}]] [][ [1{0[[66] [] []]}] [] ] })]
    ${response}    tm500_remote.send_command    command=${cmd_a3_mr}    alias=${tm500_alias}
    ${response1}    tm500_remote.send_command    command=forw mte Activate -1    alias=${tm500_alias}
    sleep    5s

A3 measurement trigger without rsrq
     [Arguments]    ${a1_meas_id}=3    ${report_interval}=4    ${serving_cell_pci}=50    ${serving_cell_rsrp}=50
    ...    ${serving_cell_rsrq}=53    ${serving_cell_sinr}=35    ${neigh_cell_pci}=52    ${neigh_cell_rsrp}=71    ${neigh_cell_rsrq}=57
    ...    ${neigh_cell_sinr}=44    ${tm500_alias}=e500
    log to console  Start to trigger A1 without rsrq measurement report
    ${cmd_a3_mr}    catenate
    ...    forw mte NrRrcAptTriggerMeasReport ${a1_meas_id} 0 0 ${report_interval} 1
    ...    {0 [${serving_cell_pci}] [[${serving_cell_rsrp}] [${serving_cell_rsrq}] [${serving_cell_sinr}]] [] [[1{0[[50] [53] []]}] []] [] []}
    ...    [0(1{[${neigh_cell_pci}] [[${neigh_cell_rsrp}] [${neigh_cell_rsrq}] [${neigh_cell_sinr}]] [][ [1{0[[71] [57] []]}] [] ] })]
    ${response}    tm500_remote.send_command    command=${cmd_a3_mr}    alias=${tm500_alias}
    ${response1}    tm500_remote.send_command    command=forw mte Activate -1    alias=${tm500_alias}
    sleep    5s

A3 measurement trigger with rsrq
     [Arguments]    ${a1_meas_id}=3    ${report_interval}=4    ${serving_cell_pci}=50    ${serving_cell_rsrp}=50
    ...    ${serving_cell_rsrq}=53    ${serving_cell_sinr}=35    ${neigh_cell_pci}=52    ${neigh_cell_rsrp}=71    ${neigh_cell_rsrq}=74
    ...    ${neigh_cell_sinr}=44    ${tm500_alias}=e500
    log to console  Start to trigger A1 with rsrq measurement report
    ${cmd_a3_mr}    catenate
    ...    forw mte NrRrcAptTriggerMeasReport ${a1_meas_id} 0 0 ${report_interval} 1
    ...    {0 [${serving_cell_pci}] [[${serving_cell_rsrp}] [${serving_cell_rsrq}] [${serving_cell_sinr}]] [] [[1{0[[50] [53] []]}] []] [] []}
    ...    [0(1{[${neigh_cell_pci}] [[${neigh_cell_rsrp}] [${neigh_cell_rsrq}] [${neigh_cell_sinr}]] [][ [1{0[[71] [74] []]}] [] ] })]
    ${response}    tm500_remote.send_command    command=${cmd_a3_mr}    alias=${tm500_alias}
    ${response1}    tm500_remote.send_command    command=forw mte Activate -1    alias=${tm500_alias}
    sleep    5s

A2 measurement trigger
    [Arguments]    ${a3_meas_id}=1    ${report_interval}=0    ${serving_cell_pci}=50    ${serving_cell_rsrp}=75
    ...    ${serving_cell_rsrq}=53    ${serving_cell_sinr}=35    ${neigh_cell_pci}=51    ${neigh_cell_rsrp}=66    ${neigh_cell_rsrq}=57
    ...    ${neigh_cell_sinr}=44    ${tm500_alias}=e500
    log to console  Start to trigger A2 measurement report
    ${cmd_a3_mr}    catenate
    ...    forw mte NrRrcAptTriggerMeasReport ${a3_meas_id} 0 0 ${report_interval} 1
    ...    {8 [${serving_cell_pci}] [[${serving_cell_rsrp}] [${serving_cell_rsrq}] [${serving_cell_sinr}]] [] [[1{0[[75] [53] []]}] []] [] []}
    ...    [0(1{[${neigh_cell_pci}] [[${neigh_cell_rsrp}] [${neigh_cell_rsrq}] [${neigh_cell_sinr}]] [][ [1{0[[66] [57] []]}] [] ] })]
    ${response}    tm500_remote.send_command    command=${cmd_a3_mr}    alias=${tm500_alias}
    ${response1}    tm500_remote.send_command    command=forw mte Activate -1    alias=${tm500_alias}
    sleep    5s

A2_009 measurement trigger
    [Arguments]    ${a3_meas_id}=1    ${report_interval}=0    ${serving_cell_pci}=50    ${serving_cell_rsrp}=75
    ...    ${serving_cell_rsrq}=53    ${serving_cell_sinr}=35    ${neigh_cell_pci}=52    ${neigh_cell_rsrp}=66    ${neigh_cell_rsrq}=57
    ...    ${neigh_cell_sinr}=44    ${tm500_alias}=e500
    log to console  Start to trigger A2 measurement report
    ${cmd_a3_mr}    catenate
    ...    forw mte NrRrcAptTriggerMeasReport ${a3_meas_id} 0 0 ${report_interval} 1
    ...    {8 [${serving_cell_pci}] [[${serving_cell_rsrp}] [${serving_cell_rsrq}] [${serving_cell_sinr}]] [] [[1{0[[75] [53] []]}] []] [] []}
    ...    [0(1{[${neigh_cell_pci}] [[${neigh_cell_rsrp}] [${neigh_cell_rsrq}] [${neigh_cell_sinr}]] [][ [1{0[[66] [] []]}] [] ] })]
    ${response}    tm500_remote.send_command    command=${cmd_a3_mr}    alias=${tm500_alias}
    ${response1}    tm500_remote.send_command    command=forw mte Activate -1    alias=${tm500_alias}

A3 measurement trigger
    [Arguments]    ${a3_meas_id}=3    ${report_interval}=4    ${serving_cell_pci}=50    ${serving_cell_rsrp}=30
    ...    ${serving_cell_rsrq}=53    ${serving_cell_sinr}=35    ${neigh_cell_pci}=51    ${neigh_cell_rsrp}=54    ${neigh_cell_rsrq}=57
    ...    ${neigh_cell_sinr}=44    ${tm500_alias}=e500
    log to console  Start to trigger A3 measurement report
    ${cmd_a3_mr}    catenate
    ...    forw mte NrRrcAptTriggerMeasReport ${a3_meas_id} 0 0 ${report_interval} 1
    ...    {0 [${serving_cell_pci}] [[${serving_cell_rsrp}] [${serving_cell_rsrq}] [${serving_cell_sinr}]] [] [[1{0[[30] [] []]}] []] [] []}
    ...    [0(1{[${neigh_cell_pci}] [[${neigh_cell_rsrp}] [${neigh_cell_rsrq}] [${neigh_cell_sinr}]] [][ [1{0[[54] [] []]}] [] ] })]
    ${response}    tm500_remote.send_command    command=${cmd_a3_mr}    alias=${tm500_alias}
    ${response1}    tm500_remote.send_command    command=forw mte Activate -1    alias=${tm500_alias}
    sleep    5s
    Wait until keyword succeeds    10s    200ms    match pattern in response    response=${response}
    ...    e500_alias=${tm500_alias}    pattern=Random Access Complete

start btslog on ute
    [Arguments]      ${connection}=ute     ${btslog_name}=btslog.log
    csn.Connect to     hostname=${TEST_PC_IP}     username=${TEST_PC_USERNAME}    password=${TEST_PC_PASSWORD}  alias=${connection}
    log to console    start syslog...
    ${list}    Create list     ${port1}    ${port2}
    ute_syslog.Start Syslog    log_dir=${OUTPUT_DIR}      log_name=${btslog_name}
    ...      host_ip=${TEST_PC_IP}    ssh_username=ute    ssh_password=ute    ports=${list}    alias=${connection}

Check wireshark log data equal value
    [Arguments]    ${command}    ${pacp_filename}   ${txt_filename}    ${filter}   ${check}    ${connection}=ute
    ${data}    Check wireshark log data common    command=${command}    pacp_filename=${pacp_filename}    connection=${connection}
    ...   txt_filename=${txt_filename}      filter=${filter}
    should be equal as strings    ${data}    ${check}
    log to console    data:${data}

Check wireshark log data not equal value
    [Arguments]    ${command}    ${pacp_filename}   ${txt_filename}    ${filter}   ${check}    ${connection}=ute
    ${data}    Check wireshark log data common    command=${command}    pacp_filename=${pacp_filename}    connection=${connection}
    ...   txt_filename=${txt_filename}      filter=${filter}
    Should Not Be Equal As Strings   ${data}    ${check}
    log to console    data:${data}

Check wireshark log data common
    [Arguments]    ${command}    ${pacp_filename}   ${txt_filename}    ${filter}    ${connection}=ute
    Connect to ENB with ssh    hostname=${TEST_PC_IP}    username=${TEST_PC_USERNAME}     password=${TEST_PC_PASSWORD}    alias=${connection}
    sleep    1s
    log to console    ${LOG_PATH}
    log to console    ${pacp_filename}
    Convert pcap to text   source=${LOG_PATH}/${pacp_filename}
    ...  target=${LOG_PATH}/${txt_filename}   connection=${connection}    filter=${filter}
    csn.Send Command  command=cat ${LOG_PATH}/${txt_filename} |${command}    connection=${connection}
    ${data}    csn.Read Output    connection=${connection}
    ${data}    strip_string    ${data}
    [Return]   ${data}
    [Teardown]    csn.Disconnect  	connection=${connection}

Connect to ENB with ssh
    [Arguments]    ${hostname}=${enb_ip}    ${username}=${eNB_username}      ${password}=${eNB_password}   ${alias}=enb
    csn.connect_to   hostname=${hostname}
        ...    username=${username}    password=${password}    alias=${alias}

Convert pcap to text
    [Arguments]    ${source}    ${target}    ${filter}   ${connection}=ute
    csn.send_command
    ...  command=nice tshark -X lua_script:${luashark_path} -V -r ${source} -T text > ${target} -Y '${filter}'   connection=${connection}
    csn.await execution end  connection=${connection}  timeout=30min
    sleep    5s

Get measId from wireshark log
    [Arguments]    ${command}    ${pacp_filename}   ${txt_filename}    ${filter}    ${connection}=ute
    Connect to ENB with ssh    hostname=${TEST_PC_IP}    username=${TEST_PC_USERNAME}     password=${TEST_PC_PASSWORD}    alias=${connection}
    sleep    1s
    Convert pcap to text   source=${LOG_PATH}/${pacp_filename}
    ...  target=${LOG_PATH}/${txt_filename}   connection=${connection}    filter=${filter}
    csn.Send Command  command=cat ${LOG_PATH}/${txt_filename} |${command}    connection=${connection}
    ${data}    csn.Read Output    connection=${connection}
    ${data}    strip_string    ${data}
    [Return]   ${data}
    [Teardown]    csn.Disconnect	connection=${connection}

Get nrcellid from web UI
    ${nrCellId1}     COAM Get nrcellid with the lcrid    bts_host=${gNB_ip}    lcrid=${1}
    ${nrCellId2}     COAM Get nrcellid with the lcrid    bts_host=${gNB_ip}   lcrid=${2}
    [Return]   ${nrCellId1}   ${nrCellId2}

Check PM counter result
    [Arguments]    ${counter_id}    ${index}=${0}    ${enb}=${False}    ${BTS}=BTS    ${CELLS}=CELLS
    ...    ${NRCELL}=NRCELL-1    ${counter_object}=NX2CC
    ${connection}    Rest Login DU    index=${index}    enb=${enb}
    sleep    6min
    ${counter_values}=    coam.get pm counters    couter_ids=${counter_id}    connection=${connection}
    ${result}    Get Dictionary Values   ${counter_values['${BTS}']['${CELLS}']['${NRCELL}']['${counter_object}']['${counter_id}']}
    [Return]    ${result}
    [Teardown]      Rest Logout DU    alias=${connection}

check BTS DL throughput
    [Arguments]   ${flag1}=100    ${flag2}=100    ${CELL1}=16385    ${CELL2}=16386    ${btslog}=btslog.log    ${connection}=GNB_OAM
    log to console    Check DL throughput
    Connect to ENB with ssh    hostname=${TEST_PC_IP}    username=${TEST_PC_USERNAME}     password=${TEST_PC_PASSWORD}    alias=${connection}
    FOR    ${NUM}    IN RANGE    ${1}    ${99}    1
        csn.Send Command
        ...    command=cat ${LOG_PATH}/${btslog}|grep DataPdu|grep ${CELL1}|cut -d ':' -f 8|cut -d '|' -f 3|head -${NUM}|tail -n 1|tr -cd "[0-9]"
        ...    connection=${connection}
        ${TP1}    csn.Read Output    connection=${connection}
        ${TP1}    Evaluate    int(${TP1})
        Run keyword if    ${TP1}==${0}      Continue For Loop
        csn.Send Command
        ...    command=cat ${LOG_PATH}/${btslog}|grep DataPdu|grep ${CELL2}|cut -d ':' -f 8|cut -d '|' -f 3|head -${NUM}|tail -n 1|tr -cd "[0-9]"
        ...    connection=${connection}
        ${TP2}    csn.Read Output    connection=${connection}
        ${TP2}    Evaluate    int(${TP2})
        log to console    ${CELL1}:${TP1}
        log to console    ${CELL2}:${TP2}
        run keyword if    ${TP2}==${0}     Set test variable    ${flag1}    ${NUM}
        run keyword if    ${TP2}==${0}     should be true    ${TP1}>${200}
        run keyword if    ${TP2}>${200}     Set test variable    ${flag2}    ${NUM}
        should be true    ${flag2}>${flag1}
    END
    should not be equal as numbers    ${flag1}    100
    should not be equal as numbers    ${flag2}    100
    log to console    Check DL throughput successful
    [Teardown]     csn.Disconnect    connection=${connection}

Check EventA2 from wireshark log data
    [Arguments]      ${pacp_filename}   ${txt_filename}    ${filter}   ${event}   ${MeasID}   ${connection}=ute
    Connect to ENB with ssh    hostname=${TEST_PC_IP}    username=${TEST_PC_USERNAME}     password=${TEST_PC_PASSWORD}    alias=${connection}
    Convert pcap to text   source=${LOG_PATH}/${pacp_filename}
    ...  target=${LOG_PATH}/${txt_filename}   connection=${connection}    filter=${filter}
    csn.Send Command  command=cat ${LOG_PATH}/${txt_filename} |awk '/measId: ${MeasID}/{p=5}p-->0'|head -3|tail -n 1|tr -cd "[0-9]"
    ...    connection=${connection}
    ${reportConfigId}    csn.Read Output    connection=${connection}
    ${reportConfigId}    strip_string    ${reportConfigId}
    csn.Send Command  command=cat ${LOG_PATH}/${txt_filename}|awk '/reportConfigId: ${reportConfigId}/{p=8}p-->0'|head -7|tail -n 1
    ...    connection=${connection}
    ${event1}    csn.Read Output    connection=${connection}
    ${event1}    strip_string    ${event1}
    should be equal as strings    ${event1}     ${event}
    log to console    event:${event1}
    [Teardown]    csn.Disconnect	connection=${connection}

Check Event and Rsrp by measID
    [Arguments]      ${pacp_filename}   ${txt_filename}    ${filter}   ${event}   ${MeasID}  ${rsrp}=rsrp  ${connection}=ute
    Connect to ENB with ssh    hostname=${TEST_PC_IP}    username=${TEST_PC_USERNAME}     password=${TEST_PC_PASSWORD}    alias=${connection}
    Convert pcap to text   source=${LOG_PATH}/${pacp_filename}
    ...  target=${LOG_PATH}/${txt_filename}   connection=${connection}    filter=${filter}
    csn.Send Command  command=cat ${LOG_PATH}/${txt_filename} |awk '/measId: ${MeasID}/{p=5}p-->0'|head -3|tail -n 1|tr -cd "[0-9]"
    ...    connection=${connection}
    ${reportConfigId}    csn.Read Output    connection=${connection}
    ${reportConfigId}    strip_string    ${reportConfigId}
    csn.Send Command  command=cat ${LOG_PATH}/${txt_filename}|awk '/reportConfigId: ${reportConfigId}/{p=8}p-->0'|head -7|tail -n 1
    ...    connection=${connection}
    ${event1}    csn.Read Output    connection=${connection}
    ${event1}    strip_string    ${event1}
    should be equal as strings    ${event1}     ${event}
    log to console    event:${event1}
    csn.Send Command  command=cat ${LOG_PATH}/${txt_filename}|awk '/reportConfigId: ${reportConfigId}/{p=8}p-->0'|head -8|tail -n 1|awk '{print $2}'
    ...    connection=${connection}
    ${rsrp}    csn.Read Output    connection=${connection}
    Should Contain  ${rsrp}  rsrp
    log to console    rsrp:${rsrp}
    [Teardown]    csn.Disconnect	connection=${connection}

Check gapoffset
    [Arguments]    ${offset_data}    ${source}=${source}    ${target}=${target}    ${filter}=${filter12}
    csn.Connect to     hostname=${TEST_PC_IP}   username=${TEST_PC_USERNAME}    password=${TEST_PC_PASSWORD}  alias=${connection}
    sleep    1s
    csn.Send Command  command=cat ${target}|grep gapOffset:|tr -cd "[0-9]"    connection=${connection}
    ${offset}    csn.Read Output    connection=${connection}
    ${offset}    strip_string    ${offset}
    should be equal as Numbers    ${offset}    ${offset_data}
    log to console    offset_data:${offset}
    [Teardown]    csn.Disconnect	connection=${connection}

check BTS UL throughput
    [Arguments]   ${CELL1}    ${CELL2}   ${btslog}=btslog.log   ${flag3}=100    ${flag4}=100    ${connection}=GNB_OAM
    log to console    Check UL throughput
    Connect to ENB with ssh    hostname=${TEST_PC_IP}    username=${TEST_PC_USERNAME}     password=${TEST_PC_PASSWORD}    alias=${connection}
    FOR    ${NUM}    IN RANGE    ${1}    ${150}    1
        csn.Send Command
        ...    command=cat ${LOG_PATH}/${btslog} |grep UlCounterUp|grep ${CELL1}|awk '{print $10}'|head -${NUM}|tail -n 1|tr -cd "[0-9]"
        ...    connection=${connection}
        ${TP1}    csn.Read Output    connection=${connection}
        ${TP1}    Evaluate    int(${TP1})
        Run keyword if    ${TP1}==${0}      Continue For Loop
        csn.Send Command
        ...    command=cat ${LOG_PATH}/${btslog}|grep UlCounterUp|grep ${CELL2}|awk '{print $10}'|head -${NUM}|tail -n 1|tr -cd "[0-9]"
        ...    connection=${connection}
        ${TP2}    csn.Read Output    connection=${connection}
        ${TP2}    Evaluate    int(${TP2})
        log to console    ${CELL1}:${TP1}
        log to console    ${CELL2}:${TP2}
        run keyword if    ${TP2}==${0}    Set test variable    ${flag3}    ${NUM}
        run keyword if    ${TP2}==${0}    should be true    ${TP1}>${200}
        run keyword if    ${TP2}>${200}     Set test variable    ${flag4}    ${NUM}
        should be true    ${flag4}>${flag3}
    END
    should not be equal as numbers    ${flag3}    100
    should not be equal as numbers    ${flag4}    100
    log to console    Check UL throughput successful
    [Teardown]    csn.Disconnect    connection=${connection}

Recover object
    Connect to DU
    ${result}    coam.get_managed_objects    class_name=NRMOPR_NSA_A   connection=cOAM_admin
    ${target_dist}    set variable    ${None}
    FOR    ${item}    IN     @{result}
        ${dist_name}    Collections.get from dictionary    ${item}    distName
        ${target_dist}     set variable     ${item}
        exit for loop if    'NRMOPR_NSA_A-2' in '${dist_name}'
    END
    ${parameter}     Collections.get from dictionary    ${target_dist}    parameters
    ${nrMeasCfgIfDNList}     Collections.get from dictionary    ${parameter}    nrMeasCfgIfDNList
   FOR    ${item}     IN     @{nrMeasCfgIfDNList}
        ${is_remove}    run keyword and return status    should contain    ${item}    NRMEASCFG_IF_A-2
        ${new_item}    string.replace string    ${item}    NRMEASCFG_IF_A-3    NRMEASCFG_IF_A-2
        run keyword if  not ${is_remove}    append to list    ${nrMeasCfgIfDNList}     ${new_item}
    END
    log to console    ${nrMeasCfgIfDNList}
    coam.perform_parameter_recommissioning     dist_name=${NRMTS_name}/NRMOPR_NSA-2
    ...                                        parameter=nrMeasCfgIfDNList
    ...                                        operation=update
    ...                                        value=${nrMeasCfgIfDNList}
    ...                                        skip_parameter_relation_errors=${True}
    ...                                        should_activate=${True}
    ...                                        connection=cOAM_admin
    [Teardown]    Disconnect from DU

Delete object
    Connect to DU
    ${result}    coam.get_managed_objects    class_name=NRMOPR_NSA_A   connection=cOAM_admin
    ${target_dist}    set variable    ${None}
    FOR    ${item}    IN     @{result}
        ${dist_name}    Collections.get from dictionary    ${item}    distName
        ${target_dist}     set variable     ${item}
        exit for loop if    'NRMOPR_NSA_A-2' in '${dist_name}'
    END
    ${parameter}     Collections.get from dictionary    ${target_dist}    parameters
    ${nrMeasCfgIfDNList}     Collections.get from dictionary    ${parameter}    nrMeasCfgIfDNList
    FOR    ${item}     IN     @{nrMeasCfgIfDNList}
        ${is_remove}    run keyword and return status    should contain    ${item}    NRMEASCFG_IF_A-2
        run keyword if  ${is_remove}    remove values from list    ${nrMeasCfgIfDNList}     ${item}
    END
    log to console    ${nrMeasCfgIfDNList}
    coam.perform_parameter_recommissioning     dist_name=${NRMTS_name}/NRMOPR_NSA-2
    ...                                        parameter=nrMeasCfgIfDNList
    ...                                        operation=update
    ...                                        value=${nrMeasCfgIfDNList}
    ...                                        skip_parameter_relation_errors=${True}
    ...                                        should_activate=${True}
    ...                                        connection=cOAM_admin
    [Teardown]   Disconnect from DU

Delete NRMOPRMA_NSA-2 AND NRMOPR_NSA-2
    Connect to DU
    ${NRMOPRMA_NSA}    coam.get_managed_objects    class_name=NRMOPRMA_NSA_A   connection=cOAM_admin
    ${NRMOPR_NSA}    coam.get_managed_objects    class_name=NRMOPR_NSA_A   connection=cOAM_admin

    log to console    delete NRMOPRMA_NSA-2
    @{emptyList}     create list
    coam.perform_object_recommissioning     dist_name=${NRMTS_name}/NRMOPRMA_NSA-2
    ...                                        parameter=@{emptyList}
    ...                                        operation=delete
    ...                                        skip_parameter_relation_errors=${True}
    ...                                        should_activate=${True}
    ...                                        connection=cOAM_admin

    log to console    delete NRMOPR_NSA-2
    coam.perform_object_recommissioning     dist_name=${NRMTS_name}/NRMOPR_NSA-2
    ...                                         parameter=@{emptyList}
    ...                                         operation=delete
    ...                                        skip_parameter_relation_errors=${True}
    ...                                        should_activate=${True}
    ...                                        connection=cOAM_admin
    [Return]     ${NRMOPRMA_NSA}     ${NRMOPR_NSA}
    [Teardown]   Disconnect from DU

Change ssbFrequency
    Connect to DU
     ${dict2}    create dictionary    parameterName=ssbFrequency   operation=update    value=${2074843}
     ${list2}    create list   ${dict2}
    coam.perform_object_recommissioning     dist_name=${NRMTS_name}/NRCELL-1/NRHOIF-2    parameter=${list2}
     ...    operation=update
     ...    skip_parameter_relation_errors=${True}    should_activate=${True}
     ...    connection=cOAM_admin
    [Teardown]     Disconnect from DU

Modify SCF file and create new SCF
    log to console      start modify scf offline...
    ${default_scf}      Get BTS Version And SCF Path
    scf.load_scf       file_path=${default_scf}
    sleep   3s
    modify_scf_element     dist_name=${NR_CELL_NAME2}    p_name=nrarfcn     value=2073799
    modify_scf_element     dist_name=${NR_CELL_NAME2}    p_name=gscnOrSsPbchArfcn     value=22454
    scf.save_scf        file_path=${new_scf_path}
    log to console      modify successful,${default_scf} will be commissioned.
    [Return]     ${new_scf_path}

Get BTS Version And SCF Path
    [Arguments]    ${gnbnumber}=2    ${gNB_ip}=${gNB_ip}   ${CURDIR_path}=${CURDIR_path}
    ${connection}    Connect to DU2
    ${version}    coam.get_sw_version    connection=${connection}
    log to console    bts version=${version}
    ${scf_name}    Covert_BTS_Version    version=${version}    gnbnumber=${gnbnumber}
    ${default_scf}    set variable    ${CURDIR_path}/${scf_name}
    [Return]    ${default_scf}
    [Teardown]    Run keyword and ignore error     coam.teardown      connection=${connection}

Update a3MeashoEnabled
    Connect to DU
      coam.perform_parameter_recommissioning     dist_name=${NRMTS_name}/NRMEASCFG_IF-2    parameter=a3MeasEnabled
      ...    operation=update    value=rsrpCombined
      ...    skip_parameter_relation_errors=${False}    should_activate=${True}
      ...    connection=cOAM_admin
    [Teardown]     Disconnect from DU

Recover a3MeashoEnabled
    Connect to DU
      coam.perform_parameter_recommissioning     dist_name=${NRMTS_name}/NRMEASCFG_IF-2    parameter=a3MeasEnabled
      ...    operation=update    value=rsrp
      ...    skip_parameter_relation_errors=${False}    should_activate=${True}
      ...    connection=cOAM_admin
    [Teardown]     Disconnect from DU

Update a1MeashoEnabled
    Connect to DU
      coam.perform_parameter_recommissioning     dist_name=${NRMTS_name}/NRMOPR_NSA-2    parameter=a1MeashoEnabled
      ...    operation=update    value=rsrpCombined
      ...    skip_parameter_relation_errors=${False}    should_activate=${True}
      ...    connection=cOAM_admin
    [Teardown]     Disconnect from DU

Recover a1MeashoEnabled
    Connect to DU
      coam.perform_parameter_recommissioning     dist_name=${NRMTS_name}/NRMOPR_NSA-2    parameter=a1MeashoEnabled
      ...    operation=update    value=rsrp
      ...    skip_parameter_relation_errors=${False}    should_activate=${True}
      ...    connection=cOAM_admin
    [Teardown]     Disconnect from DU


Connect to DU
    [Arguments]    ${alias}=cOAM_admin
    ${conn}=    coam.connect_to
    ...    bts_host=${gNB_ip}
    ...    username=${DU_OAM_WEBUI_USER}
    ...    password=${DU_OAM_WEBUI_PASSWORD}
    ...    name=${alias}
    [Return]    ${conn}

Disconnect from DU
    [Arguments]    ${alias}=cOAM_admin
    coam.teardown     connection=${alias}

Connect to DU2
    [Arguments]    ${alias}=cOAM_admin
    ${conn}=    coam.connect_to
    ...    bts_host=${gNB2_ip}
    ...    username=${DU_OAM_WEBUI_USER}
    ...    password=${DU_OAM_WEBUI_PASSWORD}
    ...    name=${alias}
    [Return]    ${conn}

Disconnect from DU2
    [Arguments]    ${alias}=cOAM_admin
    coam.teardown     connection=${alias}

Recover ssbFrequency
    Connect to DU
     ${dict2}    create dictionary    parameterName=ssbFrequency   operation=update    value=${2074267}
     ${list2}    create list   ${dict2}
    coam.perform_object_recommissioning     dist_name=${NRMTS_name}/NRCELL-1/NRHOIF-2    parameter=${list2}
     ...    operation=update
     ...    skip_parameter_relation_errors=${False}    should_activate=${True}
     ...    connection=cOAM_admin
    [Teardown]    Disconnect from DU

kill IPSL process
    Connect to cobham control pc via ssh
    csn.send command    command=taskkill /f /im "ips32.exe"       connection=tma_ssh
    Disconnect from cobham control pc via ssh

Check wireshark log data contain message
    [Arguments]    ${message}     ${txt_filename}    ${connection}=cOAM_admin
    Connect to DU
    csn.Send Command  command=cat ${LOG_PATH}/${txt_filename} | grep ${message}    connection=${connection}
    ${data}    csn.Read Output    connection=${connection}
    ${data}    strip_string    ${data}
    should not be empty    ${data}
    log to console    data:${data}
    [Teardown]     Disconnect from DU

Rest Logout DU
    [Arguments]  ${alias}=default
    [Documentation]   Rest Logout DU
    coam.Teardown  connection=${alias}

Case Teardown
    run keyword and continue on failure     traffic_via_iperf.Kill iperf process on app server     port=${dl_port}
    viavi_common_keyword.Cobham UE detach

Get length and Check sum counter value
    [Arguments]     ${list_input}
    ${length}      Get Length       ${list_input}
    ${counter_value_sum}       Set Variable          0
    FOR   ${i}    IN RANGE    ${0}    ${length}     1
        ${counter_value_sum}     Evaluate    ${counter_value_sum}+${list_input}[${i}]
    END
    [Return]     ${counter_value_sum}

Start logging on cobham and Return Folder
    [Documentation]  Author: Jiang Hongyu
    ...              Description: Start logging on cobham TMA so that the protocol logs can be captured
    ...                           And Return Log path
    [Arguments]    ${connection}=${TMA_APP_ALIAS}
    ${output_start_logging}    tm500_remote.send_command    command=#$$START_LOGGING    alias=${connection}
    should contain    ${output_start_logging}      START_LOGGING 0x00 OK    msg=Start logging on cobham failed
    ${logs_path}    Get_Viavi_CSV_Log_Path    log_str=${output_start_logging}
    log to console    ${output_start_logging}
    log to console    ${logs_path}
    [Return]  ${logs_path}

Download Viavi Log
    [Documentation]
    [Arguments]  ${logs_path}    ${retry}=2min    ${time}=40s    ${connect}=Control_PC
    log to console    ${logs_path}
    ssh.Connect to    hostname=${E500_IP}    username=${E500_USER}    password=${E500_PW}    alias=${connect}
    ${new_path}    set variable    /cygdrive/c/Users/nokia5G/Documents/CSV/${logs_path}[1]
    ssh.send command    command=mkdir ${new_path}    connection=${connect}
    Wait Until Keyword Succeeds   ${retry}    10s    Check CSV file is exsit    csv_path='${logs_path}[0]'    connection=${connect}
    ssh.send command    command=cd '${logs_path}[0]';scp *.csv ${new_path}     connection=${connect}
    sleep    ${time}
    Copy Viavi Log    logs_path=${new_path}
    ssh.send command    command=rm -rf ${new_path}    connection=${connect}
    ${ute_path}    set variable    ${output_dir}/${logs_path}[1]
    [Return]  ${ute_path}
    [Teardown]    Run Keyword And Ignore error    ssh.disconnect    connection=${connect}

Check CSV file is exsit
    [Arguments]  ${csv_path}    ${connection}
    ${file_list}   ssh.execute   ls ${csv_path}   connection=${connection}
    ${file_list}    Split String    ${file_list}    \r\n
    ${csv_list}    Get_csv_is_exsit    input_list=${file_list}
    ${csv_list_len}    Get Length    ${csv_list}
    should be equal as integers    ${csv_list_len}    ${2}    msg=Don't have all csv file
    [Return]   ${csv_list}

Copy Viavi Log
    [Documentation]
    [Arguments]  ${logs_path}    ${ute_path}=${output_dir}    ${time}=40s    ${connect}=ute
    ssh.Connect to    hostname=${TEST_PC_IP}    username=${TEST_PC_USERNAME}    password=${TEST_PC_PASSWORD}
    ...     alias=${connect}
    ssh.send command    command=sshpass -p ${E500_PW} scp -r ${E500_USER}@${E500_IP}:${logs_path} ${ute_path}
    ...     connection=${connect}
    sleep    ${time}
    [Teardown]  Run Keyword And Ignore error    ssh.disconnect    connection=${connect}

Check_TP_And_Bler
    [Arguments]  ${dir_path}    ${ul_min_tp}    ${ul_max_tp}    ${dl_min_tp}    ${dl_max_tp}    ${bler_value}    ${row}=${10}
    ${ul_tp_result}  Viavi_Log_analysis.Check_One_UE_TP_Stable    dir_path=${dir_path}    direction=ul    check_value=${ul_max_tp}
    ...    expect_num=${5}    UE_ID=0
    ${dl_tp_result}   Viavi_Log_analysis.Check_One_UE_TP_Stable    dir_path=${dir_path}    direction=dl    check_value=${dl_max_tp}
    ...    expect_num=${5}    UE_ID=0
    ${ul_bler_result}    Viavi_Log_analysis.Check_One_UE_Bler_Stable    dir_path=${dir_path}    direction=ul    check_value=${bler_value}
    ...    expect_num=${5}    UE_ID=0
    ${dl_bler_result}    Viavi_Log_analysis.Check_One_UE_Bler_Stable    dir_path=${dir_path}    direction=dl    check_value=${bler_value}
    ...    expect_num=${5}    UE_ID=0
    ${ul_start_time}    Viavi_Log_analysis.Check_One_UE_Start_TP_Time    dir_path=${dir_path}    direction=ul    row=${row}
    ...    min=${ul_min_tp}    max=${ul_max_tp}
    ${dl_start_time}    Viavi_Log_analysis.Check_One_UE_Start_TP_Time    dir_path=${dir_path}    direction=dl    row=${row}
    ...    min=${dl_min_tp}    max=${dl_max_tp}
    Run Keyword And Continue On Failure    Should Be Equal    ${ul_tp_result}    ${True}
    Run Keyword And Continue On Failure    Should Be Equal    ${dl_tp_result}    ${True}
    Run Keyword And Continue On Failure    Should Be Equal    ${ul_bler_result}    ${True}
    Run Keyword And Continue On Failure    Should Be Equal    ${dl_bler_result}    ${True}
    Run Keyword And Continue On Failure    Should Be Equal    ${ul_start_time}    ${True}
    Run Keyword And Continue On Failure    Should Be Equal    ${dl_start_time}    ${True}

009 Common Case Teardown
    Log To Console       Recover a3MeashoEnabled to rsrp...
    Recover a3MeashoEnabled
    Online update paramters    parameters=${gnb1_recover}
    Online update paramters    parameters=${gnb2_recover}    index=${1}
