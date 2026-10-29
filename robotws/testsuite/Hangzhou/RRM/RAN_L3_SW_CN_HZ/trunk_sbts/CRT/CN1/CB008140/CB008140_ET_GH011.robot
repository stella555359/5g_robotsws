*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CLOUD_5G_I_[LO][LO]_AP_[LOO]_SANSA_FS_ECPRI_CMWV_TDD    team-blues
...    owner-zora.wang    release-SBTS23R3    CRT
Resource          ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${NOKIA_XNAP_PLUGIN_FLAG}    ${True}
${NOKIA_F1AP_PLUGIN_FLAG}    ${True}
${SYSCOM_FLAG}    ${True}

@{PARAMS_IN_SCF}
...    @{PARAMS_FOR_CA}
...    @{PARAMS_FOR_GNB1}
...    @{PARAMS_ADJ_REL_FOR_GNB1}
...    @{PARAMS_FOR_OTHERS}
...    @{GNB1_A1_for_NRCELL_1}
...    @{IRAT_Config_GNB1}

@{PARAMS_IN_SCF_GNB2}
...    @{PARAMS_FOR_CA}
...    @{PARAMS_FOR_GNB2}
...    @{PARAMS_ADJ_REL_FOR_GNB2}
...    @{PARAMS_FOR_OTHERS}
...    @{GNB2_CA_for_NRCELL_11}

@{IRAT_Config_GNB1}
...    NRBTS:actInterRatHoFromEutraToSA=true
...    NRBTS:nonContentRachAcFullConfigHo=true
...    NRBTS:tNgRelocExecDeltL=5000
...    NRCELL:measGapSelectionSA=favourUeThroughput
...    NRBTS:actInterRatHoSA=true
...    NRCELL:actCDrx=true
...    NRBTS/NRHOIR-1:allowedMeasBandwidth=mbw100
...    NRBTS/NRHOIR-1:b2MeashoEnabled=rsrp
...    NRBTS/NRHOIR-1:b2Threshold1hoRsrp=35
...    NRBTS/NRHOIR-1:b2Threshold1hoRsrq=50
...    NRBTS/NRHOIR-1:earfcnValue=1
...    NRBTS/NRHOIR-1:eutraFreqQOffsetRange=0dB
...    NRBTS/NRHOIR-1:eutraB2MeashoRsrp:b2HysteresishoRsrp=0
...    NRBTS/NRHOIR-1:eutraB2MeashoRsrp:b2Threshold2hoRsrp=18
...    NRBTS/NRHOIR-1:eutraB2MeashoRsrp:b2TimeToTriggerhoRsrp=ms480
...    NRBTS/NRHOIR-1:eutraB2MeashoRsrq:b2HysteresishoRsrq=0
...    NRBTS/NRHOIR-1:eutraB2MeashoRsrq:b2Threshold2hoRsrq=2
...    NRBTS/NRHOIR-1:eutraB2MeashoRsrq:b2TimeToTriggerhoRsrq=ms480
...    NRBTS/NRCELL-1:nrhoirDNList=MRBTS-1/NRBTS-1/NRHOIR-1
...    NRBTS/NRADJECELL-8:eNodeBId=18
...    NRBTS/NRADJECELL-8:ePSTrackingAreaCode=0
...    NRBTS/NRADJECELL-8:earfcnValue=1
...    NRBTS/NRADJECELL-8:lcrId=1
...    NRBTS/NRADJECELL-8:physCellId=11
...    NRBTS/NRADJECELL-8:ecgiPlmn:mcc=311
...    NRBTS/NRADJECELL-8:ecgiPlmn:mnc=489
...    NRBTS/NRADJECELL-8:ecgiPlmn:mncLength=3
...    NRBTS/NRADJECELL-8:enbPlmn:mcc=311
...    NRBTS/NRADJECELL-8:enbPlmn:mnc=489
...    NRBTS/NRADJECELL-8:enbPlmn:mncLength=3
...    NRCELL-1/NRRELE-1:cellIndividualOffset=0dB
...    NRCELL-1/NRRELE-1:eNodeBId=18
...    NRCELL-1/NRRELE-1:eutranCellExcluded=false
...    NRCELL-1/NRRELE-1:lcrId=1
...    NRCELL-1/NRRELE-1:removeNotAllowed=false
...    NRCELL-1/NRRELE-1:ecgiPlmn:mcc=311
...    NRCELL-1/NRRELE-1:ecgiPlmn:mnc=489
...    NRCELL-1/NRRELE-1:ecgiPlmn:mncLength=3
...    NRCELL-1:a1MeasSCellAddEnabled=rsrp
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=2
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=15
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=20
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms

@{PARAMS_FOR_CA}
...    NRBTS:actCarrierAggregation=true
...    NRBTS:sCellActivationMethod=blind
...    NRBTS:caConfigurationSupport=4CCDL_2CCUL
...    NRBTS:weightForIgnbCaSelection=20
...    NRBTS:actIncXn=true
...    NRBTS:maxNumScellsDl=2
...    NRBTS:maxNumScellsUl=2
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:carrierAggregationSupportList=ca_Fdd_Fdd,ca_Fdd_Fr1Tdd_Sa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Any_Sa,ca_Fdd_Any_Sa
...    NRDU-1:actInterGnbCa=DLOnly
...    NRDU-1:dlToUlContributionRatio=101
...    NRCELL:actK1Opt=intraAndInter-gNB
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRDU-1:actConnectedModeMobilityCA=true

@{PARAMS_FOR_GNB1}
...    NRCELL-1:sCellDeactivationTimerGNB=infinity
...    NRCELL-2:sCellDeactivationTimerGNB=infinity
...    NRBTS:actHoOptimizationCa=true

@{PARAMS_ADJ_REL_FOR_GNB1}
...    NRCELL:nrCellType=2DL2UL
...    NRCELL:maxNumScellsDlFr1=3
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
...    NRCELL-1/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-3:gNbId=2
...    NRCELL-1/NRREL-3:gNbIdLength=22
...    NRCELL-1/NRREL-3:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-3:lcrId=3
...    NRCELL-1/NRREL-3:removeNotAllowed=false
...    NRCELL-1/NRREL-3:sCellAdditionMethod=blind
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
...    NRCELL-1/NRREL-11:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-11:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-11:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-11:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-11:sCellOperationalMode=dlOnly

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
...    NRCELL-4:weightForSCellSelection=30
...    NRCELL-11:weightForSCellSelection=50
...    NRCELL-12:weightForSCellSelection=60
...    NRCELL-11:measGapSelectionSA=favourUeThroughput

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
...    NRCELL:a3MeasEnabled=rsrp
...    NRCELL:a3MeasSsbRsrp:a3HysteresisSsbRsrp=2|a3OffsetSsbRsrp=10|a3TimeToTriggerSsbRsrp=ms0
...    NRDU-1:xgUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRCELL:a2MeashoEnabledSA=rsrp
...    NRCELL:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=2|a2ThresholdhoSsbRsrpSA=5|a2TimeToTriggerhoSsbRsrpSA=ms128
...    NRCELL:a1MeashoEnabledSA=rsrp
...    NRCELL:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0|a1ThresholdhoSsbRsrpSA=30|a1TimeToTriggerhoSsbRsrpSA=ms100

@{GNB2_CA_for_NRCELL_11}
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
...    NRCELL-11/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-11:a1MeasSCellAddEnabled=rsrq
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=2
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=70
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=90
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-11:a1MeasSCellAddSsbRsrq:a1HysteresisSCellAddSsbRsrq=0|a1TimeToTriggerSCellAddSsbRsrq=320ms
...    NRCELL-11:a1MeasSCellAddSsbRsrq:a1ThresholdSCellAddSsbRsrq=60|a1TimeToTriggerSCellAddSsbRsrq=320ms
...    NRCELL-11:a2MeasSCellRelEnabled=rsrq
...    NRCELL-11:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-11:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=35|a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-11:a2MeasSCellRelSsbRsrq:a2HysteresisSCellRelSsbRsrq=0|a2TimeToTriggerSCellRelSsbRsrq=0ms
...    NRCELL-11:a2MeasSCellRelSsbRsrq:a2ThresholdSCellRelSsbRsrq=10|a2TimeToTriggerSCellRelSsbRsrq=0ms

@{GNB1_A1_for_NRCELL_1}
...    NRCELL-1:a1MeasSCellAddEnabled=rsrp
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=15
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=25
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-1/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-11:sCellAdditionMethod=covBasedA1

@{A1_expect}
...    PhysCellId: 52
...    PhysCellId: 60
...    SCellIndex 1 activated successfully at airphone
...    SCellIndex 2 activated successfully at airphone

@{A2_expect}
...    gapUE setup
...    drx-Config release
...    rrcReconfigurationComplete

@{B2_expect}
...    HandoverRequired
...    Successful handover from EXT_ENB-2.1 to ENB-4.1
...    UeContextReleaseComplete

@{ENBTo5G}
...    HandoverRequest
...    ENB-4.1 to EXT_ENB-2.1

@{PM_Counters_GH011}
...    NRCELL-1:NCAC:${IGNB_CA_ATT_SA_REL}=6
...    NRBTS-1:NSL:${SUCC_IRATHO_PRE_SLICE}=5
...    NRCELL-1:NF1CC:${NF1CC_DL_RRC_MSG_TRANSFER}>0
...    NRDU-1:${NF1CD_DL_RRC_MSG_TRANSFER}>0
...    NRBTS-1:NE1CS:${NE1CS_CTXT_MOD_REQ_SENT}=11
...    NRCELL-1:NF1CC:${F1_UE_CTXT_MOD_REQ_SENT}>0
...    NRBTS-1:NE1US:${NE1US_CTXT_MOD_REQ_RECD}=11
...    NRBTS-1:NE1US:${NE1US_CTXT_MOD_RSP_SENTD}=11
...    NRBTS-1:NE1CS:${NE1CS_CTXT_MOD_RSP_RECD}=11
...    NRDU-1:${F1_UE_CTXT_MOD_REQ_RECEIVED}>0
...    NRDU-1:${F1_UE_CTXT_MOD_RESP_SENT}>0
...    NRCELL-1:NF1CC:${F1_UE_CTXT_MOD_RESP_RECEIVED}>0
...    NRBTS-1:NSL:${SUCC_IRATHO_SLICE}=5
...    NRCELL-1:NF1CC:${NF1CC_UECTXT_REL_CMDSENT}=6
...    NRBTS-1:NE1CS:${NE1CS_CTXT_REL_CMD_SENT}=6
...    NRCELL-1:NF1CC:${NF1CC_UE_CTXT_REL_CMP_RECD}=6
...    NRBTS-1:NE1CS:${NE1CS_CTXT_REL_CMP_RECD}=6

${IGNB_CA_ATT_SA_REL}    M55118C11008
${SUCC_IRATHO_PRE_SLICE}    M55149C00601
${NF1CC_DL_RRC_MSG_TRANSFER}    M55113C00501
${NF1CD_DL_RRC_MSG_TRANSFER}    M55117C02001
${NE1CS_CTXT_MOD_REQ_SENT}    M55135C00505
${F1_UE_CTXT_MOD_REQ_SENT}    M55113C00001
${NE1US_CTXT_MOD_REQ_RECD}    M55133C01004
${NE1US_CTXT_MOD_RSP_SENTD}    M55133C01005
${NE1CS_CTXT_MOD_RSP_RECD}    M55135C00506
${F1_UE_CTXT_MOD_REQ_RECEIVED}    M55117C00001
${F1_UE_CTXT_MOD_RESP_SENT}    M55117C00002
${F1_UE_CTXT_MOD_RESP_RECEIVED}    M55113C00002

${SUCC_IRATHO_SLICE}    M55149C00602
${NF1CC_UECTXT_REL_CMDSENT}    M55113C01009
${NE1CS_CTXT_REL_CMD_SENT}    M55135C00001
${NF1CC_UE_CTXT_REL_CMP_RECD}    M55113C01010
${NE1CS_CTXT_REL_CMP_RECD}    M55135C00002

*** Test Cases ***
CB008140-ET-GH011_SA_Inter-RAT_Handover_to_LTE_in_IgNB-CA_mode_then_IRAT_HO_back_to_origianl_cell
    [Documentation]
    ...    This case is to Verify the inter-RAT handover of a UE context in IgNB-CA mode.
    ...    5G_RAN_USR_RRM_18263 fully covered. CB008140-GH#B1: Inter-RAT Handover to LTE of a UE connection in IgNB-CA mode
    ...    [Configuration]:
    ...    Cell id=1 gnb=1 pci=16:2 tac=200 tdd_cell=on band=n77 nr_arfcn=663400:663400 gscn=8159 chBw=100MHz ssb=663360
    ...    Cell id=2 gnb=1 pci=17:0 tac=200 tdd_cell=on band=n77 nr_arfcn=658000:658000 gscn=8103 chBw=40MHz ssb=657984
    ...    Cell id=3 gnb=2 pci=17:1 tac=200 tdd_cell=on band=n77 nr_arfcn=653400:653400 gscn=8072 chBw=100MHz ssb=655008
    ...    Cell id=4 gnb=2 pci=17:2 tac=200 tdd_cell=on band=n77 nr_arfcn=648000:648000 gscn=8000 chBw=40MHz ssb=648096
    ...    Cell id=11 gnb=2 pci=20:0 tac=200 tdd_cell=off band=n3 nr_arfcn=349400:368400 gscn=4605 chBw=10MHz ssb=663360
    ...    Cell id=12 gnb=2 pci=20:1 tac=200 tdd_cell=off band=n28 nr_arfcn=143400:153400 gscn=1916 chBw=20MHz ssb=657984
    ...    Cell 1 is pcell and have 2 nrrel ca relationships , gnb2_cell11, gnb2_cell3
    ...    2.Test Case Steps:
    ...         a. UE1 Register And PDU Session Setup On GNB 1 NRCELL-1
    ...         b. Trigger A1 to add scell(T and F)
    ...         c. UE1 Start Traffic And Verify Throughput
    ...         d. Trigger A2 measurement gaps setup
    ...         e. UE1 send B2 MR indicating LTE_Cell has better neighbour cell.
    ...         f. trigger handover from ENB to NRCELL-1.Trigger A1 to add scell
    ...         g. Repeat step d-f for 5 times
    ...         g. check counters
    [Tags]    QC_277933    GH011    CA_LABEL-TTF(100MHz_TDD_n77+100MHz_TDD_n77+10MHZ_FDD_n3)
    Clear Counter Files
    Make Normal CA SA UE with A1add
    Repeat SA Inter-RAT Handover to LTE in IgNB-CA mode then IRAT HO back to origianl cell for 5rounds
    Check Counters    ${PM_Counters_GH011}
    Check WireShark Log GNB2    ${CURDIR}${/}A2A_GH_011${/}a2a_gnb2.ini    wait_string=UEContextRelease::24

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup 2Airphone Env    fddtdd_sansa_cmwv/6cells_gnb1_2T_gnb2_2T2F

Make Normal CA SA UE with A1add
    Sa Ue Attach    1    1    2    1
    Setup pdu session with no scelladd
    trigger A1 MR to add scell    85
    Send And Verify Throuput
    Verify Throuput on scell

Modify Cfg
    ${C_1}    catenate
    ...    set_gnb id=4 type=simulated plmn=311:489 ng=10.0.1.138 daemon=10.0.2.1:22222 gnb_id=0x12:28 nssai=0x01:0xD143A5
    ${C_2}    catenate
    ...    set_cell id=1 gnb=4 pci=3:2 earfcn=1:18001 tac=0 proxy=10.0.2.92:12219 nrci=0x01
    ...    tdd_cell=on bw=20MHz technology=lte
    Update Cfg    ${C_1}
    Update Cfg    ${C_2}
    Update Cfg    gnb_param id=4 xn_listening_socket=true

Repeat SA Inter-RAT Handover to LTE in IgNB-CA mode then IRAT HO back to origianl cell for 5rounds
    repeat N timers to SA Inter-RAT Handover to LTE in IgNB-CA mode then IRAT HO back    5
    UE Deregister From gNB

repeat N timers to SA Inter-RAT Handover to LTE in IgNB-CA mode then IRAT HO back
    [Arguments]    ${numofrepeat}=5
    FOR    ${i}    IN RANGE    ${numofrepeat}
        Execute Egate Command    ue_stats_nr id=1 scell=0-8 type=pdsch    pass_regexp=CellIndex
        Trigger B2 HO
        trigger handover from ENB to 5G
        trigger A1 MR to add scell    85
        Verify Throuput on Pscell
        Verify Throuput on scell
    END

Trigger B2 HO
    [Arguments]    ${ue_id}=1
    ${A2_meas_id}    get nr meas id for specific type and frequency    ${ue_id}    event_type=A2    carrierfreq=663360
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${A2_meas_id} event=A2 srsrp_nr=11 srsrq_nr=11
    ...    pass_regexp=${A2_expect}
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}    event_type=B2    carrierfreq=1    carrierfreq_rat=EUTRAN
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=B2 srsrp_nr=11 srsrq_nr=11
    ...    phycell_id=11 nrsrp_nr=30 nrsrq_nr=30
    Execute Egate Command    ${cmd}    pass_regexp=${B2_expect}
    sleep    20s    reason=wait timer

trigger handover from ENB to 5G
    [Arguments]    ${ue_id}=1
    ${cmd}    Catenate    gnb_trigger_inter_rat_handover_to_5g ue=${ue_id} target_gnb=2 target_cell=1 plmn=311:489
    Execute Egate Command    ${cmd}    pass_regexp=${ENBTo5G}

trigger A1 MR to add scell
    [Arguments]    ${rsrp}=80
    ${meas_id}    get_nr_meas_id_for_specific_type_and_frequency    ue_id=1    carrierfreq=663360    event_type=A1
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=1 meas_id=${meas_id} event=A1 srsrq_nr=70 srsrp_nr=${rsrp}
    ...    pass_regexp=${A1_expect}

Sa Ue Attach
    [Arguments]    ${ue_id}=1    ${gateway}=1    ${enb_id}=2    ${cell_id}=2
    ...    ${pass_regexp}=NG RM Register
    Execute Egate Command    ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    ${pass_regexp}

Setup pdu session with no scelladd
    [Arguments]    ${ue_id}=1    ${gateway}=1
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${gateway}    pass_regexp=QoS Routing Table
    ...    fail_regexp=sCellIndex 1

Send And Verify Throuput
    [Arguments]    ${ue_id}=1    ${numofrepeat}=5
    FOR    ${i}    IN RANGE    1    ${numofrepeat}
        Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=${i}    UE ${ue_id}: UDP DL
    END
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=ul mbps=10 trf_id=1    UE ${ue_id}: UDP UL
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-8 type=pdsch    pass_regexp=CellIndex
    Verify Throuput on Pscell    sleep_time=5s

Verify Throuput on Pscell
    [Arguments]    ${ue_id}=1    ${sleep_time}=5s
    sleep    ${sleep_time}    sleep for traffic stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-8 type=pdsch    pass_regexp=CellIndex
    Should Be True    ${dl_throughput}/1000>200
    Should Be True    ${ul_throughput}/1000>5

Verify Throuput on scell
    [Arguments]    ${ue_id}=1    ${total_dl_tput}=300
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-8 type=pdsch    pass_regexp=CellIndex
    ${pcell_dl}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${pcell_dl}/1000 > 0
    ${total_dl}    Set Variable    ${pcell_dl}
    ${scell1_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=1    type=pdsch    rate_type=ave
    Should Be True    ${scell1_tput}/1000 > 0
    ${scell2_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=2    type=pdsch    rate_type=ave
    Should Be True    ${scell2_tput}/1000 > 0
    ${total_dl}    Evaluate    ${scell1_tput}+${scell2_tput}+${total_dl}
    Should Be True    ${total_dl}/1000>${total_dl_tput}

UE Deregister From gNB
    [Arguments]    ${ue_id}=1
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=1    Traffic was stopped
    Execute Egate Command    ue_pdu_session_release ue=${ue_id} pdu=1    Successfully released PDU Session
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s
