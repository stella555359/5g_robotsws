*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CLOUD_5G_I_MP_AP_LO    team-PZ3_7
...     owner-yili.chen    release-SBTS24R2    release-SBTS24R3    CB008830    CRT
Resource     ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${SYSCOM_FLAG}    ${True}

@{PARAMS_IN_SCF}
...    @{CB008830}
...    @{enableBeamforming}
...    @{BWPmodify}
...    @{8246_related_modification_HRDRB}
...    @{VONR}
...    @{5GC000545_related}
...    NRBTS:actFullPlmnList=true
...    NRBTS-1:cipherPrefL:nea0=8
...    NRBTS-1:cipherPrefL:nea1_128=0
...    NRBTS-1:cipherPrefL:nea2_128=0
...    NRBTS-1:cipherPrefL:nea3_128=0
...    NRCELL:nrofHARQProcessesForPDSCH=16
...    NRCELL:maxNumPdschAllocationPerSlot=16
...    NRCELL:actPdschAtSsbSlots=true

...    NRBTS-1/NRDRX-1:drxLongCycle=40ms
...    NRCELL:actAdaptiveReTxResMcs=true

...    NRCELL:actDlLowPAPRoptimizedPrecoding=true
...    NRCELL:actPdschRmCsirsForTracking=true
...    NRCELL:actEnhancedPDSCHSchSplSlot=true
...    NRCELL:minPctResourceReservedMcsDl=50
...    NRCELL:minPctResourceReservedMcsUl=50
...    NRCELL:targetPctResourceReservedMcsDl=75
...    NRCELL:targetPctResourceReservedMcsUl=75
...    NRBTS-1/NRPMRNL-1:miNrInterGnbMobilityNsaPmqap=disabled
...    NRBTS-1/NRPMRNL-1:miNrInterGnbXnMobilitySaPmqap=disabled
...    NRBTS-1/NRPMRNL-1:miNrIntraGnbMobilityNsaPmqap=disabled
...    NRBTS-1/NRPMRNL-1:miNrIntraGnbMobilitySaPmqap=disabled
...    NRBTS-1/NRPMRNL-1:miNrNgcFlexInterface=disabled
...    NRCELL:actDlMuMimoEnh=false

@{5GC000545_related}
...    NRCELL:actUlDftSOfdm=true
...    NRBTS-1:actTdraFallback=false
...    NRCELL:pucchModeSelect=longPucch
...    NRCELL:puschMappingType=TypeB
...    NRCELL:ulTransPrecodeCtl:ulTransPrecodeOffSinrThresh=200
...    NRCELL:ulTransPrecodeCtl:ulTransPrecodeOnSinrThresh=180

@{8246_related_modification_HRDRB}
...    NRCELL-1:cellDepType=SA
...    delete:NRCELL-1:configuredEpsTac
...    NRCELL-1:actLAForHiReliab=true
...    NRCELL-1:dlMcsDowngradeForHr=disabled
...    NRCELL-1:ulMcsDowngradeForHr=disabled
...    NRCELL-1:pdschHrLaConfig:dllaCqiOffsetHR=0
...    NRCELL-1:pdschHrLaConfig:dllaDeltaCqiMaxHR=150
...    NRCELL-1:pdschHrLaConfig:dllaDeltaCqiMinHR=-150
...    NRCELL-1:pdschHrLaConfig:dllaDeltaCqiStepdownHR=20
...    NRCELL-1:pdschHrLaConfig:dllaIniDeltaCqiHR=-50
...    NRCELL-1:pdschHrLaConfig:dllaIniMcsHR=3
...    NRCELL-1:puschHrLaConfig:iniDeltaSinrHR=-50
...    NRCELL-1:puschHrLaConfig:ullaDeltaSinrMaxHR=15
...    NRCELL-1:puschHrLaConfig:ullaDeltaSinrMinHR=-30
...    NRCELL-1:puschHrLaConfig:ullaDeltaSinrStepdownHR=2
...    NRCELL-1:puschHrLaConfig:ullaIniMcsHR=0
...    NRCELL-1:puschHrLaConfig:ullaSinrOffsetHR=2
...    NRBTS-1/NRDRB-11:nrPdschHRLaDN=MRBTS-1/NRBTS-1/NRPDSCHHRLA-1
...    NRBTS-1/NRDRB-11:nrPuschHRLaDN=MRBTS-1/NRBTS-1/NRPUSCHHRLA-1
...    NRBTS-1/NRPDSCHHRLA-1:dllaBlerTargetHR=10
...    NRBTS-1/NRPDSCHHRLA-2:dllaBlerTargetHR=10
...    NRBTS-1/NRPUSCHHRLA-1:ullaBlerTargetHR=10
...    NRBTS-1/NRPUSCHHRLA-2:ullaBlerTargetHR=10
...    NRBTS-1/BWP_PROFILE-5/PDCCH-1:dciDedicatedAggregationLevelHR=AL4
...    NRBTS-1/BWP_PROFILE-54/PDCCH-1:dciDedicatedAggregationLevelHR=AL4
...    NRBTS/NRPDSCHHRLA-1:dlHRBlerOutageMcsThresh64qam=3
...    NRBTS/NRPUSCHHRLA-1:scalFactorForHRGbrUl=110
...    NRCELL-1:actCceSplit=false

@{VONR}
...    NRCELL:actVoNR=true
...    NRCELL:actEnhancedVoNR=true
...    NRCELL:actAdaptVoipTbs=true
...    NRCELL:actCDrxVoNR=true
...    NRCELL:actCDrx=true
...    NRCELL:srPeriodicity=slots80
...    NRCELL:periodicCsiAcquisition:csiReportPeriodicity=slots320
...    NRCELL:actVoipPacketAggr=true
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
...    NRBTS/NRDRX-1:drxLongCycle=40ms

@{BWPmodify}
...    NRBTS/BWP_PROFILE-5:bwpType=initial
...    NRBTS/BWP_PROFILE-5:locationAndBandwidthDl:cRbSizeDl=coreset0
...    NRBTS/BWP_PROFILE-5:locationAndBandwidthDl:cRbStartDl=coreset0
...    NRBTS/BWP_PROFILE-5:locationAndBandwidthUl:cRbSizeUl=sameAsDl
...    NRBTS/BWP_PROFILE-5:locationAndBandwidthUl:cRbStartUl=sameAsDl
...    NRBTS/BWP_PROFILE-5/PDCCH-1:dciDedicatedAggregationLevelHR=AL4
...    NRBTS/BWP_PROFILE-54/PDCCH-1:dciDedicatedAggregationLevelHR=AL4
...    NRBTS/BWP_PROFILE-5/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-5/PDCCH-1:dciDedicatedAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-5/PDCCH-1:dciPagingAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-5/PDCCH-1:dciRaCompletionAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-5/PDCCH-1:dciRaMsg2AggregationLevel=AL4
...    NRBTS/BWP_PROFILE-5/PDCCH-1:dciSiAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-5/PDCCH-1:downgradeAL16toAL8=notAllowed
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=3|searchSpaceId=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceId=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=2
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=3|searchSpaceId=3
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=3
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceId=3
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=3
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-54:bwpType=dedicated
...    NRBTS/BWP_PROFILE-54:locationAndBandwidthDl:cRbSizeDl=allRb
...    NRBTS/BWP_PROFILE-54:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-54:locationAndBandwidthUl:cRbSizeUl=sameAsDl
...    NRBTS/BWP_PROFILE-54:locationAndBandwidthUl:cRbStartUl=sameAsDl
...    NRBTS/BWP_PROFILE-54/PDSCH-1:pdschId=1
...    NRBTS/BWP_PROFILE-54/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-54/PDCCH-1:dciDedicatedAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-54/PDCCH-1:dciPagingAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-54/PDCCH-1:dciRaCompletionAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-54/PDCCH-1:dciRaMsg2AggregationLevel=AL4
...    NRBTS/BWP_PROFILE-54/PDCCH-1:dciSiAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-54/PDCCH-1:downgradeAL16toAL8=notAllowed
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=3|searchSpaceId=4
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=4
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceId=4
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=4
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=5
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=3|searchSpaceId=6
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=6
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceId=6
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=6
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cceToRegMapping=nonInterleaved
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:coresetId=1
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cRbStart=0
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:duration=1
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:interleaverSize=none
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:regBundleSize=n6
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=120
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-0-And-1-0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|searchSpaceId=7
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=7
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|searchSpaceId=7
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|searchSpaceId=7
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|searchSpaceId=7
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=1|searchSpaceId=8
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|searchSpaceId=8
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|searchSpaceId=8
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=8
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|searchSpaceId=8
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceId=8
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|searchSpaceId=8
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n5|searchSpaceId=8
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceId=8
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|searchSpaceId=8
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|searchSpaceId=8
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|searchSpaceId=8

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
...    NRBTS/NRSYSINFO_PROFILE-1:systemInformationTargetRate=157

@{CB008830}
...    NRCELL:dlDataDmrsFdm:actDlDataDmrsFdm=false
...    NRCELL:actDl256Qam=false
...    NRCELL:dlDMRSAdditionalPosition=No additional DMRS
...    NRBTS-1/NRCELL-1:dlDmrsType=Type2
...    NRBTS-1/NRCELL-2:dlDmrsType=Type2

${ue2_nr_cap}    SEPARATOR=
...    E5A00000074E5A035E000385A8000F00280000100404983200461E1A0018806804C060180E01
...    951B0A3582028680965944C44003D6C10101070EF1C39061C00103278FAB800278000546C4CD
...    6080A1A0259651311000F5B0404041C3BC70E418700040C9E3EAE0009E00380027800546C4DD
...    6080A1A0259651311000F5B0404041C3BC70E418700040C9E3EAE0009E00380027800546C4ED
...    6080A1A0259651311000F5B0404041C3BC70E418700040C9E3EAA00000A00000021071340000
...    0000809A46000003804044F6230003000281C1401C0C0260070006828000000000340020040F
...    8000000000000395340004000025965400D2AAA220007000B00000004008011AB13000102030
...    4050607080B101112131921252627284A60B40

@{failIf_DMRStype2}
...    dmrs-Type type2
@{default_fail_regexp}    ${EMPTY}
${Loop_id}    5

*** Test Cases ***
CB008830-ET-C011-Verify_IWK_With_ulSlotAggEnabled_setup_release_VoNR_with_HR_DRB_established
    [Documentation]
    ...    1. The purpose of this test case is to check following scenarios:
    ...       Dynamic switch between type 1 and type 2 due to both VoNR and DL High Reliability DRB
    ...    2. [Configuration]:
    ...       NRCELL/actDlDataDmrsFdm=False
    ...       NRCELL/dlDMRSAdditionalPosition="No Additional DMRS
    ...       NRCELL-1/dlDmrsType=Type2
    ...       256QAM is disabled: NRBTS/NRCELL.actDl256Qam and NRBTS/NRCELL.actUl256Qam set as False
    ...       MU-MIMO disabled: NRBTS/NRCELL.actDlMuMimo set to False
    ...       Adaptive retransmission (CB008662) is disabled: NRBTS/NRCELL.actAdaptiveReTxResMcs set to False
    ...       CA is disabled: NRBTS/NRDU/carrierAggregationSupportList set to 'none'
    ...    3. Test Case Steps:
    ...        a.UE attached and PDU setup successfully
    ...        b.VONR call setup with PDU session 2
    ...        c.start data transfer over PDU session 2
    ...        d.Simulate UE moves towards cell edge:
    ...        e.perform release 5QI1
    ...        f.Simulate UE moves towards cell center :  ul_sinr_testmode_nr profile_id=1 pathloss=80
    ...        g.release UE
    ...    4. Expected Results:
    ...        a.UE attached and PDU setup successfully
    ...         Checking IE in RRC:CellGroupConfig->spCellConfig/sCellConfig->spCellConfigDedicated/sCellConfigDedicated->
    ...         downlinkBWP-ToAddModList->BWP-Downlink->BWP-DownlinkDedicated->PDSCH-Config->
    ...         dmrs-DownlinkForPDSCH-MappingTypeA,DMRSType1 configured.
    ...         Check L3->L2 syscom message  PsUser_UserSetupReq/PsUser_UserModifyReq,  DMRS type correctly indicate to L2
    ...         Stable DL throughput is achieved(No BLER, DTX, NACK, CRC KO) (All PDSCHs are transmitted with DL DMRS type 1)
    ...        b.In RRC reconfiguration, No DL DMRS type reconfig needed.
    ...        c.Both PDU session can achieve Stable DL throughput (All PDSCHs are transmitted with DL DMRS type 1)
    ...        d.L2PS triggers UE reconfiguration to switch UE to Transform Precoder enabled state
    ...          gNB initiates RRCReconfiguration procedure to perform User Reconfiguration
    ...        e.gNB-L2PS exits Slot Aggregation mode
    ...         Upon receipt of RRCReconfigurationComplete from UE for the last 5QI1 DRB release, gNB-L2PS ends slot aggregation
    ...         gNB switches to DRX profile1
    ...         Upon completion of RRCReconfiguration procedure to release the last 5QI1 DRB, gNB initiates RRCReconfiguration in
    ...         order to switch from VoNR DRX profile2 to DRX profile1. Note: this is legacy CB006112 behavior
    ...         gNB-DU sets the onDurationTimer and the longDrxCycle value, as per DRX profile1 parameters
    ...         In RRC reconfiguration,  DL DMRS type is changed to type 1.
    ...         Check L3->L2 syscom message  PsUser_UserSetupReq/PsUser_UserModifyReq,  DMRS type correctly indicate to L2
    ...        f.Stable DL throughput is achieved(No BLER, DTX, NACK, CRC KO)
    ...        g.UE released successfully
    [Tags]    C011    QC_xxxxxx
	start_to_capture_gnb_ttitrace    C011
    SA UE attach    ue_id=2    cell_id=1    fail_regexp=${failIf_DMRStype2}
    Trigger UE MO VoNR call with PDU    ue_id=2    pdu_id=2    request_type=initial-emergency-request    fiveQI=5
    Trigger UE 5QI add successfully with PDU session modify    ue_id=2    pdu_id=2    fiveQI=1
    UE moves towards cell edge    ue_id=2    pathloss=118
    Trigger UE PDU session release    ue_id=2    pdu_id=2
    UE moves towards cell Center    ue_id=2    pathloss=80
	stop_capture_gnb_ttitrace    C011
    Loop teststeps

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri

Modify Cfg
    ${set_cell2}    catenate
    ...    set_cell id=2 gnb=2 pci=17:0 tac=100 nrci=0x02 tdd_cell=on proxy=$PROXY_SERVER_IP:9999|$PROXY_SERVER_IP:8888
    ...    nr_arfcn=633372:633372 gscn=7847 mandatory_for_activation=off
    Update Cfg    ${set_cell2}
    #Update Cfg    ue_param id=1 ue_nr_capabilities=${SA_Capa_Support_SAG}
    Update Cfg    ue_param id=2 ue_nr_capabilities=${ue2_nr_cap}
    #Update Cfg    ue_param id=31 ue_nr_capabilities=${ue31_nr_cap} dual_conn=eutra_nr ue_eutra_nr_capabilities=${ue31_MRDC_cap}
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
    [Arguments]    ${ue_id}=2    ${cell_id}=1    ${pdu_id}=1    ${fail_regexp}=${default_fail_regexp}
    Execute Egate Command    ue_change_location id=${ue_id} cell=${cell_id} enb=2
    Execute Egate Command    qosflow_modify qos_flow=3 default=on
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Registered state.
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
	Start To Capture Wireshark Log    HRDRB_Setup
    ${ret1}    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=1 nwslice=1
    ...    pass_regexp=Initial Context Setup Successful    fail_regexp=${fail_regexp}
	Should Contain    ${ret1}    dmrs-DownlinkForPDSCH-MappingTypeA setup
	should not contain    ${ret1}    dmrs-Type type2
    stop_capture_wireshark_log
    check_num_of_wireshark_as_excepted    ${SAVE LOG DIRECTORY}${/}/wireshark_HRDRB_Setup.pcap
	...    itf_l2_ps_HrLaProfile.puschHrConfig.Length == 1 and itf_l2_ps_PuschHrConfig.ullaBlerTargetHR == 10 @1
	Send Traffic    ue_id=${ue_id}    pdu_id=${pdu_id}
    Verify Throuput    ue_id=${ue_id}    expectedTput_dl=9    expectedTput_ul=27
	Bler Check    
	...    tag=tti_HRDRB    
	...    a2a_ini=/home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_L3_SW_CN_HZ/trunk_sbts/CRT/CN1/CB008830${/}a2a_C011${/}a2a_bler_dl_HRDRB.ini
	Bler Check    
	...    tag=tti_HRDRB    
	...    a2a_ini=/home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_L3_SW_CN_HZ/trunk_sbts/CRT/CN1/CB008830${/}a2a_C011${/}a2a_bler_ul_HRDRB.ini

UE moves towards cell edge
    [Arguments]    ${ue_id}=2    ${pathloss}=126
	Start To Capture Wireshark Log    cell_edge
    Execute Egate Command    ul_sinr_testmode_nr profile_id=1 pathloss=${pathloss}
    Execute Egate Command    ue_testmode_set_nr id=${ue_id} testmode=ul_sinr action=activate profile_id=1    pass_regexp=rrcReconfigurationComplete
    stop_capture_wireshark_log
    check_num_of_wireshark_as_excepted    ${SAVE LOG DIRECTORY}${/}/wireshark_cell_edge.pcap
	...    nr-rrc.dmrs_DownlinkForPDSCH_MappingTypeA == 1@1
	...    nr-rrc.dmrs_Type == 0@0

UE moves towards cell Center
    [Arguments]    ${ue_id}=2    ${pathloss}=126
	Start To Capture Wireshark Log    cell_Center
    Execute Egate Command    ul_sinr_testmode_nr profile_id=1 pathloss=${pathloss}    pass_regexp=rrcReconfigurationComplete
    Execute Egate Command    ue_testmode_set_nr id=${ue_id} testmode=ul_sinr action=deactivate profile_id=1
    stop_capture_wireshark_log
    check_num_of_wireshark_as_excepted    ${SAVE LOG DIRECTORY}${/}/wireshark_cell_Center.pcap
	...    nr-rrc.dmrs_DownlinkForPDSCH_MappingTypeA == 1@1
	...    nr-rrc.dmrs_Type == 0@0
	Bler Check    
	...    tag=tti_Center    
	...    a2a_ini=/home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_L3_SW_CN_HZ/trunk_sbts/CRT/CN1/CB008830${/}a2a_C011${/}a2a_bler_dl_Center.ini
	Bler Check    
	...    tag=tti_Center    
	...    a2a_ini=/home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_L3_SW_CN_HZ/trunk_sbts/CRT/CN1/CB008830${/}a2a_C011${/}a2a_bler_ul_Center.ini

Trigger UE MO VoNR call with PDU
    [Arguments]    ${ue_id}=2    ${pdu_id}=2    ${gw}=2    ${request_type}=initial-request    ${fiveQI}=5
    ...    ${cipheringAlgorithm}=nea2
    Start To Capture Wireshark Log    emergency_request
    BuiltIn.Log    Trigger UE MO VoNR call with PDU...    console=${True}
    #Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Registered    timeout=20s
    Execute Egate Command    qosflow_modify qos_flow=2 default=on
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    ${ret1}    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} nwslice=1 gw=2 request_type=${request_type}
    ...        QoS Routing Table   timeout=20s
    Should Contain    ${ret1}    Setup QosFlow with QFI:1 5QI:${fiveQI}
    stop_capture_wireshark_log
    check_num_of_wireshark_as_excepted    ${SAVE LOG DIRECTORY}${/}/wireshark_emergency_request.pcap
    ...    nr-rrc.dmrs_DownlinkForPDSCH_MappingTypeA == 1@1
	check_num_of_wireshark_as_excepted    ${SAVE LOG DIRECTORY}${/}/wireshark_emergency_request.pcap
    ...    nr-rrc.dmrs_Type == 0@0
	Send Traffic    ue_id=${ue_id}    pdu_id=${pdu_id}    ul=1    dl=1
    Verify Throuput    ue_id=${ue_id}    pdu_id=${pdu_id}    expectedTput_dl=0.9    expectedTput_ul=0.9
	Bler Check    
	...    tag=tti_VONR    
	...    a2a_ini=/home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_L3_SW_CN_HZ/trunk_sbts/CRT/CN1/CB008830${/}a2a_C011${/}a2a_bler_dl_VONR.ini
	Bler Check    
	...    tag=tti_VONR    
	...    a2a_ini=/home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_L3_SW_CN_HZ/trunk_sbts/CRT/CN1/CB008830${/}a2a_C011${/}a2a_bler_ul_VONR.ini

Trigger UE 5QI add successfully with PDU session modify
    [Arguments]    ${ue_id}=1    ${pdu_id}=2    ${fiveQI}=1    ${qosflows_to_add}=6
    BuiltIn.Log    Trigger UE${ue_id} 5QI${fiveQI} add successfully with PDU session modify...    console=${True}
	Start To Capture Wireshark Log    5QI_add
    ${ret1}    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_add=${qosflows_to_add} by=amf
    ...    Pdu Session Resource Modify Response Message with RAN UE NGAP ID [0-9]* handled successfully    timeout=20s
    Should Contain    ${ret1}    rrcReconfiguration
    Should Contain    ${ret1}    Added QosFlow with QFI:2 5QI:${fiveQI}
    stop_capture_wireshark_log
    check_num_of_wireshark_as_excepted    ${SAVE LOG DIRECTORY}${/}/wireshark_emergency_request.pcap
	...    nr-rrc.dmrs_DownlinkForPDSCH_MappingTypeA == 1@1
	...    nr-rrc.dmrs_Type == 0@0

Send And Verify Throuput
    [Arguments]    ${ue_id}=1    ${expectedTput_dl}=255    ${expectedTput_ul}=9
    Send Traffic    ue_id=${ue_id}
    Verify Throuput    ue_id=${ue_id}    expectedTput_dl=${expectedTput_dl}    expectedTput_ul=${expectedTput_ul}

Send Traffic
    [Arguments]    ${ue_id}=2    ${pdu_id}=1    ${ul}=30    ${dl}=10
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=${pdu_id} dir=ul mbps=${ul} trf_id=1
    ...    pass_regexp=UDP UL TRF
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=${pdu_id} dir=dl mbps=${dl} trf_id=2
    ...    pass_regexp=UDP DL TRF

Verify Throuput
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${qfi}=1    ${sleep_time}=10s    ${expectedTput_dl}=9    ${expectedTput_ul}=135
    sleep    ${sleep_time}    #wait trf stable
    ${dl_throuput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=${qfi}    direction=dl    rate_type=ave
    Should Be True    ${dl_throuput}/1000>${expectedTput_dl}
    ${ul_throuput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=${qfi}    direction=ul    rate_type=ave
    Should Be True    ${ul_throuput}/1000>${expectedTput_ul}

Trigger UE PDU session release
    [Arguments]    ${ue_id}=1    ${pdu_id}=1
    BuiltIn.Log    Trigger UE${ue_id} PDU session release...    console=${True}
	Start To Capture Wireshark Log    PDU_session_release
    ${ret1}    Execute Egate Command    ue_pdu_session_release ue=${ue_id} pdu=${pdu_id} by=ue    Successfully released PDU Session
    ...    timeout=20s
    stop_capture_wireshark_log
    check_num_of_wireshark_as_excepted    ${SAVE LOG DIRECTORY}${/}/wireshark_PDU_session_release.pcap
	...    nr-rrc.dmrs_DownlinkForPDSCH_MappingTypeA == 1@2
	...    nr-rrc.dmrs_Type == 0@0

Loop teststeps
    FOR    ${id}    IN RANGE    1    ${Loop_id}
	start_to_capture_gnb_ttitrace    C011
    Trigger UE MO VoNR call with PDU    ue_id=2    pdu_id=2    request_type=initial-emergency-request    fiveQI=5
    Trigger UE 5QI add successfully with PDU session modify    ue_id=2    pdu_id=2    fiveQI=1
    UE moves towards cell edge    ue_id=2    pathloss=118
    Trigger UE PDU session release    ue_id=2    pdu_id=2
    UE moves towards cell Center    ue_id=2    pathloss=80
	stop_capture_gnb_ttitrace    C011
    END
