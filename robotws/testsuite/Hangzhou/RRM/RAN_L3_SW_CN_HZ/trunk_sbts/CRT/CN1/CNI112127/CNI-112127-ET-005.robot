*** Settings ***
Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    RAN_5G    RAN_5G_FDD    SBTS00    CRT    CLOUD_5G_I_[LO][LO]_AP_[LOO]
...            owner-delun.li    team-CN1ET    release-SBTS24R1
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${NOKIA_XNAP_PLUGIN_FLAG}    ${True}
${NOKIA_F1AP_PLUGIN_FLAG}    ${True}
${SYSCOM_FLAG}    ${True}

@{PARAMS_IN_SCF}
...    @{PARAMS_FOR_CA}
...    @{PARAMS_FOR_GNB1}
...    @{PARAMS_ADJ_REL_FOR_GNB1}
...    @{PARAMS_FOR_OTHERS}
...    @{CNI-112127_feature_flag_gNB1}
...    @{CNI-112127_VoNR_relate_gNB1}

@{PARAMS_IN_SCF_GNB2}
...    @{PARAMS_FOR_CA}
...    @{PARAMS_FOR_GNB2}
...    @{PARAMS_ADJ_REL_FOR_GNB2}
...    @{PARAMS_FOR_OTHERS}
...    @{gscn_Arfcn}
...    @{CNI-112127_feature_flag_gNB2}
...    @{CNI-112127_VoNR_relate_gNB2}

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
...    NRDU-1:dlToUlContributionRatio=101
...    NRCELL:actK1Opt=intraAndInter-gNB
...    NRDU-1:xgUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRDU-1:actInterGnbCa=DLOnly

@{PARAMS_FOR_GNB1}
...    NRCELL:sCellDeactivationTimerGNB=infinity
...    NRCELL:nrCellType=2DL2UL
...    NRCELL:maxNumScellsDlFr1=3
...    NRCELL:dlMimoMode=2x2 Open Loop Spatial Multiplexing
...    NRCELL:actCDrx=true
...    NRPMRNL-1:miNrInterGnbMobilityNsaPmqap=disabled
...    NRPMRNL-1:miNrInterGnbNgMobilitySaPmqap=disabled
...    NRPMRNL-1:miNrInterGnbXnMobilitySaPmqap=disabled
...    NRPMRNL-1:miNrIntraGnbMobilityNsaPmqap=disabled
...    NRPMRNL-1:miNrIntraGnbMobilitySaPmqap=disabled
...    NRCELL-11:a5MeasEnabled=rsrpCombined
...    NRCELL-11:a5MeasSsbRsrp:a5HysteresisSsbRsrp=0
...    NRCELL-11:a5MeasSsbRsrp:a5Threshold1SsbRsrp=20
...    NRCELL-11:a5MeasSsbRsrp:a5Threshold2SsbRsrp=40
...    NRCELL-11:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms40
...    NRCELL-11:a5MeasSsbRsrq:a5HysteresisSsbRsrq=0
...    NRCELL-11:a5MeasSsbRsrq:a5Threshold1SsbRsrq=50
...    NRCELL-11:a5MeasSsbRsrq:a5Threshold2SsbRsrq=70
...    NRCELL-11:a5MeasSsbRsrq:a5TimeToTriggerSsbRsrq=ms40
...    NRCELL-11:drxProfileNrAnr:drxControl=intraNRSAintraFreq
...    NRCELL-11:drxProfileNrAnr:drxInactivityTimer=80ms
...    NRCELL-11:drxProfileNrAnr:drxLongCycle=320ms
...    NRCELL-11:drxProfileNrAnr:drxOnDurationTimer=20ms
...    NRCELL-11:drxProfileNrAnr:drxRetransTimerDl=0slot
...    NRCELL-11:drxProfileNrAnr:drxRetransTimerUl=0slot

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
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-1:gNbId=2
...    NRCELL-11/NRREL-1:gNbIdLength=22
...    NRCELL-11/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-1:lcrId=1
...    NRCELL-11/NRREL-1:removeNotAllowed=false
...    NRCELL-11/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-1:sCellAdditionMethod=blind
...    NRBTS/NRADJNRCELL-13:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-13:fiveGsTac=200
...    NRBTS/NRADJNRCELL-13:freqBandIndicatorNR=3
...    NRBTS/NRADJNRCELL-13:gNbId=2
...    NRBTS/NRADJNRCELL-13:lcrId=13
...    NRBTS/NRADJNRCELL-13:nrarfcn=364000
...    NRBTS/NRADJNRCELL-13:physCellId=62
...    NRBTS/NRADJNRCELL-13:ssbFrequency=363850
...    NRBTS/NRADJNRCELL-13:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-13:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-13:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-13:gNbId=2
...    NRCELL-11/NRREL-13:lcrId=13
...    NRCELL-11/NRREL-13:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-13:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-13:gnbPlmn:mncLength=3

###add for case005
@{CNI-112127_feature_flag_gNB1}
...    NRBTS:actAdditionalSliceSupport=true
...    NRBTS:actRedirect=true
...    NRCELL-11:actBadUplinkRadioRedirect=highUlBlerOrUlNackFloodBased
...    NRCELL-11:badULRedirectDeprioTimer=5min
...    NRCELL-11:ulBler:ulBlerThresholdRedirectData=90
...    NRCELL-11:ulBler:ulBlerThresholdRedirectVoNR=75
...    NRCELL-11/NRREDRT-1:redirFreqNr=373970
...    NRCELL-11/NRREDRT-1:redirSsbScs=15KHz
...    NRCELL-11/NRREDRT-2:redirFreqNr=663360
...    NRCELL-11/NRREDRT-2:redirPrio=2

@{CNI-112127_VoNR_relate_gNB1}
...    NRCELL-11:actVoNR=true
...    NRBTS/NRDRB-15:discardTimer=10ms
...    NRBTS/NRDRB-15:discardTimerUl=infinity
...    NRBTS/NRDRB-15:dlFlowControlAlgo=none
...    NRBTS/NRDRB-15:drbInactivityTimerSA=10
...    NRBTS/NRDRB-15:dtxDelaySinceLastScheduling=0
...    NRBTS/NRDRB-15:dtxMaxRetentionDelay=10
...    NRBTS/NRDRB-15:l2OHFactorDl=16
...    NRBTS/NRDRB-15:l2OHFactorUl=35
...    NRBTS/NRDRB-15:maxDataRateGbrDl=1000
...    NRBTS/NRDRB-15:maxDataRateGbrUl=1000
...    NRBTS/NRDRB-15:maxForwardTimeLimitX2=50
...    NRBTS/NRDRB-15:maxRlcQueueingDelayGbr=20
...    NRBTS/NRDRB-15:maxTransferDelayGbr=20
...    NRBTS/NRDRB-15:minForwardTputX2=100
...    NRBTS/NRDRB-15:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-4
...    NRBTS/NRDRB-15:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-3
...    NRBTS/NRDRB-15:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRBTS/NRDRB-15:pdcpStatRepWaitTimer=40
...    NRBTS/NRDRB-15:pdcpStatRepWaitTimerOffset=60
...    NRBTS/NRDRB-15:queuingDelayDiscarding=Disabled
...    NRBTS/NRDRB-15:resType=GBR
...    NRBTS/NRDRB-15:rlcMode=RLC_UM
...    NRBTS/NRDRB-15:schedulWeight=1
...    NRBTS/NRDRB-15:cellAggrLevel=Not FR1 CA eligible
...    NRBTS/NRDRB_5QI-6:fiveqiValueList=1
...    NRBTS/NRDRB_5QI-6:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-15
...    NRBTS/NRDRB_MAC-4:delayTarget=50
...    NRBTS/NRDRB_MAC-4:lcgid=4
...    NRBTS/NRDRB_MAC-4:schedulPrio=4
...    NRBTS/NRDRB_PDCP-3:maxCidAllowed=4
...    NRBTS/NRDRB_PDCP-3:outOfOrderDeliveryDl=false
...    NRBTS/NRDRB_PDCP-3:outOfOrderDeliveryUl=false
...    NRBTS/NRDRB_PDCP-3:pdcpSNLengthRedCap=len18bits
...    NRBTS/NRDRB_PDCP-3:tReorderingDl=ms300
...    NRBTS/NRDRB_PDCP-3:xxFlowControlProfForCuIdx=1
...    NRBTS/NRDRB_RLC_UM-1:dlTReassemblyUm=ms50



@{PARAMS_FOR_GNB2}
...    NRBTS:iGnbCaXnCfUpBackOffTmr=60
...    NRBTS:iGnbCaXnSetupReqTmr=90
...    NRBTS:iGnbCaXnSetupRespTmr=60
...    NRBTS:intGnbScellTempBlockTmr=60
...    NRMOPR_SA-1:a5MeasEnabled=rsrp
...    NRCELL-1:sCellDeactivationTimerGNB=infinity
...    NRCELL-2:sCellDeactivationTimerGNB=infinity
...    NRCELL-13:sCellDeactivationTimerGNB=infinity
...    NRCELL-14:sCellDeactivationTimerGNB=infinity
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRPMRNL-1:miNrInterGnbMobilityNsaPmqap=disabled
...    NRPMRNL-1:miNrInterGnbNgMobilitySaPmqap=disabled
...    NRPMRNL-1:miNrInterGnbXnMobilitySaPmqap=disabled
...    NRPMRNL-1:miNrIntraGnbMobilityNsaPmqap=disabled
...    NRPMRNL-1:miNrIntraGnbMobilitySaPmqap=disabled
...    NRCELL-13:a5MeasEnabled=rsrq
...    NRCELL-13:a5MeasSsbRsrp:a5HysteresisSsbRsrp=0
...    NRCELL-13:a5MeasSsbRsrp:a5Threshold1SsbRsrp=20
...    NRCELL-13:a5MeasSsbRsrp:a5Threshold2SsbRsrp=40
...    NRCELL-13:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms40
...    NRCELL-13:a5MeasSsbRsrq:a5HysteresisSsbRsrq=0
...    NRCELL-13:a5MeasSsbRsrq:a5Threshold1SsbRsrq=75
...    NRCELL-13:a5MeasSsbRsrq:a5Threshold2SsbRsrq=85
...    NRCELL-13:a5MeasSsbRsrq:a5TimeToTriggerSsbRsrq=ms40
...    NRCELL-13:actCDrx=true
...    NRCELL-13:drxProfileNrAnr:drxControl=intraNRSA
...    NRCELL-13:drxProfileNrAnr:drxInactivityTimer=80ms
...    NRCELL-13:drxProfileNrAnr:drxLongCycle=320ms
...    NRCELL-13:drxProfileNrAnr:drxOnDurationTimer=20ms
...    NRCELL-13:drxProfileNrAnr:drxRetransTimerDl=0slot
...    NRCELL-13:drxProfileNrAnr:drxRetransTimerUl=0slot
...    NRCELL-13/NRREL-12:sCellAdditionMethod=blind

#add for case005
@{CNI-112127_feature_flag_gNB2}
...    NRBTS:actAdditionalSliceSupport=true
...    NRBTS:actRedirect=true
...    NRCELL-13:ulBler:ulBlerThresholdRedirectData=90
...    NRCELL-13:ulBler:ulBlerThresholdRedirectVoNR=10
...    NRCELL-13:badULRedirectDeprioTimer=30min
...    NRCELL-13:actBadUplinkRadioRedirect=highUlBlerBased
...    NRCELL-13/NRREDRT-1:redirFreqNr=663360
...    NRCELL-13/NRREDRT-2:redirFreqNr=657984
...    NRCELL-13/NRREDRT-2:redirPrio=2

@{CNI-112127_VoNR_relate_gNB2}
...    NRCELL-13:actVoNR=true
...    NRBTS/NRDRB-15:discardTimer=10ms
...    NRBTS/NRDRB-15:discardTimerUl=infinity
...    NRBTS/NRDRB-15:dlFlowControlAlgo=none
...    NRBTS/NRDRB-15:drbInactivityTimerSA=10
...    NRBTS/NRDRB-15:dtxDelaySinceLastScheduling=0
...    NRBTS/NRDRB-15:dtxMaxRetentionDelay=10
...    NRBTS/NRDRB-15:l2OHFactorDl=16
...    NRBTS/NRDRB-15:l2OHFactorUl=35
...    NRBTS/NRDRB-15:maxDataRateGbrDl=1000
...    NRBTS/NRDRB-15:maxDataRateGbrUl=1000
...    NRBTS/NRDRB-15:maxForwardTimeLimitX2=50
...    NRBTS/NRDRB-15:maxRlcQueueingDelayGbr=20
...    NRBTS/NRDRB-15:maxTransferDelayGbr=20
...    NRBTS/NRDRB-15:minForwardTputX2=100
...    NRBTS/NRDRB-15:nrDrbMacDN=MRBTS-1/NRBTS-2/NRDRB_MAC-4
...    NRBTS/NRDRB-15:nrDrbPdcpDN=MRBTS-1/NRBTS-2/NRDRB_PDCP-3
...    NRBTS/NRDRB-15:nrDrbRlcUmDN=MRBTS-1/NRBTS-2/NRDRB_RLC_UM-1
...    NRBTS/NRDRB-15:pdcpStatRepWaitTimer=40
...    NRBTS/NRDRB-15:pdcpStatRepWaitTimerOffset=60
...    NRBTS/NRDRB-15:queuingDelayDiscarding=Disabled
...    NRBTS/NRDRB-15:resType=GBR
...    NRBTS/NRDRB-15:rlcMode=RLC_UM
...    NRBTS/NRDRB-15:schedulWeight=1
...    NRBTS/NRDRB-15:cellAggrLevel=Not FR1 CA eligible
...    NRBTS/NRDRB-15:nrDrbRlcAmDN=${EMPTY}
...    NRBTS/NRDRB_5QI-6:fiveqiValueList=1
...    NRBTS/NRDRB_5QI-6:nrDrbDN=MRBTS-1/NRBTS-2/NRDRB-15
...    NRBTS/NRDRB_MAC-4:delayTarget=50
...    NRBTS/NRDRB_MAC-4:lcgid=4
...    NRBTS/NRDRB_MAC-4:schedulBSD=100ms
...    NRBTS/NRDRB_PDCP-3:maxCidAllowed=4
...    NRBTS/NRDRB_PDCP-3:outOfOrderDeliveryDl=false
...    NRBTS/NRDRB_PDCP-3:outOfOrderDeliveryUl=false
...    NRBTS/NRDRB_PDCP-3:pdcpSNLengthRedCap=len18bits
...    NRBTS/NRDRB_PDCP-3:tReorderingDl=ms300
...    NRBTS/NRDRB_PDCP-3:xxFlowControlProfForCuIdx=1
...    NRBTS/NRDRB_RLC_UM-1:dlTReassemblyUm=ms50

@{PARAMS_ADJ_REL_FOR_GNB2}
...    NRBTS/NRADJGNB-1:administrativeState=Unlocked
...    NRBTS/NRADJGNB-1:gNbIdLength=22
...    NRBTS/NRADJGNB-1:gNodeBId=1
...    NRBTS/NRADJGNB-1:weightForIgnbCaSelection=50
...    NRBTS/NRADJGNB-1:xnLinkRef=1
...    NRBTS/NRADJGNB-1:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-1:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-12:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-12:fiveGsTac=200
...    NRBTS/NRADJNRCELL-12:gNbId=1
...    NRBTS/NRADJNRCELL-12:gNbIdLength=22
...    NRBTS/NRADJNRCELL-12:lcrId=12
...    NRBTS/NRADJNRCELL-12:nrarfcn=374000
...    NRBTS/NRADJNRCELL-12:physCellId=61
...    NRBTS/NRADJNRCELL-12:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-12:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-12:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-12:freqBandIndicatorNR=3
...    NRCELL-13/NRREL-12:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-13/NRREL-12:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-13/NRREL-12:gNbId=1
...    NRCELL-13/NRREL-12:gNbIdLength=22
...    NRCELL-13/NRREL-12:handoverAllowedSA=allowed
...    NRCELL-13/NRREL-12:lcrId=12
...    NRCELL-13/NRREL-12:removeNotAllowed=false
...    NRCELL-13/NRREL-12:sCellAdditionMethod=covBasedA1
...    NRCELL-13/NRREL-12:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-12:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-12:gnbPlmn:mncLength=3
...    NRCELL-13/NRREL-12:sCellOperationalMode=dlOnly
...    NRCELL-13:a1MeasSCellAddEnabled=rsrp
...    NRCELL-13:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=2
...    NRCELL-13:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=70
...    NRCELL-13:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=80
...    NRCELL-13:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms

@{gscn_Arfcn}
...    NRCELL-13:gscnOrSsPbchArfcn=4547
...    NRCELL-13/NRCELL_FDD-1:chBwDl=15MHz
...    NRCELL-13/NRCELL_FDD-1:chBwUl=15MHz
...    NRCELL-13/NRCELL_FDD-1:nrarfcnDl=364000
...    NRCELL-13/NRCELL_FDD-1:nrarfcnUl=345000

@{PARAMS_FOR_OTHERS}
...    NRBTS:actRanSharing=false
...    NRBTS:actHoOptimizationCa=true
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS:cipherPrefL:nea0=8
...    NRBTS:cipherPrefL:nea1_128=0
...    NRBTS:cipherPrefL:nea2_128=0
...    NRBTS:cipherPrefL:nea3_128=0
...    NRBTS:actIntraFreqHoSA=true
...    NRBTS:actInterFreqHoSA=true
...    NRPMRNL-1:miNrRelReportCu=5min

${ue_id}    1
${pdu_id}    1

@{FT 2CC check}
...    physCellId 50
...    SCellIndex 1 activated successfully at airphone

@{ho_succ}
...    Inter-eNB handover from EXT_ENB
...    physCellId 61
...    SCellIndex 1 activated successfully at airphone

${NRRCC_RRC_RELEASE_REDIR_NR}    M55124C01501
#The counter is updated when the RRC RELEASE with redirectedCarrierInfo IE and NR carrier frequency (ARFCN-ValueNR) is sent to UE.
${NG_FLOW_REL_GNB_REDIRECT_5QI1}    M55125C09502
#Number of 5QI-1 QoS Flows that are associated to PDU Session(s) released via NGAP: UE CONTEXT RELEASE REQUEST message with Cause Group IE
#set as "Radio Network Layer" and cause value set to "Redirection".
${NG_FLOW_REL_GNB_REDIRECT}    M55125C09002
#Number of QoS Flows that are associated to PDU Session(s) released via an NGAP: UE CONTEXT RELEASE REQUEST message with Cause Group IE
#set as "Radio Network Layer" and cause value set to "Redirection".
${NR_RRC_REL_REDIR_RAD_NR}    M55124C00521
#This counter provides the total number of RRC RELEASE messages with the redirectedCarrierInfo IE and NR carrier frequency for the redirections
#initiated due to a bad UL radio condition detection.

@{gNB1_PM_Counters_Check_005}
...    NRCELL-11:${NG_FLOW_REL_GNB_REDIRECT_5QI1}=1
...    NRCELL-11:${NG_FLOW_REL_GNB_REDIRECT}=3
...    NRCELL-11:NRRCC:${NRRCC_RRC_RELEASE_REDIR_NR}=1
...    NRCELL-11:NRRCC:${NR_RRC_REL_REDIR_RAD_NR}=1

@{gNB2_PM_Counters_Check_005}
...    NRCELL-13:${NG_FLOW_REL_GNB_REDIRECT_5QI1}=1
...    NRCELL-13:${NG_FLOW_REL_GNB_REDIRECT}=3
...    NRCELL-13:NRRCC:${NRRCC_RRC_RELEASE_REDIR_NR}=1
...    NRCELL-13:NRRCC:${NR_RRC_REL_REDIR_RAD_NR}=1


*** Test Cases ***
CNI-112127-ET-005_pcell_FDD_highUlBlerOrNackFlood_intergnb_CA_FT_deprioritisationTimer_5min_IWK_XNHO_trigger_HighUlBler_or_Nack_ue_redirect
    [Documentation]
    ...    1. This user scenario describes the gNb behaviour when gnb configured with highUlBlerOrNackFlood or
    ...       highUlBler,IWK with interGNB CA vonr call, and IWK with NG HO to intergnb , ul bler or nack trigger
    ...       redirect happened on FDD cell.
    ...    2. Configuration
    ...       GNB1 cell1_11, cell1_12 F+F
    ...       GNB2 cell2_1, cell2_2, cell2_13, cell2_14 T+T+F+F
    ...    [TL seting]: 2 classical cmWave gNb
    ...    [Cover Feature]: CNI-112127
    ...    [Configuration]:
    ...    GNB-1 Pri: cell11-FDD(n3)(pci:60) cell12-FDD(n3)(pci:61)
    ...    set_cell id=11 gnb=2 pci=20:0 tac=200 nrci=0x0B tdd_cell=off nr_arfcn=345000:364000 gscn=4547
    ...    set_cell id=12 gnb=2 pci=20:1 tac=200 nrci=0x0C tdd_cell=off nr_arfcn=355000:374000 gscn=4675
    ...    GNB-2 ext: cell1-TDD(n77)(pci:50) cell2-TDD(n77)(pci:51) cell13-FDD(n3)(pci:62) cell14-FDD(n28)(PCI63)
    ...    set_cell id=1 gnb=3 pci=16:2 tac=200 nrci=0x01 tdd_cell=on nr_arfcn=663400:663400 gscn=8159
    ...    set_cell id=2 gnb=3 pci=17:0 tac=200 nrci=0x02 tdd_cell=on nr_arfcn=658000:658000 gscn=8103
    ...    set_cell id=13 gnb=3 pci=20:2 tac=200 nrci=0x0D tdd_cell=off nr_arfcn=349400:368400 gscn=4605
    ...    set_cell id=14 gnb=3 pci=21:0 tac=200 nrci=0x0E tdd_cell=off nr_arfcn=143400:153400 gscn=1916

    ...    3.Test Case Steps:
    ...        a. UE1 Register, PDU Session Setup On cell1_11 and setup VoNR call.
    ...        b. UE1 send A5 MR with RSRP satisfied to trigger intra-frequency intergnb handover blind
    ...           add interGnb cell as scell.
    ...        c. Add UL Bler or Nack_flooding to make trigger redirect, and then delete UL Bler.
    ...        d. UE2 Register And PDU Session Setup On cell1_11, and setup VoNR call.
    ...        e. Add UL Bler or Nack_flooding to make trigger redirect, and then delete UL Bler.

    ...    4. Expected Results:
    ...         a. UE1 PDU Session Setup and VoNR call setup successfully. CA-FT(cell1_11+cell2_1)
    ...         b. Handover to cell2_13 and add cell1_12 as scell successfully. CA-FF(cell2_13+cell1_12)
    ...         c. UE1 trigger redirect.
    ...         d. UE2 PDU Session Setup and VoNR call setup successfully. CA-FT(cell1_11+cell2_1)
    ...         e. UE2 trigger redirect.

    [Tags]    005    QC_344648    CA_LABEL-FT(15Mhz_FDD_n3+100Mhz_TDD_n77)    CA_LABEL-FF(15Mhz_FDD_n3+15Mhz_FDD_n3)
    UE1 Traffic And VoNR Call
    Intrafreq InterGNB Handover
    UE1 Trigger UL Bler Active And Then Deactivate
    UE2 Traffic And VoNR Call
    UE2 Trigger UL Bler Active And Then Deactivate
    Check Wireshark Log    ${CURDIR}${/}A2A_005${/}a2a_gnb1.ini    wait_string=UEContextRelease::25
    Check WireShark Log GNB2    ${CURDIR}${/}A2A_005${/}a2a_gnb2.ini    wait_string=IgNBCAUeContextReleaseComplete::2
    Check Counters    ${gNB1_PM_Counters_Check_005}
    Check Counters GNB2    ${gNB2_PM_Counters_Check_005}
    Check userstop cause shall be correct
    [Teardown]    Teardown

*** Keywords ***
Modify Cfg
    Update Cfg    set_qosflow id=1 5qi=6 default=on
    Update Cfg    set_qosflow id=2 5qi=5
    Update Cfg    set_qosflow id=3 5qi=1
    Update Cfg    set_qosrule id=1 proto=tcp qos_flow=1
    Update Cfg    set_qosrule id=2 proto=udp qos_flow=2
    Update Cfg    set_qosrule id=3 proto=udp qos_flow=3
    Update Cfg    set_nwslice id=1 snssai=0x01:0xD143A5 default=on ue=all amf=1 qos_flows=1,2,3 qos_rules=1,2
    Update Cfg    ue_nr_capabilities id=1 voice_over_nr=on:on:off

Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup 2Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_gnb1_2F_gnb2_2T2F

Teardown
    Deactivate Bler Testmode    ue_id=1,2
    Common Test Teardown And Stop Capture Logs

UE Attach To Target Cell Then Send And Verify Throughput
    [Arguments]    ${cell_id}=11    ${ue_id}=1    ${pdu_id}=1    ${gw}=1
    Execute Egate Command    ue_param id=${ue_id} ue_nr_capabilities=${CB008140_GG_Capa_2CC_3CC_4CC_n3_n28_n77_n78}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    smf_param id=1 reset
    Execute Egate Command    qosflow_modify qos_flow=1 default=on
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=${gw} nwslice=1
    ...    pass_regexp=${FT 2CC check}    timeout=10s
    Send traffic    ${ue_id}
    Throughput Check    ue_id=${ue_id}    Tput=9    type=pusch
    Throughput Check    ue_id=${ue_id}    Tput=270    CC_num=2    type=pdsch

Intrafreq InterGNB Handover
    [Arguments]    ${ue_id}=1    ${carrierfreq}=363850    ${target_phycell_id}=62    ${pass_regexp}=${ho_succ}
    Execute Egate Command    ue_disp
    ${meas_id_scell}    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A5
    ${event_cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id_scell} event=A5
    ...    srsrp_nr=11 srsrq_nr=11 phycell_id=${target_phycell_id} nrsrp_nr=110 nrsrq_nr=110
    Execute Egate Command    ${event_cmd}
    ...    pass_regexp=${pass_regexp}
    sleep    15s    #wait for HO complete
    Throughput Check    ue_id=${ue_id}    Tput=9    type=pusch
    Throughput Check    ue_id=${ue_id}    Tput=200    CC_num=2    type=pdsch


Send traffic
    [Arguments]    ${ue_id}=1    ${pdu_id}=1
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=3    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=ul mbps=10 trf_id=1    UE ${ue_id}: UDP UL
    sleep    10s    #wait for stream

Throughput Check
    [Arguments]    ${ue_id}=1    ${Tput}=270    ${CC_num}=1    ${type}=pdsch
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-1 type=${type}    pass_regexp=Average
    ${all_tput}    set variable    0
    FOR    ${id}    IN RANGE    0    ${CC_num}
        ${id}=    convert to string    ${id}
        ${cell_tput}    Scell Throughput Check    ${ue_id}    ${id}    type=${type}
        ${all_tput}    Evaluate    ${all_tput}+${cell_tput}
	END
    Should Be True    ${all_tput}/1000 > ${Tput}

Scell Throughput Check
    [Arguments]    ${ue_id}=1    ${scell_id}=0    ${type}=pdsch
    [Return]    ${scell_tput}
    ${scell_tput}    Ap Get Throuput On Specific Scell     ue_id=${ue_id}    scell_id=${scell_id}    type=${type}    rate_type=ave
    Should Be True    ${scell_tput}/1000 > 0

Setup VONR Call On New PDU Session
    [Arguments]    ${ue_id}=1    ${gateway}=2    ${pdu}=2
    Execute Egate Command    qosflow_modify qos_flow=2 default=on
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu} nwslice=1 gw=${gateway}    pass_regexp=QoS Routing Table
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=2 qosflows_to_add=3 by=amf
        ...    pass_regexp=Received Pdu Session Resource Modify Response
    Execute Egate Command    qosflow_disp
    Throughput Check    ue_id=${ue_id}    Tput=9    type=pusch
    Throughput Check    ue_id=${ue_id}    Tput=200    CC_num=2    type=pdsch

Add UL Bler or Nack_flooding
    [Arguments]    ${ue_id}=1    ${profile_id}=1
    Execute Egate Command    bler_testmode_nr profile_id=${profile_id} ul_bler=800,800,800,800,800,800,800,800
    Execute Egate Command    ue_testmode_set_nr id=${ue_id} testmode=bler profile_id=${profile_id} action=activate
    Wait Until Keyword Succeeds    2min    5sec    Check Specific UE State    ${ue_id}    IDLE

Deactivate Bler Testmode
    [Arguments]    ${ue_id}=1    ${profile_id}=1
    Execute Egate Command    ue_testmode_set_nr id=${ue_id} testmode=bler profile_id=${profile_id} action=deactivate

UE1 Traffic And VoNR Call
    UE Attach To Target Cell Then Send And Verify Throughput
    Setup VONR Call On New PDU Session

UE1 Trigger UL Bler Active And Then Deactivate
    Add UL Bler or Nack_flooding
    Deactivate Bler Testmode

UE2 Traffic And VoNR Call
    UE Attach To Target Cell Then Send And Verify Throughput    ue_id=2    cell_id=11
    Setup VONR Call On New PDU Session    ue_id=2

UE2 Trigger UL Bler Active And Then Deactivate
    Add UL Bler or Nack_flooding    ue_id=2
    Deactivate Bler Testmode    ue_id=2

Check userstop cause shall be correct
    ${number_gNB1}=    Get Wireshark Message Count    ${SAVE LOG DIRECTORY}${/}wireshark.pcap    itf_l2_ps_user_RadioLinkStatusInd_t.ueRlStatus == 3
    should be equal As Numbers    ${number_gNB1}    1
    ${number_gNB2}=    Get Wireshark Message Count    ${SAVE LOG DIRECTORY}${/}gnb2${/}wireshark.pcap
    ...    itf_l2_ps_user_RadioLinkStatusInd_t.ueRlStatus == 3
    should be equal As Numbers    ${number_gNB2}    1
