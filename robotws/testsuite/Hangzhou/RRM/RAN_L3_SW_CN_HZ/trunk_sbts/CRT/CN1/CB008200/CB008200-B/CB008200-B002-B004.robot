*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    RAN_5G_FDD    SBTS00    team-Rock_SGT&A    owner-sherrzha.zhang
...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    CRT    STATE_CONFIGURED    RAN_5G

Resource    ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
${TL_TYPE_PATH}  tdd_sansa_cmwv/FS/2cells_ecpri
${5qi1_UE_Capabilities}  SEPARATOR=
...    E1A01000074E5A031E000380A03C1260C8000878180C4034026010180E01951B0A3582028680965944C043D6C10101070EF1C39061
...    C00103278FAB80027800E0009E00151B133582028680965944C043D6C10101070EF1C39061C00103278FAB80027800E0009E00151B
...    137582028680965944C043D6C10101070EF1C39061C00103278FAB80027800E0009E00151B13B582028680965944C043D6C1010107
...    0EF1C39061C00103278FAA8000028000000841C4D00000000202682807008089FEAAAAA058060005038180703005807000683E0000
...    000000000E54D000100000965950034AAA8081C002C00000010020046AC4C0004080C1014181C202C4044484C648494989CA12986B
...    40
@{PARAMS_IN_SCF}
...    @{AS_ALGORITHM}
...    @{Gnb_VoNR}
...    @{Gnb_EmergencyCall}
...    @{GNB_PMQAP}
@{AS_ALGORITHM}
...    NRBTS-1:integrityProtPrefL:nia0=0
...    NRBTS-1:integrityProtPrefL:nia1_128=0
...    NRBTS-1:integrityProtPrefL:nia2_128=0
...    NRBTS-1:integrityProtPrefL:nia3_128=9
...    NRBTS-1:cipherPrefL:nea0=0
...    NRBTS-1:cipherPrefL:nea1_128=0
...    NRBTS-1:cipherPrefL:nea2_128=0
...    NRBTS-1:cipherPrefL:nea3_128=9
@{Gnb_VoNR}

...    NRCELL:actVoNR=true
...    NRCELL:actCDrx=true
...    NRCELL:actCDrxVoNR=true
...    NRCELL:n310VoNR=n10
...    NRCELL:t310VoNR=100ms
...    NRCELL:actEnhancedVoNR=true
...    NRCELL:drxProfile1:drxInactivityTimer=40ms
...    NRCELL:drxProfile1:drxLongCycle=40ms
...    NRCELL:drxProfile1:drxOnDurationTimer=10ms
...    NRCELL:drxProfile1:drxRetransTimerDl=16slot
...    NRCELL:drxProfile1:drxRetransTimerUl=16slot
...    NRCELL:drxProfile2:drxInactivityTimer=40ms
...    NRCELL:drxProfile2:drxLongCycle=40ms
...    NRCELL:drxProfile2:drxOnDurationTimer=4ms
...    NRCELL:drxProfile2:drxRetransTimerDl=0slot
...    NRCELL:drxProfile2:drxRetransTimerUl=0slot
...    NRDRB_MAC-4:lcgid=0
...    NRDRB_MAC-4:prioritisedBitRate=16kBps
...    NRDRB_MAC-4:schedulPrio=4
...    NRDRB_MAC-3:lcgid=4
...    NRDRB_MAC-3:prioritisedBitRate=16kBps
...    NRDRB_MAC-3:schedulPrio=5
...    NRDRB_PDCP-2:pdcpBufDiscardEnabled=false
...    NRDRB_RLC_UM-1:dlTReassemblyUm=ms40
...    NRDRB_RLC_UM-1:rlcUMDrbSNLength=rlcUm12bitSN
...    NRDRB_RLC_UM-1:ulTReassemblyUm=ms40
...    NRDRB-10:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-4
...    NRDRB-10:resType=nonGBR_Signaling
...    NRDRB-15:discardTimer=infinity
...    NRDRB-15:dlFlowControlAlgo=none
...    NRDRB-15:dscp=0
...    NRDRB-15:durationThresDiscardDl=40
...    NRDRB-15:durationThresDiscardUl=20
...    NRDRB-15:actDddsReduction=false
...    NRDRB-15:actLostPduFastRetx=false
...    NRDRB-15:maxDddsPeriodCpuOvld=40
...    NRDRB-15:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-3
...    NRDRB-15:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-2
...    NRDRB-15:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRDRB-15:numSduDiscard=1
...    NRDRB-15:queuingDelayDiscarding=Disabled
...    NRDRB-15:queuingDelaySduDiscardThreshold=200
...    NRDRB-15:resType=GBR
...    NRDRB-15:rlcMode=RLC_UM
...    NRDRB-15:schedulWeight=1
...    NRDRB-15:sduDiscardIntervalTmr=100
...    NRDRB-15:volThresDiscardDl=8000
...    NRDRB-15:volThresDiscardUl=800
...    NRDRB_5QI-6:fiveqiValueList=1
...    NRDRB_5QI-6:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-15
...    NRDRB_MAC-3:schedulBSD=50ms
...    NRDRB-15:maxDataRateGbrDl=1000
...    NRDRB-15:maxDataRateGbrUl=1000
@{Gnb_EmergencyCall}
...    NRBTS:tRLFindForDUVoNR=500ms
...    NRBTS:drbInactivityTimerSA=7200
...    NRBTS:rrcReestabTypeSA=viaRRCSetup
...    NRSYSINFO_PROFILE-1/NRIRFIM-1:threshXHighQ=0
...    NRSYSINFO_PROFILE-1/NRIRFIM-1:threshXLowQ=0
...    NRCELL:emergencyFBMode=disabled
...    NRCELL:actEmergencyCall=false
...    NRCELL:actGBRAdmissionControl=EnhancedVoNR
...    NRCELL:emergencyCallLimServ=true
...    NRCELL:maxGBRTrafficLimit=30
...    NRCELL:arpPrioEmergencyCall=1
...    NRCELL:emergencyCallFails=true
...    NRCELL:maxNumOfNonGBRBearersSA=500
...    NRCELL:maxNumOfRrcSA=10
...    NRCELL:numOfRadioResReservForEmergency=1
...    NRCELL:sMeasConfigSsbRsrp=0
...    NRCELL:emergencyCallRestrictions:emergencyCallMrListIgnore=true
...    NRCELL:emergencyCallRestrictions:emergencyCallPlmnHoAllowed=true
...    NRDU-1:numOfDrbsReservForEmergency=2
...    NRCELL/NRREDRT-2:redirFreqEutra=1350
...    NRCELL/NRREDRT-2:redirPrio=2
...    NRCELL/NRREDRT-2:redirRat=eutra
@{GNB_PMQAP}
...    NRBTS:actNrpmqapProfiles=true
...    NRPMRNL-1:miNrHighRlcCellNrpmqap=15min
...    NRPMRNL-1:miNrNgInterfaceNrpmqap=15min
...    NRPMRNL-1:miNrNsaAcCuNrpmqap=15min
...    NRPMRNL-1:miNrPdcpCellNrpmqap=15min
...    NRPMRNL-1:miNrSaCuNrpmqap=15min
...    NRPMRNL-1:miNrUeStatNrpmqap=15min
...    NRPMRNL-1:miNrX2ccNrpmqap=15min
...    NRPMRNL-1/NRPMQAP-1:cfgProfType=SA
...    NRPMRNL-1/NRPMQAP-1:cfg5qiRange=9
...    NRPMRNL-1/NRPMQAP-1:cfgArpRange=15
...    NRPMRNL-1/NRPMQAP-1:cfgPlmnId:mncLength=3
...    NRPMRNL-1/NRPMQAP-1:cfgPlmnId:mcc=311
...    NRPMRNL-1/NRPMQAP-1:cfgPlmnId:mnc=489
...    NRPMRNL-1/NRPMQAP-1:cfgSliceId:sst=1
...    NRPMRNL-1/NRPMQAP-1:cfgSliceId:sd=13714341
...    NRPMRNL-1/NRPMQAP-2:cfgProfType=SA
...    NRPMRNL-1/NRPMQAP-2:cfg5qiRange=5,1
...    NRPMRNL-1/NRPMQAP-2:cfgArpRange=15,1
...    NRPMRNL-1/NRPMQAP-2:cfgPlmnId:mncLength=3
...    NRPMRNL-1/NRPMQAP-2:cfgPlmnId:mcc=311
...    NRPMRNL-1/NRPMQAP-2:cfgPlmnId:mnc=489
...    NRPMRNL-1/NRPMQAP-2:cfgSliceId:sst=1
...    NRPMRNL-1/NRPMQAP-2:cfgSliceId:sd=13714341
...    NRPMRNL-1/NRPMQAP-3:cfgProfType=SA
...    NRPMRNL-1/NRPMQAP-3:cfgArpRange=15,1
...    NRPMRNL-1/NRPMQAP-3:cfgPlmnId:mncLength=2
...    NRPMRNL-1/NRPMQAP-3:cfgPlmnId:mcc=460
...    NRPMRNL-1/NRPMQAP-3:cfgPlmnId:mnc=02
...    NRPMRNL-1/NRPMQAP-4:cfgProfType=SA
...    NRPMRNL-1/NRPMQAP-4:cfgArpRange=15,1
...    NRPMRNL-1/NRPMQAP-4:cfgSliceId:sst=1
...    NRPMRNL-1/NRPMQAP-4:cfgSliceId:sd=13714342
# PM counter for B02
${NG_FLOW_STP_FAIL_FALBACK_5QI1}    M55125C09519
${NG_FLOW_STP_FAIL_FALBACK_PMQAP}    M55163C00501
${NG_FLOW_SETUP_FAIL_FALLBACK}    M55125C09008
# PM counter for B04
${NG_FLOW_SETUP_FAIL_UNSPC_5QI1}    M55125C09522
${NG_FLOW_SETUP_FAIL_UNSPECIFIED}    M55125C09011
${NG_FLOW_SETUP_FAIL_UNSPC_PMQAP}    M55163C00511
# OnlineParam for B02 step1
@{OnlineParam_rrc_release_with_redirection}
...    NRCELL-1:emergencyFBMode=redirection
...    NRCELL-1/NRREDRT-2:redirFreqEutra=1350
...    NRBTS-1:actEmergencyFallback=true
...    NRBTS-1:actRedirect=true
...    NRCELL-1/NRREDRT-1:redirPrio=2
...    NRCELL-1/NRREDRT-2:redirPrio=1
# OnlineParam for B02 step2
@{OnlineParam_voiceFallback}
...    NRBTS-1:actNormVCFallback=true
...    NRBTS-1:actRedirect=true
...    NRCELL-1:voiceFBMode=redirection
...    NRCELL-1:actEnhancedVoNR=false
...    NRCELL-1:actVoNR=false
...    NRCELL-1:actCDrx=false
...    NRCELL-1:actCDrxVoNR=false
...    NRCELL-1:actGBRAdmissionControl=off
...    delete:NRCELL-1:maxGBRTrafficLimit
...    delete:NRCELL-1:n310VoNR
...    delete:NRCELL-1:t310VoNR
# OnlineParam for B04 step3
@{OnlineParam_redirFreqEutra}
...    NRBTS-1:actEmergencyFallback=true
...    NRCELL-1/NRREDRT-2:redirFreqEutra=262143
# PM counter check for B02
@{PM_Counters_Check_VoNR_pdu_modify_voice_eps_fallback}
...    NRCELL-1:${NG_FLOW_STP_FAIL_FALBACK_5QI1}=1
...    NRCELL-1:${NG_FLOW_SETUP_FAIL_FALLBACK}=1
...    NRCELL-1/PLMN-PLMN/NRPMQAP-2:${NG_FLOW_STP_FAIL_FALBACK_PMQAP}=1
@{PM_Counters_Check_Emergency_RRC_release_with_redirection_information}
...    NRCELL-1:${NG_FLOW_STP_FAIL_FALBACK_5QI1}=1
...    NRCELL-1:${NG_FLOW_SETUP_FAIL_FALLBACK}=2
...    NRCELL-1/PLMN-PLMN/NRPMQAP-2:${NG_FLOW_STP_FAIL_FALBACK_PMQAP}=2
# PM counter check for B04
@{PM_Counters_Check_VoNR_pdu_modify_Semantic_Error_Qos_parameter_missing}
...    NRCELL-1:${NG_FLOW_SETUP_FAIL_UNSPC_5QI1}=0
...    NRCELL-1:${NG_FLOW_SETUP_FAIL_UNSPECIFIED}=1
...    NRCELL-1/PLMN-PLMN/NRPMQAP-2:${NG_FLOW_SETUP_FAIL_UNSPC_PMQAP}=0
@{PM_Counters_Check_Emergency_ICS_failure_Unspecified_EmergencyFallbackIndicator}
...    NRCELL-1:${NG_FLOW_SETUP_FAIL_UNSPC_5QI1}=1
...    NRCELL-1:${NG_FLOW_SETUP_FAIL_UNSPECIFIED}=2
...    NRCELL-1/PLMN-PLMN/NRPMQAP-2:${NG_FLOW_SETUP_FAIL_UNSPC_PMQAP}=2
@{PM_Counters_Check_Emergency_ICS_failure_Unspecified_redirFreqEutra}
...    NRCELL-1:${NG_FLOW_SETUP_FAIL_UNSPC_5QI1}=1
...    NRCELL-1:${NG_FLOW_SETUP_FAIL_UNSPECIFIED}=2
...    NRCELL-1/PLMN-PLMN/NRPMQAP-2:${NG_FLOW_SETUP_FAIL_UNSPC_PMQAP}=2

*** Test Cases ***
CB008200-ET-B004_Verify Counter when QosFlow Setup Fail due to Unspecified Reasons
    [Documentation]
    ...    1. The purpose of this test case is to check counters when QosFlow setup fail due to Unspecified Reasons.
    ...    2. Test Case Steps:
    ...         a. Setup VONR call in UE-1 by AMF sending the NGAP: PDU SESSION RESOURCE MODIFY REQUEST missing QoS Flow Level QoS
    ...            Parameters,Then gNB sends NGAP:PDU SESSION RESOURCE MODIFY RESPONSE message to the AMF including the IE PDU
    ...            Session Resource Failed to Modify List containing PDU Session Resource Modify Unsuccessful Transfer IEs. The
    ...            Cause Group is set as "Protocol" and Cause value shall be set to "Semantic Error" or "Abstract syntax error".
    ...            check counter NG_FLOW_SETUP_FAIL_UNSPC_5QI1, NG_FLOW_SETUP_FAIL_UNSPECIFIED, NG_FLOW_SETUP_FAIL_UNSPC_PMQAP.
    ...         b. Set actEmergencyCall disabled, actEmergencyFallback disabled.
    ...            Setup Emergency call in UE-2 by AMF sending NGAP: INITIAL CONTEXT SETUP REQUEST with Emergency Fallback Indicator
    ...            IE included,  gNB sends NGAP: INITIAL CONTEXT SETUP FAILURE with Radio Network Layer cause: Unspecified.
    ...            check counter NG_FLOW_SETUP_FAIL_UNSPC_5QI1, NG_FLOW_SETUP_FAIL_UNSPECIFIED, NG_FLOW_SETUP_FAIL_UNSPC_PMQAP.
    ...         c. Set actEmergencyCall disabled, actEmergencyFallback enabled.
    ...            UE-3 don't support the EUTRA target frequency layer for redirection.
    ...            Setup Emergency call by AMF sending NGAP: INITIAL CONTEXT SETUP REQUEST with Emergency Fallback Indicator IE included,
    ...            gNB sends NGAP: INITIAL CONTEXT SETUP FAILURE with Radio Network Layer cause: Unspecified.
    ...            check counter NG_FLOW_SETUP_FAIL_UNSPC_5QI1, NG_FLOW_SETUP_FAIL_UNSPECIFIED, NG_FLOW_SETUP_FAIL_UNSPC_PMQAP.
    ...    3. Expected Results:
    ...         Step a: M55125C09522 NG_FLOW_SETUP_FAIL_UNSPC_5QI1=0
    ...                 M55125C09011 NG_FLOW_SETUP_FAIL_UNSPECIFIED=1
    ...                 M55163C00511 NG_FLOW_SETUP_FAIL_UNSPC_PMQAP=0
    ...         Step b: M55125C09522 NG_FLOW_SETUP_FAIL_UNSPC_5QI1=1
    ...                 M55125C09011 NG_FLOW_SETUP_FAIL_UNSPECIFIED=2
    ...                 M55163C00511 NG_FLOW_SETUP_FAIL_UNSPC_PMQAP=2
    ...         Step c: M55125C09522 NG_FLOW_SETUP_FAIL_UNSPC_5QI1=1
    ...                 M55125C09011 NG_FLOW_SETUP_FAIL_UNSPECIFIED=2
    ...                 M55163C00511 NG_FLOW_SETUP_FAIL_UNSPC_PMQAP=2
    [Tags]  QC_161089
    VoNR Call Test
    Emergency Call Fallback disabled Test
    Emergency Call Fallback enabled Test

CB008200-ET-B002_Verify Counter when QosFlow Setup Fail due to Voice Fallback
   [Documentation]
    ...    1. The purpose of this test case is to check counters when QosFlow setup fail due to Voice Fallback.
    ...    2. Test Case Steps:
    ...         a. Set actRedirect enabled, emergencyFBMode redirection, actEmergencyFallback enabled.
    ...            Setup emergency call in UE-4 by AMF sending InitialContextSetupRequest, gNB sends NGAP: INITIAL CONTEXT SETUP
    ...            RESPONSE to AMF, and with Radio Network Layer cause: RAN ims voice eps fallback or rat fallback triggered.
    ...            check counter NG_FLOW_STP_FAIL_FALBACK_PMQAP, NG_FLOW_STP_FAIL_FALBACK_5QI1, NG_FLOW_SETUP_FAIL_FALLBACK.
    ...         b. Set actCDrxVoNR disabled, actNormVCFallback enabled, actRedirect enabled, voiceFBMode redirection,
    ...            actEnhancedVoNR disabled, actVoNR disabled, actCDrx disabled.
    ...            Setup VONR call in UE-5 by AMF sending PduSessionResourceModifyRequest, GNB rejects the QoS flow setup with
    ...            PduSessionResourceModifyResponse with radioNetwork cause: ims-voice-eps-fallback-or-rat-fallback-triggered
    ...            check counter NG_FLOW_STP_FAIL_FALBACK_PMQAP, NG_FLOW_STP_FAIL_FALBACK_5QI1, NG_FLOW_SETUP_FAIL_FALLBACK.
    ...    3. Expected Results:
    ...         Step a: M55125C09519 NG_FLOW_STP_FAIL_FALBACK_5QI1=1
    ...                 M55125C09008 NG_FLOW_SETUP_FAIL_FALLBACK=2
    ...                 M55163C00501 NG_FLOW_STP_FAIL_FALBACK_PMQAP=2
    ...         Step b: M55125C09519 NG_FLOW_STP_FAIL_FALBACK_5QI1=1
    ...                 M55125C09008 NG_FLOW_SETUP_FAIL_FALLBACK=1
    ...                 M55163C00501 NG_FLOW_STP_FAIL_FALBACK_PMQAP=1
    [Tags]  QC_161087
    Emergency Call actEmergencyCall disabled
    VoNR Call when actVoNR disabled

*** Keywords ***
#common suite keyword
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri  ue_count=15
#    Debug Enter Into Egate

Modify Cfg
    Update Cfg    set_qosflow id=1 5qi=5 default=on
    Update Cfg    set_qosflow id=3 5qi=9
    Update Cfg    set_qosflow id=2 5qi=1
    Update Cfg    set_qosrule id=1 proto=tcp qos_flow=1
    Update Cfg    set_qosrule id=2 proto=udp qos_flow=2
    Update Cfg    set_nwslice id=1 snssai=0x01:0xD143A5 default=on ue=1-11 qos_flows=3,2,1 qos_rules=1,2 amf=1-6
    Update Cfg    ue_nr_capabilities id=1-11 voice_over_nr=on:on:off
    Update Cfg    amf_param id=1 full_nas_auth=on ims_voice_3gpp=on nia=null+zuc nea=null+zuc
    Update Cfg    set_nwslice id=2 snssai=0x01:0xD143A6 ue=1-11 qos_flows=3,2,1 qos_rules=1,2 amf=1-6
    Update Cfg    ue_param id=1-11 nr_usage_setting=voice_centric ue_nr_capabilities=${5qi1_UE_Capabilities}
    Update Cfg    set_pdu_gateway id=7 ue_nat_ip=72.23.6.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=8 ue_nat_ip=72.23.7.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=9 ue_nat_ip=72.23.8.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=10 ue_nat_ip=72.23.9.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=11 ue_nat_ip=72.23.10.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1

#common keyword
OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be Onair    check_sib=${False}

UE Register And Add Pdu With 5QI5
    [Arguments]    ${ue_id}    ${type}=${EMPTY}    ${emergency_call}=${EMPTY}    ${cause}=Initial Context Setup Failure
    Run Keyword If    '${type}'=='emergency'    Execute Egate Command    ue_nr_rrc_setup_param id=${ue_id} establishment_cause=emergency
    Execute Egate Command    ue_register id=${ue_id} nwslice=1    pass_regexp=Received REGISTRATION COMPLETE
    ${cmd}=    Set Variable    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${ue_id}
    ${cmd_emergency}=    Catenate    ${cmd}    request_type=initial-emergency-request
    ${ret}=    Run Keyword If    '${type}'=='emergency' and '${emergency_call}'=='failed'   Execute Egate Command    ${cmd_emergency}
    ...    pass_regexp=${cause}
    ...    ELSE
    ...    Execute Egate Command    ${cmd}     pass_regexp=UE${ue_id}: Ue ${ue_id} PduId 1 Created FiveQi:Qfi mapping fiveQi 5 qfi 1

Ue Deregister
    [Arguments]  ${ue_id}
    ${cmd_Deregister}=    Set Variable    ue_deregister id=${ue_id} ue_deregister_type=switch_off
    Execute Egate Command    ${cmd_Deregister}    pass_regexp=UE${ue_id}: detached

PDU Add QoSFlow 5QI1
    [Arguments]  ${ue_id}
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=2 by=amf

ICS with Emergency Fallback Indicator
    [Arguments]  ${amf_id}
    Execute Egate Command    amf_ue_ics_param id=${amf_id} emergency_fb=on target_cn=epc include_ue_capabilities=on
    Execute Egate Command    smf_param id=${amf_id} additional_qosflows_to_activate=2

#B004
VoNR Call Test
    Start To Capture Wireshark Log    vonr_pdu_modify_semantic_error
    Clear Counter Files
    Execute Egate Command    smf_param id=1 reset
    Execute Egate Command    qosflow_modify qos_flow=1 priority=15
    Execute Egate Command    qosflow_modify qos_flow=2 priority=15
    UE Register And Add Pdu With 5QI5    ue_id=1
    PDU Modify Resp Missing Qos Param    ue_id=1
    PDU Add QoSFlow 5QI1    ue_id=1
    Stop Capture Wireshark Log    vonr_pdu_modify_semantic_error
    Check Counters    ${PM_Counters_Check_VoNR_pdu_modify_Semantic_Error_Qos_parameter_missing}
    Ue Deregister    ue_id=1

PDU Modify Resp Missing Qos Param
    [Arguments]  ${ue_id}
    Execute Egate Command    amf_ue_pdu_modify_param id=1 ue=${ue_id} action=missing_qos_param  

Emergency Call Fallback disabled Test
    Start To Capture Wireshark Log    emergency_fallback_disable
    Clear Counter Files
    Execute Egate Command    smf_param id=1 reset
    Execute Egate Command    qosflow_modify qos_flow=1 priority=1
    Execute Egate Command    qosflow_modify qos_flow=2 priority=1
    ICS with Emergency Fallback Indicator    amf_id=1
    UE Register And Add Pdu With 5QI5    ue_id=2    type=emergency    emergency_call=failed
    Stop Capture Wireshark Log    emergency_fallback_disable
    Check Counters    ${PM_Counters_Check_Emergency_ICS_failure_Unspecified_EmergencyFallbackIndicator}
    Ue Deregister    ue_id=2

Emergency Call Fallback enabled Test
    OnlineParamChange  ${OnlineParam_redirFreqEutra}
    Start To Capture Wireshark Log    emergency_fallback_enable
    Clear Counter Files
    Execute Egate Command    smf_param id=1 reset
    Execute Egate Command    qosflow_modify qos_flow=1 priority=1
    Execute Egate Command    qosflow_modify qos_flow=2 priority=1
    ICS with Emergency Fallback Indicator    amf_id=1
    UE Register And Add Pdu With 5QI5    ue_id=3    type=emergency    emergency_call=failed
    Stop Capture Wireshark Log    emergency_fallback_enable
    Check Counters    ${PM_Counters_Check_Emergency_ICS_failure_Unspecified_redirFreqEutra}
    Ue Deregister    ue_id=3

#B002
Emergency Call actEmergencyCall disabled
    OnlineParamChange  ${OnlineParam_rrc_release_with_redirection}
    Start To Capture Wireshark Log    emergenc_rrc_release_with_redirection
    Clear Counter Files
    Execute Egate Command    smf_param id=1 reset
    Execute Egate Command    qosflow_modify qos_flow=1 priority=1
    Execute Egate Command    qosflow_modify qos_flow=2 priority=1
    ICS with Emergency Fallback Indicator    amf_id=1
    UE Register And Add Pdu With 5QI5    ue_id=4    type=emergency    emergency_call=failed
    ...    cause=RAN ims voice eps fallback or rat fallback triggered
    Stop Capture Wireshark Log    emergenc_rrc_release_with_redirection
    Check Counters    ${PM_Counters_Check_Emergency_RRC_release_with_redirection_information}
    Ue Deregister    ue_id=4

VoNR Call when actVoNR disabled
    OnlineParamChange  ${OnlineParam_voiceFallback}
    Start To Capture Wireshark Log    vonr_voice_eps_fallback
    Clear Counter Files
    Execute Egate Command    smf_param id=1 reset
    Execute Egate Command    qosflow_modify qos_flow=1 priority=15
    Execute Egate Command    qosflow_modify qos_flow=2 priority=15
    ICS with Voice Fallback Indicator    amf_id=1
    UE Register And Add Pdu With 5QI5    ue_id=5
    PDU Add QoSFlow 5QI1    ue_id=5
    Stop Capture Wireshark Log    vonr_voice_eps_fallback
    Check Counters    ${PM_Counters_Check_VoNR_pdu_modify_voice_eps_fallback}
    Ue Deregister    ue_id=5

ICS with Voice Fallback Indicator
    [Arguments]  ${amf_id}
    Execute Egate Command    amf_ue_ics_param id=${amf_id} emergency_fb=off
    Execute Egate Command    amf_param id=${amf_id} voice_fallback=on
