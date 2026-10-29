*** Settings ***
Documentation
...    author: Yan Susana
...    contact: susana.yan@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    CRT    CLOUD_5G_I_LO_AP_LO
...    team-CN1_SG14    owner-alex.2.wang    release-5G22R3     CB008247
Resource    ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    NRBTS:rrcReestabTypeSA=sameGNB
...    NRBTS:tWaitingRlRecover=4000ms
...    NRBTS:actCoverageNonCoherentUes=true
...    NRCELL:actDl256Qam=true
...    @{enableBeamforming}
...    @{srsConfig}
...    @{interFreqHoConfig}
...    @{csiconfig}
...    @{cellconfig}
...    @{adaptrelationerror}
@{cellconfig}
...    NRCELL-1:freqBandIndicatorNR=78
...    NRCELL-1:gscnOrSsPbchArfcn=7840
...    MRBTS-1/NRBTS-1/NRCELL-1:nrarfcn=633000

...    NRCELL-2:freqBandIndicatorNR=41
...    NRCELL-2:gscnOrSsPbchArfcn=6351
...    MRBTS-1/NRBTS-1/NRCELL-2:nrarfcn=508020

@{adaptrelationerror}

...    NRBTS:actFdmEnhancedScheduling=true
...    NRCELL:pucchModeSelect=longPucch
...    NRCELL:srsForBeamMgmt:srsPowerThresholdForDlBm=-120
...    NRBTS-1/NRCELLGRP-0:numberOfTransmittedSsBlocks=4 beams
...    NRBTS-1/NRCELLGRP-1:numberOfTransmittedSsBlocks=4 beams


...    NRBTS/NRCELL:measGapSelectionSA=favourUeThroughput
...    NRBTS-1/NRSYSINFO_PROFILE-1:systemInformationTargetRate=0
...    MRBTS-1/MNL-1/MNLENT-1/SYNC-1:actEcpriMasterClock=true
...    NRBTS-1/NRPMRNL-1:miNrNgcFlexInterface=disabled
...    NRPMRNL-1:miNrIntraGnbMobilitySaPmqap=disabled
...    NRPMRNL-1:miNrIntraGnbMobilityNsaPmqap=disabled
...    NRPMRNL-1:miNrInterGnbXnMobilitySaPmqap=disabled
...    NRPMRNL-1:miNrInterGnbNgMobilitySaPmqap=disabled
...    NRPMRNL-1:miNrInterGnbMobilityNsaPmqap=disabled
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

@{enableBeamforming}
...    NRCELL:beamSet:basicBeamSet=beamSet_4
...    NRCELL:numberOfRxBeamforming=4Rx
...    NRCELL:actBeamforming=true
...    NRCELL:mMimoAntArrayMode=Full 64TRX Array (4x8x2)
...    NRCELL:dlMimoMode=8x4 Closed Loop Spatial Multiplexing
...    NRCELL:nrCellType=8DL4UL
...    NRCELL:beamSet:lowerEdgeAngle=135
...    NRCELL:beamSet:upperEdgeAngle=80

@{srsConfig}
...    NRCELL-1:actUlSrsBm=false
...    NRCELL-1:actDlSrsBm=true
...    NRCELL-1:dftBeamDiffThresholdH=15
...    NRCELL-1:dftBeamDiffThresholdV=15
...    NRCELL-1:srsForBeamMgmt:srsUePeriodicity=slots10
...    NRCELL-1:srsForBeamMgmt:cSRS=10
...    NRCELL-1:srsForBeamMgmt:bSRS=2
#1070 Frame Structure
...    NRCELL-1:tddFrameStructure:frameStructureType=semiStatic
...    NRCELL-1:tddFrameStructure:ulDlDataSlotRatio=3/7
...    NRCELL-1:tddFrameStructure:guardPeriodLength=2Symbols
...    NRCELL-1:tddFrameStructure:tdLteUlDlConfig=tdLteConfig2
...    NRCELL-2:actUlSrsBm=true
...    NRCELL-2:actDlSrsBm=true
...    NRCELL-2:dftBeamDiffThresholdH=15
...    NRCELL-2:dftBeamDiffThresholdV=15
...    NRCELL-2:srsForBeamMgmt:srsPowerThresholdForUlBm=-132
...    NRCELL-2:srsForBeamMgmt:srsUePeriodicity=slots20
...    NRCELL-2:srsForBeamMgmt:cSRS=12
...    NRCELL-2:srsForBeamMgmt:bSRS=2
#1208 Frame Structure
...    NRCELL-2:tddFrameStructure:frameStructureType=semiStatic
...    NRCELL-2:tddFrameStructure:ulDlDataSlotRatio=1/4
...    NRCELL-2:tddFrameStructure:guardPeriodLength=2Symbols
...    NRCELL-2:tddFrameStructure:tdLteUlDlConfig=tdLteConfig2

@{csiconfig}
...    NRCELL-1:periodicCsiAcquisition:csiReportPeriodicity=slots320
...    NRCELL-2:periodicCsiAcquisition:csiReportPeriodicity=slots320
...    NRCELL-1:periodicCsiAcquisition:csirsNumberWithinReportPeriod_Set1=2
...    NRCELL-2:periodicCsiAcquisition:csirsNumberWithinReportPeriod_Set1=1
...    NRCELL-1:periodicCsiAcquisition:csirsPower=0
...    NRCELL-2:periodicCsiAcquisition:csirsPower=3
...    NRCELL:periodicCsiAcquisition:maxCsirsNumber=4
...    NRCELL:actUeCsirsCoexistCellCsirs=true

@{interFreqHoConfig}
...    NRBTS:timerXnDataFwdGuard=2000
...    NRBTS:actInterFreqHoSA=true
...    NRBTS:actInterFreqIntraGnbMobilityNSA=true
...    NRPMRNL-1:miNrRelReportCu=5min
...    NRCELL:a2MeashoEnabled=rsrp
...    NRCELL:a2MeashoEnabledSA=rsrp
...    NRCELL:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0
...    NRCELL:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=34
...    NRCELL:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL:a2MeashoSsbRsrp:a2HysteresishoSsbRsrp=0
...    NRCELL:a2MeashoSsbRsrp:a2ThresholdhoSsbRsrp=34
...    NRCELL:a2MeashoSsbRsrp:a2TimeToTriggerhoSsbRsrp=ms480
...    NRCELL:a1MeashoEnabledSA=rsrp
...    NRCELL:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRCELL:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=60
...    NRCELL:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL:a1MeashoEnabled=rsrp
...    NRCELL:a1MeashoSsbRsrp:a1HysteresishoSsbRsrp=0
...    NRCELL:a1MeashoSsbRsrp:a1ThresholdhoSsbRsrp=60
...    NRCELL:a1MeashoSsbRsrp:a1TimeToTriggerhoSsbRsrp=ms480
...    NRCELL-1/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-1/NRHOIF-1:freqBandIndicatorNR=41
...    NRCELL-1/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-1:numberOfTransmittedSsBlocks=4 beams
...    NRCELL-1/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-1:ssbFrequency=508110
...    NRCELL-1/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=11
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms80
...    NRCELL-2/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-2/NRHOIF-1:freqBandIndicatorNR=78
...    NRCELL-2/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-2/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-2/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-2/NRHOIF-1:numberOfTransmittedSsBlocks=4 beams
...    NRCELL-2/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-2/NRHOIF-1:ssbFrequency=632736
...    NRCELL-2/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=11
...    NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms64
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-1:gNbId=1
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-1:lcrId=2
...    NRCELL-1/NRREL-1:removeNotAllowed=false
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-1:gNbId=1
...    NRCELL-2/NRREL-1:gNbIdLength=22
...    NRCELL-2/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-1:lcrId=1
...    NRCELL-2/NRREL-1:removeNotAllowed=false
...    NRCELL-2/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-1:gnbPlmn:mncLength=3

@{OnlineParam_CNI92536}
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRDU-1:actInterNumerologyCa=true
...    NRDU-1:carrierAggregationSupportList=ca_Fr1Tdd_Nsa
...    NRCELL:actCsirsMultiplexing=true
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRBTS:actCarrierAggregation=true
...    NRBTS:sCellActivationMethod=blind
...    NRCELL:sCellDeactivationTimerGNB=infinity
...    NRBTS:caConfigurationSupport=4CCDL_2CCUL
...    NRCELL:allowUnsuppBcOrBcs=accept unknown band combinations
...    NRCELL:actK1Opt=intra-gNB
...    NRCELL:actPciBasedCsiImRandomization=true
...    NRCELL-1:actCDrx=true
...    NRDRX-1:drxInactivityTimer=20ms
...    NRDRX-1:drxLongCycle=20ms
...    NRDRX-1:drxOnDurationTimer=4ms
...    NRDRX-1:drxRetransTimerDl=16slot
...    NRDRX-1:drxRetransTimerUl=16slot
...    NRCELL-1/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-2/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-2/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL:dlMimoMode=4x4 or 4x2 Open Loop Spatial Multiplexing
...    NRBTS:maxNumScellsDl=3
...    NRBTS:maxNumScellsUl=3
...    delete:NRCELL:periodicCsiAcquisition:csirsNumberWithinReportPeriod_Set1
...    delete:NRCELL:periodicCsiAcquisition:csirsPower
...    delete:NRCELL:periodicCsiAcquisition:maxCsirsNumber
...    NRBTS:actPdcpRlcBufCongestionMechsm=gbrNonGbr
...    NRBTS:numNonGbrPdcpSduDiscard=5
...    NRBTS:numNonGbrRlcSduDiscard=5
...    NRBTS:pdcpBufUsageThreshold=95
...    NRBTS:rlcBufUsageThreshold=95
...    NRCELL:periodicCsiAcquisition:csiReportPeriodicity=slots40

@{OnlineParam_CNI92536_recover}
...    delete:NRBTS:sCellActivationMethod
...    delete:NRBTS:maxNumScellsDl
...    delete:NRBTS:maxNumScellsUl
...    NRBTS:actPdcpRlcBufCongestionMechsm=false
...    NRDU-1:actConnectedModeMobilityCA=false
...    NRDU-1:actInterNumerologyCa=false
...    NRDU-1:carrierAggregationSupportList=none
...    NRCELL:actCsirsMultiplexing=false
...    NRCELL:actPciBasedCsiImRandomization=false
...    NRCELL-1:actCDrx=false
...    NRDU-1:flexibleCAMode=BasicCAMode
...    NRBTS:actCarrierAggregation=false
...    NRCELL:sCellDeactivationTimerGNB=ms1280
...    NRBTS:caConfigurationSupport=none
...    delete:NRCELL:allowUnsuppBcOrBcs=accept unknown band combinations
...    NRCELL:actK1Opt=disabled
...    delete:NRCELL-1/NRREL-1:sCellAdditionMethod
...    delete:NRCELL-1/NRREL-1:sCellOperationalMode
...    delete:NRCELL-2/NRREL-1:sCellAdditionMethod
...    delete:NRCELL-2/NRREL-1:sCellOperationalMode
...    NRCELL:dlMimoMode=8x4 Closed Loop Spatial Multiplexing
...    NRCELL:periodicCsiAcquisition:csiReportPeriodicity=slots320
...    NRCELL-1:periodicCsiAcquisition:csirsNumberWithinReportPeriod_Set1=2
...    NRCELL-2:periodicCsiAcquisition:csirsNumberWithinReportPeriod_Set1=1
...    NRCELL-1:periodicCsiAcquisition:csirsPower=0
...    NRCELL-2:periodicCsiAcquisition:csirsPower=3
...    NRCELL:periodicCsiAcquisition:maxCsirsNumber=4
...    NRBTS:actPdcpRlcBufCongestionMechsm=disabled
...    delete:NRBTS:numNonGbrPdcpSduDiscard
...    delete:NRBTS:numNonGbrRlcSduDiscard
...    delete:NRBTS:pdcpBufUsageThreshold
...    delete:NRBTS:rlcBufUsageThreshold

${rdSrsCodebookAndTas}    0x590103
${rdPriorSrsForDlBm}    0x590104
@{PARAMS_IN_SWCONFIG}    ${rdSrsCodebookAndTas}=1    ${rdPriorSrsForDlBm}=1
@{PARAMS_IN_SWCONFIG_AP}    0x70690=1
#0x70690: AP enable 1086 and 8247
#rdSrsCodebookAndTas : 0: FALSE[default], 1: TRUE;To control whether 'antennaSwitching' SRS can overlap with codebook SRS or not
#rdPriorSrsForDlBm: 0: TAS[default], 1: codebook;To control which kind of periodic SRS has higher priority for DL SRS based beamforming

#BAND78: t1r4 maxNumberSRS-Ports-PerResource=n1 BAND41: t1r1 maxNumberSRS-Ports-PerResource=n1
${ue11_MRDC_cap}    SEPARATOR=
...    A11FF83BC4C0C03850001C46000000162205E260601C4D000E230000030B1102F130300E26800710400000058881789818070A0003882000
...    0002C040BC4C0C03882001C46000002160205E360601C46000E208007104000010580817898180713400385000000C2C040804808D00A001
...    C041809A26002E41E24E9113639F0E24E8513639F0E24E8913639F0E24E8913639F0E24E8912639F469D1224498E7D127429131CF8300A20
...    00080404008030100C01840001008080100402018030C0002010100C01804030060100C0184000100808010040200401040002010100C018
...    20001008080600C0

${ue_nr_full_cap}    SEPARATOR=
...    E9A09000575F5A13160003C320016093170019C3D09009B20C39F30C7942C0E098040623807DC6C28C0D608C21A08107482406D6C98AB1A1
...    CF88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE00098000702A0D883AC1184341020F10480CAD931562439F604F
...    88E3C62471E439F51CF9863CA1607038784FEC000003FB000000260001C0AA3626EB04610D04083A412030B64C55110E7C471E238F40CFB0
...    27C639F30C7942C0E070F05C00FFC007003FF0004C0003815C7C46D608C21A08107CA090155B262AC2873E238F1800000000000000000000
...    00004FFF800003FFE00000260001C00F78789A001C4100000216020541E14000711800000858158788C001C41000006160561E1400071040
...    0000858158789A001C46000002160562E2300071040038820000142C0AC3C28000E268000060B02B17134003882001C28000008160562E26
...    800711800388C0000082C0AC5C28000E20800711800001058158B850001C41000E208000020B02B17134003882001C46000004160562E140
...    00711800388C0000082C0AC5C4D000E2300070A000002058158788C001C46000006160401C0468051013602087A05D83E14489B1CF870A24
...    4D8E7C3851226C73E1C28913639F0E14489B1CF871224489B1CF870A040D8E7C08902040D8E7C08902040D8E7C08902040D8E7C08902040D
...    8E7C08902040D8E7C08902040D8E7C08902040D8E7C0850206C73E000B878C6318C6318C6318C630F413003C00281C1401C0C02500700060
...    240040603E09002000000010000020080000000400000802000008010000060080000400400002802001004010040000300200001C010008
...    000000200002001000012008000030040000500200002C01000812048020000300CE54D654D60A5606560CD60AD652D64CD602D606D60256
...    04560ED0341000009652504000065949010000296524040000E594901000049652404000165949010000696524040001E594901000089652
...    404000265949010000A96524040002E5949410000C96524040000C594900CD2AABA55154AA2E95455058AA0B1541A2A94C55268AA031540A
...    2A93555078A1202F012A05028140A05028140A05028140A05028140A0502800304040300601002004202004010080600C201002004040300
...    60100C018202018030080600C201002004040300601002004402018030080600C0201803040400802010020086A87C0004080C10181C282C
...    30344044484C5060646C70747C8494989CA0A4A8B4BD05060B40

@{expectNSAScellAddition}
...    pcid:51, scellIdx:9
...    SCellIndex 9 activated successfully at airphone

*** Test Cases ***
CB008247-ET-B02_B_B1_UE_specific_CSIRS_for_cell_8x4_CL-MIMO_t1r1_HO_reconfig_to_Cell_specific_CSIRS_target_cell_no_PSRS_NSA_UE
    [Documentation]
    ...    1. The purpose of this test case is to check following scenarios:
    ...         a.USCB008247-B#B1: UE specific CSI-RS allocation for cell with 8x4 CL-MIMO
    ...    2. Test Case Steps:
    ...         a.Attach NSA UE11 to NR cell2
    ...         b.Trigger A2 measurement report for UE11 ,Trigger A3 measurement report for UE1 to HO from cell2 to cell1
    ...         c.Trigger A2 measurement report for UE11 ,Trigger A3 measurement report for UE1 to HO from cell1 to cell2
    ...         d.Release all UEs' call
    ...    3. Expected Results:
    ...         Step a:NSA UE11 call setup successfully. 1(1port) Codebook SRS assigned,
    ...                  UE specific CSI-RS configured,1 CSI-RS resource added.
    ...         Step b:UE11 should HO from cell2 to cell1 successfully.No Codebook SRS resource assigned as actUlSrsBm disabled,
    ...                  no TAS SRS resource assigned as resource not available.Cell specific CSI-RS configured due to no psrs assigned.
    ...                  Amount of resources added is complied with UE cap.
    ...         Step c:UE11 should HO back successfully.1(1port) Codebook SRS assigned,
    ...                  UE specific CSI-RS configured.1 CSI-RS resource assigned for UE.
    ...         step d:UE call can be released successfully.
    [Tags]    QC_165721    alex.2.wang
    NSA UE attach    cell_id=2    target_cells=2
    Trigger HO from cell2 to cell1    source_cell_id=51    target_cell_id=50    measgap=True
    Trigger HO from cell1 to cell2    source_cell_id=50    target_cell_id=51    measgap=True
    Release ues    ue_type=all
    Check Logs    case=B02

CNI-92536-ET-A026_Verify_IntraGnb_CA_Scell_CSIRS_Allocate_and_multiplex_Successful_with_actPciBasedCsiImRandomization_DRX_On_when_Scell_Addition_NSA
    [Documentation]
    ...    1. The purpose of this test case is to check following scenarios:
    ...         Verify scell's CSIRS allocate and multiplexing successfully when perform scell addtion with actPciBasedCsiImTandomization as true
    ...         while DRX is on for NSA UE.
    ...    2. Test Case Steps:
    ...         a.Online modify CNI92536 needed parameters.
    ...            NRCELL:actCsirsMultiplexing=true
    ...            NRCELL:actPciBasedCsiImRandomization=true
    ...            NRCELL-1:actcdrx=true, drxProfile1:drxLongCycle=20ms, drxOnDurationTimer=4ms
    ...         b.Attach NSA UE12 to UE16 to NR cell1 and blind add scell.
    ...            start and verify traffic for UE12 to UE16 and stop traffic.
    ...         c.Check wireshark logs.
    ...         d.Release all UEs' call
    ...    3. Expected Results:
    ...         Step a:Parameters online modify successfully.
    ...         Step b:NSA UE 12 to 16 attached successfully and TDD CELL2 added as scell.
    ...                  Traffic can be start and stop successfuly. Total tput is expected.
    ...         Step c:1 CSIRS resource is allocated for scell successfully, nrofPorts is p4.
    ...                  firstOFDMSymbolinTimeDomain and slot of Scell's CSIRS resource
    ...                  should be the same for either two ues above.
    ...                  (slot 5, symbol 13 in this case).
    ...         step d:UE call can be released successfully.
    [Tags]    QC_301972    susana.yan    CNI-92536
    OnlineParamChange    ${OnlineParam_CNI92536}
    NSA 5 UEs CA blind scell add and traffic verify successfully
    Release ues    ue_type=all
    Check Wireshark Log    ${CURDIR}${/}a2a_CNI92536A026${/}a2a.ini    wait_string=UEContextRelease::40
#    [Teardown]    ParameterRecover_Teardown    ${OnlineParam_CNI92536_recover}

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri    ue_count=6

NSA UE attach
    [Arguments]    ${ue_id}=11    ${cell_id}=1    ${target_cells}=1
    Start RRC Log    NSA_UE${ue_id}_cell${cell_id}_attach
    Execute Egate Command    ue_attach id=${ue_id}    UE IS ACTIVE
    Execute Egate Command    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${target_cells} bearer=2 type=split_scg    successful RA
    Get RRC Log

NSA UE CA blind scell add and traffic verify successfully
    [Arguments]    ${ue_id}=12    ${target_cells}=1
    Execute Egate Command    ue_attach id=${ue_id}    UE IS ACTIVE
    Execute Egate Command    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${target_cells} bearer=2 type=split_scg
    ...    pass_regexp=${expectNSAScellAddition}
    Send and verify traffic    ue_id=${ue_id}

Send and verify traffic
    [Arguments]    ${ue_id}=12
    Send Throuput    ue_id=${ue_id}
    Verify Throuput on Pscell and Scell    ue_id=${ue_id}
    Stop Traffic    ue_id=${ue_id}

Send Throuput
    [Arguments]    ${ue_id}=12
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=dl mbps=150 trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=dl mbps=150 trf_id=3    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=dl mbps=150 trf_id=4    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=ul mbps=10 trf_id=1    UE ${ue_id}: UDP UL

Verify Throuput on Pscell and Scell
    [Arguments]    ${ue_id}=12    ${dl}=405    ${ul}=9
    sleep    15s     #sleep for stable traffic
    ${dl_throuput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=dl    dc_cell_group=all    rate_type=ave
    Should Be True    ${dl_throuput}/1000>${dl}
    ${ul_throuput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=ul    dc_cell_group=all    rate_type=ave
    Should Be True    ${ul_throuput}/1000>${ul}


Stop Traffic
    [Arguments]    ${ue_id}=12
    Execute Egate Command    trf_data_stop ue=${ue_id} id=2 dir=dl trf_id=2
    Execute Egate Command    trf_data_stop ue=${ue_id} id=2 dir=dl trf_id=3
    Execute Egate Command    trf_data_stop ue=${ue_id} id=2 dir=dl trf_id=4
    Execute Egate Command    trf_data_stop ue=${ue_id} id=2 dir=ul trf_id=1
    sleep    5s    #sleep to wait traffic stop

Check Logs
    [Arguments]    ${case}=A01
    Check RRC log    ${CURDIR}${/}a2a_${case}${/}a2a.ini

Modify Cfg
    Update Cfg    ue_param id=11 ue_nr_capabilities=${ue_nr_full_cap} dual_conn=eutra_nr ue_eutra_nr_capabilities=${ue11_MRDC_cap}
    Update Cfg    ue_param id=12 ue_nr_capabilities=${ue_nr_full_cap} dual_conn=eutra_nr ue_eutra_nr_capabilities=${ue11_MRDC_cap}
    Update Cfg    ue_param id=13 ue_nr_capabilities=${ue_nr_full_cap} dual_conn=eutra_nr ue_eutra_nr_capabilities=${ue11_MRDC_cap}
    Update Cfg    ue_param id=14 ue_nr_capabilities=${ue_nr_full_cap} dual_conn=eutra_nr ue_eutra_nr_capabilities=${ue11_MRDC_cap}
    Update Cfg    ue_param id=15 ue_nr_capabilities=${ue_nr_full_cap} dual_conn=eutra_nr ue_eutra_nr_capabilities=${ue11_MRDC_cap}
    Update Cfg    ue_param id=16 ue_nr_capabilities=${ue_nr_full_cap} dual_conn=eutra_nr ue_eutra_nr_capabilities=${ue11_MRDC_cap}
   ${gNB2_cell1_configuration}    catenate
    ...    set_cell id=1 gnb=2 pci=16:2 tac=200 nrci=0x01 tdd_cell=on proxy=10.0.2.80:9999|10.0.2.80:8888 nr_arfcn=633000:633000
    ...    gscn=7840 mandatory_for_activation=off
    update Cfg    ${gNB2_cell1_configuration}
    ${gNB2_cell2_configuration}    catenate
    ...    set_cell id=2 gnb=2 pci=17:0 tac=200 nrci=0x02 tdd_cell=on proxy=10.0.2.80:9999|10.0.2.80:8888 nr_arfcn=508020:508020
    ...    gscn=6351 mandatory_for_activation=off
    update Cfg    ${gNB2_cell2_configuration}
    Update Cfg    cell_srs_beam_pos_nr profile_id=1 num_of_ue_positions=4 azimuth=-45,30,25,60
    Update Cfg    cell_testmode_set_nr cell_id=1 gnb=2 testmode=cell_srs_beam_pos profile_id=1 action=activate
    Update Cfg    cell_testmode_set_nr cell_id=2 gnb=2 testmode=cell_srs_beam_pos profile_id=1 action=activate
    Update Cfg    enb_endc_param id=1 control_flow_period=3gpp1 use_nr_ran_cont=on serving_cell_index_range_scg=8:14

Trigger HO from cell2 to cell1
    [Arguments]    ${ue_id}=11    ${source_cell_id}=50    ${target_cell_id}=51    ${measgap}=False
    Start RRC Log    UE${ue_id}_HO_cell${source_cell_id}_to_cell${target_cell_id}
    ${cmd}=    Set Variable    ue_enb_param id=${ue_id} measurement_gap=gp0:0 mgta=ms0 gap_purpose=perUE gap_trigger=gnb_triggered
    Run Keyword if     ${measgap}==True    Execute Egate Command    ${cmd}
    ${a2_measid}    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=508110    event_type=A2
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${a2_measid} event=A2 srsrp_nr=11 srsrq_nr=11
    ...    Successfully reconfigured dual connectivity
    ${a3_measid}    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=632736    event_type=A3
    ${cmd_HO}=    catenate    ue_measurement_send_nr id=${ue_id} meas_id=${a3_measid} event=A3 srsrp_nr=11 srsrq_nr=11
    ...    phycell_id=${target_cell_id} nrsrp_nr=50 nrsrq_nr=50
    Execute Egate Command    ${cmd_HO}    Successfully reconfigured dual connectivity
    Get RRC Log

Trigger HO from cell1 to cell2
    [Arguments]    ${ue_id}=11    ${source_cell_id}=50    ${target_cell_id}=51    ${measgap}=False
    Start RRC Log    UE${ue_id}_HO_cell${source_cell_id}_to_cell${target_cell_id}
    ${cmd}=    Set Variable    ue_enb_param id=${ue_id} measurement_gap=gp0:0 mgta=ms0 gap_purpose=perUE gap_trigger=gnb_triggered
    Run Keyword if     ${measgap}==True    Execute Egate Command    ${cmd}
    ${a2_measid}    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=632736    event_type=A2
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${a2_measid} event=A2 srsrp_nr=11 srsrq_nr=11
    ...    Successfully reconfigured dual connectivity
    ${a3_measid}    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=508110    event_type=A3
    ${cmd_HO}=    catenate    ue_measurement_send_nr id=${ue_id} meas_id=${a3_measid} event=A3 srsrp_nr=11 srsrq_nr=11
    ...    phycell_id=${target_cell_id} nrsrp_nr=50 nrsrq_nr=50
    Execute Egate Command    ${cmd_HO}    Successfully reconfigured dual connectivity
    Get RRC Log

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir

ParameterRecover_Teardown
    [Arguments]    ${OnlineParam_recover}
    OnlineParamChange    ${OnlineParam_recover}
    Cells Should Be OnAir
    Common Test Teardown And Stop Capture Logs

NSA 5 UEs CA blind scell add and traffic verify successfully
    FOR    ${index}    IN RANGE    12    17
        NSA UE CA blind scell add and traffic verify successfully    ue_id=${index}
    END
