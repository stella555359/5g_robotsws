*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_VRF    SBTS00    RAN_5G    RAN_5G_TDD    CRT    CLOUD_5G_I_[LO][LO]_AP_[LOO]_SANSA_FS_ECPRI_CMWV_TDD
...    team-L3CN1_TA    owner-chunjian.yang    release-SBTS23R3
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${NOKIA_XNAP_PLUGIN_FLAG}    ${True}
${NOKIA_F1AP_PLUGIN_FLAG}    ${True}

@{PARAMS_IN_SCF}
...    @{PARAMS_FOR_CA}
...    @{PARAMS_FOR_GNB1}
...    @{PARAMS_ADJ_REL_FOR_GNB1}
...    @{PARAMS_FOR_OTHERS}
@{PARAMS_IN_SCF_GNB2}
...    @{PARAMS_FOR_CA}
...    @{PARAMS_FOR_GNB2}
...    @{PARAMS_ADJ_REL_FOR_GNB2}
...    @{PARAMS_FOR_OTHERS}

@{PARAMS_FOR_CA}
...    NRBTS:actCarrierAggregation=true
...    NRBTS:sCellActivationMethod=blind
...    NRBTS:caConfigurationSupport=4CCDL_2CCUL
...    NRBTS:weightForIgnbCaSelection=20
...    NRBTS:actIncXn=true
...    NRBTS:maxNumScellsDl=2
...    NRBTS:maxNumScellsUl=2
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:carrierAggregationSupportList=ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Sa,ca_Fdd_Any_Sa,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Fdd
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRDU-1:actInterGnbCa=DLOnly
...    NRDU-1:dlToUlContributionRatio=101
...    NRDU-1:xgUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRCELL:actK1Opt=intraAndInter-gNB
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based

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
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-1:gNbId=2
...    NRCELL-11/NRREL-1:gNbIdLength=22
...    NRCELL-11/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-1:lcrId=1
...    NRCELL-11/NRREL-1:removeNotAllowed=false
...    NRCELL-11/NRREL-1:sCellAdditionMethod=covBasedA1
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
...    NRCELL-11/NRREL-2:sCellAdditionMethod=covBasedA1
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
...    NRCELL-12/NRREL-14:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-14:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-14:gnbPlmn:mncLength=3
...    @{Non-split UM DRB}

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
@{PARAMS_FOR_OTHERS}


...    NRBTS:actRanSharing=false
...    NRCELL:actCDrx=false
...    NRBTS:cipherPrefL:nea0=8
...    NRBTS:cipherPrefL:nea1_128=0
...    NRBTS:cipherPrefL:nea2_128=0
...    NRBTS:cipherPrefL:nea3_128=0

@{Non-split UM DRB}
...    @{DRB_16_17}
...    @{5QI_129_254}

@{5QI_129_254}
...    MRBTS-1/NRBTS-1/NRDRB_5QI-7:fiveqiValueList=129
...    MRBTS-1/NRBTS-1/NRDRB_5QI-7:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-16
...    MRBTS-1/NRBTS-1/NRDRB_5QI-8:fiveqiValueList=254
...    MRBTS-1/NRBTS-1/NRDRB_5QI-8:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-16
@{DRB_16_17}
...    MRBTS/NRBTS/NRDRB_RLC_UM-1:dlTReassemblyUm=ms50
...    MRBTS/NRBTS/NRDRB_RLC_UM-1:rlcUMDrbSNLength=rlcUm12bitSN
...    MRBTS/NRBTS/NRDRB_RLC_UM-1:ulTReassemblyUm=ms50
...    MRBTS-1/NRBTS-1/NRDRB-16:actDddsReduction=false
...    MRBTS-1/NRBTS-1/NRDRB-16:actLostPduFastRetx=false
...    MRBTS-1/NRBTS-1/NRDRB-16:discardTimer=infinity
...    MRBTS-1/NRBTS-1/NRDRB-16:dlFlowControlAlgo=3gppFlowControl
...    MRBTS-1/NRBTS-1/NRDRB-16:dscp=0
...    MRBTS-1/NRBTS-1/NRDRB-16:endMarkerTimer=2000
...    MRBTS-1/NRBTS-1/NRDRB-16:maxDataRateGbrDl=1000
...    MRBTS-1/NRBTS-1/NRDRB-16:maxDataRateGbrUl=1000
...    MRBTS-1/NRBTS-1/NRDRB-16:maxDddsPeriodCpuOvld=40
...    MRBTS-1/NRBTS-1/NRDRB-16:maxRlcQueueingDelayGbr=20
...    MRBTS-1/NRBTS-1/NRDRB-16:maxTransferDelayGbr=20
...    MRBTS-1/NRBTS-1/NRDRB-16:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-2
...    MRBTS-1/NRBTS-1/NRDRB-16:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-2
...    MRBTS-1/NRBTS-1/NRDRB-16:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    MRBTS-1/NRBTS-1/NRDRB-16:numSduDiscard=1
...    MRBTS-1/NRBTS-1/NRDRB-16:queuingDelayDiscarding=Controlled Delay (CoDel)
...    MRBTS-1/NRBTS-1/NRDRB-16:queuingDelaySduDiscardThreshold=750
...    MRBTS-1/NRBTS-1/NRDRB-16:resType=nonGBR
...    MRBTS-1/NRBTS-1/NRDRB-16:rlcMode=RLC_UM
...    MRBTS-1/NRBTS-1/NRDRB-16:schedulWeight=1
...    MRBTS-1/NRBTS-1/NRDRB-16:sduDiscardIntervalTmr=500

#below UE capability support n3_n77_n77 FTT 3CC CA bandcombination
${SA_Capa_n3_n77_n77_3CC_CA}    SEPARATOR=
...    E9A09000575F5A13160003C320016093170019C3D09009B20C39F30C7942C0E098040623809DC6C06C0D608C21A08107482C036B64C558D
...    0E7C471E819F604F8C48E3C873EA39F30C7942C0E070F05C00FFC0070005F000540001C0A836016B04610D04083C4160195B262AC4873EC
...    09F11C78C48E3C873EA39F30C7942C0E070F09FD8000007F6000000540001C0AA36266B04610D04083A4160185B262A88873E238F11C7A0
...    67D813E31CF9863CA1607038782E007FE003801FF8002A0000E0541B06F582308682041E20B00CAD931562439F11C7B027C62471E439F51
...    CF9863CA1607038784FFF800003FFE000002A0000E0551B137582308680000100B00C2D926544439F11C79063D033EC09F00E7CC31E50B0
...    381C3C17AAAAAAA9EAAAAAAA1500007004D61E26000713000000058158B898001C4C000E260000010B02B17008003098061300004160563
...    E01000606C0C260184D0001858158B8040018020303600040B02B1F00800300C0606C0C26800142C0AC5C02000C0D8184C0003058158780
...    400184C000385815878040018020004058158783600181B000485815878040018060005058158780C00181B0005858158B8040018060303
...    6000C0B02B0F06C0038980000342C0AC5C4C000C26018020007058158F89A00184C030040606C001E160562E2600060080C0D800402C0AC
...    7C4D000C01018060303600110B02B0F1340038040800482C08048037001A0264002809A2280F509C28913639F0E2448913639F0E2448913
...    639F0E344891226C73E1C4891226C73E1C68912244D8E7C38912244D8E7C3851226C73E1C28913639F0E14489B1CF870A244D8E7C385122
...    6C73E1C4891226C73E1C28913639F0E2448913639F0E344891226C73E1C4891226C73E1C68912244D8E7C3851226C73E1801B1318C6318C
...    6318C6318C6318C7E8260078005038280381804A00E000C0480080C07C12004000000020010000000400001802000004010000040080000
...    30040000200200001401000802008020000180100000E008004000000100001000800009004000018020000280100001600800409024010
...    000180672A6B2A6B052B032B066B056B296F066F016B036B012B022B07681A0800004B29282000032CA4C080000CB29202000072CA48080
...    0024B292020000B2CA4C0800034B292020000F2CA480800044B29202000132CA480800054B29202000172CA4A0800064B29202000062CA4
...    80669555D2AAAA55174AA2A82C55058AA0D154A62A93455018AA051549AAA83C5090178095028140A05028140A05028140A05028140A050
...    281400482020040080801002201002004040080101002004402018028080100202004008C04030050100C01404008010100200440202002
...    8080800A0202C058C04030060100C014040300601002004402018028080600A020040084040300501002004202018028080600A10100C01
...    8040300608080600C02018028404030050100C014402018028080600C020180284040300601002004402004008080100202018028C04008
...    010100200404030050100C014402004008080600C02018030C04008010100C01404030060100C014202004008081200A3543E0002040608
...    0C0E1416181A2022242628303236383A3E424A4C4E5052545A5E828305A

@{PM_Counters_CE004_GNB1}
...    NRCELL-11:NCAC:${UE_PCELL_1_CONF_SCELL_DL_SA}>=1
...    NRCELL-11:NCAC:${IGNB_CA_ATT_2_SCELL_SA}=1
...    NRCELL-11:NCAC:${IGNB_CA_ATT_2_SCELL_SA_SUCC}=1
...    NRCELL-11:NCAC:${A2MEAS_REL1DLSCELL_ATT_SA}=2
...    NRCELL-11:NCAC:${A2MEAS_REL1DLSCELL_SUCC_SA}=2
...    NRCELL-11:NRRCC:${NRRCC_RRC_RECONF_SENT}=6
...    NRCELL-11:NRRCC:${NRRCC_RRC_RECONF_CMP_RECD}=6
...    NRCELL-11:NCAC:${UE_PCELL_2_CONF_SCELL_DL_SA}>0
...    NRCELL-11:NCAC:${UE_PCELL_1_CONF_SCELL_DL_SA}>0
...    NRCELL-11:RSADU:${GNB_DU_SCELL_2_ADMI_REQ_SA}=1
...    NRCELL-11:RSADU:${GNB_DU_SCELL_2_ADMI_SUCC_SA}=1
...    NRCELL-11:NNGCC:${NNGCC_PDUSESMODREQ_RECD}=2
...    NRCELL-11:NNGCC:${NNGCC_PDUSESMODRSP_SUCC_SENT}=2

@{PM_Counters_CE004_GNB2}
...    NRCELL-1:RSADU:${GNB_DU_SCELL_ADMI_REQ_SA}=1
...    NRCELL-2:RSADU:${GNB_DU_SCELL_ADMI_REQ_SA}=1
...    NRBTS-2:AGNBM:${IGNB_CA_ADD_REQ_SA_ADJ}=1

${UE_PCELL_1_CONF_SCELL_DL_SA}    M55118C05507
#The sum of samples for total number of CA UEs in the current cell configured as a PCell, which have 1 configured SCell in DL.

${GNB_DU_SCELL_ADMI_REQ_SA}    M55139C01001
#This counter is updated on the SCell if an SCell was requested which is newly added in the SCell-ToBeSetupMod-List IE
#as part of F1AP: UE CONTEXT MODIFICATION REQUEST or F1AP: UE CONTEXT SETUP REQUEST (in case of Inter gNB CA) messages
#received by the DU during SCell Addition and SCell Change procedures.

${A2MEAS_REL1DLSCELL_ATT_SA}    M55118C06501
#When RRC Reconfiguration message releasing 1 S-Cell in DL is sent to UE triggered by A2 measurement on S-Cell.
#Counter is updated on the PCell.

${A2MEAS_REL1DLSCELL_SUCC_SA}    M55118C06502
#When RRC Reconfiguration Complete message, following RRC Reconfiguration releasing 1 S-Cell in DL triggered by
#A2 measurement on S-Cell, is received.
#Counter is updated on the PCell.

${NRRCC_RRC_RECONF_SENT}    M55124C03001
#This counter provides the number of RRC: RRC RECONFIGURATION messages sent from gNB-CU.

${NRRCC_RRC_RECONF_CMP_RECD}    M55124C03002
#This counter provides the number of RRC: RRC RECONFIGURATION COMPLETE messages received at gNB-CU.

${UE_PCELL_2_CONF_SCELL_DL_SA}    M55118C07001
#The sum of total number of CA UEs in the current cell configured as a PCell, which have 2 configured SCells in DL in SA mode.

${UE_PCELL_1_CONF_SCELL_DL_SA}    M55118C05507
#Current number of PCell UEs with 1 configured SCell in DL is calculated when sample timer expires.

#This counter is updated on the PCell if exactly 2 SCells were requested which are newly added in the
#SCell-ToBeSetupMod-List IE as part of F1AP: UE CONTEXT MODIFICATION REQUEST messages received by the DU
#during SCell Addition procedure.
${GNB_DU_SCELL_2_ADMI_REQ_SA}    M55139C01501
${GNB_DU_SCELL_2_ADMI_SUCC_SA}    M55139C01502

${IGNB_CA_ATT_2_SCELL_SA}    M55118C11002
#Counted by the number of XnAP: IgNB CA ADDITION REQUEST message sent from Prime-gNB CU to ext-gNB CU to add two
#S-Cell for SA. The counter is incremented in the P-Cell.

${IGNB_CA_ATT_2_SCELL_SA_SUCC}    M55118C11005
#Counted by the number of XnAP: IgNB CA UE ADDITION REQUEST ACKNOWLEDGE message from ext-gNB CU to Prime-gNB CU
#for adding two S-Cell for SA.

${IGNB_CA_ADD_REQ_SA_ADJ}    M55199C00001
#Counted by the number of XnAP: IgNB CA ADDITION REQUEST message sent from Prime-gNB CU to ext-gNB CU to add SCell(s)
#for SA. The counter is incremented in the ext-gNB at Adjacent gNB level corresponding to the prime-gNB which sent
#the Xn message,

#This counter provides the number of NGAP: PDU SESSION RESOURCE MODIFICATION REQUEST messages received at gNB-CU.
${NNGCC_PDUSESMODREQ_RECD}    M55125C03501
${NNGCC_PDUSESMODRSP_SUCC_SENT}    M55125C03502

*** Test Cases ***
CB008140-ET-CE004_Verify_add-Modify-delete_QoS_Flow_then_a2event_scell_release_intergNBCA_without_any_CA-split_DRBs
    [Documentation]
    ...    this case is to test quirement 5G_RAN_USR_RRM_17360 merged with CB008140-CC ,A2 event for Scell release
    ...    measurementreport handling for UE with inter-gNB CA established without any CA split DRBS .
    ...    [Configuration]:
    ...    Cell id=11 gnb=2 pci=20:0 tac=200 tdd_cell=off band=n3 nr_arfcn=345000:364000 gscn=4547 chBw=15MHz
    ...    Cell id=12 gnb=2 pci=20:1 tac=200 tdd_cell=off band=n3 nr_arfcn=355000:374000 gscn=4675 chBw=15MHz
    ...    Cell id=1 gnb=3 pci=16:2 tac=200 tdd_cell=on band=n77 nr_arfcn=663400:663400 gscn=8159 chBw=100MHz
    ...    weightForSCellSelection=50
    ...    Cell id=2 gnb=3 pci=17:0 tac=200 tdd_cell=on band=n77 nr_arfcn=658000:658000 gscn=8103 chBw=40MHz
    ...    weightForSCellSelection=15
    ...    Cell id=13 gnb=3 pci=20:2 tac=200 tdd_cell=off band=n3 nr_arfcn=349400:368400 gscn=4605 chBw=10MHz
    ...    weightForSCellSelection=10
    ...    Cell id=14 gnb=3 pci=21:0 tac=200 tdd_cell=off band=n28 nr_arfcn=143400:153400 gscn=1916 chBw=15MHz
    ...    weightForSCellSelection=40
    ...    UE capability support n3+n77+n77,n3+n77+n28,not support n3+n77+n77+n28 4CC,which has higher weight than 3CC.
    ...    2.Test Case Steps:
    ...         a. UE1 Register And PDU1 Session Setup On Cell1_11, modify qos1 ,and add qos2 and qos6(non-CA split
    ...    DRBs) ,for KW "Modify traffic and check throughput" , it means after add qos2 and qos6 success, sotp some
    ...    traffic on qos1 ,and share some traffic on new qos2 and qos6
    ...         b. trigger A1 to add scell cell_13 and cell_14
    ...         c. delete CA-split DRB qos1 and qos2
    ...         d. triger A2 MR to release scell (cell_13 and cell_14) stepwise
    ...    3. Expected Results:
    ...         Step a: UE1 Register And PDU1 Session Setup Successful, qos1 modify and qos2,6 add success
    ...         Step b: UE1 A1 scell added is ok , Traffic And Throughput is OK
    ...         Step c: delete CA-split DRB qos1 and qos2 is ok , UE is still 3CC status without scell release, but only
    ...    Pcell has throughput ,as only non-CA split DRB qos6 flow existed now.
    ...         Step d: A2 release Scell stepwise is success
    [Tags]    QC_47070    CE004
    Clear Counter Files for 2GNB
    Make Normal CA SA UE
    Modify qos1 and add qos2 and qos6
    delete CA-split DRB qos1 qos2
    Check throughput for all cells after delete CA-split DRBs
    trigger A2 MR to release scell    carrierfreq=663360    scell_index=1
    trigger A2 MR to release scell    carrierfreq=657984    scell_index=2
    Check throughput for Pcell
    Release UEs    ue_type=all
    Check WireShark Log    ${CURDIR}${/}A2A_CE_004${/}a2a.ini    wait_string=UEContextRelease::10
    Check WireShark Log GNB2    ${CURDIR}${/}A2A_CE_004${/}a2a_gnb2.ini    wait_string=UEContextRelease::4
    Check Counters    ${PM_Counters_CE004_GNB1}
    Check Counters GNB2    ${PM_Counters_CE004_GNB2}

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup 2Airphone Env    fddtdd_sansa_cmwv/6cells_gnb1_2F_gnb2_2T2F

Clear Counter Files for 2GNB
    Clear Counter Files    ${False}
    Clear Counter Files GNB2

Make Normal CA SA UE
    Sa Ue Attach    cell=11    ue_cap=${SA_Capa_n3_n77_n77_3CC_CA}
    Setup pdu session with no scelladd
    trigger A1 MR to add scell    rsrp=95
    Send And Verify Throuput

Sa Ue Attach
    [Arguments]    ${cell_id}=11    ${UE_Capa}=${SA_Capa_n3_n77_n77_3CC_CA}
    ...    ${pass_regexp}=NG RM Register
    Update UE capa    1    ${UE_Capa}
    Execute Egate Command    ue_change_location id=1 enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=1    ${pass_regexp}

Setup pdu session with no scelladd
    [Arguments]    ${ue_id}=1    ${gateway}=1
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    ${ret1}=    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${gateway}
    ...    fail_regexp=sCellIndex 1
    Should Contain    ${ret1}    Setup QosFlow with QFI:1 5QI:6

Modify qos1 and add qos2 and qos6
    Execute Egate Command    qosflow_modify qos_flow=1 priority=4
    ${ret1}=    Execute Egate Command    ue_pdu_session_modify ue=1 pdu=1 qosflows_to_add=2,6 qosflows_to_modify=1 by=amf
    ...    pass_regexp=QoS Routing Table
    Should Contain    ${ret1}    Added QosFlow with QFI:3 fiveQI:129
    Should Contain    ${ret1}    Added QosFlow with QFI:2 fiveQI:5
    Modify traffic and check throughput

Modify traffic and check throughput
    [Arguments]    ${ue_id}=1    ${sleep_time}=20s
    Execute Egate Command    data_trf_stop ue=1 pdu=1 qfi=1 dir=dl trf_id=5    DL Traffic was stopped
    Execute Egate Command    data_trf_stop ue=1 pdu=1 qfi=1 dir=dl trf_id=6    DL Traffic was stopped
    Execute Egate Command    data_trf_stop ue=1 pdu=1 qfi=1 dir=dl trf_id=7    DL Traffic was stopped
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=2 dir=dl mbps=150 trf_id=5    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=2 dir=dl mbps=150 trf_id=6    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=3 dir=dl mbps=150 trf_id=7    UE ${ue_id}: UDP DL
    Check Throughput for each cell

delete CA-split DRB qos1 qos2
    ${ret2}=    Execute Egate Command    ue_pdu_session_modify ue=1 pdu=1 qosflows_to_del=1,2 by=amf
    ...    pass_regexp=rrcReconfigurationComplete
    Should Not Contain    ${ret2}    sCellToReleaseList

trigger A1 MR to add scell
    [Arguments]    ${rsrp}=95
    ${meas_id}    get_nr_meas_id_for_specific_type_and_frequency    ue_id=1    carrierfreq=363850    event_type=A1
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=1 meas_id=${meas_id} event=A1 srsrq_nr=70 srsrp_nr=${rsrp}
    ...    pass_regexp=activated successfully at airphone
    ${ret1}=    Remove String    ${ret1}    \r    \n    ${SPACE}
    Should Contain    ${ret1}    sCellToAddModList{{sCellIndex1,sCellConfigCommon{physCellId50
    Should Contain    ${ret1}    sCellIndex2,sCellConfigCommon{physCellId51

Send And Verify Throuput
    [Arguments]    ${ue_id}=1    ${sleep_time}=20s
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=3    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=4    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=5    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=6    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=7    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=ul mbps=10 trf_id=1    UE ${ue_id}: UDP UL
    Verify Throughput    ue_id=1    Tput_dl=799    Tput_ul=9

trigger A2 MR to release scell
    [Arguments]    ${carrierfreq}=663360    ${scell_index}=1
    ${meas_id}    get_nr_meas_id_for_specific_type_and_frequency    ue_id=1    carrierfreq=${carrierfreq}    event_type=A2
    ${ret2}=    Execute Egate Command    ue_measurement_send_nr id=1 meas_id=${meas_id} event=A2 scell=${scell_index} scell_rsrp=20
    ...    pass_regexp=rrcReconfigurationComplete
    Should Contain    ${ret2}    sCellToReleaseList

Update UE capa
    [Arguments]    ${ue_id}=1    ${SA_Capa_perUE_Full}=none
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full}
    Execute Egate Command    ${cmd}

Verify Throughput
    [Arguments]    ${ue_id}=1    ${Tput_dl}=865    ${Tput_ul}=9    ${sleep_time}=20s
    sleep    ${sleep_time}
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-5 type=pdsch    Throughput
    Should Not Match Regexp    ${scell_tput}    CellIndex-.*Mbps.*Mbps.*Mbps.* 0 Mbps
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

Check throughput for all cells after delete CA-split DRBs
    [Arguments]    ${ue_id}=1    ${sleep_time}=10s
    sleep    ${sleep_time}    sleep for traffic stable
    ${ret0}=    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-5 type=pdsch    pass_regexp=Average
    ${Pcell_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=current
    Should Be True    ${Pcell_tput}/1000>102
    ${scell1_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=1    type=pdsch    rate_type=current
    Should Be True    ${scell1_tput}/1000<1
    ${scell2_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=2    type=pdsch    rate_type=current
    Should Be True    ${scell2_tput}/1000<1

Check Throughput for each cell
    [Arguments]    ${ue_id}=1    ${sleep_time}=20s
    sleep    ${sleep_time}    sleep for traffic stable
    ${ret0}=    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-5 type=pdsch    pass_regexp=Average
    ${Pcell_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=current
    Should Be True    ${Pcell_tput}/1000>102
    ${scell1_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=1    type=pdsch    rate_type=current
    Should Be True    ${scell1_tput}/1000>449
    ${scell2_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=2    type=pdsch    rate_type=current
    Should Be True    ${scell2_tput}/1000>149

Check throughput for Pcell
    [Arguments]    ${ue_id}=1    ${sleep_time}=10s
    sleep    ${sleep_time}    sleep for traffic stable
    ${ret0}=    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-5 type=pdsch    pass_regexp=Average
    ${Pcell_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=current
    Should Be True    ${Pcell_tput}/1000>102

Modify Cfg
    Update Cfg    set_qosflow id=2 5qi=5
    Update Cfg    set_qosflow id=3 5qi=7
    Update Cfg    set_qosflow id=4 5qi=8
    Update Cfg    set_qosflow id=5 5qi=9
    Update Cfg    set_qosflow id=6 5qi=129
    Update Cfg    set_qosflow id=7 5qi=254
    Update Cfg    set_qosflow id=8 5qi=79
    Update Cfg    set_qosflow id=9 5qi=80
    Update Cfg    set_qosflow id=11 5qi=1
    Update Cfg    set_qosrule id=1 proto=udp qos_flow=1
    Update Cfg    set_qosrule id=2 proto=tcp qos_flow=2
    Update Cfg    set_qosrule id=3 proto=udp qos_flow=3
    Update Cfg    set_qosrule id=4 proto=tcp qos_flow=4
    Update Cfg    set_qosrule id=5 proto=udp qos_flow=5
    Update Cfg    set_qosrule id=6 proto=tcp qos_flow=6
    Update Cfg    set_qosrule id=7 proto=udp qos_flow=7
    Update Cfg    set_qosrule id=8 proto=tcp qos_flow=8
    Update Cfg    set_qosrule id=9 proto=udp qos_flow=9
    Update Cfg    set_qosrule id=11 proto=udp qos_flow=11
    Update Cfg    set_nwslice id=1 snssai=0x01:0xD143A5 default=on ue=all amf=1 qos_flows=1,2,3,4,5,6,11 qos_rules=1,2,3,4,5,6,11
    Update Cfg    set_nwslice id=2 snssai=0x01:0xD143A6 ue=all amf=1 qos_flows=1,2,6,7,8,9 qos_rules=1,2,6,7,8,9
    Update Cfg    ue_param id=1 ue_nr_capabilities=${SA_Capa_n3_n77_n77_3CC_CA}
