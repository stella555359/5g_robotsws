*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env Aic
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters Aic
Test Setup    Common Test Setup And Start To Capture Logs Aic
Test Teardown    Common Test Teardown And Stop Capture Logs Aic
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_Aic    master_vDU    CRT    owner-jianfen.shen
...    CLOUD_5GC_dRNIC_1vDU_P_AP_LO_DC    SANSA_FS_ECPRI_CMWV_TDD_CPRI_CMWV_FDD    release-5G23R3    team-DevHZ5_SG02    vDUCNF00

Resource    ../../../../resources_aic/DevHZ5_resource_aic.robot

*** Variables ***
${TL_TYPE_PATH}    tddfdd_sansa_cmwv/FS/1du/4cells_2T2F
${SA_UE_ID}    1
@{PARAMS_IN_SCF_CU}    @{5GC000784_CU}    @{5GC000786_CU}    @{5qi_CU}
@{PARAMS_IN_SCF_DU1}    @{5GC000784_DU}    @{5GC000786_DU}    @{5qi_DU}

@{5GC000784_DU}
...    NRCELL:actEmergencyCall=true
...    NRCELL:arpPrioEmergencyCall=1
...    NRBTS-1/NRDU-1:numOfDrbsReservForEmergency=0
...    NRCELL:numOfRadioResReservForEmergency=0

@{5GC000784_CU}
...    NRCELL:actEmergencyCall=true
...    NRCELL:arpPrioEmergencyCall=1
...    NRBTS-1/NRDU-1:numOfDrbsReservForEmergency=0
...    NRCELL:numOfRadioResReservForEmergency=0
...    NRBTS-1:actNormVCFallback=false
...    NRCELL:emergencyCallRestrictions:emergencyCallMrListIgnore=true
...    NRCELL:emergencyCallRestrictions:emergencyCallPlmnHoAllowed=true

@{5GC000786_DU}
...    NRCELL:actVoNR=true
...    NRCELL:actEnhancedVoNR=true
...    NRCELL:actGBRAdmissionControl=EnhancedVoNR


@{5GC000786_CU}
...    NRCELL:actVoNR=true
...    NRCELL:actEnhancedVoNR=true
...    NRCELL:actGBRAdmissionControl=EnhancedVoNR


@{5qi_CU}
...    NRBTS-1/NRDRB_5QI-1:fiveqiValueList=5
...    NRBTS-1/NRDRB_5QI-1:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-10
...    NRBTS-1/NRDRB-10:resType=nonGBR
...    NRBTS-1/NRDRB-10:rlcMode=RLC_AM

...    NRBTS-1/NRDRB_5QI-4:fiveqiValueList=1
...    NRBTS-1/NRDRB_5QI-4:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-15
...    NRBTS-1/NRDRB-15:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-1
...    NRBTS-1/NRDRB-15:dlFlowControlAlgo=none
...    NRBTS-1/NRDRB-15:resType=GBR
...    NRBTS-1/NRDRB-15:rlcMode=RLC_UM
...    NRBTS-1/NRDRB-15:discardTimer=100ms
...    NRBTS-1/NRDRB-15:maxTransferDelayGbr=20
...    NRBTS-1/NRDRB-15:queuingDelayDiscarding=Disabled
...    NRBTS-1/NRDRB-15:cellAggrLevel=Not FR1 CA eligible
...    NRBTS-1/NRDRB_PDCP-1:pdcpBufDiscardEnabled=false

@{5qi_DU}
...    NRBTS-1/NRDRB_5QI-1:fiveqiValueList=5
...    NRBTS-1/NRDRB_5QI-1:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-10
...    NRBTS-1/NRDRB-10:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-4
...    NRBTS-1/NRDRB-10:nrDrbRlcAmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_AM-2
...    NRBTS-1/NRDRB-10:resType=nonGBR
...    NRBTS-1/NRDRB-10:rlcMode=RLC_AM
...    NRBTS-1/NRDRB_MAC-4:lcgid=1
...    NRBTS-1/NRDRB_MAC-4:schedulPrio=4

...    NRBTS-1/NRDRB_5QI-4:fiveqiValueList=1
...    NRBTS-1/NRDRB_5QI-4:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-15
...    NRBTS-1/NRDRB-15:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-3
...    NRBTS-1/NRDRB-15:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRBTS-1/NRDRB-15:dlFlowControlAlgo=none
...    NRBTS-1/NRDRB-15:resType=GBR
...    NRBTS-1/NRDRB-15:rlcMode=RLC_UM
...    NRBTS-1/NRDRB-15:discardTimer=100ms
...    NRBTS-1/NRDRB-15:maxDataRateGbrDl=1000
...    NRBTS-1/NRDRB-15:maxDataRateGbrUl=1000
...    NRBTS-1/NRDRB-15:maxRlcQueueingDelayGbr=20
...    NRBTS-1/NRDRB-15:cellAggrLevel=Not FR1 CA eligible
...    delete:NRBTS-1/NRDRB-15:nrDrbRlcAmDN
...    NRBTS-1/NRDRB_MAC-3:lcgid=4
...    NRBTS-1/NRDRB_MAC-3:schedulPrio=5
...    NRBTS-1/NRDRB_MAC-3:schedulBSD=100ms

...    NRDRB_RLC_UM-1:dlTReassemblyUm=ms40
...    NRDRB_RLC_UM-1:rlcUMDrbSNLength=rlcUm12bitSN
...    NRDRB_RLC_UM-1:ulTReassemblyUm=ms40

##PM Counters for Call Release Due to NG Reset By GNB
${NG_FLOW_REL_GNB_NG_RESET}    M55125C09001    #Number of QosFlows released due to NG interface Reset initiated by gNB
${NG_FLOW_REL_GNB_NG_RESET_5QI1}    M55125C09501     #Number of 5QI-1 QoS Flows released due to Ng interface Reset
${NG_FLOW_REL_ABNORMAL_5QI1}    M55125C09515    #Number of 5QI-1 QoS Flows released due to abnormal causes
${NG_FLOW_CONNECTED_SESSION_TIME}    M55125C09516    #In-session connected time for QoS Flows
${NG_FLOW_SESSION_DUR_ABNRM_5QI1}    M55125C09527    #In-session connected time for 5QI1 QoS Flows released due to abnormal cause.
${NG_FLOW_REL_AMF_OTHER_5QI1}    M55125C09513    #Number of 5QI-1 QoS Flows releases initiated by AMF for causes that are Other
${NG_FLOW_REL_AMF_NORMAL}    M55125C09019    #Number of QosFlows releases initiated by AMF for causes that are normal
${NG_FLOW_REL_AMF_NORMAL_5QI1}    M55125C09512    #Number of 5QI-1 QoS Flows releases initiated by AMF for causes that are normal

@{PM_Counters_Voice_EC_Call_Release_Due_to_NG_Reset_By_GNB}
...    NRCELL-1:${NG_FLOW_REL_GNB_NG_RESET}=4    #M55125C09001
...    NRCELL-1:${NG_FLOW_REL_GNB_NG_RESET_5QI1}=2    #M55125C09501
...    NRCELL-1:${NG_FLOW_CONNECTED_SESSION_TIME}>1
...    NRCELL-1:${NG_FLOW_SESSION_DUR_ABNRM_5QI1}>0
...    NRCELL-1:${NG_FLOW_REL_ABNORMAL_5QI1}=2    #M55125C09515
...    NRCELL-1:${NG_FLOW_REL_AMF_OTHER_5QI1}=0    #M55125C09513
...    NRCELL-1:${NG_FLOW_REL_AMF_NORMAL}=0    #M55125C09019
...    NRCELL-1:${NG_FLOW_REL_AMF_NORMAL_5QI1}=0    #M55125C09512

##784 EC counters on CU
#Number of INITIAL CONTEXT SETUP REQUEST received for IMS Emergency Calls
${NNGCC_UE_CTXT_STP_REQ_EC_RECD}    M55125C05501
#Number of INITIAL CONTEXT SETUP RESPONSE sent for IMS Emergency Calls
${NNGCC_UE_CTXT_STP_RESP_EC_SENT}    M55125C05502
#Number of INITIAL CONTEXT SETUP FAILURE sent for IMS Emergency Calls
${NNGCC_UE_CTXT_STP_FAIL_EC_SENT}    M55125C05503
#Number of INITIAL CONTEXT SETUP FAILURE sent due to RAC Failure in the gNB for IMS Emergency Calls
${NNGCC_UE_CTXT_STP_FAIL_EC_RAC}    M55125C05504
#Number of PDU SESSION RESOURCE SETUP REQUEST received for IMS Emergency Calls
${NNGCC_PDU_SES_STP_REQ_EC_RECD}    M55125C05505
#Number of PDU SESSION RESOURCE SETUP RESPONSE sent for IMS Emergency Calls
${NNGCC_PDU_SES_STP_RESP_EC_SENT}    M55125C05506
#Number of PDU SESSION RESOURCES SETUP RESPONSE failures for IMS Emergency Calls
${NNGCC_PDU_SES_STP_NACK_EC_SENT}    M55125C05507
#Number of PDU SESSION RESOURCE SETUP RESPONSE failures due to RAC Failure for IMS Emergency Calls
${NNGCC_PDU_SES_STP_NACK_EC_RAC}    M55125C05508
#Number of PDU SESSION RESOURCE MODIFICATION REQUEST received for IMS Emergency Calls
${NNGCC_PDUSESMODREQ_EC_RECD}    M55125C05509
#Number of PDU SESSION RESOURCE MODIFICATION RESPONSE Success sent for IMS Emergency Calls
${NNGCC_PDUSESMODRSP_SUC_EC_SENT}    M55125C05510
#Number of PDU SESSION RESOURCE MODIFICATION Failures for IMS Emergency Calls
${NNGCC_PDUSESMOD_FAIL_EC_SENT}    M55125C05511
#Number of PDU SESSION RESOURCE MODIFICATION Failures due to RAC Failure for IMS Emergency Calls
${NNGCC_PDUSESMOD_FAIL_EC_RAC}    M55125C05512
#Number of RRC Connection Establishment Completions for IMS Emergency Calls
${NRRCC_RRC_STPSUCC_EMERGENCY}    M55124C04001
#Number of IMS Emergency Call attempts redirected to LTE
${NR_RRC_RELEASE_REDIR_EC_LTE}    M55124C04002
#Number of PDU SESSION RESOURCES RELEASE COMMAND for Emeregency Call
${NNGCC_PDU_SES_REL_CMD_EC_RECD}    M55125C05513
#Number of PDU SESSION RESOURCES RELEASE RESPONSE for Emeregency Call
${NNGCC_PDU_SES_REL_RESP_EC_SENT}    M55125C05514

@{PM_Counters_Emergency_Call}
...    NRCELL-1:NNGCC:${NNGCC_UE_CTXT_STP_REQ_EC_RECD}=0    #M55125C05501
...    NRCELL-1:NNGCC:${NNGCC_UE_CTXT_STP_RESP_EC_SENT}=0    #M55125C05502
...    NRCELL-1:NNGCC:${NNGCC_UE_CTXT_STP_FAIL_EC_SENT}=0    #M55125C05503
...    NRCELL-1:NNGCC:${NNGCC_UE_CTXT_STP_FAIL_EC_RAC}=0    #M55125C05504
...    NRCELL-1:NNGCC:${NNGCC_PDU_SES_STP_REQ_EC_RECD}=2    #M55125C05505
...    NRCELL-1:NNGCC:${NNGCC_PDU_SES_STP_RESP_EC_SENT}=2    #M55125C05506
...    NRCELL-1:NNGCC:${NNGCC_PDU_SES_STP_NACK_EC_SENT}=0     #M55125C05507
...    NRCELL-1:NNGCC:${NNGCC_PDU_SES_STP_NACK_EC_RAC}=0    #M55125C05508
...    NRCELL-1:NNGCC:${NNGCC_PDUSESMODREQ_EC_RECD}=0    #M55125C05509
...    NRCELL-1:NNGCC:${NNGCC_PDUSESMODRSP_SUC_EC_SENT}=0    #M55125C05510
...    NRCELL-1:NNGCC:${NNGCC_PDUSESMOD_FAIL_EC_SENT}=0    #M55125C05511
...    NRCELL-1:NNGCC:${NNGCC_PDUSESMOD_FAIL_EC_RAC}=0    #M55125C05512
...    NRCELL-1:NRRCC:${NRRCC_RRC_STPSUCC_EMERGENCY}=0    #M55124C04001
...    NRCELL-1:NRRCC:${NR_RRC_RELEASE_REDIR_EC_LTE}=0    #M55124C04002
...    NRCELL-1:NNGCC:${NNGCC_PDU_SES_REL_CMD_EC_RECD}=0    #M55125C05513
...    NRCELL-1:NNGCC:${NNGCC_PDU_SES_REL_RESP_EC_SENT}=0    #M55125C05514

${SGNB_SA_NGBR_DRB_REQ}    M55138C00003     #The number of non-GBR DRB radio admission requests for SA user
${SGNB_SA_NGBR_DRB_SUCC}    M55138C00005     #The number of non-GBR DRB successful radio admissions for SA user
${F1_UE_CTXT_MOD_REQ_RECEIVED}    M55117C00001     #Number of incoming UE CONTEXT MODIFICATION REQUEST received from gNB-CU
${SGNB_SA_NGBR_DRB_REL}    M55138C00004     #The number of non-GBR DRB radio admission releases for SA user

@{PM_Counters_Check_CU}
...    @{PM_Counters_Voice_EC_Call_Release_Due_to_NG_Reset_By_GNB}
...    @{PM_Counters_Emergency_Call}
...    NRCELL-1:RSACU:${SGNB_SA_NGBR_DRB_REQ}==4    #M55138C00003==4
...    NRCELL-2:RSACU:${SGNB_SA_NGBR_DRB_REQ}==0
...    NRCELL-1:RSACU:${SGNB_SA_NGBR_DRB_SUCC}==4    #M55138C00005==4
...    NRCELL-2:RSACU:${SGNB_SA_NGBR_DRB_SUCC}==0
...    NRCELL-1:RSACU:${SGNB_SA_NGBR_DRB_REL}==2    #M55138C00004==2
...    NRCELL-2:RSACU:${SGNB_SA_NGBR_DRB_REL}==0

@{PM_Counters_Check_DU}
...    NRBTS-1:NF1CD:${F1_UE_CTXT_MOD_REQ_RECEIVED}==12    #M55117C00001==12

*** Test Cases ***
CB009881-ET_5GC000784_786_Verify_Cloud_gNB_SA_TDD_cmWave_EC_call_and_VONR_call_setup_successful_after_Nglink_reset
    [Documentation]
    ...    1. The purpose of this test case is:
    ...         This case will cover 5GC000784(Emergency_call) and 5GC000786(VONR_call) features.
    ...         Verify emergency call is able to setup before EC5QI1 is setup after Ng link reset
    ...    2. Test Case Steps:
    ...         a. UE1 setup VONR call with 5QI5
    ...         b. PDU modify to add 5QI1
    ...         c. UE1 setup emergenct call with 5QI5 , with emergency ARP
    ...         d. PDU modify to add 5QI1 , with emergency ARP
    ...         e. trigger NG reset by lock AMF on gnb side
    ...         f. UE1 setup VONR call and then emergenct call again
    ...    3. Expected Results:
    ...         Step a and b: VONR call with PDU setup successfully
    ...         Step c and d: EC call with PDU setup successfully
    ...         setp e: NG reset successfully, VONR and EC call released
    ...         setp f: both VONR call with PDU and EC call with PDU setup successfully
    ...         check counters on CU and DU
    [Tags]    QC_278598
    Clear Counter Files
    Trigger UE MO VoNR Call And Then EC Call
    VoNR Call QosFlow Release Due to NG Reset By GNB
    Trigger UE MO VoNR Call And Then EC Call
    Release Ues    ue_type=sa
    Check Counters
    Check WireShark Log Aic    ${CURDIR}${/}a2a_5GC000784${/}a2a.ini    wait_string=UEContextReleaseComplete::1

*** Keywords ***
Modify Cfg Aic
    Update Cfg Aic    ue_param id=${SA_UE_ID} ue_nr_capabilities=${SA_Capa_perUE_Full}
    Update Cfg Aic    amf_param id=1 full_nas_auth=on nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g voice_fallback=off ims_voice_3gpp=on
    Update Cfg Aic    ue_param id=1 ue_nr_capabilities=${SA_Capa_perUE_Full}
    Update Cfg Aic    ue_param id=2 ue_nr_capabilities=${SA_Capa_perUE_Full}
    Update Cfg Aic    ue_param id=3 ue_nr_capabilities=${SA_Capa_perUE_Full}
    Update Cfg Aic    set_qosflow id=1 5qi=5 default=on
    Update Cfg Aic    set_qosflow id=2 5qi=1
    Update Cfg Aic    set_qosflow id=3 5qi=2
    Update Cfg Aic    set_qosflow id=4 5qi=9
    Update Cfg Aic    set_qosrule id=1 proto=tcp qos_flow=1
    Update Cfg Aic    set_qosrule id=2 proto=udp qos_flow=2
    Update Cfg Aic    set_qosrule id=3 proto=udp qos_flow=3
    Update Cfg Aic    set_nwslice id=1 snssai=0x01:0xD143A5 default=on ue=1-3 amf=1 qos_flows=3,2,1 qos_rules=1,2
    Update Cfg Aic    set_nwslice id=2 snssai=0x01:0xD143A6 ue=1 amf=1
    Update Cfg Aic    set_nwslice id=3 snssai=0x01:0xD143A7 ue=1 amf=1
    Update Cfg Aic    set_nwslice id=4 snssai=0x01:0xD143A8 ue=1 amf=1
    Update Cfg Aic    set_pdu_gateway id=1 ue_nat_ip=72.23.0.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg Aic    set_pdu_gateway id=2 ue_nat_ip=72.23.1.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg Aic    set_pdu_gateway id=3 ue_nat_ip=72.23.2.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg Aic    set_pdu_gateway id=4 ue_nat_ip=72.23.3.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg Aic    set_pdu_gateway id=5 ue_nat_ip=72.23.4.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg Aic    set_pdu_gateway id=6 ue_nat_ip=72.23.5.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg Aic    ue_nr_capabilities id=1 voice_over_nr=on:on:off
    Update Cfg Aic    ue_nr_capabilities id=2 voice_over_nr=on:on:off
    Update Cfg Aic    ue_nr_capabilities id=3 voice_over_nr=on:on:off

Clear Counter Files
    Clear Counter Files Cu Aic    wait=False
    Clear Counter Files Du Aic    wait=False

Check Counters
    Check Counters Cu Aic    ${PM_Counters_Check_CU}
    Check Counters Du Aic    pm_counters_expression=${PM_Counters_Check_DU}    wait=False

Send Throughput
    [Arguments]    ${ue_id}=${SA_UE_ID}
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=1 protocol=udp mbps=5    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=ul trf_id=2 protocol=udp mbps=5    UE ${ue_id}: UDP UL

Verify Throughput
    [Arguments]    ${ue_id}=${SA_UE_ID}    ${sleep_time}=10s
    sleep    ${sleep_time}    sleep for Throughput stable
    ${dl_throuput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=ave
    Should Be True    ${dl_throuput}/1000>4.6
    ${ul_throuput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${ul_throuput}/1000>4.6
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pdsch    Throughput
    Should Not Match Regexp    ${scell_tput}    CellIndex-.*Mbps.*Mbps.*Mbps.* 0 Mbps

SA UE Register And PDU Setup
    [Arguments]    ${ue_id}=${SA_UE_ID}    ${pdu}=1    ${nwslice}=1    ${cmd_regexp}=NG RM Registered
    Execute Egate Command    ue_register id=${ue_id}    ${cmd_regexp}
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu} nwslice=${nwslice} gw=1    QoS Routing Table

Trigger UE MO VoNR Call And Then EC Call
    [Documentation]    Trigger UE MO VoNR Call and 5QI1 add successfully with PDU session modify, and then EC call
    [Arguments]    ${ue_id}=${SA_UE_ID}
    Set Qosflow Priority And SMF Reset    priority=15
    Trigger UE MO VoNR call with PDU    ue_id=${ue_id}    pdu_id=1    gw=1    fiveQI=5    nwslice=1    request_type=initial-request
    Trigger UE 5QI Add Successfully With PDU Session Modify    ue_id=${ue_id}    pdu_id=1    qosflows_to_add=2    fiveQI=1
    Set Qosflow Priority And Additional Qosflows To Activate    priority=1    additional_qosflows_to_activate=2
    Trigger UE 5QI5 And 5QI1 Setup Successfully With Same PDU NGAP Procedure    ue_id=${ue_id}    pdu_id=2    nwslice=1    gw=2
    ...    request_type=initial-emergency-request

Set Qosflow Priority And SMF Reset
    [Arguments]    ${priority}=1
    Execute Egate Command    qosflow_modify qos_flow=1 priority=${priority}
    Execute Egate Command    qosflow_modify qos_flow=2 priority=${priority}
    Execute Egate Command    qosflow_modify qos_flow=3 priority=${priority}
    Execute Egate Command    qosflow_modify qos_flow=4 priority=${priority}
    Execute Egate Command    smf_param id=1 reset

Trigger UE MO VoNR call with PDU
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${fiveQI}=5    ${nwslice}=1    ${gw}=1    ${request_type}=initial-request
    Execute Egate Command    ue_location_change id=${ue_id} enb=2 cell=1
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=UE now in NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    ${ret1}=    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=${gw} nwslice=${nwslice} request_type=${request_type}
    ...    pass_regexp=QoS Routing Table
    Should Contain    ${ret1}    securityModeCommand
    Should Contain    ${ret1}    Initial Context Setup Successful for UE with AMF UE
    Should Contain    ${ret1}    Setup QosFlow with QFI:1 5QI:${fiveQI}

Trigger UE 5QI Add Successfully With PDU Session Modify
    [Arguments]    ${ue_id}=2    ${pdu_id}=1    ${qosflows_to_add}=2    ${fiveQI}=1
    ${ret2}=    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_add=${qosflows_to_add} by=amf
    ...    Pdu Session Resource Modify Response Message with RAN UE NGAP ID [0-9]* handled successfully
    Should Contain    ${ret2}    rrcReconfiguration
    Should Contain    ${ret2}    Added QosFlow with QFI:${qosflows_to_add} 5QI:${fiveQI}

Set Qosflow Priority And Additional Qosflows To Activate
    [Arguments]    ${priority}=1    ${additional_qosflows_to_activate}=2
    Execute Egate Command    qosflow_modify qos_flow=1 priority=${priority}
    Execute Egate Command    qosflow_modify qos_flow=2 priority=${priority}
    Execute Egate Command    qosflow_modify qos_flow=3 priority=${priority}
    Execute Egate Command    qosflow_modify qos_flow=4 priority=${priority}
    Execute Egate Command    smf_param id=1 additional_qosflows_to_activate=${additional_qosflows_to_activate}

Trigger UE 5QI5 And 5QI1 Setup Successfully With Same PDU NGAP Procedure
    [Arguments]    ${ue_id}=1    ${pdu_id}=2    ${nwslice}=1    ${gw}=2    ${request_type}=initial-emergency-request
    ${ret3}=    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} nwslice=${nwslice} gw=${gw} request_type=${request_type}
    ...    Pdu Session Resource Setup Response Message with RAN UE NGAP ID [0-9]* handled successfully
    Should Contain    ${ret3}    rrcReconfiguration
    Should Contain    ${ret3}    Setup QosFlow with QFI:1 5QI:5
    Should Contain    ${ret3}    Setup QosFlow with QFI:2 5QI:1
    Should Contain    ${ret3}    handled successfully


VoNR Call QosFlow Release Due to NG Reset By GNB
    Unlock_Lock_NG_Links    status=Locked
    Unlock_Lock_NG_Links    status=Unlocked
    Wait Until Keyword Succeeds    10min    10s    Object Should Exist In Cu    MRBTS-1/NRBTS-1/SERVEDAMF-1:ngLinkStatus=Active

Unlock_Lock_NG_Links
    [Arguments]    ${status}=Locked
    ${delta_parameters}    Create List    NRBTS-1/SERVEDAMF-1:administrativeState=${status}
    Delta Commission Parameters Cu    ${delta_parameters}
    Wait Until Keyword Succeeds    3min    10s    Object Should Exist In Cu    MRBTS-1/NRBTS-1/SERVEDAMF-1:administrativeState=${status}
