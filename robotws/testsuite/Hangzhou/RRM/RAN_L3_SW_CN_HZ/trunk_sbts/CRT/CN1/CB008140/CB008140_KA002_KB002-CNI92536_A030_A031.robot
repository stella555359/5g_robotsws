*** Settings ***
Documentation
...    author: Susana Yan
...    contact: susana.yan@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    CRT    CLOUD_5G_I_[LO][LO]_AP_[LOO]
...    owner-jun.3.ye    release-SBTS23R3    team-CN1ET
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${NOKIA_XNAP_PLUGIN_FLAG}    ${True}
${NOKIA_F1AP_PLUGIN_FLAG}    ${True}

@{PARAMS_IN_SWCONFIG}
...    @{rdEnableTrafficManager}
...    @{rdEnableUeIdRangeAllocationViaSdl}
...    @{rdEnableUeMappingRemovalFromCpIf}

@{PARAMS_IN_SWCONFIG_GNB2}
...    @{rdEnableTrafficManager}
...    @{rdEnableUeIdRangeAllocationViaSdl}
...    @{rdEnableUeMappingRemovalFromCpIf}

@{rdEnableTrafficManager}
...    0x89001C=1
@{rdEnableUeIdRangeAllocationViaSdl}
...    0x89001D=1
@{rdEnableUeMappingRemovalFromCpIf}
...    0x89001E=1

@{PARAMS_IN_SCF}
...    @{PARAMS_FOR_CA}
...    @{PARAMS_FOR_GNB1}
...    @{PARAMS_ADJ_REL_FOR_GNB1}
...    @{PARAMS_FOR_OTHERS}
...    @{handover_PARAMS}
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1


@{PARAMS_IN_SCF_GNB2}
...    @{PARAMS_FOR_CA}
...    @{PARAMS_FOR_GNB2}
...    @{PARAMS_ADJ_REL_FOR_GNB2}
...    @{PARAMS_FOR_OTHERS}
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-2/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-2/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-2/EQM-1/APEQM-1/RMOD-4/PHYANT-1
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-2/EQM-1/APEQM-1/RMOD-4/PHYANT-1

@{PARAMS_FOR_CA}
...    NRBTS:actCarrierAggregation=true
...    NRBTS:sCellActivationMethod=bufferBased
...    NRBTS:caConfigurationSupport=4CCDL_2CCUL
...    NRBTS:weightForIgnbCaSelection=20
...    NRBTS:actIncXn=true
...    NRBTS:maxNumScellsDl=2
...    NRBTS:maxNumScellsUl=2
...    NRBTS:actFdmEnhancedScheduling=true
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:carrierAggregationSupportList=ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Any_Sa,ca_Fdd_Any_Sa,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Fdd
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRDU-1:actInterGnbCa=DLOnly
...    NRDU-1:dlToUlContributionRatio=101
...    NRCELL:actK1Opt=intraAndInter-gNB
...    NRBTS:iGnbCaXnRemovalTmr=10
...    NRCELL:maxNumScellsDlFr1=3

@{handover_PARAMS}
...    NRBTS:actIntraFreqHoSA=false
...    NRBTS/NRPMRNL-1:miNrRelReportCu=5min
...    NRBTS:actInterFreqHoSA=true
...    NRCELL-1:a1MeashoEnabled=rsrp
...    NRCELL-1:a2MeashoEnabled=rsrp
...    NRCELL-1:a1MeashoEnabledSA=rsrp
...    NRCELL-1:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRCELL-1:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=60
...    NRCELL-1:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL-1:a2MeashoEnabledSA=rsrp
...    NRCELL-1:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0
...    NRCELL-1:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=35
...    NRCELL-1:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL-2:a1MeashoEnabled=rsrp
...    NRCELL-2:a2MeashoEnabled=rsrp
...    NRCELL-2:a1MeashoEnabledSA=rsrp
...    NRCELL-2:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRCELL-2:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=60
...    NRCELL-2:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL-2:a2MeashoEnabledSA=rsrp
...    NRCELL-2:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0
...    NRCELL-2:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=35
...    NRCELL-2:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL-1/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL-1/NRHOIF-1:a5MeasEnabled=none
...    NRCELL-1/NRHOIF-1:a1BasedPCellSwitchEnabled=false
...    NRCELL-1/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-1/NRHOIF-1:freqBandIndicatorNR=77
...    NRCELL-1/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf5
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf160
...    NRCELL-1/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-1/NRHOIF-1:scs=30 KHz
...    NRCELL-1/NRHOIF-1:ssBurstSetPeriod=10
...    NRCELL-1/NRHOIF-1:ssbFrequency=657984
...    NRCELL-2/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL-2/NRHOIF-1:a5MeasEnabled=none
...    NRCELL-2/NRHOIF-1:a1BasedPCellSwitchEnabled=false
...    NRCELL-2/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-2/NRHOIF-1:freqBandIndicatorNR=77
...    NRCELL-2/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-2/NRHOIF-1:ifhoSsbSmtcDuration=sf5
...    NRCELL-2/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf160
...    NRCELL-2/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-2/NRHOIF-1:scs=30 KHz
...    NRCELL-2/NRHOIF-1:ssBurstSetPeriod=10
...    NRCELL-2/NRHOIF-1:ssbFrequency=663360
...    NRCELL-1:measGapSelectionSA=favourUeThroughput
...    NRCELL-2:measGapSelectionSA=favourUeThroughput


@{PARAMS_FOR_GNB1}
...    NRCELL-1:sCellDeactivationTimerGNB=infinity
...    NRCELL-1:actBeamforming=true
...    NRCELL-1:nrCellType=4DL2UL
...    NRCELL-2:sCellDeactivationTimerGNB=infinity
...    NRCELL-2:actBeamforming=true
...    NRCELL-2:nrCellType=4DL2UL
...    NRDU-1:xgUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRCELL-1:iniNumSCellsToActivate=3
...    NRBTS:actGrflShdn=true
...    NRBTS:shutdownStepAmount=6
...    NRBTS:shutdownWindow=60
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRCELL-1:a1MeasSCellAddEnabled=rsrp
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=31
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=111
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-2:a1MeasSCellAddEnabled=rsrp
...    NRCELL-2:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL-2:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=31
...    NRCELL-2:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=111
...    NRCELL-2:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms


@{PARAMS_ADJ_REL_FOR_GNB1}
...    NRBTS:iGnbCaXnCfUpBackOffTmr=60
...    NRBTS:iGnbCaXnSetupReqTmr=60
...    NRBTS:iGnbCaXnSetupRespTmr=60
...    NRBTS:intGnbScellTempBlockTmr=60
...    NRBTS/NRADJGNB-2:administrativeState=Unlocked
...    NRBTS/NRADJGNB-2:gNbIdLength=22
...    NRBTS/NRADJGNB-2:gNodeBId=2
...    NRBTS/NRADJGNB-2:weightForIgnbCaSelection=50
...    NRBTS/NRADJGNB-2:xnLinkRef=1
...    NRBTS/NRADJGNB-2:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-2:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-2:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-3:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-3:fiveGsTac=200
...    NRBTS/NRADJNRCELL-3:freqBandIndicatorNR=77
...    NRBTS/NRADJNRCELL-3:gNbId=2
...    NRBTS/NRADJNRCELL-3:gNbIdLength=22
...    NRBTS/NRADJNRCELL-3:lcrId=3
...    NRBTS/NRADJNRCELL-3:nrarfcn=653400
...    NRBTS/NRADJNRCELL-3:physCellId=52
...    NRBTS/NRADJNRCELL-3:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-3:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-3:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-4:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-4:fiveGsTac=200
...    NRBTS/NRADJNRCELL-4:freqBandIndicatorNR=77
...    NRBTS/NRADJNRCELL-4:gNbId=2
...    NRBTS/NRADJNRCELL-4:gNbIdLength=22
...    NRBTS/NRADJNRCELL-4:lcrId=4
...    NRBTS/NRADJNRCELL-4:nrarfcn=648000
...    NRBTS/NRADJNRCELL-4:physCellId=53
...    NRBTS/NRADJNRCELL-4:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-4:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-4:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-11:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-11:fiveGsTac=200
...    NRBTS/NRADJNRCELL-11:freqBandIndicatorNR=3
...    NRBTS/NRADJNRCELL-11:gNbId=2
...    NRBTS/NRADJNRCELL-11:gNbIdLength=22
...    NRBTS/NRADJNRCELL-11:lcrId=11
...    NRBTS/NRADJNRCELL-11:nrarfcn=368400
...    NRBTS/NRADJNRCELL-11:physCellId=60
...    NRBTS/NRADJNRCELL-11:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-11:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-11:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-12:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-12:fiveGsTac=200
...    NRBTS/NRADJNRCELL-12:freqBandIndicatorNR=28
...    NRBTS/NRADJNRCELL-12:gNbId=2
...    NRBTS/NRADJNRCELL-12:gNbIdLength=22
...    NRBTS/NRADJNRCELL-12:lcrId=12
...    NRBTS/NRADJNRCELL-12:nrarfcn=153400
...    NRBTS/NRADJNRCELL-12:physCellId=61
...    NRBTS/NRADJNRCELL-12:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-12:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-12:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-2:gNbId=1
...    NRCELL-1/NRREL-2:gNbIdLength=22
...    NRCELL-1/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-2:lcrId=2
...    NRCELL-1/NRREL-2:removeNotAllowed=false
...    NRCELL-1/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-3:gNbId=2
...    NRCELL-1/NRREL-3:gNbIdLength=22
...    NRCELL-1/NRREL-3:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-3:lcrId=3
...    NRCELL-1/NRREL-3:removeNotAllowed=false
...    NRCELL-1/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-3:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-4:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-4:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-4:gNbId=2
...    NRCELL-1/NRREL-4:gNbIdLength=22
...    NRCELL-1/NRREL-4:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-4:lcrId=4
...    NRCELL-1/NRREL-4:removeNotAllowed=false
...    NRCELL-1/NRREL-4:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-4:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-4:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-4:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-4:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-11:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-11:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-11:gNbId=2
...    NRCELL-1/NRREL-11:gNbIdLength=22
...    NRCELL-1/NRREL-11:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-11:lcrId=11
...    NRCELL-1/NRREL-11:removeNotAllowed=false
...    NRCELL-1/NRREL-11:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-11:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-11:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-11:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-11:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-12:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-12:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-12:gNbId=2
...    NRCELL-1/NRREL-12:gNbIdLength=22
...    NRCELL-1/NRREL-12:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-12:lcrId=12
...    NRCELL-1/NRREL-12:removeNotAllowed=false
...    NRCELL-1/NRREL-12:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-12:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-12:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-12:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-12:gnbPlmn:mncLength=3
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
...    NRCELL-2/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-3:gNbId=2
...    NRCELL-2/NRREL-3:gNbIdLength=22
...    NRCELL-2/NRREL-3:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-3:lcrId=3
...    NRCELL-2/NRREL-3:removeNotAllowed=false
...    NRCELL-2/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-3:sCellOperationalMode=dlOnly
...    NRCELL-2/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-4:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-4:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-4:gNbId=2
...    NRCELL-2/NRREL-4:gNbIdLength=22
...    NRCELL-2/NRREL-4:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-4:lcrId=4
...    NRCELL-2/NRREL-4:removeNotAllowed=false
...    NRCELL-2/NRREL-4:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-4:sCellOperationalMode=dlOnly
...    NRCELL-2/NRREL-4:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-4:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-4:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-11:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-11:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-11:gNbId=2
...    NRCELL-2/NRREL-11:gNbIdLength=22
...    NRCELL-2/NRREL-11:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-11:lcrId=11
...    NRCELL-2/NRREL-11:removeNotAllowed=false
...    NRCELL-2/NRREL-11:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-11:sCellOperationalMode=dlOnly
...    NRCELL-2/NRREL-11:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-11:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-11:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-12:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-12:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-12:gNbId=2
...    NRCELL-2/NRREL-12:gNbIdLength=22
...    NRCELL-2/NRREL-12:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-12:lcrId=12
...    NRCELL-2/NRREL-12:removeNotAllowed=false
...    NRCELL-2/NRREL-12:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-12:sCellOperationalMode=dlOnly
...    NRCELL-2/NRREL-12:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-12:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-12:gnbPlmn:mncLength=3

@{PARAMS_FOR_GNB2}
...    NRBTS:iGnbCaXnCfUpBackOffTmr=60
...    NRBTS:iGnbCaXnSetupReqTmr=90
...    NRBTS:iGnbCaXnSetupRespTmr=60
...    NRBTS:intGnbScellTempBlockTmr=60
...    NRDU-1:xgUplane:ipV4AddressDN1=MRBTS-2/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRCELL-3:chBw=40MHz
...    NRCELL-3:gscnOrSsPbchArfcn=8055
...    NRCELL-3:actBeamforming=true
...    NRCELL-3:nrCellType=4DL2UL
...    NRCELL-4:actBeamforming=true
...    NRCELL-4:nrCellType=4DL2UL
...    NRCELL-3:sCellDeactivationTimerGNB=infinity
...    NRCELL-4:sCellDeactivationTimerGNB=infinity
...    NRCELL-11:sCellDeactivationTimerGNB=infinity
...    NRCELL-12:sCellDeactivationTimerGNB=infinity
...    NRCELL-3:weightForSCellSelection=40
...    NRCELL-4:weightForSCellSelection=15
...    NRCELL-11:weightForSCellSelection=90
...    NRCELL-12:weightForSCellSelection=20
...    NRBTS:shutdownWindow=60
...    NRBTS:actGrflShdn=true
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRCELL-3:a2MeasSCellRelEnabled=rsrp
...    NRCELL-3:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-3:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=35|a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-3:a2MeasSCellRelSsbRsrq:a2HysteresisSCellRelSsbRsrq=0|a2TimeToTriggerSCellRelSsbRsrq=0ms
...    NRCELL-3:a2MeasSCellRelSsbRsrq:a2ThresholdSCellRelSsbRsrq=10|a2TimeToTriggerSCellRelSsbRsrq=0ms
...    NRCELL-4:a2MeasSCellRelEnabled=rsrp
...    NRCELL-4:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-4:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=35|a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-4:a2MeasSCellRelSsbRsrq:a2HysteresisSCellRelSsbRsrq=0|a2TimeToTriggerSCellRelSsbRsrq=0ms
...    NRCELL-4:a2MeasSCellRelSsbRsrq:a2ThresholdSCellRelSsbRsrq=10|a2TimeToTriggerSCellRelSsbRsrq=0ms

@{PARAMS_ADJ_REL_FOR_GNB2}
...    NRBTS/NRADJGNB-1:administrativeState=Unlocked
...    NRBTS/NRADJGNB-1:gNbIdLength=22
...    NRBTS/NRADJGNB-1:gNodeBId=1
...    NRBTS/NRADJGNB-1:weightForIgnbCaSelection=50
...    NRBTS/NRADJGNB-1:xnLinkRef=1
...    NRBTS/NRADJGNB-1:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-1:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-1:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-1:fiveGsTac=200
...    NRBTS/NRADJNRCELL-1:gNbId=1
...    NRBTS/NRADJNRCELL-1:gNbIdLength=22
...    NRBTS/NRADJNRCELL-1:lcrId=1
...    NRBTS/NRADJNRCELL-1:nrarfcn=663400
...    NRBTS/NRADJNRCELL-1:physCellId=50
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-2:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-2:fiveGsTac=200
...    NRBTS/NRADJNRCELL-2:gNbId=1
...    NRBTS/NRADJNRCELL-2:gNbIdLength=22
...    NRBTS/NRADJNRCELL-2:lcrId=2
...    NRBTS/NRADJNRCELL-2:nrarfcn=658000
...    NRBTS/NRADJNRCELL-2:physCellId=51
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mncLength=3

@{PARAMS_FOR_OTHERS}


...    NRBTS:actRanSharing=false
...    NRCELL:actCDrx=false

@{online_modify_administrativeState_to_Shutting_Down}
...    MRBTS-1/NRBTS-1/NRCELL-1:administrativeState=Shutting Down

@{online_modify_administrativeState_to_Unlock}
...    MRBTS-1/NRBTS-1/NRCELL-1:administrativeState=Unlocked

@{UE1activatedSuccessfullyAirphoneCheck}
...    pcid:52, scellIdx:1
...    SCellIndex 1 activated successfully at airphone

@{UE4scelladditionAirphoneCheck}
...    pcid:52, scellIdx:1

@{unexpect_check}    sCellIndex2

@{UE4CCactivatedSuccessfullyAirphoneCheck}
...    pcid:52, scellIdx:1
...    pcid:60, scellIdx:2
...    pcid:61, scellIdx:3
...    SCellIndex 3 activated successfully at airphone
...    SCellIndex 2 activated successfully at airphone
...    SCellIndex 1 activated successfully at airphone

@{UE3CCactivatedSuccessfullyAirphoneCheck}
...    pcid:52, scellIdx:1
...    pcid:53, scellIdx:2
...    SCellIndex 2 activated successfully at airphone
...    SCellIndex 1 activated successfully at airphone

@{online_modify_scell_administrativeState_to_Shuttingdown}
...    NRCELL-3:administrativeState=Shutting Down

@{online_modify_scell_administrativeState_to_Unlocked}
...    NRCELL-3:administrativeState=Unlocked

@{Scell_release_expect}
...    sCellToReleaseList{1}

@{A030_Expect}
...    pcid:52, scellIdx:1
...    pcid:53, scellIdx:2
...    SCellIndex 2 activated successfully at airphone
...    SCellIndex 1 activated successfully at airphone

@{A031_Expect}
...    pcid:60, scellIdx:2
...    pcid:61, scellIdx:3
...    pcid:52, scellIdx:1
...    SCellIndex 2 activated successfully at airphone
...    SCellIndex 3 activated successfully at airphone
...    SCellIndex 1 activated successfully at airphone

@{Online_modification_for_A031_GNB1}
...    NRBTS:sCellActivationMethod=blind
...    NRBTS:maxNumScellsDl=3
...    NRBTS:maxNumScellsUl=3
...    NRCELL-1:maxNumScellsDlFr1=4
...    NRCELL-1:actCDrx=true
...    NRCELL:dlMimoMode=4x4 or 4x2 Open Loop Spatial Multiplexing
...    NRCELL:nonGbrNrDrxDN=MRBTS-1/NRBTS-1/NRDRX-1
...    NRDRX-1:drxInactivityTimer=20ms
...    NRDRX-1:drxLongCycle=40ms
...    NRDRX-1:drxOnDurationTimer=4ms
...    NRDRX-1:drxRetransTimerDl=16slot
...    NRDRX-1:drxRetransTimerUl=16slot
...    NRCELL-1:a1MeasSCellAddEnabled=rsrq
...    NRCELL-1:a1MeasSCellAddSsbRsrq:a1HysteresisSCellAddSsbRsrq=0
...    NRCELL-1:a1MeasSCellAddSsbRsrq:a1ThresholdSCellAddSsbRsrq=111
...    NRCELL-1:a1MeasSCellAddSsbRsrq:a1TimeToTriggerSCellAddSsbRsrq=320ms

@{Online_modification_for_A031_GNB2}
...    NRCELL-3:actPciBasedCsiImRandomization=false
...    NRCELL-4:actPciBasedCsiImRandomization=false
...    NRCELL-3:dlMimoMode=4x4 or 4x2 Open Loop Spatial Multiplexing
...    NRCELL-4:dlMimoMode=4x4 or 4x2 Open Loop Spatial Multiplexing
...    NRCELL-3:actCsirsMultiplexing=true
...    NRCELL-4:actCsirsMultiplexing=true
...    NRCELL:actCDrx=false
...    NRCELL-3:weightForSCellSelection=100
...    NRCELL-4:weightForSCellSelection=10
...    NRCELL-11:weightForSCellSelection=100
...    NRCELL-12:weightForSCellSelection=100

@{Online_modification_for_A030_GNB1}
...    NRBTS:sCellActivationMethod=blind
...    NRBTS:maxNumScellsDl=3
...    NRBTS:maxNumScellsUl=3
...    NRCELL-1:maxNumScellsDlFr1=4
...    NRCELL:dlMimoMode=4x4 or 4x2 Open Loop Spatial Multiplexing
...    NRCELL:nonGbrNrDrxDN=MRBTS-1/NRBTS-1/NRDRX-1
...    NRDRX-1:drxInactivityTimer=20ms
...    NRDRX-1:drxLongCycle=40ms
...    NRDRX-1:drxOnDurationTimer=4ms
...    NRDRX-1:drxRetransTimerDl=16slot
...    NRDRX-1:drxRetransTimerUl=16slot
...    NRCELL:actCDrx=false
...    NRCELL-1/NRREL-3:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-4:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-11:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-12:sCellAdditionMethod=blind

@{Online_modification_for_A030_GNB2}
...    NRCELL-3:actPciBasedCsiImRandomization=true
...    NRCELL-4:actPciBasedCsiImRandomization=true
...    NRCELL-3:weightForSCellSelection=100
...    NRCELL-4:weightForSCellSelection=10
...    NRCELL-11:weightForSCellSelection=100
...    NRCELL-12:weightForSCellSelection=100
...    NRCELL-3:dlMimoMode=4x4 or 4x2 Open Loop Spatial Multiplexing
...    NRCELL-4:dlMimoMode=4x4 or 4x2 Open Loop Spatial Multiplexing
...    NRCELL-3:actCsirsMultiplexing=true
...    NRCELL-4:actCsirsMultiplexing=true
...    NRCELL:actCDrx=false

####only support 2CC N77+N77#####
${SA_Capa_Support_2CC_CA}    SEPARATOR=
...    E9A09000575F5A13160003C4A0002C1262E003387A16009B20C39F30C7942C0E0980C0311C04EE3603606B04610D04083A41E006D6C98AB1A1CF88E3D033EC09F1891C790E7D4
...    73E618F28581C0E1E0BFFFFF800FFF8BE000C80000E0541B00B582308682041E20F0032B64C55890E7D813E238F1891C790E7D473E618F28581C0E1E13FB000000FEC000000C8
...    0000E0551B133582308682041D20F0030B64C55110E7C471E238F40CFB027C639F30C7942C0E070F05C00FFC007003FF000640000702A0D837AC1184341020F10780195B262AC
...    4873E238F604F8C48E3C873EA39F30C7942C0E070F09FFF000007FFC00000640000702A8D89BAC1184340000080780185B24CA88873E238F20C7A067D813E01CF9863CA160703
...    8782F55555553D555555432000038020B0F1300038980000002C0AC5C02000C260184C0001058158F80400181B03098061300006160562E0100060080C0D800102C0AC7C02000
...    C030181B0309A00050B0BAC5C02000C0D8184C0003058158780400184C000385815878040018020004058158783600181B000485815878040018060005058158780C00181B000
...    5858158B80400180603036000C0B02B0F06C0038980000342C0AC7C4D000C01018060303600110B02B0F1340038040800482C0AC7C02000C0D8184D0309A00130B0B804803700
...    1A0264002809A32800CD08428913639F0E2448913639F0E344891226C73E1C4891226C73E1C68912244D8E7C38912244D8E7C3851226C73E1C28913639F0E14489B1CF870A244
...    D8E7C3851226C73E1C4891226C73E1C28913639F0E344891226C73E1C28913639F0E344891226C73E18191018C6318C6318C6318C6301E836001E00140E0A00E0601280380030
...    120020301F048010000000080040000001000006008000010040000100200000C0100000800800005004002008020080000600400003802001000000040000400200002401000
...    0060080000A004000058020010240900400006019CA9ACA9AC14AC0CAC19AC15ACA5BC19BC05AC0DAC04AC08AC1DA0682000012CA4A080000CB29302000032CA48080001CB292
...    02000092CA48080002CB293020000D2CA48080003CB29202000112CA48080004CB29202000152CA48080005CB29282000192CA480800018B292019A55574AAAA9545D2A8AA0B1
...    54162A83455298AA4D154062A8145526AAA0F14340178095028140A05028140A05028140A05028140A0502814004C202004008080100220100200404008010100200440201802
...    8080100202004008C04030050100C014040080101002004402020028080800A0202C058C04030060100C014040300601002004402018028080600A02004008404030050100200
...    4202018028080600A10100C018040300608080600C02018028404030050100C014402018028080600C020180284040300601002004402004008080100202018028C0400801010
...    0200404030050100C014402004008080600C02018030C04008010100C01404030060100C014202004008081200A30100C01404030060100200404008011AA1F00010203040607
...    0A0B0C0D101112131418191B1C1D1F2125262728292A2D2F414182D0

####only support 3CC N77+N77+N77#####
${SA_Capa_Support_3CC_CA}    SEPARATOR=
...    E9A09000575F5A13160003C4A0002C1262E003387A16009B20C39F30C7942C0E0980C0311C04EE3603606B04610D04083A41E006D6C98AB1A1CF88E3D033EC09F1891C790E
...    7D473E618F28581C0E1E0B801FF800E000BE000C80000E0541B00B582308682041E20F0032B64C55890E7D813E238F1891C790E7D473E618F28581C0E1E13FB000000FEC00
...    0000C80000E0551B133582308682041D20F0030B64C55110E7C471E238F40CFB027C639F30C7942C0E070F05C00FFC007003FF000640000702A0D837AC1184341020F10780
...    195B262AC4873E238F604F8C48E3C873EA39F30C7942C0E070F09FFF000007FFC00000640000702A8D89BAC1184340000080780185B24CA88873E238F20C7A067D813E01CF
...    9863CA1607038782F55555553D555555432000038002B17130003898001C4C000002160402401B800D0132001404D19400088062448913639F0C02808CF41B000F000A0705
...    00703009401C0018090010180F82400800000004002000000080000300400000802000008010000060080000400400002802001004010040000300200001C0100080000002
...    00002001000012008000030040000500200002C01000812048020000300CE54D654D60A5606560CD60AD652DE4CDE02D606D6025604560ED03410000096525040000659498
...    10000196524040000E594901000049652404000165949810000696524040001E594901000089652404000265949010000A96524040002E5949410000C96524040000C59490
...    0CD2AABA55554AA2E95455058AA0B1541A2A94C55268AA031540A2A93555078A1A00BC04A8140A05028140A05028140A05028140A05028140A002210100200404008011008
...    0100202004008080100220100C014040080101002004602018028080600A02004008080100220101001404040050101602C602018030080600A02018030080100220100C01
...    4040300501002004202018028080100210100C014040300508080600C02018030404030060100C014202018028080600A20100C01404030060100C01420201803008010022
...    0100200404008010100C014602004008080100202018028080600A20100200404030060100C018602004008080600A02018030080600A3543E00020406080C0E1416181A20
...    22242628303236383A3E424A4C4E5052545A5E828305A0

*** Test Cases ***
CB008140_ET_KA002_PCell_graceful_shutdown_for_inter-gNB_CA_UEs_with_measurement_based_addition_and_buffer_based_activation
    [Documentation]
    ...    The purpose of this test case is to check following scenarios:
    ...    Cell lock with Graceful Cell Shutdown enabled is performed on the cell in prime-gNB which is the PCell for
    ...    inter-gNB CA UEs
    ...    1.scellAdditionMethod is configured to covBasedA1 and scellActivationMethod is configured to bufferBased
    ...    2.The locked Pcell is TDD
    ...    Requirement Coverage:
    ...    5G_RAN_USR_RRM_19018;5G_RAN_USR_RRM_19009, partially covered
    ...    It is about CB008140-K#B1: PCell lock with Graceful Cell Shutdown
    ...    CB008140-K#B5: PCell unlock
    ...    [Configuration]:
    ...    Cell id=1 gnb=2 pci=16:2 tac=200 tdd_cell=on band=n77 nr_arfcn=663400:663400 gscn=8159 chBw=100MHz Cellid=0x4001
    ...    Cell id=2 gnb=2 pci=17:0 tac=200 tdd_cell=on band=n77 nr_arfcn=658000:658000 gscn=8103 chBw=40MHz
    ...    Cell id=3 gnb=3 pci=17:1 tac=200 tdd_cell=on band=n77 nr_arfcn=653400:653400 gscn=8072 chBw=40MHz SCellWeight=40 Cellid=0x8003/32771
    ...    Cell id=4 gnb=3 pci=17:2 tac=200 tdd_cell=on band=n77 nr_arfcn=648000:648000 gscn=8000 chBw=40MHz SCellWeight=15 Cellid=0x8004/32772
    ...    Cell id=11 gnb=3 pci=20:0 tac=200 tdd_cell=off band=n3 nr_arfcn=349400:368400 gscn=4605 chBw=10MHz SCellWeight=90 Cellid=0x800b/32779
    ...    Cell id=12 gnb=3 pci=20:1 tac=200 tdd_cell=off band=n28 nr_arfcn=143400:153400 gscn=1916 chBw=15MHz SCellWeight=20 Cellid=0x800c/32780
    ...    2.Test Case Steps:
    ...         Step A. UE1 attach to Cell1_1 and trigger scell Activation with cell2_3
    ...         Step B. UE2 attach to Cell1_1 and trigger scell Activation with cell2_3_11_12
    ...         Step C. Online modify Cell1_1 Parameters administrativeState to Shutting Down
    ...         Step D. During cell1_1 is Shutting Down, UE1 Triggers Inter-Frequency HO to cell1_2
    ...         Step E. Online modify Cell1_1 Parameters administrativeState to UnLocked
    ...         Step F. Re-attach UE2 in cell1 and Trigger Scell Activation with cell2_3_11_12
    ...         Step G. Stop PDU and release UE
    ...         Step H. wireshark logs check
    ...    3. Expected Results:
    ...         Step A: UE1 Register And PDU Session Setup Successful, by A1 Add Cell2_3 as Scell
    ...         Step B: UE2 Register And PDU Session Setup Successful, by A1 Add cell2_3_11_12 as Scell
    ...         Step C: Online modify Cell1_1 Parameters administrativeState to Shutting Down successfully
    ...           2). Cell1_1 will from Shutting Down to Locked status
    ...           3). UE2 will be release
    ...         Step D:
    ...           1). During cell1_1 is Shutting Down, UE1 HO to cell1_2 is successfully
    ...           2). Cell1_1 becomes Disabled/Locked after the duration of the cell shutdown operation
    ...           gNB1 triggers common UE Bulk Release (5G_CP_CONF_1754, triggered due to cell lock) and releases all remaining UE context(s)
    ...          (CA: UE2) on Cell1_1 (as PCell), gNB1-DU cleans up outgoing CA relationship between PCell (Cell1_1) and ext-SCells
    ...          (Cell2_3 & Cell2_11 & Cell2_12) due to last CA UE release and un-registers Xp-U for Cell1_1 in XPIF component due to Cell1_1 lock
    ...           3). Each sub-step below is executed in parallel:
    ...           a). Prime-gNB1-CU-CP initiates F1 Reset
    ...           b). Prime-gNB1-CU-CP sends the F1AP:RESET to prime-gNB1-DU over F1,Reset Type is set to Part of F1 interface and include all
    ...           impacted UEs in UE-associated logical F1-connection list (UE2).
    ...           c). Prime-gNB1-DU responds with F1AP: RESET ACKNOWLEDGE to prime-gNB1-CU-CP.
    ...           d). Prime-gNB1-CU-CP initiates E1 Reset.
    ...           e). Prime-gNB1-CU-CP sends the E1AP: RESET to prime-gNB1-CU-UP over E1,Reset Type shall be set to Part of E1 interface and
    ...           include all impacted UEs in UE-associated logical E1-connection list (UE2).
    ...           f). Prime-gNB1-CU-UP responds with E1AP: RESET ACKNOWLEDGE to prime-gNB1-CU-CP.
    ...           g). Prime-gNB1-CU-CP initiates NG Reset.
    ...           h). Prime-gNB1-CU-CP sends the NG RESET to AMF over NG, Reset Type shall be set to Part of NG interface and include all impacted
    ...           UEs in UE-associated logical NG-connection list (UE2).
    ...           i). AMF responds with NG RESET ACKNOWLEDGE to prime-gNB1-CU-CP.
    ...           g). Prime-gNB1-CU-CP initiates Xn Reset.
    ...           k). Prime-gNB1-CU-CP sends the Xn: Reset Request to gNB2 over Xn, Reset Type shall be set to Partial Reset and include all
    ...           impacted UEs in UE contexts to be released List (UE2), Ext-gNB2 will send to RESET ACKNOWLEDGE.
    ...           l). gNB2 triggers common UE Bulk Release for CA UE context in ext-gNB (5G_CP_CONF_1754, triggered due to Xn reset) and releases
    ...           the corresponding IgNB-CA UE contexts on Cell2_3 (as ext-SCell) for UE1 and on Cell2_3 & Cell2_11 & Cell2_12(as ext-SCells) for
    ...           UE2,gNB2-DU cleans upincoming CA relationship between ext-SCells (Cell2_3 & Cell2_11 & Cell2_12) and PCell (Cell1_1) due to last
    ...           CA UE release.
    ...           m). Ext-gNB2-CU-CP initiates F1 Reset.
    ...           n). Ext-gNB2-CU-CP sends the F1AP: RESET to ext-gNB2-DU over F1, Reset Type is set to Part of F1 interface and include all
    ...           impacted UEs in UE-associated logical F1-connection list (UE2).
    ...           u). Ext-gNB2-DU responds with F1AP: RESET ACKNOWLEDGE to ext-gNB2-CU-CP.
    ...           v). gNB2 responses Xn: Reset Response to gNB1.
    ...           w). gNB1-CU-CP sends XnAP: NG-RAN NODE CONFIGURATION UPDATE indicating Cell1_1 deletion to gNB2-CU-CP
    ...           x). gNB2-CU-CP responses XnAP: NG-RAN NODE CONFIGURATION ACKNOWLEDGE to gNB1-CU-CP
    ...         Step E.
    ...           1). Online modify Cell1_1 Parameters administrativeState to UnLocked is successfully
    ...           2). Cell1_1 is activated and on air
    ...           3). gNB1 sends XnAP: NG-RAN NODE CONFIGURATION UPDATE indicating Cell1_1 addition to gNB2
    ...           4). gNB2 responses XnAP: NG-RAN NODE CONFIGURATION ACKNOWLEDGE to gNB1
    ...         Step F. UE2 Register And PDU Session Setup Successful, by A1 Add cell2_3_11_12 as Scell
    ...         Step G: all PDU and UE deregister successfully
    ...         Step H. wireshark logs check passed
    [Tags]    QC_281916    KA002    CA_LABEL-TT(100MHz_TDD_n77+40MHz_TDD_n77)
    ...    CA_LABEL-TTFF(100MHz_TDD_n77+40MHz_TDD_n77+10MHz_FDD_n3+15MHz_FDD_n28)
    UE1 scell Activation with cell2_3
    UE2 scell Activation with cell2_3_11_12
    Online Update Parameters    ${online_modify_administrativeState_to_Shutting_Down}
    UE1 Triggers Inter-Frequency HO to cell2
    Online Update Parameters    ${online_modify_administrativeState_to_Unlock}
    Re-attach UE2 in cell1 and Trigger Scell Activation
    Stop PDU and release UE
    Check WireShark Log    ${CURDIR}${/}A2A_KA_002${/}a2a.ini    wait_string=UEContextModificationResponse::23
    Check WireShark Log GNB2    ${CURDIR}${/}A2A_KA_002${/}a2a_gnb2.ini    wait_string=IgNBCAReleaseRequestAcknowledge::2

CB008140-ET-KB002_SCell graceful shutdown for inter-gNB CA UEs with measurement based addition and buffer based activation
    [Documentation]
    ...    It is about CB008140-K#B3: Ext-SCell lock with Graceful Cell Shutdown;CB008140-K#B6: Ext-SCell unlock
    ...    [Configuration]:
    ...    Cell id=1 gnb=2 pci=16:2 tac=200 tdd_cell=on band=n77 nr_arfcn=663400:663400 gscn=8159 chBw=100MHz Cellid=0x4001
    ...    Cell id=2 gnb=2 pci=17:0 tac=200 tdd_cell=on band=n77 nr_arfcn=658000:658000 gscn=8103 chBw=40MHz
    ...    Cell id=3 gnb=3 pci=17:1 tac=200 tdd_cell=on band=n77 nr_arfcn=653400:653400 gscn=8072 chBw=40MHz SCellWeight=40 Cellid=0x8003/32771
    ...    Cell id=4 gnb=3 pci=17:2 tac=200 tdd_cell=on band=n77 nr_arfcn=648000:648000 gscn=8000 chBw=40MHz SCellWeight=15 Cellid=0x8004/32772
    ...    Cell id=11 gnb=3 pci=20:0 tac=200 tdd_cell=off band=n3 nr_arfcn=349400:368400 gscn=4605 chBw=10MHz SCellWeight=90 Cellid=0x800b/32779
    ...    Cell id=12 gnb=3 pci=20:1 tac=200 tdd_cell=off band=n28nr_arfcn=143400:153400 gscn=1916 chBw=15MHz SCellWeight=20 Cellid=0x800c/32780
    ...    2.Test Case Steps:
    ...       Step a. UE3 Register And PDU Session Setup On Cell1_1,start traffic,then trigger A1 measurement to add cell2_3 and cell2_4 as scells
    ...               UE4 Register And PDU Session Setup On Cell1_1,start traffic,then trigger A1 measurement to add cell2_3 scell
    ...       Step b. Online modify cell2_3 into shuttig down status,during shutdownWindow timer,trigger A2 to release scell2_3 of UE3 ,and add UE5
    ...                try to add cell2_3 as scell
    ...       Step c. After cell2_3 is locked,release all UEs manually,and online modify cell2_3 to unlocked status ,at last repeat Step a
    ...    3.Expected Results:
    ...       Step a: UE3 Register And PDU Session Setup Successfully,add cell2_3 and cell2_4 as scells
    ...               UE4 Register And PDU Session Setup Successfully,add cell2_3 as scell
    ...       Step b: UE3 scell2_3 release successfully and would not be deregistered,UE4 would be deregistered,UE5 add scell unsucessfully
    ...         gNB2 triggers common UE Bulk Release (5G_CP_CONF_1754), releases relevant IgNB-CA UE contexts (CA: UE4) on
    ...         Cell 2_3 (as ext-SCell) for UE4, gNB2-DU cleans up incoming CA relationship between ext-SCell (Cell2_3) and PCell (Cell1_1) due to
    ...           last CA UE release and un-registers Xp-U for Cell2_3 in XPIF component due to Cell2_3 lock
    ...         Each sub-step below is executed in parallel:
    ...           Ext-gNB2-CU-CP initiates F1 Reset.
    ...           Ext-gNB2-CU-CP sends the F1AP: RESET to Ext-gNB2-DU over F1, Reset Type is set to Part of F1 interface and include all
    ...              impacted UEs in UE-associated logical F1-connection list (UE4).
    ...           Ext-gNB2-DU responds with F1AP: RESET ACKNOWLEDGE to Ext-gNB2-CU-CP.
    ...           Ext-gNB2-CU-CP initiates E1 Reset.
    ...           Ext-gNB2-CU-CP sends the E1AP: RESET to prime-gNB1-CU-UP over E1, Reset Type shall be set to Part of E1 interface and include all
    ...             impacted UEs in UE-associated logical E1-connection list (UE4).
    ...           Ext-gNB2-CU-UP responds with E1AP: RESET ACKNOWLEDGE to prime-gNB1-CU-CP.
    ...           Ext-gNB2-CU-CP initiates NG Reset.
    ...           Ext-gNB2-CU-CP sends the NG RESET to AMF over NG, Reset Type shall be set to Part of NG interface and include all impacted UEs in
    ...             UE-associated logical NG-connection list (UE4).
    ...           AMF responds with NG RESET ACKNOWLEDGE to Ext-gNB2-CU-CP.
    ...           Ext-gNB2-CU-CP initiates Xn Reset.
    ...           Ext-gNB2-CU-CP sends the Xn: Reset Request to gNB1 over Xn, Reset Type shall be set to Partial Reset and include all
    ...              impacted UEs in UE contexts to be released List (UE4).
    ...             gNB1 triggers common UE Bulk Release for CA UE context in prime-gNB (5G_CP_CONF_1754, triggered due to Xn reset) and
    ...              releases the corresponding IgNB-CA UE contexts on Cell1_1 (as PCell) for UE4, gNB1-DU cleans up outgoing CA relationship
    ...              between PCell (Cell1_1) and ext-SCell (Cell2_3) due to last CA UE release.
    ...         Each sub-step below is executed in parallel:
    ...           Prime-gNB1-CU-CP initiates F1 Reset.
    ...           Prime-gNB1-CU-CP sends the F1AP: RESET to prime-gNB1-DU over F1, Reset Type is set to Part of F1 interface and include all
    ...             impacted UEsin UE-associated logical F1-connection list (UE4).
    ...           Prime-gNB1-DU responds with F1AP: RESET ACKNOWLEDGE to prime-gNB1-CU-CP.
    ...           Prime-gNB1-CU-CP initiates E1 Reset
    ...           Prime-gNB1-CU-CP sends the E1AP: RESET to prime-gNB1-CU-UP over E1, Reset Type shall be set to Part of E1 interface and include
    ...              all impacted UEs in UE-associated logical E1-connection list (UE4).
    ...           Prime-gNB1-CU-UP responds with E1AP: RESET ACKNOWLEDGE to prime-gNB1-CU-CP.
    ...           Prime-gNB1-CU-CP initiates NG Reset.
    ...           Prime-gNB1-CU-CP sends the NG RESET to AMF over NG, Reset Type shall be set to Part of NG interface and include all
    ...             impacted UEs inUE-associated logical NG-connection list (UE4).
    ...           AMF responds with NG RESET ACKNOWLEDGE to prime-gNB1-CU-CP.
    ...           gNB1 responses Xn: Reset Response to gNB2.
    ...           gNB2-CU-CP sends XnAP: NG-RAN NODE CONFIGURATION UPDATE indicating Cell2_3 deletion to gNB1-CU-CP
    ...           gNB1-CU-CP responses XnAP: NG-RAN NODE CONFIGURATION ACKNOWLEDGE to gNB2-CU-CP
    ...           gNB2-CU-CP sends XnAP: IGNB CA CONFIGURATION UPDATE INDICATION with IE cell-Availability indicating Cell2_1 unavailable
    ...             to gNB1-CU-CP
    ...       Step c: UEs resource releaseed successfully,and while cell2_3 is unlocked,UE3 one more time add scells successfully
    ...           Cell2_3 becomes Enabled/Unlocked
    ...           Cell2_3 is activated and on air
    ...           gNB2 sends XnAP: NG-RAN NODE CONFIGURATION UPDATE indicating Cell2_3 addition to gNB1
    ...           gNB1 responses XnAP: NG-RAN NODE CONFIGURATION ACKNOWLEDGE to gNB2
    ...           gNB2 sends XnAP: IGNB CA CONFIGURATION UPDATE INDICATION with IE cell-Availability indicating Cell2_3 available to gNB1
    [Tags]    QC_281915    KB002    CA_LABEL-TTT(100MHz_TDD_n77+40MHz_TDD_n77+40MHz_TDD_n77)    CA_LABEL-TT(100MHz_TDD_n77+40MHz_TDD_n77)
    UE3 scell Activation with cell2_3_4
    UE4 scell addition with cell2_3
    Delta Commission To shutting down
    Send A2 release UE SCell    ue_id=3
    UE5 scell Addition unsucessfully with cell2_3
    sleep    60s    #wait cell2_3 goes into locked status
    Release UEs    ue_type=all
    Delta Commission To unlcoked
    UE3 scell Activation with cell2_3_4
    Check WireShark Log    ${CURDIR}${/}A2A_KB_002${/}a2a.ini    wait_string=IgNBCAReleaseRequestAcknowledge::1
    Check WireShark Log GNB2    ${CURDIR}${/}A2A_KB_002${/}a2a_gnb2.ini    wait_string=UEContextRelease::4
    Release UEs    ue_type=all

CNI-92536-ET-A031_Verify_InterGnb_CA_Scell_CSIRS_allocate_and_multiplexing_successfully_with_DRX_Enabled_during_A1_scell_addition_TTFF
    [Documentation]
    ...    The purpose of this test case is to check following scenario:
    ...      Verify scell's CSIRS allocate successfully on DRX duration when perform interGnb scell addtion with actPciBasedCsiImTandomization
    ...      as true
    ...    Requirement Coverage:
    ...      5G_CP_ARC_ALG_10842, partially covered
    ...        This user scenario intends to verify that Scell resource allocation for CA case when P(S)Cell setup and SCell addition are
    ...        triggered separately
    ...    [Configuration]:
    ...    Cell id=1 gnb=2 pci=16:2 tac=200 tdd_cell=on band=n77 nr_arfcn=663400:663400 gscn=8159 chBw=100MHz Cellid=0x4001
    ...    Cell id=2 gnb=2 pci=17:0 tac=200 tdd_cell=on band=n77 nr_arfcn=658000:658000 gscn=8103 chBw=40MHz
    ...    Cell id=3 gnb=3 pci=17:1 tac=200 tdd_cell=on band=n77 nr_arfcn=653400:653400 gscn=8055 chBw=40MHz SCellWeight=40 Cellid=0x8003/32771
    ...    Cell id=4 gnb=3 pci=17:2 tac=200 tdd_cell=on band=n77 nr_arfcn=648000:648000 gscn=8000 chBw=40MHz SCellWeight=15 Cellid=0x8004/32772
    ...    Cell id=11 gnb=3 pci=20:0 tac=200 tdd_cell=off band=n3 nr_arfcn=349400:368400 gscn=4605 chBw=10MHz SCellWeight=90 Cellid=0x800b/32779
    ...    Cell id=12 gnb=3 pci=20:1 tac=200 tdd_cell=off band=n28 nr_arfcn=143400:153400 gscn=1916 chBw=15MHz SCellWeight=20 Cellid=0x800c/32780
    ...    2.Test Case Steps:
    ...        a. UE6 register and PDU session setup On Cell2_1,trigger A1 to setup CA,then start traffic verification
    ...        b. UE7-9 register and PDU session setup On Cell2_1,then trigger A1 to setup CA
    ...        c. UE10 register and PDU session setup On Cell2_1,trigger A1 to setup CA,then start traffic verification
    ...        d. Release UEs
    ...    3. Expected Results:
    ...         Step a: UE6 successfully add Cell3_3/11/12 as scells,traffic is ok
    ...                1 CSIRS resource is allocated successfully for each scell, rrc message nzp_CSI_RS_ResourceToAddModList.nrofPorts=p4
    ...         Step b: UE7-9 successfully add Cell3_3/11/12 as scells to grab resource
    ...         Step c: UE10 successfully add Cell3_3/11/12 as scells,traffic is ok
    ...                1 CSIRS resource is allocated successfully for each scell, rrc message nzp_CSI_RS_ResourceToAddModList.nrofPorts=p4
    ...                UE6 and UE10 multiplexing successfully:
    ...                  slot and firstOFDMSymbolinTimeDomain of Scell's CSIRS resource for UE-6 should be the same with UE-10's
    ...    search "Csi rs allocate successful" in cprt,you will see UE6/10 are same:
    ...      Csi rs allocate successful. SCellId=32771,CsiRs:[slot:0,index:7,resourcePoolType:csiRsSs
    ...      Csi rs allocate successful. SCellId=32771,CsiRs:[slot:0,index:7,resourcePoolType:csiRsSs
    ...         Step d: UEs are released successfully
    [Tags]    QC_301974    A031    CNI-92536    CA_LABEL-TTFF(100MHz_TDD_n77+40MHz_TDD_n77+10MHz_FDD_n3+15MHz_FDD_n28)
    Online Update Parameters_A030_A031    Online_Param=${Online_modification_for_A031_GNB1}
    Online Update Parameters gnb2_A030_A031    Online_Param=${Online_modification_for_A031_GNB2}
    Ue Register And PDU Session Setup Without Scell Addition_A031
    Release UEs    ue_type=all
    Check Wireshark Log    ${CURDIR}${/}a2a_CNI92536A031${/}a2a.ini    wait_string=UEContextRelease::50

CNI-92536-ET-A030_Verify_InterGnb_CA_Scell_CSIRS_allocate_multipex_successfully_without_DRX_actPciBasedCsiImRandomization_on_when_add_scell_blindly
    [Documentation]
    ...    The purpose of this test case is to check following scenario:
    ...      Verify scell's CSIRS allocate and multiplexing successfully when perform interGnb scell addtion with actPciBasedCsiImTandomization
    ...      as true and drx off
    ...    Requirement Coverage:
    ...      5G_CP_ARC_ALG_10842, partially covered
    ...        This user scenario intends to verify that Scell resource allocation for CA case when P(S)Cell setup and SCell addition are
    ...        triggered separately
    ...    [Configuration]:
    ...    Cell id=1 gnb=2 pci=16:2 tac=200 tdd_cell=on band=n77 nr_arfcn=663400:663400 gscn=8159 chBw=100MHz Cellid=0x4001
    ...    Cell id=2 gnb=2 pci=17:0 tac=200 tdd_cell=on band=n77 nr_arfcn=658000:658000 gscn=8103 chBw=40MHz
    ...    Cell id=3 gnb=3 pci=17:1 tac=200 tdd_cell=on band=n77 nr_arfcn=653400:653400 gscn=8055 chBw=40MHz SCellWeight=40 Cellid=0x8003/32771
    ...    Cell id=4 gnb=3 pci=17:2 tac=200 tdd_cell=on band=n77 nr_arfcn=648000:648000 gscn=8000 chBw=40MHz SCellWeight=15 Cellid=0x8004/32772
    ...    Cell id=11 gnb=3 pci=20:0 tac=200 tdd_cell=off band=n3 nr_arfcn=349400:368400 gscn=4605 chBw=10MHz SCellWeight=90 Cellid=0x800b/32779
    ...    Cell id=12 gnb=3 pci=20:1 tac=200 tdd_cell=off band=n28 nr_arfcn=143400:153400 gscn=1916 chBw=15MHz SCellWeight=20 Cellid=0x800c/32780
    ...    2.Test Case Steps:
    ...        a. UE11 register and PDU session setup On Cell2_1,then start traffic verification
    ...        b. UE12 register and PDU session setup On Cell2_1,then start traffic verification
    ...        c. Release UEs
    ...    3. Expected Results:
    ...         Step a: UE11 register and PDU session setup successfully,add Cell3_3 and Cell3_4 as scells,traffic is ok
    ...                1 CSIRS resource is allocated successfully for each scell, rrc message nzp_CSI_RS_ResourceToAddModList.nrofPorts=p4
    ...         Step b: UE12 register and PDU session setup successfully,add Cell3_3 and Cell3_4 as scells,traffic is ok
    ...                1 CSIRS resource is allocated successfully for each scell, rrc message nzp_CSI_RS_ResourceToAddModList.nrofPorts=p4
    ...                multiplexing successfully:
    ...                  slot and firstOFDMSymbolinTimeDomain of Scell's CSIRS resource for UE-12 should be the same with UE-11's
    ...         Step c: UEs are released successfully
    ...    search "Csi rs allocate successful" in cprt log,you will see UE11/12 are same:
    ...      UE11:
    ...      Csi rs allocate successful. SCellId=32771,CsiRs:[slot:100,index:13,resourcePoolType:csiRsData
    ...      Csi rs allocate successful. SCellId=32772,CsiRs:[slot:110,index:13,resourcePoolType:csiRsData
    ...      UE12:
    ...      Csi rs allocate successful. SCellId=32771,CsiRs:[slot:100,index:13,resourcePoolType:csiRsData
    ...      Csi rs allocate successful. SCellId=32772,CsiRs:[slot:110,index:13,resourcePoolType:csiRsData
    [Tags]    QC_301973    CNI-92536    A030    CA_LABEL-TTT(100MHz_TDD_n77+40MHz_TDD_n77+40MHz_TDD_n77)
    Online Update Parameters_A030_A031    Online_Param=${Online_modification_for_A030_GNB1}
    Online Update Parameters gnb2_A030_A031    Online_Param=${Online_modification_for_A030_GNB2}
    Ue Register And PDU Session Setup With Blind 3CC Scell Addition    ue_id=11
    Run Traffic And Verify Throughput_A030_A031    ue_id=11
    Ue Register And PDU Session Setup With Blind 3CC Scell Addition    ue_id=12
    Run Traffic And Verify Throughput_A030_A031    ue_id=12
    Release UEs    ue_type=all
    Check Wireshark Log    ${CURDIR}${/}a2a_CNI92536A030${/}a2a.ini    wait_string=UEContextRelease::20

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup 2Airphone Env    fddtdd_sansa_cmwv/6cells_gnb1_2T_gnb2_2T2F    ue_count=15

Modify Cfg
    Update Cfg    ue_param id=1 ue_nr_capabilities=${SA_Capa_Support_2CC_CA}
    Update Cfg    ue_param id=3 ue_nr_capabilities=${SA_Capa_Support_3CC_CA}
    Update Cfg    ue_param id=4 ue_nr_capabilities=${SA_Capa_Support_2CC_CA}
    Update Cfg    ue_param id=5 ue_nr_capabilities=${SA_Capa_Support_2CC_CA}
    Update Cfg    ue_param id=11 ue_nr_capabilities=${SA_Capa_Support_3CC_CA}
    Update Cfg    ue_param id=12 ue_nr_capabilities=${SA_Capa_Support_3CC_CA}
    ${set_cell3_gscn}    catenate
    ...    set_cell id=3 gnb=3 pci=17:1 tac=200 nrci=0x03 tdd_cell=on proxy=$PROXY_SERVER_IP:9999|$PROXY_SERVER_IP:8888 nr_arfcn=653400:653400
    ...    mandatory_for_activation=off gscn=8055
    Update Cfg    ${set_cell3_gscn}

UE1 scell Activation with cell2_3
    Ue Register And PDU Session Setup Without Scell Addition    ue_id=1    enb_id=2    cell_id=1
    Ue Run Traffic And Verify Throughput    ue_id=1
    UE1 Send A1 Trigger 2CC Scell Activation And Verify Throughput    ue_id=1

UE2 scell Activation with cell2_3_11_12
    Ue Register And PDU Session Setup Without Scell Addition    ue_id=2    enb_id=2    cell_id=1
    Ue Run Traffic And Verify Throughput    ue_id=2
    UE2 Send A1 Trigger 4CC Scell Activation And Verify Throughput    ue_id=2

UE3 scell Activation with cell2_3_4
    Ue Register And PDU Session Setup Without Scell Addition    ue_id=3    enb_id=2    cell_id=1
    Ue Run Traffic And Verify Throughput    ue_id=3
    UE3 Send A1 Trigger 3CC Scell Activation And Verify Throughput    ue_id=3

UE4 scell addition with cell2_3
    Ue Register And PDU Session Setup Without Scell Addition    ue_id=4    enb_id=2    cell_id=1
    UE4 Send A1 Trigger 2CC Scell addition     ue_id=4

UE5 scell Addition unsucessfully with cell2_3
    Ue Register And PDU Session Setup Without Scell Addition    ue_id=5    enb_id=2    cell_id=1
    UE5 Send A1 Trigger 2CC Scell addition unsucessfully     ue_id=5

Ue Register And PDU Session Setup Without Scell Addition
    [Arguments]    ${ue_id}=1    ${gateway}=1    ${enb_id}=2    ${cell_id}=1
    Execute Egate Command    ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=NG RM Regist
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${gateway}    pass_regexp=QoS Routing Table

Ue Run Traffic And Verify Throughput
    [Arguments]    ${ue_id}=1
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=1 protocol=tcp mbps=150 dir=dl
    ...    pass_regexp=Started Downlink Internal traffic over TCP on Ue
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=2 protocol=tcp mbps=150 dir=dl
    ...    pass_regexp=Started Downlink Internal traffic over TCP on Ue
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=3 protocol=tcp mbps=150 dir=dl
    ...    pass_regexp=Started Downlink Internal traffic over TCP on Ue
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=1 protocol=tcp mbps=50 dir=ul
    Verify Throughput    ue_id=${ue_id}    Tput_dl=240    Tput_ul=45

UE1 Send A1 Trigger 2CC Scell Activation And Verify Throughput
    [Arguments]    ${ue_id}=1    ${cellfreq}=663360
    #${scell1pci}=52
    ${ScellAdd_A1}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cellfreq}    event_type=A1
    ...    threshold=RSRP\ 31
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${ScellAdd_A1} event=A1 srsrp_nr=115 srsrq_nr=52
    ...    pass_regexp=${UE1activatedSuccessfullyAirphoneCheck}    fail_regexp=${unexpect_check}    timeout=20s
    Verify Throughput    ue_id=${ue_id}    Tput_dl=400    Tput_ul=45

UE2 Send A1 Trigger 4CC Scell Activation And Verify Throughput
    [Arguments]    ${ue_id}=1    ${cellfreq}=663360
    #${scell1pci}=52
    ${ScellAdd_A1}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cellfreq}    event_type=A1
    ...    threshold=RSRP\ 31
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${ScellAdd_A1} event=A1 srsrp_nr=115 srsrq_nr=52
    ...    pass_regexp=${UE4CCactivatedSuccessfullyAirphoneCheck}    timeout=20s
    Verify Throughput    ue_id=${ue_id}    Tput_dl=240    Tput_ul=45

UE3 Send A1 Trigger 3CC Scell Activation And Verify Throughput
    [Arguments]    ${ue_id}=1    ${cellfreq}=663360
    #${scell1pci}=52
    ${ScellAdd_A1}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cellfreq}    event_type=A1
    ...    threshold=RSRP\ 111
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${ScellAdd_A1} event=A1 srsrp_nr=115 srsrq_nr=52
    ...    pass_regexp=${UE3CCactivatedSuccessfullyAirphoneCheck}    timeout=20s
    Verify Throughput    ue_id=${ue_id}    Tput_dl=405    Tput_ul=45

UE5 Send A1 Trigger 2CC Scell addition unsucessfully
    [Arguments]    ${ue_id}=1    ${cellfreq}=663360
    #${scell1pci}=52
    ${ScellAdd_A1}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cellfreq}    event_type=A1
    ...    threshold=RSRP\ 31
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${ScellAdd_A1} event=A1 srsrp_nr=115 srsrq_nr=52
    ...    fail_regexp=scellIdx

UE4 Send A1 Trigger 2CC Scell addition
    [Arguments]    ${ue_id}=1    ${cellfreq}=663360
    #${scell1pci}=52
    ${ScellAdd_A1}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cellfreq}    event_type=A1
    ...    threshold=RSRP\ 31
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${ScellAdd_A1} event=A1 srsrp_nr=115 srsrq_nr=52
    ...    pass_regexp=${UE4scelladditionAirphoneCheck}    fail_regexp=${unexpect_check}

Online Update Parameters
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    BuiltIn.Log To Console    Online Update Parameters is done

Delta Commission To shutting down
    Delta Commission Parameters GNB2    ${online_modify_scell_administrativeState_to_Shuttingdown}
    BuiltIn.Log To Console    Online Update Parameters is done

Delta Commission To unlcoked
    Delta Commission Parameters GNB2    ${online_modify_scell_administrativeState_to_Unlocked}
    BuiltIn.Log To Console    Online Update Parameters is done
    sleep    60s    #wait xp setup

UE1 Triggers Inter-Frequency HO to cell2
    Report A2 and configured A3 for UE1
    UE1 Trigger HO from cell1 to cell2
    sleep    120s       #wait cell to locked

Report A2 and configured A3 for UE1
    [Arguments]    ${ue_id}=1
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}    663360    A2
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 srsrp_nr=30 srsrq_nr=30
    ...    rrcReconfigurationComplete

UE1 Trigger HO from cell1 to cell2
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=5 event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=51 nrsrp_nr=100 nrsrq_nr=80
    ...    pass_regexp=Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.2 performed

Re-attach UE2 in cell1 and Trigger Scell Activation
    sleep    60s         #wait cell to unlocked
    Ue Register And PDU Session Setup Without Scell Addition    ue_id=2    enb_id=2    cell_id=1
    Ue2 Run Traffic And Verify Throughput    ue_id=2
    UE2 Send A1 Trigger 4CC Scell Activation And Verify Throughput    ue_id=2

Ue2 Run Traffic And Verify Throughput
    [Arguments]    ${ue_id}=1
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=1 protocol=tcp mbps=150 dir=dl
    ...    pass_regexp=Started Downlink Internal traffic over TCP on Ue
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=2 protocol=tcp mbps=150 dir=dl
    ...    pass_regexp=Started Downlink Internal traffic over TCP on Ue
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=3 protocol=tcp mbps=150 dir=dl
    ...    pass_regexp=Started Downlink Internal traffic over TCP on Ue
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=4 protocol=tcp mbps=150 dir=dl
    ...    pass_regexp=Started Downlink Internal traffic over TCP on Ue
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=5 protocol=tcp mbps=150 dir=dl
    ...    pass_regexp=Started Downlink Internal traffic over TCP on Ue
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=6 protocol=tcp mbps=150 dir=dl
    ...    pass_regexp=Started Downlink Internal traffic over TCP on Ue
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=1 protocol=tcp mbps=50 dir=ul
    Verify Throughput    ue_id=${ue_id}    Tput_dl=380    Tput_ul=35

Verify Throughput
    [Arguments]    ${ue_id}=1    ${Tput_dl}=230    ${Tput_ul}=45    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pdsch    Throughput
    Should Not Match Regexp    ${scell_tput}    CellIndex-. *0 *0 *0 *0
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

Stop PDU and release UE
    Execute Egate Command    trf_data_stop ue=1,2 pdu=1    pass_regexp=Stopped Downlink Internal traffic on Ue
    Release UEs    ue_type=all

Send A2 release UE SCell
    [Arguments]    ${ue_id}=1    ${carrierfreq}=653376
    #${sleep_time}=15s
    Execute Egate Command    ue_meas_cfg_disp id=${ue_id} meas_obj_type=nr
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A2
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 scell=1 scell_rsrp=30 scell_rsrq=0
    ...    pass_regexp= ${Scell_release_expect}

Online Update Parameters_A030_A031
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir

Online Update Parameters GNB2_A030_A031
    [Arguments]    ${Online_Param}
    Delta Commission Parameters gnb2    ${Online_Param}
    cells should be onair gnb2
    sleep    30s    #wait for online modificatio works,not delete please

Ue Register And PDU Session Setup Without Scell Addition_A031
    FOR    ${index}    IN RANGE    6    11
        Ue Register And PDU Session Setup Without Scell Addition    ue_id=${index}
        UE Send A1 To Trigger 4CC CA setup    ue_id=${index}
        Run Traffic And Verify Throughput_A030_A031    ue_id=${index}
    END

UE Send A1 To Trigger 4CC CA setup
    [Arguments]    ${ue_id}=1    ${cellfreq}=663360    ${UE_Expect}=${A031_Expect}
    ${ScellAdd_A1}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cellfreq}    event_type=A1
    ...    threshold=RSRQ\ 111
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${ScellAdd_A1} event=A1 srsrq_nr=120
    ...    pass_regexp=${UE_Expect}

Run Traffic And Verify Throughput_A030_A031
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${qfi}=1
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} trf_id=1 protocol=tcp mbps=150 dir=dl
    ...    Started Downlink Internal traffic over TCP on Ue
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} trf_id=2 protocol=tcp mbps=150 dir=dl
    ...    Started Downlink Internal traffic over TCP on Ue
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} trf_id=3 protocol=tcp mbps=150 dir=dl
    ...    Started Downlink Internal traffic over TCP on Ue
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} trf_id=4 protocol=tcp mbps=150 dir=dl
    ...    Started Downlink Internal traffic over TCP on Ue
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} trf_id=5 protocol=tcp mbps=150 dir=dl
    ...    Started Downlink Internal traffic over TCP on Ue
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} trf_id=6 protocol=tcp mbps=150 dir=dl
    ...    Started Downlink Internal traffic over TCP on Ue    sleep_time=2
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} trf_id=1 protocol=tcp mbps=50 dir=ul
    Verify Throughput_A030_A031    ${ue_id}    ${pdu}    ${qfi}
    [teardown]    Stop Traffic_A030_A031    ${ue_id}    ${pdu}

Stop Traffic_A030_A031
    [Arguments]    ${ue_id}=1    ${pdu}=1
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=${pdu} dir=dl trf_id=1
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=${pdu} dir=dl trf_id=2
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=${pdu} dir=dl trf_id=3
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=${pdu} dir=dl trf_id=4
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=${pdu} dir=dl trf_id=5
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=${pdu} dir=dl trf_id=6
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=${pdu} dir=dl trf_id=7
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=${pdu} dir=dl trf_id=8
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=${pdu} dir=ul trf_id=1

Verify Throughput_A030_A031
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${qfi}=1    ${Tput_dl}=810    ${Tput_ul}=45    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    direction=ul    rate_type=ave
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pdsch    Throughput
#    Should Not Match Regexp    ${scell_tput}    CellIndex-. *0 *0 *0 *0
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

Ue Register And PDU Session Setup With Blind 3CC Scell Addition
    [Arguments]    ${ue_id}=1    ${gateway}=1    ${enb_id}=2    ${cell_id}=1    ${UE_Expect}=${A030_Expect}
    Execute Egate Command    ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${gateway}
    ...    pass_regexp=${UE_Expect}
