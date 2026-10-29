*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    RAN_5G_FDD    SBTS00    team-Rock_SGT&A    owner-tingjian.mao
...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    CRT   
...    STATE_CONFIGURED    RAN_5G

Resource    ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
${TL_TYPE_PATH}    tdd_sansa_cmwv/FS/2cells_ecpri
${5qi1_UE_Capabilities}    SEPARATOR=
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
...    NRDRB_MAC-3:schedulBSD=50ms
...    NRDRB_PDCP-2:pdcpBufDiscardEnabled=false
...    NRDRB_RLC_UM-1:dlTReassemblyUm=ms40
...    NRDRB_RLC_UM-1:rlcUMDrbSNLength=rlcUm12bitSN
...    NRDRB_RLC_UM-1:ulTReassemblyUm=ms40
...    NRDRB-10:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-4
...    NRDRB-10:resType=nonGBR_Signaling
...    NRDRB-15:discardTimer=infinity
...    NRDRB-15:dlFlowControlAlgo=none
...    NRDRB-15:dscp=0
#...    NRDRB-15:durationThresDiscard=50
...    NRDRB-15:actDddsReduction=false
...    NRDRB-15:actLostPduFastRetx=false
...    NRDRB-15:maxDddsPeriodCpuOvld=40
...    NRDRB-15:maxDataRateGbrDl=1000
...    NRDRB-15:maxDataRateGbrUl=1000
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
#...    NRDRB-15:volThresDiscard=100
...    NRDRB_5QI-6:fiveqiValueList=1
...    NRDRB_5QI-6:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-15
@{Gnb_EmergencyCall}
...    NRBTS:tRLFindForDUVoNR=500ms
...    NRBTS:drbInactivityTimerSA=7200
...    NRBTS:rrcReestabTypeSA=viaRRCSetup
...    NRSYSINFO_PROFILE-1/NRIRFIM-1:threshXHighQ=0
...    NRSYSINFO_PROFILE-1/NRIRFIM-1:threshXLowQ=0
...    NRCELL:actEmergencyCall=true
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
...    NRPMRNL-1/NRPMQAP-1:cfg5qiRange=2
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
...    NRPMRNL-1/NRPMQAP-3:cfg5qiRange=5,1
...    NRPMRNL-1/NRPMQAP-3:cfgArpRange=15,1
...    NRPMRNL-1/NRPMQAP-3:cfgPlmnId:mncLength=3
...    NRPMRNL-1/NRPMQAP-3:cfgPlmnId:mcc=311
...    NRPMRNL-1/NRPMQAP-3:cfgPlmnId:mnc=489
...    NRPMRNL-1/NRPMQAP-3:cfgSliceId:sst=1
...    NRPMRNL-1/NRPMQAP-3:cfgSliceId:sd=13714343
#...    NRPMRNL-1/NRPMQAP-4:cfgProfType=SA
#...    delete:NRBTS-1/NRPMRNL-1/NRPMQAP-4:cfg5qiRange
#...    delete:NRBTS-1/NRPMRNL-1/NRPMQAP-4:cfgArpRange
#...    delete:NRBTS-1/NRPMRNL-1/NRPMQAP-4:cfgPlmnId
#...    delete:NRBTS-1/NRPMRNL-1/NRPMQAP-4:cfgSliceId

${NG_FLOW_STP_FAIL_UE_LOST_5QI1}    M55125C09520
${NG_FLOW_SETUP_FAIL_UE_LOST}    M55125C09009
${NG_FLOW_STP_FAIL_UE_LOST_PMQAP}    M55163C00509

${NG_FLOW_SETUP_FAIL_WRONG_MSG}    M55125C09012
${NG_FLOW_STP_FAIL_WRG_MSG_5QI1}    M55125C09523
${NG_FLOW_STP_FAIL_WRG_MSG_PMQAP}    M55163C00512

${NG_FLOW_SETUP_FAIL_RADIO_PROC}    M55125C09010
${NG_FLOW_STP_FAIL_RAD_PROC_5QI1}    M55125C09521
${NG_FLOW_STP_FAIL_RADPROC_PMQAP}    M55163C00510

@{PM_Counters_Check_SA_Radio_Connection_With_UE_Lost}
...    NRCELL-1:${NG_FLOW_STP_FAIL_UE_LOST_5QI1}=1
...    NRCELL-1:${NG_FLOW_SETUP_FAIL_UE_LOST}=1
...    NRCELL-1/PLMN-PLMN/NRPMQAP-2:${NG_FLOW_STP_FAIL_UE_LOST_PMQAP}=1

@{PM_Counters_Check_SA_Radio_Connection_Wrong_Message_from_Core_step1}
...    NRCELL-1:${NG_FLOW_SETUP_FAIL_WRONG_MSG}=2
...    NRCELL-1:${NG_FLOW_STP_FAIL_WRG_MSG_5QI1}=1
...    NRCELL-1/PLMN-PLMN/NRPMQAP-3:${NG_FLOW_STP_FAIL_WRG_MSG_PMQAP}=2

@{PM_Counters_Check_SA_Radio_Connection_Wrong_Message_from_Core_step2}
...    NRCELL-1:${NG_FLOW_SETUP_FAIL_WRONG_MSG}=1
...    NRCELL-1:${NG_FLOW_STP_FAIL_WRG_MSG_5QI1}=1
#...    NRCELL-1/PLMN-PLMN/NRPMQAP-4:${NG_FLOW_STP_FAIL_WRG_MSG_PMQAP}=1

@{PM_Counters_Check_SA_Radio_Connection_Wrong_Message_from_Core_step3}
...    NRCELL-1:${NG_FLOW_SETUP_FAIL_WRONG_MSG}=1
...    NRCELL-1:${NG_FLOW_STP_FAIL_WRG_MSG_5QI1}=1
...    NRCELL-1/PLMN-PLMN/NRPMQAP-2:${NG_FLOW_STP_FAIL_WRG_MSG_PMQAP}=1

@{PM_Counters_Check_SA_Radio_Connection_Wrong_Message_from_Core_step4}
...    NRCELL-1:${NG_FLOW_SETUP_FAIL_WRONG_MSG}=1
...    NRCELL-1:${NG_FLOW_STP_FAIL_WRG_MSG_5QI1}=0
...    NRCELL-1/PLMN-PLMN/NRPMQAP-1:${NG_FLOW_STP_FAIL_WRG_MSG_PMQAP}=1

@{PM_Counters_Check_SA_Radio_Connection_failure_in_radio}
...    NRCELL-1:${NG_FLOW_SETUP_FAIL_RADIO_PROC}=2
...    NRCELL-1:${NG_FLOW_STP_FAIL_RAD_PROC_5QI1}=1
...    NRCELL-1/PLMN-PLMN/NRPMQAP-2:${NG_FLOW_STP_FAIL_RADPROC_PMQAP}=2

@{ENABLE_VoNR_Drx}
...    NRCELL:actVoNR=true
...    NRBTS:actNormVCFallback=true

@{DISABLE_VoNR_Drx}
...    NRCELL:actVoNR=false
...    NRBTS:actNormVCFallback=false

*** Test Cases ***
CB008200-ET-B001_Verify Counter when QosFlow Setup Fail due to Radio Connection With Ue Lost
    [Tags]    QC_197312
    [Documentation]
    ...    1.Purpose
    ...    This User scenario is to provide the counters used for measuring SA accessibility. The User scenario
    ...    creates a counter to measure the number of QosFlows that fail to setup due to Connection with Ue Lost.
    ...    The User Scenario is a rerun of multiple User Scenario
    ...    2. Test Case Steps:
    ...    Step 1: Setup VONR call in UE1 by  AMF sending the NgAP:PDUSessionResourceModifyRequest, no response for RRC
    ...            RECONFIGURATION, UE sends RRC: RRC REESTABLISHMENT REQUEST message to the gNB-DU with the
    ...            reestablishmentCause IE set to the value reconfigurationFailure, The gNB-CU-CP sends the NgAP:
    ...            PDUSessionResourceModifyResponse message to the AMF including the IE PDU Session Resource Failed
    ...            to Modify List ,The Cause Group is set as "Radio Network Layer" and Cause value shall be set to
    ...            "Radio Connection With UE Lost" , and then release ue to idle state.
    ...    Step 2: Setup VONR call in UE1 by AMF sending the NgAP:PDUSessionResourceModifyRequest, The gNB-DU sends RRC:
    ...            RRC RECONFIGURATION message to the UE, rrcGuardTimer expires with no response, The gNB-CU-CP sends
    ...            the NgAP:PDUSessionResourceModifyResponse message to the AMF including the IE PDU Session Resource
    ...            Failed to Modify List,The Cause Group is set as "Radio Network Layer" and Cause value shall be set
    ...            to "Radio Connection with the UE lost", and then release ue to idle state.
    ...    3. Expected Result:
    ...    Step 1 check counter:
    ...            NG_FLOW_STP_FAIL_UE_LOST_5QI1+1, NG_FLOW_STP_FAIL_UE_LOST_PMQAP+1,  NG_FLOW_SETUP_FAIL_UE_LOST+1
    ...    Step 2 check counter:
    ...            NG_FLOW_STP_FAIL_UE_LOST_5QI1+1, NG_FLOW_STP_FAIL_UE_LOST_PMQAP+1,  NG_FLOW_SETUP_FAIL_UE_LOST+1
    SA Call Test with ue lost for reconfigurationFailure
    SA Call Test with ue lost for time out

CB008200-ET-B003_Verify Counter when QosFlow Setup Fail due to Wrong Message from Core
    [Tags]    QC_161088
    [Documentation]
    ...    1.Purpose
    ...    This User scenario is to provide the counters used for measuring SA accessibility. The User scenario creates
    ...    a counter to measure the number of QosFlows that fail to setup due to Connection with Ue Lost. The User
    ...    Scenario is a rerun of multiple User Scenario
    ...    2. Test Case Steps:
    ...    Step 1: Setup VONR call in UE1 by AMF sending NgAP:PDUSessionResourceSetupRequest with not supported S-NSSAI.
    ...            gNB-CU-CP rejects the the request and replies with NgAP:PDUSessionResourceSetupResponse message to 5GC.
    ...            Message contains the failed PDU Session and cause set to " Slice(s) not supported".
    ...    Step 2: Setup VONR call in UE2 by AMF sending PDUSessionResourceModifyRequest to add 5QI-1 with  Invalid PDU
    ...            Session ID,The gNB-CU-CP sends the NgAP:PDUSessionResourceModifyResponse message to the AMF including
    ...            the IE PDU Session Resource Failed to Modify List and Error Type  : Unknown PDU Session ID
    ...    Step 3: Setup video call, AMF send initial context setup request including 5QI-5 , PDU Session Resource Modify
    ...            Request only setup 5QI-2,  rejected with cause 'invalid QoS Combination'
    ...    Step 4: modify actVoNR disabled, actNormVCFallback disabled, Setup VoNR call and non-GBR call in UE3 by AMF
    ...            sending the NGAP: PDU SESSION RESOURCE MODIFY REQUEST with 5QI-1, gNB-CU-CP shall send the message
    ...            PduSessionResourceModifyResponse message with PDU Session Resource Modify Unsuccessful Transfer cause
    ...            indicating "Not supported 5QI value" for the failed PDU session ID with 5QI=1
    ...    3. Expected Result:
    ...    Step 1 check counter:
    ...            NG_FLOW_SETUP_FAIL_WRONG_MSG+2, NG_FLOW_STP_FAIL_WRG_MSG_5QI1+1, NG_FLOW_STP_FAIL_WRG_MSG_PMQAP+2
    ...    Step 2 check counter:
    ...            NG_FLOW_SETUP_FAIL_WRONG_MSG+1, NG_FLOW_STP_FAIL_WRG_MSG_PMQAP+1
    ...    Step 3 check counter:
    ...            NG_FLOW_SETUP_FAIL_WRONG_MSG+1 NG_FLOW_STP_FAIL_WRG_MSG_PMQAP+1(including 5QI-2)
    ...    Step 4 check counter:
    ...            NG_FLOW_STP_FAIL_WRG_MSG_5QI1+1 and NG_FLOW_SETUP_FAIL_WRONG_MSG+1, NG_FLOW_STP_FAIL_WRG_MSG_PMQAP+1
    VONR Call Test with not supportes S-NSSAI
    VONR Call Test with Invalid PDU Session ID
    VONR Call Test with invalid QoS Combination
    VONR Call Test with actVoNR disabled
    [teardown]     Common Test Teardown And Enable VoNR

CB008200-ET-B005_Verify Counter when QosFlow Setup Fail due to failure_in_radio_interface_procedure
    [Tags]    QC_161090
    [Documentation]
    ...    1.Purpose
    ...    This User scenario is to provide the counters used for measuring SA accessibility. The User scenario creates
    ...    a counter to measure the number of QosFlows that fail to setup due to Connection with Ue Lost. The User
    ...    Scenario is a rerun of multiple User Scenario
    ...    2. Test Case Steps:
    ...    Step 1: SetupSA CALL then VONR call in UE1 by AMF sending PDUSessionResourceModifyRequest to add 5QI-1 ,
    ...            RRC Reconfiguration  timeout, then NgAP:PDUSessionResourceModifyResponse:
    ...            PDUSessionResourceFailedToModifyListModRes, cause:"Radionetwork:failure-in-radio-interface-procedure"
    ...    3. Expected Result:
    ...    Step 1 check counter:
    ...            NG_FLOW_STP_FAIL_RADPROC_PMQAP+2,NG_FLOW_SETUP_FAIL_RADIO_PROC+2,  NG_FLOW_STP_FAIL_RAD_PROC_5QI1+1
    SA and VONR Call Test with RRC Reconfiguration timeout

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri    ue_count=6
#    Debug Enter Into Egate

Modify Cfg
    Update Cfg    set_qosflow id=1 5qi=5 default=on
    Update Cfg    set_qosflow id=3 5qi=9
    Update Cfg    set_qosflow id=2 5qi=1
    Update Cfg    set_qosflow id=4 5qi=2
    Update Cfg    set_qosrule id=1 proto=tcp qos_flow=1
    Update Cfg    set_qosrule id=2 proto=udp qos_flow=2
    Update Cfg    set_nwslice id=1 snssai=0x01:0xD143A5 default=on ue=1-6 qos_flows=4,3,2,1 qos_rules=1,2 amf=1-6
    Update Cfg    set_nwslice id=2 snssai=0x01:0xD143A6 ue=1-6 qos_flows=1,2,3 qos_rules=1,2 amf=1-6
    Update Cfg    set_nwslice id=3 snssai=0x01:0xD143A7 ue=1-6 amf=1
    Update Cfg    set_nwslice id=4 snssai=0x01:0xD143A8 ue=1 amf=1
    Update Cfg    ue_nr_capabilities id=1-6 voice_over_nr=on:on:off
    Update Cfg    amf_param id=1 full_nas_auth=on ims_voice_3gpp=on nia=null+zuc nea=null+zuc
    Update Cfg    set_nwslice id=2 snssai=0x01:0xD143A6 ue=1-6 qos_flows=4,3,2,1 qos_rules=1,2 amf=1-6
    Update Cfg    ue_param id=1-6 nr_usage_setting=voice_centric ue_nr_capabilities=${5qi1_UE_Capabilities}

Common Test Teardown And Enable VoNR
    Delta Commission Parameters    ${ENABLE_VoNR_Drx}
    Common Test Teardown And Stop Capture Logs


UE Register And Add Pdu With Default 5QI5
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_register id=${ue_id} nwslice=1  pass_regexp=Received REGISTRATION COMPLETE
    ${cmd}=    Set Variable    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${ue_id}
    Execute Egate Command    ${cmd}    pass_regexp=UE${ue_id}: Ue ${ue_id} PduId 1 Created FiveQi:Qfi mapping fiveQi 5 qfi 1

SA UE Register And Add Pdu With Default 5QI9
    [Arguments]    ${ue_id}
    Execute Egate Command    qosflow_modify qos_flow=3 default=on
    Execute Egate Command    ue_register id=${ue_id} nwslice=1    pass_regexp=Received REGISTRATION COMPLETE
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=1
    ...    pass_regexp=UE${ue_id}: Ue ${ue_id} PduId 1 Created FiveQi:Qfi mapping fiveQi 9 qfi 1

UE Register And Add Pdu With 5QI5 and 5QI1 Failure
    [Arguments]    ${ue_id}    ${nwslice_id}
    Execute Egate Command    smf_param id=1 additional_qosflows_to_activate=2
    Execute Egate Command    ue_register id=${ue_id} nwslice=1  pass_regexp=Received REGISTRATION COMPLETE
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=${nwslice_id} gw=${ue_id}
    ...    pass_regexp=Received Initial Context Setup Failure from GNB-2 with cause RAN slice not supported

SA UE Add Pdu With 5QI5 and 5QI1 Default 5QI5
    [Arguments]    ${ue_id}
    Execute Egate Command    qosflow_modify qos_flow=1 default=on
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=2 nwslice=1 gw=${ue_id}
    ...    pass_regexp=UE${ue_id}: Ue ${ue_id} PduId 2 Created FiveQi:Qfi mapping fiveQi 5 qfi 1
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=2 qosflows_to_add=2 by=amf
    ...    pass_regexp=PDU Session Resource Modify Unsuccessful Transfer

PDU Add QoSFlow 5QI2
    [Arguments]    ${ue_id}    ${qos_id}
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=${qos_id} by=amf
    ...    pass_regexp=PDU Session Resource Modify Unsuccessful Transfer

PDU Add QoSFlow 5QI1 Failure
    [Arguments]    ${ue_id}    ${action}    ${pdu_id}=1
    ${cmd}=    Set Variable    ue_nr_rrc_reconf_param id=${ue_id} if_contains=any action=${action}
    ${cmd_cause}=    Catenate    ${cmd}    cause=reconfigurationFailure
    ${ret}=    Run Keyword If    '${action}'=='reestablish'    Execute Egate Command    ${cmd_cause}
    ...    ELSE    Execute Egate Command    ${cmd}
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_add=2 by=amf
    ...    pass_regexp=PDU Session Resource Modify Unsuccessful Transfer

PDU Add QoSFlow 5QI1 And 5QI5 Failure
    [Arguments]    ${ue_id}    ${action}    ${pdu_id}
    Execute Egate Command    ue_nr_rrc_reconf_param id=${ue_id} if_contains=any action=${action}
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} nwslice=1 gw=2
    ...    pass_regexp=PDU Session Resource Setup with PDU Session ID ${pdu_id} was unsuccessful

SA Call Test with ue lost for reconfigurationFailure
    Clear Counter Files
    UE Register And Add Pdu With Default 5QI5    ue_id=1
    PDU Add QoSFlow 5QI1 Failure    ue_id=1    action=reestablish
    Check Counters    ${PM_Counters_Check_SA_Radio_Connection_With_UE_Lost}
    Release Ues    ue_id=1

SA Call Test with ue lost for time out
    Clear Counter Files
    UE Register And Add Pdu With Default 5QI5    ue_id=1
    PDU Add QoSFlow 5QI1 Failure    ue_id=1    action=drop
    Check Counters    ${PM_Counters_Check_SA_Radio_Connection_With_UE_Lost}
    Release Ues    ue_id=1

VONR Call Test with not supportes S-NSSAI
    Clear Counter Files
    UE Register And Add Pdu With 5QI5 and 5QI1 Failure    ue_id=1    nwslice_id=3
    Check Counters    ${PM_Counters_Check_SA_Radio_Connection_Wrong_Message_from_Core_step1}
    Release Ues    ue_id=1
    Execute Egate Command    smf_param id=1 reset

VONR Call Test with Invalid PDU Session ID
    Clear Counter Files
    UE Register And Add Pdu With Default 5QI5    ue_id=2
    Execute Egate Command    ue_pdu_session_modify ue=2 pdu=2 qosflows_to_add=2 by=amf validation=off
    ...    pass_regexp=PDU Session Resource Modify Unsuccessful Transfer
    Check Counters    ${PM_Counters_Check_SA_Radio_Connection_Wrong_Message_from_Core_step2}
    Release Ues    ue_id=2

VONR Call Test with actVoNR disabled
    Delta Commission Parameters    ${DISABLE_VoNR_Drx}
    Clear Counter Files
    SA UE Register And Add Pdu With Default 5QI9    ue_id=3
    SA UE Add Pdu With 5QI5 and 5QI1 Default 5QI5    ue_id=3
    Check Counters    ${PM_Counters_Check_SA_Radio_Connection_Wrong_Message_from_Core_step3}
    Release Ues    ue_id=3

VONR Call Test with invalid QoS Combination
    Clear Counter Files
    UE Register And Add Pdu With Default 5QI5    ue_id=4
    PDU Add QoSFlow 5QI2    ue_id=4    qos_id=4
    Check Counters    ${PM_Counters_Check_SA_Radio_Connection_Wrong_Message_from_Core_step4}
    Release Ues    ue_id=4

SA and VONR Call Test with RRC Reconfiguration timeout
    Clear Counter Files
    SA UE Register And Add Pdu With Default 5QI9    ue_id=1
    Execute Egate Command    qosflow_modify qos_flow=1 default=on
    Execute Egate Command    smf_param id=1 additional_qosflows_to_activate=2
    PDU Add QoSFlow 5QI1 And 5QI5 Failure    ue_id=1    action=invalid_tid    pdu_id=2
    Check Counters    ${PM_Counters_Check_SA_Radio_Connection_failure_in_radio}
    Execute Egate Command    smf_param id=1 reset
    Release Ues    ue_id=1
