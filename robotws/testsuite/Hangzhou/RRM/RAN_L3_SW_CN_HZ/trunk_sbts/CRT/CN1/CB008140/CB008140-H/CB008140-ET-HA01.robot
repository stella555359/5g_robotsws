*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CLOUD_5G_I_[LO][LO]_AP_[LOO]_SANSA_FS_ECPRI_CMWV_TDD    team-rock
...    owner-christine.chen    release-SBTS23R3    CRT
Resource    ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
${NOKIA_XNAP_PLUGIN_FLAG}    ${True}
${NOKIA_F1AP_PLUGIN_FLAG}    ${True}

@{PARAMS_IN_SCF}
...    @{PARAMS_FOR_CA}
...    @{PARAMS_FOR_GNB1}
...    @{PARAMS_ADJ_REL_FOR_GNB1}
...    @{PARAMS_FOR_OTHERS}
...    @{GNB1_CA_rel_for_NRCELL_1_2}

@{PARAMS_IN_SCF_GNB2}
...    @{PARAMS_FOR_CA}
...    @{PARAMS_FOR_GNB2}
...    @{PARAMS_ADJ_REL_FOR_GNB2}
...    @{PARAMS_FOR_OTHERS}
...    @{GNB2_CA_rel_for_NRCELL_1}


@{PARAMS_FOR_CA}
...    NRBTS:actCarrierAggregation=true
...    NRBTS:caConfigurationSupport=4CCDL_2CCUL
...    NRBTS:weightForIgnbCaSelection=1
...    NRBTS:actIncXn=true
...    NRBTS:maxNumScellsDl=2
...    NRBTS:maxNumScellsUl=2
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:carrierAggregationSupportList=${CAlist}
...    NRBTS/NRDRB_RLC_AM-1:ulTReassemblyIBCA=40
...    NRBTS/NRDRB_RLC_AM-2:ulTReassemblyIBCA=40
...    NRDU-1:actInterGnbCa=DLOnly
...    NRDU-1:dlToUlContributionRatio=101
...    NRCELL:actK1Opt=intraAndInter-gNB
...    NRCELL:weightForSCellSelection=50
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRDU-1:xgUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
${CAlist}    ca_Fdd_Fr1Tdd_Sa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Any_Sa,ca_Fdd_Any_Sa,ca_Fdd_Fdd

@{PARAMS_FOR_GNB1}
...    NRBTS:sCellActivationMethod=blind
...    NRCELL-1:sCellDeactivationTimerGNB=infinity
...    NRCELL-2:sCellDeactivationTimerGNB=infinity

...    NRCELL-2:tddFrameStructure:frameStructureType=tdLte
...    NRCELL-2:tddFrameStructure:lteToNrFrameShift=3ms
...    NRCELL-2:tddFrameStructure:tdLteUlDlConfig=tdLteConfig2
...    NRCELL-2:tddFrameStructure:guardPeriodLength=6Symbols


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
...    NRBTS/NRADJNRCELL-3:ssbFrequency=655008
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
...    NRBTS/NRADJNRCELL-4:ssbFrequency=648096
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

@{GNB1_CA_rel_for_NRCELL_1_2}
...    NRCELL-1/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-3:gNbId=2
...    NRCELL-1/NRREL-3:gNbIdLength=22
...    NRCELL-1/NRREL-3:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-3:lcrId=3
...    NRCELL-1/NRREL-3:removeNotAllowed=false
...    NRCELL-1/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-3:sCellOperationalMode=dlOnly

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
...    NRCELL-1/NRREL-11:sCellOperationalMode=dlOnly

...    NRCELL-2/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-3:gNbId=2
...    NRCELL-2/NRREL-3:gNbIdLength=22
...    NRCELL-2/NRREL-3:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-3:lcrId=3
...    NRCELL-2/NRREL-3:removeNotAllowed=false
...    NRCELL-2/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-3:sCellOperationalMode=dlOnly

...    NRCELL-2/NRREL-4:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-4:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-4:gNbId=2
...    NRCELL-2/NRREL-4:gNbIdLength=22
...    NRCELL-2/NRREL-4:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-4:lcrId=4
...    NRCELL-2/NRREL-4:removeNotAllowed=false
...    NRCELL-2/NRREL-4:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-4:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-4:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-4:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-4:sCellOperationalMode=dlOnly

...    NRCELL-1:a1MeasSCellAddEnabled=rsrp
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=70|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=90|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-2:a1MeasSCellAddEnabled=rsrp
...    NRCELL-2:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-2:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=70|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-2:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=90|a1TimeToTriggerSCellAddSsbRsrp=320ms

@{PARAMS_FOR_GNB2}
...    NRBTS:sCellActivationMethod=bufferBased
...    NRBTS:iGnbCaXnCfUpBackOffTmr=60
...    NRBTS:iGnbCaXnSetupReqTmr=90
...    NRBTS:iGnbCaXnSetupRespTmr=60
...    NRBTS:intGnbScellTempBlockTmr=60
...    NRCELL-3:sCellDeactivationTimerGNB=infinity
...    NRCELL-4:sCellDeactivationTimerGNB=infinity
...    NRCELL-11:sCellDeactivationTimerGNB=infinity
...    NRCELL-12:sCellDeactivationTimerGNB=infinity
...    NRCELL-11:measGapSelectionSA=favourUeThroughput

...    NRCELL-3:chBw=80MHz
...    NRCELL-3:tddFrameStructure:frameStructureType=tdLte
...    NRCELL-3:tddFrameStructure:lteToNrFrameShift=3ms
...    NRCELL-3:tddFrameStructure:tdLteUlDlConfig=tdLteConfig2
...    NRCELL-3:tddFrameStructure:guardPeriodLength=4Symbols

...    NRCELL-4:tddFrameStructure:frameStructureType=tdLte
...    NRCELL-4:tddFrameStructure:lteToNrFrameShift=3ms
...    NRCELL-4:tddFrameStructure:tdLteUlDlConfig=tdLteConfig2
...    NRCELL-4:tddFrameStructure:guardPeriodLength=6Symbols


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
...    NRCELL:timingAdvanceOffset=n25600

@{GNB2_CA_rel_for_NRCELL_1}
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-1:gNbId=1
...    NRCELL-11/NRREL-1:gNbIdLength=22
...    NRCELL-11/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-1:removeNotAllowed=false
...    NRCELL-11/NRREL-1:lcrId=1
...    NRCELL-11/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-2:gNbId=1
...    NRCELL-11/NRREL-2:gNbIdLength=22
...    NRCELL-11/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-2:removeNotAllowed=false
...    NRCELL-11/NRREL-2:lcrId=2
...    NRCELL-11/NRREL-2:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-2:sCellOperationalMode=dlOnly

...    NRCELL-3:a2MeasSCellRelEnabled=rsrp
...    NRCELL-3:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=480ms
...    NRCELL-3:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=40|a2TimeToTriggerSCellRelSsbRsrp=480ms
...    NRCELL-4:a2MeasSCellRelEnabled=rsrp
...    NRCELL-4:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=480ms
...    NRCELL-4:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=40|a2TimeToTriggerSCellRelSsbRsrp=480ms
...    NRCELL-11:a2MeasSCellRelEnabled=rsrp
...    NRCELL-11:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=480ms
...    NRCELL-11:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=40|a2TimeToTriggerSCellRelSsbRsrp=480ms

@{PM_Counters_Check_HA01_GNB1}
...    NRCELL-1:${IGNB_CA_SCELL_ADMI_REQ_SA}=1
...    NRCELL-2:${IGNB_CA_SCELL_ADMI_REQ_SA}=1
...    NRCELL-1:${IGNB_CA_SCELL_ADMI_SUCC_SA}=1
...    NRCELL-2:${IGNB_CA_SCELL_ADMI_SUCC_SA}=1
...    NRCELL-1:${GNB_DU_SCELL_ADMI_REQ_SA}=1
...    NRCELL-2:${GNB_DU_SCELL_ADMI_REQ_SA}=1
...    NRBTS-2:${IGNB_CA_ADD_REQ_SA_NRADJ}=1
...    NRBTS-2:${IGNB_CA_ADD_REQ_SA_REJ_NRADJ}=1

...    NRCELL-1:${GNB_DU_SCELL_2_ADMI_REQ_SA}=1
...    NRCELL-1:${GNB_DU_SCELL_1_ADMI_SUCC_SA}=1
...    NRCELL-1:${IGNB_CA_ATT_2_SCELL_SA}=1
...    NRCELL-1:${IGNB_CA_ATT_1_SCELL_SA_SUCC}=1

...    NRCELL-2:${GNB_DU_SCELL_2_ADMI_REQ_SA}=1
...    NRCELL-2:${IGNB_CA_ATT_2_SCELL_SA}=1
...    NRCELL-2:${IGNB_CA_ATT_SA_REJ}=1

@{PM_Counters_Check_HA01_GNB2}
...    NRCELL-11:${GNB_DU_SCELL_2_ADMI_REQ_SA}=1
...    NRCELL-11:${IGNB_CA_ATT_2_SCELL_SA}=1
...    NRCELL-11:${IGNB_CA_ATT_SA_REJ}=1

...    NRCELL-11:${IGNB_CA_SCELL_ADMI_REQ_SA}=1
...    NRCELL-3:${IGNB_CA_SCELL_ADMI_REQ_SA}=2
...    NRCELL-11:${IGNB_CA_SCELL_ADMI_SUCC_SA}=1
...    NRCELL-3:${IGNB_CA_SCELL_ADMI_SUCC_SA}=2
...    NRCELL-11:${GNB_DU_SCELL_ADMI_REQ_SA}=1
...    NRCELL-3:${GNB_DU_SCELL_ADMI_REQ_SA}=2
...    NRCELL-11:${GNB_DU_SCELL_ADMI_SUCC_SA}=1
...    NRBTS-1:${IGNB_CA_ADD_REQ_SA_NRADJ}=2

...    NRCELL-4:${IGNB_CA_SCELL_ADMI_REQ_SA}=1
...    NRCELL-4:${IGNB_CA_SCELL_ADMI_SUCC_SA}=1
...    NRCELL-4:${GNB_DU_SCELL_ADMI_REQ_SA}=1
...    NRBTS-1:${IGNB_CA_ADD_REQ_SA_REJ_NRADJ}=1


${GNB_DU_SCELL_2_ADMI_REQ_SA}    M55139C01501
${IGNB_CA_ATT_2_SCELL_SA}    M55118C11002

${IGNB_CA_ATT_SA_REJ}    M55118C11007
${IGNB_CA_SCELL_ADMI_REQ_SA}    M55138C03501
${IGNB_CA_SCELL_ADMI_SUCC_SA}    M55138C03502
${GNB_DU_SCELL_ADMI_REQ_SA}    M55139C01001
${IGNB_CA_ADD_REQ_SA_NRADJ}    M55175C00001
${IGNB_CA_ADD_REQ_SA_REJ_NRADJ}    M55175C00002

${GNB_DU_SCELL_1_ADMI_SUCC_SA}    M55139C01004
${IGNB_CA_ATT_1_SCELL_SA_SUCC}    M55118C11004
${GNB_DU_SCELL_ADMI_SUCC_SA}    M55139C01002

@{expect_UE2}
...    SCellIndex 2 activated successfully at airphone
...    pcid:60
...    physCellId 60

${pdu_id}    1

*** Test Cases ***
CB008140-ET-HA01_Verify_IgNB-CA_SCell_Addition_failure_for_incompatible_TDD_frame_structures_when_one_of_the_cells_applies_3ms_frame_offset
    [Documentation]
    ...    This case is to Verify IgNB-CA SCell Addition failure for incompatible TDD frame structures when one of the cells applies
    ...    3ms frame offset.

    ...    [Configuration]:
    ...                 Cell1_1     Cell1_2    Cell2_3    Cell2_4    Cell2_11    Cell2_12
    ...     Technology    TDD        TDD        TDD        TDD        FDD        FDD
    ...       Band        n77        n77        n77        n77        n3         n28
    ...      Bandwidth    100          40         80        40         10         15
    ...    CB008140 is active, i.e. NRBTS/NRDU/actInterGnbCa is set to "DLOnly" both in gNB-1 and in gNB-2.
    ...    cell1_1/cell1_2 has been configured as candidate SCell of Cell2_11 with respective NRBTS/NRCELL/NRREL/sCellAdditionMethod set to "blind".
    ...    cell2_3/cell2_11 have been as candidate SCell of Cell1_1 with respective NRBTS/NRCELL/NRREL/sCellAdditionMethod set to "coverBasedA1".
    ...    cell2_3/cell2_4 have been as candidate SCell of Cell1_2 with respective NRBTS/NRCELL/NRREL/sCellAdditionMethod set to "coverBasedA1".
    ...    A2 for scell release is configured on coverBased scells.
    ...    sCellActivationMethod for gNB1 set as blind and for gnb2 set as bufferBased.
    ...    tddFrameStructure for cell1_1:frameStructureType=semiStatic
    ...    tddFrameStructure for cell1_2,cell2_3,cell2_4:frameStructureType=tdLte,lteToNrFrameShift=3ms,tdLteUlDlConfig=tdLteConfig2,
    ...    ulDlDataSlotRatio=1/4
    ...    for cell1_2 and cell2_4:guardPeriodLength=6Symbols
    ...    for cell2_3:guardPeriodLength=4Symbols
    ...    UE1 and UE2 support band combination n3_n77(2a)

    ...    2.Test Case Steps:
    ...         a. UE1 attach to gnb2 cell2_11 and try to add ext gnb1 cell1_1 and cell1_2 as scell blindly. And start both UL/DL traffic.
    ...         b. UE2 attach to gnb1 cell1_1 and trigger A1 for scell addition to add ext gnb1 cell2_3 and cell2_11 as scell.And start
    ...            both UL/DL traffic.
    ...         c. UE3 attach to gnb1 cell1_2 and trigger A1 for scell addition to add ext gnb1 cell2_3 and cell2_4 as scell.And start
    ...            both UL/DL traffic.
    ...         d. Deregister UE

    ...    2.Expexted result:
    ...         a. scell addition failed. traffic in pcell is OK.gNB-1-DU fails the SCell addition and replies to gNB-1-CU with the F1AP: IGNB CA
    ...            U CONTEXT SETUP FAILURE message for private cause "Incompatible configuration". gNB-1-CU replies to gNB-2-CU by sending the
    ...            XnAP: IGNB-CA UE ADDITION REQUEST REJECT message for same cause "Incompatible configuration" as received from gNB-1-DU, releasing
    ...            5G-UE context.gNB-2-CU sends to gNB-2-DU via F1AP: IGNB CA UE CONTEXT MODIFICATION REQUEST message with 'Query Purpose' IE set
    ...            to 'IgNB-CA cancel'.gNB-2-DU releases the resources reserved for the ext-SCells and replies to gNB-2-CU with the F1AP: IGNB CA
    ...            UE CONTEXT MODIFICATION RESPONSE message.
    ...         b. scell addition for cell2_3 failed but success for cell2_11. traffic in pcell and scell2_11 is OK.gNB-2-DU replies to gNB-2-CU
    ...            with an F1AP: IGNB CA UE CONTEXT SETUP RESPONSE message by which it provides the transport addresses of the DRB(s) to split
    ...            (transport address per DRB per SCell is provided) as well as the selected radio configuration for SCell Cell2_11, and with
    ...            Cell2_3 in the SCell-FailedtoSetupMod-List with corresponding failure cause-"Incompatible configuration".
    ...            gNB-2-CU replies to gNB-1-CU by sending the XnAP: IGNB-CA UE ADDITION REQUEST ACKNOWLEDGE message, carrying SCells configuration
    ...            of Cell2_11 received from gNB-2-DU, and Cell2_3 in 'IgNB-CA SCell Failed to Setup List' with cause "Incompatible configuration".
    ...         c. scell addition failed. traffic in pcell is OK.
    ...         d. Deregister UE

    [Tags]    QC_277550    CA_LABEL-FTT(10MHz_FDD_n3+ 100MHz_TDD_n77+40MHz_TDD_n77)    CA_LABEL-TTF(100MHz_TDD_n77+80MHz_TDD_n77+ 10MHz_FDD_n3)
    ...    CA_LABEL-TTT(100MHz_TDD_n77+80MHz_TDD_n77+ 40MHz_TDD_n77)
    Clear counter
    UE1 attach to cell11
    UE2 attach to cell1
    UE3 attach to cell2
    Check Counters    ${PM_Counters_Check_HA01_GNB1}
    Check Counters GNB2    ${PM_Counters_Check_HA01_GNB2}
    Check WireShark Log    ${CURDIR}${/}A2A_HA_01${/}a2a.ini    wait_string=UEContextRelease::20
    Check WireShark Log GNB2    ${CURDIR}${/}A2A_HA_01${/}a2a_gnb2.ini    wait_string=UEContextRelease::14

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup 2Airphone Env    fddtdd_sansa_cmwv/6cells_gnb1_2T_gnb2_2T2F

Update UE capa
    [Arguments]    ${SA_Capa_perUE_Full}=${SA_Capa_Support}    ${ue_id}=1
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full}
    Execute Egate Command    ${cmd}

Sa Ue Attach
    [Arguments]    ${ue_id}=1    ${gateway}=1    ${enb_id}=2    ${cell_id}=1
    ...    ${pass_regexp}=NG RM Register
    Execute Egate Command    ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    ${pass_regexp}

UE Deregister From gNB
    [Arguments]    ${ue_id}
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=1    Traffic was stopped
    Execute Egate Command    ue_pdu_session_release ue=${ue_id} pdu=1    Successfully released PDU Session
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s

UE1 attach to cell11
    Update UE capa    ${CB008140_GG_Capa_2CC_3CC_4CC_n3_n28_n77_n78}    1
    Sa Ue Attach    ue_id=1    gateway=1    enb_id=3    cell_id=11
    Setup pdu session with scell add failed    ue_id=1    gateway=1    pdu_id=1
    Send Throuput    ue_id=1    pdu_id=1
    Verify Throuput for pcell    ue_id=1    pcell_dl=50
    UE Deregister From gNB    1

UE2 attach to cell1
    Update UE capa    ${CB008140_GG_Capa_2CC_3CC_4CC_n3_n28_n77_n78}    2
    Sa Ue Attach    ue_id=2    gateway=1    enb_id=2    cell_id=1
    Setup pdu session    ue_id=2    gateway=1    pdu_id=1
    trigger A1 MR to add scell and one failed    ue_id=2    carrierfreq=663360
    Send Throuput    ue_id=2    pdu_id=1
    Verify Throuput for one scell    ue_id=2    pcell_dl=500    scell1_dl=50    pdu_id=1
    UE Deregister From gNB    2

UE3 attach to cell2
    Update UE capa    ${CB008140_GG_Capa_2CC_3CC_4CC_n3_n28_n77_n78}    3
    Sa Ue Attach    ue_id=3    gateway=1    enb_id=2    cell_id=2
    Setup pdu session    ue_id=3    gateway=1    pdu_id=1
    trigger A1 MR to add scell but failed    ue_id=3    carrierfreq=657984
    Send Throuput    ue_id=3    pdu_id=1
    Verify Throuput for pcell    ue_id=3    pcell_dl=180
    UE Deregister From gNB    3

Setup pdu session
    [Arguments]    ${ue_id}=1    ${gateway}=1    ${pdu_id}=1
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} nwslice=1 gw=${gateway}    pass_regexp=QoS Routing Table    timeout=20s

Setup pdu session with scell add failed
    [Arguments]    ${ue_id}=1    ${gateway}=1    ${pdu_id}=1
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    ${ret1}=    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} nwslice=1 gw=${gateway}    pass_regexp=QoS Routing Table
    Should Not Contain    ${ret1}    sCellIndex 1

trigger A1 MR to add scell and one failed
    [Arguments]    ${ue_id}=3    ${carrierfreq}=641472    ${rsrp}=100
    ${meas_id}    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A1
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrq_nr=70 srsrp_nr=${rsrp}
    ...    pass_regexp=${expect_UE2}

trigger A1 MR to add scell but failed
    [Arguments]    ${ue_id}=1    ${carrierfreq}=641472    ${rsrp}=100
    ${meas_id}    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A1
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrq_nr=70 srsrp_nr=${rsrp}
    ...    fail_regexp=activated successfully at airphone

Send Throuput
    [Arguments]    ${ue_id}=1    ${pdu_id}=1
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=3    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=4    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=5    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=6    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=7    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=ul mbps=10 trf_id=1    UE ${ue_id}: UDP UL
    sleep    30s    #sleep for stable traffic

Verify Throuput for pcell
    [Arguments]    ${ue_id}=2    ${pcell_dl}=270    ${ul}=8    ${pdu_id}=1
    sleep    10s     #sleep for stable traffic
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000 > ${pcell_dl}
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${ul_throughput}/1000>8

Verify Throuput for one scell
    [Arguments]    ${ue_id}=2    ${pcell_dl}=420    ${scell1_dl}=400    ${ul}=8    ${pdu_id}=1
    sleep    10s     #sleep for stable traffic
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000 > ${pcell_dl}
    ${scell1_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=2    type=pdsch    rate_type=ave
    Should Be True    ${scell1_tput}/1000 > ${scell1_dl}
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${ul_throughput}/1000>8

Clear counter
    Clear Counter Files
    Clear Counter Files GNB2

