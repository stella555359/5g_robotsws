*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    CRT    CLOUD_5G_I_[LO][LO]_AP_[LOO]
...    owner-jun 3.ye    release-SBTS23R4    team-L3CN1_SG14
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${NOKIA_XNAP_PLUGIN_FLAG}    ${True}
${NOKIA_F1AP_PLUGIN_FLAG}    ${True}

@{PARAMS_IN_SCF}
...    @{PARAMS_FOR_CA}
...    @{PARAMS_FOR_GNB1}
...    @{PARAMS_ADJ_REL_FOR_GNB1}
...    @{PARAMS_FOR_OTHERS}
...    @{PARAMS_BWP_FOR_GNB1}
@{PARAMS_IN_SCF_GNB2}
...    @{PARAMS_FOR_CA}
...    @{PARAMS_FOR_GNB2}
...    @{PARAMS_ADJ_REL_FOR_GNB2}
...    @{PARAMS_FOR_OTHERS}

@{PARAMS_FOR_CA}
...    NRBTS:actCarrierAggregation=true
...    NRBTS:sCellActivationMethod=blind
...    NRBTS:caConfigurationSupport=4CCDL_2CCUL
...    NRBTS:weightForIgnbCaSelection=80
...    NRBTS:actIncXn=true
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:carrierAggregationSupportList=ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Any_Sa,ca_Fdd_Any_Sa,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Fdd
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRDU-1:actInterGnbCa=DLOnly
...    NRDU-1:dlToUlContributionRatio=101
...    NRCELL:actK1Opt=intraAndInter-gNB

@{PARAMS_FOR_GNB1}
...    NRBTS:actMultipleDedicatedBWPs=true
...    NRCELL:actEnhMultipleDedicatedBWPs=true
...    NRCELL:actPRBBlanking=false
...    NRCELL-1:sCellDeactivationTimerGNB=infinity
...    NRCELL-2:sCellDeactivationTimerGNB=infinity
...    NRDU-1:xgUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRBTS:iGnbCaXnCfUpBackOffTmr=60
...    NRBTS:iGnbCaXnSetupReqTmr=60
...    NRBTS:iGnbCaXnSetupRespTmr=60
...    NRBTS:intGnbScellTempBlockTmr=60
...    NRBTS:actBcsCheck=enabled_FR1
...    NRBTS:rejectSuppBcs=none
...    NRCELL:allowUnsuppBcOrBcs=complete BCS check
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRCELL:pucchModeSelect=longPucch
...    NRCELL-1:nrCellType=4DL2UL
...    NRCELL-1:dlMimoMode=4x4 or 4x2 Closed Loop Spatial Multiplexing
...    NRCELL-2:nrCellType=4DL2UL
...    NRCELL-2:dlMimoMode=4x4 or 4x2 Closed Loop Spatial Multiplexing
...    NRCELL-1:chBw=90MHz
...    NRCELL-1:reqMinNumPuschPrb=160
...    @{LOLO_AP_LOO_GNB1}

@{LOLO_AP_LOO_GNB1}
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1

@{PARAMS_ADJ_REL_FOR_GNB1}
...    NRCELL:a1MeasSCellAddEnabled=rsrpAndRsrq
...    NRCELL:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=31
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=111
...    NRCELL:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrq:a1HysteresisSCellAddSsbRsrq=0
...    NRCELL:a1MeasSCellAddSsbRsrq:a1ThresholdSCellAddSsbRsrq=30
...    NRCELL:a1MeasSCellAddSsbRsrq:a1TimeToTriggerSCellAddSsbRsrq=160ms
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
...    NRCELL-1/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-3:gNbId=2
...    NRCELL-1/NRREL-3:gNbIdLength=22
...    NRCELL-1/NRREL-3:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-3:lcrId=3
...    NRCELL-1/NRREL-3:removeNotAllowed=false
...    NRCELL-1/NRREL-3:sCellAdditionMethod=blind
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
...    NRCELL-1/NRREL-4:sCellAdditionMethod=blind
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
...    NRCELL-1/NRREL-11:sCellAdditionMethod=blind
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
...    NRCELL-1/NRREL-12:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-12:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-12:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-12:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-12:gnbPlmn:mncLength=3

@{PARAMS_BWP_FOR_GNB1}
...    NRCELL-1:pdcchAutoConfig:cellCoverageLevel=normal
...    NRCELL-1:pdcchAutoConfig:initialBWPMode=sameAsCoreset0
...    NRCELL-1:pdcchAutoConfig:pucchSize=36
...    NRCELL-1:pdcchAutoConfig:bwpChBwDedicated2=80MHz
...    NRCELL-1:pdcchAutoConfig:startCRBOfCoreset0=1
...    NRCELL-1:prachConfigurationIndex=160
...    NRCELL-1:pucchModeSelect=longPucch
...    NRCELL-1:periodicCsiAcquisition:csiReportPeriodicity=slots80
...    NRCELL-1:msg1FrequencyStart=36
...    BWP_PROFILE-5:bwpProfileId=5
...    BWP_PROFILE-5:bwpType=initial
...    BWP_PROFILE-5:locationAndBandwidthDl:cRbSizeDl=n217
...    BWP_PROFILE-5:locationAndBandwidthDl:cRbStartDl=crb0
...    BWP_PROFILE-5:locationAndBandwidthUl:cRbSizeUl=n217
...    BWP_PROFILE-5:locationAndBandwidthUl:cRbStartUl=crb0
...    BWP_PROFILE-5/PDCCH-1:alSelection=static
...    BWP_PROFILE-5/PDCCH-1:dciDedicatedAggregationLevel=AL4
...    BWP_PROFILE-5/PDCCH-1:dciPagingAggregationLevel=AL4
...    BWP_PROFILE-5/PDCCH-1:dciRaCompletionAggregationLevel=AL4
...    BWP_PROFILE-5/PDCCH-1:dciRaMsg2AggregationLevel=AL4
...    BWP_PROFILE-5/PDCCH-1:dciSiAggregationLevel=AL4
...    BWP_PROFILE-5/PDCCH-1:downgradeAL16toAL8=notAllowed
...    BWP_PROFILE-5/PDCCH-1:pdcchId=1
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:pdcchConfigCommonId=1
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceType=Type0A
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceType=Type0A
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=3|searchSpaceType=Type0A
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceType=Type0A
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceType=Type0A
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceType=Type0A
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceType=Type0A
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceType=Type0A
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceType=Type0A
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=1|searchSpaceType=Type0A
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceType=Type0A
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceType=Type1
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceType=Type1
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceType=Type1
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceType=Type1
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceType=Type1
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n4|searchSpaceType=Type1
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceType=Type1
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceType=Type1
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceType=Type1
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=2|searchSpaceType=Type1
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceType=Type1
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceType=Type2
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceType=Type2
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=3|searchSpaceType=Type2
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceType=Type2
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceType=Type2
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceType=Type2
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceType=Type2
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceType=Type2
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceType=Type2
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=3|searchSpaceType=Type2
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceType=Type2
...    BWP_PROFILE-56:bwpProfileId=56
...    BWP_PROFILE-56:bwpType=dedicated
...    BWP_PROFILE-56:locationAndBandwidthDl:cRbSizeDl=n245
...    BWP_PROFILE-56:locationAndBandwidthDl:cRbStartDl=crb0
...    BWP_PROFILE-56:locationAndBandwidthUl:cRbSizeUl=n245
...    BWP_PROFILE-56:locationAndBandwidthUl:cRbStartUl=crb0
...    BWP_PROFILE-56/PDCCH-1:alSelection=static
...    BWP_PROFILE-56/PDCCH-1:dciDedicatedAggregationLevel=AL4
...    BWP_PROFILE-56/PDCCH-1:dciPagingAggregationLevel=AL4
...    BWP_PROFILE-56/PDCCH-1:dciRaCompletionAggregationLevel=AL4
...    BWP_PROFILE-56/PDCCH-1:dciRaMsg2AggregationLevel=AL4
...    BWP_PROFILE-56/PDCCH-1:dciSiAggregationLevel=AL4
...    BWP_PROFILE-56/PDCCH-1:downgradeAL16toAL8=notAllowed
...    BWP_PROFILE-56/PDCCH-1:pdcchId=1
...    BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceType=Type0A
...    BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceType=Type0A
...    BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=3|searchSpaceType=Type0A
...    BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceType=Type0A
...    BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceType=Type0A
...    BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceType=Type0A
...    BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceType=Type0A
...    BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceType=Type0A
...    BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceType=Type0A
...    BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=4|searchSpaceType=Type0A
...    BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceType=Type0A
...    BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceType=Type1
...    BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceType=Type1
...    BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceType=Type1
...    BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceType=Type1
...    BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceType=Type1
...    BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n4|searchSpaceType=Type1
...    BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceType=Type1
...    BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceType=Type1
...    BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceType=Type1
...    BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=5|searchSpaceType=Type1
...    BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceType=Type1
...    BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceType=Type2
...    BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceType=Type2
...    BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=3|searchSpaceType=Type2
...    BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceType=Type2
...    BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceType=Type2
...    BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceType=Type2
...    BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceType=Type2
...    BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceType=Type2
...    BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceType=Type2
...    BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=6|searchSpaceType=Type2
...    BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceType=Type2
...    BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cceToRegMapping=nonInterleaved
...    BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:coresetId=1
...    BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cRbStart=0
...    BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:duration=1
...    BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:interleaverSize=none
...    BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:regBundleSize=n6
...    BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=120
...    BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:pdcchConfigDedicatedId=1
...    BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=0|searchSpaceType=Type3
...    BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-0-And-1-0|searchSpaceType=Type3
...    BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|searchSpaceType=Type3
...    BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceType=Type3
...    BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|searchSpaceType=Type3
...    BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|searchSpaceType=Type3
...    BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|searchSpaceType=Type3
...    BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceType=Type3
...    BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceType=Type3
...    BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|searchSpaceType=Type3
...    BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=7|searchSpaceType=Type3
...    BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|searchSpaceType=Type3
...    BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=1|searchSpaceType=UE-Specific
...    BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|searchSpaceType=UE-Specific
...    BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|searchSpaceType=UE-Specific
...    BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceType=UE-Specific
...    BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|searchSpaceType=UE-Specific
...    BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|searchSpaceType=UE-Specific
...    BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n5|searchSpaceType=UE-Specific
...    BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceType=UE-Specific
...    BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceType=UE-Specific
...    BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|searchSpaceType=UE-Specific
...    BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=8|searchSpaceType=UE-Specific
...    BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|searchSpaceType=UE-Specific
...    BWP_PROFILE-56/PDSCH-1:pdschId=1
...    BWP_PROFILE-56/PDSCH-1:pdschRat0RbgConfig=config1
...    BWP_PROFILE-55:bwpProfileId=55
...    BWP_PROFILE-55:bwpType=dedicated
...    BWP_PROFILE-55:locationAndBandwidthDl:cRbSizeDl=n217
...    BWP_PROFILE-55:locationAndBandwidthDl:cRbStartDl=crb0
...    BWP_PROFILE-55:locationAndBandwidthUl:cRbSizeUl=n217
...    BWP_PROFILE-55:locationAndBandwidthUl:cRbStartUl=crb0
...    BWP_PROFILE-55/PDCCH-1:alSelection=static
...    BWP_PROFILE-55/PDCCH-1:dciDedicatedAggregationLevel=AL4
...    BWP_PROFILE-55/PDCCH-1:dciPagingAggregationLevel=AL4
...    BWP_PROFILE-55/PDCCH-1:dciRaCompletionAggregationLevel=AL4
...    BWP_PROFILE-55/PDCCH-1:dciRaMsg2AggregationLevel=AL4
...    BWP_PROFILE-55/PDCCH-1:dciSiAggregationLevel=AL4
...    BWP_PROFILE-55/PDCCH-1:downgradeAL16toAL8=notAllowed
...    BWP_PROFILE-55/PDCCH-1:pdcchId=1
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceType=Type0A
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceType=Type0A
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=3|searchSpaceType=Type0A
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceType=Type0A
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceType=Type0A
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceType=Type0A
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceType=Type0A
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceType=Type0A
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceType=Type0A
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=9|searchSpaceType=Type0A
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceType=Type0A
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceType=Type1
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceType=Type1
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceType=Type1
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceType=Type1
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceType=Type1
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n4|searchSpaceType=Type1
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceType=Type1
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceType=Type1
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceType=Type1
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=10|searchSpaceType=Type1
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceType=Type1
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceType=Type2
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceType=Type2
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=3|searchSpaceType=Type2
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceType=Type2
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceType=Type2
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceType=Type2
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceType=Type2
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceType=Type2
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceType=Type2
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=11|searchSpaceType=Type2
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceType=Type2
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cceToRegMapping=nonInterleaved
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:coresetId=4
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cRbStart=0
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:duration=1
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:interleaverSize=none
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:regBundleSize=n6
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=120
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:pdcchConfigDedicatedId=1
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=0|searchSpaceType=Type3
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-0-And-1-0|searchSpaceType=Type3
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|searchSpaceType=Type3
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceType=Type3
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|searchSpaceType=Type3
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|searchSpaceType=Type3
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|searchSpaceType=Type3
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceType=Type3
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceType=Type3
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|searchSpaceType=Type3
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=12|searchSpaceType=Type3
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|searchSpaceType=Type3
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=4|searchSpaceType=UE-Specific
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|searchSpaceType=UE-Specific
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|searchSpaceType=UE-Specific
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceType=UE-Specific
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|searchSpaceType=UE-Specific
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|searchSpaceType=UE-Specific
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n5|searchSpaceType=UE-Specific
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceType=UE-Specific
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceType=UE-Specific
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|searchSpaceType=UE-Specific
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=13|searchSpaceType=UE-Specific
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|searchSpaceType=UE-Specific
...    BWP_PROFILE-55/PDSCH-1:pdschId=1
...    BWP_PROFILE-55/PDSCH-1:pdschRat0RbgConfig=config1
...    NRCELL-1:cellBwpList:bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-5|cellBwpId=0
...    NRCELL-1:cellBwpList:bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-56|cellBwpId=1
...    NRCELL-1:cellBwpList:bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-55|cellBwpId=2

@{PARAMS_FOR_GNB2}
...    NRBTS:iGnbCaXnCfUpBackOffTmr=60
...    NRBTS:iGnbCaXnSetupReqTmr=60
...    NRBTS:iGnbCaXnSetupRespTmr=60
...    NRBTS:intGnbScellTempBlockTmr=60
...    NRBTS:actBcsCheck=disabled
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:xgUplane:ipV4AddressDN1=MRBTS-2/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRCELL-3:chBw=70 MHz
...    NRCELL-4:chBw=70 MHz
...    NRCELL-11/NRCELL_FDD-1:chBwDl=10MHz
...    NRCELL-11/NRCELL_FDD-1:chBwUl=10MHz
...    NRCELL-12/NRCELL_FDD-1:chBwDl=10MHz
...    NRCELL-12/NRCELL_FDD-1:chBwUl=10MHz
...    NRCELL-3:gscnOrSsPbchArfcn=8055
...    NRCELL-12:type0CoresetConfigurationIndex=6
...    NRCELL-3:actBeamforming=true
...    NRCELL-3:nrCellType=4DL2UL
...    NRCELL-3:dlMimoMode=4x4 or 4x2 Closed Loop Spatial Multiplexing
...    NRCELL-4:actBeamforming=true
...    NRCELL-4:nrCellType=4DL2UL
...    NRCELL-4:dlMimoMode=4x4 or 4x2 Closed Loop Spatial Multiplexing
...    NRCELL-3:msg1FrequencyStart=22
...    NRCELL-4:msg1FrequencyStart=22
...    NRBTS:actFdmEnhancedScheduling=true
...    NRCELL-3:sCellDeactivationTimerGNB=infinity
...    NRCELL-4:sCellDeactivationTimerGNB=infinity
...    NRCELL-11:sCellDeactivationTimerGNB=infinity
...    NRCELL-12:sCellDeactivationTimerGNB=infinity
...    NRCELL-3:weightForSCellSelection=30
...    NRCELL-4:weightForSCellSelection=30
...    NRCELL-11:weightForSCellSelection=20
...    NRCELL-12:weightForSCellSelection=20
...    NRBTS:actMultipleDedicatedBWPs=true
...    NRCELL:actEnhMultipleDedicatedBWPs=true
...    NRCELL:actPRBBlanking=false
...    NRCELL:pucchModeSelect=longPucch
...    NRCELL-3:prachConfigurationIndex=160
...    NRCELL-4:prachConfigurationIndex=160
...    NRCELL-3:pdcchAutoConfig:cellCoverageLevel=normal
...    NRCELL-3:pdcchAutoConfig:initialBWPMode=sameAsCoreset0
...    NRCELL-3:pdcchAutoConfig:pucchSize=22
...    NRCELL-3:pdcchAutoConfig:bwpChBwDedicated2=60MHz
...    NRCELL-3:pdcchAutoConfig:startCRBOfCoreset0=1
...    NRCELL-4:pdcchAutoConfig:cellCoverageLevel=normal
...    NRCELL-4:pdcchAutoConfig:initialBWPMode=sameAsCoreset0
...    NRCELL-4:pdcchAutoConfig:pucchSize=22
...    NRCELL-4:pdcchAutoConfig:bwpChBwDedicated2=60MHz
...    NRCELL-4:pdcchAutoConfig:startCRBOfCoreset0=1
...    BWP_PROFILE-5:bwpProfileId=5
...    BWP_PROFILE-5:bwpType=initial
...    BWP_PROFILE-5:locationAndBandwidthDl:cRbSizeDl=n162
...    BWP_PROFILE-5:locationAndBandwidthDl:cRbStartDl=crb0
...    BWP_PROFILE-5:locationAndBandwidthUl:cRbSizeUl=n162
...    BWP_PROFILE-5:locationAndBandwidthUl:cRbStartUl=crb0
...    BWP_PROFILE-5/PDCCH-1:alSelection=static
...    BWP_PROFILE-5/PDCCH-1:dciDedicatedAggregationLevel=AL4
...    BWP_PROFILE-5/PDCCH-1:dciPagingAggregationLevel=AL4
...    BWP_PROFILE-5/PDCCH-1:dciRaCompletionAggregationLevel=AL4
...    BWP_PROFILE-5/PDCCH-1:dciRaMsg2AggregationLevel=AL4
...    BWP_PROFILE-5/PDCCH-1:dciSiAggregationLevel=AL4
...    BWP_PROFILE-5/PDCCH-1:downgradeAL16toAL8=notAllowed
...    BWP_PROFILE-5/PDCCH-1:pdcchId=1
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:pdcchConfigCommonId=1
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceType=Type0A
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceType=Type0A
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=3|searchSpaceType=Type0A
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceType=Type0A
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceType=Type0A
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceType=Type0A
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceType=Type0A
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceType=Type0A
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceType=Type0A
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=1|searchSpaceType=Type0A
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceType=Type0A
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceType=Type1
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceType=Type1
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceType=Type1
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceType=Type1
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceType=Type1
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n4|searchSpaceType=Type1
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceType=Type1
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceType=Type1
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceType=Type1
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=2|searchSpaceType=Type1
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceType=Type1
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceType=Type2
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceType=Type2
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=3|searchSpaceType=Type2
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceType=Type2
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceType=Type2
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceType=Type2
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceType=Type2
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceType=Type2
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceType=Type2
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=3|searchSpaceType=Type2
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceType=Type2
...    BWP_PROFILE-54:bwpProfileId=54
...    BWP_PROFILE-54:bwpType=dedicated
...    BWP_PROFILE-54:locationAndBandwidthDl:cRbSizeDl=n189
...    BWP_PROFILE-54:locationAndBandwidthDl:cRbStartDl=crb0
...    BWP_PROFILE-54:locationAndBandwidthUl:cRbSizeUl=n189
...    BWP_PROFILE-54:locationAndBandwidthUl:cRbStartUl=crb0
...    BWP_PROFILE-54/PDCCH-1:alSelection=static
...    BWP_PROFILE-54/PDCCH-1:dciDedicatedAggregationLevel=AL4
...    BWP_PROFILE-54/PDCCH-1:dciPagingAggregationLevel=AL4
...    BWP_PROFILE-54/PDCCH-1:dciRaCompletionAggregationLevel=AL4
...    BWP_PROFILE-54/PDCCH-1:dciRaMsg2AggregationLevel=AL4
...    BWP_PROFILE-54/PDCCH-1:dciSiAggregationLevel=AL4
...    BWP_PROFILE-54/PDCCH-1:downgradeAL16toAL8=notAllowed
...    BWP_PROFILE-54/PDCCH-1:pdcchId=1
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceType=Type0A
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceType=Type0A
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=3|searchSpaceType=Type0A
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceType=Type0A
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceType=Type0A
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceType=Type0A
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceType=Type0A
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceType=Type0A
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceType=Type0A
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=4|searchSpaceType=Type0A
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceType=Type0A
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceType=Type1
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceType=Type1
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceType=Type1
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceType=Type1
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceType=Type1
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n4|searchSpaceType=Type1
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceType=Type1
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceType=Type1
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceType=Type1
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=5|searchSpaceType=Type1
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceType=Type1
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceType=Type2
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceType=Type2
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=3|searchSpaceType=Type2
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceType=Type2
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceType=Type2
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceType=Type2
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceType=Type2
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceType=Type2
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceType=Type2
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=6|searchSpaceType=Type2
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceType=Type2
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cceToRegMapping=nonInterleaved
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:coresetId=1
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cRbStart=0
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:duration=1
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:interleaverSize=none
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:regBundleSize=n6
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=120
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:pdcchConfigDedicatedId=1
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=0|searchSpaceType=Type3
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-0-And-1-0|searchSpaceType=Type3
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|searchSpaceType=Type3
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceType=Type3
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|searchSpaceType=Type3
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|searchSpaceType=Type3
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|searchSpaceType=Type3
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceType=Type3
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceType=Type3
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|searchSpaceType=Type3
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=7|searchSpaceType=Type3
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|searchSpaceType=Type3
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=1|searchSpaceType=UE-Specific
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|searchSpaceType=UE-Specific
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|searchSpaceType=UE-Specific
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceType=UE-Specific
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|searchSpaceType=UE-Specific
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|searchSpaceType=UE-Specific
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n5|searchSpaceType=UE-Specific
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceType=UE-Specific
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceType=UE-Specific
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|searchSpaceType=UE-Specific
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=8|searchSpaceType=UE-Specific
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|searchSpaceType=UE-Specific
...    BWP_PROFILE-54/PDSCH-1:pdschId=1
...    BWP_PROFILE-54/PDSCH-1:pdschRat0RbgConfig=config1
...    BWP_PROFILE-53:bwpProfileId=53
...    BWP_PROFILE-53:bwpType=dedicated
...    BWP_PROFILE-53:locationAndBandwidthDl:cRbSizeDl=n162
...    BWP_PROFILE-53:locationAndBandwidthDl:cRbStartDl=crb0
...    BWP_PROFILE-53:locationAndBandwidthUl:cRbSizeUl=n162
...    BWP_PROFILE-53:locationAndBandwidthUl:cRbStartUl=crb0
...    BWP_PROFILE-53/PDCCH-1:alSelection=static
...    BWP_PROFILE-53/PDCCH-1:dciDedicatedAggregationLevel=AL4
...    BWP_PROFILE-53/PDCCH-1:dciPagingAggregationLevel=AL4
...    BWP_PROFILE-53/PDCCH-1:dciRaCompletionAggregationLevel=AL4
...    BWP_PROFILE-53/PDCCH-1:dciRaMsg2AggregationLevel=AL4
...    BWP_PROFILE-53/PDCCH-1:dciSiAggregationLevel=AL4
...    BWP_PROFILE-53/PDCCH-1:downgradeAL16toAL8=notAllowed
...    BWP_PROFILE-53/PDCCH-1:pdcchId=1
...    BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceType=Type0A
...    BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceType=Type0A
...    BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=3|searchSpaceType=Type0A
...    BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceType=Type0A
...    BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceType=Type0A
...    BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceType=Type0A
...    BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceType=Type0A
...    BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceType=Type0A
...    BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceType=Type0A
...    BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=9|searchSpaceType=Type0A
...    BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceType=Type0A
...    BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceType=Type1
...    BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceType=Type1
...    BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceType=Type1
...    BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceType=Type1
...    BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceType=Type1
...    BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n4|searchSpaceType=Type1
...    BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceType=Type1
...    BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceType=Type1
...    BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceType=Type1
...    BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=10|searchSpaceType=Type1
...    BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceType=Type1
...    BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceType=Type2
...    BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceType=Type2
...    BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=3|searchSpaceType=Type2
...    BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceType=Type2
...    BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceType=Type2
...    BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceType=Type2
...    BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceType=Type2
...    BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceType=Type2
...    BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceType=Type2
...    BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=11|searchSpaceType=Type2
...    BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceType=Type2
...    BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cceToRegMapping=nonInterleaved
...    BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:coresetId=4
...    BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cRbStart=0
...    BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:duration=1
...    BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:interleaverSize=none
...    BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:regBundleSize=n6
...    BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=120
...    BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:pdcchConfigDedicatedId=1
...    BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=0|searchSpaceType=Type3
...    BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-0-And-1-0|searchSpaceType=Type3
...    BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|searchSpaceType=Type3
...    BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceType=Type3
...    BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|searchSpaceType=Type3
...    BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|searchSpaceType=Type3
...    BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n4|searchSpaceType=Type3
...    BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceType=Type3
...    BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceType=Type3
...    BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|searchSpaceType=Type3
...    BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=12|searchSpaceType=Type3
...    BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|searchSpaceType=Type3
...    BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=4|searchSpaceType=UE-Specific
...    BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|searchSpaceType=UE-Specific
...    BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|searchSpaceType=UE-Specific
...    BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceType=UE-Specific
...    BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|searchSpaceType=UE-Specific
...    BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|searchSpaceType=UE-Specific
...    BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n5|searchSpaceType=UE-Specific
...    BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceType=UE-Specific
...    BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceType=UE-Specific
...    BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|searchSpaceType=UE-Specific
...    BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=13|searchSpaceType=UE-Specific
...    BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|searchSpaceType=UE-Specific
...    BWP_PROFILE-53/PDSCH-1:pdschId=1
...    BWP_PROFILE-53/PDSCH-1:pdschRat0RbgConfig=config1
...    NRCELL-3:cellBwpList:bwpDN=MRBTS-2/NRBTS-2/BWP_PROFILE-5|cellBwpId=0
...    NRCELL-3:cellBwpList:bwpDN=MRBTS-2/NRBTS-2/BWP_PROFILE-54|cellBwpId=1
...    NRCELL-3:cellBwpList:bwpDN=MRBTS-2/NRBTS-2/BWP_PROFILE-53|cellBwpId=2
...    NRCELL-4:cellBwpList:bwpDN=MRBTS-2/NRBTS-2/BWP_PROFILE-5|cellBwpId=0
...    NRCELL-4:cellBwpList:bwpDN=MRBTS-2/NRBTS-2/BWP_PROFILE-54|cellBwpId=1
...    NRCELL-4:cellBwpList:bwpDN=MRBTS-2/NRBTS-2/BWP_PROFILE-53|cellBwpId=2
...    @{LOLO_AP_LOO_GNB2}

@{LOLO_AP_LOO_GNB2}
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-2/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-2/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-2/EQM-1/APEQM-1/RMOD-4/PHYANT-1
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-2/EQM-1/APEQM-1/RMOD-4/PHYANT-1

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
...    NRBTS/NRADJNRCELL-1:freqBandIndicatorNR=77
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
...    NRBTS/NRADJNRCELL-2:freqBandIndicatorNR=77
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

@{activatedSuccessfullyAirphoneCheck}
...    pcid:52, scellIdx:1
...    pcid:53, scellIdx:2
...    SCellIndex 2 activated successfully at airphone
...    SCellIndex 1 activated successfully at airphone

${SA_Capa_Support_3CC_n77_with_90MHz}    SEPARATOR=
...    E9A09000575F5A13160003C4A0002C1262E003387A16009B20C39F30C7942C0E0980C0311C04EE3603606B04610D04083A41E006D6C98AB1A1CF88E3D033EC09F1891C790E7D4
...    73E618F28581C0E1E0BFFFFF800FFF8BE000C80000E0541B00B582308682041E20F0032B64A55890E7D813E238F1891C790E7D473E618F28581C0E1E13FB000000FEC000000C8
...    0000E0551B133582308682041D20F0030B64A55110E7C471E238F40CFB027C639F30C7942C0E070F05C0000C00700003000640000702A0D837AC1184341020F10780195B252AC
...    4873E238F604F8C48E3C873EA39F30C7942C0E070F09FFF000007FFC00000640000702A8D89BAC1184340000080780185B24CA88873E238F20C7A067D813E01CF9863CA160703
...    8782F55555553D555555432000038028B0F1300038980000002C0AC5C4C000C260184C000085BE80000000B17008003098061300004160563E01000606C0C260184C000185815
...    8B8040018020303600040B02B1F00800300C0606C0C26800142C2EB1700800303606130000C160561E010006130000E160561E0100060080010160561E0D800606C0012160561
...    E0100060180014160561E03000606C0016160562E0100060180C0D800302C0AC3C1B000E2600000D0B02B1713000309806008001C160563E2600061300C010181B0007858158B
...    8980018020303600100B02B1F134003004060180C0D800442C0AC3C4D000E010200120B02B1F008003036061340C268004C2C2E01200DC0068099000A0268CA004040C290A244
...    D8E7C38912244D8E7C38912244D8E7C38D1224489B1CF871224489B1CF871A2448913639F0E2448913639F0E14489B1CF870A244D8E7C3851226C73E1C28913639F0E14489B1C
...    F871224489B1CF870A244D8E7C38912244D8E7C38D1224489B1CF871224489B1CF871A2448913639F0E14489B1CF871A2448913639F0C074506318C6318C6318C6318C6318C7A
...    0D80078005038280381804A00E000C0480080C07C1200400000002001000000040000180200000401000004008000030040000200200001401000802008020000180100000E00
...    8004000000100001000800009004000018020000280100001600800409024010000180672A6B2A6B052B032B066B056B296F066F016B036B012B022B07681A0800004B2928200
...    0032CA4C080000CB29202000072CA480800024B292020000B2CA4C0800034B292020000F2CA480800044B29202000132CA480800054B29202000172CA4A0800064B2920200006
...    2CA480669555D2AAAA55174AA2A82C55058AA0D154A62A93455018AA051549AAA83C50D005E02540A05028140A05028140A05028140A05028140A050013080801002020040088
...    040080101002004040080110080600A02004008080100230100C014040300501002004040080110080800A02020028080B01630100C01804030050100C018040080110080600A
...    02018028080100210100C014040080108080600A02018028404030060100C018202018030080600A10100C014040300510080600A02018030080600A10100C018040080110080
...    100202004008080600A30100200404008010100C014040300510080100202018030080600C30100200404030050100C018040300508080100202048028C04030050100C018040
...    0801010020046A87C0004080C10181C282C30344044484C5060646C70747C8494989CA0A4A8B4BD05060B40

${SA_Capa_Support_3CC_n77_with_80MHz}    SEPARATOR=
...    E9A09000575F5A13160003C4A0002C1262E003387A16009B20C39F30C7942C0E0980C0311C04EE3603606B04610D04083A41E006D6C98AB1A1CF88E3D033EC09F1891C790E7D4
...    73E618F28581C0E1E0BFFFFF800FFF8BE000C80000E0541B00B582308682041E20F0032B64A55890E7D813E238F1891C790E7D473E618F28581C0E1E13FB000000FEC000000C8
...    0000E0551B133582308682041D20F0030B64A55110E7C471E238F40CFB027C639F30C7942C0E070F05C0000C00700003000640000702A0D837AC1184341020F10780195B252AC
...    4873E238F604F8C48E3C873EA39F30C7942C0E070F09FFF000007FFC00000640000702A8D89BAC1184340000080780185B24CA88873E238F20C7A067D813E01CF9863CA160703
...    8782F55555553D555555432000038028B0F1300038980000002C0AC5C4C000E2600071300000085BE80000000B1700800309806130000416FA00000002C7C02000C0D8184C030
...    9800030B02B170080030040606C0008160563E0100060180C0D8184D00028585D62E01000606C0C26000182C0AC3C02000C260001C2C0AC3C02000C01000202C0AC3C1B000C0D
...    800242C0AC3C02000C03000282C0AC3C06000C0D8002C2C0AC5C02000C030181B00060581587836001C4C00001A160562E2600061300C01000382C0AC7C4C000C260180203036
...    000F0B02B171300030040606C0020160563E2680060080C030181B0008858158789A001C02040024160563E01000606C0C268184D00098585C02401B800D0132001404D194008
...    08185214489B1CF871224489B1CF871224489B1CF871A2448913639F0E2448913639F0E344891226C73E1C4891226C73E1C28913639F0E14489B1CF870A244D8E7C3851226C73
...    E1C28913639F0E2448913639F0E14489B1CF871224489B1CF871A2448913639F0E2448913639F0E344891226C73E1C28913639F0E344891226C73E180E8A0C6318C6318C6318C
...    6318C6318F41B000F000A070500703009401C0018090010180F824008000000040020000000800003004000008020000080100000600800004004000028020010040100400003
...    00200001C010008000000200002001000012008000030040000500200002C01000812048020000300C652D654D60A5606560CD60AD652DE0CDE02D606D6025604560ED0341000
...    009652504000065949810000196524040000E594901000049652404000165949810000696524040001E594901000089652404000265949010000A96524040002E5949410000C9
...    6524040000C594900CD2AABA55554AA2E95455058AA0B1541A2A94C55268AA031540A2A93555078A1A00BC04A8140A05028140A05028140A05028140A05028140A00261010020
...    04040080110080100202004008080100220100C014040080101002004602018028080600A02004008080100220101001404040050101602C602018030080600A0201803008010
...    0220100C014040300501002004202018028080100210100C014040300508080600C02018030404030060100C014202018028080600A20100C01404030060100C0142020180300
...    80100220100200404008010100C014602004008080100202018028080600A20100200404030060100C018602004008080600A02018030080600A101002004040900518080600A
...    02018030080100202004008D50F8000810182030385058606880889098A0C0C8D8E0E8F909293139414951697A0A0C168


*** Test Cases ***
CB008140_ET_GF013_Verify_successful_blind_IgNB-CA_addition_with_P_large_or_small_S_small_when_actBcsChecksset_as_1
    [Documentation]
    ...    The purpose of this test case is to check following scenarios:
    ...    the band combination and bandwidth combination set check interaction with dedicated BWP support for IgNB-CA addition.
    ...    Requirement Coverage:
    ...    5G_RAN_USR_RRM_18337, partial covered
    ...    CB008140-GF#B5: BC and BCS check interaction with dedicated BWP support for IgNB-CA addition.
    ...    [Configuration]:
    ...    Cell id=1 gnb=2 pci=16:2 tac=200 tdd_cell=on band=n77 nr_arfcn=663400:663400 gscn=8159 chBw=100MHz
    ...    Cell id=2 gnb=2 pci=17:0 tac=200 tdd_cell=on band=n77 nr_arfcn=658000:658000 gscn=8103 chBw=40MHz
    ...    Cell id=3 gnb=3 pci=17:1 tac=200 tdd_cell=on band=n77 nr_arfcn=653400:653400 gscn=8055 chBw=100MHz weightForSCellSelection=30
    ...    Cell id=4 gnb=3 pci=17:2 tac=200 tdd_cell=on band=n77 nr_arfcn=648000:648000 gscn=8000 chBw=40MHz weightForSCellSelection=30
    ...    Cell id=11 gnb=3 pci=20:0 tac=200 tdd_cell=off band=n3 nr_arfcn=349400:368400 gscn=4605 chBw=10MHz weightForSCellSelection=20
    ...    Cell id=12 gnb=3 pci=20:1 tac=200 tdd_cell=off band=n28 nr_arfcn=143400:153400 gscn=1916 chBw=10MHz weightForSCellSelection=20
    ...    2.Test Case Steps:
    ...         Step a. UE1 Register And PDU Session Setup On Cell1_1 with scell addition
    ...         Step b. UE1 Run Traffic And Verify Throughput
    ...         Step c. UE2 Register And PDU Session Setup On Cell1_1 with scell addition
    ...         Step d. UE2 Run Traffic And Verify Throughput
    ...         Step e. stop all UE traffic and deregister UE
    ...         Step f. wireshark logs and counters check
    ...    3. Expected Results:
    ...         Step a: UE1 Register And PDU Session Setup On Cell1_1 with cell2_3 and cell2_4 scell addition Successfully
    ...         Step b: UE1 Run Traffic And Verify Throughput is ok
    ...         Step c. UE2 Register And PDU Session Setup On Cell1_1 with cell2_3 and cell2_4 scell addition Successfully
    ...         Step d. UE2 Run Traffic And Verify Throughput is ok
    ...         Step e. stop all UE traffic and deregister UE is OK
    ...         Step f. wireshark logs and counters check:
    ...         1) gNB1-CU sends XnAP: IGNB CA ADDITION REQUEST including IEs (BC and BCS Check Configuration->) 'allowUnsuppBcOrBcs' and 
    ...            'rejectSuppBcs' to gNB2-CU, and gNB2-CU sends F1AP: IGNB CA UE CONTEXT SETUP REQUEST including IEs (BC and BCS Check 
    ...             Configuration->) 'allowUnsuppBcOrBcs' and 'rejectSuppBcs' to gNB2-DU
    ...         2) CA_n77(3A) ignb ca is setup properly with scell2_3 and scell2_4
    [Tags]    QC_281421
    Ue Register And PDU Session Setup With Scell Addition    ue_id=1    enb_id=2    cell_id=1
    Run Traffic and Verify Throughput    ue_id=1
    Ue Register And PDU Session Setup With Scell Addition    ue_id=2    enb_id=2    cell_id=1
    Run Traffic and Verify Throughput    ue_id=2
    Release UEs    ue_type=all
    Check WireShark Log    ${CURDIR}${/}A2A_GF_013${/}a2a.ini    wait_string=UEContextModificationResponse::12
    Check WireShark Log GNB2    ${CURDIR}${/}A2A_GF_013${/}a2a_gnb2.ini    wait_string=IgNBCAReleaseRequestAcknowledge::2
	
*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup 2Airphone Env    fddtdd_sansa_cmwv/6cells_gnb1_2T_gnb2_2T2F

Modify Cfg
    Update Cfg    ue_param id=1 ue_nr_capabilities=${SA_Capa_Support_3CC_n77_with_90MHz}
    Update Cfg    ue_param id=2 ue_nr_capabilities=${SA_Capa_Support_3CC_n77_with_80MHz}
    ${set_cell3_gscn}    catenate
    ...    set_cell id=3 gnb=3 pci=17:1 tac=200 nrci=0x03 tdd_cell=on proxy=$PROXY_SERVER_IP:9999|$PROXY_SERVER_IP:8888 nr_arfcn=653400:653400
    ...    mandatory_for_activation=off gscn=8055
    Update Cfg    ${set_cell3_gscn}

Verify Throughput
    [Arguments]    ${ue_id}=1    ${Tput_dl}=10    ${Tput_ul}=10    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pdsch    Throughput
    ${scell_uput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pusch    Throughput
    Should Not Match Regexp    ${scell_tput}    CellIndex-.*Mbps.*Mbps.*Mbps.* 0 Mbps
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

Ue Register And PDU Session Setup With Scell Addition
    [Arguments]    ${ue_id}=1    ${gateway}=1    ${enb_id}=2    ${cell_id}=11
    Execute Egate Command    ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${gateway}    
    ...    pass_regexp=${activatedSuccessfullyAirphoneCheck}
    Sleep    5s    #wait all Scell info print

Run Traffic And Verify Throughput
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
    Verify Throughput    ue_id=${ue_id}    Tput_dl=410    Tput_ul=45
    [teardown]    Stop Traffic    ue_id=${ue_id}

Stop Traffic
    [Arguments]    ${ue_id}=1
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=1
