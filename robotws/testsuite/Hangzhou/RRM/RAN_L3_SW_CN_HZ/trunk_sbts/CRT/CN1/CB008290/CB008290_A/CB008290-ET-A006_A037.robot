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
${DEBUG_LOG_LEVEL}    4
@{PARAMS_IN_SCF}
...    NRBTS-1:cipherPrefL:nea0=8
...    NRBTS-1:cipherPrefL:nea1_128=0
...    NRBTS-1:cipherPrefL:nea2_128=0
...    NRBTS-1:cipherPrefL:nea3_128=0
...    NRBTS-1:integrityProtPrefL:nia0=0
...    NRBTS-1:integrityProtPrefL:nia1_128=0
...    NRBTS-1:integrityProtPrefL:nia2_128=0
...    NRBTS-1:integrityProtPrefL:nia3_128=9
...    @{PARAMS_FOR_IODT_ABIO_4T2F}
...    @{same frequency}
...    @{8290_enable}
...    @{732_enable}
...    @{1116_enable}
...    @{NRREL}
...    @{NRHOIF_Config}
...    @{BOO_AP_LOO}

@{BOO_AP_LOO}
...    NRBTS/NRDU-1:flexibleCAMode=NumberCellAmount
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-7:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-7:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-8:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-8:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-7:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-7:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-8:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-8:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-7:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-7:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-8:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-8:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-7:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-7:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-8:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-8:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1
...    NRCELL:actUlSrsBm=false
...    NRCELL:actDlSrsBm=false
...    NRCELL:sCellDeactivationTimerGNB=infinity
...    NRCELL-1/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-3:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-4:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-3:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-4:sCellOperationalMode=dlOnly
...    NRCELL-3/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-3/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-3/NRREL-3:sCellOperationalMode=dlOnly
...    NRCELL-3/NRREL-4:sCellOperationalMode=dlOnly

...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=1
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=1
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=4|searchSpaceId=1
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=1
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=1
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=1
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=1
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=1
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|searchSpaceId=1
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=1
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=6|searchSpaceId=1
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=2
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=2
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=2
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=2
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=2
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=2
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=2
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=2
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=2
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=2
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=2
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=3
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=3
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=3|searchSpaceId=3
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=3
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=3
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=3
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=3
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=3
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceId=3
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=3
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=3

...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=4
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=4
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=4|searchSpaceId=4
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=4
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=4
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=4
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=4
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=4
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|searchSpaceId=4
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=4
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=6|searchSpaceId=4
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=5
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=5
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=5
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=5
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=5
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=5
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=5
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=5
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=5
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=5
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=5
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=6
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=6
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=3|searchSpaceId=6
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=6
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=6
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=6
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=6
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=6
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceId=6
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=6
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=6

@{NRHOIF_Config}
...    NRBTS-1:actInterRatHoSA=true
...    NRBTS-1:actIntraFreqHoSA=true
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
...    NRCELL-3/NRHOIF-1:cellDepType=SA
...    NRCELL-3/NRHOIF-1:freqBandIndicatorNR=71
...    NRCELL-3/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-3/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-3/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf5
...    NRCELL-3/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-3/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-3/NRHOIF-1:ssbFrequency=125050
...    NRCELL-3/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-3/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1|a3OffsetSsbRsrp=15|a3TimeToTriggerSsbRsrp=40ms
...    NRCELL-3/NRHOIF-1:a5MeasEnabled=rsrp
...    NRCELL-3/NRHOIF-1:a5MeasSsbRsrp:a5HysteresisSsbRsrp=0|a5Threshold1SsbRsrp=52|a5Threshold2SsbRsrp=54|a5TimeToTriggerSsbRsrp=ms100

@{1116_enable}
#cell 2,4 1208 Frame Structure; cell 1 3 1116 Frame Structure
...    NRCELL-1:tddFrameStructure:frameStructureType=tdLte
...    NRCELL-1:tddFrameStructure:ulDlDataSlotRatio=1/4
...    NRCELL-1:tddFrameStructure:guardPeriodLength=4Symbols
...    NRCELL-1:tddFrameStructure:tdLteUlDlConfig=tdLteConfig2
...    NRCELL-1:tddFrameStructure:lteToNrFrameShift=0ms
...    NRCELL-1:prachConfigurationIndex=96
...    NRCELL-3:tddFrameStructure:frameStructureType=tdLte
...    NRCELL-3:tddFrameStructure:ulDlDataSlotRatio=1/4
...    NRCELL-3:tddFrameStructure:guardPeriodLength=4Symbols
...    NRCELL-3:tddFrameStructure:tdLteUlDlConfig=tdLteConfig2
...    NRCELL-3:tddFrameStructure:lteToNrFrameShift=0ms
...    NRCELL-3:prachConfigurationIndex=96
...    NRCELL-2:tddFrameStructure:frameStructureType=semiStatic
...    NRCELL-2:tddFrameStructure:ulDlDataSlotRatio=1/4
...    NRCELL-2:tddFrameStructure:guardPeriodLength=2Symbols
...    NRCELL-2:tddFrameStructure:tdLteUlDlConfig=tdLteConfig2
...    NRCELL-4:tddFrameStructure:frameStructureType=semiStatic
...    NRCELL-4:tddFrameStructure:ulDlDataSlotRatio=1/4
...    NRCELL-4:tddFrameStructure:guardPeriodLength=2Symbols
...    NRCELL-4:tddFrameStructure:tdLteUlDlConfig=tdLteConfig2
...    NRCELL-2:prachConfigurationIndex=98
...    NRCELL-4:prachConfigurationIndex=98
...    delete:NRCELL-2:tddFrameStructure:lteToNrFrameShift
...    delete:NRCELL-4:tddFrameStructure:lteToNrFrameShift

@{732_enable}
...    NRBTS-1:actGnbInitRlf=false
...    NRBTS-1:rrcReestabTypeSA=sameGNB
...    NRBTS-1:tWaitingRlRecover=700ms

@{NRREL}
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-1:gNbId=1
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-1:removeNotAllowed=false
...    NRCELL-1/NRREL-1:lcrId=3
...    NRCELL-1/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-1:sCellPrio=1
...    NRCELL-1/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-2:gNbId=1
...    NRCELL-1/NRREL-2:gNbIdLength=22
...    NRCELL-1/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-2:removeNotAllowed=false
...    NRCELL-1/NRREL-2:lcrId=4
...    NRCELL-1/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-2:sCellPrio=2
...    NRCELL-1/NRREL-2:handoverAllowedSA=allowed
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
...    NRCELL-1/NRREL-3:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-4:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-4:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-4:gNbId=1
...    NRCELL-1/NRREL-4:gNbIdLength=22
...    NRCELL-1/NRREL-4:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-4:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-4:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-4:removeNotAllowed=false
...    NRCELL-1/NRREL-4:lcrId=12
...    NRCELL-1/NRREL-4:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-4:sCellPrio=2
...    NRCELL-1/NRREL-4:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-1:gNbId=1
...    NRCELL-11/NRREL-1:gNbIdLength=22
...    NRCELL-11/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-1:removeNotAllowed=false
...    NRCELL-11/NRREL-1:lcrId=3
...    NRCELL-11/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-1:sCellPrio=1
...    NRCELL-11/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-2:gNbId=1
...    NRCELL-11/NRREL-2:gNbIdLength=22
...    NRCELL-11/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-2:removeNotAllowed=false
...    NRCELL-11/NRREL-2:lcrId=4
...    NRCELL-11/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-2:sCellPrio=2
...    NRCELL-11/NRREL-2:handoverAllowedSA=allowed

@{8290_enable}
...    NRBTS-1:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS-1:actSCellSwapFr1=a6BasedSa
...    NRBTS-1:sCellActivationMethod=bufferBased
...    NRCELL:cellDepType=SA
...    delete:NRCELL-.*:configuredEpsTac
...    NRCELL-11:measGapSelectionSA=balancedChoice
...    NRCELL:actCDrx=false
...    NRCELL:actK1Opt=intra-gNB

...    NRCELL:a6MeasSCellSwapEnabled=rsrp
...    NRCELL:a6MeasSCellSwapSsbRsrp:a6HysteresisSCellSwapSsbRsrp=0|a6OffsetSCellSwapSsbRsrp=6|a6TimeToTrigSCellSwapSsbRsrp=ms480
...    NRCELL:a6MeasSCellSwapSsbRsrq:a6HysteresisSCellSwapSsbRsrq=0|a6OffsetSCellSwapSsbRsrq=6|a6TimeToTrigSCellSwapSsbRsrq=ms480
...    NRCELL:reportAmountA6MeasSCellSwap=infinity
...    NRCELL:reportIntervalA6MeasSCellSwap=ms1024
...    NRCELL:sCellDeactivationTimerGNB=ms1280
...    NRCELL:thresholdSCellSwapSourceRsrp=66
...    NRCELL:thresholdSCellSwapSourceRsrq=67
...    NRCELL:a1MeasSCellAddEnabled=rsrp
...    NRCELL:a2MeasSCellRelEnabled=rsrpAndRsrq
...    NRCELL:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=70|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=80|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrq:a1HysteresisSCellAddSsbRsrq=0|a1TimeToTriggerSCellAddSsbRsrq=320ms
...    NRCELL:a1MeasSCellAddSsbRsrq:a1ThresholdSCellAddSsbRsrq=30|a1TimeToTriggerSCellAddSsbRsrq=320ms
...    NRCELL:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=480ms
...    NRCELL:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=34|a2TimeToTriggerSCellRelSsbRsrp=480ms
...    NRCELL:a2MeasSCellRelSsbRsrq:a2HysteresisSCellRelSsbRsrq=0|a2TimeToTriggerSCellRelSsbRsrq=480ms
...    NRCELL:a2MeasSCellRelSsbRsrq:a2ThresholdSCellRelSsbRsrq=5|a2TimeToTriggerSCellRelSsbRsrq=480ms
...    NRCELL-1:weightForSCellSelection=70
...    NRCELL-2:weightForSCellSelection=70
...    NRCELL-3:weightForSCellSelection=60
...    NRCELL-4:weightForSCellSelection=60
...    NRCELL-11:weightForSCellSelection=40
...    NRCELL-12:weightForSCellSelection=40

@{same frequency}
...    MRBTS-1/NRBTS-1/NRCELL-1:chBw=80MHz
...    MRBTS-1/NRBTS-1/NRCELL-2:gscnOrSsPbchArfcn=8000
...    MRBTS-1/NRBTS-1/NRCELL-2:nrarfcn=648000
...    MRBTS-1/NRBTS-1/NRCELL-2:chBw=80MHz
...    MRBTS-1/NRBTS-1/NRCELL-2:type0CoresetConfigurationIndex=12
...    MRBTS-1/NRBTS-1/NRCELL-12:gscnOrSsPbchArfcn=1562
...    MRBTS-1/NRBTS-1/NRCELL-12/NRCELL_FDD-1:nrarfcnDl=124900
...    MRBTS-1/NRBTS-1/NRCELL-12/NRCELL_FDD-1:nrarfcnUl=134100
...    MRBTS-1/NRBTS-1/NRCELL-12/NRCELL_FDD-1:chBwDl=10MHz
...    MRBTS-1/NRBTS-1/NRCELL-12/NRCELL_FDD-1:chBwUl=10MHz
...    MRBTS-1/NRBTS-1/NRCELL-12:type0CoresetConfigurationIndex=7

@{NRREL_For_A037}
...    NRCELL-3/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-3/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-3/NRREL-1:gNbId=1
...    NRCELL-3/NRREL-1:gNbIdLength=22
...    NRCELL-3/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-3/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-3/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-3/NRREL-1:removeNotAllowed=false
...    NRCELL-3/NRREL-1:lcrId=1
...    NRCELL-3/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-3/NRREL-1:sCellPrio=1
...    NRCELL-3/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-3/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-3/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-3/NRREL-2:gNbId=1
...    NRCELL-3/NRREL-2:gNbIdLength=22
...    NRCELL-3/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-3/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-3/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-3/NRREL-2:removeNotAllowed=false
...    NRCELL-3/NRREL-2:lcrId=2
...    NRCELL-3/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-3/NRREL-2:sCellPrio=1
...    NRCELL-3/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-3/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-3/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-3/NRREL-3:gNbId=1
...    NRCELL-3/NRREL-3:gNbIdLength=22
...    NRCELL-3/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-3/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-3/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-3/NRREL-3:removeNotAllowed=false
...    NRCELL-3/NRREL-3:lcrId=11
...    NRCELL-3/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-3/NRREL-3:sCellPrio=1
...    NRCELL-3/NRREL-3:handoverAllowedSA=allowed
...    NRCELL-3/NRREL-4:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-3/NRREL-4:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-3/NRREL-4:gNbId=1
...    NRCELL-3/NRREL-4:gNbIdLength=22
...    NRCELL-3/NRREL-4:gnbPlmn:mnc=489
...    NRCELL-3/NRREL-4:gnbPlmn:mcc=311
...    NRCELL-3/NRREL-4:gnbPlmn:mncLength=3
...    NRCELL-3/NRREL-4:removeNotAllowed=false
...    NRCELL-3/NRREL-4:lcrId=12
...    NRCELL-3/NRREL-4:sCellAdditionMethod=covBasedA1
...    NRCELL-3/NRREL-4:sCellPrio=1
...    NRCELL-3/NRREL-4:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-3:gNbId=1
...    NRCELL-11/NRREL-3:gNbIdLength=22
...    NRCELL-11/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-3:removeNotAllowed=false
...    NRCELL-11/NRREL-3:lcrId=1
...    NRCELL-11/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-3:sCellPrio=1
...    NRCELL-11/NRREL-3:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-4:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-4:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-4:gNbId=1
...    NRCELL-11/NRREL-4:gNbIdLength=22
...    NRCELL-11/NRREL-4:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-4:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-4:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-4:removeNotAllowed=false
...    NRCELL-11/NRREL-4:lcrId=2
...    NRCELL-11/NRREL-4:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-4:sCellPrio=1
...    NRCELL-11/NRREL-4:handoverAllowedSA=allowed

@{OnlineParamChange_A006}
...    NRBTS-1:actSCellSwapFr1=disabled
...    NRCELL:a2MeasSCellRelEnabled=rsrp

@{OnlineParam_A006_recover}
...    NRBTS-1:actSCellSwapFr1=a6BasedSa
...    NRCELL:a2MeasSCellRelEnabled=rsrpAndRsrq

@{OnlineParamChange_A037}
...    NRCELL:actCDrx=true
...    NRCELL-2:a6MeasSCellSwapEnabled=rsrpAndRsrq
...    NRCELL-1:a6MeasSCellSwapEnabled=rsrq
...    NRCELL-1:maxNumOfSCellAlloc=0
...    NRBTS-1:actSCellSwapFr1=a6BasedSa
...    NRCELL-11:a2MeasSCellRelEnabled=none
...    @{NRREL_For_A037}

@{maxNumOfSCellAllocChange_A037}
...    NRCELL:maxNumOfSCellAlloc=250

@{OnlineParam_A037_recover}
...    NRCELL:maxNumOfSCellAlloc=250
...    NRCELL:actCDrx=false
...    NRCELL:a2MeasSCellRelEnabled=rsrpAndRsrq
...    delete:NRCELL-11/NRREL-3
...    delete:NRCELL-11/NRREL-4
...    delete:NRCELL-3/NRREL-.*

${pdu_id}    1
${gw_id}    1
${nwslice}    1

*** Test Cases ***
#CB008290-ET-A006_Verify_scell_with_high_sCellPrio_will_be_selected_for_SA_call_when_actSCellSwapFr1_disabled_and_SA_only_cell_type
#    [Documentation]
#    ...    1. This user scenario describes Verify_scell_with_high_sCellPrio_will_be_selected_for_
#    ...        SA_call_when_actSCellSwapFr1_disabled_and_SA_only_cell_type
#    ...    2. Configuration
#    ...        TDD Cell1/Cell2 configure to same frequency, TDD Cell3/Cell4 configure to another same frequency.
#    ...        FDD cell11/cell12 configure to same frequency. CellDepType is set to 'SA'
#    ...        frame_structure: cell1/cell3 configured 1116(tdLte); cell2/cell4 configured 1208(semiStatic)
#    ...        Configure CA Relations: Cell1-Cell3, Cell1-Cell4, Cell1-Cell11, Cell1-Cell12, Cell11-Cell3, Cell11-Cell4.
#    ...        NRBTS-1:actSCellSwapFr1=disabled
#    ...    3. Test Case Steps:
#    ...         a. SA UE81 register to NRCELL-11 successfully.
#    ...            A1 measurement rsrp for TDD with a1ThresholdSCellAddSsbRsrpTDD for SCell Addition.
#    ...         b. UE sends A1 measurement higher than a1ThresholdSCellAddSsbRsrpTDD.
#    ...            higher priority TDD scell3 addition successfully.and no A6 meas config.
#    ...         c. A2 SCell release successfully, UE release successfully.
#    ...         d. SA UE81 register to NRCELL-1 successfully and bearer is setup successfully.
#    ...            A1 measurement rsrp for FDD with a1ThresholdSCellAddSsbRsrpFDD for SCell Addition.
#    ...         e. UE sends A1 measurement higher than a1ThresholdSCellAddSsbRsrpTDD.
#    ...            higher priority TDD scell3 addition successfully.and no A6 meas config.
#    ...         f. A2 SCell release successfully, UE release successfully.
#    ...         g. SA UE81 register to NRCELL-1 successfully and bearer is setup successfully.
#    ...            A1 measurement rsrp for FDD with a1ThresholdSCellAddSsbRsrpFDD for SCell Addition.
#    ...         h. UE sends A1 measurement higher than a1ThresholdSCellAddSsbRsrpFDD.
#    ...            higher priority FDD scell11 addition successfully.and no A6 meas config.
#    ...         i. A2 SCell release successfully, UE release successfully.
#    [Tags]    A006    QC_221310
#    OnlineParamChange    ${OnlineParamChange_A006}
#    SA FT high scellPrio scell will be select with actScellSwapFr1 disable
#    SA TT high scellPrio scell will be select with actScellSwapFr1 disable
#    SA TF high scellPrio scell will be select with actScellSwapFr1 disable
#    Check Wireshark Log    ${CURDIR}${/}a2a_CB008290A006${/}a2a.ini    wait_string=UEContextReleaseComplete::12
#    [Teardown]    A006_Teardown

CB008290-ET-A037_Verify_A6_config_swap_deconfig_with_DRX_bufferbased_scell_activation_when_SA_cell_same_sCellPrio_different_frame_structure
    [Documentation]
    ...    1. This user scenario describes Verify_A6_config_swap_deconfig_with_DRX_bufferbased_scell_
    ...        activation_when_SA_cell_same_sCellPrio_different_frame_structure
    ...    2. Configuration:
    ...        TDD Cell1/Cell2 configure to same frequency, TDD Cell3/Cell4 configure to another same frequency.
    ...        FDD cell11/cell12 configure to same frequency. CellDepType is set to 'SA'
    ...        frame_structure: cell1/cell3 configured 1116(tdLte); cell2/cell4 configured 1208(semiStatic)
    ...        Configure CA Relations: Cell3-Cell1, Cell3-Cell2, Cell3-Cell11, Cell3-Cell12,cell11-cell1,cell11-cell2
    ...        NRBTS-1/NRCELL-1:maxNumOfSCellAlloc = 0.All sCellPrio=1(round robin algorithm). a2SCellRel is not configured in cell 11.
    ...    3. Test Case Steps:
    ...         a. UE registers successfully and PDU session is setup successfully on cell 3. mobility A2/A3/A5 configured.
    ...            A1 measurement with a1ThresholdSCellAddSsbRsrpFDD for SCell Addition.scell :cell 11.
    ...            A6 meas configed to UE, A1 for scell change configured.DRX setup.no A2 meas for scell release configured.
    ...         b. A6 swap to cell 12.A6 meas configed to UE, A2 meas for scell release configured.
    ...            A1 scell change to cell 2, due to cell1 AC failure, A6 for scell swap, A2 for scell release configured.
    ...         c. modify the maxNumOfSCellAlloc to 250.A6 swap to cell 1.A6 meas configed to UE, A2 meas for scell release configured
    ...         d. A2 for mobility measurement report from 5G-UE, MG setup, DRX release .
    ...          inter frequency A3 to cell 11.deconfigures A2 measurement for SCell Release, new A1 for scell addition configured. drx setup.
    ...         e. A6 swap to cell 1.A6 meas configed to UE, A2 meas for scell release configured, A1 for scell change configured. DRX setup
    ...           A6 swap to cell 2.A6 meas configed to UE, A2 meas for scell release configured.
    ...         f. RRE to cell 3.all measconfig deconfigured except A1 scell addition and mobility related measconfig. DRX setup.
    ...            A1 measurement with a1ThresholdSCellAddSsbRsrpTDD for SCell Addition.scell :cell 1.
    ...           A6 swap to cell 2.A6 meas configed to UE, A2 meas for scell release configured.release UE
    ...         g. UE registers successfully and PDU session is setup successfully on cell 3. mobility A2/A3/A5 configured.
    ...            A1 measurement with a1ThresholdSCellAddSsbRsrpFDD for SCell Addition.scell :cell 12.
    ...            A6 meas configed to UE, A1 for scell change configured.DRX setup.A2 meas for scell release configured.
    ...         h. A2 scell release. A1 measurement with a1ThresholdSCellAddSsbRsrpFDD for SCell Addition.scell :cell 11.
    ...            A1 measurement with a1ThresholdSCellAddSsbRsrpTDD for SCell change.scell :cell 2. release UE
    [Tags]    A037    QC_47024
    OnlineParamChange    ${OnlineParamChange_A037}
    Ue Register to cell3 and add cell11 as scell then A6 swap to cell12
    A1 scell change to cell2 due to cell1 AC fauilure
    OnlineModify cell1 maxNumOfSCellAlloc to normal then A6 swap to cell1
    InterFreq A3 HO to cell11 and add cell1 as scell then A6 swap to cell2
    RRE to cell3 and add cell1 as cell then A6 swap to cell2
    Ue Register to cell3 and add cell12 as scell due to same priority round robin algorithm
    A2 scell release and add cell11 as scell due to same priority round robin algorithm
    A1 scell change to cell2 due to same priority round robin algorithm
    Check Wireshark Log    ${CURDIR}${/}a2a_CB008290A037${/}a2a.ini    wait_string=UEContextRelease::24
    [Teardown]    A037_Teardown

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_4T2F

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir

A006_Teardown
    OnlineParamChange    ${OnlineParam_A006_recover}
    Common Test Teardown And Stop Capture Logs

A037_Teardown
    OnlineParamChange    ${OnlineParam_A037_recover}
    Common Test Teardown And Stop Capture Logs

UE Attach To Target Cell
    [Arguments]    ${cell_id}    ${ue_id}=81
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=${gw_id} nwslice=${nwslice}    QoS Routing Table

Send Throuput
    [Arguments]    ${ue_id}=81
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=ul mbps=30 trf_id=1    UE ${ue_id}: UDP UL
    FOR    ${I}    IN RANGE    1    6
        Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=175 trf_id=${I}    UE ${ue_id}: UDP DL
    END
    sleep    60s    #sleep for stable traffic

Verify Throuput on Pscell
    [Arguments]    ${ue_id}=81    ${pcell_dl}=60    ${ul}=8
    sleep    10s    #sleep for stable traffic
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-4 type=pdsch    pass_regexp=CellIndex
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=current
    Should Be True    ${scell0_tput}/1000>${pcell_dl}
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=ul    rate_type=max
    Should Be True    ${ul_throughput}/1000>${ul}

Verify Throuput on Pscell and Scell
    [Arguments]    ${ue_id}=81    ${pcell_dl}=60    ${scell_dl}=60    ${ul}=8    ${scell_id}=1
    sleep    10s     #sleep for stable traffic
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-4 type=pdsch    pass_regexp=CellIndex
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=current
    Should Be True    ${scell0_tput}/1000 > ${pcell_dl}
    ${scell1_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${scell_id}    type=pdsch    rate_type=current
    Should Be True    ${scell1_tput}/1000 > ${scell_dl}
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=ul    rate_type=max
    Should Be True    ${ul_throughput}/1000>${ul}

UE Deregister From gNB
    [Arguments]    ${ue_id}=81
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s

SA FT high scellPrio scell will be select with actScellSwapFr1 disable
    UE attach and Scell Addtion successfully    cell_id=11    ue_id=81    pcell_dl=80    ul=25    carrierfreq=125050
    Enable testmode in FT
    Verify Throuput on Pscell and Scell    ue_id=81    pcell_dl=80    ul=25    scell_dl=1000
    Trigger ScellRel    carrierfreq=508110    ue_id=81
    Verify Throuput on Pscell    ue_id=81    pcell_dl=80    ul=25
    UE Deregister From gNB

SA TT high scellPrio scell will be select with actScellSwapFr1 disable
    UE attach and Scell Addtion successfully    cell_id=1    ue_id=81    pcell_dl=500    ul=25
    Enable testmode in TT
    Verify Throuput on Pscell and Scell    ue_id=81    pcell_dl=550    ul=25    scell_dl=300
    Trigger ScellRel    carrierfreq=508110    ue_id=81
    Verify Throuput on Pscell    ue_id=81    pcell_dl=500    ul=25
    UE Deregister From gNB

SA TF high scellPrio scell will be select with actScellSwapFr1 disable
    UE attach and Scell Addtion successfully    cell_id=1    ue_id=81    pcell_dl=500    ul=25    srsrp_nr=71    phycell_id=60
    Enable testmode in TF
    Verify Throuput on Pscell and Scell    ue_id=81    pcell_dl=500    ul=25    scell_dl=80
    Trigger ScellRel    carrierfreq=125050    ue_id=81
    Verify Throuput on Pscell    ue_id=81    pcell_dl=500    ul=25
    UE Deregister From gNB

UE attach and Scell Addtion successfully
    [Arguments]    ${cell_id}=3    ${ue_id}=81    ${pcell_dl}=700    ${ul}=130    ${carrierfreq}=648096    ${srsrp_nr}=81    ${phycell_id}=52
    UE Attach To Target Cell    ${cell_id}    ${ue_id}
    Send Throuput    ${ue_id}
    Verify Throuput on Pscell    ${ue_id}    ${pcell_dl}    ${ul}
    Trigger A1 ScellAdd    carrierfreq=${carrierfreq}    srsrp_nr=${srsrp_nr}    ue_id=${ue_id}    phycell_id=${phycell_id}

Trigger A1 ScellAdd
    [Arguments]    ${event_type}=A1    ${carrierfreq}=518910    ${srsrp_nr}=5    ${srsrq_nr}=5    ${ue_id}=81    ${phycell_id}=52
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type}
    ...    srsrp_nr=${srsrp_nr} srsrq_nr=${srsrq_nr}
    ${ret1}=    Execute Egate Command    ${cmd}    pass_regexp=rrcReconfigurationComplete
    Should Contain    ${ret1}    physCellId ${phycell_id}

Trigger ScellRel
    [Arguments]    ${event_type}=A2    ${carrierfreq}=518910    ${scell}=1    ${scell_rsrp}=30    ${ue_id}=81
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type}
    ...    scell=${scell} scell_rsrp=${scell_rsrp}
    Execute Egate Command    ${cmd}    pass_regexp=rrcReconfigurationComplete

Trigger ScellSwap
    [Arguments]    ${event_type}=A6    ${carrierfreq}=648096    ${nrsrp_nr}=63    ${nrsrq_nr}=20    ${ue_id}=81    ${scell_id}=1
    ...    ${phycell_id}=61
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type}
    ...    srsrp_nr=11 srsrq_nr=11 scell=${scell_id} scell_rsrp=20 scell_rsrq=20 phycell_id=${phycell_id} nrsrp_nr=${nrsrp_nr} nrsrq_nr=${nrsrq_nr}
    Execute Egate Command    ${cmd}    pass_regexp=rrcReconfigurationComplete

trigger A3 event
    [Arguments]    ${event_type}=A3    ${carrierfreq}=125050    ${srsrp_nr}=11    ${srsrq_nr}=11    ${ue_id}=81
    ...    ${phycell_id}=60    ${nrsrp_nr}=80    ${nrsrq_nr}=80
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type} srsrp_nr=${srsrp_nr}
    ...    srsrq_nr=${srsrq_nr} phycell_id=${phycell_id} nrsrp_nr=${nrsrp_nr} nrsrq_nr=${nrsrq_nr}
    ${ret1}=    Execute Egate Command    ${cmd}
    ...    pass_regexp=rrcReconfigurationComplete

RRC reestablish trigger
    [Arguments]    ${ue_id}=81    ${cell_id}=3
    ${cmd}    Catenate    ue_rrc_reestablish id=${ue_id} gnb=2 cell=${cell_id} cause=otherFailure
    Execute Egate Command    ${cmd}    pass_regexp=rrcReconfigurationComplete

Ue Register to cell3 and add cell11 as scell then A6 swap to cell12
    UE attach and Scell Addtion successfully    cell_id=3    carrierfreq=508110    pcell_dl=500    ul=25    srsrp_nr=71    phycell_id=60
    Enable testmode in TF
#    Verify Throuput on Pscell and Scell    ue_id=81    pcell_dl=500    ul=25    scell_dl=80    #step 1~2
    Trigger ScellSwap    carrierfreq=125050    scell_id=1    phycell_id=61
    Enable testmode in TF    scell_id=2
#    Verify Throuput on Pscell and Scell    ue_id=81    scell_id=2    pcell_dl=500    ul=25    scell_dl=80    #step 3

A1 scell change to cell2 due to cell1 AC fauilure
    Trigger A1 ScellAdd    carrierfreq=508110    srsrp_nr=100    ue_id=81    phycell_id=52
    Enable testmode in TT
    Verify Throuput on Pscell and Scell    ue_id=81    pcell_dl=200    ul=25    scell_dl=350    #step 4

OnlineModify cell1 maxNumOfSCellAlloc to normal then A6 swap to cell1
    OnlineParamChange    @{maxNumOfSCellAllocChange_A037}    #step 5
    Trigger ScellSwap    carrierfreq=648096    scell_id=1    phycell_id=50    #step 6
    Enable testmode in TT    scell_id=2
    Verify Throuput on Pscell and Scell    ue_id=81    scell_id=2    pcell_dl=300    ul=25    scell_dl=300

InterFreq A3 HO to cell11 and add cell1 as scell then A6 swap to cell2
    Trigger A1 ScellAdd    event_type=A2    carrierfreq=508110    srsrp_nr=30    ue_id=81    #step 7
    trigger A3 event    carrierfreq=125050    #step 8
    Enable testmode in FT
    Verify Throuput on Pscell    ue_id=81    pcell_dl=0    ul=25
    Trigger A1 ScellAdd    carrierfreq=125050    srsrp_nr=100    ue_id=81    phycell_id=50    #step 9
    Verify Throuput on Pscell and Scell    ue_id=81    pcell_dl=0    ul=25    scell_dl=300
    Trigger ScellSwap    carrierfreq=648096    scell_id=1    phycell_id=51    #step 10
    Enable testmode in FT    scell_id=2
    Verify Throuput on Pscell and Scell    ue_id=81    scell_id=2    pcell_dl=0    ul=25    scell_dl=300

RRE to cell3 and add cell1 as cell then A6 swap to cell2
    RRC reestablish trigger    #step 11
    Enable testmode in TT
    Verify Throuput on Pscell    ue_id=81    pcell_dl=0    ul=25
    Trigger A1 ScellAdd    carrierfreq=508110    srsrp_nr=100    ue_id=81    phycell_id=50    #step 12
    Verify Throuput on Pscell and Scell    ue_id=81    pcell_dl=300    ul=25    scell_dl=300
    Trigger ScellSwap    carrierfreq=648096    scell_id=1    phycell_id=51    #step 13
    Enable testmode in TT    scell_id=2
    Verify Throuput on Pscell and Scell    ue_id=81    scell_id=2    pcell_dl=300    ul=25    scell_dl=300
    UE Deregister From gNB    81    #step 14

Ue Register to cell3 and add cell12 as scell due to same priority round robin algorithm
    UE attach and Scell Addtion successfully    cell_id=3    carrierfreq=508110    pcell_dl=500    ul=25    srsrp_nr=71    phycell_id=61
    Enable testmode in TF
    Verify Throuput on Pscell and Scell    ue_id=81    pcell_dl=500    ul=25    scell_dl=0    #step 15~16

A2 scell release and add cell11 as scell due to same priority round robin algorithm
    Trigger ScellRel    carrierfreq=125050    ue_id=81    #step 17
    Verify Throuput on Pscell    ue_id=81    pcell_dl=500    ul=25
    Trigger A1 ScellAdd    carrierfreq=508110    srsrp_nr=71    ue_id=81    phycell_id=60    #step 18
    Enable testmode in TF
    Verify Throuput on Pscell and Scell    ue_id=81    pcell_dl=500    ul=25    scell_dl=0

A1 scell change to cell2 due to same priority round robin algorithm
    Enable testmode in TT
    Trigger A1 ScellAdd    carrierfreq=508110    srsrp_nr=100    ue_id=81    phycell_id=51    #step 19
    Enable testmode in TT    scell_id=2
    Verify Throuput on Pscell and Scell    ue_id=81    scell_id=2    pcell_dl=300    ul=25    scell_dl=350
    UE Deregister From gNB    81    #step 20

Enable testmode in FT
    [Arguments]    ${ue_id}=81    ${scell_id}=1
    Execute Egate Command    csi_override_testmode_nr profile_id=1 cqi_mode=fixed cqi=15 ri_mode=fixed ri=1    pass_regexp=numOfCri
    Execute Egate Command    csi_override_testmode_nr profile_id=2 cqi_mode=fixed cqi=15 ri_mode=fixed ri=3    pass_regexp=numOfCri
    Execute Egate Command    ue_testmode_set_nr id=${ue_id} testmode=csi_override action=activate profile_id=1 scell=0    pass_regexp=profileId
    ${cmd}    Catenate    ue_testmode_set_nr id=${ue_id} testmode=csi_override action=activate profile_id=2 scell=${scell_id}
    Execute Egate Command    ${cmd}    pass_regexp=profileId

Enable testmode in TT
    [Arguments]    ${ue_id}=81    ${scell_id}=1
    Execute Egate Command    csi_override_testmode_nr profile_id=1 cqi_mode=fixed cqi=15 ri_mode=fixed ri=3    pass_regexp=numOfCri
    Execute Egate Command    csi_override_testmode_nr profile_id=2 cqi_mode=fixed cqi=15 ri_mode=fixed ri=3    pass_regexp=numOfCri
    Execute Egate Command    ue_testmode_set_nr id=${ue_id} testmode=csi_override action=activate profile_id=1 scell=0    pass_regexp=profileId
    ${cmd}    Catenate    ue_testmode_set_nr id=${ue_id} testmode=csi_override action=activate profile_id=2 scell=${scell_id}
    Execute Egate Command    ${cmd}    pass_regexp=profileId

Enable testmode in TF
    [Arguments]    ${ue_id}=81    ${scell_id}=1
    Execute Egate Command    csi_override_testmode_nr profile_id=1 cqi_mode=fixed cqi=15 ri_mode=fixed ri=3    pass_regexp=numOfCri
    Execute Egate Command    csi_override_testmode_nr profile_id=2 cqi_mode=fixed cqi=15 ri_mode=fixed ri=1    pass_regexp=numOfCri
    Execute Egate Command    ue_testmode_set_nr id=${ue_id} testmode=csi_override action=activate profile_id=1 scell=0    pass_regexp=profileId
    ${cmd}    Catenate    ue_testmode_set_nr id=${ue_id} testmode=csi_override action=activate profile_id=2 scell=${scell_id}
    Execute Egate Command    ${cmd}    pass_regexp=profileId
