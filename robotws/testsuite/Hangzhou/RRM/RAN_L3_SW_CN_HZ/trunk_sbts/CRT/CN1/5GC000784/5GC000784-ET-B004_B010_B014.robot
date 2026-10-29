*** Settings ***
Documentation
...    crt_author: kema
...    contact: kema
...    squad group: VRF3SG07
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_VRF    SBTS00    RAN_5G    RAN_5G_FDD    CRT    CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD
...           team-SG2    owner-dan.liu    release-5G21A
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{ANR_gnb}
...    @{SNSSAI}
...    @{NRDRB}
...    @{PARAMS_FOR_PLMN}
...    @{NRCELL_NRPLMNSET_SA_NSA}
...    @{fixed_relation_error}
...    NRBTS:actIncXn=true
...    NRBTS:actIntraFreqHoSA=true
...    NRBTS:actInterRatHoSA=true

...    NRBTS:tRLFindForDUVoNR=500ms
...    NRBTS:rrcReestabTypeSA=viaRRCSetup
...    NRBTS:actNgcFlexSaMode=true
...    NRBTS:actRanSharing=true
...    NRBTS:actRanSharingEnh=max_10_PLMNs
...    NRBTS:cipherPrefL:nea0=1
...    NRBTS:cipherPrefL:nea1_128=0
...    NRBTS:cipherPrefL:nea2_128=9
...    NRBTS:cipherPrefL:nea3_128=0
...    NRBTS:integrityProtPrefL:nia1_128=0
...    NRBTS:integrityProtPrefL:nia2_128=9
...    NRBTS:integrityProtPrefL:nia3_128=0
...    NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-1:threshXHighQ=0
...    NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-1:threshXLowQ=0
...    NRBTS-1/NRPMRNL-1:miNrRelReportCu=5min
...    NRBTS-1/NRSCTP-1:sctpProfile:sctpWaitTimeInitSeqRetry=60
...    NRCELL:actVoNR=true
...    NRCELL:actEmergencyCall=true
...    NRCELL:actEnhancedVoNR=true
...    NRCELL:actGBRAdmissionControl=EnhancedVoNR
...    NRCELL:emergencyCallLimServ=true
...    NRCELL:maxGBRTrafficLimit=30
...    NRCELL:n310VoNR=n3
...    NRCELL:t310VoNR=500ms
...    NRCELL:gscnOrSsPbchArfcn=1587
...    NRCELL/NRCELL_FDD-1:nrarfcnDl=126900
...    NRCELL/NRCELL_FDD-1:nrarfcnUl=136100
...    NRCELL:arpPrioEmergencyCall=1
...    NRCELL:emergencyCallRestrictions:emergencyCallMrListIgnore=true
...    NRCELL:emergencyCallRestrictions:emergencyCallPlmnHoAllowed=true
...    NRCELL:a3MeasEnabled=rsrp
...    NRCELL:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRCELL:a3MeasSsbRsrp:a3OffsetSsbRsrp=15
...    NRCELL:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms40
...    NRCELL:absThreshSsbRsrpConsolidation=1
...    NRCELL:sMeasConfigSsbRsrp=0

@{NRCELL_NRPLMNSET_SA_NSA}
...    NRCELL/NRPLMNSET_SA-1:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-200
...    NRCELL/NRPLMNSET_SA-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRCELL/NRPLMNSET_NSA-1:configuredEpsTac=788
...    NRCELL/NRPLMNSET_NSA-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1

@{SNSSAI}
...    MRBTS-1/NRBTS-1/SNSSAI-1:ngUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    MRBTS-1/NRBTS-1/SNSSAI-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1,MRBTS-1/NRBTS-1/NRPLMN-2
...    MRBTS-1/NRBTS-1/SNSSAI-2:administrativeState=Unlocked
...    MRBTS-1/NRBTS-1/SNSSAI-2:sd=13714342
...    MRBTS-1/NRBTS-1/SNSSAI-2:sst=1
...    MRBTS-1/NRBTS-1/SNSSAI-2:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1,MRBTS-1/NRBTS-1/NRPLMN-2
...    delete:MRBTS-1/NRBTS-1/SNSSAI-2:ngUplane
...    MRBTS-1/NRBTS-1/TRACKINGAREA-200:fiveGsTac=788
...    TRACKINGAREA-200:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1
...    TRACKINGAREA-200:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2


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
...    MRBTS-1/NRBTS-1/NRDRB_MAC-4:lcgid=1
...    MRBTS-1/NRBTS-1/NRDRB_MAC-4:schedulPrio=4
...    MRBTS-1/NRBTS-1/NRDRB_MAC-4:nrDrbMacId=4
...    MRBTS-1/NRBTS-1/NRDRB-10:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-4
...    MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1:dlTReassemblyUm=ms40
...    MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1:nrDrbRlcUmId=1
...    MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1:ulTReassemblyUm=ms40

@{ANR_gnb}
...    NRBTS:actEnhanceIntraNrIntraFreqAnr=true
...    NRBTS:actSaUeBasedAnrNr=true
#...    NRBTS:actSaUeBasedInterFreqAnrNr=true
...    NRBTS:actDedicatedAnrDrxProfile=true
...    NRBTS:actSaIntraFreqAnrDrxProf=true
...    NRANR-1:actAutoEutraNbRemoval=false
...    NRANR-1:actAutoNrNbRemoval=true
...    NRANR-1:consecHoFailThres=0
...    NRANR-1:consecHoFailThresEutra=3
...    NRANR-1:consecXnResolveFailThres=3
...    NRANR-1:gNbIdLengthConfig:gNbIdLength=22
...    NRANR-1:gNbIdLengthConfig:priorityIndex=1
...    NRANR-1:gNbIdLengthConfig:nrPlmnDN=NRPLMN-2
...    NRANR-1:nrAnrId=1
...    NRANRPR-1:anrThresholdSelector=RSRP
...    NRANRPR-1:anrThresRsrpNbCell=-90
...    NRANRPR-1:anrThresRsrqNbCell=-12
...    NRANRPR-1:cellDepMode=SA+NSA
...    NRANRPR-1:consecRecheckForNrNbRemoval=5
...    NRANRPR-1:idleTimeForNrNbRemoval=72
...    NRANRPR-1:maxNumAnrNrrelAllowed=50
...    NRANRPR-1:nrAnrPrId=1

...    NRCELL:actCDrx=true
...    NRCELL:drxProfileNrAnr:drxControl=any
...    NRCELL:drxProfileNrAnr:nrDrxDN=NRDRX-3

@{NRREL}
...    NRADJGNB-1:administrativeState=Unlocked
...    NRADJGNB-1:gNodeBId=36
...    NRADJGNB-1:gNbIdLength=22
...    NRADJGNB-1:xnLinkRef=1
...    NRADJGNB-1:gnbPlmn:mncLength=3
...    NRADJGNB-1:gnbPlmn:mcc=311
...    NRADJGNB-1:gnbPlmn:mnc=402
#...    XNLINK-1:cPlaneIpAddr=10.0.1.122
...    NRADJNRCELL-1:cellDepType=SA
...    NRADJNRCELL-1:gNbId=36
...    NRADJNRCELL-1:gNbIdLength=22
...    NRADJNRCELL-1:lcrId=3
...    NRADJNRCELL-1:nrarfcn=126900
...    NRADJNRCELL-1:physCellId=48
...    NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRADJNRCELL-1:gnbPlmn:mnc=402
...    NRADJNRCELL-1:gnbPlmn:mncLength=3
...    NRADJNRCELL-1/ADJ_NRPLMNSET_SA-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-2
...    NRADJNRCELL-1/ADJ_NRPLMNSET_SA-1:fiveGsTac=100

@{PARAMS_FOR_PLMN}
...    MRBTS-1/NRBTS-1/NRPLMN-2:mcc=311
...    MRBTS-1/NRBTS-1/NRPLMN-2:mnc=402
...    MRBTS-1/NRBTS-1/NRPLMN-2:mncLength=3

@{fixed_relation_error}
...    NRBTS:timerXnDataFwdGuard=250
...    NRBTS-1/NRDRB-15:maxDataRateGbrDl=100
...    NRBTS-1/NRDRB-15:maxDataRateGbrUl=100
...    NRBTS-1/NRDRB_PDCP-2:pdcpBufDiscardEnabled=false
...    delete:MRBTS-1/NRBTS-1/NRCELL:configuredEpsTac
...    delete:MRBTS-1/NRBTS-1/NRCELL:trackingAreaDN
...    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrInterGnbMobilityCellCuNsa=disabled
...    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrInterGnbMobilityCellCuSa=disabled
...    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrIntraGnbMobilityCellCuSa=disabled
...    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrNeighborLteNrCuNsa=disabled
...    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrNeighborNrNrCuNsa=disabled

@{MrListIgnore_T_PlmnHoAllowed_F}
...    NRCELL:actEmergencyCall=true
...    NRBTS-1/NRCELL-1:emergencyCallRestrictions:emergencyCallMrListIgnore=true
...    NRBTS-1/NRCELL-1:emergencyCallRestrictions:emergencyCallPlmnHoAllowed=false

@{MrListIgnore_T_PlmnHoAllowed_T}
...    NRCELL:actEmergencyCall=true
...    NRBTS-1/NRCELL-1:emergencyCallRestrictions:emergencyCallMrListIgnore=true
...    NRBTS-1/NRCELL-1:emergencyCallRestrictions:emergencyCallPlmnHoAllowed=true

@{B014_param}
...    NRBTS-1/NRCELL-1:arpPrioEmergencyCall=6
...    NRBTS-1/NRCELL-1:maxNumOfNonGBRBearersSA=5
...    NRBTS-1/NRCELL-1:maxNumOfGBRBearersSA=0
...    NRBTS-1/NRCELL-1:numOfRadioResReservForEmergency=1
...    NRBTS-1/NRCELL-1:addNumOfGBRBearers=1
...    NRBTS-1/NRCELL-1:maxNumOfRrcSA=1
...    NRCELL:actEmergencyCall=true
...    NRBTS-1/NRCELL-1:emergencyCallRestrictions:emergencyCallMrListIgnore=false
...    NRBTS-1/NRCELL-1:emergencyCallRestrictions:emergencyCallPlmnHoAllowed=true
...    NRBTS-1/NRDU-1:numOfDrbsReservForEmergency=1
...    NRBTS-1/NRCELLGRP-0:addNumOfRrcCGRPSAHo=1

@{B014_RRC_0}
...    NRBTS-1/NRCELL-1:maxNumOfRrcSA=0

@{counters_B04}
...    NRCELL-1:NMOCU:${ATT_HO_EMERGENCY}=1
...    NRCELL-1:NMOCU:${FAIL_HO_PREP_EMERGENCY_RECD}=0

@{counters_B14}
...    NRCELL-1:NMOCU:${ATT_HO_EMERGENCY}=1
...    NRCELL-1:NMOCU:${SUCC_HO_EMERGENCY}=1
...    NRCELL-1:NMOCU:${HO_PREP_EMERGENCY_SENT}=1

${ATT_HO_EMERGENCY}    M55147C00501
${FAIL_HO_PREP_EMERGENCY_RECD}    M55147C00502
${SUCC_HO_EMERGENCY}    M55147C00503
${HO_PREP_EMERGENCY_SENT}    M55147C00504

${SA_Capa_perUE}    SEPARATOR=
...    E1A01000074E5A031E00038420007824C1900010F09003100D00980C0301C022A36146B04050D012CB28986801EB608080838778E1C830E0008193C7D5C0013C0070004
...    F000A8D88DAC10143404B2CA261A007AD8202020E1DE38720C38002064F1F54FFD3FF2A3626EB04050D012CB28986801EB608080838778E1C830E0008193C7D5C0013C0
...    070004F0000C20E2680000008385000000020E2300000100501360144046170000F01808804602001FEAAAAA0B800E800A070500703009801C001A0F802000000000000
...    0000803CA9AC0CA0082000012CB2A000000803A555440E85800E001600010008010020010040086AC4C0004080C1014181C202C4044484C648494989CA12986B4


*** Test Cases ***
5GC000784-ET-B004_Verify_unsuccessful_Intra_freq_inter_gnb_inter-PLMN_HO_with_EC_call_ongoing_with_inter_plmn_flag_set_as_of_false
    [Documentation]    1. The purpose of this test case is to
    ...    Verify intra-GNB intra-Freq inter-PLMN handover with emergency call ongoing when parameters set as below:
    ...    Source Cell: emergencyCallMrListIgnore=true; emergencyCallPlmnHoAllowed=true
    ...    2. Test Case Step:
    ...    a, UE-1,2 set MRL to restrict target cell (Not allowed TAC).
    ...    b, UE-2 initial emergency call in source cell via 2 pdu sessions (Normal 5QI9, EC 5QI 5&1)
    ...    c, UE-2 perform inter gnb inter-plmn HO to target cell.
    ...    d, UE-2 release pdu sessions one by one.
    ...    e, UE-1 initial emergency call in source cell via 2 pdu sessions (Normal 5QI9, EC 5QI 5&1)
    ...    f, Online modify emergencyCallPlmnHoAllowed to false.
    ...    g, UE-1 perform inter gnb inter-plmn HO to target cell.
    ...    3. Expected Result:
    ...    g, No handover(no rrc reconfiguration) shall be triggered, UE stays at source cell.
    ...    Note: merged B002 case here
    [Tags]    QC_61246
    Clear Counter files
    Setup Xn Link To gNB5
    Config AMF1 MRL For UE    ue_id=1-2
    Trigger UE MO VoNR Voice Call With One Normal and One Eemergency PDU Session    ue_id=2    gw1=1    gw2=2
    Trigger UE Intra-Frequency Inter-gNB HO    ue_id=2    phycell_id=48
    Release PDU Session One By One    ue_id=2    sessions=2
    Trigger UE MO VoNR Voice Call With One Normal and One Eemergency PDU Session    ue_id=1    gw1=3    gw2=4
    OnlineParamChange    ${MrListIgnore_T_PlmnHoAllowed_F}
    Trigger UE Intra-Frequency Inter-gNB HO fail    ue_id=1    phycell_id=48
    Check ue loacation and PM counters and Release ue

5GC000784-ET-B010_Verify_successful_Intra_freq_inter_gnb_inter-PLMN_HO_with_EC_call_ongoing_with_emergencyCallPlmnHoAllowed_off_on_target
    [Documentation]    successful_Intra_freq_inter_gnb_inter-PLMN_HO_with_EC_call_ongoing_with_emergencyCallPlmnHoAllowed_off_on_target
    ...    2. Test Case Steps:
    ...    a. Add UE History Information List For Handover
    ...    b. Setup Xn Link To gNB5
    ...    c. Config AMF1 MRL For UE
    ...    d. Trigger UE MO VoNR Voice Call With One Normal and One Eemergency PDU Session
    ...    e.Sim GNB ignore target gnb NSSAI
    ...    f. UE-1 trigger inter-Freq handover to the target cell
    ...    g.Online modify paramter DisableECPlmnHoAllowed
    ...    h.Trigger UE Intra-Frequency Inter-gNB HO
    ...    3. Expected Results:
    ...    UE-1 cell should still stay in cell in for HO unsuccessful
    [Tags]    QC_61241
    Test Setup For Case In Same Suite    ${MrListIgnore_T_PlmnHoAllowed_T}
    Add UE History Information List For Handover    ue_id=5    gnb_id=5     plmn_list=311:402
    Setup Xn Link To gNB5
    Config AMF1 MRL For UE    ue_id=5    equiv_plmn=311:402    sa_plmn=311:489    not_allowed_tacs=788
    Trigger UE MO VoNR Voice Call With One Normal and One Eemergency PDU Session    ue_id=5    pdu_id1=1    pdu_id2=2
    ...    gw1=1    gw2=2    cipheringAlgorithm=nea2
    Trigger UE Intra-Frequency Inter-gNB HO    ue_id=5    phycell_id=48
    OnlineParamChange    ${MrListIgnore_T_PlmnHoAllowed_F}
    Trigger UE Intra-Frequency Inter-gNB HO meas3    ue_id=5    phycell_id=60
    Release PDU Session and tear down
    Release Ues    ue_type=all

5GC000784-ET-B014_Verify_successful_Intra_freq_inter_gnb_inter-PLMN_HO_IN_with_EC_call_ongoing_real_gnb_as_target
    [Documentation]    1. The purpose of this test case is to
    ...    Verify intra-GNB intra-Freq inter-PLMN handover with emergency call ongoing when parameters set as below:
    ...    Source Cell:
    ...    NRBTS/NRCELL.maxNumOfGbrBearersSA =0; numOfRadioResReservForEmergency =1; maxNumOfRrcSA=1
    ...    NRBTS/NRDU.numOfDrbsReservForEmergency =1;addNumOfRrcCGRPSAHo=1
    ...    emergencyCallMrListIgnore=true; emergencyCallPlmnHoAllowed=true
    ...    2. Test Case Step:
    ...    a, UE-3 set MRL to restrict real gnb as target cell (Not allowed TAC).
    ...    b, UE-3 initial emergency call in in source cell (Normal 5QI9, EC 5QI5&1)
    ...    c, UE-3 perform inter gnb inter-plmn HO to target cell.
    ...    d, online modify maxNumOfRrcSA to 0 to ensure HO back use resource of addNumOfRrcCGRPSAHo.
    ...    e, UE-3 perform inter gnb inter-plmn HO back to real gnb.
    ...    f, change emergency arp to 15
    ...    g, UE-3 Setup normal call with 5QI5 setup and 5QI1 add
    ...    3. Expected Result:
    ...    e, handover performed succussfully.
    ...    f, normal voice call pdu setup should reject as "invalid qos combination"
    [Tags]    QC_47188    B014
    Clear Counter files
    Test Setup For Case In Same Suite    ${B014_param}
    Add UE History Information List For Handover    ue_id=3    gnb_id=5    plmn_list=311:402
#    Setup Xn Link To gNB5
    Config AMF1 MRL For UE    ue_id=3    sa_plmn=311:489    not_allowed_tacs=788
    Trigger UE MO VoNR Voice Call With One Normal and One Eemergency PDU Session    ue_id=3    gw1=4    gw2=5
    ...    arp1=15    arp2=6
    Trigger UE Intra-Frequency Inter-gNB HO    ue_id=3    phycell_id=48
    OnlineParamChange    ${B014_RRC_0}
    Trigger UE Intra-Frequency Inter-gNB HO meas3    ue_id=3    phycell_id=60
    Set qos pri and Trigger UE 2nd call
    Check PM counters and Release ue

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fdd_sansa_cmwv/2cells
    Comment    Debug Enter Into Egate

Modify Cfg
    Update Cfg    set_amf_region id=1 tac_list=7627107,100,788,200,0 plmn=311:489,311:402
    Update Cfg    amf_param id=1 full_nas_auth=on nia=null+aes nea=null+aes voice_fallback=off ims_voice_3gpp=on
    Update Cfg    set_qosflow id=1 5qi=5 default=off
    Update Cfg    set_qosflow id=2 5qi=1
    Update Cfg    set_qosflow id=3 5qi=9 default=on
    Update Cfg    set_qosflow id=4 5qi=7
    Update Cfg    set_qosrule id=1 proto=tcp qos_flow=1
    Update Cfg    set_qosrule id=2 proto=udp qos_flow=2
    Update Cfg    set_nwslice id=1 snssai=0x01:0xD143A5 default=on ue=1-6 amf=1 qos_flows=3,2,1 qos_rules=1,2
    Update Cfg    set_nwslice id=2 snssai=0x01:0xD143A6 ue=1-6 amf=1 qos_flows=1,2 qos_rules=1,2
    Update Cfg    ue_nr_capabilities id=1-6 voice_over_nr=on:on:off
    Update Cfg    ue_param id=1-10 nr_usage_setting=voice_centric ue_nr_capabilities=${SA_Capa_perUE}
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
    ${SIM-GNB5}    catenate    set_gnb id=5 type=simulated plmn=311:402 ng=10.0.1.123 gnb_id=0x24:22 daemon=10.0.2.1:22222
    ...    x2_peers=none xn=10.0.1.122 nssai=0x1:0xd143a5,0x1:0xd143a6,0x1:0xd143a8 amf=1
    Update Cfg    ${SIM-GNB5}
    Update Cfg    set_cell id=1 gnb=5 pci=16:0 tac=100 nrci=0x03 tdd_cell=off proxy=10.0.2.92:9999 nr_arfcn=136100:126900 gscn=1587
    Update Cfg    gnb_param id=5 xn_listening_socket=1 send_xn_setup=false sib1_period=160ms
	Update Cfg    gnb_cell_param id=1 gnb=5 enable_drx_profile_for_anr=on
    ${GNB2}    catenate    set_gnb id=2 type=external plmn=311:489 s1u=10.0.1.2 x2=10.0.1.2:36422 ng=10.0.1.2 gnb_id=0x1:22 daemon=10.0.2.1:22222
    ...    xn=10.0.1.2 x2_peers=none amf=1
    Update Cfg    ${GNB2}
    ${GNB2_cell}    catenate    set_cell id=1 gnb=2 pci=20:0 tac=788 nrci=0x01 eci=0x000021f tdd_cell=off proxy=10.0.2.80:9999|10.0.2.80:8888
    ...    nr_arfcn=136100:126900 gscn=1587
    Update Cfg    ${GNB2_cell}

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir

Trigger UE MO VoNR call with PDU
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${nwslice}=1    ${gw}=1    ${request_type}=initial-request    ${fiveQI}=9
    ...    ${cipheringAlgorithm}=nea2
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Registered    timeout=20s
    ${cmd}    Catenate    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} nwslice=${nwslice} gw=${gw} request_type=${request_type}
    ${ret1}=    Execute Egate Command    ${cmd}    QoS Routing Table    timeout=20s
    Should Contain    ${ret1}=    securityModeCommand
    Should Contain    ${ret1}=    cipheringAlgorithm ${cipheringAlgorithm}
    Should Contain    ${ret1}=    Initial Context Setup Successful for UE with AMF UE
    Should Contain    ${ret1}=    Setup QosFlow with QFI:1 5QI:${fiveQI}

Set qosflow priority and smf param reset
    [Arguments]    ${priority}=1
    Execute Egate Command    qosflow_modify qos_flow=1 priority=${priority}
    Execute Egate Command    qosflow_modify qos_flow=2 priority=${priority}
    Execute Egate Command    qosflow_modify qos_flow=3 priority=${priority}
    Execute Egate Command    qosflow_modify qos_flow=4 priority=${priority}
    Execute Egate Command    smf_param id=1 reset

Reset qosflow priority and smf param
    Set qosflow priority and smf param reset    priority=15

Setup Xn Link To gNB${gnb}
    Execute Egate Command    gnb_param id=${gnb} xn_listening_socket=1 send_xn_setup=true
    Execute Egate Command    gnb_xn_link_up gnb=${gnb} target=2    GNB-5: XnAP Link with GNB-2 .* is up
    Sleep    30s    #wait till xn linkup complete

Config AMF1 MRL For UE
    [Arguments]    ${ue_id}=1    ${equiv_plmn}=311:402     ${sa_plmn}=311:402    ${not_allowed_tacs}=100
    ...    ${fa_plmn}=311:409     ${forbidden_tacs}=311
    ${cmd1}    Catenate    amf_mobility_restriction_list_param id\=1 equiv_plmn\=${equiv_plmn}
    ...    sa_plmn\=${sa_plmn} not_allowed_tacs\=${not_allowed_tacs} fa_plmn=${fa_plmn} forbidden_tacs=${forbidden_tacs}
    Execute Egate Command    ${cmd1}
    ${cmd1}    Catenate    amf_mobility_restriction_list_param id=1
    Execute Egate Command    ${cmd1}    pass_regexp=${sa_plmn}
    ${cmd1}    Catenate    amf_ue_ics_param id=1 ue=${ue_id} mobility_restriction_list_id=1
    Execute Egate Command    ${cmd1}

Trigger UE MO VoNR Voice Call With One Normal and One Eemergency PDU Session
    [Arguments]    ${ue_id}=1    ${pdu_id1}=1    ${pdu_id2}=2    ${gw1}=1    ${gw2}=2
    ...    ${cipheringAlgorithm}=nea2    ${nwslice1}=1    ${fiveQI}=9    ${arp1}=15    ${arp2}=1
    Set qosflow priority and smf param reset    priority=${arp1}
    Trigger UE MO VoNR call with PDU    ue_id=${ue_id}    pdu_id=${pdu_id1}    gw=${gw1}    nwslice=${nwslice1}    request_type=initial-request
    ...    fiveQI=${fiveQI}    cipheringAlgorithm=${cipheringAlgorithm}
    Set qosflow priority and smf param reset    priority=${arp2}
    Trigger UE Setup 2nd Call    ue_id=${ue_id}    pdu_id=${pdu_id2}    gw=${gw2}    nwslice=2

Trigger UE Setup 2nd Call
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${nwslice}=1    ${gw}=1    ${request_type}=initial-emergency-request
    Trigger UE 5QI5 setup successfully with PDU    ue_id=${ue_id}    pdu_id=${pdu_id}    nwslice=${nwslice}    gw=${gw}
    ...    request_type=${request_type}
    #Trigger UE 5QI add successfully with PDU session modify    ue_id=${ue_id}    pdu_id=${pdu_id}

Trigger UE 5QI5 setup successfully with PDU
    [Arguments]    ${ue_id}=1    ${pdu_id}=2    ${nwslice}=2    ${gw}=3    ${request_type}=initial-emergency-request
    ${ret1}=    Execute Egate Command
    ...    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} nwslice=${nwslice} gw=${gw} request_type=${request_type}
    ...    Pdu Session Resource Setup Response Message with RAN UE NGAP ID [0-9]* handled successfully    timeout=20s
    Should Contain    ${ret1}=    rrcReconfiguration
    Should Contain    ${ret1}=    Setup QosFlow with QFI:1 5QI:5

Trigger UE 5QI add successfully with PDU session modify
    [Arguments]    ${ue_id}=1    ${pdu_id}=2    ${fiveQI}=1    ${qosflows_to_add}=2
    ${ret1}=    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_add=${qosflows_to_add} by=amf
   ...    Pdu Session Resource Modify Response Message with RAN UE NGAP ID [0-9]* handled successfully    timeout=20s
    Should Contain    ${ret1}=    rrcReconfiguration
    Should Contain    ${ret1}=    Added QosFlow with QFI:${qosflows_to_add} 5QI:${fiveQI}

Trigger UE Intra-Frequency Inter-gNB HO
    [Arguments]    ${ue_id}=1    ${event}=A3    ${phycell_id}=381
    Sleep    2s    #Wait pre-RrcReconfigurationComplete sent out
    Sim GNB ignore target gnb NSSAI
    ${mea_id}    get nr meas id for specific type and frequency    ue_id=${ue_id}    carrierfreq=126990    event_type=A3
    ${cmd}    Catenate    ue_measurement_send_nr id\=${ue_id} meas_id\=${mea_id} event\=${event} srsrp_nr\=11 phycell_id\=${phycell_id}
    ...    nrsrp_nr\=80
    ${xnlink_up}    create list
    ...    XnAP Link with GNB-2 .* is up
    ...    rrcReconfigurationComplete
    Execute Egate Command    ${cmd}    pass_regexp=${xnlink_up}
    ${mea_id}    get nr meas id for specific type and frequency    ue_id=${ue_id}    carrierfreq=126990    event_type=A3
    ${cmd}    Catenate    ue_measurement_send_nr id\=${ue_id} meas_id\=${mea_id} event\=${event} srsrp_nr\=11 phycell_id\=${phycell_id}
    ...    nrsrp_nr\=80
    Execute Egate Command    ${cmd}    pass_regexp=Inter-eNB handover

Trigger UE Intra-Frequency Inter-gNB HO meas3
    [Arguments]    ${ue_id}=1    ${event}=A3    ${phycell_id}=381
    Sleep    2s    #Wait pre-RrcReconfigurationComplete sent out
    ${mea_id}    get nr meas id for specific type and frequency    ue_id=${ue_id}    carrierfreq=126990    event_type=A3
    ${cmd}    Catenate    ue_measurement_send_nr id\=${ue_id} meas_id\=${mea_id} event\=${event} srsrp_nr\=11 phycell_id\=${phycell_id}
    ...    nrsrp_nr\=80
    Execute Egate Command    ${cmd}    pass_regexp=Inter-eNB handover

Release PDU Session One By One
    [Arguments]    ${ue_id}=1    ${sessions}=2
    FOR     ${session}    IN RANGE    1    ${sessions}+${1}
        sleep    10s    #Wait for command to complete
        Trigger UE PDU session release    ue_id=${ue_id}    pdu_id=${session}
    END

Trigger UE PDU session release
    [Arguments]    ${ue_id}=1    ${pdu_id}=1
    Execute Egate Command    ue_pdu_session_release ue=${ue_id} pdu=${pdu_id} by=ue    Successfully released PDU Session
    ...    timeout=20s

Trigger UE Intra-Frequency Inter-gNB HO fail
    [Arguments]    ${ue_id}=1    ${event}=A3    ${phycell_id}=381
    ${mea_id}    get nr meas id for specific type and frequency    ue_id=${ue_id}    carrierfreq=126990    event_type=A3
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${mea_id} event=${event} srsrp_nr=11 phycell_id=${phycell_id}
    ...    nrsrp_nr=80
    Execute Egate Command    ${cmd}    pass_regexp=measResultNeighCells    fail_regexp=rrcReconfiguration

Check UE Location
    [Arguments]    ${ue_id}=1    ${enb}=2    ${cell}=1
    ${ret1}=    Execute Egate Command    ue_disp id=${ue_id}    PDN    timeout=20s
    Should Match Regexp    ${ret1}=    enb\\s{2,}${enb}
    Should Match Regexp    ${ret1}=    cell\\s{2,}${cell}

Check ue loacation and PM counters and Release ue
    Check UE Location    ue_id=1    enb=2    cell=1
    Check Wireshark Log    ${CURDIR}${/}a2a_B004${/}a2a_wireshark.ini    wait_string=UEContextReleaseComplete::2
    Check counters    ${counters_B04}
    Test case tear down for 784-B
    Release Ues    ue_type=all

Check PM counters and Release ue
    Check Wireshark Log    ${CURDIR}${/}a2a_B014${/}a2a_wireshark.ini    wait_string=UEContextReleaseComplete::1
    Check counters    ${counters_B14}
    Test case tear down for 784-B
    Release Ues    ue_type=all

Sim GNB ignore target gnb NSSAI
    Execute Egate Command    gnb_param id=5 ignore_MRL_during_HO=on ignore_NSSAI_during_HO=on

Test Setup For Case In Same Suite
    [Arguments]    ${param}
    Reset qosflow priority and smf param
    Delta Commission Parameters    ${param}
    Cells Should Be OnAir

Add UE History Information List For Handover
    [Arguments]    ${ue_id}=1    ${gnb_id}=3    ${plmn_list}=311:489
    Execute Egate Command
    ...    ue_history_information_list_add_ngran id=1 cell_type=large nrcgi=311:489|0x01 gnb_id=2 time_ue_stayed_in_cell=97
    Execute Egate Command
    ...    ue_history_information_list_add_ngran id=1 cell_type=large nrcgi=${plmn_list}|0x01 gnb_id=${gnb_id} time_ue_stayed_in_cell=98
    Execute Egate Command
    ...    ue_history_information_list_add_ngran id=1 cell_type=large nrcgi=311:489|0x01 gnb_id=2 time_ue_stayed_in_cell=99
    Execute Egate Command    ue_history_information_list id=1 action=commit
    Execute Egate Command    ue_enb_param id=${ue_id} ue_history_list=1

Trigger UE Setup 2nd Call Fail
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${nwslice}=1    ${gw}=1    ${request_type}=initial-emergency-request
    Trigger UE 5QI5 setup successfully with PDU    ue_id=${ue_id}    pdu_id=${pdu_id}    nwslice=${nwslice}    gw=${gw}
    ...    request_type=${request_type}
    Trigger UE 5QI1 add failed    ue_id=${ue_id}    pdu_id=${pdu_id}

Trigger UE 5QI1 add failed
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${qosflows_to_add}=2
    ${ret1}=    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_add=${qosflows_to_add} by=amf
    ...    Pdu Session Resource Modify Response Message with RAN UE NGAP ID [0-9]* handled successfully    timeout=20s
    Should Contain    ${ret1}=    PDU Session Resource Modify Unsuccessful Transfer
    should not contain      ${ret1}=    fallback

Set qos pri and Trigger UE 2nd call
    Set qosflow priority and smf param reset    priority=15
    Trigger UE Setup 2nd Call Fail    ue_id=3    pdu_id=3    gw=6    nwslice=2    request_type=initial-request

Test case tear down for 784-B
    Reset qosflow priority and smf param
    Set AMF byPassAuth nullSecurity    bypass=off
    Remove MRL setting

Set AMF byPassAuth nullSecurity
    [Arguments]    ${amf_id}=1    ${bypass}=on
    Execute Egate Command    amf_param id=${amf_id} bypassAuth_nullSecurity=${bypass}

Remove MRL setting
    ${ret}=    Execute Egate Command    amf_mobility_restriction_list_param id=1 reset

Release PDU Session and tear down
    Release PDU Session One By One    ue_id=5
    Test case tear down for 784-B

