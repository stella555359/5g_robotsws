*** Settings ***
Documentation     :copyright: Nokia
...             :author   : Prajwali Joshi
...             :contact  : prajwali.milind_joshi@nokia.com
...             This is feature specific keywords and verification.

Resource        ../Keywords/common_keywords.robot
Resource        ../../../resources/Keywords/tsharkPcapVerifyKeywords.robot
Resource        ../../../resources/Keywords/generic_kw.robot
Resource        ../../../resources/Keywords/gnb_Keywords.robot
Resource        ../../../resources/Keywords/ap_Keywords.robot
Resource        ../../../resources/Keywords/HO_KW.robot

Library      traffic_varification.py

*** Variables ***
${scf}       ${CURDIR}/../../config/scf/
${SIB1}    SystemInformationBlockType1-NR updated
${SIB2}     eNB 3 cell 1: SystemInformationBlockType2-NR updated
${SIB5}     eNB 3 cell 1: SystemInformationBlockType5-NR updated
${QFI2}    2
${location}    location
${timeout}      60
${pdu_session_modify}     Added QosFlow with QFI:2
${pdu_session_modify_1}     PDU Session Resource Modify Unsuccessful Transfer
${Pdu_session_ID}   2
${pdu_setup}    PDU SESSION ID-1 setup/reestablishment complete
${pdu_setup_2}    PDU SESSION ID-2 setup/reestablishment complete
${pdu_session_modify_delete}       Removed FiveQi
${pdu_5qi}       ngap.pDUSessionID == 1 && ngap.fiveQI ==1
${pdu_5qi_9}       ngap.pDUSessionID == 1 && ngap.fiveQI ==9
${pdu_5qi_6}       ngap.pDUSessionID == 2 && ngap.fiveQI ==6
${pdu_5qi_6_add}    ngap.pDUSessionID == 2 && ngap.fiveQI ==6 && ngap.procedureCode == 29
${pdu_5qi_5}       ngap.pDUSessionID == 2 && ngap.fiveQI ==5
${pdu_5qi6_modify}       ngap.pDUSessionID == 2 && ngap.fiveQI ==6 && ngap.procedureCode == 26
${pdu_5qi_1_2}     ngap.pDUSessionID == 2 && ngap.fiveQI == 1 && ngap.fiveQI == 2
${arp}          ngap.priorityLevelARP
${qosflowdel}     ngap.QosFlowListWithCause == 1
${qos}     ngap.qosFlowIdentifier
${modified_pdu_add}      modified_pdu_add
${modified_pdu_delete}     modified_pdu_delete
${num}      10

*** Keywords ***
Prepare testcase
	[Documentation]    This keyword loads all required configurations like scf, cfg.
	[Arguments]       ${Testcase}
    OperatingSystem.Run	    mkdir ${OUTPUT_DIR}/${Testcase}
    ${Log_Path} 	Set Variable	${OUTPUT_DIR}/${Testcase}
    #tcom.Send Delta Commissioning    ${scf}/${Testcase}.json
    tcom.Find Scfc And Send Delta Commissioning     ${Testcase}.json
    Wait Coam Site to be Ready
    Start UTE WTS     ${Testcase}.cfg
    Basic Bring up
    wtsrunner.sim_log_set
    set global variable    ${Log_Path}

Revert testcase
	[Arguments]       ${Testcase}
	#tcom.Send Delta Commissioning    ${scf}/${Testcase}_revert.json
    tcom.Find Scfc And Send Delta Commissioning     ${Testcase}_revert.json
    Wait Coam Site to be Ready

Prepare for CB007292_C_24    [Documentation]    This keyword loads all required configurations like scf, cfg.
    ${Test_CaseNumber}=     Set Variable    CB007292_C_C1_TC24
    ${Log_Path}      Create Log Directory    ${Test_CaseNumber}
    Create Basic Interface on UTE
    tcom.Send Delta Commissioning    ${scf}/Delta_C_24.json
    log to console         \n Rebooting GNB after commissioning
    GNB Reboot
    sleep   300s
    Wait Coam Site to be Ready
    Start UTE WTS     basic_setup_C24.cfg
    Basic Bring up
    wtsrunner.sim_log_set
    set global variable    ${Log_Path}

Prepare for CB007292_C_31    [Documentation]    This keyword loads all required configurations like scf, cfg.
    ${Test_CaseNumber}=     Set Variable    CB007292_C_C1_TC31
    ${Log_Path}      Create Log Directory    ${Test_CaseNumber}
    Create Basic Interface on UTE
    tcom.Send Delta Commissioning    ${scf}/Delta_C_24.json
    log to console         \n Rebooting GNB after commissioning
    GNB Reboot
    sleep   300s
    Wait Coam Site to be Ready
    Start UTE WTS     basic_setup_C_31.cfg
    Basic Bring up
    wtsrunner.sim_log_set
    set global variable    ${Log_Path}

Prepare for CB007292_D_39    [Documentation]    This keyword loads all required configurations like scf, cfg.
    ${Test_CaseNumber}=     Set Variable    CB007292_D_39
    ${Log_Path}      Create Log Directory    ${Test_CaseNumber}
    Create Basic Interface on UTE
    tcom.Send Delta Commissioning    ${scf}/Delta_D_39.json
    log to console         \n Rebooting GNB after commissioning
    GNB Reboot
    sleep   300s
    Wait Coam Site to be Ready
    Start UTE WTS     basic_setup_PLMN.cfg
    Basic Bring up
    wtsrunner.sim_log_set
    set global variable    ${Log_Path}

Prepare for CB007292_C_17    [Documentation]    This keyword loads all required configurations like scf, cfg.
    ${Test_CaseNumber}=     Set Variable    CB007292_C_C1_TC17
    ${Log_Path}      Create Log Directory    ${Test_CaseNumber}
    Create Basic Interface on UTE
    tcom.Send Delta Commissioning    ${scf}/Delta_C_24.json
    log to console         \n Rebooting GNB after commissioning
    GNB Reboot
    sleep   300s
    Wait Coam Site to be Ready
    Start UTE WTS     basic_setup_C_TC17.cfg
    Basic Bring up
    wtsrunner.sim_log_set
    set global variable    ${Log_Path}

Prepare for CB007292_C_37    [Documentation]    This keyword loads all required configurations like scf, cfg.
    ${Test_CaseNumber}=     Set Variable    CB007292_C_C1_TC37
    ${Log_Path}      Create Log Directory    ${Test_CaseNumber}
    Create Basic Interface on UTE
    tcom.Send Delta Commissioning    ${scf}/Delta_Configuration_C_37.json
    log to console         \n Rebooting GNB after commissioning
    GNB Reboot
    sleep   300s
    Wait Coam Site to be Ready
    Start UTE WTS     basic_setup_C_C1_TC37.cfg
    Basic Bring up
    wtsrunner.sim_log_set
    set global variable    ${Log_Path}

Prepare for CB007292_C_22    [Documentation]    This keyword loads all required configurations like scf, cfg.
    ${Test_CaseNumber}=     Set Variable    CB007292_C_B4_TC22
    ${Log_Path}      Create Log Directory    ${Test_CaseNumber}
    Create Basic Interface on UTE
    tcom.Send Delta Commissioning    ${scf}/Delta_Configuration_C_22.json
    log to console         \n Rebooting GNB after commissioning
    GNB Reboot
    sleep   300s
    Wait Coam Site to be Ready
    Start UTE WTS     basic_setup_C_B4_TC22.cfg
    Basic Bring up
    wtsrunner.sim_log_set
    set global variable    ${Log_Path}

Verify SIB for gnb 3
    [Documentation]    This is to receive SIB from RAN SIM GNB.
     wtsrunner.gnb_param    id=3    sib1_period=40
     sleep    2s
     read_wtsemu_output_until      ${SIB1}     ${timeout}
     wtsrunner.gnb_param    id=3    sib2_period=40
     sleep    2s
     read_wtsemu_output_until      ${SIB2}     ${timeout}
     wtsrunner.gnb_param    id=3  sib5_period=40
     sleep    2s
     read_wtsemu_output_until      ${SIB5}     ${timeout}
     sleep    2s

Change UE location
    [Arguments]    ${ueid}    ${enb}    ${cell}
    [Documentation]    changes UE locations as per arguments.
    log to console    \nchanging UE location
    wtsrunner.ue_change_location    id=${ueid}    enb=${enb}     cell=${cell}
    run keyword and ignore error    read_wtsemu_output_until      ${location}   ${timeout}
    sleep    5s

Stop TCP Traffic
    [Arguments]       ${UE_ID}
    Log to Console    \nStopping DL + UL Traffic
    wtsrunner.trf_data_stop      ue=${UE_ID}    pdu=1   qfi=1    dir=dl
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=Stopped Downlink Internal traffic   timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    Stopped   partial_match=${TRUE}
    Log to Console    ${output}
    wtsrunner.trf_data_stop     ue=${UE_ID}   pdu=1   qfi=1    dir=ul
    ${output}    wtsrunner.read_wtsemu_output_until_re    expected=Stopping Uplink Internal traffic   timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    uplink   partial_match=${TRUE}
    Log to Console    ${output}
    sleep    5s

Modify PDU session for UE to add
    [Arguments]    ${ue_id}    ${Pdu_session}=${Pdu_session_ID}    ${QFI}=${QFI2}     ${pattern}=${pdu_session_modify}
    ue_pdu_session_modify    ue=${ue_id}    pdu=${Pdu_session}    qosflows_to_add=${QFI}   by=amf
    sleep    10s
    read_wtsemu_output_until    ${pattern}    ${timeout}
    sleep    5s

Modify PDU session for UE to modify
    [Arguments]    ${ue_id}    ${Pdu_session}=${Pdu_session_ID}    ${QFI}=${QFI2}     ${pattern}=${pdu_session_modify}
    ue_pdu_session_modify    ue=${ue_id}    pdu=${Pdu_session}    qosflows_to_modify=${QFI}   by=amf
    sleep    10s
    read_wtsemu_output_until    ${pattern}    ${timeout}
    sleep    5s

Modify PDU session for UE to delete
    [Arguments]    ${ue_id}     ${Pdu_session}=${Pdu_session_ID}    ${QFI}=${QFI2}
    ue_pdu_session_modify    ue=${ue_id}    pdu=${Pdu_session}    qosflows_to_del=${QFI}    by=amf
    read_wtsemu_output_until    ${pdu_session_modify_delete}    ${timeout}
    sleep    10s

Stop pcap collection in gNB 7292
    [Arguments]     ${name}   ${Log_Path}
    core.stop_collectors    names=${name}
    core.collect_collectors    names=${name}    target_dir=${Log_Path}
    core.teardown_collectors    names=${name}
    ${pcap_file_path}=   set variable    ${Log_Path}/${name}/${name}.pcap
    [Return]     ${pcap_file_path}

Verify QFI from PCAP
    [Arguments]   ${pcap_file_path}        ${filter}       ${field}		${arp_value}
    ${arq}    Get Fields from Pcap     ${pcap_file_path}        ${filter}      ${field}
    should be equal    ${arq}    ${arp_value}

Verify Qos deleted from PCAP
    [Arguments]   ${pcap_file_path}        ${filter}       ${field}     ${qos_delete}
    ${qos}    Get Fields from Pcap     ${pcap_file_path}         ${filter}     ${field}
    should be equal    ${qos}    ${qos_delete}

Establish Emergency RRCConnection
    [Arguments]    ${ue}
    wtsrunner.ue_nr_rrc_setup_param     id=${ue}    establishment_cause=emergency
    ue_im_exit    by=ue      id=${ue}
    sleep    10s

Validate UDP Traffic
    [Arguments]       ${UE_ID}      ${PDU_ID}     ${QFI}
    Log to Console    \nRunning DL + UL Traffic
    wtsrunner.trf_data_start     ue=${UE_ID}    pdu=${PDU_ID}   qfi=${QFI}    dir=dl    protocol=udp    mbps=1
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=UDP DL TRF   timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    TRF   partial_match=${TRUE}
    Log to Console    ${output}
    wtsrunner.trf_data_start     ue=${UE_ID}   pdu=${PDU_ID}   qfi=${QFI}   dir=ul    protocol=udp      mbps=1
    ${output}    wtsrunner.read_wtsemu_output_until_re    expected=UDP UL TRF    timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    TRF   partial_match=${TRUE}
    Log to Console    ${output}
    sleep   10s

Stop UDP Traffic
    [Arguments]       ${UE_ID}      ${PDU_ID}     ${QFI}
    Log to Console    \nStopping DL + UL Traffic
    wtsrunner.trf_data_stop      ue=${UE_ID}    pdu=${PDU_ID}   qfi=${QFI}    dir=dl
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=Stopped Downlink Internal traffic   timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    Stopped   partial_match=${TRUE}
    Log to Console    ${output}
    wtsrunner.trf_data_stop     ue=${UE_ID}   pdu=${PDU_ID}   qfi=${QFI}    dir=ul
    ${output}    wtsrunner.read_wtsemu_output_until_re    expected=Stopping Uplink Internal traffic   timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    uplink   partial_match=${TRUE}
    Log to Console    ${output}

Validate TCP Traffic
    [Arguments]       ${UE_ID}    ${PDU_ID}      ${QFI}
    Log to Console    \nRunning DL + UL Traffic
    wtsrunner.trf_data_start     ue=${UE_ID}    pdu=${PDU_ID}   qfi=${QFI}    dir=dl    protocol=tcp    seconds=300
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=TCP DL TRF   timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    TRF   partial_match=${TRUE}
    Log to Console    ${output}
    wtsrunner.trf_data_start     ue=${UE_ID}   pdu=${PDU_ID}   qfi=${QFI}    dir=ul    protocol=tcp    seconds=300
    ${output}    wtsrunner.read_wtsemu_output_until_re    expected=TCP UL TRF    timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    TRF   partial_match=${TRUE}
    Log to Console    ${output}
    sleep    5s

Validate Traffic with RTP
    [Arguments]    ${UE_ID}    ${PDU_ID}      ${QFI}
    trf_data_start     ue=${UE_ID}    pdu=${PDU_ID}   qfi=${QFI}  dir=dl  rtp_codec=amr_wb_18_25    seconds=300
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=Started Downlink RTP Internal traffic over UDP    timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    TRF:   partial_match=${TRUE}
    Log to Console    \n${output}
    trf_data_start     ue=${UE_ID}   pdu=${PDU_ID}   qfi=${QFI}  dir=ul    rtp_codec=amr_wb_18_25    seconds=300
    ${output}    wtsrunner.read_wtsemu_output_until_re    expected=Started Uplink RTP Internal traffic over UDP   timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    TRF:   partial_match=${TRUE}
    Log to Console    \n${output}
    Sleep    5s

SA registration and internal traffice on PDU-1 and PDU-2
     wtsrunner.ue_register  id=1
	 ${Attach}	Run keyword and return status	wtsrunner.Read_Wtsemu_Output_Until	expected=UE now in NG RM Registered state	timeout=10
	 Run keyword if	${Attach}==False	wtsrunner.ue_register  id=1
	 Run keyword if	${Attach}==False	wtsrunner.Read_Wtsemu_Output_Until	expected=UE now in NG RM Registered state	timeout=10
	 Log to Console    \nRegistration sucessful
     wtsrunner.set_pdu_param    ue=1    pdu=1   trf_type=internal
     wtsrunner.set_pdu_param    ue=1   pdu=2   trf_type=internal
     wtsrunner.ue_pdu_session_setup     ue=1    pdu=1   nwslice=1   gw=1
     sleep  5s
     Read WTS Output For Pattern And Print matching Lines    ${pdu_setup}    ${Timeout_SA}
     sleep  10s

qosflow_modify_5QI-6
    [Arguments]       ${qos_flow}
    wtsrunner.qosflow_modify     qos_flow=${qos_flow}     default=on
    wtsrunner.ue_pdu_session_setup     ue=1    pdu=2   nwslice=1   gw=2
    sleep   10s
    Read WTS Output For Pattern And Print matching Lines    ${pdu_setup_2}    ${Timeout_SA}
    sleep    10s

Displays bearer statistics
    [Arguments]    ${ue_id}    ${QFI1}    ${pdu_id}=${pdu_id}
    LOG TO CONSOLE     \n Bearer stats for UE '${ue_id}' in DL direction
    bearer_stats    ue=${ue_id}   qfi=${QFI1}    pdu=${pdu_id}    dir=dl
    read_wtsemu_output_until       L3 stats for internal traffic     60
    sleep    10s
    LOG TO CONSOLE     \n Bearer stats for UE '${ue_id}' in UL direction
    bearer_stats    ue=${ue_id}    qfi=${QFI1}    dir=ul     pdu=${pdu_id}
    read_wtsemu_output_until       L3 stats for internal traffic     60
    sleep    10s

Verify ARP from PCAP
    [Arguments]   ${pcap_file_path}        ${filter}       ${field}     ${arp_value}
    ${arq}    Get Fields from Pcap     ${pcap_file_path}        ${filter}      ${field}
    should be equal    ${arq}    ${arp_value}

Verify ARP for Non GBR from PCAP
    [Arguments]   ${pcap_file_path}        ${filter}       ${field}     ${arp_value}
    ${arq}    Get Fields from Pcap     ${pcap_file_path}        ${filter}      ${field}
    should be equal    ${arq}   ${arp_value}

Set priority for Qosflows
    [Arguments]    ${qos_flow}    ${PR}
    qosflow_modify     qos_flow=${qos_flow}    priority=${PR}
    log to console     \n Set priority ${PR} for Qos flow id ${qos_flow}
    qosflow_disp

qosflow_modify_5QI-5
    [Arguments]       ${qos_flow}
    wtsrunner.qosflow_modify     qos_flow=${qos_flow}     default=on
    wtsrunner.ue_pdu_session_setup     ue=1    pdu=2   nwslice=1   gw=2
    sleep   10s
    Read WTS Output For Pattern And Print matching Lines    ${pdu_setup_2}    ${Timeout_SA}
    sleep    10s

get total packets lost from bearer display
    [Arguments]    ${ue_id}    ${QFI}     ${pdu}
    LOG TO CONSOLE     \n Bearer stats for UE '${ue_id}' in UL direction
    bearer_stats     ue=${ue_id}    qfi=${QFI}    dir=dl     pdu=${pdu}
    ${output}    Read WTS Output Until Pattern Matches      Potential lost     60
    ${packet_count}    check_received_packets    ${output}
    Log to Console    \n Total Packets lost = ${packet_count}
    ${packet_value}     Evaluate      ${packet_count}<=${num}
    Should Be True     ${packet_value}
    [Return]   ${packet_count}

Verify Handover from PCAP
	[Arguments]   ${pcap_file_path}
	${ip}    Get Fields from Pcap     ${pcap_file_path}
	...	xnap && ${Five_QI_val} && ${PLMN_val} && ${RAT_val} && ip.src==10.0.1.139 && xnap.serving_PLMN == 13:20:06 && ${Restricted_PLMN}	ip.dst
	Run keyword and continue on failure		should be equal    ${ip}	10.0.1.2
	${ip}    Get Fields from Pcap     ${pcap_file_path}
	...	xnap && ${Five_QI_val} && ${PLMN_val} && ${RAT_val} && ip.src==10.0.1.2 && xnap.serving_PLMN == 13:33:04 && ${Restricted_PLMN}		ip.dst
	Run keyword and continue on failure		should be equal    ${ip}	10.0.1.139
	${ip}    Get Fields from Pcap     ${pcap_file_path}
	...		xnap.qosFlowsAdmitted_List == 2 && ip.src==10.0.1.2		ip.dst
	Run keyword and continue on failure		should be equal    ${ip}	10.0.1.139
	${ip}    Get Fields from Pcap     ${pcap_file_path}
	...		xnap.qosFlowsAdmitted_List == 2 && ip.src==10.0.1.139	ip.dst
	Run keyword and continue on failure		should be equal    ${ip}	10.0.1.2

Verify MRL
	[Arguments]   ${pcap_file_path}
	${ip}    Get Fields from Pcap     ${pcap_file_path}        ${PLMN_val} && ${RAT_val} && ip.src==10.0.1.1	ip.dst
	Run keyword and continue on failure		should be equal    ${ip}	10.0.1.2

Verify IDLE mode
	[Arguments]   ${pcap_file_path}
	${ip}    Get Fields from Pcap     ${pcap_file_path}        (ngap.radioNetwork == 20||ngap.radioNetwork == 21 ) && ip.src==10.0.1.2   ip.dst
	Run keyword and continue on failure		should be equal    ${ip}	10.0.1.1

Start Egate
	ute_wtssim.Setup Egate		egate_port=20000
    ute_wtssim.Setup Edaemon	edaemon_port=22222

Display and verify the bearer statistics
	[Arguments]   ${ue_id}    ${QFI1}    ${pdu_id}
	Displays bearer statistics		${ue_id}    ${QFI1}    ${pdu_id}
	get total packets lost from bearer display	${ue_id}    ${QFI1}    ${pdu_id}
