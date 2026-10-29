*** Settings ***
Documentation
...    author: Susana Yan
...    contact: susana.yan@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_VRF    SBTS00    RAN_5G    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    team-SG07
...     owner-susana.yan    release-SBTS24R3    CB008830    CRT
Resource     ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${rdFeatureFlagBitmap5}    0x580580
@{PARAMS_IN_SWCONFIG}     ${rdFeatureFlagBitmap5}=32
${SYSCOM_FLAG}    ${True}
${SOS_REPORT_FLAG}    pass:False,fail:False
${AP_BIP_FLAG}    ${False}
${SNAPSHOT_FLAG}    pass:True,fail:True
${GNB_BIP_FLAG}    ${False}
@{PARAMS_IN_SCF}
...    NRCELL:nrofHARQProcessesForPDSCH=16
...    NRCELL:maxNumPdschAllocationPerSlot=16
...    NRPMRNL-1:miNrInterGnbMobilityNsaPmqap=disabled
...    NRPMRNL-1:miNrInterGnbXnMobilitySaPmqap=disabled
...    NRPMRNL-1:miNrIntraGnbMobilityNsaPmqap=disabled
...    NRPMRNL-1:miNrIntraGnbMobilitySaPmqap=disabled
...    NRPMRNL-1:miNrNgcFlexInterface=disabled
...    NRBTS:actFullPlmnList=true
...    @{8246_related_modification}
...    @{VONR}
...    @{IntragNB_HO_relate}
...    @{CB008830}
...    @{enableBeamforming}
...    @{BWPmodify}
...    @{RRE_config}

${NRCELL_1_Freq}    636576
${NRCELL_2_Freq}    639936

@{RRE_config}
...    NRBTS:rrcReestabTypeSA=sameGNB
...    NRBTS:actInterGnbRREPreparedCell=true
...    NRBTS:actGnbInitRlf=true

@{8246_related_modification}
...    NRBTS-1:cipherPrefL:nea0=8
...    NRBTS-1:cipherPrefL:nea1_128=0
...    NRBTS-1:cipherPrefL:nea2_128=0
...    NRBTS-1:cipherPrefL:nea3_128=0
...    NRCELL-1:cellDepType=SA
...    delete:NRCELL-1:configuredEpsTac
...    NRCELL:actLAForHiReliab=true
...    NRBTS-1/BWP_PROFILE-5/PDCCH-1:dciDedicatedAggregationLevelHR=AL4
...    NRBTS-1/BWP_PROFILE-54/PDCCH-1:dciDedicatedAggregationLevelHR=AL4
...    NRCELL:actCceSplit=false
...    NRCELL:puschHrLaConfig:iniDeltaSinrHR=-50
...    NRCELL:puschHrLaConfig:ullaDeltaSinrMaxHR=150
...    NRCELL:puschHrLaConfig:ullaDeltaSinrMinHR=-300
...    NRCELL:puschHrLaConfig:ullaDeltaSinrStepdownHR=20
...    NRCELL:puschHrLaConfig:ullaIniMcsHR=0
...    NRCELL:puschHrLaConfig:ullaMcsMax64qamLowSERANK1HR=25
...    NRCELL:puschHrLaConfig:ullaMcsMax64qamLowSERANK2HR=25
...    NRCELL:puschHrLaConfig:ullaMcsMax64qamRANK1HR=25
...    NRCELL:puschHrLaConfig:ullaMcsMax64qamRANK2HR=25
...    NRCELL:puschHrLaConfig:ullaSinrOffsetHR=20
...    NRCELL:pdschHrLaConfig:dllaCqiOffsetHR=20
...    NRCELL:pdschHrLaConfig:dllaDeltaCqiMaxHR=150
...    NRCELL:pdschHrLaConfig:dllaDeltaCqiMinHR=-150
...    NRCELL:pdschHrLaConfig:dllaDeltaCqiStepdownHR=20
...    NRCELL:pdschHrLaConfig:dllaIniDeltaCqiHR=-50
...    NRCELL:pdschHrLaConfig:dllaIniMcsHR=3
...    NRCELL:dlMcsDowngradeForHr=disabled
...    NRCELL:ulMcsDowngradeForHr=disabled
...    NRBTS/NRPDSCHHRLA-1:dlHRBlerOutageMcsThresh64qam=3
...    NRBTS/NRPDSCHHRLA-1:dlHRBlerOutageMcsThresh64qamLowSE=2
...    NRBTS/NRPDSCHHRLA-1:dlHRBlerOutagePercentage=50
...    NRBTS/NRPDSCHHRLA-1:dlHRBlerOutagePeriod=20
...    NRBTS/NRPDSCHHRLA-1:dlHRBlerRecoverMcsThresh64qam=5
...    NRBTS/NRPDSCHHRLA-1:dlHRBlerRecoverMcsThresh64qamLowSE=5
...    NRBTS/NRPDSCHHRLA-1:dlHRBlerRecoverPercentage=60
...    NRBTS/NRPDSCHHRLA-1:dlHRBlerRecoverPeriod=20
...    NRBTS/NRPDSCHHRLA-2:dlHRBlerOutageMcsThresh64qam=3
...    NRBTS/NRPDSCHHRLA-2:dlHRBlerOutageMcsThresh64qamLowSE=2
...    NRBTS/NRPDSCHHRLA-2:dlHRBlerOutagePercentage=50
...    NRBTS/NRPDSCHHRLA-2:dlHRBlerOutagePeriod=20
...    NRBTS/NRPDSCHHRLA-2:dlHRBlerRecoverMcsThresh64qam=5
...    NRBTS/NRPDSCHHRLA-2:dlHRBlerRecoverMcsThresh64qamLowSE=5
...    NRBTS/NRPDSCHHRLA-2:dlHRBlerRecoverPercentage=60
...    NRBTS/NRPDSCHHRLA-2:dlHRBlerRecoverPeriod=20
...    NRBTS/NRPUSCHHRLA-1:scalFactorForHRGbrUl=105
...    NRBTS/NRPUSCHHRLA-1:ullaBlerTargetHR=1
...    NRBTS/NRPUSCHHRLA-1:ulHRBlerOutagePercentage=50
...    NRBTS/NRPUSCHHRLA-1:ulHRBlerOutagePeriod=20
...    NRBTS/NRPUSCHHRLA-1:ulHRBlerOutageTbsThresh=808
...    NRBTS/NRPUSCHHRLA-1:ulHRBlerOutageTbsThresh64qam=1000
...    NRBTS/NRPUSCHHRLA-1:ulHRBlerRecoverPercentage=60
...    NRBTS/NRPUSCHHRLA-1:ulHRBlerRecoverPeriod=30
...    NRBTS/NRPUSCHHRLA-1:ulHRBlerRecoverTbsThresh=10000
...    NRBTS/NRPUSCHHRLA-1:ulHRBlerRecoverTbsThresh64qam=7000
...    NRBTS/NRPUSCHHRLA-2:scalFactorForHRGbrUl=200
...    NRBTS/NRPUSCHHRLA-2:ullaBlerTargetHR=6
...    NRBTS/NRPUSCHHRLA-2:ulHRBlerOutagePercentage=50
...    NRBTS/NRPUSCHHRLA-2:ulHRBlerOutagePeriod=20
...    NRBTS/NRPUSCHHRLA-2:ulHRBlerOutageTbsThresh=808
...    NRBTS/NRPUSCHHRLA-2:ulHRBlerOutageTbsThresh64qam=1000
...    NRBTS/NRPUSCHHRLA-2:ulHRBlerRecoverPercentage=60
...    NRBTS/NRPUSCHHRLA-2:ulHRBlerRecoverPeriod=30
...    NRBTS/NRPUSCHHRLA-2:ulHRBlerRecoverTbsThresh=10000
...    NRBTS/NRPUSCHHRLA-2:ulHRBlerRecoverTbsThresh64qam=7000
...    NRBTS-1/NRDRB-11:nrPdschHRLaDN=MRBTS-1/NRBTS-1/NRPDSCHHRLA-1
...    NRBTS-1/NRDRB-11:nrPuschHRLaDN=MRBTS-1/NRBTS-1/NRPUSCHHRLA-1
...    NRBTS-1/NRDRB-12:nrPdschHRLaDN=MRBTS-1/NRBTS-1/NRPDSCHHRLA-2
...    NRBTS-1/NRDRB-12:nrPuschHRLaDN=MRBTS-1/NRBTS-1/NRPUSCHHRLA-2
...    NRBTS/NRDU-1:carrierAggregationSupportList=none

@{VONR}
...    NRCELL:actVoNR=true
...    NRCELL:actEnhancedVoNR=true
...    NRCELL:actAdaptVoipTbs=true
...    NRCELL:actCDrxVoNR=true
...    NRCELL:actCDrx=true
...    NRCELL:srPeriodicity=slots80
...    NRCELL:periodicCsiAcquisition:csiReportPeriodicity=slots80
...    NRCELL:actVoipPacketAggr=true
...    NRDRX-2:drxInactivityTimer=6ms
...    NRDRX-2:drxLongCycle=40ms
...    NRDRX-2:drxOnDurationTimer=6ms
...    NRDRX-2:drxRetransTimerDl=0slot
...    NRDRX-2:drxRetransTimerUl=0slot
...    NRCELL:voNRNrDrxDN=MRBTS-1/NRBTS-1/NRDRX-2
...    NRDRX-4:drxInactivityTimer=20ms
...    NRDRX-4:drxLongCycle=40ms
...    NRDRX-4:drxOnDurationTimer=4ms
...    NRDRX-4:drxRetransTimerDl=16slot
...    NRDRX-4:drxRetransTimerUl=16slot
...    NRCELL:nonGbrNrDrxDN=MRBTS-1/NRBTS-1/NRDRX-4
...    @{PARAMS_FOR_5QI5}
...    @{PARAMS_FOR_5QI1}

@{PARAMS_FOR_5QI5}
...    NRBTS/NRDRB_5QI-1:fiveqiValueList=5
...    NRBTS/NRDRB_5QI-1:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-10
...    NRBTS/NRDRB-10:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-3
...    NRBTS/NRDRB-10:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-2
...    NRBTS/NRDRB-10:nrDrbRlcAmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_AM-2
...    NRBTS/NRDRB-10:resType=nonGBR_Signaling
...    NRBTS/NRDRB-10:rlcMode=RLC_AM
...    NRBTS/NRDRB_MAC-3:lcgid=0
...    NRBTS/NRDRB_MAC-3:schedulPrio=4

@{PARAMS_FOR_5QI1}
...    NRCELL:actVoNR=true
...    NRBTS:actNormVCFallback=false
...    NRBTS/NRDRB_5QI-6:fiveqiValueList=1
...    NRBTS/NRDRB_5QI-6:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-15
...    NRBTS/NRDRB-15:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-4
...    NRBTS/NRDRB-15:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-3
...    NRBTS/NRDRB-15:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRBTS/NRDRB-15:cellAggrLevel=Not FR1 CA eligible
...    NRBTS/NRDRB-15:dlFlowControlAlgo=none
...    NRBTS/NRDRB-15:dscp=46
...    NRBTS/NRDRB-15:queuingDelayDiscarding=Disabled
...    NRBTS/NRDRB-15:maxDddsPeriodCpuOvld=40
...    NRBTS/NRDRB-15:numSduDiscard=1
...    NRBTS/NRDRB-15:queuingDelaySduDiscardThreshold=200
...    NRBTS/NRDRB-15:resType=GBR
...    NRBTS/NRDRB-15:rlcMode=RLC_UM
...    NRBTS/NRDRB-15:schedulWeight=1
...    NRBTS/NRDRB-15:sduDiscardIntervalTmr=100
...    NRBTS/NRDRB-15:maxDataRateGbrDl=1000
...    NRBTS/NRDRB-15:maxDataRateGbrUl=1000
...    NRBTS/NRDRB_MAC-4:lcgid=4
...    NRBTS/NRDRB_MAC-4:schedulPrio=5
...    NRBTS/NRDRB_RLC_UM-1:dlTReassemblyUm=ms40
...    NRBTS/NRDRB_RLC_UM-1:ulTReassemblyUm=ms40
...    NRBTS/NRDRB_PDCP-3:tReorderingDl=ms300
...    NRBTS/NRDRB_PDCP-3:tReorderingUl=ms300
...    NRBTS/NRDRB_PDCP-3:pdcpBufDiscardEnabled=false
...    NRBTS/NRDRB-15:discardTimer=10ms
...    NRBTS/NRDRB-15:maxRlcQueueingDelayGbr=20
...    NRBTS/NRDRB-15:maxTransferDelayGbr=20
...    NRDRX-1:drxLongCycle=40ms

@{BWPmodify}
...    NRCELL:pdcchAutoConfig:cellCoverageLevel=normal
...    NRCELL:pdcchAutoConfig:initialBWPMode=sameAsCoreset0
...    NRCELL:pdcchAutoConfig:fineTuneMode=disabled
...    NRCELL:cellBwpList:actUpperThrAckNackHrFiltering=false|cellBwpId=0
...    NRCELL:cellBwpList:actUpperThrAckNackFiltering=false|cellBwpId=0
...    NRCELL:cellBwpList:actUpperThrAckNackHrFiltering=true|cellBwpId=1
...    NRCELL:cellBwpList:actUpperThrAckNackFiltering=true|cellBwpId=1
...    NRCELL:cellBwpList:bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-5|cellBwpId=0
...    NRCELL:cellBwpList:bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-54|cellBwpId=1

@{enableBeamforming}
...    NRCELL:actBeamforming=true
...    NRCELL:nrCellType=4DL4UL
...    NRCELL:dlMimoMode=4x4 or 4x2 Open Loop Spatial Multiplexing
...    NRCELL:numberOfRxBeamforming=4Rx
...    NRBTS:actFdmEnhancedScheduling=true
...    NRBTS-1/NRCELLGRP-0:numberOfTransmittedSsBlocks=4 beams
...    NRBTS-1/NRCELLGRP-1:numberOfTransmittedSsBlocks=4 beams
...    NRCELL:beamSet:basicBeamSet=beamSet_4
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-1:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-1:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-2:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-2:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-3:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-3:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-4:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-4:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-6:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-7:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-7:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-8:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-8:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-1:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-1:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-2:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-2:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-3:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-3:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-4:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-4:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-6:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-7:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-7:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-8:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-8:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1

@{IntragNB_HO_relate}
...    NRBTS:actInterFreqIntraGnbMobilityNSA=true
...    NRBTS:actIntraFreqIntraGnbMobilityNSA=true
...    NRBTS-1/NRCELL:absThreshSsbRsrpConsolidation=1
...    NRBTS-1/NRCELL:absThreshSsbRsrqConsolidation=1
...    NRBTS-1/NRCELL:sMeasConfigSsbRsrp=1
...    NRBTS-1/NRCELL-1/NRREL:cellIndividualSsbRsrpOffset=0dB
...    NRBTS-1/NRCELL-1/NRREL:cellIndividualSsbRsrqOffset=0dB
...    NRBTS-1/NRCELL-1/NRREL:gNbId=35
...    NRBTS-1/NRCELL-1/NRREL:gNbIdLength=22
...    NRBTS-1/NRCELL-1/NRREL:lcrId=2
...    NRBTS-1/NRCELL-1/NRREL:gnbPlmn:mcc=311
...    NRBTS-1/NRCELL-1/NRREL:gnbPlmn:mnc=489
...    NRBTS-1/NRCELL-1/NRREL:gnbPlmn:mncLength=3
...    NRBTS-1/NRCELL-2/NRREL:cellIndividualSsbRsrpOffset=0dB
...    NRBTS-1/NRCELL-2/NRREL:cellIndividualSsbRsrqOffset=0dB
...    NRBTS-1/NRCELL-2/NRREL:gNbId=35
...    NRBTS-1/NRCELL-2/NRREL:gNbIdLength=22
...    NRBTS-1/NRCELL-2/NRREL:lcrId=1
...    NRBTS-1/NRCELL-2/NRREL:gnbPlmn:mcc=311
...    NRBTS-1/NRCELL-2/NRREL:gnbPlmn:mnc=489
...    NRBTS-1/NRCELL-2/NRREL:gnbPlmn:mncLength=3
...    @{CELL1_NRHOIF}
...    @{CELL2_NRHOIF}
...    @{Inter_fre}

@{CELL1_NRHOIF}
...    NRBTS-1/NRCELL-1/NRHOIF-1:cellDepType=SA+NSA
...    NRBTS-1/NRCELL-1/NRHOIF-1:freqBandIndicatorNR=78
...    NRBTS-1/NRCELL-1/NRHOIF-1:ifhoSsbScs=15KHz
...    NRBTS-1/NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRBTS-1/NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRBTS-1/NRCELL-1/NRHOIF-1:numberOfTransmittedSsBlocks=4 beams
...    NRBTS-1/NRCELL-1/NRHOIF-1:ssBurstSetPeriod=20
...    NRBTS-1/NRCELL-1/NRHOIF-1:ssbFrequency=639936
...    NRBTS-1/NRCELL-1/NRHOIF-1:a3MeasEnabled=rsrp
...    NRBTS-1/NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRBTS-1/NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=30
...    NRBTS-1/NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms64
...    MRBTS-1/NRBTS-1/NRCELL-1:sMeasConfigSsbRsrp=0

@{CELL2_NRHOIF}
...    NRBTS-1/NRCELL-2/NRHOIF-1:cellDepType=SA+NSA
...    NRBTS-1/NRCELL-2/NRHOIF-1:freqBandIndicatorNR=78
...    NRBTS-1/NRCELL-2/NRHOIF-1:ifhoSsbScs=15KHz
...    NRBTS-1/NRCELL-2/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRBTS-1/NRCELL-2/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRBTS-1/NRCELL-2/NRHOIF-1:numberOfTransmittedSsBlocks=4 beams
...    NRBTS-1/NRCELL-2/NRHOIF-1:ssBurstSetPeriod=20
...    NRBTS-1/NRCELL-2/NRHOIF-1:ssbFrequency=636576
...    NRBTS-1/NRCELL-2/NRHOIF-1:a3MeasEnabled=rsrp
...    NRBTS-1/NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRBTS-1/NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=30
...    NRBTS-1/NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms64
...    NRBTS-1/NRCELL-2:measGapSelectionSA=favourUeThroughput

@{Inter_fre}
...    NRBTS-1:actIntraFreqHoSA=true
...    NRPMRNL-1:miNrRelReportCu=5min
...    NRBTS-1:actInterFreqHoSA=true
...    NRPMRNL-1:miNrRSACU=5min
...    NRCELL-2:nrarfcn=640000
...    NRCELL-2:gscnOrSsPbchArfcn=7915
...    NRBTS-1/NRCELL:a3MeasEnabled=rsrp
...    NRBTS-1/NRCELL:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRBTS-1/NRCELL:a3MeasSsbRsrp:a3OffsetSsbRsrp=20
...    NRBTS-1/NRCELL:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms64
...    NRBTS-1/NRCELL:a1MeashoEnabled=rsrp
...    NRBTS-1/NRCELL:a1MeashoSsbRsrp:a1HysteresishoSsbRsrp=0
...    NRBTS-1/NRCELL:a1MeashoSsbRsrp:a1ThresholdhoSsbRsrp=36
...    NRBTS-1/NRCELL:a1MeashoSsbRsrp:a1TimeToTriggerhoSsbRsrp=ms64
...    NRBTS-1/NRCELL:a1MeashoEnabledSA=rsrp
...    NRBTS-1/NRCELL:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRBTS-1/NRCELL:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=36
...    NRBTS-1/NRCELL:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms64
...    NRBTS-1/NRCELL:a2MeashoEnabled=rsrp
...    NRBTS-1/NRCELL:a2MeashoSsbRsrp:a2HysteresishoSsbRsrp=0
...    NRBTS-1/NRCELL:a2MeashoSsbRsrp:a2ThresholdhoSsbRsrp=35
...    NRBTS-1/NRCELL:a2MeashoSsbRsrp:a2TimeToTriggerhoSsbRsrp=ms64
...    NRBTS-1/NRCELL:a2MeashoEnabledSA=rsrp
...    NRBTS-1/NRCELL:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0
...    NRBTS-1/NRCELL:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=35
...    NRBTS-1/NRCELL:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms64

@{CB008830}
...    NRCELL:dlDataDmrsFdm:actDlDataDmrsFdm=false
...    NRCELL:dlDMRSAdditionalPosition=No additional DMRS
...    NRCELL-1:dlDmrsType=Type2
...    NRCELL-2:dlDmrsType=Type2
...    NRCELL:actDl256Qam=true
...    NRCELL:actUl256Qam=true
...    NRCELL:actPdschAtSsbSlots=true
...    NRCELL:actPdschAllocAroundSsb=true
...    NRCELL:actAdaptiveReTxResMcs=false
...    NRCELL:actEnhancedPDSCHSchSplSlot=false
...    NRCELL:actDlLowPAPRoptimizedPrecoding=true
...    NRCELL:actPdschRmCsirsForTracking=true
...    NRCELL:minPctResourceReservedMcsDl=50
...    NRCELL:minPctResourceReservedMcsUl=50
...    NRCELL:targetPctResourceReservedMcsDl=75
...    NRCELL:targetPctResourceReservedMcsUl=75
...    NRCELL:actDlMuMimoEnh=false

@{C002_C005_parameter}
...    NRCELL:actEnhancedPDSCHSchSplSlot=true
...    NRCELL:actAdaptiveReTxResMcs=true
...    NRCELL:actAdaptVoipTbs=true
...    NRCELL:actDl256Qam=false
...    NRCELL:actUl256Qam=false
...    NRCELL:actDlMuMimo=false
${Cell1_DMRS1}    dmrs-DownlinkForPDSCH-MappingTypeAsetup:{dmrs-AdditionalPositionpos0,scramblingID050}
${Cell1_DMRS2}    dmrs-DownlinkForPDSCH-MappingTypeAsetup:{dmrs-Typetype2,dmrs-AdditionalPositionpos0,scramblingID050}
${Cell2_DMRS1}    dmrs-DownlinkForPDSCH-MappingTypeAsetup:{dmrs-AdditionalPositionpos0,scramblingID051}
${Cell2_DMRS2}    dmrs-DownlinkForPDSCH-MappingTypeAsetup:{dmrs-Typetype2,dmrs-AdditionalPositionpos0,scramblingID051}

#UE-NR-Capability->phy-Parameters->phy-ParametersFRX-Diff->supportedDMRS-TypeDL    set to type1And2
${ue_support_DMRS_Type1and2}    SEPARATOR=
...    E5A00000074E5A031E000384A0003C1260C80008785800C40340260300C0700CA8D851AC10143404B2CA261E003D6C10101070EF1C39061C00103278FAB80027800E0009E0015
...    1B133582028680965944C3C007AD8202020E1DE38720C38002064F1F570004F001C0013C002A3626EB04050D012CB28987800F5B0404041C3BC70E418700040C9E3EAE0009E00
...    380027800546C4ED6080A1A025965130F001EB608080838778E1C830E0008193C7D54000014000000420E268000000010134640000E010113D86C003000281C1401C0C0260070
...    0068280000000002C0040081F000000000000072A68000800004B2CA801A555434003800580000002004008D58980008101820283038405880889098C909293139425305A

#UE-NR-Capability->phy-Parameters->phy-ParametersFRX-Diff->supportedDMRS-TypeDL set to type1
${ue_support_DMRS_Type1}    SEPARATOR=
...    E1A00000074E5A031E000384A0003C1260C80008685800C40340260300C0700CA8D851AC10143404B2CA261E003D6C10101070EF1C39061C00103278FAB80027800E0009E0015
...    1B133582028680965944C3C007AD8202020E1DE38720C38002064F1F570004F001C0013C002A3626EB04050D012CB28987800F5B0404041C3BC70E418700040C9E3EAE0009E00
...    380027800546C4ED6080A1A025965130F001EB608080838778E1C830E0008193C7D54000014000000420E268000000010134640000E010113D86C003000281C1401C0C0260070
...    00683E0000000000000E54D000100000965950034AAA868007000B000000040080118B130001020304050607080B101112131921252627284A0

@{ICS_DMRStype2Check}
...    Initial Context Setup Successful
...    dmrs-DownlinkForPDSCH-MappingTypeA setup
...    dmrs-Type type2

@{DMRSTYPE2}
...    dmrs-Type type2

@{RRE}
...    dmrs-Type type2
...    NR RRC Reestablishment sucessfully completed

@{RRE_cause}     handoverFailure    otherFailure
@{RREFB_action}    invalid_short_mac_i    invalid_crnti

@{Add_PDU_with_5QI_6}
...    Setup QosFlow with QFI:1 5QI:6
...    Pdu Session Resource Setup Response Message

@{Modify_PDU_Add_5QI_6}
...    Added QosFlow with QFI:2 5QI:6
...    Pdu Session Resource Modify Response Message

*** Test Cases ***
CB008830-ET-C002_Verify_Dynamic_switch_between_type_1_and_type_2_due_to_DL High Reliability DRB
    [Documentation]
    ...    1.Description
    ...    The purpose of this test case is to check following scenarios:
    ...    Dynamic switch between type 1 and type 2 due to DL High Reliability DR
    ...    also check:
    ...    CB008830-ET-C002_Verify_Dynamic_switch_between_type_1_and_type_2_due_to_DL High Reliability DRB
    ...    CB008830-ET-C005 Verify_DL High Reliability_DRB_setup_and_release_via_pdu_session_modify
    ...    2.Configuration
    ...      a.NRCELL/dlDmrsType set to "Type2".
    ...      b.Configured Link Adaptation High Reliability feature: NRBTS/NRCELL.actLAForHiReliab=true.
    ...      c.Default drb 5QI6 associated with NRPDSCHHRLA profile.
    ...      d.UE capability:
    ...      d.1 UE is capable of DL-DMRS-Type2
    ...      - UE-NR-Capability->phy-Parameters->phy-ParametersFRX-Diff->supportedDMRS-TypeDL    set to type1And2
    ...      - featureSetsDownlinkPerCC->maxNumberMIMO-LayersPDSCH set to fourLayers
    ...      - UE-NR-Capability->fr1-Add-UE-NR-Capabilities->phy-ParametersFRX-Diff->supportedDMRS-TypeDL    NOT set
    ...      d.2 UE is capable of High Reliability for PDSCH. i.e. either of following IE is set as "supported"
    ...      - UE-NR-Capability-> phy-Parameters-> phy-ParametersFRX-Diff-> dl-64QAM-MCS-TableAlt
    ...      - UE-NR-Capability-> fr1-Add-UE-NR-Capabilities-> phy-ParametersFRX-Diff-> dl-64QAM-MCS-TableAlt
    ...    3.Test Steps
    ...      a.UE attach to target cell with 5QI9 PDU SESSION 1 and send traffic, check traffic on PDU1
    ...      b.Setup PDU Session 2 with 5QI6(HR DRB) and send traffic, check traffic on PDU1 and PDU2
    ...      c.Release PDU Session 2, check traffic on PDU1
    ...      d.Setup 5QI6 in PDU session 1 via PDU modification and start traffic, check traffic on PDU1 5QI_9 and 5QI_6
    ...      e.VONR call setup and data transfer with PDU session 2
    ...      f.release 5QI6 via pdu1 session modify and check data transfer
    ...      g.Setup HR DRB to pdu1 session and check data transfer
    ...      h.Perform Inter-Freq HO from Cell1 to Cell2 and HO back, and check traffic on PDU1 5QI_9 and 5QI_6
    ...      I.UE released.
    ...    4.Check Points
    ...      a.PDU1 setup with 5QI_9 successfully, stable DL throughput is achieved on 5QI_9
    ...        l2_ps_user_usersetupreq configured DmrsType type1, mcsTable qam64, after PDU setup with 5QI_9
    ...        l2_ps_user_UserModifyReq configured DmrsType type2, mcsTable qam64,
    ...        in rrcReconfiguration, DMRS Type2 configured.
    ...      b.PDU2 setup with 5QI_6 successfully, stable DL throughput is achieved on 5QI_6, and also stable on 5QI_9
    ...        l2_ps_user_UserModifyReq configured DmrsType type1, mcsTable qam64LowSE
    ...        in rrcReconfiguration, DMRS Type1 configured.
    ...      c.PDU2 released successfully, stable DL throughput is achieved on 5QI_9
    ...        l2_ps_user_UserModifyReq configured DmrsType type2, mcsTable qam64
    ...        in rrcReconfiguration, DMRS Type2 configured; Stable DL throughput is achieved on 5QI_9
    ...      d.Qosflow with 5QI_6 setup on PDU1 successfully, stable DL throughput is achieved on 5QI_6, and also stable on 5QI_9
    ...        l2_ps_user_UserModifyReq configured DmrsType type1, mcsTable qam64LowSE
    ...        in rrcReconfiguration, DMRS Type1 configured; Stable DL throughput is achieved on 5QI_9 and 5QI_6
	...      e.In RRC reconfiguration, No DL DMRS type reconfig needed.
    ...        Both PDU session can achieve Stable DL throughput (All PDSCHs are transmitted with DL DMRS type 1)
    ...      f. In RRC reconfiguration, No DL DMRS type reconfig needed
    ...      g. In RRC reconfiguration,  DL DMRS type is changed to type 1.
    ...      h. In rrcReconfiguration, DMRS Type1 configured; Stable DL throughput is achieved on 5QI_9 and 5QI_6
    ...      I.UE released.
    [Tags]    QC_47183    C002
    Delta Commission Parameters    ${C002_C005_parameter}
    UE Attach To Target Cell with 5QI9 And Check Traffic
    Setup PDU Session 2 with 5QI6 And Check Traffic On Both PDU2 and PDU1
    Release PDU Session 2 And Check Traffic On PDU1
    Modify PDU Session 1 with 5QI6 Added And Check Traffic On Both QFI2 and QFI1
    Setup PDU Session 2 with VoNR And Check Traffic
    Release HR DRB with PDU Session 1 And Check Traffic
    Modify PDU Session 1 with 5QI6 Added And Check Traffic
    Perform Inter-Freq HO from Cell1 to Cell2 and HO back With Traffic Check
    Release ues    ue_id=1    ue_type=all

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri

Modify Cfg
    ${set_cell2}    catenate
    ...    set_cell id=2 gnb=2 pci=17:0 tac=100 nrci=0x02 tdd_cell=on proxy=$PROXY_SERVER_IP:9999|$PROXY_SERVER_IP:8888
    ...    nr_arfcn=640000:640000 gscn=7915 mandatory_for_activation=off
    Update Cfg    ${set_cell2}
    Update Cfg    ue_param id=1 ue_nr_capabilities=${ue_support_DMRS_Type1and2}
    Update Cfg    ue_param id=2 ue_nr_capabilities=${ue_support_DMRS_Type1and2}
    Update Cfg    set_qosflow id=1 5qi=9 default=on
    Update Cfg    set_qosflow id=2 5qi=5
    Update Cfg    set_qosflow id=3 5qi=6
    Update Cfg    set_qosflow id=4 5qi=7
    Update Cfg    set_qosflow id=5 5qi=8
    Update Cfg    set_qosflow id=6 5qi=1
    Update Cfg    set_qosrule id=1 proto=udp qos_flow=1
    Update Cfg    set_qosrule id=2 proto=tcp qos_flow=2
    Update Cfg    set_qosrule id=3 proto=tcp qos_flow=3
    Update Cfg    set_qosrule id=4 proto=udp qos_flow=4
    Update Cfg    set_qosrule id=5 proto=tcp qos_flow=5
    Update Cfg    set_qosrule id=6 proto=udp qos_flow=6
    Update Cfg    set_nwslice id=1 snssai=0x01:0xD143A5 default=on ue=all amf=1 qos_flows=1,2,3,4,5,6 qos_rules=1,2,3,4,5,6
    Update Cfg    set_nwslice id=2 snssai=0x01:0xD143A6 ue=all amf=1 qos_flows=2,6 qos_rules=2,6

SA UE attach
    [Arguments]    ${ue_id}=1    ${cell_id}=1    ${pdu}=1
    Execute Egate Command    smf_param id=1 reset
    Execute Egate Command    qosflow_modify qos_flow=1 default=on
    Execute Egate Command    ue_change_location id=${ue_id} cell=${cell_id} enb=2
    Start To Capture Wireshark Log    normalDRB5QI9_Setup
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=UE now in NG RM Registered state    fail_regexp=dmrs-Type type2
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu} gw=${ue_id} nwslice=1
    ...    pass_regexp=${ICS_DMRStype2Check}
    stop_capture_wireshark_log
    check_num_of_wireshark_as_excepted    ${SAVE LOG DIRECTORY}${/}/wireshark_normalDRB5QI9_Setup.pcap
	...    itf_l2_ps_pdsch_PdschConfig.dmrsType == 2 and itf_l2_ps_pdsch_PdschConfig.mcsTable == 1 @1

SA UE setup HR pdu with traffic
    [Arguments]    ${ue_id}=1    ${pdu}=2    ${Tput_dl}=2.4    ${Tput_ul}=18    ${dlmbps}=1    ${ulmbps}=20    ${index}=0
    BuiltIn.Log    UE${ue_id} start to setup HR pdu with traffic...    console=${True}
    Execute Egate Command    qosflow_modify qos_flow=3 default=on
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu} trf_type=internal
    Start To Capture Wireshark Log    HRDRB_Setup${index}
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu} gw=2 nwslice=1
    ...    pass_regexp=(PDU SESSION ID-${pdu} setup/reestablishment complete|dmrs-DownlinkForPDSCH-MappingTypeA setup)
    ...    fail_regexp=dmrs-Type type2
    stop_capture_wireshark_log
    check_num_of_wireshark_as_excepted    ${SAVE LOG DIRECTORY}${/}/wireshark_HRDRB_Setup${index}.pcap
    ...    itf_l2_ps_HrLaProfile.puschHrConfig.Length == 1 and itf_l2_ps_HrLaProfile.pdschHrConfig.Length == 1 @1
    ...    itf_l2_ps_pdsch_PdschConfig.mcsTable == 2 and itf_l2_ps_pdsch_PdschConfig.dmrsType == 1 @1
    Send And Verify Throuput    ue_id=${ue_id}    pdu=${pdu}     dlmbps=${dlmbps}    ulmbps=${ulmbps}    Tput_dl=${Tput_dl}
    ...    Tput_ul=${Tput_ul}
    Verify Throuput    ue_id=${ue_id}    Tput_dl=${Tput_dl}    Tput_ul=${Tput_ul}    pdu=${pdu}
    Verify Throuput    ue_id=${ue_id}    Tput_dl=405    Tput_ul=9    pdu=1

SA UE setup VONR pdu with traffic
    [Arguments]    ${ue_id}=1    ${pdu}=3    ${Tput_dl}=2.4    ${Tput_ul}=4.5    ${dlmbps}=1    ${ulmbps}=5    ${index}=0
    BuiltIn.Log    UE${ue_id} start to setup VONR pdu with traffic...    console=${True}
    Execute Egate Command    qosflow_modify qos_flow=2 default=on
    Execute Egate Command    smf_param id=1 additional_qosflows_to_activate=6
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu} trf_type=internal
    Start To Capture Wireshark Log    VONR_Setup${index}
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu} gw=3 nwslice=1
    ...    pass_regexp=(PDU SESSION ID-${pdu} setup/reestablishment complete|dmrs-DownlinkForPDSCH-MappingTypeA setup)
    ...    fail_regexp=dmrs-Type type2
    stop_capture_wireshark_log
    check_num_of_wireshark_as_excepted    ${SAVE LOG DIRECTORY}${/}/wireshark_VONR_Setup${index}.pcap
    ...    ngap.fiveQI == 5 and ngap.QosFlowSetupRequestList == 2 and ngap.fiveQI == 1 @1
    ...    itf_l2_ps_pdsch_PdschConfig.mcsTable == 1 and itf_l2_ps_pdsch_PdschConfig.dmrsType == 1 @1
    Execute Egate Command    smf_param id=1 reset
    Send And Verify Throuput    ue_id=${ue_id}    pdu=${pdu}     dlmbps=${dlmbps}    ulmbps=${ulmbps}    Tput_dl=${Tput_dl}
    ...    Tput_ul=${Tput_ul}
    Verify Throuput    ue_id=${ue_id}    Tput_dl=405    Tput_ul=9    pdu=1
    Verify Throuput    ue_id=${ue_id}    Tput_dl=2.4    Tput_ul=${Tput_ul}    pdu=2

UE release pdu session
    [Arguments]    ${ue_id}=1    ${pdu}=2    ${mcsTable}=1    ${dmrsType}=1    ${index}=0
    ##mscTable 0: qam64   1: qam256   2: qam64LowSE
    BuiltIn.Log    UE${ue_id} start to release pdu${pdu}...    console=${True}
    Start To Capture Wireshark Log    Release_Pdu${pdu}${index}
    Execute Egate Command    ue_pdu_session_release ue=${ue_id} pdu=${pdu} by=ue    pass_regexp=Successfully released PDU Session with ID ${pdu}
    stop_capture_wireshark_log
    check_num_of_wireshark_as_excepted    ${SAVE LOG DIRECTORY}${/}/wireshark_Release_Pdu${pdu}${index}.pcap
    ...    itf_l2_ps_pdsch_PdschConfig.dmrsType == ${dmrsType} and itf_l2_ps_pdsch_PdschConfig.mcsTable == ${mcsTable} @1
    Verify Throuput    ue_id=${ue_id}    Tput_dl=405    Tput_ul=9    pdu=1

Send And Verify Throuput
    [Arguments]    ${ue_id}=1    ${Tput_dl}=360    ${Tput_ul}=9    ${pdu}=1    ${dlmbps}=150    ${ulmbps}=10
    Send Traffic    ue_id=${ue_id}    pdu=${pdu}    dlmbps=${dlmbps}    ulmbps=${ulmbps}
    Verify Throuput    ue_id=${ue_id}    Tput_dl=${Tput_dl}    Tput_ul=${Tput_ul}    pdu=${pdu}

Send Traffic
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${dlmbps}=150    ${ulmbps}=10
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=${pdu} dir=ul mbps=${ulmbps} trf_id=1
    ...    pass_regexp=Started Uplink Internal traffic
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=${pdu} dir=dl mbps=${dlmbps} trf_id=2
    ...    pass_regexp=Started Downlink Internal traffic
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=${pdu} dir=dl mbps=${dlmbps} trf_id=3
    ...    pass_regexp=Started Downlink Internal traffic
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=${pdu} dir=dl mbps=${dlmbps} trf_id=4
    ...    pass_regexp=Started Downlink Internal traffic

Check UE Location
    [Arguments]    ${ue_id}=1    ${enb}=2    ${cell}=1
    Check Specific Ue State    ${ue_id}    ACTIVE
    ${real_enb_id}    ${real_cell_id}    Get UE Location    ${ue_id}
    Should Be Equal    ${real_enb_id}    ${enb}
    Should Be Equal    ${real_cell_id}    ${cell}

UE Attach To Target Cell with 5QI9 And Check Traffic
    [Arguments]    ${ue_id}=1    ${cell_id}=1
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    qosflow_modify qos_flow=1 default=on
    Start To Capture Wireshark Log    C002_C005_PDU1_DRB5QI9_Setup
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    ${ret1}=    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1    QoS Routing Table
    ${ret1}=    Remove String    ${ret1}    \r    \n    ${SPACE}
    Should Contain    ${ret1}    ${Cell1_DMRS2}
    stop_capture_wireshark_log
    check_num_of_wireshark_as_excepted    ${SAVE LOG DIRECTORY}${/}/wireshark_C002_C005_PDU1_DRB5QI9_Setup.pcap
	...    itf_l2_ps_pdsch_PdschConfig.dmrsType == 2 and itf_l2_ps_pdsch_PdschConfig.mcsTable == 0 @1
    Send And Verify Throuput 5QI9    ue_id=${ue_id}    qfi=1    pdu=1

Setup PDU Session 2 with 5QI6 And Check Traffic On Both PDU2 and PDU1
    [Arguments]    ${ue_id}=1    ${pdu}=2
    Execute Egate Command    qosflow_modify qos_flow=3 default=on
    Start To Capture Wireshark Log    C002_C005_PDU2_DRB5QI6_Setup
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu} trf_type=internal
    ${ret1}=    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu} gw=2 nwslice=1    pass_regexp=${Add_PDU_with_5QI_6}
    ${ret1}=    Remove String    ${ret1}    \r    \n    ${SPACE}
    Should Contain    ${ret1}    ${Cell1_DMRS1}
    stop_capture_wireshark_log
    check_num_of_wireshark_as_excepted    ${SAVE LOG DIRECTORY}${/}/wireshark_C002_C005_PDU2_DRB5QI6_Setup.pcap
    ...    itf_l2_ps_pdsch_PdschConfig.mcsTable == 2 and itf_l2_ps_pdsch_PdschConfig.dmrsType == 1 @1
    Send And Verify Throuput On HR DRB    ue_id=${ue_id}    qfi=1    pdu=${pdu}
    Verify Throuput on Ordinary DBR    ue_id=${ue_id}    qfi=1    pdu=1

Release PDU Session 2 And Check Traffic On PDU1
    [Arguments]    ${ue_id}=1    ${pdu}=2
    Start To Capture Wireshark Log    C002_C005_PDU2_release
    ${ret1}=    Execute Egate Command    ue_pdu_session_release ue=${ue_id} pdu=${pdu}
    ...    pass_regexp=Successfully released PDU Session with ID ${pdu} in SMF
    ${ret1}=    Remove String    ${ret1}    \r    \n    ${SPACE}
    Should Contain    ${ret1}    ${Cell1_DMRS2}
    stop_capture_wireshark_log
    check_num_of_wireshark_as_excepted    ${SAVE LOG DIRECTORY}${/}/wireshark_C002_C005_PDU2_release.pcap
    ...    itf_l2_ps_pdsch_PdschConfig.dmrsType == 2 and itf_l2_ps_pdsch_PdschConfig.mcsTable == 0 @1
    Verify Throuput on Ordinary DBR    ue_id=${ue_id}    qfi=1    pdu=1

Modify PDU Session 1 with 5QI6 Added And Check Traffic On Both QFI2 and QFI1
    [Arguments]    ${ue_id}=1    ${pdu}=1
    Start To Capture Wireshark Log    C002_C005_PDU1_DRB5QI6_setup
    ${ret1}=    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu} qosflows_to_add=3 by=amf
     ...    pass_regexp=${Modify_PDU_Add_5QI_6}
    ${ret1}=    Remove String    ${ret1}    \r    \n    ${SPACE}
    Should Contain    ${ret1}    ${Cell1_DMRS1}
    stop_capture_wireshark_log
    check_num_of_wireshark_as_excepted    ${SAVE LOG DIRECTORY}${/}/wireshark_C002_C005_PDU1_DRB5QI6_setup.pcap
    ...    itf_l2_ps_pdsch_PdschConfig.mcsTable == 2 and itf_l2_ps_pdsch_PdschConfig.dmrsType == 1 @1
    Send And Verify Throuput On HR DRB    ue_id=${ue_id}    qfi=2    pdu=${pdu}
    Verify Throuput on Ordinary DBR    ue_id=${ue_id}    qfi=1    pdu=${pdu}

Setup PDU Session 2 with VoNR And Check Traffic
    [Arguments]    ${ue_id}=1    ${id_2}=2
    Execute Egate Command    qosflow_modify default=on qos_flow=1 priority=1
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${id_2} trf_type=internal
    Start To Capture Wireshark Log    C002_C005_VONR_Setup
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${id_2} nwslice=1 gw=${id_2}
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${id_2} qosflows_to_add=2 by=amf
    ...    pass_regexp=Added QosFlow with QFI:2 5QI:5
    ${ret1}=    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${id_2} qosflows_to_add=6 by=amf
    ...    pass_regexp=Added QosFlow with QFI:3 5QI:1
    ${ret1}=    Remove String    ${ret1}    \r    \n    ${SPACE}
    Should not Contain    ${ret1}    ${Cell1_DMRS2}
    stop_capture_wireshark_log
    check_num_of_wireshark_as_excepted    ${SAVE LOG DIRECTORY}${/}/wireshark_C002_C005_VONR_Setup.pcap
    ...    ngap.QosFlowAddOrModifyRequestList == 1 and ngap.qosFlowIdentifier == 2 and ngap.fiveQI == 5 @1
    ...    itf_l2_ps_pdsch_PdschConfig.mcsTable == 0 and itf_l2_ps_pdsch_PdschConfig.dmrsType == 1 @1
    Send Vonr traffic and check through

Send Vonr traffic and check through
    Trigger 5QI5 and 5QI1 traffic
    Check Traffic 5QI5 and 5QI1

Trigger 5QI5 and 5QI1 traffic
    [Arguments]    ${ue_id}=1    ${pdu}=2
    execute egate command     trf_data_start ue=${ue_id} pdu=${pdu} qfi=2 dir=dl trf_id=1 protocol=tcp Kbps=16 seconds=600
    execute egate command     trf_data_start ue=${ue_id} pdu=${pdu} qfi=2 dir=ul trf_id=2 protocol=tcp Kbps=16 seconds=600
    execute egate command     trf_data_start ue=${ue_id} pdu=${pdu} qfi=3 dir=dl trf_id=1 rtp_codec=amr_wb_18_25 seconds=600
    execute egate command     trf_data_start ue=${ue_id} pdu=${pdu} qfi=3 dir=ul trf_id=2 rtp_codec=amr_wb_18_25 seconds=600
    sleep    5s
    execute egate command     qfi_stats ue=1 pdu=2 qfi=3 dir=dl    pass_regexp=Parameter
    execute egate command     qfi_stats ue=1 pdu=2 qfi=3 dir=ul    pass_regexp=Parameter

Release HR DRB with PDU Session 1 And Check Traffic
    [Arguments]    ${ue_id}=1    ${qfi}=1    ${pdu}=1    ${Tput_dl}=270    ${Tput_ul}=8
    Verify Throuput    sleep=10s     ue_id=${ue_id}    qfi=${qfi}    pdu=${pdu}    Tput_dl=${Tput_dl}    Tput_ul=${Tput_ul}
    Start To Capture Wireshark Log    C002_C005_Release_HRDRB_PDU1
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu} qosflows_to_del=3 by=amf    RESOURCE MODIFY RESPONSE
    sleep    2s    for DRB delete
    stop_capture_wireshark_log
    check_num_of_wireshark_as_excepted    ${SAVE LOG DIRECTORY}${/}/wireshark_C002_C005_Release_HRDRB_PDU1.pcap
    ...    ngap.qosFlowIdentifier == 2 and ngap.radioNetwork == 0 @1
    ...    itf_l2_ps_pdsch_PdschConfig.mcsTable == 0 and itf_l2_ps_pdsch_PdschConfig.dmrsType == 2 @0
    Verify Throuput on Ordinary DBR    ue_id=${ue_id}    qfi=${qfi}    pdu=${pdu}    Tput_dl=${Tput_dl}    Tput_ul=${Tput_ul}

Modify PDU Session 1 with 5QI6 Added And Check Traffic
    [Arguments]    ${ue_id}=1    ${pdu}=1
    Start To Capture Wireshark Log    C002_C005_HRDRB_PDU1_Setup
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu} qosflows_to_add=3 by=amf    pass_regexp=${Modify_PDU_Add_5QI_6}
    stop_capture_wireshark_log
    check_num_of_wireshark_as_excepted    ${SAVE LOG DIRECTORY}${/}/wireshark_C002_C005_PDU1_DRB5QI6_setup.pcap
    ...    nr-rrc.dmrs_DownlinkForPDSCH_MappingTypeA == 1 and nr-rrc.pdsch_Config == 1 and nr-rrc.c1 == 0 and nr-rrc.dmrs_AdditionalPosition == 0 @1
    Send And Verify Throuput On HR DRB    ue_id=${ue_id}    qfi=2    pdu=${pdu}
    Verify Throuput on Ordinary DBR    ue_id=${ue_id}    qfi=1    pdu=${pdu}

Perform Inter-Freq HO from Cell1 to Cell2 and HO back With Traffic Check
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${Tput_dl}=270    ${Tput_ul}=8
    Trigger UE Inter-Frequency Intra-gNB HO SA
    ...    ue_id=${ue_id}    targetpci=51    sourcecell=1    targetcell=2    sourcefreq=${NRCELL_1_Freq}    targetfreq=${NRCELL_2_Freq}
    Verify Throuput on Ordinary DBR    ue_id=${ue_id}    qfi=1    pdu=${pdu}    Tput_dl=${Tput_dl}    Tput_ul=${Tput_ul}
    Verify Throuput on HR DBR    ue_id=${ue_id}    qfi=2    pdu=${pdu}    Tput_dl=8    Tput_ul=8
    Trigger UE Inter-Frequency Intra-gNB HO SA
    ...    ue_id=${ue_id}    targetpci=50    sourcecell=2    targetcell=1    sourcefreq=${NRCELL_2_Freq}    targetfreq=${NRCELL_1_Freq}
    Verify Throuput on Ordinary DBR    ue_id=${ue_id}    qfi=1    pdu=${pdu}    Tput_dl=${Tput_dl}    Tput_ul=${Tput_ul}
    Verify Throuput on HR DBR    ue_id=${ue_id}    qfi=2    pdu=${pdu}    Tput_dl=8    Tput_ul=8

Send And Verify Throuput On HR DRB
    [Arguments]    ${ue_id}    ${qfi}   ${pdu}    ${Tput_dl}=8    ${Tput_ul}=8
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} dir=dl mbps=10 trf_id=2
    ...    pass_regexp=Started Downlink Internal traffic over UDP on Ue:${ue_id}
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} dir=ul mbps=10 trf_id=1
    ...    pass_regexp=Started Uplink Internal traffic over UDP on Ue:${ue_id}
    Verify Throuput on HR DBR    ue_id=${ue_id}    qfi=${qfi}    pdu=${pdu}    Tput_dl=${Tput_dl}    Tput_ul=${Tput_ul}

Verify Throuput on Ordinary DBR
    [Arguments]    ${ue_id}=1    ${qfi}=1    ${pdu}=1    ${Tput_dl}=270    ${Tput_ul}=8
    Verify Throuput    ue_id=${ue_id}    qfi=${qfi}    pdu=${pdu}    Tput_dl=${Tput_dl}    Tput_ul=${Tput_ul}

Verify Throuput on HR DBR
    [Arguments]    ${ue_id}=1    ${qfi}=1    ${pdu}=1    ${Tput_dl}=8    ${Tput_ul}=8
   Verify Throuput    ue_id=${ue_id}    qfi=${qfi}    pdu=${pdu}    Tput_dl=${Tput_dl}    Tput_ul=${Tput_ul}

Trigger UE Inter-Frequency Intra-gNB HO SA
    [Arguments]    ${ue_id}    ${targetpci}    ${sourcecell}    ${targetcell}    ${sourcefreq}    ${targetfreq}
    ${measid}    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${sourcefreq}    event_type=A2
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${measid} event=A2 srsrp_nr=11 srsrq_nr=11
    ...    pass_regexp=(rrcReconfigurationComplete|eventId eventA3)
    ${a3mea}    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${targetfreq}    event_type=A3
    ${hocommand}    catenate    ue_measurement_send_nr id=${ue_id} meas_id=${a3mea} event=A3 srsrp_nr=11 srsrq_nr=11
    ...    phycell_id=${targetpci} nrsrp_nr=80
    ${ret1}=    Execute Egate Command    ${hocommand}
    ...    pass_regexp=(rrcReconfigurationComplete|UE${ue_id}: Intra-eNB handover from EXT_ENB-2.${sourcecell} to EXT_ENB-2.${targetcell} performed)
    ${ret1}=    Remove String    ${ret1}    \r    \n    ${SPACE}
    Should Contain    ${ret1}    dmrs-DownlinkForPDSCH-MappingTypeAsetup:\{dmrs-AdditionalPositionpos0,scramblingID0${targetpci}\}
    Check UE Location    ue_id=${ue_id}    enb=2    cell=${targetcell}
    Check Traffic 5QI5 and 5QI1    ue_id=${ue_id}

Check Traffic 5QI5 and 5QI1
    [Arguments]    ${ue_id}=1    ${pdu}=2    ${Tput_dl_5QI5}=10    ${Tput_ul_5QI5}=10    ${Tput_dl_5QI1}=10    ${Tput_ul_5QI1}=10    ${sleep}=15s
    sleep    ${sleep}    sleep for Tput stable
    ${dl_throughput_5QI5}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=2    direction=dl    rate_type=ave
    ${ul_throughput_5QI5}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=2    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput_5QI5}>${Tput_dl_5QI5}
    Should Be True    ${ul_throughput_5QI5}>${Tput_ul_5QI5}
    ${dl_throughput_5QI1}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=3    direction=dl    rate_type=ave
    ${ul_throughput_5QI1}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=3    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput_5QI1}>${Tput_dl_5QI1}
    Should Be True    ${ul_throughput_5QI1}>${Tput_ul_5QI1}

Verify Throuput
    [Arguments]    ${ue_id}=1    ${qfi}=1    ${pdu}=1    ${Tput_dl}=360    ${Tput_ul}=9    ${sleep}=10
    sleep    ${sleep}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    direction=dl    rate_type=ave
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    direction=ul    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

Send And Verify Throuput 5QI9
    [Arguments]    ${ue_id}    ${qfi}   ${pdu}    ${Tput_dl}=270    ${Tput_ul}=8
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} dir=dl mbps=150 trf_id=2
    ...    Started Downlink Internal traffic over UDP on Ue:${ue_id}
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} dir=dl mbps=150 trf_id=3
    ...    Started Downlink Internal traffic over UDP on Ue:${ue_id}
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} dir=ul mbps=10 trf_id=1
    ...    Started Uplink Internal traffic over UDP on Ue:${ue_id}
    Verify Throuput   ue_id=${ue_id}    qfi=${qfi}    pdu=${pdu}    Tput_dl=${Tput_dl}    Tput_ul=${Tput_ul}
