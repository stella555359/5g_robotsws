*** Settings ***
Suite Setup       Common Suite Setup And Setup IPHY Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CRT    CLOUD_5G_I_BOO_AP_LOO
...               team-CN3ET    owner-pei.han    release-SBTS23R2
Resource    ../../../../../../resources/DevHZ5_resource.robot

*** Variables ***
${SYSCOM_FLAG}  ${True}
${GNB_CONFIG}    fddtdd_sansa_cmwv/4cells_2F2T
${BTS_STARTUP_RETRY}    2
@{PARAMS_IN_SWCONFIG}
...    @{rdULCaEnablerPhase}
...    @{rdUseOptimizedDpaAlgo}
@{rdULCaEnablerPhase}
...    0x580591=0
@{rdUseOptimizedDpaAlgo}
...    0x58056B=1
@{PARAMS_IN_SCF}
...    @{CB006137}
...    @{CA}
...    @{NRREL}
...    @{Mobillity}
...    @{VONR}
...    @{Others}
...    @{gscn_Arfcn}
...    @{CDRX}
...    @{srsConfig}
...    @{Beamforming}
...    @{FrameStructure}
...    @{Overheating}
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=48
...    NRCELL:periodicCsiAcquisition:csiReportPeriodicity=slots320
...    BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=1
...    BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=1
...    BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=3|searchSpaceId=1
...    BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=1
...    BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=1
...    BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=1
...    BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=1
...    BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=1
...    BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceId=1
...    BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=1
...    BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=1
...    BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=2
...    BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=2
...    BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=2
...    BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=2
...    BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=2
...    BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=2
...    BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=2
...    BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=2
...    BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=2
...    BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=2
...    BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=2
...    BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=3
...    BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=3
...    BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=3|searchSpaceId=3
...    BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=3
...    BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=3
...    BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=3
...    BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=3
...    BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=3
...    BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceId=3
...    BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=3
...    BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=3
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-0-And-1-0|coresetId=0
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|coresetId=0
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=0
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=0
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=0
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=0
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|coresetId=0
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=0
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|coresetId=0
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=7|coresetId=0
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|coresetId=0
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=0
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|coresetId=1
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|coresetId=1
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=1
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=1
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=1
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=1
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|coresetId=1
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=1
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|coresetId=1
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=8|coresetId=1
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|coresetId=1
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=1
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=4
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=4
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=3|searchSpaceId=4
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=4
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=4
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=4
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=4
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=4
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceId=4
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=4
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=4
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=5
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=5
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=5
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=5
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=5
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=5
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=5
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=5
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=5
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=5
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=5
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=6
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=6
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=3|searchSpaceId=6
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=6
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=6
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=6
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=6
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=6
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceId=6
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=6
...    BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=6
...    @{fix_relation_err}

@{fix_relation_err}
...    NRCELL-2:dftBeamDiffThresholdH=15
...    NRCELL-2:dftBeamDiffThresholdV=15
...    NRCELL-4:dftBeamDiffThresholdH=15
...    NRCELL-4:dftBeamDiffThresholdV=15
...    MRBTS-2/NRBTS-2/NRDRB-15:maxTransferDelayGbr=20
...    MRBTS-2/NRBTS-2/NRDRB-15:maxRlcQueueingDelayGbr=20
...    NRCELL-2:increasePUSCHPrepTimeULCA=false
...    NRCELL-4:increasePUSCHPrepTimeULCA=false
...    MRBTS-2/NRBTS-2/NRCELL-2:srsForBeamMgmt:srsPowerThresholdForUlBm=-132
...    MRBTS-2/NRBTS-2/NRCELL-4:srsForBeamMgmt:srsPowerThresholdForUlBm=-132
...    NRCELL-2:increasePUSCHPrepTimeULCA=true
...    NRCELL-4:increasePUSCHPrepTimeULCA=true

${carrierAggregationSupportList}    SEPARATOR=
...    ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Any_Sa,ca_Fdd_Fdd,ca_Fr1Tdd_Any_Sa,
...    ca_Fdd_Fr1Tdd_Nsa,ca_Fdd_Fr1Tdd_Sa_WithUl,ca_Fr1Tdd_Nsa,ca_Fr1Tdd_Fdd_Nsa
@{CB006137}

...    NRBTS/NRDU-1:carrierAggregationSupportList=${carrierAggregationSupportList}
...    NRBTS/NRDU-1:dlToUlContributionRatio=100
...    NRBTS/NRDRB_RLC_AM-1:ulTReassemblyIBCA=40
...    NRBTS/NRDRB_RLC_AM-2:ulTReassemblyIBCA=40
...    NRCELL:maxNumScellsDlFr1=3
...    NRCELL:timingAdvanceOffset=n25600
@{gscn_Arfcn}
...    NRCELL-2:nrarfcn=518598
...    NRCELL-2:gscnOrSsPbchArfcn=6483
...    NRCELL-2:chBw=20MHz
...    NRCELL-2:msg1FrequencyStart=7
...    NRCELL-4:nrarfcn=636666
...    NRCELL-4:gscnOrSsPbchArfcn=7882
...    NRCELL-4:chBw=20MHz
...    NRCELL-4:msg1FrequencyStart=7
...    NRCELL-1/NRCELL_FDD-1:nrarfcnDl=126900
...    NRCELL-1/NRCELL_FDD-1:nrarfcnUl=136100
...    NRCELL-1/NRCELL_FDD-1:chBwDl=10MHz
...    NRCELL-1/NRCELL_FDD-1:chBwUl=10MHz
...    NRCELL-1:gscnOrSsPbchArfcn=1587
...    NRCELL-3/NRCELL_FDD-1:nrarfcnDl=128880
...    NRCELL-3/NRCELL_FDD-1:nrarfcnUl=138080
...    NRCELL-3/NRCELL_FDD-1:chBwDl=10MHz
...    NRCELL-3/NRCELL_FDD-1:chBwUl=10MHz
...    NRCELL-3:gscnOrSsPbchArfcn=1611
@{Others}
...    NRBTS:actMultiDrbNSA=true
...    NRBTS:actIncXn=true
...    NRBTS:actConflictConfiguration=true
...    NRBTS:rrcReestabTypeSA=sameGNB
...    NRBTS:tWaitingRlRecover=4000ms
...    NRCELL:pucchModeSelect=longPucch
...    NRBTS/NRSCTP-1:sctpProfile:sctpWaitTimeInitSeqRetry=10
...    NRCELL:actUl256Qam=false
...    NRCELL:actDl256Qam=false
@{CA}
...    NRBTS/NRDU-1:actConnectedModeMobilityCA=true
...    NRBTS/NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRCELL:weightForSCellSelection=50
...    NRCELL:actK1Opt=intra-gNB
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS:actMeasBasedSCellAdditionNsa=true
...    NRBTS:actHoOptimizationCa=true
...    NRBTS:sCellActivationMethod=bufferBased
...    NRBTS:actBcsCheck=disabled
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
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=50
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=60
...    NRCELL:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0
...    NRCELL:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=2560ms
...    NRCELL:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=34
@{NRREL}
...    NRCELL-1/NRREL-1:gNbId=2
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:lcrId=2
...    NRCELL-1/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-1:sCellOperationalMode=dlAndUl
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-1/NRHOIF-1:a1BasedPCellSwitchEnabled=true
...    NRCELL-1/NRHOIF-1:a2BasedPCellSwitchEnabled=true
...    NRCELL-1/NRHOIF-1:a2BasedPCellSwitchPriority=1
...    NRCELL-1/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-1/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-1/NRHOIF-1:freqBandIndicatorNR=41
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf5
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf20
...    NRCELL-1/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-1/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-1:ssbFrequency=518430
...    NRCELL-1/NRHOIF-1:thresholdPCellSwitchTargetRsrp=60
...    NRCELL-1/NRHOIF-1:thresholdPCellSwitchTargetRsrq=20
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms320
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=5
...    NRCELL-1/NRREL-2:gNbId=2
...    NRCELL-1/NRREL-2:gNbIdLength=22
...    NRCELL-1/NRREL-2:lcrId=4
...    NRCELL-1/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-2:sCellOperationalMode=dlAndUl
...    NRCELL-1/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-3:gNbId=2
...    NRCELL-1/NRREL-3:gNbIdLength=22
...    NRCELL-1/NRREL-3:lcrId=3
...    NRCELL-1/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-3:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-3/NRREL-1:gNbId=2
...    NRCELL-3/NRREL-1:gNbIdLength=22
...    NRCELL-3/NRREL-1:lcrId=2
...    NRCELL-3/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-3/NRREL-1:sCellOperationalMode=dlAndUl
...    NRCELL-3/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-3/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-3/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-3/NRREL-2:gNbId=2
...    NRCELL-3/NRREL-2:gNbIdLength=22
...    NRCELL-3/NRREL-2:lcrId=4
...    NRCELL-3/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-3/NRREL-2:sCellOperationalMode=dlAndUl
...    NRCELL-3/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-3/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-3/NRREL-2:gnbPlmn:mncLength=3
@{Mobillity}
...    NRBTS/NRPMRNL-1:miNrRelReportCu=5min
...    NRBTS/NRPMRNL-1:miNrMobilityReport=5min
...    NRBTS:actInterFreqHoSA=true
...    NRBTS:actInterFreqInterGnbMobilityNSA=true
...    NRBTS:actInterFreqIntraGnbMobilityNSA=true
...    NRBTS:actInterMeNBMobility=true
...    NRBTS:actIntraFreqHoSA=true
...    NRBTS:actIntraMeNBMobility=true
...    NRBTS:timerXnDataFwdGuard=250
...    NRBTS:cipherPrefL:nea0=9
...    NRBTS:cipherPrefL:nea2_128=0
...    NRBTS:cipherPrefL:nea1_128=0
...    NRBTS:cipherPrefL:nea3_128=0
...    NRCELL:a3MeasEnabled=rsrp
...    NRCELL:absThreshSsbRsrpConsolidation=1
...    NRCELL:sMeasConfigSsbRsrp=1
...    NRCELL:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms512
...    NRCELL:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL:a3MeasSsbRsrp:a3OffsetSsbRsrp=5
...    NRCELL:a1MeashoEnabled=rsrp
...    NRCELL:a2MeashoEnabled=rsrp
...    NRCELL:a1MeashoEnabledSA=rsrp
...    NRCELL:a2MeashoEnabledSA=rsrp
...    NRCELL:a1MeashoSsbRsrp:a1HysteresishoSsbRsrp=0
...    NRCELL:a1MeashoSsbRsrp:a1ThresholdhoSsbRsrp=65
...    NRCELL:a1MeashoSsbRsrp:a1TimeToTriggerhoSsbRsrp=ms480
...    NRCELL:a2MeashoSsbRsrp:a2HysteresishoSsbRsrp=0
...    NRCELL:a2MeashoSsbRsrp:a2ThresholdhoSsbRsrp=34
...    NRCELL:measGapSelectionSA=favourUeThroughput
...    NRCELL:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRCELL:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=65
...    NRCELL:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0
...    NRCELL:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=34
...    NRCELL:a1MeashoSsbRsrpSA:a1TimeToTriggerHoSsbRsrpVoNr=${EMPTY}
...    NRCELL:a1MeashoSsbRsrpSA:a1ThresholdHoSsbRsrpVoNr=${EMPTY}
...    NRCELL:a1MeashoSsbRsrpSA:a1HysteresisHoSsbRsrpVoNr=${EMPTY}
...    NRCELL:a2MeashoSsbRsrpSA:a2HysteresisHoSsbRsrpVoNr=${EMPTY}
...    NRCELL:a2MeashoSsbRsrpSA:a2ThresholdHoSsbRsrpVoNr=${EMPTY}
...    NRCELL:a2MeashoSsbRsrpSA:a2TimeToTriggerHoSsbRsrpVoNr=${EMPTY}
...    XNLINK-1:cPlaneIpAddr=10.0.1.122
...    NRADJGNB-10:administrativeState=Unlocked
...    NRADJGNB-10:gNbIdLength=22
...    NRADJGNB-10:gNodeBId=36
...    NRADJGNB-10:xnLinkRef=1
...    NRADJGNB-10:gnbPlmn:mcc=311|mncLength=3
...    NRADJGNB-10:gnbPlmn:mnc=489|mncLength=3
...    NRADJNRCELL-1:cellDepType=SA+NSA
...    NRADJNRCELL-1:fiveGsTac=788
...    NRADJNRCELL-1:gNbId=36
...    NRADJNRCELL-1:gNbIdLength=22
...    NRADJNRCELL-1:lcrId=1
...    NRADJNRCELL-1:nrarfcn=126990
...    NRADJNRCELL-1:physCellId=48
...    NRADJNRCELL-1:gnbPlmn:mcc=311|mncLength=3
...    NRADJNRCELL-1:gnbPlmn:mnc=489|mncLength=3
...    NRCELL/NRREL-5:cellIndividualSsbRsrpOffset=0dB
...    NRCELL/NRREL-5:cellIndividualSsbRsrqOffset=0dB
...    NRCELL/NRREL-5:gNbId=36
...    NRCELL/NRREL-5:gNbIdLength=22
...    NRCELL/NRREL-5:lcrId=1
...    NRCELL/NRREL-5:removeNotAllowed=false
...    NRCELL/NRREL-5:gnbPlmn:mcc=311|mncLength=3
...    NRCELL/NRREL-5:gnbPlmn:mnc=489|mncLength=3
...    delete:NRCELL/NRREL-5:sCellAdditionMethod
@{VONR}
...    NRCELL:actVoNR=true
...    NRCELL:actEnhancedVoNR=true
...    NRBTS/NRDRB-15:discardTimer=100ms
...    NRBTS/NRDRB-15:dlFlowControlAlgo=none
...    NRBTS/NRDRB-15:maxDataRateGbrDl=1000
...    NRBTS/NRDRB-15:maxDataRateGbrUl=1000
...    NRBTS/NRDRB-15:nrDrbMacDN=MRBTS-2/NRBTS-2/NRDRB_MAC-4
...    NRBTS/NRDRB-15:nrDrbPdcpDN=MRBTS-2/NRBTS-2/NRDRB_PDCP-3
...    NRBTS/NRDRB-15:nrDrbRlcUmDN=MRBTS-2/NRBTS-2/NRDRB_RLC_UM-1
...    NRBTS/NRDRB-15:queuingDelayDiscarding=Disabled
...    NRBTS/NRDRB-15:resType=GBR
...    NRBTS/NRDRB-15:rlcMode=RLC_UM
...    NRBTS/NRDRB-15:schedulWeight=${EMPTY}
...    NRBTS/NRDRB-15:nrDrbRlcAmDN=${EMPTY}
...    NRBTS/NRDRB_5QI-6:fiveqiValueList=1
...    NRBTS/NRDRB_5QI-6:nrDrbDN=MRBTS-2/NRBTS-2/NRDRB-15
...    NRBTS/NRDRB_MAC-4:lcgid=4
...    NRBTS/NRDRB_PDCP-3:maxCidAllowed=${EMPTY}
...    NRBTS/NRDRB_PDCP-3:xxFlowControlProfForCuIdx=${EMPTY}
...    NRBTS/NRDRB_RLC_UM-1:dlTReassemblyUm=ms50
...    NRBTS/NRDRB_RLC_UM-1:rlcUMDrbSNLength=rlcUm12bitSN
...    NRBTS/NRDRB_RLC_UM-1:ulTReassemblyUm=ms50
@{CDRX}
...    NRCELL-1:actCDrx=false
...    NRCELL-1:actCDrxVoNR=false
...    NRCELL-1:drxProfile1:drxInactivityTimer=80ms|drxRetransTimerUl=0slot
...    NRCELL-1:drxProfile1:drxLongCycle=160ms|drxRetransTimerUl=0slot
...    NRCELL-1:drxProfile1:drxOnDurationTimer=10ms|drxRetransTimerUl=0slot
...    NRCELL-1:drxProfile1:drxRetransTimerDl=0slot|drxRetransTimerUl=0slot
...    NRCELL-1:drxProfile2:drxInactivityTimer=4ms|drxRetransTimerUl=0slot
...    NRCELL-1:drxProfile2:drxLongCycle=40ms|drxRetransTimerUl=0slot
...    NRCELL-1:drxProfile2:drxOnDurationTimer=6ms|drxRetransTimerUl=0slot
...    NRCELL-1:drxProfile2:drxRetransTimerDl=0slot|drxRetransTimerUl=0slot
@{srsConfig}
...    NRCELL-2:actUlSrsBm=true
...    NRCELL-2:actDlSrsBm=true
...    NRCELL-4:actUlSrsBm=true
...    NRCELL-4:actDlSrsBm=true
...    NRCELL-2:srsForBeamMgmt:srsUePeriodicity=slots40
...    NRCELL-2:srsForBeamMgmt:cSRS=13
...    NRCELL-2:srsForBeamMgmt:bSRS=0
...    NRCELL-4:srsForBeamMgmt:srsUePeriodicity=slots40
...    NRCELL-4:srsForBeamMgmt:cSRS=13
...    NRCELL-4:srsForBeamMgmt:bSRS=0
...    NRCELL-2:srsForBeamMgmt:srsPowerThresholdForDlBm=-1200
...    NRCELL-4:srsForBeamMgmt:srsPowerThresholdForDlBm=-1200
...    NRCELL-2:srsForBeamMgmt:srsTypeAllocForDlBm=antenna switching or codebook
...    NRCELL-4:srsForBeamMgmt:srsTypeAllocForDlBm=antenna switching or codebook
...    NRCELL-2:ulPowerControlCommon:alphaSrs=alpha08
...    NRCELL-2:ulPowerControlCommon:p0NominalSrs=-106
...    NRCELL-4:ulPowerControlCommon:alphaSrs=alpha08
...    NRCELL-4:ulPowerControlCommon:p0NominalSrs=-106
@{Beamforming}
...    NRBTS:actChannelMapVal=ShowAsWarning
...    NRBTS:actFdmEnhancedScheduling=true
...    NRCELL-2:beamSet:nrBtsBeamRefinementP2=false
...    NRCELL-4:beamSet:nrBtsBeamRefinementP2=false
...    NRCELLGRP-1:numberOfTransmittedSsBlocks=4 beams
...    NRCELLGRP-3:numberOfTransmittedSsBlocks=4 beams
...    NRCELL-2:beamSet:basicBeamSet=beamSet_4
...    NRCELL-4:beamSet:basicBeamSet=beamSet_4
...    NRCELL-2:numberOfRxBeamforming=4Rx
...    NRCELL-4:numberOfRxBeamforming=4Rx
...    NRCELL-2:actBeamforming=true
...    NRCELL-4:actBeamforming=true
...    NRCELL-2:mMimoAntArrayMode=Full 64TRX Array (4x8x2)
...    NRCELL-4:mMimoAntArrayMode=Full 64TRX Array (4x8x2)
...    NRCELL-2:dlMimoMode=4x4 or 4x2 Closed Loop Spatial Multiplexing
...    NRCELL-4:dlMimoMode=4x4 or 4x2 Closed Loop Spatial Multiplexing
...    NRCELL-2:nrCellType=8DL4UL
...    NRCELL-4:nrCellType=8DL4UL
...    NRCELL-2:beamSet:lowerEdgeAngle=120
...    NRCELL-2:beamSet:upperEdgeAngle=60
...    NRCELL-4:beamSet:lowerEdgeAngle=120
...    NRCELL-4:beamSet:upperEdgeAngle=60
...    delete:MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-3
...    delete:MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-4
...    delete:MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-3
...    delete:MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-4
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-2
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-2
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-2/CHANNEL-1:direction=TX
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-2/CHANNEL-1:resourceDN=MRBTS-2/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-2/CHANNEL-2:direction=TX
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-2/CHANNEL-2:resourceDN=MRBTS-2/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-2/CHANNEL-3:direction=TX
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-2/CHANNEL-3:resourceDN=MRBTS-2/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-2/CHANNEL-4:direction=TX
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-2/CHANNEL-4:resourceDN=MRBTS-2/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-10:direction=TX
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-10:resourceDN=MRBTS-2/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-11:direction=RX
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-11:resourceDN=MRBTS-2/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-12:direction=RX
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-12:resourceDN=MRBTS-2/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-2/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-2/CHANNEL-1:direction=TX
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-2/CHANNEL-1:resourceDN=MRBTS-2/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-2/CHANNEL-2:direction=TX
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-2/CHANNEL-2:resourceDN=MRBTS-2/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-2/CHANNEL-3:direction=TX
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-2/CHANNEL-3:resourceDN=MRBTS-2/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-2/CHANNEL-4:direction=TX
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-2/CHANNEL-4:resourceDN=MRBTS-2/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-10:direction=TX
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-10:resourceDN=MRBTS-2/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-11:direction=RX
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-11:resourceDN=MRBTS-2/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-12:direction=RX
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-12:resourceDN=MRBTS-2/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-2/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-3:direction=RX
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-3:resourceDN=MRBTS-2/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-4:direction=RX
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-4:resourceDN=MRBTS-2/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-3:direction=RX
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-3:resourceDN=MRBTS-2/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-4:direction=RX
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-4:resourceDN=MRBTS-2/EQM-1/APEQM-1/RMOD-1/PHYANT-1

@{FrameStructure}
...    NRCELL-2:tddFrameStructure:frameStructureType=tdLte
...    NRCELL-2:tddFrameStructure:lteToNrFrameShift=0ms
...    NRCELL-2:tddFrameStructure:tdLteUlDlConfig=tdLteConfig2
...    NRCELL-2:tddFrameStructure:ulDlDataSlotRatio=1/4
...    NRCELL-2:tddFrameStructure:guardPeriodLength=6Symbols
...    NRCELL-4:tddFrameStructure:frameStructureType=semiStatic
...    NRCELL-4:tddFrameStructure:ulDlDataSlotRatio=1/4
...    NRCELL-4:tddFrameStructure:guardPeriodLength=2Symbols
...    NRCELL-4:tddFrameStructure:lteToNrFrameShift=${EMPTY}
...    NRCELL-4:tddFrameStructure:tdLteUlDlConfig=${EMPTY}
...    NRCELL-4:prachConfigurationIndex=98
@{Overheating}
...    NRBTS:actOverheatingAssistance=true
...    NRBTS:timerPostOverheating=0
...    NRBTS:timerOverheatIndProhibit=1s
${ue_nr_capabilities_04}    SEPARATOR=
...    E1A2538057E0220082000F7A03560003C3A800B010880002000600409063D011EC00F04C990E7C8B5E82AF6097A067D813E078F11C7840040
...    6024C5C00670F42400C4834026010188E01F51B0A303582308682041D20D80516CAA2A121CFA067D813E31CF9863CA1607038780210000030
...    80A090500B8002F800E000BE000B10C06CA0000A0000001480180AA3E236B04610D04083C41B0092D954541439F40CF8C73E618F28581C0E1
...    E00420000061014120A027F0000001FC0000001601802900301546C4DD608C21A0810748360145B2A8A84873E819F604F8C73E618F28581C0
...    E1E008400000C2028241402E000B60038002D8002C03005200602A8F883AC1184341020F106C024B65515050E7D033E31CF9863CA16070387
...    801080000184050482809FD0000007F4000000584600C100A400C000A83C4D000E230000073907005011A014404D154001E01850276CB5E38
...    0A0233D05A807C006000E0000020280301804A00C000C07C06004000000020000040100000400800400000010008020080200100002004000
...    01807CA9AC0CBCA5AC08A0182000000360208000080D8002000040000008000180000007A55574AA2A81455038A1680EC035038140A070281
...    C000D084200134018800000402000001008000004020000010002440200400808020000200800080400801010060000401000000804002101
...    00200404028000808060020200800080C008028010040601C01C010040300400201C000804008020100600004010040808010040200802040
...    403002010040102020080200802000058B80A0300A5101003318
#CA_n71a*_n78a*,supportedSRS-TxPortSwitch t1r2 for n78a
${ue_nr_capabilities_05}    SEPARATOR=
...    E1A2538057E0220082000F7A03560003C3A800B010880002000600409063D011EC00F04C990E7C8B5E82AF6097A067D813E078F11C7840040
...    6024C5C00670F42400C4834026010188E01F51B0A303582308682041D20D80516CAA2A121CFA067D813E31CF9863CA1607038780210000030
...    80A090500B8002F800E000BE000B10C06CA0000A0000001480180AA3E236B04610D04083C41B0092D954541439F40CF8C73E618F28581C0E1
...    E00420000061014120A027F0000001FC0000001601802900301546C4DD608C21A0810748360145B2A8A84873E819F604F8C73E618F28581C0
...    E1E008400000C2028241402E000B60038002D8002C03005200602A8F883AC1184341020F106C024B65515050E7D033E31CF9863CA16070387
...    801080000184050482809FD0000007F4000000584600C100A400C000A83C4D000E230200073907005011A014404D154001E01850276CB5E38
...    0A0233D05A807C006000E0000020280301804A00C000C07C06004000000020000040100000400800400000010008020080200100002004000
...    01807CA9AC0CBCA5AC08A0182000000360208000080D8002000040000008000180000007A55574AA2A81455038A1680EC035038140A070281
...    C000D084200134018800000402000001008000004020000010002440200400808020000200800080400801010060000401000000804002101
...    00200404028000808060020200800080C008028010040601C01C010040300400201C000804008020100600004010040808010040201402040
...    403002010040102020080200802000058B80A0300A5101003318
#CA_n71b*_n78a*,supportedSRS-TxPortSwitch t1r2 for n78a
${ue_nr_capabilities_06}    SEPARATOR=
...    E1A2538057E0220082000F7A03560003C3A800B010880002000600409063D011EC00F04C990E7C8B5E82AF6097A067D813E078F11C7840040
...    6024C5C00670F42400C4834026010188E01F51B0A303582308682041D20D80516CAA2A121CFA067D813E31CF9863CA1607038780210000030
...    80A090500B8002F800E000BE000B10C06CA0000A0000001480180AA3E236B04610D04083C41B0092D954541439F40CF8C73E618F28581C0E1
...    E00420000061014120A027F0000001FC0000001601802900301546C4DD608C21A0810748360145B2A8A84873E819F604F8C73E618F28581C0
...    E1E008400000C2028241402E000B60038002D8002C03005200602A8F883AC1184341020F106C024B65515050E7D033E31CF9863CA16070387
...    801080000184050482809FD0000007F4000000584600C100A400C000A85C4D000E2302060A0000E720E00A0234028809A2A80044031204E36
...    5AF1C00140467A0B500F800C001C0000040500603009401800180F80C00800000004000008020000080100080000002001004010040020000
...    40080000300F9535819794B5811403040000006C0410000101B000400008000001000030000000F4AAAE95455028AA07142D01D806A070281
...    40E05038001A1084002680310000008040000020100000080400000200048804008010100400004010001008010020200C000080200000100
...    8004202004008080500010100C00404010001018010050020080C0380380200806008004038001008010040200C0000802008201002008040
...    2804010020002020180100802008101004010040100002C5C0501805288080198C
#CA_n71b*_n78a*_n41a
@{PM_Counters_Check_Case6}
...    NRCELL-1:${NUM_UE_OVH_REPORTS}=6
...    NRCELL-1:${NUM_REQ_0_SCELL_ALLOW_OVH}=2
...    NRCELL-1:${NUM_REQ_1_SCELL_ALLOW_OVH}=1
...    NRCELL-1:${NUM_REQ_2_SCELL_ALLOW_OVH}=1
...    NRCELL-1:${NUM_REQ_3_SCELL_ALLOW_OVH}=1
${NUM_UE_OVH_REPORTS}    M55118C07501
${NUM_REQ_0_SCELL_ALLOW_OVH}    M55118C07503
${NUM_REQ_1_SCELL_ALLOW_OVH}    M55118C07504
${NUM_REQ_2_SCELL_ALLOW_OVH}    M55118C07505
${NUM_REQ_3_SCELL_ALLOW_OVH}    M55118C07506
${Not_limited}    7

*** Test Cases ***
#CB006137-BB_ET_04_02_Periodic SRS resources configure to TDD Scell for ULCA when Scell with frame structure 5GC001280 when Scell addition
#    [Documentation]
#    ...    This case is to verify:
#    ...    in case TDD Scell having frame structure 5GC001208,
#    ...    SRS symbol on special slot 8 & slot 18 of each frame cannot be allocated to all the Scell UE when Scell Addition.
#    ...    refer to 5G_CP_ARC_ALG_7527.
#    [Tags]
#    Cell Lock and Unlock
#    SA UE Register and PDU Session Setup and Scell Addition    ue_id=1    ue_nr_capabilities=${ue_nr_capabilities_04}
#    ...    sCellIndex=1
#    Check RRC Log    ${CURDIR}${/}a2a_CB006137-BB_ET_04${/}a2a.ini
#    Check WireShark Log    ${CURDIR}${/}a2a_CB006137-BB_ET_04${/}a2a.ini    wait_string=UEContextModificationResponse::10
#    [Teardown]    Test Case Teardown

#CB006137-BB_ET_05_01_Periodic SRS resources configure to TDD Scell for ULCA when Scell with frame structure 5GC001280 when Scell change
#    [Documentation]
#    ...    This case is to verify:
#    ...    in case TDD Scell having frame structure 5GC001208,
#    ...    SRS symbol on special slot 8 & slot 18 of each frame cannot be allocated to all the Scell UE when Scell Change.
#    ...    refer to 5G_CP_ARC_ALG_7527.
#    [Tags]
#    Cell Lock and Unlock
#    SA UE Register and PDU Session Setup and Scell Addition    ue_id=1    ue_nr_capabilities=${ue_nr_capabilities_05}
#    ...    srsrp=55    sCellIndex=1
#    Pcell A1 report to trigger Scell Change
#    Check RRC Log    ${CURDIR}${/}a2a_CB006137-BB_ET_05${/}a2a.ini
#    Check WireShark Log    ${CURDIR}${/}a2a_CB006137-BB_ET_05${/}a2a.ini    wait_string=UEContextModificationResponse::16
#    [Teardown]    Test Case Teardown

CB006137-BB_ET_06_01_Overheating handling interworking with UL CA
    [Documentation]
    ...    This case is to verify:
    ...    3GPP based overheating handling interworking with UL CA.
    ...    refer to 5G_CP_ARC_ALG_6852.
    [Tags]    QC_xxxxx    221593
    Clear Counter files
    SA UE Register and PDU Session Setup and Scell Addition    ue_id=1    ue_nr_capabilities=${ue_nr_capabilities_06}
    ...    sCellIndex=3
    Start Traffic
    UE Assistance Information for Overheating
    Release UEs    ue_type=sa    ue_id=1
    Check WireShark Log    ${CURDIR}${/}a2a_CB006137-BB_ET_06${/}a2a.ini    wait_string=itf_l2_ps_user_UserChangeInd_t::6
    Check Counters    ${PM_Counters_Check_Case6}
    [Teardown]    Test Case Teardown

*** Keywords ***
Common Suite Setup And Setup IPHY Env
    Common Suite Setup
    Setup Airphone Env    tl_type=${GNB_CONFIG}

Modify Cfg
    Update Cfg    mme_pool_area id=1 mmegi=1 plmn=311:489 eq_plmn=250:255 tac_list=777,111,222,444,333,200
    Update Cfg    enb_endc_param id=1 control_flow_period=3gpp1 use_nr_ran_cont=on serving_cell_index_range_scg=8:14
    ${Update_Cfg_1}    catenate
    ...    set_cell id=2 enb=1 eci=0x1234602 pci=3:1 tac=222 proxy=10.0.2.1:12220|10.0.2.1:8890
    ...    earfcn=2000:20000 mandatory_for_activation=off
    Update Cfg    ${Update_Cfg_1}
    ${Update_Cfg_2}    catenate
    ...    set_enb id=11 plmn=250:255 s1=10.0.1.138 enb_id_macro=0x12347 daemon=10.0.2.1:22222 x2=10.0.1.127
    ...    x2u=10.0.1.137 type=simulated x2_peers=none
    Update Cfg    ${Update_Cfg_2}
    Update Cfg    enb_param id=1 drb_id_begin=3 endc_capable_qci=all
    Update Cfg    enb_param id=11 drb_id_begin=3 endc_capable_qci=all
    Update Cfg    enb_endc_param id=11 control_flow_period=3gpp1 use_nr_ran_cont=on serving_cell_index_range_scg=8:14
    ${Update_Cfg_3}    catenate
    ...    set_cell id=1 enb=11 eci=0x1234701 pci=7:2 tac=222 proxy=10.0.2.1:8887 earfcn=2000:20000
    ...    mandatory_for_activation=off
    Update Cfg    ${Update_Cfg_3}
    ${Update_Cfg_4}    catenate
    ...    set_gnb id=3 type=simulated plmn=311:489 s1u=10.0.1.126 ng=10.0.1.127 gnb_id=0x24:22 daemon=10.0.2.1:22222
    ...    x2=10.0.1.128:36422 x2_peers=none xn=10.0.1.122 nssai=0x1:0xd143a5 amf=1
    Update Cfg    ${Update_Cfg_4}
    Update Cfg    set_cell id=1 gnb=3 pci=16:0 tac=788 nrci=0x01 tdd_cell=off proxy=10.0.2.92:9999 nr_arfcn=136100:126900 gscn=1587
    Update Cfg    gnb_param id=3 xn_listening_socket=1 send_xn_setup=true
    Update Cfg    gnb_endc_param id=3 use_nr_ran_cont=true scg_dl_dist_percent=0 enable_dud_poll_bit=0
    Update Cfg    gnb_param id=3 x2_listening_socket=1 measEvent=A3
    Update Cfg    set_qosflow id=1 5qi=6 default=on
    Update Cfg    set_qosflow id=3 5qi=1
    Update Cfg    set_qosflow id=2 5qi=5
    Update Cfg    set_qosrule id=1 proto=tcp qos_flow=2
    Update Cfg    set_qosrule id=2 proto=udp qos_flow=3
    Update Cfg    set_nwslice id=1 qos_flows=3,2,1 qos_rules=1,2 snssai=0x01:0xD143A5 default=on ue=1-30 amf=1
    Update Cfg    ue_nr_capabilities id=1-30 voice_over_nr=on:on:off
    Update Cfg    amf_param id=1 full_nas_auth=on ims_voice_3gpp=on nia=null+zuc nea=null+zuc
    ${Update_Cfg_7}    catenate    SEPARATOR=
    ...    ue_param id=1-30 nr_usage_setting=voice_centric ue_nr_capabilities=F9A0700047D0FFA17DF8E6BC32001A0349CF9A44F3
    ...    E0048018807C07C0203F1C03EF3E26807BDEB70D0645020E0000075C160145B25AA05813E439F40478C73E618F28581C0E1E0A4FF93FE
    ...    284003650000500000379C10403DEF5B8683228107000003AE0B00A2D92D502C09F21CFA023C639F30C7942C0E070F066F3823007BDEB
    ...    70D0645020E0000075C160145B25AA05813E439F40478C73E618F28581C0E1E0CDE702800F7BD6E1A0C8A041C00000EB82C028B64B540
    ...    B027C873E808F18E7CC31E50B0381C3C182541E1400061340000120561C1401C4D000002120541E2300060A00004120541C2301C28000
    ...    006120400E1400000450788C00184D0002848158708C0713400003048150788C001C4D00000E130150788C001C28000010130100500A2
    ...    026C04111403282614E9DB1CF870A74ED8E7C3853A76C73E1C29D3B639F0E04ED8E7C3853A76C73E1C29D3B639F0E14E9DB1CF8708363
    ...    9F0C07848C63180C6318FE0000004C00F800AC70500703F09001C0C0018003E021CB400001C01CB400005C01CB400009C01CB40000DC0
    ...    1CB400011C0008CA0BCA8AC0CACA4AC0CA018300000030000C0000A0C000300004030000C000180C00006E5105F2A82B81C15CA60A120
    ...    11004F0783C1E0F0000404040080101004000202004000080200410100600C04008000808030000200400800402004080805006020080
    ...    00404028000100400820A01401C018038050060A00400C0200480200410100A00C04008011A80700020406071B252724F0280C02900
    Update Cfg    ${Update_Cfg_7}
    FOR    ${SA_id}    IN RANGE    1    31
        Update Cfg    set_pdu_gateway id=${SA_id} ue_nat_ip=72.23.0.${SA_id} dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    END
    FOR    ${NSA_id}    IN RANGE    31    61
        Update Cfg    set_bearer id=3 ue=${NSA_id} qci=8 pdn=1 default=off
    END
    ${Update_Cfg_8}    catenate
    ...    set_gnb id=2 type=external plmn=311:489 s1u=10.0.1.112 x2=10.0.1.2:36422 ng=10.0.1.2 xn=10.0.1.2:38422
    ...    gnb_id=0x2:22 daemon=10.0.2.1:22222 x2_peers=none amf=1 plmnList=311:489 nssai=0x1:0xd143a5
    Update Cfg    ${Update_Cfg_8}
	Update Cfg    cell_srs_beam_pos_nr profile_id=1 num_of_ue_positions=4 azimuth=-45,30,25,60
    Update Cfg    cell_testmode_set_nr cell_id=2 gnb=2 testmode=cell_srs_beam_pos profile_id=1 action=activate
    Update Cfg    cell_testmode_set_nr cell_id=4 gnb=2 testmode=cell_srs_beam_pos profile_id=1 action=activate	


Set UE Parameters Before Attach
    [Arguments]    ${ue_id}=1    ${target_cell}=1
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${target_cell}
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal

SA UE Register To GNB
    [Arguments]    ${ue_id}=1    ${ue_nr_capabilities}=${ue_nr_capabilities_01}
    Execute Egate Command    ue_register id=${ue_id} ue_nr_capabilities=${ue_nr_capabilities}
    ...    Received REGISTRATION COMPLETE from UE

SA UE PDU Session Setup
    [Arguments]    ${pdu}=1    ${fiveQi}=6    ${ue_id}=1
    Start RRC Log    PDU_Session_Setup_${ue_id}
    ${ret1}=    Execute Egate Command    ue_pdu_session_setup pdu=${pdu} ue=${ue_id} nwslice=1 gw=${ue_id}
    ...    pass_regexp=QoS Routing Table
    Should Contain    ${ret1}    Created FiveQi:Qfi mapping fiveQi ${fiveQi} qfi 1
    Get RRC Log

SA UE Register and PDU Session Setup
    [Arguments]    ${ue_id}=1    ${ue_nr_capabilities}=${ue_nr_capabilities_01}
    SA UE Register To GNB    ue_id=${ue_id}    ue_nr_capabilities=${ue_nr_capabilities}
    SA UE PDU Session Setup    ue_id=${ue_id}

SA UE Register and PDU Session Setup and Scell Addition
    [Arguments]    ${ue_id}=1    ${ue_nr_capabilities}=${ue_nr_capabilities_01}    ${target_cell}=1    ${sCellIndex}=1    ${srsrp}=80
    Set UE Parameters Before Attach    ue_id=${ue_id}    target_cell=${target_cell}
    SA UE Register and PDU Session Setup    ue_id=${ue_id}    ue_nr_capabilities=${ue_nr_capabilities}
    Pcell A1 report to trigger Scell Addition    ue_id=${ue_id}    sCellIndex=${sCellIndex}    srsrp=${srsrp}

Pcell A1 report to trigger Scell Addition
    [Arguments]    ${ue_id}=1    ${carrierfreq}=126990    ${phycell_id}=60    ${sCellIndex}=1    ${srsrp}=80
    Start RRC Log     Scell_Addition_UE_${ue_id}
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A1
    ${A1_Scell_addition}    catenate
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} phycell_id=${phycell_id} event=A1
    ...    srsrp_nr=${srsrp} srsrq_nr=40
    ${ret1}=    Execute Egate Command    ${A1_Scell_addition}    scellIdx:${sCellIndex}
    Should Contain    ${ret1}    eventId eventA2
    Should Contain    ${ret1}    a2-Threshold rsrp : 34
    Should Contain    ${ret1}    sCellToAddModList
    Get RRC Log

Pcell A1 report to trigger Scell Change
    [Arguments]    ${ue_id}=1    ${carrierfreq}=126990    ${phycell_id}=60    ${sCellIndex}=2    ${srsrp}=80
    Start RRC Log     Scell_Change_UE_${ue_id}
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A1
    ${A1_Scell_addition}    catenate
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} phycell_id=${phycell_id} event=A1
    ...    srsrp_nr=${srsrp} srsrq_nr=40
    ${ret1}=    Execute Egate Command    ${A1_Scell_addition}    scellIdx:${sCellIndex}
    Should Contain    ${ret1}    sCellToReleaseList
    Should Contain    ${ret1}    sCellToAddModList
    Get RRC Log

Test Case Teardown
    Release UEs    ue_type=all
    Common Test Teardown And Stop Capture Logs

Start DL Traffic
    [Arguments]    ${ue_id}=1    ${qfi}=1    ${mbps}=175
    ${traffic_log1}=    Execute Egate Command
    ...    data_trf_start ue=${ue_id} pdu=1 qfi=${qfi} dir=dl mbps=${mbps} trf_id=1    fail_regexp=SCellIndex 3    timeout=10
    ${traffic_log2}=    Execute Egate Command
    ...    data_trf_start ue=${ue_id} pdu=1 qfi=${qfi} dir=dl mbps=${mbps} trf_id=2    fail_regexp=SCellIndex 3    timeout=10
    ${traffic_log}    catenate    ${traffic_log1}    ${traffic_log2}
    should contain    ${traffic_log}    SCellIndex 1 activated successfully
    should contain    ${traffic_log}    SCellIndex 2 activated successfully

Start UL Traffic
    [Arguments]    ${ue_id}=1    ${qfi}=1    ${mbps}=40
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=${qfi} dir=ul mbps=${mbps}    SCellIndex 3 activated successfully at airphone

Start Traffic
    [Arguments]    ${ue_id}=1
    Start UL Traffic    ${ue_id}
    Start DL Traffic    ${ue_id}


UE Assistance Information for Overheating
    [Arguments]    ${ue_id}=1
    Execute Egate Command
    ...    ue_assistance_send_nr ue_id=${ue_id} forOverheating=yes reducedCCsUL=0 reducedCCsDL=0    (deactivated successfully.*\n*.*){3}
    Execute Egate Command
    ...    ue_assistance_send_nr ue_id=${ue_id} forOverheating=yes reducedCCsUL=0 reducedCCsDL=1    activated successfully at airphone
    Execute Egate Command
    ...    ue_assistance_send_nr ue_id=${ue_id} forOverheating=yes reducedCCsUL=1 reducedCCsDL=2    activated successfully at airphone
    Execute Egate Command
    ...    ue_assistance_send_nr ue_id=${ue_id} forOverheating=yes reducedCCsUL=1 reducedCCsDL=3    activated successfully at airphone
    Execute Egate Command
    ...    ue_assistance_send_nr ue_id=${ue_id} forOverheating=yes reducedMIMO_LayersFR1_DL=2    (deactivated successfully.*\n*.*){3}
    Execute Egate Command    ue_assistance_send_nr ue_id=${ue_id} forOverheating=yes    (activated successfully.*\n*.*){3}

Cell Lock and Unlock
    Lock Cell1
    Unlock Cell1
    Cells Should Be Onair    1
