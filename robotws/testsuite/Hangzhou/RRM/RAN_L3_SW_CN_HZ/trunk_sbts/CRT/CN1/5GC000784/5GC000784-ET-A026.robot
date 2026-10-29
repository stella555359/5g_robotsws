*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_FDD    CRT    CLOUD_5G_I_MP_AP_LO    VARIANT_SANSA_FS_CPRI_CMWV_FDD
...           team-SG2    owner-dan.liu    release-SBTS22R3
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{5GC000784}
...    @{5QI}

@{5GC000784}
...    NRBTS-1/NRCELL-1:actVoNR=true
#...    NRBTS-1:actNormVCFallback=false
...    NRBTS-1:cipherPrefL:nea0=1
...    NRBTS-1:cipherPrefL:nea1_128=0
...    NRBTS-1:cipherPrefL:nea2_128=9
...    NRBTS-1:cipherPrefL:nea3_128=0
...    NRBTS-1:integrityProtPrefL:nia1_128=0
...    NRBTS-1:integrityProtPrefL:nia2_128=9
...    NRBTS-1:integrityProtPrefL:nia3_128=0
...    NRBTS-1/NRDU-1:numOfDrbsReservForEmergency=0
...    NRBTS-1/NRCELL-1:actEmergencyCall=true
...    NRBTS-1/NRCELL-1:actEnhancedVoNR=true
...    NRBTS-1/NRCELL-1:actGBRAdmissionControl=EnhancedVoNR
...    NRBTS-1/NRCELL-1:arpPrioEmergencyCall=1
...    NRBTS-1/NRCELL-1:emergencyCallLimServ=true
...    NRBTS-1/NRCELL-1:emergencyCallRestrictions:emergencyCallMrListIgnore=true
...    NRBTS-1/NRCELL-1:emergencyCallRestrictions:emergencyCallPlmnHoAllowed=true
@{5QI}
...    NRBTS-1/NRDRB_RLC_UM-1:dlTReassemblyUm=ms40
...    NRBTS-1/NRDRB_RLC_UM-1:nrDrbRlcUmId=1
...    NRBTS-1/NRDRB_RLC_UM-1:ulTReassemblyUm=ms40
...    NRBTS-1/NRDRB-15:dlFlowControlAlgo=none
...    NRBTS-1/NRDRB-15:dscp=0
...    NRBTS-1/NRDRB-15:nrDrbId=15
...    NRBTS-1/NRDRB-15:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-3
...    NRBTS-1/NRDRB-15:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-2
...    NRBTS-1/NRDRB_PDCP-2:pdcpBufDiscardEnabled=false
...    NRBTS-1/NRDRB-15:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRBTS-1/NRDRB-15:numSduDiscard=1
...    NRBTS-1/NRDRB-15:queuingDelayDiscarding=Disabled
...    NRBTS-1/NRDRB-15:queuingDelaySduDiscardThreshold=750
...    NRBTS-1/NRDRB-15:resType=GBR
...    NRBTS-1/NRDRB-15:maxDataRateGbrUl=1000
...    NRBTS-1/NRDRB-15:maxDataRateGbrDl=1000
...    NRBTS-1/NRDRB-15:rlcMode=RLC_UM
...    NRBTS-1/NRDRB-15:sduDiscardIntervalTmr=100
...    NRBTS-1/NRDRB_5QI-6:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-15
...    NRBTS-1/NRDRB_5QI-6:fiveqiValueList=1
...    NRBTS-1/NRDRB_MAC-3:lcgid=4
...    NRBTS-1/NRDRB_MAC-3:schedulPrio=5
...    NRBTS-1/NRDRB_MAC-3:nrDrbMacId=3
...    NRBTS-1/NRDRB_MAC-4:lcgid=1
...    NRBTS-1/NRDRB_MAC-4:schedulPrio=4
...    NRBTS-1/NRDRB_MAC-4:nrDrbMacId=4
...    NRBTS-1:gNbCuType=SA+NSA
...    NRBTS-1/NRCELL-1:cellDepType=SA+NSA
...    NRBTS-1/NRDRB-10:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-4
...    NRBTS-1/NRDRB-15:schedulWeight=1

...    NRBTS-1/NRCELL-1:maxGBRTrafficLimit=30
...    NRBTS-1/NRCELL-1:maxNumOfGBRBearersSA=1
...    NRBTS-1/NRCELL-1:maxNumOfNonGBRBearersSA=1
...    NRBTS-1/NRCELL-1:n310VoNR=n3
...    NRBTS-1/NRCELL-1:t310VoNR=500ms
...    NRBTS-1:tRLFindForDUVoNR=500ms
...    NRBTS-1/NRDRB-15:discardTimer=150ms
...    NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-1:threshXHighQ=0
...    NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-1:threshXLowQ=0
...    NRBTS-1/SNSSAI-1:ngUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRBTS-1/SNSSAI-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS-1/SNSSAI-2:administrativeState=Unlocked
...    NRBTS-1/SNSSAI-2:sd=13714342
...    NRBTS-1/SNSSAI-2:sst=1
...    NRBTS-1/SNSSAI-2:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    delete:NRBTS-1/SNSSAI-2:ngUplane
...    NRBTS-1/TRACKINGAREA-200:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1
...    NRBTS-1/TRACKINGAREA-200:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2
...    NRBTS-1/NRCELL-1:emergencyCallFails=false
...    NRBTS-1/NRCELL-1:maxNumOfRrcSA=10
...    NRBTS-1/NRCELL-1:numOfRadioResReservForEmergency=0
...    NRBTS-1/NRCELLGRP-0:maxNumOfRrcCGRPSA=100
...    NRBTS-1/NRCELLGRP-0:maxNumOfNonGBRBearersCGRPSA=30
...    NRBTS-1/NRCELL-1/NRREDRT-2:redirFreqEutra=1350
...    NRBTS-1/NRCELL-1/NRREDRT-2:redirPrio=2
...    NRBTS-1/NRDU-1:maxNumOfRrcConUEsPerDU=100
...    NRBTS-1:drbInactivityTimerSA=100
...    NRBTS-1:srbInactivityTimerSA=100

@{A026_param}
...    NRBTS-1/NRCELL-1:maxNumOfNonGBRBearersSA=1
...    NRBTS-1/NRDU-1:numOfDrbsReservForEmergency=0

${cause_22}    radio resources not available

${SA_Capa_perUE}    SEPARATOR=
...    E1A01000074E5A031E000381A00F04983200021E0A018806804C020301C022A36146B04050D012CB2898183D6C10101070EF1C39061C00103278FAB80027800E0009E00
...    151B11B582028680965944C0C1EB608080838778E1C830E0008193C7D53FF4FFCA8D89BAC10143404B2CA26060F5B0404041C3BC70E418700040C9E3EAE0009E0038002
...    78000610713400000041C2800000010711800000802809B00A20230380780C04402301000FF5555504C00E000A070500703007803800341F00400000000000000010079
...    5358194010400002596540000010074AAA881D0500E001600010008010020010040086AC4C0004080C1014181C202C4044484C648494989CA12986B40

*** Test Cases ***
5GC000784-ET-A026_Verify_unsuccessfully_emergency_call_setup_with_2_PDU_session_and_gNB_can_admit_only_one
    [Documentation]
    ...    1. The purpose of this test case is to
    ...         Verify only one pdu session can be admit when setup up 2 pdu sessions with parameters below:
    ...         NumOfNonGBRBearersSA=1; maxNumerOfGbrBearersSA=1; numOfDrbsReservForEmergency =0.
    ...    2. Test Case Step:
    ...        UE initail one emergency call
    ...        a, UE setup one PDU session with 5QI6
    ...        b, UE setup the emergency PDU session with 5QI5 and 5QI1, both with emergency ARP
    ...    3. Expected Result:
    ...        PDU session setup fail casue in PDU session Resource Setup Unsuccessful Transfer IE
    [Tags]    QC_61216
    OnlineParamChange    ${A026_param}
    Trigger UE MO VoNR call with PDU    fiveQI=6
    Set qosflow priority and smf param
    Trigger UE 5QI5 And 5QI1 Setup Fail With Same PDU NGAP Procedure
    Check Wireshark Log    ${CURDIR}${/}a2a_A026${/}a2a_wireshark.ini    wait_string=UEContextReleaseComplete::1
    Release Ues    ue_type=all

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fdd_sansa_cmwv/2cells

Modify Cfg
    Update Cfg    amf_param id=1 full_nas_auth=on nia=null+aes nea=null+aes voice_fallback=off ims_voice_3gpp=on
    Update Cfg    set_amf_region id=2 tac_list=0,100,258,788 plmn=311:489
    Update Cfg    set_amf_region id=3 tac_list=0,100,258,788 plmn=311:489
    Update Cfg    set_amf_region id=4 tac_list=0,100,258,788 plmn=311:489
    Update Cfg    set_amf_region id=5 tac_list=0,100,258,788 plmn=311:489
    Update Cfg    set_amf id=2 daemon=10.0.2.1:22222 ng=10.0.1.9:38412 region=2 set_id=2 pointer=2
    Update Cfg    set_amf id=3 daemon=10.0.2.1:22222 ng=10.0.1.10:38412 region=3 set_id=2 pointer=2
    Update Cfg    set_amf id=4 daemon=10.0.2.1:22222 ng=10.0.1.11:38412 region=4 set_id=2 pointer=2
    Update Cfg    set_amf id=5 daemon=10.0.2.1:22222 ng=10.0.1.12:38412 region=5 set_id=2 pointer=2
    Update Cfg    amf_param id=2 full_nas_auth=on nia=null+zuc nea=null+zuc
    Update Cfg    amf_param id=3 full_nas_auth=on nia=null+zuc nea=null+zuc
    Update Cfg    amf_param id=4 full_nas_auth=on nia=null+zuc nea=null+zuc
    Update Cfg    amf_param id=5 full_nas_auth=on nia=null+zuc nea=null+zuc
    ${Ue_Simu1}    catenate    set_ue simulated id=1 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...    nia=null+aes nea=null+aes sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0000:0:0:021645400 mode=nr enb=2 cell=1
    Update Cfg    ${Ue_Simu1}
    ${Ue_Simu2}    catenate    set_ue simulated id=2 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...    nia=null+aes nea=null+aes sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0000:0:0:021645401 mode=nr enb=2 cell=1
    Update Cfg    ${Ue_Simu2}
    ${Ue_Simu3}    catenate    set_ue simulated id=3 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...    nia=null+aes nea=null+aes sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0000:0:0:021645402 mode=nr enb=2 cell=1
    Update Cfg    ${Ue_Simu3}
    ${Ue_Simu4}    catenate    set_ue simulated id=4 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...    nia=null+aes nea=null+aes sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0000:0:0:021645403 mode=nr enb=2 cell=1
    Update Cfg    ${Ue_Simu4}
    ${Ue_Simu5}    catenate    set_ue simulated id=5 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...    nia=null+aes nea=null+aes sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0000:0:0:021645404 mode=nr enb=2 cell=1
    Update Cfg    ${Ue_Simu5}
    Update Cfg    ue_param id=1 ue_nr_capabilities=${SA_Capa_perUE} nr_usage_setting=voice_centric
    Update Cfg    ue_param id=2 ue_nr_capabilities=${SA_Capa_perUE} nr_usage_setting=voice_centric
    Update Cfg    ue_param id=3 ue_nr_capabilities=${SA_Capa_perUE} nr_usage_setting=voice_centric
    Update Cfg    ue_param id=4 ue_nr_capabilities=${SA_Capa_perUE}
    Update Cfg    ue_param id=5 ue_nr_capabilities=${SA_Capa_perUE}
    Update Cfg    set_qosflow id=1 5qi=5 default=off
    Update Cfg    set_qosflow id=2 5qi=1
    Update Cfg    set_qosflow id=3 5qi=6 default=on
    Update Cfg    set_qosflow id=4 5qi=7
    Update Cfg    set_qosrule id=1 proto=tcp qos_flow=1
    Update Cfg    set_qosrule id=2 proto=udp qos_flow=2
    Update Cfg    set_qosrule id=3 proto=udp qos_flow=3
    Update Cfg    set_nwslice id=1 snssai=0x01:0xD143A5 default=on ue=1-6 amf=1 qos_flows=3,2,1 qos_rules=1,2
    Update Cfg    set_nwslice id=2 snssai=0x01:0xD143A6 ue=1-6 amf=1 qos_flows=1,2,4 qos_rules=1,2
    Update Cfg    set_nwslice id=3 snssai=0x01:0xD143A7 ue=1 amf=1
    Update Cfg    set_nwslice id=4 snssai=0x01:0xD143A8 ue=1 amf=1
    Update Cfg    set_pdu_gateway id=1 ue_nat_ip=72.23.0.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=2 ue_nat_ip=72.23.1.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=3 ue_nat_ip=72.23.2.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=4 ue_nat_ip=72.23.3.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=5 ue_nat_ip=72.23.4.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=6 ue_nat_ip=72.23.5.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    ue_nr_capabilities id=1 voice_over_nr=on:on:off
    Update Cfg    ue_nr_capabilities id=2 voice_over_nr=on:on:off
    Update Cfg    ue_nr_capabilities id=3 voice_over_nr=on:on:off
    Update Cfg    ue_nr_capabilities id=4 voice_over_nr=on:on:off
    Update Cfg    ue_nr_capabilities id=5 voice_over_nr=on:on:off
    Update Cfg    ue_nr_capabilities id=6 voice_over_nr=on:on:off

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir

Trigger UE MO VoNR call with PDU
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${nwslice}=1    ${gw}=1    ${request_type}=initial-request    ${fiveQI}=9
    ...    ${additional_qosflows_to_activate}=reset    ${cipheringAlgorithm}=nea2
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Registered    timeout=20s
    ${cmd}    Catenate    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} nwslice=${nwslice} gw=${gw} request_type=${request_type}
    ${ret1}=    Execute Egate Command    ${cmd}    QoS Routing Table    timeout=20s
    Should Contain    ${ret1}=    securityModeCommand
    Should Contain    ${ret1}=    cipheringAlgorithm ${cipheringAlgorithm}
    Should Contain    ${ret1}=    Initial Context Setup Successful for UE with AMF UE
    Should Contain    ${ret1}=    Setup QosFlow with QFI:1 5QI:${fiveQI}

Set qosflow priority and smf param
    [Arguments]    ${additional_qosflows_to_activate}=2    ${priority}=1
    Execute Egate Command    qosflow_modify qos_flow=1 priority=${priority}
    Execute Egate Command    qosflow_modify qos_flow=2 priority=${priority}
    Execute Egate Command    qosflow_modify qos_flow=3 priority=${priority}
    Execute Egate Command    qosflow_modify qos_flow=4 priority=${priority}
    Execute Egate Command    smf_param id=1 additional_qosflows_to_activate=${additional_qosflows_to_activate}

Trigger UE 5QI5 And 5QI1 Setup Fail With Same PDU NGAP Procedure
    [Arguments]    ${ue_id}=1    ${nwslice}=2    ${gw}=3    ${request_type}=initial-emergency-request    ${cause}=22
    ${cmd}    Catenate    ue_pdu_session_setup ue=${ue_id} pdu=2 nwslice=${nwslice} gw=${gw} request_type=${request_type}
    ${response}    set variable    ${cause_22}
    ${ret1}=    Execute Egate Command    ${cmd}
    ...     PDU Session Resource Setup with PDU Session ID [0-9]* was unsuccessful due to RAN ${response}    timeout=20s
    Should Not Contain    ${ret1}=    rrcReconfiguration
