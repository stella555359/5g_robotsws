*** Settings ***
Suite Setup  Common Suite Setup And Setup Airphone Env
Suite Teardown  Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup  Common Test Setup And Start To Capture Logs
Test Teardown  Common Test Teardown And Stop Capture Logs
Force Tags  QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    CRT    CLOUD_5G_I_LO_AP_LO
...    team-PZ3_7    owner-Flora.Du    release-5G24R3     CB10986-B
Resource  ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_IPHY_XML}
...    vcell:ulFeatures=advancedSRS|cell=2.1

@{PARAMS_IN_SCF}
...    NRCELL:actDl256Qam=true
...    @{enableCDrx}
...    @{enableBeamforming}
...    @{srsConfig}
...    @{CB10986_A}
...    @{Enable_CB007552}

@{CB10986_A}
...    NRCELL-1:actUlNrEcIdAoa=true
...    NRCELL-1:actUlNrEcIdPosMethod=true
...    NRCELL-1:ulAoaMonitorWindow=100
...    NRBTS:nrEcidMeasSupervisionTimer=3000

@{ENABLE_CB10986B}
...    NRCELL-1:actUlNrEcIdNgRanApPosition=true
...    NRCELL-1:nGRanAccessPointPosition:altitude=32767
...    NRCELL-1:nGRanAccessPointPosition:confidence=100
...    NRCELL-1:nGRanAccessPointPosition:degreesOfLatitude=8388607
...    NRCELL-1:nGRanAccessPointPosition:degreesOfLongitude=-8388608
...    NRCELL-1:nGRanAccessPointPosition:directionOfAltitude=Height
...    NRCELL-1:nGRanAccessPointPosition:latitudeSign=North
...    NRCELL-1:nGRanAccessPointPosition:orientationOfMajorAxis=179
...    NRCELL-1:nGRanAccessPointPosition:uncertaintyAltitude=0
...    NRCELL-1:nGRanAccessPointPosition:uncertaintySemiMajor=127
...    NRCELL-1:nGRanAccessPointPosition:uncertaintySemiMinor=127
...    NRCELL-1:lcsToGcsTranslate:bearingAngle=3599
...    NRCELL-1:lcsToGcsTranslate:downtiltAngle=0
...    NRCELL-1:lcsToGcsTranslate:slantAngle=3599

@{DISABLE_CB10986B}
...    NRCELL-1:actUlNrEcIdNgRanApPosition=false
...    delete:NRCELL-1:nGRanAccessPointPosition
#...    delete:NRCELL-1:lcsToGcsTranslate

@{enableBeamforming}
...    NRCELL:beamSet:nrBtsBeamRefinementP2=true
...    NRCELL-1:beamSet:basicBeamSet=beamSet_6
...    NRBTS-1:actCustomBsr=true
...    NRBTS-1/NRCELL-1:beamSet:customBeamSetName=BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
...    NRBTS-1/NRCELL-1:beamSet:leftEdgeAngle=60
...    NRBTS-1/NRCELL-1:beamSet:rightEdgeAngle=60
...    NRBTS-1/NRCELL-1:beamSet:lowerEdgeAngle=120
...    NRBTS-1/NRCELL-1:beamSet:upperEdgeAngle=60
...    NRBTS-1/NRCELL-1:beamSet:beamsMuted=0
...    NRBTS-1/NRCELL-1:beamSet:tiltOffset=0
...    NRBTS-1/NRCELL-1:beamSet:nrBtsBeamRefinementP2=true
...    NRBTS-1/NRCELLGRP-0:numberOfTransmittedSsBlocks=6 beams
...    NRBTS-1/NRCELLGRP-1:numberOfTransmittedSsBlocks=4 beams
...    NRBTS-1/NRCELL-2:beamSet:basicBeamSet=beamSet_4
...    NRBTS-1/NRCELL-2:beamSet:leftEdgeAngle=60
...    NRBTS-1/NRCELL-2:beamSet:lowerEdgeAngle=135
...    NRBTS-1/NRCELL-2:beamSet:rightEdgeAngle=60
...    NRBTS-1/NRCELL-2:beamSet:upperEdgeAngle=80
...    NRBTS-1/NRSYSINFO_PROFILE-1/NRIAFIM-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL:numberOfRxBeamforming=4Rx
...    NRCELL:actBeamforming=true
...    NRCELL:mMimoAntArrayMode=Full 64TRX Array (4x8x2)
...    NRCELL-1:dlMimoMode=2x2 Closed Loop Spatial Multiplexing
...    NRCELL-2:dlMimoMode=4x4 or 4x2 Open Loop Spatial Multiplexing
...    NRCELL:nrCellType= 8DL4UL
...    NRCELL-1:prachConfigurationIndex=97

@{enableCDrx}
...    NRCELL:actCDrx=true

@{srsConfig}
...    NRCELL:dftBeamDiffThresholdH=15
...    NRCELL:dftBeamDiffThresholdV=15
...    NRCELL-1:actUlSrsBm=true
...    NRCELL-1:actDlSrsBm=false
...    NRCELL-1:srsForBeamMgmt:srsUePeriodicity=slots40
...    NRCELL-1:srsForBeamMgmt:cSRS=62
...    NRCELL-1:srsForBeamMgmt:bSRS=2
...    NRCELL-1:srsForBeamMgmt:comb=comb2
...    NRCELL:srsForBeamMgmt:srsPowerThresholdForDlBm=-1200
...    NRCELL:srsForBeamMgmt:srsPowerThresholdForUlBm=-1320
...    NRCELL-1:srsForBeamMgmt:srsTypeAllocForDlBm=antenna switching or codebook
#...    NRCELL-2:actUlSrsBm=true
#...    NRCELL-2:actDlSrsBm=true
#...    NRCELL-2:srsForBeamMgmt:srsUePeriodicity=slots10
#...    NRCELL-2:srsForBeamMgmt:cSRS=12
#...    NRCELL-2:srsForBeamMgmt:bSRS=2
#1208 Frame Structure
...    NRCELL-1:tddFrameStructure:frameStructureType=tdLte
...    NRCELL-1:tddFrameStructure:guardPeriodLength=6Symbols
...    NRCELL-1:tddFrameStructure:lteToNrFrameShift=0ms
...    NRCELL-1:tddFrameStructure:tdLteUlDlConfig=tdLteConfig2
...    NRCELL-1:tddFrameStructure:ulDlDataSlotRatio=1/4
#2226 Frame Structure disable
...    NRBTS:actCoverageNonCoherentUes=false

...    NRCELL-2:freqBandIndicatorNR=41
...    NRCELL-2:gscnOrSsPbchArfcn=6351
...    NRCELL-2:nrarfcn=508020
...    NRCELL-2:chBw=80MHz
...    NRBTS:actFdmEnhancedScheduling=true
...    NRCELL:pucchModeSelect=longPucch
...    NRBTS-1/NRSYSINFO_PROFILE-1:systemInformationTargetRate=0
...    NRBTS-1/NRCELL:type0SearchSpaceConfigurationIndex=5
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-1:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-1:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-2:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-2:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-3:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-3:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-4:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-4:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-6:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-7:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-7:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-8:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-8:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2/CHANNEL-1:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2/CHANNEL-1:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2/CHANNEL-2:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2/CHANNEL-2:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2/CHANNEL-3:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2/CHANNEL-3:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2/CHANNEL-4:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2/CHANNEL-4:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-1:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-1:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-2:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-2:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-3:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-3:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-4:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-4:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-6:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-7:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-7:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-8:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-8:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-2
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-2/CHANNEL-1:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-2/CHANNEL-1:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-2/CHANNEL-2:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-2/CHANNEL-2:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-2/CHANNEL-3:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-2/CHANNEL-3:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-2/CHANNEL-4:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-2/CHANNEL-4:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1

@{Enable_CB007552}
...    NRBTS:actMultipleDedicatedBWPs=true
...    NRBTS/BWP_PROFILE-55:bwpType=dedicated
...    NRBTS/BWP_PROFILE-55:locationAndBandwidthDl:cRbSizeDl=n162
...    NRBTS/BWP_PROFILE-55:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-55:locationAndBandwidthUl:cRbSizeUl=sameAsDl
...    NRBTS/BWP_PROFILE-55:locationAndBandwidthUl:cRbStartUl=sameAsDl
...    NRBTS/BWP_PROFILE-55/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-55/PDCCH-1:dciDedicatedAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-55/PDCCH-1:dciPagingAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-55/PDCCH-1:dciRaCompletionAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-55/PDCCH-1:dciRaMsg2AggregationLevel=AL4
...    NRBTS/BWP_PROFILE-55/PDCCH-1:dciSiAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-55/PDCCH-1:downgradeAL16toAL8=notAllowed
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=12
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=12
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=3|searchSpaceId=12
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=12
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n1|searchSpaceId=12
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=12
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n4|searchSpaceId=12
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n2|searchSpaceId=12
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceId=12
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=12
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=12
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=13
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=13
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=13
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=13
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=13
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n4|searchSpaceId=13
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=13
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=13
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=13
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=13
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=13
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=14
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=14
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=3|searchSpaceId=14
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=14
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n1|searchSpaceId=14
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=14
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n4|searchSpaceId=14
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n2|searchSpaceId=14
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceId=14
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=14
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=14
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cceToRegMapping=nonInterleaved
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:coresetId=1
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cRbStart=0
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:duration=1
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:interleaverSize=none
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:regBundleSize=n6
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=120
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-0-And-1-0|coresetId=0
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|coresetId=0
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=0
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=0
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=0
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=0
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|coresetId=0
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=0
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|coresetId=0
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=15|coresetId=0
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|coresetId=0
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=0
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|coresetId=1
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|coresetId=1
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=1
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=1
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=1
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=1
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n5|coresetId=1
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=1
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|coresetId=1
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=16|coresetId=1
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|coresetId=1
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=1
...    NRBTS/BWP_PROFILE-55/PDSCH-1:pdschRat0RbgConfig=config1
...    NRBTS/BWP_PROFILE-56:bwpType=powerSaving
...    NRBTS/BWP_PROFILE-56:locationAndBandwidthDl:cRbSizeDl=n162
...    NRBTS/BWP_PROFILE-56:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-56:locationAndBandwidthUl:cRbSizeUl=sameAsDl
...    NRBTS/BWP_PROFILE-56:locationAndBandwidthUl:cRbStartUl=sameAsDl
...    NRBTS/BWP_PROFILE-56/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-56/PDCCH-1:dciDedicatedAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-56/PDCCH-1:dciPagingAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-56/PDCCH-1:dciRaCompletionAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-56/PDCCH-1:dciRaMsg2AggregationLevel=AL4
...    NRBTS/BWP_PROFILE-56/PDCCH-1:dciSiAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-56/PDCCH-1:downgradeAL16toAL8=notAllowed
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=17
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=17
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=3|searchSpaceId=17
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=17
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n1|searchSpaceId=17
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=17
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n4|searchSpaceId=17
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n2|searchSpaceId=17
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceId=17
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=17
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=17
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=18
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=18
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=18
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=18
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=18
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n4|searchSpaceId=18
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=18
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=18
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=18
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=18
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=18
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=19
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=19
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=3|searchSpaceId=19
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=19
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n1|searchSpaceId=19
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=19
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n4|searchSpaceId=19
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n2|searchSpaceId=19
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceId=19
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=19
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=19
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cceToRegMapping=nonInterleaved
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:coresetId=1
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cRbStart=0
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:duration=1
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:interleaverSize=none
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:regBundleSize=n6
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=120
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-0-And-1-0|coresetId=0
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|coresetId=0
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=0
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=0
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=0
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=0
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|coresetId=0
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=0
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|coresetId=0
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=20|coresetId=0
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|coresetId=0
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=0
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|coresetId=1
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|coresetId=1
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=1
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=1
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=1
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=1
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n5|coresetId=1
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=1
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|coresetId=1
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=21|coresetId=1
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|coresetId=1
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=1
...    NRBTS/BWP_PROFILE-56/PDSCH-1:pdschRat0RbgConfig=config1
...    NRBTS/BWP_PROFILE-6:bwpType=initial
...    NRBTS/BWP_PROFILE-6:locationAndBandwidthDl:cRbSizeDl=n162
...    NRBTS/BWP_PROFILE-6:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-6:locationAndBandwidthUl:cRbSizeUl=sameAsDl
...    NRBTS/BWP_PROFILE-6:locationAndBandwidthUl:cRbStartUl=sameAsDl
...    NRBTS/BWP_PROFILE-6/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-6/PDCCH-1:dciDedicatedAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-6/PDCCH-1:dciPagingAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-6/PDCCH-1:dciRaCompletionAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-6/PDCCH-1:dciRaMsg2AggregationLevel=AL4
...    NRBTS/BWP_PROFILE-6/PDCCH-1:dciSiAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-6/PDCCH-1:downgradeAL16toAL8=notAllowed
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=3|searchSpaceId=9
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n1|searchSpaceId=9
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n4|searchSpaceId=9
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n2|searchSpaceId=9
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceId=9
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=9
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=10
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=10
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n4|searchSpaceId=10
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n4|searchSpaceId=10
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=10
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=10
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=3|searchSpaceId=11
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n1|searchSpaceId=11
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n4|searchSpaceId=11
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n2|searchSpaceId=11
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceId=11
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=11
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=11

${LOOP}    5

#${SleepForMIBSIBFinishPrint}    10s
${rdSrsCodebookAndTas}    0x590103
${rdPriorSrsForDlBm}    0x590104
@{PARAMS_IN_SWCONFIG}  ${rdSrsCodebookAndTas}=1    ${rdPriorSrsForDlBm}=0
@{PARAMS_IN_SWCONFIG_AP}    0x70690=1
#70690: AP enable 1086 and 8247
#rdSrsCodebookAndTas : 0: FALSE[default], 1: TRUE;To control whether 'antennaSwitching' SRS can overlap with codebook SRS or not
#rdPriorSrsForDlBm: 0: TAS[default], 1: codebook;To control which kind of periodic SRS has higher priority for DL SRS based beamforming

#BAND78: t1r4-t2r4 maxNumberSRS-Ports-PerResource=n2
${ue_nr_cap_SA_UE1}  SEPARATOR=
...    6180000004608580300002300000A000009A0000410200385000000000E268000011D00001602013008C3C088000A0705006020090018078
...    000000000000D1508A0452027004100000012010400004048040302A42AA02902700400200400800400802


# Num of E-CID MEASUREMENT INITIATION REQUEST msgs sent over F1 Interface
${F1_ECID_MEASINIT_REQ}    M55113C00013

# Num of E-CID MEASUREMENT INITIATION RESPONSE msgs received over F1 interface
${F1_ECID_MEASINIT_RESP}    M55113C00014

# Num of E-CID MEASUREMENT INITIATION FAILURE msgs received over F1 interface due to protocol error
${F1_ECID_MEASINIT_FAIL_PRERR}    M55113C00015

# Num of TimerF1UeProcGuard timeouts in gNB-CU due to no response to E-CID MEASUREMENT INITIATION REQUEST msg from gND-DU over F1 interface
${F1_ECID_MEASINIT_TIMEOUT}    M55113C00018

# Num of E-CID MEASUREMENT INITIATION FAILURE msgs with cause "RNL: Measurement Temporarily not Available" received over F1 interface
${F1_ECID_MEASINIT_FAIL_TMPUNAV}    M55113C00016

# Num of E-CID MEASUREMENT INITIATION FAILURE msgs with cause "RNL: Measurement not Supported For The Object" received over F1 interface
${F1_ECID_MEASINIT_FAIL_NO_SUPP}    M55113C00017

#Num of UL UE-associated NRPPA transport messages with E-CID measurement initiation response for Reporting Type "On-Demand" per NR cell
${NRPPA_MEASINIT_RESP_D}    M55125C00025

# Num of DL UE-associated NRPPA transport messages with E-CID measurement initiation requests for Reporting Type "On-Demand" per NR cell
${NRPPA_MEASINIT_REQ_D}    M55125C00024


@{PM_Counters_B005}
...    NRCELL-1:${F1_ECID_MEASINIT_REQ}=${4*${LOOP}}
...    NRCELL-1:${F1_ECID_MEASINIT_RESP}=${4*${LOOP}}
...    NRCELL-1:${NRPPA_MEASINIT_RESP_D}=${4*${LOOP}}
...    NRCELL-1:${NRPPA_MEASINIT_REQ_D}=${4*${LOOP}}
...    NRCELL-2:${F1_ECID_MEASINIT_REQ}=0
...    NRCELL-2:${F1_ECID_MEASINIT_RESP}=0
...    NRCELL-2:${NRPPA_MEASINIT_RESP_D}=0
...    NRCELL-2:${NRPPA_MEASINIT_REQ_D}=0
...    NRCELL-1:${F1_ECID_MEASINIT_FAIL_PRERR}=0
...    NRCELL-2:${F1_ECID_MEASINIT_FAIL_PRERR}=0
...    NRCELL-1:${F1_ECID_MEASINIT_TIMEOUT}=0
...    NRCELL-2:${F1_ECID_MEASINIT_TIMEOUT}=0
...    NRCELL-1:${F1_ECID_MEASINIT_FAIL_TMPUNAV}=0
...    NRCELL-2:${F1_ECID_MEASINIT_FAIL_TMPUNAV}=0
...    NRCELL-1:${F1_ECID_MEASINIT_FAIL_NO_SUPP}=0
...    NRCELL-2:${F1_ECID_MEASINIT_FAIL_NO_SUPP}=0


*** Test Cases ***
CB10986-ET-B005_nG-RanAccessPointPosition_online_change
    [Documentation]
    ...    1. The purpose of this test case is to check following scenarios:
    ...        Successful E-CID Measurement Reporting for ‘On-Demand’ Request. 5G_RAN_USR_RRM_24391
    ...    2. Test Case Steps:
    ...         a. SA UE1 attach to NR Cell 1.
    ...         b. LMF send E-CID MR.
    ...         c. Online update actUlNrEcIdNgRanApPosition to true.
    ...         d. LMF send E-CID MR.
    ...         e. Waiting nrEcidMeasSupervisionTimer expired.
    ...         f. LMF send E-CID MR.
    ...         g. Online update actUlNrEcIdNgRanApPosition to false.
    ...         h. LMF send E-CID MR.
    ...         j. repeat step b to step h many times.
    ...    4. Expected Results:
    ...         a. SA UE1 attach successfully.
    ...         b. LMF send E-CID MR
    ...            NRPPA/F1ap: E-CID MEASUREMENT INITIATION RESPONSE with all the mandatory IEs and angleOfArrivalNR filled
    ...            in the “E-CID-MeasurementResult” IE, but not incloud IE 'nG_RANAccessPointPosition_element'
    ...         c. Online update actUlNrEcIdNgRanApPosition to true, no PDL error.
    ...         d. LMF send E-CID MR.
    ...            NRPPA/F1ap: E-CID MEASUREMENT INITIATION RESPONSE with all the mandatory IEs and angleOfArrivalNR filled
    ...            in the “E-CID-MeasurementResult” IE, and incloud IE 'nG_RANAccessPointPosition_element'
    ...         e. Waiting nrEcidMeasSupervisionTimer expired.
    ...         f. LMF send E-CID MR.
    ...            NRPPA/F1ap: E-CID MEASUREMENT INITIATION RESPONSE with all the mandatory IEs and angleOfArrivalNR filled
    ...            in the “E-CID-MeasurementResult” IE, and still incloud IE 'nG_RANAccessPointPosition_element'
    ...         g. Online update actUlNrEcIdNgRanApPosition to false.
    ...         h. LMF send E-CID MR.
    ...            NRPPA/F1ap: E-CID MEASUREMENT INITIATION RESPONSE with all the mandatory IEs and angleOfArrivalNR filled
    ...            in the “E-CID-MeasurementResult” IE, but not incloud IE 'nG_RANAccessPointPosition_element'
    [Tags]    QC_349043    B005
    Clear Counter Files
    SA UE attach    ue_id=1
    Send litter traffic to keep UE alive
    Set UL MIMO SRS BEAM POS
    LOOP Five times from CB010986 disable to enable
    Release ues    ue_type=all
    Check WireShark Log    ${CURDIR}${/}A2A_B005${/}a2a.ini    wait_string=UEContextReleaseComplete::4
    Check Counters    ${PM_Counters_B005}

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Install eNB Package via WEBEM
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri    ue_count=2

LOOP Five times from CB010986 disable to enable
    FOR    ${index}    IN RANGE    0    ${LOOP}
        LMF sends E-CID MR
        Enable CB010986
        LMF sends E-CID MR
        sleep    4s    wating the nrEcidMeasSupervisionTimer expired
        LMF sends E-CID MR
        Disable CB010986
        LMF sends E-CID MR
        Execute Egate Command     bearer_stats ue=1 pdu=1 qfi=1 dir=dl
        Execute Egate Command     bearer_stats ue=1 pdu=1 qfi=1 dir=ul
    END

Send litter traffic to keep UE alive
    Execute Egate Command    trf_data_start ue=1 pdu=1 qfi=1 dir=ul mbps=1 trf_id=1    UE 1: UDP UL
    Execute Egate Command    trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=5 trf_id=1    UE 1: UDP DL

Install eNB Package via WEBEM
    [Arguments]    ${bsr_name}=BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001.zip    ${bsr_path}=/home/ute/bsr_package
    Execute Cmd On Pc    rm -rf ${bsr_path}
    Execute Cmd On Pc    mkdir ${bsr_path}
    Execute Cmd On Pc    git clone https://wrgitlab.ext.net.nokia.com/y165zhan/bsr_package ${bsr_path}
    update_software    sw_package=${bsr_path}/${bsr_name}    timeout=60

SA UE attach
    [Arguments]    ${ue_id}=1    ${cell_id}=1    ${pdu_id}=1
    Execute Egate Command    ue_change_location id=${ue_id} cell=${cell_id} enb=2
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Registered state.
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup pdu=${pdu_id} gw=${pdu_id} ue=${ue_id} nwslice=1    Initial Context Setup Successful

Enable CB010986
    Delta Commission Parameters    ${ENABLE_CB10986B}
    Cells Should Be OnAir

Disable CB010986
    Delta Commission Parameters    ${DISABLE_CB10986B}
    Cells Should Be OnAir

Set UL MIMO SRS BEAM POS
    [Arguments]    ${ue_id}=1
    ${cmd}    catenate
    ...    ul_mimo_srs_beam_pos_nr profile_id=1 mode=fixed init_quad_pos=1 init_sub_quad_pos=1 test_type=SRS
    ...    multi_path_config=1 num_of_nlos_paths=1 azimuth=30 zenith=0 srs_transmit_power_per_port=-400,-400,-500,-500
    Execute Egate Command     ${cmd}
    Execute Egate Command     ue_testmode_set_nr id=${ue_id} testmode=ul_mimo_srs_beam_pos action=activate profile_id=1

LMF sends E-CID MR
    [Arguments]    ${ue_id}=1
    ${cmd}    catenate
    ...    lmf_send_ecid_meas_req id=1 ue=${ue_id} nrppa_transaction_id=1 lmf_ue_measurement_id=1
    ...    report_characteristics=OnDemand meas_qty=NR_Angle_of_Arrival,Cell-ID
    Execute Egate Command    ${cmd}    Received ECID Measurement Response with NRPPATransactionID

Check Logs
    [Arguments]    ${case}=B005
    Check RRC log    ${CURDIR}${/}a2a_${case}${/}a2a.ini

Modify Cfg
    Update Cfg    set_lmf id=1 daemon=$SERVER_IP:$DAEMON_PORT nfId=abcdef01234567gh
        Update Cfg    ue_param id=1 ue_nr_capabilities=${ue_nr_cap_SA_UE1}

Trigger HO
    [Arguments]    ${ue_id}=1    ${source_cell_id}=50    ${target_cell_id}=51    ${a2_measid}=3
    ...    ${a3_measid}=5    ${measgap}=False
    Start RRC Log    UE${ue_id}_HO_cell${source_cell_id}_to_cell${target_cell_id}
    ${cmd}=    Set Variable
    ...    ue_enb_param id=${ue_id} measurement_gap=gp0:0 mgta=ms0 gap_purpose=perUE gap_trigger=gnb_triggered
    Run Keyword if     ${measgap}==True    Execute Egate Command    ${cmd}
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${a2_measid} event=A2 srsrp_nr=11 srsrq_nr=11
    ...    Successfully reconfigured dual connectivity
    ${cmd1}=    Set Variable    ue_measurement_send_nr id=${ue_id} meas_id=${a3_measid} event=A3 srsrp_nr=11 srsrq_nr=11
    ${cmd2}=    Set Variable    phycell_id=${target_cell_id} nrsrp_nr=50 nrsrq_nr=50
    ${cmd_HO}=    Catenate    ${cmd1}    ${cmd2}
    Execute Egate Command    ${cmd_HO}    Successfully reconfigured dual connectivity
    Get RRC Log

    Execute Egate Command    ${cmd_HO}    Successfully reconfigured dual connectivity
    Get RRC Log
