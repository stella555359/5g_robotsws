*** Settings ***

Library           Telnet
Library           ta5g_syslog
Resource          Capture.robot
Resource          TTI.robot
#Resource          Sherpa.robot
Library           ../python/ssh_command.py     WITH NAME    ssh_cmd
Library           ../python/BIP_Capture.py
Library           ../python/CPRT_Capture.py
Library           taf.transport.ssh    WITH NAME    csn
Library           String
Library          taf.ul.gnb.bip.collection   WITH NAME   bip_collection
Library            ../python/dcap_utilities.py
Library            ../python/dcap.py
Library           taf.ul.ue.sim.env_setup


*** Variables ***
${BIP_SCRIPT_PATH}         /home/ute/MN/UTE/robotws/testsuite/Bangalore/RRM/5GET_BLR/resources/NPS/SWENG/config/script/
&{AP_ASIK}     Ip=192.168.200.1    Username=toor4nsn    Password=oZPS0POrRieRtu    Connection=ApAsik
&{GNB_ASIK}    Ip=192.168.255.1    Username=toor4nsn    Password=oZPS0POrRieRtu    Connection=GnbAsik
${GNB_ASIK.ip}  192.168.255.1
${GNB.ip}       192.168.255.1
${AP_ASIK.ip}   192.168.200.1
${AP_ABIL.ip}   192.168.200.1
${GNB_ASIK.username}    toor4nsn
${AP_ASIK.username}     toor4nsn
${GNB.username}         toor4nsn
${AP_ABIL.username}     toor4nsn
${GNB_ASIK.password}    oZPS0POrRieRtu
${GNB.password}        oZPS0POrRieRtu
${AP_ASIK.password}     oZPS0POrRieRtu
${AP_ABIL.password}     oZPS0POrRieRtu
${GNB_ASIK.connection}  GnbAsik
${AP_ASIK.connection}   ApAsik
@{l2comp}    L2PS
${vDU_NODE_HOST}                ${tl.gnbs[0].dus[0].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.addr}
${vDU_NODE_USER}                ${tl.gnbs[0].dus[0].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.username}
${vDU_NODE_PASSWORD}            ${tl.gnbs[0].dus[0].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.password}
${vDU_NAMESPACE}                ${tl.gnbs[0].dus[0].cloud_deployment.cloud_hosting.namespace}
${vCU_NODE_HOST}                ${tl.gnbs[0].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.addr}
${vCU_NODE_USER}                ${tl.gnbs[0].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.username}
${vCU_NODE_PASSWORD}            ${tl.gnbs[0].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.password}
${vCU_NAMESPACE}                ${tl.gnbs[0].cloud_deployment.cloud_hosting.namespace}

*** Keywords ***
Start Log
    [Arguments]    @{log_name_list}     ${cell_id}=${50}    ${gNB_common_unit}=ASIL
    ...    ${bb_mods}=[ABIO]    ${l1_type}=FS
    [Documentation]    This keyword is to start to capture logs.
    FOR    ${log}    IN    @{log_name_list}
        ${log}    String.Convert To Lowercase    ${log}
        Run Keyword If    '${log}'=='btslog'      Start Collecting gNB Syslog
        Run Keyword If    '${log}'=='cprt'        Start CPRT capture
        Run Keyword If    '${log}'=='bip'         Start BIP capture
        Run Keyword If    '${log}'=='biptaf'      Start BIP capture taf    ${gNB_common_unit}    ${bb_mods}    ${l1_type}
        Run Keyword If    '${log}'=='ttitrace'    Start TTI_TRACE      cell_id=${cell_id}
        Run Keyword If    '${log}'=='sherpa'      Start Sherpa Collection
    END

Stop Log
    [Arguments]    @{log_name_list}    ${test_scenario}=${EMPTY}
    [Documentation]    This keyword is to stop logs.
    ${common_log_path}      Create Dictionary
    FOR    ${log}    IN    @{log_name_list}
        ${log}    String.Convert To Lowercase    ${log}
        ${log_dir_gnb}           Set Variable          ${LOG_PATH}/${TEST_NAME}/gNB/${log}/${test_scenario}
        Set suite Variable       ${log_dir_gnb}
        ${log_dir_ap}           Set Variable          ${LOG_PATH}/${TEST_NAME}/AP/${log}/${test_scenario}
        Set suite Variable       ${log_dir_ap}
        Run Keyword If    '${log}'=='btslog'      Stop Syslog    log_dir=${log_dir_gnb}
        Run Keyword If    '${log}'=='snapshot'    Collect GNB AP SnapShot    log_dir_gnb=${log_dir_gnb}
        Run Keyword If    '${log}'=='sosreport'   Collect SosReport    log_dir=${log_dir_ap}
        Run Keyword If    '${log}'=='cprt'        Stop CPRT capture common          log_dir=${log_dir_gnb}
        Run Keyword If    '${log}'=='bip'         Stop BIP capture           log_dir=${log_dir_gnb}
        Run Keyword If    '${log}'=='biptaf'      Stop BIP capture taf       log_dir=${log_dir_gnb}
        Run Keyword If    '${log}'=='ttitrace'    Stop TTItrace log     log_dir=${log_dir_gnb}
        Run Keyword If    '${log}'=='sherpa'      Stop Sherpa Collection     log_dir=${log_dir_gnb}
        Run Keyword If    '${log}'=='sosreport'      Set To Dictionary     ${common_log_path}        ${log}       ${log_dir_ap}
        ...     ELSE
        ...     Set To Dictionary     ${common_log_path}        ${log}       ${log_dir_gnb}
    END
    [Return]        ${common_log_path}

Start Collecting gNB Syslog
    ${ports}=   Create List   51000    51001    51003    50011
    ${CURRENT_SYSLOG_PATH}  Set Variable     ${LOG_PATH}/tmp/
    set suite variable      ${CURRENT_SYSLOG_PATH}
    set suite variable      ${logname}     syslog_gnb.log
    ta5g_syslog.Start Syslog  log_dir=${CURRENT_SYSLOG_PATH}  log_name=${logname}   ip=192.168.255.126
    ...       ssh_username=ute    ssh_password=ute    ports=${ports}

Stop Syslog
    [Arguments]    ${log_dir}
    ta5g_syslog.Collect Syslog Results    destination=${log_dir}/gnb_syslog.log
    run                    rm -rf ${LOG_PATH}/tmp

Collect GNB AP SnapShot
    [Arguments]    ${log_dir_gnb}   #${log_dir_ap}
    Collect GNB SnapShot     ${log_dir_gnb}
#    Collect AP SnapShot Via AaShell    ${log_dir_ap}

Collect GNB SnapShot
    [Arguments]    ${log_dir_snapshot}
    [Documentation]    collect GNB snapshot
    ...    Examples:
    ...    | Collect GNB SnapShot Via AaShell | /tmp |
    SSH.Connect_to          hostname=${GNB_ASIK.ip}
    ...                     username=${GNB_ASIK.username}
    ...                     password=${GNB_ASIK.password}
    ...                     alias=connection_gnb_snapshot
    ${prompt}               Set variable      AaShell>
    ${CURRENT_GNB_SNAPSHOT_PATH}  Set Variable     ${log_dir_snapshot}/
    set suite variable      ${CURRENT_GNB_SNAPSHOT_PATH}
    set suite variable      ${logname}     snapShot_gnb.zip
    SSH.Send command           telnet localhost 15007             connection=connection_gnb_snapshot
    SSH.Read output until      ${prompt}       timeout=60         connection=connection_gnb_snapshot
    SSH.Write input            log -c full -a -z ${log_name}\n    connection=connection_gnb_snapshot
    SSH.Read output until      ${prompt}       timeout=300        connection=connection_gnb_snapshot
    SSH.Write input            quit\n                             connection=connection_gnb_snapshot
    SSH.Await execution end                                       connection=connection_gnb_snapshot
    Create Directory    ${log_dir_snapshot}/
    ${cp_cmd}=    Set Variable    scp ${GNB_ASIK.username}@${GNB_ASIK.ip}:${/}tmp${/}${log_name} ${CURRENT_GNB_SNAPSHOT_PATH}/${logname}
    OperatingSystem.Run    sshpass -p ${GNB_ASIK.password} ${cp_cmd}
    SSH.Disconnect         connection=connection_gnb_snapshot

Collect AP SnapShot Via AaShell
    [Arguments]    ${log_dir_snapshot}
    ${CURRENT_AP_SNAPSHOT_PATH}  Set Variable     ${log_dir_snapshot}/
    set suite variable      ${CURRENT_AP_SNAPSHOT_PATH}
    set suite variable      ${logname}     snapShot_ap.zip
    Telnet.Open Connection    host=${AP_ASIK.ip}    port=15007
    Telnet.Set Prompt    AaShell>
    Telnet.Set Timeout    300 seconds
    Telnet.Write    log -c full -a -z snapShot_ap.zip
#    Telnet.Read Until    AaSysComUserDeregister succeed!
    Telnet.Close Connection
    Sleep     30
    Create Directory    ${log_dir_snapshot}/
    OperatingSystem.Run    sshpass -p ${AP_ASIK.password} scp toor4nsn@${AP_ASIK.ip}:${/}tmp${/}${log_name} ${CURRENT_AP_SNAPSHOT_PATH}/${logname}

Collect SosReport
    [Arguments]    ${log_dir}
    Dated Log           Start generating Sos Report
    OperatingSystem.Run    rm ${wts_dir}/SosReport*.tgz
    Create Directory    ${log_dir}/
    ${ap_sys_card}     ${ap_bb_card}=    ssh_cmd.get_board_type      ${AP_ASIK.Ip}     22    ${AP_ASIK.Username}      ${AP_ASIK.Password}
    ${output}=      Run Keyword If        '${ap_bb_card}'=='ABIL'
    ...     Run And Return Rc And Output        cd ${wts_dir}/ && ${wts_dir}/sosReport.sh -nr -c -s
    ...     ELSE
    ...     Run         cd ${wts_dir}/ && ${wts_dir}/sosReport_ASIK_ASIL.sh
    OperatingSystem.Run    mv ${wts_dir}/SosReport*.tgz ${log_dir}/

##############################Log_collection [cprt,bip,tti,sherpa]##############################################################
Start CPRT capture
    ${capture_cprt}     Capture CPRT Set Upon Config
    Set suite variable    ${capture_var_cprt}    ${capture_cprt}
    Capture init		${capture_var_cprt}
	Capture start		${capture_var_cprt}

Start BIP capture
    ${capture_bip}      Capture L1L2 Set Upon Config
    Set suite variable    ${capture_var_bip}    ${capture_bip}
    Modify BIP Script File      ${BIP_SCRIPT_PATH}
    Capture init		${capture_var_bip}
    Capture start		${capture_var_bip}

Start BIP capture taf
     [Documentation]     Collect L1L2 BIP Logs using taf.ul.gnb.bip.collection - scripting approach
    ...     -   :param alias:     Alias for l1l2bip which is also a directory name (default L1L2_BIP_Logs)
    ...     -   :param bb_mods:   List of BB modules to start collection from them, default: [ABIO]
    [Arguments]    ${gNB_common_unit}    ${bb_mods}    ${l1_type}    ${dir}=L1L2_BIP_Logs
    bip_collection.Configure Bip Collection     l1_type=${l1_type}
    ...                                         gNB_common_unit=${gNB_common_unit}
    ...                                         gNB_capacity_units=${bb_mods}
    ...                                         use_script=True
    ...                                         script_parameters=--bb_slot_1='false' --bb_slot_5='true'
    bip_collection.Start Bip Trace
    Log to console  BIP logs collecting started

Stop BIP capture taf
     [Documentation]     Stop collecting BIP Logs and save them at selected location
    ...     -   :param alias:       Alias for l1l2bip which is also a directory name without spaces (default L1L2_BIP_Logs)
    ...     -   :param dir_path:    Path where BIP logs should be copied (default ${OUTPUT_DIR}/
    ...     -   :param delay:       Time to wait before collecting the logs
    [Arguments]
    ...     ${dir}=L1L2_BIP_Logs    ${log_dir}=${OUTPUT_DIR}
#    Create directory  path=${dir_path}/${alias}
    Create directory  path=${log_dir}
    Create directory  path=/tmp/${dir}
    bip_collection.Stop Bip Trace   target_dir=/tmp/${dir}
    ${rc}=    Run And Return Rc  mergecap /tmp/${dir}/*.pcap* -w /tmp/${dir}/tcpdump.pcap
    Run keyword if    ${rc}!=0    Fail    PCAP merging failed, check if alias does not contain spaces
    Copy File    /tmp/${dir}/tcpdump.pcap    ${log_dir}/BIP_L1L2.pcap
    Remove directory    /tmp/${dir}    recursive=True
    Log to console  BIP logs collecting finished

Stop CPRT capture common
    [Arguments]    ${log_dir}
    Common Capture Stop		${capture_var_cprt}         ${log_dir}

Stop BIP capture
    [Arguments]    ${log_dir}
    Common Capture Stop		${capture_var_bip}          ${log_dir}

Start TTI_TRACE
    [Arguments]    ${cell_id}=${50}
    Common Start Ttitrace With Streaming Mode_3        pysical_cell_ids=${cell_id}

Stop TTItrace log
    [Arguments]    ${log_dir}
    Stop ttitrace Collection        ${log_dir}

Decode TTI Trace
    [Arguments]    ${ttitrace_path}=${EMPTY}
    Dated Log                        converting ttitrace pcap to csv
    ${tti_path}      Set Variable     ${LOG_PATH}/${TEST_NAME}/gNB/ttitrace/${ttitrace_path}/
    Common Convert Ttitrace From Pcap To Excelcsv        ${tti_path}
    Common Convert Tti To Csv Mode          ${tti_path}

Common Convert Tti To Csv Mode
    [Arguments]         ${tti_path}
    Common Format Tti In Stream Mode         ${tti_path}/output_dl.csv     ${tti_path}/output_dl_formated.csv
    Common Format Tti In Stream Mode         ${tti_path}/output_ul.csv     ${tti_path}/output_ul_formated.csv

Start Sherpa Collection
    [Documentation]                  Call SWENG Sherpa KWs to activate sherpa traces on gNB PDCP, RLC, L2PS, L2LO,
    ...                              and start the sherpa live capture with the sherpa application installed on
    ...                              UTE VM
    Dated Log                        Activate Sherpa Collection
    Sherpa.Activate Sherpa

Stop Sherpa Collection
    [Arguments]    ${log_dir}
    [Documentation]                  Call SWENG Sherpa KWs to stop the sherpa traces collection and  put the collected
    ...                              sherpa traces (tcpdump.pcap) under the auto run directory :
    ...                              <auto_log_path>/Logs/<timestampxxxxxxxx.5GC001227-A>/l2stream3/tcpdump/<xxxxxxxxxx>/tcpdump.pcap
    ...                              and decode the sherpa pcap traces to micro_*.csv and macro_*.csv files, which will be located
    ...                              under : <auto_log_path>/Logs/<timestampxxxxxxxx.5GC001227-A>/l2stream3/tcpdump/<xxxxxxxxxx>/tcpdump/*.csv
    Dated Log                        Stop Sherpa Collection
    Sherpa.Deactivate Sherpa and Stop Collect        ${log_dir}

Decode Sherpa pcap
    [Arguments]    ${sherpatrace_path}=${EMPTY}
    Dated Log                        converting sherpa pcap to csv
    ${sherpa_path}      Set Variable     ${LOG_PATH}/${TEST_NAME}/gNB/sherpa/${sherpatrace_path}/
    Upload and decode sherpa pcap files    Sherpa_logs_local_path=${sherpa_path}

Start L1L2 Bip Mon on classical gNB
    Log to Console    \n-----> Start L1L2 Mon <-----
    ${unit0_type}    ${unit1_type}    ${setup_type}    Get_Hardware_unit_type
    Run keyword If    '${unit0_type}[0]'=='ASIM' and '${unit1_type}[0]'=='ABIP' and '${setup_type}'=='Fullstack'    Bip_Mon_Start_ASIM_ABIP
    Run keyword If    '${unit0_type}[0]'=='ASIL' and '${unit1_type}[0]'=='ABIP' and '${setup_type}'=='Fullstack'    Bip_Mon_Start_ASIM_ABIP
    Run keyword If    '${unit0_type}[0]'=='ASIL' and '${unit1_type}[0]'=='ABIO' and '${setup_type}'=='Fullstack'
	...		Bip Mon Start ASIL ASIB ABIO ABIN
    Run keyword If    '${unit0_type}[0]'=='ASIL' and '${unit1_type}[0]'=='ABIN' and '${setup_type}'=='Fullstack'
	...		Bip Mon Start ASIL ASIB ABIO ABIN
    Run keyword If    '${unit0_type}[0]'=='ASIB' and '${unit1_type}[0]'=='ABIO' and '${setup_type}'=='Fullstack'
	...		Bip Mon Start ASIL ASIB ABIO ABIN
    Run keyword If    '${unit0_type}[0]'=='ASIB' and '${unit1_type}[0]'=='ABIN' and '${setup_type}'=='Fullstack'
	...		Bip Mon Start ASIL ASIB ABIO ABIN

Stop and Collect L1L2 Bip Monitoring on classical gNB
    [Arguments]    ${log_path}
    Log to Console    \n-----> Stop and Collect L1L2 Mon <-----
    Create Folder    ${log_path}/L1L2_bipmon/
    ${unit0_type}    ${unit1_type}    ${setup_type}    Get_Hardware_unit_type
    Run keyword If    '${unit0_type}[0]'=='ASIM' and '${unit1_type}[0]'=='ABIP' and '${setup_type}'=='Fullstack'
	...		Bip_Mon_Stop_Collect_ASIM_ABIP    ${log_path}/L1L2_bipmon/
    Run keyword If    '${unit0_type}[0]'=='ASIL' and '${unit1_type}[0]'=='ABIP' and '${setup_type}'=='Fullstack'
	...		Bip_Mon_Stop_Collect_ASIM_ABIP    ${log_path}/L1L2_bipmon/
    Run keyword If    '${unit0_type}[0]'=='ASIL' and '${unit1_type}[0]'=='ABIO' and '${setup_type}'=='Fullstack'
	...		Bip_Mon_Stop_Collect_ASIL_ASIB_ABIO_ABIN    ${log_path}/L1L2_bipmon/
    Run keyword If    '${unit0_type}[0]'=='ASIL' and '${unit1_type}[0]'=='ABIN' and '${setup_type}'=='Fullstack'
	...		Bip_Mon_Stop_Collect_ASIL_ASIB_ABIO_ABIN    ${log_path}/L1L2_bipmon/
    Run keyword If    '${unit0_type}[0]'=='ASIB' and '${unit1_type}[0]'=='ABIO' and '${setup_type}'=='Fullstack'
	...		Bip_Mon_Stop_Collect_ASIL_ASIB_ABIO_ABIN    ${log_path}/L1L2_bipmon/
    Run keyword If    '${unit0_type}[0]'=='ASIB' and '${unit1_type}[0]'=='ABIN' and '${setup_type}'=='Fullstack'
	...		Bip_Mon_Stop_Collect_ASIL_ASIB_ABIO_ABIN    ${log_path}/L1L2_bipmon/


Get_Hardware_unit_type
    taf_SSH.Connect_to    hostname=${GNB_ASIK.Ip}    username=${GNB_ASIK.Username}    password=${GNB_ASIK.Password}    alias=connection_gnb
    ${unit0_type}    csn.Execute    command=ddal -s ddal_sysinfo_module_get_unit_id 0|grep value=|cut -f 2 -d '=' | awk -F "'" '{print $2}'
    ...     connection=connection_gnb
    ${unit1_type}    csn.Execute    command=bsh 1:0 ddal -s ddal_sysinfo_module_get_unit_id 0|grep value=|cut -f 2 -d '=' | awk -F "'" '{print $2}'
    ...    connection=connection_gnb
    ${setup_type}    csn.Execute    command=echo "tag -a" | nc 0 15007 | grep L1Bypass    connection=connection_gnb
    ${setup_type}    Run keyword If    '${setup_type}'=='${EMPTY}'    Set Variable    Fullstack
    ...    ELSE    Set Variable    L1Bypass
    ${unit0_type}    Split String    ${unit0_type}
    ${unit1_type}    Split String    ${unit1_type}
    [Return]    ${unit0_type}    ${unit1_type}    ${setup_type}

Start CPRT Mon on classical gNB
    Log to Console    \n-----> Start CPRT Mon <-----
    ${unit0_type}    ${unit1_type}    ${setup_type}    Get_Hardware_unit_type
    Run keyword If    '${unit0_type}[0]'=='ASIM'     CPRT Monitoring Start ASIB
    Run keyword If    '${unit0_type}[0]'=='ASIL'     CPRT Monitoring Start ASIB
    Run keyword If    '${unit0_type}[0]'=='ASIB'     CPRT Monitoring Start ASIB
    Run keyword If    '${unit0_type}[0]'=='ASOE'     CPRT Monitoring Start ASOE

Stop and Collect CPRT Monitoring on classical gNB
    [Arguments]    ${log_path}
    Log to Console    \n-----> Stop and Collect CPRT Mon <-----
    Create Folder    ${log_path}/CPRTmon/
    ${unit0_type}    ${unit1_type}    ${setup_type}    Get_Hardware_unit_type
    Run keyword If    '${unit0_type}[0]'=='ASIM'     CPRT Monitoring Stop Collect ASIB     ${log_path}/CPRTmon/
    Run keyword If    '${unit0_type}[0]'=='ASIL'     CPRT Monitoring Stop Collect ASIB     ${log_path}/CPRTmon/
    Run keyword If    '${unit0_type}[0]'=='ASIB'     CPRT Monitoring Stop Collect ASIB     ${log_path}/CPRTmon/
    Run keyword If    '${unit0_type}[0]'=='ASOE'     CPRT Monitoring Stop Collect ASOE     ${log_path}/CPRTmon/

#========================DCAP Keywords Sections===============================
Initiate Dcap
    Start DCAP Containers

Start DCAP Containers
    Start Process      DCAP_Basic_controller   start          alias=start_dcap
    ${result}=         Wait For Process        start_dcap
    Log to console     ${result.stdout}
    Should contain     ${result.stdout}        All UTF Lab containers started successfully

DCAP Connect To gNB
    ${command}     Set Variable     sudo ifconfig eth0|awk -F "[ :]+" 'NR==2 {print $3}'
    ${eth0_vm_ip}      Run     ${command}
    Open Connection to gNB      ${eth0_vm_ip}    ${vDU_NODE_HOST}    ${vDU_NODE_PASSWORD}
    ...    ${vCU_NODE_HOST}    ${vCU_NODE_PASSWORD}    ${vDU_NODE_USER}     ${vDU_NAMESPACE}

DCAP Disconnect To gNB
    Close Connection to gNB    ${vDU_NODE_HOST}    ${vDU_NODE_PASSWORD}    ${vCU_NODE_HOST}
    ...    ${vCU_NODE_PASSWORD}    ${vDU_NODE_USER}     ${vDU_NAMESPACE}

Start DCAP BIP
    [Arguments]     ${mtime}    ${CellId}=None
    Start Dcap BIP Trace      ${mtime}    ${CellId}

Stop And Collect DCAP BIP
    [Arguments]     ${log_dir}
    Stop Dcap BIP Trace
    Create Directory        ${log_dir}
    dcap_utilities.Extract Dcap Logs
    ...    dcap_zip_dir=/tmp/l1l2
    ...    output_dir=/tmp/new/
    Move Files      /tmp/new/*    ${log_dir}

Start DCAP Syslog
    Start DCAP Syslog Trace

Stop And Collect DCAP Syslog
   [Arguments]    ${log_dir}
   [Documentation]   Use this keyowrd to stop and collect the syslogs
   ...    Use "Start Dcap Syslog trace"--->to start the syslog
   Stop DCAP Syslog Trace
   Create Directory   ${log_dir}
   dcap_utilities.Extract Dcap Logs
   ...    dcap_zip_dir=/tmp/syslog
   ...    output_dir=/tmp/new/
   Move Files      /tmp/new/*    ${log_dir}

Start DCAP L2Component
    [Arguments]    ${L2comp}     ${CellId}=None
    Start Dcap L2Component Trace   ${L2comp}   ${CellId}

Start DCAP Vdu Controlplane Trace
    [Arguments]    ${CellId}=None
    start_vdu_controlplane    ${CellId}

Stop DCAP Vdu Controlplane Trace
    [Arguments]   ${log_dir}
    stop_vdu_controltrace
    Create Directory         ${log_dir}
    dcap_utilities.Extract Dcap Logs
   ...    dcap_zip_dir=/tmp/control
   ...    output_dir=/tmp/new/
    Move Files      /tmp/new/*    ${log_dir}
#    Remove File     ${log_dir}/*.zip

Start DCAP Vcu Controlplane Trace
    [Arguments]    ${CellId}=None
    start_vcu_controlplane    ${CellId}

Stop DCAP Vcu Controlplane Trace
    [Arguments]    ${log_dir}
    stop_vcu_controltrace
    Create Directory        ${log_dir}
    dcap_utilities.Extract Dcap Logs
   ...    dcap_zip_dir=/tmp/controlvcu
   ...    output_dir=/tmp/new/
   Move Files      /tmp/new/*    ${log_dir}
#   Remove File     ${log_dir}/*.zip

Start DCAP Vdu CellTarce
    [Arguments]    ${CellId}=None
    start_vdu_celltrace    ${CellId}

Start DCAP Vcu CellTarce
    [Arguments]    ${CellId}=None
    start_vcu_celltrace    ${CellId}

Stop DCAP Vdu Celltrace
    [Arguments]    ${log_dir}
    stop_vdu_celltrace
    Create Directory         ${log_dir}
    dcap_utilities.Extract Dcap Logs
   ...    dcap_zip_dir=/tmp/celltrace
   ...    output_dir=/tmp/new/
    Move Files      /tmp/new/*    ${log_dir}

Stop DCAP Vcu Celltrace
    [Arguments]    ${log_dir}
    stop_vcu_celltrace
    Create Directory         ${log_dir}
    dcap_utilities.Extract Dcap Logs
   ...    dcap_zip_dir=/tmp/celltracevcu
   ...    output_dir=/tmp/new/
    Move Files      /tmp/new/*    ${log_dir}

Stop And Collect Dcap L2Component
   [Arguments]    ${log_dir}
   Stop Dcap L2Component Trace
   Create Directory   ${log_dir}
   dcap_utilities.Extract Dcap Logs
   ...    dcap_zip_dir=/tmp/TTITrace
   ...    output_dir=/tmp/new/
   Move File     /tmp/new/*.pcap   /tmp/new/tcpdump_ttitrace.pcap
   Move File     /tmp/new/tcpdump_ttitrace.pcap    ${log_dir}

Get DCAP Snapshot
   [Arguments]     ${log_dir}    ${CellId}=None
   Get Dcap Snapshot Trace   ${CellId}
   Create Directory   ${log_dir}
   Move Files      /tmp/SnapshotTrace/*    ${log_dir}

Start DCAP IpCapture
	[Arguments]		${capturepoint}=A		${uplane_iface}=False
	${capture_point}	Run Keyword If		'${capturepoint}'=='A'		Set Variable	NE_terminated	ELSE
	...		Set Variable	Transport_Interface
    Start Dcap Ipcapture Trace		${capture_point}		${uplane_iface}

Stop_and_Collect_Dcap_IpCapture
   [Arguments]    ${log_dir}
   [Documentation]   Use this keyowrd to stop and collect the ipcapture
   ...    Use "Start Dcap IP trace"--->to start the IPcapture
   Stop Dcap Ipcapture Trace
   Create Directory   ${log_dir}
   Create Directory   /tmp/new/
   dcap_utilities.Extract Dcap Logs
   ...    dcap_zip_dir=/tmp/ip_capturelog/
   ...    output_dir=/tmp/new/
   ...    logs_to_collect=['ipCapture']
   Move Files      /tmp/new/*    ${log_dir}

Start Log Via DCAP
    [Arguments]    @{log_name_list}     ${Bip_monitoring_time}=5    ${CellId}=None    ${component}=${l2comp}
    ...     ${capturepoint}=A		${uplane_iface}=False
    [Documentation]    This keyword is to start to capture logs.
    FOR    ${log}    IN    @{log_name_list}
        ${log}    String.Convert To Lowercase    	${log}
        Run Keyword If    '${log}'=='btslog'      	Start DCAP Syslog
        Run Keyword If    '${log}'=='bip'         	Start DCAP BIP     ${Bip_monitoring_time}    ${CellId}
        Run Keyword If    '${log}'=='ttitrace'  	    Start DCAP L2Component      ${component}     ${CellId}
        Run Keyword If    '${log}'=='ipcapture'        Start DCAP Ipcapture		${capturepoint}		${uplane_iface}
        Run Keyword If    '${log}'=='vducontrolplane'        Start DCAP Vdu Controlplane Trace		${CellId}
        Run Keyword If    '${log}'=='vcucontrolplane'        Start DCAP Vcu Controlplane Trace		${CellId}
        Run Keyword If    '${log}'=='vducelltrace'        Start DCAP Vdu CellTarce		${CellId}
        Run Keyword If    '${log}'=='vcucelltrace'        Start DCAP Vcu CellTarce		${CellId}
    END

Stop Log Via DCAP
    [Arguments]    @{log_name_list}    ${test_scenario}=${EMPTY}    ${CellId}=None
    [Documentation]    This keyword is to stop logs.
    ${common_log_path}      Create Dictionary
    FOR    ${log}    IN    @{log_name_list}
        ${log}    String.Convert To Lowercase    ${log}
        ${log_dir_gnb}           Set Variable          ${LOG_PATH}/${TEST_NAME}/gNB/${log}/${test_scenario}
        Set suite Variable       ${log_dir_gnb}
        ${log_dir_ap}           Set Variable          ${LOG_PATH}/${TEST_NAME}/AP/${log}/${test_scenario}
        Set suite Variable       ${log_dir_ap}
        Run Keyword If    '${log}'=='btslog'      Stop And Collect DCAP Syslog    log_dir=${log_dir_gnb}
        Run Keyword If    '${log}'=='bip'         Stop And Collect DCAP BIP           log_dir=${log_dir_gnb}
        Run Keyword If    '${log}'=='ttitrace'      Stop And Collect Dcap L2Component     log_dir=${log_dir_gnb}
        Run Keyword If    '${log}'=='snapshot'    Get DCAP Snapshot    CellId=${CellId}    log_dir=${log_dir_gnb}
        Run Keyword If    '${log}'=='ipcapture'      Stop And Collect Dcap Ipcapture     log_dir=${log_dir_gnb}
        Run Keyword If    '${log}'=='vducontrolplane'      Stop DCAP Vdu Controlplane Trace      log_dir=${log_dir_gnb}
        Run Keyword If    '${log}'=='vcucontrolplane'      Stop DCAP Vcu Controlplane Trace     log_dir=${log_dir_gnb}
        Run Keyword If    '${log}'=='vducelltrace'      Stop DCAP Vdu Celltrace     log_dir=${log_dir_gnb}
        Run Keyword If    '${log}'=='vcucelltrace'      Stop DCAP Vcu Celltrace    log_dir=${log_dir_gnb}
#        ...     ELSE
#        ...     Set To Dictionary     ${common_log_path}        ${log}       ${log_dir_gnb}
        Set To Dictionary     ${common_log_path}        ${log}       ${log_dir_gnb}
    END
    [Return]        ${common_log_path}

#======================DCAP Keywords End========================================

Prepare TL with all config files
     Log To Console    Configure ENV with SCFC/AP.xml/LUA
     add gnb configuration    scfc=${SCFC}
     add simulator  sim_type=airphone  config=${AP_XML}
#     add 5gc  config=${BASIC_CFG}  edaemon_ports=10000
     configure environment       rmod_detection_timeout=300s
     Log To Console    After Configure ENV

Prepare TL with IPHY file change
     Log To Console    Configure ENV with AP.xml
     add simulator  sim_type=airphone  config=${AP_XML}
     configure environment       rmod_detection_timeout=300s
     Log To Console    After Configure ENV

Prepare TL with SCF change
     Log To Console    Configure ENV with SCFC
     add gnb configuration    scfc=${SCFC}
     configure environment       rmod_detection_timeout=300s
     Log To Console    After Configure ENV
