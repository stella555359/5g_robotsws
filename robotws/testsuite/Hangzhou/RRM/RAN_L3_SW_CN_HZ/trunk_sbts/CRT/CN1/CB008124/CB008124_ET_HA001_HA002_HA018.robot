*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    team-CN1ET    owner-zhang.yige
...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    CRT    CB008124    release-SBTS23R4
...    STATE_CONFIGURED
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
#The following log is needed for issue debug
${TTITRACE_FLAG}    ${True}
${SYSCOM_FLAG}    ${True}

@{PARAMS_IN_SCF}
...    NRBTS-1:cipherPrefL:nea0=8
...    NRBTS-1:cipherPrefL:nea1_128=0
...    NRBTS-1:cipherPrefL:nea2_128=0
...    NRBTS-1:cipherPrefL:nea3_128=0
...    @{8124_related_modification}
...    @{5qi80_related_modification}
...    @{actCDrx}
...    @{Param_for_HA002}
...    @{5qi2_5gi1_related_modification}
...    @{RRE}

@{actCDrx}
...    NRCELL:actCDrx=true
...    NRCELL:drxProfile1:drxInactivityTimer=20ms
...    NRCELL:drxProfile1:drxLongCycle=40ms
...    NRCELL:drxProfile1:drxOnDurationTimer=10ms
...    NRCELL:drxProfile1:drxRetransTimerDl=16slot
...    NRBTS-1/NRPMRNL-1:miNrInterGnbMobilityNsaPmqap=disabled
...    NRBTS-1/NRPMRNL-1:miNrInterGnbNgMobilitySaPmqap=disabled
...    NRBTS-1/NRPMRNL-1:miNrInterGnbXnMobilitySaPmqap=disabled
...    NRBTS-1/NRPMRNL-1:miNrIntraGnbMobilitySaPmqap=disabled
...    NRBTS-1/NRPMRNL-1:miNrIntraGnbMobilityNsaPmqap=disabled
...    NRBTS-1/NRPMRNL-1:miNrNgcFlexInterface=disabled

@{8124_related_modification}
...    NRCELL:pucchModeSelect=longPucch
...    NRCELL:actUlCgType2=true
...    NRBTS/NRDRB-16:nrDrbUlCgDN=MRBTS-1/NRBTS-1/NRULCG_PROFILE-1
...    NRBTS/NRULCG_PROFILE-1:grantedPacketSize=2000
...    NRBTS/NRULCG_PROFILE-1:maxNumPrbs=16
...    NRBTS/NRULCG_PROFILE-1:periodicity=ms2
...    NRCELL-1:ulConfiguredGrantType2:ulCgMaxNumPrbs=16
...    NRCELL-1:ulConfiguredGrantType2:ulCgPrbStartOffset=0
...    NRCELL-1:ulConfiguredGrantType2:ulCgMaxNumUeUl=4
...    NRCELL-2:ulConfiguredGrantType2:ulCgMaxNumPrbs=24
...    NRCELL-2:ulConfiguredGrantType2:ulCgPrbStartOffset=0
...    NRCELL-2:ulConfiguredGrantType2:ulCgMaxNumUeUl=5
...    NRCELL-2:tddFrameStructure:frameStructureType=semiStatic
...    NRCELL-2:tddFrameStructure:guardPeriodLength=2Symbols
...    NRCELL-2:tddFrameStructure:ulDlDataSlotRatio=3/7


...    NRCELL-1:drxProfile1:drxHarqRttTimerUl=28symbols    #28symbols
...    NRCELL-1:drxProfile1:drxRetransTimerUl=6slot
...    NRCELL-2:drxProfile1:drxHarqRttTimerUl=14symbols
...    NRCELL-2:drxProfile1:drxRetransTimerUl=8slot
...    NRCELL:actDrxRetransTimerSupport=true
...    NRBTS/NRDRB-17:cellAggrLevel=Not FR1 CA eligible
...    NRBTS/NRDRB-15:cellAggrLevel=Not FR1 CA eligible
@{5qi80_related_modification}
...    NRBTS-1/NRDRB-16:actDddsReduction=false
...    NRBTS-1/NRDRB-16:actDlTxResumeOnPdcpStatRep=false
...    NRBTS-1/NRDRB-16:actLostPduFastRetx=false
...    NRBTS-1/NRDRB-16:caPduReSendingDelayMargin=2
...    NRBTS-1/NRDRB-16:discardTimer=infinity
...    NRBTS-1/NRDRB-16:discardTimerUl=infinity
...    NRBTS-1/NRDRB-16:dlAllowMinDelayLinkXxCalib=false
...    NRBTS-1/NRDRB-16:dlFlowControlAlgo=none    #UM
...    NRBTS-1/NRDRB-16:dscp=0
...    NRBTS-1/NRDRB-16:dtxDelaySinceLastScheduling=0
...    NRBTS-1/NRDRB-16:dtxMaxRetentionDelay=10
...    NRBTS-1/NRDRB-16:durationThresDiscardDl=40
...    NRBTS-1/NRDRB-16:durationThresDiscardUl=20
...    NRBTS-1/NRDRB-16:endMarkerTimer=2000
...    NRBTS-1/NRDRB-16:l2OHFactorDl=16
...    NRBTS-1/NRDRB-16:l2OHFactorUl=35
...    NRBTS-1/NRDRB-16:maxDddsPeriodCpuOvld=40
...    NRBTS-1/NRDRB-16:maxRlcQueueingDelayGbr=20
...    NRBTS-1/NRDRB-16:maxTransferDelayGbr=20
...    NRBTS-1/NRDRB-16:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-5
...    NRBTS-1/NRDRB-16:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-1
...    delete:NRBTS-1/NRDRB-16:nrDrbRlcAmDN
...    NRBTS-1/NRDRB-16:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1    #UM
...    NRBTS-1/NRDRB-16:nrDrbUlCgDN=MRBTS-1/NRBTS-1/NRULCG_PROFILE-1
...    NRBTS-1/NRDRB-16:numSduDiscard=1
...    NRBTS-1/NRDRB-16:pdcpStatRepWaitTimer=20
...    NRBTS-1/NRDRB-16:pdcpStatRepWaitTimerOffset=50

...    NRBTS-1/NRDRB-16:queuingDelaySduDiscardThreshold=750
...    NRBTS-1/NRDRB-16:resType=nonGBR
...    NRBTS-1/NRDRB-16:rlcMode=RLC_UM     #UM
...    NRBTS-1/NRDRB-16:rlcPduDelayThCa=30
...    NRBTS-1/NRDRB-16:schedulWeight=12
...    NRBTS-1/NRDRB-16:sduDiscardIntervalTmr=500
...    NRBTS-1/NRDRB-16:volThresDiscardDl=8000
...    NRBTS-1/NRDRB-16:volThresDiscardUl=800
...    delete:NRBTS-1/NRDRB-16:nsaDrbParam
...    NRBTS-1/NRDRB_5QI-80:fiveqiValueList=80
...    NRBTS-1/NRDRB_5QI-80:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-16
...    NRBTS/NRDRB_RLC_UM-1:dlTReassemblyUm=ms50
...    NRBTS/NRDRB_RLC_UM-1:rlcUMDrbSNLength=rlcUm12bitSN
...    NRBTS/NRDRB_RLC_UM-1:ulTReassemblyUm=ms50
...    NRBTS/NRDRB_MAC-5:delayTarget=50
...    NRBTS/NRDRB_MAC-5:lcgid=1
...    NRBTS/NRDRB_MAC-5:prioritisedBitRate=16kBps
...    NRBTS/NRDRB_MAC-5:schedulBSD=100ms
...    NRBTS/NRDRB_MAC-5:schedulPrio=10

@{5qi2_5gi1_related_modification}

...    NRCELL-1:actVoNR=true
...    NRCELL-1:actCDrxVoNR=true
...    NRCELL-1:n310VoNR=n10
...    NRCELL-1:t310VoNR=100ms
...    NRCELL-1:actEnhancedVoNR=true
...    NRCELL-1:drxProfile2:drxInactivityTimer=20ms
...    NRCELL-1:drxProfile2:drxLongCycle=40ms
...    NRCELL-1:drxProfile2:drxOnDurationTimer=20ms
...    NRCELL-1:drxProfile2:drxRetransTimerDl=0slot
...    NRCELL-1:drxProfile2:drxRetransTimerUl=0slot
...    NRDRB_MAC-3:lcgid=4
...    NRDRB_MAC-3:prioritisedBitRate=16kBps
...    NRDRB_MAC-3:schedulPrio=5
...    NRDRB_MAC-3:schedulBSD=50ms
...    NRDRB_PDCP-2:pdcpBufDiscardEnabled=false
...    NRDRB-15:discardTimer=30ms
...    NRDRB-15:dlFlowControlAlgo=none
...    NRDRB-15:dscp=0
...    NRDRB-15:actDddsReduction=false
...    NRDRB-15:actLostPduFastRetx=false
...    NRDRB-15:maxDddsPeriodCpuOvld=40
...    NRDRB-15:maxDataRateGbrDl=1000
...    NRDRB-15:maxDataRateGbrUl=1000
...    NRDRB-15:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-3
...    NRDRB-15:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-2
...    NRDRB-15:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRDRB-15:numSduDiscard=1
...    NRDRB-15:queuingDelayDiscarding=Disabled
...    NRDRB-15:queuingDelaySduDiscardThreshold=200
...    NRDRB-15:resType=GBR
...    NRDRB-15:rlcMode=RLC_UM
...    NRDRB-15:schedulWeight=1
...    NRDRB-15:sduDiscardIntervalTmr=100
...    NRBTS/NRDRB-15:maxRlcQueueingDelayGbr=20
...    NRBTS/NRDRB-15:maxTransferDelayGbr=20
...    delete:NRDRB-15:nrPdschHRLaDN
...    NRDRB_5QI-6:fiveqiValueList=1
...    NRDRB_5QI-6:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-15
...    NRDRB_5QI-7:fiveqiValueList=2
...    NRDRB_5QI-7:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-17
...    delete:NRDRB-17:nrPdschHRLaDN
...    NRBTS/NRDRB-17:discardTimer=300ms
...    NRBTS/NRDRB-17:l2OHFactorDl=16
...    NRBTS/NRDRB-17:l2OHFactorUl=35
...    NRBTS/NRDRB-17:maxDataRateGbrDl=30720
...    NRBTS/NRDRB-17:maxDataRateGbrUl=30720
...    NRBTS/NRDRB-17:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-4
...    NRBTS/NRDRB-17:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-3
...    NRBTS/NRDRB-17:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRBTS/NRDRB-17:resType=GBR
...    NRBTS/NRDRB-17:rlcMode=RLC_UM
...    NRBTS/NRDRB-17:schedulWeight=1
...    NRBTS/NRDRB-17:maxRlcQueueingDelayGbr=20
...    NRBTS/NRDRB-17:maxTransferDelayGbr=20
...    NRBTS/NRDRB_MAC-4:lcgid=5
...    NRBTS/NRDRB_MAC-4:delayTarget=50
...    delete:NRBTS/NRDRB-16:drbInactivityTimerSA
...    NRBTS/NRDRB_PDCP-3:tReorderingDl=ms100
...    NRBTS/NRDRB_PDCP-3:tReorderingUl=ms100
...    NRBTS/NRDRB_PDCP-3:pdcpBufDiscardEnabled=false
...    NRCELL:actNonVoNRGbrService=true
...    NRDRB-10:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-1
...    NRDRB-10:resType=nonGBR

@{RRE}
...    NRBTS:rrcReestabTypeSA=sameGNB

@{Param_for_HA002}
...    @{CA_enable}
...    @{HO_enable}

@{HO_enable}
...    NRCELL-1:ifhoSsbSmtcOffset=0
...    NRCELL-1:gapOffset=0
...    NRCELL-1:mgta=ms0
...    NRBTS-1/NRPMRNL-1:miNrRelReportCu=5min
...    NRBTS:actInterFreqHoSA=true
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-1:gNbId=1
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-1:lcrId=2
...    NRCELL-1/NRREL-1:removeNotAllowed=false
...    NRCELL-1/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-1:a1MeashoEnabledSA=rsrp
...    NRCELL-1:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRCELL-1:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=60
...    NRCELL-1:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL-1:a2MeashoEnabledSA=rsrp
...    NRCELL-1:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0
...    NRCELL-1:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=34
...    NRCELL-1:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL-1:a3MeasEnabled=rsrp
...    NRCELL-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=30
...    NRCELL-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms40
...    NRCELL-1:measGapSelectionSA=favourUeThroughput
...    NRCELL-1/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-1/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-1/NRHOIF-1:chBw=100MHz
...    NRCELL-1/NRHOIF-1:freqBandIndicatorNR=78
...    NRCELL-1/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf2
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf20
...    NRCELL-1/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-1/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-1:ssbFrequency=643392
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms1024
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=4
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL-2:nrarfcn=643400
...    NRCELL-2:gscnOrSsPbchArfcn=7951
...    NRCELL-2:ifhoSsbSmtcOffset=0
...    NRCELL-2:gapOffset=0
...    NRCELL-2:mgta=ms0
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
...    NRCELL-2:a1MeashoEnabledSA=rsrp
...    NRCELL-2:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRCELL-2:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=60
...    NRCELL-2:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL-2:a2MeashoEnabledSA=rsrp
...    NRCELL-2:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0
...    NRCELL-2:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=34
...    NRCELL-2:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL-2:a3MeasEnabled=rsrp
...    NRCELL-2:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-2:a3MeasSsbRsrp:a3OffsetSsbRsrp=30
...    NRCELL-2:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms40
...    NRCELL-2:measGapSelectionSA=favourUeThroughput
...    NRCELL-2/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-2/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-2/NRHOIF-1:chBw=100MHz
...    NRCELL-2/NRHOIF-1:freqBandIndicatorNR=78
...    NRCELL-2/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-2/NRHOIF-1:ifhoSsbSmtcDuration=sf2
...    NRCELL-2/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf20
...    NRCELL-2/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-2/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-2/NRHOIF-1:ssbFrequency=636576
...    NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms1024
...    NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=4
...    NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=10

@{CA_enable}
...    NRBTS-1:actCarrierAggregation=true
...    NRBTS-1:caConfigurationSupport=2CCDL_2CCUL
...    NRBTS-1:maxNumScellsDl=3
...    NRBTS-1:maxNumScellsUl=1
...    NRDU-1:actInterNumerologyCa=true
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRBTS-1:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS-1:sCellActivationMethod=bufferBased
...    NRCELL:actK1Opt=intra-gNB
...    NRDU-1:carrierAggregationSupportList=ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Fdd
...    NRCELL-1:a1MeasSCellAddEnabled=rsrp
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=70
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=80
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-2:a2MeasSCellRelEnabled=rsrp
...    NRCELL-2:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0
...    NRCELL-2:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=34
...    NRCELL-2:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=1280ms
...    NRCELL:allowUnsuppBcOrBcs=accept unknown BCSs

@{OnlineParam_for_HA002}
...    NRBTS-1/NRDRB-16:dlFlowControlAlgo=3gppFlowControl
...    NRBTS-1/NRDRB-16:nrDrbRlcAmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_AM-1
...    NRBTS-1/NRDRB-16:rlcMode=RLC_AM
...    delete:NRBTS-1/NRDRB-16:nrDrbRlcUmDN

${LOOP}    1

@{cg drx setup}
...    drx-HARQ-RTT-TimerUL 28
...    drx-RetransmissionTimerUL sl6
...    enhancedSkipUplinkTxConfigured-r16 true

@{cg drx setup cell2}
...    drx-HARQ-RTT-TimerUL 14
...    drx-RetransmissionTimerUL sl8
...    enhancedSkipUplinkTxConfigured-r16 true

@{Online_Change_Prepare_HA018}
...    NRBTS/NRULCG_PROFILE-1:periodicity=ms10
...    NRCELL-1:drxProfile1:drxHarqRttTimerUl=14symbols
...    NRCELL-1:drxProfile1:drxRetransTimerUl=8slot

@{Online_Change_HA018}
...    NRCELL-1:drxProfile1:drxHarqRttTimerUl=28symbols
...    NRCELL-1:drxProfile1:drxRetransTimerUl=16slot

@{Online_Restore_HA018}
...    NRBTS/NRULCG_PROFILE-1:periodicity=ms2
...    NRCELL-1:drxProfile1:drxHarqRttTimerUl=14symbols
...    NRCELL-1:drxProfile1:drxRetransTimerUl=8slot

@{CG_config_HA018}
...    rrcReconfigurationComplete
...    drx-Config setup
...    drx-HARQ-RTT-TimerUL 14
...    drx-RetransmissionTimerUL sl8
...    configuredGrantConfig setup

@{Add_5QI2_Release_Drx}
...    Added QosFlow with QFI:2 fiveQI:2
...    drx-Config release : NULL

@{Delete_5QI2_Setup_Drx}
...    Deleted QoSFlow with QFI 2 SEID 1
...    drx-Config setup
...    drx-HARQ-RTT-TimerUL 28
...    drx-RetransmissionTimerUL sl16

@{RRE_Success_With_New_CG_Config}
...    NR RRC Reestablishment sucessfully completed
...    drx-Config setup
...    drx-HARQ-RTT-TimerUL 28
...    drx-RetransmissionTimerUL sl16

# To support intra-gnb CA NRCELL1 and NRCELL2
${UE_Capa_Support_CG2_CA}    SEPARATOR=
...    E9A09000577F0140502D098B00C1E210002C1262E003387A12013641873E618F28581C130180623807DC6C28C0D608C21A08107483401
...    B5B262AC6873E238F40CFB027C62471E439F51CF9863CA1607038782E007FE003801FF8002E0000702A0D883AC1184341020F1068032B
...    64C55890E7D813E238F1891C790E7D473E618F28581C0E1E13FFE00000FFF800000B80001C0AA3626EB04610D04083A41A00B2D931543
...    439F11C7A067D813E31CF9863CA16070387817003FF001C00FFC00170000381506C46D608C21A08107CA0D00496C98AA0A1CF88E3C600
...    00000000000070F027FFC00001FFF000001700003800EF0F10400388C0000002C040BC3C28000E230000010B0102F0F0A000388200000
...    82C040BC3C41000E268000030B0102F0F0A000389A0000102C040BC3C46000E268000050B0102B0F13400389A0000182C0803808D00A2
...    026C041170005303C28913639F0E14489B1CF870A244D8E7C3851226C73E1C28913639F0E14489B1CF870A040D8E7C01E82E003C00281
...    C1401C0C0240070240040603E008020000000100000200B036B2A68020800004B29282000032CA4A00A81D552AAA16004800D02800182
...    0200400808010021010040080400801080802004020040084040080101004008202008010080200410100200404010020808020040200
...    8010D50F8000810182030385058606880889098A0C0C8D8E0E8F909293139414951697A0A0C1680

#Following tags are used to enable debug log
@{PARAMS_IN_SWCONFIG}
...    @{bitmap_level}
...    @{ULCG_TYPE2}
...    @{ULCG_TYPE2_LA}
...    @{L2_HARQ_DCI_BSR_ACSI}
...    @{L2_DL_DCI}
#it will effect retransmission if removed
...    @{rdHARQDisableIncrRedundancyUl}

@{bitmap_level}
...    0x58057A=3
@{ULCG_TYPE2}
...    0x58057E=0x200
@{ULCG_TYPE2_LA}
...    0x58057F=0x80
@{L2_HARQ_DCI_BSR_ACSI}
...    0x58057D=0x3300
@{L2_DL_DCI}
...    0x58057C=0x80000
@{rdHARQDisableIncrRedundancyUl}    
...    0x580180=1

@{PM_Counters_Check_HA001}
...    NRCELL-1:${UL_CG_ACT_ATT}>1
...    NRCELL-1:${UL_CG_ACT_ATT_SUCC}>1
...    NRCELL-1:${UL_CG_DEACT_ATT}>0
...    NRCELL-1:${UL_CG_DEACT_ATT_SUCC}>0
...    NRCELL-1:${CG_INI_TX_PUSCH_UNSUCC}>0
...    NRCELL-1:${CG_RE_TX_PUSCH_SUCC}>0
...    NRCELL-1:${CG_RE_TX_PUSCH_UNSUCC}>0

@{PM_Counters_Check_HA002}
...    NRCELL-1:${UL_CG_ACT_ATT}>1
...    NRCELL-1:${UL_CG_ACT_ATT_SUCC}>1
...    NRCELL-1:${UL_CG_DEACT_ATT}>1
...    NRCELL-1:${UL_CG_DEACT_ATT_SUCC}>1
...    NRCELL-1:${CG_INI_TX_PUSCH_UNSUCC}>0
...    NRCELL-1:${CG_RE_TX_PUSCH_SUCC}>0
...    NRCELL-1:${CG_RE_TX_PUSCH_UNSUCC}>0
...    NRCELL-2:${UL_CG_ACT_ATT}>0
...    NRCELL-2:${UL_CG_ACT_ATT_SUCC}>0
...    NRCELL-2:${CG_INI_TX_PUSCH_UNSUCC}>0
...    NRCELL-2:${CG_RE_TX_PUSCH_SUCC}>0
...    NRCELL-2:${CG_RE_TX_PUSCH_UNSUCC}>0

@{PM_Counters_Check_HA018}
...    NRCELL-1:${UL_CG_ACT_ATT}>=2
...    NRCELL-1:${UL_CG_ACT_ATT_SUCC}>=2
...    NRCELL-1:${UL_CG_DEACT_ATT_SUCC}>=1

${UL_CG_ACT_ATT}    M55308C00020    #This counters provides the number of initial activation attempts of
#UL grant Type 2 scheduling sent through the PDCCH in DCI format 0_1.
${UL_CG_ACT_ATT_SUCC}    M55308C00021    #This counters provides the number of successful activation attempts of
#UL grant Type 2 scheduling sent through the PDCCH in DCI format 0_1.
${UL_CG_DEACT_ATT}    M55308C00022     #This counters provides the number of initial deactivation attempts of
#UL grant Type 2 scheduling sent through the PDCCH in DCI format 0_0.
${UL_CG_DEACT_ATT_SUCC}    M55308C00023     #This counters provides the number of successful deactivation attempts of
#UL grant Type 2 scheduling sent through the PDCCH in DCI format 0_0.
${CG_INI_TX_PUSCH_UNSUCC}    M55308C00027    #The counter provides the sum of CG initial transmissions on the
#PUSCH unsuccessfully received by the gNB during the measurement period.
${CG_RE_TX_PUSCH_SUCC}    M55308C00029     #The counter provides the sum of CG retransmissions on the PUSCH
#successfully received on the gNB during the measurement period.
${CG_RE_TX_PUSCH_UNSUCC}    M55308C00030    #The counter provides the sum of CG retransmissions on the PUSCH
#unsuccessfully received on the gNB during the measurement period.

*** Test Cases ***
CB008124-ET-HA001_non_GBR_DRX1_setup_withCG_activation
    [Documentation]
    ...    1. The purpose of this test case is to check gNB behaviour needed to configure DRX for
    ...       UE capable to setup UL Grant Type 2 for activated cell.
    ...    2. Configuration
    ...    a.SA+NSA,TDD
    ...    b.Configured UL Grants Type 2 feature: NRBTS/NRCELL.actUlCgType2=true
    ...    c.default drb 5QI_80 RLC_UM is associated with NRULCG_PROFILE.
    ...    d.UE support CG2.
    ...    3. Test Case Steps:
    ...    a.UE attach and set up DRB 5QI_80 with CG2 configured
    ...    b.run UL traffic,then stop UL traffic and start DL traffic,then stop DL traffic and start UL traffic with 10% bler.
    ...    c.UE detach.
    ...    filter for bip log debug:(dldata_pdcchsendreq||uldata_puschreceivereq||uldata_puschreceiverespharqu||uldata_puschreceiveresplo
    ...    ||uldata_puschreceiverespps||mac-nr.ulsch.lcid == 0x37||uldata_pucchreceiverespharqd||uldata_pucchreceiverespps)&&3gpp.rnti!=65535
    [Tags]    QC_280330    owner-zhang.yige    HA001
    Setup Test Config For HA001
    ICS Without PDU    ue_id=1    cell_id=1
    Run UL Traffic And Verify Throughput    Tput_ul=6000000    trf_id=1
    Stop Traffic UL    trf_id=1
    Run DL Traffic And Verify Throughput    trf_id=2
    Stop Traffic DL    trf_id=2
    TestMode CRC NotOK    CgBler=10
    Run UL Traffic And Verify Throughput    Tput_ul=6000000    trf_id=1    Tput_ul_re=2
    UE Deregister From gNB    ue_id=1
    Check Counters    ${PM_Counters_Check_HA001}

CB008124-ET-HA002_non_GBR_DRX1_setup_withCG_activation_then_intra_DU_HO_success
    [Documentation]
    ...    1. The purpose of this test case is to check gNB behaviour needed to configure DRX for
    ...       UE capable to setup UL Grant Type 2 for activated cell.
    ...    2. Configuration
    ...    a.SA+NSA,TDD
    ...    b.Configured UL Grants Type 2 feature: NRBTS/NRCELL.actUlCgType2=true
    ...    c.default drb 5QI_80 RLC_AM is associated with NRULCG_PROFILE.
    ...    d.UE support CG2.
    ...    3. Test Case Steps:
    ...    a.UE attach to NRCELL-1 and set up DRB 5QI_80 with CG2 configured
    ...    b.start UL traffic with 10% bler.then trigger scell addition , add NRCELL-2 as scell.
    ...    c.tigger intra_DU handover from NRCELL-1 to NRCELL-2.
    ...    d.then stop UL traffic and start DL traffic,then stop DL traffic and start UL traffic with 10% bler.
    ...    e.tigger intra_DU handover from NRCELL-2 to NRCELL-1.
    ...    f.set UL bler from 10% to 0%
    ...    in case HA002, change DRB RLC mode from RLC_UM to nonGBR RLC_AM DRB to trigger Scell addition.
    [Tags]    QC_280329    owner-zhang.yige    HA002    AP_REG
    Setup Test Config For HA002
    ICS Without PDU    ue_id=1    cell_id=1    ics=off
    TestMode CRC NotOK
    Run UL Traffic And Verify Throughput    Tput_ul=6000000    trf_id=1
    Handover Between Ncell1 and Nrcell2 times
    UE Deregister From gNB    ue_id=1
    Check Counters    ${PM_Counters_Check_HA002}

CB008124-ET-HA018_online_modify_RRE
    [Documentation]
    ...    The purpose of this test case is to check gNB behaviour related to online modification of cgDrxRetransTimerUl and
    ...    cgDrxHarqRTTTimerUl specific for Configured Grant Type 2 UEs.
    ...    2. Configuration
    ...       a.SA+NSA,TDD
    ...       b.Configured UL Grants Type 2 feature: NRBTS/NRCELL.actUlCgType2=true
    ...       c.default drb 5QI_80 is associated with NRULCG_PROFILE.
    ...       d.UE not support CG2.
    ...    3. Test Case Steps:
    ...       a.UE attach and set up PDU session.5QI_80 is setup with CG2.
    ...       b.online change cgDrxHarqRttTimerUl and cgDrxRetransTimerUl successfully.
    ...       c.setup DRB3 (5QI-2) on UE1, then release DRB3, DRX1 setup on UE with first parameter.
    ...       d.RRE to original cell successfully with CG active(second parameter) and changed parameters in step b are used.
    ...       e.Stop traffic to trigger CG deactive then UE detach.
    [Tags]    QC_280313    owner-jing.ye    HA018    AP_REG
    OnlineParamChange    ${Online_Change_Prepare_HA018}
    Clear Counter Files    ${false}
    UE attach and set up PDU session
    OnlineParamChange    ${Online_Change_HA018}
    Setup Then Remove DRB With 5QI2
    Trigger RRC Reestablishment Successfully With New CG Config    ue_id=1    cell_id=1
    Stop Traffic and UE Deregister From gNB
    OnlineParamChange    ${Online_Restore_HA018}
    Check Counters Should Be Correct

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri    ue_count=2

Setup Test Config For HA001
    Update UE capa    ue_id=1    SA_Capa_perUE_Full=${SA_Capa_nonca_FULL}
    Update UE capa    ue_id=2    SA_Capa_perUE_Full=${SA_Capa_nonca_FULL}
    Clear Counter Files

Setup Test Config For HA002
    OnlineParamChange    ${OnlineParam_for_HA002}
    Update UE capa    ue_id=1    SA_Capa_perUE_Full=${UE_Capa_Support_CG2_CA}
    Update UE capa    ue_id=2    SA_Capa_perUE_Full=${UE_Capa_Support_CG2_CA}
    Clear Counter Files

TestMode CRC NotOK
    [Arguments]    ${CgBler}=10
    Execute Egate Command    cg_testmode_nr profile_id=1 CgDrxErrorType=1 CgDrxOnErrorPercent=${CgBler} CgDrxOffErrorPercent=${CgBler}
    Execute Egate Command    ue_testmode_set_nr id=1 testmode=configured_grant profile_id=1 scell=0 action=activate

Handover Between Ncell1 and Nrcell2 times
    FOR    ${index}    IN RANGE    0    ${LOOP}
        A1 Based Scell Addition
        Inter Freq intra GNB HO From Ncell1 to Nrcell2
        Sleep    200ms    #keep UL traffic
        Stop Traffic UL    trf_id=1
        Run DL Traffic And Verify Throughput    trf_id=2
        Stop Traffic DL    trf_id=2
        TestMode CRC NotOK    CgBler=10
        Run UL Traffic And Verify Throughput    Tput_ul=6000000    trf_id=1    Tput_ul_re=2
        Inter Freq intra GNB HO From Ncell2 to Nrcell1
        TestMode CRC NotOK    CgBler=0
        Stop Traffic UL    trf_id=1
        Run UL Traffic And Verify Throughput    Tput_ul=6000000    trf_id=1
    END

Run UL Traffic And Verify Throughput
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${qfi}=1    ${trf_id}=1    ${Tput_ul}=4000000    ${Tput_ul_re}=3.9
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} trf_id=${trf_id} bps=${Tput_ul} dir=ul
    ...    pass_regexp=Started Uplink Internal traffic
    Verify Throughput UL TP    ${ue_id}    ${pdu}    ${qfi}    ${Tput_ul_re}

Run DL Traffic And Verify Throughput
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${qfi}=1    ${trf_id}=1    ${Tput_dl}=20
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} trf_id=${trf_id} mbps=${Tput_dl} dir=dl
    ...    pass_regexp=Started Downlink Internal traffic
    Verify Throughput DL TP    ${ue_id}    ${pdu}    ${qfi}    18

Stop Traffic UL
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${trf_id}=1
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=${pdu} dir=ul trf_id=${trf_id}
    ...    pass_regexp=Stopping Uplink Internal traffic

Stop Traffic DL
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${trf_id}=2
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=${pdu} dir=dl trf_id=${trf_id}
    ...    pass_regexp=DL Traffic was stopped

Verify Throughput UL TP
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${qfi}=1    ${Tput_ul}=5    ${sleep_time}=5s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    direction=ul    rate_type=ave
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pusch    Throughput
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

Verify Throughput DL TP
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${qfi}=1    ${Tput_dl}=20    ${sleep_time}=5s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    direction=ul    rate_type=ave
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pdsch    Throughput
    Should Be True    ${dl_throughput}/1000>${Tput_dl}

A1 Based Scell Addition
    ${measid}    get nr meas id for specific type and frequency    ue_id=1    carrierfreq=636576    event_type=A1
    Execute Egate Command    ue_measurement_send_nr id=1 meas_id=${measid} event=A1 srsrp_nr=100
    ...    eventId

Inter Freq intra GNB HO From Ncell1 to Nrcell2
    ${measid}    get nr meas id for specific type and frequency    ue_id=1    carrierfreq=636576    event_type=A2
    Execute Egate Command    ue_measurement_send_nr id=1 meas_id=${measid} event=A2 srsrp_nr=25
    ...    pass_regexp=eventA3
    ${measid}    get nr meas id for specific type and frequency    ue_id=1    carrierfreq=643392    event_type=A3
    Execute Egate Command    ue_measurement_send_nr id=1 meas_id=${measid} event=A3 srsrp_nr=55 phycell_id=51 nrsrp_nr=80
    ...    pass_regexp=${cg drx setup cell2}

Inter Freq intra GNB HO From Ncell2 to Nrcell1
    ${measid}    get nr meas id for specific type and frequency    ue_id=1    carrierfreq=643392    event_type=A2
    Execute Egate Command    ue_measurement_send_nr id=1 meas_id=${measid} event=A2 srsrp_nr=25
    ...    pass_regexp=eventA3
    ${measid}    get nr meas id for specific type and frequency    ue_id=1    carrierfreq=636576    event_type=A3
    Execute Egate Command    ue_measurement_send_nr id=1 meas_id=${measid} event=A3 srsrp_nr=55 phycell_id=50 nrsrp_nr=80
    ...    pass_regexp=${cg drx setup}

ICS Without PDU
    [Arguments]    ${ue_id}    ${cell_id}    ${ics}=on
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    amf_param id=1 send_ics_registration=${ics}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1
    ...    pass_regexp=${cg drx setup}
    Execute Egate Command    amf_param id=1 send_ics_registration=off

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be Onair

Update UE capa
    [Arguments]    ${ue_id}    ${SA_Capa_perUE_Full}=none
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full}
    Execute Egate Command    ${cmd}

Modify Cfg
    Delete Cfg    set_qosflow id=1 5qi=6 default=on
    Update Cfg    set_qosflow id=1 5qi=6
    Update Cfg    set_qosflow id=2 5qi=5
    Update Cfg    set_qosflow id=3 5qi=1
    Update Cfg    set_qosflow id=4 5qi=80 default=on
    Update Cfg    set_qosflow id=5 5qi=2
    Update Cfg    set_qosrule id=1 proto=tcp qos_flow=2
    Update Cfg    set_qosrule id=2 proto=udp qos_flow=3
    Update Cfg    set_qosrule id=3 proto=udp qos_flow=5
    Update Cfg    nwslice_set id=1 qos_flows=1,2,3,4,5 qos_rules=1,2,3 snssai=0x01:0xD143A5 default=on ue=all amf=1

UE attach and set up PDU session
    Update UE capa    ue_id=1    SA_Capa_perUE_Full=${SA_Capa_nonca_FULL}
    UE Attach To Target Cell    ue_id=1    cell_id=1
    start UL traffic    ue_id=1    pdu=1    qfi=1
	
Setup Then Remove DRB With 5QI2
    Add DRB with 5QI2    ue_id=1    PDU=1
    Wait Until Keyword Succeeds    5s    1s    Verify Traffic
    Remove DRB with 5QI2    ue_id=1    PDU=1
    Wait Until Keyword Succeeds    5s    1s    Verify Traffic
	
Stop Traffic and UE Deregister From gNB
    Stop Traffic UL    ue_id=1    pdu=1
    Wait Until Keyword Succeeds    30s    2s    Check No Traffic
    UE Deregister From gNB    ue_id=1
	
UE Attach To Target Cell
    [Arguments]    ${ue_id}    ${cell_id}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1    ${CG_config_HA018}

Start UL traffic
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${qfi}=1 
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} trf_id=1 mbps=5 dir=ul
	
Verify Traffic
    [Arguments]    ${ue_id}=1    ${ul}=4.5
    ${ul_throughput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pusch    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul}
   
Add DRB with 5QI2
    [Arguments]    ${ue_id}=1    ${PDU}=1    ${qos}=5
    ${ret}    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${PDU} qosflows_to_add=${qos} by=amf    ${Add_5QI2_Release_Drx}
	
Remove DRB with 5QI2
    [Arguments]    ${ue_id}=1    ${PDU}=1    ${qos}=5
    ${ret}    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${PDU} qosflows_to_del=${qos} by=amf    ${Delete_5QI2_Setup_Drx}
	
Trigger RRC Reestablishment Successfully With New CG Config
    [Arguments]    ${ue_id}    ${cell_id}
    ${ret1}=    Execute Egate Command    ue_rrc_reestablish id=${ue_id} gnb=2 cell=${cell_id} cause=reconfigurationFailure
    ...    ${RRE_Success_With_New_CG_Config}    timeout=20s
    Wait Until Keyword Succeeds    5s    1s    Verify Traffic
	
Check No Traffic
    [Arguments]    ${ue_id}=1
    ${ul_throughput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pusch    rate_type=ave
    Should Be True    ${ul_throughput} == 0
	
UE Deregister From gNB
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s
	
Check Counters Should Be Correct
    Check Counters    ${PM_Counters_Check_HA018}
