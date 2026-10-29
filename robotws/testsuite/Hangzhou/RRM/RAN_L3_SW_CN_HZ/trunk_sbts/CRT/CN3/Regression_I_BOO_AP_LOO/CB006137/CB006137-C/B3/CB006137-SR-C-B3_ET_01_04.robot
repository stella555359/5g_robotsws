*** Settings ***
Suite Setup       Common Suite Setup And Setup IPHY Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    CRT    RAN_5G    RAN_5G_FDD    CLOUD_5G_I_BOO_AP_LOO
...    team-CN3ET    owner-taotao.hu    release-5G23R2    CB006137    CRT_no_clouds
Resource    ../../../../../../../resources/DevHZ5_resource.robot

*** Variables ***
${SOS_REPORT_STARTUP_1_FLAG}   pass:False,fail:True
${BTS_STARTUP_RETRY}    1
${SOS_REPORT_STARTUP_1_FLAG}   pass:True,fail:True
${GNB_CONFIG}    fddtdd_sansa_cmwv/6cells_4T2F
${SYSCOM_FLAG}    true
@{PARAMS_IN_SWCONFIG}
...    @{rdULCaEnablerPhase}
...    @{rdUseOptimizedDpaAlgo}
@{rdULCaEnablerPhase}
...    0x580591=0
@{rdUseOptimizedDpaAlgo}
...    0x58056B=1
@{PARAMS_IN_SCF}
...    @{CB006137}
...    @{CA}
...    @{NRREL}
...    @{Mobillity}
...    @{gscn_Arfcn}
...    @{Beamforming}
...    @{srsConfig}
...    @{FrameStructure}
...    @{BWP_config}
...    @{fix_relation_err}

@{fix_relation_err}
...    NRCELL-1:dftBeamDiffThresholdH=15
...    NRCELL-2:dftBeamDiffThresholdH=15
...    NRCELL-3:dftBeamDiffThresholdH=15
...    NRCELL-4:dftBeamDiffThresholdH=15

...    NRCELL-1:dftBeamDiffThresholdV=15
...    NRCELL-2:dftBeamDiffThresholdV=15
...    NRCELL-3:dftBeamDiffThresholdV=15
...    NRCELL-4:dftBeamDiffThresholdV=15

...    NRCELL-1:increasePUSCHPrepTimeULCA=true
...    NRCELL-2:increasePUSCHPrepTimeULCA=true
...    NRCELL-3:increasePUSCHPrepTimeULCA=true
...    NRCELL-4:increasePUSCHPrepTimeULCA=true

...    NRCELL-1:srsForBeamMgmt:srsPowerThresholdForUlBm=-132
...    NRCELL-2:srsForBeamMgmt:srsPowerThresholdForUlBm=-132
...    NRCELL-3:srsForBeamMgmt:srsPowerThresholdForUlBm=-132
...    NRCELL-4:srsForBeamMgmt:srsPowerThresholdForUlBm=-132


${Cell1_TDD_PCI}    50
${Cell2_TDD_PCI}    51
${Cell3_TDD_PCI}    52
#${Cell4_TDD_PCI}    53
#${Cell11_FDD_PCI}    60
#${Cell12_FDD_PCI}    61
${TDD_PRB_for_80M}    217
${TDD_PRB_for_70M}    189
${TDD_PRB_for_60M}    162

${Cell1_ssbFrequency}    632736
#${Cell2_ssbFrequency}    632736
#${Cell3_ssbFrequency}    508110
#${Cell4_ssbFrequency}    508110
${Cell12_ssbFrequency}    126750

${carrierAggregationSupportList}    SEPARATOR=
...    ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Any_Sa,ca_Fdd_Fdd,ca_Fr1Tdd_Any_Sa,
...    ca_Fdd_Fr1Tdd_Nsa,ca_Fdd_Fr1Tdd_Sa_WithUl,ca_Fr1Tdd_Nsa,ca_Fr1Tdd_Fdd_Nsa
@{CB006137}

...    NRBTS/NRDU-1:carrierAggregationSupportList=${carrierAggregationSupportList}
...    NRBTS/NRDU-1:dlToUlContributionRatio=50
...    NRBTS/NRDRB_RLC_AM-1:ulTReassemblyIBCA=40
...    NRBTS/NRDRB_RLC_AM-2:ulTReassemblyIBCA=40
...    NRBTS/NRDRB_RLC_AM-1:ulTReassembly=ms15
...    NRBTS/NRDRB_RLC_AM-2:ulTReassembly=ms15
...    NRCELL:maxNumScellsDlFr1=3
...    NRCELL:timingAdvanceOffset=n39936
...    NRCELL:weightForSCellSelection=50
...    NRCELL:actK1Opt=intra-gNB

@{gscn_Arfcn}
...    NRCELL-1:nrarfcn=633000
...    NRCELL-1:gscnOrSsPbchArfcn=7840
...    NRCELL-1:chBw=80MHz
...    NRCELL-2:nrarfcn=633000
...    NRCELL-2:gscnOrSsPbchArfcn=7840
...    NRCELL-2:chBw=80MHz
...    NRCELL-3:chBw=60MHz
...    NRCELL-4:chBw=60MHz
...    NRCELL-12/NRCELL_FDD-1:chBwDl=10MHz
...    NRCELL-12/NRCELL_FDD-1:chBwUl=10MHz
...    NRCELL-12:gscnOrSsPbchArfcn=1584
...    NRCELL-12:type0CoresetConfigurationIndex=0


@{Beamforming}
...    NRBTS:actChannelMapVal=ShowAsError
...    NRBTS:actFdmEnhancedScheduling=true
...    NRCELL-1:beamSet:nrBtsBeamRefinementP2=false
...    NRCELL-2:beamSet:nrBtsBeamRefinementP2=false
...    NRCELL-3:beamSet:nrBtsBeamRefinementP2=false
...    NRCELL-4:beamSet:nrBtsBeamRefinementP2=false
...    NRCELLGRP-0:numberOfTransmittedSsBlocks=4 beams
...    NRCELLGRP-1:numberOfTransmittedSsBlocks=4 beams
...    NRCELLGRP-2:numberOfTransmittedSsBlocks=2 beams
...    NRCELLGRP-3:numberOfTransmittedSsBlocks=2 beams
...    NRCELL-1:beamSet:basicBeamSet=beamSet_4
...    NRCELL-2:beamSet:basicBeamSet=beamSet_4
...    NRCELL-3:beamSet:basicBeamSet=beamSet_2
...    NRCELL-4:beamSet:basicBeamSet=beamSet_2
...    NRCELL-1:numberOfRxBeamforming=4Rx
...    NRCELL-2:numberOfRxBeamforming=4Rx
...    NRCELL-3:numberOfRxBeamforming=2Rx
...    NRCELL-4:numberOfRxBeamforming=2Rx
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
...    NRCELL-1:nrCellType=8DL4UL
...    NRCELL-2:nrCellType=8DL4UL
...    NRCELL-3:nrCellType=4DL2UL
...    NRCELL-4:nrCellType=4DL2UL
...    NRCELL-1:beamSet:lowerEdgeAngle=120
...    NRCELL-1:beamSet:upperEdgeAngle=60
...    NRCELL-2:beamSet:lowerEdgeAngle=120
...    NRCELL-2:beamSet:upperEdgeAngle=60
...    NRCELL-3:beamSet:lowerEdgeAngle=120
...    NRCELL-3:beamSet:upperEdgeAngle=60
...    NRCELL-4:beamSet:lowerEdgeAngle=120
...    NRCELL-4:beamSet:upperEdgeAngle=60
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-2
#...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-2
#...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-2
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-1:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-2:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-3:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-4:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-5:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-6:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-7:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-8:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2/CHANNEL-1:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2/CHANNEL-2:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2/CHANNEL-3:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2/CHANNEL-4:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-1:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-2:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-3:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-4:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-7:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-8:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2/CHANNEL-1:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2/CHANNEL-2:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2/CHANNEL-3:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2/CHANNEL-4:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-1:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-2:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-3:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-4:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-5:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-6:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-7:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-8:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-2/CHANNEL-1:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-2/CHANNEL-2:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-2/CHANNEL-3:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-2/CHANNEL-4:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-1:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-2:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-3:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-4:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-7:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-8:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-2/CHANNEL-1:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-2/CHANNEL-2:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-2/CHANNEL-3:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-2/CHANNEL-4:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-1:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-2:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-3:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-4:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-5:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-6:direction=RX
#...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-7:direction=RX
#...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-8:direction=RX
#...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-2/CHANNEL-1:direction=TX
#...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-2/CHANNEL-2:direction=TX
#...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-2/CHANNEL-3:direction=TX
#...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-2/CHANNEL-4:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-1:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-2:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-3:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-4:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-3/PHYANT-1
#...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-7:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-3/PHYANT-1
#...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-8:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-3/PHYANT-1
#...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-2/CHANNEL-1:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-3/PHYANT-1
#...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-2/CHANNEL-2:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-3/PHYANT-1
#...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-2/CHANNEL-3:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-3/PHYANT-1
#...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-2/CHANNEL-4:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-1:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-2:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-3:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-4:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-5:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-6:direction=RX
#...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-7:direction=RX
#...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-8:direction=RX
#...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-2/CHANNEL-1:direction=TX
#...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-2/CHANNEL-2:direction=TX
#...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-2/CHANNEL-3:direction=TX
#...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-2/CHANNEL-4:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-1:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-2:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-3:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-4:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1
#...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-7:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1
#...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-8:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1
#...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-2/CHANNEL-1:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1
#...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-2/CHANNEL-2:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1
#...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-2/CHANNEL-3:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1
#...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-2/CHANNEL-4:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1
@{srsConfig}
...    NRCELL-1:actUlSrsBm=true
...    NRCELL-1:actDlSrsBm=true
...    NRCELL-2:actUlSrsBm=true
...    NRCELL-2:actDlSrsBm=true
...    NRCELL-3:actUlSrsBm=true
...    NRCELL-3:actDlSrsBm=true
...    NRCELL-4:actUlSrsBm=true
...    NRCELL-4:actDlSrsBm=true
...    NRCELL-1:srsForBeamMgmt:srsUePeriodicity=slots40
...    NRCELL-1:srsForBeamMgmt:cSRS=13
...    NRCELL-1:srsForBeamMgmt:bSRS=0
...    NRCELL-2:srsForBeamMgmt:srsUePeriodicity=slots40
...    NRCELL-2:srsForBeamMgmt:cSRS=13
...    NRCELL-2:srsForBeamMgmt:bSRS=0
...    NRCELL-3:srsForBeamMgmt:srsUePeriodicity=slots40
...    NRCELL-3:srsForBeamMgmt:cSRS=13
...    NRCELL-3:srsForBeamMgmt:bSRS=0
...    NRCELL-4:srsForBeamMgmt:srsUePeriodicity=slots40
...    NRCELL-4:srsForBeamMgmt:cSRS=13
...    NRCELL-4:srsForBeamMgmt:bSRS=0
...    NRCELL-1:srsForBeamMgmt:srsPowerThresholdForDlBm=-1200
...    NRCELL-2:srsForBeamMgmt:srsPowerThresholdForDlBm=-1200
...    NRCELL-3:srsForBeamMgmt:srsPowerThresholdForDlBm=-1200
...    NRCELL-4:srsForBeamMgmt:srsPowerThresholdForDlBm=-1200
...    NRCELL-1:srsForBeamMgmt:srsTypeAllocForDlBm=antenna switching or codebook
...    NRCELL-2:srsForBeamMgmt:srsTypeAllocForDlBm=antenna switching or codebook
...    NRCELL-3:srsForBeamMgmt:srsTypeAllocForDlBm=antenna switching or codebook
...    NRCELL-4:srsForBeamMgmt:srsTypeAllocForDlBm=antenna switching or codebook
...    NRCELL-1:ulPowerControlCommon:alphaSrs=alpha08
...    NRCELL-1:ulPowerControlCommon:p0NominalSrs=-106
...    NRCELL-2:ulPowerControlCommon:alphaSrs=alpha08
...    NRCELL-2:ulPowerControlCommon:p0NominalSrs=-106
...    NRCELL-3:ulPowerControlCommon:alphaSrs=alpha08
...    NRCELL-3:ulPowerControlCommon:p0NominalSrs=-106
...    NRCELL-4:ulPowerControlCommon:alphaSrs=alpha08
...    NRCELL-4:ulPowerControlCommon:p0NominalSrs=-106

@{FrameStructure}
...    NRCELL-1:tddFrameStructure:frameStructureType=tdLte
...    NRCELL-1:tddFrameStructure:lteToNrFrameShift=0ms
...    NRCELL-1:tddFrameStructure:tdLteUlDlConfig=tdLteConfig2
...    NRCELL-1:tddFrameStructure:ulDlDataSlotRatio=1/4
...    NRCELL-1:tddFrameStructure:guardPeriodLength=6Symbols

...    NRCELL-2:tddFrameStructure:frameStructureType=tdLte
...    NRCELL-2:tddFrameStructure:lteToNrFrameShift=3ms
...    NRCELL-2:tddFrameStructure:tdLteUlDlConfig=tdLteConfig2
...    NRCELL-2:tddFrameStructure:ulDlDataSlotRatio=1/4
...    NRCELL-2:tddFrameStructure:guardPeriodLength=6Symbols
...    NRCELL-2:prachConfigurationIndex=98

...    NRCELL-3:tddFrameStructure:frameStructureType=semiStatic
...    NRCELL-3:tddFrameStructure:ulDlDataSlotRatio=1/4
...    NRCELL-3:tddFrameStructure:guardPeriodLength=2Symbols
...    NRCELL-3:tddFrameStructure:lteToNrFrameShift=${EMPTY}
...    NRCELL-3:tddFrameStructure:tdLteUlDlConfig=${EMPTY}
...    NRCELL-3:prachConfigurationIndex=98

...    NRCELL-4:tddFrameStructure:frameStructureType=semiStatic
...    NRCELL-4:tddFrameStructure:ulDlDataSlotRatio=1/4
...    NRCELL-4:tddFrameStructure:guardPeriodLength=2Symbols
...    NRCELL-4:tddFrameStructure:lteToNrFrameShift=${EMPTY}
...    NRCELL-4:tddFrameStructure:tdLteUlDlConfig=${EMPTY}
...    NRCELL-4:prachConfigurationIndex=98

@{CA}
...    NRBTS/NRDU-1:actConnectedModeMobilityCA=true
...    NRBTS/NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS:actMeasBasedSCellAdditionNsa=true
...    NRBTS:actHoOptimizationCa=true
...    NRBTS:sCellActivationMethod=bufferBased
...    NRBTS:actBcsCheck=disabled
...    NRCELL:allowUnsuppBcOrBcs=accept unknown band combinations,accept unknown BCSs
...    NRCELL:a1MeasPCellSwitchEnabled=rsrp
...    NRCELL:a2MeasPCellSwitchEnabled=rsrp
...    NRCELL:a1MeasSCellAddEnabled=rsrp
...    NRCELL:a2MeasSCellRelEnabled=rsrp
...    NRCELL:a1MeasPCellSwitchSsbRsrp:a1TimeToTriggerPCellSwitchSsbRsrp=480ms
...    NRCELL:a1MeasPCellSwitchSsbRsrp:a1HysteresisPCellSwitchSsbRsrp=0
...    NRCELL:a1MeasPCellSwitchSsbRsrp:a1ThresholdPCellSwitchSsbRsrp=60
...    NRCELL:a2MeasPCellSwitchSsbRsrp:a2TimeToTriggerPCellSwitchSsbRsrp=480ms
...    NRCELL:a2MeasPCellSwitchSsbRsrp:a2HysteresisPCellSwitchSsbRsrp=0
...    NRCELL:a2MeasPCellSwitchSsbRsrp:a2ThresholdPCellSwitchSsbRsrp=40
...    NRCELL:a2MeasPCellSwitchSsbRsrp:pCellSwitchOffsetSsbRsrp=0
...    NRCELL:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=50
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=60
...    NRCELL:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0
...    NRCELL:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=2560ms
...    NRCELL:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=34
@{NRREL}
...    NRBTS:actSCellSwapFr1=a6BasedSa
...    NRCELL-12/NRREL-1:gNbId=1
...    NRCELL-12/NRREL-1:gNbIdLength=22
...    NRCELL-12/NRREL-1:lcrId=1
...    NRCELL-12/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-1:sCellOperationalMode=dlAndUl
...    NRCELL-12/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-1:sCellPrio=1
...    NRCELL-12/NRREL-2:gNbId=1
...    NRCELL-12/NRREL-2:gNbIdLength=22
...    NRCELL-12/NRREL-2:lcrId=2
...    NRCELL-12/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-2:sCellOperationalMode=dlAndUl
...    NRCELL-12/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-2:sCellPrio=2
...    NRCELL-12/NRREL-3:gNbId=1
...    NRCELL-12/NRREL-3:gNbIdLength=22
...    NRCELL-12/NRREL-3:lcrId=3
...    NRCELL-12/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-3:sCellOperationalMode=dlAndUl
...    NRCELL-12/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-3:sCellPrio=1
...    NRCELL-12/NRREL-4:gNbId=1
...    NRCELL-12/NRREL-4:gNbIdLength=22
...    NRCELL-12/NRREL-4:lcrId=4
...    NRCELL-12/NRREL-4:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-4:sCellOperationalMode=dlAndUl
...    NRCELL-12/NRREL-4:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-4:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-4:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-4:sCellPrio=2

...    NRCELL-12/NRREL-5:gNbId=1
...    NRCELL-12/NRREL-5:gNbIdLength=22
...    NRCELL-12/NRREL-5:lcrId=11
...    NRCELL-12/NRREL-5:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-5:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-5:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-5:gnbPlmn:mncLength=3

...    NRCELL-12/NRHOIF-1:a1BasedPCellSwitchEnabled=true
...    NRCELL-12/NRHOIF-1:a2BasedPCellSwitchEnabled=true
...    NRCELL-12/NRHOIF-1:a2BasedPCellSwitchPriority=1
...    NRCELL-12/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-12/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-12/NRHOIF-1:freqBandIndicatorNR=41
...    NRCELL-12/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-12/NRHOIF-1:ifhoSsbSmtcDuration=sf5
...    NRCELL-12/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf20
...    NRCELL-12/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-12/NRHOIF-1:ssbFrequency=508110
...    NRCELL-12/NRHOIF-1:thresholdPCellSwitchTargetRsrp=60
...    NRCELL-12/NRHOIF-1:thresholdPCellSwitchTargetRsrq=20
...    NRCELL-12/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms320
...    NRCELL-12/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=5
...    NRCELL-12/NRHOIF-2:a1BasedPCellSwitchEnabled=true
...    NRCELL-12/NRHOIF-2:a2BasedPCellSwitchEnabled=true
...    NRCELL-12/NRHOIF-2:a2BasedPCellSwitchPriority=1
...    NRCELL-12/NRHOIF-2:a3MeasEnabled=rsrp
...    NRCELL-12/NRHOIF-2:cellDepType=SA+NSA
...    NRCELL-12/NRHOIF-2:freqBandIndicatorNR=78
...    NRCELL-12/NRHOIF-2:ifhoSsbScs=30 KHz
...    NRCELL-12/NRHOIF-2:ifhoSsbSmtcDuration=sf5
...    NRCELL-12/NRHOIF-2:ifhoSsbSmtcPeriodicity=sf20
...    NRCELL-12/NRHOIF-2:ssBurstSetPeriod=20
...    NRCELL-12/NRHOIF-2:ssbFrequency=632736
...    NRCELL-12/NRHOIF-2:thresholdPCellSwitchTargetRsrp=60
...    NRCELL-12/NRHOIF-2:thresholdPCellSwitchTargetRsrq=20
...    NRCELL-12/NRHOIF-2:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms320
...    NRCELL-12/NRHOIF-2:a3MeasSsbRsrp:a3OffsetSsbRsrp=5
@{Mobillity}
...    NRBTS/NRPMRNL-1:miNrRelReportCu=5min
...    NRBTS/NRPMRNL-1:miNrMobilityReport=5min
...    NRBTS:actInterFreqHoSA=true
...    NRBTS:actInterFreqInterGnbMobilityNSA=true
...    NRBTS:actInterFreqIntraGnbMobilityNSA=true
...    NRBTS:actInterMeNBMobility=true
...    NRBTS:actIntraFreqHoSA=true
...    NRBTS:actIntraMeNBMobility=true
...    NRBTS:timerXnDataFwdGuard=250
...    NRBTS:cipherPrefL:nea0=9
...    NRBTS:cipherPrefL:nea2_128=0
...    NRBTS:cipherPrefL:nea1_128=0
...    NRBTS:cipherPrefL:nea3_128=8
...    NRCELL:a3MeasEnabled=rsrp
...    NRCELL:absThreshSsbRsrpConsolidation=1
...    NRCELL:sMeasConfigSsbRsrp=1
...    NRCELL:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms512
...    NRCELL:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL:a3MeasSsbRsrp:a3OffsetSsbRsrp=5
...    NRCELL:a1MeashoEnabledSA=rsrp
...    NRCELL:a2MeashoEnabledSA=rsrp
...    NRCELL:measGapSelectionSA=favourUeThroughput
...    NRCELL:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRCELL:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=60
...    NRCELL:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0
...    NRCELL:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=34
...    NRCELL:a1MeashoSsbRsrpSA:a1TimeToTriggerHoSsbRsrpVoNr=${EMPTY}
...    NRCELL:a1MeashoSsbRsrpSA:a1ThresholdHoSsbRsrpVoNr=${EMPTY}
...    NRCELL:a1MeashoSsbRsrpSA:a1HysteresisHoSsbRsrpVoNr=${EMPTY}
...    NRCELL:a2MeashoSsbRsrpSA:a2HysteresisHoSsbRsrpVoNr=${EMPTY}
...    NRCELL:a2MeashoSsbRsrpSA:a2ThresholdHoSsbRsrpVoNr=${EMPTY}
...    NRCELL:a2MeashoSsbRsrpSA:a2TimeToTriggerHoSsbRsrpVoNr=${EMPTY}
...    NRCELL-1:a6MeasSCellSwapEnabled=rsrp
...    NRCELL-1:reportAmountA6MeasSCellSwap=infinity    #infinity
...    NRCELL-1:reportIntervalA6MeasSCellSwap=ms120
...    NRCELL-1:thresholdSCellSwapSourceRsrp=66
...    NRCELL-1:thresholdSCellSwapSourceRsrq=67
...    NRCELL-1:a6MeasSCellSwapSsbRsrp:a6HysteresisSCellSwapSsbRsrp=0|a6OffsetSCellSwapSsbRsrp=6|a6TimeToTrigSCellSwapSsbRsrp=ms480
...    NRCELL-1:a6MeasSCellSwapSsbRsrq:a6HysteresisSCellSwapSsbRsrq=0|a6OffsetSCellSwapSsbRsrq=6|a6TimeToTrigSCellSwapSsbRsrq=ms480
...    NRCELL-2:a6MeasSCellSwapEnabled=rsrp
...    NRCELL-2:reportAmountA6MeasSCellSwap=infinity
...    NRCELL-2:reportIntervalA6MeasSCellSwap=ms120
...    NRCELL-2:thresholdSCellSwapSourceRsrp=66
...    NRCELL-2:thresholdSCellSwapSourceRsrq=67
...    NRCELL-2:a6MeasSCellSwapSsbRsrp:a6HysteresisSCellSwapSsbRsrp=0|a6OffsetSCellSwapSsbRsrp=6|a6TimeToTrigSCellSwapSsbRsrp=ms480
...    NRCELL-2:a6MeasSCellSwapSsbRsrq:a6HysteresisSCellSwapSsbRsrq=0|a6OffsetSCellSwapSsbRsrq=6|a6TimeToTrigSCellSwapSsbRsrq=ms480
...    NRCELL-3:a6MeasSCellSwapEnabled=rsrp
...    NRCELL-3:reportAmountA6MeasSCellSwap=r4
...    NRCELL-3:reportIntervalA6MeasSCellSwap=ms120
...    NRCELL-3:thresholdSCellSwapSourceRsrp=66
...    NRCELL-3:thresholdSCellSwapSourceRsrq=67
...    NRCELL-3:a6MeasSCellSwapSsbRsrp:a6HysteresisSCellSwapSsbRsrp=0|a6OffsetSCellSwapSsbRsrp=20|a6TimeToTrigSCellSwapSsbRsrp=ms480
...    NRCELL-3:a6MeasSCellSwapSsbRsrq:a6HysteresisSCellSwapSsbRsrq=0|a6OffsetSCellSwapSsbRsrq=20|a6TimeToTrigSCellSwapSsbRsrq=ms480
...    NRCELL-4:a6MeasSCellSwapEnabled=rsrp
...    NRCELL-4:reportAmountA6MeasSCellSwap=r4
...    NRCELL-4:reportIntervalA6MeasSCellSwap=ms120
...    NRCELL-4:thresholdSCellSwapSourceRsrp=66
...    NRCELL-4:thresholdSCellSwapSourceRsrq=67
...    NRCELL-4:a6MeasSCellSwapSsbRsrp:a6HysteresisSCellSwapSsbRsrp=0|a6OffsetSCellSwapSsbRsrp=20|a6TimeToTrigSCellSwapSsbRsrp=ms480
...    NRCELL-4:a6MeasSCellSwapSsbRsrq:a6HysteresisSCellSwapSsbRsrq=0|a6OffsetSCellSwapSsbRsrq=20|a6TimeToTrigSCellSwapSsbRsrq=ms480

@{BWP_config}
...    NRBTS:actMultipleDedicatedBWPs=true
...    NRCELL:actEnhMultipleDedicatedBWPs=true
...    NRBTS/BWP_PROFILE-52:bwpType=dedicated
...    NRBTS/BWP_PROFILE-52:locationAndBandwidthDl:cRbSizeDl=n189
...    NRBTS/BWP_PROFILE-52:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-52:locationAndBandwidthUl:cRbSizeUl=sameAsDl
...    NRBTS/BWP_PROFILE-52:locationAndBandwidthUl:cRbStartUl=sameAsDl
...    NRBTS/BWP_PROFILE-52/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-52/PDCCH-1:dciDedicatedAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-52/PDCCH-1:dciPagingAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-52/PDCCH-1:dciRaCompletionAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-52/PDCCH-1:dciRaMsg2AggregationLevel=AL4
...    NRBTS/BWP_PROFILE-52/PDCCH-1:dciSiAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-52/PDCCH-1:downgradeAL16toAL8=notAllowed
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=9|searchSpaceId=9
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=9
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|searchSpaceId=9
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=9
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=4|searchSpaceId=9
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=10
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=10
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n4|searchSpaceId=10
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=10
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=10
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=9|searchSpaceId=11
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=11
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|searchSpaceId=11
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=11
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=4|searchSpaceId=11
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cceToRegMapping=nonInterleaved
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:coresetId=4
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cRbStart=0
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:duration=1
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:interleaverSize=none
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:regBundleSize=n6
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=120
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-0-And-1-0|coresetId=0
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|coresetId=0
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=0
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=0
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=0
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=0
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n4|coresetId=0
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=0
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|coresetId=0
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=12|coresetId=0
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|coresetId=0
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=0
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|coresetId=4
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|coresetId=4
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=4
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=4
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=4
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=4
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n5|coresetId=4
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=4
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|coresetId=4
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=13|coresetId=4
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|coresetId=4
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=4
...    NRBTS/BWP_PROFILE-52/PDSCH-1:pdschRat0RbgConfig=config1
...    NRCELL-1:cellBwpList:cellBwpId=2|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-52
...    NRCELL-1:cellBwpList:cellBwpId=0|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-5
...    NRCELL-1:cellBwpList:cellBwpId=1|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-54
...    NRCELL-2:cellBwpList:cellBwpId=2|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-52
...    NRCELL-2:cellBwpList:cellBwpId=0|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-5
...    NRCELL-2:cellBwpList:cellBwpId=1|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-54

@{config_pmaxforcell}
...    NRCELL-1:pMaxNROwnCell=23
...    NRCELL-2:pMaxNROwnCell=30
...    NRCELL-12:pMaxNROwnCell=20

${N71DLUL_N41DLUL_N78DLUL}    SEPARATOR=
...    E9A09000575F5A13160003C320016093170019C3D09009B20C39F30C7942C0E098040623807DC6C28C0D608C21A08107482406D6C98AB1A1CF88E3D
...    033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E007FE00098000702A0D883AC1184341020F10480CAD931562439F604F88E3C62471E439
...    F51CF9863CA1607038784FEC000003FB000000260001C0AA3626EB04610D04083A412030B64C55110E7C471E238F40CFB027C639F30C7942C0E070F
...    05C00FFC007003FF0004C0003815C7C46D608C21A08107CA090155B262AC2873E238F180000000000000000000003C04FFF800003FFE00000260001
...    C00178B850001C46000E268000010B010200E0234028809B01043D001C021000140467A09801E00140E0A00E0601280380030120020301F04801000
...    000008000010040000000200000401000004008000030040000200200001401000802008020000180100000E0080040000001000010008000090040
...    00018020000280100001600800409024010000180672A6B2A6B052B052B066B056B296B266B016B036B012B022B07681A0800004B29202000032CA4
...    80800014B29202000072CA480800024B292020000B2CA480800034B292020000F2CA480800044B29202000132CA480800054B29202000172CA48080
...    0064B29202000062CA480669545D2A8AA55174AA2A82C55058AA0D154A62A93455018AA051549A2A83C5090178095028140A05028140A05028140A0
...    5028140A050281400182020180300801002201002004040300601002004402004008080600C02018030404030060100C018402004008080600C0201
...    8000804030060100C018040300618080600C02018030080100402004010D50F8000810182030385058606880889098A0C0C8D8E0E8F909293139414
...    951697A0A0C1680

${N71DLUL_N41DLUL_N78DLUL_70M}    SEPARATOR=
...    E9A09000575F5A13160003C320016093170019C3D09009B20C39F30C7942C0E098040623807DC6C28C0D608C21A08107482406D6C98AB1A1CF88E3D
...    033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E007FE00098000702A0D883AC1184341020F10480CAD931562439F604F88E3C62471E439
...    F51CF9863CA1607038784FEC000003FB000000260001C0AA3626EB04610D04083A412030B64C55110E7C471E238F40CFB027C639F30C7942C0E070F
...    05C00FF8007003FF0004C8003800D9400014000015C7C46D608C21A08107CA090155B262AC2873E238F180000000000000000000003C04FFF800003
...    FFE00000260001C00178B850001C46000E268000010B010200E0234028809B01043D001C021000140467A09801E00140E0A00E06012803800301200
...    20301F04801000000008000010040000000200000401000004008000030040000200200001401000802008020000180100000E00800400000010000
...    1000800009004000018020000280100001600800409024010000180672A6B2A6B052B052B066B056B296B266B016B036B012B022B07681A0800004B
...    29202000032CA480800014B29202000072CA480800024B292020000B2CA480800034B292020000F2CA480800044B29202000132CA480800054B2920
...    2000172CA480800064B29202000062CA480669545D2A8AA55174AA2A82C55058AA0D154A62A93455018AA051549A2A83C5090178095028140A05028
...    140A05028140A05028140A050281400182020180300801002201002004040300601002004402004008080600C02018030404030060100C018402004
...    008080600C02018000804030060100C018040300618080600C02018030080100402004010D50F8000810182030385058606880889098A0C0C8D8E0E
...    8F909293139414951697A0A0C1680

${N71DLUL_N41DLUL_N78DLUL_and_N71DLUL_N41DL_N78DL}    SEPARATOR=
...    E9A09000575F5A13160003C320016093170019C3D09009B20C39F30C7942C0E098040623807DC6C28C0D608C21A08107482406D6C98AB1A1CF88E3D
...    033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E007FE00098000702A0D883AC1184341020F10480CAD931562439F604F88E3C62471E439
...    F51CF9863CA1607038784FEC000003FB000000260001C0AA3626EB04610D04083A412030B64C55110E7C471E238F40CFB027C639F30C7942C0E070F
...    05C00FFC007003FF0004C0003815C7C46D608C21A08107CA090155B262AC2873E238F180000000000000000000003C04FFF800003FFE00000260001
...    C00278B850001C46000E268000010B0102F160A00E230006134000216020401C0468051013602087A005808200200003810C60F413003C00281C140
...    1C0C02500700060240040603E0900200000001000002008000000040000080200000801000006008000040040000280200100401004000030020000
...    1C010008000000200002001000012008000030040000500200002C01000812048020000300CE54D654D60A560A560CD60AD652D64CD602D606D6025
...    604560ED0341000009652404000065949010000296524040000E594901000049652404000165949010000696524040001E594901000089652404000
...    265949010000A96524040002E5949010000C96524040000C594900CD2A8BA55154AA2E95455058AA0B1541A2A94C55268AA031540A2A93455078A12
...    02F012A05028140A05028140A05028140A05028140A0502800304040300601002004402004008080600C02004008804008010100C01804030060808
...    0600C02018030804008010100C018040300010080600C02018030080600C30100C01804030060100200804008021AA1F000102030406070A0B0C0D1
...    01112131418191B1C1D1F2125262728292A2D2F414182D0

${N71DLUL_N78DLUL_SRS}    SEPARATOR=
...    E1A2538057E0220082000F7A03560003C3A800B010880002000600409063D011EC00F04C990E7C8B5E82AF6097A067D813E078F11C7840040
...    6024C5C00670F42400C4834026010188E01F51B0A303582308682041D20D80516CAA2A121CFA067D813E31CF9863CA1607038780210000030
...    80A090500B8002F800E000BE000B10C06CA0000A0000001480180AA3E236B04610D04083C41B0092D954541439F40CF8C73E618F28581C0E1
...    E00420000061014120A027F0000001FC0000001601802900301546C4DD608C21A0810748360145B2A8A84873E819F604F8C73E618F28581C0
...    E1E008400000C2028241402E000B60038002D8002C03005200602A8F883AC1184341020F106C024B65515050E7D033E31CF9863CA16070387
...    801080000184050482809FD0000007F4000000584600C100A400C000A83C4D000E230000073907005011A014404D154001E01850276CB5E38
...    0A0233D05A807C006000E0000020280301804A00C000C07C06004000000020000040100000400800400000010008020080200100002004000
...    01807CA9AC0CBCA5AC08A0182000000360208000080D8002000040000008000180000007A55574AA2A81455038A1680EC035038140A070281
...    C000D084200134018800000402000001008000004020000010002440200400808020000200800080400801010060000401000000804002101
...    00200404028000808060020200800080C008028010040601C01C010040300400201C000804008020100600004010040808010040200802040
...    403002010040102020080200802000058B80A0300A5101003318
#CA_n71a*_n78a*,supportedSRS-TxPortSwitch t1r2 for n78a

@{COUNTER_CHECK_case4}
...    NRCELL-12:NCAC:${RRC_RECONF_ADD1ULSCELL_ATT_SA}=1
...    NRCELL-12:NCAC:${RRC_RECONF_ADD1ULSCELL_SUCC_SA}=1
...    NRCELL-12:NCAC:${UE_PCELL_1_CONF_SCELL_UL_SA}>1
...    NRCELL-1:NCAC:${UE_SCELL_1_CONF_SCELL_UL_SA}>1
...    NRCELL-2:NCAC:${UE_SCELL_1_CONF_SCELL_UL_SA}>1
...    NRCELL-12:NCAC:${SCELL_SWAP_1_ATT_SA}=2
...    NRCELL-12:NCAC:${SCELL_SWAP_1_SUCC_SA}=2
...    last NRCELL-12:CUCM:${MAX_UE_PCEL_1_CONF_SCEL_UL_SA}=1

${UE_PCELL_1_CONF_SCELL_UL_SA}    M55118C10005
${UE_SCELL_1_CONF_SCELL_UL_SA}    M55118C10006
${MAX_UE_PCEL_1_CONF_SCEL_UL_SA}    M55156C10007
${SCELL_SWAP_1_ATT_SA}    M55118C10501
${SCELL_SWAP_1_SUCC_SA}    M55118C10502
${RRC_RECONF_ADD1ULSCELL_ATT_SA}    M55118C10001
${RRC_RECONF_ADD1ULSCELL_SUCC_SA}    M55118C10002

*** Test Cases ***
CB006137-SR-C-B3_ET_01_01_Verify Scell swap with UL CA when swapped scell with UL CA configured and verify pmax
    [Documentation]
    ...    GNB configuration
    ...    cell-1: band78 CHBW=80M NRARFCN=633000 PCI=50 icrid=1 scellprio=1
    ...    cell-2: band78 CHBW=80M NRARFCN=633000 PCI=51 icrid=2 scellprio=2
    ...    cell-3: band41 CHBW=60M NRARFCN=508020 PCI=52 icrid=3 scellprio=1
    ...    cell-4: band41 CHBW=60M NRARFCN=508020 PCI=53 icrid=4 scellprio=2
    ...    cell-11: band71 CHBW=10M PCI=60 icrid=11
    ...    cell-12: band71 CHBW=20M PCI=61 icrid=12
    ...    for TDD cell-1 and cell-2 large(80M) and small(70M) BWP configed
    ...    actMultipleDedicatedBWPs=true actEnhMultipleDedicatedBWPs=true for pcell and scell
    ...    step1: register UE to FDD cell-12 and setup PDU
    ...    step2: UE report A1 for F+T+T 3CC scell addition and check pmax
    ...           scell-1: TDD cel-1 as DL&UL scell
    ...           scell-2: TDD cel-3 as DLonly scell
    ...    step3: UE report A6 for scell-1 for scell swap and check pmax
    ...           scell-1: released
    ...           scell-3: TDD cel-2 as DL&UL scell addition
    ...    step4: UE report A6 for scell-3 for scell swap
    ...           scell-3: released
    ...           scell-1: TDD cel-1 as DL&UL scell addition back
    ...    UE-2 is the same with UE-1 with band78 only support 70M
    [Tags]    TC01
    delta commission parameters    ${config_pmaxforcell}
    Attach UE and trigger UL scell swap    ue_id=1    ue_capa=${N71DLUL_N41DLUL_N78DLUL_and_N71DLUL_N41DL_N78DL}
    Attach UE and trigger UL scell swap    ue_id=2    ue_capa=${N71DLUL_N41DLUL_N78DLUL_70M}
    check rrc log    ${CURDIR}${/}A2A_case1${/}a2a_01.ini
    Check Wireshark Log    ${CURDIR}${/}A2A_case1${/}a2a_01.ini    wait_string=UEContextReleaseComplete::8

CB006137-SR-C-B3_ET_04_01_Periodic codebook SRS and antennaSwitching SRS resources configure when Scell swap with UL CA
    [Documentation]
    ...    precondition:
    ...    for TDD cell-1: frameStructureType=5GC001116(0ms)
    ...    for TDD cell-2: frameStructureType=5GC001116(3ms)
    ...    DL SRS and UL SRS and beamforming is enabled for TDD cells and SRS periodic is slot40
    ...    step1: register UE to FDD cell-12 and setup PDU
    ...    step2: UE report A1 for F+T+T 3CC scell addition and check periodic SRS config
    ...           scell-1: TDD cel-1 as DL&UL scell
    ...           scell-2: TDD cel-3 as DLonly scell
    ...           CSI-report on Pcell pucch(periodic=slot160): pcell(slot5) scell-1(slot6, slot7) scell-2(slot8, slot9)
    ...           SRS config on TDD cell-1 need 3 slots(1 slot for codebook and two slots for antennaSwitch): slot3, slot23, slot33
    ...           slot 13 is conflict with PCELL pucch which used by UE self for CSI-report and not used for SRS
    ...    step3: UE report A6 for scell-1 for scell swap and check periodic SRS config
    ...           scell-1: released
    ...           scell-3: TDD cel-2 as DL&UL scell addition
    ...           CSI-report on Pcell pucch(periodic=slot160): pcell(slot5) scell-1(slot6, slot7) scell-2(slot8, slot9),scell-3(slot10,slot11)
    ...           SRS config on TDD cell-2 need 3 slots(1 slot for codebook and two slots for antennaSwitch): slot7, slot27, slot37
    ...           slot 17 is conflict with PCELL pucch which used by UE self for CSI-report and not used for SRS
    ...    step4: UE report A6 for scell-3 for scell swap
    ...           scell-3: released
    ...           scell-1: TDD cel-2 as DL&UL scell addition back
    [Tags]    TC04
    Cell Lock and Unlock
    Clear Counter Files
    Attach UE and swap UL scell for 2CC
    check rrc log    ${CURDIR}${/}A2A_case4${/}a2a_01.ini
    Check Counters     ${COUNTER_CHECK_case4}
    Release UEs    ue_type=sa    ue_id=1

*** Keywords ***
Common Suite Setup And Setup IPHY Env
    Common Suite Setup
    Setup Airphone Env    tl_type=${GNB_CONFIG}
	
Modify Cfg
    Update Cfg    cell_srs_beam_pos_nr profile_id=1 num_of_ue_positions=4 azimuth=-45,30,25,60
    Update Cfg    cell_testmode_set_nr cell_id=1 gnb=2 testmode=cell_srs_beam_pos profile_id=1 action=activate
    Update Cfg    cell_testmode_set_nr cell_id=2 gnb=2 testmode=cell_srs_beam_pos profile_id=1 action=activate
    Update Cfg    cell_testmode_set_nr cell_id=3 gnb=2 testmode=cell_srs_beam_pos profile_id=1 action=activate
    Update Cfg    cell_testmode_set_nr cell_id=4 gnb=2 testmode=cell_srs_beam_pos profile_id=1 action=activate

Attach UE and swap UL scell for 2CC
    Start rrc log    UE_1
    Ue with specified capabilitiy Register And Pdu Session Setup At FDD Cell-12    ue_id=1    ue_capa=${N71DLUL_N78DLUL_SRS}
    Trigger Scell Addition Via A1 and 1TDD scell added    ue_id=1
    Trigger UL scell swap from TDD cell-1 to cell-2 for 2CC    ue_id=1    scell_id=1    scell_phy_id=${Cell2_TDD_PCI}
    Trigger UL scell swap from TDD cell-2 to cell-1    ue_id=1    scell_id=2    scell_phy_id=${Cell1_TDD_PCI}
    Get rrc log

Attach UE and trigger UL scell swap
    [Arguments]    ${ue_id}    ${ue_capa}
    Start rrc log    UE_${ue_id}
    Ue with specified capabilitiy Register And Pdu Session Setup At FDD Cell-12    ue_id=${ue_id}    ue_capa=${ue_capa}
    Trigger Scell Addition Via A1 and 2TDD scell added    ue_id=${ue_id}
    Trigger UL scell swap from TDD cell-1 to cell-2 for 3CC    ue_id=${ue_id}    scell_id=1    scell_phy_id=${Cell2_TDD_PCI}
    Trigger UL scell swap from TDD cell-2 to cell-1    ue_id=${ue_id}    scell_id=3    scell_phy_id=${Cell1_TDD_PCI}
    Get rrc log
    Release UEs    ue_type=sa    ue_id=${ue_id}

Ue with specified capabilitiy Register And Pdu Session Setup At FDD Cell-12
    [Arguments]    ${ue_id}    ${ue_capa}
    Execute Egate Command    ue_location_change id=${ue_id} enb=2 cell=12
    Execute Egate Command    ue_register id=${ue_id} ue_nr_capabilities=${ue_capa}    pass_regexp=UE now in NG RM Registere
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=${ue_id} nwslice=1    pass_regexp=QoS Routing Table

Cell Lock and Unlock
    Lock Cell1
    Lock Cell2
    Unlock Cell1
    Unlock Cell2
    Cells Should Be Onair    1

Trigger Scell Addition Via A1 and 2TDD scell added
    [Arguments]    ${ue_id}=1
    ${measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${Cell12_ssbFrequency}    event_type=A1
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${measid} event=A1 srsrp_nr=120 ssinr_nr=59 srsrq_nr=32
    ...    pass_regexp=rrcReconfigurationComplete
    Should Contain    ${ret1}    pcid:${Cell3_TDD_PCI}, scellIdx:2
    Should Contain    ${ret1}    pcid:${Cell1_TDD_PCI}, scellIdx:1

Trigger Scell Addition Via A1 and 1TDD scell added
    [Arguments]    ${ue_id}=1
    ${measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${Cell12_ssbFrequency}    event_type=A1
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${measid} event=A1 srsrp_nr=120 ssinr_nr=59 srsrq_nr=32
    ...    pass_regexp=rrcReconfigurationComplete
    Should Contain    ${ret1}    pcid:${Cell1_TDD_PCI}, scellIdx:1

Trigger UL scell swap from TDD cell-1 to cell-2 for 3CC
    [Arguments]    ${ue_id}    ${scell_id}    ${scell_phy_id}
    ${measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${Cell1_ssbFrequency}    event_type=A6
    ${V_1}    catenate
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${measid} event=A6 srsrp_nr=11 srsrq_nr=11 scell=${scell_id} 
    ...    scell_rsrp=20 scell_rsrq=20 phycell_id=${scell_phy_id} nrsrp_nr=63 nrsrq_nr=20
    ${ret1}=    Execute Egate Command    ${V_1}    pass_regexp=rrcReconfigurationComplete
    Should Contain    ${ret1}    pcid:${Cell2_TDD_PCI}, scellIdx:3

Trigger UL scell swap from TDD cell-1 to cell-2 for 2CC
    [Arguments]    ${ue_id}    ${scell_id}    ${scell_phy_id}
    ${measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${Cell1_ssbFrequency}    event_type=A6
    ${V_1}    catenate
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${measid} event=A6 srsrp_nr=11 srsrq_nr=11 scell=${scell_id} 
    ...    scell_rsrp=20 scell_rsrq=20 phycell_id=${scell_phy_id} nrsrp_nr=63 nrsrq_nr=20
    ${ret1}=    Execute Egate Command    ${V_1}    pass_regexp=rrcReconfigurationComplete
    Should Contain    ${ret1}    pcid:${Cell2_TDD_PCI}, scellIdx:2

Trigger UL scell swap from TDD cell-2 to cell-1
    [Arguments]    ${ue_id}    ${scell_id}    ${scell_phy_id}
    ${measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${Cell1_ssbFrequency}    event_type=A6
    ${V_1}    catenate
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${measid} event=A6 srsrp_nr=11 srsrq_nr=11 scell=${scell_id} 
    ...    scell_rsrp=20 scell_rsrq=20 phycell_id=${scell_phy_id} nrsrp_nr=63 nrsrq_nr=20
    ${ret1}=    Execute Egate Command    ${V_1}    pass_regexp=rrcReconfigurationComplete
    Should Contain    ${ret1}    pcid:${Cell1_TDD_PCI}, scellIdx:1
