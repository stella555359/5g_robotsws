*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    RAN_5G_TDD    SBTS00    team-Blues_SGT&A    owner-ha.zheng
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
...    @{A1pcellchange}
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
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-1:gNbId=1
...    NRCELL-11/NRREL-1:gNbIdLength=22
...    NRCELL-11/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-1:removeNotAllowed=false
...    NRCELL-11/NRREL-1:lcrId=1
...    NRCELL-11/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-1:sCellPrio=1
...    NRCELL-11/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-2:gNbId=1
...    NRCELL-11/NRREL-2:gNbIdLength=22
...    NRCELL-11/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-2:removeNotAllowed=false
...    NRCELL-11/NRREL-2:lcrId=2
...    NRCELL-11/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-2:sCellPrio=2
...    NRCELL-11/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-3:gNbId=1
...    NRCELL-11/NRREL-3:gNbIdLength=22
...    NRCELL-11/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-3:removeNotAllowed=false
...    NRCELL-11/NRREL-3:lcrId=12
...    NRCELL-11/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-3:sCellPrio=1
...    NRCELL-11/NRREL-4:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-4:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-4:gNbId=1
...    NRCELL-11/NRREL-4:gNbIdLength=22
...    NRCELL-11/NRREL-4:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-4:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-4:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-4:removeNotAllowed=false
...    NRCELL-11/NRREL-4:lcrId=14
...    NRCELL-11/NRREL-4:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-4:sCellPrio=2
...    NRCELL-11/NRREL-5:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-5:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-5:gNbId=1
...    NRCELL-11/NRREL-5:gNbIdLength=22
...    NRCELL-11/NRREL-5:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-5:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-5:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-5:removeNotAllowed=false
...    NRCELL-11/NRREL-5:lcrId=13
...    NRCELL-11/NRREL-5:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-5:sCellPrio=1
...    NRCELL:maxNumScellsDlFr1=3
...    NRBTS-1:maxNumScellsDl=3
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-1:gNbId=1
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-1:removeNotAllowed=false
...    NRCELL-1/NRREL-1:lcrId=12
...    NRCELL-1/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-1:sCellPrio=1
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-2:gNbId=1
...    NRCELL-1/NRREL-2:gNbIdLength=22
...    NRCELL-1/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-2:removeNotAllowed=false
...    NRCELL-1/NRREL-2:lcrId=14
...    NRCELL-1/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-2:sCellPrio=2
...    NRCELL-1/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-3:gNbId=1
...    NRCELL-1/NRREL-3:gNbIdLength=22
...    NRCELL-1/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-3:removeNotAllowed=false
...    NRCELL-1/NRREL-3:lcrId=11
...    NRCELL-1/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-3:sCellPrio=1
...    NRCELL-1/NRREL-4:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-4:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-4:gNbId=1
...    NRCELL-1/NRREL-4:gNbIdLength=22
...    NRCELL-1/NRREL-4:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-4:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-4:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-4:removeNotAllowed=false
...    NRCELL-1/NRREL-4:lcrId=2

@{8290_enable}
...    NRDU-1:actInterNumerologyCa=true
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRBTS-1:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS-1:actMeasBasedSCellAdditionNsa=true
...    NRBTS-1:actSCellSwapFr1=a6BasedSa
...    NRBTS-1:actRanSharing=false
...    NRCELL:actCDrx=true
...    NRCELL:actPrachMultiplexing=true
...    NRCELL:actBeamforming=false
...    NRBTS-1:actFdmScheduling=true

...    NRBTS-1:sCellActivationMethod=bufferBased
...    NRCELL:sCellDeactivationTimerGNB=ms1280
...    NRCELL:cellDepType=SA+NSA
#...    NRCELL:actK1OptForDPA=true
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
#...    NRCELL:a5MeasEnabled=rsrp
#...    NRCELL:a5MeasSsbRsrp:a5HysteresisSsbRsrp=0|a5Threshold1SsbRsrp=20|a5Threshold2SsbRsrp=40|a5TimeToTriggerSsbRsrp=ms64
...    NRCELL:a2MeasSCellRelEnabled=rsrp
...    NRCELL:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2ThresholdSCellRelSsbRsrp=34|a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-12:weightForSCellSelection=50
...    NRCELL-14:weightForSCellSelection=50
...    NRCELL-11:weightForSCellSelection=60
...    NRCELL-13:weightForSCellSelection=60
...    NRCELL-1:weightForSCellSelection=80
...    NRCELL-2:weightForSCellSelection=80
...    NRDU-1:carrierAggregationSupportList=ca_Fdd_Fdd,ca_Fdd_Fr1Tdd_Sa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fdd_Any_Sa,ca_Fr1Tdd_Any_Sa

@{same frequency}
...    MRBTS-1/NRBTS-1/NRCELL-12:gscnOrSsPbchArfcn=1592
...    MRBTS-1/NRBTS-1/NRCELL-12/NRCELL_FDD-1:nrarfcnDl=127420
...    MRBTS-1/NRBTS-1/NRCELL-12/NRCELL_FDD-1:nrarfcnUl=136620
...    MRBTS-1/NRBTS-1/NRCELL-12/NRCELL_FDD-1:chBwDl=10MHz
...    MRBTS-1/NRBTS-1/NRCELL-12/NRCELL_FDD-1:chBwUl=10MHz
...    MRBTS-1/NRBTS-1/NRCELL-12:type0CoresetConfigurationIndex=8
...    MRBTS-1/NRBTS-1/NRCELL-13/NRCELL_FDD-1:chBwDl=10MHz
...    MRBTS-1/NRBTS-1/NRCELL-13/NRCELL_FDD-1:chBwUl=10MHz
...    MRBTS-1/NRBTS-1/NRCELL-13:type0CoresetConfigurationIndex=8
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

@{Result_4cc}
...    rrcReconfigurationComplete
...    pcid:62, scellIdx:3
...    pcid:61, scellIdx:2
...    pcid:50, scellIdx:1
...    SCellIndex 1 activated successfully
...    SCellIndex 2 activated successfully
...    SCellIndex 3 activated successfully

@{Result_3cc}
...    rrcReconfigurationComplete
...    pcid:61, scellIdx:2
...    pcid:60, scellIdx:1
...    SCellIndex 1 activated successfully
...    SCellIndex 2 activated successfully


${pdu_id}    1
${gw_id}    1
${nwslice}    1

${SA_Capa_Support}    SEPARATOR=
...    E9A09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C4700FB8D85181AC1184341020E9068036B64C558D0E7C471
...    E819F604F8C48E3C873EA39F30C7942C0E070F05C00FFC0070005F0005C0000E0541B107582308682041E20D00656C98AB121CFB027C471E31238F2
...    1CFA8E7CC31E50B0381C3C27F6000001FD800000170000381546C4DD608C21A0810748340185B262A88873E238F11C7A067D813E31CF9863CA16070
...    38782E007FE003801FF8002E0000702A0D88DAC1184341020F1068032B64C55890E7C471EC09F1891C790E7D473E618F28581C0E1E13FFE00000FFF
...    800000B80001C00F78789A001C4100000216020541E14000711800000858158788C001C41000006160561E14000710400000858158789A001C46000
...    002160562E2300071040038820000142C0AC3C28000E268000060B02B17134003882001C28000008160562E26800711800388C0000082C0AC5C2800
...    0E20800711800001058158F850001C41000E20800711800003858158B89A001C41000E230000020B02B170A000388C001C46000004160562E268007
...    1180038500000102C0AC3C46000E230000030B0200E0234028809B01045D002F41F0A244D8E7C3851226C73E1C28913639F0E14489B1CF870A244D8
...    E7C38912244D8E7C3850206C73E044810206C73E044810206C73E044810206C73E0468102040D8E7C08902040D8E7C08902040D8E7C08902040D8E7
...    C0850206C73E0005C3C6318C6318C6318C63187A0B800F000A070500703009401C0018090010180F824008000000040000080200000001000002008
...    00002004000018020000100100000A008004010040100000C0080000700400200000008000080040000480200000C010000140080000B0040020481
...    20080000C0339535953582958195833582B594B5933580B581B58095811583B40D04000025949410000196525040000A59490100003965240400012
...    5949010000596524040001A594901000079652404000225949010000996524040002A5949010000B96525040003259490100003165240334AAAE955
...    552A8BA55154162A82C55068AA531549A2A80C55028AA4D5541E285805E02540A05028140A05028140A05028140A05028140A05000708080600C020
...    04008404008020100C018402004008080600C02018030404030060100C018402004008080600C02004008804030060100C018040300608080100402
...    004010C04008010100C01804030060100C0186A87C0004080C10181C282C30344044484C5060646C70747C8494989CA0A4A8B4BD050E0B4

*** Test Cases ***
CB008290-ET-B088_Verify_incoming_A6_MR_for_scell_swap_queue_when_A6_scell_swap_ongoing
    [Documentation]
    ...    1. This user scenario describes Verify incoming A6 MR for scell swap queue when A6 scell swap ongoing
    ...    2. Configuration:
    ...       TDD Cell1/Cell2 configure to same frequency. FDD Cell11/Cell13 configure to different frequency.
    ...       FDD Cell12/Cell14 configure to same frequency.
    ...       cell11-cell1, cell11-cell2, cell11-cell12, cell11-cell13, cell11-cell14
    ...    3. Test Case Steps:
    ...         a. UE registers successfully and PDU session is setup successfully on cell 11, Start traffic and check traffic
    ...         b. UE sends A1 measurement for SCell Addition, check traffic.
    ...         c. delay to send RRC Reconfiguration Complete
    ...         d. UE sends A6 measurement for SCell1 swap and check traffic.
    ...         e. UE sends A6 measurement for SCell2 swap and check traffic.
    ...         f. delay to send RRC Reconfiguration Complete
    ...         g. UE sends A6 measurement for SCell4 swap and check traffic.
    ...         h. UE sends A6 measurement for SCell4 swap and check traffic.
    ...         i. UE deregister
    ...     4. Expect result:
    ...         a. UE registers successfully, PDU session is setup successfully, A1 meas for scell addition configured
    ...            DL/UL throughput on TDD PCell can reach the expected value.
    ...         b. UE is successfully configured with FDD PCell and TDD SCell1-cell1, FDD SCell2-cell12, FDD SCell3-cell13 as SCell,
    ...            A1 for scell addition is released.
    ...            A2 for scell release and A6 for scell swap is configured to UE.
    ...            Aggregate UE peak DL/UL throughput on FDD PCell and TDD SCell1, FDD SCell2, FDD SCell3 can reach the expected value.
    ...         d. scell swap holdon, after 3s swap to scell4-cell2 successfully.
    ...            A2 for scell release and A6 for scell swap on Scell1 is removed to UE.
    ...            A2 for scell release and A6 for scell swap on Scell4 is configured to UE.
    ...         e. scell swap to scell1-cell13 successfully.
    ...            A2 for scell release and A6 for scell swap on Scell2 is removed to UE.
    ...            A2 for scell release and A6 for scell swap on Scell1 is configured to UE.
    ...            Aggregate UE peak DL/UL throughput on TDD PCell and TDD SCell1 can reach the expected value.
    ...         g. scell swap holdon, after 3s swap to scell2-cell1 successfully.
    ...            A2 for scell release and A6 for scell swap on Scell4 is removed to UE.
    ...            A2 for scell release and A6 for scell swap on Scell2 is configured to UE.
    ...         h. scell swap to scell2-cell1 drop.
    ...            Aggregate UE peak DL/UL throughput on TDD PCell and TDD SCell4 can reach the expected value.
    ...         i. UE deregister is successfully.
    [Tags]    QC_223973    owner-ha.zheng    B088
    UE Attach To Target Cell    pcell_dl=60
    Trigger ScellAdd 4CC
    Set RRC Reconfiguration Complete delay
    Trigger ScellSwap holdon
    Trigger ScellSwap
    Set RRC Reconfiguration Complete delay
    Trigger ScellSwap holdon    scell_id=4    phycell_id=50
    Trigger ScellSwap fail    carrierfreq=518910    scell_id=4    phycell_id=50    check=rrc-TransactionIdentifier 4
    UE Deregister From gNB
    Check Wireshark Log    ${CURDIR}${/}a2a_CB008290B088${/}a2a.ini    wait_string=UEContextReleaseComplete::4

#CB008290-ET-B089_Verify_incoming_A6_MR_for_scell_swap_ignore_when_A1_MR_for_scell_change_ongoing
#    [Documentation]
#    ...    1. This user scenario describes Verify incoming A1 MR for scell change ingore when A6 scell swap ongoing
#    ...    2. Configuration:
#    ...       TDD Cell1/Cell2 configure to same frequency. FDD Cell11/Cell13 configure to different frequency.
#    ...       FDD Cell12/Cell14 configure to same frequency.
#    ...       cell11-cell1, cell11-cell2, cell11-cell12, cell11-cell13, cell11-cell14
#    ...    3. Test Case Steps:
#    ...         a. UE registers successfully and PDU session is setup successfully on cell 11, Start traffic and check traffic
#    ...         b. UE sends A1 measurement for SCell Addition, check traffic.
#    ...         c. delay to send RRC Reconfiguration Complete
#    ...         d. UE sends A1 measurement for SCell change.
#    ...         e. UE sends A6 measurement for SCell1 swap.
#    ...         f. UE deregister
#    ...    4. Expect result:
#    ...         a. UE registers successfully, PDU session is setup successfully, A1 meas for scell addition configured
#    ...            DL/UL throughput on TDD PCell can reach the expected value.
#    ...         b. UE is successfully configured with FDD PCell and FDD SCell1-cell12, FDD SCell2-cell13 as SCell,
#    ...            A1 for scell addition is released.
#    ...            A2 for scell release and A6 for scell swap is configured to UE.
#    ...            Aggregate UE peak DL/UL throughput on FDD PCell and FDD SCell1, FDD SCell2 can reach the expected value.
#    ...         d. scell change holdon , after 3s, scell change to TDD SCell-cell1
#    ...            A2 for scell release and A6 for scell swap on Scell1 is removed to UE.
#    ...            A2 for scell release and A6 for scell swap on Scell2 is configured to UE.
#    ...            Aggregate UE peak DL/UL throughput on TDD PCell and TDD SCell4 can reach the expected value.
#    ...         e. A6 measurement drop.
#    ...         f. UE deregister is successfully.
#    [Tags]    QC_223974    owner-ha.zheng    B089
#    UE Attach To Target Cell    pcell_dl=60
#    Trigger ScellAdd 3CC
#    Set RRC Reconfiguration Complete delay
#    Trigger ScellChange holdon
#    Trigger ScellSwap fail    scell_id=1    phycell_id=63    check=rrc-TransactionIdentifier 2
#    UE Deregister From gNB
#    Check Wireshark Log    ${CURDIR}${/}a2a_CB008290B089${/}a2a.ini    wait_string=UEContextReleaseComplete::4

CB008290-ET-B090_Verify_new_incoming_A2_for_inter_freq_HO_will_be_ignored_when_intra_freq_A3_is_queued_and_A6_ongoing
    [Documentation]
    ...    1. This user scenario describes Verify new incoming A2 for inter freq HO will be ignored when intra freq A3 is queued and A6 ongoing
    ...    2. Configuration:
    ...       TDD Cell1/Cell2 configure to same frequency. FDD Cell11/Cell13 configure to different frequency.
    ...       FDD Cell12/Cell14 configure to same frequency.
    ...       cell11-cell1, cell11-cell2, cell11-cell12, cell11-cell13, cell11-cell14
    ...    3. Test Case Steps:
    ...         a. UE registers successfully and PDU session is setup successfully on cell 1, Start traffic and check traffic
    ...         b. UE sends A1 measurement for SCell Addition, check traffic.
    ...         c. delay to send RRC Reconfiguration Complete
    ...         d. UE sends A6 measurement for SCell2 swap.
    ...         e. UE sends A3 measurement for intrafrequecy handover.
    ...         f. UE sends A2 measurement for interfrequecy handover.
    ...         h. UE deregister
    ...    4. Expect result:
    ...         a. UE registers successfully, PDU session is setup successfully, A1 meas for scell addition configured
    ...            A2/A3 for mobility configured
    ...            DL/UL throughput on TDD PCell can reach the expected value.
    ...         b. UE is successfully configured with TDD PCell and FDD SCell1-cell11, FDD SCell2-cell12 as SCell,
    ...            A1 for scell addition is released.
    ...            A2 for scell release and A6 for scell swap is configured to UE.
    ...            Aggregate UE peak DL/UL throughput on TDD PCell and TDD SCell1, FDD SCell2, FDD SCell2 can reach the expected value.
    ...         d. scell swap holdon , after 3s, scell swap to FDD SCell3-cell14
    ...            A2 for scell release and A6 for scell swap on Scell2 is removed to UE.
    ...            A2 for scell release and A6 for scell swap on Scell3 is configured to UE.
    ...         e. handover from cell1 to cell2.
    ...         f. A2 measurement drop.
    ...         h. UE deregister is successfully.
    [Tags]    QC_223975    owner-ha.zheng    B090
    UE Attach To Target Cell    cell_id=1    pcell_dl=320
    Trigger ScellAdd 3CC    carrierfreq=518910    phycell_id_1=60    phycell_id_2=61
    Set RRC Reconfiguration Complete delay
    Trigger ScellSwap holdon    carrierfreq=127450    scell_id=2    phycell_id=63
    trigger A3 event
    trigger A2 event
    UE Deregister From gNB
    Check Wireshark Log    ${CURDIR}${/}a2a_CB008290B090${/}a2a.ini    wait_string=UEContextReleaseComplete::4

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_2T4F_2N41_2N71_2N66

Set RRC Reconfiguration Complete delay
    [Arguments]    ${ue_id}=81
    Execute Egate Command    ue_nr_rrc_reconf_param id=${ue_id} if_contains=any delay=4000

UE Attach To Target Cell
    [Arguments]    ${cell_id}=11    ${ue_id}=81    ${pcell_dl}=60
    Update UE capa    ${SA_Capa_Support}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    ${ret1}=    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=${gw_id} nwslice=${nwslice}    QoS Routing Table
    Should Contain    ${ret1}    drx-Config setup
    Send Throuput
    Verify Throuput on Pcell    pcell_dl=${pcell_dl}

Update UE capa
    [Arguments]    ${SA_Capa_perUE_Full}=none    ${ue_id}=81
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full}
    Execute Egate Command    ${cmd}

Send Throuput
    [Arguments]    ${ue_id}=81
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=1    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=3    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=4    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=5    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=ul mbps=10 trf_id=1    UE ${ue_id}: UDP UL
    sleep    30s    #sleep for stable traffic

Verify Throuput on Pcell
    [Arguments]    ${ue_id}=81    ${pcell_dl}=60    ${ul}=8
    sleep    10s    #sleep for stable traffic
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000>${pcell_dl}
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul}

Verify Throuput on Pcell and Scell
    [Arguments]    ${ue_id}=81    ${pcell_dl}=10    ${scell_dl}=10    ${ul}=8    ${scell_id}=1
    sleep    10s     #sleep for stable traffic
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000 > ${pcell_dl}
    ${scell_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${scell_id}    type=pdsch    rate_type=ave
    Should Be True    ${scell_tput}/1000 > ${scell_dl}
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul}

UE Deregister From gNB
    [Arguments]    ${ue_id}=81
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s

Trigger ScellAdd 4CC
    [Arguments]    ${event_type}=A1    ${carrierfreq}=424090    ${srsrp_nr}=91    ${srsrq_nr}=50    ${ue_id}=81    ${phycell_id_1}=50
    ...    ${phycell_id_2}=61    ${phycell_id_3}=62    ${pcell_dl}=60    ${scell_dl_1}=320    ${scell_id_1}=1
    ...    ${scell_dl_2}=65    ${scell_id_2}=2    ${scell_dl_3}=60    ${scell_id_3}=3
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type}
    ...    srsrp_nr=${srsrp_nr} srsrq_nr=${srsrq_nr}
    ${ret1}=    Execute Egate Command    ${cmd}    pass_regexp=${Result_4cc}
    Verify Throuput on Pcell and Scell    pcell_dl=${pcell_dl}    scell_dl=${scell_dl_1}    scell_id=${scell_id_1}
    Verify Throuput on Pcell and Scell    pcell_dl=${pcell_dl}    scell_dl=${scell_dl_2}    scell_id=${scell_id_2}
    Verify Throuput on Pcell and Scell    pcell_dl=${pcell_dl}    scell_dl=${scell_dl_3}    scell_id=${scell_id_3}

Trigger ScellAdd 3CC
    [Arguments]    ${event_type}=A1    ${carrierfreq}=424090    ${srsrp_nr}=81    ${srsrq_nr}=50    ${ue_id}=81    ${phycell_id_1}=61
    ...    ${phycell_id_2}=62    ${pcell_dl}=60    ${scell_dl_1}=60    ${scell_id_1}=1    ${scell_dl_2}=60    ${scell_id_2}=2
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type}
    ...    srsrp_nr=${srsrp_nr} srsrq_nr=${srsrq_nr}
    ${ret1}=    Execute Egate Command    ${cmd}    pass_regexp=${Result_3cc}
    Verify Throuput on Pcell and Scell    pcell_dl=${pcell_dl}    scell_dl=${scell_dl_1}    scell_id=${scell_id_1}
    Verify Throuput on Pcell and Scell    pcell_dl=${pcell_dl}    scell_dl=${scell_dl_2}    scell_id=${scell_id_2}

Trigger ScellSwap holdon
    [Arguments]    ${event_type}=A6    ${carrierfreq}=518910    ${nrsrp_nr}=30    ${nrsrq_nr}=30    ${ue_id}=81    ${scell_id}=1
    ...    ${phycell_id}=51
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type}
    ...    srsrp_nr=11 srsrq_nr=11 scell=${scell_id} scell_rsrp=20 scell_rsrq=20 phycell_id=${phycell_id}
    ...    nrsrp_nr=${nrsrp_nr} nrsrq_nr=${nrsrq_nr}
    Execute Egate Command    ${cmd}    Hit on error cases presence=any action=delay

Trigger ScellChange holdon
    [Arguments]    ${event_type}=A1    ${carrierfreq}=424090    ${srsrp_nr}=91    ${srsrq_nr}=50    ${ue_id}=81    ${phycell_id_1}=61
    ...    ${phycell_id_2}=62    ${pcell_dl}=60    ${scell_dl_1}=60    ${scell_id_1}=1    ${scell_dl_2}=65    ${scell_id_2}=2
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type}
    ...    srsrp_nr=${srsrp_nr} srsrq_nr=${srsrq_nr}
    Execute Egate Command    ${cmd}    Hit on error cases presence=any action=delay

Trigger ScellSwap
    [Arguments]    ${event_type}=A6    ${carrierfreq}=127450    ${nrsrp_nr}=30    ${nrsrq_nr}=30    ${ue_id}=81    ${scell_id}=2
    ...    ${phycell_id}=63    ${pcell_dl}=0    ${scell_dl}=0    ${scell_id_1}=2
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type}
    ...    srsrp_nr=11 srsrq_nr=11 scell=${scell_id} scell_rsrp=20 scell_rsrq=20 phycell_id=${phycell_id}
    ...    nrsrp_nr=${nrsrp_nr} nrsrq_nr=${nrsrq_nr}
    ${ret1}=    Execute Egate Command    ${cmd}    pass_regexp=rrcReconfigurationComplete

Trigger ScellSwap fail
    [Arguments]    ${event_type}=A6    ${carrierfreq}=127450    ${nrsrp_nr}=30    ${nrsrq_nr}=30    ${ue_id}=81    ${scell_id}=2
    ...    ${phycell_id}=63    ${pcell_dl}=0    ${scell_dl}=0    ${scell_id_1}=2    ${check}=${EMPTY}
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type}
    ...    srsrp_nr=11 srsrq_nr=11 scell=${scell_id} scell_rsrp=20 scell_rsrq=20 phycell_id=${phycell_id}
    ...    nrsrp_nr=${nrsrp_nr} nrsrq_nr=${nrsrq_nr}
    ${ret1}=    Execute Egate Command    ${cmd}    pass_regexp=rrcReconfigurationComplete
    Should not contain    ${ret1}    ${check}

trigger A2 event
    [Arguments]    ${event_type}=A2    ${carrierfreq}=518910    ${srsrp_nr}=7    ${srsrq_nr}=7    ${ue_id}=81
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=1 event=${event_type} srsrp_nr=7 srsrq_nr=7
    ...    pass_regexp=rrcReconfigurationComplete
    Should Contain    ${ret1}    measurementReport
    Should not Contain    ${ret1}    rrc-TransactionIdentifier 4

trigger A3 event
    [Arguments]    ${event_type}=A3    ${carrierfreq}=518910    ${srsrp_nr}=20    ${srsrq_nr}=20    ${ue_id}=81
    ...    ${phycell_id}=51    ${nrsrp_nr}=61    ${nrsrq_nr}=61    ${source_cell}=1    ${target_cell}=2
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type} srsrp_nr=${srsrp_nr}
    ...    srsrq_nr=${srsrq_nr} phycell_id=${phycell_id} nrsrp_nr=${nrsrp_nr} nrsrq_nr=${nrsrq_nr}
    ${ret1}=    Execute Egate Command    ${cmd}
    ...    pass_regexp=measurementReport






