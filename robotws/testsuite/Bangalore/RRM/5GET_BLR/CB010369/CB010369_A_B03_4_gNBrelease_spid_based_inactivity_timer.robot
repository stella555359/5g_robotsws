*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO
...             SBTS23R4    CONFIGURED

Documentation    USCB010369-A#B03_4_Successful SgNB Release due to expiration of SPID based Inactivity timer single bearer
...				 CB010369_A_B02_3_Successful SPID based Inactivity timer configuration during Bearer Context Modication with 
...				 nsaactivitynotificationlevel=drb
...
...             author: padmashree.b@nokia.com            
...             maintainer:  padmashree.b@nokia.com       
...
...             INTRODUCTION:This scenario describes the Successful SgNB Release due to 
...                           expiration of SPID based Inactivity timer single bearer    
...             TEST SET NAME:USCB010369-A#B03_4_Successful SgNB Release due to expiration of SPID based Inactivity timer single bearer 
...                       and    CB010369_A_B02_3_Successful SPID based Inactivity timer configuration during Bearer Context Modication with 
...				 nsaactivitynotificationlevel=drb  
...             TESTING SPLIT:USCB010369-A#B03 and CB010369_A_B02_3
...             CONTACTS:    RAN_L2_SW_BLR_1     
...             REFERENCES: CB010769 CFAM
...             Requirement ID: 5G_RAN_USR_RRM_23643 and 5G_RAN_USR_RRM_23655
  

Resource         ./resources/CB010369_resource.robot

Suite Setup         Run keywords    Run Keyword and Ignore Error      Suite setup from scratch
...                 AND     Perform SCF Delta Commissioning with Delta_json_A_B03_fdd_tdd_aeqe.json
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
${wts_cfg_file}     ${CURDIR}/config/wts/basic_setup_fdd_tdd_aeqe1.cfg
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}          /opt/iphy/latest
${UE_ID}        1
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${QFI_ID}    1
${TRF_ID}    1

${TEST_NAME}        test_case
${start_ue_id}    ${121}
${end_ue_id}      ${121}
${drb_ue_id}       ${101}
${spid}         ${1}
${Target_Cells}     ${2}
${Target_gNB}   ${2}
${Bearer_ID}    ${2}

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
${spidinactivity_timer}      100
${spidinactivity_timer1}      300
${nsainactivity_timer}       200

*** Test Cases ***
[1][1.0] USCB010369-A#B03_4_Successful SgNB Release due to expiration of SPID based Inactivity timer single bearer


    Start Log      btslog     cprt
	
	NSA LTE Attach should be Successful		${start_ue_id}
	${enb_param_cmd}    SET VARIABLE    ue_enb_param id=${start_ue_id} spid=${spid} 
    ute_wtssim.Execute Egate Command    ${enb_param_cmd}    timeout=${EGATE_COMMAND_TIMEOUT}
    NSA X2AP Link Should be UP      eNB_ID=1   eNB_target=2
	NSA UE Attach should be Successful	${start_ue_id}	${Target_Cells}
	
	Trigger DL Traffic for NSA      ${start_ue_id}        Traffic_rate=mbps     dl_rate=1       id=${Bearer_ID}    trf_id=${TRF_ID}
    Trigger UL Traffic for NSA      ${start_ue_id}        Traffic_rate=mbps     ul_rate=1       id=${Bearer_ID}    trf_id=${TRF_ID}	
	
    
    ${trf_stop_cmd}     SET VARIABLE    trf_data_stop ue=${start_ue_id}
	${datastop_time}      Get Time
    ${output}       ute_wtssim.Execute Egate Command And Wait For Data   ${trf_stop_cmd}    
    ...     pass_regexp=Bearer-type change from SCG-split to MCG is successful   timeout=120
	${release_time}     Get Time
    ${scen1}     Stop Log      btslog     cprt


    Should Contain  ${output}   SgNBReleaseRequired
    Should Contain  ${output}   radioNetwork : user-inactivity
    Should Contain  ${output}   SgNBReleaseConfirm
	Verify Timer	${datastop_time}	${release_time}		${spidinactivity_timer}
	Verify Pcap msgs ue		${scen1}[cprt]/NODECPRT_GNB.pcap		${spid}		${start_ue_id}

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
    [Teardown]    Link SCOUT SCF to Configuration ID for Reporting

	
	
*** Keywords ***
Verify Timer
	[Arguments]		${time1}	${time2}	${timer}
	${datastop_time}    Split String    ${time1}
    ${release_time}     Split String    ${time2}
    ${time_diff}    DateTime.Subtract time from time     ${release_time}[${1}]        ${datastop_time}[${1}]
    ${result}         Evaluate    (${timer} + 1.0) >= ${time_diff} >= (${timer} - 1.0)
    Should Be True    ${result}
	
Verify Pcap msgs ue
	[Arguments]         ${pcap_file}    ${spid}		${idx}
	${packet}        set variable	e1ap || x2ap
    ${pdmlFile}=   Fetch filtered PDML file from pcap    ${pcap_file}         filterExp=${packet}       filterName=UE_${idx}
	${spid_packet}      analyzer.get_shownames        pdmlFile=${pdmlFile}
    ...                                                packetName=x2ap.SgNBAdditionRequest_element
    ...                                                path=x2ap.SubscriberProfileIDforRFP
    ...                                                endPacket=-${1}
    Should Contain Match           ${spid_packet}         SubscriberProfileIDforRFP: ${spid}
	${path_count}      analyzer.count_path     pdmlFile=${pdmlFile}
    ...                                                packetName=x2ap.SgNBAdditionRequest_element
    ...                                                path=x2ap.SgNBAdditionRequest_element$
    Should Be Equal As Numbers     ${path_count}   1
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
