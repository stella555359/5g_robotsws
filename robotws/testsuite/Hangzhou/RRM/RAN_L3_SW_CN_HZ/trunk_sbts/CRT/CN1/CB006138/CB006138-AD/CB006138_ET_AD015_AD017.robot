*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    CXT    master_classicalbts_all    STATE_CONFIGURED
...               FR1    CN2    team-SG2    owner-cathy.mao    owner-dandan.chen    release-SBTS22R1
...               PRI-Medium    CB006138-AD    CLOUD_5G_I_BOO_AP_LOO
Resource         ../../../../../resources/DevHZ5_resource.robot


*** Variables ***
${TL_TYPE_PATH}    fddtdd_sansa_cmwv/6cells_4T2F

@{beamforming_enable}
...    NRCELL-1:actBeamforming=true
...    MRBTS-1/NRBTS-1/NRCELLGRP-0:numberOfTransmittedSsBlocks=4 beams
...    NRCELL-1:beamSet:basicBeamSet=beamSet_4
...    NRCELL-1:numberOfRxBeamforming=4Rx
...    NRCELL-1:nrCellType=4DL4UL
...    NRCELL-2:nrCellType=4DL4UL
...    NRCELL-3:nrCellType=4DL4UL
...    NRCELL-4:nrCellType=4DL4UL
...    NRCELL-1:beamSet:leftEdgeAngle=60
...    NRCELL-1:beamSet:nrBtsBeamRefinementP2=false
...    NRCELL-1:beamSet:rightEdgeAngle=60
...    NRCELL-4:actBeamforming=true
...    NRCELL-4:numberOfRxBeamforming=4Rx
...    MRBTS-1/NRBTS-1/NRCELLGRP-3:numberOfTransmittedSsBlocks=4 beams
...    NRCELL-4:beamSet:basicBeamSet=beamSet_4
...    NRCELL-4:beamSet:nrBtsBeamRefinementP2=false
...    NRCELL-4:beamSet:leftEdgeAngle=60
...    NRCELL-4:beamSet:lowerEdgeAngle=120
...    NRCELL-4:beamSet:rightEdgeAngle=60
...    NRCELL-4:beamSet:upperEdgeAngle=60
...    NRCELL-1:dlMimoMode=4x4 or 4x2 Open Loop Spatial Multiplexing
...    NRCELL-2:dlMimoMode=4x4 or 4x2 Open Loop Spatial Multiplexing
...    NRCELL-3:dlMimoMode=4x4 or 4x2 Open Loop Spatial Multiplexing
...    NRCELL-4:dlMimoMode=4x4 or 4x2 Open Loop Spatial Multiplexing
...    MRBTS-1/NRBTS-1/NRDU-1:actNonBfAndBfCa=true
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-7:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-7:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-8:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-8:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-7:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-7:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-8:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-8:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-7:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-7:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-8:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-8:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-7:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-7:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-8:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-8:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1


@{PARAMS_FOR_5QI1}
...    NRBTS:actNormVCFallback=false
...    NRBTS/NRDRB_5QI-6:fiveqiValueList=1
...    NRBTS/NRDRB_5QI-6:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-15
...    NRBTS/NRDRB-15:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-4
...    NRBTS/NRDRB-15:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-3
...    NRBTS/NRDRB-15:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRBTS/NRDRB-15:dlFlowControlAlgo=none
...    NRBTS/NRDRB-15:dscp=46
...    NRBTS/NRDRB-15:maxDddsPeriodCpuOvld=40
...    NRBTS/NRDRB-15:numSduDiscard=1
...    NRBTS/NRDRB-15:queuingDelayDiscarding=Disabled
...    NRBTS/NRDRB-15:queuingDelaySduDiscardThreshold=200
...    NRBTS/NRDRB-15:resType=GBR
...    NRBTS/NRDRB-15:rlcMode=RLC_UM
...    NRBTS/NRDRB-15:schedulWeight=1
...    NRBTS/NRDRB-15:sduDiscardIntervalTmr=100
...    NRBTS/NRDRB-15:maxDataRateGbrDl=1000
...    NRBTS/NRDRB-15:maxDataRateGbrUl=1000
...    NRBTS/NRDRB_MAC-4:lcgid=4
...    NRBTS/NRDRB_MAC-4:schedulPrio=4
...    NRBTS/NRDRB_RLC_UM-1:dlTReassemblyUm=ms40
...    NRBTS/NRDRB_RLC_UM-1:ulTReassemblyUm=ms40
...    NRBTS/NRDRB_PDCP-3:tReorderingDl=ms300
...    NRBTS/NRDRB_PDCP-3:tReorderingUl=ms300
...    NRBTS/NRDRB_PDCP-3:pdcpBufDiscardEnabled=false

@{PARAMS_IN_SCF}
...    @{PARAMS_FOR_5QI1}
...    NRCELL:actK1Opt=intra-gNB
...    NRCELL:a1MeashoSsbRsrp:a1HysteresishoSsbRsrp=0
...    NRCELL:a1MeashoSsbRsrp:a1ThresholdhoSsbRsrp=34
...    NRCELL:a1MeashoSsbRsrp:a1TimeToTriggerhoSsbRsrp=ms480
...    NRCELL:a1MeashoSsbRsrq:a1HysteresishoSsbRsrq=0
...    NRCELL:a1MeashoSsbRsrq:a1ThresholdhoSsbRsrq=31
...    NRCELL:a1MeashoSsbRsrq:a1TimeToTriggerhoSsbRsrq=ms480
...    NRCELL:a2MeasRedirectSsbRsrp:a2HysteresisRedirectSsbRsrp=0
...    NRCELL:a2MeasRedirectSsbRsrp:a2ThresholdRedirectSsbRsrp=34
...    NRCELL:a2MeasRedirectSsbRsrp:a2TimeToTriggerRedirectSsbRsrp=ms480
...    NRCELL:a2MeasRedirectSsbRsrq:a2HysteresisRedirectSsbRsrq=0
...    NRCELL:a2MeasRedirectSsbRsrq:a2ThresholdRedirectSsbRsrq=31
...    NRCELL:a2MeasRedirectSsbRsrq:a2TimeToTriggerRedirectSsbRsrq=ms480
...    NRCELL:a2MeasReleaseSsbRsrp:a2HysteresisReleaseSsbRsrp=0
...    NRCELL:a2MeasReleaseSsbRsrp:a2ThresholdReleaseSsbRsrp=75
...    NRCELL:a2MeasReleaseSsbRsrp:a2TimeToTriggerReleaseSsbRsrp=ms0
...    NRCELL:a2MeasReleaseSsbRsrq:a2HysteresisReleaseSsbRsrq=0
...    NRCELL:a2MeasReleaseSsbRsrq:a2ThresholdReleaseSsbRsrq=75
...    NRCELL:a2MeasReleaseSsbRsrq:a2TimeToTriggerReleaseSsbRsrq=ms0
...    NRCELL:a2MeashoSsbRsrp:a2HysteresishoSsbRsrp=1
...    NRCELL:a2MeashoSsbRsrp:a2ThresholdhoSsbRsrp=34
...    NRCELL:a2MeashoSsbRsrp:a2TimeToTriggerhoSsbRsrp=ms480
...    NRCELL:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRCELL:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL:a5MeasSsbRsrp:a5HysteresisSsbRsrp=0
...    NRCELL:a5MeasSsbRsrp:a5Threshold1SsbRsrp=75
...    NRCELL:a5MeasSsbRsrp:a5Threshold2SsbRsrp=85
...    NRCELL:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms0
...    NRCELL:a5MeasSsbRsrq:a5HysteresisSsbRsrq=0
...    NRCELL:a5MeasSsbRsrq:a5Threshold1SsbRsrq=75
...    NRCELL:a5MeasSsbRsrq:a5Threshold2SsbRsrq=85
...    NRCELL:a5MeasSsbRsrq:a5TimeToTriggerSsbRsrq=ms0
...    NRBTS:actNormVCFallback=false
...    NRCELL:pucchF3MaxCodeRate=zeroDot08
...    NRCELL:pucchModeSelect=longPucch
...    NRCELL:actPrachMultiplexing=true
...    NRCELL:actCDrx=true
...    NRCELL:pucchF3ModulationScheme=pi2bpsk
...    NRBTS:actConflictConfiguration=true

...    NRCELL-3/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-3/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-3/NRREL-1:gNbId=1
...    NRCELL-3/NRREL-1:gNbIdLength=22
...    NRCELL-3/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-3/NRREL-1:lcrId=11
...    NRCELL-3/NRREL-1:removeNotAllowed=false
...    NRCELL-3/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-3/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-3/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-3/NRREL-1:gnbPlmn:mncLength=3
...    NRBTS-1:actFdmEnhancedScheduling=true
...    NRBTS-1:actFdmScheduling=true
...    NRBTS-1:actLteNrDss=true

...    NRBTS-1:actConflictConfiguration=true
...    NRCELLGRP-0:numberOfTransmittedSsBlocks=4 beams
#...    NRBTS-1/NRCELL-4:actBeamforming=true
#...    NRBTS-1/NRCELL-4:beamSet:basicBeamSet=beamSet_4
#...    NRBTS-1/NRCELL-4:beamSet:leftEdgeAngle=60
#...    NRBTS-1/NRCELL-4:beamSet:nrBtsBeamRefinementP2=false
#...    NRBTS-1/NRCELL-4:beamSet:rightEdgeAngle=60
...    NRBTS-1/NRCELL-4:drxProfile1:drxInactivityTimer=40ms
...    NRBTS-1/NRCELL-4:drxProfile1:drxLongCycle=80ms
...    NRBTS-1/NRCELL-4:drxProfile1:drxOnDurationTimer=10ms
...    NRBTS-1/NRCELL-4:drxProfile1:drxRetransTimerDl=16slot
...    NRBTS-1/NRCELL-4:drxProfile1:drxRetransTimerUl=16slot
...    NRBTS-1/NRCELL-4:t310VoNR=100ms
...    NRBTS-1/NRCELL-4:drxProfile2:drxInactivityTimer=4ms
...    NRBTS-1/NRCELL-4:drxProfile2:drxLongCycle=40ms
...    NRBTS-1/NRCELL-4:drxProfile2:drxOnDurationTimer=6ms
...    NRBTS-1/NRCELL-4:drxProfile2:drxRetransTimerDl=0slot
...    NRBTS-1/NRCELL-4:drxProfile2:drxRetransTimerUl=0slot
...    NRBTS-1/NRCELL-4:actCDrxVoNR=true
...    NRBTS-1/NRCELL-4:actEnhancedVoNR=true
...    NRBTS-1/NRCELL-4:actCDrx=true
...    NRBTS-1/NRCELL-4:actVoNR=true
...    NRBTS-1/NRCELL-4:n310VoNR=n10
...    NRBTS-1/NRCELL-4:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRBTS-1/NRCELL-4:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRBTS-1/NRCELL-4:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRBTS-1/NRCELL-4:a5MeasSsbRsrp:a5HysteresisSsbRsrp=0
...    NRBTS-1/NRCELL-4:a5MeasSsbRsrp:a5Threshold1SsbRsrp=75
...    NRBTS-1/NRCELL-4:a5MeasSsbRsrp:a5Threshold2SsbRsrp=85
...    NRBTS-1/NRCELL-4:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms0
...    NRBTS-1/NRCELL-4:pucchF3MaxCodeRate=zeroDot08
...    NRBTS-1/NRCELL-4:pucchModeSelect=longPucch
...    NRBTS-1/NRCELL-4:a1MeashoSsbRsrp:a1HysteresishoSsbRsrp=0
...    NRBTS-1/NRCELL-4:a1MeashoSsbRsrp:a1ThresholdhoSsbRsrp=34
...    NRBTS-1/NRCELL-4:a1MeashoSsbRsrp:a1TimeToTriggerhoSsbRsrp=ms480
...    NRBTS-1/NRCELL-4:a2MeashoSsbRsrp:a2HysteresishoSsbRsrp=1
...    NRBTS-1/NRCELL-4:a2MeashoSsbRsrp:a2ThresholdhoSsbRsrp=34
...    NRBTS-1/NRCELL-4:a2MeashoSsbRsrp:a2TimeToTriggerhoSsbRsrp=ms480
...    NRBTS-1/NRCELL-4:actPrachMultiplexing=true
...    NRBTS-1/NRCELL-4:a2MeasRedirectSsbRsrp:a2HysteresisRedirectSsbRsrp=0
...    NRBTS-1/NRCELL-4:a2MeasRedirectSsbRsrp:a2ThresholdRedirectSsbRsrp=34
...    NRBTS-1/NRCELL-4:a2MeasRedirectSsbRsrp:a2TimeToTriggerRedirectSsbRsrp=ms480
...    NRBTS-1/NRCELL-4:a2MeasReleaseSsbRsrp:a2HysteresisReleaseSsbRsrp=0
...    NRBTS-1/NRCELL-4:a2MeasReleaseSsbRsrp:a2ThresholdReleaseSsbRsrp=75
...    NRBTS-1/NRCELL-4:a2MeasReleaseSsbRsrp:a2TimeToTriggerReleaseSsbRsrp=ms0
...    NRBTS-1/NRCELL-4:a2MeasReleaseSsbRsrq:a2HysteresisReleaseSsbRsrq=0
...    NRBTS-1/NRCELL-4:a2MeasReleaseSsbRsrq:a2ThresholdReleaseSsbRsrq=75
...    NRBTS-1/NRCELL-4:a2MeasReleaseSsbRsrq:a2TimeToTriggerReleaseSsbRsrq=ms0
...    NRBTS-1/NRCELL-4:pucchF3ModulationScheme=pi2bpsk
...    NRBTS-1/NRCELL-4:a1MeashoSsbRsrq:a1HysteresishoSsbRsrq=0
...    NRBTS-1/NRCELL-4:a1MeashoSsbRsrq:a1ThresholdhoSsbRsrq=31
...    NRBTS-1/NRCELL-4:a1MeashoSsbRsrq:a1TimeToTriggerhoSsbRsrq=ms480
...    NRBTS-1/NRCELL-4:a2MeasRedirectSsbRsrq:a2HysteresisRedirectSsbRsrq=0
...    NRBTS-1/NRCELL-4:a2MeasRedirectSsbRsrq:a2ThresholdRedirectSsbRsrq=31
...    NRBTS-1/NRCELL-4:a2MeasRedirectSsbRsrq:a2TimeToTriggerRedirectSsbRsrq=ms480
...    NRBTS-1/NRCELL-4:a5MeasSsbRsrq:a5HysteresisSsbRsrq=0
...    NRBTS-1/NRCELL-4:a5MeasSsbRsrq:a5Threshold1SsbRsrq=75
...    NRBTS-1/NRCELL-4:a5MeasSsbRsrq:a5Threshold2SsbRsrq=85
...    NRBTS-1/NRCELL-4:a5MeasSsbRsrq:a5TimeToTriggerSsbRsrq=ms0
...    NRBTS-1/NRCELL-11:pMax=380
...    NRBTS-1/NRCELL-11:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRBTS-1/NRCELL-11:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRBTS-1/NRCELL-11:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRBTS-1/NRCELL-11:pucchF3MaxCodeRate=zeroDot08
...    NRBTS-1/NRCELL-11:a2MeashoSsbRsrp:a2HysteresishoSsbRsrp=1
...    NRBTS-1/NRCELL-11:a2MeashoSsbRsrp:a2ThresholdhoSsbRsrp=34
...    NRBTS-1/NRCELL-11:a2MeashoSsbRsrp:a2TimeToTriggerhoSsbRsrp=ms480
...    NRBTS-1/NRCELL-11:actPrachMultiplexing=true
...    NRBTS-1/NRCELL-11:a2MeasReleaseSsbRsrp:a2HysteresisReleaseSsbRsrp=0
...    NRBTS-1/NRCELL-11:a2MeasReleaseSsbRsrp:a2ThresholdReleaseSsbRsrp=75
...    NRBTS-1/NRCELL-11:a2MeasReleaseSsbRsrp:a2TimeToTriggerReleaseSsbRsrp=ms0
...    NRBTS-1/NRCELL-11:a2MeasReleaseSsbRsrq:a2HysteresisReleaseSsbRsrq=0
...    NRBTS-1/NRCELL-11:a2MeasReleaseSsbRsrq:a2ThresholdReleaseSsbRsrq=75
...    NRBTS-1/NRCELL-11:a2MeasReleaseSsbRsrq:a2TimeToTriggerReleaseSsbRsrq=ms0
...    NRBTS-1/NRCELL-11:actCDrx=true
...    NRBTS-1/NRCELL-11:pucchF3ModulationScheme=pi2bpsk
...    NRBTS-1/NRCELL-11:a1MeashoSsbRsrq:a1HysteresishoSsbRsrq=0
...    NRBTS-1/NRCELL-11:a1MeashoSsbRsrq:a1ThresholdhoSsbRsrq=31
...    NRBTS-1/NRCELL-11:a1MeashoSsbRsrq:a1TimeToTriggerhoSsbRsrq=ms480
...    NRBTS-1/NRCELL-11:a5MeasSsbRsrq:a5HysteresisSsbRsrq=0
...    NRBTS-1/NRCELL-11:a5MeasSsbRsrq:a5Threshold1SsbRsrq=75
...    NRBTS-1/NRCELL-11:a5MeasSsbRsrq:a5Threshold2SsbRsrq=85
...    NRBTS-1/NRCELL-11:a5MeasSsbRsrq:a5TimeToTriggerSsbRsrq=ms0
...    NRBTS-1/NRCELL-11:a5MeasSsbRsrp:a5HysteresisSsbRsrp=0
...    NRBTS-1/NRCELL-11:a5MeasSsbRsrp:a5Threshold1SsbRsrp=75
...    NRBTS-1/NRCELL-11:a5MeasSsbRsrp:a5Threshold2SsbRsrp=85
...    NRBTS-1/NRCELL-11:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms0
...    NRBTS-1/NRCELL-11:pucchModeSelect=longPucch
...    NRBTS-1/NRCELL-11:a1MeashoSsbRsrp:a1HysteresishoSsbRsrp=0
...    NRBTS-1/NRCELL-11:a1MeashoSsbRsrp:a1ThresholdhoSsbRsrp=34
...    NRBTS-1/NRCELL-11:a1MeashoSsbRsrp:a1TimeToTriggerhoSsbRsrp=ms480
...    NRBTS-1/NRCELL-11:a2MeasRedirectSsbRsrp:a2HysteresisRedirectSsbRsrp=0
...    NRBTS-1/NRCELL-11:a2MeasRedirectSsbRsrp:a2ThresholdRedirectSsbRsrp=34
...    NRBTS-1/NRCELL-11:a2MeasRedirectSsbRsrp:a2TimeToTriggerRedirectSsbRsrp=ms480
...    NRBTS-1/NRCELL-11:a2MeasRedirectSsbRsrq:a2HysteresisRedirectSsbRsrq=0
...    NRBTS-1/NRCELL-11:a2MeasRedirectSsbRsrq:a2ThresholdRedirectSsbRsrq=31
...    NRBTS-1/NRCELL-11:a2MeasRedirectSsbRsrq:a2TimeToTriggerRedirectSsbRsrq=ms480
...    NRCELL-3:actVoNR=true
...    NRCELL-3:actCDrxVoNR=true
...    NRCELL-3:actEnhancedVoNR=true
...    NRCELL-3:actCDrx=true
...    NRCELL-3:n310VoNR=n10
...    NRCELL-3:t310VoNR=100ms
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
...    NRCELL-3:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRCELL-3:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL-3:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL-3:a5MeasSsbRsrp:a5HysteresisSsbRsrp=0
...    NRCELL-3:a5MeasSsbRsrp:a5Threshold1SsbRsrp=75
...    NRCELL-3:a5MeasSsbRsrp:a5Threshold2SsbRsrp=85
...    NRCELL-3:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms0
...    NRCELL-3:pucchF3MaxCodeRate=zeroDot08
...    NRCELL-3:pucchModeSelect=longPucch
...    NRCELL-3:a1MeashoSsbRsrp:a1HysteresishoSsbRsrp=0
...    NRCELL-3:a1MeashoSsbRsrp:a1ThresholdhoSsbRsrp=34
...    NRCELL-3:a1MeashoSsbRsrp:a1TimeToTriggerhoSsbRsrp=ms480
...    NRCELL-3:a2MeashoSsbRsrp:a2HysteresishoSsbRsrp=1
...    NRCELL-3:a2MeashoSsbRsrp:a2ThresholdhoSsbRsrp=34
...    NRCELL-3:a2MeashoSsbRsrp:a2TimeToTriggerhoSsbRsrp=ms480
...    NRCELL-3:actPrachMultiplexing=true
...    NRCELL-3:a2MeasRedirectSsbRsrp:a2HysteresisRedirectSsbRsrp=0
...    NRCELL-3:a2MeasRedirectSsbRsrp:a2ThresholdRedirectSsbRsrp=34
...    NRCELL-3:a2MeasRedirectSsbRsrp:a2TimeToTriggerRedirectSsbRsrp=ms480
...    NRCELL-3:a2MeasReleaseSsbRsrp:a2HysteresisReleaseSsbRsrp=0
...    NRCELL-3:a2MeasReleaseSsbRsrp:a2ThresholdReleaseSsbRsrp=75
...    NRCELL-3:a2MeasReleaseSsbRsrp:a2TimeToTriggerReleaseSsbRsrp=ms0
...    NRCELL-3:a2MeasReleaseSsbRsrq:a2HysteresisReleaseSsbRsrq=0
...    NRCELL-3:a2MeasReleaseSsbRsrq:a2ThresholdReleaseSsbRsrq=75
...    NRCELL-3:a2MeasReleaseSsbRsrq:a2TimeToTriggerReleaseSsbRsrq=ms0
...    NRCELL-3:pucchF3ModulationScheme=pi2bpsk
...    NRCELL-3:a1MeashoSsbRsrq:a1HysteresishoSsbRsrq=0
...    NRCELL-3:a1MeashoSsbRsrq:a1ThresholdhoSsbRsrq=31
...    NRCELL-3:a1MeashoSsbRsrq:a1TimeToTriggerhoSsbRsrq=ms480
...    NRCELL-3:a2MeasRedirectSsbRsrq:a2HysteresisRedirectSsbRsrq=0
...    NRCELL-3:a2MeasRedirectSsbRsrq:a2ThresholdRedirectSsbRsrq=31
...    NRCELL-3:a2MeasRedirectSsbRsrq:a2TimeToTriggerRedirectSsbRsrq=ms480
...    NRCELL-3:a5MeasSsbRsrq:a5HysteresisSsbRsrq=0
...    NRCELL-3:a5MeasSsbRsrq:a5Threshold1SsbRsrq=75
...    NRCELL-3:a5MeasSsbRsrq:a5Threshold2SsbRsrq=85
...    NRCELL-3:a5MeasSsbRsrq:a5TimeToTriggerSsbRsrq=ms0
...    NRCELL-4/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-4/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-4/NRREL-1:gNbId=1
...    NRCELL-4/NRREL-1:gNbIdLength=22
...    NRCELL-4/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-4/NRREL-1:lcrId=1
...    NRCELL-4/NRREL-1:removeNotAllowed=false
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
...    NRCELL-4/NRREL-2:sCellAdditionMethod=blind
...    NRCELL-4/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-4/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-4/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-3/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-3/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-3/NRREL-2:gNbId=1
...    NRCELL-3/NRREL-2:gNbIdLength=22
...    NRCELL-3/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-3/NRREL-2:lcrId=12
...    NRCELL-3/NRREL-2:removeNotAllowed=false
...    NRCELL-3/NRREL-2:sCellAdditionMethod=blind
...    NRCELL-3/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-3/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-3/NRREL-2:gnbPlmn:mncLength=3
...    NRCELLGRP-3:numberOfTransmittedSsBlocks=4 beams
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRDU-1:actInterNumerologyCa=true
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:carrierAggregationSupportList=${CA_SUPPORT_LIST}
...    NRCELL-4:gscnOrSsPbchArfcn=6351
...    NRCELL-4:nrarfcn=508020
...    NRCELL-4:actVoNR=true
...    NRCELL-4:actCDrxVoNR=true
...    NRCELL-4:actEnhancedVoNR=true
...    NRCELL-4:actCDrx=true
...    NRCELL-4:n310VoNR=n10
...    NRCELL-4:t310VoNR=100ms
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
...    NRCELL-4:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRCELL-4:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL-4:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL-4:a5MeasSsbRsrp:a5HysteresisSsbRsrp=0
...    NRCELL-4:a5MeasSsbRsrp:a5Threshold1SsbRsrp=75
...    NRCELL-4:a5MeasSsbRsrp:a5Threshold2SsbRsrp=85
...    NRCELL-4:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms0
...    NRCELL-4:pucchF3MaxCodeRate=zeroDot08
...    NRCELL-4:pucchModeSelect=longPucch
...    NRCELL-4:a1MeashoSsbRsrp:a1HysteresishoSsbRsrp=0
...    NRCELL-4:a1MeashoSsbRsrp:a1ThresholdhoSsbRsrp=34
...    NRCELL-4:a1MeashoSsbRsrp:a1TimeToTriggerhoSsbRsrp=ms480
...    NRCELL-4:a2MeashoSsbRsrp:a2HysteresishoSsbRsrp=1
...    NRCELL-4:a2MeashoSsbRsrp:a2ThresholdhoSsbRsrp=34
...    NRCELL-4:a2MeashoSsbRsrp:a2TimeToTriggerhoSsbRsrp=ms480
...    NRCELL-4:actPrachMultiplexing=true
...    NRCELL-4:a2MeasRedirectSsbRsrp:a2HysteresisRedirectSsbRsrp=0
...    NRCELL-4:a2MeasRedirectSsbRsrp:a2ThresholdRedirectSsbRsrp=34
...    NRCELL-4:a2MeasRedirectSsbRsrp:a2TimeToTriggerRedirectSsbRsrp=ms480
...    NRCELL-4:a2MeasReleaseSsbRsrp:a2HysteresisReleaseSsbRsrp=0
...    NRCELL-4:a2MeasReleaseSsbRsrp:a2ThresholdReleaseSsbRsrp=75
...    NRCELL-4:a2MeasReleaseSsbRsrp:a2TimeToTriggerReleaseSsbRsrp=ms0
...    NRCELL-4:a2MeasReleaseSsbRsrq:a2HysteresisReleaseSsbRsrq=0
...    NRCELL-4:a2MeasReleaseSsbRsrq:a2ThresholdReleaseSsbRsrq=75
...    NRCELL-4:a2MeasReleaseSsbRsrq:a2TimeToTriggerReleaseSsbRsrq=ms0
...    NRCELL-4:pucchF3ModulationScheme=pi2bpsk
...    NRCELL-4:a1MeashoSsbRsrq:a1HysteresishoSsbRsrq=0
...    NRCELL-4:a1MeashoSsbRsrq:a1ThresholdhoSsbRsrq=31
...    NRCELL-4:a1MeashoSsbRsrq:a1TimeToTriggerhoSsbRsrq=ms480
...    NRCELL-4:a2MeasRedirectSsbRsrq:a2HysteresisRedirectSsbRsrq=0
...    NRCELL-4:a2MeasRedirectSsbRsrq:a2ThresholdRedirectSsbRsrq=31
...    NRCELL-4:a2MeasRedirectSsbRsrq:a2TimeToTriggerRedirectSsbRsrq=ms480
...    NRCELL-4:a5MeasSsbRsrq:a5HysteresisSsbRsrq=0
...    NRCELL-4:a5MeasSsbRsrq:a5Threshold1SsbRsrq=75
...    NRCELL-4:a5MeasSsbRsrq:a5Threshold2SsbRsrq=85
...    NRCELL-4:a5MeasSsbRsrq:a5TimeToTriggerSsbRsrq=ms0
#...    NRBTS-1/NRCELL-1:actBeamforming=true
#...    NRBTS-1/NRCELL-1:beamSet:basicBeamSet=beamSet_4
#...    NRBTS-1/NRCELL-1:beamSet:leftEdgeAngle=60
#...    NRBTS-1/NRCELL-1:beamSet:nrBtsBeamRefinementP2=false
#...    NRBTS-1/NRCELL-1:beamSet:rightEdgeAngle=60
...    NRBTS-1/NRCELL-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRBTS-1/NRCELL-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRBTS-1/NRCELL-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRBTS-1/NRCELL-1:pucchF3MaxCodeRate=zeroDot08
...    NRBTS-1/NRCELL-1:a2MeashoSsbRsrp:a2HysteresishoSsbRsrp=1
...    NRBTS-1/NRCELL-1:a2MeashoSsbRsrp:a2ThresholdhoSsbRsrp=34
...    NRBTS-1/NRCELL-1:a2MeashoSsbRsrp:a2TimeToTriggerhoSsbRsrp=ms480
...    NRBTS-1/NRCELL-1:actPrachMultiplexing=true
...    NRBTS-1/NRCELL-1:a2MeasReleaseSsbRsrp:a2HysteresisReleaseSsbRsrp=0
...    NRBTS-1/NRCELL-1:a2MeasReleaseSsbRsrp:a2ThresholdReleaseSsbRsrp=75
...    NRBTS-1/NRCELL-1:a2MeasReleaseSsbRsrp:a2TimeToTriggerReleaseSsbRsrp=ms0
...    NRBTS-1/NRCELL-1:a2MeasReleaseSsbRsrq:a2HysteresisReleaseSsbRsrq=0
...    NRBTS-1/NRCELL-1:a2MeasReleaseSsbRsrq:a2ThresholdReleaseSsbRsrq=75
...    NRBTS-1/NRCELL-1:a2MeasReleaseSsbRsrq:a2TimeToTriggerReleaseSsbRsrq=ms0
...    NRBTS-1/NRCELL-1:actCDrx=true
...    NRBTS-1/NRCELL-1:pucchF3ModulationScheme=pi2bpsk
...    NRBTS-1/NRCELL-1:a1MeashoSsbRsrq:a1HysteresishoSsbRsrq=0
...    NRBTS-1/NRCELL-1:a1MeashoSsbRsrq:a1ThresholdhoSsbRsrq=31
...    NRBTS-1/NRCELL-1:a1MeashoSsbRsrq:a1TimeToTriggerhoSsbRsrq=ms480
...    NRBTS-1/NRCELL-1:a5MeasSsbRsrq:a5HysteresisSsbRsrq=0
...    NRBTS-1/NRCELL-1:a5MeasSsbRsrq:a5Threshold1SsbRsrq=75
...    NRBTS-1/NRCELL-1:a5MeasSsbRsrq:a5Threshold2SsbRsrq=85
...    NRBTS-1/NRCELL-1:a5MeasSsbRsrq:a5TimeToTriggerSsbRsrq=ms0
...    NRBTS-1/NRCELL-1:a5MeasSsbRsrp:a5HysteresisSsbRsrp=0
...    NRBTS-1/NRCELL-1:a5MeasSsbRsrp:a5Threshold1SsbRsrp=75
...    NRBTS-1/NRCELL-1:a5MeasSsbRsrp:a5Threshold2SsbRsrp=85
...    NRBTS-1/NRCELL-1:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms0
...    NRBTS-1/NRCELL-1:pucchModeSelect=longPucch
...    NRBTS-1/NRCELL-1:a1MeashoSsbRsrp:a1HysteresishoSsbRsrp=0
...    NRBTS-1/NRCELL-1:a1MeashoSsbRsrp:a1ThresholdhoSsbRsrp=34
...    NRBTS-1/NRCELL-1:a1MeashoSsbRsrp:a1TimeToTriggerhoSsbRsrp=ms480
...    NRBTS-1/NRCELL-1:a2MeasRedirectSsbRsrp:a2HysteresisRedirectSsbRsrp=0
...    NRBTS-1/NRCELL-1:a2MeasRedirectSsbRsrp:a2ThresholdRedirectSsbRsrp=34
...    NRBTS-1/NRCELL-1:a2MeasRedirectSsbRsrp:a2TimeToTriggerRedirectSsbRsrp=ms480
...    NRBTS-1/NRCELL-1:a2MeasRedirectSsbRsrq:a2HysteresisRedirectSsbRsrq=0
...    NRBTS-1/NRCELL-1:a2MeasRedirectSsbRsrq:a2ThresholdRedirectSsbRsrq=31
...    NRBTS-1/NRCELL-1:a2MeasRedirectSsbRsrq:a2TimeToTriggerRedirectSsbRsrq=ms480
...    @{beamforming_enable}
...    @{Change_Golden_Band}


@{Change_Golden_Band}
...    NRCELL-11:freqBandIndicatorNR=66
...    NRCELL-11:gscnOrSsPbchArfcn=5300
...    NRCELL-11/NRCELL_FDD-1:chBwDl=20MHz
...    NRCELL-11/NRCELL_FDD-1:chBwUl=20MHz
...    NRCELL-11/NRCELL_FDD-1:nrarfcnDl=424000
...    NRCELL-11/NRCELL_FDD-1:nrarfcnUl=344000

${CA_SUPPORT_LIST}    ca_Fr1Tdd_Any_Sa,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Fr1Tdd_Nsa,ca_Fdd_Fdd,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Nsa,ca_Fr1Tdd_Fdd_Sa


@{VALID_SCELL_ADD_AD015}
...    NRCELL:a3MeasEnabled=rsrp
...    NRCELL-2:sMeasConfigSsbRsrp=1
...    NRCELL-2:actCDrx=false
...    NRCELL-2:a3MeasEnabled=rsrp
...    NRCELL-11:actCDrx=false
...    NRCELL-11:a3MeasEnabled=rsrp
...    NRCELL-3:a3MeasEnabled=rsrp
...    NRCELL-3:actCDrxVoNR=false
...    NRCELL-3:actCDrx=false
...    NRCELL-3/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-3/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-3/NRREL-2:gNbId=1
...    NRCELL-3/NRREL-2:gNbIdLength=22
...    NRCELL-3/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-3/NRREL-2:lcrId=2
...    NRCELL-3/NRREL-2:removeNotAllowed=false
...    NRCELL-3/NRREL-2:sCellAdditionMethod=blind
...    NRCELL-3/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-3/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-3/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-4/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-4/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-4/NRREL-10:gNbId=1
...    NRCELL-4/NRREL-10:gNbIdLength=22
...    NRCELL-4/NRREL-10:lcrId=3
...    NRCELL-4/NRREL-10:removeNotAllowed=false
...    NRCELL-4/NRREL-10:handoverAllowedSA=allowed
...    NRCELL-4/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-4/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-4/NRREL-10:gnbPlmn:mncLength=3
...    NRPMRNL-1:miNrRelReportCu=15min
...    NRBTS:actIntraFreqHoSA=true
...    NRBTS:timerXnDataFwdGuard=250
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRCELL-4:a3MeasEnabled=rsrp
...    NRCELL-4:sMeasConfigSsbRsrp=1
...    NRCELL-3/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-3/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-3/NRREL-10:gNbId=1
...    NRCELL-3/NRREL-10:gNbIdLength=22
...    NRCELL-3/NRREL-10:lcrId=4
...    NRCELL-3/NRREL-10:removeNotAllowed=false
...    NRCELL-3/NRREL-10:handoverAllowedSA=allowed
...    NRCELL-3/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-3/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-3/NRREL-10:gnbPlmn:mncLength=3

@{origin_params_AD015}
...    NRCELL:a3MeasEnabled=none
...    NRCELL:actCDrx=true
...    NRCELL-3:actCDrxVoNR=true
...    NRCELL-3/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-3/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-3/NRREL-2:gNbId=1
...    NRCELL-3/NRREL-2:gNbIdLength=22
...    NRCELL-3/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-3/NRREL-2:lcrId=12
...    NRCELL-3/NRREL-2:removeNotAllowed=false
...    NRCELL-3/NRREL-2:sCellAdditionMethod=blind
...    NRCELL-3/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-3/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-3/NRREL-2:gnbPlmn:mncLength=3


@{VALID_SCELL_ADD_AD017}
...    NRCELL:a5MeasEnabled=rsrp
...    NRCELL-2:sMeasConfigSsbRsrp=0
...    NRCELL-2:a5MeasEnabled=rsrp
...    NRCELL-4/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-3:a5MeasEnabled=rsrp
...    NRCELL-4/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-4/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-4/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-4/NRREL-10:gNbId=1
...    NRCELL-4/NRREL-10:gNbIdLength=22
...    NRCELL-4/NRREL-10:lcrId=3
...    NRCELL-4/NRREL-10:removeNotAllowed=false
...    NRCELL-4/NRREL-10:handoverAllowedSA=allowed
...    NRCELL-4/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-4/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-4/NRREL-10:gnbPlmn:mncLength=3
...    NRPMRNL-1:miNrRelReportCu=15min
...    NRBTS:actIntraFreqHoSA=true
...    NRBTS:timerXnDataFwdGuard=250
...    NRBTS:actHoOptimizationCa=true
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRCELL-4:a5MeasEnabled=rsrp
...    NRCELL-4:sMeasConfigSsbRsrp=0
...    NRCELL-4:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL-4:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=20
...    NRCELL-4:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=29
...    NRCELL-4:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=0ms
...    NRCELL-4:a1MeasSCellAddEnabled=rsrp
...    NRCELL-3/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-3/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-3/NRREL-10:gNbId=1
...    NRCELL-3/NRREL-10:gNbIdLength=22
...    NRCELL-3/NRREL-10:lcrId=4
...    NRCELL-3/NRREL-10:removeNotAllowed=false
...    NRCELL-3/NRREL-10:handoverAllowedSA=allowed
...    NRCELL-3/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-3/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-3/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-3/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-3/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-3/NRREL-2:gNbId=1
...    NRCELL-3/NRREL-2:gNbIdLength=22
...    NRCELL-3/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-3/NRREL-2:lcrId=12
...    NRCELL-3/NRREL-2:removeNotAllowed=false
...    NRCELL-3/NRREL-2:sCellAdditionMethod=blind
...    NRCELL-3/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-3/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-3/NRREL-2:gnbPlmn:mncLength=3

${TDD_SCELL_FOR_NRCELL4}    NRCELL-1
${FDD_SCELL_FOR_NRCELL4}    NRCELL-11

${TDD_SCELL_FOR_NRCELL3}    NRCELL-2
${FDD_SCELL_FOR_NRCELL3}    NRCELL-11
${FDD_SCELL2_FOR_NRCELL3}    NRCELL-12


${SA_Capa_perUE_Full}    SEPARATOR=
...    E9A09000575F5A13160003C320016093170019C3D09009B20C39F30C7942C0E098040623807DC6C28C0D608C21A08107482406D6C98
...    AB1A1CF88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE00088000E0541B107582308682041E2090195B262A
...    C4873EC09F11C78C48E3C873EA39F30C7942C0E070F09FD8000007F600000044000702A8D89BAC1184341020E90480C2D931544439F
...    11C788E3D033EC09F18E7CC31E50B0381C3C17003FF001C00FFC00110001C0AE3E236B04610D04083E50480AAD931561439F11C78C0
...    0000000000000000040E1E027FFC00001FFF00000110001C00F78789A001C4100000216020541E14000711800000858158788C001C4
...    1000006160561E14000710400000858158789A001C46000002160562E2300071040038820000142C0AC3C28000E268000060B02B171
...    34003882001C28000008160562E26800711800388C0000082C0AC5C28000E20800711800001058158B850001C41000E208000020B02
...    B17134003882001C46000004160562E14000711800388C0000082C0AC5C4D000E2300070A000002058158788C001C46000006160401
...    C0468051013602086A0BB07C28913639F0E14489B1CF870A244D8E7C3851226C73E1C28913639F0E2448913639F0E14081B1CF81120
...    4081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF810A040D8E7C00170F18C
...    6318C6318C6318C61E8260078005038280381804A00E000C0480080C07C120040000000200000401000000008000010040000100200
...    000C01000008008000050040020080200800006004000038020010000000400004002000024010000060080000A0040000580200102
...    40900400006019CA9ACA9AC14AC0CAC19AC15ACA5AC99AC05AC0DAC04AC08AC1DA0682000012CA4A080000CB29282000052CA480800
...    01CB29202000092CA48080002CB292020000D2CA48080003CB29202000112CA48080004CB29202000152CA48080005CB29282000192
...    CA480800018B292019A55574AAAA9545D2A8AA0B154162A83455298AA4D154062A8145526AAA0F142405E02540A05028140A0502814
...    0A05028140A05028140A05000608080600C02004008404008020100C018402004008080600C02018030404030060100C01840200400
...    8080600C02004008804030060100C018040300608080100402004010D50F8000810182030385058606880889098A0C0C8D8E0E8F909
...    293139414951697A0A0C168


&{CELLS_SSBFREQ}
...     1=632736
...     2=648096
...     3=508110
...     4=508110
...     11=424090
...     12=126750

${UE_PCELL_2_CONF_SCELL_DL_SA}    M55118C07001    #Sum of CA UEs in the current cell configured as a PCell, which have 2 configured SCells in DL
${RRC_RECONF_ADD2DLSCELL_SUCC_SA}    M55118C07003    #Successful RRC Reconfigurations attempts for 2 SCells Addition in DL for SA mode
${RRC_RECONF_ADD2DLSCELL_ATT_SA}    M55118C07004    #RRC Reconfigurations attempts for 2 SCells Addition in DL for SA mode
${UE_SCELL_2_CONF_SCELL_DL_SA}    M55118C07002    #Sum of CA UEs in the current cell configured as a SCell, which have 2 configured SCells in DL


${UE_PCELL_1_CONF_SCELL_DL_SA}    M55118C05507
${RRC_RECONF_ADD1DLSCELL_ATT_SA}    M55118C05505


@{PM_COUNTER_AD015}
...     ${UE_PCELL_1_CONF_SCELL_DL_SA}==0
...     ${RRC_RECONF_ADD1DLSCELL_ATT_SA}==0
...     NRCELL-3:${UE_PCELL_2_CONF_SCELL_DL_SA}>0
...     NRCELL-4:${UE_PCELL_2_CONF_SCELL_DL_SA}>0
...     NRCELL-1:${UE_SCELL_2_CONF_SCELL_DL_SA}>0
...     NRCELL-11:${UE_SCELL_2_CONF_SCELL_DL_SA}>0
...     NRCELL-3:${RRC_RECONF_ADD2DLSCELL_SUCC_SA}==1
...     NRCELL-4:${RRC_RECONF_ADD2DLSCELL_SUCC_SA}==2
...     NRCELL-3:${RRC_RECONF_ADD2DLSCELL_ATT_SA}==1
...     NRCELL-4:${RRC_RECONF_ADD2DLSCELL_ATT_SA}==2

@{PM_COUNTER_AD017}
...     ${UE_PCELL_1_CONF_SCELL_DL_SA}==0
...     ${RRC_RECONF_ADD1DLSCELL_ATT_SA}==0
...     NRCELL-3:${UE_PCELL_2_CONF_SCELL_DL_SA}>0
...     NRCELL-4:${UE_PCELL_2_CONF_SCELL_DL_SA}>0
...     NRCELL-1:${UE_SCELL_2_CONF_SCELL_DL_SA}>0
...     NRCELL-11:${UE_SCELL_2_CONF_SCELL_DL_SA}>0
...     NRCELL-12:${UE_SCELL_2_CONF_SCELL_DL_SA}>0
...     NRCELL-3:${RRC_RECONF_ADD2DLSCELL_SUCC_SA}==1
...     NRCELL-4:${RRC_RECONF_ADD2DLSCELL_SUCC_SA}==2
...     NRCELL-3:${RRC_RECONF_ADD2DLSCELL_ATT_SA}==1
...     NRCELL-4:${RRC_RECONF_ADD2DLSCELL_ATT_SA}==2

*** Test Cases ***
CB006138-ET-AD015_Verify_SA_A3_rsrp_intrafreq_intragNB_HO_from_3CC_TTF_with_scell_blind_to_3CC_TTF
    [Documentation]
    ...    1. The purpose of this test case is to verify Interworking with DRX during intrafreq handover,
    ...       while source cell drx=true, target cell drx=false
    ...    2. Test Case Steps:
    ...         step1. setup ue (PCell 4), blind add scell (TDD SCell 1 and FDD SCell 11)
    ...         Expected Results:
    ...                TDD scell and FDD scell can added.
    ...         step2. HO to TTF, blind scell add (Target cell TDD Cell3 , TDD SCell 2 and FDD SCell 11)
    ...         Expected Results:
    ...                HO successful and scell add successful
    ...         step3. HO back to original Pcell 4 , scell added automatically (TDD SCell 1 and FDD SCell 11)
    ...         Expected Results:
    ...                HO successful and scell add successful automatically without A1 MR.
    ...    Count check: M55118C05507,M55118C05505,M55118C07001,M55118C07002,M55118C07003,M55118C07004
    [Tags]    CB006138-AD015    Owner_Yangchunjian    QC_133899
    [Timeout]    60 min
    Before_ue_attach_AD015
    UE Attach and L3 Normal Call    ue_id=81    pdu_gw_id=1
    Check Two Scell Added Successfully    NRCELL-4    ${TDD_SCELL_FOR_NRCELL4}    ${FDD_SCELL_FOR_NRCELL4}
    Verify Throuput on Pscell and Scell    ue_id=81    pdu_gw_id=1
    Start RRC Log       AD015_IntraFreqIntraGNB_HO
    IntraFreq IntragNB HO    ue_id=81    source_cell=4    target_cell=3    target_phycell_id=52    event=A3
    Check Two Scell Added Successfully    NRCELL-3    ${TDD_SCELL_FOR_NRCELL3}    ${FDD_SCELL_FOR_NRCELL3}
    Verify Throuput on Pscell and Scell    ue_id=81    pdu_gw_id=1
    Start RRC Log       AD015_IntraFreqIntraGNB_HO_2
    IntraFreq IntragNB HO    ue_id=81    source_cell=3    target_cell=4    target_phycell_id=53    event=A3
    Check Two Scell Added Successfully    NRCELL-4    ${TDD_SCELL_FOR_NRCELL4}    ${FDD_SCELL_FOR_NRCELL4}
    Verify Throuput on Pscell and Scell    ue_id=81    pdu_gw_id=1
    Check WireShark Log    ${CURDIR}${/}a2a_AD015${/}a2a.ini
    ...    wait_string=UEContextModificationResponse::38
    Check Counters    ${PM_COUNTER_AD015}
    Release Ues    ue_type=all
    [Teardown]    Recover Param and Common Test Teardown    ${origin_params_AD015}

CB006138-ET-AD017_Verify_SA_A5_rsrp_intrafreq_intragNB_HO_from_3CC_TTF_with_scell_covBasedA1_to_3CC_TFF_VoNR
    [Documentation]
    ...    1. The purpose of this test case is to verify intrafreq intragnb HO from 3CC TTF with scell covBasedA1 to
    ...    TFF with vonr call setup.
    ...    2. Test Case Steps:
    ...         step1. setup ue to pcell cell4 , then setup vonr, then send A1 to add scell (1,11)
    ...         Expected Results:
    ...                vonr call setup, and 2scell added
    ...         step2. HO to TFF pcell cell3 (scell:11,12), blind scell add
    ...         Expected Results:
    ...                HO successful and scell add successful
    ...         step3. HO back to TTF, scell added automatically as actHoOptimizationCa enable and rsrp fullfiled
    ...         Expected Results:
    ...                HO successful and scell add successful automatically without A1 MR.
    ...    Count check: M55118C05507,M55118C05505,M55118C07001,M55118C07002,M55118C07003,M55118C07004
    [Tags]    CB006138-AD017    Owner_dandchen    QC_133897
    [Timeout]    60 min
    Before_ue_attach_AD017
    UE Attach and L3 VoNR Call    ue_id=81    pdu_gw_id=2
    Triggered Scell Addition by A1    pcell=4
    Check Two Scell Added Successfully    NRCELL-4    ${TDD_SCELL_FOR_NRCELL4}    ${FDD_SCELL_FOR_NRCELL4}
    Verify Throuput on Pscell and Scell    ue_id=81    pdu_gw_id=2
    Start RRC Log       AD017_IntraFreqIntraGNB_HO
    IntraFreq IntragNB HO    ue_id=81    source_cell=4    target_cell=3    target_phycell_id=52    event=A5
    Check Two Scell Added Successfully    NRCELL-3    ${FDD_SCELL_FOR_NRCELL3}    ${FDD_SCELL2_FOR_NRCELL3}
    Verify Throuput on Pscell and Scell    ue_id=81    pdu_gw_id=2
    Start RRC Log       AD017_IntraFreqIntraGNB_HO_2
    IntraFreq IntragNB HO    ue_id=81    source_cell=3    target_cell=4    target_phycell_id=53    event=A5
    Check Two Scell Added Successfully    NRCELL-4    ${TDD_SCELL_FOR_NRCELL4}    ${FDD_SCELL_FOR_NRCELL4}
    Verify Throuput on Pscell and Scell    ue_id=81    pdu_gw_id=2
    Check WireShark Log    ${CURDIR}${/}a2a_AD017${/}a2a.ini
    ...    wait_string=UEContextModificationResponse::52
    Check Counters    ${PM_COUNTER_AD017}
    Release Ues    ue_type=all


*** Keywords ***
Modify Cfg
    Delete Cfg    set_qosflow id=1 5qi=6 default=on
    Update Cfg    set_nwslice id=1 snssai=0x01:0xD143A5 default=on ue=all amf=1 qos_flows=1,2,3 qos_rules=1,2
    Update Cfg    set_qosflow id=1 5qi=5 default=on
    Update Cfg    set_qosflow id=2 5qi=1
    Update Cfg    set_qosflow id=3 5qi=2
    Update Cfg    set_qosrule id=1 proto=tcp qos_flow=1
    Update Cfg    set_qosrule id=2 proto=udp qos_flow=2
    Update Cfg    set_qosrule id=3 proto=udp qos_flow=3
    Update Cfg    ue_nr_capabilities id=81 voice_over_nr=on:on:off
    Update Cfg    ue_param id=81 ue_nr_capabilities=${SA_Capa_perUE_Full} nr_usage_setting=voice_centric
    ${cell4_config}    Catenate    set_cell id=4 gnb=2 pci=17:2 tac=200 nrci=0x04 tdd_cell=on
    ...    proxy=$PROXY_SERVER_IP:9999|$PROXY_SERVER_IP:8888 nr_arfcn=508020:508020
    ...    gscn=6351 mandatory_for_activation=off
    Update Cfg    ${cell4_config}
    ${cell_11}    catenate    set_cell id=11 gnb=2 pci=20:0 tac=200 nrci=0x0B tdd_cell=off
    ...    proxy=$PROXY_SERVER_IP:9999|$PROXY_SERVER_IP:8888 nr_arfcn=344000:424000 gscn=5300 mandatory_for_activation=off
    Update Cfg    ${cell_11}

Verify Throuput on Pscell and Scell
    [Arguments]    ${ue_id}    ${pdu_gw_id}
    Execute Egate Command    ue_disp
    ${ret0}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-5 type=pdsch    pass_regexp=Average
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000 > 100
    ${scell1_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=1    type=pdsch    rate_type=ave
    Should Be True    ${scell1_tput}/1000 > 10
    ${scell2_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=2    type=pdsch    rate_type=ave
    #Should Be True    ${scell2_tput}/1000 > 5
    Should Be True    ${scell0_tput}/1000+${scell1_tput}/1000+${scell2_tput}/1000 > 540
    Verify SA DL and UL Traffic    ${ue_id}    ${pdu_gw_id}

Verify SA DL and UL Traffic
    [Arguments]    ${ue_id}    ${pdu_gw_id}
    ${ul_throuput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_gw_id}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${ul_throuput}/1000>9
    ${dl_throuput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_gw_id}    qfi=1    direction=dl    rate_type=ave
    Should Be True    ${dl_throuput}/1000>100

Before_ue_attach_AD015
    Delta Commission Parameters     ${VALID_SCELL_ADD_AD015}
    Execute Egate Command    ue_change_location id=81 enb=2 cell=4
    Clear Counter Files
    Start RRC Log    AD015

Before_ue_attach_AD017
    Delta Commission Parameters     ${VALID_SCELL_ADD_AD017}
    Execute Egate Command    ue_change_location id=81 enb=2 cell=4
    Execute Egate Command    smf_param id=1 reset
    Clear Counter Files
    Start RRC Log    AD017

Check Two Scell Added Successfully
    [Arguments]    ${pcell}    ${scell1}    ${scell2}
    ${NRREL1_sCellAdditionMethod}    Get Scf Parameter Value    MRBTS-1/NRBTS-1/${pcell}/NRREL-1:sCellAdditionMethod
    ${NRREL2_sCellAdditionMethod}    Get Scf Parameter Value    MRBTS-1/NRBTS-1/${pcell}/NRREL-2:sCellAdditionMethod
    ${SCELL1_physCellId}    Get Scf Parameter Value    ${scell1}:physCellId
    ${SCELL2_physCellId}    Get Scf Parameter Value    ${scell2}:physCellId
    Rrc Should Contain    sCellToAddModList    physCellId ${SCELL1_physCellId}    physCellId ${SCELL2_physCellId}
    Rrc Should Contain    SCellIndex 2 activated successfully

UE Attach and L3 Normal Call
    [Arguments]    ${ue_id}    ${pdu_gw_id}
    Execute Egate Command    smf_param id=1 reset
    Execute Egate Command    qosflow_modify qos_flow=1 default=on
    Execute Egate Command    ue_register id=${ue_id}     pass_regexp=Received REGISTRATION COMPLETE
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_gw_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup pdu=${pdu_gw_id} ue=${ue_id} nwslice=1 gw=${pdu_gw_id}
    ...                      pass_regexp=Initial Context Setup Successful
    Execute Egate Command    qosflow_disp
    Start Traffic    ${ue_id}    ${pdu_gw_id}

UE Attach and L3 VoNR Call
    [Arguments]    ${ue_id}    ${pdu_gw_id}
    Execute Egate Command    smf_param id=1 reset
    Execute Egate Command    qosflow_modify qos_flow=1 default=on
    Execute Egate Command    ue_register id=${ue_id}     pass_regexp=Received REGISTRATION COMPLETE
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_gw_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup pdu=${pdu_gw_id} ue=${ue_id} nwslice=1 gw=${pdu_gw_id}
    ...                      pass_regexp=Initial Context Setup Successful
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu_gw_id} qosflows_to_add=2 by=amf
    ...                      pass_regexp=Added QosFlow with QFI:2 fiveQI:1
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

IntraFreq IntragNB HO
    [Arguments]    ${ue_id}    ${source_cell}    ${target_cell}    ${target_phycell_id}    ${event}
    Execute Egate Command    ue_disp
    ${src_cell_ssbfreq}    Get From Dictionary    ${CELLS_SSBFREQ}    ${source_cell}
    ${meas_id}    Get Nr Meas Id For Specific Type And Frequency    ${ue_id}    ${src_cell_ssbfreq}    ${event}
    ${event_cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event}
    ...    srsrp_nr=11 srsrq_nr=11 phycell_id=${target_phycell_id} nrsrp_nr=60 nrsrq_nr=60
    Execute Egate Command    ${event_cmd}
    ...    pass_regexp=Intra-eNB handover from EXT_ENB-2.${source_cell} to EXT_ENB-2.${target_cell} performed

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