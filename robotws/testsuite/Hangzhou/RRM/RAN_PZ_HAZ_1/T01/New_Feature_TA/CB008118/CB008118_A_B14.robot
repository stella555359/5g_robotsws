*** Settings ***
Documentation
...   Author: xiaowei.1.chen@nokia-sbell.com
...   Contact: xiaowei.1.chen@nokia-sbell.com
...   Description: This user scenario describes

Suite Setup       Run keywords   Common Suite Setup For RRM   AND   Update bsr package
Test Setup        Common Test Setup For RRM
Suite Teardown    Common Suite Teardown For RRM
Test Teardown     Common Test Teardown For RRM

Test Timeout    120 minutes

Resource          ../../../Resources/Classical/RRM_Common_Resource.robot

*** Variables ***
${Setup_5QI1_Success}
...    Added QosFlow with QFI:2 5QI:1
${Setup_5QI5_Success}
...    Setup QosFlow with QFI:1 5QI:5
${Setup_5QI9_Success}
...    Setup QosFlow with QFI:1 5QI:9
${Setup_5QI65_Success}
...    Added QosFlow with QFI:2 5QI:65
${Setup_5QI69_Success}
...    Setup QosFlow with QFI:1 5QI:69
${Setup_5QI70_Success}
...    Setup QosFlow with QFI:1 5QI:70
${Remove_5QI65_Success}
...    Deleting QosFlow with QFI:2 5QI:65
&{dcap_info}    host=127.0.0.1    port=9443    username=${None}    password=${None}
@{field_names_1}         _ws.col.No.     _ws.col.Source    _ws.col.Info
${extra_conditions}      -E header=y -E separator=, -E quote=d -E occurrence=a
&{wireshark_analysis_dict_1}    filter_conditions=ngap.radioNetwork == 34
...    extra_conditions=${extra_conditions}    output_field_names=${field_names_1}
${wireshark_analysis_dict_2}    filter_conditions=ngap.radioNetwork == 22
...    extra_conditions=${extra_conditions}    output_field_names=${field_names_1}
${intra_ho_success}
...    Intra-eNB handover from EXT_ENB-2.2 to EXT_ENB-2.1 performed
*** Test Cases ***
Case_Precondition
    Case Precondition
CB008118-A#B14_TC25_Successful_Intrafrequency_IntraDU_IntraGnb_handover_with_MCGBR bearers
    [Tags]    QC_xxx       QCD_MN_RAN      QCP_RAN_VRF
    Airphone Operation    edaemon_egate_setup     gnb tag=CB008118_RJIO
    Start TTI For GNB    NRCELL_R-2
    ${ue_id}    Set Variable    21
    UE Deregister From gNB      ue_id=1-80    cell=2
    Establish mcs-PriorityAccess    ue_id=${ue_id}
    UE Register And PDU Session Setup   ue_id=${ue_id}   qos_flow=19   pass_regexp=${Setup_5QI69_Success}
    UE Modify new PDU    ue_id=${ue_id}    pdu=1    qosflows_to_add=15    pass_regexp=${Setup_5QI65_Success}
    Send GBR Throughput    ue_id=${ue_id}    pdu_id=1    qfi_id=1
    ${meas_id}   Get Measurement Id   ue_id=${ue_id}   event_type=A3    carrierfreq=634080
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=52
    ...      nrsrp_nr=30 nrsrq_nr=30 rs_type=ssb index=0 nrs_result=30:30:30
    Airphone Execute Egate Command      cmd=${cmd}     pass_regexp=Intra-eNB handover from EXT_ENB-2.2 to EXT_ENB-2.1 performed
    Stop TTI For GNB
CB008118-A#B14_TC26_Successful_HO_with_MCGBR bearers_and_18bit_PDCP_size
    [Tags]    QC_xxx       QCD_MN_RAN      QCP_RAN_VRF
    Airphone Operation    edaemon_egate_setup     gnb tag=CB008118_RJIO
    Start TTI For GNB    NRCELL_R-2
    ${ue_id}    Set Variable    21
    Modify Parameter        para=pdcpSNLength    mo_list=MRBTS-1/NRBTS-1/NRDRB_PDCP-3    value=len18bits
    UE Deregister From gNB      ue_id=1-80    cell=2
    Establish mcs-PriorityAccess    ue_id=${ue_id}
    UE Register And PDU Session Setup   ue_id=${ue_id}   qos_flow=19   pass_regexp=${Setup_5QI69_Success}
    UE Modify new PDU    ue_id=${ue_id}    pdu=1    qosflows_to_add=15    pass_regexp=${Setup_5QI65_Success}
    Send GBR Throughput    ue_id=${ue_id}    pdu_id=1    qfi_id=1
    ${meas_id}   Get Measurement Id   ue_id=${ue_id}   event_type=A3    carrierfreq=634080
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=52
    ...      nrsrp_nr=30 nrsrq_nr=30 rs_type=ssb index=0 nrs_result=30:30:30
    Airphone Execute Egate Command      cmd=${cmd}  pass_regexp=Intra-eNB handover from EXT_ENB-2.2 to EXT_ENB-2.1 performed
    Stop TTI For GNB
CB008118-A#B14_TC27_Successful_IntergNB_HO_with_MCGBR bearers
    [Tags]    QC_xxx       QCD_MN_RAN      QCP_RAN_VRF
    Airphone Operation    edaemon_egate_setup     gnb tag=CB008118_RJIO
#    Start Collect Wireshark For GNB
    Start TTI For GNB    NRCELL_R-1
    Setup Xn Link To GNB
    ${ue_id}    Set Variable    1
    UE Deregister From gNB      ue_id=1-80    cell=1
    Establish mcs-PriorityAccess    ue_id=${ue_id}
    UE Register And PDU Session Setup   ue_id=${ue_id}   qos_flow=19   pass_regexp=${Setup_5QI69_Success}
    UE Modify new PDU    ue_id=${ue_id}    pdu=1    qosflows_to_add=15    pass_regexp=${Setup_5QI65_Success}
    Send GBR Throughput    ue_id=${ue_id}    pdu_id=1    qfi_id=1
    ${meas_id}   Get Measurement Id   ue_id=${ue_id}   event_type=A3    carrierfreq=634080
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=7
    ...      nrsrp_nr=30 nrsrq_nr=30 rs_type=ssb index=0 nrs_result=30:30:30
    Airphone Execute Egate Command      cmd=${cmd}     pass_regexp=Intra-eNB handover from EXT_ENB-2.2 to EXT_ENB-2.3 performed
#    Stop Wireshark log For GNB
    Stop TTI For GNB
CB008118-A-#B16_TC30_excluded_Neighbor_cell_not_supporting_MC_QoS_flow_during_IntraGnb_HO_for_UE_have_MCGBR
    [Tags]    QC_xxx       QCD_MN_RAN      QCP_RAN_VRF
    Airphone Operation    edaemon_egate_setup     gnb tag=CB008118_RJIO
    Start TTI For GNB    NRCELL_R-2
    ${ue_id}    Set Variable    22
    Modify Parameter        para=actMcQosSupport    mo_list=MRBTS-1/NRBTS-1/NRCELL-3    value=false
    UE Deregister From gNB      ue_id=1-80    cell=2
    Establish mcs-PriorityAccess    ue_id=${ue_id}
    UE Register And PDU Session Setup   ue_id=${ue_id}   qos_flow=19   pass_regexp=${Setup_5QI69_Success}
    UE Modify new PDU    ue_id=${ue_id}    pdu=1    qosflows_to_add=15    pass_regexp=${Setup_5QI65_Success}
    Send GBR Throughput    ue_id=${ue_id}    pdu_id=1    qfi_id=1
    ${meas_id}   Get Measurement Id   ue_id=${ue_id}   event_type=A3    carrierfreq=634080
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=50
    ...      nrsrp_nr=30 nrsrq_nr=30 phycell_id=52 nrsrp_nr=40 nrsrq_nr=40
    Airphone Execute Egate Command      cmd=${cmd}    pass_regexp=Intra-eNB handover from EXT_ENB-2.2 to EXT_ENB-2.1 performed

    Modify Parameter        para=actMcQosSupport    mo_list=MRBTS-1/NRBTS-1/NRCELL-3    value=true
    UE Deregister From gNB      ue_id=1-80    cell=2
    ${ue_id}    Set Variable    23
    Establish mcs-PriorityAccess    ue_id=${ue_id}
    UE Register And PDU Session Setup   ue_id=${ue_id}   qos_flow=19   pass_regexp=${Setup_5QI69_Success}
    UE Modify new PDU    ue_id=${ue_id}    pdu=1    qosflows_to_add=15    pass_regexp=${Setup_5QI65_Success}
    Send GBR Throughput    ue_id=${ue_id}    pdu_id=1    qfi_id=1
    ${meas_id}   Get Measurement Id   ue_id=${ue_id}   event_type=A3    carrierfreq=634080
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=50
    ...      nrsrp_nr=30 nrsrq_nr=30 phycell_id=52 nrsrp_nr=40 nrsrq_nr=40
    Airphone Execute Egate Command      cmd=${cmd}    pass_regexp=Intra-eNB handover from EXT_ENB-2.2 to EXT_ENB-2.3 performed
    Stop TTI For GNB
*** Keywords ***
Case Precondition
    Airphone Operation    operation=edaemon_egate_setup
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=${None}
    ...                   pass_regexp=${None}
    ...                   timeout=100s
    Airphone Operation    operation=env_setup_sa
    ...                   product_type=gnb
    ...                   traffic_info_dic=${None}
    ...                   tag=CB008118_RJIO
    ...                   cmd=${None}
    ...                   pass_regexp=${None}
    ...                   timeout=12000s
    ...                   customer=RJIO
#    [Teardown]    Airphone Operation    operation=edaemon_egate_teardown    product_type=${None}    traffic_info_dic=${None}
#    ...                                 tag=${None}    cmd=${None}    pass_regexp=${None}    timeout=100s
    log_to_console     Plugin download
    start_dcap_controller_common
UE Deregister From gNB
    [Arguments]    ${ue_id}    ${cell}
    Airphone Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off
    Airphone Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell}
    sleep     5s
UE Register And PDU Session Setup
    [Arguments]    ${ue_id}=1   ${qos_flow}=5  ${pass_regexp}=QoS Routing Table
    Airphone Execute Egate Command    cmd=ue_register id=${ue_id}
    sleep   2s
    Airphone Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=1 trf_type=internal default_qos_flow=${qos_flow}
    sleep   2s
    Airphone Execute Egate Command    cmd=ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=1    pass_regexp=${pass_regexp}
UE Modify new PDU
    [Arguments]    ${ue_id}=1    ${pdu}=1   ${qosflows_to_add}=65   ${pass_regexp}=QoS Routing Table
    Airphone Execute Egate Command
    ...    cmd=ue_pdu_session_modify ue=${ue_id} pdu=${pdu} qosflows_to_add=${qosflows_to_add} by=amf    pass_regexp=${pass_regexp}
    sleep    5s
UE Delte PDU
    [Arguments]    ${ue_id}=1    ${pdu}=1   ${qosflows_to_del}=65   ${pass_regexp}=QoS Routing Table
    Airphone Execute Egate Command
    ...    cmd=ue_pdu_session_modify ue=${ue_id} pdu=${pdu} qosflows_to_del=${qosflows_to_del} by=amf pass_regexp=${pass_regexp}
    sleep    5s
Send NonGBR Throughput
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${qfi_id}=1
    Execute Egate Command    cmd=data_trf_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=dl trf_id=1 protocol=udp mbps=100
#    ...    pass_regexp=UE ${ue_id}: UDP DL
    sleep   2s
    Execute Egate Command    cmd=data_trf_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=ul trf_id=2 protocol=udp mbps=10
#    ...    pass_regexp=UE ${ue_id}: UDP UL
Send GBR Throughput
    [Arguments]    ${ue_id}     ${pdu_id}=1    ${qfi_id}=1
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=dl trf_id=3 protocol=tcp mbps=50 seconds=600
    ...    pass_regexp=UE ${ue_id}: TCP DL
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=ul trf_id=4 protocol=tcp mbps=10 seconds=600
    ...    pass_regexp=UE ${ue_id}: TCP UL
Establish mcs-PriorityAccess
    [Arguments]    ${ue_id}=1
    Execute Egate Command    cmd=ue_nr_rrc_setup_param id=${ue_id} establishment_cause=mcs-PriorityAccess

Check Traffic
    [Arguments]    ${ue_id}=1
    Airphone Execute Egate Command     ue_stats_nr id=${ue_id} type=pdsch
    Airphone Execute Egate Command     ue_stats_nr id=${ue_id} type=pusch
Start Collect Wireshark For GNB
    ${wireshark_argument}   Create Dictionary   wireshark_options=-i any
    ${dict_argument}   Create Dictionary   argument=${wireshark_argument}
    Log Collection    start    wireshark    product_type=gnb    bts_index=${0}    dict_argument=${dict_argument}
    sleep     5s
Stop Wireshark log For GNB
    ${local_file_path}    Log Collection    stop_and_download    wireshark    product_type=gnb    bts_index=${0}
    sleep    2s
    [Return]    ${local_file_path}
Analyze Wireshark log
    [Arguments]    ${local_file_path}    ${wireshark_analysis_dict}
    ${result}=    Log Analysis    check    wireshark    ${local_file_path}    ${wireshark_analysis_dict}
    Log To Console    \nAnalyze log: ${result}
Start TTI For GNB
    [Arguments]    ${nrCells}=NRCELL_R-2
    start_dcap_controller_common
    ${dcap_argument}   Create Dictionary   nrCells=${nrCells}
    ${dict_argument}   Create Dictionary   dcap_server=${dcap_info}    argument=${dcap_argument}
    Log Collection    start    tti    product_type=gnb    bts_index=${0}    cudu_index=${0}    dict_argument=${dict_argument}
    sleep    60s
Stop TTI For GNB
    ${local_file_path}    Log Collection    stop_and_download    tti    product_type=gnb    bts_index=${0}    cudu_index=${0}
Modify Parameter
    [Arguments]    ${para}    ${mo_list}     ${value}
    @{para_list}          Create List    ${para}
    @{mo_list}            Create List    ${mo_list}
    @{value_list_true}    Create List    ${value}
    ${out}                Parameter Operation    operation=parameter_update    product_type=gnb
    ...                                          para_list=@{para_list}    value_list=@{value_list_true}    mo_list=@{mo_list}
    Log To Console        gnb paramter update result: ${out}
    sleep   10s
Check NonGBR UE Tput
    [Arguments]    ${ue_id}=1
    ${max_tput}    ${ave_tput}    ${min_tput}    Module AP Get Average Throughput    ue_id=${ue_id}
    ...                                                  qfi=1    dir=dl    trf_id=1    type=l3
    ...                                                  call_type=SA    pdu_id=1
    ${ave_tput_str}    Convert To String    ${ave_tput}
    log_to_console     UE${ue_id} DL ave tput is ${ave_tput_str.lower()}
    ${max_tput}    ${ave_tput}    ${min_tput}    Module AP Get Average Throughput    ue_id=${ue_id}
    ...                                                  qfi=1    dir=ul    trf_id=2    type=l3
    ...                                                  call_type=SA    pdu_id=1
    ${ave_tput_str}    Convert To String    ${ave_tput}
    log_to_console     UE${ue_id} UL ave tput is ${ave_tput_str.lower()}
Check GBR UE Tput
    [Arguments]    ${ue_id}=1
    ${max_tput}    ${ave_tput}    ${min_tput}    Module AP Get Average Throughput    ue_id=${ue_id}
    ...                                                  qfi=1    dir=dl    trf_id=3    type=l3
    ...                                                  call_type=SA    pdu_id=1
    ${ave_tput_str}    Convert To String    ${ave_tput}
    log_to_console     UE${ue_id} DL ave tput is ${ave_tput_str.lower()}
    ${max_tput}    ${ave_tput}    ${min_tput}    Module AP Get Average Throughput    ue_id=${ue_id}
    ...                                                  qfi=1    dir=ul    trf_id=4    type=l3
    ...                                                  call_type=SA    pdu_id=1
    ${ave_tput_str}    Convert To String    ${ave_tput}
    log_to_console     UE${ue_id} UL ave tput is ${ave_tput_str.lower()}
Start Collect Mutli Counter For T16
    ${rule_list}    Create List
    ${rule1}    Catenate
    ...         Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...         Counter: M55125C08501;
    ...         Counter rule:avg(M55125C08501)>=1;
    append to list  ${rule_list}    ${rule1}

    ${rule2}    Catenate
    ...         Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...         Counter: M55163C00001;
    ...         Counter rule:avg(M55163C00001)>=1;
    append to list  ${rule_list}    ${rule2}

    ${rule3}    Catenate
    ...         Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...         Counter: M55125C09012;
    ...         Counter rule:avg(M55125C09012)>=1;
    append to list  ${rule_list}    ${rule3}
    ${rule4}    Catenate
    ...         Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...         Counter: M55163C00512;
    ...         Counter rule:avg(M55163C00512)>=1;
    append to list  ${rule_list}    ${rule4}
    Counter Operation    operation=start_collect_counter    product_type=gnb
    ...                                                     bts_index=0
    ...                                                     counter_rule=${rule_list}
Stop Collect Mutli Counter
    ${value1}    Counter Operation    operation=collect_counter_and_check_rule    product_type=gnb    bts_index=0    cudu_index=0

Get Measurement id
    [Arguments]  ${ue_id}=1   ${event_type}=A3  ${carrierfreq}=0
    ${meas_id}    Get Nr Meas Id For Specific Type And Frequency  ue_id=${ue_id}
    ...     event_type=${event_type}  carrierfreq=${carrierfreq}
    [Return]     ${meas_id}

Setup Xn Link To gNB
    [Arguments]    ${gnb_id}=3    ${pass_regexp}=none
    Airphone Execute Egate Command   cmd=gnb_param id=${gnb_id} xn_listening_socket=1 send_xn_setup=true sib1_period=160ms
    Airphone Execute Egate Command
    ...    cmd=gnb_xn_link_up gnb=${gnb_id} target=2    pass_regexp=${pass_regexp}
Update bsr package
    ${dllink}   Set Variable     https://artifactory-espoo1.ext.net.nokia.com:443/artifactory/mnpute-rotta-local/BSR
    ${filename}    Set variable     BSR_AQQJ_4_H4_ALN30_ARP30_P00_6TO4_60_00421_00001.zip
    Run     wget ${dllink}/${filename} -P /home/ute
    coam.setup admin
    ${ret}     coam.Update Software      /home/ute/BSR_AQQJ_4_H4_ALN30_ARP30_P00_6TO4_60_00421_00001.zip
    coam.teardown admin