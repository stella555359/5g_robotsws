*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CLOUD_5G_I_LO_AP_LO    team-CN1ET
...    owner-zhubaijie    release-SBTS24R2    CRT
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}    @{CB008236}    @{CB006112}    @{5GC000545}    @{PARAMS_FOR_5QI9}    @{PARAMS_FOR_5QI5}
...    @{PARAMS_FOR_5QI1}    @{PARAMS_FOR_HO}

@{CB008236}
...    NRCELL-1:actUlSlotAgg=Enabled_VoNr
...    NRCELL-1:actDrxSleepOff=Enabled_VoNr_SAg
...    NRCELL-1:sCellDeactInPoorRf=Deact_Scells_VoNr_SAg
...    NRCELL-1:ulTransPrecodeCtl:ulSlotAggOffTotPwrThresh=33
...    NRCELL-1:ulTransPrecodeCtl:ulSlotAggOnTotPwrThresh=30
...    NRCELL-1:maxHarqBundlesUlSlotAgg=10
...    NRCELL-1:minTbsUlSlotAgg=384
...    NRCELL-2:actUlSlotAgg=Disabled
...    NRCELL-2:actDrxSleepOff=Enabled_VoNr_SAg
...    NRCELL-2:sCellDeactInPoorRf=Deact_Scells_VoNr_SAg
...    NRCELL-2:ulTransPrecodeCtl:ulSlotAggOffTotPwrThresh=33
...    NRCELL-2:ulTransPrecodeCtl:ulSlotAggOnTotPwrThresh=30
...    NRCELL-2:maxHarqBundlesUlSlotAgg=10
...    NRCELL-2:minTbsUlSlotAgg=384

@{CB006112}
...    NRCELL-1:actEnhancedVoNR=true
...    NRCELL-1:actAdaptVoipTbs=true
...    NRCELL-1:actCDrxVoNR=true
...    NRCELL-1:actCDrx=true
...    NRCELL-1:actVoNR=true
#...    NRCELL-1:drxProfile2:drxLongCycle=40ms
#...    NRCELL-1:drxProfile2:drxOnDurationTimer=6ms
#...    NRCELL-1:drxProfile2:drxInactivityTimer=6ms
...    NRCELL-1:srPeriodicity=slots40
...    NRCELL-1:periodicCsiAcquisition:csiReportPeriodicity=slots80
...    NRCELL-1:actVoipPacketAggr=true
...    NRCELL-2:actEnhancedVoNR=true
...    NRCELL-2:actAdaptVoipTbs=true
...    NRCELL-2:actCDrxVoNR=true
...    NRCELL-2:actCDrx=true
...    NRCELL-2:actVoNR=true
#...    NRCELL-2:drxProfile2:drxLongCycle=40ms
#...    NRCELL-2:drxProfile2:drxOnDurationTimer=6ms
#...    NRCELL-2:drxProfile2:drxInactivityTimer=6ms
...    NRCELL-2:srPeriodicity=slots40
...    NRCELL-2:periodicCsiAcquisition:csiReportPeriodicity=slots80
...    NRCELL-2:actVoipPacketAggr=true

@{5GC000545}
...    NRCELL-1:actUlDftSOfdm=true
...    NRBTS:actTdraFallback=false
...    NRCELL-1:pucchModeSelect=longPucch
...    NRCELL-1:puschMappingType=TypeB
...    NRCELL-1:ulTransPrecodeCtl:ulTransPrecodeOffSinrThresh=200
...    NRCELL-1:ulTransPrecodeCtl:ulTransPrecodeOnSinrThresh=180
...    NRCELL-2:actUlDftSOfdm=true
...    NRCELL-2:pucchModeSelect=longPucch
...    NRCELL-2:puschMappingType=TypeB
...    NRCELL-2:ulTransPrecodeCtl:ulTransPrecodeOffSinrThresh=200
...    NRCELL-2:ulTransPrecodeCtl:ulTransPrecodeOnSinrThresh=180

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
...    NRCELL-2:actVoNR=true
...    NRBTS:actNormVCFallback=false
...    NRBTS:rrcReestabTypeSA=sameGNB
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
...    NRCELL-1:a3MeasEnabled=rsrp
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
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-1:gNbId=2
...    NRCELL-1/NRREL-1:lcrId=2
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-1:gNbId=2
...    NRCELL-2/NRREL-1:lcrId=1
...    NRCELL-2/NRREL-1:gNbIdLength=22
...    NRCELL-2:a1MeashoSsbRsrp:a1ThresholdhoSsbRsrp=34
...    NRCELL-2:a1MeashoSsbRsrp:a1TimeToTriggerhoSsbRsrp=ms480
...    NRCELL-2:a1MeashoSsbRsrp:a1HysteresishoSsbRsrp=0
...    NRCELL-2:a2MeasRedirectSsbRsrp:a2HysteresisRedirectSsbRsrp=0
...    NRCELL-2:a2MeasRedirectSsbRsrp:a2TimeToTriggerRedirectSsbRsrp=ms480
...    NRCELL-2:a2MeasRedirectSsbRsrp:a2ThresholdRedirectSsbRsrp=34
...    NRCELL-2:a2MeashoSsbRsrp:a2HysteresishoSsbRsrp=1
...    NRCELL-2:a2MeashoSsbRsrp:a2ThresholdhoSsbRsrp=34
...    NRCELL-2:a2MeashoSsbRsrp:a2TimeToTriggerhoSsbRsrp=ms480
...    NRCELL-2:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRCELL-2:a3MeasSsbRsrp:a3OffsetSsbRsrp=15
...    NRCELL-2:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms40
...    NRCELL-2:a3MeasSsbRsrq:a3HysteresisSsbRsrq=0
...    NRCELL-2:a3MeasSsbRsrq:a3OffsetSsbRsrq=5
...    NRCELL-2:a3MeasSsbRsrq:a3TimeToTriggerSsbRsrq=ms0
...    NRCELL-2:a2MeashoEnabled=rsrp
...    NRCELL-2:a1MeashoEnabled=rsrp
...    NRCELL-2:a3MeasEnabled=rsrp
...    NRCELL-2:a1MeashoEnabledSA=rsrp
...    NRCELL-2:a1MeashoSsbRsrpSA:a1HysteresisHoSsbRsrpVoNr=0
...    NRCELL-2:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRCELL-2:a1MeashoSsbRsrpSA:a1ThresholdHoSsbRsrpVoNr=60
...    NRCELL-2:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=60
...    NRCELL-2:a1MeashoSsbRsrpSA:a1TimeToTriggerHoSsbRsrpVoNr=ms480
...    NRCELL-2:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL-2:a2MeashoEnabledSA=rsrp
...    NRCELL-2:a2MeashoSsbRsrpSA:a2HysteresisHoSsbRsrpVoNr=0
...    NRCELL-2:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0
...    NRCELL-2:a2MeashoSsbRsrpSA:a2ThresholdHoSsbRsrpVoNr=34
...    NRCELL-2:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=34
...    NRCELL-2:a2MeashoSsbRsrpSA:a2TimeToTriggerHoSsbRsrpVoNr=ms480
...    NRCELL-2:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL-2:absThreshSsbRsrpConsolidation=1
...    NRCELL-1:maxNumPdschAllocationPerSlot=4
...    NRCELL-1:maxNumPuschAllocationPerSlot=4
...    NRCELL-2:maxNumPdschAllocationPerSlot=4
...    NRCELL-2:maxNumPuschAllocationPerSlot=4

${SA_Capa_Support_SAG}    SEPARATOR=
...    E9A09000575F5A13560003C4A8002C00A0000040301262E003387A16009B20C39F30C7942C0E0980C0311C03EE3614606B04610D04083A41E006D6C98AB1A1CF88E3D033EC09
...    F1891C790E7D473E618F28581C0E1E0B801FF800E000BE000C80000E0541B107582308682041E20F0032B64C55890E7D813E238F1891C790E7D473E618F28581C0E1E13FB000
...    000FEC000000C80000E0551B137582308682041D20F0030B64C55110E7C471E238F40CFB027C639F30C7942C0E070F05C00FFC007003FF000640000702A0D88DAC1184341020
...    F10780195B262AC4873E238F604F8C48E3C873EA39F30C7942C0E070F09FFF000007FFC000006400007003DE1E26800710400000858081507850001C46000002160561E23000
...    7104000018581587850001C41000002160561E26800711800000858158B88C001C41000E208000050B02B0F0A000389A0000182C0AC5C4D000E2080070A000002058158B89A0
...    01C46000E230000020B02B170A0003882001C46000004160562E1400071040038820000082C0AC5C4D000E20800711800001058158B850001C46000E230000020B02B1713400
...    388C001C28000008160561E230007118000018581007011A014404D808232800BB07C28913639F0E14489B1CF870A244D8E7C3851226C73E1C28913639F0E2448913639F0E14
...    081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF810A040D8E7C00170F18C6318C6318C6318C61E836
...    001E00140E0A00E0601280380030120020301F04801000000008000010040000000200000401000004008000030040000200200001401000802008020000180100000E008004
...    000000100001000800009004000018020000280100001600800409024010000180672A6B2A6B052B032B066B056B296B266B016B036B012B022B07681A0800004B2928200003
...    2CA4A0800014B29202000072CA480800024B292020000B2CA480800034B292020000F2CA480800044B29202000132CA480800054B29202000172CA4A0800064B29202000062C
...    A480669555D2AAAA55174AA2A82C55058AA0D154A62A93455018AA051549AAA83C50D005E02540A05028140A05028140A05028140A05028140A05000608080600C0200400840
...    4008020100C018402004008080600C02018030404030060100C018402004008080600C02004008804030060100C018040300608080100402004010D50F800081018203038505
...    8606880889098A0C0C8D8E0E8F909293139414951697A0A0C168
#Common capa with below capa supported
#phy-Parameters {
#phy-ParametersCommon {
#dynamicBetaOffsetInd-HARQ-ACK-CSI supported,
#pusch-RepetitionTypeA-r16 {
#sharedSpectrumChAccess-r16 supported,
#non-SharedSpectrumChAccess-r16 supported

@{expect_5QI5}
...    Setup QosFlow with QFI:1 fiveQI:5
...    transformPrecoderDisabled
...    transformPrecoderEnabled
...    pusch-TimeDomainAllocationList release : NULL
...    betaOffsets semiStatic
...    @{semiStatic_BetaOffsets_values}
...    tp-pi2BPSK enabled
...    pusch-TimeDomainAllocationListDCI-0-1-r16 setup
...    pusch-RepTypeIndicatorDCI-0-1-r16 pusch-RepTypeA
...    drx-Config setup
...    drx-onDurationTimer milliSeconds : ms10
...    drx-InactivityTimer ms80
...    drx-SlotOffset 0

@{expect_CellEdge}
...    transformPrecoder enabled
...    tp-pi2BPSK enabled
...    pusch-TimeDomainAllocationListDCI-0-1-r16 setup
...    pusch-RepTypeIndicatorDCI-0-1-r16 pusch-RepTypeA

@{expect_5QI1_DrxSleepOffDis}
...    transformPrecoder enabled
...    betaOffsets dynamic
...    @{semiStatic_BetaOffsets_values}
...    @{moderate_BetaOffsets_values}
...    @{optimistic_BetaOffsets_values}
...    @{default_BetaOffsets_values}
...    tp-pi2BPSK enabled
...    pusch-RepTypeIndicatorDCI-0-1-r16 pusch-RepTypeA
...    drx-Config setup
...    drx-onDurationTimer milliSeconds    #the value could be ms10 or it could be ms6, add failure check
...    drx-InactivityTimer ms6
...    Added QosFlow with QFI:3 fiveQI:1

@{unexpect_5QI1_DrxSleepOff}
...    drx-onDurationTimer milliSeconds : ms40

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

@{expect_5QI1_TPOff}
...    Added QosFlow with QFI:3 fiveQI:1
...    drx-Config setup
...    drx-onDurationTimer milliSeconds    #the value could be ms10 or it could be ms6, add failure check
...    drx-InactivityTimer ms6

@{expect_CellEdgeVoNR}
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

@{expect_CellCenter}
...    drx-Config setup
...    drx-onDurationTimer milliSeconds    #the value could be ms10 or it could be ms6, add failure check
...    drx-InactivityTimer ms6
...    transformPrecoder disabled
...    @{semiStatic_BetaOffsets_values}
...    tp-pi2BPSK enabled
...    pusch-TimeDomainAllocationListDCI-0-1-r16 setup
...    pusch-RepTypeIndicatorDCI-0-1-r16 pusch-RepTypeA

@{expect_5QI1_VoNR_Add}
...    Added QosFlow with QFI:2 fiveQI:1
...    drx-Config setup
...    drx-onDurationTimer milliSeconds : ms6
...    drx-InactivityTimer ms6

@{expect_5QI1_Rel}
...    Deleting QosFlow with QFI:2 5QI:1
...    transformPrecoder enabled
...    betaOffsets semiStatic
...    @{semiStatic_BetaOffsets_values}
...    tp-pi2BPSK enabled
...    pusch-RepTypeIndicatorDCI-0-1-r16 pusch-RepTypeA
...    drx-Config setup
...    drx-onDurationTimer milliSeconds : ms10
...    drx-InactivityTimer ms80

@{expect_5QI1_Add_TP_check}
...    transformPrecoder enabled
...    betaOffsets dynamic
...    @{semiStatic_BetaOffsets_values}
...    @{moderate_BetaOffsets_values}
...    @{optimistic_BetaOffsets_values}
...    @{default_BetaOffsets_values}
...    tp-pi2BPSK enabled
...    pusch-RepTypeIndicatorDCI-0-1-r16 pusch-RepTypeA
...    drx-Config setup
...    drx-onDurationTimer milliSeconds : ms40
...    drx-InactivityTimer ms6
...    Added QosFlow with QFI:3 fiveQI:1

@{reestablish_TP_activate_check}
...    drx-onDurationTimer milliSeconds : ms40
...    transformPrecoder enabled
...    betaOffsets dynamic
...    @{semiStatic_BetaOffsets_values}
...    @{moderate_BetaOffsets_values}
...    @{optimistic_BetaOffsets_values}
...    @{default_BetaOffsets_values} 
...    tp-pi2BPSK enabled
...    pusch-TimeDomainAllocationListDCI-0-1-r16 setup
...    pusch-RepTypeIndicatorDCI-0-1-r16 pusch-RepTypeA
...    rrcReconfigurationComplete:::6

@{actDrxSleepOff_Dis}
...    NRCELL-1:actDrxSleepOff=Disabled

@{actDrxSleepOff_En}
...    NRCELL-1:actDrxSleepOff=Enabled_VoNr_SAg

${ACC_PUSCH_REP_TYPE_A_CAP_UE}    M55139C00025
${MAX_PUSCH_REP_TYPE_A_CAP_UE}    M55139C00026
${UE_CAP_DEN}    M55139C00027

@{PM_Counters_Check}
...    NRCELL-1:RSADU:${ACC_PUSCH_REP_TYPE_A_CAP_UE}>15
...    NRCELL-1:RSADU:${MAX_PUSCH_REP_TYPE_A_CAP_UE}=1|2
...    NRCELL-1:RSADU:${UE_CAP_DEN}=300

*** Test Cases ***
CB008236_ET_B003_Verify_VoNR_DRB_is_added_for_a_UE_in_TP_Off state_and_DRX_Sleep_off_is_enabled_then_UE_moves_to_poor_RF_state
    [Documentation]
    ...    The purpose of this test case is to check following scenarios:
    ...    This scenario describes gNB behavior when DRX Sleep off is enabled for a VoNR UE entering SAg mode. UE is connected to FDD cell in SA 
    ...    mode. UE already has DRX profile2 configured. gNB modifies the drx-onDurationTimer to be the same as drx-LongCycle to force UE to not
    ...    go to sleep mode.
    ...    This scenario describes gNB behavior when a UE with a 5QI1 DRB in poor RF coverage while in Slot Aggregation mode, the last 5QI1 DRB 
    ...    is released. UE is connected to FDD cell in SA mode.
    ...    gNB ends slot aggregation for the UE once VoNR/5QI1 DRB is released and switches from DRX profile2 to DRX profile1.
    ...    it also covered the B002 scenarios that Verify VoNR DRB is added for a UE in TP On state and DRX Sleep off is enabled and on line change
    ...    Requirement Coverage:
    ...    5G_RAN_USR_RRM_19907, fully covered
    ...    5G_RAN_USR_RRM_20142, fully covered
    ...    2. Test Case Steps:
    ...         preconfiguration:Install RFMplugin Package via WEBEM for band 71 before cell on air.
    ...         Step A.UE Trigger Single VoNR Call
    ...         Step B.UE Moves Towards Cell Edge With VoNR
    ...         Step C.UE Trigger VoNR Call add 5QI6 Setup Successfully
    ...         Step D.UE Trigger VoNR Call 5QI1 Release Successfully
    ...         Step E.UE Deregister From gNB
    ...    3. Expect result:
    ...         Step A.
    ...             1)VoNR call setup successfylly
    ...             2)DRX profile2 is in use
    ...         Step B.
    ...             1)L2PS triggers UE reconfiguration to switch UE to Transform Precoder enabled state 
    ...             2)gNB initiates RRCReconfiguration procedure to perform User Reconfiguration
    ...             3)UE is configured with DRX Sleep Off,onDurationTimer equal to drx-LongCycle length
    ...             4)gNB configures UE with SAg specific dynamic betaoffsets in UCI-onPUSCH IE
    ...         Step C.5QI6 Setup Successfully
    ...         Step D.
    ...             1)5QI1 Release Successfully
    ...             2)gNB switches to DRX profile1
    ...             Upon completion of RRCReconfiguration procedure to release the last 5QI1 DRB, gNB initiates RRCReconfiguration in order to 
    ...             switch from VoNR
    ...             3)DRX profile2 to DRX profile1. Note: this is legacy CB006112 behavior
    ...             gNB-DU sets the onDurationTimer and the longDrxCycle value, as per DRX profile1 parameters
    ...         Step E.UE is release successfully
    [Tags]    B003    B005    QC_347355
    Verify VoNR DRB is added for a UE in TP On state and DRX Sleep off is enabled and on line change
    UE Trigger Single VoNR Call
    UE Moves Towards Cell Edge With VoNR
    UE Trigger VoNR Call add 5QI6 Setup Successfully    ue_id=1
    UE Trigger VoNR Call 5QI1 Release Successfully
    UE Deregister From gNB    ue_id=1
    [Teardown]    B003_Teardown

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Install RFMplugin Package via WEBEM
    Setup Airphone Env    fdd_sansa_cmwv/2cells_oran

Install RFMplugin Package via WEBEM
    [Arguments]    ${RFMplugin_path}=/home/ute/bsr_package
    ...    ${RFMplugin_name}=RFMPlugin_O-RU_FJ_FJRU-N75N3N71-G_0016.zip
    Execute Cmd On Pc    mkdir ${RFMplugin_path}
    Execute Cmd On Pc    git clone https://wrgitlab.ext.net.nokia.com/y165zhan/bsr_package ${RFMplugin_path}
    update_software    sw_package=${RFMplugin_path}/RFMPlugins/${RFMplugin_name}    timeout=20

Verify VoNR DRB is added for a UE in TP On state and DRX Sleep off is enabled and on line change
    Delta Commission Set DrxSleepOff Disable
    UE Trigger Normal Call With PDU Default 5QI5    ue_id=1
    Delta Commission Set DrxSleepOff Enable
    UE Trigger VoNR Call 5QI6 Setup Successfully    ue_id=1
    UE Moves Towards Cell Edge
    UE Trigger VoNR Call 5QI1 Setup Successfully With DrxSleepOff Disable    ue_id=1
    UE Deregister From gNB    ue_id=1
    UE Trigger Normal Call With PDU Default 5QI5    ue_id=1
    UE Trigger VoNR Call On Another PDU
    UE Moves Towards Cell Edge With VoNR
    UE Moves Towards Cell Center
    UE Deregister From gNB    ue_id=1

B003_Teardown
    Delta Commission Set DrxSleepOff Disable
    Common Test Teardown And Stop Capture Logs

Disable UE Testmode
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_testmode_set_nr id=${ue_id} testmode=ul_sinr profile_id=1 action=deactivate
    Execute Egate Command    ul_sinr_testmode_nr profile_id=1 delete=1

Delta Commission Set DrxSleepOff Disable
    Delta Commission Parameters    ${actDrxSleepOff_Dis}

Delta Commission Set DrxSleepOff Enable
    Delta Commission Parameters    ${actDrxSleepOff_En}

UE Trigger Normal Call With PDU Default 5QI5
    [Arguments]    ${ue_id}
    Disable UE Testmode    ue_id=${ue_id}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=1
    Execute Egate Command    ue_register id=${ue_id} nwslice=1    pass_regexp=Received REGISTRATION COMPLETE
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${ue_id}    pass_regexp=${expect_5QI5}

UE Trigger VoNR Call 5QI6 Setup Successfully
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=3 by=amf    pass_regexp=Added QosFlow with QFI:2 fiveQI:6
    UE Send Throuput On 5QI6

UE Send Throuput On 5QI6
    [Arguments]    ${ue_id}=1
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=1 protocol=tcp mbps=10 dir=ul     pass_regexp=UE 1: TCP UL TRF
    sleep    10s    #sleep for stable traffic
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pusch

UE Moves Towards Cell Edge
    Execute Egate Command    ul_sinr_testmode_nr profile_id=1 pathloss=118
    Execute Egate Command    ue_testmode_set_nr id=1 testmode=ul_sinr profile_id=1 action=activate    pass_regexp=${expect_CellEdge}

UE Trigger VoNR Call 5QI1 Setup Successfully With DrxSleepOff Disable
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=2 by=amf    pass_regexp=${expect_5QI1_DrxSleepOffDis}
    ...    fail_regexp=${unexpect_5QI1_DrxSleepOff}

UE Deregister From gNB
    [Arguments]    ${ue_id}=1
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=1    pass_regexp=Traffic was stopped
    Execute Egate Command    ue_pdu_session_release ue=${ue_id} pdu=1    pass_regexp=Successfully released PDU Session
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    pass_regexp=UE1: detached    timeout=10s

UE Trigger VoNR Call On Another PDU
    UE Trigger VoNR Call 5QI6 Setup Successfully    ue_id=1
    UE Trigger VoNR Call 5QI1 Setup Successfully With TP Off    ue_id=1

UE Trigger VoNR Call 5QI1 Setup Successfully With TP Off
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=2 by=amf    pass_regexp=${expect_5QI1_TPOff}
    ...    fail_regexp=${unexpect_5QI1_DrxSleepOff}

UE Moves Towards Cell Edge With VoNR
    Execute Egate Command    ul_sinr_testmode_nr profile_id=1 pathloss=118
    Execute Egate Command    ue_testmode_set_nr id=1 testmode=ul_sinr profile_id=1 action=activate    pass_regexp=${expect_CellEdgeVoNR}

UE Moves Towards Cell Center
    Sleep    2s    #wait UE stabilization
    Execute Egate Command    ul_sinr_testmode_nr profile_id=1 pathloss=40    pass_regexp=${expect_CellCenter}
    ...    fail_regexp=${unexpect_5QI1_DrxSleepOff}

UE Trigger Single VoNR Call
    UE Trigger Normal Call With PDU Default 5QI5    ue_id=1
    UE Trigger VoNR Call 5QI1 Setup Successfully    ue_id=1
    Execute Egate Command    trf_data_start ue=1 pdu=1 qfi=1 trf_id=1 protocol=tcp mbps=2 dir=ul     pass_regexp=UE 1: TCP UL TRF
    Execute Egate Command    ue_stats_nr id=1 scell=0-7 type=pusch

UE Trigger VoNR Call 5QI1 Setup Successfully
    [Arguments]    ${ue_id}=1 
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=2 by=amf    pass_regexp=${expect_5QI1_VoNR_Add}

UE Trigger VoNR Call add 5QI6 Setup Successfully
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=3 by=amf    pass_regexp=Added QosFlow with QFI:3 fiveQI:6

UE Trigger VoNR Call 5QI1 Release Successfully
    Execute Egate Command    ue_pdu_session_modify ue=1 pdu=1 qosflows_to_del=2 by=amf    pass_regexp=${expect_5QI1_Rel}

PDU Add QoSFlow 5QI1
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=2 by=amf    pass_regexp=${expect_5QI1_Add_TP_check}
    sleep    10s    #wait counter update and check UE not release

Trigger UE reestablish and Transform Precoder enabled
    Execute Egate Command    ue_rrc_reestablish id=1 gnb=2 cell=1 cause=otherFailure    pass_regexp=${reestablish_TP_activate_check}
    sleep    10s    #wait counter update and check UE not release
