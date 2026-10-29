*** Settings ***
Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    CRT    CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD    team-SG2
...               owner-dan.liu    release-5G21A
Resource          ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{NRREL}
...    @{SNSSAI}
...    @{NRDRB}
...    @{fixed_relation_error}
...    NRCELL:actVoNR=true
...    NRCELL:actEmergencyCall=true

...    NRCELL:actEnhancedVoNR=true
...    NRCELL:actGBRAdmissionControl=EnhancedVoNR
...    NRBTS:actIntraFreqHoSA=true
...    NRBTS:actInterRatHoSA=true
...    NRCELL:emergencyCallLimServ=true
...    NRCELL:maxGBRTrafficLimit=30
...    NRCELL:n310VoNR=n3
...    NRCELL:t310VoNR=500ms
...    NRCELL:gscnOrSsPbchArfcn=1587
...    NRCELL/NRCELL_FDD-1:nrarfcnDl=126900
...    NRCELL/NRCELL_FDD-1:nrarfcnUl=136100
...    NRBTS:tRLFindForDUVoNR=500ms
...    NRCELL:arpPrioEmergencyCall=1
...    NRBTS:rrcReestabTypeSA=viaRRCSetup
...    NRCELL:emergencyCallRestrictions:emergencyCallMrListIgnore=true
...    NRCELL:emergencyCallRestrictions:emergencyCallPlmnHoAllowed=false
...    NRBTS:cipherPrefL:nea0=1
...    NRBTS:cipherPrefL:nea1_128=0
...    NRBTS:cipherPrefL:nea2_128=9
...    NRBTS:cipherPrefL:nea3_128=0
...    NRBTS:integrityProtPrefL:nia1_128=0
...    NRBTS:integrityProtPrefL:nia2_128=9
...    NRBTS:integrityProtPrefL:nia3_128=0
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-1:threshXHighQ=0
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-1:threshXLowQ=0
...    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrRelReportCu=5min
...    MRBTS-1/NRBTS-1/NRCELL-1:a3MeasEnabled=rsrp
...    NRCELL:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRCELL:a3MeasSsbRsrp:a3OffsetSsbRsrp=15
...    NRCELL:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms40
...    NRCELL:absThreshSsbRsrpConsolidation=1
...    NRCELL:sMeasConfigSsbRsrp=0
@{SNSSAI}
...    MRBTS-1/NRBTS-1/SNSSAI-1:ngUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    MRBTS-1/NRBTS-1/SNSSAI-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    MRBTS-1/NRBTS-1/SNSSAI-2:administrativeState=Unlocked
...    MRBTS-1/NRBTS-1/SNSSAI-2:sd=13714342
...    MRBTS-1/NRBTS-1/SNSSAI-2:sst=1
...    MRBTS-1/NRBTS-1/SNSSAI-2:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    delete:MRBTS-1/NRBTS-1/SNSSAI-2:ngUplane
...    TRACKINGAREA-200:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1
...    TRACKINGAREA-200:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2
...    MRBTS-1/NRBTS-1/TRACKINGAREA-200:fiveGsTac=788
@{NRDRB}
...    NRBTS-1/NRDRB_5QI-6:fiveqiValueList=1
...    NRBTS-1/NRDRB_5QI-6:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-15
...    MRBTS-1/NRBTS-1/NRDRB-15:dlFlowControlAlgo=none
...    MRBTS-1/NRBTS-1/NRDRB-15:dscp=0
...    MRBTS-1/NRBTS-1/NRDRB-15:nrDrbId=15
...    MRBTS-1/NRBTS-1/NRDRB-15:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-3
...    MRBTS-1/NRBTS-1/NRDRB-15:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-2
...    MRBTS-1/NRBTS-1/NRDRB-15:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    MRBTS-1/NRBTS-1/NRDRB-15:numSduDiscard=1
...    MRBTS-1/NRBTS-1/NRDRB-15:queuingDelayDiscarding=Disabled
...    MRBTS-1/NRBTS-1/NRDRB-15:queuingDelaySduDiscardThreshold=750
...    MRBTS-1/NRBTS-1/NRDRB-15:resType=GBR
...    MRBTS-1/NRBTS-1/NRDRB-15:rlcMode=RLC_UM
...    MRBTS-1/NRBTS-1/NRDRB-15:sduDiscardIntervalTmr=100
...    MRBTS-1/NRBTS-1/NRDRB-15:schedulWeight=1
...    MRBTS-1/NRBTS-1/NRDRB-15:discardTimer=150ms
...    MRBTS-1/NRBTS-1/NRDRB-15:actDddsReduction=false
...    MRBTS-1/NRBTS-1/NRDRB_MAC-3:lcgid=4
...    MRBTS-1/NRBTS-1/NRDRB_MAC-3:schedulPrio=5
...    MRBTS-1/NRBTS-1/NRDRB_MAC-3:nrDrbMacId=3
...    MRBTS-1/NRBTS-1/NRDRB_MAC-3:schedulBSD=100ms
...    MRBTS-1/NRBTS-1/NRDRB_MAC-4:lcgid=1
...    MRBTS-1/NRBTS-1/NRDRB_MAC-4:schedulPrio=4
...    MRBTS-1/NRBTS-1/NRDRB_MAC-4:nrDrbMacId=4
...    MRBTS-1/NRBTS-1/NRDRB-10:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-4
...    MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1:dlTReassemblyUm=ms40
...    MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1:nrDrbRlcUmId=1
...    MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1:ulTReassemblyUm=ms40
@{NRREL}
...    NRBTS:actIncXn=true
...    NRBTS:actConflictConfiguration=true
...    NRADJGNB-1:administrativeState=Unlocked
...    NRADJGNB-1:gNodeBId=35
...    NRADJGNB-1:gNbIdLength=22
...    NRADJGNB-1:xnLinkRef=1
...    NRADJGNB-1:gnbPlmn:mncLength=3
...    NRADJGNB-1:gnbPlmn:mcc=311
...    NRADJGNB-1:gnbPlmn:mnc=489
...    XNLINK-1:cPlaneIpAddr=10.0.1.124
...    NRADJGNB-2:administrativeState=Unlocked
...    NRADJGNB-2:gNodeBId=36
...    NRADJGNB-2:gNbIdLength=22
...    NRADJGNB-2:xnLinkRef=2
...    NRADJGNB-2:gnbPlmn:mncLength=3
...    NRADJGNB-2:gnbPlmn:mcc=311
...    NRADJGNB-2:gnbPlmn:mnc=489
...    XNLINK-2:cPlaneIpAddr=10.0.1.122
...    NRADJNRCELL-1:cellDepType=SA
...    NRADJNRCELL-1:fiveGsTac=100
...    NRADJNRCELL-1:gNbId=35
...    NRADJNRCELL-1:gNbIdLength=22
...    NRADJNRCELL-1:lcrId=1
...    NRADJNRCELL-1:nrarfcn=126900
...    NRADJNRCELL-1:physCellId=381
...    NRADJNRCELL-1:gnbPlmn:mcc=311|mncLength=3
...    NRADJNRCELL-1:gnbPlmn:mnc=489|mncLength=3
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-1:gNbId=35
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-1:lcrId=1
...    NRCELL-1/NRREL-1:removeNotAllowed=false
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311|mncLength=3
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489|mncLength=3
...    NRADJNRCELL-2:cellDepType=SA
...    NRADJNRCELL-2:fiveGsTac=100
...    NRADJNRCELL-2:gNbId=36
...    NRADJNRCELL-2:gNbIdLength=22
...    NRADJNRCELL-2:lcrId=3
...    NRADJNRCELL-2:nrarfcn=126900
...    NRADJNRCELL-2:physCellId=48
...    NRADJNRCELL-2:gnbPlmn:mcc=311|mncLength=3
...    NRADJNRCELL-2:gnbPlmn:mnc=489|mncLength=3
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-2:gNbId=36
...    NRCELL-1/NRREL-2:gNbIdLength=22
...    NRCELL-1/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-2:lcrId=3
...    NRCELL-1/NRREL-2:removeNotAllowed=false
...    NRCELL-1/NRREL-2:gnbPlmn:mcc=311|mncLength=3
...    NRCELL-1/NRREL-2:gnbPlmn:mnc=489|mncLength=3
@{fixed_relation_error}
...    NRBTS:timerXnDataFwdGuard=250
...    NRBTS-1/NRDRB-15:maxDataRateGbrDl=100
...    NRBTS-1/NRDRB-15:maxDataRateGbrUl=100
...    NRBTS-1/NRDRB_PDCP-2:pdcpBufDiscardEnabled=false
@{Online_param_B006}
...    NRCELL:actEmergencyCall=true
...    NRCELL:emergencyCallRestrictions:emergencyCallMrListIgnore=true
...    NRCELL:emergencyCallRestrictions:emergencyCallPlmnHoAllowed=false
@{Online_param_B013}
...    NRCELL:actEmergencyCall=true
...    NRCELL:emergencyCallRestrictions:emergencyCallMrListIgnore=true
...    NRCELL:emergencyCallRestrictions:emergencyCallPlmnHoAllowed=true
@{DisableEC}
...    NRCELL:actEmergencyCall=false
@{Online_param_B016}
...    NRCELL:actEmergencyCall=true
...    NRCELL:emergencyCallRestrictions:emergencyCallMrListIgnore=true
...    NRCELL:emergencyCallRestrictions:emergencyCallPlmnHoAllowed=false
@{Delete_DRB_5QI1}
...    delete:NRDRB_5QI-6
@{Recovery_DRB_5QI1}
...    NRBTS-1/NRDRB_5QI-6:fiveqiValueList=1
...    NRBTS-1/NRDRB_5QI-6:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-15
@{counters_inter_GNB_HO}
...    NRCELL-1:${ATT_HO_EMERGENCY}=1
...    NRCELL-1:${SUCC_HO_EMERGENCY}=1
...    NRCELL-1:${HO_PREP_EMERGENCY_SENT}=1
${ATT_HO_EMERGENCY}             M55147C00501
${SUCC_HO_EMERGENCY}                 M55147C00503
${HO_PREP_EMERGENCY_SENT}                 M55147C00504
${UE_nr_sa_capability}    SEPARATOR=
...    E1A01000074E5A031E000381A00F04983200021E0A018806804C020301C022A36146B04050D012CB2898183D6C10101070EF1C39061C001032
...    78FAB80027800E0009E00151B11B582028680965944C0C1EB608080838778E1C830E0008193C7D53FF4FFCA8D89BAC10143404B2CA26060F5B
...    0404041C3BC70E418700040C9E3EAE0009E003800278000610713400000041C2800000010711800000802809B00A20230380780C0440230100
...    0FF5555504C00E000A070500703007803800341F004000000000000000100795358194010400002596540000010074AAA881D0500E00160001
...    0008010020010040086AC4C0004080C1014181C202C4044484C648494989CA12986B40

*** Test Cases ***
5GC000784-ET-B006_Verify_successful_Intra_freq_inter_gnb_intra-PLMN_HO_with_EC_call_ongoing_with_inter_plmn_flag_set_as_of_false
    [Documentation]
    ...    1. This purpose of this test case is to
    ...         verify intra-Freq inter-GNB intra-PLMN handover with emergency call would be successful.
    ...         and related counters should be increased accordingly.
    ...         Source Cell: NRBTS/NRCELL.emergencyCallMrListIgnore=true, NRBTS/NRCELL.emergencyCallPlmnHoAllowed=false
    ...    2. Test Case Steps:
    ...         a. Set Up Xn_link between source gnb and target gnb
    ...         b. configure MRL with target PLMN matching the not_allowed_tacs
    ...         c. UE setup a normal call with 5QI-9
    ...         d. UE setup an emeregency call with 5QI-5 and 5QI-1
    ...         e. ignore target gnb NSSAI
    ...         f. UE trigger handover to the target cell
    ...         g. UE relese the normal call
    ...    3. Expected Results:
    ...         UE-3 Handover successfully
    [Tags]    B006    QC_61244
    Setup Xn and online parameters    ${Online_param_B006}    ue_id=1
    Config AMF1 MRL For UE    sa_plmn=311:489    ue_id=1
    Trigger UE MO VoNR Voice Call With One Normal and One Eemergency PDU Session    ue_id=1    pdu_id1=1    pdu_id2=2    gw_1st=1    gw_2nd=2
    Trigger UE Intra-Frequency Inter-gNB HO    ue_id=1    phycell_id=381
    Release PDU Session One By One    ue_id=1
    release ues    ue_type=all
    check wireshark log    ${CURDIR}${/}A2A_B_006${/}a2a.ini
    [Teardown]     Testcase Tear Down for 5GC000784-B

5GC000784-ET-B013_Verify_normal_RAC_should_performed_as_feature_flag_actEmergencyCall_is_off_on_target
    [Documentation]    1. The purpose of this test case is to verify inter-GNB intra-Freq intra-PLMN HO with EC ongoing with MRL
    ...                   flag off and inter PLMN flag on
    ...    Source Cell: NRBTS/NRCELL.emergencyCallMrListIgnore = true, NRBTS/NRCELL.emergencyCallPlmnHoAllowed = true
    ...    2. Test Case Step:
    ...    a, UE-1 set MRL to restrict target cell (Not allowed TAC).
    ...    b, UE-1 initial emergency call in in source cell (Normal 5QI9, EC 5QI5&1)
    ...    c, UE-1 perform inter gnb intra-plmn HO to target cell.
    ...    d, online modify source cell NRBTS/NRCELL.actEmergencyCall to false
    ...    e, UE-1 perform inter gnb intra-plmn HO back to source cell.
    ...    3. Expected Result:
    ...    c&e, Handover failed due to target cell not allowed.
    [Tags]    B013    QC_61238
    Setup Xn and online parameters    ${Online_param_B013}    ue_id=2
    Config AMF1 MRL For UE    ue_id=2    equiv_plmn=311:402    sa_plmn=311:489    not_allowed_tacs=788
    Trigger UE MO VoNR Voice Call With One Normal and One Eemergency PDU Session    ue_id=2    pdu_id1=1    pdu_id2=2    gw_1st=3    gw_2nd=4
    Trigger UE Intra-Frequency Inter-gNB HO    ue_id=2    phycell_id=381
    OnlineParamChange    ${DisableEC}
    Trigger UE Intra-Frequency Inter-gNB Handover cancel    ue_id=2    phycell_id=60
    check UE location    ue_id=2    enb=3    cell=1
    Sleep    5    waiting for HandoverPreparationFailure
    release ues    ue_type=all
    check counters    ${counters_inter_GNB_HO}
    check wireshark log    ${CURDIR}${/}A2A_B_013${/}a2a.ini
    [Teardown]     Testcase Tear Down for 5GC000784-B

5GC000784-ET-B016_Verify_unsuccesful_intra_freq_inter_gnb_Ho_due_to_no_valid_drb_profile_configured_on_target
    [Documentation]    intra freq inter gnb intra PLMN,source: gnbsim target: real gnb
    ...    2. Test Case Steps:
    ...    a. configure MRL with target PLMN matching the not_allowed_tacs
    ...    b. UE-1 setup a normal call and emergencyl call
    ...    c. set Sim Gnb ignore target gnb NSSAI
    ...    d. UE-1 trigger inter-Freq handover to the target cell should successful
    ...    e.delete DRB 5QI1
    ...    f. UE-1 trigger inter-Freq handover to the target cell
    ...    3. Expected Results:
    ...    UE-1 cell should still stay in cell in for HO unsuccessful
    [Tags]    B016    QC_61235
    Setup Xn and online parameters    ${Online_param_B016}    ue_id=3
    Config AMF1 MRL For UE    ue_id=3    equiv_plmn=311:402    sa_plmn=311:489    not_allowed_tacs=788
    Trigger UE MO VoNR Voice Call With One Normal and One Eemergency PDU Session    ue_id=3    pdu_id1=1    pdu_id2=2    gw_1st=5    gw_2nd=6
    Trigger UE Intra-Frequency Inter-gNB HO    ue_id=3    phycell_id=381
    OnlineParamChange    ${Delete_DRB_5QI1}
    Trigger UE Intra-Frequency Inter-gNB Handover cancel    ue_id=3    phycell_id=60
    check UE location    ue_id=3    enb=3    cell=1
    Sleep    5    waiting for HandoverPreparationFailure
    release ues    ue_type=all
    check wireshark log    ${CURDIR}${/}A2A_B_016${/}a2a.ini    wait_string=HandoverPreparationFailure
    [Teardown]     Testcase Tear Down for 5GC000784-B    ${Recovery_DRB_5QI1}

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fdd_sansa_cmwv/2cells
    Comment    Debug Enter Into Egate

Modify Cfg
    Update Cfg    set_qosflow id=1 5qi=5 default=off
    Update Cfg    set_qosflow id=2 5qi=1
    Update Cfg    set_qosflow id=3 5qi=9 default=on
    Update Cfg    set_qosflow id=4 5qi=7
    Update Cfg    set_qosrule id=1 proto=tcp qos_flow=1
    Update Cfg    set_qosrule id=2 proto=udp qos_flow=2
    Update Cfg    set_nwslice id=1 snssai=0x01:0xD143A5 default=on ue=1-6 amf=1 qos_flows=3,2,1 qos_rules=1,2
    Update Cfg    set_nwslice id=2 snssai=0x01:0xD143A6 ue=1-6 amf=1 qos_flows=1,2 qos_rules=1,2
    Update Cfg    set_nwslice id=3 snssai=0x01:0xD143A7 ue=1-6 amf=1
    Update Cfg    set_nwslice id=4 snssai=0x01:0xD143A8 ue=1-6 amf=1
    Update Cfg    set_amf_region id=1 tac_list=0,100,258,788 plmn=311:489
    Update Cfg    ue_nr_capabilities id=1-6 voice_over_nr=on:on:off
    Update Cfg    ue_param id=1-10 nr_usage_setting=voice_centric ue_nr_capabilities=${UE_nr_sa_capability}
    Update Cfg    amf_param id=1 full_nas_auth=on nia=null+aes nea=null+aes voice_fallback=off ims_voice_3gpp=on
    Update Cfg    set_upf id=1 daemon=10.0.2.1:22222 type=simulated addr=10.12.2.1/24 ngu=10.0.1.1
    Update Cfg    set_amf id=1 daemon=10.0.2.1:22222 ng=10.0.1.1:38412 region=1 set_id=2 pointer=2
    Update Cfg    set_pdu_gateway id=3 ue_nat_ip=72.23.0.3 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=4 ue_nat_ip=72.23.0.4 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=5 ue_nat_ip=72.23.0.5 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=6 ue_nat_ip=72.23.0.6 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=7 ue_nat_ip=72.23.0.7 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=8 ue_nat_ip=72.23.0.8 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    FOR    ${ue_id}    IN RANGE    1    10
       ${ue_V}    catenate
    ...    set_ue simulated id=${ue_id} uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...    nia=null+aes nea=null+aes sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0000:0:0:02164540${ue_id} mode=nr enb=2 cell=1
       Update Cfg    ${ue_V}
    END
    FOR    ${ue_id}    IN RANGE    10    31
       ${ue_V}    catenate
    ...    set_ue simulated id=${ue_id} uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...    nia=null+aes nea=null+aes sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0000:0:0:0216454${ue_id} mode=nr enb=2 cell=1
       Update Cfg    ${ue_V}
    END
    ${SIM-GNB3}    catenate    set_gnb id=3 type=simulated plmn=311:489 ng=10.0.1.125 gnb_id=0x23:22 daemon=10.0.2.1:22222 x2_peers=none
    ...    xn=10.0.1.124    nssai=0x1:0xd143a5,0x1:0xd143a6 amf=1
    Update Cfg    ${SIM-GNB3}
    Update Cfg    gnb_param id=3 xn_listening_socket=1 send_xn_setup=false sib1_period=40
    Update Cfg    set_cell id=1 gnb=3 pci=127:0 tac=100 nrci=0x01 tdd_cell=off proxy=10.0.2.90:9999 nr_arfcn=136100:126900 gscn=1587
    ${SIM-GNB5}    catenate    set_gnb id=5 type=simulated plmn=311:489 ng=10.0.1.123 gnb_id=0x24:22 daemon=10.0.2.1:22222 x2_peers=none
    ...    xn=10.0.1.122    nssai=0x1:0xd143a5,0x1:0xd143a6 amf=1
    Update Cfg    ${SIM-GNB5}
    Update Cfg    set_cell id=1 gnb=5 pci=16:0 tac=100 nrci=0x03 tdd_cell=off proxy=10.0.2.92:9999 nr_arfcn=136100:126900 gscn=1587
    Update Cfg    gnb_param id=5 xn_listening_socket=1 send_xn_setup=false
    ${GNB2}    catenate    set_gnb id=2 type=external plmn=311:489 s1u=10.0.1.2 x2=10.0.1.2:36422 ng=10.0.1.2 gnb_id=0x1:22 daemon=10.0.2.1:22222
    ...    xn=10.0.1.2 x2_peers=none amf=1
    Update Cfg    ${GNB2}
    ${GNB2_cell1}    catenate    set_cell id=1 gnb=2 pci=20:0 tac=788 nrci=0x01 eci=0x000021f tdd_cell=off proxy=10.0.2.80:9999|10.0.2.80:8888
    ...    nr_arfcn=136100:126900 gscn=1587
    ${GNB2_cell2}    catenate    set_cell id=2 gnb=2 pci=20:1 tac=788 nrci=0x02 eci=0x000021f tdd_cell=off proxy=10.0.2.80:9999|10.0.2.80:8888
    ...    nr_arfcn=136100:126900 gscn=1587
    Update Cfg    ${GNB2_cell1}
    Update Cfg    ${GNB2_cell2}

Setup Xn and online parameters
   [Arguments]    ${Online_Param}    ${ue_id}
   Xn link SETUP and Recovery
   OnlineParamChange    ${Online_Param}
   clear counter files
   before UE register    ${ue_id}

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be Onair    check_sib=${False}

Xn link SETUP and Recovery
    Execute Egate Command    gnb_param id=5 xn_listening_socket=1 send_xn_setup=true
    Execute Egate Command    gnb_xn_ngran_conf_update_param id=5 reset
    Execute Egate Command    gnb_xn_setup_param id=5 reset
    Execute Egate Command    gnb_xn_link_up gnb=5 target=2    GNB-5: XnAP Link with GNB-2 .* is up
    Execute Egate Command    gnb_param id=3 xn_listening_socket=1 send_xn_setup=true
    Execute Egate Command    gnb_xn_ngran_conf_update_param id=3 reset
    Execute Egate Command    gnb_xn_setup_param id=3 reset
    Execute Egate Command    gnb_xn_link_up gnb=3 target=2    GNB-3: XnAP Link with GNB-2 .* is up

before UE register
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_history_information_list_add_ngran id=${ue_id} cell_type=large nrcgi=311:489|0x01 gnb_id=2 time_ue_stayed_in_cell=97
    Execute Egate Command    ue_history_information_list_add_ngran id=${ue_id} cell_type=large nrcgi=311:489|0x01 gnb_id=3 time_ue_stayed_in_cell=98
    Execute Egate Command    ue_history_information_list_add_ngran id=${ue_id} cell_type=large nrcgi=311:489|0x01 gnb_id=2 time_ue_stayed_in_cell=99
    Execute Egate Command    ue_history_information_list id=${ue_id} action=commit
    Execute Egate Command    ue_enb_param id=${ue_id} ue_history_list=${ue_id}

Config AMF1 MRL For UE
    [Arguments]    ${ue_id}=1    ${equiv_plmn}=311:409     ${sa_plmn}=311:489    ${not_allowed_tacs}=100
    ...    ${fa_plmn}=311:409     ${forbidden_tacs}=311
    ${cmd1}    Catenate    amf_mobility_restriction_list_param id\=1 equiv_plmn\=${equiv_plmn}
    ...    sa_plmn\=${sa_plmn} not_allowed_tacs\=${not_allowed_tacs} fa_plmn=${fa_plmn} forbidden_tacs=${forbidden_tacs}
    Execute Egate Command     ${cmd1}
    Execute Egate Command     amf_mobility_restriction_list_param id=1    pass_regexp=${sa_plmn}
    Execute Egate Command     amf_ue_ics_param id=1 ue=${ue_id} mobility_restriction_list_id=1

Trigger UE MO VoNR Voice Call With One Normal and One Eemergency PDU Session
    [Arguments]    ${ue_id}=1    ${pdu_id1}=1    ${pdu_id2}=2    ${gw_1st}=1    ${gw_2nd}=2
    Set qosflow priority and smf param    priority=15
    UE register    ue_id=${ue_id}    ue_sa_capabilities=${UE_nr_sa_capability}
    Setup PDU session    ${ue_id}    ${pdu_id1}    1    ${gw_1st}    initial-request    nea2    9
    Set qosflow priority and smf param    priority=1
    Setup PDU session with emergence cause    ${ue_id}    ${pdu_id2}    2    ${gw_2nd}    initial-emergency-request    nea2    5
    ADD Qosflow to exist PDU session    ${ue_id}    ${pdu_id2}    2    2    5QI_id=1
    Sim GNB ignore target gnb NSSAI    gNB_id=3

Set qosflow priority and smf param
    [Arguments]    ${priority}=15
    Execute Egate Command     qosflow_modify qos_flow=1 priority=${priority}
    Execute Egate Command     qosflow_modify qos_flow=2 priority=${priority}
    Execute Egate Command     qosflow_modify qos_flow=3 priority=${priority}
    Execute Egate Command     qosflow_modify qos_flow=4 priority=${priority}
    Execute Egate Command     smf_param id=1 reset

Setup PDU session
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${nwslice}=1    ${gw}=1    ${request_type}=initial-request    ${cipheringAlgorithm}=nea2    ${5QI}=9
    ${ret1}    Execute Egate Command     ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} nwslice=${nwslice} gw=${gw} request_type=${request_type}
    ...    QoS Routing Table
    Should Contain    ${ret1}=    securityModeCommand
    Should Contain    ${ret1}=    cipheringAlgorithm ${cipheringAlgorithm}
    Should Contain    ${ret1}=    Initial Context Setup Successful for UE with AMF UE
    Should Contain    ${ret1}=    Setup QosFlow with QFI:1 5QI:${5QI}

Setup PDU session with emergence cause
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${nwslice}=1    ${gw}=1    ${request_type}=initial-request    ${cipheringAlgorithm}=nea2    ${5QI}=5
    ${ret1}    Execute Egate Command     ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} nwslice=${nwslice} gw=${gw} request_type=${request_type}
    ...    Pdu Session Resource Setup Response Message with RAN UE NGAP ID [0-9]* handled successfully
    Should Contain    ${ret1}=    rrcReconfiguration
    Should Contain    ${ret1}=    Setup QosFlow with QFI:1 5QI:${5QI}

ADD Qosflow to exist PDU session
    [Arguments]    ${ue_id}=1    ${pdu_ses_id}=1    ${qos_flow_id}=2    ${QFI}=2    ${5QI_id}=1
    ${ret}    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu_ses_id} qosflows_to_add=${qos_flow_id} by=amf
    ...    pass_regexp=Pdu Session Resource Modify Response Message with .* handled successfully
    Should Contain    ${ret}    AMF-1: Added QosFlow with QFI:${QFI} 5QI:${5QI_id}

UE register
    [Arguments]    ${ue_id}=1    ${ue_sa_capabilities}=1
    Execute Egate Command     ue_register id=${ue_id} ue_nr_capabilities=${ue_sa_capabilities}    UE performed Registration

Trigger UE Intra-Frequency Inter-gNB HO
    [Arguments]    ${ue_id}=1    ${event}=A3    ${phycell_id}=381
    ${mea_id}    get nr meas id for specific type and frequency    ue_id=${ue_id}    carrierfreq=126990    event_type=A3
    Execute Egate Command     ue_measurement_send_nr id=${ue_id} meas_id=${mea_id} event=${event} srsrp_nr=11 phycell_id=${phycell_id} nrsrp_nr=80
    ...      pass_regexp=Inter-eNB handover

Trigger UE Intra-Frequency Inter-gNB Handover cancel
    [Arguments]    ${ue_id}=1    ${event}=A3    ${phycell_id}=381
    ${mea_id}    get nr meas id for specific type and frequency    ue_id=${ue_id}    carrierfreq=126990    event_type=A3
    Execute Egate Command     ue_measurement_send_nr id=${ue_id} meas_id=${mea_id} event=${event} srsrp_nr=11 phycell_id=${phycell_id} nrsrp_nr=80
    ...      pass_regexp=Handover canceled

Release PDU Session One By One
    [Arguments]    ${ue_id}=1
    Trigger UE PDU session release    ${ue_id}    pdu_id=1
    Trigger UE PDU session release    ${ue_id}    pdu_id=2

Trigger UE PDU session release
    [Arguments]    ${ue_id}=1    ${pdu_id}=1
    Execute Egate Command    ue_pdu_session_release ue=${ue_id} pdu=${pdu_id} by=ue    Successfully released PDU Session

Testcase Tear Down for 5GC000784-B
    [Arguments]    ${amf_id}=1    ${bypass}=off    ${Online_Param}=${EMPTY}
    Set qosflow priority and smf param     priority=15
    Execute Egate Command    amf_param id=${amf_id} bypassAuth_nullSecurity=${bypass}
    Execute Egate Command    amf_mobility_restriction_list_param id=1 reset
    OnlineParamChange    ${Online_Param}
    Common Test Teardown And Stop Capture Logs

Sim GNB ignore target gnb NSSAI
    [Arguments]    ${gNB_id}=3
    Execute Egate Command    gnb_param id=${gNB_id} ignore_MRL_during_HO=on ignore_NSSAI_during_HO=on

Check UE Location
    [Arguments]    ${ue_id}=1    ${enb}=3    ${cell}=1
    ${ret1}=    Execute Egate Command    ue_disp id=${ue_id}    PDN    timeout=20s
    ${ret2}=    Remove String    ${ret1}    ${SPACE}
    Should Contain    ${ret2}    enb${enb}
    Should Contain    ${ret2}    cell${cell}
