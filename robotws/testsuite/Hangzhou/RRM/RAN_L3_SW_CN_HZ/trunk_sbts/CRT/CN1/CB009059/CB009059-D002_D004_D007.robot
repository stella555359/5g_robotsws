*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    CRT    CLOUD_5G_I_[LO][LO]_AP_[LOO]_SANSA_FS_ECPRI_CMWV_TDD 
...    owner-zora.wang    release-SBTS24R2    team-CN1ET
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${NOKIA_XNAP_PLUGIN_FLAG}    ${True}
${NOKIA_F1AP_PLUGIN_FLAG}    ${True}

@{PARAMS_IN_SCF}
...    @{PARAMS_FOR_CA}
...    @{PARAMS_FOR_GNB1}
...    @{PARAMS_ADJ_REL_FOR_GNB1}
...    @{PARAMS_FOR_OTHERS}
...    @{PARAMS_FOR_9059}

@{PARAMS_IN_SCF_GNB2}
...    @{PARAMS_FOR_CA}
...    @{PARAMS_FOR_GNB2}
...    @{PARAMS_ADJ_REL_FOR_GNB2}
...    @{PARAMS_FOR_OTHERS}
...    @{PARAMS_FOR_9059}

@{PARAMS_FOR_9059}
...    NRBTS/NRDRB-11:cellAggrLevel=FR1 CA eligible
...    NRBTS/NRDRB-12:cellAggrLevel=Not FR1 CA eligible
...    NRBTS/NRDRB-13:cellAggrLevel=FR1 CA incompatible
...    NRBTS/NRDRB-14:cellAggrLevel=FR1 CA eligible
...    NRBTS/NRDRB-18:cellAggrLevel=Not FR1 CA eligible
...    NRBTS/NRDRB-19:cellAggrLevel=Not FR1 CA eligible
...    NRBTS/NRDRB-20:cellAggrLevel=FR1 CA eligible
...    NRBTS:actDrbProfileForCellAggrLevel=FR1_SA

@{PARAMS_FOR_CA}
...    NRBTS:actCarrierAggregation=true
...    NRBTS:sCellActivationMethod=bufferBased
...    NRBTS:actBufferBasedSCellAddition=disabled
...    NRBTS:caConfigurationSupport=4CCDL_2CCUL
...    NRBTS:weightForIgnbCaSelection=20
...    NRBTS:actIncXn=true
...    NRBTS:maxNumScellsDl=3
...    NRBTS:maxNumScellsUl=3
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:carrierAggregationSupportList=ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Sa,ca_Fdd_Any_Sa,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Fdd,ca_Fr1Tdd_Any_Sa
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRDU-1:actInterGnbCa=DLOnly
...    NRDU-1:dlToUlContributionRatio=101
...    NRDU-1:xgUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRCELL:actK1Opt=intraAndInter-gNB
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based

@{PARAMS_FOR_GNB1}
...    NRCELL:sCellDeactivationTimerGNB=infinity
...    NRCELL:nrCellType=2DL2UL
...    NRCELL-11:maxNumScellsDlFr1=3
...    NRCELL:dlMimoMode=2x2 Open Loop Spatial Multiplexing
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
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-1:gNbId=2
...    NRCELL-11/NRREL-1:gNbIdLength=22
...    NRCELL-11/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-1:lcrId=1
...    NRCELL-11/NRREL-1:removeNotAllowed=false
...    NRCELL-11/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-2:gNbId=2
...    NRCELL-11/NRREL-2:gNbIdLength=22
...    NRCELL-11/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-2:lcrId=2
...    NRCELL-11/NRREL-2:removeNotAllowed=false
...    NRCELL-11/NRREL-2:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-2:gnbPlmn:mncLength=3
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
...    NRCELL-11/NRREL-14:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-14:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-14:gNbId=2
...    NRCELL-11/NRREL-14:gNbIdLength=22
...    NRCELL-11/NRREL-14:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-14:lcrId=14
...    NRCELL-11/NRREL-14:removeNotAllowed=false
...    NRCELL-11/NRREL-14:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-14:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-14:gnbPlmn:mncLength=3
...    NRCELL-11:a1MeasSCellAddEnabled=rsrp
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=70
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=90
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-12/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-1:gNbId=2
...    NRCELL-12/NRREL-1:gNbIdLength=22
...    NRCELL-12/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-12/NRREL-1:lcrId=1
...    NRCELL-12/NRREL-1:removeNotAllowed=false
...    NRCELL-12/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-12/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-12/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-2:gNbId=2
...    NRCELL-12/NRREL-2:gNbIdLength=22
...    NRCELL-12/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-12/NRREL-2:lcrId=2
...    NRCELL-12/NRREL-2:removeNotAllowed=false
...    NRCELL-12/NRREL-2:sCellAdditionMethod=blind
...    NRCELL-12/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-12/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-13:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-13:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-13:gNbId=2
...    NRCELL-12/NRREL-13:gNbIdLength=22
...    NRCELL-12/NRREL-13:handoverAllowedSA=allowed
...    NRCELL-12/NRREL-13:lcrId=13
...    NRCELL-12/NRREL-13:removeNotAllowed=false
...    NRCELL-12/NRREL-13:sCellAdditionMethod=blind
...    NRCELL-12/NRREL-13:sCellOperationalMode=dlOnly
...    NRCELL-12/NRREL-13:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-13:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-13:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-14:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-14:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-14:gNbId=2
...    NRCELL-12/NRREL-14:gNbIdLength=22
...    NRCELL-12/NRREL-14:handoverAllowedSA=allowed
...    NRCELL-12/NRREL-14:lcrId=14
...    NRCELL-12/NRREL-14:removeNotAllowed=false
...    NRCELL-12/NRREL-14:sCellAdditionMethod=blind
...    NRCELL-12/NRREL-14:sCellOperationalMode=dlOnly
...    NRCELL-12/NRREL-14:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-14:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-14:gnbPlmn:mncLength=3

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
...    NRCELL-1:maxNumScellsDlFr1=4
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
#resource
...    NRCELLGRP-0:numberOfTransmittedSsBlocks=6 beams
...    NRCELLGRP-1:numberOfTransmittedSsBlocks=6 beams
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

...    NRCELL-2:periodicCsiAcquisition:maxCsirsNumber=4
...    NRCELL-2:periodicCsiAcquisition:csirsNumberWithinReportPeriod_Set1=4
...    NRCELL-2:periodicCsiAcquisition:csirsPower=9
...    NRCELL-2:actCellCsirsTddOnSsbBf=false
...    NRCELL-2:actCellCsiRsImTddNonBf=false
...    NRCELL-2:actCsirsMultiplexing=true
...    NRCELL-2:dlMimoMode=8x4 Closed Loop Spatial Multiplexing
...    NRCELL-2:numberOfRxBeamforming=4Rx
...    NRCELL-2:actAperCsi=true
...    NRCELL-2:actBeamforming=true
...    NRCELL-2:beamSet:basicBeamSet=beamSet_6
...    NRCELL-2:beamSet:beamsMuted=0
...    NRCELL-2:beamSet:tiltOffset=0
...    NRCELL-2:beamSet:leftEdgeAngle=60
...    NRCELL-2:beamSet:rightEdgeAngle=60

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
...    NRBTS/NRADJNRCELL-11:nrarfcn=364000
...    NRBTS/NRADJNRCELL-11:physCellId=60
...    NRBTS/NRADJNRCELL-11:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-11:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-11:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-11:ssbFrequency=363850
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

...    NRCELL-2/NRREL-11:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-11:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-11:gNbId=1
...    NRCELL-2/NRREL-11:gNbIdLength=22
...    NRCELL-2/NRREL-11:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-11:lcrId=11
...    NRCELL-2/NRREL-11:removeNotAllowed=false
...    NRCELL-2/NRREL-11:sCellAdditionMethod=blind
...    NRCELL-2/NRREL-11:sCellOperationalMode=dlOnly
...    NRCELL-2/NRREL-11:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-11:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-11:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-12:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-12:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-12:gNbId=1
...    NRCELL-2/NRREL-12:gNbIdLength=22
...    NRCELL-2/NRREL-12:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-12:lcrId=12
...    NRCELL-2/NRREL-12:removeNotAllowed=false
...    NRCELL-2/NRREL-12:sCellAdditionMethod=blind
...    NRCELL-2/NRREL-12:sCellOperationalMode=dlOnly
...    NRCELL-2/NRREL-12:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-12:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-12:gnbPlmn:mncLength=3

@{PARAMS_FOR_OTHERS}
...    NRBTS:actRanSharing=false
...    NRCELL:actCDrx=true

@{PM_Counters_D002}
...    NRCELL-11:${DL_RRC_FSCELL_REL_ATT_SA}=2
...    NRCELL-11:${DL_RRC_FSCELL_REL_SUC_SA}=2
...    NRCELL-11:${DL_RRC_FEXTSCELL_REL_ATT_SA}=2
...    NRCELL-11:${DL_RRC_FEXTSCELL_REL_SUC_SA}=2
...    NRCELL-11:${SCELL_ADDN_ALLOW_DRB_PRFL_CA}=5
...    NRCELL-11:${SCELL_ADDN_PREVENT_DRB_PRFL_CA}=2
...    NRCELL-11:${INCMP_DRB_STP_REL_SCELL_ATT_SA}=4
...    NRCELL-11:${INCMP_DRB_STP_REL_SCELL_SUC_SA}=4
...    NRCELL-11:${ELIGIBLE_DRB_REL_SCELL_ATT_SA}=0
...    NRCELL-11:${ELIGIBLE_DRB_REL_SCELL_SUC_SA}=0

@{PM_Counters_D004}
...    NRCELL-2:${DL_RRC_FSCELL_REL_ATT_SA}=2
...    NRCELL-2:${DL_RRC_FSCELL_REL_SUC_SA}=2
...    NRCELL-2:${DL_RRC_FEXTSCELL_REL_ATT_SA}=2
...    NRCELL-2:${DL_RRC_FEXTSCELL_REL_SUC_SA}=2
...    NRCELL-2:${SCELL_ADDN_ALLOW_DRB_PRFL_CA}=1
...    NRCELL-2:${SCELL_ADDN_PREVENT_DRB_PRFL_CA}=0
...    NRCELL-2:${INCMP_DRB_STP_REL_SCELL_ATT_SA}=0
...    NRCELL-2:${INCMP_DRB_STP_REL_SCELL_SUC_SA}=0
...    NRCELL-2:${ELIGIBLE_DRB_REL_SCELL_ATT_SA}=0
...    NRCELL-2:${ELIGIBLE_DRB_REL_SCELL_SUC_SA}=0

@{PM_Counters_D007}
...    NRCELL-11:${DL_RRC_FSCELL_REL_ATT_SA}=2
...    NRCELL-11:${DL_RRC_FSCELL_REL_SUC_SA}=2
...    NRCELL-11:${DL_RRC_FEXTSCELL_REL_ATT_SA}=2
...    NRCELL-11:${DL_RRC_FEXTSCELL_REL_SUC_SA}=2
...    NRCELL-11:${SCELL_ADDN_ALLOW_DRB_PRFL_CA}=1
...    NRCELL-11:${SCELL_ADDN_PREVENT_DRB_PRFL_CA}=0
...    NRCELL-11:${INCMP_DRB_STP_REL_SCELL_ATT_SA}=0
...    NRCELL-11:${INCMP_DRB_STP_REL_SCELL_SUC_SA}=0
...    NRCELL-11:${ELIGIBLE_DRB_REL_SCELL_ATT_SA}=0
...    NRCELL-11:${ELIGIBLE_DRB_REL_SCELL_SUC_SA}=0

${DL_RRC_FEXTSCELL_REL_ATT_SA}    M55118C00044
#The number of successful DL Full ext-SCell Release attempts on PCell for SA
${DL_RRC_FEXTSCELL_REL_SUC_SA}    M55118C00045
#The number of successful DL Full ext-SCell Release attempts on PCell for SA
${DL_RRC_FSCELL_REL_ATT_SA}    M55118C00042
#This counter measures the number of full SCell release attempts in DL in the PCell for SA. It considers only full SCell
#releases, partial SCell releases aren't counted. It considers both local SCells and ext-SCells.
${DL_RRC_FSCELL_REL_SUC_SA}    M55118C00043
#This counter measures the number of successful full SCell release attempts in DL in the PCell for SA. It considers only full
#SCell releases, partial SCell releases aren't counted. It considers both local SCells and ext-SCells.
${SCELL_ADDN_ALLOW_DRB_PRFL_CA}    M55125C00039
#This counter shows the number of times SCell addition is allowed for a UE due to data radio bearer (DRB) profile-based Carrier Aggregation.
${SCELL_ADDN_PREVENT_DRB_PRFL_CA}    M55125C00040
#This counter shows the number of times SCell addition is prevented for a UE due to data radio bearer (DRB) profile-based Carrier Aggregation.
${INCMP_DRB_STP_REL_SCELL_ATT_SA}    M55118C00034
# This counter measures the number of SCells to be released due to the addition of a CA-incompatible data radio bearer (DRB) in the PCell for SA.
${INCMP_DRB_STP_REL_SCELL_SUC_SA}    M55118C00035
#This counter measures the number of SCells released due to the addition of a CA-incompatible data radio bearer (DRB) in the PCell for SA.
${ELIGIBLE_DRB_REL_SCELL_ATT_SA}    M55118C00036
#This counter measures the number of SCells to be released due to the release of the last CA-eligible data radio bearer (DRB) in the PCell for SA.
${ELIGIBLE_DRB_REL_SCELL_SUC_SA}    M55118C00037
#This counter measures the number of SCells released due to the release of the last CA-eligible data radio bearer (DRB) in the PCell for SA.

${CB008140_n3_n77}    SEPARATOR=         #AB12-13_capa_nr
...    E9A09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C47013B8D80D81AC1184341020E9068036B64C558D0E7C471E819F604F8C48
...    E3C873EA39F30C7942C0E070F05C00FFC0070005F0005C0000E0541B00B582308682041E20D00656C98AB121CFB027C471E31238F21CFA8E7CC31E50B0381C3C27F6
...    000001FD800000170000381546C4CD608C21A0810748340185B262A88873E238F11C7A067D813E31CF9863CA1607038782E007FE003801FF8002E0000702A0D837AC
...    1184341020F1068032B64C55890E7C471EC09F1891C790E7D473E618F28581C0E1E13FFE00000FFF800000B80001C0EE36147FEB04610D04083A41A00DAD93156343
...    9F11C7A067D813E31238F21CFA8E7CC31E50B0381C3C17AABFFAA9EAAFFEAA17000038026B0F1300038980000002C0AC5C4C000E26000713000000858158B8040018
...    4C0309800020B02B1F008003836001C4C000E260000030B02B170080030040606C0008160563E0100060180C0D8184D0002858158B80400181B0309800060B02B0F0
...    0800309800070B02B0F00800300400080B02B0F06C00303600090B02B0F00800300C000A0B02B0F018003036000B0B02B1700800300C0606C0018160563E0D800713
...    000309806130001A160562E2600061300C01000382C0AC78020389800184C03098000F0B02B171300030040606C0020160563E2680060080C030181B0008858158F8
...    040018020309807130000090581009006E003404C800500A05D003DC270A244D8E7C38912244D8E7C38912244D8E7C38D1224489B1CF871224489B1CF871A2448913
...    639F0E2448913639F0E14489B1CF870A244D8E7C3851226C73E1C28913639F0E14489B1CF871224489B1CF870A244D8E7C38912244D8E7C38D1224489B1CF8712244
...    89B1CF871A2448913639F0E344891226C73E186C4C6318C6318C6318C6318C631FA0B800F000A070500703009401C0018090010180F8240080000000400200000008
...    0000300400000802000008010000060080000400400002802001004010040000300200001C010008000000200002001000012008000030040000500200002C010008
...    12048020000300CE54D654D60A5606560CD60AD652DE4CDE02D606D6025604560ED0341000009652504000065949810000196524040000E594901000049652404000
...    165949810000696524040001E594901000089652404000265949010000A96524040002E5949410000C96524040000C594900CD2AABA55554AA2E95455058AA0B1541
...    A2A94C55268AA031540A2A93555078A160178095028140A05028140A05028140A05028140A0502814004820200400808010022010020040400801010020044020180
...    28080100202004008C04030050100C014040080101002004402020028080800A0202C058C04030060100C014040300601002004402018028080600A0200400840403
...    00501002004202018028080600A10100C018040300608080600C02018028404030050100C014402018028080600C02018028C0403006010020040400801010020044
...    02004008080100202018028C040300501002004040080101002004402004008080600C02018030C04008010100C01404030060100C014602018028080600A0200400
...    808010023543E00020406080C0E1416181A2022242628303236383A3E424A4C4E5052545A5E828305A

@{OnlineParam_set_RAC_failure}
...    NRCELL:maxNumOfNonGBRBearersSA=1

@{OnlineParam_D002_recover}
...    NRCELL:maxNumOfNonGBRBearersSA=550

@{OnlineParam_D007_start}
...    NRBTS/NRDRB-14:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRBTS/NRDRB-14:rlcMode=RLC_UM
...    NRBTS/NRDRB_RLC_UM-1:dlTReassemblyUm=ms50
...    NRBTS/NRDRB_RLC_UM-1:rlcUMDrbSNLength=rlcUm12bitSN
...    NRBTS/NRDRB_RLC_UM-1:ulTReassemblyUm=ms50
...    NRBTS:actBufferBasedSCellAddition=oneShot_Dl_Fr1
...    NRCELL:dlSCellConfigLevel=3
...    NRCELL:dlSCellConfigLevelNum=5
...    NRCELL-11/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-2:sCellAdditionMethod=covBasedA1


@{OnlineParam_D007_SCellRelease}
...    NRBTS:actSCellReleaseForInactiveSCell=timer_based_Fr1
...    NRCELL:sCellInactivityReleaseTimer=10
...    NRBTS:actBufferBasedSCellAddition=oneShot_Dl_Fr1
...    NRCELL:dlSCellConfigLevel=3
...    NRCELL:dlSCellConfigLevelNum=5

@{5QI9_del}
...    Deleting QosFlow with QFI:2 5QI:9
...    Ue 1 PduId 1 Removed FiveQi:Qfi mapping fiveQi 9 qfi 2
...    QoS Routing Table
...    Pdu Session Resource Modify Response Message
...    rrcReconfigurationComplete

@{5QI9_add}
...    Added QosFlow with QFI:2 fiveQI:9
...    Ue 1 PduId 1 Created FiveQi:Qfi mapping fiveQi 9 qfi 2
...    QoS Routing Table
...    rrcReconfigurationComplete

@{5QI6_add}
...    Ue 1 PduId 1 Created FiveQi:Qfi mapping fiveQi 6 qfi 1
...    QoS Routing Table
...    rrcReconfigurationComplete

@{5QI8_add}
...    Added QosFlow with QFI:2 5QI:8
...    Ue 1 PduId 1 Created FiveQi:Qfi mapping fiveQi 8 qfi 2
...    QoS Routing Table
...    rrcReconfigurationComplete

@{5QI8_del}
...    Ue 1 PduId 1 Removed FiveQi:Qfi mapping fiveQi 8 qfi 2
...    QoS Routing Table
...    Pdu Session Resource Modify Response Message
...    rrcReconfigurationComplete

@{5QI8_add_fail}
...    Adding QosFlow with QFI:2 5QI:8
...    Deleted Unsuccessful QosFlow QFI:2
...    Pdu Session Resource Modify Response Message

@{5QI9_add_fail}
...    Adding QosFlow with QFI:2 5QI:9
...    Deleted Unsuccessful QosFlow QFI:2
...    Pdu Session Resource Modify Response Message

@{5QI6_del_9_add}
...    Ue 1 PduId 1 Created FiveQi:Qfi mapping fiveQi 9 qfi 2
...    Ue 1 PduId 1 Removed FiveQi:Qfi mapping fiveQi 6 qfi 1
...    Added QosFlow with QFI:2 5QI:9
...    QoS Routing Table
...    rrcReconfigurationComplete

@{5QI6_add_9_del}
...    Ue 1 PduId 1 Created FiveQi:Qfi mapping fiveQi 6 qfi 1
...    Ue 1 PduId 1 Removed FiveQi:Qfi mapping fiveQi 9 qfi 2
...    Added QosFlow with QFI:1 fiveQI:6
...    QoS Routing Table
...    rrcReconfigurationComplete

@{5QI6_del_8_del_9_add}
...    Ue 1 PduId 1 Created FiveQi:Qfi mapping fiveQi 9 qfi 3
...    Ue 1 PduId 1 Removed FiveQi:Qfi mapping fiveQi 6 qfi 1
...    Ue 1 PduId 1 Removed FiveQi:Qfi mapping fiveQi 8 qfi 2
...    Added QosFlow with QFI:3 fiveQI:9
...    QoS Routing Table
...    rrcReconfigurationComplete

@{5QI7_add}
...    Ue 1 PduId 1 Created FiveQi:Qfi mapping fiveQi 7 qfi 1
...    QoS Routing Table
...    rrcReconfigurationComplete

@{OnlineParam_D004}
...    NRBTS:actBufferBasedSCellAddition=oneShot_Dl_Fr1
...    NRCELL:dlSCellConfigLevel=3
...    NRCELL:dlSCellConfigLevelNum=5
...    NRCELL:sCellDeactivationTimerGNB=ms1280
...    NRBTS:actSCellReleaseForInactiveSCell=timer_based_Fr1
...    NRCELL:sCellInactivityReleaseTimer=10
...    NRBTS:drbRrcInactInactivityTimerSA=60

...    NRCELL:sCellGoodChannelQualityThreshold=8
...    NRCELL:sCellBadChannelQualityThreshold=4
...    NRCELL:sCellChannelEstimationPeriod=2000
...    NRBTS:sCellDeactivationBadRlqCount=1
...    NRBTS:actSCellReleaseBadSCellRlq=disabled
...    NRDU-1:actInterNumerologyCa=true
...    NRBTS:sCellExcludelistTimerFr1=20

@{actSCellReleaseBadSCellRlq_D004}
...    NRBTS:actSCellReleaseBadSCellRlq=enabled_Fr1

@{OnlineParam_D004_recover}
...    NRBTS:actSCellReleaseBadSCellRlq=disabled
...    NRBTS:actBufferBasedSCellAddition=disabled
...    NRBTS:actSCellReleaseForInactiveSCell=disabled
...    NRCELL:sCellDeactivationTimerGNB=infinity

@{5QI6_add_D004}
...    Ue 1 PduId 1 Created FiveQi:Qfi mapping fiveQi 6 qfi 2
...    QoS Routing Table
...    rrcReconfigurationComplete

*** Test Cases ***
CB009059-ET-D002_Interaction_with_inter-gNB_CA_release_when_at_least_one_CA_incompatible_DRB_session_is_setup
    [Documentation]
    ...    The purpose of this test case is to check following scenarios:This user scenario validates that for a UE with a CA eligible DRB
    ...    and CA is activated, if a new DRB is setup which is CA incompatible, CA is released. In this case, a new PDU session is setup
    ...    with DRB of type CA incompatible. CA is released for the UE.5G_RAN_USR_RRM_21582
    ...    At least 4 NRBTS/NRDRB MOC instances are configured as non-GRB types:
    ...    NRDRB ID resType Value RLC Mode cellAggrLevel Value
    ...          1 non-GBR AM 0:FR1 CA eligible
    ...          2 non-GBR AM 1:Not FR1 CA eligible
    ...          3 non-GBR AM 2:FR1 CA incompatible
    ...          4 non-GBR AM 0:FR1 CA eligible
    ...          UE1 3CC PCELL(cell1-11) SCELLs(cell2-1+cell2-2)
    ...    2.Test Case Steps:
    ...    a.UE1 attaches to Cell1-11.No PDU session is established during the UE ICS,PDU SESSION RESOURCE SETUP REQUEST to setup NRDRB-1.
    ...      The gNB configures the UE with 3CC DL CA with Cell2_1 and Cell2_2 as SCells.DRB-1 non-GBR DL data is scheduled on the PCell and SCells
    ...    b.Setup DRB-4 successfully, UE remains in CA, DRB-1 and DRB-4 non-GBR DL data is scheduled on the PCell and SCells.
    ...      release NRDRB-4 successfully,UE remains in CA, DRB-1 non-GBR DL data is scheduled on the PCell and SCells.
    ...    c.PDU release DRB-1 and add DRB-4 successfully,UE remains in CA, DRB-4 non-GBR DL data is scheduled on the PCell and SCells.
    ...    d.PDU release DRB-4 and add DRB-1 successfully,UE remains in CA, DRB-1 non-GBR DL data is scheduled on the PCell and SCells.
    ...    e.ADD incompatible DRB-3 successfully,The gNB releases SCells, DL non-GBR data for the DRB-3 and DRB-1 are scheduled on the PCell.
    ...      release CA incompatible DRB3 successfully,UE remains in CA, DRB-1 non-GBR DL data is scheduled on the PCell and SCells.
    ...      ADD incompatible DRB-3 successfully,The gNB releases SCells, DL non-GBR data for the DRB-3 and DRB-1 are scheduled on the PCell.
    ...    f.PDU SESSION RESOURCE Modify REQUEST to release NRDRB-3 and NRDRB-1 and setup NRDRB-4 message to the gNB-CU-CP.FR1 CA incompatible
    ...      DRB3 and One FR1 CA eligible DRB1 are released and One FR1 CA eligible DRB4 is established.The gNB configures the UE with
    ...      3CC DL CA with Cell2_1 and Cell2_2 as SCells.DRB-4 non-GBR DL data is scheduled on the PCell and SCells.Then Ue release.
    ...    g.online set maxNumOfNonGBRBearersSA=1.
    ...    h.UE1 attaches to Cell1-11.No PDU session is established during the UE ICS,PDU SESSION RESOURCE SETUP REQUEST to setup NRDRB-1.
    ...      The gNB configures the UE with 3CC DL CA with Cell2_1 and Cell2_2 as SCells.DRB-1 non-GBR DL data is scheduled on the PCell and SCells
    ...      setup NRDRB-3 message to the gNB-CU-CP,R1 CA incompatible DRB is NOT established due to RAC failure. scell release don't trigger.
    ...      The gNB configures the UE with 3CC DL CA with Cell2_1 and Cell2_2 as SCells.DRB-1 non-GBR DL data is scheduled on the PCell and SCells
    ...    i.UE1 attaches to Cell1-11.No PDU session is established during the UE ICS,PDU SESSION RESOURCE SETUP REQUEST to setup NRDRB-1.
    ...      The gNB configures the UE with 3CC DL CA with Cell2_1 and Cell2_2 as SCells.DRB-1 non-GBR DL data is scheduled on the PCell and SCells
    ...      setup NRDRB-4 message to the gNB-CU-CP,One FR1 CA eligible DRB is NOT established due to RAC failure.
    ...      The gNB configures the UE with 3CC DL CA with Cell2_1 and Cell2_2 as SCells.DRB-1 non-GBR DL data is scheduled on the PCell and SCells
    [Tags]    QC_345930    zora.wang    D002    CA_LABEL-FTT(15MHZ_FDD_n3+40MHZ_TDD_n77+100MHZ_TDD_n77)
    clear counter files    wait=${False}
    UE attach to Cell11 then DRB add and release
    OnlineParamChange_gNB1    ${OnlineParam_set_RAC_failure}
    UE attach to Cell11 and DRB add fail    qos_id=3    ATT_regexp=${5QI6_add}    QOS_ADD_regexp=${5QI8_add_fail}
    UE attach to Cell11 and DRB add fail    qos_id=4    ATT_regexp=${5QI6_add}    QOS_ADD_regexp=${5QI9_add_fail}
    Check Counters    pm_counters_expression=${PM_Counters_D002}
    [Teardown]    case recover D002

CB009059-ET-D004_Interaction_with_inter-gNB_CA_allowed_after_last_SCell_release_DL_buffer_monitoring_activated
    [Documentation]
    ...    The purpose of this test case is to check following scenarios:The last ext-SCell is released due to prolonged data inactivity.
    ...    After the ext-SCell Release, if the gNB is no longer in CA, the gNB activates DL buffer monitoring in the gNB-DU if at least
    ...    one FR1 CA eligible DRB is established and no FR1 CA incompatible DRB is established.
    ...    At least 4 NRBTS/NRDRB MOC instances are configured as non-GRB types:
    ...    NRDRB ID resType Value RLC Mode cellAggrLevel Value
    ...          1 non-GBR AM 0:FR1 CA eligible
    ...          2 non-GBR AM 1:Not FR1 CA eligible
    ...          3 non-GBR AM 2:FR1 CA incompatible
    ...          4 non-GBR AM 0:FR1 CA eligible
    ...          UE1 3CC PCELL(cell2-2) SCELLs(cell1-11+cell1-12)
    ...    2.Test Case Steps:
    ...    a.online set CB008311 enable.UE1 attaches to Cell2-2.setup NRDRB-2 message to the gNB-CU-CP in ICS procedure.The UE is not in CA.
    ...     All DL non-GBR data is scheduled on the PCell.
    ...    b.Setup DRB-1 successfully,The gNB-CU sends a private unacknowledged F1AP message to the gNB-DU to activate DL data buffer monitoring.
    ...     Sufficient DL data to exceed the PCell throughput is initiated for DRB-1 and DRB-2.gNB-CU receives the gNB-DU DL buffer monitoring
    ...     criterion notification.GNB configures the UE with 3CC DL CA with Cell1_11 and Cell1_12 as SCells.
    ...    c.Stop traffic for DRB2,the gNB still is in CA.Stop traffic for DRB1,the gNB releases Cell1_1. The gNB activates DL buffer monitoring
    ...     for SCell Addition in the gNB-DU.
    ...    d.online set actSCellReleaseBadSCellRlq as enabled_Fr1.Sufficient DL for DRB-1 and DRB-2.The SCell deactivated due to bad SCell RLQ.
    ...     after sCellExcludelistTimerFr1 ,check traffic status.all scell released. Check counter.
    [Tags]    zora.wang    D004    CA_LABEL-TFF(40MHZ_TDD_n77+15MHZ_FDD_n3+15MHZ_FDD_n3)
    OnlineParamChange    Online_Param_gnb1=${OnlineParam_D004}    Online_Param_gnb2=${OnlineParam_D004}
    Clear Counter Files GNB2    wait=${True}
    UE1 attach to Cell2 with DRB2 then DRB1 add
    OnlineParamChange    Online_Param_gnb1=${actSCellReleaseBadSCellRlq_D004}    Online_Param_gnb2=${actSCellReleaseBadSCellRlq_D004}
    Send Throughput    qfi=2    times=6
    Wait Until Keyword Succeeds    40s    5s    Check Traffic    dl=500
    Trigger scell bad RLQ for scell
    sleep    25s    #sleep for sCellExcludelistTimerFr1 timer to prevent Cell-1 Cell-2.DL buffer monitoring send, but no CA add trigger.
    Wait Until Keyword Succeeds    40s    5s    Verify Throughput pcell    dl=300
    Check WireShark Log GNB2    ${CURDIR}${/}A2A_D004${/}a2a.ini    wait_string=gNBCARelease::8
    Check Counters GNB2    ${PM_Counters_D004}    wait=${True}
    [Teardown]    case recover D004

CB009059-ET-D007_Interaction_with_inter-gNB_CA_CA_allowed_after_last_SCell_release_covBasedA1_SCell_Addition_method_with_RLC_UM_DRB
    [Documentation]
    ...    The purpose of this test case is to check following scenarios:SCell(s) are released due to A2 measurement report received.
    ...    After the last SCell Release the gNB activates event A1 measurement in the gNB-DU if at least one FR1 CA eligible DRB is
    ...    established and no FR1 CA incompatible DRB is established.
    ...    At least 4 NRBTS/NRDRB MOC instances are configured as non-GRB types:
    ...    NRDRB ID resType Value RLC Mode cellAggrLevel Value
    ...          1 non-GBR AM 0:FR1 CA eligible
    ...          2 non-GBR AM 1:Not FR1 CA eligible
    ...          3 non-GBR AM 2:FR1 CA incompatible
    ...          4 non-GBR UM 0:FR1 CA eligible
    ...          UE1 3CC PCELL(cell2-2) SCELLs(cell1-11+cell1-12)
    ...    2.Test Case Steps:
    ...    a.UE attaches to Cell2-2.setup DRB-2 message to the gNB-CU-CP in ICS procedure.The UE is not in CA.
    ...     All TP on the PCell.
    ...    b.Setup DRB-4 successfully,UE send A1 MR to gnb activate DL data buffer monitoring.
    ...      DRB-4 TP Over and above PCell,UE is in 3CC DL CA,A2 scell release measconfig to UE
    ...    c.online change actSCellReleaseForInactiveSCell=timer_based_Fr1 sCellInactivityReleaseTimer=10(for the SCell)
    ...    d.Stop DRB-2 TP,the gNB still is in CA,Stop DRB-4 TP,the gNB still is in CA then A2 release all scell
    ...    e.UE send A1 MR to gnb activate DL data buffer monitoring.DRBs TP Over and above PCell
    ...      UE is in 3CC DL CA,A2 scell release measconfig to UE
    ...    f.Stop DRBs TP,When the SCell inactivity release timer expires, the gNB triggers an SCell release.
    ...      The gNB activates DL buffer monitoring for SCell Addition
    [Tags]    QC_345932    Tingjian.Mao    D007    CA_LABEL-FTT(15MHZ_FDD_n3+40MHZ_TDD_n77+100MHZ_TDD_n77)
    OnlineParamChange_gNB1    Online_Param=${OnlineParam_D007_start}
    Clear Counter Files
    Verify UE 3CC with UM eligible DRB
    Verify Online Change actSCellReleaseForInactiveSCell does not work in an existing PDU
    Verify Online Change actSCellReleaseForInactiveSCell effective in the next PDU
    Check Counters    ${PM_Counters_D007}

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup 2Airphone Env    fddtdd_sansa_cmwv/6cells_gnb1_2F_gnb2_2T2F

case recover D002
    OnlineParamChange_gNB1    ${OnlineParam_D002_recover}
    Common Test Teardown And Stop Capture Logs

case recover D004
    Recover scell bad RLQ
    OnlineParamChange    Online_Param_gnb1=${OnlineParam_D004_recover}    Online_Param_gnb2=${OnlineParam_D004_recover}
    Common Test Teardown And Stop Capture Logs

Modify Cfg
    Update Cfg    ue_param id=1 ue_nr_capabilities=${CB008140_GG_Capa_2CC_3CC_4CC_n3_n28_n77_n78}
    Update Cfg    ue_param id=2 ue_nr_capabilities=${CB008140_GG_Capa_2CC_3CC_4CC_n3_n28_n77_n78}
    Update Cfg    amf_param id=1 full_nas_auth=on nia=null+aes nea=null+aes ims_voice_3gpp=on
    Update Cfg    ue_nr_capabilities id=1 voice_over_nr=on:on:off
    Update Cfg    set_qosflow id=1 5qi=6 default=on
    Update Cfg    set_qosflow id=2 5qi=7
    Update Cfg    set_qosflow id=3 5qi=8
    Update Cfg    set_qosflow id=4 5qi=9
    Update Cfg    set_qosrule id=1 proto=tcp qos_flow=1
    Update Cfg    set_qosrule id=2 proto=udp qos_flow=2
    Update Cfg    set_nwslice id=1 snssai=0x01:0xD143A5 qos_flows=1,2,3,4 qos_rules=1,2 default=on ue=1-6 amf=1

Ue register and pdu session setup
    [Arguments]    ${ue_id}=1    ${cell_id}=11    ${enb}=2    ${qos_id}=1    ${pass_regexp}=QoS Routing Table    ${fail_regexp}=none
    ...    ${ics_registration}=on
    Execute Egate Command    smf_param id=1 reset
    Execute Egate Command    amf_ue_pdu_setup_param id=1 reset
    Execute Egate Command    ue_change_location id=${ue_id} enb=${enb} cell=${cell_id}
    Execute Egate Command    amf_param id=1 send_ics_registration=${ics_registration}
    Execute Egate Command    qosflow_modify qos_flow=${qos_id} default=on
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=UE now in NG RM Registere
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    ${ret}    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${ue_id}
    ...    pass_regexp=${pass_regexp}    fail_regexp=${fail_regexp}

OnlineParamChange_gNB1
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir

OnlineParamChange
    [Arguments]    ${Online_Param_gnb1}=none    ${Online_Param_gnb2}=none
    Delta Commission Parameters    ${Online_Param_gnb1}
    Delta Commission Parameters gnb2    ${Online_Param_gnb2}
    Cells Should Be OnAir
    Cells Should Be Onair GNB2

Check Traffic
    [Arguments]     ${ue_id}=1    ${cell_num}=2    ${dl}=600    ${ul}=8
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-11 type=pdsch    Throughput
    ${ul_throuput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pusch    rate_type=ave
    ${total_dl_tput}    Set Variable    0
    FOR    ${index}    IN RANGE    0    ${cell_num}+1
         ${str_index}    Convert To String    ${index}
         ${scell_tput}    Ap Get Throuput On Specific Scell    ${ue_id}    ${str_index}    pdsch
         Should Be True    ${scell_tput}/1000 > 0
         ${total_dl_tput}    Evaluate    ${scell_tput}+${total_dl_tput}
    END
    Should Be True    ${total_dl_tput}/1000 > ${dl}
    Should Be True    ${ul_throuput}/1000 > ${ul}

Send Throughput
    [Arguments]    ${ue_id}=1    ${times}=5    ${pdu}=1    ${qfi}=1
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} dir=ul mbps=10 trf_id=1    UE ${ue_id}: UDP UL
    FOR    ${I}    IN RANGE    1    ${times}
        Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} dir=dl mbps=170 trf_id=${I}    UE ${ue_id}: UDP DL
    END

ADD QOS in same pdu
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${qos_id}=4    ${pass_regexp}=QoS Routing Table    ${fail_regexp}=none
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_add=${qos_id} by=amf
    ...    pass_regexp=${pass_regexp}    fail_regexp=${fail_regexp}

UE send A1 to add 3CC failed because there was no traffic
    [Arguments]    ${ue_id}=1    ${cellfreq}=363850    ${pass_regexp}=measurementReport
    ${A1}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cellfreq}    event_type=A1
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${A1} event=A1 srsrq_nr=70 srsrp_nr=90
    ...    pass_regexp=${pass_regexp}

Delete QOS in same pdu
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${qos_id}=4    ${pass_regexp}=QoS Routing Table
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_del=${qos_id} by=amf
    ...    pass_regexp=${pass_regexp}

trigger A2 MR to release scell
    [Arguments]    ${ue_id}=1    ${cellfreq}=663360    ${cellfreq2}=657984
    ${meas_id_scell}    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=${cellfreq}    event_type=A2
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id_scell} event=A2 scell=1 scell_rsrp=20 scell_rsrq=20
    ...    pass_regexp=rrcReconfigurationComplete
    ${meas_id_scell2}    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=${cellfreq2}    event_type=A2
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id_scell2} event=A2 scell=2 scell_rsrp=20 scell_rsrq=20
    ...    pass_regexp=rrcReconfigurationComplete
    sleep    10s    #sleep for stable traffic

Stop traffic
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${qfi}=1
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=${pdu} qfi=${qfi}    pass_regexp=Stopped Downlink Internal traffic on Ue:${ue_id}

Verify Throughput pcell
    [Arguments]     ${ue_id}=1    ${dl}=60    ${ul}=8
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-11 type=pdsch    Throughput
    ${ul_throuput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pusch    rate_type=ave
    ${dl_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=1-11 type=pdsch    fail_regexp=CellIndex-
    Should Be True    ${dl_tput}/1000 > ${dl}
    Should Be True    ${ul_throuput}/1000 > ${ul}

Verify that the UE is still at 3CC
    [Arguments]     ${ue_id}=1    ${sleep_time}=15S
    sleep    ${sleep_time}    sleep for Tput stable
    ${Pcell_Tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=current
    Should Be True    ${Pcell_tput}/1000 == 0
    ${Scell1_Tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=1    type=pdsch    rate_type=current
    Should Be True    ${Scell1_Tput}/1000 == 0
    ${Scell2_Tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=2    type=pdsch    rate_type=current
    Should Be True    ${Scell2_Tput}/1000 == 0
    ${ul_throughput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pusch    rate_type=current
    Should Be True    ${ul_throughput}/1000 == 0

Check CA Traffic for different DRB
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${qfi_id}=1    ${cell_num}=2    ${dl}=600
    Send Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=${qfi_id}
    Wait Until Keyword Succeeds    40s    5s    Check Traffic    ue_id=${ue_id}    cell_num=${cell_num}    dl=${dl}
    Stop traffic    ue_id=${ue_id}    pdu=${pdu_id}    qfi=${qfi_id}

Check Pcell Traffic for different DRB
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${qfi_id}=1    ${dl}=90    ${times}=5
    Send Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=${qfi_id}    times=${times}
    Wait Until Keyword Succeeds    40s    5s    Verify Throughput pcell    ue_id=${ue_id}    dl=${dl}
    Stop traffic    ue_id=${ue_id}    pdu=${pdu_id}    qfi=${qfi_id}

UE release DRB and add DRB in same pdu
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${qos_id_add}=4    ${qos_id_del}=1    ${qfi_id}=1    ${pass_regexp}=QoS Routing Table
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_add=${qos_id_add} qosflows_to_del=${qos_id_del} by=amf
    ...    pass_regexp=${pass_regexp}
    Check CA Traffic for different DRB    qfi_id=${qfi_id}

UE attach to Cell11 then DRB add and release
    Ue register and pdu session setup    pass_regexp=${5QI6_add}
    Check CA Traffic for different DRB    qfi_id=1
    DRB add and DRB delete    qos_id_add=4    qos_id_del=4    qfi=1    QOS_ADD_regexp=${5QI9_add}    QOS_DEL_regexp=${5QI9_del}
    UE release DRB and add DRB in same pdu    qos_id_add=4    qos_id_del=1    qfi_id=2    pass_regexp=${5QI6_del_9_add}    #step5
    UE release DRB and add DRB in same pdu    qos_id_add=1    qos_id_del=4    qfi_id=1    pass_regexp=${5QI6_add_9_del}    #step6
    CA incompatible DRB add and DRB delete
    UE release DRB and add DRB in same pdu    qos_id_add=4    qos_id_del=1,3    qfi_id=3    pass_regexp=${5QI6_del_8_del_9_add}    #step10,11
    Release Ues    ue_type=all

CA incompatible DRB add and DRB delete
    DRB3 add and Pcell traffic check
    Delete QOS in same pdu    qos_id=3    pass_regexp=${5QI8_del}
    Check CA Traffic for different DRB    qfi_id=1
    DRB3 add and Pcell traffic check

DRB add and DRB delete
    [Arguments]    ${qos_id_add}=4    ${qos_id_del}=1    ${qfi}=1    ${QOS_ADD_regexp}=${5QI9_add}    ${QOS_DEL_regexp}=${5QI9_del}
    ADD QOS in same pdu    qos_id=${qos_id_add}    pass_regexp=${QOS_ADD_regexp}
    Check CA Traffic for different DRB    qfi_id=1
    Check CA Traffic for different DRB    qfi_id=2
    Delete QOS in same pdu    qos_id=${qos_id_del}    pass_regexp=${QOS_DEL_regexp}
    Check CA Traffic for different DRB    qfi_id=${qfi}

DRB3 add and Pcell traffic check
    ADD QOS in same pdu    qos_id=3    pass_regexp=${5QI8_add}    #step9
    Check Pcell Traffic for different DRB    qfi_id=1
    Check Pcell Traffic for different DRB    qfi_id=2

UE attach to Cell11 and DRB add fail
    [Arguments]    ${qos_id}=3    ${ATT_regexp}=${5QI6_add}    ${QOS_ADD_regexp}=${5QI8_add_fail}
    Ue register and pdu session setup    pass_regexp=${ATT_regexp}
    Check CA Traffic for different DRB    qfi_id=1
    ADD QOS in same pdu    qos_id=${qos_id}    pass_regexp=${QOS_ADD_regexp}
    Check CA Traffic for different DRB    qfi_id=1
    Release Ues    ue_type=all

Update UE capa
    [Arguments]    ${ue_id}=1    ${SA_Capa_perUE_Full}=none    ${Capa_LTE}=none
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full}
    ...    dual_conn=eutra_nr ue_eutra_nr_capabilities=${Capa_LTE}
    Execute Egate Command    ${cmd}

UE1 attach to Cell2 with DRB2 then DRB1 add
    Update UE capa    ue_id=1    SA_Capa_perUE_Full=${CB008140_n3_n77}
    Ue register and pdu session setup    cell_id=2    enb=3    qos_id=2    ics_registration=off    pass_regexp=${5QI7_add}
    Check Pcell Traffic for different DRB    qfi_id=1    times=6    dl=300
    ADD QOS in same pdu    qos_id=1    pass_regexp=${5QI6_add_D004}
    Send Throughput    qfi=2    times=6
    Send Throughput    qfi=1    times=6
    Wait Until Keyword Succeeds    40s    5s    Check Traffic    dl=500
    Stop traffic    qfi=1
    sleep    2s    #sleep for traffic stop
    Wait Until Keyword Succeeds    40s    5s    Check Traffic    dl=500
    Send Throughput    qfi=1    times=6
    Stop traffic    qfi=2
    Wait Until Keyword Succeeds    70s    5s    Verify Throughput pcell    dl=300

Trigger scell bad RLQ for scell
    [Arguments]    ${ue_id}=1    ${scell_id}=1,2
    Trigger scell bad RLQ    ue_id=${ue_id}    scell_id=${scell_id}
    ${cmd}    Catenate    ue_stats_nr id=${ue_id} scell=1-11 type=pdsch
    Wait Until Keyword Succeeds    3 min    2s    Execute Egate Command    ${cmd}    fail_regexp=CellIndex-
    Recover scell bad RLQ    ue_id=${ue_id}    scell_id=${scell_id}

Trigger scell bad RLQ
    [Arguments]    ${ue_id}=1    ${scell_id}=1,2
    Execute Egate Command    bler_testmode_nr profile_id=1 target_mcs=0 num_dl_pkts=10000
    Execute Egate Command    ue_testmode_set_nr id=${ue_id} scell=${scell_id} testmode=bler action=activate profile_id=1

Recover scell bad RLQ
    [Arguments]    ${ue_id}=1    ${scell_id}=1,2
    Execute Egate Command    ue_testmode_set_nr id=${ue_id} scell=${scell_id} testmode=bler action=deactivate profile_id=1
    Execute Egate Command    bler_testmode_nr delete=true profile_id=1

Verify UE 3CC with UM eligible DRB
    Ue register and pdu session setup    qos_id=2
    Send Throughput    times=2
    Wait Until Keyword Succeeds    30s    5s    Verify Throughput pcell    dl=90
    ADD QOS in same pdu
    UE send A1 to add 3CC failed because there was no traffic
    Send Throughput    qfi=2
    Wait Until Keyword Succeeds    30s    5s    Check Traffic    dl=600

Verify Online Change actSCellReleaseForInactiveSCell does not work in an existing PDU
    OnlineParamChange    Online_Param_gnb1=${OnlineParam_D007_SCellRelease}    Online_Param_gnb2=${OnlineParam_D007_SCellRelease}
    Stop traffic
    Wait Until Keyword Succeeds    30s    5s    Check Traffic    dl=600
    Stop traffic    qfi=2
    sleep    15s    #wait sCellInactivityReleaseTimer time out
    Verify that the UE is still at 3CC
    trigger A2 MR to release scell

Verify Online Change actSCellReleaseForInactiveSCell effective in the next PDU
    UE send A1 to add 3CC failed because there was no traffic
    Send Throughput    times=2
    Send Throughput    qfi=2
    Wait Until Keyword Succeeds    30s    5s    Check Traffic    dl=600
    Stop traffic    qfi=2
    sleep    15s    #wait sCellInactivityReleaseTimer time out
    Verify Throughput pcell
    Release Ues    ue_type=all
