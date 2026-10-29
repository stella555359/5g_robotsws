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

@{PARAMS_IN_SCF}
...    NRCELL:actK1Opt=intra-gNB
...    NRCELL:sMeasConfigSsbRsrp=1
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
...    NRCELL:actPrachMultiplexing=true
...    NRCELL:pucchF3MaxCodeRate=zeroDot08
...    NRCELL:pucchModeSelect=longPucch
...    NRCELL:actCDrx=true
...    NRCELL:pucchF3ModulationScheme=pi2bpsk
...    NRBTS:actConflictConfiguration=true
...    NRBTS:timerXnDataFwdGuard=250
...    NRBTS:actIncXn=true
...    NRBTS:actInterFreqHoSA=true
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS-1/NRCELL-4:actBeamforming=true
...    NRBTS-1/NRCELL-4:beamSet:basicBeamSet=beamSet_4
...    NRBTS-1/NRCELL-4:beamSet:leftEdgeAngle=60
...    NRBTS-1/NRCELL-4:beamSet:nrBtsBeamRefinementP2=false
...    NRBTS-1/NRCELL-4:beamSet:rightEdgeAngle=60
...    NRBTS-1/NRCELL-4:drxProfile2:drxInactivityTimer=4ms
...    NRBTS-1/NRCELL-4:drxProfile2:drxLongCycle=40ms
...    NRBTS-1/NRCELL-4:drxProfile2:drxOnDurationTimer=6ms
...    NRBTS-1/NRCELL-4:drxProfile2:drxRetransTimerDl=0slot
...    NRBTS-1/NRCELL-4:drxProfile2:drxRetransTimerUl=0slot
...    NRBTS-1/NRCELL-4:drxProfile1:drxInactivityTimer=40ms
...    NRBTS-1/NRCELL-4:drxProfile1:drxLongCycle=80ms
...    NRBTS-1/NRCELL-4:drxProfile1:drxOnDurationTimer=10ms
...    NRBTS-1/NRCELL-4:drxProfile1:drxRetransTimerDl=16slot
...    NRBTS-1/NRCELL-4:drxProfile1:drxRetransTimerUl=16slot
...    NRBTS-1/NRCELL-4:actCDrx=true
...    NRBTS-1/NRCELL-4:a2MeashoSsbRsrp:a2HysteresishoSsbRsrp=1
...    NRBTS-1/NRCELL-4:a2MeashoSsbRsrp:a2ThresholdhoSsbRsrp=34
...    NRBTS-1/NRCELL-4:a2MeashoSsbRsrp:a2TimeToTriggerhoSsbRsrp=ms480
...    NRBTS-1/NRCELL-4:actPrachMultiplexing=true
...    NRBTS-1/NRCELL-4:a5MeasSsbRsrq:a5HysteresisSsbRsrq=0
...    NRBTS-1/NRCELL-4:a5MeasSsbRsrq:a5Threshold1SsbRsrq=75
...    NRBTS-1/NRCELL-4:a5MeasSsbRsrq:a5Threshold2SsbRsrq=85
...    NRBTS-1/NRCELL-4:a5MeasSsbRsrq:a5TimeToTriggerSsbRsrq=ms0
...    NRBTS-1/NRCELL-4:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRBTS-1/NRCELL-4:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRBTS-1/NRCELL-4:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRBTS-1/NRCELL-4:pucchF3MaxCodeRate=zeroDot08
...    NRBTS-1/NRCELL-4:a2MeasRedirectSsbRsrp:a2HysteresisRedirectSsbRsrp=0
...    NRBTS-1/NRCELL-4:a2MeasRedirectSsbRsrp:a2ThresholdRedirectSsbRsrp=34
...    NRBTS-1/NRCELL-4:a2MeasRedirectSsbRsrp:a2TimeToTriggerRedirectSsbRsrp=ms480
...    NRBTS-1/NRCELL-4:a5MeasSsbRsrp:a5HysteresisSsbRsrp=0
...    NRBTS-1/NRCELL-4:a5MeasSsbRsrp:a5Threshold1SsbRsrp=75
...    NRBTS-1/NRCELL-4:a5MeasSsbRsrp:a5Threshold2SsbRsrp=85
...    NRBTS-1/NRCELL-4:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms0
...    NRBTS-1/NRCELL-4:a1MeashoSsbRsrp:a1HysteresishoSsbRsrp=0
...    NRBTS-1/NRCELL-4:a1MeashoSsbRsrp:a1ThresholdhoSsbRsrp=34
...    NRBTS-1/NRCELL-4:a1MeashoSsbRsrp:a1TimeToTriggerhoSsbRsrp=ms480
...    NRBTS-1/NRCELL-4:a1MeashoSsbRsrq:a1HysteresishoSsbRsrq=0
...    NRBTS-1/NRCELL-4:a1MeashoSsbRsrq:a1ThresholdhoSsbRsrq=31
...    NRBTS-1/NRCELL-4:a1MeashoSsbRsrq:a1TimeToTriggerhoSsbRsrq=ms480
...    NRBTS-1/NRCELL-4:a2MeasRedirectSsbRsrq:a2HysteresisRedirectSsbRsrq=0
...    NRBTS-1/NRCELL-4:a2MeasRedirectSsbRsrq:a2ThresholdRedirectSsbRsrq=31
...    NRBTS-1/NRCELL-4:a2MeasRedirectSsbRsrq:a2TimeToTriggerRedirectSsbRsrq=ms480
...    NRBTS-1/NRCELL-4:a2MeasReleaseSsbRsrq:a2HysteresisReleaseSsbRsrq=0
...    NRBTS-1/NRCELL-4:a2MeasReleaseSsbRsrq:a2ThresholdReleaseSsbRsrq=75
...    NRBTS-1/NRCELL-4:a2MeasReleaseSsbRsrq:a2TimeToTriggerReleaseSsbRsrq=ms0
...    NRBTS-1/NRCELL-4:pucchModeSelect=longPucch
...    NRBTS-1/NRCELL-4:a2MeasReleaseSsbRsrp:a2HysteresisReleaseSsbRsrp=0
...    NRBTS-1/NRCELL-4:a2MeasReleaseSsbRsrp:a2ThresholdReleaseSsbRsrp=75
...    NRBTS-1/NRCELL-4:a2MeasReleaseSsbRsrp:a2TimeToTriggerReleaseSsbRsrp=ms0
...    NRBTS-1/NRCELL-4:pucchF3ModulationScheme=pi2bpsk
...    NRBTS-1/NRCELL-1:actBeamforming=true
...    NRBTS-1/NRCELL-1:beamSet:basicBeamSet=beamSet_4
...    NRBTS-1/NRCELL-1:beamSet:leftEdgeAngle=60
...    NRBTS-1/NRCELL-1:beamSet:nrBtsBeamRefinementP2=false
...    NRBTS-1/NRCELL-1:beamSet:rightEdgeAngle=60
...    NRBTS-1/NRCELL-1:actPrachMultiplexing=true
...    NRBTS-1/NRCELL-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRBTS-1/NRCELL-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRBTS-1/NRCELL-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRBTS-1/NRCELL-1:a2MeasRedirectSsbRsrp:a2HysteresisRedirectSsbRsrp=0
...    NRBTS-1/NRCELL-1:a2MeasRedirectSsbRsrp:a2ThresholdRedirectSsbRsrp=34
...    NRBTS-1/NRCELL-1:a2MeasRedirectSsbRsrp:a2TimeToTriggerRedirectSsbRsrp=ms480
...    NRBTS-1/NRCELL-1:a5MeasSsbRsrp:a5HysteresisSsbRsrp=0
...    NRBTS-1/NRCELL-1:a5MeasSsbRsrp:a5Threshold1SsbRsrp=75
...    NRBTS-1/NRCELL-1:a5MeasSsbRsrp:a5Threshold2SsbRsrp=85
...    NRBTS-1/NRCELL-1:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms0
...    NRBTS-1/NRCELL-1:a1MeashoSsbRsrq:a1HysteresishoSsbRsrq=0
...    NRBTS-1/NRCELL-1:a1MeashoSsbRsrq:a1ThresholdhoSsbRsrq=31
...    NRBTS-1/NRCELL-1:a1MeashoSsbRsrq:a1TimeToTriggerhoSsbRsrq=ms480
...    NRBTS-1/NRCELL-1:a2MeasRedirectSsbRsrq:a2HysteresisRedirectSsbRsrq=0
...    NRBTS-1/NRCELL-1:a2MeasRedirectSsbRsrq:a2ThresholdRedirectSsbRsrq=31
...    NRBTS-1/NRCELL-1:a2MeasRedirectSsbRsrq:a2TimeToTriggerRedirectSsbRsrq=ms480
...    NRBTS-1/NRCELL-1:pucchModeSelect=longPucch
...    NRBTS-1/NRCELL-1:a2MeashoSsbRsrp:a2HysteresishoSsbRsrp=1
...    NRBTS-1/NRCELL-1:a2MeashoSsbRsrp:a2ThresholdhoSsbRsrp=34
...    NRBTS-1/NRCELL-1:a2MeashoSsbRsrp:a2TimeToTriggerhoSsbRsrp=ms480
...    NRBTS-1/NRCELL-1:a5MeasSsbRsrq:a5HysteresisSsbRsrq=0
...    NRBTS-1/NRCELL-1:a5MeasSsbRsrq:a5Threshold1SsbRsrq=75
...    NRBTS-1/NRCELL-1:a5MeasSsbRsrq:a5Threshold2SsbRsrq=85
...    NRBTS-1/NRCELL-1:a5MeasSsbRsrq:a5TimeToTriggerSsbRsrq=ms0
...    NRBTS-1/NRCELL-1:pucchF3MaxCodeRate=zeroDot08
...    NRBTS-1/NRCELL-1:a1MeashoSsbRsrp:a1HysteresishoSsbRsrp=0
...    NRBTS-1/NRCELL-1:a1MeashoSsbRsrp:a1ThresholdhoSsbRsrp=34
...    NRBTS-1/NRCELL-1:a1MeashoSsbRsrp:a1TimeToTriggerhoSsbRsrp=ms480
...    NRBTS-1/NRCELL-1:a2MeasReleaseSsbRsrq:a2HysteresisReleaseSsbRsrq=0
...    NRBTS-1/NRCELL-1:a2MeasReleaseSsbRsrq:a2ThresholdReleaseSsbRsrq=75
...    NRBTS-1/NRCELL-1:a2MeasReleaseSsbRsrq:a2TimeToTriggerReleaseSsbRsrq=ms0
...    NRBTS-1/NRCELL-1:actCDrx=true
...    NRBTS-1/NRCELL-1:a2MeasReleaseSsbRsrp:a2HysteresisReleaseSsbRsrp=0
...    NRBTS-1/NRCELL-1:a2MeasReleaseSsbRsrp:a2ThresholdReleaseSsbRsrp=75
...    NRBTS-1/NRCELL-1:a2MeasReleaseSsbRsrp:a2TimeToTriggerReleaseSsbRsrp=ms0
...    NRBTS-1/NRCELL-1:pucchF3ModulationScheme=pi2bpsk
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
...    NRCELL-4:actCDrx=true
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
...    NRCELL-4:a2MeashoSsbRsrp:a2HysteresishoSsbRsrp=1
...    NRCELL-4:a2MeashoSsbRsrp:a2ThresholdhoSsbRsrp=34
...    NRCELL-4:a2MeashoSsbRsrp:a2TimeToTriggerhoSsbRsrp=ms480
...    NRCELL-4:actPrachMultiplexing=true
...    NRCELL-4:a5MeasSsbRsrq:a5HysteresisSsbRsrq=0
...    NRCELL-4:a5MeasSsbRsrq:a5Threshold1SsbRsrq=75
...    NRCELL-4:a5MeasSsbRsrq:a5Threshold2SsbRsrq=85
...    NRCELL-4:a5MeasSsbRsrq:a5TimeToTriggerSsbRsrq=ms0
...    NRCELL-4:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRCELL-4:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL-4:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL-4:pucchF3MaxCodeRate=zeroDot08
...    NRCELL-4:a2MeasRedirectSsbRsrp:a2HysteresisRedirectSsbRsrp=0
...    NRCELL-4:a2MeasRedirectSsbRsrp:a2ThresholdRedirectSsbRsrp=34
...    NRCELL-4:a2MeasRedirectSsbRsrp:a2TimeToTriggerRedirectSsbRsrp=ms480
...    NRCELL-4:a5MeasSsbRsrp:a5HysteresisSsbRsrp=0
...    NRCELL-4:a5MeasSsbRsrp:a5Threshold1SsbRsrp=75
...    NRCELL-4:a5MeasSsbRsrp:a5Threshold2SsbRsrp=85
...    NRCELL-4:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms0
...    NRCELL-4:a1MeashoSsbRsrp:a1HysteresishoSsbRsrp=0
...    NRCELL-4:a1MeashoSsbRsrp:a1ThresholdhoSsbRsrp=34
...    NRCELL-4:a1MeashoSsbRsrp:a1TimeToTriggerhoSsbRsrp=ms480
...    NRCELL-4:a1MeashoSsbRsrq:a1HysteresishoSsbRsrq=0
...    NRCELL-4:a1MeashoSsbRsrq:a1ThresholdhoSsbRsrq=31
...    NRCELL-4:a1MeashoSsbRsrq:a1TimeToTriggerhoSsbRsrq=ms480
...    NRCELL-4:a2MeasRedirectSsbRsrq:a2HysteresisRedirectSsbRsrq=0
...    NRCELL-4:a2MeasRedirectSsbRsrq:a2ThresholdRedirectSsbRsrq=31
...    NRCELL-4:a2MeasRedirectSsbRsrq:a2TimeToTriggerRedirectSsbRsrq=ms480
...    NRCELL-4:a2MeasReleaseSsbRsrq:a2HysteresisReleaseSsbRsrq=0
...    NRCELL-4:a2MeasReleaseSsbRsrq:a2ThresholdReleaseSsbRsrq=75
...    NRCELL-4:a2MeasReleaseSsbRsrq:a2TimeToTriggerReleaseSsbRsrq=ms0
...    NRCELL-4:pucchModeSelect=longPucch
...    NRCELL-4:a2MeasReleaseSsbRsrp:a2HysteresisReleaseSsbRsrp=0
...    NRCELL-4:a2MeasReleaseSsbRsrp:a2ThresholdReleaseSsbRsrp=75
...    NRCELL-4:a2MeasReleaseSsbRsrp:a2TimeToTriggerReleaseSsbRsrp=ms0
...    NRCELL-4:pucchF3ModulationScheme=pi2bpsk
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
...    NRCELL-3:a2MeashoEnabledSA=rsrp
...    NRCELL-3:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=80
...    NRCELL-3:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRCELL-3:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms0
...    NRCELL-3:a1MeashoEnabledSA=rsrp
...    NRCELL-3:sMeasConfigSsbRsrp=0
...    NRCELL-3:a1MeasSCellAddEnabled=rsrp
...    NRCELL-3:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=35
...    NRCELL-3:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0
...    NRCELL-3:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms0
...    NRCELL-3:a2MeashoSsbRsrp:a2HysteresishoSsbRsrp=1
...    NRCELL-3:a2MeashoSsbRsrp:a2ThresholdhoSsbRsrp=34
...    NRCELL-3:a2MeashoSsbRsrp:a2TimeToTriggerhoSsbRsrp=ms480
...    NRCELL-3:actPrachMultiplexing=true
...    NRCELL-3:a5MeasSsbRsrq:a5HysteresisSsbRsrq=0
...    NRCELL-3:a5MeasSsbRsrq:a5Threshold1SsbRsrq=75
...    NRCELL-3:a5MeasSsbRsrq:a5Threshold2SsbRsrq=85
...    NRCELL-3:a5MeasSsbRsrq:a5TimeToTriggerSsbRsrq=ms0
...    NRCELL-3:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRCELL-3:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL-3:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL-3:pucchF3MaxCodeRate=zeroDot08
...    NRCELL-3:a2MeasRedirectSsbRsrp:a2HysteresisRedirectSsbRsrp=0
...    NRCELL-3:a2MeasRedirectSsbRsrp:a2ThresholdRedirectSsbRsrp=34
...    NRCELL-3:a2MeasRedirectSsbRsrp:a2TimeToTriggerRedirectSsbRsrp=ms480
...    NRCELL-3:a5MeasSsbRsrp:a5HysteresisSsbRsrp=0
...    NRCELL-3:a5MeasSsbRsrp:a5Threshold1SsbRsrp=75
...    NRCELL-3:a5MeasSsbRsrp:a5Threshold2SsbRsrp=85
...    NRCELL-3:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms0
...    NRCELL-3:a1MeashoSsbRsrp:a1HysteresishoSsbRsrp=0
...    NRCELL-3:a1MeashoSsbRsrp:a1ThresholdhoSsbRsrp=34
...    NRCELL-3:a1MeashoSsbRsrp:a1TimeToTriggerhoSsbRsrp=ms480
...    NRCELL-3:a1MeashoSsbRsrq:a1HysteresishoSsbRsrq=0
...    NRCELL-3:a1MeashoSsbRsrq:a1ThresholdhoSsbRsrq=31
...    NRCELL-3:a1MeashoSsbRsrq:a1TimeToTriggerhoSsbRsrq=ms480
...    NRCELL-3:a2MeasRedirectSsbRsrq:a2HysteresisRedirectSsbRsrq=0
...    NRCELL-3:a2MeasRedirectSsbRsrq:a2ThresholdRedirectSsbRsrq=31
...    NRCELL-3:a2MeasRedirectSsbRsrq:a2TimeToTriggerRedirectSsbRsrq=ms480
...    NRCELL-3:a2MeasReleaseSsbRsrq:a2HysteresisReleaseSsbRsrq=0
...    NRCELL-3:a2MeasReleaseSsbRsrq:a2ThresholdReleaseSsbRsrq=75
...    NRCELL-3:a2MeasReleaseSsbRsrq:a2TimeToTriggerReleaseSsbRsrq=ms0
...    NRCELL-3:pucchModeSelect=longPucch
...    NRCELL-3:a2MeasReleaseSsbRsrp:a2HysteresisReleaseSsbRsrp=0
...    NRCELL-3:a2MeasReleaseSsbRsrp:a2ThresholdReleaseSsbRsrp=75
...    NRCELL-3:a2MeasReleaseSsbRsrp:a2TimeToTriggerReleaseSsbRsrp=ms0
...    NRCELL-3:pucchF3ModulationScheme=pi2bpsk
...    NRCELLGRP-3:numberOfTransmittedSsBlocks=4 beams
...    NRCELLGRP-0:numberOfTransmittedSsBlocks=4 beams
...    NRBTS-1/NRCELL-11:pMax=380
...    NRBTS-1/NRCELL-11:actPrachMultiplexing=true
...    NRBTS-1/NRCELL-11:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRBTS-1/NRCELL-11:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRBTS-1/NRCELL-11:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRBTS-1/NRCELL-11:a2MeasRedirectSsbRsrp:a2HysteresisRedirectSsbRsrp=0
...    NRBTS-1/NRCELL-11:a2MeasRedirectSsbRsrp:a2ThresholdRedirectSsbRsrp=34
...    NRBTS-1/NRCELL-11:a2MeasRedirectSsbRsrp:a2TimeToTriggerRedirectSsbRsrp=ms480
...    NRBTS-1/NRCELL-11:a5MeasSsbRsrp:a5HysteresisSsbRsrp=0
...    NRBTS-1/NRCELL-11:a5MeasSsbRsrp:a5Threshold1SsbRsrp=75
...    NRBTS-1/NRCELL-11:a5MeasSsbRsrp:a5Threshold2SsbRsrp=85
...    NRBTS-1/NRCELL-11:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms0
...    NRBTS-1/NRCELL-11:a1MeashoSsbRsrq:a1HysteresishoSsbRsrq=0
...    NRBTS-1/NRCELL-11:a1MeashoSsbRsrq:a1ThresholdhoSsbRsrq=31
...    NRBTS-1/NRCELL-11:a1MeashoSsbRsrq:a1TimeToTriggerhoSsbRsrq=ms480
...    NRBTS-1/NRCELL-11:a2MeasRedirectSsbRsrq:a2HysteresisRedirectSsbRsrq=0
...    NRBTS-1/NRCELL-11:a2MeasRedirectSsbRsrq:a2ThresholdRedirectSsbRsrq=31
...    NRBTS-1/NRCELL-11:a2MeasRedirectSsbRsrq:a2TimeToTriggerRedirectSsbRsrq=ms480
...    NRBTS-1/NRCELL-11:pucchModeSelect=longPucch
...    NRBTS-1/NRCELL-11:a2MeashoSsbRsrp:a2HysteresishoSsbRsrp=1
...    NRBTS-1/NRCELL-11:a2MeashoSsbRsrp:a2ThresholdhoSsbRsrp=34
...    NRBTS-1/NRCELL-11:a2MeashoSsbRsrp:a2TimeToTriggerhoSsbRsrp=ms480
...    NRBTS-1/NRCELL-11:a5MeasSsbRsrq:a5HysteresisSsbRsrq=0
...    NRBTS-1/NRCELL-11:a5MeasSsbRsrq:a5Threshold1SsbRsrq=75
...    NRBTS-1/NRCELL-11:a5MeasSsbRsrq:a5Threshold2SsbRsrq=85
...    NRBTS-1/NRCELL-11:a5MeasSsbRsrq:a5TimeToTriggerSsbRsrq=ms0
...    NRBTS-1/NRCELL-11:pucchF3MaxCodeRate=zeroDot08
...    NRBTS-1/NRCELL-11:a1MeashoSsbRsrp:a1HysteresishoSsbRsrp=0
...    NRBTS-1/NRCELL-11:a1MeashoSsbRsrp:a1ThresholdhoSsbRsrp=34
...    NRBTS-1/NRCELL-11:a1MeashoSsbRsrp:a1TimeToTriggerhoSsbRsrp=ms480
...    NRBTS-1/NRCELL-11:a2MeasReleaseSsbRsrq:a2HysteresisReleaseSsbRsrq=0
...    NRBTS-1/NRCELL-11:a2MeasReleaseSsbRsrq:a2ThresholdReleaseSsbRsrq=75
...    NRBTS-1/NRCELL-11:a2MeasReleaseSsbRsrq:a2TimeToTriggerReleaseSsbRsrq=ms0
...    NRBTS-1/NRCELL-11:actCDrx=true
...    NRBTS-1/NRCELL-11:a2MeasReleaseSsbRsrp:a2HysteresisReleaseSsbRsrp=0
...    NRBTS-1/NRCELL-11:a2MeasReleaseSsbRsrp:a2ThresholdReleaseSsbRsrp=75
...    NRBTS-1/NRCELL-11:a2MeasReleaseSsbRsrp:a2TimeToTriggerReleaseSsbRsrp=ms0
...    NRBTS-1/NRCELL-11:pucchF3ModulationScheme=pi2bpsk
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
...    NRPMRNL-1:miNrRelReportCu=15min
...    NRBTS-1:actFdmEnhancedScheduling=true
...    NRBTS-1:actFdmScheduling=true
...    NRBTS-1:actLteNrDss=true
...    NRBTS-1:timerXnDataFwdGuard=250
...    NRBTS-1:actIncXn=true
...    NRBTS-1:actInterFreqHoSA=true
...    NRBTS-1:actConflictConfiguration=true
...    NRBTS-1:actMeasBasedSCellAdditionSa=A1-based
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRDU-1:actInterNumerologyCa=true
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:carrierAggregationSupportList=${CA_SUPPORT_LIST}
...    NRCELL-3/NRHOIF-1:a1BasedPCellSwitchEnabled=false
...    NRCELL-3/NRHOIF-1:a2BasedPCellSwitchEnabled=true
...    NRCELL-3/NRHOIF-1:a2BasedPCellSwitchPriority=9
...    NRCELL-3/NRHOIF-1:thresholdPCellSwitchTargetRsrp=60
...    NRCELL-3/NRHOIF-1:thresholdPCellSwitchTargetRsrq=30
...    NRCELL-3/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-3/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-3/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=25
...    NRCELL-3/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL-3/NRHOIF-1:a5MeasEnabled=rsrp
...    NRCELL-3/NRHOIF-1:a5MeasSsbRsrp:a5HysteresisSsbRsrp=10
...    NRCELL-3/NRHOIF-1:a5MeasSsbRsrp:a5Threshold1SsbRsrp=30
...    NRCELL-3/NRHOIF-1:a5MeasSsbRsrp:a5Threshold2SsbRsrp=55
...    NRCELL-3/NRHOIF-1:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms0
...    NRCELL-3/NRHOIF-1:a5MeasSsbRsrq:a5HysteresisSsbRsrq=0
...    NRCELL-3/NRHOIF-1:a5MeasSsbRsrq:a5Threshold1SsbRsrq=12
...    NRCELL-3/NRHOIF-1:a5MeasSsbRsrq:a5Threshold2SsbRsrq=12
...    NRCELL-3/NRHOIF-1:a5MeasSsbRsrq:a5TimeToTriggerSsbRsrq=ms160
...    NRCELL-3/NRHOIF-1:cellDepType=SA
...    NRCELL-3/NRHOIF-1:freqBandIndicatorNR=78
...    NRCELL-3/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-3/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-3/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-3/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-3/NRHOIF-1:scs=30 KHz
...    NRCELL-3/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-3/NRHOIF-1:ssbFrequency=632736
...    NRBTS-1/NRADJNRCELL-1:cellDepType=SA
...    NRBTS-1/NRADJNRCELL-1:gNbId=35
...    NRBTS-1/NRADJNRCELL-1:gNbIdLength=22
...    NRBTS-1/NRADJNRCELL-1:lcrId=1
...    NRBTS-1/NRADJNRCELL-1:nrarfcn=633000
...    NRBTS-1/NRADJNRCELL-1:physCellId=381
...    NRBTS-1/NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRBTS-1/NRADJNRCELL-1:gnbPlmn:mnc=489
...    NRBTS-1/NRADJNRCELL-1:gnbPlmn:mncLength=3
...    NRBTS-1/NRADJNRCELL-1:freqBandIndicatorNR=78
...    NRCELL-3/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-3/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-3/NRREL-10:gNbId=35
...    NRCELL-3/NRREL-10:gNbIdLength=22
...    NRCELL-3/NRREL-10:handoverAllowedSA=allowed
...    NRCELL-3/NRREL-10:lcrId=1
...    NRCELL-3/NRREL-10:removeNotAllowed=false
...    NRCELL-3/NRREL-10:nrDcAllowed=false
...    NRCELL-3/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-3/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-3/NRREL-10:gnbPlmn:mncLength=3
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

@{VALID_SCELL_ADD_AD021}
...    NRCELL-3/NRHOIF-1:a5MeasEnabled=rsrp
...    NRCELL-3:a1MeashoEnabled=rsrp
...    NRCELL-3:a2MeashoEnabled=rsrp


${FDD_SCELL_FOR_NRCELL3}    NRCELL-11
${FDD_SCELL2_FOR_NRCELL3}    NRCELL-12


&{INTER_GNB_CELLS_SSBFREQ}
...     ENB-3.1=632736
...     EXT_ENB-2.3=508110

${SA_Capa_perUE_Full}    SEPARATOR=
...    E9A09000575F5A13160003C1A00B0498B800CE1E82813641873E618F28581C130080C4700FB8D85181AC1184341020
...    E90186D6C98AB1A1CF88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE0005800702A0D883AC
...    1184341020F1018656C98AB121CFB027C471E31238F21CFA8E7CC31E50B0381C3C27F6000001FD8000000B000E0551
...    B137582308682041D2030C2D931544439F11C788E3D033EC09F18E7CC31E50B0381C3C17003FF001C00FFC000B000E
...    0571F11B582308682041F280C2AB64C55850E7C471E300000000000000000000000009FFF000007FFC000002C00380
...    1EF0F1340038820000042C040A83C28000E230000010B02B0F11800388200000C2C0AC3C28000E208000010B02B0F1
...    3400388C0000042C0AC5C46000E208007104000028581587850001C4D00000C160562E2680071040038500000102C0
...    AC5C4D000E23000711800001058158B850001C41000E230000020B02B170A0003882001C41000004160562E2680071
...    0400388C0000082C0AC5C28000E23000711800001058158B89A001C46000E140000040B02B0F11800388C00000C2C0
...    803808D00A2026C041074BB07C28913639F0E14489B1CF870A244D8E7C3851226C73E1C28913639F0E2448913639F0
...    E14081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF811204
...    081B1CF810A040D8E7C00170F18C6318C6318C6318C61E8260078005038280381803A01C0018090010180F82400800
...    000004000008020000000100000200800002004000018020000100100000A008004010040100000C00800007004002
...    00000008000080040000480200000C010000140080000B004002048120080000C0339535953582958195833582B594
...    B5933580B581B58095811583B40D04000025949410000196525040000A594901000039652404000125949010000596
...    524040001A594901000079652404000225949010000996524040002A5949010000B965250400032594901000031652
...    40334AAAE955552A8BA55154162A82C55068AA531549A2A80C55028AA4D5541E28282F012A05028140A05028140A05
...    028140A05028140A0502800304040300601002004202004010080600C20100200404030060100C0182020180300806
...    00C201002004040300601002004402018030080600C0201803040400802010020086A87C0004080C10181C282C3034
...    4044484C5060646C70747C8494989CA0A4A8B4BD05060B40

${UE_PCELL_2_CONF_SCELL_DL_SA}    M55118C07001    #Sum of CA UEs in the current cell configured as a PCell, which have 2 configured SCells in DL
${RRC_RECONF_ADD2DLSCELL_SUCC_SA}    M55118C07003    #Successful RRC Reconfigurations attempts for 2 SCells Addition in DL for SA mode
${RRC_RECONF_ADD2DLSCELL_ATT_SA}    M55118C07004    #RRC Reconfigurations attempts for 2 SCells Addition in DL for SA mode
${UE_SCELL_2_CONF_SCELL_DL_SA}    M55118C07002    #Sum of CA UEs in the current cell configured as a SCell, which have 2 configured SCells in DL



@{PM_COUNTER_AD021}
...     NRCELL-3:${UE_PCELL_2_CONF_SCELL_DL_SA}>0
...     NRCELL-11:${UE_SCELL_2_CONF_SCELL_DL_SA}>0
...     NRCELL-12:${UE_SCELL_2_CONF_SCELL_DL_SA}>0
...     NRCELL-3:${RRC_RECONF_ADD2DLSCELL_SUCC_SA}==2
...     NRCELL-3:${RRC_RECONF_ADD2DLSCELL_ATT_SA}==2


*** Test Cases ***
CB006138-ET-AD021_Verify_SA_A5_rsrp_interfreq_intergNB_HO_from_3CC_TFF_with_scell_blind_to_TDD
    [Documentation]
    ...    The purpose of the case is to test A5 rsrp inter-Freq, IntergNB 2 FDD Scells with both mode HO from CA to TDD
    ...    Step 1: Attach UE to cell3, (cell11&12 shall be selected as SCell candidate)
    ...    Expected Result: attach successfully, SA call setup successfully
    ...    Step 2:trigger A2 for UE
    ...    Expected Result: A5 and A1 event configured for UE, DRX released, MeasGap perUE setup.
    ...    resources for source cell and SCells of source cell in gNB side released. ue context released.
    ...    Step 3:trigger A5 for UE
    ...    Expected Result:receives A5 measurement report from UE, UE HO to T. Measgap released.
    ...    resources for source cell and SCells of source cell in gNB side released. ue context released
    ...    Step 4:HO back
    ...    Expected Result:Ho successful and traffic is ok. scell add as expected.
    ...    Step 5:Detach UE
    ...    Expected Result:Detach UE success .
    ...    check the counter: 'M55118C07001', 'M55118C07002', 'M55118C07003', 'M55118C07004'
    [Tags]    CB006138-AD021    Owner_jejing    QC_133895
    [Timeout]    60 min
    Before_ue_attach_AD021
    UE Attach and L3 Normal Call    ue_id=81    pdu_gw_id=1
    Check Two Scell Added Successfully    NRCELL-3    ${FDD_SCELL_FOR_NRCELL3}    ${FDD_SCELL2_FOR_NRCELL3}
    Verify Throuput on Pscell and Scell    ue_id=81    pdu_gw_id=1
    InterFreq InterGNB A5 HO    ue_id=81    source_cell=EXT_ENB-2.3    target_cell=ENB-3.1    target_phycell_id=381
    Start RRC Log       AD020_InterFreqInterGNB_HO
    InterFreq InterGNB A5 HO    ue_id=81    source_cell=ENB-3.1    target_cell=EXT_ENB-2.3    target_phycell_id=52
    Check Two Scell Added Successfully    NRCELL-3    ${FDD_SCELL_FOR_NRCELL3}    ${FDD_SCELL2_FOR_NRCELL3}
    Verify Throuput on Pscell and Scell    ue_id=81    pdu_gw_id=1
    Check WireShark Log    ${CURDIR}${/}a2a_AD021${/}a2a.ini
    ...    wait_string=UEContextModificationResponse::36
    Check Counters    ${PM_COUNTER_AD021}
    Release Ues    ue_type=all


*** Keywords ***
Modify Cfg
    Update Cfg    gnb_param id=3 send_xn_setup=true xn_listening_socket=on
    Update Cfg    gnb_param id=4 send_xn_setup=true xn_listening_socket=on
    Update Cfg    ue_param id=81 ue_nr_capabilities=${SA_Capa_perUE_Full}
    ${cmd2}    Catenate    set_cell id=1 gnb=3 pci=127:0 tac=200 nrci=0x01 tdd_cell=on
    ...    proxy=$PROXY_SERVER5_IP:9999 nr_arfcn=633000:633000 gscn=7840 mandatory_for_activation=off
    Update Cfg    ${cmd2}
    ${cell_11}    catenate    set_cell id=11 gnb=2 pci=20:0 tac=200 nrci=0x0B tdd_cell=off
    ...    proxy=$PROXY_SERVER_IP:9999|$PROXY_SERVER_IP:8888 nr_arfcn=344000:424000 gscn=5300 mandatory_for_activation=off
    Update Cfg    ${cell_11}
    ${cell_4}    catenate    set_cell id=4 gnb=2 pci=17:2 tac=200 nrci=0x04 tdd_cell=on
    ...    proxy=$PROXY_SERVER_IP:9999|$PROXY_SERVER_IP:8888 nr_arfcn=526020:526020 gscn=6582 mandatory_for_activation=off
    Update Cfg    ${cell_4}


Verify Throuput on Pscell and Scell
    [Arguments]    ${ue_id}    ${pdu_gw_id}
    Sleep    15s
    ${ret0}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-5 type=pdsch    pass_regexp=Average
    Execute Egate Command    ue_disp
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000 > 100
    ${scell1_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=1    type=pdsch    rate_type=ave
    #Should Be True    ${scell1_tput}/1000 > 0
    ${scell2_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=2    type=pdsch    rate_type=ave
    #Should Be True    ${scell2_tput}/1000 > 0
    Should Be True    ${scell0_tput}/1000+${scell1_tput}/1000+${scell2_tput}/1000 > 360
    Verify SA DL and UL Traffic    ${ue_id}    ${pdu_gw_id}

Verify SA DL and UL Traffic
    [Arguments]    ${ue_id}    ${pdu_gw_id}
    builtin.sleep    15s
    ${ul_throuput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_gw_id}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${ul_throuput}/1000>9
    ${dl_throuput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_gw_id}    qfi=1    direction=dl    rate_type=ave
    Should Be True    ${dl_throuput}/1000>100

Before_ue_attach_AD021
    Delta Commission Parameters     ${VALID_SCELL_ADD_AD021}
    ${cmd1}    Catenate    ue_history_information_list_add_ngran id=1 cell_type=large
    ...    nrcgi=311:489|0x01 gnb_id=3 time_ue_stayed_in_cell=97
    ${cmd2}    Catenate    ue_history_information_list_add_ngran id=1 cell_type=large
    ...    nrcgi=311:489|0x01 gnb_id=2 time_ue_stayed_in_cell=98
    Execute Egate Command    gnb_param id=3 xn_listening_socket=1 send_xn_setup=true measEvent=A2 measEvent=A5
    Execute Egate Command    gnb_xn_link_up gnb=3 target=2    pass_regexp=is up
    Execute Egate Command    ${cmd1}
    Execute Egate Command    ${cmd2}
    Execute Egate Command    ue_history_information_list id=1 action=commit
    Execute Egate Command    ue_enb_param id=81 ue_history_list=1
    Execute Egate Command    ue_change_location id=81 enb=2 cell=3
    Clear Counter Files
    Start RRC Log    AD021


Check Two Scell Added Successfully
    [Arguments]    ${pcell}    ${scell1}    ${scell2}
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
    Execute Egate Command    ue_disp
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
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_gw_id} qfi=1 dir=ul mbps=10
    ...    pass_regexp=UE ${ue_id}: UDP UL

InterFreq InterGNB A5 HO
    [Arguments]    ${ue_id}    ${source_cell}    ${target_cell}    ${target_phycell_id}
    Execute Egate Command    ue_disp
     ${source_cell_ssbfreq}    Get From Dictionary    ${INTER_GNB_CELLS_SSBFREQ}    ${source_cell}
    ${a2_meas_id}    Get Nr Meas Id For Specific Type And Frequency    ${ue_id}    ${source_cell_ssbfreq}    A2
    ${a2_cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${a2_meas_id} event=A2 srsrp_nr=5 srsrq_nr=5
    Execute Egate Command    ${a2_cmd}    pass_regexp=rrcReconfiguration
    ${target_cell_ssbfreq}    Get From Dictionary    ${INTER_GNB_CELLS_SSBFREQ}    ${target_cell}
    ${a5_meas_id}    Get Nr Meas Id For Specific Type And Frequency    ${ue_id}    ${target_cell_ssbfreq}    A5
    ${a5_cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${a5_meas_id} event=A5
    ...    srsrp_nr=11 srsrq_nr=11 phycell_id=${target_phycell_id} nrsrp_nr=80 nrsrq_nr=80
    Execute Egate Command    ${a5_cmd}
    ...    pass_regexp=Inter-eNB handover from ${source_cell} to ${target_cell} performed

