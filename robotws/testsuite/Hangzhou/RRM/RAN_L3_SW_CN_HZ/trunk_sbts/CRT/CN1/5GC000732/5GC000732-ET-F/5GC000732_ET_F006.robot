*** Settings ***
Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags      QCD_MN_RAN    QCP_RAN_ET    RAN_5G    RAN_5G_TDD    CRT    SBTS00
...    owner-liupei.fang    owner-shelly.song    team-SG2    release-SBTS22R2    5GC000732
...    CLOUD_5G_I_BLLL_AP_LOO
Resource    ../../../../../resources/DevHZ5_resource.robot


*** Variables ***
@{PARAMS_IN_SCF}    
...    @{5GC000732_Base}
...    @{CELL_Base}

@{5GC000732_Base}
...    NRBTS-1:rrcReestabTypeSA=sameGNB
...    NRBTS-1:actIntraFreqHoSA=true
...    NRBTS-1:timerXnDataFwdGuard=250
...    NRBTS-1:actInterFreqHoSA=true
...    NRBTS-1:actMultipleDedicatedBWPs=true
...    NRBTS-1:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS-1:tWaitingRlRecover=4000ms
...    NRPMRNL-1:miNrRelReportCu=15min
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5:bwpType=dedicated
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5:locationAndBandwidthDl:cRbSizeDl=n133
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5:locationAndBandwidthDl:cRbStartDl=crb0
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5:locationAndBandwidthUl:cRbSizeUl=sameAsDl
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5:locationAndBandwidthUl:cRbStartUl=sameAsDl
...    NRBTS-1/BWP_PROFILE-2:bwpType=dedicated
...    NRBTS-1/BWP_PROFILE-2:locationAndBandwidthDl:cRbSizeDl=allRb
...    NRBTS-1/BWP_PROFILE-2:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS-1/BWP_PROFILE-2:locationAndBandwidthUl:cRbSizeUl=allRb
...    NRBTS-1/BWP_PROFILE-2:locationAndBandwidthUl:cRbStartUl=crb0
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceType=Type0A
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceType=Type0A
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=9|searchSpaceType=Type0A
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceType=Type0A
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceType=Type0A
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceType=Type0A
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceType=Type0A
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceType=Type0A
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|searchSpaceType=Type0A
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=9|searchSpaceType=Type0A
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=4|searchSpaceType=Type0A
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceType=Type1
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceType=Type1
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceType=Type1
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceType=Type1
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceType=Type1
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceType=Type1
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceType=Type1
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceType=Type1
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceType=Type1
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=10|searchSpaceType=Type1
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceType=Type1
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceType=Type2
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceType=Type2
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=9|searchSpaceType=Type2
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceType=Type2
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceType=Type2
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceType=Type2
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceType=Type2
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceType=Type2
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|searchSpaceType=Type2
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=11|searchSpaceType=Type2
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=4|searchSpaceType=Type2
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cceToRegMapping=nonInterleaved
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:coresetId=4
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cRbStart=0
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:duration=1
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:interleaverSize=none
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:regBundleSize=n6
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=120
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=0|searchSpaceType=Type3
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-0-And-1-0|searchSpaceType=Type3
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|searchSpaceType=Type3
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|searchSpaceType=Type3
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceType=Type3
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|searchSpaceType=Type3
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|searchSpaceType=Type3
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceType=Type3
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl10|searchSpaceType=Type3
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=12|searchSpaceType=Type3
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|searchSpaceType=Type3
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=4|searchSpaceType=UE-Specific
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|searchSpaceType=UE-Specific
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|searchSpaceType=UE-Specific
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|searchSpaceType=UE-Specific
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceType=UE-Specific
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|searchSpaceType=UE-Specific
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n5|searchSpaceType=UE-Specific
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceType=UE-Specific
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|searchSpaceType=UE-Specific
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=13|searchSpaceType=UE-Specific
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|searchSpaceType=UE-Specific
...    NRBTS-1/BWP_PROFILE-3:bwpType=initial
...    NRBTS-1/BWP_PROFILE-3:locationAndBandwidthDl:cRbSizeDl=allRb
...    NRBTS-1/BWP_PROFILE-3:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS-1/BWP_PROFILE-3:locationAndBandwidthUl:cRbSizeUl=allRb
...    NRBTS-1/BWP_PROFILE-3:locationAndBandwidthUl:cRbStartUl=crb0
...    NRBTS-1/BWP_PROFILE-4:bwpType=dedicated
...    NRBTS-1/BWP_PROFILE-4:locationAndBandwidthDl:cRbSizeDl=allRb
...    NRBTS-1/BWP_PROFILE-4:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS-1/BWP_PROFILE-4:locationAndBandwidthUl:cRbSizeUl=allRb
...    NRBTS-1/BWP_PROFILE-4:locationAndBandwidthUl:cRbStartUl=crb0
...    NRBTS-1/BWP_PROFILE-1:bwpType=initial
...    NRBTS-1/BWP_PROFILE-1:locationAndBandwidthDl:cRbSizeDl=coreset0
...    NRBTS-1/BWP_PROFILE-1:locationAndBandwidthDl:cRbStartDl=coreset0
...    NRBTS-1/BWP_PROFILE-1:locationAndBandwidthUl:cRbSizeUl=allRb
...    NRBTS-1/BWP_PROFILE-1:locationAndBandwidthUl:cRbStartUl=crb0
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1:alSelection=static
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1:dciDedicatedAggregationLevel=AL4
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1:dciPagingAggregationLevel=AL4
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1:dciRaCompletionAggregationLevel=AL4
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1:dciRaMsg2AggregationLevel=AL4
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1:dciSiAggregationLevel=AL4
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1:downgradeAL16toAL8=notAllowed
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDSCH-1:pdschRat0RbgConfig=config1
...    NRBTS:actMultipleDedicatedBWPs=true
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS:actIntraFreqHoSA=true
...    NRBTS:actInterFreqHoSA=true
...    NRBTS:timerXnDataFwdGuard=250
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:actInterNumerologyCa=true
...    NRDU-1:carrierAggregationSupportList=ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Any_Sa
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=${value}

@{CELL_Base}
...    NRCELL:actPrachMultiplexing=true
...    NRCELL-1:actK1Opt=intra-gNB
...    NRCELL-2:actK1Opt=intra-gNB
...    MRBTS-1/NRBTS-1/NRCELL-1:cellBwpList:bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-3|cellBwpId=0
...    MRBTS-1/NRBTS-1/NRCELL-1:cellBwpList:bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-4|cellBwpId=1
...    MRBTS-1/NRBTS-1/NRCELL-1:cellBwpList:bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-5|cellBwpId=2
...    NRCELL-1/NRHOIF-1:a1BasedPCellSwitchEnabled=false
...    NRCELL-1/NRHOIF-1:a2BasedPCellSwitchEnabled=false
...    NRCELL-1/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-1/NRHOIF-1:freqBandIndicatorNR=71
...    NRCELL-1/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf5
...    NRCELL-1/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-1/NRHOIF-1:scs=15 KHz
...    NRCELL-1/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-1:ssbFrequency=126750
...    NRCELL-1/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-1:gNbId=35
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:lcrId=1
...    NRCELL-1/NRREL-1:removeNotAllowed=false
...    NRCELL-1/NRREL-1:nrDcAllowed=false
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-10:gNbId=1
...    NRCELL-1/NRREL-10:gNbIdLength=22
...    NRCELL-1/NRREL-10:lcrId=2
...    NRCELL-1/NRREL-10:removeNotAllowed=false
...    NRCELL-1/NRREL-10:nrDcAllowed=false
...    NRCELL-1/NRREL-10:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-10:sCellOperationalMode=dlOnly
...    NRCELL-2:actPrachMultiplexing=true
...    NRCELL-1:actCDrx=true
...    NRCELL-1:drxProfile1:drxInactivityTimer=10ms
...    NRCELL-1:drxProfile1:drxLongCycle=40ms
...    NRCELL-1:drxProfile1:drxOnDurationTimer=10ms
...    NRCELL-1:drxProfile1:drxRetransTimerDl=0slot
...    NRCELL-1:drxProfile1:drxRetransTimerUl=0slot
...    NRCELL-1:a1MeasSCellAddEnabled=rsrp
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=31
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=111
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms

...    NRCELL-1:a1MeashoEnabledSA=rsrp
...    NRCELL-1:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRCELL-1:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=60
...    NRCELL-1:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL-1:a2MeasSCellRelEnabled=rsrp
...    NRCELL-1:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=2
...    NRCELL-1:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=34
...    NRCELL-1:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-1:a2MeashoEnabledSA=rsrp
...    NRCELL-1:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0
...    NRCELL-1:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=34
...    NRCELL-1:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL-1:actPrachMultiplexing=true
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=${value1}
...    NRCELL-1:msg1FrequencyStart=30

@{PM_Counters_Check}
...    NRDU-1:${RRC_REESTAB_ACC_OTHER_FAIL_DU}=2
...    NRDU-1:${RRC_REESTAB_OTHER_FAILURE_DU}=2
...    NRCELL-1:${RRC_REESTAB_OTHER_FAILURE}=2
...    NRCELL-1:${REESTAB_ACC_OTHER_FAIL}=2
...    NRCELL-1:${REESTAB_RRCRECONFIG_SUCC}=2
...    NRCELL-1:${EPmCounterId_5G_F1_UE_CTXT_MOD_REQ_SENT}>0
...    NRCELL-1:${EPmCounterId_5G_F1_UE_CTXT_MOD_RESP_RECEIVED}>6
...    NRCELL-1:${EPmCounterId_5G_NF1CC_DL_RRC_MSG_TRANSFER}=16
...    NRCELL-1:${EPmCounterId_5G_NF1CC_UL_RRC_MSG_TRANSFER}=20
...    NRCELL-1:${EPmCounterId_5G_NRRCC_RRC_RECONF_SENT}=8
...    NRCELL-1:${EPmCounterId_5G_NRRCC_RRC_RECONF_CMP_RECD}=8
...    NRCELL-1:${EPmCounterId_5G_SGNB_SA_DU_ADMISSION_REQ}=3
...    NRCELL-1:${EPmCounterId_5G_SGNB_SA_DU_ADMISSION_SUCC}=3
...    NRCELL-1:${EPmCounterId_5G_SGNB_SA_DU_NGBR_DRB_REQ}=3
...    NRCELL-1:${EPmCounterId_5G_SGNB_SA_DU_NGBR_DRB_SUCC}=3
...    NRCELL-1:${EPmCounterId_5G_SGNB_SA_DU_NGBR_DRB_REL}=3
...    NRCELL-1:${EPmCounterId_5G_GNB_SA_DU_ADM_SUCC_BWP1}=3
...    NRCELL-1:${EPmCounterId_5G_GNB_SA_DU_ADM_SUCC_BWP2}=0

${value}    symbol_0_1|searchSpaceType=Type3 
${value1}    symbol_0_1|searchSpaceType=UE-Specific    

${RRC_REESTAB_OTHER_FAILURE_DU}    M55127C00503    #Number of RRC Re-establishment Request caused by other failure
${RRC_REESTAB_ACC_OTHER_FAIL_DU}    M55127C00512    #Number of accepted RRC Re-establishment when reestablishment cause is other failure
${RRC_REESTAB_OTHER_FAILURE}       M55124C00505    #Number of RRC Re-establishment Request caused by HO failure
${REESTAB_RRCRECONFIG_SUCC}    M55124C00516    #Number of RRC reconfiguration successful in RRC reestablishment procedure
${EPmCounterId_5G_F1_UE_CTXT_MOD_REQ_SENT}    M55113C00001    #Number of outgoing UE CONTEXT MODIFICATION REQUEST sent to gNB-DU
${EPmCounterId_5G_F1_UE_CTXT_MOD_RESP_RECEIVED}    M55113C00002    #Number of incoming UE CONTEXT MODIFICATION RESPONSE received from gNB-DU
${EPmCounterId_5G_NF1CC_DL_RRC_MSG_TRANSFER}    M55113C00501    #Number of DL RRC Message Transfer sent.
${EPmCounterId_5G_NF1CC_UL_RRC_MSG_TRANSFER}    M55113C00502    #Number of UL RRC Message Transfer received.
${EPmCounterId_5G_NRRCC_RRC_RECONF_SENT}    M55124C03001    #Number of RRC RECONFIGURATION sent
${EPmCounterId_5G_NRRCC_RRC_RECONF_CMP_RECD}    M55124C03002    #Number of RRC RECONFIGURATION COMPLETE received
${EPmCounterId_5G_SGNB_SA_DU_ADMISSION_REQ}    M55139C00001    #Number of SA DU ADMISSION REQ
${EPmCounterId_5G_SGNB_SA_DU_ADMISSION_SUCC}    M55139C00002    #Number of SA DU ADMISSION SUCC
${EPmCounterId_5G_SGNB_SA_DU_NGBR_DRB_REQ}    M55139C00003     #Number of SA DU NGBR DRB REQ
${EPmCounterId_5G_SGNB_SA_DU_NGBR_DRB_SUCC}    M55139C00004    #Number of SA DU NGBR DRB SUCC
${EPmCounterId_5G_SGNB_SA_DU_NGBR_DRB_REL}    M55139C00012    #Number of SA DU NGBR DRB REL
${EPmCounterId_5G_GNB_SA_DU_ADM_SUCC_BWP1}     M55139C02501    #The number of admission successes due to BWP1 selected for SA 
${EPmCounterId_5G_GNB_SA_DU_ADM_SUCC_BWP2}     M55139C02502    #The number of admission successes due to BWP2 selected for SA 
# The counter is updated when receiving the RRCReestablishmentComplete message when the reestablishmentCause is otherFailure
${REESTAB_ACC_OTHER_FAIL}    M55124C00512

${V_1}    SEPARATOR=
...    E9A09380575F5A13160003C320016093170019C3D09009B20C39F30C7942C0E098040623807DC6C28
...    C0D608C21A08107482406D6C98AB1A1CF88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801F
...    E000E000B800088000E0541B107582308682041E2090195B262AC4873EC09F11C78C48E3C873EA39F
...    30C7942C0E070F09FD8000007F600000044000702A8D89BAC1184341020E90480C2D931544439F11C
...    788E3D033EC09F18E7CC31E50B0381C3C17003FF001C00FFC00110001C0A836236B04610D04083C41
...    2032B64C55890E7C471EC09F1891C790E7D473E618F28581C0E1E13FFE00000FFF80000088000E008
...    3C3C4D000E208000010B0102A0F0A000388C0000042C0AC3C46000E208000030B02B0F0A000388200
...    00042C0AC3C4D000E230000010B02B17118003882001C4100000A160561E14000713400003058158B
...    89A001C41000E140000040B02B1713400388C001C46000004160562E14000710400388C0000082C0A
...    C5C28000E20800710400001058158B89A001C41000E230000020B02B170A000388C001C4600000416
...    0562E2680071180038500000102C0AC3C46000E230000030B02A070A0000038581007011A014404D8
...    0821A8314210A244D8E7C3851226C73E1C28913639F0E14489B1CF870A244D8E7C38912244D8E7C38
...    50206C73E044810206C73E044810206C73E044810206C73E044810206C73E044810206C73E0448102
...    06C73E044810206C73E0428103639F02040D8E7C00064406318C6318C6318C6318C07A09801E00140
...    E0A00E0601280380030120020301F0480100000000800001004000000020000040100000400800003
...    0040000200200001401000802008020000180100000E0080040000001000010008000090040000180
...    2000028010000160080040902401000018063276B2A6B052B032B066B056B296B266B016B036B012B
...    022B07681A0800004B29282000032CA4A0800014B29202000072CA480800024B292020000B2CA4808
...    00034B292020000F2CA480800044B29202000132CA480800054B29202000172CA4A0800064B292020
...    00062CA480669555527AAA55174AA2A82C55058AA0D154A62A93455018AA051549AAA83C509017809
...    5028140A05028140A05028140A05028140A0502814001C20201803008010021010020080403006100
...    80100202018030080600C10100C018040300610080100202018030080100220100C01804030060100
...    C01820200401008010040010020086A87C0004080C10181C282C30344044484C5060646C70747C849
...    4989CA0A4A8B4BD05060B40
 
${ReconfigurationFailure}    otherFailure
${ue_id}    81
${gw_id}    2

*** Test Cases ***
5GC000732-ET-F006_RRC_reestablish_succ_with_7922_meas_to_ori_Pcell_DRX_enabled_with_MG_A1_configured
    [Documentation]    This case will combine F006(RRC_reestablish_succ_with_7922_meas_to_ori_Pcell_DRX_enabled_with_MG_A1_configured)
    ...    And F032(RRC_reestablish_succ_with_7552_from_small_bwp_to_small_bwp
    ...    preconditions:
    ...        1. BWP(7552) is opened 
    ...        2. configure CA T+T(cell 1+cell 2) for 7922 covBasedA1 with DRX,measconfig 
    ...    Case steps:
    ...        1.Setup CA(TDD+TDD)(cell 1+ cell 2) successfully
    ...        2.Trigger normal call with cell 1
    ...        3.Trgger RRC reestablish from cell 1 to cell 1, RRC reestablish successfully
    ...        4.check drx setup successfully and meas config not missing in RRCReestablish procedure
    ...        5.Check counters:

    [Tags]    QC_165745    F006
    Ue Register And Pdu Session Setup At FDD Cell-1
    Trigger MEASUREMENT    A1    518910
    Trigger MEASUREMENT    A2    518910    30    30    
    Start To Capture Wireshark Log    F00600
    Trigger RRC Reestablish    1    ${ReconfigurationFailure}    	
    Check Wireshark Log    ${CURDIR}${/}a2a_F006_00${/}a2a.ini    name=F00600    wait_string=UEContextModificationResponse::12
    Start To Capture Wireshark Log    F00601
    Trigger RRC Reestablish    1    ${ReconfigurationFailure}
    Verify Throughput And Check Counters    sleep_time=40s    Tput_dl=150
    Check Wireshark Log    ${CURDIR}${/}a2a_F006_01${/}a2a.ini    name=F00601    wait_string=UEContextReleaseComplete::4
    [Teardown]    Common Test Teardown And Stop Capture Logs

*** Keywords ***
Modify Cfg
    ${AutoVariable_1}    catenate
    ...    ue_param id=${ue_id} 
    ...    ue_nr_capabilities=${V_1}
    Update Cfg    ${AutoVariable_1}
	
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_2T4F
	
Ue_Deregister
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE CONTEXT RELEASE COMPLETE
	
Trigger RRC Reestablish
    [Arguments]    ${cell_id}    ${cause}
    ${ret1}=    Execute Egate Command    ue_rrc_reestablish id=${ue_id} gnb=2 cell=${cell_id} cause=${cause}
    ...    NR RRC Reestablishment sucessfully completed    timeout=20s
    sleep    42    reason=wait finished      	
	
Ue Register And Pdu Session Setup At FDD Cell-1
    Clear Counter Files
    Execute Egate Command    qosflow_modify qos_flow=1 default=on
    Execute Egate Command    ue_location_change id=${ue_id} enb=2 cell=1
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=UE now in NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=${gw_id} nwslice=1    pass_regexp=QoS Routing Table
    sleep    42    reason=wait rrc finished
    Trigger Throughput	
	
Trigger Throughput
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=1    pass_regexp=Started Downlink
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=2    pass_regexp=Started Downlink
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=3    pass_regexp=Started Downlink
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=50 trf_id=4    pass_regexp=Started Downlink	
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=ul mbps=10 trf_id=1    pass_regexp=Started Uplink    
	
Verify Throughput And Check Counters
    [Documentation]    verify Tput in scell is not 0
    [Arguments]    ${Tput_dl}=60    ${Tput_ul}=9    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pdsch    Throughput
    Should Not Match Regexp    ${scell_tput}    CellIndex-.*Mbps.*Mbps.*Mbps.* 0 Mbps
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}
    Ue_Deregister
    Check Counters    ${PM_Counters_Check}
	
Trigger MEASUREMENT
    [Arguments]    ${event_type}=A1    ${carrierfreq}=424090    ${srsrp_nr}=112    ${srsrq_nr}=80    ${ue_id}=81
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr    id=${ue_id}    meas_id=${meas_id}    event=${event_type}
    ...    srsrp_nr=${srsrp_nr}    srsrq_nr=${srsrq_nr}
    Execute Egate Command    ${cmd}    pass_regexp=rrcReconfigurationComplete
