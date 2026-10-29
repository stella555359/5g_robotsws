*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags      QCD_MN_RAN    QCP_RAN_ET    RAN_5G    RAN_5G_TDD    CRT    SBTS00
...    owner-dandan.chen    owner-teana.wang    team-SG2    release-SBTS22R1    CB006138-F
...    CLOUD_5G_I_BOO_AP_LOO    AP_REG
Resource        ../../../../../resources/DevHZ5_resource.robot


*** Variables ***
${TL_TYPE_PATH}    fddtdd_sansa_cmwv/6cells_4T2F

@{PARAMS_IN_SCF}
...    @{PARAMS_FOR_CA}
...    @{PARAMS_FOR_5QI1}
...    @{PARAMS_FOR_NRCELL}
...    @{PARAMS_FOR_NRREL}
...    @{PARAMS_FOR_CELL_BWP_PROFILE}
...    @{PARAMS_FOR_NRSYSINFO_PROFILE}
...    @{PARAMS_FOR_NRDSSLTE}
...    @{PARAMS_FOR_XPAP}
...    @{FIX_RELATION_ERROR}


${CA_SUPPORT_LIST}    SEPARATOR=,
...    ca_Fr1Tdd_Any_Sa
...    ca_Fdd_Fr1Tdd_Sa
...    ca_Fdd_Fr1Tdd_Nsa
...    ca_Fdd_Fdd
...    ca_Fr1Tdd_Sa
...    ca_Fr1Tdd_Nsa
...    ca_Fr1Tdd_Fdd_Sa

@{PARAMS_FOR_CA}
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRDU-1:actInterNumerologyCa=true
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:carrierAggregationSupportList=${CA_SUPPORT_LIST}
...    NRBTS:actFdmEnhancedScheduling=true
...    NRBTS:actFdmScheduling=true

@{PARAMS_FOR_NRCELL}
...    NRCELLGRP-0:numberOfTransmittedSsBlocks=4 beams
...    NRCELLGRP-3:numberOfTransmittedSsBlocks=4 beams
...    NRCELL-1:actCDrx=true
...    NRCELL-1:actK1Opt=intra-gNB
...    NRCELL-1:pucchModeSelect=longPucch
...    NRCELL-1:pucchF3ModulationScheme=pi2bpsk
...    NRCELL-1:pucchF3MaxCodeRate=zeroDot08
...    NRCELL-1:actBeamforming=true
...    NRCELL-1:beamSet:basicBeamSet=beamSet_4
...    NRCELL-1:beamSet:leftEdgeAngle=60
...    NRCELL-1:beamSet:nrBtsBeamRefinementP2=false
...    NRCELL-1:beamSet:rightEdgeAngle=60
...    NRCELL-4:actCDrx=true
...    NRCELL-4:actK1Opt=intra-gNB
...    NRCELL-4:pucchModeSelect=longPucch
...    NRCELL-4:pucchF3ModulationScheme=pi2bpsk
...    NRCELL-4:pucchF3MaxCodeRate=zeroDot08
...    NRCELL-4:actBeamforming=true
...    NRCELL-4:beamSet:basicBeamSet=beamSet_4
...    NRCELL-4:beamSet:leftEdgeAngle=60
...    NRCELL-4:beamSet:nrBtsBeamRefinementP2=false
...    NRCELL-4:beamSet:rightEdgeAngle=60
...    NRCELL-4:actCDrxVoNR=true
...    NRCELL-4:actEnhancedVoNR=true
...    NRCELL-4:actVoNR=true
...    NRCELL-4:nonGbrNrDrxDN=MRBTS-1/NRBTS-2/NRDRX-1
...    NRDRX-1:drxInactivityTimer=40ms
...    NRDRX-1:drxLongCycle=80ms
...    NRDRX-1:drxOnDurationTimer=10ms
...    NRDRX-1:drxRetransTimerDl=16slot
...    NRDRX-1:drxRetransTimerUl=16slot
...    NRCELL-4:voNRNrDrxDN=MRBTS-1/NRBTS-2/NRDRX-2
...    NRDRX-2:drxInactivityTimer=4ms
...    NRDRX-2:drxLongCycle=40ms
...    NRDRX-2:drxOnDurationTimer=6ms
...    NRDRX-2:drxRetransTimerDl=0slot
...    NRDRX-2:drxRetransTimerUl=0slot

...    NRCELL-4:t310VoNR=100ms
...    NRCELL-4:n310VoNR=n10
...    NRCELL-4:gscnOrSsPbchArfcn=6582
...    NRCELL-4:nrarfcn=526020
...    NRCELL-12:gscnOrSsPbchArfcn=1588
...    NRCELL-12/NRCELL_FDD-1:chBwDl=10MHz
...    NRCELL-12/NRCELL_FDD-1:chBwUl=10MHz
...    NRCELL-12/NRCELL_FDD-1:nrarfcnDl=127100
...    NRCELL-12/NRCELL_FDD-1:nrarfcnUl=136300
...    NRCELL-12:actCDrx=true
...    NRCELL-12:actK1Opt=intra-gNB
...    NRCELL-12:pucchModeSelect=longPucch
...    NRCELL-12:pucchF3ModulationScheme=pi2bpsk
...    NRCELL-12:pucchF3MaxCodeRate=zeroDot08
...    NRCELL-12:prachConfigurationIndex=12
...    NRCELL-12:actPrachMultiplexing=false
...    NRCELL-12:msg1FrequencyStart=5
...    NRCELL-12:srPeriodicity=slots80
...    NRCELL-12:periodicCsiAcquisition:csiReportPeriodicity=slots160
...    NRCELL-12:aggregationLevel=4CCEs
...    NRCELL-12:dlDMRSAdditionalPosition=No additional DMRS
...    NRCELL-12:lteNrDssMode=DSS_Phase_3
...    NRCELL-12:dlPtrs:actDlPtrs=false
...    NRCELL-12:type0SearchSpaceConfigurationIndex=15
...    NRCELL-12:type0CoresetConfigurationIndex=6
...    NRCELL-12:actPdschRmCsirsForTracking=true
...    NRCELL-12:actPdschAtSsbSlots=true
...    NRBTS:actLteNrDss=true


@{PARAMS_FOR_5QI1}
...    NRBTS/NRDRB_5QI-6:fiveqiValueList=1
...    NRBTS/NRDRB_5QI-6:nrDrbDN=MRBTS-1/NRBTS-2/NRDRB-15
...    NRBTS/NRDRB-15:nrDrbMacDN=MRBTS-1/NRBTS-2/NRDRB_MAC-4
...    NRBTS/NRDRB-15:nrDrbPdcpDN=MRBTS-1/NRBTS-2/NRDRB_PDCP-3
...    NRBTS/NRDRB-15:nrDrbRlcUmDN=MRBTS-1/NRBTS-2/NRDRB_RLC_UM-1
...    NRBTS/NRDRB-15:dlFlowControlAlgo=none
...    NRBTS/NRDRB-15:dscp=46
...    NRBTS/NRDRB-15:maxDddsPeriodCpuOvld=40
...    NRBTS/NRDRB-15:numSduDiscard=1
...    NRBTS/NRDRB-15:queuingDelayDiscarding=Disabled
...    NRBTS/NRDRB-15:queuingDelaySduDiscardThreshold=200
...    NRBTS/NRDRB-15:discardTimer=100ms
...    NRBTS/NRDRB-15:maxRlcQueueingDelayGbr=20
...    NRBTS/NRDRB-15:maxTransferDelayGbr=20
...    NRBTS/NRDRB-15:resType=GBR
...    NRBTS/NRDRB-15:rlcMode=RLC_UM
...    NRBTS/NRDRB-15:schedulWeight=1
...    NRBTS/NRDRB-15:sduDiscardIntervalTmr=100
...    NRBTS/NRDRB-15:maxDataRateGbrDl=1000
...    NRBTS/NRDRB-15:maxDataRateGbrUl=1000
...    NRBTS/NRDRB-15:cellAggrLevel=Not FR1 CA eligible
...    NRBTS/NRDRB-15:nrDrxDN=MRBTS-1/NRBTS-2/NRDRX-2
...    NRBTS/NRDRB_MAC-4:lcgid=4
...    NRBTS/NRDRB_MAC-4:schedulPrio=4
...    NRDRB_RLC_UM-1:dlTReassemblyUm=ms50
...    NRDRB_RLC_UM-1:ulTReassemblyUm=ms50
...    NRDRB_RLC_UM-1:rlcUMDrbSNLength=rlcUm12bitSN
...    NRBTS/NRDRB_PDCP-3:tReorderingDl=ms300
...    NRBTS/NRDRB_PDCP-3:tReorderingUl=ms300
...    NRBTS/NRDRB_PDCP-3:pdcpBufDiscardEnabled=false

@{PARAMS_FOR_NRREL}
...    NRCELL-4/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-4/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-4/NRREL-1:gNbId=2
...    NRCELL-4/NRREL-1:gNbIdLength=22
...    NRCELL-4/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-4/NRREL-1:lcrId=1
...    NRCELL-4/NRREL-1:removeNotAllowed=false
...    NRCELL-4/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-4/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-4/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-4/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-4/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-4/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-4/NRREL-2:gNbId=2
...    NRCELL-4/NRREL-2:gNbIdLength=22
...    NRCELL-4/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-4/NRREL-2:lcrId=12
...    NRCELL-4/NRREL-2:removeNotAllowed=false
...    NRCELL-4/NRREL-2:sCellAdditionMethod=blind
...    NRCELL-4/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-4/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-4/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-4/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-4/NRREL-2:sCellOperationalMode=dlOnly

@{PARAMS_FOR_CELL_BWP_PROFILE}
...    @{BWP_PROFILE_4}
...    @{BWP_PROFILE_33}
...    NRCELL-12:cellBwpList:bwpDN=MRBTS-1/NRBTS-2/BWP_PROFILE-4|cellBwpId=0
...    NRCELL-12:cellBwpList:bwpDN=MRBTS-1/NRBTS-2/BWP_PROFILE-33|cellBwpId=1

@{BWP_PROFILE_4}
...    NRBTS/BWP_PROFILE-4:bwpType=initial
...    NRBTS/BWP_PROFILE-4:locationAndBandwidthDl:cRbSizeDl=coreset0
...    NRBTS/BWP_PROFILE-4:locationAndBandwidthDl:cRbStartDl=coreset0
...    NRBTS/BWP_PROFILE-4:locationAndBandwidthUl:cRbSizeUl=allRb
...    NRBTS/BWP_PROFILE-4:locationAndBandwidthUl:cRbStartUl=crb0
...    NRBTS/BWP_PROFILE-4/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-4/PDCCH-1:dciDedicatedAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-4/PDCCH-1:dciPagingAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-4/PDCCH-1:dciRaCompletionAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-4/PDCCH-1:dciRaMsg2AggregationLevel=AL4
...    NRBTS/BWP_PROFILE-4/PDCCH-1:dciSiAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-4/PDCCH-1:downgradeAL16toAL8=notAllowed
...    delete: NRBTS/BWP_PROFILE-4/PDCCH-1:dynamicAggregationLevelSet
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:coresetCommon:cceToRegMapping=interleaved
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:coresetCommon:coresetId=4
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:coresetCommon:cRbStart=0
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:coresetCommon:duration=1
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:coresetCommon:interleaverSize=n3
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:coresetCommon:regBundleSize=n2
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:coresetCommon:size=48
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=1
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_2|searchSpaceId=1
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=1
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl80|searchSpaceId=1
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=1
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=47|searchSpaceId=1
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_2|searchSpaceId=2
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=2
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|searchSpaceId=2
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=6|searchSpaceId=2
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=3
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_2|searchSpaceId=3
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=3
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl40|searchSpaceId=3
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=3
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=27|searchSpaceId=3

@{BWP_PROFILE_33}
...    NRBTS/BWP_PROFILE-33:bwpType=dedicated
...    NRBTS/BWP_PROFILE-33:locationAndBandwidthDl:cRbSizeDl=allRb
...    NRBTS/BWP_PROFILE-33:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-33:locationAndBandwidthUl:cRbSizeUl=allRb
...    NRBTS/BWP_PROFILE-33:locationAndBandwidthUl:cRbStartUl=crb0
...    NRBTS/BWP_PROFILE-33/PDSCH-1:pdschId=1
...    NRBTS/BWP_PROFILE-33/PDSCH-1:pdschRat0RbgConfig=config1
...    NRBTS/BWP_PROFILE-33/PDCCH-1:alSelection=dynamic
...    NRBTS/BWP_PROFILE-33/PDCCH-1:dciDedicatedAggregationLevel=AL2
...    NRBTS/BWP_PROFILE-33/PDCCH-1:dciPagingAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-33/PDCCH-1:dciRaCompletionAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-33/PDCCH-1:dciRaMsg2AggregationLevel=AL4
...    NRBTS/BWP_PROFILE-33/PDCCH-1:dciSiAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-33/PDCCH-1:downgradeAL16toAL8=notAllowed
...    NRBTS/BWP_PROFILE-33/PDCCH-1:dynamicAggregationLevelSet:aggregationLevelList=AL1_AL2_AL4
...    NRBTS/BWP_PROFILE-33/PDCCH-1:dynamicAggregationLevelSet:cqiCorrectionUp=5
...    NRBTS/BWP_PROFILE-33/PDCCH-1:dynamicAggregationLevelSet:cqiDciCssAl1=81
...    NRBTS/BWP_PROFILE-33/PDCCH-1:dynamicAggregationLevelSet:cqiDciCssAl2=59
...    NRBTS/BWP_PROFILE-33/PDCCH-1:dynamicAggregationLevelSet:cqiDciCssAl4=33
...    NRBTS/BWP_PROFILE-33/PDCCH-1:dynamicAggregationLevelSet:cqiDciCssAl8=1
...    NRBTS/BWP_PROFILE-33/PDCCH-1:dynamicAggregationLevelSet:cqiDciCssAl16=0
...    NRBTS/BWP_PROFILE-33/PDCCH-1:dynamicAggregationLevelSet:highOlcCqiOffset=1
...    NRBTS/BWP_PROFILE-33/PDCCH-1:dynamicAggregationLevelSet:lowOlcCqiOffset=1
...    NRBTS/BWP_PROFILE-33/PDCCH-1:dynamicAggregationLevelSet:pCqiErasureActTimer=160
...    NRBTS/BWP_PROFILE-33/PDCCH-1:dynamicAggregationLevelSet:pCqiErasureReduction=1
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
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cceToRegMapping=nonInterleaved
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:coresetId=4
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cRbStart=0
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:duration=1
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:interleaverSize=none
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:regBundleSize=n6
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=48
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-0-And-1-0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=3|searchSpaceId=7
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_2|searchSpaceId=7
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n2|searchSpaceId=7
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n2|searchSpaceId=7
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|searchSpaceId=7
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl10|searchSpaceId=7
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|searchSpaceId=7
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=2|searchSpaceId=7
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=0|searchSpaceId=8
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-0-And-1-0|searchSpaceId=8
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=3|searchSpaceId=8
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_2|searchSpaceId=8
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n2|searchSpaceId=8
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceId=8
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n2|searchSpaceId=8
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|searchSpaceId=8
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceId=8
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl10|searchSpaceId=8
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|searchSpaceId=8
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=6|searchSpaceId=8
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|searchSpaceId=9
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=3|searchSpaceId=9
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_2|searchSpaceId=9
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n2|searchSpaceId=9
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n2|searchSpaceId=9
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|searchSpaceId=9
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl10|searchSpaceId=9
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|searchSpaceId=9
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=2|searchSpaceId=9
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|searchSpaceId=10
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=3|searchSpaceId=10
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_2|searchSpaceId=10
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n2|searchSpaceId=10
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n2|searchSpaceId=10
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|searchSpaceId=10
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl10|searchSpaceId=10
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|searchSpaceId=10
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=6|searchSpaceId=10
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=4|searchSpaceId=11
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|searchSpaceId=11
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|searchSpaceId=11
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_2|searchSpaceId=11
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n2|searchSpaceId=11
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n2|searchSpaceId=11
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|searchSpaceId=11
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl10|searchSpaceId=11
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|searchSpaceId=11
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=5|searchSpaceId=11
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=4|searchSpaceId=12
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-0-And-1-0|searchSpaceId=12
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=3|searchSpaceId=12
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_2|searchSpaceId=12
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n2|searchSpaceId=12
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceId=12
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n2|searchSpaceId=12
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|searchSpaceId=12
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceId=12
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl10|searchSpaceId=12
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|searchSpaceId=12
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=9|searchSpaceId=12

@{PARAMS_FOR_XPAP}
...    MNL-1/MNLENT-1/XPAP-1:xpApId=1
...    MNL-1/MNLENT-1/XPAP-1/XPIF-1:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    MNL-1/MNLENT-1/XPAP-1/XPIF-1:localNeDN=MRBTS-1/NRBTS-2
...    MNL-1/MNLENT-1/XPAP-1/XPIF-1:sctpAssocMaxRetrans=7
...    MNL-1/MNLENT-1/XPAP-1/XPIF-1:sctpDscp=46
...    MNL-1/MNLENT-1/XPAP-1/XPIF-1:sctpHeartbeatInterval=20
...    MNL-1/MNLENT-1/XPAP-1/XPIF-1:sctpMaxPayloadSize=1395
...    MNL-1/MNLENT-1/XPAP-1/XPIF-1:sctpRtoMax=30000
...    MNL-1/MNLENT-1/XPAP-1/XPIF-1:sctpRtoMin=1000
...    MNL-1/MNLENT-1/XPAP-1/XPIF-1:sctpSackDelay=200
...    MNL-1/MNLENT-1/XPAP-1/XPIF-1:sctpSackFreq=2
...    MNL-1/MNLENT-1/XPAP-1/XPIF-1:sctpWaitTimeInitSeqRetry=240
...    MNL-1/MNLENT-1/XPAP-1/XPIF-1:udpDscp=18
...    MNL-1/MNLENT-1/XPAP-1/XPIF-1/XPIFREMOTE-1:ipAddress=10.0.1.1
...    MNL-1/MNLENT-1/XPAP-1/XPIF-1/XPIFREMOTE-1:remoteNeType=ENB

@{PARAMS_FOR_NRDSSLTE}
...    NRCELL-12/NRDSSLTE-1:actLteNrDssFastAlloc=false
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
...    NRCELL-12/NRDSSLTE-1:lteNrDssDlRatio:dlResourceSharingAlgo=DL PRB load based
...    NRCELL-12/NRDSSLTE-1:lteNrDssDlRatio:maxNrDssRatio=100
...    NRCELL-12/NRDSSLTE-1:lteNrDssDlRatio:minNrDssRatio=30
...    NRCELL-12/NRDSSLTE-1:lteNrDssMbsfnRatio:maxValue=50
...    NRCELL-12/NRDSSLTE-1:lteNrDssMbsfnRatio:minValue=50
...    NRCELL-12/NRDSSLTE-1:lteNrDssUlRatio:maxNrDssRatio=70
...    NRCELL-12/NRDSSLTE-1:lteNrDssUlRatio:minNrDssRatio=20

@{PARAMS_FOR_NRSYSINFO_PROFILE}
...    NRCELL-12:nrSysInfoProfileDN=MRBTS-1/NRBTS-2/NRSYSINFO_PROFILE-12
...    NRBTS/NRSYSINFO_PROFILE-12:nCellChangeMedium=14
...    NRBTS/NRSYSINFO_PROFILE-12:systemInformationTargetRate=1
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

@{PARAMS_DEL_CELL2_CELL3}
...    NRBTS/NRDU-1:refNrCellGroup=0,3,4,5
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-1
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-2
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-3
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-4
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-1
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-2
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-3
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-4
...    delete:NRCELL-2
...    delete:NRCELL-3
...    delete:NRCELLGRP-1
...    delete:NRCELLGRP-2

@{FIX_RELATION_ERROR}
...    NRCELL-1:nrCellType=4DL2UL
...    NRCELL-4:nrCellType=4DL2UL
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1
...    @{PARAMS_DEL_CELL2_CELL3}

${SA_Capa_perUE_Full}    SEPARATOR=
...     E9A09000575F5A13160003C1A00B0498B800CE1E82813641873E618F28581C130080C4700FB8D85181AC1184341020E90186D6C98AB1A1CF
...     88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE0005800702A0D883AC1184341020F1018656C98AB121CFB027C471
...     E31238F21CFA8E7CC31E50B0381C3C27F6000001FD8000000B000E0551B137582308682041D2030C2D931544439F11C788E3D033EC09F18E
...     7CC31E50B0381C3C17003FF001C00FFC000B000E0571F11B582308682041F280C2AB64C55850E7C471E300000000000000000000000009FF
...     F000007FFC000002C003801EF0F1340038820000042C040A83C28000E230000010B02B0F11800388200000C2C0AC3C28000E208000010B02
...     B0F13400388C0000042C0AC5C46000E208007104000028581587850001C4D00000C160562E2680071040038500000102C0AC5C4D000E2300
...     0711800001058158B850001C41000E230000020B02B170A0003882001C41000004160562E26800710400388C0000082C0AC5C28000E23000
...     711800001058158B89A001C46000E140000040B02B0F11800388C00000C2C0803808D00A2026C041074BB07C28913639F0E14489B1CF870A
...     244D8E7C3851226C73E1C28913639F0E2448913639F0E14081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF811204
...     081B1CF811204081B1CF811204081B1CF810A040D8E7C00170F18C6318C6318C6318C61E8260078005038280381803A01C0018090010180F
...     82400800000004000008020000000100000200800002004000018020000100100000A008004010040100000C008000070040020000000800
...     0080040000480200000C010000140080000B004002048120080000C0339535953582958195833582B594B5933580B581B58095811583B40D
...     04000025949410000196525040000A594901000039652404000125949010000596524040001A594901000079652404000225949010000996
...     524040002A5949010000B96525040003259490100003165240334AAAE955552A8BA55154162A82C55068AA531549A2A80C55028AA4D5541E
...     28282F012A05028140A05028140A05028140A05028140A0502800304040300601002004202004010080600C20100200404030060100C0182
...     02018030080600C201002004040300601002004402018030080600C0201803040400802010020086A87C0004080C10181C282C3034404448
...     4C5060646C70747C8494989CA0A4A8B4BD05060B40


@{PM_COUNTER_CHECK}
...     NRCELL-12:${EN_DSS_DL_NR_SLOTS}>0
...     NRCELL-12:${EN_DSS_DL_NR_MAX_SHARE}>0
...     NRCELL-12:${EN_DSS_DL_NR_MIN_SHARE}==0
...     NRCELL-12:${SCELL_ACTIVATIONS}==1
...     NRCELL-12:${DL_RLC_VOL_TX_L_QOS_GRP_06}>0
...     NRBTS-2:${UL_VOL_RCV_F1_QoS_GRP_06}>0
${EN_DSS_DL_NR_SLOTS}            M55332C00001    #Number of DL Slots assigned to NR
${EN_DSS_DL_NR_MAX_SHARE}        M55332C00002    #Number of DL Slots assigned to NR with maximum share
${EN_DSS_DL_NR_MIN_SHARE}        M55332C00003    #Number of DL Slots assigned to NR with minimum share
${SCELL_ACTIVATIONS}             M55316C09000    #Number of S-Cell activations while pegged in the secondary cell.
${DL_RLC_VOL_TX_L_QOS_GRP_06}    M55310C01006    #Number of DL RLC data PDU bytes transmitted by Low RLC for the given QoS Group
${UL_VOL_RCV_F1_QoS_GRP_06}      M55323C03006    #Total number of uplink data volume received over F1-U at gNB-CU for QoS Group 6

${RESERVED_FIXED_NORMAL_SUBFRAMES}    0000000000-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000
${DL_NORMAL_SUBFRAMES}    1011110011-1111111111-1011110011-1111111111-1011110011-1111111111-1011110011-1111111111
${DL_PRB_ALLOCATION}    SEPARATOR=
...    0:0,52+1:0,0+2:0,52+3:0,52+4:0,52+5:0,52+6:0,52+7:0,52+8:0,52+9:0,52+10:0,52+11:0,52+12:0,52+13:0,52+14:0,
...    52+15:0,52+16:0,52+17:0,52+18:0,52+19:0,52+20:0,52+21:0,0+22:0,52+23:0,52+24:0,52+25:0,52+26:0,52+27:0,
...    52+52:0,52+29:0,52+30:0,52+31:0,52+32:0,52+33:0,52+34:0,52+35:0,52+36:0,52+37:0,52+38:0,52+39:0,52+40:0,
...    52+41:0,0+42:0,52+43:0,52+44:0,52+45:0,52+46:0,52+47:0,52+48:0,52+49:0,52+50:0,52+51:0,52+52:0,52+53:0,
...    52+54:0,52+55:0,52+56:0,52+57:0,52+58:0,52+59:0,52+60:0,52+61:0,0+62:0,52+63:0,52+64:0,52+65:0,52+66:0,
...    52+67:0,52+68:0,52+69:0,52+70:0,52+71:0,52+72:0,52+73:0,52+74:0,52+75:0,52+76:0,52+77:0,52+78:0,52+79:0,52



*** Test Cases ***
CB006138-ET-F001_Verify_SA_3CC_TTF_with_scell_blind_interact_with_DSS
    [Documentation]
    ...    1. The purpose of this test case is to verify TTF CA with scell blind interact with DSS.
    ...    2. Test Case Steps:
    ...         step1. setup CA TTF ue
    ...         Expected Results:
    ...                FDD dss scell can added, TP is expected, and count is correct.
    [Tags]    QC_134364
    Clear Counter Files    wait=${False}
    UE Attach To GNB2 Cell4 and Scell_1_12 Added Blindly
    Check Traffic
    Stop Traffic and UE Detach
    Check Counters    ${PM_COUNTER_CHECK}
    Check Wireshark Log    ${CURDIR}/a2a_F001/a2a.ini


*** Keywords ***
Modify Cfg
    ${set_gnb2}    Catenate    set_gnb id=2 gnb_id=0x01:22 xp_management=on xp=10.0.1.2:32742 xpu=10.0.1.2:32742
    Update Cfg Param    ${set_gnb2}
    ${set_gnb2_cell4}    Catenate    set_cell id=4 gnb=2 nr_arfcn=526020:526020 gscn=6582
    Update Cfg Param    ${set_gnb2_cell4}
    ${set_gnb2_cell12}    Catenate    set_cell id=12 gnb=2 nr_arfcn=136300:127100 gscn=1588
    Update Cfg Param    ${set_gnb2_cell12}
    ${set_enb1}    Catenate    set_enb id=1 enb_id_macro=0x00001 type=simulated
    ...    xp_management=on xp=10.0.1.1:32742 xpu=10.0.1.1:32742
    Update Cfg Param    ${set_enb1}
    ${set_enb1_cell1}    Catenate    set_cell id=1 enb=1 eci=0x0000101 pci=4:2 tac=222 earfcn=68771:133307 proxy=$CONTAINER_IP:12219 bw=10MHz
    Update Cfg    ${set_enb1_cell1}
    Update Cfg    ue_param id=81 ue_nr_capabilities=${SA_Capa_perUE_Full}

Perform Steps After WTS Started
    Setup X2 link for gNB2
    Establish DSS betewetn ENB1 Cell1 and GNB2 Cell12

Setup X2 link for gNB2
    Execute Egate Command    enb_x2_link_up enb=1 target=2    pass_regexp=ENB-1: X2AP Link with GNB-2 .* is up

Establish DSS betewetn ENB1 Cell1 and GNB2 Cell12
    Establish XP link Between ENB1 And GNB2
    Activate DSS Feature on ENB1 Cell1
    Configure DSS Partnership on ENB1 Cell1
    Activate DSS Partnership Between ENB1 Cell1 and GNB2 Cell12
    Prepare DSS Resource Reservation on ENB1 Cell1
    Request DSS Cell Resource Coordination To CRM
    Request DSS Cell Resource Allocation To CRM

Establish XP link Between ENB1 And GNB2
    Execute Egate Command    sim_trace enb=1 protocol=xp on
    Execute Egate Command    enb_xp_param id=1 xp_peers=none
    Execute Egate Command    enb_xp_param id=1 xp_peers=2
    Execute Egate Command    enb_xp_link_up enb=1 target=2
    ...     pass_regexp=ENB-1: XpAP Link with GNB-2.*is up    timeout=100    sleep_time=10

Activate DSS Feature on ENB1 Cell1
    Execute Egate Command    enb_dss_param id=1 feature_flag=on message_sets=DMS3
    Execute Egate Command    enb_cell_param id=1 enb=1 lte_nr_dss_mode=DSS_PHASE_3 antenna_ports_num=2
    Execute Egate Command    enb_cell_dss_feature id=1 enb=1 nr_dl_peak_rate_increase=on superfast_allocation=off
    ...    sleep_time=3
    Execute Egate Command    enb_cell_dss_param id=1 enb=1 dl_resource_sharing_algo=dl_prb_load_based
    ...    sleep_time=3

Configure DSS Partnership on ENB1 Cell1
    Execute Egate Command    enb_dss_configure_partnership enb=1 cell=1 dss_peer=2:12
    ...    pass_regexp=ENB-1: CRM Partnership Creation    sleep_time=3

Activate DSS Partnership Between ENB1 Cell1 and GNB2 Cell12
    ${cmd}    catenate    enb_crm_cell_resource_reservation enb=1 cell=1 tgt_enb=2 tgt_cell=12
    ...    assigned_dl_minimum_share_to_nr=30 assigned_dl_maximum_share_to_nr=100
    ...    assigned_dl_minimum_share_to_lte=15 assigned_dl_maximum_share_to_lte=70
    ...    assigned_ul_minimum_share_to_nr=20 assigned_ul_maximum_share_to_nr=70
    Execute Egate Command    ${cmd}    sleep_time=3
    Execute Egate Command    enb_crm_param id=1 ul_qos_load_meas_timer=200 dl_qos_load_meas_timer=200    sleep_time=3
    Execute Egate Command    enb_dss_establish_partnership enb=1 cell=1 tgt_enb=2 tgt_cell=12    sleep_time=3
    ...    pass_regexp=ENB-1: Cell 1: Partnership activated on both partners

Prepare DSS Resource Reservation on ENB1 Cell1
    Execute Egate Command    enb_dss_dl_cell_resource_reservation enb=1 cell=1 reset    sleep_time=3
    Execute Egate Command    enb_dss_ul_cell_resource_reservation enb=1 cell=1 reset    sleep_time=3
    ${cmd}    catenate    enb_dss_dl_cell_resource_reservation enb=1 cell=1
    ...    prb_area_reservation_list=0,0,0-10-none+0,0,5-10-none+0,0,9-10-none
    ...    reserved_fixed_normal_subframes=${RESERVED_FIXED_NORMAL_SUBFRAMES}
    ...    min_lte_nr_dss_ratio=30 max_lte_nr_dss_ratio=100
    Execute Egate Command    ${cmd}    sleep_time=3
    ${cmd}    catenate    enb_dss_ul_cell_resource_reservation enb=1 cell=1
    ...    minimum_prb_share=30 maximum_prb_share=70
    Execute Egate Command    ${cmd}    sleep_time=3

Request DSS Cell Resource Coordination To CRM
    Execute Egate Command    enb_dss_cell_resource_coordination enb=1 cell=1 tgt_enb=2 tgt_cell=12 dir=DL
    ...     pass_regexp=ENB-1: Cell 1:.*DSS DL.*Coordination    sleep_time=3
    Execute Egate Command    enb_dss_cell_resource_coordination enb=1 cell=1 tgt_enb=2 tgt_cell=12 dir=UL
    ...     pass_regexp=ENB-1: Cell 1:.*DSS UL.*Coordination    sleep_time=3

Request DSS Cell Resource Allocation To CRM
    ${cmd}    catenate    enb_dss_resource_allocation enb=1 cell=1 tgt_enb=2 tgt_cell=12 dir=DL
    ...    allocation_start_time=immediate dl_allocated_normal_subframes=${DL_NORMAL_SUBFRAMES}
    ...    dl_prb_area_allocation_list=${DL_PRB_ALLOCATION}
    Execute Egate Command    ${cmd}    pass_regexp=ENB-1: Cell 1: Received.*DSS DL.*Allocation Response    sleep_time=3
    ${cmd}    catenate    enb_dss_resource_allocation enb=1 cell=1 tgt_enb=2 tgt_cell=12 dir=UL
    ...    allocation_start_time=immediate ul_allocated_prb_list=1,35
    Execute Egate Command    ${cmd}    pass_regexp=ENB-1: Cell 1: Received.*DSS UL.*Allocation Response    sleep_time=3
    Execute Egate Command     enb_crm_status enb=1 cell=1    pass_regexp=eNB-1: Configured DSS partnership

UE Attach To GNB2 Cell4 and Scell_1_12 Added Blindly
    ${ret}    Execute Egate Command    ue_change_location id=81 enb=2 cell=4    pass_regexp=location
    Should Contain Any    ${ret}    location updated    already there
    Execute Egate Command    qosflow_modify qos_flow=1 default=on
    Execute Egate Command    ue_register id=81     pass_regexp=Received REGISTRATION COMPLETE
    Execute Egate Command    set_pdu_param ue=81 pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup pdu=1 ue=81 nwslice=1 gw=1
    ...                      pass_regexp=SCellIndex 2 activated successfully
    Rrc Should Contain    sCellToAddModList    physCellId 50    physCellId 61

Check Traffic
    Send Traffic
    Verify Throuput

Send Traffic
    Execute Egate Command    data_trf_start ue=81 pdu=1 dir=dl mbps=150 trf_id=1
    ...                      pass_regexp=UE81: Started Downlink Internal traffic
    Execute Egate Command    data_trf_start ue=81 pdu=1 dir=dl mbps=150 trf_id=2
    ...                      pass_regexp=UE81: Started Downlink Internal traffic
    Execute Egate Command    data_trf_start ue=81 pdu=1 dir=dl mbps=150 trf_id=3
    ...                      pass_regexp=UE81: Started Downlink Internal traffic
    Execute Egate Command    data_trf_start ue=81 pdu=1 dir=dl mbps=150 trf_id=4
    ...                      pass_regexp=UE81: Started Downlink Internal traffic
    Execute Egate Command    data_trf_start ue=81 pdu=1 dir=dl mbps=150 trf_id=5
    ...                      pass_regexp=UE81: Started Downlink Internal traffic
    Execute Egate Command    data_trf_start ue=81 pdu=1 dir=dl mbps=150 trf_id=6
    ...                      pass_regexp=UE81: Started Downlink Internal traffic
    Execute Egate Command    data_trf_start ue=81 pdu=1 dir=dl mbps=100 trf_id=7
    ...                      pass_regexp=UE81: Started Downlink Internal traffic
    Execute Egate Command    data_trf_start ue=81 pdu=1 dir=ul mbps=10 trf_id=8    sleep_time=30
    ...                      pass_regexp=UE81: Started Uplink Internal traffic

Verify Throuput
    [Arguments]     ${cell_num}=3    ${min_dl_tput}=850    ${min_ul_tput}=8
    Sleep    15s    sleep for Tput stable
    ${dl_throuput}    Ap Get SA Throughput    ue_id=81    pdu=1    qfi=1    direction=dl    rate_type=ave
    ${ul_throuput}    Ap Get SA Throughput    ue_id=81    pdu=1    qfi=1    direction=ul    rate_type=ave
    ${total_dl_tput}    Set Variable    0
    FOR    ${index}    IN RANGE    0    ${cell_num}
         ${str_index}    Convert To String    ${index}
         ${scell_tput}    Ap Get Throuput On Specific Scell    81    ${str_index}    pdsch
         Should Be True    ${scell_tput}/1000 > 0
         ${total_dl_tput}    Evaluate    ${scell_tput}+${total_dl_tput}
    END
    Should Be True    ${total_dl_tput}/1000 > ${min_dl_tput}
    Should Be True    ${ul_throuput}/1000 > ${min_ul_tput}

Stop Traffic and UE Detach
    Execute Egate Command    trf_data_stop ue=81    pass_regexp=Traffic was stopped
    Execute Egate Command    ue_deregister id=81 ue_deregister_type=switch_off    pass_regexp=UE81: detached

