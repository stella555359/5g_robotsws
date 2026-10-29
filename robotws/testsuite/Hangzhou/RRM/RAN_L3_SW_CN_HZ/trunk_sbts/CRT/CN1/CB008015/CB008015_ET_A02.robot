*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    CRT    RAN_5G    CLOUD_5G_I_BLLL_AP_LOO
...    team-DevHZ5_SG2    owner-nanxiao.ge    release-5G22R2    CB008015
Resource    ../../../../resources/DevHZ5_resource.robot


*** Variables ***
@{PARAMS_IN_SCF}    @{CB008015}    @{5GC001390}    @{CB006138}    @{BLL_AP_LOO}

@{5GC001390}    NRBTS/NRDU-1:actInterNumerologyCa=true
@{CB006138}
...    NRBTS/NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRBTS/NRDU-1:carrierAggregationSupportList=${CA_support_list}
${CA_support_list}    ca_Fr1Tdd_Fdd_Sa,ca_Fdd_Fdd,ca_Fdd_Fr1Tdd_Nsa,ca_Fr1Tdd_Nsa,ca_Fdd_Fr1Tdd_Sa,ca_Fr1Tdd_Sa

@{BLL_AP_LOO}
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1


@{CB008015}
...    NRBTS-1/NRCELL-1:beamSet:rightEdgeAngle=60
...    NRBTS-1/NRCELL-1:beamSet:basicBeamSet=beamSet_5_1
...    NRBTS-1/NRCELL-1:beamSet:nrBtsBeamRefinementP2=true
...    NRBTS-1/NRCELL-1:beamSet:leftEdgeAngle=60
...    NRBTS-1/NRCELL-1:beamSet:tiltOffset=0
...    NRBTS-1/NRCELL-1:actBeamforming=true
...    NRBTS-1/NRCELL-1:nrCellType=4DL2UL
...    NRBTS-1/NRCELL-2:beamSet:rightEdgeAngle=60
...    NRBTS-1/NRCELL-2:beamSet:basicBeamSet=beamSet_5_1
...    NRBTS-1/NRCELL-2:beamSet:nrBtsBeamRefinementP2=true
...    NRBTS-1/NRCELL-2:beamSet:leftEdgeAngle=60
...    NRBTS-1/NRCELL-2:beamSet:tiltOffset=0
...    NRBTS-1/NRCELL-2:actBeamforming=true
...    NRBTS-1/NRCELL-2:nrCellType=4DL2UL
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB

...    NRCELL-1/NRREL-1:gNbId=1
...    NRCELL-1/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-1:lcrId=2
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:removeNotAllowed=false
...    NRCELL-2/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRBTS-1/NRCELL:pucchModeSelect=longPucch
...    NRDU-1:actConnectedModeMobilityCA=true

...    NRCELL-2/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-1:gNbId=1
...    NRCELL-2/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-1:lcrId=11
...    NRCELL-2/NRREL-1:gNbIdLength=22
...    NRCELL-2/NRREL-1:removeNotAllowed=false

...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms160
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=20
...    NRCELL-1/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-1/NRHOIF-1:freqBandIndicatorNR=41
...    NRCELL-1/NRHOIF-1:numberOfTransmittedSsBlocks=6 beams
...    NRCELL-1/NRHOIF-1:a1BasedPCellSwitchEnabled=false
...    NRCELL-1/NRHOIF-1:a2BasedPCellSwitchEnabled=false
...    NRCELL-1/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-1:a3MeasEnabled=none
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-1/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-1/NRHOIF-1:ssbFrequency=518910
...    NRCELL-1/NRHOIF-1:a5MeasEnabled=none

...    NRCELL-11/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-1:gNbId=1
...    NRCELL-11/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-1:lcrId=1
...    NRCELL-11/NRREL-1:gNbIdLength=22
...    NRCELL-11/NRREL-1:removeNotAllowed=false
...    NRCELL-11/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-10:gNbId=1
...    NRCELL-11/NRREL-10:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-10:lcrId=2
...    NRCELL-11/NRREL-10:gNbIdLength=22
...    NRCELL-11/NRREL-10:removeNotAllowed=false
...    NRCELL-11/NRREL-3:gNbId=1
...    NRCELL-11/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-3:lcrId=12
...    NRCELL-11/NRREL-3:gNbIdLength=22
...    NRCELL-11/NRREL-3:removeNotAllowed=false
...    NRCELL-11/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-2:gNbId=1
...    NRCELL-11/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-2:lcrId=13
...    NRCELL-11/NRREL-2:gNbIdLength=22
...    NRCELL-11/NRREL-2:removeNotAllowed=false

...    NRBTS-1:actMeasBasedSCellAdditionNsa=true
...    NRBTS-1:actGrflShdn=true
...    NRBTS-1:actFdmEnhancedScheduling=true
...    NRBTS-1:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS-1:actFdmScheduling=true

...    NRCELL:a1MeasSCellAddEnabled=rsrp
...    NRCELL:actK1Opt=intra-gNB
...    NRCELL:actCDrx=true
...    NRCELL:actPrachMultiplexing=true
...    NRCELL:a2MeasSCellRelEnabled=rsrp
...    NRCELLGRP-3:numberOfTransmittedSsBlocks=6 beams
...    NRCELLGRP-4:numberOfTransmittedSsBlocks=6 beams

...    NRCELL-13/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-13/NRREL-3:gNbId=1
...    NRCELL-13/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-13/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-13/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-13/NRREL-3:lcrId=12
...    NRCELL-13/NRREL-3:gNbIdLength=22
...    NRCELL-13/NRREL-3:removeNotAllowed=false
...    NRCELL-13/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-13/NRREL-2:gNbId=1
...    NRCELL-13/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-13/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-13/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-13/NRREL-2:lcrId=11
...    NRCELL-13/NRREL-2:gNbIdLength=22
...    NRCELL-13/NRREL-2:removeNotAllowed=false
...    NRCELL-13/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-13/NRREL-1:gNbId=1
...    NRCELL-13/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-13/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-13/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-13/NRREL-1:lcrId=1
...    NRCELL-13/NRREL-1:gNbIdLength=22
...    NRCELL-13/NRREL-1:removeNotAllowed=false
...    NRCELL-13/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-13/NRREL-10:gNbId=1
...    NRCELL-13/NRREL-10:sCellAdditionMethod=covBasedA1
...    NRCELL-13/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-13/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-13/NRREL-10:lcrId=2
...    NRCELL-13/NRREL-10:gNbIdLength=22
...    NRCELL-13/NRREL-10:removeNotAllowed=false

...    NRCELL-12/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-2:gNbId=1
...    NRCELL-12/NRREL-2:sCellAdditionMethod=blind
...    NRCELL-12/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-2:lcrId=11
...    NRCELL-12/NRREL-2:gNbIdLength=22
...    NRCELL-12/NRREL-2:removeNotAllowed=false
...    NRCELL-12/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-3:gNbId=1
...    NRCELL-12/NRREL-3:sCellAdditionMethod=blind
...    NRCELL-12/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-3:lcrId=13
...    NRCELL-12/NRREL-3:gNbIdLength=22
...    NRCELL-12/NRREL-3:removeNotAllowed=false
...    NRCELL-12/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-10:gNbId=1
...    NRCELL-12/NRREL-10:sCellAdditionMethod=blind
...    NRCELL-12/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-10:lcrId=2
...    NRCELL-12/NRREL-10:gNbIdLength=22
...    NRCELL-12/NRREL-10:removeNotAllowed=false
...    NRCELL-12/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-1:gNbId=1
...    NRCELL-12/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-12/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-1:lcrId=1
...    NRCELL-12/NRREL-1:gNbIdLength=22
...    NRCELL-12/NRREL-1:removeNotAllowed=false

...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms160
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=20
...    NRCELL-11/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-11/NRHOIF-1:freqBandIndicatorNR=71
...    NRCELL-11/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-11/NRHOIF-1:a1BasedPCellSwitchEnabled=false
...    NRCELL-11/NRHOIF-1:a2BasedPCellSwitchEnabled=false
...    NRCELL-11/NRHOIF-1:ssBurstSetPeriod=10
...    NRCELL-11/NRHOIF-1:a3MeasEnabled=none
...    NRCELL-11/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-11/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-11/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-11/NRHOIF-1:ssbFrequency=126750
...    NRCELL-11/NRHOIF-1:a5MeasEnabled=none

...    NRCELL-12/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms160
...    NRCELL-12/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-12/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=25
...    NRCELL-12/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-12/NRHOIF-1:freqBandIndicatorNR=66
...    NRCELL-12/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-12/NRHOIF-1:a1BasedPCellSwitchEnabled=false
...    NRCELL-12/NRHOIF-1:a2BasedPCellSwitchEnabled=false
...    NRCELL-12/NRHOIF-1:ssBurstSetPeriod=10
...    NRCELL-12/NRHOIF-1:a3MeasEnabled=none
...    NRCELL-12/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-12/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-12/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-12/NRHOIF-1:ssbFrequency=424090
...    NRCELL-12/NRHOIF-1:a5MeasEnabled=none

${GNB_SCELL_1_ADMI_REQ_SA}        M55138C01501
${GNB_SCELL_1_ADMI_SUCC_SA}       M55138C01502
${GNB_SCELL_2_ADMI_REQ_SA}        M55138C02501
${GNB_SCELL_2_ADMI_SUCC_SA}       M55138C02502
${GNB_DU_SCELL_ADMI_REQ_SA}       M55139C01001
${GNB_DU_SCELL_ADMI_SUCC_SA}      M55139C01002
${GNB_DU_SCELL_1_ADMI_REQ_SA}     M55139C01003
${GNB_DU_SCELL_1_ADMI_SUCC_SA}    M55139C01004
${GNB_DU_SCELL_2_ADMI_REQ_SA}     M55139C01501
${GNB_DU_SCELL_2_ADMI_SUCC_SA}    M55139C01502

${SCELL_ACTIVATIONS}    M55316C09000

@{Counters_Check_CB008015_A02_UE82}
...    NRCELL-12:${GNB_SCELL_1_ADMI_REQ_SA}=1
...    NRCELL-12:${GNB_SCELL_1_ADMI_SUCC_SA}=1
...    NRCELL-13:${GNB_DU_SCELL_ADMI_REQ_SA}=1
...    NRCELL-13:${GNB_DU_SCELL_ADMI_SUCC_SA}=1
...    NRCELL-12:${GNB_DU_SCELL_1_ADMI_REQ_SA}=1
...    NRCELL-12:${GNB_DU_SCELL_1_ADMI_SUCC_SA}=1
...    NRCELL-13:${SCELL_ACTIVATIONS}=1

@{Counters_Check_CB008015_A02_UE83}
...    NRCELL-12:${GNB_SCELL_1_ADMI_REQ_SA}=1
...    NRCELL-12:${GNB_SCELL_1_ADMI_SUCC_SA}=1
...    NRCELL-1:${GNB_DU_SCELL_ADMI_REQ_SA}=1
...    NRCELL-1:${GNB_DU_SCELL_ADMI_SUCC_SA}=1
...    NRCELL-12:${GNB_DU_SCELL_1_ADMI_REQ_SA}=1
...    NRCELL-12:${GNB_DU_SCELL_1_ADMI_SUCC_SA}=1
...    NRCELL-1:${SCELL_ACTIVATIONS}=1

@{Counters_Check_CB008015_A02_UE84}
...    NRCELL-12:${GNB_SCELL_1_ADMI_REQ_SA}=1
...    NRCELL-12:${GNB_SCELL_1_ADMI_SUCC_SA}=1
...    NRCELL-2:${GNB_DU_SCELL_ADMI_REQ_SA}=1
...    NRCELL-2:${GNB_DU_SCELL_ADMI_SUCC_SA}=1
...    NRCELL-12:${GNB_DU_SCELL_1_ADMI_REQ_SA}=1
...    NRCELL-12:${GNB_DU_SCELL_1_ADMI_SUCC_SA}=1
...    NRCELL-2:${SCELL_ACTIVATIONS}=1

@{Counters_Check_CB008015_A02_UE85}
...    NRCELL-12:${GNB_SCELL_2_ADMI_REQ_SA}=1
...    NRCELL-12:${GNB_SCELL_2_ADMI_SUCC_SA}=1
...    NRCELL-12:${GNB_DU_SCELL_2_ADMI_REQ_SA}=1
...    NRCELL-12:${GNB_DU_SCELL_2_ADMI_SUCC_SA}=1
...    NRCELL-13:${GNB_DU_SCELL_ADMI_REQ_SA}=1
...    NRCELL-13:${GNB_DU_SCELL_ADMI_SUCC_SA}=1
...    NRCELL-11:${GNB_DU_SCELL_ADMI_REQ_SA}=1
...    NRCELL-11:${GNB_DU_SCELL_ADMI_SUCC_SA}=1
...    NRCELL-13:${SCELL_ACTIVATIONS}=1
...    NRCELL-11:${SCELL_ACTIVATIONS}=1

${ue_id}    82

*** Test Cases ***
CB008015-ET-A02_A_B2_blind scell addtion based on UE capability for SA call
    [Documentation]
    ...    1. The purpose of this test case is to check SCell selection based on UE capability for SA call.
    ...       UE 82: support N66_N71 CA
    ...       UE 83: support n71_n41；n66_n41 CA
    ...       UE 84: support n71_n78；n66_n78 CA
    ...       UE 85: support n66_n66_n71 CA
    ...    2. Test Case Steps:
    ...         a. SA UE-82, 83, 84, 85 are attached in cell 12.Blind SCell addition is triggered for
    ...            SA UE-82, 83, 84, 85  based on UE supported band combination.
    ...         b. Check scell activate/deactivate status based on the sCellActivationMethod.
    ...            check pscell and scell Tput are ok check pscell and scell Tput are ok.
    ...            check counters every round.
    ...         c. release the call for SA UE-82, 83, 84, 85
    ...    3. Expected Results:
    ...         Step a: Cell13,Cell1,Cell2,Cell13+Cell11 is added as scell.
    ...         Step b: M55138C01501 GNB_SCELL_1_ADMI_REQ_SA
    ...                 M55138C01502 GNB_SCELL_1_ADMI_SUCC_SA
    ...                 M55138C02501 GNB_SCELL_2_ADMI_REQ_SA
    ...                 M55138C02502 GNB_SCELL_2_ADMI_SUCC_SA
    ...                 M55139C01001 GNB_DU_SCELL_ADMI_REQ_SA
    ...                 M55139C01002 GNB_DU_SCELL_ADMI_SUCC_SA
    ...                 M55139C01003 GNB_DU_SCELL_1_ADMI_REQ_SA
    ...                 M55139C01004 GNB_DU_SCELL_1_ADMI_SUCC_SA
    ...                 M55139C01501 GNB_DU_SCELL_2_ADMI_REQ_SA
    ...                 M55139C01502 GNB_DU_SCELL_2_ADMI_SUCC_SA
    ...         Step c: Call release successfully.
    [Tags]    QC_128155
    [Timeout]    2 hours
    SA UE 82 Register At FDD Cell-12
    SA UE 83 Register At FDD Cell-12
    SA UE 84 Register At FDD Cell-12
    SA UE 85 Register At FDD Cell-12

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_2T4F

Modify Cfg
    ${UE83}    catenate
    ...  set_ue simulated id=83 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...   nea=null+snow3g+aes+zuc nia=null+snow3g+aes+zuc sec_key=0102030405060708090A0B0C0D0EFF00
    ...   suci=0:311:489:0000:0:0:021645483 enb=2 cell=11 mode=nr
    ${UE84}    catenate
    ...  set_ue simulated id=84 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...   nea=null+snow3g+aes+zuc nia=null+snow3g+aes+zuc sec_key=0102030405060708090A0B0C0D0EFF00
    ...   suci=0:311:489:0000:0:0:021645484 enb=2 cell=11 mode=nr
    ${UE85}    catenate
    ...  set_ue simulated id=85 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...   nea=null+snow3g+aes+zuc nia=null+snow3g+aes+zuc sec_key=0102030405060708090A0B0C0D0EFF00
    ...   suci=0:311:489:0000:0:0:021645485 enb=2 cell=11 mode=nr
    Update Cfg    ${UE83}
    Update Cfg    ${UE84}
    Update Cfg    ${UE85}
    Update Cfg    ue_param id=82 ue_nr_capabilities=${Capa_F2CC}
    Update Cfg    ue_param id=83 ue_nr_capabilities=${Capa_FT2CC}
    Update Cfg    ue_param id=84 ue_nr_capabilities=${Capa_FT2CC1}
    Update Cfg    ue_param id=85 ue_nr_capabilities=${Capa_FDD3}

SA UE 82 Register At FDD Cell-12
    [Arguments]    ${ue_id}=82
    Clear Counter Files
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=12
    Execute Egate Command    ue_register id=${ue_id}    NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal    sleep_time=5
    ${ret1}=    Execute Egate Command
    ...    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=1    activated successfully at airphone
    Should Contain    ${ret1}    physCellId 62
    Should Contain    ${ret1}    SCellIndex 1 activated successfully at airphone
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=70
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=ul mbps=10
    sleep    10s    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput}/1000>63
    Should Be True    ${ul_throughput}/1000>9.5
    Release Ues    ue_type=sa    ue_id=${ue_id}
    Check Counters    ${Counters_Check_CB008015_A02_UE82}

SA UE 83 Register At FDD Cell-12
    [Arguments]    ${ue_id}=83
    Clear Counter Files
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=12
    Execute Egate Command    ue_register id=${ue_id}    NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal    sleep_time=5
    ${ret1}=    Execute Egate Command
    ...    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=1    activated successfully at airphone
    Should Contain    ${ret1}    physCellId 50
    Should Contain    ${ret1}    SCellIndex 1 activated successfully at airphone
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=70
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=ul mbps=10
    sleep    10s    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput}/1000>63
    Should Be True    ${ul_throughput}/1000>9.5
    Release Ues    ue_type=sa    ue_id=${ue_id}
    Check Counters    ${Counters_Check_CB008015_A02_UE83}

SA UE 84 Register At FDD Cell-12
    [Arguments]    ${ue_id}=84
    Clear Counter Files
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=12
    Execute Egate Command    ue_register id=${ue_id}    NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal    sleep_time=5
    ${ret1}=    Execute Egate Command
    ...    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=1    activated successfully at airphone
    Should Contain    ${ret1}    physCellId 51
    Should Contain    ${ret1}    SCellIndex 1 activated successfully at airphone
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=70
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=ul mbps=10
    sleep    10s    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput}/1000>63
    Should Be True    ${ul_throughput}/1000>9.5
    Release Ues    ue_type=sa    ue_id=${ue_id}
    Check Counters    ${Counters_Check_CB008015_A02_UE84}

SA UE 85 Register At FDD Cell-12
    [Arguments]    ${ue_id}=85
    Clear Counter Files
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=12
    Execute Egate Command    ue_register id=${ue_id}    NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal    sleep_time=5
    ${ret1}=    Execute Egate Command
    ...    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=1    activated successfully at airphone
    Should Contain    ${ret1}    physCellId 62
    Should Contain    ${ret1}    physCellId 60
    Should Contain    ${ret1}    SCellIndex 1 activated successfully at airphone
    Should Contain    ${ret1}    SCellIndex 2 activated successfully at airphone
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=70
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=ul mbps=10
    sleep    10s    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput}/1000>63
    Should Be True    ${ul_throughput}/1000>9.5
    Release Ues    ue_type=sa    ue_id=${ue_id}
    Check Counters    ${Counters_Check_CB008015_A02_UE85}
