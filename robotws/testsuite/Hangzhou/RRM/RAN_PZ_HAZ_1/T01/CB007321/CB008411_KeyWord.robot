*** Settings ***

Documentation     Keywords related to CB012629
Library     ute_wtssim
Library     String
Library     OperatingSystem
Library     Collections
Library     ta5g_ue_measurements
Resource          ../../Resources/Classical/RRM_Common_Resource.robot

*** Variables ***
${nsetapx_plugin_addr}
...   ...  https://artifactory-hz1.int.net.nokia.com/artifactory/wslte5g_plugins-local/NSETAP_X/nsetapx-1.13.4
${mcshark_plugin_addr}
...   https://artifactory-hz1.int.net.nokia.com/artifactory/wslte5g_plugins-local/MCShark
${plugin_folder}   /usr/lib/x86_64-linux-gnu/wireshark/plugins
${plugin_folder_utevm}   /home/ute/.local/lib/wireshark/plugins
@{cuup_tracerecords}   nsetapx.CuUpVendorExtensionRecordDataType == dlRbPdcpThroughputRecord
...   nsetapx.CuUpVendorExtensionRecordDataType == bearerCtxSetupRecord
...   nsetapx.CuUpVendorExtensionRecordDataType == bearerRecord
...   nsetapx.CuUpVendorExtensionRecordDataType == pduSessionResourceInfoRecord
...   nsetapx.CuUpVendorExtensionRecordDataType == ulRbPdcpMeasRecord
...   nsetapx.CuUpVendorExtensionRecordDataType == dlRbPdcpMeasRecord

@{cuup_throughput_tracerecords}   nsetapx.CuUpVendorExtensionRecordDataType == dlRbPdcpThroughputRecord
...   nsetapx.CuUpVendorExtensionRecordDataType == ulRbPdcpMeasRecord
...   nsetapx.CuUpVendorExtensionRecordDataType == dlRbPdcpMeasRecord
@{cucp_tracerecords}   nsetapx.CuVendorExtensionRecordDataType == pduSessionResourceInfoRecord
...    nsetapx.CuVendorExtensionRecordDataType == ueDuConnectivityRecord
...    nsetapx.CuVendorExtensionRecordDataType == rrcSetupRecord
...    nsetapx.CuVendorExtensionRecordDataType == ueInfoRecord
...    nsetapx.CuVendorExtensionRecordDataType == ueSetupRecord
...    nsetapx.CuVendorExtensionRecordDataType == bearerRecord
@{cucp_ca_tracerecords}   nsetapx.CuVendorExtensionRecordDataType == pduSessionResourceInfoRecord
...    nsetapx.CuVendorExtensionRecordDataType == ueDuConnectivityRecord
...    nsetapx.CuVendorExtensionRecordDataType == rrcSetupRecord
...    nsetapx.CuVendorExtensionRecordDataType == ueInfoRecord
...    nsetapx.CuVendorExtensionRecordDataType == ueSetupRecord
...    nsetapx.CuVendorExtensionRecordDataType == caConfigurationRecord
...    nsetapx.CuVendorExtensionRecordDataType == ueMeasRecord
${cucp_mea_tracerecords}   nsetapx.CuVendorExtensionRecordDataType == ueMeasRecord
${f1ap_trace_activate_minimum}   f1ap.traceDepth == minimum
${f1ap_trace_activate_medium}   f1ap.traceDepth == medium
${f1ap_trace_activate_maximum}   f1ap.traceDepth == maximum
${f1ap_trace_activate_min_without_vse}   f1ap.traceDepth == minimumWithoutVendorSpecificExtension
${f1ap_trace_activate_med_without_vse}   f1ap.traceDepth == mediumWithoutVendorSpecificExtension
${f1ap_trace_activate_max_without_vse}   f1ap.traceDepth == maximumWithoutVendorSpecificExtension

*** Keywords ***
Case Precondition
    [Arguments]   ${operation}=env_setup_sansa   ${tag}=CLOUD_5G_I_LO_AP_LO
    Airphone Operation  edaemon_egate_setup  gnb  tag=${tag}
    Airphone Operation  ${operation}  gnb  tag=${tag}
    OperatingSystem.Run     DCAP_Basic_controller start
    Download wireshark plugin

Update UE capa
    [Arguments]    ${ue_id}    ${SA_Capa_perUE_Full}=none
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full}
    Airphone Execute Egate Command    cmd=${cmd}

UE Register And PDU Session Setup
    [Arguments]    ${ue_id}=1  ${gnb_id}=2  ${cell_id}=1   ${pass_regexp}=QoS Routing Table
    ${cmd}    catenate    amf_ue_ics_param id=1 core_network_assistance_info=on ue_identity_index_value=${ue_id} ue_specific_drx=64
    ...    periodic_registration_update_timer=1:10min plmn_id=311:489 tac_id=200
    Airphone Execute Egate Command    cmd=ue_change_location id=${ue_id} enb=${gnb_id} cell=${cell_id}
    Airphone Execute Egate Command    cmd=${cmd}
    Airphone Execute Egate Command    cmd=ue_register id=${ue_id}    pass_regexp=UE now in NG RM Register
    Airphone Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Airphone Execute Egate Command    cmd=ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=1    pass_regexp=${pass_regexp}

UE Modify new PDU
    [Arguments]    ${ue_id}=1    ${pdu}=1   ${qosflows_to_add}=2   ${pass_regexp}=QoS Routing Table
    Airphone Execute Egate Command
    ...    cmd=ue_pdu_session_modify ue=${ue_id} pdu=${pdu} qosflows_to_add=${qosflows_to_add} by=amf    pass_regexp=${pass_regexp}

UE setup new PDU
    [Arguments]    ${ue_id}=1    ${pdu}=2    ${nwslice}=2    ${gateway}=2    ${pass_regexp}=QoS Routing Table
    Airphone Execute Egate Command   cmd=set_pdu_param ue=${ue_id} pdu=${pdu} trf_type=internal
    Airphone Execute Egate Command   cmd=ue_pdu_session_setup ue=${ue_id} pdu=${pdu} nwslice=${nwslice} gw=${gateway}    pass_regexp=${pass_regexp}

Trigger RRC Resume
    [Arguments]    ${ue_id}=1  ${gnb_id}=2  ${cell_id}=1  ${msg}=${EMPTY}  ${cause}=mt_Access   ${pass_regexp}=none   ${action}=${EMPTY}
    sleep    2s    #sleep for inactive precedure complete
    Airphone Execute Egate Command
    ...       cmd=ue_nr_rrc_resume_request_param id=${ue_id} gnb=${gnb_id} cell=${cell_id} msg=${msg} cause=${cause} action=${action}
    Airphone Execute Egate Command    cmd=ue_nr_rrc_resume id=${ue_id}    pass_regexp=${pass_regexp}

Trigger RRC Resume wo Action
    [Arguments]    ${ue_id}=1  ${gnb_id}=2  ${cell_id}=1  ${msg}=${EMPTY}  ${cause}=mt_Access   ${pass_regexp}=none
    sleep    2s    #sleep for inactive precedure complete
    Airphone Execute Egate Command
    ...       cmd=ue_nr_rrc_resume_request_param id=${ue_id} gnb=${gnb_id} cell=${cell_id} msg=${msg} cause=${cause}
    Airphone Execute Egate Command    cmd=ue_nr_rrc_resume id=${ue_id}    pass_regexp=${pass_regexp}

Send UAI to gNB
    [Arguments]    ${ue_id}=1    ${state}=inactive    ${pass_regexp}=none
    Airphone Execute Egate Command    cmd=ue_assistance_send_nr ue_id=${ue_id} PreferredRRCState=${state}    pass_regexp=${pass_regexp}

UE Deregister From gNB
    [Arguments]    ${ue_id}=1
    Airphone Execute Egate Command   cmd=ue_deregister id=${ue_id} ue_deregister_type=switch_off
    sleep   15s


Multi UE Detach
   [Arguments]    ${start}=1   ${num}=6
   sleep  5s
   FOR  ${ue_id}    IN RANGE    ${start}    ${num}
        UE Deregister From gNB    ue_id=${ue_id}
   END

Multi UE ICS With Trace Stop
   [Arguments]    ${start}=1   ${num}=6
   sleep  2s
   FOR  ${ue_id}    IN RANGE    ${start}    ${num}
        Trigger ICS With Trace Stop    ue_id=${ue_id}
   END

Start data traffic in egate
    [Arguments]   ${ue_id}=${EMPTY}   ${direction}=ul  ${protocol}=udp   ${ack_mode}=off   ${trf_id}=1  ${qfi}=1
    ...   ${cl_trf_stats}=on    &{kwargs}
    ${command}   Catenate
    ...   trf_data_start ue=${ue_id} dir=${direction} trf_id=${trf_id}
    ...   protocol=${protocol} ack_mode=${ack_mode} cl_trf_stats=${cl_trf_stats}
    ...   pdu=1 qfi=${qfi} mbps=10
    Airphone Operation    operation=send_common_command
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=${command}
    ...                   pass_regexp=${None}
    ...                   timeout=100s

Stop data traffic in egate
    [Arguments]   ${ue_id}=1   ${direction}=ul   ${trf_id}=1   ${pass_regexp}=none   &{kwargs}
    Send Egate Command and verify output   cmd=trf_data_stop ue=${ue_id} dir=${direction} trf_id=${trf_id} pdu=1 qfi=1
    ...   pass_regexp=${pass_regexp}

Start traffic to Active
    [Arguments]   ${ue_id}=1
    Airphone Execute Egate Command    cmd=data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=1 mbps=100
    Airphone Execute Egate Command    cmd=data_trf_start ue=${ue_id} pdu=2 qfi=1 dir=dl trf_id=2 mbps=100
    Airphone Execute Egate Command    cmd=data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=ul trf_id=3 mbps=10
    Airphone Execute Egate Command    cmd=data_trf_start ue=${ue_id} pdu=2 qfi=1 dir=ul trf_id=4 mbps=10

Start traffic to 5QI5 and 5QI1
    [Arguments]    ${ue_id}=23   ${pdu}=1
    Airphone Execute Egate Command
    ...    cmd=trf_data_start ue=${ue_id} pdu=${pdu} qfi=1 dir=dl trf_id=1 protocol=tcp seconds=6000
    Airphone Execute Egate Command
    ...    cmd=trf_data_start ue=${ue_id} pdu=${pdu} qfi=1 dir=ul trf_id=2 protocol=tcp seconds=6000
    Airphone Execute Egate Command
    ...    cmd=trf_data_start ue=${ue_id} pdu=${pdu} qfi=2 dir=dl trf_id=1 rtp_codec=amr_wb_18_25 seconds=6000
    Airphone Execute Egate Command
    ...    cmd=trf_data_start ue=${ue_id} pdu=${pdu} qfi=2 dir=ul trf_id=2 rtp_codec=amr_wb_18_25 seconds=6000

Check traffic for 5QI5 and 5QI1
    [Arguments]    ${ue_id}=23   ${pdu}=1
    Airphone Execute Egate Command      cmd=qfi_stats ue=${ue_id} pdu=${pdu} qfi=1 dir=dl    pass_regexp=Parameter
    Airphone Execute Egate Command      cmd=qfi_stats ue=${ue_id} pdu=${pdu} qfi=1 dir=ul    pass_regexp=Parameter
    Airphone Execute Egate Command      cmd=qfi_stats ue=${ue_id} pdu=${pdu} qfi=2 dir=dl    pass_regexp=Parameter
    Airphone Execute Egate Command      cmd=qfi_stats ue=${ue_id} pdu=${pdu} qfi=2 dir=ul    pass_regexp=Parameter

Get Measurement id
    [Arguments]  ${ue_id}=1   ${event_type}=A2  ${carrierfreq}=633216    ${threshold}=38
    ${meas_id}    Get Nr Meas Id For Specific Type And Frequency   ${ue_id}
    ...    event_type=${event_type}   carrierfreq=${carrierfreq}    threshold=${threshold}
    [Return]     ${meas_id}

Trigger Measurement Report
    [Arguments]    ${ue_id}=1   ${meas_id}=3  ${event_type}=A2    ${srsrp_nr}=7    ${srsrq_nr}=7
    ${cmd}    Catenate    ue_measurement_send_nr    id=${ue_id}    meas_id=${meas_id}   event=${event_type}
    ...    srsrp_nr=${srsrp_nr}    srsrq_nr=${srsrq_nr}
    Airphone Operation    send_common_command  gnb  cmd=${cmd}  pass_regexp=measurementReport  timeout=30s

Trigger Inter-gNB Inter-Freq HO
    [Arguments]  ${ue_id}=1   ${carrier_freq_source}=633216   ${carrier_freq_target}=633408   ${pass_regexp}=none
    ${meas_id_A2}=    Get Measurement Id    ue_id=${ue_id}    event_type=A2   carrier_freq=${carrier_freq_source}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id_A2} event=A2 srsrp_nr=11 srsrq_nr=11 srs_result=0:11:11:0
    Airphone Execute Egate Command      cmd=${cmd}
    ${meas_id_A3}=    Get Measurement Id    ue_id=${ue_id}    event_type=A3   carrier_freq=${carrier_freq_target}
    ${cmd}    catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id_A3} event=A3 srsrp_nr=11 phycell_id=381 nrsrp_nr=85
    Airphone Execute Egate Command     cmd=${cmd}    pass_regexp=${pass_regexp}

Trigger HO Back from SiM to Real
    [Arguments]  ${ue_id}=1  ${event_type}=A2  ${carrier_freq}=633216   ${pass_regexp}=none
    ${meas_id_A3}    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrier_freq}    event_type=${event_type}
    Airphone Execute Egate Command    cmd=ue_measurement_send_nr id=${ue_id} meas_id=${meas_id_A3} event=A3 srsrp_nr=30 phycell_id=50 nrsrp_nr=80
    ...    pass_regexp=${pass_regexp}

Stop traffic to Inactive
    [Arguments]   ${ue_id}=1   ${pass_regexp}=none
    Airphone Execute Egate Command    cmd=trf_data_stop ue=${ue_id} pdu=1
    Airphone Execute Egate Command    cmd=trf_data_stop ue=${ue_id} pdu=2    pass_regexp=${pass_regexp}   timeout=21s

Send Egate Command and verify output
    [Documentation]
    [Arguments]   ${cmd}   ${timeout}=65   ${return_output}=${True}   ${pass_regexp}=${None}   ${fail_regexp}=${None}
    ${output}   ute_wtssim.execute egate command and wait for data
    ...   cmd=${cmd}   pass_regexp=${pass_regexp}   fail_regexp=${fail_regexp}
    ...   timeout=${timeout}   return_output=${return_output}
    [Return]   ${output}

Setup Xn Link To gNB
    [Arguments]    ${gnb_id}=3    ${pass_regexp}=none
    Airphone Execute Egate Command   cmd=gnb_param id=${gnb_id} xn_listening_socket=1 send_xn_setup=true sib1_period=160ms
    Airphone Execute Egate Command
    ...    cmd=gnb_xn_link_up gnb=${gnb_id} target=2    pass_regexp=${pass_regexp}

Start Subscriber Trace
    [Arguments]    ${ue_id}=1   ${tce_ip}=10.0.1.1
    ...            ${trace_depth}=minimum
    ...            ${ifaces_to_trace}=Uu,NG-C,Xn-C,F1-C,E1
    ...            ${trace_plmn}=311:489
    ...            ${trace_rec_session_ref_id}=1
    ...            ${trace_ref_id}=1
    ${command} =  catenate  SEPARATOR=
    ...           ng_ue_trace_start id=${ue_id}
    ...           \ tce_ip=${tce_ip}
    ...           \ trace_depth=${trace_depth}
    ...           \ ifaces_to_trace=${ifaces_to_trace}
    ...           \ trace_plmn=${trace_plmn}
    ...           \ trace_rec_session_ref_id=${trace_rec_session_ref_id}
    ...           \ trace_ref_id=${trace_ref_id}
    Execute Egate Command      cmd=${command}

Trigger ICS With Trace Start
    [Arguments]    ${ue_id}=1  ${trace_ref_id}=1
    ...            ${trace_rec_session_ref_id}=1
    ...            ${trace_depth}=minimum
    ...            ${ifaces_to_trace}=Uu,NG-C,Xn-C,F1-C,E1
    ...            ${tce_ip}=10.0.1.1
    ...            ${trace_plmn}=311:489
    ${command} =  catenate   SEPARATOR=
    ...           amf_ue_ics_param id=1 ue=${ue_id} object_id=1 location_reporting_reference_id=1 trace_activation=on trace_plmn=${trace_plmn}
    ...           \ trace_ref_id=${trace_ref_id}
    ...           \ trace_rec_session_ref_id=${trace_rec_session_ref_id}
    ...           \ trace_depth=${trace_depth}
    ...           \ ifaces_to_trace=${ifaces_to_trace}
    ...           \ tce_ip=${tce_ip}
    Execute Egate Command      cmd=${command}

Trigger ICS With Trace Stop
    [Arguments]    ${ue_id}=1
    ${command_off} =  catenate   SEPARATOR=
    ...           amf_ue_ics_param id=1 ue=${ue_id} object_id=1 location_reporting_reference_id=1 trace_activation=off
    Execute Egate Command    cmd=${command_off}

Activate or Deactivate Trace Report
    [Arguments]       ${actPCMDReport}=true   ${actSubscriberTraceReport}=true
     @{para_list}   Create List   actPCMDReport    actSubscriberTraceReport
     @{value_list}   Create List   ${actPCMDReport}   ${actSubscriberTraceReport}
     @{mo_list}   Create List    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}   MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
     ${res}   Parameter Operation    operation=parameter_update   product_type=gnb   para_list=${para_list}
     ...      value_list=${value_list}   mo_list=${mo_list}

Add or Delete A New MOC
     [Arguments]     ${moc_jason}=default.json    ${product_type}=gnb
     #NRSTRACEDU
     ${delta_file_path}   Set Variable   ${CURDIR}/config/${moc_jason}
     ${res}   Parameter Operation    operation=delta_plan_update   product_type=${product_type}   delta_file_path=${delta_file_path}

Start Collect Wireshark For GNB
    [Arguments]     ${bts_index}=${0}    ${interface}=any
    ${wireshark_argument}   Create Dictionary   wireshark_options=-i ${interface}
    ${dict_argument}   Create Dictionary   argument=${wireshark_argument}
    Log Collection    start    wireshark    product_type=gnb    bts_index=${bts_index}    dict_argument=${dict_argument}

Stop Wireshark log For GNB
    [Arguments]     ${bts_index}=${0}
    ${local_file_path}    Log Collection    stop_and_download    wireshark    product_type=gnb    bts_index=${bts_index}
    [Return]    ${local_file_path}

Check multi tracerecords
    [Arguments]     ${tracerecords}    ${host}=10.0.1.1   ${traceId}=00:00:01    ${capture_file_path}=none
    FOR   ${tracerecords_index}   IN   @{tracerecords}
       ${tracerecord}   Check tracerecords    tracerecords=${tracerecords_index}   host=${host}   traceId=${traceId}
       ...   capture_file_path=${capture_file_path}
       Should Not Be Empty     ${tracerecord}
   END

Check tracerecords
    [Arguments]    ${tracerecords}    ${host}=mba   ${traceId}=00:00:01    ${capture_file_path}=none
	${traceMessage}  Set Variable    'nsetapx.traceActivationType == ${host} && ${tracerecords} && nsetapx.traceId == ${traceId}'
    ${traceMessage_result} =    Decode tcpdump	   input_file=${capture_file_path}
	...                                            filter_expression=${traceMessage}
    [Return]     ${traceMessage_result}

Decode tcpdump
    [Arguments]    ${input_file}=${capture_file_path}    ${filter_expression}=esp.sequence == 115
    ${tshark_comd}  catenate    tshark -r ${input_file} -o ntrstr.defragment:TRUE  -d tcp.port==49151,ntrstr
    ...  -d tcp.port==49148,ntrstr -d tcp.port==15000-15500,ntrstr -Y ${filter_expression}
    ${filtered_packets}    Run    ${tshark_comd}
    [Return]    ${filtered_packets}

Check common tracerecords
    [Arguments]    ${tracerecords}      ${capture_file_path}=none
	${traceMessage}  Set Variable    '${tracerecords}'
    ${traceMessage_result} =    Decode tcpdump	   input_file=${capture_file_path}
	...                                            filter_expression=${traceMessage}
    Should Not Be Empty     ${traceMessage_result}

Check no tracerecords
    [Arguments]     ${tracerecords}    ${host}=mba   ${traceId}=00:00:01    ${capture_file_path}=none
    FOR   ${tracerecords_index}   IN   @{tracerecords}
       ${tracerecord}   Check tracerecords    tracerecords=${tracerecords_index}   host=${host}   traceId=${traceId}
       ...   capture_file_path=${capture_file_path}
       Should Be Empty     ${tracerecord}
   END

Download wireshark plugin
    sleep    5s
    ${ver}   Run   ls ${plugin_folder}/
    ${exist}   Run   cd ${plugin_folder}/${ver}/epan;ls nsetapx*
    ${exist_mcshark}   Run   cd ${plugin_folder}/${ver}/epan;ls mcshark*
#    ${exist_utevm}   Run   cd ${plugin_folder_utevm}/${ver}/epan;ls nsetapx*
    Run   cd ${plugin_folder}/${ver}/epan;sudo rm mcshark*
    Run   cd ${plugin_folder}/${ver}/epan;sudo rm nsetapx*
    ${mcshark_plugin_path}   Generate Mcshark path
    ${cmd_1}=    Catenate    wget -r -np -nH  ${nsetapx_plugin_addr}/ -P /home/ute/nsetapx
    ${cmd_2}=    Catenate    wget -r -np -nH  ${mcshark_plugin_path}/ -P /home/ute/mcshark
    Run Keyword If    not os.path.exists("/home/ute/nsetapx")   Run  cd /home/ute/;sudo mkdir nsetapx
    Run  cd /home/ute/;sudo chmod 777 nsetapx
    OperatingSystem.Run    command=cd /home/ute/nsetapx
    OperatingSystem.Run    command=sudo rm -rf /home/ute/nsetapx/artifactory
    OperatingSystem.Run    command=${cmd_1}
    Run Keyword If    not os.path.exists("/home/ute/mcshark")   Run  cd /home/ute/;sudo mkdir mcshark
    Run  cd /home/ute/;sudo chmod 777 mcshark
    OperatingSystem.Run    command=cd /home/ute/mcshark
    OperatingSystem.Run    command=sudo rm -rf /home/ute/mcshark/artifactory
    OperatingSystem.Run    command=${cmd_2}
    ${nsetapx_plugin_addr_local}  Replace String    ${nsetapx_plugin_addr}   https://artifactory-hz1.int.net.nokia.com
    ...  /home/ute/nsetapx
    ${nsetapx_plugin_path}=    Run Keyword If   "${ver}"=="4.2"  Catenate   ${nsetapx_plugin_addr_local}/nsetapx-${ver}-*rocky08.so
    ...   ELSE
    ...   Catenate   ${nsetapx_plugin_addr_local}/nsetapx-${ver}-*buster.so
    OperatingSystem.Run    command=sudo cp ${nsetapx_plugin_path} ${plugin_folder}/${ver}/epan
    ${mcshark_plugin_addr_local}  Replace String    ${mcshark_plugin_path}   https://artifactory-hz1.int.net.nokia.com
    ...  /home/ute/mcshark
    ${mcshark_plugin_path}=    Run Keyword If   "${ver}"=="4.2"  Catenate   ${mcshark_plugin_addr_local}/mcshark-${ver}-*rocky8.so
    ...   ELSE
    ...   Catenate   ${mcshark_plugin_addr_local}/mcshark-${ver}-*buster.so
    OperatingSystem.Run    command=sudo cp ${mcshark_plugin_path} ${plugin_folder}/${ver}/epan

Generate Mcshark path
    ${sw_list}    Split String    ${ACTIVE_SW_VERSION}    _
    ${sw_version}  Replace String    ${ACTIVE_SW_VERSION}   ${sw_list[0]}   ${RELEASE}
    ${output}    OperatingSystem.Run    command=tshark -v |grep TShark
    ${lst}    Get Regexp Matches    ${output}    v(\\d{1,3}\.\\d{1,3})\.\\d{1,3}   1
    ${tshark_version}=    set variable    ${lst}[0]
    ${mcshark_plugin_path}    Run Keyword If   "${tshark_version}"=="4.2"
    ...   Set Variable    ${mcshark_plugin_addr}/${sw_version}
    ...   ELSE
    ...   Set Variable   ${mcshark_plugin_addr}/${sw_version}
    [Return]    ${mcshark_plugin_path}
