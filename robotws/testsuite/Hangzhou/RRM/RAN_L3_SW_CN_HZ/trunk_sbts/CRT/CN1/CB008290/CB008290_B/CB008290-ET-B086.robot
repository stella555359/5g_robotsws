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
...    @{A1pcellchange}
...    @{intraFreqA3_NRHOIF}
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

@{A1pcellchange}
...    NRBTS-1:actInterFreqHoSA=true
...    NRBTS-1:actIntraFreqHoSA=true
...    NRPMRNL-1:miNrRelReportCu=15min
...    NRCELL:a1MeasPCellSwitchEnabled=rsrp
...    NRCELL:a1MeasPCellSwitchSsbRsrp:a1HysteresisPCellSwitchSsbRsrp=0
...    NRCELL:a1MeasPCellSwitchSsbRsrp:a1ThresholdPCellSwitchSsbRsrp=100
...    NRCELL:a1MeasPCellSwitchSsbRsrp:a1TimeToTriggerPCellSwitchSsbRsrp=0ms
...    NRCELL-11/NRHOIF-1:a1BasedPCellSwitchEnabled=true
...    NRCELL-11/NRHOIF-1:cellDepType=SA
...    NRCELL-11/NRHOIF-1:freqBandIndicatorNR=66
...    NRCELL-11/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-11/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-11/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf5
...    NRCELL-11/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-11/NRHOIF-1:scs=15 KHz
...    NRCELL-11/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-11/NRHOIF-1:ssbFrequency=427970
...    NRCELL-11:measGapSelectionSA=favourUeThroughput
...    NRCELL-11/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0|a3OffsetSsbRsrp=30|a3TimeToTriggerSsbRsrp=ms64
...    NRCELL-11/NRHOIF-1:a5MeasEnabled=rsrp
...    NRCELL-11/NRHOIF-1:a5MeasSsbRsrp:a5HysteresisSsbRsrp=0|a5Threshold1SsbRsrp=52|a5Threshold2SsbRsrp=54|a5TimeToTriggerSsbRsrp=ms100

@{NRREL}
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-1:gNbId=1
...    NRCELL-11/NRREL-1:gNbIdLength=22
...    NRCELL-11/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-1:removeNotAllowed=false
...    NRCELL-11/NRREL-1:lcrId=1
...    NRCELL-11/NRREL-1:sCellPrio=1
...    NRCELL-11/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-2:gNbId=1
...    NRCELL-11/NRREL-2:gNbIdLength=22
...    NRCELL-11/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-2:removeNotAllowed=false
...    NRCELL-11/NRREL-2:lcrId=2
...    NRCELL-11/NRREL-2:sCellPrio=2
...    NRCELL-11/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-3:gNbId=1
...    NRCELL-11/NRREL-3:gNbIdLength=22
...    NRCELL-11/NRREL-3:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-3:removeNotAllowed=false
...    NRCELL-11/NRREL-3:lcrId=12
...    NRCELL-11/NRREL-3:sCellPrio=1
...    NRCELL-11/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-3:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-4:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-4:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-4:gNbId=1
...    NRCELL-11/NRREL-4:gNbIdLength=22
...    NRCELL-11/NRREL-4:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-4:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-4:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-4:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-4:removeNotAllowed=false
...    NRCELL-11/NRREL-4:lcrId=14
...    NRCELL-11/NRREL-4:sCellPrio=2
...    NRCELL-11/NRREL-4:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-4:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-6:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-6:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-6:gNbId=1
...    NRCELL-11/NRREL-6:gNbIdLength=22
...    NRCELL-11/NRREL-6:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-6:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-6:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-6:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-6:removeNotAllowed=false
...    NRCELL-11/NRREL-6:lcrId=13
...    NRCELL-11/NRREL-6:sCellPrio=1
...    NRCELL-11/NRREL-6:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-6:sCellOperationalMode=dlOnly

@{8290_enable}
...    MRBTS-1/NRBTS-1:actHoOptimizationCa=true
...    NRDU-1:actInterNumerologyCa=true
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRBTS-1:actCarrierAggregation=true
...    NRBTS-1:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS-1:actSCellSwapFr1=a6BasedSa
...    NRBTS-1:sCellActivationMethod=bufferBased
...    NRCELL:maxNumScellsDlFr1=3
...    NRBTS-1:caConfigurationSupport=4CCDL_2CCUL
...    NRCELL:sCellDeactivationTimerGNB=ms1280
...    NRCELL:cellDepType=SA
...    delete:NRCELL-.*:configuredEpsTac
...    NRCELL:actCDrx=true
...    NRCELL:a6MeasSCellSwapEnabled=rsrp
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
...    NRCELL-11:actProactUlScheduling=false
...    NRCELL-12:actProactUlScheduling=false
...    NRCELL-13:actProactUlScheduling=false
...    NRCELL-14:actProactUlScheduling=false
...    NRDU-1:carrierAggregationSupportList=ca_Fdd_Fdd,ca_Fdd_Fr1Tdd_Sa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fdd_Any_Sa,ca_Fr1Tdd_Any_Sa

@{same frequency}
...    MRBTS-1/NRBTS-1/NRCELL-13:gscnOrSsPbchArfcn=5350
...    MRBTS-1/NRBTS-1/NRCELL-13:type0CoresetConfigurationIndex=8
...    MRBTS-1/NRBTS-1/NRCELL-13/NRCELL_FDD-1:nrarfcnDl=428000
...    MRBTS-1/NRBTS-1/NRCELL-13/NRCELL_FDD-1:nrarfcnUl=348000
...    MRBTS-1/NRBTS-1/NRCELL-13/NRCELL_FDD-1:chBwDl=10MHz
...    MRBTS-1/NRBTS-1/NRCELL-13/NRCELL_FDD-1:chBwUl=10MHz
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

@{intraFreqA3_NRHOIF}
...    NRBTS/NRADJGNB-1:administrativeState=Unlocked
...    NRBTS/NRADJGNB-1:gNbIdLength=22
...    NRBTS/NRADJGNB-1:gNodeBId=36
...    NRBTS/NRADJGNB-1:weightForIgnbCaSelection=1
...    NRBTS/NRADJGNB-1:xnLinkRef=1
...    NRBTS/NRADJGNB-1:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-1:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-1:cellDepType=SA
...    NRBTS/NRADJNRCELL-1:fiveGsTac=200
...    NRBTS/NRADJNRCELL-1:freqBandIndicatorNR=66
...    NRBTS/NRADJNRCELL-1:gNbId=36
...    NRBTS/NRADJNRCELL-1:gNbIdLength=22
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-1:lcrId=1
...    NRBTS/NRADJNRCELL-1:nrarfcn=633372
...    NRBTS/NRADJNRCELL-1:physCellId=30
...    NRBTS/NRADJNRCELL-1:ssbFrequency=424090
...    NRBTS/XNLINK-1:cPlaneIpAddr=10.0.1.124
...    NRBTS/XNLINK-1:cPlaneIpAddrCtrl=oamControlled
...    NRCELL-11/NRHOIF-2:cellDepType=SA
...    NRCELL-11/NRHOIF-2:a1BasedPCellSwitchEnabled=false
...    NRCELL-11/NRHOIF-2:freqBandIndicatorNR=66
...    NRCELL-11/NRHOIF-2:ifhoSsbScs=15KHz
...    NRCELL-11/NRHOIF-2:ifhoSsbSmtcDuration=sf1
...    NRCELL-11/NRHOIF-2:ifhoSsbSmtcPeriodicity=sf5
...    NRCELL-11/NRHOIF-2:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-11/NRHOIF-2:scs=15 KHz
...    NRCELL-11/NRHOIF-2:ssBurstSetPeriod=20
...    NRCELL-11/NRHOIF-2:ssbFrequency=424090
...    NRCELL-11:measGapSelectionSA=favourUeThroughput
...    NRCELL-11/NRHOIF-2:a3MeasEnabled=rsrp
...    NRCELL-11/NRHOIF-2:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0|a3OffsetSsbRsrp=25|a3TimeToTriggerSsbRsrp=ms80
...    NRCELL-11/NRHOIF-2:a5MeasEnabled=none
...    NRCELL-11/NRREL-5:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-5:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-5:gNbId=36
...    NRCELL-11/NRREL-5:gNbIdLength=22
...    NRCELL-11/NRREL-5:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-5:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-5:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-5:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-5:removeNotAllowed=false
...    NRCELL-11/NRREL-5:lcrId=1
...    NRCELL-11/NRREL-5:sCellPrio=1
...    NRCELL-11/NRREL-5:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-5:sCellOperationalMode=dlOnly
...    NRDU-1:actInterGnbCa=DLOnly
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRDU-1:actInterNumerologyCa=true
...    NRBTS:iGnbCaXnSetupReqTmr=30
...    NRCELL:actK1Opt=intraAndInter-gNB
...    NRBTS:intGnbScellTempBlockTmr=60
...    NRBTS:iGnbCaXnCfUpBackOffTmr=0
...    NRBTS:iGnbCaXnSetupRespTmr=1
...    NRBTS:weightForIgnbCaSelection=1
...    NRBTS-1:actIncXn=true

@{online_modify_scell_administrativeState_to_Locked}
...    NRCELL-12:administrativeState=Locked

@{online_modify_scell_administrativeState_to_Unlocked}
...    NRCELL-12:administrativeState=Unlocked

${SA_4CC}    SEPARATOR=
...    E9A09000575F5A13160003C320016093170019C3D09009B20C39F30C7942C0E098040623807DC6C28C0D608C21A08107482406D6C98AB1A1C
...    F88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E007FE00088000E0541B107582308682041E2090195B262AC4873EC09F11
...    C78C48E3C873EA39F30C7942C0E070F09FFF000007FFC0000044000702A8D89BAC1184341020E90480B2D931543439F11C7A067D813E31CF9
...    863CA16070387817003FF001C00FFC00110001C0A836236B04610D04083E5048092D931541439F11C78C0000000000000000004FFF800003F
...    FE00000220003801CF0F10400388C0000002C040BC3C28000E230000010B0102F1F0A0003882001C46000E208000020B0102F1710400389A0
...    01C28000006160205E1E14000713400002058081707850001C4100000A160205E1E20800711800003058081787882001C4D00000E160205E2
...    E1400071040038820000202C040BC5C28000E2300071180000485808178B882001C41000E2300000A0B0102F1710400388C001C4600001616
...    0205E1E2300071340000605808178B882001C46000E2680000D0B010200E0234028809B01043505783A14489B1CF870A244D8E7C38D122448
...    9B1CF871224489B1CF870A244D8E7C3851226C73E1C28913639F0E14489B1CF871224489B1CF871224489B1CF871224489B1CF871224489B1
...    CF870A244D8E7C38912244D8E7C30A870C6318C6318C6318C6F413003C00381C1401C0C02500700060240040603E008020000000100000200
...    B036B2A68020800004B29282000032CA4A00A81D552AAA12009001A0500068404008010100200420200801008010023010040080400801010
...    02004040080110080100202008010080200410100400804010020808020040200400840400801010020042020040080802004201004008040
...    08010100200440200801008010020200400880400801010020040400801100801002020040080801002101002004040100210080100202004
...    00808020043543E00020406080C0E1416181A2022242628303236383A3E424A4C4E5052545A5E828305A0

${ue_id}    81
${pdu_id}    1
${gw_id}    1
${nwslice}    1
${delay_re}    Hit on error cases presence=any action=delay

@{handover back check}
...    Inter-eNB handover from ENB-4.1 to EXT_ENB-2.11 performed
...    physCellId 50
...    physCellId 61
...    physCellId 62
...    SCellIndex 2 activated successfully at airphone
...    SCellIndex 3 activated successfully at airphone
...    SCellIndex 1 activated successfully at airphone

*** Test Cases ***
CB008290-ET-B086_Verify_incoming_A2_MR_for_scell_deletion_queue_when_A6_scell_swap_ongoing
    [Documentation]
    ...    1. This user scenario Verify_incoming_A2_MR_for_scell_deletion_queue_when_A6_scell_swap_ongoing
    ...    2. Configuration:
    ...        TDD Cell1/Cell2 configure to same frequency, FDD Cell11/Cell13 configure to different frequency.
    ...        FDD cell12/cell14 configure to another same frequency.
    ...        Configure nrrel Relations: cell11-cell1(sCellPrio=1), cell11-cell2(sCellPrio=2),cell11-cell12(sCellPrio=1),
    ...        cell11-cell14(sCellPrio=2),cell11-13(sCellPrio=1).cell11-gnb36_cell1(sCellPrio=1),same frequ as cell11.
    ...    3. Test Case Steps:
    ...         1) UE registers successfully and PDU session is setup successfully on cell 11, Start UL/DL data.
    ...             A1 meas for scell addition configured. mobility A2/A3/A5 configured.
    ...         2) UE sends A1 measurement for scell 1 ,scell 12 ,scell 13 Addition successfully.F+F+F+T.
    ...         3) delay to send RRC Reconfiguration Complete.
    ...         4) cell 1 A6 swap to cell 2. A6 swap procedure hold on.Then A2 for scell 12 release,procedure queue.
    ...           result: A6 swap procedure complete and successfully,then A2 for scell release complete and successfully.
    ...         5) delay to send RRC Reconfiguration Complete.
    ...         6) cell 2 A6 swap to cell 1. A6 swap procedure hold on.Then A2 for scell 2 release,procedure queue.
    ...          result: A6 swap procedure complete and successfully,then A2 for scell release ignore and not triggered.
    [Tags]    QC_224321    B086
    Ue Register to cell11 and add cell1_12_13 as scell
    Trigger hold RRC reconfiguration complete
    Trigger ScellSwap    pass_regexp=${delay_re}    #cell 1 swap to cell 2
    Trigger ScellRel    carrierfreq=127450    scell=2    #scell relesae cell 12
    Verify Throuput on Pscell and Scell1_2    pcell_dl=60    scell_dl=50    scell_id=3    scell_2=4    scell2_dl=250
    Trigger hold RRC reconfiguration complete
    Trigger ScellSwap    pass_regexp=${delay_re}    scell_id=4    phycell_id=50    #cell 2 swap to cell 1
    Trigger ScellRel    #scell relesae cell 2
    Verify Throuput on Pscell and Scell1_2    pcell_dl=60    scell_dl=50    scell_id=3    scell_2=1    scell2_dl=250
    UE Deregister From gNB
    Check Wireshark Log    ${CURDIR}${/}a2a_CB008290B086${/}a2a.ini    wait_string=UEContextRelease::12

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_2T4F_2N41_2N71_2N66

Update UE capa
    [Arguments]    ${SA_Capa_perUE_Full}=none    ${ue_id}=81
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full}
    Execute Egate Command    ${cmd}

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
    sleep    10s    #sleep for stable traffic
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-4 type=pdsch    pass_regexp=CellIndex
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=current
    Should Be True    ${scell0_tput}/1000>${pcell_dl}
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul}

Verify Throuput on Pscell and Scell
    [Arguments]    ${ue_id}=81    ${pcell_dl}=60    ${scell_dl}=50    ${ul}=7    ${scell_id}=1
    sleep    10s     #sleep for stable traffic
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-4 type=pdsch    pass_regexp=CellIndex
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=current
    Should Be True    ${scell0_tput}/1000 > ${pcell_dl}
    ${scell1_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${scell_id}    type=pdsch    rate_type=current
    Should Be True    ${scell1_tput}/1000 > ${scell_dl}
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul}

Verify Throuput on Pscell and Scell1_2
    [Arguments]    ${ue_id}=81    ${pcell_dl}=60    ${scell_dl}=50    ${ul}=7    ${scell_id}=1    ${scell_2}=2    ${scell2_dl}=60
    sleep    10s     #sleep for stable traffic
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-4 type=pdsch    pass_regexp=CellIndex
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=current
    Should Be True    ${scell0_tput}/1000 > ${pcell_dl}
    ${scell1_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${scell_id}    type=pdsch    rate_type=current
    Should Be True    ${scell1_tput}/1000 > ${scell_dl}
    ${scell1_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${scell_2}    type=pdsch    rate_type=current
    Should Be True    ${scell1_tput}/1000 > ${scell2_dl}
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul}

Verify Throuput on Scells
    [Arguments]    ${ue_id}=81    ${scell_dl}=60    ${scell_id}=1    ${scell_2}=2    ${scell2_dl}=60    ${scell_3}=3
    ...    ${scell3_dl}=60
    sleep    10s     #sleep for stable traffic
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-4 type=pdsch    pass_regexp=CellIndex
    ${scell1_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${scell_id}    type=pdsch    rate_type=current
    Should Be True    ${scell1_tput}/1000 > ${scell_dl}
    ${scell1_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${scell_2}    type=pdsch    rate_type=current
    Should Be True    ${scell1_tput}/1000 > ${scell2_dl}
    ${scell1_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${scell_3}    type=pdsch    rate_type=current
    Should Be True    ${scell1_tput}/1000 > ${scell3_dl}

UE Deregister From gNB
    [Arguments]    ${ue_id}=81
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s

Trigger ScellAdd
    [Arguments]    ${event_type}=A1    ${carrierfreq}=424090    ${srsrp_nr}=81    ${srsrq_nr}=81    ${ue_id}=81    ${threshold}=70
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}    threshold=${threshold}
    ${cmd}    Catenate    ue_measurement_send_nr    id=${ue_id}    meas_id=${meas_id}    event=${event_type}
    ...    srsrp_nr=${srsrp_nr}    srsrq_nr=${srsrq_nr}
    Execute Egate Command    ${cmd}    pass_regexp=rrcReconfigurationComplete

Trigger ScellAdd fail
    [Arguments]    ${event_type}=A1    ${carrierfreq}=424090    ${srsrp_nr}=81    ${srsrq_nr}=81    ${ue_id}=81    ${threshold}=70
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}    threshold=${threshold}
    ${cmd}    Catenate    ue_measurement_send_nr    id=${ue_id}    meas_id=${meas_id}    event=${event_type}
    ...    srsrp_nr=${srsrp_nr}    srsrq_nr=${srsrq_nr}
    Execute Egate Command    ${cmd}    fail_regexp=rrcReconfigurationComplete

Modify Cfg
    ${C_1}    catenate
    ...    set_cell id=1 gnb=4 pci=10:0 tac=200 nrci=0x01 tdd_cell=off proxy=10.0.2.90:9999 nr_arfcn=344000:424000
    ...    gscn=5300 mandatory_for_activation=off
    Update Cfg    ${C_1}
    Update Cfg    gnb_param id=4 xn_listening_socket=1 send_xn_setup=true

Setup XN Link
    Execute Egate Command    gnb_xn_link_up gnb=4 target=2    pass_regexp=XnAP Link with GNB

Trigger hold RRC reconfiguration complete
    [Arguments]    ${ue_id}=81
    ${ret1}=     Execute Egate Command    ue_nr_rrc_reconf_param id=${ue_id} if_contains=any delay=5000

Ue Register to cell11 and add cell1_12_13 as scell
    [Arguments]    ${ue_id}=81
    ${ret1}=     Execute Egate Command    ue_nr_rrc_reconf_param id=${ue_id} if_contains=any delay=0
    Update UE capa    ${SA_4CC}    ${ue_id}
    UE Attach To Target Cell    cell_id=11    ue_id=${ue_id}
    Send Throuput    ${ue_id}
    Verify Throuput on Pscell    ue_id=${ue_id}    pcell_dl=60
    Trigger ScellAdd    ue_id=${ue_id}    srsrp_nr=100
    Verify Throuput on Pscell    ue_id=${ue_id}    pcell_dl=60
    Verify Throuput on Scells    ue_id=${ue_id}    scell_dl=300    scell2_dl=60    scell3_dl=60

Ue Register to cell11 and add scell fail
    [Arguments]    ${ue_id}=81
    ${ret1}=     Execute Egate Command    ue_nr_rrc_reconf_param id=${ue_id} if_contains=any delay=0
    Update UE capa    ${SA_4CC}    ${ue_id}
    UE Attach To Target Cell    cell_id=11    ue_id=${ue_id}
    Send Throuput    ${ue_id}
    Verify Throuput on Pscell    ue_id=${ue_id}    pcell_dl=60
    Trigger ScellAdd fail    ue_id=${ue_id}    srsrp_nr=100

Ue Register to cell11 and add cell12_13 as scell
    ${ret1}=     Execute Egate Command    ue_nr_rrc_reconf_param id=${ue_id} if_contains=any delay=0
    Update UE capa    ${SA_4CC}
    UE Attach To Target Cell    cell_id=11
    Send Throuput
    Verify Throuput on Pscell    pcell_dl=60
    Trigger ScellAdd
    Verify Throuput on Pscell and Scell1_2    pcell_dl=60    scell_dl=60    scell2_dl=60

Trigger ScellSwap
    [Arguments]    ${event_type}=A6    ${carrierfreq}=518910    ${nrsrp_nr}=63    ${nrsrq_nr}=20    ${ue_id}=81    ${scell_id}=1
    ...    ${phycell_id}=51    ${pass_regexp}=rrcReconfigurationComplete
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type}    srsrp_nr=11 srsrq_nr=11
    ...    scell=${scell_id} scell_rsrp=20 scell_rsrq=20 phycell_id=${phycell_id} nrsrp_nr=${nrsrp_nr} nrsrq_nr=${nrsrq_nr}
    Execute Egate Command    ${cmd}    pass_regexp=${pass_regexp}    timeout=3s

trigger A1 Pcell Switch
    [Arguments]    ${event_type}=A1    ${carrierfreq}=427970    ${scell_rsrp}=127    ${ue_id}=81    ${scell_id}=3    ${threshold}=100
    ...    ${source_cell}=11    ${target_cell}=13
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}    threshold=${threshold}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type} scell=${scell_id} scell_rsrp=${scell_rsrp}
    ${ret1}=    Execute Egate Command    ${cmd}    pass_regexp=Intra-eNB handover from    timeout=3s
    Should Contain    ${ret1}    Intra-eNB handover from EXT_ENB-2.${source_cell} to EXT_ENB-2.${target_cell}

Frist Trigger ScellSwap then A3 interFreq HO and last A3 intraFreq HO
    [Arguments]    ${A6_carrierfreq}=518910    ${nrsrp_nr}=80    ${nrsrq_nr}=80    ${ue_id}=81    ${scell_id}=1    ${phycell_id}=51
    ...    ${A3_interFreq_carrierfreq}=427970    ${A3_intraFreq_carrierfreq}=424090    ${A3_interFreq_phycell_id}=62
    ...    ${A3_intraFreq_phycell_id}=30
    ${A6_meas_id}    get nr meas id for specific type and frequency    ${ue_id}    event_type=A6    carrierfreq=${A6_carrierfreq}
    ${A3_interFreq_id}    get nr meas id for specific type and frequency    ${ue_id}    event_type=A3    carrierfreq=${A3_interFreq_carrierfreq}
    ${A3_intraFreq_id}    get nr meas id for specific type and frequency    ${ue_id}    event_type=A3    carrierfreq=${A3_intraFreq_carrierfreq}
    ${A6_cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${A6_meas_id} event=A6 srsrp_nr=11 srsrq_nr=11
    ...    scell=${scell_id} scell_rsrp=20 scell_rsrq=20 phycell_id=${phycell_id} nrsrp_nr=${nrsrp_nr} nrsrq_nr=${nrsrq_nr}
    ${A3_interFreq_cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${A3_interFreq_id} event=A3 srsrp_nr=11 srsrq_nr=11
    ...    phycell_id=${A3_interFreq_phycell_id} nrsrp_nr=${nrsrp_nr} nrsrq_nr=${nrsrq_nr}
    ${A3_intraFreq_cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${A3_intraFreq_id} event=A3 srsrp_nr=11 srsrq_nr=11
    ...    phycell_id=${A3_intraFreq_phycell_id} nrsrp_nr=${nrsrp_nr} nrsrq_nr=${nrsrq_nr}
    Execute Egate Command    ${A6_cmd}    pass_regexp=${delay_re}    timeout=3s    #cell 1 swap to cell 2
    Execute Egate Command    ${A3_interFreq_cmd}    pass_regexp=measurementReport    # A3 for inter freq to cell 13
    Execute Egate Command    ${A3_intraFreq_cmd}    pass_regexp=Inter-eNB handover from EXT_ENB-2.11 to ENB-4.1 performed

Handover back from simgnb to realgnb
    [Arguments]    ${nrsrp_nr}=100    ${nrsrq_nr}=100    ${ue_id}=81    ${A3_intraFreq_carrierfreq}=424090    ${A3_intraFreq_phycell_id}=60
    ${A3_intraFreq_id}    get nr meas id for specific type and frequency    ${ue_id}    event_type=A3    carrierfreq=${A3_intraFreq_carrierfreq}
    ${A3_intraFreq_cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${A3_intraFreq_id} event=A3 srsrp_nr=11 srsrq_nr=11
    ...    phycell_id=${A3_intraFreq_phycell_id} nrsrp_nr=${nrsrp_nr} nrsrq_nr=${nrsrq_nr}
    Execute Egate Command    ${A3_intraFreq_cmd}    pass_regexp=${handover back check}

Trigger ScellRel
    [Arguments]    ${event_type}=A2    ${carrierfreq}=518910    ${scell}=1    ${scell_rsrp}=30    ${ue_id}=81
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type}
    ...    scell=${scell} scell_rsrp=${scell_rsrp}
    Execute Egate Command    ${cmd}    pass_regexp=rrcReconfigurationComplete

Scell_12 locked and unlocked
    Delta Commission To locked
    sleep    3s    #wait cell_12 goes into locked status
    Delta Commission To unlocked

Delta Commission To locked
    Delta Commission Parameters    ${online_modify_scell_administrativeState_to_Locked}
    BuiltIn.Log To Console    Online Update Parameters is done

Delta Commission To unlocked
    Delta Commission Parameters    ${online_modify_scell_administrativeState_to_Unlocked}
    BuiltIn.Log To Console    Online Update Parameters is done
    sleep    60s    #wait xp setup
    wait until keyword succeeds    3 min    10 sec    cells should be on air
