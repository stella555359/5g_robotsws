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

#Suite Setup        Update bsr package

Suite Teardown      Run Keywords
...                 Log To console  Suite_teardown
#...                 AND     Link SCOUT SCF to Configuration ID for Reporting
...                 AND     Run Keyword and Ignore Error     Stop Log      btslog     cprt
...                 AND     Run Keyword and Ignore Error    wts_sim_keywords.Clean edaemon and egate

*** Variables ***
#${wts_cfg_file}     ${CURDIR}/config/wts/basic_setup_fdd_tdd_aeqe.cfg
#${gbr_cfg_file}     ${CURDIR}/config/wts/basic_setup_LO_AP_LO_TDD_FDD_HO_Slice.cfg
#${wts_cfg_file_ab03}		${CURDIR}/config/wts/basic_setup_fdd_tdd_aeqe1.cfg
${wts_cfg_file_ab03}       ${CURDIR}/config/wts/basic_setup_slice_tmo1.cfg
${wts_cfg_file}     ${CURDIR}/config/wts/basic_setup_tmo.cfg
${gbr_cfg_file}     ${CURDIR}/config/wts/basic_setup_slice_tmo.cfg
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

${start_ue_id_ab03}    ${121}
${end_ue_id_ab03}      ${121}
${drb_ue_id}       ${101}
${spid}         ${1}
${Target_Cells}     ${2}
${Target_gNB}   ${2}
${Bearer_ID}    ${2}

# GFBR and MFBR profile <qos flow id>_gfbr_<dir>=speed
&{gfbr_mfbr_profile}                6_gfbr_ul=10   6_gfbr_dl=20    6_mfbr_ul=40     6_mfbr_dl=50
...                                 7_gfbr_ul=10   7_gfbr_dl=20    7_mfbr_ul=40     7_mfbr_dl=50
...                                 3_gfbr_ul=10   3_gfbr_dl=20    3_mfbr_ul=40     3_mfbr_dl=50
${spidinactivity_timer}      100
${spidinactivity_timer1}      300
${nsainactivity_timer}       200

@{Pdu_session_ID_b101}       1   2   3
${end_ue_id_b101}      ${3}

@{indexToRSFP_b101}		128		129		None
${rfsprrctimer}    130
${rfsptimer_1}    100
${drbrrctimer_1}     120

*** Test Cases ***
[1][1.0] USCB010369-B#B03_7_Successful UE Context Release due to expiration of RFSP based Inactivity timer Single Bearer without 8225
	[Setup]		Run keywords    Run Keyword and Ignore Error      Suite setup from scratch
	...                 AND     Perform SCF Delta Commissioning with Delta_json_B_B03_fdd_tdd_aeqe.json
	...                 AND     sleep    60
	...                 AND     gnb.Perform gNB reboot
	...                 AND     sleep    120
	...                 AND     Load CFG and verify cell status   ${wts_cfg_file}   1   1
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
    [Teardown]    Run Keywords
	...                 Log To console  Testteardown
	...                 AND     Link SCOUT SCF to Configuration ID for Reporting
	...                 AND     Run Keyword and Ignore Error     Stop Log      btslog     cprt
	...                 AND     Run Keyword and Ignore Error    wts_sim_keywords.Clean edaemon and egate

[1][1.0] USCB010369-A#B03_4_Successful SgNB Release due to expiration of SPID based Inactivity timer single bearer
	[Setup]		Run keywords    Run Keyword and Ignore Error      Suite setup from scratch
	...                 AND     Perform SCF Delta Commissioning with Delta_json_A_B03_fdd_tdd_aeqe.json
	...                 AND     sleep    60
	...                 AND     gnb.Perform gNB reboot
	...                 AND     sleep    120
	...                 AND     Load CFG and verify cell status   ${wts_cfg_file_ab03}   1   1
    Start Log      btslog     cprt

	NSA LTE Attach should be Successful		${start_ue_id_ab03}
	${enb_param_cmd}    SET VARIABLE    ue_enb_param id=${start_ue_id_ab03} spid=${spid}
    ute_wtssim.Execute Egate Command    ${enb_param_cmd}    timeout=${EGATE_COMMAND_TIMEOUT}
    NSA X2AP Link Should be UP      eNB_ID=1   eNB_target=2
	NSA UE Attach should be Successful	${start_ue_id_ab03}	${Target_Cells}

	Trigger DL Traffic for NSA      ${start_ue_id_ab03}        Traffic_rate=mbps     dl_rate=1       id=${Bearer_ID}    trf_id=${TRF_ID}
    Trigger UL Traffic for NSA      ${start_ue_id_ab03}        Traffic_rate=mbps     ul_rate=1       id=${Bearer_ID}    trf_id=${TRF_ID}


    ${trf_stop_cmd}     SET VARIABLE    trf_data_stop ue=${start_ue_id_ab03}
	${datastop_time}      Get Time
    ${output}       ute_wtssim.Execute Egate Command And Wait For Data   ${trf_stop_cmd}
    ...     pass_regexp=Bearer-type change from SCG-split to MCG is successful   timeout=120
	${release_time}     Get Time
    ${scen1}     Stop Log      btslog     cprt


#    Should Contain  ${output}   SgNBReleaseRequired
#    Should Contain  ${output}   radioNetwork : user-inactivity
    Should Contain  ${output}   SgNBReleaseConfirm
	Verify Timer	${datastop_time}	${release_time}		${spidinactivity_timer}
	Verify Pcap msgs ue		${scen1}[cprt]/NODECPRT_GNB.pcap		${spid}		${start_ue_id_ab03}

    BuiltIn.Log    [1]CB010369_A_B02_3_Successful SPID based Inactivity config during BearerContextModication nsaactivitynotificationlevel=drb
    Comment         Verify with notification level drb


    Modify NIDD parameters      nsaActivityNotificationLevel      drb        update      MRBTS-1/NRBTS-1
    Modify NIDD parameters      nsaInactivityTimer      200        update      MRBTS-1/NRBTS-1
    Modify NIDD parameters      spidInactivityTimer      300        update      MRBTS-1/NRBTS-1/NRSPID_PROFILE-1

    Start Log      btslog     cprt
    NSA LTE Attach should be Successful     ${drb_ue_id}
    NSA X2AP Link Should be UP      eNB_ID=1   eNB_target=2
    NSA UE Attach should be Successful  ${drb_ue_id}  ${Target_Cells}
    Sgnb beareradd and modify   ${drb_ue_id}      ${spid}
    Trigger DL Traffic for NSA      ${drb_ue_id}        Traffic_rate=mbps     dl_rate=1       id=${Bearer_ID}    trf_id=${TRF_ID}
    Trigger UL Traffic for NSA      ${drb_ue_id}        Traffic_rate=mbps     ul_rate=1       id=${Bearer_ID}    trf_id=${TRF_ID}
    ${trf_stop_cmd}     SET VARIABLE    trf_data_stop ue=${drb_ue_id}
    ${datastop_time}      Get Time
    ${output}       ute_wtssim.Execute Egate Command And Wait For Data   ${trf_stop_cmd}
    ...     pass_regexp=Bearer-type change from SCG-split to MCG is successful   timeout=320
    ${release_time}     Get Time
    ${scen2}     Stop Log      btslog     cprt

    Should Contain  ${output}   SgNBReleaseConfirm
    Verify Timer    ${datastop_time}    ${release_time}     ${spidinactivity_timer1}
    Verify Pcap msgs drb    ${scen2}[cprt]/NODECPRT_GNB.pcap    ${spid}     ${drb_ue_id}    ${spidinactivity_timer1}     ${nsainactivity_timer}
    [Teardown]    Run Keywords
	...                 Log To console  Testteardown
	...                 AND     Link SCOUT SCF to Configuration ID for Reporting
	...                 AND     Run Keyword and Ignore Error     Stop Log      btslog     cprt
	...                 AND     Run Keyword and Ignore Error    wts_sim_keywords.Clean edaemon and egate

[1][1.0] CB010369-B-B101_B04-1_Successful transition of UE from RRC_Connected to RRC_Inactive state due to expiration of RFSP based Inactivity timer
	[Setup]		Run keywords    Run Keyword and Ignore Error      Suite setup from scratch
	...                 AND     Perform SCF Delta Commissioning with Delta_json_B_B04_fdd_tdd_aeqe.json
	...                 AND     sleep    60
	...                 AND     gnb.Perform gNB reboot
	...                 AND     sleep    120
	...                 AND     Load CFG and verify cell status   ${wts_cfg_file}   1   1

    Comment     #### ue1 with rfsp 128 and cnai on ####
	Start Log      btslog     cprt
	Set ICS with index to RFSP		1		${indexToRSFP_b101}[0]
	UE Register should be Successful	1     pdu_id=${Pdu_session_ID_b101}[0]     nw_id=${nwslice_ID}      gw_id=${gw_ID}
	Trigger data	1     ul		pdu_id=${Pdu_session_ID_b101}[0]     trf_id=1		qfi=1  Traffic_unit=mbps		traffic_rate=1
	Trigger data	1     dl		pdu_id=${Pdu_session_ID_b101}[0]     trf_id=1		qfi=1  Traffic_unit=mbps		traffic_rate=1
	${trf_stop_cmd}     SET VARIABLE    trf_data_stop ue=1 pdu=${Pdu_session_ID_b101}[0]
	${datastop_time}      Get Time
    ${output}       ute_wtssim.Execute Egate Command And Wait For Data   ${trf_stop_cmd}    pass_regexp=UE1\: Is INACTIVE   timeout=150
	${release_time}     Get Time
    ${ue1_log}     Stop Log      btslog     cprt    test_scenario=ue1
    Run Keyword and Continue on Failure		Verify Timer	${datastop_time}	${release_time}		${rfsprrctimer}

	Comment     #### ue2 with rfsp 129 and cnai off ####
	Start Log      btslog     cprt
	Set ICS with index to RFSP		2		${indexToRSFP_b101}[1]
	UE Register should be Successful	2     pdu_id=${Pdu_session_ID_b101}[1]     nw_id=${nwslice_ID}      gw_id=${gw_ID}
	Trigger data	2     dl		pdu_id=${Pdu_session_ID_b101}[1]     trf_id=1		qfi=1  Traffic_unit=mbps		traffic_rate=1
	${trf_stop_cmd}     SET VARIABLE    trf_data_stop ue=2 pdu=${Pdu_session_ID_b101}[1]
	${datastop_time}      Get Time
    ${output}       Run keyword and continue on failure     ute_wtssim.Execute Egate Command And Wait For Data   ${trf_stop_cmd}
    ...     pass_regexp=UE2\: IS IDLE   timeout=150
	${release_time}     Get Time
    ${ue2_log}     Stop Log      btslog     cprt    test_scenario=ue2
    Run Keyword and Continue on Failure		Verify Timer	${datastop_time}	${release_time}		${rfsprrctimer}

	Comment     #### ue3 with rfsp None and cnai off ####
	Start Log      btslog     cprt
	Set ICS with index to RFSP		3		${indexToRSFP_b101}[2]
	UE Register should be Successful	3     pdu_id=${Pdu_session_ID_b101}[2]     nw_id=${nwslice_ID}      gw_id=${gw_ID}
	Trigger data	3     dl		pdu_id=${Pdu_session_ID_b101}[2]     trf_id=1		qfi=1  Traffic_unit=mbps		traffic_rate=1
	${trf_stop_cmd}     SET VARIABLE    trf_data_stop ue=3 pdu=${Pdu_session_ID_b101}[2]
	${datastop_time}      Get Time
    ${output}       Run keyword and continue on failure     ute_wtssim.Execute Egate Command And Wait For Data   ${trf_stop_cmd}
    ...     pass_regexp=UE3\: IS IDLE   timeout=150
	${release_time}     Get Time
    ${ue3_log}     Stop Log      btslog     cprt    test_scenario=ue3
    OperatingSystem.Run    cp /opt/wts/latest/egate_console.log /home/ute/Logs/
    Run Keyword and Continue on Failure		Verify Timer	${datastop_time}	${release_time}		${drbrrctimer_1}
    ${timers}   Create List     ${rfsptimer}    ${rfsprrctimer}     ${rfsprrctimer}     ${drbrrctimer_1}
    ${id}   Create List     dummy       128     129     None
    FOR     ${i}   IN RANGE    ${start_ue_id}    ${end_ue_id_b101}+1
    Verify Pcap messages    ${ue${i}_log}[cprt]/NODECPRT_GNB.pcap       ${i}    ${timers}[${i}]     ${id}[${i}]
    END
    [Teardown]    Run Keywords
	...                 Log To console  Testteardown
	...                 AND     Link SCOUT SCF to Configuration ID for Reporting
	...                 AND     Run Keyword and Ignore Error     Stop Log      btslog     cprt
	...                 AND     Run Keyword and Ignore Error    wts_sim_keywords.Clean edaemon and egate



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
#    Perform SCF Delta Commissioning with Delta_Configuration_1CC_TDD_GBR_MultiUE_with_8379.json
#    Sleep   60
    Perform SCF Delta Commissioning with Delta_json_B_B02_fdd_tdd_aeqe.json
    sleep    60
    gnb.Perform gNB reboot
    sleep	120
    Load CFG and verify cell status   ${gbr_cfg_file}   1  1

Verify Pcap msgs ue
	[Arguments]         ${pcap_file}    ${spid}		${idx}
	${packet}        set variable	e1ap || x2ap
    ${pdmlFile}=   Fetch filtered PDML file from pcap    ${pcap_file}         filterExp=${packet}       filterName=UE_${idx}
    BuiltIn.Log     ${spid}
#	${spid_packet}      analyzer.get_shownames        pdmlFile=${pdmlFile}
#    ...                                                packetName=x2ap.SgNBAdditionRequest_element
#    ...                                                path=x2ap.SubscriberProfileIDforRFP
#    ...                                                endPacket=-${1}
#    Should Contain Match           ${spid_packet}         SubscriberProfileIDforRFP: ${spid}
#	${path_count}      analyzer.count_path     pdmlFile=${pdmlFile}
#    ...                                                packetName=x2ap.SgNBAdditionRequest_element
#    ...                                                path=x2ap.SgNBAdditionRequest_element$
#    Should Be Equal As Numbers     ${path_count}   1
	${path_count}      analyzer.count_path     pdmlFile=${pdmlFile}
    ...                                                packetName=x2ap.SgNBAdditionRequestAcknowledge_element
    ...                                                path=x2ap.SgNBAdditionRequestAcknowledge_element$
    Should Be Equal As Numbers     ${path_count}   1
	${path_count}      analyzer.count_path     pdmlFile=${pdmlFile}
    ...                                                packetName=x2ap.SgNBReleaseConfirm_element
    ...                                                path=x2ap.SgNBReleaseConfirm_element$
    Should Be Equal As Numbers          ${path_count}   1
	${path_count}      analyzer.count_path     pdmlFile=${pdmlFile}
    ...                                                packetName=x2ap.SgNBReleaseRequired_element
    ...                                                path=x2ap.SgNBReleaseRequired_element$
    Should Be Equal As Numbers     ${path_count}   1
	${path_count}      analyzer.count_path     pdmlFile=${pdmlFile}
    ...                                                packetName=e1ap.BearerContextInactivityNotification_element
    ...                                                path=e1ap.BearerContextInactivityNotification_element$
    Should Not Be Equal As Numbers     ${path_count}   0
    ${bearerinact_packet}      analyzer.get_shownames     pdmlFile=${pdmlFile}
    ...                                                packetName=e1ap.BearerContextInactivityNotification_element
    ...                                                path=e1ap.uE_Activity
    ...                                                 endPacket=-${1}
    Should Contain Match          ${bearerinact_packet}     uE-Activity: not-active (1)


Sgnb beareradd and modify
    [Arguments]     ${start_ue_id}      ${spid}
    ${bearer_add_cmd}   SET VARIABLE    bearer_add ue=${start_ue_id} id=3 filter=0 precedence=0
    ute_wtssim.Execute Egate Command    ${bearer_add_cmd}    timeout=${EGATE_COMMAND_TIMEOUT}
    ${brrmod}    SET VARIABLE    enb_ue_dc_modify ue=${start_ue_id} bearer_to_add=3 by=enb cause=RN_load_balancing type=split_scg spid=${spid}
    ute_wtssim.Execute Egate Command    ${brrmod}    timeout=${EGATE_COMMAND_TIMEOUT}

Verify Pcap msgs drb
    [Arguments]         ${pcap_file}    ${spid}     ${idx}  ${spidtimer}    ${nsa_timer}
    ${packet}        set variable   e1ap || x2ap
    ${pdmlFile}=   Fetch filtered PDML file from pcap    ${pcap_file}         filterExp=${packet}       filterName=UE_${idx}
    ${spid_packet}      analyzer.get_shownames        pdmlFile=${pdmlFile}
    ...                                                packetName=x2ap.SgNBModificationRequest_element
    ...                                                path=x2ap.SubscriberProfileIDforRFP
    ...                                                endPacket=-${1}
    Should Contain Match           ${spid_packet}         SubscriberProfileIDforRFP: ${spid}
    ${bearercontext_packet}      analyzer.get_shownames        pdmlFile=${pdmlFile}
    ...                                                packetName=e1ap.BearerContextSetupRequest_element
    ...                                                path=e1ap.dRB_Inactivity_Timer
    ...                                                endPacket=-${1}
    Should Contain           ${bearercontext_packet}         dRB-Inactivity-Timer: ${nsa_timer}s
    ${bearermodify_packet}      analyzer.get_shownames        pdmlFile=${pdmlFile}
    ...                                                packetName=e1ap.BearerContextModificationRequest_element
    ...                                                path=e1ap.dRB_Inactivity_Timer
    ...                                                endPacket=-${1}
    Should Contain           ${bearermodify_packet}         dRB-Inactivity-Timer: ${spidtimer}s
    ${bearerinact_packet}      analyzer.get_shownames     pdmlFile=${pdmlFile}
    ...                                                packetName=e1ap.BearerContextInactivityNotification_element
    ...                                                path=e1ap.DRB_Activity_Item_element
    ...                                                 endPacket=-${1}
    Should Contain Match          ${bearerinact_packet}     dRB-Activity: not-active (1)
    ${path_count}      analyzer.count_path     pdmlFile=${pdmlFile}
    ...                                                packetName=x2ap.SgNBReleaseConfirm_element
    ...                                                path=x2ap.SgNBReleaseConfirm_element$
    Should Be Equal As Numbers          ${path_count}   1
    ${path_count}      analyzer.count_path     pdmlFile=${pdmlFile}
    ...                                                packetName=x2ap.SgNBReleaseRequired_element
    ...                                                path=x2ap.SgNBReleaseRequired_element$
    Should Be Equal As Numbers     ${path_count}   1

Set ICS with index to RFSP
	[Arguments]		${ueid}		${indexRSFP}
	${ics_rfsp}    SET VARIABLE    amf_ue_ics_param id=1 ue=${ueid} indexToRFSP=${indexRSFP}
	${ics_cnai}	   SET VARIABLE 	core_network_assistance_info=
	${cnai_param}	SET VARIABLE	on ue_identity_index_value=1 ue_specific_drx=64 periodic_registration_update_timer=5:1min plmn_id=311:489 tac_id=2
	Run keyword If	${ueid}==1	ute_wtssim.Execute Egate Command	${ics_rfsp} ${ics_cnai}${cnai_param} 		ELSE
	...    ute_wtssim.Execute Egate Command		${ics_rfsp} ${ics_cnai}off

Verify Pcap for multiple UE
	[Arguments]    ${start_ue_id}   ${end_ue_id}
    ${timers}   Create List     ${rfsptimer}    ${rfsprrctimer}     ${rfsprrctimer}     ${drbrrctimer}
	FOR     ${i}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
	Verify Pcap messages	${ue${i}_log}[cprt]/NODECPRT_GNB.pcap		${i}	${timers}${i}
	END

Verify Pcap messages
	[Arguments]         ${pcap_file}    ${idx}		${timer}    ${rfsp_id}
    BuiltIn.Log     ${rfsp_id}
	${packet}        set variable	e1ap || f1ap || ngap
    ${pdmlFile}=   Fetch filtered PDML file from pcap    ${pcap_file}         filterExp=${packet}       filterName=UE_${idx}
	${bearercontext_packet}      analyzer.get_shownames        pdmlFile=${pdmlFile}
    ...                                                packetName=e1ap.BearerContextSetupRequest_element
    ...                                                path=e1ap.Inactivity_Timer
    ...                                                endPacket=-${1}
    Should Contain Match          ${bearercontext_packet}         Inactivity-Timer: ${timer}s
	${path_count}      analyzer.count_path     pdmlFile=${pdmlFile}
    ...                                                packetName=e1ap.BearerContextInactivityNotification_element
    ...                                                path=e1ap.BearerContextInactivityNotification_element$
    Should Be Equal As Numbers     ${path_count}   1
	${bearerinact_packet}      analyzer.get_shownames     pdmlFile=${pdmlFile}
    ...                                                packetName=e1ap.BearerContextInactivityNotification_element
    ...                                                path=e1ap.uE_Activity
	...													endPacket=-${1}
    Should Contain Match          ${bearerinact_packet}		uE-Activity: not-active (1)

Update bsr package
    Run     mkdir ${CURDIR}/BSR
    ${dllink}   Set Variable     https://artifactory-espoo1.ext.net.nokia.com:443/artifactory/mnpute-rotta-local/BSR
    ${filename}    Set variable     BSR_AQQJ_4_H4_ALN30_ARP30_P00_6TO4_60_00421_00001.zip
    Run     sudo wget ${dllink}/${filename} --user=dheerajn --password=AP33ZXKC1P9cgS4SsiuoeE23c8C -P ${CURDIR}/BSR
    coam.setup admin
    ${ret}     coam.Update Software      ${CURDIR}/BSR/BSR_AQQJ_4_H4_ALN30_ARP30_P00_6TO4_60_00421_00001.zip
    coam.teardown admin

