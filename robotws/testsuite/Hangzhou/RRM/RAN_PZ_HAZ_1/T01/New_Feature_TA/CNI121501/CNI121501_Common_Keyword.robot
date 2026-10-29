*** Settings ***
Documentation     Keywords related to CB012629
*** Variables ***
${IgNBCAXpProtocol_Version}   40
${IgNBCAXgUProtocol_Version}  1
${DU-to-CU-RRCInfo}    SEPARATOR=100200c0000100c1400302000e00c240020100
${ExtDu-to-PrimeDu-RrcInfo}    SEPARATOR=
...    0044002880a360631078d167cb80042cdb40000019b193e8a81d29c028806b010a02190a20860c23286d9220064401b90018000080b290202
...    51003c0200240400498118140d484362194088512f08e54140188aa88008c00609d5000708879400e0402188001c221e38005c0c045100038
...    443c7000b8200862000708878e08170501144000e110f1c1020800000286181018202c0e0ba000e5000000001002000c04803305c00300800
...    0000280059f10082320400000000002800554d80800800000013d0050a51451e52853253c5463857ffc
&{dcap_info}    host=127.0.0.1    port=9443    username=${None}    password=${None}
${case_path}   /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T01/New_Feature_TA/CNI121501
*** Keywords ***
Case Precondition
     [Arguments]   ${operation}=env_setup_sansa   ${tag}=CLOUD_5G_I_LO_AP_LO    ${customer}=${NONE}
    Airphone Operation  edaemon_egate_setup  gnb  tag=${tag}
    Airphone Operation  ${operation}  gnb  tag=${tag}  customer=${customer}
    Airphone Operation  swconfig  gnb  tag=${tag}
    OperatingSystem.Run     DCAP_Basic_controller start

Setup Xn Link To gNB
    [Arguments]    ${gnb_id}=3
    ${cmd}    Catenate    gnb_param id=${gnb_id} xn_listening_socket=1 send_xn_setup=true sib1_period=160ms
    Airphone Operation    send_common_command  gnb  cmd=${cmd}
    ${cmd}    Catenate    gnb_xn_link_up gnb=${gnb_id} target=2
    Airphone Operation    send_common_command  gnb  cmd=${cmd}  pass_regexp=GNB-${gnb_id}: XnAP Link with GNB-2 .* is up

UE Attach To Target Cell
    [Arguments]   ${cell_id}=1   ${ue_id}=1
    ${traffic_info_dic}    Create Dictionary    call_type=SA    ue_id=${ue_id}    pdu_id=1    profile_id=1
    ...                                         cell_id=${cell_id}  gnb_id=0   call_type=SA   bearer_id=2
    Airphone Operation   attach  gnb  traffic_info_dic=${traffic_info_dic}

UE Attach and Send Traffic
    [Arguments]  ${cell_id}=1   ${ue_id}=1   ${pdu_id}=1   ${dir}=dlul
    ${traffic_info_dic}    Create Dictionary    call_type=SA    ue_id=${ue_id}    bearer_id=2    dir=${dir}
    ...                                     pdu_id=${pdu_id}    time_len=5s    trf_id=1    mbps_dl=178m    mbps_ul=10m
    ...                                     qfi_id=1    time=300    type=l3    profile_id=1   protocol=udp
    ...                                     gnb_id=0    cell_id=${cell_id}
    ${Tput_dict}    Airphone Operation    start_traffic  gnb   traffic_info_dic=${traffic_info_dic}  timeout=10s

Send And Verify Throughput
    [Arguments]    ${ue_id}=1
    Airphone Start Traffic   ue_id=${ue_id} trf_id=2  dir=dl
    Airphone Start Traffic   ue_id=${ue_id}  trf_id=1  dir=ul
    Airphone Get Average Throughput   ue_id=${ue_id}  trf_id=2
    Airphone Get Average Throughput   ue_id=${ue_id}  trf_id=1

Hold RRC Reconfiguration Complete
    [Arguments]    ${ue_id}=1   ${delay_time}=1000   ${contains}=any   ${nth}=1
    ${cmd}    Catenate   ue_nr_rrc_reconf_param id=${ue_id} if_contains=${contains} delay=${delay_time}   nth=${nth}
    Airphone Operation    send_common_command  gnb  cmd=${cmd}

Hold snode release Complete
    [Arguments]    ${ue_id}=1  ${gnb_id}=3  ${delay_time}=1000   ${contains}=delayed_rsp
    ${cmd}    Catenate   ue_gnb_snode_release_request_param  id=${ue_id} gnb_id=${gnb_id} action=${contains} delay=${delay_time}
    Airphone Operation    send_common_command  gnb  cmd=${cmd}



Get Measurement id
    [Arguments]  ${ue_id}=1   ${event_type}=A2  ${carrierfreq}=633216    ${threshold}=38
    ${meas_id}    Get Nr Meas Id For Specific Type And Frequency   ${ue_id}
    ...    event_type=${event_type}   carrierfreq=${carrierfreq}    threshold=${threshold}
    [Return]     ${meas_id}

Get Measurement id without threshold
    [Arguments]  ${ue_id}=1   ${event_type}=A2  ${carrierfreq}=633216   ${carrierfreq_rat}=NR
    ${meas_id}    Get Nr Meas Id For Specific Type And Frequency    ${ue_id}
    ...    event_type=${event_type}   carrierfreq=${carrierfreq}   carrierfreq_rat=${carrierfreq_rat}
    [Return]     ${meas_id}

Subsequent PDU Session Setup
    [Arguments]    ${ue_id}=1    ${pdu_id}=2   ${gw_id}=1   ${pass_regexp}=${None}
    Log To Console    ${ue_id}
    ${cmd}    Catenate   ue_pdu_session_setup pdu=${pdu_id} ue=${ue_id} gw=${gw_id}
    Airphone Operation    send_common_command  gnb  cmd=${cmd}   pass_regexp=${pass_regexp}   timeout=10s

Initial PDU Session Setup
    [Arguments]    ${ue_id}=1    ${pdu_id}=1   ${pass_regexp}=Established PDU session ID=1 using PDU Gateway ID
    Airphone Execute Egate Command  cmd=ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id}   pass_regexp=${pass_regexp}


Subsequent PDU Session Release
    [Arguments]    ${ue_id}   ${pdu_id}   ${pass_regexp}=${None}
    Log To Console    ${ue_id}
    ${cmd}    Catenate   ue_pdu_session_release ue=${ue_id} pdu=${pdu_id} by=amf
    Airphone Operation    send_common_command  gnb  cmd=${cmd}   pass_regexp=${pass_regexp}   timeout=10s

UE location
    [Arguments]    ${ue_id}=1  ${gnb_id}=2  ${cell_id}=1
    Airphone Execute Egate Command    cmd=ue_change_location id=${ue_id} enb=${gnb_id} cell=${cell_id}

UE Register
    [Arguments]    ${ue_id}=1  ${gnb_id}=2  ${cell_id}=1   ${pass_regexp}=UE now in NG RM Registered state
    Airphone Execute Egate Command    cmd=ue_change_location id=${ue_id} enb=${gnb_id} cell=${cell_id}
    Airphone Execute Egate Command    cmd=ue_register id=${ue_id}    pass_regexp=${pass_regexp}

#Set ICS none to gNB
#    [Arguments]    ${ue_id}=1  ${gnb_id}=2  ${cell_id}=1   ${pass_regexp}=UE now in NG RM Registered state
#    Airphone Execute Egate Command   cmd=amf_param id=1 empty_pdu_session_list=on send_ics_registration=off

PDU Modify to add DRB
    [Arguments]    ${ue_id}=1  ${pdu_id}=1  ${qosflows}=3  ${pass_regexp}=QosFlow
    Log To Console    ${ue_id}
    ${cmd}    Catenate   ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_add=${qosflows} by=amf
    Airphone Operation    send_common_command  gnb  cmd=${cmd}  pass_regexp=${pass_regexp}   timeout=30s

PDU Modify to delete DRB
    [Arguments]    ${ue_id}=1  ${pdu_id}=1  ${qosflows}=3  ${pass_regexp}=QosFlow
    Log To Console    ${ue_id}
    ${cmd}    Catenate   ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_del=${qosflows} by=amf
    Airphone Operation    send_common_command  gnb  cmd=${cmd}  pass_regexp=${pass_regexp}   timeout=30s

PDU Setup to add DRB
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${gw_id}=1  ${nwslice}=1  ${request_type}=initial-request
    ...    ${pass_regexp}=${None}
    ${cmd}    Catenate   ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} nwslice=${nwslice} gw=${gw_id}  request_type=${request_type}
    Airphone Operation    send_common_command  gnb  cmd=${cmd}  pass_regexp=${pass_regexp}   timeout=30s

PDU Setup With 5QI5 and 5QI1
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${gw_id}=1    ${pass_regexp}=handled successfully
    Log To Console    ${ue_id}
    ${cmd}    Catenate   ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} nwslice=1 gw=${gw_id}
    Airphone Execute Egate Command    smf_param id=1 additional_qosflows_to_activate=2
    Airphone Execute Egate Command    ${cmd}    pass_regexp=${pass_regexp}   timeout=10s

Trigger Measurement Report
    [Arguments]    ${ue_id}=1   ${meas_id}=3  ${event_type}=A2    ${srsrp_nr}=7    ${srsrq_nr}=7   ${pass_regexp}=measurementReport
    ${cmd}    Catenate    ue_measurement_send_nr    id=${ue_id}    meas_id=${meas_id}   event=${event_type}
    ...    srsrp_nr=${srsrp_nr}    srsrq_nr=${srsrq_nr}
    Airphone Operation    send_common_command  gnb  cmd=${cmd}  pass_regexp=${pass_regexp}  timeout=30s

Trigger Measurement Report with phycellid
    [Arguments]    ${ue_id}=1   ${meas_id}=2  ${event_type}=B2    ${phycell_id}=11   ${nrsrp_nr}=30
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${measid} event=${event_type}
     ...    srsrp_nr=11 srsrq_nr=11 srs_result=0:11:11:0
     ...    phycell_id=${phycell_id} nrsrp_nr=${nrsrp_nr}  nrsrq_nr=30 rs_type=ssb index=0 nrs_result=30:30:0
    Airphone Operation    send_common_command  gnb  cmd=${cmd}  pass_regexp=measurementReport  timeout=30s

Trigger Measurement Report for scell swap
    [Arguments]    ${ue_id}=1   ${meas_id}=2  ${event_type}=A6    ${nrsrp_nr}=7    ${nrsrq_nr}=7   ${scell_id}=1   ${phycell_id}=51
    ${cmd}    Catenate    ue_measurement_send_nr    id=${ue_id}    meas_id=${meas_id}   event=${event_type}  srsrp_nr=11 srsrq_nr=11
    ...    scell=${scell_id} scell_rsrp=20 scell_rsrq=20  phycell_id=${phycell_id} nrsrp_nr=${nrsrp_nr} nrsrq_nr=${nrsrq_nr}
   Airphone Operation    send_common_command  gnb  cmd=${cmd}  pass_regexp=measurementReport  timeout=30s

#Trigger Measurement Report for scell release
#    [Arguments]    ${ue_id}=1   ${meas_id}=2  ${event_type}=A2    ${scell_id}=1   ${scell_rsrp}=30
#    ${cmd}    Catenate    ue_measurement_send_nr    id=${ue_id}    meas_id=${meas_id}   event=${event_type}
#    ...    scell=${scell_id}  scell_rsrp=${scell_rsrp}
#    Airphone Operation    send_common_command  gnb  cmd=${cmd}  pass_regexp=measurementReport  timeout=30s

Trigger Measurement Report for scell release
    [Arguments]  ${ue_id}=1  ${meas_id}=2  ${event_type}=A2  ${srsrp_nr}=7  ${srsrq_nr}=7  ${scell_id}=1  ${srsrp_nr}=20  ${srsrp_nr}=20
    ${cmd}    Catenate    ue_measurement_send_nr    id=${ue_id}  meas_id=${meas_id}  event=${event_type}
    ...    scell=${scell_id}  srsrp_nr=${srsrp_nr}  srsrq_nr=${srsrq_nr}
    Airphone Operation    send_common_command  gnb  cmd=${cmd}  pass_regexp=measurementReport  timeout=30s

Trigger Measurement Report with neighbor cell id
    [Arguments]    ${ue_id}=1  ${meas_id}=2  ${event_type}=A2  ${srsrp_nr}=11  ${nrsrp_nr}=80  ${phycell_id}=62
    ...   ${pass_regexp}=measurementReport
    ${cmd}    Catenate    ue_measurement_send_nr    id=${ue_id}    meas_id=${meas_id}   event=${event_type}
    ...    srsrp_nr=${srsrp_nr}    srsrq_nr=11    phycell_id=${phycell_id}    nrsrp_nr=${nrsrp_nr}    nrsrq_nr=80
    Airphone Operation    send_common_command  gnb  cmd=${cmd}  pass_regexp=${pass_regexp}  timeout=30s

Trigger E-CID Measurement Initiation Request
    [Arguments]    ${ue_id}=1    ${meas_qty}=SS-RSRP    ${tid}=1    ${pass_regexp}=Received ECID Measurement Response
    ${cmd}    Catenate    lmf_send_ecid_meas_req id=1 ue=${ue_id} nrppa_transaction_id=${tid} lmf_ue_measurement_id=${tid}
    ...    report_characteristics=OnDemand meas_qty=${meas_qty}
    Airphone Operation    send_common_command  gnb  cmd=${cmd}   pass_regexp=${pass_regexp}  timeout=30s

Trigger UE Detach
    [Arguments]    ${ue_id}=1
    Airphone Execute Egate Command   cmd=ue_deregister id=${ue_id} ue_deregister_type=switch_off

Enable Indirect Data Forwarding Function
    [Arguments]    ${ue_id}=6
    Airphone Execute Egate Command    cmd=amf_timer T_Local=4000
    Airphone Execute Egate Command    cmd=amf_timer T_NotifyProcessing=2500
    Airphone Execute Egate Command    cmd=upf_param id=1 end_markers_delay=10004
    Airphone Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=1 trf_type=internal

Set Sim gNB4 Parameter
    Airphone Execute Egate Command    cmd=sim_trace enb=4 protocol=xn on
    Airphone Execute Egate Command    cmd=enb_xp_param xp_peers=2 id=4
#    download scf and filter XPIFREMOTE_R-1:xpLinkStatus=available
    sleep  120s
    ${cmd1}    catenate    gnb_cell_param gnb=4 id=11 Cell_BWP_List=3,4,5,6 cell_Available=yes
    ...    weightForSCellSelection=50    lteNrDssMode=lteNrDssModeNone
    Airphone Execute Egate Command    cmd=${cmd1}
    ${cmd2}    catenate    gnb_param id=4 bwp_profile_id=54 bwp_profile_type=dedicated
    ...    act_multiple_dedicated_bwps=no location_bw_ul=1:0 location_bw_dl=1:1    Inter_gNB_CA_Allowed=yes
    ...    CellLoadReportingPeriodicity=000 IgNBCAXpProtocolVersion=${IgNBCAXpProtocol_Version}
    ...    IgNBCAXgUProtocolVersion=${IgNBCAXgUProtocol_Version}
    Airphone Execute Egate Command    cmd=${cmd2}
    Airphone Execute Egate Command    cmd=ignb_ca_configuration_update_indication_send id=4 target=2
    ...   pass_regexp=IgNBCAConfigurationUpdateIndication
    ${cmd3}    catenate    ignb_ca_addition_param gnb_id=4 DU-to-CU-RRCInfo=${DU-to-CU-RRCInfo}
    ...    ExtDu-to-PrimeDu-RrcInfo=${ExtDu-to-PrimeDu-RrcInfo}
    Airphone Execute Egate Command    cmd=${cmd3}

Start DCAP logs
    [Arguments]     ${log_type}=emil    ${nrCells}=NRCELL_R-1   ${bts_index}=${0}
    ${dcap_argument}   Create Dictionary   nrCells=${nrCells}
    ${dict_argument}   Create Dictionary   dcap_server=${dcap_info}    argument=${dcap_argument}
    Log Collection    start   log_type=${log_type}   product_type=gnb   bts_index=${bts_index}  dict_argument=${dict_argument}

Stop DCAP logs
    [Arguments]     ${log_type}=emil   ${bts_index}=${0}
    ${local_file_path}    Log Collection    stop_and_download    log_type=${log_type}    product_type=gnb    bts_index=${bts_index}

Start DCAP logs multi BTS
    [Arguments]     ${log_type}=muti_emil  ${nrCells_1}=NRCELL_R-1   ${nrCells_2}=NRCELL_R-1
    ${bts1_cell_argument}   Create Dictionary   nrCells=${nrCells_1}
    ${bts2_cell_argument}    Create Dictionary  nrCells=${nrCells_2}
    ${dict_argument}   Create Dictionary
    ...    dcap_server=${dcap_info}
    ...    bts1_cell_argument=${bts1_cell_argument}
    ...    bts2_cell_argument=${bts2_cell_argument}
    Log Collection    start   log_type=${log_type}   product_type=gnb   dict_argument=${dict_argument}

Stop DCAP logs multi BTS
    [Arguments]     ${log_type}=muti_emil
    ${local_file_path}    Log Collection    stop_and_download    log_type=${log_type}    product_type=gnb

Activate or Deactivate Emil
    [Arguments]       ${actInternalTrace}=true   ${product_type}=gnb
     @{para_list}   Create List   actInternalTrace
     @{value_list}   Create List   ${actInternalTrace}
     @{mo_list}   Create List   MRBTS-1/MNL-1/MNLENT-1/TRBLCADM-1
     ${res}   Parameter Operation    operation=parameter_update   product_type=${product_type}   para_list=${para_list}
     ...      value_list=${value_list}   mo_list=${mo_list}

Update Measurement Report time
    [Arguments]    ${delta_file_path}=${case_path}/config/mea_switch.json
    Parameter Operation    operation=delta_plan_update   product_type=gnb  delta_file_path=${delta_file_path}  wait_for_completion=${True}

Activate VONR
     [Arguments]  ${delta_file_path}=${case_path}/config/vonr.json
     Parameter Operation    operation=delta_plan_update   product_type=gnb  delta_file_path=${delta_file_path}  wait_for_completion=${True}

Activate CB008281
     [Arguments]  ${delta_file_path}=${case_path}/config/CB008281.json
     Parameter Operation    operation=delta_plan_update   product_type=gnb  delta_file_path=${delta_file_path}

Activate Feature
     [Arguments]  ${feature}=CB008281.json   ${bts_index}=${0}
     Parameter Operation    operation=delta_plan_update   product_type=gnb  delta_file_path=${case_path}/config/${feature}
     ...   bts_index=${bts_index}   backhaul_site_oam_ip=${True}

Counter Verification
   [Arguments]    ${counter_rule}=counter_rule.txt
   log to console   start counter collection time
   Counter Operation    operation=start_collect_counter
   ...                  product_type=gnb
   ...                  bts_index=0
   ...                  counter_rule=${case_path}/config/${counter_rule}
   ${result}    Counter Operation    operation=collect_counter_and_check_rule
   Log To Console    \nCounter Rule Collect and Check Result is: ${result}

Clear Egate console log
     ${exist_console}   Run   cd /opt/wts/latest;ls egate_console.log.001
     Run keyword if  "${exist_console}"=="egate_console.log.001"
     ...   Run  cd /opt/wts/latest;sudo rm egate_console.log.001

Get Egate console Log
     ${save_path}    basic.create_a_directory    log_path=${TEST_LOG_DIRECTORY}
      ...                 directory_name=egate_console
     ${exist_console}   Run   cd /opt/wts/latest;ls egate_console.log.001
     Run keyword if  "${exist_console}"=="egate_console.log.001"
     ...   Run  cd /opt/wts/latest;sudo mv egate_console.log.001 ${TEST_LOG_DIRECTORY}/egate_console/

Set Qosflow Priority and Reset Smf Param
    [Arguments]    ${priority}=1
    Airphone Execute Egate Command    qosflow_modify qos_flow=1 priority=${priority}
    Airphone Execute Egate Command    qosflow_modify qos_flow=2 priority=${priority}
    Airphone Execute Egate Command    qosflow_modify qos_flow=3 priority=${priority}
    Airphone Execute Egate Command    qosflow_modify qos_flow=4 priority=${priority}
    Airphone Execute Egate Command    smf_param id=1 reset

#Set Internal Traffic Type To UE
#    [Arguments]    ${ue_id}=1    ${pdu_id}=1
#    Airphone Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal

#Set Scg UL Dist Percent
#    [Arguments]    ${id}=1    ${scg_ul_dist_percent}=50    ${wait}=1s
#    Airphone Execute Egate Command    cmd=uec_param id=${id} scg_ul_dist_percent=${scg_ul_dist_percent}
#    Sleep    ${wait}

#Set ICS to gNB
#    [Arguments]    ${ue_id}=1
#    Airphone Execute Egate Command    cmd=amf_ue_ics_param id=1 ue=${ue_id} indexToRFSP=1

Send Data Traffic
    [Arguments]    ${ue_id}=1   ${pdu_id}=1    ${qfi}=1    ${mbps}=150    ${size}=1350    ${inactive_timer}=30
    Airphone Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi} dir=dl mbps=${mbps} size=${size}
    Airphone Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} trf_id=1 dir=dl mbps=${mbps} size=${size}
    Airphone Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} trf_id=2 dir=dl mbps=${mbps} size=${size}
    Airphone Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} trf_id=3 dir=dl mbps=${mbps} size=${size}
    Airphone Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi} dir=ul mbps=60 size=${size}
    Airphone Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi} trf_id=1 dir=ul mbps=60 size=${size}
    Wait for Traffic to Stabilize    inactive_timer=${inactive_timer}

Wait for Traffic to Stabilize
    [Arguments]    ${inactive_timer}=30
    BuiltIn.Sleep    ${inactive_timer}s

#Modify json file value
#     [Arguments]    ${param_dict}=none   ${json_file_name}=a2_redirect.json    ${new_file_name}=a2_redirect_new.json
#     ...   ${target_operation}=create   ${new_distname}=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
#     basic.modify_json_file   json_file_path=${case_path}/config/${json_file_name}
#     ...     new_distname=${new_distname}
#     ...     param_updates=${param_dict}    new_file_name=${new_file_name}   target_operation=${target_operation}

UE Register And PDU Session Setup
    [Arguments]    ${ue_id}=1  ${gnb_id}=2  ${cell_id}=1  ${gw}=1  ${pass_regexp}=QoS Routing Table
    Log To Console    ${ue_id}
    Airphone Execute Egate Command    cmd=ue_change_location id=${ue_id} enb=${gnb_id} cell=${cell_id}
    Airphone Execute Egate Command    cmd=ue_register id=${ue_id} nwslice=all    pass_regexp=UE now in NG RM Register
    Airphone Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=1 trf_type=internal log_traffic_stats=off
    Airphone Execute Egate Command    cmd=ue_pdu_session_setup ue=${ue_id} pdu=1 gw=${gw}    pass_regexp=${pass_regexp}
#	sleep    5s
#    Airphone Execute Egate Command    cmd=ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=2 by=amf
#    ...       pass_regexp=${pass_regexp}

Start data traffic in egate
    [Arguments]   ${ue_id}=${EMPTY}   ${direction}=ul  ${protocol}=udp   ${ack_mode}=off   ${trf_id}=1  ${qfi}=1
    ...   ${cl_trf_stats}=on   ${mbps}=10  ${pass_regexp}=Internal traffic Receiver
    ${command}   Catenate
    ...   trf_data_start ue=${ue_id} dir=${direction} trf_id=${trf_id}
    ...   protocol=${protocol} ack_mode=${ack_mode} cl_trf_stats=${cl_trf_stats}
    ...   pdu=1 qfi=${qfi} mbps=${mbps}
    Airphone Operation    operation=send_common_command
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=${command}
    ...                   pass_regexp=${pass_regexp}
    ...                   timeout=100s

Start data traffic in egate by kbps
    [Arguments]   ${ue_id}=${EMPTY}   ${direction}=ul  ${protocol}=udp   ${ack_mode}=off   ${trf_id}=1  ${qfi}=1
    ...   ${cl_trf_stats}=on  ${pdu}=1  ${kbps}=10   ${pass_regexp}=Internal traffic Receiver
    ${command}   Catenate
    ...   trf_data_start ue=${ue_id} dir=${direction} trf_id=${trf_id}
    ...   protocol=${protocol} ack_mode=${ack_mode} cl_trf_stats=${cl_trf_stats}
    ...   pdu=${pdu} qfi=${qfi} kbps=${kbps}
    Airphone Operation    operation=send_common_command
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=${command}
    ...                   pass_regexp=${pass_regexp}
    ...                   timeout=100s

Send RRE before Handover failure
    [Arguments]    ${ue_id}=1   ${pass_regexp}=${None}
    ${cmd}    Catenate
    ...  ue_nr_rrc_reconf_param id=${ue_id} if_contains=any action=reestablish gnb=3 cell=4 crnti=source cause=handoverFailure delay=1000 nth=1
    Airphone Operation    send_common_command  gnb  cmd=${cmd}    pass_regexp=${pass_regexp}

Start Tcpdump Log on Target gNB
    [Arguments]    ${host}=10.0.1.3
    Log To Console    start tcpdump on target gNB
    ${tcpdump_log_name_T}=    TStart tcpdump in SBTS    host=${host}
    [Return]    ${tcpdump_log_name_T}

Stop Tcpdump Log on Target gNB
    [Arguments]    ${tcpdump_log_name_T}
    Log To Console    stop tcpdump on target gNB
    ${capture_file_path_T}    ${input_file}=    TStop Tcpdump in SBTS      names=${tcpdump_log_name_T}
    [Return]     ${capture_file_path_T}

TStart tcpdump in SBTS
   [Arguments]    ${host}
   [Documentation]    this kw is used to start tcpdump in gnb
    ${timestamp}=    DateTime.Get Current Date    result_format=%Y%m%d%H%M%S
    ${pcap_path}    Join Path    ${OUTPUT_DIR}    Wireshark_${timestamp}
    ${pcap_file_name}    Join Path    ${OUTPUT_DIR}    Wireshark_${timestamp}    Wireshark_${timestamp}.pcap
    set variable    ${pcap_path}
    set variable    ${pcap_file_name}
    ${tcpdump_log_name}  set variable   Wireshark_${host}_${timestamp}
    TStart tcpdump collection in SBTS    host=${host}     name=Wireshark_${host}_${timestamp}    options=-i any
    [Return]    ${tcpdump_log_name}

TStop Tcpdump in SBTS
   [Arguments]    ${names}=${tcpdump_log_name}
   [Documentation]    this kw is used to stop tcpdump in gnb
    core.stop_collectors    names=${names}
    core.Collect Collectors    names=${names}    target_dir=${TEST_LOG_DIRECTORY}
    core.Teardown Collectors    names=${names}

    ${capture_file_path} =    Set Variable    ${TEST_LOG_DIRECTORY}/${names}/${names}.pcap
    ${input_file} =    Set Variable    ${names}.pcap
    set variable    ${capture_file_path}
    set variable    ${input_file}
    [Return]    ${capture_file_path}    ${input_file}

TStart tcpdump collection in SBTS
    [Arguments]    ${host}=none    ${name}=ASIB_tcpdump    ${options}=-i any
    [Documentation]    this kw is used to create tcpdump log collection on ASIB VM
    &{ASIB}=    create dictionary    host=${host}
    ...                              user=${ASIB_USERNAME}
    ...                              password=${ASIB_PASSWORD}
    tcpdump.create_tcpdump_collector    name=${name}    options=${options}    executor=${ASIB}
    tcpdump.Set Suite Alias    ${name}
    core.setup_collectors    names=${name}
    core.start_collectors    names=${name}