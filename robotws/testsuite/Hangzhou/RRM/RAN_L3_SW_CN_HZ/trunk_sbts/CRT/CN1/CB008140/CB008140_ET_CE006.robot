*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_VRF    SBTS00    RAN_5G    RAN_5G_TDD    CRT    CLOUD_5G_I_[LO][LO]_AP_[LOO]_SANSA_FS_ECPRI_CMWV_TDD
...    team-jazz    owner-dandan.chen    release-SBTS23R3
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${NOKIA_XNAP_PLUGIN_FLAG}    ${True}
${NOKIA_F1AP_PLUGIN_FLAG}    ${True}
${BTS_STARTUP_RETRY}    4
${SYSCOM_FLAG}    ${True}
@{PARAMS_IN_SCF}
...    @{PARAMS_FOR_CA}
...    @{PARAMS_FOR_GNB1}
...    @{PARAMS_ADJ_REL_FOR_GNB1}
...    @{PARAMS_FOR_OTHERS}
...    @{GNB1_A2_for_NRCELL_1}
@{PARAMS_IN_SCF_GNB2}
...    @{PARAMS_FOR_CA}
...    @{PARAMS_FOR_GNB2}
...    @{PARAMS_ADJ_REL_FOR_GNB2}
...    @{PARAMS_FOR_OTHERS}
...    @{GNB2_CA_for_NRCELL_A2rel}

@{PARAMS_FOR_CA}
...    NRBTS:actCarrierAggregation=true
...    NRBTS:sCellActivationMethod=blind
...    NRBTS:caConfigurationSupport=4CCDL_2CCUL
...    NRBTS:weightForIgnbCaSelection=20
...    NRBTS:actIncXn=true
...    NRBTS:maxNumScellsDl=2
...    NRBTS:maxNumScellsUl=2
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:actInterGnbCa=DLOnly
...    NRDU-1:dlToUlContributionRatio=101
...    NRCELL:actK1Opt=intraAndInter-gNB
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRDU-1:xgUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1

@{PARAMS_FOR_GNB1}
...    NRCELL-1:sCellDeactivationTimerGNB=infinity
...    NRCELL-1:maxNumScellsDlFr1=3
...    NRCELL-2:sCellDeactivationTimerGNB=infinity
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRDU-1:carrierAggregationSupportList=ca_Fdd_Fdd,ca_Fdd_Fr1Tdd_Sa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Any_Sa

@{PARAMS_ADJ_REL_FOR_GNB1}
...    NRBTS:actFdmEnhancedScheduling=true
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
...    NRBTS/NRADJNRCELL-3:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-3:fiveGsTac=200
...    NRBTS/NRADJNRCELL-3:gNbId=2
...    NRBTS/NRADJNRCELL-3:gNbIdLength=22
...    NRBTS/NRADJNRCELL-3:lcrId=3
...    NRBTS/NRADJNRCELL-3:nrarfcn=653400
...    NRBTS/NRADJNRCELL-3:physCellId=52
...    NRBTS/NRADJNRCELL-3:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-3:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-3:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-3:freqBandIndicatorNR=77
...    NRBTS/NRADJNRCELL-4:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-4:fiveGsTac=200
...    NRBTS/NRADJNRCELL-4:gNbId=2
...    NRBTS/NRADJNRCELL-4:gNbIdLength=22
...    NRBTS/NRADJNRCELL-4:lcrId=4
...    NRBTS/NRADJNRCELL-4:nrarfcn=648000
...    NRBTS/NRADJNRCELL-4:physCellId=53
...    NRBTS/NRADJNRCELL-4:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-4:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-4:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-4:freqBandIndicatorNR=77
...    NRBTS/NRADJNRCELL-11:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-11:fiveGsTac=200
...    NRBTS/NRADJNRCELL-11:gNbId=2
...    NRBTS/NRADJNRCELL-11:gNbIdLength=22
...    NRBTS/NRADJNRCELL-11:lcrId=11
...    NRBTS/NRADJNRCELL-11:nrarfcn=368400
...    NRBTS/NRADJNRCELL-11:physCellId=60
...    NRBTS/NRADJNRCELL-11:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-11:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-11:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-11:freqBandIndicatorNR=3
...    NRBTS/NRADJNRCELL-12:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-12:fiveGsTac=200
...    NRBTS/NRADJNRCELL-12:gNbId=2
...    NRBTS/NRADJNRCELL-12:gNbIdLength=22
...    NRBTS/NRADJNRCELL-12:lcrId=12
...    NRBTS/NRADJNRCELL-12:nrarfcn=153400
...    NRBTS/NRADJNRCELL-12:physCellId=61
...    NRBTS/NRADJNRCELL-12:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-12:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-12:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-12:freqBandIndicatorNR=28
...    NRCELL-1/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-3:gNbId=2
...    NRCELL-1/NRREL-3:gNbIdLength=22
...    NRCELL-1/NRREL-3:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-3:lcrId=3
...    NRCELL-1/NRREL-3:removeNotAllowed=false
...    NRCELL-1/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-4:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-4:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-4:gNbId=2
...    NRCELL-1/NRREL-4:gNbIdLength=22
...    NRCELL-1/NRREL-4:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-4:lcrId=4
...    NRCELL-1/NRREL-4:removeNotAllowed=false
...    NRCELL-1/NRREL-4:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-4:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-4:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-4:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-11:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-11:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-11:gNbId=2
...    NRCELL-1/NRREL-11:gNbIdLength=22
...    NRCELL-1/NRREL-11:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-11:lcrId=11
...    NRCELL-1/NRREL-11:removeNotAllowed=false
...    NRCELL-1/NRREL-11:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-11:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-11:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-11:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-12:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-12:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-12:gNbId=2
...    NRCELL-1/NRREL-12:gNbIdLength=22
...    NRCELL-1/NRREL-12:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-12:lcrId=12
...    NRCELL-1/NRREL-12:removeNotAllowed=false
...    NRCELL-1/NRREL-12:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-12:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-12:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-12:gnbPlmn:mncLength=3
...    NRCELL-1:a1MeasSCellAddEnabled=rsrp
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=2
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=70
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=80
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-1:a1MeasSCellAddSsbRsrq:a1HysteresisSCellAddSsbRsrq=0|a1TimeToTriggerSCellAddSsbRsrq=320ms
...    NRCELL-1:a1MeasSCellAddSsbRsrq:a1ThresholdSCellAddSsbRsrq=60|a1TimeToTriggerSCellAddSsbRsrq=320ms
...    NRCELL-1:pucchF3ModulationScheme=pi2bpsk
...    NRCELL-1:pucchF3MaxCodeRate=zeroDot08
...    NRCELL-1:actBeamforming=true
...    NRCELL-1:nrCellType=4DL2UL
...    NRCELL-2:actBeamforming=true
...    NRCELL-2:nrCellType=4DL2UL
...    NRDU-1:xgUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    @{OnlineParam_CE}
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1

@{PARAMS_FOR_GNB2}
...    NRBTS:actFdmEnhancedScheduling=true
...    NRBTS:iGnbCaXnCfUpBackOffTmr=60
...    NRBTS:iGnbCaXnSetupReqTmr=90
...    NRBTS:iGnbCaXnSetupRespTmr=60
...    NRBTS:intGnbScellTempBlockTmr=60
...    NRCELL-3:sCellDeactivationTimerGNB=infinity
...    NRCELL-4:sCellDeactivationTimerGNB=infinity
...    NRCELL-11:sCellDeactivationTimerGNB=infinity
...    NRCELL-12:sCellDeactivationTimerGNB=infinity
...    NRCELL-3:weightForSCellSelection=10
...    NRCELL-4:weightForSCellSelection=30
...    NRCELL-11:weightForSCellSelection=50
...    NRCELL-12:weightForSCellSelection=60
...    NRCELL-11:measGapSelectionSA=favourUeThroughput
...    NRDU-1:actConnectedModeMobilityCA=false
...    NRDU-1:carrierAggregationSupportList=ca_Fdd_Fdd,ca_Fdd_Fr1Tdd_Sa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa
...    NRCELL-4:actBeamforming=true
...    NRCELL-4:nrCellType=4DL2UL
...    NRCELL-3:actBeamforming=true
...    NRCELL-3:nrCellType=4DL2UL

...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1

@{PARAMS_ADJ_REL_FOR_GNB2}
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
...    NRBTS/NRADJNRCELL-1:gNbId=1
...    NRBTS/NRADJNRCELL-1:gNbIdLength=22
...    NRBTS/NRADJNRCELL-1:lcrId=1
...    NRBTS/NRADJNRCELL-1:nrarfcn=663400
...    NRBTS/NRADJNRCELL-1:physCellId=50
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-1:ssbFrequency=663360
...    NRBTS/NRADJNRCELL-1:freqBandIndicatorNR=77
...    NRBTS/NRADJNRCELL-2:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-2:fiveGsTac=200
...    NRBTS/NRADJNRCELL-2:gNbId=1
...    NRBTS/NRADJNRCELL-2:gNbIdLength=22
...    NRBTS/NRADJNRCELL-2:lcrId=2
...    NRBTS/NRADJNRCELL-2:nrarfcn=658000
...    NRBTS/NRADJNRCELL-2:physCellId=51
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-2:ssbFrequency=657984
...    NRBTS/NRADJNRCELL-2:freqBandIndicatorNR=77

@{PARAMS_FOR_OTHERS}


...    NRBTS:actRanSharing=false
...    NRCELL:actCDrx=false
...    NRBTS:cipherPrefL:nea0=8
...    NRBTS:cipherPrefL:nea1_128=0
...    NRBTS:cipherPrefL:nea2_128=0
...    NRBTS:cipherPrefL:nea3_128=0

@{GNB2_CA_for_NRCELL_A2rel}
...    NRCELL-4:a2MeasSCellRelEnabled=rsrp
...    NRCELL-4:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-4:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=33|a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-4:a2MeasSCellRelSsbRsrq:a2HysteresisSCellRelSsbRsrq=0|a2TimeToTriggerSCellRelSsbRsrq=0ms
...    NRCELL-4:a2MeasSCellRelSsbRsrq:a2ThresholdSCellRelSsbRsrq=23|a2TimeToTriggerSCellRelSsbRsrq=0ms
...    NRCELL-11:a2MeasSCellRelEnabled=rsrq
...    NRCELL-11:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-11:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=31|a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-11:a2MeasSCellRelSsbRsrq:a2HysteresisSCellRelSsbRsrq=0|a2TimeToTriggerSCellRelSsbRsrq=0ms
...    NRCELL-11:a2MeasSCellRelSsbRsrq:a2ThresholdSCellRelSsbRsrq=21|a2TimeToTriggerSCellRelSsbRsrq=0ms
...    NRCELL-12:a2MeasSCellRelEnabled=rsrpAndRsrq
...    NRCELL-12:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-12:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=32|a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-12:a2MeasSCellRelSsbRsrq:a2HysteresisSCellRelSsbRsrq=0|a2TimeToTriggerSCellRelSsbRsrq=0ms
...    NRCELL-12:a2MeasSCellRelSsbRsrq:a2ThresholdSCellRelSsbRsrq=22|a2TimeToTriggerSCellRelSsbRsrq=0ms

@{GNB1_A2_for_NRCELL_1}
...    NRCELL-1:a2MeasSCellRelEnabled=rsrq
...    NRCELL-1:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=5120ms
...    NRCELL-1:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=50|a2TimeToTriggerSCellRelSsbRsrp=5120ms
...    NRCELL-1:a2MeasSCellRelSsbRsrq:a2HysteresisSCellRelSsbRsrq=0|a2TimeToTriggerSCellRelSsbRsrq=5120ms
...    NRCELL-1:a2MeasSCellRelSsbRsrq:a2ThresholdSCellRelSsbRsrq=35|a2TimeToTriggerSCellRelSsbRsrq=5120ms

@{OnlineParam_CE}
...    @{DRB_16_17}
...    @{5QI_129_254}

@{5QI_129_254}
...    MRBTS-1/NRBTS-1/NRDRB_5QI-7:fiveqiValueList=129
...    MRBTS-1/NRBTS-1/NRDRB_5QI-7:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-16
...    MRBTS-1/NRBTS-1/NRDRB_5QI-8:fiveqiValueList=254
...    MRBTS-1/NRBTS-1/NRDRB_5QI-8:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-16
@{DRB_16_17}
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

${SA_Capa_Support_CA_with_Rankchange}    SEPARATOR=
...    E9A09000575F5A13160003C1A00B0498B800CE1E82813641873E618F28581C130080C47013B8D80D81AC1184341020E90186D6C98AB1A1CF
...    88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE0005800702A0D805AC1184341020F1018656C98AB121CFB027C471
...    E31238F21CFA8E7CC31E50B0381C3C27F6000001FD8000000B000E0551B133582308682041D2030C2D931544439F11C788E3D033EC09F18E
...    7CC31E50B0381C3C17003FF001C00FFC000B000E0541B06F582308682041E2030CAD931562439F11C7B027C62471E439F51CF9863CA16070
...    38784FFF800003FFE0000016001C0AA3626EB04610D000002006185B24CA88873E238F20C7A067D813E01CF9863CA1607038782F55555553
...    D555555416001C012587898001C4C000000160562E2600071300038980000042C0AC5C02000C260184C0001058158F80400181B030980613
...    00006160562E0100060080C0D800102C0AC7C02000C030181B0309A00050B02B1700800303606130000C160561E010006130000E160561E0
...    100060080010160561E0D800606C0012160561E0100060180014160561E03000606C0016160562E0100060180C0D800302C0AC3C1B000E26
...    00000D0B02B1713000309806008001C160563E2600061300C010181B0007858158B8980018020303600100B02B1F134003004060180C0D80
...    0442C08048037001A0264002809A0E9D212851226C73E1C4891226C73E1C4891226C73E1C68912244D8E7C38912244D8E7C38D1224489B1C
...    F871224489B1CF870A244D8E7C3851226C73E1C28913639F0E14489B1CF870A244D8E7C38912244D8E7C3851226C73E1C4891226C73E1C68
...    912244D8E7C38912244D8E7C38D1224489B1CF8603624318C6318C6318C6318C63183D04C00F000A07050070300740380030120020301F04
...    8010000000080040000001000002008000010040000100200000C01000008008000050040020080200800006004000038020010000000400
...    004002000024010000060080000A004000058020010240900400006019CA9BCA9AC14AC0CAC19AC15ACA5BC99BC05AC0DAC04AC08AC1DA06
...    82000012CA4A080000CB29202000032CA48080001CB29202000092CA48080002CB293020000D2CA48080003CB29202000112CA48080004CB
...    29202000152CA48080005CB29282000192CA480800018B292019A55574AA2A9545D2A8AA0B154162A83455298AA4D154062A8145526AAA0F
...    1414178095028140A05028140A05028140A05028140A05028140044202004008080100220100200404008010100200440201802808010020
...    2004008C04030050100C014040080101002004402020028080800A0202C058C04030060100C014040300601002004402018028080600A020
...    040084040300501002004202018028080600A10100C018040300608080600C02018028404030050100C014402018028080600C0201802840
...    40300601002004402004008080100202018028C04010020100400804030050100C014402004008080600C02018030C04008010100C014040
...    30060100C0146A87C0004080C10181C282C30344044484C5060646C70747C8494989CA0A4A8B4BD05060B4

@{PM_Counters_CD002_GNB1}
...    NRCELL-1:RSADU:${GNB_DU_SCELL_1_ADMI_REQ_SA}=0
...    NRCELL-1:RSADU:${GNB_DU_SCELL_1_ADMI_SUCC_SA}=0
...    NRCELL-1:NCAC:${UE_PCELL_1_CONF_SCELL_DL_SA}=0
...    NRCELL-1:NCAC:${A2MEAS_REL1DLSCELL_ATT_SA}=1
...    NRCELL-1:NCAC:${A2MEAS_REL1DLSCELL_SUCC_SA}=1
...    NRCELL-1:NCAC:${A2MEAS_IMMEDIATE_REL_SCELL}=0
...    NRCELL-1:NRRCC:${NRRCC_RRC_RECONF_SENT}=10
...    NRCELL-1:NRRCC:${NRRCC_RRC_RECONF_CMP_RECD}=10
...    NRCELL-1:NCAC:${UE_PCELL_3_CONF_SCELL_DL_SA}>0
...    NRCELL-1:NCAC:${UE_PCELL_2_CONF_SCELL_DL_SA}>0
...    NRCELL-1:RSADU:${GNB_DU_SCELL_3_ADMI_REQ_SA}=1
...    NRCELL-1:RSADU:${GNB_DU_SCELL_3_ADMI_SUCC_SA}=1
...    NRCELL-1:NNGCC:${NNGCC_PDUSESMODREQ_RECD}=5
...    NRCELL-1:NNGCC:${NNGCC_PDUSESMODRSP_SUCC_SENT}=5

...    NRCELL-1:NCAC:${IGNB_CA_ATT_1_SCELL_SA}=0
...    NRCELL-1:NCAC:${IGNB_CA_ATT_SA_REJ}=0
...    NRCELL-1:NCAC:${IGNB_CA_ATT_1_SCELL_SA_SUCC}=0

...    NRCELL-1:NCAC:${IGNB_CA_ATT_3_SCELL_SA}=1
...    NRCELL-1:NCAC:${IGNB_CA_ATT_3_SCELL_SA_SUCC}=1

@{PM_Counters_CD002_GNB2}
...    NRCELL-4:RSADU:${GNB_DU_SCELL_ADMI_REQ_SA}=1
...    NRCELL-11:RSADU:${GNB_DU_SCELL_ADMI_REQ_SA}=1
...    NRCELL-12:RSADU:${GNB_DU_SCELL_ADMI_REQ_SA}=1
...    NRCELL-4:RSADU:${GNB_DU_SCELL_ADMI_SUCC_SA}=1
...    NRCELL-11:RSADU:${GNB_DU_SCELL_ADMI_SUCC_SA}=1
...    NRCELL-12:RSADU:${GNB_DU_SCELL_ADMI_SUCC_SA}=1
...    NRBTS-2:AGNBM:${IGNB_CA_ADD_REQ_SA_ADJ}=1
...    NRCELL-4:RSACU:${IGNB_CA_SCELL_ADMI_REQ_SA}=1
...    NRCELL-4:RSACU:${IGNB_CA_SCELL_ADMI_SUCC_SA}=1
...    NRCELL-11:RSACU:${IGNB_CA_SCELL_ADMI_REQ_SA}=1
...    NRCELL-11:RSACU:${IGNB_CA_SCELL_ADMI_SUCC_SA}=1
...    NRCELL-12:RSACU:${IGNB_CA_SCELL_ADMI_REQ_SA}=1
...    NRCELL-12:RSACU:${IGNB_CA_SCELL_ADMI_SUCC_SA}=1
...    NRBTS-2:AGNBM:${IGNB_CA_ADD_REQ_SA_REJ_NRADJ}=0

${IGNB_CA_ADD_REQ_SA_ADJ}    M55199C00001
${IGNB_CA_ATT_3_SCELL_SA}    M55118C11003
${IGNB_CA_ATT_3_SCELL_SA_SUCC}    M55118C11006
${IGNB_CA_SCELL_ADMI_REQ_SA}    M55138C03501
${IGNB_CA_SCELL_ADMI_SUCC_SA}    M55138C03502

${IGNB_CA_ATT_1_SCELL_SA}    M55118C11001
${IGNB_CA_ATT_SA_REJ}    M55118C11007
${IGNB_CA_ATT_1_SCELL_SA_SUCC}    M55118C11004
${IGNB_CA_ADD_REQ_SA_REJ_NRADJ}    M55199C00002

#This counter provides the number of NGAP: PDU SESSION RESOURCE MODIFICATION REQUEST messages received at gNB-CU.
${NNGCC_PDUSESMODREQ_RECD}    M55125C03501
${NNGCC_PDUSESMODRSP_SUCC_SENT}    M55125C03502

#This counter is updated on the PCell if exactly 3 SCells were requested which are newly added in the
#SCell-ToBeSetupMod-List IE as part of F1AP: UE CONTEXT MODIFICATION REQUEST messages received by the DU
#during SCell Addition procedure.
${GNB_DU_SCELL_3_ADMI_REQ_SA}    M55139C03001
${GNB_DU_SCELL_3_ADMI_SUCC_SA}    M55139C03002

#Sum of CA UEs in the current cell configured as a S-Cell, which have three configured S-Cell in DL
${UE_PCELL_1_CONF_SCELL_DL_SA}    M55118C05507
${GNB_DU_SCELL_ADMI_REQ_SA}    M55139C01001
${GNB_DU_SCELL_ADMI_SUCC_SA}    M55139C01002
#This counter is updated on the SCell if an SCell was requested which is newly added in the SCell-ToBeSetupMod-List IE
#as part of F1AP: UE CONTEXT MODIFICATION REQUEST or F1AP: UE CONTEXT SETUP REQUEST (in case of Inter gNB CA) messages
#received by the DU during SCell Addition and SCell Change procedures.

${GNB_DU_SCELL_1_ADMI_REQ_SA}    M55139C01003
#This counter is updated on the PCell if exactly 1 SCell was requested which is newly added in the
#SCell-ToBeSetupMod-List IE as part of F1AP: UE CONTEXT MODIFICATION REQUEST messages received by the DU during SCell
#Addition and SCell Change procedures.

${GNB_DU_SCELL_1_ADMI_SUCC_SA}    M55139C01004
#This counter is updated on the PCell if exactly 1 SCell was admitted which is newly added as part of F1AP: UE CONTEXT
#MODIFICATION REQUEST messages received by the DU during SCell Addition and SCell Change procedures.

${A2MEAS_REL1DLSCELL_ATT_SA}    M55118C06501
#When RRC Reconfiguration message releasing 1 S-Cell in DL is sent to UE triggered by A2 measurement on S-Cell.
#Counter is updated on the PCell.

${A2MEAS_REL1DLSCELL_SUCC_SA}    M55118C06502
#When RRC Reconfiguration Complete message, following RRC Reconfiguration releasing 1 S-Cell in DL triggered by
#A2 measurement on S-Cell, is received.
#Counter is updated on the PCell.

${A2MEAS_IMMEDIATE_REL_SCELL}    M55118C06505
#When RRC Reconfiguration message releasing S-Cell is sent to UE triggered by A2 measurement on
#S-Cell immediately (within A2 timeToTrigger and short additional wait time) upon S-Cell addition.

${NRRCC_RRC_RECONF_SENT}    M55124C03001
#This counter provides the number of RRC: RRC RECONFIGURATION messages sent from gNB-CU.

${NRRCC_RRC_RECONF_CMP_RECD}    M55124C03002
#This counter provides the number of RRC: RRC RECONFIGURATION COMPLETE messages received at gNB-CU.

${UE_PCELL_3_CONF_SCELL_DL_SA}    M55118C09501
#The total number of CA UEs in the current cell configured as a PCell, which have exactly 3 configured SCells in DL in SA mode.

${UE_PCELL_2_CONF_SCELL_DL_SA}    M55118C07001
#The sum of total number of CA UEs in the current cell configured as a PCell, which have 2 configured SCells in DL in SA mode.

${UE_PCELL_1_CONF_SCELL_DL_SA}    M55118C05507
#Current number of PCell UEs with 1 configured SCell in DL is calculated when sample timer expires.

*** Test Cases ***
CB008140-ET-CE006_Verify_Add_QoS_Flow_with_oneUE_igNBCA_4cc_TTFF_after_partially_scell_release_then_modify_QoS_flow
    [Documentation]
    ...    This case is to Verify 4CC add and delete QoS Flow, interwork with partially release then modify qos flow again.
    ...    [Configuration]:
    ...    Cell id=1 gnb=2 pci=16:2 tac=200 tdd_cell=on band=n77 nr_arfcn=663400:663400 gscn=8159 chBw=100MHz ssb=663360
    ...    Cell id=2 gnb=2 pci=17:0 tac=200 tdd_cell=on band=n77 nr_arfcn=658000:658000 gscn=8103 chBw=40MHz ssb=657984
    ...    Cell id=3 gnb=3 pci=17:1 tac=200 tdd_cell=on band=n77 nr_arfcn=653400:653400 gscn=8072 chBw=100MHz ssb=655008
    ...    Cell id=4 gnb=3 pci=17:2 tac=200 tdd_cell=on band=n77 nr_arfcn=648000:648000 gscn=8000 chBw=40MHz ssb=648096
    ...    Cell id=11 gnb=3 pci=20:0 tac=200 tdd_cell=off band=n3 nr_arfcn=349400:368400 gscn=4605 chBw=10MHz ssb=663360
    ...    Cell id=12 gnb=3 pci=20:1 tac=200 tdd_cell=off band=n28 nr_arfcn=143400:153400 gscn=1916 chBw=15MHz ssb=657984
    ...    2.Test Case Steps:
    ...         a. UE1 Register And PDU1 Session Setup On NRCELL-1
    ...         b. Trigger A1 to add 3scells nrcell-4 nrcell-11 nrcell-12
    ...         c. setup PDU2 session for UE1
    ...         d. UE1 Start Traffic And Verify Throughput
    ...         e. Modify Pdu1 addqos3 and pdu2 del3 And Verify Throughput
    ...         f. trigger A2 MR to stepwise release one scell And Verify Throughput
    ...         g. Modify pdu2 qos1 to pri4 And Verify Throughput
    ...         h. Modify Pdu1 delqos3 and pdu2 add3 And Verify Throughput
    ...         i. release call
    [Tags]    QC_47071    CE006
    Clear Counter Files    wait=False
    Clear Counter Files GNB2
    Make Normal CA SA UE with PDU qos modify and scell release
    Check WireShark Log    ${CURDIR}${/}A2A_CE_006${/}a2a.ini    wait_string=UEContextRelease::10
    Check WireShark Log GNB2    ${CURDIR}${/}A2A_CE_006${/}a2a_gnb2.ini    wait_string=UEContextRelease::4
    Check Counters    ${PM_Counters_CD002_GNB1}
    Check Counters GNB2    ${PM_Counters_CD002_GNB2}
    Check userstop cause shall be correct

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup 2Airphone Env    fddtdd_sansa_cmwv/6cells_gnb1_2T_gnb2_2T2F

Make Normal CA SA UE with PDU qos modify and scell release
    Sa Ue Attach    ue_id=1    gateway=1    enb_id=2    cell_id=1
    Setup pdu1 session with no scelladd
    trigger A1 MR to add scell    rsrp=85
    Setup pdu2 session after with scelladd
    Send And Verify Throuput    ue_id=1    sleep_time=5s
    Modify Pdu1 addqos3 and pdu2 del3
    trigger A2 MR to release one scell
    Modify pdu2 qos1 to pri4
    Modify Pdu1 delqos3 and pdu2 add3
    UE Deregister From gNB    ue_id=1

Modify Pdu1 addqos3 and pdu2 del3
    Execute Egate Command    data_trf_stop ue=1 pdu=2 qfi=2 dir=dl trf_id=6    DL Traffic was stopped
    Verify Throuput on Pscell    sleep_time=2s    scell1_expectTP=100    scell2_expectTP=15    scell3_expectTP=35    pcell_TP=420
    ${ret1}=    Execute Egate Command    ue_pdu_session_modify ue=1 pdu=1 qosflows_to_add=3 pdu=2 qosflows_to_del=3 by=amf
    ...    pass_regexp=Adding QosFlow with QFI:3 5QI:7
    Should Contain    ${ret1}    Adding QosFlow with QFI:3 5QI:7
    Should Contain    ${ret1}    Deleting QosFlow with QFI:2 5QI:7
    Verify Throuput on Pscell    sleep_time=25s    scell1_expectTP=100    scell2_expectTP=15    scell3_expectTP=35    pcell_TP=420
    Execute Egate Command    data_trf_start ue=1 pdu=1 qfi=3 dir=dl mbps=150 trf_id=6    UDP DL TRF
    Verify Throuput on Pscell    sleep_time=2s    scell1_expectTP=150    scell2_expectTP=35    scell3_expectTP=55    pcell_TP=440

Modify pdu2 qos1 to pri4
    Execute Egate Command    qosflow_modify qos_flow=1 priority=4
    Execute Egate Command    ue_pdu_session_modify ue=1 pdu=2 qosflows_to_modify=1 by=amf    PDU SESSION RESOURCE MODIFY RESPONSE
    Check throught for 2scells    ue_id=1    sleep_time=10s    s1_id=2    s1_tp=50    s2_id=3    s2_tp=80    pcell_tp=500

Modify Pdu1 delqos3 and pdu2 add3
    Execute Egate Command    data_trf_stop ue=1 pdu=1 qfi=3 dir=dl trf_id=6    DL Traffic was stopped
    Check throught for 2scells    ue_id=1    sleep_time=10s    s1_id=2    s1_tp=30    s2_id=3    s2_tp=50    pcell_tp=450
    ${ret1}=    Execute Egate Command    ue_pdu_session_modify ue=1 pdu=1 qosflows_to_del=3 pdu=2 qosflows_to_add=3 by=amf
    ...    Deleting QosFlow
    Should Contain    ${ret1}    Deleting QosFlow with QFI:3 5QI:7
    Should Contain    ${ret1}    Adding QosFlow with QFI:2 5QI:7
    Check throught for 2scells    ue_id=1    sleep_time=10s    s1_id=2    s1_tp=30    s2_id=3    s2_tp=50    pcell_tp=450

trigger A1 MR to add scell
    [Arguments]    ${rsrp}=80
    ${meas_id}    get_nr_meas_id_for_specific_type_and_frequency    ue_id=1    carrierfreq=663360    event_type=A1
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=1 meas_id=${meas_id} event=A1 srsrq_nr=70 srsrp_nr=${rsrp}
    ...    pass_regexp=sCellIndex 1
    Should Contain    ${ret1}    physCellId 53
    Should Contain    ${ret1}    physCellId 60
    Should Contain    ${ret1}    physCellId 61

trigger A2 MR to release one scell
    stop some traffic
    ${meas_id_scell1}    get_nr_meas_id_for_specific_type_and_frequency    ue_id=1    carrierfreq=648096    event_type=A2
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=1 meas_id=${meas_id_scell1} event=A2 scell=1 scell_rsrp=20 scell_rsrq=20
    ...    pass_regexp=rrcReconfigurationComplete
    Should Contain    ${ret1}    sCellToReleaseList
    Check throught for 2scells    ue_id=1    sleep_time=10s    s1_id=2    s1_tp=50    s2_id=3    s2_tp=80    pcell_tp=500

stop some traffic
    Execute Egate Command    data_trf_stop ue=1 pdu=1 qfi=1 dir=dl trf_id=2    DL Traffic was stopped
    sleep    4s    sleep for traffic stable

Check throught for 2scells
    [Arguments]    ${ue_id}=1    ${sleep_time}=30s    ${s1_id}=1    ${s1_tp}=40    ${s2_id}=2    ${s2_tp}=60
    ...    ${pcell_tp}=400
    sleep    ${sleep_time}    sleep for traffic stable
    ${ret0}=    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-5 type=pdsch    pass_regexp=Average
    ${scellN1_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${s1_id}    type=pdsch    rate_type=current
    Should Be True    ${scellN1_tput}/1000>${s1_tp}
    ${scellN2_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${s2_id}    type=pdsch    rate_type=current
    Should Be True    ${scellN2_tput}/1000>${s2_tp}
    Verify Throuput on Pscell for common dlul    sleep_time=10s    expect_dl_TP=${pcell_tp}

Sa Ue Attach
    [Arguments]    ${ue_id}=1    ${gateway}=1    ${enb_id}=2    ${cell_id}=2
    ...    ${pass_regexp}=NG RM Register
    Execute Egate Command    sim_debug_log level=4
    Execute Egate Command    ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    ${pass_regexp}

Setup pdu1 session with no scelladd
    [Arguments]    ${ue_id}=1    ${gateway}=1
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${gateway}    fail_regexp=sCellIndex 1
    Execute Egate Command    ue_pdu_session_modify ue=1 pdu=1 qosflows_to_add=2 by=amf    pass_regexp=QFI:2 5QI:5

Setup pdu2 session after with scelladd
    [Arguments]    ${ue_id}=1    ${gateway}=2
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=2 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=2 nwslice=1 gw=${gateway}    fail_regexp=sCellIndex 1
    Execute Egate Command    ue_pdu_session_modify ue=1 pdu=2 qosflows_to_add=3,4 by=amf    pass_regexp=QFI:2 5QI:7
    ...    pass_regexp=QFI:3 5QI:8

Send And Verify Throuput
    [Arguments]    ${ue_id}=1    ${sleep_time}=5s
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=ul mbps=10 trf_id=1    UE ${ue_id}: UDP UL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=50 trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=3    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=4    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=2 qfi=1 dir=ul mbps=10 trf_id=2    UE ${ue_id}: UDP
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=2 qfi=1 dir=dl mbps=150 trf_id=5    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=2 qfi=2 dir=dl mbps=150 trf_id=6    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=2 qfi=3 dir=dl mbps=150 trf_id=7    UE ${ue_id}: UDP DL
    Verify Throuput on Pscell    sleep_time=${sleep_time}    scell1_expectTP=140    scell2_expectTP=30    scell3_expectTP=50    pcell_TP=480

Verify Throuput on Pscell
    [Arguments]    ${ue_id}=1    ${sleep_time}=30s    ${scell1_expectTP}=80    ${scell2_expectTP}=15    ${scell3_expectTP}=25
    ...    ${pcell_TP}=480
    sleep    ${sleep_time}    sleep for traffic stable
    ${ret0}=    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-5 type=pdsch    pass_regexp=Average
    ${scell1_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=1    type=pdsch    rate_type=ave
    Should Be True    ${scell1_tput}/1000>60
    ${scell2_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=2    type=pdsch    rate_type=ave
    Should Be True    ${scell2_tput}/1000>15
    ${scell3_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=3    type=pdsch    rate_type=ave
    Should Be True    ${scell3_tput}/1000>20
    Verify Throuput on Pscell for common dlul    sleep_time=0s    expect_dl_TP=${pcell_TP}

Verify Throuput on Pscell for common dlul
    [Arguments]    ${ue_id}=1    ${sleep_time}=0s    ${expect_dl_TP}=350
    sleep    ${sleep_time}    sleep for traffic stable
    ${pcell_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${pcell_tput}/1000>${expect_dl_TP}
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${ul_throughput}/1000>8
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=2    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${ul_throughput}/1000>8

UE Deregister From gNB
    [Arguments]    ${ue_id}
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=1    Traffic was stopped
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=2    Traffic was stopped
    Execute Egate Command    ue_pdu_session_release ue=${ue_id} pdu=1    Successfully released PDU Session
    Execute Egate Command    ue_pdu_session_release ue=${ue_id} pdu=2    Successfully released PDU Session
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s

Check userstop cause shall be correct
    ${number}=    Get Wireshark Message Count    ${SAVE LOG DIRECTORY}${/}wireshark.pcap    itf_l2_ps_user_UserStopReq_t.cause == 3
    should be equal As Numbers    ${number}    1

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
    Update Cfg    ue_param id=1 ue_nr_capabilities=${SA_Capa_Support_CA_with_Rankchange}
