*** Settings ***
Documentation
...    author:  ruifang.zhu@nokia-sbell.com
...    contact: ruifang.zhu@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_VRF    RAN_5G    RAN_5G_TDD    SBTS00    CRT    CLOUD_5G_I_LO_AP_LO
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
...    NRBTS:actMultiDrbNSA=true
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
#...    NRPMRNL-1:miNrOranTrxStats=disabled
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
...    NRBTS/NRDRB_MAC-2:nbrDl=10000
...    NRBTS/NRDRB_MAC-2:nbrUl=5000
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
...    NRBTS:actThpDist=true
...    NRBTS:actIpThpt=true
...    NRBTS:actLatencyPmCount=true
...    NRPMRNL-1/NRPMQAP-1:cfgProfType=SA
...    NRPMRNL-1/NRPMQAP-1:cfg5qiRange=6
...    NRPMRNL-1/NRPMQAP-1:cfgArpRange=2
...    NRPMRNL-1/NRPMQAP-1:cfgPlmnId:mncLength=3
...    NRPMRNL-1/NRPMQAP-1:cfgPlmnId:mcc=311
...    NRPMRNL-1/NRPMQAP-1:cfgPlmnId:mnc=489
...    NRPMRNL-1/NRPMQAP-1:cfgSliceId:sst=1
...    NRPMRNL-1/NRPMQAP-1:cfgSliceId:sd=13714341

...    NRPMRNL-1/NRPMQAP-2:cfgProfType=SA
...    NRPMRNL-1/NRPMQAP-2:cfg5qiRange=7
...    NRPMRNL-1/NRPMQAP-2:cfgArpRange=14
...    NRPMRNL-1/NRPMQAP-2:cfgPlmnId:mncLength=3
...    NRPMRNL-1/NRPMQAP-2:cfgPlmnId:mcc=311
...    NRPMRNL-1/NRPMQAP-2:cfgPlmnId:mnc=489
...    NRPMRNL-1/NRPMQAP-2:cfgSliceId:sst=1
...    NRPMRNL-1/NRPMQAP-2:cfgSliceId:sd=13714341

...    NRPMRNL-1/NRPMQAP-3:cfgProfType=SA
...    NRPMRNL-1/NRPMQAP-3:cfg5qiRange=8
...    NRPMRNL-1/NRPMQAP-3:cfgArpRange=2
...    NRPMRNL-1/NRPMQAP-3:cfgPlmnId:mncLength=3
...    NRPMRNL-1/NRPMQAP-3:cfgPlmnId:mcc=311
...    NRPMRNL-1/NRPMQAP-3:cfgPlmnId:mnc=489
...    NRPMRNL-1/NRPMQAP-3:cfgSliceId:sst=1
...    NRPMRNL-1/NRPMQAP-3:cfgSliceId:sd=13714341

...    NRPMRNL-1/NRPMQAP-4:cfgProfType=SA
...    NRPMRNL-1/NRPMQAP-4:cfg5qiRange=6,7,8
...    NRPMRNL-1/NRPMQAP-4:cfgArpRange=2,14
...    NRPMRNL-1/NRPMQAP-4:cfgPlmnId:mncLength=3
...    NRPMRNL-1/NRPMQAP-4:cfgPlmnId:mcc=311
...    NRPMRNL-1/NRPMQAP-4:cfgPlmnId:mnc=489
...    NRPMRNL-1/NRPMQAP-4:cfgSliceId:sst=1
...    NRPMRNL-1/NRPMQAP-4:cfgSliceId:sd=13714341

...    NRPMRNL-1/NRPMQAP-5:cfgProfType=SA
...    NRPMRNL-1/NRPMQAP-5:cfg5qiRange=6
...    NRPMRNL-1/NRPMQAP-5:cfgArpRange=14
...    NRPMRNL-1/NRPMQAP-5:cfgPlmnId:mncLength=3
...    NRPMRNL-1/NRPMQAP-5:cfgPlmnId:mcc=311
...    NRPMRNL-1/NRPMQAP-5:cfgPlmnId:mnc=489
...    NRPMRNL-1/NRPMQAP-5:cfgSliceId:sst=1
...    NRPMRNL-1/NRPMQAP-5:cfgSliceId:sd=13714341

...    NRPMRNL-1/NRPMQAP-6:cfgProfType=SA
...    NRPMRNL-1/NRPMQAP-6:cfg5qiRange=8
...    NRPMRNL-1/NRPMQAP-6:cfgArpRange=14
...    NRPMRNL-1/NRPMQAP-6:cfgPlmnId:mncLength=3
...    NRPMRNL-1/NRPMQAP-6:cfgPlmnId:mcc=311
...    NRPMRNL-1/NRPMQAP-6:cfgPlmnId:mnc=489
...    NRPMRNL-1/NRPMQAP-6:cfgSliceId:sst=1
...    NRPMRNL-1/NRPMQAP-6:cfgSliceId:sd=13714341
...    NRPMRNL-1:miNrPdcpCellNrpmqap=5min

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
...    NRBTS/NRDRX-4:drxHarqRttTimerDl=0symbols
...    NRBTS/NRDRX-4:drxHarqRttTimerUl=0symbols
...    NRBTS/NRDRX-4:drxInactivityTimer=40ms
...    NRBTS/NRDRX-4:drxLongCycle=80ms
...    NRBTS/NRDRX-4:drxOnDurationTimer=60ms
...    NRBTS/NRDRX-4:drxPriority=16
...    NRBTS/NRDRX-4:drxRetransTimerDl=16slot
...    NRBTS/NRDRX-4:drxRetransTimerUl=16slot
...    NRBTS/NRDRB-11:nrDrxDN=MRBTS-1/NRBTS-1/NRDRX-4
...    NRBTS/NRDRB-13:nrDrxDN=MRBTS-1/NRBTS-1/NRDRX-4

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

${CA_support_list}    ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Any_Sa,ca_Fdd_Any_Sa,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Fdd,ca_Fdd_Fr1Tdd_Sa_WithUl,
...                   ca_Fr1Tdd_Fdd_Sa_WithUl,ca_Fdd_Fr1Tdd_Nsa,ca_Fr1Tdd_Fdd_Nsa
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

@{pass_A2}
...    eventId eventA3
...    gapUE setup
...    drx-Config release
...    rrcReconfigurationComplete

@{pass_ho}
...    gapUE release
...    Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.2 performed
...    drx-Config setup
...    drx-onDurationTimer milliSeconds : ms60
...    drx-InactivityTimer ms40
...    rrcReconfigurationComplete

@{PARAMS_for_dis6457}
...    NRBTS:actArpBasedQosScaling=false

@{PARAMS_for_en6457}
...    NRBTS:actArpBasedQosScaling=true

@{PARAMS_for_SWSF}
...    NRCELL:actNbrForNonGbrBearers=false
...    NRBTS:multiArpBasedParam:schedulingWeightSF=5|arpPrioLev=14
...    NRBTS:multiArpBasedParam:schedulingWeightSF=40|arpPrioLev=2
...    NRBTS:multiArpBasedParam:schedulingWeightSF=2|arpPrioLev=15
...    NRBTS:multiArpBasedParam:nbrUlDlSF=2|arpPrioLev=15

@{PARAMS_for_NBRSF}
...    NRBTS:multiArpBasedParam:nbrUlDlSF=100|arpPrioLev=14
...    NRBTS:multiArpBasedParam:nbrUlDlSF=80|arpPrioLev=2
...    NRBTS:multiArpBasedParam:nbrUlDlSF=30|arpPrioLev=15
...    NRCELL:actNbrForNonGbrBearers=true

@{PARAMS_for_recover_AB08}
...    NRBTS:multiArpBasedParam:nbrUlDlSF=50|arpPrioLev=14
...    NRBTS:multiArpBasedParam:schedulingWeightSF=30|arpPrioLev=14
...    NRBTS:multiArpBasedParam:nbrUlDlSF=50|arpPrioLev=2
...    NRBTS:multiArpBasedParam:schedulingWeightSF=60|arpPrioLev=2
...    delete:NRBTS:multiArpBasedParam:arpPrioLev=15
...    NRBTS:actArpBasedQosScaling=true
...    NRCELL:actNbrForNonGbrBearers=true
...    NRBTS-1/NRDRB-11:cellAggrLevel=FR1 CA eligible
...    NRBTS-1/NRDRB-12:cellAggrLevel=FR1 CA eligible
...    NRBTS-1/NRDRB-13:cellAggrLevel=FR1 CA eligible
...    NRBTS-1/NRDRB-14:cellAggrLevel=FR1 CA eligible
...    NRBTS/NRDRB_MAC-1:nbrDl=30000
...    NRBTS/NRDRB_MAC-1:nbrUl=10000
...    NRBTS/NRDRB_MAC-1:schedulBSD=50ms

${ue_nr_cap_SA_UE1}    SEPARATOR=
...    E9A09000575F5A13160003C4A0002C1262E003387A16009B20C39F30C7942C0E0980C0311C01EE3614606B04610D04083A41E006D6C98AB1A
...    1CF88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E007FE000C80000E0541B11B582308682041F283C0092D931541439F11
...    C78C00000000000040E1E04FFF800003FFE0000032000038002F0F1180038500000002C040801808D00A06500026018D1224489B1CF8600A0
...    233D068003C1C1401C0C02500700060240040603E008020000000100000200B036B2A68020800004B29282000032CA4A00A81D552AAA1A002
...    4006814000010100200404010021AA1F000102030406070A0B0C0D101112131418191B1C1D1F2125262728292A2D2F414182D0

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

@{PARAMS_IN_SWCONFIG}
...    0x5A0618=1
...    0x5A0619=1
...    0x5A0608=1

${Capa_LTE}    SEPARATOR=
...    A11FF82384C0C03850001C46000000122205C160601C46000002022205C2606018280388C00000824440B84C0C03850001846000184888100
...    5011A014003174003282449D1276C73E1C29D3B639F0E24E893B639F0E201B1CF86009020C6318400C4000100808010040201803040002010
...    100C018400010080801000020180308000201010020080403000

@{nsa_ue_attach_expect}
...    Successfully reconfigured dual connectivity
...    reported successful RA

@{PM_Counters_A-B002}
...    NRCELL-2/NRPMQAP-1:ACDSQ:${SA_DRB_DU_INI_REQ_PMQAP}=1
...    NRCELL-2/NRPMQAP-1:ACDSQ:${SA_DRB_DU_INI_SUC_PMQAP}=1
...    NRCELL-2/NRPMQAP-1:ACCSQ:${SA_DRB_CU_INI_REQ_PMQAP}=1
...    NRCELL-2/NRPMQAP-1:ACCSQ:${SA_DRB_CU_INI_SUC_PMQAP}=1
...    NRCELL-2/NRPMQAP-1:ACDSQ:${SA_DRB_DU_RRE_REQ_PMQAP}=1
...    NRCELL-2/NRPMQAP-1:ACDSQ:${SA_DRB_DU_RRE_SUC_PMQAP}=1
...    NRCELL-1/NRPMQAP-2:ACDSQ:${SA_DRB_DU_INI_REQ_PMQAP}=1
...    NRCELL-1/NRPMQAP-2:ACDSQ:${SA_DRB_DU_INI_SUC_PMQAP}=1
...    NRCELL-1/NRPMQAP-2:ACCSQ:${SA_DRB_CU_INI_REQ_PMQAP}=1
...    NRCELL-1/NRPMQAP-2:ACCSQ:${SA_DRB_CU_INI_SUC_PMQAP}=1
...    NRCELL-2/NRPMQAP-2:ACDSQ:${SA_DRB_DU_RRE_REQ_PMQAP}=1
...    NRCELL-2/NRPMQAP-2:ACDSQ:${SA_DRB_DU_RRE_SUC_PMQAP}=1
...    NRCELL-2/NRPMQAP-2:ACCSQ:${SA_DRB_CU_RRE_REQ_PMQAP}=1
...    NRCELL-2/NRPMQAP-2:ACCSQ:${SA_DRB_CU_RRE_SUC_PMQAP}=1
...    NRCELL-2/NRPMQAP-3:ACDSQ:${SA_DRB_DU_INI_REQ_PMQAP}=1
...    NRCELL-2/NRPMQAP-3:ACDSQ:${SA_DRB_DU_INI_SUC_PMQAP}=1
...    NRCELL-2/NRPMQAP-3:ACCSQ:${SA_DRB_CU_INI_REQ_PMQAP}=1
...    NRCELL-2/NRPMQAP-3:ACCSQ:${SA_DRB_CU_INI_SUC_PMQAP}=1
...    NRCELL-2/NRPMQAP-3:ACDSQ:${SA_DRB_DU_RRE_REQ_PMQAP}=1
...    NRCELL-2/NRPMQAP-3:ACDSQ:${SA_DRB_DU_RRE_SUC_PMQAP}=1
...    NRCELL-1/NRPMQAP-4:ACDSQ:${SA_DRB_DU_INI_REQ_PMQAP}=1
...    NRCELL-1/NRPMQAP-4:ACDSQ:${SA_DRB_DU_INI_SUC_PMQAP}=1
...    NRCELL-1/NRPMQAP-4:ACCSQ:${SA_DRB_CU_INI_REQ_PMQAP}=1
...    NRCELL-1/NRPMQAP-4:ACCSQ:${SA_DRB_CU_INI_SUC_PMQAP}=1
...    NRCELL-2/NRPMQAP-4:ACDSQ:${SA_DRB_DU_INI_REQ_PMQAP}=2
...    NRCELL-2/NRPMQAP-4:ACDSQ:${SA_DRB_DU_INI_SUC_PMQAP}=2
...    NRCELL-2/NRPMQAP-4:ACCSQ:${SA_DRB_CU_INI_REQ_PMQAP}=2
...    NRCELL-2/NRPMQAP-4:ACCSQ:${SA_DRB_CU_INI_SUC_PMQAP}=2
...    NRCELL-2/NRPMQAP-4:ACDSQ:${SA_DRB_DU_RRE_REQ_PMQAP}=3
...    NRCELL-2/NRPMQAP-4:ACDSQ:${SA_DRB_DU_RRE_SUC_PMQAP}=3
...    NRCELL-2/NRPMQAP-4:ACCSQ:${SA_DRB_CU_RRE_REQ_PMQAP}=1
...    NRCELL-2/NRPMQAP-4:ACCSQ:${SA_DRB_CU_RRE_SUC_PMQAP}=1

@{PM_Counters_A-B003}
...    NRCELL-1/NRPMQAP-1:ACDSQ:${SA_DRB_DU_INI_REQ_PMQAP}=1
...    NRCELL-1/NRPMQAP-1:ACDSQ:${SA_DRB_DU_INI_SUC_PMQAP}=1
...    NRCELL-1/NRPMQAP-1:ACCSQ:${SA_DRB_CU_INI_REQ_PMQAP}=1
...    NRCELL-1/NRPMQAP-1:ACCSQ:${SA_DRB_CU_INI_SUC_PMQAP}=1
...    NRCELL-2/NRPMQAP-1:ACDSQ:${SA_DRB_DU_HO_REQ_PMQAP}=1
...    NRCELL-2/NRPMQAP-1:ACDSQ:${SA_DRB_DU_HO_SUC_PMQAP}=1
...    NRCELL-2/NRPMQAP-1:ACCSQ:${SA_DRB_CU_HO_REQ_PMQAP}=1
...    NRCELL-2/NRPMQAP-1:ACCSQ:${SA_DRB_CU_HO_SUC_PMQAP}=1
...    NRCELL-2/NRPMQAP-2:ACDSQ:${SA_DRB_DU_INI_REQ_PMQAP}=1
...    NRCELL-2/NRPMQAP-2:ACDSQ:${SA_DRB_DU_INI_SUC_PMQAP}=1
...    NRCELL-2/NRPMQAP-2:ACCSQ:${SA_DRB_CU_INI_REQ_PMQAP}=1
...    NRCELL-2/NRPMQAP-2:ACCSQ:${SA_DRB_CU_INI_SUC_PMQAP}=1
...    NRCELL-2/NRPMQAP-5:ACDSQ:${SA_DRB_DU_INI_REQ_PMQAP}=1
...    NRCELL-2/NRPMQAP-5:ACDSQ:${SA_DRB_DU_INI_SUC_PMQAP}=1
...    NRCELL-2/NRPMQAP-5:ACCSQ:${SA_DRB_CU_INI_REQ_PMQAP}=1
...    NRCELL-2/NRPMQAP-5:ACCSQ:${SA_DRB_CU_INI_SUC_PMQAP}=1
...    NRCELL-2/NRPMQAP-6:ACDSQ:${SA_DRB_DU_INI_REQ_PMQAP}=1
...    NRCELL-2/NRPMQAP-6:ACDSQ:${SA_DRB_DU_INI_SUC_PMQAP}=1
...    NRCELL-2/NRPMQAP-6:ACCSQ:${SA_DRB_CU_INI_REQ_PMQAP}=1
...    NRCELL-2/NRPMQAP-6:ACCSQ:${SA_DRB_CU_INI_SUC_PMQAP}=1
...    NRCELL-1/NRPMQAP-3:ACDSQ:${SA_DRB_DU_INI_REQ_PMQAP}=1
...    NRCELL-1/NRPMQAP-3:ACDSQ:${SA_DRB_DU_INI_SUC_PMQAP}=1
...    NRCELL-1/NRPMQAP-3:ACCSQ:${SA_DRB_CU_INI_REQ_PMQAP}=1
...    NRCELL-1/NRPMQAP-3:ACCSQ:${SA_DRB_CU_INI_SUC_PMQAP}=1
...    NRCELL-2/NRPMQAP-3:ACDSQ:${SA_DRB_DU_HO_REQ_PMQAP}=1
...    NRCELL-2/NRPMQAP-3:ACDSQ:${SA_DRB_DU_HO_SUC_PMQAP}=1
...    NRCELL-2/NRPMQAP-3:ACCSQ:${SA_DRB_CU_HO_REQ_PMQAP}=1
...    NRCELL-2/NRPMQAP-3:ACCSQ:${SA_DRB_CU_HO_SUC_PMQAP}=1
...    NRCELL-1/NRPMQAP-4:ACDSQ:${SA_DRB_DU_INI_REQ_PMQAP}=2
...    NRCELL-1/NRPMQAP-4:ACDSQ:${SA_DRB_DU_INI_SUC_PMQAP}=2
...    NRCELL-1/NRPMQAP-4:ACCSQ:${SA_DRB_CU_INI_REQ_PMQAP}=2
...    NRCELL-1/NRPMQAP-4:ACCSQ:${SA_DRB_CU_INI_SUC_PMQAP}=2
...    NRCELL-2/NRPMQAP-4:ACDSQ:${SA_DRB_DU_INI_REQ_PMQAP}=3
...    NRCELL-2/NRPMQAP-4:ACDSQ:${SA_DRB_DU_INI_SUC_PMQAP}=3
...    NRCELL-2/NRPMQAP-4:ACCSQ:${SA_DRB_CU_INI_REQ_PMQAP}=3
...    NRCELL-2/NRPMQAP-4:ACCSQ:${SA_DRB_CU_INI_SUC_PMQAP}=3
...    NRCELL-2/NRPMQAP-4:ACDSQ:${SA_DRB_DU_HO_REQ_PMQAP}=2
...    NRCELL-2/NRPMQAP-4:ACDSQ:${SA_DRB_DU_HO_SUC_PMQAP}=2
...    NRCELL-2/NRPMQAP-4:ACCSQ:${SA_DRB_CU_HO_REQ_PMQAP}=2
...    NRCELL-2/NRPMQAP-4:ACCSQ:${SA_DRB_CU_HO_SUC_PMQAP}=2

${SA_DRB_DU_INI_REQ_PMQAP}    M55193C00001
# This counter provides the number of NR PMQAP profile data radio bearers (DRBs) for radio admission requests for an SA
# user in a DU during the initial access procedure.
${SA_DRB_DU_INI_SUC_PMQAP}    M55193C00002
# This counter provides the number of NR PMQAP profile data radio bearers (DRBs) for successful radio admission requests
# for an SA user in a DU during the initial access procedure.
${SA_DRB_DU_HO_REQ_PMQAP}    M55193C00003
# This counter provides the number of NR PMQAP profile data radio bearers (DRBs) for radio admission requests for an SA
# user in a DU during the incoming handover procedure.
${SA_DRB_DU_HO_SUC_PMQAP}    M55193C00004
# This counter provides the number of NR PMQAP profile data radio bearers (DRBs) for successful radio admission requests
# for an SA user in a DU during the incoming handover procedure.
${SA_DRB_DU_RRE_REQ_PMQAP}    M55193C00005
# This counter provides the number of NR PMQAP profile data radio bearers (DRBs) for radio admission requests for an SA
# user in a DU during the re-establishment procedure.
${SA_DRB_DU_RRE_SUC_PMQAP}    M55193C00006
# This counter provides the number of NR PMQAP profile data radio bearers (DRBs) for successful radio admission requests
# for an SA user in a DU during the re-establishment procedure.
${SA_DRB_CU_INI_REQ_PMQAP}    M55161C00008
# This counter provides the number of NR PMQAP profile data radio bearers (DRBs) for radio admission requests for an SA
# user in a CU during the initial access procedure.
${SA_DRB_CU_INI_SUC_PMQAP}    M55161C00009
# This counter provides the number of NR PMQAP profile data radio bearers (DRBs) for successful radio admission requests
# for an SA user in a CU during the initial access procedure.
${SA_DRB_CU_HO_REQ_PMQAP}    M55161C00010
# This counter provides the number of NR PMQAP profile data radio bearers (DRBs) for radio admission requests for an SA
# user in a CU during the incoming handover procedure.
${SA_DRB_CU_HO_SUC_PMQAP}    M55161C00011
# This counter provides the number of NR PMQAP profile data radio bearers (DRBs) for successful radio admission requests
# for an SA user in a CU during the incoming handover procedure.
${SA_DRB_CU_RRE_REQ_PMQAP}    M55161C00012
# This counter provides the number of NR PMQAP profile data radio bearers (DRBs) for radio admission requests for an SA
# user in a CU during the inter-cell re-establishment procedure.
${SA_DRB_CU_RRE_SUC_PMQAP}    M55161C00013
# This counter provides the number of NR PMQAP profile data radio bearers (DRBs) for successful radio admission requests
# for an SA user in a CU during the inter-cell re-establishment procedure.

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
    Clear Counter Files
    set drb prio
    SA UE attach with drb    ue_id=1    cell_id=2    pdu_id=1    qos_flow=1    Tput_dl=125    Tput_ul=32
    SA UE attach with drb    ue_id=2    cell_id=1    pdu_id=1    qos_flow=2    Tput_dl=80    Tput_ul=47
    PDU Session Setup    ue_id=1    pdu_id=2    qos_flow=3    Tput_dl=150    Tput_ul=50
    verify tput for drb1 drb2 and drb3
    Trigger UE RRC Reestablish to Cell    tgt_cell_id=2    ue_id=1
    Trigger UE RRC Reestablish to Cell    tgt_cell_id=2    ue_id=2
    verify tput for drb1 drb2 and drb3 after reestab
    Release UEs    ue_type=all
    Check Wireshark Log    ${CURDIR}${/}A2A_A-B002${/}a2a.ini    wait_string=UEContextReleaseComplete::8
    Check Counters    ${PM_Counters_A-B002}

CB006457-ET-A-B003_ARP based scaling of schedulWeight and NBR for non-GBR SA call intra-DU HO before and after pdu setup_Maxvaluecheck_MultiUE
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
    ...     Step D. AMF sends PDU SESSION SETUP REQUEST to setup NRDRB-3(ArpPrioLev = 14) for UE3
    ...     Step E. start DL and UL data traffic for DRB-3 for UE1
    ...     Step F. UE1 handover to CELL-2
    ...     Step G. release UE1, UE2 and UE3
    ...     Step H. Check counters
    ...    3. Expected Results:
    ...     Step A. UE1 setup DRB1 successfully, scaled scheduling weight is 10x6=60, scaled NBR is 10x0.5=5(DL), 5x0.5=2.5->3(UL)
    ...             UE2 setup DRB2 successfully, scaled scheduling weight is 20x3=60, scaled NBR is 10x1=10(DL), 5x1=5(UL)
    ...             UE3 setup DRB1 successfully, scaled scheduling weight is 10x3=30, scaled NBR is 10x1=10(DL), 5x1=5(UL)
    ...     Step B. The DL data rates of the non-GBR bearers are approximately in the ratio of the ARP scaled scheduling weights,
    ...             NBR is achieved for all non-GBR bearers. NBR statistics are updated to reflect the NBR allocations
    ...     Step C. UE1 DRB3 Add successfully, scaled scheduling weight is 20x6=120->100, scaled NBR is 10x0.5=5(DL), 5x0.5=2.5->3(UL)
    ...     Step D. UE3 DRB3 Add successfully, scaled scheduling weight is 20x3=60, scaled NBR is 10x1=10(DL), 5x1=5(UL)
    ...     Step E. The DL data rates of the non-GBR bearers are approximately in the ratio of the ARP scaled scheduling weights,
    ...             NBR is achieved for all non-GBR bearers. NBR statistics are updated to reflect the NBR allocations
    ...     Step F. UE1 handover to CELL-2 successfully.
    ...     Step H. Check counters successful
    [Tags]    A-B003    QC_363224
    Clear Counter Files
    set drb prio
    SA UE attach with drb    ue_id=1    cell_id=1    pdu_id=1    qos_flow=1    Tput_dl=80    Tput_ul=47
    SA UE attach with drb    ue_id=2    cell_id=2    pdu_id=1    qos_flow=2    Tput_dl=125    Tput_ul=32
    Execute Egate Command    qosflow_modify qos_flow=1 priority=14
    SA UE attach with drb    ue_id=3    cell_id=2    pdu_id=1    qos_flow=1    Tput_dl=40    Tput_ul=10
    Verify Pcell    ue_id=2    pdu_id=1    qfi_id=1    Tput_dl=0    Tput_ul=0
    PDU Session Setup    ue_id=1    pdu_id=2    qos_flow=3    Tput_dl=150    Tput_ul=50
    Execute Egate Command    qosflow_modify qos_flow=3 priority=14
    PDU Session Setup    ue_id=3    pdu_id=2    qos_flow=3    Tput_dl=150    Tput_ul=50
    verify tput for drb1 drb2 drb3 for ue1 ue2 ue3
    A2 A3 handover    ue_id=1    cellfreq=127210    cellfreq2=518670    phy_id=50    pass_A2=${pass_A2}    pass_ho=${pass_ho}
    verify tput for drb1 drb2 and drb3 after ho
    Release UEs    ue_type=all
    Check Wireshark Log    ${CURDIR}${/}A2A_A-B003${/}a2a.ini    wait_string=UEContextReleaseComplete::12
    Check Counters    ${PM_Counters_A-B003}

CB006457-ET-A-B008_online_modifyVfor_actArpBasedQosScaling_and_schedulingWeightSF_and_nominal_bitrate
    [Documentation]
    ...    1. The purpose of this test case is to check following scenarios:
    ...     This User Scenario validates the Allocation and Retention Priority (ARP) based scaling of the scheduling
    ...     weights for UEs with non-GBR bearers.
    ...     This User Scenario validates the Allocation and Retention Priority (ARP) based scaling of the nominal
    ...     bitrate (NBR) for UEs with non-GBR bearers.
    ...     This user scenario describes the gNB behaviour for the online modification of the feature activation flag
    ...     and the scheduling weight scaling factor (NRBTS.multiArpBasedPara.schedulingWeightSF).
    ...     This user scenario describes the gNB behaviour for the online modification of the feature activation flag
    ...     and the nominal bitrate scaling factor (NRBTS.multiArpBasedPara.nbrUlDlSF).
    ...     2.Test Case Steps:
    ...     Step A. UE1 setup SA call with NRDRB-1(ArpPrioLev = 2),
    ...             UE2 setup SA call with NRDRB-2(ArpPrioLev = 14)
    ...             UE11 setup NSA call with NRDRB-1(ArpPrioLev = 2),
    ...             UE12 setup NSA call with NRDRB-2(ArpPrioLev = 15)
    ...     Step B. start DL and UL data traffic for all UEs and check traffic
    ...     Step C. online change to NRBTS.actArpBasedQosScaling to disable
    ...     Step D. UE1 add NRDRB-3(ArpPrioLev = 2),UE2 add NRDRB-4(ArpPrioLev = 14),UE3 add NRDRB-11(ArpPrioLev = 15),
    ...     Step E. start DL and UL data traffic for all UEs and check traffic
    ...     Step F. delete NRDRB-3 of UE1,NRDRB-4 of UE2,NRDRB-11 of UE3
    ...     Step G. online change to NRBTS.actArpBasedQosScaling to enable
    ...     Step H. UE1 add NRDRB-3(ArpPrioLev = 2),UE2 add NRDRB-4(ArpPrioLev = 14),UE3 add NRDRB-11(ArpPrioLev = 15),
    ...             UE3 setup SA call with NRDRB-2(ArpPrioLev = 14), UE13 setup NSA call with NRDRB-1(ArpPrioLev = 2)
    ...     Step I. start DL and UL data traffic for all UEs and check traffic
    ...     Step J. online change to NRBTS.multiArpBasedPara.schedulingWeightSF
    ...     Step K. UE3 add NRDRB-3(ArpPrioLev = 2),UE13 add NRDRB-4(ArpPrioLev = 14)
    ...     Step L. start DL and UL data traffic for all UEs and check traffic
    ...     Step M. release NRDRB-3 of UE3,NRDRB-4 of UE13
    ...     Step N. online change to Online change NRBTS.multiArpBasedPara.nbrUlDlSF
    ...     Step O. UE3 add NRDRB-3(ArpPrioLev = 2),UE13 add NRDRB-4(ArpPrioLev = 14)
    ...     Step P. start DL and UL data traffic for all UEs and check traffic
    ...     Step Q. release NRDRB-3 of UE3,NRDRB-4 of UE13
    ...     Step R. release all ues
    ...     Step S. Check wireshark log
    ...    3. Expected Results:
    ...     Step A. all UE setup call successfully
    ...     Step B. traffic ok
    ...     Step C. online change successfully
    ...     Step D. UE add drb successfully
    ...     Step E. traffic ok
    ...     Step G. online change successfully
    ...     Step H. UE add drb successfully
    ...     Step I. traffic ok
    ...     Step J. online change successfully
    ...     Step K. UE add drb successfully
    ...     Step L. traffic ok
    ...     Step M. release drb successfully
    ...     Step N. online change successfully
    ...     Step O. UE add drb successfully
    ...     Step P. traffic ok
    ...     Step Q. release drb successfully
    ...     Step R. release all ues successfully
    ...     Step S. Check wireshark log successfully
    [Tags]    A-B008    QC_46953
    Execute Egate Command    sim_debug_log level=1 app_type=ueproxy
    Execute Egate Command    sim_debug_log level=0 uec=1
	Online param change    ${PARAMS_for_recover_AB08}
    set drb prio
    Check schedulingWeight and NBR when 6457 Enabled
    Check schedulingWeight and NBR when 6457 disabled
    Check schedulingWeight and NBR when 6457 online Enabled
    Check schedulingWeight and NBR when online modify SWSF
    Check schedulingWeight and NBR when online modify NBRULDLSF
    Release ues    ue_type=all
    Check Wireshark Log    ${CURDIR}${/}A2A_A-B008${/}a2a.ini
    [Teardown]    AB08_Teardown

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/2cells_1T1F    ue_count=5

AB08_Teardown
    Online param change    ${PARAMS_for_recover_AB08}
    Common Test Teardown And Stop Capture Logs

set drb prio
    Execute Egate Command    qosflow_modify qos_flow=1 priority=2
    Execute Egate Command    qosflow_modify qos_flow=3 priority=2
    Execute Egate Command    qosflow_modify qos_flow=2 priority=14
    Execute Egate Command    debug_log level=4
    Execute Egate Command    qosflow_modify qos_flow=4 priority=14

SA UE attach with drb
    [Arguments]    ${ue_id}=1    ${cell_id}=1    ${pdu_id}=1    ${qos_flow}=1    ${qfi_id}=1    ${Tput_dl}=120    ${Tput_ul}=8
    Execute Egate Command    ue_change_location id=${ue_id} cell=${cell_id} enb=2
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Registered state.
    Execute Egate Command    qosflow_modify qos_flow=${qos_flow} default=on
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=${ue_id} nwslice=1    pass_regexp=Initial Context Setup Successful
    Send Traffic SA    ue_id=${ue_id}    pdu_id=${pdu_id}    qfi_id=${qfi_id}    Tput_dl=${Tput_dl}    Tput_ul=${Tput_ul}

Modify Cfg
    Update Cfg    ue_nr_capabilities id=1 voice_over_nr=on:on:off
    Update Cfg    ue_param id=1 ue_nr_capabilities=${ue_nr_cap_SA_UE1}
    Update Cfg    ue_param id=2 ue_nr_capabilities=${ue_nr_cap_SA_UE1}
    Update Cfg    ue_param id=3 ue_nr_capabilities=${ue_nr_cap_SA_UE1}
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

Verify tput for NSA
    Verify Throughput pcell NSA    ue_id=11    bearer_id=3
    Verify Throughput pcell NSA    ue_id=12    bearer_id=4

Verify tput for SA
    Verify Pcell    ue_id=1    pdu_id=1    qfi_id=1    Tput_dl=0    Tput_ul=0
    Verify Pcell    ue_id=2    pdu_id=1    qfi_id=1    Tput_dl=0    Tput_ul=0

Stop All tput
    Stop Throughput SA    ue_id=1
    Stop Throughput SA    ue_id=2
    Stop Throughput SA    ue_id=3
    Stop Throughput NSA    ue_id=11
    Stop Throughput NSA    ue_id=12
    Stop Throughput NSA    ue_id=13

Send Traffic SA
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${qfi_id}=1    ${Tput_dl}=50    ${Tput_ul}=10
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=dl mbps=${Tput_dl} trf_id=1    pass_regexp=Started Downlink
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=ul mbps=${Tput_ul} trf_id=1    pass_regexp=Started Uplink

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
    Verify Pcell    ue_id=2    pdu_id=1    qfi_id=1    Tput_dl=78    Tput_ul=45

verify tput for drb1 drb2 and drb3 after reestab
    Verify Pcell    ue_id=1    pdu_id=1    qfi_id=1    Tput_dl=26    Tput_ul=10
    Verify Pcell    ue_id=1    pdu_id=2    qfi_id=1    Tput_dl=43    Tput_ul=10
    Verify Pcell    ue_id=2    pdu_id=1    qfi_id=1    Tput_dl=25    Tput_ul=8

PDU Session Setup
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${qos_flow}=1    ${pass_regexp}=QoS Routing Table    ${fail_regexp}=None
    ...    ${qfi_id}=1    ${Tput_dl}=150    ${Tput_ul}=50
    Execute Egate Command    qosflow_modify qos_flow=${qos_flow} default=on
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=1 nwslice=1    pass_regexp=${pass_regexp}
    ...    fail_regexp=${fail_regexp}
    Send Traffic SA    ue_id=${ue_id}    pdu_id=${pdu_id}    qfi_id=${qfi_id}    Tput_dl=${Tput_dl}    Tput_ul=${Tput_ul}

PDU Session Release
    [Arguments]    ${ue_id}=1    ${pdu}=1
    Execute Egate Command    ue_pdu_session_release ue=${ue_id} pdu=${pdu} by=amf    pass_regexp=rrcReconfigurationComplete

Trigger UE RRC Reestablish to Cell
    [Arguments]    ${tgt_cell_id}    ${ue_id}=1
    Execute Egate Command    ue_rrc_reestablish id=${ue_id} gnb=2 cell=${tgt_cell_id} cause=otherFailure
    ...    pass_regexp=NR RRC Reestablishment sucessfully completed

A2 A3 handover
    [Arguments]    ${ue_id}=1    ${cellfreq}=518670    ${cellfreq2}=127210    ${phy_id}=60    ${pass_A2}=none    ${pass_ho}=none
    ${A2}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cellfreq}    event_type=A2
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${A2} event=A2 srsrp_nr=5
    ...    pass_regexp=${pass_A2}
    ${A3}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cellfreq2}    event_type=A3
    ${event_cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${A3} event=A3 srsrp_nr=5 srsrq_nr=11
    ...    phycell_id=${phy_id} nrsrp_nr=90 nrsrq_nr=80
    Execute Egate Command    ${event_cmd}    pass_regexp=${pass_ho}

verify tput for drb1 drb2 drb3 for ue1 ue2 ue3
    Verify Pcell    ue_id=1    pdu_id=1    qfi_id=1    Tput_dl=28    Tput_ul=28
    Verify Pcell    ue_id=1    pdu_id=2    qfi_id=1    Tput_dl=50    Tput_ul=28
    Verify Pcell    ue_id=2    pdu_id=1    qfi_id=1    Tput_dl=40    Tput_ul=10
    Verify Pcell    ue_id=3    pdu_id=1    qfi_id=1    Tput_dl=25    Tput_ul=8
    Verify Pcell    ue_id=3    pdu_id=2    qfi_id=1    Tput_dl=50    Tput_ul=8

verify tput for drb1 drb2 and drb3 after ho
    Verify Pcell    ue_id=1    pdu_id=1    qfi_id=1    Tput_dl=5    Tput_ul=7
    Verify Pcell    ue_id=1    pdu_id=2    qfi_id=1    Tput_dl=38    Tput_ul=7
    Verify Pcell    ue_id=2    pdu_id=1    qfi_id=1    Tput_dl=26    Tput_ul=5
    Verify Pcell    ue_id=3    pdu_id=1    qfi_id=1    Tput_dl=12    Tput_ul=4
    Verify Pcell    ue_id=3    pdu_id=2    qfi_id=1    Tput_dl=28    Tput_ul=4

Del QOS in same pdu SA
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${qos_flow}=3,10    ${pass_regexp}=QoS Routing Table
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_del=${qos_flow} by=amf    pass_regexp=${pass_regexp}

NSA UE Attach To Sim Enb1 And Start ENDC
    [Arguments]    ${ue_id}=11    ${target_gnb}=1    ${target_cells}=2    ${bearer_id}=2    ${target_enb}=3
    ...    ${pass_AT}=${nsa_ue_attach_expect}    ${qci}=6    ${priority}=2
    Execute Egate Command    ue_change_location id=${ue_id} enb=1 cell=${target_enb}
    Execute Egate Command    ue_attach id=${ue_id}    pass_regexp=UE${ue_id}: === UE IS ACTIVE
    Execute Egate Command    ue_disp id=${ue_id}    timeout=20s
    Execute Egate Command    bearer_mod ue=${ue_id} id=${bearer_id} priority=${priority} qci=${qci}
    ${cmd}     Catenate    ue_dc_enb_start ue=${ue_id} target_gnb=${target_gnb}
    ...    target_cells=${target_cells} bearer=${bearer_id} type=split_scg
    Execute Egate Command    ${cmd}    pass_regexp=${pass_AT}    timeout=20s
    Send Throughput NSA    ue_id=${ue_id}    bearer_id=${bearer_id}

Send Throughput NSA
    [Arguments]    ${ue_id}=31    ${bearer_id}=1
    Execute Egate Command    trf_data_start ue=${ue_id} id=${bearer_id} dir=dl mbps=50 trf_id=1    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} id=${bearer_id} dir=ul mbps=10 trf_id=1    UE ${ue_id}: UDP UL

Verify Throughput pcell NSA
    [Arguments]     ${ue_id}=31    ${bearer_id}=1    ${dl}=0    ${ul}=0
    sleep    15s
    ${dl_throuput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=${bearer_id}    direction=dl    dc_cell_group=all    rate_type=ave
    ${ul_throuput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=${bearer_id}    direction=ul    dc_cell_group=all    rate_type=ave
    Should Be True    ${dl_throuput}/1000 > ${dl}
    Should Be True    ${ul_throuput}/1000 > ${ul}


Online param Change
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be Onair    check_sib=${True}

ADD QOS in same pdu SA
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${qos_flow}=10    ${pass_regexp}=QoS Routing Table
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_add=${qos_flow} by=amf
    ...    pass_regexp=${pass_regexp}
    Send Traffic SA    ue_id=${ue_id}    pdu_id=${pdu_id}    qfi_id=2

ADD Bearers NSA
    [Arguments]    ${ue_id}=31    ${bearer_id}=1    ${pass_regexp}=Successfully reconfigured dual connectivity    ${fail_regexp}=none
    Execute Egate Command    enb_ue_dc_modify ue=${ue_id} bearer_to_add=${bearer_id} by=enb cause=RN_action_desirable_for_radio_reasons
    ...    pass_regexp=${pass_regexp}    fail_regexp=${fail_regexp}
    Send Throughput NSA    ue_id=${ue_id}    bearer_id=${bearer_id}

Stop Throughput NSA
    [Arguments]    ${ue_id}=11
    Execute Egate Command    trf_data_stop ue=${ue_id}

Stop Throughput SA
    [Arguments]    ${ue_id}=1
    Execute Egate Command    trf_data_stop ue=${ue_id}

Release DRB NSA
    [Arguments]    ${ue_id}=11    ${bearer_id}=3
    Execute Egate Command    enb_ue_dc_modify ue=${ue_id} bearer_to_release=${bearer_id} by=enb cause=RN_action_desirable_for_radio_reasons
    ...    pass_regexp=rrcConnectionReconfigurationComplete

Check schedulingWeight and NBR when 6457 Enabled
    SA UE attach with drb    ue_id=1    cell_id=2    pdu_id=1    qos_flow=1    Tput_dl=50    Tput_ul=10
    SA UE attach with drb    ue_id=2    cell_id=2    pdu_id=1    qos_flow=2    Tput_dl=50    Tput_ul=10
    NSA UE Attach To Sim Enb1 And Start ENDC    ue_id=11    target_gnb=2    target_cells=2    bearer_id=3    qci=6    priority=2
    NSA UE Attach To Sim Enb1 And Start ENDC    ue_id=12    target_gnb=2    target_cells=2    bearer_id=4    qci=7    priority=15
    Verify tput for NSA
    Verify tput for SA
    sleep    30s
    Stop All tput

Check schedulingWeight and NBR when 6457 disabled
    Online param change    ${PARAMS_for_dis6457}
    ADD QOS in same pdu SA   ue_id=1    pdu_id=1    qos_flow=3
    ADD QOS in same pdu SA   ue_id=2    pdu_id=1    qos_flow=4
    ADD Bearers NSA    ue_id=11    bearer_id=5
    Verify Pcell    ue_id=1    pdu_id=1    qfi_id=2    Tput_dl=0    Tput_ul=0
    Verify Pcell    ue_id=2    pdu_id=1    qfi_id=2    Tput_dl=0    Tput_ul=0
    Verify Throughput pcell NSA    ue_id=11    bearer_id=5
    Stop All tput
    Del QOS in same pdu SA   ue_id=1    pdu_id=1    qos_flow=3
    sleep    5s
    Del QOS in same pdu SA   ue_id=2    pdu_id=1    qos_flow=4
    sleep    5s
    Release DRB NSA    ue_id=11    bearer_id=5

Check schedulingWeight and NBR when 6457 online Enabled
    Online param change    ${PARAMS_for_en6457}
    ADD QOS in same pdu SA   ue_id=1    pdu_id=1    qos_flow=3
    ADD QOS in same pdu SA   ue_id=2    pdu_id=1    qos_flow=4
    ADD Bearers NSA    ue_id=11    bearer_id=5
    SA UE attach with drb    ue_id=3    cell_id=2    pdu_id=1    qos_flow=2    Tput_dl=50    Tput_ul=10
    NSA UE Attach To Sim Enb1 And Start ENDC    ue_id=13    target_gnb=2    target_cells=2    bearer_id=3    qci=6    priority=2
    Verify Pcell    ue_id=1    pdu_id=1    qfi_id=2    Tput_dl=0    Tput_ul=0
    Verify Pcell    ue_id=2    pdu_id=1    qfi_id=2    Tput_dl=0    Tput_ul=0
    Verify Throughput pcell NSA    ue_id=11    bearer_id=5
    Verify Pcell    ue_id=3    pdu_id=1    qfi_id=1    Tput_dl=0    Tput_ul=0
    Verify Throughput pcell NSA    ue_id=13    bearer_id=3
    Stop All tput

Check schedulingWeight and NBR when online modify SWSF
    Send Throughput NSA    ue_id=13    bearer_id=3
    Online param change    ${PARAMS_for_SWSF}
    PDU Session Setup    ue_id=3    pdu_id=2    qos_flow=3    Tput_dl=50    Tput_ul=10
    ADD Bearers NSA    ue_id=13    bearer_id=5
    Verify Pcell    ue_id=3    pdu_id=2    qfi_id=1    Tput_dl=0    Tput_ul=0
    Verify Throughput pcell NSA    ue_id=13    bearer_id=5
    Stop All tput
    PDU Session Release    ue_id=3    pdu=2
    Release DRB NSA    ue_id=13    bearer_id=5

Check schedulingWeight and NBR when online modify NBRULDLSF
    Online param change    ${PARAMS_for_NBRSF}
    PDU Session Setup    ue_id=3    pdu_id=2    qos_flow=3    Tput_dl=50    Tput_ul=10
    ADD Bearers NSA    ue_id=13    bearer_id=5
    Verify Pcell    ue_id=3    pdu_id=2    qfi_id=1    Tput_dl=0    Tput_ul=0
    Verify Throughput pcell NSA    ue_id=13    bearer_id=5
    Stop All tput
    PDU Session Release    ue_id=3    pdu=2
    Release DRB NSA    ue_id=13    bearer_id=5
    stop capture wireshark log
