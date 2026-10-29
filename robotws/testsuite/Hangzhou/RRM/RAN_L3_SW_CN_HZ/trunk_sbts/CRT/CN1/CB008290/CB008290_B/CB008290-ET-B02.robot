*** Settings ***
Documentation
...    author:  baijie.zhu@nokia-sbell.com
...    contact: baijie.zhu@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_VRF    RAN_5G_TDD    SBTS00    team-Rock_SGT&A    owner-xiaowen.xu
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
...    @{A1pcellchange}
...    NRCELL:cellDepType=SA
...    delete:NRCELL:configuredEpsTac

...    NRCELL:maxNumScellsDlFr1=3
...    MRBTS-1/NRBTS-1/NRDU-1:carrierAggregationSupportList=${CA_support_list}
...    @{PARAMS_FOR_IODT_ABIO_2T4F}
...    @{same frequency}    @{NRREL}    @{8290_enable}
...    @{HoSA_A2A3A5}    @{actCDrx}
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
...    NRPMRNL-1:miNrIntraGnbMobilitySaPmqap=disabled
...    NRPMRNL-1:miNrIntraGnbMobilityNsaPmqap=disabled
...    NRPMRNL-1:miNrInterGnbNgMobilitySaPmqap=disabled
...    NRPMRNL-1:miNrInterGnbXnMobilitySaPmqap=disabled
...    NRPMRNL-1:miNrInterGnbMobilityNsaPmqap=disabled
...    NRPMRNL-1:miNrNgcFlexInterface=disabled
...    NRCELL:drxProfileNrAnr:nrDrxDN=NRDRX-3
...    MRBTS-1/EQM-1/APEQM-1/RMOD:protocol=NOKIA
...    NRCELL-11/NRREL-5:sCellOperationalMode=dlOnly

@{HoSA_A2A3A5}
...    NRBTS-1:actInterFreqHoSA=true
...    NRBTS-1:actIntraFreqHoSA=true
...    NRPMRNL-1:miNrRelReportCu=15min
...    NRCELL:measGapSelectionSA=favourUeThroughput
...    NRCELL:a1MeashoEnabledSA=rsrp
...    NRCELL:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRCELL:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=39
...    NRCELL:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms128
...    NRCELL:a2MeashoEnabledSA=rsrp
...    NRCELL:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=1
...    NRCELL:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=34
...    NRCELL:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms160
...    NRCELL:a1MeashoSsbRsrqSA:a1HysteresishoSsbRsrqSA=4
...    NRCELL:a1MeashoSsbRsrqSA:a1ThresholdhoSsbRsrqSA=33
...    NRCELL:a1MeashoSsbRsrqSA:a1TimeToTriggerhoSsbRsrqSA=ms40
...    NRCELL:a2MeashoSsbRsrqSA:a2HysteresishoSsbRsrqSA=20
...    NRCELL:a2MeashoSsbRsrqSA:a2ThresholdhoSsbRsrqSA=40
...    NRCELL:a2MeashoSsbRsrqSA:a2TimeToTriggerhoSsbRsrqSA=ms80
...    NRCELL:a3MeasEnabled=rsrp
...    NRCELL:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRCELL:a3MeasSsbRsrp:a3OffsetSsbRsrp=15
...    NRCELL:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms40
...    NRCELL:a5MeasEnabled=rsrp
...    NRCELL:a5MeasSsbRsrp:a5HysteresisSsbRsrp=0
...    NRCELL:a5MeasSsbRsrp:a5Threshold1SsbRsrp=50
...    NRCELL:a5MeasSsbRsrp:a5Threshold2SsbRsrp=60
...    NRCELL:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms40
...    NRCELL:absThreshSsbRsrpConsolidation=1
...    NRCELL:sMeasConfigSsbRsrp=1

...    NRCELL-11/NRHOIF-1:freqBandIndicatorNR=71
...    NRCELL-11/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-11/NRHOIF-1:ifhoSsbSmtcDuration=sf2
...    NRCELL-11/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-11/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-11/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-11/NRHOIF-1:ssbFrequency=127450
...    NRCELL-11/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms480
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=30
...    NRCELL-11/NRHOIF-1:a5MeasEnabled=rsrp
...    NRCELL-11/NRHOIF-1:a5MeasSsbRsrp:a5HysteresisSsbRsrp=10
...    NRCELL-11/NRHOIF-1:a5MeasSsbRsrp:a5Threshold1SsbRsrp=30
...    NRCELL-11/NRHOIF-1:a5MeasSsbRsrp:a5Threshold2SsbRsrp=55
...    NRCELL-11/NRHOIF-1:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms0

...    NRCELL-13/NRHOIF-1:freqBandIndicatorNR=71
...    NRCELL-13/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-13/NRHOIF-1:ifhoSsbSmtcDuration=sf2
...    NRCELL-13/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-13/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-13/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-13/NRHOIF-1:ssbFrequency=127450
...    NRCELL-13/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-13/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms480
...    NRCELL-13/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0    NRCELL-13/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=30
...    NRCELL-13/NRHOIF-1:a5MeasEnabled=rsrp
...    NRCELL-13/NRHOIF-1:a5MeasSsbRsrp:a5HysteresisSsbRsrp=10
...    NRCELL-13/NRHOIF-1:a5MeasSsbRsrp:a5Threshold1SsbRsrp=30
...    NRCELL-13/NRHOIF-1:a5MeasSsbRsrp:a5Threshold2SsbRsrp=55
...    NRCELL-13/NRHOIF-1:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms0

${CA_support_list}    ca_Fdd_Fdd,ca_Fdd_Fr1Tdd_Sa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fdd_Any_Sa,ca_Fr1Tdd_Any_Sa

@{8290_enable}
...    NRDU-1:actInterNumerologyCa=true
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRBTS-1:actCarrierAggregation=true
...    NRBTS-1:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS-1:caConfigurationSupport=2CCDL_2CCUL
...    NRBTS-1:actSCellSwapFr1=a6BasedSa
...    NRBTS-1:sCellActivationMethod=bufferBased

...    NRCELL-1:a6MeasSCellSwapEnabled=rsrp
...    NRCELL-2:a6MeasSCellSwapEnabled=rsrq
...    NRCELL-11:a6MeasSCellSwapEnabled=rsrpAndRsrq
...    NRCELL-12:a6MeasSCellSwapEnabled=rsrqCombined
...    NRCELL-13:a6MeasSCellSwapEnabled=rsrq
...    NRCELL-14:a6MeasSCellSwapEnabled=rsrpCombined
...    NRCELL:a6MeasSCellSwapSsbRsrp:a6HysteresisSCellSwapSsbRsrp=0|a6OffsetSCellSwapSsbRsrp=20|a6TimeToTrigSCellSwapSsbRsrp=ms480
...    NRCELL:a6MeasSCellSwapSsbRsrq:a6HysteresisSCellSwapSsbRsrq=0|a6OffsetSCellSwapSsbRsrq=20|a6TimeToTrigSCellSwapSsbRsrq=ms480
...    NRCELL:reportAmountA6MeasSCellSwap=r4
...    NRCELL:reportIntervalA6MeasSCellSwap=ms1024
...    NRCELL:thresholdSCellSwapSourceRsrp=66
...    NRCELL:thresholdSCellSwapSourceRsrq=67
...    NRCELL:a1MeasSCellAddEnabled=rsrpAndRsrq
...    NRCELL:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=70|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=90|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrq:a1HysteresisSCellAddSsbRsrq=0|a1TimeToTriggerSCellAddSsbRsrq=320ms
...    NRCELL:a1MeasSCellAddSsbRsrq:a1ThresholdSCellAddSsbRsrq=30|a1TimeToTriggerSCellAddSsbRsrq=320ms
...    NRCELL:weightForSCellSelection=50
...    NRCELL:a2MeasSCellRelEnabled=rsrp
...    NRCELL:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=2560ms
...    NRCELL:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=34
...    NRCELL:a2MeasRedirectSsbRsrq:a2HysteresisRedirectSsbRsrq=2
...    NRCELL:a2MeasRedirectSsbRsrp:a2HysteresisRedirectSsbRsrp=2

@{same frequency}
...    MRBTS-1/NRBTS-1/NRCELL-11:gscnOrSsPbchArfcn=5300
...    MRBTS-1/NRBTS-1/NRCELL-11/NRCELL_FDD-1:nrarfcnDl=424000
...    MRBTS-1/NRBTS-1/NRCELL-11/NRCELL_FDD-1:nrarfcnUl=344000
...    MRBTS-1/NRBTS-1/NRCELL-11/NRCELL_FDD-1:chBwDl=10MHz
...    MRBTS-1/NRBTS-1/NRCELL-11/NRCELL_FDD-1:chBwUl=10MHz

...    MRBTS-1/NRBTS-1/NRCELL-13:gscnOrSsPbchArfcn=5300
...    MRBTS-1/NRBTS-1/NRCELL-13/NRCELL_FDD-1:nrarfcnDl=424000
...    MRBTS-1/NRBTS-1/NRCELL-13/NRCELL_FDD-1:nrarfcnUl=344000
...    MRBTS-1/NRBTS-1/NRCELL-13/NRCELL_FDD-1:chBwDl=10MHz
...    MRBTS-1/NRBTS-1/NRCELL-13/NRCELL_FDD-1:chBwUl=10MHz

...    MRBTS-1/NRBTS-1/NRCELL-12:gscnOrSsPbchArfcn=1592
...    MRBTS-1/NRBTS-1/NRCELL-12/NRCELL_FDD-1:nrarfcnDl=127420
...    MRBTS-1/NRBTS-1/NRCELL-12/NRCELL_FDD-1:nrarfcnUl=136620
...    MRBTS-1/NRBTS-1/NRCELL-12/NRCELL_FDD-1:chBwDl=10MHz
...    MRBTS-1/NRBTS-1/NRCELL-12/NRCELL_FDD-1:chBwUl=10MHz

...    MRBTS-1/NRBTS-1/NRCELL-14:gscnOrSsPbchArfcn=1592
...    MRBTS-1/NRBTS-1/NRCELL-14/NRCELL_FDD-1:nrarfcnDl=127420
...    MRBTS-1/NRBTS-1/NRCELL-14/NRCELL_FDD-1:nrarfcnUl=136620
...    MRBTS-1/NRBTS-1/NRCELL-14/NRCELL_FDD-1:chBwDl=10MHz
...    MRBTS-1/NRBTS-1/NRCELL-14/NRCELL_FDD-1:chBwUl=10MHz


@{A1pcellchange}
...    MRBTS-1/NRBTS-1:actHoOptimizationCa=true
...    NRCELL-11/NRHOIF-1:a1BasedPCellSwitchEnabled=true
...    NRCELL-13/NRHOIF-1:a1BasedPCellSwitchEnabled=true
...    NRCELL:a1MeasPCellSwitchEnabled=rsrp
...    NRCELL:a1MeasPCellSwitchSsbRsrp:a1HysteresisPCellSwitchSsbRsrp=0|a1ThresholdPCellSwitchSsbRsrp=50|a1TimeToTriggerPCellSwitchSsbRsrp=0ms

@{actCDrx}
...    NRCELL:actCDrx=false
...    NRCELL-11:actCDrx=true
...    NRCELL-11:drxProfileNrAnr:drxControl=interRATeUTRA
#...    NRCELL-11:drxProfileNrAnr:drxInactivityTimer=80ms
#...    NRCELL-11:drxProfileNrAnr:drxLongCycle=320ms
#...    NRCELL-11:drxProfileNrAnr:drxOnDurationTimer=20ms
#...    NRCELL-11:drxProfileNrAnr:drxRetransTimerDl=0slot
#...    NRCELL-11:drxProfileNrAnr:drxRetransTimerUl=0slot

@{NRREL}
...    NRCELL-13/NRREL-4:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-13/NRREL-4:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-13/NRREL-4:gNbId=1
...    NRCELL-13/NRREL-4:gNbIdLength=22
...    NRCELL-13/NRREL-4:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-4:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-4:gnbPlmn:mncLength=3
...    NRCELL-13/NRREL-4:removeNotAllowed=false
...    NRCELL-13/NRREL-4:lcrId=14
...    NRCELL-13/NRREL-4:sCellPrio=2
...    NRCELL-13/NRREL-4:handoverAllowedSA=allowed
...    NRCELL-13/NRREL-4:sCellAdditionMethod=covBasedA1
...    NRCELL-13/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-13/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-13/NRREL-3:gNbId=1
...    NRCELL-13/NRREL-3:gNbIdLength=22
...    NRCELL-13/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-13/NRREL-3:removeNotAllowed=false
...    NRCELL-13/NRREL-3:lcrId=12
...    NRCELL-13/NRREL-3:sCellPrio=1
...    NRCELL-13/NRREL-3:handoverAllowedSA=allowed
...    NRCELL-13/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-13/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-13/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-13/NRREL-2:gNbId=1
...    NRCELL-13/NRREL-2:gNbIdLength=22
...    NRCELL-13/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-13/NRREL-2:removeNotAllowed=false
...    NRCELL-13/NRREL-2:lcrId=2
...    NRCELL-13/NRREL-2:sCellPrio=2
...    NRCELL-13/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-13/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-13/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-13/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-13/NRREL-1:gNbId=1
...    NRCELL-13/NRREL-1:gNbIdLength=22
...    NRCELL-13/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-13/NRREL-1:removeNotAllowed=false
...    NRCELL-13/NRREL-1:lcrId=1
...    NRCELL-13/NRREL-1:sCellPrio=1
...    NRCELL-13/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-13/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-4:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-4:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-4:gNbId=1
...    NRCELL-12/NRREL-4:gNbIdLength=22
...    NRCELL-12/NRREL-4:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-4:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-4:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-4:removeNotAllowed=false
...    NRCELL-12/NRREL-4:lcrId=13
...    NRCELL-12/NRREL-4:sCellPrio=2
...    NRCELL-12/NRREL-4:handoverAllowedSA=allowed
...    NRCELL-12/NRREL-4:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-3:gNbId=1
...    NRCELL-12/NRREL-3:gNbIdLength=22
...    NRCELL-12/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-3:removeNotAllowed=false
...    NRCELL-12/NRREL-3:lcrId=11
...    NRCELL-12/NRREL-3:sCellPrio=1
...    NRCELL-12/NRREL-3:handoverAllowedSA=allowed
...    NRCELL-12/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-2:gNbId=1
...    NRCELL-12/NRREL-2:gNbIdLength=22
...    NRCELL-12/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-2:removeNotAllowed=false
...    NRCELL-12/NRREL-2:lcrId=2
...    NRCELL-12/NRREL-2:sCellPrio=2
...    NRCELL-12/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-12/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-1:gNbId=1
...    NRCELL-12/NRREL-1:gNbIdLength=22
...    NRCELL-12/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-1:removeNotAllowed=false
...    NRCELL-12/NRREL-1:lcrId=1
...    NRCELL-12/NRREL-1:sCellPrio=1
...    NRCELL-12/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-12/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-5:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-5:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-5:gNbId=1
...    NRCELL-11/NRREL-5:gNbIdLength=22
...    NRCELL-11/NRREL-5:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-5:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-5:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-5:removeNotAllowed=false
...    NRCELL-11/NRREL-5:lcrId=13
...    NRCELL-11/NRREL-5:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-4:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-4:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-4:gNbId=1
...    NRCELL-11/NRREL-4:gNbIdLength=22
...    NRCELL-11/NRREL-4:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-4:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-4:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-4:removeNotAllowed=false
...    NRCELL-11/NRREL-4:lcrId=14
...    NRCELL-11/NRREL-4:sCellPrio=2
...    NRCELL-11/NRREL-4:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-4:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-3:gNbId=1
...    NRCELL-11/NRREL-3:gNbIdLength=22
...    NRCELL-11/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-3:removeNotAllowed=false
...    NRCELL-11/NRREL-3:lcrId=12
...    NRCELL-11/NRREL-3:sCellPrio=1
...    NRCELL-11/NRREL-3:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-2:gNbId=1
...    NRCELL-11/NRREL-2:gNbIdLength=22
...    NRCELL-11/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-2:removeNotAllowed=false
...    NRCELL-11/NRREL-2:lcrId=2
...    NRCELL-11/NRREL-2:sCellPrio=2
...    NRCELL-11/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-1:gNbId=1
...    NRCELL-11/NRREL-1:gNbIdLength=22
...    NRCELL-11/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-1:removeNotAllowed=false
...    NRCELL-11/NRREL-1:lcrId=1
...    NRCELL-11/NRREL-1:sCellPrio=1
...    NRCELL-11/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-1:sCellAdditionMethod=covBasedA1
...    delete:NRCELL-11/NRREL-10
...    delete:NRCELL-13/NRREL-10

...    NRCELL-11/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-3:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-4:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-5:sCellOperationalMode=dlOnly
...    NRCELL-12/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-12/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-12/NRREL-3:sCellOperationalMode=dlOnly
...    NRCELL-12/NRREL-4:sCellOperationalMode=dlOnly
...    NRCELL-13/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-13/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-13/NRREL-3:sCellOperationalMode=dlOnly
...    NRCELL-13/NRREL-4:sCellOperationalMode=dlOnly

#SA_Capa_Full: TDD: n41 n78  FDD: n66 n71
#3CC: n41+n78+n66  n41+n66+n71   n41+n66+n66  n41+n71+n71  n66+n66+n71  n66+n71+n71 n78+n66+n71
#2CC: n66+n71 n41+n71 n41+n78 n41+n66 n66+n71 n66+n78 n78+n71
#nr-CGI-Reporting supported
${SA_Capa_perUE_Full_ANR}    SEPARATOR=
...    E9A09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C4700FB8D85181AC1184341020E9068036B64C558D0E
...    7C471E819F604F8C48E3C873EA39F30C7942C0E070F05C00FFC0070005F0005C0000E0541B107582308682041E20D00656C98AB121CFB027C4
...    71E31238F21CFA8E7CC31E50B0381C3C27F6000001FD800000170000381546C4DD608C21A0810748340185B262A88873E238F11C7A067D813E
...    31CF9863CA1607038782E007FE003801FF8002E0000702A0D88DAC1184341020F1068032B64C55890E7C471EC09F1891C790E7D473E618F285
...    81C0E1E13FFE00000FFF800000B80001C00F78789A001C4100000216020541E14000711800000858158788C001C41000006160561E14000710
...    400000858158789A001C46000002160562E2300071040038820000142C0AC3C28000E268000060B02B17134003882001C28000008160562E26
...    800711800388C0000082C0AC5C28000E20800711800001058158B850001C41000E208000020B02B17134003882001C46000004160562E14000
...    711800388C0000082C0AC5C4D000E2300070A000002058158788C001C46000006160401C046805101360208BA005D83E14489B1CF870A244D8
...    E7C3851226C73E1C28913639F0E14489B1CF871224489B1CF870A040D8E7C08902040D8E7C08902040D8E7C08902040D8E7C08902040D8E7C0
...    8902040D8E7C08902040D8E7C08902040D8E7C0850206C73E000B878C6318C6318C6318C630F417001F00140E0A00E06012803800301200203
...    01F04801000000008000010040000000200000401000004008000030040000200200001401000802008020000180100000E008004000000100
...    001000800009004000018020000280100001600800409024010000180672A6B2A6B052B032B066B056B296B266B016B036B012B022B07681A0
...    800004B29282000032CA4A0800014B29202000072CA480800024B292020000B2CA480800034B292020000F2CA480800044B29202000132CA48
...    0800054B29202000172CA4A0800064B29202000062CA480669555D2AAAA55174AA2A82C55058AA0D154A62A93455018AA051549AAA83C50B00
...    BC04A8140A05028140A05028140A05028140A05028140A000C10100C018040080108080100402018030804008010100C018040300608080600
...    C02018030804008010100C018040080110080600C02018030080600C10100200804008021AA1F000102030406070A0B0C0D101112131418191
...    B1C1D1F2125262728292A2D2F414182D

@{ANR_gnb}
...    NRBTS:actSaUeBasedAnrNr=true
...    NRBTS:actDedicatedAnrDrxProfile=true
...    NRBTS:actSaIntraFreqAnrDrxProf=true
...    NRANR-1:actAutoEutraNbRemoval=false
...    NRANR-1:actAutoNrNbRemoval=true
...    NRANR-1:consecHoFailThres=0
...    NRANR-1:consecHoFailThresEutra=3
...    NRANR-1:consecXnResolveFailThres=3
...    NRANR-1:gNbIdLengthConfig:gNbIdLength=22
...    NRANR-1:gNbIdLengthConfig:priorityIndex=1
...    NRANR-1:nrAnrId=1
...    NRANRPR-1:anrThresholdSelector=RSRP
...    NRANRPR-1:anrThresRsrpNbCell=-90
...    NRANRPR-1:anrThresRsrqNbCell=-12
...    NRANRPR-1:cellDepMode=SA+NSA
...    NRANRPR-1:consecRecheckForNrNbRemoval=5
...    NRANRPR-1:idleTimeForNrNbRemoval=72
...    NRANRPR-1:maxNumAnrNrrelAllowed=50
...    NRANRPR-1:nrAnrPrId=1
...    NRBTS:actSaUeBasedInterFreqAnrNr=false
...    NRANRPR-2:anrThresholdSelector=RSRP
...    NRANRPR-2:anrThresRsrpNbCell=-90
...    NRANRPR-2:anrThresRsrqNbCell=-12
...    NRANRPR-2:cellDepMode=SA+NSA
...    NRANRPR-2:consecRecheckForNrNbRemoval=5
...    NRANRPR-2:idleTimeForNrNbRemoval=72
...    NRANRPR-2:maxNumAnrNrrelAllowed=50
...    NRANRPR-2:nrAnrPrId=2
...    NRANRPR-2:nrarfcn=364000
...    NRANRPR-2:ssbFrequency=363850
...    NRCELL-11:drxProfileNrAnr:drxControl=any
#...    NRCELL-11:drxProfileNrAnr:drxInactivityTimer=80ms
#...    NRCELL-11:drxProfileNrAnr:drxLongCycle=320ms
#...    NRCELL-11:drxProfileNrAnr:drxOnDurationTimer=20ms
#...    NRCELL-11:drxProfileNrAnr:drxRetransTimerDl=0slot
#...    NRCELL-11:drxProfileNrAnr:drxRetransTimerUl=0slot
...    delete:NRCELL-11/NRREL-5

@{ANR_ho_succ}
...    drx-Config setup
...    cellForWhichToReportCGI 62
...    Intra-eNB handover from EXT_ENB-2.11 to EXT_ENB-2.13 performed
...    pcid:62, scellIdx:0
...    pcid:50, scellIdx:1
...    pcid:61, scellIdx:2
...    SCellIndex 1 activated successfully at airphone
...    SCellIndex 2 activated successfully at airphone

@{ho_succ_without_ANR}
...    Intra-eNB handover from EXT_ENB-2.11 to EXT_ENB-2.13 performed
...    pcid:62, scellIdx:0
...    pcid:50, scellIdx:1
...    pcid:61, scellIdx:2
...    SCellIndex 1 activated successfully at airphone
...    SCellIndex 2 activated successfully at airphone

${pdu_id}    1
${gw_id}    1
${nwslice}    1

*** Test Cases ***
CB008290-ET-B02 Verify_A6_scell_swap_successfully_for_FFT
    [Documentation]
    ...    1. This user scenario describes A6 configuration and swap with 3cc interworking
    ...    configuration: 2T4F, cell1 and cell2 same Frequency, cell11 and cell13 same Frequency, cell12 and cell14 same Frequency
    ...    2. Test Steps
    ...    UE attach to cell 11
    ...    A1MR to trigger Scelladdition T1,F12 , to FFT CA
    ...    to do A6 scell swap for TDD scell, FDD scell , repeat 5 times
    ...    to do A3 intra Fre HO to cell13 from cell11 ,ca FFT auto
    ...    to do A1PCELL switch to cell12 from cell 13 ,ca FFT auto
    ...    to do scell swap for TDD scell, FDD scell , repeat 5 times
    ...    A2MR trigger release TDD scell , A1 scell change should configured
    ...    A2MR trigger release Fdd scell , A1 scell change deconfigured , A1scell addition should be configured
    ...    release UE
    ...    And the Intra gnb intra fre HO With ANR scenario.
    [Tags]    owner-xiaowen.xu    B02    QC_47045
    ue attach and trigger scell addition
    Trigger Scell Swap on Pcell 11
    Trigger A3MR    event_type=A3    carrierfreq=424090    srsrp_nr=100    srsrq_nr=80    ue_id=81    phycell_id=62
    Verify Throuput For FFT    scellT_id=1    scellF_id=2
    Trigger A1pcellswitch or A2scellrelease    scell_index=2    scell_rsrp=100    scell_rsrq=80
    Trigger Scell Swap on Pcell 12
    Release scells and deregister ue
    Intra gnb intra fre HO With ANR
    Check Wireshark Log    ${CURDIR}${/}a2a_CB008290B02${/}a2a.ini    wait_string=UEContextReleaseComplete::8

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_2T4F_2N41_2N71_2N66

Intra gnb intra fre HO With ANR
    Delta Commission Parameters    ${ANR_gnb}
    Cells Should Be OnAir
    Execute Egate Command    ue_param id=81 ue_nr_capabilities=${SA_Capa_perUE_Full_ANR}
    ue attach and trigger scell addition
    Trigger A3MR    event_type=A3    carrierfreq=424090    srsrp_nr=100    srsrq_nr=80    ue_id=81    phycell_id=62
    ...    ho_succ=${ANR_ho_succ}
    UE Deregister From gNB    81

ue attach and trigger scell addition
    ue attach to target cell    cell_id=11    ue_id=81
    trigger mr     event_type=A1    carrierfreq=424090    srsrp_nr=100    srsrq_nr=80    ue_id=81
    Send Throuput
    Verify Throuput For FFT    scellT_id=1    scellF_id=2

Trigger A1pcellswitch or A2scellrelease
    [Arguments]    ${event_type}=A1    ${carrierfreq}=127450    ${scell_index}=1    ${ue_id}=81    ${scell_rsrp}=10    ${scell_rsrq}=10
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} event=${event_type} meas_id=${meas_id} srsrp_nr=60 srsrq_nr=60
    ...    scell=${scell_index} scell_rsrp=${scell_rsrp} scell_rsrq=${scell_rsrq}
    Execute Egate Command    ${cmd}    pass_regexp=rrcReconfigurationComplete

Release scells and deregister ue
    Release TDD scell and A1 for scell change configured
    Release FDD scell and A1 for scell addition configured
    UE Deregister From gNB    81

Release TDD scell and A1 for scell change configured
    [Arguments]    ${ue_id}=81
    Trigger A1pcellswitch or A2scellrelease     event_type=A2    carrierfreq=518910    scell_index=2    ue_id=81
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=A1    carrierfreq=127450    threshold=90
    Verify Throuput For FF    scellF1_id=3

Release FDD scell and A1 for scell addition configured
    [Arguments]    ${ue_id}=81
    Trigger A1pcellswitch or A2scellrelease     event_type=A2    carrierfreq=424090    scell_index=3    ue_id=81
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=A1    carrierfreq=127450    threshold=70
    Verify Throuput For FF    scellF1_id=0

UE Attach To Target Cell
    [Arguments]    ${cell_id}=11    ${ue_id}=81
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=${gw_id} nwslice=${nwslice}    QoS Routing Table

UE Deregister From gNB
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s

Trigger MR
    [Arguments]    ${event_type}=A2    ${carrierfreq}=518910    ${srsrp_nr}=5    ${srsrq_nr}=5    ${ue_id}=81    ${phycell_id}=62
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${phycell}    Catenate    phycell_id=${phycell_id} nrsrp_nr=110 nrsrq_nr=100
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type}
    ...    srsrp_nr=${srsrp_nr} srsrq_nr=${srsrq_nr}
    Execute Egate Command    ${cmd}     pass_regexp=rrcReconfigurationComplete

Trigger A3MR
    [Arguments]    ${event_type}=A2    ${carrierfreq}=518910    ${srsrp_nr}=5    ${srsrq_nr}=5    ${ue_id}=81    ${phycell_id}=62
    ...    ${ho_succ}=${ho_succ_without_ANR}
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${phycell}    Catenate    phycell_id=${phycell_id} nrsrp_nr=110 nrsrq_nr=100
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type}
    ...    srsrp_nr=${srsrp_nr} srsrq_nr=${srsrq_nr}
    ${cmd_1}    Catenate    ${cmd} ${phycell}
    Execute Egate Command    ${cmd_1}    pass_regexp=${ho_succ}

Trigger A6swap
    [Arguments]    ${carrierfreq}=518910    ${scell_index}=1    ${phycell_id}=51    ${ue_id}=81
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=A6    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} event=A6 meas_id=${meas_id} srsrp_nr=60 srsrq_nr=60
    ...    scell=${scell_index} scell_rsrp=10 scell_rsrq=10 phycell_id=${phycell_id} nrsrp_nr=60 nrsrq_nr=60
    Execute Egate Command    ${cmd}    pass_regexp=sCellToReleaseList

Trigger Scell Swap on Pcell 11
    trigger a6swap    carrierfreq=518910    scell_index=1    phycell_id=51    ue_id=81    #1->3
    Verify Throuput For FFT    scellT_id=3    scellF_id=2
    trigger a6swap    carrierfreq=127450    scell_index=2    phycell_id=63    ue_id=81    #2->1
    Verify Throuput For FFT    scellT_id=3    scellF_id=1
    trigger a6swap    carrierfreq=518910    scell_index=3    phycell_id=50    ue_id=81    #3->2
    Verify Throuput For FFT    scellT_id=2    scellF_id=1
    trigger a6swap    carrierfreq=127450    scell_index=1    phycell_id=61    ue_id=81    #1->3
    Verify Throuput For FFT    scellT_id=2    scellF_id=3
    Trigger Scell Swap on Pcell 11 part2
    Trigger Scell Swap on Pcell 11 part3

Trigger Scell Swap on Pcell 11 part2
    trigger a6swap    carrierfreq=518910    scell_index=2    phycell_id=51    ue_id=81    #2->1
    Verify Throuput For FFT    scellT_id=1    scellF_id=3
    trigger a6swap    carrierfreq=127450    scell_index=3    phycell_id=63    ue_id=81    #3->2
    Verify Throuput For FFT    scellT_id=1    scellF_id=2
    trigger a6swap    carrierfreq=518910    scell_index=1    phycell_id=50    ue_id=81    #1->3
    Verify Throuput For FFT    scellT_id=3    scellF_id=2
    trigger a6swap    carrierfreq=127450    scell_index=2    phycell_id=61    ue_id=81    #2->1
    Verify Throuput For FFT    scellT_id=3    scellF_id=1

Trigger Scell Swap on Pcell 11 part3
    trigger a6swap    carrierfreq=518910    scell_index=3    phycell_id=51    ue_id=81    #3->2
    Verify Throuput For FFT    scellT_id=2    scellF_id=1
    trigger a6swap    carrierfreq=127450    scell_index=1    phycell_id=63    ue_id=81    #1->3
    Verify Throuput For FFT    scellT_id=2    scellF_id=3

Trigger Scell Swap on Pcell 12
    Verify Throuput For FFT    scellT_id=1    scellF_id=2
    trigger a6swap    carrierfreq=518910    scell_index=1    phycell_id=51    ue_id=81    #1->3
    Verify Throuput For FFT    scellT_id=3    scellF_id=2
    trigger a6swap    carrierfreq=424090    scell_index=2    phycell_id=62    ue_id=81    #2->1
    Verify Throuput For FFT    scellT_id=3    scellF_id=1
    trigger a6swap    carrierfreq=518910    scell_index=3    phycell_id=50    ue_id=81    #3->2
    Verify Throuput For FFT    scellT_id=2    scellF_id=1
    Trigger Scell Swap on Pcell 12 part2
    Trigger Scell Swap on Pcell 12 part3

Trigger Scell Swap on Pcell 12 part2
    trigger a6swap    carrierfreq=424090    scell_index=1    phycell_id=60    ue_id=81    #1->3
    Verify Throuput For FFT    scellT_id=2    scellF_id=3
    trigger a6swap    carrierfreq=518910    scell_index=2    phycell_id=51    ue_id=81    #2->1
    Verify Throuput For FFT    scellT_id=1    scellF_id=3
    trigger a6swap    carrierfreq=424090    scell_index=3    phycell_id=62    ue_id=81    #3->2
    Verify Throuput For FFT    scellT_id=1    scellF_id=2

Trigger Scell Swap on Pcell 12 part3
    trigger a6swap    carrierfreq=518910    scell_index=1    phycell_id=50    ue_id=81    #1->3
    Verify Throuput For FFT    scellT_id=3    scellF_id=2
    trigger a6swap    carrierfreq=424090    scell_index=2    phycell_id=60    ue_id=81    #2->1
    Verify Throuput For FFT    scellT_id=3    scellF_id=1
    trigger a6swap    carrierfreq=518910    scell_index=3    phycell_id=51    ue_id=81    #3->2
    Verify Throuput For FFT    scellT_id=2    scellF_id=1
    trigger a6swap    carrierfreq=424090    scell_index=1    phycell_id=62    ue_id=81    #1->3
    Verify Throuput for FFT    scellT_id=2    scellF_id=3

Send Throuput
    [Arguments]    ${ue_id}=81
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=3    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=4    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=50 trf_id=5    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=ul mbps=10 trf_id=1    UE ${ue_id}: UDP UL
    sleep    30s    #sleep for stable traffic

Verify Throuput For FFT
    [Arguments]    ${ue_id}=81    ${pcell_dl}=60    ${scell_dl_T}=200    ${scell_dl_F}=50    ${ul}=8    ${scellT_id}=2    ${scellF_id}=2
    sleep    10s     #sleep for stable traffic
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000 > ${pcell_dl}
    ${scellT_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${scellT_id}    type=pdsch    rate_type=ave
    Should Be True    ${scellT_tput}/1000 > ${scell_dl_T}
    ${scellF_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${scellF_id}    type=pdsch    rate_type=ave
    Should Be True    ${scellF_tput}/1000 > ${scell_dl_F}
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul}

Verify Throuput For FF
    [Arguments]    ${ue_id}=81    ${pcell_dl}=60    ${scell_dl_F}=50    ${ul}=8    ${scellF1_id}=2
    sleep    10s     #sleep for stable traffic
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000 > ${pcell_dl}
    ${scellF1_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${scellF1_id}    type=pdsch    rate_type=ave
    Should Be True    ${scellF1_tput}/1000 > ${scell_dl_F}
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul}
