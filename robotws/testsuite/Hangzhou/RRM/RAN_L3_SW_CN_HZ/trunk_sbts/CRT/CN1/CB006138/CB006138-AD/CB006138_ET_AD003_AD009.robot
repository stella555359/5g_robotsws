*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    CRT    master_classicalbts_all    STATE_CONFIGURED
...               FR1    CN2    team-SG2    owner-cathy.mao    owner-dandan.chen    release-SBTS22R1
...               PRI-Medium    CB006138-AD    CLOUD_5G_I_BOO_AP_LOO
Resource         ../../../../../resources/DevHZ5_resource.robot


*** Variables ***
${TL_TYPE_PATH}    fddtdd_sansa_cmwv/6cells_4T2F

@{beamforming_enable}
...    NRCELL-1:nrCellType=4DL2UL
...    NRCELL-2:nrCellType=4DL2UL
...    NRCELL-3:nrCellType=4DL2UL
...    NRCELL-4:nrCellType=4DL2UL
...    NRCELL-1:dlMimoMode=4x4 or 4x2 Open Loop Spatial Multiplexing
...    NRCELL-2:dlMimoMode=4x4 or 4x2 Open Loop Spatial Multiplexing
...    NRCELL-3:dlMimoMode=4x4 or 4x2 Open Loop Spatial Multiplexing
...    NRCELL-4:dlMimoMode=4x4 or 4x2 Open Loop Spatial Multiplexing
...    NRBTS-1/NRCELL-1:actBeamforming=true
...    NRBTS-1/NRCELL-1:beamSet:basicBeamSet=beamSet_4
...    NRBTS-1/NRCELL-1:beamSet:leftEdgeAngle=60
...    NRBTS-1/NRCELL-1:beamSet:nrBtsBeamRefinementP2=false
...    NRBTS-1/NRCELL-1:beamSet:rightEdgeAngle=60
...    NRCELL-4:actBeamforming=true
...    NRCELL-4:beamSet:basicBeamSet=beamSet_4
...    NRCELL-4:beamSet:leftEdgeAngle=60
...    NRCELL-4:beamSet:nrBtsBeamRefinementP2=false
...    NRCELL-4:beamSet:rightEdgeAngle=60
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1


@{PARAMS_IN_SCF}
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRDU-1:actInterNumerologyCa=true
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:carrierAggregationSupportList=${CA_SUPPORT_LIST}
...    NRBTS-1:actLteNrDss=true
...    NRCELL:actCDrx=true
...    NRCELL:actK1Opt=intra-gNB
...    NRCELL:pucchF3ModulationScheme=pi2bpsk
...    NRCELL:pucchF3MaxCodeRate=zeroDot08
#...    NRBTS-1/NRCELL-1:actBeamforming=true
#...    NRBTS-1/NRCELL-1:beamSet:basicBeamSet=beamSet_4
#...    NRBTS-1/NRCELL-1:beamSet:leftEdgeAngle=60
#...    NRBTS-1/NRCELL-1:beamSet:nrBtsBeamRefinementP2=false
#...    NRBTS-1/NRCELL-1:beamSet:rightEdgeAngle=60
...    NRBTS-1/NRCELL-1:pucchF3MaxCodeRate=zeroDot08
...    NRBTS-1/NRCELL-1:actK1Opt=intra-gNB
...    NRBTS-1/NRCELL-1:pucchF3ModulationScheme=pi2bpsk
...    NRBTS-1/NRCELL-1:actCDrx=true
...    NRBTS-1/NRCELL-1:pucchModeSelect=longPucch
...    NRBTS-1/NRCELL-1:actPrachMultiplexing=true
...    NRCELLGRP-0:numberOfTransmittedSsBlocks=4 beams
...    NRCELLGRP-3:numberOfTransmittedSsBlocks=4 beams
...    NRBTS-1/NRCELL-11:pMax=380
...    NRBTS-1/NRCELL-11:pucchF3MaxCodeRate=zeroDot08
...    NRBTS-1/NRCELL-11:actK1Opt=intra-gNB
...    NRBTS-1/NRCELL-11:pucchF3ModulationScheme=pi2bpsk
...    NRBTS-1/NRCELL-11:actCDrx=true
...    NRBTS-1/NRCELL-11:pucchModeSelect=longPucch
...    NRBTS-1/NRCELL-11:actPrachMultiplexing=true
...    NRCELL-3:actVoNR=false
...    NRCELL-3:actCDrxVoNR=false
...    NRCELL-3:actEnhancedVoNR=false
...    NRCELL-3:actCDrx=true
...    NRCELL-3:drxProfile1:drxInactivityTimer=40ms
...    NRCELL-3:drxProfile1:drxLongCycle=80ms
...    NRCELL-3:drxProfile1:drxOnDurationTimer=10ms
...    NRCELL-3:drxProfile1:drxRetransTimerDl=16slot
...    NRCELL-3:drxProfile1:drxRetransTimerUl=16slot
...    NRCELL-3:drxProfile2:drxInactivityTimer=4ms
...    NRCELL-3:drxProfile2:drxLongCycle=40ms
...    NRCELL-3:drxProfile2:drxOnDurationTimer=6ms
...    NRCELL-3:drxProfile2:drxRetransTimerDl=0slot
...    NRCELL-3:drxProfile2:drxRetransTimerUl=0slot
...    NRCELL-3:pucchF3MaxCodeRate=zeroDot08
...    NRCELL-3:actK1Opt=intra-gNB
...    NRCELL-3:pucchF3ModulationScheme=pi2bpsk
...    NRCELL-3:pucchModeSelect=longPucch
...    NRCELL-3:actPrachMultiplexing=true
...    NRCELL-3/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-3/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-3/NRREL-1:gNbId=1
...    NRCELL-3/NRREL-1:gNbIdLength=22
...    NRCELL-3/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-3/NRREL-1:lcrId=11
...    NRCELL-3/NRREL-1:removeNotAllowed=false
...    NRCELL-3/NRREL-1:nrDcAllowed=false
...    NRCELL-3/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-3/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-3/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-3/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-3/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-3/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-3/NRREL-2:gNbId=1
...    NRCELL-3/NRREL-2:gNbIdLength=22
...    NRCELL-3/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-3/NRREL-2:lcrId=12
...    NRCELL-3/NRREL-2:removeNotAllowed=false
...    NRCELL-3/NRREL-2:nrDcAllowed=false
...    NRCELL-3/NRREL-2:sCellAdditionMethod=blind
...    NRCELL-3/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-3/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-3/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-4:actVoNR=false
...    NRCELL-4:actCDrxVoNR=false
...    NRCELL-4:actEnhancedVoNR=false
...    NRCELL-4:actCDrx=true
#...    NRCELL-4:actBeamforming=true
#...    NRCELL-4:beamSet:basicBeamSet=beamSet_4
#...    NRCELL-4:beamSet:leftEdgeAngle=60
#...    NRCELL-4:beamSet:nrBtsBeamRefinementP2=false
#...    NRCELL-4:beamSet:rightEdgeAngle=60
...    NRCELL-4:drxProfile1:drxInactivityTimer=40ms
...    NRCELL-4:drxProfile1:drxLongCycle=80ms
...    NRCELL-4:drxProfile1:drxOnDurationTimer=10ms
...    NRCELL-4:drxProfile1:drxRetransTimerDl=16slot
...    NRCELL-4:drxProfile1:drxRetransTimerUl=16slot
...    NRCELL-4:drxProfile2:drxInactivityTimer=4ms
...    NRCELL-4:drxProfile2:drxLongCycle=40ms
...    NRCELL-4:drxProfile2:drxOnDurationTimer=6ms
...    NRCELL-4:drxProfile2:drxRetransTimerDl=0slot
...    NRCELL-4:drxProfile2:drxRetransTimerUl=0slot
...    NRCELL-4:pucchF3MaxCodeRate=zeroDot08
...    NRCELL-4:actK1Opt=intra-gNB
...    NRCELL-4:pucchF3ModulationScheme=pi2bpsk
...    NRCELL-4/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-4/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-4/NRREL-1:gNbId=1
...    NRCELL-4/NRREL-1:gNbIdLength=22
...    NRCELL-4/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-4/NRREL-1:lcrId=1
...    NRCELL-4/NRREL-1:removeNotAllowed=false
...    NRCELL-4/NRREL-1:nrDcAllowed=false
...    NRCELL-4/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-4/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-4/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-4/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-4/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-4/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-4/NRREL-2:gNbId=1
...    NRCELL-4/NRREL-2:gNbIdLength=22
...    NRCELL-4/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-4/NRREL-2:lcrId=11
...    NRCELL-4/NRREL-2:removeNotAllowed=false
...    NRCELL-4/NRREL-2:nrDcAllowed=false
...    NRCELL-4/NRREL-2:sCellAdditionMethod=blind
...    NRCELL-4/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-4/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-4/NRREL-2:gnbPlmn:mncLength=3
...    @{beamforming_enable}
...    @{Change_Golden_Band}


@{Change_Golden_Band}
...    NRCELL-4:freqBandIndicatorNR=41
...    NRCELL-4:gscnOrSsPbchArfcn=6582
...    NRCELL-4:nrarfcn=526020
...    NRCELL-11:freqBandIndicatorNR=66
...    NRCELL-11:gscnOrSsPbchArfcn=5300
...    NRCELL-11/NRCELL_FDD-1:chBwDl=20MHz
...    NRCELL-11/NRCELL_FDD-1:chBwUl=20MHz
...    NRCELL-11/NRCELL_FDD-1:nrarfcnDl=424000
...    NRCELL-11/NRCELL_FDD-1:nrarfcnUl=344000



${CA_SUPPORT_LIST}    ca_Fr1Tdd_Any_Sa,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Fr1Tdd_Nsa,ca_Fdd_Fdd,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Nsa,ca_Fr1Tdd_Fdd_Sa

@{VALID_SCELL_ADD_AD003}
...    NRCELL-3:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL-3:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=75
...    NRCELL-3:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=95
...    NRCELL-3:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=0ms
...    NRCELL-3:a1MeasSCellAddEnabled=rsrp
...    NRCELL-3/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-3/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRBTS-1:actMeasBasedSCellAdditionSa=A1-based
...    NRCELL-11:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0
...    NRCELL-11:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=34
...    NRCELL-11:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-11:a2MeasSCellRelEnabled=rsrp
...    NRCELL-12:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0
...    NRCELL-12:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=35
...    NRCELL-12:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-12:a2MeasSCellRelEnabled=rsrp

@{origin_params_AD003}
...    NRCELL-3:a1MeasSCellAddEnabled=none
...    NRCELL-3/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-3/NRREL-2:sCellAdditionMethod=blind
...    NRBTS-1:actMeasBasedSCellAdditionSa=disabled
...    NRCELL-11:a2MeasSCellRelEnabled=none
...    NRCELL-12:a2MeasSCellRelEnabled=none


@{VALID_SCELL_ADD_AD009}
...    NRBTS:actInterFreqHoSA=true
...    NRCELL:measGapSelection=favourUeThroughput
...    NRCELL-4:a1MeashoEnabledSA=rsrp
...    NRCELL-4:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=80
...    NRCELL-4:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=20
...    NRCELL-4:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL-4:a2MeashoEnabledSA=rsrp
...    NRCELL-4:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=80
...    NRCELL-4:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=26
...    NRCELL-4:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms40
...    NRCELL-4:ifhoSsbSmtcOffset=0
...    NRCELL-4/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-4/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-4/NRREL-10:gNbId=1
...    NRCELL-4/NRREL-10:gNbIdLength=22
...    NRCELL-4/NRREL-10:handoverAllowedSA=allowed
...    NRCELL-4/NRREL-10:lcrId=2
...    NRCELL-4/NRREL-10:nrDcAllowed=false
...    NRCELL-4/NRREL-10:removeNotAllowed=false
...    NRCELL-4/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-4/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-4/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-4/NRHOIF-1:a1BasedPCellSwitchEnabled=false
...    NRCELL-4/NRHOIF-1:a2BasedPCellSwitchEnabled=false
...    NRCELL-4/NRHOIF-1:a4MeasEnDcSteeringEnabled=none
...    NRCELL-4/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-4/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-4/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=25
...    NRCELL-4/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL-4/NRHOIF-1:a4MeasHigherPrioFreqEnabled=none
...    NRCELL-4/NRHOIF-1:a4MeasNrDcEnabled=none
...    NRCELL-4/NRHOIF-1:a5MeasEnabled=none
...    NRCELL-4/NRHOIF-1:cellDepType=SA
...    NRCELL-4/NRHOIF-1:freqBandIndicatorNR=78
...    NRCELL-4/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-4/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-4/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-4/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-4/NRHOIF-1:scs=30 KHz
...    NRCELL-4/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-4/NRHOIF-1:ssbFrequency=648096

@{origin_params_AD009}
...    NRBTS:actInterFreqHoSA=false
...    NRCELL-4:a1MeashoEnabledSA=none
...    NRCELL-4:a2MeashoEnabledSA=none



${TDD_SCELL_FOR_NRCELL4}    NRCELL-1
${FDD_SCELL_FOR_NRCELL4}    NRCELL-11

${FDD_SCELL1_FOR_NRCELL3}    NRCELL-11
${FDD_SCELL2_FOR_NRCELL3}    NRCELL-12


&{CELLS_SSBFREQ}
...     1=632736
...     2=648096
...     3=508110
...     4=526590
...     11=424090
...     12=126750

${UE_PCELL_2_CONF_SCELL_DL_SA}    M55118C07001    #Sum of CA UEs in the current cell configured as a PCell, which have 2 configured SCells in DL
${RRC_RECONF_ADD2DLSCELL_SUCC_SA}    M55118C07003    #Successful RRC Reconfigurations attempts for 2 SCells Addition in DL for SA mode
${RRC_RECONF_ADD2DLSCELL_ATT_SA}    M55118C07004    #RRC Reconfigurations attempts for 2 SCells Addition in DL for SA mode
${UE_SCELL_2_CONF_SCELL_DL_SA}    M55118C07002    #Sum of CA UEs in the current cell configured as a SCell, which have 2 configured SCells in DL


${UE_PCELL_1_CONF_SCELL_DL_SA}    M55118C05507

@{PM_COUNTER_AD003}
...     NRCELL-3:${UE_PCELL_1_CONF_SCELL_DL_SA}>0
...     NRCELL-11:${UE_SCELL_2_CONF_SCELL_DL_SA}>0
...     NRCELL-12:${UE_SCELL_2_CONF_SCELL_DL_SA}>0

@{PM_COUNTER_AD009}
...     NRCELL-4:${UE_PCELL_2_CONF_SCELL_DL_SA}>0
...     NRCELL-1:${UE_SCELL_2_CONF_SCELL_DL_SA}>0
...     NRCELL-11:${UE_SCELL_2_CONF_SCELL_DL_SA}>0
...     NRCELL-4:${RRC_RECONF_ADD2DLSCELL_SUCC_SA}==1
...     NRCELL-4:${RRC_RECONF_ADD2DLSCELL_ATT_SA}==1

*** Test Cases ***
CB006138-ET-AD003_Verify_SA_3CC_TFF_with_scell_covBasedA1_and_Scell_Release_via_A2_report_interact_with_CommonDRX
    [Documentation]
    ...    1. The purpose of this test case is to verify Interworking with DRX when UE has no VoNR call running
    ...    2.Test Case Steps:
    ...         step1.start capture tcpdump
    ...         Excepted Results:
    ...         step2.attach CA UE,(008:add vonr before scell) scell covBasedA1 (006:add vonr after scell) added, traffic is ok
    ...         Excepted Results:
    ...         Step3: trigger A2 scell release for multi scells
    ...         Excepted Results:
    ...         Step4: check wireshark and counters
    ...         Excepted Results:
    [Tags]    CB006138-AD003    QC_133904
    [Timeout]    60 min
    Before_ue_attach_AD003
    UE Attach and L3 Normal Call    ue_id=81    pdu_gw_id=1
    Triggered Scell Addition by A1    pcell=3
    Check Two Scell Added Successfully    NRCELL-3    ${FDD_SCELL1_FOR_NRCELL3}    ${FDD_SCELL2_FOR_NRCELL3}
    Verify Throuput on Pscell and Scell    ue_id=81    pdu_gw_id=1
    Release Scell    11    12    ue_id=81
    Verify SA DL and UL Traffic    ue_id=81    pdu_gw_id=1
    Check WireShark Log    ${CURDIR}${/}a2a_AD003${/}a2a.ini
    ...    wait_string=UEContextModificationResponse::28
    Check Counters    ${PM_COUNTER_AD003}
    Release Ues    ue_type=all
    [Teardown]    Recover Param and Common Test Teardown    ${origin_params_AD003}


CB006138-ET-AD009_Verify_SA_3CC_TTF_removal_A3_rsrp_interFreq_and_gaprelease_then_config_A2_after_receipt_A1_MR_perFR
    [Documentation]
    ...    The purpose of the case is to verify when UE configured with carrier aggregation triggers A1 measurement
    ...    report with the purpose to release Inter-frequency or/and inter-RAT measurements.
    ...    gNB shall internally release measurement gaps on all carriers.
    ...    Case steps:
    ...    Step 1: Attach UE to cell4, (cell1&11 shall be selected as SCell candidate)
    ...    Expected Result: attach successfully, SA call setup successfully, scell addition successfully,
    ...    Scell activated successfully
    ...    Step 2:trigger A2 measurement report for interFreq HO
    ...    Expected Result:NRHOIF A3 and A1 event configured for UE, MeasGap perFR is setup
    ...    Step 3:trigger A1 measurement report to release interFrequency HO
    ...    Expected Result:receives A1 measurement report from UE, removal of A1 and Inter-frequency A3/A5,
    ...    configure A2 measurements release measurement gap configuration, DRX is setup
    ...    Step 4:Detach UE
    ...    Expected Result: Detach UE success .
    ...    check the counter: 'M55118C07001', 'M55118C07002', 'M55118C07003', 'M55118C07004'
    [Tags]    CB006138-AD009    Owner_jejing    QC_133905
    [Timeout]    60 min
    Before_ue_attach_AD009
    UE Attach and L3 Call    ue_id=81    pdu_gw_id=2
    Check Two Scell Added Successfully    NRCELL-4    ${TDD_SCELL_FOR_NRCELL4}    ${FDD_SCELL_FOR_NRCELL4}
    Trigger A2 and A1 MR Received    pcell=4
    traffic_should_be_ok    ue_id=81    type=SA    pdu=2
    Check WireShark Log    ${CURDIR}${/}a2a_AD009${/}a2a.ini
    ...    wait_string=UEContextModificationResponse::32
    Check Counters    ${PM_COUNTER_AD009}
    Release Ues    ue_type=all
    [Teardown]    Recover Param and Common Test Teardown    ${origin_params_AD009}


*** Keywords ***
Verify Throuput on Pscell and Scell
    [Arguments]    ${ue_id}    ${pdu_gw_id}
    Sleep    15s
    ${ret0}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-5 type=pdsch    pass_regexp=Average
    Execute Egate Command    ue_disp
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000 > 100
    ${scell1_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=1    type=pdsch    rate_type=ave
    Should Be True    ${scell1_tput}/1000 > 0
    ${scell2_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=2    type=pdsch    rate_type=ave
    #Should Be True    ${scell2_tput}/1000 > 0
    Should Be True    ${scell0_tput}/1000+${scell1_tput}/1000+${scell2_tput}/1000 > 540
    Verify SA DL and UL Traffic    ${ue_id}    ${pdu_gw_id}

Verify SA DL and UL Traffic
    [Arguments]    ${ue_id}    ${pdu_gw_id}
    Sleep    15s
    ${ul_throuput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_gw_id}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${ul_throuput}/1000>9
    ${dl_throuput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_gw_id}    qfi=1    direction=dl    rate_type=ave
    Should Be True    ${dl_throuput}/1000>540

Before_ue_attach_AD003
    Delta Commission Parameters     ${VALID_SCELL_ADD_AD003}
    Execute Egate Command    ue_change_location id=81 enb=2 cell=3
    Clear Counter Files
    Start RRC Log    AD003

Before_ue_attach_AD009
    Delta Commission Parameters     ${VALID_SCELL_ADD_AD009}
    Execute Egate Command    ue_change_location id=81 enb=2 cell=4
    Clear Counter Files
    Start RRC Log    AD009

UE Attach and L3 Call
    [Arguments]    ${ue_id}    ${pdu_gw_id}
    Execute Egate Command    qosflow_modify qos_flow=1 default=on
    Execute Egate Command    ue_register id=${ue_id}     pass_regexp=Received REGISTRATION COMPLETE
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_gw_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup pdu=${pdu_gw_id} ue=${ue_id} nwslice=1 gw=${pdu_gw_id}
    ...                      pass_regexp=Initial Context Setup Successful
    Execute Egate Command    qosflow_disp
    traffic_should_be_ok    ue_id=${ue_id}    type=SA    pdu=${pdu_gw_id}

Check Two Scell Added Successfully
    [Arguments]    ${pcell}    ${scell1}    ${scell2}
    ${NRREL1_sCellAdditionMethod}    Get Scf Parameter Value    MRBTS-1/NRBTS-1/${pcell}/NRREL-1:sCellAdditionMethod
    ${NRREL2_sCellAdditionMethod}    Get Scf Parameter Value    MRBTS-1/NRBTS-1/${pcell}/NRREL-2:sCellAdditionMethod
    ${SCELL1_physCellId}    Get Scf Parameter Value    ${scell1}:physCellId
    ${SCELL2_physCellId}    Get Scf Parameter Value    ${scell2}:physCellId
    Rrc Should Contain    sCellToAddModList    physCellId ${SCELL1_physCellId}    physCellId ${SCELL2_physCellId}

UE Attach and L3 Normal Call
    [Arguments]    ${ue_id}    ${pdu_gw_id}
    Execute Egate Command    qosflow_modify qos_flow=1 default=on
    Execute Egate Command    ue_register id=${ue_id}     pass_regexp=Received REGISTRATION COMPLETE
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_gw_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup pdu=${pdu_gw_id} ue=${ue_id} nwslice=1 gw=${pdu_gw_id}
    ...                      pass_regexp=Initial Context Setup Successful
    Execute Egate Command    qosflow_disp
    Start Traffic    ${ue_id}    ${pdu_gw_id}

Start Traffic
    [Arguments]    ${ue_id}    ${pdu_gw_id}
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_gw_id} qfi=1 dir=dl mbps=100 trf_id=2
    ...    pass_regexp=UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_gw_id} qfi=1 dir=dl mbps=100 trf_id=3
    ...    pass_regexp=UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_gw_id} qfi=1 dir=dl mbps=100 trf_id=4
    ...    pass_regexp=UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_gw_id} qfi=1 dir=dl mbps=100 trf_id=5
    ...    pass_regexp=UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_gw_id} qfi=1 dir=dl mbps=100 trf_id=6
    ...    pass_regexp=UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_gw_id} qfi=1 dir=dl mbps=100 trf_id=7
    ...    pass_regexp=UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_gw_id} qfi=1 dir=ul mbps=10
    ...    pass_regexp=UE ${ue_id}: UDP UL

Triggered Scell Addition by A1
    [Arguments]    ${pcell}    ${ue_id}=81    ${rsrp}=120    ${rsrq}=120    ${scell_num}=2
    Execute Egate Command    ue_disp
    ${pcell_ssbfreq}    Get From Dictionary    ${CELLS_SSBFREQ}    ${pcell}
    ${meas_id}    Get Nr Meas Id For Specific Type And Frequency    ${ue_id}    ${pcell_ssbfreq}    A1
    Execute Egate Command
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=${rsrp} srsrq_nr=${rsrq}
    ...    pass_regexp=SCellIndex ${scell_num} activated successfully

Recover Param and Common Test Teardown
    [Arguments]     ${origin_params}
    Delta Commission Parameters     ${origin_params}
    Common Test Teardown And Stop Capture Logs

Trigger A2 and A1 MR Received
    [Arguments]    ${pcell}    ${ue_id}=81
    Execute Egate Command    ue_disp
    ${pcell_ssbfreq}    Get From Dictionary    ${CELLS_SSBFREQ}    ${pcell}
    ${a2_meas_id}    Get Nr Meas Id For Specific Type And Frequency    ${ue_id}    ${pcell_ssbfreq}    A2
    Execute Egate Command
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${a2_meas_id} event=A2 srsrp_nr=30 srsrq_nr=30
    ...    pass_regexp=ReconfigurationComplete
    ${a1_meas_id}    Get Nr Meas Id For Specific Type And Frequency    ${ue_id}    ${pcell_ssbfreq}    A1
    Execute Egate Command
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${a1_meas_id} event=A1 srsrp_nr=60 srsrq_nr=60
    ...    pass_regexp=ReconfigurationComplete

Release Scell
    [Arguments]      @{scell_list}    ${ue_id}=81
    ${scell_index}    set variable    1
    FOR    ${scell}    IN    @{scell_list}
        ${ssbfreq}     Get From Dictionary    ${CELLS_SSBFREQ}     ${scell}
        ${meas_id}    Get Nr Meas Id For Specific Type And Frequency    ${ue_id}    ${ssbfreq}    A2
        ${release_cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2
        ...    scell=${scell_index} scell_rsrp=20 scell_rsrq=20
        Execute Egate Command    ${release_cmd}    pass_regexp=sCellToReleaseList
        ${scell_index}    evaluate    ${scell_index}+1
    END
