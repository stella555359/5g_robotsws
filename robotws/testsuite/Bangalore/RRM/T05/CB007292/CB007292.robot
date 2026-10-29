*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO

Documentation   :copyright: Nokia

Resource    resources/Keywords/common_keywords.robot
Resource    resources/Keywords/CB007292_KW.robot
Resource    resources/Keywords/testsuits.robot
Resource    ../resources/Keywords/configuration_id.robot

Suite Setup        Updated Suite Setup
Suite Teardown     Common Suite Teardown

*** Variables  ***
${ue}    1
${gw}    1
${cell1}    1
${enb2}    2
${enb3}    3
${qfi1}    1
${qos_flow}     2
${pdu_id}     1
${pdu2}     2
${arp_value_1}  3
${eventA5}    A5
${phycell_id}    53
${arp_value}    1
${priority}   4
${pdu2_modify_5QI_2}       Added QosFlow with QFI:2 5QI:2
${pdu2_modify_5QI_1}       Added QosFlow with QFI:3 5QI:1
${qos_delete}    1
${Five_QI_val}		xnap.fiveQI == 5 && xnap.priorityLevel == 2 && xnap.fiveQI == 1 && xnap.priorityLevel == 1 && xnap.qosFlowsToBeSetup_List == 2
${PLMN_val}			ngap.PLMNIdentity == 13:33:04 && ngap.equivalentPLMNs == 1 && ngap.servingPLMN == 13:20:06
${RAT_val}			ngap.RATRestrictionInformation.nR == 1 && ngap.TAC == 250 && ngap.forbiddenTACs == 1
${Restricted_PLMN}	xnap.rat_Restrictions == 1 && xnap.forbiddenAreaInformation == 1

*** Test Cases ***
[1]CB007292_C_17_Verify_Emergency_Non_GBR_QoS_Flow_using_PDU_Session_Setup_for_one_subsequent_PDU_session_and_related_new_and_legacy_counters
    [Tags]   QC_54824     QCD_MN_RAN      QCP_RAN_VRF
    [setup]     Prepare testcase	CB007292_C_TC17
    Wait For Next Full Pm Interval
    Start pcap collection in gNB CU     name=modified_pdu_add
    Log to Console     \n Register SA UE and Configure traffic type as internal for PDU session 1 and PDU session 2
    wtsrunner.ue_nr_rrc_setup_param     id=${ue}    establishment_cause=emergency
    SA registration and internal traffice on PDU-1 and PDU-2
    Log to Console      \n Starting and Validating UDP traffic on 5QI-9
    Validate UDP Traffic      ${ue}      ${pdu_id}     ${qfi1}
    Displays bearer statistics      ${ue}    ${qfi1}    ${pdu_id}
    get total packets lost from bearer display    1    1    1
    Log to Console      \n  This 2nd PDU session need to get establish using PDU Session Setup procedure
    qosflow_modify_5QI-6     ${qos_flow}
    Log to Console      \n Trigger DL and UL UDP data over 5QI-6 and verify
    Validate UDP Traffic      ${ue}      ${pdu2}     ${qfi1}
    Displays bearer statistics      1    1    2
     get total packets lost from bearer display    1    1    2
    ${pcap_file_path}    Stop pcap collection in gNB 7292    modified_pdu_add    ${Log_Path}
    Verify ARP from PCAP     ${pcap_file_path}      ${pdu_5qi_9}    ${arp}      15
    Verify ARP from PCAP     ${pcap_file_path}      ${pdu_5qi_6}    ${arp}      3
    Wait For Next Full Pm Interval
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55125C13031    1    NG_FLOW_SETUP_SUCC_EMC_OTH5Q
    ...     M55125C13030    1    NG_FLOW_SETUP_ATT_EMC_OTH5QI
    ...     M55125C05505    1    NNGCC_PDU_SES_STP_REQ_EC_RECD
    ...     M55125C05506    1    NNGCC_PDU_SES_STP_RESP_EC_SENT
    ...     M55124C01004    1    NRRCC_RRC_STPREQ_EMERGENCY
    ...     M55124C01024    0    NRRCC_RRC_STPREJ_EMERGENCY
    ...     M55124C04001    1    NRRCC_RRC_STPSUCC_EMERGENCY
    ...     local_moid=MRBTS-1/NRBTS-1/NRCELL-1
    ...     file_path=${pm_counter_file}
    Verify Last Counters In File
    ...     M55127C00004    1    NRRCD_RRC_STPREQ_EMERGENCY
    ...     local_moid=MRBTS-1/NRBTS-1/NRDU-1
    ...     file_path=${pm_counter_file}
    wtsrunner.ue_deregister	id=all	ue_deregister_type=switch_off
    [Teardown]      Run keywords	configuration_id.Link SCOUT SCF to Configuration ID for Reporting
	...				AND		Revert testcase		CB007292_C_TC17

[1]CB007292_C_22_Verify_Successful_Non_GBR_Emergency_call_Intra_gNB_Intra_DU_Handover
    [Tags]   QC_54826     QCD_MN_RAN      QCP_RAN_VRF
    [setup]     Prepare testcase	CB007292_C_TC22
    Wait For Next Full Pm Interval
    Start pcap collection in gNB CU     name=modified_pdu_add
    Log to Console     \n Register SA UE and Configure traffic type as internal for PDU session 1 and PDU session 2
    wtsrunner.ue_nr_rrc_setup_param     id=${ue}    establishment_cause=emergency
    SA registration and internal traffice on PDU-1 and PDU-2
    Log to Console      \n Starting and Validating UDP traffic on 5QI-9
    Validate UDP Traffic      ${ue}      ${pdu_id}     ${qfi1}
    Displays bearer statistics      ${ue}    ${qfi1}    ${pdu_id}
    get total packets lost from bearer display    1    1    1
    Log to Console    \n This 2nd PDU session need to get establish using PDU Session Setup procedure
    qosflow_modify_5QI-6     ${qos_flow}
    Log to Console      \n Trigger DL and UL UDP data over 5QI-6 and verify
    Validate UDP Traffic      ${ue}      ${pdu2}     ${qfi1}
    Displays bearer statistics      1    1    2
    get total packets lost from bearer display    1    1    2
    ${measId}    Display Measurement Configuration for UE    ${UE}    ${eventA5}
    Trigger A5 Measurement      ${UE}    ${measId}    ${phycell_id}
    ${pcap_file_path}    Stop pcap collection in gNB 7292    modified_pdu_add    ${Log_Path}
    Verify ARP from PCAP     ${pcap_file_path}      ${pdu_5qi_9}    ${arp}    15
    Verify ARP for Non GBR from PCAP     ${pcap_file_path}      ${pdu_5qi_6}    ${arp}    3
    Wait For Next Full Pm Interval
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55125C13031    1    NG_FLOW_SETUP_SUCC_EMC_OTH5Q
    ...     M55125C13030    1    NG_FLOW_SETUP_ATT_EMC_OTH5QI
    ...     M55125C05505    1    NNGCC_PDU_SES_STP_REQ_EC_RECD
    ...     M55125C05506    1    NNGCC_PDU_SES_STP_RESP_EC_SENT
    ...     M55124C01004    1    NRRCC_RRC_STPREQ_EMERGENCY
    ...     M55124C01024    0    NRRCC_RRC_STPREJ_EMERGENCY
    ...     M55124C04001    1    NRRCC_RRC_STPSUCC_EMERGENCY
    ...     M55147C00504    1    HO_PREP_EMERGENCY_SENT
    ...     M55147C00501    1    ATT_HO_EMERGENCY
    ...     M55147C00503    1    SUCC_HO_EMERGENCY
    ...     local_moid=MRBTS-1/NRBTS-1/NRCELL-1
    ...     file_path=${pm_counter_file}
    Verify Last Counters In File
    ...     M55127C00004    1    NRRCD_RRC_STPREQ_EMERGENCY
    ...     local_moid=MRBTS-1/NRBTS-1/NRDU-1
    ...     file_path=${pm_counter_file}
    wtsrunner.ue_deregister	id=all	ue_deregister_type=switch_off
    [Teardown]      Run keywords	configuration_id.Link SCOUT SCF to Configuration ID for Reporting
	...				AND		Revert testcase		CB007292_C_TC22

[1]CB007292_C_24_Verify_Emergency_GBR_QoS_Flow_5QI_2_together_with_5QI_1_in_same_PDU_Session_Modify_and_related_new_and_legacy_counters
    [Tags]   QC_54827     QCD_MN_RAN      QCP_RAN_VRF
    [setup]     Prepare testcase	CB007292_C_TC24
    Wait For Next Full Pm Interval
    Start pcap collection in gNB CU     name=modified_pdu_add
    Log to Console     \n Register SA UE and Configure traffic type as internal for PDU session 1 and PDU session 2
    wtsrunner.ue_nr_rrc_setup_param     id=${ue}    establishment_cause=emergency
    SA registration and internal traffice on PDU-1 and PDU-2
    Log to Console      \n Starting and Validating UDP traffic on 5QI-9
    Validate UDP Traffic      ${ue}      ${pdu_id}     ${qfi1}
    Displays bearer statistics      ${ue}    ${qfi1}    ${pdu_id}
    get total packets lost from bearer display    1    1    1
    Log to Console      \n  This 2nd PDU session need to get establish using PDU Session Setup procedure
    qosflow_modify_5QI-5     ${qos_flow}
    Log to Console      \n Trigger DL and UL UDP data over 5QI-6 and verify
    Validate TCP Traffic     ${ue}      ${pdu2}     ${qfi1}
    Displays bearer statistics      1    1    2
    get total packets lost from bearer display    1    1    2
    sleep    10s
    wtsrunner.ue_pdu_session_modify     ue=1    pdu=2   qosflows_to_add=3,4     by=amf
    sleep   10s
    Read WTS Output For Pattern And Print matching Lines    ${pdu2_modify_5QI_1}    ${Timeout_SA}
    Read WTS Output For Pattern And Print matching Lines    ${pdu2_modify_5QI_2}    ${Timeout_SA}
    sleep     10s
    Validate Traffic with RTP       1      2     3
    Displays bearer statistics      1      3     2
    get total packets lost from bearer display    1    3    2
    Validate UDP Traffic            1      2     2
    Displays bearer statistics      1      2     2
    get total packets lost from bearer display    1    2    2
    ${pcap_file_path}    Stop pcap collection in gNB 7292    modified_pdu_add    ${Log_Path}
    Verify ARP from PCAP     ${pcap_file_path}      ${pdu_5qi_9}    ${arp}      15
    Verify ARP from PCAP     ${pcap_file_path}      ${pdu_5qi_5}    ${arp}      2
    Verify ARP from PCAP     ${pcap_file_path}      ${pdu_5qi_1_2}    ${arp}      1,1
    Wait For Next Full Pm Interval
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55125C13031    1    NG_FLOW_SETUP_SUCC_EMC_OTH5Q
    ...     M55125C13030    1    NG_FLOW_SETUP_ATT_EMC_OTH5QI
    ...     M55125C05505    1    NNGCC_PDU_SES_STP_REQ_EC_RECD
    ...     M55125C05506    1    NNGCC_PDU_SES_STP_RESP_EC_SENT
    ...     M55124C01004    1    NRRCC_RRC_STPREQ_EMERGENCY
    ...     M55124C01024    0    NRRCC_RRC_STPREJ_EMERGENCY
    ...     M55124C04001    1    NRRCC_RRC_STPSUCC_EMERGENCY
    ...     M55125C05509    1    NNGCC_PDUSESMODREQ_EC_RECD
    ...     M55125C05510    1    NNGCC_PDUSESMODRSP_SUC_EC_SENT
    ...     local_moid=MRBTS-1/NRBTS-1/NRCELL-1
    ...     file_path=${pm_counter_file}
    Verify Last Counters In File
    ...     M55127C00004    1    NRRCD_RRC_STPREQ_EMERGENCY
    ...     local_moid=MRBTS-1/NRBTS-1/NRDU-1
    ...     file_path=${pm_counter_file}
    wtsrunner.ue_deregister	id=all	ue_deregister_type=switch_off
    [Teardown]      Run keywords	configuration_id.Link SCOUT SCF to Configuration ID for Reporting
	...				AND		Revert testcase		CB007292_C_TC24

[1]CB007292_C_31_Verify_Successful_Release_of_the_Non_GBR_Emergency_QoS flow_using_PDU Session_Modification_and_related_legacy_counters
    [Tags]   QC_54839     QCD_MN_RAN      QCP_RAN_VRF
    [setup]     Prepare testcase	CB007292_C_TC31
    Wait For Next Full Pm Interval
    Start pcap collection in gNB CU     name=modified_pdu_add
    Log to Console     \n Register SA UE and Configure traffic type as internal for PDU session 1 and PDU session 2
    wtsrunner.ue_nr_rrc_setup_param     id=${ue}    establishment_cause=emergency
    SA registration and internal traffice on PDU-1 and PDU-2
    Log to Console      \n Starting and Validating UDP traffic on 5QI-9
    Validate UDP Traffic      ${ue}      ${pdu_id}     ${qfi1}
    Displays bearer statistics      ${ue}    ${qfi1}    ${pdu_id}
    get total packets lost from bearer display    1    1    1
    Log to Console      \n  This 2nd PDU session need to get establish using PDU Session Setup procedure
    qosflow_modify_5QI-6     ${qos_flow}
    Log to Console      \n Trigger DL and UL UDP data over 5QI-6 and verify
    Validate UDP Traffic      ${ue}      ${pdu2}     ${qfi1}
    Displays bearer statistics      1    1    2
    get total packets lost from bearer display    1    1    2
    Modify PDU session for UE to add     1    2    3
    sleep    10s
    log to console    \n Deleting QFI 2
    Modify PDU session for UE to delete    1    2    2
    ${pcap_file_path}    Stop pcap collection in gNB 7292    modified_pdu_add    ${Log_Path}
    Verify ARP from PCAP     ${pcap_file_path}      ${pdu_5qi_9}    ${arp}      15
    Verify ARP from PCAP     ${pcap_file_path}      ${pdu_5qi_6}    ${arp}      3
    Verify Qos deleted from PCAP     ${pcap_file_path}     ${qosflowdel}     ${qos}     1
    Wait For Next Full Pm Interval
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55125C13031    2    NG_FLOW_SETUP_SUCC_EMC_OTH5QI
    ...     M55125C13030    2    NG_FLOW_SETUP_ATT_EMC_OTH5QI
    ...     M55125C05505    1    NNGCC_PDU_SES_STP_REQ_EC_RECD
    ...     M55125C05506    1    NNGCC_PDU_SES_STP_RESP_EC_SENT
    ...     M55124C01004    1    NRRCC_RRC_STPREQ_EMERGENCY
    ...     M55124C01024    0    NRRCC_RRC_STPREJ_EMERGENCY
    ...     M55124C04001    1    NRRCC_RRC_STPSUCC_EMERGENCY
    ...     M55125C05509    2    NNGCC_PDUSESMODREQ_EC_RECD
    ...     M55125C05510    2    NNGCC_PDUSESMODRSP_SUC_EC_SENT
    ...     local_moid=MRBTS-1/NRBTS-1/NRCELL-1
    ...     file_path=${pm_counter_file}
    Verify Last Counters In File
    ...     M55127C00004    1    NRRCD_RRC_STPREQ_EMERGENCY
    ...     local_moid=MRBTS-1/NRBTS-1/NRDU-1
    ...     file_path=${pm_counter_file}
    wtsrunner.ue_deregister	id=all	ue_deregister_type=switch_off
    [Teardown]      Run keywords	configuration_id.Link SCOUT SCF to Configuration ID for Reporting
	...				AND		Revert testcase		CB007292_C_TC31

[1]CB007292_C_37_Verify_gNB_is_not_allowing_to_modify_ARP_value_of_exising_Non_GBR_Emergency_QoS_flow
    [Tags]   QC_54841     QCD_MN_RAN      QCP_RAN_VRF
    [setup]     Prepare testcase	CB007292_C_TC37
    Wait For Next Full Pm Interval
    Start pcap collection in gNB CU     name=modified_pdu_add
    Log to Console     \n Register SA UE and Configure traffic type as internal for PDU session 1 and PDU session 2
    wtsrunner.ue_nr_rrc_setup_param     id=${ue}    establishment_cause=emergency
    SA registration and internal traffice on PDU-1 and PDU-2
    Log to Console      \n Starting and Validating UDP traffic on 5QI-9
    Validate UDP Traffic      ${ue}      ${pdu_id}     ${qfi1}
    Displays bearer statistics      ${ue}    ${qfi1}    ${pdu_id}
    get total packets lost from bearer display    1    1    1
    Log to Console      \n  This 2nd PDU session need to get establish using PDU Session Setup procedure
    qosflow_modify_5QI-6     ${qos_flow}
    Log to Console      \n Trigger DL and UL UDP data over 5QI-6 and verify
    Validate UDP Traffic      ${ue}      ${pdu2}     ${qfi1}
    Displays bearer statistics      1    1    2
    get total packets lost from bearer display    1    1    2
    sleep    10s
    Log to console      \n Change priority of 5QI-6
    Set priority for Qosflows    ${qos_flow}    ${priority}
    Log to console      \n Modifying PDU session
    Modify PDU session for UE to modify    ${ue}   ${pdu2}   ${QFI2}   ${pdu_session_modify_1}
    ${pcap_file_path}    Stop pcap collection in gNB 7292    modified_pdu_add    ${Log_Path}
    Verify ARP from PCAP     ${pcap_file_path}      ${pdu_5qi_9}    ${arp}  15
    Verify ARP for Non GBR from PCAP     ${pcap_file_path}      ${pdu_5qi_6_add}    ${arp}  3
    Verify QFI from PCAP     ${pcap_file_path}    ${pdu_5qi6_modify}    ${arp}  4
    Wait For Next Full Pm Interval
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55125C13031    1    NG_FLOW_SETUP_SUCC_EMC_OTH5Q
    ...     M55125C13030    1    NG_FLOW_SETUP_ATT_EMC_OTH5QI
    ...     M55125C05505    1    NNGCC_PDU_SES_STP_REQ_EC_RECD
    ...     M55125C05506    1    NNGCC_PDU_SES_STP_RESP_EC_SENT
    ...     M55124C01004    1    NRRCC_RRC_STPREQ_EMERGENCY
    ...     M55124C01024    0    NRRCC_RRC_STPREJ_EMERGENCY
    ...     M55124C04001    1    NRRCC_RRC_STPSUCC_EMERGENCY
    ...     local_moid=MRBTS-1/NRBTS-1/NRCELL-1
    ...     file_path=${pm_counter_file}
    Verify Last Counters In File
    ...     M55127C00004    1    NRRCD_RRC_STPREQ_EMERGENCY
    ...     local_moid=MRBTS-1/NRBTS-1/NRDU-1
    ...     file_path=${pm_counter_file}
    wtsrunner.ue_deregister	id=all	ue_deregister_type=switch_off
    [Teardown]      Run keywords	configuration_id.Link SCOUT SCF to Configuration ID for Reporting
	...				AND		Revert testcase		CB007292_C_TC37

[1]CB007292_D_39_Verify_Inter_PLMN_HO_with_Ignoring_restriction_of_Mobility_Restriction_list_in_case_of_Xn_based_inter_gNB_Emergency_call_HO
	[Tags]   	QC_54842     QCD_MN_RAN      QCP_RAN_VRF	Split_D
    [setup]     Prepare testcase	CB007292_D_TC39
	Wait For Next Full Pm Interval
    Start pcap collection in gNB CU     name=CB007292_D_39
	Log to Console		\n Adding MRL to AMF
	wtsrunner.amf_mobility_restriction_list_param 	id=1	equiv_plmn=313:340 	fa_plmn=313:340	forbidden_tacs=250	sa_plmn=313:340	allowed_tacs=200
	...		not_allowed_tacs=250	restricted_plmn=313:340	restricted_rat=nr
	Start Egate
	ute_wtssim.execute_egate_command	cmd=amf_ue_ics_param id=1 ue=1 mobility_restriction_list_id=1
	ute_wtssim.execute_egate_command	cmd=amf_ue_ng_handover_request_param id=1 mobility_restriction_list_id=1
	Log to Console		\n Registering UE
	wtsrunner.ue_register	id=1
	${Attach}	Run keyword and return status	wtsrunner.Read_Wtsemu_Output_Until	expected=UE now in NG RM Registered state	timeout=10
	Run keyword if	${Attach}==False	wtsrunner.ue_register	id=1
	Run keyword if	${Attach}==False	wtsrunner.Read_Wtsemu_Output_Until	expected=UE now in NG RM Registered state	timeout=10
	Log to Console		\n Set UE to IDLE state
	wtsrunner.ue_im_entry	id=1	by=ue
	wtsrunner.Read_Wtsemu_Output_Until	expected=UE CONTEXT RELEASE COMPLETE	timeout=100
	wtsrunner.qosflow_modify	qos_flow=1	 default=on		priority=2
	wtsrunner.set_pdu_param		ue=1	pdu=1	trf_type=internal
	wtsrunner.ue_nr_rrc_setup_param     id=1    establishment_cause=emergency
	Log to Console		\n Exiting UE from IDLE state
	wtsrunner.ue_im_exit	id=1	by=ue	service_type=emergency_services
	wtsrunner.Read_Wtsemu_Output_Until	expected=UE performed IM exit		timeout=10
	Log to Console		\n Creating PDU session
	wtsrunner.ue_pdu_session_setup	ue=1	pdu=1	nwslice=1	gw=1	request_type=initial-emergency-request
	wtsrunner.Read_Wtsemu_Output_Until	expected=Setup QosFlow with QFI:1 5QI:5		timeout=10
	Log to Console      \n Starting and Validating UDP traffic on 5QI-5
    Validate UDP Traffic			1	1	1
	Display and verify the bearer statistics      1		1	1
	wtsrunner.qosflow_modify	qos_flow=2 	priority=1
	wtsrunner.ue_pdu_session_modify		ue=1	pdu=1	qosflows_to_add=2	by=amf
	wtsrunner.Read_Wtsemu_Output_Until	expected=Added QosFlow with QFI:2 5QI:1		timeout=10
	Log to Console      \n Starting and Validating UDP traffic on 5QI-1
    Validate Traffic with RTP		1	1	2
	Display and verify the bearer statistics		1	2	1
	wtsrunner.gnb_param	id=3	ignore_NSSAI_during_HO=on
	wtsrunner.ue_disp	id=1
	wtsrunner.ue_meas_cfg_disp	id=1	meas_obj_type=nr
	Log to Console		\n Triggereing Xn HO to RANSIM
	wtsrunner.ue_measurement_send_nr	id=1	meas_id=3	event=A3	srsrp_nr=10	srsrq_nr=10	phycell_id=52	nrsrp_nr=30	nrsrq_nr=20
	wtsrunner.Read_Wtsemu_Output_Until	expected=GNB-3: UE1: XN Handover Successfully completed at Target		timeout=20
	Log to Console		\n Xn HO to RANSIM successful
	wtsrunner.ue_disp	id=1
	Display and verify the bearer statistics		1	1	1
	Display and verify the bearer statistics		1	2	1
	wtsrunner.ue_meas_cfg_disp	id=1	meas_obj_type=nr
	wtsrunner.ue_history_information_list_add_ngran	id=1	gnb_id=3	cell_type=medium	nrcgi=313:340|0x01	time_ue_stayed_in_cell=100
	wtsrunner.ue_history_information_list	id=1	action=commit
	wtsrunner.ue_enb_param	id=1	ue_history_list=1
	Verify SIB for gnb 3
	wtsrunner.gnb_param	id=3	ignore_MRL_during_HO=true
	Log to Console		\n Triggereing Xn HO from RANSIM
	wtsrunner.ue_measurement_send_nr	id=1	meas_id=1	event=A3	srsrp_nr=10	srsrq_nr=10	phycell_id=51	nrsrp_nr=30	nrsrq_nr=20
	wtsrunner.Read_Wtsemu_Output_Until		expected=GNB-3: UE1: XN Handover Successfully completed at Source		timeout=20
	Log to Console		\n Xn HO from RANSIM successful
	wtsrunner.ue_disp	id=1
	Display and verify the bearer statistics		1	1	1
	Display and verify the bearer statistics		1	2	1
    ${pcap_file_path}    Stop pcap collection in gNB 7292    CB007292_D_39    ${Log_Path}
    Verify ARP from PCAP     ${pcap_file_path}      ngap.pDUSessionID == 1 && ngap.fiveQI ==5    ${arp}      2
    Verify ARP from PCAP     ${pcap_file_path}      ngap.pDUSessionID == 1 && ngap.fiveQI ==1    ${arp}      1
	Verify Handover from PCAP	${pcap_file_path}
	Verify MRL			${pcap_file_path}
	Verify IDLE mode	${pcap_file_path}
	Wait For Next Full Pm Interval
    ${pm_counter_file}      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55125C05505    1    NNGCC_PDU_SES_STP_REQ_EC_RECD
    ...     M55125C05506    1    NNGCC_PDU_SES_STP_RESP_EC_SENT
    ...     M55125C05509    1    NNGCC_PDUSESMODREQ_EC_RECD
    ...     M55125C05510    1    NNGCC_PDUSESMODRSP_SUC_EC_SENT
    ...     M55124C04001    1    NRRCC_RRC_STPSUCC_EMERGENCY
    ...     M55124C01004    1    NRRCC_RRC_STPREQ_EMERGENCY
    ...     M55124C01024    0    NRRCC_RRC_STPREJ_EMERGENCY
	...		M55147C00501	1	 ATT_HO_EMERGENCY
	...		M55147C00503	1	 SUCC_HO_EMERGENCY
	...		M55147C00504	1	 HO_PREP_EMERGENCY_SENT
    ...     local_moid=MRBTS-1/NRBTS-1/NRCELL-1
    ...     file_path=${pm_counter_file}
	Verify Any Counters In File
	...     M55145C00341    1    ATT_OG_INTER_GNB_HO_SA_PLMN
    ...     M55145C00342    1    SUCC_OG_INTER_GNB_HO_SA_PLMN
    ...     local_moid=MRBTS-1/NRBTS-1/NRCELL-1
    ...     file_path=${pm_counter_file}
    [Teardown]      Run keywords	configuration_id.Link SCOUT SCF to Configuration ID for Reporting
	...				AND		Revert testcase		CB007292_D_TC39
