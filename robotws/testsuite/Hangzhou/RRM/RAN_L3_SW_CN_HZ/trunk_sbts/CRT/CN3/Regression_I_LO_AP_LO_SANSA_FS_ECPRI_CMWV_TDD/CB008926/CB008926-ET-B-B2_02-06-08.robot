*** Settings ***
Suite Setup       Common Suite Setup And Setup IPHY Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CRT_no_cloud    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...               team-DevHZ5_SG1    owner-tom.li    release-SBTS23R3
Resource          ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
${GNB1_CONFIG}    tdd_sansa_cmwv/FS/3cells_ecpri
${uplane_6878}    0x5901AB=1
${BTS_INFO.LNBTS}    NRBTS-2
@{PARAMS_IN_SWCONFIG}
...    ${rdPCsiPoolHkfPeriod_min}
...    ${rdHkfMinPCsiResPerSlot}
...    ${rdHkfMinPCsiRepPeriod}
...    ${rdHkfPCsiPoolMaxRCUsFactor}
...    ${uplane_6878}
...    ${rdPCsiPoolHkfRate_millisec}
...    @{l2psRD}
#...    ${rdEnableTrafficManager}
#...    ${rdEnableUeIdRangeAllocationViaSdl}
#...    ${rdEnableUeMappingRemovalFromCpIf}

@{l2psRD}
...    0x58057b=16842887
...    0x58057c=278396928
...    0x58057d=606077441
...    0x58057e=2

@{FAULTS_EXCLUDED_CHECKING}    7315
${rdPCsiPoolHkfRate_millisec}    0x5901B2=3000
${rdPCsiPoolHkfPeriod_min}    0x5901A6=2
${rdHkfMinPCsiResPerSlot}    0x5901A7=8
${rdHkfMinPCsiRepPeriod}    0x5901A8=40
${rdHkfPCsiPoolMaxRCUsFactor}    0x5901A9=6
${rdEnableTrafficManager}     0x89001C=0
${rdEnableUeIdRangeAllocationViaSdl}     0x89001D=0
${rdEnableUeMappingRemovalFromCpIf}     0x89001E=1

@{PARAMS_IN_SCF}
...    @{CB006878}
...    @{5GC000704}
...    @{5GC00572}
...    @{interGnbHO}
...    @{beamforming}
...    ${actFdmEnhancedScheduling}
...    @{uplink_share_related_params_3_10}
...    @{interFreqHoSA}
...    @{CA}
...    @{reestablish_SA_enable}
...    @{longerRRCGurad}
...    @{ueInactivityTimer}
...    @{CB008962}
...    @{actVonr}
...    @{ngcFlexDelta}

@{CB008962}
...    NRBTS:actNsaSlice=true
...    NRBTS/NRDRB_QCI-98:nrDrbDN=MRBTS-1/NRBTS-2/NRDRB-6
...    NRBTS/NRDRB_QCI-98:qciValueList=98
...    NRBTS/NRNWSLICE_NSA-1:nrPlmnDN=MRBTS-1/NRBTS-2/NRPLMN-1
...    NRBTS/NRNWSLICE_NSA-1:operatorSpecificQCIList=98
...    NRBTS/NRNWSLICE_NSA-1:s1Uplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRBTS:cuUeIdToLinkMappingUpdateDelay=500ms

@{ueInactivityTimer}    NRBTS:srbInactivityTimerSA=600

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
...    NRBTS/TRACKINGAREA-200:fiveGsTac=788
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
...    NRCELL-3/NRHOIF-1:chBw=20MHz
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

@{CB006878}
...    NRCELL-1:actDynUlResAlloc=true
...    NRCELL-2:actDynUlResAlloc=true
...    NRCELL-3:actDynUlResAlloc=true
...    NRCELL:srPeriodicity=slots80
...    NRCELL:periodicCsiAcquisition:csiReportPeriodicity=slots40
...    NRCELL:reqMinNumPuschPrb=247
...    NRCELL:pucchModeSelect=longPucch
...    NRCELL-1:periodicCsiAcquisition:csiReportPeriodicity=slots20
...    NRCELL-2:periodicCsiAcquisition:csiReportPeriodicity=slots320
...    NRCELL-3:periodicCsiAcquisition:csiReportPeriodicity=slots40

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
...    NRCELL-1/NRHOIF-1:chBw=20MHz
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
...    NRBTS/NRDU-1:carrierAggregationSupportList=ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Any_Sa
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

@{reestablish_SA_enable}
...    NRBTS-2:rrcReestabTypeSA=sameGNB
...    NRBTS-2:tWaitingRlRecover=5000ms
...    NRBTS-2:tWaitingRlRecoverSA=5000ms
...    NRBTS-2:tRLFindForDUSA=2000ms

@{uplink_share_related_params_3_10}
...    NRCELL:actInfTddFrameMuting=true
...    NRCELL:infTddFrameStructure:infTddFrameMutingBiAgreement=true
...    NRCELL:tddFrameStructure:frameStructureType=semiStatic
...    NRCELL:tddFrameStructure:guardPeriodLength=2Symbols
...    NRCELL:tddFrameStructure:tdLteUlDlConfig=tdLteConfig2
...    delete:NRCELL:tddFrameStructure:lteToNrFrameShift
...    NRCELL:prachConfigurationIndex=100
...    NRCELL:tddFrameStructure:ulDlDataSlotRatio=3/7

${ue_nr_capabilities}    SEPARATOR=
...    E1A03FA0474E7AEFFFFFAFC2200782E0203C127BE7FFFFF800F00C6FBE00050370101F8E0155DF0A3FE2F08762F82087F540A083D951D2206
...    24FAC41E420F081425BE7E57771DF001DDC77C000CC005000742AEF851FF17843B17C1043FAA05041ECA8E9103127D620F2107840A12DF3F3
...    3BB8EF800EEE3BE000660028003A1577C4DFF8BC21D8BE0821FD502820F65474881893EB1079083C205096F9F95DFC7FC0077F1FF00033001
...    4001D00650389A000000C40A83C4D000C2680004C40AC1C4D080004620540E268400033102B070A0200021881507850001828000298810090
...    0A2026C04605000C2508206811B649F0214285B24F810236C93E04085B24F810276C93E042853B649F000160C318C631BFFFE000138036002
...    800301C1401C0C4270070007000603E0488200000041000002208004000004100080000882001004001040020080220800402008410008040
...    188200100C021040020180601B072F2A2B072F2A28060800004B2CA82000032CB2A0800014B2CA02000072CB2801A83D5D2AAAA0F174AA283
...    839804F9BF01C070079BF01C070079BF01C070079BF01C070079BF01C070079BF01C070079BF01C070079BF01C070079BF01C070079BF01C0
...    700001400600400C010020808020040200801001C0180180400300A00A01801001C0180380400700A01201802001C0380180800301200A028
...    01041C0080180100300400A0080103801001004002004004010001AB0602072125262728770000000361781C06000601A

${actFdmEnhancedScheduling}    NRBTS-2:actFdmEnhancedScheduling=true

@{beamforming}
...    NRCELL:actBeamforming=false
...    NRBTS:actChannelMapVal=Disabled
...    NRCELL:beamSet:nrBtsBeamRefinementP2=false
...    NRCELLGRP-0:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-1:beamSet:basicBeamSet=beamSet_1
...    NRCELL:actPerCsiReportBundlingTddFr1=false

@{longerRRCGurad}    ${BTS_INFO.LNBTS}:timerRRCGuard=6000

@{actVonr}
...    NRCELL-3:actVoNR=true
...    NRBTS/NRDRB-12:discardTimer=10ms
...    NRBTS/NRDRB-12:dlFlowControlAlgo=none
...    NRBTS/NRDRB-12:nrDrbMacDN=MRBTS-1/NRBTS-2/NRDRB_MAC-4
...    NRBTS/NRDRB-12:nrDrbRlcUmDN=MRBTS-1/NRBTS-2/NRDRB_RLC_UM-1
...    NRBTS/NRDRB-12:queuingDelayDiscarding=Disabled
...    NRBTS/NRDRB-12:resType=GBR
...    NRBTS/NRDRB-12:rlcMode=RLC_UM
...    NRBTS/NRDRB_5QI-3:fiveqiValueList=1
...    NRBTS/NRDRB_MAC-4:lcgid=4
...    NRBTS/NRDRB_MAC-4:prioritisedBitRate=16kBps
...    NRBTS/NRDRB_MAC-4:schedulBSD=50ms
...    NRBTS/NRDRB_MAC-4:schedulPrio=12
...    NRBTS/NRDRB_PDCP-2:pdcpBufDiscardEnabled=false
...    NRBTS/NRDRB_RLC_UM-1:dlTReassemblyUm=ms50
...    NRBTS/NRDRB_RLC_UM-1:rlcUMDrbSNLength=rlcUm12bitSN
...    NRBTS/NRDRB_RLC_UM-1:ulTReassemblyUm=ms50

@{ngcFlexDelta}
...    NRBTS:actNrpmqapProfiles=true
...    NRBTS/NRPMRNL-1/NRPMQAP-1:cfg5qiRange=1-9
...    NRBTS/NRPMRNL-1/NRPMQAP-1:cfgProfType=both
...    NRBTS:actNgcFlexSaMode=false
...    NRBTS/SERVEDAMF-2:administrativeState=Unlocked
...    NRBTS/SERVEDAMF-2:amfIPAddress=10.0.1.102
...    NRBTS/SERVEDAMF-2:defaultAMF=false

*** Test Cases ***
CB008926-SR-B-B2_ET_01_02_sgNB release with valid MeNB X2AP ID and invalid SgNB X2AP ID can be handled correctly in classical gNB
    [Tags]
    ${ue31_MeNB_X2APID}    ${ue31_sgNB_X2APID}    NSA UE ICS and setup ENDC to TargetGnbCell    ue_id=31    target_gnbCell=1
    ${ue32_MeNB_X2APID}    ${ue32_sgNB_X2APID}    NSA UE ICS and setup ENDC to TargetGnbCell    ue_id=32    target_gnbCell=1
    trigger ENDC release with invalid sgnb_ue_id    MeNB_X2APID=${ue31_MeNB_X2APID}
    Set Test Variable    \${ue31_sgNB_X2APID}    ${ue31_sgNB_X2APID}
    Release Ues    ue_type=all
    Check WireShark Log    ${CURDIR}${/}A2A_B-B2-02${/}a2a.ini    wait_string=UEContextReleaseCommand::4

CB008926-SR-B-B2_ET_01_06_PDU modification request with invalid AMF NGAP ID and invalid RAN NGAP ID can be handled correctly in classical gNB
    [Tags]
    ${AMF_UE_NGAP_ID_UE1_2}    ${RAN_UE_NGAP_ID_UE1_2}    UE ICS success    ue_id=1    pdu_id=1    gw=1
    ${AMF_UE_NGAP_ID_UE2_2}    ${RAN_UE_NGAP_ID_UE2_2}    UE ICS success    ue_id=2    pdu_id=1    gw=2
    trigger PDU session modify with invalid remote and local ue id
    Release Ues    ue_type=all
    Check WireShark Log    ${CURDIR}${/}A2A_B-B2-06${/}a2a.ini    wait_string=UEContextReleaseCommand::8

CB008926-SR-B-B2_ET_01_08_PDU Setup Request with duplicated AMF NGAP ID can be handled correctly in classical gNB
    [Tags]
    ${AMF_UE_NGAP_ID_UE1_3}    ${RAN_UE_NGAP_ID_UE1_3}    UE ICS success    ue_id=1    pdu_id=1    gw=1
    trigger UE2 ICS with duplicated remote ue id
    Set Test Variable    \${AMF_UE_NGAP_ID_UE1_3}    ${AMF_UE_NGAP_ID_UE1_3}
    Release Ues    ue_type=all
    Check WireShark Log    ${CURDIR}${/}A2A_B-B2-08${/}a2a.ini    wait_string=UEContextReleaseCommand::8

*** Keywords ***
Common Suite Setup And Setup IPHY Env
    Common Suite Setup
    Setup Airphone Env    tl_type=${GNB1_CONFIG}
    Execute Cmd On PC    sudo ip addr add 10.0.1.102/24 dev eth3
    Execute Egate Command    trace_sim amf=1 on
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
    Update Cfg    ue_param id=1-3 ue_nr_capabilities=${ue_nr_capabilities}
    Update Cfg    set_bearer id=2 ue=31 qci=98 pdn=1 ip=4.7.254.208 default=on ul_nat_gw=10.0.2.1 dl_nat_gw=10.0.2.1 trf_type=internal
    Update Cfg    set_bearer id=2 ue=32 qci=98 pdn=1 ip=4.7.254.232 default=on ul_nat_gw=10.0.2.1 dl_nat_gw=10.0.2.1 trf_type=internal
    Update Cfg    set_bearer id=2 ue=33 qci=98 pdn=1 ip=4.7.254.233 default=on ul_nat_gw=10.0.2.1 dl_nat_gw=10.0.2.1 trf_type=internal
    Update Cfg    set_bearer id=2 ue=34 qci=98 pdn=1 ip=4.7.254.234 default=on ul_nat_gw=10.0.2.1 dl_nat_gw=10.0.2.1 trf_type=internal
    Update Cfg    set_nwslice id=1 snssai=0x01:0xd143a5 amf=1-2 default=on qos_flows=3,2,1 qos_rules=1,2 ue=all
    Update Cfg    ue_nr_capabilities id=1-9 voice_over_nr=on:on:off
    Update Cfg    amf_param id=1-2 full_nas_auth=on ims_voice_3gpp=on nia=null+zuc nea=null+zuc

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

UE Register To GNB
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Reg

UE ICS success
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${gw}=1
    [return]    ${AMF_UE_NGAP_ID_UE[0]}    ${RAN_UE_NGAP_ID_UE[0]}
    UE Register To GNB    ue_id=${ue_id}
    ${ret}    Execute Egate Command    ue_pdu_session_setup pdu=${pdu_id} ue=${ue_id} nwslice=1 gw=${gw}    pass_regexp=QoS Routing Table
    ${AMF_UE_NGAP_ID_UE}    Get Regexp Matches    ${ret}    value AMF-UE-NGAP-ID : (\\d+)    1
    ${RAN_UE_NGAP_ID_UE}    Get Regexp Matches    ${ret}    value RAN-UE-NGAP-ID : (\\d+)    1

NSA UE ICS and setup ENDC to TargetGnbCell
    [Arguments]    ${ue_id}    ${target_gnbCell}
    [Return]    ${MeNB_x2apIDList[0]}    ${sgNB_x2apIDList[0]}
    UE Attach To ENB    ${ue_id}
    ${output}    Execute Egate Command    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${target_gnbCell} bearer=2 type=split_scg
    ...    pass_regexp=SgNBAdditionRequestAcknowledge
    ${MeNB_x2apIDList}    Get Regexp Matches    ${output}    value UE-X2AP-ID : (\\d+)    1
    ${sgNB_x2apIDList}    Get Regexp Matches    ${output}    value SgNB-UE-X2AP-ID : (\\d+)    1

UE Attach To ENB
    [Arguments]    ${ue_id}=31
    Execute Egate Command    ue_attach id=${ue_id}    pass_regexp=UE IS ACTIVE

trigger ENDC release with invalid sgnb_ue_id
    [Arguments]    ${MeNB_X2APID}=1
    Execute Egate Command    enb_ue_dc_release ue=31 by=enb cause=RN_user_inactivity menb_ue_x2ap_id=${MeNB_X2APID} sgnb_ue_x2ap_id=125
    ...    pass_regexp=UE31: IS IDLE

trigger PDU session modify with invalid remote and local ue id
    Execute Egate Command    amf_ue_pdu_modify_param id=1 ue=2 action=override_ie amf_ue_id=25 ran_ue_id=25 nth=1
    Execute Egate Command    ue_pdu_session_modify ue=2 pdu=1 qosflows_to_add=3 by=amf    pass_regexp=NgLink::OnReceiveErrorIndication

trigger UE2 ICS with duplicated remote ue id
    Execute Egate Command    amf_ue_ics_param id=1 ue=2 action=use_duplicate_amf_ue_ngap_id
    UE Register To GNB    ue_id=2
    Execute Egate Command    ue_pdu_session_setup pdu=1 ue=2 nwslice=1 gw=2    pass_regexp=UE1: IS IDLE
