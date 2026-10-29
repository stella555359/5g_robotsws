*** Settings ***
Suite Setup       Common Suite Setup And Setup IPHY Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    CRT    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...               team-CN3ET    owner-lishuo.geng    release-SBTS23R1
Resource    ../../../../../../resources/DevHZ5_resource.robot

*** Variables ***
${GNB1_CONFIG}    tdd_sansa_cmwv/FS/3cells_ecpri

@{PARAMS_IN_SWCONFIG}
...    ${rdPCsiPoolHkfPeriod_min}
...    ${rdHkfMinPCsiResPerSlot}
...    ${rdHkfMinPCsiRepPeriod}
...    ${rdHkfPCsiPoolMaxRCUsFactor}
...    ${uplane_6878}

${rdPCsiPoolHkfPeriod_min}    0x5901A6=1
${rdHkfMinPCsiResPerSlot}    0x5901A7=4
${rdHkfMinPCsiRepPeriod}    0x5901A8=40
${rdHkfPCsiPoolMaxRCUsFactor}    0x5901A9=60
${uplane_6878}    0x5901AB=1

@{PARAMS_IN_SCF}    @{CB006878}    @{5GC000704}    @{5GC00572}    @{dedicate_small_BWP}    @{power_saving_BWP}    @{CA}
@{CB006878}
...    NRBTS:actBbPoolTddFr1=true
...    NRCELL-1:actDynUlResAlloc=true
...    NRCELL-2:actDynUlResAlloc=false
...    NRCELL-3:actDynUlResAlloc=false
...    NRCELL:srPeriodicity=slots20
...    NRCELL:periodicCsiAcquisition:csiReportPeriodicity=slots40
...    NRCELL:reqMinNumPuschPrb=247
...    NRCELL:pucchModeSelect=longPucch
...    NRBTS:srbInactivityTimerSA=600
...    NRBTS:nsaInactivityTimer=600
...    NRCELL-1/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-1:msg1FrequencyStart=24
...    NRCELL-2:msg1FrequencyStart=12
...    NRCELL-3:msg1FrequencyStart=12
...    NRCELL:maxNumOfUsersPerNRCell=48
...    NRCELL:maxNumOfSCellAlloc=48
...    NRCELL:maxNumOfUsersPerCell=48
...    NRCELL:maxNumOfRrcSA=48
...    NRCELL:maxNumOfNrDcSnUsers=48

@{5GC00572}
...    NRBTS:actIntraFreqIntraGnbMobilityNSA=true
...    NRBTS:actIntraMeNBMobility=true

@{5GC000704}
...    NRBTS:actConflictConfiguration=true
...    NRBTS:actIntraFreqHoSA=true
...    NRBTS:timerXnDataFwdGuard=250
...    NRPMRNL-1:miNrRelReportCu=5min
...    NRCELL:a3MeasEnabled=rsrp
...    NRCELL:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0|a3TimeToTriggerSsbRsrp=ms320
...    NRCELL:a3MeasSsbRsrp:a3OffsetSsbRsrp=3|a3TimeToTriggerSsbRsrp=ms320
...    NRCELL:filterCoeffSsbRsrp=fc4
...    NRCELL:absThreshSsbRsrpConsolidation=80
...    NRCELL:sMeasConfigSsbRsrp=20
...    NRBTS:actIncXn=true
...    NRBTS:cipherPrefL:nea0=9|nea3_128=0
...    NRCELL:numOfRadioResReservForEmergency=1
...    NRBTS/NRDU-1:numOfDrbsReservForEmergency=1
...    NRCELL:maxNumOfGBRBearersSA=10
...    NRCELL:maxNumOfCaUsersNRCell=20

@{CA}
...    @{NRREL}
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

@{NRREL}
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-2:gNbId=1
...    NRCELL-1/NRREL-2:gNbIdLength=22
...    NRCELL-1/NRREL-2:lcrId=2
...    NRCELL-1/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-1:gNbId=1
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:lcrId=3
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-1:gNbId=1
...    NRCELL-2/NRREL-1:gNbIdLength=22
...    NRCELL-2/NRREL-1:lcrId=1
...    NRCELL-2/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL:actK1Opt=intra-gNB
...    NRCELL-1/NRREL-1:sCellAdditionMethod=blind

@{dedicate_small_BWP}
...    NRBTS:actMultipleDedicatedBWPs=true
...    NRBTS/BWP_PROFILE-62:bwpType=dedicated
...    NRBTS/BWP_PROFILE-62:locationAndBandwidthDl:cRbSizeDl=n217
...    NRBTS/BWP_PROFILE-62:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-62:locationAndBandwidthUl:cRbSizeUl=sameAsDl
...    NRBTS/BWP_PROFILE-62:locationAndBandwidthUl:cRbStartUl=sameAsDl
...    NRBTS/BWP_PROFILE-62/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-62/PDCCH-1:dciDedicatedAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-62/PDCCH-1:dciPagingAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-62/PDCCH-1:dciRaCompletionAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-62/PDCCH-1:dciRaMsg2AggregationLevel=AL4
...    NRBTS/BWP_PROFILE-62/PDCCH-1:dciSiAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-62/PDCCH-1:downgradeAL16toAL8=notAllowed
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=3|searchSpaceId=9
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=9
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceId=9
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=9
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=10
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=10
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n4|searchSpaceId=10
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=10
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=10
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=3|searchSpaceId=11
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=11
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl20|searchSpaceId=11
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=11
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=5|searchSpaceId=11
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cceToRegMapping=nonInterleaved
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:coresetId=4
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cRbStart=0
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:duration=1
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:interleaverSize=none
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:regBundleSize=n6
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=120
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-0-And-1-0|coresetId=0
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|coresetId=0
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=0
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=0
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=0
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=0
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n4|coresetId=0
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=0
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|coresetId=0
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=12|coresetId=0
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|coresetId=0
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=0
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|coresetId=4
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|coresetId=4
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=4
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=4
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=4
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=4
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n5|coresetId=4
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=4
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|coresetId=4
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=13|coresetId=4
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|coresetId=4
...    NRBTS/BWP_PROFILE-62/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=4
...    NRBTS/BWP_PROFILE-62/PDSCH-1:pdschRat0RbgConfig=config1
...    NRBTS/BWP_PROFILE-5:locationAndBandwidthDl:cRbSizeDl=n217
...    NRBTS/BWP_PROFILE-5:locationAndBandwidthDl:cRbStartDl=crb0

@{power_saving_BWP}
...    NRCELL-1:maxNumberUesPowerSaving=400
...    NRCELL-1:maxNumberVoNRPowerSaving=250
...    NRBTS/BWP_PROFILE-63:bwpType=powerSaving
...    NRBTS/BWP_PROFILE-63:locationAndBandwidthDl:cRbSizeDl=n162
...    NRBTS/BWP_PROFILE-63:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-63:locationAndBandwidthUl:cRbSizeUl=sameAsDl
...    NRBTS/BWP_PROFILE-63:locationAndBandwidthUl:cRbStartUl=sameAsDl
...    NRBTS/BWP_PROFILE-63/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-63/PDCCH-1:dciDedicatedAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-63/PDCCH-1:dciPagingAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-63/PDCCH-1:dciRaCompletionAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-63/PDCCH-1:dciRaMsg2AggregationLevel=AL4
...    NRBTS/BWP_PROFILE-63/PDCCH-1:dciSiAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-63/PDCCH-1:downgradeAL16toAL8=notAllowed
...    NRBTS/BWP_PROFILE-63/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=14
...    NRBTS/BWP_PROFILE-63/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=14
...    NRBTS/BWP_PROFILE-63/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=3|searchSpaceId=14
...    NRBTS/BWP_PROFILE-63/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=14
...    NRBTS/BWP_PROFILE-63/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=14
...    NRBTS/BWP_PROFILE-63/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=14
...    NRBTS/BWP_PROFILE-63/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=14
...    NRBTS/BWP_PROFILE-63/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=14
...    NRBTS/BWP_PROFILE-63/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceId=14
...    NRBTS/BWP_PROFILE-63/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=14
...    NRBTS/BWP_PROFILE-63/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=14
...    NRBTS/BWP_PROFILE-63/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=15
...    NRBTS/BWP_PROFILE-63/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=15
...    NRBTS/BWP_PROFILE-63/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=15
...    NRBTS/BWP_PROFILE-63/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=15
...    NRBTS/BWP_PROFILE-63/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=15
...    NRBTS/BWP_PROFILE-63/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=15
...    NRBTS/BWP_PROFILE-63/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n4|searchSpaceId=15
...    NRBTS/BWP_PROFILE-63/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=15
...    NRBTS/BWP_PROFILE-63/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=15
...    NRBTS/BWP_PROFILE-63/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=15
...    NRBTS/BWP_PROFILE-63/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=15
...    NRBTS/BWP_PROFILE-63/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=16
...    NRBTS/BWP_PROFILE-63/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=16
...    NRBTS/BWP_PROFILE-63/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=3|searchSpaceId=16
...    NRBTS/BWP_PROFILE-63/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=16
...    NRBTS/BWP_PROFILE-63/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=16
...    NRBTS/BWP_PROFILE-63/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=16
...    NRBTS/BWP_PROFILE-63/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=16
...    NRBTS/BWP_PROFILE-63/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=16
...    NRBTS/BWP_PROFILE-63/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl20|searchSpaceId=16
...    NRBTS/BWP_PROFILE-63/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=16
...    NRBTS/BWP_PROFILE-63/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=5|searchSpaceId=16
...    NRBTS/BWP_PROFILE-63/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cceToRegMapping=nonInterleaved
...    NRBTS/BWP_PROFILE-63/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:coresetId=4
...    NRBTS/BWP_PROFILE-63/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cRbStart=0
...    NRBTS/BWP_PROFILE-63/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:duration=1
...    NRBTS/BWP_PROFILE-63/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:interleaverSize=none
...    NRBTS/BWP_PROFILE-63/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:regBundleSize=n6
...    NRBTS/BWP_PROFILE-63/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=120
...    NRBTS/BWP_PROFILE-63/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-0-And-1-0|coresetId=0
...    NRBTS/BWP_PROFILE-63/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|coresetId=0
...    NRBTS/BWP_PROFILE-63/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=0
...    NRBTS/BWP_PROFILE-63/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=0
...    NRBTS/BWP_PROFILE-63/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=0
...    NRBTS/BWP_PROFILE-63/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=0
...    NRBTS/BWP_PROFILE-63/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n4|coresetId=0
...    NRBTS/BWP_PROFILE-63/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=0
...    NRBTS/BWP_PROFILE-63/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|coresetId=0
...    NRBTS/BWP_PROFILE-63/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=17|coresetId=0
...    NRBTS/BWP_PROFILE-63/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|coresetId=0
...    NRBTS/BWP_PROFILE-63/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=0
...    NRBTS/BWP_PROFILE-63/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|coresetId=4
...    NRBTS/BWP_PROFILE-63/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|coresetId=4
...    NRBTS/BWP_PROFILE-63/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=4
...    NRBTS/BWP_PROFILE-63/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=4
...    NRBTS/BWP_PROFILE-63/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=4
...    NRBTS/BWP_PROFILE-63/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=4
...    NRBTS/BWP_PROFILE-63/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n5|coresetId=4
...    NRBTS/BWP_PROFILE-63/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=4
...    NRBTS/BWP_PROFILE-63/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|coresetId=4
...    NRBTS/BWP_PROFILE-63/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=18|coresetId=4
...    NRBTS/BWP_PROFILE-63/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|coresetId=4
...    NRBTS/BWP_PROFILE-63/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=4
...    NRBTS/BWP_PROFILE-63/PDSCH-1:pdschRat0RbgConfig=config1
...    NRCELL-1:actPowerSavingBWP=true
...    NRCELL-1:cellBwpList:cellBwpId=0|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-5
...    NRCELL-1:cellBwpList:cellBwpId=1|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-54
...    NRCELL-1:cellBwpList:cellBwpId=2|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-63
...    NRCELL-1:cellBwpList:cellBwpId=3|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-62

${UE_small_bwp}    SEPARATOR=
...    E9A09000575F5A13160003C0A02C1262E003387A0213641873E618F28581C130080C4700FB8D85181AC1184341020E9008DAD931563439F1
...    1C7A067D813E31238F21CFA8E7CC31E50B0381C3C170005F001C0017C000300E0741B13703582308682041D201195B262AC4873EC09F11C7
...    8C48E3C873EA39F30C7942C0E070F09FD817C007F605F0000C0381506C46D608C21A081078804656C98AB121CFB027C471E31238F21CFA8E
...    7CC31E50B0381C3C27F0000001FC0000000300E0541B107582308682041E201195B262AC4873EC09F11C78C48E3C873EA39F30C7942C0E07
...    0F09FC0AAAAA7F02AAAA80C03800CA07118100000481507050071180000084815878500018460001048158389A10000C041D61E268006134
...    0008020EA17104003882001C4600000A120E00E023402880010104048606813B639F0E14E9DB1CF870A24ED8E7C38113639F0E1449DB1CF8
...    712006C73E1BD01C078005038080E0600601C090010180F82400800000004000008020000000100000200800002004000018020000100100
...    000A008004010040100000C0080000700400200000008000080040000480200100C030040000500200002C01000812048020000300CE52D6
...    52D60A5606560CD60AD652D64CD602D606D6025604560ED0341000009652504000065949410000296524040000E594901000049652404000
...    165949010000696524040001E594901000089652404000265949010000A96524040002E5949410000C96524040000C594900C52AABA55554
...    AA2E95455058AA071541A2A94C55268AA031540A2A93555078A022F012A05028140A05028140A05028140A05028140A05028002800407806
...    08080100002018030404008020100C0000020300104040080201002000402018030080600C02018030D50F80008101820303850586068808
...    89098A0C0C8D8E0E8F909293139414951697A0A08350
${UE_powersaving_bwp}    SEPARATOR=
...    E1A2538057E0220082000F7A03560003C3A800B010880002000600409063D011EC00F04C990E7C8B5E82AF6097A067D813E078F11C784004
...    06024C5C00670F42400C4834026010188E01F51B0A303582308682041D20D80516CAA2A121CFA067D813E31CF9863CA16070387802100000
...    3080A090500B8002F800E000BE000B10C06CA0000A0000001480180AA3E236B04610D04083C41B0092D954541439F40CF8C73E618F28581C
...    0E1E00420000061014120A027F0000001FC0000001601802900301546C4DD608C21A0810748360145B2A8A84873E819F604F8C73E618F285
...    81C0E1E008400000C2028241402E000B60038002D8002C03005200602A8F883AC1184341020F106C024B65515050E7D033E31CF9863CA160
...    70387801080000184050482809FD0000007F4000000584600C100A400C000A85C4D000E2302060A0000E720E00A0234028809A2A80044031
...    204E365AF1C00140467A0B500F800C001C0000040500603009401800180F80C0080000000400000802000008010008000000200100401004
...    002000040080000300F9535819794B5811403040000006C0410000101B000400008000001000030000000F4AAAE95455028AA07142D01D80
...    6A07028140E05038001A1084002680310000008040000020100000080400000200048804008010100400004010001008010020200C000080
...    2000001008004202004008080500010100C00404010001018010050020080C0380380200806008004038001008010040200C000080200820
...    10020080402804010020002020180100802008101004010040100002C5C0501805288080198C
${UE_band_78A_band78A_CA_capability}    SEPARATOR=
...    E9A09000575F5A13160003C0A02C1262E003387A0213641873E618F28581C130080C4700FB8D85181AC1184341020E9008DAD931563439F1
...    1C7A067D813E31238F21CFA8E7CC31E50B0381C3C170005F001C0017C000300E0741B13703582308682041D201195B262AC4873EC09F11C7
...    8C48E3C873EA39F30C7942C0E070F09FD817C007F605F0000C0381506C46D608C21A081078804656C98AB121CFB027C471E31238F21CFA8E
...    7CC31E50B0381C3C27F0000001FC0000000300E0541B107582308682041E201195B262AC4873EC09F11C78C48E3C873EA39F30C7942C0E07
...    0F09FC0AAAAA7F02AAAA80C03800CA07118100000481507050071180000084815878500018460001048158389A10000C041D61E268006134
...    0008020EA17104003882001C4600000A120E00E023402880010104048606813B639F0E14E9DB1CF870A24ED8E7C38113639F0E1449DB1CF8
...    712006C73E1BD01C078005038080E0600601C090010180F82400800000004000008020000000100000200800002004000018020000100100
...    000A008004010040100000C0080000700400200000008000080040000480200100C030040000500200002C01000812048020000300CE54D6
...    54D60A5606560CD60AD652D64CD602D606D6025604560ED0341000009652504000065949410000296524040000E594901000049652404000
...    165949010000696524040001E594901000089652404000265949010000A96524040002E5949410000C96524040000C594900C52AABA55554
...    AA2E95455058AA071541A2A94C55268AA031540A2A93555078A022F012A05028140A05028140A05028140A05028140A05028002800407806
...    08080100002018030404008020100C0000020300104040080201002000402018030080600C02018030D50F80008101820303850586068808
...    89098A0C0C8D8E0E8F909293139414951697A0A08350
${default_ue_capability}    SEPARATOR=
...    e1a00000074e5a031e000380a03c1260c80008780818806804c020301c032a36146b04050d012cb2898087ad8202020e1de38720c3800206
...    4f1f570004f001c0013c002a36266b04050d012cb2898087ad8202020e1de38720c38002064f1f570004f001c0013c002a3626eb04050d01
...    2cb2898087ad8202020e1de38720c38002064f1f570004f001c0013c002a36276b04050d012cb2898087ad8202020e1de38720c38002064f
...    1f55000005000000108389a00000000404d0103804044f60701800140e020381801c07000683e0000000000000e54d000100000965950034
...    aaa8081c002c000000100200462c4c0004080c1014181c202c4044484c648494989ca128

${PCsiPoolHkfPeriod_min}    60s
${SYSCOM_FLAG}    true

*** Test Cases ***
CB006878-SR-B_ET_B1_06_01_Verify PUCCH layout with power saving BWP
    [Documentation]
    ...    checkpoints:
    ...    1.UEs do BWP change to power saving BWP when no throughput
    ...    2.check HARQ layout
    ...    3.check SR allocation of every UE
    ...    4.check CSI allocation of every UE
    [Tags]
    Start To Capture AP Wireshark
    Lock And Unlock cell1 to make sure UE position no change
    Ues Attach And BWP Switch To PowerSaving BWP    cell_id=1    ue_id_start=1    ue_id_end_before=13
    Release Ues    ue_type=all
    Check Wireshark Log    ${CURDIR}${/}a2a_b1_case0506${/}HKF.ini    wait_string=rrcReconfigurationComplete::84
    Stop Capture AP Wireshark

*** Keywords ***
Common Suite Setup And Setup IPHY Env
    Common Suite Setup
    Setup Airphone Env    tl_type=${GNB1_CONFIG}

Perform Steps After Onair
    Check Wireshark Log    ${CURDIR}${/}a2a_b1_after_onair_check${/}HKF.ini    wait_string=CellSetupReq::18

Lock And Unlock cell1 to make sure UE position no change
    Lock Cell1
    Unlock Cell1
    Cells Should Be Onair    1

Register For Normal Call Successfully
  [Arguments]    ${ue_id}    ${cell_id}    ${ue_nr_capabilities}=${default_ue_capability}
  Execute Egate Command    ue_change_location id=${ue_id} cell=${cell_id}    ${cell_id}
  Execute Egate Command    ue_register id=${ue_id} ue_nr_capabilities=${ue_nr_capabilities}    UE now in NG RM Reg

Register And Set up PDU For Normal Call Successfully
  [Arguments]    ${ue_id}    ${cell_id}
  Register For Normal Call Successfully    ${ue_id}    ${cell_id}
  UE PDU Session Setup    ${ue_id}    ${ue_id}

Register And Set up PDU For Number Of Normal Calls And Check Scell Addition
    [Arguments]    ${cell_id}    ${ue_id_start}    ${ue_id_end_before}
    FOR    ${ue_id}    IN RANGE    ${ue_id_start}    ${ue_id_end_before}
        Register For Normal Call Successfully    ue_id=${ue_id}    cell_id=${cell_id}
        ...    ue_nr_capabilities=${UE_band_78A_band78A_CA_capability}
        ${ret1}=    Execute Egate Command    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=${ue_id}    scellIdx:1
        Should Contain    ${ret1}    reportSlotConfig slots40 : 14
        Should Contain    ${ret1}    reportSlotConfig slots40 : 19
    END

UE PDU Session Setup
    [Arguments]    ${ue_id}=1    ${gw_id}=1
    ${ret1}=    Execute Egate Command    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=${gw_id}    QoS Routing Table
    Should Contain    ${ret1}    Initial Context Setup Successful

UE HO To Target Cell1 Successfully for SA
    [Arguments]    ${ue_id}
    ${ret1}=    Execute Egate Command
    ...    ue_measurement_send_nr id=${ue_id} meas_id=1 event=A3 srsrp_nr=50 srsrq_nr=30 phycell_id=50 nrsrp_nr=70 nrsrq_nr=30
    ...    Intra-eNB handover from EXT_ENB-2.2 to EXT_ENB-2.1 performed

UE ICS And Wait BWP Switch To PowerSaving BWP
    [Arguments]    ${ue_id}=1
    ${ret1}=    Execute Egate Command    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=${ue_id}    Bwp Switched from bwpId 1 to 2
    Should Contain    ${ret1}    Initial Context Setup Successful

UE ICS And Wait BWP Switch To Samll BWP
    [Arguments]    ${ue_id}=1
    ${ret1}=    Execute Egate Command    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=${ue_id}    QoS Routing Table
    Should Contain    ${ret1}    Initial Context Setup Successful
    Should Contain    ${ret1}    locationAndBandwidth 31624

Ues Attach And BWP Switch To PowerSaving BWP
    [Arguments]    ${cell_id}    ${ue_id_start}    ${ue_id_end_before}
    FOR    ${ue_id}    IN RANGE    ${ue_id_start}    ${ue_id_end_before}
        Register For Normal Call Successfully    ${ue_id}    ${cell_id}    ${UE_powersaving_bwp}
        UE ICS And Wait BWP Switch To PowerSaving BWP    ${ue_id}
    END

Ues Attach And BWP Switch To Small BWP
    [Arguments]    ${cell_id}    ${ue_id_start}    ${ue_id_end_before}
    FOR    ${ue_id}    IN RANGE    ${ue_id_start}    ${ue_id_end_before}
        Register For Normal Call Successfully    ${ue_id}    ${cell_id}    ${UE_small_bwp}
        UE ICS And Wait BWP Switch To Samll BWP    ${ue_id}
    END

Wait For HKF timer timeout
    sleep    ${PCsiPoolHkfPeriod_min}

HKF will not happen
    execute egate command    set_log flush    fail_regexp=startingPRB    timeout=${PCsiPoolHkfPeriod_min}

Start To Capture AP Wireshark
   execute cmd on wts      nohup tcpdump -i br0 -vvv -s3000 -A -w /tmp/madani_rfh4.pcap > /tmp/nohup_w1.out 2>&1 &

Stop Capture AP Wireshark
   execute cmd on wts     pkill tcpdump
   get wts file    /tmp/madani_rfh4.pcap    ${SAVE LOG DIRECTORY}