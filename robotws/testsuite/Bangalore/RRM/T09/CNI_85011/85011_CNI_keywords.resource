*** Settings ***
Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Library          Collections
Resource         ../CB008541/resources/CB008541_Keywords.robot
Library          ta5g_pm_counters



*** Variables ***
${gw_ID}     1
${Pdu_session_ID}       1
${QFI_ID}     1
${nwslice_ID}    1
${nw_id}    1


*** Keywords ***
Validate Sending PDU Session End Marker From Syslog
    [Arguments]    ${syslog}   ${Pdu_id}   ${QFI}
    ${status} =   run    command=sudo cat ${LOG_PATH}/syslog_${syslog}.log | grep "PDU Session End Marker"
    Builtin.Log   ${status}
    Should Not Be Empty    ${status}
    Should Contain    ${status}   Sending PDU Session End Marker over Teid = ${Pdu_id} with QFI = ${QFI}

Validate Receiving HO End Marker From Syslog
    [Arguments]    ${syslog}   ${UE}   ${Bearerid}
    ${status} =   run    command=sudo cat ${LOG_PATH}/syslog_${syslog}.log | grep "Get fwdEndmarker when HO on going"
    Builtin.Log   ${status}
    Should Not Be Empty    ${status}
    Should Match Regexp    ${status}    h0${Bearerid}/Ln:\\d+/Get fwdEndmarker when HO on going

Validate Receiving HO End Marker From ENB3
    [Arguments]    ${WTS_DIR}   ${EBI}
    ${status} =   run    command=sudo cat ${WTS_DIR}/enb_3* | grep "End marker received for ebi"
    Builtin.Log   ${status}
    Should Not Be Empty    ${status}
    Should Contain    ${status}    End marker received for ebi ${EBI}

Trigger DL Traffic for SA Vonr
    [Arguments]    ${ue_id}      ${dl_rate}     ${pdu_id}=${Pdu_session_ID}     ${trf_id}=${TRF_ID}      ${qfi_id}=${QFI_ID}
    [Documentation]    This keyword starts the DL Traffic for the SA variant
    #Log to Console    \nRunning DL Traffic for ${dl_rate} ${Traffic_rate}...
    wtsrunner.trf_data_start   ue=${ue_id}  pdu=${pdu_id}   qfi=${qfi_id}  dir=dl  trf_id=${trf_id}   protocol=udp   ack_mode=off  cl_trf_stats=on
    ...    mbps=${dl_rate}   ack_mode=off  cl_trf_stats=on
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=Started Downlink Internal traffic    timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    UDP DL TRF:    partial_match=${TRUE}
    Log to Console    ${output}
    BuiltIn.Log    DL_traffic_data_is_started_successfully

Trigger UL Traffic for SA Vonr
    [Arguments]    ${ue_id}     ${ul_rate}       ${pdu_id}=${Pdu_session_ID}     ${trf_id}=${TRF_ID}      ${qfi_id}=${QFI_ID}
    [Documentation]    This keyword starts the UL Traffic for the SA variant
   # Log to Console    \nRunning UL Traffic for ${ul_rate} ${Traffic_rate}...
    wtsrunner.trf_data_start   ue=${ue_id}  pdu=${pdu_id}   qfi=${qfi_id}  dir=ul  trf_id=${trf_id}   protocol=udp   ack_mode=off  cl_trf_stats=on
    ...   mbps=${ul_rate}    ack_mode=off  cl_trf_stats=on
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=Started Uplink Internal traffic*    timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    UDP UL TRF:    partial_match=${TRUE}
    Log to Console    ${output}
    BuiltIn.Log    UL_traffic_data_is_started_successfully

Validate PM Counters bigger
    [Arguments]    ${PM_dir}     ${PM_counter}    ${expected_value}
    PM_Counters.Check PM counter value bigger than    expected_value=${expected_value}   pm_files_location=${PM_dir}
    ...  pi_id=${PM_counter}    moc=NRBTS-1

Verify The Sending DataForwarding Counter
    Wait For Next Full Pm Interval
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55337C00001    >0     DL_FW_SDU_SNT_PDUSES_QOS_01
    ...     local_moid=MRBTS-1/NRBTS-1
    ...     file_path=${pm_counter_file}

Verify The Receiving DataForwarding Counter
    Wait For Next Full Pm Interval
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55337C05001    >0     NUM_DL_FWDT_RCV_PDUSES_QOS_01
    ...     local_moid=MRBTS-1/NRBTS-1
    ...     file_path=${pm_counter_file}

Verify The Sending and Receiving DataForwarding Counter
    Wait For Next Full Pm Interval
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55337C05001    >0     NUM_DL_FWDT_RCV_PDUSES_QOS_01
    ...     M55337C00001    >0     DL_FW_SDU_SNT_PDUSES_QOS_01
    ...     local_moid=MRBTS-1/NRBTS-1
    ...     file_path=${pm_counter_file}

UE Register should be Successful Vonr
    [Arguments]    ${ue_id}     ${pdu_id}=${Pdu_session_ID}     ${nw_id}=${nwslice_ID}      ${gw_id}=${gw_ID}
    [Documentation]    This keyword checks the message for the completion of UE registration in the output file for the SA variant
    wtsrunner.set_pdu_param     ue=${ue_id}    pdu=${pdu_id}    trf_type=internal   log_traffic_stats=off
    wtsrunner.ue_register   id=${ue_id}    nwslice=${nw_id}
    ${output}    Read WTS Output Until Pattern Matches    ${UE_register_complete_pattern}    ${Timeout_SA}
    Log to Console    ---> ${UE_register_complete_pattern}
    Print Matching Lines from Output File    ${output}    ${Register_complete_pattern}
    Initial Success Message for UE Register and Reregister   ${output}
    wtsrunner.ue_pdu_session_setup    pdu=${pdu_id}    ue=${ue_id}    nwslice=${nw_id}    gw=${gw_id}
    Read WTS Output For Pattern And Print matching Lines    ${Initial_context_setup_pattern}    ${Timeout_SA}
    BuiltIn.Log                first_ue_register_is_ok
    [Return]      ${output}

Verify The End Marker for Xn Egate
	${output}    wtsrunner.read_wtsemu_output_until_re    expected=recvd GTP-U End Marker from 10.0.1.2:2152 via XNU    timeout=15
    ${output}    Get Lines Matching Regexp    ${output}    recvd GTP-U End Marker from 10.0.1.2:2152 via XNU   partial_match=${TRUE}
    Log to Console    ${output}

Verify The End Marker for Ng HO Egate
    [Arguments]    ${WTS_DIR}
    ${status} =   run    command=sudo cat ${WTS_DIR}/upf_1* | grep "End marker received? "
    Builtin.Log   ${status}
    Should Not Be Empty    ${status}
    Should Not Contain    ${status}    End marker received? No


CheckqosFlowsAcceptedForDataForwarding Xnap
    [Arguments]    ${file_path}   ${num_qos}   ${att_val}
    ${pdmlFile} =    Get filtered PDML file from pcap   pcapFile=${file_path}    filterExp=xnap.qosFlowsAcceptedForDataForwarding_List
    ${pdml_entries}    taf_pdml_analyser.get_pdml_entries     ${pdmlFile}
	...          field_name=xnap.qosFlowsAcceptedForDataForwarding_List     attrib_name=show     attrib_value=${att_val}
    ${attrib_values}    taf_pdml_analyser.get_attrib_value_from_pdml_entries    ${pdml_entries}
    ...    field_name=xnap.qosFlowIdentifier  attrib_name=showname
    ${cnt}=  Get length  ${attrib_values}
    should be equal    ${cnt}    ${num_qos}

CheckqosFlowsAcceptedForDataForwarding Ngap RealtoSim
    [Arguments]    ${file_path}   ${num_qos}    ${att_val}
    ${pdmlFile} =    Get filtered PDML file from pcap    pcapFile=${file_path}   filterExp=ngap.qosFlowToBeForwardedList
    ${pdml_entries}    taf_pdml_analyser.get_pdml_entries     ${pdmlFile}
	...          field_name=ngap.qosFlowToBeForwardedList   attrib_name=show     attrib_value=${att_val}
    ${attrib_values}    taf_pdml_analyser.get_attrib_value_from_pdml_entries    ${pdml_entries}
    ...    field_name=ngap.qosFlowIdentifier  attrib_name=showname
    ${cnt}=  Get length  ${attrib_values}
    should be equal    ${cnt}    ${num_qos}


CheckqosFlowsAcceptedForDataForwarding Ngap SimtoReal
    [Arguments]    ${file_path}   ${num_qos}    ${att_val}
    ${pdmlFile} =    Get filtered PDML file from pcap    pcapFile=${file_path}   filterExp=ngap.QosFlowSetupRequestList
    ${pdml_entries}    taf_pdml_analyser.get_pdml_entries     ${pdmlFile}
	...          field_name=ngap.QosFlowSetupRequestList     attrib_name=show     attrib_value=${att_val}
    ${attrib_values}    taf_pdml_analyser.get_attrib_value_from_pdml_entries    ${pdml_entries}
    ...    field_name=ngap.qosFlowIdentifier  attrib_name=showname
    ${cnt}=  Get length  ${attrib_values}
    should be equal    ${cnt}    ${num_qos}


Check Counters CNI10466
    Wait For Next Full Pm Interval
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    ${F1_UE_CTXT_MOD_REQ_SENT}    ta5g_pm_counters.get_pm_counter_value    M55113C00001    MRBTS-1/NRBTS-1/NRCELL-1    ${pm_counter_file}
    ${F1_UE_CTXT_MOD_RESP_RECEIVED}    ta5g_pm_counters.get_pm_counter_value   M55113C00002    MRBTS-1/NRBTS-1/NRCELL-1    ${pm_counter_file}
	${F1_UE_CTXT_MOD_FAIL_RECEIVED}    ta5g_pm_counters.get_pm_counter_value     M55113C00003    MRBTS-1/NRBTS-1/NRCELL-1    ${pm_counter_file}
    ${NNGCC_PDUSESMODRSP_SUCC_SENT}    ta5g_pm_counters.get_pm_counter_value    M55125C03502    MRBTS-1/NRBTS-1/NRCELL-1    ${pm_counter_file}
    ${NNGCC_PDUSESMODREQ_RECD}    ta5g_pm_counters.get_pm_counter_value     M55125C03501     MRBTS-1/NRBTS-1/NRCELL-1    ${pm_counter_file}
    ${NG_FLOW_SETUP_FAIL_RRNA}   ta5g_pm_counters.get_pm_counter_value     M55125C10501     MRBTS-1/NRBTS-1/NRCELL-1    ${pm_counter_file}
    ${NRRCC_RRC_RECONF_CMP_RECD}    ta5g_pm_counters.get_pm_counter_value     M55124C03002     MRBTS-1/NRBTS-1/NRCELL-1    ${pm_counter_file}
    ${NRRCC_RRC_RECONF_SENT}    ta5g_pm_counters.get_pm_counter_value     M55124C03001    MRBTS-1/NRBTS-1/NRCELL-1    ${pm_counter_file}
	Should be True   ${F1_UE_CTXT_MOD_REQ_SENT}[0] == ${F1_UE_CTXT_MOD_RESP_RECEIVED}[0]
	Should be True   ${NNGCC_PDUSESMODREQ_RECD}[0] == ${NNGCC_PDUSESMODRSP_SUCC_SENT}[0]
	Should be True   ${NRRCC_RRC_RECONF_SENT}[0] == ${NRRCC_RRC_RECONF_CMP_RECD}[0]
	Should be True   ${F1_UE_CTXT_MOD_FAIL_RECEIVED}[0] == 0
	Should be True   ${NG_FLOW_SETUP_FAIL_RRNA}[0] == 1

Register ALL Ues and Send Low data
    [Arguments]     ${Start_ue}    ${End_ue}
    ${crnti_list}     Create List
    FOR    ${ue_id}    IN RANGE    ${Start_ue}   ${End_ue}+1
    ${rnti}    WTS_Runner_Keywords.UE Register should be Successful And Fetch RNTI    ${ue_id}
    Append to list   ${crnti_list}    ${rnti}
    WTS_Runner_Keywords.Trigger DL Data Traffic for SA   ue_id=${ue_id}    Traffic_rate=kbps     dl_rate=15    pdu_id=1    trf_id=1
    END

Change Default 5QI Value Qos Flow
   [Arguments]   ${qos_flow}    ${5qi}   ${type}=gbr   ${default}=on   ${dummy}=9
   wtsrunner.qosflow_modify  qos_flow=${qos_flow}  5qi=${dummy}  fiveqi_type=non-gbr    default=${default}
   wtsrunner.qosflow_modify  qos_flow=${qos_flow}  5qi=${5qi}  fiveqi_type=${type}  default=${default}

Deregister Multiple Ues
    [Arguments]     ${Start_ue}    ${End_ue}
    ${crnti_list}     Create List
    FOR    ${ue_id}    IN RANGE    ${Start_ue}   ${End_ue}+1
       Wait Until Keyword Succeeds    5 min	  30 sec  Ue Deregister   ${ue_id}
    END

QosFlow addition should be Successful
   [Arguments]    ${start_ueid}    ${end_ueid}    ${qosflows_to_add}    ${qfi_ids}    ${pdu_id}=1
    FOR    ${ue_id}    IN RANGE    ${start_ueid}    ${end_ueid}+1
    Add Multiple Qos flow to Ues and send data   ${ue_id}   ${qosflows_to_add}    ${qfi_ids}    ${pdu_id}
    END

Add Multiple Qos flow to Ues and send data
    [Arguments]    ${ue_id}   ${qosflows_to_add}    ${qfi_ids}     ${pdu_id}=1
    FOR    ${qosflow}    IN    &{qosflows_to_add}
    WTS_Runner_Keywords.UE PDU Modfication should be Successful    ${ue_id}   pdu_id=${pdu_id}   qosflows_to_add=${qosflow}[0]
    Sleep   2s
    Run Keyword If    ${qosflow}[1]==1    Run Keywords
    ...    Trigger VoNR DL Traffic for SA     ue_id=${ue_id}   trf_id=1   qfi_id=${qfi_ids}[${qosflow}[1]]   rtp_codec=custom
    ...    AND    Trigger VoNR UL Traffic for SA    ue_id=${ue_id}   trf_id=1   qfi_id=${qfi_ids}[${qosflow}[1]]   rtp_codec=custom
    ...    ELSE   Run Keywords
    ...    Trigger DL Traffic for SA   ue_id=${ue_id}    Traffic_rate=mbps     dl_rate=1    pdu_id=${pdu_id}
    ...    trf_id=1    qfi_id=${qfi_ids}[${qosflow}[1]]
    ...    AND    Trigger UL Traffic for SA   ue_id=${ue_id}    Traffic_rate=mbps     ul_rate=1    pdu_id=${pdu_id}
    ...    trf_id=1    qfi_id=${qfi_ids}[${qosflow}[1]]
    END

Set Core Network Assistance info
    [Arguments]    ${ue_idx}   ${mnc}    ${mcc}
    Log to Console     Setting Core Network Assistance Info
    wtsrunner.amf_ue_ics_param id=1 ue=${ue_idx}    trace_activation=on  trace_plmn=${mnc}:${mcc}
    ...   trace_ref_id=1    trace_rec_session_ref_id=1  trace_depth=minimum    ifaces_to_trace=NG-C    tce_ip=10.0.1.1
    ...   core_network_assistance_info=on    ue_identity_index_value=1    ue_specific_drx=64    periodic_registration_update_timer=1:1min
    ...   plmn_id=${mnc}:${mcc}    tac_id=200
    ${output}    Read WTS Output Until Pattern Matches    ${network_core}    timeout=${EGATE_COMMAND_TIMEOUT}

Ue RRC Inactive state should be successful
    [Arguments]   ${start_ue_rrcinac}    ${end_ue_rrcinac}    ${mnc}=310    ${mcc}=260
    MultiUE Register should be Successful with CNAI and wait to Inactive state     ${start_ue_rrcinac}    ${end_ue_rrcinac}     mnc=${mnc}
	...    mcc=${mcc}

Start Multi UE DL traffic with multiple trafficID
    [Arguments]   ${start_ue}   ${end_ue}    ${Traffic_rate}    ${dl_trf_id}    ${qfi_id}    ${dl_rate_DL}
    FOR   ${TRF_ID}  IN RANGE   1    ${dl_trf_id}+1
        MultiUE Trigger DL Traffic for SA    ${start_ue}    ${end_ue}    ${Traffic_rate}     ${dl_rate_DL}    pdu_id=1
        ...    trf_id=${TRF_ID}    qfi_id=${qfi_id}
    END

Start Multi UE UL traffic with multiple trafficID
    [Arguments]   ${start_ue}   ${end_ue}   ${Traffic_rate}   ${ul_trf_id}    ${qfi_id}    ${ul_rate_UL}
    FOR   ${TRF_ID}  IN RANGE   1    ${ul_trf_id}+1
        MultiUE Trigger UL Traffic for SA    ${start_ue}   ${end_ue}    ${Traffic_rate}    ${ul_rate_UL}    pdu_id=1
        ...    trf_id=${TRF_ID}    qfi_id=${qfi_id}
    END

MultiUE Register should be Successful with CNAI and wait to Inactive state
    [Arguments]    ${start_ue_id}   ${end_ue_id}    ${mnc}    ${mcc}
    [Documentation]    This keyword checks the message for the completion of UE registration in the output file for the SA varianti
    ${crnti_list}       Create List
    FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    Set Core Network Assistance info    ${ue_idx}    ${mnc}    ${mcc}
    wtsrunner.ue_register   id=${ue_id}
    ${output}    Read WTS Output Until Pattern Matches    ${UE_register_complete_pattern}    ${Timeout_SA}
	Create File     ${OUTPUT_DIR}/regst.txt     ${output}
	${crnti_value}=    Run     cat ${OUTPUT_DIR}/regst.txt |grep -i crnti |awk -F 'crnti:' '{print $2}'|cut -d ' ' -f 2
	BuiltIn.Log     ${crnti_value}
	Log to Console             ue${ue_idx}_register_is_ok with ${crnti_value}
	Append To List  ${crnti_list}   ${crnti_value}
	wtsrunner.set_pdu_param     ue=${ue_id}    pdu=${pdu_id}    trf_type=internal
    wtsrunner.ue_pdu_session_setup    pdu=${pdu_id}    ue=${ue_id}    nwslice=${nw_id}    gw=${gw_id}
	${output}    Read WTS Output Until Pattern Matches    pass_regexp=.*Is INACTIVE       timeout=300
    BuiltIn.Log        ue=${ue_idx} with crnti=${crnti_value} is regtd ,pdu=1 created and its crnti is appended in list ${crnti_list}
    END
    Log to Console             multi_ue_register_is_ok with ${crnti_list}
    BuiltIn.Log                multi_ue_register_is_ok with ${crnti_list}
    BuiltIn.Log                CRntilist:${crnti_list}
    [Return]      ${crnti_list}


Register UE with GBR and check default bearer and PDCP length New
    [Arguments]    ${ue_id}    ${default_drb}    ${pdcplength}
    Run Keyword If    ${Validation}==${True}    Start Log    btslog   cprt
    ${rnti}    WTS_Runner_Keywords.UE Register should be Successful And Fetch RNTI    ue_id=${UEID}
    WTS_Runner_Keywords.Trigger DL Data Traffic for SA    ue_id=${ue_id}      Traffic_rate=mbps     dl_rate=1     pdu_id=1   trf_id=1
    WTS_Runner_Keywords.Trigger UL Data Traffic for SA    ue_id=${ue_id}      Traffic_rate=mbps     ul_rate=1     pdu_id=1   trf_id=1
    ${attach_5QI1}    Run Keyword If    ${Validation}==${True}    Stop Log    btslog   cprt    test_scenario=attach_${UEID}
    Run Keyword If    ${Validation}==${True}    Checkdrbdefault    ${attach_5QI1}[cprt]   ${default_drb}
    Run Keyword If    ${Validation}==${True}    CheckPDCPLength    ${attach_5QI1}[cprt]   ${pdcplength}

Add Qos flow and check PDCP Lenght and Default DRB New
    [Arguments]   ${ue_id}   ${pdu_id}    ${flow_dict}    ${5QI}
    Run Keyword If    ${Validation}==${True}     Start Log    btslog   cprt
    ${value}    Get From Dictionary   ${flow_dict}    ${5QI}
    WTS_Runner_Keywords.UE PDU Modfication should be Successful    ue_id=${ue_id}      pdu_id=${pdu_id}     qosflows_to_add=${value}[0]
    WTS_Runner_Keywords.Trigger DL Traffic for SA    ue_id=${ue_id}      Traffic_rate=mbps     dl_rate=1     pdu_id=${pdu_id}   trf_id=1    qfi_id=${5QI}
    WTS_Runner_Keywords.Trigger UL Traffic for SA    ue_id=${ue_id}      Traffic_rate=mbps     ul_rate=1     pdu_id=${pdu_id}   trf_id=1    qfi_id=${5QI}
    ${add_qosflow}    Run Keyword If    ${Validation}==${True}     Stop Log    btslog   cprt    test_scenario=add_PDU1_${5QI}
    Run Keyword If    ${Validation}==${True}    CheckPDCPLength   ${add_qosflow}[cprt]   ${value}[1]
    Run Keyword If    ${Validation}==${True}    Checkdrbdefault    ${add_qosflow}[cprt]   ${value}[2]

Add PDU to UE and send data Check PDCP Lenght and Default DRB New
    [Arguments]   ${ue_id}   ${pdu_id}    ${nw_id}    ${gw_id}    ${default_drb}    ${pdcplength}
    Run Keyword If    ${Validation}==${True}    Start Log    btslog   cprt
    WTS_Runner_Keywords.UE PDU Addition should be Successful    ue_id=${ue_id}     pdu_id=${pdu_id}     nw_id=${nw_id}    gw_id=${gw_id}
    WTS_Runner_Keywords.Trigger DL Data Traffic for SA    ue_id=${ue_id}      Traffic_rate=mbps     dl_rate=1     pdu_id=${pdu_id}   trf_id=1
    WTS_Runner_Keywords.Trigger UL Data Traffic for SA    ue_id=${ue_id}      Traffic_rate=mbps     ul_rate=1     pdu_id=${pdu_id}   trf_id=1
    ${add_pdu}  Run Keyword If    ${Validation}==${True}   Stop Log    btslog   cprt    test_scenario=add_pdu_${ue_id}_${pdu_id}
    Run Keyword If    ${Validation}==${True}  Checkdrbdefault    ${add_pdu}[cprt]     ${default_drb}
    Run Keyword If    ${Validation}==${True}  CheckPDCPLength    ${add_pdu}[cprt]     ${pdcplength}

Checkdrbdefault
    [Arguments]    ${file_path}   ${status}
    ${pdmlFile} =    Get filtered PDML file from pcap   pcapFile=${file_path}/NODECPRT_GNB.pcap    filterExp=e1ap
    ${defaultDRB}   Set Variable If    '${status}' == 'false'    defaultDRB: ${status} (1)     defaultDRB: ${status} (0)
    ${pdmlentry}     get_pdml_entries    ${pdmlFile}
	...          field_name=e1ap.defaultDRB     attrib_name=showname  attrib_value=${defaultDRB}
    ${attrib_value}    taf_pdml_analyser.get_attrib_value_from_pdml_entries   ${pdmlentry}
	...          field_name=e1ap.defaultDRB     attrib_name=showname
    Run Keyword And Continue On Failure    Should Contain   ${attrib_value}[0]    ${status}

CheckPDCPLength
    [Arguments]    ${file_path}   ${length}
    ${pdmlFile} =    Get filtered PDML file from pcap   pcapFile=${file_path}/NODECPRT_GNB.pcap    filterExp=e1ap
    Set Suite Variable    ${length}
    IF   ${length}==18
        Run Keyword   PDCPLength for 18 bits    ${pdmlFile}
    ELSE
        Run Keyword   PDCPLength for 12 bits    ${pdmlFile}
    END
    ${pdml_entriesUL}    taf_pdml_analyser.get_attrib_value_from_pdml_entries   ${pdmlentryUL}
	  ...          field_name=e1ap.pDCP_SN_Size_UL     attrib_name=showname
	  ${pdml_entriesDL}    taf_pdml_analyser.get_attrib_value_from_pdml_entries   ${pdmlentryDL}
    ...          field_name=e1ap.pDCP_SN_Size_DL     attrib_name=showname
	  Run Keyword And Continue On Failure    Should Contain   ${pdml_entriesUL}[0]    ${length}
	  Run Keyword And Continue On Failure    Should Contain   ${pdml_entriesDL}[0]    ${length}

PDCPLength for 18 bits
    [Arguments]    ${pdmlFile}
    ${pdmlentryUL}     get_pdml_entries    ${pdmlFile}
	  ...          field_name=e1ap.pDCP_SN_Size_UL     attrib_name=showname    attrib_value=pDCP-SN-Size-UL: s-${length} (1)
    Set Suite Variable    ${pdmlentryUL}
	  ${pdmlentryDL}     get_pdml_entries     ${pdmlFile}
	  ...          field_name=e1ap.pDCP_SN_Size_DL     attrib_name=showname    attrib_value=pDCP-SN-Size-DL: s-${length} (1)
    Set Suite Variable    ${pdmlentryDL}

PDCPLength for 12 bits
    [Arguments]    ${pdmlFile}
    ${pdmlentryUL}     get_pdml_entries    ${pdmlFile}
	  ...          field_name=e1ap.pDCP_SN_Size_UL     attrib_name=showname    attrib_value=pDCP-SN-Size-UL: s-${length} (0)
    Set Suite Variable    ${pdmlentryUL}
	  ${pdmlentryDL}     get_pdml_entries     ${pdmlFile}
	  ...          field_name=e1ap.pDCP_SN_Size_DL     attrib_name=showname    attrib_value=pDCP-SN-Size-DL: s-${length} (0)
    Set Suite Variable    ${pdmlentryDL}
