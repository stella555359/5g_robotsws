*** Settings ***
Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    CRT    CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD    team-SG2
...               owner-jun.15.zhang    release-5G21A
Resource          ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{NRRELE}
...    @{SNSSAI}
...    @{NRDRB}
...    @{Mobility}
...    @{NRHOIF}
...    @{NRHOIR}
...    @{fixed_relation_error}
...    NRBTS:actMFBIEutra=true
...    NRCELL:actVoNR=true
...    NRCELL:actEmergencyCall=true

...    NRCELL:actEnhancedVoNR=true
...    NRCELL:actGBRAdmissionControl=EnhancedVoNR
...    NRBTS:actIntraFreqHoSA=true
...    NRBTS:actInterRatHoSA=true
...    NRBTS:actNgcFlexSaMode=true

...    NRCELL:measGapSelectionSA=favourUeThroughput
...    NRCELL:actVoNrMobilityThresholds=VoNrMobilityThresholds
...    NRCELL:emergencyCallLimServ=true
...    NRCELL:maxGBRTrafficLimit=30
...    NRBTS:actInterFreqHoSA=false
...    NRCELL:n310VoNR=n3
...    NRCELL:t310VoNR=500ms
...    NRCELL:gscnOrSsPbchArfcn=1587
...    NRCELL/NRCELL_FDD-1:nrarfcnDl=126900
...    NRCELL/NRCELL_FDD-1:nrarfcnUl=136100
...    NRBTS:tRLFindForDUVoNR=500ms
...    NRCELL:arpPrioEmergencyCall=1
...    NRBTS:rrcReestabTypeSA=viaRRCSetup
...    NRCELL:emergencyCallRestrictions:emergencyCallMrListIgnore=false
...    NRCELL:emergencyCallRestrictions:emergencyCallPlmnHoAllowed=true
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
...    MRBTS-1/NRBTS-1/NRCELL-1:nrhoirDNList=MRBTS-1/NRBTS-1/NRHOIR-1
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
...    MRBTS-1/NRBTS-1/NRDRB_MAC-4:lcgid=1
...    MRBTS-1/NRBTS-1/NRDRB_MAC-4:schedulPrio=4
...    MRBTS-1/NRBTS-1/NRDRB_MAC-4:nrDrbMacId=4
...    MRBTS-1/NRBTS-1/NRDRB-10:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-4
...    MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1:dlTReassemblyUm=ms40
...    MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1:nrDrbRlcUmId=1
...    MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1:ulTReassemblyUm=ms40
@{Mobility}
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeashoEnabledSA=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=20
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=80
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms480
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeashoEnabledSA=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=34
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms480
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeashoSsbRsrpSA:a2HysteresisHoSsbRsrpVoNr=1
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeashoSsbRsrpSA:a2ThresholdHoSsbRsrpVoNr=35
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeashoSsbRsrpSA:a2TimeToTriggerHoSsbRsrpVoNr=ms512
...    MRBTS-1/NRBTS-1/NRCELL-1:a3MeasEnabled=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    MRBTS-1/NRBTS-1/NRCELL-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=15
...    MRBTS-1/NRBTS-1/NRCELL-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms40
...    MRBTS-1/NRBTS-1/NRCELL-1:absThreshSsbRsrpConsolidation=1
...    MRBTS-1/NRBTS-1/NRCELL-1:sMeasConfigSsbRsrp=0
@{NRHOIF}
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a3MeasEnabled=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:cellDepType=SA
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:freqBandIndicatorNR=78
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:ifhoSsbScs=15KHz
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:ssBurstSetPeriod=20
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:ssbFrequency=633408
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=30
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms64
@{NRRELE}
...    MRBTS-1/NRBTS-1:actIncXn=true
...    MRBTS-1/NRBTS-1:actConflictConfiguration=true
...    MRBTS-1/NRBTS-1/NRADJECELL-1:eNodeBId=36
...    MRBTS-1/NRBTS-1/NRADJECELL-1:ePSTrackingAreaCode=100
...    MRBTS-1/NRBTS-1/NRADJECELL-1:earfcnValue=1400
...    MRBTS-1/NRBTS-1/NRADJECELL-1:lcrId=1
...    MRBTS-1/NRBTS-1/NRADJECELL-1:physCellId=11
...    MRBTS-1/NRBTS-1/NRADJECELL-1:eUtraMultibandInfoList=3
...    MRBTS-1/NRBTS-1/NRADJECELL-1:ecgiPlmn:mcc=311
...    MRBTS-1/NRBTS-1/NRADJECELL-1:ecgiPlmn:mnc=402
...    MRBTS-1/NRBTS-1/NRADJECELL-1:ecgiPlmn:mncLength=3
...    MRBTS-1/NRBTS-1/NRADJECELL-1:enbPlmn:mcc=311
...    MRBTS-1/NRBTS-1/NRADJECELL-1:enbPlmn:mnc=402
...    MRBTS-1/NRBTS-1/NRADJECELL-1:enbPlmn:mncLength=3
...    MRBTS-1/NRBTS-1/NRCELL-1/NRRELE-1:cellIndividualOffset=0dB
...    MRBTS-1/NRBTS-1/NRCELL-1/NRRELE-1:eNodeBId=36
...    MRBTS-1/NRBTS-1/NRCELL-1/NRRELE-1:eutranCellExcluded=false
...    MRBTS-1/NRBTS-1/NRCELL-1/NRRELE-1:lcrId=1
...    MRBTS-1/NRBTS-1/NRCELL-1/NRRELE-1:ecgiPlmn:mcc=311
...    MRBTS-1/NRBTS-1/NRCELL-1/NRRELE-1:ecgiPlmn:mnc=402
...    MRBTS-1/NRBTS-1/NRCELL-1/NRRELE-1:ecgiPlmn:mncLength=3
@{NRHOIR}
...    MRBTS-1/NRBTS-1/NRHOIR-1:allowedMeasBandwidth=mbw50
...    MRBTS-1/NRBTS-1/NRHOIR-1:b2MeashoEnabled=rsrp
...    MRBTS-1/NRBTS-1/NRHOIR-1:b2Threshold1hoRsrp=35
...    MRBTS-1/NRBTS-1/NRHOIR-1:b2Threshold1hoRsrq=50
...    MRBTS-1/NRBTS-1/NRHOIR-1:earfcnValue=1400
...    MRBTS-1/NRBTS-1/NRHOIR-1:eutraFreqQOffsetRange=0dB
...    MRBTS-1/NRBTS-1/NRHOIR-1:presenceAntennaPort1=false
...    MRBTS-1/NRBTS-1/NRHOIR-1:reportAmount=r8
...    MRBTS-1/NRBTS-1/NRHOIR-1:reportInterval=ms240
...    MRBTS-1/NRBTS-1/NRHOIR-1:widebandRsrqMeas=true
...    MRBTS-1/NRBTS-1/NRHOIR-1:eutraB2MeashoRsrp:b2HysteresishoRsrp=0
...    MRBTS-1/NRBTS-1/NRHOIR-1:eutraB2MeashoRsrp:b2HysteresishoRsrpVoNr=0
...    MRBTS-1/NRBTS-1/NRHOIR-1:eutraB2MeashoRsrp:b2Threshold2hoRsrp=18
...    MRBTS-1/NRBTS-1/NRHOIR-1:eutraB2MeashoRsrp:b2Threshold2hoRsrpVoNr=18
...    MRBTS-1/NRBTS-1/NRHOIR-1:eutraB2MeashoRsrp:b2TimeToTriggerhoRsrp=ms480
...    MRBTS-1/NRBTS-1/NRHOIR-1:eutraB2MeashoRsrp:b2TimeToTriggerhoRsrpVoNr=ms480
...    MRBTS-1/NRBTS-1:excludedEutranCellPeriod=10
...    MRBTS-1/NRBTS-1:excludedEutranCellThreshold=5
...    MRBTS-1/NRBTS-1:excludedEutranCellTimeWindow=10
@{fixed_relation_error}
...    NRBTS:timerXnDataFwdGuard=250
...    NRBTS-1/NRDRB-15:maxDataRateGbrDl=100
...    NRBTS-1/NRDRB-15:maxDataRateGbrUl=100
...    NRBTS-1/NRDRB_PDCP-2:pdcpBufDiscardEnabled=false
...    NRDRB_MAC-3:schedulBSD=100ms
@{MrListIgnore_T_PlmnHoAllowed_T}
...    NRCELL:emergencyCallRestrictions:emergencyCallMrListIgnore=true
...    NRCELL:emergencyCallRestrictions:emergencyCallPlmnHoAllowed=true
@{MrListIgnore_F_PlmnHoAllowed_T}
...    NRCELL:emergencyCallRestrictions:emergencyCallMrListIgnore=false
...    NRCELL:emergencyCallRestrictions:emergencyCallPlmnHoAllowed=true
@{MrListIgnore_T_PlmnHoAllowed_T_Act_InterFHo}
...    NRBTS:actInterFreqHoSA=true
...    NRCELL:emergencyCallRestrictions:emergencyCallMrListIgnore=true
...    NRCELL:emergencyCallRestrictions:emergencyCallPlmnHoAllowed=true
@{Counters_B022}
...    NRCELL-1:${ATT_IRATHO_EMERGENCY} =1
...    NRCELL-1:${SUCC_IRATHO_EMERGENCY} =1
...    NRCELL-1:${IRATHO_PREP_EMERGENCY_SENT}=1
${ATT_IRATHO_EMERGENCY}             M55144C00501
${SUCC_IRATHO_EMERGENCY}                 M55144C00502
${IRATHO_PREP_EMERGENCY_SENT}                 M55144C00503
${UE_nr_sa_capability}    SEPARATOR=
...    E1A01000074E5A031E000381A00F04983200021E0A018806804C020301C022A36146B04050D012CB2898183D6C10101070EF1C39061C001032
...    78FAB80027800E0009E00151B11B582028680965944C0C1EB608080838778E1C830E0008193C7D53FF4FFCA8D89BAC10143404B2CA26060F5B
...    0404041C3BC70E418700040C9E3EAE0009E003800278000610713400000041C2800000010711800000802809B00A20230380780C0440230100
...    0FF5555504C00E000A070500703007803800341F004000000000000000100795358194010400002596540000010074AAA881D0500E00160001
...    0008010020010040086AC4C0004080C1014181C202C4044484C648494989CA12986B40

*** Test Cases ***
5GC000784-ET-B022_Verify_InterRAT_HO_With_Emergency_Call_Ongoing_Based_On_B2_Measurements_With_actVoNrMobilityThresholds
    [Documentation]
    ...    UE1: without MRL in ICSR and non-standardized slice is used
    ...         MrListIgnore_F_PlmnHoAllowed_T, actVoNrMobilityThresholds = VoNrMobilityThresholds
    ...         NC PDU setup 5QI5, normal threshold, modify+5QI1, vonr threshold, EC PDU setup 5QI5+5QI1, no update
    ...    UE2: MRL: restricted_rat=lte; target cell plmn not include in equipment plmn
    ...         MrListIgnore_T_PlmnHoAllowed_T, actVoNrMobilityThresholds = VoNrMobilityThresholds
    ...         NC PDU setup 5QI5+5QI1, no measConfig, EC PDU setup 5QI5, vonr threshold, modify+5QI1, no update
    ...    UE3: MRL: no restricted_rat configured; target cell plmn include in equipment plmn
    ...         MrListIgnore_F_PlmnHoAllowed_T, actVoNrMobilityThresholds = VoNrMobilityThresholds
    ...         NC PDU setup 5QI5, normal threshold, EC PDU setup 5QI5, no update, modify+5QI1, vonr threshold
    ...    UE4: MRL: restricted_rat=lte; target cell plmn not include in equipment plmn
    ...         MrListIgnore_T_PlmnHoAllowed_T, actVoNrMobilityThresholds = VoNrMobilityThresholds, inter-frequency mobility configed
    ...         NC PDU setup 5QI5, no measConfig, modify+5QI1, no measConfig, EC PDU setup 5QI5+5QI1, vonr threshold
    ...    After InterRAT_HO finish, below PM Counters should be updated:
    ...    784 M55144C00501 ATT_IRATHO_EMERGENCY       Number of Inter-RAT Handover attempts for IMS Emergency Call
    ...    784 M55144C00502 SUCC_IRATHO_EMERGENCY      Number of Successful inter-RAT handover for IMS Emergency Call
    ...    784 M55144C00503 IRATHO_PREP_EMERGENCY_SENT Number of Successful Preparation of inter-RAT Handover for Emergency call
    [Tags]    B022    QC_82872
    clear counter files
    UE1 Setup VoNR Call And Emergency Call Then Trigger Inter-RAT HO    ue_id=1
    check counters    ${Counters_B022}
    Config gNB and AMF UE2 Setup VoNR Call And Emergency Call Then Trigger Inter-RAT HO    ue_id=2
    Config gNB and AMF UE3 Setup VoNR Call And Emergency Call Then Trigger Inter-RAT HO    ue_id=3
    Config gNB and AMF UE4 Setup VoNR Call And Emergency Call Then Trigger Inter-RAT HO    ue_id=4
    check wireshark log    ${CURDIR}${/}a2a_B022${/}a2a.ini

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fdd_sansa_cmwv/2cells
    Comment    Debug Enter Into Egate

Modify Cfg
    Update Cfg    set_qosflow id=1 5qi=5 default=on
    Update Cfg    set_qosflow id=2 5qi=1
    Update Cfg    set_qosflow id=3 5qi=2
    Update Cfg    set_qosflow id=4 5qi=9
    Update Cfg    set_qosrule id=1 proto=tcp qos_flow=1
    Update Cfg    set_qosrule id=2 proto=udp qos_flow=2
    Update Cfg    set_qosrule id=3 proto=udp qos_flow=3
    Update Cfg    set_nwslice id=1 snssai=0x01:0xD143A5 default=on ue=1-6 amf=1 qos_flows=3,2,1 qos_rules=1,2
    Update Cfg    set_nwslice id=2 snssai=0x01:0xD143A6 ue=1-6 amf=1 qos_flows=1,2,4 qos_rules=1,2
    Update Cfg    set_nwslice id=3 snssai=0x01:0xD143A7 ue=1-6 amf=1
    Update Cfg    set_nwslice id=4 snssai=0x01:0xD143A8 ue=1-6 amf=1
    Update Cfg    set_amf_region id=1 tac_list=0,100,258,788 plmn=311:489,311:402
    Update Cfg    ue_nr_capabilities id=1-6 voice_over_nr=on:on:off
    Update Cfg    ue_param id=1-10 nr_usage_setting=voice_centric ue_nr_capabilities=${UE_nr_sa_capability}
    Update Cfg    amf_param id=1 full_nas_auth=on nia=null+aes nea=null+aes voice_fallback=off ims_voice_3gpp=on
    Update Cfg    set_upf id=1 daemon=10.0.2.1:22222 type=simulated addr=10.12.2.1/24 ngu=10.0.1.1
    Update Cfg    set_amf id=1 daemon=10.0.2.1:22222 ng=10.0.1.1:38412 region=1 set_id=2 pointer=2
    Update Cfg    set_pdu_gateway id=3 ue_nat_ip=72.23.0.3 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=4 ue_nat_ip=72.23.0.4 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=5 ue_nat_ip=72.23.0.5 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=6 ue_nat_ip=72.23.0.6 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=51 ue_nat_ip=72.23.0.51 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=52 ue_nat_ip=72.23.0.52 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
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
    ${sim_gNB5}    catenate    set_gnb id=5 type=simulated plmn=311:402 ng=10.0.1.123 gnb_id=0x24:22 daemon=10.0.2.1:22222 x2_peers=none
    ...    nssai=0x01:0xd143a5,0x01:0xd143a6
    Update Cfg    ${sim_gNB5}
    Update Cfg    set_cell id=1 gnb=5 pci=3:2 nrci=0x1 tac=100 proxy=10.0.2.92:8889 earfcn=1400:19400 technology=lte tdd_cell=off
    ${GNB2}    catenate    set_gnb id=2 type=external plmn=311:489 s1u=10.0.1.2 x2=10.0.1.2:36422 ng=10.0.1.2 gnb_id=0x1:22 daemon=10.0.2.1:22222
    ...    xn=10.0.1.2 x2_peers=none amf=1
    Update Cfg    ${GNB2}
    ${GNB2_cell1}    catenate    set_cell id=1 gnb=2 pci=20:0 tac=788 nrci=0x01 eci=0x000021f tdd_cell=off proxy=10.0.2.80:9999|10.0.2.80:8888
    ...    nr_arfcn=136100:126900 gscn=1587
    ${GNB2_cell2}    catenate    set_cell id=2 gnb=2 pci=20:1 tac=788 nrci=0x02 eci=0x000021f tdd_cell=off proxy=10.0.2.80:9999|10.0.2.80:8888
    ...    nr_arfcn=136100:126900 gscn=1587
    Update Cfg    ${GNB2_cell1}
    Update Cfg    ${GNB2_cell2}

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be Onair    check_sib=${False}

Config AMF1 MRL With Restrict For UE
    [Arguments]    ${ue_id}=1    ${equiv_plmn}=311:402    ${sa_plmn}=311:402    ${not_allowed_tacs}=100    ${restricted_plmn}=311:402
    ...    ${restricted_rat}=eutra
    ${cmd1}    Catenate    amf_mobility_restriction_list_param id\=1 equiv_plmn\=${equiv_plmn} sa_plmn\=${sa_plmn}
    ...    not_allowed_tacs\=${not_allowed_tacs} restricted_plmn=${restricted_plmn} restricted_rat=${restricted_rat}
    Execute Egate Command     ${cmd1}
    Execute Egate Command     amf_mobility_restriction_list_param id=1    pass_regexp=${sa_plmn}
    Execute Egate Command     amf_ue_ics_param id=1 ue=${ue_id} mobility_restriction_list_id=1

Config AMF1 MRL For UE
    [Arguments]    ${ue_id}=1    ${equiv_plmn}=311:402     ${sa_plmn}=311:402    ${not_allowed_tacs}=100
    ...    ${fa_plmn}=311:409     ${forbidden_tacs}=311
    ${cmd1}    Catenate    amf_mobility_restriction_list_param id\=1 equiv_plmn\=${equiv_plmn}
    ...    sa_plmn\=${sa_plmn} not_allowed_tacs\=${not_allowed_tacs} fa_plmn=${fa_plmn} forbidden_tacs=${forbidden_tacs}
    Execute Egate Command    ${cmd1}
    Execute Egate Command    amf_mobility_restriction_list_param id=1    pass_regexp=${sa_plmn}
    Execute Egate Command    amf_ue_ics_param id=1 ue=${ue_id} mobility_restriction_list_id=1

UE1 Setup VoNR Call And Emergency Call Then Trigger Inter-RAT HO
    [Arguments]     ${ue_id}=1
    Start To Capture Wireshark Log    UE${ue_id}_log
    Set qosflow priority and smf param reset    priority=15
    Trigger UE register and setup PDU session and check A2    ue_id=${ue_id}    pdu_id=1    gw=1    fiveQI=5
    Trigger UE 5QI add successfully with PDU session modify and check A2    ue_id=${ue_id}    pdu_id=1    fiveQI=1    qosflows_to_add=2
    Set qosflow priority and smf param    add_qosflows_to_activate=2    priority=1
    Trigger UE 5QI5 and 5QI1 setup successfully with same PDU NGAP procedure    ue_id=${ue_id}    pdu_id=2    gw=2
    ...    request_type=initial-emergency-request
    Trigger UE Inter-RAT HO    ue_id=${ue_id}
    release ues    ue_type=all
    [Teardown]    Stop Capture Wireshark Log    UE${ue_id}_log

Config gNB and AMF UE2 Setup VoNR Call And Emergency Call Then Trigger Inter-RAT HO
    [Arguments]    ${ue_id}=2
    Start To Capture Wireshark Log    UE${ue_id}_log
    OnlineParamChange    ${MrListIgnore_T_PlmnHoAllowed_T}
    Config AMF1 MRL With Restrict For UE    ue_id=${ue_id}    equiv_plmn=311:401     sa_plmn=311:489    not_allowed_tacs=100
    ...    restricted_plmn=311:402    restricted_rat=eutra
    Set qosflow priority and smf param    add_qosflows_to_activate=2    priority=15
    Trigger UE register and setup PDU session with 2 Qosflows    ue_id=${ue_id}    pdu_id=1    gw=3    request_type=initial-request    fiveQI=5
    Set qosflow priority and smf param reset    priority=1
    Trigger UE 5QI5 setup successfully with PDU    ue_id=${ue_id}    pdu_id=2    nwslice=1    gw=4    request_type=initial-emergency-request
    Trigger UE 5QI add successfully with PDU session modify    ue_id=${ue_id}    pdu_id=2    fiveQI=1    qosflows_to_add=2
    Trigger UE Inter-RAT HO    ue_id=${ue_id}
    release ues    ue_type=all
    [Teardown]     Stop Capture Wireshark Log    UE${ue_id}_log

Config gNB and AMF UE3 Setup VoNR Call And Emergency Call Then Trigger Inter-RAT HO
    [Arguments]     ${ue_id}=3
    Start To Capture Wireshark Log    UE${ue_id}_log
    OnlineParamChange    ${MrListIgnore_F_PlmnHoAllowed_T}
    Config AMF1 MRL For UE    ue_id=${ue_id}    equiv_plmn=311:402     sa_plmn=311:489    not_allowed_tacs=100
    Set qosflow priority and smf param reset    priority=15
    Trigger UE register and setup PDU session and check A2     ue_id=${ue_id}    pdu_id=1    gw=5    request_type=initial-request    fiveQI=5
    Set qosflow priority and smf param reset    priority=1
    Trigger UE 5QI5 setup successfully with PDU noA2info    ue_id=${ue_id}    pdu_id=2    nwslice=1    gw=6    request_type=initial-emergency-request
    Trigger UE 5QI add successfully with PDU session modify and check A2    ue_id=${ue_id}    pdu_id=2
    Trigger UE Inter-RAT HO    ue_id=${ue_id}
    release ues    ue_type=all
    [Teardown]     Stop Capture Wireshark Log    UE${ue_id}_log

Config gNB and AMF UE4 Setup VoNR Call And Emergency Call Then Trigger Inter-RAT HO
    [Arguments]     ${ue_id}=4
    Start To Capture Wireshark Log    UE${ue_id}_log
    OnlineParamChange    ${MrListIgnore_T_PlmnHoAllowed_T_Act_InterFHo}
    Config AMF1 MRL With Restrict For UE    ue_id=${ue_id}    equiv_plmn=311:401     sa_plmn=311:489    not_allowed_tacs=100
    ...    restricted_plmn=311:402    restricted_rat=eutra
    Set qosflow priority and smf param reset    priority=15
    Trigger UE register and setup PDU session    ue_id=${ue_id}    pdu_id=1    gw=51    request_type=initial-request    fiveQI=5
    Trigger UE 5QI add successfully with PDU session modify    ue_id=${ue_id}    pdu_id=1    fiveQI=1    qosflows_to_add=2
    Set qosflow priority and smf param    add_qosflows_to_activate=2    priority=1
    Trigger UE 5QI5 and 5QI1 setup successfully with same PDU NGAP procedure and check A2    ue_id=${ue_id}    pdu_id=2    nwslice=1    gw=52
    ...    request_type=initial-emergency-request
    Trigger UE Inter-RAT HO    ue_id=${ue_id}
    release ues    ue_type=all
    [Teardown]     Stop Capture Wireshark Log    UE${ue_id}_log

Set qosflow priority and smf param reset
    [Arguments]     ${priority}=15
    Execute Egate Command    qosflow_modify qos_flow=1 priority=${priority}
    Execute Egate Command    qosflow_modify qos_flow=2 priority=${priority}
    Execute Egate Command    qosflow_modify qos_flow=3 priority=${priority}
    Execute Egate Command    qosflow_modify qos_flow=4 priority=${priority}
    Execute Egate Command    smf_param id=1 reset

Set qosflow priority and smf param
    [Arguments]    ${add_qosflows_to_activate}=2    ${priority}=1
    Execute Egate Command    qosflow_modify qos_flow=1 priority=${priority}
    Execute Egate Command    qosflow_modify qos_flow=2 priority=${priority}
    Execute Egate Command    qosflow_modify qos_flow=3 priority=${priority}
    Execute Egate Command    qosflow_modify qos_flow=4 priority=${priority}
    Execute Egate Command    smf_param id=1 additional_qosflows_to_activate=${add_qosflows_to_activate}

Trigger UE register and setup PDU session
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${nwslice}=1    ${gw}=1    ${request_type}=initial-request    ${fiveQI}=9
    ...    ${cipheringAlgorithm}=nea2
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Registered    timeout=20s
    ${cmd}    Catenate    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} nwslice=${nwslice} gw=${gw} request_type=${request_type}
    ${ret1}=    Execute Egate Command    ${cmd}    QoS Routing Table    timeout=20s
    Should Contain    ${ret1}=    securityModeCommand
    Should Contain    ${ret1}=    cipheringAlgorithm ${cipheringAlgorithm}
    Should Contain    ${ret1}=    Initial Context Setup Successful for UE with AMF UE
    Should Contain    ${ret1}=    Setup QosFlow with QFI:1 5QI:${fiveQI}

Trigger UE register and setup PDU session and check A2
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${nwslice}=1    ${gw}=1    ${request_type}=initial-request    ${fiveQI}=5
    ...    ${cipheringAlgorithm}=nea2
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Registered    timeout=20s
    ${cmd}    Catenate    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} nwslice=${nwslice} gw=${gw} request_type=${request_type}
    ${ret1}=    Execute Egate Command    ${cmd}    QoS Routing Table    timeout=20s
    Should Contain    ${ret1}=    securityModeCommand
    Should Contain    ${ret1}=    cipheringAlgorithm ${cipheringAlgorithm}
    Should Contain    ${ret1}=    Initial Context Setup Successful for UE with AMF UE
    Should Contain    ${ret1}=    Setup QosFlow with QFI:1 5QI:${fiveQI}
    Should Contain    ${ret1}=    a2-Threshold rsrp : 34
    Should Contain    ${ret1}=    hysteresis 0
    Should Contain    ${ret1}=    timeToTrigger ms480

Trigger UE register and setup PDU session with 2 Qosflows
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${nwslice}=1    ${gw}=1    ${request_type}=initial-request    ${fiveQI}=5
    ...    ${cipheringAlgorithm}=nea2
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Registered    timeout=20s
    ${cmd}    Catenate    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} nwslice=${nwslice} gw=${gw} request_type=${request_type}
    ${ret1}=    Execute Egate Command    ${cmd}    QoS Routing Table    timeout=20s
    Should Contain    ${ret1}=    securityModeCommand
    Should Contain    ${ret1}=    cipheringAlgorithm ${cipheringAlgorithm}
    Should Contain    ${ret1}=    Initial Context Setup Successful for UE with AMF UE
    Should Contain    ${ret1}=    Setup QosFlow with QFI:1 5QI:${fiveQI}
    Should Contain    ${ret1}=    Setup QosFlow with QFI:2 5QI:1

Trigger UE 5QI add successfully with PDU session modify and check A2
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${fiveQI}=1    ${qosflows_to_add}=2
    ${ret1}=    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_add=${qosflows_to_add} by=amf
   ...    Pdu Session Resource Modify Response Message with RAN UE NGAP ID [0-9]* handled successfully    timeout=20s
    Should Contain    ${ret1}=    rrcReconfiguration
    Should Contain    ${ret1}=    Added QosFlow with QFI:${qosflows_to_add} 5QI:${fiveQI}
    Should Contain    ${ret1}=    a2-Threshold rsrp : 35
    Should Contain    ${ret1}=    hysteresis 1
    Should Contain    ${ret1}=    timeToTrigger ms512

Trigger UE 5QI add successfully with PDU session modify
    [Arguments]    ${ue_id}=1    ${pdu_id}=2    ${fiveQI}=1    ${qosflows_to_add}=2
    ${ret1}=    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_add=${qosflows_to_add} by=amf
   ...    Pdu Session Resource Modify Response Message with RAN UE NGAP ID [0-9]* handled successfully    timeout=20s
    Should Contain    ${ret1}=    rrcReconfiguration
    Should Contain    ${ret1}=    Added QosFlow with QFI:${qosflows_to_add} 5QI:${fiveQI}

Trigger UE 5QI5 and 5QI1 setup successfully with same PDU NGAP procedure
    [Arguments]    ${ue_id}=1    ${pdu_id}=2    ${nwslice}=1    ${gw}=3    ${request_type}=initial-emergency-request
    ${ret1}=    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} nwslice=${nwslice} gw=${gw} request_type=${request_type}
    ...    Pdu Session Resource Setup Response Message with RAN UE NGAP ID [0-9]* handled successfully    timeout=20s
    Should Contain    ${ret1}=    rrcReconfiguration
    Should Contain    ${ret1}=    Setup QosFlow with QFI:1 5QI:5
    Should Contain    ${ret1}=    Setup QosFlow with QFI:2 5QI:1
    Should Contain    ${ret1}=    handled successfully

Trigger UE 5QI5 and 5QI1 setup successfully with same PDU NGAP procedure and check A2
    [Arguments]    ${ue_id}=1    ${pdu_id}=2    ${nwslice}=1    ${gw}=3    ${request_type}=initial-emergency-request
    ${ret1}=    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} nwslice=${nwslice} gw=${gw} request_type=${request_type}
    ...    Pdu Session Resource Setup Response Message with RAN UE NGAP ID [0-9]* handled successfully    timeout=20s
    Should Contain    ${ret1}=    rrcReconfiguration
    Should Contain    ${ret1}=    Setup QosFlow with QFI:1 5QI:5
    Should Contain    ${ret1}=    Setup QosFlow with QFI:2 5QI:1
    Should Contain    ${ret1}=    handled successfully
#    Should Contain    ${ret1}=    a2-Threshold rsrp : 35
#    Should Contain    ${ret1}=    hysteresis 1
#    Should Contain    ${ret1}=    timeToTrigger ms512

Trigger UE Inter-RAT HO
    [Arguments]    ${ue_id}=1
    ${A2_meas_id}    get nr meas id for specific type and frequency    ue_id=${ue_id}    carrierfreq=126990    event_type=A2
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${A2_meas_id} event=A2 srsrp_nr=7 srsrq_nr=7 srs_result=0:7:7:0
    ...    phycell_id=60 nrsrp_nr=30 nrsrq_nr=30 rs_type=ssb index=0 nrs_result=30:30:0
    ${ret1}=    Execute Egate Command    ${cmd}    rrcReconfiguration    timeout=20s
    ${B2_meas_id}    get nr meas id for specific type and frequency    ue_id=${ue_id}    carrierfreq_rat=EUTRA    carrierfreq=1400    event_type=B2
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${B2_meas_id} event=B2 srsrp_nr=11 srsrq_nr=11 srs_result=0:11:11:0
    ...    phycell_id=11 nrsrp_nr=30 nrsrq_nr=30 rs_type=ssb index=0 nrs_result=30:30:0
    ${ret1}=    Execute Egate Command    ${cmd}    pass_regexp=Successful handover from EXT_ENB-2.1 to ENB-5.1

Trigger UE 5QI5 setup successfully with PDU
    [Arguments]    ${ue_id}=1    ${pdu_id}=2    ${nwslice}=2    ${gw}=3    ${request_type}=initial-emergency-request
    ${ret1}=    Execute Egate Command
    ...    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} nwslice=${nwslice} gw=${gw} request_type=${request_type}
    ...    Pdu Session Resource Setup Response Message with RAN UE NGAP ID [0-9]* handled successfully    timeout=20s
    Should Contain    ${ret1}=    rrcReconfiguration
    Should Contain    ${ret1}=    Setup QosFlow with QFI:1 5QI:5
    Should Contain    ${ret1}=    a2-Threshold rsrp : 35
    Should Contain    ${ret1}=    hysteresis 1
    Should Contain    ${ret1}=    timeToTrigger ms512

Trigger UE 5QI5 setup successfully with PDU noA2info
    [Arguments]    ${ue_id}=1    ${pdu_id}=2    ${nwslice}=2    ${gw}=3    ${request_type}=initial-emergency-request
    ${ret1}=    Execute Egate Command
    ...    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} nwslice=${nwslice} gw=${gw} request_type=${request_type}
    ...    Pdu Session Resource Setup Response Message with RAN UE NGAP ID [0-9]* handled successfully    timeout=20s
    Should Contain    ${ret1}=    rrcReconfiguration
    Should Contain    ${ret1}=    Setup QosFlow with QFI:1 5QI:5

