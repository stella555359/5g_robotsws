*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    CRT
...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    team-L3CN1_SG14    owner-jiancao    release-SBTS23R4    CB008236
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}    @{CB008236}    @{CB006112}    @{5GC000545}    @{PARAMS_FOR_5QI9}    @{PARAMS_FOR_5QI5}
...    @{PARAMS_FOR_5QI1}    @{PARAMS_FOR_HO}    @{PARAMS_FREQ_FOR_CELL3}    @{CB008311}

@{PARAMS_IN_SWCONFIG}    0x57000B=0xFFFFFFFF    0x57002f=1

${TTITRACE_FLAG}    True
${GNB_BIP_FLAG}    True
${GNB_BIP_SIZE}    2000


@{CB008236}
...    NRCELL-1:actUlSlotAgg=Enabled_VoNr
...    NRCELL-1:actDrxSleepOff=Enabled_VoNr_SAg
...    NRCELL:sCellDeactInPoorRf=Deact_Scells_VoNr_SAg
...    NRCELL-1:ulTransPrecodeCtl:ulSlotAggOffTotPwrThresh=33
...    NRCELL-1:ulTransPrecodeCtl:ulSlotAggOnTotPwrThresh=30
...    NRCELL-1:maxHarqBundlesUlSlotAgg=10
...    NRCELL-1:minTbsUlSlotAgg=384
...    NRCELL-3:actUlSlotAgg=Enabled_VoNr
...    NRCELL-3:actDrxSleepOff=Enabled_VoNr_SAg
...    NRCELL-3:ulTransPrecodeCtl:ulSlotAggOffTotPwrThresh=33
...    NRCELL-3:ulTransPrecodeCtl:ulSlotAggOnTotPwrThresh=30
...    NRCELL-3:maxHarqBundlesUlSlotAgg=10
...    NRCELL-3:minTbsUlSlotAgg=384
...    NRCELL:maxNumPuschAllocationPerSlot=2
@{CB006112}
...    NRCELL-1:actEnhancedVoNR=true
...    NRCELL-1:actAdaptVoipTbs=true
...    NRCELL-1:actCDrxVoNR=true
...    NRCELL-1:actCDrx=true
...    NRCELL-1:actVoNR=true
...    NRCELL-1:drxProfile2:drxLongCycle=40ms
...    NRCELL-1:drxProfile2:drxOnDurationTimer=6ms
...    NRCELL-1:drxProfile2:drxInactivityTimer=6ms
...    NRCELL-1:srPeriodicity=slots40
...    NRCELL-1:periodicCsiAcquisition:csiReportPeriodicity=slots80
...    NRCELL-1:actVoipPacketAggr=true
...    NRCELL-3:actEnhancedVoNR=true
...    NRCELL-3:actAdaptVoipTbs=true
...    NRCELL-3:actCDrxVoNR=true
...    NRCELL-3:actCDrx=true
...    NRCELL-3:actVoNR=true
...    NRCELL-3:drxProfile2:drxLongCycle=40ms
...    NRCELL-3:drxProfile2:drxOnDurationTimer=6ms
...    NRCELL-3:drxProfile2:drxInactivityTimer=6ms
...    NRCELL-3:srPeriodicity=slots40
...    NRCELL-3:periodicCsiAcquisition:csiReportPeriodicity=slots80
...    NRCELL-3:actVoipPacketAggr=true

@{5GC000545}
...    NRCELL-1:actUlDftSOfdm=true
...    NRBTS:actTdraFallback=false
...    NRCELL-1:pucchModeSelect=longPucch
...    NRCELL-1:puschMappingType=TypeB
...    NRCELL-1:ulTransPrecodeCtl:ulTransPrecodeOffSinrThresh=200
...    NRCELL-1:ulTransPrecodeCtl:ulTransPrecodeOnSinrThresh=180
...    NRCELL-3:actUlDftSOfdm=true
...    NRCELL-3:pucchModeSelect=longPucch
...    NRCELL-3:puschMappingType=TypeB
...    NRCELL-3:ulTransPrecodeCtl:ulTransPrecodeOffSinrThresh=200
...    NRCELL-3:ulTransPrecodeCtl:ulTransPrecodeOnSinrThresh=180

@{CB008311}
...    NRBTS:actBufferBasedSCellAddition=oneShot_Dl_Fr1
...    NRCELL-1/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-2:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-2:gNbId=2
...    NRCELL-1/NRREL-2:lcrId=2
...    NRCELL-1/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL:dlSCellConfigLevel=5
...    NRCELL:dlSCellConfigLevelNum=5
...    NRCELL:sCellDeactivationTimerGNB=ms1280
...    NRCELL:sCellInactivityReleaseTimer=300
...    NRBTS:sCellActivationMethod=bufferBased
...    NRBTS:actSCellReleaseForInactiveSCell=timer_based_Fr1

@{PARAMS_FOR_5QI9}
...    NRBTS/NRDRB_5QI-2:fiveqiValueList=6
...    NRBTS/NRDRB_5QI-2:nrDrbDN=MRBTS-2/NRBTS-2/NRDRB-14
...    NRBTS/NRDRB-14:nrDrbMacDN=MRBTS-2/NRBTS-2/NRDRB_MAC-2
...    NRBTS/NRDRB-14:nrDrbPdcpDN=MRBTS-2/NRBTS-2/NRDRB_PDCP-2
...    NRBTS/NRDRB-14:nrDrbRlcAmDN=MRBTS-2/NRBTS-2/NRDRB_RLC_AM-2
...    NRBTS/NRDRB-14:resType=nonGBR
...    NRBTS/NRDRB-14:rlcMode=RLC_AM
...    NRBTS/NRDRB_MAC-2:lcgid=1
...    NRBTS/NRDRB_PDCP-2:cuFlowControlProfId=1
...    NRBTS/NRDRB_RLC_AM-2:duFlowControlProfId=1
@{PARAMS_FOR_5QI5}
...    NRBTS/NRDRB_5QI-1:fiveqiValueList=5
...    NRBTS/NRDRB_5QI-1:nrDrbDN=MRBTS-2/NRBTS-2/NRDRB-10
...    NRBTS/NRDRB-10:nrDrbMacDN=MRBTS-2/NRBTS-2/NRDRB_MAC-3
...    NRBTS/NRDRB-10:nrDrbPdcpDN=MRBTS-2/NRBTS-2/NRDRB_PDCP-2
...    NRBTS/NRDRB-10:nrDrbRlcAmDN=MRBTS-2/NRBTS-2/NRDRB_RLC_AM-2
...    NRBTS/NRDRB-10:resType=nonGBR_Signaling
...    NRBTS/NRDRB-10:rlcMode=RLC_AM
...    NRBTS/NRDRB_MAC-3:lcgid=0
...    NRBTS/NRDRB_MAC-3:schedulPrio=4
@{PARAMS_FOR_5QI1}
...    NRCELL-1:actVoNR=true
...    NRCELL-3:actVoNR=true
...    NRBTS:actNormVCFallback=false
...    NRBTS/NRDRB_5QI-6:fiveqiValueList=1
...    NRBTS/NRDRB_5QI-6:nrDrbDN=MRBTS-2/NRBTS-2/NRDRB-15
...    NRBTS/NRDRB-15:nrDrbMacDN=MRBTS-2/NRBTS-2/NRDRB_MAC-4
...    NRBTS/NRDRB-15:nrDrbPdcpDN=MRBTS-2/NRBTS-2/NRDRB_PDCP-3
...    NRBTS/NRDRB-15:nrDrbRlcUmDN=MRBTS-2/NRBTS-2/NRDRB_RLC_UM-1
...    NRBTS/NRDRB-15:dlFlowControlAlgo=none
...    NRBTS/NRDRB-15:dscp=46
...    NRBTS/NRDRB-15:maxDddsPeriodCpuOvld=40
...    NRBTS/NRDRB-15:numSduDiscard=1
...    NRBTS/NRDRB-15:queuingDelayDiscarding=Disabled
...    NRBTS/NRDRB-15:queuingDelaySduDiscardThreshold=200
...    NRBTS/NRDRB-15:resType=GBR
...    NRBTS/NRDRB-15:rlcMode=RLC_UM
...    NRBTS/NRDRB-15:schedulWeight=1
...    NRBTS/NRDRB-15:sduDiscardIntervalTmr=100
...    NRBTS/NRDRB-15:maxDataRateGbrDl=1000
...    NRBTS/NRDRB-15:maxDataRateGbrUl=1000
...    NRBTS/NRDRB-15:cellAggrLevel=Not FR1 CA eligible
...    NRBTS/NRDRB_MAC-4:lcgid=4
...    NRBTS/NRDRB_MAC-4:schedulPrio=5
...    NRBTS/NRDRB_RLC_UM-1:dlTReassemblyUm=ms40
...    NRBTS/NRDRB_RLC_UM-1:ulTReassemblyUm=ms40
...    NRBTS/NRDRB_PDCP-3:tReorderingDl=ms300
...    NRBTS/NRDRB_PDCP-3:tReorderingUl=ms300
...    NRBTS/NRDRB_PDCP-3:pdcpBufDiscardEnabled=false
...    NRBTS/NRDRB-15:discardTimer=10ms
...    NRBTS/NRDRB-15:maxRlcQueueingDelayGbr=20
...    NRBTS/NRDRB-15:maxTransferDelayGbr=20

@{PARAMS_FOR_HO}
...    NRBTS:actInterFreqHoSA=true
...    NRBTS:actIntraFreqHoSA=true
...    NRBTS/NRPMRNL-1:miNrRelReportCu=5min
...    NRDU-1:carrierAggregationSupportList=ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Any_Sa,ca_Fdd_Any_Sa,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Fdd
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRCELL-1:a1MeashoSsbRsrp:a1ThresholdhoSsbRsrp=34
...    NRCELL-1:a1MeashoSsbRsrp:a1TimeToTriggerhoSsbRsrp=ms480
...    NRCELL-1:a1MeashoSsbRsrp:a1HysteresishoSsbRsrp=0
...    NRCELL-1:a2MeasRedirectSsbRsrp:a2HysteresisRedirectSsbRsrp=0
...    NRCELL-1:a2MeasRedirectSsbRsrp:a2TimeToTriggerRedirectSsbRsrp=ms480
...    NRCELL-1:a2MeasRedirectSsbRsrp:a2ThresholdRedirectSsbRsrp=34
...    NRCELL-1:a2MeashoSsbRsrp:a2HysteresishoSsbRsrp=1
...    NRCELL-1:a2MeashoSsbRsrp:a2ThresholdhoSsbRsrp=34
...    NRCELL-1:a2MeashoSsbRsrp:a2TimeToTriggerhoSsbRsrp=ms480
...    NRCELL-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRCELL-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=15
...    NRCELL-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms40
...    NRCELL-1:a3MeasSsbRsrq:a3HysteresisSsbRsrq=0
...    NRCELL-1:a3MeasSsbRsrq:a3OffsetSsbRsrq=5
...    NRCELL-1:a3MeasSsbRsrq:a3TimeToTriggerSsbRsrq=ms0
...    NRCELL-1:a2MeashoEnabled=rsrp
...    NRCELL-1:a1MeashoEnabled=rsrp
...    NRCELL-1:a1MeashoEnabledSA=rsrp
...    NRCELL-1:a1MeashoSsbRsrpSA:a1HysteresisHoSsbRsrpVoNr=0
...    NRCELL-1:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRCELL-1:a1MeashoSsbRsrpSA:a1ThresholdHoSsbRsrpVoNr=60
...    NRCELL-1:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=60
...    NRCELL-1:a1MeashoSsbRsrpSA:a1TimeToTriggerHoSsbRsrpVoNr=ms480
...    NRCELL-1:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL-1:a2MeashoEnabledSA=rsrp
...    NRCELL-1:a2MeashoSsbRsrpSA:a2HysteresisHoSsbRsrpVoNr=0
...    NRCELL-1:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0
...    NRCELL-1:a2MeashoSsbRsrpSA:a2ThresholdHoSsbRsrpVoNr=34
...    NRCELL-1:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=34
...    NRCELL-1:a2MeashoSsbRsrpSA:a2TimeToTriggerHoSsbRsrpVoNr=ms480
...    NRCELL-1:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL-1:absThreshSsbRsrpConsolidation=1
...    NRCELL-1:a3MeasEnabled=rsrp
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-1:gNbId=2
...    NRCELL-1/NRREL-1:lcrId=3
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-3/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-3/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-3/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-3/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-3/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-3/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-3/NRREL-1:gNbId=2
...    NRCELL-3/NRREL-1:lcrId=1
...    NRCELL-3/NRREL-1:gNbIdLength=22
...    NRCELL-3:maxNumOfRrcSA=1
...    NRCELL-3:a1MeashoSsbRsrp:a1ThresholdhoSsbRsrp=34
...    NRCELL-3:a1MeashoSsbRsrp:a1TimeToTriggerhoSsbRsrp=ms480
...    NRCELL-3:a1MeashoSsbRsrp:a1HysteresishoSsbRsrp=0
...    NRCELL-3:a2MeasRedirectSsbRsrp:a2HysteresisRedirectSsbRsrp=0
...    NRCELL-3:a2MeasRedirectSsbRsrp:a2TimeToTriggerRedirectSsbRsrp=ms480
...    NRCELL-3:a2MeasRedirectSsbRsrp:a2ThresholdRedirectSsbRsrp=34
...    NRCELL-3:a2MeashoSsbRsrp:a2HysteresishoSsbRsrp=1
...    NRCELL-3:a2MeashoSsbRsrp:a2ThresholdhoSsbRsrp=34
...    NRCELL-3:a2MeashoSsbRsrp:a2TimeToTriggerhoSsbRsrp=ms480
...    NRCELL-3:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRCELL-3:a3MeasSsbRsrp:a3OffsetSsbRsrp=15
...    NRCELL-3:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms40
...    NRCELL-3:a3MeasSsbRsrq:a3HysteresisSsbRsrq=0
...    NRCELL-3:a3MeasSsbRsrq:a3OffsetSsbRsrq=5
...    NRCELL-3:a3MeasSsbRsrq:a3TimeToTriggerSsbRsrq=ms0
...    NRCELL-3:a2MeashoEnabled=rsrp
...    NRCELL-3:a1MeashoEnabled=rsrp
...    NRCELL-3:a3MeasEnabled=rsrp

@{PARAMS_FREQ_FOR_CELL3}
...    NRCELL-3/NRCELL_FDD-1:nrarfcnDl=124580
...    NRCELL-3/NRCELL_FDD-1:nrarfcnUl=133780
...    NRCELL-3:gscnOrSsPbchArfcn=1555
...    NRCELL-3:type0CoresetConfigurationIndex=0

${SA_Capa_Support_SAG}    SEPARATOR=
...    E9A09000575F5A13560003C4A8002C00A0000040301262E003387A16009B20C39F30C7942C0E0980C0311C03EE3614606B04610D04083A41
...    E006D6C98AB1A1CF88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE000C80000E0541B107582308682041E20F0032
...    B64C55890E7D813E238F1891C790E7D473E618F28581C0E1E13FB000000FEC000000C80000E0551B137582308682041D20F0030B64C55110
...    E7C471E238F40CFB027C639F30C7942C0E070F05C00FFC007003FF000640000702A0D88DAC1184341020F10780195B262AC4873E238F604F
...    8C48E3C873EA39F30C7942C0E070F09FFF000007FFC000006400007003DE1E26800710400000858081507850001C46000002160561E23000
...    7104000018581587850001C41000002160561E26800711800000858158B88C001C41000E208000050B02B0F0A000389A0000182C0AC5C4D0
...    00E2080070A000002058158B89A001C46000E230000020B02B170A0003882001C46000004160562E1400071040038820000082C0AC5C4D00
...    0E20800711800001058158B850001C46000E230000020B02B1713400388C001C28000008160561E230007118000018581007011A014404D8
...    08232800BB07C28913639F0E14489B1CF870A244D8E7C3851226C73E1C28913639F0E2448913639F0E14081B1CF811204081B1CF81120408
...    1B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF810A040D8E7C00170F18C6318C6318C6318C61E836
...    001E00140E0A00E0601280380030120020301F04801000000008000010040000000200000401000004008000030040000200200001401000
...    802008020000180100000E008004000000100001000800009004000018020000280100001600800409024010000180672A6B2A6B052B032B
...    066B056B296B266B016B036B012B022B07681A0800004B29282000032CA4A0800014B29202000072CA480800024B292020000B2CA4808000
...    34B292020000F2CA480800044B29202000132CA480800054B29202000172CA4A0800064B29202000062CA480669555D2AAAA55174AA2A82C
...    55058AA0D154A62A93455018AA051549AAA83C50D005E02540A05028140A05028140A05028140A05028140A05000608080600C0200400840
...    4008020100C018402004008080600C02018030404030060100C018402004008080600C02004008804030060100C018040300608080100402
...    004010D50F8000810182030385058606880889098A0C0C8D8E0E8F909293139414951697A0A0C168

@{TP_and_SAG_activate_for_cell_edge}
...    criticalExtensions rrcReconfiguration
...    drx-Config setup
...    drx-onDurationTimer milliSeconds : ms40
...    drx-InactivityTimer ms6
...    transformPrecoder enabled
...    betaOffsets dynamic
...    @{semiStatic_BetaOffsets_values}
...    @{moderate_BetaOffsets_values}
...    @{optimistic_BetaOffsets_values}
...    @{default_BetaOffsets_values}
...    tp-pi2BPSK enabled
...    pusch-TimeDomainAllocationListDCI-0-1-r16 setup
...    pusch-RepTypeIndicatorDCI-0-1-r16 pusch-RepTypeA
...    criticalExtensions rrcReconfigurationComplete
...    SCellIndex 1 deactivated successfully at airphone
...    SCellIndex 2 deactivated successfully at airphone

@{semiStatic_BetaOffsets_values}
...    betaOffsetACK-Index1 11
...    betaOffsetACK-Index2 11
...    betaOffsetACK-Index3 6
...    betaOffsetCSI-Part1-Index1 13
...    betaOffsetCSI-Part1-Index2 13
...    betaOffsetCSI-Part2-Index1 13
...    betaOffsetCSI-Part2-Index2 13

@{moderate_BetaOffsets_values}
...    betaOffsetACK-Index1 10
...    betaOffsetACK-Index2 11
...    betaOffsetACK-Index3 6
...    betaOffsetCSI-Part1-Index1 13
...    betaOffsetCSI-Part1-Index2 13
...    betaOffsetCSI-Part2-Index1 15
...    betaOffsetCSI-Part2-Index2 12

@{optimistic_BetaOffsets_values}
...    betaOffsetACK-Index1 13
...    betaOffsetACK-Index2 12
...    betaOffsetACK-Index3 6
...    betaOffsetCSI-Part1-Index1 13
...    betaOffsetCSI-Part1-Index2 13
...    betaOffsetCSI-Part2-Index1 12
...    betaOffsetCSI-Part2-Index2 13

@{default_BetaOffsets_values}
...    betaOffsetACK-Index1 11
...    betaOffsetACK-Index2 11
...    betaOffsetACK-Index3 6
...    betaOffsetCSI-Part1-Index1 13
...    betaOffsetCSI-Part1-Index2 13
...    betaOffsetCSI-Part2-Index1 13
...    betaOffsetCSI-Part2-Index2 13

@{TP_and_SAG_scell_check_for_center_center}
...    criticalExtensions rrcReconfiguration
...    drx-Config setup
...    drx-onDurationTimer milliSeconds : ms6
...    transformPrecoder disabled
...    betaOffsets semiStatic
...    @{semiStatic_BetaOffsets_values}
...    pusch-RepTypeIndicatorDCI-0-1-r16 pusch-RepTypeA
...    criticalExtensions rrcReconfigurationComplete
...    @{Scells_Activate}

@{TP_and_SAG_scell_check_for_5QI1_del}
...    SCellIndex *. activated successfully at airphone
...    criticalExtensions rrcReconfiguration
...    transformPrecoder enabled
...    betaOffsets semiStatic
...    @{semiStatic_BetaOffsets_values}
...    pusch-RepTypeIndicatorDCI-0-1-r16 pusch-RepTypeA
...    criticalExtensions rrcReconfigurationComplete

@{Scells_Activate}
...    SCellIndex 2 activated successfully at airphone
...    SCellIndex 1 activated successfully at airphone

*** Test Cases ***
CB008236-ET-B016 Verify VoNR UE with active SCells moves to cell edge or RF degrades Intra gnb CA
    [Documentation]
    ...    This case is to verify gNB behavior after a VoNR UE that has DL-only SCells configured moves to cell edge and
    ...    transitions to TP On state while UE is capable of PUSCH Repetition Type A. UE is connected to FDD PCell in SA
    ...    mode and is configured with 2 SCells.
    ...    Requirement Coverage:
    ...    5G_RAN_USR_RRM_19901, partially covered
    ...    2.Test Case Steps:
    ...         Step A.UE Register on cell1 and Add Pdu with Default 5QI5
    ...         Step B.PDU Add QoSFlow 5QI6
    ...         Step C.PDU Add QoSFlow 5QI1
    ...         Step D.Start data transfer,trigger the DL buffer criteria for SCell Addition
    ...         Step E.UE moves towards cell edge
    ...         Step F.UE moves towards cell center
    ...         Step G.UE moves towards cell edge
    ...         Step H.Delete 5QI1
    ...         Step I.UE release
    ...    3. Expected Results:
    ...         Step A: UE Register on cell1 and Add Pdu with Default 5QI5 is successful
    ...         Step B: PDU Add QoSFlow 5QI6 is successful
    ...         Step C: PDU Add QoSFlow 5QI1 is successful
    ...         Step D:
    ...          a.traffic start successfully
    ...          b.two other FR1 cells (SCell1 and SCell2) added as scells
    ...          c.scell can be activate successfully
    ...         Step E.
    ...          a.UE Transform Precoder enabled
    ...          b.gNB initiates RRCReconfiguration procedure to perform User Reconfiguration
    ...          c.pusch-TimeDomainAllocationListDCI-0-1-r16 is setup
    ...          d.UE Transform Precoder enabled
    ...          e.gNB configures UE with SAg specific dynamic betaoffsets in UCI-onPUSCH IE
    ...          f.UE is configured with DRX Sleep Off, onDurationTimer equal to drx-LongCycle length
    ...          g.scells are deactivated successfully
    ...         Step F.
    ...          a.gNB performs procedures to transition to TP Off state and stop Slot Aggregation,DRX is also changed to
    ...            profile2 with onDuration set less than the drx-LongCycle.
    ...          b.gNB starts buffer monitoring for SCell activation
    ...          c. SCells are activated successfully
    ...         Step G.
    ...          a.UE Transform Precoder enabled
    ...          b.gNB initiates RRCReconfiguration procedure to perform User Reconfiguration
    ...          c.pusch-TimeDomainAllocationListDCI-0-1-r16 is setup
    ...          d.UE Transform Precoder enabled
    ...          e.gNB configures UE with SAg specific dynamic betaoffsets in UCI-onPUSCH IE
    ...          f.UE is configured with DRX Sleep Off, onDurationTimer equal to drx-LongCycle length
    ...          g.scells are deactivated successfully
    ...         Step H.
    ...          a.gNB performs procedures to transition to TP Off state and stop Slot Aggregation,DRX is also changed to
    ...            profile2 with onDuration set less than the drx-LongCycle.
    ...          b.gNB starts buffer monitoring for SCell activation
    ...          c. SCells are activated successfully
    ...         Step I.UE is released successfully
    ...         5QI-1: NRDRB-15  MRBTS-2/NRBTS-2/NRDRB_MAC-4  lcgid 4  schedulPrio 5
    ...         5QI-5: NRDRB-10  MRBTS-2/NRBTS-2/NRDRB_MAC-3  lcgid 0  schedulPrio 4
    ...         5QI-6: NRDRB-14  MRBTS-2/NRBTS-2/NRDRB_MAC-2  lcgid 1  schedulPrio 12
    [Tags]    QC_304759
    UE Register And Add Pdu With Default 5QI5 5QI6 and 5QI1
    Scell Addition Trigger By DL ThroughPut And Start Ul Throughput
    Trigger UE Transform Precoder enabled and SAG Activate
    Simulate From Cell Edge to Cell Center
    Trigger UE Transform Precoder enabled and SAG Activate
    Release 5QI1
    Release UEs    ue_type=all


*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/3cells_1T2F

Modify Cfg
    #UE configuration
    Update Cfg    ue_param id=1 ue_nr_capabilities=${SA_Capa_Support_SAG} nr_usage_setting=voice_centric
    Update Cfg    amf_param id=1 full_nas_auth=on nia=null+aes nea=null+aes ims_voice_3gpp=on
    ${cell3_gnb2}    catenate    set_cell id=3 gnb=2 pci=20:1 tac=200 nrci=0x03 tdd_cell=off proxy=$PROXY_SERVER_IP:9999|$PROXY_SERVER_IP:8888
    ...     nr_arfcn=133780:124580 mandatory_for_activation=off gscn=1555
    Update Cfg    ${cell3_gnb2}
    ${set_ue1}    catenate
    ...    set_ue simulated id=1 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56
    ...    opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+aes nea=null+aes sec_key=0102030405060708090A0B0C0D0EFF00
    ...    suci=0:311:489:0000:0:0:021645400 mode=nr enb=2 cell=1
    Update Cfg    ${set_ue1}
    Update Cfg    ue_nr_capabilities id=1 voice_over_nr=on:on:off
    #5QI configuration
    Update Cfg    set_qosflow id=1 5qi=6 default=on
    Update Cfg    set_qosflow id=2 5qi=1
    Update Cfg    set_qosflow id=3 5qi=5 default=off
    Update Cfg    set_qosrule id=1 proto=tcp qos_flow=1
    Update Cfg    set_qosrule id=2 proto=udp qos_flow=2
    Update Cfg    set_nwslice id=1 snssai=0x01:0xD143A5 qos_flows=1,2,3 qos_rules=1,2 default=on ue=1-6 amf=1

UE Register And Add Pdu With Default 5QI5 5QI6 and 5QI1
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=Received REGISTRATION COMPLETE
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${ue_id}
    ...    pass_regexp=UE${ue_id}: Ue ${ue_id} PduId 1 Created FiveQi:Qfi mapping fiveQi 6 qfi 1
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=3 by=amf    pass_regexp=Added QosFlow with QFI:2 fiveQI:5
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=2 by=amf    pass_regexp=Added QosFlow with QFI:3 fiveQI:1

Scell Addition Trigger By DL ThroughPut And Start Ul Throughput
    [Arguments]    ${ue_id}=1
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 trf_id=1 protocol=tcp mbps=150 dir=dl
    ...    pass_regexp=@{Scells_Activate}
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 trf_id=2 protocol=tcp mbps=150 dir=dl    Started Downlink Internal traffic
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=2 dir=ul mbps=10 trf_id=1 protocol=tcp    Started Uplink Internal traffic Receiver
    Verify Throughput    ${ue_id}

Trigger UE Transform Precoder enabled and SAG Activate
    Execute Egate Command     ul_sinr_testmode_nr profile_id=1 pathloss=118
    Execute Egate Command     ue_testmode_set_nr id=1 testmode=ul_sinr profile_id=1 action=activate
    ...    pass_regexp=${TP_and_SAG_activate_for_cell_edge}
    sleep    15s    sleep for Tput stable
    ${pcell_tput}    Execute Egate Command    ue_stats_nr id=1 scell=0 type=pdsch    NR PDSCH Throughput
    Should Not Match Regexp    ${pcell_tput}    CellIndex-0.*Mbps.*Mbps.*Mbps.* 0 Mbps

Simulate From Cell Edge to Cell Center
    Execute Egate Command     ul_sinr_testmode_nr profile_id=1 pathloss=30    pass_regexp=@{TP_and_SAG_scell_check_for_center_center}
    Verify Throughput
    Execute Egate Command     ue_testmode_set_nr id=1 testmode=ul_sinr profile_id=1 action=deactivate    #ul_sinr recover
    Execute Egate Command     ul_sinr_testmode_nr profile_id=1 delete=1    #ul_sinr recover

Release 5QI1
    Execute Egate Command     ue_pdu_session_modify ue=1 pdu=1 qosflows_to_del=2 by=amf    pass_regexp=@{TP_and_SAG_scell_check_for_5QI1_del}
    Verify Throughput

Verify Throughput
    [Arguments]    ${ue_id}=1    ${Tput_ul}=8    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=2    direction=ul    rate_type=ave
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pdsch    Throughput
    ${scell_tput_pusch}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pusch    Throughput
    Should Not Match Regexp    ${scell_tput}    CellIndex-.*Mbps.*Mbps.*Mbps.* 0 Mbps
    Should Not Match Regexp    ${scell_tput_pusch}    CellIndex-.*Mbps.*Mbps.*Mbps.* 0 Mbps

    Should Not Match Regexp    ${scell_tput}    CellIndex-.*Mbps.*Mbps.*Mbps.* 0 Mbps
    Should Not Match Regexp    ${scell_tput_pusch}    CellIndex-.*Mbps.*Mbps.*Mbps.* 0 Mbps

