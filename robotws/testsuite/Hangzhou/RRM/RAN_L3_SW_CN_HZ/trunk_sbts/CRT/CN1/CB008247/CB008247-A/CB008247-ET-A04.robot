*** Settings ***
Suite Setup  Common Suite Setup And Setup Airphone Env
Suite Teardown  Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup  Common Test Setup And Start To Capture Logs
Test Teardown  Common Test Teardown And Stop Capture Logs
Force Tags  QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    CRT    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...    team-CN1_SG14    owner-damon.lei    release-5G22R3     CB008247
Resource  ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    NRCELL:actDl256Qam=true
...    NRBTS/NRDU-1:actInterNumerologyCa=false
...    NRBTS:actCoverageNonCoherentUes=true
...    @{enableCDrx}
...    @{enableBeamforming}
...    @{srsConfig}
...    @{interFreqHoConfig}

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
...    NRCELL-1:actUlSrsBm=true
...    NRCELL-1:actDlSrsBm=true
...    NRCELL-1:srsForBeamMgmt:srsUePeriodicity=slots80
...    NRCELL-1:srsForBeamMgmt:cSRS=8
...    NRCELL-1:srsForBeamMgmt:bSRS=2
#1116 Frame Structure
...    NRCELL-1:tddFrameStructure:frameStructureType=tdLte
...    NRCELL-1:tddFrameStructure:lteToNrFrameShift=3ms
...    NRCELL-1:tddFrameStructure:ulDlDataSlotRatio=3/7
...    NRCELL-1:tddFrameStructure:guardPeriodLength=4Symbols
...    NRCELL-1:tddFrameStructure:tdLteUlDlConfig=tdLteConfig2    
...    NRCELL-1:prachConfigurationIndex=98
...    NRCELL-2:actUlSrsBm=true
...    NRCELL-2:actDlSrsBm=true
...    NRCELL-2:srsForBeamMgmt:srsUePeriodicity=slots10
...    NRCELL-2:srsForBeamMgmt:cSRS=15
...    NRCELL-2:srsForBeamMgmt:bSRS=1
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
...  NRCELL-2/NRHOIF-1:ssbFrequency=636576
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

...    NRCELL-2:freqBandIndicatorNR=41
...    NRCELL-2:gscnOrSsPbchArfcn=6351
...    NRCELL-2:nrarfcn=508020
...    NRCELL-2:chBw=80MHz


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
@{PARAMS_IN_SWCONFIG}  ${rdSrsCodebookAndTas}=1    ${rdPriorSrsForDlBm}=0
@{PARAMS_IN_SWCONFIG_AP}    0x70690=1
#70690: AP enable 1086 and 8247
#rdSrsCodebookAndTas : 0: FALSE[default], 1: TRUE;To control whether 'antennaSwitching' SRS can overlap with codebook SRS or not
#rdPriorSrsForDlBm: 0: TAS[default], 1: codebook;To control which kind of periodic SRS has higher priority for DL SRS based beamforming

#BAND78: t1r4-t2r4 maxNumberSRS-Ports-PerResource=n1 BAND41: t4r4 maxNumberSRS-Ports-PerResource=n4
${ue_nr_cap_SA_UE1}  SEPARATOR=
...    6180000004608580300002300000A000009A0000410200385000000000E268000010F000B0100980461E02400503828030
...    1004800C03C00000000000068A845022901380208000000901020000202400018152154014813802001002004002004010

#BAND78: no supportedSRS-TxPortSwitch configured, maxNumberSRS-Ports-PerResource=n2 BAND41: t2r2 maxNumberSRS-Ports-PerResource=n2
${ue_nr_cap_SA_UE2}  SEPARATOR=
...    6180000004608580300002300000A000009A0000410200385000000000E268000010F000B01009404E1E02400503828030
...    1004800C03C00000000000068A845022901380208000000900820000002402018150140148138020010020040020040100

#BAND78: t1r1 maxNumberSRS-Ports-PerResource=n1 BAND41: t1r1 maxNumberSRS-Ports-PerResource=n1
${ue11_MRDC_cap}    SEPARATOR=
...    A11FF83BC4C0C03850001C46000000162205E260601C4D000E230000000B1102F130300E26800710400000058881789818070A0003882000
...    0002C040BC4C0C03882001C46000002160205E360601C46000E208007104000010580817898180713400385000000C2C040804808D00A001
...    C041809A26002E41E24E9113639F0E24E9113639F0E24E8913639F0E24E8913639F0E24E8912639F469D1224498E7D127489131CF8300A20
...    00080404008030100C01840001008080100402018030C0002010100C01804030060100C0184000100808010040200401040002010100C018
...    20001008080600C0

#BAND78: t1r4 maxNumberSRS-Ports-PerResource=n1 BAND41: t2r2 maxNumberSRS-Ports-PerResource=n1
${ue12_MRDC_cap}    SEPARATOR=
...    A11FF83BC4C0C03850001C46000000162205E260601C4D000E230000000B1102F130300E26800710400000058881789818070A0003882000
...    0002C040BC4C0C03882001C46000002160205E360601C46000E208007104000010580817898180713400385000000C2C040804808D00A001
...    C041809A26002E41E24E9513639F0E24E8513639F0E24E8913639F0E24E8913639F0E24E8912639F469D1224498E7D127448931CF8300A20
...    00080404008020100C01840001008080100402018030C0002010100C01804030060100C0184000100808010040200401040002010100C018
...    20001008080600C0

${ue_nr_full_cap}  SEPARATOR=
...    E9A09000575F5A13160003C320016093170019C3D09009B20C39F30C7942C0E098040623807DC6C28C0D608C21A08107482406D6C98AB1A1
...    CF88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE00098000702A0D883AC1184341020F10480CAD931562439F604F
...    88E3C62471E439F51CF9863CA1607038784FEC000003FB000000260001C0AA3626EB04610D04083A412030B64C55110E7C471E238F40CFB0
...    27C639F30C7942C0E070F05C00FFC007003FF0004C0003815C7C46D608C21A08107CA090155B262AC2873E238F1800000000000000000000
...    00004FFF800003FFE00000260001C00F78789A001C4100000216020541E14000711800000858158788C001C41000006160561E1400071040
...    0000858158789A001C46000002160562E2300071040038820000142C0AC3C28000E268000060B02B17134003882001C28000008160562E26
...    800711800388C0000082C0AC5C28000E20800711800001058158B850001C41000E208000020B02B17134003882001C46000004160562E140
...    00711800388C0000082C0AC5C4D000E2300070A000002058158788C001C46000006160401C0468051013602087A05D83E14489B1CF870A24
...    4D8E7C3851226C73E1C28913639F0E14489B1CF871224489B1CF870A040D8E7C08902040D8E7C08902040D8E7C08902040D8E7C08902040D
...    8E7C08902040D8E7C08902040D8E7C08902040D8E7C0850206C73E000B878C6318C6318C6318C630F413003C00281C1401C0C02500700060
...    240040603E09002000000010000020080000000400000802000008010000060080000400400002802001004010040000300200001C010008
...    000000200002001000012008000030040000500200002C01000812048020000300CE54D654D60A5606560CD60AD652D64CD602D606D60256
...    04560ED0341000009652504000065949010000296524040000E594901000049652404000165949010000696524040001E594901000089652
...    404000265949010000A96524040002E5949410000C96524040000C594900CD2AABA55154AA2E95455058AA0B1541A2A94C55268AA031540A
...    2A93555078A1202F012A05028140A05028140A05028140A05028140A0502800304040300601002004202004010080600C201002004040300
...    60100C018202018030080600C201002004040300601002004402018030080600C0201803040400802010020086A87C0004080C10181C282C
...    30344044484C5060646C70747C8494989CA0A4A8B4BD05060B40

${cfg_setue12}    set_ue simulated id=12 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00
...    nia=zuc nea=zuc imsi=311:489:21645501

*** Test Cases ***
CB008247-ET-A04_A_B1_TAS_t2r2_not_reuse_UE_codebook_100Mhz_Intra_GNB_HO_target_cell_80Mhz_TAS_SRS_add_as_UE_capability_changed_NSA_5GC001116_3ms
    [Documentation]
    ...    1. The purpose of this test case is to check following scenarios:
    ...         a.USCB008247-A#B1: Antenna switching SRS configuration for UEs
    ...    2. Test Case Steps:
    ...         a. NSA UE12 attach to NR Cell 2.
    ...         b. trigger A2 measurement report via egate command for UE12.
    ...         c. Triger A3 measurement report via egate command for UE12 to HO from cell2 to cell1.
    ...         d. trigger A2 measurement report via egate command for UE12.
    ...         e. Triger A3 measurement report via egate command for UE12 to HO from cell1 to cell3.
    ...         f. Release NSA UE12 call.
    ...    4. Expected Results:
    ...         Step a: NSA UE12 call setup successfully. 1(1port) Codebook SRS and 1 (1port1) TAS SRS resource assigned,
    ...              	TAS SRS is not reusing codebook SRS resource as actCoverageNonCoherentUes is enabled.
    ...         Step b: A2 measurement report should be sent.
    ...         Step c: NSA UE12 should handover from cell2 to cell1 successfully. 1(1port) Codebook SRS and 4 (1port) TAS
    ...                 SRS resource assigned, TAS SRS is not reusing codebook SRS resource as actCoverageNonCoherentUes is enabled.
    ...         step d: A2 measurement report should be sent.
    ...         step e: NSA UE12 should handover from cell1 to cell2 successfully.  1(1port) Codebook SRS and 1 (1port) TAS
    ...             	SRS resource assigned, TAS SRS is not reusing codebook SRS resource as actCoverageNonCoherentUes is enabled.
    ...         step f: UE call should be released successfully.
	[Tags]    QC_161912   damon.lei
    NSA UE attach    ue_id=12    cell_id=2    target_cells=2
    Trigger HO    ue_id=12    source_cell_id=51    target_cell_id=50    a2_measid=1    a3_measid=3    measgap=True
    Trigger HO    ue_id=12    source_cell_id=50    target_cell_id=51    a2_measid=1    a3_measid=3    measgap=True
	Check Logs    case=A04
    Release ues    ue_type=all

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri    ue_count=2

SA UE attach
    [Arguments]    ${ue_id}=1    ${cell_id}=1    ${pdu_id}=1
    Execute Egate Command    ue_change_location id=${ue_id} cell=${cell_id} enb=2
	Start RRC Log    SA_UE${ue_id}_cell${cell_id}_attach
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Registered state.
    Execute Egate Command    ue_pdu_session_setup pdu=${pdu_id} gw=${pdu_id} ue=${ue_id} nwslice=1    Initial Context Setup Successful
    Get RRC Log

NSA UE attach
    [Arguments]    ${ue_id}=11    ${cell_id}=1    ${target_cells}=1
	Start RRC Log    NSA_UE${ue_id}_cell${cell_id}_attach
    Execute Egate Command    ue_attach id=${ue_id}    UE IS ACTIVE
    Execute Egate Command    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${target_cells} bearer=2 type=split_scg    successful RA
    Get RRC Log

Check Logs
    [Arguments]    ${case}=A01
    Check RRC log    ${CURDIR}${/}a2a_${case}${/}a2a.ini

Modify Cfg
    Update Cfg    ${cfg_setue12}
	Update Cfg    ue_param id=1 ue_nr_capabilities=${ue_nr_cap_SA_UE1}
	Update Cfg    ue_param id=2 ue_nr_capabilities=${ue_nr_cap_SA_UE2}
    Update Cfg    ue_param id=11 ue_nr_capabilities=${ue_nr_full_cap} dual_conn=eutra_nr ue_eutra_nr_capabilities=${ue11_MRDC_cap}
	Update Cfg    ue_param id=12 ue_nr_capabilities=${ue_nr_full_cap} dual_conn=eutra_nr ue_eutra_nr_capabilities=${ue12_MRDC_cap}
	Update Cfg    set_pdu_gateway id=2 ue_nat_ip=72.23.0.2 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
	Update Cfg    set_pdu_gateway id=3 ue_nat_ip=72.23.0.3 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=12 ue_nat_ip=72.23.0.12 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1	
    Update Cfg    set_bearer id=2 ue=12 qci=9 pdn=1 ip=4.7.254.212 default=on ul_nat_gw=10.0.2.1 dl_nat_gw=10.0.2.1 trf_type=internal
    Update Cfg    cell_srs_beam_pos_nr profile_id=1 num_of_ue_positions=4 azimuth=-45,30,25,60
    Update Cfg    cell_testmode_set_nr cell_id=1 gnb=2 testmode=cell_srs_beam_pos profile_id=1 action=activate
    Update Cfg    cell_testmode_set_nr cell_id=2 gnb=2 testmode=cell_srs_beam_pos profile_id=1 action=activate

Trigger HO
    [Arguments]    ${ue_id}=1    ${source_cell_id}=50    ${target_cell_id}=51    ${a2_measid}=3
    ...    ${a3_measid}=5    ${measgap}=False
    Start RRC Log    UE${ue_id}_HO_cell${source_cell_id}_to_cell${target_cell_id}
    ${cmd}=    Set Variable    ue_enb_param id=${ue_id} measurement_gap=gp0:0 mgta=ms0 gap_purpose=perUE gap_trigger=gnb_triggered
    Run Keyword if     ${measgap}==True    Execute Egate Command    ${cmd}
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${a2_measid} event=A2 srsrp_nr=11 srsrq_nr=11
    ...    Successfully reconfigured dual connectivity
    ${cmd1}=    Set Variable    ue_measurement_send_nr id=${ue_id} meas_id=${a3_measid} event=A3 srsrp_nr=11 srsrq_nr=11
    ${cmd2}=    Set Variable    phycell_id=${target_cell_id} nrsrp_nr=50 nrsrq_nr=50
    ${cmd_HO}=    Catenate    ${cmd1}    ${cmd2}
    Execute Egate Command    ${cmd_HO}    Successfully reconfigured dual connectivity
    Get RRC Log
