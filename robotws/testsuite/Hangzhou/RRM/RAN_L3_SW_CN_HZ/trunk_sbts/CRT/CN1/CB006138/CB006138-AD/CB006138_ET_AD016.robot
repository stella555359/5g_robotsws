*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_VRF    SBTS00    RAN_5G    RAN_5G_TDD    CRT    master_classicalbts_all    STATE_CONFIGURED
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
...    NRCELL-2:sMeasConfigSsbRsrp=1
...    NRCELL-4:sMeasConfigSsbRsrp=1
...    NRCELL:a1MeashoSsbRsrp:a1HysteresishoSsbRsrp=0
...    NRCELL:a1MeashoSsbRsrp:a1ThresholdhoSsbRsrp=34
...    NRCELL:a1MeashoSsbRsrp:a1TimeToTriggerhoSsbRsrp=ms480
...    NRCELL:a1MeashoSsbRsrq:a1HysteresishoSsbRsrq=0
...    NRCELL:a1MeashoSsbRsrq:a1ThresholdhoSsbRsrq=31
...    NRCELL:a1MeashoSsbRsrq:a1TimeToTriggerhoSsbRsrq=ms480
...    NRCELL:a2MeasRedirectSsbRsrp:a2HysteresisRedirectSsbRsrp=0
...    NRCELL:a2MeasRedirectSsbRsrp:a2ThresholdRedirectSsbRsrp=33
...    NRCELL:a2MeasRedirectSsbRsrp:a2TimeToTriggerRedirectSsbRsrp=ms480
...    NRCELL:a2MeasRedirectSsbRsrq:a2HysteresisRedirectSsbRsrq=0
...    NRCELL:a2MeasRedirectSsbRsrq:a2ThresholdRedirectSsbRsrq=31
...    NRCELL:a2MeasRedirectSsbRsrq:a2TimeToTriggerRedirectSsbRsrq=ms480
...    NRCELL:a2MeasReleaseSsbRsrp:a2HysteresisReleaseSsbRsrp=0
...    NRCELL:a2MeasReleaseSsbRsrp:a2ThresholdReleaseSsbRsrp=32
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
...    NRCELL:actVoNR=true
...    NRCELL:pucchF3MaxCodeRate=zeroDot08
...    NRCELL:pucchModeSelect=longPucch
...    NRCELL:pucchF3ModulationScheme=pi2bpsk
...    NRCELL:actCDrx=true
...    NRCELL:actPrachMultiplexing=true
...    NRBTS:actConflictConfiguration=true
...    NRBTS-1/NRDRB_PDCP-3:tReorderingDl=ms300
...    NRBTS-1/NRDRB_PDCP-3:tReorderingUl=ms300
...    NRBTS-1/NRDRB_PDCP-3:pdcpBufDiscardEnabled=false
...    NRBTS-1/NRDRB-16:dlFlowControlAlgo=none
...    NRBTS-1/NRDRB-16:dscp=46
...    NRBTS-1/NRDRB-16:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-2
...    NRBTS-1/NRDRB-16:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-3
...    NRBTS-1/NRDRB-16:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRBTS-1/NRDRB-16:numSduDiscard=1
...    NRBTS-1/NRDRB-16:queuingDelayDiscarding=Controlled Delay (CoDel)
...    NRBTS-1/NRDRB-16:queuingDelaySduDiscardThreshold=200
...    NRBTS-1/NRDRB-16:resType=nonGBR
...    NRBTS-1/NRDRB-16:rlcMode=RLC_UM
...    NRBTS-1/NRDRB-16:sduDiscardIntervalTmr=100
...    NRBTS-1/NRDRB-16:schedulWeight=24
...    NRBTS-1/NRDRB-16:discardTimer=150ms
...    NRBTS-1/NRDRB_RLC_UM-1:dlTReassemblyUm=ms40
...    NRBTS-1/NRDRB_RLC_UM-1:ulTReassemblyUm=ms40
...    NRBTS-1/NRDRB_5QI-6:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-15
...    NRBTS-1/NRDRB-15:dlFlowControlAlgo=none
...    NRBTS-1/NRDRB-15:dscp=0
...    NRBTS-1/NRDRB-15:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-3
...    NRBTS-1/NRDRB-15:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-3
...    NRBTS-1/NRDRB-15:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRBTS-1/NRDRB-15:numSduDiscard=1
...    NRBTS-1/NRDRB-15:queuingDelayDiscarding=Disabled
...    NRBTS-1/NRDRB-15:queuingDelaySduDiscardThreshold=200
...    NRBTS-1/NRDRB-15:resType=GBR
...    NRBTS-1/NRDRB-15:rlcMode=RLC_UM
...    NRBTS-1/NRDRB-15:sduDiscardIntervalTmr=100
...    NRBTS-1/NRDRB-15:schedulWeight=1
...    NRBTS-1/NRDRB-15:discardTimer=10ms
...    NRBTS-1/NRDRB-15:maxRlcQueueingDelayGbr=20
...    NRBTS-1/NRDRB-15:maxTransferDelayGbr=20
...    NRBTS-1/NRDRB-15:cellAggrLevel=Not FR1 CA eligible
...    NRDRB-10:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-4
...    NRBTS-1/NRDRB_MAC-2:lcgid=2
...    NRBTS-1/NRDRB_MAC-2:schedulPrio=5
...    NRBTS-1/NRDRB_MAC-3:lcgid=4
...    NRBTS-1/NRDRB_MAC-3:schedulPrio=5
...    NRBTS-1/NRDRB_MAC-4:lcgid=2
...    NRBTS-1/NRDRB_MAC-4:schedulPrio=4
...    NRCELL-4:actCDrxVoNR=true
...    NRCELL-4:actEnhancedVoNR=true
...    NRCELL-4:n310VoNR=n10
...    NRCELL-4:t310VoNR=100ms
...    NRCELLGRP-3:numberOfTransmittedSsBlocks=4 beams
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
...    NRCELL-4/NRREL-2:sCellOperationalMode=dlOnly
...    NRPMRNL-1:miNrRelReportCu=15min
...    NRBTS-1:actFdmEnhancedScheduling=true
...    NRBTS-1:actFdmScheduling=true
...    NRBTS-1:actLteNrDss=true
...    NRBTS-1:actConflictConfiguration=true
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRDU-1:actInterNumerologyCa=true
...    NRDU-1:flexibleCAMode=NumberCellAmount
#...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:carrierAggregationSupportList=${CA_SUPPORT_LIST}
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
...    NRCELL-3/NRREL-2:sCellOperationalMode=dlOnly
...    NRBTS-1/NRCELL-11:pMax=380
...    NRCELL-3:actCDrxVoNR=true
...    NRCELL-3:actEnhancedVoNR=true
...    NRCELL-3:n310VoNR=n10
...    NRCELL-3:t310VoNR=100ms
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
...    NRCELL-4/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELLGRP-0:numberOfTransmittedSsBlocks=4 beams
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
...    NRCELL-3/NRREL-1:sCellOperationalMode=dlOnly
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

@{VALID_SCELL_ADD_AD016}
...    NRCELL:a3MeasEnabled=rsrp
...    NRCELL:absThreshSsbRsrqConsolidation=1
...    NRCELL:absThreshSsbRsrpConsolidation=1
...    NRCELL:sMeasConfigSsbRsrp=1
...    NRBTS-1/NRADJNRCELL-1:cellDepType=SA
...    NRBTS-1/NRADJNRCELL-1:freqBandIndicatorNR=41
...    NRBTS-1/NRADJNRCELL-1:fiveGsTac=0
...    NRBTS-1/NRADJNRCELL-1:gNbId=35
...    NRBTS-1/NRADJNRCELL-1:gNbIdLength=22
...    NRBTS-1/NRADJNRCELL-1:lcrId=1
...    NRBTS-1/NRADJNRCELL-1:nrarfcn=526020
...    NRBTS-1/NRADJNRCELL-1:physCellId=381
...    NRBTS-1/NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRBTS-1/NRADJNRCELL-1:gnbPlmn:mnc=489
...    NRBTS-1/NRADJNRCELL-1:gnbPlmn:mncLength=3
...    NRBTS:actIncXn=true
...    NRBTS:actConflictConfiguration=true
...    NRBTS:timerXnDataFwdGuard=250
...    NRBTS:actIntraFreqHoSA=true
...    NRBTS:cipherPrefL:nea0=1
...    NRBTS:cipherPrefL:nea1_128=3
...    NRBTS:cipherPrefL:nea2_128=6
...    NRBTS:cipherPrefL:nea3_128=9
...    NRBTS:integrityProtPrefL:nia0=0
...    NRBTS:integrityProtPrefL:nia1_128=3
...    NRBTS:integrityProtPrefL:nia2_128=6
...    NRBTS:integrityProtPrefL:nia3_128=9
...    NRPMRNL-1:miNrRelReportCu=15min
...    NRPMRNL-1:miNrCABMCCP=disabled
...    NRCELL-4/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-4/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-4/NRREL-10:gNbId=35
...    NRCELL-4/NRREL-10:gNbIdLength=22
...    NRCELL-4/NRREL-10:handoverAllowedSA=allowed
...    NRCELL-4/NRREL-10:lcrId=1
...    NRCELL-4/NRREL-10:removeNotAllowed=false
...    NRCELL-4/NRREL-10:nrDcAllowed=false
...    NRCELL-4/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-4/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-4/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-4/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-4/NRREL-2:sCellAdditionMethod=blind

${TDD_SCELL_FOR_NRCELL4}    NRCELL-1
${FDD_SCELL_FOR_NRCELL4}    NRCELL-11

&{INTER_GNB_CELLS_SSBFREQ}
...     ENB-3.1=526590
...     EXT_ENB-2.4=526590

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



*** Test Cases ***
CB006138-ET-AD016_Verify_SA_A3_rsrp_intrafreq_intergNB_HO_from_3CC_TTF_with_scell_blind_to_3CC_TTF_with_intracell_HO
    [Documentation]
    ...    1. The purpose of this test case is to verify Interworking with DRX when UE has no VoNR call running
    ...    2. Test Case Steps:
    ...         step1. Attach UE to cell4, (cell1&11 shall be selected as SCell candidate)
    ...         Expected Results:
    ...                attach successfully, SA call setup successfully, blind scell add
    ...         step2. HO to sim GNB ID=3,
    ...         Expected Results:
    ...                HO successful
    ...         step3. HO back to ell4_TTF, scell added automatically. Sim AMF updated UE security capacity to AES\AES.
    ...         Expected Results:
    ...                Intracell HO successfully. With NewSecurityIndicator is true.
    [Tags]    CB006138-AD016    QC_46989
    Before_ue_attach_AD016
    UE Attach and L3 VoNR Call    ue_id=81    pdu_gw_id=2
    Check Two Scell Added Successfully    NRCELL-4    ${TDD_SCELL_FOR_NRCELL4}    ${FDD_SCELL_FOR_NRCELL4}
    Verify Throuput on Pscell and Scell    ue_id=81    pdu_gw_id=2
    Start RRC Log       AD016_IntraFreqInterGNB_HO
    IntraFreq InterGNB A3 HO    ue_id=81    source_cell=EXT_ENB-2.4    target_cell=ENB-3.1    target_phycell_id=381
    IntraFreq InterGNB A3 HO with IntraCell HO    ue_id=81    source_cell=ENB-3.1    target_cell=EXT_ENB-2.4    target_phycell_id=53
    Check Two Scell Added Successfully    NRCELL-4    ${TDD_SCELL_FOR_NRCELL4}    ${FDD_SCELL_FOR_NRCELL4}
    Verify Throuput on Pscell and Scell    ue_id=81    pdu_gw_id=2
    Check WireShark Log    ${CURDIR}${/}a2a_AD016${/}a2a.ini
    ...    wait_string=UEContextModificationResponse::42
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
    Update Cfg    gnb_param id=3 send_xn_setup=true xn_listening_socket=on
    Update Cfg    gnb_param id=4 send_xn_setup=true xn_listening_socket=on
    ${cmd1}    Catenate    set_ue simulated id=81 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56
    ...    opc_key=0ED47545168EAFE2C39C075829A7B61F nia=snow3g+zuc+aes nea=null+snow3g+zuc+aes
    ...    sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0000:0:0:021645481 enb=2 cell=1 mode=nr
    Update Cfg    ${cmd1}
    Update Cfg    amf_param id=1 full_nas_auth=on ims_voice_3gpp=on nia=snow3g+zuc+aes nea=null+snow3g+zuc+aes
    Update Cfg    ue_nr_capabilities id=81 voice_over_nr=on:on:off
    Update Cfg    ue_param id=81 ue_nr_capabilities=${SA_Capa_perUE_Full} nr_usage_setting=voice_centric
    ${cmd2}    Catenate    set_cell id=1 gnb=3 pci=127:0 tac=200 nrci=0x01 tdd_cell=on
    ...    proxy=$PROXY_SERVER5_IP:9999 nr_arfcn=526020:526020 gscn=6582 mandatory_for_activation=off
    Update Cfg    ${cmd2}
    ${cell_11}    catenate    set_cell id=11 gnb=2 pci=20:0 tac=200 nrci=0x0B tdd_cell=off
    ...    proxy=$PROXY_SERVER_IP:9999|$PROXY_SERVER_IP:8888 nr_arfcn=344000:424000 gscn=5300 mandatory_for_activation=off
    Update Cfg    ${cell_11}
    ${cell_4}    catenate    set_cell id=4 gnb=2 pci=17:2 tac=200 nrci=0x04 tdd_cell=on
    ...    proxy=$PROXY_SERVER_IP:9999|$PROXY_SERVER_IP:8888 nr_arfcn=526020:526020 gscn=6582 mandatory_for_activation=off
    Update Cfg    ${cell_4}


Verify Throuput on Pscell and Scell
    [Arguments]    ${ue_id}    ${pdu_gw_id}
    builtin.sleep    15s
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000 > 100
    ${scell1_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=1    type=pdsch    rate_type=ave
    #Should Be True    ${scell1_tput}/1000 > 10
    ${scell2_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=2    type=pdsch    rate_type=ave
    #Should Be True    ${scell2_tput}/1000 > 10
    Should Be True    ${scell0_tput}/1000+${scell1_tput}/1000+${scell2_tput}/1000 > 360
    Verify SA DL and UL Traffic    ${ue_id}    ${pdu_gw_id}

Verify SA DL and UL Traffic
    [Arguments]    ${ue_id}    ${pdu_gw_id}
    builtin.sleep    15s
    ${ul_throuput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_gw_id}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${ul_throuput}/1000>9
    ${dl_throuput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_gw_id}    qfi=1    direction=dl    rate_type=ave
    Should Be True    ${dl_throuput}/1000>100

Before_ue_attach_AD016
    Delta Commission Parameters     ${VALID_SCELL_ADD_AD016}
    ${cmd1}    Catenate    ue_history_information_list_add_ngran id=1 cell_type=large
    ...    nrcgi=311:489|0x01 gnb_id=3 time_ue_stayed_in_cell=97
    ${cmd2}    Catenate    ue_history_information_list_add_ngran id=1 cell_type=large
    ...    nrcgi=311:489|0x01 gnb_id=2 time_ue_stayed_in_cell=98
    Execute Egate Command    gnb_param id=3 xn_listening_socket=1 send_xn_setup=true
    Execute Egate Command    gnb_xn_link_up gnb=3 target=2    pass_regexp=is up
    Execute Egate Command    ${cmd1}
    Execute Egate Command    ${cmd2}
    Execute Egate Command    ue_history_information_list id=1 action=commit
    Execute Egate Command    ue_enb_param id=81 ue_history_list=1
    Execute Egate Command    ue_change_location id=81 enb=2 cell=4
    Clear Counter Files
    Start RRC Log    AD016

Check Two Scell Added Successfully
    [Arguments]    ${pcell}    ${scell1}    ${scell2}
    ${SCELL1_physCellId}    Get Scf Parameter Value    ${scell1}:physCellId
    ${SCELL2_physCellId}    Get Scf Parameter Value    ${scell2}:physCellId
    Rrc Should Contain    sCellToAddModList    physCellId ${SCELL1_physCellId}    physCellId ${SCELL2_physCellId}

UE Attach and L3 VoNR Call
    [Arguments]    ${ue_id}    ${pdu_gw_id}
    Execute Egate Command    smf_param id=1 reset
    Execute Egate Command    qosflow_modify qos_flow=1 default=on
    Execute Egate Command    ue_register id=${ue_id}     pass_regexp=Received REGISTRATION COMPLETE
    Execute Egate Command    qosflow_modify qos_flow=1 default=on
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_gw_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup pdu=${pdu_gw_id} ue=${ue_id} nwslice=1 gw=${pdu_gw_id}
    ...                      pass_regexp=Initial Context Setup Successful
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu_gw_id} qosflows_to_add=2 by=amf
    ...                      pass_regexp=Added QosFlow with QFI:2 5QI:1
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

IntraFreq InterGNB A3 HO with IntraCell HO
    [Arguments]    ${ue_id}    ${source_cell}    ${target_cell}    ${target_phycell_id}
    Execute Egate Command    ue_disp
    Execute Egate Command    ue_reauth id=81 nr_sec_cap=aes|aes    pass_regexp=Reauthentication
    Execute Egate Command    amf_path_switch_param id=1 include_ue_sec_cap=on
    Execute Egate Command    smf_param id=1 security_indication=path_switch:preferred:preferred max_data_rate=6mbps
    ${target_cell_ssbfreq}    Get From Dictionary    ${INTER_GNB_CELLS_SSBFREQ}    ${target_cell}
    ${a3_meas_id}    Get Nr Meas Id For Specific Type And Frequency    ${ue_id}    ${target_cell_ssbfreq}    A3
    ${a3_cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${a3_meas_id} event=A3
    ...    srsrp_nr=11 srsrq_nr=11 phycell_id=${target_phycell_id} nrsrp_nr=60 nrsrq_nr=60
    Execute Egate Command    ${a3_cmd}
    ...    pass_regexp=Intra-cell handover

IntraFreq InterGNB A3 HO
    [Arguments]    ${ue_id}    ${source_cell}    ${target_cell}    ${target_phycell_id}
    Execute Egate Command    ue_disp
    ${target_cell_ssbfreq}    Get From Dictionary    ${INTER_GNB_CELLS_SSBFREQ}    ${target_cell}
    ${a3_meas_id}    Get Nr Meas Id For Specific Type And Frequency    ${ue_id}    ${target_cell_ssbfreq}    A3
    ${a3_cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${a3_meas_id} event=A3
    ...    srsrp_nr=11 srsrq_nr=11 phycell_id=${target_phycell_id} nrsrp_nr=60 nrsrq_nr=60
    Execute Egate Command    ${a3_cmd}
    ...    pass_regexp=Inter-eNB handover from ${source_cell} to ${target_cell} performed

