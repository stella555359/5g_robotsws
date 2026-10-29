*** Settings ***
Documentation
...    author: 'Abderrahmane NEZROUK'
...    Team: 'MN RAN RD VRF NPS 2'
...    Email: 'Abderrahmane.nezrouk@nokia.com'

Library     taf.rfrl.bts.devices.du.commissioning.GnbCommissioning          WITH NAME   gnb_scf
Library     ute_tshark
Library     Process

Library     ../../resources/vrf_nps_2/python/utilities.py                   WITH NAME   utilities
Library     ../../resources/vrf_nps_2/python/pdml_analysis.py
Library     ../../resources/vrf_nps_2/python/syslog_analysis.py

*** Keywords ***
Activate Feature CB010361-A
    [Documentation]   This keyword will activate the feature CB010361-A
    ...   This keyword assumes that the BTS is Up and running and that the validation rules are defined.
    # ************* Activation of the Feature *************
    Set BTSLog Rad Parameters value    0x580129    0x3FFF    persistently=${True}
    Run Keyword If   "${WITH_FEATURE_ACTIVATION}" in ['yes', 'Yes', 'YES']
    ...   Activate CB010361 PCMD Feature

Deactivate Feature CB010361-A
    [Documentation]   This keyword will activate the feature CB010361-A
    ...   This keyword assumes that the BTS is Up and running and that the validation rules are defined.
    # ************* Activation of the Feature *************
    Run Keyword If   "${WITH_FEATURE_ACTIVATION}" in ['yes', 'Yes', 'YES']
    ...   Deactivate CB010361 PCMD Feature

CB010361-A Test Suite Setup
    [Documentation]   Prepare TL for CB010361-A test
    ...    backup TL configurations, Activate feature, prepare WTS config file for
    # Turn all DUs RUs TestLine PDU Power Position To   on
    Test Suite Preparation
    # ===========================================
    # TCP server Setup and Start
    TCP Server Setup
    #============================================
    # Validating Initial SCF
    Validate SCF Plan    ${PATH_Storage}/initial_conf_scf.xml
    Activating Energy Effecency Monitoring
    Activate Feature CB010361-A
    Backup SBTS Configuration    filename_prefix=current_conf
    # Validating current test SCF
    Validate SCF Plan    ${PATH_Storage}/current_conf_scf.xml
    ${Active_Alarms}=    Collect Active Alarms    alarms_path=${PATH_Storage}    alarms_prefix=current_
    Run Keyword If     ${Active_Alarms}
    ...    Fail  Warning BTS Alarm appear after feature activation, please check the logs.
    # ===========================================
    # utilities.Install Wireshark Plugin   ${ENB_BUILD}  force=${False}
    tti_tool_installer.Install_5g_ttitrace_tools    build_version=${ENB_BUILD}

CB010361-A Test Suite Teradown
    [Documentation]    This keyword is for CB010361 test suite teardown
    Run Keyword And Ignore Error    TCP Server Teardown
    Run Keyword And Ignore Error    Deactivate Feature CB010361-A
    Test Suite Teardown

A_B101_PCMD_Monitoring_MAC_Layer_Check
    [Documentation]    This keyword is for CB010361 test case
    [Arguments]   ${tput}  ${direction}
    ...           ${PCMD_COUNTER}=numOfPrbsUsed    ${protocol_name}=dlSchedulingRecord
    ...            ${filter_expression}=value and value != '0' and value != '0.0'

    Set Suite Variable  ${trace_name}  ${TEST NAME[9:]}
    # Starting Logs Collection
    ute_tshark.Setup Tshark        interface=eth0  preferences=ntrstr.defragment:TRUE ntrstr.port:${TCE_PORT_NUM}
    ...     log_dir=${res_path}/PCMD_REPORT  log_name=${trace_name}.pcap
    ...     ssh_username=localuser  ssh_password=10c@1user  alias=tshark
    Run Keyword And Continue On Failure  gnb_log.Start Collecting gNB Btslog
    ute_tshark.Start Capturing  capture_filter=tcp port ${TCE_PORT_NUM}  alias=tshark

    # *********** Attach & Traffic Scenario *******************
    Log To Console      Starting Test attached and Traffic Scenario
    Run keyword and ignore error
    ...           taf_ue.require_ue      ue_alias=${alias_1}     capabilities=REAL_ANDROID_UE
    Run keyword and ignore error
    ...           taf_ue.attach_ue       ue_alias=${alias_1}
    BuiltIn.Sleep     5s
    ${UE_INFO}=    taf_ue.Get UE Info    ${alias_1}    ALL
    Log To Console      Here is the Ue Info ${UE_INFO}
    BuiltIn.Sleep     5s
    taf_ue.Start Data Transfer  dt_name=dt_${alias_1}  ue_alias=${alias_1}  direction=${direction}  duration=60s
        ...    throughput=${tput}  protocol=${protocol}	 packet_size=${Packet_Size}
        ...    qci=${qci_dl}  buffer_client=${buffer_client}  buffer_server=${buffer_server}
    Builtin.Sleep     5s
    # Starting ttitrace collection
    tti_trace_collector.Start collecting TTI trace    capacity_unit_id=0  common_unit_id=0
    BuiltIn.Sleep     30s
    tti_trace_collector.Stop collecting TTI trace    capacity_unit_id=0   common_unit_id=0
    BuiltIn.Sleep     5s
    taf_ue.Await Data Transfer Finish    dt_${alias_1}
    # *********** waiting till Traffic Scenario finish *******************
    ute_tshark.Stop Capturing  alias=tshark
    ${result}    ${syslog_path}    Run Keyword And Ignore Error  gnb_log.Stop Collecting gNB Btslog  log_dir=${res_path}
    Run Keyword And Ignore Error  Collect IMS File  ${res_path}/IMS2/
    Run Keyword And Ignore Error  Verify Average Throughput With Deviation   dt_name=dt_${alias_1}   tput=${tput}
    ...                                  deviation=${deviation}
    Run Keyword And Continue On Failure  tti_trace_collector.Convert TTI traces to CSV    capacity_unit_id=0   common_unit_id=0
    OperatingSystem.Run  mkdir ${res_path}/ttitrace/
    Run Keyword And Continue On Failure  tti_trace_collector.Download TTI trace CSV logs   capacity_unit_id=0   common_unit_id=0
    ...  download_dir=${res_path}/ttitrace/    timeout=300
    # *********** Analysis of PCMD ***************************************
    Generate PCMD Reports    protocol_name=${protocol_name}
    ${column_name}=    Catenate   SEPARATOR=   nsetapx.  ${PCMD_COUNTER}
    ${filtred_csv}=    Analysis PCMD Report    protocol_name=${protocol_name}  column_name=${column_name}
    ...                 filter_expression=${filter_expression}
    ${numOfRecords}=     get length    ${filtred_csv}
    Run Keyword if  ${numOfRecords} == 0    Fail  No incrementation of PCMD counter nsetapx.${PCMD_COUNTER} was recorded.
    BuiltIn.Log   A Number of ${numOfRecords} of PCMD counter nsetapx.${PCMD_COUNTER} was recorded   console=True
    ${syslog_dir}=    utilities.get_folder_from_path  ${syslog_path}
    syslog_analysis.run_analysis
    ...    ${syslog_dir}
    ...    custom_patterns=${custom_patterns}
    ...    custom_msg_to_skip=${custom_msg_to_skip}
    ${syslog_msg}=    syslog_analysis.results_summary
    log    ${syslog_msg}    console=True

A_B101_PCMD_Monitoring_MAC_Layer_Check_WITH_Traffic_Burst_DL
    [Documentation]    This keyword is for CB010361 test case
    [Arguments]   ${PCMD_COUNTER}=numOfPrbsUsed    ${protocol_name}=dlSchedulingRecord
    ...            ${filter_expression}=value and value != '0' and value != '0.0'

    Set Suite Variable  ${trace_name}  ${TEST NAME[9:]}
    # Preparation of Iperf Server and Ue PC
    IperfSvrManager.Prepart Iperf Server
    ...    ${capabilities_1}
    ...    ${server_app}
    ...    ${EXECDIR}/testsuite/Paris/RRM/ST/resources/vrf_nps_2/bash_scripts/iperf_server_busrt_traffic.sh

    UePcManager.Prepare Ue PC    ${capabilities_1}    ${server_app}    ${alias_1}    cmd_timeout=${CMD_TIMEOUT}
    # Starting Logs Collection
    ute_tshark.Setup Tshark        interface=eth0  preferences=ntrstr.defragment:TRUE ntrstr.port:${TCE_PORT_NUM}
    ...     log_dir=${res_path}/PCMD_REPORT
    ...     log_name=${trace_name}.pcap
    ...     ssh_username=${tl.test_pcs[0].default_ssh_connection_details.username}
    ...     ssh_password=${tl.test_pcs[0].default_ssh_connection_details.password}
    ...     alias=tshark
    Run Keyword And Continue On Failure  gnb_log.Start Collecting gNB Btslog
    ute_tshark.Start Capturing  capture_filter=tcp port ${TCE_PORT_NUM}  alias=tshark

    # *********** Attach & Traffic Scenario *******************
    Log To Console      Starting Test attached and Traffic Scenario
    UePcManager.Attach Ue
    ${UE_IP}=    UePcManager.Get Ue Info    IP
    IperfSvrManager.Build Iperf Server Command
    ...    ${UE_IP}
    ...    cmd_timeout=${CMD_TIMEOUT}
    UePcManager.Start Iperf Client Command
    IperfSvrManager.Start Iperf Server Command
    BuiltIn.sleep    20s
    # Starting ttitrace collection
    tti_trace_collector.Start collecting TTI trace    capacity_unit_id=0  common_unit_id=0
    BuiltIn.Sleep     30s
    tti_trace_collector.Stop collecting TTI trace    capacity_unit_id=0   common_unit_id=0
    BuiltIn.Sleep     20s
    IperfSvrManager.Stop Iperf Server Command
    UePcManager.Stop Iperf Client Command
    # *********** waiting till Traffic Scenario finish *******************
    ute_tshark.Stop Capturing  alias=tshark
    ${result}    ${syslog_path}    Run Keyword And Ignore Error  gnb_log.Stop Collecting gNB Btslog  log_dir=${res_path}
    Run Keyword And Ignore Error  Collect IMS File  ${res_path}/IMS2/
    Run Keyword And Ignore Error  Verify Average Throughput With Deviation   dt_name=dt_${alias_1}   tput=${tput}
    ...                                  deviation=${deviation}
    Run Keyword And Continue On Failure  tti_trace_collector.Convert TTI traces to CSV    capacity_unit_id=0   common_unit_id=0
    OperatingSystem.Run  mkdir ${res_path}/ttitrace/
    Run Keyword And Continue On Failure  tti_trace_collector.Download TTI trace CSV logs   capacity_unit_id=0   common_unit_id=0
    ...  download_dir=${res_path}/ttitrace/    timeout=300
    # *********** Analysis of PCMD ***************************************
    Generate PCMD Reports    protocol_name=${protocol_name}
    ${column_name}=    Catenate   SEPARATOR=   nsetapx.  ${PCMD_COUNTER}
    ${filtred_csv}=    Analysis PCMD Report    protocol_name=${protocol_name}  column_name=${column_name}
    ...                 filter_expression=${filter_expression}
    ${numOfRecords}=     get length    ${filtred_csv}
    Run Keyword if  ${numOfRecords} == 0    Fail  No incrementation of PCMD counter nsetapx.${PCMD_COUNTER} was recorded.
    BuiltIn.Log   A Number of ${numOfRecords} of PCMD counter nsetapx.${PCMD_COUNTER} was recorded   console=True
    ${syslog_dir}=    utilities.get_folder_from_path  ${syslog_path}
    syslog_analysis.run_analysis
    ...    ${syslog_dir}
    ...    custom_patterns=${custom_patterns}
    ...    custom_msg_to_skip=${custom_msg_to_skip}
    ${syslog_msg}=    syslog_analysis.results_summary
    log    ${syslog_msg}    console=True

Generate PCMD Reports
    [Documentation]    This keyword will generate PDMD Report txt and pdml from pcap
    [Arguments]    ${protocol_name}=dlSchedulingRecord

    ${pdml_file}    Convert nsetapx trace to pdml
    ...      ${res_path}/PCMD_REPORT/${trace_name}.pcap
    ...      filter=nsetapx    port=${TCE_PORT_NUM}
    ...      dir_path=${res_path}/PCMD_REPORT
    ...      pdml_log_name=${trace_name}.pdml
    # ${resultat}=    Run  sed -i 's/,/./g' ${res_path}/PCMD_REPORT/${protocol_name}_${trace_name}.csv

    pdml_analysis.extract_data_from_pdml_to_csv   ${pdml_file}   nsetapx.${protocol_name}
    ...  nsetapx.numOfPrbsUsed
    ...  nsetapx.sumOfMcsIndexes
    ...  nsetapx.sumOfMacPduTxTime
    ...  nsetapx.sumOfInitTxTime
    ...  nsetapx.numOfInitTxSamples
    ...  nsetapx.sumOfMacPduRxTime
    ...  nsetapx.sumOfInitRxTime
    ...  nsetapx.numOfInitRxSamples
    ...  nsetapx.sumOfOverAirDelay


    Convert nsetapx trace to txt
    ...      ${res_path}/PCMD_REPORT/${trace_name}.pcap
    ...      filter=nsetapx    port=${TCE_PORT_NUM}
    ...      dir_path=${res_path}/PCMD_REPORT
    ...      txt_log_name=${trace_name}.txt

Analysis PCMD Report Old
    [Documentation]    This keyword for PCMD report contante
    [Arguments]    ${protocol_name}=ulSchedulingRecord  ${column_name}=nsetapx.numOfPrbsUsed
    ${cmd}      catenate    awk -F'\\t' -v col="${column_name}" 'NR > 1 { if ($col != 0) { count++ } } END { print count }'
    ...                    ${res_path}/PCMD_REPORT/nsetapx.${protocol_name}_${trace_name}.csv
    # Log to console    ${cmd}
    ${count}=    Run      ${cmd}
    [Return]    ${count}

Analysis PCMD Report
    [Documentation]    This keyword for PCMD report contante
    [Arguments]    ${protocol_name}=ulSchedulingRecord  ${column_name}=nsetapx.numOfPrbsUsed
    ...            ${filter_expression}=value and value != '0' and value != '0.0'

    ${filtred_csv}    pdml_analysis.filter_csv
    ...    ${res_path}/PCMD_REPORT/nsetapx.${protocol_name}_${trace_name}.csv
    ...    ${column_name}
    ...    filter_expression=${filter_expression}
    [Return]    ${filtred_csv}


Activate CB010361 PCMD Feature
    [Documentation]    This keyword will activate the feature CB010361
    ${delta_scf}=  Set Variable  ${PATH_Storage}/pcmd_activation.json
    OperatingSystem.copy file  ${EXECDIR}/testsuite/Paris/RRM/ST/CB010361_A/configs/${ENB_BRANCH}/pcmd_activation.json  ${delta_scf}
    utilities.update_json_file  ${delta_scf}  MRBTS-__MRBTS_ID__/MNL-1/TCEADM-1/TCE-1
    ...                         tceIpAddress=${TCE_IP_ADD}  tcePortNumber=${TCE_PORT_NUM}
    gnb_scf.perform_bts_delta_json_commissioning    delta_file=${delta_scf}    bts_id=0
    ...     du_id=0     skip_parameter_relation_errors=${false}    should_activate=${true}    timeout=${60}

Deactivate CB010361 PCMD Feature
    [Documentation]    This keyword will deactivate the feature CB010361
    ${delta_scf}=  Set Variable  ${PATH_Storage}/pcmd_deactivation.json
    OperatingSystem.copy file    ${EXECDIR}/testsuite/Paris/RRM/ST/CB010361_A/configs/${ENB_BRANCH}/pcmd_deactivation.json  ${delta_scf}
    gnb_scf.perform_bts_delta_json_commissioning    delta_file=${delta_scf}    bts_id=0
    ...     du_id=0     skip_parameter_relation_errors=${false}    should_activate=${true}    timeout=${60}

Check pcap file
    [Documentation]    This keyword check if the pcap file is empty
    [Arguments]       ${pcap_file}=None
    ${num}            OperatingSystem.Run    tshark -r ${pcap_file} 2>&1 | wc -l
    Run Keyword If    ${num} == 0   Fail  PCAP file contains no packets

Check TCE link is Up
    [Documentation]    This keyword check if the TCE server is up and running for test
    ${netstat}       OperatingSystem.Run   netstat -nt 2>/dev/null | grep :${TCE_PORT_NUM} | grep ESTABLISHED
    ${len}           Get Length   ${netstat}
    Run Keyword If   ${len} == 0   Fail  TCE link is still down

TCP Server Setup
    [Documentation]    This keyword will set up TCE server for test
    ${servertcp}=    Set Variable    %{HOME}/servertcp
    Set Suite Variable  ${servertcp}
    Create Directory      ${servertcp}
    Copy Files             ${EXECDIR}/testsuite/Paris/RRM/ST/resources/vrf_nps_2/tcp_server/*    ${servertcp}
    ${resultat}=    OperatingSystem.Run    /usr/bin/gcc ${servertcp}/server.c -o ${servertcp}/servertcp

TCP Server Start
    [Documentation]    This keyword will run TCP server for test
    ${servertcp} =    process.Start Process   nohup  ${servertcp}/servertcp  -p ${TCE_PORT_NUM}  &  shell=True
    BuiltIn.Sleep   5s
    ${server_pid} =    process.Get Process ID    ${servertcp}
    Run Keyword If    ${server_pid} == None    Fail    TCP Server process did not start successfully
    Set Suite Variable    ${server_pid}

TCP Server Stop
    [Documentation]    This keyword will stop TCP server for test
    process.Terminate Process    ${server_pid}

TCP Server Teardown
    [Documentation]    This keyword will set remove TCE server installation
    ${resultat}=    Run    rm -rf ${servertcp}

Convert nsetapx trace to txt
    [Arguments]  ${pcap_path}    ${filter}=nsetapx    ${port}=${TCE_PORT_NUM}
    ...          ${dir_path}=${OUTPUT_DIR}    ${txt_log_name}==L2PS_TTI_TRACE.txt
    [Documentation]    This keyword converts BIP logs pcap to txt file
    ${cmd}      catenate    tshark -o ntrstr.defragment:TRUE -o ntrstr.port:${port}
    ...         -Y '${filter}'
    ...         -n -V -r ${pcap_path} > ${dir_path}/${txt_log_name}
    ${rc}    OperatingSystem.Run And Return RC    ${cmd}

    [Return]  ${dir_path}/${txt_log_name}

Convert nsetapx trace to pdml
    [Arguments]  ${pcap_path}    ${filter}=nsetapx    ${port}=${TCE_PORT_NUM}
    ...          ${dir_path}=${OUTPUT_DIR}    ${pdml_log_name}==L2PS_TTI_TRACE.pdml
    [Documentation]    This keyword converts BIP logs pcap to txt file
    ${cmd}      catenate    tshark -o ntrstr.defragment:TRUE -o ntrstr.port:${port}
    ...         -Y '${filter}'
    ...         -T pdml -r ${pcap_path} > ${dir_path}/${pdml_log_name}
    ${rc}    OperatingSystem.Run And Return RC    ${cmd}

    [Return]  ${dir_path}/${pdml_log_name}

Convert nsetapx trace to csv
    [Arguments]    ${pcap_path}    ${filter}    ${columns}    ${dir_path}=${OUTPUT_DIR}
    ...            ${port}=48151    ${csv_log_name}=L2PS_TTI_TRACE.csv
    [Documentation]    This keyword converts BIP logs pcap to csv
    ...     -   :param pcap_path:       Path to BIP logs pcap
    ...     -   :param filter:          Filter (e.g. dldata_slottypereq || dldata_pdcchsendreq)
    ...     -   :param dir_path:        Path for output csv file (default OUTPUT_DIR)
    ...     -   :param csv_log_name:    csv file name (default BIP_Logs.csv)
    ...     -   :param columns:         Fields name to be collect in csv
    ...         (e.g. DlData_SlotTypeReq.SlotTypeReq.slot  DlData_SlotTypeReq.SlotTypeReq.slotType)

    Log to console    Converting BIP Log Pcap to csv...

    ${columns_string}    Catenate    SEPARATOR=${SPACE}-e${SPACE}  @{columns}
    ${cmd}      catenate    tshark -o ntrstr.defragment:TRUE -o ntrstr.port:${port}
    ...         -r ${pcap_path}
    ...         -Y "${filter}"
    ...         -T fields -e ${columns_string}
    ...         -E header=y -E separator=/t -E occurrence=a > ${dir_path}/${csv_log_name}
    ${rc}    OperatingSystem.Run And Return RC    ${cmd}

    Log to console    ...conversion done

    [Return]    ${dir_path}/${csv_log_name}
