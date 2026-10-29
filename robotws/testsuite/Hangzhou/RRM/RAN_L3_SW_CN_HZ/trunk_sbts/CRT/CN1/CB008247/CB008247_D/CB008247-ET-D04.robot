*** Settings ***
Suite Setup  Common Suite Setup And Setup Airphone Env
Suite Teardown  Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup  Common Test Setup And Start To Capture Logs
Test Teardown  Common Test Teardown And Stop Capture Logs
Force Tags  QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    CRT    CLOUD_5G_I_BOO_AP_LOO
...    team-CN1_SG14    owner-alex.2.wang    release-5G22R3     CB008247
Resource    ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{enableCDrx}
...    @{enableBeamforming}
...    @{srsConfig}
...    @{interFreqHoConfig}
...    @{CarrierAggregationConfig}
...    @{gscn_Arfcn}
...    @{csiconfig}

@{gscn_Arfcn}
...    NRCELL-2:nrarfcn=501198
...    NRCELL-2:gscnOrSsPbchArfcn=6252
...    NRCELL-2:type0CoresetConfigurationIndex=1


@{enableBeamforming}
...    NRBTS-2:actChannelMapVal=ShowAsWarning
...    NRCELL:actUeCsirsCoexistCellCsirs=true
...    NRCELL-4:beamSet:nrBtsBeamRefinementP2=true
...    NRCELL-2:beamSet:nrBtsBeamRefinementP2=true
...    NRCELL-4:srsForBeamMgmt:srsPowerThresholdForDlBm=-120
...    NRCELL-2:srsForBeamMgmt:srsPowerThresholdForDlBm=-120
...    NRCELL-4:srsForBeamMgmt:srsPowerThresholdForUlBm=-120
...    NRCELL-2:srsForBeamMgmt:srsPowerThresholdForUlBm=-120
...    NRCELL-4:beamSet:basicBeamSet=beamSet_4
...    NRCELL-2:beamSet:basicBeamSet=beamSet_4
...    NRCELL-4:numberOfRxBeamforming=4Rx
...    NRCELL-2:numberOfRxBeamforming=4Rx
...    NRCELLGRP-1:numberOfTransmittedSsBlocks=4 beams
...    NRCELLGRP-0:numberOfTransmittedSsBlocks=1 beam
...    NRCELLGRP-3:numberOfTransmittedSsBlocks=4 beams
...    NRCELLGRP-2:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-4:actBeamforming=true
...    NRCELL-2:actBeamforming=true
...    NRCELL-4:mMimoAntArrayMode=Full 64TRX Array (4x8x2)
...    NRCELL-2:mMimoAntArrayMode=Full 64TRX Array (4x8x2)
...    NRCELL-4:dlMimoMode=4x4 or 4x2 Closed Loop Spatial Multiplexing
...    NRCELL-2:dlMimoMode=4x4 or 4x2 Closed Loop Spatial Multiplexing
...    NRCELL-1:dlMimoMode=2x2 Closed Loop Spatial Multiplexing
...    NRCELL-3:dlMimoMode=2x2 Closed Loop Spatial Multiplexing
...    NRCELL-4:nrCellType=8DL4UL
...    NRCELL-2:nrCellType=8DL4UL
...    NRCELL-4:beamSet:lowerEdgeAngle=120
...    NRCELL-4:beamSet:upperEdgeAngle=60
...    NRCELL-2:beamSet:lowerEdgeAngle=120
...    NRCELL-2:beamSet:upperEdgeAngle=60
...    delete:NRCELL-4:periodicCsiAcquisition:maxCsirsNumber
...    delete:NRCELL-2:periodicCsiAcquisition:maxCsirsNumber
...    delete:NRCELL-4:periodicCsiAcquisition:csirsPower
...    delete:NRCELL-2:periodicCsiAcquisition:csirsPower
...    delete:NRCELL-4:tddFrameStructure:lteToNrFrameShift
...    delete:NRCELL-2:tddFrameStructure:lteToNrFrameShift
...    NRCELL:actDl256Qam=true
...    NRBTS-2:actFdmScheduling=true
...    NRBTS-2:actChannelMapVal=Disabled
...    NRCELLGRP:ssBurstSetPeriod=20
...    NRCELL:pucchModeSelect=longPucch
...    NRCELL:actLongPucchPhase2=true

...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-1:direction=TX
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-1:resourceDN=MRBTS-2/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-2:direction=RX
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-2:resourceDN=MRBTS-2/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-3:direction=TX
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-3:resourceDN=MRBTS-2/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-4:direction=RX
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-4:resourceDN=MRBTS-2/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-2/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-6:direction=RX
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-2/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-7:direction=TX
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-7:resourceDN=MRBTS-2/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-8:direction=RX
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-8:resourceDN=MRBTS-2/EQM-1/APEQM-1/RMOD-1/PHYANT-1

...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-2
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-2/CHANNEL-1:direction=TX
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-2/CHANNEL-1:resourceDN=MRBTS-2/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-2/CHANNEL-2:direction=TX
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-2/CHANNEL-2:resourceDN=MRBTS-2/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-2/CHANNEL-3:direction=TX
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-2/CHANNEL-3:resourceDN=MRBTS-2/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-2/CHANNEL-4:direction=TX
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-2/CHANNEL-4:resourceDN=MRBTS-2/EQM-1/APEQM-1/RMOD-1/PHYANT-1

...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-1:direction=TX
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-1:resourceDN=MRBTS-2/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-2:direction=RX
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-2:resourceDN=MRBTS-2/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-3:direction=TX
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-3:resourceDN=MRBTS-2/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-4:direction=RX
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-4:resourceDN=MRBTS-2/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-2/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-6:direction=RX
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-2/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-7:direction=TX
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-7:resourceDN=MRBTS-2/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-8:direction=RX
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-8:resourceDN=MRBTS-2/EQM-1/APEQM-1/RMOD-3/PHYANT-1

...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-2
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-2/CHANNEL-1:direction=TX
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-2/CHANNEL-1:resourceDN=MRBTS-2/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-2/CHANNEL-2:direction=TX
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-2/CHANNEL-2:resourceDN=MRBTS-2/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-2/CHANNEL-3:direction=TX
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-2/CHANNEL-3:resourceDN=MRBTS-2/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-2/CHANNEL-4:direction=TX
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-2/CHANNEL-4:resourceDN=MRBTS-2/EQM-1/APEQM-1/RMOD-3/PHYANT-1

...    NRCELL-2:cellBwpList:bwpDN=MRBTS-2/NRBTS-2/BWP_PROFILE-5|cellBwpId=0
...    NRCELL-2:cellBwpList:bwpDN=MRBTS-2/NRBTS-2/BWP_PROFILE-54|cellBwpId=1
...    NRCELL-4:cellBwpList:bwpDN=MRBTS-2/NRBTS-2/BWP_PROFILE-5|cellBwpId=0
...    NRCELL-4:cellBwpList:bwpDN=MRBTS-2/NRBTS-2/BWP_PROFILE-54|cellBwpId=1
...    BWP_PROFILE-5:bwpProfileId=5
...    BWP_PROFILE-5:bwpType=initial
...    BWP_PROFILE-5:locationAndBandwidthDl:cRbSizeDl=coreset0
...    BWP_PROFILE-5:locationAndBandwidthDl:cRbStartDl=coreset0
...    BWP_PROFILE-5:locationAndBandwidthUl:cRbSizeUl=sameAsDl
...    BWP_PROFILE-5:locationAndBandwidthUl:cRbStartUl=sameAsDl
...    BWP_PROFILE-5/PDCCH-1:alSelection=static
...    BWP_PROFILE-5/PDCCH-1:dciDedicatedAggregationLevel=AL4
...    BWP_PROFILE-5/PDCCH-1:dciPagingAggregationLevel=AL4
...    BWP_PROFILE-5/PDCCH-1:dciRaCompletionAggregationLevel=AL4
...    BWP_PROFILE-5/PDCCH-1:dciRaMsg2AggregationLevel=AL4
...    BWP_PROFILE-5/PDCCH-1:dciSiAggregationLevel=AL4
...    BWP_PROFILE-5/PDCCH-1:downgradeAL16toAL8=notAllowed
...    BWP_PROFILE-5/PDCCH-1:pdcchId=1
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:pdcchConfigCommonId=1
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceType=Type0A
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceType=Type0A
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=3|searchSpaceType=Type0A
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceType=Type0A
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceType=Type0A
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceType=Type0A
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceType=Type0A
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceType=Type0A
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceType=Type0A
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=1|searchSpaceType=Type0A
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceType=Type0A
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceType=Type1
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceType=Type1
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceType=Type1
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceType=Type1
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceType=Type1
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceType=Type1
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceType=Type1
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceType=Type1
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceType=Type1
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=2|searchSpaceType=Type1
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceType=Type1
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceType=Type2
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceType=Type2
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=3|searchSpaceType=Type2
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceType=Type2
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceType=Type2
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceType=Type2
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceType=Type2
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceType=Type2
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceType=Type2
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=3|searchSpaceType=Type2
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceType=Type2
...    BWP_PROFILE-54:bwpProfileId=54
...    BWP_PROFILE-54:bwpType=dedicated
...    BWP_PROFILE-54:locationAndBandwidthDl:cRbSizeDl=allRb
...    BWP_PROFILE-54:locationAndBandwidthDl:cRbStartDl=crb0
...    BWP_PROFILE-54:locationAndBandwidthUl:cRbSizeUl=sameAsDl
...    BWP_PROFILE-54:locationAndBandwidthUl:cRbStartUl=sameAsDl
...    BWP_PROFILE-54/PDCCH-1:alSelection=static
...    BWP_PROFILE-54/PDCCH-1:dciDedicatedAggregationLevel=AL4
...    BWP_PROFILE-54/PDCCH-1:dciPagingAggregationLevel=AL4
...    BWP_PROFILE-54/PDCCH-1:dciRaCompletionAggregationLevel=AL4
...    BWP_PROFILE-54/PDCCH-1:dciRaMsg2AggregationLevel=AL4
...    BWP_PROFILE-54/PDCCH-1:dciSiAggregationLevel=AL4
...    BWP_PROFILE-54/PDCCH-1:downgradeAL16toAL8=notAllowed
...    BWP_PROFILE-54/PDCCH-1:pdcchId=1
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceType=Type0A
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceType=Type0A
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=3|searchSpaceType=Type0A
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceType=Type0A
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceType=Type0A
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceType=Type0A
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceType=Type0A
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceType=Type0A
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceType=Type0A
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=4|searchSpaceType=Type0A
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceType=Type0A
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceType=Type1
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceType=Type1
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceType=Type1
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceType=Type1
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceType=Type1
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceType=Type1
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceType=Type1
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceType=Type1
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceType=Type1
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=5|searchSpaceType=Type1
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceType=Type1
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceType=Type2
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceType=Type2
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=3|searchSpaceType=Type2
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceType=Type2
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceType=Type2
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceType=Type2
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceType=Type2
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceType=Type2
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceType=Type2
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=6|searchSpaceType=Type2
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceType=Type2
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cceToRegMapping=nonInterleaved
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:coresetId=1
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cRbStart=0
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:duration=1
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:interleaverSize=none
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:regBundleSize=n6
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=48
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:pdcchConfigDedicatedId=1
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=0|searchSpaceType=Type3
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-0-And-1-0|searchSpaceType=Type3
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|searchSpaceType=Type3
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0|searchSpaceType=Type3
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|searchSpaceType=Type3
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|searchSpaceType=Type3
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|searchSpaceType=Type3
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceType=Type3
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceType=Type3
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|searchSpaceType=Type3
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=7|searchSpaceType=Type3
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|searchSpaceType=Type3
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=1|searchSpaceType=UE-Specific
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|searchSpaceType=UE-Specific
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|searchSpaceType=UE-Specific
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceType=UE-Specific
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|searchSpaceType=UE-Specific
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|searchSpaceType=UE-Specific
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|searchSpaceType=UE-Specific
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceType=UE-Specific
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceType=UE-Specific
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|searchSpaceType=UE-Specific
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=8|searchSpaceType=UE-Specific
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|searchSpaceType=UE-Specific

@{srsConfig}
...    NRCELL-4:dftBeamDiffThresholdH=15
...    NRCELL-4:dftBeamDiffThresholdV=15
...    NRCELL-4:actUlSrsBm=true
...    NRCELL-4:actDlSrsBm=true
...    NRCELL-4:srsForBeamMgmt:srsUePeriodicity=slots20
...    NRCELL-4:srsForBeamMgmt:cSRS=12
...    NRCELL-4:srsForBeamMgmt:bSRS=2
...    NRCELL-2:actUlSrsBm=true
...    NRCELL-2:actDlSrsBm=true
...    NRCELL-2:dftBeamDiffThresholdH=15
...    NRCELL-2:dftBeamDiffThresholdV=15
...    NRCELL-2:srsForBeamMgmt:srsUePeriodicity=slots20
...    NRCELL-2:srsForBeamMgmt:cSRS=12
...    NRCELL-2:srsForBeamMgmt:bSRS=2

#1208 Frame Structure
...    NRCELL-4:tddFrameStructure:frameStructureType=semiStatic
...    NRCELL-4:tddFrameStructure:ulDlDataSlotRatio=1/4
...    NRCELL-4:tddFrameStructure:guardPeriodLength=2Symbols
...    NRCELL-4:tddFrameStructure:tdLteUlDlConfig=tdLteConfig2
...    NRCELL-2:tddFrameStructure:frameStructureType=semiStatic
...    NRCELL-2:tddFrameStructure:ulDlDataSlotRatio=1/4
...    NRCELL-2:tddFrameStructure:guardPeriodLength=2Symbols
...    NRCELL-2:tddFrameStructure:tdLteUlDlConfig=tdLteConfig2
...    NRCELL-4:prachConfigurationIndex=98
...    NRCELL-2:prachConfigurationIndex=98

@{enableCDrx}
...    NRCELL-4:actCDrx=true
...    NRCELL-2:actCDrx=true
...    NRCELL-4:drxProfile1:drxInactivityTimer=20ms
...    NRCELL-4:drxProfile1:drxLongCycle=40ms
...    NRCELL-4:drxProfile1:drxOnDurationTimer=4ms
...    NRCELL-4:drxProfile1:drxRetransTimerDl=16slot
...    NRCELL-4:drxProfile1:drxRetransTimerUl=16slot
...    NRCELL-2:drxProfile1:drxInactivityTimer=20ms
...    NRCELL-2:drxProfile1:drxLongCycle=40ms
...    NRCELL-2:drxProfile1:drxOnDurationTimer=4ms
...    NRCELL-2:drxProfile1:drxRetransTimerDl=16slot
...    NRCELL-2:drxProfile1:drxRetransTimerUl=16slot

@{csiconfig}
...    NRCELL-4:actCsirsMultiplexing=true
...    NRCELL-2:actCsirsMultiplexing=true

@{interFreqHoConfig}
...    NRBTS/NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRBTS/NRDU-1:carrierAggregationSupportList=${CA_support_list}
...    NRBTS/NRDU-1:actConnectedModeMobilityCA=true
...    NRBTS:timerXnDataFwdGuard=2000
...    NRBTS:actInterFreqHoSA=true
...    NRBTS:actInterFreqIntraGnbMobilityNSA=true
...    NRPMRNL-1:miNrRelReportCu=5min
...    NRCELL-2:a2MeashoEnabled=rsrp
...    NRCELL-2:a2MeashoEnabledSA=rsrp
...    NRCELL-2:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0
...    NRCELL-2:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=34
...    NRCELL-2:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL-2:a2MeashoSsbRsrp:a2HysteresishoSsbRsrp=0
...    NRCELL-2:a2MeashoSsbRsrp:a2ThresholdhoSsbRsrp=34
...    NRCELL-2:a2MeashoSsbRsrp:a2TimeToTriggerhoSsbRsrp=ms480
...    NRCELL-2:a1MeashoEnabledSA=rsrp
...    NRCELL-2:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRCELL-2:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=60
...    NRCELL-2:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL-2:a1MeashoEnabled=rsrp
...    NRCELL-2:a1MeashoSsbRsrp:a1HysteresishoSsbRsrp=0
...    NRCELL-2:a1MeashoSsbRsrp:a1ThresholdhoSsbRsrp=60
...    NRCELL-2:a1MeashoSsbRsrp:a1TimeToTriggerhoSsbRsrp=ms480
...    NRCELL-2:a2MeasPCellSwitchEnabled=rsrp
...    NRCELL-2:a2MeasPCellSwitchSsbRsrp:a2HysteresisPCellSwitchSsbRsrp=0
...    NRCELL-2:a2MeasPCellSwitchSsbRsrp:a2ThresholdPCellSwitchSsbRsrp=70
...    NRCELL-2:a2MeasPCellSwitchSsbRsrp:a2TimeToTriggerPCellSwitchSsbRsrp=480ms
...    NRCELL-2:a2MeasPCellSwitchSsbRsrp:pCellSwitchOffsetSsbRsrp=5
...    NRCELL-2/NRHOIF-1:a2BasedPCellSwitchEnabled=true
...    NRCELL-2/NRHOIF-1:a2BasedPCellSwitchPriority=1
...    NRCELL-2/NRHOIF-1:chBw=20MHz
...    NRCELL-2/NRHOIF-1:cellDepType=SA
...    NRCELL-2/NRHOIF-1:freqBandIndicatorNR=71
...    NRCELL-2/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-2/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-2/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf5
...    NRCELL-2/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-2/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-2/NRHOIF-1:ssbFrequency=125050
...    NRCELL-1:gscnOrSsPbchArfcn=1562
...    NRCELL-1/NRCELL_FDD-1:nrarfcnDl=124900
...    NRCELL-1/NRCELL_FDD-1:nrarfcnUl=134100
...    NRCELL-2/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=20
...    NRCELL-2/NRHOIF-1:thresholdPCellSwitchTargetRsrp=10
...    NRCELL-2/NRHOIF-1:thresholdPCellSwitchTargetRsrq=10

@{CarrierAggregationConfig}
...    NRBTS:actCarrierAggregation=true
...    NRBTS:sCellActivationMethod=blind
...    NRBTS:caConfigurationSupport=2CCDL_2CCUL
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS:actMeasBasedSCellAdditionNsa=true
...    NRCELL-1:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0
...    NRCELL-1:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=30
...    NRCELL-1:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=480ms
...    NRCELL-2:ulMimoMode=Closed loop Spatial Multiplexing (2x2)
...    NRCELL-2/NRREL-1:gNbId=2
...    NRCELL-2/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-1:lcrId=1
...    NRCELL-2/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-2:a1MeasSCellAddEnabled=rsrp
...    NRCELL-2:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=111
...    NRCELL-2:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=61
...    NRCELL:actK1Opt=intra-gNB
...    NRCELL-1:a2MeasSCellRelEnabled=rsrp
...    NRCELL-1:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0
...    NRCELL-1:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=30
...    NRCELL-1:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=480ms

@{ONLINE_enable_5GC002226}
...    NRBTS:actCoverageNonCoherentUes=true


${CA_support_list}  ca_Fr1Tdd_Fdd_Sa,ca_Fdd_Fdd,ca_Fdd_Fr1Tdd_Nsa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Nsa,ca_Fdd_Fr1Tdd_Sa,ca_Fr1Tdd_Any_Sa
${rdSrsCodebookAndTas}    0x590103
${rdPriorSrsForDlBm}    0x590104
${rdMaxSrsResPerSym1208}    0x5900FD
@{PARAMS_IN_SWCONFIG}  ${rdSrsCodebookAndTas}=1    ${rdPriorSrsForDlBm}=0    ${rdMaxSrsResPerSym1208}=1    0x59004D=1
@{PARAMS_IN_SWCONFIG_AP}    0x70690=1
#0x70690: AP enable 1086 and 8247
#rdSrsCodebookAndTas : 0: FALSE[default], 1: TRUE;To control whether 'antennaSwitching' SRS can overlap with codebook SRS or not
#rdPriorSrsForDlBm: 0: TAS[default], 1: codebook;To control which kind of periodic SRS has higher priority for DL SRS based beamforming
#rdMaxSrsResPerSym1208 : frameStructureType 1028 max srs resoure, it impact srs alloaction,rule is attach first then dealloaction

#BAND41:  t1r4 maxNumberSRS-Ports-PerResource=n1
${ue_nr_cap_SA_UE}  SEPARATOR=
...    E9A09000575F5A13160003C320016093170019C3D09009B20C39F30C7942C0E098040623807DC6C28C0D608C21A08107
...    482406D6C98AB1A1CF88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE00098000702A0D883AC1
...    184341020F10480CAD931562439F604F88E3C62471E439F51CF9863CA1607038784FEC000003FB000000260001C0AA36
...    26EB04610D04083A412030B64C55110E7C471E238F40CFB027C639F30C7942C0E070F05C00FFC007003FF0004C000381
...    5C7C46D608C21A08107CA090155B262AC2873E238F180000000000000000000003C04FE0000003F8000000260001C012
...    78789A001C4100000216020541E14000711800000858158788C001C41000006160561E14000710400000858158789A00
...    1C46000002160562E2300071040038820000142C0AC3C28000E268000060B02B17134003882001C28000008160562E26
...    800711800388C0000082C0AC5C28000E20800711800001058158B850001C41000E208000020B02B17134003882001C46
...    000004160562E14000711800388C0000082C0AC5C4D000E2300070A000002058158788C001C46000006160561E140007
...    0A000003058158B850001C46000E140000040B02B0F13400389A0000182C0803808D00A2026C0410F40DF09428913639
...    F0E14289B1CF870A244D8E7C3851226C73E1C28913639F0E2448913639F0E14081B1CF811204081B1CF811204081B1CF
...    811204081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF810A040D8E7C0850206C73E04481020
...    6C73E0428103639F0001B1218C6318C6318C6318C6318C1E8260078007038280381804A00E000C0480080C07C1200400
...    00000200000401000000008000010040000100200000C010000080080000500400200802008000060040000380200100
...    00000400004002000024010000060080000A004000058020010240900400006019CA9ACA9AC14AC0CAC19AC15ACA5AC9
...    9AC05AC0DAC04AC08AC1DA0682000012CA4A080000CB29202000052CA48080001CB29202000092CA48080002CB292020
...    000D2CA48080003CB29202000112CA48080004CB29202000152CA48080005CB29282000192CA480800018B292019A555
...    74AAAA9545D2A8AA0B154162A83455298AA4D154062A8145526AAA0F142405E02540A05028140A05028140A05028140A
...    05028140A05000608080600C02004008404008020100C018402004008080600C02018030404030060100C01840200400
...    8080600C02004008804030060100C018040300608080100402004010D50F8000810182030385058606880889098A0C0C
...    8D8E0E8F909293139414951697A0A0C168

*** Test Cases ***
CB008247-ET-D04_D_B2_Coexistence_with_DL_CA_pcell_change_4x4_CL_MIMO_T+F_TAS_t1r4_UE_SA
    [Documentation]
    ...    1. The purpose of this test case is to check following scenarios:
    ...         a.USCB008247-D#B2: Coexistence with DL CA
    ...    2. Test Case Steps:
    ...         a. SA UE1 attach to NR cell 2.
    ...         b. A1 measurement report based SCell addition is triggered, rsrp value higher than a1ThresholdSCellAddSsbRsrpTDD for SA UE1
    ...         c. Cell2 A2 measurement report for Pcell switch is triggered, rsrp value lower than a2ThresholdPCellSwitchSsbRsrp
    ...         d. Attach SA UE2 to NR Cell2
    ...         e. A1 measurement report based SCell addition is triggered, rsrp value higher than a1ThresholdSCellAddSsbRsrpTDD for SA UE2
    ...         f. Release all UEs' call
    ...    3. Expected Results:
    ...         Step a:  SA UE1 call setup successfully. 1(1ports) Codebook SRS and 4 (1ports) TAS SRS resource assigned,
    ...                  TAS SRS is reusing codebook resource.
    ...         Step b:  SA UE1 will add cell 1 for TDD-FDD 2CC CA. 1(1port) Codebook SRS and 4(1ports) TAS SRS resource assigned,
    ...                  TAS SRS should not reuse codebook resource only on PCELL.
    ...         Step c:  Pcell switch, IFHO trigger from Cell2 to cell1,all p-SRS release
    ...         Step d:  SA UE2 call setup successfully. 1(1ports) Codebook SRS and 4 (1ports) TAS SRS resource assigned,
    ...                  TAS SRS is reusing codebook resource..
    ...         Step e:  SA UE2 will add cell 1 for TDD-FDD 2CC CA. 1(1port) Codebook SRS and 4(1ports) TAS SRS resource assigned,
    ...                  TAS SRS should not reuse codebook resource only on PCELL.e.
    ...         step f:  UEs call can be released successfully.
    [Tags]    QC_166765    alex.2.wang
    SA UE attach    cell_id=2
    CA setup via A1 measurement
    Pcell switch via A2 measurement
    SA UE attach    ue_id=2    cell_id=2    pdu_id=2
    CA setup via A1 measurement    ue_id=2
    Check Logs    case=D04
    Online enable 5GC002226
    Release Ues    ue_type=sa    ue_id=2
    SA UE attach    ue_id=2    cell_id=2    pdu_id=3
    CA setup via A1 measurement    ue_id=2
    Release ues    ue_type=all
    Check Logs    case=D04

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/4cells_2F2T

SA UE attach
    [Arguments]    ${ue_id}=1    ${cell_id}=2    ${pdu_id}=1
    Execute Egate Command    ue_change_location id=${ue_id} cell=${cell_id} enb=2
    Start RRC Log    SA_UE${ue_id}_cell${cell_id}_attach
    Execute Egate Command    ue_register id=${ue_id}    is now Registered
    Execute Egate Command    ue_pdu_session_setup pdu=${pdu_id} gw=${pdu_id} ue=${ue_id} nwslice=1    Initial Context Setup Successful
    Get RRC Log

Check Logs
    [Arguments]    ${case}=A01
    Check RRC log    ${CURDIR}${/}a2a_${case}${/}a2a.ini

Modify Cfg
    ${Update_Cfg_CELL2}    catenate
    ...    set_cell id=2 gnb=2 pci=16:2 tac=200 nrci=0x02 tdd_cell=on proxy=$PROXY_SERVER_IP:9999|$PROXY_SERVER_IP:8888
    ...    nr_arfcn=501198:501198 mandatory_for_activation=off gscn=6252
    Update Cfg    ${Update_Cfg_CELL2}
    Update Cfg    ue_param id=1 ue_nr_capabilities=${ue_nr_cap_SA_UE}
    Update Cfg    ue_param id=2 ue_nr_capabilities=${ue_nr_cap_SA_UE}
    Update Cfg    cell_srs_beam_pos_nr profile_id=1 num_of_ue_positions=4 azimuth=-45,30,25,60
    Update Cfg    cell_testmode_set_nr cell_id=2 gnb=2 testmode=cell_srs_beam_pos profile_id=1 action=activate
    Update Cfg    cell_testmode_set_nr cell_id=4 gnb=2 testmode=cell_srs_beam_pos profile_id=1 action=activate

CA setup via A1 measurement
    [Arguments]    ${ue_id}=1    ${meas_id}=2
    Start RRC Log    SA_UE${ue_id}_CA_setup
    Execute Egate Command    ue_meas_cfg_disp id=1 meas_obj_type=nr
    sleep    1s
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrq_nr=60 srsrp_nr=90
    ...    activated successfully at airphone
    Get RRC Log

Pcell switch via A2 measurement
    [Arguments]    ${ue_id}=1    ${meas_id}=4
    Execute Egate Command    ue_meas_cfg_disp id=1 meas_obj_type=nr
    sleep    1s
    Start RRC Log    SA_UE${ue_id}_PcellSwitch
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 srsrp_nr=0 srsrq_nr=0 scell=1 scell_rsrp=115 scell_rsrq=35
    ...    Intra-eNB handover from EXT_ENB-2.
    Get RRC Log

Online enable 5GC002226
    Delta Commission Parameters    ${ONLINE_enable_5GC002226}
