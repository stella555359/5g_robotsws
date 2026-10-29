*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CRT    CLOUD_5G_I_[LO][LO]_AP_[LOO]_SANSA_FS_ECPRI_CMWV_TDD
...    owner-susana.yan    release-SBTS23R3    team-L3CN1_SG14
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${NOKIA_XNAP_PLUGIN_FLAG}    ${True}
${NOKIA_F1AP_PLUGIN_FLAG}    ${True}

@{PARAMS_IN_SCF}
...    @{PARAMS_FOR_CA}
...    @{DSS_BWP_PROFILES}
...    @{DSS_NRSYSINFO_PROFILE}
...    @{DSS_CELL_CONFIG}
...    @{DSS_CELL_NRDSSLTE}
...    @{DSS_XPAP}
...    @{PARAMS_FOR_GNB1}
...    @{PARAMS_ADJ_REL_FOR_GNB1}
...    @{PARAMS_FOR_OTHERS}

@{PARAMS_IN_SCF_GNB2}
...    @{PARAMS_FOR_CA}
...    @{DSS_BWP_PROFILES}
...    @{DSS_NRSYSINFO_PROFILE_ExtGnb}
...    @{DSS_XPAP_ExtGnb}
...    @{PARAMS_FOR_GNB2}
...    @{PARAMS_ADJ_REL_FOR_GNB2}
...    @{PARAMS_FOR_OTHERS}

@{PARAMS_FOR_CA}
#actOptimizedFlowControl should be set to optimizedAllUe to enable flow control on scells when DSS enabled
...    NRCELL:actOptimizedFlowControl=optimizedAllUe
...    NRBTS:actCarrierAggregation=true
...    NRBTS:sCellActivationMethod=bufferBased
...    NRBTS:caConfigurationSupport=4CCDL_2CCUL
...    NRBTS:weightForIgnbCaSelection=20
...    NRBTS:actIncXn=true
...    NRBTS:maxNumScellsDl=2
...    NRBTS:maxNumScellsUl=2
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:carrierAggregationSupportList=ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Any_Sa,ca_Fdd_Any_Sa,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Fdd
...    NRBTS:actFdmEnhancedScheduling=true
...    NRBTS:actFdmScheduling=true
...    NRBTS:actLteNrDss=true
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRDU-1:actInterGnbCa=DLOnly
...    NRDU-1:dlToUlContributionRatio=101
...    NRCELL:actK1Opt=intraAndInter-gNB
...    NRCELL:maxNumScellsDlFr1=3

@{PARAMS_FOR_GNB1}
...    NRBTS:actPdcpRlcBufCongestionMechsm=gbrNonGbr
...    NRBTS:numNonGbrPdcpSduDiscard=5
...    NRBTS:numNonGbrRlcSduDiscard=5
...    NRBTS:rlcBufUsageThreshold=95
...    NRBTS:pdcpBufUsageThreshold=95
...    NRCELL:nrCellType=2DL2UL
...    NRCELL:dlMimoMode=2x2 Open Loop Spatial Multiplexing
...    NRDU-1:xgUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRBTS:actInterFreqHoSA=true
...    NRCELL-12/NRREL-11:gNbId=2
...    NRCELL-12/NRREL-11:gNbIdLength=22
...    NRCELL-12/NRREL-11:handoverAllowedSA=allowed
...    NRCELL-12/NRREL-11:lcrId=11
...    NRCELL-12/NRREL-11:removeNotAllowed=false
...    NRCELL-12/NRREL-11:sCellAdditionMethod=blind
...    NRCELL-12/NRREL-11:sCellOperationalMode=dlOnly
...    NRCELL-12/NRREL-11:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-11:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-11:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-12:gNbId=2
...    NRCELL-11/NRREL-12:gNbIdLength=22
...    NRCELL-11/NRREL-12:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-12:lcrId=12
...    NRCELL-11/NRREL-12:removeNotAllowed=false
...    NRCELL-11/NRREL-12:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-12:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-12:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-12:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-12:gnbPlmn:mncLength=3
...    NRPMRNL-1:miNrRelReportCu=5min
...    NRPMRNL-1:miNrInterGnbMobilityNsaPmqap=disabled
...    NRPMRNL-1:miNrInterGnbNgMobilitySaPmqap=disabled
...    NRPMRNL-1:miNrInterGnbXnMobilitySaPmqap=disabled
...    NRPMRNL-1:miNrIntraGnbMobilityNsaPmqap=disabled
...    NRPMRNL-1:miNrIntraGnbMobilitySaPmqap=disabled
...    NRPMRNL-1:miNrNgcFlexInterface=disabled
...    NRCELL-11:sCellDeactivationTimerGNB=ms1280
...    NRCELL-12:sCellDeactivationTimerGNB=ms1280
...    NRCELL-11:measGapSelectionSA=favourUeThroughput
...    NRCELL-12:measGapSelectionSA=favourUeThroughput
...    NRCELL-11:a1MeashoEnabledSA=rsrp
...    NRCELL-11:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRCELL-11:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=60
...    NRCELL-11:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL-12:a1MeashoEnabledSA=rsrp
...    NRCELL-12:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRCELL-12:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=60
...    NRCELL-12:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL-11/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-11/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-11/NRHOIF-1:freqBandIndicatorNR=3
...    NRCELL-11/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-11/NRHOIF-1:ifhoSsbSmtcDuration=sf2
...    NRCELL-11/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf20
...    NRCELL-11/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-11/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-11/NRHOIF-1:ssbFrequency=373970
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms1024
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=4
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL-12/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-12/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-12/NRHOIF-1:freqBandIndicatorNR=3
...    NRCELL-12/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-12/NRHOIF-1:ifhoSsbSmtcDuration=sf2
...    NRCELL-12/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf20
...    NRCELL-12/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-12/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-12/NRHOIF-1:ssbFrequency=363850
...    NRCELL-12/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms1024
...    NRCELL-12/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=4
...    NRCELL-12/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=10

@{PARAMS_ADJ_REL_FOR_GNB1}
...    NRBTS:iGnbCaXnCfUpBackOffTmr=60
...    NRBTS:iGnbCaXnSetupReqTmr=60
...    NRBTS:iGnbCaXnSetupRespTmr=60
...    NRBTS:intGnbScellTempBlockTmr=60
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRCELL:a1MeasSCellAddEnabled=rsrpAndRsrq
...    NRCELL:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=31
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=111
...    NRCELL:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrq:a1HysteresisSCellAddSsbRsrq=0
...    NRCELL:a1MeasSCellAddSsbRsrq:a1ThresholdSCellAddSsbRsrq=30
...    NRCELL:a1MeasSCellAddSsbRsrq:a1TimeToTriggerSCellAddSsbRsrq=160ms
...    NRBTS/NRADJGNB-3:administrativeState=Unlocked
...    NRBTS/NRADJGNB-3:gNbIdLength=22
...    NRBTS/NRADJGNB-3:gNodeBId=3
...    NRBTS/NRADJGNB-3:weightForIgnbCaSelection=50
...    NRBTS/NRADJGNB-3:xnLinkRef=1
...    NRBTS/NRADJGNB-3:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-3:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-3:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-1:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-1:fiveGsTac=200
...    NRBTS/NRADJNRCELL-1:freqBandIndicatorNR=77
...    NRBTS/NRADJNRCELL-1:gNbId=3
...    NRBTS/NRADJNRCELL-1:gNbIdLength=22
...    NRBTS/NRADJNRCELL-1:lcrId=1
...    NRBTS/NRADJNRCELL-1:nrarfcn=663400
...    NRBTS/NRADJNRCELL-1:ssbFrequency=663360
...    NRBTS/NRADJNRCELL-1:physCellId=50
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-2:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-2:fiveGsTac=200
...    NRBTS/NRADJNRCELL-2:freqBandIndicatorNR=77
...    NRBTS/NRADJNRCELL-2:gNbId=3
...    NRBTS/NRADJNRCELL-2:gNbIdLength=22
...    NRBTS/NRADJNRCELL-2:lcrId=2
...    NRBTS/NRADJNRCELL-2:nrarfcn=658000
...    NRBTS/NRADJNRCELL-2:ssbFrequency=657984
...    NRBTS/NRADJNRCELL-2:physCellId=51
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-13:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-13:fiveGsTac=200
...    NRBTS/NRADJNRCELL-13:freqBandIndicatorNR=3
...    NRBTS/NRADJNRCELL-13:gNbId=3
...    NRBTS/NRADJNRCELL-13:gNbIdLength=22
...    NRBTS/NRADJNRCELL-13:lcrId=13
...    NRBTS/NRADJNRCELL-13:nrarfcn=368400
...    NRBTS/NRADJNRCELL-13:physCellId=62
...    NRBTS/NRADJNRCELL-13:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-13:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-13:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-14:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-14:fiveGsTac=200
...    NRBTS/NRADJNRCELL-14:freqBandIndicatorNR=28
...    NRBTS/NRADJNRCELL-14:gNbId=3
...    NRBTS/NRADJNRCELL-14:gNbIdLength=22
...    NRBTS/NRADJNRCELL-14:lcrId=14
...    NRBTS/NRADJNRCELL-14:nrarfcn=153400
...    NRBTS/NRADJNRCELL-14:ssbFrequency=153370
...    NRBTS/NRADJNRCELL-14:physCellId=63
...    NRBTS/NRADJNRCELL-14:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-14:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-14:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-1:gNbId=3
...    NRCELL-11/NRREL-1:gNbIdLength=22
...    NRCELL-11/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-1:lcrId=1
...    NRCELL-11/NRREL-1:removeNotAllowed=false
...    NRCELL-11/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-1:gNbId=3
...    NRCELL-12/NRREL-1:gNbIdLength=22
...    NRCELL-12/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-12/NRREL-1:lcrId=1
...    NRCELL-12/NRREL-1:removeNotAllowed=false
...    NRCELL-12/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-12/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-12/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-2:gNbId=3
...    NRCELL-12/NRREL-2:gNbIdLength=22
...    NRCELL-12/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-12/NRREL-2:lcrId=2
...    NRCELL-12/NRREL-2:removeNotAllowed=false
...    NRCELL-12/NRREL-2:sCellAdditionMethod=blind
...    NRCELL-12/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-12/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-13:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-13:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-13:gNbId=3
...    NRCELL-12/NRREL-13:gNbIdLength=22
...    NRCELL-12/NRREL-13:handoverAllowedSA=allowed
...    NRCELL-12/NRREL-13:lcrId=13
...    NRCELL-12/NRREL-13:removeNotAllowed=false
...    NRCELL-12/NRREL-13:sCellAdditionMethod=blind
...    NRCELL-12/NRREL-13:sCellOperationalMode=dlOnly
...    NRCELL-12/NRREL-13:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-13:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-13:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-14:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-14:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-14:gNbId=3
...    NRCELL-12/NRREL-14:gNbIdLength=22
...    NRCELL-12/NRREL-14:handoverAllowedSA=allowed
...    NRCELL-12/NRREL-14:lcrId=14
...    NRCELL-12/NRREL-14:removeNotAllowed=false
...    NRCELL-12/NRREL-14:sCellAdditionMethod=blind
...    NRCELL-12/NRREL-14:sCellOperationalMode=dlOnly
...    NRCELL-12/NRREL-14:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-14:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-14:gnbPlmn:mncLength=3
...    NRCELL-12:msg1FrequencyStart=10
...    NRCELL:a2MeashoEnabledSA=rsrpAndRsrq
...    NRCELL:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0
...    NRCELL:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=34
...    NRCELL:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL:a2MeashoSsbRsrqSA:a2HysteresishoSsbRsrqSA=0
...    NRCELL:a2MeashoSsbRsrqSA:a2ThresholdhoSsbRsrqSA=49
...    NRCELL:a2MeashoSsbRsrqSA:a2TimeToTriggerhoSsbRsrqSA=ms480
...    NRCELL:a3MeasEnabled=rsrp
...    NRCELL:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL:a3MeasSsbRsrp:a3OffsetSsbRsrp=30
...    NRCELL:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms40

@{PARAMS_FOR_GNB2}
...    NRBTS:actPdcpRlcBufCongestionMechsm=gbrNonGbr
...    NRBTS:numNonGbrPdcpSduDiscard=5
...    NRBTS:numNonGbrRlcSduDiscard=5
...    NRBTS:rlcBufUsageThreshold=95
...    NRBTS:pdcpBufUsageThreshold=95
...    MNL-1/MNLENT-1/XPAP-1/XPIF-1:localNeDN=MRBTS-2/NRBTS-3
...    NRDU-1:xgUplane:ipV4AddressDN1=MRBTS-2/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRBTS:iGnbCaXnCfUpBackOffTmr=60
...    NRBTS:iGnbCaXnSetupReqTmr=90
...    NRBTS:iGnbCaXnSetupRespTmr=60
...    NRBTS:intGnbScellTempBlockTmr=60
...    NRCELL-1:sCellDeactivationTimerGNB=ms1280
...    NRCELL-1:tddFrameStructure:frameStructureType=tdLte
...    NRCELL-1:tddFrameStructure:guardPeriodLength=6Symbols
...    NRCELL-1:tddFrameStructure:lteToNrFrameShift=0ms
...    NRCELL-1:tddFrameStructure:tdLteUlDlConfig=tdLteConfig2
...    NRCELL-1:prachConfigurationIndex=158
...    NRCELL-2:sCellDeactivationTimerGNB=ms1280
...    NRCELL-2:tddFrameStructure:frameStructureType=semiStatic
...    NRCELL-2:tddFrameStructure:guardPeriodLength=4Symbols
...    NRCELL-2:tddFrameStructure:ulDlDataSlotRatio=4/6
...    NRCELL-13:sCellDeactivationTimerGNB=ms1280
...    NRCELL-14:sCellDeactivationTimerGNB=ms1280
...    NRCELL-1:weightForSCellSelection=50
...    NRCELL-2:weightForSCellSelection=50
...    NRCELL-13:weightForSCellSelection=50
...    NRCELL-14:weightForSCellSelection=50

@{DSS_BWP_PROFILES}    @{BWP_PROFILE_8}    @{BWP_PROFILE_33}
@{BWP_PROFILE_8}
...    NRBTS/BWP_PROFILE-8:bwpType=initial
...    NRBTS/BWP_PROFILE-8:locationAndBandwidthDl:cRbSizeDl=coreset0
...    NRBTS/BWP_PROFILE-8:locationAndBandwidthDl:cRbStartDl=coreset0
...    NRBTS/BWP_PROFILE-8:locationAndBandwidthUl:cRbSizeUl=n73
...    NRBTS/BWP_PROFILE-8:locationAndBandwidthUl:cRbStartUl=crb6
...    NRBTS/BWP_PROFILE-8/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-8/PDCCH-1:dciDedicatedAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-8/PDCCH-1:dciPagingAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-8/PDCCH-1:dciRaCompletionAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-8/PDCCH-1:dciRaMsg2AggregationLevel=AL4
...    NRBTS/BWP_PROFILE-8/PDCCH-1:dciSiAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-8/PDCCH-1:downgradeAL16toAL8=notAllowed
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=1
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_2|searchSpaceId=1
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=1
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl80|searchSpaceId=1
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=1
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=47|searchSpaceId=1
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_2|searchSpaceId=2
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=2
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|searchSpaceId=2
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=6|searchSpaceId=2
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=3
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_2|searchSpaceId=3
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=3
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl40|searchSpaceId=3
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=3
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=27|searchSpaceId=3

@{BWP_PROFILE_33}
...    NRBTS/BWP_PROFILE-33:bwpType=dedicated
...    NRBTS/BWP_PROFILE-33:locationAndBandwidthDl:cRbSizeDl=allRb
...    NRBTS/BWP_PROFILE-33:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-33:locationAndBandwidthUl:cRbSizeUl=allRb
...    NRBTS/BWP_PROFILE-33:locationAndBandwidthUl:cRbStartUl=crb0
...    NRBTS/BWP_PROFILE-33/PDSCH-1:pdschId=1
...    NRBTS/BWP_PROFILE-33/PDSCH-1:pdschRat0RbgConfig=config1
...    NRBTS/BWP_PROFILE-33/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-33/PDCCH-1:dciDedicatedAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-33/PDCCH-1:dciPagingAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-33/PDCCH-1:dciRaCompletionAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-33/PDCCH-1:dciRaMsg2AggregationLevel=AL4
...    NRBTS/BWP_PROFILE-33/PDCCH-1:dciSiAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-33/PDCCH-1:downgradeAL16toAL8=notAllowed
...    delete: NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1/coresetCommon
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=4
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_2|searchSpaceId=4
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=4
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl80|searchSpaceId=4
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=4
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=47|searchSpaceId=4
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_2|searchSpaceId=5
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=5
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|searchSpaceId=5
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=6|searchSpaceId=5
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=6
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_2|searchSpaceId=6
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=6
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl40|searchSpaceId=6
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=6
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=27|searchSpaceId=6
...    delete: NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1/coresetCommon
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cceToRegMapping=nonInterleaved
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:coresetId=4
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cRbStart=6
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:duration=1
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:interleaverSize=none
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:regBundleSize=n6
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=72
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-0-And-1-0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|searchSpaceId=7
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_2|searchSpaceId=7
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|searchSpaceId=7
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl10|searchSpaceId=7
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|searchSpaceId=7
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=6|searchSpaceId=7
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=0|searchSpaceId=8
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|searchSpaceId=8
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|searchSpaceId=8
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_2|searchSpaceId=8
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|searchSpaceId=8
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceId=8
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|searchSpaceId=8
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|searchSpaceId=8
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceId=8
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl10|searchSpaceId=8
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|searchSpaceId=8
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=6|searchSpaceId=8
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|searchSpaceId=9
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|searchSpaceId=9
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_2|searchSpaceId=9
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|searchSpaceId=9
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl20|searchSpaceId=9
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|searchSpaceId=9
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=7|searchSpaceId=9
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=4|searchSpaceId=10
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-0-And-1-0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=8|searchSpaceId=10
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_2|searchSpaceId=10
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n3|searchSpaceId=10
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl10|searchSpaceId=10
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|searchSpaceId=10
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=8|searchSpaceId=10
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=4|searchSpaceId=11
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|searchSpaceId=11
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=8|searchSpaceId=11
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_2|searchSpaceId=11
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n3|searchSpaceId=11
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl10|searchSpaceId=11
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|searchSpaceId=11
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=8|searchSpaceId=11
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=4|searchSpaceId=12
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|searchSpaceId=12
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|searchSpaceId=12
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_2|searchSpaceId=12
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|searchSpaceId=12
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceId=12
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|searchSpaceId=12
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n3|searchSpaceId=12
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceId=12
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl20|searchSpaceId=12
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|searchSpaceId=12
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=17|searchSpaceId=12

@{DSS_XPAP}
...    MNL-1/MNLENT-1/XPAP-1/XPIF-1:localNeDN=MRBTS-1/NRBTS-2
...    MNL-1/MNLENT-1/XPAP-1/XPIF-2:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    MNL-1/MNLENT-1/XPAP-1/XPIF-2:localNeDN=MRBTS-1/NRBTS-2
...    MNL-1/MNLENT-1/XPAP-1/XPIF-2:sctpAssocMaxRetrans=7
...    MNL-1/MNLENT-1/XPAP-1/XPIF-2:sctpDscp=46
...    MNL-1/MNLENT-1/XPAP-1/XPIF-2:sctpHeartbeatInterval=20
...    MNL-1/MNLENT-1/XPAP-1/XPIF-2:sctpMaxPayloadSize=1395
...    MNL-1/MNLENT-1/XPAP-1/XPIF-2:sctpRtoMax=30000
...    MNL-1/MNLENT-1/XPAP-1/XPIF-2:sctpRtoMin=1000
...    MNL-1/MNLENT-1/XPAP-1/XPIF-2:sctpSackDelay=200
...    MNL-1/MNLENT-1/XPAP-1/XPIF-2:sctpSackFreq=2
...    MNL-1/MNLENT-1/XPAP-1/XPIF-2:sctpWaitTimeInitSeqRetry=240
...    MNL-1/MNLENT-1/XPAP-1/XPIF-2:udpDscp=18
...    MNL-1/MNLENT-1/XPAP-1/XPIF-2/XPIFREMOTE-1:ipAddress=10.0.1.121
...    MNL-1/MNLENT-1/XPAP-1/XPIF-2/XPIFREMOTE-1:remoteNeType=ENB

@{DSS_XPAP_ExtGnb}
...    MNL-1/MNLENT-1/XPAP-1/XPIF-1:localNeDN=MRBTS-2/NRBTS-3
...    MNL-1/MNLENT-1/XPAP-1/XPIF-2:ipV4AddressDN1=MRBTS-2/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    MNL-1/MNLENT-1/XPAP-1/XPIF-2:localNeDN=MRBTS-2/NRBTS-3
...    MNL-1/MNLENT-1/XPAP-1/XPIF-2:sctpAssocMaxRetrans=7
...    MNL-1/MNLENT-1/XPAP-1/XPIF-2:sctpDscp=46
...    MNL-1/MNLENT-1/XPAP-1/XPIF-2:sctpHeartbeatInterval=20
...    MNL-1/MNLENT-1/XPAP-1/XPIF-2:sctpMaxPayloadSize=1395
...    MNL-1/MNLENT-1/XPAP-1/XPIF-2:sctpRtoMax=30000
...    MNL-1/MNLENT-1/XPAP-1/XPIF-2:sctpRtoMin=1000
...    MNL-1/MNLENT-1/XPAP-1/XPIF-2:sctpSackDelay=200
...    MNL-1/MNLENT-1/XPAP-1/XPIF-2:sctpSackFreq=2
...    MNL-1/MNLENT-1/XPAP-1/XPIF-2:sctpWaitTimeInitSeqRetry=240
...    MNL-1/MNLENT-1/XPAP-1/XPIF-2:udpDscp=18
...    MNL-1/MNLENT-1/XPAP-1/XPIF-2/XPIFREMOTE-1:ipAddress=10.0.1.122
...    MNL-1/MNLENT-1/XPAP-1/XPIF-2/XPIFREMOTE-1:remoteNeType=ENB

@{DSS_CELL_CONFIG}
...    NRCELL-12:payloadSizeProactiveNonDrx=16
...    NRCELL-12:payloadSizeProactiveDrx=64
...    NRCELL-12:actProactUlScheduling=true
...    NRCELL-12:numOfPagingFrames=oneSixteenthT
...    NRCELL-12:srPeriodicity=slots80
...    NRCELL-12:periodicCsiAcquisition:csiReportPeriodicity=slots160
...    NRCELL-12:actPdschRmCsirsForTracking=true
...    NRCELL-12:actPdschAtSsbSlots=true
...    NRCELL-12:type0SearchSpaceConfigurationIndex=15
...    NRCELL-12:actPRBBlanking=true
...    NRCELL-12:nbrOfBlankedPRBsHighEdgeDL=0
...    NRCELL-12:nbrOfBlankedPRBsHighEdgeUL=0
...    NRCELL-12:nbrOfBlankedPRBsLowEdgeDL=6
...    NRCELL-12:nbrOfBlankedPRBsLowEdgeUL=6
...    NRCELL-12:dlPtrs:actDlPtrs=false
...    NRCELL-12:nrSysInfoProfileDN=MRBTS-1/NRBTS-2/NRSYSINFO_PROFILE-12
...    NRCELL-12:lteNrDssMode=DSS_Phase_3
...    NRCELL-12:cellBwpList:bwpDN=MRBTS-1/NRBTS-2/BWP_PROFILE-8|cellBwpId=0
...    NRCELL-12:cellBwpList:bwpDN=MRBTS-1/NRBTS-2/BWP_PROFILE-33|cellBwpId=1

@{DSS_CELL_CONFIG_ExtGnb}
...    NRCELL-14:payloadSizeProactiveNonDrx=16
...    NRCELL-14:payloadSizeProactiveDrx=64
...    NRCELL-14:actProactUlScheduling=true
...    NRCELL-14:numOfPagingFrames=oneSixteenthT
...    NRCELL-14:srPeriodicity=slots80
...    NRCELL-14:periodicCsiAcquisition:csiReportPeriodicity=slots160
...    NRCELL-14:actPdschRmCsirsForTracking=true
...    NRCELL-14:actPdschAtSsbSlots=true
...    NRCELL-14:type0SearchSpaceConfigurationIndex=15
...    NRCELL-14:actPRBBlanking=true
...    NRCELL-14:nbrOfBlankedPRBsHighEdgeDL=0
...    NRCELL-14:nbrOfBlankedPRBsHighEdgeUL=0
...    NRCELL-14:nbrOfBlankedPRBsLowEdgeDL=6
...    NRCELL-14:nbrOfBlankedPRBsLowEdgeUL=6
...    NRCELL-14:dlPtrs:actDlPtrs=false
...    NRCELL-14:nrSysInfoProfileDN=MRBTS-2/NRBTS-3/NRSYSINFO_PROFILE-12
...    NRCELL-14:lteNrDssMode=DSS_Phase_3
...    NRCELL-14:cellBwpList:bwpDN=MRBTS-2/NRBTS-3/BWP_PROFILE-8|cellBwpId=0
...    NRCELL-14:cellBwpList:bwpDN=MRBTS-2/NRBTS-3/BWP_PROFILE-33|cellBwpId=1
...    NRCELL-14:type0CoresetConfigurationIndex=7

@{DSS_CELL_NRDSSLTE}
...    NRCELL-12/NRDSSLTE-1:actLteNrDssFastAlloc=true
...    NRCELL-12/NRDSSLTE-1:actLteNrDssLteCatM=false
...    NRCELL-12/NRDSSLTE-1:actRateMatchedCsiIm=false
...    NRCELL-12/NRDSSLTE-1:dssDlTPollRetr=ms80
...    NRCELL-12/NRDSSLTE-1:dssDlTProhib=ms0
...    NRCELL-12/NRDSSLTE-1:dssMaxNumberOfDlDcis=1
...    NRCELL-12/NRDSSLTE-1:dssUlTPollRetr=ms5
...    NRCELL-12/NRDSSLTE-1:dssUlTProhib=ms0
...    NRCELL-12/NRDSSLTE-1:eNodeBId=1
...    NRCELL-12/NRDSSLTE-1:lcrId=1
...    NRCELL-12/NRDSSLTE-1:ltePhyCellId=14
...    NRCELL-12/NRDSSLTE-1:ssbPosition=pos1
...    NRCELL-12/NRDSSLTE-1:enbPlmn:mcc=311
...    NRCELL-12/NRDSSLTE-1:enbPlmn:mnc=489
...    NRCELL-12/NRDSSLTE-1:enbPlmn:mncLength=3
...    NRCELL-12/NRDSSLTE-1:lteNrDssDlRatio:dlResourceSharingAlgo=DL buffer level based
...    NRCELL-12/NRDSSLTE-1:lteNrDssDlRatio:maxNrDssRatio=100
...    NRCELL-12/NRDSSLTE-1:lteNrDssDlRatio:minNrDssRatio=20
...    NRCELL-12/NRDSSLTE-1:lteNrDssMbsfnRatio:maxValue=20
...    NRCELL-12/NRDSSLTE-1:lteNrDssMbsfnRatio:minValue=20
...    NRCELL-12/NRDSSLTE-1:lteNrDssUlRatio:maxNrDssRatio=70
...    NRCELL-12/NRDSSLTE-1:lteNrDssUlRatio:minNrDssRatio=20

@{DSS_CELL_NRDSSLTE_ExtGnb}
...    NRCELL-14/NRCELL_FDD-1:nrarfcnDl=153400
...    NRCELL-14/NRCELL_FDD-1:nrarfcnUl=142400
...    NRCELL-14/NRDSSLTE-1:actLteNrDssFastAlloc=true
...    NRCELL-14/NRDSSLTE-1:actLteNrDssLteCatM=false
...    NRCELL-14/NRDSSLTE-1:actRateMatchedCsiIm=false
...    NRCELL-14/NRDSSLTE-1:dssDlTPollRetr=ms80
...    NRCELL-14/NRDSSLTE-1:dssDlTProhib=ms0
...    NRCELL-14/NRDSSLTE-1:dssMaxNumberOfDlDcis=1
...    NRCELL-14/NRDSSLTE-1:dssUlTPollRetr=ms5
...    NRCELL-14/NRDSSLTE-1:dssUlTProhib=ms0
...    NRCELL-14/NRDSSLTE-1:eNodeBId=11
...    NRCELL-14/NRDSSLTE-1:lcrId=2
...    NRCELL-14/NRDSSLTE-1:ltePhyCellId=15
...    NRCELL-14/NRDSSLTE-1:ssbPosition=pos1
...    NRCELL-14/NRDSSLTE-1:enbPlmn:mcc=311
...    NRCELL-14/NRDSSLTE-1:enbPlmn:mnc=489
...    NRCELL-14/NRDSSLTE-1:enbPlmn:mncLength=3
...    NRCELL-14/NRDSSLTE-1:lteNrDssDlRatio:dlResourceSharingAlgo=DL buffer level based
...    NRCELL-14/NRDSSLTE-1:lteNrDssDlRatio:maxNrDssRatio=100
...    NRCELL-14/NRDSSLTE-1:lteNrDssDlRatio:minNrDssRatio=20
...    NRCELL-14/NRDSSLTE-1:lteNrDssMbsfnRatio:maxValue=20
...    NRCELL-14/NRDSSLTE-1:lteNrDssMbsfnRatio:minValue=20
...    NRCELL-14/NRDSSLTE-1:lteNrDssUlRatio:maxNrDssRatio=70
...    NRCELL-14/NRDSSLTE-1:lteNrDssUlRatio:minNrDssRatio=20

@{DSS_NRSYSINFO_PROFILE}
...    NRBTS/NRSYSINFO_PROFILE-12:nCellChangeMedium=14
...    NRBTS/NRSYSINFO_PROFILE-12:systemInformationTargetRate=193
...    NRBTS/NRSYSINFO_PROFILE-12:addHystSfHigh=dB-2
...    NRBTS/NRSYSINFO_PROFILE-12:addHystSfMedium=dB-2
...    NRBTS/NRSYSINFO_PROFILE-12:nCellChangeHigh=16
...    NRBTS/NRSYSINFO_PROFILE-12:qHyst=dB0
...    NRBTS/NRSYSINFO_PROFILE-12:siWindowLength=s160
...    NRBTS/NRSYSINFO_PROFILE-12:tEvaluation=s30
...    NRBTS/NRSYSINFO_PROFILE-12:tHystNormal=s30
...    NRBTS/NRSYSINFO_PROFILE-12:tReselectionEutra=0
...    NRBTS/NRSYSINFO_PROFILE-12:threshServingLowP=0
...    NRBTS/NRSYSINFO_PROFILE-12:sibSchedulingList:sibBroadcastStatus=broadcasting|sibType=sibType2
...    NRBTS/NRSYSINFO_PROFILE-12:sibSchedulingList:sibPeriodicity=rf64|sibType=sibType2
...    NRBTS/NRSYSINFO_PROFILE-12:sibSchedulingList:sibScope=cellSpecific|sibType=sibType2
...    NRBTS/NRSYSINFO_PROFILE-12:sibSchedulingList:sibType=sibType2|sibType=sibType2
...    NRBTS/NRSYSINFO_PROFILE-12:sibSchedulingList:sibBroadcastStatus=broadcasting|sibType=sibType3
...    NRBTS/NRSYSINFO_PROFILE-12:sibSchedulingList:sibPeriodicity=rf64|sibType=sibType3
...    NRBTS/NRSYSINFO_PROFILE-12:sibSchedulingList:sibScope=cellSpecific|sibType=sibType3
...    NRBTS/NRSYSINFO_PROFILE-12:sibSchedulingList:sibBroadcastStatus=broadcasting|sibType=sibType4
...    NRBTS/NRSYSINFO_PROFILE-12:sibSchedulingList:sibPeriodicity=rf64|sibType=sibType4
...    NRBTS/NRSYSINFO_PROFILE-12:sibSchedulingList:sibScope=cellSpecific|sibType=sibType4
...    NRBTS/NRSYSINFO_PROFILE-12:sibSchedulingList:sibBroadcastStatus=broadcasting|sibType=sibType5
...    NRBTS/NRSYSINFO_PROFILE-12:sibSchedulingList:sibPeriodicity=rf64|sibType=sibType5
...    NRBTS/NRSYSINFO_PROFILE-12:sibSchedulingList:sibScope=cellSpecific|sibType=sibType5
...    NRBTS/NRSYSINFO_PROFILE-12:sibSchedulingList:sibBroadcastStatus=broadcasting|sibType=sibType6
...    NRBTS/NRSYSINFO_PROFILE-12:sibSchedulingList:sibPeriodicity=rf64|sibType=sibType6
...    NRBTS/NRSYSINFO_PROFILE-12:sibSchedulingList:sibScope=cellSpecific|sibType=sibType6
...    NRBTS/NRSYSINFO_PROFILE-12:sibSchedulingList:sibBroadcastStatus=broadcasting|sibType=sibType7
...    NRBTS/NRSYSINFO_PROFILE-12:sibSchedulingList:sibPeriodicity=rf64|sibType=sibType7
...    NRBTS/NRSYSINFO_PROFILE-12:sibSchedulingList:sibScope=cellSpecific|sibType=sibType7
...    NRBTS/NRSYSINFO_PROFILE-12:sibSchedulingList:sibBroadcastStatus=broadcasting|sibType=sibType8
...    NRBTS/NRSYSINFO_PROFILE-12:sibSchedulingList:sibPeriodicity=rf64|sibType=sibType8
...    NRBTS/NRSYSINFO_PROFILE-12:sibSchedulingList:sibScope=cellSpecific|sibType=sibType8
...    NRBTS/NRSYSINFO_PROFILE-12/NRIAFIM-1:numberOfTransmittedSsBlocks=1 beam
...    NRBTS/NRSYSINFO_PROFILE-12/NRIAFIM-1:qRxLevMin=-56
...    NRBTS/NRSYSINFO_PROFILE-12/NRIAFIM-1:sIntraSearchP=22
...    NRBTS/NRSYSINFO_PROFILE-12/NRIAFIM-1:tReselectionNr=0
...    NRBTS/NRSYSINFO_PROFILE-12/NRIRFIM-1:dlCarrierFreq=355000
...    NRBTS/NRSYSINFO_PROFILE-12/NRIRFIM-1:dssCellsDeployed=false
...    NRBTS/NRSYSINFO_PROFILE-12/NRIRFIM-1:freqBandIndicatorNR=3
...    NRBTS/NRSYSINFO_PROFILE-12/NRIRFIM-1:numberOfTransmittedSsBlocks=1 beam
...    NRBTS/NRSYSINFO_PROFILE-12/NRIRFIM-1:qOffsetFreq=4dB
...    NRBTS/NRSYSINFO_PROFILE-12/NRIRFIM-1:qRxLevMin=-56
...    NRBTS/NRSYSINFO_PROFILE-12/NRIRFIM-1:ssbScs=15KHz
...    NRBTS/NRSYSINFO_PROFILE-12/NRIRFIM-1:tReselectionNr=1
...    NRBTS/NRSYSINFO_PROFILE-12/NRIRFIM-1:threshXHighP=30
...    NRBTS/NRSYSINFO_PROFILE-12/NRIRFIM-1:threshXLowP=22
...    NRBTS/NRSYSINFO_PROFILE-12/NRLIM-1:allowedMeasBw=mbw100
...    NRBTS/NRSYSINFO_PROFILE-12/NRLIM-1:carrierFreq=40890
...    NRBTS/NRSYSINFO_PROFILE-12/NRLIM-1:cellReselectionPriority=3
...    NRBTS/NRSYSINFO_PROFILE-12/NRLIM-1:cellReselectionSubPriority=oDot4
...    NRBTS/NRSYSINFO_PROFILE-12/NRLIM-1:pMaxEutra=22
...    NRBTS/NRSYSINFO_PROFILE-12/NRLIM-1:presenceAntPort1=true
...    NRBTS/NRSYSINFO_PROFILE-12/NRLIM-1:qQualMin=-30
...    NRBTS/NRSYSINFO_PROFILE-12/NRLIM-1:qRxLevMin=-67
...    NRBTS/NRSYSINFO_PROFILE-12/NRLIM-1:threshXHigh=10
...    NRBTS/NRSYSINFO_PROFILE-12/NRLIM-1:threshXHighQ=10
...    NRBTS/NRSYSINFO_PROFILE-12/NRLIM-1:threshXLow=9
...    NRBTS/NRSYSINFO_PROFILE-12/NRLIM-1:threshXLowQ=9

@{DSS_NRSYSINFO_PROFILE_ExtGnb}
...    NRBTS/NRSYSINFO_PROFILE-12:nCellChangeMedium=14
...    NRBTS/NRSYSINFO_PROFILE-12:systemInformationTargetRate=193
...    NRBTS/NRSYSINFO_PROFILE-12:addHystSfHigh=dB-2
...    NRBTS/NRSYSINFO_PROFILE-12:addHystSfMedium=dB-2
...    NRBTS/NRSYSINFO_PROFILE-12:nCellChangeHigh=16
...    NRBTS/NRSYSINFO_PROFILE-12:qHyst=dB0
...    NRBTS/NRSYSINFO_PROFILE-12:siWindowLength=s160
...    NRBTS/NRSYSINFO_PROFILE-12:tEvaluation=s30
...    NRBTS/NRSYSINFO_PROFILE-12:tHystNormal=s30
...    NRBTS/NRSYSINFO_PROFILE-12:tReselectionEutra=0
...    NRBTS/NRSYSINFO_PROFILE-12:threshServingLowP=0
...    NRBTS/NRSYSINFO_PROFILE-12:sibSchedulingList:sibBroadcastStatus=broadcasting|sibType=sibType2
...    NRBTS/NRSYSINFO_PROFILE-12:sibSchedulingList:sibPeriodicity=rf64|sibType=sibType2
...    NRBTS/NRSYSINFO_PROFILE-12:sibSchedulingList:sibScope=cellSpecific|sibType=sibType2
...    NRBTS/NRSYSINFO_PROFILE-12:sibSchedulingList:sibType=sibType2|sibType=sibType2
...    NRBTS/NRSYSINFO_PROFILE-12:sibSchedulingList:sibBroadcastStatus=broadcasting|sibType=sibType3
...    NRBTS/NRSYSINFO_PROFILE-12:sibSchedulingList:sibPeriodicity=rf64|sibType=sibType3
...    NRBTS/NRSYSINFO_PROFILE-12:sibSchedulingList:sibScope=cellSpecific|sibType=sibType3
...    NRBTS/NRSYSINFO_PROFILE-12:sibSchedulingList:sibBroadcastStatus=broadcasting|sibType=sibType4
...    NRBTS/NRSYSINFO_PROFILE-12:sibSchedulingList:sibPeriodicity=rf64|sibType=sibType4
...    NRBTS/NRSYSINFO_PROFILE-12:sibSchedulingList:sibScope=cellSpecific|sibType=sibType4
...    NRBTS/NRSYSINFO_PROFILE-12:sibSchedulingList:sibBroadcastStatus=broadcasting|sibType=sibType5
...    NRBTS/NRSYSINFO_PROFILE-12:sibSchedulingList:sibPeriodicity=rf64|sibType=sibType5
...    NRBTS/NRSYSINFO_PROFILE-12:sibSchedulingList:sibScope=cellSpecific|sibType=sibType5
...    NRBTS/NRSYSINFO_PROFILE-12:sibSchedulingList:sibBroadcastStatus=broadcasting|sibType=sibType6
...    NRBTS/NRSYSINFO_PROFILE-12:sibSchedulingList:sibPeriodicity=rf64|sibType=sibType6
...    NRBTS/NRSYSINFO_PROFILE-12:sibSchedulingList:sibScope=cellSpecific|sibType=sibType6
...    NRBTS/NRSYSINFO_PROFILE-12:sibSchedulingList:sibBroadcastStatus=broadcasting|sibType=sibType7
...    NRBTS/NRSYSINFO_PROFILE-12:sibSchedulingList:sibPeriodicity=rf64|sibType=sibType7
...    NRBTS/NRSYSINFO_PROFILE-12:sibSchedulingList:sibScope=cellSpecific|sibType=sibType7
...    NRBTS/NRSYSINFO_PROFILE-12:sibSchedulingList:sibBroadcastStatus=broadcasting|sibType=sibType8
...    NRBTS/NRSYSINFO_PROFILE-12:sibSchedulingList:sibPeriodicity=rf64|sibType=sibType8
...    NRBTS/NRSYSINFO_PROFILE-12:sibSchedulingList:sibScope=cellSpecific|sibType=sibType8
...    NRBTS/NRSYSINFO_PROFILE-12/NRIAFIM-1:numberOfTransmittedSsBlocks=1 beam
...    NRBTS/NRSYSINFO_PROFILE-12/NRIAFIM-1:qRxLevMin=-56
...    NRBTS/NRSYSINFO_PROFILE-12/NRIAFIM-1:sIntraSearchP=22
...    NRBTS/NRSYSINFO_PROFILE-12/NRIAFIM-1:tReselectionNr=0
...    NRBTS/NRSYSINFO_PROFILE-12/NRIRFIM-1:dlCarrierFreq=152878
...    NRBTS/NRSYSINFO_PROFILE-12/NRIRFIM-1:dssCellsDeployed=false
...    NRBTS/NRSYSINFO_PROFILE-12/NRIRFIM-1:freqBandIndicatorNR=28
...    NRBTS/NRSYSINFO_PROFILE-12/NRIRFIM-1:numberOfTransmittedSsBlocks=1 beam
...    NRBTS/NRSYSINFO_PROFILE-12/NRIRFIM-1:qOffsetFreq=4dB
...    NRBTS/NRSYSINFO_PROFILE-12/NRIRFIM-1:qRxLevMin=-56
...    NRBTS/NRSYSINFO_PROFILE-12/NRIRFIM-1:ssbScs=15KHz
...    NRBTS/NRSYSINFO_PROFILE-12/NRIRFIM-1:tReselectionNr=1
...    NRBTS/NRSYSINFO_PROFILE-12/NRIRFIM-1:threshXHighP=30
...    NRBTS/NRSYSINFO_PROFILE-12/NRIRFIM-1:threshXLowP=22
...    NRBTS/NRSYSINFO_PROFILE-12/NRLIM-1:allowedMeasBw=mbw100
...    NRBTS/NRSYSINFO_PROFILE-12/NRLIM-1:carrierFreq=40890
...    NRBTS/NRSYSINFO_PROFILE-12/NRLIM-1:cellReselectionPriority=3
...    NRBTS/NRSYSINFO_PROFILE-12/NRLIM-1:cellReselectionSubPriority=oDot4
...    NRBTS/NRSYSINFO_PROFILE-12/NRLIM-1:pMaxEutra=23
...    NRBTS/NRSYSINFO_PROFILE-12/NRLIM-1:presenceAntPort1=false
...    NRBTS/NRSYSINFO_PROFILE-12/NRLIM-1:qQualMin=-34
...    NRBTS/NRSYSINFO_PROFILE-12/NRLIM-1:qRxLevMin=-22
...    NRBTS/NRSYSINFO_PROFILE-12/NRLIM-1:threshXHigh=2
...    NRBTS/NRSYSINFO_PROFILE-12/NRLIM-1:threshXHighQ=2
...    NRBTS/NRSYSINFO_PROFILE-12/NRLIM-1:threshXLow=0
...    NRBTS/NRSYSINFO_PROFILE-12/NRLIM-1:threshXLowQ=0

@{PARAMS_ADJ_REL_FOR_GNB2}
...    NRBTS/NRADJGNB-2:administrativeState=Unlocked
...    NRBTS/NRADJGNB-2:gNbIdLength=22
...    NRBTS/NRADJGNB-2:gNodeBId=2
...    NRBTS/NRADJGNB-2:weightForIgnbCaSelection=50
...    NRBTS/NRADJGNB-2:xnLinkRef=1
...    NRBTS/NRADJGNB-2:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-2:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-2:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-11:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-11:fiveGsTac=200
...    NRBTS/NRADJNRCELL-11:gNbId=2
...    NRBTS/NRADJNRCELL-11:gNbIdLength=22
...    NRBTS/NRADJNRCELL-11:lcrId=11
...    NRBTS/NRADJNRCELL-11:nrarfcn=364000
...    NRBTS/NRADJNRCELL-11:physCellId=60
...    NRBTS/NRADJNRCELL-11:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-11:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-11:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-12:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-12:fiveGsTac=200
...    NRBTS/NRADJNRCELL-12:gNbId=2
...    NRBTS/NRADJNRCELL-12:gNbIdLength=22
...    NRBTS/NRADJNRCELL-12:lcrId=12
...    NRBTS/NRADJNRCELL-12:nrarfcn=374000
...    NRBTS/NRADJNRCELL-12:physCellId=61
...    NRBTS/NRADJNRCELL-12:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-12:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-12:gnbPlmn:mncLength=3

@{PARAMS_FOR_OTHERS}


...    NRBTS:actRanSharing=false
...    NRCELL:actCDrx=false

@{NRREL_FOR_MB007}
...    NRCELL-11/NRREL-13:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-13:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-13:gNbId=3
...    NRCELL-11/NRREL-13:gNbIdLength=22
...    NRCELL-11/NRREL-13:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-13:lcrId=13
...    NRCELL-11/NRREL-13:removeNotAllowed=false
...    NRCELL-11/NRREL-13:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-13:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-13:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-13:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-13:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-14:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-14:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-14:gNbId=3
...    NRCELL-11/NRREL-14:gNbIdLength=22
...    NRCELL-11/NRREL-14:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-14:lcrId=14
...    NRCELL-11/NRREL-14:removeNotAllowed=false
...    NRCELL-11/NRREL-14:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-14:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-14:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-14:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-14:gnbPlmn:mncLength=3

#DL_NORMAL_SUBFRAMES represents NR subframe sharing ratio of DSS, 1 represents this subframe can be used by NR.
${RESERVED_FIXED_NORMAL_SUBFRAMES}    0000000000-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000
${DL_NORMAL_SUBFRAMES_20}    0010000000-0010001000-0010000000-0010000000-0010000000-0000001000-0000000000-0000000000
${DL_NORMAL_SUBFRAMES_50}    0010000010-0111001110-0011001010-0111000110-0011101010-0111001100-0000001010-0000000110
${DL_NORMAL_SUBFRAMES_95}    1011111011-1111111111-1011111011-1111110111-1011111011-1111111111-1011111111-1111110111

#DL_PRB_ALLOCATION represents NR PRB allocation of DSS, total 80 items (subframes). Seprator for subframe is "+".
#ex. 1:6,73 represents subframe 1 from prb 6 to 69, in total 63 prbs can be used by NR.
${DL_PRB_ALLOCATION_20}    SEPARATOR=
...    0:0,0+1:6,73+2:6,73+3:0,0+4:0,0+5:0,0+6:0,0+7:6,73+8:0,0+9:0,0+
...    10:0,0+11:0,0+12:6,73+13:0,0+14:0,0+15:0,0+16:6,73+17:0,0+18:0,0+19:0,0+
...    20:0,0+21:6,73+22:6,73+23:0,0+24:0,0+25:0,0+26:0,0+27:6,73+28:0,0+29:0,0+
...    30:0,0+31:0,0+32:6,73+33:0,0+34:0,0+35:0,0+36:6,73+37:0,0+38:0,0+39:0,0+
...    40:0,0+41:6,73+42:6,73+43:0,0+44:0,0+45:0,0+46:0,0+47:6,73+48:0,0+49:0,0+
...    50:0,0+51:0,0+52:0,0+53:0,0+54:0,0+55:0,0+56:6,73+57:0,0+58:0,0+59:0,0+
...    60:0,0+61:6,73+62:0,0+63:0,0+64:0,0+65:0,0+66:0,0+67:0,0+68:0,0+69:0,0+
...    70:0,0+71:0,0+72:0,0+73:0,0+74:0,0+75:0,0+76:6,73+77:0,0+78:0,0+79:0,0

${DL_PRB_ALLOCATION_50}    SEPARATOR=
...    0:0,0+1:6,73+2:6,73+3:0,0+4:0,0+5:0,0+6:0,0+7:6,73+8:6,73+9:0,0+
...    10:0,0+11:6,73+12:6,73+13:6,73+14:0,0+15:0,0+16:6,73+17:6,73+18:6,73+19:0,0+
...    20:0,0+21:6,73+22:6,73+23:6,73+24:0,0+25:0,0+26:6,73+27:6,73+28:6,73+29:0,0+
...    30:0,0+31:6,73+32:6,73+33:6,73+34:0,0+35:0,0+36:6,73+37:6,73+38:6,73+39:0,0+
...    40:0,0+41:6,73+42:6,73+43:6,73+44:6,73+45:0,0+46:6,73+47:6,73+48:6,73+49:0,0+
...    50:0,0+51:6,73+52:6,73+53:6,73+54:0,0+55:0,0+56:6,73+57:6,73+58:0,0+59:0,0+
...    60:0,0+61:6,73+62:0,0+63:0,0+64:0,0+65:0,0+66:6,73+67:0,0+68:6,73+69:0,0+
...    70:0,0+71:0,0+72:0,0+73:0,0+74:0,0+75:0,0+76:6,73+77:6,73+78:6,73+79:0,0

${DL_PRB_ALLOCATION_95}    SEPARATOR=
...    0:6,35+1:6,73+2:6,73+3:6,73+4:6,73+5:6,35+6:6,73+7:6,73+8:6,73+9:6,73+
...    10:6,35+11:6,73+12:6,73+13:6,73+14:6,73+15:6,35+16:6,73+17:6,73+18:6,73+19:6,73+
...    20:6,35+21:6,73+22:6,73+23:6,73+24:6,73+25:6,35+26:6,73+27:6,73+28:6,73+29:6,73+
...    30:6,35+31:6,73+32:6,73+33:6,73+34:6,73+35:6,35+36:6,73+37:6,73+38:6,73+39:6,73+
...    40:6,35+41:6,73+42:6,73+43:6,73+44:6,73+45:6,35+46:6,73+47:6,73+48:6,73+49:6,73+
...    50:6,35+51:6,73+52:6,73+53:6,73+54:6,73+55:6,35+56:6,73+57:6,73+58:6,73+59:6,73+
...    60:6,35+61:6,73+62:6,73+63:6,73+64:6,73+65:6,35+66:6,73+67:6,73+68:6,73+69:6,73+
...    70:6,35+71:6,73+72:6,73+73:6,73+74:6,73+75:6,35+76:6,73+77:6,73+78:6,73+79:6,73

#common UE cap with DSS supported
#DSS cap: RF param - supportedbandlist - rateMatchingLTE-CRS supported
${SA_Capa_DSS_supported}    SEPARATOR=
...    E9A09000575F5A13160003C4A0002C1262E003387A16009B20C39F30C7942C0E0980C0311C04EE3E03606B04610D04083A41E006D6C98AB1
...    A1CF88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE000C80000E0541F00B582308682041E20F0032B64C55890E7D
...    813E238F1891C790E7D473E618F28581C0E1E13FB000000FEC000000C80000E0551F133582308682041D20F0030B64C55110E7C471E238F4
...    0CFB027C639F30C7942C0E070F05C00FFC007003FF000640000702A0F837AC1184341020F10780195B262AC4873E238F604F8C48E3C873EA
...    39F30C7942C0E070F09FFF000007FFC00000640000702A8F89BAC1184340000080780185B24CA88873E238F20C7A067D813E01CF9863CA16
...    07038782F55555553D555555432000038024B0F1300038980000002C0AC5C4C000E26000713000000858158B80400184C0309800020B02B1
...    F008003036061300C260000C2C0AC5C02000C010181B0002058158F8040018060303606134000A160562E01000606C0C26000182C0AC3C02
...    000C260001C2C0AC3C02000C01000202C0AC3C1B000C0D800242C0AC3C02000C03000282C0AC3C06000C0D8002C2C0AC5C02000C030181B0
...    0060581587836001C4C00001A160562E2600061300C01000382C0AC7C4C000C260180203036000F0B02B171300030040606C0020160563E2
...    680060080C030181B00088581009006E003404C8005013465001D212851226C73E1C4891226C73E1C4891226C73E1C68912244D8E7C38912
...    244D8E7C38D1224489B1CF871224489B1CF870A244D8E7C3851226C73E1C28913639F0E14489B1CF870A244D8E7C38912244D8E7C3851226
...    C73E1C4891226C73E1C68912244D8E7C38912244D8E7C38D1224489B1CF8603624318C6318C6318C6318C63183D06C003C00281C1401C0C0
...    2500700060240040603E09002000000010008000000200000C0100000200800002004000018020000100100000A008004010040100000C00
...    80000700400200000008000080040000480200000C010000140080000B004002048120080000C0339535953582958195833582B594B79337
...    80B581B58095811583B40D040000259494100001965260400006594901000039652404000125949010000596526040001A59490100007965
...    2404000225949010000996524040002A5949010000B96525040003259490100003165240334AAAE955552A8BA55154162A82C55068AA5315
...    49A2A80C55028AA4D5541E286802F012A05028140A05028140A05028140A05028140A0502800884040080101002004402004008080100202
...    0040088040300501002004040080118080600A020180280801002020040088040400501010014040580B18080600C02018028080600C0200
...    4008804030050100C014040080108080600A02004008404030050100C014202018030080600C10100C018040300508080600A02018028804
...    030050100C018040300508080600C020040088040080101002004040300518080100202004008080600A02018028804008010100C0180403
...    00618080100202018028080600C02018028D50F8000810182030385058606880889098A0C0C8D8E0E8F909293139414951697A0A0C1680

#UE is capable of LTE-CRS rate matching in a given NR frequency band,3+3+28
${UE_Capbility_support_N3_2A_N28A}    SEPARATOR=
...    E9A09000575F5A13160003C4A0002C1262E003387A16009B20C39F30C7942C0E0980C0311C04EE3E03606B04610D04083A41E006D6C98AB1A1CF88E3D033EC09F1
...    891C790E7D473E618F28581C0E1E0B801FF800E000BE000C80000E0541F00B582308682041E20F0032B64C55890E7D813E238F1891C790E7D473E618F28581C0E1
...    E13B8000000FEC000000C80000E0551F133582308682041D20F0030B64C55110E7C471E238F40CFB027C639F30C7942C0E070F05C00FFC007003FF000640000702
...    A0F837AC1184341020F10780195B262AC4873E238F604F8C48E3C873EA39F30C7942C0E070F09CC0000007FFC00000640000702A8F89BAC1184340000080780185
...    B24CA88873E238F20C7A067D813E01CF9863CA1607038782F55555553D555555432000038002B170080030040606C0008160402401B800D0132001404D19400088
...    062448913639F0C02808CF41B000F000A070500703009401C0018090010180F8240080000000400200000008000030040000080200000801000006008000040040
...    0002802001004010040000300200001C010008000000200002001000012008000030040000500200002C01000812048020000300CE54D654D60A5606560CD604D6
...    52DE0CDE02D606D6025604560ED0341000009652504000065949810000196524040000E594901000049652404000165949810000696524040001E5949010000896
...    52404000265949010000A96524040002E5949410000C96524040000C594900CD2AABA55554AA2E95455058AA0B1541A2A94C55068AA031540A2A93555078A1A00B
...    C04A8140A05028140A05028140A05028140A05028140A0022101002004040080110080100202004008080100220100C014040080101002004602018028080600A0
...    2004008080100220101001404040050101602C602018030080600A02018030080100220100C014040300501002004202018028080100210100C014040300508080
...    600C02018030404030060100C014202018028080600A20100C01404030060100C014202018030080100220100200404008010100C0146020040080801002020180
...    28080600A20100200404030060100C018602004008080600A02018030080600A3543E00020406080C0E1416181A2022242628303236383A3E424A4C4E5052545A5
...    E828305A

@{expectedScellsAdditionString}
...    pcid:50, scellIdx:1
...    pcid:51, scellIdx:2
...    pcid:63, scellIdx:3
...    rrcReconfigurationComplete

@{unexpectedScellsAdditionString}
...    rateMatchPatternToAddModList*sCellConfigCommon*

@{Nrcell12_HO_to_Nrcell11_Success}
...    Intra-eNB handover from EXT_ENB-2.12 to EXT_ENB-2.11 performed
...    pcid:50, scellIdx:1
...    SCellIndex 1 activated successfully at airphone

@{UE1_HO_Unexpect}
...    pcid:51, scellIdx:2

@{Nrcell11_HO_to_Nrcell12_Success}
...    Intra-eNB handover from EXT_ENB-2.11 to EXT_ENB-2.12 performed
...    pcid:50, scellIdx:1
...    pcid:51, scellIdx:2
...    pcid:63, scellIdx:3
...    SCellIndex 1 activated successfully at airphone
...    SCellIndex 2 activated successfully at airphone
...    SCellIndex 3 activated successfully at airphone

@{Online_Modify_GNB2_Params_MB007}    @{DSS_CELL_CONFIG_ExtGnb}    @{DSS_CELL_NRDSSLTE_ExtGnb}

@{UE2_CA_addition}
...    pcid:62, scellIdx:1
...    pcid:63, scellIdx:2
...    rrcReconfigurationComplete

@{UE2_HO_Expect}
...    Intra-eNB handover from EXT_ENB-2.12 to EXT_ENB-2.11 performed
...    pcid:62, scellIdx:1
...    pcid:63, scellIdx:2

@{UE2_HO_Back_Expect}
...    Intra-eNB handover from EXT_ENB-2.11 to EXT_ENB-2.12 performed
...    pcid:62, scellIdx:1
...    pcid:63, scellIdx:2

*** Test Cases ***
CB008140-MB_001_Verify Successful InterGnb CA Interworking With DSS Enabled in Pcell Only FFTT
    [Documentation]
    ...    1. The purpose of this test case is to check following scenarios:
    ...    Successful inter-gNB FDD+FDD+TDD+TDD CA in case DSS is enabled in FDD serving cell.
    ...    successful blind SCell addition for inter-gNB 4CC DL CA.
    ...    and sCellActivationMethod set to bufferBased take effect.
    ...    [Configuration]:
    ...    Simulate LTE DSS GNB1 CELL1:
    ...    set_cell id=1 enb=1 eci=0x0000101 pci=4:2 tac=222 proxy=10.0.2.1:12219 earfcn=1850:19850 bw=15MHz
    ...    External GNB:
    ...    Cell id=11 gnb=2 pci=20:0 tac=200 tdd_cell=off band=n3 nr_arfcn=345000:364000 gscn=4547 chBw=15MHz
    ...    Cell id=12 gnb=2 pci=20:1 tac=200 tdd_cell=off band=n3 nr_arfcn=355000:374000 gscn=4675 chBw=15MHz
    ...    Cell id=1 gnb=3 pci=16:2 tac=200 tdd_cell=on band=n77 nr_arfcn=663400:663400 gscn=8159 chBw=100MHz
    ...    Cell id=2 gnb=3 pci=17:0 tac=200 tdd_cell=on band=n77 nr_arfcn=658000:658000 gscn=8103 chBw=40MHz
    ...    Cell id=13 gnb=3 pci=20:2 tac=200 tdd_cell=off band=n3 nr_arfcn=349400:368400 gscn=4605 chBw=10MHz
    ...    Cell id=14 gnb=3 pci=21:0 tac=200 tdd_cell=off band=n28 nr_arfcn=143400:153400 gscn=1916 chBw=15MHz
    ...    UE capability support lteCRS-Rate Matching and n3+n77+n77+n28 4CC
    ...    2.Test Case Steps:
    ...         Step a: Establish DSS between LTE CELL 1_1 and GNB CELL 2_12.
    ...         Step b: Attach SA UE1 to cell2_12.
    ...         Step c: start traffic and check traffic.
    ...         Step d: Dynamically adjust the PDSCH load in LTE cell and NR FDD cell2_12 as:
    ...                (LTE cell PDSCH load, NR FDD cell PDSCH load) = {(low, high) => (medium, medium) => (high, low) }
    ...                refer to below site:
    ...                https://confluence.ext.net.nokia.com/display/5GHAN/%5B5GC002063%5D+CRM+sending+DL+allocated+normal+subframes+calculation+forum
    ...         Step e: UE1 send A2 and A3 MR to trigger inter-frequency intragnb handover and verify traffic.
    ...         Step f: UE1 send A2 and A3 MR to trigger inter-frequency intragnb handover and verify traffic.
    ...    3. Expected Results:
    ...         Step a: DSS established between LTE CELL 1_1 and GNB CELL 2_12.
    ...         Step b: UE1 Register And PDU Session Setup Successful.
    ...                 Blind Add Cell3_1 and Cell3_2 and Cell3_14 as Scells.
    ...         Step c: Traffic is stable and on expected level. UE1 SCells activated.
    ...         Step d: Pcell's tput increase while PDSCH load in the NR FDD cell is high.
    ...         Step e: Gnb2 cell2_12 handover to gnb3 cell3_13 successful, traffic is as expected.
    ...         Step f: Gnb3 cell3_13 handover to gnb2 cell2_12 successful, traffic is as expected.
    [Tags]    QC_281437    MB001    CA_LABEL-FFTT(15MHz_FDD_n3+10MHz_FDD_n3+100MHz_TDD_n77+15MHz_FDD_n28)
    SA UE Attach To GNB2 Cell12 and Scells Added Blindly
    Run Traffic and Verify Throughput    ue_id=1    Tput_dl=270    Tput_ul=4    sharingRatio=20    Tput_pcell=9
    Adjust the PDSCH load in LTE cell and GNB cell and Verify Throughput    DL_NORMAL_SUBFRAMES=${DL_NORMAL_SUBFRAMES_50}
    ...    DL_PRB_ALLOCATION=${DL_PRB_ALLOCATION_50}    ue_id=1    Tput_dl=270    Tput_ul=7    sharingRatio=50    Tput_pcell=15
    Adjust the PDSCH load in LTE cell and GNB cell and Verify Throughput    DL_NORMAL_SUBFRAMES=${DL_NORMAL_SUBFRAMES_95}
    ...    DL_PRB_ALLOCATION=${DL_PRB_ALLOCATION_95}    ue_id=1    Tput_dl=270    Tput_ul=10    sharingRatio=95    Tput_pcell=18
    Verify Pcell Tput Increase when sharingRatio Increase
    Inter Freq intra GNB HO and HO back and Verify Traffic
    Check WireShark Log    ${CURDIR}${/}A2A_MB_001${/}a2a.ini    wait_string=UEContextModificationResponse::24

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup 2Airphone Env    fddtdd_sansa_cmwv/6cells_gnb1_2T_gnb2_2T2F

Perform Steps After WTS Started
    Establish DSS between ENB Cell and GNB Cell    enb=1    gnb=2    enb_cell=1    gnb_cell=12    antenna_ports_num=2
    Establish XP link Between ENB And GNB    enb=11    gnb=3

Modify Cfg
    ${cmd1}    Catenate    set_enb id=1 plmn=311:489 s1=10.0.1.136 enb_id_macro=0x00001
    ...    daemon=10.0.2.1:22222 type=simulated x2_peers=none
    ...    xp_management=on xp=10.0.1.121:32742 xpu=10.0.1.121:32742
    Update Cfg    ${cmd1}
    ${cmd2}    Catenate    set_cell id=1 enb=1 eci=0x0000101 pci=4:2 tac=222
    ...    proxy=10.0.2.1:12219 earfcn=1850:19850 bw=15MHz
    Update Cfg    ${cmd2}
    ${cmd3}    Catenate    set_enb id=11 plmn=311:489 s1=10.0.1.146 enb_id_macro=0x00004
    ...    daemon=10.0.2.1:22222 type=simulated x2_peers=none
    ...    xp_management=on xp=10.0.1.122:32742 xpu=10.0.1.122:32742 x2=10.0.1.147 x2u=10.0.1.145
    Update Cfg    ${cmd3}
    Update Cfg    enb_param id=11 drb_id_begin=3 endc_capable_qci=9
    Update Cfg    enb_endc_param id=11 control_flow_period=3gpp1 use_nr_ran_cont=on serving_cell_index_range_scg=8:14
    ${cmd4}    Catenate    set_cell id=2 enb=11 eci=0x0000402 pci=5:0 tac=222
    ...    proxy=10.0.2.1:12220 earfcn=9300:27300 bw=15MHz
    Update Cfg    ${cmd4}
    ${command_gnb3} =    catenate    set_gnb id=3 type=external plmn=311:489 s1u=$GNB2_S1U_ADDR x2=10.0.1.3:36422 ng=10.0.1.3 xn=10.0.1.3
    ...    gnb_id=0x02:22 daemon=10.0.2.1:22222 x2_peers=none amf=1 plmnList=311:489 nssai=0x1:0xd143a5
    ...    xp=10.0.1.3:32742 xpu=10.0.1.3:32742 xp_management=on
    Update Cfg    ${command_gnb3}
    ${command_gnb2} =    catenate    set_gnb id=2 type=external plmn=311:489 s1u=$GNB1_S1U_ADDR x2=10.0.1.2:36422 ng=10.0.1.2 xn=10.0.1.2
    ...    gnb_id=0x01:22 daemon=10.0.2.1:22222 x2_peers=none amf=1 plmnList=311:489 nssai=0x1:0xd143a5
    ...    xp=10.0.1.2:32742 xpu=10.0.1.2:32742 xp_management=on
    Update Cfg    ${command_gnb2}
    Update Cfg    ue_param id=1 ue_nr_capabilities=${SA_Capa_DSS_supported}
    Update Cfg    ue_param id=2 ue_nr_capabilities=${UE_Capbility_support_N3_2A_N28A}

Establish DSS between ENB Cell and GNB Cell
    [Arguments]    ${enb}=1    ${gnb}=2    ${enb_cell}=1    ${gnb_cell}=12    ${antenna_ports_num}=2
    Establish XP link Between ENB And GNB    enb=${enb}    gnb=${gnb}
    Activate DSS Feature on ENB Cell    enb=${enb}    enb_cell=${enb_cell}    antenna_ports_num=${antenna_ports_num}
    Setup DSS Partnership Between ENB Cell and GNB Cell    enb=${enb}    gnb=${gnb}    enb_cell=${enb_cell}    gnb_cell=${gnb_cell}
    Cell Resource Reservation Between ENB Cell and GNB Cell    enb=${enb}    gnb=${gnb}    enb_cell=${enb_cell}    gnb_cell=${gnb_cell}
    Request DSS Cell Resource Coordination To CRM    enb=${enb}    gnb=${gnb}    enb_cell=${enb_cell}    gnb_cell=${gnb_cell}
    Request CRM Periodic Resource Allocation    DL_NORMAL_SUBFRAMES=${DL_NORMAL_SUBFRAMES_20}    DL_PRB_ALLOCATION=${DL_PRB_ALLOCATION_20}
    ...    enb=${enb}    gnb=${gnb}    enb_cell=${enb_cell}    gnb_cell=${gnb_cell}
    Request DSS UL Cell Resource Allocation To CRM    enb=${enb}    gnb=${gnb}    enb_cell=${enb_cell}    gnb_cell=${gnb_cell}

Establish XP link Between ENB And GNB
    [Arguments]    ${enb}=1    ${gnb}=2
    Execute Egate Command    enb_x2_link_up enb=${enb} target=${gnb}    pass_regexp=is up
    Execute Egate Command    sim_trace enb=${enb} protocol=xp on
    Execute Egate Command    enb_xp_param id=${enb} xp_peers=none
    Execute Egate Command    enb_xp_param id=${enb} xp_peers=${gnb}
    Execute Egate Command    enb_xp_link_up enb=${enb} target=${gnb}
    ...     pass_regexp=(XpAP Link .* is up|Xp Link is already active)    timeout=100    sleep_time=10

Activate DSS Feature on ENB Cell
    [Arguments]    ${enb}=1    ${enb_cell}=1    ${antenna_ports_num}=2
    Execute Egate Command    enb_dss_param id=${enb} feature_flag=on message_sets=DMS3
    Execute Egate Command    enb_cell_param id=${enb_cell} enb=${enb} lte_nr_dss_mode=DSS_PHASE_3 antenna_ports_num=${antenna_ports_num}
    Execute Egate Command    enb_cell_dss_feature id=${enb_cell} enb=${enb} nr_dl_peak_rate_increase=on superfast_allocation=on    sleep_time=3
    ${cmd}    catenate    enb_cell_dss_param id=${enb_cell} enb=${enb} dl_resource_sharing_algo=dl_buffer_level_based
    ...    dl_superfast_load_meas_timer=100 ul_superfast_load_meas_timer=100
    Execute Egate Command    ${cmd}    timeout=60    sleep_time=3

Setup DSS Partnership Between ENB Cell and GNB Cell
    [Arguments]    ${enb}=1    ${gnb}=2    ${enb_cell}=1    ${gnb_cell}=12
    Execute Egate Command    enb_dss_configure_partnership enb=${enb} cell=${enb_cell} dss_peer=${gnb}:${gnb_cell}
    ...    pass_regexp=ENB-${enb}: CRM Partnership Creation    sleep_time=3

Cell Resource Reservation Between ENB Cell and GNB Cell
    [Arguments]    ${enb}=1    ${gnb}=2    ${enb_cell}=1    ${gnb_cell}=12
    ${cmd}    catenate    enb_crm_cell_resource_reservation enb=${enb} cell=${enb_cell} tgt_enb=${gnb} tgt_cell=${gnb_cell}
    ...    assigned_dl_minimum_share_to_nr=20 assigned_dl_maximum_share_to_nr=100
    ...    assigned_dl_minimum_share_to_lte=20 assigned_dl_maximum_share_to_lte=100
    ...    assigned_ul_minimum_share_to_nr=20 assigned_ul_maximum_share_to_nr=70
    Execute Egate Command    ${cmd}    sleep_time=3
    Execute Egate Command    enb_crm_param id=${enb} ul_qos_load_meas_timer=100 dl_qos_load_meas_timer=100    sleep_time=3
    Execute Egate Command    enb_dss_establish_partnership enb=${enb} cell=${enb_cell} tgt_enb=${gnb} tgt_cell=${gnb_cell}
    ...    pass_regexp=ENB-${enb}: Cell ${enb_cell}: Partnership activated on both partners    sleep_time=3    timeout=30s
    Execute Egate Command    enb_dss_dl_cell_resource_reservation enb=${enb} cell=${enb_cell} reset    sleep_time=3
    Execute Egate Command    enb_dss_ul_cell_resource_reservation enb=${enb} cell=${enb_cell} reset    sleep_time=3
    ${cmd}    catenate    enb_dss_dl_cell_resource_reservation enb=${enb} cell=${enb_cell}
    ...    prb_area_reservation_list=0,0,0-10-none+0,0,5-10-none+0,0,9-10-none
    ...    reserved_fixed_normal_subframes=${RESERVED_FIXED_NORMAL_SUBFRAMES}
    ...    min_lte_nr_dss_ratio=20 max_lte_nr_dss_ratio=100
    Execute Egate Command    ${cmd}    sleep_time=3

Request DSS Cell Resource Coordination To CRM
    [Arguments]    ${enb}=1    ${gnb}=2    ${enb_cell}=1    ${gnb_cell}=12
    Execute Egate Command    enb_dss_cell_resource_coordination enb=${enb} cell=${enb_cell} tgt_enb=${gnb} tgt_cell=${gnb_cell} dir=DL
    ...     pass_regexp=ENB-${enb}: Cell ${enb_cell}:.*DSS DL.*Coordination: both NEs synchronized    timeout=60s
    ${cmd}    catenate    enb_dss_ul_cell_resource_reservation enb=${enb} cell=${enb_cell} minimum_prb_share=20 maximum_prb_share=70
    Execute Egate Command    ${cmd}    sleep_time=3
    Execute Egate Command    enb_dss_cell_resource_coordination enb=${enb} cell=${enb_cell} tgt_enb=${gnb} tgt_cell=${gnb_cell} dir=UL
    ...     pass_regexp=ENB-${enb}: Cell ${enb_cell}:.*DSS UL.*Coordination    sleep_time=3
    Execute Egate Command     enb_crm_status enb=${enb} cell=${enb_cell}

Request CRM Periodic Resource Allocation
    [Arguments]    ${DL_NORMAL_SUBFRAMES}    ${DL_PRB_ALLOCATION}    ${enb}=1    ${gnb}=2    ${enb_cell}=1    ${gnb_cell}=12
    ${cmd}    catenate    enb_dss_resource_allocation enb=${enb} cell=${enb_cell} tgt_enb=${gnb} tgt_cell=${gnb_cell} dir=DL
    ...    allocation_start_time=immediate dl_allocated_normal_subframes=${DL_NORMAL_SUBFRAMES}
    ...    dl_prb_area_allocation_list=${DL_PRB_ALLOCATION}
    Execute Egate Command    ${cmd}    pass_regexp=ENB-${enb}: Cell ${enb_cell}: Received.*DSS DL.*Allocation Response    timeout=30s
    ${cmd}    catenate    enb_dss_resource_allocation enb=${enb} cell=${enb_cell} tgt_enb=${gnb} tgt_cell=${gnb_cell} dir=UL
    ...    allocation_start_time=immediate ul_allocated_prb_list=6,21|28,40|69,10
    Execute Egate Command    ${cmd}    pass_regexp=ENB-${enb}: Cell ${enb_cell}: Received.*DSS UL.*Allocation Response    timeout=30s
    Execute Egate Command     enb_crm_status enb=${enb} cell=${enb_cell}    pass_regexp=eNB-${enb}: Configured DSS partnership
    ${cmd}    catenate    enb_crm_periodic_allocation_pattern enb=${enb} cell=${enb_cell} tgt_enb=${gnb} tgt_cell=${gnb_cell}
    ...    allocation_start_time=auto dir=DL dl_allocated_normal_subframes=${DL_NORMAL_SUBFRAMES}
    ...    dl_allocation_priority=10 dl_prb_area_allocation_list=${DL_PRB_ALLOCATION}
    Execute Egate Command    ${cmd}    pass_regexp=CRM Trigger Periodic Allocation Pattern    timeout=10min
    ${cmd}    catenate    enb_crm_periodic_resource_allocation enb=${enb} cell=${enb_cell} tgt_enb=${gnb} tgt_cell=${gnb_cell} dir=DL
    ...    periodicity=10 periodicity_and_load_indication=true loopback=on periodicity_messages_logged=500
    Execute Egate Command    ${cmd}    pass_regexp=Received.*DSS DL.*Allocation Response    timeout=10min

Request CRM Periodic DL Resource Allocation
    [Arguments]    ${DL_NORMAL_SUBFRAMES}    ${DL_PRB_ALLOCATION}    ${enb}=1    ${gnb}=2    ${enb_cell}=1    ${gnb_cell}=12
    ${cmd}    catenate    enb_crm_periodic_allocation_pattern enb=${enb} cell=${enb_cell} tgt_enb=${gnb} tgt_cell=${gnb_cell}
    ...    allocation_start_time=auto dir=DL dl_allocated_normal_subframes=${DL_NORMAL_SUBFRAMES}
    ...    dl_allocation_priority=10 dl_prb_area_allocation_list=${DL_PRB_ALLOCATION}
    Execute Egate Command    ${cmd}    sleep_time=3    pass_regexp=CRM Trigger Periodic Allocation Pattern    timeout=10min
    ${cmd}    catenate    enb_crm_periodic_resource_allocation enb=${enb} cell=${enb_cell} tgt_enb=${gnb} tgt_cell=${gnb_cell} dir=DL
    ...    periodicity=10 periodicity_and_load_indication=true loopback=on periodicity_messages_logged=500
    Execute Egate Command    ${cmd}    pass_regexp=Received.*DSS DL.*Allocation Response    timeout=10min

Adjust the PDSCH load in LTE cell and GNB cell and Verify Throughput
    [Arguments]    ${DL_NORMAL_SUBFRAMES}    ${DL_PRB_ALLOCATION}    ${enb}=1    ${gnb}=2    ${enb_cell}=1    ${gnb_cell}=12
    ...    ${ue_id}=1    ${Tput_dl}=100    ${Tput_ul}=4    ${sleep_time}=5s    ${sharingRatio}=20    ${Tput_pcell}=9
    Request CRM Periodic DL Resource Allocation    DL_NORMAL_SUBFRAMES=${DL_NORMAL_SUBFRAMES}    DL_PRB_ALLOCATION=${DL_PRB_ALLOCATION}
    ...    enb=${enb}    gnb=${gnb}    enb_cell=${enb_cell}    gnb_cell=${gnb_cell}
    Verify Throughput    ue_id=${ue_id}    Tput_dl=${Tput_dl}    Tput_ul=${Tput_ul}    sleep_time=${sleep_time}
    ...    sharingRatio=${sharingRatio}    Tput_pcell=${Tput_pcell}

Request DSS UL Cell Resource Allocation To CRM
    [Arguments]    ${enb}=1    ${gnb}=2    ${enb_cell}=1    ${gnb_cell}=12
    ${cmd}    catenate    enb_crm_periodic_allocation_pattern enb=${enb} cell=${enb_cell} tgt_enb=${gnb} tgt_cell=${gnb_cell} dir=UL
    ...    allocation_start_time=auto ul_allocated_prb_list=6,30|37,12|50,29 delay_if_auto=30
    Execute Egate Command    ${cmd}    pass_regexp=CRM Trigger Periodic Allocation Pattern    sleep_time=3
    ${cmd}    catenate    enb_crm_periodic_resource_allocation enb=${enb} cell=${enb_cell} tgt_enb=${gnb} tgt_cell=${gnb_cell} dir=UL periodicity=500
    ...    periodicity_and_load_indication=true loopback=on periodicity_messages_logged=500
    Execute Egate Command    ${cmd}    pass_regexp=ENB-${enb}: Cell ${enb_cell}: Received.*DSS UL.*Allocation Response    timeout=10min
    Execute Egate Command     enb_crm_status enb=${enb} cell=${enb_cell}    pass_regexp=eNB-${enb}: Configured DSS partnership

SA UE Attach To GNB2 Cell12 and Scells Added Blindly
    [Arguments]    ${ue_id}=1    ${Expect}=${expectedScellsAdditionString}    ${Unexpect}=${unexpectedScellsAdditionString}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=12    pass_regexp=(location updated|already there)
    Execute Egate Command    ue_register id=${ue_id}     pass_regexp=Received REGISTRATION COMPLETE
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=3
    ...    pass_regexp=${Expect}    fail_regexp=${Unexpect}

Run Traffic and Verify Throughput
    [Arguments]    ${ue_id}=1    ${Tput_dl}=270    ${Tput_ul}=4    ${sleep_time}=15s    ${sharingRatio}=20    ${Tput_pcell}=9
    ...     ${mbps}=150
    ${ret1}=    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=1 protocol=tcp mbps=${mbps} dir=dl
    ...    pass_regexp=Started Downlink Internal traffic over TCP on Ue    sleep_time=2
    ${ret2}=    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=2 protocol=tcp mbps=${mbps} dir=dl
    ...    pass_regexp=Started Downlink Internal traffic over TCP on Ue    sleep_time=2
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=1 protocol=tcp mbps=50 dir=ul
    Verify Throughput    ue_id=${ue_id}    Tput_dl=${Tput_dl}    Tput_ul=${Tput_ul}    sharingRatio=${sharingRatio}    Tput_pcell=${Tput_pcell}

Verify Throughput
    [Arguments]    ${ue_id}=1    ${Tput_dl}=100    ${Tput_ul}=4    ${sleep_time}=15s    ${sharingRatio}=20    ${Tput_pcell}=9
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pdsch    Throughput
    ${PcellTput}=    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Set Test Variable    ${PcellTput${sharingRatio}}    ${PcellTput}/1000
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}
    Should Be True    ${PcellTput${sharingRatio}}>${Tput_pcell}


Inter Freq intra GNB HO and HO back and Verify Traffic
    [Arguments]    ${ue_id}=1    ${HO_Expect}=${Nrcell12_HO_to_Nrcell11_Success}    ${HO_Back_Expect}=${Nrcell11_HO_to_Nrcell12_Success}
    ...    ${Tput_dl_11}=270    ${Tput_dl_12}=270    ${Tput_pcell_11}=50    ${Tput_pcell_12}=18
    Inter Freq intra GNB HO From Nrcell12 to Nrcell11    ue_id=${ue_id}    HO_Expect=${HO_Expect}
    Sleep    2s    #wait for HO success
    Verify Throughput    ue_id=${ue_id}    Tput_dl=${Tput_dl_11}    Tput_pcell=${Tput_pcell_11}
    Inter Freq intra GNB HO From Nrcell11 to Nrcell12    ue_id=${ue_id}    HO_Back_Expect=${HO_Back_Expect}
    Sleep    2s    #wait for HO success
    Verify Throughput    ue_id=${ue_id}    Tput_dl=${Tput_dl_12}    Tput_pcell=${Tput_pcell_12}

Inter Freq intra GNB HO From Nrcell12 to Nrcell11
    [Arguments]    ${ue_id}=1    ${HO_Expect}=${Nrcell12_HO_to_Nrcell11_Success}    ${HO_Unexpect}=${UE1_HO_Unexpect}
    ${measid}    get nr meas id for specific type and frequency    ue_id=${ue_id}    carrierfreq=373970    event_type=A2
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${measid} event=A2 srsrp_nr=25
    ...    pass_regexp=rrcReconfigurationComplete
    ${measid}    get nr meas id for specific type and frequency    ue_id=${ue_id}    carrierfreq=363850    event_type=A3
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${measid} event=A3 srsrp_nr=20 phycell_id=60 nrsrp_nr=80
    ...    pass_regexp=${HO_Expect}    fail_regexp=${HO_Unexpect}

Inter Freq intra GNB HO From Nrcell11 to Nrcell12
    [Arguments]    ${ue_id}=1    ${HO_Back_Expect}=${Nrcell11_HO_to_Nrcell12_Success}
    ${measid}    get nr meas id for specific type and frequency    ue_id=${ue_id}    carrierfreq=363850    event_type=A2
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${measid} event=A2 srsrp_nr=25
    ...    pass_regexp=rrcReconfigurationComplete
    ${measid}    get nr meas id for specific type and frequency    ue_id=${ue_id}    carrierfreq=373970    event_type=A3
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${measid} event=A3 srsrp_nr=20 phycell_id=61 nrsrp_nr=80
    ...    pass_regexp=${HO_Back_Expect}

Verify Pcell Tput Increase when sharingRatio Increase
    ${dl_rate}=    Evaluate    ${PcellTput20}<${PcellTput50}<${PcellTput95}
    Should be True    ${dl_rate}==True

Online Update Parameters
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    BuiltIn.Log To Console    Online Update Parameters is done

Online Update Parameters GNB2
    [Arguments]    ${Online_Param}
    Delta Commission Parameters gnb2    ${Online_Param}
    BuiltIn.Log To Console    Online Update Parameters is done
