*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_FDD    CRT    CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD
...           team-SG2    owner-dan.liu    release-5G21A
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SWCONFIG}
...    @{rdNeighRemovalEvaluationTimer}

@{rdNeighRemovalEvaluationTimer}
...    0x890062=1

${NOKIA_XNAP_PLUGIN_FLAG}    ${True}
${NOKIA_F1AP_PLUGIN_FLAG}    ${True}

@{PARAMS_IN_SCF}
...    @{784_PARAMS}
...    @{HO_PARAMS}
...    @{CELL_NRHOIF}
...    @{ANR_PARAMS}
...    @{SNSSAI}
...    @{NRDRB}
...    @{PARAMS_FOR_PLMN}
...    @{NRCELL_NRPLMNSET_SA_NSA}
...    @{fixed_relation_error}
...    @{CA_PARAMS}
...    @{diff_frequency}

@{CELL_NRHOIF}
...    NRBTS-1/NRCELL-2/NRHOIF-1:cellDepType=SA
...    NRBTS-1/NRCELL-2/NRHOIF-1:freqBandIndicatorNR=71
...    NRBTS-1/NRCELL-2/NRHOIF-1:ifhoSsbScs=15KHz
...    NRBTS-1/NRCELL-2/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRBTS-1/NRCELL-2/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRBTS-1/NRCELL-2/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRBTS-1/NRCELL-2/NRHOIF-1:ssBurstSetPeriod=20
...    NRBTS-1/NRCELL-2/NRHOIF-1:ssbFrequency=127230
...    NRBTS-1/NRCELL-2/NRHOIF-1:a3MeasEnabled=rsrp
...    NRBTS-1/NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRBTS-1/NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=30
...    NRBTS-1/NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms64
...    NRBTS-1/NRCELL-2:measGapSelectionSA=favourUeThroughput

@{CA_PARAMS}
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-1:gNbId=1
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-1:lcrId=2
...    NRCELL-1/NRREL-1:removeNotAllowed=false
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-1:sCellOperationalMode=dlOnly
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
...    NRCELL-2/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-2/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL:sCellDeactivationTimerGNB=infinity
...    NRCELL:allowUnsuppBcOrBcs=accept unknown band combinations
...    NRBTS:sCellActivationMethod=blind
...    NRDU-1:flexibleCAMode=NumberCellAmount
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRDU-1:carrierAggregationSupportList=ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Fdd,ca_Fdd_Any_Sa
...    NRDU-1:actInterNumerologyCa=true
...    NRBTS-1:actHoOptimizationCa=true
...    NRBTS-1:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS:actCarrierAggregation=true
...    NRBTS:caConfigurationSupport=2CCDL_2CCUL
...    NRBTS:maxNumScellsDl=2
...    NRBTS:maxNumScellsUl=2

@{HO_PARAMS}
...    NRBTS:actIncXn=true
...    NRBTS:actIntraFreqHoSA=true
...    NRBTS:actInterRatHoSA=true
...    NRBTS:actInterFreqHoSA=true
...    NRBTS:tRLFindForDUVoNR=500ms
...    NRBTS:rrcReestabTypeSA=viaRRCSetup
...    NRBTS:actNgcFlexSaMode=true
...    NRBTS:actRanSharing=true
...    NRBTS:actRanSharingEnh=max_10_PLMNs
...    NRBTS:cipherPrefL:nea0=1
...    NRBTS:cipherPrefL:nea1_128=0
...    NRBTS:cipherPrefL:nea2_128=9
...    NRBTS:cipherPrefL:nea3_128=0
...    NRBTS:integrityProtPrefL:nia1_128=0
...    NRBTS:integrityProtPrefL:nia2_128=9
...    NRBTS:integrityProtPrefL:nia3_128=0
...    NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-1:threshXHighQ=0
...    NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-1:threshXLowQ=0
...    NRBTS-1/NRPMRNL-1:miNrRelReportCu=5min
...    NRBTS-1/NRSCTP-1:sctpProfile:sctpWaitTimeInitSeqRetry=60
...    NRCELL:a3MeasEnabled=rsrp
...    NRCELL:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRCELL:a3MeasSsbRsrp:a3OffsetSsbRsrp=15
...    NRCELL:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms40
...    NRCELL:absThreshSsbRsrpConsolidation=1
...    NRCELL:sMeasConfigSsbRsrp=0
...    NRCELL:a1MeashoEnabledSA=rsrp
...    NRCELL:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRCELL:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=60
...    NRCELL:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL:a2MeashoEnabledSA=rsrp
...    NRCELL:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0
...    NRCELL:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=34
...    NRCELL:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL:filterCoeffSsbRsrp=fc4
...    NRCELL:filterCoeffSsbRsrq=fc4

@{784_PARAMS}
...    NRCELL:actVoNR=true
...    NRCELL:actEmergencyCall=true
...    NRCELL:actEnhancedVoNR=true
...    NRCELL:actGBRAdmissionControl=EnhancedVoNR
...    NRCELL:emergencyCallLimServ=true
...    NRCELL:maxGBRTrafficLimit=30
...    NRCELL:n310VoNR=n3
...    NRCELL:t310VoNR=500ms
...    NRCELL:arpPrioEmergencyCall=1
...    NRCELL:emergencyCallRestrictions:emergencyCallMrListIgnore=true
...    NRCELL:emergencyCallRestrictions:emergencyCallPlmnHoAllowed=true

@{diff_frequency}
...    NRCELL-1:gscnOrSsPbchArfcn=1590
...    NRCELL-1/NRCELL_FDD-1:nrarfcnDl=127440
...    NRCELL-1/NRCELL_FDD-1:nrarfcnUl=136660
...    NRCELL-1/NRCELL_FDD-1:chBwDl=20MHz
...    NRCELL-1/NRCELL_FDD-1:chBwUl=20MHz
...    NRCELL-2:gscnOrSsPbchArfcn=1549
...    NRCELL-2/NRCELL_FDD-1:nrarfcnDl=124400
...    NRCELL-2/NRCELL_FDD-1:nrarfcnUl=133620
...    NRCELL-2/NRCELL_FDD-1:chBwDl=10MHz
...    NRCELL-2/NRCELL_FDD-1:chBwUl=10MHz
...    NRCELL-2:type0CoresetConfigurationIndex=0
...    @{Cell_BWPs}

@{Cell_BWPs}
...    NRCELL-2:cellBwpList:cellBwpId=0|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-7
...    NRCELL-2:cellBwpList:cellBwpId=1|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-13
...    @{BWP_PROFILE_7}
...    @{BWP_PROFILE_13}
...    NRCELL-1:cellBwpList:cellBwpId=0|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-5
...    NRCELL-1:cellBwpList:cellBwpId=1|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-15
...    @{BWP_PROFILE_5}
...    @{BWP_PROFILE_15}

@{BWP_PROFILE_7}
...    BWP_PROFILE-7:bwpProfileId=7
...    BWP_PROFILE-7:bwpType=initial
...    BWP_PROFILE-7:locationAndBandwidthDl:cRbSizeDl=coreset0
...    BWP_PROFILE-7:locationAndBandwidthDl:cRbStartDl=coreset0
...    BWP_PROFILE-7:locationAndBandwidthUl:cRbSizeUl=allRb
...    BWP_PROFILE-7:locationAndBandwidthUl:cRbStartUl=crb0
...    BWP_PROFILE-7/PDCCH-1:alSelection=static
...    BWP_PROFILE-7/PDCCH-1:dciDedicatedAggregationLevel=AL4
...    BWP_PROFILE-7/PDCCH-1:dciPagingAggregationLevel=AL4
...    BWP_PROFILE-7/PDCCH-1:dciRaCompletionAggregationLevel=AL4
...    BWP_PROFILE-7/PDCCH-1:dciRaMsg2AggregationLevel=AL4
...    BWP_PROFILE-7/PDCCH-1:dciSiAggregationLevel=AL4
...    BWP_PROFILE-7/PDCCH-1:downgradeAL16toAL8=notAllowed
...    BWP_PROFILE-7/PDCCH-1:downgradeALProactive=false
...    BWP_PROFILE-7/PDCCH-1:pdcchId=1
...    delete:BWP_PROFILE-7/PDCCH-1:dynamicAggregationLevelSet
...    delete:BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:coresetCommon
...    BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:pdcchConfigCommonId=1
...    BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceType=Type0A
...    BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceType=Type0A
...    BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceType=Type0A
...    BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceType=Type0A
...    BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceType=Type0A
...    BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceType=Type0A
...    BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceType=Type0A
...    BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceType=Type0A
...    BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceType=Type0A
...    BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=1|searchSpaceType=Type0A
...    BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceType=Type0A
...    BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceType=Type1
...    BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceType=Type1
...    BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceType=Type1
...    BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceType=Type1
...    BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceType=Type1
...    BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceType=Type1
...    BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceType=Type1
...    BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceType=Type1
...    BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceType=Type1
...    BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=2|searchSpaceType=Type1
...    BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceType=Type1
...    BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceType=Type2
...    BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceType=Type2
...    BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceType=Type2
...    BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceType=Type2
...    BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceType=Type2
...    BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceType=Type2
...    BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceType=Type2
...    BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceType=Type2
...    BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceType=Type2
...    BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=3|searchSpaceType=Type2
...    BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceType=Type2

@{BWP_PROFILE_13}
...    BWP_PROFILE-13:bwpProfileId=13
...    BWP_PROFILE-13:bwpType=dedicated
...    BWP_PROFILE-13:locationAndBandwidthDl:cRbSizeDl=allRb
...    BWP_PROFILE-13:locationAndBandwidthDl:cRbStartDl=crb0
...    BWP_PROFILE-13:locationAndBandwidthUl:cRbSizeUl=sameAsDl
...    BWP_PROFILE-13:locationAndBandwidthUl:cRbStartUl=sameAsDl
...    BWP_PROFILE-13/PDCCH-1:alSelection=static
...    BWP_PROFILE-13/PDCCH-1:dciDedicatedAggregationLevel=AL4
...    BWP_PROFILE-13/PDCCH-1:dciPagingAggregationLevel=AL4
...    BWP_PROFILE-13/PDCCH-1:dciRaCompletionAggregationLevel=AL4
...    BWP_PROFILE-13/PDCCH-1:dciRaMsg2AggregationLevel=AL4
...    BWP_PROFILE-13/PDCCH-1:dciSiAggregationLevel=AL4
...    BWP_PROFILE-13/PDCCH-1:downgradeAL16toAL8=notAllowed
...    BWP_PROFILE-13/PDCCH-1:downgradeALProactive=false
...    BWP_PROFILE-13/PDCCH-1:pdcchId=1
...    delete:BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_COMMON-1:coresetCommon
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_COMMON-1:pdcchConfigCommonId=1
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceType=Type0A
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceType=Type0A
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceType=Type0A
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceType=Type0A
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceType=Type0A
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceType=Type0A
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceType=Type0A
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceType=Type0A
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceType=Type0A
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=4|searchSpaceType=Type0A
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceType=Type0A
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceType=Type1
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceType=Type1
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceType=Type1
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceType=Type1
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceType=Type1
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceType=Type1
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceType=Type1
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceType=Type1
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceType=Type1
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=5|searchSpaceType=Type1
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceType=Type1
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceType=Type2
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceType=Type2
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceType=Type2
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceType=Type2
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceType=Type2
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceType=Type2
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceType=Type2
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceType=Type2
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceType=Type2
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=6|searchSpaceType=Type2
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceType=Type2
...    delete:BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:pdcchConfigDedicatedId=1
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=0|searchSpaceType=Type3
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-0-And-1-0|searchSpaceType=Type3
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|searchSpaceType=Type3
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0|searchSpaceType=Type3
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|searchSpaceType=Type3
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|searchSpaceType=Type3
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|searchSpaceType=Type3
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceType=Type3
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceType=Type3
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|searchSpaceType=Type3
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=7|searchSpaceType=Type3
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|searchSpaceType=Type3
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=0|searchSpaceType=UE-Specific
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|searchSpaceType=UE-Specific
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|searchSpaceType=UE-Specific
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0|searchSpaceType=UE-Specific
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|searchSpaceType=UE-Specific
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|searchSpaceType=UE-Specific
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|searchSpaceType=UE-Specific
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceType=UE-Specific
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceType=UE-Specific
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|searchSpaceType=UE-Specific
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=8|searchSpaceType=UE-Specific
...    BWP_PROFILE-13/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|searchSpaceType=UE-Specific
...    BWP_PROFILE-13/PDSCH-1:pdschId=1
...    BWP_PROFILE-13/PDSCH-1:pdschRat0RbgConfig=config1


@{BWP_PROFILE_5}
...    BWP_PROFILE-5:bwpProfileId=5
...    BWP_PROFILE-5:bwpType=initial
...    BWP_PROFILE-5:locationAndBandwidthDl:cRbSizeDl=coreset0
...    BWP_PROFILE-5:locationAndBandwidthDl:cRbStartDl=coreset0
...    BWP_PROFILE-5:locationAndBandwidthUl:cRbSizeUl=allRb
...    BWP_PROFILE-5:locationAndBandwidthUl:cRbStartUl=crb0
...    BWP_PROFILE-5/PDCCH-1:alSelection=static
...    BWP_PROFILE-5/PDCCH-1:dciDedicatedAggregationLevel=AL4
...    BWP_PROFILE-5/PDCCH-1:dciPagingAggregationLevel=AL4
...    BWP_PROFILE-5/PDCCH-1:dciRaCompletionAggregationLevel=AL4
...    BWP_PROFILE-5/PDCCH-1:dciRaMsg2AggregationLevel=AL4
...    BWP_PROFILE-5/PDCCH-1:dciSiAggregationLevel=AL4
...    BWP_PROFILE-5/PDCCH-1:downgradeAL16toAL8=notAllowed
...    BWP_PROFILE-5/PDCCH-1:downgradeALProactive=false
...    BWP_PROFILE-5/PDCCH-1:pdcchId=1
...    delete:BWP_PROFILE-5/PDCCH-1:dynamicAggregationLevelSet
...    delete:BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:coresetCommon
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:pdcchConfigCommonId=1
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceType=Type0A
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceType=Type0A
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceType=Type0A
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceType=Type0A
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceType=Type0A
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceType=Type0A
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceType=Type0A
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceType=Type0A
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceType=Type0A
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=1|searchSpaceType=Type0A
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceType=Type0A
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceType=Type1
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceType=Type1
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceType=Type1
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceType=Type1
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceType=Type1
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceType=Type1
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceType=Type1
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceType=Type1
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceType=Type1
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=2|searchSpaceType=Type1
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceType=Type1
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceType=Type2
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceType=Type2
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceType=Type2
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceType=Type2
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceType=Type2
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceType=Type2
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceType=Type2
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceType=Type2
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceType=Type2
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=3|searchSpaceType=Type2
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceType=Type2

@{BWP_PROFILE_15}
...    BWP_PROFILE-15:bwpProfileId=15
...    BWP_PROFILE-15:bwpType=dedicated
...    BWP_PROFILE-15:locationAndBandwidthDl:cRbSizeDl=allRb
...    BWP_PROFILE-15:locationAndBandwidthDl:cRbStartDl=crb0
...    BWP_PROFILE-15:locationAndBandwidthUl:cRbSizeUl=sameAsDl
...    BWP_PROFILE-15:locationAndBandwidthUl:cRbStartUl=sameAsDl
...    BWP_PROFILE-15/PDCCH-1:alSelection=static
...    BWP_PROFILE-15/PDCCH-1:dciDedicatedAggregationLevel=AL4
...    BWP_PROFILE-15/PDCCH-1:dciPagingAggregationLevel=AL4
...    BWP_PROFILE-15/PDCCH-1:dciRaCompletionAggregationLevel=AL4
...    BWP_PROFILE-15/PDCCH-1:dciRaMsg2AggregationLevel=AL4
...    BWP_PROFILE-15/PDCCH-1:dciSiAggregationLevel=AL4
...    BWP_PROFILE-15/PDCCH-1:downgradeAL16toAL8=notAllowed
...    BWP_PROFILE-15/PDCCH-1:downgradeALProactive=false
...    BWP_PROFILE-15/PDCCH-1:pdcchId=1
...    delete:BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_COMMON-1:coresetCommon
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_COMMON-1:pdcchConfigCommonId=1
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceType=Type0A
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceType=Type0A
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceType=Type0A
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceType=Type0A
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceType=Type0A
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceType=Type0A
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceType=Type0A
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceType=Type0A
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceType=Type0A
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=4|searchSpaceType=Type0A
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceType=Type0A
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceType=Type1
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceType=Type1
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceType=Type1
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceType=Type1
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceType=Type1
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceType=Type1
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceType=Type1
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceType=Type1
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceType=Type1
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=5|searchSpaceType=Type1
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceType=Type1
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceType=Type2
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceType=Type2
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceType=Type2
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceType=Type2
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceType=Type2
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceType=Type2
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceType=Type2
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceType=Type2
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceType=Type2
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=6|searchSpaceType=Type2
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceType=Type2
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cceToRegMapping=interleaved
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:coresetId=1
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cRbStart=0
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:duration=1
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:interleaverSize=n3
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:regBundleSize=n2
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=96
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:pdcchConfigDedicatedId=1
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=0|searchSpaceType=Type3
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-0-And-1-0|searchSpaceType=Type3
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|searchSpaceType=Type3
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceType=Type3
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|searchSpaceType=Type3
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|searchSpaceType=Type3
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n4|searchSpaceType=Type3
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceType=Type3
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceType=Type3
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|searchSpaceType=Type3
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=7|searchSpaceType=Type3
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|searchSpaceType=Type3
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=1|searchSpaceType=UE-Specific
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|searchSpaceType=UE-Specific
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|searchSpaceType=UE-Specific
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceType=UE-Specific
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|searchSpaceType=UE-Specific
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|searchSpaceType=UE-Specific
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n4|searchSpaceType=UE-Specific
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceType=UE-Specific
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceType=UE-Specific
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|searchSpaceType=UE-Specific
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=8|searchSpaceType=UE-Specific
...    BWP_PROFILE-15/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|searchSpaceType=UE-Specific
...    BWP_PROFILE-15/PDSCH-1:pdschId=1
...    BWP_PROFILE-15/PDSCH-1:pdschRat0RbgConfig=config1

@{NRCELL_NRPLMNSET_SA_NSA}
...    NRCELL/NRPLMNSET_SA-1:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-200
...    NRCELL/NRPLMNSET_SA-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRCELL/NRPLMNSET_NSA-1:configuredEpsTac=788
...    NRCELL/NRPLMNSET_NSA-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1

@{SNSSAI}
...    NRBTS/SNSSAI-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1,MRBTS-1/NRBTS-1/NRPLMN-2
...    NRBTS/SNSSAI-1:ngUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRBTS/SNSSAI-1:sd=${EMPTY}
...    NRBTS/SNSSAI-2:sd=13714342
...    NRBTS/SNSSAI-2:ngUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRBTS/SNSSAI-2:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1,MRBTS-1/NRBTS-1/NRPLMN-2
...    MRBTS-1/NRBTS-1/TRACKINGAREA-200:fiveGsTac=788
...    TRACKINGAREA-200:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1
...    TRACKINGAREA-200:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2


@{NRDRB}
...    NRBTS-1/NRDRB_5QI-6:fiveqiValueList=1
...    NRBTS-1/NRDRB_5QI-6:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-15
...    MRBTS-1/NRBTS-1/NRDRB-15:dlFlowControlAlgo=none
...    MRBTS-1/NRBTS-1/NRDRB-15:dscp=0
...    MRBTS-1/NRBTS-1/NRDRB-15:nrDrbId=15
...    MRBTS-1/NRBTS-1/NRDRB-15:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-3
...    MRBTS-1/NRBTS-1/NRDRB-15:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-2
...    MRBTS-1/NRBTS-1/NRDRB-15:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    MRBTS-1/NRBTS-1/NRDRB-15:numSduDiscard=1
...    MRBTS-1/NRBTS-1/NRDRB-15:queuingDelayDiscarding=Disabled
...    MRBTS-1/NRBTS-1/NRDRB-15:queuingDelaySduDiscardThreshold=750
...    MRBTS-1/NRBTS-1/NRDRB-15:resType=GBR
...    MRBTS-1/NRBTS-1/NRDRB-15:rlcMode=RLC_UM
...    MRBTS-1/NRBTS-1/NRDRB-15:sduDiscardIntervalTmr=100
...    MRBTS-1/NRBTS-1/NRDRB-15:schedulWeight=1
...    MRBTS-1/NRBTS-1/NRDRB-15:discardTimer=150ms
...    MRBTS-1/NRBTS-1/NRDRB-15:actDddsReduction=false
...    MRBTS-1/NRBTS-1/NRDRB_MAC-3:lcgid=4
...    MRBTS-1/NRBTS-1/NRDRB_MAC-3:schedulPrio=5
...    MRBTS-1/NRBTS-1/NRDRB_MAC-3:nrDrbMacId=3
...    MRBTS-1/NRBTS-1/NRDRB_MAC-4:lcgid=1
...    MRBTS-1/NRBTS-1/NRDRB_MAC-4:schedulPrio=4
...    MRBTS-1/NRBTS-1/NRDRB_MAC-4:nrDrbMacId=4
...    MRBTS-1/NRBTS-1/NRDRB-10:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-4
...    MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1:dlTReassemblyUm=ms40
...    MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1:nrDrbRlcUmId=1
...    MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1:ulTReassemblyUm=ms40

@{ANR_PARAMS}
...    NRBTS:actEnhanceIntraNrIntraFreqAnr=true
...    NRBTS:actSaUeBasedAnrNr=true
...    NRBTS:actSaUeBasedInterFreqAnrNr=true
...    NRBTS:actDedicatedAnrDrxProfile=true
...    NRBTS:actSaIntraFreqAnrDrxProf=true
...    NRANR-1:actAutoEutraNbRemoval=false
...    NRANR-1:actAutoNrNbRemoval=true
...    NRANR-1:consecHoFailThres=0
...    NRANR-1:consecHoFailThresEutra=3
...    NRANR-1:consecXnResolveFailThres=3
...    NRANR-1:gNbIdLengthConfig:gNbIdLength=22
...    NRANR-1:gNbIdLengthConfig:priorityIndex=1
...    NRANR-1:gNbIdLengthConfig:nrPlmnDN=NRPLMN-2
...    NRANR-1:nrAnrId=1
...    NRANRPR-1:anrThresholdSelector=RSRP
...    NRANRPR-1:anrThresRsrpNbCell=-90
...    NRANRPR-1:anrThresRsrqNbCell=-12
...    NRANRPR-1:cellDepMode=SA+NSA
...    NRANRPR-1:consecRecheckForNrNbRemoval=5
...    NRANRPR-1:idleTimeForNrNbRemoval=2
...    NRANRPR-1:maxNumAnrNrrelAllowed=50
...    NRANRPR-1:nrAnrPrId=1
...    NRANRPR-2:anrThresRsrpNbCell=-90     #-90 dBm is equal to RSRP value of 67 reported by the UE
...    NRANRPR-2:anrThresRsrqNbCell=-12     #-12 dB is equal to RSRQ value of 63 reported by the UE
...    NRANRPR-2:anrThresholdSelector=RSRP
...    NRANRPR-2:cellDepMode=SA+NSA
...    NRANRPR-2:consecRecheckForNrNbRemoval=5
...    NRANRPR-2:idleTimeForNrNbRemoval=2  # hours, value: 2 ~ 192
...    NRANRPR-2:maxNumAnrNrrelAllowed=10
...    NRANRPR-2:nrarfcn=127440
...    NRANRPR-2:ssbFrequency=127230
...    NRANRPR-3:anrThresRsrpNbCell=-90     #-90 dBm is equal to RSRP value of 67 reported by the UE
...    NRANRPR-3:anrThresRsrqNbCell=-12     #-12 dB is equal to RSRQ value of 63 reported by the UE
...    NRANRPR-3:anrThresholdSelector=RSRP
...    NRANRPR-3:cellDepMode=SA+NSA
...    NRANRPR-3:consecRecheckForNrNbRemoval=5
...    NRANRPR-3:idleTimeForNrNbRemoval=2  # hours, value: 2 ~ 192
...    NRANRPR-3:maxNumAnrNrrelAllowed=10
...    NRANRPR-3:nrarfcn=124400
...    NRANRPR-3:ssbFrequency=123890
...    NRCELL:actCDrx=true
...    NRCELL:drxProfileNrAnr:drxControl=any
...    NRCELL:drxProfileNrAnr:nrDrxDN=NRDRX-3

@{NRADJNRCELL}
...    delete:XNLINK.*
...    NRADJGNB-1:administrativeState=Unlocked
...    NRADJGNB-1:gNodeBId=10
...    NRADJGNB-1:gNbIdLength=22
...    NRADJGNB-1:gnbPlmn:mncLength=3
...    NRADJGNB-1:gnbPlmn:mcc=311
...    NRADJGNB-1:gnbPlmn:mnc=402
...    NRADJNRCELL-1:cellDepType=SA
...    NRADJNRCELL-1:gNbId=10
...    NRADJNRCELL-1:gNbIdLength=22
...    NRADJNRCELL-1:lcrId=3
...    NRADJNRCELL-1:nrarfcn=127440
...    NRADJNRCELL-1:physCellId=30
...    NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRADJNRCELL-1:gnbPlmn:mnc=402
...    NRADJNRCELL-1:gnbPlmn:mncLength=3
...    NRADJNRCELL-1/ADJ_NRPLMNSET_SA-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-2
...    NRADJNRCELL-1/ADJ_NRPLMNSET_SA-1:fiveGsTac=100

@{PARAMS_FOR_PLMN}
...    MRBTS-1/NRBTS-1/NRPLMN-2:mcc=311
...    MRBTS-1/NRBTS-1/NRPLMN-2:mnc=402
...    MRBTS-1/NRBTS-1/NRPLMN-2:mncLength=3
...    MRBTS-1/NRBTS-1/NRPLMN-1:mcc=311
...    MRBTS-1/NRBTS-1/NRPLMN-1:mnc=489
...    MRBTS-1/NRBTS-1/NRPLMN-1:mncLength=3

@{fixed_relation_error}
...    NRBTS:timerXnDataFwdGuard=250
...    NRBTS-1/NRDRB-15:maxDataRateGbrDl=100
...    NRBTS-1/NRDRB-15:maxDataRateGbrUl=100
...    NRBTS-1/NRDRB_PDCP-2:pdcpBufDiscardEnabled=false
...    delete:MRBTS-1/NRBTS-1/NRCELL:configuredEpsTac
...    delete:MRBTS-1/NRBTS-1/NRCELL:trackingAreaDN
...    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrInterGnbMobilityCellCuNsa=disabled
...    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrInterGnbMobilityCellCuSa=disabled
...    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrIntraGnbMobilityCellCuSa=disabled
...    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrNeighborLteNrCuNsa=disabled
...    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrNeighborNrNrCuNsa=disabled

@{MrListIgnore_T_PlmnHoAllowed_F}
...    NRCELL:actEmergencyCall=true
...    NRBTS-1/NRCELL-1:emergencyCallRestrictions:emergencyCallMrListIgnore=true
...    NRBTS-1/NRCELL-1:emergencyCallRestrictions:emergencyCallPlmnHoAllowed=false

@{MrListIgnore_T_PlmnHoAllowed_T}
...    NRCELL:actEmergencyCall=true
...    NRBTS-1/NRCELL-1:emergencyCallRestrictions:emergencyCallMrListIgnore=true
...    NRBTS-1/NRCELL-1:emergencyCallRestrictions:emergencyCallPlmnHoAllowed=true

@{B014_param}
...    NRBTS-1/NRCELL-1:arpPrioEmergencyCall=6
...    NRBTS-1/NRCELL-1:maxNumOfNonGBRBearersSA=5
...    NRBTS-1/NRCELL-1:maxNumOfGBRBearersSA=0
...    NRBTS-1/NRCELL-1:numOfRadioResReservForEmergency=1
...    NRBTS-1/NRCELL-1:addNumOfGBRBearers=1
...    NRBTS-1/NRCELL-1:maxNumOfRrcSA=1
...    NRCELL:actEmergencyCall=true
...    NRBTS-1/NRCELL-1:emergencyCallRestrictions:emergencyCallMrListIgnore=false
...    NRBTS-1/NRCELL-1:emergencyCallRestrictions:emergencyCallPlmnHoAllowed=true
...    NRBTS-1/NRDU-1:numOfDrbsReservForEmergency=1
...    NRBTS-1/NRCELLGRP-0:addNumOfRrcCGRPSAHo=1

@{B014_RRC_0}
...    NRBTS-1/NRCELL-1:maxNumOfRrcSA=0

@{counters_B04}
...    NRCELL-1:NMOCU:${ATT_HO_EMERGENCY}=1
...    NRCELL-1:NMOCU:${FAIL_HO_PREP_EMERGENCY_RECD}=0

@{counters_B14}
...    NRCELL-1:NMOCU:${ATT_HO_EMERGENCY}=1
...    NRCELL-1:NMOCU:${SUCC_HO_EMERGENCY}=1
...    NRCELL-1:NMOCU:${HO_PREP_EMERGENCY_SENT}=1


${ATT_HO_EMERGENCY}    M55147C00501
${FAIL_HO_PREP_EMERGENCY_RECD}    M55147C00502
${SUCC_HO_EMERGENCY}    M55147C00503
${HO_PREP_EMERGENCY_SENT}    M55147C00504

${SA_Capa_perUE}    SEPARATOR=
...    E1A01000074E5A031E00038420007824C1900010F09003100D00980C0301C022A36146B04050D012CB28986801EB608080838778E1C830E0008193C7D5C0013C0070004
...    F000A8D88DAC10143404B2CA261A007AD8202020E1DE38720C38002064F1F54FFD3FF2A3626EB04050D012CB28986801EB608080838778E1C830E0008193C7D5C0013C0
...    070004F0000C20E2680000008385000000020E2300000100501360144046170000F01808804602001FEAAAAA0B800E800A070500703009801C001A0F802000000000000
...    0000803CA9AC0CA0082000012CB2A000000803A555440E85800E001600010008010020010040086AC4C0004080C1014181C202C4044484C648494989CA12986B4

${SA_Capa_2N71_ANR}    SEPARATOR=
...    E9A09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C4700FB8D85181AC1184341020E9068036B64C558D0E
...    7C471E819F604F8C48E3C873EA39F30C7942C0E070F05C00FFC0070005F0005C0000E0541B107582308682041E20D00656C98AB121CFB027C4
...    71E31238F21CFA8E7CC31E50B0381C3C27F6000001FD800000170000381546C4DD608C21A0810748340185B262A88873E238F11C7A067D813E
...    31CF9863CA1607038782E007FE003801FF8002E0000702B8F88DAC1184341020F941A00AAD931561439F11C78C00000000000000000040E1E0
...    27FFC00001FFF000001700003801EF0F1340038820000042C040A83C28000E230000010B02B0F11800388200000C2C0AC3C28000E208000010
...    B02B0F13400388C0000042C0AC5C46000E208007104000028581587850001C4D00000C160562E2680071040038500000102C0AC5C4D000E230
...    00711800001058158B850001C41000E230000020B02B170A0003882001C41000004160562E26800710400388C0000082C0AC5C28000E230007
...    11800001058158B89A001C46000E140000040B02B0F11800388C00000C2C0803808D00A2026C04117400BB07C28913639F0E14489B1CF870A2
...    44D8E7C3851226C73E1C28913639F0E2448913639F0E14081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF811204081
...    B1CF811204081B1CF811204081B1CF810A040D8E7C00170F18C6318C6318C6318C61E82F003E002800301C1401C0C02500700060240040603E
...    09002000000010000020080000000400000802000008010000060080000400400002802001004010040000300200001C010008000000200002
...    001000012008000030040000500200002C01000812048020000300CE54D654D60A5606560CD60AD652D64CD602D606D6025604560ED0341000
...    009652504000065949410000296524040000E594901000049652404000165949010000696524040001E5949010000896524040002659490100
...    00A96524040002E5949410000C96524040000C594900CD2AABA55554AA2E95455058AA0B1541A2A94C55268AA031540A2A93555078A1601780
...    95028140A05028140A05028140A05028140A050281400182020180300801002101002008040300610080100202018030080600C10100C01804
...    0300610080100202018030080100220100C01804030060100C01820200401008010043543E00020406080C0E1416181A202224262830323638
...    3A3E424A4C4E5052545A5E828305A0

${xn_start}    122
${ng_start}    142
${ue_start}    3
${pci_start}    90
${gnb_id_start}    20
${inter_plmn_gnb_start}    3
${sim_gnb_num}    8


*** Test Cases ***
5GC0001085-ET_HO_with_multi_simgnb_without_XNlink_based_on_ANR_and_CA_enabled
    [Documentation]    1. The purpose of this test case is to
    ...    Verify inter-GNB intra/inter-Freq inter/intra-PLMN handover with ANR enabled while XN link is not established.
    ...    a. Configuraion:
    ...    1) real gnb id 2, PLMN - 311:489
    ...    NRCELL-1: FDD N71, 20M nr_arfcn=136660:127440 gscn=1590, ssbFreqency=127230
    ...    NRCELL-2: FDD N71, 10M nr_arfcn=133620:124400 gscn=1549, ssbFreqency=123890
    ...    2) simGnb id: 20~29, cell id: 20~29, cell pci: 90~99
    ...    simGnb 20~22: PLMN - 311:489, simGnb 23~29:  PLMN - 311:402
    ...    sim cell: FDD N71, nr_arfcn=136660:127440 gscn=1590, ssbFreqency=127230
    ...    b. Test step:
    ...    1) handover from real gnb cell-1/2 to simulate gnb
    ...    2) handover back from simulate gnb to real gnb cell-1/2
    [Tags]    Test
    FOR    ${loop_num}    IN RANGE    0    5
        Lock Cell2
        Unlock Cell2
        IntraFreq HO with MultiGnb    num_start=0    gnb_num=4
        Lock Cell1
        Unlock Cell1
        InterFreq HO with MultiGnb    num_start=4   gnb_num=${sim_gnb_num}
        Release Ues    ue_type=all
        check resources leakage
        sleep    5
    END


*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fdd_sansa_cmwv/2cells
    Comment    Debug Enter Into Egate

Modify Cfg
    Update Cfg    set_amf_region id=1 tac_list=7627107,100,788,200,0 plmn=311:489,311:402
    Update Cfg    amf_param id=1 full_nas_auth=on nia=null+aes nea=null+aes voice_fallback=off ims_voice_3gpp=on
    Update Cfg    set_qosflow id=1 5qi=5 default=off
    Update Cfg    set_qosflow id=2 5qi=1
    Update Cfg    set_qosflow id=3 5qi=9 default=on
    Update Cfg    set_qosflow id=4 5qi=7
    Update Cfg    set_qosrule id=1 proto=tcp qos_flow=1
    Update Cfg    set_qosrule id=2 proto=udp qos_flow=2
    Update Cfg    set_nwslice id=1 snssai=0x01:0xFFFFFF default=on ue=all amf=1 qos_flows=3,2,1 qos_rules=1,2
    Update Cfg    set_nwslice id=2 snssai=0x01:0xD143A6 ue=all amf=1 qos_flows=1,2 qos_rules=1,2

    Update Cfg    set_pdu_gateway id=3 ue_nat_ip=72.23.0.3 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=4 ue_nat_ip=72.23.0.4 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=5 ue_nat_ip=72.23.0.5 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=6 ue_nat_ip=72.23.0.6 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=7 ue_nat_ip=72.23.0.7 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=8 ue_nat_ip=72.23.0.8 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    FOR    ${ue_id}    IN RANGE    1    10
       ${ue_V}    catenate
        ...    set_ue simulated id=${ue_id} uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
        ...    nia=null+aes nea=null+aes sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0000:0:0:02164540${ue_id} mode=nr enb=2 cell=1
       Update Cfg    ${ue_V}
    END
    FOR    ${ue_id}    IN RANGE    10    31
       ${ue_V}    catenate
        ...    set_ue simulated id=${ue_id} uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
        ...    nia=null+aes nea=null+aes sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0000:0:0:0216454${ue_id} mode=nr enb=2 cell=1
       Update Cfg    ${ue_V}
    END
    Update Cfg    ue_nr_capabilities id=1-30 voice_over_nr=on:on:off
    Update Cfg    ue_param id=1-30 nr_usage_setting=voice_centric ue_nr_capabilities=${SA_Capa_2N71_ANR}
    ${GNB2}    catenate    set_gnb id=2 type=external plmn=311:489 s1u=10.0.1.2 x2=10.0.1.2:36422 ng=10.0.1.2 gnb_id=0x1:22
    ...    xn=10.0.1.2 x2_peers=none amf=1 daemon=10.0.2.1:22222
    Update Cfg    ${GNB2}
    ${GNB2_cell1}    catenate    set_cell id=1 gnb=2 pci=20:0 tac=788 nrci=0x01 nr_arfcn=136660:127440 gscn=1590
    ...    eci=0x000021f tdd_cell=off proxy=10.0.2.80:9999|10.0.2.80:8888
    Update Cfg    ${GNB2_cell1}
    ${GNB2_cell2}    catenate    set_cell id=2 gnb=2 pci=20:1 tac=200 nrci=0x02 nr_arfcn=133620:124400 gscn=1549
    ...    eci=0x000021f proxy=10.0.2.80:9999|10.0.2.80:8888 tdd_cell=off mandatory_for_activation=off
    Update Cfg    ${GNB2_cell2}

    #set simulate gnb 3
    ${SIM-GNB3}    catenate    set_gnb id=3 type=simulated plmn=311:402 ng=10.0.1.141 gnb_id=0x0A:22 daemon=10.0.2.1:22222
    ...    x2_peers=none xn=10.0.1.121 nssai=0x1:0xFFFFFF,0x1:0xd143a6,0x1:0xd143a5 amf=1
    Update Cfg    ${SIM-GNB3}
    Update Cfg    set_cell id=1 gnb=3 pci=10:0 tac=100 nrci=0x03 tdd_cell=off proxy=10.0.2.91:9999 nr_arfcn=136660:127440 gscn=1590
    Update Cfg    gnb_param id=3 xn_listening_socket=1 send_xn_setup=false sib1_period=160ms
	Update Cfg    gnb_cell_param id=1 gnb=3 enable_drx_profile_for_anr=on

    Update Cfg for Simulate GNBs


Update Cfg for Simulate GNBs
    FOR    ${idx}    IN RANGE    0    ${sim_gnb_num}
        ${gnb_id}    evaluate    ${gnb_id_start}+${idx}
        ${gnb_id_hex}    Convert to hex    ${gnb_id}
        ${xnip_suffix}    evaluate    ${xn_start}+${idx}
        ${ngip_suffix}    evaluate    ${ng_start}+${idx}
        ${proxyip_suffix}    evaluate    92+${idx}
        ${pci_prefix}    Convert To Integer    ${${${pci_start}+${idx}}/3}
        ${pci_suffix}    evaluate    ${idx}%3
        ${mnc}    Set Variable If    ${idx}>=${inter_plmn_gnb_start}    402    489
        ${sim_gnb_cmd}    catenate    set_gnb id=${gnb_id} plmn=311:${mnc} xn=10.0.1.${xnip_suffix} ng=10.0.1.${ngip_suffix}
        ...    gnb_id=0x${gnb_id_hex}:22 x2_peers=none daemon=10.0.2.1:22222 nssai=0x1:0xFFFFFF,0x1:0xd143a6,0x1:0xd143a5 amf=1 type=simulated
        Update Cfg    ${sim_gnb_cmd}
        ${sim_cell_cmd}    catenate
        ...    set_cell id=${gnb_id} gnb=${gnb_id} pci=${pci_prefix}:${pci_suffix} tac=100 nrci=0x${gnb_id_hex} tdd_cell=off
        ...    proxy=10.0.2.${proxyip_suffix}:9999 nr_arfcn=136660:127440 gscn=1590
        Update Cfg    ${sim_cell_cmd}
        Update Cfg    gnb_param id=${gnb_id} xn_listening_socket=1 send_xn_setup=false sib1_period=160ms
        Update Cfg    gnb_cell_param id=${gnb_id} gnb=${gnb_id} enable_drx_profile_for_anr=on
    END

Create New NRADJNRCELL Object
    [Arguments]    ${obj_id}    ${gnb_id}    ${pci}    ${mnc}    ${plmn_id}
    ${object_list}    create list
    ...    NRADJGNB-${obj_id}:administrativeState=Unlocked
    ...    NRADJGNB-${obj_id}:gNodeBId=${gnb_id}
    ...    NRADJGNB-${obj_id}:gNbIdLength=22
    ...    NRADJGNB-${obj_id}:gnbPlmn:mncLength=3
    ...    NRADJGNB-${obj_id}:gnbPlmn:mcc=311
    ...    NRADJGNB-${obj_id}:gnbPlmn:mnc=${mnc}
#    ...    NRADJNRCELL-${obj_id}:cellDepType=SA
#    ...    NRADJNRCELL-${obj_id}:gNbId=${gnb_id}
#    ...    NRADJNRCELL-${obj_id}:gNbIdLength=22
#    ...    NRADJNRCELL-${obj_id}:lcrId=${gnb_id}
#    ...    NRADJNRCELL-${obj_id}:nrarfcn=126900
#    ...    NRADJNRCELL-${obj_id}:physCellId=${pci}
#    ...    NRADJNRCELL-${obj_id}:gnbPlmn:mcc=311
#    ...    NRADJNRCELL-${obj_id}:gnbPlmn:mnc=${mnc}
#    ...    NRADJNRCELL-${obj_id}:gnbPlmn:mncLength=3
#    ...    NRADJNRCELL-${obj_id}/ADJ_NRPLMNSET_SA-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-${plmn_id}
#    ...    NRADJNRCELL-${obj_id}/ADJ_NRPLMNSET_SA-1:fiveGsTac=100
    [Return]    ${object_list}

Online Add NRADJNRCELL List
    ${params}    create list
    FOR    ${idx}    IN RANGE    0    ${sim_gnb_num}
        ${mnc}    Set Variable If    ${idx}>=${inter_plmn_gnb_start}    402    489
        ${plmn_id}    Set Variable If    ${idx}>=${inter_plmn_gnb_start}    2    1
        ${obj_list}    Create New NRADJNRCELL Object    obj_id=${${gnb_id_start}+${idx}}    gnb_id=${${gnb_id_start}+${idx}}
        ...     pci=${${pci_start}+${idx}}    mnc=${mnc}    plmn_id=${plmn_id}
        ${params}    Combine Lists    ${params}    ${obj_list}
    END
    OnlineParamChange    ${params}

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir

Trigger UE MO VoNR call with PDU
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${nwslice}=1    ${gw}=1    ${request_type}=initial-request    ${fiveQI}=9
    ...    ${additional_qosflows_to_activate}=reset    ${cipheringAlgorithm}=nea2
    Execute Egate Command    ue_change_location id=${ue_id} cell=1 enb=2
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Registered    timeout=20s
    ${cmd}    Catenate    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} nwslice=${nwslice} gw=${gw} request_type=${request_type}
    ${ret1}=    Execute Egate Command    ${cmd}    QoS Routing Table    timeout=20s
    Should Contain    ${ret1}=    securityModeCommand
    Should Contain    ${ret1}=    cipheringAlgorithm ${cipheringAlgorithm}
    Should Contain    ${ret1}=    Initial Context Setup Successful for UE with AMF UE
    Should Contain    ${ret1}=    Setup QosFlow with QFI:1 5QI:${fiveQI}

Set qosflow priority and smf param reset
    [Arguments]    ${additional_qosflows_to_activate}=2    ${priority}=1
    Execute Egate Command    qosflow_modify qos_flow=1 priority=${priority}
    Execute Egate Command    qosflow_modify qos_flow=2 priority=${priority}
    Execute Egate Command    qosflow_modify qos_flow=3 priority=${priority}
    Execute Egate Command    qosflow_modify qos_flow=4 priority=${priority}
    Execute Egate Command    smf_param id=1 reset

Reset qosflow priority and smf param
    Set qosflow priority and smf param reset    additional_qosflows_to_activate=reset    priority=15

Setup Xn Link To gNB${gnb}
    Execute Egate Command    gnb_param id=${gnb} xn_listening_socket=1 send_xn_setup=true
    Execute Egate Command    gnb_xn_link_up gnb=${gnb} target=2    GNB-${gnb}: XnAP Link with GNB-2 .* is up

Config AMF1 MRL For UE
    [Arguments]    ${ue_id}=1    ${equiv_plmn}=311:402     ${sa_plmn}=311:402    ${not_allowed_tacs}=100
    ...    ${fa_plmn}=311:409     ${forbidden_tacs}=311
    ${cmd1}    Catenate    amf_mobility_restriction_list_param id\=1 equiv_plmn\=${equiv_plmn}
    ...    sa_plmn\=${sa_plmn} not_allowed_tacs\=${not_allowed_tacs} fa_plmn=${fa_plmn} forbidden_tacs=${forbidden_tacs}
    Execute Egate Command    ${cmd1}
    ${cmd1}    Catenate    amf_mobility_restriction_list_param id=1
    Execute Egate Command    ${cmd1}    pass_regexp=${sa_plmn}
    ${cmd1}    Catenate    amf_ue_ics_param id=1 ue=${ue_id} mobility_restriction_list_id=1
    Execute Egate Command    ${cmd1}

Trigger UE MO VoNR Voice Call With One Normal and One Eemergency PDU Session
    [Arguments]    ${ue_id}=1    ${pdu_id1}=1    ${pdu_id2}=2    ${gw1}=1    ${gw2}=2    ${RRCEstablishmentCause}=3
    ...    ${cipheringAlgorithm}=nea2    ${mrl_set}=no    ${nwslice1}=1    ${fiveQI}=9    ${arp1}=15    ${arp2}=1
    ...    ${additional_qosflows_to_activate}=reset     ${notAllowedTAC}=100
    Set qosflow priority and smf param reset    additional_qosflows_to_activate=reset    priority=${arp1}
    Trigger UE MO VoNR call with PDU    ue_id=${ue_id}    pdu_id=${pdu_id1}    gw=${gw1}    nwslice=${nwslice1}    request_type=initial-request
    ...    fiveQI=${fiveQI}    cipheringAlgorithm=${cipheringAlgorithm}
    Set qosflow priority and smf param reset    additional_qosflows_to_activate=${additional_qosflows_to_activate}    priority=${arp2}
    Trigger UE Setup 2nd Call    ue_id=${ue_id}    pdu_id=${pdu_id2}    gw=${gw2}    priorityLevelARP=${arp2}    nwslice=2

Trigger UE Setup 2nd Call
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${nwslice}=1    ${gw}=1    ${request_type}=initial-emergency-request    ${priorityLevelARP}=1
    Trigger UE 5QI5 setup successfully with PDU    ue_id=${ue_id}    pdu_id=${pdu_id}    nwslice=${nwslice}    gw=${gw}
    ...    request_type=${request_type}
    #Trigger UE 5QI add successfully with PDU session modify    ue_id=${ue_id}    pdu_id=${pdu_id}

Trigger UE 5QI5 setup successfully with PDU
    [Arguments]    ${ue_id}=1    ${pdu_id}=2    ${nwslice}=2    ${gw}=3    ${request_type}=initial-emergency-request
    ${ret1}=    Execute Egate Command
    ...    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} nwslice=${nwslice} gw=${gw} request_type=${request_type}
    ...    Pdu Session Resource Setup Response Message with RAN UE NGAP ID [0-9]* handled successfully    timeout=20s
    Should Contain    ${ret1}=    rrcReconfiguration
    Should Contain    ${ret1}=    Setup QosFlow with QFI:1 5QI:5

Trigger UE 5QI add successfully with PDU session modify
    [Arguments]    ${ue_id}=1    ${pdu_id}=2    ${fiveQI}=1    ${qosflows_to_add}=2
    ${ret1}=    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_add=${qosflows_to_add} by=amf
   ...    Pdu Session Resource Modify Response Message with RAN UE NGAP ID [0-9]* handled successfully    timeout=20s
    Should Contain    ${ret1}=    rrcReconfiguration
    Should Contain    ${ret1}=    Added QosFlow with QFI:${qosflows_to_add} 5QI:${fiveQI}

Trigger UE Intra-Frequency Inter-gNB HO
    [Arguments]    ${ue_id}=1    ${event}=A3    ${phycell_id}=48    ${carrierfreq}=126990    ${pass_check}=Inter-eNB handover
    ${mea_id}    get nr meas id for specific type and frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A3
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${mea_id} event=${event} srsrp_nr=11 phycell_id=${phycell_id}
    ...    nrsrp_nr=80
    Execute Egate Command    ${cmd}    pass_regexp=${pass_check}

Release PDU Session One By One
    [Arguments]    ${ue_id}=1    ${sessions}=2
    FOR     ${session}    IN RANGE    1    ${sessions}+${1}
        sleep    10s    #Wait for command to complete
        Trigger UE PDU session release    ue_id=${ue_id}    pdu_id=${session}
    END

Trigger UE PDU session release
    [Arguments]    ${ue_id}=1    ${pdu_id}=1
    Execute Egate Command    ue_pdu_session_release ue=${ue_id} pdu=${pdu_id} by=ue    Successfully released PDU Session
    ...    timeout=20s

Trigger UE Intra-Frequency Inter-gNB HO fail
    [Arguments]    ${ue_id}=1    ${gscn}=1587    ${event}=A3    ${phycell_id}=381    ${ignoreNSSAI}=no
    ${mea_id}    get nr meas id for specific type and frequency    ue_id=${ue_id}    carrierfreq=126990    event_type=A3
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${mea_id} event=${event} srsrp_nr=11 phycell_id=${phycell_id}
    ...    nrsrp_nr=80
    Execute Egate Command    ${cmd}    pass_regexp=measResultNeighCells    fail_regexp=rrcReconfiguration

Check UE Location
    [Arguments]    ${ue_id}=1    ${enb}=2    ${cell}=1
    ${ret1}=    Execute Egate Command    ue_disp id=${ue_id}    PDN    timeout=20s
    Should Match Regexp    ${ret1}=    enb\\s{2,}${enb}
    Should Match Regexp    ${ret1}=    cell\\s{2,}${cell}

Check ue loacation and PM counters and Release ue
    Check UE Location    ue_id=1    enb=2    cell=1
    Check Wireshark Log    ${CURDIR}${/}a2a_B004${/}a2a_wireshark.ini    wait_string=UEContextReleaseComplete::2
    Check counters    ${counters_B04}
    Test case tear down for 784-B
    Release Ues    ue_type=all

Check PM counters and Release ue
    Check Wireshark Log    ${CURDIR}${/}a2a_B014${/}a2a_wireshark.ini    wait_string=UEContextReleaseComplete::1
    Check counters    ${counters_B14}
    Test case tear down for 784-B
    Release Ues    ue_type=all

Sim GNB ignore target gnb NSSAI
    [Arguments]    ${gnb_id}=5
    Execute Egate Command    gnb_param id=${gnb_id} ignore_MRL_during_HO=on ignore_NSSAI_during_HO=on

Test Setup For Case In Same Suite
    [Arguments]    ${param}
    Reset qosflow priority and smf param
    Delta Commission Parameters    ${param}
    Cells Should Be OnAir

Add UE History Information List For Handover
    [Arguments]    ${ue_id}=1    ${gnb_id}=3    ${plmn_list}=311:489    ${nrci}=0x01
    Execute Egate Command
    ...    ue_history_information_list_add_ngran id=1 cell_type=large nrcgi=311:489|0x01 gnb_id=2 time_ue_stayed_in_cell=97
    Execute Egate Command
    ...    ue_history_information_list_add_ngran id=1 cell_type=large nrcgi=${plmn_list}|${nrci} gnb_id=${gnb_id} time_ue_stayed_in_cell=98
    Execute Egate Command
    ...    ue_history_information_list_add_ngran id=1 cell_type=large nrcgi=311:489|0x01 gnb_id=2 time_ue_stayed_in_cell=99
    Execute Egate Command    ue_history_information_list id=1 action=commit
    Execute Egate Command    ue_enb_param id=${ue_id} ue_history_list=1

Trigger UE Setup 2nd Call Fail
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${nwslice}=1    ${gw}=1    ${request_type}=initial-emergency-request
    ...    ${priorityLevelARP}=1    ${causeRadioNetwork}=23
    Trigger UE 5QI5 setup successfully with PDU    ue_id=${ue_id}    pdu_id=${pdu_id}    nwslice=${nwslice}    gw=${gw}
    ...    request_type=${request_type}
    Trigger UE 5QI1 add failed    ue_id=${ue_id}    pdu_id=${pdu_id}

Trigger UE 5QI1 add failed
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${qosflows_to_add}=2
    ${ret1}=    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_add=${qosflows_to_add} by=amf
    ...    Pdu Session Resource Modify Response Message with RAN UE NGAP ID [0-9]* handled successfully    timeout=20s
    Should Contain    ${ret1}=    PDU Session Resource Modify Unsuccessful Transfer
    should not contain      ${ret1}=    fallback

Set qos pri and Trigger UE 2nd call
    [Arguments]    ${ue_id}=1
    Set qosflow priority and smf param reset    additional_qosflows_to_activate=reset    priority=15
    Trigger UE Setup 2nd Call Fail    ue_id=${ue_id}    pdu_id=3    gw=6    nwslice=2    request_type=initial-request    priorityLevelARP=15
    ...    causeRadioNetwork=23

Test case tear down for 784-B
    Reset qosflow priority and smf param
    Set AMF byPassAuth nullSecurity    bypass=off
    Remove MRL setting

Set AMF byPassAuth nullSecurity
    [Arguments]    ${amf_id}=1    ${bypass}=on
    Execute Egate Command    amf_param id=${amf_id} bypassAuth_nullSecurity=${bypass}

Remove MRL setting
    ${ret}=    Execute Egate Command    amf_mobility_restriction_list_param id=1 reset

Release PDU Session and tear down
    Release PDU Session One By One    ue_id=5
    Test case tear down for 784-B

Trigger UE Normal call
    [Arguments]    ${ue_id}=1    ${cell_id}=1    ${pdu_id}=1    ${nwslice}=1    ${gw}=1    ${request_type}=initial-request
    Execute Egate Command    ue_change_location id=${ue_id} cell=${cell_id} enb=2
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    ${cmd}    Catenate    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} nwslice=${nwslice} gw=${gw} request_type=${request_type}
    ${2cc_setup_blindly}    create list
    ...    QoS Routing Table
    ...    SCellIndex 1 activated successfully
    Execute Egate Command    ${cmd}    ${2cc_setup_blindly}

Send Throuput For SA
    [Arguments]    ${ue_id}=1
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=1    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=ul mbps=10 trf_id=2    UE ${ue_id}: UDP UL

Check Traffic
    [Arguments]     ${ue_id}=1    ${cell_num}=2    ${pdu_id}=1    ${min_dl_tput}=0   ${min_ul_tput}=0
    ${dl_throuput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=dl    rate_type=ave
    ${ul_throuput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=ul    rate_type=ave
    ${scells_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-2 type=pdsch    Throughput
    Should Not Match Regexp    ${scells_tput}    CellIndex-.*Mbps.*Mbps.*Mbps.* 0 Mbps
#    FOR    ${index}    IN RANGE    0    ${cell_num}
#         ${str_ue}    Convert To String    ${ue_id}
#         ${str_scell}    Convert To String    ${index}
#         ${scell_tput}    Ap Get Throuput On Specific Scell    ${str_ue}    ${str_scell}    pdsch
#         Should Be True    ${scell_tput}/1000 > 0
#    END
    Should Be True    ${dl_throuput}/1000 > ${min_dl_tput}
    Should Be True    ${ul_throuput}/1000 > ${min_ul_tput}

Object List Should Exist
    [Arguments]    ${param_list}
    FOR    ${param}    IN     @{param_list}
         Object Should Exist     ${param}    timeout=60
    END

Object List Should Not Exist
    [Arguments]    ${param_list}
    FOR    ${param}    IN     @{param_list}
         Object Should Not Exist     ${param}    timeout=60
    END

UE Register and Start Traffic
    [Arguments]    ${ue_id}=3    ${cell_id}=1
    Trigger UE Normal call    ue_id=${ue_id}    cell_id=${cell_id}
    Send Throuput For SA    ue_id=${ue_id}
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=${ue_id}    cell_num=2

Trigger UE intraFreq HO from Real Gnb to Simulate Gnb
    [Arguments]    ${ue_id}    ${src_cell}    ${src_pci}    ${src_freq}    ${dst_gnb}    ${dst_pci}    ${dst_freq}
    ${xnlink_up}    create list
    ...    GNB-${dst_gnb}: XnAP Link with GNB-2 .* is up
    ...    rrcReconfigurationComplete
    Trigger UE Intra-Frequency Inter-gNB HO    ue_id=${ue_id}    phycell_id=${dst_pci}    carrierfreq=${dst_freq}    pass_check=${xnlink_up}
    ${ho_success}    create list
    ...    UE${ue_id}: Inter-eNB handover from EXT_ENB-2.${src_cell} to ENB-${dst_gnb}.${dst_gnb}
    ...    rrcReconfigurationComplete
    Trigger UE Intra-Frequency Inter-gNB HO    ue_id=${ue_id}    phycell_id=${dst_pci}    carrierfreq=${dst_freq}    pass_check=${ho_success}
    Wait Until Keyword Succeeds    30s    3s    Check Traffic    ue_id=${ue_id}    cell_num=1

Trigger UE intraFreq HO Back from Simulate Gnb to Real Gnb
    [Arguments]    ${ue_id}    ${src_gnb}    ${src_freq}    ${dst_cell}   ${dst_pci}    ${dst_freq}
    ${ho_success}    create list
    ...    UE${ue_id}: Inter-eNB handover from ENB-${src_gnb}.${src_gnb} to EXT_ENB-2.${dst_cell} performed
    ...    rrcReconfigurationComplete
    ...    pcid:61, scellIdx:1
    Trigger UE Intra-Frequency Inter-gNB HO    ue_id=${ue_id}    phycell_id=${dst_pci}    carrierfreq=${dst_freq}    pass_check=${ho_success}
    Wait Until Keyword Succeeds    30s    3s    Check Traffic    ue_id=${ue_id}    cell_num=1

Trigger UE Inter-Frequency Inter-gNB HO
    [Arguments]    ${ue_id}    ${dst_pci}    ${src_freq}    ${dst_freq}    ${pass_check}
    ${a2_measid}    get nr meas id for specific type and frequency    ue_id=${ue_id}    carrierfreq=${src_freq}    event_type=A2
    Execute Egate Command
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${a2_measid} event=A2 srsrp_nr=7 srsrq_nr=7
    ...    pass_regexp=eventA3
    ${a3_measid}    get nr meas id for specific type and frequency    ue_id=${ue_id}    carrierfreq=${dst_freq}    event_type=A3
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${a3_measid} event=A3 srsrp_nr=11 phycell_id=${dst_pci}
    ...    nrsrp_nr=80
    Execute Egate Command    ${cmd}    pass_regexp=${pass_check}

Trigger UE interFreq HO from Real Gnb to Simulate Gnb
    [Arguments]    ${ue_id}=3    ${src_cell}=2    ${src_pci}=61    ${src_freq}=126530    ${dst_gnb}=20
    ...    ${dst_pci}=90    ${dst_freq}=126990
    ${xnlink_up}    create list
    ...    GNB-${dst_gnb}: XnAP Link with GNB-2 .* is up
    ...    eventA2
    ...    rrcReconfigurationComplete
    Trigger UE Inter-Frequency Inter-gNB HO    ue_id=${ue_id}    dst_pci=${dst_pci}    src_freq=${src_freq}    dst_freq=${dst_freq}
    ...    pass_check=${xnlink_up}
    ${ho_success}    create list
    ...    UE${ue_id}: Inter-eNB handover from EXT_ENB-2.${src_cell} to ENB-${dst_gnb}.${dst_gnb}
    ...    rrcReconfigurationComplete
    Trigger UE Inter-Frequency Inter-gNB HO    ue_id=${ue_id}    dst_pci=${dst_pci}    src_freq=${src_freq}    dst_freq=${dst_freq}
    ...    pass_check=${ho_success}
    Wait Until Keyword Succeeds    30s    3s    Check Traffic    ue_id=${ue_id}

Trigger UE interFreq HO Back from Simulate Gnb to Real Gnb
    [Arguments]    ${ue_id}=3    ${src_gnb}=20    ${src_freq}=126990    ${dst_cell}=1   ${dst_pci}=61    ${dst_freq}=126530
    ${ho_success}    create list
    ...    UE${ue_id}: Inter-eNB handover from ENB-${src_gnb}.${src_gnb} to EXT_ENB-2.${dst_cell} performed
    ...    rrcReconfigurationComplete
    ...    pcid:60, scellIdx:1
    Trigger UE Inter-Frequency Inter-gNB HO    ue_id=${ue_id}    dst_pci=${dst_pci}    src_freq=${src_freq}    dst_freq=${dst_freq}
    ...    pass_check=${ho_success}
    Wait Until Keyword Succeeds    30s    3s    Check Traffic    ue_id=${ue_id}

IntraFreq HO with MultiGnb
    [Arguments]    ${num_start}    ${gnb_num}
    ${params_remove}    create list
    FOR    ${idx}    IN RANGE    ${num_start}    ${gnb_num}
        ${ue_id}    evaluate    ${ue_start}+${idx}
        ${gnb_id}    evaluate    ${gnb_id_start}+${idx}
        ${xnip_suffix}    evaluate    ${xn_start}+${idx}
        ${pci}    evaluate    ${pci_start}+${idx}
        ${mnc}    Set Variable If    ${idx}>=${inter_plmn_gnb_start}    402    489
        UE Register and Start Traffic    ue_id=${ue_id}    cell_id=1
        Trigger UE intraFreq HO from Real Gnb to Simulate Gnb    ue_id=${ue_id}    src_cell=1    src_pci=60    src_freq=127230
        ...    dst_gnb=${gnb_id}    dst_pci=${pci}    dst_freq=127230
        Trigger UE intraFreq HO Back from Simulate Gnb to Real Gnb    ue_id=${ue_id}   src_gnb=${gnb_id}    src_freq=127230
        ...    dst_cell=1    dst_pci=60    dst_freq=127230
        ${params_add}    create list
        ...    XNLINK:cPlaneIpAddr=10.0.1.${xnip_suffix}
        ...    NRADJGNB:gNodeBId=${gnb_id}
        ...    NRADJNRCELL:physCellId=${pci}
        ...    NRCELL-1/NRREL:lcrId=${gnb_id}
        ...    NRCELL-1/NRREL:gNbId=${gnb_id}
#        ...    NRCELL-1/NRREL:gnbPlmn:mnc=${mnc}
        Wait Until Keyword Succeeds    2min    5s    Object List Should Exist    ${params_add}
        append to list    ${params_remove}      @{params_add}
    END
    Wait Until Keyword Succeeds    3min    5s    Object List Should Not Exist    ${params_remove}
    ${params_not_remove}    create list
    ...    NRCELL-1/NRREL-1:lcrId=2
    ...    NRCELL-2/NRREL-1:lcrId=1
    Object List Should Exist    ${params_not_remove}

InterFreq HO with MultiGnb
    [Arguments]    ${num_start}    ${gnb_num}
    ${params_remove}    create list
    FOR    ${idx}    IN RANGE    ${num_start}    ${gnb_num}
        ${ue_id}    evaluate    ${ue_start}+${idx}
        ${gnb_id}    evaluate    ${gnb_id_start}+${idx}
        ${xnip_suffix}    evaluate    ${xn_start}+${idx}
        ${pci}    evaluate    ${pci_start}+${idx}
        ${mnc}    Set Variable If    ${idx}>=${inter_plmn_gnb_start}    402    489
        UE Register and Start Traffic    ue_id=${ue_id}    cell_id=2
        Trigger UE interFreq HO from Real Gnb to Simulate Gnb    ue_id=${ue_id}    src_cell=2    src_pci=61    src_freq=123890
        ...    dst_gnb=${gnb_id}    dst_pci=${pci}    dst_freq=127230
        Trigger UE interFreq HO Back from Simulate Gnb to Real Gnb    ue_id=${ue_id}   src_gnb=${gnb_id}    src_freq=127230
        ...    dst_cell=2    dst_pci=61    dst_freq=123890
        ${params_add}    create list
        ...    XNLINK:cPlaneIpAddr=10.0.1.${xnip_suffix}
        ...    NRADJGNB:gNodeBId=${gnb_id}
        ...    NRADJNRCELL:physCellId=${pci}
        ...    NRCELL-2/NRREL:lcrId=${gnb_id}
        ...    NRCELL-2/NRREL:gNbId=${gnb_id}
        Wait Until Keyword Succeeds    2min    5s    Object List Should Exist    ${params_add}
        append to list    ${params_remove}    @{params_add}
    END
    Wait Until Keyword Succeeds    3min    5s    Object List Should Not Exist    ${params_remove}
    ${params_not_remove}    create list
    ...    NRCELL-1/NRREL-1:lcrId=2
    ...    NRCELL-2/NRREL-1:lcrId=1
    Object List Should Exist    ${params_not_remove}

