*** Settings ***
Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    RAN_5G    RAN_5G_TDD    CRT    SBTS00    master_classicalbts_all
...               STATE_CONFIGURED    FR1    CN2    team-SG2    owner-cathy.mao    owner-dandan.chen    release-SBTS22R1
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
...    NRBTS:actLteNrDss=true
...    NRCELL:actVoNR=true
...    NRCELL:actCDrx=true
...    NRCELL:pucchF3MaxCodeRate=zeroDot08
...    NRCELL:actK1Opt=intra-gNB
...    NRCELL:actPrachMultiplexing=true
...    NRCELL:pucchModeSelect=longPucch
...    NRCELL:pucchF3ModulationScheme=pi2bpsk
...    NRCELLGRP-0:numberOfTransmittedSsBlocks=4 beams
...    NRCELLGRP-3:numberOfTransmittedSsBlocks=4 beams
...    NRBTS-1:cipherPrefL:nea0=8
...    NRBTS-1:cipherPrefL:nea1_128=0
...    NRBTS-1:cipherPrefL:nea2_128=0
...    NRBTS-1:cipherPrefL:nea3_128=0
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
...    NRBTS-1/NRDRB-15:maxDataRateGbrDl=1000
...    NRBTS-1/NRDRB-15:maxDataRateGbrUl=1000
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
...    NRBTS-1/NRDRB_PDCP-3:tReorderingDl=ms300
...    NRBTS-1/NRDRB_PDCP-3:tReorderingUl=ms300
...    NRBTS-1/NRDRB_PDCP-3:pdcpBufDiscardEnabled=false
...    NRBTS-1/NRDRB_RLC_UM-1:dlTReassemblyUm=ms40
...    NRBTS-1/NRDRB_RLC_UM-1:ulTReassemblyUm=ms40
...    NRBTS-1/NRDRB_5QI-7:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-16
...    NRBTS-1/NRDRB_5QI-7:fiveqiValueList=128
...    NRBTS-1/NRDRB_MAC-2:lcgid=2
...    NRBTS-1/NRDRB_MAC-2:schedulPrio=5
...    NRBTS-1/NRDRB_5QI-6:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-15
...    NRBTS-1/NRDRB_5QI-6:fiveqiValueList=1
...    NRDRB-10:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-4
...    NRBTS-1/NRDRB_MAC-4:lcgid=2
...    NRBTS-1/NRDRB_MAC-4:schedulPrio=4
...    NRBTS-1/NRDRB_MAC-3:lcgid=4
...    NRBTS-1/NRDRB_MAC-3:schedulPrio=5
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRDU-1:actInterNumerologyCa=true
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:carrierAggregationSupportList=${CA_SUPPORT_LIST}
#...    NRBTS-1/NRCELL-1:actBeamforming=true
#...    NRBTS-1/NRCELL-1:beamSet:basicBeamSet=beamSet_4
#...    NRBTS-1/NRCELL-1:beamSet:leftEdgeAngle=60
#...    NRBTS-1/NRCELL-1:beamSet:nrBtsBeamRefinementP2=false
#...    NRBTS-1/NRCELL-1:beamSet:rightEdgeAngle=60
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
#...    NRCELL-4:actBeamforming=true
#...    NRCELL-4:beamSet:basicBeamSet=beamSet_4
#...    NRCELL-4:beamSet:leftEdgeAngle=60
#...    NRCELL-4:beamSet:nrBtsBeamRefinementP2=false
#...    NRCELL-4:beamSet:rightEdgeAngle=60
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
...    NRCELL-11:pMax=380
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

@{VALID_SCELL_ADD_AD001}
...    NRCELL-4:drxProfile1:drxInactivityTimer=20ms
...    NRCELL-4:drxProfile1:drxLongCycle=80ms
...    NRCELL-4:drxProfile1:drxOnDurationTimer=2ms
...    NRCELL-4:drxProfile1:drxRetransTimerDl=16slot
...    NRCELL-4:drxProfile1:drxRetransTimerUl=16slot
...    NRCELL-4:actAperCsi=true

@{origin_params_AD001}
...    NRCELL-4:drxProfile1:drxInactivityTimer=40ms
...    NRCELL-4:drxProfile1:drxLongCycle=80ms
...    NRCELL-4:drxProfile1:drxOnDurationTimer=10ms
...    NRCELL-4:drxProfile1:drxRetransTimerDl=16slot
...    NRCELL-4:drxProfile1:drxRetransTimerUl=16slot
...    NRCELL-4:actAperCsi=false

@{VALID_SCELL_ADD_AD004}
...    NRCELL-4:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL-4:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=75
...    NRCELL-4:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=95
...    NRCELL-4:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-4:a1MeasSCellAddEnabled=rsrp
...    NRCELL-4:drxProfile1:drxInactivityTimer=40ms
...    NRCELL-4:drxProfile1:drxLongCycle=160ms
...    NRCELL-4:drxProfile1:drxOnDurationTimer=2ms
...    NRCELL-4:drxProfile1:drxRetransTimerDl=16slot
...    NRCELL-4:drxProfile1:drxRetransTimerUl=16slot
...    NRCELL-4:drxProfile2:drxInactivityTimer=4ms
...    NRCELL-4:drxProfile2:drxLongCycle=40ms
...    NRCELL-4:drxProfile2:drxOnDurationTimer=6ms
...    NRCELL-4:drxProfile2:drxRetransTimerDl=0slot
...    NRCELL-4:drxProfile2:drxRetransTimerUl=0slot
...    NRCELL-4:beamSet:basicBeamSet=beamSet_2
...    NRCELL-4:beamSet:leftEdgeAngle=60
...    NRCELL-4:beamSet:nrBtsBeamRefinementP2=false
...    NRCELL-4:beamSet:rightEdgeAngle=60
...    NRCELL-4/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-4/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRBTS-1:actMeasBasedSCellAdditionSa=A1-based
...    NRCELL-11:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0
...    NRCELL-11:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=34
...    NRCELL-11:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-11:a2MeasSCellRelEnabled=rsrp
...    NRCELL-1:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0
...    NRCELL-1:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=35
...    NRCELL-1:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-1:a2MeasSCellRelEnabled=rsrp
...    NRCELLGRP-3:numberOfTransmittedSsBlocks=2 beams

@{origin_params_AD004}
...    NRCELL-4:a1MeasSCellAddEnabled=none
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
...    NRCELL-4:beamSet:basicBeamSet=beamSet_4
...    NRCELL-4:beamSet:leftEdgeAngle=60
...    NRCELL-4:beamSet:nrBtsBeamRefinementP2=false
...    NRCELL-4:beamSet:rightEdgeAngle=60
...    NRCELL-4/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-4/NRREL-2:sCellAdditionMethod=blind
...    NRBTS-1:actMeasBasedSCellAdditionSa=disabled
...    NRCELL-11:a2MeasSCellRelEnabled=none
...    NRCELL-1:a2MeasSCellRelEnabled=none
...    NRCELLGRP-3:numberOfTransmittedSsBlocks=4 beams

${TDD_SCELL_FOR_NRCELL4}    NRCELL-1
${FDD_SCELL_FOR_NRCELL4}    NRCELL-11

${FDD_SCELL1_FOR_NRCELL3}    NRCELL-11
${FDD_SCELL2_FOR_NRCELL3}    NRCELL-12

@{VALID_SCELL_ADD_AD006}
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

@{origin_params_AD006}
...    NRCELL-3:a1MeasSCellAddEnabled=none
...    NRCELL-3/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-3/NRREL-2:sCellAdditionMethod=blind
...    NRBTS-1:actMeasBasedSCellAdditionSa=disabled
...    NRCELL-11:a2MeasSCellRelEnabled=none
...    NRCELL-12:a2MeasSCellRelEnabled=none

@{VALID_SCELL_ADD_AD008}
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

@{origin_params_AD008}
...    NRCELL-3:a1MeasSCellAddEnabled=none
...    NRCELL-3/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-3/NRREL-2:sCellAdditionMethod=blind
...    NRBTS-1:actMeasBasedSCellAdditionSa=disabled
...    NRCELL-11:a2MeasSCellRelEnabled=none
...    NRCELL-12:a2MeasSCellRelEnabled=none

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
${A2MEAS_REL1DLSCELL_ATT_SA}    M55118C06501    #Nbr of RRC Reconfiguration attempts releasing 1 SCell in DL triggered by A2 measurement for SA
${A2MEAS_REL1DLSCELL_SUCC_SA}    M55118C06502    #Nbr of successful RRC Reconfigurations releasing 1 SCell in DL triggered by A2 measurement for SA
${GNB_SCELL_2_ADMI_REQ_SA}    M55138C02501    #The number of radio admission requests for 2 SCells in SA mode
${GNB_SCELL_2_ADMI_SUCC_SA}    M55138C02502    #The number of successful radio admissions for 2 SCells additions in SA mode
${GNB_DU_SCELL_2_ADMI_REQ_SA}    M55139C01501    #The number of radio admission requests for 2 SCells in SA mode in DU
${GNB_DU_SCELL_2_ADMI_SUCC_SA}    M55139C01502    #The number of successful radio admissions for 2 SCells additions in SA mode in DU
${GNB_DU_SCELL_ADMI_REQ_SA}    M55139C01001    #The number of radio admission requests for the SCell in SA mode in DU
${GNB_DU_SCELL_ADMI_SUCC_SA}    M55139C01002    #The number of successful radio admissions for the SCell in SA mode in DU
${UE_SCELL_2_CONF_SCELL_DL_SA}    M55118C07002    #Sum of CA UEs in the current cell configured as a SCell, which have 2 configured SCells in DL

${UE_PCELL_1_CONF_SCELL_DL_SA}    M55118C05507
${RRC_RECONF_ADD1DLSCELL_ATT_SA}    M55118C05505

@{PM_COUNTER_AD004}
...     NRCELL-4:${UE_PCELL_2_CONF_SCELL_DL_SA}>0
...     NRCELL-4:${RRC_RECONF_ADD2DLSCELL_SUCC_SA}==1
...     NRCELL-4:${RRC_RECONF_ADD2DLSCELL_ATT_SA}==1
...     NRCELL-4:${A2MEAS_REL1DLSCELL_ATT_SA}==2
...     NRCELL-4:${A2MEAS_REL1DLSCELL_SUCC_SA}==2
...     NRCELL-4:${GNB_SCELL_2_ADMI_REQ_SA}==1
...     NRCELL-4:${GNB_SCELL_2_ADMI_SUCC_SA}==1
...     NRCELL-4:${GNB_DU_SCELL_2_ADMI_REQ_SA}==1
...     NRCELL-4:${GNB_DU_SCELL_2_ADMI_SUCC_SA}==1
...     NRCELL-11:${GNB_DU_SCELL_ADMI_REQ_SA}==1
...     NRCELL-11:${GNB_DU_SCELL_ADMI_SUCC_SA}==1
...     NRCELL-1:${GNB_DU_SCELL_ADMI_REQ_SA}==1
...     NRCELL-1:${GNB_DU_SCELL_ADMI_SUCC_SA}==1
...     NRCELL-1:${UE_SCELL_2_CONF_SCELL_DL_SA}>0
...     NRCELL-11:${UE_SCELL_2_CONF_SCELL_DL_SA}>0

@{PM_COUNTER_AD006}
...     NRCELL-3:${UE_PCELL_1_CONF_SCELL_DL_SA}>0
...     NRCELL-3:${RRC_RECONF_ADD1DLSCELL_ATT_SA}==0
...     NRCELL-3:${UE_PCELL_2_CONF_SCELL_DL_SA}>0
...     NRCELL-3:${UE_SCELL_2_CONF_SCELL_DL_SA}==0
...     NRCELL-3:${RRC_RECONF_ADD2DLSCELL_SUCC_SA}==1
...     NRCELL-3:${RRC_RECONF_ADD2DLSCELL_ATT_SA}==1
...     NRCELL-11:${UE_SCELL_2_CONF_SCELL_DL_SA}>0
...     NRCELL-12:${UE_SCELL_2_CONF_SCELL_DL_SA}>0

@{PM_COUNTER_AD008}
...     NRCELL-3:${UE_PCELL_1_CONF_SCELL_DL_SA}>0
...     NRCELL-3:${RRC_RECONF_ADD1DLSCELL_ATT_SA}==0
...     NRCELL-3:${UE_PCELL_2_CONF_SCELL_DL_SA}>0
...     NRCELL-3:${UE_SCELL_2_CONF_SCELL_DL_SA}==0
...     NRCELL-3:${RRC_RECONF_ADD2DLSCELL_SUCC_SA}==1
...     NRCELL-3:${RRC_RECONF_ADD2DLSCELL_ATT_SA}==1
...     NRCELL-11:${UE_SCELL_2_CONF_SCELL_DL_SA}>0
...     NRCELL-12:${UE_SCELL_2_CONF_SCELL_DL_SA}>0

*** Test Cases ***
CB006138-ET-AD001_Verify_SA_3CC_TTF_with_scell_blind_with_CommonDRX_when_CSI_of_scell_can_not_be_allocated_in_DRX
    [Documentation]
    ...    1. The purpose of this test case is to verify Interworking with DRX when UE has no VoNR call running
    ...    2. Test Case Steps:
    ...         step1. setup CA TTF ue when CSI of scell can not be allocated in DRX. Online modifiy common drx onduration to 1ms
    ...                to make sure two scell CSI RS cannot be allocated on DRXonduration timer.
    ...         Expected Results:
    ...                FDD scell can added, TDD scell can also be added.
    [Tags]    CB006138-AD001    owner-chendandan    QC_133906
    [Timeout]    60 min
    Before_ue_attach_AD001
    UE Attach and L3 Call    ue_id=81    pdu_gw_id=1
    Check Two Scell Added Successfully    NRCELL-4    ${TDD_SCELL_FOR_NRCELL4}    ${FDD_SCELL_FOR_NRCELL4}
    Check WireShark Log    ${CURDIR}${/}a2a_AD001${/}a2a.ini    wait_string=UEContextModificationResponse::16
    Release Ues    ue_type=all
    [Teardown]    Recover Param and Common Test Teardown    ${origin_params_AD001}

CB006138-ET-AD004_Verify_SA_3CC_TTF_with_scell_coverbased_interact_with_VoNRDRX_when_CSI_can_not_be_allocated_in_DRX
    [Documentation]
    ...    1. The purpose of this test case is to verify Interworking with DRX when UE has no VoNR call running
    ...    2. Test Case Steps:
    ...         step1. setup CA TTF VoNR ue before PDU session setup
    ...         Expected Results:
    ...                CA TTF VoNR ue L3 call successful. VoNR DRX is configured to UE.
    ...         step2. Trigger A1 event, setup CA TTF ue when CSI of scell can not be allocated in DRX
    ...         Expected Results:
    ...                FDD scell can added, TDD scell can also be added.
     ...         step3. Release VoNR service.
    ...         Expected Results:
    ...                VoNR released and VoNR DRX released, common drx setup.
    ...         counters check: M55118C07001,M55118C07003,M55118C07004,M55118C06501,M55118C06502,M55138C02501,
    ...         M55138C02502,M55139C01501,M55139C01502,M55139C01002,M55139C01001,M55118C07002
    [Tags]     CB006138-AD004    owner-zhoulingyan    QC_133903
    [Timeout]    60 min
    Before_ue_attach_AD004
    UE Attach and L3 VoNR Call    ue_id=81    pdu_gw_id=2
    Triggered Scell Addition by A1    pcell=4
    Check Two Scell Added Successfully    NRCELL-4    ${TDD_SCELL_FOR_NRCELL4}    ${FDD_SCELL_FOR_NRCELL4}
    Verify Throuput on Pscell and Scell    ue_id=81    pdu_gw_id=2
    Release VoNR    ue_id=81    pdu_gw_id=2
    Release Scell    1    11    ue_id=81
    Check WireShark Log    ${CURDIR}${/}a2a_AD004${/}a2a.ini    wait_string=UEContextModificationResponse::40
    Check Counters    ${PM_COUNTER_AD004}
    Release Ues    ue_type=all
    [Teardown]    Recover Param and Common Test Teardown    ${origin_params_AD004}

CB006138-ET-AD006_Verify_SA_3CC_TFF_VoNR_after_scell_covBasedA1_then_Scell_Release_via_A2_report_with_VoNRDRX
    [Documentation]
    ...    1. The purpose of this test case is to verify Interworking with DRX when UE has no VoNR call running
    ...    2. Test Case Steps:
    ...         step1. setup ue
    ...         Expected Results:
    ...                l3 call setup success
    ...         step2. setup 5QI-1
    ...         Expected Results:
    ...                VoNR set on the UE, commondrx released, vonrdrx setup
    ...         step3. setup 5QI-2
    ...         Expected Results:
    ...                ViNR setup on the UE, vonrdrx released, FDD scells can added, commondrx setup
    ...         step4. trigger A2 to release scell-1
    ...         Expected Results:
    ...                scell-1 released successful
    ...         step5. trigger A2 to release scell-2
    ...         Expected Results:
    ...                scell-2 released successful
    ...         step6. release 5QI-2
    ...         Expected Results:
    ...                ViNR released, Vonrdrx setup
    ...         step7. release 5QI-1
    ...         Expected Results:
    ...                VoNR released, Vonrdrx release, commondrx setup
    ...          counters check : M55118C05507,M55118C05505,M55118C07001,M55118C07002,M55118C07003,M55118C07004
    [Tags]    CB006138-AD006    test    owner-chendandan    QC_133902
    [Timeout]    60 min
    Before_ue_attach_AD006
    UE Attach and L3 ViNR Call    ue_id=81    pdu_gw_id=3
    Triggered Scell Addition by A1    pcell=3
    Check Two Scell Added Successfully    NRCELL-3    ${FDD_SCELL1_FOR_NRCELL3}    ${FDD_SCELL2_FOR_NRCELL3}
    Verify Throuput on Pscell and Scell    ue_id=81    pdu_gw_id=3
    Release Scell    11    12    ue_id=81
    Release ViNR    ue_id=81    pdu_gw_id=3
    Release VoNR    ue_id=81    pdu_gw_id=3
    Verify SA DL and UL Traffic    ue_id=81    pdu_gw_id=3
    Check WireShark Log    ${CURDIR}${/}a2a_AD006${/}a2a.ini
    ...    wait_string=UEContextModificationResponse::68
    Check Counters    ${PM_COUNTER_AD006}
    Release Ues    ue_type=all
    [Teardown]    Recover Param and Common Test Teardown    ${origin_params_AD006}

CB006138-ET-AD008_Verify_SA_3CC_TFF_VoNR_ICS_5QI5_1_before_scell_covBasedA1_then_Scell_Release_via_A2_report_with_VoNRDRX
    [Documentation]
    ...    Case steps:
    ...    ActDRX and VONR before below steps
    ...    Step 1: Attach UE-81 to the TDD NR cell and setup GBR SA call.
    ...    Expected Result: attach successfully, SA call setup successfully
    ...    Step 2: When the PCell quality goes above the threshold for the configured A1 measurement event,
    ...            5GUE/Airphone sends RRC: Measurement report to the gNB for A1 event, Start UL/DL data.
    ...    Expected Result: scell addition successfully, Scell activated successfully
    ...    Step 3: Release VoNR and A2 (for SCell release) measurement report from 5G-UE
    ...    Expected Result: VoNR Resoure and SCell release successfully
    ...    Step 5: Detach UE
    ...    Expected Result: Detach UE success .
    ...    counters check : M55118C05507,M55118C05505,M55118C07001,M55118C07002,M55118C07003,M55118C07004
    [Tags]    CB006138-AD008    owner-yangchunjian    QC_133901
    [Timeout]    60 min
    Before_ue_attach_AD008
    UE Attach and L3 VoNR Call    ue_id=81    pdu_gw_id=4
    Triggered Scell Addition by A1    pcell=3
    Check Two Scell Added Successfully    NRCELL-3    ${FDD_SCELL1_FOR_NRCELL3}    ${FDD_SCELL2_FOR_NRCELL3}
    Verify Throuput on Pscell and Scell    ue_id=81    pdu_gw_id=4
    Release VoNR    ue_id=81    pdu_gw_id=4
    Release Scell    11    12    ue_id=81
    Verify SA DL and UL Traffic    ue_id=81    pdu_gw_id=4
    Check WireShark Log    ${CURDIR}${/}a2a_AD008${/}a2a.ini
    ...    wait_string=UEContextModificationResponse::40
    Check Counters    ${PM_COUNTER_AD008}
    Release Ues    ue_type=all
    [Teardown]    Recover Param and Common Test Teardown    ${origin_params_AD008}

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
    #Should Be True    ${scell2_tput}/1000 > 10
    Should Be True    ${scell0_tput}/1000+${scell1_tput}/1000+${scell2_tput}/1000 > 450
    Verify SA DL and UL Traffic    ${ue_id}    ${pdu_gw_id}

Verify SA DL and UL Traffic
    [Arguments]    ${ue_id}    ${pdu_gw_id}
    ${ul_throuput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_gw_id}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${ul_throuput}/1000>9
    ${dl_throuput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_gw_id}    qfi=1    direction=dl    rate_type=ave
    Should Be True    ${dl_throuput}/1000>450

Before_ue_attach_AD001
    Delta Commission Parameters     ${VALID_SCELL_ADD_AD001}
    Execute Egate Command    smf_param id=1 reset
    Execute Egate Command    ue_change_location id=81 enb=2 cell=4
    Clear Counter Files
    Start RRC Log    AD001

Before_ue_attach_AD004
    Delta Commission Parameters     ${VALID_SCELL_ADD_AD004}
    Execute Egate Command    ue_change_location id=81 enb=2 cell=4
    Clear Counter Files
    Start RRC Log    AD004

Before_ue_attach_AD006
    Delta Commission Parameters     ${VALID_SCELL_ADD_AD006}
    Execute Egate Command    ue_change_location id=81 enb=2 cell=3
    Clear Counter Files
    Start RRC Log    AD006

Before_ue_attach_AD008
    Delta Commission Parameters     ${VALID_SCELL_ADD_AD008}
    Execute Egate Command    ue_change_location id=81 enb=2 cell=3
    Clear Counter Files
    Start RRC Log    AD008

UE Attach and L3 Call
    [Arguments]    ${ue_id}    ${pdu_gw_id}
    Execute Egate Command    qosflow_modify qos_flow=1 default=on
    Execute Egate Command    ue_register id=${ue_id}     pass_regexp=Received REGISTRATION COMPLETE
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_gw_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup pdu=${pdu_gw_id} ue=${ue_id} nwslice=1 gw=${pdu_gw_id}
    ...                      pass_regexp=Initial Context Setup Successful
    Execute Egate Command    qosflow_disp
    traffic_should_be_ok    ue_id=81    type=SA

Check Two Scell Added Successfully
    [Arguments]    ${pcell}    ${scell1}    ${scell2}
    ${NRREL1_sCellAdditionMethod}    Get Scf Parameter Value    MRBTS-1/NRBTS-1/${pcell}/NRREL-1:sCellAdditionMethod
    ${NRREL2_sCellAdditionMethod}    Get Scf Parameter Value    MRBTS-1/NRBTS-1/${pcell}/NRREL-2:sCellAdditionMethod
    ${SCELL1_physCellId}    Get Scf Parameter Value    ${scell1}:physCellId
    ${SCELL2_physCellId}    Get Scf Parameter Value    ${scell2}:physCellId
    Rrc Should Contain    sCellToAddModList    physCellId ${SCELL1_physCellId}    physCellId ${SCELL2_physCellId}

UE Attach and L3 VoNR Call
    [Arguments]    ${ue_id}    ${pdu_gw_id}
    Execute Egate Command    qosflow_modify qos_flow=1 default=on
    Execute Egate Command    smf_param id=1 reset
    Execute Egate Command    smf_param id=1 additional_qosflows_to_activate=2
    Execute Egate Command    ue_register id=${ue_id}     pass_regexp=Received REGISTRATION COMPLETE
    Execute Egate Command    qosflow_modify qos_flow=1 default=on
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_gw_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup pdu=${pdu_gw_id} ue=${ue_id} nwslice=1 gw=${pdu_gw_id}
    ...                      pass_regexp=Initial Context Setup Successful
    Execute Egate Command    qosflow_disp
    Start Traffic    ${ue_id}    ${pdu_gw_id}
    Execute Egate Command    smf_param id=1 reset

UE Attach and L3 ViNR Call
    [Arguments]    ${ue_id}    ${pdu_gw_id}
    Execute Egate Command    smf_param id=1 reset
    Execute Egate Command    qosflow_modify qos_flow=1 default=on
    Execute Egate Command    ue_register id=${ue_id}     pass_regexp=Received REGISTRATION COMPLETE
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_gw_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup pdu=${pdu_gw_id} ue=${ue_id} nwslice=1 gw=${pdu_gw_id}
    ...                      pass_regexp=Initial Context Setup Successful
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu_gw_id} qosflows_to_add=2 by=amf
    ...    pass_regexp=Adding QosFlow with QFI:2 5QI:1
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu_gw_id} qosflows_to_add=3 by=amf
    ...    pass_regexp=Adding QosFlow with QFI:3 5QI:2
    Execute Egate Command    qosflow_disp
    Start Traffic    ${ue_id}    ${pdu_gw_id}
    Execute Egate Command    smf_param id=1 reset

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

Release VoNR
    [Arguments]    ${ue_id}    ${pdu_gw_id}
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu_gw_id} qosflows_to_del=2 by=amf
    ...    pass_regexp=Deleting QosFlow with QFI:2 5QI:1
    Builtin.sleep    3s    #sleep 3s after release vonr

Release ViNR
    [Arguments]    ${ue_id}    ${pdu_gw_id}
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu_gw_id} qosflows_to_del=3 by=amf
    ...    pass_regexp=Deleting QosFlow with QFI:3 5QI:2
    Builtin.sleep    3s    #sleep 3s after release vinr

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
