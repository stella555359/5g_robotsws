*** Settings ***
Documentation
...    author:  baijie.zhu@nokia-sbell.com
...    contact: baijie.zhu@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_VRF    RAN_5G_TDD    SBTS00    team-Rock_SGT&A    owner-jing.ye
...    CLOUD_5G_I_BOO_AP_LOO    CRT    CB008290    release-5G23R1
...    STATE_CONFIGURED    RAN_5G
Resource    ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    NRBTS-1:cipherPrefL:nea0=8
...    NRBTS-1:cipherPrefL:nea1_128=0
...    NRBTS-1:cipherPrefL:nea2_128=0
...    NRBTS-1:cipherPrefL:nea3_128=0
...    NRBTS-1:integrityProtPrefL:nia0=0
...    NRBTS-1:integrityProtPrefL:nia1_128=0
...    NRBTS-1:integrityProtPrefL:nia2_128=0
...    NRBTS-1:integrityProtPrefL:nia3_128=9
...    @{PARAMS_FOR_IODT_ABIO_4T2F}
...    NRCELL:srsForBeamMgmt:srsPowerThresholdForDlBm=0
...    NRCELL-12:msg1FrequencyStart=11
...    @{8290_enable}
...    @{2426_disable}
...    @{784_EC_enable}
...    @{8232 HPA_call_enable}
...    @{BOO_AP_LOO}

@{BOO_AP_LOO}
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
...    NRCELL:actUlSrsBm=false
...    NRCELL:actDlSrsBm=false

@{IRAT_config}
...    NRBTS-1:actInterRatHoSA=true
...    NRBTS-1:actInterRatHoFromEutraToSA=true
...    NRBTS-1:nonContentRachAcFullConfigHo=true
...    NRBTS-1:tNgRelocExecDeltL=5000
...    NRCELL-11:measGapSelectionSA=favourUeThroughput
...    NRCELL-11:a1MeashoEnabledSA=rsrp
...    NRCELL-11:a2MeashoEnabledSA=rsrp
...    NRCELL-11:dtxOptimizedScheduler:dtxDelaySinceLastScheduling=0
...    NRCELL-11:dtxOptimizedScheduler:dtxMaxRetentionDelay=10
...    NRCELL-11:dtxOptimizedScheduler:dtxPrbThreshold=80
...    NRCELL-11:nrhoirDNList=MRBTS-1/NRBTS-1/NRHOIR-1
...    NRCELL-11/NRRELE-1:cellIndividualOffset=0dB
...    NRCELL-11/NRRELE-1:eutranCellExcluded=false
...    NRCELL-11/NRRELE-1:lcrId=1
...    NRCELL-11/NRRELE-1:eNodeBId=18
...    NRCELL-11/NRRELE-1:ecgiPlmn:mnc=489
...    NRCELL-11/NRRELE-1:ecgiPlmn:mcc=311
...    NRCELL-11/NRRELE-1:ecgiPlmn:mncLength=3
...    NRHOIR-1:allowedMeasBandwidth=mbw100
...    NRHOIR-1:b2MeashoEnabled=rsrp
...    NRHOIR-1:b2Threshold1hoRsrp=35
...    NRHOIR-1:b2Threshold1hoRsrpVoNr=35
...    NRHOIR-1:b2Threshold1hoRsrq=50
...    NRHOIR-1:b2Threshold1hoRsrqVoNr=50
...    NRHOIR-1:earfcnValue=1
...    NRHOIR-1:eutraFreqQOffsetRange=0dB
...    NRHOIR-1:eutraB2MeashoRsrp:b2HysteresishoRsrp=0|b2TimeToTriggerhoRsrpVoNr=ms512
...    NRHOIR-1:eutraB2MeashoRsrp:b2HysteresishoRsrpVoNr=4|b2TimeToTriggerhoRsrpVoNr=ms512
...    NRHOIR-1:eutraB2MeashoRsrp:b2Threshold2hoRsrp=18|b2TimeToTriggerhoRsrpVoNr=ms512
...    NRHOIR-1:eutraB2MeashoRsrp:b2Threshold2hoRsrpVoNr=28|b2TimeToTriggerhoRsrpVoNr=ms512
...    NRHOIR-1:eutraB2MeashoRsrp:b2TimeToTriggerhoRsrp=ms480|b2TimeToTriggerhoRsrpVoNr=ms512
...    NRHOIR-1:eutraB2MeashoRsrq:b2HysteresishoRsrq=0|b2TimeToTriggerhoRsrqVoNr=ms512
...    NRHOIR-1:eutraB2MeashoRsrq:b2HysteresishoRsrqVoNr=4|b2TimeToTriggerhoRsrqVoNr=ms512
...    NRHOIR-1:eutraB2MeashoRsrq:b2Threshold2hoRsrq=2|b2TimeToTriggerhoRsrqVoNr=ms512
...    NRHOIR-1:eutraB2MeashoRsrq:b2Threshold2hoRsrqVoNr=10|b2TimeToTriggerhoRsrqVoNr=ms512
...    NRHOIR-1:eutraB2MeashoRsrq:b2TimeToTriggerhoRsrq=ms480|b2TimeToTriggerhoRsrqVoNr=ms512
...    MRBTS-1/NRBTS-1/NRADJECELL-1:eNodeBId=18
...    MRBTS-1/NRBTS-1/NRADJECELL-1:ePSTrackingAreaCode=0
...    MRBTS-1/NRBTS-1/NRADJECELL-1:earfcnValue=1
...    MRBTS-1/NRBTS-1/NRADJECELL-1:lcrId=1
...    MRBTS-1/NRBTS-1/NRADJECELL-1:physCellId=11
...    MRBTS-1/NRBTS-1/NRADJECELL-1:ecgiPlmn:mcc=311
...    MRBTS-1/NRBTS-1/NRADJECELL-1:ecgiPlmn:mnc=489
...    MRBTS-1/NRBTS-1/NRADJECELL-1:ecgiPlmn:mncLength=3
...    MRBTS-1/NRBTS-1/NRADJECELL-1:enbPlmn:mcc=311
...    MRBTS-1/NRBTS-1/NRADJECELL-1:enbPlmn:mnc=489
...    MRBTS-1/NRBTS-1/NRADJECELL-1:enbPlmn:mncLength=3

@{784_EC_enable}
...    NRCELL-3:actVoNR=true
...    NRCELL-3:arpPrioEmergencyCall=2
...    NRCELL-3:actEmergencyCall=true
...    NRCELL-3:actEnhancedVoNR=true
...    NRCELL-3:actGBRAdmissionControl=EnhancedVoNR
...    NRCELL-3:emergencyCallLimServ=true
...    NRCELL-3:maxGBRTrafficLimit=80
...    NRCELL-3:emergencyCallFails=true
...    NRCELL-3:emergencyCallRestrictions:emergencyCallMrListIgnore=true
...    NRCELL-3:emergencyCallRestrictions:emergencyCallPlmnHoAllowed=true
...    NRBTS:timerXnDataFwdGuard=2000
...    NRCELL-3/NRREDRT-1:redirFreqEutra=39750
...    NRCELL-3/NRREDRT-1:redirRat=eutra
...    NRCELL-3/NRREDRT-1:redirPrio=5
...    delete:NRCELL-3/NRREDRT-1:redirSsbScs
...    NRBTS-1/NRDRB_RLC_UM-1:dlTReassemblyUm=ms40
...    NRBTS-1/NRDRB_RLC_UM-1:ulTReassemblyUm=ms40
...    NRBTS-1/NRDRB_RLC_UM-1:rlcUMDrbSNLength=rlcUm12bitSN
...    NRBTS-1/NRDRB-15:actDddsReduction=false
...    NRBTS-1/NRDRB-15:actLostPduFastRetx=false
...    NRBTS-1/NRDRB-15:dlFlowControlAlgo=none
...    NRBTS-1/NRDRB-15:dscp=46
#...    NRBTS-1/NRDRB-15:durationThresDiscard=50
...    NRBTS-1/NRDRB-15:maxDataRateGbrDl=1000
...    NRBTS-1/NRDRB-15:maxDataRateGbrUl=1000
...    NRBTS-1/NRDRB-15:maxDddsPeriodCpuOvld=40
...    NRBTS-1/NRDRB-15:maxRlcQueueingDelayGbr=20
...    NRBTS-1/NRDRB-15:maxTransferDelayGbr=20
...    NRBTS-1/NRDRB-15:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-4
...    NRBTS-1/NRDRB-15:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-2
...    NRBTS-1/NRDRB-15:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRBTS-1/NRDRB-15:numSduDiscard=1
...    NRBTS-1/NRDRB-15:queuingDelayDiscarding=Disabled
...    NRBTS-1/NRDRB-15:queuingDelaySduDiscardThreshold=750
...    NRBTS-1/NRDRB-15:resType=GBR
...    NRBTS-1/NRDRB-15:rlcMode=RLC_UM
...    NRBTS-1/NRDRB-15:schedulWeight=1
...    NRBTS-1/NRDRB-15:sduDiscardIntervalTmr=500
#...    NRBTS-1/NRDRB-15:volThresDiscard=100
...    NRBTS-1/NRDRB-15:discardTimer=100ms
...    NRBTS-1/NRDRB_5QI-6:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-15
...    NRBTS-1/NRDRB_5QI-6:fiveqiValueList=1
...    NRBTS-1/NRDRB_PDCP:maxCidAllowed=4
...    NRBTS-1/NRDRB_PDCP-2:pdcpBufDiscardEnabled=false
...    NRBTS-1/NRDRB_PDCP-2:maxCidAllowed=4
...    NRBTS-1/NRDRB_MAC-4:lcgid=4
...    NRBTS-1/NRDRB_MAC-4:schedulPrio=5
...    NRBTS-1/NRDRB_MAC-4:prioritisedBitRate=16kBps
...    NRBTS-1/NRDRB_MAC-4:schedulBSD=100ms
...    NRBTS-1/SNSSAI-2:administrativeState=Unlocked
#...    NRBTS-1/SNSSAI-2:sd=13714342
#...    NRBTS-1/SNSSAI-2:sst=1
#...    NRBTS-1/SNSSAI-2:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
#...    NRBTS-1/TRACKINGAREA-200:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1
#...    NRBTS-1/TRACKINGAREA-200:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2
...    @{SNSSAI}
...    @{TRACKINGAREA}
...    ${NRPLMNDNLIST}

@{SNSSAI}
...    SNSSAI-1:sst=1
...    SNSSAI-1:sd=13714341
...    SNSSAI-1:nrPlmnDNList=${NRPLMNDNLIST}
...    SNSSAI-2:sst=1
...    SNSSAI-2:sd=13714342
...    SNSSAI-2:nrPlmnDNList=${NRPLMNDNLIST}

@{TRACKINGAREA}
...    TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-1|snssaiDN=SNSSAI-1
...    TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-2|snssaiDN=SNSSAI-2

${NRPLMNDNLIST}    MRBTS-1/NRBTS-1/NRPLMN-1

@{2426_disable}
...    NRCELL-3:maxNumOfUsersPerNRCell=2
...    NRCELL-3:maxNumOfCaUsersNRCell=2
...    NRCELL-3:maxNumOfUsersPerCell=2
...    NRCELL-3:maxNumOfRrcSA=2
...    NRCELL-3:maxNumOfSCellAlloc=2
...    NRCELL-3:allowEmergencyReservForTempUse=false
...    NRCELL-3:numOfRadioResReservForEmergency=2
...    NRCELL-3:numOfRadioResReservForPa=2
...    NRBTS-1/NRDU-1:numOfDrbsReservForEmergency=2

@{8290_enable}
...    NRDU-1:actInterNumerologyCa=true
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRBTS-1:actCarrierAggregation=true
...    NRBTS-1:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS-1:caConfigurationSupport=2CCDL_2CCUL
...    NRBTS-1:actSCellSwapFr1=a6BasedSa
...    NRBTS-1:sCellActivationMethod=bufferBased
...    NRCELL:cellDepType=SA+NSA

...    NRCELL-3:a6MeasSCellSwapEnabled=rsrpAndRsrq
...    NRCELL-4:a6MeasSCellSwapEnabled=rsrp
...    NRCELL:a6MeasSCellSwapSsbRsrp:a6HysteresisSCellSwapSsbRsrp=0|a6OffsetSCellSwapSsbRsrp=20|a6TimeToTrigSCellSwapSsbRsrp=ms480
...    NRCELL:a6MeasSCellSwapSsbRsrq:a6HysteresisSCellSwapSsbRsrq=0|a6OffsetSCellSwapSsbRsrq=20|a6TimeToTrigSCellSwapSsbRsrq=ms480
...    NRCELL:reportAmountA6MeasSCellSwap=r4
...    NRCELL:reportIntervalA6MeasSCellSwap=ms120
...    NRCELL:thresholdSCellSwapSourceRsrp=66
...    NRCELL:thresholdSCellSwapSourceRsrq=67
...    NRCELL:a1MeasSCellAddEnabled=rsrpAndRsrq
...    NRCELL:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=70|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=90|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrq:a1HysteresisSCellAddSsbRsrq=0|a1TimeToTriggerSCellAddSsbRsrq=320ms
...    NRCELL:a1MeasSCellAddSsbRsrq:a1ThresholdSCellAddSsbRsrq=30|a1TimeToTriggerSCellAddSsbRsrq=320ms
...    NRCELL-3:weightForSCellSelection=50
...    NRCELL-4:weightForSCellSelection=50
...    NRCELL-3:actCDrx=true
...    NRCELL-4:actCDrx=true
...    NRCELL-11:actCDrx=true
...    @{NRREL}


@{NRREL}
...    NRCELL-11/NRREL-3:gNbId=1
...    NRCELL-11/NRREL-3:gNbIdLength=22
...    NRCELL-11/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-3:lcrId=3
...    NRCELL-11/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-3:sCellPrio=1
...    NRCELL-11/NRREL-4:gNbId=1
...    NRCELL-11/NRREL-4:gNbIdLength=22
...    NRCELL-11/NRREL-4:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-4:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-4:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-4:lcrId=4
...    NRCELL-11/NRREL-4:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-4:sCellPrio=2

@{8232 HPA_call_enable}
...    NRCELL-3:actPriorityAccess=true
...    NRBTS:applyPriorityAccess=HPA
...    NRBTS/NRPRIOACC_PROFILE-1:nrPlmnIdx=1
...    NRBTS/NRPRIOACC_PROFILE-1:arpPrioLevelHpaMax=8
...    NRBTS/NRPRIOACC_PROFILE-1:arpPrioLevelHpaMin=6
...    NRBTS/NRPRIOACC_PROFILE-1:arpPrioLevelMpsMax=4
...    NRBTS/NRPRIOACC_PROFILE-1:arpPrioLevelMpsMin=1
...    NRCELL-3:tPageCorrInt=3000
...    NRCELL-3:raPrioritizationForAI=MPS
...    NRCELL-3:powerRampingStepHighPriorityCbra=dB4
...    NRCELL-3:powerRampingStep=dB2
...    NRCELL-3:pagingPrioLevelPaMax=1
...    NRCELL-3:pagingPrioLevelPaMin=1
...    NRCELL-3:numOfRadioResReservForPa=2

${pdu_id}    1
${nwslice}    1
@{SA_UE_list}
...    85
...    86
@{EC_ue_list}
...    1
...    2
@{HPA_ue_list}
...    3
...    4

${SA_Capa_perUE_Full}    SEPARATOR=
...    E9A09000575F5A13160003C320016093170019C3D09009B20C39F30C7942C0E098040623807DC6C28C0D608C21A08107482406D6C98AB1A1CF88E3D033EC09F1891C790E7D
...    473E618F28581C0E1E0B801FF800E000BE00088000E0541B107582308682041E2090195B262AC4873EC09F11C78C48E3C873EA39F30C7942C0E070F09FD8000007F6000000
...    44000702A8D89BAC1184341020E90480C2D931544439F11C788E3D033EC09F18E7CC31E50B0381C3C17003FF001C00FFC00110001C0AE3E236B04610D04083E50480AAD931
...    561439F11C78C00000000000000000040E1E027FFC00001FFF00000110001C00F78789A001C4100000216020541E14000711800000858158788C001C41000006160561E140
...    00710400000858158789A001C46000002160562E2300071040038820000142C0AC3C28000E268000060B02B17134003882001C28000008160562E26800711800388C000008
...    2C0AC5C28000E20800711800001058158B850001C41000E208000020B02B17134003882001C46000004160562E14000711800388C0000082C0AC5C4D000E2300070A000002
...    058158788C001C46000006160401C0468051013602086A0BB07C28913639F0E14489B1CF870A244D8E7C3851226C73E1C28913639F0E2448913639F0E14081B1CF81120408
...    1B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF810A040D8E7C00170F18C6318C6318C6318C61E8260078005038280
...    381804A00E000C0480080C07C120040000000200000401000000008000010040000100200000C0100000800800005004002008020080000600400003802001000000040000
...    4002000024010000060080000A004000058020010240900400006019CA9ACA9AC14AC0CAC19AC15ACA5AC99AC05AC0DAC04AC08AC1DA0682000012CA4A080000CB29282000
...    052CA48080001CB29202000092CA48080002CB292020000D2CA48080003CB29202000112CA48080004CB29202000152CA48080005CB29282000192CA480800018B292019A5
...    5574AAAA9545D2A8AA0B154162A83455298AA4D154062A8145526AAA0F142405E02540A05028140A05028140A05028140A05028140A05000608080600C0200400840400802
...    0100C018402004008080600C02018030404030060100C018402004008080600C02004008804030060100C018040300608080100402004010D50F8000810182030385058606
...    880889098A0C0C8D8E0E8F909293139414951697A0A0C168


*** Test Cases ***
CB008290-ET-B058_Verify_no_scell_swap_performed_due_to_scell_L2_resources_limitation_TF_IWK_UE_pooling_with_EC_and_HPA_enabled
    [Documentation]
    ...    1. This user scenario Verify successful scell swap intworking with Emergency call and HPA call.
    ...    2. Configuration:
    ...        cell-11 is Pcell, configure NRREL cell 3 and cell 4. cell 3 and cell 4 are for Scell Swap.
    ...        Normal call restraction on cell 3: 2
    ...        EC restraction on cell 3: 2
    ...        HPA call restraction on cell 3: 2
    ...
    ...    2. Test Case Steps:
    ...         a. Attach 2 noramll call UE to cell 11 and check traffic. Trigger Scell addition(cell 3 is selected) and check traffic.
    ...         b. Attach 2 EC to cell 3 should be successful.
    ...         c. Attach 2 HPA call to cell 3 should be successful.
    ...         d. Attach 1 more normal call to cell 3 should be failed.
    ...         e. Attach 1 more EC to cell 3 should be failed.
    ...         f. Attach 1 more HPA call to cell 3 should be failed.
    ...         g. Trigger ScellSwap from cell 3 to cell 4 Success.
    ...         h. Trigger ScellSwap from cell 4 to cell 3 failed due to 5G_CP_ARC_ALG_7490.
    ...            number of UEs served by cell-3 as PCell is 4 (2 EC calls, 2 HPA calls)
    ...            number of UEs served by cell-3 as Scell is 1
    ...            4+1 > NRCELL:maxNumOfUsersPerNRCell=2
    ...            So cpcl should return NOK due to no capacity.
    ...         i. Release all UEs successfully.
    [Tags]    owner-jing.ye    B058    QC_47047
    Multi SA UEs Attach and Scell Addition are Successful    ${SA_UE_list}
    UE Attach To Target Cell with Emergency call    ${EC_ue_list}    cell_id=3    nwslice=2
    UE Attach To Target Cell with HPA call    ${HPA_ue_list}    cell_id=3
    Attach One More Normal UE Will Fail    ue_id=81    cell_id=3
    Attach One More EC Will Fail    ue_id=82    cell_id=3
    Attach One More HPA call Will Fail    ue_id=83    cell_id=3
    Trigger ScellSwap from Cell 3 to Cell 4 should be successful
    Trigger ScellSwap Back Failed    ue_id=${SA_UE_list[1]}    carrierfreq=508110    scell_id=2    phycell_id=52
    Release Ues    ue_type=all
#    Check Wireshark Log    ${CURDIR}${/}a2a_CB008290B058${/}a2a.ini    wait_string=UEContextReleaseComplete::15

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_4T2F

Modify Cfg
    Update Cfg    amf_param id=1 full_nas_auth=on nia=null nea=null ims_voice_3gpp=on
    Update Cfg    set_nwslice id=1 snssai=0x01:0xD143A5 qos_flows=1,2,3 qos_rules=1,2 default=on ue=all amf=1
    Update Cfg    set_nwslice id=2 snssai=0x01:0xD143A6 qos_flows=2,3 qos_rules=1,2 ue=all amf=1
    Update Cfg    set_qosflow id=2 5qi=5
    Update Cfg    set_qosflow id=3 5qi=1
    Update Cfg    set_qosrule id=1 proto=tcp qos_flow=2
    Update Cfg    set_qosrule id=2 proto=udp qos_flow=3

UE Attach To Target Cell with Emergency call
    [Arguments]    ${ue_list}    ${cell_id}=3    ${nwslice}=2
    FOR    ${ue_id}    IN    @{ue_list}
        Update UE capa    ${ue_id}    ${SA_Capa_perUE_Full}
        Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
        Execute Egate Command    ue_nr_rrc_setup_param id=${ue_id} establishment_cause=emergency
        Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
        Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
        Execute Egate Command    qosflow_modify qos_flow=2 priority=1
        Execute Egate Command    qosflow_modify qos_flow=3 priority=1
        ${cmd}    Catenate    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=${ue_id} nwslice=${nwslice} request_type=initial-emergency-request
        ${ret}=    Execute Egate Command    ${cmd}    QoS Routing Table    timeout=20s
        Should Contain    ${ret}    Setup QosFlow with QFI:1 5QI:5
        ${ret1}=    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_add=3 by=amf    QoS Routing Table
        Should Contain    ${ret1}    Added QosFlow with QFI:2 fiveQI:1
        Keep Traffic On EC    ue_id=${ue_id}
    END

UE Attach To Target Cell with HPA call
    [Arguments]    ${ue_list}    ${cell_id}=3
    FOR    ${ue_id}    IN    @{ue_list}
        Update UE capa    ${ue_id}    ${SA_Capa_perUE_Full}
        Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
        Execute Egate Command    ue_nr_rrc_setup_param id=${ue_id} establishment_cause=highPriorityAccess
        Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
        Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
        Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=${ue_id} nwslice=${nwslice}    QoS Routing Table
        Keep Traffic on EC    ue_id=${ue_id}
    END

Multi SA UEs Attach and Scell Addition are Successful
    [Arguments]    ${ue_list}
    Attach Multi UEs and Send traffic    ${ue_list}
    Wait Until Keyword Succeeds    30s    2s    Verify Throuput on Pscell    ${ue_list[1]}
    Trigger Scell Addition for all UEs Should be Successful    ${ue_list}
    Wait Until Keyword Succeeds    30s    2s    Verify Throuput on Pscell and Scell    ${ue_list[1]}

Attach Multi UEs and Send traffic
    [Arguments]    ${ue_list}    ${cell_id}=11    ${pdu_id}=1
    FOR    ${ue_id}    IN    @{ue_list}
        Update UE capa    ${ue_id}    ${SA_Capa_perUE_Full}
        Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
        Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
        Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
        Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=${ue_id} nwslice=${nwslice}    QoS Routing Table
    END
    Keep Traffic on Normal Call    ue_id=${ue_list[0]}
    Send Throuput    ue_id=${ue_list[1]}

Attach One More Normal UE Will Fail
    [Arguments]    ${cell_id}=11    ${ue_id}=81
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    UE${ue_id}: T300 expiration: No response to RRCSetupRequest

Attach One More EC Will Fail
    [Arguments]    ${cell_id}=3    ${ue_id}=81
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_nr_rrc_setup_param id=${ue_id} establishment_cause=emergency
    Execute Egate Command    ue_register id=${ue_id}    UE${ue_id}: T300 expiration: No response to RRCSetupRequest

Attach One More HPA call Will Fail
    [Arguments]    ${cell_id}=3    ${ue_id}=83
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_nr_rrc_setup_param id=${ue_id} establishment_cause=highPriorityAccess
    Execute Egate Command    ue_register id=${ue_id}    UE${ue_id}: T300 expiration: No response to RRCSetupRequest

Keep Traffic On EC
    [Arguments]    ${ue_id}
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=7
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=ul mbps=1
    sleep    3s    #sleep for stable traffic
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput}/1000>0
    Should Be True    ${ul_throughput}/1000>0

Keep Traffic on Normal Call
    [Arguments]    ${ue_id}
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=1 trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=ul mbps=1 trf_id=1    UE ${ue_id}: UDP UL
    sleep    3s    #sleep for stable traffic
    ${pcell_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${pcell_tput}/1000>0
    ${ul_tput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${ul_tput}/1000>0

Send Throuput
    [Arguments]    ${ue_id}
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=1    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=3    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=4    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=ul mbps=10 trf_id=1    UE ${ue_id}: UDP UL

Verify Throuput on Pscell
    [Arguments]    ${ue_id}    ${pcell_dl}=60    ${ul}=9.5
    ${pcell_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    ${ul_tput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${pcell_tput}/1000>${pcell_dl}
    Should Be True    ${ul_tput}/1000>${ul}

Verify Throuput on Pscell and Scell
    [Arguments]    ${ue_id}    ${traffic_dl}=570    ${ul}=9.5    ${scell_id}=1
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-9 type=pdsch    Throughput
    ${pcell_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${pcell_tput}/1000>0
    ${scell_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${scell_id}    type=pdsch    rate_type=ave
    Should Be True    ${scell_tput}/1000>0
    ${total_dl_tput}    Evaluate    ${scell_tput}+${pcell_tput}
    ${ul_tput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${total_dl_tput}/1000>${traffic_dl}
    Should Be True    ${ul_tput}/1000>${ul}

Trigger Scell Addition for all UEs Should be Successful
    [Arguments]    ${ue_list}
    FOR    ${ue_id}    IN    @{ue_list}
        Trigger Scell Addition    ue_id=${ue_id}
    END

Trigger Scell Addition
    [Arguments]    ${ue_id}=81    ${event_type}=A1    ${carrierfreq}=125050    ${srsrp_nr}=120    ${srsrq_nr}=50
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type}    srsrp_nr=${srsrp_nr} srsrq_nr=${srsrq_nr}
    Execute Egate Command    ${cmd}    pass_regexp=rrcReconfigurationComplete

Trigger ScellSwap from Cell 3 to Cell 4 should be successful
    Trigger ScellSwap Success    ue_id=${SA_UE_list[1]}    carrierfreq=508110    scell_id=1    phycell_id=53
    Wait Until Keyword Succeeds    10s    2s    Verify Throuput on Pscell and Scell    ue_id=${SA_UE_list[1]}    scell_id=2

Trigger ScellSwap Success
    [Arguments]    ${event_type}=A6    ${carrierfreq}=518910    ${nrsrp_nr}=5    ${nrsrq_nr}=5    ${ue_id}=82    ${scell_id}=1
    ...    ${phycell_id}=63
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type}
    ...    srsrp_nr=11 srsrq_nr=11 scell=${scell_id} scell_rsrp=20 scell_rsrq=20 phycell_id=${phycell_id} nrsrp_nr=${nrsrp_nr} nrsrq_nr=${nrsrq_nr}
    Execute Egate Command    ${cmd}    pass_regexp=rrcReconfigurationComplete

Trigger ScellSwap Back Failed
    [Arguments]    ${event_type}=A6    ${carrierfreq}=518910    ${nrsrp_nr}=5    ${nrsrq_nr}=5    ${ue_id}=82    ${scell_id}=1
    ...    ${phycell_id}=63
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type}
    ...    srsrp_nr=11 srsrq_nr=11 scell=${scell_id} scell_rsrp=20 scell_rsrq=20 phycell_id=${phycell_id} nrsrp_nr=${nrsrp_nr} nrsrq_nr=${nrsrq_nr}
    Execute Egate Command    ${cmd}    fail_regexp=rrcReconfigurationComplete
    Verify Throuput on Pscell and Scell    ue_id=${ue_id}    scell_id=2

Update UE capa
    [Arguments]    ${ue_id}=81    ${SA_Capa_perUE_Full}=none
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full}
    Execute Egate Command    ${cmd}



