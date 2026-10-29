*** Setting ***

*** Variables ***
@{PARAMS_FOR_IODT_ABIL}
...    @{PARAMS_FOR_5GC000772}
...    @{PARAMS_FOR_5GC002060}
...    @{PARAMS_FOR_5GC000884}
...    @{PARAMS_FOR_5GC001118_CB007797}
...    @{PARAMS_FOR_5GC001729}

@{PARAMS_FOR_IODT_ABIO_4T2F}
...    @{PARAMS_FOR_5GC000772}
...    @{PARAMS_FOR_5GC002060}
...    @{PARAMS_FOR_5GC000884}
...    @{PARAMS_FOR_5GC001118_CB007797}
...    @{PARAMS_FOR_5GC001729}
...    @{PARAMS_FOR_5GC008247_4T2F}

@{PARAMS_FOR_IODT_ABIO_2T4F}
...    @{PARAMS_FOR_IODT_ABIL}

@{PARAMS_FOR_5GC000772}
...    NRCELL:actCDrx=true

@{PARAMS_FOR_5GC002060}
...    NRCELL:drxWactDlEnabled=true
...    NRCELL:drxWactUlEnabled=true
...    NRCELL:drxProfile1:drxInactivityTimer=80ms
...    NRCELL:drxProfile1:drxLongCycle=160ms
...    NRCELL:actProactUlScheduling=true
...    NRCELL:payloadSizeProactiveDrx=64
...    NRCELL:payloadSizeProactiveNonDrx=16

@{PARAMS_FOR_5GC000884}
...    NRCELL:actUlClosedLoopPwrCtrl=pucchPuschSrs
...    NRBTS-1/NRULCLPC_PROFILE-1
...    NRBTS-1/NRULCLPC_PROFILE-1:clpcPucch:targetSinr=16
...    NRCELL:nrUlClpcProfileDN=MRBTS-1/NRBTS-1/NRULCLPC_PROFILE-1

@{PARAMS_FOR_5GC001118_CB007797}
...    NRCELL:actUl256Qam=true

@{PARAMS_FOR_5GC001729}
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRDU-1:actInterNumerologyCa=true
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRBTS/NRDU-1:carrierAggregationSupportList=${CA_support_list}
...    NRCELL:allowUnsuppBcOrBcs=${allowUnsuppBcOrBcs}
...    NRBTS:sCellActivationMethod=bufferBased

${CA_support_list}    ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Fr1Tdd_Nsa,ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Fdd_Nsa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Nsa,ca_Fdd_Fdd
${allowUnsuppBcOrBcs}    accept unknown band combinations,accept unknown BCSs


@{PARAMS_FOR_5GC008247_4T2F}
...    @{PARAMS_FOR_BEAMFORMING_4T2F}
...    @{srsConfig}
...    @{csiconfig}
...    @{enableCDrx}

@{PARAMS_FOR_BEAMFORMING_4T2F}
...    NRCELL-1:beamSet:nrBtsBeamRefinementP2=true
...    NRCELL-3:beamSet:nrBtsBeamRefinementP2=true
...    NRCELL-1:beamSet:basicBeamSet=beamSet_4
...    NRCELL-2:beamSet:basicBeamSet=beamSet_4
...    NRCELL-3:beamSet:basicBeamSet=beamSet_4
...    NRCELL-4:beamSet:basicBeamSet=beamSet_4
...    NRCELL-1:numberOfRxBeamforming=4Rx
...    NRCELL-2:numberOfRxBeamforming=4Rx
...    NRCELL-3:numberOfRxBeamforming=4Rx
...    NRCELL-4:numberOfRxBeamforming=4Rx
...    NRCELLGRP-0:numberOfTransmittedSsBlocks=4 beams
...    NRCELLGRP-1:numberOfTransmittedSsBlocks=4 beams
...    NRCELLGRP-2:numberOfTransmittedSsBlocks=4 beams
...    NRCELLGRP-3:numberOfTransmittedSsBlocks=4 beams
...    NRCELL-1:actBeamforming=true
...    NRCELL-2:actBeamforming=true
...    NRCELL-3:actBeamforming=true
...    NRCELL-4:actBeamforming=true
...    NRCELL-1:mMimoAntArrayMode=Full 64TRX Array (4x8x2)
...    NRCELL-2:mMimoAntArrayMode=Full 64TRX Array (4x8x2)
...    NRCELL-3:mMimoAntArrayMode=Full 64TRX Array (4x8x2)
...    NRCELL-4:mMimoAntArrayMode=Full 64TRX Array (4x8x2)
...    NRCELL-1:dlMimoMode=4x4 or 4x2 Closed Loop Spatial Multiplexing
...    NRCELL-2:dlMimoMode=4x4 or 4x2 Closed Loop Spatial Multiplexing
...    NRCELL-3:dlMimoMode=4x4 or 4x2 Closed Loop Spatial Multiplexing
...    NRCELL-4:dlMimoMode=4x4 or 4x2 Closed Loop Spatial Multiplexing
...    NRCELL-11:dlMimoMode=2x2 Closed Loop Spatial Multiplexing
...    NRCELL-12:dlMimoMode=2x2 Closed Loop Spatial Multiplexing
...    NRCELL-1:nrCellType=8DL4UL
...    NRCELL-2:nrCellType=8DL4UL
...    NRCELL-3:nrCellType=8DL4UL
...    NRCELL-4:nrCellType=8DL4UL
...    NRCELL-1:beamSet:lowerEdgeAngle=120
...    NRCELL-1:beamSet:upperEdgeAngle=60
...    NRCELL-2:beamSet:lowerEdgeAngle=120
...    NRCELL-2:beamSet:upperEdgeAngle=60
...    NRCELL-3:beamSet:lowerEdgeAngle=120
...    NRCELL-3:beamSet:upperEdgeAngle=60
...    NRCELL-4:beamSet:lowerEdgeAngle=120
...    NRCELL-4:beamSet:upperEdgeAngle=60
...    delete:NRCELL-1:periodicCsiAcquisition:maxCsirsNumber
...    delete:NRCELL-2:periodicCsiAcquisition:maxCsirsNumber
...    delete:NRCELL-3:periodicCsiAcquisition:maxCsirsNumber
...    delete:NRCELL-4:periodicCsiAcquisition:maxCsirsNumber
...    delete:NRCELL-1:periodicCsiAcquisition:csirsPower
...    delete:NRCELL-2:periodicCsiAcquisition:csirsPower
...    delete:NRCELL-3:periodicCsiAcquisition:csirsPower
...    delete:NRCELL-4:periodicCsiAcquisition:csirsPower
...    delete:NRCELL-1:tddFrameStructure:lteToNrFrameShift
...    delete:NRCELL-2:tddFrameStructure:lteToNrFrameShift
...    delete:NRCELL-3:tddFrameStructure:lteToNrFrameShift
...    delete:NRCELL-4:tddFrameStructure:lteToNrFrameShift
...    NRCELL:actDl256Qam=true
...    NRBTS:actFdmScheduling=true
...    NRBTS:actChannelMapVal=Disabled
...    NRCELLGRP:ssBurstSetPeriod=20
...    NRCELL:pucchModeSelect=longPucch
...    NRCELL:actLongPucchPhase2=true

@{srsConfig}
...    NRCELL-1:actUlSrsBm=true
...    NRCELL-1:actDlSrsBm=true
...    NRCELL-1:srsForBeamMgmt:srsUePeriodicity=slots40
...    NRCELL-1:srsForBeamMgmt:cSRS=12
...    NRCELL-1:srsForBeamMgmt:bSRS=2
...    NRCELL-2:actUlSrsBm=true
...    NRCELL-2:actDlSrsBm=true
...    NRCELL-2:srsForBeamMgmt:srsUePeriodicity=slots40
...    NRCELL-2:srsForBeamMgmt:cSRS=38
...    NRCELL-2:srsForBeamMgmt:bSRS=2
...    NRCELL-3:actUlSrsBm=true
...    NRCELL-3:actDlSrsBm=true
...    NRCELL-3:srsForBeamMgmt:srsUePeriodicity=slots40
...    NRCELL-3:srsForBeamMgmt:cSRS=12
...    NRCELL-3:srsForBeamMgmt:bSRS=2
...    NRCELL-4:actUlSrsBm=true
...    NRCELL-4:actDlSrsBm=true
...    NRCELL-4:srsForBeamMgmt:srsUePeriodicity=slots40
...    NRCELL-4:srsForBeamMgmt:cSRS=49
...    NRCELL-4:srsForBeamMgmt:bSRS=2
...    NRCELL-1:srsForBeamMgmt:srsPowerThresholdForDlBm=-120
...    NRCELL-2:srsForBeamMgmt:srsPowerThresholdForDlBm=-120
...    NRCELL-3:srsForBeamMgmt:srsPowerThresholdForDlBm=-120
...    NRCELL-4:srsForBeamMgmt:srsPowerThresholdForDlBm=-120


#1208 Frame Structure
...    NRCELL-1:tddFrameStructure:frameStructureType=semiStatic
...    NRCELL-1:tddFrameStructure:ulDlDataSlotRatio=1/4
...    NRCELL-1:tddFrameStructure:guardPeriodLength=2Symbols
...    NRCELL-1:tddFrameStructure:tdLteUlDlConfig=tdLteConfig2
...    NRCELL-2:tddFrameStructure:frameStructureType=semiStatic
...    NRCELL-2:tddFrameStructure:ulDlDataSlotRatio=1/4
...    NRCELL-2:tddFrameStructure:guardPeriodLength=2Symbols
...    NRCELL-2:tddFrameStructure:tdLteUlDlConfig=tdLteConfig2
...    NRCELL-3:tddFrameStructure:frameStructureType=semiStatic
...    NRCELL-3:tddFrameStructure:ulDlDataSlotRatio=1/4
...    NRCELL-3:tddFrameStructure:guardPeriodLength=2Symbols
...    NRCELL-3:tddFrameStructure:tdLteUlDlConfig=tdLteConfig2
...    NRCELL-4:tddFrameStructure:frameStructureType=semiStatic
...    NRCELL-4:tddFrameStructure:ulDlDataSlotRatio=1/4
...    NRCELL-4:tddFrameStructure:guardPeriodLength=2Symbols
...    NRCELL-4:tddFrameStructure:tdLteUlDlConfig=tdLteConfig2
...    NRCELL-1:prachConfigurationIndex=98
...    NRCELL-2:prachConfigurationIndex=98
...    NRCELL-3:prachConfigurationIndex=98
...    NRCELL-4:prachConfigurationIndex=98

@{enableCDrx}
...    NRCELL-1:actCDrx=true
...    NRCELL-2:actCDrx=true
...    NRCELL-3:actCDrx=true
...    NRCELL-4:actCDrx=true
...    NRCELL-1:drxProfile1:drxInactivityTimer=20ms
...    NRCELL-1:drxProfile1:drxLongCycle=40ms
...    NRCELL-1:drxProfile1:drxOnDurationTimer=4ms
...    NRCELL-1:drxProfile1:drxRetransTimerDl=16slot
...    NRCELL-1:drxProfile1:drxRetransTimerUl=16slot
...    NRCELL-2:drxProfile1:drxInactivityTimer=20ms
...    NRCELL-2:drxProfile1:drxLongCycle=40ms
...    NRCELL-2:drxProfile1:drxOnDurationTimer=4ms
...    NRCELL-2:drxProfile1:drxRetransTimerDl=16slot
...    NRCELL-2:drxProfile1:drxRetransTimerUl=16slot
...    NRCELL-3:drxProfile1:drxInactivityTimer=20ms
...    NRCELL-3:drxProfile1:drxLongCycle=40ms
...    NRCELL-3:drxProfile1:drxOnDurationTimer=4ms
...    NRCELL-3:drxProfile1:drxRetransTimerDl=16slot
...    NRCELL-3:drxProfile1:drxRetransTimerUl=16slot
...    NRCELL-4:drxProfile1:drxInactivityTimer=20ms
...    NRCELL-4:drxProfile1:drxLongCycle=40ms
...    NRCELL-4:drxProfile1:drxOnDurationTimer=4ms
...    NRCELL-4:drxProfile1:drxRetransTimerDl=16slot
...    NRCELL-4:drxProfile1:drxRetransTimerUl=16slot

@{csiconfig}
...    NRCELL-2:actPciBasedCsiImRandomization=true
...    NRCELL-1:actCsirsMultiplexing=true
...    NRCELL-3:actCsirsMultiplexing=true

*** Keywords ***
