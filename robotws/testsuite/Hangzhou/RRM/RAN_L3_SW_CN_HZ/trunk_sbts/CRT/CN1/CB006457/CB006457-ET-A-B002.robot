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

@{PARAMS_FOR_6457}
...    NRBTS:actArpBasedQosScaling=true
...    NRBTS:multiArpBasedParam:nbrUlDlSF=10|arpPrioLev=14
...    NRBTS:multiArpBasedParam:schedulingWeightSF=30|arpPrioLev=14
...    NRBTS:multiArpBasedParam:nbrUlDlSF=5|arpPrioLev=2
...    NRBTS:multiArpBasedParam:schedulingWeightSF=60|arpPrioLev=2
...    NRBTS:actNonGbrServiceDiff=true
...    NRCELL:actNbrForNonGbrBearers=true
...    NRCELL:maxNumOfNbrBearers=80
...    NRCELL:maxPrbsPerNbrUe=10
...    NRCELL:nbrPdcchCongHandlingDl=false
...    NRCELL:nbrPdcchCongHandlingUl=false
...    NRCELL:nbrPdschCongHandling=false
...    NRCELL:nbrPuschCongHandling=false
...    NRCELL:congDetectPeriod=ms500
...    NRCELL:congWeightAlg=arpPrioPerVul
...    NRCELL:maxNbrTrafficLimit=20
...    NRBTS/NRDRB-11:schedulWeight=10
...    NRBTS/NRDRB-12:schedulWeight=20
...    NRBTS/NRDRB-13:schedulWeight=20
...    NRBTS/NRDRB-14:schedulWeight=10
...    NRBTS/NRDRB-1:priorityLevel=15
...    NRBTS/NRDRB-11:priorityLevel=15
...    NRBTS/NRDRB-12:priorityLevel=15
...    NRBTS/NRDRB-13:priorityLevel=15
...    NRBTS/NRDRB-14:priorityLevel=15
...    NRBTS/NRDRB_MAC-2:nbrDl=10
...    NRBTS/NRDRB_MAC-2:nbrUl=5
...    NRBTS/NRDRB_MAC-2:schedulBSD=50ms
...    NRBTS:act5qiAndUlNguTnlQosFlowMod=true

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
...    NRPMRNL-1/NRPMQAP-1:cfgProfType=SA
...    NRPMRNL-1/NRPMQAP-1:cfg5qiRange=6
...    NRPMRNL-1/NRPMQAP-1:cfgArpRange=15
...    NRPMRNL-1/NRPMQAP-1:cfgPlmnId:mncLength=3
...    NRPMRNL-1/NRPMQAP-1:cfgPlmnId:mcc=311
...    NRPMRNL-1/NRPMQAP-1:cfgPlmnId:mnc=489
...    NRPMRNL-1/NRPMQAP-1:cfgSliceId:sst=1
...    NRPMRNL-1/NRPMQAP-1:cfgSliceId:sd=13714341
...    NRPMRNL-1/NRPMQAP-2:cfgProfType=SA
...    NRPMRNL-1/NRPMQAP-2:cfg5qiRange=5,1
...    NRPMRNL-1/NRPMQAP-2:cfgArpRange=15,1
...    NRPMRNL-1/NRPMQAP-2:cfgPlmnId:mncLength=3
...    NRPMRNL-1/NRPMQAP-2:cfgPlmnId:mcc=311
...    NRPMRNL-1/NRPMQAP-2:cfgPlmnId:mnc=489
...    NRPMRNL-1/NRPMQAP-2:cfgSliceId:sst=1
...    NRPMRNL-1/NRPMQAP-2:cfgSliceId:sd=13714341
...    NRPMRNL-1:miNrPdcpCellNrpmqap=5min

@{PARAMS_FOR_VoNR}
...    NRBTS:actNormVCFallback=false
...    NRULCLPC_PROFILE-1:nrUlClpcProfileId=1
...    NRCELL:actVoNR=true
...    NRCELL:actEnhancedVoNR=true
...    NRCELL:actAdaptVoipTbs=true
...    NRCELL:actCDrx=true
...    NRCELL:actCDrxVoNR=true
...    NRCELL:drxProfile1:drxInactivityTimer=40ms
...    NRCELL:drxProfile1:drxLongCycle=80ms
...    NRCELL:drxProfile1:drxOnDurationTimer=60ms
...    NRCELL:drxProfile1:drxRetransTimerDl=16slot
...    NRCELL:drxProfile1:drxRetransTimerUl=16slot
...    NRCELL:drxProfile2:drxInactivityTimer=6ms
...    NRCELL:drxProfile2:drxLongCycle=40ms
...    NRCELL:drxProfile2:drxOnDurationTimer=20ms
...    NRCELL:drxProfile2:drxRetransTimerDl=0slot
...    NRCELL:drxProfile2:drxRetransTimerUl=0slot
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
...    NRBTS/NRDRB-11:schedulWeight=50
...    NRBTS/NRDRB-12:schedulWeight=50
...    NRBTS/NRDRB-13:schedulWeight=50
...    NRBTS/NRDRB-14:schedulWeight=50
...    NRBTS/NRDRB-10:schedulWeight=50
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
...    NRBTS/NRDRB-17:schedulWeight=1
...    NRBTS/NRDRB-17:sduDiscardIntervalTmr=500
...    NRBTS/NRDRB-17:volThresDiscardDl=8000
...    NRBTS/NRDRB-17:volThresDiscardUl=800
...    NRBTS/NRDRB-17:l2OHFactorDl=16
...    NRBTS/NRDRB-17:l2OHFactorUl=35
...    NRBTS/NRDRB-17:nrDrbUlCgDN=MRBTS-1/NRBTS-1/NRULCG_PROFILE-7
...    NRBTS/NRDRB-17:cellAggrLevel=FR1 CA incompatible
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

*** Test Cases ***
CB006457-ET-A-B002_ARP_based_scaling_of_schedulWeight_and_NBR_for_non-GBR_SA_call_RRC_Reestablish_to_same_DU_after_ICS_and_pdu_setup_MultiQosFlow_TDD
    [Documentation]
    ...    1. The purpose of this test case is to check following scenarios:
    ...     This User Scenario validates the Allocation and Retention Priority (ARP) based scaling of the scheduling
    ...     weights for UEs with non-GBR bearers.
    ...     This User Scenario validates the Allocation and Retention Priority (ARP) based scaling of the nominal
    ...     bitrate (NBR) for UEs with non-GBR bearers.
    ...     NRBTS.actNonGbrServiceDiff = true: Enable non-GBR service differentiation (5GC000776/5GC001926)
    ...     NRBTS.NRCELL.actNbrForNonGbrBearers = true: Enable Nominal bitrate (CB008227)
    ...     NRBTS.actArpBasedQosScaling = true: Enable ARP based QoS scaling: (CB006457)
    ...    2.Test Case Steps:
    ...     Step A. UE1 registered to TDD cell1, PDU Session Resource Setup using the NGAP INITIAL CONTEXT SETUP to setup NRDRB-1( ArpPrioLev = 2),
    ...             UE2 registered to FDD cell2, PDU Session Resource Setup using the NGAP INITIAL CONTEXT SETUP( ArpPrioLev = 14) to setup NRDRB-2
    ...     Step B. start DL and UL data traffic for DRB-1 and DRB-2 for UE1 and UE2
    ...     Step C. AMF sends PDU SESSION SETUP REQUEST to setup NRDRB-3(ArpPrioLev = 2) for UE1
    ...     Step D. start DL and UL data traffic for DRB-3 for UE1
    ...     Step E. UE1 UE2 RRC Reestablish to CELL-2
    ...     Step F. release UE1 and UE2
    ...     Step G. Check counters
    ...    3. Expected Results:
    ...     Step A. UE1 setup DRB1 successfully, scaled scheduling weight is 10x6=60, scaled NBR is 10x0.5=5(DL), 5x0.5=2.5->3(UL)
    ...             UE2 setup DRB2 successfully, scaled scheduling weight is 20x3=60, scaled NBR is 10x1=10(DL), 5x1=5(UL)
    ...     Step B. The DL data rates of the non-GBR bearers are approximately in the ratio of the ARP scaled scheduling weights,
    ...             NBR is achieved for all non-GBR bearers. NBR statistics are updated to reflect the NBR allocations
    ...     Step C. DRB3 Add successfully, scaled scheduling weight is 20x6=120->100, scaled NBR is 10x0.5=5(DL), 5x0.5=2.5->3(UL)
    ...     Step D. The DL data rates of the non-GBR bearers are approximately in the ratio of the ARP scaled scheduling weights,
    ...             NBR is achieved for all non-GBR bearers. NBR statistics are updated to reflect the NBR allocations
    ...     Step E. RRC Reestablish successfully, UE1 DRB1 scaled scheduling weight is 10x6=60, scaled NBR is 10x0.5=5(DL), 5x0.5=2.5->3(UL)
    ...             UE1 DRB3 scaled scheduling weight is 20x6=120->100, scaled NBR is 10x0.5=5(DL), 5x0.5=2.5->3(UL)
    ...             UE2 DRB2 scaled scheduling weight is 20x3=60, scaled NBR is 10x1=10(DL), 5x1=5(UL)
    ...     Step G. Check counters successful
    [Tags]    A-B002    QC_362180
    set drb prio
    SA UE attach with drb    ue_id=1    cell_id=2    pdu_id=1    qos_flow=1    Tput_dl=125    Tput_ul=32
    SA UE attach with drb    ue_id=2    cell_id=1    pdu_id=1    qos_flow=2    Tput_dl=80    Tput_ul=47
    PDU Session Setup    ue_id=1    pdu_id=2    qos_flow=3
    verify tput for drb1 drb2 and drb3
    Trigger UE RRC Reestablish to Cell    tgt_cell_id=2    ue_id=1
    Trigger UE RRC Reestablish to Cell    tgt_cell_id=2    ue_id=2
    verify tput for drb1 drb2 and drb3 after reestab
    Release UEs    ue_type=all
    Check Wireshark Log    ${CURDIR}${/}A2A_A-B002${/}a2a.ini    wait_string=UEContextReleaseComplete::8

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/2cells_1T1F    ue_count=5

set drb prio
    Execute Egate Command    qosflow_modify qos_flow=1 priority=2
    Execute Egate Command    qosflow_modify qos_flow=3 priority=2
    Execute Egate Command    qosflow_modify qos_flow=2 priority=14
    Execute Egate Command    debug_log level=4

SA UE attach with drb
    [Arguments]    ${ue_id}=1    ${cell_id}=1    ${pdu_id}=1    ${qos_flow}=1    ${qfi_id}=1    ${Tput_dl}=120    ${Tput_ul}=8
    Execute Egate Command    ue_change_location id=${ue_id} cell=${cell_id} enb=2
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Registered state.
    Execute Egate Command    qosflow_modify qos_flow=${qos_flow} default=on
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=${ue_id} nwslice=1    pass_regexp=Initial Context Setup Successful
    Send Traffic SA    ue_id=${ue_id}    pdu_id=${pdu_id}    qfi_id=${qfi_id}
    Verify Pcell    ue_id=${ue_id}    pdu_id=${pdu_id}    qfi_id=${qfi_id}    Tput_dl=${Tput_dl}    Tput_ul=${Tput_ul}

Modify Cfg
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
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=ul mbps=50 trf_id=1    pass_regexp=Started Uplink

Verify Pcell
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${qfi_id}=1    ${Tput_dl}=120    ${Tput_ul}=8    ${sleep_time}=30s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=${qfi_id}    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=${qfi_id}    direction=ul    rate_type=ave
    ${scell_tput_dl}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-5 type=pdsch    Throughput
    ${scell_tput_ul}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-5 type=pusch    Throughput
    Log To Console    DL:${dl_throughput}
    Log To Console    UL:${ul_throughput}
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

verify tput for drb1 drb2 and drb3
    Verify Pcell    ue_id=1    pdu_id=1    qfi_id=1    Tput_dl=47    Tput_ul=15
    Verify Pcell    ue_id=1    pdu_id=2    qfi_id=1    Tput_dl=78    Tput_ul=15
    Verify Pcell    ue_id=2    pdu_id=1    qfi_id=1    Tput_dl=80    Tput_ul=47

verify tput for drb1 drb2 and drb3 after reestab
    Verify Pcell    ue_id=1    pdu_id=1    qfi_id=1    Tput_dl=26    Tput_ul=12
    Verify Pcell    ue_id=1    pdu_id=2    qfi_id=1    Tput_dl=43    Tput_ul=11
    Verify Pcell    ue_id=2    pdu_id=1    qfi_id=1    Tput_dl=25    Tput_ul=8

PDU Session Setup
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${qos_flow}=1    ${pass_regexp}=QoS Routing Table    ${fail_regexp}=None
    ...    ${qfi_id}=1
    Execute Egate Command    qosflow_modify qos_flow=${qos_flow} default=on
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=1 nwslice=1    pass_regexp=${pass_regexp}
    ...    fail_regexp=${fail_regexp}
    Send Traffic SA    ue_id=${ue_id}    pdu_id=${pdu_id}    qfi_id=${qfi_id}

Trigger UE RRC Reestablish to Cell
    [Arguments]    ${tgt_cell_id}    ${ue_id}=1
    Execute Egate Command    ue_rrc_reestablish id=${ue_id} gnb=2 cell=${tgt_cell_id} cause=otherFailure
    ...    pass_regexp=NR RRC Reestablishment sucessfully completed
