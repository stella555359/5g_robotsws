*** Settings ***
Documentation
...    author: Geng lishuo
...    contact: lishuo.geng@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CRT    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...               team-CN3ET    owner-chengmao.sun    release-SBTS23R3
Resource          ../../../../../../resources/DevHZ5_resource.robot

*** Variables ***
${GNB1_CONFIG}    tdd_sansa_cmwv/FS/3cells_ecpri
${NOKIA_F1AP_PLUGIN_FLAG}    ${True}

@{PARAMS_IN_SCF}
...    @{5GC000704}
...    @{5GC00572}
...    @{interGnbHO}
...    @{interFreqHoSA}
...    @{CA}
...    @{PowerSaving}

@{interGnbHO}
...    NRBTS/NRADJNRCELL-1:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-1:gNbId=36
...    NRBTS/NRADJNRCELL-1:gNbIdLength=22
...    NRBTS/NRADJNRCELL-1:lcrId=1
...    NRBTS/NRADJNRCELL-1:nrarfcn=636666
...    NRBTS/NRADJNRCELL-1:physCellId=48
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-1:freqBandIndicatorNR=${EMPTY}
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-2:gNbId=2
...    NRCELL-1/NRREL-2:gNbIdLength=22
...    NRCELL-1/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-2:lcrId=3
...    NRCELL-1/NRREL-2:nrDcAllowed=false
...    NRCELL-1/NRREL-2:removeNotAllowed=true
...    NRCELL-1/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-2:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-2/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-2:gNbId=36
...    NRCELL-2/NRREL-2:gNbIdLength=22
...    NRCELL-2/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-2:lcrId=1
...    NRCELL-2/NRREL-2:nrDcAllowed=false
...    NRCELL-2/NRREL-2:removeNotAllowed=true
...    NRCELL-2/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-3/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-3/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-3/NRREL-2:gNbId=36
...    NRCELL-3/NRREL-2:gNbIdLength=22
...    NRCELL-3/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-3/NRREL-2:lcrId=1
...    NRCELL-3/NRREL-2:nrDcAllowed=false
...    NRCELL-3/NRREL-2:removeNotAllowed=true
...    NRCELL-3/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-3/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-3/NRREL-2:gnbPlmn:mncLength=3
...    NRBTS/TRACKINGAREA-788:fiveGsTac=788
...    NRBTS/TRACKINGAREA-200:fiveGsTac=200
...    NRCELL:trackingAreaDN=MRBTS-1/NRBTS-2/TRACKINGAREA-200
...    NRCELL-2:trackingAreaDN=MRBTS-1/NRBTS-2/TRACKINGAREA-788
...    MRBTS-1/NRBTS-2/NRADJGNB-1:administrativeState=Unlocked
...    MRBTS-1/NRBTS-2/NRADJGNB-1:gNbIdLength=22
...    MRBTS-1/NRBTS-2/NRADJGNB-1:gNodeBId=36
...    MRBTS-1/NRBTS-2/NRADJGNB-1:gNodeBIdCtrl=oamControlled
...    MRBTS-1/NRBTS-2/NRADJGNB-1:weightForIgnbCaSelection=1
...    MRBTS-1/NRBTS-2/NRADJGNB-1:gnbPlmn:mcc=311
...    MRBTS-1/NRBTS-2/NRADJGNB-1:gnbPlmn:mnc=489
...    MRBTS-1/NRBTS-2/NRADJGNB-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJGNB-1:xnLinkRef=1
...    NRCELL-3:measGapSelectionSA=favourUeThroughput
...    NRCELL-3/NRHOIF-1:a1BasedPCellSwitchEnabled=false
...    NRCELL-3/NRHOIF-1:a2BasedPCellSwitchEnabled=false
...    NRCELL-3/NRHOIF-1:a3MeasEnabled=rsrpAndRsrq
...    NRCELL-3/NRHOIF-1:a4MeasEnDcSteeringEnabled=none
...    NRCELL-3/NRHOIF-1:a4MeasHigherPrioFreqEnabled=none
...    NRCELL-3/NRHOIF-1:a4MeasNrDcEnabled=none
...    NRCELL-3/NRHOIF-1:a5MeasEnabled=rsrpAndRsrq
...    NRCELL-3/NRHOIF-1:cellDepType=SA
#...    NRCELL-3/NRHOIF-1:chBw=20MHz
...    NRCELL-3/NRHOIF-1:freqBandIndicatorNR=78
...    NRCELL-3/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-3/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-3/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf5
...    NRCELL-3/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-3/NRHOIF-1:scs=30 KHz
...    NRCELL-3/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-3/NRHOIF-1:ssbFrequency=636576
...    NRCELL-3/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-3/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrpVoNr=2
...    NRCELL-3/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=3
...    NRCELL-3/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrpVoNr=2
...    NRCELL-3/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms480
...    NRCELL-3/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrpVoNr=ms256
...    NRCELL-3/NRHOIF-1:a3MeasSsbRsrq:a3HysteresisSsbRsrq=0
...    NRCELL-3/NRHOIF-1:a3MeasSsbRsrq:a3HysteresisSsbRsrqVoNr=2
...    NRCELL-3/NRHOIF-1:a3MeasSsbRsrq:a3OffsetSsbRsrq=3
...    NRCELL-3/NRHOIF-1:a3MeasSsbRsrq:a3OffsetSsbRsrqVoNr=2
...    NRCELL-3/NRHOIF-1:a3MeasSsbRsrq:a3TimeToTriggerSsbRsrq=ms480
...    NRCELL-3/NRHOIF-1:a3MeasSsbRsrq:a3TimeToTriggerSsbRsrqVoNr=ms256
...    NRCELL-3/NRHOIF-1:a5MeasSsbRsrp:a5HysteresisSsbRsrp=0
...    NRCELL-3/NRHOIF-1:a5MeasSsbRsrp:a5HysteresisSsbRsrpVoNr=2
...    NRCELL-3/NRHOIF-1:a5MeasSsbRsrp:a5Threshold1SsbRsrp=40
...    NRCELL-3/NRHOIF-1:a5MeasSsbRsrp:a5Threshold1SsbRsrpVoNr=50
...    NRCELL-3/NRHOIF-1:a5MeasSsbRsrp:a5Threshold2SsbRsrp=50
...    NRCELL-3/NRHOIF-1:a5MeasSsbRsrp:a5Threshold2SsbRsrpVoNr=60
...    NRCELL-3/NRHOIF-1:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms480
...    NRCELL-3/NRHOIF-1:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrpVoNr=ms256
...    NRCELL-3/NRHOIF-1:a5MeasSsbRsrq:a5HysteresisSsbRsrq=0
...    NRCELL-3/NRHOIF-1:a5MeasSsbRsrq:a5HysteresisSsbRsrqVoNr=2
...    NRCELL-3/NRHOIF-1:a5MeasSsbRsrq:a5Threshold1SsbRsrq=10
...    NRCELL-3/NRHOIF-1:a5MeasSsbRsrq:a5Threshold1SsbRsrqVoNr=20
...    NRCELL-3/NRHOIF-1:a5MeasSsbRsrq:a5Threshold2SsbRsrq=20
...    NRCELL-3/NRHOIF-1:a5MeasSsbRsrq:a5Threshold2SsbRsrqVoNr=30
...    NRCELL-3/NRHOIF-1:a5MeasSsbRsrq:a5TimeToTriggerSsbRsrq=ms480
...    NRCELL-3/NRHOIF-1:a5MeasSsbRsrq:a5TimeToTriggerSsbRsrqVoNr=ms256
...    NRBTS/XNLINK-1:cPlaneIpAddr=10.0.1.122
...    NRBTS/XNLINK-1:cPlaneIpAddrCtrl=oamControlled
...    NRCELL:cellDepType=SA+NSA

@{interFreqHoSA}
...    NRBTS:actInterFreqHoSA=true
...    NRCELL:a2MeashoEnabledSA=rsrpAndRsrq
...    NRCELL:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0|a2TimeToTriggerHoSsbRsrpVoNr=ms256
...    NRCELL:a2MeashoSsbRsrpSA:a2HysteresisHoSsbRsrpVoNr=6|a2TimeToTriggerHoSsbRsrpVoNr=ms256
...    NRCELL:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=50|a2TimeToTriggerHoSsbRsrpVoNr=ms256
...    NRCELL:a2MeashoSsbRsrpSA:a2ThresholdHoSsbRsrpVoNr=60|a2TimeToTriggerHoSsbRsrpVoNr=ms256
...    NRCELL:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms480|a2TimeToTriggerHoSsbRsrpVoNr=ms256
...    NRCELL:a2MeashoSsbRsrqSA:a2HysteresishoSsbRsrqSA=0|a2TimeToTriggerHoSsbRsrqVoNr=ms256
...    NRCELL:a2MeashoSsbRsrqSA:a2HysteresisHoSsbRsrqVoNr=6|a2TimeToTriggerHoSsbRsrqVoNr=ms256
...    NRCELL:a2MeashoSsbRsrqSA:a2ThresholdhoSsbRsrqSA=20|a2TimeToTriggerHoSsbRsrqVoNr=ms256
...    NRCELL:a2MeashoSsbRsrqSA:a2ThresholdHoSsbRsrqVoNr=30|a2TimeToTriggerHoSsbRsrqVoNr=ms256
...    NRCELL:a2MeashoSsbRsrqSA:a2TimeToTriggerhoSsbRsrqSA=ms480|a2TimeToTriggerHoSsbRsrqVoNr=ms256
...    NRCELL:a1MeashoEnabledSA=rsrpAndRsrq
...    NRCELL:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0|a1TimeToTriggerHoSsbRsrpVoNr=ms256
...    NRCELL:a1MeashoSsbRsrpSA:a1HysteresisHoSsbRsrpVoNr=6|a1TimeToTriggerHoSsbRsrpVoNr=ms256
...    NRCELL:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=60|a1TimeToTriggerHoSsbRsrpVoNr=ms256
...    NRCELL:a1MeashoSsbRsrpSA:a1ThresholdHoSsbRsrpVoNr=70|a1TimeToTriggerHoSsbRsrpVoNr=ms256
...    NRCELL:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms480|a1TimeToTriggerHoSsbRsrpVoNr=ms256
...    NRCELL:a1MeashoSsbRsrqSA:a1HysteresishoSsbRsrqSA=0|a1TimeToTriggerHoSsbRsrqVoNr=ms256
...    NRCELL:a1MeashoSsbRsrqSA:a1HysteresisHoSsbRsrqVoNr=6|a1TimeToTriggerHoSsbRsrqVoNr=ms256
...    NRCELL:a1MeashoSsbRsrqSA:a1ThresholdhoSsbRsrqSA=30|a1TimeToTriggerHoSsbRsrqVoNr=ms256
...    NRCELL:a1MeashoSsbRsrqSA:a1ThresholdHoSsbRsrqVoNr=40|a1TimeToTriggerHoSsbRsrqVoNr=ms256
...    NRCELL:a1MeashoSsbRsrqSA:a1TimeToTriggerhoSsbRsrqSA=ms480|a1TimeToTriggerHoSsbRsrqVoNr=ms256
...    NRCELL-1/NRHOIF-1:a3MeasEnabled=rsrpAndRsrq
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0|a3TimeToTriggerSsbRsrpVoNr=ms256
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrpVoNr=2|a3TimeToTriggerSsbRsrpVoNr=ms256
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=3|a3TimeToTriggerSsbRsrpVoNr=ms256
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrpVoNr=2|a3TimeToTriggerSsbRsrpVoNr=ms256
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms480|a3TimeToTriggerSsbRsrpVoNr=ms256
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrq:a3HysteresisSsbRsrq=0|a3TimeToTriggerSsbRsrqVoNr=ms256
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrq:a3HysteresisSsbRsrqVoNr=2|a3TimeToTriggerSsbRsrqVoNr=ms256
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrq:a3OffsetSsbRsrq=3|a3TimeToTriggerSsbRsrqVoNr=ms256
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrq:a3OffsetSsbRsrqVoNr=2|a3TimeToTriggerSsbRsrqVoNr=ms256
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrq:a3TimeToTriggerSsbRsrq=ms480|a3TimeToTriggerSsbRsrqVoNr=ms256
...    NRCELL-1/NRHOIF-1:a5MeasEnabled=rsrpAndRsrq
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5HysteresisSsbRsrp=0|a5TimeToTriggerSsbRsrpVoNr=ms256
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5HysteresisSsbRsrpVoNr=2|a5TimeToTriggerSsbRsrpVoNr=ms256
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5Threshold1SsbRsrp=40|a5TimeToTriggerSsbRsrpVoNr=ms256
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5Threshold1SsbRsrpVoNr=50|a5TimeToTriggerSsbRsrpVoNr=ms256
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5Threshold2SsbRsrp=50|a5TimeToTriggerSsbRsrpVoNr=ms256
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5Threshold2SsbRsrpVoNr=60|a5TimeToTriggerSsbRsrpVoNr=ms256
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms480|a5TimeToTriggerSsbRsrpVoNr=ms256
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrq:a5HysteresisSsbRsrq=0|a5TimeToTriggerSsbRsrqVoNr=ms256
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrq:a5HysteresisSsbRsrqVoNr=2|a5TimeToTriggerSsbRsrqVoNr=ms256
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrq:a5Threshold1SsbRsrq=10|a5TimeToTriggerSsbRsrqVoNr=ms256
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrq:a5Threshold1SsbRsrqVoNr=20|a5TimeToTriggerSsbRsrqVoNr=ms256
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrq:a5Threshold2SsbRsrq=20|a5TimeToTriggerSsbRsrqVoNr=ms256
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrq:a5Threshold2SsbRsrqVoNr=30|a5TimeToTriggerSsbRsrqVoNr=ms256
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrq:a5TimeToTriggerSsbRsrq=ms480|a5TimeToTriggerSsbRsrqVoNr=ms256
...    NRCELL-1/NRHOIF-1:cellDepType=SA
#...    NRCELL-1/NRHOIF-1:chBw=20MHz
...    NRCELL-1/NRHOIF-1:freqBandIndicatorNR=78
...    NRCELL-1/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf5
...    NRCELL-1/NRHOIF-1:scs=30 KHz
...    NRCELL-1/NRHOIF-1:ssbFrequency=646656
...    NRCELL:a2MeashoSsbRsrp:a2ThresholdhoSsbRsrp=34
...    NRCELL:a2MeashoSsbRsrq:a2ThresholdhoSsbRsrq=31|a2TimeToTriggerhoSsbRsrq=ms480
...    NRCELL:a2MeasRedirectSsbRsrp:a2ThresholdRedirectSsbRsrp=34|a2TimeToTriggerRedirectSsbRsrp=ms480
...    NRCELL:a2MeasRedirectSsbRsrq:a2ThresholdRedirectSsbRsrq=31|a2TimeToTriggerRedirectSsbRsrq=ms480
...    NRCELL:a1MeashoSsbRsrp:a1ThresholdhoSsbRsrp=39
...    NRCELL:a1MeashoSsbRsrq:a1ThresholdhoSsbRsrq=36|a1TimeToTriggerhoSsbRsrq=ms480

@{5GC00572}
...    NRBTS:actIntraFreqIntraGnbMobilityNSA=true
...    NRBTS:actIntraMeNBMobility=true

@{5GC000704}

...    NRBTS:actConflictConfiguration=true
...    NRBTS:actIntraFreqHoSA=true
...    NRBTS:timerXnDataFwdGuard=250
...    NRPMRNL-1:miNrRelReportCu=15min
...    NRCELL:a3MeasEnabled=rsrp
...    NRCELL:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0|a3TimeToTriggerSsbRsrp=ms320
...    NRCELL:a3MeasSsbRsrp:a3OffsetSsbRsrp=3|a3TimeToTriggerSsbRsrp=ms320
...    NRCELL:filterCoeffSsbRsrp=fc4
...    NRCELL:absThreshSsbRsrpConsolidation=80
...    NRCELL:sMeasConfigSsbRsrp=20
...    NRBTS:actIncXn=true
...    NRBTS:cipherPrefL:nea0=9|nea3_128=0

@{CA}
...    NRBTS/NRDU-1:actConnectedModeMobilityCA=true
...    NRBTS/NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRBTS/NRDU-1:carrierAggregationSupportList=ca_Fr1Tdd_Sa,ca_Fr1Tdd_Nsa,ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Any_Sa
...    NRBTS/NRDU-1:actInterNumerologyCa=true
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS:actMeasBasedSCellAdditionNsa=true
...    NRBTS:actHoOptimizationCa=true
...    NRBTS:sCellActivationMethod=bufferBased
...    NRCELL:allowUnsuppBcOrBcs=accept unknown band combinations,accept unknown BCSs
...    NRCELL:a1MeasPCellSwitchEnabled=rsrp
...    NRCELL:a2MeasPCellSwitchEnabled=rsrp
...    NRCELL:a1MeasSCellAddEnabled=rsrp
...    NRCELL:a2MeasSCellRelEnabled=rsrp
...    NRCELL:a1MeasPCellSwitchSsbRsrp:a1TimeToTriggerPCellSwitchSsbRsrp=480ms
...    NRCELL:a1MeasPCellSwitchSsbRsrp:a1HysteresisPCellSwitchSsbRsrp=0
...    NRCELL:a1MeasPCellSwitchSsbRsrp:a1ThresholdPCellSwitchSsbRsrp=60
...    NRCELL:a2MeasPCellSwitchSsbRsrp:a2TimeToTriggerPCellSwitchSsbRsrp=480ms
...    NRCELL:a2MeasPCellSwitchSsbRsrp:a2HysteresisPCellSwitchSsbRsrp=0
...    NRCELL:a2MeasPCellSwitchSsbRsrp:a2ThresholdPCellSwitchSsbRsrp=40
...    NRCELL:a2MeasPCellSwitchSsbRsrp:pCellSwitchOffsetSsbRsrp=0
...    NRCELL:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=60
...    NRCELL:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0
...    NRCELL:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=2560ms
...    NRCELL:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=34
...    NRBTS/NRDU-1:actNonBfAndBfCa=true
...    NRCELL:pucchModeSelect=longPucch
...    NRCELL:actK1Opt=intra-gNB

@{PowerSaving}
...    NRBTS:actNrLBPowerSaving=true
...    NRBTS:actCoordinated4g5gPowerSaving=cellDeactivation
...    NRBTS/NRPGRP-10:lbpsCSONCtlEnabled=true
...    NRBTS/NRPGRP-10:lbpsLastCellMinLoad=20
...    NRBTS/NRPGRP-10:lbpsLastCellRTXMinLoad=10
...    NRBTS/NRPGRP-10:lbpsLastCellSOEnabled=true
...    NRBTS/NRPGRP-10:lbpsMaxLoad=60
...    NRBTS/NRPGRP-10:lbpsMinLoad=20
...    NRBTS/NRPGRP-10:lbpsMonWinForCellSOff=120
...    NRBTS/NRPGRP-10:lbpsMonWinForCellSOn=120
...    NRBTS/NRPGRP-10:lbpsPdcchLoadOffset=4
...    NRBTS/NRPGRP-10:lbpsRTXCellCapOffset=80
...    NRBTS/NRPGRP-10:lbpsRTXMaxLoad=60
...    NRBTS/NRPGRP-10:lbpsRTXMinLoad=20
...    NRBTS/NRPGRP-10:lbpsRTXSOffTime=300
...    NRBTS/NRPGRP-10:lbpsRTXSOnTime=120
...    NRBTS/NRPGRP-10:lbpsSOMethod=cell switch off
...    NRBTS/NRPGRP-10:lbpsCellList:lbpsCellSOOrder=70|nrCellId=1
...    NRPGRP-10:lbpsPeriodList:lbpsDuration=35|lbpsDayOfWeek=Wed
...    NRPGRP-10:lbpsPeriodList:lbpsStartTimeHour=8|lbpsDayOfWeek=Wed
...    NRPGRP-10:lbpsPeriodList:lbpsStartTimeMinute=20|lbpsDayOfWeek=Wed
...    NRBTS:x2EnDcCfUpRspTmr=3
...    NRBTS:maxX2EnDcCfUpRetry=3
...    NRBTS:x2EnDcCfUpRdmDelayTmr=3
...    NRBTS:xnNgRanCfUpRdmDelayTmr=3
...    NRBTS:actLbpsCtrlLogicEnh=true
...    NRBTS/NRPGRP-10:lbpsLoadCalcMethod=Max(G, C, P)
...    NRBTS/NRPGRP-10:lbpsSOnTrRule=MinValueMethod
...    NRBTS/NRPGRP-10:lbpsSOffTrRule=MaxValueMethod

${ue_nr_capabilities}    SEPARATOR=
...    E9A09000575F5A13160003C320016093170019C3D09009B20C39F30C7942C0E098040623807DC6C28C0D608C21A08107482C036B64C558D0E
...    7C471E819F604F8C48E3C873EA39F30C7942C0E070F05C00FFC0070005F000540001C0A83620EB04610D04083C4160195B262AC4873EC09F1
...    1C78C48E3C873EA39F30C7942C0E070F09FD8000007F6000000540001C0AA3626EB04610D04083A4160185B262A88873E238F11C7A067D813
...    E31CF9863CA1607038782E007FE003801FF8002A0000E0541B11B582308682041E20B00CAD931562439F11C7B027C62471E439F51CF9863CA
...    1607038784FFF800003FFE000002A0000E007BC3C4D000E208000010B0102A0F0A000388C0000042C0AC3C46000E208000030B02B0F0A0003
...    8820000042C0AC3C4D000E230000010B02B17118003882001C4100000A160561E26800713400003058158B89A001C41000E140000040B02B1
...    713400388C001C46000004160562E14000710400388C0000082C0AC5C28000E20800710400001058158B89A001C41000E230000020B02B170
...    A000388C001C46000004160562E2680071180038500000102C0AC3C46000E230000030B0200E0234028809B01044501760F851226C73E1C28
...    913639F0E14489B1CF870A244D8E7C3851226C73E1C4891226C73E1C28103639F022408103639F022408103639F022408103639F022408103
...    639F022408103639F022408103639F022408103639F0214081B1CF8002E1E318C6318C6318C6318C3D04C00F000A070500703009401C00180
...    90010180F82400800000004000008020000000100000200800002004000018020000100100000A008004010040100000C0080000700400200
...    000008000080040000480200000C010000140080000B004002048120080000C0339535953582979515933582B594B5933580B581B58095811
...    583B40D04000025949410000196525040000A594901000039652404000125949010000596524040001A594901000079652404000225949010
...    000996524040002A5949010000B96525040003259490100003165240334AAAE955552A8BA55154962E95455068AA531549A2A80C55028AA4D
...    5541E28480BC04A8140A05028140A05028140A05028140A05028140A000C10100C018040080108080100402018030804008010100C0180403
...    00608080600C02018030804008010100C018040080110080600C02018030080600C10100200804008021AA1F000102030406070A0B0C0D101
...    112131418191B1C1D1F2125262728292A2D2F414182D

${ue_eutra_nr_capabilities}    SEPARATOR=
...    A11FF83BC4C0C03850001C46000000162205E260601C4D000E268000000B1102F130300E26800710400000058881789818070A00038820000
...    002C040BC4C0C03882001C46000002160205E360601C46000E208007104000010580817898180713400385000000C2C040804808D00A001C0
...    41809A2A801720F1274489B1CF871274489B1CF871274489B1CF871274489B1CF87127448931CFA34E891224C73E893A24498E7C0340E318C
...    6318C18041000040202004010080600C2000080404008010100C01860001008080600C02018030080600C2000080404008020100200800000
...    0000

@{reset_conf}
...    NRPGRP-10:lbpsPeriodList:lbpsDuration=1|lbpsDayOfWeek=Wed
...    NRPGRP-10:lbpsPeriodList:lbpsStartTimeHour=7|lbpsDayOfWeek=Wed
...    NRPGRP-10:lbpsPeriodList:lbpsStartTimeMinute=20|lbpsDayOfWeek=Wed
...    NRBTS/NRPGRP-10:lbpsLastCellSOEnabled=true
...    NRCELL-3/NRHOIF-1:cellDepType=NSA
...    NRCELL:cellDepType=NSA
...    NRCELL:msg1FrequencyStart=13
...    delete:NRCELL:trackingAreaDN
...    NRCELL-1/NRHOIF-1:cellDepType=NSA

@{prepare_case03_precondition}
...    NRBTS:actCoordinated4g5gPowerSaving=cellDeactivation
...    NRBTS/NRPGRP-10:lbpsLastCellSOEnabled=true
...    NRBTS/NRPGRP-10:lbpsMonWinForCellSOff=200
...    NRBTS/NRPGRP-10:lbpsMonWinForCellSOn=120
...    NRBTS/NRPGRP-10:lbpsCellList:lbpsCellSOOrder=70|nrCellId=3
...    delete:NRPGRP-10:lbpsCellList:lbpsCellSOOrder=60|nrCellId=2
...    delete:NRPGRP-10:lbpsCellList:lbpsCellSOOrder=50|nrCellId=1
...    NRBTS/NRPGRP-10:lbpsPeriodList:lbpsSuspended=notSuspended

@{prepare_case07_precondition}
...    NRBTS:actCoordinated4g5gPowerSaving=cellDeactivation
...    NRBTS/NRPGRP-10:lbpsLastCellSOEnabled=true
...    NRBTS/NRPGRP-10:lbpsMonWinForCellSOff=200
...    NRBTS/NRPGRP-10:lbpsMonWinForCellSOn=120
...    NRBTS/NRPGRP-10:lbpsCellList:lbpsCellSOOrder=50|nrCellId=1
...    delete:NRPGRP-10:lbpsCellList:lbpsCellSOOrder=70|nrCellId=3
...    delete:NRPGRP-10:lbpsCellList:lbpsCellSOOrder=60|nrCellId=2
...    NRBTS/NRPGRP-10:lbpsPeriodList:lbpsSuspended=notSuspended

@{case02_pass_list}
...    UE31: Sending SgNB Addition Request
...    value SgNBAdditionRequestReject
...    radioNetwork : cell-not-available
...    SgNBChangeRefuse message received with cause RAN Cell not avalible

@{case03_pass_list}
...    Successfully reconfigured dual connectivity
...    rrcConnectionReconfigurationComplete

@{case07_pass_list}
...    Successfully reconfigured dual connectivity
...    sCellToAddModList
...    rrcConnectionReconfigurationComplete

*** Test Cases ***
CB008951-B-a_ET_01_01_MeNB will be informed that NRCELL with SA and NSA is deactivated when CB008951 is activated
    [Tags]    CA_LABEL-TT(100MHz_TDD_n78+100MHz_TDD_n78)
    Start To Capture AP Wireshark
    Check currently time and modify parameters under lbpsPeriodList
    Cell States Check    State=notEnergySaving
    Register UE to gnb2 cell1
    Cell States Check    State=energySaving
    sleep    5    # waiting for the tEcuDelay timer expiry
    Delta Commission Parameters    NRBTS/NRPGRP-10:lbpsLastCellSOEnabled=false
    Cells Should Be OnAir
    Check Wireshark Log    ${CURDIR}${/}a2a_CB008951-B_01${/}a2a.ini    wait_string=ENDCConfigurationUpdateAcknowledge::2
    Stop Capture AP Wireshark

CB008951-C_ET_01_02_Inter-SgNB PSCell change due to NR cell is in EnergySaving status when CB009920 is deactivated
    [Tags]    CA_LABEL-TT(100MHz_TDD_n78+100MHz_TDD_n78)
    Start To Capture AP Wireshark
    Fallback Cells To Onair    ${reset_conf}
    Setup X2link between enb and 2 gnbs
    Check currently time and modify parameters under lbpsPeriodList
    Cell States Check    State=energySaving
    Change PScell fail due to NR cell is in EnergySaving status
    Check WireShark Log    ${CURDIR}${/}a2a_CB008951-C_02${/}a2a.ini    wait_string=ENDCConfigurationUpdateAcknowledge::4
    Stop Capture AP Wireshark

CB008951-C_ET_01_03_UE is configured as non-CA UE when scell is in EnergySaving status
    [Tags]    CA_LABEL-TT(100MHz_TDD_n78+100MHz_TDD_n78)
    Start To Capture AP Wireshark
    Fallback Cells To Onair    ${reset_conf}
    Check currently time and modify parameters under lbpsPeriodList
    OnlineParamChange    ${prepare_case03_precondition}
    Till Cell3 Enter PowerSaving
    Trigger UE Attach And Setup ENDC Without CA
    Stop Capture AP Wireshark

CB008951-C_ET_01_07_CB008951-C_ET_01_07_UE is configured as CA UE will be released when PSCell become EnergySaving
    [Tags]    CA_LABEL-TT(100MHz_TDD_n78+100MHz_TDD_n78)
    Start To Capture AP Wireshark
    Fallback Cells To Onair    ${reset_conf}
    Check currently time and modify parameters under lbpsPeriodList
    OnlineParamChange    ${prepare_case07_precondition}
    Trigger UE Attach And Setup ENDC With CA
    Till Cell1 Enter PowerSaving And SCG Fallback To MCG
    Stop Capture AP Wireshark

CB008951-C_ET_01_08_MeNB is informed that the NR cell is deleted when lock the energysaving cell
    [Tags]    CA_LABEL-TT(100MHz_TDD_n78+100MHz_TDD_n78)
    Start To Capture AP Wireshark
    Fallback Cells To Onair    ${reset_conf}
    Check currently time and modify parameters under lbpsPeriodList
    OnlineParamChange    ${prepare_case07_precondition}
    Cell States Check    State=energySaving
    Delta Commission Parameters    NRCELL-1:administrativeState=Locked
    Cell States Check    State=notEnergySaving
    Check WireShark Log    ${CURDIR}${/}a2a_CB008951-C_08${/}a2a.ini    wait_string=ENDCConfigurationUpdateAcknowledge::3
    Stop Capture AP Wireshark

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=${GNB1_CONFIG}
    Execute Cmd On PC    sudo ip addr add 10.0.1.102/24 dev eth3
    Execute Egate Command    trace_sim amf=1 on
    Execute Egate Command    sim_trace enb=3 protocol=xn on
    Execute Egate Command    sim_trace enb=1 protocol=x2 on
    Execute Egate Command    ue_change_location id=1-3 enb=2 cell=3
    Set UE Parameters Before Register

Set UE Parameters Before Register
    Execute Egate Command    qosflow_modify default=on qos_flow=1 priority=5
    Execute Egate Command    qosflow_modify qos_flow=2 priority=1
    Execute Egate Command    smf_param id=1 additional_qosflows_to_activate=2

Modify Cfg
    Update Cfg    enb_param id=1 drb_id_begin=3 endc_capable_qci=98
    Update Cfg    qci_set qci=98 gbr=no priority=9 delay=300    #get error KeyError: 'id' ,please add it manual
    Set Bear in WTS
    Set PDU Session in WTS
    Set Sim gNB
    Update Cfg    set_bearer id=2 ue=31 qci=98 pdn=1 ip=4.7.254.208 default=on ul_nat_gw=10.0.2.1 dl_nat_gw=10.0.2.1 trf_type=internal
    Update Cfg    set_nwslice id=1 snssai=0x01:0xd143a5 amf=1-2 default=on qos_flows=3,2,1 qos_rules=1,2 ue=all
    Update Cfg    ue_nr_capabilities id=1-9 voice_over_nr=on:on:off
    Update Cfg    amf_param id=1-2 full_nas_auth=on ims_voice_3gpp=on nia=null+zuc nea=null+zuc
    Update Cfg    ue_param id=31 ue_nr_capabilities=${ue_nr_capabilities} dual_conn=eutra_nr ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities}

Set Sim gNB
    ${cfg_cmd_1}    catenate
    ...    set_gnb id=3 type=simulated plmn=311:489 s1u=10.0.1.124 ng=10.0.1.123
    ...    gnb_id=0x24:22 daemon=10.0.2.1:22222 x2=10.0.1.126:36422 x2_peers=none xn=10.0.1.122 nssai=0x1:0xd143a5 amf=1
    ${cfg_cmd_2}    catenate
    ...    gnb_param id=3 x2_listening_socket=1 measEvent=A3
    ${cfg_cmd_3}    catenate
    ...    gnb_param id=3 xn_listening_socket=1 send_xn_setup=true measEvent=A3
    ${cfg_cmd_4}    catenate
    ...    set_cell id=1 gnb=3 pci=16:0 tac=788 nrci=0x01 tdd_cell=on proxy=10.0.2.92:9999 nr_arfcn=636666:636666 gscn=7880
    Update Cfg    ${cfg_cmd_1}
    Update Cfg    ${cfg_cmd_3}
    Update Cfg    ${cfg_cmd_4}

Set Bear in WTS
    ${cfg_cmd_3}    catenate
    ...    ul_nat_gw=10.0.2.1 dl_nat_gw=10.0.2.1 trf_type=internal
    FOR    ${ue_id}    IN RANGE    32    56
        Update Cfg    set_bearer id=2 ue=${ue_id} qci=9 pdn=1 ip=4.7.254.2${ue_id} default=on ${cfg_cmd_3}
        Update Cfg    set_bearer id=3 ue=${ue_id} qci=8 default=off
    END

Set PDU Session in WTS
    ${cfg_cmd}    catenate
    ...    qos_flows=3,2,1 qos_rules=1,2 ue=1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30
    Update Cfg    set_qosflow id=1 5qi=5 default=on
    Update Cfg    set_qosflow id=3 5qi=6 default=off
    Update Cfg    set_qosflow id=2 5qi=1
    Update Cfg    qosrule_set id=1 proto=tcp qos_flow=1
    Update Cfg    qosrule_set id=2 proto=udp qos_flow=2
    Update Cfg    set_nwslice id=1 snssai=0x01:0xd143a5 amf=1 default=on ${cfg_cmd}
    FOR    ${ue_id}    IN RANGE    2    31
        Update Cfg    set_pdu_gateway id=${ue_id} ue_nat_ip=72.23.0.${ue_id} dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    END

Check currently time and modify parameters under lbpsPeriodList
    ${date}    execute command on enb     date
    ${day_of_week}    set variable    ${date.split()[0]}
    ${hour}    set variable    ${date.split()[3].split(":")[0]}
    ${minute}    set variable    ${date.split()[3].split(":")[1]}
    @{modify_lbpsPeriodList}    create list
    ...    NRPGRP-10:lbpsPeriodList:lbpsStartTimeHour=${hour}|lbpsDayOfWeek=${day_of_week}
    ...    NRPGRP-10:lbpsPeriodList:lbpsStartTimeMinute=${minute}|lbpsDayOfWeek=${day_of_week}
    ...    NRPGRP-10:lbpsPeriodList:lbpsDuration=35|lbpsDayOfWeek=${day_of_week}
    ...    NRPGRP-10:lbpsPeriodList:lbpsSuspended=notSuspended|lbpsDayOfWeek=${day_of_week}
    Delta Commission Parameters    ${modify_lbpsPeriodList}

Register UE to gnb2 cell1
    Execute Egate Command    ue_change_location id=1 enb=2 cell=1
    Execute Egate Command    ue_register id=1    pass_regexp=UE now in NG RM Registered state

Cell States Check
    [Arguments]    ${cell_number}=1    ${State}=notEnergySaving    ${timeout}=600
    Object Should Exist    NRCELL-${cell_number}:energySavingState=${State}    timeout=${timeout}

Fallback Cells To Onair
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cell States Check    State=notEnergySaving
    Cells Should Be OnAir    check_sib=${False}

Setup X2link between enb and 2 gnbs
    Execute Egate Command    enb_x2_link_up enb=1 target=2    pass_regexp=X2AP Link with GNB-2 \\(10.0.1.2:36422\\[0\\]\\) is up
    Execute Egate Command    enb_x2_link_up enb=1 target=3    pass_regexp=X2AP Link with GNB-3 \\(10.0.1.126:36422\\[0\\]\\) is up

Change PScell fail due to NR cell is in EnergySaving status
    UE Attach And Trigger To Setup ENDC
    ${ret}=    Execute Egate Command    gnb_ue_dc_change ue=31 gnb=2 target_sgnb_cells=1 cause=RN_sCG_Mobility
    ...    pass_regexp=${case02_pass_list}

UE Attach To ENB
    [Arguments]    ${ue_id}=31
    Execute Egate Command    enb_endc_param id=1 serving_cell_index_range_scg=8:14
    Execute Egate Command    ue_attach id=${ue_id}    pass_regexp=UE IS ACTIVE

UE Attach And Trigger To Setup ENDC
    [Arguments]    ${ue_id}=31
    UE Attach To ENB
    Execute Egate Command    ue_dc_enb_start ue=${ue_id} target_gnb=3 target_cells=1 bearer=2 type=split_scg
    ...    pass_regexp=Bearer-type change from MCG to SCG-split

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir    check_sib=${False}    cell_id=3

Till Cell3 Enter PowerSaving
    [Arguments]    ${State}=energySaving
    Cell States Check    State=${State}    cell_number=3

Trigger UE Attach And Setup ENDC Without CA
    [Arguments]    ${ue_id}=31
    UE Attach To ENB    ${ue_id}
    ${ret}    Execute Egate Command    ue_dc_enb_start ue=31 target_gnb=2 target_cells=1 bearer=2 type=split_scg    pass_regexp=${case03_pass_list}
    Should Not Contain    ${ret}    sCellToAddModList

Trigger UE Attach And Setup ENDC With CA
    [Arguments]    ${ue_id}=31
    UE Attach To ENB    ${ue_id}
    ${ret}    Execute Egate Command    ue_dc_enb_start ue=31 target_gnb=2 target_cells=1 bearer=2 type=split_scg    pass_regexp=${case07_pass_list}

Till Cell1 Enter PowerSaving And SCG Fallback To MCG
    [Arguments]    ${State}=energySaving
    Cell States Check    State=${State}    cell_number=1
    RRC Should Contain    Bearer-type change from SCG-split to MCG is successful
    RRC Should Contain    deactivated

Start To Capture AP Wireshark
   execute cmd on wts      nohup tcpdump -i br0 -vvv -s3000 -A -w /tmp/madani_rfh4.pcap > /tmp/nohup_w1.out 2>&1 &

Stop Capture AP Wireshark
   execute cmd on wts     pkill tcpdump
   get wts file    /tmp/madani_rfh4.pcap    ${SAVE LOG DIRECTORY}