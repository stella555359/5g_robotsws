*** Settings ***
Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CRT    CLOUD_5G_I_BLLL_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD
...    team-L3CN3_SG2    owner-Song.xiuli    release-5G22R2
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
${carrierfreq_cell1}    518910
${carrierfreq_cell2}    633216
${carrierfreq_cell12}    126750
${phycelId_1}    50
${phycelId_12}    61

@{PARAMS_IN_SCF}
...    @{5GC000732_Base}
...    @{CELL1}
...    @{CELL2}
...    @{CELL12}
...    @{CELL1_CELL2}
...    @{CELL2_CELL1}
...    @{CELL1_CELL12}
...    @{CELL12_CELL1}
...    @{bwp_related}

@{5GC000732_Base}
...    NRBTS-1:rrcReestabTypeSA=sameGNB
...    NRBTS-1:actConflictConfiguration=true
...    NRBTS-1:actLteNrDss=false
...    NRBTS-1:actFdmEnhancedScheduling=true
...    NRBTS-1:actFdmScheduling=true
...    NRBTS-1:tWaitingRlRecover=4000ms
...    NRBTS:actInterFreqHoSA=true
...    NRBTS-1/NRPMRNL-1:miNrRelReportCu=5min
...    NRBTS-1/NRCELL-1:actCDrx=true

@{CELL1}
...    NRCELL-1:a1MeashoEnabledSA=rsrp
...    NRCELL-1:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRCELL-1:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=95
...    NRCELL-1:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms0
...    NRCELL-1:a2MeashoEnabledSA=rsrp
...    NRCELL-1:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=90
...    NRCELL-1:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0
...    NRCELL-1:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms0
...    NRCELL-1:rsrpThresholdSSB=15
...    NRCELL-1:sMeasConfigSsbRsrp=1
...    NRCELL-1:absThreshSsbRsrpConsolidation=1
...    NRCELL-1:freqBandIndicatorNR=41
...    NRCELL-1:gscnOrSsPbchArfcn=6486
...    NRCELL-1:type0CoresetConfigurationIndex=0

@{CELL2}
...    NRCELL-2:a1MeashoEnabledSA=rsrp
...    NRCELL-2:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRCELL-2:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=95
...    NRCELL-2:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms0
...    NRCELL-2:a2MeashoEnabledSA=rsrp
...    NRCELL-2:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=90
...    NRCELL-2:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0
...    NRCELL-2:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms0
...    NRCELL-2:rsrpThresholdSSB=11
...    NRCELL-2:sMeasConfigSsbRsrp=1
...    NRCELL-2:absThreshSsbRsrpConsolidation=1
...    NRCELL-2:freqBandIndicatorNR=78
...    NRCELL-2:gscnOrSsPbchArfcn=7845

@{CELL12}
...    NRCELL-12:a1MeashoEnabledSA=rsrp
...    NRCELL-12:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRCELL-12:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=95
...    NRCELL-12:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms0
...    NRCELL-12:a2MeashoEnabledSA=rsrp
...    NRCELL-12:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=90
...    NRCELL-12:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0
...    NRCELL-12:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms0
...    NRCELL-12:rsrpThresholdSSB=11
...    NRCELL-12:sMeasConfigSsbRsrp=1
...    NRCELL-12:absThreshSsbRsrpConsolidation=1
...    NRCELL-12:freqBandIndicatorNR=71
...    NRCELL-12:gscnOrSsPbchArfcn=1584


@{CELL1_CELL2}
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-1:gNbId=1
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-1:lcrId=2
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:removeNotAllowed=false
...    delete:NRCELL-1/NRREL-1:sCellAdditionMethod
...    delete:NRCELL-1/NRREL-1:sCellOperationalMode

...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=5
...    NRCELL-1/NRHOIF-1:cellDepType=SA
...    NRCELL-1/NRHOIF-1:freqBandIndicatorNR=78
...    NRCELL-1/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-1/NRHOIF-1:a1BasedPCellSwitchEnabled=false
...    NRCELL-1/NRHOIF-1:ssBurstSetPeriod=10
...    NRCELL-1/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-1:a5MeasEnabled=none
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-1/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-1/NRHOIF-1:ssbFrequency=633216
...    NRCELL-1/NRHOIF-1:scs=30 KHz

@{CELL2_CELL1}
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-1:gNbId=1
...    NRCELL-2/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-1:lcrId=1
...    NRCELL-2/NRREL-1:gNbIdLength=22
...    NRCELL-2/NRREL-1:removeNotAllowed=false
...    delete:NRCELL-2/NRREL-1:sCellAdditionMethod
...    delete:NRCELL-2/NRREL-1:sCellOperationalMode
...    NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=5
...    NRCELL-2/NRHOIF-1:cellDepType=SA
...    NRCELL-2/NRHOIF-1:freqBandIndicatorNR=41
...    NRCELL-2/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-2/NRHOIF-1:a1BasedPCellSwitchEnabled=false
...    NRCELL-2/NRHOIF-1:ssBurstSetPeriod=10
...    NRCELL-2/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-2/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-2/NRHOIF-1:a5MeasEnabled=none
...    NRCELL-2/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-2/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-2/NRHOIF-1:ssbFrequency=518910
...    NRCELL-2/NRHOIF-1:scs=30 KHz

@{CELL1_CELL12}
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-1:gNbId=1
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-1:lcrId=12
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:removeNotAllowed=false
...    delete:NRCELL-1/NRREL-1:sCellAdditionMethod
...    delete:NRCELL-1/NRREL-1:sCellOperationalMode

...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=5
...    NRCELL-1/NRHOIF-1:cellDepType=SA
...    NRCELL-1/NRHOIF-1:freqBandIndicatorNR=71
...    NRCELL-1/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-1/NRHOIF-1:a1BasedPCellSwitchEnabled=false
...    NRCELL-1/NRHOIF-1:ssBurstSetPeriod=10
...    NRCELL-1/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-1:a5MeasEnabled=none
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-1/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-1/NRHOIF-1:ssbFrequency=126750
...    NRCELL-1/NRHOIF-1:scs=15 KHz

@{CELL12_CELL1}
...    NRCELL-12/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-1:gNbId=1
...    NRCELL-12/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-1:lcrId=1
...    NRCELL-12/NRREL-1:gNbIdLength=22
...    NRCELL-12/NRREL-1:removeNotAllowed=false
...    delete:NRCELL-12/NRREL-1:sCellAdditionMethod
...    delete:NRCELL-12/NRREL-1:sCellOperationalMode

...    NRCELL-12/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL-12/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-12/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=5
...    NRCELL-12/NRHOIF-1:cellDepType=SA
...    NRCELL-12/NRHOIF-1:freqBandIndicatorNR=41
...    NRCELL-12/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-12/NRHOIF-1:a1BasedPCellSwitchEnabled=false
...    NRCELL-12/NRHOIF-1:ssBurstSetPeriod=10
...    NRCELL-12/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-12/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-12/NRHOIF-1:a5MeasEnabled=none
...    NRCELL-12/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-12/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-12/NRHOIF-1:ssbFrequency=518910
...    NRCELL-12/NRHOIF-1:scs=30 KHz

@{bwp_related}
...    NRBTS-1:actMultipleDedicatedBWPs=true
...    NRBTS-1:timerXnDataFwdGuard=250
...    NRBTS-1:cipherPrefL:nea0=8
...    NRBTS-1:cipherPrefL:nea1_128=0
...    NRBTS-1:cipherPrefL:nea2_128=0
...    NRBTS-1:cipherPrefL:nea3_128=0

...    NRBTS-1/BWP_PROFILE-1:bwpType=initial
...    NRBTS-1/BWP_PROFILE-1:locationAndBandwidthDl:cRbSizeDl=coreset0
...    NRBTS-1/BWP_PROFILE-1:locationAndBandwidthDl:cRbStartDl=coreset0
...    NRBTS-1/BWP_PROFILE-1:locationAndBandwidthUl:cRbSizeUl=allRb
...    NRBTS-1/BWP_PROFILE-1:locationAndBandwidthUl:cRbStartUl=crb0

...    NRBTS-1/BWP_PROFILE-2:bwpType=dedicated
...    NRBTS-1/BWP_PROFILE-2:locationAndBandwidthDl:cRbSizeDl=allRb
...    NRBTS-1/BWP_PROFILE-2:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS-1/BWP_PROFILE-2:locationAndBandwidthUl:cRbSizeUl=allRb
...    NRBTS-1/BWP_PROFILE-2:locationAndBandwidthUl:cRbStartUl=crb0

...    NRBTS-1/BWP_PROFILE-3:bwpType=initial
...    NRBTS-1/BWP_PROFILE-3:locationAndBandwidthDl:cRbSizeDl=coreset0
...    NRBTS-1/BWP_PROFILE-3:locationAndBandwidthDl:cRbStartDl=coreset0
...    NRBTS-1/BWP_PROFILE-3:locationAndBandwidthUl:cRbSizeUl=allRb
...    NRBTS-1/BWP_PROFILE-3:locationAndBandwidthUl:cRbStartUl=crb0

...    NRBTS-1/BWP_PROFILE-4:bwpType=dedicated
...    NRBTS-1/BWP_PROFILE-4:locationAndBandwidthDl:cRbSizeDl=allRb
...    NRBTS-1/BWP_PROFILE-4:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS-1/BWP_PROFILE-4:locationAndBandwidthUl:cRbSizeUl=allRb
...    NRBTS-1/BWP_PROFILE-4:locationAndBandwidthUl:cRbStartUl=crb0

...    NRBTS-1/BWP_PROFILE-5:bwpType=dedicated
...    NRBTS-1/BWP_PROFILE-5:locationAndBandwidthDl:cRbSizeDl=n133
...    NRBTS-1/BWP_PROFILE-5:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS-1/BWP_PROFILE-5:locationAndBandwidthUl:cRbSizeUl=sameAsDl
...    NRBTS-1/BWP_PROFILE-5:locationAndBandwidthUl:cRbStartUl=sameAsDl

...    NRBTS-1/BWP_PROFILE-5/PDSCH-1:pdschRat0RbgConfig=config1
...    NRBTS-1/BWP_PROFILE-5/PDCCH-1:alSelection=static
...    NRBTS-1/BWP_PROFILE-5/PDCCH-1:dciDedicatedAggregationLevel=AL4
...    NRBTS-1/BWP_PROFILE-5/PDCCH-1:dciPagingAggregationLevel=AL4
...    NRBTS-1/BWP_PROFILE-5/PDCCH-1:dciRaCompletionAggregationLevel=AL4
...    NRBTS-1/BWP_PROFILE-5/PDCCH-1:dciRaMsg2AggregationLevel=AL4
...    NRBTS-1/BWP_PROFILE-5/PDCCH-1:dciSiAggregationLevel=AL4
...    NRBTS-1/BWP_PROFILE-5/PDCCH-1:downgradeAL16toAL8=notAllowed


...    NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=9
...    NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=9
...    NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=9|searchSpaceId=9
...    NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=9
...    NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=9
...    NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=9
...    NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=9
...    NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=9
...    NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|searchSpaceId=9
...    NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=9|searchSpaceId=9
...    NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=9
...    NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=4|searchSpaceId=9

...    NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=10
...    NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=10
...    NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=10
...    NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=10
...    NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=10
...    NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=10
...    NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=10
...    NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=10
...    NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=10
...    NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=10|searchSpaceId=10
...    NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=10
...    NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=10

...    NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=11
...    NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=11
...    NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=9|searchSpaceId=11
...    NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=11
...    NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=11
...    NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=11
...    NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=11
...    NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=11
...    NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|searchSpaceId=11
...    NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=11|searchSpaceId=11
...    NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=11
...    NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=4|searchSpaceId=11

...    NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cceToRegMapping=nonInterleaved
...    NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:coresetId=4
...    NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cRbStart=0
...    NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:duration=1
...    NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:interleaverSize=none
...    NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:regBundleSize=n6
...    NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=120

...    NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=0|searchSpaceId=12
...    NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-0-And-1-0|searchSpaceId=12
...    NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|searchSpaceId=12
...    NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=12
...    NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|searchSpaceId=12
...    NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceId=12
...    NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|searchSpaceId=12
...    NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|searchSpaceId=12
...    NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceId=12
...    NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl10|searchSpaceId=12
...    NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=12|searchSpaceId=12
...    NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|searchSpaceId=12
...    NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|searchSpaceId=12

...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=4|searchSpaceId=13
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|searchSpaceId=13
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|searchSpaceId=13
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=13
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|searchSpaceId=13
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceId=13
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|searchSpaceId=13
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n5|searchSpaceId=13
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceId=13
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|searchSpaceId=13
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=13|searchSpaceId=13
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|searchSpaceId=13
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|searchSpaceId=13

...    MRBTS-1/NRBTS-1/NRCELL-1:cellBwpList:bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-3|cellBwpId=0
...    MRBTS-1/NRBTS-1/NRCELL-1:cellBwpList:bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-4|cellBwpId=1
...    MRBTS-1/NRBTS-1/NRCELL-1:cellBwpList:bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-5|cellBwpId=2


@{PM_Counters_Check}
...    NRDU-1:${REESTAB_ACC_OTHER_FAIL_DU}=1
...    NRDU-1:${RRC_REESTAB_OTHER_FAILURE_DU}=1
...    NRCELL-1:${RRC_REESTAB_OTHER_FAILURE}=1
...    NRCELL-1:${REESTAB_ACC_OTHER_FAIL}=1
...    NRCELL-1:${REESTAB_RRCRECONFIG_SUCC}=1
...    NRCELL-1:${F1_UE_CTXT_MOD_REQ_SENT}>0
...    NRCELL-1:${F1_UE_CTXT_MOD_RESP_RECEIVED}>0
...    NRCELL-1:${NF1CC_DL_RRC_MSG_TRANSFER}=6
...    NRCELL-1:${NF1CC_UL_RRC_MSG_TRANSFER}=8
...    NRCELL-1:${NRRCC_RRC_RECONF_SENT}=4
...    NRCELL-1:${NRRCC_RRC_RECONF_CMP_RECD}=4
...    NRCELL-1:${SGNB_SA_DU_ADMISSION_REQ}=1
...    NRCELL-1:${SGNB_SA_DU_ADMISSION_SUCC}=1
...    NRCELL-1:${SGNB_SA_DU_NGBR_DRB_REQ}=1
...    NRCELL-1:${SGNB_SA_DU_NGBR_DRB_SUCC}=1
...    NRCELL-1:${SGNB_SA_DU_NGBR_DRB_REL}=2
...    NRCELL-1:${GNB_SA_DU_ADM_SUCC_BWP1}=2
...    NRCELL-1:${GNB_SA_DU_ADM_SUCC_BWP2}=0

${F1_UE_CTXT_MOD_REQ_SENT}    M55113C00001
${F1_UE_CTXT_MOD_RESP_RECEIVED}    M55113C00002
${NF1CC_DL_RRC_MSG_TRANSFER}    M55113C00501
${NF1CC_UL_RRC_MSG_TRANSFER}    M55113C00502
${NRRCC_RRC_RECONF_SENT}    M55124C03001
${NRRCC_RRC_RECONF_CMP_RECD}    M55124C03002
${SGNB_SA_DU_ADMISSION_REQ}    M55139C00001
${SGNB_SA_DU_ADMISSION_SUCC}    M55139C00002
${SGNB_SA_DU_NGBR_DRB_REQ}    M55139C00003
${SGNB_SA_DU_NGBR_DRB_SUCC}    M55139C00004
${SGNB_SA_DU_NGBR_DRB_REL}    M55139C00012
${GNB_SA_DU_ADM_SUCC_BWP1}    M55139C02501
${RRC_REESTAB_OTHER_FAILURE_DU}    M55127C00503
${RRC_REESTAB_OTHER_FAILURE}    M55124C00505
${REESTAB_ACC_OTHER_FAIL_DU}    M55127C00512
${REESTAB_ACC_OTHER_FAIL}    M55124C00512
${REESTAB_RRCRECONFIG_SUCC}    M55124C00516
${GNB_SA_DU_ADM_SUCC_BWP2}    M55139C02502

${otherFailure}    otherFailure

#this UE capblity support small BWP
${ue_capa}    SEPARATOR=
...    E9A09380575F5A13160003C320016093170019C3D09009B20C39F30C7942C0E09
...    8040623807DC6C28C0D608C21A08107482406D6C98AB1A1CF88E3D033EC09F1891C790E7D473E618F28581C0E1E0B
...    801FE000E000B800088000E0541B107582308682041E2090195B262AC4873EC09F11C78C48E3C873EA39F30C7942C
...    0E070F09FD8000007F600000044000702A8D89BAC1184341020E90480C2D931544439F11C788E3D033EC09F18E7CC
...    31E50B0381C3C17003FF001C00FFC00110001C0A836236B04610D04083C412032B64C55890E7C471EC09F1891C790
...    E7D473E618F28581C0E1E13FFE00000FFF80000088000E0083C3C4D000E208000010B0102A0F0A000388C0000042C
...    0AC3C46000E208000030B02B0F0A00038820000042C0AC3C4D000E230000010B02B17118003882001C4100000A160
...    561E14000713400003058158B89A001C41000E140000040B02B1713400388C001C46000004160562E140007104003
...    88C0000082C0AC5C28000E20800710400001058158B89A001C41000E230000020B02B170A000388C001C460000041
...    60562E2680071180038500000102C0AC3C46000E230000030B02A070A0000038581007011A014404D80821A831421
...    0A244D8E7C3851226C73E1C28913639F0E14489B1CF870A244D8E7C38912244D8E7C3850206C73E044810206C73E0
...    44810206C73E044810206C73E044810206C73E044810206C73E044810206C73E044810206C73E0428103639F02040
...    D8E7C00064406318C6318C6318C6318C07A09801E00140E0A00E0601280380030120020301F048010000000080000
...    10040000000200000401000004008000030040000200200001401000802008020000180100000E008004000000100
...    00100080000900400001802000028010000160080040902401000018063276B2A6B052B032B066B056B296B266B01
...    6B036B012B022B07681A0800004B29282000032CA4A0800014B29202000072CA480800024B292020000B2CA480800
...    034B292020000F2CA480800044B29202000132CA480800054B29202000172CA4A0800064B29202000062CA4806695
...    55527AAA55174AA2A82C55058AA0D154A62A93455018AA051549AAA83C5090178095028140A05028140A05028140A
...    05028140A0502814001C2020180300801002101002008040300610080100202018030080600C10100C01804030061
...    0080100202018030080100220100C01804030060100C01820200401008010040010020086A87C0004080C10181C28
...    2C30344044484C5060646C70747C8494989CA0A4A8B4BD05060B40

*** Test Cases ***
5GC000732-ET-F100_HO_success_after_RRC_reestablish
    [Documentation]    This case will combine F100(5GC000732-ET-F100_HO_success_after_RRC_reestablish)
    ...    preconditions:
    ...    modify UE capablity to support small bwp.
    ...    Case steps:
    ...    1.Trigger Normal call with cell 2
    ...    2.Trigger HO from cell 2 to cell cell 1, HO should be succesffully
    ...    3.Trgger RRC reestablish from cell 1 to cell 1, RRC reestablish successfully
    ...    4.Trigger HO from cell 1 to cell 12,HO should be succesfully

    [Tags]    QC_XXXX    F100
    Clear Counter Files    false
    Ue Register And Pdu Session Setup
    Trigger UE HO to gNB CELL1
    Trigger RRC Reestablish    ${otherFailure}
    Trigger UE HO to CELL12
    Check Counters    ${PM_Counters_Check}
    Release Ues    ue_type=all
    Check Wireshark Log    ${CURDIR}${/}a2a_F100${/}a2a.ini    wait_string=UEContextReleaseComplete::4

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/L1B/6cells_2T4F


Modify Cfg
    Update Cfg    set_qosflow id=2 5qi=5
    Update Cfg    set_qosflow id=3 5qi=1
    Update Cfg    set_qosflow id=4 5qi=2
    Update Cfg    set_qosrule id=1 proto=tcp qos_flow=2
    Update Cfg    set_qosrule id=2 proto=udp qos_flow=3
    Update Cfg    set_qosrule id=3 proto=udp qos_flow=4
    Update Cfg    ue_param id=82 ue_nr_capabilities=${ue_capa}

Ue Register And Pdu Session Setup
    [Arguments]    ${ue_id}=82
    Execute Egate Command    qosflow_modify qos_flow=1 default=on
    Execute Egate Command    ue_location_change id=${ue_id} enb=2 cell=2
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=UE now in NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=1    pass_regexp=QoS Routing Table
    Send Throuput
    Verify Throughput

Trigger UE HO to gNB CELL1
    Trigger A2 measurement report    ${carrierfreq_cell2}
    Trigger A3 Measurement Report    ${carrierfreq_cell1}    ${phycelId_1}
    Verify Throughput

Trigger UE HO to CELL12
    Trigger A2 measurement report    ${carrierfreq_cell1}
    Trigger A3 Measurement Report    ${carrierfreq_cell12}    ${phycelId_12}
    Verify Throughput

Trigger A2 measurement report
    [Arguments]    ${carrierfreq}
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=82    carrierfreq=${carrierfreq}    event_type=A2
    Execute Egate Command
    ...    ue_measurement_send_nr id=82 meas_id=${meas_id} event=A2 srsrp_nr=30 srsrq_nr=30
    ...    rrcReconfigurationComplete

Trigger A3 Measurement Report
    [Arguments]    ${carrierfreq}    ${phycelId}
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=82    carrierfreq=${carrierfreq}    event_type=A3
    ${V3}    catenate
    ...    ue_measurement_send_nr id=82 meas_id=${meas_id} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=${phycelId} nrsrp_nr=60 nrsrq_nr=60
    ...    rs_type=ssb index=0 nrs_result=30:30:30
    Execute Egate Command    ${V3}    Intra-eNB handover
    Verify Throughput

Trigger RRC Reestablish
    [Arguments]    ${cause}
    ${ret1}=    Execute Egate Command    ue_rrc_reestablish id=82 gnb=2 cell=1 cause=${cause}
    ...    NR RRC Reestablishment sucessfully completed    timeout=20s
    Verify Throughput

Send Throuput
    [Arguments]    ${ue_id}=82
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=1 mbps=100    UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=2 mbps=100    UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=3 mbps=100    UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=4 mbps=100    UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=ul trf_id=5 mbps=100    UDP UL
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pdsch

Verify Throughput
    [Arguments]    ${ue_id}=82    ${Tput_dl}=90    ${Tput_ul}=10    ${sleep_time}=15s
    [Documentation]    verify Tput in scell is not 0
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pdsch    Throughput
    Should Not Match Regexp    ${scell_tput}    CellIndex-.*Mbps.*Mbps.*Mbps.* 0 Mbps
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}