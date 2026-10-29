*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_FDD    CIT  team-SG2
...    CLOUD_5G_I_MP_AP_LO    VARIANT_SANSA_FS_CPRI_CMWV_FDD    CDRT  release-SBTS20B    owner-dan.liu    5GC000784

Resource  ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${DEBUG_LOG_LEVEL}    0
${AP_UDPLOG_LEVEL}    0

${GNB_BIP_FLAG}    ${True}

@{FAULTS_EXCLUDED_CHECKING}    7314

@{PARAMS_IN_SCF}
...    @{parameters_related_to_Voice_call}
...    @{parameters_5GC000784}

@{parameters_related_to_Voice_call}

...    NRBTS-1:rrcReestabTypeSA=viaRRCSetup
...    NRBTS-1:actNormVCFallback=false
...    NRBTS-1:cipherPrefL:nea0=1
...    NRBTS-1:cipherPrefL:nea1_128=0
...    NRBTS-1:cipherPrefL:nea2_128=9
...    NRBTS-1:cipherPrefL:nea3_128=0
...    NRBTS-1:integrityProtPrefL:nia1_128=0
...    NRBTS-1:integrityProtPrefL:nia2_128=9
...    NRBTS-1:integrityProtPrefL:nia3_128=0
...    NRBTS-1:drbInactivityTimerSA=100

...    NRBTS-1:srbInactivityTimerSA=100
...    NRBTS-1/NRDU-1:numOfDrbsReservForEmergency=2
...    NRBTS-1/NRCELL-1:actVoNR=true
...    NRBTS-1/NRCELL-1:actEmergencyCall=true
...    NRBTS-1/NRCELL-1:actEnhancedVoNR=true
...    NRBTS-1/NRCELL-1:actGBRAdmissionControl=EnhancedVoNR
...    NRBTS-1/NRCELL-1:arpPrioEmergencyCall=1

...    NRBTS-1/NRCELL-1:emergencyCallLimServ=true
...    NRBTS-1/NRCELL-1:emergencyCallRestrictions:emergencyCallMrListIgnore=true
...    NRBTS-1/NRCELL-1:emergencyCallRestrictions:emergencyCallPlmnHoAllowed=true
...    NRBTS-1/NRCELL-1:emergencyCallFails=true
...    NRBTS-1/NRCELL-1/NRREDRT-2:redirFreqEutra=1350
...    NRBTS-1/NRCELL-1/NRREDRT-2:redirPrio=2
...    NRBTS-1/NRCELL-1/NRREDRT-2:redirRat=eutra
...    delete:NRREDRT-2:redirSsbScs
...    NRBTS-1/NRPMRNL-1:miNrNgcFlexInterface=disabled
...    NRBTS-1/NRDRB_5QI-6:fiveqiValueList=1
...    NRBTS-1/NRDRB_5QI-6:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-15
...    NRBTS-1/NRDRB_MAC-3:lcgid=4
...    NRBTS-1/NRDRB_MAC-3:schedulPrio=5
...    NRBTS-1/NRDRB-15:actDddsReduction=false

...    NRBTS-1/NRDRB_PDCP-1:pdcpBufDiscardEnabled=false
...    NRDRB_RLC_UM-1:dlTReassemblyUm=ms40
...    NRDRB_RLC_UM-1:rlcUMDrbSNLength=rlcUm12bitSN
...    NRDRB_RLC_UM-1:ulTReassemblyUm=ms40
...    NRBTS-1/NRDRB-15:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-3
...    NRBTS-1/NRDRB-15:numSduDiscard=1
...    NRBTS-1/NRDRB-15:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1

...    NRBTS-1/NRDRB-15:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-1
...    NRBTS-1/NRDRB-15:dlFlowControlAlgo=none
...    NRBTS-1/NRDRB-15:resType=GBR
...    NRBTS-1/NRDRB-15:rlcMode=RLC_UM
...    NRBTS-1/NRDRB-15:queuingDelaySduDiscardThreshold=200



...    NRBTS-1/NRDRB-15:maxDataRateGbrDl=1000
...    NRBTS-1/NRDRB-15:maxDataRateGbrUl=1000
...    NRBTS-1/NRDRB-15:maxRlcQueueingDelayGbr=20
...    NRBTS-1/NRDRB-15:maxTransferDelayGbr=20
...    NRBTS-1/NRDRB-15:queuingDelayDiscarding=Disabled

...    NRBTS-1/NRDRB-15:sduDiscardIntervalTmr=100
...    NRBTS-1/NRDRB-15:schedulWeight=1

...    NRBTS-1/SNSSAI-1:administrativeState=Unlocked
...    NRBTS-1/SNSSAI-1:sd=13714341
...    NRBTS-1/SNSSAI-1:sst=1
...    NRBTS-1/SNSSAI-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS-1/SNSSAI-1:ngUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRBTS-1/SNSSAI-2:administrativeState=Unlocked
...    NRBTS-1/SNSSAI-2:sd=13714342
...    NRBTS-1/SNSSAI-2:sst=1
...    NRBTS-1/SNSSAI-2:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS-1/SNSSAI-2:ngUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRBTS-1/TRACKINGAREA-200:fiveGsTac=200
...    TRACKINGAREA-200:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1
...    TRACKINGAREA-200:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2

@{parameters_5GC000784}
...    MRBTS-1/NRBTS-1:tRLFindForDUVoNR=500ms
...    MRBTS-1/NRBTS-1/NRDRB-15:discardTimer=150ms
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-1:threshXHighQ=0
...    MRBTS-1/NRBTS-1/NRCELL-1:maxNumOfGBRBearersSA=2
...    MRBTS-1/NRBTS-1/NRCELL-1:maxNumOfNonGBRBearersSA=5
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-1:threshXLowQ=0
...    MRBTS-1/NRBTS-1/NRCELL-1:maxNumOfRrcSA=0
...    MRBTS-1/NRBTS-1/NRCELL-1:numOfRadioResReservForEmergency=2
...    MRBTS-1/NRBTS-1/NRCELLGRP-0:maxNumOfRrcCGRPSA=0

@{PM_Counters_5GC000638}
...    NRBTS-1:${NG_CU_RESET_REQ_RCV}=1
...    NRBTS-1:${NG_CU_RESET_ACK_SENT}=1

${NG_CU_RESET_REQ_RCV}    M55119C00012    #Number of NGAP:NG Reset messages received by gNB-CU
${NG_CU_RESET_ACK_SENT}    M55119C00013    #Number of NGAP:NG Reset Acknowledge messages sent by gNB-CU

${ue_nr_capabilities}    SEPARATOR=
...    E1A01000074E5A031E000381A00F04983200021E0A018806804C020301C022A36146B04050D012CB2898183D6C10101070EF1C39061C00103278
...    FAB80027800E0009E00151B11B582028680965944C0C1EB608080838778E1C830E0008193C7D53FF4FFCA8D89BAC10143404B2CA26060F5B0404
...    041C3BC70E418700040C9E3EAE0009E003800278000610713400000041C2800000010711800000802809B00A20230380780C04402301000FF555
...    5504C00E000A070500703007803800341F004000000000000000100795358194010400002596540000010074AAA881D0500E0016000100080100
...    20010040086AC4C0004080C1014181C202C4044484C648494989CA12986B40

@{fault_7314}    fault_id=7314    fault_name=NgamfInitFullReset    severity=transient

*** Test Cases ***
5GSW-CP-CIT030_Verify_Classical_SA_FDD_cmWave_emergency_call_setup_successful_after_Nglink_reset
    [Documentation]
    ...    This case is to verify successfully emergency call will be released after Nglink reset.
    ...    1. UE initial emergency call (ICS with EC5QI5,PDU session modify with EC5QI1)
    ...    2. Reset Nglink on gnb via set administrative state of SERVEDAMF NG-C link to "Locked"
    ...    3. UE could re-initials emergency call again
    [Tags]    QC_81229
    Clear Counter Files    ${False}
    Set UE RRC Establishment Cause to Emergency    ue_id=1
    Set qosflow priority and smf param reset
    Trigger UE MO VoNR call with PDU    ue_id=1    pdu_id=1    gw=1    nwslice=2    request_type=initial-emergency-request    fiveQI=5
    Make UE1 Exit From Idle To Connected And Check Expected Output
    Trigger UE 5QI add successfully with PDU session modify     1    1    1    2
    Trigger NG Reset By AMF
    Set UE RRC Establishment Cause to Emergency    ue_id=2
    Trigger 2nd EC call
    SA UE Deregister From GNB    1-2
    Check Wireshark Log    ${CURDIR}${/}a2a_CIT030${/}a2a_784.ini    wait_string=InitialContextSetupResponse::3
    Check Counters    ${PM_Counters_5GC000638}

*** Keywords ***
Common Suite Setup And Setup Airphone Env
  Common Suite Setup
  Setup Airphone Env  tl_type=fdd_sansa_cmwv/2cells

Modify Cfg
  Update Cfg  amf_param id=1 full_nas_auth=on nia=null+aes nea=null+aes voice_fallback=off ims_voice_3gpp=on
  ${C_1}  catenate
  ...  set_ue simulated id=1 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56
  ...  opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+aes nea=null+aes sec_key=0102030405060708090A0B0C0D0EFF00
  ...  suci=0:311:489:0000:0:0:021645400 mode=nr enb=2 cell=1
  Update Cfg  ${C_1}
  ${C_2}  catenate
  ...  set_ue simulated id=2 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56
  ...  opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+aes nea=null+aes sec_key=0102030405060708090A0B0C0D0EFF00
  ...  suci=0:311:489:0000:0:0:021645401 mode=nr enb=2 cell=1
  Update Cfg  ${C_2}
  Update Cfg  ue_param id=1 ue_nr_capabilities=${ue_nr_capabilities}
  Update Cfg  ue_param id=2 ue_nr_capabilities=${ue_nr_capabilities}
  Update Cfg  ue_nr_capabilities id=1 voice_over_nr=on:on:off
  Update Cfg  ue_nr_capabilities id=2 voice_over_nr=on:on:off
  Update Cfg  set_qosflow id=1 5qi=5 default=off
  Update Cfg  set_qosflow id=2 5qi=1
  Update Cfg  set_qosflow id=3 5qi=9 default=on
  Update Cfg  set_qosflow id=4 5qi=7
  Update Cfg  set_qosrule id=1 proto=tcp qos_flow=1
  Update Cfg  set_qosrule id=2 proto=udp qos_flow=2
  Update Cfg  set_nwslice id=1 snssai=0x01:0xD143A5 default=on ue=all amf=1 qos_flows=3,2,1 qos_rules=1,2
  Update Cfg  set_nwslice id=2 snssai=0x01:0xD143A6 ue=all amf=1 qos_flows=1,2,4 qos_rules=1,2
  Update Cfg  set_nwslice id=3 snssai=0x01:0xD143A7 ue=1 amf=1
  Update Cfg  set_pdu_gateway id=2 ue_nat_ip=72.23.1.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
  Update Cfg  set_amf_region id=1 tac_list=0,100,200,258,788 plmn=311:489

Trigger 2nd EC call
    Trigger UE MO VoNR call with PDU    2    1    2    2    initial-emergency-request    5
    Sleep    5s    #wait time before detach

Set UE RRC Establishment Cause to Emergency
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_nr_rrc_setup_param id=${ue_id} establishment_cause=emergency

Set qosflow priority and smf param reset
    [Arguments]   ${priority}=1
    BuiltIn.Log    Set qosflow priority and smf param...    console=${True}
    Execute Egate Command    qosflow_modify qos_flow=1 priority=${priority}
    Execute Egate Command    qosflow_modify qos_flow=2 priority=${priority}
    Execute Egate Command    qosflow_modify qos_flow=3 priority=${priority}
    Execute Egate Command    qosflow_modify qos_flow=4 priority=${priority}
    Execute Egate Command    smf_param id=1 reset

Trigger UE MO VoNR call with PDU
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${nwslice}=1    ${gw}=1    ${request_type}=initial-request    ${fiveQI}=9
    ...    ${cipheringAlgorithm}=nea2
    BuiltIn.Log    Trigger UE MO VoNR call with PDU...    console=${True}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Registered    timeout=20s

    ${ret1}    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} nwslice=${nwslice} gw=${gw} request_type=${request_type}
    ...        QoS Routing Table   timeout=20s
    Should Contain    ${ret1}    cipheringAlgorithm ${cipheringAlgorithm}
    Should Contain    ${ret1}    Initial Context Setup Successful for UE with AMF UE
    Should Contain    ${ret1}    Setup QosFlow with QFI:1 5QI:${fiveQI}

Make UE1 Exit From Idle To Connected And Check Expected Output
    Execute Egate Command    ue_im_entry id=1 by=ue    pass_regexp=Release Complete    timeout=100s
    ${ue1_status}=    Execute Egate Command    ue_disp id=1    pass_regexp=state    timeout=20s
    Should Contain    ${ue1_status}    IDLE
    ${ret1}    Execute Egate Command  ue_im_exit id=1 by=ue service_type=emergency_services
    ...    pass_regexp=Setup QosFlow with QFI:1 5QI:5    timeout=100s

Trigger UE 5QI add successfully with PDU session modify
    [Arguments]    ${ue_id}=1    ${pdu_id}=2    ${fiveQI}=1    ${qosflows_to_add}=2
    BuiltIn.Log    Trigger UE${ue_id} 5QI${fiveQI} add successfully with PDU session modify...    console=${True}
    ${ret1}    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_add=${qosflows_to_add} by=amf
   ...    Pdu Session Resource Modify Response Message with RAN UE NGAP ID [0-9]* handled successfully    timeout=20s
    Should Contain    ${ret1}    rrcReconfiguration
    Should Contain    ${ret1}    Added QosFlow with QFI:${qosflows_to_add} 5QI:${fiveQI}

Trigger UE PDU session release
    [Arguments]    ${ue_id}=1    ${pdu_id}=1
    BuiltIn.Log    Trigger UE${ue_id} PDU session release...    console=${True}
    Execute Egate Command    ue_pdu_session_release ue=${ue_id} pdu=${pdu_id} by=ue    Successfully released PDU Session
    ...    timeout=20s

Trigger NG Reset By AMF
    ${cmd}    Set Variable    link_ng_reset by=amf:1
    Execute Egate Command    ${cmd}    pass_regexp=Received NG Reset Acknowledge from GNB-2
    fm fault should be raised    ${fault_7314}

SA UE Deregister From GNB
    [Arguments]  ${ue_id}=1
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    detached
