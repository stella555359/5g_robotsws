*** Settings ***
Documentation    Suite description
...   Author:      Geng Lishuo
...   Contact:     lishuo.geng@nokia-sbell.com
...   Squad Group: MMW_SG7
...   Feature:     CB008847
Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Restore Env
Force Tags        QCD_MN_RAN  QCP_RAN_ET  SBTS00  RAN_5G  CRT  CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...               team-DevHZ5_SG1    owner-qi.zheng    release-SBTS23R1
Resource          ../../../../../../resources/DevHZ5_resource.robot

*** Variables ***
${TL_TYPE_PATH}    tdd_sansa_cmwv/FS/2cells_ecpri
@{PARAMS_IN_VENDOR}
...    maxNumOfUserL2Pool=20    maxNumOfDRBL2Pool=400    maxNumOfGBRL2Pool=200    guaranteedResourceRatioPerCell=10
...    maxNumPucchF1SRPerSlotL1Pool=80    maxNumPucchF3PCSIPerSlotL1Pool=30
@{PARAMS_IN_SWCONFIG}
...    ${rdMaxPucchTempUseReservation}
${rdMaxPucchTempUseReservation}
...    0x590186=100

@{PARAMS_IN_SCF}
...    @{PARAMS_8X4_CELLMAPPING}
...    @{5GC000704}
...    @{5GC00572}
...    @{CB008847}
...    @{CA}
...    @{NRREL}
...    @{beamforming}
...    @{2200_enable}
...    ${reestablish_SA_enable}
...    @{NRDRB}
@{CB008847}
...    NRCELL:srPeriodicity=slots80
...    NRCELL:periodicCsiAcquisition:csiReportPeriodicity=slots40
...    NRCELL-2:periodicCsiAcquisition:csiReportPeriodicity=slots80
...    NRCELL:reqMinNumPuschPrb=13
...    NRCELL:pucchModeSelect=longPucch
...    NRBTS:srbInactivityTimerSA=600
...    NRBTS:nsaInactivityTimer=600
...    NRBTS:actConnRrcPooling=true
...    NRBTS:actScheUePooling=true
...    NRBTS:actBbPoolTddFr1=true
...    NRCELL:maxNumOfUsersPerNRCell=20
...    NRCELL:maxNumOfGBRBearersSA=10
...    NRCELL:maxNumOfCaUsersNRCell=20
...    NRCELL:maxNumOfUsersPerCell=20
...    NRCELL:maxNumOfRrcSA=20
...    NRCELL:maxNumOfSCellAlloc=20
...    NRCELL:maxNumOfNrDcSnUsers=20
...    NRCELL:actEmergencyCall=true
...    NRCELL:numOfRadioResReservForEmergency=4
...    NRBTS/NRDU-1:numOfDrbsReservForEmergency=4
...    NRCELL:emergencyCallRestrictions:emergencyCallMrListIgnore=false|emergencyCallPlmnHoAllowed=false
...    NRCELL:actVoNR=true

@{2200_enable}
...    NRCELL:dlMimoMode=8x4 Closed Loop Spatial Multiplexing
...    NRCELL:periodicCsiAcquisition:csirsPower=0
...    NRCELL:periodicCsiAcquisition:csirsNumberWithinReportPeriod_Set1=2
...    NRCELL:periodicCsiAcquisition:maxCsirsNumber=2
...    NRCELL:ssPbchBlockPower=0
...    NRCELL:actCsirsMultiplexing=true
...    NRCELL:openLoopScheme=Automatic

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
...    NRCELL:actPerCsiReportBundlingTddFr1=true



@{5GC00572}
...    NRBTS:actIntraFreqIntraGnbMobilityNSA=true
...    NRBTS:actIntraMeNBMobility=true
...    NRBTS:tWaitingRlRecover=4000ms

@{5GC000704}

...    NRBTS:actConflictConfiguration=true
...    NRBTS:actIntraFreqHoSA=true
...    NRBTS:timerXnDataFwdGuard=250
...    NRPMRNL-1:miNrRelReportCu=15min
...    NRCELL:a3MeasEnabled=rsrp
...    NRCELL:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0|a3TimeToTriggerSsbRsrp=ms320
...    NRCELL:a3MeasSsbRsrp:a3OffsetSsbRsrp=3|a3TimeToTriggerSsbRsrp=ms320
...    NRCELL:filterCoeffSsbRsrp=fc4
...    NRCELL:absThreshSsbRsrpConsolidation=80
...    NRCELL:sMeasConfigSsbRsrp=20
...    NRBTS:actIncXn=true
...    NRBTS:cipherPrefL:nea0=9|nea3_128=0

@{CA}
...    NRBTS/NRDU-1:actConnectedModeMobilityCA=true
...    NRBTS/NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRBTS/NRDU-1:carrierAggregationSupportList=ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Any_Sa
...    NRBTS/NRDU-1:actInterNumerologyCa=true
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS:actMeasBasedSCellAdditionNsa=true
...    NRBTS:actHoOptimizationCa=true
...    NRBTS:sCellActivationMethod=bufferBased
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
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=60
...    NRCELL:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0
...    NRCELL:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=2560ms
...    NRCELL:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=34
...    NRBTS/NRDU-1:actNonBfAndBfCa=true

@{NRREL}
...    NRCELL-1/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-10:gNbId=1
...    NRCELL-1/NRREL-10:gNbIdLength=22
...    NRCELL-1/NRREL-10:lcrId=2
...    NRCELL-1/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-10:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-10:sCellOperationalMode=dlOnly
...    NRCELL-1:actK1Opt=intra-gNB
...    NRCELL-2/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-10:gNbId=1
...    NRCELL-2/NRREL-10:gNbIdLength=22
...    NRCELL-2/NRREL-10:lcrId=1
...    NRCELL-2/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-10:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-10:sCellOperationalMode=dlOnly
...    NRCELL:actK1Opt=intra-gNB
...    NRCELL-2:actK1Opt=intra-gNB
...    delete:NRCELL-2/NRREL-1
...    delete:NRCELL-1/NRREL-1
...    NRCELL-2:gscnOrSsPbchArfcn=7985
...    NRCELL-2:nrarfcn=646666

${Cell1_ssbFrequency}
...    636576

${reestablish_SA_enable}
...    NRBTS:rrcReestabTypeSA=sameGNB

@{NRDRB}
...    MRBTS/NRBTS/NRDRB_RLC_UM-1
...    NRDRB_MAC-3:lcgid=4
...    NRDRB_MAC-2:lcgid=7
...    NRDRB_PDCP-2:pdcpBufDiscardEnabled=false
...    MRBTS/NRBTS/NRDRB-15:dlFlowControlAlgo=none
...    MRBTS/NRBTS/NRDRB-15:resType=GBR
...    MRBTS/NRBTS/NRDRB-15:maxDataRateGbrDl=1000
...    MRBTS/NRBTS/NRDRB-15:maxDataRateGbrUl=1000
...    MRBTS/NRBTS/NRDRB-15:queuingDelayDiscarding=Disabled
...    MRBTS/NRBTS/NRDRB-15:rlcMode=RLC_UM
...    MRBTS/NRBTS/NRDRB-15:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    MRBTS/NRBTS/NRDRB-15:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-2
...    MRBTS/NRBTS/NRDRB-15:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-3
...    NRBTS/NRDRB_5QI-6:fiveqiValueList=1
...    NRBTS/NRDRB_5QI-6:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-15



@{PM_Counters_Check_B7}
...    NRCELL-1:${SA_DU_RAC_FAIL_BBPOOL_NR_USER}=1
...    NRCELL-1:${SGNB_SA_DU_RAC_REJ_DUE_RRC}=1
...    NRCELL-2:${SA_DU_RAC_FAIL_BBPOOL_NR_USER}=0
...    NRCELL-2:${SGNB_SA_DU_RAC_REJ_DUE_RRC}=0
@{PM_Counters_Check_B6}
...    NRCELL-3:${SA_DU_RAC_FAIL_BBPOOL_NR_USER}=0
...    NRCELL-3:${SGNB_SA_DU_RAC_REJ_DUE_RRC}=0
${SA_DU_RAC_FAIL_BBPOOL_NR_USER}
...    M55139C03502
${SGNB_SA_DU_RAC_REJ_DUE_RRC}
...    M55139C00013
${wait_UE_deregister_finish}    1s
${wait_securmodecompl_not_received}    1s
${N78_N78}    SEPARATOR=
...    E9A09000575F5A13160003C6A80002C0100000080001813E01262E003387A1A004D9061CF9863CA160704C0A00C4
...    700FB8D85181AC1184341020E9098006D6C98AB1A1CF88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF
...    800E007FE0011800000702A0D883AC1184341020F109800656C98AB121CFB027C471E31238F21CFA8E7CC31E50B03
...    81C3C27F6000001FD80000023000000E0551B137582308682041D21300082D931540C1BF18E7CC31E50B0381C3C01
...    7003FF001C00FFC0023000000E0571F11B582308682041F284C002AB64C55850E7C471E3000000000000000000000
...    07809FFF000007FFC000008C0000038002F1713400388C001C4D00000256020401C0468051013602094B000001C02
...    10001404613D0140002000C00000B1922E26800711800389A0000042D100D8E7C31A0001000600002081044807A17
...    80003C00281C1401C0C02500700060240040603E09002000000010000020080000000400000802000008010000060
...    080000400400002802001004010040000300200001C01000800000020000200100001200800003004000050020000
...    2C01000812048020000300CE54D654D60A560A560CD60AD652D64CD602D606D6025604560ED034100000965250400
...    0065949410000296525040000E594941000049652504000165949010000696525040001E594941000089652504000
...    265949410000A96525040002E5949410000C96525040000C594940CD2ABBA55754AAAE9555505AAA0B1541A2A94D5
...    526AAA035540A2A93555078A2E0005E02540A05028140A05028140A05028140A05028140A05000608080600C02004
...    008804008010100C018040080110080100202018030080600C10100C0180403006100801002020180300806000201
...    00C01804030060100C018602018030080600C0200401008010043543E00020406080C0E1416181A20222426283032
...    36383A3E424A4C4E5052545A5E828305A0
*** Test Cases ***
CB008847-B_ET_07_01_The NR User number for TDD L2 pool check for CA users when Reestablishment
    [Documentation]
    ...    precondition:
    ...    one cell in one pool
    ...    Cell-1 as PCell is covBasedA1 CA relation for cell-2
    ...           maxNumOfUserL2Pool: 20
    ...           Guaranteed L2 NR User number per cell: 2
    ...           Emergency resource (NR User Number) per cell: 4
    ...           Shared resource (NR User Number) in one pool: 14
    ...    step1: EXPECT: register 12 UEs on cell1 pass
    ...    step2: EXPECT: register 1 UE on cell3 pass
    ...    step3: EXPECT: register normal UE-14 on cell1 with A1 CA cell3 pass
    ...    step4: EXPECT: reestablish the UE-14 on cell1 fail
    ...                   counter SA_DU_RAC_FAIL_BBPOOL_NR_USER, SGNB_SA_DU_RAC_REJ_DUE_RRC value increase 1 on cell1
    ...                   counter SA_DU_RAC_FAIL_BBPOOL_NR_USER, SGNB_SA_DU_RAC_REJ_DUE_RRC value no change on cell3
    ...    step5: EXPECT: register normal UE-15 on cell1 with A1 CA cell3 pass
    ...    step6: EXPECT: reestablish the UE-15 to cell2, reestablish succeed
    [Tags]
    [Setup]    Common Test Setup And Start To Capture Logs On Case7
    [Teardown]    Common Test Setup And Stop To Capture Logs On Case7
    Register For Number Of Normal Calls    cell_id=1    ue_id_start=1    ue_id_end_before=16
    Register For Number Of Normal Calls    cell_id=2    ue_id_start=16    ue_id_end_before=17
    Register And Set up PDU For Normal Call with report A1 scell added Successfully    ue_id=17    cell_id=1
    Clear Counter files
    reestablish UE to serving cell fail    ue_id=17
    Check Counters    ${PM_Counters_Check_B7}
    #Register And Set up PDU For Normal Call with report A1 scell added Successfully    ue_id=18    cell_id=1
    reestablish UE to target cell succeed    ue_id=10


*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=${TL_TYPE_PATH}
    Set UE Parameters Before Register

Set UE Parameters Before Register
    Execute Egate Command    enb_x2_link_up enb=1 target=2    None

Modify Cfg
    Set Bear in WTS
    Set PDU Session in WTS
    Set Sim gNB

Set Sim gNB
    ${cfg_cmd_1}    catenate
    ...    set_gnb id=3 type=simulated plmn=311:489 s1u=10.0.1.124 ng=10.0.1.123
    ...    gnb_id=0x24:22 daemon=10.0.2.1:22222 x2=10.0.1.126:36422 x2_peers=none xn=10.0.1.122 nssai=0x1:0xd143a5 amf=1
    ${cfg_cmd_2}    catenate
    ...    gnb_param id=3 x2_listening_socket=1 measEvent=A3
    ${cfg_cmd_3}    catenate
    ...    gnb_param id=3 xn_listening_socket=1 send_xn_setup=true
    ${cfg_cmd_4}    catenate
    ...    set_cell id=1 gnb=3 pci=16:0 tac=788 nrci=0x01 tdd_cell=off proxy=10.0.2.92:9999 nr_arfcn=135580:126380 gscn=1579
    Update Cfg    ${cfg_cmd_1}
    Update Cfg    ${cfg_cmd_2}
    Update Cfg    ${cfg_cmd_3}
    Update Cfg    ${cfg_cmd_4}

Set Bear in WTS
    ${cfg_cmd_3}    catenate
    ...    ul_nat_gw=10.0.2.1 dl_nat_gw=10.0.2.1 trf_type=internal
    FOR    ${ue_id}    IN RANGE    32    56
        Update Cfg    set_bearer id=2 ue=${ue_id} qci=9 pdn=1 ip=4.7.254.2${ue_id} default=on ${cfg_cmd_3}
        Update Cfg    set_bearer id=3 ue=${ue_id} qci=8 default=off
    END

Set PDU Session in WTS
    ${cfg_cmd}    catenate
      ...    qos_flows=3,2,1 qos_rules=1,2 ue=1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30
      Update Cfg    set_qosflow id=1 5qi=5 default=on
    Update Cfg    set_qosflow id=3 5qi=6 default=off
    Update Cfg    set_qosflow id=2 5qi=1
    Update Cfg    qosrule_set id=1 proto=tcp qos_flow=1
    Update Cfg    qosrule_set id=2 proto=udp qos_flow=2
    Update Cfg    set_nwslice id=1 snssai=0x01:0xd143a5 amf=1 default=on ${cfg_cmd}
    FOR    ${ue_id}    IN RANGE    2    31
        Update Cfg    set_pdu_gateway id=${ue_id} ue_nat_ip=72.23.0.${ue_id} dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    END

Common Test Teardown And Restore Env
    Common Test Teardown And Stop Capture Logs

Modify QOSflow
    [Arguments]    ${priority}
    Execute Egate Command    qosflow_modify qos_flow=1 priority=${priority}    None
    Execute Egate Command    qosflow_modify qos_flow=2 priority=${priority}    None

Modify UE Establishemnt Cause
    [Arguments]    ${ue_id}    ${cause}
    Execute Egate Command    ue_nr_rrc_setup_param id=${ue_id} establishment_cause=${cause}    None



Register For Normal Call Successfully
  [Arguments]    ${ue_id}    ${cell_id}
  Execute Egate Command  ue_change_location id=${ue_id} cell=${cell_id}    None
  Modify UE Establishemnt Cause    ${ue_id}    mo-Signalling
  UE Register To GNB    ${ue_id}

Register And Set up PDU For Normal Call Successfully
  [Arguments]    ${ue_id}    ${cell_id}
  Execute Egate Command  ue_change_location id=${ue_id} cell=${cell_id}    None
  Modify UE Establishemnt Cause    ${ue_id}    mo-Signalling
  UE Register To GNB    ${ue_id}
  #sleep    ${wait_securmodecompl_not_received}    #wait for a while due to sometimes SecurityModeComplete not received and result in UE release
  UE PDU Session Setup    ${ue_id}    ${ue_id}

Register For Number Of Normal Calls
  [Arguments]    ${cell_id}    ${ue_id_start}    ${ue_id_end_before}
  Modify QOSflow    priority=15
  FOR    ${ue_id}    IN RANGE    ${ue_id_start}    ${ue_id_end_before}
        Register For Normal Call Successfully    ${ue_id}    ${cell_id}
        UE PDU Session Setup    ${ue_id}    ${ue_id}
  END

UE Register To GNB
  [Arguments]    ${ue_id}
  Execute Egate Command    ue_register id=${ue_id} ue_nr_capabilities=${N78_N78}   UE now in NG RM Reg

UE PDU Session Setup
  [Arguments]    ${ue_id}=1    ${gw_id}=1
  ${ret1}=    Execute Egate Command    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=${gw_id}    QoS Routing Table
  Should Contain  ${ret1}  Created FiveQi:Qfi mapping fiveQi 5 qfi 1

reestablish UE to serving cell fail
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_rrc_reestablish id=${ue_id} gnb=2 cell=1    fail
    Execute Egate Command    ue_disp state=ACTIVE    2.1

reestablish UE to target cell succeed
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_rrc_reestablish id=${ue_id} gnb=2 cell=2    Reestablishment sucessfully completed
    Execute Egate Command    ue_disp state=ACTIVE    2.2

Register And Set up PDU For Normal Call with report A1 scell added Successfully
    [Arguments]    ${ue_id}    ${cell_id}
    [Return]    ${ret}
    Execute Egate Command    ue_change_location id=${ue_id} cell=${cell_id}    None
    Modify UE Establishemnt Cause    ${ue_id}    mo-Signalling
    UE Register To GNB    ${ue_id}
    ${ret}    Execute Egate Command    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=${ue_id}    QoS Routing Table
    UE report A1 to add scell Successfully    ${ue_id}


Common Test Setup And Start To Capture Logs On Case7
    Common Test Setup And Start To Capture Logs


Common Test Setup And Stop To Capture Logs On Case7
    Common Test Teardown And Stop Capture Logs

UE report A1 to add scell Successfully
    [Arguments]    ${ue_id}
    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${Cell1_ssbFrequency}    event_type=A1
    ${ret1}=    Execute Egate Command
    ...    ue_measurement_send_nr id=${ue_id} meas_id=2 phycell_id=50 event=A1 srsrp_nr=80 srsrq_nr=40
    ...    sCellToAddModList



