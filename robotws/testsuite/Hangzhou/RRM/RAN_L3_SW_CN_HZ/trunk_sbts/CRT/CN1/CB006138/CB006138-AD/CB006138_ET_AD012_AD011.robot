*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    RAN_5G    RAN_5G_TDD    CRT    SBTS00    master_classicalbts_all
...               STATE_CONFIGURED    FR1    CN2    team-SG2    owner-cathy.mao    owner-dandan.chen
...               release-SBTS22R1    PRI-Medium    CB006138-AD    CLOUD_5G_I_BOO_AP_LOO
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
...    NRCELL-1:actVoNR=true
...    NRCELL-2:actVoNR=true
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
...    NRBTS/NRDRB-15:resType=GBR
...    NRBTS/NRDRB-15:cellAggrLevel=Not FR1 CA eligible
...    NRBTS/NRDRB-15:rlcMode=RLC_UM
...    NRBTS/NRDRB-15:schedulWeight=1
...    NRBTS/NRDRB-15:sduDiscardIntervalTmr=100
...    NRBTS/NRDRB-15:maxDataRateGbrDl=1000
...    NRBTS/NRDRB-15:maxDataRateGbrUl=1000
...    NRBTS/NRDRB-15:discardTimer=150ms
...    NRBTS/NRDRB-15:maxRlcQueueingDelayGbr=20
...    NRBTS/NRDRB-15:maxTransferDelayGbr=20
...    NRBTS/NRDRB_MAC-4:lcgid=4
...    NRBTS/NRDRB_MAC-4:schedulPrio=4
...    NRBTS/NRDRB_RLC_UM-1:dlTReassemblyUm=ms40
...    NRBTS/NRDRB_RLC_UM-1:ulTReassemblyUm=ms40
...    NRBTS/NRDRB_PDCP-3:tReorderingDl=ms300
...    NRBTS/NRDRB_PDCP-3:tReorderingUl=ms300
...    NRBTS/NRDRB_PDCP-3:pdcpBufDiscardEnabled=false

@{PARAMS_IN_SCF}
...    @{PARAMS_FOR_5QI1}
...    NRCELL:a1MeasSCellAddEnabled=rsrp
...    NRCELL:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=75
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=95
...    NRCELL:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-2/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-3/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-3/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-4/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-4/NRREL-2:sCellOperationalMode=dlOnly
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRDU-1:actInterNumerologyCa=true
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:carrierAggregationSupportList=${CA_SUPPORT_LIST}
...    NRDU-1:actNonBfAndBfCa=true
...    NRBTS-1:actFdmEnhancedScheduling=true
...    NRBTS-1:actFdmScheduling=true
...    NRBTS-1:actLteNrDss=true
...    NRBTS-1:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS-1:actInterFreqHoSA=true
...    NRBTS-1:actIntraFreqHoSA=false
...    NRCELL:actPrachMultiplexing=true
...    NRCELL:actCDrx=true
...    NRCELL:actK1Opt=intra-gNB
...    NRCELL:pucchModeSelect=longPucch
...    NRCELL:pucchF3ModulationScheme=pi2bpsk
...    NRCELL:pucchF3MaxCodeRate=zeroDot08
...    NRCELL:absThreshSsbRsrqConsolidation=1
...    NRCELL:absThreshSsbRsrpConsolidation=1
...    NRCELL:sMeasConfigSsbRsrp=1
#...    NRBTS-1/NRCELL-1:actBeamforming=true
#...    NRBTS-1/NRCELL-1:nrCellType=4DL2UL
#...    NRBTS-1/NRCELL-1:beamSet:basicBeamSet=beamSet_4
#...    NRBTS-1/NRCELL-1:beamSet:leftEdgeAngle=60
#...    NRBTS-1/NRCELL-1:beamSet:nrBtsBeamRefinementP2=false
#...    NRBTS-1/NRCELL-1:beamSet:rightEdgeAngle=60
...    NRBTS-1/NRCELL-1:absThreshSsbRsrqConsolidation=1
...    NRBTS-1/NRCELL-1:absThreshSsbRsrpConsolidation=1
...    NRBTS-1/NRCELL-1:sMeasConfigSsbRsrp=1
...    NRBTS-1/NRCELL-1:actCDrx=true
...    NRBTS-1/NRCELL-1:pucchF3MaxCodeRate=zeroDot08
...    NRBTS-1/NRCELL-1:actK1Opt=intra-gNB
...    NRBTS-1/NRCELL-1:actPrachMultiplexing=true
...    NRBTS-1/NRCELL-1:pucchF3ModulationScheme=pi2bpsk
...    NRBTS-1/NRCELL-1:pucchModeSelect=longPucch
#...    NRCELLGRP-0:numberOfTransmittedSsBlocks=4 beams
#...    NRBTS-1/NRCELL-4:actBeamforming=true
#...    NRBTS-1/NRCELL-4:nrCellType=4DL2UL
#...    NRBTS-1/NRCELL-4:beamSet:basicBeamSet=beamSet_4
#...    NRBTS-1/NRCELL-4:beamSet:leftEdgeAngle=60
#...    NRBTS-1/NRCELL-4:beamSet:nrBtsBeamRefinementP2=false
#...    NRBTS-1/NRCELL-4:beamSet:rightEdgeAngle=60
...    NRBTS-1/NRCELL-4:actVoNR=true
...    NRBTS-1/NRCELL-4:actCDrx=true
#...    NRBTS-1/NRCELL-4:drxProfile2:drxInactivityTimer=4ms
#...    NRBTS-1/NRCELL-4:drxProfile2:drxLongCycle=40ms
#...    NRBTS-1/NRCELL-4:drxProfile2:drxOnDurationTimer=6ms
#...    NRBTS-1/NRCELL-4:drxProfile2:drxRetransTimerDl=0slot
#...    NRBTS-1/NRCELL-4:drxProfile2:drxRetransTimerUl=0slot
...    NRBTS-1/NRCELL-4:t310VoNR=100ms
...    NRBTS-1/NRCELL-4:n310VoNR=n10
#...    NRBTS-1/NRCELL-4:drxProfile1:drxInactivityTimer=40ms
#...    NRBTS-1/NRCELL-4:drxProfile1:drxLongCycle=80ms
#...    NRBTS-1/NRCELL-4:drxProfile1:drxOnDurationTimer=10ms
#...    NRBTS-1/NRCELL-4:drxProfile1:drxRetransTimerDl=16slot
#...    NRBTS-1/NRCELL-4:drxProfile1:drxRetransTimerUl=16slot
...    NRBTS-1/NRCELL-4:actCDrxVoNR=true
...    NRBTS-1/NRCELL-4:actEnhancedVoNR=true
...    NRBTS-1/NRCELL-4:absThreshSsbRsrqConsolidation=1
...    NRBTS-1/NRCELL-4:absThreshSsbRsrpConsolidation=1
...    NRBTS-1/NRCELL-4:sMeasConfigSsbRsrp=1
...    NRBTS-1/NRCELL-4:pucchF3MaxCodeRate=zeroDot08
...    NRBTS-1/NRCELL-4:actK1Opt=intra-gNB
...    NRBTS-1/NRCELL-4:actPrachMultiplexing=true
...    NRBTS-1/NRCELL-4:pucchF3ModulationScheme=pi2bpsk
...    NRBTS-1/NRCELL-4:pucchModeSelect=longPucch
#...    NRCELLGRP-3:numberOfTransmittedSsBlocks=4 beams
...    NRBTS-1/NRCELL-11:pMax=380
...    NRBTS-1/NRCELL-11:periodicCsiAcquisition:csiReportPeriodicity=slots160
...    NRBTS-1/NRCELL-11:absThreshSsbRsrqConsolidation=1
...    NRBTS-1/NRCELL-11:absThreshSsbRsrpConsolidation=1
...    NRBTS-1/NRCELL-11:sMeasConfigSsbRsrp=1
...    NRBTS-1/NRCELL-11:actCDrx=true
...    NRBTS-1/NRCELL-11:pucchF3MaxCodeRate=zeroDot08
...    NRBTS-1/NRCELL-11:actK1Opt=intra-gNB
...    NRBTS-1/NRCELL-11:actPrachMultiplexing=true
...    NRBTS-1/NRCELL-11:pucchF3ModulationScheme=pi2bpsk
...    NRBTS-1/NRCELL-11:pucchModeSelect=longPucch
...    NRCELL-3:actVoNR=true
...    NRCELL-3:actCDrxVoNR=true
...    NRCELL-3:actEnhancedVoNR=true
...    NRCELL-3:actCDrx=true
...    NRCELL-3:n310VoNR=n10
...    NRCELL-3:t310VoNR=100ms
#...    NRCELL-3:drxProfile1:drxInactivityTimer=40ms
#...    NRCELL-3:drxProfile1:drxLongCycle=80ms
#...    NRCELL-3:drxProfile1:drxOnDurationTimer=10ms
#...    NRCELL-3:drxProfile1:drxRetransTimerDl=16slot
#...    NRCELL-3:drxProfile1:drxRetransTimerUl=16slot
#...    NRCELL-3:drxProfile2:drxInactivityTimer=4ms
#...    NRCELL-3:drxProfile2:drxLongCycle=40ms
#...    NRCELL-3:drxProfile2:drxOnDurationTimer=6ms
#...    NRCELL-3:drxProfile2:drxRetransTimerDl=0slot
#...    NRCELL-3:drxProfile2:drxRetransTimerUl=0slot
...    NRCELL-3:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=25
...    NRCELL-3:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0
...    NRCELL-3:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms0
...    NRCELL-3:a1MeashoEnabledSA=rsrp
...    NRCELL-3:gapOffset=8
...    NRCELL-3:a3MeasEnabled=rsrp
...    NRCELL-3:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=40
...    NRCELL-3:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRCELL-3:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms0
...    NRCELL-3:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-3:a3MeasSsbRsrp:a3OffsetSsbRsrp=25
...    NRCELL-3:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL-3:a2MeashoEnabledSA=rsrp
...    NRCELL-3:ifhoSsbSmtcOffset=9
...    NRCELL-3:absThreshSsbRsrqConsolidation=1
...    NRCELL-3:absThreshSsbRsrpConsolidation=1
...    NRCELL-3:sMeasConfigSsbRsrp=1
...    NRCELL-3:pucchF3MaxCodeRate=zeroDot08
...    NRCELL-3:actK1Opt=intra-gNB
...    NRCELL-3:actPrachMultiplexing=true
...    NRCELL-3:pucchF3ModulationScheme=pi2bpsk
...    NRCELL-3:pucchModeSelect=longPucch
...    NRCELL-4:actVoNR=true
...    NRCELL-4:actCDrxVoNR=true
...    NRCELL-4:actEnhancedVoNR=true
...    NRCELL-4:actCDrx=true
...    NRCELL-4:n310VoNR=n10
...    NRCELL-4:t310VoNR=100ms
#...    NRCELL-4:drxProfile1:drxInactivityTimer=40ms
#...    NRCELL-4:drxProfile1:drxLongCycle=80ms
#...    NRCELL-4:drxProfile1:drxOnDurationTimer=10ms
#...    NRCELL-4:drxProfile1:drxRetransTimerDl=16slot
#...    NRCELL-4:drxProfile1:drxRetransTimerUl=16slot
#...    NRCELL-4:drxProfile2:drxInactivityTimer=4ms
#...    NRCELL-4:drxProfile2:drxLongCycle=40ms
#...    NRCELL-4:drxProfile2:drxOnDurationTimer=6ms
#...    NRCELL-4:drxProfile2:drxRetransTimerDl=0slot
#...    NRCELL-4:drxProfile2:drxRetransTimerUl=0slot
...    NRCELL-4:absThreshSsbRsrqConsolidation=1
...    NRCELL-4:absThreshSsbRsrpConsolidation=1
...    NRCELL-4:sMeasConfigSsbRsrp=1
...    NRCELL-4:pucchF3MaxCodeRate=zeroDot08
...    NRCELL-4:actK1Opt=intra-gNB
...    NRCELL-4:actPrachMultiplexing=true
...    NRCELL-4:pucchF3ModulationScheme=pi2bpsk
...    NRCELL-4:pucchModeSelect=longPucch
...    NRCELL-4/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-4/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-4/NRREL-1:gNbId=1
...    NRCELL-4/NRREL-1:gNbIdLength=22
...    NRCELL-4/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-4/NRREL-1:lcrId=2
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
...    NRCELL-3/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-3/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-3/NRREL-1:gNbId=1
...    NRCELL-3/NRREL-1:gNbIdLength=22
...    NRCELL-3/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-3/NRREL-1:lcrId=11
...    NRCELL-3/NRREL-1:removeNotAllowed=false
...    NRCELL-3/NRREL-1:sCellAdditionMethod=covBasedA1
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
...    NRCELL-3/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-3/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-3/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-3/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-3/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-3/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-3/NRREL-10:gNbId=1
...    NRCELL-3/NRREL-10:gNbIdLength=22
...    NRCELL-3/NRREL-10:lcrId=2
...    NRCELL-3/NRREL-10:removeNotAllowed=false
...    NRCELL-3/NRREL-10:handoverAllowedSA=allowed
...    NRCELL-3/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-3/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-3/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-12:periodicCsiAcquisition:csiReportPeriodicity=slots160
...    NRCELL-12:absThreshSsbRsrqConsolidation=1
...    NRCELL-12:absThreshSsbRsrpConsolidation=1
...    NRCELL-12:sMeasConfigSsbRsrp=1
...    NRCELL-12:actCDrx=true
...    NRCELL-12:pucchF3MaxCodeRate=zeroDot08
...    NRCELL-12:actK1Opt=intra-gNB
...    NRCELL-12:actPrachMultiplexing=true
...    NRCELL-12:pucchF3ModulationScheme=pi2bpsk
...    NRCELL-12:pucchModeSelect=longPucch
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-1:gNbId=1
...    NRCELL-2/NRREL-1:gNbIdLength=22
...    NRCELL-2/NRREL-1:lcrId=3
...    NRCELL-2/NRREL-1:removeNotAllowed=false
...    NRCELL-2/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-2/NRHOIF-1:a1BasedPCellSwitchEnabled=false
...    NRCELL-2/NRHOIF-1:a2BasedPCellSwitchEnabled=false
...    NRCELL-2/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-2/NRHOIF-1:a5MeasEnabled=none
...    NRCELL-2/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-2/NRHOIF-1:freqBandIndicatorNR=41
...    NRCELL-2/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-2/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-2/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-2/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-2/NRHOIF-1:ssBurstSetPeriod=10
...    NRCELL-2/NRHOIF-1:ssbFrequency=508110
...    NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=25
...    NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms160
...    NRCELL-2:a1MeashoEnabledSA=rsrp
...    NRCELL-2:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=40
...    NRCELL-2:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRCELL-2:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms0
...    NRCELL-2:a2MeashoEnabledSA=rsrp
...    NRCELL-2:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=25
...    NRCELL-2:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0
...    NRCELL-2:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms0
...    NRCELL-2:measGapSelection=favourUeThroughput
...    NRCELL-2:measGapSelectionSA=favourUeThroughput
...    NRCELL-2:gapOffset=8
...    NRCELL-2:ifhoSsbSmtcOffset=9
...    NRCELL-2:absThreshSsbRsrqConsolidation=1
...    NRCELL-2:absThreshSsbRsrpConsolidation=1
...    NRCELL-2:sMeasConfigSsbRsrp=1
...    NRCELL-2:actCDrx=true
...    NRCELL-2:pucchF3MaxCodeRate=zeroDot08
...    NRCELL-2:actK1Opt=intra-gNB
...    NRCELL-2:actPrachMultiplexing=true
...    NRCELL-2:pucchF3ModulationScheme=pi2bpsk
...    NRCELL-2:pucchModeSelect=longPucch
...    NRCELL-11:periodicCsiAcquisition:csiReportPeriodicity=slots160
...    NRCELL-11:absThreshSsbRsrqConsolidation=1
...    NRCELL-11:absThreshSsbRsrpConsolidation=1
...    NRCELL-11:sMeasConfigSsbRsrp=1
...    NRCELL-11:actCDrx=true
...    NRCELL-11:pucchF3MaxCodeRate=zeroDot08
...    NRCELL-11:actK1Opt=intra-gNB
...    NRCELL-11:actPrachMultiplexing=true
...    NRCELL-11:pucchF3ModulationScheme=pi2bpsk
...    NRCELL-11:pucchModeSelect=longPucch
...    NRCELL-3/NRHOIF-1:a1BasedPCellSwitchEnabled=false
...    NRCELL-3/NRHOIF-1:a2BasedPCellSwitchEnabled=false
...    NRCELL-3/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-3/NRHOIF-1:a5MeasEnabled=none
...    NRCELL-3/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-3/NRHOIF-1:freqBandIndicatorNR=78
...    NRCELL-3/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-3/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-3/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-3/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-3/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-3/NRHOIF-1:ssbFrequency=648096
...    NRCELL-3/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-3/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=20
...    NRCELL-3/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms160
...    NRCELL-2/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-2:gNbId=1
...    NRCELL-2/NRREL-2:gNbIdLength=22
...    NRCELL-2/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-2:lcrId=1
...    NRCELL-2/NRREL-2:removeNotAllowed=false
...    NRCELL-2/NRREL-2:sCellAdditionMethod=blind
...    NRCELL-2/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-2:gnbPlmn:mncLength=3
...    @{Change_Golden_Band}
#...    @{PARAMS_IN_BOO_4T2F_8PIPES}
...    @{beamforming_enable}


@{Change_Golden_Band}
...    NRCELL-11:freqBandIndicatorNR=66
...    NRCELL-11:gscnOrSsPbchArfcn=5300
...    NRCELL-11/NRCELL_FDD-1:chBwDl=20MHz
...    NRCELL-11/NRCELL_FDD-1:chBwUl=20MHz
...    NRCELL-11/NRCELL_FDD-1:nrarfcnDl=424000
...    NRCELL-11/NRCELL_FDD-1:nrarfcnUl=344000


${CA_SUPPORT_LIST}    ca_Fr1Tdd_Any_Sa,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Fr1Tdd_Nsa,ca_Fdd_Fdd,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Nsa,ca_Fr1Tdd_Fdd_Sa
${UE2_NON_CA_SA_Capa_perFR}    SEPARATOR=
...    E1A01000074E5A031E000380A03C1260C80008780818806804C020301C032A36146B04050D012CB2898087AD8202020E1DE38720
...    C38002064F1F570004F001C0013C002A36266B04050D012CB2898087AD8202020E1DE38720C38002064F1F570004F001C0013C00
...    2A3626EB04050D012CB2898087AD8202020E1DE38720C38002064F1F570004F001C0013C002A36276B04050D012CB2898087AD82
...    02020E1DE38720C38002064F1F55000005000000208389A00000000E1400000000301360140082C0402201187FAAAAA80E030003
...    81C04070300380E000D07C0000000000001CA9A0002000012CB2A00695550103800580000002004008D589800081018202830384
...    05880889098C90929313942530D680
${UE82_CA_SA_Capa_perFR_Full}    SEPARATOR=
...    E9A09000575F5A13160003C1A00B0498B800CE1E82813641873E618F28581C130080C4700FB8D85181AC1184341020E90186D6C9
...    8AB1A1CF88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE0005800702A0D883AC1184341020F1018656C9
...    8AB121CFB027C471E31238F21CFA8E7CC31E50B0381C3C27F6000001FD8000000B000E0551B137582308682041D2030C2D931544
...    439F11C788E3D033EC09F18E7CC31E50B0381C3C17003FF001C00FFC000B000E0571F11B582308682041F280C2AB64C55850E7C4
...    71E300000000000000000000007809FC0000007F00000002C0038024F0F1340038820000042C040A83C28000E230000010B02B0F
...    11800388200000C2C0AC3C28000E208000010B02B0F13400388C0000042C0AC5C46000E208007104000028581587850001C4D000
...    00C160562E2680071040038500000102C0AC5C4D000E23000711800001058158B850001C41000E230000020B02B170A000388200
...    1C41000004160562E26800710400388C0000082C0AC5C28000E23000711800001058158B89A001C46000E140000040B02B0F1180
...    0388C00000C2C0AC3C28000E140000060B02B170A000388C001C28000008160561E268007134000030581007011A014404D80820
...    E9BE12851226C73E1C28913639F0E14489B1CF870A244D8E7C3851226C73E1C4891226C73E1C28103639F022408103639F022408
...    103639F022408103639F022408103639F022408103639F022408103639F022408103639F0214081B1CF810A040D8E7C08902040D
...    8E7C0850206C73E0003624318C6318C6318C6318C63183D04C00F000E07050070300740380030120020301F04801000000008000
...    010040000000200000401000004008000030040000200200001401000802008020000180100000E0080040000001000010008000
...    09004000018020000280100001600800409024010000180672A6B2A6B052B032B066B056B296B266B016B036B012B022B07681A0
...    800004B29282000032CA4A0800014B29202000072CA480800024B292020000B2CA480800034B292020000F2CA480800044B29202
...    000132CA480800054B29202000172CA4A0800064B29202000062CA480669555D2AAAA55174AA2A82C55058AA0D154A62A9345501
...    8AA051549AAA83C50505E02540A05028140A05028140A05028140A05028140A05000608080600C02004008404008020100C01840
...    2004008080600C02018030404030060100C018402004008080600C02004008804030060100C018040300608080100402004010D5
...    0F8000810182030385058606880889098A0C0C8D8E0E8F909293139414951697A0A0C168

${UE82_Capability_AD011}    SEPARATOR=
...    E9A09000575F5A13160003C1A00B0498B800CE1E82813641873E618F28581C130080C4700FB8D85181AC1184341020E90186D6C98
...    AB1A1CF88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE0005800702A0D883AC1184341020F1018656C98A
...    B121CFB027C471E31238F21CFA8E7CC31E50B0381C3C27F6000001FD8000000B000E0551B137582308682041D2030C2D931544439
...    F11C788E3D033EC09F18E7CC31E50B0381C3C17003FF001C00FFC000B000E0541B11B582308682041E2030CAD931562439F11C7B0
...    27C62471E439F51CF9863CA1607038784FFF800003FFE0000016001C00F78789A001C4100000216020541E1400071180000085815
...    8788C001C41000006160561E14000710400000858158789A001C46000002160562E2300071040038820000142C0AC3C28000E2680
...    00060B02B17134003882001C28000008160562E26800711800388C0000082C0AC5C28000E20800711800001058158B850001C4100
...    0E208000020B02B17134003882001C46000004160562E14000711800388C0000082C0AC5C4D000E2300070A000002058158788C00
...    1C46000006160401C0468051013602083A5D83E14489B1CF870A244D8E7C3851226C73E1C28913639F0E14489B1CF871224489B1C
...    F870A040D8E7C08902040D8E7C08902040D8E7C08902040D8E7C08902040D8E7C08902040D8E7C08902040D8E7C08902040D8E7C0
...    850206C73E000B878C6318C6318C6318C630F413003C00281C1401C0C01D00E000C0480080C07C120040000000200000401000000
...    008000010040000100200000C01000008008000050040020080200800006004000038020010000000400004002000024010000060
...    080000A004000058020010240900400006019CA9ACA9AC14AC0CAC19AC15ACA5AC99AC05AC0DAC04AC08AC1DA0682000012CA4A08
...    0000CB29282000052CA48080001CB29202000092CA48080002CB292020000D2CA48080003CB29202000112CA48080004CB2920200
...    0152CA48080005CB29282000192CA480800018B292019A55574AAAA9545D2A8AA0B154162A83455298AA4D154062A8145526AAA0F
...    1414178095028140A05028140A05028140A05028140A0502814001820201803008010021010020080403006100801002020180300
...    80600C10100C018040300610080100202018030080100220100C01804030060100C01820200401008010043543E00020406080C0E
...    1416181A2022242628303236383A3E424A4C4E5052545A5E828305A
${UE2_Capability_AD011}    SEPARATOR=
...    E9A09000575F5A13160003C2A002C1262E003387A0E026C830E7CC31E50B03826010188E01F71B0A303582308682041D207036B64
...    C558D0E7C471E819F604F8C48E3C873EA39F30C7942C0E070F05C00FFC0070005F0003C000E0541B107582308682041E207032B64
...    C55890E7D813E238F1891C790E7D473E618F28581C0E1E13FB000000FEC00000078001C0AA3626EB04610D04083A40E0616C98AA2
...    21CF88E3C471E819F604F8C73E618F28581C0E1E0B801FF800E007FE00078001C0A836236B04610D04083C40E0656C98AB121CF88
...    E3D813E31238F21CFA8E7CC31E50B0381C3C24F013C00F0003800830713400000822070A000000823071180000002307104000000
...    200E0234028809B01042D02B024089B1CF810226C73E04089B1CF810226C73E000090418C631E8260078005038280381804A00E00
...    0C0480080C07C120040000000200000401000000008000010040000100200000C0100000800800005004002008020080000600400
...    0038020010000000400004002000024010000060080000A004000058020010240900400006019CA9ACA9AC14AC0CAC19AC15ACA5A
...    C99AC05AC0DAC04AC08AC1DA0682000012CA4A080000CB29282000052CA48080001CB29202000092CA48080002CB292020000D2CA
...    48080003CB29202000112CA48080004CB29202000152CA48080005CB29282000192CA480800018B292019A55574AAAA9545D2A8AA
...    0B154162A83455298AA4D154062A8145526AAA0F142405E02540A05028140A05028140A05028140A05028140A05000100080600C0
...    010020046A87C0004080C10181C282C30344044484C5060646C70747C8494989CA0A4A8B4BD05060B40

${TDD_SCELL1_FOR_NRCELL2}    NRCELL-1
${FDD_SCELL1_FOR_NRCELL3}    NRCELL-11
${FDD_SCELL2_FOR_NRCELL3}    NRCELL-12

@{VALID_SCELL_ADD_AD012}
...    NRCELL-2:actCDrx=false

@{origin_params_AD012}
...    NRCELL-2:actCDrx=true

@{VALID_SCELL_ADD_AD011}
...    NRCELL-3:actAperCsi=false
...    NRCELL-3:a1MeashoEnabledSA=rsrp
...    NRCELL-3:a2MeashoEnabledSA=rsrp
...    NRCELL-3:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRCELL-3:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=40
...    NRCELL-3:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms0
...    NRCELL-3:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=1
...    NRCELL-3:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=34
...    NRCELL-3:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms0
...    NRCELL-12:actCDrx=false
...    NRCELL-12:a1MeashoEnabledSA=rsrp
...    NRCELL-12:a2MeashoEnabledSA=rsrp
...    NRCELL-12:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRCELL-12:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=40
...    NRCELL-12:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms0
...    NRCELL-12:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=1
...    NRCELL-12:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=34
...    NRCELL-12:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms0
...    NRCELL-3/NRHOIF-1:cellDepType=SA
...    NRCELL-3/NRHOIF-1:freqBandIndicatorNR=71
...    NRCELL-3/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-3/NRHOIF-1:ssbFrequency=126750
...    NRCELL-12/NRHOIF-1:cellDepType=SA
...    NRCELL-12/NRHOIF-1:freqBandIndicatorNR=41
...    NRCELL-12/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-12/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-12/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-12/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-12/NRHOIF-1:scs=30 KHz
...    NRCELL-12/NRHOIF-1:ssBurstSetPeriod=10
...    NRCELL-12/NRHOIF-1:ssbFrequency=508110
...    NRCELL-12/NRHOIF-1:a5MeasEnabled=none
...    NRCELL-12/NRHOIF-1:a1BasedPCellSwitchEnabled=false
...    NRCELL-12/NRHOIF-1:a2BasedPCellSwitchEnabled=false
...    NRCELL-12/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-12/NRHOIF-1:a4MeasEnDcSteeringEnabled=none
...    NRCELL-12/NRHOIF-1:a4MeasHigherPrioFreqEnabled=none
...    NRCELL-12/NRHOIF-1:a4MeasNrDcEnabled=none
...    NRCELL-12/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRCELL-12/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL-12/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL-12/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-10:gNbId=1
...    NRCELL-12/NRREL-10:gNbIdLength=22
...    NRCELL-12/NRREL-10:handoverAllowedSA=allowed
...    NRCELL-12/NRREL-10:lcrId=3
...    NRCELL-12/NRREL-10:removeNotAllowed=false
...    NRCELL-12/NRREL-10:nrDcAllowed=false
...    NRCELL-12/NRREL-10:sCellAdditionMethod=blind
...    NRCELL-12/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-10:sCellOperationalMode=dlOnly
...    NRCELL-3/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-3/NRREL-2:sCellAdditionMethod=blind

@{origin_params_AD011}
...    NRCELL-3:a1MeashoEnabledSA=none
...    NRCELL-3:a2MeashoEnabledSA=none
...    NRCELL-12:actCDrx=true
...    NRCELL-12:a1MeashoEnabledSA=none
...    NRCELL-12:a2MeashoEnabledSA=none
...    NRCELL-3/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-3/NRREL-2:sCellAdditionMethod=covBasedA1


&{CELLS_SSBFREQ}
...     1=632736
...     2=648096
...     3=508110
...     4=526590
...     11=424090
...     12=126750


*** Test Cases ***
CB006138-ET-AD012_Verify_SA_A3_rsrp_interfreq_intragNB_HO_from_3CC_TFF_with_scell_covBasedA1_and_non_CA_UE_in_TDD_to_2CC_TT_perFR
    [Documentation]
    ...    1. The purpose of this test case is to verify interfreq HO with measurement gap configuration for CA UE
    ...       and compared with non-CA UE
    ...    2. Test Case Steps:
    ...         step1. attach CA capability UE82 and non-CA capability UE2,Pcell's PCI is 52(cell3), band 41
    ...         step2. Scell added based covbasedA1 for UE82 (scell 11 and scell 12)
    ...         step3. UE82 HO from Cell3(TFF) to Cell2(TT ,SCELL is cell1) , UE2 HO from cell3 to cell2 (band 78)
    ...         step4. UE82 and UE2 HO from cell2 back to cell3
    ...         step5. trigger A1 report to add scell for CA UE82
    ...    3. Expected Results:
    ...         step1. UE82 and UE2 attach success
    ...         step2. CA UE82 added FDD Scell11 and Scell12 based covbasedA1
    ...         step3. UE82 and UE2 HO from Cell3 to Cell2 success , UE82 blind add TDD SCell1
    ...         step4. UE82 and UE2 HO back from cell2 to cell3 success
    ...         step5. CA UE82 added FDD Scell11 and Scell12 based covbasedA1
    [Tags]    test    CB006138-AD012    Owner_chunjian.yang    QC_133900
    Before_ue_attach_AD012
    UE Attach and L3 Call    ue_id=82    pdu_gw_id=1
    UE Attach and L3 Call NonCA    ue_id=2    pdu_gw_id=2
    Trigger Scell Addition by A1 for TFF CA    ue_id=82    pdu_gw_id=1    pcell_id=3
    ...    scell1=${FDD_SCELL1_FOR_NRCELL3}    scell2=${FDD_SCELL2_FOR_NRCELL3}
    Verify SA DL and UL Traffic NonCA    ue_id=2    pdu_gw_id=2
    InterFreq A3 HO With A2    ue_id=82    source_cell=3    target_cell=2    target_phycell_id=51
    InterFreq A3 HO With A2    ue_id=2    source_cell=3    target_cell=2    target_phycell_id=51
    Check TDD Scell Blind Added    pcell=NRCELL-2    scell1=${TDD_SCELL1_FOR_NRCELL2}
    Verify Throuput on Pscell and Scell With CA_TT    ue_id=82    pdu_gw_id=1
    Verify SA DL and UL Traffic NonCA    ue_id=2    pdu_gw_id=2
    InterFreq A3 HO With A2    ue_id=82    source_cell=2    target_cell=3    target_phycell_id=52
    InterFreq A3 HO With A2    ue_id=2    source_cell=2    target_cell=3    target_phycell_id=52
    Trigger Scell Addition by A1 for TFF CA    ue_id=82    pdu_gw_id=1    pcell_id=3
    ...    scell1=${FDD_SCELL1_FOR_NRCELL3}    scell2=${FDD_SCELL2_FOR_NRCELL3}
    Verify SA DL and UL Traffic NonCA    ue_id=2    pdu_gw_id=2
    Check WireShark Log    ${CURDIR}${/}a2a_AD012${/}a2a.ini
    ...    wait_string=UEContextModificationResponse::43
    Release Ues    ue_type=all
    [Teardown]    Recover Param and Common Test Teardown    ${origin_params_AD012}


CB006138-ET-AD011_Verify_SA_A3_rsrp_interfreq_intragNB_HO_from_3CC_TFF_with_scell_blind_and_non_CA_UE_in_TDD_to_2CC_FT_perUE
    [Documentation]    This case will test A3 rsrp inter-Freq, IntragNB HO from CA/TFF to FT and non CA/TDD to FDD with
    ...    perUE measurement gap, DRX open.
    [Tags]    CB006138-AD011    owner_zhoulingyan    QC_141941
    ...    Case steps:
    ...    1.UE-82 support CA(T+F+F) and UE-2 not support CA
    ...    2.both of UE-82 and UE-2 attached. CA Setup successfully for UE-82
    ...    3.Trigger A2 measurement report for the both UE
    ...    4.Trigger A3 measurement report to trigger HO from CA (T+F+F) to (F+T) for the both UE
    ...    5.Trigger A2/A3 to handover from FDD to CA(T+F+F) for the both UE, check traffic
    Before_ue_attach_AD011
    UE Attach and L3 Call    ue_id=82    pdu_gw_id=3
    UE Attach and L3 Call NonCA    ue_id=2    pdu_gw_id=4
    Check Blind Scell Addition for TFF CA    ue_id=82    pdu_gw_id=3    pcell_id=3
    ...    scell1=${FDD_SCELL1_FOR_NRCELL3}    scell2=${FDD_SCELL2_FOR_NRCELL3}
    Verify SA DL and UL Traffic NonCA    ue_id=2    pdu_gw_id=4
    InterFreq A3 HO With A2    ue_id=82    source_cell=3    target_cell=12    target_phycell_id=61
    InterFreq A3 HO With A2    ue_id=2    source_cell=3    target_cell=12    target_phycell_id=61
    Verify Throuput on Pscell and Scell With CA_FT    ue_id=82    pdu_gw_id=3
    Verify SA DL and UL Traffic Exist    ue_id=2    pdu_gw_id=4
    InterFreq A3 HO With A2    ue_id=82    source_cell=12    target_cell=3    target_phycell_id=52
    InterFreq A3 HO With A2    ue_id=2    source_cell=12    target_cell=3    target_phycell_id=52
    Check Blind Scell Addition for TFF CA    ue_id=82    pdu_gw_id=3    pcell_id=3
    ...    scell1=${FDD_SCELL1_FOR_NRCELL3}    scell2=${FDD_SCELL2_FOR_NRCELL3}
    Verify SA DL and UL Traffic NonCA    ue_id=2    pdu_gw_id=4
    Check WireShark Log    ${CURDIR}${/}a2a_AD011${/}a2a.ini
    ...    wait_string=UEContextModificationResponse::43
    Release Ues    ue_type=all
    [Teardown]    Recover Param and Common Test Teardown    ${origin_params_AD011}


*** Keywords ***
Modify Cfg
    Delete Cfg    set_qosflow id=1 5qi=6 default=on
    Update Cfg    set_qosflow id=1 5qi=5 default=on
    Update Cfg    set_qosflow id=2 5qi=1
    Update Cfg    set_qosflow id=3 5qi=2
    Update Cfg    set_qosrule id=1 proto=tcp qos_flow=1
    Update Cfg    set_qosrule id=2 proto=udp qos_flow=2
    Update Cfg    set_qosrule id=3 proto=udp qos_flow=3
    Update Cfg    set_nwslice id=1 qos_flows=1,2,3 qos_rules=1,2 snssai=0x01:0xD143A5 default=on ue=all amf=1
    Update Cfg    ue_param id=82 ue_nr_capabilities=${UE82_CA_SA_Capa_perFR_Full}
    Update Cfg    ue_param id=2 ue_nr_capabilities=${UE2_NON_CA_SA_Capa_perFR}
    ${cell_11}    catenate    set_cell id=11 gnb=2 pci=20:0 tac=200 nrci=0x0B tdd_cell=off
    ...    proxy=$PROXY_SERVER_IP:9999|$PROXY_SERVER_IP:8888 nr_arfcn=344000:424000 gscn=5300 mandatory_for_activation=off
    Update Cfg    ${cell_11}

Verify Throuput on Pscell and Scell With CA_TFF
    [Arguments]    ${ue_id}    ${pdu_gw_id}
    Sleep    15s
    ${ret0}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-5 type=pdsch    pass_regexp=Average
    Execute Egate Command    ue_disp
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000 > 100
    ${scell1_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=1    type=pdsch    rate_type=ave
    Should Be True    ${scell1_tput}/1000 > 0
    ${scell2_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=2    type=pdsch    rate_type=ave
    Should Be True    ${scell2_tput}/1000 > 0
    Should Be True    ${scell0_tput}/1000+${scell1_tput}/1000+${scell2_tput}/1000 > 540
    Verify SA DL and UL Traffic    ${ue_id}    ${pdu_gw_id}

Verify Throuput on Pscell and Scell With CA_TT
    [Arguments]    ${ue_id}    ${pdu_gw_id}
    Sleep    15s
    ${ret0}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-5 type=pdsch    pass_regexp=Average
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000 > 100
    ${scell1_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=1    type=pdsch    rate_type=ave
   #Should Be True    ${scell1_tput}/1000 > 0
	Should Be True    ${scell0_tput}/1000+${scell1_tput}/1000 > 540
    Verify SA DL and UL Traffic    ${ue_id}    ${pdu_gw_id}

Verify Throuput on Pscell and Scell With CA_FT
    [Arguments]    ${ue_id}    ${pdu_gw_id}
    Sleep    15s
    ${ret0}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-5 type=pdsch    pass_regexp=Average
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000 > 10
    ${scell1_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=1    type=pdsch    rate_type=ave
    Should Be True    ${scell1_tput}/1000 > 0
    Should Be True    ${scell0_tput}/1000+${scell1_tput}/1000 > 540
    Verify SA DL and UL Traffic    ${ue_id}    ${pdu_gw_id}

Verify SA DL and UL Traffic
    [Arguments]    ${ue_id}    ${pdu_gw_id}
    Sleep    15s
    ${ul_throuput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_gw_id}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${ul_throuput}/1000>9
    ${dl_throuput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_gw_id}    qfi=1    direction=dl    rate_type=ave
    Should Be True    ${dl_throuput}/1000>300

Verify SA DL and UL Traffic NonCA
    [Arguments]    ${ue_id}    ${pdu_gw_id}
    Sleep    15s
    ${ul_throuput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_gw_id}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${ul_throuput}/1000>9
    ${dl_throuput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_gw_id}    qfi=1    direction=dl    rate_type=ave
    Should Be True    ${dl_throuput}/1000>90


Verify SA DL and UL Traffic Exist
    [Arguments]    ${ue_id}    ${pdu_gw_id}
    Sleep    15s
    ${ul_throuput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_gw_id}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${ul_throuput}/1000>9
    ${dl_throuput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_gw_id}    qfi=1    direction=dl    rate_type=ave
    Should Be True    ${dl_throuput}/1000>10

Before_ue_attach_AD012
    Delta Commission Parameters     ${VALID_SCELL_ADD_AD012}
    Execute Egate Command    ue_change_location id=82 enb=2 cell=3
    Execute Egate Command    ue_change_location id=2 enb=2 cell=3
    Clear Counter Files
    Start RRC Log    AD012

Before_ue_attach_AD011
    Delta Commission Parameters     ${VALID_SCELL_ADD_AD011}
    Execute Egate Command    ue_param id=82 ue_nr_capabilities=${UE82_Capability_AD011}
    Execute Egate Command    ue_param id=2 ue_nr_capabilities=${UE2_Capability_AD011}
    Execute Egate Command    ue_change_location id=82 enb=2 cell=3
    Execute Egate Command    ue_change_location id=2 enb=2 cell=3
    Clear Counter Files
    Start RRC Log    AD011

UE Attach and L3 Call
    [Arguments]    ${ue_id}    ${pdu_gw_id}
    Execute Egate Command    qosflow_modify qos_flow=1 default=on
    Execute Egate Command    ue_register id=${ue_id}     pass_regexp=Received REGISTRATION COMPLETE
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_gw_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup pdu=${pdu_gw_id} ue=${ue_id} nwslice=1 gw=${pdu_gw_id}
    ...                      pass_regexp=Initial Context Setup Successful
    Execute Egate Command    qosflow_disp
    Start Traffic    ${ue_id}    ${pdu_gw_id}


UE Attach and L3 Call NonCA
    [Arguments]    ${ue_id}    ${pdu_gw_id}
    Execute Egate Command    qosflow_modify qos_flow=1 default=on
    Execute Egate Command    ue_register id=${ue_id}     pass_regexp=Received REGISTRATION COMPLETE
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_gw_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup pdu=${pdu_gw_id} ue=${ue_id} nwslice=1 gw=${pdu_gw_id}
    ...                      pass_regexp=Initial Context Setup Successful
    Execute Egate Command    qosflow_disp
    Start Traffic NonCA     ${ue_id}    ${pdu_gw_id}


Check Two Scell Added Successfully
    [Arguments]    ${pcell}    ${scell1}    ${scell2}
    ${NRREL1_sCellAdditionMethod}    Get Scf Parameter Value    MRBTS-1/NRBTS-1/${pcell}/NRREL-1:sCellAdditionMethod
    ${NRREL2_sCellAdditionMethod}    Get Scf Parameter Value    MRBTS-1/NRBTS-1/${pcell}/NRREL-2:sCellAdditionMethod
    ${SCELL1_physCellId}    Get Scf Parameter Value    ${scell1}:physCellId
    ${SCELL2_physCellId}    Get Scf Parameter Value    ${scell2}:physCellId
    Rrc Should Contain    sCellToAddModList    physCellId ${SCELL1_physCellId}    physCellId ${SCELL2_physCellId}

Check TDD Scell Blind Added
    [Arguments]    ${pcell}    ${scell1}
    ${NRREL1_sCellAdditionMethod}    Get Scf Parameter Value    MRBTS-1/NRBTS-1/${pcell}/NRREL-2:sCellAdditionMethod
    ${SCELL1_physCellId}    Get Scf Parameter Value    ${scell1}:physCellId
    Rrc Should Contain    sCellToAddModList    physCellId ${SCELL1_physCellId}

Trigger Scell Addition by A1 for TFF CA
    [Arguments]    ${ue_id}    ${pdu_gw_id}    ${pcell_id}    ${scell1}    ${scell2}
    Triggered Scell Addition by A1    ue_id=${ue_id}    pcell=${pcell_id}
    Check Two Scell Added Successfully    NRCELL-${pcell_id}    ${scell1}    ${scell2}
    Verify Throuput on Pscell and Scell With CA_TFF    ue_id=${ue_id}    pdu_gw_id=${pdu_gw_id}

Check Blind Scell Addition for TFF CA
    [Arguments]    ${ue_id}    ${pdu_gw_id}    ${pcell_id}    ${scell1}    ${scell2}
    Check Two Scell Added Successfully    NRCELL-${pcell_id}    ${scell1}    ${scell2}
    Verify Throuput on Pscell and Scell With CA_TFF    ue_id=${ue_id}    pdu_gw_id=${pdu_gw_id}

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

Start Traffic NonCA
    [Arguments]    ${ue_id}    ${pdu_gw_id}
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_gw_id} qfi=1 dir=dl mbps=100 trf_id=2
    ...    pass_regexp=UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_gw_id} qfi=1 dir=ul mbps=10
    ...    pass_regexp=UE ${ue_id}: UDP UL

Triggered Scell Addition by A1
    [Arguments]    ${pcell}    ${ue_id}=82    ${rsrp}=120    ${rsrq}=120    ${scell_num}=2
    Execute Egate Command    ue_disp
    ${pcell_ssbfreq}    Get From Dictionary    ${CELLS_SSBFREQ}    ${pcell}
    ${meas_id}    Get Nr Meas Id For Specific Type And Frequency    ${ue_id}    ${pcell_ssbfreq}    A1
    Execute Egate Command
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=${rsrp} srsrq_nr=${rsrq}
    ...    pass_regexp=SCellIndex ${scell_num} activated successfully

InterFreq A3 HO With A2
    [Arguments]    ${ue_id}    ${source_cell}    ${target_cell}    ${target_phycell_id}
    Execute Egate Command    ue_disp
    ${src_cell_ssbfreq}    Get From Dictionary    ${CELLS_SSBFREQ}    ${source_cell}
    ${a2_meas_id}    Get Nr Meas Id For Specific Type And Frequency    ${ue_id}    ${src_cell_ssbfreq}    A2
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${a2_meas_id} event=A2 srsrp_nr=7 srsrq_nr=7
    ...    pass_regexp=rrcReconfigurationComplete
    ${target_cell_ssbfreq}    Get From Dictionary    ${CELLS_SSBFREQ}    ${target_cell}
    ${a3_meas_id}    Get Nr Meas Id For Specific Type And Frequency    ${ue_id}    ${target_cell_ssbfreq}    A3
    ${a3_cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${a3_meas_id} event=A3
    ...    srsrp_nr=11 srsrq_nr=11 phycell_id=${target_phycell_id} nrsrp_nr=60 nrsrq_nr=60
    Execute Egate Command    ${a3_cmd}
    ...    pass_regexp=Intra-eNB handover from EXT_ENB-2.${source_cell} to EXT_ENB-2.${target_cell} performed


Recover Param and Common Test Teardown
    [Arguments]     ${origin_params}
    Delta Commission Parameters     ${origin_params}
    Common Test Teardown And Stop Capture Logs
