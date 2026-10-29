*** Settings ***
Documentation
...    author:  baijie.zhu@nokia-sbell.com
...    contact: baijie.zhu@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_VRF    RAN_5G_TDD    SBTS00    team-Blues_SGT&A    owner-zora.wang
...    CLOUD_5G_I_BOO_AP_LOO    CRT    CB008290    release-5G23R1
...    STATE_CONFIGURED    RAN_5G
Resource    ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    NRBTS-1:cipherPrefL:nea0=8
...    NRBTS-1:cipherPrefL:nea1_128=0
...    NRBTS-1:cipherPrefL:nea2_128=0
...    NRBTS-1:cipherPrefL:nea3_128=0
...    NRBTS-1:integrityProtPrefL:nia0=0
...    NRBTS-1:integrityProtPrefL:nia1_128=0
...    NRBTS-1:integrityProtPrefL:nia2_128=0
...    NRBTS-1:integrityProtPrefL:nia3_128=9
...    NRBTS-1:actFdmEnhancedScheduling=true
...    @{PARAMS_FOR_IODT_ABIO_2T4F}
...    @{same frequency}
...    @{NRREL}
...    @{8290_enable}
...    @{HO_related}
...    @{A2pcellchange}
...    @{BOO_AP_LOO}

@{BOO_AP_LOO}
...    BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=1
...    BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=1
...    BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=9|searchSpaceId=1
...    BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=1
...    BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=1
...    BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=1
...    BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=1
...    BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=1
...    BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|searchSpaceId=1
...    BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=1
...    BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=4|searchSpaceId=1
...    BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=2
...    BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=2
...    BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=2
...    BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=2
...    BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=2
...    BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n4|searchSpaceId=2
...    BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=2
...    BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=2
...    BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=2
...    BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=2
...    BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=2
...    BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=3
...    BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=3
...    BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=2|searchSpaceId=3
...    BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=3
...    BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=3
...    BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=3
...    BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=3
...    BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=3
...    BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceId=3
...    BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=3
...    BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=3

...    BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=4
...    BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=4
...    BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=9|searchSpaceId=4
...    BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=4
...    BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=4
...    BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=4
...    BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=4
...    BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=4
...    BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|searchSpaceId=4
...    BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=4
...    BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=4|searchSpaceId=4
...    BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=5
...    BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=5
...    BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=5
...    BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=5
...    BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=5
...    BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n4|searchSpaceId=5
...    BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=5
...    BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=5
...    BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=5
...    BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=5
...    BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=5
...    BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=6
...    BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=6
...    BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=2|searchSpaceId=6
...    BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=6
...    BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=6
...    BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=6
...    BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=6
...    BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=6
...    BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceId=6
...    BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=6
...    BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=6

@{HO_related}
...    NRBTS-1:actInterRatHoSA=true
...    NRBTS-1:actInterFreqHoSA=true
...    NRBTS-1:actIntraFreqHoSA=true
...    NRBTS-1/NRPMRNL-1:miNrRelReportCu=5min
...    NRCELL:absThreshSsbRsrpConsolidation=0
...    NRCELL:sMeasConfigSsbRsrp=10
...    NRCELL:a3MeasEnabled=rsrp
...    NRCELL:a3MeasSsbRsrp:a3HysteresisSsbRsrp=2|a3OffsetSsbRsrp=10|a3TimeToTriggerSsbRsrp=ms0
...    NRCELL:a5MeasEnabled=rsrp
...    NRCELL:a5MeasSsbRsrp:a5HysteresisSsbRsrp=0|a5Threshold1SsbRsrp=52|a5Threshold2SsbRsrp=54|a5TimeToTriggerSsbRsrp=ms100
...    NRCELL:a1MeashoEnabledSA=rsrp
...    NRCELL:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0|a1ThresholdhoSsbRsrpSA=30|a1TimeToTriggerhoSsbRsrpSA=ms100
...    NRCELL:a2MeashoEnabledSA=rsrp
...    NRCELL:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=2|a2ThresholdhoSsbRsrpSA=5|a2TimeToTriggerhoSsbRsrpSA=ms128

@{A2pcellchange}
...    NRCELL:a2MeasPCellSwitchEnabled=none
...    NRCELL:a2MeasPCellSwitchSsbRsrp:a2HysteresisPCellSwitchSsbRsrp=0
...    NRCELL:a2MeasPCellSwitchSsbRsrp:a2ThresholdPCellSwitchSsbRsrp=111
...    NRCELL:a2MeasPCellSwitchSsbRsrp:a2TimeToTriggerPCellSwitchSsbRsrp=0ms
...    NRCELL:a2MeasPCellSwitchSsbRsrp:pCellSwitchOffsetSsbRsrp=1
...    NRBTS-1:actMeasBasedSCellAdditionNsa=true
...    NRCELL-1/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-1/NRHOIF-1:a2BasedPCellSwitchPriority=1
...    NRCELL-1/NRHOIF-1:thresholdPCellSwitchTargetRsrp=122
...    NRCELL-1/NRHOIF-1:thresholdPCellSwitchTargetRsrq=2
...    NRCELL-1/NRHOIF-1:a2BasedPCellSwitchEnabled=true
...    NRCELL-1/NRHOIF-1:freqBandIndicatorNR=71
...    NRCELL-1/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf5
...    NRCELL-1/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-1/NRHOIF-1:scs=15 KHz
...    NRCELL-1/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-1:ssbFrequency=127450
...    NRCELL-1:measGapSelectionSA=favourUeThroughput

@{NRREL}
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-1:gNbId=1
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-1:removeNotAllowed=false
...    NRCELL-1/NRREL-1:lcrId=12
...    NRCELL-1/NRREL-1:sCellPrio=1
...    NRCELL-1/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-2:gNbId=1
...    NRCELL-1/NRREL-2:gNbIdLength=22
...    NRCELL-1/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-2:removeNotAllowed=false
...    NRCELL-1/NRREL-2:lcrId=14
...    NRCELL-1/NRREL-2:sCellPrio=2
...    NRCELL-1/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-3:gNbId=1
...    NRCELL-1/NRREL-3:gNbIdLength=22
...    NRCELL-1/NRREL-3:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-3:removeNotAllowed=false
...    NRCELL-1/NRREL-3:lcrId=11
...    NRCELL-1/NRREL-3:sCellPrio=1
...    NRCELL-1/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-4:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-4:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-4:gNbId=1
...    NRCELL-1/NRREL-4:gNbIdLength=22
...    NRCELL-1/NRREL-4:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-4:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-4:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-4:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-4:removeNotAllowed=false
...    NRCELL-1/NRREL-4:lcrId=13
...    NRCELL-1/NRREL-4:sCellPrio=2
...    NRCELL-1/NRREL-4:sCellAdditionMethod=covBasedA1

@{8290_enable}
...    MRBTS-1/NRBTS-1:actHoOptimizationCa=true
...    NRDU-1:actInterNumerologyCa=true
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRBTS-1:actCarrierAggregation=true
...    NRBTS-1:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS-1:actSCellSwapFr1=a6BasedSa
...    NRBTS-1:sCellActivationMethod=blind
...    NRCELL:maxNumScellsDlFr1=3
...    NRBTS-1:caConfigurationSupport=4CCDL_2CCUL

...    NRCELL:sCellDeactivationTimerGNB=infinity
...    NRCELL:actK1Opt=intra-gNB
...    NRCELL:cellDepType=SA+NSA
...    NRCELL:actCDrx=false
...    NRCELL-11:a6MeasSCellSwapEnabled=rsrp
...    NRCELL-12:a6MeasSCellSwapEnabled=rsrp
...    NRCELL-13:a6MeasSCellSwapEnabled=rsrp
...    NRCELL:a6MeasSCellSwapSsbRsrp:a6HysteresisSCellSwapSsbRsrp=0|a6OffsetSCellSwapSsbRsrp=20|a6TimeToTrigSCellSwapSsbRsrp=ms480
...    NRCELL:a6MeasSCellSwapSsbRsrq:a6HysteresisSCellSwapSsbRsrq=0|a6OffsetSCellSwapSsbRsrq=20|a6TimeToTrigSCellSwapSsbRsrq=ms480
...    NRCELL:reportAmountA6MeasSCellSwap=infinity
...    NRCELL:reportIntervalA6MeasSCellSwap=ms1024
...    NRCELL:thresholdSCellSwapSourceRsrp=66
...    NRCELL:thresholdSCellSwapSourceRsrq=67
...    NRCELL:a1MeasSCellAddEnabled=rsrp
...    NRCELL:a2MeasSCellRelEnabled=rsrp
...    NRCELL:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=70|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=90|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrq:a1HysteresisSCellAddSsbRsrq=0|a1TimeToTriggerSCellAddSsbRsrq=320ms
...    NRCELL:a1MeasSCellAddSsbRsrq:a1ThresholdSCellAddSsbRsrq=30|a1TimeToTriggerSCellAddSsbRsrq=320ms
...    NRCELL:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=480ms
...    NRCELL:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=40|a2TimeToTriggerSCellRelSsbRsrp=480ms
...    NRCELL:a2MeasSCellRelSsbRsrq:a2HysteresisSCellRelSsbRsrq=0|a2TimeToTriggerSCellRelSsbRsrq=480ms
...    NRCELL:a2MeasSCellRelSsbRsrq:a2ThresholdSCellRelSsbRsrq=43|a2TimeToTriggerSCellRelSsbRsrq=480ms
...    NRCELL-12:weightForSCellSelection=50
...    NRCELL-14:weightForSCellSelection=50
...    NRCELL-13:weightForSCellSelection=60
...    NRCELL-11:weightForSCellSelection=60
...    NRCELL-1:weightForSCellSelection=50
...    NRCELL-2:weightForSCellSelection=50
...    NRCELL-11:actProactUlSchedulingEnh=disabled
...    NRCELL-12:actProactUlSchedulingEnh=disabled
...    NRCELL-13:actProactUlSchedulingEnh=disabled
...    NRCELL-14:actProactUlSchedulingEnh=disabled
...    NRDU-1:carrierAggregationSupportList=ca_Fdd_Fdd,ca_Fdd_Fr1Tdd_Sa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fdd_Any_Sa,ca_Fr1Tdd_Any_Sa

@{same frequency}
...    MRBTS-1/NRBTS-1/NRCELL-13/NRCELL_FDD-1:chBwDl=10MHz
...    MRBTS-1/NRBTS-1/NRCELL-13/NRCELL_FDD-1:chBwUl=10MHz
...    MRBTS-1/NRBTS-1/NRCELL-13:type0CoresetConfigurationIndex=7
...    MRBTS-1/NRBTS-1/NRCELL-13:gscnOrSsPbchArfcn=5300
...    MRBTS-1/NRBTS-1/NRCELL-13/NRCELL_FDD-1:nrarfcnDl=424000
...    MRBTS-1/NRBTS-1/NRCELL-13/NRCELL_FDD-1:nrarfcnUl=344000
...    MRBTS-1/NRBTS-1/NRCELL-12:gscnOrSsPbchArfcn=1592
...    MRBTS-1/NRBTS-1/NRCELL-12/NRCELL_FDD-1:nrarfcnDl=127420
...    MRBTS-1/NRBTS-1/NRCELL-12/NRCELL_FDD-1:nrarfcnUl=136620
...    MRBTS-1/NRBTS-1/NRCELL-12/NRCELL_FDD-1:chBwDl=10MHz
...    MRBTS-1/NRBTS-1/NRCELL-12/NRCELL_FDD-1:chBwUl=10MHz
...    MRBTS-1/NRBTS-1/NRCELL-12:type0CoresetConfigurationIndex=8
...    MRBTS-1/NRBTS-1/NRCELL-14:gscnOrSsPbchArfcn=1592
...    MRBTS-1/NRBTS-1/NRCELL-14/NRCELL_FDD-1:nrarfcnDl=127420
...    MRBTS-1/NRBTS-1/NRCELL-14/NRCELL_FDD-1:nrarfcnUl=136620
...    MRBTS-1/NRBTS-1/NRCELL-14/NRCELL_FDD-1:chBwDl=10MHz
...    MRBTS-1/NRBTS-1/NRCELL-14/NRCELL_FDD-1:chBwUl=10MHz
...    MRBTS-1/NRBTS-1/NRCELL-14:type0CoresetConfigurationIndex=8

@{OnlineParamChange_B098}
...    NRCELL:a2MeasPCellSwitchEnabled=rsrp

@{OnlineParam_B098_recover}
...    NRCELL:a2MeasPCellSwitchEnabled=none


${ue_id}    81
${pdu_id}    1
${gw_id}    1
${nwslice}    1

*** Test Cases ***
CB008290-ET-B094_Verify_incoming_A6_MR_for_scell_swap_queue_and_finally_swap_succeed_when_A2_MR_for_a_different_scell_release_ongoing
    [Documentation]
    ...    1. This user scenario Verify_incoming_A6_MR_for_scell_swap_queue_and_finally_swap_succeed_when_A2
    ...             MR_for_a_different_scell_release_ongoing. 5G_RAN_USR_RRM_16486
    ...    2. Configuration:
    ...        TDD Cell1/Cell2 configure to same frequency, FDD Cell11/Cell13 configure to same frequency.
    ...        FDD cell12/cell14 configure to another same frequency.
    ...        Configure nrrel Relations: cell1-cell11, cell1-cell13,cell1-cell12, cell1-cell14
    ...    3. Test Case Steps:
    ...         1) UE registers successfully and PDU session is setup successfully on cell 1, Start UL/DL data.
    ...             A1 meas for scell addition configured. mobility A3/A5 configured.
    ...         2) UE sends A1 measurement for SCell 11 and scell 12 Addition successfully.
    ...         3) delay to send RRC Reconfiguration Complete.
    ...         4) A2 scell release cell 12. scell release procedure hold on,then cell 11 A6 swap to cell 13.
    ...            A2 scell release procedure complete and successfully, then scell swap trigger successfully.
    [Tags]    QC_244335    B094
    Ue Register to cell1 and add cell11_12 as scell
    Trigger hold RRC reconfiguration complete
    Trigger ScellRel After HoldOn    carrierfreq=127450    scell=2    #release cell 12
    Wait Trigger ScellSwap sucessfully    carrierfreq=424090    scell_id=1    phycell_id=62    #cell 11 swap to cell 13
    Verify Throuput on Pscell and Scell    pcell_dl=300    scell_dl=60    scell_id=2
    UE Deregister From gNB
    Check Wireshark Log    ${CURDIR}${/}a2a_CB008290B094${/}a2a.ini    wait_string=UEContextRelease::12

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_2T4F_2N41_2N71_2N66

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir

B098_Teardown
    OnlineParamChange    ${OnlineParam_B098_recover}
    Common Test Teardown And Stop Capture Logs

UE Attach To Target Cell
    [Arguments]    ${cell_id}    ${ue_id}=81
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=${gw_id} nwslice=${nwslice}    QoS Routing Table

Send Throuput
    [Arguments]    ${ue_id}=81
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=1    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=3    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=4    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=ul mbps=10 trf_id=1    UE ${ue_id}: UDP UL
    sleep    30s    #sleep for stable traffic

Verify Throuput on Pscell
    [Arguments]    ${ue_id}=81    ${pcell_dl}=60    ${ul}=7
    sleep    5s    #sleep for stable traffic
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-4 type=pdsch    pass_regexp=CellIndex
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=current
    Should Be True    ${scell0_tput}/1000>${pcell_dl}
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul}

Verify Throuput on Pscell and Scell
    [Arguments]    ${ue_id}=81    ${pcell_dl}=60    ${scell_dl}=60    ${ul}=7    ${scell_id}=1
    sleep    5s     #sleep for stable traffic
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-4 type=pdsch    pass_regexp=CellIndex
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=current
    Should Be True    ${scell0_tput}/1000 > ${pcell_dl}
    ${scell1_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${scell_id}    type=pdsch    rate_type=current
    Should Be True    ${scell1_tput}/1000 > ${scell_dl}
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul}

Verify Throuput on Pscell and Scell1_2
    [Arguments]    ${ue_id}=81    ${pcell_dl}=60    ${scell_dl}=60    ${ul}=7    ${scell_id}=1    ${scell_2}=2    ${scell2_dl}=60
    sleep    5s     #sleep for stable traffic
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-4 type=pdsch    pass_regexp=CellIndex
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=current
    Should Be True    ${scell0_tput}/1000 > ${pcell_dl}
    ${scell1_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${scell_id}    type=pdsch    rate_type=current
    Should Be True    ${scell1_tput}/1000 > ${scell_dl}
    ${scell1_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${scell_2}    type=pdsch    rate_type=current
    Should Be True    ${scell1_tput}/1000 > ${scell2_dl}
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul}

UE Deregister From gNB
    [Arguments]    ${ue_id}=81
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s

Trigger ScellAdd
    [Arguments]    ${event_type}=A1    ${carrierfreq}=424090    ${srsrp_nr}=81    ${srsrq_nr}=81    ${ue_id}=81
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr    id=${ue_id}    meas_id=${meas_id}    event=${event_type}
    ...    srsrp_nr=${srsrp_nr}    srsrq_nr=${srsrq_nr}
    Execute Egate Command    ${cmd}    pass_regexp=rrcReconfigurationComplete

Trigger ScellRel
    [Arguments]    ${event_type}=A2    ${carrierfreq}=518910    ${scell}=1    ${scell_rsrp}=30    ${ue_id}=81
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type}
    ...    scell=${scell} scell_rsrp=${scell_rsrp}
    Execute Egate Command    ${cmd}    pass_regexp=rrcReconfigurationComplete

Trigger ScellSwap
    [Arguments]    ${event_type}=A6    ${carrierfreq}=632736    ${nrsrp_nr}=63    ${nrsrq_nr}=20    ${ue_id}=81    ${scell_id}=1
    ...    ${phycell_id}=61
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type}
    ...    srsrp_nr=11 srsrq_nr=11 scell=${scell_id} scell_rsrp=20 scell_rsrq=20 phycell_id=${phycell_id} nrsrp_nr=${nrsrp_nr} nrsrq_nr=${nrsrq_nr}
    Execute Egate Command    ${cmd}    pass_regexp=rrcReconfigurationComplete

Wait Trigger ScellSwap sucessfully
    [Arguments]    ${event_type}=A6    ${carrierfreq}=632736    ${nrsrp_nr}=63    ${nrsrq_nr}=20    ${ue_id}=81    ${scell_id}=1
    ...    ${phycell_id}=61
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type}
    ...    srsrp_nr=11 srsrq_nr=11 scell=${scell_id} scell_rsrp=20 scell_rsrq=20 phycell_id=${phycell_id} nrsrp_nr=${nrsrp_nr} nrsrq_nr=${nrsrq_nr}
    Execute Egate Command    ${cmd}    pass_regexp=SCellIndex 2 activated successfully at airphone.

Trigger hold RRC reconfiguration complete
    ${ret1}=     Execute Egate Command    ue_nr_rrc_reconf_param id=${ue_id} if_contains=any delay=3000

Trigger ScellRel After HoldOn
    [Arguments]    ${event_type}=A2    ${carrierfreq}=518910    ${scell}=1    ${scell_rsrp}=30    ${ue_id}=81
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type}
    ...    scell=${scell} scell_rsrp=${scell_rsrp}
    Execute Egate Command    ${cmd}    Hit on error cases presence=any action=delay    timeout=3s

Ue Register to cell1 and add cell11_12 as scell
    ${ret1}=     Execute Egate Command    ue_nr_rrc_reconf_param id=${ue_id} if_contains=any delay=0
    UE Attach To Target Cell    cell_id=1
    Send Throuput
    Verify Throuput on Pscell    pcell_dl=300    ul=7
    Trigger ScellAdd    carrierfreq=518910
    Verify Throuput on Pscell and Scell1_2    pcell_dl=300    scell_dl=60    ul=7    scell2_dl=60

Frist Trigger ScellSwap then A2 Pcell Switch and last ScellRel
    [Arguments]    ${carrierfreq}=424090    ${nrsrp_nr}=63    ${nrsrq_nr}=20    ${ue_id}=81    ${scell_id}=1    ${scell_id_2}=2
    ...    ${phycell_id}=62    ${Pcell_Switch_carrierfreq}=518910    ${A2_ScellRel_carrierfreq}=127450
    ...    ${srsrp_nr}=60    ${srsrq_nr}=11    ${scell_rsrp}=30
    ${A6_id}    get nr meas id for specific type and frequency    ${ue_id}    event_type=A6    carrierfreq=${carrierfreq}
    ${PSwitch_id}    get nr meas id for specific type and frequency    ${ue_id}    event_type=A2    carrierfreq=${Pcell_Switch_carrierfreq}
    ${A2_id}    get nr meas id for specific type and frequency    ${ue_id}    event_type=A2    carrierfreq=${A2_ScellRel_carrierfreq}
    ${A6_cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${A6_id} event=A6 srsrp_nr=11 srsrq_nr=11
    ...    scell=${scell_id} scell_rsrp=20 scell_rsrq=20 phycell_id=${phycell_id} nrsrp_nr=${nrsrp_nr} nrsrq_nr=${nrsrq_nr}
    ${PSwitch_cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${PSwitch_id} event=A2 srsrp_nr=${srsrp_nr}
    ...    srsrq_nr=${srsrq_nr} scell=${scell_id_2} scell_rsrp=123 scell_rsrq=55
    ${SRel_cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${A2_id} event=A2    scell=${scell_id_2} scell_rsrp=${scell_rsrp}
    Execute Egate Command    ${A6_cmd}    Hit on error cases presence=any action=delay    timeout=3s
    Execute Egate Command     ${PSwitch_cmd}    pass_regexp=measurementReport
    Execute Egate Command    ${SRel_cmd}    pass_regexp=rrcReconfigurationComplete

