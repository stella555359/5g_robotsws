*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CLOUD_5G_I_[BO][BO]_AP_[KLLL]_SANSA_L1B_CPRI_CMWV_FDD    team-Blues_SGT&A
...    owner-Tingjian.Mao    release-SBTS23R3    CRT
Resource          ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${NOKIA_XNAP_PLUGIN_FLAG}    ${True}
${NOKIA_F1AP_PLUGIN_FLAG}    ${True}

@{PARAMS_IN_SCF}
...    @{PARAMS_FOR_CA}
...    @{PARAMS_ADJ_REL_FOR_GNB1}
...    @{PARAMS_FOR_OTHERS}
...    @{GNB1_CA_rel_for_NRCELL_11}
...    @{PARAMS_FOR_GNB1}
...    @{GNB_VoNR}

@{PARAMS_IN_SCF_GNB2}
...    @{PARAMS_FOR_CA}
...    @{PARAMS_FOR_GNB2}
...    @{PARAMS_ADJ_REL_FOR_GNB2}
...    @{PARAMS_FOR_OTHERS}
...    @{GNB2_cell1_2200_cell2_no_2200}

@{PARAMS_FOR_CA}
...    NRBTS:actCarrierAggregation=true
...    NRBTS:sCellActivationMethod=blind
...    NRBTS:caConfigurationSupport=4CCDL_2CCUL
...    NRBTS:weightForIgnbCaSelection=1
...    NRBTS:actIncXn=true
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:carrierAggregationSupportList=${CA_support_list}
...    NRBTS/NRDRB_RLC_AM-1:ulTReassemblyIBCA=40
...    NRBTS/NRDRB_RLC_AM-2:ulTReassemblyIBCA=40
...    NRDU-1:actInterGnbCa=DLOnly
...    NRDU-1:dlToUlContributionRatio=101
...    NRDU-1:xgUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRCELL:actK1Opt=intraAndInter-gNB
...    NRCELL:weightForSCellSelection=50
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRDU-1:actConnectedModeMobilityCA=true


@{PARAMS_FOR_GNB1}
...    NRCELL:sCellDeactivationTimerGNB=infinity
...    NRBTS:iGnbCaXnCfUpBackOffTmr=60
...    NRBTS:iGnbCaXnSetupReqTmr=60
...    NRBTS:iGnbCaXnSetupRespTmr=60
...    NRBTS:intGnbScellTempBlockTmr=60
...    NRCELL-11:msg1FrequencyStart=20
...    NRCELL-11/NRCELL_FDD-1:chBwDl=20MHz
...    NRCELL-11/NRCELL_FDD-1:chBwUl=20MHz
...    NRCELL-12:msg1FrequencyStart=20
...    NRCELL-12/NRCELL_FDD-1:chBwDl=20MHz
...    NRCELL-12/NRCELL_FDD-1:chBwUl=20MHz
...    NRCELL:maxNumScellsDlFr1=3

@{GNB_VoNR}
...    NRCELL:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=75
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=95
...    NRCELL:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=0ms
...    NRCELL:a1MeasSCellAddEnabled=rsrp

...    NRCELL:actVoNR=true
...    NRCELL:actCDrx=true
...    NRCELL:actCDrxVoNR=true
...    NRCELL:n310VoNR=n10
...    NRCELL:t310VoNR=100ms
...    NRCELL:actEnhancedVoNR=true
...    NRCELL:drxProfile1:drxInactivityTimer=80ms
...    NRCELL:drxProfile1:drxLongCycle=160ms
...    NRCELL:drxProfile1:drxOnDurationTimer=5ms
...    NRCELL:drxProfile1:drxRetransTimerDl=0slot
...    NRCELL:drxProfile1:drxRetransTimerUl=0slot
...    NRCELL:drxProfile2:drxInactivityTimer=20ms
...    NRCELL:drxProfile2:drxLongCycle=40ms
...    NRCELL:drxProfile2:drxOnDurationTimer=20ms
...    NRCELL:drxProfile2:drxRetransTimerDl=0slot
...    NRCELL:drxProfile2:drxRetransTimerUl=0slot
...    NRDRB_MAC-4:lcgid=0
...    NRDRB_MAC-4:prioritisedBitRate=16kBps
...    NRDRB_MAC-4:schedulPrio=4
...    NRDRB_MAC-3:lcgid=4
...    NRDRB_MAC-3:prioritisedBitRate=16kBps
...    NRDRB_MAC-3:schedulPrio=5
...    NRDRB_MAC-3:schedulBSD=50ms
...    NRDRB_PDCP-2:pdcpBufDiscardEnabled=false
...    NRDRB_RLC_UM-1:dlTReassemblyUm=ms40
...    NRDRB_RLC_UM-1:rlcUMDrbSNLength=rlcUm12bitSN
...    NRDRB_RLC_UM-1:ulTReassemblyUm=ms40
...    NRDRB-10:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-4
...    NRDRB-10:resType=nonGBR_Signaling
...    NRDRB-15:discardTimer=30ms
...    NRDRB-15:dlFlowControlAlgo=none
...    NRDRB-15:dscp=0
...    NRDRB-15:actDddsReduction=false
...    NRDRB-15:actLostPduFastRetx=false
...    NRDRB-15:maxDddsPeriodCpuOvld=40
...    NRDRB-15:maxDataRateGbrDl=1000
...    NRDRB-15:maxDataRateGbrUl=1000
...    NRDRB-15:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-3
...    NRDRB-15:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-2
...    NRDRB-15:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRDRB-15:numSduDiscard=1
...    NRDRB-15:queuingDelayDiscarding=Disabled
...    NRDRB-15:queuingDelaySduDiscardThreshold=200
...    NRDRB-15:resType=GBR
...    NRDRB-15:cellAggrLevel=Not FR1 CA eligible
...    NRDRB-15:rlcMode=RLC_UM
...    NRDRB-15:schedulWeight=1
...    NRDRB-15:sduDiscardIntervalTmr=100
...    NRBTS/NRDRB-15:maxRlcQueueingDelayGbr=20
...    NRBTS/NRDRB-15:maxTransferDelayGbr=20
...    delete:NRDRB-15:nrPdschHRLaDN
...    NRDRB_5QI-6:fiveqiValueList=1
...    NRDRB_5QI-6:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-15
...    NRDRB_5QI-7:fiveqiValueList=2
...    NRDRB_5QI-7:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-16
...    delete:NRDRB-16:nrPdschHRLaDN
...    NRBTS/NRDRB-16:discardTimer=300ms
...    NRBTS/NRDRB-16:l2OHFactorDl=16
...    NRBTS/NRDRB-16:l2OHFactorUl=35
...    NRBTS/NRDRB-16:maxDataRateGbrDl=30720
...    NRBTS/NRDRB-16:maxDataRateGbrUl=30720
...    NRBTS/NRDRB-16:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-5
...    NRBTS/NRDRB-16:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-3
...    NRBTS/NRDRB-16:nrDrbRlcAmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_AM-2
...    NRBTS/NRDRB-16:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRBTS/NRDRB-16:cellAggrLevel=Not FR1 CA eligible
...    NRBTS/NRDRB-16:resType=GBR
...    NRBTS/NRDRB-16:rlcMode=RLC_UM
...    NRBTS/NRDRB-16:schedulWeight=1
...    NRBTS/NRDRB-16:nsaDrbParam:dlDataSplitMode=dlOverF1UX2U
...    NRBTS/NRDRB-16:nsaDrbParam:inactPeriodX2PdcpDuplication=300
...    NRBTS/NRDRB-16:maxRlcQueueingDelayGbr=20
...    NRBTS/NRDRB-16:maxTransferDelayGbr=20
...    NRBTS/NRDRB_MAC-5:lcgid=5
...    NRBTS/NRDRB_MAC-5:delayTarget=50
...    delete:NRBTS/NRDRB-16:drbInactivityTimerSA
...    NRBTS/NRDRB_PDCP-3:tReorderingDl=ms100
...    NRBTS/NRDRB_PDCP-3:tReorderingUl=ms100
...    NRBTS/NRDRB_PDCP-3:pdcpBufDiscardEnabled=false
...    NRCELL:actNonVoNRGbrService=true

@{PARAMS_ADJ_REL_FOR_GNB1}
...    NRBTS/NRADJGNB-2:administrativeState=Unlocked
...    NRBTS/NRADJGNB-2:gNbIdLength=22
...    NRBTS/NRADJGNB-2:gNodeBId=2
...    NRBTS/NRADJGNB-2:weightForIgnbCaSelection=1
...    NRBTS/NRADJGNB-2:xnLinkRef=1
...    NRBTS/NRADJGNB-2:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-2:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-2:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-1:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-1:fiveGsTac=200
...    NRBTS/NRADJNRCELL-1:gNbId=2
...    NRBTS/NRADJNRCELL-1:gNbIdLength=22
...    NRBTS/NRADJNRCELL-1:lcrId=1
...    NRBTS/NRADJNRCELL-1:nrarfcn=663400
...    NRBTS/NRADJNRCELL-1:physCellId=50
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-1:freqBandIndicatorNR=77
...    NRBTS/NRADJNRCELL-2:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-2:fiveGsTac=200
...    NRBTS/NRADJNRCELL-2:gNbId=2
...    NRBTS/NRADJNRCELL-2:gNbIdLength=22
...    NRBTS/NRADJNRCELL-2:lcrId=2
...    NRBTS/NRADJNRCELL-2:nrarfcn=658000
...    NRBTS/NRADJNRCELL-2:physCellId=51
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-2:freqBandIndicatorNR=77
...    NRBTS/NRADJNRCELL-13:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-13:fiveGsTac=200
...    NRBTS/NRADJNRCELL-13:gNbId=2
...    NRBTS/NRADJNRCELL-13:gNbIdLength=22
...    NRBTS/NRADJNRCELL-13:lcrId=13
...    NRBTS/NRADJNRCELL-13:nrarfcn=368400
...    NRBTS/NRADJNRCELL-13:physCellId=62
...    NRBTS/NRADJNRCELL-13:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-13:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-13:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-13:freqBandIndicatorNR=3
...    NRBTS/NRADJNRCELL-14:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-14:fiveGsTac=200
...    NRBTS/NRADJNRCELL-14:gNbId=2
...    NRBTS/NRADJNRCELL-14:gNbIdLength=22
...    NRBTS/NRADJNRCELL-14:lcrId=14
...    NRBTS/NRADJNRCELL-14:nrarfcn=153400
...    NRBTS/NRADJNRCELL-14:physCellId=63
...    NRBTS/NRADJNRCELL-14:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-14:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-14:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-14:freqBandIndicatorNR=28

@{PARAMS_FOR_GNB2}
...    NRBTS:iGnbCaXnCfUpBackOffTmr=60
...    NRBTS:iGnbCaXnSetupReqTmr=90
...    NRBTS:iGnbCaXnSetupRespTmr=60
...    NRBTS:intGnbScellTempBlockTmr=60
...    NRCELL:sCellDeactivationTimerGNB=infinity
...    NRBTS:actInterFreqHoSA=true
...    NRPMRNL-1:miNrRelReportCu=5min

@{PARAMS_ADJ_REL_FOR_GNB2}
...    NRBTS/NRADJGNB-1:administrativeState=Unlocked
...    NRBTS/NRADJGNB-1:gNbIdLength=22
...    NRBTS/NRADJGNB-1:gNodeBId=1
...    NRBTS/NRADJGNB-1:weightForIgnbCaSelection=1
...    NRBTS/NRADJGNB-1:xnLinkRef=1
...    NRBTS/NRADJGNB-1:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-1:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-11:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-11:fiveGsTac=200
...    NRBTS/NRADJNRCELL-11:gNbId=1
...    NRBTS/NRADJNRCELL-11:gNbIdLength=22
...    NRBTS/NRADJNRCELL-11:lcrId=11
...    NRBTS/NRADJNRCELL-11:nrarfcn=368400
...    NRBTS/NRADJNRCELL-11:physCellId=60
...    NRBTS/NRADJNRCELL-11:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-11:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-11:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-11:ssbFrequency=368430
...    NRBTS/NRADJNRCELL-11:freqBandIndicatorNR=3
...    NRBTS/NRADJNRCELL-12:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-12:fiveGsTac=200
...    NRBTS/NRADJNRCELL-12:gNbId=1
...    NRBTS/NRADJNRCELL-12:gNbIdLength=22
...    NRBTS/NRADJNRCELL-12:lcrId=12
...    NRBTS/NRADJNRCELL-12:nrarfcn=374000
...    NRBTS/NRADJNRCELL-12:physCellId=61
...    NRBTS/NRADJNRCELL-12:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-12:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-12:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-12:ssbFrequency=373970
...    NRBTS/NRADJNRCELL-12:freqBandIndicatorNR=3

@{PARAMS_FOR_OTHERS}


...    NRBTS:actRanSharing=false
...    NRCELL:actCDrx=false
...    NRBTS:cipherPrefL:nea0=8
...    NRBTS:cipherPrefL:nea1_128=0
...    NRBTS:cipherPrefL:nea2_128=0
...    NRBTS:cipherPrefL:nea3_128=0
...    NRCELL:timingAdvanceOffset=n25600
...    NRBTS:actHighestEstNrTputBcSel=true
...    NRBTS:actMultipleDedicatedBWPs=true
...    NRBTS/NRCELL:actEnhMultipleDedicatedBWPs=true
...    NRCELL:a2MeasSCellRelEnabled=rsrp
...    NRCELL:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=480ms
...    NRCELL:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=50|a2TimeToTriggerSCellRelSsbRsrp=480ms
...    NRCELL:a2MeasSCellRelSsbRsrq:a2HysteresisSCellRelSsbRsrq=0|a2TimeToTriggerSCellRelSsbRsrq=480ms
...    NRCELL:a2MeasSCellRelSsbRsrq:a2ThresholdSCellRelSsbRsrq=5|a2TimeToTriggerSCellRelSsbRsrq=480ms

@{GNB2_cell1_2200_cell2_no_2200}
...    NRBTS:actChannelMapVal=Disabled
...    NRBTS:actFdmEnhancedScheduling=true
...    NRCELL-1:dlMimoMode=8x4 Closed Loop Spatial Multiplexing
...    NRCELL-1:actBeamforming=true
...    NRCELL-1:nrCellType=4DL2UL
...    NRCELL-1:ssPbchBlockPower=10
...    NRCELL-1:periodicCsiAcquisition:csirsPower=10
...    NRCELL-1:beamSet:basicBeamSet=beamSet_2
...    NRCELL-1:periodicCsiAcquisition:csirsNumberWithinReportPeriod_Set1=1
...    NRCELL-1:periodicCsiAcquisition:maxCsirsNumber=4
...    NRCELL-2:dlMimoMode=2x2 Closed Loop Spatial Multiplexing
...    NRCELL-2:nrCellType=4DL2UL
...    NRCELL-2:actBeamforming=true
...    NRCELL-2:ssPbchBlockPower=10
...    NRCELL-2:beamSet:basicBeamSet=beamSet_1
...    delete:NRCELL-2:periodicCsiAcquisition:csirsPower=10
...    delete:NRCELL-2:periodicCsiAcquisition:csirsNumberWithinReportPeriod_Set1=1
...    delete:NRCELL-2:periodicCsiAcquisition:maxCsirsNumber=4
...    NRCELLGRP-0:numberOfTransmittedSsBlocks=2 beams
...    NRCELLGRP-1:numberOfTransmittedSsBlocks=1 beam
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1


@{GNB1_CA_rel_for_NRCELL_11}
...    NRCELL-11/NRREL-14:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-14:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-14:gNbId=2
...    NRCELL-11/NRREL-14:gNbIdLength=22
...    NRCELL-11/NRREL-14:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-14:lcrId=14
...    NRCELL-11/NRREL-14:removeNotAllowed=false
...    NRCELL-11/NRREL-14:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-14:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-14:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-14:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-14:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-1:gNbId=2
...    NRCELL-11/NRREL-1:gNbIdLength=22
...    NRCELL-11/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-1:lcrId=1
...    NRCELL-11/NRREL-1:removeNotAllowed=false
...    NRCELL-11/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-2:gNbId=2
...    NRCELL-11/NRREL-2:gNbIdLength=22
...    NRCELL-11/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-2:lcrId=2
...    NRCELL-11/NRREL-2:removeNotAllowed=false
...    NRCELL-11/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-2:sCellAdditionMethod=covBasedA1

@{OnlineParam_GH019}
...    NRCELL:actCDrxVoNR=false

@{default DRX setup}
...    drx-Config setup
...    drx-onDurationTimer milliSeconds : ms5
...    drx-LongCycleStartOffset ms160
...    QoS Routing Table

@{default DRX release}
...    drx-Config release
...    Added QosFlow with QFI:2 5QI:1

@{VONR DRX release for 5QI-2 call}
...    drx-Config release
...    Added QosFlow with QFI:2 5QI:2

@{VONR DRX setup for 5QI-2 call release}
...    Removed FiveQi:Qfi mapping fiveQi 2 qfi 2
...    drx-Config setup
...    drx-onDurationTimer milliSeconds : ms20
...    drx-LongCycleStartOffset ms40
...    rrcReconfigurationComplete

@{default DRX setup for VONR call release}
...    drx-Config setup
...    drx-onDurationTimer milliSeconds : ms5
...    drx-LongCycleStartOffset ms160
...    Removed FiveQi:Qfi mapping fiveQi 1 qfi 2

@{FTTF 4CC check}
...    SCellIndex 3 activated successfully at airphone
...    SCellIndex 1 activated successfully at airphone
...    SCellIndex 2 activated successfully at airphone

${CA_support_list}    ca_Fr1Tdd_Any_Sa,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Fr1Tdd_Nsa,ca_Fdd_Fdd,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Nsa,ca_Fdd_Any_Sa,ca_Fr1Tdd_Fdd_Sa

#4CC CA_n3A-n28A-n77(2A) n77 simultaneousCSI-ReportsPerCC=4
${SA_Capa_Support_n3A_n28A_n77(2A)}    SEPARATOR=
...    E9A09000575F5A13160003C320016093170019C3D09009B20C39F30C7942C0E098040623809DC6C06C0D608C21A08107482406D6C98AB1A1C
...    F88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE00098000702A0D805AC1184341020F10480CAD931562439F604F88
...    E3C62471E439F51CF9863CA1607038784FEC000003FB000000260001C0AA36266B04610D04083A412030B64C55110E7C471E238F40CFB027C
...    639F30C7942C0E070F05C00FFC007003FF0004C000381506C1BD608C21A0810788240656C98AB121CF88E3D813E31238F21CFA8E7CC31E50B
...    0381C3C27FFC00001FFF00000130000E0551B13758230868000010090185B24CA88873E238F20C7A067D813E01CF9863CA1607038782F5555
...    5553D5555554260001C00258F804001C1B000E260007130000018581587804001C4C00000E160402401B800D0132001404D0F401F01468912
...    244D8E7C3851226C73E180070218C1E8260078005038280381804A00E000C0480080C07C12004000000020010000000400001802000004010
...    00004008000030040000200200001401000802008020000180100000E00800400000010000100080000900400001802000028010000160080
...    0409024010000180672A6B2A6B052B032B066B056B296F266F016B036B012B022B07681A0800004B29202000032CA4C080000CB2920200007
...    2CA480800024B292020000B2CA4C0800034B292020000F2CA480800044B29202000132CA480800054B29202000172CA4A0800064B29202000
...    062CA480669545D2AAAA55174AA2A82C55058AA0D154A62A93455018AA051549AAA83C509004800D028001C20200400808010022010020040
...    40080101002004402018028080100202004008C04030050100C014040080101002004402020028080800A0202C058C04030060100C0140403
...    00601002004402018028080600A0200400840403005010020046A87C0004080C10181C282C30344044484C5060646C70747C8494989CA0A4A
...    8B4BD05060B40

*** Test Cases ***
CB008140-ET-GH014 nonGBR and vonr 4CC FFTT covBasedA1 IgNB-CA setup after DRX setup and then DRX release with non-VONR GBR setup
    [Documentation]
    ...    1. This user scenario verifies the case that UE is configured with DRX while SCell addition is triggered.
    ...       In this case,DRX configuration impacts SCells resource allocation procedure.
    ...       This user scenario verifies the case that DRX release is triggered after SCell addition.In this case,
    ...       DRX release should be indicated to all ext-SCells.
    ...    2. Configuration:
    ...    GNB-1 Pri: cell11-FDD(n3)(pci:60) cell12-FDD(n3)(pci:61)
    ...    GNB-2 ext: cell1-TDD(n77)(pci:50) cell2-TDD(n77)(pci:51) cell13-FDD(n3)(pci:62) cell14-FDD(n28)(PCI63)
    ...    scell gnb2-cell1 gnb2-cell2 and gnb2-cell14
    ...    [Test Case Steps]
    ...         a.UE1 register to cell1_1 and setup SA non-GBR call,start both UL/DL traffic
    ...         b.add vonr call,VONR call setup successfully, default DRX release,VONR DRX setup
    ...         c.A1 scell addition MR send from UE,FTTF 4CC add successful,CSI-RS Resource check,4 csirs P8 is used for
    ...           Scell(pci:50), 1 csirs P2 is used for Scell(pci:51)
    ...         d.add non-VONR GBR 5QI-2 call,VONR DRX released
    ...         e.release non-VONR GBR 5QI-2 call,VONR DRX setup
    ...         f.A2 release all scell successful
    ...         g.repeat step c-f for 5 times
    [Tags]    GH014    QC_277934    CA_LABEL-FTTF(20Mhz_FDD_n3+100Mhz_TDD_n77+40Mhz_TDD_n77+15Mhz_FDD_n28)
    Update UE capa    ${SA_Capa_Support_n3A_n28A_n77(2A)}
    Sa Ue Attach    1    1    2    11
    Setup SA non-GBR call
    Setup Vonr call
    repeat keyword    5 times    GH014
    UE Deregister From gNB    1
    Check Wireshark Log    ${CURDIR}${/}A2A_GH_014${/}a2a_gnb1.ini    wait_string=UEContextRelease::10
    Check WireShark Log GNB2    ${CURDIR}${/}A2A_GH_014${/}a2a_gnb2.ini    wait_string=IgNBCAUeContextReleaseComplete::5

CB008140-ET-GH019 nonGBR and vonr 4CC FFTT covBasedA1 IgNB-CA setup after DRX release and then DRX setup with GBR release
    [Documentation]
    ...    1. This user scenario verifies the case that DRX setup is triggered after SCell addition.In this case,
    ...       DRX configuration should be synchronized to ext-SCells.
    ...    2. Configuration:
    ...    GNB-1 Pri: cell11-FDD(n3)(pci:60) cell12-FDD(n3)(pci:61)
    ...    GNB-2 ext: cell1-TDD(n77)(pci:50) cell2-TDD(n77)(pci:51) cell13-FDD(n3)(pci:62) cell14-FDD(n28)(PCI63)
    ...    scell gnb2-cell1 gnb2-cell2 and gnb2-cell14
    ...    [Test Case Steps]
    ...         a.UE1 register to cell1_1 and setup SA non-GBR call,start both UL/DL traffic
    ...         b.add vonr call,default DRX release
    ...         c.A1 scell addition MR send from UE,FTTF 4CC add successful,CSI-RS Resource check,4 csirs P8 is used for
    ...           Scell(pci:50), 1 csirs P2 is used for Scell(pci:51)
    ...         d.release VONR GBR call,DRX setup
    ...         e.add VONR GBR call,DRX release
    ...         f.A2 release all scell successful
    ...         g.repeat step c-f for 5 times
    [Tags]    GH019    QC_277935    CA_LABEL-FTTF(20Mhz_FDD_n3+100Mhz_TDD_n77+40Mhz_TDD_n77+15Mhz_FDD_n28)
    Update UE capa    ${SA_Capa_Support_n3A_n28A_n77(2A)}
    OnlineParamChange    ${OnlineParam_GH019}
    Sa Ue Attach    1    1    2    11
    Setup SA non-GBR call
    Setup pdu2 Vonr call And No Drx Setup
    repeat keyword    5 times    GH019
    UE Deregister From gNB    1
    Check Wireshark Log    ${CURDIR}${/}A2A_GH_019${/}a2a_gnb1.ini    wait_string=UEContextRelease::10
    Check WireShark Log GNB2    ${CURDIR}${/}A2A_GH_019${/}a2a_gnb2.ini    wait_string=IgNBCAUeContextReleaseComplete::5

*** Keywords ***
Modify Cfg
    Update Cfg    set_nwslice id=1 snssai=0x01:0xD143A5 default=on ue=all amf=1 qos_flows=1,2,3,4 qos_rules=1,2,3
    Update Cfg    set_qosflow id=1 5qi=9 default=on
    Update Cfg    set_qosflow id=2 5qi=2
    Update Cfg    set_qosflow id=3 5qi=5
    Update Cfg    set_qosflow id=4 5qi=1
    Update Cfg    set_qosrule id=1 proto=tcp qos_flow=1
    Update Cfg    set_qosrule id=2 proto=udp qos_flow=2
    Update Cfg    set_qosrule id=3 proto=udp qos_flow=3
    Update Cfg    set_qosrule id=4 proto=udp qos_flow=4

Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup 2Airphone Env    fddtdd_sansa_cmwv/6cells_gnb1_2F_gnb2_2T2F

Update UE capa
    [Arguments]    ${SA_Capa_perUE_Full}=none    ${ue_id}=1
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full}
    Execute Egate Command    ${cmd}

OnlineParamChange
    [Arguments]    ${Online_Param1}
    Delta Commission Parameters    ${Online_Param1}
    Cells Should Be Onair    check_sib=${False}

Sa Ue Attach
    [Arguments]    ${ue_id}=1    ${gateway}=1    ${enb_id}=2    ${cell_id}=11
    ...    ${pass_regexp}=NG RM Register
    Execute Egate Command    ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}
    Execute Egate Command    qosflow_modify qos_flow=1 default=on
    Execute Egate Command    ue_register id=${ue_id}    ${pass_regexp}

Setup SA non-GBR call
    [Arguments]    ${ue_id}=1    ${gateway}=1
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${gateway}
    ...    pass_regexp=${default DRX setup}    timeout=10s
    Send Throuput
    Wait Until Keyword Succeeds    60s    10s    Verify Throuput on Pscell    ue_id=${ue_id}

Setup Vonr call
    [Arguments]    ${ue_id}=1
    Execute Egate Command    qosflow_modify qos_flow=3 default=on
    Execute Egate Command    ue_pdu_session_setup pdu=2 ue=${ue_id} nwslice=1 gw=2
    ...    pass_regexp=Setup QosFlow with QFI:1 5QI:5
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=2 qosflows_to_add=4 by=amf
    ...    pass_regexp=Added QosFlow with QFI:2 5QI:1

Setup pdu2 Vonr call And No Drx Setup
    [Arguments]    ${ue_id}=1
    Execute Egate Command    qosflow_modify qos_flow=3 default=on
    Execute Egate Command    ue_pdu_session_setup pdu=2 ue=${ue_id} nwslice=1 gw=2
    ...    pass_regexp=Setup QosFlow with QFI:1 5QI:5
    Execute Egate Command    ue_pdu_session_modify ue=1 pdu=2 qosflows_to_add=4 by=amf
    ...    pass_regexp=${default DRX release}    fail_regexp=drx-Config setup

Setup Non-VONR GBR 5QI-2 call
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=2 by=amf
    ...    pass_regexp=${VONR DRX release for 5QI-2 call}

Release Non-VONR GBR 5QI-2 call
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_del=2 by=amf
    ...    pass_regexp=${VONR DRX setup for 5QI-2 call release}

Add pdu2 Vonr call 5QI1
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=2 qosflows_to_add=4 by=amf
    ...    pass_regexp=${default DRX release}    fail_regexp=drx-Config setup

Release pdu2 Vonr call
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=2 qosflows_to_del=4 by=amf
    ...    pass_regexp=${default DRX setup for VONR call release}

A2 release all scell
    [Arguments]    ${ue_id}=1
    ${measid1}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=663360    event_type=A2
    ${measid2}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=657984    event_type=A2
    ${measid3}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=153370    event_type=A2
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${measid1} event=A2 scell=1 scell_rsrp=20 scell_rsrq=20
    ...    pass_regexp=rrcReconfigurationComplete
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${measid2} event=A2 scell=2 scell_rsrp=20 scell_rsrq=20
    ...    pass_regexp=rrcReconfigurationComplete
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${measid3} event=A2 scell=3 scell_rsrp=20 scell_rsrq=20
    ...    pass_regexp=rrcReconfigurationComplete
    sleep    5s    sleep for command take effective

Trigger A1 MR to add scell FFTT
    [Arguments]    ${ue_id}=1    ${rsrp}=100
    ${meas_id}    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=363850    event_type=A1
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=1 meas_id=${meas_id} event=A1 srsrq_nr=70 srsrp_nr=${rsrp}
    ...    pass_regexp=${FTTF 4CC check}
    sleep    10s    sleep for command take effective
    Verify Throuput For FFTT

UE Deregister From gNB
    [Arguments]    ${ue_id}=1
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=1    Traffic was stopped
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s

Send Throuput
    [Arguments]    ${ue_id}=1    ${pdu_id}=1
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=3    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=4    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=ul mbps=60 trf_id=1    UE ${ue_id}: UDP UL
    sleep    30s    #sleep for stable traffic

Verify Throuput on Pscell
    [Arguments]    ${ue_id}=1    ${pcell_dl}=90    ${ul}=45
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000>${pcell_dl}
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul}

Verify Throuput For FFTT
    [Arguments]    ${ue_id}=1    ${total_dl_tput}=400
    ${pcell_dl}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${pcell_dl}/1000 > 0
    ${total_dl}    Set Variable    ${pcell_dl}
    ${scell1_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=1    type=pdsch    rate_type=ave
    Should Be True    ${scell1_tput}/1000 > 0
    ${scell2_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=2    type=pdsch    rate_type=ave
    Should Be True    ${scell2_tput}/1000 > 0
    ${scell3_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=3    type=pdsch    rate_type=ave
    Should Be True    ${scell3_tput}/1000 > 0
    ${total_dl}    Evaluate    ${scell1_tput}+${scell2_tput}+${scell3_tput}+${total_dl}
    Should Be True    ${total_dl}/1000>${total_dl_tput}
    Verify Throuput UL

Verify Throuput UL
    [Arguments]    ${ue_id}=1    ${ul_tput}=45
    ${ul_throughput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pusch    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul_tput}

GH019
    Trigger A1 MR to add scell FFTT
    Release pdu2 Vonr call
    Add pdu2 Vonr call 5QI1
    A2 release all scell

GH014
    Trigger A1 MR to add scell FFTT
    Setup Non-VONR GBR 5QI-2 call
    Release Non-VONR GBR 5QI-2 call
    A2 release all scell
