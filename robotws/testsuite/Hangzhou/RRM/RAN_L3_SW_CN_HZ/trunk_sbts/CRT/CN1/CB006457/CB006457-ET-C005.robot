*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    RAN_5G    RAN_5G_TDD    SBTS00    CRT    CLOUD_5G_I_LO_AP_LO
...            owner-ha.zheng    team-CN1ET    release-SBTS24R3
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${SYSCOM_FLAG}    ${True}

@{PARAMS_IN_SCF}
...    @{PARAMS_FOR_VoNR}
...    @{CAparam}
...    @{csiparam}
...    @{PARAMS_FOR_9059}
...    @{PARAMS_FOR_5QI71}
...    @{overheating}
...    @{2271_related_modification}
...    @{PARAMS_FOR_6457}
...    @{pmqap}
...    @{732_enabled}
...    @{handover}
...    @{8311_enable}

@{PARAMS_FOR_6457}
...    NRBTS:actMultiDrbNSA=true
...    NRBTS:actArpBasedQosScaling=true
...    NRBTS:multiArpBasedParam:nbrUlDlSF=30|arpPrioLev=14
...    NRBTS:multiArpBasedParam:schedulingWeightSF=30|arpPrioLev=14
...    NRBTS:multiArpBasedParam:nbrUlDlSF=80|arpPrioLev=2
...    NRBTS:multiArpBasedParam:schedulingWeightSF=80|arpPrioLev=2
...    NRBTS:multiArpBasedParam:nbrUlDlSF=70|arpPrioLev=10
...    NRBTS:multiArpBasedParam:schedulingWeightSF=70|arpPrioLev=10
...    NRBTS:multiArpBasedParam:nbrUlDlSF=50|arpPrioLev=13
...    NRBTS:multiArpBasedParam:schedulingWeightSF=50|arpPrioLev=13
...    NRBTS:multiArpBasedParam:nbrUlDlSF=20|arpPrioLev=15
...    NRBTS:multiArpBasedParam:schedulingWeightSF=20|arpPrioLev=15
...    NRBTS:actNonGbrServiceDiff=true
...    NRCELL-1:actNbrForNonGbrBearers=true
...    NRCELL-2:actNbrForNonGbrBearers=false
...    NRCELL:maxNumOfNbrBearers=80
...    NRCELL:maxPrbsPerNbrUe=10
...    NRCELL:nbrPdcchCongHandlingDl=false
...    NRCELL:nbrPdcchCongHandlingUl=false
...    NRCELL:nbrPdschCongHandling=false
...    NRCELL:nbrPuschCongHandling=false
...    NRCELL:congDetectPeriod=ms500
...    NRCELL:congWeightAlg=priorityLevel
...    NRCELL:maxNbrTrafficLimit=20
...    NRBTS/NRDRB-10:schedulWeight=50
...    NRBTS/NRDRB-11:schedulWeight=10
...    NRBTS/NRDRB-11:pmCounterGroup=1
...    NRBTS/NRDRB-12:schedulWeight=20
...    NRBTS/NRDRB-12:pmCounterGroup=2
...    NRBTS/NRDRB-13:schedulWeight=20
...    NRBTS/NRDRB-13:pmCounterGroup=3
...    NRBTS/NRDRB-14:schedulWeight=10
...    NRBTS/NRDRB-14:pmCounterGroup=4
...    NRBTS/NRDRB-1:priorityLevel=15
...    NRBTS/NRDRB-10:priorityLevel=2
...    NRBTS/NRDRB-11:priorityLevel=11
...    NRBTS/NRDRB-12:priorityLevel=12
...    NRBTS/NRDRB-13:priorityLevel=13
...    NRBTS/NRDRB-14:priorityLevel=14
...    NRBTS/NRDRB-15:priorityLevel=3
...    NRBTS/NRDRB_MAC-1:nbrDl=30000
...    NRBTS/NRDRB_MAC-1:nbrUl=10000
...    NRBTS/NRDRB_MAC-1:schedulBSD=50ms
...    NRBTS/NRDRB_MAC-2:nbrDl=10000
...    NRBTS/NRDRB_MAC-2:nbrUl=5000
...    NRBTS/NRDRB_MAC-2:schedulBSD=50ms
...    NRBTS/NRDRB_MAC-1:maxDlHarqTxDrb=4
...    NRBTS/NRDRB_MAC-1:maxUlHarqTxDrb=4
...    NRBTS/NRDRB_MAC-2:maxDlHarqTxDrb=4
...    NRBTS/NRDRB_MAC-2:maxUlHarqTxDrb=4
...    NRBTS:act5qiAndUlNguTnlQosFlowMod=true
...    NRBTS/NRDRB-15:queuingDelayDiscarding=Disabled
...    NRCELL:actServiceAwareConfig=true

@{732_enabled}
...    NRBTS:rrcReestabTypeSA=sameGNB
...    NRBTS:tWaitingRlRecover=4000ms
...    NRBTS:tWaitingRlRecoverSA=4000ms

@{handover}
...    NRBTS:actIntraFreqHoSA=true
...    NRBTS:actInterFreqHoSA=true
...    NRCELL:a1MeashoEnabledSA=rsrp
...    NRCELL:a2MeashoEnabledSA=rsrp
...    NRCELL:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=5
...    NRCELL:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=20
...    NRCELL:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms100
...    NRCELL:a1MeashoSsbRsrqSA:a1HysteresishoSsbRsrqSA=0
...    NRCELL:a1MeashoSsbRsrqSA:a1ThresholdhoSsbRsrqSA=20
...    NRCELL:a1MeashoSsbRsrqSA:a1TimeToTriggerhoSsbRsrqSA=ms100
...    NRCELL:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=5
...    NRCELL:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=20
...    NRCELL:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms40
...    NRCELL:a2MeashoSsbRsrqSA:a2HysteresishoSsbRsrqSA=5
...    NRCELL:a2MeashoSsbRsrqSA:a2ThresholdhoSsbRsrqSA=20
...    NRCELL:a2MeashoSsbRsrqSA:a2TimeToTriggerhoSsbRsrqSA=ms40
...    NRCELL-2/NRHOIF-1:cellDepType=SA
...    NRCELL-2/NRHOIF-1:freqBandIndicatorNR=71
...    NRCELL-2/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-2/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-2/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-2/NRHOIF-1:ssbFrequency=127210
...    NRCELL-2/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=30
...    NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms64
...    NRCELL-2/NRHOIF-1:a5MeasEnabled=rsrp
...    NRCELL-2/NRHOIF-1:a5MeasSsbRsrp:a5HysteresisSsbRsrp=0
...    NRCELL-2/NRHOIF-1:a5MeasSsbRsrp:a5Threshold1SsbRsrp=30
...    NRCELL-2/NRHOIF-1:a5MeasSsbRsrp:a5Threshold2SsbRsrp=40
...    NRCELL-2/NRHOIF-1:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms64
...    NRCELL-2:measGapSelectionSA=favourUeThroughput
...    NRPMRNL-1:miNrRelReportCu=5min
...    NRCELL-1/NRHOIF-1:cellDepType=SA
...    NRCELL-1/NRHOIF-1:freqBandIndicatorNR=41
...    NRCELL-1/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-1:ssbFrequency=518670
...    NRCELL-1/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=30
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms64
...    NRCELL-1/NRHOIF-1:a5MeasEnabled=rsrp
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5HysteresisSsbRsrp=0
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5Threshold1SsbRsrp=30
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5Threshold2SsbRsrp=40
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms64
...    NRCELL-1:measGapSelectionSA=favourUeThroughput

@{pmqap}
...    NRBTS:actNrpmqapProfiles=true
...    NRBTS:actThpDist=true
...    NRBTS:actIpThpt=true
...    NRBTS:actLatencyPmCount=true
...    NRPMRNL-1:miNrPdcpCellNrpmqap=5min
...    NRPMRNL-1:miNrHighRlcCellNrpmqap=5min
...    NRPMRNL-1:miNrNgInterfaceNrpmqap=5min
...    NRPMRNL-1:miNrNsaAcCuNrpmqap=5min
...    NRPMRNL-1:miNrSaCuNrpmqap=5min
...    NRPMRNL-1:miNrUeStatNrpmqap=5min
...    NRPMRNL-1:miNrX2ccNrpmqap=5min
...    NRPMRNL-1/NRPMQAP-1:cfgProfType=SA
...    NRPMRNL-1/NRPMQAP-1:cfg5qiRange=6
...    NRPMRNL-1/NRPMQAP-1:cfgArpRange=2
...    NRPMRNL-1/NRPMQAP-1:cfgPlmnId:mncLength=3
...    NRPMRNL-1/NRPMQAP-1:cfgPlmnId:mcc=311
...    NRPMRNL-1/NRPMQAP-1:cfgPlmnId:mnc=489
...    NRPMRNL-1/NRPMQAP-1:cfgSliceId:sst=1
...    NRPMRNL-1/NRPMQAP-1:cfgSliceId:sd=13714341
...    NRPMRNL-1/NRPMQAP-2:cfgProfType=SA
...    NRPMRNL-1/NRPMQAP-2:cfg5qiRange=8
...    NRPMRNL-1/NRPMQAP-2:cfgArpRange=2
...    NRPMRNL-1/NRPMQAP-2:cfgPlmnId:mncLength=3
...    NRPMRNL-1/NRPMQAP-2:cfgPlmnId:mcc=311
...    NRPMRNL-1/NRPMQAP-2:cfgPlmnId:mnc=489
...    NRPMRNL-1/NRPMQAP-2:cfgSliceId:sst=1
...    NRPMRNL-1/NRPMQAP-2:cfgSliceId:sd=13714341
...    NRPMRNL-1/NRPMQAP-3:cfgProfType=SA
...    NRPMRNL-1/NRPMQAP-3:cfg5qiRange=7
...    NRPMRNL-1/NRPMQAP-3:cfgArpRange=14
...    NRPMRNL-1/NRPMQAP-3:cfgPlmnId:mncLength=3
...    NRPMRNL-1/NRPMQAP-3:cfgPlmnId:mcc=311
...    NRPMRNL-1/NRPMQAP-3:cfgPlmnId:mnc=489
...    NRPMRNL-1/NRPMQAP-3:cfgSliceId:sst=1
...    NRPMRNL-1/NRPMQAP-3:cfgSliceId:sd=13714341
...    NRPMRNL-1/NRPMQAP-4:cfgProfType=SA
...    NRPMRNL-1/NRPMQAP-4:cfg5qiRange=6
...    NRPMRNL-1/NRPMQAP-4:cfgArpRange=14
...    NRPMRNL-1/NRPMQAP-4:cfgPlmnId:mncLength=3
...    NRPMRNL-1/NRPMQAP-4:cfgPlmnId:mcc=311
...    NRPMRNL-1/NRPMQAP-4:cfgPlmnId:mnc=489
...    NRPMRNL-1/NRPMQAP-4:cfgSliceId:sst=1
...    NRPMRNL-1/NRPMQAP-4:cfgSliceId:sd=13714341
...    NRPMRNL-1/NRPMQAP-5:cfgProfType=SA
...    NRPMRNL-1/NRPMQAP-5:cfg5qiRange=9
...    NRPMRNL-1/NRPMQAP-5:cfgArpRange=10
...    NRPMRNL-1/NRPMQAP-5:cfgPlmnId:mncLength=3
...    NRPMRNL-1/NRPMQAP-5:cfgPlmnId:mcc=311
...    NRPMRNL-1/NRPMQAP-5:cfgPlmnId:mnc=489
...    NRPMRNL-1/NRPMQAP-5:cfgSliceId:sst=1
...    NRPMRNL-1/NRPMQAP-5:cfgSliceId:sd=13714341
...    NRPMRNL-1/NRPMQAP-6:cfgArpRange=15
...    NRPMRNL-1/NRPMQAP-6:cfgPlmnId:mncLength=3
...    NRPMRNL-1/NRPMQAP-6:cfgPlmnId:mcc=311
...    NRPMRNL-1/NRPMQAP-6:cfgPlmnId:mnc=489
...    NRPMRNL-1/NRPMQAP-6:cfgSliceId:sst=1
...    NRPMRNL-1/NRPMQAP-6:cfgSliceId:sd=13714341
...    NRPMRNL-1/NRPMQAP-1:rlcAmSduDlDelayThresh=2000
...    NRPMRNL-1/NRPMQAP-1:thpHistDownlinkMaxRange=1000000
...    NRPMRNL-1/NRPMQAP-1:thpHistDownlinkMinRange=100
...    NRPMRNL-1/NRPMQAP-1:thpHistScale=linear
...    NRPMRNL-1/NRPMQAP-1:thpHistUplinkMaxRange=100000
...    NRPMRNL-1/NRPMQAP-1:thpHistUplinkMinRange=100
...    NRPMRNL-1/NRPMQAP-2:rlcAmSduDlDelayThresh=2000
...    NRPMRNL-1/NRPMQAP-2:thpHistDownlinkMaxRange=1000000
...    NRPMRNL-1/NRPMQAP-2:thpHistDownlinkMinRange=100
...    NRPMRNL-1/NRPMQAP-2:thpHistScale=linear
...    NRPMRNL-1/NRPMQAP-2:thpHistUplinkMaxRange=100000
...    NRPMRNL-1/NRPMQAP-2:thpHistUplinkMinRange=100
...    NRPMRNL-1/NRPMQAP-3:rlcAmSduDlDelayThresh=2000
...    NRPMRNL-1/NRPMQAP-3:thpHistDownlinkMaxRange=1000000
...    NRPMRNL-1/NRPMQAP-3:thpHistDownlinkMinRange=100
...    NRPMRNL-1/NRPMQAP-3:thpHistScale=linear
...    NRPMRNL-1/NRPMQAP-3:thpHistUplinkMaxRange=100000
...    NRPMRNL-1/NRPMQAP-3:thpHistUplinkMinRange=100
...    NRPMRNL-1/NRPMQAP-4:rlcAmSduDlDelayThresh=2000
...    NRPMRNL-1/NRPMQAP-4:thpHistDownlinkMaxRange=1000000
...    NRPMRNL-1/NRPMQAP-4:thpHistDownlinkMinRange=100
...    NRPMRNL-1/NRPMQAP-4:thpHistScale=linear
...    NRPMRNL-1/NRPMQAP-4:thpHistUplinkMaxRange=100000
...    NRPMRNL-1/NRPMQAP-4:thpHistUplinkMinRange=100
...    NRPMRNL-1/NRPMQAP-5:rlcAmSduDlDelayThresh=2000
...    NRPMRNL-1/NRPMQAP-5:thpHistDownlinkMaxRange=1000000
...    NRPMRNL-1/NRPMQAP-5:thpHistDownlinkMinRange=100
...    NRPMRNL-1/NRPMQAP-5:thpHistScale=linear
...    NRPMRNL-1/NRPMQAP-5:thpHistUplinkMaxRange=100000
...    NRPMRNL-1/NRPMQAP-5:thpHistUplinkMinRange=100
...    NRPMRNL-1/NRPMQAP-6:rlcAmSduDlDelayThresh=2000
...    NRPMRNL-1/NRPMQAP-6:thpHistDownlinkMaxRange=1000000
...    NRPMRNL-1/NRPMQAP-6:thpHistDownlinkMinRange=100
...    NRPMRNL-1/NRPMQAP-6:thpHistScale=linear
...    NRPMRNL-1/NRPMQAP-6:thpHistUplinkMaxRange=100000
...    NRPMRNL-1/NRPMQAP-6:thpHistUplinkMinRange=100
...    NRBTS-1:thpHistDownlinkMaxRange=1000000
...    NRBTS-1:thpHistDownlinkMinRange=100
...    NRBTS-1:thpHistScale=linear
...    NRBTS-1:thpHistUplinkMaxRange=100000
...    NRBTS-1:thpHistUplinkMinRange=100

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

@{8311_enable}
...    NRBTS:actBufferBasedSCellAddition=oneShot_Dl_Fr1
...    NRCELL:dlSCellConfigLevel=10
...    NRCELL:dlSCellConfigLevelNum=20
...    NRBTS:caBackoffTimerUeOh=20
...    NRBTS:actSCellReleaseForInactiveSCell=timer_based_Fr1
...    NRCELL:sCellInactivityReleaseTimer=10
...    NRBTS:timerPostOverheating=5
...    NRBTS:actOverheatingAssistance=true
...    NRBTS:timerOverheatIndProhibit=1s


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
#...    NRBTS/NRDRB-15:queuingDelayDiscardEnabled=false
...    NRBTS/NRDRB-15:queuingDelaySduDiscardThreshold=200
...    NRBTS/NRDRB-15:cellAggrLevel=Not FR1 CA eligible
...    NRBTS/NRDRB-15:resType=GBR
...    NRBTS/NRDRB-15:discardTimer=10ms
...    NRBTS/NRDRB-15:maxTransferDelayGbr=20
...    NRBTS/NRDRB-15:maxRlcQueueingDelayGbr=20
...    NRBTS/NRDRB-15:rlcMode=RLC_UM
...    NRBTS/NRDRB-15:schedulWeight=10
...    NRBTS/NRDRB-15:sduDiscardIntervalTmr=100
...    NRBTS/NRDRB-15:maxDataRateGbrDl=1000
...    NRBTS/NRDRB-15:maxDataRateGbrUl=1000
...    NRBTS/NRDRB_MAC-3:lcgid=4
...    NRBTS/NRDRB_MAC-3:schedulPrio=5
...    NRBTS/NRDRB_PDCP-2:pdcpBufDiscardEnabled=false
...    NRBTS/NRDRB_RLC_UM-1:dlTReassemblyUm=ms40
...    NRBTS/NRDRB_RLC_UM-1:ulTReassemblyUm=ms40

@{CAparam}
...    NRBTS:maxNumScellsDl=2
...    NRBTS:maxNumScellsUl=2
...    NRDU-1:carrierAggregationSupportList=${CA_support_list}
...    NRBTS/NRDRB_RLC_AM-1:ulTReassemblyIBCA=40
...    NRBTS/NRDRB_RLC_AM-2:ulTReassemblyIBCA=40
...    NRBTS/NRDRB_RLC_AM-3:ulTReassemblyIBCA=40
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
...    NRCELL-1/NRREL-1:sCellOperationalMode=dlAndUl
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
...    NRCELL-2/NRREL-1:sCellOperationalMode=dlAndUl
...    NRCELL-2/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL:timingAdvanceOffset=n25600
...    NRCELL-2:increasePUSCHPrepTimeULCA=true
...    NRCELL-2:actIncreasedFdmUsersPerSlot=true
...    NRCELL-2:actRescheduleBlockedRetx=true
...    NRCELL-2:maxNumPuschAllocationPerSlot=4
...    NRCELL-2:minPctResourceReservedMcsDl=50
...    NRCELL-2:minPctResourceReservedMcsUl=50
...    NRCELL-2:targetPctResourceReservedMcsDl=75
...    NRCELL-2:targetPctResourceReservedMcsUl=75
...    NRCELL-2:maxNumOfUlCaUeParallelTx=1
...    NRCELL-2:actAdaptiveReTxResMcs=true
...    NRCELL:a1MeasSCellAddEnabled=rsrp
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=31
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=70
...    NRCELL:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=2
...    NRCELL:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms

${CA_support_list}    SEPARATOR=,
...    ca_Fr1Tdd_Fdd_Sa
...    ca_Fdd_Fr1Tdd_Sa
...    ca_Fdd_Fr1Tdd_Sa_WithUl
...    ca_Fr1Tdd_Fdd_Sa_WithUl
...    ca_Fdd_Fr1Tdd_Nsa
...    ca_Fr1Tdd_Fdd_Nsa

@{csiparam}
...    NRBTS/NRCELL:actCsirsMultiplexing = false
...    NRBTS/NRCELL:actUeCsirsCoexistCellCsirs=true
...    NRCELL:ssPbchBlockPower=0
...    NRCELL:periodicCsiAcquisition:csiReportPeriodicity=slots320

@{PARAMS_FOR_9059}
...    NRBTS-1/NRDRB-10:cellAggrLevel=FR1 CA eligible
...    NRBTS-1/NRDRB-11:cellAggrLevel=FR1 CA eligible
...    NRBTS-1/NRDRB-12:cellAggrLevel=FR1 CA eligible
...    NRBTS-1/NRDRB-13:cellAggrLevel=FR1 CA incompatible
...    NRBTS-1/NRDRB-14:cellAggrLevel=Not FR1 CA eligible
...    NRBTS-1:actDrbProfileForCellAggrLevel=FR1_SA

@{PARAMS_FOR_5QI71}
...    NRCELL:actNonVoNRGbrService=true
...    NRCELL:maxGBRTrafficLimit=50
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
...    NRBTS/NRDRB-17:queuingDelaySduDiscardThreshold=750
...    NRBTS/NRDRB-17:resType=GBR
...    NRBTS/NRDRB-17:rlcMode=RLC_AM
...    NRBTS/NRDRB-17:rlcPduDelayThCa=30
...    NRBTS/NRDRB-17:schedulWeight=10
...    NRBTS/NRDRB-17:sduDiscardIntervalTmr=500
...    NRBTS/NRDRB-17:volThresDiscardDl=8000
...    NRBTS/NRDRB-17:volThresDiscardUl=800
...    NRBTS/NRDRB-17:l2OHFactorDl=16
...    NRBTS/NRDRB-17:l2OHFactorUl=35
...    NRBTS/NRDRB-17:nrDrbUlCgDN=MRBTS-1/NRBTS-1/NRULCG_PROFILE-7
...    NRBTS/NRDRB-17:cellAggrLevel=Not FR1 CA eligible
...    NRBTS/NRDRB-15:nrDrbMacDN=NRDRB_MAC-3
...    NRBTS/NRDRB-15:nrDrbPdcpDN=NRDRB_PDCP-2
...    NRBTS/NRDRB-15:nrDrbRlcUmDN=NRDRB_RLC_UM-1
...    NRBTS/NRDRB-15:dlFlowControlAlgo=none
...    NRBTS/NRDRB-15:dscp=0
...    NRBTS/NRDRB-15:maxDddsPeriodCpuOvld=40
...    NRBTS/NRDRB-15:numSduDiscard=1
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

@{PARAMS_for_recover_C05}
...    NRCELL-1:actNbrForNonGbrBearers=true
...    NRCELL-2:actNbrForNonGbrBearers=false

@{PARAMS_for_C005_1}
...    NRCELL-1:actNbrForNonGbrBearers=true
...    NRCELL-2:actNbrForNonGbrBearers=true

@{PARAMS_for_C005_2}
...    NRCELL-1:actNbrForNonGbrBearers=false
...    NRCELL-2:actNbrForNonGbrBearers=false

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
...    0x600013=1     #9496 BOAM_RAT_ADAPT
...    0x19040F=1     #9496 BOAM_FRONTHAUL
...    0x88004b=0     #L1FH rdEnableSktMvp, 0 for 9496; 1 for SKTMVP
...    0x880031=14    #L1FH rdBwvTxOpportunities, 14 for 9496; 3 for SKTMVP
...    0x58026F=0
...    0x800087=0
...    0x580717=1

${ERadParam_EnableSrsBasedBeamForming}    0x70690

@{PARAMS_IN_SWCONFIG_AP}
...    ${ERadParam_EnableSrsBasedBeamForming}=1

@{PM_Counters_C005}
...    NRCELL-2/NRPMQAP-1:PDCPQ:${DL_PDCP_VOL_UE_TPUT_5G_PMQAP}>0
...    NRCELL-2/NRPMQAP-1:PDCPQ:${DL_PDCP_TIME_UE_TPUT_5G_PMQAP}>0
...    NRCELL-2/NRPMQAP-3:PDCPQ:${DL_PDCP_VOL_UE_TPUT_5G_PMQAP}>0
...    NRCELL-2/NRPMQAP-3:PDCPQ:${DL_PDCP_TIME_UE_TPUT_5G_PMQAP}>0
...    NRCELL-2/NRPMQAP-4:PDCPQ:${DL_PDCP_VOL_UE_TPUT_5G_PMQAP}>0
...    NRCELL-2/NRPMQAP-4:PDCPQ:${DL_PDCP_TIME_UE_TPUT_5G_PMQAP}>0
...    NRCELL-2/NRPMQAP-5:PDCPQ:${DL_PDCP_VOL_UE_TPUT_5G_PMQAP}>0
...    NRCELL-2/NRPMQAP-5:PDCPQ:${DL_PDCP_TIME_UE_TPUT_5G_PMQAP}>0
...    NRCELL-2/NRPMQAP-6:PDCPQ:${DL_PDCP_VOL_UE_TPUT_5G_PMQAP}>0
...    NRCELL-2/NRPMQAP-6:PDCPQ:${DL_PDCP_TIME_UE_TPUT_5G_PMQAP}>0
...    NRCELL-1/NRPMQAP-1:PDCPQ:${DL_PDCP_VOL_UE_TPUT_5G_PMQAP}>0
...    NRCELL-1/NRPMQAP-1:PDCPQ:${DL_PDCP_TIME_UE_TPUT_5G_PMQAP}>0
...    NRCELL-1/NRPMQAP-3:PDCPQ:${DL_PDCP_VOL_UE_TPUT_5G_PMQAP}>0
...    NRCELL-1/NRPMQAP-3:PDCPQ:${DL_PDCP_TIME_UE_TPUT_5G_PMQAP}>0
...    NRCELL-1/NRPMQAP-4:PDCPQ:${DL_PDCP_VOL_UE_TPUT_5G_PMQAP}>0
...    NRCELL-1/NRPMQAP-4:PDCPQ:${DL_PDCP_TIME_UE_TPUT_5G_PMQAP}>0
...    NRCELL-1/NRPMQAP-5:PDCPQ:${DL_PDCP_VOL_UE_TPUT_5G_PMQAP}>0
...    NRCELL-1/NRPMQAP-5:PDCPQ:${DL_PDCP_TIME_UE_TPUT_5G_PMQAP}>0
...    NRCELL-2/NRPMQAP-1:PDCPQ:${DL_PDCP_VOL_UE_TPUT_PMQAP}>0
...    NRCELL-2/NRPMQAP-1:PDCPQ:${DL_PDCP_TIME_UE_TPUT_PMQAP}>0
...    NRCELL-2/NRPMQAP-3:PDCPQ:${DL_PDCP_VOL_UE_TPUT_PMQAP}>0
...    NRCELL-2/NRPMQAP-3:PDCPQ:${DL_PDCP_TIME_UE_TPUT_PMQAP}>0
...    NRCELL-2/NRPMQAP-4:PDCPQ:${DL_PDCP_VOL_UE_TPUT_PMQAP}>0
...    NRCELL-2/NRPMQAP-4:PDCPQ:${DL_PDCP_TIME_UE_TPUT_PMQAP}>0
...    NRCELL-2/NRPMQAP-5:PDCPQ:${DL_PDCP_VOL_UE_TPUT_PMQAP}>0
...    NRCELL-2/NRPMQAP-5:PDCPQ:${DL_PDCP_TIME_UE_TPUT_PMQAP}>0
...    NRCELL-2/NRPMQAP-6:PDCPQ:${DL_PDCP_VOL_UE_TPUT_PMQAP}>0
...    NRCELL-2/NRPMQAP-6:PDCPQ:${DL_PDCP_TIME_UE_TPUT_PMQAP}>0
...    NRCELL-1/NRPMQAP-1:PDCPQ:${DL_PDCP_VOL_UE_TPUT_PMQAP}>0
...    NRCELL-1/NRPMQAP-1:PDCPQ:${DL_PDCP_TIME_UE_TPUT_PMQAP}>0
...    NRCELL-1/NRPMQAP-3:PDCPQ:${DL_PDCP_VOL_UE_TPUT_PMQAP}>0
...    NRCELL-1/NRPMQAP-3:PDCPQ:${DL_PDCP_TIME_UE_TPUT_PMQAP}>0
...    NRCELL-1/NRPMQAP-4:PDCPQ:${DL_PDCP_VOL_UE_TPUT_PMQAP}>0
...    NRCELL-1/NRPMQAP-4:PDCPQ:${DL_PDCP_TIME_UE_TPUT_PMQAP}>0
...    NRCELL-1/NRPMQAP-5:PDCPQ:${DL_PDCP_VOL_UE_TPUT_PMQAP}>0
...    NRCELL-1/NRPMQAP-5:PDCPQ:${DL_PDCP_TIME_UE_TPUT_PMQAP}>0
...    NRCELL-1/NRPMQAP-6:PDCPQ:${DL_PDCP_VOL_UE_TPUT_PMQAP}>0
...    NRCELL-1/NRPMQAP-6:PDCPQ:${DL_PDCP_TIME_UE_TPUT_PMQAP}>0

${DL_PDCP_VOL_UE_TPUT_5G_PMQAP}    M55352C01002
${DL_PDCP_TIME_UE_TPUT_5G_PMQAP}    M55352C01003
${DL_PDCP_VOL_UE_TPUT_PMQAP}    M55352C01001
${DL_PDCP_TIME_UE_TPUT_PMQAP}    M55352C00001


${ue_nr_cap_SA_UE1}    SEPARATOR=
...    E9A09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C47007B8D85181AC1184341020E9068036B64C558D0
...    E7C471E819F604F8C48E3C873EA39F30C7942C0E070F05C00FFC007003FF0005C0000E0541B11B582308682041F28340125B262A82873E238
...    F1800000000000081C3C09FFF000007FFC000005C0000E000BC3C46000E140000000B01020060234028174001300C68912244D8E7C3005011
...    9E82C003C1C1401C0C02500700060240040603E008020000000100000200B036B2A68020800004B29202000032CA4800A81C552A8A1600480
...    0D028000020200400808020043543E00020406080C0E1416181A2022242628303236383A3E424A4C4E5052545A5E828305A0

${SA_Capa_Support_CA}    SEPARATOR=
...    E9A09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C4700BB8D85181AC1184341020E9068036B64C558D0
...    E7C471E819F604F8C48E3C873EA39F30C7942C0E070F05C0017C0070005F0005C0000E0541B107582308682041E20D00656C98AB121CFB027
...    C471E31238F21CFA8E7CC31E50B0381C3C27F6000001FD800000171000380030F506C46D608C21A0810788340195B262AC4873EC09F11C78C
...    48E3C873EA39F30C7942C0E070F09FC0000007F00000005C0000E002A81C46040000120541C1401C46000002120561E140006118000412056
...    0E14040003010758785000182800020083801808D00A05D000E40B0276C73E1C29D3B639F0E1449DB1CF870226C73E1C2893B639F0C02C14D
...    18C6307A0B800F000A070500703009401C0018090010180F82400800000004000008020000000100000200800002004000018020000100100
...    000A008004010040100000C0080000700400200000008000080040000480200100C030040000500200002C01000812048020000300CE54D65
...    4D60A5606560CD60AD652D64CD602D606D6025604560ED0341000009652504000065949410000296524040000E59490100004965240400016
...    5949010000696524040001E594901000089652404000265949010000A96524040002E5949410000C96524040000C594900C52AABA55554AA2
...    E95455058AA071541A2A94C55268AA031540A2A93555078A160178095028140A05028140A05028140A05028140A0502814001000203C03040
...    4008000100C018202004010080600000101800820200401008010003143E00020406080C0E1416181A2022242628303236383A3E424A4C4E5
...    052545A5E8280

${Capa_LTE}    SEPARATOR=
...    A11FF82384C0C03850001C46000000122205C160601C46000002022205C2606018280388C00000824440B84C0C03850001846000184888100
...    5011A014003174003282449D1276C73E1C29D3B639F0E24E893B639F0E201B1CF86009020C6318400C4000100808010040201803040002010
...    100C018400010080801000020180308000201010020080403000

@{pass_pdu1_add_71}
...    Ue 2 PduId 1 Created FiveQi:Qfi mapping fiveQi 71 qfi 2
...    QoS Routing Table

@{pass_pdu1_Modify_8}
...    drb-ToAddModList
...    drb-ToReleaseList
...    sCellToReleaseList

@{pass_pdu1_Modify_9}
...    drb-ToAddModList
...    drb-ToReleaseList

*** Test Cases ***
CB006457-ET-C005_5QI Modification for an existing non-GBR QoS Flow_5QI and ARP
    [Documentation]
    ...     This user scenario describes the successful modification of a QoS flow for an existing non GBR QoS Flow
    ...     triggered via PDU Session Resource Modification procedure requested by 5GC
    ...     (single non-GBR for 5QI modification with different DRB profile)
    ...     2.Test Case Steps:
    ...     Step A. setup cell-2 NRCELL-2:actNbrForNonGbrBearers=false,NRCELL-1:actNbrForNonGbrBearers=true
    ...             UE1 setup SA call with NRDRB-1(ArpPrioLev = 2) 5QI-6 in cell-2 and trigger scell addition,
    ...             UE2 setup SA call with NRDRB-2(ArpPrioLev = 14) 5QI-7 in cell-2 and trigger scell addition,
    ...             start DL and UL data traffic for all UEs and check traffic
    ...     Step B. add vonr call in UE1
    ...             add nonVONR GBR call in UE2
    ...             modify UE1 5qi-6 to 5qi-9, start DL and UL data traffic for all UEs and check traffic
    ...             modify UE2 5qi-7 to 5qi-8, start DL and UL data traffic for all UEs and check traffic
    ...     Step C. repeat step A-B in cell1
    ...     Step D. online change all cell actNbrForNonGbrBearers=true
    ...     Step E. repeat step A-B in cell2
    ...     Step F. online change all cell actNbrForNonGbrBearers=false
    ...     Step G. repeat step A-B in cell2
    [Tags]    C005    QC_363597
    Clear Counter Files
    set drb prio
    UE ATTACH and modify 5QI    cell_id=2
    Recover 5QI
    UE ATTACH and modify 5QI    cell_id=1
    online param change    ${PARAMS_for_C005_1}
    Recover 5QI
    UE ATTACH and modify 5QI    cell_id=2
	online param change    ${PARAMS_for_C005_2}
	Recover 5QI
	UE ATTACH and modify 5QI    cell_id=2
	stop capture wireshark log
	Check Wireshark Log    ${CURDIR}${/}A2A_C005${/}a2a.ini
	Check Counters    ${PM_Counters_C005}
	[Teardown]    C05_Teardown
	
*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Install eNB Package via WEBEM
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/2cells_1T1F    ue_count=5

Install eNB Package via WEBEM
    [Arguments]    ${bsr_name}=BSR_AQQL_6_H6_ALN60_ARP60_P11_COVERAGE_00776_00001.zip    ${bsr_path}=/home/ute/bsr_package
    Execute Cmd On Pc    rm -rf ${bsr_path}
    Execute Cmd On Pc    mkdir ${bsr_path}
    Execute Cmd On Pc    git clone https://wrgitlab.ext.net.nokia.com/y165zhan/bsr_package ${bsr_path}
    update_software    sw_package=${bsr_path}/${bsr_name}    timeout=60

C05_Teardown
    Online param change    ${PARAMS_for_recover_C05}
    Recover 5QI
    Common Test Teardown And Stop Capture Logs

SA UE attach
    [Arguments]    ${ue_id}=1    ${cell_id}=1    ${pdu_id}=1
    reset SRS power
    Execute Egate Command    ue_change_location id=${ue_id} cell=${cell_id} enb=2
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Registered state.
    set SRS power
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    smf_param id=1 additional_qosflows_to_activate=2
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=${ue_id} nwslice=1    pass_regexp=Initial Context Setup Successful

set drb prio
    Execute Egate Command    qosflow_modify qos_flow=1 priority=2
    Execute Egate Command    qosflow_modify qos_flow=2 priority=14

SA UE attach with drb
    [Arguments]    ${ue_id}=1    ${cell_id}=1    ${pdu_id}=1    ${qos_flow}=1
    #reset SRS power
    Execute Egate Command    ue_change_location id=${ue_id} cell=${cell_id} enb=2
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Registered state.
    Execute Egate Command    qosflow_modify qos_flow=${qos_flow} default=on
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=${ue_id} nwslice=1    pass_regexp=Initial Context Setup Successful
    Send Traffic SA    ue_id=${ue_id}    pdu_id=${pdu_id}    qfi_id=1

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
    Update Cfg    ue_nr_capabilities id=1 voice_over_nr=on:on:off
    Update Cfg    ue_param id=1 ue_nr_capabilities=${ue_nr_cap_SA_UE1}
    Update Cfg    ue_param id=2 ue_nr_capabilities=${ue_nr_cap_SA_UE1}
    Update Cfg    ue_param id=3 ue_nr_capabilities=${ue_nr_cap_SA_UE1}
    Update Cfg    set_qosflow id=1 5qi=6 default=on
    Update Cfg    set_qosflow id=2 5qi=7
    Update Cfg    set_qosrule id=1 proto=tcp qos_flow=1
    Update Cfg    set_qosrule id=2 proto=udp qos_flow=2
    Update Cfg    set_qosflow id=5 5qi=5
    Update Cfg    set_qosflow id=6 5qi=1
    Update Cfg    set_nwslice id=1 snssai=0x01:0xD143A5 qos_flows=all qos_rules=1,2 default=on ue=1-6 amf=1
    ${qosflow10}    catenate    set_qosflow id=10 5qi=71 gfbr_ul=1000 gfbr_dl=1000 mfbr_ul=30720 mfbr_dl=30720
    ...    qos_flow_type=gbr ue=all pci=may_trigger_pre_emption pvi=pre_emptable priority=2
    Update Cfg    ${qosflow10}
    ${qosflow11}    catenate    set_qosflow id=11 5qi=72 gfbr_ul=18000 gfbr_dl=1000 mfbr_ul=30720 mfbr_dl=30720
    ...    qos_flow_type=gbr ue=all pci=may_trigger_pre_emption pvi=pre_emptable priority=2
    Update Cfg    ${qosflow11}
    Update Cfg    sim_debug_log level=4
    Update Cfg    enb_param id=1 drb_id_begin=3 endc_capable_qci=6-9
    Update Cfg    set_bearer id=3 ue=11 qci=6 pdn=1 default=off preprovisioned=on filter=3 precedence=3
    Update Cfg    set_bearer id=4 ue=11 qci=7 pdn=1 default=off preprovisioned=on filter=4 precedence=4
    Update Cfg    set_bearer id=5 ue=11 qci=8 pdn=1 default=off preprovisioned=on filter=5 precedence=5
    Update Cfg    set_bearer id=3 ue=12 qci=6 pdn=1 default=off preprovisioned=on filter=3 precedence=3
    Update Cfg    set_bearer id=4 ue=12 qci=7 pdn=1 default=off preprovisioned=on filter=4 precedence=4
    Update Cfg    set_bearer id=5 ue=12 qci=8 pdn=1 default=off preprovisioned=on filter=5 precedence=5
    Update Cfg    set_bearer id=3 ue=13 qci=6 pdn=1 default=off preprovisioned=on filter=3 precedence=3
    Update Cfg    set_bearer id=4 ue=13 qci=7 pdn=1 default=off preprovisioned=on filter=4 precedence=4
    Update Cfg    set_bearer id=5 ue=13 qci=8 pdn=1 default=off preprovisioned=on filter=5 precedence=5
    Update Cfg    enb_endc_param id=1 control_flow_period=3gpp1 use_nr_ran_cont=on serving_cell_index_range_scg=8:14
    Update Cfg    ue_param id=11-15 ue_eutra_nr_capabilities=${Capa_LTE} ue_nr_capabilities=${SA_Capa_Support_CA} dual_conn=eutra_nr



Verify tput for SA
    Verify Pcell    ue_id=1    pdu_id=1    qfi_id=1    Tput_dl=0
    Verify Pcell    ue_id=2    pdu_id=1    qfi_id=1    Tput_dl=0

Stop All tput
    Stop Throughput    ue_id=1
    Stop Throughput    ue_id=2
    Stop Throughput    ue_id=3
    Stop Throughput NSA    ue_id=11
    Stop Throughput NSA    ue_id=12
    Stop Throughput NSA    ue_id=13
    Stop Throughput NSA    ue_id=11

Send Traffic SA
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${qfi_id}=1
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=dl mbps=150 trf_id=1    pass_regexp=Started Downlink
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=ul mbps=50 trf_id=1    pass_regexp=Started Uplink

Verify Pcell
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${qfi_id}=1    ${Tput_dl}=0    ${Tput_ul}=0    ${sleep_time}=15s    ${cell_num}=1
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=${qfi_id}    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=${qfi_id}    direction=ul    rate_type=ave
    Log To Console    DL:${dl_throughput}
    Log To Console    UL:${ul_throughput}
    ${scell_tput_dl}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-5 type=pdsch    Throughput
    ${scell_tput_ul}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-5 type=pusch    Throughput
    Wait Until Keyword Succeeds    40s    5s    Check Traffic    ue_id=${ue_id}    cell_num=${cell_num}    dl=${Tput_dl}    ul=${Tput_ul}

Check Traffic
    [Arguments]     ${ue_id}=1    ${cell_num}=2    ${dl}=0    ${ul}=0
    ${total_dl_tput}    Set Variable    0
    FOR    ${index}    IN RANGE    0    ${cell_num}+1
         ${str_index}    Convert To String    ${index}
         ${scell_dl_tput}    Ap Get Throuput On Specific Scell    ${ue_id}    ${str_index}    pdsch
         ${total_dl_tput}    Evaluate    ${scell_dl_tput}+${total_dl_tput}
    END
    ${total_ul_tput}    Set Variable    0
    FOR    ${index}    IN RANGE    0    ${cell_num}+1
         ${str_index}    Convert To String    ${index}
         ${scell_ul_tput}    Ap Get Throuput On Specific Scell    ${ue_id}    ${str_index}    pusch
         ${total_ul_tput}    Evaluate    ${scell_ul_tput}+${total_ul_tput}
    END
    Should Be True    ${total_dl_tput}/1000 > ${dl}
    Should Be True    ${total_ul_tput}/1000 > ${ul}

Stop Throughput
    [Arguments]    ${ue_id}=1
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=1

PDU Session Setup
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${qos_flow}=1    ${pass_regexp}=QoS Routing Table    ${fail_regexp}=None
    Execute Egate Command    qosflow_modify qos_flow=${qos_flow} default=on
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu} gw=1 nwslice=1    pass_regexp=${pass_regexp}
    ...    fail_regexp=${fail_regexp}
    Send Traffic SA    ue_id=${ue_id}    pdu_id=${pdu}    qfi_id=1

PDU Session Release
    [Arguments]    ${ue_id}=1    ${pdu}=1
    Execute Egate Command    ue_pdu_session_release ue=${ue_id} pdu=${pdu} by=amf    pass_regexp=rrcReconfigurationComplete

Online param Change
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be Onair    check_sib=${True}

ADD QOS in same pdu SA
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${qos_flow}=10    ${pass_regexp}=QoS Routing Table
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_add=${qos_flow} by=amf
    ...    pass_regexp=${pass_regexp}
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=2 dir=dl mbps=1 trf_id=1    pass_regexp=Started Downlink
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=2 dir=ul mbps=1 trf_id=1    pass_regexp=Started Uplink

UE ATTACH and modify 5QI
    [Arguments]    ${cell_id}=2
    SA UE attach with drb    ue_id=1    cell_id=${cell_id}    pdu_id=1    qos_flow=1 
	SA UE attach with drb    ue_id=2    cell_id=${cell_id}    pdu_id=1    qos_flow=2
	Verify Pcell    ue_id=1    pdu_id=1    qfi_id=1    Tput_dl=0    Tput_ul=0
	Verify Pcell    ue_id=2    pdu_id=1    qfi_id=1    Tput_dl=0    Tput_ul=0
    ADD VONR    ue_id=1
    ADD nonVONRGBR    ue_id=2    qos_flow=10
    Execute Egate Command    qosflow_modify qos_flow=1 5qi=9 fiveqi_type=non-gbr priority=10
    Execute Egate Command    ue_pdu_session_modify ue=1 pdu=1 qosflows_to_modify=1 by=amf    pass_regexp=${pass_pdu1_Modify_9}
    Stop Throughput    ue_id=1
    Send Traffic SA    ue_id=1    pdu_id=1    qfi_id=1
    Verify Pcell    ue_id=1    pdu_id=1    qfi_id=1    Tput_dl=0    Tput_ul=0
    Execute Egate Command    qosflow_modify qos_flow=2 5qi=8 fiveqi_type=non-gbr priority=13
    Execute Egate Command    ue_pdu_session_modify ue=2 pdu=1 qosflows_to_modify=2 by=amf    pass_regexp=${pass_pdu1_Modify_8}
    Stop Throughput    ue_id=2
    Send Traffic SA    ue_id=2    pdu_id=1    qfi_id=1
	Verify Pcell    ue_id=1    pdu_id=1    qfi_id=1    Tput_dl=0    Tput_ul=0
	Verify Pcell    ue_id=2    pdu_id=1    qfi_id=1    Tput_dl=0    Tput_ul=0    cell_num=0
    Execute Egate Command    ue_deregister id=1,2 ue_deregister_type=switch_off

Recover 5QI
    Execute Egate Command    qosflow_modify qos_flow=1 5qi=6 fiveqi_type=non-gbr priority=2
    Execute Egate Command    qosflow_modify qos_flow=2 5qi=7 fiveqi_type=non-gbr priority=14
    Execute Egate Command    smf_param id=1 reset

ADD VONR
    [Arguments]    ${ue_id}=1
    Execute Egate Command    qosflow_modify qos_flow=5 default=on
    Execute Egate Command    smf_param id=1 additional_qosflows_to_activate=6
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=2 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=2 gw=2 nwslice=1
    Execute Egate Command    smf_param id=1 reset
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=2 qfi=1 dir=dl kbps=5 trf_id=1    pass_regexp=Started Downlink
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=2 qfi=1 dir=ul kbps=5 trf_id=1    pass_regexp=Started Uplink
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=2 qfi=2 dir=dl kbps=3 trf_id=1    pass_regexp=Started Downlink
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=2 qfi=2 dir=ul kbps=3 trf_id=1    pass_regexp=Started Uplink

ADD nonVONRGBR
    [Arguments]    ${ue_id}=1    ${qos_flow}=10
    ADD QOS in same pdu SA   ue_id=2    pdu_id=1    qos_flow=${qos_flow}    pass_regexp=${pass_pdu1_add_71}
