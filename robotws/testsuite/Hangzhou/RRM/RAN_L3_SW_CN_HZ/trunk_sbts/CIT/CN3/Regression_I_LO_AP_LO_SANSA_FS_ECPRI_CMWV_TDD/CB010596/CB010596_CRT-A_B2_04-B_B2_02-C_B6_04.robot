*** Settings ***
Suite Setup       Common Suite Setup And Setup IPHY Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    CIT    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...               team-CN3ET    owner-lishuo.geng    release-SBTS23R4
Resource          ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_VENDOR}
...    maxNumOfUserL2Pool=200    maxNumOfDRBL2Pool=400    maxNumOfGBRL2Pool=200    guaranteedResourceRatioPerCell=5
...    maxNumPucchF1SRPerSlotL1Pool=1    maxNumPucchF3PCSIPerSlotL1Pool=1
${GNB1_CONFIG}    tdd_sansa_cmwv/FS/2cells_ecpri

@{PARAMS_IN_SWCONFIG}
...    ${rdPCsiPoolHkfPeriod_min}
...    ${rdHkfMinPCsiResPerSlot}
...    ${rdHkfMinPCsiRepPeriod}
...    ${rdHkfPCsiPoolMaxRCUsFactor}
...    ${uplane_6878}
...    0x300000=1
...    0x300001=1
...    0x30001C=1

${rdPCsiPoolHkfPeriod_min}    0x5901A6=1
${rdHkfMinPCsiResPerSlot}    0x5901A7=4
${rdHkfMinPCsiRepPeriod}    0x5901A8=40
${rdHkfPCsiPoolMaxRCUsFactor}    0x5901A9=60
${uplane_6878}    0x5901AB=1

@{PARAMS_IN_SCF}
...    @{PARAMS_8X4_CELLMAPPING}
...    @{5GC000704}
...    @{5GC00572}
...    @{CB006878}
...    @{beamforming}
...    @{2200_enable}


@{CB010596_set_1OCC_Harq_set_by_system_and_6878_on}
...    @{CB006878}
...    NRCELL:actLongPucchResourceOpt=true
...    NRCELL:actIncreasedFdmUsersPerSlot=true
...    NRCELL:pucchF1ResOccConf=1-1-0_OCCs
...    NRCELL:pucchNumberHarqAnPrbs=Set_by_system
...    NRCELL:srPeriodicity=slots20    NRCELL:periodicCsiAcquisition:csiReportPeriodicity=slots160
...    NRCELL:reqMinNumPuschPrb=23
...    NRCELL:actAdaptiveSr=false
...    NRCELL:actShortBsrLimitAdaptation=false
...    NRBTS:actBbPoolTddFr1=true
...    NRBTS:actBbPoolExtensionTddFr1=true
...    NRBTS:actBbPoolTddFr1AlgEnh=true     NRBTS:actLargeBbPoolTddFr1=true    NRBTS:actBbPoolTddFr1Enh=true

@{CB010596_set_2OCC_Harq_set_by_system_and_8847_on}
...    @{8847}
...    NRCELL:actLongPucchResourceOpt=true
...    NRCELL:actIncreasedFdmUsersPerSlot=true
...    NRCELL-1:pucchF1ResOccConf=2-2-1_OCCs
...    NRCELL-2:pucchF1ResOccConf=1-1-0_OCCs
...    NRCELL:pucchNumberHarqAnPrbs=Set_by_system
...    NRCELL-1:srPeriodicity=slots20    NRCELL-1:periodicCsiAcquisition:csiReportPeriodicity=slots160
...    NRCELL-2:srPeriodicity=slots40    NRCELL-2:periodicCsiAcquisition:csiReportPeriodicity=slots160
...    NRCELL:reqMinNumPuschPrb=213


@{CB010596_set_2OCC_Harq_set_by_operator_4PRBs_and_6878_on}
...    @{CB006878}
...    NRCELL:actLongPucchResourceOpt=true
...    NRCELL:actIncreasedFdmUsersPerSlot=true
...    NRCELL:pucchF1ResOccConf=2-2-0_OCCs
...    NRCELL:pucchNumberHarqAnPrbs=4_PRBs
...    NRCELL:srPeriodicity=slots20    NRCELL:periodicCsiAcquisition:csiReportPeriodicity=slots80
...    NRCELL:reqMinNumPuschPrb=23
...    NRCELL:actShortBsrLimitAdaptation=false
...    NRBTS:actBbPoolTddFr1=false
...    NRBTS:actBbPoolExtensionTddFr1=false

@{CB006878}
...    NRCELL:actDynUlResAlloc=true
...    NRCELL:pucchModeSelect=longPucch
...    NRBTS:srbInactivityTimerSA=600
...    NRBTS:nsaInactivityTimer=600


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

@{PARAMS_8X4_CELLMAPPING}
# CELL1 mapping
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-1:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-1:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-2:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-2:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-3:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-3:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-4:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-4:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-7:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-7:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-8:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-8:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2/CHANNEL-1:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2/CHANNEL-1:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2/CHANNEL-2:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2/CHANNEL-2:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2/CHANNEL-3:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2/CHANNEL-3:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2/CHANNEL-4:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2/CHANNEL-4:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
# CELL2 mapping
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-1:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-1:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-2:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-2:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-3:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-3:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-4:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-4:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-5:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-6:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-7:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-7:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-8:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-8:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-2
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-2/CHANNEL-1:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-2/CHANNEL-1:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-2/CHANNEL-2:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-2/CHANNEL-2:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-2/CHANNEL-3:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-2/CHANNEL-3:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-2/CHANNEL-4:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-2/CHANNEL-4:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1

@{beamforming}
...    NRCELL:beamSet:basicBeamSet=beamSet_6
...    delete:NRCELL:periodicCsiAcquisition:csirsNumberWithinReportPeriod_Set1
...    delete:NRCELL:periodicCsiAcquisition:csirsPower
...    delete:NRCELL:periodicCsiAcquisition:maxCsirsNumber
...    NRCELL:msg1FrequencyStart=14
...    NRCELL:nrofHARQProcessesForPDSCH=16
...    NRCELL:openLoopScheme=NoPrecoding
...    NRCELL:type0SearchSpaceConfigurationIndex=5
...    NRCELL:zeroCorrelationZoneConfig=13
...    NRCELLGRP-0:numberOfTransmittedSsBlocks=6 beams
...    NRCELLGRP-1:numberOfTransmittedSsBlocks=6 beams
...    NRBTS:actFdmEnhancedScheduling=true
...    NRCELL:actBeamforming=true
...    NRCELL:nrCellType=8DL4UL
...    NRCELL:dlMimoMode=2x2 Open Loop Spatial Multiplexing
...    NRCELL:numOfSubSectors=0sub-sector
...    NRCELL:numberOfRxBeamforming=4Rx

${default_ue_capability}    SEPARATOR=
...    e1a00000074e5a031e000380a03c1260c80008780818806804c020301c032a36146b04050d012cb2898087ad8202020e1de38720c3800206
...    4f1f570004f001c0013c002a36266b04050d012cb2898087ad8202020e1de38720c38002064f1f570004f001c0013c002a3626eb04050d01
...    2cb2898087ad8202020e1de38720c38002064f1f570004f001c0013c002a36276b04050d012cb2898087ad8202020e1de38720c38002064f
...    1f55000005000000108389a00000000404d0103804044f60701800140e020381801c07000683e0000000000000e54d000100000965950034
...    aaa8081c002c000000100200462c4c0004080c1014181c202c4044484c648494989ca128

@{2200_enable}
...    NRCELL:dlMimoMode=8x4 Closed Loop Spatial Multiplexing
...    NRCELL:periodicCsiAcquisition:csirsPower=0
...    NRCELL:periodicCsiAcquisition:csirsNumberWithinReportPeriod_Set1=1
...    NRCELL:periodicCsiAcquisition:maxCsirsNumber=2
...    NRCELL:ssPbchBlockPower=0
...    NRCELL:actCsirsMultiplexing=true

@{8847}
...    NRCELL:actShortBsrLimitAdaptation=true
...    NRBTS:actBbPoolTddFr1=true
...    NRBTS:actBbPoolExtensionTddFr1=true
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=3|searchSpaceId=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n1|searchSpaceId=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n2|searchSpaceId=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceId=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n4|searchSpaceId=2
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=2
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=3|searchSpaceId=3
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n1|searchSpaceId=3
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=3
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n2|searchSpaceId=3
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceId=3
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=3
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=3|searchSpaceId=4
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n1|searchSpaceId=4
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=4
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n2|searchSpaceId=4
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceId=4
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=4
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n4|searchSpaceId=5
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=5
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=3|searchSpaceId=6
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n1|searchSpaceId=6
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=6
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n2|searchSpaceId=6
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceId=6
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=6
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=6
...    NRBTS/NRSYSINFO_PROFILE-1:systemInformationTargetRate=251
...    NRCELL:fPdcchMonOccsnPo=2

${SYSCOM_FLAG}    true

*** Test Cases ***
CB010596-SR-A-B2_ET_04_01_pucchF1ResOccConf set with 1OCC And Check SR and HARQ Resource when single BWP with 100M chBW 
    [Documentation]
    ...    Below calculate changed due to bbpool enforce enable in new build, then similar as case_CB010596-SR-C-B6_ET_04_01
    ...    _actLongPucchResourceOpt activation with LongPucch TDD FR1 when bbpooling enable with csi rs reconfig
    ...    6878 on + single BWP
    ...    cell: numSrPrbsPerSlot = 6 numHarqF1PrbsPerSlot = 16 numCsiReportsPerSlot = 14 numPrbsPerCsiReport = 1 sr resource per slot=28
    ...    pucchsize=PRB(SR)+PRB(HARQ_AN)+k*PRB(pCSI)=6+16+14*1=36
    ...    SR PRB:(0,1,2,272,271,270) slot:(4,9,14,19)
    ...    HARQ PRB:(3,4,5,6,7,8,9,10,269,268,267,266,265,264,263,262)
    ...    CSI PRB:(11,12,13,14,15,16,17,261,260,259,258,257,256,255) slot:(4,9,14,19)
    ...    cell-1 SR OCC:0 CS:(6,2,10,4,8,0) HARQ F1 PRB:{(3,269)(4,268)(5,267)(6,266)} OCC:2 CS:(0,2,4,6,8,10) HARQ F3: (262,10,263,9,264,8,263,7)
    ...    cell-2 SR OCC:2 CS:(7,3,11,5,9,1) HARQ F1 PRB:{(269,4)(268,5)(267,6)(266,3)} OCC:1 CS:(0,2,4,6,8,10) HARQ F3: (7,262,10,263,9,264,8,263)
    [Tags]
    Online Change And Wait Cell Onair    ${CB010596_set_1OCC_Harq_set_by_system_and_6878_on}
    Start To Capture Wireshark Log    cellsetup
    Lock And Unlock cell to make sure UE position no change And Check Pucch Size    cell_id=1    pucchsize=20
    Lock And Unlock cell to make sure UE position no change And Check Pucch Size    cell_id=2    pucchsize=20
    Check PUSCH PRB And Common Pucch In L2PS Msg    case_id=A_B2_04
    Register And Set up PDU For Number Of Normal Calls    cell_id=1    ue_id_start=1    ue_id_end_before=5
    Register For Normal Call Fail Due To RAC Failure    cell_id=1    ue_id=5
    Register And Set up PDU For Number Of Normal Calls    cell_id=2    ue_id_start=5    ue_id_end_before=9
    Register For Normal Call Fail Due To RAC Failure    cell_id=2    ue_id=10
    #below step obsolete due to BBpool enforce enable in new trunk build
#    Attach Multi UEs And Check PUCCH Resource For Cell And Then Release All UEs    cell_id=1    ue_count=112    case_id=A_B2_04
#    Attach Multi UEs And Check PUCCH Resource For Cell And Then Release All UEs    cell_id=2    ue_count=112    case_id=A_B2_04
	
*** Keywords ***
Common Suite Setup And Setup IPHY Env
    Common Suite Setup
    Setup Airphone Env    tl_type=${GNB1_CONFIG}
	
Modify Cfg
    Set Multi UEs in WTS


Set Multi UEs in WTS
    ${cfg_cmd_3}    catenate
    ...    uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...    nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g sec_key=0102030405060708090A0B0C0D0EFF00
    FOR    ${ue_id}    IN RANGE    61    100
        Update Cfg    set_ue simulated id=${ue_id} ${cfg_cmd_3} suci=0:311:489:0000:0:0:0216454${ue_id} mode=nr enb=2 cell=1
        Update Cfg    ue_param id=${ue_id} ue_nr_capabilities=${default_ue_capability}
    END
    FOR    ${ue_id}    IN RANGE    100    113
        Update Cfg    set_ue simulated id=${ue_id} ${cfg_cmd_3} suci=0:311:489:0000:0:0:021645${ue_id} mode=nr enb=2 cell=1
        Update Cfg    ue_param id=${ue_id} ue_nr_capabilities=${default_ue_capability}
    END
	
Lock And Unlock cell to make sure UE position no change And Check Pucch Size
    [Arguments]    ${cell_id}    ${pucchsize}
    Lock Cell${cell_id}
    Unlock Cell${cell_id}
    Cells Should Be Onair    ${cell_id}
    object should exist    NRCELL-${cell_id}:pucchConfig:pucchSize=${pucchsize}
	
Check PUSCH PRB And Common Pucch In L2PS Msg
    [Arguments]    ${case_id}
    Check Wireshark Log    ${CURDIR}${/}a2a_${case_id}${/}cellsetup.ini    wait_string=itf_l2_ps_cell_CellSetupReq::6
    ...    name=cellsetup

	
Online Change And Wait Cell Onair
    [Arguments]    ${parameters}
    delta commission parameters    ${parameters}
    Cells Should Be Onair

	
Register For Normal Call Successfully
  [Arguments]    ${ue_id}    ${cell_id}
  Execute Egate Command    ue_change_location id=${ue_id} cell=${cell_id}    ${cell_id}
  Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Reg
  
	
Register For Number Of Normal Calls
    [Arguments]    ${cell_id}    ${ue_id_start}    ${ue_id_end_before}
    FOR    ${ue_id}    IN RANGE    ${ue_id_start}    ${ue_id_end_before}
        Register For Normal Call Successfully    ${ue_id}    ${cell_id}
    END

UE Attach To ENB And Set ENDC
    [Arguments]    ${ue_id}    ${cell_id}
    Execute Egate Command    ue_attach id=${ue_id} profile=1    UE IS ACTIVE
    Execute Egate Command    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${cell_id} bearer=2 type=split_scg    reported successful RA

Attach And Set ENDC For Number Of Normal Calls
    [Arguments]    ${cell_id}    ${ue_id_start}    ${ue_id_end_before}
    FOR    ${ue_id}    IN RANGE    ${ue_id_start}    ${ue_id_end_before}
        UE Attach To ENB And Set ENDC    ${ue_id}    ${cell_id}
    END
	
Check PUCCH Size For Cell
    [Arguments]    ${cell_id}    ${pucchsize}
    object should exist    NRCELL-${cell_id}:pucchConfig:pucchSize=${pucchsize}
    
	
Attach Multi UEs And Check PUCCH Resource For Cell And Then Release All UEs
    [Arguments]    ${cell_id}    ${ue_count}    ${case_id}
    Start To Capture Wireshark Log    cell${cell_id}
    Register For Number Of Normal Calls    cell_id=${cell_id}    ue_id_start=1    ue_id_end_before=31
    Attach And Set ENDC For Number Of Normal Calls    cell_id=${cell_id}    ue_id_start=31    ue_id_end_before=61
    Register For Number Of Normal Calls    cell_id=${cell_id}    ue_id_start=61    ue_id_end_before=${ue_count}+1
    Check Pucch Resource    ${CURDIR}${/}a2a_${case_id}${/}pucch_cell${cell_id}.ini    ${ue_count}    cell${cell_id}
    Release Ues    ue_type=all    

Register And Set up PDU For Normal Call Successfully
    [Arguments]    ${ue_id}    ${cell_id}
    Register For Normal Call Successfully    ${ue_id}    ${cell_id}
    UE PDU Session Setup    ${ue_id}    ${ue_id}

Register And Set up PDU For Number Of Normal Calls
    [Arguments]    ${cell_id}    ${ue_id_start}    ${ue_id_end_before}
    FOR    ${ue_id}    IN RANGE    ${ue_id_start}    ${ue_id_end_before}
        Register And Set up PDU For Normal Call Successfully    ${ue_id}    ${cell_id}
    END
	
UE PDU Session Setup
    [Arguments]    ${ue_id}    ${gw_id}
    Execute Egate Command    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=${gw_id}    QoS Routing Table

Register For Normal Call Fail Due To RAC Failure
    [Arguments]    ${ue_id}    ${cell_id}
    UE Register To GNB Due To RAC Failure    ${ue_id}    ${cell_id}

UE Register To GNB Due To RAC Failure
    [Arguments]    ${ue_id}    ${cell_id}
    Execute Egate Command    ue_change_location id=${ue_id} cell=${cell_id}    ${cell_id}
    ${res}    Execute Egate Command    ue_register id=${ue_id}    detached
    Should Contain    ${res}    rrcReject

Teardown For Debug Delta Commission
    Sleep    120s    #monitor delta commission admin api timeout
    Common Test Teardown And Stop Capture Logs