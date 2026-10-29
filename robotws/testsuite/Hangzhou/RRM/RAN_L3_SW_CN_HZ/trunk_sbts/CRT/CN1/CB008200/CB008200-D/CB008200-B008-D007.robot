*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    RAN_5G_FDD    SBTS00    team-Rock_SGT&A    owner-ha.zheng
...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    CRT    STATE_CONFIGURED    RAN_5G
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
...    @{Intrafrequency_Intra_Gnb_Handover}
...    @{Intrafrequency_Intra_Inter_Gnb_HO}
...    @{Inter_RAT_Handover}
...    @{rrc_Reestablish}
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
...    NRPMRNL-1/NRPMQAP-1:cfg5qiRange=9
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
...    NRPMRNL-1/NRPMQAP-3:cfgArpRange=15,1
...    NRPMRNL-1/NRPMQAP-3:cfgPlmnId:mncLength=2
...    NRPMRNL-1/NRPMQAP-3:cfgPlmnId:mcc=460
...    NRPMRNL-1/NRPMQAP-3:cfgPlmnId:mnc=02
...    NRPMRNL-1/NRPMQAP-4:cfgProfType=SA
...    NRPMRNL-1/NRPMQAP-4:cfgArpRange=15,1
...    NRPMRNL-1/NRPMQAP-4:cfgSliceId:sst=1
...    NRPMRNL-1/NRPMQAP-4:cfgSliceId:sd=13714342
@{Intrafrequency_Intra_Gnb_Handover}
...    NRBTS:actIntraFreqHoSA=true
...    NRPMRNL-1:miNrRelReportCu=15min
...    NRCELL:a3MeasEnabled=rsrp
@{Intrafrequency_Intra_Inter_Gnb_HO}
...    NRBTS:actIncXn=true
...    NRADJGNB-1:administrativeState=Unlocked
...    NRADJGNB-1:gNodeBId=35
...    NRADJGNB-1:gNbIdLength=22
...    NRADJGNB-1:xnLinkRef=1
...    NRADJGNB-1:gnbPlmn:mncLength=3
...    NRADJGNB-1:gnbPlmn:mcc=311
...    NRADJGNB-1:gnbPlmn:mnc=489
...    XNLINK-1:cPlaneIpAddr=10.0.1.124
...    NRCELL/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL/NRREL-2:gNbId=35
...    NRCELL/NRREL-2:gNbIdLength=22
...    NRCELL/NRREL-2:handoverAllowedSA=allowed
...    NRCELL/NRREL-2:removeNotAllowed=false
...    NRCELL/NRREL-2:lcrId=1
...    NRCELL/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL/NRREL-2:gnbPlmn:mcc=311
...    NRCELL/NRREL-2:gnbPlmn:mnc=489
...    NRADJNRCELL-1:cellDepType=SA
...    NRADJNRCELL-1:gNbId=35
...    NRADJNRCELL-1:lcrId=1
...    NRADJNRCELL-1:nrarfcn=636666
...    NRADJNRCELL-1:physCellId=381
...    NRADJNRCELL-1:gNbIdLength=22
...    NRADJNRCELL-1:fiveGsTac=0
...    NRADJNRCELL-1:gnbPlmn:mncLength=3
...    NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRADJNRCELL-1:gnbPlmn:mnc=489
@{Inter_RAT_Handover}
...    NRBTS:actInterFreqHoSA=true
#...    NRBTS:raTypeList=eutra
...    NRBTS:actMFBIEutra=true
...    NRBTS:actInterRatHoSA=true

...    NRBTS:excludedEutranCellPeriod=10
...    NRBTS:excludedEutranCellThreshold=5
...    NRBTS:excludedEutranCellTimeWindow=10
...    NRCELL:a1MeashoEnabledSA=rsrpCombined
...    NRCELL:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRCELL:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=34
...    NRCELL:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL:a1MeashoSsbRsrqSA:a1HysteresishoSsbRsrqSA=0
...    NRCELL:a1MeashoSsbRsrqSA:a1ThresholdhoSsbRsrqSA=31
...    NRCELL:a1MeashoSsbRsrqSA:a1TimeToTriggerhoSsbRsrqSA=ms480
...    NRCELL:a2MeashoEnabledSA=rsrp
...    NRCELL:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=2
...    NRCELL:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=34
...    NRCELL:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL:a2MeashoSsbRsrqSA:a2HysteresishoSsbRsrqSA=2
...    NRCELL:a2MeashoSsbRsrqSA:a2ThresholdhoSsbRsrqSA=31
...    NRCELL:a2MeashoSsbRsrqSA:a2TimeToTriggerhoSsbRsrqSA=ms480
...    NRCELL:nrhoirDNList=MRBTS-1/NRBTS-1/NRHOIR-1
...    NRCELL:absThreshSsbRsrpConsolidation=1
...    NRCELL:absThreshSsbRsrqConsolidation=1
...    NRCELL:measGapSelectionSA=favourUeThroughput
...    NRCELL:a1MeashoEnabled=rsrp
...    NRCELL:a2MeashoEnabled=none
...    NRCELL:a1MeashoSsbRsrp:a1ThresholdhoSsbRsrp=34
...    NRCELL:a2MeashoSsbRsrp:a2ThresholdhoSsbRsrp=34
...    NRHOIR-1:earfcnValue=1400
...    NRHOIR-1:presenceAntennaPort1=false
...    NRHOIR-1:reportAmount=r8
...    NRHOIR-1:reportInterval=ms240
...    NRHOIR-1:b2MeashoEnabled=rsrp
...    NRHOIR-1:b2Threshold1hoRsrp=35
...    NRHOIR-1:b2Threshold1hoRsrq=50
...    NRHOIR-1:b2Threshold1hoRsrpVoNr=35
...    NRHOIR-1:allowedMeasBandwidth=mbw50
...    NRHOIR-1:eutraFreqQOffsetRange=0dB
...    NRHOIR-1:eutraB2MeashoRsrp:b2HysteresishoRsrp=0
...    NRHOIR-1:eutraB2MeashoRsrp:b2Threshold2hoRsrp=18
...    NRHOIR-1:eutraB2MeashoRsrp:b2TimeToTriggerhoRsrp=ms480
...    NRHOIR-1:eutraB2MeashoRsrq:b2HysteresishoRsrq=0
...    NRHOIR-1:eutraB2MeashoRsrq:b2Threshold2hoRsrq=2
...    NRHOIR-1:eutraB2MeashoRsrq:b2TimeToTriggerhoRsrq=ms480
...    NRHOIR-1:eutraB2MeashoRsrp:b2HysteresishoRsrpVoNr=0
...    NRHOIR-1:eutraB2MeashoRsrp:b2Threshold2hoRsrpVoNr=18
...    NRHOIR-1:eutraB2MeashoRsrp:b2TimeToTriggerhoRsrpVoNr=ms480
...    NRBTS-1/NRADJECELL-1:eNodeBId=18
...    NRBTS-1/NRADJECELL-1:ePSTrackingAreaCode=100
...    NRBTS-1/NRADJECELL-1:earfcnValue=1400
...    NRBTS-1/NRADJECELL-1:lcrId=1
...    NRBTS-1/NRADJECELL-1:physCellId=11
...    NRBTS-1/NRADJECELL-1:ecgiPlmn:mcc=311
...    NRBTS-1/NRADJECELL-1:ecgiPlmn:mnc=489
...    NRBTS-1/NRADJECELL-1:ecgiPlmn:mncLength=3
...    NRBTS-1/NRADJECELL-1:enbPlmn:mcc=311
...    NRBTS-1/NRADJECELL-1:enbPlmn:mnc=489
...    NRBTS-1/NRADJECELL-1:enbPlmn:mncLength=3
...    NRCELL/NRRELE-1:cellIndividualOffset=0dB
...    NRCELL/NRRELE-1:eNodeBId=18
...    NRCELL/NRRELE-1:eutranCellExcluded=false
...    NRCELL/NRRELE-1:lcrId=1
...    NRCELL/NRRELE-1:ecgiPlmn:mcc=311|mncLength=3
...    NRCELL/NRRELE-1:ecgiPlmn:mnc=489|mncLength=3
...    NRCELL/NRRELE-1:ecgiPlmn:mncLength=3
${NG_FLOW_SESSION_DUR_NORM_5QI1}    M55125C09526
${NG_FLOW_CONNECTED_SESSION_TIME}    M55125C09516
${NG_FLOW_REL_IANR_SUC_HO_5QI1}    M55125C09508
${NG_FLOW_REL_IANR_SUC_HO_PMQAP}    M55163C00515
${NG_FLOW_REL_IANR_SUC_HO}    M55125C09015
${NG_FLOW_REL_IRAT_SUC_HO_5QI1}    M55125C09509
${NG_FLOW_REL_IRAT_SUC_HO_PMQAP}    M55163C00516
${NG_FLOW_REL_IRAT_SUC_HO}    M55125C09016
${NG_FLOW_REL_NORMAL_5QI1}    M55125C09514
${NG_FLOW_REL_ABNORMAL_5QI1}    M55125C09515
${NG_FLOW_REL_AMF_NORMAL_PMQAP}    M55163C00519
${NG_FLOW_REL_AMF_NORMAL_5QI1}    M55125C09512
${NG_FLOW_REL_GNB_RLF_PMQAP}    M55163C00504
${NG_FLOW_REL_GNB_RLF_5QI1}    M55125C09503
${NG_FLOW_REL_AMF_NORMAL_5QI1}    M55125C09512
@{PM_Counters_Check_SA_IntraFre_IntraGNB_HO_Succeed_And_Drop}
...    NRCELL-1:${NG_FLOW_REL_IANR_SUC_HO_5QI1}=0
...    NRCELL-1:${NG_FLOW_REL_IANR_SUC_HO}=1                             
...    NRCELL-1/PLMN-PLMN/NRPMQAP-1:${NG_FLOW_REL_IANR_SUC_HO_PMQAP}=1    
...    NRCELL-1/PLMN-PLMN/NRPMQAP-2:${NG_FLOW_REL_IANR_SUC_HO_PMQAP}=0
...    NRCELL-1/PLMN-PLMN/NRPMQAP-3:${NG_FLOW_REL_IANR_SUC_HO_PMQAP}=0
...    NRCELL-1/PLMN-PLMN/NRPMQAP-4:${NG_FLOW_REL_IANR_SUC_HO_PMQAP}=0
...    NRCELL-1:${NG_FLOW_CONNECTED_SESSION_TIME}>1                       
...    NRCELL-1:${NG_FLOW_REL_AMF_NORMAL_PMQAP}=0
...    NRCELL-2/PLMN-PLMN/NRPMQAP-1:${NG_FLOW_REL_IANR_SUC_HO_PMQAP}=0
...    NRCELL-2/PLMN-PLMN/NRPMQAP-2:${NG_FLOW_REL_IANR_SUC_HO_PMQAP}=0
...    NRCELL-2/PLMN-PLMN/NRPMQAP-3:${NG_FLOW_REL_IANR_SUC_HO_PMQAP}=0
...    NRCELL-2/PLMN-PLMN/NRPMQAP-4:${NG_FLOW_REL_IANR_SUC_HO_PMQAP}=0
...    NRCELL-2/PLMN-PLMN/NRPMQAP-1:${NG_FLOW_REL_GNB_RLF_PMQAP}=0
...    NRCELL-2/PLMN-PLMN/NRPMQAP-2:${NG_FLOW_REL_GNB_RLF_PMQAP}=0
...    NRCELL-2:${NG_FLOW_REL_IANR_SUC_HO}=0
...    NRCELL-2:${NG_FLOW_REL_GNB_RLF_5QI1}=0
...    NRCELL-2:${NG_FLOW_REL_NORMAL_5QI1}=0
@{PM_Counters_Check_SA_IntraFre_InterGNB_HO}
...    NRCELL-1:${NG_FLOW_REL_IANR_SUC_HO_5QI1}=0
...    NRCELL-1:${NG_FLOW_REL_IANR_SUC_HO}=1
...    NRCELL-1/PLMN-PLMN/NRPMQAP-1:${NG_FLOW_REL_IANR_SUC_HO_PMQAP}=1
...    NRCELL-1/PLMN-PLMN/NRPMQAP-2:${NG_FLOW_REL_IANR_SUC_HO_PMQAP}=0
...    NRCELL-1/PLMN-PLMN/NRPMQAP-3:${NG_FLOW_REL_IANR_SUC_HO_PMQAP}=0
...    NRCELL-1/PLMN-PLMN/NRPMQAP-4:${NG_FLOW_REL_IANR_SUC_HO_PMQAP}=0
...    NRCELL-1:${NG_FLOW_CONNECTED_SESSION_TIME}>1
...    NRCELL-1:${NG_FLOW_REL_AMF_NORMAL_PMQAP}=0
@{PM_Counters_Check_SA_InterRAT_HO}
...    NRCELL-1:${NG_FLOW_REL_IRAT_SUC_HO_5QI1}=0
...    NRCELL-1:${NG_FLOW_REL_IRAT_SUC_HO}=1  
...    NRCELL-1/PLMN-PLMN/NRPMQAP-1:${NG_FLOW_REL_IRAT_SUC_HO_PMQAP}=1
...    NRCELL-1/PLMN-PLMN/NRPMQAP-2:${NG_FLOW_REL_IRAT_SUC_HO_PMQAP}=0
...    NRCELL-1/PLMN-PLMN/NRPMQAP-3:${NG_FLOW_REL_IRAT_SUC_HO_PMQAP}=0
...    NRCELL-1/PLMN-PLMN/NRPMQAP-4:${NG_FLOW_REL_IRAT_SUC_HO_PMQAP}=0
...    NRCELL-1:${NG_FLOW_CONNECTED_SESSION_TIME}>1
...    NRCELL-1:${NG_FLOW_REL_NORMAL_5QI1}=0
...    NRCELL-1:${NG_FLOW_SESSION_DUR_NORM_5QI1}=0
...    NRCELL-1:${NG_FLOW_REL_AMF_NORMAL_5QI1}=0
...    NRCELL-1:${NG_FLOW_REL_AMF_NORMAL_PMQAP}=1
@{PM_Counters_Check_VoNR_Emergency_IntraFre_IntraGNB_HO_Succeed_And_Drop}
...    NRCELL-1:${NG_FLOW_REL_IANR_SUC_HO_5QI1}=1
...    NRCELL-1:${NG_FLOW_REL_IANR_SUC_HO}=2
...    NRCELL-1/PLMN-PLMN/NRPMQAP-1:${NG_FLOW_REL_IANR_SUC_HO_PMQAP}=0
...    NRCELL-1/PLMN-PLMN/NRPMQAP-2:${NG_FLOW_REL_IANR_SUC_HO_PMQAP}=2
...    NRCELL-1/PLMN-PLMN/NRPMQAP-3:${NG_FLOW_REL_IANR_SUC_HO_PMQAP}=0
...    NRCELL-1/PLMN-PLMN/NRPMQAP-4:${NG_FLOW_REL_IANR_SUC_HO_PMQAP}=0
...    NRCELL-1:${NG_FLOW_CONNECTED_SESSION_TIME}>1
...    NRCELL-1:${NG_FLOW_REL_AMF_NORMAL_PMQAP}=0
...    NRCELL-2/PLMN-PLMN/NRPMQAP-1:${NG_FLOW_REL_IANR_SUC_HO_PMQAP}=0
...    NRCELL-2/PLMN-PLMN/NRPMQAP-2:${NG_FLOW_REL_IANR_SUC_HO_PMQAP}=0
...    NRCELL-2/PLMN-PLMN/NRPMQAP-3:${NG_FLOW_REL_IANR_SUC_HO_PMQAP}=0
...    NRCELL-2/PLMN-PLMN/NRPMQAP-4:${NG_FLOW_REL_IANR_SUC_HO_PMQAP}=0
...    NRCELL-2/PLMN-PLMN/NRPMQAP-1:${NG_FLOW_REL_GNB_RLF_PMQAP}=0
...    NRCELL-2/PLMN-PLMN/NRPMQAP-2:${NG_FLOW_REL_GNB_RLF_PMQAP}=0
...    NRCELL-2:${NG_FLOW_REL_IANR_SUC_HO_5QI1}=0
...    NRCELL-2:${NG_FLOW_REL_IANR_SUC_HO}=0
...    NRCELL-2:${NG_FLOW_REL_GNB_RLF_5QI1}=0
...    NRCELL-2:${NG_FLOW_REL_NORMAL_5QI1}=0
#B006
...    NRCELL-2:${NG_FLOW_STP_ATT_INC_HO}=2
...    NRCELL-2:${NG_FLOW_STP_SUC_INC_HO}=2
...    NRCELL-2:${NG_FLOW_STP_ATT_INC_HO_PMQAP}=2
...    NRCELL-2:${NG_FLOW_STP_SUC_INC_HO_PMQAP}=2
...    NRCELL-2:${NG_FLOW_STP_ATT_INC_HO_5QI1}=1
...    NRCELL-2:${NG_FLOW_STP_SUC_INC_HO_5QI1}=1
...    NRCELL-2:${NG_FLOW_CONNECTED_SESSION_TIME}>1
...    NRCELL-1:${NG_FLOW_SESSION_DUR_NORM_5QI1}>1
@{PM_Counters_Check_VoNR_Emergency_IntraFre_InterGNB_HO}
...    NRCELL-1:${NG_FLOW_REL_IANR_SUC_HO_5QI1}=1
...    NRCELL-1:${NG_FLOW_REL_IANR_SUC_HO}=2
...    NRCELL-1/PLMN-PLMN/NRPMQAP-1:${NG_FLOW_REL_IANR_SUC_HO_PMQAP}=0
...    NRCELL-1/PLMN-PLMN/NRPMQAP-2:${NG_FLOW_REL_IANR_SUC_HO_PMQAP}=2
...    NRCELL-1/PLMN-PLMN/NRPMQAP-3:${NG_FLOW_REL_IANR_SUC_HO_PMQAP}=0
...    NRCELL-1/PLMN-PLMN/NRPMQAP-4:${NG_FLOW_REL_IANR_SUC_HO_PMQAP}=0
...    NRCELL-1:${NG_FLOW_CONNECTED_SESSION_TIME}>1
...    NRCELL-1:${NG_FLOW_REL_AMF_NORMAL_PMQAP}=0
...    NRCELL-1:${NG_FLOW_SESSION_DUR_NORM_5QI1}>0
@{PM_Counters_Check_VoNR_Emergency_InterRAT_HO}
...    NRCELL-1:${NG_FLOW_REL_IRAT_SUC_HO_5QI1}=1
...    NRCELL-1:${NG_FLOW_REL_IRAT_SUC_HO}=2
...    NRCELL-1/PLMN-PLMN/NRPMQAP-1:${NG_FLOW_REL_IRAT_SUC_HO_PMQAP}=0
...    NRCELL-1/PLMN-PLMN/NRPMQAP-2:${NG_FLOW_REL_IRAT_SUC_HO_PMQAP}=2
...    NRCELL-1/PLMN-PLMN/NRPMQAP-3:${NG_FLOW_REL_IRAT_SUC_HO_PMQAP}=0 
...    NRCELL-1/PLMN-PLMN/NRPMQAP-4:${NG_FLOW_REL_IRAT_SUC_HO_PMQAP}=0
...    NRCELL-1:${NG_FLOW_CONNECTED_SESSION_TIME}>1
...    NRCELL-1:${NG_FLOW_SESSION_DUR_NORM_5QI1}>1
...    NRCELL-1:${NG_FLOW_REL_NORMAL_5QI1}=1
...    NRCELL-1/PLMN-PLMN/NRPMQAP-2:${NG_FLOW_REL_AMF_NORMAL_PMQAP}=2
@{PM_Counters_Check_VoNR And_Emergency_IntraFre_IntraGNB_HO_Drop}
...    NRCELL-1:${NG_FLOW_REL_IANR_SUC_HO_5QI1}=0
...    NRCELL-1:${NG_FLOW_REL_IANR_SUC_HO}=0
...    NRCELL-1/PLMN-PLMN/NRPMQAP-1:${NG_FLOW_REL_IANR_SUC_HO_PMQAP}=0
...    NRCELL-1/PLMN-PLMN/NRPMQAP-2:${NG_FLOW_REL_IANR_SUC_HO_PMQAP}=0
...    NRCELL-1/PLMN-PLMN/NRPMQAP-3:${NG_FLOW_REL_IANR_SUC_HO_PMQAP}=0
...    NRCELL-1/PLMN-PLMN/NRPMQAP-4:${NG_FLOW_REL_IANR_SUC_HO_PMQAP}=0
...    NRCELL-1:${NG_FLOW_REL_NORMAL_5QI1}=0
...    NRCELL-1/PLMN-PLMN/NRPMQAP-2:${NG_FLOW_REL_GNB_RLF_PMQAP}=0
...    NRCELL-1:${NG_FLOW_REL_GNB_RLF_5QI1}=0

#B006
${NG_FLOW_STP_ATT_INC_HO}    M55125C09013
${NG_FLOW_STP_SUC_INC_HO}    M55125C09014
${NG_FLOW_STP_ATT_INC_HO_PMQAP}    M55163C00513
${NG_FLOW_STP_SUC_INC_HO_PMQAP}    M55163C00514
${NG_FLOW_STP_ATT_INC_HO_5QI1}    M55125C09524
${NG_FLOW_STP_SUC_INC_HO_5QI1}    M55125C09525
@{PM_Counters_Check_VoNR_IntraFre_InterGNB_HO_Back}
...    NRCELL-1:${NG_FLOW_STP_ATT_INC_HO}=2
...    NRCELL-1:${NG_FLOW_STP_SUC_INC_HO}=2
...    NRCELL-1:${NG_FLOW_STP_ATT_INC_HO_PMQAP}=2
...    NRCELL-1:${NG_FLOW_STP_SUC_INC_HO_PMQAP}=2
...    NRCELL-1:${NG_FLOW_STP_ATT_INC_HO_5QI1}=1
...    NRCELL-1:${NG_FLOW_STP_SUC_INC_HO_5QI1}=1
...    NRCELL-1:${NG_FLOW_CONNECTED_SESSION_TIME}>1
...    NRCELL-1:${NG_FLOW_SESSION_DUR_NORM_5QI1}>1
#B008
@{rrc_Reestablish}
...    NRBTS:rrcReestabTypeSA=sameGNB
${NG_FLOW_STP_ATT_REEST_IADU}    M55125C09023
${NG_FLOW_STP_SUC_REEST_IADU}    M55125C09024
${NG_FLOW_STP_ATT_RES_IADU_PMQAP}    M55163C00530
${NG_FLOW_STP_SUC_RES_IADU_PMQAP}    M55163C00531
${NG_FLOW_STP_ATT_RES_IADU_5QI1}    M55125C09531
${NG_FLOW_STP_SUC_RES_IADU_5QI1}     M55125C09532
${NG_FLOW_SESSION_DUR_ABNRM_5QI1}    M55125C09527
@{PM_Counters_Check_VoNR_Reestablish_succ}
...    NRCELL-1:${NG_FLOW_SESSION_DUR_ABNRM_5QI1}>0
...    NRCELL-1:${NG_FLOW_CONNECTED_SESSION_TIME}>0
...    NRCELL-2:${NG_FLOW_STP_ATT_REEST_IADU}=2
...    NRCELL-2:${NG_FLOW_STP_SUC_REEST_IADU}=2
...    NRCELL-2/PLMN-PLMN/NRPMQAP-2:${NG_FLOW_STP_ATT_RES_IADU_PMQAP}=2
...    NRCELL-2/PLMN-PLMN/NRPMQAP-2:${NG_FLOW_STP_SUC_RES_IADU_PMQAP}=2
...    NRCELL-2:${NG_FLOW_STP_ATT_RES_IADU_5QI1}=1
...    NRCELL-2:${NG_FLOW_STP_SUC_RES_IADU_5QI1}=1
...    NRCELL-2:${NG_FLOW_CONNECTED_SESSION_TIME}>0

*** Test Cases ***
CB008200-ET-B008_Verify Counter when Qos Flow Setup and Setup Success due to Intra DU or Intra-gNB re-establishment
    [Tags]  QC_161092    B008
    [Documentation]
    ...    1. This User scenario is to provide the counters used for measuring SA accessibility.
    ...       The User scenario creates a counter to measure the number of QosFlows that fail to setup due to Connection with Ue Lost.
    ...       The User Scenario is a rerun of multiple User Scenario.
    ...    2. Test Case Steps:
    ...         step1. Set up VONR call in cell1.
    ...         step2. Ue performs RRC reestablishment to new cell2 in the same gnb with cause otherFailure.
    ...         step3. Check related Counters ‘PM_Counters_Check_VoNR_Reestablish_succ’
    VoNR Call Reestablish To New Cell

CB008200-ET-D007_Verify_Related_Counters_when_QosFlow_Release_due_to_HO
    [Tags]  QC_161099    owner-xiaowen.xu
    [Documentation]  Check NG_Flow counters during HO procedue, include intragnb,intergnb,interRAT.
    ...    For intragnb,intergnb , counter name contain IANR(intra NR) , interRAT contain IRAT (inter RAT).
    ...    step1: SA call do handover with intragnb,intergnb,interRAT
    ...    step2: Vonr call do handover with intragnb,intergnb,interRAT
    ...    step3: EC do handover with intragnb,intergnb,interRAT
    ...    step4: Vonr call and EC do handover with  intragnb,intergnb,interRAT
    SA Call Test
    VoNR Call Test
    Emergency Call Test
    VoNR Call And Emergency Call IntraGnb Handover Drop
    run keyword and ignore error  Release Ues    ue_type=all
    sleep    60s

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri    ue_count=15
    #Debug Enter Into Egate

Modify Cfg 
    Update Cfg    set_qosflow id=1 5qi=5 default=on
    Update Cfg    set_qosflow id=3 5qi=9
    Update Cfg    set_qosflow id=2 5qi=1 ue=1-12
    Update Cfg    set_qosrule id=1 proto=tcp qos_flow=1
    Update Cfg    set_qosrule id=2 proto=udp qos_flow=2
    Update Cfg    set_nwslice id=1 snssai=0x01:0xD143A5 default=on ue=1-12 qos_flows=3,2,1 qos_rules=1,2 amf=1-6
    Update Cfg    ue_nr_capabilities id=1-12 voice_over_nr=on:on:off
    Update Cfg    amf_param id=1 full_nas_auth=on ims_voice_3gpp=on nia=null+zuc nea=null+zuc
    Update Cfg    set_nwslice id=2 snssai=0x01:0xD143A6 ue=1-12 qos_flows=3,2,1 qos_rules=1,2 amf=1-6
    ${gnb3_info}    Catenate
    ...    set_gnb id=3 type=simulated plmn=311:489 ng=10.0.1.125 gnb_id=0x23:22 daemon=10.0.2.1:22222 x2_peers=none xn=10.0.1.124
    ...    nssai=0x1:0xd143a5 amf=1
    Update Cfg    ${gnb3_info}
    Update Cfg    set_cell id=1 gnb=3 pci=127:0 tac=0 nrci=0x01 tdd_cell=on proxy=10.0.2.90:9999 nr_arfcn=636666:636666 gscn=7880
    Update Cfg    gnb_param id=3 xn_listening_socket=on send_xn_setup=true
    Update Cfg    enb_param id=1 drb_id_begin=3 endc_capable_qci=all send_ho_ack=on
    Update Cfg    set_gnb id=6 type=simulated plmn=311:489 ng=10.0.1.13 daemon=10.0.2.1:22222 gnb_id=0x12:28 nssai=0x01:0xD143A5 x2_peers=none amf=1
    ${gnb6_cell1_info}    Catenate
    ...    set_cell id=1 gnb=6 pci=3:2 nrci=0x01 tac=100 proxy=10.0.2.1:12218 earfcn=1400:19400 technology=lte tdd_cell=on
    ...    mandatory_for_activation=off
    Update Cfg    ${gnb6_cell1_info}
    Update Cfg    gnb_param id=6 xn_listening_socket=off
    Update Cfg    ue_param id=1-12 nr_usage_setting=voice_centric ue_nr_capabilities=${5qi1_UE_Capabilities}
    Update Cfg    set_pdu_gateway id=7 ue_nat_ip=72.23.6.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1 
    Update Cfg    set_pdu_gateway id=8 ue_nat_ip=72.23.7.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1 
    Update Cfg    set_pdu_gateway id=9 ue_nat_ip=72.23.8.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1 
    Update Cfg    set_pdu_gateway id=10 ue_nat_ip=72.23.9.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1 
    Update Cfg    set_pdu_gateway id=11 ue_nat_ip=72.23.10.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=12 ue_nat_ip=72.23.11.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1

UE Register And Add Pdu With Default 5QI5
    [Arguments]    ${ue_id}    ${type}=${EMPTY}
    Run Keyword If    '${type}'=='emergency'    Execute Egate Command    ue_nr_rrc_setup_param id=${ue_id} establishment_cause=emergency
    Execute Egate Command    ue_register id=${ue_id} nwslice=1  pass_regexp=Received REGISTRATION COMPLETE
    ${cmd}=    Set Variable    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${ue_id}
    ${cmd_emergency}=    Catenate    ${cmd}    request_type=initial-emergency-request
    ${ret}=    Run Keyword If    '${type}'=='emergency'    Execute Egate Command    ${cmd_emergency}
    ...    pass_regexp=UE${ue_id}: Ue ${ue_id} PduId 1 Created FiveQi:Qfi mapping fiveQi 5 qfi 1
    ...    ELSE
    ...    Execute Egate Command    ${cmd}    pass_regexp=UE${ue_id}: Ue ${ue_id} PduId 1 Created FiveQi:Qfi mapping fiveQi 5 qfi 1

SA UE Register And Add Pdu With Default 5QI9
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_register id=${ue_id} nwslice=1    pass_regexp=Received REGISTRATION COMPLETE
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${ue_id}
    ...    pass_regexp=UE${ue_id}: Ue ${ue_id} PduId 1 Created FiveQi:Qfi mapping fiveQi 9 qfi 1
  
PDU Add QoSFlow 5QI1
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=2 by=amf    pass_regexp=Added QosFlow with QFI:2 fiveQI:1
	
IntraFre A3 Handover
    [Arguments]    ${ue_id}    ${t_cell_pci}    ${expect_res}    ${fail_flag}=${EMPTY}    ${meas_id}=2
    Run Keyword If    '${fail_flag}'=='drop'    Execute Egate Command    ue_nr_rrc_reconf_param id=${ue_id} if_contains=any action=drop
	${a3cmd}=    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A3 srsrp_nr=9 srsrq_nr=9 phycell_id=${t_cell_pci} nrsrp_nr=30
	...    nrsrq_nr=30    
    Execute Egate Command    ${a3cmd}    pass_regexp=${expect_res}

InterRAT B2 Handover
    [Arguments]    ${ue_id}    ${t_cell_pci}
    ${a2cmd}=    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=1 event=A2 srsrp_nr=7 srsrq_nr=7 srs_result=0:7:7:0 phycell_id=${t_cell_pci}
    ...    nrsrp_nr=30 nrsrq_nr=30 rs_type=ssb index=0 nrs_result=30:30:0
    Execute Egate Command    ${a2cmd}    sleep_time=2
    ${b2cmd}=    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=4 event=B2 srsrp_nr=11 srsrq_nr=11 srs_result=0:11:11:0 
    ...    phycell_id=${t_cell_pci} nrsrp_nr=30 nrsrq_nr=30 rs_type=ssb index=0 nrs_result=30:30:0
    Execute Egate Command    ${b2cmd}    pass_regexp=UE${ue_id}: IRAT Handover from NR to EUTRA completed

SA Call Test
    Execute Egate Command    qosflow_modify qos_flow=3 default=on
    SA Call IntraFrequency IntraGnb Handover Succeed And Drop
    SA Call IntraFrequency InterGnb Handover
    SA Call InterRAT Handover

VoNR Call Test
    Execute Egate Command    qosflow_modify qos_flow=1 default=on
    VoNR Call IntraFrequency IntraGnb Handover Succeed And Drop
    VoNR Call IntraFrequency InterGnb Handover
    VoNR Call InterRAT Handover

Emergency Call Test
    Execute Egate Command    qosflow_modify qos_flow=1 priority=1
    Execute Egate Command    qosflow_modify qos_flow=2 priority=1
    Emergency Call IntraFrequency IntraGnb Handover Succeed And Drop
    Emergency Call IntraFrequency InterGnb Handover
    Emergency Call InterRAT Handover

SA Call IntraFrequency IntraGnb Handover Succeed And Drop
    Start To Capture Wireshark Log    1_1_sa_intra_gnb_ho_succeed_drop
    Clear Counter Files
    SA UE Register And Add Pdu With Default 5QI9    ue_id=1
    IntraFre A3 Handover    ue_id=1    t_cell_pci=51    expect_res=UE1: Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.2 performed
    IntraFre A3 Handover    ue_id=1    t_cell_pci=50    expect_res=UE1: Hit on error cases presence=any action=drop  fail_flag=drop
    Check Counters    ${PM_Counters_Check_SA_IntraFre_IntraGNB_HO_Succeed_And_Drop}
    Check Wireshark Log    ${CURDIR}${/}a2a${/}sa_intra_gnb_ho_succeed_drop.ini    name=1_1_sa_intra_gnb_ho_succeed_drop

SA Call IntraFrequency InterGnb Handover
    Start To Capture Wireshark Log    1_2_sa_inter_gnb_ho
    Clear Counter Files  
    SA UE Register And Add Pdu With Default 5QI9    ue_id=2
    IntraFre A3 Handover    ue_id=2    t_cell_pci=381    expect_res=UE2: Inter-eNB handover from EXT_ENB-2.1 to ENB-3.1 performed
    Check Counters    ${PM_Counters_Check_SA_IntraFre_InterGNB_HO}
    Check Wireshark Log    ${CURDIR}${/}a2a${/}sa_inter_gnb_ho.ini    name=1_2_sa_inter_gnb_ho

SA Call InterRAT Handover
    Start To Capture Wireshark Log    1_3_sa_inter_rat_ho
    Clear Counter Files
    SA UE Register And Add Pdu With Default 5QI9    ue_id=3
    InterRAT B2 Handover    ue_id=3    t_cell_pci=11
    Check Counters    ${PM_Counters_Check_SA_InterRAT_HO}
    Check Wireshark Log    ${CURDIR}${/}a2a${/}sa_inter_rat_ho.ini    name=1_3_sa_inter_rat_ho    #wait_string=UEContextReleaseComplete

VoNR Call IntraFrequency IntraGnb Handover Succeed And Drop
    Start To Capture Wireshark Log    2_1_vonr_intra_gnb_ho_succeed_drop
    Clear Counter Files  
    UE Register And Add Pdu With Default 5QI5    ue_id=4
    PDU Add QoSFlow 5QI1    ue_id=4
    IntraFre A3 Handover    ue_id=4    t_cell_pci=51    expect_res=UE4: Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.2 performed
    IntraFre A3 Handover    ue_id=4    t_cell_pci=50    expect_res=UE4: Hit on error cases presence=any action=drop  fail_flag=drop
    Check Counters    ${PM_Counters_Check_VoNR_Emergency_IntraFre_IntraGNB_HO_Succeed_And_Drop}
    Check Wireshark Log    ${CURDIR}${/}a2a${/}vonr_intra_gnb_ho_succeed_drop.ini    name=2_1_vonr_intra_gnb_ho_succeed_drop

VoNR Call IntraFrequency InterGnb Handover
    Start To Capture Wireshark Log    2_2_vonr_inter_gnb_ho
    Clear Counter Files   
    UE Register And Add Pdu With Default 5QI5    ue_id=5
    PDU Add QoSFlow 5QI1    ue_id=5
    IntraFre A3 Handover    ue_id=5    t_cell_pci=381    expect_res=UE5: Inter-eNB handover from EXT_ENB-2.1 to ENB-3.1 performed
    Check Counters    ${PM_Counters_Check_VoNR_Emergency_IntraFre_InterGNB_HO}
    #B006
    IntraFre A3 Handover    ue_id=5    t_cell_pci=50    meas_id=3    expect_res=UE5: Inter-eNB handover from ENB-3.1 to EXT_ENB-2.1 performed
    Check Counters    ${PM_Counters_Check_VoNR_IntraFre_InterGNB_HO_Back}
    Check Wireshark Log    ${CURDIR}${/}a2a${/}vonr_inter_gnb_ho.ini    name=2_2_vonr_inter_gnb_ho

VoNR Call InterRAT Handover
    Start To Capture Wireshark Log    2_3_vonr_inter_rat_ho
    Clear Counter Files
    UE Register And Add Pdu With Default 5QI5    ue_id=6
    PDU Add QoSFlow 5QI1    ue_id=6
    InterRAT B2 Handover    ue_id=6    t_cell_pci=11
    Check Counters    ${PM_Counters_Check_VoNR_Emergency_InterRAT_HO}
    Check Wireshark Log    ${CURDIR}${/}a2a${/}vonr_inter_rat_ho.ini    name=2_3_vonr_inter_rat_ho

Emergency Call IntraFrequency IntraGnb Handover Succeed And Drop
    Start To Capture Wireshark Log    3_1_emergency_intra_gnb_ho_succeed_drop
    Clear Counter Files
    UE Register And Add Pdu With Default 5QI5    ue_id=7    type=emergency
    PDU Add QoSFlow 5QI1    ue_id=7
    IntraFre A3 Handover    ue_id=7    t_cell_pci=51    expect_res=UE7: Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.2 performed
    IntraFre A3 Handover    ue_id=7    t_cell_pci=50    expect_res=UE7: Hit on error cases presence=any action=drop  fail_flag=drop
    Check Counters    ${PM_Counters_Check_VoNR_Emergency_IntraFre_IntraGNB_HO_Succeed_And_Drop}
    Check Wireshark Log    ${CURDIR}${/}a2a${/}emergency_intra_gnb_ho_succeed_drop.ini    name=3_1_emergency_intra_gnb_ho_succeed_drop

Emergency Call IntraFrequency InterGnb Handover
    Start To Capture Wireshark Log    3_2_emergency_inter_gnb_ho
    Clear Counter Files
    UE Register And Add Pdu With Default 5QI5    ue_id=8    type=emergency
    PDU Add QoSFlow 5QI1    ue_id=8
    IntraFre A3 Handover    ue_id=8    t_cell_pci=381    expect_res=UE8: Inter-eNB handover from EXT_ENB-2.1 to ENB-3.1 performed
    Check Counters    ${PM_Counters_Check_VoNR_Emergency_IntraFre_InterGNB_HO}
    Check Wireshark Log    ${CURDIR}${/}a2a${/}emergency_inter_gnb_ho.ini    name=3_2_emergency_inter_gnb_ho

Emergency Call InterRAT Handover
    Start To Capture Wireshark Log    3_3_emergency_inter_rat_ho
    Clear Counter Files
    UE Register And Add Pdu With Default 5QI5    ue_id=9    type=emergency
    PDU Add QoSFlow 5QI1    ue_id=9
    InterRAT B2 Handover    ue_id=9    t_cell_pci=11
    Check Counters    ${PM_Counters_Check_VoNR_Emergency_InterRAT_HO}
    Check Wireshark Log    ${CURDIR}${/}a2a${/}emergency_inter_rat_ho.ini    name=3_3_emergency_inter_rat_ho
  
VoNR Call And Emergency Call IntraGnb Handover Drop
    Start To Capture Wireshark Log    4_1_both_vonr_emergency_intra_gnb_ho_drop_all
    Clear Counter Files  
    Execute Egate Command    qosflow_modify qos_flow=1 priority=15
    Execute Egate Command    qosflow_modify qos_flow=2 priority=15
    UE Register And Add Pdu With Default 5QI5    ue_id=10
    PDU Add QoSFlow 5QI1    ue_id=10
    Execute Egate Command    qosflow_modify qos_flow=1 priority=1
    Execute Egate Command    qosflow_modify qos_flow=2 priority=1
    UE Register And Add Pdu With Default 5QI5    ue_id=11    type=emergency
    PDU Add QoSFlow 5QI1    ue_id=11
    IntraFre A3 Handover    ue_id=10    t_cell_pci=51    expect_res=UE10: Hit on error cases presence=any action=drop    fail_flag=drop
    Sleep  1s
    IntraFre A3 Handover    ue_id=11    t_cell_pci=51    expect_res=UE11: Hit on error cases presence=any action=drop    fail_flag=drop
    Check Counters    ${PM_Counters_Check_VoNR And_Emergency_IntraFre_IntraGNB_HO_Drop}
    Stop Capture Wireshark Log    4_1_both_vonr_emergency_intra_gnb_ho_drop_all

VoNR Call Reestablish To New Cell
    Start To Capture Wireshark Log    B008
    Clear Counter Files
    Execute Egate Command    qosflow_modify qos_flow=1 default=on
    change ue location to cell    ue_id=12
    UE Register And Add Pdu With Default 5QI5    ue_id=12
    PDU Add QoSFlow 5QI1    ue_id=12
    Trigger Rrc Reestablish    ue_id=12
    Release Ues  ue_type=all
    Check Counters    ${PM_Counters_Check_VoNR_Reestablish_succ}
    Stop Capture Wireshark Log    B008

change ue location to cell
    [Arguments]    ${ue_id}    ${pcell_id}=1    ${enb_id}=2
    ${checkUeLocation}    Execute Egate Command     ue_change_location id=${ue_id} enb=${enb_id} cell=${pcell_id}    location
    Should Contain Any    ${checkUeLocation}    location updated    already there

Trigger Rrc Reestablish
    [Arguments]    ${ue_id}    ${cell_id}=2
    ${ret1}=     Execute Egate Command    ue_rrc_reestablish id=${ue_id} gnb=2 cell=${cell_id} cause=otherFailure
    ...    pass_regexp=rrcReconfigurationComplete
    should contain    ${ret1}    NR RRC Reestablishment sucessfully completed
