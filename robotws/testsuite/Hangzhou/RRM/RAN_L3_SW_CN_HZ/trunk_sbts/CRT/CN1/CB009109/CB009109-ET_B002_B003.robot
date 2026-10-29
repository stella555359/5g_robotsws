*** Settings ***
Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_VRF    RAN_5G    RAN_5G_TDD    SBTS00    CRT    CLOUD_5G_I_BOO_AP_LOO
...           owner-xiaowen.xu    team-CN1ET    release-SBTS24R3
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${BTS_STARTUP_RETRY}    2
${SYSCOM_FLAG}    True
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
...    @{VONR}
...    @{Others}
...    @{gscn_Arfcn}
...    @{5GC002396}
...    @{CB009109}

@{CB009109}

...    NRCELL:actCDrx=true
...    NRCELL:actCDrxVoNR=true

...    NRBTS:actDedicatedAnrDrxProfile=true

...    NRBTS:actDrbDrx=true
...    NRCELL:nonGbrNrDrxDN=NRDRX-4
...    NRCELL:voNRNrDrxDN=MRBTS-2/NRBTS-2/NRDRX-2


...    NRCELL:drxProfileNrAnr:drxControl=intraNRSAintraFreq

...    NRCELL:drxProfileNrAnr:nrDrxDN=NRDRX-3

...    NRBTS/NRDRX-0:drxHarqRttTimerDl=0symbols
...    NRBTS/NRDRX-0:drxHarqRttTimerUl=0symbols
...    NRBTS/NRDRX-0:drxInactivityTimer=0ms
...    NRBTS/NRDRX-0:drxLongCycle=10ms
...    NRBTS/NRDRX-0:drxOnDurationTimer=1ms
...    NRBTS/NRDRX-0:drxRetransTimerDl=0slot
...    NRBTS/NRDRX-0:drxRetransTimerUl=0slot
...    NRBTS/NRDRX-0:drxPriority=0
...    NRBTS/NRDRX-1:drxHarqRttTimerDl=0symbols
...    NRBTS/NRDRX-1:drxHarqRttTimerUl=0symbols
...    NRBTS/NRDRX-1:drxInactivityTimer=80ms
...    NRBTS/NRDRX-1:drxLongCycle=160ms
...    NRBTS/NRDRX-1:drxOnDurationTimer=10ms
...    NRBTS/NRDRX-1:drxRetransTimerDl=0slot
...    NRBTS/NRDRX-1:drxRetransTimerUl=0slot
...    NRBTS/NRDRX-1:drxPriority=31
...    NRBTS/NRDRX-2:drxHarqRttTimerDl=0symbols
...    NRBTS/NRDRX-2:drxHarqRttTimerUl=0symbols
...    NRBTS/NRDRX-2:drxInactivityTimer=20ms
...    NRBTS/NRDRX-2:drxLongCycle=40ms
...    NRBTS/NRDRX-2:drxOnDurationTimer=10ms
...    NRBTS/NRDRX-2:drxRetransTimerDl=0slot
...    NRBTS/NRDRX-2:drxRetransTimerUl=0slot
...    NRBTS/NRDRX-2:drxPriority=3
...    NRBTS/NRDRX-3:drxHarqRttTimerDl=0symbols
...    NRBTS/NRDRX-3:drxHarqRttTimerUl=0symbols
...    NRBTS/NRDRX-3:drxInactivityTimer=20ms
...    NRBTS/NRDRX-3:drxLongCycle=320ms
...    NRBTS/NRDRX-3:drxOnDurationTimer=40ms
...    NRBTS/NRDRX-3:drxPriority=15
...    NRBTS/NRDRX-3:drxRetransTimerDl=0slot
...    NRBTS/NRDRX-3:drxRetransTimerUl=0slot
...    NRBTS/NRDRX-4:drxHarqRttTimerDl=0symbols
...    NRBTS/NRDRX-4:drxHarqRttTimerUl=0symbols
...    NRBTS/NRDRX-4:drxInactivityTimer=40ms
...    NRBTS/NRDRX-4:drxLongCycle=80ms
...    NRBTS/NRDRX-4:drxOnDurationTimer=10ms
...    NRBTS/NRDRX-4:drxPriority=16
...    NRBTS/NRDRX-4:drxRetransTimerDl=0slot
...    NRBTS/NRDRX-4:drxRetransTimerUl=0slot
...    NRBTS/NRDRX-5:drxHarqRttTimerDl=0symbols
...    NRBTS/NRDRX-5:drxHarqRttTimerUl=0symbols
...    NRBTS/NRDRX-5:drxInactivityTimer=10ms
...    NRBTS/NRDRX-5:drxLongCycle=20ms
...    NRBTS/NRDRX-5:drxOnDurationTimer=10ms
...    NRBTS/NRDRX-5:drxRetransTimerDl=16slot
...    NRBTS/NRDRX-5:drxRetransTimerUl=16slot
...    NRBTS/NRDRX-5:drxPriority=2
...    NRBTS/NRDRX-6:drxHarqRttTimerDl=0symbols
...    NRBTS/NRDRX-6:drxHarqRttTimerUl=0symbols
...    NRBTS/NRDRX-6:drxInactivityTimer=10ms
...    NRBTS/NRDRX-6:drxLongCycle=40ms
...    NRBTS/NRDRX-6:drxOnDurationTimer=10ms
...    NRBTS/NRDRX-6:drxRetransTimerDl=24slot
...    NRBTS/NRDRX-6:drxRetransTimerUl=24slot
...    NRBTS/NRDRX-6:drxPriority=4
...    NRBTS/NRDRB-1:nrDrxDN=MRBTS-2/NRBTS-2/NRDRX-6
...    NRBTS/NRDRB-15:nrDrxDN=MRBTS-2/NRBTS-2/NRDRX-6
...    NRBTS/NRDRB-16:nrDrxDN=MRBTS-2/NRBTS-2/NRDRX-5

${carrierAggregationSupportList}    SEPARATOR=
...    ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Any_Sa,ca_Fdd_Fdd,ca_Fr1Tdd_Any_Sa,
...    ca_Fdd_Fr1Tdd_Nsa,ca_Fdd_Fr1Tdd_Sa_WithUl,ca_Fr1Tdd_Nsa,ca_Fr1Tdd_Fdd_Nsa
@{CB006137}
...    NRBTS/NRDU-1:carrierAggregationSupportList=${carrierAggregationSupportList}
...    NRBTS/NRDU-1:dlToUlContributionRatio=90
...    NRBTS/NRDRB_RLC_AM-1:ulTReassemblyIBCA=40
...    NRBTS/NRDRB_RLC_AM-2:ulTReassemblyIBCA=40
...    NRCELL:maxNumScellsDlFr1=3
...    NRCELL:timingAdvanceOffset=n25600
...    NRCELL-2:increasePUSCHPrepTimeULCA=true
...    NRCELL-4:increasePUSCHPrepTimeULCA=true

@{gscn_Arfcn}
...    NRCELL-2:nrarfcn=518598
...    NRCELL-2:gscnOrSsPbchArfcn=6483
...    NRCELL-2:chBw=20MHz
...    NRCELL-2:msg1FrequencyStart=7
...    NRCELL-4:nrarfcn=636666
...    NRCELL-4:gscnOrSsPbchArfcn=7882
...    NRCELL-4:chBw=20MHz
...    NRCELL-4:msg1FrequencyStart=7
...    NRCELL-1/NRCELL_FDD-1:nrarfcnDl=126900
...    NRCELL-1/NRCELL_FDD-1:nrarfcnUl=136100
...    NRCELL-1/NRCELL_FDD-1:chBwDl=10MHz
...    NRCELL-1/NRCELL_FDD-1:chBwUl=10MHz
...    NRCELL-1:gscnOrSsPbchArfcn=1587
...    NRCELL-3/NRCELL_FDD-1:nrarfcnDl=128880
...    NRCELL-3/NRCELL_FDD-1:nrarfcnUl=138080
...    NRCELL-3/NRCELL_FDD-1:chBwDl=10MHz
...    NRCELL-3/NRCELL_FDD-1:chBwUl=10MHz
...    NRCELL-3:gscnOrSsPbchArfcn=1611
@{Others}
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=48
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|searchSpaceType=Type3
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|searchSpaceType=UE-Specific
...    NRBTS:actMultiDrbNSA=true
...    NRBTS:actIncXn=true
...    NRBTS:actConflictConfiguration=true
...    NRBTS:rrcReestabTypeSA=sameGNB
...    NRBTS:tWaitingRlRecover=4000ms
...    NRCELL:pucchModeSelect=longPucch
...    NRBTS/NRSCTP-1:sctpProfile:sctpWaitTimeInitSeqRetry=10
...    NRCELL:actUl256Qam=false
...    NRCELL:actDl256Qam=false
@{CA}
...    NRBTS/NRDU-1:actConnectedModeMobilityCA=true
...    NRBTS/NRDU-1:flexibleCAMode=NumberCellAmount
...    NRCELL:weightForSCellSelection=50
...    NRCELL:actK1Opt=intra-gNB
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
...    NRBTS:actDrbProfileForCellAggrLevel=FR1_SA
@{NRREL}
...    NRCELL-1/NRREL-1:gNbId=2
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:lcrId=2
...    NRCELL-1/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-1:sCellOperationalMode=dlAndUl
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-1/NRHOIF-1:a1BasedPCellSwitchEnabled=true
...    NRCELL-1/NRHOIF-1:a2BasedPCellSwitchEnabled=true
...    NRCELL-1/NRHOIF-1:a2BasedPCellSwitchPriority=1
...    NRCELL-1/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-1/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-1/NRHOIF-1:freqBandIndicatorNR=41
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf5
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf20
...    NRCELL-1/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-1/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-1:ssbFrequency=518430
...    NRCELL-1/NRHOIF-1:thresholdPCellSwitchTargetRsrp=60
...    NRCELL-1/NRHOIF-1:thresholdPCellSwitchTargetRsrq=20
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms320
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=5
...    NRCELL-1/NRREL-2:gNbId=2
...    NRCELL-1/NRREL-2:gNbIdLength=22
...    NRCELL-1/NRREL-2:lcrId=4
...    NRCELL-1/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-2:sCellOperationalMode=dlAndUl
...    NRCELL-1/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-3:gNbId=2
...    NRCELL-1/NRREL-3:gNbIdLength=22
...    NRCELL-1/NRREL-3:lcrId=3
...    NRCELL-1/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-3:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-3/NRREL-1:gNbId=2
...    NRCELL-3/NRREL-1:gNbIdLength=22
...    NRCELL-3/NRREL-1:lcrId=2
...    NRCELL-3/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-3/NRREL-1:sCellOperationalMode=dlAndUl
...    NRCELL-3/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-3/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-3/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-3/NRREL-2:gNbId=2
...    NRCELL-3/NRREL-2:gNbIdLength=22
...    NRCELL-3/NRREL-2:lcrId=4
...    NRCELL-3/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-3/NRREL-2:sCellOperationalMode=dlAndUl
...    NRCELL-3/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-3/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-3/NRREL-2:gnbPlmn:mncLength=3
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
...    NRBTS:cipherPrefL:nea3_128=0
...    NRCELL:a3MeasEnabled=rsrp
...    NRCELL:absThreshSsbRsrpConsolidation=1
...    NRCELL:sMeasConfigSsbRsrp=1
...    NRCELL:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms512
...    NRCELL:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL:a3MeasSsbRsrp:a3OffsetSsbRsrp=5
...    NRCELL:a1MeashoEnabled=rsrp
...    NRCELL:a2MeashoEnabled=rsrp
...    NRCELL:a1MeashoEnabledSA=rsrp
...    NRCELL:a2MeashoEnabledSA=rsrp
...    NRCELL:a1MeashoSsbRsrp:a1HysteresishoSsbRsrp=0
...    NRCELL:a1MeashoSsbRsrp:a1ThresholdhoSsbRsrp=65
...    NRCELL:a1MeashoSsbRsrp:a1TimeToTriggerhoSsbRsrp=ms480
...    NRCELL:a2MeashoSsbRsrp:a2HysteresishoSsbRsrp=0
...    NRCELL:a2MeashoSsbRsrp:a2ThresholdhoSsbRsrp=34
...    NRCELL:measGapSelectionSA=favourUeThroughput
...    NRCELL:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRCELL:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=65
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
...    XNLINK-1:cPlaneIpAddr=10.0.1.122
...    NRADJGNB-1:administrativeState=Unlocked
...    NRADJGNB-1:gNbIdLength=22
...    NRADJGNB-1:gNodeBId=36
...    NRADJGNB-1:xnLinkRef=1
...    NRADJGNB-1:gnbPlmn:mcc=311|mncLength=3
...    NRADJGNB-1:gnbPlmn:mnc=489|mncLength=3
...    NRADJNRCELL-1:cellDepType=SA+NSA
...    NRADJNRCELL-1:fiveGsTac=788
...    NRADJNRCELL-1:gNbId=36
...    NRADJNRCELL-1:gNbIdLength=22
...    NRADJNRCELL-1:lcrId=1
...    NRADJNRCELL-1:nrarfcn=126990
...    NRADJNRCELL-1:physCellId=48
...    NRADJNRCELL-1:gnbPlmn:mcc=311|mncLength=3
...    NRADJNRCELL-1:gnbPlmn:mnc=489|mncLength=3
...    NRCELL/NRREL-5:cellIndividualSsbRsrpOffset=0dB
...    NRCELL/NRREL-5:cellIndividualSsbRsrqOffset=0dB
...    NRCELL/NRREL-5:gNbId=36
...    NRCELL/NRREL-5:gNbIdLength=22
...    NRCELL/NRREL-5:lcrId=1
...    NRCELL/NRREL-5:removeNotAllowed=false
...    NRCELL/NRREL-5:gnbPlmn:mcc=311|mncLength=3
...    NRCELL/NRREL-5:gnbPlmn:mnc=489|mncLength=3
...    delete:NRCELL/NRREL-5:sCellAdditionMethod
@{VONR}
...    NRCELL:actVoNR=true
...    NRCELL:actEnhancedVoNR=true
...    NRCELL:actNonVoNRGbrService=true
...    NRBTS/NRDRB-15:discardTimer=100ms
...    NRBTS/NRDRB-15:dlFlowControlAlgo=none
...    NRBTS/NRDRB-15:maxDataRateGbrDl=1000
...    NRBTS/NRDRB-15:maxDataRateGbrUl=1000
...    NRBTS/NRDRB-15:nrDrbMacDN=MRBTS-2/NRBTS-2/NRDRB_MAC-4
...    NRBTS/NRDRB-15:nrDrbPdcpDN=MRBTS-2/NRBTS-2/NRDRB_PDCP-3
...    NRBTS/NRDRB-15:nrDrbRlcUmDN=MRBTS-2/NRBTS-2/NRDRB_RLC_UM-1
...    NRBTS/NRDRB-15:queuingDelayDiscarding=Disabled
...    NRBTS/NRDRB-15:resType=GBR
...    NRBTS/NRDRB-15:rlcMode=RLC_UM
...    NRBTS/NRDRB-15:schedulWeight=${EMPTY}
...    NRBTS/NRDRB-15:nrDrbRlcAmDN=${EMPTY}
...    NRBTS/NRDRB-15:maxRlcQueueingDelayGbr=20
...    NRBTS/NRDRB-15:maxTransferDelayGbr=20
...    NRBTS/NRDRB-15:cellAggrLevel=FR1 CA incompatible
...    NRBTS/NRDRB_5QI-6:fiveqiValueList=1
...    NRBTS/NRDRB_5QI-6:nrDrbDN=MRBTS-2/NRBTS-2/NRDRB-15
...    NRBTS/NRDRB_MAC-4:lcgid=4
...    NRBTS/NRDRB_PDCP-3:maxCidAllowed=${EMPTY}
...    NRBTS/NRDRB_PDCP-3:xxFlowControlProfForCuIdx=${EMPTY}
...    NRBTS/NRDRB_RLC_UM-1:dlTReassemblyUm=ms50
...    NRBTS/NRDRB_RLC_UM-1:rlcUMDrbSNLength=rlcUm12bitSN
...    NRBTS/NRDRB_RLC_UM-1:ulTReassemblyUm=ms50
...    NRBTS/NRDRB-16:discardTimer=100ms
...    NRBTS/NRDRB-16:dlFlowControlAlgo=none
...    NRBTS/NRDRB-16:l2OHFactorDl=16
...    NRBTS/NRDRB-16:l2OHFactorUl=16
...    NRBTS/NRDRB-16:maxDataRateGbrDl=1000
...    NRBTS/NRDRB-16:maxDataRateGbrUl=1000
...    NRBTS/NRDRB-16:nrDrbMacDN=MRBTS-2/NRBTS-2/NRDRB_MAC-5
...    NRBTS/NRDRB-16:nrDrbPdcpDN=MRBTS-2/NRBTS-2/NRDRB_PDCP-3
...    NRBTS/NRDRB-16:nrDrbRlcUmDN=MRBTS-2/NRBTS-2/NRDRB_RLC_UM-1
...    NRBTS/NRDRB-16:queuingDelayDiscarding=Disabled
...    NRBTS/NRDRB-16:resType=GBR
...    NRBTS/NRDRB-16:rlcMode=RLC_UM
...    NRBTS/NRDRB-16:schedulWeight=${EMPTY}
...    NRBTS/NRDRB-16:nrDrbRlcAmDN=${EMPTY}
...    NRBTS/NRDRB-16:maxRlcQueueingDelayGbr=20
...    NRBTS/NRDRB-16:maxTransferDelayGbr=20
...    NRBTS/NRDRB-16:cellAggrLevel=Not FR1 CA eligible
...    NRBTS/NRDRB_MAC-5:lcgid=5
...    NRBTS/NRDRB_MAC-5:delayTarget=50
...    NRBTS/NRDRB_5QI-7:fiveqiValueList=2
...    NRBTS/NRDRB_5QI-7:nrDrbDN=MRBTS-2/NRBTS-2/NRDRB-16
...    NRBTS/NRDRB_5QI-8:fiveqiValueList=3
...    NRBTS/NRDRB_5QI-8:nrDrbDN=MRBTS-2/NRBTS-2/NRDRB-16
...    NRBTS/NRDRB_5QI-9:fiveqiValueList=71
...    NRBTS/NRDRB_5QI-9:nrDrbDN=MRBTS-2/NRBTS-2/NRDRB-16
...    NRBTS/NRDRB_5QI-10:fiveqiValueList=128
...    NRBTS/NRDRB_5QI-10:nrDrbDN=MRBTS-2/NRBTS-2/NRDRB-16

@{5GC002396}
...    NRCELL:actFullPwrMode=true

${ue_nr_capabilities_06}    SEPARATOR=
...    F9A0700047D4FFA17DF8E6BC32001A0349CF9A44F3E0048018807C07C0203F1C03EF3E26807BDEB70D0645020E0000075C160145B25AA0581
...    3E439F40478C73E618F28581C0E1E0A4FF93FE284003650000500000379C10403DEF5B8683228107000003AE0B00A2D92D502C09F21CFA023
...    C639F30C7942C0E070F066F3823007BDEB70D0645020E0000075C160145B25AA05813E439F40478C73E618F28581C0E1E0DDE7C2800F7BD6E
...    1A0C8A041C00000EB82C028B64B540B027C873E808F18E7CC31E50B0381C3C189FF27FC508006CA0000A000000950785000184D0000048158
...    70500713400000848150788C0018280001048150708C070A000001848100385000001141E230006134000A120561C2301C4D00000C120541E
...    2300071340000384C0541E2300070A00000404C0401C028809B010602308A0194130A74ED8E7C3853A76C73E1C29D3B639F0E14E9DB1CF870
...    276C73E1C29D3B639F0E14E9DB1CF870A74ED8E7C3841B1CF8603C246318C06318C7F00000026007C005638280381F84800E06000C001F010
...    E5A00000E00E5A00002E00E5A00004E00E5A00006E00E5A00008E00046505E54560656525606500C180000018000600005060001800020180
...    0060000C060000372882F95415C0E0AE530509008802783C1E0F0780002020200400808020001010020000401002080803006020040004040
...    1800010020040020100204040280301004000202014000080200410500A00E00C01C02803050020060100240100208080500602004008D403
...    80010203038D9293927814060148
#CA_n71b*_n78a*,supportedSRS-TxPortSwitch t1r2 for n78a

@{5QI5_DRB10_DRX-4}
...    drx-Config setup
...    drx-onDurationTimer milliSeconds : ms10
...    drx-InactivityTimer ms40
...    drx-HARQ-RTT-TimerDL 0
...    drx-HARQ-RTT-TimerUL 0
...    drx-RetransmissionTimerDL sl0
...    drx-RetransmissionTimerUL sl0
...    drx-LongCycleStartOffset ms80
...    drx-SlotOffset 0
...    drx-Config release : NULL
@{5QI1_DRB15_DRX-6}
...    drx-Config setup
...    drx-onDurationTimer milliSeconds : ms10
...    drx-InactivityTimer ms10
...    drx-HARQ-RTT-TimerDL 0
...    drx-HARQ-RTT-TimerUL 0
...    drx-RetransmissionTimerDL sl24
...    drx-RetransmissionTimerUL sl24
...    drx-LongCycleStartOffset ms40
...    drx-SlotOffset 0
...    drx-Config release : NULL
@{5QI3_DRB16_DRX-5}
...    drx-Config setup
...    drx-onDurationTimer milliSeconds : ms10
...    drx-InactivityTimer ms10
...    drx-HARQ-RTT-TimerDL 0
...    drx-HARQ-RTT-TimerUL 0
...    drx-RetransmissionTimerDL sl16
...    drx-RetransmissionTimerUL sl16
...    drx-LongCycleStartOffset ms20
...    drx-SlotOffset 0
...    drx-Config release : NULL
@{5QI2_DRB16_DRX-5}
...    @{5QI3_DRB16_DRX-5}

@{5QI1_DRB15_DRX-6_&_scell_release}
...    @{5QI1_DRB15_DRX-6}
...    sCellToReleaseList

@{sCellAdditionMethod_cell1_blind}
...    NRCELL-1/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-2:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-3:sCellAdditionMethod=blind

@{sCellAdditionMethod_cell1_covBasedA1}
...    NRCELL-1/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-3:sCellAdditionMethod=covBasedA1
*** Test Cases ***
CB009109-5G-ET_B002_B003_DRX_override_subsequently_for_nonGBR_DRX_and_VoNR_DRX_and_nonVoNR_GBR_DRX_when_actDrbDrx_true
    [Documentation]
    ...    precondition : 5QI5-DRB10-DRX4,5QI3_DRB16_DRX5,5QI1_DRB15_DRX6,5QI2_DRB16_DRX5
    ...    CA :6137 && 9059 ,5QI1 related DRB is FR1 CA incompatible, 5QI2/3 related DRB is Not FR1 CA eligible
    ...    B002
    ...    1.    The purpose of this test case is to check following scenarios:
    ...    Higher priority DRX overrides lower priority DRX based on SA Call with 5QI5 + 5QI1 + 5QI3, then drop 5QI3.
    ...    2.    Test Case Steps:
    ...    Step-1:Attach UE to the FDD NR cell, allowedServingCells to Pcell only configured for SRB.
    ...    Step-2:A1 measurement event for ULCA addition,,DRX-4 configured
    ...    Step-3:UE PDU Session Modify to Add 5QI-1,DRX-6 configured.
    ...    Step-4:UE PDU Session Modify to Add 5QI-3,DRX-5 configured.
    ...    Step-5:UE PDU Session Modify to Del 5QI-3,DRX-6 configured.
    ...    Step-6:UE PDU Session Modify to Del 5QI-1,DRX-4 configured.
    ...    Step-7:UE PDU Session Modify to Add 5QI-3,DRX-5 configured.
    ...    Step-8:UE PDU Session Modify to Del 5QI-3,DRX-4 configured.
    ...    Step-9:UE PDU Session Modify to Add 5QI-1,DRX-6 configured.
    ...    Step-10:modify the priority of 5QI-1 bearer.
    ...    Step-11:release PDU1 ,DRX uninstall, no DRX.
    ...    B003
    ...    1.    The purpose of this test case is to check following scenarios:
    ...    Lower priority DRX not overrides higher priority DRX based on SA Call with 5QI5 + 5Q2 + 5QI1, then drop 5QI1.
    ...    2.    Test Case Steps:
    ...    Step-1:Attach UE to the FDD NR cell, allowedServingCells to Pcell only configured for SRB.
    ...    Step-2:UE PDU Session Modify to Add 5QI-2,DRX-5 configured.
    ...    Step-3:UE PDU Session Modify to Add 5QI-1,no drx changed.
    ...    Step-4:UE PDU Session Modify to Del 5QI-1,no drx changed.
    ...    Step-5:A1 measurement event for UL CA addition.
    [Tags]    QC_46917
    SA UE Register and PDU Session Setup     ue_id=1    ue_nr_capabilities=${ue_nr_capabilities_06}
    Pcell A1 report to trigger Scell Addition    ue_id=1
    UE PDU Session Modify to Add    qosflows=3    fiveQi=1    qfi=2    pass_regexp=@{5QI1_DRB15_DRX-6_&_scell_release}
    UE PDU Session Modify to Add    qosflows=5    fiveQi=3    qfi=3    pass_regexp=@{5QI3_DRB16_DRX-5}
    UE PDU Session Modify to Del    qosflows=5    fiveQi=3    qfi=3    pass_regexp=@{5QI1_DRB15_DRX-6}
    UE PDU Session Modify to Del    qosflows=3    fiveQi=1    qfi=2    pass_regexp=@{5QI5_DRB10_DRX-4}
    UE PDU Session Modify to Add    qosflows=5    fiveQi=3    qfi=2    pass_regexp=@{5QI3_DRB16_DRX-5}
    Pcell A1 report to trigger Scell Addition    ue_id=1
    UE PDU Session Modify to Del    qosflows=5    fiveQi=3    qfi=2    pass_regexp=@{5QI5_DRB10_DRX-4}
    UE PDU Session Modify to Add    qosflows=3    fiveQi=1    qfi=2    pass_regexp=@{5QI1_DRB15_DRX-6_&_scell_release}
#B003
    OnlineParamChange    ${sCellAdditionMethod_cell1_blind}
    SA UE Register and PDU Session Setup    ue_id=2    ue_nr_capabilities=${ue_nr_capabilities_06}
    UE PDU Session Modify to Add    ue_id=2    qosflows=4    fiveQi=2    qfi=2    pass_regexp=@{5QI2_DRB16_DRX-5}
    ...    fail_regexp=sCellToReleaseList
    UE PDU Session Modify to Add    ue_id=2    qosflows=3    fiveQi=1    qfi=3    pass_regexp=sCellToReleaseList
    ...    fail_regexp=drx-Config setup
    UE PDU Session Modify to Del    ue_id=2    qosflows=3    fiveQi=1    qfi=3    pass_regexp=sCellToAddModList
    ...    fail_regexp=drx-Config release
#B003 end
    Execute Egate Command    qosflow_modify id=3 priority=14
    UE PDU Session release    pdu=1

    [Teardown]    Test Case Teardown

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/4cells_2F2T

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir


Modify Cfg
    Update Cfg    mme_pool_area id=1 mmegi=1 plmn=311:489 eq_plmn=250:255 tac_list=777,111,222,444,333,200
    Update Cfg    enb_endc_param id=1 control_flow_period=3gpp1 use_nr_ran_cont=on serving_cell_index_range_scg=8:14
    ${Update_Cfg_1}    catenate
    ...    set_cell id=2 enb=1 eci=0x1234602 pci=3:1 tac=222 proxy=10.0.2.1:12220|10.0.2.1:8890
    ...    earfcn=2000:20000 mandatory_for_activation=off
    Update Cfg    ${Update_Cfg_1}
    ${Update_Cfg_2}    catenate
    ...    set_enb id=11 plmn=250:255 s1=10.0.1.138 enb_id_macro=0x12347 daemon=10.0.2.1:22222 x2=10.0.1.127
    ...    x2u=10.0.1.137 type=simulated x2_peers=none
    Update Cfg    ${Update_Cfg_2}
    Update Cfg    enb_param id=1 drb_id_begin=3 endc_capable_qci=all
    Update Cfg    enb_param id=11 drb_id_begin=3 endc_capable_qci=all
    Update Cfg    enb_endc_param id=11 control_flow_period=3gpp1 use_nr_ran_cont=on serving_cell_index_range_scg=8:14
    ${Update_Cfg_3}    catenate
    ...    set_cell id=1 enb=11 eci=0x1234701 pci=7:2 tac=222 proxy=10.0.2.1:8887 earfcn=2000:20000
    ...    mandatory_for_activation=off
    Update Cfg    ${Update_Cfg_3}
    ${Update_Cfg_4}    catenate
    ...    set_gnb id=3 type=simulated plmn=311:489 s1u=10.0.1.126 ng=10.0.1.127 gnb_id=0x24:22 daemon=10.0.2.1:22222
    ...    x2=10.0.1.128:36422 x2_peers=none xn=10.0.1.122 nssai=0x1:0xd143a5 amf=1
    Update Cfg    ${Update_Cfg_4}
    Update Cfg    set_cell id=1 gnb=3 pci=16:0 tac=788 nrci=0x01 tdd_cell=off proxy=10.0.2.92:9999 nr_arfcn=136100:126900 gscn=1587
    Update Cfg    gnb_param id=3 xn_listening_socket=1 send_xn_setup=true
    Update Cfg    gnb_endc_param id=3 use_nr_ran_cont=true scg_dl_dist_percent=0 enable_dud_poll_bit=0
    Update Cfg    gnb_param id=3 x2_listening_socket=1 measEvent=A3
    Update Cfg    set_qosflow id=1 5qi=6 default=off
    Update Cfg    set_qosflow id=3 5qi=1
    Update Cfg    set_qosflow id=2 5qi=5 default=on
    Update Cfg    set_qosflow id=4 5qi=2
    Update Cfg    set_qosflow id=5 5qi=3
    Update Cfg    set_qosflow id=6 5qi=4
    Update Cfg    set_qosflow id=7 5qi=71
    Update Cfg    set_qosflow id=8 5qi=128 qos_flow_type=gbr mfbr_dl=250 mfbr_ul=250 gfbr_dl=120 gfbr_ul=120
    Update Cfg    set_qosrule id=1 proto=tcp qos_flow=2
    Update Cfg    set_qosrule id=2 proto=udp qos_flow=3
    Update Cfg    set_nwslice id=1 qos_flows=8,7,6,5,4,3,2,1 qos_rules=1,2 snssai=0x01:0xD143A5 default=on ue=1-30 amf=1
    Update Cfg    ue_nr_capabilities id=1-30 voice_over_nr=on:on:off
    Update Cfg    amf_param id=1 full_nas_auth=on ims_voice_3gpp=on nia=null+zuc nea=null+zuc
    ${Update_ue_param}    catenate    SEPARATOR=
    ...    ue_param id=1-30 nr_usage_setting=voice_centric ue_nr_capabilities=${ue_nr_capabilities_06}
    Update Cfg    ${Update_ue_param}
    FOR    ${SA_id}    IN RANGE    1    31
        Update Cfg    set_pdu_gateway id=${SA_id} ue_nat_ip=72.23.0.${SA_id} dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    END
    FOR    ${NSA_id}    IN RANGE    31    61
        Update Cfg    set_bearer id=3 ue=${NSA_id} qci=8 pdn=1 default=off
    END
    ${Update_Cfg_8}    catenate
    ...    set_gnb id=2 type=external plmn=311:489 s1u=10.0.1.112 x2=10.0.1.2:36422 ng=10.0.1.2 xn=10.0.1.2:38422
    ...    gnb_id=0x2:22 daemon=10.0.2.1:22222 x2_peers=none amf=1 plmnList=311:489 nssai=0x1:0xd143a5
    Update Cfg    ${Update_Cfg_8}

SA UE PDU Session Setup
    [Arguments]    ${pdu}=1    ${fiveQi}=5    ${ue_id}=1
    Start RRC Log    PDU_Session_Setup_${ue_id}
    ${ret1}=    Execute Egate Command    ue_pdu_session_setup pdu=${pdu} ue=${ue_id} nwslice=1 gw=${ue_id}
    ...    pass_regexp=QoS Routing Table
    Should Contain    ${ret1}    Created FiveQi:Qfi mapping fiveQi ${fiveQi} qfi 1
    Get RRC Log

SA UE Register and PDU Session Setup
    [Arguments]    ${ue_id}=1    ${ue_nr_capabilities}=${ue_nr_capabilities_06}    ${target_cell}=1
    Execute Egate Command    qosflow_modify default=on qos_flow=2
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${target_cell}
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_register id=${ue_id} ue_nr_capabilities=${ue_nr_capabilities_06}
    ...    Received REGISTRATION COMPLETE from UE
    SA UE PDU Session Setup    ue_id=${ue_id}

Pcell A1 report to trigger Scell Addition
    [Arguments]    ${ue_id}=1    ${carrierfreq}=126990    ${phycell_id}=60    ${sCellIndex}=1    ${srsrp}=80
    Start RRC Log     Scell_Addition_UE_${ue_id}
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A1
    ${A1_Scell_addition}    catenate
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} phycell_id=${phycell_id} event=A1
    ...    srsrp_nr=${srsrp} srsrq_nr=40
    ${ret1}=    Execute Egate Command    ${A1_Scell_addition}    scellIdx:${sCellIndex}
    Should Contain    ${ret1}    eventId eventA2
    Should Contain    ${ret1}    a2-Threshold rsrp : 34
    Should Contain    ${ret1}    sCellToAddModList
    Get RRC Log

Test Case Teardown
    Release UEs    ue_type=all
    OnlineParamChange    ${sCellAdditionMethod_cell1_covBasedA1}
    Common Test Teardown And Stop Capture Logs

UE PDU Session Modify to Add
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${fiveQi}=5    ${qfi}=2    ${qosflows}=2    ${pass_regexp}=${EMPTY}
    ...    ${fail_regexp}=${EMPTY}
    Start RRC Log    PDU_Session_Modify_to_Add_${ue_id}_${fiveQi}
    ${ret1}=    Execute Egate Command
    ...    ue_pdu_session_modify ue=${ue_id} pdu=${pdu} qosflows_to_add=${qosflows} by=amf
    ...    pass_regexp=${pass_regexp}    fail_regexp=${fail_regexp}
    Should Contain    ${ret1}    Created FiveQi:Qfi mapping fiveQi ${fiveQi} qfi ${qfi}
    Get RRC Log

UE PDU Session Modify to Del
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${fiveQi}=1    ${qfi}=3    ${qosflows}=3    ${pass_regexp}=${EMPTY}
    ...    ${fail_regexp}=${EMPTY}
    Start RRC Log    PDU_Session_Modify_to_Del_${ue_id}_${fiveQi}
    ${ret1}=    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu} qosflows_to_del=${qosflows} by=amf
    ...    pass_regexp=${pass_regexp}    fail_regexp=${fail_regexp}
    Should Contain    ${ret1}    Removed FiveQi:Qfi mapping fiveQi ${fiveQi} qfi ${qfi}
    Get RRC Log

UE PDU Session release
    [Arguments]    ${ue_id}=1    ${pdu}=1
    Start RRC Log    PDU_Session_release
    ${ret1}=    Execute Egate Command    ue_pdu_session_release ue=${ue_id} pdu=${pdu} by=amf
    ...    rrcReconfigurationComplete
    Should Contain    ${ret1}    UE${ue_id}: Released PDU session ID=${pdu}
    Should Contain    ${ret1}    drx-Config release : NULL
    Get RRC Log
