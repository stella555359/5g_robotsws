*** Settings ***
Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags      QCD_MN_RAN    QCP_RAN_ET    RAN_5G    RAN_5G_TDD    CRT    SBTS00
...    owner-liupei.fang    owner-shelly.song    team-SG2    release-SBTS22R2    5GC000732
...    CLOUD_5G_I_BLLL_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD
Resource    ../../../../../resources/DevHZ5_resource.robot


*** Variables ***
@{PARAMS_IN_SCF}
...    @{5GC000732_Base}
...    @{CELL_Base}

@{5GC000732_Base}
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRDU-1:actInterNumerologyCa=true
...    NRDU-1:carrierAggregationSupportList=ca_Fdd_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Sa,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Any_Sa,ca_Fdd_Fdd
...    NRPMRNL-1:miNrRelReportCu=15min

...    NRBTS:actInterRatHoSA=true
...    NRBTS:cipherPrefL:nea0=8
...    NRBTS:cipherPrefL:nea1_128=0
...    NRBTS:cipherPrefL:nea2_128=0
...    NRBTS:cipherPrefL:nea3_128=0
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
...    NRBTS-1:rrcReestabTypeSA=sameGNB
...    NRBTS-1:actInterRatHoSA=true
...    NRBTS-1:cipherPrefL:nea0=8
...    NRBTS-1:cipherPrefL:nea1_128=0
...    NRBTS-1:cipherPrefL:nea2_128=0
...    NRBTS-1:cipherPrefL:nea3_128=0
...    NRBTS-1:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS-1:actIntraFreqHoSA=false
...    NRBTS-1:actInterFreqHoSA=true
...    NRBTS-1:timerXnDataFwdGuard=250

...    NRBTS-1/NRHOIR-1:allowedMeasBandwidth=mbw100
...    NRBTS-1/NRHOIR-1:b2MeashoEnabled=none
...    NRBTS-1/NRHOIR-1:b2Threshold1hoRsrp=35
...    NRBTS-1/NRHOIR-1:b2Threshold1hoRsrpVoNr=35
...    NRBTS-1/NRHOIR-1:b2Threshold1hoRsrq=50
...    NRBTS-1/NRHOIR-1:b2Threshold1hoRsrqVoNr=50
...    NRBTS-1/NRHOIR-1:earfcnValue=1
...    NRBTS-1/NRHOIR-1:eutraFreqQOffsetRange=0dB
...    NRBTS-1/NRHOIR-1:presenceAntennaPort1=false
...    NRBTS-1/NRHOIR-1:reportAmount=r8
...    NRBTS-1/NRHOIR-1:reportInterval=ms240
...    NRBTS-1/NRHOIR-1:widebandRsrqMeas=false
...    NRBTS-1/NRHOIR-1:eutraB2MeashoRsrp:b2HysteresishoRsrp=0
...    NRBTS-1/NRHOIR-1:eutraB2MeashoRsrp:b2HysteresishoRsrpVoNr=0
...    NRBTS-1/NRHOIR-1:eutraB2MeashoRsrp:b2Threshold2hoRsrp=18
...    NRBTS-1/NRHOIR-1:eutraB2MeashoRsrp:b2Threshold2hoRsrpVoNr=18
...    NRBTS-1/NRHOIR-1:eutraB2MeashoRsrp:b2TimeToTriggerhoRsrp=ms480
...    NRBTS-1/NRHOIR-1:eutraB2MeashoRsrp:b2TimeToTriggerhoRsrpVoNr=ms480
...    NRBTS-1/NRHOIR-1:eutraB2MeashoRsrq:b2HysteresishoRsrq=0
...    NRBTS-1/NRHOIR-1:eutraB2MeashoRsrq:b2HysteresishoRsrqVoNr=0
...    NRBTS-1/NRHOIR-1:eutraB2MeashoRsrq:b2Threshold2hoRsrq=2
...    NRBTS-1/NRHOIR-1:eutraB2MeashoRsrq:b2Threshold2hoRsrqVoNr=2
...    NRBTS-1/NRHOIR-1:eutraB2MeashoRsrq:b2TimeToTriggerhoRsrq=ms480
...    NRBTS-1/NRHOIR-1:eutraB2MeashoRsrq:b2TimeToTriggerhoRsrqVoNr=ms480
...    NRBTS-1/NRADJECELL-1:eNodeBId=18
...    NRBTS-1/NRADJECELL-1:ePSTrackingAreaCode=0
...    NRBTS-1/NRADJECELL-1:earfcnValue=1
...    NRBTS-1/NRADJECELL-1:lcrId=1
...    NRBTS-1/NRADJECELL-1:physCellId=1
...    NRBTS-1/NRADJECELL-1:ecgiPlmn:mcc=311
...    NRBTS-1/NRADJECELL-1:ecgiPlmn:mnc=489
...    NRBTS-1/NRADJECELL-1:ecgiPlmn:mncLength=3
...    NRBTS-1/NRADJECELL-1:enbPlmn:mcc=311
...    NRBTS-1/NRADJECELL-1:enbPlmn:mnc=489
...    NRBTS-1/NRADJECELL-1:enbPlmn:mncLength=3
...    NRBTS-1/NRDRB_PDCP-2:pdcpBufDiscardEnabled=false
...    NRBTS-1/NRDRB_PDCP-2:maxCidAllowed=4
...    NRBTS:actInterFreqHoSA=true
...    NRBTS:timerXnDataFwdGuard=250
...    NRBTS:actIntraFreqHoSA=true
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS-1/NRDRB_PDCP:maxCidAllowed=4
...    NRDRB-10:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-4
...    NRDRB-10:resType=nonGBR
...    NRBTS-1/NRDRB_5QI-1:fiveqiValueList=5
...    NRBTS-1/NRDRB_5QI-7:fiveqiValueList=128
...    NRBTS-1/NRDRB_5QI-6:fiveqiValueList=1

@{CELL_Base}

...    NRCELL:absThreshSsbRsrqConsolidation=1
...    NRCELL:absThreshSsbRsrpConsolidation=1
...    NRCELL:sMeasConfigSsbRsrp=1
...    NRCELL-1:drxProfile1:drxInactivityTimer=10ms
...    NRCELL-1:drxProfile1:drxLongCycle=40ms
...    NRCELL-1:drxProfile1:drxOnDurationTimer=10ms
...    NRCELL-1:drxProfile1:drxRetransTimerDl=0slot
...    NRCELL-1:drxProfile1:drxRetransTimerUl=0slot
...    NRCELL-1:actVoNR=true
...    NRCELL-1:absThreshSsbRsrqConsolidation=1
...    NRCELL-1:absThreshSsbRsrpConsolidation=1
...    NRCELL-1:sMeasConfigSsbRsrp=1
...    NRCELL-1:actK1Opt=intra-gNB
...    NRCELL-1/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-10:gNbId=1
...    NRCELL-1/NRREL-10:gNbIdLength=22
...    NRCELL-1/NRREL-10:lcrId=12
...    NRCELL-1/NRREL-10:removeNotAllowed=false
...    NRCELL-1/NRREL-10:nrDcAllowed=false
...    NRCELL-1/NRREL-10:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-1/NRRELE-1:cellIndividualOffset=0dB
...    NRCELL-1/NRRELE-1:eNodeBId=18
...    NRCELL-1/NRRELE-1:eutranCellExcluded=false
...    NRCELL-1/NRRELE-1:lcrId=1
...    NRCELL-1/NRRELE-1:ecgiPlmn:mcc=311
...    NRCELL-1/NRRELE-1:ecgiPlmn:mnc=489
...    NRCELL-1/NRRELE-1:ecgiPlmn:mncLength=3
...    NRCELL-12/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-10:gNbId=1
...    NRCELL-12/NRREL-10:gNbIdLength=22
...    NRCELL-12/NRREL-10:lcrId=13
...    NRCELL-12/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-12:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=25
...    NRCELL-12:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0
...    NRCELL-12:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms0
...    NRCELL-12:a2MeashoEnabledSA=rsrp
...    NRCELL-12:actVoNR=true
...    NRCELL-12:absThreshSsbRsrqConsolidation=1
...    NRCELL-12:absThreshSsbRsrpConsolidation=1
...    NRCELL-12:sMeasConfigSsbRsrp=1
...    NRCELL-12:actK1Opt=intra-gNB
...    NRCELL-12/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-1:gNbId=1
...    NRCELL-12/NRREL-1:gNbIdLength=22
...    NRCELL-12/NRREL-1:lcrId=11
...    NRCELL-12/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-1:actCDrx=false
...    NRCELL-1:actCDrxVoNR=false
...    NRCELL-1:a1MeasSCellAddEnabled=rsrp
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=31
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=111
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=80ms
...    NRCELL-1:a1MeashoEnabledSA=rsrp
...    NRCELL-1:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRCELL-1:a1MeashoSsbRsrpSA:a1HysteresisHoSsbRsrpVoNr=0
...    NRCELL-1:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=60
...    NRCELL-1:a1MeashoSsbRsrpSA:a1ThresholdHoSsbRsrpVoNr=55
...    NRCELL-1:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL-1:a1MeashoSsbRsrpSA:a1TimeToTriggerHoSsbRsrpVoNr=ms40

...    NRCELL-1:a2MeasSCellRelEnabled=rsrp
...    NRCELL-1:a2MeashoEnabledSA=rsrp
...    NRCELL-1:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0
...    NRCELL-1:a2MeashoSsbRsrpSA:a2HysteresisHoSsbRsrpVoNr=0
...    NRCELL-1:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=34
...    NRCELL-1:a2MeashoSsbRsrpSA:a2ThresholdHoSsbRsrpVoNr=55
...    NRCELL-1:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL-1:a2MeashoSsbRsrpSA:a2TimeToTriggerHoSsbRsrpVoNr=ms40
...    NRCELL-1:a2MeasPCellSwitchEnabled=rsrp
...    NRCELL-1:a2MeasPCellSwitchSsbRsrp:a2HysteresisPCellSwitchSsbRsrp=0
...    NRCELL-1:a2MeasPCellSwitchSsbRsrp:a2ThresholdPCellSwitchSsbRsrp=45
...    NRCELL-1:a2MeasPCellSwitchSsbRsrp:a2TimeToTriggerPCellSwitchSsbRsrp=640ms
...    NRCELL-1:a2MeasPCellSwitchSsbRsrp:pCellSwitchOffsetSsbRsrp=0
...    NRCELL-1:a3MeasEnabled=rsrp
...    NRCELL-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRCELL-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL-1:actPrachMultiplexing=true
...    NRCELL-1/NRHOIF-1:a4MeasEnDcSteeringEnabled=none
...    NRCELL-1/NRHOIF-1:a4MeasNrDcEnabled=none
...    NRCELL-1/NRHOIF-1:a4MeasHigherPrioFreqEnabled=none
...    NRCELL-1/NRHOIF-1:a1BasedPCellSwitchEnabled=false
...    NRCELL-1/NRHOIF-1:a2BasedPCellSwitchEnabled=false
...    NRCELL-1/NRHOIF-1:thresholdPCellSwitchTargetRsrp=60
...    NRCELL-1/NRHOIF-1:thresholdPCellSwitchTargetRsrq=30
...    NRCELL-1/NRHOIF-1:a2BasedPCellSwitchPriority=1
...    NRCELL-1/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-1/NRHOIF-1:freqBandIndicatorNR=71
...    NRCELL-1/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf5
...    NRCELL-1/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-1/NRHOIF-1:scs=15 KHz
...    NRCELL-1/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-1:ssbFrequency=126750
...    NRCELL-1/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrpVoNr=2
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrpVoNr=10
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrpVoNr=ms0
...    NRCELL-1/NRHOIF-1:a5MeasEnabled=none
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5HysteresisSsbRsrp=20
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5Threshold1SsbRsrp=60
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5Threshold2SsbRsrp=110
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms5120
...    NRCELL-12/NRREL-10:removeNotAllowed=false
...    NRCELL-12/NRREL-10:nrDcAllowed=false
...    NRCELL-12/NRREL-10:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-1:removeNotAllowed=false
...    NRCELL-12/NRREL-1:nrDcAllowed=false
...    NRCELL-12/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-12:actCDrx=true
...    NRCELL-12:actCDrxVoNR=true
...    NRCELL-12:actEnhancedVoNR=true
...    NRCELL-12:a2MeasSCellRelEnabled=rsrp
...    NRCELL-12:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=2
...    NRCELL-12:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=34
...    NRCELL-12:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-12:a1MeasSCellAddEnabled=rsrp
...    NRCELL-12:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=1
...    NRCELL-12:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=75
...    NRCELL-12:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=100
...    NRCELL-12:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=480ms

...    NRCELL-12:actPrachMultiplexing=true
...    NRCELL-12:drxProfile1:drxInactivityTimer=40ms
...    NRCELL-12:drxProfile1:drxLongCycle=40ms
...    NRCELL-12:drxProfile1:drxOnDurationTimer=10ms
...    NRCELL-12:drxProfile1:drxRetransTimerDl=16slot
...    NRCELL-12:drxProfile1:drxRetransTimerUl=16slot
...    NRCELL-12:drxProfile2:drxInactivityTimer=4ms
...    NRCELL-12:drxProfile2:drxLongCycle=40ms
...    NRCELL-12:drxProfile2:drxOnDurationTimer=4ms
...    NRCELL-12:drxProfile2:drxRetransTimerDl=0slot
...    NRCELL-12:drxProfile2:drxRetransTimerUl=0slot
...    NRCELL-11:actVoNR=true
...    NRCELL-11:a2MeasSCellRelEnabled=rsrp
...    NRCELL-11:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=2
...    NRCELL-11:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=34
...    NRCELL-11:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-11:actPrachMultiplexing=true
...    NRCELL-13:actVoNR=true
...    NRCELL-13:a2MeasSCellRelEnabled=rsrp
...    NRCELL-13:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=2
...    NRCELL-13:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=34
...    NRCELL-13:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-13:actPrachMultiplexing=true
...    NRCELL:actPrachMultiplexing=true

@{PM_Counters_Check}
...    NRDU-1:${RRC_REESTAB_OTHER_FAILURE_DU}=2
...    NRCELL-12:${RRC_REESTAB_OTHER_FAILURE}=1
...    NRCELL-1:${RRC_REESTAB_OTHER_FAILURE}=1
...    NRDU-1:${RRC_REESTAB_ACC_OTHER_FAIL_DU}=2
...    NRCELL-12:${REESTAB_ACC_OTHER_FAIL}=1
...    NRCELL-1:${REESTAB_ACC_OTHER_FAIL}=1
...    NRCELL-12:${REESTAB_RRCRECONFIG_SUCC}=1
...    NRCELL-1:${REESTAB_RRCRECONFIG_SUCC}=1
...    NRCELL-12:${REESTAB_ADMISSION_CRTL}=1
...    NRCELL-1:${REESTAB_ADMISSION_CRTL}=1
...    NRCELL-12:${EPmCounterId_5G_F1_UE_CTXT_MOD_REQ_SENT}=23
...    NRCELL-1:${EPmCounterId_5G_F1_UE_CTXT_MOD_REQ_SENT}=6
...    NRCELL-12:${EPmCounterId_5G_F1_UE_CTXT_MOD_RESP_RECEIVED}=23
...    NRCELL-1:${EPmCounterId_5G_F1_UE_CTXT_MOD_RESP_RECEIVED}=6
...    NRCELL-1:${EPmCounterId_5G_NF1CC_DL_RRC_MSG_TRANSFER}=3
...    NRCELL-12:${EPmCounterId_5G_NF1CC_UL_RRC_MSG_TRANSFER}=20
...    NRCELL-1:${EPmCounterId_5G_NF1CC_UL_RRC_MSG_TRANSFER}=4
...    NRCELL-12:${EPmCounterId_5G_NRRCC_RRC_RECONF_SENT}=8
...    NRCELL-1:${EPmCounterId_5G_NRRCC_RRC_RECONF_SENT}=2
...    NRCELL-12:${EPmCounterId_5G_NRRCC_RRC_RECONF_CMP_RECD}=8
...    NRCELL-1:${EPmCounterId_5G_NRRCC_RRC_RECONF_CMP_RECD}=2
...    NRCELL-1:${UE_PCELL_1_CONF_SCELL_DL_SA}>0
...    NRCELL-12:${UE_SCELL_1_CONF_SCELL_DL_SA}>0
...    NRCELL-12:${UE_PCELL_2_CONF_SCELL_DL_SA}>0
...    NRCELL-11:${UE_SCELL_2_CONF_SCELL_DL_SA}>0
...    NRCELL-13:${UE_SCELL_2_CONF_SCELL_DL_SA}>0
...    NRCELL-12:${SAMPLES_UE_AMOUNTS}>0
...    NRBTS-1:${EPmCounterId_5G_NE1CS_CTXT_MOD_REQ_SENT}=9
...    NRBTS-1:${EPmCounterId_5G_NE1CS_CTXT_MOD_RSP_RECD}=9

${RRC_REESTAB_OTHER_FAILURE_DU}    M55127C00503    #Number of RRC Re-establishment Request caused by other failure
${RRC_REESTAB_ACC_OTHER_FAIL_DU}    M55127C00512    #Number of accepted RRC Re-establishment when reestablishment cause is other failure
${RRC_REESTAB_OTHER_FAILURE}       M55124C00505    #Number of RRC Re-establishment Request caused by HO failure
${REESTAB_RRCRECONFIG_SUCC}    M55124C00516    #Number of RRC reconfiguration successful in RRC reestablishment procedure
${REESTAB_ADMISSION_CRTL}    M55124C00519    #Number of admission control triggered in CU by RRC reestablishment procedure
${EPmCounterId_5G_F1_UE_CTXT_MOD_REQ_SENT}    M55113C00001    #Number of outgoing UE CONTEXT MODIFICATION REQUEST sent to gNB-DU
${EPmCounterId_5G_F1_UE_CTXT_MOD_RESP_RECEIVED}    M55113C00002    #Number of incoming UE CONTEXT MODIFICATION RESPONSE received from gNB-DU
${EPmCounterId_5G_NF1CC_DL_RRC_MSG_TRANSFER}    M55113C00501    #Number of DL RRC Message Transfer sent.
${EPmCounterId_5G_NF1CC_UL_RRC_MSG_TRANSFER}    M55113C00502    #Number of UL RRC Message Transfer received.
${EPmCounterId_5G_NRRCC_RRC_RECONF_SENT}    M55124C03001    #Number of RRC RECONFIGURATION sent
${EPmCounterId_5G_NRRCC_RRC_RECONF_CMP_RECD}    M55124C03002    #Number of RRC RECONFIGURATION COMPLETE received
${EPmCounterId_5G_NE1CS_CTXT_MOD_REQ_SENT}    M55135C00505    #Number of Bearer Context Modification Request sent by gNB-CU-CP
${EPmCounterId_5G_NE1CS_CTXT_MOD_RSP_RECD}    M55135C00506    #Number of Bearer Context Modification Response received at gNB-CU-CP
${UE_PCELL_1_CONF_SCELL_DL_SA}    M55118C05507
#Sum of CA UEs in the current cell configured as a SCell, which have 1 configured SCell in DL
${UE_SCELL_1_CONF_SCELL_DL_SA}    M55118C05508
#Current number of PCell UEs with 2 configured SCells in DL in SA mode is calculated when sample timer expires.
${UE_PCELL_2_CONF_SCELL_DL_SA}    M55118C07001
# Current number of SCell UEs with 2 configured SCells in DL in SA mode is calculated when sample timer expires.
${UE_SCELL_2_CONF_SCELL_DL_SA}    M55118C07002    # This counter indicates the number of samples taken to "user amount" counters
# The counter is updated when receiving the RRCReestablishmentComplete message when the reestablishmentCause is otherFailure
${REESTAB_ACC_OTHER_FAIL}    M55124C00512
# The counter can be used to calculate "average number of UEs"
${SAMPLES_UE_AMOUNTS}            M55118C01000

${ReconfigurationFailure}    otherFailure
${ue_id}    81
${gw_id}    2

*** Test Cases ***
5GC000732-ET-F005_RRC_loop_reestablish_succ_with_1167_meas_to_new_2329_meas_Pcell_old_DRX_enabled_no_meas_new_no_DRX_707
    [Documentation]    This case will test RRC reestablish to ori_cell due to otherFailure with valid UE context
    ...    combine with F005 and F010 RRCreestablish success with 1167 meas VONR to new 2329 meas Pcell with VoNR
    ...    old DRX enabled no meas new no DRX 707
    ...    preconditions:
    ...    1.configure FFF(cell 12+ cell 13+cell 11) with VoNR for 1167 coverbase for orig cell with DRX
    ...    2.configure T+F(cell 1+cell 12) with VoNR for 2329 coverbase for new cell with non-DRX, interRAT(707)
    ...    and config with meas A1,A2,a2MeasPCellSwitch,interratB2,intrafreq A3
    ...    Case steps:
    ...        1.Setup CA(FDD+FDD+FDD)(cell 12+ cell 13+cell 11) successfully
    ...        2.Trigger VoNR call with cell 12
    ...          result: Drx setup ,A1 MR reported to gNB, scell added to Pcell
    ...          A1 meas for scell addition been removed, A2 meas for scell release been added
    ...        3.Trgger RRC reestablish successful from cell 12 to cell 1
    ...          result: A1 MR reported to gNB, scell added to Pcell.
    ...          A2Measpcellswitch, interfreq A3 report, DRX release
    ...        4.Trgger RRC reestablish successful from cell 1 to cell 12
    ...          result: Drx setup, A1 report, A2,A3 remove
    ...        5. check counters:
    [Tags]    QC_142249    F005
    Clear Counter Files
    Ue Register And Pdu Session Setup At FDD Cell-12
    Trigger ScellAdd    carrierfreq=126750
    Start To Capture Wireshark Log    F00500
    Trigger RRC Reestablish with cause Then ScellAdd    1    ${ReconfigurationFailure}    518910
    Check Wireshark Log    ${CURDIR}${/}a2a_F005_00${/}a2a.ini    name=F00500    wait_string=UEContextModificationResponse::12
    Start To Capture Wireshark Log    F00501
    Trigger RRC Reestablish with cause Then ScellAdd    12    ${ReconfigurationFailure}    126750
    Verify Throughput And Check Counters    sleep_time=40s
    Check Wireshark Log    ${CURDIR}${/}a2a_F005_01${/}a2a.ini    name=F00501    wait_string=UEContextReleaseComplete::4
    [Teardown]    Common Test Teardown And Stop Capture Logs

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

Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/L1B/6cells_2T4F

Ue_Deregister
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE CONTEXT RELEASE COMPLETE


Trigger RRC Reestablish with cause Then ScellAdd
    [Arguments]    ${cell_id}    ${cause}    ${carrierfreq}
    ${ret1}=    Execute Egate Command    ue_rrc_reestablish id=${ue_id} gnb=2 cell=${cell_id} cause=${cause}
    ...    NR RRC Reestablishment sucessfully completed    timeout=20s
    sleep    42    reason=wait finished
    Trigger ScellAdd    carrierfreq=${carrierfreq}
    sleep    42    reason=wait finished

Ue Register And Pdu Session Setup At FDD Cell-12
    Execute Egate Command    qosflow_modify qos_flow=2 default=on
    Execute Egate Command    ue_location_change id=${ue_id} enb=2 cell=12
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=UE now in NG RM Registered
    Execute Egate Command    qosflow_modify qos_flow=2 default=on
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=${gw_id} nwslice=1    pass_regexp=QoS Routing Table
    sleep    42    reason=wait rrc finished
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=3 by=amf    pass_regexp=mapping fiveQi
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=5 trf_id=1    pass_regexp=Started Downlink
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=ul mbps=10 trf_id=1    pass_regexp=Started Uplink

Verify Throughput And Check Counters
    [Documentation]    verify Tput in scell is not 0
    [Arguments]    ${Tput_dl}=3    ${Tput_ul}=9    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pdsch    Throughput
    Should Not Match Regexp    ${scell_tput}    CellIndex-.*Mbps.*Mbps.*Mbps.* 0 Mbps
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}
    Ue_Deregister
    Check Counters    ${PM_Counters_Check}

Trigger ScellAdd
    [Arguments]    ${event_type}=A1    ${carrierfreq}=424090    ${srsrp_nr}=112    ${srsrq_nr}=80    ${ue_id}=81
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr    id=${ue_id}    meas_id=${meas_id}    event=${event_type}
    ...    srsrp_nr=${srsrp_nr}    srsrq_nr=${srsrq_nr}
    Execute Egate Command    ${cmd}    pass_regexp=rrcReconfigurationComplete
