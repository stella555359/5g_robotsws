*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO
...             SBTS23R4    CONFIGURED

Documentation    USCB010369-B#B03_7_Successful UE Context Release due to expiration of RFSP based Inactivity timer Single Bearer without 8225
...				 USCB010369-B#B02_4_Successful RFSP based Inactivity timer configuration during Bearer Context Modification with RRCInactive
...				 Notificationlevel=UE
...
...             author:     padmashree.b@nokia.com       
...             maintainer: padmashree.b@nokia.com       
...
...             INTRODUCTION:This test scenario describes the behavior when Successful 
...     UE Context Release due to expiration of RFSP based Inactivity timer Single Bearer without 8225
...                          This test scenario describes the behavior when Successful RFSP based Inactivity timer configuration during 
...							Bearer Context Modification with RRCInactive , Notificationlevel=UE    
...             TEST SET NAME:USCB010369-B#B03_7_Successful UE Context Release due to 
...         expiration of RFSP based Inactivity timer Single Bearer without 8225 
...							  USCB010369-B#B02_4_Successful RFSP based Inactivity timer configuration during Bearer Context Modification 
...			with RRCInactive , Notificationlevel=UE   
...             TESTING SPLIT:USCB010369-B#B03 and USCB010369-B#B02
...             CONTACTS:    RAN_L2_SW_BLR_1     
...             REFERENCES: CB010769 CFAM
...             Requirement ID: 5G_RAN_USR_RRM_23641 and 5G_RAN_USR_RRM_23657

Resource         ./resources/CB010369_resource.robot

Suite Setup         Run keywords    Run Keyword and Ignore Error      Suite setup from scratch
...                 AND     Perform SCF Delta Commissioning with Delta_json_B_B03_fdd_tdd_aeqe.json
...                 AND     sleep    60
...                 AND     gnb.Perform gNB reboot
...                 AND     sleep    60
...                 AND     Load CFG and verify cell status   ${wts_cfg_file}   1   1

Suite Teardown      Run Keywords
...                 Log To console  Suiteteardown
#...                 AND     Link SCOUT SCF to Configuration ID for Reporting 
...                 AND     Run Keyword and Ignore Error     Stop Log      btslog     cprt
...                 AND     Run Keyword and Ignore Error    wts_sim_keywords.Clean edaemon and egate

*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/wts/basic_setup_fdd_tdd_aeqe.cfg
${gbr_cfg_file}     ${CURDIR}/config/wts/basic_setup_LO_AP_LO_TDD_FDD_HO_Slice.cfg
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}          /opt/iphy/latest
${UE_ID}        1
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${QFI_ID}    1
${TRF_ID}    1

${TEST_NAME}        test_case
${start_ue_id}    ${1}
${end_ue_id}      ${1}

${Traffic_rate}		mbps
${ul_rate} 			1
${dl_rate}			1


${delta}       30
${indexToRSFP}		51
${srbinactintimer}	500
${rfsp_timer}	400
${drbrrc_timer}     460

*** Test Cases ***
[1][1.0] USCB010369-B#B03_7_Successful UE Context Release due to expiration of RFSP based Inactivity timer Single Bearer without 8225
	
    Start Log      btslog     cprt
   ${ics_param_cmd}    SET VARIABLE    amf_ue_ics_param id=1 ue=${start_ue_id} indexToRFSP=${indexToRSFP} 
	ute_wtssim.Execute Egate Command    ${ics_param_cmd}    timeout=${EGATE_COMMAND_TIMEOUT}
	UE Register should be Successful	${UE_ID}     pdu_id=${Pdu_session_ID}     nw_id=${nwslice_ID}      gw_id=${gw_ID}
    Trigger DL Data Traffic for SA		${UE_ID}     ${Traffic_rate}     ${dl_rate}       pdu_id=${Pdu_session_ID}     trf_id=${TRF_ID}
	Trigger UL Data Traffic for SA		${UE_ID}     ${Traffic_rate}     ${ul_rate}       pdu_id=${Pdu_session_ID}     trf_id=${TRF_ID}
	
	${trf_stop_cmd}     SET VARIABLE    trf_data_stop ue=${UE_ID} pdu=${Pdu_session_ID}
	${datastop_time}      Get Time
    ${output}       ute_wtssim.Execute Egate Command And Wait For Data   ${trf_stop_cmd}    
    ...     pass_regexp=Received UE Context Release Complete   timeout=520
	${release_time}     Get Time
    ${scen1}     Stop Log      btslog     cprt
	Should Contain  ${output}   Received RRC Release
	Verify Timer	${datastop_time}	${release_time}		${srbinactintimer}
	Verify Pcap messages bearersetup		${scen1}[cprt]/NODECPRT_GNB.pcap		${start_ue_id}		${indexToRSFP}

	
    Builtin.Log     [1]USCB010369-B#B02_4_Successful RFSP based Inactivity timer configuration during Bearer Context Modification
    Comment         verify with 8225 with bearer context modification Notificationlevel=UE

    Enable GBR Configuration
    Start Log      btslog     cprt
    Set ICS with cnai       ${UE_ID}
    UE Register should be Successful    ${UE_ID}     pdu_id=${Pdu_session_ID}     nw_id=${nwslice_ID}      gw_id=${gw_ID}
    Modify Ue context with RFSPID       ${UE_ID}    ${indexToRSFP}
    Modify PDU Session      ${UE_ID}    5
    Trigger DL Data Traffic for SA      ${UE_ID}     ${Traffic_rate}     ${dl_rate}       pdu_id=${Pdu_session_ID}     trf_id=${TRF_ID}
    Trigger UL Data Traffic for SA      ${UE_ID}     ${Traffic_rate}     ${ul_rate}       pdu_id=${Pdu_session_ID}     trf_id=${TRF_ID}
    ${trf_stop_cmd}     SET VARIABLE    trf_data_stop ue=${UE_ID} pdu=${Pdu_session_ID}
    ${datastop_time}      Get Time
    ${output}       ute_wtssim.Execute Egate Command And Wait For Data   ${trf_stop_cmd}    pass_regexp=Is INACTIVE   timeout=520
    ${release_time}     Get Time
    ${scen1}     Stop Log      btslog     cprt
    Verify Timer    ${datastop_time}    ${release_time}     ${srbinactintimer}
    Verify Pcap messages bearermodify        ${scen1}[cprt]/NODECPRT_GNB.pcap        ${start_ue_id}      ${indexToRSFP}	
    [Teardown]    Link SCOUT SCF to Configuration ID for Reporting


*** Keywords ***
Verify Timer
	[Arguments]		${time1}	${time2}	${timer}
	${datastop_time}    Split String    ${time1}
    ${release_time}     Split String    ${time2}
    ${time_diff}    DateTime.Subtract time from time     ${release_time}[${1}]        ${datastop_time}[${1}]
    ${result}         Evaluate    (${timer} + 4.0) >= ${time_diff} >= (${timer} - 4.0)
    Should Be True    ${result}
	
Verify Pcap messages bearersetup
	[Arguments]         ${pcap_file}    ${idx}		${rfspid}
	${packet}        set variable	e1ap || f1ap || ngap
    ${pdmlFile}=   Fetch filtered PDML file from pcap    ${pcap_file}         filterExp=${packet}       filterName=UE_${idx}
	${inicontext_packet}      analyzer.get_shownames     pdmlFile=${pdmlFile}
    ...                                                packetName=ngap.InitialContextSetupRequest_element
    ...                                                path=ngap.IndexToRFSP
    ...                                                 endPacket=-${1}
    Should Contain Match          ${inicontext_packet}     IndexToRFSP: ${rfspid}
	${bearercontext_packet}      analyzer.get_shownames        pdmlFile=${pdmlFile}
    ...                                                packetName=e1ap.BearerContextSetupRequest_element
    ...                                                path=e1ap.Inactivity_Timer
    ...                                                endPacket=-${1}
    Should Contain Match          ${bearercontext_packet}         Inactivity-Timer: ${rfsp_timer}s
	${path_count}      analyzer.count_path     pdmlFile=${pdmlFile}
    ...                                                packetName=e1ap.BearerContextInactivityNotification_element
    ...                                                path=e1ap.BearerContextInactivityNotification_element$
    Should Be Equal As Numbers     ${path_count}   1
    ${path_count}      analyzer.count_path     pdmlFile=${pdmlFile}
    ...                                                packetName=f1ap.UEContextReleaseComplete_element
    ...                                                path=f1ap.UEContextReleaseComplete_element$
    Should Be Equal As Numbers     ${path_count}   1
	${bearerinact_packet}      analyzer.get_shownames     pdmlFile=${pdmlFile}
    ...                                                packetName=e1ap.BearerContextInactivityNotification_element
    ...                                                path=e1ap.uE_Activity
    ...                                                 endPacket=-${1}
    Should Contain Match          ${bearerinact_packet}     uE-Activity: not-active (1)

Set ICS with cnai
    [Arguments]     ${ueid}
    ${ics_rfsp}    SET VARIABLE    amf_ue_ics_param id=1 ue=${ueid}
    ${ics_cnai}    SET VARIABLE     core_network_assistance_info=
    ${cnaiprm}   SET VARIABLE    on ue_identity_index_value=1 ue_specific_drx=64 periodic_registration_update_timer=5:1min
    ${plmntac}  SET VARIABLE    plmn_id=311:489 tac_id=200
    Run keyword If  ${ueid}==1  ute_wtssim.Execute Egate Command    ${ics_rfsp} ${ics_cnai}${cnaiprm} ${plmntac}    ELSE
    ...    ute_wtssim.Execute Egate Command     ${ics_rfsp} ${ics_cnai}off

Modify Ue context with RFSPID
    [Arguments]     ${UE_ID}    ${indexToRSFP}
    ${ue_ctx_cmd}   SET VARIABLE    ue_ctx_ng_mod id=${UE_ID} indexToRFSP=${indexToRSFP}
    ute_wtssim.Execute Egate Command    ${ue_ctx_cmd}    timeout=${EGATE_COMMAND_TIMEOUT}

Modify PDU Session
    [Arguments]     ${UE_ID}    ${qosflow}
    ${ue_pdu_cmd}       SET VARIABLE    ue_pdu_session_modify ue=${UE_ID} pdu=1 qosflows_to_add=${qosflow} by=amf
    ute_wtssim.Execute Egate Command    ${ue_pdu_cmd}    timeout=${EGATE_COMMAND_TIMEOUT}

Verify Pcap messages bearermodify
    [Arguments]         ${pcap_file}    ${idx}      ${rfspid}
    ${packet}        set variable   e1ap || f1ap || ngap
    ${pdmlFile}=   Fetch filtered PDML file from pcap    ${pcap_file}         filterExp=${packet}       filterName=UE_${idx}
    ${uecontext_packet}      analyzer.get_shownames     pdmlFile=${pdmlFile}
    ...                                                packetName=ngap.UEContextModificationRequest_element
    ...                                                path=ngap.IndexToRFSP
    ...                                                 endPacket=-${1}
    Should Contain Match          ${uecontext_packet}     IndexToRFSP: ${rfspid}
    ${bearercontext_packet}      analyzer.get_shownames        pdmlFile=${pdmlFile}
    ...                                                packetName=e1ap.BearerContextSetupRequest_element
    ...                                                path=e1ap.Inactivity_Timer
    ...                                                endPacket=-${1}
    Should Contain Match          ${bearercontext_packet}         Inactivity-Timer: ${drbrrc_timer}s
    ${path_count}      analyzer.count_path     pdmlFile=${pdmlFile}
    ...                                                packetName=ngap.PDUSessionResourceModifyResponse_element
    ...                                                path=ngap.PDUSessionResourceModifyResponse_element$
    Should Be Equal As Numbers     ${path_count}   1
    ${path_count}      analyzer.count_path     pdmlFile=${pdmlFile}
    ...                                                packetName=f1ap.UEContextReleaseComplete_element
    ...                                                path=f1ap.UEContextReleaseComplete_element$
    Should Be Equal As Numbers     ${path_count}   1
    ${bearerinact_packet}      analyzer.get_shownames     pdmlFile=${pdmlFile}
    ...                                                packetName=e1ap.BearerContextInactivityNotification_element
    ...                                                path=e1ap.uE_Activity
    ...                                                 endPacket=-${1}
    Should Contain Match          ${bearerinact_packet}     uE-Activity: not-active (1)

Enable GBR Configuration
    wts_sim_keywords.Clean edaemon and egate
    Perform SCF Delta Commissioning with Delta_Configuration_1CC_TDD_GBR_MultiUE_with_8379.json
    Sleep   60
    Perform SCF Delta Commissioning with Delta_json_B_B02_fdd_tdd_aeqe.json
    sleep    60
    gnb.Perform gNB reboot
	sleep	60
    Load CFG and verify cell status   ${gbr_cfg_file}   1  1 
