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
...    NRBTS-1:actNormVCFallback=true
...    NRBTS-1:actRedirect=true
...    NRBTS-1:gNbCuType=SA+NSA

...    NRBTS-1:tRLFindForDUVoNR=500ms
...    NRBTS-1:cipherPrefL:nea0=1
...    NRBTS-1:cipherPrefL:nea1_128=0
...    NRBTS-1:cipherPrefL:nea2_128=9
...    NRBTS-1:cipherPrefL:nea3_128=0
...    NRBTS-1:integrityProtPrefL:nia1_128=0
...    NRBTS-1:integrityProtPrefL:nia2_128=9
...    NRBTS-1:integrityProtPrefL:nia3_128=0
...    NRBTS-1:drbInactivityTimerSA=100
...    NRBTS-1:srbInactivityTimerSA=100
...    NRBTS-1/NRCELL-1:actVoNR=true
...    NRBTS-1/NRCELL-1:voiceFBMode=redirection
...    NRBTS-1/NRCELL-1:cellDepType=SA+NSA
...    NRBTS-1/NRCELL-1:actEmergencyCall=true
...    NRBTS-1/NRCELL-1:actEnhancedVoNR=true
...    NRBTS-1/NRCELL-1:actGBRAdmissionControl=EnhancedVoNR
...    NRBTS-1/NRCELL-1:emergencyCallLimServ=true
...    NRBTS-1/NRCELL-1:maxGBRTrafficLimit=30
...    NRBTS-1/NRCELL-1:maxNumOfGBRBearersSA=1
...    NRBTS-1/NRCELL-1:maxNumOfNonGBRBearersSA=5
...    NRBTS-1/NRCELL-1:n310VoNR=n3
...    NRBTS-1/NRCELL-1:t310VoNR=500ms
...    NRBTS-1/NRCELL-1:emergencyCallRestrictions:emergencyCallMrListIgnore=true
...    NRBTS-1/NRCELL-1:emergencyCallRestrictions:emergencyCallPlmnHoAllowed=true
...    NRBTS-1/NRCELL-1:arpPrioEmergencyCall=1
...    NRBTS-1/NRCELL-1:emergencyCallFails=false
...    NRBTS-1/NRCELL-1:numOfRadioResReservForEmergency=1
...    NRBTS-1/NRDU-1:numOfDrbsReservForEmergency=1
@{5QI}
...    NRBTS-1/NRDRB_MAC-3:lcgid=4
...    NRBTS-1/NRDRB_MAC-3:schedulPrio=5
...    NRBTS-1/NRDRB_MAC-4:lcgid=1
...    NRBTS-1/NRDRB_MAC-4:schedulPrio=4
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
...    NRBTS-1/SNSSAI-1:administrativeState=Unlocked
...    NRBTS-1/SNSSAI-1:sd=13714341
...    NRBTS-1/SNSSAI-1:sst=1
...    NRBTS-1/SNSSAI-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS-1/SNSSAI-1:ngUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRBTS-1/SNSSAI-2:administrativeState=Unlocked
...    NRBTS-1/SNSSAI-2:sd=13714342
...    NRBTS-1/SNSSAI-2:sst=1
...    NRBTS-1/SNSSAI-2:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    delete:NRBTS-1/SNSSAI-2:ngUplane
...    NRBTS-1/TRACKINGAREA-200:fiveGsTac=200
...    NRBTS-1/TRACKINGAREA-200:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1
...    NRBTS-1/TRACKINGAREA-200:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2
...    NRBTS-1/NRDRB-10:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-4
@{delta_commission_params}
...    NRBTS-1/NRCELL-1:numOfRadioResReservForEmergency=0
${SA_Capa_perUE}    SEPARATOR=
...    E1A01000074E5A031E000381A00F04983200021E0A018806804C020301C022A36146B04050D012CB2898183D6C10101070EF1C39061C00103278FAB80027800E0009E00
...    151B11B582028680965944C0C1EB608080838778E1C830E0008193C7D53FF4FFCA8D89BAC10143404B2CA26060F5B0404041C3BC70E418700040C9E3EAE0009E0038002
...    78000610713400000041C2800000010711800000802809B00A20230380780C04402301000FF5555504C00E000A070500703007803800341F00400000000000000010079
...    5358194010400002596540000010074AAA881D0500E001600010008010020010040086AC4C0004080C1014181C202C4044484C648494989CA12986B40

*** Test Cases ***
5GC000784-ET-C012_Verify_emergency_call_failed_as_DRB_CU_RAC_failure_and_emergencyCallFails_disabled_UE_in_LSM_with_SIM
    [Documentation]
    ...    1. The purpose of this test case is to
    ...         Verify emergency call fails when emergencyCallFails disabled and parameters set as below:
    ...         maxNumerOfGbrBearersSA=1; numOfDrbsReservForEmergency=0; numOfRadioResReservForEmergency=0
    ...    2. Test Case Step:
    ...        a, Presetup numOfRadioResReservForEmergency to 1
    ...        b, UE2 setup emergenct call with 5QI5 and 5QI1, both with emergency ARP
    ...        c, LSM UE1 setup emergenct call with 5QI5 and 5QI1, both with emergency ARP
    ...        d, Online change numOfRadioResReservForEmergency to 0
    ...        e. UE1 enter idle mode
    ...        e, Make sure UE2 is active and trigger UE1 exit from idle mode
    ...    3. Expected Result:
    ...        UE1 emergency call failed as 5QI1 CU level RAC failure
    ...        Fallback to LTE not triggered
    [Tags]    QC_61191
    Set Qosflow Priority1 And Active Qosflow2
    Set UE RRC Establishment Cause To Emergency    ue_id=1
    UE With SIM But No Valid Subscription Initiates Emergency Call    ue_id=1    nwslice=2    gw=1
    Wait Until Keyword Succeeds    3 min    5 sec    Check Ue Status Is Idle    ue_id=1
    Delta Commission Parameters    ${delta_commission_params}
    Emergency UE2 Trigger Emergency Call And Pdu Setup Fail Without Fallback
    Check Wireshark Log    ${CURDIR}${/}a2a_C012${/}a2a_wireshark.ini    wait_string=InitialContextSetupFailure::2
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

Set Qosflow Priority1 And Active Qosflow2
    FOR    ${qosflow_id}    IN    1    2    3    4
        Execute Egate Command    qosflow_modify qos_flow=${qosflow_id} priority=1
    END
    Execute Egate Command    smf_param id=1 additional_qosflows_to_activate=2

Set UE RRC Establishment Cause To Emergency
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_nr_rrc_setup_param id=${ue_id} establishment_cause=emergency

UE With SIM But No Valid Subscription Initiates Emergency Call
    [Arguments]    ${ue_id}=1    ${nwslice}=2    ${gw}=1
    ${ret1}=    Execute Egate Command    ue_register id=${ue_id} registration_type=EmergencyRegistration withSim=yes
    ...    pass_regexp=UE now in NG RM Registered state    timeout=20s
    Should Contain    ${ret1}    Authentication Procedure is success
    ${ret2}=    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=2 nwslice=${nwslice} gw=${gw} request_type=initial-emergency-request
    ...    pass_regexp=QoS Routing Table    timeout=20s
    Should Contain    ${ret2}    rrcReconfiguration
    Should Contain    ${ret2}    Setup QosFlow with QFI:1 5QI:5
    Should Contain    ${ret2}    Setup QosFlow with QFI:2 5QI:1
    Should Contain    ${ret2}    cipheringAlgorithm nea0
    Should Contain    ${ret2}    integrityProtAlgorithm nia0

Check Ue Status Is Idle
    [Arguments]    ${ue_id}=1
    ${checkUeStatus}=    Execute Egate Command    ue_disp id=${ue_id}    pass_regexp=state    timeout=20s
    Should Contain    ${checkUeStatus}    IDLE

Trigger UE Emergency Call With PDU
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${nwslice}=1    ${gw}=1    ${fiveQI}=5
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=UE now in NG RM Registered state   timeout=20s
    ${cmd}=    Catenate    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} nwslice=${nwslice} gw=${gw} request_type=initial-emergency-request
    ${ret1}=    Execute Egate Command    ${cmd}    pass_regexp=QoS Routing Table   timeout=20s
    Should Contain    ${ret1}    securityModeCommand
    Should Contain    ${ret1}    cipheringAlgorithm nea2
    Should Contain    ${ret1}    Initial Context Setup Successful for UE with AMF UE
    Should Contain    ${ret1}    Setup QosFlow with QFI:1 5QI:${fiveQI}
    Should Contain    ${ret1}    Setup QosFlow with QFI:2 5QI:1

UE Exit From Idle Mode And Check Pdu Setup Fail Without Fallback
    [Arguments]    ${ue_id}=1
    ${ret}=    Execute Egate Command    ue_im_exit id=${ue_id} by=ue service_type=emergency_services
    ...    pass_regexp=Received Initial Context Setup Failure from GNB-2 with cause RAN radio resources not available    timeout=20s
    Should Not Contain    ${ret}    fallback
    sleep    2s    # To wait the InitialContextSetupFailure message

Emergency UE2 Trigger Emergency Call And Pdu Setup Fail Without Fallback
    Set UE RRC Establishment Cause To Emergency    ue_id=2
    Trigger UE Emergency Call With PDU    ue_id=2    pdu_id=1    nwslice=2    gw=2    fiveQI=5   
    UE Exit From Idle Mode And Check Pdu Setup Fail Without Fallback    ue_id=1	