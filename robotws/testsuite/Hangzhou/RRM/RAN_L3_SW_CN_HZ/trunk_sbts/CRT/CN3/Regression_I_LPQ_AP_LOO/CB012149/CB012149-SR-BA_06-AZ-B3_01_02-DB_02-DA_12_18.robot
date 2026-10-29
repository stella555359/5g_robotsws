*** Settings ***
Documentation
...    author: Lishuo Geng
...    contact: lishuo.geng@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup       Start BTS With Specified Config Files
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_FDD    CLOUD_5G_I_LPQ_AP_LOO
...               team-CN3ET    owner-tom.li    release-SBTS24R3    CB012149
Resource          ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_VENDOR}
...    maxNumOfUserL2Pool=100    maxNumOfDRBL2Pool=100    maxNumOfGBRL2Pool=50    guaranteedResourceRatioPerCell=10
...    maxNumPucchF1SRPerSlotL1Pool=50    maxNumPucchF3PCSIPerSlotL1Pool=1

${GNB_CONFIG}    fddtdd_sansa_cmwv/6cells_2T4F
${SYSCOM_FLAG}    true

# if FDD cells have a bandwidth > 25MHz, need configure FR1_WB
@{PARAMS_IN_IPHY_XML}    fddFrequencyRange=FR1_WB

@{PARAMS_IN_SWCONFIG}
...    @{AaSysLogOutputMode}
...    @{AaSysLogOutputLevel}
...    @{AaSysLogInputLevel}
...    @{BSTAT_PM_debug_prints}
...    @{enable_measurement_flag}
...    @{rdULCaEnablerPhase}
...    @{rdUseOptimizedDpaAlgo}
...    ${CB007015_disable}
...    ${ActL2CellSlotModelExtension_disable}
...    ${BBbPoolSkipChecks_disable}
${CB007015_disable}    0x4F030E=1
${ActL2CellSlotModelExtension_disable}    0x60000B=1
${BBbPoolSkipChecks_disable}    0x60000C=1
@{AaSysLogOutputMode}
...    0x10041 = 5
@{AaSysLogOutputLevel}
...    0x10040 = 1
@{AaSysLogInputLevel}
...    0x1003F = 1
@{BSTAT_PM_debug_prints}
...    0x340002 = 1
@{enable_measurement_flag}
...    0x340006 = 55118
@{rdULCaEnablerPhase}
...    0x580591=0
@{rdUseOptimizedDpaAlgo}
...    0x58056B=1

@{PARAMS_IN_SCF}
...    @{CB012149_enable}
...    @{CB009169_CB006137_enable}
...    @{CA}
...    @{NRREL}
...    @{Mobillity}
...    @{Others}
...    @{gscn_Arfcn}
...    @{5GC000704}
...    @{dlToUlContributionRatio50 and frameStructureType semiStatic}
...    @{5GC002396}
...    @{CB006086}
...    @{5GC002426}
...    @{beamforming}
...    @{PARAMS_8X4_CELLMAPPING}
...    @{CB008698}
...    @{CB008232}
...    @{5GC000784}
...    @{VONR}
...    @{5GC000707_InterRAT}
...    NRCELL:pMaxNROwnCell=31

@{A4basedCA}
...    @{change_pcsi_resourse_enough}
...    @{CB008311_enable}
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based,A4-based
...    NRCELL-13:a4PeriodicMeasControlSA:a4RetryTimer=3
...    NRCELL-13:a4PeriodicMeasControlSA:a4Fr1SupervisionTimer=10000
...    NRCELL-13/NRREL-1:sCellAdditionMethod=covBasedA4
...    NRCELL-13/NRREL-1:actA4ToA1BasedSCellFallbackNsa=false
...    NRCELL-13/NRREL-2:sCellAdditionMethod=covBasedA4
...    NRCELL-13/NRREL-2:actA4ToA1BasedSCellFallbackNsa=false
...    NRCELL-13/NRREL-3:sCellAdditionMethod=covBasedA4
...    NRCELL-13/NRREL-3:actA4ToA1BasedSCellFallbackNsa=false
...    NRCELL-13/NRREL-4:sCellAdditionMethod=covBasedA4
...    NRCELL-13/NRREL-4:actA4ToA1BasedSCellFallbackNsa=false
#...    NRCELL-13/NRREL-5:sCellAdditionMethod=covBasedA4
#...    NRCELL-13/NRREL-5:actA4ToA1BasedSCellFallbackNsa=false
...    NRCELL-13/NRHOIF-1:a4MeasSCellAddEnabled=rsrp
...    NRCELL-13/NRHOIF-1:a4MeasSCellAddSsbRsrp:a4ThresholdSCellAddSsbRsrp=60
...    NRCELL-13/NRHOIF-1:a4MeasSCellAddSsbRsrp:a4HysteresisSCellAddSsbRsrp=0
...    NRCELL-13/NRHOIF-2:a4MeasSCellAddEnabled=rsrp
...    NRCELL-13/NRHOIF-2:a4MeasSCellAddSsbRsrp:a4ThresholdSCellAddSsbRsrp=60
...    NRCELL-13/NRHOIF-2:a4MeasSCellAddSsbRsrp:a4HysteresisSCellAddSsbRsrp=0
...    NRCELL-13/NRHOIF-3:a4MeasSCellAddEnabled=rsrp
...    NRCELL-13/NRHOIF-3:a4MeasSCellAddSsbRsrp:a4ThresholdSCellAddSsbRsrp=60
...    NRCELL-13/NRHOIF-3:a4MeasSCellAddSsbRsrp:a4HysteresisSCellAddSsbRsrp=0
...    NRCELL-13/NRHOIF-4:a4MeasSCellAddEnabled=rsrp
...    NRCELL-13/NRHOIF-4:a4MeasSCellAddSsbRsrp:a4ThresholdSCellAddSsbRsrp=60
...    NRCELL-13/NRHOIF-4:a4MeasSCellAddSsbRsrp:a4HysteresisSCellAddSsbRsrp=0
...    NRCELL-13/NRHOIF-5:a4MeasSCellAddEnabled=rsrp
...    NRCELL-13/NRHOIF-5:a4MeasSCellAddSsbRsrp:a4ThresholdSCellAddSsbRsrp=60
...    NRCELL-13/NRHOIF-5:a4MeasSCellAddSsbRsrp:a4HysteresisSCellAddSsbRsrp=0
...    NRCELL-2:a4PeriodicMeasControlSA:a4RetryTimer=1
...    NRCELL-2:a4PeriodicMeasControlSA:a4Fr1SupervisionTimer=10000
...    NRCELL-2/NRREL-1:sCellAdditionMethod=covBasedA4
...    NRCELL-2/NRREL-1:actA4ToA1BasedSCellFallbackNsa=false
...    NRCELL-2/NRREL-2:sCellAdditionMethod=covBasedA4
...    NRCELL-2/NRREL-2:actA4ToA1BasedSCellFallbackNsa=false
...    NRCELL-2/NRREL-3:sCellAdditionMethod=covBasedA4
...    NRCELL-2/NRREL-3:actA4ToA1BasedSCellFallbackNsa=false
...    NRCELL-2/NRREL-4:sCellAdditionMethod=covBasedA4
...    NRCELL-2/NRREL-4:actA4ToA1BasedSCellFallbackNsa=false
...    NRCELL-2/NRREL-5:sCellAdditionMethod=covBasedA4
...    NRCELL-2/NRREL-5:actA4ToA1BasedSCellFallbackNsa=false
...    NRCELL-2/NRHOIF-1:a4MeasSCellAddEnabled=rsrp
...    NRCELL-2/NRHOIF-1:a4MeasSCellAddSsbRsrp:a4ThresholdSCellAddSsbRsrp=60
...    NRCELL-2/NRHOIF-1:a4MeasSCellAddSsbRsrp:a4HysteresisSCellAddSsbRsrp=0
...    NRCELL-2/NRHOIF-2:a4MeasSCellAddEnabled=rsrp
...    NRCELL-2/NRHOIF-2:a4MeasSCellAddSsbRsrp:a4ThresholdSCellAddSsbRsrp=60
...    NRCELL-2/NRHOIF-2:a4MeasSCellAddSsbRsrp:a4HysteresisSCellAddSsbRsrp=0
...    NRCELL-2/NRHOIF-3:a4MeasSCellAddEnabled=rsrp
...    NRCELL-2/NRHOIF-3:a4MeasSCellAddSsbRsrp:a4ThresholdSCellAddSsbRsrp=60
...    NRCELL-2/NRHOIF-3:a4MeasSCellAddSsbRsrp:a4HysteresisSCellAddSsbRsrp=0
...    NRCELL-2/NRHOIF-4:a4MeasSCellAddEnabled=rsrp
...    NRCELL-2/NRHOIF-4:a4MeasSCellAddSsbRsrp:a4ThresholdSCellAddSsbRsrp=60
...    NRCELL-2/NRHOIF-4:a4MeasSCellAddSsbRsrp:a4HysteresisSCellAddSsbRsrp=0
#...    NRCELL-2/NRHOIF-5:a4MeasSCellAddEnabled=rsrp
#...    NRCELL-2/NRHOIF-5:a4MeasSCellAddSsbRsrp:a4ThresholdSCellAddSsbRsrp=60
#...    NRCELL-2/NRHOIF-5:a4MeasSCellAddSsbRsrp:a4HysteresisSCellAddSsbRsrp=0

@{disable-A4}
...    @{NRREL}
...    @{CB008311_disable}
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based

@{5GC002426}
...    NRBTS:actConnRrcPooling=true
...    NRBTS:actScheUePooling=true
...    NRCELL:srPeriodicity=slots20
...    NRCELL-1:periodicCsiAcquisition:csiReportPeriodicity=slots320
...    NRCELL-2:periodicCsiAcquisition:csiReportPeriodicity=slots320
...    NRCELL-11:periodicCsiAcquisition:csiReportPeriodicity=slots20
...    NRCELL-12:periodicCsiAcquisition:csiReportPeriodicity=slots20
...    NRCELL-13:periodicCsiAcquisition:csiReportPeriodicity=slots20
...    NRCELL-14:periodicCsiAcquisition:csiReportPeriodicity=slots20
@{beamforming}
...    NRCELL-13/NRCELL_FDD-1:actPerCsiReportBundlingFdd=true
...    NRCELL-1:actCDrx=false
...    NRCELL-1:beamSet:basicBeamSet=beamSet_6
...    NRCELL-1:periodicCsiAcquisition:csirsPower=10
...    NRCELL-1:periodicCsiAcquisition:csirsNumberWithinReportPeriod_Set1=1
...    NRCELL-1:periodicCsiAcquisition:maxCsirsNumber=4
...    NRCELL-1:ssPbchBlockPower=10
...    NRCELL-1:fPdcchMonOccsnPo=3
...    NRCELL-1:msg1FrequencyStart=14
...    NRCELL-1:nrofHARQProcessesForPDSCH=16
...    NRCELL-1:openLoopScheme=NoPrecoding
...    NRCELL-1:type0SearchSpaceConfigurationIndex=5
...    NRCELL-1:zeroCorrelationZoneConfig=13
...    NRCELL-1:csirsForTracking:csirsTrackingPeriod=80ms
...    NRCELL-1:actCsirsMultiplexing=true
...    NRCELLGRP-3:numberOfTransmittedSsBlocks=6 beams
...    NRBTS:actFdmEnhancedScheduling=true
...    NRCELL-1:actBeamforming=true
...    NRCELL-1:nrCellType=8DL4UL
...    NRCELL-1:dlMimoMode=8x4 Closed Loop Spatial Multiplexing
...    NRCELL-1:numOfSubSectors=0sub-sector
...    NRCELL-1:numberOfRxBeamforming=4Rx
...    NRCELL-1:actPerCsiReportBundlingTddFr1=false
...    NRCELL-2:beamSet:basicBeamSet=beamSet_6
...    NRCELL-2:periodicCsiAcquisition:csirsPower=10
...    NRCELL-2:periodicCsiAcquisition:csirsNumberWithinReportPeriod_Set1=1
...    NRCELL-2:periodicCsiAcquisition:maxCsirsNumber=4
...    NRCELL-2:ssPbchBlockPower=10
...    NRCELL-2:fPdcchMonOccsnPo=3
...    NRCELL-2:msg1FrequencyStart=14
...    NRCELL-2:nrofHARQProcessesForPDSCH=16
...    NRCELL-2:openLoopScheme=NoPrecoding
...    NRCELL-2:type0SearchSpaceConfigurationIndex=5
...    NRCELL-2:zeroCorrelationZoneConfig=13
...    NRCELL-2:csirsForTracking:csirsTrackingPeriod=80ms
...    NRCELL-2:actCsirsMultiplexing=true
...    NRCELLGRP-4:numberOfTransmittedSsBlocks=6 beams
...    NRCELL-2:actBeamforming=true
...    NRCELL-2:nrCellType=8DL4UL
...    NRCELL-2:dlMimoMode=8x4 Closed Loop Spatial Multiplexing
...    NRCELL-2:numOfSubSectors=0sub-sector
...    NRCELL-2:numberOfRxBeamforming=4Rx
...    NRCELL-2:actPerCsiReportBundlingTddFr1=false
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
@{CB008698}
...    NRBTS:actDrbPreemption=true
...    NRBTS:actUserPreemption=true
...    NRBTS:maxNumOfPreemptions=20
...    NRCELL:allowEmergencyReservForTempUse=true
...    NRCELL:numOfRadioResReservForTempUse=0
...    NRCELL:preferNsaPreemption=false
...    NRCELL:numOfRadioResReservForEmergency=0
...    NRCELL:maxNumOfRrcSA=3
...    NRCELL:maxNumOfUsersPerNRCell=6
...    NRCELL:maxNumOfCaUsersNRCell=3
...    NRCELL:maxNumOfSCellAlloc=3
...    NRCELL:maxNumOfUsersPerCell=3
...    NRCELL:maxNumOfNrDcSnUsers=3
...    NRCELL:maxNumOfNonGBRBearersSA=30
...    NRCELL:maxNumOfGBRBearersSA=10
...    NRCELL:maxGBRTrafficLimit=50
...    NRCELL:addGbrTrafficHo=0
...    NRCELL-13:allowEmergencyReservForTempUse=true
...    NRCELL-13:numOfRadioResReservForTempUse=1
...    NRCELL-13:preferNsaPreemption=false
...    NRCELL-13:numOfRadioResReservForEmergency=1
...    NRCELL-13:maxNumOfRrcSA=3
...    NRCELL-13:maxNumOfUsersPerNRCell=6
...    NRCELL-13:maxNumOfCaUsersNRCell=3
...    NRCELL-13:maxNumOfSCellAlloc=3
...    NRCELL-13:maxNumOfUsersPerCell=3
...    NRCELL-13:maxNumOfNonGBRBearersSA=30
...    NRCELL-13:maxNumOfGBRBearersSA=10
...    NRCELL-13:maxGBRTrafficLimit=50
...    NRCELL-13:addGbrTrafficHo=0
...    NRBTS/NRCELLGRP-2:maxNumOfRrcCGRPSA=100
...    NRBTS/NRCELLGRP-2:maxNumOfNonGBRBearersCGRPSA=100
...    NRBTS/NRDU-1:numOfDrbsReservForTempUse=120
...    NRBTS/NRDU-1:maxNumOfRrcConUEsPerDU=10
...    NRBTS/NRDU-1:numOfDrbsReservForEmergency=120
...    NRCELL:pucchModeSelect=longPucch
...    NRBTS:timerRejectWait=5
...    NRBTS/NRCELLGRP-0:addNumOfRrcCGRPSAHo=0
...    NRBTS/NRCELLGRP-1:addNumOfRrcCGRPSAHo=0
...    NRBTS/NRCELLGRP-2:addNumOfRrcCGRPSAHo=0
@{CB008232}
...    NRCELL-13:actPriorityAccess=true
...    NRBTS:applyPriorityAccess=HPA
...    NRBTS/NRPRIOACC_PROFILE-1:nrPlmnIdx=1
...    NRBTS/NRPRIOACC_PROFILE-1:arpPrioLevelHpaMax=8
...    NRBTS/NRPRIOACC_PROFILE-1:arpPrioLevelHpaMin=6
...    NRBTS/NRPRIOACC_PROFILE-1:arpPrioLevelMpsMax=4
...    NRBTS/NRPRIOACC_PROFILE-1:arpPrioLevelMpsMin=1
...    NRCELL-13:numOfRadioResReservForPa=1
...    NRBTS/NRDU-1:numOfDrbsReservForPa=0
...    NRCELL-13:tPageCorrInt=3000
...    NRCELL-13:raPrioritizationForAI=MPS
...    NRCELL-13:powerRampingStepHighPriorityCbra=dB4
...    NRCELL-13:powerRampingStep=dB2
...    NRCELL-13:pagingPrioLevelPaMax=1
...    NRCELL-13:pagingPrioLevelPaMin=1
@{5GC000784}
...    NRCELL:arpPrioEmergencyCall=2
...    NRCELL:actEmergencyCall=true
...    NRCELL:emergencyCallFails=false
...    NRCELL:emergencyCallRestrictions:emergencyCallMrListIgnore=true
...    NRCELL:emergencyCallRestrictions:emergencyCallPlmnHoAllowed=true
...    NRCELL-13:arpPrioEmergencyCall=2
...    NRCELL-13:actEmergencyCall=true
...    NRCELL-13:emergencyCallFails=false
...    NRCELL-13:emergencyCallRestrictions:emergencyCallMrListIgnore=true
...    NRCELL-13:emergencyCallRestrictions:emergencyCallPlmnHoAllowed=true
...    NRBTS:timerXnDataFwdGuard=2000
@{VONR}
...    NRCELL:actVoNR=true
...    NRCELL:actEnhancedVoNR=true
...    NRBTS:tRLFindForDUVoNR=2000ms
...    NRCELL-13:n310VoNR=n20
...    NRCELL-13:t310VoNR=4000ms
...    NRCELL-1:n310VoNR=n20
...    NRCELL-1:t310VoNR=4000ms
...    NRCELL:actGBRAdmissionControl=EnhancedVoNR
...    NRCELL-13:actGBRAdmissionControl=EnhancedVoNR
...    NRCELL-13:actVoNrMobilityThresholds=VoNrMobilityThresholds
...    NRCELL-1:actVoNrMobilityThresholds=VoNrMobilityThresholds
@{5GC000707_InterRAT}
...    NRBTS:actInterRatHoSA=true
...    NRCELL-13:measGapSelectionSA=favourUeThroughput
...    NRCELL-12:measGapSelectionSA=favourUeThroughput
...    NRHOIR-1:allowedMeasBandwidth=mbw50
...    NRHOIR-1:b2MeashoEnabled=rsrpAndRsrq
...    NRHOIR-1:b2Threshold1hoRsrp=35
...    NRHOIR-1:b2Threshold1hoRsrpVoNr=45
...    NRHOIR-1:b2Threshold1hoRsrq=50
...    NRHOIR-1:b2Threshold1hoRsrqVoNr=55
...    NRHOIR-1:earfcnValue=39750
...    NRHOIR-1:eutraFreqQOffsetRange=0dB
...    NRHOIR-1:eutraB2MeashoRsrp:b2HysteresishoRsrp=0|b2TimeToTriggerhoRsrpVoNr=ms512
...    NRHOIR-1:eutraB2MeashoRsrp:b2HysteresishoRsrpVoNr=4|b2TimeToTriggerhoRsrpVoNr=ms512
...    NRHOIR-1:eutraB2MeashoRsrp:b2Threshold2hoRsrp=18|b2TimeToTriggerhoRsrpVoNr=ms512
...    NRHOIR-1:eutraB2MeashoRsrp:b2Threshold2hoRsrpVoNr=28|b2TimeToTriggerhoRsrpVoNr=ms512
...    NRHOIR-1:eutraB2MeashoRsrp:b2TimeToTriggerhoRsrp=ms480|b2TimeToTriggerhoRsrpVoNr=ms512
...    NRHOIR-1:eutraB2MeashoRsrq:b2HysteresishoRsrq=0|b2TimeToTriggerhoRsrqVoNr=ms512
...    NRHOIR-1:eutraB2MeashoRsrq:b2HysteresishoRsrqVoNr=4|b2TimeToTriggerhoRsrqVoNr=ms512
...    NRHOIR-1:eutraB2MeashoRsrq:b2Threshold2hoRsrq=2|b2TimeToTriggerhoRsrqVoNr=ms512
...    NRHOIR-1:eutraB2MeashoRsrq:b2Threshold2hoRsrqVoNr=10|b2TimeToTriggerhoRsrqVoNr=ms512
...    NRHOIR-1:eutraB2MeashoRsrq:b2TimeToTriggerhoRsrq=ms480|b2TimeToTriggerhoRsrqVoNr=ms512
...    NRCELL-13:nrhoirDNList=MRBTS-1/NRBTS-1/NRHOIR-1
...    NRCELL-1:nrhoirDNList=MRBTS-1/NRBTS-1/NRHOIR-1
...    NRADJECELL-1:eNodeBId=25
...    NRADJECELL-1:ePSTrackingAreaCode=222
...    NRADJECELL-1:earfcnValue=39750
...    NRADJECELL-1:lcrId=1
...    NRADJECELL-1:physCellId=12
...    NRADJECELL-1:eUtraMultibandInfoList=41
...    NRADJECELL-1:ecgiPlmn:mcc=311|mncLength=3
...    NRADJECELL-1:ecgiPlmn:mnc=489|mncLength=3
...    NRADJECELL-1:enbPlmn:mcc=311|mncLength=3
...    NRADJECELL-1:enbPlmn:mnc=489|mncLength=3
...    NRCELL-13/NRRELE-1:cellIndividualOffset=0dB
...    NRCELL-13/NRRELE-1:eNodeBId=25
...    NRCELL-13/NRRELE-1:lcrId=1
...    NRCELL-13/NRRELE-1:ecgiPlmn:mcc=311|mncLength=3
...    NRCELL-13/NRRELE-1:ecgiPlmn:mnc=489|mncLength=3
...    NRCELL-1/NRRELE-1:cellIndividualOffset=0dB
...    NRCELL-1/NRRELE-1:eNodeBId=25
...    NRCELL-1/NRRELE-1:lcrId=1
...    NRCELL-1/NRRELE-1:ecgiPlmn:mcc=311|mncLength=3
...    NRCELL-1/NRRELE-1:ecgiPlmn:mnc=489|mncLength=3
@{5GC002396}
...    NRCELL-1:actFullPwrMode=true

@{CB006086}
...    NRBTS:actCoverageNonCoherentUes=true

${Cell1_ssbFrequency}    518430
${Cell2_ssbFrequency}    636576
${Cell11_ssbFrequency}    423850
${Cell13_ssbFrequency}    430830
${Cell12_ssbFrequency}    126990
${sCellInactivityReleaseTimer}    10

${carrierAggregationSupportList}    SEPARATOR=
...    ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Any_Sa,ca_Fdd_Fdd,ca_Fr1Tdd_Any_Sa,
...    ca_Fdd_Fr1Tdd_Nsa,ca_Fr1Tdd_Fdd_Sa_WithUl,ca_Fdd_Fdd_Sa_WithUl,ca_Fdd_Fr1Tdd_Sa_WithUl

@{CB012149_enable}
...    NRBTS/NRDU-1:ulTxSwitchingSupportList=ca_F_Fr1T_Sa_switchedUl,ca_Fr1T_F_Sa_switchedUl
...    NRBTS:ulTxSwitchingBoost=20
...    NRCELL-1:weightForSCellSelection=50
...    NRCELL-2:weightForSCellSelection=50
...    NRCELL-13:weightForSCellSelection=50
...    NRCELL-11:weightForSCellSelection=50
...    NRCELL-12:weightForSCellSelection=50
...    NRCELL-14:weightForSCellSelection=50
...    NRBTS/NRDU-1:dlToUlContributionRatio=50

@{CB009169_CB006137_enable}
...    NRBTS/NRDU-1:carrierAggregationSupportList=${carrierAggregationSupportList}
...    NRBTS/NRDU-1:dlToUlContributionRatio=50
...    NRBTS/NRDRB_RLC_AM-1:ulTReassemblyIBCA=40
...    NRBTS/NRDRB_RLC_AM-2:ulTReassemblyIBCA=40
...    NRCELL:maxNumScellsDlFr1=3
...    NRCELL:timingAdvanceOffset=n25600
...    NRCELL:actK1Opt=intra-gNB
...    NRCELL-1:increasePUSCHPrepTimeULCA=true
...    NRCELL-2:increasePUSCHPrepTimeULCA=true

@{CB008311_enable}
...    NRBTS:actSCellReleaseForInactiveSCell=timer_based_Fr1
...    NRBTS:actBufferBasedSCellAddition=oneShot_Dl_Fr1
...    NRBTS-1:actSCellReleaseBadSCellRlq=enabled_Fr1
...    NRBTS-1:sCellExcludelistTimerFr1=60
...    NRCELL:sCellInactivityReleaseTimer=${sCellInactivityReleaseTimer}
...    NRCELL:sCellDeactivationTimerGNB=ms1280
...    NRCELL:dlSCellConfigLevel=2
...    NRCELL:dlSCellConfigLevelNum=5
...    NRCELL:dllaDeltaCqiMin=-150
...    NRBTS-1:sCellDeactivationBadRlqCount=1
...    NRCELL:sCellGoodChannelQualityThreshold=8
...    NRCELL:sCellBadChannelQualityThreshold=4
...    NRCELL:sCellChannelEstimationPeriod=2000

@{CB008311_disable}
...    NRBTS:actSCellReleaseForInactiveSCell=disabled
...    NRBTS:actBufferBasedSCellAddition=disabled
...    NRBTS-1:actSCellReleaseBadSCellRlq=disabled

@{gscn_Arfcn}
...    NRCELL-1:nrarfcn=518598
...    NRCELL-1:gscnOrSsPbchArfcn=6480
...    NRCELL-1:chBw=70 MHz

...    NRCELL-2:nrarfcn=636666
...    NRCELL-2:gscnOrSsPbchArfcn=7880
...    NRCELL-2:chBw=90MHz

...    NRCELL-11/NRCELL_FDD-1:nrarfcnDl=424000
...    NRCELL-11/NRCELL_FDD-1:nrarfcnUl=344000
...    NRCELL-11/NRCELL_FDD-1:chBwDl=20MHz
...    NRCELL-11/NRCELL_FDD-1:chBwUl=20MHz
...    NRCELL-11:gscnOrSsPbchArfcn=5297

...    NRCELL-12/NRCELL_FDD-1:nrarfcnDl=126900
...    NRCELL-12/NRCELL_FDD-1:nrarfcnUl=136100
...    NRCELL-12/NRCELL_FDD-1:chBwDl=10MHz
...    NRCELL-12/NRCELL_FDD-1:chBwUl=10MHz
...    NRCELL-12:gscnOrSsPbchArfcn=1587

...    NRCELL-13/NRCELL_FDD-1:nrarfcnDl=430920
...    NRCELL-13/NRCELL_FDD-1:nrarfcnUl=350920
...    NRCELL-13/NRCELL_FDD-1:chBwDl=30MHz
...    NRCELL-13/NRCELL_FDD-1:chBwUl=30MHz
...    NRCELL-13:gscnOrSsPbchArfcn=5385

...    NRCELL-14/NRCELL_FDD-1:nrarfcnDl=129000
...    NRCELL-14/NRCELL_FDD-1:nrarfcnUl=138200
...    NRCELL-14/NRCELL_FDD-1:chBwDl=10MHz
...    NRCELL-14/NRCELL_FDD-1:chBwUl=10MHz
...    NRCELL-14:gscnOrSsPbchArfcn=1611
...    NRCELL-14:type0CoresetConfigurationIndex=6

...    MRBTS-1/NRBTS-1/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=0|searchSpaceId=7
...    MRBTS-1/NRBTS-1/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|searchSpaceId=7
...    MRBTS-1/NRBTS-1/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-0-And-1-0|searchSpaceId=7
...    MRBTS-1/NRBTS-1/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|searchSpaceId=8
...    MRBTS-1/NRBTS-1/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|searchSpaceId=8
...    delete:MRBTS-1/NRBTS-1/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated

@{Others}
...    NRBTS:actMultiDrbNSA=true
...    NRBTS:actIncXn=true
...    NRBTS:actConflictConfiguration=true
...    NRBTS:rrcReestabTypeSA=sameGNB
...    NRBTS:tWaitingRlRecover=4000ms
...    NRCELL:pucchModeSelect=longPucch
...    NRBTS:actDrbDrx=false
...    NRCELL:actCDrx=true
...    MRBTS-1/MNL-1/AMGR-1/LUAC-1:appAdmActivated=false
...    MRBTS-1/MNL-1/AMGR-1/LUAC-1:readOnlyActivated=false
...    MRBTS-1/MNL-1/AMGR-1/LUAC-1:secAdmActivated=false
...    MRBTS-1/MNL-1/MNLENT-1/SECADM-1:actServicePortState=false
...    MRBTS-1/MNL-1/MNLENT-1/TRBLCADM-1:actDccSupport=false
...    MRBTS-1/NRBTS-1/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=3|periodicity=sl5
...    MRBTS-1/NRBTS-1/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|periodicity=sl5
...    MRBTS-1/NRBTS-1/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|periodicity=sl1
...    MRBTS-1/NRBTS-1/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|periodicity=sl1
...    MRBTS-1/NRBTS-1/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=2|periodicity=sl1
...    MRBTS-1/NRBTS-1/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|periodicity=sl1
...    MRBTS-1/NRBTS-1/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|periodicity=sl1
...    MRBTS-1/NRBTS-1/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=3|periodicity=sl20
...    MRBTS-1/NRBTS-1/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=3|periodicity=sl20
...    MRBTS-1/NRBTS-1/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|periodicity=sl20
...    MRBTS-1/NRBTS-1/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=5|periodicity=sl20
...    MRBTS-1/NRBTS-1/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=3|periodicity=sl5
...    MRBTS-1/NRBTS-1/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|periodicity=sl5
...    MRBTS-1/NRBTS-1/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|periodicity=sl1
...    MRBTS-1/NRBTS-1/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|periodicity=sl1
...    MRBTS-1/NRBTS-1/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=5|periodicity=sl1
...    MRBTS-1/NRBTS-1/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|periodicity=sl1
...    MRBTS-1/NRBTS-1/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|periodicity=sl1
...    MRBTS-1/NRBTS-1/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=3|periodicity=sl20
...    MRBTS-1/NRBTS-1/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=6|periodicity=sl20
...    MRBTS-1/NRBTS-1/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|periodicity=sl20
...    MRBTS-1/NRBTS-1/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=5|periodicity=sl20
...    MRBTS-1/NRBTS-1/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|coresetId=0
...    MRBTS-1/NRBTS-1/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|coresetId=1
...    MRBTS-1/NRBTS-1/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n5|coresetId=1
...    MRBTS-1/NRBTS-1/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=8|coresetId=1
...    MRBTS-1/NRBTS-1/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|coresetId=1
...    MRBTS-1/NRBTS-1/NRCELL-1:actGbrRacTdEnhResourcePriority=false
...    MRBTS-1/NRBTS-1/NRCELL-1:pagingOffset=3
...    MRBTS-1/NRBTS-1/NRCELL-1:fPdcchMonOccsnPo=0
...    MRBTS-1/NRBTS-1/NRCELL-1:pdcchAutoConfig:cellCoverageLevel=normal
...    MRBTS-1/NRBTS-1/NRCELL-1:pdcchAutoConfig:fineTuneMode=disabled
...    MRBTS-1/NRBTS-1/NRCELL-1:pdcchAutoConfig:initialBWPMode=sameAsCoreset0
...    MRBTS-1/NRBTS-1/NRCELL-1:pdcchAutoConfig:pucchSize=22
...    MRBTS-1/NRBTS-1/NRCELL-11:actGbrRacTdEnhResourcePriority=false
...    MRBTS-1/NRBTS-1/NRCELL-12:actGbrRacTdEnhResourcePriority=false
...    MRBTS-1/NRBTS-1/NRCELL-13:actGbrRacTdEnhResourcePriority=false
...    MRBTS-1/NRBTS-1/NRCELL-14:actGbrRacTdEnhResourcePriority=false
...    MRBTS-1/NRBTS-1/NRCELL-2:actGbrRacTdEnhResourcePriority=false
...    MRBTS-1/NRBTS-1/NRCELL-2:pagingOffset=3
...    MRBTS-1/NRBTS-1/NRCELL-2:fPdcchMonOccsnPo=0
...    MRBTS-1/NRBTS-1/NRCELL-2:pdcchAutoConfig:cellCoverageLevel=normal
...    MRBTS-1/NRBTS-1/NRCELL-2:pdcchAutoConfig:fineTuneMode=disabled
...    MRBTS-1/NRBTS-1/NRCELL-2:pdcchAutoConfig:initialBWPMode=sameAsCoreset0
...    MRBTS-1/NRBTS-1/NRCELL-2:pdcchAutoConfig:pucchSize=22
...    MRBTS-1/NRBTS-1/NRDU-1:remoteDuIpAddr=fd5f:4268:2387:a881:40:43ff:fe80:1085
...    MRBTS-1/NRBTS-1/NRX2LINK_TRUST-257:ipV4Addr=10.0.1.13
...    MRBTS-1/NRBTS-1/NRX2LINK_TRUST-257:x2LinkTrustCtrl=gnbControlled


@{CA}
...    NRBTS/NRDU-1:actConnectedModeMobilityCA=true
...    NRBTS/NRDU-1:flexibleCAMode=NumberCellAmount
...    NRBTS:actSlowPrbPooling=true
...    NRBTS:actConnRrcPooling=true
...    NRBTS:actScheUePooling=true
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS:actMeasBasedSCellAdditionNsa=true
...    NRBTS:actHoOptimizationCa=false
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
...    NRCELL-13/NRREL-1:gNbId=1
...    NRCELL-13/NRREL-1:gNbIdLength=22
...    NRCELL-13/NRREL-1:lcrId=11
...    NRCELL-13/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-13/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-13/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-13/NRREL-1:sCellPrio=1

...    NRCELL-13/NRREL-2:gNbId=1
...    NRCELL-13/NRREL-2:gNbIdLength=22
...    NRCELL-13/NRREL-2:lcrId=12
...    NRCELL-13/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-13/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-13/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-13/NRREL-2:sCellPrio=1

...    NRCELL-13/NRREL-3:gNbId=1
...    NRCELL-13/NRREL-3:gNbIdLength=22
...    NRCELL-13/NRREL-3:lcrId=1
...    NRCELL-13/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-13/NRREL-3:sCellOperationalMode=dlAndUl
...    NRCELL-13/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-3:gnbPlmn:mncLength=3

...    NRCELL-13/NRREL-4:gNbId=1
...    NRCELL-13/NRREL-4:gNbIdLength=22
...    NRCELL-13/NRREL-4:lcrId=14
...    NRCELL-13/NRREL-4:sCellAdditionMethod=covBasedA1
...    NRCELL-13/NRREL-4:sCellOperationalMode=dlOnly
...    NRCELL-13/NRREL-4:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-4:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-4:gnbPlmn:mncLength=3
...    NRCELL-13/NRREL-4:sCellPrio=2

...    NRCELL-13/NRREL-5:gNbId=1
...    NRCELL-13/NRREL-5:gNbIdLength=22
...    NRCELL-13/NRREL-5:lcrId=2
...    NRCELL-13/NRREL-5:sCellAdditionMethod=covBasedA1
...    NRCELL-13/NRREL-5:sCellOperationalMode=dlAndUl
...    NRCELL-13/NRREL-5:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-5:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-5:gnbPlmn:mncLength=3

...    NRCELL-2/NRREL-1:gNbId=1
...    NRCELL-2/NRREL-1:gNbIdLength=22
...    NRCELL-2/NRREL-1:lcrId=11
...    NRCELL-2/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-1:sCellOperationalMode=dlAndUl
...    NRCELL-2/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-1:sCellPrio=1

...    NRCELL-2/NRREL-2:gNbId=1
...    NRCELL-2/NRREL-2:gNbIdLength=22
...    NRCELL-2/NRREL-2:lcrId=12
...    NRCELL-2/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-2:sCellOperationalMode=dlAndUl
...    NRCELL-2/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-2:sCellPrio=1

...    NRCELL-2/NRREL-3:gNbId=1
...    NRCELL-2/NRREL-3:gNbIdLength=22
...    NRCELL-2/NRREL-3:lcrId=13
...    NRCELL-2/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-3:sCellOperationalMode=dlAndUl
...    NRCELL-2/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-3:gnbPlmn:mncLength=3

...    NRCELL-2/NRREL-4:gNbId=1
...    NRCELL-2/NRREL-4:gNbIdLength=22
...    NRCELL-2/NRREL-4:lcrId=14
...    NRCELL-2/NRREL-4:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-4:sCellOperationalMode=dlAndUl
...    NRCELL-2/NRREL-4:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-4:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-4:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-4:sCellPrio=2

...    NRCELL-2/NRREL-5:gNbId=1
...    NRCELL-2/NRREL-5:gNbIdLength=22
...    NRCELL-2/NRREL-5:lcrId=1
...    NRCELL-2/NRREL-5:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-5:sCellOperationalMode=dlOnly
...    NRCELL-2/NRREL-5:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-5:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-5:gnbPlmn:mncLength=3

...    NRCELL-13/NRHOIF-1:a1BasedPCellSwitchEnabled=true
...    NRCELL-13/NRHOIF-1:a2BasedPCellSwitchEnabled=true
...    NRCELL-13/NRHOIF-1:a2BasedPCellSwitchPriority=1
...    NRCELL-13/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-13/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-13/NRHOIF-1:freqBandIndicatorNR=41
...    NRCELL-13/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-13/NRHOIF-1:ifhoSsbSmtcDuration=sf5
...    NRCELL-13/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf20
...    NRCELL-13/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-13/NRHOIF-1:ssbFrequency=${Cell1_ssbFrequency}
...    NRCELL-13/NRHOIF-1:thresholdPCellSwitchTargetRsrp=60
...    NRCELL-13/NRHOIF-1:thresholdPCellSwitchTargetRsrq=20
...    NRCELL-13/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms320
...    NRCELL-13/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=5

...    NRCELL-13/NRHOIF-2:a1BasedPCellSwitchEnabled=true
...    NRCELL-13/NRHOIF-2:a2BasedPCellSwitchEnabled=true
...    NRCELL-13/NRHOIF-2:a2BasedPCellSwitchPriority=1
...    NRCELL-13/NRHOIF-2:a3MeasEnabled=rsrp
...    NRCELL-13/NRHOIF-2:cellDepType=SA+NSA
...    NRCELL-13/NRHOIF-2:freqBandIndicatorNR=78
...    NRCELL-13/NRHOIF-2:ifhoSsbScs=30 KHz
...    NRCELL-13/NRHOIF-2:ifhoSsbSmtcDuration=sf5
...    NRCELL-13/NRHOIF-2:ifhoSsbSmtcPeriodicity=sf20
...    NRCELL-13/NRHOIF-2:ssBurstSetPeriod=20
...    NRCELL-13/NRHOIF-2:ssbFrequency=${Cell2_ssbFrequency}
...    NRCELL-13/NRHOIF-2:thresholdPCellSwitchTargetRsrp=60
...    NRCELL-13/NRHOIF-2:thresholdPCellSwitchTargetRsrq=20
...    NRCELL-13/NRHOIF-2:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms320
...    NRCELL-13/NRHOIF-2:a3MeasSsbRsrp:a3OffsetSsbRsrp=5

...    NRCELL-13/NRHOIF-3:a1BasedPCellSwitchEnabled=true
...    NRCELL-13/NRHOIF-3:a2BasedPCellSwitchEnabled=true
...    NRCELL-13/NRHOIF-3:a2BasedPCellSwitchPriority=1
...    NRCELL-13/NRHOIF-3:a3MeasEnabled=rsrp
...    NRCELL-13/NRHOIF-3:cellDepType=SA+NSA
...    NRCELL-13/NRHOIF-3:freqBandIndicatorNR=71
...    NRCELL-13/NRHOIF-3:ifhoSsbScs=15KHz
...    NRCELL-13/NRHOIF-3:ifhoSsbSmtcDuration=sf5
...    NRCELL-13/NRHOIF-3:ifhoSsbSmtcPeriodicity=sf20
...    NRCELL-13/NRHOIF-3:ssBurstSetPeriod=20
...    NRCELL-13/NRHOIF-3:ssbFrequency=126990
...    NRCELL-13/NRHOIF-3:thresholdPCellSwitchTargetRsrp=60
...    NRCELL-13/NRHOIF-3:thresholdPCellSwitchTargetRsrq=20
...    NRCELL-13/NRHOIF-3:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms320
...    NRCELL-13/NRHOIF-3:a3MeasSsbRsrp:a3OffsetSsbRsrp=5

...    NRCELL-13/NRHOIF-4:a1BasedPCellSwitchEnabled=true
...    NRCELL-13/NRHOIF-4:a2BasedPCellSwitchEnabled=true
...    NRCELL-13/NRHOIF-4:a2BasedPCellSwitchPriority=1
...    NRCELL-13/NRHOIF-4:a3MeasEnabled=rsrp
...    NRCELL-13/NRHOIF-4:cellDepType=SA+NSA
...    NRCELL-13/NRHOIF-4:freqBandIndicatorNR=66
...    NRCELL-13/NRHOIF-4:ifhoSsbScs=15KHz
...    NRCELL-13/NRHOIF-4:ifhoSsbSmtcDuration=sf5
...    NRCELL-13/NRHOIF-4:ifhoSsbSmtcPeriodicity=sf20
...    NRCELL-13/NRHOIF-4:ssBurstSetPeriod=20
...    NRCELL-13/NRHOIF-4:ssbFrequency=423850
...    NRCELL-13/NRHOIF-4:thresholdPCellSwitchTargetRsrp=60
...    NRCELL-13/NRHOIF-4:thresholdPCellSwitchTargetRsrq=20
...    NRCELL-13/NRHOIF-4:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms320
...    NRCELL-13/NRHOIF-4:a3MeasSsbRsrp:a3OffsetSsbRsrp=5

...    NRCELL-2/NRHOIF-1:a1BasedPCellSwitchEnabled=true
...    NRCELL-2/NRHOIF-1:a2BasedPCellSwitchEnabled=true
...    NRCELL-2/NRHOIF-1:a2BasedPCellSwitchPriority=1
...    NRCELL-2/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-2/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-2/NRHOIF-1:freqBandIndicatorNR=41
...    NRCELL-2/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-2/NRHOIF-1:ifhoSsbSmtcDuration=sf5
...    NRCELL-2/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf20
...    NRCELL-2/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-2/NRHOIF-1:ssbFrequency=${Cell1_ssbFrequency}
...    NRCELL-2/NRHOIF-1:thresholdPCellSwitchTargetRsrp=60
...    NRCELL-2/NRHOIF-1:thresholdPCellSwitchTargetRsrq=20
...    NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms320
...    NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=5

...    NRCELL-2/NRHOIF-2:a1BasedPCellSwitchEnabled=true
...    NRCELL-2/NRHOIF-2:a2BasedPCellSwitchEnabled=true
...    NRCELL-2/NRHOIF-2:a2BasedPCellSwitchPriority=1
...    NRCELL-2/NRHOIF-2:a3MeasEnabled=rsrp
...    NRCELL-2/NRHOIF-2:cellDepType=SA+NSA
...    NRCELL-2/NRHOIF-2:freqBandIndicatorNR=66
...    NRCELL-2/NRHOIF-2:ifhoSsbScs=15KHz
...    NRCELL-2/NRHOIF-2:ifhoSsbSmtcDuration=sf5
...    NRCELL-2/NRHOIF-2:ifhoSsbSmtcPeriodicity=sf20
...    NRCELL-2/NRHOIF-2:ssBurstSetPeriod=20
...    NRCELL-2/NRHOIF-2:ssbFrequency=${Cell13_ssbFrequency}
...    NRCELL-2/NRHOIF-2:thresholdPCellSwitchTargetRsrp=60
...    NRCELL-2/NRHOIF-2:thresholdPCellSwitchTargetRsrq=20
...    NRCELL-2/NRHOIF-2:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms320
...    NRCELL-2/NRHOIF-2:a3MeasSsbRsrp:a3OffsetSsbRsrp=5

...    NRCELL-2/NRHOIF-3:a1BasedPCellSwitchEnabled=true
...    NRCELL-2/NRHOIF-3:a2BasedPCellSwitchEnabled=true
...    NRCELL-2/NRHOIF-3:a2BasedPCellSwitchPriority=1
...    NRCELL-2/NRHOIF-3:a3MeasEnabled=rsrp
...    NRCELL-2/NRHOIF-3:cellDepType=SA+NSA
...    NRCELL-2/NRHOIF-3:freqBandIndicatorNR=71
...    NRCELL-2/NRHOIF-3:ifhoSsbScs=15KHz
...    NRCELL-2/NRHOIF-3:ifhoSsbSmtcDuration=sf5
...    NRCELL-2/NRHOIF-3:ifhoSsbSmtcPeriodicity=sf20
...    NRCELL-2/NRHOIF-3:ssBurstSetPeriod=20
...    NRCELL-2/NRHOIF-3:ssbFrequency=126990
...    NRCELL-2/NRHOIF-3:thresholdPCellSwitchTargetRsrp=60
...    NRCELL-2/NRHOIF-3:thresholdPCellSwitchTargetRsrq=20
...    NRCELL-2/NRHOIF-3:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms320
...    NRCELL-2/NRHOIF-3:a3MeasSsbRsrp:a3OffsetSsbRsrp=5

...    NRCELL-2/NRHOIF-4:a1BasedPCellSwitchEnabled=true
...    NRCELL-2/NRHOIF-4:a2BasedPCellSwitchEnabled=true
...    NRCELL-2/NRHOIF-4:a2BasedPCellSwitchPriority=1
...    NRCELL-2/NRHOIF-4:a3MeasEnabled=rsrp
...    NRCELL-2/NRHOIF-4:cellDepType=SA+NSA
...    NRCELL-2/NRHOIF-4:freqBandIndicatorNR=66
...    NRCELL-2/NRHOIF-4:ifhoSsbScs=15KHz
...    NRCELL-2/NRHOIF-4:ifhoSsbSmtcDuration=sf5
...    NRCELL-2/NRHOIF-4:ifhoSsbSmtcPeriodicity=sf20
...    NRCELL-2/NRHOIF-4:ssBurstSetPeriod=20
...    NRCELL-2/NRHOIF-4:ssbFrequency=423850
...    NRCELL-2/NRHOIF-4:thresholdPCellSwitchTargetRsrp=60
...    NRCELL-2/NRHOIF-4:thresholdPCellSwitchTargetRsrq=20
...    NRCELL-2/NRHOIF-4:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms320
...    NRCELL-2/NRHOIF-4:a3MeasSsbRsrp:a3OffsetSsbRsrp=5

...    NRBTS/NRPMRNL-1:miNrNgcFlexInterface=disabled
...    NRBTS/NRPMRNL-1:miNrIntraGnbMobilitySaPmqap=disabled
...    NRBTS/NRPMRNL-1:miNrIntraGnbMobilityNsaPmqap=disabled
...    NRBTS/NRPMRNL-1:miNrInterGnbXnMobilitySaPmqap=disabled
...    NRBTS/NRPMRNL-1:miNrInterGnbNgMobilitySaPmqap=disabled
...    NRBTS/NRPMRNL-1:miNrInterGnbMobilityNsaPmqap=disabled



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
...    NRBTS:cipherPrefL:nea3_128=8
...    NRCELL:a3MeasEnabled=rsrp
...    NRCELL:absThreshSsbRsrpConsolidation=1
...    NRCELL:sMeasConfigSsbRsrp=1
...    NRCELL:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms512
...    NRCELL:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL:a3MeasSsbRsrp:a3OffsetSsbRsrp=5
...    NRCELL:a1MeashoEnabledSA=rsrp
...    NRCELL:a2MeashoEnabledSA=rsrp
...    NRCELL:measGapSelectionSA=favourUeThroughput
...    NRCELL:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRCELL:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=60
...    NRCELL:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0
...    NRCELL:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=34
...    NRCELL:a1MeashoSsbRsrpSA:a1TimeToTriggerHoSsbRsrpVoNr=${EMPTY}
...    NRCELL:a1MeashoSsbRsrpSA:a1ThresholdHoSsbRsrpVoNr=${EMPTY}
...    NRCELL:a1MeashoSsbRsrpSA:a1HysteresisHoSsbRsrpVoNr=${EMPTY}
...    NRCELL:a2MeashoSsbRsrpSA:a2HysteresisHoSsbRsrpVoNr=${EMPTY}
...    NRCELL:a2MeashoSsbRsrpSA:a2ThresholdHoSsbRsrpVoNr=60
...    NRCELL:a2MeashoSsbRsrpSA:a2TimeToTriggerHoSsbRsrpVoNr=${EMPTY}

@{5GC000704}
...    NRBTS:actConflictConfiguration=true
...    NRBTS:actUeCapaEnquiryHoCa=true
...    NRBTS:actIntraFreqHoSA=true
...    NRBTS:actHoOptimizationCa=false
...    NRPMRNL-1:miNrRelReportCu=5min

...    NRCELL-13:a3MeasEnabled=rsrp
...    NRCELL-13:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-13:a3MeasSsbRsrp:a3OffsetSsbRsrp=3
...    NRCELL-13:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms320
...    NRCELL-13:filterCoeffSsbRsrp=fc4
...    NRCELL-13:absThreshSsbRsrpConsolidation=80
...    NRCELL-13:sMeasConfigSsbRsrp=20
...    NRCELL-2:a3MeasEnabled=rsrp
...    NRCELL-2:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-2:a3MeasSsbRsrp:a3OffsetSsbRsrp=3
...    NRCELL-2:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms320
...    NRCELL-2:filterCoeffSsbRsrp=fc4
...    NRCELL-2:absThreshSsbRsrpConsolidation=80
...    NRCELL-2:sMeasConfigSsbRsrp=20

...    NRBTS:actIncXn=true
...    XNLINK-1:cPlaneIpAddr=10.0.1.122
...    NRADJGNB-1:administrativeState=Unlocked
...    NRADJGNB-1:gNbIdLength=22
...    NRADJGNB-1:gNodeBId=35
...    NRADJGNB-1:xnLinkRef=1
...    NRADJGNB-1:gnbPlmn:mcc=311|mncLength=3
...    NRADJGNB-1:gnbPlmn:mnc=489|mncLength=3
...    NRADJNRCELL-1:cellDepType=SA
...    NRADJNRCELL-1:fiveGsTac=200
...    NRADJNRCELL-1:gNbId=35
...    NRADJNRCELL-1:gNbIdLength=22
...    NRADJNRCELL-1:lcrId=1
...    NRADJNRCELL-1:nrarfcn=513234
...    NRADJNRCELL-1:physCellId=381
...    NRADJNRCELL-1:gnbPlmn:mcc=311|mncLength=3
...    NRADJNRCELL-1:gnbPlmn:mnc=489|mncLength=3
...    delete:NRADJNRCELL-1:freqBandIndicatorNR

...    NRCELL-13/NRREL-6:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-13/NRREL-6:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-13/NRREL-6:gNbId=35
...    NRCELL-13/NRREL-6:gNbIdLength=22
...    NRCELL-13/NRREL-6:lcrId=1
...    NRCELL-13/NRREL-6:removeNotAllowed=false
...    NRCELL-13/NRREL-6:gnbPlmn:mcc=311|mncLength=3
...    NRCELL-13/NRREL-6:gnbPlmn:mnc=489|mncLength=3


@{dlToUlContributionRatio50}
...    NRBTS/NRDU-1:dlToUlContributionRatio=50

@{frameStructureType_setting}
...    NRCELL-1:tddFrameStructure:frameStructureType=semiStatic
...    NRCELL-1:prachConfigurationIndex=98
...    NRCELL-1:tddFrameStructure:guardPeriodLength=2Symbols
...    NRCELL-1:tddFrameStructure:ulDlDataSlotRatio=1/4
...    delete:NRCELL-1:tddFrameStructure:lteToNrFrameShift
...    NRCELL-2:tddFrameStructure:frameStructureType=semiStatic
...    NRCELL-2:prachConfigurationIndex=98
...    NRCELL-2:tddFrameStructure:guardPeriodLength=2Symbols
...    NRCELL-2:tddFrameStructure:ulDlDataSlotRatio=1/4
...    delete:NRCELL-2:tddFrameStructure:lteToNrFrameShift

@{dlToUlContributionRatio50 and frameStructureType semiStatic}
...    @{dlToUlContributionRatio50}
...    @{frameStructureType_setting}

@{ulTxSwitchingBoost_10}
...    NRBTS-1:ulTxSwitchingBoost=10

@{ulTxSwitchingBoost_20}
...    NRBTS-1:ulTxSwitchingBoost=20

@{Recover}
...    @{CB012149_enable}
#...    @{CB009169_CB006137_enable}
...    @{ulTxSwitchingBoost_20}
#...    @{CB008311_disable}

${BA_06_UE_1}    SEPARATOR=
...    E9A09000575F5A13160003C6A00002C1262E003387A1A004D9061CF9863CA160704C0A00C4700FB8D85181AC1184341020E9098006D6C98AB
...    1A1CF88E3D033EC09F1891C790E7D473E639F28581C0E1E0B801FF800E007FE00119000007001B2FFFF2FFFF02A0D883AC1184341020F1098
...    00656C98AB121CFB027C471E31238F21CFA8E7CC31E50B0381C3C17FFC00001FFF0000023000000E0551B137582308682041D213000C2D931
...    544439F11C788E3D033EC09F18E7CC31E50B0381C3C17003FF001C00FFC0023200000E00365FFFE5FFFE0571F11B582308682041F284C002A
...    B64C55850E7C471E300000000000000000000007805FFF000007FFC000008C000003800AF0F10400389A0000042C040B87C28000E20800710
...    400388C0000082C040BC7C41000C208184D0388C00000C2C040B89C41000E2080061180E2300070A00000005808170B882001C4D000E20800
...    0040B010200E0234028809B0104A5800002A050403000C0040002000160A318C6302022682C010803090308030803005612C3C41000E26800
...    0050B02080C2080002CC248F882001C41000E2300070A00000305A3006C73E18C6081006823021A31923E2080040A209AD1800038583001C8
...    1010014012000184C1F10400388C001C46000E140000080B01060031803011810C0C04C260B89A001C41000E208000090B010400C60850408
...    4040033D0BC0001E00140E0A00E0601280380030120020301F00C01000000008000010040000100200000C03E54DE54DE0A5E0A5008100000
...    965240400006594941000029652400B4AA2E95555058A2E0001E00740A05028000092008030060200C01808030060200C0180801002101006
...    00C04008011808010020200C01808030060200C000C04018030100600C04008010100600C40200C01808010020200C0184040180301002008
...    60200C01808030060200C018080100430100600C04008020100200804018031808030060200C0180803006020040108040080201006000040
...    18001AA1F000102030406070A0B0C0D101112131418191B1C1D1F2125262728292A2D2F414182D0

${AZ_B3_UE_1}    SEPARATOR=
...    E9A09000575F5A13160003C5200016093170019C3D0B004D9061CF9863CA160704C060188E01F71B0A303582308682041D211001B5B262AC6
...    873E238F40CFB027C62471E439F51CF98E7CA1607038782E007FE003801FF8003640001C006CBFFFCBFFFC0A83620EB04610D04083C422003
...    2B64C55890E7D813E238F1891C790E7D473E618F28581C0E1E0BFFE00000FFF800000D80000702A8D89BAC1184341020E908800C2D9315444
...    39F11C788E3D033EC09F18E7CC31E50B0381C3C17003FF001C00FFC001B20000E00365FFFE5FFFE0571F11B582308682041F284400556C98A
...    B0A1CF88E3C60000000000000000000000F00BFFE00000FFF800000D800007000DE2E2080070A000308200000B0102E1F134003882001C040
...    00E020000020B0102F1F104003082061380E228000030B010200E0234028809B01046D8000F01840060018000070318C69540E00840184818
...    01B0961E2080070A0000028581040610400016612C5C41000E2680061180008160420061040001661245C41000E2300070A00000305A201B1
...    CF8631820401208808081E83E000F000A070500703009401C0018090010180F80600800000004000008020000080100000601F2A6F2A6F052
...    F0528040800004B29202000032CA4A0800014B292005A55174AAAA82C50F400F003A05028140001A802000000100000004000000100488040
...    180301002004040180308080300602004008C04008010100600C04018030100600C60200C018080300602004008080300620100600C040080
...    20100600C20200C018080100420100600C04018030100200860200C018080100402004010080300630100600C04018030100600C040080210
...    08010040200C00008030003543E00020406080C0E1416181A2022242628303236383A3E424A4C4E5052545A5E828305A0

#UE1 support fullpowermode1
${DB_02_UE_1}    SEPARATOR=
...    E9A09000575F5A13160003C5200016093170019C3D0B004D9061CF9863CA160704C060188E01F71B0A303582308682041D211001B5B262AC6
...    873E238F40CFB027C62471E439F51CF98E7CA1607038782E007FE003801FF8003640001C006CBFFFCBFFFC0A83620EB04610D04083C422003
...    2B64C55890E7D813E238F1891C790E7D473E618F28581C0E1E0BFFE00000FFF800000D80000702A8D89BAC1184341020E908800C2D9315444
...    39F11C788E3D033EC09F18E7CC31E50B0381C3C17003FF001C00FFC001B20000E00365FFFE5FFFE0571F11B582308682041F284400556C98A
...    B0A1CF88E3C60000000000000000000000F00BFFE00000FFF800000D800007000DE2E2080070A000308200000B0102E1F094003882001C410
...    00E228000020B0102F1F104003082061380E228000030B010200E0234028809B01046D8000F018400600180000B0518C631806B40E0084018
...    48180130961E2080070A000002858104061040001661245C41000E2300070A00000305A201B1CF863182040120880809E83E000F000A07050
...    0703009401C0018090010180F80600800000004000008020000080100000601F2A6F2A6F052F0528040800004B29202000032CA4A0800014B
...    292005A55174AAAA82C50F400F003A05028140001A802000000100000004000000100488040180301002004040180308080300602004008C0
...    4008010100600C04018030100600060200C018080300602004008080300620100600C04008010100600C20200C018080100420100600C0401
...    8030100200860200C018080100402004010080300630100600C04018030100600C04008021008010040200C00008030003543E00020406080
...    C0E1416181A2022242628303236383A3E424A4C4E5052545A5E828305A0

#UE2 support fullpowermode0
${DB_02_UE_2}    SEPARATOR=
...    E9A09000575F5A13160003C5200016093170019C3D0B004D9061CF9863CA160704C060188E01F71B0A303582308682041D211001B5B262AC6
...    873E238F40CFB027C62471E439F51CF98E7CA1607038782E007FE003801FF8003640001C006CBFFFCBFFFC0A83620EB04610D04083C422003
...    2B64C55890E7D813E238F1891C790E7D473E618F28581C0E1E0BFFE00000FFF800000D80000702A8D89BAC1184341020E908800C2D9315444
...    39F11C788E3D033EC09F18E7CC31E50B0381C3C17003FF001C00FFC001B20000E00365FFFE5FFFE0571F11B582308682041F284400556C98A
...    B0A1CF88E3C60000000000000000000000F00BFFE00000FFF800000D800007000DE2E2080070A000308200000B0102F1F0A0003882001C460
...    00E230000020B0102F1F104003082070A000388C00000C2C040803808D00A2026C0411B60003C061001800600002C146318C601AD03802100
...    61206004C2587882001C2800000A16041018410000598491710400388C001C2800000C168806C73E18C608100482202027A0F8003C00281C1
...    401C0C02500700060240040603E01802000000010000020080000200400001807CA9BCA9BC14BC14A0102000012CA48080000CB2928200005
...    2CA480169545D2AAAA0B143D003C00E8140A0500006A008000001000000040000001001220100600C04008010100600C20200C01808010023
...    0100200404018030100600C04018001808030060200C01808010020200C018804018030100200404018030808030060200401080401803010
...    0600C04008021808030060200401008010040200C018C04018030100600C04018030100200840200401008030000200C000D50F8000810182
...    030385058606880889098A0C0C8D8E0E8F909293139414951697A0A0C1680

#UE3 support fullpowermode2
${DB_02_UE_3}    SEPARATOR=
...    E9A09000575F5A13160003C5200016093170019C3D0B004D9061CF9863CA160704C060188E01F71B0A303582308682041D211001B5B262AC6
...    873E238F40CFB027C62471E439F51CF98E7CA1607038782E007FE003801FF8003640001C006CBFFFCBFFFC0A83620EB04610D04083C422003
...    2B64C55890E7D813E238F1891C790E7D473E618F28581C0E1E0BFFE00000FFF800000D80000702A8D89BAC1184341020E908800C2D9315444
...    39F11C788E3D033EC09F18E7CC31E50B0381C3C17003FF001C00FFC001B20000E00365FFFE5FFFE0571F11B582308682041F284400556C98A
...    B0A1CF88E3C60000000000000000000000F00BFFE00000FFF800000D800007000DE2E2080070A000308200000B0102E1F094003882001C410
...    00E228000020B0102F1F104003082061380E228000030B010200E0234028809B01046D8000F018400600180000B0518C631806B40E0084018
...    48180130961E2080070A000002858104061040001661245C41000E2300070A00000305A201B1CF863182040120880809E83E000F000A07050
...    0703009401C0018090010180F80600800000004000008020000080100000601F2A6F2A6F052F0528040800004B29202000032CA4A0800014B
...    292005A55174AAAA82C50F400F003A05028140001E8020000000620000000C400000018804880401803010020040401803080803006020040
...    08C04008010100600C04018030100600060200C018080300602004008080300620100600C04008010100600C20200C018080100420100600C
...    04018030100200860200C018080100402004010080300630100600C04018030100600C04008021008010040200C00008030003543E0002040
...    6080C0E1416181A2022242628303236383A3E424A4C4E5052545A5E828305A0

#UE4 not support fullpowermode0/1/2
${DB_02_UE_4}    SEPARATOR=
...    E9A09000575F5A13160003C5200016093170019C3D0B004D9061CF9863CA160704C060188E01F71B0A303582308682041D211001B5B262AC6
...    873E238F40CFB027C62471E439F51CF98E7CA1607038782E007FE003801FF8003640001C006CBFFFCBFFFC0A83620EB04610D04083C422003
...    2B64C55890E7D813E238F1891C790E7D473E618F28581C0E1E0BFFE00000FFF800000D80000702A8D89BAC1184341020E908800C2D9315444
...    39F11C788E3D033EC09F18E7CC31E50B0381C3C17003FF001C00FFC001B20000E00365FFFE5FFFE0571F11B582308682041F284400556C98A
...    B0A1CF88E3C60000000000000000000000F00BFFE00000FFF800000D800007000DE2E2080070A000308200000B0102E1F094003882001C410
...    00E228000020B0102F1F104003082061380E228000030B010200E0234028809B01046D8000F018400600180000B0518C631806B40E0084018
...    48180130961E2080070A000002858104061040001661245C41000E2300070A00000305A201B1CF863182040120880809E83E000F000A07050
...    0703009401C0018090010180F80600800000004000008020000080100000601F2A6F2A6F052F0528040800004B29202000032CA4A0800014B
...    292005A55174AAAA82C50F000F003A05028140000488040180301002004040180308080300602004008C04008010100600C04018030100600
...    060200C018080300602004008080300620100600C04008010100600C20200C018080100420100600C04018030100200860200C01808010040
...    2004010080300630100600C04018030100600C04008021008010040200C00008030003543E00020406080C0E1416181A20222426283032363
...    83A3E424A4C4E5052545A5E828305A0


${DA12_UE_1}    SEPARATOR=
...    E9A09000575F5A13160003C2A002C1262E003387A0E026C830E7CC31E50B03826010188E01F71B0A303582308682041D207036B64C558D0E7C471E819F604F8C48E3C873E
...    A39F30C7942C0E070F05C00FFC007003FF0003C800E00365FFFE5FFFE0541B107582308682041E207032B64C55890E7D813E238F1891C790E7D473E618F28581C0E1E13FF
...    E00000FFF80000078001C0AA3626EB04610D04083A40E0616C98AA221CF88E3C471E819F604F8C73E618F28581C0E1E0B801FF800E007FE00079001C006CBFFFCBFFFC0AE
...    3E236B04610D04083E5038155B262AC2873E238F180000000000000000000003C04FFF800003FFE000001E0007000DE2E2080061040E140000010B0102F1F104003850001
...    8460308C00020B0102F1F1040038500018410308C00030B010200E0234028809B01042D80F01840060018000070318C64E40984A0F1040038500000182C08203000146128
...    5C41000E14000711800003858108018400A1051E8260078005038280381804A00E000C0480080C07C120040000000200000401000000008000010040000100200000C0100
...    0008008000050040020080200800006004000038020010000000400004002000024010000060080000A004000058020010240900400006019CA8ACA9AC14AC14AC19AC15A
...    CA5AC99AC05AC0DAC04AC08AC1DA0682000012CA48080000CB29282000052CA48080001CB29202000092CA48080002CB292020000D2CA48080003CB29202000112CA48080
...    004CB29202000152CA48080005CB29202000192CA480800018B292019A55174AAAA9545D2A8AA0B154162A83455298AA4D154062A81455268AA0F142405E02540A0502814
...    0A05028140A05028140A05028140A05000A08080600C02004008804030060100C018040080118080600C02004008080600C02018030C04030060100200404030060100C01
...    8602018030080600C02004008080600C40100C01804030060100C018040300601002004202018030080100420100C01804008020100C01860201803008010040200401008
...    0600C30100C01804030060100C018040080210080600C0201803008010043543E00020406080C0E1416181A2022242628303236383A3E424A4C4E5052545A5E828305A0
${DA12_UE_2}    SEPARATOR=
...    E9A09000575F5A13160003C2A002C1262E003387A0E026C830E7CC31E50B03826010188E01F71B0A303582308682041D207036B64C558D0E7C471E819F604F8C48E3C873E
...    A39F30C7942C0E070F05C00FFC007003FF0003C800E00365FFFE5FFFE0541B107582308682041E207032B64C55890E7D813E238F1891C790E7D473E618F28581C0E1E13FF
...    E00000FFF80000078001C0AA3626EB04610D04083A40E0616C98AA221CF88E3C471E819F604F8C73E618F28581C0E1E0B801FF800E007FE00079001C006CBFFFCBFFFC0AE
...    3E236B04610D04083E5038155B262AC2873E238F180000000000000000000003C04FFF800003FFE000001E00070009E2E2080061040E140000010B0102F1F104003850001
...    8460308C00020B010200E0234028809B01042D80B0104006000070218C04E40984A0F1040038500000182C082030001461285C41000E14000711800003858108018400A10
...    51E8260078005038280381804A00E000C0480080C07C120040000000200000401000000008000010040000100200000C01000008008000050040020080200800006004000
...    038020010000000400004002000024010000060080000A004000058020010240900400006019CA8ACA9AC14AC14AC19AC15ACA5AC99AC05AC0DAC04AC08AC1DA068200001
...    2CA48080000CB29282000052CA48080001CB29202000092CA48080002CB292020000D2CA48080003CB29202000112CA48080004CB29202000152CA48080005CB292020001
...    92CA480800018B292019A55174AAAA9545D2A8AA0B154162A83455298AA4D154062A81455268AA0F142405E02540A05028140A05028140A05028140A05028140A05000A08
...    080600C02004008804030060100C018040100118080600C02008008080600C02018030C04030060100200404030060100C018602018030080600C02004008080600C40100
...    C01804030060100C018040300601002004202018030080100420100C01804008020100C018602018030080100402004010080600C30100C01804030060100C01804008021
...    0080600C0201803008010043543E00020406080C0E1416181A2022242628303236383A3E424A4C4E5052545A5E828305A

${DA_18_UE_1}    SEPARATOR=
...    E9A09000575F5A13160003C5200016093170019C3D0B004D9061CF9863CA160704C060188E01F71B0A303582308682041D211001B5B262AC6
...    873E238F40CFB027C62471E439F51CF98E7CA1607038782E007FE003801FF8003640001C006CBFFFCBFFFC0A83620EB04610D04083C422003
...    2B64C55890E7D813E238F1891C790E7D473E618F28581C0E1E0BFFE00000FFF800000D80000702A8D89BAC1184341020E908800C2D9315444
...    39F11C788E3D033EC09F18E7CC31E50B0381C3C17003FF001C00FFC001B20000E00365FFFE5FFFE0571F11B582308682041F284400556C98A
...    B0A1CF88E3C60000000000000000000000F00BFFE00000FFF800000D800007000DE2E2080070A000308200000B0102F1F0A0003882001C460
...    00E230000020B0102F1F104003008070A000380800000C2C040803808D00A2026C0411B60003C061001800600002C146318C601AD03802100
...    61206004C2587882001C2800000A16041018410000598491710400388C001C2800000C168806C73E18C608100482202027A0F8003C00281C1
...    401C0C02500700060240040603E01802000000010000020080000200400001807CA9BCA9BC14BC14A0102000012CA48080000CB2928200005
...    2CA480169545D2AAAA0B143D003C00E8140A0500006A008000001000000040000001001220100600C04008010100600C20200C01808010023
...    0100200404018030100600C04018001808030060200C01808010020200C018804018030100200404018030808030060200401080401803010
...    0600C04008021808030060200401008010040200C018C04018030100600C04018030100200840200401008030000200C000D50F8000810182
...    030385058606880889098A0C0C8D8E0E8F909293139414951697A0A0C1680


@{change_F3_setup_and_limitpcsiforUE2toaddscell}
...    NRCELL-13:pucchF3ModulationScheme=pi2bpsk
#...    NRCELL-13:pucchF3ModulationScheme=qpsk_4psk
...    NRCELL-13:pucchF3MaxCodeRate=zeroDot80
...    @{ulTxSwitchingBoost_20}
...    @{pcsiresource_notenough_forUE2toaddscell}

@{pcsiresource_notenough_forUE2toaddscell}
...    NRCELL-13:numOfRadioResReservForPa=9

@{change_pcsi_resourse_enough}
...    NRCELL-13:numOfRadioResReservForPa=0
...    NRCELL-13:numOfRadioResReservForTempUse=0
...    NRCELL-13:numOfRadioResReservForEmergency=0
...    NRCELL-11:periodicCsiAcquisition:csiReportPeriodicity=slots40
...    NRCELL-12:periodicCsiAcquisition:csiReportPeriodicity=slots40
...    NRCELL-13:periodicCsiAcquisition:csiReportPeriodicity=slots40
...    NRCELL-14:periodicCsiAcquisition:csiReportPeriodicity=slots40

@{Counters_case2_1}
...    NRCELL-1:${ACC_NUM_UL_TX_SW_OP1_UE_CAP}=0
...    NRCELL-1:${ACC_NUM_UL_TX_SW_OP1_UE_CONFG}=0
...    NRCELL-1:${DEN_1_SEC_SAMPLE}>1
...    NRCELL-1:${AVG_NUM_UE_DENOM}>1
...    NRCELL-1:${SUM_SA_UE_FULL_PWR_FR1}=0
...    NRCELL-1:${SUM_SA_UE_FULL_PWR1_FR1}=0
...    NRCELL-1:${SUM_SA_UE_FULL_PWR2_FR1}=0
...    NRCELL-1:${DENOM_UE_FULL_PWR_FR1}=0
...    NRCELL-1:${MAX_SA_UES_FULL_PWR_FR1}=0
...    NRCELL-1:${MAX_SA_UES_FULL_PWR1_FR1}=0
...    NRCELL-1:${MAX_SA_UES_FULL_PWR2_FR1}=0
...    NRCELL-13:${ACC_NUM_UL_TX_SW_OP1_UE_CAP}>1
...    NRCELL-13:${ACC_NUM_UL_TX_SW_OP1_UE_CONFG}>1
...    NRCELL-13:${DEN_1_SEC_SAMPLE}>1
...    NRCELL-13:${AVG_NUM_UE_DENOM}>1
...    NRCELL-13:${SUM_SA_UE_FULL_PWR_FR1}=0
...    NRCELL-13:${SUM_SA_UE_FULL_PWR1_FR1}=0
...    NRCELL-13:${SUM_SA_UE_FULL_PWR2_FR1}=0
...    NRCELL-13:${DENOM_UE_FULL_PWR_FR1}=0
...    NRCELL-13:${MAX_SA_UES_FULL_PWR_FR1}=0
...    NRCELL-13:${MAX_SA_UES_FULL_PWR1_FR1}=0
...    NRCELL-13:${MAX_SA_UES_FULL_PWR2_FR1}=0

${ACC_NUM_UL_TX_SW_OP1_UE_CAP}    M55181C00010
${ACC_NUM_UL_TX_SW_OP1_UE_CONFG}    M55118C00053
${DEN_1_SEC_SAMPLE}    M55118C00054
${AVG_NUM_UE_DENOM}    M55181C00003

${SUM_SA_UE_FULL_PWR_FR1}    M55114C01501
${SUM_SA_UE_FULL_PWR1_FR1}    M55114C01502
${SUM_SA_UE_FULL_PWR2_FR1}    M55114C01503
${DENOM_UE_FULL_PWR_FR1}    M55114C01505
${MAX_SA_UES_FULL_PWR_FR1}    M55156C00001
${MAX_SA_UES_FULL_PWR1_FR1}    M55156C00002
${MAX_SA_UES_FULL_PWR2_FR1}    M55156C00003

@{config_DB_02}
...    @{change_pcsi_resourse_enough}
...    @{disable-A4}

@{config_DA_12}
...    @{change_pcsi_resourse_enough}
...    NRBTS:actHighestEstNrTputBcSel=true
#...    NRCELL-1:chBw=60MHz
#...    NRCELL-2:chBw=80MHz

@{config_DA_18}
...    @{change_pcsi_resourse_enough}
...    NRBTS:actHighestEstNrTputBcSel=false
#...    NRCELL-1:chBw=60MHz
#...    NRCELL-2:chBw=80MHz
...    NRCELL-13:a1MeasSCellAddSsbRsrp:a1ThresholdUlTxSwitchingDelta=30
...    NRCELL-1:a2MeasSCellRelSsbRsrp:a2ThresholdUlTxSwitchingDelta=30
...    NRCELL-2:a2MeasSCellRelSsbRsrp:a2ThresholdUlTxSwitchingDelta=0

@{change_UlTxSwitchingDelta_1}
...    delete:NRCELL-13:a1MeasSCellAddSsbRsrp:a1ThresholdUlTxSwitchingDelta
...    NRCELL-1:a2MeasSCellRelSsbRsrp:a2ThresholdUlTxSwitchingDelta=5
...    NRCELL-2:a2MeasSCellRelSsbRsrp:a2ThresholdUlTxSwitchingDelta=30

@{change_UlTxSwitchingDelta_2}
...    NRCELL-13:a1MeasSCellAddSsbRsrp:a1ThresholdUlTxSwitchingDelta=15
...    NRCELL-1:a2MeasSCellRelSsbRsrp:a2ThresholdUlTxSwitchingDelta=0

@{change_UlTxSwitchingDelta_3}
...    NRCELL-13:a1MeasSCellAddSsbRsrp:a1ThresholdUlTxSwitchingDelta=0
...    delete:NRCELL-1:a2MeasSCellRelSsbRsrp:a2ThresholdUlTxSwitchingDelta

@{scell_a2_release_msg}    sCellToReleaseList    rrcReconfigurationComplete

*** Test Cases ***
CB012149-SR-BA_ET_06_01_check PUCCH resource before and after UL Tx switch CA addition and release with frame structure 1208
    [Documentation]
    ...    == Precondition: ==
    ...    GNB:

    ...        CELL      TEC    BAND    CHBW    NRARFCN          GSCN    ssbFrequency    PCI    nrCellIdentity
    ...        CELL1     TDD    N41     70M     518598           6480    518430          50     16385
    ...        CELL2     TDD    N78     90M     636666           7880    636576          51     16386
    ...        CELL11    FDD    N66     20M     424000/344000    5297    423850          60     16395
    ...        CELL12    FDD    N71     10M     126900/136100    1587    126990          61     16396
    ...        CELL13    FDD    N66     30M     430920/350920    5385    430830          62     16397
    ...        CELL14    FDD    N71     10M     129000/138200    1611    128910          63     16398

    ...        CB012149 enable/CB009169 enable/CB008311 enable/ulTxSwitchingBoost 2

    ...    UE:
    ...        A1 > a1ThresholdSCellAddSsbRsrpTDD
    ...        normal BC:
    ...            BC#5: N66a*-N78a*-N66a*
    ...        ultxswitch BC:
    ...            ulTxSwitchingBoost 2
    ...            BC#2: N66a*-N66a*-N71a*-N41*
    ...    == Test steps: ==
    ...    step 1. ulTxSwitchingBoost 20,pucchF3ModulationScheme pi2bpsk,pucchF3MaxCodeRate zeroDot80,normal pcsi resource 5
    ...    step 2. UE1 ICS success, report A1 to trigger scell addition (UL TX switch BC#2 selected)
    ...    step 3. UE2 ICS success, report A1 and no scell added due to no pcsi resource as TDD scell need 2 pcsi resources
    ...    step 4. release UE1 scells one by one
    ...    step 5. change ulTxSwitchingBoost 10
    ...    step 6. UE3 ICS success, report A1 to trigger scell addition(normal BC#5 selected)
    ...    step 7. release UE3 scells one by one
    [Tags]    owner-tom.li
    OnlineParamChange    ${change_F3_setup_and_limitpcsiforUE2toaddscell}
    UE Register Setup PDU Trigger Scell Addition By A1    ue_id=1    srsrp_nr=61    ue_capa=${BA_06_UE_1}
    UE Register Setup PDU Trigger Scell Addition failed By A1    ue_id=2    srsrp_nr=61    ue_capa=${BA_06_UE_1}
    Release UE1 scells one by one
    OnlineParamChange    ${ulTxSwitchingBoost_10}
    UE Register Setup PDU Trigger Scell Addition By A1    ue_id=3    srsrp_nr=61    ue_capa=${BA_06_UE_1}
    Release UE3 scells one by one
    Check RRC Log    ${CURDIR}${/}A2A_BA_case06${/}a2a.ini
    [teardown]    Recover And Test Teardown

CB012149-SR-AZ-B3_ET_01_01_scell selection with UL TX switch BC not fallback of normal BC for A1
    [Documentation]
    ...    == Precondition: ==
    ...    GNB:

    ...        CELL      TEC    BAND    CHBW    NRARFCN          GSCN    ssbFrequency    PCI    nrCellIdentity
    ...        CELL1     TDD    N41     70M     518598           6480    518430          50     16385
    ...        CELL2     TDD    N78     90M     636666           7880    636576          51     16386
    ...        CELL11    FDD    N66     20M     424000/344000    5297    423850          60     16395
    ...        CELL12    FDD    N71     10M     126900/136100    1587    126990          61     16396
    ...        CELL13    FDD    N66     30M     430920/350920    5385    430830          62     16397
    ...        CELL14    FDD    N71     10M     129000/138200    1611    128910          63     16398

    ...        CB012149 enable/CB009169 enable/CB008311 enable/ulTxSwitchingBoost 2

    ...    UE:
    ...        A1 > a1ThresholdSCellAddSsbRsrpTDD
    ...        normal BC:
    ...            BC#1: N66a*-N41a*-N66a*
    ...        ultxswitch BC:
    ...            ulTxSwitchingBoost 2
    ...            BC#2: N66a*-N78a*-N71a
    ...    == Test steps: ==
    ...    step 1. ulTxSwitchingBoost 20
    ...    step 2. UE1 ICS success to cell-13(FDD), report A1 to trigger scell addition (UL TX switch BC#2 selected)
    ...    step 3. trigger UE1 intra-gnb HO to cell-2(TDD)
    ...    step 4. report A1 to trigger scell addition (UL TX switch BC#2 selected)
    ...    step 5. release scells one by one
    ...    step 6. report A1 to trigger scell addition (UL TX switch BC#2 selected)
    [Tags]    owner-tom.li
    OnlineParamChange    ${change_pcsi_resourse_enough}
    UE Register Setup PDU Trigger Scell Addition By A1    ue_id=1    srsrp_nr=61    ue_capa=${AZ_B3_UE_1}
    Send A2 A3 report to trigger intra-gnb handover to TDD cell-2
    Trigger Scell Addition By A1    ue_id=1    srsrp_nr=61    carrierfreq=${Cell2_ssbFrequency}
    Scell A2 report to trigger Scell Release    ue_id=1    carrierfreq=${Cell13_ssbFrequency}    scell_id=2
    Scell A2 report to trigger Scell Release    ue_id=1    carrierfreq=${Cell12_ssbFrequency}    scell_id=1
    Trigger Scell Addition By A1    ue_id=1    srsrp_nr=61    carrierfreq=${Cell2_ssbFrequency}
    UE Deregister    ue_id=1
    Check RRC Log    ${CURDIR}${/}A2A_AZ-B3_case01${/}a2a.ini
    [teardown]    Recover And Test Teardown

CB012149-SR-AZ-B3_ET_02_01_scell selection with UL TX switch BC not fallback of normal BC for A4
    [Documentation]
    ...    == Precondition: ==
    ...    GNB:

    ...        CELL      TEC    BAND    CHBW    NRARFCN          GSCN    ssbFrequency    PCI    nrCellIdentity
    ...        CELL1     TDD    N41     70M     518598           6480    518430          50     16385
    ...        CELL2     TDD    N78     90M     636666           7880    636576          51     16386
    ...        CELL11    FDD    N66     20M     424000/344000    5297    423850          60     16395
    ...        CELL12    FDD    N71     10M     126900/136100    1587    126990          61     16396
    ...        CELL13    FDD    N66     30M     430920/350920    5385    430830          62     16397
    ...        CELL14    FDD    N71     10M     129000/138200    1611    128910          63     16398

    ...        CB012149 enable/CB009169 enable/CB008311 enable/ulTxSwitchingBoost 2

    ...    UE:
    ...        A1 > a1ThresholdSCellAddSsbRsrpTDD
    ...        normal BC:
    ...            BC#1: N66a*-N41a*-N66a*
    ...        ultxswitch BC:
    ...            ulTxSwitchingBoost 2
    ...            BC#3: N66a*-N41a*-N71a
    ...    == Test steps: ==
    ...    step 1. ulTxSwitchingBoost 20
    ...    step 2. UE1 ICS success to cell-13(FDD), start data and report A4 to trigger scell addition (UL TX switch BC#3 selected)
    ...    step 3. release scell
    ...    step 4. report A4 to trigger scell addition (UL TX switch BC#2 selected)
    ...    step 5. trigger UE1 intra-gnb HO to cell-2(TDD)
    ...    step 6. report A4 to trigger scell addition (UL TX switch BC#2 selected)
    [Tags]    owner-tom.li
    OnlineParamChange    ${A4basedCA}
    UE Register Setup PDU Trigger Scell Addition By A4    ue_id=1    nrsrp_nr=61    ue_capa=${AZ_B3_UE_1}    ssbfreq=${Cell1_ssbFrequency}
    Scell A2 report to trigger Scell Release    ue_id=1    carrierfreq=${Cell1_ssbFrequency}    scell_id=1
    sleep    5s    #sleeping for event A4 retry
    Trigger Scell Addition By A4    ue_id=1    nrsrp_nr=61    ssbfreq=${Cell1_ssbFrequency}
    Send A2 A3 report to trigger intra-gnb handover to TDD cell-2
    Trigger Scell Addition By A4    ue_id=1    nrsrp_nr=61    ssbfreq=${Cell13_ssbFrequency}    phycell_id=62
    UE Deregister    ue_id=1
    Check RRC Log    ${CURDIR}${/}A2A_AZ-B3_case02${/}a2a.ini
    [teardown]    Recover And Test Teardown

CB012149-SR-DB_ET_02_01_scell selection with full TX power mode
    [Documentation]
    ...    == Precondition: ==
    ...    GNB:

    ...        CELL      TEC    BAND    CHBW    NRARFCN          GSCN    ssbFrequency    PCI    nrCellIdentity
    ...        CELL1     TDD    N41     70M     518598           6480    518430          50     16385
    ...        CELL2     TDD    N78     90M     636666           7880    636576          51     16386
    ...        CELL11    FDD    N66     20M     424000/344000    5297    423850          60     16395
    ...        CELL12    FDD    N71     10M     126900/136100    1587    126990          61     16396
    ...        CELL13    FDD    N66     30M     430920/350920    5385    430830          62     16397
    ...        CELL14    FDD    N71     10M     129000/138200    1611    128910          63     16398

    ...        CB012149 enable/CB009169 enable/CB008311 enable/ulTxSwitchingBoost 2

    ...    UE:
    ...        A1 > a1ThresholdSCellAddSsbRsrpTDD
    ...        normal BC:
    ...            BC#3: N66a*-N41a*-N66a*-N71a
    ...        ultxswitch BC:
    ...            ulTxSwitchingBoost 2
    ...            BC#3: N66a*-N41a*-N71a
    ...    == Test steps: ==
    ...    step 1. ulTxSwitchingBoost 20
    ...    step 2. UE1 ICS success to cell-13(FDD), report A1 to trigger scell addition (UL TX switch BC#2 selected),full powermode1 configured
    ...    step 3. deregister UE1
    ...    step 4. UE1 ICS success to cell-13(FDD), report A1 to trigger scell addition (normal BC#3 selected),no full powermode configured
    ...    step 5. deregister UE2
    ...    step 6. UE3 ICS success to cell-13(FDD), report A1 to trigger scell addition (UL TX switch BC#2 selected),full powermode2 configured
    ...    step 7. trigger RLQ to bad, no SRS port reconfigure
    ...    step 8. deregister UE3
    ...    step 9. UE4 ICS success to cell-13(FDD), report A1 to trigger scell addition (UL TX switch BC#2 selected),no full powermode configured
    ...    step 10. trigger RLQ to bad, no SRS port reconfigure
    ...    step 11. deregister UE4
    ...    step 12. check PM counter
    [Tags]    owner-tom.li    t02
    OnlineParamChange    ${config_DB_02}
    Clear Counter files
    UE1 ICS and scell addition with fullpowermode1
    UE2 ICS and scell addition without fullpowermode0 as normal BC
    UE3 ICS and scell addition with fullpowermode2 then not trigger SRS port switch
    UE4 ICS and scell addition without fullpowermode then not trigger SRS port switch
    Check Counters    ${Counters_case2_1}
    Check RRC Log    ${CURDIR}${/}A2A_DB_case02${/}a2a.ini
    [teardown]    Recover And Test Teardown

CB012149-SR-DA_ET_12_01_scell change from FDD DL only to FDD and TDD UL CA
    [Documentation]
    ...    == Precondition: ==
    ...    GNB:

    ...        CELL      TEC    BAND    CHBW    NRARFCN          GSCN    ssbFrequency    PCI    nrCellIdentity
    ...        CELL1     TDD    N41     60M     518598           6480    518430          50     16385
    ...        CELL2     TDD    N78     80M     636666           7880    636576          51     16386
    ...        CELL11    FDD    N66     20M     424000/344000    5297    423850          60     16395
    ...        CELL12    FDD    N71     10M     126900/136100    1587    126990          61     16396
    ...        CELL13    FDD    N66     30M     430920/350920    5385    430830          62     16397
    ...        CELL14    FDD    N71     10M     129000/138200    1611    128910          63     16398

    ...        CB012149 enable/CB009169 enable/CB008311 enable/ulTxSwitchingBoost 2

    ...    UE:
    ...        A1 > a1ThresholdSCellAddSsbRsrpTDD
    ...        normal BC:
    ...            BC#3: N66a*-N71a*-N66a*
    ...        ultxswitch BC:
    ...            ulTxSwitchingBoost 2
    ...            BC#1: N66a*-N41a*
    ...    == Test steps: ==
    ...    step 1. ulTxSwitchingBoost 20
    ...    step 2. UE1 ICS success to cell-13(FDD), report A1 to trigger scell addition (normal BC#3 selected)
    ...    step 3. report A1 to trigger scell change (ul tx switch BC#1 selected)
    ...    step 4. deregister UE1
    ...    step 5. UE2 ICS success to cell-13(FDD), report A1 to trigger scell addition (normal BC#3 selected)
    ...    step 6. report A1 to trigger scell change (normal BC#1 selected)
    ...    step 7. deregister UE2
    [Tags]    owner-annie.nie    t12
    OnlineParamChange    ${config_DA_12}
    UE Register Setup PDU Trigger Scell Addition By A1    ue_id=1    srsrp_nr=51    ue_capa=${DA12_UE_1}
    Trigger Scell Addition By A1    ue_id=1    srsrp_nr=61
    UE Deregister    ue_id=1
    UE Register Setup PDU Trigger Scell Addition By A1    ue_id=2    srsrp_nr=51    ue_capa=${DA12_UE_2}
    Trigger Scell Addition By A1    ue_id=2    srsrp_nr=61
    UE Deregister    ue_id=2
    Check RRC Log    ${CURDIR}${/}A2A_DA_case12${/}a2a.ini
    [teardown]    Recover And Test Teardown

CB012149-SR-DA_ET_18_01_scell addition and release with normal BC then addition and release with UL TX switch BC
    [Documentation]
    ...    == Precondition: ==
    ...    GNB:

    ...        CELL      TEC    BAND    CHBW    NRARFCN          GSCN    ssbFrequency    PCI    nrCellIdentity
    ...        CELL1     TDD    N41     60M     518598           6480    518430          50     16385
    ...        CELL2     TDD    N78     80M     636666           7880    636576          51     16386
    ...        CELL11    FDD    N66     20M     424000/344000    5297    423850          60     16395
    ...        CELL12    FDD    N71     10M     126900/136100    1587    126990          61     16396
    ...        CELL13    FDD    N66     30M     430920/350920    5385    430830          62     16397
    ...        CELL14    FDD    N71     10M     129000/138200    1611    128910          63     16398

    ...        CB012149 enable/CB009169 enable/CB008311 enable/ulTxSwitchingBoost 2

    ...    UE:
    ...        A1 > a1ThresholdSCellAddSsbRsrpTDD
    ...        normal BC:
    ...            BC#1: N66a*-N41a*-N66a*
    ...        ultxswitch BC:
    ...            ulTxSwitchingBoost 2
    ...            BC#2: N66a*-N41a*-N71a
    ...    == Test steps: ==
    ...    step 1. ulTxSwitchingBoost 20
    ...    step 2. UE1 ICS success to cell-13(FDD), report A1 to trigger scell addition (UL TX switch BC#2 selected)
    ...    step 3. release scell, onlinechange UlTxSwitchingDelta
    ...    step 4. report A1 to trigger scell addition (UL TX switch BC#2 selected)
    ...    step 5. release scell, onlinechange UlTxSwitchingDelta
    ...    step 6. report A1 below A1+delta to trigger scell addition (normal BC#1 selected)
    ...    step 7. release scell, report A1 above A1+delta to trigger scell addition (UL TX switch BC#2 selected)
    ...    step 8. release scell, onlinechange UlTxSwitchingDelta
    ...    step 9. report A1 to trigger scell addition (UL TX switch BC#2 selected)
    [Tags]    owner-tom.li    t18
    OnlineParamChange    ${config_DA_18}
    UE1 scell addition with A1delta 30 and A2delta 30
    OnlineParamChange    ${change_UlTxSwitchingDelta_1}
    UE1 scell addition with A1delta none and A2delta 5
    OnlineParamChange    ${change_UlTxSwitchingDelta_2}
    UE1 scell addition with below and equal A1delta 15 and A2delta 0
    OnlineParamChange    ${change_UlTxSwitchingDelta_3}
    UE1 scell addition with A1delta 0 and A2delta none
    UE Deregister    ue_id=1
    Check RRC Log    ${CURDIR}${/}A2A_DA_case18${/}a2a.ini

*** Keywords ***
Modify Cfg
    FOR    ${gateway_id}    IN RANGE    1    11
        Update Cfg    set_pdu_gateway id=${gateway_id} ue_nat_ip=72.23.${gateway_id}.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    END
    ${V1}    catenate
    ...    set_ue simulated id=1 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...    nea=null+snow3g+aes+zuc nia=null+snow3g+aes+zuc sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0000:0:0:021645400
    ...    enb=2 cell=1 mode=nr
    Update Cfg    ${V1}
    Delete Cfg    set_qosflow id=1 5qi=6 default=on
    Update Cfg    set_qosflow id=1 5qi=8 default=on

Start BTS With Specified Config Files
    Common Suite Setup
    Setup Airphone Env    tl_type=${GNB_CONFIG}
    Execute Egate Command    gnb_param id=3 sib1_period=3000
    Execute Egate Command    ib_enb_cell_disp enb=3 cell=1
    Set UE Parameters Before Register

Recover And Test Teardown
    OnlineParamChange    ${Recover}
    Common Test Teardown And Stop Capture Logs

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be Onair    check_sib=${False}

Set UE Parameters Before Register
    set UE history info    ue_id=1    history_id=1
    Execute Egate Command    gnb_param id=3 xn_listening_socket=1 send_xn_setup=true measEvent=A3
    Execute Egate Command    gnb_xn_link_up gnb=3 target=2    GNB-3: XnAP Link with GNB-2
    Execute Egate Command    set_pdu_param ue=1 pdu=1 trf_type=internal
    Execute Egate Command    set_pdu_param ue=1 pdu=2 trf_type=internal

set UE history info
    [Arguments]    ${ue_id}=1    ${history_id}=1
    Execute Egate Command
    ...    ue_history_information_list_add_ngran id=${history_id} cell_type=large nrcgi=311:489|0x01 gnb_id=2 time_ue_stayed_in_cell=97
    Execute Egate Command
    ...    ue_history_information_list_add_ngran id=${history_id} cell_type=large nrcgi=311:489|0x01 gnb_id=3 time_ue_stayed_in_cell=98
    Execute Egate Command    ue_history_information_list id=${history_id} action=commit
    Execute Egate Command    ue_enb_param id=${ue_id} ue_history_list=${history_id}

Scell A2 report to trigger Scell Release
    [Arguments]    ${ue_id}=31    ${carrierfreq}=${Cell2_ssbFrequency}    ${scell_id}=2
    ${measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A2
    ${A2_Scell_Release}    catenate
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${measid} scell=${scell_id} scell_rsrp=33 scell_rsrq=0 event=A2
    ${ret1}=    Execute Egate Command    ${A2_Scell_Release}    ${scell_a2_release_msg}    # rrcReconfigurationComplete
    # Should Contain    ${ret1}    sCellToReleaseList

Trigger Scell Addition By A1
    [Arguments]    ${ue_id}    ${srsrp_nr}    ${carrierfreq}=${Cell13_ssbFrequency}
    ${measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A1
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${measid} event=A1 srsrp_nr=${srsrp_nr} ssinr_nr=59 srsrq_nr=32
    ...    pass_regexp=rrcReconfigurationComplete

Trigger Scell Addition failed By A1
    [Arguments]    ${ue_id}    ${srsrp_nr}
    ${measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${Cell13_ssbFrequency}    event_type=A1
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${measid} event=A1 srsrp_nr=${srsrp_nr} ssinr_nr=59 srsrq_nr=32
    ...    fail_regexp=rrcReconfigurationComplete    timeout=3s

UE Register And Setup PDU Session
    [Arguments]    ${ue_id}    ${ue_capa}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=13
    Execute Egate Command    ue_register id=${ue_id} ue_nr_capabilities=${ue_capa}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1    QoS Routing Table

UE Register Setup PDU Trigger Scell Addition By A1
    [Arguments]    ${ue_capa}    ${ue_id}    ${srsrp_nr}
    UE Register And Setup PDU Session    ue_id=${ue_id}    ue_capa=${ue_capa}
    Trigger Scell Addition By A1    ue_id=${ue_id}    srsrp_nr=${srsrp_nr}

UE Register Setup PDU Trigger Scell Addition failed By A1
    [Arguments]    ${ue_capa}    ${ue_id}    ${srsrp_nr}
    UE Register And Setup PDU Session    ue_id=${ue_id}    ue_capa=${ue_capa}
    Trigger Scell Addition failed By A1    ue_id=${ue_id}    srsrp_nr=${srsrp_nr}

Release UE1 scells one by one
    Scell A2 report to trigger Scell Release    ue_id=1    carrierfreq=${Cell1_ssbFrequency}    scell_id=1
    Scell A2 report to trigger Scell Release    ue_id=1    carrierfreq=${Cell11_ssbFrequency}    scell_id=2
    Scell A2 report to trigger Scell Release    ue_id=1    carrierfreq=${Cell12_ssbFrequency}    scell_id=3

Release UE3 scells one by one
    Scell A2 report to trigger Scell Release    ue_id=3    carrierfreq=${Cell2_ssbFrequency}    scell_id=1
    Scell A2 report to trigger Scell Release    ue_id=3    carrierfreq=${Cell11_ssbFrequency}    scell_id=2

Send A2 A3 report to trigger intra-gnb handover to TDD cell-2
    UE Report InterFrequency A2 event    ue_id=1    carrierfreq=${Cell13_ssbFrequency}
    UE Report InterFrequency A3 event    ue_id=1    carrierfreq=${Cell2_ssbFrequency}    phycell_id=51

UE Report InterFrequency A2 event
    [Arguments]    ${ue_id}=1    ${carrierfreq}=${Cell1_ssbFrequency}    ${srsrp_nr}=34    ${srsrq_nr}=20
    ${measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A2
    ${ret3}=    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${measid} event=A2 srsrp_nr=${srsrp_nr} srsrq_nr=${srsrq_nr}
    ...    pass_regexp=eventA3

UE Report InterFrequency A3 event
    [Arguments]    ${ue_id}=1    ${carrierfreq}=${Cell1_ssbFrequency}    ${srsrp_nr}=34    ${srsrq_nr}=20
    ...    ${phycell_id}=61    ${nrsrp_nr}=75    ${nrsrq_nr}=75
    ${measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A3
    ${command}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${measid} event=A3 srsrp_nr=${srsrp_nr}
    ...    srsrq_nr=${srsrq_nr} phycell_id=${phycell_id} nrsrp_nr=${nrsrp_nr} nrsrq_nr=${nrsrq_nr}
    ${ret3}=    Execute Egate Command
    ...    ${command}
    ...    pass_regexp=rrcReconfigurationComplete

UE Register Setup PDU Trigger Scell Addition By A4
    [Arguments]    ${ue_capa}    ${ue_id}    ${nrsrp_nr}    ${ssbfreq}
    UE Register And Setup PDU Session    ue_id=${ue_id}    ue_capa=${ue_capa}
    Start Data    ue_id=${ue_id}
    Trigger Scell Addition By A4    ue_id=${ue_id}    nrsrp_nr=${nrsrp_nr}    ssbfreq=${ssbfreq}

Trigger Scell Addition By A4
    [Arguments]    ${ue_id}    ${nrsrp_nr}    ${ssbfreq}    ${phycell_id}=50
    ${measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${ssbfreq}    event_type=A4
    ${command}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${measid} event=A4 srsrp_nr=61 ssinr_nr=59 srsrq_nr=32
    ...    phycell_id=${phycell_id} nrsrp_nr=${nrsrp_nr} nsinr_nr=59 nrsrq_nr=32
    Execute Egate Command    ${command}    pass_regexp=rrcReconfigurationComplete

UE Deregister
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s

Start Data
    [Arguments]    ${ue_id}
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=175 trf_id=1    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=175 trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=175 trf_id=3    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=175 trf_id=4    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=175 trf_id=5    UE ${ue_id}: UDP DL
    sleep    2s    #sleep for stable traffic

Start UL Data
    [Arguments]    ${ue_id}
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=ul mbps=50 trf_id=1    UE ${ue_id}: UDP UL
    sleep    3s    #sleep for stable traffic

Stop UL Data
    [Arguments]    ${ue_id}
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=1 qfi=1 trf_id=1
    ...    pass_regexp=Traffic was stopped

UE3 ICS and scell addition with fullpowermode2 then not trigger SRS port switch
    UE Register Setup PDU Trigger Scell Addition By A1    ue_id=3    srsrp_nr=61    ue_capa=${DB_02_UE_3}
    Start UL Data    ue_id=3
    sleep    3    #sleeping for data stable
    Execute Egate Command    ul_sinr_testmode_nr profile_id=3 pathloss=70 pcmax=-30
    Execute Egate Command    ue_testmode_set_nr id=3 testmode=ul_sinr action=activate profile_id=3
    ...    fail_regexp=rrcReconfigurationComplete    timeout=3s
    Execute Egate Command    ue_testmode_set_nr id=3 testmode=ul_sinr action=deactivate profile_id=3
    ...    fail_regexp=rrcReconfigurationComplete    timeout=3s
    Stop UL Data    ue_id=3
    UE Deregister    ue_id=3

UE4 ICS and scell addition without fullpowermode then not trigger SRS port switch
    UE Register Setup PDU Trigger Scell Addition By A1    ue_id=4    srsrp_nr=61    ue_capa=${DB_02_UE_4}
    Start UL Data    ue_id=4
    sleep    3    #sleeping for data stable
    Execute Egate Command    ul_sinr_testmode_nr profile_id=3 pathloss=70 pcmax=-30
    Execute Egate Command    ue_testmode_set_nr id=4 testmode=ul_sinr action=activate profile_id=3
    ...    fail_regexp=rrcReconfigurationComplete    timeout=3s
    Execute Egate Command    ue_testmode_set_nr id=4 testmode=ul_sinr action=deactivate profile_id=3
    ...    fail_regexp=rrcReconfigurationComplete    timeout=3s
    Stop UL Data    ue_id=4
    UE Deregister    ue_id=4

UE1 ICS and scell addition with fullpowermode1
    UE Register Setup PDU Trigger Scell Addition By A1    ue_id=1    srsrp_nr=61    ue_capa=${DB_02_UE_1}
    Scell A2 report to trigger Scell Release    ue_id=1    carrierfreq=${Cell1_ssbFrequency}    scell_id=1
    Scell A2 report to trigger Scell Release    ue_id=1    carrierfreq=${Cell12_ssbFrequency}    scell_id=2
    UE Deregister    ue_id=1

UE2 ICS and scell addition without fullpowermode0 as normal BC
    UE Register Setup PDU Trigger Scell Addition By A1    ue_id=2    srsrp_nr=61    ue_capa=${DB_02_UE_2}
    UE Deregister    ue_id=2

UE1 scell addition with A1delta 30 and A2delta 30
    UE Register Setup PDU Trigger Scell Addition By A1    ue_id=1    srsrp_nr=90    ue_capa=${DA_18_UE_1}
    Scell A2 report to trigger Scell Release    ue_id=1    carrierfreq=${Cell12_ssbFrequency}    scell_id=2
    Scell A2 report to trigger Scell Release    ue_id=1    carrierfreq=${Cell1_ssbFrequency}    scell_id=1

UE1 scell addition with A1delta none and A2delta 5
    Trigger Scell Addition By A1    ue_id=1    srsrp_nr=60    carrierfreq=${Cell13_ssbFrequency}
    Scell A2 report to trigger Scell Release    ue_id=1    carrierfreq=${Cell12_ssbFrequency}    scell_id=2
    Scell A2 report to trigger Scell Release    ue_id=1    carrierfreq=${Cell1_ssbFrequency}    scell_id=1

UE1 scell addition with below and equal A1delta 15 and A2delta 0
    UE1 scell addition with below A1delta 15 and A2delta 0 and select normal BC
    UE1 scell addition with equal A1delta 15 and A2delta 0

UE1 scell addition with below A1delta 15 and A2delta 0 and select normal BC
    Trigger Scell Addition By A1    ue_id=1    srsrp_nr=74    carrierfreq=${Cell13_ssbFrequency}    #add normal BC as RSRP below A1+DELTA
    Scell A2 report to trigger Scell Release    ue_id=1    carrierfreq=${Cell11_ssbFrequency}    scell_id=2
    Scell A2 report to trigger Scell Release    ue_id=1    carrierfreq=${Cell1_ssbFrequency}    scell_id=1

UE1 scell addition with equal A1delta 15 and A2delta 0
    Trigger Scell Addition By A1    ue_id=1    srsrp_nr=75    carrierfreq=${Cell13_ssbFrequency}
    Scell A2 report to trigger Scell Release    ue_id=1    carrierfreq=${Cell12_ssbFrequency}    scell_id=2
    Scell A2 report to trigger Scell Release    ue_id=1    carrierfreq=${Cell1_ssbFrequency}    scell_id=1

UE1 scell addition with A1delta 0 and A2delta none
    Trigger Scell Addition By A1    ue_id=1    srsrp_nr=61    carrierfreq=${Cell13_ssbFrequency}
    Scell A2 report to trigger Scell Release    ue_id=1    carrierfreq=${Cell12_ssbFrequency}    scell_id=2
    Scell A2 report to trigger Scell Release    ue_id=1    carrierfreq=${Cell1_ssbFrequency}    scell_id=1
