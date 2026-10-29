*** Settings ***
Documentation
...    author:  damon.lei@nokia-sbell.com
...    contact: damon.lei@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup    Common Suite Setup And Setup Airphone Env Aic 2DU
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters Aic
Test Setup    Common Test Setup And Start To Capture Logs Aic
Test Teardown    Common Test Teardown And Stop Capture Logs Aic
Force Tags    QCD_MN_RAN    QCP_RAN_VRF    RAN_Aic    RAN_5G    CRT    team-VRF3_SG7    owner-dalei    release-25R3
...    CLOUD_5GC_dRNIC_2vDU_P_AP_LOO_DC    master_vDU    vDUCNF00
Resource    ../../../../resources_aic/DevHZ5_resource_aic.robot
Library           taf.gnb.oam.coam.vdu.interface.Vdu    WITH NAME    vdu

*** Variables ***
${TL_TYPE_PATH}    tdd_sansa_cmwv/FS/2du/4cells_du1_2T_du2_2T
${AP_UDPLOG_LEVEL}    1
${AP_BIP_FLAG}    True
#${AP_TTITRACE_FLAG}    True
${GNB_BIP_FLAG}    True
${SOS_REPORT_FLAG}    pass:Fail,fail:True
${SOS_REPORT_STARTUP_1_FLAG}   pass:Fail,fail:True
${SNAPSHOT_FLAG}     pass:True,fail:True

@{PARAMS_IN_SCF_CU}    @{meas_Config_cell1}    @{NRREL}    @{A3_event}    @{SRB3}    @{BBPooling}    @{PLMN}
...    @{RANsharing}    @{nsaDrbParam}    @{CB008195_CU}    @{CB008195}    @{TAC}    @{other_resource_reserve}
...    @{cellDepType}    @{CA_CU}    @{HO_CU}
...    @{gnbCutyp_SANSA}    @{DRB}
...    NRBTS:actNgcFlexSaMode=true
...    NRCELL:actRrcReconfProcessingDelay=false
...    NRDRB_QCI-5:qciValueList=
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
...    @{CB012631_para}

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
...    NRCELL-1/NRREL-1:sCellAdditionMethod=covBasedA1
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

@{pdu_setup}
...    QoS Routing Table

@{FAULTS_EXCLUDED_CHECKING}    8101

@{PARAMS_ONLINE}
...    NRCELL-1:ssPbchBlockPower=8

${before_vdu_reset1}    before_vdu_reset1
${before_vdu_reset2}    before_vdu_reset2

*** Test Cases ***
CNI-119992_03_Verify L1 IQ capture after runtime modification rdAbnormalEventRachFailureEnabled msg3 NOK
    [Documentation]
    ...    This user scenario describes when runtime modification rdAbnormalEventRachFailureEnabled from 0 to 1 and
    ...    then 1 to 0, the L2 abnormal event trggered L1 IQ snapshot shall included accordingly.
    ...    persistency=oneReset in this case,the value shall back to 0 after second vDU reset.
    ...    [step]:
    ...       a. vCU,vDU startup successfully, cell on-air
    ...       b. Online change below setting via vDU WEBEM, persistency set as permanent except
    ...          rdAbnormalEventRachFailureEnabled
    ...       c. Online change rdAbnormalEventRachFailureEnabled via vDU WEBEM, persistency set as one reset
    ...       d. Enable IQ Data Config On WebEM
    ...       f. UE register and trigger msg3 failure
    ...       h. Perform vDU RESET and wait system up and cell on air
    ...       i: UE register and trigger msg3 failure
    ...       j: Perform vDU RESET and wait system up and cell on air
    ...       k: UE register and trigger msg3 failure
    [Tags]    A03
    Create vDU REST Connection
    Enable IQ Data Config On WebEM
    Set Permanent Debug Params
    Online Change RAD Debug Params Except rdAbnormalEventRachFailureEnabled
    Online Change rdAbnormalEventRachFailureEnabled    value=1    persistency=oneReset
    Set RACH Msg3 Failure    num=5
    Execute Egate Command    ue_register id=1    pass_regexp=RAR Timer has expired
    sleep    15s
    Release ues    ue_type=all
    Run Keyword And Ignore Error    Stop To Capture GNB BIP Log Aic    tag=${before_vdu_reset1}
    log to console    start vDU reset first time...
    vdu.reset_vdu    vdu_connection=${connect_du}
    sleep    480s
    Create vDU REST Connection
    Enable IQ Data Config On WebEM
    Run Keyword And Ignore Error    Start To Capture GNB BIP Log Aic
    Set RACH Msg3 Failure    num=5
    Execute Egate Command    ue_register id=1    pass_regexp=RAR Timer has expired
    sleep    15s
    Release ues    ue_type=all
    Run Keyword And Ignore Error    Stop To Capture GNB BIP Log Aic    tag=${before_vdu_reset2}
    log to console    start vDU reset second time...
    vdu.reset_vdu    vdu_connection=${connect_du}
    sleep    480s
    Create vDU REST Connection
    Enable IQ Data Config On WebEM
    Run Keyword And Ignore Error    Start To Capture GNB BIP Log Aic
    Set RACH Msg3 Failure    num=5
    Execute Egate Command    ue_register id=1    pass_regexp=RAR Timer has expired
    sleep    15s
    Release ues    ue_type=all

*** Keywords ***
Enable IQ Data Config On WebEM
    @{ul_nr_subcell_list}   create list
    &{ul_subcell_dict}  Create Dictionary
    set to dictionary  ${ul_subcell_dict}  nrCellId=${1}   subCellId=${0}
    append to list   ${ul_nr_subcell_list}   ${ul_subcell_dict}
    log to console   ${ul_nr_subcell_list}
    ${operation_id}    Activate IQ Data Configuration    ul_nr_subcell_list=${ul_nr_subcell_list}    alias=${connect_du}
    ${res_opreation}   Get Operation Status of Activating IQ Data Configuration   operation_id=${operation_id}   alias=${connect_du}
    log to console    ${res_opreation}
#    should be equal   ${res_opreation['status']}   success
    Delete Operation of Activating IQ Data Configuration   operation_id=${res_opreation['operation_id']}
    ...                                                                              alias=${connect_du}

Create vDU REST Connection
    ${connect_du}    set variable    default
    Set test variable    ${connect_du}
    vDU Login By Rest    alias=${connect_du}

Online Change RAD Debug Params
    [Arguments]    ${persistency}=persistent
    #&{para_dict}=   Create Dictionary    name=rdAbnormalEventTriggerOnlineEnable    value=1
    &{para_dict_2}=   Create Dictionary    name=rdAbnormalEventRachFailureEnabled    value=1
    &{para_dict_3}=   Create Dictionary    name=rdAbnormalEventTriggerNumber    value=5
    #&{para_dict_4}=   Create Dictionary    name=rdFeatureFlagBitmapLevel    value=4
    #&{para_dict_5}=   Create Dictionary    name=rdFeatureFlagBitmap0    value=16
    &{para_dict_6}=   Create Dictionary    name=rdAbnormalEventRlfEnabled    value=1
    &{para_dict_7}=   Create Dictionary    name=rdAbnormalEventTriggerSubcellIdForIqCapture    value=0
    @{para_list}    Create List    ${para_dict_2}    ${para_dict_3}    ${para_dict_6}    ${para_dict_7}
    ${is_success}    Update vDU RAD Debug params    persistency=${persistency}   domain_name=L2PS
    ...                 vdu_connection=${connect_du}    parameters=${para_list}
    sleep    5s

Online Change RAD Debug Params Except rdAbnormalEventRachFailureEnabled
    [Arguments]    ${persistency}=persistent
    &{para_dict_3}=   Create Dictionary    name=rdAbnormalEventTriggerNumber    value=5
    &{para_dict_6}=   Create Dictionary    name=rdAbnormalEventRlfEnabled    value=1
    @{para_list}    Create List    ${para_dict_3}    ${para_dict_6}
    ${is_success}    Update vDU RAD Debug params    persistency=${persistency}   domain_name=L2PS
    ...                 vdu_connection=${connect_du}    parameters=${para_list}
    sleep    5s

Set Permanent Debug Params
    [Arguments]    ${persistency}=persistent
    &{para_dict}=   Create Dictionary    name=rdAbnormalEventTriggerOnlineEnable    value=1
    &{para_dict_4}=   Create Dictionary    name=rdFeatureFlagBitmapLevel    value=4
    &{para_dict_5}=   Create Dictionary    name=rdFeatureFlagBitmap0    value=16
    @{para_list}    Create List    ${para_dict}    ${para_dict_4}    ${para_dict_5}
    ${is_success}    Update vDU RAD Debug params    persistency=${persistency}   domain_name=L2PS
    ...                 vdu_connection=${connect_du}    parameters=${para_list}
    sleep    5s

Online Change rdAbnormalEventRachFailureEnabled
    [Arguments]    ${value}=0    ${persistency}=persistent
    &{para_dict_rach}=   Create Dictionary    name=rdAbnormalEventRachFailureEnabled    value=${value}
    @{para_list_rach}    Create List    ${para_dict_rach}
    ${is_success}    Update vDU RAD Debug params    persistency=${persistency}   domain_name=L2PS
    ...                 vdu_connection=${connect_du}    parameters=${para_list_rach}

Online Change rdAbnormalEventTriggerSubcellIdForIqCapture
    [Arguments]    ${value}=0    ${persistency}=persistent
    &{para_dict_subcellid}=   Create Dictionary    name=rdAbnormalEventTriggerSubcellIdForIqCapture    value=${value}
    @{para_list_subcellid}    Create List    ${para_dict_subcellid}
    ${is_success}    Update vDU RAD Debug params    persistency=${persistency}   domain_name=L2PS
    ...                 vdu_connection=${connect_du}    parameters=${para_list_subcellid}

Online Change rdAbnormalEventTriggerNumber
    [Arguments]    ${value}=0    ${persistency}=persistent
    &{para_dict_number}=   Create Dictionary    name=rdAbnormalEventTriggerNumber    value=${value}
    @{para_list_number}    Create List    ${para_dict_number}
    ${is_success}    Update vDU RAD Debug params    persistency=${persistency}   domain_name=L2PS
    ...                 vdu_connection=${connect_du}    parameters=${para_list_number}

Clean Ue Testmode
    Execute Egate Command    ue_testmode_set_nr id=1 testmode=rlf action=deactivate profile_id=1
    Execute Egate Command    ue_testmode_set_nr id=1 testmode=contention_resolution action=deactivate profile_id=1

Set RACH Msg3 Failure
    [Arguments]    ${ue_id}=1    ${num}=1
    Execute Egate Command    ue_testmode_set_nr id=${ue_id} testmode=rlf action=deactivate profile_id=1
    Execute Egate Command    ue_testmode_set_nr id=${ue_id} testmode=contention_resolution action=deactivate profile_id=1
    Execute Egate Command    cont_res_testmode_nr profile_id=1 missed_ra_resp=${num}
    Execute Egate Command    ue_testmode_set_nr id=${ue_id} testmode=contention_resolution action=activate profile_id=1
    sleep    5s

Set RACH Msg4 Failure
    [Arguments]    ${ue_id}=1    ${num}=1
    Execute Egate Command    ue_testmode_set_nr id=${ue_id} testmode=rlf action=deactivate profile_id=1
    Execute Egate Command    ue_testmode_set_nr id=${ue_id} testmode=contention_resolution action=deactivate profile_id=1
    Execute Egate Command    cont_res_testmode_nr profile_id=1 msg4_nacks=${num}
    Execute Egate Command    ue_testmode_set_nr id=${ue_id} testmode=contention_resolution action=activate profile_id=1

Set RACH Msg5 Failure
    [Arguments]    ${ue_id}=1    ${num}=1
    Execute Egate Command    ue_testmode_set_nr id=${ue_id} testmode=rlf action=deactivate profile_id=1
    Execute Egate Command    ue_testmode_set_nr id=${ue_id} testmode=contention_resolution action=deactivate profile_id=1
    Execute Egate Command    cont_res_testmode_nr profile_id=1 msg5_dtx=${num}
    Execute Egate Command    ue_testmode_set_nr id=${ue_id} testmode=contention_resolution action=activate profile_id=1

Set Radio Link Failure
    [Arguments]    ${ue_id}=1    ${num}=100
    Execute Egate Command    ue_testmode_set_nr id=${ue_id} testmode=rlf action=deactivate profile_id=1
    Execute Egate Command    ue_testmode_set_nr id=${ue_id} testmode=contention_resolution action=deactivate profile_id=1
    Execute Egate Command    rlf_testmode_nr profile_id=1 num_stop_csi_report=${num}
    Execute Egate Command    ue_testmode_set_nr id=${ue_id} testmode=rlf action=activate profile_id=1

Activate IQ Data Configuration
     [Arguments]  ${ru_iq_data_parameters_list}=${None}   ${dl_nr_subcell_list}=${None}   ${ul_nr_subcell_list}=${None}
     ...  ${vdu_index}=${0}   ${gnb_index}=${0}   ${alias}=vdu_con   ${capture_on_event}=${True}
     ...  ${capture_on_event_from_l1_hi_and_l1_low}=${False}   ${capture_frame_offset}=${0}  ${buffer_cycle}=1024_FRAMES
     [Documentation]  Activate IQ Data Configuration
     ...    Author: gcao
     ...    Contact: ge.cao@nokia-sbell.com
     ...    | ru_iq_data_parameters_list | no | RU specific parameters for IQ data capture, Default is None. or e.g.
     ...      [{'nr_cell_id': 0,
     ...        'target_rmod': 'MRBTS-10950/EQM_R-1/APEQM_R-1/RMOD_R-1',
     ...        'array_elements_polarization': [{'polarization': 'MINUS_45',
     ...        'array_elements': [0],
     ...        'antenna': 'ANT1'}],
     ...        'capture_activity_timer': 1}] |
     ...    | dl_nr_subcell_list | no | List of NR dl subcell identifiers. Default is None.
     ...        :param int nr_cell_id: NR cell instance ID.
     ...        :param int sub_cell_id: NR subcell identifier.
     ...         e.g. [{'nr_cell_id': 0, 'sub_cell_id': 0}]|
     ...    | ul_nr_subcell_list | no | List of NR ul subcell identifiers. Default is None.
     ...        :param int nr_cell_id: NR cell instance ID.
     ...        :param int sub_cell_id: NR subcell identifier.
     ...        e.g. [{'nr_cell_id': 0, 'sub_cell_id': 0}] |
     ...    | alias | no | define alias of connect to vDU |
     ...    | capture_on_event | no | Flag enabling capture on event mode. Default is False. |
     ...    | capture_on_event_from_l1_hi_and_l1_low | no | Flag enabling capture on event from L1Hi(RAN NIC) and L1Low(RU).
     ...      Default is False. |
     ...    | ccapture_frame_offset | no | Capture frame offset. Default is 0. |
     ...    | buffer_cycle | no | Buffer cycle.Allowed value is 2_FRAMES, 4_FRAMES, 8_FRAMES, 16_FRAMES, 32_FRAMES,
     ...      64_FRAMES, 128_FRAMES, 256_FRAMES, 512_FRAMES, 1024_FRAMES.Default is None. |
     ...
     ...    | Return Value | Description |
     ...    | ${operation_id} | operation id |
     ...
     ...    Example
     ...    | Activate IQ Data Configuration | dl_nr_subcell_list=[{'nr_cell_id': 0, 'sub_cell_id': 0}] |
     ...
     Log To Console    ${vdu_index}
     Log To Console    ${gnb_index}
     ${operation_id}   vdu.activate_l1_iq_data_configuration   capture_on_event=${capture_on_event}
     ...   capture_on_event_from_l1_hi_and_l1_low=${capture_on_event_from_l1_hi_and_l1_low}
     ...   dl_nr_subcell_list=${dl_nr_subcell_list}   ul_nr_subcell_list=${ul_nr_subcell_list}
     ...   ru_iq_data_parameters_list=${ru_iq_data_parameters_list}    capture_frame_offset=${capture_frame_offset}
     ...   buffer_cycle=${buffer_cycle}   reason=NOT_SET    vdu_connection=${alias}
     [Return]    ${operation_id}

Get Operation Status of Activating IQ Data Configuration
    [Arguments]   ${operation_id}   ${alias}=vdu_con
    [Documentation]  Get Operation Status of Activating IQ Data Configuration
    ...    Author: gcao
    ...    Contact: ge.cao@nokia-sbell.com
    ...    | operation_id | yes | operation unique ID |
    ...    | alias | no | define alias of connect to vDU |
    ...
    ...    | Return Value | Description |
    ...    | ${res} | dict of operation_id, status, error_message, file_id |
    ...
    ...    Example
    ...    | Get Operation Status of Activating IQ Data Configuration | operation_id=1700018656120930578 |
    ...
    ${res}  vdu.get_operation_status_of_activating_l1_iq_data_configuration
    ...   operation_id=${operation_id}   vdu_connection=${alias}
    [Return]    ${res}

Delete Operation of Activating IQ Data Configuration
    [Arguments]   ${operation_id}   ${alias}=vdu_con
    [Documentation]  Delete Operation of Activating IQ Data Configuration
    ...    Author: gcao
    ...    Contact: ge.cao@nokia-sbell.com
    ...    | operation_id | yes | operation unique ID |
    ...    | alias | no | define alias of connect to vDU |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Delete Operation of Activating IQ Data Configuration | operation_id=1700018656120930578 |
    ...
    vdu.delete_operation_of_activating_l1_iq_data_configuration   operation_id=${operation_id}
    ...                                                                                     vdu_connection=${alias}

# deactivate l1 iq data configuration
Deactivate IQ Data Configuration
    [Arguments]   ${alias}=vdu_con
    [Documentation]  Deactivate IQ Data Configuration
    ...    Author: gcao
    ...    Contact: ge.cao@nokia-sbell.com
    ...    | alias | no | define alias of connect to vDU |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Deactivate IQ Data Configuration | alias=vdu_con |
    ...
    ${deactivate_operation_id}   vdu.deactivate_l1_iq_data_configuration   vdu_connection=${alias}
    [Return]    ${deactivate_operation_id}

Get Operation Status of Deactivating IQ Data Configuration
    [Arguments]   ${operation_id}   ${alias}=vdu_con
    [Documentation]  Get Operation Status of Deactivating IQ Data Configuration
    ...    Author: gcao
    ...    Contact: ge.cao@nokia-sbell.com
    ...    | operation_id | yes | operation unique ID |
    ...    | alias | no | define alias of connect to vDU |
    ...
    ...    | Return Value | Description |
    ...    | ${res} | dict of operation_id, status, error_message, file_id |
    ...
    ...    Example
    ...    | Get Operation Status of Deactivating IQ Data Configuration | operation_id=1700018656120930578 |
    ...
    ${res}   vdu.get_operation_status_of_deactivating_l1_iq_data_configuration    operation_id=${operation_id}
    ...                                                                           vdu_connection=${alias}
    [Return]    ${res}

Delete Operation of Deactivating IQ Data Configuration
    [Arguments]   ${operation_id}   ${alias}=vdu_con
    [Documentation]  Delete Operation of Deactivating IQ Data Configuration
    ...    Author: gcao
    ...    Contact: ge.cao@nokia-sbell.com
    ...    | operation_id | yes | operation unique ID |
    ...    | alias | no | define alias of connect to vDU |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Delete Operation of Deactivating IQ Data Configuration | operation_id=1700018656120930578 |
    ...
    vdu.delete_operation_of_deactivating_l1_iq_data_configuration   operation_id=${operation_id}
    ...                                                             vdu_connection=${alias}

UE Attach and Setup PDU session
    [Arguments]    ${ue_id}=1    ${cell}=1    ${pdu}=1    ${nwslice}=1    ${gw}=1    ${pass_regexp}=${pdu_setup}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell}
    #Execute Egate Command    qosflow_modify qos_flow=2 priority=15 default=on
    Execute Egate Command    ue_register id=${ue_id}     pass_regexp=Received REGISTRATION COMPLETE
    Setup PDU Session    ue_id=${ue_id}    pdu=${pdu}    nwslice=${nwslice}    gw=${gw}    pass_regexp=${pass_regexp}
    #Send Traffic SA    ue_id=${ue_id}

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

Update vDU RAD Debug params
    [Arguments]    ${persistency}=${None}    ${domain_name}=${None}    ${parameters}=${None}
    ...            ${vdu_connection}=${None}          ${node_id}=${None}        ${timeout}=30
    ...            ${time_to_check}=15
    [Documentation]    This kw is used to modify R&D debug parameters in vDU.
    ...    Author: Liu Renhui
    ...    Contact: renhui-david.liu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | persistency | no | should be persistent, notPersistent or oneReset. |
    ...                         persistent means persistent over all BTS resets.
    ...                         notPersistent means not persistent change.
    ...                         oneReset means persistent change over only one BTS reset.
    ...                         Not providing persistency means persistent.|
    ...    | domain_name | no | Specify target domain name to update params in it |
    ...    | parameters | no | list type, its element(s) is dict type. Params to be updated |
    ...    | vdu_connection | no | VduConnection object or string name alias if used |
    ...    | node_id | no | default is None means 'all node' |
    ...    | timeout | no | Timeout for the operation |
    ...    | time_to_check | no | Time to sleep to check the operation result |
    ...
    ...    | Return Value | Description |
    ...    |  | dict type | operation info
    ...
    ...    Example
    ...    | Update vDU RAD Debug params |
    ...
    ${operation_info}    vdu.update_rad_debug_params
    ...                  persistency=${persistency}   domain_name=${domain_name}
    ...                  parameters=${parameters}       vdu_connection=${vdu_connection}
    ...                  node_id=${node_id}             timeout=${timeout}
    sleep    ${time_to_check}    reason=Wait for operation succeeded
    ${is_success}=    Check vDU if RAD Debug params Update Operation Succeed
    ...               ${operation_info['operation_id']}    vdu_connection=${vdu_connection}    timeout=${timeout}
    [Return]   ${is_success}

Get vDU RAD Debug params Update Operation Status
    [Arguments]    ${operation_id}    ${vdu_connection}=${None}    ${timeout}=30
    [Documentation]    This kw is used to get R&D debug parameters update operation status.
    ...    Author: Liu Renhui
    ...    Contact: renhui-david.liu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | operation_id | no | the operation id |
    ...    | vdu_connection | no | VduConnection object or string name alias if used |
    ...    | timeout | no | Timeout for the operation |
    ...
    ...    | Return Value | Description |
    ...    |  | dict type | operation info
    ...
    ...    Example
    ...    | Get vDU RAD Debug params Update Operation Status |
    ${operation_info}    vdu.get_rad_debug_params_update_operation
    ...                         operation_id=${operation_id}
    ...                         vdu_connection=${vdu_connection}
    ...                         timeout=${timeout}
    [Return]   ${operation_info}

Check vDU if RAD Debug params Update Operation Succeed
    [Arguments]    ${operation_id}    ${vdu_connection}=${None}    ${timeout}=30
    [Documentation]    This kw is used to check if R&D debug parameters update operation succeed in vDU.
    ...    Author: Liu Renhui
    ...    Contact: renhui-david.liu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | operation_id | no | the operation id |
    ...    | vdu_connection | no | VduConnection object or string name alias if used |
    ...    | timeout | no | Timeout for the operation |
    ...
    ...    | Return Value | Description |
    ...    |  | bool type | whether the update operation succeed
    ...
    ...    Example
    ...    | Check vDU if RAD Debug params Update Operation Succeed |
    ...
    ${operation_info_latest}    Get vDU RAD Debug params Update Operation Status
    ...                         operation_id=${operation_id}
    ...                         vdu_connection=${vdu_connection}    timeout=${timeout}
    ${is_success}=    Run Keyword And Return Status
    ...               Should Be Equal    ${operation_info_latest['status']}    succeeded
    [Return]   ${is_success}

Restore vDU All Non-Default RAD Debug params To Default
    [Arguments]    ${persistency}=${None}    ${vdu_connection}=${None}
    ...            ${timeout}=30             ${time_to_check}=15
    [Documentation]    This kw is used to restore all non-default R&D debug parameters to default values.
    ...    Author: Liu Renhui
    ...    Contact: renhui-david.liu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | persistency | no | should be persistent, notPersistent or oneReset. |
    ...    | vdu_connection | no | VduConnection object or string name alias if used |
    ...    | timeout | no | Timeout for the operation |
    ...    | time_to_check | no | Time to sleep to check the operation result |
    ...
    ...    | Return Value | Description |
    ...    |  | bool type |
    ...
    ...    Example
    ...    | Restore vDU All Non-Default RAD Debug params To Default |
    ...
    log to console    \nStarting to restore vDU all non-default R&D debug parameters to default values
	${operation_info}    vdu.update_rad_debug_params    persistency=${persistency}    vdu_connection=${vdu_connection}
    ...                                                 timeout=${timeout}
    sleep    ${time_to_check}    reason=Wait for operation succeeded
    ${is_success}=    Check vDU if RAD Debug params Update Operation Succeed
    ...               ${operation_info['operation_id']}    vdu_connection=${vdu_connection}    timeout=${timeout}
    [Return]   ${is_success}

vDU Login By Rest
    [Arguments]    ${vdu_index}=0    ${gnb_index}=0    ${alias}=default
    [Documentation]    this kw is used to Login vDU By Rest
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | vdu_index | yes | The list index from tl.dus[], it will use the index of VDU |
    ...    | gnb_index | yes | The list index from tl.cu[], it will use the index of gnb |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | vDU Login By Rest |
    ...
    ${oam_httpaddr}    set variable    ${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.addr}
    ${oam_web_ip}    set variable if    ':' in '''${oam_httpaddr}'''   [${oam_httpaddr}]    ${oam_httpaddr}
    Run keyword and ignore error    vDU Logout By Rest    vdu_index=${vdu_index}
    vdu.connect to
    ...  host=${oam_web_ip}
    ...  port=${EMPTY}
    ...  username=${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.username}
    ...  password=${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.password}
    ...  secure=True
    ...  connection_name=${alias}

vDU Logout By Rest
    [Arguments]    ${vdu_index}=0    ${alias}=default
    [Documentation]  this kw is used to Logout vDU By Rest
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | vdu_index | yes | The list index from tl.dus[], it will use the index of VDU |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | vDU Logout By Rest  |
    ...
    Log    ${vdu_index} is not used
    vdu.disconnect    ${alias}

