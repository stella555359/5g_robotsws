*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_VRF    SBTS00    RAN_5G    RAN_5G_TDD    CRT    CLOUD_5G_I_[LO][LO]_AP_[LOO] 
...    owner-ha.zheng    release-SBTS24R2    team-CN1ET
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${NOKIA_XNAP_PLUGIN_FLAG}    ${True}
${NOKIA_F1AP_PLUGIN_FLAG}    ${True}

@{PARAMS_IN_SCF}
...    @{PARAMS_FOR_CA}
...    @{PARAMS_FOR_GNB1}
...    @{PARAMS_ADJ_REL_FOR_GNB1}
...    @{PARAMS_FOR_OTHERS}
...    @{PARAMS_FOR_9059_gnb1}
...    @{PARAMS_FOR_HO}
...    @{PARAMS_FREQ_FOR_CELL11}

@{PARAMS_IN_SCF_GNB2}
...    @{PARAMS_FOR_CA}
...    @{PARAMS_FOR_GNB2}
...    @{PARAMS_ADJ_REL_FOR_GNB2}
...    @{PARAMS_FOR_OTHERS}
...    @{PARAMS_FOR_9059_gnb2}
...    @{PARAMS_FOR_HO}
...    @{PARAMS_FOR_beams}

@{PARAMS_FOR_9059_gnb1}
...    NRBTS/NRDRB-11:cellAggrLevel=FR1 CA eligible
...    NRBTS/NRDRB-12:cellAggrLevel=FR1 CA incompatible
...    NRBTS/NRDRB-13:cellAggrLevel=Not FR1 CA eligible
...    NRBTS/NRDRB-14:cellAggrLevel=FR1 CA eligible
...    NRBTS/NRDRB-18:cellAggrLevel=Not FR1 CA eligible
...    NRBTS/NRDRB-19:cellAggrLevel=Not FR1 CA eligible
...    NRBTS/NRDRB-20:cellAggrLevel=FR1 CA eligible
...    NRBTS:actDrbProfileForCellAggrLevel=FR1_SA

@{PARAMS_FOR_9059_gnb2}
...    NRBTS/NRDRB-11:cellAggrLevel=FR1 CA eligible
...    NRBTS/NRDRB-12:cellAggrLevel=Not FR1 CA eligible
...    NRBTS/NRDRB-13:cellAggrLevel=FR1 CA incompatible
...    NRBTS/NRDRB-14:cellAggrLevel=FR1 CA eligible
...    NRBTS/NRDRB-18:cellAggrLevel=Not FR1 CA eligible
...    NRBTS/NRDRB-19:cellAggrLevel=Not FR1 CA eligible
...    NRBTS/NRDRB-20:cellAggrLevel=FR1 CA eligible
...    NRBTS:actDrbProfileForCellAggrLevel=FR1_SA

@{PARAMS_FREQ_FOR_CELL11}
...    NRCELL-11/NRCELL_FDD-1:nrarfcnDl=368400
...    NRCELL-11/NRCELL_FDD-1:nrarfcnUl=349400
...    NRCELL-11:gscnOrSsPbchArfcn=4605
...    NRCELL-11:type0CoresetConfigurationIndex=7

@{PARAMS_FOR_beams}
...    NRCELLGRP-0:numberOfTransmittedSsBlocks=6 beams
...    NRBTS:actFdmEnhancedScheduling=true
...    NRCELL-1:periodicCsiAcquisition:maxCsirsNumber=4
...    NRCELL-1:periodicCsiAcquisition:csirsNumberWithinReportPeriod_Set1=4
...    NRCELL-1:periodicCsiAcquisition:csirsPower=9
...    NRCELL-1:actCellCsirsTddOnSsbBf=false
...    NRCELL-1:actCellCsiRsImTddNonBf=false
...    NRCELL-1:actCsirsMultiplexing=true
...    NRCELL-1:dlMimoMode=8x4 Closed Loop Spatial Multiplexing
...    NRCELL-1:numberOfRxBeamforming=4Rx
...    NRCELL-1:actAperCsi=true
...    NRCELL-1:actBeamforming=true
...    NRCELL-1:beamSet:basicBeamSet=beamSet_6
...    NRCELL-1:beamSet:beamsMuted=0
...    NRCELL-1:beamSet:tiltOffset=0
...    NRCELL-1:beamSet:leftEdgeAngle=60
...    NRCELL-1:beamSet:rightEdgeAngle=60

@{PARAMS_FOR_CA}
...    NRBTS:actCarrierAggregation=true
...    NRBTS:sCellActivationMethod=bufferBased
...    NRBTS:actBufferBasedSCellAddition=disabled
...    NRBTS:caConfigurationSupport=4CCDL_2CCUL
...    NRBTS:weightForIgnbCaSelection=20
...    NRBTS:actIncXn=true
...    NRBTS:maxNumScellsDl=2
...    NRBTS:maxNumScellsUl=2
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:carrierAggregationSupportList=ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Sa,ca_Fdd_Any_Sa,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Fdd,ca_Fdd_Fr1Tdd_Sa_WithUl
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRDU-1:actInterGnbCa=DLOnly
...    NRDU-1:dlToUlContributionRatio=50
...    NRDU-1:xgUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRCELL:actK1Opt=intraAndInter-gNB
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRDRB_RLC_AM-1:ulTReassemblyIBCA=40
...    NRDRB_RLC_AM-2:ulTReassemblyIBCA=40

@{PARAMS_FOR_HO}
...    NRBTS:actIntraFreqHoSA=true
...    NRBTS:actInterFreqHoSA=true
...    NRPMRNL-1:miNrRelReportCu=5min
...    NRBTS:actIntraNrNgHo=sourceAndTarget
...    NRBTS:tNgRelocExecDeltN=3000
...    NRBTS:tNgRelocCancelN=2000
...    NRBTS:tNgRelocOverallN=3000
...    NRBTS:tNgRelocPrepN=2000
...    NRBTS:suppCnPartialAdNgHo=false
...    NRBTS:actHoOptimizationCa=true

@{PARAMS_FOR_GNB1}
...    NRCELL-11:sCellDeactivationTimerGNB=infinity
...    NRCELL-12:sCellDeactivationTimerGNB=infinity
...    NRCELL:nrCellType=2DL2UL
...    NRCELL-11:maxNumScellsDlFr1=3
...    NRCELL-11:dlMimoMode=2x2 Open Loop Spatial Multiplexing
...    NRCELL-12:dlMimoMode=2x2 Open Loop Spatial Multiplexing
...    NRPMRNL-1:miNrInterGnbMobilityNsaPmqap=disabled
...    NRPMRNL-1:miNrInterGnbNgMobilitySaPmqap=disabled
...    NRPMRNL-1:miNrInterGnbXnMobilitySaPmqap=disabled
...    NRPMRNL-1:miNrIntraGnbMobilityNsaPmqap=disabled
...    NRPMRNL-1:miNrIntraGnbMobilitySaPmqap=disabled
...    NRBTS:actNgcFlexSaMode=true
...    NRPMRNL-1:miNrRelReportCu=disabled

@{PARAMS_ADJ_REL_FOR_GNB1}
...    NRBTS:iGnbCaXnCfUpBackOffTmr=60
...    NRBTS:iGnbCaXnSetupReqTmr=60
...    NRBTS:iGnbCaXnSetupRespTmr=60
...    NRBTS:intGnbScellTempBlockTmr=60
...    NRBTS/NRADJGNB-2:administrativeState=Unlocked
...    NRBTS/NRADJGNB-2:gNbIdLength=22
...    NRBTS/NRADJGNB-2:gNodeBId=2
...    NRBTS/NRADJGNB-2:weightForIgnbCaSelection=50
...    NRBTS/NRADJGNB-2:xnLinkRef=1
...    NRBTS/NRADJGNB-2:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-2:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-2:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-1:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-1:fiveGsTac=200
...    NRBTS/NRADJNRCELL-1:gNbId=2
...    NRBTS/NRADJNRCELL-1:gNbIdLength=22
...    NRBTS/NRADJNRCELL-1:lcrId=1
...    NRBTS/NRADJNRCELL-1:nrarfcn=663400
...    NRBTS/NRADJNRCELL-1:physCellId=50
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-1:freqBandIndicatorNR=77
...    NRBTS/NRADJNRCELL-1:ssbFrequency=663360
...    NRBTS/NRADJNRCELL-2:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-2:fiveGsTac=200
...    NRBTS/NRADJNRCELL-2:gNbId=2
...    NRBTS/NRADJNRCELL-2:gNbIdLength=22
...    NRBTS/NRADJNRCELL-2:lcrId=2
...    NRBTS/NRADJNRCELL-2:nrarfcn=658000
...    NRBTS/NRADJNRCELL-2:physCellId=51
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-2:freqBandIndicatorNR=77
...    NRBTS/NRADJNRCELL-2:ssbFrequency=657984
...    NRBTS/NRADJNRCELL-13:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-13:fiveGsTac=200
...    NRBTS/NRADJNRCELL-13:gNbId=2
...    NRBTS/NRADJNRCELL-13:gNbIdLength=22
...    NRBTS/NRADJNRCELL-13:lcrId=13
...    NRBTS/NRADJNRCELL-13:nrarfcn=368400
...    NRBTS/NRADJNRCELL-13:physCellId=62
...    NRBTS/NRADJNRCELL-13:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-13:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-13:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-13:freqBandIndicatorNR=3
...    NRBTS/NRADJNRCELL-13:ssbFrequency=368430
...    NRBTS/NRADJNRCELL-14:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-14:fiveGsTac=200
...    NRBTS/NRADJNRCELL-14:gNbId=2
...    NRBTS/NRADJNRCELL-14:gNbIdLength=22
...    NRBTS/NRADJNRCELL-14:lcrId=14
...    NRBTS/NRADJNRCELL-14:nrarfcn=153400
...    NRBTS/NRADJNRCELL-14:physCellId=63
...    NRBTS/NRADJNRCELL-14:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-14:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-14:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-14:freqBandIndicatorNR=28
...    NRBTS/NRADJNRCELL-14:ssbFrequency=153370
...    NRCELL-11/NRREL-12:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-12:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-12:gNbId=1
...    NRCELL-11/NRREL-12:gNbIdLength=22
...    NRCELL-11/NRREL-12:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-12:lcrId=12
...    NRCELL-11/NRREL-12:removeNotAllowed=false
...    NRCELL-11/NRREL-12:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-12:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-12:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-12:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-12:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-13:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-13:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-13:gNbId=2
...    NRCELL-11/NRREL-13:gNbIdLength=22
...    NRCELL-11/NRREL-13:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-13:lcrId=13
...    NRCELL-11/NRREL-13:removeNotAllowed=false
...    NRCELL-11/NRREL-13:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-13:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-13:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-11:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-11:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-11:gNbId=1
...    NRCELL-12/NRREL-11:gNbIdLength=22
...    NRCELL-12/NRREL-11:handoverAllowedSA=allowed
...    NRCELL-12/NRREL-11:lcrId=11
...    NRCELL-12/NRREL-11:removeNotAllowed=false
...    NRCELL-12/NRREL-11:sCellAdditionMethod=blind
...    NRCELL-12/NRREL-11:sCellOperationalMode=dlOnly
...    NRCELL-12/NRREL-11:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-11:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-11:gnbPlmn:mncLength=3
...    NRCELL-11:a3MeasEnabled=rsrp
...    NRCELL-11:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0|a3OffsetSsbRsrp=3|a3TimeToTriggerSsbRsrp=ms320
...    NRCELL:a1MeasSCellAddEnabled=rsrp
...    NRCELL:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=70
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=90
...    NRCELL:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms

@{PARAMS_FOR_GNB2}
...    NRBTS:iGnbCaXnCfUpBackOffTmr=60
...    NRBTS:iGnbCaXnSetupReqTmr=90
...    NRBTS:iGnbCaXnSetupRespTmr=60
...    NRBTS:intGnbScellTempBlockTmr=60
...    NRCELL-1:sCellDeactivationTimerGNB=infinity
...    NRCELL-2:sCellDeactivationTimerGNB=infinity
...    NRCELL-13:sCellDeactivationTimerGNB=infinity
...    NRCELL-14:sCellDeactivationTimerGNB=infinity
...    NRCELL-1:weightForSCellSelection=50
...    NRCELL-2:weightForSCellSelection=15
...    NRCELL-13:weightForSCellSelection=10
...    NRCELL-14:weightForSCellSelection=40
...    NRCELL-1:nrCellType=4DL4UL
...    NRCELL-2:nrCellType=4DL4UL
...    NRCELL-1:fPdcchMonOccsnPo=2
...    NRCELL-2:fPdcchMonOccsnPo=2
...    NRCELL-1:dlMimoMode=4x4 or 4x2 Open Loop Spatial Multiplexing
...    NRCELL-2:dlMimoMode=4x4 or 4x2 Open Loop Spatial Multiplexing
...    NRCELL-1:a2MeasSCellRelEnabled=rsrp
...    NRCELL-1:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-1:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=35|a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-1:a2MeasSCellRelSsbRsrq:a2HysteresisSCellRelSsbRsrq=0|a2TimeToTriggerSCellRelSsbRsrq=0ms
...    NRCELL-1:a2MeasSCellRelSsbRsrq:a2ThresholdSCellRelSsbRsrq=10|a2TimeToTriggerSCellRelSsbRsrq=0ms
...    NRCELL-2:a2MeasSCellRelEnabled=rsrp
...    NRCELL-2:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-2:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=35|a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-2:a2MeasSCellRelSsbRsrq:a2HysteresisSCellRelSsbRsrq=0|a2TimeToTriggerSCellRelSsbRsrq=0ms
...    NRCELL-2:a2MeasSCellRelSsbRsrq:a2ThresholdSCellRelSsbRsrq=10|a2TimeToTriggerSCellRelSsbRsrq=0ms
...    NRCELL-13:a1MeashoEnabledSA=rsrp
...    NRCELL-13:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0|a1ThresholdhoSsbRsrpSA=34|a1TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL-13:a2MeashoEnabledSA=rsrp
...    NRCELL-13:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0|a2ThresholdhoSsbRsrpSA=20|a2TimeToTriggerhoSsbRsrpSA=ms64
...    NRCELL-13:a3MeasEnabled=rsrp
...    NRCELL-13:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0|a3OffsetSsbRsrp=3|a3TimeToTriggerSsbRsrp=ms320
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-7:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-7:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-8:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-8:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-7:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-7:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-8:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-8:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1

@{PARAMS_ADJ_REL_FOR_GNB2}
...    NRBTS/NRADJGNB-1:administrativeState=Unlocked
...    NRBTS/NRADJGNB-1:gNbIdLength=22
...    NRBTS/NRADJGNB-1:gNodeBId=1
...    NRBTS/NRADJGNB-1:weightForIgnbCaSelection=50
...    NRBTS/NRADJGNB-1:xnLinkRef=1
...    NRBTS/NRADJGNB-1:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-1:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-11:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-11:fiveGsTac=200
...    NRBTS/NRADJNRCELL-11:freqBandIndicatorNR=3
...    NRBTS/NRADJNRCELL-11:gNbId=1
...    NRBTS/NRADJNRCELL-11:gNbIdLength=22
...    NRBTS/NRADJNRCELL-11:lcrId=11
...    NRBTS/NRADJNRCELL-11:nrarfcn=368400
...    NRBTS/NRADJNRCELL-11:physCellId=60
...    NRBTS/NRADJNRCELL-11:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-11:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-11:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-11:ssbFrequency=368430
...    NRBTS/NRADJNRCELL-12:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-12:fiveGsTac=200
...    NRBTS/NRADJNRCELL-12:freqBandIndicatorNR=3
...    NRBTS/NRADJNRCELL-12:gNbId=1
...    NRBTS/NRADJNRCELL-12:gNbIdLength=22
...    NRBTS/NRADJNRCELL-12:lcrId=12
...    NRBTS/NRADJNRCELL-12:nrarfcn=374000
...    NRBTS/NRADJNRCELL-12:physCellId=61
...    NRBTS/NRADJNRCELL-12:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-12:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-12:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-12:ssbFrequency=373970
...    NRCELL-13/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-13/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-13/NRREL-1:gNbId=2
...    NRCELL-13/NRREL-1:gNbIdLength=22
...    NRCELL-13/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-13/NRREL-1:lcrId=1
...    NRCELL-13/NRREL-1:removeNotAllowed=false
...    NRCELL-13/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-13/NRREL-1:sCellOperationalMode=dlAndUl
...    NRCELL-13/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-1:increasePUSCHPrepTimeULCA=true
...    NRCELL-13:timingAdvanceOffset=n25600
...    NRCELL-13/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-13/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-13/NRREL-2:gNbId=2
...    NRCELL-13/NRREL-2:gNbIdLength=22
...    NRCELL-13/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-13/NRREL-2:lcrId=2
...    NRCELL-13/NRREL-2:removeNotAllowed=false
...    NRCELL-13/NRREL-2:sCellAdditionMethod=blind
...    NRCELL-13/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-13/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-13/NRREL-11:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-13/NRREL-11:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-13/NRREL-11:gNbId=1
...    NRCELL-13/NRREL-11:gNbIdLength=22
...    NRCELL-13/NRREL-11:handoverAllowedSA=allowed
...    NRCELL-13/NRREL-11:lcrId=11
...    NRCELL-13/NRREL-11:removeNotAllowed=false
...    NRCELL-13/NRREL-11:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-11:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-11:gnbPlmn:mncLength=3
...    NRCELL-13/NRREL-12:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-13/NRREL-12:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-13/NRREL-12:gNbId=1
...    NRCELL-13/NRREL-12:gNbIdLength=22
...    NRCELL-13/NRREL-12:handoverAllowedSA=XnHoNotAllowed
...    NRCELL-13/NRREL-12:lcrId=12
...    NRCELL-13/NRREL-12:removeNotAllowed=false
...    NRCELL-13/NRREL-12:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-12:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-12:gnbPlmn:mncLength=3
...    NRCELL-13/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-13/NRHOIF-1:a5MeasEnabled=rsrp
...    NRCELL-13/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-13/NRHOIF-1:freqBandIndicatorNR=3
...    NRCELL-13/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-13/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-13/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-13/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-13/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-13/NRHOIF-1:ssbFrequency=373970
...    NRCELL-13/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0|a3OffsetSsbRsrp=20|a3TimeToTriggerSsbRsrp=ms160
...    NRCELL-13/NRHOIF-1:a5MeasSsbRsrp:a5HysteresisSsbRsrp=0
...    NRCELL-13/NRHOIF-1:a5MeasSsbRsrp:a5Threshold1SsbRsrp=40
...    NRCELL-13/NRHOIF-1:a5MeasSsbRsrp:a5Threshold2SsbRsrp=50
...    NRCELL-13/NRHOIF-1:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms160
...    NRCELL-13:measGapSelectionSA=favourUeThroughput
...    NRCELL-13:a1MeasSCellAddEnabled=rsrp
...    NRCELL-13:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL-13:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=70
...    NRCELL-13:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=90
...    NRCELL-13:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms

@{PARAMS_FOR_OTHERS}
...    NRBTS:actRanSharing=false
...    NRCELL:actCDrx=true
...    NRBTS:rrcReestabTypeSA=viaRRCSetup

@{OnlineParam_BC004_1}
...    NRCELL-11/NRREL-12:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-11:sCellAdditionMethod=covBasedA1

@{OnlineParam_BC004_2}
...    NRCELL-13/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-13/NRREL-2:sCellAdditionMethod=covBasedA1

@{OnlineParam_BC004_3}
...    NRCELL-11/NRREL-12:sCellAdditionMethod=blind
...    NRCELL-12/NRREL-11:sCellAdditionMethod=blind

@{OnlineParam_BC004_4}
...    NRCELL-13/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-13/NRREL-2:sCellAdditionMethod=blind

${SA_Capa_n3_n77_n77_3CC_DL_2CC_UL_CA}    SEPARATOR=
...    E9A09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C47013B8D80D81AC1184341020E9068036B64C558D
...    0E7C471E819F604F8C48E3C873EA39F30C7942C0E070F05C00FFC0070005F0005C0000E0541B00B582308682041E20D00656C98AB121CFB0
...    27C471E31238F21CFA8E7CC31E50B0381C3C27F6000001FD800000170000381546C4CD608C21A0810748340185B262A88873E238F11C7A06
...    7D813E31CF9863CA1607038782E007FE003801FF8002E0000702A0D837AC1184341020F1068032B64C55890E7C471EC09F1891C790E7D473
...    E618F28581C0E1E13FFE00000FFF800000B80001C0AA3626EB04610D00000201A00C2D926544439F11C79063D033EC09F00E7CC31E50B038
...    1C3C17AAAAAAA9EAAAAAAA17000038026B0F1300038980000002C0AC5C4C000E26000713000000858158B804001C4C000E260000020B02B1
...    F008003036061300C268000C2C0AC5C02000C010181B0002058158F8040018060303606134000A160562E01000606C0C26000182C0AC3C02
...    000C260001C2C0AC3C02000C01000202C0AC3C1B000C0D800242C0AC3C02000C03000282C0AC3C06000C0D8002C2C0AC5C02000C030181B0
...    0060581587836001C4C00001A160562E2600061300C01000382C0AC7C4D000C260180203036000F0B02B171300030040606C0020160563E2
...    680060080C030181B0008858158789A001C02040024160402401B800D0132001404D17400F509C28913639F0E2448913639F0E2448913639
...    F0E344891226C73E1C4891226C73E1C68912244D8E7C38912244D8E7C3851226C73E1C28913639F0E14489B1CF870A244D8E7C3851226C73
...    E1C4891226C73E1C28913639F0E2448913639F0E344891226C73E1C4891226C73E1C68912244D8E7C3851226C73E1801B1318C6318C6318C
...    6318C6318C7E82E003C00281C1401C0C02500700060240040603E09002000000010008000000200000C01000002008000020040000180200
...    00100100000A008004010040100000C0080000700400200000008000080040000480200000C010000140080000B004002048120080000C03
...    39535953582958195833582B594B7833780B581B58095811583B40D040000259490100001965260400006594901000039652404000125949
...    010000596526040001A594901000079652404000225949010000996524040002A5949010000B96525040003259490100003165240334AA2E
...    955552A8BA55154162A82C55068AA531549A2A80C55028AA4D5541E285805E02540A05028140A05028140A05028140A05028140A05001208
...    0801002020040088040080101002004040080110080600A02004008080100230100C014040300501002004040080110080800A0202002808
...    0B01630100C01804030050100C018040080110080600A02018028080100210100C014040080108080600A02018028404030060100C018202
...    018030080600A10100C014040300510080600A02018030080600A10100C018040080110080100202004008080600A3010020040400801010
...    0C014040300510080100202018030080600C30100200404030050100C018040300508080100202048028D50F800081018203038505860688
...    0889098A0C0C8D8E0E8F909293139414951697A0A0C168

@{PM_Counters_Check_GNB1_BC002_1}
...    NRCELL-12:${SCELL_ADDN_ALLOW_DRB_PRFL_CA}=1
...    NRCELL-11:${SCELL_ADDN_PREVENT_DRB_PRFL_CA}=1
...    NRCELL-12:${SCELL_ADDN_PREVENT_DRB_PRFL_CA}=1

@{PM_Counters_Check_GNB2_BC002_1}
...    NRCELL-13:${SCELL_ADDN_ALLOW_DRB_PRFL_CA}=2
...    NRCELL-13:${DL_RRC_FSCELL_REL_ATT_SA}=1
...    NRCELL-13:${DL_RRC_FSCELL_REL_SUC_SA}=1
...    NRCELL-13:${ELIGIBLE_DRB_REL_SCELL_ATT_SA}=3
...    NRCELL-13:${ELIGIBLE_DRB_REL_SCELL_SUC_SA}=3

@{PM_Counters_Check_GNB1_BC002_2}
...    NRCELL-11:${SCELL_ADDN_ALLOW_DRB_PRFL_CA}=1
...    NRCELL-12:${SCELL_ADDN_ALLOW_DRB_PRFL_CA}=1

@{PM_Counters_Check_GNB2_BC002_2}
...    NRCELL-13:${SCELL_ADDN_PREVENT_DRB_PRFL_CA}=1
...    NRCELL-13:${DL_RRC_FSCELL_REL_ATT_SA}=0
...    NRCELL-13:${DL_RRC_FSCELL_REL_SUC_SA}=0
...    NRCELL-13:${ELIGIBLE_DRB_REL_SCELL_ATT_SA}=0
...    NRCELL-13:${ELIGIBLE_DRB_REL_SCELL_SUC_SA}=0

@{PM_Counters_Check_GNB1_BC004}
...    NRCELL-11:${SCELL_ADDN_ALLOW_DRB_PRFL_CA}=1
...    NRCELL-12:${SCELL_ADDN_ALLOW_DRB_PRFL_CA}=1
...    NRCELL-11:${SCELL_ADDN_PREVENT_DRB_PRFL_CA}=2
...    NRCELL-12:${SCELL_ADDN_PREVENT_DRB_PRFL_CA}=1

@{PM_Counters_Check_GNB2_BC004}
...    NRCELL-13:${SCELL_ADDN_ALLOW_DRB_PRFL_CA}=3
...    NRCELL-13:${SCELL_ADDN_PREVENT_DRB_PRFL_CA}=1
...    NRCELL-13:${DL_RRC_FSCELL_REL_ATT_SA}=2
...    NRCELL-13:${DL_RRC_FSCELL_REL_SUC_SA}=2
...    NRCELL-13:${ELIGIBLE_DRB_REL_SCELL_ATT_SA}=3
...    NRCELL-13:${ELIGIBLE_DRB_REL_SCELL_SUC_SA}=3
...    NRCELL-13:${INCMP_DRB_STP_REL_SCELL_ATT_SA}=3
...    NRCELL-13:${INCMP_DRB_STP_REL_SCELL_SUC_SA}=3

${SCELL_ADDN_ALLOW_DRB_PRFL_CA}    M55125C00039
#This counter shows the number of times SCell addition is allowed for a UE due to data radio bearer (DRB) profile-based Carrier Aggregation.
${SCELL_ADDN_PREVENT_DRB_PRFL_CA}    M55125C00040
#This counter shows the number of times SCell addition is prevented for a UE due to data radio bearer (DRB) profile-based Carrier Aggregation.
${INCMP_DRB_STP_REL_SCELL_ATT_SA}    M55118C00034
# This counter measures the number of SCells to be released due to the addition of a CA-incompatible data radio bearer (DRB) in the PCell for SA.
${INCMP_DRB_STP_REL_SCELL_SUC_SA}    M55118C00035
#This counter measures the number of SCells released due to the addition of a CA-incompatible data radio bearer (DRB) in the PCell for SA.
${DL_RRC_FSCELL_REL_ATT_SA}    M55118C00042
#This counter measures the number of full SCell release attempts in DL in the PCell for SA. It considers only full SCell
#releases, partial SCell releases aren't counted. It considers both local SCells and ext-SCells.
${DL_RRC_FSCELL_REL_SUC_SA}    M55118C00043
#This counter measures the number of successful full SCell release attempts in DL in the PCell for SA. It considers only full
#SCell releases, partial SCell releases aren't counted. It considers both local SCells and ext-SCells.
${ELIGIBLE_DRB_REL_SCELL_ATT_SA}    M55118C00036
#This counter measures the number of SCells to be released due to the release of the last CA-eligible data radio bearer (DRB) in the PCell for SA.
${ELIGIBLE_DRB_REL_SCELL_SUC_SA}    M55118C00037
#This counter measures the number of SCells released due to the release of the last CA-eligible data radio bearer (DRB) in the PCell for SA.


@{pdu_check_drb2}
...    freqBandIndicatorNR 3
...    eventA3
...    QoS Routing Table
...    QFI:1 5QI:6
...    QFI:2 5QI:7
...    drx-Config setup
...    pcid:60, scellIdx:0
...    rrcReconfigurationComplete

@{pdu_check_drb3}
...    freqBandIndicatorNR 3
...    eventA3
...    QoS Routing Table
...    QFI:1 5QI:6
...    QFI:2 5QI:8
...    drx-Config setup
...    pcid:60, scellIdx:0
...    rrcReconfigurationComplete
...    @{FF_CA_1}

@{FF_CA_1}
...    pcid:61, scellIdx:1
...    frequencyBandList.*\{.*3.*\}\.

@{ho_intra}
...    eventA2
...    drx-Config release
...    Inter-eNB handover from EXT_ENB-2.11 to EXT_ENB-3.13
...    drx-Config setup
...    rrcReconfigurationComplete

@{ho_FTT_CA}
...    @{ho_intra}
...    @{FTT_CA}

@{FTT_CA}
...    frequencyBandList.*\{.*77.*\}\.:::2
...    pcid:50, scellIdx:1] configure_1_1
...    pcid:50, scellIdx:1] configure_0_1
...    pcid:51, scellIdx:2

@{del_drb1_release_CA}
...    QoS Routing Table
...    sCellToReleaseList.*\{.*1,.*2.*\}\.
...    Pdu Session Resource Modify Response

@{add_drb1_add_CA}
...    QoS Routing Table
...    Pdu Session Resource Modify Response
...    @{FTT_CA}

@{ho_no_CA}
...    Inter-eNB handover from EXT_ENB-3.13 to EXT_ENB-2.12
...    drx-Config setup

@{del_drb2_add_CA}
...    QoS Routing Table
...    Pdu Session Resource Modify Response
...    @{FF_CA_2}

@{FF_CA_2}
...    pcid:60, scellIdx:1
...    frequencyBandList.*\{.*3.*\}\.

@{ho_add_CA}
...    Inter-eNB handover from EXT_ENB-3.13 to EXT_ENB-2.12
...    drx-Config setup
...    @{FF_CA_2}

@{add_drb1_A1}
...    QoS Routing Table
...    Pdu Session Resource Modify Response
...    eventA1

@{del_drb2_A1}
...    QoS Routing Table
...    Pdu Session Resource Modify Response
...    eventA1

@{ho_intra_back}
...    eventA3
...    drx-Config release
...    Inter-eNB handover from EXT_ENB-3.13 to EXT_ENB-2.11
...    drx-Config setup
...    rrcReconfigurationComplete

@{rrc_delay}
...    drx-Config release
...    Hit on

@{reestab_intra}
...    eventA2
...    eventA1
...    drx-Config setup
...    rrcReconfigurationComplete
...    setup/reestablishment complete

@{add_drb3_release_CA}
...    QoS Routing Table
...    sCellToReleaseList.*\{.*1,.*2.*\}\.
...    Pdu Session Resource Modify Response

@{add_drb2}
...    QoS Routing Table
...    Pdu Session Resource Modify Response

*** Test Cases ***
CB009059-ET-BC007_Interaction_with_mobility_covBasedA1_SCell_Addition_method_and_HO_optimized_for_CA
    [Documentation]
    ...    1.The purpose of this test case is to check following scenarios:
    ...     This user scenario describes CB009059 interaction with UE mobility cases when the SCell Addition method is
    ...     covBasedA1.
    ...     This user scenario describes CB009059 interaction with UE mobility cases when a CA is disallowed DRB
    ...     configuration is established during the HO procedure.
    ...     This user scenario describes CB009059 interaction with HO optimized for CA (CB007877) when the SCell
    ...     Addition method is covBasedA1.
    ...     This user scenario describes CB009059 interaction with incoming HO from LTE connected to ECP (5GC000711)
    ...     when the SCell Addition method is covBasedA1.
    ...     This user scenario describes CB009059 interaction with incoming HO from LTE connected to ECP (5GC000711)
    ...     when a CA is disallowed DRB configuration is established during the HO procedure.
    ...     At least 4 NRBTS/NRDRB MOC instances are configured as non-GRB types:
    ...     NRDRB ID resType Value RLC Mode cellAggrLevel Value
    ...     for gnb1:
    ...          1 non-GBR AM 0:FR1 CA eligible
    ...          2 non-GBR AM 1:FR1 CA incompatible
    ...          3 non-GBR AM 2:Not FR1 CA eligible
    ...          4 non-GBR AM 0:FR1 CA eligible
    ...     for gnb2:
    ...          1 non-GBR AM 0:FR1 CA eligible
    ...          2 non-GBR AM 1:Not FR1 CA eligible
    ...          3 non-GBR AM 2:FR1 CA incompatible
    ...          4 non-GBR AM 0:FR1 CA eligible
    ...    2.Test Case Steps:
    ...         Step A. 1.UE1 attaches to gnb1 Cell-11 and the gNB establishes 1 PDU session with DRB-1, DRB-2 during the UE context setup
    ...                 2.trigger intra freq XN handover to gnb2 cell13
    ...                 3.delete DRB-1 by NGAP: PDU SESSION RESOURCE MODIFY REQUEST
    ...                 4.add DRB-1 by NGAP: PDU SESSION RESOURCE MODIFY REQUEST
    ...                 5.trigger inter freq NG handover to gnb1 cell12,
    ...                 6.delete DRB-2 by NGAP: PDU SESSION RESOURCE MODIFY REQUEST
    ...                 7.UE released
    ...                 8.check counters
    ...         Step B. 1.UE1 attaches to gnb1 Cell-11 and the gNB establishes 1 PDU session with DRB-1, DRB-3 during the UE context setup
    ...                 2.trigger intra freq XN handover to gnb2 cell13
    ...                 3.delete DRB-1 by NGAP: PDU SESSION RESOURCE MODIFY REQUEST
    ...                 4.add DRB-1 by NGAP: PDU SESSION RESOURCE MODIFY REQUEST
    ...                 5.trigger inter freq NG handover to gnb1 cell12
    ...                 6.delete DRB-3 by NGAP: PDU SESSION RESOURCE MODIFY REQUEST
    ...                 7.UE released
    ...                 8.check counters
    ...         Step C. 1.UE1 attaches to gnb1 Cell-11 and the gNB establishes 1 PDU session with DRB-1, DRB-2 during the UE context setup
    ...                 2.trigger intra freq XN handover to gnb2 cell13, A1 scell addtion MR send from UE1
    ...                 3.delete DRB-1 by NGAP: PDU SESSION RESOURCE MODIFY REQUEST
    ...                 4.add DRB-1 by NGAP: PDU SESSION RESOURCE MODIFY REQUEST, A1 scell addtion MR send from UE1
    ...                 5.trigger intra freq XN handover to gnb1 cell11, A1 scell addtion MR send from UE1
    ...                 6.Set RRC Reconfiguration Complete delay, trigger intra freq XN handover to gnb2 cell13, 
    ...                 trigger reestablishment to gnb2 cell13, A1 scell addtion MR send from UE1
    ...                 7.add DRB-3 by NGAP: PDU SESSION RESOURCE MODIFY REQUEST
    ...                 8.add DRB-2 by NGAP: PDU SESSION RESOURCE MODIFY REQUEST
    ...                 9.trigger inter freq NG handover to gnb1 cell12
    ...                 10.delete DRB-2 by NGAP: PDU SESSION RESOURCE MODIFY REQUEST, A1 scell addtion MR send from UE1
    ...                 11.UE released
    ...                 12.check counters
    ...    3. Expected Results:
    ...         Step A. 1.UE1 is attached to gnb1 Cell-11 and DRBs setup successfully, A3 mobility measconfig send to UE, no CA
    ...                 2.handover to gnb2 cell13 successfully, 3CC CA to the UE with Cell-1(ul and dl) and Cell-2 as the SCells
    ...                 3.DRB-1 delete successfully, CA release.
    ...                 4.DRB-1 add successfully, 3CC CA to the UE with Cell-1(ul and dl) and Cell-2 as the SCells
    ...                 5.handover to gnb1 cell12 successfully, no CA configured.
    ...                 6.DRB-2 delete successfully, 2CC CA to the UE with Cell-11 as the SCells
    ...                 7.UE released successfully
    ...                 8.check counters successful
    ...         Step B. 1.UE1 is attached to gnb1 Cell-11 and DRBs setup successfully, A3 mobility measconfig send to UE,
    ...                 2CC CA to the UE with Cell-12 as the SCell
    ...                 2.handover to gnb2 cell13 successfully, A3 mobility measconfig send to UE, no CA.
    ...                 3.DRB-1 delete successfully, no CA.
    ...                 4.DRB-1 add successfully, no CA.
    ...                 5.handover to gnb1 cell12 successfully, 2CC CA to the UE with Cell-11 as the SCells.
    ...                 6.DRB-3 delete successfully, no change to the CA.
    ...                 7.UE released successfully
    ...                 8.check counters successful
    ...         Step C. 1.UE1 is attached to gnb1 Cell-11 and DRBs setup successfully, A3 mobility measconfig send to UE, no A1 configured
    ...                 2.handover to gnb2 cell13 successfully, A1 configured, 3CC CA to the UE with Cell-1(ul and dl) and Cell-2 as the SCells
    ...                 3.DRB-1 delete successfully, CA release.
    ...                 4.DRB-1 add successfully, A1 configured, 3CC CA to the UE with Cell-1(ul and dl) and Cell-2 as the SCells
    ...                 5.handover to gnb1 cell11 successfully, A1 configured, 2CC CA to the UE with Cell-12 as the SCell
    ...                 6.reestablishment to gnb2 cell13 successfully, A1 configured, 3CC CA to the UE with Cell-1(ul and dl) 
    ...                 and Cell-2 as the SCells
    ...                 7.DRB-3 add successfully, CA release.
    ...                 8.DRB-2 add successfully, no change to the config.
    ...                 9.handover to gnb1 cell12 successfully, no A1 configured.
    ...                 10.DRB-2 delete successfully, A1 configured, 2CC CA to the UE with Cell-11 as the SCells
    ...                 11.check counters successful
    [Tags]    QC_46740    BC007    DL_CA_LABEL-FTT(10MHZ_FDD_n3+100MHZ_TDD_n77+40MHZ_TDD_n77)    UL_CA_LABEL-FT(10Mhz_FDD_n3+100Mhz_TDD_n77)
    Clear Counter Files for 2GNB Without Wait
    Interaction with inter gnb mobility and blind CA    qos_id=2    pass_pdu=${pdu_check_drb2}    fail_CA=${FF_CA1}    pass_ho_intra=${ho_FTT_CA}
    ...    del_drb1=${del_drb1_release_CA}    add_drb1=${add_drb1_add_CA}    pass_ho_inter=${ho_no_CA}    #inter_ho_fail_CA=${FF_CA_2}
    ...    del_drb=${del_drb2_add_CA}
    ...    PM_Counters_Check_GNB1=${PM_Counters_Check_GNB1_BC002_1}    PM_Counters_Check_GNB2=${PM_Counters_Check_GNB2_BC002_1}
    Clear Counter Files for 2GNB
    Interaction with inter gnb mobility and blind CA    qos_id=3    pass_pdu=${pdu_check_drb3}    pass_ho_intra=${ho_intra}
    ...    ho_fail_CA=${FTT_CA}    del_drb1_fail_CA=${FTT_CA}    add_drb1_fail_CA=${FTT_CA}    pass_ho_inter=${ho_add_CA}
    ...    del_drb_fail_CA=${FF_CA_2}    cell_num=1    min_dl_tput=60
    ...    PM_Counters_Check_GNB1=${PM_Counters_Check_GNB1_BC002_2}    PM_Counters_Check_GNB2=${PM_Counters_Check_GNB2_BC002_2}
    OnlineParamChange    Online_Param_gnb1=${OnlineParam_BC004_1}    Online_Param_gnb2=${OnlineParam_BC004_2}
    Interaction with inter gnb mobility and optimised A1 based CA    qos_id=2    pass_pdu=${pdu_check_drb2}    fail_CA=eventA1
    [Teardown]    BC07_Teardown

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup 2Airphone Env    fddtdd_sansa_cmwv/6cells_gnb1_2F_gnb2_2T2F

BC07_Teardown
    OnlineParamChange    Online_Param_gnb1=${OnlineParam_BC004_3}    Online_Param_gnb2=${OnlineParam_BC004_4}
    Common Test Teardown And Stop Capture Logs

Modify Cfg
    Update Cfg    ue_param id=1 ue_nr_capabilities=${SA_Capa_n3_n77_n77_3CC_DL_2CC_UL_CA}
    Update Cfg    ue_param id=2 ue_nr_capabilities=${SA_Capa_n3_n77_n77_3CC_DL_2CC_UL_CA}
    Update Cfg    amf_param id=1 full_nas_auth=on nia=null+aes nea=null+aes ims_voice_3gpp=on
    Update Cfg    ue_nr_capabilities id=1 voice_over_nr=on:on:off
    Update Cfg    set_qosflow id=1 5qi=6 default=on
    Update Cfg    set_qosflow id=2 5qi=7
    Update Cfg    set_qosflow id=3 5qi=8
    Update Cfg    set_qosflow id=4 5qi=9
    Update Cfg    set_qosrule id=1 proto=tcp qos_flow=1
    Update Cfg    set_qosrule id=2 proto=udp qos_flow=2
    Update Cfg    set_nwslice id=1 snssai=0x01:0xD143A5 qos_flows=1,2,3,4 qos_rules=1,2 default=on ue=1-6 amf=1
    Update Cfg    debug_log level=0
    Update Cfg    sim_debug_log level=0 uec=1

Clear Counter Files for 2GNB Without Wait
    Clear Counter Files    wait=${False}
    Clear Counter Files GNB2    wait=${False}

Clear Counter Files for 2GNB
    Clear Counter Files
    Clear Counter Files GNB2

Check Counters for 2GNB
    [Arguments]    ${counters_for_gnb1}    ${counters_for_gnb2}
    Check Counters    ${counters_for_gnb1}
    Check Counters GNB2    ${counters_for_gnb2}

UE PDU Session Setup with multiple Qosflows
    [Arguments]    ${ue_id}=1    ${gnb_id}=2    ${cell_id}=11    ${qos_id}=2    ${pass_pdu}=none    ${fail_CA}=none
    Execute Egate Command    ue_change_location id=${ue_id} enb=${gnb_id} cell=${cell_id}
    Execute Egate Command    smf_param id=1 additional_qosflows_to_activate=${qos_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=1    pass_regexp=${pass_pdu}
    ...    fail_regexp=${fail_CA}

A3 handover to cell
    [Arguments]    ${ue_id}=1    ${cellfreq}=368430    ${id}=62    ${pass_ho}=none    ${fail_CA}=none
    ${A3}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cellfreq}    event_type=A3
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${A3} event=A3 srsrp_nr=5 srsrq_nr=11 phycell_id=${id} nrsrp_nr=90 nrsrq_nr=80
    ...    pass_regexp=${pass_ho}    fail_regexp=${fail_CA}

DEL DRB
    [Arguments]    ${ue_id}=1    ${qos_id}=1    ${del_drb}=none    ${fail_CA}=none
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_del=${qos_id} by=amf
    ...    pass_regexp=${del_drb}    fail_regexp=${fail_CA}

ADD DRB
    [Arguments]    ${ue_id}=1    ${qos_id}=1    ${add_drb}=none    ${fail_CA}=none
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=${qos_id} by=amf
    ...    pass_regexp=${add_drb}    fail_regexp=${fail_CA}

A2 A3 handover to cell12
    [Arguments]    ${ue_id}=1    ${cellfreq}=368430    ${cellfreq2}=373970    ${pass_ho}=none    ${ho_fail_CA}=none
    ${A2}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cellfreq}    event_type=A2
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${A2} event=A2 srsrp_nr=5
    ...    pass_regexp=rrcReconfigurationComplete
    ${A3}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cellfreq2}    event_type=A3
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${A3} event=A3 srsrp_nr=5 srsrq_nr=11 phycell_id=61 nrsrp_nr=90 nrsrq_nr=80
    ...    pass_regexp=${pass_ho}    fail_regexp=${ho_fail_CA}

Interaction with inter gnb mobility and blind CA
    [Arguments]    ${qos_id}=2    ${pass_pdu}=none    ${fail_CA}=none    ${pass_ho_intra}=none    ${ho_fail_CA}=none
    ...    ${del_drb1}=QoS Routing Table    ${del_drb1_fail_CA}=none    ${add_drb1}=QoS Routing Table    ${add_drb1_fail_CA}=none
    ...    ${pass_ho_inter}=none    ${inter_ho_fail_CA}=none    ${del_drb}=QoS Routing Table    ${del_drb_fail_CA}=none
    ...    ${PM_Counters_Check_GNB1}=none    ${PM_Counters_Check_GNB2}=none
    ...    ${cell_num}=3    ${min_dl_tput}=700
    UE PDU Session Setup with multiple Qosflows    qos_id=${qos_id}    pass_pdu=${pass_pdu}    fail_CA=${fail_CA}
    A3 handover to cell    pass_ho=${pass_ho_intra}    fail_CA=${ho_fail_CA}
    DEL DRB    del_drb=${del_drb1}    fail_CA=${del_drb1_fail_CA}
    ADD DRB    add_drb=${add_drb1}    fail_CA=${add_drb1_fail_CA}
    Send Throughput
    Wait Until Keyword Succeeds    30s    5s    Check Traffic    cell_num=${cell_num}    min_dl_tput=${min_dl_tput}
    A2 A3 handover to cell12    pass_ho=${pass_ho_inter}    ho_fail_CA=${inter_ho_fail_CA}
    DEL DRB    qos_id=${qos_id}    del_drb=${del_drb}    fail_CA=${del_drb_fail_CA}
    Wait Until Keyword Succeeds    30s    5s    Check Traffic    cell_num=2    min_dl_tput=200
    Release Ues    ue_type=all
    Check Counters for 2GNB    counters_for_gnb1=${PM_Counters_Check_GNB1}    counters_for_gnb2=${PM_Counters_Check_GNB2}

Interaction with inter gnb mobility and optimised A1 based CA
    [Arguments]    ${qos_id}=2    ${pass_pdu}=none    ${fail_CA}=none
    Clear Counter Files for 2GNB
    UE PDU Session Setup with multiple Qosflows    qos_id=${qos_id}    pass_pdu=${pass_pdu}    fail_CA=${fail_CA}
    Interaction with intra frequency ho
    Interaction with rrc reestab
    Interaction with inter frequency ho
    Release Ues    ue_type=all
    Check Counters for 2GNB    counters_for_gnb1=${PM_Counters_Check_GNB1_BC004}    counters_for_gnb2=${PM_Counters_Check_GNB2_BC004}

Interaction with intra frequency ho
    A3 handover to cell    pass_ho=${ho_FTT_CA}
    DEL DRB    del_drb=${del_drb1_release_CA}
    ADD DRB    add_drb=${add_drb1_A1}
    trigger A1 scell addtion with CA add    pass_CA=${FTT_CA}
    Send Throughput
    Wait Until Keyword Succeeds    40s    5s    Check Traffic
    A3 handover to cell    id=60    pass_ho=${ho_intra_back}    fail_CA=eventA1
    DEL DRB    qos_id=2    del_drb=${del_drb2_A1}
    trigger A1 scell addtion with CA add    pass_CA=${FF_CA_1}
    Wait Until Keyword Succeeds    30s    5s    Check Traffic    cell_num=2    min_dl_tput=200

Interaction with rrc reestab
    Set RRC Reconfiguration Complete delay
    A3 handover to cell    pass_ho=${rrc_delay}
    Trigger reestablishment    pass_regexp=${reestab_intra}
    trigger A1 scell addtion with CA add    pass_CA=${FTT_CA}
    Send Throughput
    Wait Until Keyword Succeeds    30s    5s    Check Traffic

Interaction with inter frequency ho
    ADD DRB    qos_id=3    add_drb=${add_drb3_release_CA}
    ADD DRB    qos_id=2    add_drb=${add_drb2}
    A2 A3 handover to cell12    pass_ho=${ho_no_CA}    ho_fail_CA=eventA1
    DEL DRB    qos_id=2    del_drb=${del_drb2_A1}
    trigger A1 scell addtion with CA add    carrierfreq=373970    pass_CA=${FF_CA_2}
    Wait Until Keyword Succeeds    30s    5s    Check Traffic    cell_num=2    min_dl_tput=200

Set RRC Reconfiguration Complete delay
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_nr_rrc_reconf_param id=${ue_id} if_contains=any delay=3000

Trigger reestablishment
    [Arguments]    ${ue_id}=1    ${cell_id}=13    ${pass_regexp}=RRC Reestablishment sucessfully completed
    ${cmd}=    Set Variable    ue_rrc_reestablish id=${ue_id} gnb=3 cell=${cell_id} cause=reconfigurationFailure
    Execute Egate Command    ${cmd}    pass_regexp=${pass_regexp}

trigger A1 scell addtion with CA add
    [Arguments]    ${ue_id}=1    ${carrierfreq}=368430    ${srsrp_nr}=90    ${srsrq_nr}=90    ${pass_CA}=none    ${fail_CA}=none
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A1
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=${srsrp_nr} ssinr_nr=59 srsrq_nr=${srsrp_nr}
    ...    pass_regexp=${pass_CA}    fail_regexp=${fail_CA}

OnlineParamChange
    [Arguments]    ${Online_Param_gnb1}=none    ${Online_Param_gnb2}=none
    Delta Commission Parameters    ${Online_Param_gnb1}
    Cells Should Be OnAir
    Delta Commission Parameters gnb2    ${Online_Param_gnb2}
    Cells Should Be Onair GNB2

Check Traffic
    [Arguments]     ${ue_id}=1    ${cell_num}=3    ${min_dl_tput}=700    ${min_ul_tput}=8    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    ${ul_throuput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pusch    rate_type=ave
    ${total_dl_tput}    Set Variable    0
    FOR    ${index}    IN RANGE    0    ${cell_num}
         ${str_index}    Convert To String    ${index}
         ${scell_tput}    Ap Get Throuput On Specific Scell    ${ue_id}    ${str_index}    pdsch
         Should Be True    ${scell_tput}/1000 > 10
         ${total_dl_tput}    Evaluate    ${scell_tput}+${total_dl_tput}
    END
    Should Be True    ${total_dl_tput}/1000 > ${min_dl_tput}
    Should Be True    ${ul_throuput}/1000 > ${min_ul_tput}

Send Throughput
    [Arguments]    ${ue_id}=1    ${times}=5    ${qfi}=1
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=ul mbps=10 trf_id=1    UE ${ue_id}: UDP UL
    FOR    ${I}    IN RANGE    1    ${times}+1
        Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=${qfi} dir=dl mbps=150 trf_id=${I}    UE ${ue_id}: UDP DL
    END
