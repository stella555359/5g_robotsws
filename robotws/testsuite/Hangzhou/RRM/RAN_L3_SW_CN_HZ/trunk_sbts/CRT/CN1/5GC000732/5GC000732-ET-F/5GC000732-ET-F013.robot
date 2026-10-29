*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags      QCD_MN_RAN    QCP_RAN_ET    RAN_5G    RAN_5G_TDD    CRT    SBTS00
...    owner-liupei.fang    owner-shelly.song    team-SG2    release-SBTS22R2    5GC000732
...    CLOUD_5G_I_BLLL_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD
Resource    ../../../../../resources/DevHZ5_resource.robot


*** Variables ***
${TL_TYPE_PATH}    fddtdd_sansa_cmwv/L1B/6cells_2T4F

@{PARAMS_IN_SCF}
...    @{Switch}
...    @{DRB}
...    @{CELL1}
...    @{CELL11}
...    @{CELL_NRREL}
...    @{CELL_NRHOIF}

@{Switch}
...    NRBTS-1:rrcReestabTypeSA=sameGNB
...    NRBTS-1:tWaitingRlRecover=10000ms

...    NRBTS-1:timerXnDataFwdGuard=250
...    NRBTS-1:actRedirect=true
...    NRBTS-1:actInterFreqHoSA=true
...    NRBTS-1:actIntraFreqHoSA=true
...    NRPMRNL-1:miNrRelReportCu=15min
...    NRBTS-1:actMeasBasedSCellAdditionSa=A1-based
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:actInterNumerologyCa=true
...    NRCELL-1:actK1Opt=intra-gNB
...    NRCELL-2:actK1Opt=intra-gNB
...    NRBTS-1:actRohc=true
...    NRCELL:actPrachMultiplexing=true

...    NRDU-1:carrierAggregationSupportList=ca_Fdd_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Sa


@{CELL1}
...    NRCELL-1:actVoNrMobilityThresholds=VoNrMobilityThresholds
...    NRCELL-1:actVoipPacketAggr=true
...    NRCELL-1:actGBRAdmissionControl=EnhancedVoNR

...    NRCELL-1:actVoNR=true
...    NRCELL-1:actCDrxVoNR=true
...    NRCELL-1:actEnhancedVoNR=true
...    NRCELL-1:n310VoNR=n10
...    NRCELL-1:t310VoNR=100ms
...    NRCELL-1:actCDrx=true
...    NRCELL-1:drxProfile1:drxInactivityTimer=40ms
...    NRCELL-1:drxProfile1:drxLongCycle=80ms
...    NRCELL-1:drxProfile1:drxOnDurationTimer=20ms
...    NRCELL-1:drxProfile1:drxRetransTimerDl=16slot
...    NRCELL-1:drxProfile1:drxRetransTimerUl=16slot
...    NRCELL-1:drxProfile2:drxInactivityTimer=20ms
...    NRCELL-1:drxProfile2:drxLongCycle=40ms
...    NRCELL-1:drxProfile2:drxOnDurationTimer=20ms
...    NRCELL-1:drxProfile2:drxRetransTimerDl=0slot
...    NRCELL-1:drxProfile2:drxRetransTimerUl=0slot
...    NRCELL-1:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0
...    NRCELL-1:a2MeashoSsbRsrpSA:a2HysteresisHoSsbRsrpVoNr=0
...    NRCELL-1:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=34
...    NRCELL-1:a2MeashoSsbRsrpSA:a2ThresholdHoSsbRsrpVoNr=75
...    NRCELL-1:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL-1:a2MeashoSsbRsrpSA:a2TimeToTriggerHoSsbRsrpVoNr=ms64
...    NRCELL-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRCELL-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL-1:a2MeashoEnabledSA=rsrp
...    NRCELL-1:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRCELL-1:a1MeashoSsbRsrpSA:a1HysteresisHoSsbRsrpVoNr=0
...    NRCELL-1:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=60
...    NRCELL-1:a1MeashoSsbRsrpSA:a1ThresholdHoSsbRsrpVoNr=65
...    NRCELL-1:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL-1:a1MeashoSsbRsrpSA:a1TimeToTriggerHoSsbRsrpVoNr=ms64
...    NRCELL-1:a1MeashoEnabledSA=rsrp
...    NRCELL-1:a3MeasEnabled=rsrp
...    NRCELL-1:actPrachMultiplexing=true
...    NRCELL-1:a2MeasSCellRelEnabled=rsrp
...    NRCELL-1:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=1
...    NRCELL-1:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=36
...    NRCELL-1:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=40ms
...    NRCELL-1:a1MeasPCellSwitchEnabled=rsrp
...    NRCELL-1:a1MeasPCellSwitchSsbRsrp:a1HysteresisPCellSwitchSsbRsrp=0
...    NRCELL-1:a1MeasPCellSwitchSsbRsrp:a1ThresholdPCellSwitchSsbRsrp=35
...    NRCELL-1:a1MeasPCellSwitchSsbRsrp:a1TimeToTriggerPCellSwitchSsbRsrp=0ms



@{CELL11}

...    NRCELL-11:actPrachMultiplexing=true
...    NRCELL-11:actVoNR=true
...    NRCELL-11:actCDrxVoNR=true
...    NRCELL-11:actEnhancedVoNR=true
...    NRCELL-11:n310VoNR=n10
...    NRCELL-11:t310VoNR=100ms
...    NRCELL-11:actVoNrMobilityThresholds=VoNrMobilityThresholds
...    NRCELL-11:actCDrx=true
...    NRCELL-11:actVoipPacketAggr=true
...    NRCELL-11:actGBRAdmissionControl=EnhancedVoNR
...    NRCELL-11:drxProfile1:drxInactivityTimer=40ms
...    NRCELL-11:drxProfile1:drxLongCycle=80ms
...    NRCELL-11:drxProfile1:drxOnDurationTimer=20ms
...    NRCELL-11:drxProfile1:drxRetransTimerDl=16slot
...    NRCELL-11:drxProfile1:drxRetransTimerUl=16slot
...    NRCELL-11:drxProfile2:drxInactivityTimer=40ms
...    NRCELL-11:drxProfile2:drxLongCycle=40ms
...    NRCELL-11:drxProfile2:drxOnDurationTimer=10ms
...    NRCELL-11:drxProfile2:drxRetransTimerDl=0slot
...    NRCELL-11:drxProfile2:drxRetransTimerUl=0slot
...    NRCELL-11:a1MeashoEnabledSA=rsrp
...    NRCELL-11:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=60
...    NRCELL-11:a1MeashoSsbRsrpSA:a1ThresholdHoSsbRsrpVoNr=55
...    NRCELL-11:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRCELL-11:a1MeashoSsbRsrpSA:a1HysteresisHoSsbRsrpVoNr=0
...    NRCELL-11:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL-11:a1MeashoSsbRsrpSA:a1TimeToTriggerHoSsbRsrpVoNr=ms40
...    NRCELL-11:a2MeashoEnabledSA=rsrp
...    NRCELL-11:a2MeasSCellRelEnabled=rsrp
...    NRCELL-11:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=2
...    NRCELL-11:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=34
...    NRCELL-11:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-11:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=34
...    NRCELL-11:a2MeashoSsbRsrpSA:a2ThresholdHoSsbRsrpVoNr=55
...    NRCELL-11:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0
...    NRCELL-11:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL-11:a2MeashoSsbRsrpSA:a2TimeToTriggerHoSsbRsrpVoNr=ms40
...    NRCELL-11:a2MeashoSsbRsrpSA:a2HysteresisHoSsbRsrpVoNr=0
...    NRCELL-11:a2MeasPCellSwitchEnabled=rsrp
...    NRCELL-11:a2MeasPCellSwitchSsbRsrp:a2HysteresisPCellSwitchSsbRsrp=0
...    NRCELL-11:a2MeasPCellSwitchSsbRsrp:a2ThresholdPCellSwitchSsbRsrp=45
...    NRCELL-11:a2MeasPCellSwitchSsbRsrp:a2TimeToTriggerPCellSwitchSsbRsrp=640ms
...    NRCELL-11:a2MeasPCellSwitchSsbRsrp:pCellSwitchOffsetSsbRsrp=0
...    NRCELL-11:a2MeasRedirectEnabled=none
...    NRCELL-11:a2MeasRedirectSsbRsrp:a2ThresholdRedirectSsbRsrp=34
...    NRCELL-11:a2MeasRedirectSsbRsrp:a2HysteresisRedirectSsbRsrp=0
...    NRCELL-11:a2MeasRedirectSsbRsrp:a2TimeToTriggerRedirectSsbRsrp=ms480
...    NRCELL-11:a1MeasSCellAddEnabled=rsrp
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=31
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=111
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=80ms
...    NRCELL-11:a3MeasEnabled=rsrp
...    NRCELL-11:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRCELL-11:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL-11:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL-11:a5MeasEnabled=none
...    NRCELL-11/NRREDRT-0:redirFreqNr=518910
...    NRCELL-11/NRREDRT-0:redirPrio=1
...    NRCELL-11/NRREDRT-0:redirRat=nr
...    NRCELL-11/NRREDRT-0:redirSsbScs=30 KHz

@{DRB}
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
...    NRBTS-1/NRDRB-15:maxTransferDelayGbr=20
...    NRBTS-1/NRDRB-15:discardTimer=100ms
...    NRBTS-1/NRDRB-15:maxDataRateGbrUl=1000
...    NRBTS-1/NRDRB-15:maxDataRateGbrDl=1000
...    NRBTS-1/NRDRB-16:dlFlowControlAlgo=none
...    NRBTS-1/NRDRB-16:dscp=46
...    NRBTS-1/NRDRB-16:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-2
...    NRBTS-1/NRDRB-16:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-3
...    NRBTS-1/NRDRB-16:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRBTS-1/NRDRB-16:numSduDiscard=1
...    NRBTS-1/NRDRB-16:queuingDelayDiscarding=Controlled Delay (CoDel)
...    NRBTS-1/NRDRB-16:queuingDelaySduDiscardThreshold=200
...    NRBTS-1/NRDRB-16:resType=nonGBR
...    NRBTS-1/NRDRB-16:rlcMode=RLC_UM
...    NRBTS-1/NRDRB-16:sduDiscardIntervalTmr=100
...    NRBTS-1/NRDRB-16:schedulWeight=24
...    NRBTS-1/NRDRB-16:discardTimer=150ms
...    NRBTS-1/NRDRB_PDCP-3:tReorderingDl=ms300
...    NRBTS-1/NRDRB_PDCP-3:tReorderingUl=ms300
...    NRBTS-1/NRDRB_PDCP-3:pdcpBufDiscardEnabled=false
...    NRBTS-1/NRDRB_PDCP-3:maxCidAllowed=4
...    NRBTS-1/NRDRB_RLC_UM-1:dlTReassemblyUm=ms40
...    NRBTS-1/NRDRB_RLC_UM-1:ulTReassemblyUm=ms40
...    NRBTS-1/NRDRB_RLC_UM-1:rlcUMDrbSNLength=rlcUm12bitSN
...    NRBTS-1/NRDRB_5QI-7:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-16
...    NRBTS-1/NRDRB_MAC-2:lcgid=2
...    NRBTS-1/NRDRB_MAC-2:schedulPrio=5
...    NRBTS-1/NRDRB_5QI-6:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-15
...    NRBTS-1/NRDRB_MAC-4:lcgid=2
...    NRBTS-1/NRDRB_MAC-4:schedulPrio=4
...    NRBTS-1/NRDRB_MAC-3:lcgid=4
...    NRBTS-1/NRDRB_MAC-3:schedulPrio=5
...    NRBTS-1/NRDRB_MAC-3:prioritisedBitRate=16kBps
...    NRBTS-1/NRDRB_PDCP-2:pdcpBufDiscardEnabled=false
...    NRBTS-1/NRDRB_PDCP-2:maxCidAllowed=4
...    NRBTS-1/NRDRB_PDCP-1:maxCidAllowed=4
...    NRBTS-1/NRDRB-10:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-4
...    NRBTS-1/NRDRB-10:resType=nonGBR
...    NRBTS-1/NRDRB_5QI-1:fiveqiValueList=5
...    NRBTS-1/NRDRB_5QI-7:fiveqiValueList=128
...    NRBTS-1/NRDRB_5QI-6:fiveqiValueList=1

@{CELL_NRREL}
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-1:gNbId=1
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-1:lcrId=11
...    NRCELL-1/NRREL-1:removeNotAllowed=false
...    NRCELL-1/NRREL-1:nrDcAllowed=false
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-1:gNbId=1
...    NRCELL-2/NRREL-1:gNbIdLength=22
...    NRCELL-2/NRREL-1:lcrId=1
...    NRCELL-2/NRREL-1:removeNotAllowed=false
...    NRCELL-2/NRREL-1:nrDcAllowed=false
...    NRCELL-2/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-2/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-1:gNbId=1
...    NRCELL-11/NRREL-1:gNbIdLength=22
...    NRCELL-11/NRREL-1:lcrId=1
...    NRCELL-11/NRREL-1:removeNotAllowed=false
...    NRCELL-11/NRREL-1:nrDcAllowed=false
...    NRCELL-11/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-2:gNbId=1
...    NRCELL-11/NRREL-2:gNbIdLength=22
...    NRCELL-11/NRREL-2:lcrId=12
...    NRCELL-11/NRREL-2:removeNotAllowed=false
...    NRCELL-11/NRREL-2:nrDcAllowed=false
...    NRCELL-11/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-2:gnbPlmn:mncLength=3

@{CELL_NRHOIF}
...    NRCELL-1/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-1/NRHOIF-1:freqBandIndicatorNR=66
...    NRCELL-1/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf2
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-1:ssbFrequency=424090
...    NRCELL-1/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=2
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrpVoNr=4
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=20
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrpVoNr=3
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms80
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrpVoNr=ms40
...    NRCELL-1/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-11/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-11/NRHOIF-1:freqBandIndicatorNR=71
...    NRCELL-11/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-11/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-11/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-11/NRHOIF-1:scs=15 KHz
...    NRCELL-11/NRHOIF-1:ssBurstSetPeriod=10
...    NRCELL-11/NRHOIF-1:ssbFrequency=126750
...    NRCELL-11/NRHOIF-1:a1BasedPCellSwitchEnabled=false
...    NRCELL-11/NRHOIF-1:a5MeasEnabled=none
...    NRCELL-11/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=2
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrpVoNr=6
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=20
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrpVoNr=5
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrpVoNr=ms0
...    NRCELL-11/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam

@{PM_COUNTER_CHECK}
...    NRCELL-11:${RRC_REESTAB_OTHER_FAILURE}=1
...    NRCELL-1:${RRC_REESTAB_OTHER_FAILURE}=1
...    NRCELL-11:${REESTAB_ACC_OTHER_FAIL}=1
...    NRCELL-1:${REESTAB_ACC_OTHER_FAIL}=1
...    NRCELL-11:${REESTAB_ADMISSION_CTRL}=1
...    NRCELL-1:${REESTAB_ADMISSION_CTRL}=1
...    NRCELL-11:${REESTAB_RRCRECONFIG_SUCC}=1
...    NRCELL-1:${REESTAB_RRCRECONFIG_SUCC}=1
...    NRCELL-11:${SGNB_SA_DU_ADMISSION_REQ}=2
...    NRCELL-1:${SGNB_SA_DU_ADMISSION_REQ}=1
...    NRCELL-11:${SGNB_SA_DU_ADMISSION_SUCC}=2
...    NRCELL-1:${SGNB_SA_DU_ADMISSION_SUCC}=1
...    NRCELL-11:${SGNB_SA_DU_NGBR_DRB_REQ}=2
...    NRCELL-1:${SGNB_SA_DU_NGBR_DRB_REQ}=1
...    NRCELL-11:${SGNB_SA_DU_NGBR_DRB_SUCC}=2
...    NRCELL-1:${SGNB_SA_DU_NGBR_DRB_SUCC}=1
...    ${RRC_REESTAB_OTHER_FAILURE_DU}=2
...    ${REESTAB_ACC_OTHER_FAIL_DU}=2
...    NRCELL-11:${REESTAB_ACC_VONR}=1
...    NRCELL-1:${REESTAB_ACC_VONR}=1
...    NRCELL-11:${RRC_REESTAB_ATT_VONR}=1
...    NRCELL-1:${RRC_REESTAB_ATT_VONR}=1
...    NRCELL-11:${SA_DU_GBR_DRB_REQ}=2
...    NRCELL-1:${SA_DU_GBR_DRB_REQ}=1
...    NRCELL-11:${SA_DU_GBR_DRB_SUCC}=2
...    NRCELL-1:${SA_DU_GBR_DRB_SUCC}=1
...    NRCELL-11:${SA_DU_GBR_DRB_REL}=2
...    NRCELL-1:${SA_DU_GBR_DRB_REL}=1
...    NRCELL-11:${AVE_AVAIL_SA_5QI1_GBR_RES}>0
...    NRCELL-1:${AVE_AVAIL_SA_5QI1_GBR_RES}>0
...    NRCELL-11:${AVE_AVAIL_SA_5QI1_GBR_RES_DEN}>0
...    NRCELL-1:${AVE_AVAIL_SA_5QI1_GBR_RES_DEN}>0
...    NRCELL-11:${LOW_PEAK_SA_5QI1_GBR_RES}>0
...    NRCELL-1:${LOW_PEAK_SA_5QI1_GBR_RES}>0
...    ${NE1CS_ROHC_DRB_CTX_REQ_SENT}=15
...    ${NE1CS_ROHC_DRB_CTX_RESP_RECD}=15


# The number of the RRCReestablishmentRequest with the reestablishmentCause of otherFailure
${RRC_REESTAB_OTHER_FAILURE_DU}    M55127C00503
# The number of successful RRC Reestablishment procedures when the reestablishmentCause is otherFailure
${REESTAB_ACC_OTHER_FAIL_DU}    M55127C00512
# The number of the RRCReestablishmentRequest with the reestablishmentCause of otherFailure
${RRC_REESTAB_OTHER_FAILURE}    M55124C00505
# The counter is updated when receiving the RRCReestablishmentComplete message when the reestablishmentCause is otherFailure
${REESTAB_ACC_OTHER_FAIL}    M55124C00512
# The number of admission controls triggered in CU by RRC reestablishment procedure
${REESTAB_ADMISSION_CTRL}    M55124C00519
# The number of RRC reconfiguration succeeded in RRC reestablishment procedure
${REESTAB_RRCRECONFIG_SUCC}    M55124C00516
# The number of radio admission requests for SA user. Updated in the DU when RRC resources are requested
${SGNB_SA_DU_ADMISSION_REQ}    M55139C00001
# The number of admitted radio admission requests for SA user. Updated in the DU when RRC resources are admitted
${SGNB_SA_DU_ADMISSION_SUCC}    M55139C00002
# The number of non-GBR DRB radio admission requests for SA user in DU.
# Updated in DU whenever an admission is requested for a non-GBR DRB due to Initial Context Setup
# or PDU session addition or due to PDU session modification.
${SGNB_SA_DU_NGBR_DRB_REQ}    M55139C00003
# The number of non-GBR DRB successful radio admissions for SA user. Updated in DU whenever a request for a non-GBR DRB
# is successfully admitted in Initial Context Setup or PDU session addition or due to PDU session modification.
${SGNB_SA_DU_NGBR_DRB_SUCC}    M55139C00004
#The number of successful RRC Reestablishment procedures for VONR for all reestablishment causes
${REESTAB_ACC_VONR}    M55124C00518
#The number of RRC Re-establishment Request attempts for VONR for any cause RRC_REESTAB_ATT_VONR
${RRC_REESTAB_ATT_VONR}    M55124C00520
#The number of GBR DRB radio admission requests in DU for SA user.
${SA_DU_GBR_DRB_REQ}    M55139C00501
#The number of GBR DRB successful radio admissions for SA user.
${SA_DU_GBR_DRB_SUCC}    M55139C00502
#The number of GBR DRB radio admission releases for SA user in DU.
${SA_DU_GBR_DRB_REL}    M55139C00509
#Number of RoHC contexts configured for the DRBs for which RoHC compression is requested by gNB-CU-CP from gNB-CU-UP.
${NE1CS_ROHC_DRB_CTX_REQ_SENT}    M55135C01001
#Number of RoHC contexts configured for the DRBs for which RoHC compression is requested by gNB-CU-CP from gNB-CU-UP.
${NE1CS_ROHC_DRB_CTX_RESP_RECD}    M55135C01002
#The average number of estimated available radio resources for 5QI-1 users. The counter counts resources per UE
#and is based defined cell level maximum GBR capacity and used capacity per UE
${AVE_AVAIL_SA_5QI1_GBR_RES}    M55139C00510
#Denominator for AVE_AVAIL_SA_5QI1_GBR_RES
${AVE_AVAIL_SA_5QI1_GBR_RES_DEN}    M55139C00511
#Lowest peak number of radio resources available for 5QI-1 GBR users.
${LOW_PEAK_SA_5QI1_GBR_RES}    M55139C00512

&{CELLS_CARRIER_FREQ}
...     1=518910
...     11=424090

${ue_id_82}    82

*** Test Cases ***
5GC000732-ET-F013_RRC_loop_reestablish_succ_with_6112_1390_meas_with_ROHC_to_scell_old_DRX_enabled_A1_configured_new_DRX_enabled_with_meas
    [Documentation]    This case will test RRC reestablish to new cell due to configureationFailure with ROHC
    ...    Reestablish from VoNR, meas, DRX, CA(T+T) to new cell(scell) with DRX and no meas with VoNR
    ...    preconditions:
    ...        1. ROHC(774) is opened and VoNR(6112)
    ...        2. configure CA F+T(cell 11+cell 1) for 1390 covBasedA1 with DRX,measconfig(A1, A2,A2pcellswitch, A3),VoNR
    ...        3. configure cell 1 for new cell with new DRX,measconfig(A1, A2,A3)
    ...    Case steps:
    ...        1.Setup CA(FDD+TDD)(cell 11+ cell 1) successfully
    ...        2.Trigger VoNR call with cell 11, scell 1 added
    ...        3.Trgger RRC reestablish from cell 11 to cell 1, RRC reestablish successfully
    ...        4.Trigger RRC reestablish from cell 1 to cell 11,RRC reestablish successfully
    ...        5.check VoNR successfully , drx setup successfully and meas config not missing in RRCReestablish procedure
    ...        6.Check counters:
    ...          RRC_REESTAB_OTHER_FAILURE_DU: If reestablishmentCause IE is otherFailure (Counter ID: M55127C00503)
    ...          RRC_REESTAB_OTHER_FAILURE: If reestablishmentCause IE is otherFailure (Counter ID: M55124C00505)
    ...          REESTAB_ACC_OTHER_FAIL_DU: If reestablishmentCause IE is otherFailure (Counter ID: M55127C00512)
    ...          REESTAB_RRCRECONFIG_SUCC: Number of RRC reconfiguration successful in RRC reestablishment procedure
    ...          (Counter ID: M55124C00516)
    ...          REESTAB_ACC_VONR: (Counter ID: M55124C00518)
    ...          RRC_REESTAB_ATT_VONR: (Counter ID: M55124C00520)
    ...          REESTAB_ADMISSION_CRTL: (Counter ID: M55124C00519)
    ...          NE1CS_ROHC_DRB_CTX_REQ_SENT:M55135C01001
    ...          NE1CS_ROHC_DRB_CTX_RESP_RECD:M55135C01002
    ...          EPmCounterId_5G_SGNB_SA_DU_ADMISSION_REQ: M55139C00001
    ...          EPmCounterId_5G_SGNB_SA_DU_ADMISSION_SUCC:M55139C00002
    ...          EPmCounterId_5G_SGNB_SA_DU_NGBR_DRB_REQ:M55139C00003
    ...          EPmCounterId_5G_SGNB_SA_DU_NGBR_DRB_SUCC:M55139C00004
    ...          EPmCounterId_5G_SGNB_SA_DU_NGBR_DRB_REL:M55139C00012
    ...          EPmCounterId_5G_SA_DU_GBR_DRB_REQ:M55139C00501
    ...          EPmCounterId_5G_SA_DU_GBR_DRB_SUCC:M55139C00502
    [Tags]    QC_157334
    Clear Counter Files    wait=${False}
    Start VoNR Call To Cell11 and Start Traffic
    Add Scell_1 and Check Traffic
    Reestablish from Cell_11 to Cell_1 and Check Traffic
    Reestablish from Cell_1 to Cell_11 and Check Traffic
    Stop Traffic and UE Detach
    Check Counters    ${PM_COUNTER_CHECK}
    Check Wireshark Log    ${CURDIR}/a2a_F013/a2a.ini    wait_string=UEContextReleaseComplete::4


*** Keywords ***
Modify Cfg
    Update Cfg    set_qosflow id=2 5qi=5
    Update Cfg    set_qosflow id=3 5qi=1
    Update Cfg    set_qosflow id=4 5qi=2
    Update Cfg    set_qosrule id=1 proto=tcp qos_flow=2
    Update Cfg    set_qosrule id=2 proto=udp qos_flow=3
    Update Cfg    set_qosrule id=3 proto=udp qos_flow=4
    Update Cfg    ue_param id=${ue_id_82} ue_nr_capabilities=${SA_Capa_perUE_Full_enable_ROHC_powersaving}

Start VoNR Call To Cell11 and Start Traffic
    [Arguments]    ${ue_id}=${ue_id_82}    ${pdu_id}=1
    Execute Egate Command    qosflow_modify qos_flow=2 default=on
    ${ret}    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=11    pass_regexp=location
    Should Contain Any    ${ret}    location updated    already there
    Execute Egate Command    qosflow_modify qos_flow=2 default=on
    Execute Egate Command    ue_register id=${ue_id}     pass_regexp=Received REGISTRATION COMPLETE
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup pdu=${pdu_id} ue=${ue_id} nwslice=1 gw=${pdu_id}
    ...                      pass_regexp=QoS Routing Table
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_add=3 by=amf
    ...                      pass_regexp=QoS Routing Table
    Send Traffic    ${ue_id}    ${pdu_id}

Send Traffic
    [Arguments]    ${ue_id}=${ue_id_82}    ${pdu_id}=1
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=${pdu_id} dir=dl mbps=70 trf_id=1
    ...                      pass_regexp=UE${ue_id}: Started Downlink Internal traffic
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=${pdu_id} dir=ul mbps=10 trf_id=1
    ...                      pass_regexp=UE${ue_id}: Started Uplink Internal traffic

Stop Traffic and UE Detach
    [Arguments]    ${ue_id}=${ue_id_82}
    Execute Egate Command    trf_data_stop ue=${ue_id}    pass_regexp=Traffic was stopped
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    pass_regexp=UE${ue_id}: detached

Check Traffic
    [Arguments]    ${ue_id}     ${cell_num}    ${min_dl_tput}    ${min_ul_tput}
    Sleep    10s    sleep for Tput stable
    ${dl_throuput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=ave
    ${ul_throuput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    FOR    ${index}    IN RANGE    0    ${cell_num}
         ${str_index}    Convert To String    ${index}
         ${scell_tput}    Ap Get Throuput On Specific Scell    ${ue_id}    ${str_index}    pdsch
         Should Be True    ${scell_tput}/1000 > 0
    END
    Should Be True    ${dl_throuput}/1000 > ${min_dl_tput}
    Should Be True    ${ul_throuput}/1000 > ${min_ul_tput}

Add Scell_1 and Check Traffic
    [Arguments]    ${ue_id}=${ue_id_82}    ${pcell_id}=11
    Trigger Scell Addition by A1 Event    ue_id=${ue_id}    pcell_id=${pcell_id}    scell_physCellId=50
    Check Traffic    ue_id=${ue_id}    cell_num=2    min_dl_tput=63    min_ul_tput=9

Trigger Scell Addition by A1 Event
    [Arguments]    ${ue_id}    ${pcell_id}    ${scell_physCellId}
    Start RRC Log    scell_addition
    ${pcell_carrier_freq}    Get From Dictionary    ${CELLS_CARRIER_FREQ}    ${pcell_id}
    ${meas_id}    Get Nr Meas Id For Specific Type And Frequency    ${ue_id}    ${pcell_carrier_freq}    A1
    Execute Egate Command
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=112 srsrq_nr=80
    ...    pass_regexp=SCellIndex 1 activated successfully
    Rrc Should Contain    sCellToAddModList    sCellIndex 1    physCellId ${scell_physCellId}
    Rrc Should Not Contain    sCellIndex 2

Trigger UE RRC Reestablish to Cell
    [Arguments]    ${ue_id}    ${tgt_cell_id}
    Execute Egate Command    ue_rrc_reestablish id=${ue_id} gnb=2 cell=${tgt_cell_id} cause=otherFailure
    ...    pass_regexp=UE${ue_id}: NR RRC Reestablishment sucessfully completed
    Check Specific Ue State    ${ue_id}    ACTIVE
    ${enb_id}    ${cell_id}    Get UE Location    ${ue_id}
    Should Be Equal    ${enb_id}    2
    Should Be Equal    ${cell_id}    ${tgt_cell_id}

Reestablish from Cell_1 to Cell_11 and Check Traffic
    [Arguments]    ${ue_id}=${ue_id_82}
    Trigger UE RRC Reestablish to Cell    ${ue_id}    tgt_cell_id=11
    Check Traffic    ${ue_id}    cell_num=1    min_dl_tput=63    min_ul_tput=9

Reestablish from Cell_11 to Cell_1 and Check Traffic
    [Arguments]    ${ue_id}=${ue_id_82}
    Trigger UE RRC Reestablish to Cell    ${ue_id}    tgt_cell_id=1
    Check Traffic    ${ue_id}    cell_num=1    min_dl_tput=63    min_ul_tput=9

