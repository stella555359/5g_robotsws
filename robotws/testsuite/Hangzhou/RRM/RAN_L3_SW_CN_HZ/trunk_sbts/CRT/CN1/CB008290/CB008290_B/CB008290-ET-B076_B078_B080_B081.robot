*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    RAN_5G_TDD    SBTS00    team-Blues_SGT&A    owner-Tingjian.Mao
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
...    @{PARAMS_FOR_IODT_ABIO_2T4F}
...    @{same frequency}
...    @{NRREL}
...    @{8290_enable}
...    @{DRX}
...    @{A1pcellchange}
...    @{8697_enable}
...    @{4CC}
...    @{5GC000732}
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

@{NRREL}
...    NRCELL-11/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-10:gNbId=1
...    NRCELL-11/NRREL-10:gNbIdLength=22
...    NRCELL-11/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-10:removeNotAllowed=false
...    NRCELL-11/NRREL-10:lcrId=13
...    NRCELL-11/NRREL-4:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-4:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-4:gNbId=1
...    NRCELL-11/NRREL-4:gNbIdLength=22
...    NRCELL-11/NRREL-4:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-4:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-4:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-4:removeNotAllowed=false
...    NRCELL-11/NRREL-4:lcrId=2
...    NRCELL-11/NRREL-4:sCellPrio=1
...    NRCELL-11/NRREL-4:handoverAllowedSA=forbidden
...    NRCELL-11/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-3:gNbId=1
...    NRCELL-11/NRREL-3:gNbIdLength=22
...    NRCELL-11/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-3:removeNotAllowed=false
...    NRCELL-11/NRREL-3:lcrId=1
...    NRCELL-11/NRREL-3:sCellPrio=2
...    NRCELL-11/NRREL-3:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-2:gNbId=1
...    NRCELL-11/NRREL-2:gNbIdLength=22
...    NRCELL-11/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-2:removeNotAllowed=false
...    NRCELL-11/NRREL-2:lcrId=14
...    NRCELL-11/NRREL-2:sCellPrio=2
...    NRCELL-11/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-1:gNbId=1
...    NRCELL-11/NRREL-1:gNbIdLength=22
...    NRCELL-11/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-1:removeNotAllowed=false
...    NRCELL-11/NRREL-1:lcrId=12
...    NRCELL-11/NRREL-1:sCellPrio=1
...    NRCELL-11/NRREL-1:handoverAllowedSA=allowed

@{5GC000732}
...    NRBTS:rrcReestabTypeSA=sameGNB
...    NRBTS:tWaitingRlRecover=10000ms
...    NRBTS:actGnbInitRlf=false

@{8697_enable}
...    NRBTS-1:actOverheatingAssistance=true
...    NRBTS-1:timerPostOverheating=10
...    NRBTS-1:timerOverheatIndProhibit=1s

@{DRX}
...    NRCELL:actCDrx=true

@{8290_enable}
...    NRDU-1:actInterNumerologyCa=true
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRBTS-1:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS-1:actMeasBasedSCellAdditionNsa=true
...    NRBTS-1:actSCellSwapFr1=a6BasedSa
...    NRBTS-1:sCellActivationMethod=bufferBased
...    NRCELL:sCellDeactivationTimerGNB=infinity
...    NRCELL:cellDepType=SA+NSA
...    NRCELL:actK1Opt=intra-gNB
...    NRCELL:a6MeasSCellSwapEnabled=rsrp
...    NRCELL:a6MeasSCellSwapSsbRsrp:a6HysteresisSCellSwapSsbRsrp=0|a6OffsetSCellSwapSsbRsrp=20|a6TimeToTrigSCellSwapSsbRsrp=ms480
...    NRCELL:a6MeasSCellSwapSsbRsrq:a6HysteresisSCellSwapSsbRsrq=0|a6OffsetSCellSwapSsbRsrq=20|a6TimeToTrigSCellSwapSsbRsrq=ms480
...    NRCELL:reportAmountA6MeasSCellSwap=infinity
...    NRCELL:reportIntervalA6MeasSCellSwap=ms1024
...    NRCELL:thresholdSCellSwapSourceRsrp=66
...    NRCELL:thresholdSCellSwapSourceRsrq=67
...    NRCELL:a1MeasSCellAddEnabled=rsrp
...    NRCELL:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=70|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=90|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrq:a1HysteresisSCellAddSsbRsrq=0|a1TimeToTriggerSCellAddSsbRsrq=320ms
...    NRCELL:a1MeasSCellAddSsbRsrq:a1ThresholdSCellAddSsbRsrq=30|a1TimeToTriggerSCellAddSsbRsrq=320ms
...    NRCELL:a1MeashoEnabledSA=rsrp
...    NRCELL:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0|a1ThresholdhoSsbRsrpSA=40|a1TimeToTriggerhoSsbRsrpSA=ms64
...    NRCELL:a2MeashoEnabledSA=rsrp
...    NRCELL:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0|a2ThresholdhoSsbRsrpSA=30|a2TimeToTriggerhoSsbRsrpSA=ms64
...    NRCELL:a3MeasEnabled=rsrp
...    NRCELL:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0|a3OffsetSsbRsrp=20|a3TimeToTriggerSsbRsrp=ms64
...    NRCELL:absThreshSsbRsrpConsolidation=1
...    NRCELL:sMeasConfigSsbRsrp=1
...    NRCELL:a2MeasSCellRelEnabled=rsrp
...    NRCELL:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2ThresholdSCellRelSsbRsrp=34|a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-12:weightForSCellSelection=50
...    NRCELL-14:weightForSCellSelection=50
...    NRCELL-11:weightForSCellSelection=60
...    NRCELL-13:weightForSCellSelection=60
...    NRCELL-1:weightForSCellSelection=80
...    NRCELL-2:weightForSCellSelection=80
...    NRCELL-11/NRREL-10:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-4:sCellAdditionMethod=covBasedA1
...    NRDU-1:carrierAggregationSupportList=ca_Fdd_Fdd,ca_Fdd_Fr1Tdd_Sa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fdd_Any_Sa,ca_Fr1Tdd_Any_Sa

@{same frequency}
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

@{A1pcellchange}
...    NRBTS-1:actInterFreqHoSA=true
...    NRBTS-1:actIntraFreqHoSA=true
...    NRPMRNL-1:miNrRelReportCu=15min
...    NRCELL:a1MeasPCellSwitchEnabled=rsrp
...    NRCELL:a1MeasPCellSwitchSsbRsrp:a1HysteresisPCellSwitchSsbRsrp=0
...    NRCELL:a1MeasPCellSwitchSsbRsrp:a1ThresholdPCellSwitchSsbRsrp=100
...    NRCELL:a1MeasPCellSwitchSsbRsrp:a1TimeToTriggerPCellSwitchSsbRsrp=0ms
...    NRCELL-1/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-1/NRHOIF-1:freqBandIndicatorNR=71
...    NRCELL-1/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-1/NRHOIF-1:scs=15 KHz
...    NRCELL-1/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-1:ssbFrequency=127450
...    NRCELL-1:measGapSelectionSA=favourUeThroughput
...    NRCELL-1/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0|a3OffsetSsbRsrp=30|a3TimeToTriggerSsbRsrp=ms64
...    NRCELL-12/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-12/NRHOIF-1:a1BasedPCellSwitchEnabled=true
...    NRCELL-12/NRHOIF-1:freqBandIndicatorNR=41
...    NRCELL-12/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-12/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-12/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-12/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-12/NRHOIF-1:scs=30 KHz
...    NRCELL-12/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-12/NRHOIF-1:ssbFrequency=518910
...    NRCELL-12:measGapSelectionSA=favourUeThroughput
...    NRCELL-12/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-12/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0|a3OffsetSsbRsrp=30|a3TimeToTriggerSsbRsrp=ms64
...    NRCELL:a2MeasPCellSwitchEnabled=rsrp
...    NRCELL:a2MeasPCellSwitchSsbRsrp:a2HysteresisPCellSwitchSsbRsrp=0
...    NRCELL:a2MeasPCellSwitchSsbRsrp:a2ThresholdPCellSwitchSsbRsrp=111
...    NRCELL:a2MeasPCellSwitchSsbRsrp:a2TimeToTriggerPCellSwitchSsbRsrp=0ms
...    NRCELL:a2MeasPCellSwitchSsbRsrp:pCellSwitchOffsetSsbRsrp=1
...    NRCELL-1/NRHOIF-2:cellDepType=SA+NSA
...    NRCELL-1/NRHOIF-2:a2BasedPCellSwitchEnabled=true
...    NRCELL-1/NRHOIF-2:freqBandIndicatorNR=66
...    NRCELL-1/NRHOIF-2:ifhoSsbScs=15KHz
...    NRCELL-1/NRHOIF-2:ifhoSsbSmtcDuration=sf1
...    NRCELL-1/NRHOIF-2:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-2:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-1/NRHOIF-2:scs=15 KHz
...    NRCELL-1/NRHOIF-2:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-2:ssbFrequency=424090
...    NRCELL-1/NRHOIF-2:thresholdPCellSwitchTargetRsrp=122
...    NRCELL-1/NRHOIF-2:thresholdPCellSwitchTargetRsrq=2
...    NRCELL-1/NRHOIF-2:a2BasedPCellSwitchPriority=1
...    NRCELL-2/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-2/NRHOIF-1:a2BasedPCellSwitchEnabled=true
...    NRCELL-2/NRHOIF-1:freqBandIndicatorNR=66
...    NRCELL-2/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-2/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-2/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-2/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-2/NRHOIF-1:scs=15 KHz
...    NRCELL-2/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-2/NRHOIF-1:ssbFrequency=424090
...    NRCELL-2/NRHOIF-1:thresholdPCellSwitchTargetRsrp=122
...    NRCELL-2/NRHOIF-1:thresholdPCellSwitchTargetRsrq=2
...    NRCELL-2/NRHOIF-1:a2BasedPCellSwitchPriority=1
...    NRCELL-2:measGapSelectionSA=favourUeThroughput
...    NRCELL-13/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-13/NRHOIF-1:a1BasedPCellSwitchEnabled=true
...    NRCELL-13/NRHOIF-1:freqBandIndicatorNR=71
...    NRCELL-13/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-13/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-13/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-13/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-13/NRHOIF-1:scs=15 KHz
...    NRCELL-13/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-13/NRHOIF-1:ssbFrequency=127450
...    NRCELL-13:measGapSelectionSA=favourUeThroughput

@{4CC}
...    MRBTS-1/NRBTS-1/NRCELL-11:maxNumScellsDlFr1=3

${SA_Capa_Support}    SEPARATOR=
...    E9A09000575F5A13160003C320016093170019C3D09009B20C39F30C7942C0E098040623807DC6C28C0D608C21A08107482406D6C98AB1A1C
...    F88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE00088000E0541B107582308682041E2090195B262AC4873EC09F11
...    C78C48E3C873EA39F30C7942C0E070F09FD8000007F600000044000702A8D89BAC1184341020E90480C2D931544439F11C788E3D033EC09F1
...    8E7CC31E50B0381C3C17003FF001C00FFC00110001C0A836236B04610D04083C412032B64C55890E7C471EC09F1891C790E7D473E618F2858
...    1C0E1E13FFE00000FFF80000088000E000AC7C28000E20800710400388C0000082C0803808D00A2026C0410D4026018D0204081B1CF8000A0
...    233D04C00F000A070500703009401C0018090010180F82400800000004000008020000000100000200800002004000018020000100100000A
...    008004010040100000C0080000700400200000008000080040000480200000C010000140080000B004002048120080000C033953595358295
...    8195833582B594B5933580B581B58095811583B40D04000025949410000196525040000A59490100003965240400012594901000059652404
...    0001A594901000079652404000225949010000996524040002A5949010000B96525040003259490100003165240334AAAE955552A8BA55154
...    162A82C55068AA531549A2A80C55028AA4D5541E28480BC04A8140A05028140A05028140A05028140A05028140A000C10100C018040080108
...    080100402018030C04008010100C01804030060100C018202018030080600C201002004040300601002004402018030080600C02018030404
...    00802010020086A87C0004080C10181C282C30344044484C5060646C70747C8494989CA0A4A8B4BD050E0B4

${SA_Capa_Support_81}    SEPARATOR=
...    E9A09000575F5A13160003C320016093170019C3D09009B20C39F30C7942C0E098040623807DC6C28C0D608C21A08107482406D6C98AB1A1C
...    F88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE00088000E0541B107582308682041E2090195B262AC4873EC09F11
...    C78C48E3C873EA39F30C7942C0E070F09FD8000007F600000044000702A8D89BAC1184341020E90480C2D931544439F11C788E3D033EC09F1
...    8E7CC31E50B0381C3C17003FF001C00FFC00110001C0A836236B04610D04083C412032B64C55890E7C471EC09F1891C790E7D473E618F2858
...    1C0E1E13FFE00000FFF80000088000E000AC7C28000E20800710400388C0000082C0803808D00A2026C0410D4026018D0204081B1CF8000A0
...    233D04C00F000A070500703009401C0018090010180F82400800000004000008020000000100000200800002004000018020000100100000A
...    008004010040100000C0080000700400200000008000080040000480200000C010000140080000B004002048120080000C033953595358295
...    8195833582B594B5933580B581B58095811583B40D04000025949410000196525040000A59490100003965240400012594901000059652404
...    0001A594901000079652404000225949010000996524040002A5949010000B96525040003259490100003165240334AAAE955552A8BA55154
...    162A82C55068AA531549A2A80C55028AA4D5541E28480BC04A8140A05028140A05028140A05028140A05028140A000C10100C018040080108
...    080100402018030C04008010100C01804030060100C018202018030080600C201002004040300601002004402018030080600C02018030404
...    00802010020086A87C0004080C10181C282C30344044484C5060646C70747C8494989CA0A4A8B4BD050E0B4

${pdu_id}    1
${gw_id}    1
${nwslice}    1
${ue_id}    81

*** Test Cases ***
#CB008290-ET-B076_Verify_incoming_NGAP_PDUSessionResource_ReleaseCommand_queue_when_A6_scell_swap_ongoing
#    [Documentation]
#    ...    1. This user scenario describes Verify incoming NGAP PDUSessionResource ReleaseCommandqueue when A6 scell swap ongoing
#    ...    2. Configuration:
#    ...        TDD Cell1/Cell2 configure to same frequency, FDD Cell12/Cell14 configure to same frequency.
#    ...        FDD cell11/cell13 configure to another differ frequency.
#    ...        Configure nrrel Relations:
#    ...        cell11-cell1, cell11-cell2, cell11-cell12, cell11-cell14, cell11-cell13
#    ...    2. Test Case Steps:
#    ...        a.Attach UE-81 to the FDD NR cell11 and setup non-GBR SA call
#    ...          A1 measurement rsrp and rsrq for TDD with a1ThresholdSCellAddSsbRsrpTDD for SCell Addition
#    ...        b.UE sends A1 measurement for SCell Addition,F+F+F+T successfully,A6 meas configed to UE, DRX setup
#    ...        c.delay to send RRC Reconfiguration Complete
#    ...        d.A6 for scell swap measurement report from 5G-UE,release a pdu trigger by amf_ue_pdu_release
#    ...        e. After delay ,scell swap procedure complete and successfully, Scell activated successfully,
#    ...           then pdu release successfully
#    ...        f.UE release successfully
#    [Tags]    QC_223969    owner-Tingjian.Mao    B076
#    Update UE capa    ${SA_Capa_Support}    81
#    UE Attach To Target Cell
#    Trigger ScellAdd 4CC FFFT
#    Trigger ScellSwap and pdu release after delay
#    UE Deregister From gNB
#    Check Wireshark Log    ${CURDIR}${/}a2a_CB008290B076${/}a2a.ini    wait_string=UEContextReleaseComplete::4
#    [Teardown]    Teardown
#
#CB008290-ET-B078_Verify_incoming_NGAP_NGReset_process_and_A6_abort_when_A6_scell_swap_ongoing
#    [Documentation]
#    ...    1. This user scenario describes Verify incoming NGAP NGReset process and A6 abort when A6 scell swap ongoing
#    ...    2. Configuration:
#    ...        TDD Cell1/Cell2 configure to same frequency, FDD Cell12/Cell14 configure to same frequency.
#    ...        FDD cell11/cell13 configure to another differ frequency.
#    ...        Configure nrrel Relations:
#    ...        cell11-cell1, cell11-cell2, cell11-cell12, cell11-cell14, cell11-cell13
#    ...    2. Test Case Steps:
#    ...        a.Attach UE-81 to the FDD NR cell11 and setup non-GBR SA call
#    ...          A1 measurement rsrp and rsrq for TDD with a1ThresholdSCellAddSsbRsrpTDD for SCell Addition
#    ...        b.UE sends A1 measurement for SCell Addition,F+F+F+T successfully,A6 meas configed to UE, DRX setup
#    ...        c.delay to send RRC Reconfiguration Complete
#    ...        d.A6 for scell swap measurement report from 5G-UE then NG reset
#    ...        e.NO delay,NG reset successfully,abort the scell swap procedure
#    ...        f.UE release successfully
#    [Tags]    QC_223970    owner-Tingjian.Mao    B078
#    Update UE capa    ${SA_Capa_Support}    81
#    UE Attach To Target Cell
#    Trigger ScellAdd 4CC FFFT
#    A6 abort when NGReset
#    UE Deregister From gNB
#    Check Wireshark Log    ${CURDIR}${/}a2a_CB008290B078${/}a2a.ini    wait_string=NGResetAcknowledge::2
#    [Teardown]    Teardown

CB008290-ET-B080_Verify_incoming_RRCReestablishment_process_and_A6_abort_when_A6_scell_swap_ongoing
    [Documentation]
    ...    1. This user scenario describes Verify incoming RRCReestablishment process and A6 abort when A6 scell swap ongoing
    ...    2. Configuration:
    ...        TDD Cell1/Cell2 configure to same frequency, FDD Cell12/Cell14 configure to same frequency.
    ...        FDD cell11/cell13 configure to another differ frequency.
    ...        Configure nrrel Relations:
    ...        cell11-cell1, cell11-cell2, cell11-cell12, cell11-cell14, cell11-cell13
    ...    2. Test Case Steps:
    ...        a.Attach UE-81 to the FDD NR cell11 and setup non-GBR SA call
    ...          A1 measurement rsrp and rsrq for TDD with a1ThresholdSCellAddSsbRsrpTDD for SCell Addition
    ...        b.UE sends A1 measurement for SCell Addition,F+F+F+T successfully,A6 meas configed to UE, DRX setup
    ...        c.delay to send RRC Reconfiguration Complete
    ...        d.A6 for scell swap measurement report from 5G-UE,At the same time send RRCReestablishment
    ...        e.RRCReestablishment successfully , abort the scell swap procedure
    ...        f.UE release successfully
    [Tags]    QC_223971    owner-Tingjian.Mao    B080
    Update UE capa    ${SA_Capa_Support}    81
    UE Attach To Target Cell
    Trigger ScellAdd 4CC FFFT
    A6 abort when RRCReestablishment
    UE Deregister From gNB
    Check Wireshark Log    ${CURDIR}${/}a2a_CB008290B080${/}a2a.ini    wait_string=UEContextReleaseComplete::4
    [Teardown]    Teardown

CB008290-ET-B081_Verify_incoming_UEAssistanceInformation_for_Overheating_queue_when_A6_scell_swap_ongoing
    [Documentation]
    ...    1. This user scenario describes Verify incoming UEAssistanceInformation for Overheating queue when A6 scell swap ongoing
    ...    2. Configuration:
    ...        TDD Cell1/Cell2 configure to same frequency, FDD Cell12/Cell14 configure to same frequency.
    ...        FDD cell11/cell13 configure to another differ frequency.
    ...        Configure nrrel Relations:
    ...        cell11-cell1, cell11-cell2, cell11-cell12, cell11-cell14, cell11-cell13
    ...    2. Test Case Steps:
    ...        a.Attach UE-81 to the FDD NR cell11 and setup non-GBR SA call
    ...          A1 measurement rsrp and rsrq for TDD with a1ThresholdSCellAddSsbRsrpTDD for SCell Addition
    ...        b.UE sends A1 measurement for SCell Addition,F+F+F+T successfully,A6 meas configed to UE, DRX setup
    ...        c.delay to send RRC Reconfiguration Complete
    ...        d.A6 for scell swap measurement report from 5G-UE,UE Assistance Information received in gnb, but queued
    ...        e.After delay ,scell swap procedure complete and successfully, Scell4 activated successfully,
    ...           then one scell deactivated successfully.
    ...        f.UE exit overheating condition and release successfully
    [Tags]    QC_244333    owner-Tingjian.Mao    B081
    Update UE capa    ${SA_Capa_Support_81}    81
    UE Attach To Target Cell
    Trigger ScellAdd 4CC FFFT
    Trigger ScellSwap and ue enter the Overheated after delay
    UE has recovered from overheating
    UE Deregister From gNB
    Check Wireshark Log    ${CURDIR}${/}a2a_CB008290B081${/}a2a.ini    wait_string=UEContextReleaseComplete::4
    [Teardown]    Teardown

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_2T4F_2N41_2N71_2N66

Update UE capa
    [Arguments]    ${SA_Capa_perUE_Full}=none    ${ue_id}=81
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full}
    Execute Egate Command    ${cmd}

UE Attach To Target Cell
    [Arguments]    ${cell_id}=11    ${ue_id}=81    ${pcell_dl}=30
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    ${ret1}=    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=${gw_id} nwslice=${nwslice}    QoS Routing Table
    Should Contain    ${ret1}    drx-Config setup

Send Throuput
    [Arguments]    ${ue_id}=81
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=3    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=4    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=5    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=6    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=ul mbps=40 trf_id=1    UE ${ue_id}: UDP UL
    sleep    30s    #sleep for stable traffic

Verify Throuput on Pcell and Scell
    sleep    10s     #sleep for stable traffic
    [Arguments]    ${ue_id}=81    ${pcell_dl}=50    ${scell_id}=1    ${scell_dl1}=250    ${scell_dl2}=50    ${scell_dl3}=100    ${ul}=30
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000 > ${pcell_dl}
    ${scell_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${scell_id}    type=pdsch    rate_type=ave
    Should Be True    ${scell_tput}/1000 > ${scell_dl1}
    ${scell_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=2    type=pdsch    rate_type=ave
    Should Be True    ${scell_tput}/1000 > ${scell_dl2}
    ${scell_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=3    type=pdsch    rate_type=ave
    Should Be True    ${scell_tput}/1000 > ${scell_dl3}
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul}

Verify Throuput on Pcell and one scell no traffic
    sleep    10s     #sleep for stable traffic
    [Arguments]    ${ue_id}=81    ${pcell_dl}=50    ${index1}=4    ${scell_dl1}=250    ${index2}=2    ${scell_dl2}=50
    ...    ${index3}=3    ${scell_dl3}=100    ${ul}=30
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000 > ${pcell_dl}
    ${scell_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${index1}    type=pdsch    rate_type=ave
    Should Be True    ${scell_tput}/1000 > ${scell_dl1}
    ${scell_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${index2}    type=pdsch    rate_type=ave
    Should Be True    ${scell_tput} == 0
    ${scell_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${index3}    type=pdsch    rate_type=ave
    Should Be True    ${scell_tput}/1000 > ${scell_dl3}
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul}

UE Deregister From gNB
    [Arguments]    ${ue_id}=81
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s

Trigger ScellAdd 4CC FFFT
    [Arguments]    ${event_type}=A1    ${carrierfreq}=424090    ${srsrp_nr}=100    ${srsrq_nr}=50    ${ue_id}=81    ${phycell_id}=60
    ...    ${pcell_dl}=30    ${scell_dl}=10
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type}
    ...    srsrp_nr=${srsrp_nr} srsrq_nr=${srsrq_nr}
    Execute Egate Command    ${cmd}    pass_regexp=rrcReconfigurationComplete
    Send Throuput
    Verify Throuput on Pcell and Scell

Trigger ScellSwap and hold on
    [Arguments]    ${event_type}=A6    ${carrierfreq}=518910    ${nrsrp_nr}=60    ${nrsrq_nr}=30    ${ue_id}=81    ${scell_id}=1
    ...    ${phycell_id}=50
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type}
    ...    srsrp_nr=11 srsrq_nr=11 scell=${scell_id} scell_rsrp=20 scell_rsrq=20 phycell_id=${phycell_id}
    ...    nrsrp_nr=${nrsrp_nr} nrsrq_nr=${nrsrq_nr}
    Execute Egate Command    ${cmd}    pass_regexp=Hit on error

Trigger ScellSwap and pdu release after delay
    Execute Egate Command    ue_nr_rrc_reconf_param id=${ue_id} if_contains=any delay=3000
    Trigger ScellSwap and hold on
    Execute Egate Command    ue_pdu_session_release ue=${ue_id} by=amf pdu=${pdu_id}    pass_regexp=Successfully released PDU

A6 abort when NGReset
    Execute Egate Command    ue_nr_rrc_reconf_param id=${ue_id} if_contains=any delay=3000
    Trigger ScellSwap and hold on
    Execute Egate Command    link_ng_reset by=amf:1 ue=${ue_id}    pass_regexp=Received NG Reset Acknowledge

A6 abort when RRCReestablishment
    Execute Egate Command    ue_nr_rrc_reconf_param id=${ue_id} if_contains=any delay=3000
    Trigger ScellSwap and hold on
    Execute Egate Command    ue_rrc_reestablish id=${ue_id} gnb=2 cell=11 cause=otherFailure    pass_regexp=rrcReconfigurationComplete

Trigger ScellSwap and ue enter the Overheated after delay
    Execute Egate Command    ue_nr_rrc_reconf_param id=${ue_id} if_contains=any delay=3000
    Trigger ScellSwap and hold on
    Execute Egate Command    ue_assistance_send_nr ue_id=${ue_id} forOverheating=yes reducedCCsDL=2    pass_regexp=deactivated
    Verify Throuput on Pcell and one scell no traffic

UE has recovered from overheating
    [Arguments]    ${ue_id}=81
    Execute Egate Command    ue_assistance_send_nr ue_id=${ue_id} forOverheating=yes    pass_regexp=activated
    sleep    15s    #Wait for scell to activate
    Verify Throuput on Pcell and Scell    scell_id=4

Delay reset
    Execute Egate Command    ue_nr_rrc_reconf_param id=${ue_id} reset

Teardown
    Delay reset
    Common Test Teardown And Stop Capture Logs


