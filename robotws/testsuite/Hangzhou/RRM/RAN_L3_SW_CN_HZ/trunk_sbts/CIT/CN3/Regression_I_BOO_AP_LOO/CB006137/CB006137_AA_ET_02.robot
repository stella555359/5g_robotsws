*** Settings ***
Documentation
...    Author:yin zhang
...    contact:yin.zhang@nokia-sbell.com
...    squad group:VRF3_7
Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CRT    CLOUD_5G_I_BOO_AP_LOO
...               team-DevHZ5_SG1    owner-feng.2.chen    release-5G22R4    CB006137
Resource    ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{5GC001765_CB007877}
...    @{CB008015_Connected_mode_Carrier_Aggregation_mobility}
...    @{5GC001390}
...    @{CB006138}
...    @{long_pucch_parameter}
...    @{consistency_param}
...    @{CA_Basic}
...    @{5QI}
...    NRCELL:actCDrx=false
...    NRBTS-1:actExtN77Support=true
...    NRBTS-1:actIntraFreqHoSA=true
...    NRCELL-1:measGapSelectionSA=favourUeThroughput
...    NRBTS:cipherPrefL:nea3_128=0
...    MRBTS-1/NRBTS-1/NRCELL-2:ulPowerControlCommon:alphaSrs=alpha09
...    MRBTS-1/NRBTS-1/NRCELL-2:ulPowerControlCommon:p0NominalSrs=-202
...    NRCELL-1/NRREL-1:sCellOperationalMode=dlAndUl
...    NRCELL-2:increasePUSCHPrepTimeULCA=true
...    NRCELL:timingAdvanceOffset=n25600
...    @{5GC000786_Voice_over_NR_introduction_VoNR}
...    @{CB006112-A_Voice_over_NR_enhancement}
...    @{CB006112-C_Voice_over_NR_enhancement}
...    @{5GC000704_Intra-Frequency_Handover_via_Xn}
...    @{relation error}

${cell2_PHY_TDD}    50
${PM_debug_print}    0x340002
${PM_debug_specific}    0x340006

@{PARAMS_IN_SWCONFIG}
...    ${PM_debug_print}=1
...    ${PM_debug_specific}=55139

@{5GC001765_CB007877}
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS:actMeasBasedSCellAdditionNsa=true
...    NRBTS:actHoOptimizationCa=true
...    NRCELL:a1MeasSCellAddEnabled=rsrp
...    NRCELL:a2MeasSCellRelEnabled=rsrp
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=31
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=111
...    NRCELL:a1MeasPCellSwitchEnabled=rsrp
...    NRCELL:a1MeasPCellSwitchSsbRsrp:a1ThresholdPCellSwitchSsbRsrp=65
...    NRCELL:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=35

@{CB008015_Connected_mode_Carrier_Aggregation_mobility}
...    NRBTS/NRDU-1:actConnectedModeMobilityCA=false
...    NRBTS:sCellMeasCycle=sf320
...    NRCELL:actK1Opt=intraAndInter-gNB
...    NRCELL-1/NRREL-2:gNbId=35
...    NRCELL-1/NRREL-2:gNbIdLength=22
...    NRCELL-1/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-2:lcrId=1
...    NRCELL-1/NRREL-2:removeNotAllowed=false
...    NRCELL-1/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-2:gnbPlmn:mncLength=3

@{add_scellAdditionMethod}
...    NRCELL-1/NRREL-1:sCellAdditionMethod=blind

@{delete_scellAdditionMethod}
...    delete:NRCELL-1/NRREL-1:sCellAdditionMethod

@{5GC001390}    NRBTS/NRDU-1:actInterNumerologyCa=true

@{CA_Basic}
...    NRBTS-1:cipherPrefL:nea0=9
...    NRCELL:primaryPathMaxQueueingDelay=10
...    NRCELL:allowUnsuppBcOrBcs=accept unknown band combinations,accept unknown BCSs
...    NRBTS-1:sCellActivationMethod=blind
...    NRBTS:actMeasBasedSCellAdditionNsa=true
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS-1:actCarrierAggregation=true
...    NRBTS-1:caConfigurationSupport=2CCDL_2CCUL
...    NRCELL:sCellDeactivationTimerGNB=infinity

@{CB006138}
...    NRBTS/NRDU-1:flexibleCAMode=MixedCAMode     #MixedCAMode ConfigurationIndependent
...    NRBTS/NRDU-1:carrierAggregationSupportList=${CA_Support_List_WithUl}
...    NRCELL-1:a2MeasPCellSwitchSsbRsrp:a2ThresholdPCellSwitchSsbRsrp=120
...    NRCELL-2:a2MeasPCellSwitchEnabled=none
...    NRCELL-1:a2MeasPCellSwitchEnabled=none
...    NRCELL-3:a2MeasPCellSwitchEnabled=none
...    NRCELL-4:a2MeasPCellSwitchEnabled=none

@{long_pucch_parameter}
...    NRBTS:actFdmScheduling=true
...    NRBTS:actFdmEnhancedScheduling=true
...    NRCELL:pucchModeSelect=longPucch

@{consistency_param}
...    NRPMRNL-1:miNrRelReportCu=5min
...    NRCELL:filterCoeffSsbRsrp=fc4
...    NRCELL:filterCoeffSsbRsrq=fc4

${CA_support_list_WithOutUl}    ca_Fdd_Fr1Tdd_Nsa,ca_Fdd_Fdd,ca_Fr1Tdd_Sa,ca_Fdd_Fr1Tdd_Sa
${CA_Support_List_WithUl}    ca_Fdd_Fr1Tdd_Nsa,ca_Fdd_Fdd,ca_Fr1Tdd_Sa,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Fr1Tdd_Sa_WithUl

@{relation error}
...    NRBTS/NRDRB_RLC_AM-1:ulTReassemblyIBCA=40
...    NRBTS/NRDRB_RLC_AM-2:ulTReassemblyIBCA=40

@{enable_UL}
...    NRBTS/NRDU-1:carrierAggregationSupportList=${CA_Support_List_WithUl}
...    NRBTS/NRDU-1:dlToUlContributionRatio=2
...    @{relation error}

@{Set_Scell_Mode_As_dlAndUL_And_CA_Support_List_WithUl}
...    NRBTS/NRDU-1:carrierAggregationSupportList=${CA_Support_List_WithUl}
...    NRBTS/NRDU-1:dlToUlContributionRatio=2
...    NRCELL-1/NRREL-1:sCellOperationalMode=dlAndUl
...    NRCELL-2:increasePUSCHPrepTimeULCA=true
...    @{relation error}

@{disable_UL}
...    NRBTS/NRDU-1:carrierAggregationSupportList=${CA_support_list_WithOutUl}
...    NRBTS/NRDU-1:dlToUlContributionRatio=101

@{Set_Scell_Mode_As_dlOnly_And_CA_support_list_WithOutUl}
...    NRBTS/NRDU-1:carrierAggregationSupportList=${CA_support_list_WithOutUl}
...    NRBTS/NRDU-1:dlToUlContributionRatio=101
...    NRCELL-1/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-2:increasePUSCHPrepTimeULCA=false
...    NRADJNRCELL-1:freqBandIndicatorNR=71

@{5QI}
...    MRBTS-1/NRBTS-1/NRDRB_PDCP-1:pdcpBufDiscardEnabled=false
...    NRDRB_5QI-6:fiveqiValueList=7
...    NRDRB_5QI-6:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-2
...    NRDRB_5QI-7:fiveqiValueList=3
...    NRDRB_5QI-7:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-5
...    NRDRB_5QI-8:fiveqiValueList=4
...    NRDRB_5QI-8:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-5

@{5QI_1-dedicated_for_Conversational_Voice-RLC_UM}
...    NRDRB_5QI-3:fiveqiValueList=1
...    NRDRB_5QI-3:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-4
...    @{NRDRB-4-RLC_UM}

@{5QI_5-IMS_signaling-RLC_AM}
...    NRDRB_5QI-1:fiveqiValueList=5
...    NRDRB_5QI-1:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-2
...    @{NRDRB-2-RLC_AM}

@{5QI_2-Video_over_NR-RLC_AM}
...    NRDRB_5QI-2:fiveqiValueList=6
...    NRDRB_5QI-2:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-2

@{NRDRB-2-RLC_AM}
...    NRDRB-2:discardTimer=infinity
...    NRDRB-2:dlFlowControlAlgo=3gppFlowControl
...    NRDRB-2:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-1
...    NRDRB-2:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-1
...    NRDRB-2:nrDrbRlcAmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_AM-1
...    NRDRB-2:rlcMode=RLC_AM
...    NRDRB-2:queuingDelayDiscarding=Controlled Delay (CoDel)

@{NRDRB-3-RLC_AM}
...    NRDRB-3:discardTimer=infinity
...    NRDRB-3:dlFlowControlAlgo=3gppFlowControl
...    NRDRB-3:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-1
...    NRDRB-3:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-1
...    NRDRB-3:nrDrbRlcAmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_AM-1
...    NRDRB-3:rlcMode=RLC_AM
...    NRDRB-3:queuingDelayDiscarding=Disabled

@{NRDRB-4-RLC_UM}
...    NRDRB-4:discardTimer=150ms
...    NRDRB-4:dlFlowControlAlgo=none
...    NRDRB-4:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-3
...    NRDRB-4:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-1
...    NRDRB-4:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRDRB-4:resType=GBR
...    NRDRB-4:cellAggrLevel=Not FR1 CA eligible
...    NRDRB-4:maxDataRateGbrDl=1000
...    NRDRB-4:maxDataRateGbrUl=1000
...    NRDRB-4:maxRlcQueueingDelayGbr=20
...    NRDRB-4:maxTransferDelayGbr=20
...    NRDRB-4:rlcMode=RLC_UM
...    NRDRB-4:queuingDelayDiscarding=Disabled
...    NRDRB-4:dscp=46
...    NRDRB-4:l2OHFactorUl=35
...    NRDRB-4:l2OHFactorDl=16
...    NRDRB_MAC-3:delayTarget=50
...    NRDRB_MAC-3:lcgid=4

@{NRDRB-5-RLC_UM}
...    NRDRB-5:discardTimer=150ms
...    NRDRB-5:dlFlowControlAlgo=none
...    NRDRB-5:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-4
...    NRDRB-5:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-1
...    NRDRB-5:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRDRB-5:resType=GBR
...    NRDRB-5:cellAggrLevel=Not FR1 CA eligible
...    NRDRB-5:maxDataRateGbrDl=1000
...    NRDRB-5:maxDataRateGbrUl=1000
...    NRDRB-5:maxRlcQueueingDelayGbr=20
...    NRDRB-5:maxTransferDelayGbr=20
...    NRDRB-5:rlcMode=RLC_UM
...    NRDRB-5:queuingDelayDiscarding=Disabled
...    NRDRB-5:dscp=46
...    NRDRB-5:l2OHFactorUl=35
...    NRDRB-5:l2OHFactorDl=16
...    NRDRB_MAC-4:delayTarget=50
...    NRDRB_MAC-4:lcgid=5


@{5GC000786_Voice_over_NR_introduction_VoNR}
...    NRCELL-1:actVoNR=true
...    @{5QI_1-dedicated_for_Conversational_Voice-RLC_UM}
...    @{5QI_5-IMS_signaling-RLC_AM}
...    @{5QI_2-Video_over_NR-RLC_AM}
...    NRDRB_5QI-5:fiveqiValueList=9
...    NRDRB_5QI-5:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-2
...    NRDRB_5QI-4:fiveqiValueList=128
...    NRDRB_5QI-4:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-5
...    @{NRDRB-5-RLC_UM}

...    NRDRB_RLC_UM-1:dlTReassemblyUm=ms15
...    NRDRB_RLC_UM-1:ulTReassemblyUm=ms15
...    NRDRB_PDCP-1:pdcpBufDiscardEnabled=false
...    NRDRB_PDCP-2:pdcpBufDiscardEnabled=false


@{CB006112-A_Voice_over_NR_enhancement}
...    NRCELL-1:actEnhancedVoNR=true
...    NRBTS:tRLFindForDUVoNR=2000ms
...    NRCELL-1:n310VoNR=n20
...    NRCELL-1:t310VoNR=4000ms
...    NRDRB_RLC_UM-1:rlcUMDrbSNLength=rlcUm6bitSN
...    NRCELL-1:actAdaptVoipTbs=true
...    NRCELL-1:actVoipPacketAggr=true

@{CB006112-C_Voice_over_NR_enhancement}
...    NRCELL-1:actGBRAdmissionControl=EnhancedVoNR
...    NRCELL-1:maxNumOfGBRBearersSA=10
...    NRCELL-1:maxGBRTrafficLimit=50
...    NRCELL-1:addNumOfGBRBearers=0
...    NRCELL-1:actVoNrMobilityThresholds=VoNrMobilityThresholds
...    NRBTS:actInterFreqHoSA=true
...    NRCELL-1:a2MeashoEnabledSA=rsrpAndRsrq
...    NRCELL-1:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0|a2TimeToTriggerHoSsbRsrpVoNr=ms256
...    NRCELL-1:a2MeashoSsbRsrpSA:a2HysteresisHoSsbRsrpVoNr=6|a2TimeToTriggerHoSsbRsrpVoNr=ms256
...    NRCELL-1:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=50|a2TimeToTriggerHoSsbRsrpVoNr=ms256
...    NRCELL-1:a2MeashoSsbRsrpSA:a2ThresholdHoSsbRsrpVoNr=60|a2TimeToTriggerHoSsbRsrpVoNr=ms256
...    NRCELL-1:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms480|a2TimeToTriggerHoSsbRsrpVoNr=ms256
...    NRCELL-1:a2MeashoSsbRsrqSA:a2HysteresishoSsbRsrqSA=0|a2TimeToTriggerHoSsbRsrqVoNr=ms256
...    NRCELL-1:a2MeashoSsbRsrqSA:a2HysteresisHoSsbRsrqVoNr=6|a2TimeToTriggerHoSsbRsrqVoNr=ms256
...    NRCELL-1:a2MeashoSsbRsrqSA:a2ThresholdhoSsbRsrqSA=20|a2TimeToTriggerHoSsbRsrqVoNr=ms256
...    NRCELL-1:a2MeashoSsbRsrqSA:a2ThresholdHoSsbRsrqVoNr=30|a2TimeToTriggerHoSsbRsrqVoNr=ms256
...    NRCELL-1:a2MeashoSsbRsrqSA:a2TimeToTriggerhoSsbRsrqSA=ms480|a2TimeToTriggerHoSsbRsrqVoNr=ms256
...    NRCELL-1:a1MeashoEnabledSA=rsrpAndRsrq
...    NRCELL-1:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0|a1TimeToTriggerHoSsbRsrpVoNr=ms256
...    NRCELL-1:a1MeashoSsbRsrpSA:a1HysteresisHoSsbRsrpVoNr=6|a1TimeToTriggerHoSsbRsrpVoNr=ms256
...    NRCELL-1:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=60|a1TimeToTriggerHoSsbRsrpVoNr=ms256
...    NRCELL-1:a1MeashoSsbRsrpSA:a1ThresholdHoSsbRsrpVoNr=70|a1TimeToTriggerHoSsbRsrpVoNr=ms256
...    NRCELL-1:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms480|a1TimeToTriggerHoSsbRsrpVoNr=ms256
...    NRCELL-1:a1MeashoSsbRsrqSA:a1HysteresishoSsbRsrqSA=0|a1TimeToTriggerHoSsbRsrqVoNr=ms256
...    NRCELL-1:a1MeashoSsbRsrqSA:a1HysteresisHoSsbRsrqVoNr=6|a1TimeToTriggerHoSsbRsrqVoNr=ms256
...    NRCELL-1:a1MeashoSsbRsrqSA:a1ThresholdhoSsbRsrqSA=30|a1TimeToTriggerHoSsbRsrqVoNr=ms256
...    NRCELL-1:a1MeashoSsbRsrqSA:a1ThresholdHoSsbRsrqVoNr=40|a1TimeToTriggerHoSsbRsrqVoNr=ms256
...    NRCELL-1:a1MeashoSsbRsrqSA:a1TimeToTriggerhoSsbRsrqSA=ms480|a1TimeToTriggerHoSsbRsrqVoNr=ms256
...    NRCELL-1/NRHOIF-1:a3MeasEnabled=rsrpAndRsrq
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0|a3TimeToTriggerSsbRsrpVoNr=ms256
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrpVoNr=2|a3TimeToTriggerSsbRsrpVoNr=ms256
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=3|a3TimeToTriggerSsbRsrpVoNr=ms256
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrpVoNr=2|a3TimeToTriggerSsbRsrpVoNr=ms256
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms480|a3TimeToTriggerSsbRsrpVoNr=ms256
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrq:a3HysteresisSsbRsrq=0|a3TimeToTriggerSsbRsrqVoNr=ms256
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrq:a3HysteresisSsbRsrqVoNr=2|a3TimeToTriggerSsbRsrqVoNr=ms256
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrq:a3OffsetSsbRsrq=3|a3TimeToTriggerSsbRsrqVoNr=ms256
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrq:a3OffsetSsbRsrqVoNr=2|a3TimeToTriggerSsbRsrqVoNr=ms256
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrq:a3TimeToTriggerSsbRsrq=ms480|a3TimeToTriggerSsbRsrqVoNr=ms256
...    NRCELL-1/NRHOIF-1:a5MeasEnabled=rsrpAndRsrq
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5HysteresisSsbRsrp=0|a5TimeToTriggerSsbRsrpVoNr=ms256
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5HysteresisSsbRsrpVoNr=2|a5TimeToTriggerSsbRsrpVoNr=ms256
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5Threshold1SsbRsrp=40|a5TimeToTriggerSsbRsrpVoNr=ms256
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5Threshold1SsbRsrpVoNr=50|a5TimeToTriggerSsbRsrpVoNr=ms256
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5Threshold2SsbRsrp=50|a5TimeToTriggerSsbRsrpVoNr=ms256
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5Threshold2SsbRsrpVoNr=60|a5TimeToTriggerSsbRsrpVoNr=ms256
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms480|a5TimeToTriggerSsbRsrpVoNr=ms256
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrq:a5HysteresisSsbRsrq=0|a5TimeToTriggerSsbRsrqVoNr=ms256
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrq:a5HysteresisSsbRsrqVoNr=2|a5TimeToTriggerSsbRsrqVoNr=ms256
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrq:a5Threshold1SsbRsrq=10|a5TimeToTriggerSsbRsrqVoNr=ms256
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrq:a5Threshold1SsbRsrqVoNr=20|a5TimeToTriggerSsbRsrqVoNr=ms256
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrq:a5Threshold2SsbRsrq=20|a5TimeToTriggerSsbRsrqVoNr=ms256
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrq:a5Threshold2SsbRsrqVoNr=30|a5TimeToTriggerSsbRsrqVoNr=ms256
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrq:a5TimeToTriggerSsbRsrq=ms480|a5TimeToTriggerSsbRsrqVoNr=ms256
...    NRCELL-1/NRHOIF-1:cellDepType=SA
...    NRCELL-1/NRHOIF-1:freqBandIndicatorNR=71
...    NRCELL-1/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf3
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-1:scs=15 KHz
...    NRCELL-1/NRHOIF-1:ssbFrequency=126530
...    XNLINK-1:cPlaneIpAddr=10.0.1.124
...    NRADJGNB-1:administrativeState=Unlocked
...    NRADJGNB-1:gNbIdLength=22
...    NRADJGNB-1:gNodeBId=35
...    NRADJGNB-1:xnLinkRef=1
...    NRADJGNB-1:gnbPlmn:mcc=311|mncLength=3
...    NRADJGNB-1:gnbPlmn:mnc=489|mncLength=3

...    NRADJNRCELL-2:cellDepType=SA
...    NRADJNRCELL-2:fiveGsTac=788
...    NRADJNRCELL-2:gNbId=35
...    NRADJNRCELL-2:gNbIdLength=22
...    NRADJNRCELL-2:lcrId=1
...    NRADJNRCELL-2:nrarfcn=126530
...    NRADJNRCELL-2:physCellId=49
...    NRADJNRCELL-2:gnbPlmn:mcc=311|mncLength=3
...    NRADJNRCELL-2:gnbPlmn:mnc=489|mncLength=3

# ext_ca_Rel
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-1:gNbId=1
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:lcrId=2
...    NRCELL-1/NRREL-1:removeNotAllowed=false
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311|mncLength=3
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489|mncLength=3
...    delete:NRADJNRCELL-2:freqBandIndicatorNR
...    NRCELL-1/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-1:sCellAdditionMethod=blind

@{5GC000704_Intra-Frequency_Handover_via_Xn}
...    NRBTS:actConflictConfiguration=true
...    NRBTS:actIntraFreqHoSA=true
...    NRPMRNL-1:miNrRelReportCu=5min
...    NRCELL-1:a3MeasEnabled=rsrp
...    NRCELL-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0|a3TimeToTriggerSsbRsrp=ms320
...    NRCELL-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=3|a3TimeToTriggerSsbRsrp=ms320
...    NRCELL-1:filterCoeffSsbRsrp=fc4
...    NRCELL-1:absThreshSsbRsrpConsolidation=1
...    NRCELL-1:sMeasConfigSsbRsrp=20
...    NRBTS:actIncXn=true
...    XNLINK-2:cPlaneIpAddr=10.0.1.122
...    NRADJGNB-2:administrativeState=Unlocked
...    NRADJGNB-2:gNbIdLength=22
...    NRADJGNB-2:gNodeBId=36
...    NRADJGNB-2:xnLinkRef=2
...    NRADJGNB-2:gnbPlmn:mcc=311|mncLength=3
...    NRADJGNB-2:gnbPlmn:mnc=489|mncLength=3
...    NRADJNRCELL-1:cellDepType=SA
...    NRADJNRCELL-1:fiveGsTac=788
...    NRADJNRCELL-1:gNbId=36
...    NRADJNRCELL-1:gNbIdLength=22
...    NRADJNRCELL-1:lcrId=1
...    NRADJNRCELL-1:nrarfcn=126290
...    NRADJNRCELL-1:physCellId=48
...    NRADJNRCELL-1:ssbFrequency=127210
...    NRADJNRCELL-1:gnbPlmn:mcc=311|mncLength=3
...    NRADJNRCELL-1:gnbPlmn:mnc=489|mncLength=3

# ext_ca_Rel
...    NRCELL-1/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-10:gNbId=36
...    NRCELL-1/NRREL-10:gNbIdLength=22
...    NRCELL-1/NRREL-10:lcrId=1
...    NRCELL-1/NRREL-10:removeNotAllowed=false
...    NRCELL-1/NRREL-10:gnbPlmn:mcc=311|mncLength=3
...    NRCELL-1/NRREL-10:gnbPlmn:mnc=489|mncLength=3
...    delete:NRCELL-1/NRREL-10:sCellAdditionMethod
...    NRBTS:cipherPrefL:nea0=9|nea3_128=0

${SA_Capa_perUE_Full_old}    SEPARATOR=
...    E9A09000575F5A13160003C320016093170019C3D09009B20C39F30C7942C0E098040623807DC6C28C0D608C21A08107482406D6C98AB1A1
...    CF88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE00098000702A0D883AC1184341020F10480CAD931562439F604F
...    88E3C62471E439F51CF9863CA1607038784FEC000003FB000000260001C0AA36266B04610D04083A412030B64C55110E7C471E238F40CFB0
...    27C639F30C7942C0E070F05C007FC007001FF0004C000381506C46D608C21A0810788240656C98AB121CF88E3D813E31238F21CFA8E7CC31
...    E50B0381C3C27FFC00001FFF00000130000E007BC3C28000E230000010B0102A0F0A000388C0000042C0AC3C46000E208000030B02B0F0A0
...    0038820000042C0AC3C4C000E230000010B02B17118003882001C4100000A160561E26000713000003058158B898001C41000E140000040B
...    02B1713000388C001C46000004160562E14000710400388C0000082C0AC5C28000E20800710400001058158B898001C41000E230000020B0
...    2B170A000388C001C46000004160562E2600071180038500000102C0AC3C46000E230000030B0200E0234028809B01043D0AEC1F0A244D8E
...    7C3851226C73E1C28913639F0E14489B1CF870A244D8E7C38912244D8E7C3850206C73E044810206C73E044810206C73E044810206C73E04
...    4810206C73E044810206C73E044810206C73E044810206C73E0428103639F0005C3C6318C6318C6318C631800C07A09801E00140E0A00E06
...    01280380030120020301F0480100000000800001004000000020000040100000400800003004000020020000140100080200802000018010
...    0000E00800400000010000100080000900400001802000028010000160080040902401000018063266B2A6B052B032B066B056B296B266B0
...    16B036B012B022B07681A0800004B29282000032CA4A0800014B29202000072CA480800024B292020000B2CA480800034B292020000F2CA4
...    80800044B29202000132CA480800054B29202000172CA4A0800064B29202000062CA480629355526AAA55174AA2A82C55058AA0D154A62A9
...    3455018AA051549AAA83C5090178095028140A05028140A05028140A05028140A05028140018202018030080100210100200804030061008
...    0100202018030080600C10100C018040300610080100202018030080100220100C01804030060100C01820200401008010043543E0002040
...    6080C0E1416181A2022242628303236383A3E424A4C4E5052545A5E828305A

# 41 + 66 + 77 + 71
${SA_Capa_perUE_Full}    SEPARATOR=
...    E9A09000575F5A13160003C2A002C1262E003387A0E026C830E7CC31E50B03826010188E01F71B0A303582308682041D207036B64C558D0E
...    7C471E819F604F8C48E3C873EA39F30C7942C0E070F05C00FFC0070005F0003C000E0541B107582308682041E207032B64C55890E7D813E2
...    38F1891C790E7D473E618F28581C0E1E13FB000000FEC00000078001C0AA36266B04610D04083A40E0616C98AA221CF88E3C471E819F604F
...    8C73E618F28581C0E1E0B800FF800E003FE00078001C0A836236B04610D04083C40E0656C98AB121CF88E3D813E31238F21CFA8E7CC31E50
...    B0381C3C27FFC00001FFF000000F0003801EF0F0A000388C0000042C040A83C28000E230000010B02B0F11800388200000C2C0AC3C28000E
...    208000010B02B0F13000388C0000042C0AC5C46000E208007104000028581587898001C4C00000C160562E2600071040038500000102C0AC
...    5C4C000E23000711800001058158B850001C41000E230000020B02B170A0003882001C41000004160562E26000710400388C0000082C0AC5
...    C28000E23000711800001058158B898001C46000E140000040B02B0F11800388C00000C2C0803808D00A2026C0410B42EC1F0A244D8E7C38
...    51226C73E1C28913639F0E14489B1CF870A244D8E7C38912244D8E7C3850206C73E044810206C73E044810206C73E044810206C73E044810
...    206C73E044810206C73E044810206C73E044810206C73E0428103639F0005C3C6318C6318C6318C63187A09801E00140E0A00E0601280380
...    030120020301F04801000000008000010040000000200000401000004008000030040000200200001401000802008020000180100000E008
...    00400000010000100080000900400001802000028010000160080040902401000018063266B2A6B052B032B066B056B296B266B016B036B0
...    12B022B07681A0800004B29202000032CA4A0800014B29202000072CA480800024B292020000B2CA480800034B292020000F2CA480800044
...    B29202000132CA480800054B29202000172CA4A0800064B29202000062CA480629345526AAA55174AA2A82C55058AA0D154A62A93455018A
...    A051549AAA83C5090178095028140A05028140A05028140A05028140A05028140018202018030080100210100200804030061008010020201
...    8030080600C10100C018040300610080100202018030080100220100C01804030060100C01820200401008010043543E00020406080C0E141
...    6181A2022242628303236383A3E424A4C4E5052545A5E828305A


#UE CAPA :  CA FDD (71) + TDD (41) + VoNR support :
${SA_Capa_perUE_Full_pass}    SEPARATOR=
...    E5A010000747580303000049A3000481A0603100D0098040621803506C28D618C21A0C54083E5008A2D931542C09F21CFA023C639F30C7942
...    C0E070F04E0009E003800278000E00702A0D88DAC31843418A8107CA01125B262A82873EC08F18E7CC31E50B0381C3C09FC0000007F000000
...    01C00E000B83C46000E1400000009017E0000000001C028005011801727802203014008000008818268000E7CC31E50B0303E008020000000
...    100000200F286B0268020800003AE928200002EBA4800E94555028A0219008A05028140A05028140A0000040C008018020040600400C01002
...    12A03044142464106A

${nr_capability_with_no_UL}    SEPARATOR=
...    E9A09000575F5A13160003C320016093170019C3D09009B20C39F30C7942C0E098040623807DC6C28C0D608C21A08107482406D6C98AB1A1
...    CF88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE00098000702A0D883AC1184341020F10480CAD931562439F604F
...    88E3C62471E439F51CF9863CA1607038784FEC000003FB000000260001C0AA36266B04610D04083A412030B64C55110E7C471E238F40CFB0
...    27C639F30C7942C0E070F05C007FC007001FF0004C000381506C46D608C21A0810788240656C98AB121CF88E3D813E31238F21CFA8E7CC31
...    E50B0381C3C27FFC00001FFF00000130000E007BC38280388C0000042C040A838280388C0000042C0AC3C46000E208000030B02B0F0A0003
...    8820000042C0AC3C4C000E230000010B02B17118003882001C4100000A160561E26000713000003058158B898001C41000E140000040B02B
...    1713000388C001C46000004160562C1401C41000E230000020B02B170A0003882001C41000004160562E26000710400388C0000082C0AC58
...    280388C001C46000004160562E26000711800305000040B02B0F11800388C00000C2C0803808D00A2026C0410F42BB07C28913639F0E1448
...    9B1CF870A244D8E7C3851226C73E1C28913639F0E2448913639F0E14081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B
...    1CF811204081B1CF811204081B1CF811204081B1CF810A040D8E7C00170F18C6318C6318C6318C600301E8260078005038280381804A00E0
...    00C0480080C07C120040000000200000401000000008000010040000100200000C0100000800800005004002008020080000600400003802
...    0010000000400004002000024010000060080000A004000058020010240900400006018C99ACA9AC14AC0CAC19AC15ACA5AC99AC05AC0DAC
...    04AC08AC1DA0682000012CA4A080000CB29282000052CA48080001CB29202000092CA48080002CB292020000D2CA48080003CB2920200011
...    2CA48080004CB29202000152CA48080005CB29282000192CA480800018B292018A4D5549AAA9545D2A8AA0B154162A83455298AA4D154062
...    A8145526AAA0F142405E02540A05028140A05028140A05028140A05028140A05000608080600C02004008404008020100C01840200400808
...    0600C02018030404030060100C018402004008080600C02004008804030060100C018040300608080100402004010D50F800081018203038
...    5058606880889098A0C0C8D8E0E8F909293139414951697A0A0C1680

# 41 + 41 + 78
${ue_nr_capabilities}  SEPARATOR=
...    E1A03FA0474E7AEFFFFFAFC2200782E0203C127BE7FFFFF800F00C6FBE00050370101F8E0155DF0A3FE2F08762F82087F540A083D951D2206
...    24FAC41E420F081425BE7E57771DF001DDC77C000CC005000742AEF851FF17843B17C1043FAA05041ECA8E9103127D620F2107840A12DF3F3
...    3BB8EF800EEE3BE000660028003A1577C4DFF8BC21D8BE0821FD502820F65474881893EB1079083C205096F9F95DFC7FC0077F1FF00033001
...    4001D00650389A000000C40A83C4D000C2680004C40AC1C4D080004620540E268400033102B070A0200021881507850001828000298810010
...    0A02508206811B649F0214285B24F810236C93E04085B24F810276C93E042853B649F000160C318C631BFFFE000138036002800301C1401C0
...    C4270070007000603E0488200000041000002208004000004100080000882001004001040020080220800402008410008040188200100C021
...    040020180601B072F2A2B072F2A28060800004B2CA82000032CB2A0800014B2CA02000072CB2801A83D5D2AAAA0F174AA283839804F9BF01C
...    070079BF01C070079BF01C070079BF01C070079BF01C070079BF01C070079BF01C070079BF01C070079BF01C070079BF01C07000014006004
...    00C010020808020040200801001C0180180400300A00A01801001C0180380400700A01201802001C0380180800301200A02801041C0080180
...    100300400A0080103801001004002004004010001AB0602072125262728770000000361781C06000601A0

${ue_eutra_capabilities}  SEPARATOR=
...    DD9FF430832808081705C177E0DF99ACA100220401052A000050665F3FC1BB134BC32022F7E0DD89AB230421841086104218210C108208030
...    4218018018200C100608430030022104002D1F5518502038410041460821610401051820A30410B0820082841051820838410041420820610
...    40105902E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82
...    E0B82E0B82E0B82E0B82EFC5000019B210F0F0F1708FE2E43C3C3C3C3C3C3C3C3C3C3887878787000045F830000081010440668003E71E000
...    20406080C0E162636383A83F7FC4B5A60190BFCDEA000600DB24000080000412E780C000048080C2609A143C037FC00000A00000061000880004

${GNB_SCELL_1_ADMI_REQ_SA}    M55138C01501
${GNB_SCELL_1_ADMI_SUCC_SA}    M55138C01502
${GNB_DU_SCELL_ADMI_REQ_SA}    M55139C01001
${GNB_DU_SCELL_ADMI_SUCC_SA}    M55139C01002
${GNB_DU_SCELL_1_ADMI_REQ_SA}    M55139C01003
${GNB_DU_SCELL_1_ADMI_SUCC_SA}    M55139C01004
${UE_PCELL_1_CONF_SCELL_DL_SA}    M55118C05507
${UE_SCELL_1_CONF_SCELL_DL_SA}    M55118C05508
${SCELL_CHANGE_ATT_SA}    M55118C06506
${SCELL_CHANGE_SUCC_SA}    M55118C06507

@{PM_Counters_Check_case2}
...    NRCELL-1:RSACU:${GNB_SCELL_1_ADMI_REQ_SA}=3
...    NRCELL-1:RSACU:${GNB_SCELL_1_ADMI_SUCC_SA}=3
...    NRCELL-1:RSADU:${GNB_DU_SCELL_1_ADMI_REQ_SA}=3
...    NRCELL-1:RSADU:${GNB_DU_SCELL_1_ADMI_SUCC_SA}=3
...    NRCELL-1:NCAC:${SCELL_CHANGE_SUCC_SA}=0
...    NRCELL-1:NCAC:${SCELL_CHANGE_ATT_SA}=0
...    NRCELL-1:NCAC:${UE_PCELL_1_CONF_SCELL_DL_SA}>=1
...    NRCELL-2:RSADU:${GNB_DU_SCELL_ADMI_REQ_SA}=3
...    NRCELL-2:RSADU:${GNB_DU_SCELL_ADMI_SUCC_SA}=3
...    NRCELL-2:NCAC:${UE_SCELL_1_CONF_SCELL_DL_SA}>=1

@{enable_UL_delete_NRREL}
...    delete:NRCELL-1/NRREL-1
...    @{enable_UL}

${V_1}    SEPARATOR=
...    E1A01000074E5A031E000382A003C1260C80008683803100D0098040623805506C28D608C21A08107CA0702CB64C550F027C873E819F11C78C
...    73E618F28581C0E1E0BF8000000FE000000078001C0AA36236B04650D0408380000650380F5B040A041C3BC70E418700040C9E3E2FE0000003
...    F80000001E000702A0D805AC1184341020F940E0496C98AA0A1CF88E3C639F30C7942C0E070F027F0000001FC0000000F00038002107118000
...    00001988C004C280002C00700808DFEAAAAA09801800140E0A00E06013003800301F008010000000080000100400001005CA9BCA9AC0CA0102
...    000012CA4A080000CB29282000052CA480169555D2AAAA07142401600560B0580000008030063562600020406080A0C0E10162022242632424
...    A4C4E5094C35A0

${V_2}    SEPARATOR=
...    E1A01000074E5A031E000382A003C1260C80008683803100D0098040623805506C28D608C21A08107CA0702CB64C550F027C873E819F11C78C
...    73E618F28581C0E1E0BF8000000FE000000078001C0AA36236B04650D0408380000650380F5B040A041C3BC70E418700040C9E3E2FE0000003
...    F80000001E000702A0D805AC1184341020F940E0496C98AA0A1CF88E3C639F30C7942C0E070F027F0000001FC0000000F00038002107118000
...    00001988C004C280002C00700808DFEAAAAA09801800140E0A00E06013003800301F008010000000080000100400001005CA9BCA9AC0CA0102
...    000012CA4A080000CB29282000052CA480169555D2AAAA07142401600560B0580000008030063562600020406080A0C0E10162022242632424
...    A4C4E5094C35A0

@{UE_Add_5QI-7-5-1_successful}
...    AMF-1: Setup QosFlow with QFI:1 5QI:7
...    AMF-1: Setup QosFlow with QFI:2 5QI:5
...    AMF-1: Setup QosFlow with QFI:3 5QI:1
...    QoS Routing Table

*** Test Cases ***
CB006137-AA_ET_02_01_Feature activation and deactivation via change ca_Fdd_Fr1Tdd_Sa_WithUl
    [Documentation]    flexibleCAMode= ConfigurationIndependent and Beamforming is enabled
    ...    step1:Attach UE-1 to FDD Cell without ca_Fdd_Fr1Tdd_Sa_WithUl,UE-1 F+T DL CA blind configured only;
    ...    step2:Attach UE-2 to FDD Cell with ca_Fdd_Fr1Tdd_Sa_WithUl, UE-2 F+T DL and UL CA blind configured;
    ...    step3:Attach UE-3 to FDD Cell without ca_Fdd_Fr1Tdd_Sa_WithUl,UE-1 F+T DL CA blind configured only;
    [Tags]    TC02
    Set UE Parameters Before Register And Clear Counter Files
    UE1 Register WithOutUl And Check No UL Ca Is Added In RRC Log
	UE Inter-gNB Intra-frequency HO From Rel-gNB to Sim-gNB With Traffic    ue_id=1
    UE2 Register WithUl And Check UL Ca Is Added In RRC Log
	UE Inter-gNB Intra-frequency HO From Rel-gNB to Sim-gNB With Traffic    ue_id=2
    UE3 Register WithOutUl And Check No UL Ca Is Added In RRC Log
    UE Inter-gNB Intra-frequency HO From Rel-gNB to Sim-gNB With Traffic    ue_id=3
    Check UE1 And UE3 Have No UL Ca Is Added Which UE2 Have

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    ${match_string}    Create List    GNB-3: XnAP Link with GNB-2    #GNB-4: XnAP Link with GNB-2
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/4cells_2F2T    match_string=${match_string}

Modify Cfg
    FOR    ${gateway_id}    IN RANGE    1    11
        Update Cfg    set_pdu_gateway id=${gateway_id} ue_nat_ip=72.23.${gateway_id}.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    END

	Update Cfg    ue_param id=1-10 nr_usage_setting=voice_centric ue_nr_capabilities=${SA_Capa_perUE_Full}    # pass ue_nr_capabilities
	Update Cfg    ue_nr_capabilities id=1-10 voice_over_nr=on:on:off

    ${AutoVariable_2}    catenate
    ...    set_ue simulated id=1 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...    nia=null+zuc nea=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0000:0:0:021645400 mode=nr enb=2 cell=1
    ${AutoVariable_3}    catenate
    ...    set_ue simulated id=2 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...    nia=null+zuc nea=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0000:0:0:021645401 mode=nr enb=2 cell=1
    ${AutoVariable_4}    catenate
    ...    set_ue simulated id=3 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...    nia=null+zuc nea=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0000:0:0:021645402 mode=nr enb=2 cell=1
    ${AutoVariable_5}    catenate
    ...    set_ue simulated id=4 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...    nia=null+zuc nea=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0000:0:0:021645403 mode=nr enb=2 cell=1
    ${AutoVariable_6}    catenate
    ...    set_ue simulated id=5 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...    nia=null+zuc nea=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0000:0:0:021645404 mode=nr enb=2 cell=1
    Update Cfg    ${AutoVariable_2}
    Update Cfg    ${AutoVariable_3}
    Update Cfg    ${AutoVariable_4}
    Update Cfg    ${AutoVariable_5}
    Update Cfg    ${AutoVariable_6}

    Update Cfg    amf_param id=1 full_nas_auth=on ims_voice_3gpp=on nia=null+zuc nea=null+zuc

    Update Cfg    set_qosflow id=1 5qi=1 priority=1
    Update Cfg    set_qosflow id=2 5qi=2 priority=2
    Update Cfg    set_qosflow id=3 5qi=3 priority=3
    Update Cfg    set_qosflow id=4 5qi=4 priority=4
    Update Cfg    set_qosflow id=5 5qi=5 priority=5
    Update Cfg    set_qosflow id=6 5qi=6 priority=6
    Update Cfg    set_qosflow id=7 5qi=7 default=on priority=7
    Update Cfg    set_qosflow id=8 5qi=8 priority=8
    Update Cfg    set_qosflow id=9 5qi=9 priority=9
    Update Cfg    set_qosrule id=1 proto=tcp qos_flow=1
    Update Cfg    set_qosrule id=2 proto=udp qos_flow=2
    Update Cfg    set_nwslice id=1 qos_flows=9,8,7,6,5,4,3,2,1 qos_rules=1,2 snssai=0x01:0xD143A5 default=on ue=all amf=1
    Update Cfg    set_nwslice id=2 qos_flows=9,8,7,6,5,4,3,2,1 qos_rules=1,2 snssai=0x01:0xD143A6 default=off ue=all amf=1
    ${V_3}    catenate
    ...    set_gnb id=3 type=simulated plmn=311:489 ng=10.0.1.123 gnb_id=0x24:22 daemon=10.0.2.1:22222 x2_peers=none
    ...    xn=10.0.1.122 nssai=0x1:0xd143a5 amf=1
    Update Cfg    ${V_3}
    Update Cfg    set_cell id=1 gnb=3 pci=16:0 tac=788 nrci=0x01 tdd_cell=off proxy=10.0.2.92:9999 nr_arfcn=135760:126380 gscn=1579
    Update Cfg    gnb_param id=3 xn_listening_socket=1 send_xn_setup=false
    ${V_4}    catenate
    ...    set_gnb id=4 type=simulated plmn=311:489 ng=10.0.1.125 gnb_id=0x23:22 daemon=10.0.2.1:22222 x2_peers=none
    ...    xn=10.0.1.124 nssai=0x1:0xd143a5 amf=1
    Update Cfg    ${V_4}
    Update Cfg    set_cell id=1 gnb=4 pci=16:1 tac=788 nrci=0x01 tdd_cell=off proxy=10.0.2.90:9999 nr_arfcn=135760:126380 gscn=1582
    ${AutoVariable_7}    catenate
    ...    set_cell id=1 gnb=2 pci=20:0 tac=788 nrci=0x01 tdd_cell=off
    ...    proxy=10.0.2.80:9999|10.0.2.80:8888 nr_arfcn=135760:126380 mandatory_for_activation=off
    Update Cfg    ${AutoVariable_7}

Set UE Parameters Before Register And Clear Counter Files
    Set UE Parameters
    Execute Egate Command
    ...    ue_history_information_list_add_ngran id=1 cell_type=large nrcgi=311:489|0x01 gnb_id=2 time_ue_stayed_in_cell=97
    Execute Egate Command
    ...    ue_history_information_list_add_ngran id=1 cell_type=large nrcgi=311:489|0x01 gnb_id=3 time_ue_stayed_in_cell=98
    Execute Egate Command
    ...    ue_history_information_list_add_ngran id=2 cell_type=large nrcgi=311:489|0x01 gnb_id=2 time_ue_stayed_in_cell=97
    Execute Egate Command
    ...    ue_history_information_list_add_ngran id=2 cell_type=large nrcgi=311:489|0x01 gnb_id=3 time_ue_stayed_in_cell=98
    Clear Counter Files

Set UE Parameters
    Execute Egate Command    ue_history_information_list id=1 action=commit
    Execute Egate Command    ue_history_information_list id=2 action=commit
    Execute Egate Command    ue_enb_param id=1 ue_history_list=1
    Execute Egate Command    ue_enb_param id=2 ue_history_list=2
    Execute Egate Command    gnb_param id=3 xn_listening_socket=1 send_xn_setup=true measEvent=A3
    Execute Egate Command    gnb_xn_link_up gnb=3 target=2    GNB-3: XnAP Link with GNB-2
    Execute Egate Command    gnb_param id=4 xn_listening_socket=1 send_xn_setup=true measEvent=A3
    Execute Egate Command    gnb_xn_link_up gnb=4 target=2    GNB-4: XnAP Link with GNB-2
    Execute Egate Command    set_pdu_param ue=1,2,3,4 pdu=1 trf_type=internal
    Execute Egate Command    set_pdu_param ue=1,2,3,4 pdu=2 trf_type=internal

Delta commission and wait cells onair_wa_for_restart_params
    [Arguments]    ${delta_para}
    delta commission parameters    ${delta_para}
    cells should be onair

Ue Register And Pdu Session Setup At FDD Cell-1 and check UL CA added
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_location_change id=${ue_id} enb=2 cell=1
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=UE now in NG RM Registere
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Start rrc log    log_ue_${ue_id}
    ${ret1}=    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=${ue_id} nwslice=1    SCellIndex 1 activated successfully
    Should Contain    ${ret1}    physCellId ${cell2_PHY_TDD}
    Should Contain    ${ret1}    p-Max
    Get rrc log

Ue Register And Pdu Session Setup At FDD Cell-1 and check no UL CA added
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_location_change id=${ue_id} enb=2 cell=1
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=UE now in NG RM Registere
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Start rrc log    log_ue_${ue_id}
    UE Add 5QI-7-5-1 to PDU1    ue_id=${ue_id}
    Get rrc log

Ue Register And Pdu Session Setup At FDD Cell-1 and check no CA added
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_location_change id=${ue_id} enb=2 cell=1
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=UE now in NG RM Registere
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Start rrc log    log_ue_${ue_id}
    ${ret1}=    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=${ue_id} nwslice=1    fail_regexp=sCellToAddModList
    Should not Contain    ${ret1}    SCellIndex 1 activated successfully
    Should not Contain    ${ret1}    sCellToAddModList
    Should Contain    ${ret1}    QoS Routing Table
    Get rrc log

Add qosflows
   [Arguments]    ${ue_id}=1
   Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=5 by=amf    pass_regexp=Added QosFlow with QFI:
   Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=6 by=amf    pass_regexp=Added QosFlow with QFI:

Set UE not support UL CA bandcombination
   [Arguments]    ${ue_id}=1
   Execute Egate Command    ue_param id=${ue_id} ue_nr_capabilities=${nr_capability_with_no_UL}

Online change parameters and wait cells onair
    [Arguments]    ${parameter}
    delta commission parameters    ${parameter}
    sleep    10s    #delete NRREL will cause cell restart
    Cells Should Be Onair    check_sib=${False}

Test Teardown And Stop Capture Logs and detach UE123
    Execute Egate Command    ue_deregister id=1,2,3 ue_deregister_type=switch_off    detached
    Common Test Teardown And Stop Capture Logs

Test Teardown And Stop Capture Logs and detach UE9
    Execute Egate Command    ue_deregister id=9 ue_deregister_type=switch_off    detached
    Common Test Teardown And Stop Capture Logs

Enable feature flag and delete NRREL to check no CA added
    [Arguments]    ${ue_id}=1
    Online change parameters and wait cells onair    ${enable_UL_delete_NRREL}
    Ue Register And Pdu Session Setup At FDD Cell-1 and check no CA added    ue_id=${ue_id}

Reset smf
    [Arguments]    ${amf_id}=1
	Execute Egate Command    smf_param id=${amf_id} reset

UE1 Register WithOutUl And Check No UL Ca Is Added In RRC Log
    Delta commission parameters    ${Set_Scell_Mode_As_dlOnly_And_CA_support_list_WithOutUl}
	Cells Should Be OnAir
    Ue Register And Pdu Session Setup At FDD Cell-1 and check no UL CA added    ue_id=1

UE2 Register WithUl And Check UL Ca Is Added In RRC Log
    Delta commission parameters    ${Set_Scell_Mode_As_dlAndUL_And_CA_Support_List_WithUl}
	Cells Should Be OnAir
    Reset smf
    Ue Register And Pdu Session Setup At FDD Cell-1 and check UL CA added    ue_id=2
    Add qosflows    ue_id=2

UE3 Register WithOutUl And Check No UL Ca Is Added In RRC Log
    Delta commission parameters    ${Set_Scell_Mode_As_dlOnly_And_CA_support_list_WithOutUl}
	Cells Should Be OnAir
    Ue Register And Pdu Session Setup At FDD Cell-1 and check no UL CA added    ue_id=3

Check UE1 And UE3 Have No UL Ca Is Added Which UE2 Have
    Check Logs With Au2anlysis    ${CURDIR}${/}A2A_case2${/}a2a_01.ini    p
    Check Counters    ${PM_Counters_Check_case2}

Add 5QI-7-5-1 to PDU1
    Execute Egate Command    qosflow_modify default=on qos_flow=7 priority=7 include_addl_qosflow_info=on
    Execute Egate Command    qosflow_modify qos_flow=5 priority=5
    Execute Egate Command    qosflow_modify qos_flow=1 priority=3
    Execute Egate Command    smf_param id=1 additional_qosflows_to_activate=5,1
    Execute Egate Command    ue_pdu_session_setup pdu=1 ue=2 nwslice=1 gw=10    pass_regexp=QoS Routing Table

UE Add 5QI-7-5-1 to PDU1
    [Arguments]    ${ue_id}=1
    Execute Egate Command    qosflow_modify default=on qos_flow=7 priority=7 include_addl_qosflow_info=on
    Execute Egate Command    qosflow_modify qos_flow=5 priority=5
    Execute Egate Command    qosflow_modify qos_flow=1 priority=3
    Execute Egate Command    smf_param id=1 additional_qosflows_to_activate=5,1
    ${ret1}=    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=${ue_id} nwslice=1    pass_regexp=${UE_Add_5QI-7-5-1_successful}

Handover to Sim gNB
    [Arguments]    ${ue_id}=1    ${meas_id}=3
    ${ret1}=    Execute Egate Command
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A3 srsrp_nr=50 srsrq_nr=30 phycell_id=48 nrsrp_nr=70 nrsrq_nr=30
    ...    pass_regexp=rrcReconfigurationComplete.*rrcReconfigurationComplete
    Should Contain    ${ret1}    Inter-eNB handover from EXT_ENB-2.1 to ENB-3.1 performed

Qosflow_modify
    [Arguments]    ${qos_flow}=1    ${ue_id}=1
    Execute Egate Command    qosflow_modify default=on qos_flow=${qos_flow} ue=${ue_id}

UE PDU Session Setup with Multi Qosflow
    [Arguments]    ${additional_qosflows_to_activate}=2    ${fiveQi_1}=5    ${fiveQi_2}=1    ${ue_id}=1    ${gw}=1    ${pdu}=1
    Start RRC Log    PDU_Session_Setup_with_Multi_Qosflow
    Execute Egate Command    smf_param id=1 reset
    Execute Egate Command    smf_param id=1 additional_qosflows_to_activate=${additional_qosflows_to_activate}
    ${ret1}=    Execute Egate Command    ue_pdu_session_setup pdu=${pdu} ue=${ue_id} nwslice=1 gw=${gw}    QoS Routing Table
    Should Contain    ${ret1}    Created FiveQi:Qfi mapping fiveQi ${fiveQi_1} qfi 1
    Should Contain    ${ret1}    Created FiveQi:Qfi mapping fiveQi ${fiveQi_2} qfi 2
    Execute Egate Command    smf_param id=1 reset

Start Traffic Data
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${qfi}=2
    Execute Egate Command    trf_data_start pdu=${pdu} qfi=${qfi} dir=dl kbps=12 ue=${ue_id}    Started Downlink Internal traffic
    Execute Egate Command    trf_data_start pdu=${pdu} qfi=${qfi} dir=ul kbps=12 ue=${ue_id}    Started Uplink Internal traffic

UE Inter-gNB Intra-frequency HO From Rel-gNB to Sim-gNB With Traffic
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${qfi}=1
    Start Traffic Data    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}
    sleep    15s    sleep for Tput stable
	Execute Egate Command    ue_stats_nr id=${ue_id}
    Handover to Sim gNB    ue_id=${ue_id}    meas_id=3
	Execute Egate Command    ue_stats_nr id=${ue_id}


