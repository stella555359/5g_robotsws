*** Settings ***
Documentation
...    author:  keyun.ma@nokia-sbell.com
...    contact: keyun.ma@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup    Common Suite Setup And Setup Airphone Env Aic 2DU
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters Aic
Test Setup    Common Test Setup And Start To Capture Logs Aic
Test Teardown    Common Test Teardown And Stop Capture Logs Aic
Force Tags    QCD_MN_RAN    QCP_RAN_ET    RAN_Aic    RAN_5G    CRT    team-L3CN3_SG2    owner-kema    release-25R3
...    CLOUD_5GC_dRNIC_2vDU_P_AP_LOO_DC    master_vDU    vDUCNF00
Resource    ../../../../resources_aic/DevHZ5_resource_aic.robot

*** Variables ***
${TL_TYPE_PATH}    tdd_sansa_cmwv/FS/2du/4cells_du1_2T_du2_2T
${AP_UDPLOG_LEVEL}    1
${AP_BIP_FLAG}    True
#${AP_TTITRACE_FLAG}    True
${GNB_BIP_FLAG}    True
#${SOS_REPORT_FLAG}    pass:True,fail:True
#{SOS_REPORT_STARTUP_1_FLAG}   pass:True,fail:True
#${SNAPSHOT_FLAG}     pass:True,fail:True

@{PARAMS_IN_SCF_CU}    @{meas_Config_cell1}    @{NRREL}    @{A3_event}    @{SRB3}    @{BBPooling}    @{PLMN}
...    @{RANsharing}    @{nsaDrbParam}    @{CB008195_CU}    @{CB008195}    @{TAC}    @{other_resource_reserve}
...    @{cellDepType}    @{CA_CU}    @{HO_CU}
...    @{gnbCutyp_SANSA}    @{DRB}
...    NRBTS:actCarrierAggregation=true
...    NRBTS:maxNumScellsDl=3
...    NRBTS:maxNumScellsUl=1
...    NRBTS:caConfigurationSupport=4CCDL_2CCUL
...    NRBTS:actNgcFlexSaMode=true
...    NRCELL:actRrcReconfProcessingDelay=false
...    NRDRB_QCI-5:qciValueList=8
...    NRDRB_QCI-5:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-10
...    NRDRB_QCI-5:nrDrbQciId=5
...    NRDRB_QCI-4:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-11
...    MRBTS-1/NRBTS-1:drbRrcInactInactivityTimerSA=90
...    MRBTS-1/NRBTS-1:drbInactivityTimerSA=90
...    MRBTS-1/NRBTS-1:srbInactivityTimerSA=90
...    MRBTS-1/NRBTS-1:maxUeRrcInactTime=90
...    NRCELL:actCDrx=true
...    NRDU-2:carrierAggregationSupportList=none
...    NRDU-1:carrierAggregationSupportList=ca_Fr1Tdd_Sa, ca_Fr1Tdd_Fdd_Sa, ca_Fr1Tdd_Any_Sa
...    NRDU-1:actInterNumerologyCa=true
...    NRDU-2:actInterNumerologyCa=fasle
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRDU-2:actConnectedModeMobilityCA=fasle
...    NRCELL-1:nrarfcn=646666
...    NRCELL-3:nrarfcn=637334
...    NRCELL-1:chBw=40MHz
...    NRCELL-3:chBw=40MHz
...    NRDRB_QCI-5:qciValueList=8
...    NRDRB_QCI-5:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-10
...    NRDRB_QCI-5:nrDrbQciId=5
...    NRDRB_QCI-4:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-11
...    NRCELL:arpPrioEmergencyCall=1
...    NRBTS:actDrbPreemption=false
...    NRBTS:actUserPreemption=false
...    NRBTS:actEmergencyFallback=false
...    NRCELL:emergencyCallRestrictions:emergencyCallMrListIgnore=true
...    NRCELL:emergencyCallRestrictions:emergencyCallPlmnHoAllowed=true
...    NRCELL:actECallOverIMS=true
...    NRDRB_PDCP-2:pdcpBufDiscardEnabled=false
...    NRCELL:actVoNR=true
...    NRBTS-1/NRDRB-3:nsaDrbParam:nsa3xBearerAllowed=true
...    NRBTS-1/NRDRB-6:nsaDrbParam:nsa3xBearerAllowed=true
...    NRBTS-1/NRDRB-7:nsaDrbParam:nsa3xBearerAllowed=true
...    NRBTS-1/NRDRB-8:nsaDrbParam:nsa3xBearerAllowed=true
...    NRBTS-1/NRDRB-9:nsaDrbParam:nsa3xBearerAllowed=true
...    NRBTS-1/NRDRB-13:nsaDrbParam:nsa3xBearerAllowed=true
...    NRBTS/NRDRB-13:nsaDrbParam:dlDataSplitMode=dlOverF1U
...    delete:NRBTS/NRDRB-13:nsaDrbParam:dlPreferredPath
...    NRDU-1:numOfDrbsReservForEmergency=0
...    NRDU-2:numOfDrbsReservForEmergency=0
...    NRDRB-15:actLostPduFastRetx=false
...    NRDRB-15:maxTransferDelayGbr=20
...    NRDRB-15:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-2
...    NRDRB-15:numSduDiscard=1
...    NRDRB-15:queuingDelaySduDiscardThreshold=750
...    NRDRB-15:sduDiscardIntervalTmr=500
...    NRDRB-15:queuingDelayDiscarding=Disabled
@{PARAMS_IN_SCF_DU1}     @{SSB}    @{BBPooling}    @{PLMN}    @{RANsharing}    @{DRB}
...    @{cellDepType}    @{CB008195_DU1}    @{CB008195}    @{NRRESOURCEGROUP_PROFILE}    @{TAC}    @{other_resource_reserve}
...    @{RANsharing_DU}    @{gnbCutyp_SANSA}
...    NRDU-1:numOfDrbsReservForEmergency=0
...    NRCELL:sCellDeactivationTimerGNB=infinity
...    NRCELL:actEmergencyCallExtensions=false
...    NRBTS:actScheUePooling=true
...    NRCELL:maxNumPdschAllocationPerSlot=2
...    NRCELL:msg1FrequencyStart=18
...    delete:NRCELL:configuredEpsTac
...    NRBTS:actMultiDrbNSA=true
...    NRCELL:actShortBsrLimitAdaptation=true
...    NRCELL-1/NRREL-1:nrRelId=1
...    NRDRB_QCI-5:qciValueList=8
...    NRDRB_QCI-5:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-10
...    NRDRB_QCI-5:nrDrbQciId=5
...    NRDRB_QCI-4:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-11
...    NRDU-1:flexibleCAMode=NumberCellAmount
...    NRDU-1:actInterNumerologyCa=true
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRCELL:actCDrx=true
...    NRCELL:actPrachMultiplexing=false
...    NRCELL:actK1Opt=intra-gNB
...    NRDU-1:carrierAggregationSupportList=ca_Fr1Tdd_Sa, ca_Fr1Tdd_Fdd_Sa, ca_Fr1Tdd_Any_Sa
...    NRCELL-1:gscnOrSsPbchArfcn=7981
...    NRCELL-1:nrarfcn=646666
...    NRBTS:actSlowPrbPooling=true
...    NRCELL-3:nrarfcn=637334
...    NRCELL-3:gscnOrSsPbchArfcn=7884
...    NRCELL:chBw=40MHz
...    NRCELL:maxNumOfNbrBearers=10
...    NRCELL:nbrPdcchCongHandlingDl=true
...    NRCELL:nbrPdcchCongHandlingUl=true
...    NRCELL:nbrPdschCongHandling=true
...    NRCELL:nbrPuschCongHandling=true
...    NRBTS:actNonGbrServiceDiff=true
...    NRCELL:actNbrForNonGbrBearers=true
...    NRCELL:congWeightAlg=arpPrioPerVul
...    NRCELL:congDetectPeriod=ms100
...    NRCELL:maxNbrTrafficLimit=80
...    NRCELL:maxPrbsPerNbrUe=30
...    NRCELL:actECallOverIMS=true
...    NRDRB_RLC_UM-1:dlTReassemblyUm=ms40
...    NRDRB_RLC_UM-1:ulTReassemblyUm=ms40
...    NRDRB_RLC_UM-1:rlcUMDrbSNLength=rlcUm12bitSN
...    NRCELL:actVoNR=true
...    NRBTS/NRDRB_MAC-3:lcgid=0
...    NRDRB_MAC-4:lcgid=4
...    NRDRB_MAC-4:schedulPrio=5
...    NRDRB_MAC-4:prioritisedBitRate=16kBps
...    NRDRB_MAC-3:schedulPrio=5
...    NRDRB_MAC-3:prioritisedBitRate=16kBps
...    NRDRB_MAC-5:lcgid=7
...    NRDRB_MAC-5:schedulPrio=5
...    NRDRB_MAC-5:prioritisedBitRate=16kBps
...    NRDRB_MAC-6:lcgid=7
...    NRDRB_MAC-6:schedulPrio=5
...    NRDRB_MAC-6:prioritisedBitRate=16kBps
...    NRDRB-15:maxRlcQueueingDelayGbr=20
...    NRBTS/NRDRB-5:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-5
...    NRBTS/NRDRB-6:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-5
...    NRBTS/NRDRB-10:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-6
...    NRBTS/NRDRB-11:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-6
...    NRBTS/NRDRB-13:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-6
...    NRDRB-15:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-4
...    NRBTS/NRDRB-10:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-3
...    NRDRB-15:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRDRB-15:priorityLevel=1
...    NRBTS/NRDRB_MAC-5:nbrDl=200
...    NRBTS/NRDRB_MAC-5:nbrUl=200
...    NRBTS-1/NRDRB_MAC-5:schedulBSD=5ms
...    NRBTS/NRDRB_MAC-6:nbrUl=200
...    NRBTS/NRDRB_MAC-6:nbrDl=200
...    NRBTS/NRDRB_MAC-6:schedulBSD=5ms
...    NRBTS/NRDRB_MAC-4:schedulBSD=5ms
...    NRCELL:actBeamforming=false
...    NRCELL:actExternalAntennaBF=false
...    NRCELL:actCsirsMultiplexing=true
...    NRCELL:beamSet:externalAntennaType=0
...    NRCELL:actAdmissionCtrlSr=true
...    NRCELL:actSrAllocOpt=true
...    NRBTS-1/BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=96
...    NRBTS/NRRESOURCEGROUP_PROFILE-1:bypassRgLimits=0
...    NRBTS/NRRESOURCEGROUP_PROFILE-2:bypassRgLimits=0
#...    @{CB012631_para}

@{CB012631_para}
...    NRCELL:actSssgSwitching=eMBB UEs
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

@{PARAMS_IN_SCF_DU2}    @{SSB}    @{BBPooling}    @{PLMN}    @{RANsharing}    @{DRB}
...    @{cellDepType}   @{CB008195_DU2}    @{CB008195}    @{NRRESOURCEGROUP_PROFILE}    @{TAC}    @{other_resource_reserve}
...    @{RANsharing_DU}    @{gnbCutyp_SANSA}
...    NRCELL:sCellDeactivationTimerGNB=infinity
...    NRBTS-1/BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=96
...    NRCELL:maxNumOfNbrBearers=10
...    NRCELL:actEmergencyCallExtensions=false
...    NRDU-2:numOfDrbsReservForEmergency=0
...    NRBTS:actScheUePooling=true
...    NRCELL:maxNumPdschAllocationPerSlot=2
...    NRCELL:msg1FrequencyStart=18
...    delete:NRCELL:configuredEpsTac
...    NRBTS:actMultiDrbNSA=true
...    NRCELL:actShortBsrLimitAdaptation=true
...    NRBTS:actSlowPrbPooling=true
...    NRCELL-2/NRREL-1:nrRelId=1
...    NRDRB_QCI-5:qciValueList=8
...    NRDRB_QCI-5:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-10
...    NRDRB_QCI-5:nrDrbQciId=5
...    NRDRB_QCI-4:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-11
...    NRDU-2:flexibleCAMode=NumberCellAmount
...    NRDU-2:actInterNumerologyCa=false
...    NRDU-2:actConnectedModeMobilityCA=false
...    NRCELL:actCDrx=true
...    NRCELL:actPrachMultiplexing=false
...    NRCELL:actK1Opt=intra-gNB
...    NRDU-2:carrierAggregationSupportList=none
...    NRDRB-15:priorityLevel=1
...    NRCELL:nbrPdcchCongHandlingDl=true
...    NRCELL:nbrPdcchCongHandlingUl=true
...    NRCELL:nbrPdschCongHandling=true
...    NRCELL:nbrPuschCongHandling=true
...    NRBTS:actNonGbrServiceDiff=true
...    NRCELL:actNbrForNonGbrBearers=true
...    NRCELL:congWeightAlg=arpPrioPerVul
...    NRCELL:congDetectPeriod=ms100
...    NRCELL:maxNbrTrafficLimit=80
...    NRCELL:maxPrbsPerNbrUe=30
...    NRCELL:actECallOverIMS=true
...    NRDRB_RLC_UM-1:dlTReassemblyUm=ms40
...    NRDRB_RLC_UM-1:ulTReassemblyUm=ms40
...    NRDRB_RLC_UM-1:rlcUMDrbSNLength=rlcUm12bitSN
...    NRCELL:actVoNR=true
...    NRDRB_MAC-3:lcgid=0
...    NRDRB_MAC-4:lcgid=4
...    NRDRB_MAC-4:schedulPrio=5
...    NRDRB_MAC-4:prioritisedBitRate=16kBps
...    NRDRB_MAC-3:schedulPrio=5
...    NRDRB_MAC-3:prioritisedBitRate=16kBps
...    NRDRB_MAC-5:lcgid=7
...    NRDRB_MAC-5:schedulPrio=5
...    NRDRB_MAC-5:prioritisedBitRate=16kBps
...    NRDRB_MAC-6:lcgid=7
...    NRDRB_MAC-6:schedulPrio=5
...    NRDRB_MAC-6:prioritisedBitRate=16kBps
...    NRDRB-15:maxRlcQueueingDelayGbr=20
...    NRBTS/NRDRB-5:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-5
...    NRBTS/NRDRB-6:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-5
...    NRBTS/NRDRB-10:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-6
...    NRBTS/NRDRB-11:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-6
...    NRBTS/NRDRB-13:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-6
...    NRDRB-15:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-4
...    NRBTS/NRDRB-10:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-3
...    NRDRB-15:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRBTS/NRDRB_MAC-5:nbrDl=200
...    NRBTS/NRDRB_MAC-5:nbrUl=200
...    NRBTS/NRDRB_MAC-6:nbrUl=200
...    NRBTS/NRDRB_MAC-6:nbrDl=200
...    NRBTS/NRDRB_MAC-6:schedulBSD=5ms
...    NRBTS/NRDRB_MAC-4:schedulBSD=5ms
...    NRBTS/NRDRB_MAC-5:schedulBSD=5ms
...    NRCELL:actAdmissionCtrlSr=true
...    NRCELL:actSrAllocOpt=true

@{HO_CU}
...    NRBTS-1:actInterFreqHoSA=true
...    NRBTS-1:actIntraFreqHoSA=true
...    NRPMRNL-1:miNrRelReportCu=15min

@{CA_CU}
...    NRBTS:actIncXn=true
...    NRDU-1:flexibleCAMode=NumberCellAmount
...    NRDU-1:actInterNumerologyCa=true
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRDU-2:flexibleCAMode=NumberCellAmount
...    NRDU-2:actInterNumerologyCa=false
...    NRDU-2:actConnectedModeMobilityCA=false
...    NRBTS:actMeasBasedSCellAdditionNsa=true
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS-1:actHoOptimizationCa=true
...    NRCELL:thresholdSCellSwapSourceRsrp=66
...    NRCELL:thresholdSCellSwapSourceRsrq=67
...    NRCELL:a1MeasSCellAddEnabled=rsrp
...    NRCELL:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=70|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=90|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrq:a1HysteresisSCellAddSsbRsrq=0|a1TimeToTriggerSCellAddSsbRsrq=320ms
...    NRCELL:a1MeasSCellAddSsbRsrq:a1ThresholdSCellAddSsbRsrq=30|a1TimeToTriggerSCellAddSsbRsrq=320ms
...    NRCELL:a3MeasEnabled=rsrp
...    NRCELL:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0|a3OffsetSsbRsrp=20|a3TimeToTriggerSsbRsrp=ms64
...    NRCELL:absThreshSsbRsrpConsolidation=1
...    NRCELL:sMeasConfigSsbRsrp=1
...    NRCELL:a2MeasSCellRelEnabled=none
...    NRCELL:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0
...    NRCELL:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=34
...    NRCELL:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-2:weightForSCellSelection=50
...    NRCELL-4:weightForSCellSelection=50
...    NRCELL-1:weightForSCellSelection=80
...    NRCELL-3:weightForSCellSelection=80

@{DRB}
...    NRBTS/NRDRB-5:priorityLevel=68
...    NRBTS/NRDRB-6:priorityLevel=68
...    NRBTS/NRDRB-10:priorityLevel=2
...    NRBTS/NRDRB-11:priorityLevel=3
...    NRBTS/NRDRB-13:priorityLevel=17
...    NRDRB_5QI-6:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-15
...    NRDRB_5QI-6:fiveqiValueList=1
...    NRDRB-15:actDddsReduction=false
...    NRDRB-15:discardTimer=150ms
...    NRDRB-15:dlFlowControlAlgo=none
...    NRDRB-15:dscp=46
...    NRBTS/NRDRB-15:durationThresDiscardDl=40
...    NRBTS/NRDRB-15:durationThresDiscardUl=20
...    NRDRB-15:maxDataRateGbrDl=1000
...    NRDRB-15:maxDataRateGbrUl=1000
...    NRDRB-15:maxDddsPeriodCpuOvld=40
...    NRDRB-15:resType=GBR
...    NRDRB-15:rlcMode=RLC_UM
...    NRDRB-15:schedulWeight=1
...    NRDRB-15:volThresDiscardDl=8000
...    NRDRB-15:volThresDiscardUl=800
...    NRBTS/NRDRB-10:resType=nonGBR_Signaling
...    NRDRB-15:cellAggrLevel=Not FR1 CA eligible
@{NRREL}
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-1:gNbId=1
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-1:removeNotAllowed=false
...    NRCELL-1/NRREL-1:lcrId=3
...    NRCELL-1/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-1:sCellPrio=1

@{A3_event}
...    NRCELL:a3MeasEnabled=rsrp
...    NRCELL:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRCELL:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL:absThreshSsbRsrpConsolidation=1
...    NRCELL:filterCoeffSsbRsrp=fc4
...    NRCELL:sMeasConfigSsbRsrp=1

@{SRB3}
...    NRBTS-1:srb3SupportEnabled=true
...    NRBTS-1:cipherPrefL:nea0=1
...    NRBTS-1:cipherPrefL:nea1_128=3
...    NRBTS-1:cipherPrefL:nea2_128=4
...    NRBTS-1:cipherPrefL:nea3_128=2
...    NRBTS-1:integrityProtPrefL:nia0=0
...    NRBTS-1:integrityProtPrefL:nia1_128=3
...    NRBTS-1:integrityProtPrefL:nia2_128=4
...    NRBTS-1:integrityProtPrefL:nia3_128=2

@{SSB}
...    NRCELL:cbraPreamblesPerSsb=n60
...    NRCELL:rsrpThresholdSSB=11

@{meas_Config_cell1}
...    NRBTS:nsaInactivityTimer=600
...    NRBTS:actInterFreqIntraGnbMobilityNSA=true
...    NRBTS:actIntraFreqIntraGnbMobilityNSA=true
...    NRBTS-1/NRCELL:a3MeasEnabled=rsrp
...    NRBTS-1/NRCELL:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRBTS-1/NRCELL:a3MeasSsbRsrp:a3OffsetSsbRsrp=20
...    NRBTS-1/NRCELL:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms64

@{BBPooling}
...    NRBTS:actConnRrcPooling=true


@{RANsharing}
...    NRBTS:actRanSharing=true
...    NRBTS:actRanSharingEnh=disabled
...    NRBTS:actTrsSepaSARanSharing=false
...    NRCELL/NRPLMNSET_NSA-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1,MRBTS-1/NRBTS-1/NRPLMN-2
...    NRCELL/NRPLMNSET_SA-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1,MRBTS-1/NRBTS-1/NRPLMN-2
...    NRCELL/NRPLMNSET_SA-1:ranAC=0
...    NRCELL/NRPLMNSET_SA-1:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-200
...    NRCELL:allowUnsuppBcOrBcs=accept unknown band combinations

@{RANsharing_DU}
...    NRCELL/NRPLMNSET_NSA-1:configuredEpsTac=222
@{gnbCutyp_SANSA}
...    NRBTS:gNbCuType=SA+NSA
...    delete:MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRLIM-1

@{nsaDrbParam}
...    NRBTS:actMultiDrbNSA=true
...    NRBTS-1/NRDRB-10:nsaDrbParam:dlPreferredPath=F1-U
...    NRBTS-1/NRDRB-10:nsaDrbParam:actPrioritizeX2AfterInactivity=true
...    NRBTS-1/NRDRB-10:nsaDrbParam:actX2DuplicateTxNSA3x=false
...    NRBTS-1/NRDRB-10:nsaDrbParam:dlDataSplitBufferBuildUpThreshold=5
...    NRBTS-1/NRDRB-10:nsaDrbParam:dlDataSplitBufferBuildUpThresholdPrioritizeX2=5
...    NRBTS-1/NRDRB-10:nsaDrbParam:dlDataSplitGainThreshold=5
...    NRBTS-1/NRDRB-10:nsaDrbParam:dlDataSplitMode=dlOverF1UX2U
...    NRBTS-1/NRDRB-10:nsaDrbParam:inactivityThresholdForPrioritizeX2=300
...    NRBTS-1/NRDRB-10:nsaDrbParam:inactivityThresholdForRestartPrioritizeX2=100
...    NRBTS-1/NRDRB-10:nsaDrbParam:inactPeriodX2PdcpDuplication=300
...    NRBTS-1/NRDRB-10:nsaDrbParam:initialDLTrafficRouting=initDLoverX2U
...    NRBTS-1/NRDRB-10:nsaDrbParam:nsa3xBearerAllowed=true
...    NRBTS-1/NRDRB-10:nsaDrbParam:prioritizeX2Period=500
...    NRBTS-1/NRDRB-10:nsaDrbParam:ulDataPath=ulOverNr
...    NRBTS-1/NRDRB-10:nsaDrbParam:ulDataSplitThreshold=infinity
...    NRBTS-1/NRDRB-11:nsaDrbParam:dlPreferredPath=F1-U
...    NRBTS-1/NRDRB-11:nsaDrbParam:actPrioritizeX2AfterInactivity=true
...    NRBTS-1/NRDRB-11:nsaDrbParam:actX2DuplicateTxNSA3x=false
...    NRBTS-1/NRDRB-11:nsaDrbParam:dlDataSplitBufferBuildUpThreshold=5
...    NRBTS-1/NRDRB-11:nsaDrbParam:dlDataSplitBufferBuildUpThresholdPrioritizeX2=5
...    NRBTS-1/NRDRB-11:nsaDrbParam:dlDataSplitGainThreshold=5
...    NRBTS-1/NRDRB-11:nsaDrbParam:dlDataSplitMode=dlOverF1UX2U
...    NRBTS-1/NRDRB-11:nsaDrbParam:inactivityThresholdForPrioritizeX2=300
...    NRBTS-1/NRDRB-11:nsaDrbParam:inactivityThresholdForRestartPrioritizeX2=100
...    NRBTS-1/NRDRB-11:nsaDrbParam:inactPeriodX2PdcpDuplication=300
...    NRBTS-1/NRDRB-11:nsaDrbParam:initialDLTrafficRouting=initDLoverX2U
...    NRBTS-1/NRDRB-11:nsaDrbParam:nsa3xBearerAllowed=true
...    NRBTS-1/NRDRB-11:nsaDrbParam:prioritizeX2Period=500
...    NRBTS-1/NRDRB-11:nsaDrbParam:ulDataPath=ulOverNr
...    NRBTS-1/NRDRB-11:nsaDrbParam:ulDataSplitThreshold=infinity
...    NRBTS-1/NRDRB-12:nsaDrbParam:dlPreferredPath=F1-U
...    NRBTS-1/NRDRB-12:nsaDrbParam:actPrioritizeX2AfterInactivity=true
...    NRBTS-1/NRDRB-12:nsaDrbParam:actX2DuplicateTxNSA3x=false
...    NRBTS-1/NRDRB-12:nsaDrbParam:dlDataSplitBufferBuildUpThreshold=5
...    NRBTS-1/NRDRB-12:nsaDrbParam:dlDataSplitBufferBuildUpThresholdPrioritizeX2=5
...    NRBTS-1/NRDRB-12:nsaDrbParam:dlDataSplitGainThreshold=5
...    NRBTS-1/NRDRB-12:nsaDrbParam:dlDataSplitMode=dlOverF1UX2U
...    NRBTS-1/NRDRB-12:nsaDrbParam:inactivityThresholdForPrioritizeX2=300
...    NRBTS-1/NRDRB-12:nsaDrbParam:inactivityThresholdForRestartPrioritizeX2=100
...    NRBTS-1/NRDRB-12:nsaDrbParam:inactPeriodX2PdcpDuplication=300
...    NRBTS-1/NRDRB-12:nsaDrbParam:initialDLTrafficRouting=initDLoverX2U
...    NRBTS-1/NRDRB-12:nsaDrbParam:nsa3xBearerAllowed=true
...    NRBTS-1/NRDRB-12:nsaDrbParam:prioritizeX2Period=500
...    NRBTS-1/NRDRB-12:nsaDrbParam:ulDataPath=ulOverNr
...    NRBTS-1/NRDRB-12:nsaDrbParam:ulDataSplitThreshold=infinity
...    NRBTS-1/NRDRB-13:nsaDrbParam:dlPreferredPath=F1-U
...    NRBTS-1/NRDRB-13:nsaDrbParam:actPrioritizeX2AfterInactivity=true
...    NRBTS-1/NRDRB-13:nsaDrbParam:actX2DuplicateTxNSA3x=false
...    NRBTS-1/NRDRB-13:nsaDrbParam:dlDataSplitBufferBuildUpThreshold=5
...    NRBTS-1/NRDRB-13:nsaDrbParam:dlDataSplitBufferBuildUpThresholdPrioritizeX2=5
...    NRBTS-1/NRDRB-13:nsaDrbParam:dlDataSplitGainThreshold=5
...    NRBTS-1/NRDRB-13:nsaDrbParam:dlDataSplitMode=dlOverF1UX2U
...    NRBTS-1/NRDRB-13:nsaDrbParam:inactivityThresholdForPrioritizeX2=300
...    NRBTS-1/NRDRB-13:nsaDrbParam:inactivityThresholdForRestartPrioritizeX2=100
...    NRBTS-1/NRDRB-13:nsaDrbParam:inactPeriodX2PdcpDuplication=300
...    NRBTS-1/NRDRB-13:nsaDrbParam:initialDLTrafficRouting=initDLoverX2U
...    NRBTS-1/NRDRB-13:nsaDrbParam:nsa3xBearerAllowed=true
...    NRBTS-1/NRDRB-13:nsaDrbParam:prioritizeX2Period=500
...    NRBTS-1/NRDRB-13:nsaDrbParam:ulDataPath=ulOverNr
...    NRBTS-1/NRDRB-13:nsaDrbParam:ulDataSplitThreshold=infinity
...    NRBTS-1/NRDRB-14:nsaDrbParam:dlPreferredPath=F1-U
...    NRBTS-1/NRDRB-14:nsaDrbParam:actPrioritizeX2AfterInactivity=true
...    NRBTS-1/NRDRB-14:nsaDrbParam:actX2DuplicateTxNSA3x=false
...    NRBTS-1/NRDRB-14:nsaDrbParam:dlDataSplitBufferBuildUpThreshold=5
...    NRBTS-1/NRDRB-14:nsaDrbParam:dlDataSplitBufferBuildUpThresholdPrioritizeX2=5
...    NRBTS-1/NRDRB-14:nsaDrbParam:dlDataSplitGainThreshold=5
...    NRBTS-1/NRDRB-14:nsaDrbParam:dlDataSplitMode=dlOverF1UX2U
...    NRBTS-1/NRDRB-14:nsaDrbParam:inactivityThresholdForPrioritizeX2=300
...    NRBTS-1/NRDRB-14:nsaDrbParam:inactivityThresholdForRestartPrioritizeX2=100
...    NRBTS-1/NRDRB-14:nsaDrbParam:inactPeriodX2PdcpDuplication=300
...    NRBTS-1/NRDRB-14:nsaDrbParam:initialDLTrafficRouting=initDLoverX2U
...    NRBTS-1/NRDRB-14:nsaDrbParam:nsa3xBearerAllowed=true
...    NRBTS-1/NRDRB-14:nsaDrbParam:prioritizeX2Period=500
...    NRBTS-1/NRDRB-14:nsaDrbParam:ulDataPath=ulOverNr
...    NRBTS-1/NRDRB-14:nsaDrbParam:ulDataSplitThreshold=infinity

@{cellDepType}
...    NRCELL:cellDepType=SA+NSA
...    delete:NRCELL:ranAC
...    delete:NRCELL:trackingAreaDN



@{CB008195_DU1}
...    MRBTS/NRBTS:rgMinQuotaReservationLevel=cell_and_multicell_level
...    NRBTS/NRPMRNL-1:miNrCellUtilPerPLMN=disabled
...    NRCELL-1:nrResourceGroupProfileRacDN=NRRESOURCEGROUP_PROFILE-1
...    NRCELL-3:nrResourceGroupProfileRacDN=NRRESOURCEGROUP_PROFILE-2
@{CB008195_DU2}
...    MRBTS/NRBTS:rgMinQuotaReservationLevel=cell_and_multicell_level
...    NRBTS/NRPMRNL-1:miNrCellUtilPerPLMN=disabled
...    NRCELL-2:nrResourceGroupProfileRacDN=NRRESOURCEGROUP_PROFILE-1
@{CB008195_CU}
...    NRCELL:sliceAwareAdmissionCtrlEnabled=true
...    NRBTS-1/NRCELL-1:sliceAwareAdmissionCtrlEnabled=true
...    NRBTS-1/NRCELL-3:sliceAwareAdmissionCtrlEnabled=true
...    NRBTS-1/NRCELL-2:sliceAwareAdmissionCtrlEnabled=true
@{CB008195}
...    NRBTS:actSliceAwareAdmissionCtrl=true
...    NRBTS:actSpidBasedSlicingNSA=false
...    NRBTS:actSliceAwareScheduler=false
...    NRBTS:actDrbPreemption=false
...    NRBTS:actUserPreemption=false
...    NRBTS/NRCELL:actPriorityAccess=false
...    NRBTS/NRCELL:actEmergencyCall=true
...    NRBTS/NRPMRNL-1:miNrCellUtilPerNrg=5min


@{NRRESOURCEGROUP_PROFILE}
#NRRESOURCEGROUP_PROFILE-0 - PLMN1 and PLMN2
...    NRBTS-1/NRRESOURCEGROUP_PROFILE-1:defaultRgSaList:nrResourceGroupId=1|nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS-1/NRRESOURCEGROUP_PROFILE-1:defaultRgSaList:nrResourceGroupId=1|nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-2
...    NRBTS-1/NRRESOURCEGROUP_PROFILE-1:defaultRgNsaList:nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1|nrResourceGroupId=1
...    NRBTS-1/NRRESOURCEGROUP_PROFILE-1:defaultRgNsaList:nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-2|nrResourceGroupId=2
...    NRBTS-1/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-1:nrResourceList:resourceDN=SNSSAI-1|resourceDN=NRPLMN-1
...    NRBTS-1/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-1:racParams:maxQuota=24
...    NRBTS-1/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-1:racParams:minQuota=14
...    NRBTS-1/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-2:nrResourceList:resourceDN=SNSSAI-2|resourceDN=NRPLMN-2
...    NRBTS-1/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-2:racParams:maxQuota=76
...    NRBTS-1/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-2:racParams:minQuota=75
...    NRBTS-1/NRRESOURCEGROUP_PROFILE-1:nrResourceGroupProfileId=1
...    NRBTS-1/NRRESOURCEGROUP_PROFILE-2:defaultRgSaList:nrResourceGroupId=1|nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS-1/NRRESOURCEGROUP_PROFILE-2:defaultRgSaList:nrResourceGroupId=1|nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-2
...    NRBTS-1/NRRESOURCEGROUP_PROFILE-2:defaultRgNsaList:nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1|nrResourceGroupId=1
...    NRBTS-1/NRRESOURCEGROUP_PROFILE-2:defaultRgNsaList:nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-2|nrResourceGroupId=2
...    NRBTS-1/NRRESOURCEGROUP_PROFILE-2/NRRESOURCEGROUP-1:nrResourceList:resourceDN=SNSSAI-1|resourceDN=NRPLMN-1
...    NRBTS-1/NRRESOURCEGROUP_PROFILE-2/NRRESOURCEGROUP-1:racParams:maxQuota=74
...    NRBTS-1/NRRESOURCEGROUP_PROFILE-2/NRRESOURCEGROUP-1:racParams:minQuota=24
...    NRBTS-1/NRRESOURCEGROUP_PROFILE-2/NRRESOURCEGROUP-2:nrResourceList:resourceDN=SNSSAI-2|resourceDN=NRPLMN-2
...    NRBTS-1/NRRESOURCEGROUP_PROFILE-2/NRRESOURCEGROUP-2:racParams:maxQuota=26
...    NRBTS-1/NRRESOURCEGROUP_PROFILE-2/NRRESOURCEGROUP-2:racParams:minQuota=0
...    NRBTS-1/NRRESOURCEGROUP_PROFILE-2:nrResourceGroupProfileId=2

@{PLMN}
...    MRBTS-1/NRBTS-1/NRPLMN-1:mcc=311
...    MRBTS-1/NRBTS-1/NRPLMN-1:mnc=489
...    MRBTS-1/NRBTS-1/NRPLMN-1:mncLength=3
...    MRBTS-1/NRBTS-1/NRPLMN-2:mcc=311
...    MRBTS-1/NRBTS-1/NRPLMN-2:mnc=490
...    MRBTS-1/NRBTS-1/NRPLMN-2:mncLength=3
...    NRBTS/SNSSAI-1:sst=1
...    NRBTS/SNSSAI-1:sd=13714341
...    NRBTS/SNSSAI-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1,MRBTS-1/NRBTS-1/NRPLMN-2
...    NRBTS/SNSSAI-2:sst=1
...    NRBTS/SNSSAI-2:sd=13714342
...    NRBTS/SNSSAI-2:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1,MRBTS-1/NRBTS-1/NRPLMN-2
...    TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-1|snssaiDN=SNSSAI-1
...    TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-2|snssaiDN=SNSSAI-2

@{TAC}
...    NRBTS/TRACKINGAREA-200:fiveGsTac=280
...    delete:TRACKINGAREA-1
@{other_resource_reserve}
...    NRCELL:actPriorityAccess=false
...    NRCELL:actEmergencyCall=true
...    NRBTS:actDrbPreemption=false
...    NRBTS:actUserPreemption=false
...    NRCELL:numOfRadioResReservForTempUse=1
...    NRCELL:numOfRadioResReservForEmergency=0
...    NRCELL:numOfRadioResReservForPa=1

${SSSG_SWITCH_ATT}    M55308C00142
${SSSG_SWITCH_SUCC}    M55308C00143
${SSSG_SWITCH_ATT_REDCAP}    M55308C00146
${SSSG_SWITCH_SUCC_REDCAP}    M55308C00147

${SLOTS_UE_DENSE_SSSG}    M55308C00144
${SLOTS_UE_SPARSE_SSSG}    M55308C00145
${SLOTS_UE_DENSE_SSSG_REDCAP}    M55308C00148
${SLOTS_UE_SPARSE_SSSG_REDCAP}    M55308C00149

@{PM_Counters_Check}
...    NRCELL-1/NRRESOURCEGROUP-1:${AVG_NUM_UE_NOM_NRG}>=0
...    NRCELL-1/NRRESOURCEGROUP-1:${DNOM_SAMPLES_NRG}>0
...    NRCELL-1/NRRESOURCEGROUP-1:${AVE_NUM_NGBR_NOM_NRG}>0
...    last NRCELL-1/NRRESOURCEGROUP-1:${PEAK_NUM_UE_NRG}=5
...    last NRCELL-1/NRRESOURCEGROUP-1:${PEAK_NUM_NGBR_NRG}=10
...    NRCELL-1/NRRESOURCEGROUP-1:${NUM_ADM_REQ_NGBR_NRG}=10
...    NRCELL-1/NRRESOURCEGROUP-1:${NUM_ADM_SUC_NGBR_NRG}=10
...    NRCELL-1/NRRESOURCEGROUP-1:${NUM_ADM_REQ_UE_NRG}=5
...    NRCELL-1/NRRESOURCEGROUP-1:${NUM_ADM_SUC_UE_NRG}=5
...    NRCELL-1/NRRESOURCEGROUP-1:${RAC_REJ_DUE_DRB_MAX_QUOTA_NRG}=0
...    NRCELL-1/NRRESOURCEGROUP-1:${RAC_REJ_DUE_UE_MAX_QUOTA_NRG}=0
#...    NRCELL-1:NCELA:${SSSG_SWITCH_ATT}>0
#...    NRCELL-1:NCELA:${SSSG_SWITCH_SUCC}>0
#...    NRCELL-1:NCELA:${SSSG_SWITCH_ATT_REDCAP}=0
#...    NRCELL-1:NCELA:${SSSG_SWITCH_SUCC_REDCAP}=0
#...    NRCELL-1:NCELA:${SLOTS_UE_DENSE_SSSG}>0
#...    NRCELL-1:NCELA:${SLOTS_UE_SPARSE_SSSG}>0
#...    NRCELL-1:NCELA:${SLOTS_UE_DENSE_SSSG_REDCAP}=0
#...    NRCELL-1:NCELA:${SLOTS_UE_SPARSE_SSSG_REDCAP}=0

#Counter
${AVG_NUM_UE_NOM_NRG}    M55910C00005
${DNOM_SAMPLES_NRG}    M55910C00006
${AVE_NUM_NGBR_NOM_NRG}    M55910C00007
${PEAK_NUM_UE_NRG}    M55910C00010
${PEAK_NUM_NGBR_NRG}    M55910C00011
${NUM_ADM_REQ_NGBR_NRG}    M55910C00017
${NUM_ADM_SUC_NGBR_NRG}    M55910C00018
${NUM_ADM_REQ_UE_NRG}    M55910C00023
${NUM_ADM_SUC_UE_NRG}    M55910C00024
${RAC_REJ_DUE_DRB_MAX_QUOTA_NRG}    M55910C00015
${RAC_REJ_DUE_UE_MAX_QUOTA_NRG}    M55910C00016


${ue_nr_capabilities_SA_Capa_perFR_Full}    SEPARATOR=
...    E9A09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C4700FB8D85181AC1184341020E9068036B64C558D0
...    E7C471E819F604F8C48E3C873EA39F30C7942C0E070F05C00FFC007003FF0005C0080E0040004000000000000541B107582308682041E20D0
...    0656C98AB121CFB027C471E31238F21CFA8E7CC31E50B0381C3C27FFC00001FFF00000170020380100010000000000001546C4DD608C21A08
...    10748340165B262A86873E238F40CFB027C639F30C7942C0E070F02E007FE003801FF8002E0040700200020000000000002A0D88DAC118434
...    1020F941A0092D931541439F11C78C00000000000000E1E04FFF800003FFE000002E004070020002000000000000019E1E208007118000000
...    58081787850001C46000002160205E1E14000710400001058081787882001C4D000006160205E1E2680071340000205808178788C001C4D00
...    000A16020401C046805101360208B8002381A14489B1CF870A244D8E7C3851226C73E1C28913639F0E14489B1CF870A244D8E7C3F417001E0
...    0140E0A00E060120038120020301F004010000000080000100581B59534010400002594941000019652500540EAA95550B0024006814000A1
...    0100200404008010808020040200400840401002010020042020040080802004101004008040100208080100202008010D50F800081018203
...    0385058606880889098A0C0C8D8E0E8F909293139414951697A0A0C1680

${enableApplyCellRacForPrivilegedUEEC}
...    NRBTS-1/NRRESOURCEGROUP_PROFILE-1:applyCellRacForPrivilegedUE=1

@{sssg_enable}
...    Setup QosFlow with QFI:1 fiveQI:8
...    QoS Routing Table


*** Test Cases ***
CB013452_A_01_VERIFY_SUCCESS_AND_UNSUCCESS_NBR_SETUP_STATIC_CELL_LIMIT_CHECK_WITH_FAF_ONLINE_CHANGE_AND_COUNTER
    [Documentation]
    ...    NRCELL-1:gscnOrSsPbchArfcn=7981/nrarfcn=646666/chBw=40MHz
    ...    NRCELL-3:gscnOrSsPbchArfcn=7884/nrarfcn=637334/chBw=40MHz
    ...    1. Config:
    ...    [Configuration]:
    ...       GNB1: actNbrForNonGbrBearers=true, actEmergencyCall=true, ApplyCellRacForPrivilegedUE=false
    ...             numOfRadioResReservForEmergency=0
    ...       Cell1: maxNumOfNbrBearers=10, Cell3: maxNumOfNbrBearers=10
	...       Cell1 RG1: minQuota=14, maxQuota=24
    ...       Cell1 RG2: minQuota=75, maxQuota=76
    ...       Cell1 NbrBearers:RG1 [1,2] RG2 [7,7]  (maxNumOfNbrBearers*RGQuota)
    ...       Cell3 RG1: minQuota=24, maxQuota=74
    ...       Cell3 RG2: minQuota=0, maxQuota=26
    ...       Cell3 NbrBearers:RG1 [2,7] RG2 [0,2]  (maxNumOfNbrBearers*RGQuota)
    ...    2. Test Case Steps:
    ...       Step1: full commission with enable 8195.
    ...       Step2: UE81 attach to cell1 and pdu session setup with slice1.
    ...       Step3: UE82 attach to cell1 and pdu session setup with slice1.
    ...       Step4: UE81,82 setup EC pdu with slice1.
    ...       Step5: UE83,UE84 attach to cell1, setup normal and EC pdu session setup with slice1.
    ...       Step6: Delta commission to enable ApplyCellRacForPrivilegedUE.
    ...       Step7: UE85 setup EC pdu with slice1.
    ...       Step8: check counters
    ...    3. Expected Results:
    ...       Step1: cell on air.
    ...       Step2: UE81 bearer is admitted as NBR bearer by CELL1 RG1.
    ...       Step3: UE82 bearer is admitted as NON NBR bearer by CELL1 RG1 due to RG exceed limit.
    ...       Step4: UE81,82 EC bearer is admitted as NBR bearer by CELL1 RG1.
    ...       Step5: only UE83 EC bearer is admitted as NBR bearer by CELL1 RG1.
    ...              ---as maxquota exceed, paNbrReserveCell resource exhausted and ApplyCellRacForPrivilegedUE disabled.
    ...       Step6: Params can be changed successfully.
    ...       Step7: UE85 bearer is admitted as NBR bearer by CELL1 RG1.
    [Tags]
    Clear Counter Files Cu Aic    ${False}
    Clear Counter Files Du Aic    ${False}
    UE Attach and Setup PDU session    ue_id=81    cell=1    pdu=1    nwslice=1    gw=1    #admit NBR--cell1 RG1-sum1
    UE Attach and Setup PDU session    ue_id=82    cell=1    pdu=1    nwslice=1    gw=2    #admit nonNBR--cell1 RG1 exceed limit.
    Setup Emergency PDU Session for Multi Ues    ue_start=81    ue_count=2    nwslice=1    gw=3    #admit RG1 NBR--paNbrReserveCell-sum4
    UE Attach Setup Normal PDU and Emergency PDU Sessions    ue_start=83    cell=1    nwslice=1    gw=5    #admit EC RG1 NBR-sum5
    UE Attach Setup Normal PDU and Emergency PDU Sessions    ue_start=84    cell=1    nwslice=1    gw=7    #admit nonNBR
    Delta Commission Parameters Du    ${enableApplyCellRacForPrivilegedUEEC}
    UE Attach Setup Normal PDU and Emergency PDU Sessions    ue_start=85    cell=1    nwslice=1    gw=9    #admit EC RG1 NBR-sum6
    Check Counters Du Aic    ${PM_Counters_Check}

*** Keywords ***
UE Attach and Setup PDU session
    [Arguments]    ${ue_id}=1    ${cell}=1    ${pdu}=1    ${nwslice}=1    ${gw}=1    ${pass_regexp}=${sssg_enable}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell}
    Execute Egate Command    qosflow_modify qos_flow=2 priority=15 default=on
    Execute Egate Command    ue_register id=${ue_id}     pass_regexp=Received REGISTRATION COMPLETE
    Setup PDU Session    ue_id=${ue_id}    pdu=${pdu}    nwslice=${nwslice}    gw=${gw}    pass_regexp=${pass_regexp}
    Send Traffic SA    ue_id=${ue_id}

Send Traffic SA
    [Arguments]    ${ue_id}=1
    sleep    3s    wait ue in sparse state
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 dir=dl mbps=1 trf_id=1    pass_regexp=Started Downlink Internal traffic

Modify Cfg Aic
    Update Cfg Aic    set_amf_region id=1 tac_list=0,200,280,300 plmn=311:489,311:490
    Update Cfg Aic    set_nwslice id=1 snssai=0x01:13714341 default=on ue=all amf_region_id=1 plmn_list=311:489,311:490
    Update Cfg Aic    set_nwslice id=2 snssai=0x01:13714342 ue=all amf_region_id=1 plmn_list=311:489,311:490
    ${set_ue81}    catenate    set_ue simulated id=81 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...    nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0000:0:0:021645481
    ...    enb=2 cell=1 mode=nr
    ${set_ue82}    catenate    set_ue simulated id=82 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...    nea=null+zuc+aes+snow3g nia=null+zuc+aes+snow3g sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0000:0:0:021645482
    ...    enb=2 cell=1 mode=nr
    ${set_ue83}    catenate    set_ue simulated id=83 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...    nea=null+zuc+aes+snow3g nia=null+zuc+aes+snow3g sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0000:0:0:021645483
    ...    enb=2 cell=1 mode=nr
    ${set_ue84}    catenate    set_ue simulated id=84 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...    nea=null+zuc+aes+snow3g nia=null+zuc+aes+snow3g sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0000:0:0:021645484
    ...    enb=2 cell=1 mode=nr
    ${set_ue85}    catenate    set_ue simulated id=85 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...    nea=null+zuc+aes+snow3g nia=null+zuc+aes+snow3g sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0000:0:0:021645485
    ...    enb=2 cell=1 mode=nr
    Update Cfg Aic    ${set_ue81}
    Update Cfg Aic    ${set_ue82}
    Update Cfg Aic    ${set_ue83}
    Update Cfg Aic    ${set_ue84}
    Update Cfg Aic    ${set_ue85}
    Update Cfg Aic    set_qosflow id=1 5qi=6 priority=1 default=off
    Update Cfg Aic    set_qosflow id=2 5qi=8 default=on
    Update Cfg Aic    ue_param id=81 nr_usage_setting=voice_centric
    Update Cfg Aic    ue_param id=82 nr_usage_setting=voice_centric
    Update Cfg Aic    ue_param id=83 nr_usage_setting=voice_centric
    Update Cfg Aic    ue_param id=84 nr_usage_setting=voice_centric
    Update Cfg Aic    ue_param id=85 nr_usage_setting=voice_centric
    Update Cfg Aic    ue_param id=1 nr_usage_setting=voice_centric
    Update Cfg Aic    ue_param id=2 nr_usage_setting=voice_centric
    Update Cfg Aic    ue_param id=3 nr_usage_setting=voice_centric
    Update Cfg Aic    ue_param id=4 nr_usage_setting=voice_centric
    Update Cfg Aic    ue_param id=5 nr_usage_setting=voice_centric
    Update Cfg Aic    ue_param id=6 nr_usage_setting=voice_centric
    Update Cfg Aic    ue_nr_capabilities id=81 voice_over_nr=on:on:off
    Update Cfg Aic    ue_nr_capabilities id=82 voice_over_nr=on:on:off
    Update Cfg Aic    ue_nr_capabilities id=83 voice_over_nr=on:on:off
    Update Cfg Aic    ue_nr_capabilities id=84 voice_over_nr=on:on:off
    Update Cfg Aic    ue_nr_capabilities id=85 voice_over_nr=on:on:off
    Update Cfg Aic    ue_nr_capabilities id=1 voice_over_nr=on:on:off
    Update Cfg Aic    ue_nr_capabilities id=2 voice_over_nr=on:on:off
    Update Cfg Aic    ue_nr_capabilities id=3 voice_over_nr=on:on:off
    Update Cfg Aic    ue_nr_capabilities id=4 voice_over_nr=on:on:off
    Update Cfg Aic    ue_nr_capabilities id=5 voice_over_nr=on:on:off
    Update Cfg Aic    ue_nr_capabilities id=6 voice_over_nr=on:on:off
    Update Cfg Aic    ue_param id=81 ue_nr_capabilities=${ue_nr_capabilities_SA_Capa_perFR_Full}
    Update Cfg Aic    ue_param id=82 ue_nr_capabilities=${ue_nr_capabilities_SA_Capa_perFR_Full}
    Update Cfg Aic    ue_param id=83 ue_nr_capabilities=${ue_nr_capabilities_SA_Capa_perFR_Full}
    Update Cfg Aic    ue_param id=84 ue_nr_capabilities=${ue_nr_capabilities_SA_Capa_perFR_Full}
    Update Cfg Aic    ue_param id=85 ue_nr_capabilities=${ue_nr_capabilities_SA_Capa_perFR_Full}
    Update Cfg Aic    ue_param id=1 ue_nr_capabilities=${ue_nr_capabilities_SA_Capa_perFR_Full}
    Update Cfg Aic    ue_param id=2 ue_nr_capabilities=${ue_nr_capabilities_SA_Capa_perFR_Full}
    Update Cfg Aic    ue_param id=3 ue_nr_capabilities=${ue_nr_capabilities_SA_Capa_perFR_Full}
    Update Cfg Aic    ue_param id=4 ue_nr_capabilities=${ue_nr_capabilities_SA_Capa_perFR_Full}
    Update Cfg Aic    ue_param id=5 ue_nr_capabilities=${ue_nr_capabilities_SA_Capa_perFR_Full}
    Update Cfg Aic    ue_param id=6 ue_nr_capabilities=${ue_nr_capabilities_SA_Capa_perFR_Full}

Setup PDU Session
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${nwslice}=1    ${gw}=1    ${pass_regexp}=${EMPTY}
    execute egate command    set_pdu_param ue=${ue_id} pdu=${pdu} trf_type=internal
    execute egate command    ue_pdu_session_setup pdu=${pdu} ue=${ue_id} nwslice=${nwslice} gw=${gw}    ${pass_regexp}

Setup Emergency PDU Session
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${nwslice}=1    ${gw}=1    ${pass_regexp}=Setup QosFlow with QFI:1 fiveQI:6    ${priority}=1
    Execute Egate Command    qosflow_modify qos_flow=1 priority=${priority} default=on
    Execute egate command    set_pdu_param ue=${ue_id} pdu=${pdu} trf_type=internal
    Start To Capture Wireshark Log Aic    ue${ue_id}_pdu${pdu}ECsetup
    Execute egate command    ue_pdu_session_setup pdu=${pdu} ue=${ue_id} nwslice=${nwslice} gw=${gw}    ${pass_regexp}
    Execute Egate Command    qosflow_modify qos_flow=2 priority=15 default=on
    stop_capture_wireshark_log_Aic

Setup Emergency PDU Session for Multi Ues
    [Arguments]    ${ue_start}=1    ${nwslice}=1    ${gw}=1    ${ue_count}=3
    FOR    ${i}    IN RANGE    0    ${ue_count}
        ${ue_id}    Evaluate    ${ue_start}+${i}
        ${gw_id}    Evaluate    ${gw}+${i}
        Setup Emergency PDU Session    ue_id=${ue_id}    pdu=2    nwslice=${nwslice}    gw=${gw_id}    priority=2
        ...    pass_regexp=Setup QosFlow with QFI:1 fiveQI:6
    END

UE Attach Setup Normal PDU and Emergency PDU Sessions
    [Arguments]    ${ue_start}=1    ${ue_count}=1    ${cell}=1    ${nwslice}=1    ${gw}=1
    FOR    ${i}    IN RANGE    0    ${ue_count}
        ${ue_id}    Evaluate    ${ue_start}+${i}
        ${gw_id}    Evaluate    ${gw}+2*${i}
        ${gw_id2}       Evaluate    ${gw}+2*${i}+1
        UE Attach and Setup PDU session    ue_id=${ue_id}    cell=${cell}    pdu=1    nwslice=${nwslice}    gw=${gw_id}
        ...    pass_regexp=Setup QosFlow with QFI:1 fiveQI:8
        Setup Emergency PDU Session    ue_id=${ue_id}    pdu=2    nwslice=${nwslice}    gw=${gw_id2}    priority=2
        ...    pass_regexp=Setup QosFlow with QFI:1 fiveQI:6
    END
