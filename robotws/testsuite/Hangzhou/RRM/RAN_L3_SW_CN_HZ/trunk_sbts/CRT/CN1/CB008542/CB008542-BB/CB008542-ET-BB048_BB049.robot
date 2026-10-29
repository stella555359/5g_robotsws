*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags  QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CRT    CLOUD_5G_I_BOO_AP_LOO
...    team-CN1ET    owner-jiadan.wu release-5G22R3    CB008542
Resource  ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
${BTS_STARTUP_RETRY}   4
${DEBUG_LOG_LEVEL}    4
@{PARAMS_IN_SCF}
...    NRBTS/NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRBTS:actFdmScheduling=true
...    NRBTS:actFdmEnhancedScheduling=true
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS:actMeasBasedSCellAdditionNsa=true
...    NRBTS:sCellActivationMethod=blind
...    NRBTS/NRDU-1:actInterNumerologyCa=true
...    NRBTS/NRDU-1:carrierAggregationSupportList=${CA_support_list}
...    NRCELL-1:actCDrx=true
...    NRCELL-1:pucchModeSelect=longPucch
...    NRCELL-1:actK1Opt=intra-gNB
...    NRCELL-1:measGapSelectionSA=favourUeThroughput
...    NRCELL-12:pucchModeSelect=longPucch
...    NRCELL-12:actK1Opt=intra-gNB
...    NRCELL-12:measGapSelectionSA=favourUeThroughput
...    NRBTS-2/NRCELL-1/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-10:gNbId=2
...    NRCELL-1/NRREL-10:gNbIdLength=22
...    NRCELL-1/NRREL-10:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-10:lcrId=12
...    NRCELL-1/NRREL-10:removeNotAllowed=false
...    NRCELL-1/NRREL-10:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-1:a1MeasSCellAddEnabled=rsrp
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=75
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=95
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=0ms
...    NRCELL-12:a2MeasSCellRelEnabled=rsrp
...    NRCELL-12:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0
...    NRCELL-12:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=35
...    NRCELL-12:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL:sCellDeactivationTimerGNB=infinity
...    NRBTS/NRDU-1:actConnectedModeMobilityCA=true
...    @{DSS_cell_config}
...    @{DSS_cell_NRDSSLTE}
...    @{DSS_xp}
...    @{DSS_cell12_bwp}
...    @{DSS_cell12_NRSYSINFO}
...    @{BOO_LOO}
...    @{NRCELL_config}


@{BOO_LOO}
...    NRCELL-1:dlMimoMode=2x2 Closed Loop Spatial Multiplexing
...    NRCELL-2:dlMimoMode=2x2 Closed Loop Spatial Multiplexing
...    NRCELL-2:nrCellType=4DL2UL
...    NRCELL-1:nrCellType=4DL2UL
#...    MRBTS-1/NRBTS-2/NRCELL-1/NRREL-10:sCellOperationalMode=dlOnly
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-7
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-8
#...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-5
#...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-6
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-7
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-8

@{NRCELL_config}
...    NRCELL-1:srPeriodicity=slots80
...    NRCELL-1:periodicCsiAcquisition:csiReportPeriodicity=slots320
...    NRCELL-1:actBeamforming=true
#...    NRCELL-1:nrCellType=4DL2UL
...    NRCELL-1:beamSet:basicBeamSet=beamSet_2
...    NRCELLGRP-3:numberOfTransmittedSsBlocks=2 beams

...    NRCELL-2:srPeriodicity=slots80
...    NRCELL-2:periodicCsiAcquisition:csiReportPeriodicity=slots320
...    NRCELL-2:actBeamforming=true
...    NRCELL-2:beamSet:basicBeamSet=beamSet_2
...    NRCELLGRP-4:numberOfTransmittedSsBlocks=2 beams


@{DSS_cell_config}
...    NRCELL-12/NRCELL_FDD-1:chBwDl=10MHz
...    NRCELL-12/NRCELL_FDD-1:chBwUl=10MHz
...    NRCELL-12/NRCELL_FDD-1:nrarfcnDl=127100
...    NRCELL-12/NRCELL_FDD-1:nrarfcnUl=136300
...    NRCELL-12:gscnOrSsPbchArfcn=1588
...    NRCELL-12:type0CoresetConfigurationIndex=6
...    NRCELL-12:prachConfigurationIndex=12
...    NRCELL-12:actPrachMultiplexing=false
...    NRCELL-12:msg1FrequencyStart=5
...    NRCELL-12:type0SearchSpaceConfigurationIndex=15
...    NRCELL-12:aggregationLevel=4CCEs
...    NRCELL-12:periodicCsiAcquisition:csiReportPeriodicity=slots160
...    NRCELL-12:lteNrDssMode=DSS_Phase_3
...    NRCELL-12:actPdschRmCsirsForTracking=true
...    NRCELL-12:actPdschAtSsbSlots=true
...    NRCELL-12:srPeriodicity=slots80
...    NRCELL-12:cellBwpList:bwpDN=MRBTS-1/NRBTS-2/BWP_PROFILE-5|cellBwpId=0
...    NRCELL-12:cellBwpList:bwpDN=MRBTS-1/NRBTS-2/BWP_PROFILE-6|cellBwpId=1
...    NRCELL-12:dlPtrs:actDlPtrs=false
...    NRBTS:actLteNrDss=true



@{DSS_cell_NRDSSLTE}
...    NRBTS-2/NRCELL-12/NRDSSLTE-1:actLteNrDssFastAlloc=false
...    NRCELL-12/NRDSSLTE-1:actLteNrDssLteCatM=false
...    NRCELL-12/NRDSSLTE-1:actRateMatchedCsiIm=false
...    NRCELL-12/NRDSSLTE-1:dssDlTPollRetr=ms80
...    NRCELL-12/NRDSSLTE-1:dssDlTProhib=ms0
...    NRCELL-12/NRDSSLTE-1:dssMaxNumberOfDlDcis=1
...    NRCELL-12/NRDSSLTE-1:dssUlTPollRetr=ms5
...    NRCELL-12/NRDSSLTE-1:dssUlTProhib=ms0
...    NRCELL-12/NRDSSLTE-1:eNodeBId=1
...    NRCELL-12/NRDSSLTE-1:lcrId=2
...    NRCELL-12/NRDSSLTE-1:ltePhyCellId=13
...    NRCELL-12/NRDSSLTE-1:ssbPosition=pos1
...    NRCELL-12/NRDSSLTE-1:enbPlmn:mnc=489
...    NRCELL-12/NRDSSLTE-1:enbPlmn:mcc=311
...    NRCELL-12/NRDSSLTE-1:enbPlmn:mncLength=3
...    NRCELL-12/NRDSSLTE-1:lteNrDssDlRatio:dlResourceSharingAlgo=DL PRB load based
...    NRCELL-12/NRDSSLTE-1:lteNrDssDlRatio:maxNrDssRatio=100
...    NRCELL-12/NRDSSLTE-1:lteNrDssDlRatio:minNrDssRatio=30
...    NRCELL-12/NRDSSLTE-1:lteNrDssMbsfnRatio:maxValue=50
...    NRCELL-12/NRDSSLTE-1:lteNrDssMbsfnRatio:minValue=50
...    NRCELL-12/NRDSSLTE-1:lteNrDssUlRatio:maxNrDssRatio=70
...    NRCELL-12/NRDSSLTE-1:lteNrDssUlRatio:minNrDssRatio=20

@{DSS_xp}
...    MRBTS/MNL-1/MNLENT-1/XPAP-1
...    MRBTS/MNL-1/MNLENT-1/XPAP-1/XPIF-1:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    MRBTS/MNL-1/MNLENT-1/XPAP-1/XPIF-1:localNeDN=MRBTS-1/NRBTS-2
...    MRBTS/MNL-1/MNLENT-1/XPAP-1/XPIF-1:sctpAssocMaxRetrans=7
...    MRBTS/MNL-1/MNLENT-1/XPAP-1/XPIF-1:sctpDscp=46
...    MRBTS/MNL-1/MNLENT-1/XPAP-1/XPIF-1:sctpHeartbeatInterval=20
...    MRBTS/MNL-1/MNLENT-1/XPAP-1/XPIF-1:sctpMaxPayloadSize=1395
...    MRBTS/MNL-1/MNLENT-1/XPAP-1/XPIF-1:sctpRtoMax=30000
...    MRBTS/MNL-1/MNLENT-1/XPAP-1/XPIF-1:sctpRtoMin=1000
...    MRBTS/MNL-1/MNLENT-1/XPAP-1/XPIF-1:sctpSackDelay=200
...    MRBTS/MNL-1/MNLENT-1/XPAP-1/XPIF-1:sctpSackFreq=2
...    MRBTS/MNL-1/MNLENT-1/XPAP-1/XPIF-1:sctpWaitTimeInitSeqRetry=240
...    MRBTS/MNL-1/MNLENT-1/XPAP-1/XPIF-1:udpDscp=18
...    MRBTS/MNL-1/MNLENT-1/XPAP-1/XPIF-1/XPIFREMOTE-1:ipAddress=10.0.1.13
...    MRBTS/MNL-1/MNLENT-1/XPAP-1/XPIF-1/XPIFREMOTE-1:remoteNeType=ENB

@{DSS_cell12_bwp}
...    NRBTS/BWP_PROFILE-5:bwpType=initial
...    NRBTS/BWP_PROFILE-5:locationAndBandwidthDl:cRbSizeDl=coreset0
...    NRBTS/BWP_PROFILE-5:locationAndBandwidthDl:cRbStartDl=coreset0
...    NRBTS/BWP_PROFILE-5:locationAndBandwidthUl:cRbSizeUl=allRb
...    NRBTS/BWP_PROFILE-5:locationAndBandwidthUl:cRbStartUl=crb0
...    NRBTS/BWP_PROFILE-5/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-5/PDCCH-1:dciDedicatedAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-5/PDCCH-1:dciPagingAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-5/PDCCH-1:dciRaCompletionAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-5/PDCCH-1:dciRaMsg2AggregationLevel=AL4
...    NRBTS/BWP_PROFILE-5/PDCCH-1:dciSiAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-5/PDCCH-1:downgradeAL16toAL8=notAllowed
...    delete: NRBTS/BWP_PROFILE-5/PDCCH-1:dynamicAggregationLevelSet
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:coresetCommon:cceToRegMapping=interleaved
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:coresetCommon:coresetId=4
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:coresetCommon:cRbStart=0
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:coresetCommon:duration=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:coresetCommon:interleaverSize=n3
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:coresetCommon:regBundleSize=n2
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:coresetCommon:size=48
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_2|searchSpaceId=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl80|searchSpaceId=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=1|searchSpaceId=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=47|searchSpaceId=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=2|searchSpaceId=2
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_2|searchSpaceId=2
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=2
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|searchSpaceId=2
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=6|searchSpaceId=2
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=3|searchSpaceId=3
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=3
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_2|searchSpaceId=3
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=3
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl40|searchSpaceId=3
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=3
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=27|searchSpaceId=3
...    NRBTS/BWP_PROFILE-6:bwpType=dedicated
...    NRBTS/BWP_PROFILE-6:locationAndBandwidthDl:cRbSizeDl=allRb
...    NRBTS/BWP_PROFILE-6:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-6:locationAndBandwidthUl:cRbSizeUl=allRb
...    NRBTS/BWP_PROFILE-6:locationAndBandwidthUl:cRbStartUl=crb0
...    NRBTS/BWP_PROFILE-6/PDCCH-1:alSelection=dynamic
...    NRBTS/BWP_PROFILE-6/PDCCH-1:dciDedicatedAggregationLevel=AL2
...    NRBTS/BWP_PROFILE-6/PDCCH-1:dciPagingAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-6/PDCCH-1:dciRaCompletionAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-6/PDCCH-1:dciRaMsg2AggregationLevel=AL4
...    NRBTS/BWP_PROFILE-6/PDCCH-1:dciSiAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-6/PDCCH-1:downgradeAL16toAL8=notAllowed
...    NRBTS/BWP_PROFILE-6/PDCCH-1:dynamicAggregationLevelSet:aggregationLevelList=AL1_AL2_AL4
...    NRBTS/BWP_PROFILE-6/PDCCH-1:dynamicAggregationLevelSet:cqiCorrectionUp=8
...    NRBTS/BWP_PROFILE-6/PDCCH-1:dynamicAggregationLevelSet:cqiDciCssAl1=101
...    NRBTS/BWP_PROFILE-6/PDCCH-1:dynamicAggregationLevelSet:cqiDciCssAl16=0
...    NRBTS/BWP_PROFILE-6/PDCCH-1:dynamicAggregationLevelSet:cqiDciCssAl2=69
...    NRBTS/BWP_PROFILE-6/PDCCH-1:dynamicAggregationLevelSet:cqiDciCssAl4=33
...    NRBTS/BWP_PROFILE-6/PDCCH-1:dynamicAggregationLevelSet:cqiDciCssAl8=10
...    NRBTS/BWP_PROFILE-6/PDCCH-1:dynamicAggregationLevelSet:highOlcCqiOffset=100
...    NRBTS/BWP_PROFILE-6/PDCCH-1:dynamicAggregationLevelSet:lowOlcCqiOffset=1100
...    NRBTS/BWP_PROFILE-6/PDCCH-1:dynamicAggregationLevelSet:pCqiErasureActTimer=160
...    NRBTS/BWP_PROFILE-6/PDCCH-1:dynamicAggregationLevelSet:pCqiErasureReduction=10
...    delete:NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:coresetCommon
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=4
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_2|searchSpaceId=4
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=4
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl80|searchSpaceId=4
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=4|searchSpaceId=4
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=4
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=47|searchSpaceId=4
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=5|searchSpaceId=5
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_2|searchSpaceId=5
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=5
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|searchSpaceId=5
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=6|searchSpaceId=5
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=6|searchSpaceId=6
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=6
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_2|searchSpaceId=6
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=6
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl40|searchSpaceId=6
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=6
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=27|searchSpaceId=6
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cceToRegMapping=nonInterleaved
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:coresetId=4
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cRbStart=0
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:duration=1
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:interleaverSize=none
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:regBundleSize=n6
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=48
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-0-And-1-0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=3|searchSpaceId=7
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_2|searchSpaceId=7
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n2|searchSpaceId=7
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n2|searchSpaceId=7
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|searchSpaceId=7
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl10|searchSpaceId=7
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=7|searchSpaceId=7
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|searchSpaceId=7
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=2|searchSpaceId=7
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=0|searchSpaceId=8
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-0-And-1-0|searchSpaceId=8
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=3|searchSpaceId=8
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_2|searchSpaceId=8
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n2|searchSpaceId=8
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceId=8
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n2|searchSpaceId=8
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|searchSpaceId=8
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceId=8
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl10|searchSpaceId=8
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=8|searchSpaceId=8
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|searchSpaceId=8
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=6|searchSpaceId=8
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|searchSpaceId=9
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=3|searchSpaceId=9
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_2|searchSpaceId=9
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n2|searchSpaceId=9
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n2|searchSpaceId=9
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|searchSpaceId=9
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl10|searchSpaceId=9
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=9|searchSpaceId=9
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|searchSpaceId=9
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=2|searchSpaceId=9
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|searchSpaceId=10
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=3|searchSpaceId=10
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_2|searchSpaceId=10
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n2|searchSpaceId=10
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n2|searchSpaceId=10
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|searchSpaceId=10
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl10|searchSpaceId=10
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=10|searchSpaceId=10
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|searchSpaceId=10
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=6|searchSpaceId=10
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=4|searchSpaceId=11
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|searchSpaceId=11
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|searchSpaceId=11
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_2|searchSpaceId=11
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n2|searchSpaceId=11
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n2|searchSpaceId=11
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|searchSpaceId=11
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl10|searchSpaceId=11
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=11|searchSpaceId=11
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|searchSpaceId=11
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=5|searchSpaceId=11
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=4|searchSpaceId=12
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-0-And-1-0|searchSpaceId=12
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=3|searchSpaceId=12
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_2|searchSpaceId=12
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n2|searchSpaceId=12
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceId=12
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n2|searchSpaceId=12
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|searchSpaceId=12
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceId=12
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl10|searchSpaceId=12
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=12|searchSpaceId=12
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|searchSpaceId=12
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=9|searchSpaceId=12
...    NRBTS/BWP_PROFILE-6/PDSCH-1:pdschRat0RbgConfig=config1

@{DSS_cell12_NRSYSINFO}
...    NRBTS/NRSYSINFO_PROFILE-2:addHystSfHigh=dB-2
...    NRBTS/NRSYSINFO_PROFILE-2:addHystSfMedium=dB-2
...    NRBTS/NRSYSINFO_PROFILE-2:nCellChangeHigh=16
...    NRBTS/NRSYSINFO_PROFILE-2:nCellChangeMedium=14
...    NRBTS/NRSYSINFO_PROFILE-2:qHyst=dB0
...    NRBTS/NRSYSINFO_PROFILE-2:siWindowLength=s160
...    NRBTS/NRSYSINFO_PROFILE-2:systemInformationTargetRate=1
...    NRBTS/NRSYSINFO_PROFILE-2:tEvaluation=s30
...    NRBTS/NRSYSINFO_PROFILE-2:tHystNormal=s30
...    NRBTS/NRSYSINFO_PROFILE-2:tReselectionEutra=0
...    NRBTS/NRSYSINFO_PROFILE-2:threshServingLowP=0
...    NRBTS/NRSYSINFO_PROFILE-2:threshServingLowQ=0
...    NRBTS/NRSYSINFO_PROFILE-2:sibSchedulingList:sibBroadcastStatus=broadcasting|sibType=sibType2
...    NRBTS/NRSYSINFO_PROFILE-2:sibSchedulingList:sibPeriodicity=rf64|sibType=sibType2
...    NRBTS/NRSYSINFO_PROFILE-2:sibSchedulingList:sibScope=cellSpecific|sibType=sibType2
...    NRBTS/NRSYSINFO_PROFILE-2:sibSchedulingList:sibType=sibType2|sibType=sibType2
...    NRBTS/NRSYSINFO_PROFILE-2:sibSchedulingList:sibBroadcastStatus=broadcasting|sibType=sibType3
...    NRBTS/NRSYSINFO_PROFILE-2:sibSchedulingList:sibPeriodicity=rf64|sibType=sibType3
...    NRBTS/NRSYSINFO_PROFILE-2:sibSchedulingList:sibScope=cellSpecific|sibType=sibType3
...    NRBTS/NRSYSINFO_PROFILE-2:sibSchedulingList:sibType=sibType3|sibType=sibType3
...    NRBTS/NRSYSINFO_PROFILE-2:sibSchedulingList:sibBroadcastStatus=broadcasting|sibType=sibType4
...    NRBTS/NRSYSINFO_PROFILE-2:sibSchedulingList:sibPeriodicity=rf64|sibType=sibType4
...    NRBTS/NRSYSINFO_PROFILE-2:sibSchedulingList:sibScope=cellSpecific|sibType=sibType4
...    NRBTS/NRSYSINFO_PROFILE-2:sibSchedulingList:sibType=sibType4|sibType=sibType4
...    NRBTS/NRSYSINFO_PROFILE-2:sibSchedulingList:sibBroadcastStatus=broadcasting|sibType=sibType5
...    NRBTS/NRSYSINFO_PROFILE-2:sibSchedulingList:sibPeriodicity=rf64|sibType=sibType5
...    NRBTS/NRSYSINFO_PROFILE-2:sibSchedulingList:sibScope=cellSpecific|sibType=sibType5
...    NRBTS/NRSYSINFO_PROFILE-2:sibSchedulingList:sibType=sibType5|sibType=sibType5
...    NRBTS/NRSYSINFO_PROFILE-2:sibSchedulingList:sibBroadcastStatus=broadcasting|sibType=sibType6
...    NRBTS/NRSYSINFO_PROFILE-2:sibSchedulingList:sibPeriodicity=rf64|sibType=sibType6
...    NRBTS/NRSYSINFO_PROFILE-2:sibSchedulingList:sibScope=cellSpecific|sibType=sibType6
...    NRBTS/NRSYSINFO_PROFILE-2:sibSchedulingList:sibType=sibType6|sibType=sibType6
...    NRBTS/NRSYSINFO_PROFILE-2:sibSchedulingList:sibBroadcastStatus=broadcasting|sibType=sibType7
...    NRBTS/NRSYSINFO_PROFILE-2:sibSchedulingList:sibPeriodicity=rf64|sibType=sibType7
...    NRBTS/NRSYSINFO_PROFILE-2:sibSchedulingList:sibScope=cellSpecific|sibType=sibType7
...    NRBTS/NRSYSINFO_PROFILE-2:sibSchedulingList:sibType=sibType7|sibType=sibType7
...    NRBTS/NRSYSINFO_PROFILE-2:sibSchedulingList:sibBroadcastStatus=broadcasting|sibType=sibType8
...    NRBTS/NRSYSINFO_PROFILE-2:sibSchedulingList:sibPeriodicity=rf64|sibType=sibType8
...    NRBTS/NRSYSINFO_PROFILE-2:sibSchedulingList:sibScope=cellSpecific|sibType=sibType8
...    NRBTS/NRSYSINFO_PROFILE-2:sibSchedulingList:sibType=sibType8|sibType=sibType8

${CA_support_list}  ca_Fr1Tdd_Fdd_Nsa

@{OnlineParam_BB048}
...    NRCELL-1/NRREL-10:sCellAdditionMethod=blind

@{OnlineParam_BB049}
...    NRCELL-1/NRREL-10:sCellAdditionMethod=covBasedA1

@{PM_Counters_Check_BB048}
...    NRCELL-1:RACCU:${SGNB_SCELL_1_ADMISSION_REQ}=1
...    NRCELL-1:RACCU:${SGNB_SCELL_1_ADMISSION_SUCC}=1
...    NRCELL-1:NCAC:${RRC_RECONF_1_SCELL_DL_ATT}=1
...    NRCELL-1:NCAC:${RRC_RECONF_1_SCELL_DL_SUCC}=1
...    NRCELL-1:NCAC:${UE_PSCELL_1_CONF_SCELL_DL}>0
...    NRCELL-1:RACDU:${SGNB_DU_SCELL_1_ADMISSION_REQ}=1
...    NRCELL-1:RACDU:${SGNB_DU_SCELL_1_ADMISSION_SUCC}=1
...    NRCELL-12:RACDU:${SGNB_DU_SCELL_ADMISSION_REQ}=1
...    NRCELL-12:RACDU:${SGNB_DU_SCELL_ADMISSION_SUCC}=1
...    NRCELL-12:NCAC:${UE_SCELL_1_CONF_SCELL_DL}>0


@{PM_Counters_Check_BB049}
...    NRCELL-1:RACCU:${SGNB_SCELL_1_ADMISSION_REQ}=1
...    NRCELL-1:RACCU:${SGNB_SCELL_1_ADMISSION_SUCC}=1
...    NRCELL-1:NCAC:${RRC_RECONF_1_SCELL_DL_ATT}=1
...    NRCELL-1:NCAC:${RRC_RECONF_1_SCELL_DL_SUCC}=1
...    NRCELL-1:NCAC:${UE_PSCELL_1_CONF_SCELL_DL}>0
...    NRCELL-1:RACDU:${SGNB_DU_SCELL_1_ADMISSION_REQ}=1
...    NRCELL-1:RACDU:${SGNB_DU_SCELL_1_ADMISSION_SUCC}=1
...    NRCELL-12:RACDU:${SGNB_DU_SCELL_ADMISSION_REQ}=1
...    NRCELL-12:RACDU:${SGNB_DU_SCELL_ADMISSION_SUCC}=1
...    NRCELL-12:NCAC:${UE_SCELL_1_CONF_SCELL_DL}>0
...    NRCELL-1:NCAC:${A2MEAS_REL1DLSCELL_ATT_NSA}=1
...    NRCELL-1:NCAC:${A2MEAS_REL1DLSCELL_SUCC_NSA}=1


${SGNB_SCELL_1_ADMISSION_REQ}    M55114C00021
#The number of radio admission requests for 1 Scell
${SGNB_SCELL_1_ADMISSION_SUCC}    M55114C00028
#The number of successful radio admissions for 1 Scell additions.
${RRC_RECONF_1_SCELL_DL_ATT}    M55118C02000
#RRC Reconfigurations attempts for 1 SCell Addition in DL for NSA mode
${RRC_RECONF_1_SCELL_DL_SUCC}    M55118C03000
#Successful RRC Reconfigurations attempts for 1 SCell Addition in DL for NSA mode
${UE_PSCELL_1_CONF_SCELL_DL}    M55118C04000
#Number of CA UEs in the current cell configured as a PSCell, which have 1 configured SCell in DL
${SGNB_DU_SCELL_1_ADMISSION_REQ}    M55115C00008
#The number of radio admission requests for 1 Scell
${SGNB_DU_SCELL_1_ADMISSION_SUCC}    M55115C00015
#The number of successful radio admissions for 1 Scell additions.
${SGNB_DU_SCELL_ADMISSION_REQ}    M55115C00006
#The number of radio admission requests for the Scell
${SGNB_DU_SCELL_ADMISSION_SUCC}    M55115C00007
#The number of successful radio admissions for the Scell
${UE_SCELL_1_CONF_SCELL_DL}    M55118C05000
#Number of CA UEs in the current cell configured as a SCell, which have 1 configured SCell in DL
${A2MEAS_REL1DLSCELL_ATT_NSA}    M55118C06503
#Nbr of RRC Reconfiguration attempts releasing 1 SCell in DL triggered by A2 measurement for NSA
${A2MEAS_REL1DLSCELL_SUCC_NSA}    M55118C06504
#Nbr of successful RRC Reconfigurations releasing 1 SCell in DL triggered by A2 measurement for NSA

${SA_Capa_perUE_Full_ue91}    SEPARATOR=
...    E9A09000575F5A13160003C0A02C1262E003387A0609B20C39F30C7942C0E098040623807DC6C28C0D608C21A0810748046D6C98AB1A1CF88
...    E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE0003801C0A83620EB04610D04083C40232B64C55890E7D813E238F189
...    1C790E7D473E618F28581C0E1E13FB000000FEC0000003801C0AA3626EB04610D04083A40230B64C55110E7C471E238F40CFB027C639F30C7
...    942C0E070F05C00FFC007003FF0001C00E0541F11B582308682041E201195B262AC4873E238F604F8C48E3C873EA39F30C7942C0E070F09FF
...    F000007FFC000001C00E007BC3C4D000E208000010B0102A0F0A000388C0000042C0AC3C46000E208000030B02B0F0A00038820000042C0AC
...    3C4D000E230000010B02B17118003882001C4100000A160561E14000713400003058158B89A001C41000E140000040B02B1713400388C001C
...    46000004160562E14000710400388C0000082C0AC5C28000E20800710400001058158B89A001C41000E230000020B02B170A000388C001C46
...    000004160562E2680071180038500000102C0AC3C46000E230000030B0200E0234028809B0104155D83E14489B1CF870A244D8E7C3851226C
...    73E1C28913639F0E14489B1CF871224489B1CF870A040D8E7C08902040D8E7C08902040D8E7C08902040D8E7C08902040D8E7C08902040D8E
...    7C08902040D8E7C08902040D8E7C0850206C73E000B878C6318C6318C6318C630F40B00F000A070300E0600A80E000C0480080C07C1200400
...    00000200000401000000008000010040000100200000C01000008008000050040020080200800006004000038020010000000400004002000
...    024010000060080000A004000058020010240900400006019CA9ACA9AC14AC0CAC19AC15ACA5AC99AC05AC0DAC04AC08AC1DA0682000012CA
...    4A080000CB29282000052CA48080001CB29202000092CA48080002CB292020000D2CA48080003CB29202000112CA48080004CB29202000152
...    CA48080005CB29282000192CA480800018B292019A55574AAAA9545D2A8AA0B154162A83455298AA4D154062A8145526AAA0F14045E02540A
...    05028140A05028140A05028140A05028140A05000608080600C02004008404008020100C018402004008080600C02018030404030060100C0
...    18402004008080600C02004008804030060100C018040300608080100402004010D50F8000810182030385058606880889098A0C0C8D8E0E8
...    F909293139414951697A0A0C1680

${Capa_LTE_ue91}    SEPARATOR=
...    A11FF83BC4C0C03850001C46000000162205E260601C4D000E230000000B1102F130300E26800710400000058881789818070A00038820000
...    002C040BC4C0C03882001C46000002160205E360601C46000E208007104000010580817898180713400385000000C2C040804808D00A001C0
...    41809A1E80B907893A244D8E7C3893A244D8E7C3893A244D8E7C3893A244D8E7C3893A24498E7D1A7448912639F449D1224C73E01A0718C63
...    18C60C02080002010100200804030061000040202004008080600C3000080404030060100C018040300610000402020040100801004000000
...    00

${list1}    0:0,52+1:0,52+2:0,52+3:0,52+4:0,52+5:0,52+6:0,52+7:0,52+8:0,52+9:0,52+10:0,52+11:0,52+12:0,52+13:0,52+14:0,
${list2}    52+15:0,52+16:0,52+17:0,52+18:0,52+19:0,52+20:0,52+21:0,52+22:0,52+23:0,52+24:0,52+25:0,52+26:0,52+27:0,52+28:0,52+29:0,52+30:0,52+31:0,
${list3}    52+32:0,52+33:0,52+34:0,52+35:0,52+36:0,52+37:0,52+38:0,52+39:0,52+40:0,52+41:0,52+42:0,52+43:0,52+44:0,52+45:0,52+46:0,52+47:0,52+48:0,
${list4}    52+49:0,52+50:0,52+51:0,52+52:0,52+53:0,52+54:0,52+55:0,52+56:0,52+57:0,52+58:0,52+59:0,52+60:0,52+61:0,52+62:0,52+63:0,52+64:0,52+65:0,
${list5}    52+66:0,52+67:0,52+68:0,52+69:0,52+70:0,52+71:0,52+72:0,52+73:0,52+74:0,52+75:0,52+76:0,52+77:0,52+78:0,52+79:0,52
${Resource_Allocation}    enb_dss_resource_allocation enb=1 cell=2 tgt_enb=2 tgt_cell=12 dir=DL
...    allocation_start_time=immediate
...    dl_allocated_normal_subframes=1011110011-1111111111-1011110011-1111111111-1011110011-1111111111-1011110011-1111111111
...    dl_prb_area_allocation_list=${list1}${list2}${list3}${list4}${list5}

*** Test Cases ***
CB008542-ET-BB048_Verify_NSA_TF_blind_scell_addition_successfully_when_DSS_enabled_for_FDD_scell
    [Documentation]
    ...    1. The purpose of this test case is to check following scenarios:
    ...       US CB008542-BB#B9: FR1 TDD + FDD DL CA interworking with DSS in NSA option 3x
    ...       This US describes the expected behaviour of UE and gNB when DSS is enabled in FDD SCell within TDD-FDD DL
    ...       CA in NSA 3x mode.
    ...       Precondition:
    ...       1. enb1 cell1 is configured as non-DSS cell(configured for EN-DC), and cell2 as DSS cell.
    ...       2. gnb FDD cell12 has the same frequency with enb cell2
    ...       3. UE91 supports DSS while UE92 doesn't.
    ...    2. Test Case Steps:
    ...         a. NSA UE91 attach to NR Cell 1, and scell12 is added as scell blindy.
    ...         b. NSA UE92 attach to NR Cell 1, scell will not be added as UE92 doesn't support DSS.
    ...         c. all ue detach
    ...    3. Expected Results:
    ...         a. NSA UE91 attach to NR Cell 1, cell12 is added as scell blindy, DRX setup. Both Pcell ans scell traffic are ok.
    ...         b: NSA UE92 attach to NR Cell 1, scell will not be added as UE92 doesn't support DSS. DRX setup. Traffic on Pcell is OK.
    ...         c: ALL UEs can be released successfully.
	[Tags]    QC_164081    BB048   WuJiadan
	Delta Commission Parameters    ${OnlineParam_BB048}
	Clear Counter Files
	NSA CA DSS UE91 attach and scell added blindly and check traffic
	NSA CA nonDSS UE92 attach and no scell added blindly and check traffic
	Stop Traffic And Detach Ue
	Check Counters    ${PM_Counters_Check_BB048}
	Check Wireshark    BB048

CB008542-ET-BB049_Verify_NSA_TF_A1_scell_addition_A2_scell_release_successfully_when_DSS_enabled_for_FDD_scell
    [Documentation]
    ...    1. The purpose of this test case is to check following scenarios:
    ...       US CB008542-BB#B9: FR1 TDD + FDD DL CA interworking with DSS in NSA option 3x
    ...       This US describes the expected behaviour of UE and gNB when DSS is enabled in FDD SCell within TDD-FDD DL
    ...       CA in NSA 3x mode.
    ...       Precondition:
    ...       1. enb1 cell1 is configured as non-DSS cell(configured for EN-DC), and cell2 as DSS cell.
    ...       2. gnb FDD cell12 has the same frequency with enb cell2
    ...       3. UE91 supports DSS while UE92 doesn't.
    ...    2. Test Case Steps:
    ...         a. NSA UE91 attach to NR Cell 1.
    ...         b. Trigger A1 MR for scell addition.
    ...         c. Trigger A2 MR for scell release.
    ...         b. NSA UE92 attach to NR Cell 1, scell will not be added as UE92 doesn't support DSS.
    ...         e. all ue detach
    ...    3. Expected Results:
    ...         a. NSA UE91 attach to NR Cell 1, DRX setup.
    ...         b. scell addition successfully. Both Pcell ans scell traffic are ok.
    ...         c. scell release successfully. Pcell traffic is OK.
    ...         d. NSA UE92 attach to NR Cell 1, A1 will not be configured to UE as UE92 doesn't support DSS. DRX setup. Traffic on Pcell is OK.
    ...         e. ALL UEs can be released successfully.
    [Tags]    QC_164080    BB049   WuJiadan
    Delta Commission Parameters    ${OnlineParam_BB049}
    Clear Counter Files
    NSA CA DSS UE91 attach and coverbased scell addition and release and check traffic
    NSA CA nonDSS UE92 attach and no A1 configured and check traffic
    Stop Traffic And Detach Ue
    Check Counters    ${PM_Counters_Check_BB049}
    Check Wireshark    BB049

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_2T4F
	
Perform Steps After WTS Started
    Setup Xp link
	Set LTE NR DSS configuration
	Reserve DSS Cell resource

Modify Cfg
    ${V1}    catenate
    ...    set_gnb id=2 type=external plmn=311:489 x2=10.0.1.2:36422 ng=10.0.1.2 gnb_id=0x02:22 daemon=10.0.2.1:22222 x2_peers=none xn=10.0.1.2
    ...    amf=1 xp_management=on xp=10.0.1.2:32742 xpu=10.0.1.2:32742
    ${V2}   catenate
    ...    set_cell id=12 gnb=2 pci=20:1 tac=0 nrci=0x0C tdd_cell=off proxy=10.0.2.80:9999|10.0.2.80:8888 nr_arfcn=136300:127100 gscn=1588
    ...    mandatory_for_activation=off
    ${V3}   catenate
    ...    set_enb id=1 plmn=311:489 s1=10.0.1.12 enb_id_macro=0x00001 daemon=10.0.2.1:22222 x2=10.0.1.13 x2u=10.0.1.13 type=simulated x2_peers=none
    ...    xp_management=on xp=10.0.1.13:32742 xpu=10.0.1.13:32742
    ${V4}   catenate
    ...    set_cell id=1 enb=1 eci=0x0000101 pci=4:0 tac=222 proxy=10.0.2.1:12219|$CONTAINER_IP:8889 earfcn=2000:20000 mapped_earfcn=4200:22200
    ...    mandatory_for_activation=off
    ${V5}   catenate
    ...    set_cell id=2 enb=1 eci=0x0000102 pci=4:1 tac=222 proxy=10.0.2.1:12220|$CONTAINER_IP:8890 earfcn=68771:133307
    ...    mandatory_for_activation=off bw=10MHz
    Update Cfg    ${V1}
    Update Cfg    ${V2}
    Update Cfg    ${V3}
    Update Cfg    ${V4}
    Update Cfg    ${V5}

Precondition UE91 setting for supporting DSS
    [Arguments]    ${ue_id}=91
    Update UE capa    ${ue_id}    ${SA_Capa_perUE_Full_ue91}    ${Capa_LTE_ue91}
    Execute Egate Command    ue_enb_endc_param id=${ue_id} reset
    Execute Egate Command    enb_endc_param id=1 reset
    Execute Egate Command    enb_endc_param id=1 control_flow_period=3gpp1 use_nr_ran_cont=on serving_cell_index_range_scg=8:14
    Execute Egate Command    ue_change_location id=${ue_id} cell=1 enb=1

Update UE capa
    [Arguments]    ${ue_id}=91    ${SA_Capa_perUE_Full}=none    ${Capa_LTE}=none
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full}
    ...    dual_conn=eutra_nr ue_eutra_nr_capabilities=${Capa_LTE}
    Execute Egate Command    ${cmd}

Setup Xp link
    Execute Egate Command    sim_trace enb=1 protocol=xp on
    Execute Egate Command    enb_xp_param id=1 xp_peers=none
    Execute Egate Command    enb_xp_param id=1 xp_peers=2
    Execute Egate Command    enb_xp_link_up enb=1 target=2    pass_regexp=is up    timeout=90s

Set LTE NR DSS configuration
    [Arguments]    ${sleep_time}=4
    Execute Egate Command    enb_dss_param id=1 feature_flag=on message_sets=DMS3    pass_regexp=EGATE>    sleep_time=${sleep_time}
    Execute Egate Command    enb_cell_param id=2 enb=1 lte_nr_dss_mode=DSS_PHASE_3 antenna_ports_num=2    pass_regexp=EGATE>
    ...    sleep_time=${sleep_time}
    Execute Egate Command    enb_cell_dss_feature enb=1 id=2 nr_dl_peak_rate_increase=on    pass_regexp=EGATE>    sleep_time=${sleep_time}
    Execute Egate Command    enb_cell_dss_feature enb=1 id=2 superfast_allocation=off    pass_regexp=EGATE>    sleep_time=${sleep_time}
    Execute Egate Command    enb_dss_cell_param enb=1 id=2 dl_resource_sharing_algo=dl_prb_load_based    pass_regexp=EGATE>
    ...    sleep_time=${sleep_time}
    Execute Egate Command    enb_configure_dss_partnership enb=1 cell=2 dss_peer=2:12
    ...    pass_regexp=CRM Partnership Creation    sleep_time=${sleep_time}
    ${command1}    catenate
    ...    enb_crm_cell_resource_reservation enb=1 cell=2 tgt_enb=2 tgt_cell=12 assigned_dl_minimum_share_to_nr=30
    ...    assigned_dl_maximum_share_to_nr=100 assigned_dl_minimum_share_to_lte=15 assigned_dl_maximum_share_to_lte=70
    ...    assigned_ul_minimum_share_to_nr=20 assigned_ul_maximum_share_to_nr=70
    Execute Egate Command    ${command1}    pass_regexp=EGATE>    sleep_time=${sleep_time}
    Execute Egate Command    enb_crm_param id=1 ul_qos_load_meas_timer=200 dl_qos_load_meas_timer=200    pass_regexp=EGATE>
    ...    sleep_time=${sleep_time}
    Execute Egate Command    enb_dss_establish_partnership enb=1 cell=2 tgt_enb=2 tgt_cell=12    pass_regexp=Partnership activated on both partners
    ...    sleep_time=${sleep_time}

Reserve DSS Cell resource
    [Arguments]    ${sleep_time}=3
    Execute Egate Command    enb_dss_cell_resource_reservation_dl enb=1 cell=2 reset    pass_regexp=EGATE>    sleep_time=${sleep_time}
    Execute Egate Command    enb_dss_cell_resource_reservation_ul enb=1 cell=2 reset    pass_regexp=EGATE>    sleep_time=${sleep_time}
    ${cmd1}    catenate    enb_dss_dl_resource_cell_reservation cell=2 enb=1 prb_area_reservation_list=0,0,0-10-none+0,0,5-10-none+0,0,9-10-none
    Execute Egate Command    ${cmd1}    pass_regexp=EGATE>    sleep_time=${sleep_time}
    ${command2}    catenate
    ...    enb_dss_dl_resource_cell_reservation cell=2 enb=1
    ...    reserved_fixed_normal_subframes=0000000000-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000
    Execute Egate Command    ${command2}    pass_regexp=EGATE>    sleep_time=${sleep_time}
    ${cmd2}    catenate    enb_dss_dl_resource_cell_reservation cell=2 enb=1 min_lte_nr_dss_ratio=30 max_lte_nr_dss_ratio=100
    Execute Egate Command    ${cmd2}   pass_regexp=EGATE>    sleep_time=${sleep_time}
    Execute Egate Command    enb_dss_cell_resource_coordination enb=1 cell=2 tgt_enb=2 tgt_cell=12 dir=DL    pass_regexp=EGATE>
    ...    sleep_time=${sleep_time}
    Execute Egate Command    enb_dss_ul_cell_resource_reservation enb=1 cell=2 minimum_prb_share=30 maximum_prb_share=70    pass_regexp=EGATE>
    ...    sleep_time=${sleep_time}
    Execute Egate Command    enb_dss_cell_resource_coordination enb=1 cell=2 tgt_enb=2 tgt_cell=12 dir=UL    pass_regexp=EGATE>
    ...    sleep_time=${sleep_time}
    Execute Egate Command    ${Resource_Allocation}    pass_regexp=CRM Trigger Resource Allocation    sleep_time=${sleep_time}
    ${command4}    catenate
    ...    enb_dss_resource_allocation enb=1 cell=2 tgt_enb=2 tgt_cell=12 dir=UL allocation_start_time=immediate ul_allocated_prb_list=0,3|5,35|49,3
    Execute Egate Command    ${command4}    pass_regexp=CRM Trigger Resource Allocation    sleep_time=${sleep_time}
    Execute Egate Command    enb_crm_status enb=1 cell=2    pass_regexp=EGATE>    sleep_time=${sleep_time}

NSA CA DSS UE91 attach and scell added blindly and check traffic
    [Arguments]    ${ue_id}=91    ${cell_id}=1
    Precondition UE91 setting for supporting DSS
    NSA UE attach    ${ue_id}    ${cell_id}    pass    SCellIndex 9 activated successfully
    Send trffic
    Verify Throuput on Pscell cell1 and Scell cell12

NSA CA nonDSS UE92 attach and no scell added blindly and check traffic
    [Arguments]    ${ue_id}=92    ${cell_id}=1
    NSA UE attach    ${ue_id}    ${cell_id}    fail    SCellIndex 9 activated successfully
    Send trffic    92    30
    Verify Throuput on Pscell cell1    92

NSA CA DSS UE91 attach and coverbased scell addition and release and check traffic
    [Arguments]    ${ue_id}=91    ${cell_id}=1
    Precondition UE91 setting for supporting DSS
    NSA UE attach    ${ue_id}    ${cell_id}
    Send trffic    91    30
    Verify Throuput on Pscell cell1
    Add gNB Cell As Scell By A1    carrierfreq=518910
    Verify Throuput on Pscell cell1 and Scell cell12
    Release Scell By A2
    Verify Throuput on Pscell cell1

NSA CA nonDSS UE92 attach and no A1 configured and check traffic
    [Arguments]    ${ue_id}=92    ${cell_id}=1
    NSA UE attach    ${ue_id}    ${cell_id}
    Check No A1 config
    Send trffic    92    30
    Verify Throuput on Pscell cell1    92

NSA UE attach
    [Arguments]    ${ue_id}=91    ${target_cells}=1    ${regexp}=pass    ${regexp_sting}=successful RA
    Execute Egate Command    ue_attach id=${ue_id}    UE IS ACTIVE
    ${cmd}    catenate    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${target_cells} bearer=2 type=split_scg
    Execute Egate Command    ${cmd}    ${regexp}_regexp=${regexp_sting}

Add gNB Cell As Scell By A1
    [Arguments]    ${ue_id}=91    ${carrierfreq}=518910
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A1
    Execute Egate Command    ue_measurement_send_nr id=91 meas_id=${meas_id} event=A1 srsrp_nr=100
    ...    pass_regexp=SCellIndex 9 activated successfully    sleep_time=30

Check No A1 config
    [Arguments]    ${ue_id}=92
    ${ret1}=    Execute Egate Command    ue_meas_cfg_disp id=${ue_id} meas_obj_type=nr
    ...    DETAILED INFO
    Should Not Contain    ${ret1}    EventA1


Release Scell By A2
    [Arguments]    ${ue_id}=91    ${carrierfreq}=127010
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A2
    ${cmd}    catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 srsrp_nr=90 srsrq_nr=90 scell=9 scell_rsrp=10
    ...   scell_rsrq=10
    Execute Egate Command    ${cmd}

Check Wireshark
    [Arguments]    ${case_id}=BB048
    check wireshark log    ${CURDIR}${/}a2a_${case_id}${/}a2a.ini

Stop Traffic And Detach Ue
    Stop Traffic
    UE Detach From GNB

Stop Traffic
    Execute Egate Command    trf_data_stop ue=91    pass_regexp=Traffic was stopped
    Execute Egate Command    trf_data_stop ue=92    pass_regexp=Traffic was stopped

UE Detach From GNB
    [Arguments]    ${expect_string}=${EMPTY}
    Execute Egate Command  ue_detach id=91    ${expect_string}
    Execute Egate Command  ue_detach id=92    ${expect_string}

Send trffic
    [Arguments]    ${ue_id}=91    ${sleep_time}=30
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=dl mbps=150 trf_id=1    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=dl mbps=150 trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=dl mbps=150 trf_id=3    UE ${ue_id}: UDP DL
	Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=dl mbps=150 trf_id=4    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=ul mbps=10    UE ${ue_id}: UDP UL    sleep_time=${sleep_time}

Verify Throuput on Pscell cell1
    [Arguments]    ${ue_id}=91
    ${scell8_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=8    type=pdsch    rate_type=ave
    Should Be True    ${scell8_tput}/1000>150
    ${ul_throuput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=ul    dc_cell_group=all    rate_type=ave
    Should Be True    ${ul_throuput}/1000>6

Verify Throuput on Pscell cell1 and Scell cell12
    [Arguments]    ${ue_id}=91
    ${scell8_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=8    type=pdsch    rate_type=ave
    Should Be True    ${scell8_tput}/1000 > 150
    ${scell9_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=9    type=pdsch    rate_type=ave
    Should Be True    ${scell9_tput}/1000 > 55
    ${ul_throuput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=ul    dc_cell_group=all    rate_type=ave
    Should Be True    ${ul_throuput}/1000>6


