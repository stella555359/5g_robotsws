*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_FDD    CRT    CLOUD_5G_I_BLLL_AP_LOO
...     owner-selena.ye    team-SG2    release-5G22R2    CB008015    SBTS00
Resource    ../../../../../resources/DevHZ5_resource.robot


*** Variables ***
${DEBUG_LOG_LEVEL}    0

${GNB_BIP_FLAG}    True

@{PARAMS_IN_SCF}    @{5GC001390}    @{CB006138}    @{CB008015}    @{OPEN_BEAMFORMING}

@{5GC001390}    NRDU-1:actInterNumerologyCa=true
@{CB006138}
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:carrierAggregationSupportList=${CA_SUPPORT_LIST}
${CA_SUPPORT_LIST}    ca_Fr1Tdd_Sa,ca_Fdd_Fdd,ca_Fdd_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fdd_Fr1Tdd_Nsa,ca_Fr1Tdd_Nsa
@{CB008015}
...    NRCELL:actK1Opt=intra-gNB
...    NRBTS-1:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS-1:actMeasBasedSCellAdditionNsa=true
...    NRBTS-1:actGrflShdn=true
...    NRBTS-1:actFdmEnhancedScheduling=true
...    NRBTS-1:actFdmScheduling=true
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRCELL:actPrachMultiplexing=true
...    NRCELL:a2MeasSCellRelEnabled=rsrp
...    NRCELL:a1MeasSCellAddEnabled=rsrp
...    NRCELL:actCDrx=true
...    NRCELL-11/NRREL:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL:sCellAdditionMethod=covBasedA1
...    NRCELL-13/NRREL:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-10:gNbId=1
...    NRCELL-11/NRREL-10:gNbIdLength=22
...    NRCELL-11/NRREL-10:lcrId=2
...    NRCELL-11/NRREL-10:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-10:removeNotAllowed=false
...    NRCELL-11/NRREL-10:nrDcAllowed=false
...    NRCELL-11/NRREL-10:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-2:gNbId=1
...    NRCELL-12/NRREL-2:gNbIdLength=22
...    NRCELL-12/NRREL-2:lcrId=11
...    NRCELL-12/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-12/NRREL-2:removeNotAllowed=false
...    NRCELL-12/NRREL-2:nrDcAllowed=false
...    NRCELL-12/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-13/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-13/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-13/NRREL-10:gNbId=1
...    NRCELL-13/NRREL-10:gNbIdLength=22
...    NRCELL-13/NRREL-10:lcrId=2
...    NRCELL-13/NRREL-10:sCellOperationalMode=dlOnly
...    NRCELL-13/NRREL-10:removeNotAllowed=false
...    NRCELL-13/NRREL-10:nrDcAllowed=false
...    NRCELL-13/NRREL-10:sCellAdditionMethod=covBasedA1
...    NRCELL-13/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-13/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-13/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-13/NRREL-2:gNbId=1
...    NRCELL-13/NRREL-2:gNbIdLength=22
...    NRCELL-13/NRREL-2:lcrId=11
...    NRCELL-13/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-13/NRREL-2:removeNotAllowed=false
...    NRCELL-13/NRREL-2:nrDcAllowed=false
...    NRCELL-13/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-13/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-10:gNbId=1
...    NRCELL-12/NRREL-10:gNbIdLength=22
...    NRCELL-12/NRREL-10:lcrId=2
...    NRCELL-12/NRREL-10:sCellOperationalMode=dlOnly
...    NRCELL-12/NRREL-10:removeNotAllowed=false
...    NRCELL-12/NRREL-10:nrDcAllowed=false
...    NRCELL-12/NRREL-10:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-1:gNbId=1
...    NRCELL-2/NRREL-1:gNbIdLength=22
...    NRCELL-2/NRREL-1:lcrId=11
...    NRCELL-12/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-2/NRREL-1:removeNotAllowed=false
...    NRCELL-2/NRREL-1:nrDcAllowed=false
...    NRCELL-2/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-11/NRHOIF-1:a1BasedPCellSwitchEnabled=true
...    NRCELL-11/NRHOIF-1:a2BasedPCellSwitchEnabled=false
...    NRCELL-11/NRHOIF-1:a3MeasEnabled=none
...    NRCELL-11/NRHOIF-1:a5MeasEnabled=none
...    NRCELL-11/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-11/NRHOIF-1:freqBandIndicatorNR=71
...    NRCELL-11/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-11/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-11/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-11/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-11/NRHOIF-1:ssBurstSetPeriod=10
...    NRCELL-11/NRHOIF-1:ssbFrequency=126750
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=20
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms160
...    NRCELL-12/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-1:gNbId=1
...    NRCELL-12/NRREL-1:gNbIdLength=22
...    NRCELL-12/NRREL-1:lcrId=1
...    NRCELL-12/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-12/NRREL-1:removeNotAllowed=false
...    NRCELL-12/NRREL-1:nrDcAllowed=false
...    NRCELL-12/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-3:gNbId=1
...    NRCELL-11/NRREL-3:gNbIdLength=22
...    NRCELL-11/NRREL-3:lcrId=12
...    NRCELL-11/NRREL-3:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-3:removeNotAllowed=false
...    NRCELL-11/NRREL-3:nrDcAllowed=false
...    NRCELL-11/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-13/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-13/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-13/NRREL-1:gNbId=1
...    NRCELL-13/NRREL-1:gNbIdLength=22
...    NRCELL-13/NRREL-1:lcrId=1
...    NRCELL-13/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-13/NRREL-1:removeNotAllowed=false
...    NRCELL-13/NRREL-1:nrDcAllowed=false
...    NRCELL-13/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-13/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-13/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-13/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-13/NRREL-3:gNbId=1
...    NRCELL-13/NRREL-3:gNbIdLength=22
...    NRCELL-13/NRREL-3:lcrId=12
...    NRCELL-13/NRREL-3:sCellOperationalMode=dlOnly
...    NRCELL-13/NRREL-3:removeNotAllowed=false
...    NRCELL-13/NRREL-3:nrDcAllowed=false
...    NRCELL-13/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-13/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-1:gNbId=1
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:lcrId=2
...    NRCELL-1/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-1:removeNotAllowed=false
...    NRCELL-1/NRREL-1:nrDcAllowed=false
...    NRCELL-1/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-2:gNbId=1
...    NRCELL-11/NRREL-2:gNbIdLength=22
...    NRCELL-11/NRREL-2:lcrId=13
...    NRCELL-11/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-2:removeNotAllowed=false
...    NRCELL-11/NRREL-2:nrDcAllowed=false
...    NRCELL-11/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-1/NRHOIF-1:a1BasedPCellSwitchEnabled=false
...    NRCELL-1/NRHOIF-1:a2BasedPCellSwitchEnabled=true
...    NRCELL-1/NRHOIF-1:a3MeasEnabled=none
...    NRCELL-1/NRHOIF-1:a5MeasEnabled=none
...    NRCELL-1/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-1/NRHOIF-1:freqBandIndicatorNR=71
...    NRCELL-1/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-1/NRHOIF-1:ssBurstSetPeriod=10
...    NRCELL-1/NRHOIF-1:ssbFrequency=126750
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=20
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms160
...    NRCELL-1/NRHOIF-1:a2BasedPCellSwitchPriority=1
...    NRCELL-1/NRHOIF-1:thresholdPCellSwitchTargetRsrp=122
...    NRCELL-1/NRHOIF-1:thresholdPCellSwitchTargetRsrq=2
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-1:gNbId=1
...    NRCELL-11/NRREL-1:gNbIdLength=22
...    NRCELL-11/NRREL-1:lcrId=1
...    NRCELL-11/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-1:removeNotAllowed=false
...    NRCELL-11/NRREL-1:nrDcAllowed=false
...    NRCELL-11/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-12/NRHOIF-1:a1BasedPCellSwitchEnabled=true
...    NRCELL-12/NRHOIF-1:a2BasedPCellSwitchEnabled=false
...    NRCELL-12/NRHOIF-1:a3MeasEnabled=none
...    NRCELL-12/NRHOIF-1:a5MeasEnabled=none
...    NRCELL-12/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-12/NRHOIF-1:freqBandIndicatorNR=41
...    NRCELL-12/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-12/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-12/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-12/NRHOIF-1:numberOfTransmittedSsBlocks=6 beams
...    NRCELL-12/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-12/NRHOIF-1:ssbFrequency=518910
...    NRCELL-12/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-12/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=25
...    NRCELL-12/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms160
...    NRCELL-12/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-3:gNbId=1
...    NRCELL-12/NRREL-3:gNbIdLength=22
...    NRCELL-12/NRREL-3:lcrId=13
...    NRCELL-12/NRREL-3:sCellOperationalMode=dlOnly
...    NRCELL-12/NRREL-3:removeNotAllowed=false
...    NRCELL-12/NRREL-3:nrDcAllowed=false
...    NRCELL-12/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-3:gnbPlmn:mncLength=3
...    MRBTS-1/NRBTS-1:actHoOptimizationCa=true
...    NRBTS-1/NRCELL:pucchModeSelect=longPucch
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeasPCellSwitchEnabled=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeasPCellSwitchSsbRsrp:a1HysteresisPCellSwitchSsbRsrp=0
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeasPCellSwitchSsbRsrp:a1ThresholdPCellSwitchSsbRsrp=125
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeasPCellSwitchSsbRsrp:a1TimeToTriggerPCellSwitchSsbRsrp=0ms
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeasPCellSwitchEnabled=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeasPCellSwitchSsbRsrp:a2HysteresisPCellSwitchSsbRsrp=0
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeasPCellSwitchSsbRsrp:a2ThresholdPCellSwitchSsbRsrp=120
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeasPCellSwitchSsbRsrp:a2TimeToTriggerPCellSwitchSsbRsrp=0ms
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeasPCellSwitchSsbRsrp:pCellSwitchOffsetSsbRsrp=1
...    MRBTS-1/NRBTS-1/NRCELL-12:a1MeasPCellSwitchEnabled=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-12:a1MeasPCellSwitchSsbRsrp:a1HysteresisPCellSwitchSsbRsrp=0
...    MRBTS-1/NRBTS-1/NRCELL-12:a1MeasPCellSwitchSsbRsrp:a1ThresholdPCellSwitchSsbRsrp=65
...    MRBTS-1/NRBTS-1/NRCELL-12:a1MeasPCellSwitchSsbRsrp:a1TimeToTriggerPCellSwitchSsbRsrp=0ms

...    NRCELL-1:msg1FrequencyStart=19
...    NRCELL-2:msg1FrequencyStart=19
...    NRCELL-11:msg1FrequencyStart=9
...    NRCELL-12:msg1FrequencyStart=12
...    NRCELL-13:msg1FrequencyStart=11
...    NRCELL-14:msg1FrequencyStart=13


@{OPEN_BEAMFORMING}
...    NRCELL-1:actBeamforming=true
...    NRCELL-1:beamSet:basicBeamSet=beamSet_5_1
...    NRCELL-1:beamSet:leftEdgeAngle=60
...    NRCELL-1:beamSet:nrBtsBeamRefinementP2=true
...    NRCELL-1:beamSet:rightEdgeAngle=60
...    NRCELL-1:beamSet:tiltOffset=0
...    NRCELLGRP-3:numberOfTransmittedSsBlocks=6 beams
...    NRCELL-2:actBeamforming=true
...    NRCELL-2:beamSet:basicBeamSet=beamSet_5_1
...    NRCELL-2:beamSet:leftEdgeAngle=60
...    NRCELL-2:beamSet:nrBtsBeamRefinementP2=true
...    NRCELL-2:beamSet:rightEdgeAngle=60
...    NRCELL-2:beamSet:tiltOffset=0
...    NRCELLGRP-4:numberOfTransmittedSsBlocks=6 beams
...    NRCELL-1:nrCellType=4DL2UL
...    NRCELL-2:nrCellType=4DL2UL
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1


@{DELTA_PARAS_C02}
...    NRCELL:a1MeasSCellAddEnabled=rsrpCombined
...    NRCELL-1:a1MeasPCellSwitchEnabled=rsrpCombined
...    NRCELL-12:a1MeasPCellSwitchEnabled=rsrpCombined

@{DELTA_PARAS_C02_Recover}
...    NRCELL:a1MeasSCellAddEnabled=rsrp
...    NRCELL-1:a1MeasPCellSwitchEnabled=rsrp
...    NRCELL-12:a1MeasPCellSwitchEnabled=rsrp

@{DELTA_PARAS_C03}
...    NRCELL:a1MeasSCellAddEnabled=rsrp
...    NRCELL-13:weightForSCellSelection=45
...    NRCELL-2:weightForSCellSelection=1
...    NRCELL-11:weightForSCellSelection=30
...    NRCELL-1:weightForSCellSelection=95
...    NRCELL-12:weightForSCellSelection=55
...    MRBTS-1/NRBTS-1/NRCELL-13:a2MeasReleaseEnabled=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-13:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    MRBTS-1/NRBTS-1/NRCELL-13:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=111
...    MRBTS-1/NRBTS-1/NRCELL-13:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=60
...    MRBTS-1/NRBTS-1/NRCELL-13:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=0ms
...    MRBTS-1/NRBTS-1/NRCELL-13:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0
...    MRBTS-1/NRBTS-1/NRCELL-13:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=48
...    MRBTS-1/NRBTS-1/NRCELL-13:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=0ms
...    MRBTS-1/NRBTS-1:actInterFreqHoSA=true
...    MRBTS-1/NRBTS-1:actHoOptimizationCa=true
...    NRCELL-1:a1MeasPCellSwitchEnabled=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeashoEnabledSA=none
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeasReleaseEnabled=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeasPCellSwitchSsbRsrp:a1HysteresisPCellSwitchSsbRsrp=0
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeasPCellSwitchSsbRsrp:a1ThresholdPCellSwitchSsbRsrp=125
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeasPCellSwitchSsbRsrp:a1TimeToTriggerPCellSwitchSsbRsrp=0ms
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=120
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=120
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=0ms
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=100
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=0ms
...    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrRelReportCu=15min
...    MRBTS-1/NRBTS-1/NRCELL-12:a1MeashoEnabledSA=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-12:a2MeasReleaseEnabled=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-12:a2MeashoEnabledSA=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-12:a1MeasPCellSwitchSsbRsrp:a1HysteresisPCellSwitchSsbRsrp=0
...    MRBTS-1/NRBTS-1/NRCELL-12:a1MeasPCellSwitchSsbRsrp:a1ThresholdPCellSwitchSsbRsrp=80
...    MRBTS-1/NRBTS-1/NRCELL-12:a1MeasPCellSwitchSsbRsrp:a1TimeToTriggerPCellSwitchSsbRsrp=0ms
...    MRBTS-1/NRBTS-1/NRCELL-12:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    MRBTS-1/NRBTS-1/NRCELL-12:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=111
...    MRBTS-1/NRBTS-1/NRCELL-12:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=60
...    MRBTS-1/NRBTS-1/NRCELL-12:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=0ms
...    MRBTS-1/NRBTS-1/NRCELL-12:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0
...    MRBTS-1/NRBTS-1/NRCELL-12:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=35
...    MRBTS-1/NRBTS-1/NRCELL-12:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=0ms
...    MRBTS-1/NRBTS-1/NRCELL-12:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    MRBTS-1/NRBTS-1/NRCELL-12:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=50
...    MRBTS-1/NRBTS-1/NRCELL-12:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms0
...    MRBTS-1/NRBTS-1/NRCELL-12:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0
...    MRBTS-1/NRBTS-1/NRCELL-12:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=45
...    MRBTS-1/NRBTS-1/NRCELL-12:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms0
...    MRBTS-1/NRBTS-1/NRCELL-11:a2MeasReleaseEnabled=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-11:a1MeasPCellSwitchSsbRsrp:a1HysteresisPCellSwitchSsbRsrp=0
...    MRBTS-1/NRBTS-1/NRCELL-11:a1MeasPCellSwitchSsbRsrp:a1ThresholdPCellSwitchSsbRsrp=80
...    MRBTS-1/NRBTS-1/NRCELL-11:a1MeasPCellSwitchSsbRsrp:a1TimeToTriggerPCellSwitchSsbRsrp=0ms
...    MRBTS-1/NRBTS-1/NRCELL-11:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    MRBTS-1/NRBTS-1/NRCELL-11:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=111
...    MRBTS-1/NRBTS-1/NRCELL-11:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=60
...    MRBTS-1/NRBTS-1/NRCELL-11:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=0ms
...    MRBTS-1/NRBTS-1/NRCELL-11:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0
...    MRBTS-1/NRBTS-1/NRCELL-11:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=24
...    MRBTS-1/NRBTS-1/NRCELL-11:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=0ms
...    MRBTS-1/NRBTS-1/NRCELL-11:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0
...    MRBTS-1/NRBTS-1/NRCELL-11:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=30
...    MRBTS-1/NRBTS-1/NRCELL-11:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms0
...    NRBTS-1/NRCELL-1/NRREL-1:lcrId=12
...    NRCELL-1/NRREL-1:sCellOperationalMode=dlOnly
...    NRBTS-1/NRCELL-12/NRHOIF-1:a3MeasEnabled=rsrp
...    NRBTS-1/NRCELL-12/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRBTS-1/NRCELL-12/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=30
...    NRBTS-1/NRCELL-12/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL-12:a1MeasPCellSwitchEnabled=rsrp


&{CELLS_CARRIER_FREQ}
...     1=518910
...     2=633216
...     11=424090
...     12=126750
...     13=427970

*** Test Cases ***
CB008015-ET-C02_C_B1_SA Mobility based on rsrpCombined involving two cells with same coverage
    [Documentation]
    ...    The purpose of this test case is to check following scenarios: actHoOptimizationCa true
    ...    US CB008015-C_B1: Mobility based on rsrpcombined involving two TDD cells with same coverage -SA
    ...    CA relationships: FDD have 4 NRREL MO , TDD cell only have configured one necessary
    ...    UE81: support n66+n71,n71+n41,n66+n41,n66+n78; n41+n78,n71+n78,n66+n66+n71 CA
    ...    step1: SA UE-81 is attached in cell11 with the PDU session setup for data transferring. trigger MR with RSRQ not enough
    ...    Expected Result: SA call setup successfully, but CA is not possible
    ...    step2: trigger MR with enough threshold to a1ThresholdSCellAddSsbRsrpFDD, rsrq enough.
    ...    Expected Result: F+F+F successfully Cell11+Cell11+cell13
    ...    step3: trigger MR with rsrp enough rsrq NOT enough threshold to a1ThresholdPCellSwitchSsbRsrp
    ...    Expected Result: PCELL switch failed (cell11-->Cell12)
    ...    step4: trigger MR with rsrp enough rsrq enough threshold to a1ThresholdPCellSwitchSsbRsrp
    ...    Expected Result: PCELL switch successfully (cell11-->Cell12) , and add Cell11 Cell13, F+F+F (Cell11+cell12+cell13)successfully
    ...    step5: trigger MR with rsrq not enough threshold to a1ThresholdSCellAddSsbRsrpTDD
    ...    Expected Result: Scell change failed to F+T .
    ...    step6: trigger MR with enough threshold to a1ThresholdSCellAddSsbRsrpTDD
    ...    Expected Result: Scell change successfully to F+T .(Cell12+cell11+cell13-->Cell11+Cell1)
    ...    step7: trigger MR with not enough threshold to a1ThresholdPCellSwitchSsbRsrp
    ...    Expected Result: PCELL switch failed (Cell11-->cell1)
    ...    step8: trigger MR with enough threshold to a1ThresholdPCellSwitchSsbRsrp
    ...    Expected Result: PCELL switch successfully (Cell11-->cell1) , and add Cell2, t+t successfully cell1+cell2
    [Tags]    QC_128180    Ye Selena
    OnlineParamChange    ${DELTA_PARAS_C02}
    SA UE Attach to Cell    11    1    1
    No scell added Based On lower Rsrq
    Scell_12_13 Added Based On high Rsrq
    PCELL switch from cell11 to cell12 failed by A1 Based On lower Rsrq
    PCELL switch from cell11 to cell12 by A1 Based On higher Rsrp and Rsrq and add scell_11_13
    Scell change failed Based on lower Rsrq
    Scell changed to cell1 Based on higher Rsrp and Rsrq
    PCELL switch from cell12 to cell1 failed by A1 Based On lower Rsrq
    PCELL switch from cell12 to cell1 by A1 Based On higher Rsrp and Rsrq and add scell_2
    Release Scell    1    2
    Release call
    [Teardown]    Recover Param and Common Test Teardown    ${DELTA_PARAS_C02_Recover}

CB008015-ET-C03_C_B2_SA Mobility based on rsrp involving one TDD cell
    [Documentation]
    ...    1. The purpose of this test case is to verify SCell selection based on weightForSCellSelection
    ...    and Pcell switch for SA call
    ...    UE81: support n66+n71,n71+n41,n66+n41,n66+n78; n41+n78,n71+n78,n66+n66+n71 CA
    ...    CA relationships: FDD have 4 NRREL MO , TDD cell only have configured one necessary
    ...    The weighted cell bandwidth is configured as : Cell 1>Cell 11+Cell 13>Cell 13>Cell 11>Cell 2
    ...    2. Test Case Steps:
    ...    a. SA UE81 attach to cell12, trigger A1 MR(rsrp > a1ThresholdSCellAddSsbRsrpTDD) for Scell addition
    ...    b. Trigger A1 MR(rsrp > a1ThresholdPCellSwitchSsbRsrp) for Pcell switch
    ...    c. Trigger A2 MR(rsrp < a1ThresholdPCellSwitchSsbRsrp) for Pcell switch
    ...    d. Trigger A2 MR(rsrp < a2MeasSCellRelSsbRsrp) for Scell release
    ...    e. Trigger A1 MR(a1ThresholdSCellAddSsbRsrpFDD < rsrp < a1ThresholdSCellAddSsbRsrpTDD) for Scell addition
    ...    f. Trigger A2 MR(rsrp < a2MeasSCellRelSsbRsrp) for Scell release
    ...    h. Release SA UE1
    ...    3. Expected Results:
    ...    Step a: SA UE81 attach successfully and config A1 for SCell addition with a1ThresholdSCellAddSsbRsrpFDD
    ...            UE81 add cell1 for FT 2CC and config A1 for Pcellswitch with a1ThresholdPCellSwitchSsbRsrp for cell1,
    ...            A2 measurement for scell release for scells cell1
    ...    Step b: Pcell switch IFHO trigger form cell12 to cell1 and scell cell12 addition successfully as RSRP for cell12
    ...            higher than a1ThresholdSCellAddSsbRsrpFDD config in cell1
    ...    Step c: Pcell switch IFHO trigger form cell1 to cell12 and scell cell1 addition successfully as RSRP for cell1
    ...            higher than a1ThresholdSCellAddSsbRsrpTDD config in cell12
    ...    Step d: scell cell1 release and UE81 config A1 for scell add with a1ThresholdSCellAddSsbRsrpFDD for cell12
    ...    Step e: SA UE81 add cell11 and cell13 for FF 3CC CA and config A2 for scell release for cell1 and cell13,
    ...            config A1 for a1ThresholdSCellAddSsbRsrpTDD for pcell cell2
    ...    Step f: cell13 release and UE81 config A1 for scell addition with a1ThresholdSCellAddSsbRsrpFDD for cell12,
    ...            config A2 for scell release for scells cell11
    ...    Step h: SA call release successfully
    [Tags]    QC_128181    Ye Selena
    OnlineParamChange     ${DELTA_PARAS_C03}
    SA UE Attach to Cell    12    2    2
    Scell_1 Added Based On high Rsrq
    Pcell switch from Cell12 to Cell1 by A1 and add scell_12
    Pcell switch from Cell1 to Cell12 by A2 and add scell_1
    Release Scell    1    1
    Scell_11_13 added Based on high Rsrp
    Release Scell    1    11
    Release Scell    2    13
    Release call

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_2T4F

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}

SA UE Attach To Cell
    [Arguments]    ${cell_id}    ${pdu_id}    ${gw_id}    ${ue_id}=81
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=${gw_id} nwslice=1    QoS Routing Table
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=100 trf_id=1
    ...    pass_regexp=UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=ul mbps=100 trf_id=1
    ...    pass_regexp=UE ${ue_id}: UDP UL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=100 trf_id=2
    ...    pass_regexp=UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=100 trf_id=3
    ...    pass_regexp=UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=100 trf_id=4
    ...    pass_regexp=UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=100 trf_id=5
    ...    pass_regexp=UE ${ue_id}: UDP DL
    Check Pcell triffice    ${pdu_id}

No scell added Based On lower Rsrq
    No Scell Addition by A1 Event    11    81    40    10

Scell_12_13 Added Based On high Rsrq
    Triggered Scell Addition by A1 Event    11    40    120
    Verify Throuput with two scell    270

PCELL switch from cell11 to cell12 failed by A1 Based On lower Rsrq
    [Arguments]    ${ue_id}=81
    ${carrier_freq}     Get From Dictionary    ${CELLS_CARRIER_FREQ}    12
    ${meas_id}    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrier_freq}    event_type=A1
    ${Pcell_switch_by_A1}    catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=0 srsrq_nr=0
     ...    scell=1 scell_rsrp=100 scell_rsrq=10
     Should Not Contain    ${Pcell_switch_by_A1}    SCellIndex 1 activated successfully at airphone

PCELL switch from cell11 to cell12 by A1 Based On higher Rsrp and Rsrq and add scell_11_13
    [Arguments]    ${ue_id}=81
    ${carrier_freq}     Get From Dictionary    ${CELLS_CARRIER_FREQ}    12
    ${meas_id}    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrier_freq}    event_type=A1
    ${Pcell_switch_by_A1}    catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=0 srsrq_nr=0
    ...    scell=1 scell_rsrp=100 scell_rsrq=120
    ${ret2}    Execute Egate Command    ${Pcell_switch_by_A1}    pass_regexp=SCellIndex 1 activated successfully at airphone
    Should Contain    ${ret2}    sCellToReleaseList
    Should Contain    ${ret2}    Intra-eNB handover from EXT_ENB-2.11 to EXT_ENB-2.12 performed
    Should Contain    ${ret2}    sCellToAddModList    physCellId 60    physCellId 62
    Verify Throuput with two scell    270

Scell change failed Based on lower Rsrq
    No Scell Addition by A1 Event    12    81    120    10

Scell changed to cell1 Based on higher Rsrp and Rsrq
    Triggered Scell Addition by A1 Event    12    113    120
    Verify Throuput    400    1    3

PCELL switch from cell12 to cell1 failed by A1 Based On lower Rsrq
    [Arguments]    ${ue_id}=81
    ${carrier_freq}     Get From Dictionary    ${CELLS_CARRIER_FREQ}    1
    ${meas_id}    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrier_freq}    event_type=A1
    ${Pcell_switch_by_A1}    catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=0 srsrq_nr=0
    ...    scell=3 scell_rsrp=126 scell_rsrq=10
    Should Not Contain    ${Pcell_switch_by_A1}    SCellIndex 3 activated successfully at airphone

PCELL switch from cell12 to cell1 by A1 Based On higher Rsrp and Rsrq and add scell_2
    [Arguments]    ${ue_id}=81    ${scell_pci}=51
    ${carrier_freq}     Get From Dictionary    ${CELLS_CARRIER_FREQ}    1
    ${meas_id}    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrier_freq}    event_type=A1
    ${Pcell_switch_by_A1}    catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=0 srsrq_nr=0
    ...    scell=3 scell_rsrp=126 scell_rsrq=120
    ${ret2}    Execute Egate Command    ${Pcell_switch_by_A1}    pass_regexp=SCellIndex 1 activated successfully at airphone
    Should Contain    ${ret2}    sCellToReleaseList
    Should Contain    ${ret2}    Intra-eNB handover from EXT_ENB-2.12 to EXT_ENB-2.1 performed
    Should Contain    ${ret2}    sCellToAddModList    physCellId ${scell_pci}
    Verify Throuput    450

Scell_1 Added Based On high Rsrq
    Triggered Scell Addition by A1 Event    12    120    120
    Verify Throuput    400    2

Pcell switch from Cell12 to Cell1 by A1 and add scell_12
    [Arguments]    ${scell_pci}=61    ${ue_id}=81
    ${carrier_freq}     Get From Dictionary    ${CELLS_CARRIER_FREQ}    1
    ${meas_id}    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrier_freq}    event_type=A1
    ${Pcell_switch_by_A1}    catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=0 srsrq_nr=0
     ...    scell=1 scell_rsrp=127 scell_rsrq=0
    ${ret1}=    Execute Egate Command    ${Pcell_switch_by_A1}    pass_regexp=SCellIndex 1 activated successfully at airphone
    Should Contain    ${ret1}    sCellToReleaseList
    Should Contain    ${ret1}    Intra-eNB handover from EXT_ENB-2.12 to EXT_ENB-2.1 performed
    Should Contain    ${ret1}    sCellToAddModList    physCellId ${scell_pci}
    Verify Throuput    400    2

Pcell switch from Cell1 to Cell12 by A2 and add scell_1
    [Arguments]    ${scell_pci}=50    ${ue_id}=81
    ${carrier_freq}     Get From Dictionary    ${CELLS_CARRIER_FREQ}    1
    ${meas_id}    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrier_freq}    event_type=A2
    ${Pcell_switch_by_A2}    catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 srsrp_nr=11 srsrq_nr=11
     ...    scell=1 scell_rsrp=123 scell_rsrq=5
    ${ret2}=    Execute Egate Command    ${Pcell_switch_by_A2}    pass_regexp=SCellIndex 1 activated successfully at airphone
    Should Contain    ${ret2}    sCellToReleaseList
    Should Contain    ${ret2}    Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.12 performed
    Should Contain    ${ret2}    sCellToAddModList    physCellId ${scell_pci}
    Verify Throuput    400    2

Scell_11_13 added Based on high Rsrp
    Triggered Scell Addition by A1 Event    12    85    125
    Verify Throuput with two scell    270    81    2

Recover Param and Common Test Teardown
    [Arguments]    ${origin_params}
    Delta Commission Parameters    ${origin_params}
    Common Test Teardown And Stop Capture Logs

No Scell Addition by A1 Event
    [Arguments]    ${pcell_id}    ${ue_id}=81    ${rsrp}=100    ${rsrq}=10
    ${pcell_carrier_freq}    Get From Dictionary    ${CELLS_CARRIER_FREQ}    ${pcell_id}
    ${meas_id}    Get Nr Meas Id For Specific Type And Frequency    ${ue_id}    ${pcell_carrier_freq}    A1
    Execute Egate Command
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=${rsrp} srsrq_nr=${rsrq}
    ...    fail_regexp=rrcReconfiguration

Check Pcell triffice
    [Arguments]    ${pdu_id}    ${ue_id}=81
    sleep    10s    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput}/1000>63
    Should Be True    ${ul_throughput}/1000>9.5

Triggered Scell Addition by A1 Event
    [Arguments]    ${pcell_id}    ${srsrp_nr}    ${srsrq_nr}    ${ue_id}=81
    ${carrier_freq}     Get From Dictionary    ${CELLS_CARRIER_FREQ}     ${pcell_id}
    ${meas_id}    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrier_freq}    event_type=A1
    Execute Egate Command    ue_meas_cfg_disp id=${ue_id} meas_obj_type=nr
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=${srsrp_nr} srsrq_nr=${srsrq_nr}
    ...                      activated successfully at airphone

Release Scell
    [Arguments]    ${scell_idx}    ${scell_id}    ${ue_id}=81
    ${carrier_freq}     Get From Dictionary    ${CELLS_CARRIER_FREQ}     ${scell_id}
    ${meas_id}    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrier_freq}    event_type=A2
    Execute Egate Command    ue_meas_cfg_disp id=${ue_id} meas_obj_type=nr
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 scell=${scell_idx} scell_rsrp=20 scell_rsrq=20
    ...    pass_regexp=sCellToReleaseList

Verify Throuput
    [Arguments]    ${target_dl_throuput}=135    ${pdu_id}=1     ${scell_idx}=1    ${ue_id}=81   ${sleep_time}=30s
    sleep    ${sleep_time}    sleep for Tput stable
    ${scell_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${scell_idx}
    ...    type=pdsch    rate_type=ave
    Should Be True    ${scell_tput}/1000 > 0
    ${ul_throuput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${ul_throuput}/1000>9
    ${pcell_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0
    ...    type=pdsch    rate_type=ave
    Should Be True    ${pcell_tput}/1000 > 0
    Should Be True    ${scell_tput}/1000 + ${pcell_tput}/1000>${target_dl_throuput}

Verify Throuput with two scell
    [Arguments]    ${target_dl_throuput}=135    ${ue_id}=81    ${pdu_id}=1    ${sleep_time}=30s
    sleep    ${sleep_time}
    ${scell1_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=1    type=pdsch    rate_type=ave
    Should Be True    ${scell1_tput}/1000 > 0
    ${scell2_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=2    type=pdsch    rate_type=ave
    Should Be True    ${scell2_tput}/1000 > 0
    ${pcell_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0
    ...    type=pdsch    rate_type=ave
    Should Be True    ${pcell_tput}/1000 > 0
    ${ul_throuput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${ul_throuput}/1000>9
    Should Be True    ${scell1_tput}/1000 + ${scell2_tput}/1000 + ${pcell_tput}/1000>${target_dl_throuput}

Release call
    [Arguments]    ${ue_id}=81
    Execute Egate Command    ue_disp
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off        UE${ue_id}: detached
