*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    CRT
...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    team-L3CN1_SG14    owner-jun.3.ye    release-SBTS00    CB008236
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}    @{CB008236}    @{CB006112}    @{5GC000545}    @{PARAMS_FOR_5QI9}    @{PARAMS_FOR_5QI5}
...    @{PARAMS_FOR_5QI1}    @{PARAMS_FOR_SECURITY}    @{PARAMS_FOR_HO}

@{CB008236}
...    NRCELL-1:actUlSlotAgg=Enabled_VoNr
...    NRCELL-1:actDrxSleepOff=Enabled_VoNr_SAg
...    NRCELL-1:sCellDeactInPoorRf=Deact_Scells_VoNr_SAg
...    NRCELL-1:ulTransPrecodeCtl:ulSlotAggOffTotPwrThresh=33
...    NRCELL-1:ulTransPrecodeCtl:ulSlotAggOnTotPwrThresh=30
...    NRCELL-1:maxHarqBundlesUlSlotAgg=10
...    NRCELL-1:minTbsUlSlotAgg=384
...    NRCELL-3:actUlSlotAgg=Disabled
...    NRCELL-3:actDrxSleepOff=Enabled_VoNr_SAg
...    NRCELL-3:sCellDeactInPoorRf=Deact_Scells_VoNr_SAg
...    NRCELL-3:ulTransPrecodeCtl:ulSlotAggOffTotPwrThresh=33
...    NRCELL-3:ulTransPrecodeCtl:ulSlotAggOnTotPwrThresh=30
...    NRCELL-3:maxHarqBundlesUlSlotAgg=10
...    NRCELL-3:minTbsUlSlotAgg=384

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

@{PARAMS_FOR_SECURITY}
...    NRBTS:cipherPrefL:nea0=9
...    NRBTS:cipherPrefL:nea1_128=0
...    NRBTS:cipherPrefL:nea2_128=0
...    NRBTS:cipherPrefL:nea3_128=0
...    NRBTS:integrityProtPrefL:nia0=0
...    NRBTS:integrityProtPrefL:nia1_128=0
...    NRBTS:integrityProtPrefL:nia2_128=9
...    NRBTS:integrityProtPrefL:nia3_128=0

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
...    NRCELL-3:a1MeashoEnabledSA=rsrp
...    NRCELL-3:a1MeashoSsbRsrpSA:a1HysteresisHoSsbRsrpVoNr=0
...    NRCELL-3:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRCELL-3:a1MeashoSsbRsrpSA:a1ThresholdHoSsbRsrpVoNr=60
...    NRCELL-3:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=60
...    NRCELL-3:a1MeashoSsbRsrpSA:a1TimeToTriggerHoSsbRsrpVoNr=ms480
...    NRCELL-3:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL-3:a2MeashoEnabledSA=rsrp
...    NRCELL-3:a2MeashoSsbRsrpSA:a2HysteresisHoSsbRsrpVoNr=0
...    NRCELL-3:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0
...    NRCELL-3:a2MeashoSsbRsrpSA:a2ThresholdHoSsbRsrpVoNr=34
...    NRCELL-3:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=34
...    NRCELL-3:a2MeashoSsbRsrpSA:a2TimeToTriggerHoSsbRsrpVoNr=ms480
...    NRCELL-3:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL-3:absThreshSsbRsrpConsolidation=1
...    NRCELL-1:maxNumPdschAllocationPerSlot=4
...    NRCELL-1:maxNumPuschAllocationPerSlot=4
...    NRCELL-3:maxNumPdschAllocationPerSlot=4
...    NRCELL-3:maxNumPuschAllocationPerSlot=4

###enabled ue support dynamic betaoffsets and non-SharedSpectrumChAccess-r16###
${SA_Capa_Support_SAG}    SEPARATOR=
...    E9A09000575F5A13560003C4A8002C00A0000040301262E003387A16009B20C39F30C7942C0E0980C0311C03EE3614606B04610D04083A41E006D6C98AB1A1CF88E3D033EC09F
...    1891C790E7D473E618F28581C0E1E0B801FF800E000BE000C80000E0541B107582308682041E20F0032B64C55890E7D813E238F1891C790E7D473E618F28581C0E1E13FB00000
...    0FEC000000C80000E0551B137582308682041D20F0030B64C55110E7C471E238F40CFB027C639F30C7942C0E070F05C00FFC007003FF000640000702A0D88DAC1184341020F10
...    780195B262AC4873E238F604F8C48E3C873EA39F30C7942C0E070F09FFF000007FFC000006400007003DE1E26800710400000858081507850001C46000002160561E230007104
...    000018581587850001C41000002160561E26800711800000858158B88C001C41000E208000050B02B0F0A000389A0000182C0AC5C4D000E2080070A000002058158B89A001C46
...    000E230000020B02B170A0003882001C46000004160562E1400071040038820000082C0AC5C4D000E20800711800001058158B850001C46000E230000020B02B1713400388C00
...    1C28000008160561E230007118000018581007011A014404D808232800BB07C28913639F0E14489B1CF870A244D8E7C3851226C73E1C28913639F0E2448913639F0E14081B1CF
...    811204081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF810A040D8E7C00170F18C6318C6318C6318C61E836001E0014
...    0E0A00E0601280380030120020301F04801000000008000010040000000200000401000004008000030040000200200001401000802008020000180100000E008004000000100
...    001000800009004000018020000280100001600800409024010000180672A6B2A6B052B032B066B056B296B266B016B036B012B022B07681A0800004B29282000032CA4A08000
...    14B29202000072CA480800024B292020000B2CA480800034B292020000F2CA480800044B29202000132CA480800054B29202000172CA4A0800064B29202000062CA480669555D
...    2AAAA55174AA2A82C55058AA0D154A62A93455018AA051549AAA83C50D005E02540A05028140A05028140A05028140A05028140A05000608080600C02004008404008020100C0
...    18402004008080600C02018030404030060100C018402004008080600C02004008804030060100C018040300608080100402004010D50F8000810182030385058606880889098
...    A0C0C8D8E0E8F909293139414951697A0A0C168

@{TP_activate_check}
...    transformPrecoder enabled
...    tp-pi2BPSK enabled
...    pusch-TimeDomainAllocationListDCI-0-1-r16 setup
...    pusch-RepTypeIndicatorDCI-0-1-r16 pusch-RepTypeA
...    criticalExtensions rrcReconfigurationComplete

@{TP_and_SAg_activate_check_after_add_5QI1}
...    Adding QosFlow with QFI:3 5QI:1
...    transformPrecoder enabled
...    tp-pi2BPSK enabled
...    pusch-RepTypeIndicatorDCI-0-1-r16 pusch-RepTypeA
...    drx-Config setup
...    betaOffsets dynamic
...    @{semiStatic_BetaOffsets_values}
...    @{moderate_BetaOffsets_values}
...    @{optimistic_BetaOffsets_values}
...    @{default_BetaOffsets_values}

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

@{HO_check_disabled_8236}
...    criticalExtensions rrcReconfiguration
...    eventId eventA3
...    transformPrecoder disabled
...    betaOffsets semiStatic
...    @{semiStatic_BetaOffsets_values}
...    tp-pi2BPSK enabled
...    pusch-TimeDomainAllocationListDCI-0-1-r16 release : NULL
...    Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.3 performed
...    drx-Config setup
...    transformPrecoder enabled
...    criticalExtensions rrcReconfigurationComplete

@{HO_check_enabled_8236}
...    criticalExtensions rrcReconfiguration
...    eventId eventA3
...    transformPrecoder enabled
...    betaOffsets dynamic
...    @{semiStatic_BetaOffsets_values}
...    @{moderate_BetaOffsets_values}
...    @{optimistic_BetaOffsets_values}
...    @{default_BetaOffsets_values}
...    tp-pi2BPSK enabled
...    pusch-TimeDomainAllocationListDCI-0-1-r16 setup
...    pusch-RepTypeIndicatorDCI-0-1-r16 pusch-RepTypeA
...    Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.3 performed
...    drx-Config setup
...    drx-onDurationTimer milliSeconds : ms40
...    drx-InactivityTimer ms6
...    drx-SlotOffset 0
...    criticalExtensions rrcReconfigurationComplete

@{TP_and_SAG_scell_check_for_center_center}
...    criticalExtensions rrcReconfiguration
...    drx-Config setup
...    transformPrecoder disabled
...    betaOffsets semiStatic
...    pusch-RepTypeIndicatorDCI-0-1-r16 pusch-RepTypeA
...    criticalExtensions rrcReconfigurationComplete


@{change_actUlSlotAgg_to_enabled_in_cell3}
...    NRCELL-3:actUlSlotAgg=Enabled_VoNr

${ACC_PUSCH_REP_TYPE_A_CAP_UE}    M55139C00025
${MAX_PUSCH_REP_TYPE_A_CAP_UE}    M55139C00026
${UE_CAP_DEN}    M55139C00027

@{PM_Counters_Check}
...    NRCELL-1:RSADU:${ACC_PUSCH_REP_TYPE_A_CAP_UE}>15
...    NRCELL-3:RSADU:${ACC_PUSCH_REP_TYPE_A_CAP_UE}>=13
...    NRCELL-1:RSADU:${MAX_PUSCH_REP_TYPE_A_CAP_UE}=1
...    NRCELL-3:RSADU:${MAX_PUSCH_REP_TYPE_A_CAP_UE}=1
...    last NRCELL-1:RSADU:${UE_CAP_DEN}=${60*${PM_COUNTER_INTERVAL[:-3]}}
...    last NRCELL-3:RSADU:${UE_CAP_DEN}=${60*${PM_COUNTER_INTERVAL[:-3]}}

*** Test Cases ***
CB008236_ET_B010_Verify_Intra gnb_Handover_Feature_is_disabled_on_target_cell
    [Documentation]
    ...    The purpose of this test case is to check following scenarios:
    ...    This scenario describes gNB behavior when a UE with a 5QI1 DRB in poor RF coverage while in Slot Aggregation mode, is handed over to a
    ...    neighbor cell with CB008236 feature enabled
    ...    UE does not perform Slot Aggregation as Feature is disabled on target cell.
    ...    Handover may be intra-gNB or inter-gNB. 
    ...    Requirement Coverage:
    ...    5G_RAN_USR_RRM_19911, fully covered
    ...    2.Test Case Steps:
    ...         Step A.UE Register on cell1 and Add Pdu with Default 5QI5
    ...         Step B.PDU Add QoSFlow 5QI6
    ...         Step C.UE moves towards cell edge
    ...         Step D.PDU Add QoSFlow 5QI1
    ...         Step E.trigger gNB source cell1 initiates handover to target cell3
    ...         Step F.release UE
    ...         Step G.wireshark logs check
    ...    3. Expected Results:
    ...         Step A: UE Register on cell1 and Add Pdu with Default 5QI5 is successfully
    ...         Step B: PDU Add QoSFlow 5QI6 is succefflly
    ...         Step C:
    ...          1)UE Transform Precoder enabled
    ...          2)gNB initiates RRCReconfiguration procedure to perform User Reconfiguration
    ...          3)pusch-TimeDomainAllocationListDCI-0-1-r16 is setup
    ...         Step D:
    ...          1)PDU Add QoSFlow 5QI1 is successfully
    ...          2)gNB initiates RRCReconfiguration procedure to perform User Reconfiguration
    ...          3)UE Transform Precoder enabled
    ...          4)gNB configures UE with SAg specific dynamic betaoffsets in UCI-onPUSCH IE
    ...          5)UE is configured with DRX Sleep Off, onDurationTimer equal to drx-LongCycle length
    ...         Step E.
    ...          1)Source cell includes UE capability for PUSCH repetition and TP enabled state info in HandoverPreparationInformation
    ...          2)as feature is disabled on target cell, gNB-CU-CP shall include the Rel15 TDRA table as per legacy behavior. as source cell
    ...            was configured with Rel16 TDRA table, then gNB-DU shall include Rel15 TDRA Table (pusch-TimeDomainAllocationList) and set it to
    ...            'release', gNB configures UE with legacy non-SAg specific dynamic betaoffsets in UCI-onPUSCH IE
    ...          3)gNB-L2PS shall not enter Slot Aggregation mode
    ...          4)during DRX profile2 setup, gNB-CU-CP shall setup DRX with profile2 parameter settings
    ...         Step F.UE is release successfully
    ...         Step G: wireshark logs check passed
    [Tags]    QC_303561
    UE Register And Add Pdu With Default 5QI5    ue_id=1
    PDU Add QoSFlow 5QI6    ue_id=1
    Trigger UE Transform Precoder enabled
    PDU Add QoSFlow 5QI1    ue_id=1
    IntraFre A3 Handover to cell3 with 8236 disabled
    Release UEs    ue_type=all
    Check WireShark Log    ${CURDIR}${/}A2A_CB008236_B010${/}a2a.ini    wait_string=UEContextReleaseComplete::4

CB008236_ET_B006_Verify_Intra_gnb_Handover_of_VoNR_UE_in_SAg_mode_Slot_Aggregation_continues_at_Target_Cell
    [Documentation]
    ...    The purpose of this test case is to check following scenarios:
    ...    This scenario describes gNB behavior when a UE with a 5QI1 DRB in poor RF coverage while in Slot Aggregation mode, is handed over to a 
    ...    neighbor cell with CB008236 feature enabled
    ...    gNB continues to remain in slot aggregation eligible state on the target cell.
    ...    Upon completion of handover, target cell sets up DRX profile2 at the UE with DRX sleep off state.
    ...    Handover may be intra-gNB or inter-gNB. 
    ...    Requirement Coverage:
    ...    5G_PM_1076, 5G_RAN_USR_RRM_19896, fully covered
    ...    2.Test Case Steps:
    ...         Step A.UE Register on cell1 and Add Pdu with Default 5QI5
    ...         Step B.PDU Add QoSFlow 5QI6
    ...         Step C.UE moves towards cell edge
    ...         Step D.PDU Add QoSFlow 5QI1
    ...         Step E.trigger gNB source cell1 initiates handover to target cell3
    ...         Step F.release UE
    ...         Step G.Check PUSCH Repetition related counters
    ...         Step H.wireshark logs check
    ...    3. Expected Results:
    ...         Step A: UE Register on cell1 and Add Pdu with Default 5QI5 is successfully
    ...         Step B: PDU Add QoSFlow 5QI6 is succefflly
    ...         Step C:
    ...          1)UE Transform Precoder enabled
    ...          2)gNB initiates RRCReconfiguration procedure to perform User Reconfiguration
    ...          3)pusch-TimeDomainAllocationListDCI-0-1-r16 is setup
    ...         Step D:
    ...          1)PDU Add QoSFlow 5QI1 is successfully
    ...          2)gNB initiates RRCReconfiguration procedure to perform User Reconfiguration
    ...          3)UE Transform Precoder enabled
    ...          4)gNB configures UE with SAg specific dynamic betaoffsets in UCI-onPUSCH IE
    ...          5)UE is configured with DRX Sleep Off, onDurationTimer equal to drx-LongCycle length
    ...         Step E.
    ...          1)Source cell includes UE capability for PUSCH repetition and TP enabled state info in HandoverPreparationInformation
    ...          2)
    ...          a)Target cell gNB-DU-CP configures Rel16 TDRA table in RRCReconfiguration to UE as part of Handover Command
    ...          b)gNB-DU-CP configures Rel16 TDRA table (pusch-TimeDomainAllocationListDCI-0-1-r16) in PUSCH-Config as part of uplinkBWPConfig for 
    ...          each of the dedicated BWP's to be configured (UplinkConfig -> uplinkBWP-ToAddModList -> #BWP-Uplink -> bwp-Dedicated)
    ...          Note: due to delta configuration, target cell gNB-DU-CP may choose to not include the IE as mentioned above, if the IE is already 
    ...          configured at the UE as indicated by PUSCH-Config received from source cell in HandoverPreparationInformation
    ...          c)The Rel15 TDRA table PUSCH-TimeDomainAllocationList is not configured if Rel16 IE is configured
    ...          d)gNB configures UE with SAg specific dynamic betaoffsets in UCI-onPUSCH IE	
    ...          3)UE sends RRCReconfigurationComplete to target cell gNB and as per legacy behavior, the Handover procedure is completed
    ...          4)NB-DU enters Slot Aggregation eligible state
    ...          5)gNB sets up VoNR DRX profile2 with DRX Sleep Off
    ...         Step F.UE is release successfully
    ...         Step G: ALL PUSCH Repetition related counters is update is correct
    ...         Step H: wireshark logs check passed
    [Tags]    QC_303565
    Online changes the actUlSlotAgg to enabled in cell3
    clear counter files
    UE Register And Add Pdu With Default 5QI5    ue_id=2
    PDU Add QoSFlow 5QI6    ue_id=2
    Trigger UE Transform Precoder enabled    ue_id=2
    PDU Add QoSFlow 5QI1    ue_id=2
    IntraFre A3 Handover to cell3 with 8236 enabled    ue_id=2
    Simulate From Cell Edge to Cell Center
    sleep    2s
    Trigger UE Transform Precoder enabled    ue_id=2
    Release UEs    ue_type=all
    Check Counters    ${PM_Counters_Check}

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/3cells_1T2F

Modify Cfg
    Update Cfg    ue_param id=1 ue_nr_capabilities=${SA_Capa_Support_SAG} nr_usage_setting=voice_centric
    Update Cfg    ue_param id=2 ue_nr_capabilities=${SA_Capa_Support_SAG} nr_usage_setting=voice_centric
    Update Cfg    amf_param id=1 full_nas_auth=on nia=null+aes nea=null+aes ims_voice_3gpp=on
    ${set_ue1}    catenate
    ...    set_ue simulated id=1 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56
    ...    opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+aes nea=null+aes sec_key=0102030405060708090A0B0C0D0EFF00
    ...    suci=0:311:489:0000:0:0:021645400 mode=nr enb=2 cell=1
    Update Cfg    ${set_ue1}
    Update Cfg    ue_nr_capabilities id=1 voice_over_nr=on:on:off
    ${set_ue2}    catenate
    ...    set_ue simulated id=2 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56
    ...    opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+aes nea=null+aes sec_key=0102030405060708090A0B0C0D0EFF00
    ...    suci=0:311:489:0000:0:0:021645401 mode=nr enb=2 cell=1
    Update Cfg    ${set_ue2}
    Update Cfg    ue_nr_capabilities id=2 voice_over_nr=on:on:off
    Update Cfg    set_qosflow id=1 5qi=5 default=on
    Update Cfg    set_qosflow id=2 5qi=1
    Update Cfg    set_qosflow id=3 5qi=6 default=off
    Update Cfg    set_qosrule id=1 proto=tcp qos_flow=1
    Update Cfg    set_qosrule id=2 proto=udp qos_flow=2
    Update Cfg    set_qosrule id=3 proto=udp qos_flow=3
    Update Cfg    set_nwslice id=1 snssai=0x01:0xD143A5 qos_flows=1,2,3 qos_rules=1,2,3 default=on ue=1-6 amf=1

UE Register And Add Pdu With Default 5QI5
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_register id=${ue_id} nwslice=1    pass_regexp=Received REGISTRATION COMPLETE
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${ue_id}    
    ...    pass_regexp=UE${ue_id}: Ue ${ue_id} PduId 1 Created FiveQi:Qfi mapping fiveQi 5 qfi 1

PDU Add QoSFlow 5QI6
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=3 by=amf    pass_regexp=Added QosFlow with QFI:2 fiveQI:6
    Run Traffic    ue_id=${ue_id}

PDU Add QoSFlow 5QI1
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=2 by=amf    
    ...    pass_regexp=${TP_and_SAg_activate_check_after_add_5QI1}


Run Traffic
    [Arguments]    ${ue_id}=1
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=2 trf_id=1 mbps=10 dir=ul
    Verify Throughput    ue_id=${ue_id}

Verify Throughput
    [Arguments]    ${ue_id}=1    ${Tput_ul}=8    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=2    direction=ul    rate_type=ave
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pdsch    Throughput
    Should Not Match Regexp    ${scell_tput}    CellIndex-.*Mbps.*Mbps.*Mbps.* 0 Mbps
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

Trigger UE Transform Precoder enabled
    [Arguments]    ${ue_id}=1
    Execute Egate Command     ul_sinr_testmode_nr profile_id=2 pathloss=118
    Execute Egate Command     ue_testmode_set_nr id=${ue_id} testmode=ul_sinr profile_id=2 action=activate    pass_regexp=${TP_activate_check}

IntraFre A3 Handover to cell3 with 8236 disabled
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=1 event=A3 phycell_id=61    pass_regexp=${HO_check_disabled_8236}

IntraFre A3 Handover to cell3 with 8236 enabled
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=1 event=A3 phycell_id=61    pass_regexp=${HO_check_enabled_8236}
    sleep    10s    #wait counter update and check UE not release

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir

Online changes the actUlSlotAgg to enabled in cell3
    OnlineParamChange    ${change_actUlSlotAgg_to_enabled_in_cell3}
    Execute Egate Command     ue_testmode_set_nr id=1 testmode=ul_sinr profile_id=2 action=deactivate
    Execute Egate Command     ul_sinr_testmode_nr profile_id=2 delete=1

Simulate From Cell Edge to Cell Center
    Execute Egate Command     ul_sinr_testmode_nr profile_id=2 pathloss=30
    ...    pass_regexp=@{TP_and_SAG_scell_check_for_center_center}
    Execute Egate Command     ue_testmode_set_nr id=1 testmode=ul_sinr profile_id=2 action=deactivate    #ul_sinr recover
    Execute Egate Command     ul_sinr_testmode_nr profile_id=2 delete=1    #ul_sinr recover
