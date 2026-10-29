from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value("${tl}")
gNbId = tl.gnbs[0].instance_id

PARAMS_CB008830 = [
  "NRCELL-4:actBeamforming=true",
  "NRCELL-4:nrCellType=4DL4UL",
  "NRCELL-4:dlMimoMode=4x4 or 4x2 Closed Loop Spatial Multiplexing",
  "NRCELL-4:numberOfRxBeamforming=4Rx",
  "NRCELL-4:beamSet:basicBeamSet=beamSet_4",
  "NRBTS/NRCELLGRP-3:numberOfTransmittedSsBlocks=4 beams",
  "NRCELL-4:actCDrx=true",
  "NRCELL-4:dlDataDmrsFdm:actDlDataDmrsFdm=true",
  "NRCELL-4:dlDataDmrsFdm:dlDataDmrsFdmThres64QamLowSEMcs=20",
  "NRCELL-4:actPdschAtSsbSlots=true",
  "NRCELL-4:actAdaptiveReTxResMcs=true",
  "NRCELL-4:actDlLowPAPRoptimizedPrecoding=true",
  "NRCELL-4:actPdschRmCsirsForTracking=true",
  "NRCELL-4:actEnhancedPDSCHSchSplSlot=true",
  "NRCELL-4:actLAForHiReliab=false",
  "NRCELL-4:dlDmrsType=Type2",
  "NRCELL-4:dlDMRSAdditionalPosition=One additional DMRS",
  "NRCELL-4:minPctResourceReservedMcsDl=50",
  "NRCELL-4:minPctResourceReservedMcsUl=50",
  "NRCELL-4:targetPctResourceReservedMcsDl=75",
  "NRCELL-4:targetPctResourceReservedMcsUl=75",
  "NRCELL-4:actDl256Qam=true",
  "NRCELL-4:actDlMuMimo=false",
  "NRCELL-4:actDlMuMimoEnh=false",
  "NRCELL-4:actVoNR=true",
  "NRCELL-4:actEnhancedVoNR=true",
  "NRCELL-4:actAdaptVoipTbs=true",
  "NRCELL-4:actCDrxVoNR=true",
  "NRCELL-4:actVoipPacketAggr=true",
  "NRCELL-4:actGBRAdmissionControl=EnhancedVoNR"
]

Post_Config = [
  "NRCELL-4:actAdaptiveReTxResMcs=false",
  "NRCELL-4:actEnhancedPDSCHSchSplSlot=false",
  "NRCELL-4:dlDmrsType=Type1"
]
