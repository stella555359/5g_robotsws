*** Settings ***
Suite Setup  Common Suite Setup And Setup Airphone Env
Suite Teardown  Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup  Common Test Setup And Start To Capture Logs
Test Teardown  Common Test Teardown And Stop Capture Logs
Force Tags  QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    CRT    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...    team-CN1_SG14    owner-alex.2.wang    release-5G22R3     CB008247
Resource  ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    NRBTS:rrcReestabTypeSA=sameGNB
...    NRBTS:tWaitingRlRecover=4000ms
...    NRCELL:actDl256Qam=true
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
...    NRCELL:nrCellType=8DL4UL
...    NRCELL:beamSet:lowerEdgeAngle=135
...    NRCELL:beamSet:upperEdgeAngle=80

@{srsConfig}
...    NRCELL:dftBeamDiffThresholdH=15
...    NRCELL:dftBeamDiffThresholdV=15
...    NRCELL-1:actUlSrsBm=true
...    NRCELL-1:actDlSrsBm=true
...    NRCELL-1:srsForBeamMgmt:srsUePeriodicity=slots20
...    NRCELL-1:srsForBeamMgmt:cSRS=8
...    NRCELL-1:srsForBeamMgmt:bSRS=1
#1070 Frame Structure
...    NRCELL-1:tddFrameStructure:frameStructureType=semiStatic
...    NRCELL-1:tddFrameStructure:ulDlDataSlotRatio=3/7
...    NRCELL-1:tddFrameStructure:guardPeriodLength=2Symbols
...    NRCELL-1:tddFrameStructure:tdLteUlDlConfig=tdLteConfig2
...    NRCELL-2:actUlSrsBm=true
...    NRCELL-2:actDlSrsBm=true
...    NRCELL-2:srsForBeamMgmt:srsUePeriodicity=slots5
...    NRCELL-2:srsForBeamMgmt:cSRS=36
...    NRCELL-2:srsForBeamMgmt:bSRS=2
#1208 Frame Structure
...    NRCELL-2:tddFrameStructure:frameStructureType=semiStatic
...    NRCELL-2:tddFrameStructure:ulDlDataSlotRatio=1/4
...    NRCELL-2:tddFrameStructure:guardPeriodLength=2Symbols
...    NRCELL-2:tddFrameStructure:tdLteUlDlConfig=tdLteConfig2

@{enableCDrx}
...    NRCELL:actCDrx=true
...    NRCELL:drxProfile1:drxInactivityTimer=20ms
...    NRCELL:drxProfile1:drxLongCycle=40ms
...    NRCELL:drxProfile1:drxOnDurationTimer=4ms
...    NRCELL:drxProfile1:drxRetransTimerDl=16slot
...    NRCELL:drxProfile1:drxRetransTimerUl=16slot

@{interFreqHoConfig}
...  NRBTS:timerXnDataFwdGuard=250
...  NRBTS:actInterFreqHoSA=true
...  NRPMRNL-1:miNrRelReportCu=5min
...  NRCELL:a2MeashoEnabledSA=rsrp
...  NRCELL:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0
...  NRCELL:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=25
...  NRCELL:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms0
...  NRCELL:a1MeashoEnabledSA=rsrp
...  NRCELL:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...  NRCELL:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=40
...  NRCELL:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms0
...  NRCELL-1/NRHOIF-1:cellDepType=SA+NSA
...  NRCELL-1/NRHOIF-1:freqBandIndicatorNR=41
...  NRCELL-1/NRHOIF-1:ifhoSsbScs=30 KHz
...  NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...  NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...  NRCELL-1/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...  NRCELL-1/NRHOIF-1:ssBurstSetPeriod=20
...  NRCELL-1/NRHOIF-1:ssbFrequency=508110
...  NRCELL-1/NRHOIF-1:a3MeasEnabled=rsrp
...  NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...  NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=30
...  NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms64
...  NRCELL-2/NRHOIF-1:cellDepType=SA+NSA
...  NRCELL-2/NRHOIF-1:freqBandIndicatorNR=78
...  NRCELL-2/NRHOIF-1:ifhoSsbScs=30 KHz
...  NRCELL-2/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...  NRCELL-2/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...  NRCELL-2/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...  NRCELL-2/NRHOIF-1:ssBurstSetPeriod=20
...  NRCELL-2/NRHOIF-1:ssbFrequency=636576
...  NRCELL-2/NRHOIF-1:a3MeasEnabled=rsrp
...  NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...  NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=30
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
${rdMaxSrsResPerSym1208}    0x5900FD
@{PARAMS_IN_SWCONFIG}  ${rdSrsCodebookAndTas}=1    ${rdPriorSrsForDlBm}=0    ${rdMaxSrsResPerSym1208}=4
@{PARAMS_IN_SWCONFIG_AP}    0x70690=1
#0x70690: AP enable 1086 and 8247
#rdSrsCodebookAndTas : 0: FALSE[default], 1: TRUE;To control whether 'antennaSwitching' SRS can overlap with codebook SRS or not
#rdPriorSrsForDlBm: 0: TAS[default], 1: codebook;To control which kind of periodic SRS has higher priority for DL SRS based beamforming
#rdMaxSrsResPerSym1208 frameStructureType 1208 max srs resoure, it impact srs alloaction,rule is attach first then dealloaction

#BAND78:  no supported SRS-TxPortSwitch configured, maxNumberSRS-Ports-PerResource=n2 BAND41:  t2r2 maxNumberSRS-Ports-PerResource=n2
${ue_nr_cap_SA_UE1}  SEPARATOR=
...    6180000004608580300002300000A000009A0000410200385000000000E268000010F000B01009404E1E02400503828030
...    1004800C03C00000000000068A845022901380208000000900820000002402018150140148138020010020040020040100

*** Test Cases ***
CB008247-ET-A03_A_B1_TAS_t1r2_reuse_UE_codebook_80Mhz_Intra_GNB_HO_target_cell_100Mhz_resource_release_with_Target_Cell_UE_Incapable_of_TAS
    [Documentation]
    ...    1. The purpose of this test case is to check following scenarios:
    ...         a.USCB008247-A#B1: Antenna switching SRS configuration for UEs
    ...    2. Test Case Steps:
    ...         a. SA UE1 attach to NR cell2.
    ...         b. trigger UE1 re-establish on cell2.
    ...         c. trigger A2 measurement report via egate command for UE1.
    ...         d. trigger A3 measurement report via egate command for UE1 to HO from cell2 to cell1
    ...         e. trigger A2 measurement report via egate command for UE1.
	...         f. trigger A3 measurement report via egate command for UE1 to HO back from cell2 to cell1 
    ...         g. Release SA UE2 call.
    ...    4. Expected Results:
    ...         Step a:  SA UE1 call setup successfully. 1(2ports) Codebook SRS and 1 (2ports) TAS SRS resource assigned,
    ...                  TAS SRS is reusing codebook resource.
    ...         Step b:  RRC reestablish success, UE1 in RRC connected state.1(2ports) Codebook SRS and 1 (2ports) TAS SRS resource assigned,
	...                  TAS SRS is reusing codebook resource.
    ...         Step c:  A2 measurement report should be sent.
    ...         step d:  SA UE1 should handover from cell2 to cell1 successfully. 1(2ports) Codebook SRS resource assigned,
    ...                	 TAS SRS resource released.
    ...         step e:  A2 measurement report should be sent.
	...         step f:  SA UE1 should handover back from cell1 to cell2 successfully.  1(2port) Codebook SRS and 1 (2port) TAS SRS resource assigned,
	...                  TAS SRS is reusing codebook resource.
    ...         step g: UE1 call can be released successfully.
	[Tags]    QC_161911    alex.2.wang
    SA UE attach    cell_id=2
	UE re-establish    cell_id=2
	Trigger HO    source_cell_id=51    target_cell_id=50
	Trigger HO    source_cell_id=50    target_cell_id=51    a2_measid=4    a3_measid=6
	Release ues    ue_type=all
    Check Logs    case=A03

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri    ue_count=1

Modify Cfg
    Update Cfg    ue_param id=1 ue_nr_capabilities=${ue_nr_cap_SA_UE1}
    ${gNB2_cell2_configuration}    catenate
    ...    set_cell id=2 gnb=2 pci=17:0 tac=200 nrci=0x02 tdd_cell=on proxy=10.0.2.80:9999|10.0.2.80:8888 nr_arfcn=508020:508020
    ...    gscn=6351 mandatory_for_activation=off
    update Cfg    ${gNB2_cell2_configuration}
    Update Cfg    cell_srs_beam_pos_nr profile_id=1 num_of_ue_positions=4 azimuth=-45,30,25,60
    Update Cfg    cell_testmode_set_nr cell_id=1 gnb=2 testmode=cell_srs_beam_pos profile_id=1 action=activate
    Update Cfg    cell_testmode_set_nr cell_id=2 gnb=2 testmode=cell_srs_beam_pos profile_id=1 action=activate

SA UE attach
    [Arguments]    ${ue_id}=1    ${cell_id}=1
    Execute Egate Command    ue_change_location id=${ue_id} cell=${cell_id} enb=2
	Start RRC Log    SA_UE${ue_id}_cell${cell_id}_attach
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Registered
    Execute Egate Command    ue_pdu_session_setup pdu=1 gw=${ue_id} ue=${ue_id} nwslice=1    Initial Context Setup Successful
    Get RRC Log

UE re-establish
   [Arguments]    ${ue_id}=1    ${cell_id}=1
   Start RRC Log    SA_UE${ue_id}_cell${cell_id}_reestablish
   Execute Egate Command    ue_rrc_reestablish id=${ue_id} gnb=2 cell=${cell_id} cause=reconfigurationFailure    rrcReestablishmentComplete
   Get RRC Log

Trigger HO
    [Arguments]    ${ue_id}=1    ${source_cell_id}=50    ${target_cell_id}=51    ${a2_measid}=1
    ...    ${a3_measid}=3    ${measgap}=False
    Start RRC Log    UE${ue_id}_HO_cell${source_cell_id}_to_cell${target_cell_id}
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${a2_measid} event=A2 srsrp_nr=11    
    ...    message c1 : rrcReconfigurationComplete :
    ${cmd1}=    Set Variable    ue_measurement_send_nr id=${ue_id} meas_id=${a3_measid} event=A3 srsrp_nr=11 srsrq_nr=11
    ${cmd2}=    Set Variable    phycell_id=${target_cell_id} nrsrp_nr=50 nrsrq_nr=50
    ${cmd_HO}=    Catenate    ${cmd1}    ${cmd2}
    Execute Egate Command    ${cmd_HO}    UE1: Intra-eNB handover from
    Get RRC Log   

Check Logs
    [Arguments]    ${case}=A01
    Check RRC log    ${CURDIR}${/}a2a_${case}${/}a2a.ini


