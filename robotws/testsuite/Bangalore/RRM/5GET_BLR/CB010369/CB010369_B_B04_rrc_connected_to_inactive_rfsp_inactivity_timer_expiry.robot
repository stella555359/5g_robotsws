*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO
...             SBTS23R4    CONFIGURED

Documentation    CB010369-B-B101_B04-1_Successful transition of UE from RRC_Connected to RRC_Inactive state due to 
...			     expiration of RFSP based Inactivity timer
...
...             author:  padmashree.b@nokia.com          
...             maintainer:   padmashree.b@nokia.com     
...
...             INTRODUCTION:This test scenario describes the transition of UE from 
...             RRC_Connected to RRC_Inactive state due to expiration of Inactivity timer for a configured RFSP.    
...             TEST SET NAME:CB010369-B-B101_B04-1_Successful transition of UE from RRC_Connected to RRC_Inactive state due to 
...			     expiration of RFSP based Inactivity timer
...             CONTACTS:    RAN_L2_SW_BLR_1     
...             REFERENCES: CB010369 CFAM
...             Requirement ID: 5G_RAN_USR_RRM_23653 , CB_FIM_43435


Resource         ./resources/CB010369_resource.robot

Suite Setup         Run keywords    Run Keyword and Ignore Error      Suite setup from scratch
...                 AND     Perform SCF Delta Commissioning with Delta_json_B_B04_fdd_tdd_aeqe.json
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
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}          /opt/iphy/latest
${UE_ID}        1
${nwslice_ID}   1
${gw_ID}     1
@{Pdu_session_ID}       1   2   3
${QFI_ID}    1
${TRF_ID}    1

${TEST_NAME}        test_case
${start_ue_id}    ${1}
${end_ue_id}      ${3}

# GFBR and MFBR profile <qos flow id>_gfbr_<dir>=speed
&{gfbr_mfbr_profile}                6_gfbr_ul=10   6_gfbr_dl=20    6_mfbr_ul=40     6_mfbr_dl=50
...                                 7_gfbr_ul=10   7_gfbr_dl=20    7_mfbr_ul=40     7_mfbr_dl=50
...                                 3_gfbr_ul=10   3_gfbr_dl=20    3_mfbr_ul=40     3_mfbr_dl=50
#Make sure VONR Traffic profile should in kbps for 5QI1 and 5QI 5 i.e QFI 2 and 3
@{QOS_Prof1}               1     #5QI 6
@{QOS_Prof1_speed_dl}      1
@{QOS_Prof1_speed_ul}      1
@{QOS_Prof1_unit}          mbps

@{QOS_Prof2}               1       5            #5QI 9
@{QOS_Prof2_speed_dl}      1       1
@{QOS_Prof2_speed_ul}      1       1
@{QOS_Prof2_unit}          mbps     mbps

@{QOS_Prof3}               1        6            #5QI 4
@{QOS_Prof3_speed_dl}      1        30
@{QOS_Prof3_speed_ul}      1        30
@{QOS_Prof3_unit}          mbps     mbps

@{QOS_Prof4}               1      2       3                            #5QI 1
@{QOS_Prof4_speed_dl}      1      32      amr_wb_18_25
@{QOS_Prof4_speed_ul}      1      32      amr_wb_18_25
@{QOS_Prof4_unit}          mbps   kbps    rtp_codec

${delta}       30
@{indexToRSFP}		128		129		None
${rfsprrctimer}    130
${rfsptimer}    100
${drbrrctimer}     120

*** Test Cases ***
[1][1.0] CB010369-B-B101_B04-1_Successful transition of UE from RRC_Connected to RRC_Inactive state due to expiration of RFSP based Inactivity timer
    Comment     #### ue1 with rfsp 128 and cnai on ####
	Start Log      btslog     cprt
	Set ICS with index to RFSP		1		${indexToRSFP}[0]
	UE Register should be Successful	1     pdu_id=${Pdu_session_ID}[0]     nw_id=${nwslice_ID}      gw_id=${gw_ID}
	Trigger data	1     ul		pdu_id=${Pdu_session_ID}[0]     trf_id=1		qfi=1  Traffic_unit=mbps		traffic_rate=1
	Trigger data	1     dl		pdu_id=${Pdu_session_ID}[0]     trf_id=1		qfi=1  Traffic_unit=mbps		traffic_rate=1
	${trf_stop_cmd}     SET VARIABLE    trf_data_stop ue=1 pdu=${Pdu_session_ID}[0]
	${datastop_time}      Get Time
    ${output}       ute_wtssim.Execute Egate Command And Wait For Data   ${trf_stop_cmd}    pass_regexp=UE1\: Is INACTIVE   timeout=150
	${release_time}     Get Time
    ${ue1_log}     Stop Log      btslog     cprt    test_scenario=ue1
    Run Keyword and Continue on Failure		Verify Timer	${datastop_time}	${release_time}		${rfsprrctimer}

	Comment     #### ue2 with rfsp 129 and cnai off ####
	Start Log      btslog     cprt
	Set ICS with index to RFSP		2		${indexToRSFP}[1]
	UE Register should be Successful	2     pdu_id=${Pdu_session_ID}[1]     nw_id=${nwslice_ID}      gw_id=${gw_ID}
	Trigger data	2     dl		pdu_id=${Pdu_session_ID}[1]     trf_id=1		qfi=1  Traffic_unit=mbps		traffic_rate=1
	${trf_stop_cmd}     SET VARIABLE    trf_data_stop ue=2 pdu=${Pdu_session_ID}[1]
	${datastop_time}      Get Time
    ${output}       Run keyword and continue on failure     ute_wtssim.Execute Egate Command And Wait For Data   ${trf_stop_cmd}    
    ...     pass_regexp=UE2\: IS IDLE   timeout=150
	${release_time}     Get Time
    ${ue2_log}     Stop Log      btslog     cprt    test_scenario=ue2
    Run Keyword and Continue on Failure		Verify Timer	${datastop_time}	${release_time}		${rfsprrctimer}

	Comment     #### ue3 with rfsp None and cnai off ####
	Start Log      btslog     cprt
	Set ICS with index to RFSP		3		${indexToRSFP}[2]
	UE Register should be Successful	3     pdu_id=${Pdu_session_ID}[2]     nw_id=${nwslice_ID}      gw_id=${gw_ID}
	Trigger data	3     dl		pdu_id=${Pdu_session_ID}[2]     trf_id=1		qfi=1  Traffic_unit=mbps		traffic_rate=1
	${trf_stop_cmd}     SET VARIABLE    trf_data_stop ue=3 pdu=${Pdu_session_ID}[2]
	${datastop_time}      Get Time
    ${output}       Run keyword and continue on failure     ute_wtssim.Execute Egate Command And Wait For Data   ${trf_stop_cmd}    
    ...     pass_regexp=UE3\: IS IDLE   timeout=150
	${release_time}     Get Time
    ${ue3_log}     Stop Log      btslog     cprt    test_scenario=ue3
    OperatingSystem.Run    cp /opt/wts/latest/egate_console.log /home/ute/Logs/
    Run Keyword and Continue on Failure		Verify Timer	${datastop_time}	${release_time}		${drbrrctimer}
    ${timers}   Create List     ${rfsptimer}    ${rfsprrctimer}     ${rfsprrctimer}     ${drbrrctimer}
    ${id}   Create List     dummy       128     129     None
    FOR     ${i}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    Verify Pcap messages    ${ue${i}_log}[cprt]/NODECPRT_GNB.pcap       ${i}    ${timers}[${i}]     ${id}[${i}]
    END
    [Teardown]    Link SCOUT SCF to Configuration ID for Reporting
	
*** Keywords ***
Set ICS with index to RFSP
	[Arguments]		${ueid}		${indexRSFP}
	${ics_rfsp}    SET VARIABLE    amf_ue_ics_param id=1 ue=${ueid} indexToRFSP=${indexRSFP} 
	${ics_cnai}	   SET VARIABLE 	core_network_assistance_info=
	${cnai_param}	SET VARIABLE	on ue_identity_index_value=1 ue_specific_drx=64 periodic_registration_update_timer=5:1min plmn_id=311:489 tac_id=2
	Run keyword If	${ueid}==1	ute_wtssim.Execute Egate Command	${ics_rfsp} ${ics_cnai}${cnai_param} 		ELSE	
	...    ute_wtssim.Execute Egate Command		${ics_rfsp} ${ics_cnai}off	

Verify Timer
	[Arguments]		${time1}	${time2}	${timer}
	${datastop_time}    Split String    ${time1}
    ${release_time}     Split String    ${time2}
    ${time_diff}    DateTime.Subtract time from time     ${release_time}[${1}]        ${datastop_time}[${1}]
    ${result}         Evaluate    (${timer} + 1.0) >= ${time_diff} >= (${timer} - 1.0)
    Should Be True    ${result}

Verify Pcap for multiple UE
	[Arguments]    ${start_ue_id}   ${end_ue_id}
    ${timers}   Create List     ${rfsptimer}    ${rfsprrctimer}     ${rfsprrctimer}     ${drbrrctimer}
	FOR     ${i}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
	Verify Pcap messages	${ue${i}_log}[cprt]/NODECPRT_GNB.pcap		${i}	${timers}${i}
	END
	
Verify Pcap messages
	[Arguments]         ${pcap_file}    ${idx}		${timer}    ${rfsp_id}
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
    ${inicontext_packet}      Run Keyword If  '${idx}' != '3'		analyzer.get_shownames     pdmlFile=${pdmlFile}
    ...                                                packetName=ngap.InitialContextSetupRequest_element
    ...                                                path=ngap.IndexToRFSP
    ...                                                 endPacket=-${1}
    Run Keyword If  '${idx}' != '3'    Should Contain Match          ${inicontext_packet}     IndexToRFSP: ${rfsp_id}
