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
...    @{PARAMS_FOR_IODT_ABIO_2T4F}
...    @{same frequency}
...    @{NRREL}
...    @{8290_enable}
...    @{1116_enable}
...    @{HO_related}
...    @{NRHOIF_Config}
...    @{EutraCGI_Config}
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
...    NRCELL-11/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-12/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-12/NRREL-2:sCellOperationalMode=dlOnly


@{HO_related}
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
...    NRCELL-11:measGapSelectionSA=balancedChoice

@{EutraCGI_Config}
...    NRBTS-1:actInterRatHoFromEutraToSA=true
...    NRBTS-1:nonContentRachAcFullConfigHo=true
...    NRBTS-1:tNgRelocExecDeltL=5000
...    NRBTS-1:actSaUeBasedAnrEutra=true
...    NRBTS-1:actInterRatHoSA=true
#...    NRBTS-1/NRCELL-11:drxProfileAnrEutra:drxInactivityTimer=10ms
#...    NRBTS-1/NRCELL-11:drxProfileAnrEutra:drxLongCycle=160ms
#...    NRBTS-1/NRCELL-11:drxProfileAnrEutra:drxOnDurationTimer=20ms
#...    NRBTS-1/NRCELL-11:drxProfileAnrEutra:drxRetransTimerDl=0slot
#...    NRBTS-1/NRCELL-11:drxProfileAnrEutra:drxRetransTimerUl=0slot
...    NRBTS-1/NRCELL-11:drxProfileNrAnr:drxControl=any
#...    NRBTS-1/NRCELL-11:drxProfileNrAnr:drxInactivityTimer=10ms
#...    NRBTS-1/NRCELL-11:drxProfileNrAnr:drxLongCycle=80ms
#...    NRBTS-1/NRCELL-11:drxProfileNrAnr:drxOnDurationTimer=20ms
#...    NRBTS-1/NRCELL-11:drxProfileNrAnr:drxRetransTimerDl=0slot
#...    NRBTS-1/NRCELL-11:drxProfileNrAnr:drxRetransTimerUl=0slot
...    MRBTS-1/NRBTS-1/NRANRPRE-1:anrThresholdSelectorEutra=RSRP
...    MRBTS-1/NRBTS-1/NRANRPRE-1:anrThresRsrpEutraNbCell=-120
...    MRBTS-1/NRBTS-1/NRANRPRE-1:anrThresRsrqEutraNbCell=-19
...    MRBTS-1/NRBTS-1/NRANRPRE-1:consecRecheckForEutraNbRemoval=5
...    MRBTS-1/NRBTS-1/NRANRPRE-1:idleTimeForEutraNbRemoval=72
...    MRBTS-1/NRBTS-1/NRANRPRE-1:maxNumAnrNrrelePerCell=50
...    MRBTS-1/NRBTS-1/NRHOIR-1:allowedMeasBandwidth=mbw50
...    MRBTS-1/NRBTS-1/NRHOIR-1:b2MeashoEnabled=rsrp
...    MRBTS-1/NRBTS-1/NRHOIR-1:b2Threshold1hoRsrp=35
...    MRBTS-1/NRBTS-1/NRHOIR-1:b2Threshold1hoRsrq=50
...    MRBTS-1/NRBTS-1/NRHOIR-1:earfcnValue=2000
...    MRBTS-1/NRBTS-1/NRHOIR-1:eutraFreqQOffsetRange=0dB
...    MRBTS-1/NRBTS-1/NRHOIR-1:eutraB2MeashoRsrp:b2HysteresishoRsrp=0
...    MRBTS-1/NRBTS-1/NRHOIR-1:eutraB2MeashoRsrp:b2Threshold2hoRsrp=20
...    MRBTS-1/NRBTS-1/NRHOIR-1:eutraB2MeashoRsrp:b2TimeToTriggerhoRsrp=ms64
...    MRBTS-1/NRBTS-1/NRHOIR-1:eutraB2MeashoRsrq:b2HysteresishoRsrq=0
...    MRBTS-1/NRBTS-1/NRHOIR-1:eutraB2MeashoRsrq:b2Threshold2hoRsrq=2
...    MRBTS-1/NRBTS-1/NRHOIR-1:eutraB2MeashoRsrq:b2TimeToTriggerhoRsrq=ms80
...    MRBTS-1/NRBTS-1/NRHOIR-1:presenceAntennaPort1=false
...    MRBTS-1/NRBTS-1/NRHOIR-1:reportAmount=r8
...    MRBTS-1/NRBTS-1/NRHOIR-1:reportInterval=ms240
...    MRBTS-1/NRBTS-1/NRHOIR-1:widebandRsrqMeas=true
...    MRBTS-1/NRBTS-1/NRCELL-11:nrhoirDNList=MRBTS-1/NRBTS-1/NRHOIR-1
...    MRBTS-1/NRBTS-1/NRCELL-11:a1MeashoEnabledSA=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-11:a2MeashoEnabledSA=rsrp
...    MRBTS-1/NRBTS-1/NRANR-1:actAutoEutraNbRemoval=false
...    MRBTS-1/NRBTS-1/NRANR-1:actAutoNrNbRemoval=false
...    MRBTS-1/NRBTS-1/NRANR-1:consecHoFailThres=3
...    MRBTS-1/NRBTS-1/NRANR-1:consecHoFailThresEutra=3

@{NRHOIF_Config}
...    NRCELL-11/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-11/NRHOIF-1:freqBandIndicatorNR=41
...    NRCELL-11/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-11/NRHOIF-1:ifhoSsbSmtcDuration=sf2
...    NRCELL-11/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-11/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-11/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-11/NRHOIF-1:ssbFrequency=518910
...    NRCELL-11/NRHOIF-1:a1BasedPCellSwitchEnabled=false
...    NRCELL-11/NRHOIF-1:a2BasedPCellSwitchEnabled=false
...    NRCELL-11/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=4|a3OffsetSsbRsrp=15|a3TimeToTriggerSsbRsrp=ms0
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
...    NRCELL-11/NRREL-1:lcrId=12
...    NRCELL-11/NRREL-1:sCellPrio=1
...    NRCELL-11/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-2:gNbId=1
...    NRCELL-11/NRREL-2:gNbIdLength=22
...    NRCELL-11/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-2:removeNotAllowed=false
...    NRCELL-11/NRREL-2:lcrId=14
...    NRCELL-11/NRREL-2:sCellPrio=2
...    NRCELL-11/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-1:gNbId=1
...    NRCELL-12/NRREL-1:gNbIdLength=22
...    NRCELL-12/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-12/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-1:removeNotAllowed=false
...    NRCELL-12/NRREL-1:lcrId=11
...    NRCELL-12/NRREL-1:sCellPrio=1
...    NRCELL-12/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-2:gNbId=1
...    NRCELL-12/NRREL-2:gNbIdLength=22
...    NRCELL-12/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-12/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-2:removeNotAllowed=false
...    NRCELL-12/NRREL-2:lcrId=13
...    NRCELL-12/NRREL-2:sCellPrio=2
...    NRCELL-12/NRREL-2:sCellAdditionMethod=covBasedA1

@{8290_enable}
...    NRDU-1:actInterNumerologyCa=true
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRBTS-1:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS-1:actSCellSwapFr1=a6BasedSa
...    NRBTS-1:sCellActivationMethod=bufferBased
...    NRCELL:sCellDeactivationTimerGNB=ms1280
...    NRCELL:cellDepType=SA+NSA
...    NRCELL:actCDrx=true
...    NRCELL:actK1Opt=intra-gNB
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
...    NRCELL-11:actProactUlSchedulingEnh=disabled
...    NRCELL-12:actProactUlSchedulingEnh=disabled
...    NRCELL-13:actProactUlSchedulingEnh=disabled
...    NRCELL-14:actProactUlSchedulingEnh=disabled
...    NRDU-1:carrierAggregationSupportList=ca_Fdd_Fdd,ca_Fdd_Fr1Tdd_Sa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa

@{same frequency}
...    MRBTS-1/NRBTS-1/NRCELL-1:gscnOrSsPbchArfcn=6486
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

@{1116_enable}
...    NRCELL-1:tddFrameStructure:lteToNrFrameShift=0ms
...    NRCELL-2:tddFrameStructure:lteToNrFrameShift=0ms
...    NRCELL-1:prachConfigurationIndex=97
...    NRCELL-2:prachConfigurationIndex=97
...    NRBTS-1:actRanSharing=false

@{NRREL_A034}
...    NRCELL-11/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-3:gNbId=1
...    NRCELL-11/NRREL-3:gNbIdLength=22
...    NRCELL-11/NRREL-3:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-3:removeNotAllowed=false
...    NRCELL-11/NRREL-3:lcrId=1
...    NRCELL-11/NRREL-3:sCellPrio=2
...    NRCELL-11/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-4:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-4:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-4:gNbId=1
...    NRCELL-11/NRREL-4:gNbIdLength=22
...    NRCELL-11/NRREL-4:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-4:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-4:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-4:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-4:removeNotAllowed=false
...    NRCELL-11/NRREL-4:lcrId=2
...    NRCELL-11/NRREL-4:sCellPrio=1
...    NRCELL-11/NRREL-4:sCellAdditionMethod=covBasedA1

@{OnlineParamChange_A034}
...    NRCELL-12:a6MeasSCellSwapEnabled=rsrpAndRsrq
...    NRCELL-1:a6MeasSCellSwapEnabled=rsrpAndRsrq
...    NRCELL-2:a6MeasSCellSwapEnabled=rsrq
...    @{NRREL_A034}

@{OnlineParam_A034_recover}
...    NRCELL:a6MeasSCellSwapEnabled=rsrp
...    delete:NRCELL-11/NRREL-3
...    delete:NRCELL-11/NRREL-4

@{OnlineParamChange_A049}
...    NRDU-1:actConnectedModeMobilityCA=false
...    NRDU-1:carrierAggregationSupportList=ca_Fdd_Fdd
...    NRCELL:actCDrx=false
...    NRBTS-1:actSaUeBasedAnrEutra=false
...    NRCELL-13:a6MeasSCellSwapEnabled=rsrpAndRsrq

@{OnlineParam_A049_recover}
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRDU-1:carrierAggregationSupportList=ca_Fdd_Fdd,ca_Fdd_Fr1Tdd_Sa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa
...    NRCELL:actCDrx=true
...    NRBTS-1:actSaUeBasedAnrEutra=true
...    NRCELL-13:a6MeasSCellSwapEnabled=rsrp

${SA_Capa_CGI_HO}    SEPARATOR=
...    E9A09000575F5A13160003C320016093170019C3D09009B20C39F30C7942C0E098040623807DC6C28C0D608C21A08107482406D6C98AB1A
...    1CF88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE00098000702A0D883AC1184341020F10480CAD931562439F604
...    F88E3C62471E439F51CF9863CA1607038784FEC000003FB000000260001C0AA3626EB04610D04083A412030B64C55110E7C471E238F40CFB
...    027C639F30C7942C0E070F05C00FFC007003FF0004C000381506C46D608C21A0810788240656C98AB121CF88E3D813E31238F21CFA8E7CC3
...    1E50B0381C3C27FFC00001FFF00000130000E007BC3C4D000E208000010B0102A0F0A000388C0000042C0AC3C46000E208000030B02B0F0A
...    00038820000042C0AC3C4D000E230000010B02B17118003882001C4100000A160561E14000713400003058158B89A001C41000E140000040
...    B02B1713400388C001C46000004160562E14000710400388C0000082C0AC5C28000E20800710400001058158B89A001C41000E230000020B
...    02B170A000388C001C46000004160562E2680071180038500000102C0AC3C46000E230000030B0200E0234028809B01043D02EC1F0A244D8
...    E7C3851226C73E1C28913639F0E14489B1CF870A244D8E7C38912244D8E7C3850206C73E044810206C73E044810206C73E044810206C73E0
...    44810206C73E044810206C73E044810206C73E044810206C73E0428103639F0005C3C6318C6318C6318C63187A09C01F001600180E0A00E0
...    601280380030120020301F048010000000080000100400000002000004010000040080000300400002002000014010008020080200001801
...    00000E008004000000100001000800009004000018020000280100001600800409024010000180672A6B2A6B052B032B066B056B296B266B
...    016B036B012B022B07681A0800004B29282000032CA4A0800014B29202000072CA480800024B292020000B2CA480800034B292020000F2CA
...    480800044B29202000132CA480800054B29202000172CA4A0800064B29202000062CA480669555D2AAAA55174AA2A82C55058AA0D154A62A
...    93455018AA051549AAA83C5090178095028140A05028140A05028140A05028140A0502814001820201803008010021010020080403006100
...    80100202018030080600C10100C018040300610080100202018030080100220100C01804030060100C01820200401008010043543E000204
...    06080C0E1216181A2022242628303236383A3E424A4C4E5052545A5E828305A ue_eutra_capabilities=1E000030010312000000

${ue_id}    1
${pdu_id}    1
${gw_id}    1
${nwslice}    1
${ue_id_49}    81

*** Test Cases ***
CB008290-ET-A049_Verify_scell_swap_succeed_when_actConnectedModeMobilityCA_disbaled_actSCellSwapFr1_enabled
    [Documentation]
    ...    1. This user scenario Verify_scell_swap_succeed_when_actConnectedModeMobilityCA_disbaled_actSCellSwapFr1_enabled
    ...    2. Configuration:
    ...        TDD Cell1/Cell2 configure to same frequency, FDD Cell11/Cell13 configure to same frequency.
    ...        FDD cell12/cell14 configure to another same frequency. ActConnectedModeMobilityCA = false
    ...        Configure nrrel Relations: cell12-cell11, cell12-cell13
    ...    3. Test Case Steps:
    ...         1) UE registers successfully and PDU session is setup successfully on cell 12, Start UL/DL data.
    ...             A1 meas for scell addition configured.
    ...         2) UE sends A1 measurement for SCell 11 Addition successfully.
    ...         3) A6 for scell swap measurement report from 5G-UE.
    ...             scell swap to FDD cell 13 successfully, Scell activated successfully .
    ...         4) A6 for scell swap measurement report from 5G-UE.
    ...             scell swap back to FDD cell 11 successfully, Scell activated successfully .
    [Tags]    QC_222566    owner-zora    A049
    OnlineParamChange    ${OnlineParamChange_A049}
    Ue Register to cell12 and add cell11 as scell
    A6 swap to cell13 and then A6 swap back to cell11
    UE Deregister From gNB    ue_id=${ue_id_49}
    Check Wireshark Log    ${CURDIR}${/}a2a_CB008290A049${/}a2a.ini    wait_string=UEContextRelease::12
    [Teardown]    A049_Teardown

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_2T4F_2N41_2N71_2N66

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir

A034_Teardown
    OnlineParamChange    ${OnlineParam_A034_recover}
    Common Test Teardown And Stop Capture Logs

A049_Teardown
    OnlineParamChange    ${OnlineParam_A049_recover}
    Common Test Teardown And Stop Capture Logs

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
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=175 trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=175 trf_id=3    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=175 trf_id=4    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=ul mbps=10 trf_id=1    UE ${ue_id}: UDP UL
    sleep    30s    #sleep for stable traffic

Verify Throuput on Pscell
    [Arguments]    ${ue_id}=82    ${pcell_dl}=60    ${ul}=8
    sleep    10s    #sleep for stable traffic
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000>${pcell_dl}
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul}

Verify Throuput on Pscell and Scell
    [Arguments]    ${ue_id}=82    ${pcell_dl}=60    ${scell_dl}=60    ${ul}=8    ${scell_id}=1
    sleep    10s     #sleep for stable traffic
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000 > ${pcell_dl}
    ${scell1_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${scell_id}    type=pdsch    rate_type=ave
    Should Be True    ${scell1_tput}/1000 > ${scell_dl}
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul}

UE Deregister From gNB
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s

Trigger ScellAdd
    [Arguments]    ${event_type}=A1    ${carrierfreq}=424090    ${srsrp_nr}=81    ${srsrq_nr}=81    ${ue_id}=1
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr    id=${ue_id}    meas_id=${meas_id}    event=${event_type}
    ...    srsrp_nr=${srsrp_nr}    srsrq_nr=${srsrq_nr}
    Execute Egate Command    ${cmd}    pass_regexp=rrcReconfigurationComplete

Trigger B2 HO
    ${A2_meas_id}    get nr meas id for specific type and frequency    ${ue_id}    event_type=A2    carrierfreq=424090
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${A2_meas_id} event=A2 srsrp_nr=11 srsrq_nr=11 srs_result=0:11:11:0
    ...    pass_regexp=rrcReconfigurationComplete
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}    event_type=B2    carrierfreq=2000    carrierfreq_rat=EUTRAN
    Execute Egate Command    ue_nr_rrc_reconf_param id=${ue_id} if_contains=report_cgi_eutra anr_cgi_delay=60
    sleep    2s    #sleep for stable to execute next command
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=B2 srsrp_nr=11 srsrq_nr=11
    ...    srs_result=0:11:11:0 phycell_id=30 nrsrp_nr=58 nrsrq_nr=30 rs_type=ssb index=1 nrs_result=30:30:0
    Execute Egate Command    ${cmd}    pass_regexp=Successful handover from EXT_ENB-2.11 to ENB-3.1

Modify Cfg
    ${C_1}    catenate
    ...    set_gnb id=3 type=simulated plmn=311:489 ng=10.0.1.138 daemon=10.0.2.1:22222 gnb_id=0x74321:28 nssai=0x01:0xD143A5
    ${C_2}    catenate
    ...    set_cell id=1 gnb=3 pci=10:0 eci=0x7432101 earfcn=2000:20000 mapped_earfcn=4200:22200 tac=200 proxy=10.0.2.92:12219 nrci=0x01
    ...    tdd_cell=off bw=20MHz technology=lte mandatory_for_activation=off
    Update Cfg    ${C_1}
    Update Cfg    ${C_2}
    Update Cfg    gnb_cell_param id=1 gnb=3 enable_drx_profile_for_anr=on
    Update Cfg    gnb_param id=3 xn_listening_socket=off sib1_period=20000
    Update Cfg    mme_pool_area id=1 mmegi=1 plmn=311:489 tac_list=777,111,222,444,333,200
    Update Cfg    set_mme id=1 ip=10.0.2.1:22222 s1=10.0.1.131:36412 supported_rat=lte,nblte pool=1:1

Trigger ScellSwap
    [Arguments]    ${event_type}=A6    ${carrierfreq}=424090    ${nrsrp_nr}=63    ${nrsrq_nr}=63    ${ue_id}=81    ${scell_id}=1
    ...    ${phycell_id}=62
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type}
    ...    srsrp_nr=11 srsrq_nr=11 scell=${scell_id} scell_rsrp=20 scell_rsrq=20 phycell_id=${phycell_id} nrsrp_nr=${nrsrp_nr} nrsrq_nr=${nrsrq_nr}
    Execute Egate Command    ${cmd}    pass_regexp=rrcReconfigurationComplete

Ue Register to cell12 and add cell11 as scell
    UE Attach To Target Cell    cell_id=12    ue_id=${ue_id_49}
    Send Throuput    ue_id=${ue_id_49}
    Verify Throuput on Pscell    ue_id=${ue_id_49}    pcell_dl=45    ul=7
    Trigger ScellAdd    carrierfreq=127450    ue_id=${ue_id_49}
    Verify Throuput on Pscell and Scell    ue_id=${ue_id_49}    pcell_dl=45    scell_dl=50    ul=7

A6 swap to cell13 and then A6 swap back to cell11
    Trigger ScellSwap
    Verify Throuput on Pscell and Scell    ue_id=${ue_id_49}    scell_id=2    pcell_dl=45    ul=7    scell_dl=50
    Trigger ScellSwap    scell_id=2    phycell_id=60
    Verify Throuput on Pscell and Scell    ue_id=${ue_id_49}    pcell_dl=45    ul=7    scell_dl=50
