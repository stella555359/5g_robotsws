*** Settings ***
Documentation
...    author: Chen Dandan
...    contact: dandan.chen@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup    Common Suite Setup And Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/8cells_4T4F_2N78_2N41_2N66_N71_N25
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_VRF    SBTS00    RAN_5G    RAN_5G_TDD    CLOUD_5G_I_BOO_AP_LOO
...    team-PZ3_7    owner-dandchen    release-5G25R3    CB012631
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG8/resources/DevHZ5_resource_ET.robot

*** Variables ***
${ue_info1}    uec=1 release=17 red_cap=true idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
${ue_info2}    nea=null+zuc+aes+snow3g nia=null+zuc+aes+snow3g sec_key=0102030405060708090A0B0C0D0EFF00

@{PARAMS_IN_SCF}
...    @{PARAMS_FOR_beamforming}
...    @{PARAMS_FOR_NRCELL1}
...    @{PARAMS_FOR_NRCELL2}
...    NRCELL-1:fPdcchMonOccsnPo=6
...    NRCELL-2:fPdcchMonOccsnPo=6
...    NRCELL-3:fPdcchMonOccsnPo=6
...    NRCELL-4:fPdcchMonOccsnPo=6
...    NRCELL-1:msg1FrequencyStart=13
...    NRCELL-2:msg1FrequencyStart=13
...    NRCELL-3:msg1FrequencyStart=13
...    NRCELL-4:msg1FrequencyStart=13
...    @{CB012631_para}
#TDD initailBWP add dedicated pdcch
...    NRCELL-2:ueConnectionEstablishmentMode=useInitialBwp
...    NRBTS/BWP_PROFILE-3:locationAndBandwidthDl:cRbSizeDl=allRb
...    NRBTS/BWP_PROFILE-3:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cceToRegMapping=nonInterleaved
...    NRBTS/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:coresetId=1
...    NRBTS/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cRbStart=0
...    NRBTS/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:duration=1
...    NRBTS/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:interleaverSize=none
...    NRBTS/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:regBundleSize=n6
...    NRBTS/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=96
...    NRBTS/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-0-And-1-0|coresetId=0
...    NRBTS/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|coresetId=0
...    NRBTS/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=0
...    NRBTS/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=0
...    NRBTS/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=0
...    NRBTS/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=0
...    NRBTS/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|coresetId=0
...    NRBTS/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=0
...    NRBTS/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|coresetId=0
...    NRBTS/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=9|coresetId=0
...    NRBTS/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|coresetId=0
...    NRBTS/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=0
...    NRBTS/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|coresetId=1
...    NRBTS/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|coresetId=1
...    NRBTS/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=1
...    NRBTS/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=1
...    NRBTS/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=1
...    NRBTS/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=1
...    NRBTS/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n4|coresetId=1
...    NRBTS/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=1
...    NRBTS/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|coresetId=1
...    NRBTS/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=10|coresetId=1
...    NRBTS/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|coresetId=1
...    NRBTS/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=1
#FDD initailBWP add dedicated pdcch
...    NRCELL-11:ueConnectionEstablishmentMode=useInitialBwp
...    NRBTS/BWP_PROFILE-1:locationAndBandwidthDl:cRbSizeDl=allRb
...    NRBTS/BWP_PROFILE-1:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=0|dciFormat=formats0-0-And-1-0
...    NRBTS/BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|dciFormat=formats0-0-And-1-0
...    NRBTS/BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|dciFormat=formats0-0-And-1-0
...    NRBTS/BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|dciFormat=formats0-0-And-1-0
...    NRBTS/BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|dciFormat=formats0-0-And-1-0
...    NRBTS/BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|dciFormat=formats0-0-And-1-0
...    NRBTS/BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|dciFormat=formats0-0-And-1-0
...    NRBTS/BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|dciFormat=formats0-0-And-1-0
...    NRBTS/BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|dciFormat=formats0-0-And-1-0
...    NRBTS/BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=9|dciFormat=formats0-0-And-1-0
...    NRBTS/BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|dciFormat=formats0-0-And-1-0
...    NRBTS/BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|dciFormat=formats0-0-And-1-0
...    NRBTS/BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=0|dciFormat=formats0-1-And-1-1
...    NRBTS/BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|dciFormat=formats0-1-And-1-1
...    NRBTS/BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|dciFormat=formats0-1-And-1-1
...    NRBTS/BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|dciFormat=formats0-1-And-1-1
...    NRBTS/BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|dciFormat=formats0-1-And-1-1
...    NRBTS/BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|dciFormat=formats0-1-And-1-1
...    NRBTS/BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|dciFormat=formats0-1-And-1-1
...    NRBTS/BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|dciFormat=formats0-1-And-1-1
...    NRBTS/BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|dciFormat=formats0-1-And-1-1
...    NRBTS/BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=10|dciFormat=formats0-1-And-1-1
...    NRBTS/BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|dciFormat=formats0-1-And-1-1
...    NRBTS/BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|dciFormat=formats0-1-And-1-1
...    NRCELL:actRedCapUeSupport=true
...    NRCELL:maxNumOfRrcSARedCap=20
...    NRCELL:cellBarredRedCap=no barring

@{CB012631_para}
...    NRBTS-1:sssgSwitching:cqiThreshold=8
...    NRBTS-1:sssgSwitching:dlBufferEmptyRatioFromSparseSssg=40
...    NRBTS-1:sssgSwitching:dlBufferEmptyRatioToSparseSssg=90
...    NRBTS-1:sssgSwitching:dlRateThresholdFromSparseSssg=35
...    NRBTS-1:sssgSwitching:dlRateThresholdToSparseSssg=30
...    NRBTS-1:sssgSwitching:measurementDurationFromSparseSssg=40
...    NRBTS-1:sssgSwitching:measurementDurationToSparseSssg=160
...    NRBTS-1:sssgSwitching:ulBufferEmptyRatioFromSparseSssg=40
...    NRBTS-1:sssgSwitching:ulBufferEmptyRatioToSparseSssg=90
...    NRBTS-1:sssgSwitching:ulRateThresholdNoVoNRFromSparseSssg=10
...    NRBTS-1:sssgSwitching:ulRateThresholdNoVoNRToSparseSssg=5
...    NRBTS-1:sssgSwitching:ulRateThresholdVoNRFromSparseSssg=35
...    NRBTS-1:sssgSwitching:ulRateThresholdVoNRToSparseSssg=30

...    NRBTS-1:sssgSwitchingRedCap:cqiThreshold=8
...    NRBTS-1:sssgSwitchingRedCap:dlBufferEmptyRatioFromSparseSssg=40
...    NRBTS-1:sssgSwitchingRedCap:dlBufferEmptyRatioToSparseSssg=90
...    NRBTS-1:sssgSwitchingRedCap:dlRateThresholdFromSparseSssg=35
...    NRBTS-1:sssgSwitchingRedCap:dlRateThresholdToSparseSssg=30
...    NRBTS-1:sssgSwitchingRedCap:measurementDurationFromSparseSssg=40
...    NRBTS-1:sssgSwitchingRedCap:measurementDurationToSparseSssg=160
...    NRBTS-1:sssgSwitchingRedCap:ulBufferEmptyRatioFromSparseSssg=40
...    NRBTS-1:sssgSwitchingRedCap:ulBufferEmptyRatioToSparseSssg=90
...    NRBTS-1:sssgSwitchingRedCap:ulRateThresholdFromSparseSssg=10
...    NRBTS-1:sssgSwitchingRedCap:ulRateThresholdToSparseSssg=5

@{PARAMS_IN_SWCONFIG}
...    0x58057A=3    0x580582=0x20000

#0x580582=0xA0000 17 19

@{actSssgSwitching_embb}
...    NRCELL-2:actSssgSwitching=eMBB UEs

@{actSssgSwitching_embb_all}
...    NRCELL:actSssgSwitching=eMBB UEs

@{actSssgSwitching_disabled}
...    NRCELL-2:actSssgSwitching=disabled

@{nrcell_11_actSssgSwitching_disabled}
...    NRCELL-11:actSssgSwitching=disabled

@{actSssgSwitching_embb_redcap}
...    NRCELL-2:actSssgSwitching=eMBB and RedCap UEs

@{nrcell_11_actSssgSwitching_embb_redcap}
...    NRCELL-11:actSssgSwitching=eMBB and RedCap UEs

@{nrcell_11_actSssgSwitching_redcap}
...    NRCELL-11:actSssgSwitching=RedCap UEs

@{ueConnectionEstablishmentMode_usededicated}
...    NRCELL-2:ueConnectionEstablishmentMode=useDedicatedBwp
...    NRCELL-11:ueConnectionEstablishmentMode=useDedicatedBwp


@{PARAMS_FOR_beamforming}
...    NRCELL-1:beamSet:basicBeamSet=beamSet_2
...    NRCELL-2:beamSet:basicBeamSet=beamSet_2
...    NRCELL-3:beamSet:basicBeamSet=beamSet_2
...    NRCELL-4:beamSet:basicBeamSet=beamSet_2
...    NRCELLGRP-0:numberOfTransmittedSsBlocks=2 beams
...    NRCELLGRP-2:numberOfTransmittedSsBlocks=2 beams
...    NRCELLGRP-6:numberOfTransmittedSsBlocks=2 beams
...    NRCELLGRP-7:numberOfTransmittedSsBlocks=2 beams
...    NRCELL:pucchF3ModulationScheme=pi2bpsk

@{PARAMS_FOR_NRCELL1}
...    NRCELL-1:maxNumScellsDlFr1=4
...    NRCELL-1/NRREL-14:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-14:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-14:gNbId=1
...    NRCELL-1/NRREL-14:gNbIdLength=22
...    NRCELL-1/NRREL-14:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-14:handoverAllowedSARedCap=forbidden
...    NRCELL-1/NRREL-14:lcrId=14
...    NRCELL-1/NRREL-14:nrDcAllowed=false
...    NRCELL-1/NRREL-14:removeNotAllowed=false
...    NRCELL-1/NRREL-14:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-14:sCellOperationalMode=dlAndUl
...    NRCELL-1/NRREL-14:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-14:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-14:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-14:isRplCellForPSCell=true
...    NRCELL-1/NRREL-2:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-11:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-12:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-13:sCellAdditionMethod=blind
...    NRCELL:actOptimizedFlowControl=optimizedAllUe

@{PARAMS_FOR_NRCELL2}
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-1:gNbId=1
...    NRCELL-2/NRREL-1:gNbIdLength=22
...    NRCELL-2/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-1:handoverAllowedSARedCap=forbidden
...    NRCELL-2/NRREL-1:lcrId=1
...    NRCELL-2/NRREL-1:nrDcAllowed=false
...    NRCELL-2/NRREL-1:removeNotAllowed=false
...    NRCELL-2/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-2/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-2/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-1:isRplCellForPSCell=true
...    NRCELL-2/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-3:gNbId=1
...    NRCELL-2/NRREL-3:gNbIdLength=22
...    NRCELL-2/NRREL-3:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-3:handoverAllowedSARedCap=forbidden
...    NRCELL-2/NRREL-3:lcrId=3
...    NRCELL-2/NRREL-3:nrDcAllowed=false
...    NRCELL-2/NRREL-3:removeNotAllowed=false
...    NRCELL-2/NRREL-3:sCellAdditionMethod=blind
...    NRCELL-2/NRREL-3:sCellOperationalMode=dlOnly
...    NRCELL-2/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-3:isRplCellForPSCell=true
...    NRCELL-2/NRREL-11:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-11:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-11:gNbId=1
...    NRCELL-2/NRREL-11:gNbIdLength=22
...    NRCELL-2/NRREL-11:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-11:handoverAllowedSARedCap=forbidden
...    NRCELL-2/NRREL-11:lcrId=11
...    NRCELL-2/NRREL-11:nrDcAllowed=false
...    NRCELL-2/NRREL-11:removeNotAllowed=false
...    NRCELL-2/NRREL-11:sCellAdditionMethod=blind
...    NRCELL-2/NRREL-11:sCellOperationalMode=dlOnly
...    NRCELL-2/NRREL-11:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-11:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-11:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-11:isRplCellForPSCell=true
...    NRCELL-2/NRREL-12:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-12:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-12:gNbId=1
...    NRCELL-2/NRREL-12:gNbIdLength=22
...    NRCELL-2/NRREL-12:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-12:handoverAllowedSARedCap=forbidden
...    NRCELL-2/NRREL-12:lcrId=12
...    NRCELL-2/NRREL-12:nrDcAllowed=false
...    NRCELL-2/NRREL-12:removeNotAllowed=false
...    NRCELL-2/NRREL-12:sCellAdditionMethod=blind
...    NRCELL-2/NRREL-12:sCellOperationalMode=dlOnly
...    NRCELL-2/NRREL-12:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-12:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-12:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-12:isRplCellForPSCell=true
...    NRCELL-2/NRREL-13:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-13:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-13:gNbId=1
...    NRCELL-2/NRREL-13:gNbIdLength=22
...    NRCELL-2/NRREL-13:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-13:handoverAllowedSARedCap=forbidden
...    NRCELL-2/NRREL-13:lcrId=13
...    NRCELL-2/NRREL-13:nrDcAllowed=false
...    NRCELL-2/NRREL-13:removeNotAllowed=false
...    NRCELL-2/NRREL-13:sCellAdditionMethod=blind
...    NRCELL-2/NRREL-13:sCellOperationalMode=dlAndUl
...    NRCELL-2/NRREL-13:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-13:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-13:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-13:isRplCellForPSCell=true

@{allcell_actSssgSwitching_embb_redcap}
...    NRCELL:actSssgSwitching=eMBB and RedCap UEs

${ue_capa_eMBB}    SEPARATOR=
...     FFA0F200475F7A6B5F8382086000D0017700400404820F990406902600C7FFE000503E0300C07012A1F851BF30342A08A5965440D00BDFF9
...     81C81B7FFDBFFEDFFF6FFFB7FFDBFFEDFFF3FFFD3FFEF8FCFC3FE3FFDBFFEDFFF6FFFB7FFDBFFEDFFF6FFFA8C026FF3FF6FF3FF16A020280
...     15B300078003300078000010001000000000000150FC41DF981A150452CB2A206805EFFCC0E40DBFFEDFFF6FFFB7FFDBFFEDFFF6FFF9FFFE
...     9FFF7C7E7E1FF1FFEDFFF6FFFB7FFDBFFEDFFF6FFFB7FFD460137F9FFB7F9FF8B50101400AD98003C00198003C0000080008000000000000
...     A87E26EFCC0D0A82296595103402F7FE607206DFFF6FFFB7FFDBFFEDFFF6FFFB7FFCFFFF4FFFBE3F3F0FF8FFF6FFFB7FFDBFFEDFFF6FFFB7
...     FFDBFFEA3009BFCFFDBFCFFC5A8080A0056CC001E000CC001E0000040004000000000000541F0637E606854114B2CA881A017BFF3039036F
...     FFB7FFDBFFEDFFF6FFFB7FFDBFFE7FFFA7FFDF1F9F87FC7FFB7FFDBFFEDFFF6FFFB7FFDBFFEDFFF51804DFE7FEDFE7FE2D40405002B66000
...     F00066000F00000200020000000000002A0F88DBF30342A08A5965440D00B5FF981C81B7FFDBFFEDFFF6FFFB7FFDBFFEDFFF3FFFD3FFEF8F
...     CFC3FE3FFBBFFEDFFF6FFFB7FFDBFFEDFFF518026FF3FF6FF3FF16A02028015B300078003300078000010001000000000000008A2F134003
...     89A001C28000E20800710400388C000000ADF8000000010389A000007F80000000A2F060003882001C41000E23000713400389A000008ADF
...     80000000513850001C41000E23000713400303800032B27800050062026C046174002F02409F81FEBDB813F03FD7B7027E07FAF6E041C0FF
...     5ED8090418C631FBFFFFF0BC00F800F000C0705807800703F09801E001806BB82C02C00380D770580580070200100000008004000000DE00
...     C88000001644000002A00B066F2A68064F000029659427800054B2CA1200004A5965490000352CB2A01A8345D2A8AA557541AE8065010040
...     0804010020100400804008010100200404008010008020065010020040400801010020040400801010040080401002004802005002006004
...     00C01002801000168250

${ue_capa_RedCap}    SEPARATOR=
...    FFA4F2004F0280C02FBD35AFC1C10430006800BB802002024107CC020248130063FFF000281F018060380550DC28DF981A158452CB2A20680
...     5EFFCC0E40DBFFEDFFF6FFFB7FFDBFFEDFFF6FFF9FFFE9FFF7C7E7E1FF1FFEDFFF6FFFB7FFDBFFEDFFF6FFFB7FFD4600DFE7FEDFE7FE2D40
...     405002B66000F00066000F00000200030000000000002A1B883BF30342B08A5965440D00BDFF981C81B7FFDBFFEDFFF6FFFB7FFDBFFEDFFF
...     3FFFD3FFEF8FCFC3FE3FFDBFFEDFFF6FFFB7FFDBFFEDFFF6FFFA8C01BFCFFDBFCFFC5A8080A0056CC001E000CC001E000004000600000000
...     000054371377E606856114B2CA881A017BFF3039036FFFB7FFDBFFEDFFF6FFFB7FFDBFFE7FFFA7FFDF1F9F87FC7FFB7FFDBFFEDFFF6FFFB7
...     FFDBFFEDFFF518037F9FFB7F9FF8B50101400AD98003C00198003C000008000C00000000000001507850001C4100000056F8400000000180
...     5101045D0004C031274E9F81FEBDB00140467EFFFFFC2F003E003C00301C1601E001C0FC26007800601AEE0B00B000E035DC16016001C080
...     0400000020010000003F80322000000591000000A802CA9BC0DA0093C0000A596509E000152CB2800B95417C0E0A17009E00F87C200C6200
...     FFE0780396595CB2CA80002020040080802004168A54A00001250200058

@{A002_A1}
...    NRCELL-2/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-11:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-12:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-13:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-2:maxNumScellsDlFr1=5
...    NRCELL-1:a2MeasSCellRelEnabled=rsrp
...    NRCELL-1:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=480ms
...    NRCELL-1:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=40|a2TimeToTriggerSCellRelSsbRsrp=480ms
...    NRCELL-2:pucchF3MaxCodeRate=zeroDot08
...    NRCELL-2:pucchF3ModulationScheme=pi2bpsk

@{A002_A1_Recover}
...    NRCELL-2/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-2/NRREL-11:sCellAdditionMethod=blind
...    NRCELL-2/NRREL-12:sCellAdditionMethod=blind
...    NRCELL-2/NRREL-13:sCellAdditionMethod=blind
...    NRCELL-2/NRREL-3:sCellAdditionMethod=blind
...    NRCELL-2:maxNumScellsDlFr1=4
...    NRCELL-2:pucchF3MaxCodeRate=zeroDot15
...    NRCELL-2:pucchF3ModulationScheme=qpsk_4psk

@{C003_A4}
...    NRBTS:actBufferBasedSCellAddition=oneShot_Dl_Fr1
...    NRBTS:actMeasBasedSCellAdditionSa=A4-based
...    NRCELL-2:dlSCellConfigLevel=1
...    NRCELL-2:dlSCellConfigLevelNum=1
...    NRCELL-2:maxNumScellsDlFr1=5
...    NRCELL-2:measGapSelectionSA=favourUeThroughput
...    NRCELL-2:a4PeriodicMeasControlSA:a4Fr1SupervisionTimer=6000
...    NRCELL-2:a4PeriodicMeasControlSA:a4MeasMaxNumber=8
...    NRCELL-2:a4PeriodicMeasControlSA:a4RetryTimer=5
...    NRCELL-2/NRHOIF-1:a4MeasSCellAddEnabled=rsrpCombined
...    NRCELL-2/NRHOIF-1:deriveSsbIndexFromCell=true
...    NRCELL-2/NRHOIF-1:freqBandIndicatorNR=78
...    NRCELL-2/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-2/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-2/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-2/NRHOIF-1:ssbFrequency=632736
...    NRCELL-2/NRHOIF-1:a4MeasEnDcSteeringSsbRsrp:a4TimeToTriggerEnDcSteeringSsbRsrp=ms0
...    NRCELL-2/NRHOIF-1:a4MeasNrDcSsbRsrp:a4HysteresisNrDcSsbRsrp=0
...    NRCELL-2/NRHOIF-1:a4MeasNrDcSsbRsrq:a4HysteresisNrDcSsbRsrq=0
...    NRCELL-2/NRHOIF-1:a4MeasSCellAddSsbRsrp:a4HysteresisSCellAddSsbRsrp=0
...    NRCELL-2/NRHOIF-1:a4MeasSCellAddSsbRsrq:a4HysteresisSCellAddSsbRsrq=0
...    NRCELL-2/NRHOIF-1:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-2/NRHOIF-1:a4MeasSsbRsrq:a4HysteresisSsbRsrq=0
...    NRCELL-2/NRHOIF-11:a4MeasSCellAddEnabled=rsrpCombined
...    NRCELL-2/NRHOIF-11:deriveSsbIndexFromCell=true
...    NRCELL-2/NRHOIF-11:freqBandIndicatorNR=66
...    NRCELL-2/NRHOIF-11:ifhoSsbSmtcDuration=sf1
...    NRCELL-2/NRHOIF-11:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-2/NRHOIF-11:ssbFrequency=423130
...    NRCELL-2/NRHOIF-11:a4MeasEnDcSteeringSsbRsrp:a4TimeToTriggerEnDcSteeringSsbRsrp=ms0
...    NRCELL-2/NRHOIF-11:a4MeasNrDcSsbRsrp:a4HysteresisNrDcSsbRsrp=0
...    NRCELL-2/NRHOIF-11:a4MeasNrDcSsbRsrq:a4HysteresisNrDcSsbRsrq=0
...    NRCELL-2/NRHOIF-11:a4MeasSCellAddSsbRsrp:a4HysteresisSCellAddSsbRsrp=0
...    NRCELL-2/NRHOIF-11:a4MeasSCellAddSsbRsrq:a4HysteresisSCellAddSsbRsrq=0
...    NRCELL-2/NRHOIF-11:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-2/NRHOIF-11:a4MeasSsbRsrq:a4HysteresisSsbRsrq=0
...    NRCELL-2/NRHOIF-12:a4MeasSCellAddEnabled=rsrpCombined
...    NRCELL-2/NRHOIF-12:deriveSsbIndexFromCell=true
...    NRCELL-2/NRHOIF-12:freqBandIndicatorNR=71
...    NRCELL-2/NRHOIF-12:ifhoSsbSmtcDuration=sf1
...    NRCELL-2/NRHOIF-12:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-2/NRHOIF-12:ssbFrequency=127450
...    NRCELL-2/NRHOIF-12:a4MeasEnDcSteeringSsbRsrp:a4TimeToTriggerEnDcSteeringSsbRsrp=ms0
...    NRCELL-2/NRHOIF-12:a4MeasNrDcSsbRsrp:a4HysteresisNrDcSsbRsrp=0
...    NRCELL-2/NRHOIF-12:a4MeasNrDcSsbRsrq:a4HysteresisNrDcSsbRsrq=0
...    NRCELL-2/NRHOIF-12:a4MeasSCellAddSsbRsrp:a4HysteresisSCellAddSsbRsrp=0
...    NRCELL-2/NRHOIF-12:a4MeasSCellAddSsbRsrq:a4HysteresisSCellAddSsbRsrq=0
...    NRCELL-2/NRHOIF-12:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-2/NRHOIF-12:a4MeasSsbRsrq:a4HysteresisSsbRsrq=0
...    NRCELL-2/NRHOIF-13:a4MeasSCellAddEnabled=rsrpCombined
...    NRCELL-2/NRHOIF-13:deriveSsbIndexFromCell=true
...    NRCELL-2/NRHOIF-13:freqBandIndicatorNR=66
...    NRCELL-2/NRHOIF-13:ifhoSsbSmtcDuration=sf1
...    NRCELL-2/NRHOIF-13:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-2/NRHOIF-13:ssbFrequency=427970
...    NRCELL-2/NRHOIF-13:a4MeasEnDcSteeringSsbRsrp:a4TimeToTriggerEnDcSteeringSsbRsrp=ms0
...    NRCELL-2/NRHOIF-13:a4MeasNrDcSsbRsrp:a4HysteresisNrDcSsbRsrp=0
...    NRCELL-2/NRHOIF-13:a4MeasNrDcSsbRsrq:a4HysteresisNrDcSsbRsrq=0
...    NRCELL-2/NRHOIF-13:a4MeasSCellAddSsbRsrp:a4HysteresisSCellAddSsbRsrp=0
...    NRCELL-2/NRHOIF-13:a4MeasSCellAddSsbRsrq:a4HysteresisSCellAddSsbRsrq=0
...    NRCELL-2/NRHOIF-13:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-2/NRHOIF-13:a4MeasSsbRsrq:a4HysteresisSsbRsrq=0
...    NRCELL-2/NRHOIF-3:a4MeasSCellAddEnabled=rsrpCombined
...    NRCELL-2/NRHOIF-3:deriveSsbIndexFromCell=true
...    NRCELL-2/NRHOIF-3:freqBandIndicatorNR=41
...    NRCELL-2/NRHOIF-3:ifhoSsbScs=30 KHz
...    NRCELL-2/NRHOIF-3:ifhoSsbSmtcDuration=sf1
...    NRCELL-2/NRHOIF-3:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-2/NRHOIF-3:ssbFrequency=508110
...    NRCELL-2/NRHOIF-3:a4MeasEnDcSteeringSsbRsrp:a4TimeToTriggerEnDcSteeringSsbRsrp=ms0
...    NRCELL-2/NRHOIF-3:a4MeasNrDcSsbRsrp:a4HysteresisNrDcSsbRsrp=0
...    NRCELL-2/NRHOIF-3:a4MeasNrDcSsbRsrq:a4HysteresisNrDcSsbRsrq=0
...    NRCELL-2/NRHOIF-3:a4MeasSCellAddSsbRsrp:a4HysteresisSCellAddSsbRsrp=0
...    NRCELL-2/NRHOIF-3:a4MeasSCellAddSsbRsrq:a4HysteresisSCellAddSsbRsrq=0
...    NRCELL-2/NRHOIF-3:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-2/NRHOIF-3:a4MeasSsbRsrq:a4HysteresisSsbRsrq=0
...    NRCELL-2/NRREL-1:sCellAdditionMethod=covBasedA4
...    NRCELL-2/NRREL-11:sCellAdditionMethod=covBasedA4
...    NRCELL-2/NRREL-12:sCellAdditionMethod=covBasedA4
...    NRCELL-2/NRREL-13:sCellAdditionMethod=covBasedA4
...    NRCELL-2/NRREL-3:sCellAdditionMethod=covBasedA4

@{C003_A4_Recover}
...    NRBTS:actBufferBasedSCellAddition=disabled
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRCELL-2:dlSCellConfigLevel=10
...    NRCELL-2:dlSCellConfigLevelNum=20
...    NRCELL-2:maxNumScellsDlFr1=4
...    NRCELL-2:measGapSelectionSA=${EMPTY}
...    NRCELL-2:a4PeriodicMeasControlSA=${EMPTY}
...    NRCELL-2/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-2/NRREL-11:sCellAdditionMethod=blind
...    NRCELL-2/NRREL-12:sCellAdditionMethod=blind
...    NRCELL-2/NRREL-13:sCellAdditionMethod=blind
...    NRCELL-2/NRREL-3:sCellAdditionMethod=blind
...    delete:NRCELL-2/NRHOIF-1
...    delete:NRCELL-2/NRHOIF-11
...    delete:NRCELL-2/NRHOIF-12
...    delete:NRCELL-2/NRHOIF-13
...    delete:NRCELL-2/NRHOIF-3

@{C006_CNI81817_Enable}
...    @{A002_A1}
...    NRBTS:actHighestEstNrTputBcSel=true
...    NRCELL:actDl256Qam=true
...    NRCELL:actUl256Qam=true

@{C006_Recover}
...    @{A002_A1_Recover}
...    NRBTS:actHighestEstNrTputBcSel=false
...    NRCELL:actDl256Qam=false
...    NRCELL:actUl256Qam=false
...    NRCELL-2/NRREL-13:sCellOperationalMode=dlAndUl

@{sssg_enable}
...    QoS Routing Table
...    searchSpaceId 39
...    monitoringSlotPeriodicityAndOffset sl4
...    searchSpaceId 38

@{nrcell_11_sssg_enable}
...    QoS Routing Table
...    searchSpaceId 39
...    monitoringSlotPeriodicityAndOffset sl4
...    searchSpaceId 38

@{sssg_disable}
...    QoS Routing Table

@{A002_6CC_expect_regexp}
...    pcid:51, scellIdx:0] configure_0_1
...    pcid:51, scellIdx:0] configure_1_1
...    pcid:50, scellIdx:1] configure_1_1
...    pcid:52, scellIdx:2] configure_1_1
...    pcid:60, scellIdx:3] configure_1_1
...    pcid:61, scellIdx:4] configure_1_1
...    pcid:62, scellIdx:5] configure_0_1
...    pcid:62, scellIdx:5] configure_1_1
...    SCellIndex 1 activated successfully at airphone
...    SCellIndex 2 activated successfully at airphone
...    SCellIndex 3 activated successfully at airphone
...    SCellIndex 4 activated successfully at airphone
...    SCellIndex 5 activated successfully at airphone
...    maxPayloadSize 24
...    maxCodeRate zeroDot25

${SSSG_SWITCH_ATT}    M55308C00142
${SSSG_SWITCH_SUCC}    M55308C00143
${SSSG_SWITCH_ATT_REDCAP}    M55308C00146
${SSSG_SWITCH_SUCC_REDCAP}    M55308C00147

${SLOTS_UE_DENSE_SSSG}    M55308C00144
${SLOTS_UE_SPARSE_SSSG}    M55308C00145
${SLOTS_UE_DENSE_SSSG_REDCAP}    M55308C00148
${SLOTS_UE_SPARSE_SSSG_REDCAP}    M55308C00149

@{PM_Counters_Check_US1}
...    NRCELL-2:NCELA:${SSSG_SWITCH_ATT}>0
...    NRCELL-2:NCELA:${SSSG_SWITCH_SUCC}>0
...    NRCELL-2:NCELA:${SSSG_SWITCH_ATT_REDCAP}=0
...    NRCELL-2:NCELA:${SSSG_SWITCH_SUCC_REDCAP}=0
...    NRCELL-2:NCELA:${SLOTS_UE_DENSE_SSSG}>0
...    NRCELL-2:NCELA:${SLOTS_UE_SPARSE_SSSG}>0
...    NRCELL-2:NCELA:${SLOTS_UE_DENSE_SSSG_REDCAP}=0
...    NRCELL-2:NCELA:${SLOTS_UE_SPARSE_SSSG_REDCAP}=0
@{PM_Counters_Check_US0}
...    NRCELL-2:NCELA:${SSSG_SWITCH_ATT}=0
...    NRCELL-2:NCELA:${SSSG_SWITCH_SUCC}=0
...    NRCELL-2:NCELA:${SSSG_SWITCH_ATT_REDCAP}=0
...    NRCELL-2:NCELA:${SSSG_SWITCH_SUCC_REDCAP}=0
...    NRCELL-2:NCELA:${SLOTS_UE_DENSE_SSSG}=0
...    NRCELL-2:NCELA:${SLOTS_UE_SPARSE_SSSG}=0
...    NRCELL-2:NCELA:${SLOTS_UE_DENSE_SSSG_REDCAP}=0
...    NRCELL-2:NCELA:${SLOTS_UE_SPARSE_SSSG_REDCAP}=0
@{PM_Counters_Check_nrcell_11}
...    NRCELL-11:NCELA:${SSSG_SWITCH_ATT}>0
...    NRCELL-11:NCELA:${SSSG_SWITCH_SUCC}>0
...    NRCELL-11:NCELA:${SSSG_SWITCH_ATT_REDCAP}>0
...    NRCELL-11:NCELA:${SSSG_SWITCH_SUCC_REDCAP}>0
...    NRCELL-11:NCELA:${SLOTS_UE_DENSE_SSSG}>0
...    NRCELL-11:NCELA:${SLOTS_UE_SPARSE_SSSG}>0
...    NRCELL-11:NCELA:${SLOTS_UE_DENSE_SSSG_REDCAP}>0
...    NRCELL-11:NCELA:${SLOTS_UE_SPARSE_SSSG_REDCAP}>0
@{PM_Counters_Check_nrcell_11_US0}
...    NRCELL-11:NCELA:${SSSG_SWITCH_ATT}=0
...    NRCELL-11:NCELA:${SSSG_SWITCH_SUCC}=0
...    NRCELL-11:NCELA:${SSSG_SWITCH_ATT_REDCAP}=0
...    NRCELL-11:NCELA:${SSSG_SWITCH_SUCC_REDCAP}=0
...    NRCELL-11:NCELA:${SLOTS_UE_DENSE_SSSG}>=0
...    NRCELL-11:NCELA:${SLOTS_UE_SPARSE_SSSG}=0
...    NRCELL-11:NCELA:${SLOTS_UE_DENSE_SSSG_REDCAP}=0
...    NRCELL-11:NCELA:${SLOTS_UE_SPARSE_SSSG_REDCAP}=0
@{PM_Counters_Check_nrcell_11_US2}
...    NRCELL-11:NCELA:${SSSG_SWITCH_ATT}=0
...    NRCELL-11:NCELA:${SSSG_SWITCH_SUCC}=0
...    NRCELL-11:NCELA:${SSSG_SWITCH_ATT_REDCAP}>0
...    NRCELL-11:NCELA:${SSSG_SWITCH_SUCC_REDCAP}>0
...    NRCELL-11:NCELA:${SLOTS_UE_DENSE_SSSG}=0
...    NRCELL-11:NCELA:${SLOTS_UE_SPARSE_SSSG}=0
...    NRCELL-11:NCELA:${SLOTS_UE_DENSE_SSSG_REDCAP}>0
...    NRCELL-11:NCELA:${SLOTS_UE_SPARSE_SSSG_REDCAP}>0
@{PM_Counters_Check_multiUE}
...    NRCELL-2:NCELA:${SSSG_SWITCH_ATT}>0
...    NRCELL-2:NCELA:${SSSG_SWITCH_SUCC}>0
...    NRCELL-2:NCELA:${SSSG_SWITCH_ATT_REDCAP}=0
...    NRCELL-2:NCELA:${SSSG_SWITCH_SUCC_REDCAP}=0
...    NRCELL-11:NCELA:${SSSG_SWITCH_ATT}=0
...    NRCELL-11:NCELA:${SSSG_SWITCH_SUCC}=0
...    NRCELL-11:NCELA:${SSSG_SWITCH_ATT_REDCAP}>0
...    NRCELL-11:NCELA:${SSSG_SWITCH_SUCC_REDCAP}>0
...    NRCELL-2:NCELA:${SLOTS_UE_DENSE_SSSG}>0
...    NRCELL-2:NCELA:${SLOTS_UE_SPARSE_SSSG}>0
...    NRCELL-2:NCELA:${SLOTS_UE_DENSE_SSSG_REDCAP}=0
...    NRCELL-2:NCELA:${SLOTS_UE_SPARSE_SSSG_REDCAP}=0
...    NRCELL-11:NCELA:${SLOTS_UE_DENSE_SSSG}=0
...    NRCELL-11:NCELA:${SLOTS_UE_SPARSE_SSSG}=0
...    NRCELL-11:NCELA:${SLOTS_UE_DENSE_SSSG_REDCAP}>0
...    NRCELL-11:NCELA:${SLOTS_UE_SPARSE_SSSG_REDCAP}>0
*** Test Cases ***
CB012631_no_smallBWP_configured_ue_attach
    [Documentation]
    ...    1. This user scenario describes the CB012631 testcase
    ...    3. Test Case Steps:
    ...           a. eMBB UE attach to nrcell-2
    ...              eMBB UE and RedCap UE attach nrcell-11
    ...              MultiUE attach
    ...           b. online ueConnectionEstablishmentMode_usededicated
    ...              do the same step of a
    [Tags]    001    CA_LABEL-3T3F(2_40M_TDD_n78+40M_TDD_n41+2_20M_FDD_n66+10M_FDD_n71)    owner-dandchen
    OnlineParamChange    ${C006_CNI81817_Enable}
    eMBB UE attach to nrcell-2
    eMBB UE and RedCap UE attach nrcell-11
    MultiUE attach
    OnlineParamChange    ${ueConnectionEstablishmentMode_usededicated}
    eMBB UE attach to nrcell-2
    eMBB UE and RedCap UE attach nrcell-11
    MultiUE attach

*** Keywords ***
eMBB UE attach to nrcell-2
    Clear Counter Files
    OnlineParamChange    ${actSssgSwitching_embb}
    one SA UE attach to nrcell-2    ue_id=1    pass_regexp=${sssg_enable}    ue_capa=${ue_capa_eMBB}
    Release ues    ue_type=all
    OnlineParamChange    ${actSssgSwitching_embb_redcap}
    one SA UE attach to nrcell-2    ue_id=1    pass_regexp=${sssg_enable}    ue_capa=${ue_capa_eMBB}
    Release ues    ue_type=all
    Check Counters    ${PM_Counters_Check_US1}
    OnlineParamChange    ${actSssgSwitching_disabled}
    Clear Counter Files
    one SA UE attach to nrcell sssg disable    ue_id=1    pass_regexp=${sssg_disable}
    Release ues    ue_type=all
    Check Counters    ${PM_Counters_Check_US0}
    OnlineParamChange    ${actSssgSwitching_embb}
    Clear Counter Files
    one SA UE attach to nrcell-2    ue_id=1    pass_regexp=${sssg_enable}    ue_capa=${ue_capa_eMBB}
    Release ues    ue_type=all
    Check Counters    ${PM_Counters_Check_US1}

eMBB UE and RedCap UE attach nrcell-11
    Clear Counter Files
    OnlineParamChange    ${nrcell_11_actSssgSwitching_embb_redcap}
    one SA UE attach to nrcell-11    ue_id=1    pass_regexp=${nrcell_11_sssg_enable}    ue_capa=${ue_capa_eMBB}
    one SA UE attach to nrcell-11    ue_id=11    pass_regexp=${nrcell_11_sssg_enable}    ue_capa=${ue_capa_RedCap}
    Release ues    ue_type=all
    Check Counters    ${PM_Counters_Check_nrcell_11}
    OnlineParamChange    ${nrcell_11_actSssgSwitching_disabled}
    Clear Counter Files
    one SA UE attach to nrcell sssg disable    ue_id=1    pass_regexp=${sssg_disable}    cell_id=11    ue_capa=${ue_capa_eMBB}
    one SA UE attach to nrcell sssg disable    ue_id=11    pass_regexp=${sssg_disable}    cell_id=11    ue_capa=${ue_capa_RedCap}
    Release ues    ue_type=all
    Check Counters    ${PM_Counters_Check_nrcell_11_US0}
    OnlineParamChange    ${nrcell_11_actSssgSwitching_redcap}
    Clear Counter Files
    one SA UE attach to nrcell-11    ue_id=11    pass_regexp=${nrcell_11_sssg_enable}    ue_capa=${ue_capa_RedCap}
    one SA UE attach to nrcell sssg disable    ue_id=1    pass_regexp=${sssg_disable}    cell_id=11    ue_capa=${ue_capa_eMBB}
    Release ues    ue_type=all
    Check Counters    ${PM_Counters_Check_nrcell_11_US2}
    OnlineParamChange    ${nrcell_11_actSssgSwitching_embb_redcap}
    Clear Counter Files
    one SA UE attach to nrcell-11    ue_id=1    pass_regexp=${nrcell_11_sssg_enable}    ue_capa=${ue_capa_eMBB}
    one SA UE attach to nrcell-11    ue_id=11    pass_regexp=${nrcell_11_sssg_enable}    ue_capa=${ue_capa_RedCap}
    Release ues    ue_type=all
    Check Counters    ${PM_Counters_Check_nrcell_11}

MultiUE attach
    Clear Counter Files
    FOR    ${i}    IN RANGE    1    11
        multi SA UE attach to nrcell-2    ue_id=${i}
    END
    FOR    ${i}    IN RANGE    1    11
        Execute Egate Command    ue_stats_nr id=${i} scell=0-7 type=pdsch    Throughput
    END
    FOR    ${i}    IN RANGE    11    21
        multi SA UE attach to nrcell-11    ue_id=${i}
    END
    Release ues    ue_type=all
    Check Counters    ${PM_Counters_Check_multiUE}

one SA UE attach to nrcell-2
    [Arguments]    ${ue_id}=1    ${pass_regexp}=${sssg_enable}    ${ue_capa}=${ue_capa_eMBB}
    SA UE attach Without Scell Addition    ue_id=${ue_id}    pass_regexp=${pass_regexp}    ue_capa=${ue_capa}
    Send A1 MR    ue_id=${ue_id}
    Check large Traffic and Release Scell Should Success    ue_id=${ue_id}

one SA UE attach to nrcell sssg disable
    [Arguments]    ${ue_id}=1    ${pass_regexp}=${sssg_disable}    ${cell_id}=2    ${ue_capa}=${ue_capa_eMBB}
    SA UE attach Without Scell Addition sssg disable    ue_id=${ue_id}    cell_id=${cell_id}    pass_regexp=${pass_regexp}    ue_capa_6cc=${ue_capa}
    Check large Traffic and Release Scell Should Success    ue_id=${ue_id}

multi SA UE attach to nrcell-2
    [Arguments]    ${ue_id}=1    ${pass_regexp}=${sssg_enable}
    SA UE attach Without Scell Addition    ue_id=${ue_id}    pass_regexp=${pass_regexp}    ue_capa=${ue_capa_eMBB}
    sleep    2s
    Send A1 MR    ue_id=${ue_id}
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=1 mbps=50    UE ${ue_id}: UDP DL
    sleep    5s
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pdsch    Throughput

multi SA UE attach to nrcell-11
    [Arguments]    ${ue_id}=1    ${pass_regexp}=${nrcell_11_sssg_enable}
    SA UE attach Without Scell Addition    ue_id=${ue_id}    cell_id=11    pass_regexp=${pass_regexp}    ue_capa=${ue_capa_RedCap}
    sleep    5s
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=1 mbps=5    UE ${ue_id}: UDP DL
    sleep    5s

one SA UE attach to nrcell-11
    [Arguments]    ${ue_id}=1    ${pass_regexp}=${nrcell_11_sssg_enable}    ${ue_capa}=${ue_capa_eMBB}
    SA UE attach Without Scell Addition    ue_id=${ue_id}    cell_id=11    pass_regexp=${pass_regexp}    ue_capa=${ue_capa}
    Check large Traffic and Release Scell Should Success    ue_id=${ue_id}

Modify Cfg
    Update Cfg    set_qosflow id=2 5qi=7
    Update Cfg    set_qosflow id=3 5qi=8
    Update Cfg    set_qosrule id=1 proto=tcp qos_flow=1
    Update Cfg    set_qosrule id=2 proto=udp qos_flow=2
    Update Cfg    set_nwslice id=1 snssai=0x01:0xD143A5 qos_flows=1,2,3 qos_rules=1,2 default=on ue=all amf=1
    Update Cfg    set_ue simulated id=11 ${ue_info1} ${ue_info2} suci=0:311:489:0000:0:0:021645411 enb=2 cell=1 mode=nr
    Update Cfg    set_ue simulated id=12 ${ue_info1} ${ue_info2} suci=0:311:489:0000:0:0:021645412 enb=2 cell=1 mode=nr
    Update Cfg    set_ue simulated id=13 ${ue_info1} ${ue_info2} suci=0:311:489:0000:0:0:021645413 enb=2 cell=1 mode=nr
    Update Cfg    set_ue simulated id=14 ${ue_info1} ${ue_info2} suci=0:311:489:0000:0:0:021645414 enb=2 cell=1 mode=nr
    Update Cfg    set_ue simulated id=15 ${ue_info1} ${ue_info2} suci=0:311:489:0000:0:0:021645415 enb=2 cell=1 mode=nr
    Update Cfg    set_ue simulated id=16 ${ue_info1} ${ue_info2} suci=0:311:489:0000:0:0:021645416 enb=2 cell=1 mode=nr
    Update Cfg    set_ue simulated id=17 ${ue_info1} ${ue_info2} suci=0:311:489:0000:0:0:021645417 enb=2 cell=1 mode=nr
    Update Cfg    set_ue simulated id=18 ${ue_info1} ${ue_info2} suci=0:311:489:0000:0:0:021645418 enb=2 cell=1 mode=nr
    Update Cfg    set_ue simulated id=19 ${ue_info1} ${ue_info2} suci=0:311:489:0000:0:0:021645419 enb=2 cell=1 mode=nr
    Update Cfg    set_ue simulated id=20 ${ue_info1} ${ue_info2} suci=0:311:489:0000:0:0:021645420 enb=2 cell=1 mode=nr

Set UE Capability
    [Arguments]    ${ue_id}=1    ${UE_Capabilities}=${ue_capa_eMBB}    ${wait_timer}=0.5
    Execute Egate Command    ue_param id=${ue_id} ue_nr_capabilities=${UE_Capabilities}    sleep_time=${wait_timer}

SA UE attach Without Scell Addition
    [Arguments]    ${ue_id}=1    ${cell_id}=2    ${pdu_id}=1    ${pass_regexp}=${sssg_enable}    ${ue_capa}=${ue_capa_eMBB}
    Set UE Capability    ue_id=${ue_id}    UE_Capabilities=${ue_capa}
    Execute Egate Command    ue_change_location id=${ue_id} cell=${cell_id} enb=2
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Registered state.
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup pdu=${pdu_id} gw=${pdu_id} ue=${ue_id} nwslice=1    pass_regexp=${pass_regexp}

SA UE attach Without Scell Addition sssg disable
    [Arguments]    ${ue_id}=1    ${cell_id}=2    ${pdu_id}=1    ${pass_regexp}=${sssg_disable}    ${ue_capa_6cc}=${ue_capa_eMBB}
    Set UE Capability    ue_id=${ue_id}    UE_Capabilities=${ue_capa_6cc}
    Execute Egate Command    ue_change_location id=${ue_id} cell=${cell_id} enb=2
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Registered state.
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    ${output}=    Execute Egate Command    ue_pdu_session_setup pdu=${pdu_id} gw=${pdu_id} ue=${ue_id} nwslice=1    pass_regexp=${pass_regexp}
    Should Not Contain    ${output}    monitoringSlotPeriodicityAndOffset sl4
    Should Not Contain    ${output}    searchSpaceId 39
    Should Not Contain    ${output}    searchSpaceId 38

Send A1 MR
    [Arguments]    ${ue_id}=1    ${carrierfreq}=635616    ${pass_regexp}=${A002_6CC_expect_regexp}
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A1
    ${cmd}    catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=127 srsrq_nr=127
    Execute Egate Command    ${cmd}    ${pass_regexp}
    sleep    5s

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be Onair    check_sib=${True}    timeout=600

Check Traffic
    [Arguments]    ${ue_id}=1    ${Tput_dl}=150    ${CC_num}=5
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pdsch    Throughput
    ${alldl_tput}    set variable    0
    FOR    ${scellid}    IN RANGE    0    ${CC_num}
        ${scellid}=    convert to string    ${scellid}
        ${cell_tput}    Get Scell Throughput    ${ue_id}    ${scellid}
        ${alldl_tput}    Evaluate    ${alldl_tput}+${cell_tput}
    END
    Should Be True    ${alldl_tput}/1000 > ${Tput_dl}

Get Scell Throughput
    [Arguments]    ${ue_id}=1    ${scell_id}=0
    [Return]    ${scell_tput}
    ${scell_tput}    Ap Get Throuput On Specific Scell     ue_id=${ue_id}    scell_id=${scell_id}    type=pdsch    rate_type=ave

Check large Traffic and Release Scell Should Success
    [Arguments]    ${ue_id}=1
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=1 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=2 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=3 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=4 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=ul trf_id=8 mbps=10    UE ${ue_id}: UDP UL
    sleep    5s
    Wait Until Keyword Succeeds    30s    5s    Check Traffic    ue_id=${ue_id}    Tput_dl=10    CC_num=1
    Execute Egate Command    data_trf_stop ue=${ue_id} pdu=1
    sleep    10s
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-5 type=pusch
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-5 type=pdsch
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=1 mbps=15    UE ${ue_id}: UDP DL
    sleep    5s
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-5 type=pdsch