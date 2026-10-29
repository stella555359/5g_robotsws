*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    RAN_5G_TDD    SBTS00    team-Rock_SGT&A    owner-christine.chen
...    CLOUD_5G_I_BLLL_AP_LOO    CB007517-C    release-5G22R4
...    STATE_CONFIGURED    RAN_5G
Resource    ../../../../resources/DevHZ5_resource.robot


*** Variables ***
@{PARAMS_IN_SCF}
...    NRBTS-1:timerRRCGuard=6000
...    NRBTS-1:cipherPrefL:nea0=8
...    NRBTS-1:cipherPrefL:nea1_128=0
...    NRBTS-1:cipherPrefL:nea2_128=0
...    NRBTS-1:cipherPrefL:nea3_128=0
...    NRBTS-1:integrityProtPrefL:nia0=0
...    NRBTS-1:integrityProtPrefL:nia1_128=0
...    NRBTS-1:integrityProtPrefL:nia2_128=0
...    NRBTS-1:integrityProtPrefL:nia3_128=9
#...    NRBTS-1:actLteNrDss=false
...    @{HO_Config}
...    @{A4_Config}
...    @{Vonr_Config}
...    @{NRHOIF_Config}
...    @{NRREL_Config}
...    @{MFBI_activation}
...    @{NRPMQAP_config}
...    NRBTS-1/NRCELL-1:actCDrx=true
...    NRBTS-1/NRCELL-12:actCDrx=true
...    NRCELL-11:msg1FrequencyStart=9
...    NRCELL-12:msg1FrequencyStart=11
...    NRCELL-13:msg1FrequencyStart=11
...    NRCELL-14:msg1FrequencyStart=11

@{MFBI_activation}
...    NRBTS-1:actMultiFrequencyBandIndicatorNRSupport=true

@{Vonr_Config}
...    NRCELL-1:actVoNR=true
...    NRCELL-12:actVoNR=true
...    NRCELL-1:actCDrxVoNR=true
...    NRCELL-12:actCDrxVoNR=true
...    NRCELL-1:actEnhancedVoNR=true
...    NRCELL-12:actEnhancedVoNR=true
...    NRCELL-12:actGBRAdmissionControl=EnhancedVoNR
...    NRCELL-1:actVoNrMobilityThresholds=VoNrMobilityThresholds
...    NRCELL-12:actVoNrMobilityThresholds=VoNrMobilityThresholds
...    NRDRB-15:maxRlcQueueingDelayGbr=20
...    NRDRB-15:queuingDelayDiscarding=Disabled
...    NRDRB-15:cellAggrLevel=Not FR1 CA eligible
...    NRDRB-15:discardTimer=300ms
...    NRDRB-15:dlFlowControlAlgo=none
...    NRDRB-15:maxTransferDelayGbr=20
...    NRDRB-15:dscp=0
...    NRDRB-15:durationThresDiscardDl=50
...    NRDRB-15:durationThresDiscardUl=50
...    NRDRB-15:actDddsReduction=false
...    NRDRB-15:actLostPduFastRetx=false
...    NRDRB-15:maxDddsPeriodCpuOvld=40
...    NRDRB-15:maxDataRateGbrDl=1000
...    NRDRB-15:maxDataRateGbrUl=1000
...    NRDRB-15:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-3
...    NRDRB-15:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-2
...    NRDRB-15:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRDRB-15:nrDrxDN=MRBTS-1/NRBTS-1/NRDRX-2
...    NRDRB-15:numSduDiscard=1
...    NRDRB-15:queuingDelaySduDiscardThreshold=200
...    NRDRB-15:resType=GBR
...    NRDRB-15:rlcMode=RLC_UM
...    NRDRB-15:schedulWeight=1
...    NRDRB-15:sduDiscardIntervalTmr=100
...    NRDRB-15:volThresDiscardDl=100
...    NRDRB-15:volThresDiscardUl=100
...    NRDRB_5QI-6:fiveqiValueList=1
...    NRDRB_5QI-6:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-15
...    NRDRB_MAC-3:lcgid=4
...    NRDRB_MAC-3:prioritisedBitRate=16kBps
...    NRDRB_MAC-3:schedulPrio=5
...    NRDRB_MAC-3:schedulBSD=50ms
...    NRDRB_PDCP-2:pdcpBufDiscardEnabled=false
...    NRDRB_RLC_UM-1:dlTReassemblyUm=ms40
...    NRDRB_RLC_UM-1:rlcUMDrbSNLength=rlcUm12bitSN
...    NRDRB_RLC_UM-1:ulTReassemblyUm=ms40

@{NRPMQAP_config}
...    NRBTS-1:actNrpmqapProfiles=true
...    NRBTS-1/NRPMRNL-1/NRPMQAP-1:cfg5qiRange=6-9
...    NRBTS-1/NRPMRNL-1/NRPMQAP-1:cfgPlmnId:mcc=311
...    NRBTS-1/NRPMRNL-1/NRPMQAP-1:cfgPlmnId:mnc=490
...    NRBTS-1/NRPMRNL-1/NRPMQAP-1:cfgPlmnId:mncLength=3
...    NRBTS-1/NRPMRNL-1/NRPMQAP-1:cfgProfType=SA
...    NRBTS-1/NRPMRNL-1/NRPMQAP-1:nrPmqapId=1
...    NRBTS-1/NRPMRNL-1/NRPMQAP-2:cfg5qiRange=6-9
...    NRBTS-1/NRPMRNL-1/NRPMQAP-2:cfgPlmnId:mcc=311
...    NRBTS-1/NRPMRNL-1/NRPMQAP-2:cfgPlmnId:mnc=489
...    NRBTS-1/NRPMRNL-1/NRPMQAP-2:cfgPlmnId:mncLength=3
...    NRBTS-1/NRPMRNL-1/NRPMQAP-2:cfgSliceId:sd=13714341
...    NRBTS-1/NRPMRNL-1/NRPMQAP-2:cfgSliceId:sst=1
...    NRBTS-1/NRPMRNL-1/NRPMQAP-2:cfgArpRange=15
...    NRBTS-1/NRPMRNL-1/NRPMQAP-2:cfgProfType=both
...    NRBTS-1/NRPMRNL-1/NRPMQAP-2:nrPmqapId=2
...    NRBTS-1/NRPMRNL-1/NRPMQAP-3:cfg5qiRange=1
...    NRBTS-1/NRPMRNL-1/NRPMQAP-3:cfgPlmnId:mcc=311
...    NRBTS-1/NRPMRNL-1/NRPMQAP-3:cfgPlmnId:mnc=489
...    NRBTS-1/NRPMRNL-1/NRPMQAP-3:cfgPlmnId:mncLength=3
...    NRBTS-1/NRPMRNL-1/NRPMQAP-3:cfgProfType=both
...    NRBTS-1/NRPMRNL-1/NRPMQAP-3:nrPmqapId=3
...    NRBTS-1/NRPMRNL-1/NRPMQAP-11:cfg5qiRange=5
...    NRBTS-1/NRPMRNL-1/NRPMQAP-11:cfgPlmnId:mcc=311
...    NRBTS-1/NRPMRNL-1/NRPMQAP-11:cfgPlmnId:mnc=489
...    NRBTS-1/NRPMRNL-1/NRPMQAP-11:cfgPlmnId:mncLength=3
...    NRBTS-1/NRPMRNL-1/NRPMQAP-11:cfgProfType=both
...    NRBTS-1/NRPMRNL-1/NRPMQAP-11:nrPmqapId=11
#...    NRBTS-1/NRPMRNL-1/NRPMQAP-4:cfg5qiRange=5
...    NRBTS-1/NRPMRNL-1/NRPMQAP-4:cfgPlmnId:mcc=311
...    NRBTS-1/NRPMRNL-1/NRPMQAP-4:cfgPlmnId:mnc=489
...    NRBTS-1/NRPMRNL-1/NRPMQAP-4:cfgPlmnId:mncLength=3
...    NRBTS-1/NRPMRNL-1/NRPMQAP-4:cfgProfType=NSA
...    NRBTS-1/NRPMRNL-1/NRPMQAP-4:nrPmqapId=4
...    NRBTS-1/NRPMRNL-1/NRPMQAP-12:cfgProfType=both
...    NRBTS-1/NRPMRNL-1/NRPMQAP-12:nrPmqapId=12
...    NRBTS-1/NRPMRNL-1/NRPMQAP-20:cfg5qiRange=6-9
...    NRBTS-1/NRPMRNL-1/NRPMQAP-20:cfgPlmnId:mcc=311
...    NRBTS-1/NRPMRNL-1/NRPMQAP-20:cfgPlmnId:mnc=489
...    NRBTS-1/NRPMRNL-1/NRPMQAP-20:cfgPlmnId:mncLength=3
...    NRBTS-1/NRPMRNL-1/NRPMQAP-20:cfgSliceId:sd=13714341
...    NRBTS-1/NRPMRNL-1/NRPMQAP-20:cfgSliceId:sst=1
...    NRBTS-1/NRPMRNL-1/NRPMQAP-20:cfgArpRange=10
...    NRBTS-1/NRPMRNL-1/NRPMQAP-20:cfgProfType=SA
...    NRBTS-1/NRPMRNL-1/NRPMQAP-20:nrPmqapId=20
...    NRBTS-1/NRPMRNL-1/NRPMQAP-10:cfg5qiRange=6-9
...    NRBTS-1/NRPMRNL-1/NRPMQAP-10:cfgPlmnId:mcc=311
...    NRBTS-1/NRPMRNL-1/NRPMQAP-10:cfgPlmnId:mnc=489
...    NRBTS-1/NRPMRNL-1/NRPMQAP-10:cfgPlmnId:mncLength=3
...    NRBTS-1/NRPMRNL-1/NRPMQAP-10:cfgSliceId:sd=13714340
...    NRBTS-1/NRPMRNL-1/NRPMQAP-10:cfgSliceId:sst=1
...    NRBTS-1/NRPMRNL-1/NRPMQAP-10:cfgProfType=SA
...    NRBTS-1/NRPMRNL-1/NRPMQAP-10:nrPmqapId=10

@{HO_Config}
...    NRBTS-1:actIntraFreqHoSA=true
...    NRBTS-1:actInterFreqHoSA=true
...    NRBTS-1:actInterFreqInterGnbMobilityNSA=true
...    NRBTS-1:actInterFreqIntraGnbMobilityNSA=true
...    NRBTS-1:actHigherPrioFreqHo=SA
...    NRBTS-1:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS/NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRBTS/NRDU-1:actInterNumerologyCa=true
...    NRBTS/NRDU-1:actConnectedModeMobilityCA=true
...    NRBTS/NRDU-1:carrierAggregationSupportList=${CA_support_list}
...    NRBTS-1/NRPMRNL-1:miNrRelReportCu=15min
...    NRCELL:actK1Opt=intra-gNB
#...    NRCELL-2:actK1Opt=intra-gNB
...    NRREL-2:sCellOperationalMode=dlOnly

@{A4_Config}
...    NRCELL-1:a4PeriodicMeasControlSA:a4Fr1SupervisionTimer=9000
...    NRCELL-1:a4PeriodicMeasControlSA:a4Fr2SupervisionTimer=9000
...    NRCELL-1:a4PeriodicMeasControlSA:a4MeasMaxNumber=8
...    NRCELL-1:a4PeriodicMeasControlSA:a4RetryTimer=10
...    NRCELL-2:a4PeriodicMeasControlSA:a4Fr1SupervisionTimer=6000
...    NRCELL-2:a4PeriodicMeasControlSA:a4Fr2SupervisionTimer=6000
...    NRCELL-2:a4PeriodicMeasControlSA:a4MeasMaxNumber=8
...    NRCELL-2:a4PeriodicMeasControlSA:a4RetryTimer=6
...    NRCELL-11:a4PeriodicMeasControlSA:a4Fr1SupervisionTimer=6000
...    NRCELL-11:a4PeriodicMeasControlSA:a4Fr2SupervisionTimer=6000
...    NRCELL-11:a4PeriodicMeasControlSA:a4MeasMaxNumber=8
...    NRCELL-11:a4PeriodicMeasControlSA:a4RetryTimer=7
...    NRCELL-12:a4PeriodicMeasControlSA:a4Fr1SupervisionTimer=5000
...    NRCELL-12:a4PeriodicMeasControlSA:a4Fr2SupervisionTimer=5000
...    NRCELL-12:a4PeriodicMeasControlSA:a4MeasMaxNumber=8
...    NRCELL-12:a4PeriodicMeasControlSA:a4RetryTimer=2
...    NRCELL-13:a4PeriodicMeasControlSA:a4Fr1SupervisionTimer=6000
...    NRCELL-13:a4PeriodicMeasControlSA:a4Fr2SupervisionTimer=6000
...    NRCELL-13:a4PeriodicMeasControlSA:a4MeasMaxNumber=8
...    NRCELL-13:a4PeriodicMeasControlSA:a4RetryTimer=9
...    NRCELL-14:a4PeriodicMeasControlSA:a4Fr1SupervisionTimer=6000
...    NRCELL-14:a4PeriodicMeasControlSA:a4Fr2SupervisionTimer=6000
...    NRCELL-14:a4PeriodicMeasControlSA:a4MeasMaxNumber=8
...    NRCELL-14:a4PeriodicMeasControlSA:a4RetryTimer=10
...    NRCELL-1:a4PeriodicMeasControlNSA:a4Fr1SupervisionTimer=6000
...    NRCELL-1:a4PeriodicMeasControlNSA:a4Fr2SupervisionTimer=6000
...    NRCELL-1:a4PeriodicMeasControlNSA:a4MeasMaxNumber=8
...    NRCELL-1:a4PeriodicMeasControlNSA:a4RetryTimer=20
...    NRCELL-2:a4PeriodicMeasControlNSA:a4Fr1SupervisionTimer=6000
...    NRCELL-2:a4PeriodicMeasControlNSA:a4Fr2SupervisionTimer=6000
...    NRCELL-2:a4PeriodicMeasControlNSA:a4MeasMaxNumber=8
...    NRCELL-2:a4PeriodicMeasControlNSA:a4RetryTimer=20
...    NRCELL-11:a4PeriodicMeasControlNSA:a4Fr1SupervisionTimer=6000
...    NRCELL-11:a4PeriodicMeasControlNSA:a4Fr2SupervisionTimer=6000
...    NRCELL-11:a4PeriodicMeasControlNSA:a4MeasMaxNumber=3
...    NRCELL-11:a4PeriodicMeasControlNSA:a4RetryTimer=20
...    NRCELL-12:a4PeriodicMeasControlNSA:a4Fr1SupervisionTimer=10000
...    NRCELL-12:a4PeriodicMeasControlNSA:a4Fr2SupervisionTimer=10000
...    NRCELL-12:a4PeriodicMeasControlNSA:a4MeasMaxNumber=3
...    NRCELL-12:a4PeriodicMeasControlNSA:a4RetryTimer=20
...    NRCELL-13:a4PeriodicMeasControlNSA:a4Fr1SupervisionTimer=6000
...    NRCELL-13:a4PeriodicMeasControlNSA:a4Fr2SupervisionTimer=6000
...    NRCELL-13:a4PeriodicMeasControlNSA:a4MeasMaxNumber=3
...    NRCELL-13:a4PeriodicMeasControlNSA:a4RetryTimer=20
...    NRCELL-14:a4PeriodicMeasControlNSA:a4Fr1SupervisionTimer=6000
...    NRCELL-14:a4PeriodicMeasControlNSA:a4Fr2SupervisionTimer=6000
...    NRCELL-14:a4PeriodicMeasControlNSA:a4MeasMaxNumber=3
...    NRCELL-14:a4PeriodicMeasControlNSA:a4RetryTimer=20

@{NRHOIF_Config}
...    NRCELL-1/NRHOIF-1:cellDepType=SA
...    NRCELL-1/NRHOIF-1:freqBandIndicatorNR=66
...    NRCELL-1/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf2
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-1/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-1:ssbFrequency=424090
...    NRCELL-1/NRHOIF-1:a4MeasHigherPrioFreqEnabled=rsrp
...    NRCELL-1/NRHOIF-1:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-1/NRHOIF-1:a4MeasSsbRsrp:a4ThresholdSsbRsrp=34
...    NRCELL-1/NRHOIF-1:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms40
...    NRCELL-1/NRHOIF-1:a4MeasSsbRsrq:a4HysteresisSsbRsrq=0
...    NRCELL-1/NRHOIF-1:a4MeasSsbRsrq:a4ThresholdSsbRsrq=49
...    NRCELL-1/NRHOIF-1:a4MeasSsbRsrq:a4TimeToTriggerSsbRsrq=ms40
...    NRCELL-1/NRHOIF-1:a4PriorityForHigherPrioFreqHo=2
...    NRCELL-1/NRHOIF-2:cellDepType=SA
...    NRCELL-1/NRHOIF-2:freqBandIndicatorNR=71
...    NRCELL-1/NRHOIF-2:ifhoSsbScs=15KHz
...    NRCELL-1/NRHOIF-2:ifhoSsbSmtcDuration=sf2
...    NRCELL-1/NRHOIF-2:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-2:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-1/NRHOIF-2:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-2:ssbFrequency=126750
...    NRCELL-1/NRHOIF-2:a4MeasHigherPrioFreqEnabled=rsrp
...    NRCELL-1/NRHOIF-2:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-1/NRHOIF-2:a4MeasSsbRsrp:a4ThresholdSsbRsrp=45
...    NRCELL-1/NRHOIF-2:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms40
...    NRCELL-1/NRHOIF-2:a4PriorityForHigherPrioFreqHo=1
...    NRCELL-1/NRHOIF-3:cellDepType=SA
...    NRCELL-1/NRHOIF-3:freqBandIndicatorNR=78
...    NRCELL-1/NRHOIF-3:ifhoSsbScs=30 KHz
...    NRCELL-1/NRHOIF-3:ifhoSsbSmtcDuration=sf2
...    NRCELL-1/NRHOIF-3:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-3:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-1/NRHOIF-3:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-3:ssbFrequency=633216
...    NRCELL-1/NRHOIF-3:a4MeasHigherPrioFreqEnabled=rsrqCombined
...    NRCELL-1/NRHOIF-3:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-1/NRHOIF-3:a4MeasSsbRsrp:a4ThresholdSsbRsrp=15
...    NRCELL-1/NRHOIF-3:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms0
...    NRCELL-1/NRHOIF-3:a4MeasSsbRsrq:a4HysteresisSsbRsrq=0
...    NRCELL-1/NRHOIF-3:a4MeasSsbRsrq:a4ThresholdSsbRsrq=20
...    NRCELL-1/NRHOIF-3:a4MeasSsbRsrq:a4TimeToTriggerSsbRsrq=ms40
...    NRCELL-1/NRHOIF-3:a4PriorityForHigherPrioFreqHo=3
...    NRCELL-1/NRHOIF-4:cellDepType=SA
...    NRCELL-1/NRHOIF-4:freqBandIndicatorNR=66
...    NRCELL-1/NRHOIF-4:ifhoSsbScs=15KHz
...    NRCELL-1/NRHOIF-4:ifhoSsbSmtcDuration=sf2
...    NRCELL-1/NRHOIF-4:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-4:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-1/NRHOIF-4:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-4:ssbFrequency=427970
...    NRCELL-1/NRHOIF-4:a4MeasHigherPrioFreqEnabled=rsrp
...    NRCELL-1/NRHOIF-4:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-1/NRHOIF-4:a4MeasSsbRsrp:a4ThresholdSsbRsrp=20
...    NRCELL-1/NRHOIF-4:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms0
...    NRCELL-1/NRHOIF-4:a4PriorityForHigherPrioFreqHo=4
...    NRCELL-1/NRHOIF-5:cellDepType=SA
...    NRCELL-1/NRHOIF-5:freqBandIndicatorNR=257
...    NRCELL-1/NRHOIF-5:ifhoSsbScs=120 KHz
...    NRCELL-1/NRHOIF-5:ifhoSsbSmtcDuration=sf1
...    NRCELL-1/NRHOIF-5:ifhoSsbSmtcPeriodicity=sf5
...    NRCELL-1/NRHOIF-5:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-1/NRHOIF-5:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-5:ssbFrequency=2079163
...    NRCELL-1/NRHOIF-5:a4MeasHigherPrioFreqEnabled=rsrp
...    NRCELL-1/NRHOIF-5:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-1/NRHOIF-5:a4MeasSsbRsrp:a4ThresholdSsbRsrp=20
...    NRCELL-1/NRHOIF-5:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms0
...    NRCELL-1/NRHOIF-5:a4PriorityForHigherPrioFreqHo=5
...    NRCELL-1/NRHOIF-6:cellDepType=SA
...    NRCELL-1/NRHOIF-6:freqBandIndicatorNR=257
...    NRCELL-1/NRHOIF-6:ifhoSsbScs=120 KHz
...    NRCELL-1/NRHOIF-6:ifhoSsbSmtcDuration=sf2
...    NRCELL-1/NRHOIF-6:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-6:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-1/NRHOIF-6:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-6:ssbFrequency=2071675
...    NRCELL-1/NRHOIF-6:a4MeasHigherPrioFreqEnabled=rsrp
...    NRCELL-1/NRHOIF-6:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-1/NRHOIF-6:a4MeasSsbRsrp:a4ThresholdSsbRsrp=15
...    NRCELL-1/NRHOIF-6:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms40
...    NRCELL-1/NRHOIF-6:a4PriorityForHigherPrioFreqHo=6
...    NRCELL-1/NRHOIF-7:cellDepType=SA
...    NRCELL-1/NRHOIF-7:freqBandIndicatorNR=41
...    NRCELL-1/NRHOIF-7:ifhoSsbScs=30 KHz
...    NRCELL-1/NRHOIF-7:ifhoSsbSmtcDuration=sf2
...    NRCELL-1/NRHOIF-7:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-7:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-1/NRHOIF-7:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-7:ssbFrequency=513150
...    NRCELL-1/NRHOIF-7:a4MeasHigherPrioFreqEnabled=rsrp
...    NRCELL-1/NRHOIF-7:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-1/NRHOIF-7:a4MeasSsbRsrp:a4ThresholdSsbRsrp=20
...    NRCELL-1/NRHOIF-7:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms0
...    NRCELL-1/NRHOIF-7:a4PriorityForHigherPrioFreqHo=7
...    NRCELL-12/NRHOIF-1:cellDepType=SA
...    NRCELL-12/NRHOIF-1:freqBandIndicatorNR=41
...    NRCELL-12/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-12/NRHOIF-1:ifhoSsbSmtcDuration=sf2
...    NRCELL-12/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-12/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-12/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-12/NRHOIF-1:ssbFrequency=518910
...    NRCELL-12/NRHOIF-1:a4MeasHigherPrioFreqEnabled=rsrp
...    NRCELL-12/NRHOIF-1:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-12/NRHOIF-1:a4MeasSsbRsrp:a4ThresholdSsbRsrp=34
...    NRCELL-12/NRHOIF-1:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms40
...    NRCELL-12/NRHOIF-1:a4MeasSsbRsrq:a4HysteresisSsbRsrq=0
...    NRCELL-12/NRHOIF-1:a4MeasSsbRsrq:a4ThresholdSsbRsrq=49
...    NRCELL-12/NRHOIF-1:a4MeasSsbRsrq:a4TimeToTriggerSsbRsrq=ms40
...    NRCELL-12/NRHOIF-1:a4PriorityForHigherPrioFreqHo=2

@{NRREL_Config}
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-1:gNbId=1
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-1:removeNotAllowed=false
...    NRCELL-1/NRREL-1:lcrId=12
...    NRCELL-1/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-10:gNbId=1
...    NRCELL-1/NRREL-10:gNbIdLength=22
...    NRCELL-1/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-10:removeNotAllowed=false
...    NRCELL-1/NRREL-10:lcrId=11
...    NRCELL-12/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-10:gNbId=1
...    NRCELL-12/NRREL-10:gNbIdLength=22
...    NRCELL-12/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-10:removeNotAllowed=false
...    NRCELL-12/NRREL-10:lcrId=1
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-2:gNbId=1
...    NRCELL-1/NRREL-2:gNbIdLength=22
...    NRCELL-1/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-2:removeNotAllowed=false
...    NRCELL-1/NRREL-2:lcrId=2
...    NRCELL-1/NRREL-2:sCellAdditionMethod=blind
${CA_support_list}    ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Any_Sa

@{OnlineParam_C050}
...    NRCELL-11:msg1FrequencyStart=9
...    NRCELL-12:msg1FrequencyStart=11
...    NRCELL-13:msg1FrequencyStart=11
...    NRCELL-14:msg1FrequencyStart=11
...    NRCELL-1:a2MeashoEnabledSA=rsrp
...    NRCELL-1:a1MeashoEnabledSA=rsrp
...    @{MFBI_NRCONNECTEDMODE_Profile}
...    @{MFBI_NRNSPMAX_Profile}
...    @{MFBI_NRMULTIBANDINFO_PROFILE}
...    @{MFBI_NRCELL2}
...    @{MFBI_NRHOIF-3}
...    @{InterF_A3_Enable_Band257}
...    @{NRCELL-2_A4config_NRHOIF}
...    delete:NRBTS-1/NRCELL-1/NRREL-2:sCellAdditionMethod
...    NRCELL-1:a4PeriodicMeasControlSA:a4Fr1SupervisionTimer=10000
...    NRCELL-1:a4PeriodicMeasControlSA:a4Fr2SupervisionTimer=10000
...    NRCELL-1:a4PeriodicMeasControlSA:a4MeasMaxNumber=3
...    NRCELL-1:a4PeriodicMeasControlSA:a4RetryTimer=30
...    NRBTS/NRDU-1:carrierAggregationSupportList=${CA_support_list_none}

${CA_support_list_none}    none

@{MFBI_NRCONNECTEDMODE_Profile}
...    MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-0:multiFreqBandIndicatorNR=77
@{MFBI_NRNSPMAX_Profile}
...    MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1:nrNsPmaxList:additionalPmax=1
...    MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1:nrNsPmaxList:additionalSpectrumEmission=1
...    MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1:nrNsPmaxList:nrNsPmaxPriority=1
@{MFBI_NRMULTIBANDINFO_PROFILE}
...    MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-1:nrMultibandInfoList:nrBandPriority=1|freqBandIndicatorNR=77
...    MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-1:nrMultibandInfoList:nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1|freqBandIndicatorNR=77
...    MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-1:nrMultibandInfoList:nrBandPriority=2|freqBandIndicatorNR=78
...    MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-1:nrMultibandInfoList:nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1|freqBandIndicatorNR=78
@{MFBI_NRCELL2}
...    NRCELL-2:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-0
...    NRCELL-2:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-1
@{MFBI_NRHOIF-3}
...    NRCELL-1/NRHOIF-3:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-0
...    NRCELL-1/NRHOIF-3:a4PriorityForHigherPrioFreqHo=1
...    NRCELL-1/NRHOIF-3:a4MeasHigherPrioFreqEnabled=rsrp
@{InterF_A3_Enable_Band257}
...    NRCELL-1/NRHOIF-5:a3MeasEnabled=rsrp
...    NRCELL-1/NRHOIF-5:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-1/NRHOIF-5:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL-1/NRHOIF-5:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
@{NRCELL-2_A4config_NRHOIF}
...    NRCELL-2:a4PeriodicMeasControlSA:a4Fr1SupervisionTimer=10000
...    NRCELL-2:a4PeriodicMeasControlSA:a4Fr2SupervisionTimer=10000
...    NRCELL-2:a4PeriodicMeasControlSA:a4MeasMaxNumber=8
...    NRCELL-2:a4PeriodicMeasControlSA:a4RetryTimer=30
...    NRCELL-2/NRHOIF-3:cellDepType=SA
...    NRCELL-2/NRHOIF-3:freqBandIndicatorNR=41
...    NRCELL-2/NRHOIF-3:ifhoSsbScs=30 KHz
...    NRCELL-2/NRHOIF-3:ifhoSsbSmtcDuration=sf2
...    NRCELL-2/NRHOIF-3:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-2/NRHOIF-3:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-2/NRHOIF-3:ssBurstSetPeriod=20
...    NRCELL-2/NRHOIF-3:ssbFrequency=518910
...    NRCELL-2/NRHOIF-3:a4MeasHigherPrioFreqEnabled=rsrp
...    NRCELL-2/NRHOIF-3:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-2/NRHOIF-3:a4MeasSsbRsrp:a4ThresholdSsbRsrp=15
...    NRCELL-2/NRHOIF-3:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms0
...    NRCELL-2/NRHOIF-3:a4MeasSsbRsrq:a4HysteresisSsbRsrq=0
...    NRCELL-2/NRHOIF-3:a4MeasSsbRsrq:a4ThresholdSsbRsrq=20
...    NRCELL-2/NRHOIF-3:a4MeasSsbRsrq:a4TimeToTriggerSsbRsrq=ms40
...    NRCELL-2/NRHOIF-3:a4PriorityForHigherPrioFreqHo=3
...    NRCELL-2/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-2:gNbId=1
...    NRCELL-2/NRREL-2:gNbIdLength=22
...    NRCELL-2/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-2:removeNotAllowed=false
...    NRCELL-2/NRREL-2:lcrId=1

@{OnlineParam_C050_recover}
...    NRBTS-1/NRCELL-1/NRREL-2:sCellAdditionMethod=blind
...    NRBTS/NRDU-1:carrierAggregationSupportList=${CA_support_list}
...    NRCELL-1:a4PeriodicMeasControlSA:a4Fr1SupervisionTimer=9000
...    NRCELL-1:a4PeriodicMeasControlSA:a4Fr2SupervisionTimer=9000
...    NRCELL-1:a4PeriodicMeasControlSA:a4MeasMaxNumber=8
...    NRCELL-1:a4PeriodicMeasControlSA:a4RetryTimer=10
...    NRCELL-1/NRHOIF-3:a4PriorityForHigherPrioFreqHo=3
...    NRCELL-1/NRHOIF-3:a4MeasHigherPrioFreqEnabled=rsrqCombined
...    delete:NRCELL-1/NRHOIF-3:nrConnectModeProfileDN
...    delete:NRCELL-2/NRHOIF-3
...    delete:NRCELL-2/NRREL-2
...    NRCELL-1/NRHOIF-5:a3MeasEnabled=none
...    delete:MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-0
...    delete:MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1
...    delete:MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-1
...    delete:NRCELL-2:nrConnectModeProfileDN
...    delete:NRCELL-2:nrMultibandInfoProfileDN



${SA_Capa_not_Support_n41+n78_independent}    SEPARATOR=
...    E9A09000575F5A13160003C0A02C1262E003387A0609B20C39F30C7942C0E098040623807DC6C28C0D608C21A0810748046D6C98AB1A1CF8
...    8E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE0003801C0A83620EB04610D04083C40232B64C55890E7D813E238F1
...    891C790E7D473E618F28581C0E1E13FB000000FEC0000003801C0AA3626EB04610D04083A40230B64C55110E7C471E238F40CFB027C639F
...    30C7942C0E070F05C00FFC007003FF0001C00E0541B11B582308682041E201195B262AC4873E238F604F8C48E3C873EA39F30C7942C0E07
...    0F09FFF000007FFC000001C00E0063C3C4D000E208000010B0102A0F0A000388C0000042C0AC3C46000E208000030B02B0F0A0003882000
...    0042C0AC3C4D000E230000010B02B17118003882001C4100000A160562E26800711800388C0000082C0AC5C28000E208007118000010581
...    58B850001C41000E208000020B02B17134003882001C46000004160562E14000711800388C0000082C0AC3C46000E230000030B0200E023
...    4028809B0104154A83214489B1CF870A244D8E7C3851226C73E1C28913639F0E14489B1CF871224489B1CF871204081B1CF811204081B1C
...    F811204081B1CF811204081B1CF811204081B1CF810A040D8E7C009860C6318C6318C6318F40B00F000E070300E0600A80E000C0480080C0
...    7C120040000000200000401000000008000010040000100200000C010000080080000500400200802008000060040000380200100000004
...    00004002000024010000060080000A004000058020010240900400006019CA9ACA9AC14AC0CAC19AC15ACA5AC99AC05AC0DAC04AC08AC1DA
...    0682000012CA4A080000CB29282000052CA48080001CB29202000092CA48080002CB292020000D2CA48080003CB29202000112CA48080004
...    CB29202000152CA48080005CB29282000192CA480800018B292019A55574AAAA9545D2A8AA0B154162A83455298AA4D154062A8145526AAA
...    0F14045E02540A05028140A05028140A05028140A05028140A05000608080600C02004008404008020100C018402004008080600C0201803
...    0404030060100C018402004008080600C02004008804030060100C018040300608080100402004010D50F800081018203038505860688088
...    9098A0C0C8D8E0E8F909293139414951697A0A0C168

${SA_Capa_MFBI_n41+n77+n257}    SEPARATOR=
...    E9A09000575F5A13160003C2A002C1262E003387A0E026C830E7CC31E50B03826010188E02771B0A303582308682041D207036B64C558D0E7
...    C471E819F604F8C48E3C873EA39F30C7942C0E070F05C00FFC0070005F0003C000E0541B107582308682041E207032B64C55890E7D813E238
...    F1891C790E7D473E618F28581C0E1E13FB000000FEC00000078001C0AA36266B04610D04083A40E0616C98AA221CF88E3C471E819F604F8C7
...    3E618F28581C0E1E0B801FF800E007FE00078001C0A836236B04610D04083C40E0656C98AB121CF88E3D813E31238F21CFA8E7CC31E50B038
...    1C3C27FFC00001FFF000000F000381502D00DE38C21A002A3CFC507022F6CC554800F1E00438820C22A051FBF9025F7874001800F78789800
...    1C4100000216020541E14000711800000858158788C001C41000006160561E140007104000008581587898001C46000002160562E23000710
...    40038820000142C0AC3C28000E260000060B02B17130003882001C28000008160562E26000711800388C0000082C0AC5C28000E2080071180
...    0001058158B850001C41000E208000020B02B17130003882001C46000004160562E14000711800388C0000082C0AC5C4C000E2300070A0000
...    020001183A0000001C1009011A014404C808304002D0B907C28913639F0E14489B1CF870A244D8E7C3851226C73E1C28913639F0E24489136
...    39F0E14081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF810206C7
...    3E00170F18C6318C6318C6318C61E8260078007838280381804A00E000C0480080C07C1200400000002000004010000000080000100400001
...    00200000C01000008008000050040020080200800006004000038020010000000400004002000024010000060080000A00400005802001024
...    0900400006019CA9ACA9AC14AC0CAC19AC15ACA5AC99AC05AC0DAC04AC08AC1DA0682000012CA4A080000CB29282000052CA48080001CB292
...    02000092CA48080002CB292020000D2CA48080003CB29202000112CA48080004CB29202000152CA48080005CB29282000192CA480800018B2
...    92019A55574AAAA9545D2A8AA0B154162A83455298AA4D154062A8145526AAA0F142405E02540A05028140A05028140A05028140A05028140
...    A05000708080600C02004008404008020100C018402004008080600C02018030404030060100C018402004008080600C02004008804030060
...    100C018040300608080100402004010004008021AA1F000102030406070A0B0C0D101112131418191B1C1D1F2125262728292A2D2F414182D
...    0
${ue_id}    81
${pdu_id}    1
${gw_id}    1
${nwslice}    1
${BTS_STARTUP_RETRY}    4
${F518910}    518910
${F633216}    633216
${F424090}    424090
${F427970}    427970


${GNB_BIP_FLAG}    True

@{PM_Counters_Check_C007}
...    NRCELL-1/PLMN-PLMN/NRPMQAP-2:SMAGP:${A4_IEF_IADU_HO_EX_ATT_SA}=1
...    NRCELL-1/PLMN-PLMN/NRPMQAP-2:SMAGP:${A4_IEF_IADU_HO_EX_SUC_SA}=1
...    NRCELL-1/PLMN-PLMN/NRPMQAP-3:SMAGP:${A4_IEF_IADU_HO_EX_ATT_SA}=1
...    NRCELL-1/PLMN-PLMN/NRPMQAP-3:SMAGP:${A4_IEF_IADU_HO_EX_SUC_SA}=1
...    NRCELL-1/PLMN-PLMN/NRPMQAP-11:SMAGP:${A4_IEF_IADU_HO_EX_ATT_SA}=1
...    NRCELL-1/PLMN-PLMN/NRPMQAP-11:SMAGP:${A4_IEF_IADU_HO_EX_SUC_SA}=1
...    NRCELL-1/PLMN-PLMN/NRPMQAP-12:SMAGP:${A4_IEF_IADU_HO_EX_ATT_SA}=1
...    NRCELL-1/PLMN-PLMN/NRPMQAP-12:SMAGP:${A4_IEF_IADU_HO_EX_SUC_SA}=1
...    NRCELL-1/PLMN-PLMN/NRPMQAP-1:SMAGP:${A4_IEF_IADU_HO_EX_ATT_SA}=0
...    NRCELL-1/PLMN-PLMN/NRPMQAP-1:SMAGP:${A4_IEF_IADU_HO_EX_SUC_SA}=0
...    NRCELL-1/PLMN-PLMN/NRPMQAP-4:SMAGP:${A4_IEF_IADU_HO_EX_ATT_SA}=0
...    NRCELL-1/PLMN-PLMN/NRPMQAP-4:SMAGP:${A4_IEF_IADU_HO_EX_SUC_SA}=0
...    NRCELL-1/PLMN-PLMN/NRPMQAP-20:SMAGP:${A4_IEF_IADU_HO_EX_ATT_SA}=0
...    NRCELL-1/PLMN-PLMN/NRPMQAP-20:SMAGP:${A4_IEF_IADU_HO_EX_SUC_SA}=0
...    NRCELL-1/PLMN-PLMN/NRPMQAP-10:SMAGP:${A4_IEF_IADU_HO_EX_ATT_SA}=0
...    NRCELL-1/PLMN-PLMN/NRPMQAP-10:SMAGP:${A4_IEF_IADU_HO_EX_SUC_SA}=0
...    NRCELL-1:NRANS:${ATT_IF_INTRA_DU_HO_SA_PLMN}=1
...    NRCELL-1:NRANS:${SUCC_IF_INTRA_DU_HO_SA_PLMN}=1
...    NRCELL-12/PLMN-PLMN/NRPMQAP-2:SMAGP:${A4_IEF_IADU_HO_EX_ATT_SA}=1
...    NRCELL-12/PLMN-PLMN/NRPMQAP-2:SMAGP:${A4_IEF_IADU_HO_EX_SUC_SA}=1
...    NRCELL-12/PLMN-PLMN/NRPMQAP-3:SMAGP:${A4_IEF_IADU_HO_EX_ATT_SA}=1
...    NRCELL-12/PLMN-PLMN/NRPMQAP-3:SMAGP:${A4_IEF_IADU_HO_EX_SUC_SA}=1
...    NRCELL-12/PLMN-PLMN/NRPMQAP-11:SMAGP:${A4_IEF_IADU_HO_EX_ATT_SA}=1
...    NRCELL-12/PLMN-PLMN/NRPMQAP-11:SMAGP:${A4_IEF_IADU_HO_EX_SUC_SA}=1
...    NRCELL-12/PLMN-PLMN/NRPMQAP-12:SMAGP:${A4_IEF_IADU_HO_EX_ATT_SA}=1
...    NRCELL-12/PLMN-PLMN/NRPMQAP-12:SMAGP:${A4_IEF_IADU_HO_EX_SUC_SA}=1
...    NRCELL-12/PLMN-PLMN/NRPMQAP-1:SMAGP:${A4_IEF_IADU_HO_EX_ATT_SA}=0
...    NRCELL-12/PLMN-PLMN/NRPMQAP-1:SMAGP:${A4_IEF_IADU_HO_EX_SUC_SA}=0
...    NRCELL-12/PLMN-PLMN/NRPMQAP-4:SMAGP:${A4_IEF_IADU_HO_EX_ATT_SA}=0
...    NRCELL-12/PLMN-PLMN/NRPMQAP-4:SMAGP:${A4_IEF_IADU_HO_EX_SUC_SA}=0
...    NRCELL-12/PLMN-PLMN/NRPMQAP-20:SMAGP:${A4_IEF_IADU_HO_EX_ATT_SA}=0
...    NRCELL-12/PLMN-PLMN/NRPMQAP-20:SMAGP:${A4_IEF_IADU_HO_EX_SUC_SA}=0
...    NRCELL-12/PLMN-PLMN/NRPMQAP-10:SMAGP:${A4_IEF_IADU_HO_EX_ATT_SA}=0
...    NRCELL-12/PLMN-PLMN/NRPMQAP-10:SMAGP:${A4_IEF_IADU_HO_EX_SUC_SA}=0
...    NRCELL-12:NRANS:${ATT_IF_INTRA_DU_HO_SA_PLMN}=1
...    NRCELL-12:NRANS:${SUCC_IF_INTRA_DU_HO_SA_PLMN}=1

${A4_IEF_IADU_HO_EX_ATT_SA}    M55184C00003
#A4 trigg Execution attempts for inter-freq Intra-gNB Intra-DU HO for SA
${A4_IEF_IADU_HO_EX_SUC_SA}    M55184C00004
#A4 trigg Successful execution attempts for inter-freq Intra-gNB Intra-DU HO for SA
${ATT_IF_INTRA_DU_HO_SA_PLMN}    M55145C00321
#The number of inter-frequency intra-DU HO attempts for SA per PLMN-ID
${SUCC_IF_INTRA_DU_HO_SA_PLMN}    M55145C00322
#The number of successful inter-frequency intra-DU HOs for SA per PLMN-ID

@{PM_Counters_Check_C050}
...    NRCELL-1/PLMN-PLMN/NRPMQAP-2:SMAGP:${A4_IEF_IADU_HO_EX_ATT_SA}=1
...    NRCELL-2/PLMN-PLMN/NRPMQAP-2:SMAGP:${A4_IEF_IADU_HO_EX_ATT_SA}=1
...    NRCELL-1/PLMN-PLMN/NRPMQAP-2:SMAGP:${A4_IEF_IADU_HO_EX_SUC_SA}=1
...    NRCELL-2/PLMN-PLMN/NRPMQAP-2:SMAGP:${A4_IEF_IADU_HO_EX_SUC_SA}=1
...    NRCELL-1/PLMN-PLMN/NRPMQAP-12:SMAGP:${A4_IEF_IADU_HO_EX_ATT_SA}=1
...    NRCELL-1/PLMN-PLMN/NRPMQAP-12:SMAGP:${A4_IEF_IADU_HO_EX_SUC_SA}=1
...    NRCELL-2/PLMN-PLMN/NRPMQAP-12:SMAGP:${A4_IEF_IADU_HO_EX_ATT_SA}=1
...    NRCELL-2/PLMN-PLMN/NRPMQAP-12:SMAGP:${A4_IEF_IADU_HO_EX_SUC_SA}=1
...    NRCELL-1/PLMN-PLMN/NRPMQAP-1:SMAGP:${A4_IEF_IADU_HO_EX_ATT_SA}=0
...    NRCELL-1/PLMN-PLMN/NRPMQAP-1:SMAGP:${A4_IEF_IADU_HO_EX_SUC_SA}=0
...    NRCELL-1/PLMN-PLMN/NRPMQAP-4:SMAGP:${A4_IEF_IADU_HO_EX_ATT_SA}=0
...    NRCELL-1/PLMN-PLMN/NRPMQAP-4:SMAGP:${A4_IEF_IADU_HO_EX_SUC_SA}=0
...    NRCELL-1/PLMN-PLMN/NRPMQAP-20:SMAGP:${A4_IEF_IADU_HO_EX_ATT_SA}=0
...    NRCELL-1/PLMN-PLMN/NRPMQAP-20:SMAGP:${A4_IEF_IADU_HO_EX_SUC_SA}=0
...    NRCELL-1/PLMN-PLMN/NRPMQAP-10:SMAGP:${A4_IEF_IADU_HO_EX_ATT_SA}=0
...    NRCELL-1/PLMN-PLMN/NRPMQAP-10:SMAGP:${A4_IEF_IADU_HO_EX_SUC_SA}=0
...    NRCELL-1/PLMN-PLMN/NRPMQAP-3:SMAGP:${A4_IEF_IADU_HO_EX_ATT_SA}=0
...    NRCELL-1/PLMN-PLMN/NRPMQAP-3:SMAGP:${A4_IEF_IADU_HO_EX_SUC_SA}=0
...    NRCELL-1:NRANS:${ATT_IF_INTRA_DU_HO_SA_PLMN}=1
...    NRCELL-1:NRANS:${SUCC_IF_INTRA_DU_HO_SA_PLMN}=1
...    NRCELL-1:NRANS:${FAI_IF_INTRA_DU_HOP_AC_SA_PLMN}=0
...    NRCELL-1:NRANS:${FAI_IF_INTRADU_HOP_OTH_SA_PLMN}=0
...    NRCELL-1:NRREL:${ATT_HO_NRREL}=1
...    NRCELL-1:NRREL:${SUCC_HO_NRREL}=1
...    NRCELL-1:NRREL:${FAIL_HO_NRREL_PREP}=0
...    NRBTS-1:NSL:${ATT_IF_GNB_INTRA_DU_HO_SLICE}=2
...    NRBTS-1:NSL:${SUCC_IF_GNB_INTRA_DU_HO_SLICE}=2
...    NRCELL-2:NRANS:${ATT_IF_INTRA_DU_HO_SA_PLMN}=1
...    NRCELL-2:NRANS:${SUCC_IF_INTRA_DU_HO_SA_PLMN}=1
...    NRCELL-2:NRANS:${FAI_IF_INTRA_DU_HOP_AC_SA_PLMN}=0
...    NRCELL-2:NRANS:${FAI_IF_INTRADU_HOP_OTH_SA_PLMN}=0
...    NRCELL-2:NRREL:${ATT_HO_NRREL}=1
...    NRCELL-2:NRREL:${SUCC_HO_NRREL}=1
...    NRCELL-2:NRREL:${FAIL_HO_NRREL_PREP}=0
${FAI_IF_INTRA_DU_HOP_AC_SA_PLMN}    M55145C00323
#The number of inter-frequency intra-DU HO preparation failures for SA due to admission control
${FAI_IF_INTRADU_HOP_OTH_SA_PLMN}    M55145C00324
#The number of inter-frequency intra-DU HO preparation failures for SA due to other reasons
${ATT_HO_NRREL}    M55153C00001
#The number of HO attempts per neighbor relation
${SUCC_HO_NRREL}    M55153C00002
#The number of HO Success per neighbor relation
${FAIL_HO_NRREL_PREP}    M55153C00003
#The number of HO preparation Failures per neighbor relation
${ATT_IF_GNB_INTRA_DU_HO_SLICE}    M55149C00550
#The number of Inter-Frequency Intra-gNB Intra-DU HOs attempted for the given slice and PLMN
${SUCC_IF_GNB_INTRA_DU_HO_SLICE}    M55149C00551
#The number of Inter-Frequency Intra-gNB Intra-DU HOs successful for the given slice and PLMN


*** Test Cases ***
CB007517-ET-C007_Inter-freq_Intra-DU_HO_succeed_immediately_with_A4_MR_with_highest_prio_received_first_circulation_with_VONR
    [Documentation]
    ...    1. This user scenario describes the behaviour, gNB support CA, but UE is not support CA, inter-frq intra-DU HO will be succeed
    ...    immediately with A4 MR with highest prio received first circulation after ICS with VONR and loop handover.
    ...    2. Configuration
    ...         a.configuration on cell 1
    ...           UE capability support independent MG
    ...           5GUE supports the band of the inter-frequency configured for A4 measurements
    ...           UE capability is not support corresponding bandcombination(n41+n78).
    ...           VONR is enabled for cell1 and cell12
    ...           NRHOIF and NRREL for cell 1, present for cell 11,cell 12,cell 2,a4PriorityForHigherPrioFreqHo are 2,1,3
    ...           NRHOIF and NRREL for cell 12, present for cell 1,a4PriorityForHigherPrioFreqHo are 1
    ...           scell is configed for cell1 NRREL2
    ...           Measurement: A4
    ...           DRX: enable
    ...    3. Test Case Steps:
    ...         a. UE registers successfully and PDU session is setup successfully on cell 1.
    ...         b. Setup DRB for 5QI-5 and 5QI-1
    ...         c. Trigger A4 MG and meas_id = 3,2,1 within first SupervisionTimer (a4RetryTimer = 10s)
    ...         d. HO is excuted after A4 MG (meas_id = 1) is trigged.
    ...         e. Trigger A4 MG and meas_id = 1 within second SupervisionTimer (a4RetryTimer = 2s,a4Fr1SupervisionTimer=5s).
    ...         f. HO is excuted successful.
    ...         g. UE deregister should be successfully.
    ...     4. Expect result:
    ...          a. PDU session is setup successfully, and start retry timer
    ...          b. 5QI-5 setup, DRX setup, then 5QI-1 setup , DRX release, VONR DRX setup
    ...          c. A4 meas(1,2,3,4,5) is configged, gapFR1 setup, drx release after retry timer timeout
    ...          d. HO is triggered, A4 meas is released, gapFR1 is release, drx is setup,and start retry timer
    ...          e. A4 meas(1) is configure, gapFR1 setup, drx release after retry timer timeout. then after SupervisionTimer
    ...             timeout, A4 meas(1)is release, gapFR1 is release, drx is setup,and start second retry timer, start second
    ...             retry timer. after retry timer timeout, A4 meas(1)is re-configged, gapFR1 setup, drx release.
    ...          f. HO is trigged, A4 meas is released, gapFR1 is release, drx is setup
    ...          g. UE deregister is successfully
    [Tags]    QC_198813    owner-christine.chen    C007    CRT
    Clear Counter Files
    UE Attach To Target Cell with VONR    cell_id=1
    Send And Verify Throuput
    Trigger A4 HO to cell12
    Verify Throuput
    Trigger A4 HO to cell1
    Verify Throuput
    UE Deregister From gNB    ue_id=${ue_id}
    Check Wireshark Log    ${CURDIR}${/}a2a_CB007517C007${/}a2a.ini        wait_string=UEContextReleaseComplete::4
    Check Counters    ${PM_Counters_Check_C007}

CB007517-ET-C050_A4_deconfigured_after_A2_then_A1_with_A4_HO_with_diff_low_and_latest_highest_prio_A4_with_MFBI
    [Documentation]
    ...    1. The purpose of this test case is to check following scenarios:
    ...       deconfigured for non-first circulation after receiving inter-freq A2 MR and keep deconfigured until receiving A1 MR
    ...       and keep circulation then A4 MR before reach maxNum and inter-frq intra-DU HO succeed at last with multi A4 MR with
    ...       diff low prio and latest highest pro received after ICS(UEcapaperFR_A4MGperFR_interfreqA2Target3FR2)
    ...      (ICS_optimized_multiPDU__DRX__CA_Ue+_gNB_turnoff__actHigherPrioFreqHo_SA+NSA__target7_FR1__UEcapaPerFR
    ...       __priority_alldiff__highestMFBI)
    ...    2. Configuration
    ...         a.UE and gNB SCF configuration
    ...           UE capability support meagap perFR
    ...           5GUE supports the band of the inter-frequency configured for A4 measurements
    ...           UE capability is support corresponding bandcombination(n41+n77+n257) while gNB disable CA function
    ...           NRCELL-1: DRX enable, a4MeasMaxNumber=8, a4RetryTimer=30s, SupervisionTimer=10s
    ...                     NRHOIF-1: band66, ssb 424090, a4PriorityForHigherPrioFreqHo: 2
    ...                     NRHOIF-2: band71, ssb 126750, a4PriorityForHigherPrioFreqHo: 1
    ...                     NRHOIF-3: band78/77_MFBI, ssb 633216, a4PriorityForHigherPrioFreqHo: 1
    ...                     NRHOIF-4: band66, ssb 427970, a4PriorityForHigherPrioFreqHo: 4
    ...                     NRHOIF-5: band257, ssb 2079163, a4PriorityForHigherPrioFreqHo: 5
    ...                     NRHOIF-6: band257, ssb 2071675, a4PriorityForHigherPrioFreqHo: 6
    ...                     NRHOIF-7: band41, ssb 513150, a4PriorityForHigherPrioFreqHo: 7
    ...           NRCELL-2: DRX disable, a4MeasMaxNumber=8, a4RetryTimer=30s, SupervisionTimer=10s
    ...                     NRHOIF-3: band41, ssb 518910, a4PriorityForHigherPrioFreqHo: 3
    ...    3. Test Case Steps:
    ...         a. UE attach to NRCELL-1, band 41. A2 is configured and measid=1. MutliPDU session PDU=2 is setup.
    ...         b. After 1st retrytimer=30s, A4 is configured. 7 Measobject are added. Measid 3 is for MFBI band 77.
    ...            DRX release. GapFR1 is setup. MutliPDU session PDU=3 is setup.
    ...         c. After 1st supervision timer=10s, A4 is deconfigured. 7 Measid are removed.GapFR1 is released. DRX setup
    ...         d. After 2nd retrytimer=30s, A4 is configured. Measid 3 is for MFBI band 77.DRX release. GapFR1 is setup.
    ...         e. Before 2nd supervision timer=10s time out, A2 MR raised for NRCELL-1. A1 added in F1AP.
    ...            A1/A3 are added in RRC Reconfig.GapFR1 is released. DRX setup.
    ...         f. A1MR raise. A2 is configured.
    ...         g. After 4st retrytimer=30s, A4 configured.8 Measobject are added(1 for A2, other 7 for A4).
    ...            Measid 2 is for MFBI band 77.DRX release. GapFR1 is setup.
    ...         h. 3 A4 MR Raised. MeasId 2 of MFBI band 77 which is highest.
    ...         i. A4 HO to NRCELL-2, PCI 51.
    ...         j. After 1st retrytimer=30s, A4 is configured. 2 Measobject are added. MeasID is 1. GapFR1 is setup.
    ...         k. After 1st supervision timer=10s, A4 is deconfigured. 1 Measid is removed.GapFR1 is released.
    ...         l. After 2nd retrytimer=30s, A4 is configured. 2 Measobject are added. MeasID is 1. GapFR1 is setup.
    ...         m. A4 HO to NRCELL-1, PCI 50. Sourceconfig check then A2 is configured in target cell. DRX is setup.
    ...         n. After 1st retrytimer=30s, A4 is configured. 7 Measobject are added. Measid 2 is for MFBI band 77.
    ...            DRX release. GapFR1 is setup.
    ...         o. After 1st supervision timer=10s, A4 is deconfigured. 7 Measid are removed.GapFR1 is released. DRX setup
    ...         p. Normal release with multi-PDU: PDU 1,2,3
    [Tags]     QC_193983    owner-zhoulingyan    C050    CIT    CDRT
    Clear Counter Files
    OnlineParamChange    ${OnlineParam_C050}
    SA UE attach with multi PDU
    Check A4 timer working after Ue attach
    Trigger A2 On Second Supervison And Then Trigger A1 To Deconfig A1A3
    Trigger 3 Duplicated Highest A4 On Third Supervison Timer To Do HO
    UE Deregister From gNB    ${ue_id}
    Check Counters    ${PM_Counters_Check_C050}
    Check Wireshark Log    ${CURDIR}${/}a2a_CB007517C050${/}a2a.ini        wait_string=UEContextReleaseComplete::4
    [Teardown]    Restore scf to remove C050 delta
*** Keywords ***
Check A4 timer working after Ue attach
    Check Measid After Fist A4retrytimer Expire and PDU 3 is setup
    Check Measid After Fist A4Fr2SupervisionTimer Expire
    Check Measid After Second A4retrytimer Expire

Trigger A2 On Second Supervison And Then Trigger A1 To Deconfig A1A3
    Trigger A2MR During Second A4Fr2SupervisionTimer
    sleep    8s    reason=wait Second A4Fr2SupervisionTimer expire
    sleep    30s    reason=wait Third A4retrytimer Expire
    Third A4retrytimer Expire And Restart And Trigger A1MR Before Expire Then A1A3 Deconfig

Trigger 3 Duplicated Highest A4 On Third Supervison Timer To Do HO
    Trigger 3 A4 Duplicate Highest Prio MR During Third A4Fr2SupervisionTimer Then HO Happen Later
    After A4retrytimer Expire On Target Cell A4 Configure
    Verify_TP_MultiPDU_3PDU

Check Measid After Fist A4retrytimer Expire and PDU 3 is setup
    Wait Until Keyword Succeeds    25s    1s    Get Band 77 measid
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=3 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup pdu=3 ue=${ue_id} nwslice=1 gw=3    PDU SESSION RESOURCE SETUP RESPONSE

Get Band 77 measid
    ${m633216}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${F633216}    event_type=A4

Check Measid After Fist A4Fr2SupervisionTimer Expire
    sleep    7s    reason=wait Fist A4Fr2SupervisionTimer Expire

Check Measid After Second A4retrytimer Expire
    Send_TP_MultiPDU_3rdPDU
    Verify_TP_MultiPDU_3PDU
    sleep    21s    reason=wait Second A4retrytimer Expire


Trigger A2MR During Second A4Fr2SupervisionTimer
    ${m518910}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${F518910}    event_type=A2
    ${ret}=    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${m518910} event=A2 srsrp_nr=20 srsrq_nr=20
    ...    pass_regexp=eventId eventA3
    Should Contain    ${ret}    gapFR1 release

Third A4retrytimer Expire And Restart And Trigger A1MR Before Expire Then A1A3 Deconfig
    sleep    15s    reason=wait Third A4retrytimer 15s
    ${m518910}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${F518910}    event_type=A1
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${m518910} event=A1 srsrp_nr=110 srsrq_nr=110
    ...    pass_regexp=eventId eventA2
    sleep    10s    reason=wait Third A4retrytimer expire

Trigger 3 A4 Duplicate Highest Prio MR During Third A4Fr2SupervisionTimer Then HO Happen Later
    Get Freq Measid List
    Compare Mesid According Freq and Trigger 3 A4 MR

Get Freq Measid List
    ${list_of_query_conditions}    Create List
    ${query1}=    Create Dictionary    ue_id=${ue_id}    carrierfreq=${F633216}    event_type=A4
    ${query2}=    Create Dictionary    ue_id=${ue_id}    carrierfreq=${F424090}    event_type=A4
    ${query3}=    Create Dictionary    ue_id=${ue_id}    carrierfreq=${F427970}    event_type=A4
    Append To List    ${list_of_query_conditions}    ${query1}    ${query2}    ${query3}
    Set Test Variable    ${list_of_query_conditions}

Compare Mesid According Freq and Trigger 3 A4 MR
    Wait Until Keyword Succeeds    15s    2s    Get Nr Meas Ids For Specific Type And Frequency
    ...    list_of_query_conditions=${list_of_query_conditions}
	${meas_ids}=    Get Nr Meas Ids For Specific Type And Frequency    list_of_query_conditions=${list_of_query_conditions}
    Should Be True    ${meas_ids[0]}<${meas_ids[1]}<${meas_ids[2]}
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_ids[1]} event=A4 phycell_id=60 nrsrp_nr=80 nrsrq_nr=80
    ...    pass_regexp=measResultNeighCells measResultListNR
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_ids[2]} event=A4 phycell_id=62 nrsrp_nr=80 nrsrq_nr=80
    ...    pass_regexp=measResultNeighCells measResultListNR
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_ids[0]} event=A4 phycell_id=51 nrsrp_nr=80 nrsrq_nr=80
    ...    pass_regexp=Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.2
    #sleep    7s    reason=wait Third A4Fr2SupervisionTimer expire

After A4retrytimer Expire On Target Cell A4 Configure
    sleep    32s    reason=wait Fist A4retrytimer Expire
    ${m518910}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${F518910}    event_type=A4
    Verify_TP_MultiPDU_3PDU
    sleep    29s    reason=wait Second A4retrytimer Expire
    ${m518910}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${F518910}    event_type=A4
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${m518910} event=A4 phycell_id=50 nrsrp_nr=80 nrsrq_nr=80
    ...    pass_regexp=measResultNeighCells measResultListNR
    sleep    30s    reason=wait Fist A4retrytimer Expire
    ${m633216}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${F633216}    event_type=A4
    sleep    8s    reason=wait Fist supervision Expire


SA UE attach with multi PDU
    [Arguments]    ${ue_id}=81    ${target_cells}=1
    Update UE capa    ${SA_Capa_MFBI_n41+n77+n257}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${target_cells}
    Execute Egate Command    ue_register id=${ue_id}    NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal    sleep_time=5
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=2 trf_type=internal    sleep_time=5
    Execute Egate Command    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=1    Initial Context Setup Successful
    Execute Egate Command    ue_pdu_session_setup pdu=2 ue=${ue_id} nwslice=1 gw=2    PDU SESSION RESOURCE SETUP RESPONSE
    Send_TP_MultiPDU_2PDU
    Verify_TP_MultiPDU_2PDU

Send_TP_MultiPDU_2PDU
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=1
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=2 qfi=1 dir=dl mbps=50 trf_id=1
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=ul mbps=10 trf_id=1
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=2 qfi=1 dir=ul mbps=10 trf_id=1

Send_TP_MultiPDU_3rdPDU
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=3 qfi=1 dir=dl mbps=100 trf_id=1
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=3 qfi=1 dir=ul mbps=10 trf_id=1

Verify_TP_MultiPDU_2PDU
    sleep    5s    reason=wait for stable traffic
    ${dl_tp_pdu1}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=ave
    ${dl_tp_pdu2}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=2    qfi=1    direction=dl    rate_type=ave
    ${ul_tp_pdu1}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    ${ul_tp_pdu2}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=2    qfi=1    direction=ul    rate_type=ave
    Should Be True    ( ${dl_tp_pdu1}+ ${dl_tp_pdu2})/1000>145
    Should Be True    ( ${ul_tp_pdu1}+ ${ul_tp_pdu2})/1000>19

Verify_TP_MultiPDU_3PDU
    sleep    5s    reason=wait for stable traffic
    ${dl_tp_pdu1}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=ave
    ${dl_tp_pdu2}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=2    qfi=1    direction=dl    rate_type=ave
    ${dl_tp_pdu3}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=3    qfi=1    direction=dl    rate_type=ave
    ${ul_tp_pdu1}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    ${ul_tp_pdu2}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=2    qfi=1    direction=ul    rate_type=ave
    ${ul_tp_pdu3}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=3    qfi=1    direction=ul    rate_type=ave
    Should Be True    ( ${dl_tp_pdu1}+ ${dl_tp_pdu2}+ ${dl_tp_pdu3})/1000>235
    Should Be True    ( ${ul_tp_pdu1}+ ${ul_tp_pdu2}+${ul_tp_pdu3})/1000>28

Restore scf to remove C050 delta
    OnlineParamChange    ${OnlineParam_C050_recover}
    Common Test Teardown And Stop Capture Logs

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be Onair    check_sib=${False}

Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_2T4F

UE Attach To Target Cell with VONR
    [Arguments]    ${cell_id}
    Update UE capa    ${SA_Capa_not_Support_n41+n78_independent}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=${gw_id} nwslice=${nwslice}    QoS Routing Table
    ${ret}=    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_add=2 by=amf    QoS Routing Table
    Should Contain    ${ret}    Added QosFlow with QFI:2 fiveQI:5
    ${ret1}=    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_add=3 by=amf    QoS Routing Table
    Should Contain    ${ret1}    Added QosFlow with QFI:3 fiveQI:1

Trigger A4 HO to cell12
    [Arguments]
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=3 event=A4 phycell_id=51 nrsrp_nr=50
    ...    pass_regexp=measResultNeighCells measResultListNR
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=2 event=A4 phycell_id=60 nrsrp_nr=50
    ...    pass_regexp=measResultNeighCells measResultListNR
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=1 event=A4 phycell_id=61 nrsrp_nr=50
    ...    rrcReconfigurationComplete
    Execute Egate Command    ue_disp
Trigger A4 HO to cell1
    [Arguments]
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=1 event=A4 phycell_id=50 nrsrp_nr=40
    ...    rrcReconfigurationComplete
    Execute Egate Command    ue_disp

Verify Throuput
    [Arguments]    ${Tput_dl}=63    ${Tput_ul}=9.5    ${sleep_time}=10s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

Send And Verify Throuput
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=70
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=ul mbps=10
    Verify Throuput

UE Deregister From gNB
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s

Update UE capa
    [Arguments]    ${SA_Capa_perUE_Full}=none
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full}
    Execute Egate Command    ${cmd}

Modify Cfg
    ${V_1}    catenate
    Update Cfg    set_qosflow id=2 5qi=5 default=off
    Update Cfg    set_qosflow id=3 5qi=1
    Update Cfg    set_qosflow id=4 5qi=9 default=off
    Update Cfg    set_qosrule id=1 proto=tcp qos_flow=2
    Update Cfg    set_qosrule id=2 proto=udp qos_flow=3
    ${cmd}    catenate    set_cell id=2 gnb=2 pci=17:0 tac=200 nrci=0x02 tdd_cell=on proxy=10.0.2.80:9999|10.0.2.80:8888
    ...    nr_arfcn=633372:633372 gscn=7845 mapped_MFBI=77 mandatory_for_activation=off
    Update Cfg    ${cmd}
