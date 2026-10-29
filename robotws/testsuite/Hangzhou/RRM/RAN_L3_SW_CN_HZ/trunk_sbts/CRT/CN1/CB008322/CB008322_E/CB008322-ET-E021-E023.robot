*** Settings ***
Documentation
...    author: Yan Susana
...    contact: susana.yan@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_VRF    SBTS00    RAN_5G    RAN_5G_TDD    CRT    CLOUD_5G_I_BOO_AP_LOO
...    team-CN1ET    owner-jun.15.zhang    release-5G24R2     CB008322
Resource    ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{enableBeamforming}
...    @{srsConfig}
...    @{CB008322}
...    @{PARAMS_FOR_VoNR}
...    @{1070_Frame_Structure}
...    @{1070_bwp}
...    @{1116_0ms_bwp}
...    @{1116_0_Frame_Structure}
...    @{FDD_CELL11_Config}
...    @{CA_Config}
...    @{FDD_CELL_bwp}

@{PARAMS_IN_IPHY_XML}
...    vcell:phy_cell_id=52|cell=2.1
...    vcell:dlFeatures=pmiBeams|cell=2.1
...    vcell:phy_cell_id=53|cell=2.2
...    vcell:dlFeatures=pmiBeams|cell=2.2

@{enableBeamforming}
...    NRCELL-1:beamSet:basicBeamSet=beamSet_6
...    NRCELL-1:dlMimoMode=8x4 Closed Loop Spatial Multiplexing
...    NRCELL-1:nrCellType=8DL4UL
...    NRCELL-1:beamSet:lowerEdgeAngle=120
...    NRCELL-1:beamSet:upperEdgeAngle=60
...    NRCELLGRP-0:numberOfTransmittedSsBlocks=6 beams
...    NRCELLGRP-1:numberOfTransmittedSsBlocks=6 beams
...    NRCELL-1:periodicCsiAcquisition:csirsPower=3
...    NRCELL-1:periodicCsiAcquisition:csirsNumberWithinReportPeriod_Set1=1
...    NRCELL-1:periodicCsiAcquisition:maxCsirsNumber=2
...    NRCELL-1:chBw=80MHz
...    NRCELL-2:chBw=80MHz
...    NRCELL-1:physCellId=52
...    NRCELL-2:physCellId=53
...    NRCELL-2:beamSet:basicBeamSet=beamSet_6
...    NRCELL-2:dlMimoMode=8x4 Closed Loop Spatial Multiplexing
...    NRCELL-2:nrCellType=8DL4UL
...    NRCELL-2:beamSet:lowerEdgeAngle=120
...    NRCELL-2:beamSet:upperEdgeAngle=60
...    NRCELL-2:periodicCsiAcquisition:csirsPower=3
...    NRCELL-2:periodicCsiAcquisition:csirsNumberWithinReportPeriod_Set1=1
...    NRCELL-2:periodicCsiAcquisition:maxCsirsNumber=2

@{srsConfig}
...    NRPMRNL-1:miNrNgcFlexInterface=disabled
...    NRPMRNL-1:miNrIntraGnbMobilitySaPmqap=disabled
...    NRPMRNL-1:miNrIntraGnbMobilityNsaPmqap=disabled
...    NRPMRNL-1:miNrInterGnbXnMobilitySaPmqap=disabled
...    NRPMRNL-1:miNrInterGnbNgMobilitySaPmqap=disabled
...    NRPMRNL-1:miNrInterGnbMobilityNsaPmqap=disabled
...    NRCELL-1:actUlSrsBm=true
...    NRCELL-1:actDlSrsBm=true
...    NRCELL-1:srsForBeamMgmt:srsTypeAllocForDlBm=antenna switching or codebook
...    NRCELL-1:srsForBeamMgmt:comb=comb4
...    NRCELL-1:srsForBeamMgmt:srsUePeriodicity=slots20
...    NRCELL-1:srsForBeamMgmt:cSRS=49
...    NRCELL-1:srsForBeamMgmt:bSRS=2
...    NRCELL-1:srsForBeamMgmt:srsPowerThresholdForDlBm=-1280
...    NRCELL-1:srsForBeamMgmt:srsPowerThresholdForUlBm=-1200
...    NRCELL-2:actUlSrsBm=true
...    NRCELL-2:actDlSrsBm=true
...    NRCELL-2:srsForBeamMgmt:srsTypeAllocForDlBm=antenna switching or codebook
...    NRCELL-2:srsForBeamMgmt:comb=comb2
...    NRCELL-2:srsForBeamMgmt:srsUePeriodicity=slots80
...    NRCELL-2:srsForBeamMgmt:cSRS=49
...    NRCELL-2:srsForBeamMgmt:bSRS=2
...    NRCELL-2:srsForBeamMgmt:srsPowerThresholdForDlBm=-1280
...    NRCELL-2:srsForBeamMgmt:srsPowerThresholdForUlBm=-1200

@{1070_Frame_Structure}
...    NRCELL-1:tddFrameStructure:frameStructureType=semiStatic
...    NRCELL-1:tddFrameStructure:ulDlDataSlotRatio=3/7
...    NRCELL-1:tddFrameStructure:guardPeriodLength=2Symbols
...    delete:NRCELL-1:tddFrameStructure:lteToNrFrameShift
...    delete:NRCELL-1:tddFrameStructure:tdLteUlDlConfig
...    NRCELL-1:prachConfigurationIndex=98
...    NRCELL-1:type0SearchSpaceConfigurationIndex=5

@{1070_bwp}
...    NRCELL-1:cellBwpList:bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-7|cellBwpId=0
...    NRCELL-1:cellBwpList:bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-77|cellBwpId=1

@{1116_0_Frame_Structure}
...    NRCELL-2:tddFrameStructure:frameStructureType=tdLte
...    NRCELL-2:tddFrameStructure:guardPeriodLength=4Symbols
...    NRCELL-2:tddFrameStructure:lteToNrFrameShift=0ms
...    NRCELL-2:tddFrameStructure:tdLteUlDlConfig=tdLteConfig2
...    NRCELL-2:tddFrameStructure:ulDlDataSlotRatio=1/9
...    NRCELL-2:prachConfigurationIndex=97
...    NRCELL-2:type0SearchSpaceConfigurationIndex=5

@{1116_0ms_bwp}
...    NRBTS/BWP_PROFILE-6:bwpType=initial
...    NRBTS/BWP_PROFILE-6:locationAndBandwidthDl:cRbSizeDl=coreset0
...    NRBTS/BWP_PROFILE-6:locationAndBandwidthDl:cRbStartDl=coreset0
...    NRBTS/BWP_PROFILE-6:locationAndBandwidthUl:cRbSizeUl=sameAsDl
...    NRBTS/BWP_PROFILE-6:locationAndBandwidthUl:cRbStartUl=sameAsDl
...    NRBTS/BWP_PROFILE-6/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-6/PDCCH-1:dciDedicatedAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-6/PDCCH-1:dciPagingAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-6/PDCCH-1:dciRaCompletionAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-6/PDCCH-1:dciRaMsg2AggregationLevel=AL4
...    NRBTS/BWP_PROFILE-6/PDCCH-1:dciSiAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-6/PDCCH-1:downgradeAL16toAL8=notAllowed
...    delete: NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1/coresetCommon
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=9|searchSpaceId=1
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=1
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|searchSpaceId=1
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=1
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=4|searchSpaceId=1
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=2
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=9|searchSpaceId=3
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=3
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|searchSpaceId=3
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=3
...    NRBTS/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=4|searchSpaceId=3
...    NRBTS/BWP_PROFILE-67:bwpType=dedicated
...    NRBTS/BWP_PROFILE-67:locationAndBandwidthDl:cRbSizeDl=allRb
...    NRBTS/BWP_PROFILE-67:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-67:locationAndBandwidthUl:cRbSizeUl=sameAsDl
...    NRBTS/BWP_PROFILE-67:locationAndBandwidthUl:cRbStartUl=sameAsDl
...    NRBTS/BWP_PROFILE-67/PDSCH-1:pdschId=1
...    NRBTS/BWP_PROFILE-67/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-67/PDCCH-1:dciDedicatedAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-67/PDCCH-1:dciPagingAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-67/PDCCH-1:dciRaCompletionAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-67/PDCCH-1:dciRaMsg2AggregationLevel=AL4
...    NRBTS/BWP_PROFILE-67/PDCCH-1:dciSiAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-67/PDCCH-1:downgradeAL16toAL8=notAllowed
...    delete: NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_COMMON-1/coresetCommon
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=9|searchSpaceId=4
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=4
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|searchSpaceId=4
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=4
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=4|searchSpaceId=4
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=5
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=9|searchSpaceId=6
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=6
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|searchSpaceId=6
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=6
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=4|searchSpaceId=6
...    delete: NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_DEDICATED-1/coresetCommon
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cceToRegMapping=nonInterleaved
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:coresetId=1
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cRbStart=0
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:duration=1
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:interleaverSize=none
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:regBundleSize=n6
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=120
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-0-And-1-0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|searchSpaceId=7
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=7
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|searchSpaceId=7
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|searchSpaceId=7
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|searchSpaceId=7
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=1|searchSpaceId=8
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|searchSpaceId=8
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|searchSpaceId=8
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=8
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|searchSpaceId=8
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceId=8
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|searchSpaceId=8
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n5|searchSpaceId=8
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceId=8
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|searchSpaceId=8
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|searchSpaceId=8
...    NRBTS/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|searchSpaceId=8
...    NRCELL-2:cellBwpList:bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-6|cellBwpId=0
...    NRCELL-2:cellBwpList:bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-67|cellBwpId=1

@{FDD_CELL_bwp}
...    NRBTS/BWP_PROFILE-4:bwpType=initial
...    NRBTS/BWP_PROFILE-4:locationAndBandwidthDl:cRbSizeDl=coreset0
...    NRBTS/BWP_PROFILE-4:locationAndBandwidthDl:cRbStartDl=coreset0
...    NRBTS/BWP_PROFILE-4:locationAndBandwidthUl:cRbSizeUl=allRb
...    NRBTS/BWP_PROFILE-4:locationAndBandwidthUl:cRbStartUl=crb0
...    NRBTS/BWP_PROFILE-4/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-4/PDCCH-1:dciDedicatedAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-4/PDCCH-1:dciPagingAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-4/PDCCH-1:dciRaCompletionAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-4/PDCCH-1:dciRaMsg2AggregationLevel=AL4
...    NRBTS/BWP_PROFILE-4/PDCCH-1:dciSiAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-4/PDCCH-1:downgradeAL16toAL8=notAllowed
...    delete: NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1/coresetCommon
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=1
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=1
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=1
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=1
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n4|searchSpaceId=2
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=3
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=3
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=3
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=3
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-31:bwpType=dedicated
...    NRBTS/BWP_PROFILE-31:locationAndBandwidthDl:cRbSizeDl=allRb
...    NRBTS/BWP_PROFILE-31:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-31:locationAndBandwidthUl:cRbSizeUl=sameAsDl
...    NRBTS/BWP_PROFILE-31:locationAndBandwidthUl:cRbStartUl=sameAsDl
...    NRBTS/BWP_PROFILE-31/PDSCH-1:pdschId=1
...    NRBTS/BWP_PROFILE-31/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-31/PDCCH-1:dciDedicatedAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-31/PDCCH-1:dciPagingAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-31/PDCCH-1:dciRaCompletionAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-31/PDCCH-1:dciRaMsg2AggregationLevel=AL4
...    NRBTS/BWP_PROFILE-31/PDCCH-1:dciSiAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-31/PDCCH-1:downgradeAL16toAL8=notAllowed
...    delete: NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_COMMON-1/coresetCommon
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=4
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=4
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=4
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=4
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n4|searchSpaceId=5
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=6
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=6
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=6
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=6
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=6
...    delete: NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_DEDICATED-1/coresetCommon
...    delete: NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_DEDICATED-1/coresetDedicated
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-0-And-1-0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|searchSpaceId=7
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=7
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|searchSpaceId=7
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|searchSpaceId=7
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|searchSpaceId=7
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=0|searchSpaceId=8
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|searchSpaceId=8
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|searchSpaceId=8
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=8
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|searchSpaceId=8
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceId=8
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|searchSpaceId=8
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|searchSpaceId=8
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceId=8
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|searchSpaceId=8
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|searchSpaceId=8
...    NRBTS/BWP_PROFILE-31/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|searchSpaceId=8
...    NRCELL-11:cellBwpList:bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-4|cellBwpId=0
...    NRCELL-11:cellBwpList:bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-31|cellBwpId=1

@{CB008322}
...    NRBTS:actCoverageNonCoherentUes=false
...    NRBTS:actFdmScheduling=true
...    NRDU-1:actInterNumerologyCa=true
...    NRCELLGRP:ssBurstSetPeriod=20
...    NRCELL-1:pucchModeSelect=longPucch
...    NRCELL-1:cellDepType=SA+NSA
...    NRCELL-1:beamSet:nrBtsBeamRefinementP2=true
...    NRCELL-1:actDl256Qam=true
...    NRCELL-1:ulMimoMode=Closed loop Spatial Multiplexing (2x2)
...    NRCELL-1:actPdschAtSsbSlots=false
...    NRCELL-1:numberOfRxBeamforming=4Rx
...    NRCELL-1:actBeamforming=true
...    NRCELL-1:mMimoAntArrayMode=Full 64TRX Array (4x8x2)
...    NRCELL-1:actCsirsMultiplexing=true
...    NRCELL-1:actUeCsirsCoexistCellCsirs=true
...    NRCELL-1:actDlSrsSubbandBm=true
...    NRCELL-1:srsForSubbandBm:bfSubbandSize=16 PRBs
...    NRCELL-1:srsForSubbandBm:maxNumUeSrs=4
...    NRCELL-1:srsForSubbandBm:srsPowerThreshold=-1350
...    NRCELL-1:srsForSubbandBm:srsUePeriodicityInput=slots40
...    NRCELL-1:srsForSubbandBm:srsSinrThreshold=-400
...    NRCELL-1:actDlMuMimoEnh=false
...    NRCELL-2:pucchModeSelect=longPucch
...    NRCELL-2:cellDepType=SA+NSA
...    NRCELL-2:beamSet:nrBtsBeamRefinementP2=true
...    NRCELL-2:actDl256Qam=true
...    NRCELL-2:ulMimoMode=Closed loop Spatial Multiplexing (2x2)
...    NRCELL-2:actPdschAtSsbSlots=false
...    NRCELL-2:numberOfRxBeamforming=4Rx
...    NRCELL-2:actBeamforming=true
...    NRCELL-2:mMimoAntArrayMode=Full 64TRX Array (4x8x2)
...    NRCELL-2:actCsirsMultiplexing=true
...    NRCELL-2:actUeCsirsCoexistCellCsirs=true
...    NRCELL-2:actDlSrsSubbandBm=true
...    NRCELL-2:srsForSubbandBm:bfSubbandSize=16 PRBs
...    NRCELL-2:srsForSubbandBm:maxNumUeSrs=4
...    NRCELL-2:srsForSubbandBm:srsPowerThreshold=-1350
...    NRCELL-2:srsForSubbandBm:srsUePeriodicityInput=slots80
...    NRCELL-2:srsForSubbandBm:srsSinrThreshold=-400
...    NRCELL-2:actDlMuMimoEnh=false
...    NRCELL-1:wbSbSrsSwitch:channelStabilityHysteresis=100
...    NRCELL-1:wbSbSrsSwitch:channelStabilityThreshold=30
...    NRCELL-1:wbSbSrsSwitch:enableSbSrsVolatilityCheck=false
...    NRCELL-1:wbSbSrsSwitch:maxWbSbSwitch=10
...    NRCELL-1:wbSbSrsSwitch:numWbSrsConfigSample=10
...    NRCELL-1:wbSbSrsSwitch:numWbSrsReleaseSample=10
...    NRCELL-1:wbSbSrsSwitch:prbRatioHysteresis=15
...    NRCELL-1:wbSbSrsSwitch:prbRatioThreshold=1
...    NRCELL-1:wbSbSrsSwitch:prbSampleHighLowPercentage=60
...    NRCELL-1:wbSbSrsSwitch:rankHysteresis=4
...    NRCELL-1:wbSbSrsSwitch:rankThreshold=1
...    NRCELL-1:wbSbSrsSwitch:rlqBadPercentage=50
...    NRCELL-1:wbSbSrsSwitch:rlqGoodPercentage=20
...    NRCELL-1:wbSbSrsSwitch:seHysteresis=100
...    NRCELL-1:wbSbSrsSwitch:seThreshold=1
...    NRCELL-1:wbSbSrsSwitch:sortingMetric=DL Spectral Efficiency
...    NRCELL-1:wbSbSrsSwitch:wbSrsConfigProhibitTimer=100
...    NRCELL-1:wbSbSrsSwitch:wbSrsPowerHysteresis=100
...    NRCELL-1:wbSbSrsSwitch:wbSrsPowerThreshold=-1160
...    NRCELL-1:wbSbSrsSwitch:wbSrsReleaseProhibitTimer=1000
...    NRCELL-2:wbSbSrsSwitch:channelStabilityHysteresis=100
...    NRCELL-2:wbSbSrsSwitch:channelStabilityThreshold=30
...    NRCELL-2:wbSbSrsSwitch:enableSbSrsVolatilityCheck=false
...    NRCELL-2:wbSbSrsSwitch:maxWbSbSwitch=10
...    NRCELL-2:wbSbSrsSwitch:numWbSrsConfigSample=10
...    NRCELL-2:wbSbSrsSwitch:numWbSrsReleaseSample=10
...    NRCELL-2:wbSbSrsSwitch:prbRatioHysteresis=15
...    NRCELL-2:wbSbSrsSwitch:prbRatioThreshold=1
...    NRCELL-2:wbSbSrsSwitch:prbSampleHighLowPercentage=60
...    NRCELL-2:wbSbSrsSwitch:rankHysteresis=4
...    NRCELL-2:wbSbSrsSwitch:rankThreshold=1
...    NRCELL-2:wbSbSrsSwitch:rlqBadPercentage=50
...    NRCELL-2:wbSbSrsSwitch:rlqGoodPercentage=20
...    NRCELL-2:wbSbSrsSwitch:seHysteresis=100
...    NRCELL-2:wbSbSrsSwitch:seThreshold=1
...    NRCELL-2:wbSbSrsSwitch:sortingMetric=DL Spectral Efficiency
...    NRCELL-2:wbSbSrsSwitch:wbSrsConfigProhibitTimer=100
...    NRCELL-2:wbSbSrsSwitch:wbSrsPowerHysteresis=100
...    NRCELL-2:wbSbSrsSwitch:wbSrsPowerThreshold=-1160
...    NRCELL-2:wbSbSrsSwitch:wbSrsReleaseProhibitTimer=1000

@{PARAMS_FOR_VoNR}
...    NRBTS:actNormVCFallback=false
...    NRDRX-4:drxInactivityTimer=40ms
...    NRDRX-4:drxLongCycle=80ms
...    NRDRX-4:drxOnDurationTimer=6ms
...    NRDRX-4:drxRetransTimerDl=16slot
...    NRDRX-4:drxRetransTimerUl=16slot
...    NRDRX-1:drxLongCycle=40ms
...    NRCELL-1:nonGbrNrDrxDN=MRBTS-1/NRBTS-1/NRDRX-4
...    NRCELL-2:nonGbrNrDrxDN=MRBTS-1/NRBTS-1/NRDRX-4
...    NRBTS:actFdmEnhancedScheduling=true
...    NRBTS-1/NRSYSINFO_PROFILE-1:systemInformationTargetRate=0
...    MRBTS-1/MNL-1/MNLENT-1/SYNC-1:actEcpriMasterClock=true
...    NRCELL-1:actVoNR=true
...    NRCELL-1:actCDrx=true
...    NRCELL-1:actCDrxVoNR=false
...    NRCELL-1:measGapSelectionSA=favourUeThroughput
...    NRCELL-1:actUlClosedLoopPwrCtrl=pucchPuschSrs
...    NRCELL:nrUlClpcProfileDN=NRULCLPC_PROFILE-1
...    NRULCLPC_PROFILE-1:nrUlClpcProfileId=1
...    NRCELL-1:actEnhancedVoNR=true
...    NRCELL-1:actAdaptVoipTbs=true
...    NRCELL-1:srPeriodicity=slots40
...    NRCELL-1:periodicCsiAcquisition:csiReportPeriodicity=slots160
...    NRCELL-1:actVoipPacketAggr=true
...    NRCELL-2:actVoNR=true
...    NRCELL-2:actCDrx=true
...    NRCELL-2:actCDrxVoNR=false
...    NRCELL-2:measGapSelectionSA=favourUeThroughput
...    NRCELL-2:actUlClosedLoopPwrCtrl=pucchPuschSrs
...    NRCELL-2:actEnhancedVoNR=true
...    NRCELL-2:actAdaptVoipTbs=true
...    NRCELL-2:srPeriodicity=slots40
...    NRCELL-2:actVoipPacketAggr=true
...    @{PARAMS_FOR_5QI5}
...    @{PARAMS_FOR_5QI1}

@{FDD_CELL11_Config}
...    NRCELL-11:actCDrx=true
...    NRCELL-11:drxWactUlEnabled=false
...    NRCELL-11:drxWactDlEnabled=false
...    NRCELL-11:actUlSrsBm=false
...    NRCELL-11:actDlSrsBm=false
...    NRCELL-11:actDlSrsSubbandBm=false
...    NRCELL-11:dlMimoMode=2x2 Closed Loop Spatial Multiplexing
...    NRCELL-11:nrCellType=2DL2UL
...    NRCELL-11:prachConfigurationIndex=39
...    NRCELL-11/NRCELL_FDD-1:chBwDl=10MHz
...    NRCELL-11/NRCELL_FDD-1:chBwUl=10MHz

@{CA_Config}
...    NRBTS:actCarrierAggregation=true
...    NRBTS:caConfigurationSupport=4CCDL_2CCUL
...    NRBTS:sCellActivationMethod=blind
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRCELL:actK1Opt=intraAndInter-gNB
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:carrierAggregationSupportList=ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Any_Sa,ca_Fdd_Any_Sa,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Fdd
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-1:gNbId=1
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-1:lcrId=2
...    NRCELL-1/NRREL-1:removeNotAllowed=false
...    NRCELL-1/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-1:sCellPrio=1
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-2:gNbId=1
...    NRCELL-1/NRREL-2:gNbIdLength=22
...    NRCELL-1/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-2:lcrId=11
...    NRCELL-1/NRREL-2:removeNotAllowed=false
...    NRCELL-1/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-2:sCellPrio=1
...    NRCELL-1/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-1:gNbId=1
...    NRCELL-2/NRREL-1:gNbIdLength=22
...    NRCELL-2/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-1:lcrId=1
...    NRCELL-2/NRREL-1:removeNotAllowed=false
...    NRCELL-2/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-2/NRREL-1:sCellPrio=1
...    NRCELL-2/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-2:gNbId=1
...    NRCELL-2/NRREL-2:gNbIdLength=22
...    NRCELL-2/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-2:lcrId=11
...    NRCELL-2/NRREL-2:removeNotAllowed=false
...    NRCELL-2/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-2/NRREL-2:sCellPrio=1
...    NRCELL-2/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL:a1MeasSCellAddEnabled=rsrp
...    NRCELL:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=31
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=111
...    NRCELL:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-1:a2MeasSCellRelEnabled=rsrp
...    NRCELL-1:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=2
...    NRCELL-1:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=34
...    NRCELL-1:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-2:a2MeasSCellRelEnabled=rsrp
...    NRCELL-2:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=2
...    NRCELL-2:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=34
...    NRCELL-2:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-11:a2MeasSCellRelEnabled=rsrp
...    NRCELL-11:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=2
...    NRCELL-11:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=34
...    NRCELL-11:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-11:filterCoeffSsbRsrp=fc4
...    NRCELL-11:filterCoeffSsbRsrq=fc4

@{PARAMS_FOR_5QI5}
...    NRBTS/NRDRB_5QI-1:fiveqiValueList=5
...    NRBTS/NRDRB_5QI-1:nrDrbDN=NRDRB-10
...    NRBTS/NRDRB-10:nrDrbMacDN=NRDRB_MAC-4
...    NRBTS/NRDRB-10:nrDrbPdcpDN=NRDRB_PDCP-2
...    NRBTS/NRDRB-10:nrDrbRlcAmDN=NRDRB_RLC_AM-2
...    NRBTS/NRDRB-10:cellAggrLevel=FR1 CA eligible
...    NRBTS/NRDRB-10:resType=nonGBR_Signaling
...    NRBTS/NRDRB-10:rlcMode=RLC_AM
...    NRBTS/NRDRB_MAC-4:lcgid=0
...    NRBTS/NRDRB_MAC-4:schedulPrio=4
...    NRBTS/NRDRB_PDCP-2:tReorderingDl=ms100
...    NRBTS/NRDRB_PDCP-2:tReorderingUl=ms100
...    NRBTS/NRDRB_RLC_AM-2:ulMaxRetxThreshold=t16

@{PARAMS_FOR_5QI1}
...    NRBTS/NRDRB_5QI-6:fiveqiValueList=1
...    NRBTS/NRDRB_5QI-6:nrDrbDN=NRDRB-15
...    NRBTS/NRDRB-15:nrDrbMacDN=NRDRB_MAC-3
...    NRBTS/NRDRB-15:nrDrbPdcpDN=NRDRB_PDCP-2
...    NRBTS/NRDRB-15:nrDrbRlcUmDN=NRDRB_RLC_UM-1
...    NRBTS/NRDRB-15:dlFlowControlAlgo=none
...    NRBTS/NRDRB-15:dscp=0
...    NRBTS/NRDRB-15:maxDddsPeriodCpuOvld=40
...    NRBTS/NRDRB-15:numSduDiscard=1
...    NRBTS/NRDRB-15:queuingDelayDiscarding=Disabled
...    NRBTS/NRDRB-15:queuingDelaySduDiscardThreshold=200
...    NRBTS/NRDRB-15:cellAggrLevel=Not FR1 CA eligible
...    NRBTS/NRDRB-15:resType=GBR
...    NRBTS/NRDRB-15:discardTimer=10ms
...    NRBTS/NRDRB-15:maxTransferDelayGbr=20
...    NRBTS/NRDRB-15:maxRlcQueueingDelayGbr=20
...    NRBTS/NRDRB-15:rlcMode=RLC_UM
...    NRBTS/NRDRB-15:schedulWeight=1
...    NRBTS/NRDRB-15:sduDiscardIntervalTmr=100
...    NRBTS/NRDRB-15:maxDataRateGbrDl=1000
...    NRBTS/NRDRB-15:maxDataRateGbrUl=1000
...    NRBTS/NRDRB_MAC-3:lcgid=4
...    NRBTS/NRDRB_MAC-3:schedulPrio=5
...    NRBTS/NRDRB_PDCP-2:pdcpBufDiscardEnabled=false
...    NRBTS/NRDRB_RLC_UM-1:dlTReassemblyUm=ms40
...    NRBTS/NRDRB_RLC_UM-1:ulTReassemblyUm=ms40

@{actCsirsMultiplexing_Dis}
...    NRCELL-2:actCsirsMultiplexing=false
...    NRDRX-4:drxInactivityTimer=20ms
...    NRDRX-4:drxLongCycle=40ms
...    NRDRX-4:drxOnDurationTimer=30ms
...    NRDRX-4:drxRetransTimerDl=16slot
...    NRDRX-4:drxRetransTimerUl=16slot

@{NSA_UE11_to_13_detached}
...    UE11: detached
...    UE12: detached
...    UE13: detached

@{NSA_UE15_16_17_detached}
...    UE15: detached
...    UE16: detached
...    UE17: detached

@{NSA_UE18_detached}
...    UE18: detached

${rdSrsCodebookAndTas}    0x590103
${rdSubBandSectorNumber}    0x5901DC
${rdSrsAllocMethod}    0x5901B6
${rdMaxSrsResPerSpecialSym1208}    0x5901EC
${rdMaxSrsResPerSpecialSym1070}    0x5901ED
${rdMaxSrsResPerSpecialSym1116}    0x5901EE
${rdMaxSrsResPerSym1208}    0x5900FD
${rdMaxSrsResPerSym1070}    0x590127
${rdMaxSrsResPerSym1116}    0x590128
${rdSubbandBfMethod}    0x5901BD
${rdEnableSrsSwitchScheduler}    0x5805ae
${rdNumSrsCheck}    0x5805b5
${rdfakedrx}    0x5901EA
${rdNumberOfUeCsirsSymbol}    0x580265
${rdCsiRsReconfigCellToUE}    0x590179
${rdPdcchApplyToSeparateStream}    0x580717

@{PARAMS_IN_SWCONFIG}
...    ${rdSrsCodebookAndTas}=1
...    ${rdSubBandSectorNumber}=3
...    ${rdSrsAllocMethod}=0
...    ${rdMaxSrsResPerSpecialSym1208}=2
...    ${rdMaxSrsResPerSpecialSym1116}=2
...    ${rdMaxSrsResPerSpecialSym1070}=2
...    ${rdMaxSrsResPerSym1208}=5
...    ${rdMaxSrsResPerSym1116}=5
...    ${rdMaxSrsResPerSym1070}=5
...    ${rdSubbandBfMethod}=0
...    ${rdEnableSrsSwitchScheduler}=1
...    ${rdNumSrsCheck}=100
...    ${rdfakedrx}=1
...    ${rdNumberOfUeCsirsSymbol}=2
...    ${rdCsiRsReconfigCellToUE}=1
...    ${rdPdcchApplyToSeparateStream}=1

#CB009496 flag
...    0x600013=1     #9496 BOAM_RAT_ADAPT
...    0x19040F=1     #9496 BOAM_FRONTHAUL
...    0x88004b=0     #L1FH rdEnableSktMvp, 0 for 9496; 1 for SKTMVP
...    0x880031=14    #L1FH rdBwvTxOpportunities, 14 for 9496;  3 for SKTMVP
...    0x580789=1     #rdEnableNiddFor8322

${ERadParam_EnableSrsBasedBeamForming}    0x70690
#${rdPdcchApplyToSeparateStream_AP}    0x580717

@{PARAMS_IN_SWCONFIG_AP}
...    ${ERadParam_EnableSrsBasedBeamForming}=1
#...    ${rdPdcchApplyToSeparateStream_AP}=1


#SA UE1 with anr:
# 78 n2 t1r4, n7878 n2 t2r4
${ue_nr_cap_SA_UE1}    SEPARATOR=
...    F9A09000575F7A13160003C4A0002C1001018093170019C3D0B004D9061CF9863CA160704C060188E00D51B137582308682041D20F003EB65C558D0E7C471E819F604F8CC8E3C
...    873E819F604FA8E7CC31E50B0381C3C5C0017C0070005F0006480007001B280002800003A8D85181AC1184341020E907801F5B2E2AC6873E238F40CFB027C66471E439F40CFB0
...    27D473E618F28581C0E1E2E000BE0038002F8003200003800630F13400305000030E307134000000758789A00184D0001058380180510134650004A03850A16C73E1C085B1CF8
...    70A244D8E7C3000E06318FD06C003E0028101401C0C02500700060108423E13802000000010000020080000000400000802000008010000060080000400400002802001004010
...    04000030020000180100000E008000070040020000000800008004002018060080000900400005002001010040040020380E0080000B925002060185C92800030B92500606018
...    060185C928020300C030B92500C060180601806018061724A0100C0300C0300C2E49403818060180601806018061704A0000C2E494000189C928010300C4E49401018060189C1
...    2800031392500E060180601806018060189C928030300C0300C4E494000181C928070300C0300C0300C0300C0E4940181806018060704A0000C0C0100001A06F2A6B2A6B2A6F2
...    A6B036B2A6B296B266B016B012B022B236B748CA9A0682000012CA48080000CB29202000052CA48080001CB29202000092CA48080002CB292820000D2CA48080003CB29202000
...    112CA48080004CB29202000152CA48080005CB2928200818064B29282000192CA4A062954552A8BA55174AA2A82C5D2AAAA0D154A62A93455018AA051548EAABB503402F813D0
...    28140A05028140A05028140A05028140A05028140A05028140A05028140A05028140A05028140A05028140A0000C002008030404018030100600C202018030080600C10100400
...    804010021AA06000102030406074386B40

#SA UE2:
#BAND78: t1r4-t2r4 maxNumberSRS-Ports-PerResource=n2
#n71_n78: t1r4 maxNumberSRS-Ports-PerResource=n1
#n78(2A): t2r4 maxNumberSRS-Ports-PerResource=n2
${ue_nr_cap_SA_UE2_CA}    SEPARATOR=
...    E9A09000575F5A13160003C4A0002C1262E003387A16009B20C39F30C7942C0E0980C0311C04EE3603606B04610D04083A41E006D6C98AB1A1CF88E3D033EC09F1891C790E7D4
...    73E618F28581C0E1E0BFFFFF800FFF8BE000C80000E0541B11B582308682041E20F0032B64C55890E7D813E238F1891C790E7D473E618F28581C0E1E13FB000000FEC000000C8
...    0000E0551B137582308682041D20F0030B64C55110E7C471E238F40CFB027C639F30C7942C0E070F05C00FFC007003FF000640000702A0D837AC1184341020F10780195B262AC
...    4873E238F604F8C48E3C873EA39F30C7942C0E070F09FFF000007FFC00000640000702A8D899AC1184340000080780185B24CA88873E238F20C7A067D813E01CF9863CA160703
...    8782F55555553D555555432000038028B0F13400309A00000B02B17130003898001C4C000002160562E2300061300C26000082C0AC7C02000C0D8184C0309800030B02B170080
...    030040606C0008160563E0100060180C0D8184D00028585D62E01000606C0C26000182C0AC3C02000C260001C2C0AC3C02000C01000202C0AC3C1B000C0D800242C0AC3C02000
...    C03000282C0AC3C06000C0D8002C2C0AC5C02000C030181B00060581587836001C4C00001A160562E2680061340C23000382C0AC7C4C000C260180203036000F0B02B17130003
...    0040606C0020160563E2680060080C030181B0008858158789A0018460009058158F80400181B0309A0613400261617009006E003404C808D013465002020614851226C73E1C4
...    891226C73E1C4891226C73E1C68912244D8E7C38912244D8E7C38D1224489B1CF871224489B1CF870A244D8E7C3851226C73E1C28913639F0E14489B1CF870A244D8E7C389122
...    44D8E7C3851226C73E1C4850A16C73E1C68912244D8E7C38912244D8E7C38D1224489B1CF870A142D8E7C38D1224489B1CF8603A28318C6318C6318C6318C6318C63D06C003C0
...    0281C1401C0C02500700060240040603E09002000000010008000000200000C0100000200800002004000018020000100100000A008004010040100000C008000070040020000
...    0008000080040000480200000C010000140080000B004002048120080000C0339535953582958195833582B594B7833780B581B58095811583B40D04000025949410000196526
...    0400006594901000039652404000125949410000596524040001A594901000079652404000225949010000996524040002A5949010000B9652504000325949010000316524033
...    4AAAE954552A8BA5555416AA82C55068AA531549A2A80C55028AA4D5541E286802F012A05028140A05028140A05028140A05028140A0502800984040080101002004402004008
...    0801002020040088040300501002004040080118080600A020180280801002020040088040400501010014040580B18080600C02018028080600C02004008804030050100C014
...    040080108080600A02004008404030050100C014202018030080600C10100C018040300508080600A02018028804030050100C018040300508080600C02004008804020030100
...    800C040300618080100202004008080600A02018028804008010100C018040300618080100202018028080600C02018028404020030100C018602018028080600C02004008080
...    10023543E00020406080C0E1416181A2022242628303236383A3E424A4C4E5052545A5E828305A0


#NSA UE12
#BAND78: t1r4 maxNumberSRS-Ports-PerResource=n1 BAND41: t2r2 maxNumberSRS-Ports-PerResource=n1
${ue12_MRDC_cap}    SEPARATOR=
...    A11FF83BC4C0C03850001C46000000162205E260601C4D000E230000000B1102F130300E26800710400000058881789818070A00038820000002C040BC4C0C03882001C460000
...    02160205E360601C46000E208007104000010580817898180713400385000000C2C040804808D00A001C041809A26002E41E24E9513639F0E24E8513639F0E24E8913639F0E24
...    E8913639F0E24E8912639F469D1224498E7D127448931CF8300A2000080404008020100C01840001008080100402018030C0002010100C01804030060100C0184000100808010
...    040200401040002010100C01820001008080600C0

#T2R4-T2R4 PORT1
${ue13_MRDC_cap}    SEPARATOR=
...    A11FF83BC4C0C03850001C46000000162205E260601C4D000E230000000B1102F130300E26800710400000058881789818070A00038820000002C040BC4C0C03882001C460000
...    02160205E360601C46000E208007104000010580817898180713400385000000C2C040804808D00A001C041809A320005C83C49D2A26C73E1C49D1A36C73E1C49D1A36C73E1C4
...    9D1226C73E1C49D1224C73E8D3A2448931CFA24E8D1A639F060144000100808010040201803080002010100200804030061800040202018030080600C02018030800020101002
...    0080400802080004020201803040002010100C018

#ANR
${ue_nr_full_cap}  SEPARATOR=
...    F9A09000575F5A13160003C4A0002C1262E003387A16009B20C39F30C7942C0E0980C0311C03EE3614606B04610D04083A41E006D6C98AB1A1CF88E3D033EC09F1891C790E7D4
...    73E618F28581C0E1E0B801FF800E000BE000C90000E00365E0005E0000541B107582308682041E20F0032B64C55890E7D813E238F1891C790E7D473E618F28581C0E1E13FB000
...    000FEC000000C80000E0551B137582308682041D20F0030B64C55110E7C471E238F40CFB027C639F30C7942C0E070F05C00FFC007003FF0006480007001B2F0002F00002B8F88
...    DAC1184341020F941E00556C98AB0A1CF88E3C600000000000000000000000013FFE00000FFF800000C80000E007BC3C4D000E208000010B0102A0F0A000388C0000042C0AC3C
...    46000E208000030B02B0F0A00038820000042C0AC3C4D000E230000010B02B17118003882001C4100000A160561E14000713400003058158B89A001C41000E140000040B02B17
...    13400388C001C46000004160562E14000710400388C0000082C0AC5C28000E20800710400001058158B89A001C41000E230000020B02B170A000388C001C46000004160562E26
...    80071180038500000102C0AC3C46000E230000030B0200E0234028809B010465001760F851226C73E1C28913639F0E14489B1CF870A244D8E7C3851226C73E1C4891226C73E1C
...    28103639F022408103639F022408103639F022408103639F022408103639F022408103639F022408103639F022408103639F0214081B1CF8002E1E318C6318C6318C6318C3D06
...    E003E002800301C1401C0C02500700060108D001018011F0480100000000800001004000000020000040100000400800003004000020020000140100080200802000018010000
...    0E008004000000100001000800009004000018020000280100001600800409024010000180672A6B2A6B052B2A6B066B056B296B266B016B036B012B022B07681A0800004B292
...    82000032CA480800014B29202000072CA480800024B292020000B2CA480800034B292020000F2CA480800044B29202000132CA480800054B29202000172CA4A0800064B292020
...    00062CA480669555D2A8AA55174AA2A82C55058AA0D154A62A93455018AA051549AAA83C50D005E02540A05028140A05028140A05028140A05028140A05000608080600C02004
...    008404008020100C018402004008080600C02018030404030060100C018402004008080600C02004008804030060100C018040300608080100402004010D50F80008101820303
...    85058606880889098A0C0C8D8E0E8F909293139414951697A0A0C1680

*** Test Cases ***
CB008322-ET-E021_Verify_intra-gnb_CA_scell_addition_after_WB_TAS_setup_and_SRS_ue_capability_changed_and_still_have_4R_capability_then_scell_change
    [Documentation]
    ...    1. The purpose of this test case is to check following scenarios:
    ...    Verify when wideband tas srs setup and perform intra gnb CA scell addition with ue cap changed and still have 4R cap, then CA scell
    ...    change successfully.
    ...    Requirement Coverage:
    ...    5G_RAN_USR_RRM_20710,partially covered
    ...    User Scenario CB008322-D#2: CB008322-D#2:Comb 4 for DL BF
    ...    5G_RAN_USR_RRM_20712,partially covered
    ...    User Scenario CB008322-D#4: Coexist of 3 types of SRS based beamforming
    ...    5G_RAN_USR_RRM_20668,partially covered
    ...    User Scenario CB008322-B#2: Wide band TAS SRS configuration algorithm - L2 UE selection
    ...    5G_RAN_USR_RRM_20714,partially covered
    ...    User Scenario CB008322-E#2: Coexistence with cDRX, CLPC enabled
    ...    5G_RAN_USR_RRM_20715,partially covered
    ...    User Scenario CB008322-E#3: Coexistence with CA
    ...    [Configuration]:
    ...    CELL1 Frame structure 1070, srsForBeamMgmt.srsUePeriodicity = 20slots, srsForBeamMgmt.srsUePeriodicityInput = 40slots,PCI 52
    ...    CELL2 Frame structure 1116_0ms, srsForBeamMgmt.srsUePeriodicity = 80slots, srsForBeamMgmt.srsUePeriodicityInput = 40slots,PCI 53
    ...    (srsUePeriodicityOutput automatically calculated as 80slots)
    ...    / is availableWidebandSrsBmResourcesTable, | is availableSubbandSrsBmResourcesTable
    ...    |Comb  |cyclicShift| symbol 0 | symbol 1 | symbol 2 | symbol 3 | symbol 4 | symbol 5 | symbol 6 | symbol 7 |
    ...    |     Slot id      |     3    |     13   |    23    |    33    |    43    |    53    |    63    |    73    |
    ...    |  0   |     1     /          /          /          /          /          /          /    UE11  /    UE11  /
    ...    |  0   |     5     /          /          /          /    UE12  /    UE11  /   UE11   /    UE12  /    UE13  /
    ...    |  0   |     3     /          /          /    UE2   /    UE2   /    UE12  /   UE12   /    UE13  /          /
    ...    |  0   |     7     |          /          /    UE2   /    UE2   /    UE13  /   UE13   /          /          /
    ...    |  1   |     1     | UE11     | UE2      |          |          |          |          |          |          |
    ...    |  1   |     5     |          | UE2      |          |          |          |          |          |          |
    ...    |  1   |     3     |          |          |          |          |          |          |          |          |
    ...    |  1   |     7     |          |          |          |          |          |          |          |          |
    ...    2.Test Case Steps:
    ...       Step a. SA UE2 attach to CELL2
    ...       Step b. send full DL traffic to SA UE2
    ...       Step c. A1 measurement report based SCell addition is triggered, rsrp value higher than a1ThresholdSCellAddSsbRsrpFDD but lower than
    ...            a1ThresholdSCellAddSsbRsrpTDD for SA UE2
    ...       Step d. Attach NSA UE11 to CELL2 to occupy wideband srs resources
    ...       Step e. Attach NSA UE12 to CELL2 to occupy wideband srs resources
    ...       Step f. Attach NSA UE13 to CELL2 to occupy wideband srs resources
    ...       Step g. A1 measurement report based SCell change is triggered, rsrp value higher than a1ThresholdSCellAddSsbRsrpTDD for SA UE2
    ...       Step h. Release NSA UE11 and NSA UE12
    ...       Step i. Stop traffic for UE2 and release ALL ue
    ...       Step j. WireShark Log check
    ...    3. Expected Results:
    ...         Step a:
    ...            1)UE1 is configured with 2 2port subband tas srs and 1 2 port codebook srs resource. Srs resources are on or close to the end
    ...              of drx on duration slot.
    ...            2)the fisrt tas srs resource is reusing codebook srs resource. See table-E021 in sheet ""Case resource pool"" for resource
    ...              pool reference.
    ...            3)UE spec CSIRS resouce is allocated for UE. (Check rrcReconfiguration.csi_MeasConfig IE: nrofPorts=p4)
    ...         Step b:
    ...            1)In case of both DL buffer and channel status above threshold, L2PS triggered rrc reconfiguration procedure
    ...            2)Cplane configured wide band SRS with periodicity indicated srsUePeriodicitySubbandBm. Resource position See table-E021 in
    ...              sheet ""Case resource pool"".
    ...            3)UE2 is configured with 2 2 port wideband tas srs regardless of drx.
    ...            4)subband codebook SRS is reconfigured if it is conflict with its wideband tas srs resource.
    ...         Step c:
    ...            1)UE is reconfigured with 4 1port wideband tas srs and 1 1 port subband codebook srs resource on pcell.
    ...            2)SA UE2 add CELL11 as scell. Scell activated immediately after scell addition successfully.
    ...            3)No tas srs resource allocate on scell.
    ...         Step d: UE is configured with 4 1port wideband tas srs and 1 1 port subband codebook srs resource
    ...         Step e: UE is configured with 4 1port wideband tas srs and 1 1 port subband codebook srs resource
    ...         Step f: UE is configured with 4 1port wideband tas srs and 1 1 port subband codebook srs resource
    ...         Step g:
    ...            1)UE1 is configured with 2 2port wideband tas srs and 1 2 port codebook srs resource
    ...            2)SA UE2 change scell to CELL1. Scell activated immediately after scell addition successfully.
    ...            3)No tas srs resource allocate on scell.
    ...         Step h: UE are release successfully
    ...         Step i: SRS resource not changed, traffic can be stopped successfully and UE release successfully
    ...         Step j: WireShark Log check is passed
    [Tags]    QC_47144    E021    AP_REG
    Set radPdcchApplyToSeparateStream for AP
    SA UE attach    ue_id=2    cell_id=2
    SA UE Send And Verify Throuput    ue_id=2
    UE Send A1 To Trigger FDD Scell Addition    ue_id=2
    NSA UE11 attach on cell2
    NSA UE12 attach on cell2
    NSA UE13 attach on cell2
    UE Send A1 To Trigger TDD Scell Addition    ue_id=2
    Stop Traffic SA UE and release all UE
    Check WireShark Log    ${CURDIR}${/}A2A_CB008322_E021${/}a2a.ini    wait_string=UEContextReleaseComplete::10

CB008322-ET-E023_Verify_intra-gnb_CA_scell_add_after_WB_TAS_setup_and_SRS_ue_capability_changed_but_not_enough_WB_TAS_resource_then_scell_release
    [Documentation]
    ...    1. The purpose of this test case is to check following scenarios:
    ...    Verify when wideband tas srs setup and perform intra gnb CA scell addition successfylly with ue cap changed(still have 4R cap) but not
    ...    enough wideband srs resource, then perform CA scell release successfully.
    ...    Requirement Coverage:
    ...    5G_RAN_USR_RRM_20710,partially covered
    ...    User Scenario CB008322-D#2:CB008322-D#2: Comb 4 for DL BF
    ...    5G_RAN_USR_RRM_20712,partially covered
    ...    User Scenario CB008322-D#4:Coexist of 3 types of SRS based beamforming
    ...    5G_RAN_USR_RRM_20668,partially covered
    ...    User Scenario CB008322-B#2:Wide band TAS SRS configuration algorithm - L2 UE selection
    ...    5G_RAN_USR_RRM_20714,partially covered
    ...    User Scenario CB008322-E#2:Coexistence with cDRX, CLPC enabled
    ...    5G_RAN_USR_RRM_20715,partially covered
    ...    User Scenario CB008322-E#3:Coexistence with CA
    ...    [Configuration]:
    ...    CELL1 Frame structure 1070, srsForBeamMgmt.srsUePeriodicity = 20slots, srsForBeamMgmt.minSrsUePeriodicity = 40slots,PCI 52
    ...    CELL2 Frame structure 1116_0ms, srsForBeamMgmt.srsUePeriodicity = 80slots, srsForBeamMgmt.minSrsUePeriodicity = 40slots,PCI 53
    ...    / is availableWidebandSrsBmResourcesTable, | is availableSubbandSrsBmResourcesTable
    ...    |Comb  |cyclicShift| symbol 0 | symbol 1 | symbol 2 | symbol 3 | symbol 4 | symbol 5 | symbol 6 | symbol 7 |
    ...    |     Slot id      |     3    |     13   |    23    |    33    |    43    |    53    |    63    |    73    |
    ...    |  0   |     1     |          /          /    UE17  /     UE16 /    UE15  /   UE15   /   UE15   /    UE15  /
    ...    |  0   |     5     |          /          /          /     UE17 /    UE16  /   UE16   /    UE16  /    UE1   /
    ...    |  0   |     3     |          /          /          /          /    UE17  /   UE17   /    UE1   /          /
    ...    |  0   |     7     |          /          /          /          /    UE1   /   UE1    /          /          /
    ...    |  1   |     1     |          |          |          |          |          |          |          |          |
    ...    |  1   |     5     |          |          |          |          |          |          |          |          |
    ...    |  1   |     3     |          |          |          |          |          |          |          |          |
    ...    |  1   |     7     |          |          |          |          |          |          |          |          |
    ...    2.Test Case Steps:
    ...       Step a. preUE NSA UE15, UE16, UE17 attach to CELL1 and send full DL traffic to occupy Wideband pool resources
    ...       Step b. preUE NSA UE18 attach to CELL1 to occupy UE specific CSIRS resource
    ...       Step c. SA UE1 attach to CELL2
    ...       Step d. SA UE1 start full DL traffic
    ...       Step e. Release preUE NSA UE18
    ...       Step f. A1 measurement report based SCell addition is triggered of SA UE1
    ...       Step g. A2 measurement report based SCell release is triggered of SA UE1
    ...       Step h. releas all UE
    ...       Step i. WireShark Log check
    ...    3. Expected Results:
    ...         Step a:
    ...            1)All UEs are reconfigured with 4 1 port wideband tas srs and 1 1 port codebook srs resource regardless of drx. the fisrt tas srs
    ...              resource is reusing codebook srs resource
    ...            2)Cplane configured wideband SRS with periodicity indicated srsUePeriodicitySubbandBm. Resource pool See table-E012 in
    ...              sheet "Case resource pool"
    ...         Step b: preUE NSA UE18 attach is attach successfully
    ...         Step c: UE1 is attach successfully
    ...         Step d:
    ...            1)Cplane configured wide band SRS with periodicity indicated srsUePeriodicitySubbandBm. Resource position See table-E012 in
    ...            sheet "Case resource pool".
    ...            2)UE1 is reconfigured with 4 1port wideband tas srs, codebook srs resource is reconfig to asrs resource due to conflict with
    ...            its wideband tas srs resource.
    ...            3)cell spec CSIRS resouce is allocated for UE. (Check rrcReconfiguration.csi_MeasConfig IE: nrofPorts=p8)
    ...         Step e: UE releases successfully
    ...         Step f:
    ...            1)check l2_psuser_usermodify msg, RemotePcellToModify is not include.
    ...            2)UE1 is reconfigured with 2 2port subband tas srs and 1 2 port subband codebook srs resource due to wideband pool resource
    ...              limitation exceeds. the fisrt tas srs resource is not reusing codebook srs resource.No tas srs resource allocate on scell.
    ...            3)SA UE1 add CELL2 as scell. Scell activated immediately after scell addition successfully.
    ...            4)Ue specific CSIRS is allocated for UE (rrc message nrofPorts=p4, firstOFDMSymbolinTimeDomain and slot of UE-1 should be the
    ...             same with UE-17's)
    ...         Step g:
    ...            1)scell release sucessfully.
    ...            2)UE1 is reconfigured with 4 1port subband tas srs and 1 2 port codebook srs resource on or close to the end of the drx
    ...             duration slot.The fisrt tas srs resource is not reusing codebook srs resource.
    ...            3)Ue specific CSIRS is allocated for UE (rrc message nrofPorts=p4, firstOFDMSymbolinTimeDomain and slot of UE-1 should be the
    ...             same with UE-17's)ration.csi_MeasConfig IE: nrofPorts=p4)
    ...         Step h: UE are release successfully
    ...         Step i: WireShark Log check is passed
    [Tags]    QC_47142    E023
    OnlineParamChange    ${actCsirsMultiplexing_Dis}
    Set radPdcchApplyToSeparateStream for AP
    NSA UE15-17 attach on cell2
    NSA UE attach    ue_id=18
    SA UE attach    ue_id=1    cell_id=2
    SA UE Send And Verify Throuput    ue_id=1
    NSA UE release    ue_id=18
    UE1 Send A1 To Trigger TDD Scell Addition    ue_id=1    cellfreq=628320
    UE Send A2 event to trigger scell release
    all SA and NSA UE release
    Check WireShark Log    ${CURDIR}${/}A2A_CB008322_E023${/}a2a.ini    wait_string=UEContextReleaseComplete::12

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Install eNB Package via WEBEM
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/3cells_2T1F    ue_count=10

Install eNB Package via WEBEM
    [Arguments]    ${bsr_name}=BSR_AQQL_6_H6_ALN60_ARP60_P11_COVERAGE_00776_00001.zip
    Execute Cmd On Pc    rm -rf /home/ute/bsr_package/
    Execute Cmd On Pc    mkdir /home/ute/bsr_package/
    Execute Cmd On Pc    git clone https://gitlabe1.ext.net.nokia.com/hz_ran_l2_sw3_ta/ta_kiss_golden_files.git /home/ute/bsr_package/
    update_software    sw_package=/home/ute/bsr_package/BSR_FILE/${bsr_name}    timeout=60

Modify Cfg
    Update Cfg Param    set_cell id=1 gnb=2 pci=17:1
    Update Cfg Param    set_cell id=2 gnb=2 pci=17:2
    Update Cfg    ue_param id=1 ue_nr_capabilities=${ue_nr_cap_SA_UE1}
    Update Cfg    ue_param id=2 ue_nr_capabilities=${ue_nr_cap_SA_UE2_CA}
    Update Cfg    ue_param id=11 ue_nr_capabilities=${ue_nr_full_cap} dual_conn=eutra_nr ue_eutra_nr_capabilities=${ue12_MRDC_cap}
    Update Cfg    ue_param id=12 ue_nr_capabilities=${ue_nr_full_cap} dual_conn=eutra_nr ue_eutra_nr_capabilities=${ue12_MRDC_cap}
    Update Cfg    ue_param id=13 ue_nr_capabilities=${ue_nr_full_cap} dual_conn=eutra_nr ue_eutra_nr_capabilities=${ue12_MRDC_cap}
    Update Cfg    ue_param id=14 ue_nr_capabilities=${ue_nr_full_cap} dual_conn=eutra_nr ue_eutra_nr_capabilities=${ue12_MRDC_cap}
    Update Cfg    ue_param id=15 ue_nr_capabilities=${ue_nr_full_cap} dual_conn=eutra_nr ue_eutra_nr_capabilities=${ue13_MRDC_cap}
    Update Cfg    ue_param id=16 ue_nr_capabilities=${ue_nr_full_cap} dual_conn=eutra_nr ue_eutra_nr_capabilities=${ue13_MRDC_cap}
    Update Cfg    ue_param id=17 ue_nr_capabilities=${ue_nr_full_cap} dual_conn=eutra_nr ue_eutra_nr_capabilities=${ue13_MRDC_cap}
    Update Cfg    ue_param id=18 ue_nr_capabilities=${ue_nr_full_cap} dual_conn=eutra_nr ue_eutra_nr_capabilities=${ue13_MRDC_cap}

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir

SA UE attach
    [Arguments]    ${ue_id}=1    ${cell_id}=1    ${pdu_id}=1    ${enb_id}=2
    Execute Egate Command    ue_change_location id=${ue_id} cell=${cell_id} enb=${enb_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Registered state.
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup pdu=${pdu_id} gw=${pdu_id} ue=${ue_id} nwslice=1    pass_regexp=Initial Context Setup Successful

SA UE Send And Verify Throuput
    [Arguments]    ${ue_id}=1
    Send Traffic SA    ue_id=${ue_id}
    Throughput Verify    ue_id=${ue_id}

Send Traffic SA
    [Arguments]    ${ue_id}=1
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 dir=dl mbps=150 trf_id=1    pass_regexp=Started Downlink Internal traffic
    sleep    2s    #wait drx reconfig
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 dir=dl mbps=150 trf_id=2    pass_regexp=Started Downlink Internal traffic
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 dir=dl mbps=150 trf_id=3    pass_regexp=Started Downlink Internal traffic
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 dir=dl mbps=150 trf_id=4    pass_regexp=Started Downlink Internal traffic
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 dir=dl mbps=150 trf_id=5    pass_regexp=Started Downlink Internal traffic
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 dir=dl mbps=150 trf_id=6    pass_regexp=Started Downlink Internal traffic

Throughput Verify
    [Arguments]    ${ue_id}=1    ${Tput_dl}=140    ${sleep_time}=15s    ${qfi}=1
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=${qfi}    direction=dl    rate_type=ave
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pdsch    Throughput
    Should Not Match Regexp    ${scell_tput}    CellIndex-.*Mbps.*Mbps.*Mbps.* 0 Mbps
    Should Be True    ${dl_throughput}/1000>${Tput_dl}

UE Send A1 To Trigger FDD Scell Addition
    [Arguments]    ${ue_id}=2    ${cellfreq}=628320
    ${ScellAdd_A1}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cellfreq}    event_type=A1
    ...    threshold=RSRP\ 31
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=2 meas_id=1 event=A1 srsrp_nr=70 srsrq_nr=40
    ...    pass_regexp=rrcReconfigurationComplete    fail_regexp=usage codebook
    Throughput Verify    ue_id=2

UE Send A1 To Trigger TDD Scell Addition
    [Arguments]    ${ue_id}=2    ${cellfreq}=628320
    ${ScellAdd_A1}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cellfreq}    event_type=A1
    ...    threshold=RSRP\ 111
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${ScellAdd_A1} event=A1 srsrp_nr=115 srsrq_nr=40
    ...    pass_regexp=rrcReconfigurationComplete
    Throughput Verify    ue_id=${ue_id}

NSA UE attach
    [Arguments]    ${ue_id}=11    ${target_cells}=2
    Execute Egate Command    ue_attach id=${ue_id}    pass_regexp=UE IS ACTIVE
    Execute Egate Command    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${target_cells} bearer=2 type=split_scg
    ...    pass_regexp=SgNBModificationConfirm

NSA UE Send And Verify Throuput
    [Arguments]    ${ue_id}=11
    Send Traffic NSA    ue_id=${ue_id}
    Verify Throuput NSA    ue_id=${ue_id}

NSA UE11 attach on cell2
    NSA UE attach    ue_id=11
    NSA UE Send And Verify Throuput    ue_id=11

NSA UE12 attach on cell2
    NSA UE attach    ue_id=12
    NSA UE Send And Verify Throuput    ue_id=12

NSA UE13 attach on cell2
    NSA UE attach    ue_id=13
    NSA UE Send And Verify Throuput    ue_id=13

Send Traffic NSA
    [Arguments]    ${ue_id}=11
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=dl mbps=150 trf_id=1    pass_regexp=SgNBModificationConfirm
    sleep    2s    #wait WB reconfig
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=ul mbps=10    pass_regexp=UDP UL

Verify Throuput NSA
    [Arguments]    ${ue_id}=11    ${sleep_time}=10s
    sleep    ${sleep_time}
    ${scell8_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=8    type=pdsch    rate_type=ave
    Should Be True    ${scell8_tput}/1000>130
    ${ul_throuput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=ul    dc_cell_group=all    rate_type=ave
    Should Be True    ${ul_throuput}/1000>3

Stop Traffic SA UE and release all UE
    [Arguments]    ${ue_id}=2
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=1    pass_regexp=Traffic was stopped
    sleep    2s    #wait SB reconfig
    Execute Egate Command    ue_deregister id=2 ue_deregister_type=switch_off    UE${ue_id}: detached
    Execute Egate Command    ue_detach id=11,12,13    pass_regexp=${NSA_UE11_to_13_detached}

NSA UE release
    [Arguments]    ${ue_id}=2
    Execute Egate Command    ue_detach id=${ue_id}    pass_regexp=detached

NSA UE15-17 attach on cell2
    NSA UE attach    ue_id=15    target_cells=2
    NSA UE attach    ue_id=16    target_cells=2
    NSA UE attach    ue_id=17    target_cells=2
    NSA UE Send And Verify Throuput    ue_id=15
    NSA UE Send And Verify Throuput    ue_id=16
    NSA UE Send And Verify Throuput    ue_id=17

UE1 Send A1 To Trigger TDD Scell Addition
    [Arguments]    ${ue_id}=2    ${cellfreq}=628320
    ${ScellAdd_A1}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cellfreq}    event_type=A1
    ...    threshold=RSRP\ 111
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${ScellAdd_A1} event=A1 srsrp_nr=115 srsrq_nr=40
    ...    pass_regexp=rrcReconfigurationComplete
    Throughput Verify    ue_id=${ue_id}

UE Send A2 event to trigger scell release
    [Arguments]    ${ue_id}=1    ${cellfreq}=636576    ${SCellIndex}=1
    ${ScellRel_A2}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cellfreq}    event_type=A2
    ...    threshold=RSRP\ 34
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${ScellRel_A2} event=A2 scell=${SCellIndex} scell_rsrp=20
    ...    pass_regexp=rrcReconfigurationComplete

all SA and NSA UE release
    NSA UE release    ue_id=15,16,17
    Release ues    ue_type=all

Set radPdcchApplyToSeparateStream for AP
    ${Command_1}    catenate
    ...    bsh 1:1 confmgmtdefscli set --domain NrUeDlPhy  --name radPdcchApplyToSeparateStreams_AP
    ...    --value 1 --change-type persistent --timeout 5
    ${Command_2}    catenate
    ...    bsh 2:1 confmgmtdefscli set --domain NrUeDlPhy  --name radPdcchApplyToSeparateStreams_AP
    ...    --value 1 --change-type persistent --timeout 5
	    ${Command_3}    catenate
    ...    bsh 1:1 confmgmtdefscli set --domain NrUeDlPhy  --name radIqDumpInSyslog
    ...    --value 15 --change-type persistent --timeout 5
	${Command_4}    catenate
    ...    bsh 2:1 confmgmtdefscli set --domain NrUeDlPhy  --name radIqDumpInSyslog
    ...    --value 15 --change-type persistent --timeout 5
    Execute Command On Wts    ${Command_1}
	Execute Command On Wts    bsh 1:1 confmgmtdefscli read --domain NrUeDlPhy  --timeout 5
	Execute Command On Wts    ${Command_2}
	Execute Command On Wts    bsh 2:1 confmgmtdefscli read --domain NrUeDlPhy  --timeout 5
	Execute Command On Wts    ${Command_3}
	Execute Command On Wts    bsh 1:1 confmgmtdefscli read --domain NrUeDlPhy  --timeout 5
	Execute Command On Wts    ${Command_4}
	Execute Command On Wts    bsh 2:1 confmgmtdefscli read --domain NrUeDlPhy  --timeout 5

