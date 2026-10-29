*** Settings ***
Suite Setup  Common Suite Setup And Setup Airphone Env
Suite Teardown  Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup  Common Test Setup And Start To Capture Logs
Test Teardown  Common Test Teardown And Stop Capture Logs
Force Tags  QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    CRT    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...    team-CN1_SG14    owner-damon.lei    release-5G22R2     CB008247
Resource  ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
${DEBUG_LOG_LEVEL}    0
${AP_UDPLOG_LEVEL}    0
${GNB_BIP_FLAG}    ${True}
${AP_BIP_FLAG}    ${True}
@{PARAMS_IN_SCF}
...    NRBTS/NRDU-1:actInterNumerologyCa=false
...    NRBTS:actCoverageNonCoherentUes=false
...    @{enableCDrx}
...    @{enableBeamforming}
...    @{srsConfig}
...    @{interFreqHoConfig}
...    @{cellconfig}
...    @{adaptrelationerror}

@{enableBeamforming}
...    NRCELL:beamSet:nrBtsBeamRefinementP2=true
...    NRCELL:beamSet:basicBeamSet=beamSet_4
...    NRCELL:numberOfRxBeamforming=4Rx
...    NRCELL:actBeamforming=true
...    NRCELL:mMimoAntArrayMode=Full 64TRX Array (4x8x2)
...    NRCELL:dlMimoMode=4x4 or 4x2 Closed Loop Spatial Multiplexing
...    NRCELL:nrCellType= 8DL4UL
...    NRCELL:beamSet:lowerEdgeAngle=135
...    NRCELL:beamSet:upperEdgeAngle=80

@{srsConfig}
...    NRCELL:dftBeamDiffThresholdH=15
...    NRCELL:dftBeamDiffThresholdV=15
...    NRCELL-1:actUlSrsBm=false    #feature 1086 switch
...    NRCELL-1:actDlSrsBm=true
...    NRCELL-1:srsForBeamMgmt:srsUePeriodicity=slots10
...    NRCELL-1:srsForBeamMgmt:cSRS=10
...    NRCELL-1:srsForBeamMgmt:bSRS=0
#1070 Frame Structure
...    NRCELL-1:tddFrameStructure:frameStructureType=semiStatic
...    delete:NRCELL-1:tddFrameStructure:lteToNrFrameShift
...    NRCELL-1:tddFrameStructure:ulDlDataSlotRatio=3/7
...    NRCELL-1:tddFrameStructure:guardPeriodLength=2Symbols
...    NRCELL-1:prachConfigurationIndex=98
...    NRCELL-2:actUlSrsBm=true
...    NRCELL-2:actDlSrsBm=true
...    NRCELL-2:srsForBeamMgmt:srsUePeriodicity=slots10
...    NRCELL-2:srsForBeamMgmt:cSRS=12
...    NRCELL-2:srsForBeamMgmt:bSRS=3
#1208 Frame Structure
...    NRCELL-2:tddFrameStructure:frameStructureType=semiStatic
...    delete:NRCELL-2:tddFrameStructure:lteToNrFrameShift
...    NRCELL-2:tddFrameStructure:ulDlDataSlotRatio=1/4
...    NRCELL-2:tddFrameStructure:guardPeriodLength=2Symbols
...    NRCELL-2:prachConfigurationIndex=98

@{enableCDrx}
...    NRCELL:actCDrx=true
...    NRCELL:drxProfile1:drxInactivityTimer=20ms
...    NRCELL:drxProfile1:drxLongCycle=40ms
...    NRCELL:drxProfile1:drxOnDurationTimer=4ms
...    NRCELL:drxProfile1:drxRetransTimerDl=16slot
...    NRCELL:drxProfile1:drxRetransTimerUl=16slot

@{interFreqHoConfig}
...  NRBTS:timerXnDataFwdGuard=2000
...  NRBTS:actInterFreqHoSA=true
...  NRBTS:actInterFreqIntraGnbMobilityNSA=true
...  NRPMRNL-1:miNrRelReportCu=5min
...  NRCELL:a2MeashoEnabled=rsrp
...  NRCELL:a2MeashoEnabledSA=rsrp
...  NRCELL:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0
...  NRCELL:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=34
...  NRCELL:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms480
...  NRCELL:a2MeashoSsbRsrp:a2HysteresishoSsbRsrp=0
...  NRCELL:a2MeashoSsbRsrp:a2ThresholdhoSsbRsrp=34
...  NRCELL:a2MeashoSsbRsrp:a2TimeToTriggerhoSsbRsrp=ms480
...  NRCELL:a1MeashoEnabledSA=rsrp
...  NRCELL:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...  NRCELL:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=60
...  NRCELL:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms480
...  NRCELL:a1MeashoEnabled=rsrp
...  NRCELL:a1MeashoSsbRsrp:a1HysteresishoSsbRsrp=0
...  NRCELL:a1MeashoSsbRsrp:a1ThresholdhoSsbRsrp=60
...  NRCELL:a1MeashoSsbRsrp:a1TimeToTriggerhoSsbRsrp=ms480
...  NRCELL-1/NRHOIF-1:cellDepType=SA+NSA
...  NRCELL-1/NRHOIF-1:freqBandIndicatorNR=41
...  NRCELL-1/NRHOIF-1:ifhoSsbScs=30 KHz
...  NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...  NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...  NRCELL-1/NRHOIF-1:numberOfTransmittedSsBlocks=4 beams
...  NRCELL-1/NRHOIF-1:ssBurstSetPeriod=20
...  NRCELL-1/NRHOIF-1:ssbFrequency=508110
...  NRCELL-1/NRHOIF-1:a3MeasEnabled=rsrp
...  NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...  NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=11
...  NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms80
...  NRCELL-2/NRHOIF-1:cellDepType=SA+NSA
...  NRCELL-2/NRHOIF-1:freqBandIndicatorNR=78
...  NRCELL-2/NRHOIF-1:ifhoSsbScs=30 KHz
...  NRCELL-2/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...  NRCELL-2/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...  NRCELL-2/NRHOIF-1:numberOfTransmittedSsBlocks=4 beams
...  NRCELL-2/NRHOIF-1:ssBurstSetPeriod=20
...  NRCELL-2/NRHOIF-1:ssbFrequency=632736
...  NRCELL-2/NRHOIF-1:a3MeasEnabled=rsrp
...  NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...  NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=11
...  NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms64
...  NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...  NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...  NRCELL-1/NRREL-1:gNbId=1
...  NRCELL-1/NRREL-1:gNbIdLength=22
...  NRCELL-1/NRREL-1:handoverAllowedSA=allowed
...  NRCELL-1/NRREL-1:lcrId=2
...  NRCELL-1/NRREL-1:removeNotAllowed=false
...  NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...  NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...  NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...  NRCELL-2/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...  NRCELL-2/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...  NRCELL-2/NRREL-1:gNbId=1
...  NRCELL-2/NRREL-1:gNbIdLength=22
...  NRCELL-2/NRREL-1:handoverAllowedSA=allowed
...  NRCELL-2/NRREL-1:lcrId=1
...  NRCELL-2/NRREL-1:removeNotAllowed=false
...  NRCELL-2/NRREL-1:gnbPlmn:mcc=311
...  NRCELL-2/NRREL-1:gnbPlmn:mnc=489
...  NRCELL-2/NRREL-1:gnbPlmn:mncLength=3

@{cellconfig}
...    NRCELL-1:freqBandIndicatorNR=78
...    NRCELL-1:gscnOrSsPbchArfcn=7840
...    MRBTS-1/NRBTS-1/NRCELL-1:nrarfcn=633000

...    NRCELL-2:freqBandIndicatorNR=41
...    NRCELL-2:gscnOrSsPbchArfcn=6351
...    MRBTS-1/NRBTS-1/NRCELL-2:nrarfcn=508020


@{adaptrelationerror}

...    NRBTS:actFdmEnhancedScheduling=true
...    NRCELL:pucchModeSelect=longPucch
...    NRCELL:srsForBeamMgmt:srsPowerThresholdForDlBm=-120
...    NRCELL:srsForBeamMgmt:srsPowerThresholdForUlBm=-132
...    NRBTS-1/NRCELLGRP-0:numberOfTransmittedSsBlocks=4 beams
...    NRBTS-1/NRCELLGRP-1:numberOfTransmittedSsBlocks=4 beams


...    NRBTS/NRCELL:measGapSelectionSA=favourUeThroughput
...    NRBTS-1/NRSYSINFO_PROFILE-1:systemInformationTargetRate=0
...    MRBTS-1/MNL-1/MNLENT-1/SYNC-1:actEcpriMasterClock=true
...    NRBTS-1/NRPMRNL-1:miNrNgcFlexInterface=disabled
...    NRPMRNL-1:miNrIntraGnbMobilitySaPmqap=disabled
...    NRPMRNL-1:miNrIntraGnbMobilityNsaPmqap=disabled
...    NRPMRNL-1:miNrInterGnbXnMobilitySaPmqap=disabled
...    NRPMRNL-1:miNrInterGnbNgMobilitySaPmqap=disabled
...    NRPMRNL-1:miNrInterGnbMobilityNsaPmqap=disabled
...    NRBTS-1/NRCELL:type0SearchSpaceConfigurationIndex=5


...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-1:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-1:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-2:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-2:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-3:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-3:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-4:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-4:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-6:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-7:direction=TX
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

...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-1:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-1:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-2:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-2:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-3:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-3:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-4:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-4:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-6:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-7:direction=TX
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

${rdSrsCodebookAndTas}    0x590103
${rdPriorSrsForDlBm}    0x590104
@{PARAMS_IN_SWCONFIG}  ${rdSrsCodebookAndTas}=0    ${rdPriorSrsForDlBm}=0
@{PARAMS_IN_SWCONFIG_AP}    0x70690=1
#0x70690: AP enable 1086 and 8247
#rdSrsCodebookAndTas : 0: FALSE[default], 1: TRUE;To control whether 'antennaSwitching' SRS can overlap with codebook SRS or not
#rdPriorSrsForDlBm: 0: TAS[default], 1: codebook;To control which kind of periodic SRS has higher priority for DL SRS based beamforming

#BAND78: t1r4-t2r4 maxNumberSRS-Ports-PerResource=n1 BAND41: t4r4 maxNumberSRS-Ports-PerResource=n4
${ue_nr_cap}  SEPARATOR=
...    E9A09000575F5A13160003C320016093170019C3D09009B20C39F30C7942C0E098040623803DC6C28C0D608C21A0810748
...    2406D6C98AB1A1CF88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE00098000702A8D89BAC11843
...    41020E90480C2D931544439F11C788E3D033EC09F18E7CC31E50B0381C3C17003FF001C00FFC00130000E0012C1C280000
...    00160560E268000010B02006014404D0F4017014099B1CF810236C73E00070218C1E8260078005038280381804A00E000C
...    0480080C07C010040000000200000401E54DE54D0041000009652604000065949001D2AABA55142401200340A000100080
...    10020010040086A87C0004080C10181C282C30344044484C5060646C70747C8494989CA0A4A8B4BD05060B40

*** Test Cases ***
CB008247-ET-A02_A_B1_TAS_t1r4-t2r4_TAS_SRS_80Mhz_A-SRS_assigned_as_Resource unavailable_SA_5GC001070
    [Documentation]
    ...    1. The purpose of this test case is to check following scenarios:
    ...         a.USCB008247-A#B1: Antenna switching SRS configuration for UEs
    ...    2. Test Case Steps:
    ...         a. SA UE1 attach to NR Cell 1.
    ...         b. trigger A2 measurement report via egate command for UE1.
    ...         c. trigger A3 measurement report via egate command for UE1 to HO from cell1 to cell2
    ...         d. trigger A2 measurement report via egate command for UE1.
    ...         e. trigger A3 measurement report via egate command for UE1 to HO from cell2 to cell1
    ...         f. Release SA UE1 call.
    ...    4. Expected Results:
    ...         Step a:  SA UE1 call setup successfully. A-SRS resource is assigned as actUlSrsBm is disabled and
    ...                  no available TAS SRS can be assigned.
    ...         Step b: A2 measurement report should be sent.
    ...         Step c: SA UE1 will HO to Cell 2. 1(2ports) Codebook SRS and 1(4ports) TAS SRS resource assigned
    ...         step d: A2 measurement report should be sent.
    ...         step e: SA UE1 will HO to Cell 1. A-SRS resource is assigned as actUlSrsBm is disabled and no available
    ...                  TAS SRS can be assigned.
    ...         step f: UE call can be released successfully.
	[Tags]    QC_161913    damon.lei
    SA UE attach
	Trigger HO
    Trigger HO    ue_id=1    source_cell_id=51    target_cell_id=50    a2_measid=4    a3_measid=6
    Release ues    ue_type=all
    Check Logs    case=A02

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env        tl_type=tdd_sansa_cmwv/FS/2cells_ecpri    ue_count=1

SA UE attach
    [Arguments]    ${ue_id}=1    ${cell_id}=1
    Execute Egate Command    ue_change_location id=${ue_id} cell=${cell_id} enb=2
	Start RRC Log    SA_UE${ue_id}_cell${cell_id}_attach
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Registered state.
    Execute Egate Command    ue_pdu_session_setup pdu=1 gw=1 ue=${ue_id} nwslice=1    Initial Context Setup Successful
    Get RRC Log

NSA UE attach
    [Arguments]    ${ue_id}=11    ${cell_id}=1    ${target_cells}=1
	Start RRC Log    NSA_UE${ue_id}_cell${cell_id}_attach
    Execute Egate Command    ue_attach id=${ue_id}    UE IS ACTIVE
    Execute Egate Command    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${target_cells} bearer=2 type=split_scg    successful RA
    Get RRC Log

Check Logs
    [Arguments]    ${case}=A02
    Check RRC log    ${CURDIR}${/}a2a_${case}${/}a2a.ini

Modify Cfg
    Update Cfg    ue_param id=1 ue_nr_capabilities=${ue_nr_cap}
    ${gNB2_cell1_configuration}    catenate
    ...    set_cell id=1 gnb=2 pci=16:2 tac=200 nrci=0x01 tdd_cell=on proxy=10.0.2.80:9999|10.0.2.80:8888 nr_arfcn=633000:633000
    ...    gscn=7840 mandatory_for_activation=off
    update Cfg    ${gNB2_cell1_configuration}
    ${gNB2_cell2_configuration}    catenate
    ...    set_cell id=2 gnb=2 pci=17:0 tac=200 nrci=0x02 tdd_cell=on proxy=10.0.2.80:9999|10.0.2.80:8888 nr_arfcn=508020:508020
    ...    gscn=6351 mandatory_for_activation=off
    update Cfg    ${gNB2_cell2_configuration}
    Update Cfg    cell_srs_beam_pos_nr profile_id=1 num_of_ue_positions=4 azimuth=-45,30,25,60
    Update Cfg    cell_testmode_set_nr cell_id=1 gnb=2 testmode=cell_srs_beam_pos profile_id=1 action=activate
    Update Cfg    cell_testmode_set_nr cell_id=2 gnb=2 testmode=cell_srs_beam_pos profile_id=1 action=activate


Trigger HO
    [Arguments]    ${ue_id}=1    ${source_cell_id}=50    ${target_cell_id}=51    ${a2_measid}=1
    ...    ${a3_measid}=3    ${measgap}=False
    Start RRC Log    UE${ue_id}_HO_cell${source_cell_id}_to_cell${target_cell_id}
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${a2_measid} event=A2 srsrp_nr=11 srsrq_nr=11
    ...    message c1 : rrcReconfigurationComplete :
    ${cmd1}=    Set Variable    ue_measurement_send_nr id=${ue_id} meas_id=${a3_measid} event=A3 srsrp_nr=11 srsrq_nr=11
    ${cmd2}=    Set Variable    phycell_id=${target_cell_id} nrsrp_nr=50 nrsrq_nr=50
    ${cmd_HO}=    Catenate    ${cmd1}    ${cmd2}
    Execute Egate Command    ${cmd_HO}    UE1: Intra-eNB handover from
    Get RRC Log
