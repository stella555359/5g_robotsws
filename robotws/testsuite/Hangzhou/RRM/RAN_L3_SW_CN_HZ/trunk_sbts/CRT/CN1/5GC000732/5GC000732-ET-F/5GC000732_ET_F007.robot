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
${DEBUG_LOG_LEVEL}    4
@{PARAMS_IN_SCF}    
...    @{5GC000732_Base}
...    @{CELL_Base}

@{5GC000732_Base}
...    NRPMRNL-1:miNrRelReportCu=15min

...    NRBTS-1:tWaitingRlRecover=4000ms
...    NRBTS:actIntraFreqHoSA=true
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS:actInterFreqHoSA=true
...    NRBTS:timerXnDataFwdGuard=250
...    NRBTS:cipherPrefL:nea0=8
...    NRBTS:cipherPrefL:nea1_128=0
...    NRBTS:cipherPrefL:nea2_128=0
...    NRBTS:cipherPrefL:nea3_128=0
...    NRBTS:actInterRatHoSA=true
...    NRBTS-1/NRDRB-15:dlFlowControlAlgo=none
...    NRBTS-1/NRDRB-15:dscp=46
...    NRBTS-1/NRDRB-15:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-3
...    NRBTS-1/NRDRB-15:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-2
...    NRBTS-1/NRDRB-15:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRBTS-1/NRDRB-15:numSduDiscard=1
...    NRBTS-1/NRDRB-15:discardTimer=100ms
...    NRBTS-1/NRDRB-15:queuingDelayDiscarding=Disabled
...    NRBTS-1/NRDRB-15:queuingDelaySduDiscardThreshold=750
...    NRBTS-1/NRDRB-15:resType=GBR
...    NRBTS-1/NRDRB-15:rlcMode=RLC_UM
...    NRBTS-1/NRDRB-15:sduDiscardIntervalTmr=500
...    NRBTS-1/NRDRB-15:schedulWeight=1
...    NRBTS-1/NRDRB-15:maxDddsPeriodCpuOvld=40
...    NRBTS-1/NRDRB-15:maxTransferDelayGbr=20
...    NRBTS-1/NRDRB-15:maxDataRateGbrUl=1000
...    NRBTS-1/NRDRB-15:maxDataRateGbrDl=1000
...    NRBTS-1/NRDRB-15:actLostPduFastRetx=false
...    NRBTS-1/NRDRB-15:actDddsReduction=false
...    NRBTS-1/NRDRB-15:maxRlcQueueingDelayGbr=20
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
...    NRBTS-1/NRDRB_PDCP-1:maxCidAllowed=4
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
...    NRDRB-10:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-4
...    NRBTS-1/NRDRB_MAC-4:lcgid=2
...    NRBTS-1/NRDRB_MAC-4:schedulPrio=4
...    NRBTS-1/NRDRB_MAC-3:lcgid=4
...    NRBTS-1/NRDRB_MAC-3:schedulPrio=5
...    NRBTS-1/NRDRB_MAC-3:prioritisedBitRate=16kBps
...    NRBTS-1:rrcReestabTypeSA=sameGNB
...    NRBTS-1:actInterRatHoSA=true

...    NRBTS-1:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS-1:actInterFreqHoSA=true
...    NRBTS-1:cipherPrefL:nea0=8
...    NRBTS-1:cipherPrefL:nea1_128=0
...    NRBTS-1:cipherPrefL:nea2_128=0
...    NRBTS-1:cipherPrefL:nea3_128=0
...    NRBTS-1:actIntraFreqHoSA=true
...    NRBTS-1:timerXnDataFwdGuard=250
...    NRBTS-1/NRDRB_PDCP:maxCidAllowed=4
...    MRBTS-1/NRBTS-1:actNormVCFallback=false
...    MRBTS-1/NRBTS-1:actRohc=true
...    MRBTS-1/NRBTS-1:rrcReestabTypeSA=sameGNB
...    MRBTS-1/NRBTS-1:actInterRatHoSA=true

...    MRBTS-1/NRBTS-1:actMeasBasedSCellAdditionSa=A1-based
...    MRBTS-1/NRBTS-1:actInterFreqHoSA=true
...    MRBTS-1/NRBTS-1:cipherPrefL:nea0=8
...    MRBTS-1/NRBTS-1:cipherPrefL:nea1_128=0
...    MRBTS-1/NRBTS-1:cipherPrefL:nea2_128=0
...    MRBTS-1/NRBTS-1:cipherPrefL:nea3_128=0
...    MRBTS-1/NRBTS-1:actIntraFreqHoSA=true
...    MRBTS-1/NRBTS-1:timerXnDataFwdGuard=250
...    NRPMRNL:miNrRelReportCu=15min
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:actInterNumerologyCa=true
...    NRDU-1:carrierAggregationSupportList=ca_Fdd_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa
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
...    NRBTS-1/NRDRB_PDCP-2:pdcpBufDiscardEnabled=false
...    NRBTS-1/NRDRB_PDCP-2:maxCidAllowed=4
...    NRBTS-1/NRDRB_5QI-1:fiveqiValueList=5
...    NRBTS-1/NRDRB_5QI-7:fiveqiValueList=128
...    NRBTS-1/NRDRB_5QI-6:fiveqiValueList=1


@{CELL_Base}
...    NRCELL-1:actK1Opt=intra-gNB
...    NRCELL-2:actK1Opt=intra-gNB
...    NRCELL-11:actK1Opt=intra-gNB
...    NRCELL-12:actK1Opt=intra-gNB
...    NRCELL-13:actK1Opt=intra-gNB
...    NRCELL-14:actK1Opt=intra-gNB
...    NRCELL-2:actCDrxVoNR=true
...    NRCELL-2:a1MeasSCellAddEnabled=rsrp
...    NRCELL-2:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=1
...    NRCELL-2:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=75
...    NRCELL-2:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=100
...    NRCELL-2:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=480ms
...    NRCELL-2:a1MeashoEnabledSA=rsrp
...    NRCELL-2:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRCELL-2:a1MeashoSsbRsrpSA:a1HysteresisHoSsbRsrpVoNr=0
...    NRCELL-2:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=70
...    NRCELL-2:a1MeashoSsbRsrpSA:a1ThresholdHoSsbRsrpVoNr=60
...    NRCELL-2:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms320
...    NRCELL-2:a1MeashoSsbRsrpSA:a1TimeToTriggerHoSsbRsrpVoNr=ms64
...    NRCELL-2:a2MeashoEnabledSA=rsrp
...    NRCELL-2:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0
...    NRCELL-2:a2MeashoSsbRsrpSA:a2HysteresisHoSsbRsrpVoNr=0
...    NRCELL-2:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=45
...    NRCELL-2:a2MeashoSsbRsrpSA:a2ThresholdHoSsbRsrpVoNr=60
...    NRCELL-2:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms320
...    NRCELL-2:a2MeashoSsbRsrpSA:a2TimeToTriggerHoSsbRsrpVoNr=ms64
...    NRCELL-2:a3MeasEnabled=rsrp
...    NRCELL-2:a3MeasSsbRsrp:a3HysteresisSsbRsrp=2
...    NRCELL-2:a3MeasSsbRsrp:a3OffsetSsbRsrp=25
...    NRCELL-2:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL-2:actPrachMultiplexing=true
...    NRCELL-2:absThreshSsbRsrqConsolidation=1
...    NRCELL-2:absThreshSsbRsrpConsolidation=1
...    NRCELL-2:sMeasConfigSsbRsrp=1
...    NRCELL-2:actVoNR=true
...    NRCELL-2/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-10:gNbId=1
...    NRCELL-2/NRREL-10:gNbIdLength=22
...    NRCELL-2/NRREL-10:lcrId=11
...    NRCELL-2/NRREL-10:removeNotAllowed=false
...    NRCELL-2/NRREL-10:nrDcAllowed=false
...    NRCELL-2/NRREL-10:sCellAdditionMethod=blind
...    NRCELL-2/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-10:gnbPlmn:mncLength=3
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
...    NRCELL-1/NRRELE-1:cellIndividualOffset=0dB
...    NRCELL-1/NRRELE-1:eNodeBId=18
...    NRCELL-1/NRRELE-1:eutranCellExcluded=false
...    NRCELL-1/NRRELE-1:lcrId=1
...    NRCELL-1/NRRELE-1:ecgiPlmn:mcc=311
...    NRCELL-1/NRRELE-1:ecgiPlmn:mnc=489
...    NRCELL-1/NRRELE-1:ecgiPlmn:mncLength=3
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
...    NRCELL-1:drxProfile1:drxInactivityTimer=10ms
...    NRCELL-1:drxProfile1:drxLongCycle=40ms
...    NRCELL-1:drxProfile1:drxOnDurationTimer=10ms
...    NRCELL-1:drxProfile1:drxRetransTimerDl=0slot
...    NRCELL-1:drxProfile1:drxRetransTimerUl=0slot
...    NRCELL-1:a1MeasSCellAddEnabled=rsrp
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=31
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=111
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms

...    NRCELL-1:a2MeasSCellRelEnabled=rsrp
...    NRCELL-1:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRCELL-1:a1MeashoSsbRsrpSA:a1HysteresisHoSsbRsrpVoNr=0
...    NRCELL-1:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=60
...    NRCELL-1:a1MeashoSsbRsrpSA:a1ThresholdHoSsbRsrpVoNr=55
...    NRCELL-1:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL-1:a1MeashoSsbRsrpSA:a1TimeToTriggerHoSsbRsrpVoNr=ms40
...    NRCELL-1:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=2
...    NRCELL-1:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=34
...    NRCELL-1:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-1:actCDrxVoNR=false
...    NRCELL-1:a3MeasEnabled=rsrp
...    NRCELL-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=10
...    NRCELL-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=30
...    NRCELL-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms40
...    NRCELL-1:a1MeashoEnabledSA=rsrp
...    NRCELL-1:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0
...    NRCELL-1:a2MeashoSsbRsrpSA:a2HysteresisHoSsbRsrpVoNr=0
...    NRCELL-1:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=34
...    NRCELL-1:a2MeashoSsbRsrpSA:a2ThresholdHoSsbRsrpVoNr=55
...    NRCELL-1:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL-1:a2MeashoSsbRsrpSA:a2TimeToTriggerHoSsbRsrpVoNr=ms40
...    NRCELL-1:a2MeashoEnabledSA=rsrp
...    NRCELL-1:actPrachMultiplexing=true
...    NRCELL-1:absThreshSsbRsrqConsolidation=1
...    NRCELL-1:absThreshSsbRsrpConsolidation=1
...    NRCELL-1:sMeasConfigSsbRsrp=1

...    NRCELL-12:a2MeasSCellRelEnabled=rsrp
...    NRCELL-12:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=2
...    NRCELL-12:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=34
...    NRCELL-12:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-12:actPrachMultiplexing=true
...    NRCELL-12:absThreshSsbRsrqConsolidation=1
...    NRCELL-12:absThreshSsbRsrpConsolidation=1
...    NRCELL-12:sMeasConfigSsbRsrp=1
...    NRCELL-12:actVoNR=true
...    NRCELL:actVoNR=true
...    NRCELL:actPrachMultiplexing=true
...    NRCELL:absThreshSsbRsrqConsolidation=1
...    NRCELL:sMeasConfigSsbRsrp=1

...    NRCELL:absThreshSsbRsrpConsolidation=1
...    NRCELL-1:actCDrx=false
...    NRCELL-1:actVoNR=true
...    NRCELL-2:actCDrx=true
...    NRCELL-2:actEnhancedVoNR=true
...    NRCELL-2:actVoipPacketAggr=true
...    NRCELL-2:actGBRAdmissionControl=EnhancedVoNR
...    NRCELL-2:actVoNrMobilityThresholds=VoNrMobilityThresholds
...    NRCELL-2:n310VoNR=n10
...    NRCELL-2:t310VoNR=100ms

...    NRCELL-2:drxProfile1:drxInactivityTimer=40ms
...    NRCELL-2:drxProfile1:drxLongCycle=80ms
...    NRCELL-2:drxProfile1:drxOnDurationTimer=20ms
...    NRCELL-2:drxProfile1:drxRetransTimerDl=16slot
...    NRCELL-2:drxProfile1:drxRetransTimerUl=16slot
...    NRCELL-2:drxProfile2:drxInactivityTimer=20ms
...    NRCELL-2:drxProfile2:drxLongCycle=40ms
...    NRCELL-2:drxProfile2:drxOnDurationTimer=20ms
...    NRCELL-2:drxProfile2:drxRetransTimerDl=0slot
...    NRCELL-2:drxProfile2:drxRetransTimerUl=0slot

@{PM_Counters_Check}
...    NRCELL-1:${RRC_REESTAB_OTHER_FAILURE}=1
...    NRCELL-2:${RRC_REESTAB_OTHER_FAILURE}=1
...    NRDU-1:${RRC_REESTAB_ACC_OTHER_FAIL_DU}=2
...    NRCELL-1:${REESTAB_ACC_OTHER_FAIL}=1
...    NRCELL-2:${REESTAB_ACC_OTHER_FAIL}=1
...    NRCELL-1:${REESTAB_RRCRECONFIG_SUCC}=1
...    NRCELL-2:${REESTAB_RRCRECONFIG_SUCC}=1
...    NRCELL-1:${REESTAB_ADMISSION_CRTL}=1
...    NRCELL-2:${REESTAB_ADMISSION_CRTL}=1
...    NRCELL-1:${REESTAB_ACC_VONR}=1
...    NRCELL-1:${RRC_REESTAB_ATT_VONR}=1
...    NRCELL-1:${EPmCounterId_5G_SGNB_SA_DU_ADMISSION_REQ}=2
...    NRCELL-2:${EPmCounterId_5G_SGNB_SA_DU_ADMISSION_REQ}=1
...    NRCELL-1:${EPmCounterId_5G_SGNB_SA_DU_ADMISSION_SUCC}=2
...    NRCELL-2:${EPmCounterId_5G_SGNB_SA_DU_ADMISSION_SUCC}=1
...    NRCELL-1:${EPmCounterId_5G_SGNB_SA_DU_NGBR_DRB_REQ}=4
...    NRCELL-2:${EPmCounterId_5G_SGNB_SA_DU_NGBR_DRB_REQ}=3
...    NRCELL-1:${EPmCounterId_5G_SGNB_SA_DU_NGBR_DRB_SUCC}=4
...    NRCELL-2:${EPmCounterId_5G_SGNB_SA_DU_NGBR_DRB_SUCC}=3
...    NRCELL-1:${EPmCounterId_5G_SGNB_SA_DU_NGBR_DRB_REL}=4
...    NRCELL-1:${SA_DU_GBR_DRB_REQ}=1
...    NRCELL-2:${SA_DU_GBR_DRB_REQ}=1
...    NRCELL-1:${SA_DU_GBR_DRB_SUCC}=1
...    NRCELL-2:${SA_DU_GBR_DRB_SUCC}=1
...    ${NE1CS_ROHC_DRB_CTX_REQ_SENT}=10
...    ${NE1CS_ROHC_DRB_CTX_RESP_RECD}=10

${RRC_REESTAB_OTHER_FAILURE}       M55124C00505    #Number of RRC Re-establishment Request caused by HO failure
${RRC_REESTAB_ACC_OTHER_FAIL_DU}    M55127C00512    #Number of accepted RRC Re-establishment when reestablishment cause is other failure
# The counter is updated when receiving the RRCReestablishmentComplete message when the reestablishmentCause is otherFailure
${REESTAB_ACC_OTHER_FAIL}    M55124C00512
${REESTAB_RRCRECONFIG_SUCC}    M55124C00516    #Number of RRC reconfiguration successful in RRC reestablishment procedure
${REESTAB_ADMISSION_CRTL}    M55124C00519    #Number of admission control triggered in CU by RRC reestablishment procedure
#The number of successful RRC Reestablishment procedures for VONR for all reestablishment causes
${REESTAB_ACC_VONR}    M55124C00518
#The number of RRC Re-establishment Request attempts for VONR for any cause RRC_REESTAB_ATT_VONR
${RRC_REESTAB_ATT_VONR}    M55124C00520
${EPmCounterId_5G_SGNB_SA_DU_ADMISSION_REQ}    M55139C00001    #Number of SA DU ADMISSION REQ
${EPmCounterId_5G_SGNB_SA_DU_ADMISSION_SUCC}    M55139C00002    #Number of SA DU ADMISSION SUCC
${EPmCounterId_5G_SGNB_SA_DU_NGBR_DRB_REQ}    M55139C00003     #Number of SA DU NGBR DRB REQ
${EPmCounterId_5G_SGNB_SA_DU_NGBR_DRB_SUCC}    M55139C00004    #Number of SA DU NGBR DRB SUCC
${EPmCounterId_5G_SGNB_SA_DU_NGBR_DRB_REL}    M55139C00012    #Number of SA DU NGBR DRB REL
#The number of GBR DRB radio admission requests in DU for SA user.
${SA_DU_GBR_DRB_REQ}    M55139C00501
#The number of GBR DRB successful radio admissions for SA user.
${SA_DU_GBR_DRB_SUCC}    M55139C00502
#Number of RoHC contexts configured for the DRBs for which RoHC compression is requested by gNB-CU-CP from gNB-CU-UP.
${NE1CS_ROHC_DRB_CTX_REQ_SENT}    M55135C01001
#Number of RoHC contexts configured for the DRBs for which RoHC compression is requested by gNB-CU-CP from gNB-CU-UP.
${NE1CS_ROHC_DRB_CTX_RESP_RECD}    M55135C01002
 
${ReconfigurationFailure}    otherFailure
${ue_id}    81
${gw_id}    2

*** Test Cases ***
5GC000732-ET-F007_RRC_loop_reestablish_succ_with_2329_meas_to_new_2329_blind_Pcell_old_DRX_disabled_707_A2_configured_new_DRX_enabled_704
    [Documentation]    This case will test RRC reestablish to new_cell due to otherFailure combine with F007 and F099
    ...    5GC000732-ET-F099_RRC_reestablish_from_normal_call_to_VONR_call
    ...    preconditions:
    ...        1. configure T+F for 2329(cell 1+ cell 12 covBasedA1) with interRat(707) and meas(A1,A2), non-DRX, VoNR
    ...        2. configure T+F for 2329 new (cell 2 + cell 11 blind) with intraFreq(704),DRX ,VonR
    ...    Case steps:
    ...        1.Setup CA(TDD+FDD) successfully
    ...        2.Trigger normal call on Cell 1
    ...        3.Trgger RRC reestablish (reestablish to cell 2 - otherFailure)without scelladd,
    ...          RRC reestablish should successfully 
    ...        4.Add 5QI5 , 5QI1 ,setup Vonr call successuflly 
    ...        5.Trgger RRC reestablish (reestablish to cell 1 - otherFailure), RRC reestablish should successfully
    ...        6.Add 5QI5 , 5QI1 ,setup Vonr call successuflly 
    ...        7.check cause otherFailure in rrcReestablishmentRequest wiresahrk msg
    ...        8.check counter:

    [Tags]    QC_165746    F007
    Ue Register And Pdu Session Setup At FDD Cell-1  
    Start To Capture Wireshark Log    F00700
    Trigger RRC Reestablish    2    ${ReconfigurationFailure}    PduId 3 Created    
    Check Wireshark Log    ${CURDIR}${/}a2a_F007_00${/}a2a.ini    name=F00700    wait_string=UEContextModificationResponse::18
    Start To Capture Wireshark Log    F00701
    Trigger RRC Reestablish    1    ${ReconfigurationFailure}    invalid or already used
    Verify Throughput And Check Counters    sleep_time=40s
    Check Wireshark Log    ${CURDIR}${/}a2a_F007_01${/}a2a.ini    name=F00701    wait_string=UEContextReleaseComplete::4
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
    Update Cfg    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full_enable_ROHC_powersaving}

Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/L1B/6cells_2T4F

Ue_Deregister
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE CONTEXT RELEASE COMPLETE

Trigger RRC Reestablish
    [Arguments]    ${cell_id}    ${cause}    ${wait_string}
    ${ret1}=    Execute Egate Command    ue_rrc_reestablish id=${ue_id} gnb=2 cell=${cell_id} cause=${cause}
    ...    NR RRC Reestablishment sucessfully completed    timeout=20s
    sleep    42    reason=wait finished
    Execute Egate Command    smf_param id=1 additional_qosflows_to_activate=2,3	
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=3 nwslice=1 gw=${gw_id}    ${wait_string}

Ue Register And Pdu Session Setup At FDD Cell-1
    Clear Counter Files
    Execute Egate Command    qosflow_modify qos_flow=1 default=on
    Execute Egate Command    ue_location_change id=${ue_id} enb=2 cell=1
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=UE now in NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1    pass_regexp=QoS Routing Table
    sleep    42    reason=wait rrc finished
    Trigger Throughput

Trigger Throughput
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=70 trf_id=1    pass_regexp=Started Downlink
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=ul mbps=10 trf_id=1    pass_regexp=Started Uplink    

Verify Throughput And Check Counters
    [Documentation]    verify Tput in scell is not 0
    [Arguments]    ${Tput_dl}=60    ${Tput_ul}=9    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pdsch    Throughput
    Should Not Match Regexp    ${scell_tput}    CellIndex-.*Mbps.*Mbps.*Mbps.* 0 Mbps
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}
    Ue_Deregister
    Check Counters    ${PM_Counters_Check}
