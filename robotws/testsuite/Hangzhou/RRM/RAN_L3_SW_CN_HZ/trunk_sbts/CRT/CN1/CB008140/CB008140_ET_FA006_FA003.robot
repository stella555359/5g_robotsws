*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    CRT    CLOUD_5G_I_[LO][LO]_AP_[LOO]_SANSA_FS_ECPRI_CMWV_TDD
...    owner-jun.3.ye    release-SBTS23R3    team-L3CN1_SG14
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${NOKIA_XNAP_PLUGIN_FLAG}    ${True}
${NOKIA_F1AP_PLUGIN_FLAG}    ${True}

@{LOLO_Golden_Changes_GNB1}
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1

@{LOLO_Golden_Changes_GNB2}
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1


@{PARAMS_IN_SCF}
...    @{PARAMS_FOR_CA}
...    @{PARAMS_FOR_GNB1}
...    @{PARAMS_ADJ_REL_FOR_GNB1}
...    @{PARAMS_FOR_OTHERS}
...    @{LOLO_Golden_Changes_GNB1}

@{PARAMS_IN_SCF_GNB2}
...    @{PARAMS_FOR_CA}
...    @{PARAMS_FOR_GNB2}
...    @{PARAMS_ADJ_REL_FOR_GNB2}
...    @{PARAMS_FOR_OTHERS}
...    @{LOLO_Golden_Changes_GNB2}

@{PARAMS_FOR_CA}
...    NRBTS:actCarrierAggregation=true
...    NRBTS:sCellActivationMethod=blind
...    NRCELL:sCellDeactivationTimerGNB=infinity
...    NRBTS:caConfigurationSupport=4CCDL_2CCUL
...    NRBTS:weightForIgnbCaSelection=60
...    NRBTS:actIncXn=true
...    NRBTS:maxNumScellsDl=3
...    NRBTS:maxNumScellsUl=3
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:carrierAggregationSupportList=ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Any_Sa,ca_Fdd_Any_Sa,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Fdd
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRDU-1:actInterGnbCa=DLOnly
...    NRDU-1:dlToUlContributionRatio=101
...    NRDU-1:xgUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRCELL:actK1Opt=intraAndInter-gNB
...    NRCELL:maxNumScellsDlFr1=3

@{PARAMS_FOR_GNB1}
...    NRCELL-1:nrCellType=4DL2UL
...    NRCELL-2:nrCellType=4DL2UL
...    NRCELL:actBeamforming=true
...    NRCELL-1:beamSet:nrBtsBeamRefinementP2=true
...    NRCELL-1:beamSet:basicBeamSet=beamSet_6
...    NRCELLGRP-0:numberOfTransmittedSsBlocks=6 beams
...    NRCELL-2:beamSet:nrBtsBeamRefinementP2=true
...    NRCELL-2:beamSet:basicBeamSet=beamSet_6
...    NRCELLGRP-1:numberOfTransmittedSsBlocks=6 beams
...    NRCELL-1:msg1FrequencyStart=0
...    NRCELL-2:msg1FrequencyStart=0
...    NRCELL-1:type0CoresetConfigurationIndex=12
...    NRCELL-2:type0CoresetConfigurationIndex=12
...    NRCELL-1:type0SearchSpaceConfigurationIndex=5
...    NRCELL-2:type0SearchSpaceConfigurationIndex=5
...    NRCELL-1:prachConfigurationIndex=97
...    NRCELL-2:prachConfigurationIndex=97
...    NRCELL-1:zeroCorrelationZoneConfig=13
...    NRCELL-2:zeroCorrelationZoneConfig=13
...    NRCELL-1:numOfPagingFrames=quaterT
...    NRCELL-2:numOfPagingFrames=quaterT
...    NRCELL-1:tddFrameStructure:frameStructureType=tdLte
...    NRCELL-1:tddFrameStructure:lteToNrFrameShift=0ms
...    NRCELL-1:tddFrameStructure:ulDlDataSlotRatio=2/8
...    NRCELL-1:tddFrameStructure:guardPeriodLength=6Symbols
...    NRCELL-1:tddFrameStructure:tdLteUlDlConfig=tdLteConfig2
...    NRCELL-2:tddFrameStructure:frameStructureType=tdLte
...    NRCELL-2:tddFrameStructure:lteToNrFrameShift=0ms
...    NRCELL-2:tddFrameStructure:ulDlDataSlotRatio=2/8
...    NRCELL-2:tddFrameStructure:guardPeriodLength=6Symbols
...    NRCELL-2:tddFrameStructure:tdLteUlDlConfig=tdLteConfig2

@{PARAMS_ADJ_REL_FOR_GNB1}
...    NRBTS:iGnbCaXnCfUpBackOffTmr=60
...    NRBTS:iGnbCaXnSetupReqTmr=60
...    NRBTS:iGnbCaXnSetupRespTmr=60
...    NRBTS:intGnbScellTempBlockTmr=60
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRCELL-1:a1MeasSCellAddEnabled=rsrq
...    NRCELL-1:a1MeasSCellAddSsbRsrq:a1HysteresisSCellAddSsbRsrq=0
...    NRCELL-1:a1MeasSCellAddSsbRsrq:a1ThresholdSCellAddSsbRsrq=30
...    NRCELL-1:a1MeasSCellAddSsbRsrq:a1TimeToTriggerSCellAddSsbRsrq=320ms
...    NRBTS/NRADJGNB-2:administrativeState=Unlocked
...    NRBTS/NRADJGNB-2:gNbIdLength=22
...    NRBTS/NRADJGNB-2:gNodeBId=2
...    NRBTS/NRADJGNB-2:weightForIgnbCaSelection=50
...    NRBTS/NRADJGNB-2:xnLinkRef=1
...    NRBTS/NRADJGNB-2:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-2:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-2:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-3:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-3:fiveGsTac=200
...    NRBTS/NRADJNRCELL-3:freqBandIndicatorNR=77
...    NRBTS/NRADJNRCELL-3:gNbId=2
...    NRBTS/NRADJNRCELL-3:gNbIdLength=22
...    NRBTS/NRADJNRCELL-3:lcrId=3
...    NRBTS/NRADJNRCELL-3:nrarfcn=653400
...    NRBTS/NRADJNRCELL-3:physCellId=52
...    NRBTS/NRADJNRCELL-3:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-3:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-3:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-4:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-4:fiveGsTac=200
...    NRBTS/NRADJNRCELL-4:freqBandIndicatorNR=77
...    NRBTS/NRADJNRCELL-4:gNbId=2
...    NRBTS/NRADJNRCELL-4:gNbIdLength=22
...    NRBTS/NRADJNRCELL-4:lcrId=4
...    NRBTS/NRADJNRCELL-4:nrarfcn=648000
...    NRBTS/NRADJNRCELL-4:physCellId=53
...    NRBTS/NRADJNRCELL-4:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-4:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-4:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-11:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-11:fiveGsTac=200
...    NRBTS/NRADJNRCELL-11:freqBandIndicatorNR=3
...    NRBTS/NRADJNRCELL-11:gNbId=2
...    NRBTS/NRADJNRCELL-11:gNbIdLength=22
...    NRBTS/NRADJNRCELL-11:lcrId=11
...    NRBTS/NRADJNRCELL-11:nrarfcn=368400
...    NRBTS/NRADJNRCELL-11:physCellId=60
...    NRBTS/NRADJNRCELL-11:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-11:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-11:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-12:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-12:fiveGsTac=200
...    NRBTS/NRADJNRCELL-12:freqBandIndicatorNR=28
...    NRBTS/NRADJNRCELL-12:gNbId=2
...    NRBTS/NRADJNRCELL-12:gNbIdLength=22
...    NRBTS/NRADJNRCELL-12:lcrId=12
...    NRBTS/NRADJNRCELL-12:nrarfcn=153400
...    NRBTS/NRADJNRCELL-12:physCellId=61
...    NRBTS/NRADJNRCELL-12:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-12:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-12:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-1:gNbId=2
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-1:lcrId=3
...    NRCELL-1/NRREL-1:removeNotAllowed=false
...    NRCELL-1/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-2:gNbId=2
...    NRCELL-1/NRREL-2:gNbIdLength=22
...    NRCELL-1/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-2:lcrId=4
...    NRCELL-1/NRREL-2:removeNotAllowed=false
...    NRCELL-1/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-3:gNbId=2
...    NRCELL-1/NRREL-3:gNbIdLength=22
...    NRCELL-1/NRREL-3:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-3:lcrId=11
...    NRCELL-1/NRREL-3:removeNotAllowed=false
...    NRCELL-1/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-4:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-4:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-4:gNbId=2
...    NRCELL-1/NRREL-4:gNbIdLength=22
...    NRCELL-1/NRREL-4:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-4:lcrId=12
...    NRCELL-1/NRREL-4:removeNotAllowed=false
...    NRCELL-1/NRREL-4:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-4:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-4:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-4:gnbPlmn:mncLength=3
@{PARAMS_FOR_GNB2}
...    NRBTS:iGnbCaXnCfUpBackOffTmr=60
...    NRBTS:iGnbCaXnSetupReqTmr=90
...    NRBTS:iGnbCaXnSetupRespTmr=60
...    NRBTS:intGnbScellTempBlockTmr=60
...    NRCELL-3:sCellDeactivationTimerGNB=infinity
...    NRCELL-4:sCellDeactivationTimerGNB=infinity
...    NRCELL-11:sCellDeactivationTimerGNB=infinity
...    NRCELL-12:sCellDeactivationTimerGNB=infinity
...    NRCELL-3:weightForSCellSelection=10
...    NRCELL-4:weightForSCellSelection=10
...    NRCELL-11:weightForSCellSelection=10
...    NRCELL-12:weightForSCellSelection=10
...    NRCELL-3:nrCellType=4DL2UL
...    NRCELL-4:nrCellType=4DL2UL
...    NRCELL-11:nrCellType=2DL2UL
...    NRCELL-12:nrCellType=2DL2UL
...    NRCELL-3:chBw=100MHz
...    NRCELL-4:chBw=40MHz
...    NRCELL-11:chBw=20MHz
...    NRCELL-12:chBw=20MHz
...    NRCELL-3:actBeamforming=true
...    NRCELL-4:actBeamforming=true
...    NRCELL-3:maxNumOfUsersPerNRCell=1
...    NRCELL-4:maxNumOfUsersPerNRCell=1
...    NRCELL-3:maxNumOfCaUsersNRCell=1
...    NRCELL-4:maxNumOfCaUsersNRCell=1
...    NRCELL-3:maxNumOfSCellAlloc=1
...    NRCELL-4:maxNumOfSCellAlloc=1
...    NRCELL-3:maxNumOfUsersPerCell=1
...    NRCELL-4:maxNumOfUsersPerCell=1
...    NRCELL-3:maxNumOfRrcSA=1
...    NRCELL-4:maxNumOfRrcSA=1
...    NRCELL-3:maxNumOfNrDcSnUsers=1
...    NRCELL-4:maxNumOfNrDcSnUsers=1
...    NRPMRNL-1:miNrInterGnbMobilityNsaPmqap=disabled
...    NRPMRNL-1:miNrInterGnbNgMobilitySaPmqap=disabled
...    NRPMRNL-1:miNrInterGnbXnMobilitySaPmqap=disabled
...    NRPMRNL-1:miNrIntraGnbMobilityNsaPmqap=disabled
...    NRPMRNL-1:miNrIntraGnbMobilitySaPmqap=disabled
...    NRPMRNL-1:miNrRelReportCu=disabled
...    NRPMRNL-1:miNrNgcFlexInterface=disabled
...    NRCELL-3:beamSet:nrBtsBeamRefinementP2=true
...    NRCELL-3:beamSet:basicBeamSet=beamSet_6
...    NRCELLGRP-0:numberOfTransmittedSsBlocks=6 beams
...    NRCELL-4:beamSet:nrBtsBeamRefinementP2=true
...    NRCELL-4:beamSet:basicBeamSet=beamSet_6
...    NRCELLGRP-1:numberOfTransmittedSsBlocks=6 beams
...    NRCELL-3:msg1FrequencyStart=0
...    NRCELL-4:msg1FrequencyStart=0
...    NRCELL-3:type0CoresetConfigurationIndex=12
...    NRCELL-4:type0CoresetConfigurationIndex=12
...    NRCELL-3:type0SearchSpaceConfigurationIndex=5
...    NRCELL-4:type0SearchSpaceConfigurationIndex=5
...    NRCELL-3:prachConfigurationIndex=97
...    NRCELL-4:prachConfigurationIndex=97
...    NRCELL-3:zeroCorrelationZoneConfig=13
...    NRCELL-4:zeroCorrelationZoneConfig=13
...    NRCELL-3:numOfPagingFrames=quaterT
...    NRCELL-4:numOfPagingFrames=quaterT
...    NRCELL-3:tddFrameStructure:frameStructureType=tdLte
...    NRCELL-3:tddFrameStructure:lteToNrFrameShift=0ms
...    NRCELL-3:tddFrameStructure:ulDlDataSlotRatio=2/8
...    NRCELL-3:tddFrameStructure:guardPeriodLength=6Symbols
...    NRCELL-3:tddFrameStructure:tdLteUlDlConfig=tdLteConfig2
...    NRCELL-4:tddFrameStructure:frameStructureType=tdLte
...    NRCELL-4:tddFrameStructure:lteToNrFrameShift=0ms
...    NRCELL-4:tddFrameStructure:ulDlDataSlotRatio=2/8
...    NRCELL-4:tddFrameStructure:guardPeriodLength=6Symbols
...    NRCELL-4:tddFrameStructure:tdLteUlDlConfig=tdLteConfig2

@{PARAMS_ADJ_REL_FOR_GNB2}
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS/NRADJGNB-1:administrativeState=Unlocked
...    NRBTS/NRADJGNB-1:gNbIdLength=22
...    NRBTS/NRADJGNB-1:gNodeBId=1
...    NRBTS/NRADJGNB-1:weightForIgnbCaSelection=50
...    NRBTS/NRADJGNB-1:xnLinkRef=1
...    NRBTS/NRADJGNB-1:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-1:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-1:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-1:fiveGsTac=200
...    NRBTS/NRADJNRCELL-1:freqBandIndicatorNR=77
...    NRBTS/NRADJNRCELL-1:gNbId=1
...    NRBTS/NRADJNRCELL-1:gNbIdLength=22
...    NRBTS/NRADJNRCELL-1:lcrId=1
...    NRBTS/NRADJNRCELL-1:nrarfcn=663400
...    NRBTS/NRADJNRCELL-1:physCellId=50
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-2:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-2:fiveGsTac=200
...    NRBTS/NRADJNRCELL-2:freqBandIndicatorNR=77
...    NRBTS/NRADJNRCELL-2:gNbId=1
...    NRBTS/NRADJNRCELL-2:gNbIdLength=22
...    NRBTS/NRADJNRCELL-2:lcrId=2
...    NRBTS/NRADJNRCELL-2:nrarfcn=658000
...    NRBTS/NRADJNRCELL-2:physCellId=51
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mncLength=3
...    NRCELL-3:a2MeasSCellRelEnabled=rsrp
...    NRCELL-3:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-3:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=35|a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-3:a2MeasSCellRelSsbRsrq:a2HysteresisSCellRelSsbRsrq=0|a2TimeToTriggerSCellRelSsbRsrq=0ms
...    NRCELL-3:a2MeasSCellRelSsbRsrq:a2ThresholdSCellRelSsbRsrq=10|a2TimeToTriggerSCellRelSsbRsrq=0ms
...    NRCELL-4:a2MeasSCellRelEnabled=rsrp
...    NRCELL-4:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-4:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=35|a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-4:a2MeasSCellRelSsbRsrq:a2HysteresisSCellRelSsbRsrq=0|a2TimeToTriggerSCellRelSsbRsrq=0ms
...    NRCELL-4:a2MeasSCellRelSsbRsrq:a2ThresholdSCellRelSsbRsrq=10|a2TimeToTriggerSCellRelSsbRsrq=0ms

@{PARAMS_FOR_OTHERS}


...    NRBTS:actRanSharing=false
...    NRCELL:actCDrx=false
...    NRBTS:actFdmEnhancedScheduling=true

${GNB_DU_SCELL_2_ADMI_REQ_SA}    M55139C01501
${IGNB_CA_ATT_2_SCELL_SA}    M55118C11002
${GNB_DU_SCELL_1_ADMI_SUCC_SA}    M55139C01004

${IGNB_CA_SCELL_ADMI_REQ_SA}    M55138C03501
${IGNB_CA_SCELL_ADMI_SUCC_SA}    M55138C03502
${IGNB_CA_ADD_REQ_SA_NRADJ}    M55175C00001
${GNB_DU_SCELL_ADMI_REQ_SA}    M55139C01001
${GNB_DU_SCELL_ADMI_SUCC_SA}    M55139C01002


${IGNB_CA_ATT_1_SCELL_SA_SUCC}    M55118C11004


@{PM_Counters_Check_priGNB}
...    NRCELL-1:RSADU:${GNB_DU_SCELL_2_ADMI_REQ_SA}=1
...    NRCELL-1:NCAC:${IGNB_CA_ATT_2_SCELL_SA}=1
...    NRCELL-1:RSADU:${GNB_DU_SCELL_1_ADMI_SUCC_SA}=1
...    NRCELL-1:NCAC:${IGNB_CA_ATT_1_SCELL_SA_SUCC}=1

@{PM_Counters_Check_extGNB}
...    NRCELL-3:RSACU:${IGNB_CA_SCELL_ADMI_REQ_SA}=1
...    NRCELL-4:RSACU:${IGNB_CA_SCELL_ADMI_REQ_SA}=1
...    NRCELL-3:RSACU:${IGNB_CA_SCELL_ADMI_SUCC_SA}=1
...    NRCELL-4:RSACU:${IGNB_CA_SCELL_ADMI_SUCC_SA}=1
...    NRBTS-1:ADJNB:${IGNB_CA_ADD_REQ_SA_NRADJ}=1
...    NRCELL-3:RSADU:${GNB_DU_SCELL_ADMI_REQ_SA}=1
...    NRCELL-4:RSADU:${GNB_DU_SCELL_ADMI_REQ_SA}=1
...    NRCELL-3:RSADU:${GNB_DU_SCELL_ADMI_SUCC_SA}=1

@{RD_Counters_Check_priGNB}
...    NRCELL-1:IGNB_CA_ATT_1_SCELL_SA_SUCC=1


@{Online_Param_FA003_gnb1}
...    NRCELL-1:a1MeasSCellAddEnabled=none
...    NRCELL-1/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-2:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-3:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-4:sCellAdditionMethod=blind

@{Online_Param_FA003_gnb2}
...    NRCELL:weightForSCellSelection=50
...    NRCELL-3:a2MeasSCellRelEnabled=none
...    NRCELL-4:a2MeasSCellRelEnabled=none
...    NRCELL-11:maxNumOfUsersPerNRCell=1
...    NRCELL-11:maxNumOfCaUsersNRCell=1
...    NRCELL-11:maxNumOfSCellAlloc=1
...    NRCELL-11:maxNumOfUsersPerCell=1
...    NRCELL-11:maxNumOfRrcSA=1
...    NRCELL-11:maxNumOfNrDcSnUsers=1

${SA_Capa_Support_All_CA_Without_3T}    SEPARATOR=
...    E9A09000575F5A13160003C320016093170019C3D09009B20C39F30C7942C0E098040623809DC6C06C0D608C21A08107482C036B64C558D
...    0E7C471E819F604F8C48E3C873EA39F30C7942C0E070F05FFFFFC007FFC5F000540001C0A836016B04610D04083C4160195B262AC4873EC
...    09F11C78C48E3C873EA39F30C7942C0E070F09FD8000007F6000000540001C0AA36266B04610D04083A4160185B262A88873E238F11C7A0
...    67D813E31CF9863CA1607038782E007FE003801FF8002A0000E0541B06F582308682041E20B00CAD931562439F11C7B027C62471E439F51
...    CF9863CA1607038784FFF800003FFE000002A0000E0551B137582308680000100B00C2D926544439F11C79063D033EC09F00E7CC31E50B0
...    381C3C17AAAAAAA9EAAAAAAA1500007005161E26000713000000058158B89A001C4C000E260000010B02B17008003098061300004160563
...    E01000606C0C260184C0001858158B8040018020303600040B02B1F00800300C0606C0C26800142C2EB1700800303606130000C160561E0
...    10006130000E160561E0100060080010160561E0D800606C0012160561E0100060180014160561E03000606C0016160562E0100060180C0
...    D800302C0AC3C1B000E2600000D0B02B1713000309806008001C160563E2600061300C010181B0007858158B8980018020303600100B02B
...    1F134003004060180C0D800442C0AC3C4D000E010200120B02B1F008003036061340C268004C2C2E01200DC0068099000A02688A04040C2
...    90A244D8E7C38912244D8E7C38912244D8E7C38D1224489B1CF871224489B1CF871A2448913639F0E2448913639F0E14489B1CF870A244D
...    8E7C3851226C73E1C28913639F0E14489B1CF871224489B1CF870A244D8E7C38912244D8E7C38D1224489B1CF871224489B1CF871A24489
...    13639F0E14489B1CF871A2448913639F0C074506318C6318C6318C6318C6318C7A09801E00140E0A00E0601280380030120020301F04801
...    0000000080040000001000006008000010040000100200000C0100000800800005004002008020080000600400003802001000000040000
...    4002000024010000060080000A004000058020010240900400006019CA9ACA9AC14AC0CAC19AC15ACA5BC19BC05AC0DAC04AC08AC1DA068
...    2000012CA4A080000CB29302000032CA48080001CB29202000092CA48080002CB293020000D2CA48080003CB29202000112CA48080004CB
...    29202000152CA48080005CB29282000192CA480800018B292019A55574AAAA9545D2A8AA0B154162A83455298AA4D154062A8145526AAA0
...    F142405E02540A05028140A05028140A05028140A05028140A050013080801002020040088040080101002004040080110080600A020040
...    08080100230100C014040300501002004040080110080800A02020028080B01630100C01804030050100C018040080110080600A0201802
...    8080100210100C014040080108080600A02018028404030060100C018202018030080600A10100C014040300510080600A0201803008060
...    0A10100C018040080110080100202004008080600A30100200404008010100C014040300510080100202018030080600C30100200404030
...    050100C018040300508080100202048028C04030050100C0180400801010020046A87C0004080C10181C282C30344044484C5060646C707
...    47C8494989CA0A4A8B4BD05060B4

@{unexpectedRegisterString}
...    physCellId 52
...    physCellId 53
...    physCellId 60
...    physCellId 61


*** Test Cases ***
CB008140_ET_FA006_Verify_Successful_Partial_SCell_addition_with_partial_SCellCandidates_are_admitted_at_ext-gNBDU_TTT_maxConfiguredResourceSetsAllCC
    [Documentation]
    ...    The purpose of this test case is to check following scenarios:
    ...    this case is to test successful partial SCell addition with partial scell candidates are admitted at ext-Gnb-DU due to
    ...    maxConfiguredResourceSetsAllCC check status for inter-gNB with 3CC(TDD-TDD-TDD) DL CA.
    ...    Requirement Coverage:
    ...    5G_RAN_USR_RRM_17898, fully covered
    ...    It is about CB008140-FA#B2: Partial SCell addition success for one SA connection when there are more than one SCell candidate to be
    ...    added partial SCell candidates are admitted at ext-gNB-DU
    ...    [Configuration]:
    ...    gnb1:
    ...    Cell id=1 gnb=2 pci=16:2 tac=200 tdd_cell=on band=n77 nr_arfcn=663400:663400 gscn=8159 chBw=100MHz
    ...    weightForSCellSelection=50
    ...    Cell id=2 gnb=2 pci=17:0 tac=200 tdd_cell=on band=n77 nr_arfcn=658000:658000 gscn=8103 chBw=100MHz
    ...    weightForSCellSelection=50
    ...    gnb2:
    ...    Cell id=3 gnb=3 pci=17:1 tac=200 tdd_cell=on band=n77 nr_arfcn=653400:653400 gscn=8072 chBw=100MHz
    ...    weightForSCellSelection=10
    ...    Cell id=4 gnb=3 pci=17:2 tac=200 tdd_cell=on band=n77 nr_arfcn=648000:648000 gscn=8000 chBw=40MHz
    ...    weightForSCellSelection=10
    ...    Cell id=11 gnb=3 pci=20:0 tac=200 tdd_cell=off band=n3 nr_arfcn=349400:368400 gscn=4605 chBw=20MHz
    ...    weightForSCellSelection=10
    ...    Cell id=12 gnb=3 pci=20:1 tac=200 tdd_cell=off band=n28 nr_arfcn=143400:153400 gscn=1916 chBw=20MHz
    ...    weightForSCellSelection=10
    ...    maxConfiguredResourceSetsAllCC set to 16 in all UE Capability and all UE not support 4CC_TTTF, so CA first select 3CC_TTT
    ...    2.Test Case Steps:
    ...        a. UE1 Register And PDU Session Setup On Cell1_1
    ...        b. Trigger UE1 A1 to setup 2CCs CA via rsrq measurement
    ...        c. UE1 Start Traffic And Verify Throughput
    ...        d. Ue2 Register And PDU Session Setup on cell2_4
    ...        e. Send A2 release UE1 SCell
    ...        f. Release all UEs
    ...        g. wireshark logs and PM counters check
    ...    3. Expected Results:
    ...         Step a: UE1 Register And PDU Session Setup Successfully
    ...         Step b: After measurement works,add Cell2_3 as Scells and fails to setup CELL2_4 as Scell with cause "Insufficient UE Capabilities"
    ...         as numberOfTransmittedSsBlocks of PCell Sum(numberOfTransmittedSsBlocks)of all SCell(s) <= maxConfiguredResourceSetsAllCC
    ...        (but actually pcell 8+scell 8 +scell 8 >16)
    ...         Step c: UE1 Traffic And Throughput is OK
    ...         Step d: UE-2 is attached to ext-gNB TDD CELL2-4 and PDU session setup successfully as maxNumOfUsersPerNRCell reserved for UE1 is
    ...                 released after scell addition partial failure
    ...         Step e: UE1 SCell release successfully
    ...         Step f: all UE release successfully
    ...         Step g: wireshark logs and PM counters check:
    ...        1). Procedure:
    ...          1. gNB-1-CU sends to gNB-1-DU the F1AP: IGNB CA UE CONTEXT MODIFICATION REQUEST message
    ...          2. gNB-1-DU replies with the F1AP: IGNB CA UE CONTEXT MODIFICATION RESPONSE message
    ...          3. gNB-1-CU sends to gNB-2-CU XnAP: IGNB CA ADDITION REQUEST message.
    ...          4. gNB-2-CU forwards to gNB-2-DU via F1AP: IGNB CA UE CONTEXT SETUP REQUEST message.
    ...             Only Cell2_3 is successfully allocated with radio resources, Cell2_4 is failed to be added.
    ...             gNB-2-DU replies to gNB-2-CU with an F1AP: IGNB CA UE CONTEXT SETUP RESPONSE message
    ...             with Cell2_4 in the SCell-FailedtoSetupMod-List with cause "Insufficient UE Capabilities"
    ...          5. gNB-2-CU replies to gNB-1-CU XnAP: IGNB-CA UE ADDITION REQUEST ACKNOWLEDGE message, carrying SCells configuration of Cell2_3
    ...             received from gNB-2-DU, and Cell2_4 in 'IgNB-CA SCell Failed to Setup List' with cause "Insufficient UE Capabilities"
    ...          6. gNB-1-CU forwards to gNB-1-DU F1AP:IGNB CA UE CONTEXT MODIFICATION REQUEST message, with Cell2_3 in the 'IgNB-CA SCell to Be
    ...             Setup List' and Cell2_4 in the 'IgNB-CA SCell Failed to Setup List'
    ...          7. gNB-1-DU reconfigures Cell1_1, release resources reserved to Cell2_4, allocates PUCCH resource(s) to support Cell2_3, prepares
    ...             the new radio configuration message (cellGroupConfig) for 5G-UE and sends it to gNB-1-CU via F1AP: IGNB CA UE CONTEXT
    ...             MODIFICATION RESPONSE message. This message carries also the PUCCH configuration Information required by SCell Cell2_4 for
    ...             proper data scheduling and decoding.
    ...          8. gNB-1-CU sends to gNB-2-CU the XnAP: IGNB CA UE CONTEXT MODIFICATION REQUEST message
    ...          9. gNB-2-CU forwards to gNB-2-DU F1AP: IGNB CA UE CONTEXT MODIFICATION REQUEST message.
    ...          10. gNB-2-DU replies with the F1AP: IGNB CA UE CONTEXT MODIFICATION RESPONSE message.
    ...          11. gNB-2-CU replies to gNB-1-CU sending the XnAP: IGNB CA MODIFICATION REQUEST ACKNOWLEDGE message confirming SCells addition.
    ...          12. gNB-1-CU fills out the final RRC: RECONFIGURATION message and sends it to 5G-UE, which acknowledges it through gNB-1-DU via
    ...              F1AP: DL RRC MESSAGE TRANSFER/UL RRC MESSAGE TRANSFER.
    ...          13. gNB-1-CU sends to gNB-1-DU the F1AP: UE CONTEXT MODIFICATION REQUEST message including the RRCReconfigurationCompleteIndicator
    ...              IE, gNB-1-DU replies with the F1AP: UE CONTEXT MODIFICATION RESPONSE message
    ...          14. Finally, gNB-1-CU sends to gNB-1-DU the F1AP: UE CONTEXT MODIFICATION REQUEST message including the GNB-DU Configuration Query
    ...              IE to which gNB-1-DU replies with the F1AP: UE CONTEXT MODIFICATION RESPONSE message
    ...         2). The corresponding counters for SCell Addition are updated accordingly:
    ...             M55139C01501 GNB_DU_SCELL_2_ADMI_REQ_SA for cell1_1
    ...             M55118C11002 IGNB_CA_ATT_2_SCELL_SA for Cell1_1
    ...             M55138C03501 IGNB_CA_SCELL_ADMI_REQ_SA and M55138C03502 IGNB_CA_SCELL_ADMI_SUCC_SA for Cell2_3
    ...             M55138C03501 IGNB_CA_SCELL_ADMI_REQ_SA
    ...             M55175C00001 IGNB_CA_ADD_REQ_SA_NRADJ for gNB-1
    ...             M55139C01001 GNB_DU_SCELL_ADMI_REQ_SA for Cell2_3
    ...             M55118C11004 IGNB_CA_ATT_1_SCELL_SA_SUCC for Cell1_1
    ...             M55139C01004 GNB_DU_SCELL_1_ADMI_SUCC_SA for Cell1_1
    ...             M55139C01002 GNB_DU_SCELL_ADMI_SUCC_SA for Cell2_3
    [Tags]    QC_252595    FA006
    Clear Counter Files for 2GNB
    Ue Register And PDU Session Setup Without Scell Addition    ue_id=1    enb_id=2    cell_id=1
    UE Send A1 To Trigger Scell Addition    ue_id=1
    Run Traffic And Verify Throughput    ue_id=1
    Ue2 Register And PDU Session Setup successful    ue_id=2    enb_id=3    cell_id=4
    Send A2 release UE1 SCell    ue_id=1
    Release UEs    ue_type=all
    Check Counters    ${PM_Counters_Check_priGNB}
    Check Counters GNB2    ${PM_Counters_Check_extGNB}
    Check WireShark Log    ${CURDIR}${/}A2A_FA_006${/}a2a.ini    wait_string=IgNBCAReleaseRequestAcknowledge::1
    Check WireShark Log GNB2    ${CURDIR}${/}A2A_FA_006${/}a2a_gnb2.ini    wait_string=UEContextRelease::14

CB008140_ET_FA003_Verify_Successful_Partial_SCell_addition_with_partial_SCell_candidates_are_admitted_at_ext-gNB-CU_TTFF_maxNumOfUsersPerNRCell
    [Documentation]
    ...    The purpose of this test case is to check following scenarios:
    ...    this case is to test successful partial SCell addition with partial scell candidates are admitted at ext-Gnb-CU due to
    ...    maxNumOfUsersPerNRCell reached for inter-gNB with 4CC(TDD-TDD-FDD-FDD) DL CA.
    ...    Requirement Coverage:
    ...    5G_RAN_USR_RRM_17897, fully covered
    ...    It is about CB008140-FA#B1 Partial SCell addition success for one SA connection when there are more than one SCell
    ...    candidate to be added partial SCell candidates are admitted at ext-gNB-CU
    ...    UE3 {SA_Capa_Support_All_CA_Without_3T} Capability use golden UE Capability but not support TTT, UE1 and UE2 use golden UE Capability
    ...    [Configuration]:
    ...    gnb1:
    ...    Cell id=1 gnb=3 pci=16:2 tac=200 tdd_cell=on band=n77 nr_arfcn=663400:663400 gscn=8159 chBw=100MHz
    ...    weightForSCellSelection=50
    ...    Cell id=2 gnb=3 pci=17:0 tac=200 tdd_cell=on band=n77 nr_arfcn=658000:658000 gscn=8103 chBw=40MHz
    ...    weightForSCellSelection=50
    ...    gnb2:
    ...    Cell id=3 gnb=3 pci=17:1 tac=200 tdd_cell=on band=n77 nr_arfcn=653400:653400 gscn=8072 chBw=100MHz
    ...    weightForSCellSelection=50
    ...    Cell id=4 gnb=3 pci=17:2 tac=200 tdd_cell=on band=n77 nr_arfcn=648000:648000 gscn=8000 chBw=50MHz
    ...    weightForSCellSelection=50
    ...    Cell id=11 gnb=2 pci=20:0 tac=200 tdd_cell=off band=n3 nr_arfcn=349400:368400 gscn=4605 chBw=10MHz
    ...    weightForSCellSelection=50
    ...    Cell id=12 gnb=2 pci=20:1 tac=200 tdd_cell=off band=n28 nr_arfcn=143400:153400 gscn=1916 chBw=15MHz
    ...    weightForSCellSelection=50
    ...    2.Test Case Steps:
    ...        a. Attach UE1 on cell3_3 and UE2 on cell3_11 as pre-UE
    ...        b. Ue3 Register And PDU Session Setup With Blind Scell3_12 Addition
    ...        c. Ue3 Run Traffic And Verify Throughput
    ...        d. Release UEs
    ...        e.wireshark logs check
    ...    3. Expected Results:
    ...         Step a:
    ...         1) UE-1 is attached to ext-gNB TDD CELL3_3 and PDU session setup successfully. maxNumOfUsersPerNRCell of CELL3_3 reaches
    ...         2) UE-2 is attached to ext-gNB FDD CELL3_11 and PDU session setup successfully. maxNumOfUsersPerNRCell of CELL3_11 reaches
    ...         Step b: Ue3 Register And PDU Session Setup With Blind Scell3_12 Addition is successfully
    ...         Step c: UE3 Traffic And Throughput is OK
    ...         Step d: all UE release is ok
    ...         Step e: wireshark logs check:
    ...         1) xn and xp interfaces setup successfully
    ...         2) Procedure:
    ...        a. gNB-1-CU asks gNB-2-CU to configure Cell3_3, Cell3_11 and Cell3_12 as SCells for 5G-UE by sending the XnAP: IGNB CA ADDITION
    ...           REQUEST message.
    ...        b. gNB-2-CU forwards to gNB-2-DU F1AP:IGNB CA UE CONTEXT SETUP REQUEST message with only Cell3_12 in the 'SCell for IgNB-CA
    ...           Establishment to Be Setup List'
    ...        c. gNB-2-DU replies to gNB-2-CU F1AP:IGNB CA UE CONTEXT SETUP RESPONSE message with selected radio configuration for the
    ...           remaining SCell candidate Cell3_12.
    ...        d. gNB-2-CU replies to gNB-1-CU XnAP:IGNB-CA UE ADDITION REQUEST ACKNOWLEDGE message, carrying SCells configuration of carrying
    ...           SCells configuration of Cell3_12, while Cell3_3 and Cell3_11 in 'IgNB-CA SCell Failed to Setup List' with cause
    ...           "RadioNetworkLayer:no-radio-resources-available"
    ...        e. gNB-1-CU forwards to gNB-1-DU F1AP: IGNB CA UE CONTEXT MODIFICATION REQUEST message, with Cell3_12 in the 'IgNB-CA SCell to Be
    ...           Setup List' and Cell3_3 and Cell3_11 in the 'IgNB-CA SCell Failed to Setup List'
    ...        f. gNB-1-DU reconfigures Cell1_1, release resources reserved to Cell3_3 and Cell3_11, allocates PUCCH resource(s) to support
    ...           Cell3_12, prepares the new radio configuration message (cellGroupConfig) for 5G-UE and sends it to gNB-1-CU via F1AP:IGNB CA
    ...           UE CONTEXT MODIFICATION RESPONSE message. This message carries also the PUCCH configuration Information required by SCell Cell3_12
    ...           for proper data scheduling and decoding.
    [Tags]    QC_252598    FA003
    OnlineParamChange_gNB1    ${Online_Param_FA003_gnb1}
    OnlineParamChange_gNB2    ${Online_Param_FA003_gnb2}
    Attach UE1 on cell3_3 and UE2 on cell3_11 as pre-UE
    Ue Register And PDU Session Setup With Blind Scell Addition    ue_id=3
    Run Traffic And Verify Throughput    ue_id=3
    Release UEs    ue_type=all
    Check WireShark Log    ${CURDIR}${/}A2A_FA_003${/}a2a.ini    wait_string=IgNBCAReleaseRequestAcknowledge::1
    Check WireShark Log GNB2    ${CURDIR}${/}A2A_FA_003${/}a2a_gnb2.ini    wait_string=UEContextRelease::24

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup 2Airphone Env    fddtdd_sansa_cmwv/6cells_gnb1_2T_gnb2_2T2F

Modify Cfg
    Update Cfg    ue_param id=3 ue_nr_capabilities=${SA_Capa_Support_All_CA_Without_3T}

Ue Register And PDU Session Setup Without Scell Addition
    [Arguments]    ${ue_id}=1    ${gateway}=1    ${enb_id}=2    ${cell_id}=1
    Execute Egate Command    ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=UE now in NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${gateway}    pass_regexp=QoS Routing Table
    ...    fail_regexp=${unexpectedRegisterString}

Ue2 Register And PDU Session Setup successful
    [Arguments]    ${ue_id}=1    ${gateway}=1    ${enb_id}=2    ${cell_id}=1
    Execute Egate Command    ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=UE now in NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    ${ret1}=    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${gateway}    pass_regexp=QoS Routing Table


UE Send A1 To Trigger Scell Addition
    [Arguments]    ${ue_id}=1    ${cellfreq}=663360    ${scellpci}=52
    ${ScellAdd_A1}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cellfreq}    event_type=A1
    ...    threshold=RSRQ\ 30
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${ScellAdd_A1} event=A1 srsrp_nr=115 srsrq_nr=40
    ...    pass_regexp=rrcReconfigurationComplete
    Should Not Contain    ${ret1}    SCellIndex 2 activated successfully at airphone
    Should Contain    ${ret1}    SCellIndex 1 activated successfully at airphone
    ${ret1}=    Remove String    ${ret1}    \r    \n    ${SPACE}
    Should Contain    ${ret1}    sCellToAddModList{{sCellIndex1,sCellConfigCommon{physCellId${scellpci}
    Sleep    5s    #wait all sysinfo

Run Traffic And Verify Throughput
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${qfi}=1
    Run Keywords    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} trf_id=1 protocol=tcp mbps=150 dir=dl
    ...    Started Downlink Internal traffic over TCP on Ue
    ...    AND    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} trf_id=2 protocol=tcp mbps=150 dir=dl
    ...    Started Downlink Internal traffic over TCP on Ue    sleep_time=2
    ...    AND    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} trf_id=3 protocol=tcp mbps=150 dir=dl
    ...    Started Downlink Internal traffic over TCP on Ue    sleep_time=2
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} trf_id=1 protocol=tcp mbps=50 dir=ul
    Verify Throughput    ue_id=${ue_id}    Tput_dl=410    Tput_ul=45
    [teardown]    Stop Traffic    ${ue_id}    ${pdu}

Stop Traffic
    [Arguments]    ${ue_id}=1    ${pdu}=1
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=${pdu} dir=dl trf_id=1
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=${pdu} dir=dl trf_id=2
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=${pdu} dir=dl trf_id=3
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=${pdu} dir=ul trf_id=1

Verify Throughput
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${qfi}=1    ${Tput_dl}=410    ${Tput_ul}=45    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    direction=ul    rate_type=ave
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pdsch    Throughput
    Should Not Match Regexp    ${scell_tput}    CellIndex-[0-3] *0 *0 *0 *0
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

Clear Counter Files for 2GNB
    Clear Counter Files    ${False}
    Clear Counter Files GNB2

Send A2 release UE1 SCell
    [Arguments]    ${ue_id}=1    ${carrierfreq}=655008    ${sleep_time}=15s
    Execute Egate Command    ue_meas_cfg_disp id=1 meas_obj_type=nr
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A2
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 scell=1 scell_rsrp=30 scell_rsrq=0
    ...    pass_regexp=rrcReconfigurationComplete
    ${ret1}=    Remove String    ${ret1}    \r    \n    ${SPACE}
    Should Contain    ${ret1}    sCellToReleaseList{1}

Attach UE1 on cell3_3 and UE2 on cell3_11 as pre-UE
    Ue Register And PDU Session Setup Without Scell Addition    ue_id=1    enb_id=3    cell_id=3
    Ue Register And PDU Session Setup Without Scell Addition    ue_id=2    enb_id=3    cell_id=11

Ue Register And PDU Session Setup With Blind Scell Addition
    [Arguments]    ${ue_id}=3    ${gateway}=1    ${enb_id}=2    ${cell_id}=1    ${scell1pci}=61
    Execute Egate Command    ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=UE now in NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    ${ret1}=    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${gateway}
    ...    pass_regexp=activated successfully at airphone
    ${ret1}=    Remove String    ${ret1}    \r    \n    ${SPACE}
    Should Contain    ${ret1}    sCellToAddModList{{sCellIndex3,sCellConfigCommon{physCellId${scell1pci}

OnlineParamChange_gNB1
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    wait until keyword succeeds    10 min    60 sec    Cells Should Be OnAir

OnlineParamChange_gNB2
    [Arguments]    ${Online_Param}
    Delta Commission Parameters gnb2    ${Online_Param}
    wait until keyword succeeds    10 min    60 sec    Cells Should Be OnAir
