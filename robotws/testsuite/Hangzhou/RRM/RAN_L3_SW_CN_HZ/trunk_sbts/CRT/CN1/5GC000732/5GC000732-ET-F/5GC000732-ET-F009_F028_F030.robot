*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags      QCD_MN_RAN    QCP_RAN_ET    RAN_5G    RAN_5G_TDD    CXT    SBTS00
...    owner-jolin.fan    owner-cathy.mao    team-SG2    release-SBTS22R2    5GC000732
...    CLOUD_5G_I_BLLL_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD
Resource    ../../../../../resources/DevHZ5_resource.robot


*** Variables ***
${TL_TYPE_PATH}    fddtdd_sansa_cmwv/L1B/6cells_2T4F


@{PARAMS_IN_SCF}
...    @{DRB}
...    NRPMRNL-1:miNrRelReportCu=15min
...    NRCELL:actK1Opt=intra-gNB
...    NRBTS-1:rrcReestabTypeSA=sameGNB
...    NRBTS-1:actMultipleDedicatedBWPs=true
...    NRBTS-1:timerXnDataFwdGuard=250
...    NRBTS-1:tWaitingRlRecover=10000ms

...    NRBTS-1:actInterFreqHoSA=true
...    NRBTS-1:actIntraFreqHoSA=true
...    NRBTS-1:actMeasBasedSCellAdditionSa=A1-based

...    NRBTS:timerXnDataFwdGuard=250
...    NRBTS:tWaitingRlRecover=10000ms
...    NRBTS:actInterFreqHoSA=true
...    NRBTS:actIntraFreqHoSA=true
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    MRBTS-1/NRBTS-1/NRCELL-2:actCDrx=true
...    MRBTS-1/NRBTS-1/NRCELL-2:actVoNR=true
...    MRBTS-1/NRBTS-1/NRCELL-2:actCDrxVoNR=true
...    MRBTS-1/NRBTS-1/NRCELL-2:actEnhancedVoNR=true
...    MRBTS-1/NRBTS-1/NRCELL-2:n310VoNR=n10
...    MRBTS-1/NRBTS-1/NRCELL-2:t310VoNR=100ms
...    MRBTS-1/NRBTS-1/NRCELL-2:drxProfile1:drxInactivityTimer=40ms
...    MRBTS-1/NRBTS-1/NRCELL-2:drxProfile1:drxLongCycle=40ms
...    MRBTS-1/NRBTS-1/NRCELL-2:drxProfile1:drxOnDurationTimer=10ms
...    MRBTS-1/NRBTS-1/NRCELL-2:drxProfile1:drxRetransTimerDl=16slot
...    MRBTS-1/NRBTS-1/NRCELL-2:drxProfile1:drxRetransTimerUl=16slot
...    MRBTS-1/NRBTS-1/NRCELL-2:drxProfile2:drxInactivityTimer=4ms
...    MRBTS-1/NRBTS-1/NRCELL-2:drxProfile2:drxLongCycle=40ms
...    MRBTS-1/NRBTS-1/NRCELL-2:drxProfile2:drxOnDurationTimer=4ms
...    MRBTS-1/NRBTS-1/NRCELL-2:drxProfile2:drxRetransTimerDl=0slot
...    MRBTS-1/NRBTS-1/NRCELL-2:drxProfile2:drxRetransTimerUl=0slot
...    MRBTS-1/NRBTS-1/NRCELL-2:maxGBRTrafficLimit=80
...    MRBTS-1/NRBTS-1/NRCELL-2:actGBRAdmissionControl=EnhancedVoNR
...    NRCELL-2:actVoipPacketAggr=true
...    NRCELL-2:actEnhancedVoNR=true
...    NRCELL-2:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRCELL-2:a1MeashoSsbRsrpSA:a1HysteresisHoSsbRsrpVoNr=0
...    NRCELL-2:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=60
...    NRCELL-2:a1MeashoSsbRsrpSA:a1ThresholdHoSsbRsrpVoNr=55
...    NRCELL-2:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL-2:a1MeashoSsbRsrpSA:a1TimeToTriggerHoSsbRsrpVoNr=ms40
...    NRCELL-2:a1MeasSCellAddEnabled=rsrp
...    NRCELL-2:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0
...    NRCELL-2:a2MeashoSsbRsrpSA:a2HysteresisHoSsbRsrpVoNr=0
...    NRCELL-2:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=34
...    NRCELL-2:a2MeashoSsbRsrpSA:a2ThresholdHoSsbRsrpVoNr=55
...    NRCELL-2:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL-2:a2MeashoSsbRsrpSA:a2TimeToTriggerHoSsbRsrpVoNr=ms40
...    NRCELL-2:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL-2:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=31
...    NRCELL-2:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=111
...    NRCELL-2:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=80ms
...    NRCELL-2:a3MeasEnabled=rsrp
...    NRCELL-2:a1MeashoEnabledSA=rsrp
...    NRCELL-2:actPrachMultiplexing=true
...    NRCELL-2:a2MeashoEnabledSA=rsrp
...    MRBTS-1/NRBTS-1/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=14
...    MRBTS-1/NRBTS-1/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=14
...    MRBTS-1/NRBTS-1/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=9|searchSpaceId=14
...    MRBTS-1/NRBTS-1/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=14
...    MRBTS-1/NRBTS-1/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=14
...    MRBTS-1/NRBTS-1/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=14
...    MRBTS-1/NRBTS-1/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=14
...    MRBTS-1/NRBTS-1/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=14
...    MRBTS-1/NRBTS-1/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|searchSpaceId=14
...    MRBTS-1/NRBTS-1/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=14|searchSpaceId=14
...    MRBTS-1/NRBTS-1/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=14
...    MRBTS-1/NRBTS-1/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=4|searchSpaceId=14
...    MRBTS-1/NRBTS-1/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=15
...    MRBTS-1/NRBTS-1/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=15
...    MRBTS-1/NRBTS-1/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=15
...    MRBTS-1/NRBTS-1/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=15
...    MRBTS-1/NRBTS-1/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=15
...    MRBTS-1/NRBTS-1/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=15
...    MRBTS-1/NRBTS-1/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=15
...    MRBTS-1/NRBTS-1/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=15
...    MRBTS-1/NRBTS-1/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=15
...    MRBTS-1/NRBTS-1/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=15|searchSpaceId=15
...    MRBTS-1/NRBTS-1/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=15
...    MRBTS-1/NRBTS-1/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=15
...    MRBTS-1/NRBTS-1/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=16
...    MRBTS-1/NRBTS-1/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=16
...    MRBTS-1/NRBTS-1/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=9|searchSpaceId=16
...    MRBTS-1/NRBTS-1/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=16
...    MRBTS-1/NRBTS-1/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=16
...    MRBTS-1/NRBTS-1/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=16
...    MRBTS-1/NRBTS-1/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=16
...    MRBTS-1/NRBTS-1/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=16
...    MRBTS-1/NRBTS-1/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|searchSpaceId=16
...    MRBTS-1/NRBTS-1/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=16|searchSpaceId=16
...    MRBTS-1/NRBTS-1/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=16
...    MRBTS-1/NRBTS-1/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=4|searchSpaceId=16
...    MRBTS-1/NRBTS-1/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cceToRegMapping=nonInterleaved
...    MRBTS-1/NRBTS-1/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:coresetId=5
...    MRBTS-1/NRBTS-1/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cRbStart=0
...    MRBTS-1/NRBTS-1/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:duration=1
...    MRBTS-1/NRBTS-1/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:interleaverSize=none
...    MRBTS-1/NRBTS-1/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:regBundleSize=n6
...    MRBTS-1/NRBTS-1/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=120
...    MRBTS-1/NRBTS-1/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=0|searchSpaceId=17
...    MRBTS-1/NRBTS-1/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-0-And-1-0|searchSpaceId=17
...    MRBTS-1/NRBTS-1/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|searchSpaceId=17
...    MRBTS-1/NRBTS-1/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=17
...    MRBTS-1/NRBTS-1/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|searchSpaceId=17
...    MRBTS-1/NRBTS-1/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceId=17
...    MRBTS-1/NRBTS-1/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|searchSpaceId=17
...    MRBTS-1/NRBTS-1/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|searchSpaceId=17
...    MRBTS-1/NRBTS-1/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceId=17
...    MRBTS-1/NRBTS-1/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|searchSpaceId=17
...    MRBTS-1/NRBTS-1/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=17|searchSpaceId=17
...    MRBTS-1/NRBTS-1/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|searchSpaceId=17
...    MRBTS-1/NRBTS-1/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|searchSpaceId=17
...    MRBTS-1/NRBTS-1/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=5|searchSpaceId=18
...    MRBTS-1/NRBTS-1/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|searchSpaceId=18
...    MRBTS-1/NRBTS-1/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|searchSpaceId=18
...    MRBTS-1/NRBTS-1/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=18
...    MRBTS-1/NRBTS-1/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|searchSpaceId=18
...    MRBTS-1/NRBTS-1/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceId=18
...    MRBTS-1/NRBTS-1/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|searchSpaceId=18
...    MRBTS-1/NRBTS-1/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|searchSpaceId=18
...    MRBTS-1/NRBTS-1/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceId=18
...    MRBTS-1/NRBTS-1/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|searchSpaceId=18
...    MRBTS-1/NRBTS-1/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=18|searchSpaceId=18
...    MRBTS-1/NRBTS-1/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|searchSpaceId=18
...    MRBTS-1/NRBTS-1/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|searchSpaceId=18
...    MRBTS-1/NRBTS-1/BWP_PROFILE-6/PDSCH-1:pdschRat0RbgConfig=config1
...    MRBTS-1/NRBTS-1/BWP_PROFILE-6:bwpType=dedicated
...    MRBTS-1/NRBTS-1/BWP_PROFILE-6:locationAndBandwidthDl:cRbSizeDl=n106
...    MRBTS-1/NRBTS-1/BWP_PROFILE-6:locationAndBandwidthDl:cRbStartDl=crb0
...    MRBTS-1/NRBTS-1/BWP_PROFILE-6:locationAndBandwidthUl:cRbSizeUl=sameAsDl
...    MRBTS-1/NRBTS-1/BWP_PROFILE-6:locationAndBandwidthUl:cRbStartUl=sameAsDl
...    MRBTS-1/NRBTS-1/BWP_PROFILE-6/PDCCH-1:alSelection=static
...    MRBTS-1/NRBTS-1/BWP_PROFILE-6/PDCCH-1:dciDedicatedAggregationLevel=AL4
...    MRBTS-1/NRBTS-1/BWP_PROFILE-6/PDCCH-1:dciPagingAggregationLevel=AL4
...    MRBTS-1/NRBTS-1/BWP_PROFILE-6/PDCCH-1:dciRaCompletionAggregationLevel=AL4
...    MRBTS-1/NRBTS-1/BWP_PROFILE-6/PDCCH-1:dciRaMsg2AggregationLevel=AL4
...    MRBTS-1/NRBTS-1/BWP_PROFILE-6/PDCCH-1:dciSiAggregationLevel=AL4
...    MRBTS-1/NRBTS-1/BWP_PROFILE-6/PDCCH-1:downgradeAL16toAL8=notAllowed
...    MRBTS-1/NRBTS-1/BWP_PROFILE-3:locationAndBandwidthUl:cRbSizeUl=sameAsDl
...    MRBTS-1/NRBTS-1/BWP_PROFILE-3:locationAndBandwidthUl:cRbStartUl=sameAsDl
...    MRBTS-1/NRBTS-1/BWP_PROFILE-4:locationAndBandwidthUl:cRbSizeUl=sameAsDl
...    MRBTS-1/NRBTS-1/BWP_PROFILE-4:locationAndBandwidthUl:cRbStartUl=sameAsDl
...    NRPMRNL:miNrRelReportCu=15min
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-1:gNbId=1
...    NRCELL-2/NRREL-1:gNbIdLength=22
...    NRCELL-2/NRREL-1:lcrId=1
...    NRCELL-2/NRREL-1:removeNotAllowed=false
...    NRCELL-2/NRREL-1:nrDcAllowed=false
...    NRCELL-2/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-2/NRHOIF-1:a1BasedPCellSwitchEnabled=false
...    NRCELL-2/NRHOIF-1:a2BasedPCellSwitchEnabled=false
...    NRCELL-2/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-2/NRHOIF-1:freqBandIndicatorNR=71
...    NRCELL-2/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-2/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-2/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf5
...    NRCELL-2/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-2/NRHOIF-1:scs=15 KHz
...    NRCELL-2/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-2/NRHOIF-1:ssbFrequency=126750
...    NRCELL-2/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrpVoNr=2
...    NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrpVoNr=10
...    NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrpVoNr=ms0
...    NRCELL-12:a2MeasSCellRelEnabled=rsrp
...    NRCELL-12:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=2
...    NRCELL-12:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=35
...    NRCELL-12:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=64ms
...    NRCELL-2/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-10:gNbId=1
...    NRCELL-2/NRREL-10:gNbIdLength=22
...    NRCELL-2/NRREL-10:lcrId=12
...    NRCELL-2/NRREL-10:removeNotAllowed=false
...    NRCELL-2/NRREL-10:nrDcAllowed=false
...    NRCELL-2/NRREL-10:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-10:gnbPlmn:mncLength=3
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:actInterNumerologyCa=true
...    NRDU-1:carrierAggregationSupportList=ca_Fr1Tdd_Fdd_Sa
...    NRBTS/NRDRB_RLC_AM-1:ulTReassemblyIBCA=40
...    NRBTS/NRDRB_RLC_AM-2:ulTReassemblyIBCA=40

@{DRB}
...    NRBTS-1/NRDRB-15:dlFlowControlAlgo=none
...    NRBTS-1/NRDRB-15:dscp=46
...    NRBTS-1/NRDRB-15:l2OHFactorDl=16
...    NRBTS-1/NRDRB-15:l2OHFactorUl=35
...    NRBTS-1:tWaitingRlRecover=4000ms
...    NRBTS-1/NRDRB-15:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-3
...    NRBTS-1/NRDRB-15:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-2
...    NRBTS-1/NRDRB-15:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRBTS-1/NRDRB-15:numSduDiscard=1
...    NRBTS-1/NRDRB-15:queuingDelayDiscarding=Disabled
...    NRBTS-1/NRDRB-15:queuingDelaySduDiscardThreshold=750
...    NRBTS-1/NRDRB-15:resType=GBR
...    NRBTS-1/NRDRB-15:rlcMode=RLC_UM
...    NRBTS-1/NRDRB-15:sduDiscardIntervalTmr=500
...    NRBTS-1/NRDRB-15:schedulWeight=1
...    NRBTS-1/NRDRB-15:actDddsReduction=false
...    NRBTS-1/NRDRB-15:maxRlcQueueingDelayGbr=20
...    NRBTS-1/NRDRB-15:actLostPduFastRetx=false
...    NRBTS-1/NRDRB-15:maxDddsPeriodCpuOvld=40
...    NRBTS-1/NRDRB-15:durationThresDiscardDl=40
...    NRBTS-1/NRDRB-15:durationThresDiscardUl=20
...    NRBTS-1/NRDRB-15:volThresDiscardDl=8000
...    NRBTS-1/NRDRB-15:volThresDiscardUl=800
...    NRBTS-1/NRDRB-15:maxTransferDelayGbr=20
...    NRBTS-1/NRDRB-15:discardTimer=100ms
...    NRBTS-1/NRDRB-15:maxDataRateGbrUl=1000
...    NRBTS-1/NRDRB-15:maxDataRateGbrDl=1000
...    NRBTS-1/NRDRB-16:dlFlowControlAlgo=none
...    NRBTS-1/NRDRB-16:dscp=46
...    NRBTS-1/NRDRB-16:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-2
...    NRBTS-1/NRDRB-16:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-3
...    NRBTS-1/NRDRB-16:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRBTS-1/NRDRB-16:numSduDiscard=1
...    NRBTS-1/NRDRB-16:queuingDelayDiscarding=Controlled Delay (CoDel)
...    NRBTS-1/NRDRB-16:queuingDelaySduDiscardThreshold=200
...    NRBTS-1/NRDRB-16:resType=nonGBR
...    NRBTS-1/NRDRB-16:rlcMode=RLC_UM
...    NRBTS-1/NRDRB-16:sduDiscardIntervalTmr=100
...    NRBTS-1/NRDRB-16:schedulWeight=24
...    NRBTS-1/NRDRB-16:discardTimer=150ms
...    NRBTS-1/NRDRB_PDCP-3:tReorderingDl=ms300
...    NRBTS-1/NRDRB_PDCP-3:tReorderingUl=ms300
...    NRBTS-1/NRDRB_PDCP-3:pdcpBufDiscardEnabled=false
...    NRBTS-1/NRDRB_PDCP-3:maxCidAllowed=4
...    NRBTS-1/NRDRB_RLC_UM-1:dlTReassemblyUm=ms40
...    NRBTS-1/NRDRB_RLC_UM-1:ulTReassemblyUm=ms40
...    NRBTS-1/NRDRB_RLC_UM-1:rlcUMDrbSNLength=rlcUm12bitSN
...    NRBTS-1/NRDRB_MAC-2:lcgid=2
...    NRBTS-1/NRDRB_MAC-2:schedulPrio=5
...    NRBTS-1/NRDRB_MAC-4:lcgid=2
...    NRBTS-1/NRDRB_MAC-4:schedulPrio=4
...    NRBTS-1/NRDRB_MAC-3:lcgid=4
...    NRBTS-1/NRDRB_MAC-3:schedulPrio=5
...    NRBTS-1/NRDRB_MAC-3:prioritisedBitRate=16kBps
...    NRBTS-1/NRDRB_PDCP-2:pdcpBufDiscardEnabled=false
...    NRBTS-1/NRDRB_PDCP-2:maxCidAllowed=4
...    NRBTS-1/NRDRB_PDCP-1:maxCidAllowed=4
...    NRBTS-1/NRDRB-10:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-4
...    NRBTS-1/NRDRB-10:resType=nonGBR
...    NRBTS-1/NRDRB_5QI-1:fiveqiValueList=5
...    NRBTS-1/NRDRB_5QI-1:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-10
...    NRBTS-1/NRDRB_5QI-7:fiveqiValueList=128
...    NRBTS-1/NRDRB_5QI-7:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-16
...    NRBTS-1/NRDRB_5QI-6:fiveqiValueList=1
...    NRBTS-1/NRDRB_5QI-6:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-15


@{Delta_Scf_F009}
...    MRBTS-1/NRBTS-1/NRCELL-2:cellBwpList:bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-3|cellBwpId=0
...    MRBTS-1/NRBTS-1/NRCELL-2:cellBwpList:bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-4|cellBwpId=1
...    MRBTS-1/NRBTS-1/NRCELL-2:cellBwpList:bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-6|cellBwpId=2
...    MRBTS-1/NRBTS-1:actLocationReportingSA=true
...    MRBTS-1/NRBTS-1/NRCELL-2:actCDrx=true
...    MRBTS-1/NRBTS-1/NRCELL-2:actVoNR=true
...    MRBTS-1/NRBTS-1/NRCELL-2:actCDrxVoNR=true
...    MRBTS-1/NRBTS-1/NRCELL-2:actEnhancedVoNR=true
...    MRBTS-1/NRBTS-1/NRCELL-2:n310VoNR=n10
...    MRBTS-1/NRBTS-1/NRCELL-2:t310VoNR=100ms
...    MRBTS-1/NRBTS-1/NRCELL-2:drxProfile1:drxInactivityTimer=40ms
...    MRBTS-1/NRBTS-1/NRCELL-2:drxProfile1:drxLongCycle=40ms
...    MRBTS-1/NRBTS-1/NRCELL-2:drxProfile1:drxOnDurationTimer=10ms
...    MRBTS-1/NRBTS-1/NRCELL-2:drxProfile1:drxRetransTimerDl=16slot
...    MRBTS-1/NRBTS-1/NRCELL-2:drxProfile1:drxRetransTimerUl=16slot
...    MRBTS-1/NRBTS-1/NRCELL-2:drxProfile2:drxInactivityTimer=4ms
...    MRBTS-1/NRBTS-1/NRCELL-2:drxProfile2:drxLongCycle=40ms
...    MRBTS-1/NRBTS-1/NRCELL-2:drxProfile2:drxOnDurationTimer=4ms
...    MRBTS-1/NRBTS-1/NRCELL-2:drxProfile2:drxRetransTimerDl=0slot
...    MRBTS-1/NRBTS-1/NRCELL-2:drxProfile2:drxRetransTimerUl=0slot
...    MRBTS-1/NRBTS-1/NRCELL-2:maxGBRTrafficLimit=80
...    MRBTS-1/NRBTS-1/NRCELL-2:actGBRAdmissionControl=EnhancedVoNR



@{PM_COUNTER_CHECK}
...    ${REESTAB_ACC_OTHER_FAIL_DU}=2
...    ${RRC_REESTAB_OTHER_FAILURE_DU}=2
...    NRCELL-2:${RRC_REESTAB_OTHER_FAILURE}=2
...    NRCELL-2:${REESTAB_ACC_OTHER_FAIL}=2
...    NRCELL-2:${REESTAB_RRCRECONFIG_SUCC}=2
...    NRCELL-2:${REESTAB_ADMISSION_CTRL}=0
...    ${NF1CD_UECTXT_REL_CMDRECD}=1
...    NRCELL-2:${REESTAB_ACC_VONR}=2
...    NRCELL-2:${RRC_REESTAB_ATT_VONR}=2
...    NRCELL-2:${SGNB_SA_DU_NGBR_DRB_SUCC}=6
...    NRCELL-2:${SGNB_SA_DU_NGBR_DRB_REL}=6
...    NRCELL-2:${SA_DU_GBR_DRB_REQ}=3
...    NRCELL-2:${SA_DU_GBR_DRB_SUCC}=3
...    NRCELL-2:${NNGCC_LOC_REPORT_SENT}=1




&{CELLS_CARRIER_FREQ}
...     1=518910
...     2=633216
...     11=424090
...     12=126750


${RRC_REESTAB_OTHER_FAILURE_DU}    M55127C00503
${REESTAB_ACC_OTHER_FAIL_DU}    M55127C00512
${RRC_REESTAB_OTHER_FAILURE}    M55124C00505
${REESTAB_ACC_OTHER_FAIL}    M55124C00512
${REESTAB_ADMISSION_CTRL}    M55124C00519
${REESTAB_RRCRECONFIG_SUCC}    M55124C00516
${SGNB_SA_DU_NGBR_DRB_SUCC}    M55139C00004
${SGNB_SA_DU_NGBR_DRB_REL}    M55139C00012
${REESTAB_ACC_VONR}    M55124C00518
${RRC_REESTAB_ATT_VONR}    M55124C00520
${SA_DU_GBR_DRB_REQ}    M55139C00501
${SA_DU_GBR_DRB_SUCC}    M55139C00502



${NF1CD_UECTXT_REL_CMDRECD}    M55117C01009
${NNGCC_LOC_REPORT_SENT}    M55125C06502


*** Test Cases ***
5GC000732-ET-F009_RRC_reestablish_succ_with_6112_2329_meas_to_ori_Pcell_DRX_enabled_with_A1_configured
    [Documentation]    This user scenario describes the behaviour, when a UE in RRC_CONNECTED re-establishes RRC Connection to the selected cell
    ...    (serving cell or the other cell) in serving gNB-DU with valid UE context interaction with VoNR or emergency call.
    ...    This case combines with F028_RRC_reestablish_succ_with_770_to_ori_no_area_of_interest_changed and
    ...    with F030_RRC_reestablish_succ_with_7552_from_large_bwp_to_large_bwp
    ...    preconditions:
    ...    1. set NRCELL-2 actVoNR
    ...    Case steps:
    ...    1.UE register to cell-2 successfully
    ...    2.ViNR Call set up successfully
    ...    3.Add cell-12 as Scell for cell-2 TF 2CC CA
    ...    4.Trgger RRC reestablish to cell-2
    ...    5.RRC reestablish should succeed
    ...    6.check cause otherFailure in rrcReestablishmentRequest wiresahrk msg
    ...    and DRB,SRB
    ...    7.check counter
    ...    M55127C00503: RRC_REESTAB_OTHER_FAILURE_DU:If reestablishmentCause IE is otherFailure
    ...    M55124C00505: RRC_REESTAB_OTHER_FAILURE:If reestablishmentCause IE is otherFailure
    ...    M55127C00512: REESTAB_ACC_OTHER_FAIL_DU:If reestablishmentCause IE is otherFailure
    ...    M55124C00512: REESTAB_ACC_OTHER_FAIL:If reestablishmentCause IE is otherFailure
    ...    M55124C00516: REESTAB_RRCRECONFIG_SUCC:Number of RRC reconfiguration successful in RRC reestablishment procedure
    ...    M55124C00519: REESTAB_ADMISSION_CRTL:Number of admission control triggered in CU by RRC reestablishment procedure
    ...    M55139C00004: The number of radio admitted non-GBR DRBs for SA user in DU
    ...    M55117C01009: Number of F1AP: UE Context Release Command messages received in gNB-DU.
    ...    M55139C00012: The number of non-GBR DRB radio admission releases for SA user in DU
    ...    M55139C00501: The number of GBR DRB radio admission requests for SA user in DU.
    ...    M55139C00502: The number of GBR DRB successful radio admissions for SA user in DU.
    ...    M55124C00520: umber of RRC Re-establishment Request attempts for VONR for any cause RRC_REESTAB_ATT_VONR
    ...    M55124C00518: Number of accepted VONR RRC Re-establishment for all reestablishment causes
    ...    M55125C06502: The counter is updated when the NGAP: LOCATION REPORT message is sent to AMF
    [Tags]    F009    F028    F030    QC_165747
    [Timeout]     60 min
    Before_ue_attach_F009
    UE Attach and L3 ViNR Call
    Verify SA DL and UL Traffic
    Change Serving Cell
    Trigger Scell Addition by A1 Event    pcell_id=2    scell_physCellId=61
    Add Measurement Gap By A2    pcell_id=2
    Reestablish from Cell_2 to Cell_2 and Check Traffic
    Reestablish from Cell_2 to Cell_2 and Check Traffic
    Cancel Location Report
    Release Ues    ue_type=all
    Check Wireshark Log    ${CURDIR}/a2a_F009/a2a.ini    wait_string=UEContextReleaseComplete::4
    Check Counters    ${PM_COUNTER_CHECK}


*** Keywords ***
Modify Cfg
    Update Cfg    set_qosflow id=1 5qi=6 default=off
    Update Cfg    set_qosflow id=2 5qi=5 default=on
    Update Cfg    set_qosflow id=3 5qi=1
    Update Cfg    set_qosflow id=4 5qi=2
    Update Cfg    set_qosrule id=1 proto=tcp qos_flow=2
    Update Cfg    set_qosrule id=2 proto=udp qos_flow=3
    Update Cfg    set_qosrule id=3 proto=udp qos_flow=4
    Update Cfg    set_nwslice id=1 snssai=0x01:0xD143A5 default=on ue=all amf=1 qos_flows=1,2,3,4 qos_rules=1,2,3

Before_ue_attach_F009
    Delta Commission Parameters     ${Delta_Scf_F009}
    Execute Egate Command    ue_change_location id=81 enb=2 cell=2
    Clear Counter Files
    Start RRC Log    F009

Change Serving Cell
    [Arguments]    ${ue_id}=81
    Execute Egate Command    ue_send_location_reporting_control ue=${ue_id} event_type=change-of-serving-cell
    ...                      pass_regexp=Received Location Report

Cancel Location Report
    [Arguments]    ${ue_id}=81
    Execute Egate Command    ue_send_location_reporting_control ue=${ue_id} event_type=cancel-location-reporting-for-the-ue



Trigger Scell Addition by A1 Event
    [Arguments]    ${pcell_id}    ${scell_physCellId}    ${ue_id}=81
    Start RRC Log    scell_covA1_addition
    ${pcell_carrier_freq}    Get From Dictionary    ${CELLS_CARRIER_FREQ}    ${pcell_id}
    ${meas_id}    Get Nr Meas Id For Specific Type And Frequency    ${ue_id}    ${pcell_carrier_freq}    A1
    Execute Egate Command
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=112 srsrq_nr=80
    ...    pass_regexp=SCellIndex 1 activated successfully
    Rrc Should Contain    sCellToAddModList    sCellIndex 1    physCellId ${scell_physCellId}
    Rrc Should Not Contain    sCellIndex 2

Add Measurement Gap By A2
    [Arguments]    ${pcell_id}    ${ue_id}=81
    Start RRC Log    scell_covA1_addition
    ${pcell_carrier_freq}    Get From Dictionary    ${CELLS_CARRIER_FREQ}    ${pcell_id}
    ${meas_id}    Get Nr Meas Id For Specific Type And Frequency    ${ue_id}    ${pcell_carrier_freq}    A2
    Execute Egate Command
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 srsrp_nr=30 srsrq_nr=30
    ...    pass_regexp=rrcReconfigurationComplete


UE Attach and L3 ViNR Call
    [Arguments]    ${ue_id}=81    ${pdu_gw_id}=1
    Execute Egate Command    qosflow_modify qos_flow=2 default=on
    Execute Egate Command    ue_register id=${ue_id}     pass_regexp=Received REGISTRATION COMPLETE
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_gw_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup pdu=${pdu_gw_id} ue=${ue_id} nwslice=1 gw=${pdu_gw_id}
    ...                      pass_regexp=Initial Context Setup Successful
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu_gw_id} qosflows_to_add=3 by=amf
    ...                      pass_regexp=Added QosFlow with QFI:2 fiveQI:1
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu_gw_id} qosflows_to_add=4 by=amf
    ...                      pass_regexp=Added QosFlow with QFI:3 fiveQI:2
    Execute Egate Command    qosflow_disp
    Start Traffic    ${ue_id}    ${pdu_gw_id}

Start Traffic
    [Arguments]    ${ue_id}=81    ${pdu_gw_id}=1
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_gw_id} qfi=1 dir=dl mbps=100 trf_id=2
    ...    pass_regexp=UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_gw_id} qfi=1 dir=dl mbps=100 trf_id=3
    ...    pass_regexp=UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_gw_id} qfi=1 dir=dl mbps=100 trf_id=4
    ...    pass_regexp=UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_gw_id} qfi=1 dir=ul mbps=10
    ...    pass_regexp=UE ${ue_id}: UDP UL

Verify SA DL and UL Traffic
    [Arguments]    ${ue_id}=81    ${pdu_gw_id}=1
    Builtin.sleep    15s
    ${ul_throuput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_gw_id}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${ul_throuput}/1000>9
    ${dl_throuput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_gw_id}    qfi=1    direction=dl    rate_type=ave
    Should Be True    ${dl_throuput}/1000>240

Trigger UE RRC Reestablish to Cell
    [Arguments]    ${tgt_cell_id}    ${ue_id}=81
    Execute Egate Command    ue_rrc_reestablish id=${ue_id} gnb=2 cell=${tgt_cell_id} cause=otherFailure
    ...    pass_regexp=UE81: NR RRC Reestablishment sucessfully completed
    Check Specific Ue State    ${ue_id}    ACTIVE
    ${enb_id}    ${cell_id}    Get UE Location    ${ue_id}
    Should Be Equal    ${enb_id}    2
    Should Be Equal    ${cell_id}    ${tgt_cell_id}

Reestablish from Cell_2 to Cell_2 and Check Traffic
    Trigger UE RRC Reestablish to Cell    tgt_cell_id=2
    Verify SA DL and UL Traffic
