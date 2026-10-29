*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_VRF    RAN_5G    RAN_5G_TDD    SBTS00    CRT    CLOUD_5G_I_LO_AP_LO
...            owner-ruifang.zhu    team-CN1ET    release-SBTS24R2
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{enableBeamforming}
...    @{srsConfig}
...    @{CB008322}
...    @{PARAMS_FOR_VoNR}
...    @{CAparam}
...    @{csiparam}
...    NRCELL-1:chBw=80MHz
...    NRCELL-2:chBw=80MHz
...    NRCELL-1:physCellId=50
...    NRCELL-2:physCellId=51
...    NRCELL-2:nrarfcn=643334
...    NRCELL-2:gscnOrSsPbchArfcn=7950
...    NRCELL:msg1FrequencyStart=14
...    @{PARAMS_FOR_9059}
...    @{PARAMS_FOR_5QI71}
...    @{overheating}
...    @{2271_related_modification}
...    @{9109}

@{enableBeamforming}
...    NRCELL:beamSet:nrBtsBeamRefinementP2=true
...    NRCELL:beamSet:basicBeamSet=beamSet_6
...    NRCELL:numberOfRxBeamforming=6Rx
...    NRCELL:actBeamforming=true
...    NRCELL:mMimoAntArrayMode=Full 64TRX Array (4x8x2)
...    NRCELL:dlMimoMode=4x4 or 4x2 Closed Loop Spatial Multiplexing
...    NRCELL:nrCellType=8DL4UL
...    NRCELL:beamSet:lowerEdgeAngle=120
...    NRCELL:beamSet:upperEdgeAngle=60
...    NRCELLGRP-0:numberOfTransmittedSsBlocks=6 beams
...    NRCELLGRP-1:numberOfTransmittedSsBlocks=6 beams

@{srsConfig}
...    NRPMRNL-1:miNrNgcFlexInterface=disabled
...    NRPMRNL-1:miNrIntraGnbMobilitySaPmqap=disabled
...    NRPMRNL-1:miNrIntraGnbMobilityNsaPmqap=disabled
...    NRPMRNL-1:miNrInterGnbXnMobilitySaPmqap=disabled
...    NRPMRNL-1:miNrInterGnbNgMobilitySaPmqap=disabled
...    NRPMRNL-1:miNrInterGnbMobilityNsaPmqap=disabled
...    NRCELL:actUlSrsBm=true
...    NRCELL:actDlSrsBm=true
...    NRCELL:srsForBeamMgmt:srsTypeAllocForDlBm=antenna switching or codebook
...    NRCELL:srsForBeamMgmt:comb=comb2
...    NRCELL:msg1FrequencyStart=18
...    NRCELL:wbSbSrsSwitch:channelStabilityHysteresis=100
...    NRCELL:wbSbSrsSwitch:channelStabilityThreshold=30
...    NRCELL:wbSbSrsSwitch:enableSbSrsVolatilityCheck=false
...    NRCELL:wbSbSrsSwitch:maxWbSbSwitch=10
...    NRCELL:wbSbSrsSwitch:numWbSrsConfigSample=10
...    NRCELL:wbSbSrsSwitch:numWbSrsReleaseSample=10
...    NRCELL:wbSbSrsSwitch:prbRatioHysteresis=15
...    NRCELL:wbSbSrsSwitch:prbRatioThreshold=1
...    NRCELL:wbSbSrsSwitch:prbSampleHighLowPercentage=60
...    NRCELL:wbSbSrsSwitch:rankHysteresis=4
...    NRCELL:wbSbSrsSwitch:rankThreshold=1
...    NRCELL:wbSbSrsSwitch:rlqBadPercentage=50
...    NRCELL:wbSbSrsSwitch:rlqGoodPercentage=20
...    NRCELL:wbSbSrsSwitch:seHysteresis=100
...    NRCELL:wbSbSrsSwitch:seThreshold=1
...    NRCELL:wbSbSrsSwitch:sortingMetric=DL Spectral Efficiency
...    NRCELL:wbSbSrsSwitch:wbSrsConfigProhibitTimer=100
...    NRCELL:wbSbSrsSwitch:wbSrsPowerHysteresis=100
...    NRCELL:wbSbSrsSwitch:wbSrsPowerThreshold=-1160
...    NRCELL:wbSbSrsSwitch:wbSrsReleaseProhibitTimer=1000
...    NRCELL-1:srsForBeamMgmt:srsUePeriodicity=slots40
...    NRCELL-1:srsForBeamMgmt:cSRS=49
...    NRCELL-1:srsForBeamMgmt:bSRS=2
...    NRCELL-1:srsForBeamMgmt:srsPowerThresholdForDlBm=-1280
...    NRCELL-1:srsForBeamMgmt:srsPowerThresholdForUlBm=-1200
...    NRCELL-2:srsForBeamMgmt:srsUePeriodicity=slots20
...    NRCELL-2:srsForBeamMgmt:cSRS=49
...    NRCELL-2:srsForBeamMgmt:bSRS=2
...    NRCELL-2:srsForBeamMgmt:srsPowerThresholdForDlBm=-1280
...    NRCELL-2:srsForBeamMgmt:srsPowerThresholdForUlBm=-1200
#1208 Frame Structure
...    NRCELL:tddFrameStructure:frameStructureType=semiStatic
...    NRCELL:tddFrameStructure:ulDlDataSlotRatio=1/4
...    NRCELL:tddFrameStructure:guardPeriodLength=2Symbols

@{CB008322}
...    NRBTS:actCarrierAggregation=false
...    NRBTS:actCoverageNonCoherentUes=false
...    NRBTS:actFdmScheduling=true
...    NRDU-1:actInterNumerologyCa=false
...    NRCELLGRP-0:ssBurstSetPeriod=20
...    NRCELLGRP-1:ssBurstSetPeriod=20
...    NRCELL:pucchModeSelect=longPucch
...    NRCELL:actCDrx=false
...    NRCELL:beamSet:nrBtsBeamRefinementP2=true
...    NRCELL:actDl256Qam=true
...    NRCELL:actPdschAtSsbSlots=false
...    NRCELL-1:chBw=80MHz
...    NRCELL:ulMimoMode=Closed loop Spatial Multiplexing (2x2)
...    NRCELL:numberOfRxBeamforming=4Rx
...    NRCELL:actBeamforming=true
...    NRCELL:mMimoAntArrayMode=Full 64TRX Array (4x8x2)
...    NRCELL:actCsirsMultiplexing=false
...    NRCELL:actDlSrsSubbandBm=true
...    NRCELL:srsForSubbandBm:bfSubbandSize=16 PRBs
...    NRCELL:srsForSubbandBm:maxNumUeSrs=4
...    NRCELL:srsForSubbandBm:srsPowerThreshold=-1350

@{PARAMS_FOR_VoNR}
...    NRBTS:actNormVCFallback=false
...    NRULCLPC_PROFILE-1:nrUlClpcProfileId=1
...    NRCELL:actVoNR=true
...    NRCELL:actEnhancedVoNR=true
...    NRCELL:actAdaptVoipTbs=true
...    NRCELL:actCDrx=true
...    NRCELL:actCDrxVoNR=true
...    NRCELL:actUlClosedLoopPwrCtrl=puschSrs
...    NRCELL:nrUlClpcProfileDN=NRULCLPC_PROFILE-1
...    NRCELL:srPeriodicity=slots40
...    NRCELL:actVoipPacketAggr=true
...    @{PARAMS_FOR_5QI5}
...    @{PARAMS_FOR_5QI1}

@{PARAMS_FOR_5QI5}
...    NRBTS/NRDRB_5QI-1:fiveqiValueList=5
...    NRBTS/NRDRB_5QI-1:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-10
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

@{PARAMS_for_UlTxSkip}
...    NRCELL:actUlTxSkip=true
...    NRCELL:payloadSizeProactiveTxSkip=80
...    NRCELL:ulSchedTimeIntervalTxSkip=150
...    NRCELL:ulProGrantTimerTxSkip=1200
...    NRCELL:ulProGrantTimer=10

@{PARAMS_for_Recover_UlTxSkip}
...    NRCELL:actUlTxSkip=false

@{CAparam}
...    NRBTS:maxNumScellsDl=2
...    NRBTS:maxNumScellsUl=2
...    NRDU-1:carrierAggregationSupportList=ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Any_Sa,ca_Fdd_Any_Sa,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Fdd
...    NRBTS:caConfigurationSupport=4CCDL_2CCUL
...    NRCELL:allowUnsuppBcOrBcs=accept unknown band combinations
...    NRCELL:actK1Opt=intraAndInter-gNB
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRBTS:actCarrierAggregation=true
...    NRBTS:actCoverageNonCoherentUes=false
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRDU-1:actInterNumerologyCa=true
...    NRBTS:sCellActivationMethod=bufferBased
...    NRCELL:sCellDeactivationTimerGNB=infinity
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRCELL:a2MeasSCellRelEnabled=rsrp
...    NRCELL:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0
...    NRCELL:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=30
...    NRCELL:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=480ms
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-1:gNbId=1
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-1:lcrId=2
...    NRCELL-1/NRREL-1:removeNotAllowed=false
...    NRCELL-1/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-1:sCellOperationalMode=dlOnly
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
...    NRCELL-2/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-2/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-2/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL:a1MeasSCellAddEnabled=rsrp
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=31
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=70
...    NRCELL:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=2
...    NRCELL:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms

@{csiparam}
...    NRBTS/NRCELL:actCsirsMultiplexing = false
...    NRBTS/NRCELL:actUeCsirsCoexistCellCsirs=true
...    NRCELL:ssPbchBlockPower=0
...    NRCELL:periodicCsiAcquisition:csiReportPeriodicity=slots320

@{PARAMS_FOR_9059}
...    NRBTS-1/NRDRB-10:cellAggrLevel=FR1 CA eligible
...    NRBTS-1/NRDRB-11:cellAggrLevel=FR1 CA eligible
...    NRBTS-1/NRDRB-12:cellAggrLevel=Not FR1 CA eligible
...    NRBTS-1/NRDRB-13:cellAggrLevel=FR1 CA incompatible
...    NRBTS-1/NRDRB-14:cellAggrLevel=FR1 CA incompatible
...    NRBTS-1:actDrbProfileForCellAggrLevel=FR1_SA

@{PARAMS_FOR_5QI71}
...    NRCELL:actNonVoNRGbrService=true
...    NRCELL:maxGBRTrafficLimit=12
...    NRCELL:pucchModeSelect=longPucch
...    NRCELL:actGBRAdmissionControl=GBRService
...    NRBTS/NRULCG_PROFILE-7:grantedPacketSize=3000
...    NRBTS/NRULCG_PROFILE-7:maxNumPrbs=20
...    NRBTS/NRULCG_PROFILE-7:periodicity=ms20
...    NRCELL:actVoNR=true
...    NRBTS:actNormVCFallback=false
...    NRBTS/NRDRB_5QI-71:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-17
...    NRBTS/NRDRB_5QI-71:fiveqiValueList=71
...    NRBTS/NRDRB_5QI-6:fiveqiValueList=1
...    NRBTS/NRDRB_5QI-6:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-15
...    NRBTS/NRDRB-17:actDddsReduction=false
...    NRBTS/NRDRB-17:actDlTxResumeOnPdcpStatRep=false
...    NRBTS/NRDRB-17:actLostPduFastRetx=false
...    NRBTS/NRDRB-17:caPduReSendingDelayMargin=2
...    NRBTS/NRDRB-17:discardTimer=100ms
...    NRBTS/NRDRB-17:dlAllowMinDelayLinkXxCalib=false
...    NRBTS/NRDRB-17:dlFlowControlAlgo=3gppFlowControl
...    NRBTS/NRDRB-17:dscp=46
...    NRBTS/NRDRB-17:durationThresDiscardDl=50
...    NRBTS/NRDRB-17:durationThresDiscardUl=20
...    NRBTS/NRDRB-17:endMarkerTimer=2000
...    NRBTS/NRDRB-17:maxDataRateGbrDl=30720
...    NRBTS/NRDRB-17:maxDataRateGbrUl=30720
...    NRBTS/NRDRB-17:maxDddsPeriodCpuOvld=40
...    NRBTS/NRDRB-17:maxRlcQueueingDelayGbr=20
...    NRBTS/NRDRB-17:maxTransferDelayGbr=20
...    NRBTS/NRDRB-17:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-5
...    NRBTS/NRDRB-17:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-3
...    NRBTS/NRDRB-17:nrDrbRlcAmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_AM-2
...    NRBTS/NRDRB-17:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRBTS/NRDRB-17:numSduDiscard=1
...    NRBTS/NRDRB-17:queuingDelayDiscarding=Disabled
...    NRBTS/NRDRB-17:queuingDelaySduDiscardThreshold=750
...    NRBTS/NRDRB-17:resType=GBR
...    NRBTS/NRDRB-17:rlcMode=RLC_AM
...    NRBTS/NRDRB-17:rlcPduDelayThCa=30
...    NRBTS/NRDRB-17:schedulWeight=1
...    NRBTS/NRDRB-17:sduDiscardIntervalTmr=500
...    NRBTS/NRDRB-17:volThresDiscardDl=8000
...    NRBTS/NRDRB-17:volThresDiscardUl=800
...    NRBTS/NRDRB-17:l2OHFactorDl=16
...    NRBTS/NRDRB-17:l2OHFactorUl=35
...    NRBTS/NRDRB-17:nrDrbUlCgDN=MRBTS-1/NRBTS-1/NRULCG_PROFILE-7
...    NRBTS/NRDRB-17:cellAggrLevel=FR1 CA incompatible
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
...    NRBTS/NRDRB_MAC-4:lcgid=0
...    NRBTS/NRDRB_MAC-4:delayTarget=50
...    NRBTS/NRDRB_MAC-4:prioritisedBitRate=16kBps
...    NRBTS/NRDRB_MAC-4:schedulBSD=100ms
...    NRBTS/NRDRB_MAC-4:schedulPrio=4
...    NRBTS/NRDRB_MAC-5:lcgid=5
...    NRBTS/NRDRB_MAC-5:delayTarget=50
...    NRBTS/NRDRB_MAC-5:prioritisedBitRate=16kBps
...    NRBTS/NRDRB_MAC-5:schedulBSD=100ms
...    NRBTS/NRDRB_MAC-5:schedulPrio=6
...    NRBTS/NRDRB_PDCP-3:cuFlowControlProfId=1
...    NRBTS/NRDRB_PDCP-3:pdcpBufDiscardEnabled=false
...    NRBTS/NRDRB_PDCP-3:pdcpBufDiscardThreshold=20000
...    NRBTS/NRDRB_PDCP-3:pdcpDelayThreshRetxMode=disabled
...    NRBTS/NRDRB_PDCP-3:tReorderingDl=ms80
...    NRBTS/NRDRB_PDCP-3:tReorderingUl=ms80
...    NRBTS/NRDRB_PDCP-3:xxFlowControlProfForCuIdx=1
...    NRBTS/NRDRB_RLC_UM-1:dlTReassemblyUm=ms50
...    NRBTS/NRDRB_RLC_UM-1:rlcUMDrbSNLength=rlcUm12bitSN
...    NRBTS/NRDRB_RLC_UM-1:ulTReassemblyUm=ms50
...    NRBTS/NRDRB_RLC_AM-2:dlTReassembly=ms15
...    NRBTS/NRDRB_RLC_AM-2:dlTReassemblyIBCA=30
...    NRBTS/NRDRB_RLC_AM-3:dlTReassembly=ms20
...    NRBTS/NRDRB_RLC_AM-3:dlTReassemblyIBCA=40
...    NRBTS/NRDRB_5QI-72:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-18
...    NRBTS/NRDRB_5QI-72:fiveqiValueList=72
...    NRBTS/NRDRB-18:actDddsReduction=false
...    NRBTS/NRDRB-18:actDlTxResumeOnPdcpStatRep=false
...    NRBTS/NRDRB-18:actLostPduFastRetx=false
...    NRBTS/NRDRB-18:caPduReSendingDelayMargin=2
...    NRBTS/NRDRB-18:discardTimer=100ms
...    NRBTS/NRDRB-18:dlAllowMinDelayLinkXxCalib=false
...    NRBTS/NRDRB-18:dlFlowControlAlgo=3gppFlowControl
...    NRBTS/NRDRB-18:dscp=46
...    NRBTS/NRDRB-18:durationThresDiscardDl=50
...    NRBTS/NRDRB-18:durationThresDiscardUl=20
...    NRBTS/NRDRB-18:endMarkerTimer=2000
...    NRBTS/NRDRB-18:maxDataRateGbrDl=30720
...    NRBTS/NRDRB-18:maxDataRateGbrUl=30720
...    NRBTS/NRDRB-18:maxDddsPeriodCpuOvld=40
...    NRBTS/NRDRB-18:maxRlcQueueingDelayGbr=20
...    NRBTS/NRDRB-18:maxTransferDelayGbr=20
...    NRBTS/NRDRB-18:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-5
...    NRBTS/NRDRB-18:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-3
...    NRBTS/NRDRB-18:nrDrbRlcAmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_AM-2
...    NRBTS/NRDRB-18:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRBTS/NRDRB-18:numSduDiscard=1
...    NRBTS/NRDRB-18:queuingDelayDiscarding=Disabled
...    NRBTS/NRDRB-18:queuingDelaySduDiscardThreshold=750
...    NRBTS/NRDRB-18:resType=GBR
...    NRBTS/NRDRB-18:rlcMode=RLC_AM
...    NRBTS/NRDRB-18:rlcPduDelayThCa=30
...    NRBTS/NRDRB-18:schedulWeight=1
...    NRBTS/NRDRB-18:sduDiscardIntervalTmr=500
...    NRBTS/NRDRB-18:volThresDiscardDl=8000
...    NRBTS/NRDRB-18:volThresDiscardUl=800
...    NRBTS/NRDRB-18:l2OHFactorDl=16
...    NRBTS/NRDRB-18:l2OHFactorUl=35
...    NRBTS/NRDRB-18:nrDrbUlCgDN=MRBTS-1/NRBTS-1/NRULCG_PROFILE-7
...    NRBTS/NRDRB-18:cellAggrLevel=Not FR1 CA eligible
...    NRBTS-1/NRDRB-17:srPeriodicityDrb=10ms
...    NRBTS-1/NRDRB-11:srPeriodicityDrb=10ms
...    NRBTS-1/NRDRB-12:srPeriodicityDrb=5ms
...    NRBTS-1/NRDRB-12:nrDrbRlcAmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_AM-3
...    NRBTS-1/NRDRB-13:srPeriodicityDrb=20ms
...    NRBTS-1/NRDRB-13:nrDrbRlcAmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_AM-3

@{overheating}
...    NRBTS:timerPostOverheating=10
...    NRBTS:actOverheatingAssistance=true
...    NRBTS:timerOverheatIndProhibit=1s

@{2271_related_modification}
...    NRCELL:actAdaptiveSr=true
...    NRCELL:actServiceAwareConfig=true
...    NRCELL:adaptiveSrBlockingMinimization=20
...    NRCELL:adaptiveSrLoadThresholdDown=50
...    NRCELL:adaptiveSrLoadThresholdUp=80
...    NRCELL:srPeriodicityMin=slots20
...    NRCELL:srPeriodicity=slots40
...    NRCELL:vonrReservation=30
...    NRCELL:preferredVoNrSrPeriod=slots40

@{9109}
...    NRBTS:actDrbDrx=true
...    NRBTS/NRDRB-17:nrDrxDN=MRBTS-1/NRBTS-1/NRDRX-0
...    NRBTS/NRDRB-18:nrDrxDN=MRBTS-1/NRBTS-1/NRDRX-0
...    NRBTS/NRDRB-15:nrDrxDN=MRBTS-1/NRBTS-1/NRDRX-2
...    NRBTS/NRDRX-1:drxInactivityTimer=40ms
...    NRBTS/NRDRX-1:drxLongCycle=80ms
...    NRBTS/NRDRX-1:drxOnDurationTimer=60ms
...    NRBTS/NRDRX-1:drxRetransTimerDl=16slot
...    NRBTS/NRDRX-1:drxRetransTimerUl=16slot
...    NRBTS/NRDRX-2:drxInactivityTimer=6ms
...    NRBTS/NRDRX-2:drxOnDurationTimer=20ms

${rdSrsCodebookAndTas}    0x590103
${rdMinSrsUePeriodicity}    0x5901E6
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

@{PARAMS_IN_SWCONFIG}
...    ${rdSrsCodebookAndTas}=2
...    ${rdMinSrsUePeriodicity}=40
...    ${rdSubBandSectorNumber}=3
...    ${rdSrsAllocMethod}=0
...    ${rdMaxSrsResPerSpecialSym1208}=10
...    ${rdMaxSrsResPerSpecialSym1116}=10
...    ${rdMaxSrsResPerSpecialSym1070}=10
...    ${rdMaxSrsResPerSym1208}=11
...    ${rdMaxSrsResPerSym1116}=11
...    ${rdMaxSrsResPerSym1070}=11
...    ${rdSubbandBfMethod}=0
...    ${rdEnableSrsSwitchScheduler}=1
...    ${rdNumSrsCheck}=100
#CB009496 flag
...    0x600013=1     #9496 BOAM_RAT_ADAPT
...    0x19040F=1     #9496 BOAM_FRONTHAUL
...    0x88004b=0     #L1FH rdEnableSktMvp, 0 for 9496; 1 for SKTMVP
...    0x880031=14    #L1FH rdBwvTxOpportunities, 14 for 9496; 3 for SKTMVP
...    0x58026F=0
...    0x800087=0
...    0x580717=1
...    0x590246=0     #9109 DU
...    0x890076=0     #9109 CU

${ERadParam_EnableSrsBasedBeamForming}    0x70690

@{PARAMS_IN_SWCONFIG_AP}
...    ${ERadParam_EnableSrsBasedBeamForming}=1

@{PM_Counters_AB08}
...    NRCELL-1:${DL_RRC_FSCELL_REL_ATT_SA}=4
#M55118C00042
...    NRCELL-1:${DL_RRC_FSCELL_REL_SUC_SA}=4
#M55118C00043
...    NRCELL-1:${SCELL_ADDN_ALLOW_DRB_PRFL_CA}=4
#M55125C00039
#This counter shows the number of times SCell addition is allowed for a UE due to data radio bearer (DRB) profile-based Carrier Aggregation.
...    NRCELL-1:${SCELL_ADDN_PREVENT_DRB_PRFL_CA}=2
#M55125C00040
#This counter shows the number of times SCell addition is prevented for a UE due to data radio bearer (DRB) profile-based Carrier Aggregation.
...    NRCELL-1:${INCMP_DRB_STP_REL_SCELL_ATT_SA}=2
#M55118C00034
...    NRCELL-1:${INCMP_DRB_STP_REL_SCELL_SUC_SA}=2
#M55118C00035
...    NRCELL-1:${ELIGIBLE_DRB_REL_SCELL_ATT_SA}=2
#M55118C00036
...    NRCELL-1:${ELIGIBLE_DRB_REL_SCELL_SUC_SA}=2
#M55118C00037

${DL_RRC_FSCELL_REL_ATT_SA}    M55118C00042
${DL_RRC_FSCELL_REL_SUC_SA}    M55118C00043
${SCELL_ADDN_ALLOW_DRB_PRFL_CA}    M55125C00039
${SCELL_ADDN_PREVENT_DRB_PRFL_CA}    M55125C00040
${INCMP_DRB_STP_REL_SCELL_ATT_SA}    M55118C00034
${INCMP_DRB_STP_REL_SCELL_SUC_SA}    M55118C00035
${ELIGIBLE_DRB_REL_SCELL_ATT_SA}    M55118C00036
${ELIGIBLE_DRB_REL_SCELL_SUC_SA}    M55118C00037

#BAND78: t1r4-t2r4 maxNumberSRS-Ports-PerResource=n2, n78(2A): t1r2 maxNumberSRS-Ports-PerResource=n1
${ue_nr_cap_SA_UE1}    SEPARATOR=
...    F9A09000575F7A13160003C5200016080080C0498B800CE1E858026C830E7CC31E50B038260300C47006A8D89BAC1184341020E908800FAD9
...    71563439F11C7A067D813E33238F21CFA067D813EA39F30C7942C0E070F170005F001C0017C001D200007001B280002800003A8D85181AC11
...    84341020E908800FAD971563439F11C7A067D813E33238F21CFA067D813EA39F30C7942C0E070F170005F001C0017C001D000007001860E14
...    0400000E30F0A000309A00010E30F0A000305000020E30E0A00E268000030E307134200000718789A00184D00010B80180510134740002281
...    A044D8E7C3851236C73E1C28913639F0E14E8DB1CF870236C73E1C28103639F0C0F4230003E0028101401C0C02500700060108423E1380200
...    000001000002008000000040000080200000801000006008000040040000280200100401004000030020000180100000E0080000700400200
...    00000800008004002018060080000900400005002001010040040020380E0080000B925002060185C92800030B92500606018060185C92802
...    0300C030B92500C060180601806018061724A0100C0300C0300C2E49403818060180601806018061704A0000C2E494000189C928010300C4E
...    49401018060189C12800031392500E060180601806018060189C928030300C0300C4E494000181C928070300C0300C0300C0300C0E4940181
...    806018060704A0000C0C0100001A06F2A6B2A6B2A6B032B036B066B296B266B016B012B022B236B748CA9A0682000012CA48080000CB29202
...    000052CA4A080001CB29202000092CA48080002CB292020000D2CA48080003CB29202000112CA48080004CB29202000152CA48080005CB292
...    8200818064B29282000192CA4A062954552A8BA55574AA2A82C55038AA0D154A62A93455018AA051548EAABB503C017C09E8140A05028140A
...    05028140A05028140A05028140A05028140A05028140A05028140A05028140A05028140A050000600101C00C20200C0180803006101006004
...    04008010808030060200C018D50300008101820303A1C35A0

@{pass_pdu1_add_71}
...    sCellToReleaseList
...    Added QosFlow with QFI:3 fiveQI:71
...    QoS Routing Table

@{pass_pdu1_add_72}
...    drx-Config release : NULL
...    Added QosFlow with QFI:4 fiveQI:72
...    QoS Routing Table

@{pass_pdu1_Modify_8}
...    Added QosFlow with QFI:4 fiveQI:8
...    QoS Routing Table

@{pass_pdu1_del_8_71}
...    Removed FiveQi:Qfi mapping fiveQi 8 qfi 4
...    Removed FiveQi:Qfi mapping fiveQi 71 qfi 3
...    sCellToAddModList
...    drx-Config setup

@{pass_pdu1_del_6_72}
...    sCellToReleaseList
...    Removed FiveQi:Qfi mapping fiveQi 6 qfi 1
...    Removed FiveQi:Qfi mapping fiveQi 72 qfi 4
...    drx-Config setup


*** Test Cases ***
CB009059-ET-AB08_CA and PDU session modification with DRB modification
    [Documentation]
    ...    1. The purpose of this test case is to check following scenarios:
    ...     This user scenario describes the gNB behaviour when AMF requests simultaneous DRB addition of an incompatible
    ...     DRB and DRB modification for 5QI-5 QoS Flow modification to change the ARP or GFBR information and
    ...     DRX interworking
    ...     At least 5 NRBTS/NRDRB MOC instances are configured as non-GRB types:
    ...     NRDRB ID resType Value RLC Mode cellAggrLevel Value
    ...     1 non-GBR(5QI-6) AM 0:FR1 CA eligible
    ...     2 non-GBR AM 1:Not FR1 CA eligible
    ...     3 non-GBR AM 2:FR1 CA incompatible
    ...     4 GBR(5QI-71) AM 2:FR1 CA incompatible
    ...     5 GBR(5QI-72) AM 1:Not FR1 CA eligible
    ...    2.Test Case Steps:
    ...     Step A. UE attaches to Cell-1 and the gNB establishes 1 PDU session with 2 DRBs(NRDRB-1, NRDRB-2 )
    ...     Step B. AMF sends the NGAP: PDU SESSION RESOURCE MODIFY REQUEST to add NRDRB-4 message to the gNB
    ...     Step C. AMF sends NGAP: PDU Session Resource Modify Request to gNB-CU-CP containing NRDRB-3 addition
    ...     (1 incompatible DRB) and DRB modification (modify QoSInformation for NRDRB-4).
    ...     Step D. AMF sends the NGAP: PDU SESSION RESOURCE MODIFY REQUEST to delete NRDRB-3 and NRDRB-4 message
    ...     Step E. AMF sends the NGAP: PDU SESSION RESOURCE MODIFY REQUEST to add NRDRB-5 message to the gNB
    ...     Step F. AMF sends NGAP: PDU Session Resource Modify Request to gNB-CU-CP containing NRDRB-5 modification
    ...     (modify QosFlowAddOrModifyRequestItem->QosFlowLevelQosParameters->Allocation and Retention Priority)
    ...     Step G. AMF sends the NGAP: PDU SESSION RESOURCE MODIFY REQUEST to delete NRDRB-2 and NRDRB-5 message
    ...     Step H. Release UE.
    ...     Step I. online change actUlTxSkip=true and related configuration
    ...     Step J. repeat steps A-H
    ...     Step K. Check counters
    ...    3. Expected Results:
    ...     Step A. DRBs setup successfully, The gNB configures the UE with 2CC DL CA with Cell-2 as SCell,
    ...             DRB-1 non-GBR DL data is scheduled on the PCell and SCell. DRB-2 DL non-GBR data is scheduled only
    ...             on the PCell. check dlTReassemblyIBCA of dl-AM-RLC for eligible DRB, subband SRS trigger
    ...             (nrofSRS-Port=port1, cSRS=49,bSRS=2), DRX setup, schedulingRequestResourceToAddModList,
    ...             OverheatingAssistanceConfig setup, macCellGroupConfig->skipUplinkTxDynamic=false.
    ...     Step B. non-VONR GBR is established, scell release due to incompatible DRB,drxConfig release,
    ...             overheatingAssistanceConfig release, check t-reassembly=corresponding DRB dl-AM-RLC=dlTReassembly,
    ...             wideband SRS trigger(nrofSRS-Port=portf2, cSRS=51,bSRS=0,fake setup DRX, longcycle=onduration=80ms)
    ...     Step C. DRB Add, DRB Modify successfully
    ...     Step D. incompatible DRB released and scell addition trigger with 2CC DL CA with Cell-2 as SCell,
    ...             subband SRS trigger(nrofSRS-Port=port1, cSRS=49,bSRS=2), DRX setup, OverheatingAssistanceConfig setup
    ...     Step E. non-VONR GBR Not Eligible DRBs setup successfully, CA remains, DRX release
    ...     Step F. DRB Modify successfully,UE remains in CA mode.
    ...     Step G. Eligible DRB and non-VONR GBR Not Eligible DRB release, CA release, OverheatingAssistanceConfig
    ...             release,DRX setup
    ...     Step H. UE is released successful
    ...     Step I. no pdl error
    ...     Step J. repeat step A-H successful and check the macCellGroupConfig->skipUplinkTxDynamic=true
    ...     Step K. Check counters successful
    [Tags]    AB08    QC_46717    AP_REG
    clear counter files    wait=${False}
    Verify CA and PDU session modification with DRB modification for 5QI71
    Verify CA and PDU session modification with DRB modification for 5QI72
    online param change    ${PARAMS_for_UlTxSkip}
    Verify CA and PDU session modification with DRB modification for 5QI71
    Verify CA and PDU session modification with DRB modification for 5QI72
    Check Wireshark Log    ${CURDIR}${/}A2A_AB08${/}a2a.ini    wait_string=UEContextReleaseComplete::8
    Check Counters    pm_counters_expression=${PM_Counters_AB08}
    [Teardown]    AB08_Teardown

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Install eNB Package via WEBEM
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri_AQQL    ue_count=5

Install eNB Package via WEBEM
    [Arguments]    ${bsr_name}=BSR_AQQL_6_H6_ALN60_ARP60_P11_COVERAGE_00776_00001.zip    ${bsr_path}=/home/ute/bsr_package
    Execute Cmd On Pc    rm -rf ${bsr_path}
    Execute Cmd On Pc    mkdir ${bsr_path}
    Execute Cmd On Pc    git clone https://wrgitlab.ext.net.nokia.com/y165zhan/bsr_package ${bsr_path}
    update_software    sw_package=${bsr_path}/${bsr_name}    timeout=60

AB08_Teardown
    online param change    ${PARAMS_for_Recover_UlTxSkip}
    Common Test Teardown And Stop Capture Logs

Verify CA and PDU session modification with DRB modification for 5QI71
    SA UE attach    ue_id=1    cell_id=1
    Send Traffic SA    qfi_id=1
    Send Traffic SA    qfi_id=2
    Verify UE status after ADD QOS in same pdu    qos_id=10    pass_regexp=${pass_pdu1_add_71}
    set SRS power
    Verify UE status after add and modify QOS in same pdu    qos_id=10    pass_regexp=${pass_pdu1_Modify_8}
    Verify UE status after del QOS in same pdu    qos_id=3,10    pass_regexp=${pass_pdu1_del_8_71}

Verify CA and PDU session modification with DRB modification for 5QI72
    set SRS power
    Verify UE status after ADD QOS in same pdu    qos_id=11    pass_regexp=${pass_pdu1_add_72}
    Verify UE status after modify QOS in same pdu    qos_id=11
    Verify UE status after del QOS in same pdu    qos_id=1,11    pass_regexp=${pass_pdu1_del_6_72}
    Release ues    ue_type=all

SA UE attach
    [Arguments]    ${ue_id}=1    ${cell_id}=1    ${pdu_id}=1
    reset SRS power
    Execute Egate Command    ue_change_location id=${ue_id} cell=${cell_id} enb=2
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Registered state.
    set SRS power
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    smf_param id=1 additional_qosflows_to_activate=2
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=${ue_id} nwslice=1    pass_regexp=Initial Context Setup Successful

set SRS power
    ${cmd}    catenate    ul_mimo_srs_beam_pos_nr profile_id=1 mode=fixed init_quad_pos=1 init_sub_quad_pos=1 test_type=SRS
    ...    multi_path_config=true num_of_nlos_paths=1 azimuth=30 zenith=0 srs_transmit_power_per_port=-200,-200,-200,-200
    Execute Egate Command    ${cmd}
    Execute Egate Command    ue_testmode_set_nr id=1 testmode=ul_mimo_srs_beam_pos action=activate profile_id=1

reset SRS power
    ${cmd}    catenate    ul_mimo_srs_beam_pos_nr profile_id=1 mode=fixed init_quad_pos=1 init_sub_quad_pos=1 test_type=SRS
    ...    multi_path_config=true num_of_nlos_paths=1 azimuth=30 zenith=0 srs_transmit_power_per_port=--145,-145,-145,-145
    Execute Egate Command    ${cmd}
    Execute Egate Command    ue_testmode_set_nr id=1 testmode=ul_mimo_srs_beam_pos action=activate profile_id=1

Modify Cfg
    Update Cfg    ue_param id=1 ue_nr_capabilities=${ue_nr_cap_SA_UE1}
    ${SRS1}    catenate    set_cell id=1 gnb=2 nr_arfcn=636666:636666 gscn=7880 eci=0x000021f pci=16:2 tac=200
    ...    proxy=$PROXY_SERVER_IP:9999|$PROXY_SERVER_IP:8888 nrci=0x01 tdd_cell=on mandatory_for_activation=off
    Update Cfg    ${SRS1}
    ${SRS2}    catenate    set_cell id=2 gnb=2 nr_arfcn=643334:643334 gscn=7950 eci=0x000021f pci=17:0 tac=200
    ...    proxy=$PROXY_SERVER_IP:9999|$PROXY_SERVER_IP:8888 nrci=0x02 tdd_cell=on mandatory_for_activation=off
    Update Cfg    ${SRS2}
    Update Cfg    ue_nr_capabilities id=1 voice_over_nr=on:on:off
    Update Cfg    set_qosflow id=1 5qi=6 default=on
    Update Cfg    set_qosflow id=2 5qi=7
    Update Cfg    set_qosflow id=3 5qi=8
    Update Cfg    set_qosflow id=4 5qi=9 default=off
    Update Cfg    set_qosrule id=1 proto=tcp qos_flow=1
    Update Cfg    set_qosrule id=2 proto=udp qos_flow=2
    Update Cfg    set_qosflow id=5 5qi=5
    Update Cfg    set_qosflow id=6 5qi=1
    Update Cfg    set_nwslice id=1 snssai=0x01:0xD143A5 qos_flows=all qos_rules=1,2 default=on ue=1-6 amf=1
    ${qosflow10}    catenate    set_qosflow id=10 5qi=71 gfbr_ul=18000 gfbr_dl=1000 mfbr_ul=30720 mfbr_dl=30720
    ...    qos_flow_type=gbr ue=all pci=may_trigger_pre_emption pvi=pre_emptable priority=2
    Update Cfg    ${qosflow10}
    ${qosflow11}    catenate    set_qosflow id=11 5qi=72 gfbr_ul=18000 gfbr_dl=1000 mfbr_ul=30720 mfbr_dl=30720
    ...    qos_flow_type=gbr ue=all pci=may_trigger_pre_emption pvi=pre_emptable priority=2
    Update Cfg    ${qosflow11}

Send Traffic SA
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${qfi_id}=1
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=dl mbps=150 trf_id=1    pass_regexp=Started Downlink
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=dl mbps=150 trf_id=2    pass_regexp=Started Downlink
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=dl mbps=150 trf_id=3    pass_regexp=Started Downlink
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=dl mbps=150 trf_id=4    pass_regexp=Started Downlink
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=ul mbps=10 trf_id=1    pass_regexp=Started Uplink

Online Param Change
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be Onair    check_sib=${True}

Verify UE status after ADD QOS in same pdu
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${qos_id}=10    ${pass_regexp}=QoS Routing Table
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_add=${qos_id} by=amf
    ...    pass_regexp=${pass_regexp}

Verify UE status after add and modify QOS in same pdu
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${qos_id}=10    ${pass_regexp}=QoS Routing Table
    set SRS power
    Execute Egate Command    qosflow_modify qos_flow=10 mfbr_dl=128 mfbr_ul=128 gfbr_dl=64 gfbr_ul=64
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_add=3 qosflows_to_modify=${qos_id} by=amf
    ...    pass_regexp=${pass_regexp}

Verify UE status after modify QOS in same pdu
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${qos_id}=11
    Execute Egate Command    qosflow_modify qos_flow=11 priority=11
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_modify=${qos_id} by=amf
    ...    pass_regexp=Pdu Session Resource Modify Response Message with RAN UE NGAP

Verify UE status after del QOS in same pdu
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${qos_id}=3,10    ${pass_regexp}=QoS Routing Table
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_del=${qos_id} by=amf    pass_regexp=${pass_regexp}
