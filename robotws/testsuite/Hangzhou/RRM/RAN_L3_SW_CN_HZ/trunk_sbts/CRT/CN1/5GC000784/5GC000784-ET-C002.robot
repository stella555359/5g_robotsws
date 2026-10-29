*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_FDD    CRT    CLOUD_5G_I_MP_AP_LO    VARIANT_SANSA_FS_CPRI_CMWV_FDD
...    team-DevHZ5_SG4    owner-eric.jiang    release-5G20B    5GC000784-C
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{5GC000784}
...    @{5QI}
@{5GC000784}
...    NRBTS-1:rrcReestabTypeSA=viaRRCSetup
...    NRBTS-1:actNormVCFallback=false
...    NRBTS-1:cipherPrefL:nea0=1
...    NRBTS-1:cipherPrefL:nea1_128=0
...    NRBTS-1:cipherPrefL:nea2_128=9
...    NRBTS-1:cipherPrefL:nea3_128=0
...    NRBTS-1:integrityProtPrefL:nia1_128=0
...    NRBTS-1:integrityProtPrefL:nia2_128=9
...    NRBTS-1:integrityProtPrefL:nia3_128=0
...    NRBTS-1/NRDU-1:numOfDrbsReservForEmergency=2
...    NRBTS-1/NRCELL-1:actVoNR=true
...    NRBTS-1/NRCELL-1:actEmergencyCall=true
...    NRBTS-1/NRCELL-1:actEnhancedVoNR=true
...    NRBTS-1/NRCELL-1:actGBRAdmissionControl=EnhancedVoNR
...    NRBTS-1/NRCELL-1:arpPrioEmergencyCall=1
...    NRBTS-1/NRCELL-1:emergencyCallLimServ=true
...    NRBTS-1/NRCELL-1:emergencyCallRestrictions:emergencyCallMrListIgnore=true
...    NRBTS-1/NRCELL-1:emergencyCallRestrictions:emergencyCallPlmnHoAllowed=true
...    NRBTS-1/NRCELL-1:numOfRadioResReservForEmergency=0
@{5QI}
...    NRBTS-1/NRPMRNL-1:miNrNgcFlexInterface=disabled
...    NRBTS-1/NRDRB_5QI-6:fiveqiValueList=1
...    NRBTS-1/NRDRB_5QI-6:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-15
...    NRBTS-1/NRDRB_MAC-3:lcgid=4
...    NRBTS-1/NRDRB_MAC-3:schedulPrio=5
...    NRBTS-1/NRDRB_PDCP-1:pdcpBufDiscardEnabled=false
...    NRDRB_RLC_UM-1:dlTReassemblyUm=ms40
...    NRDRB_RLC_UM-1:rlcUMDrbSNLength=rlcUm12bitSN
...    NRDRB_RLC_UM-1:ulTReassemblyUm=ms40
...    NRBTS-1/NRDRB-15:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-3
...    NRBTS-1/NRDRB-15:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRBTS-1/NRDRB-15:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-1
...    NRBTS-1/NRDRB-15:dlFlowControlAlgo=none
...    NRBTS-1/NRDRB-15:resType=GBR
...    NRBTS-1/NRDRB-15:rlcMode=RLC_UM
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
${SA_Capa_perUE}    SEPARATOR=
...    E1A01000074E5A031E000381A00F04983200021E0A018806804C020301C022A36146B04050D012CB2898183D6C10101070EF1C39061C00103278FAB80027800E0009E00
...    151B11B582028680965944C0C1EB608080838778E1C830E0008193C7D53FF4FFCA8D89BAC10143404B2CA26060F5B0404041C3BC70E418700040C9E3EAE0009E0038002
...    78000610713400000041C2800000010711800000802809B00A20230380780C04402301000FF5555504C00E000A070500703007803800341F00400000000000000010079
...    5358194010400002596540000010074AAA881D0500E001600010008010020010040086AC4C0004080C1014181C202C4044484C648494989CA12986B40

*** Test Cases ***
5GC000784-ET-C002_Verify_successfully_emergency_call_setup_with_5QI5_Setup_in_ICSR_in_case_UE_In_LSM_without_SIM
    [Documentation]
    ...    This case is to verify the emergency call can be setup when UE is in Limited service mode without SIM,
    ...    and ICSR should contain 5QI5 sent from AMF to GNB.
    [Tags]    QC_61197
    UE1 Setup Emergency Call Without SIM Card
    Make UE1 Exit From Idle To Connected And Check Expected Output
    Trigger UE1 5QI1 Setup Successfully
    Trigger UE1 PDU Session Release
	Release Ues  ue_type=all

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fdd_sansa_cmwv/2cells    match_string=${EMPTY}    cfg=auto    ue_count=5
    #Debug Enter Into Egate

Modify Cfg
    Update Cfg    amf_param id=1 nia=null+aes nea=null+aes voice_fallback=off ims_voice_3gpp=on full_nas_auth=on
    FOR    ${sa_ue_id}    IN RANGE    1    6
        ${suci_suffix}=    Evaluate    21645400+${sa_ue_id}-1
        ${ue_cmd}    Catenate    set_ue simulated id=${sa_ue_id} uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 
        ...    opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null nea=null sec_key=0102030405060708090A0B0C0D0EFF00 
        ...    suci=0:311:489:0000:0:0:0${suci_suffix} imei=12345123:451234:${sa_ue_id} mode=nr enb=2 cell=1
        Update Cfg    ${ue_cmd}
        Update Cfg    ue_param id=${sa_ue_id} ue_nr_capabilities=${SA_Capa_perUE} nr_usage_setting=voice_centric
        Update Cfg    ue_nr_capabilities id=${sa_ue_id} voice_over_nr=on:on:off
    END
    Update Cfg    set_qosflow id=1 5qi=5
    Update Cfg    set_qosflow id=2 5qi=1
    Update Cfg    set_qosflow id=3 5qi=9 default=on
    Update Cfg    set_qosflow id=4 5qi=7
    Update Cfg    set_qosrule id=1 proto=tcp qos_flow=1
    Update Cfg    set_qosrule id=2 proto=udp qos_flow=2
    Update Cfg    set_nwslice id=1 snssai=0x01:0xD143A5 qos_flows=1,2,3 qos_rules=1,2 default=on ue=all amf=1
    Update Cfg    set_nwslice id=2 snssai=0x01:0xD143A6 qos_flows=1,2,4 qos_rules=1,2 ue=all amf=1

Set Qosflow Priority1 And Reset Smf Param
    FOR    ${qosflow_id}    IN    1    2    3    4
        Execute Egate Command    qosflow_modify qos_flow=${qosflow_id} priority=1
    END
    Execute Egate Command    smf_param id=1 reset

UE1 Setup Emergency Call Without SIM Card
    Start To Capture Wireshark Log    UE1_EmergencyCall
    Execute Egate Command    ue_nr_rrc_setup_param id=1 establishment_cause=emergency
    Execute Egate Command    amf_param id=1 bypassAuth_nullSecurity=on 
    Set Qosflow Priority1 And Reset Smf Param
    ${ret1}=    Execute Egate Command    ue_register id=1 registration_type=EmergencyRegistration withSim=no
    ...    pass_regexp=UE now in NG RM Registered state    timeout=20s
    Should Contain    ${ret1}    Authentication Procedure is success
    ${ret2}=    Execute Egate Command    ue_pdu_session_setup ue=1 pdu=1 gw=1 nwslice=2 request_type=initial-emergency-request
    ...    pass_regexp=QoS Routing Table    timeout=20s
    Should Contain    ${ret2}    rrcReconfiguration
    Should Contain    ${ret2}    Setup QosFlow with QFI:1 5QI:5
    Should Contain    ${ret2}    cipheringAlgorithm nea0
    Should Contain    ${ret2}    integrityProtAlgorithm nia0
    Stop Capture Wireshark Log    UE1_EmergencyCall

Make UE1 Exit From Idle To Connected And Check Expected Output	
    Execute Egate Command    ue_im_entry id=1 by=ue    pass_regexp=UE1: IS IDLE    timeout=100s
    ${ue1_status}=    Execute Egate Command    ue_disp id=1    pass_regexp=state    timeout=20s
    Should Contain    ${ue1_status}    IDLE
    ${ret1}=    Execute Egate Command  ue_im_exit id=1 by=ue service_type=emergency_services
    ...    pass_regexp=Setup QosFlow with QFI:1 5QI:5    timeout=100s

Trigger UE1 5QI1 Setup Successfully
    Start To Capture Wireshark Log    UE1_5QI1_Setup
    ${ret1}=    Execute Egate Command    ue_pdu_session_modify ue=1 pdu=1 qosflows_to_add=2 by=amf    pass_regexp=QoS Routing Table    timeout=20s
    Should Contain    ${ret1}    rrcReconfiguration
    Should Contain    ${ret1}    pdcp-SN-SizeUL len12bits
    Should Contain    ${ret1}    pdcp-SN-SizeDL len12bits
    Should Contain    ${ret1}    ul-UM-RLC
    Should Contain    ${ret1}    sn-FieldLength size12
    Should Contain    ${ret1}    dl-UM-RLC
    Should Contain    ${ret1}    sn-FieldLength size12
    Should Contain    ${ret1}    t-Reassembly ms40
    Should Contain    ${ret1}    schedulingRequestID 0
    Stop Capture Wireshark Log    UE1_5QI_1Setup

Trigger UE1 PDU Session Release
    Execute Egate Command    ue_pdu_session_release ue=1 pdu=1 by=ue    pass_regexp=Successfully released PDU Session    timeout=20s
