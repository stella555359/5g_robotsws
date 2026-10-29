*** Settings ***
Suite Setup     Common Suite Setup And Setup Airphone Env
Suite Teardown  Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup      Common Test Setup And Start To Capture Logs
Test Teardown   Common Test Teardown And Stop Capture Logs
Force Tags      QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    CRT    CLOUD_5G_I_BOO_AP_LOO
...             team-CN1_SG14    owner-jiangping.cao    release-5G22R3     CB008247
Resource        ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{enableCDrx}
...    @{enableBeamforming}
...    @{srsConfig}
...    @{interFreqHoConfig}
...    @{csiconfig}
...    @{CarrierAggregationConfig}
...    @{gscn_Arfcn}

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
...    NRCELL-4:srsForBeamMgmt:srsUePeriodicity=slots40
...    NRCELL-4:srsForBeamMgmt:cSRS=12
...    NRCELL-4:srsForBeamMgmt:bSRS=2
...    NRCELL-2:dftBeamDiffThresholdH=15
...    NRCELL-2:dftBeamDiffThresholdV=15
...    NRCELL-2:actUlSrsBm=true
...    NRCELL-2:actDlSrsBm=true
...    NRCELL-2:srsForBeamMgmt:srsUePeriodicity=slots40
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
...    NRBTS-2:timerXnDataFwdGuard=250
...    NRBTS-2:actInterFreqHoSA=true
...    NRPMRNL-1:miNrRelReportCu=5min
...    NRCELL:a2MeashoEnabledSA=rsrp
...    NRCELL:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0
...    NRCELL:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=25
...    NRCELL:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms0
...    NRCELL:a1MeashoEnabledSA=rsrp
...    NRCELL:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRCELL:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=40
...    NRCELL:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms0


@{CarrierAggregationConfig}
...    NRBTS-2/NRDU-1:actConnectedModeMobilityCA=true
...    NRBTS-2/NRDU-1:carrierAggregationSupportList=${CA_support_list}
...    NRBTS-2/NRDRB_RLC_AM-1:ulTReassemblyIBCA=40ms
...    NRBTS-2/NRDRB_RLC_AM-2:ulTReassemblyIBCA=40ms
...    NRBTS-2:actCarrierAggregation=true
...    NRBTS-2:sCellActivationMethod=blind
...    NRBTS-2:caConfigurationSupport=2CCDL_2CCUL
...    NRBTS-2:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS-2:actMeasBasedSCellAdditionNsa=true
...    NRCELL-4:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0
...    NRCELL-4:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=30
...    NRCELL-4:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=480ms
...    NRCELL-4:ulMimoMode=Closed loop Spatial Multiplexing (2x2)
...    NRCELL-2:ulMimoMode=Closed loop Spatial Multiplexing (2x2)
...    NRCELL-2:actUlSrsBm=true
...    NRCELL-2:actDlSrsBm=true
...    NRCELL-4/NRREL-1:gNbId=2
...    NRCELL-4/NRREL-2:gNbId=2
...    NRCELL-4/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-4/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-4/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-4/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-4/NRREL-1:lcrId=2
...    NRCELL-4/NRREL-2:lcrId=1
...    NRCELL-4/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-4/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-4/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-4/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-4/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-4/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-4:a1MeasSCellAddEnabled=rsrp
...    NRCELL-4:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=111
...    NRCELL-4:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=30
...    NRCELL-4:a2MeasSCellRelEnabled=rsrp
...    NRCELL-2:weightForSCellSelection=100
...    NRCELL-1:weightForSCellSelection=50
...    NRCELL-4:actK1Opt=intra-gNB
...    NRCELL-2:actK1Opt=intra-gNB
...    NRCELL-1:actK1Opt=intra-gNB
...    NRCELL-1:a2MeasSCellRelEnabled=rsrp
...    NRCELL-1:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0
...    NRCELL-1:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=30
...    NRCELL-1:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=480ms
...    NRCELL-2:a2MeasSCellRelEnabled=rsrp
...    NRCELL-2:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0
...    NRCELL-2:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=30
...    NRCELL-2:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=480ms
...    NRDU:actInterNumerologyCa=true

${CA_support_list}  ca_Fr1Tdd_Fdd_Sa,ca_Fdd_Fdd,ca_Fdd_Fr1Tdd_Nsa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Nsa,ca_Fdd_Fr1Tdd_Sa,ca_Fr1Tdd_Any_Sa
${rdSrsCodebookAndTas}    0x590103
${rdPriorSrsForDlBm}    0x590104
@{PARAMS_IN_SWCONFIG}  ${rdSrsCodebookAndTas}=1    ${rdPriorSrsForDlBm}=0
@{PARAMS_IN_SWCONFIG_AP}    0x70690=1
#0x70690: AP enable 1086 and 8247
#rdSrsCodebookAndTas : 0: FALSE[default], 1: TRUE;To control whether 'antennaSwitching' SRS can overlap with codebook SRS or not
#rdPriorSrsForDlBm: 0: TAS[default], 1: codebook;To control which kind of periodic SRS has higher priority for DL SRS based beamforming

#5G-UEs are capable of TAS SRS. UE’s capability IE ‘supportedSRS-TxPortSwitch’ is one of {t1r1, t1r2, t1r4, t2r4, t2r2, t4r4, t1r4-t2r4}.
#SA UE3:
#BAND78: t2r4 maxNumberSRS-Ports-PerResource=n2
#BandCombination T(n78)+F(n71): t1r4 maxNumberSRS-Ports-PerResource=n2
#BandCombination T(n78)+T(n41): t2r4 maxNumberSRS-Ports-PerResource=n2
${ue_nr_cap_SA_UE1}  SEPARATOR=
...    E9A09000575F5A13160003C320016093170019C3D09009B20C39F30C7942C0E098040623807DC6C28C0D608C21A08107482C
...    036B64C558D0E7C471E819F604F8C48E3C873EA39F30C7942C0E070F05C00FFC0070005F000540001C0A83620EB04610D040
...    83C4160195B262AC4873EC09F11C78C48E3C873EA39F30C7942C0E070F09FD8000007F6000000540001C0AA3626EB04610D0
...    4083A4160185B262A88873E238F11C7A067D813E31CF9863CA1607038782E007FE003801FF8002A0000E0571F11B58230868
...    2041F282C02AB64C55850E7C471E300000000000000000000007809FC0000007F0000000540001C01278789A001C41000002
...    16020541E14000711800000858158788C001C41000006160561E14000710400000858158789A001C46000002160562E23000
...    71040038820000142C0AC3C28000E268000060B02B17134003882001C28000008160562E26800711800388C0000082C0AC5C
...    28000E20800711800001058158B850001C41000E208000020B02B17134003882001C46000004160562E14000711800388C00
...    00082C0AC5C4D000E2300070A000002058158788C001C46000006160561E1400070A000003058158B850001C46000E140000
...    040B02B0F13400389A0000182C0803808D00A2026C04111406F84A14489B1CF870A244D8E7C3851226C73E1C28913639F0E1
...    4285B1CF871224489B1CF870A244D8E7C08902040D8E7C08902040D8E7C08902040D8E7C08902040D8E7C08912040D8E7C08
...    902040D8E7C08902040D8E7C0850206C73E0428103639F022408103639F0214489B1CF8000D890C6318C6318C6318C6318C6
...    0F413003C00381C1401C0C02500700060240040603E090020000000100000200800000004000008020000080100000600800
...    00400400002802001004010040000300200001C010008000000200002001000012008000030040000500200002C010008120
...    48020000300CE54D654D60A5606560CD60AD652D64CD602D606D6025604560ED034100000965250400006594941000029652
...    4040000E594901000049652404000165949010000696524040001E594901000089652404000265949010000A96524040002E
...    5949410000C96524040000C594900CD2AABA55554AA2E95455058AA0B1541A2A94C55268AA031540A2A93555078A1202F012
...    A05028140A05028140A05028140A05028140A0502800304040300601002004202004010080600420100200404030060100C0
...    18202018030080600C201002004040300601002004402018030080600C0201803040400802010020086A87C0004080C10181
...    C282C30344044484C5060646C70747C8494989CA0A4A8B4BD05060B4

*** Test Cases ***
CB008247-ET-D02_D_B2_Coexistence_with_DL_CA_scell_change_4x2_CL_MIMO_T+F_UE_with_TAS_t2r4_reuse_codebook_SRS_resource
    [Documentation]
    ...    1. The purpose of this test case is to check following scenarios:
    ...         USCB008247-D#B1: Coexistence with cDRX enabled
    ...         USCB008247-D#B2: Coexistence with DL CA
    ...    2. Test Case Steps:
    ...         a. Attach SA UE1 to NR cell1
    ...         b. Trigger A1 measurement report for UE1, rsrp value higher than a1ThresholdSCellAddSsbRsrpFDD
    ...            but lower than a1ThresholdSCellAddSsbRsrpTDD
    ...         c. Trigger A1 measurement report for UE1, rsrp value higher than a1ThresholdSCellAddSsbRsrpTDD
    ...         d. Trigger A2 measurement report for UE1
    ...         e. Release UE1
    ...    3. Expected Results:
    ...         Step a:  SA UE-3 call setup successfully. 1(2ports) Codebook SRS and 2 (2ports) TAS SRS resource
    ...                  assigned only on PCELL, TAS SRS should reuse codebook resource.  p-SRS slotoffset is in
    ...                  DRX on duration. UE specific CSI-RS configured.1 CSI-RS resource assigned.
    ...         Step b:  SA UE-3 will add cell 1 for TDD-FDD 2CC CA. 1(2ports) Codebook SRS and 4(1port) TAS SRS
    ...                  resource assigned only on PCELL, TAS SRS should not reuse codebook resource. 1 UE
    ...                  specific CSI-RS resource should be added for scell.  p-SRS slotoffset is in DRX on
    ...                  duration or close to the end of DRX on duration.
    ...         Step c:  SCell change is triggered and Cell 2 is selected as new Scell. 1(2ports) Codebook SRS and
    ...                  2(2ports) TAS SRS resource assigned only on PCELL, TAS SRS should reuse codebook resource.
    ...                  UE specific CSI-RS should be assigned for scell.
    ...         step d:  scell released
    ...         step e:  SA UE1 can be released successfully.
    [Tags]    QC_166764    jiancao
    SA UE attach
    A1 event trigger scell addition or scell change    carrierfreq=636576    srsrp_nr=90    scell_id=1    SCellIndex=1
    A1 event trigger scell addition or scell change    carrierfreq=636576    srsrp_nr=120    scell_id=2    SCellIndex=2
    A2 event trigger scell release
    Check RRC log    ${CURDIR}${/}a2a_D02${/}a2a.ini

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/4cells_2F2T    ue_count=2

Modify Cfg
    ${Update_Cfg_CELL2}    catenate
    ...    set_cell id=2 gnb=2 pci=16:2 tac=200 nrci=0x02 tdd_cell=on proxy=$PROXY_SERVER_IP:9999|$PROXY_SERVER_IP:8888
    ...    nr_arfcn=501198:501198 mandatory_for_activation=off gscn=6252
    Update Cfg    ${Update_Cfg_CELL2}
    Update Cfg    ue_param id=1 ue_nr_capabilities=${ue_nr_cap_SA_UE1}
    Update Cfg    cell_srs_beam_pos_nr profile_id=1 num_of_ue_positions=4 azimuth=-45,30,25,60
    Update Cfg    cell_testmode_set_nr cell_id=2 gnb=2 testmode=cell_srs_beam_pos profile_id=1 action=activate
    Update Cfg    cell_testmode_set_nr cell_id=4 gnb=2 testmode=cell_srs_beam_pos profile_id=1 action=activate

SA UE attach
    [Arguments]    ${ue_id}=1    ${cell_id}=4    ${pdu_id}=1
    Execute Egate Command    ue_change_location id=1 cell=${cell_id} enb=2
    Start RRC Log    SA_UE${ue_id}_cell4_attach
    Execute Egate Command    ue_register id=${ue_id}    is now Registered
    Execute Egate Command    ue_pdu_session_setup pdu=${pdu_id} gw=${pdu_id} ue=${ue_id} nwslice=1    Initial Context Setup Successful
    Get RRC Log

A1 event trigger scell addition or scell change
    [Arguments]    ${ue_id}=1    ${carrierfreq}=636576    ${srsrp_nr}=90    ${scell_id}=1    ${SCellIndex}=1
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=1    carrierfreq=${carrierfreq}    event_type=A1
    Start RRC Log    UE${ue_id}_addition_to_cell${scell_id}
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrq_nr=60 srsrp_nr=${srsrp_nr}
    ...    SCellIndex ${SCellIndex} activated successfully at airphone    timeout=20s
    Get RRC Log

A2 event trigger scell release
    [Arguments]    ${ue_id}=1    ${carrierfreq}=500190    ${scell_id}=2    ${SCellIndex}=2
    Start RRC Log    UE${ue_id}_cell${scell_id}_release
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=1    carrierfreq=${carrierfreq}    event_type=A2
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 scell=${SCellIndex} scell_rsrp=20
    ...    ServingCellMO is not present in CellGroupConfig    timeout=20s
    Get RRC Log
