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
...    NRBTS-1:actNormVCFallback=false
...    NRBTS-1:cipherPrefL:nea0=1
...    NRBTS-1:cipherPrefL:nea1_128=0
...    NRBTS-1:cipherPrefL:nea2_128=9
...    NRBTS-1:cipherPrefL:nea3_128=0
...    NRBTS-1:integrityProtPrefL:nia1_128=0
...    NRBTS-1:integrityProtPrefL:nia2_128=9
...    NRBTS-1:integrityProtPrefL:nia3_128=0
...    NRBTS-1/NRDU-1:numOfDrbsReservForEmergency=2
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
...    NRBTS-1/NRCELL-1:maxNumOfGBRBearersSA=2
...    NRBTS-1/NRCELL-1:maxNumOfNonGBRBearersSA=5
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
...    TRACKINGAREA-200:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1
...    TRACKINGAREA-200:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2
...    NRBTS-1/NRCELL-1:emergencyCallFails=false
...    NRBTS-1/NRCELL-1:maxNumOfRrcSA=10
...    NRBTS-1/NRCELL-1:numOfRadioResReservForEmergency=1
...    NRBTS-1/NRCELLGRP-0:maxNumOfRrcCGRPSA=100
...    NRBTS-1/NRCELLGRP-0:maxNumOfNonGBRBearersCGRPSA=30
...    NRBTS-1/NRCELL-1/NRREDRT-2:redirFreqEutra=1350
...    NRBTS-1/NRCELL-1/NRREDRT-2:redirPrio=2
...    NRBTS-1/NRDU-1:maxNumOfRrcConUEsPerDU=100
...    NRBTS-1:drbInactivityTimerSA=100
...    NRBTS-1:srbInactivityTimerSA=600
...    NRBTS-1:actGnbInitRlf=true
...    NRBTS-1/NRCELL-1:rlpDetDlHarqThreshold=5
...    NRBTS-1/NRCELL-1:rlpRecDlHarqThreshold=10000
...    NRBTS-1/NRDRB_RLC_AM-1:dlMaxRetxThreshold=t1

@{maxNumOfRrcSA_1}
...    NRCELL-1:maxNumOfGBRBearersSA=2
...    NRBTS-1/NRCELL-1:maxNumOfRrcSA=1

@{DELTA_PARAS_014}
...    NRBTS-1:srbInactivityTimerSA=600
...    NRBTS-1/NRCELL-1:maxNumOfRrcSA=10

@{flag_actEmergencyCall_false}
...    NRBTS-1/NRCELL-1:actEmergencyCall=false

@{srbInactivityTimerSA}
...    NRBTS-1:srbInactivityTimerSA=60

@{flag_actEmergencyCall_true}
...    NRBTS-1/NRCELL-1:actEmergencyCall=true

@{DELTA_PARAS_028}
...    NRCELL-1:numOfRadioResReservForEmergency=1
...    NRCELL-1:maxNumOfGBRBearersSA=0

@{administrativeState_Lock}
...    NRBTS-1/NRCELL-1:administrativeState=Locked

@{administrativeState_Unlock}
...    NRBTS-1/NRCELL-1:administrativeState=Unlocked

${SA_Capa_perUE}    SEPARATOR=
...    E1A01000074E5A031E000381A00F04983200021E0A018806804C020301C022A36146B04050D012CB2898183D6C10101070EF1C39061C00103278FAB80027800E0009E00
...    151B11B582028680965944C0C1EB608080838778E1C830E0008193C7D53FF4FFCA8D89BAC10143404B2CA26060F5B0404041C3BC70E418700040C9E3EAE0009E0038002
...    78000610713400000041C2800000010711800000802809B00A20230380780C04402301000FF5555504C00E000A070500703007803800341F00400000000000000010079
...    5358194010400002596540000010074AAA881D0500E001600010008010020010040086AC4C0004080C1014181C202C4044484C648494989CA12986B40

@{PM_Counters_Check}
...    NRCELL-1:NNGCC:${NNGCC_UE_CTXT_STP_REQ_EC_RECD}=2
...    NRCELL-1:NNGCC:${NNGCC_UE_CTXT_STP_RESP_EC_SENT}=2
...    NRCELL-1:NNGCC:${NNGCC_PDUSESMODREQ_EC_RECD}=2
...    NRCELL-1:NNGCC:${NNGCC_PDUSESMODRSP_SUC_EC_SENT}=2
...    NRCELL-1:NRRCC:${NRRCC_RRC_STPSUCC_EMERGENCY}=4
...    NRCELL-1:NNGCC:${NNGCC_PDU_SES_REL_CMD_EC_RECD}=2
...    NRCELL-1:NNGCC:${NNGCC_PDU_SES_REL_RESP_EC_SENT}=2

${NNGCC_UE_CTXT_STP_REQ_EC_RECD}    M55125C05501
${NNGCC_UE_CTXT_STP_RESP_EC_SENT}    M55125C05502
${NNGCC_PDUSESMODREQ_EC_RECD}    M55125C05509
${NNGCC_PDUSESMODRSP_SUC_EC_SENT}    M55125C05510
${NRRCC_RRC_STPSUCC_EMERGENCY}    M55124C04001
${NNGCC_PDU_SES_REL_CMD_EC_RECD}    M55125C05513
${NNGCC_PDU_SES_REL_RESP_EC_SENT}    M55125C05514

*** Test Cases ***
5GC000784-ET-A028_Verify_emergency_call_release_after_lock_unkock_cell_during_emergency_call_ongoing
    [Documentation]
    ...    1) This case is to verify the emergency call can be released normally with cell lock. Also can perform emergency call again
    ...    after unlock the cell.
    ...    2) Test Case Step:
    ...        a, UE1 setup one emergency call
    ...        c, on-line change administrativeState to Lock
    ...        d, on-line change administrativeState to unlock
    ...        f, UE2 setup one emergency call
    ...    3) Expected Result:
    ...        UE2 setup one emergency call successfully
    [Tags]    QC_61205
    OnlineParamChange    ${DELTA_PARAS_028}
    Set qosflow priority and smf param    additional_qosflows_to_activate=reset    priority=1
    Set UE RRC Establishment Cause to Emergency    ue_id=1
    Trigger UE MO VoNR call with PDU and add pdu session successfully    ue_id=1    pdu_id=1    gw=1    nwslice=2    RRCEstablishmentCause=0
    ...    request_type=initial-emergency-request    fiveQI=5    additional_qosflows_to_activate=reset    fiveQI_add=1    priorityLevelARP=1
    ...    req_typ=3
    Delta Commission Parameters    ${administrativeState_Lock}
    Delta Commission Parameters    ${administrativeState_Unlock}
    Sleep    30s    #wait 30s after CELL unlock
    Set UE RRC Establishment Cause to Emergency    ue_id=2
    Trigger UE MO VoNR call with PDU and add pdu session successfully    ue_id=2    pdu_id=1    gw=3    nwslice=2    RRCEstablishmentCause=0
    ...    request_type=initial-emergency-request    fiveQI=5    additional_qosflows_to_activate=reset    fiveQI_add=1    priorityLevelARP=1
    ...    req_typ=3
    Release Ues    ue_type=all

5GC000784-ET-A011_Verify_successfully_emergency_call_setup_when_UE_in_idle_state_after_normal_call_RRC_RAC_failure
    [Documentation]
    ...    1) This case is to verify the emergency call can be performed when UE in idle and normal call RRC RAC failure before.

    ...    2) Test Case Step:
    ...        a, UE3 setup one normal call
    ...        b, UE2 setup one normal call
    ...        c, UE1 setup one emergency call
    ...        d, release EC5QI1 of UE1 with PDU session modify request
    ...        e, AMF send PDU session resource modify to add EC5QI1
    ...    3) Expected Result:
    ...        a, UE3 normal call setup successfully
    ...        b, UE2 normal call setup failed (UE RRC access failure)
    ...        c, UE1 emergency call setup successfully
    ...        d, EC5QI1 can be removed succesfully
    ...        e, EC5QI1 can be added succesfully
    [Tags]    QC_61202
    OnlineParamChange    ${maxNumOfRrcSA_1}
    Set UE RRC Establishment Cause for rrc setup param    ue_id=3    establishment_cause=mo-Signalling
    Set qosflow priority and smf param    additional_qosflows_to_activate=reset     priority=15
    Trigger UE MO VoNR call with PDU and add pdu
    Set UE RRC Establishment Cause for rrc setup param
    Set qosflow priority and smf param    additional_qosflows_to_activate=reset
    Trigger UE 5QI1 delete and add
    Release Ues    ue_type=all
    Check Wireshark Log    ${CURDIR}${/}a2a_A011${/}a2a_wireshark.ini    wait_string=UEContextReleaseComplete::1

5GC000784-ET-A014_Verify_ongoing_emergency_call_should_not_be_impact_after_online_change_feature_flag_to_deactivate
    [Documentation]
    ...    1) This user scenario describes the gNB behavior for the successful initiation of the Emergency voice call for a UE in idle state.
    ...    The Selected cell allows Normal Service access (Not Limited Service Mode).
    ...    This case is to verify emergency call can be handled correctly with feature flag changed, when feature flag changed from on to off,
    ...    the ongoing emergency call should not be impacted, when feature flag changed from off to on
    ...    new emergency call should be setup successfully.
    ...    2) Test Case Step:
    ...        a, UE1 setup one emergency call (ICS with EC5QI5, PDU MODIFY with EC5QI1)
    ...        b, UE2 setup one emergency call (ICS with EC5QI5, PDU MODIFY with EC5QI1)
    ...        c, on-line change NRBTS/NRCELL.actEmergencyCall to disabled
    ...        d, UE1 release emergency PDU session
    ...        e, attach UE1 and setup emergency pdu session
    ...        f, on-line change NRBTS/NRCELL.actEmergencyCall to enabled
    ...        g, UE2 release emergency PDU session
    ...    3) Expected Result:
    ...        after step c, the ongoing emergency call is not impacted(UE1 emergency pdu session can be released successfully)
    ...        UE2 emergency pdu session can be released successfully
    ...        counter should be OK
    [Tags]    QC_61201
    OnlineParamChange    ${DELTA_PARAS_014}
    Clear Counter files
    Trigger UE MO VoNR call with PDU UE1 UE2
    OnlineParamChange    ${flag_actEmergencyCall_false}
    Trigger UE PDU session release    ue_id=1    pdu_id=1
    OnlineParamChange    ${srbInactivityTimerSA}
    Trigger UE MO VoNR call with PDU UE3
    Trigger UE PDU release
    Check counters    ${PM_Counters_Check}
    Release Ues    ue_type=all

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fdd_sansa_cmwv/2cells

Modify Cfg
    Update Cfg    amf_param id=1 full_nas_auth=on nia=null+aes nea=null+aes voice_fallback=off ims_voice_3gpp=on
    Update Cfg    set_amf_region id=2 tac_list=0,100,258,788 plmn=311:489
    Update Cfg    set_amf_region id=3 tac_list=0,100,258,788 plmn=311:489
    Update Cfg    set_amf id=2 daemon=10.0.2.1:22222 ng=10.0.1.9:38412 region=2 set_id=2 pointer=2
    Update Cfg    set_amf id=3 daemon=10.0.2.1:22222 ng=10.0.1.10:38412 region=3 set_id=2 pointer=2
    Update Cfg    amf_param id=2 full_nas_auth=on nia=null+zuc nea=null+zuc
    Update Cfg    amf_param id=3 full_nas_auth=on nia=null+zuc nea=null+zuc
    ${Ue_Simu1}    catenate    set_ue simulated id=1 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...    nia=null+aes nea=null+aes sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0000:0:0:021645400 mode=nr enb=2 cell=1
    Update Cfg    ${Ue_Simu1}
    ${Ue_Simu2}    catenate    set_ue simulated id=2 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...    nia=null+aes nea=null+aes sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0000:0:0:021645401 mode=nr enb=2 cell=1
    Update Cfg    ${Ue_Simu2}
    ${Ue_Simu3}    catenate    set_ue simulated id=3 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...    nia=null+aes nea=null+aes sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0000:0:0:021645402 mode=nr enb=2 cell=1
    Update Cfg    ${Ue_Simu3}
    Update Cfg    ue_param id=1 ue_nr_capabilities=${SA_Capa_perUE} nr_usage_setting=voice_centric
    Update Cfg    ue_param id=2 ue_nr_capabilities=${SA_Capa_perUE} nr_usage_setting=voice_centric
    Update Cfg    ue_param id=3 ue_nr_capabilities=${SA_Capa_perUE} nr_usage_setting=voice_centric
    Update Cfg    ue_param id=4 ue_nr_capabilities=${SA_Capa_perUE}
    Update Cfg    set_qosflow id=1 5qi=5 default=off
    Update Cfg    set_qosflow id=2 5qi=1
    Update Cfg    set_qosflow id=3 5qi=9 default=on
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

UE register failed
    [Arguments]    ${ue_id}=1
    ${ret1}=    Execute Egate Command    ue_register id=${ue_id} registration_type=EmergencyRegistration    RRC Reject was received
    Should Contain    ${ret1}=    rrcReject
    sleep    5s     # to wait messages captured

Set PDU Param for UE
    [Arguments]    ${ue_id}=1    ${pdu_id}=1
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal

Precondition for Set PDU Param for UE1 to UE3
    Set PDU Param for UE    ue_id=1-2    pdu_id=2
    Set PDU Param for UE    ue_id=3    pdu_id=1

Trigger UE DL traffic to trigger ICS and check pdu setup
    [Arguments]    ${ue_id}=1
    ...    ${additional_qosflows_to_activate}=reset
    ${ret1}=    Execute Egate Command    ue_im_exit id=${ue_id} by=ue service_type=emergency_services
    ...    Initial Context Setup Successful for UE with AMF UE ID
    sleep    5s     # to wait messages captured

Set UE RRC Establishment Cause for rrc setup param
    [Arguments]    ${ue_id}=1    ${establishment_cause}=emergency
    Execute Egate Command    ue_nr_rrc_setup_param id=${ue_id} establishment_cause=${establishment_cause}

Set qosflow priority and smf param
    [Arguments]    ${additional_qosflows_to_activate}=2    ${priority}=1
    Execute Egate Command    qosflow_modify qos_flow=1 priority=${priority}
    Execute Egate Command    qosflow_modify qos_flow=2 priority=${priority}
    Execute Egate Command    qosflow_modify qos_flow=3 priority=${priority}
    Execute Egate Command    qosflow_modify qos_flow=4 priority=${priority}
    Execute Egate Command    smf_param id=1 reset

Trigger UE MO VoNR call with PDU and add pdu session successfully
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${nwslice}=1    ${gw}=1    ${request_type}=initial-request    ${fiveQI}=9    ${priorityLevelARP}=15
    ...    ${RRCEstablishmentCause}=3    ${req_typ}=1    ${additional_qosflows_to_activate}=reset    ${cipheringAlgorithm}=nea2    ${fiveQI_add}=2
    Trigger UE MO VoNR call with PDU    ${ue_id}    ${pdu_id}    ${nwslice}    ${gw}    ${request_type}    ${fiveQI}
    ...    ${additional_qosflows_to_activate}    ${cipheringAlgorithm}
    Trigger UE 5QI add successfully with PDU session modify    ue_id=${ue_id}    pdu_id=${pdu_id}    fiveQI=${fiveQI_add}

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

Trigger UE 5QI add successfully with PDU session modify
    [Arguments]    ${ue_id}=1    ${pdu_id}=2    ${fiveQI}=1    ${qosflows_to_add}=2
    ${ret1}=    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_add=${qosflows_to_add} by=amf
   ...    Pdu Session Resource Modify Response Message with RAN UE NGAP ID [0-9]* handled successfully    timeout=20s
    Should Contain    ${ret1}=    rrcReconfiguration
    Should Contain    ${ret1}=    Added QosFlow with QFI:${qosflows_to_add} 5QI:${fiveQI}

Trigger UE 5QI1 delete successfully with PDU
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${qosflows_to_del}=2
    ${ret1}=    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_del=${qosflows_to_del} by=amf
    ...    Pdu Session Resource Modify Response Message with RAN UE NGAP ID [0-9]* handled successfully    timeout=20s
    Should Contain    ${ret1}=    Deleting QosFlow with QFI:2 5QI:1
    Should Contain    ${ret1}=    rrcReconfiguration
    Should Contain    ${ret1}=    Removed FiveQi:Qfi mapping fiveQi 1 qfi 2

Trigger UE 5QI add successfully with PDU session modify and check the logs
    [Arguments]    ${ue_id}=1    ${pdu_id}=2    ${fiveQI}=1    ${priorityLevelARP}=1
    Trigger UE 5QI add successfully with PDU session modify    ue_id=${ue_id}    pdu_id=${pdu_id}    fiveQI=${fiveQI}

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir

Set UE RRC Establishment Cause to Emergency
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_nr_rrc_setup_param id=${ue_id} establishment_cause=emergency

Trigger UE PDU session release
    [Arguments]    ${ue_id}=1    ${pdu_id}=1
    Execute Egate Command    ue_pdu_session_release ue=${ue_id} pdu=${pdu_id} by=ue    Successfully released PDU Session
    ...    timeout=20s

Trigger UE MO VoNR call with PDU and add Check priority level arp and request type in Wireshark
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${nwslice}=1    ${gw}=1    ${request_type}=initial-request    ${fiveQI}=9    ${priorityLevelARP}=15
    ...    ${RRCEstablishmentCause}=3    ${req_typ}=1    ${additional_qosflows_to_activate}=reset    ${cipheringAlgorithm}=nea2
    Trigger UE MO VoNR call with PDU    ${ue_id}    ${pdu_id}    ${nwslice}    ${gw}    ${request_type}    ${fiveQI}
    ...    ${additional_qosflows_to_activate}    ${cipheringAlgorithm}

Wait Until UE Status To Be Idle
    [Arguments]    ${ue_id}=1
    Sleep    16s    #wait to verify UE not drop after pdu session setup
    ${checkUeStatus}=    Execute Egate Command    ue_disp id=${ue_id}    state    timeout=20s
    should contain    ${checkUeStatus}=    ACTIVE
    Wait until keyword succeeds    5 min    5 sec    Check Ue Status Is Idle    ue_id=${ue_id}

Check Ue Status Is Idle
    [Arguments]    ${ue_id}=1
    ${checkUeStatus}=    Execute Egate Command    ue_disp id=${ue_id}    state    timeout=20s
    should contain    ${checkUeStatus}=    IDLE

Trigger UE MO VoNR call with PDU and add pdu
    Trigger UE MO VoNR call with PDU and add pdu session successfully    ue_id=3    pdu_id=1    gw=5    nwslice=2    RRCEstablishmentCause=3
    ...    request_type=initial-request    fiveQI=5    additional_qosflows_to_activate=reset    fiveQI_add=1    priorityLevelARP=15    req_typ=1
    Set UE RRC Establishment Cause for rrc setup param    ue_id=2    establishment_cause=mo-Signalling
    UE register failed    ue_id=2

Trigger UE 5QI1 delete and add
    Trigger UE MO VoNR call with PDU and add pdu session successfully    ue_id=1    pdu_id=1    gw=1    nwslice=2    RRCEstablishmentCause=0
    ...    request_type=initial-emergency-request    fiveQI=5    additional_qosflows_to_activate=reset    fiveQI_add=1    priorityLevelARP=1
    ...    req_typ=3
    Trigger UE 5QI1 delete successfully with PDU    ue_id=1    pdu_id=1
    Trigger UE 5QI add successfully with PDU session modify and check the logs    ue_id=1    pdu_id=1    fiveQI=1    priorityLevelARP=1

Trigger UE MO VoNR call with PDU UE1 UE2
    Precondition for Set PDU Param for UE1 to UE3
    Set qosflow priority and smf param    additional_qosflows_to_activate=reset     priority=1
    Set UE RRC Establishment Cause to Emergency    ue_id=1
    Trigger UE MO VoNR call with PDU and add pdu session successfully    ue_id=1    pdu_id=1    gw=1    nwslice=2    RRCEstablishmentCause=0
    ...    request_type=initial-emergency-request    fiveQI=5    additional_qosflows_to_activate=reset    fiveQI_add=1    priorityLevelARP=1
    ...    req_typ=3
    Set UE RRC Establishment Cause to Emergency    ue_id=2
    Trigger UE MO VoNR call with PDU and add pdu session successfully    ue_id=2    pdu_id=1    gw=3    nwslice=2    RRCEstablishmentCause=0
    ...    request_type=initial-emergency-request    fiveQI=5    additional_qosflows_to_activate=reset    fiveQI_add=1    priorityLevelARP=1
    ...    req_typ=3

Trigger UE MO VoNR call with PDU UE3
    Set UE RRC Establishment Cause to Emergency    ue_id=3
    Set qosflow priority and smf param    additional_qosflows_to_activate=reset
    Trigger UE MO VoNR call with PDU and add Check priority level arp and request type in Wireshark    ue_id=3    pdu_id=1    gw=5    nwslice=2
    ...    request_type=initial-emergency-request    fiveQI=5    priorityLevelARP=1    RRCEstablishmentCause=0    req_typ=3
    Wait until UE status to be idle    ue_id=3
    Trigger UE DL traffic to trigger ICS and check pdu setup    ue_id=3
    Trigger UE 5QI add successfully with PDU session modify and check the logs    ue_id=3    pdu_id=1    fiveQI=1    priorityLevelARP=1

Trigger UE PDU release
    OnlineParamChange    ${flag_actEmergencyCall_true}
    Trigger UE PDU session release    ue_id=2    pdu_id=1
