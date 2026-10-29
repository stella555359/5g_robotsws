*** Settings ***
Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    RAN_5G    RAN_5G_TDD    CRT    SBTS00
...               owner-fan.jolin    owner-mao.cathy    team-SG2    release-SBTS22R2    5GC000732
...               CLOUD_5G_I_BOO_AP_LOO
Resource          ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
${TL_TYPE_PATH}    fddtdd_sansa_cmwv/6cells_2T4F


@{DRB}
...    NRCELL-1:actVoNR=true
...    NRCELL-2:actVoNR=true
...    NRBTS:actNormVCFallback=false
...    NRCELL:actK1Opt=intra-gNB
...    NRPMRNL-1:miNrRelReportCu=15min
...    NRBTS-1/NRDRB-15:dlFlowControlAlgo=none
...    NRBTS-1/NRDRB-15:dscp=46
...    NRBTS-1/NRDRB-15:l2OHFactorDl=16
...    NRBTS-1/NRDRB-15:l2OHFactorUl=35
...    NRBTS-1:tWaitingRlRecover=4000ms
...    NRBTS-1/NRDRB-15:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-3
...    NRBTS-1/NRDRB-15:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-2
...    NRBTS-1/NRDRB-15:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRBTS-1/NRDRB-15:numSduDiscard=1
...    NRBTS-1/NRDRB-15:queuingDelayDiscarding=Disabled
...    NRBTS-1/NRDRB-15:queuingDelaySduDiscardThreshold=750
...    NRBTS-1/NRDRB-15:resType=GBR
...    NRBTS-1/NRDRB-15:rlcMode=RLC_UM
...    NRBTS-1/NRDRB-15:sduDiscardIntervalTmr=500
...    NRBTS-1/NRDRB-15:schedulWeight=1
...    NRBTS-1/NRDRB-15:actDddsReduction=false
...    NRBTS-1/NRDRB-15:maxRlcQueueingDelayGbr=20
...    NRBTS-1/NRDRB-15:actLostPduFastRetx=false
...    NRBTS-1/NRDRB-15:maxDddsPeriodCpuOvld=40
...    NRBTS-1/NRDRB-15:durationThresDiscardDl=40
...    NRBTS-1/NRDRB-15:durationThresDiscardUl=20
...    NRBTS-1/NRDRB-15:volThresDiscardDl=8000
...    NRBTS-1/NRDRB-15:volThresDiscardUl=800
...    NRBTS-1/NRDRB-15:maxTransferDelayGbr=20
...    NRBTS-1/NRDRB-15:discardTimer=100ms
...    NRBTS-1/NRDRB-15:maxDataRateGbrUl=1000
...    NRBTS-1/NRDRB-15:maxDataRateGbrDl=1000
...    NRBTS-1/NRDRB_PDCP-3:tReorderingDl=ms300
...    NRBTS-1/NRDRB_PDCP-3:tReorderingUl=ms300
...    NRBTS-1/NRDRB_PDCP-3:pdcpBufDiscardEnabled=false
...    NRBTS-1/NRDRB_PDCP-3:maxCidAllowed=4
...    NRBTS-1/NRDRB_RLC_UM-1:dlTReassemblyUm=ms40
...    NRBTS-1/NRDRB_RLC_UM-1:ulTReassemblyUm=ms40
...    NRBTS-1/NRDRB_RLC_UM-1:rlcUMDrbSNLength=rlcUm12bitSN
...    NRBTS-1/NRDRB_MAC-2:lcgid=2
...    NRBTS-1/NRDRB_MAC-2:schedulPrio=5
...    NRBTS-1/NRDRB_MAC-4:lcgid=2
...    NRBTS-1/NRDRB_MAC-4:schedulPrio=4
...    NRBTS-1/NRDRB_MAC-3:lcgid=4
...    NRBTS-1/NRDRB_MAC-3:schedulPrio=5
...    NRBTS-1/NRDRB_MAC-3:prioritisedBitRate=16kBps
...    NRBTS-1/NRDRB_5QI-6:fiveqiValueList=1
...    NRBTS-1/NRDRB_5QI-6:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-15

@{PARAMS_FOR_5QI1}
...    NRCELL-1:actVoNR=true
...    NRCELL-2:actVoNR=true
...    NRBTS:actNormVCFallback=false
...    NRCELL:actK1Opt=intra-gNB
...    NRPMRNL-1:miNrRelReportCu=15min
...    NRBTS-1:tWaitingRlRecover=4000ms
...    NRBTS/NRDRB_5QI-6:fiveqiValueList=1
...    NRBTS/NRDRB_5QI-6:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-15
...    NRBTS/NRDRB-15:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-4
...    NRBTS/NRDRB-15:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-3
...    NRBTS/NRDRB-15:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRBTS/NRDRB-15:dlFlowControlAlgo=none
...    NRBTS/NRDRB-15:dscp=46
...    NRBTS/NRDRB-15:maxDddsPeriodCpuOvld=40
...    NRBTS/NRDRB-15:numSduDiscard=1
...    NRBTS/NRDRB-15:queuingDelayDiscarding=Disabled
...    NRBTS/NRDRB-15:queuingDelaySduDiscardThreshold=200
...    NRBTS/NRDRB-15:resType=GBR
...    NRBTS/NRDRB-15:rlcMode=RLC_UM
...    NRBTS/NRDRB-15:schedulWeight=1
...    NRBTS/NRDRB-15:sduDiscardIntervalTmr=100
...    NRBTS/NRDRB-15:maxDataRateGbrDl=1000
...    NRBTS/NRDRB-15:maxDataRateGbrUl=1000
...    NRBTS/NRDRB_MAC-4:lcgid=4
...    NRBTS/NRDRB_MAC-4:schedulPrio=4
...    NRBTS/NRDRB_RLC_UM-1:dlTReassemblyUm=ms40
...    NRBTS/NRDRB_RLC_UM-1:ulTReassemblyUm=ms40
...    NRBTS/NRDRB_PDCP-3:tReorderingDl=ms300
...    NRBTS/NRDRB_PDCP-3:tReorderingUl=ms300
...    NRBTS/NRDRB_PDCP-3:pdcpBufDiscardEnabled=false

@{PARAMS_IN_SCF}
#...    @{PARAMS_FOR_5QI1}
...    @{DRB}
...    NRBTS-1:rrcReestabTypeSA=sameGNB
...    NRBTS-1:actRedirect=true

...    NRBTS-1:drbInactivityTimerSA=7200
...    NRBTS-1:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS-1:actInterFreqHoSA=true
...    NRBTS-1:actIntraFreqHoSA=true
...    NRBTS-1:tRLFindForDUVoNR=500ms
...    NRBTS-1:actLocationReportingSA=true
...    NRBTS-1:timerXnDataFwdGuard=250
...    NRCELL-11/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-10:gNbId=1
...    NRCELL-11/NRREL-10:gNbIdLength=22
...    NRCELL-11/NRREL-10:lcrId=1
...    NRCELL-11/NRREL-10:removeNotAllowed=false
...    NRCELL-11/NRREL-10:nrDcAllowed=false
...    NRCELL-11/NRREL-10:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-10:gnbPlmn:mncLength=3
...    NRPMRNL:miNrRelReportCu=15min
...    NRCELL-11:a1MeashoEnabledSA=rsrp
...    NRCELL-11:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=40
...    NRCELL-11:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRCELL-11:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms0
...    NRCELL-11:a2MeashoEnabledSA=rsrp
...    NRCELL-11:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=25
...    NRCELL-11:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0
...    NRCELL-11:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms0
...    NRCELL-11:a1MeasSCellAddEnabled=rsrp
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=1
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=32
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=33
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=480ms
...    NRCELL-11:a3MeasEnabled=rsrp
...    NRCELL-11:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRCELL-11:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL-11:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL-11:a5MeasEnabled=rsrp
...    NRCELL-11:a5MeasSsbRsrp:a5HysteresisSsbRsrp=10
...    NRCELL-11:a5MeasSsbRsrp:a5Threshold1SsbRsrp=30
...    NRCELL-11:a5MeasSsbRsrp:a5Threshold2SsbRsrp=55
...    NRCELL-11:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms0
...    NRCELL-11:a2MeasRedirectEnabled=rsrp
...    NRCELL-11:a2MeasRedirectSsbRsrp:a2ThresholdRedirectSsbRsrp=34
...    NRCELL-11:a2MeasRedirectSsbRsrp:a2HysteresisRedirectSsbRsrp=0
...    NRCELL-11:a2MeasRedirectSsbRsrp:a2TimeToTriggerRedirectSsbRsrp=ms480
...    NRCELL-11:t310VoNR=500ms
...    NRCELL-11:emergencyCallRestrictions:emergencyCallMrListIgnore=true
...    NRCELL-11:emergencyCallRestrictions:emergencyCallPlmnHoAllowed=true
...    NRCELL-11:emergencyCallLimServ=true
...    NRCELL-11:n310VoNR=n3
...    NRCELL-11:arpPrioEmergencyCall=1
...    NRCELL-11:actEnhancedVoNR=true
...    NRCELL-11:maxGBRTrafficLimit=75
...    NRCELL-11:actGBRAdmissionControl=EnhancedVoNR
...    NRCELL-11:actVoNrMobilityThresholds=VoNrMobilityThresholds
...    NRCELL-11:actVoNR=true
...    NRCELL-11:actCDrx=true
...    NRCELL-11:drxProfile2:drxInactivityTimer=8ms
...    NRCELL-11:drxProfile2:drxLongCycle=40ms
...    NRCELL-11:drxProfile2:drxOnDurationTimer=8ms
...    NRCELL-11:drxProfile2:drxRetransTimerDl=0slot
...    NRCELL-11:drxProfile2:drxRetransTimerUl=0slot
...    NRCELL-11:actEmergencyCall=true
...    NRCELL-11:actCDrxVoNR=true
...    NRCELL-11:actPrachMultiplexing=true
...    NRCELL:actPrachMultiplexing=true
...    NRCELL-11/NRREDRT-0:redirFreqNr=518910
...    NRCELL-11/NRREDRT-0:redirPrio=1
...    NRCELL-11/NRREDRT-0:redirRat=nr
...    NRCELL-11/NRREDRT-0:redirSsbScs=30 KHz
...    NRCELL-11/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-11/NRHOIF-1:freqBandIndicatorNR=71
...    NRCELL-11/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-11/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-11/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-11/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-11/NRHOIF-1:scs=15 KHz
...    NRCELL-11/NRHOIF-1:ssBurstSetPeriod=10
...    NRCELL-11/NRHOIF-1:ssbFrequency=126750
...    NRCELL-11/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=3
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=30
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms40
...    NRCELL-11/NRHOIF-1:a5MeasEnabled=rsrp
...    NRCELL-11/NRHOIF-1:a5MeasSsbRsrp:a5HysteresisSsbRsrp=20
...    NRCELL-11/NRHOIF-1:a5MeasSsbRsrp:a5Threshold1SsbRsrp=60
...    NRCELL-11/NRHOIF-1:a5MeasSsbRsrp:a5Threshold2SsbRsrp=110
...    NRCELL-11/NRHOIF-1:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms5120
...    NRCELL-11/NRHOIF-1:a1BasedPCellSwitchEnabled=false
...    NRBTS:actInterFreqHoSA=true
...    NRBTS:actIntraFreqHoSA=true
...    NRBTS:timerXnDataFwdGuard=250
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS:actRedirect=true
...    NRBTS:drbInactivityTimerSA=7200
...    NRBTS:actLocationReportingSA=true
...    NRBTS:tRLFindForDUVoNR=500ms

...    NRDU-1:actConnectedModeMobilityCA=true
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:actInterNumerologyCa=true
...    NRDU-1:carrierAggregationSupportList=ca_Fdd_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa
...    NRCELL-1:a2MeasSCellRelEnabled=rsrp
...    NRCELL-1:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=1
...    NRCELL-1:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=36
...    NRCELL-1:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=40ms
...    NRCELL-1:a1MeasPCellSwitchEnabled=rsrp
...    NRCELL-1:a1MeasPCellSwitchSsbRsrp:a1HysteresisPCellSwitchSsbRsrp=0
...    NRCELL-1:a1MeasPCellSwitchSsbRsrp:a1ThresholdPCellSwitchSsbRsrp=35
...    NRCELL-1:a1MeasPCellSwitchSsbRsrp:a1TimeToTriggerPCellSwitchSsbRsrp=0ms
...    NRCELL-1:actPrachMultiplexing=true
...    NRCELL-2/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-10:gNbId=1
...    NRCELL-2/NRREL-10:gNbIdLength=22
...    NRCELL-2/NRREL-10:lcrId=12
...    NRCELL-2/NRREL-10:removeNotAllowed=false
...    NRCELL-2/NRREL-10:nrDcAllowed=false
...    NRCELL-2/NRREL-10:sCellAdditionMethod=blind
...    NRCELL-2/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-10:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-1:gNbId=1
...    NRCELL-11/NRREL-1:gNbIdLength=22
...    NRCELL-11/NRREL-1:lcrId=12
...    NRCELL-11/NRREL-1:removeNotAllowed=false
...    NRCELL-11/NRREL-1:nrDcAllowed=false
...    NRCELL-11/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-2/NRHOIF-1:a1BasedPCellSwitchEnabled=false
...    NRCELL-2/NRHOIF-1:a2BasedPCellSwitchEnabled=false
...    NRCELL-2/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-2/NRHOIF-1:freqBandIndicatorNR=71
...    NRCELL-2/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-2/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-2/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf5
...    NRCELL-2/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-2/NRHOIF-1:scs=15 KHz
...    NRCELL-2/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-2/NRHOIF-1:ssbFrequency=126750
...    NRCELL-2/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrpVoNr=3
...    NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrpVoNr=30
...    NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrpVoNr=ms40
...    NRCELL-2:actCDrx=true
...    NRCELL-2:actVoNR=true
...    NRCELL-2:actCDrxVoNR=true
...    NRCELL-2:actEmergencyCall=true
...    NRCELL-2:actEnhancedVoNR=true
...    NRCELL-2:actGBRAdmissionControl=EnhancedVoNR
...    NRCELL-2:actVoNrMobilityThresholds=VoNrMobilityThresholds
...    NRCELL-2:n310VoNR=n3
...    NRCELL-2:t310VoNR=500ms
...    NRCELL-2:emergencyCallLimServ=true
...    NRCELL-2:maxGBRTrafficLimit=75
...    NRCELL-2:arpPrioEmergencyCall=1
...    NRCELL-2:emergencyCallRestrictions:emergencyCallMrListIgnore=true
...    NRCELL-2:emergencyCallRestrictions:emergencyCallPlmnHoAllowed=true
...    NRCELL-2:drxProfile2:drxInactivityTimer=4ms
...    NRCELL-2:drxProfile2:drxLongCycle=40ms
...    NRCELL-2:drxProfile2:drxOnDurationTimer=4ms
...    NRCELL-2:drxProfile2:drxRetransTimerDl=0slot
...    NRCELL-2:drxProfile2:drxRetransTimerUl=0slot
...    NRCELL-2:a1MeashoEnabledSA=rsrp
...    NRCELL-2:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRCELL-2:a1MeashoSsbRsrpSA:a1HysteresisHoSsbRsrpVoNr=0
...    NRCELL-2:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=60
...    NRCELL-2:a1MeashoSsbRsrpSA:a1ThresholdHoSsbRsrpVoNr=55
...    NRCELL-2:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL-2:a1MeashoSsbRsrpSA:a1TimeToTriggerHoSsbRsrpVoNr=ms40
...    NRCELL-2:a2MeashoEnabledSA=rsrp
...    NRCELL-2:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0
...    NRCELL-2:a2MeashoSsbRsrpSA:a2HysteresisHoSsbRsrpVoNr=0
...    NRCELL-2:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=34
...    NRCELL-2:a2MeashoSsbRsrpSA:a2ThresholdHoSsbRsrpVoNr=55
...    NRCELL-2:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL-2:a2MeashoSsbRsrpSA:a2TimeToTriggerHoSsbRsrpVoNr=ms40
...    NRCELL-2:a3MeasEnabled=rsrp
...    NRCELL-2:a5MeasEnabled=rsrp
...    NRCELL-2:actPrachMultiplexing=true
...    NRBTS-1/NRDRB_PDCP-2:pdcpBufDiscardEnabled=false
...    NRBTS-1/NRDRB_5QI-6:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-15
...    NRBTS-1/NRDRB_PDCP:maxCidAllowed=4


@{Delta_Scf_F018}
...    delete:NRCELL-2/NRREL-10:sCellAdditionMethod

@{PM_COUNTER_CHECK}
...    ${REESTAB_ACC_OTHER_FAIL_DU}=2
...    ${RRC_REESTAB_OTHER_FAILURE_DU}=2
...    NRCELL-11:${RRC_REESTAB_OTHER_FAILURE}=1
...    NRCELL-2:${RRC_REESTAB_OTHER_FAILURE}=1
...    NRCELL-11:${REESTAB_ACC_OTHER_FAIL}=1
...    NRCELL-2:${REESTAB_ACC_OTHER_FAIL}=1
...    NRCELL-11:${REESTAB_RRCRECONFIG_SUCC}=1
...    NRCELL-2:${REESTAB_RRCRECONFIG_SUCC}=1
...    NRCELL-11:${UE_PCELL_1_CONF_SCELL_DL_SA}>0
...    NRCELL-1:${UE_SCELL_1_CONF_SCELL_DL_SA}>0
...    NRCELL-11:${SAMPLES_UE_AMOUNTS}>0
...    NRCELL-11:${SGNB_SA_DU_NGBR_DRB_REQ}=1
...    NRCELL-2:${SGNB_SA_DU_NGBR_DRB_REQ}=2
...    NRCELL-11:${SGNB_SA_DU_NGBR_DRB_SUCC}=1
...    NRCELL-2:${SGNB_SA_DU_NGBR_DRB_SUCC}=2
...    NRCELL-11:${SGNB_SA_DU_NGBR_DRB_REL}=1
...    NRCELL-2:${SGNB_SA_DU_NGBR_DRB_REL}=2
...    NRCELL-11:${SA_DU_GBR_DRB_REQ}=1
...    NRCELL-2:${SA_DU_GBR_DRB_REQ}=2
...    NRCELL-11:${SA_DU_GBR_DRB_SUCC}=1
...    NRCELL-2:${SA_DU_GBR_DRB_SUCC}=2
...    NRCELL-11:${REESTAB_ACC_VONR}=1
...    NRCELL-2:${REESTAB_ACC_VONR}=1
...    NRCELL-11:${RRC_REESTAB_ATT_VONR}=1
...    NRCELL-2:${RRC_REESTAB_ATT_VONR}=1
...    NRCELL-11:${NNGCC_LOC_REPORT_SENT}=2
...    NRCELL-2:${NNGCC_LOC_REPORT_SENT}=4

${RRC_REESTAB_OTHER_FAILURE_DU}    M55127C00503
${REESTAB_ACC_OTHER_FAIL_DU}    M55127C00512
${RRC_REESTAB_OTHER_FAILURE}    M55124C00505
${REESTAB_ACC_OTHER_FAIL}    M55124C00512
${REESTAB_RRCRECONFIG_SUCC}    M55124C00516
${SGNB_SA_DU_NGBR_DRB_REQ}    M55139C00003
${SGNB_SA_DU_NGBR_DRB_SUCC}    M55139C00004
${UE_PCELL_1_CONF_SCELL_DL_SA}    M55118C05507
${UE_SCELL_1_CONF_SCELL_DL_SA}    M55118C05508
${SAMPLES_UE_AMOUNTS}            M55118C01000
${SGNB_SA_DU_NGBR_DRB_REL}    M55139C00012
${SA_DU_GBR_DRB_REQ}    M55139C00501
${SA_DU_GBR_DRB_SUCC}    M55139C00502
${REESTAB_ACC_VONR}    M55124C00518
${RRC_REESTAB_ATT_VONR}    M55124C00520
${NNGCC_LOC_REPORT_SENT}    M55125C06502

&{CELLS_CARRIER_FREQ}
...     1=518910
...     2=633216
...     11=424090
...     12=126750
...     13=427970
...     14=126750

*** Test Cases ***
5GC000732-ET-F018_RRC_loop_reestablish_succ_with_784_to_new_Pcell_old_DRX_enabled_A2_configured_new_1390_meas_DRX_enabled_meas
    [Documentation]    This user scenario describes the behaviour, when a UE in RRC_CONNECTED re-establishes RRC Connection to the selected cell
    ...    (serving cell or the other cell) in serving gNB-DU with valid UE context interaction with emergency call
    ...    This case combines with F029_RRC_reestablish_succ_with_770_to_new_cell_area_of_interest_changed
    ...    preconditions:
    ...    1. configure F+T CA covBasedA1
    ...    2. config NRBTS.actLocationReportingSA as TRUE
    ...     Case steps:
    ...    1.EmergencyCall set up successfully
    ...    2.Trigger LOCATION REPORTING CONTROL to gNB
    ...    3.Change UE presence in the area of interest
    ...    4.Trgger RRC reestablish to new cell-11 successfully
    ...    5.Trgger RRC reestablish to cell-2 second time successfully
    ...    6.Cancel location reporting for the UE to gNB
    ...    7.check cause otherFailure in rrcReestablishmentRequest wiresahrk msg and DRB,SRB
    ...    8.check counter
    ...          M55127C00503: RRC_REESTAB_OTHER_FAILURE_DU:If reestablishmentCause IE is otherFailure
    ...          M55124C00505: RRC_REESTAB_OTHER_FAILURE:If reestablishmentCause IE is otherFailure
    ...          M55127C00512: REESTAB_ACC_OTHER_FAIL_DU:If reestablishmentCause IE is otherFailure
    ...          M55124C00512: REESTAB_ACC_OTHER_FAIL:If reestablishmentCause IE is otherFailure
    ...          M55124C00516: REESTAB_RRCRECONFIG_SUCC:Number of RRC reconfiguration successful in RRC reestablishment procedure
    ...          M55118C05507: Sum of CA UEs in the current cell configured as a PCell, which have 1 configured SCell in DL
    ...          M55118C05508: Sum of CA UEs in the current cell configured as a SCell, which have 1 configured SCell in DL
    ...          M55118C01000: When sample value is accumulated into "amount of UEs" counters
    ...          M55139C00003: The number of non-GBR DRB radio admission requests for SA user in DU
    ...          M55139C00004: The number of radio admitted non-GBR DRBs for SA user in DU
    ...          M55139C00012: The number of non-GBR DRB radio admission releases for SA user in DU
    ...          M55139C00501: The number of GBR DRB radio admission requests for SA user in DU.
    ...          M55139C00502: The number of GBR DRB successful radio admissions for SA user in DU.
    ...          M55124C00520: umber of RRC Re-establishment Request attempts for VONR for any cause RRC_REESTAB_ATT_VONR
    ...          M55124C00518: Number of accepted VONR RRC Re-establishment for all reestablishment causes
    ...          M55125C06502: The counter is updated when the NGAP: LOCATION REPORT message is sent to AMF
    [Tags]    F018    F029    QC_160339
    [Timeout]     60 min
    Before_ue_attach_F018
    UE Attach and L3 Emergency Call
    Verify SA DL and UL Traffic
    Change Ue Area Of Interest
    Reestablish from Cell_2 to Cell_11 and Check Traffic
    Reestablish from Cell_11 to Cell_2 and Check Traffic
    Cancel Location Reporting
    Release Ues    ue_type=all
    Check Wireshark Log    ${CURDIR}/a2a_F018/a2a.ini    wait_string=UEContextReleaseComplete::4
    Check Counters    ${PM_COUNTER_CHECK}

*** Keywords ***
Modify Cfg
    Update Cfg    set_qosflow id=1 5qi=6 default=off
    Update Cfg    set_qosflow id=2 5qi=5 default=on
    Update Cfg    set_qosflow id=3 5qi=1
    Update Cfg    set_qosflow id=4 5qi=2
    Update Cfg    set_qosrule id=1 proto=tcp qos_flow=2
    Update Cfg    set_qosrule id=2 proto=udp qos_flow=3
    Update Cfg    set_qosrule id=3 proto=udp qos_flow=4
    Update Cfg    set_nwslice id=1 snssai=0x01:0xD143A5 default=on ue=all amf=1 qos_flows=1,2,3,4 qos_rules=1,2,3

Before_ue_attach_F018
#    Delta Commission Parameters     ${Delta_Scf_F018}
    Execute Egate Command    ue_change_location id=81 enb=2 cell=2
    Clear Counter Files
    Start RRC Log    F018

UE Attach and L3 Emergency Call
    [Arguments]    ${ue_id}=81    ${pdu_gw_id}=1
    Execute Egate Command    qosflow_modify qos_flow=2 default=on
    Execute Egate Command    ue_register id=${ue_id}     pass_regexp=Received REGISTRATION COMPLETE
    Execute Egate Command    qosflow_modify qos_flow=2 priority=1
    Execute Egate Command    qosflow_modify qos_flow=3 priority=1
    Execute Egate Command    qosflow_modify qos_flow=2 default=on
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_gw_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup pdu=${pdu_gw_id} ue=${ue_id} nwslice=1 gw=${pdu_gw_id} request_type=initial-emergency-request
    ...                      pass_regexp=Initial Context Setup Successful
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu_gw_id} qosflows_to_add=3 by=amf
    ...                      pass_regexp=Added QosFlow with QFI:2 fiveQI:1
    Execute Egate Command    qosflow_disp
    Execute Egate Command    qosflow_modify qos_flow=2 priority=15
    Execute Egate Command    qosflow_modify qos_flow=3 priority=15
    Start Traffic    ${ue_id}    ${pdu_gw_id}

Change Ue Area Of Interest
    [Arguments]    ${ue_id}=81    ${area01}=16385    ${area02}=16395
    ${cmd01}    Catenate    ue_send_location_reporting_control ue=${ue_id} event_type=change-of-serving-cell
    ${cmd02}    Catenate    area_of_interest_configuration object_id=1 plmn_cellid=311:489 nrcellidentitylist=${area01}
    ${cmd03}    Catenate    area_of_interest_configuration object_id=2 plmn_cellid=311:489 nrcellidentitylist=${area02}
    ${cmd04}    Catenate    ue_send_location_reporting_control ue=${ue_id} event_type=ue-presence-in-area-of-interest
    ...    object_id=1 location_reporting_reference_id=1 object_id=2 location_reporting_reference_id=2
    Execute Egate Command    ${cmd01}    pass_regexp=Received Location Report
    Execute Egate Command    ${cmd02}    pass_regexp=EGATE>
    Execute Egate Command    ${cmd03}    pass_regexp=EGATE>
    Execute Egate Command    ${cmd04}    pass_regexp=Received Location Report

Cancel Location Reporting
    [Arguments]    ${ue_id}=81
    Execute Egate Command    ue_send_location_reporting_control ue=${ue_id} event_type=cancel-location-reporting-for-the-ue

Start Traffic
    [Arguments]    ${ue_id}=81    ${pdu_gw_id}=1
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_gw_id} qfi=1 dir=dl mbps=100 trf_id=2
    ...    pass_regexp=UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_gw_id} qfi=1 dir=dl mbps=100 trf_id=3
    ...    pass_regexp=UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_gw_id} qfi=1 dir=dl mbps=100 trf_id=4
    ...    pass_regexp=UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_gw_id} qfi=1 dir=ul mbps=10
    ...    pass_regexp=UE ${ue_id}: UDP UL

Verify Throuput on FT_CA
    [Arguments]    ${ue_id}=81    ${pdu_gw_id}=1
    Builtin.sleep    15s
    ${ret0}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-5 type=pdsch    pass_regexp=Average
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000 > 10
    ${scell1_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=1    type=pdsch    rate_type=ave
    Should Be True    ${scell1_tput}/1000 > 10
    Should Be True    ${scell0_tput}/1000+${scell1_tput}/1000 > 270
    Verify SA DL and UL Traffic    ${ue_id}    ${pdu_gw_id}

Verify SA DL and UL Traffic
    [Arguments]    ${ue_id}=81    ${pdu_gw_id}=1
    Builtin.sleep    15s
    ${ret0}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-5 type=pdsch    pass_regexp=Average
    ${ul_throuput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_gw_id}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${ul_throuput}/1000>9
    ${dl_throuput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_gw_id}    qfi=1    direction=dl    rate_type=ave
    Should Be True    ${dl_throuput}/1000>10

Trigger Scell Addition by A1 Event
    [Arguments]    ${pcell_id}    ${scell_physCellId}    ${ue_id}=81
    Start RRC Log    scell_addition
    ${pcell_carrier_freq}    Get From Dictionary    ${CELLS_CARRIER_FREQ}    ${pcell_id}
    ${meas_id}    Get Nr Meas Id For Specific Type And Frequency    ${ue_id}    ${pcell_carrier_freq}    A1
    Execute Egate Command
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=112 srsrq_nr=80
    ...    pass_regexp=SCellIndex 1 activated successfully
    Rrc Should Contain    sCellToAddModList    sCellIndex 1    physCellId ${scell_physCellId}
    Rrc Should Not Contain    sCellIndex 2

Trigger UE RRC Reestablish to Cell
    [Arguments]    ${tgt_cell_id}    ${ue_id}=81
    Execute Egate Command    ue_rrc_reestablish id=${ue_id} gnb=2 cell=${tgt_cell_id} cause=otherFailure
    ...    pass_regexp=UE81: NR RRC Reestablishment sucessfully completed
    Check Specific Ue State    ${ue_id}    ACTIVE
    ${enb_id}    ${cell_id}    Get UE Location    ${ue_id}
    Should Be Equal    ${enb_id}    2
    Should Be Equal    ${cell_id}    ${tgt_cell_id}

Reestablish from Cell_2 to Cell_11 and Check Traffic
    Trigger UE RRC Reestablish to Cell    tgt_cell_id=11
    Verify SA DL and UL Traffic
    Trigger Scell Addition by A1 Event    pcell_id=11    scell_physCellId=50
    Verify Throuput on FT_CA

Reestablish from Cell_11 to Cell_2 and Check Traffic
    Trigger UE RRC Reestablish to Cell    tgt_cell_id=2
    Verify SA DL and UL Traffic
