*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_FDD    CRT    CLOUD_5G_I_MP_AP_LO    VARIANT_SANSA_FS_CPRI_CMWV_FDD
...    team-DevHZ5_SG4    owner-eric.jiang    release-5G20B    5GC000784-C
Resource    ..${/}..${/}..${/}..${/}resources${/}DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{5GC000784}    
...    @{5QI}
@{5GC000784}
...    NRBTS-1:actRedirect=true
...    NRBTS-1:actNormVCFallback=false
...    NRBTS-1:gNbCuType=SA+NSA

...    NRBTS-1:tRLFindForDUVoNR=500ms
...    NRBTS-1:actEmergencyFallback=false
...    NRBTS-1:srbInactivityTimerSA=100
...    NRBTS-1:drbInactivityTimerSA=100
...    NRBTS-1:cipherPrefL:nea0=1
...    NRBTS-1:cipherPrefL:nea1_128=0
...    NRBTS-1:cipherPrefL:nea2_128=9
...    NRBTS-1:cipherPrefL:nea3_128=0
...    NRBTS-1:integrityProtPrefL:nia0=0
...    NRBTS-1:integrityProtPrefL:nia1_128=0
...    NRBTS-1:integrityProtPrefL:nia2_128=9
...    NRBTS-1:integrityProtPrefL:nia3_128=0
...    NRBTS-1/NRCELL-1:actVoNR=true
...    NRBTS-1/NRCELL-1:cellDepType=SA+NSA
...    NRBTS-1/NRCELL-1:emergencyCallLimServ=true
...    NRBTS-1/NRCELL-1:voiceFBMode=redirection
...    NRBTS-1/NRCELL-1:actEmergencyCall=true
...    NRBTS-1/NRCELL-1:actEnhancedVoNR=true
...    NRBTS-1/NRCELL-1:actGBRAdmissionControl=EnhancedVoNR
...    NRBTS-1/NRCELL-1:maxGBRTrafficLimit=30
...    NRBTS-1/NRCELL-1:maxNumOfGBRBearersSA=1
...    NRBTS-1/NRCELL-1:maxNumOfNonGBRBearersSA=5
...    NRBTS-1/NRCELL-1:n310VoNR=n3
...    NRBTS-1/NRCELL-1:t310VoNR=500ms
...    NRBTS-1/NRCELL-1:emergencyCallRestrictions:emergencyCallMrListIgnore=true
...    NRBTS-1/NRCELL-1:emergencyCallRestrictions:emergencyCallPlmnHoAllowed=true
...    NRBTS-1/NRCELL-1:arpPrioEmergencyCall=1
...    NRBTS-1/NRCELL-1:emergencyCallFails=true
...    NRBTS-1/NRCELL-1:maxNumOfRrcSA=10
...    NRBTS-1/NRCELL-1:numOfRadioResReservForEmergency=0
...    NRBTS-1/NRDU-1:numOfDrbsReservForEmergency=0
@{5QI}
...    NRBTS-1/NRDRB_MAC-3:lcgid=4
...    NRBTS-1/NRDRB_MAC-3:schedulPrio=5
...    NRBTS-1/NRDRB_RLC_UM-1:dlTReassemblyUm=ms40
...    NRBTS-1/NRDRB_RLC_UM-1:ulTReassemblyUm=ms40
...    NRBTS-1/NRDRB_PDCP-2:pdcpBufDiscardEnabled=false
...    NRBTS-1/NRDRB-15:dlFlowControlAlgo=none
...    NRBTS-1/NRDRB-15:dscp=0
...    NRBTS-1/NRDRB-15:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-3
...    NRBTS-1/NRDRB-15:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-2
...    NRBTS-1/NRDRB-15:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRBTS-1/NRDRB-15:numSduDiscard=1
...    NRBTS-1/NRDRB-15:queuingDelayDiscarding=Disabled
...    NRBTS-1/NRDRB-15:queuingDelaySduDiscardThreshold=750
...    NRBTS-1/NRDRB-15:resType=GBR
...    NRBTS-1/NRDRB-15:rlcMode=RLC_UM
...    NRBTS-1/NRDRB-15:sduDiscardIntervalTmr=100
...    NRBTS-1/NRDRB-15:schedulWeight=1
...    NRBTS-1/NRDRB-15:discardTimer=150ms
...    NRBTS-1/NRDRB-15:actDddsReduction=false
...    NRBTS-1/NRDRB-15:maxDataRateGbrDl=1000
...    NRBTS-1/NRDRB-15:maxDataRateGbrUl=1000
...    NRBTS-1/NRDRB_5QI-6:fiveqiValueList=1
...    NRBTS-1/NRDRB_5QI-6:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-15 
...    NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-1:threshXHighQ=0
...    NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-1:threshXLowQ=0
...    NRBTS-1/SNSSAI-1:sd=13714341
...    NRBTS-1/SNSSAI-1:sst=1
...    NRBTS-1/SNSSAI-1:ngUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRBTS-1/SNSSAI-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS-1/SNSSAI-2:administrativeState=Unlocked
...    NRBTS-1/SNSSAI-2:sd=13714342
...    NRBTS-1/SNSSAI-2:sst=1
...    NRBTS-1/SNSSAI-2:ngUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRBTS-1/SNSSAI-2:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS-1/TRACKINGAREA-200:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1
...    NRBTS-1/TRACKINGAREA-200:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2
...    NRBTS-1/NRCELL-1/NRREDRT-2:redirRat=eutra
...    delete:NRBTS-1/NRCELL-1/NRREDRT-2:redirSsbScs
...    NRBTS-1/NRCELL-1/NRREDRT-2:redirFreqEutra=1350
...    NRBTS-1/NRCELL-1/NRREDRT-2:redirPrio=2
${cprt_log_level}    0x590072
${conrt_cuup_log_level}    0x41001b
@{PARAMS_IN_SWCONFIG}
...    ${cprt_log_level}=1
...    ${conrt_cuup_log_level}=1
${SA_Capa_perUE}    SEPARATOR=
...    E1A01000074E5A031E000381A00F04983200021E0A018806804C020301C022A36146B04050D012CB2898183D6C10101070EF1C39061C00103278FAB80027800E0009E00
...    151B11B582028680965944C0C1EB608080838778E1C830E0008193C7D53FF4FFCA8D89BAC10143404B2CA26060F5B0404041C3BC70E418700040C9E3EAE0009E0038002
...    78000610713400000041C2800000010711800000802809B00A20230380780C04402301000FF5555504C00E000A070500703007803800341F00400000000000000010079
...    5358194010400002596540000010074AAA881D0500E001600010008010020010040086AC4C0004080C1014181C202C4044484C648494989CA12986B40

*** Test Cases ***
5GC000784-ET-C013_Verify_emergency_call_fallback_to_LTE_due_to_DRB_CU_RAC_failure_during_ICS_in_case_UE_in_LSM_with_SIM
    [Documentation]    The purpose of this test case is to verfify
    ...    1.the successful initiation of the noraml voice call for a UE.
    ...    2.Verify second PDU session setup fail casue in PDU session Resource Setup Unsuccessful Transfer IE
    ...    for UE with SIM/UICC which could be authenticated but no valid subscription
    [Tags]    QC_61190
    Setup Normal Call With UE2
    Reset Qosflow Priority And Smf Param
    Check UE2 Status Is Active
    Trigger Emergency Call With SIM On UE1 And UE1 Will Fall Back To LTE
    Release Ues    ue_type=all

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fdd_sansa_cmwv/2cells    match_string=${EMPTY}    cfg=auto   ue_count=2
    #Debug Enter Into Egate

Modify Cfg
    Update Cfg    amf_param id=1 nia=null+aes nea=null+aes voice_fallback=off ims_voice_3gpp=on full_nas_auth=on
    ${ue1_cmd}=    Catenate    set_ue simulated id=1 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 
        ...    opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null nea=null sec_key=0102030405060708090A0B0C0D0EFF00 
        ...    suci=0:311:489:0000:0:0:021645400 imei=12345123:451234:1 mode=nr enb=2 cell=1
    Update Cfg    ${ue1_cmd}
    ${ue2_cmd}=    Catenate    set_ue simulated id=2 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 
        ...    opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+aes nea=null+aes sec_key=0102030405060708090A0B0C0D0EFF00 
        ...    suci=0:311:489:0000:0:0:021645401 imei=12345123:451234:2 mode=nr enb=2 cell=1
    Update Cfg    ${ue2_cmd}	
    Update Cfg    ue_param id=1 ue_nr_capabilities=${SA_Capa_perUE} nr_usage_setting=voice_centric
    Update Cfg    ue_param id=2 ue_nr_capabilities=${SA_Capa_perUE} nr_usage_setting=voice_centric
    Update Cfg    ue_nr_capabilities id=1 voice_over_nr=on:on:off
    Update Cfg    ue_nr_capabilities id=2 voice_over_nr=on:on:off
    Update Cfg    set_qosflow id=1 5qi=5 default=off
    Update Cfg    set_qosflow id=2 5qi=1  
    Update Cfg    set_qosflow id=3 5qi=9 default=on
    Update Cfg    set_qosflow id=4 5qi=7
    Update Cfg    set_qosrule id=1 proto=tcp qos_flow=1
    Update Cfg    set_qosrule id=2 proto=udp qos_flow=2
    Update Cfg    set_nwslice id=1 snssai=0x01:0xD143A5 qos_flows=3,2,1 qos_rules=1,2 default=on ue=1-2 amf=1
    Update Cfg    set_nwslice id=2 snssai=0x01:0xD143A6 qos_flows=1,2,4 qos_rules=1,2 ue=1-2 amf=1
    Update Cfg    set_pdu_gateway id=3 ue_nat_ip=72.23.0.3 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1

Setup Normal Call With UE2
    Execute Egate Command    smf_param id=1 additional_qosflows_to_activate=2
    Execute Egate Command    ue_register id=2    UE now in NG RM Registered    timeout=20s
    ${cmd}=    Catenate    ue_pdu_session_setup ue=2 pdu=2 nwslice=2 gw=3 request_type=initial-request        
    ${ret}=    Execute Egate Command    ${cmd}    QoS Routing Table    timeout=20s
    Should Contain    ${ret}    securityModeCommand
    Should Contain    ${ret}    cipheringAlgorithm nea2
    Should Contain    ${ret}    Initial Context Setup Successful for UE with AMF UE
    Should Contain    ${ret}    Setup QosFlow with QFI:1 5QI:5
    Should Contain    ${ret}    Setup QosFlow with QFI:2 5QI:1

Reset Qosflow Priority And Smf Param
    Execute Egate Command    qosflow_modify qos_flow=1 priority=1
    Execute Egate Command    qosflow_modify qos_flow=2 priority=1
    Execute Egate Command    qosflow_modify qos_flow=3 priority=1
    Execute Egate Command    qosflow_modify qos_flow=4 priority=1
    Execute Egate Command    smf_param id=1 additional_qosflows_to_activate=2

Check UE2 Status Is Active
    ${UE2Status}=    Execute Egate Command    ue_disp id=2    state    timeout=20s
    Should Contain    ${UE2Status}    ACTIVE

Trigger Emergency Call With SIM On UE1 And UE1 Will Fall Back To LTE
    Execute Egate Command    ue_nr_rrc_setup_param id=1 establishment_cause=emergency
    ${ret1}=    Execute Egate Command    ue_register id=1 registration_type=EmergencyRegistration withSim=yes    
    ...    UE now in NG RM Registered    timeout=20s
    Should Contain    ${ret1}    Authentication Procedure is success
    ${ret2}=    Execute Egate Command    
    ...     ue_pdu_session_setup ue=1 pdu=2 nwslice=2 gw=1 request_type=initial-emergency-request    
    ...     Received RRC Release while in FIVE     timeout=20s
    Should Contain    ${ret2}    Received Initial Context Setup Failure
    Should Contain    ${ret2}    redirection
    Should Contain    ${ret2}    E-UTRA redirectedCarrierInfo=1350