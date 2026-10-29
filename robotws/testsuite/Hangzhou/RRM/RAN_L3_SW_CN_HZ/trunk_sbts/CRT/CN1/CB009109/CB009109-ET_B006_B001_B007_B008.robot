*** Settings ***
Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_VRF    RAN_5G    RAN_5G_TDD    SBTS00    CRT    CLOUD_5G_I_BOO_AP_LOO
...           owner-liupei.fang    team-PZ3_06    release-SBTS24R3
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${BTS_STARTUP_RETRY}    2
${SYSCOM_FLAG}    True

@{PARAMS_IN_SCF}
...    @{CA}
...    @{NRREL}
...    @{Mobillity}
...    @{VONR}
...    @{Others}
...    @{gscn_Arfcn}
...    @{CB009109}
...    @{cell_level_drx}



@{CB009109}
...    NRBTS:actDedicatedAnrDrxProfile=true
...    NRBTS:actDisableUlProactGrantAnr=true
...    NRBTS:actEnhanceIntraNrIntraFreqAnr=true
...    NRBTS:actIntraFreqInterGnbMobilityNSA3x=true
...    NRBTS:actIntraFreqIntraGnbMobilityNSA=true
...    NRBTS:actNsaUeBasedAnrNr=true
...    NRBTS:actNsaUeBasedInterFreqAnrNr=true
...    NRBTS:actSaIntraFreqAnrDrxProf=true
...    NRBTS:actSaUeBasedAnrNr=true
...    NRBTS:actSaUeBasedInterFreqAnrNr=true
...    NRBTS/NRDU-1:carrierAggregationSupportList=${carrierAggregationSupportList}
...    NRBTS/NRDRB_RLC_AM-1:ulTReassemblyIBCA=40
...    NRBTS/NRDRB_RLC_AM-2:ulTReassemblyIBCA=40
...    NRCELL:actCDrx=true
...    NRCELL:actCDrxVoNR=true
...    NRBTS:actDrbDrx=true
...    NRCELL:nonGbrNrDrxDN=NRDRX-4
...    NRCELL:voNRNrDrxDN=MRBTS-2/NRBTS-2/NRDRX-2

...    NRCELL:drxProfileNrAnr:drxControl=any
...    NRCELL:drxProfileNrAnr:nrDrxDN=NRDRX-3
...    NRBTS/NRDRX-1:drxPriority=31
...    NRBTS/NRDRX-2:drxPriority=3
...    NRBTS/NRDRX-3:drxPriority=15
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
...    NRBTS/NRDRX-6:drxOnDurationTimer=20ms
...    NRBTS/NRDRX-6:drxRetransTimerDl=24slot
...    NRBTS/NRDRX-6:drxRetransTimerUl=24slot
...    NRBTS/NRDRX-6:drxPriority=4

...    NRBTS/NRDRX-7:drxHarqRttTimerDl=0symbols
...    NRBTS/NRDRX-7:drxHarqRttTimerUl=0symbols
...    NRBTS/NRDRX-7:drxInactivityTimer=80ms
...    NRBTS/NRDRX-7:drxLongCycle=160ms
...    NRBTS/NRDRX-7:drxOnDurationTimer=10ms
...    NRBTS/NRDRX-7:drxPriority=30
...    NRBTS/NRDRX-7:drxRetransTimerDl=0slot
...    NRBTS/NRDRX-7:drxRetransTimerUl=0slot
...    NRBTS/NRDRX-7:userLabel=${EMPTY}
...    NRBTS/NRDRX-8:drxHarqRttTimerDl=0symbols
...    NRBTS/NRDRX-8:drxHarqRttTimerUl=0symbols
...    NRBTS/NRDRX-8:drxInactivityTimer=80ms
...    NRBTS/NRDRX-8:drxLongCycle=640ms
...    NRBTS/NRDRX-8:drxOnDurationTimer=5ms
...    NRBTS/NRDRX-8:drxPriority=29
...    NRBTS/NRDRX-8:drxRetransTimerDl=0slot
...    NRBTS/NRDRX-8:drxRetransTimerUl=0slot
...    NRBTS/NRDRX-8:userLabel=${EMPTY}
...    NRBTS/NRDRB-1:nrDrxDN=MRBTS-2/NRBTS-2/NRDRX-6
...    NRBTS/NRDRB-15:nrDrxDN=MRBTS-2/NRBTS-2/NRDRX-2
...    NRBTS/NRDRB-16:nrDrxDN=MRBTS-2/NRBTS-2/NRDRX-5
...    NRBTS/NRDRB-10:nrDrxDN=MRBTS-2/NRBTS-2/NRDRX-7
...    NRBTS/NRDRB-13:nrDrxDN=MRBTS-2/NRBTS-2/NRDRX-8
...    NRBTS/NRDRB_5QI-10:fiveqiValueList=128
...    NRBTS/NRDRB_5QI-10:nrDrbDN=MRBTS-2/NRBTS-2/NRDRB-16
...    NRBTS/NRDRB_5QI-6:fiveqiValueList=1
...    NRBTS/NRDRB_5QI-6:nrDrbDN=MRBTS-2/NRBTS-2/NRDRB-15
...    NRBTS/NRDRB_5QI-7:fiveqiValueList=2
...    NRBTS/NRDRB_5QI-7:nrDrbDN=MRBTS-2/NRBTS-2/NRDRB-16
...    NRBTS/NRDRB_5QI-8:fiveqiValueList=3
...    NRBTS/NRDRB_5QI-8:nrDrbDN=MRBTS-2/NRBTS-2/NRDRB-16
...    NRBTS/NRDRB_5QI-9:fiveqiValueList=71
...    NRBTS/NRDRB_5QI-9:nrDrbDN=MRBTS-2/NRBTS-2/NRDRB-16

...    NRBTS/NRANR-1:actAutoEutraNbRemoval=false
...    NRBTS/NRANR-1:actAutoNrNbRemoval=false
...    NRBTS/NRANR-1:autoRecheckAttempts=0
...    NRBTS/NRANR-1:autoRecheckInterval=30
...    NRBTS/NRANR-1:consecHoFailThres=0
...    NRBTS/NRANR-1:consecHoFailThresEutra=3
...    NRBTS/NRANR-1:consecXnResolveFailThres=3
...    NRBTS/NRANRPR-2:anrThresRsrpNbCell=-90
...    NRBTS/NRANRPR-2:anrThresRsrqNbCell=-24
...    NRBTS/NRANRPR-2:anrThresholdSelector=RSRP
...    NRBTS/NRANRPR-2:cellDepMode=SA+NSA
...    NRBTS/NRANRPR-2:consecRecheckForNrNbRemoval=5
...    NRBTS/NRANRPR-2:idleTimeForNrNbRemoval=72
...    NRBTS/NRANRPR-2:maxNumAnrNrrelAllowed=50
...    NRBTS/NRANRPR-2:nrarfcn=518598
...    NRBTS/NRANRPR-2:ssbFrequency=518670

@{cell_level_drx}
...    NRCELL-1:fiveQiDrbDrxList:nrDrxDN=NRDRX-1|nrDrb5qiDN=NRDRB_5QI-4
...    NRCELL-1:fiveQiDrbDrxList:nrDrxDN=NRDRX-6|nrDrb5qiDN=NRDRB_5QI-6

${carrierAggregationSupportList}    SEPARATOR=
...    ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Any_Sa,ca_Fdd_Fdd,ca_Fr1Tdd_Any_Sa,
...    ca_Fdd_Fr1Tdd_Nsa,ca_Fdd_Fr1Tdd_Sa_WithUl,ca_Fr1Tdd_Nsa,ca_Fr1Tdd_Fdd_Nsa


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
...    NRBTS/NRDU-1:flexibleCAMode=ConfigurationIndependent
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
...    NRCELL-1/NRREL-1:sCellOperationalMode=dlOnly
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
...    NRCELL-1/NRREL-2:sCellOperationalMode=dlOnly
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
...    NRCELL-3/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-3/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-3/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-3/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-3/NRREL-2:gNbId=2
...    NRCELL-3/NRREL-2:gNbIdLength=22
...    NRCELL-3/NRREL-2:lcrId=4
...    NRCELL-3/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-3/NRREL-2:sCellOperationalMode=dlOnly
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


@{CB009109_related_for_B001}
...    NRCELL:nonGbrNrDrxDN=NRDRX-5
...    NRBTS/NRDRB-10:nrDrxDN=MRBTS-2/NRBTS-2/NRDRX-1
...    NRBTS/NRDRB-11:nrDrxDN=MRBTS-2/NRBTS-2/NRDRX-5
...    NRBTS/NRDRB-12:nrDrxDN=MRBTS-2/NRBTS-2/NRDRX-5
...    NRBTS/NRDRB-14:nrDrxDN=MRBTS-2/NRBTS-2/NRDRX-7
...    NRBTS/NRDRB-2:nrDrxDN=MRBTS-2/NRBTS-2/NRDRX-1
...    NRBTS/NRDRB-3:nrDrxDN=MRBTS-2/NRBTS-2/NRDRX-5
...    NRBTS/NRDRB-4:nrDrxDN=MRBTS-2/NRBTS-2/NRDRX-5
...    NRBTS/NRDRB-5:nrDrxDN=MRBTS-2/NRBTS-2/NRDRX-5
...    NRBTS/NRDRB-6:nrDrxDN=MRBTS-2/NRBTS-2/NRDRX-7
...    NRBTS/NRDRB-7:nrDrxDN=MRBTS-2/NRBTS-2/NRDRX-6
...    NRBTS/NRDRB-8:nrDrxDN=MRBTS-2/NRBTS-2/NRDRX-5
...    NRBTS/NRDRB-9:nrDrxDN=MRBTS-2/NRBTS-2/NRDRX-6
...    NRBTS/NRDRX-3:drxLongCycle=80ms
...    NRBTS/NRDRX-4:drxInactivityTimer=10ms
...    NRBTS/NRDRX-4:drxLongCycle=320ms
...    NRCELL-1:fiveQiDrbDrxList:nrDrxDN=NRDRX-1|nrDrb5qiDN=NRDRB_5QI-4
...    NRCELL-1:fiveQiDrbDrxList:nrDrxDN=NRDRX-6|nrDrb5qiDN=NRDRB_5QI-6
...    NRBTS/NRDRB-2:nsaDrbParam:nsa3xBearerAllowed=true
...    NRBTS/NRDRB-8:nsaDrbParam:nsa3xBearerAllowed=true
...    NRBTS/NRDRB-9:nsaDrbParam:nsa3xBearerAllowed=true
...    NRBTS/NRDRX-7:drxInactivityTimer=30ms
...    NRBTS/NRDRX-7:drxLongCycle=640ms
...    NRBTS/NRDRX-7:drxOnDurationTimer=20ms

@{CB009109_recovery_B001}
...    NRBTS/NRDRB-10:nrDrxDN=MRBTS-2/NRBTS-2/NRDRX-7
...    delete:NRCELL-1:fiveQiDrbDrxList
...    NRBTS/NRDRX-7:drxInactivityTimer=80ms
...    NRBTS/NRDRX-7:drxLongCycle=160ms
...    NRBTS/NRDRX-7:drxOnDurationTimer=10ms
...    NRBTS/NRDRX-7:drxPriority=30

@{online_actDrbDrx_false}
...    NRBTS:actDrbDrx=false
...    @{onlinechange_cell_level_5QI1_NRDRX}

@{online_actDrbDrx_true}
...    NRBTS:actDrbDrx=true

@{onlinechange_cell_level_5QI5_NRDRX}
...    NRCELL-1:fiveQiDrbDrxList:nrDrxDN=NRDRX-1|nrDrb5qiDN=NRDRB_5QI-1

@{onlinechange_cell_level_5QI1_NRDRX}
...    NRCELL-1:fiveQiDrbDrxList:nrDrxDN=NRDRX-6|nrDrb5qiDN=NRDRB_5QI-6
...    NRBTS/NRDRX-6:drxPriority=4


@{change_parameter_for_B007}
...    @{online_actDrbDrx_false}
...    NRBTS/NRDRX-2:drxPriority=40
...    NRCELL-1:fiveQiDrbDrxList:nrDrxDN=NRDRX-7|nrDrb5qiDN=NRDRB_5QI-1
...    NRCELL-1:fiveQiDrbDrxList:nrDrxDN=NRDRX-2|nrDrb5qiDN=NRDRB_5QI-6
...    NRBTS/NRDRB-10:nrDrxDN=MRBTS-2/NRBTS-2/NRDRX-7
...    NRCELL-1:nonGbrNrDrxDN=NRDRX-1
...    NRBTS/NRDRX-6:drxLongCycle=20ms
...    NRBTS/NRDRX-6:drxPriority=45
...    NRBTS/NRDRX-7:drxInactivityTimer=60ms
...    NRBTS/NRDRX-7:drxLongCycle=320ms




@{change_parameter_for_B008}
...    @{online_actDrbDrx_true}
...    delete:NRCELL-1:fiveQiDrbDrxList
...    NRBTS:act3gppBL23R1=true
...    NRBTS:actIdleMMSteering=true
...    NRBTS:actRrcInactState=intra-gNB
...    NRBTS:actRrcReleasePreference=true
...    NRBTS:drbInactivityTimerSA=60
...    NRBTS:drbRrcInactInactivityTimerSA=10
...    NRBTS:maxUeRrcInactTime=60
...    NRBTS:outOfConnectedPreference=inactive
...    NRBTS:ranPagingCycle=v32
...    NRBTS:rrcInactIMMSteeringEnabled=false
...    NRBTS:rrcInactLocationReportEnabled=false
...    NRBTS:rrcInactPreferredStateEnabled=true
...    NRBTS:srbInactivityTimerSA=30
...    NRBTS/NRDRB-14:nrDrxDN=MRBTS-2/NRBTS-2/NRDRX-1
...    NRBTS/NRDRX-6:drxOnDurationTimer=5ms
...    NRBTS/NRDRX-7:drxInactivityTimer=60ms
...    NRBTS/NRDRX-7:drxLongCycle=320ms
...    NRBTS:t380=5min
...    NRBTS:tRanPagingGuard=4
...    NRBTS:timerReleasePreferenceProhibit=s5
...    NRCELL:actEnhancedFlowControlETh=false
...    NRCELL:idleMMSteeringAlgo=non CA aware
...    NRCELL:idleMMSteeringPercentageOfUes=100
...    NRCELL:idleMMSteeringWRREnabled=true
...    NRCELL:idleMMSteeringWRREnabledSec=Disabled
...    NRCELL:nonGbrNrDrxDN=NRDRX-1
...    NRCELL:primaryPathMaxQueueingDelay=10
...    NRCELL:secondaryPathMaxQueueingDelay=10
...    NRBTS/NRDRX-2:drxPriority=3
...    NRBTS/NRDRB-10:nrDrxDN=MRBTS-2/NRBTS-2/NRDRX-7
...    NRCELL-1:nonGbrNrDrxDN=NRDRX-1
...    NRBTS/NRDRX-6:drxLongCycle=20ms
...    NRBTS/NRDRX-6:drxPriority=4



@{INACTIVE_check}
...    SuspendConfig
...    fullI_RNTI
...    shortI_RNTI
...    nextHopChainingCount
...    t380
...    NR_RRC_INACTIVE
...    Is INACTIVE


@{online_change_NRDRX_for_5QI5}
...    NRBTS/NRDRB-10:nrDrxDN=MRBTS-2/NRBTS-2/NRDRX-1


@{CB009109_recovery_B008}
...    NRBTS/NRDRB-10:nrDrxDN=MRBTS-2/NRBTS-2/NRDRX-7



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


${ue_nr_capabilities_08_with_ICS}    SEPARATOR=
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


@{5QI5_DRB10_DRX-8}
...    drx-Config setup
...    drx-onDurationTimer milliSeconds : ms10
...    drx-InactivityTimer ms80
...    drx-HARQ-RTT-TimerDL 0
...    drx-HARQ-RTT-TimerUL 0
...    drx-RetransmissionTimerDL sl0
...    drx-RetransmissionTimerUL sl0
...    drx-LongCycleStartOffset ms640
...    drx-SlotOffset 0



@{5QI1_DRB15_NRDRX6}
...    drx-Config setup
...    drx-onDurationTimer milliSeconds : ms20
...    drx-InactivityTimer ms10
...    drx-HARQ-RTT-TimerDL 0
...    drx-HARQ-RTT-TimerUL 0
...    drx-RetransmissionTimerDL sl24
...    drx-RetransmissionTimerUL sl24
...    drx-LongCycleStartOffset ms40
...    drx-SlotOffset 0
...    drx-Config release : NULL






@{5QI8_DRB13_DRX-7}
...    drx-Config setup
...    drx-onDurationTimer milliSeconds : ms10
...    drx-InactivityTimer ms80
...    drx-HARQ-RTT-TimerDL 0
...    drx-HARQ-RTT-TimerUL 0
...    drx-RetransmissionTimerDL sl0
...    drx-RetransmissionTimerUL sl0
...    drx-LongCycleStartOffset ms160
...    drx-SlotOffset 0


@{sCellAdditionMethod_cell1_covBasedA1}
...    NRCELL-1/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-3:sCellAdditionMethod=covBasedA1


@{cell_level_fiveQiDrbDrxList_delete}
...    delete:NRCELL-1:fiveQiDrbDrxList:nrDrxDN=NRDRX-1

@{Resume_with_scell_regexp}
...    rrcResumeRequest1
...    rrcResumeComplete


@{Nsa_QCI5}
...    reported successful RA
...    rrcConnectionReconfigurationComplete
...    drx-onDurationTimer milliSeconds : ms10
...    drx-InactivityTimer ms80
...    drx-HARQ-RTT-TimerDL 0
...    drx-HARQ-RTT-TimerUL 0
...    drx-RetransmissionTimerDL sl0
...    drx-RetransmissionTimerUL sl0
...    drx-LongCycleStartOffset ms160
...    drx-SlotOffset 0


@{Nsa_QCI9_add}
...    rrcConnectionReconfigurationComplete
...    UE31: Successfully reconfigured dual connectivity
...    drx-onDurationTimer milliSeconds : ms20
...    drx-InactivityTimer ms30
...    drx-HARQ-RTT-TimerDL 0
...    drx-HARQ-RTT-TimerUL 0
...    drx-RetransmissionTimerDL sl0
...    drx-RetransmissionTimerUL sl0
...    drx-LongCycleStartOffset ms640
...    drx-SlotOffset 0

@{Nsa_QCI9_del}
...    rrcConnectionReconfigurationComplete
...    drx-onDurationTimer milliSeconds : ms10
...    drx-InactivityTimer ms80
...    drx-HARQ-RTT-TimerDL 0
...    drx-HARQ-RTT-TimerUL 0
...    drx-RetransmissionTimerDL sl0
...    drx-RetransmissionTimerUL sl0
...    drx-LongCycleStartOffset ms160
...    drx-SlotOffset 0


@{5QI5_DRX-1}
...    drx-onDurationTimer milliSeconds : ms10
...    drx-InactivityTimer ms80
...    drx-HARQ-RTT-TimerDL 0
...    drx-HARQ-RTT-TimerUL 0
...    drx-RetransmissionTimerDL sl0
...    drx-RetransmissionTimerUL sl0
...    drx-LongCycleStartOffset ms160
...    drx-SlotOffset 0

@{5QI1_DRX-2}
...    drx-onDurationTimer milliSeconds : ms10
...    drx-InactivityTimer ms20
...    drx-HARQ-RTT-TimerDL 0
...    drx-HARQ-RTT-TimerUL 0
...    drx-RetransmissionTimerDL sl0
...    drx-RetransmissionTimerUL sl0
...    drx-LongCycleStartOffset ms40
...    drx-SlotOffset 0


@{5QI5_DRX-7}
...    drx-onDurationTimer milliSeconds : ms10
...    drx-InactivityTimer ms60
...    drx-HARQ-RTT-TimerDL 0
...    drx-HARQ-RTT-TimerUL 0
...    drx-RetransmissionTimerDL sl0
...    drx-RetransmissionTimerUL sl0
...    drx-LongCycleStartOffset ms320
...    drx-SlotOffset 0



*** Test Cases ***
CB009109-5G-ET_B006_Cell_level_DRX_override_DRB_level_DRX_for_SA_RRE_when_actDrbDrx_true
    [Documentation]
    ...    1.The purpose of this test case is to check following scenarios:
    ...    a. Cell level DRX overrides the DRB level DRX
    ...    b. Cell level DRX will not override the DRX (DRB level or cell level) which belongs to other DRB
    ...    c. Online change of DRX priority will take effect in the next transaction.
    ...    2.     configuration:
    ...    NRBTS/NRDRX[8] = defined as per the 5QI-8 DRX configuration
    ...    NRBTS/NRDRX[8].drxPriority = 29(Higher Priority than other nonGBR DRX)
    ...    DRX profile for SA call 5QI-5 (nonGBR) => NRDRB_5QI1->NRDRB10->nrDrxDN = NRDRX-7.(drxPriority = 30)
    ...    DRX profile for SA call 5QI-8 (nonGBR) => NRDRB_5QI4->NRDRB13->nrDrxDN = NRDRX-8.(drxPriority = 29)
    ...    DRX profile for SA call 5QI-1 (GBR) => NRDRB_5QI6->NRDRB15->nrDrxDN = NRDRX-2.(drxPriority = 3)
    ...    And following configuration of NRCELL level DRX are configured:
    ...    NRBTS.NRCELL.fiveQiDrbDrxList.nrDrb5qiDN = MRBTS-1/NRBTS-1/NRDRB_5QI-4(point to 5qi-8)
    ...    NRBTS.NRCELL.fiveQiDrbDrxList.nrDrxDN = MRBTS-1/NRBTS-1/NRDRX-1(drxPriority = 31)
    ...    NRBTS.NRCELL.fiveQiDrbDrxList.nrDrb5qiDN = MRBTS-1/NRBTS-1/NRDRB_5QI-6(point to 5qi-1)
    ...    NRBTS.NRCELL.fiveQiDrbDrxList.nrDrxDN = MRBTS-1/NRBTS-1/NRDRX-6(drxPriority = 4)
    ...    3.    Test Case Steps:
    ...    Step-1:UE register and attach to cell-1 with 5QI-5 drb setup
    ...    Expected result:UE register successfully and NRDRX-7's config setup for no cell level drx.
    ...    Step-2:add 5QI-8 drb
    ...    Expected result:Add 5QI-8 drb successfully ,NRDRX-7 keeps using because 5QI-8 Cell level DRX with lower drxpriority
    ...    Step-3:online delete cell level 5qi-8 fiveQiDrbDrxList
    ...    Expected result:online deleted successfully and drx not changed
    ...    Step-4:Trigger RRE
    ...    Expected result:after RRE compeleted, NRDRX-7 is uninstalled and NRDRX-8 is installed     
    ...    Step-5:add 5QI-1 drb
    ...    Expected result:NRDRX-8 is uninstalled and cell level VoNR DRX profile NRDRX-6 is installed    
    ...    Step-6:trigger RRE due to no RRC Reconfiguration Complete respond to GNB again
    ...    Expected result:NRDRX-8 is installed firstly then uninstalled and NRDRX-6 is installed.
    ...    Step-7:release UE
    ...    Expected result:release UE successfully     
    [Tags]    B006    QC_46915
    SA UE Register and PDU Session Setup     ue_id=1    ue_nr_capabilities=${ue_nr_capabilities_06}     pass_regexp=${5QI8_DRB13_DRX-7}      
    UE PDU Session Modify to Add    ue_id=1    pdu=1    fiveQi=8    qfi=2    qosflows=9      fail_regexp=${5QI5_DRB10_DRX-8}
    OnlineParamChange     ${cell_level_fiveQiDrbDrxList_delete}
    Trigger RRC Reestablish with cause      ue_id=1    cause=reconfigurationFailure        pass_regexp=${5QI5_DRB10_DRX-8}
    UE PDU Session Modify to Add     ue_id=1    pdu=1    fiveQi=1    qfi=3    qosflows=3    pass_regexp=${5QI1_DRB15_NRDRX6}     
    Trigger RRC Reestablish with cause     ue_id=1    cause=reconfigurationFailure    fail_regexp=${5QI5_DRB10_DRX-8}     
    [Teardown]    Test Case Teardown
    
CB009109-5G-ET_B001_nonGBR_DRX_override_between_two_nonGBR_DRB_with_different_priority_for_NSA_call_when_actDrbDrx_true
    [Documentation]
    ...    1. The purpose of this test case is to check following scenarios:
    ...    Higher priority DRX overrides lower priority DRX for nonGBR DRBs based on NSA Call QCI5 + QCI9.
    ...    2. configuration:
    ...    NRBTS/NRDRX[8] = defined as per the 5QI-8 DRX configuration
    ...    NRBTS/NRDRX[8].drxPriority = 29(Higher Priority than other nonGBR DRX)
    ...    DRX profile for NSA call QCI-5 (nonGBR) => NRDRB_QCI1->NRDRB2->nrDrxDN = NRDRX-1.(drxPriority = 31)
    ...    DRX profile for NSA call QCI-9 (nonGBR) => NRDRB_QCI5->NRDRB6->nrDrxDN = NRDRX-7.(drxPriority = 30)
    ...    DRX profile for SA call 5QI-1 (GBR) => NRDRB_5QI6->NRDRB15->nrDrxDN = NRDRX-2.(drxPriority = 3)
    ...    DRX profile for SA call 5QI-5 (nonGBR) => NRDRB_5QI[a1]->NRDRB[b1]->nrDrxDN = NRDRX-1.
    ...    DRX profile for SA call 5QI-9 (nonGBR) => NRDRB_5QI[a2]->NRDRB[b2]->nrDrxDN = NRDRX-7.
    ...    DRX profile for SA call 5QI-2 (GBR) => NRDRB_5QI[a4]->NRDRB[b4]->nrDrxDN = NRDRX-5. 
    ...    3.    Test Case Steps:
    ...    Step-1:UE register and attach to cell-1 with QCI-5 drb setup
    ...    Expected result: UE attached and bearer QCI-5 setup, and nonGBR DRX profile NRDRX[1] is installed for the UE.
    ...    Step-2:add QCI-9 drb
    ...    Expected result:nonGBR DRX profile NRDRX[1] is uninstalled and NRDRX[7] is installed for the UE since NRDRX[7] has higher priority.
    ...    Step-3:Drop QCI-9 bearer:
    ...    Expected result:nonGBR DRX profile NRDRX[7] is uninstalled and NRDRX[1] is installed.
    ...    Step-4:release UE
    ...    Expected result:release UE successfully      
    [Tags]    B001    QC_46916
    OnlineParamChange     ${CB009109_related_for_B001}
    Nsa ue register with QCI5    pass_regexp=${Nsa_QCI5}    ue_id=31
    NSA add QCI9    ue_id=31    pass_regexp=${Nsa_QCI9_add}
    NSA dorp QCI9    ue_id=31    pass_regexp=${Nsa_QCI9_del}
    [Teardown]    B001_teardown  
    

CB009109-5G-ET_B007_actDrbDrx_online_activation_and_deactivation_Should_effect_next_Call_when_actDrbDrx_true
    [Documentation]
    ...    1.The purpose of this test case is to check following scenarios:
    ...    a. CB009109 FAF actDrbDrx online change will take effect for the next call
    ...    b. PDL should work well, e.g. actCDrx is required to be set to true if actDrbDrx is true.
    ...    c. Cell level override will not happen if actDrbDrx is false.
    ...    2.     configuration:
    ...    NRBTS/actDrbDrx = false
    ...    DRX profile for SA call 5QI-5 (nonGBR) => NRDRB_5QI1->NRDRB10->nrDrxDN = NRDRX-7.(drxPriority = 30)
    ...    DRX profile for SA call 5QI-1 (GBR) => NRDRB_5QI6->NRDRB15->nrDrxDN = NRDRX-2.(drxPriority = 40)
    ...    And following configuration of NRCELL level DRX are configured:
    ...    NRBTS.NRCELL.fiveQiDrbDrxList.nrDrb5qiDN = MRBTS-1/NRBTS-1/NRDRB_5QI-4(point to 5qi-5)
    ...    NRBTS.NRCELL.fiveQiDrbDrxList.nrDrxDN = MRBTS-1/NRBTS-1/NRDRX-1(drxPriority = 31)
    ...    NRBTS.NRCELL.fiveQiDrbDrxList.nrDrb5qiDN = MRBTS-1/NRBTS-1/NRDRB_5QI-6(point to 5qi-1)
    ...    NRBTS.NRCELL.fiveQiDrbDrxList.nrDrxDN = MRBTS-1/NRBTS-1/NRDRX-6(drxPriority = 45)
    ...    3.    Test Case Steps:
    ...    Step-1:UE1 register and attach to cell-1 with 5QI-5 drb setup
    ...    Expected result:UE register successfully and NRDRX-1's config setup for no cell level drx.
    ...    Step-2:add 5QI-1 drb
    ...    Expected result:Add 5QI-1 drb successfully ,NRDRX-1 is uninstalled and NRDRX-2 is installed for the UE-1
    ...    Step-3:online change actDrbDrx to true
    ...    Expected result:online change successfully and drx not changed
    ...    Step-4:UE2 register and attach to cell-1 with 5QI-5 drb setup
    ...    Expected result:UE-2 attached and bearer 5QI-5 setup, nonGBR DRX profile NRDRX-7 is installed for the UE-2.   
    ...    Step-5:UE2 add 5QI-1 drb
    ...    Expected result:Add 5QI-1 drb successfully ,and NRDRX-7 is not changed for the UE-2 because of higher priority than NRDRX-2.
    ...    Step-6:Cell level override nonGBR DRX profile with NRDRX-1 for 5QI-5
    ...    Expected result:online modify change successfully for cell level override
    ...    Step-7:UE-2 drop 5QI-1
    ...    Expected result: UE2 drop 5QI-1,and NRDRX-7 is uninstalled and NRDRX-1 is installed for UE-2 because of cell level override.
    ...    Step-8:Online change actDrbDrx to false
    ...    Expected result: online change successfully and drx no impact.   
    ...    Step-9:Trigger RRE on UE1
    ...    Expected result:after RRE compeleted,NRDRX-2 is installed for UE-1  
    ...    Step-10:UE2 add 5QI-1 drb
    ...    Expected result:5QI-1 added, and NRDRX-1 is installed because of pririty is 30
    ...    Expected result:release UE successfully    
    
    [Tags]    B007    QC_46913
    OnlineParamChange     ${change_parameter_for_B007}
    SA UE Register and PDU Session Setup     ue_id=1    ue_nr_capabilities=${ue_nr_capabilities_06}     pass_regexp=${5QI5_DRX-1}      
    UE PDU Session Modify to Add    ue_id=1    pdu=1    fiveQi=1    qfi=2    qosflows=3      pass_regexp=${5QI1_DRX-2}    
    OnlineParamChange     ${online_actDrbDrx_true}
    SA UE Register and PDU Session Setup     ue_id=2    pdu=2    ue_nr_capabilities=${ue_nr_capabilities_06}     pass_regexp=${5QI5_DRX-7}      
    UE PDU Session Modify to Add    ue_id=2    pdu=2    fiveQi=1    qfi=2    qosflows=3 
    OnlineParamChange     ${onlinechange_cell_level_5QI5_NRDRX}
    UE PDU Session Modify to Del    ue_id=2    pdu=2    qosflows=3    fiveQi=1    qfi=2    pass_regexp=${5QI5_DRX-1} 
    OnlineParamChange     ${online_actDrbDrx_false}
    Trigger RRC Reestablish with cause      ue_id=1    cause=reconfigurationFailure        pass_regexp=${5QI1_DRX-2}
    UE PDU Session Modify to Add     ue_id=2    pdu=2    fiveQi=1    qfi=2    qosflows=3                 
    [Teardown]    Test Case Teardown



CB009109-5G-ET_B008_RRC_inactive_and_resume_when_actDrbDrx_True
    [Documentation]
    ...    1.The purpose of this test case is to check following scenarios:
    ...    DRX should be re-selected based on the latest NIDD parameter setting after RRC inactive and RRC resume.
    ...    2.     configuration:
    ...    NRBTS/actDrbDrx = true
    ...    NRBTS/NRDRX[8].drxPriority = 29(Higher Priority than other nonGBR DRX)
    ...    DRX profile for SA call 5QI-1 (GBR) => NRDRB_5QI6->NRDRB15->nrDrxDN = NRDRX-2.(drxPriority = 3)
    ...    DRX profile for SA call 5QI-5 (nonGBR) => NRDRB_5QI[a1]->NRDRB[b1]->nrDrxDN = NRDRX-1.
    ...    DRX profile for SA call 5QI-9 (nonGBR) => NRDRB_5QI[a2]->NRDRB[b2]->nrDrxDN = NRDRX-7.
    ...    DRX profile for SA call 5QI-2 (GBR) => NRDRB_5QI[a4]->NRDRB[b4]->nrDrxDN = NRDRX-5. 
    ...    And following configuration of NRCELL level DRX are configured:
    ...    DRX profile for SA call 5QI-9 (nonGBR) => NRDRB_5QI[a1]->NRDRB[b1]->nrDrxDN = NRDRX-7.(drxPriority = 30)
    ...    3.    Test Case Steps:
    ...    Step-1:UE register and attach to cell-1 with 5QI-5 setup and start traffic:
    ...    Expected result:UE attached and bearer 5QI-5 setup, and nonGBR DRX profile NRDRX-7 is installed for the UE, traffic is started.
    ...    Step-2:online change DRX profile for SA call 5QI-5 (nonGBR) => NRDRB_5QI[a1]->NRDRB[b1]->nrDrxDN = NRDRX-1.(drxPriority = 31)
    ...    Expected result:online change succeed and DRX keeps using
    ...    Step-3:add 5qi-1 then drop it 
    ...    Expected result:NRDRX-7 is uninstalled and NRDRX-2 is installed because of higher priority, 
    ...    then NRDRX-2 uninstalled and NRDRX-1 is installed after 5qi-1 dropped.
    ...    Step-4:stop traffic and wait 15s to trigger RRC inactive:
    ...    Expected result:RRC state enters into inactive state with RRC Release containing SuspendConfig.
    ...    Step-5:start traffic again:
    ...    Expected result:traffic started and UE enter into RRC connected mode again and DRX profile NRDRX-1 is installed.
    ...    Step-6:release UE
    ...    Expected result:release UE successfully     
    [Tags]    B008    QC_46912
    OnlineParamChange     ${change_parameter_for_B008}
    SA UE Register and PDU Session Setup with ics core network     ue_id=1    
    ...    ue_nr_capabilities=${ue_nr_capabilities_08_with_ICS}     pass_regexp=${5QI5_DRX-7}      
    OnlineParamChange     ${online_change_NRDRX_for_5QI5}
    UE PDU Session Modify to Add    ue_id=1    pdu=1    fiveQi=1    qfi=2    qosflows=3      pass_regexp=${5QI1_DRX-2}    
    UE PDU Session Modify to Del    ue_id=1    qosflows=3    fiveQi=1    qfi=2    pass_regexp=${5QI5_DRX-1} 
    Stop traffic to Inactive
    Start traffic to trigger resume 
    [Teardown]    Test Case Teardown for B008


*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/4cells_2F2T

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir


Modify Cfg
    Update Cfg    enb_param id=1 drb_id_begin=1 endc_capable_qci=all
    Update Cfg    set_qosflow id=1 5qi=6 default=off
    Update Cfg    set_qosflow id=3 5qi=1
    Update Cfg    set_qosflow id=2 5qi=5 default=on
    Update Cfg    set_qosflow id=4 5qi=2
    Update Cfg    set_qosflow id=5 5qi=3
    Update Cfg    set_qosflow id=6 5qi=4
    Update Cfg    set_qosflow id=7 5qi=71
    Update Cfg    set_qosflow id=9 5qi=8
    Update Cfg    set_qosflow id=8 5qi=128 qos_flow_type=gbr mfbr_dl=250 mfbr_ul=250 gfbr_dl=120 gfbr_ul=120
    Update Cfg    set_qosrule id=1 proto=tcp qos_flow=2
    Update Cfg    set_qosrule id=2 proto=udp qos_flow=3
    Update Cfg    set_nwslice id=1 qos_flows=9,8,7,6,5,4,3,2,1 qos_rules=1,2 snssai=0x01:0xD143A5 default=on ue=1-30 amf=1
    Update Cfg    ue_nr_capabilities id=1-30 voice_over_nr=on:on:off
    Update Cfg    amf_param id=1 full_nas_auth=on ims_voice_3gpp=on nia=null+zuc nea=null+zuc
    Update Cfg    set_bearer id=2 ue=31 qci=5 pdn=1 ip=4.7.254.208 default=on trf_type=internal
    Update Cfg    set_bearer id=3 ue=31 qci=9 pdn=1 default=off preprovisioned=on filter=3 precedence=3
    Update Cfg    set_bearer id=4 ue=31 qci=7 pdn=1 default=off preprovisioned=on filter=4 precedence=4


Trigger RRC Reestablish with cause
    [Arguments]     ${ue_id}=1     ${cause}=reconfigurationFailure    ${pass_regexp}=${EMPTY}     ${fail_regexp}=${EMPTY}
    Start RRC Log    RRE_${ue_id}
    ${ret1}=    Execute Egate Command    ue_rrc_reestablish id=${ue_id} gnb=2 cell=1 cause=${cause}    pass_regexp=${pass_regexp}
    ...    fail_regexp=${fail_regexp}
    Get RRC Log

SA UE Register and PDU Session Setup with ics core network
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${ue_nr_capabilities}=${ue_nr_capabilities_06}    
    ...    ${target_cell}=1     ${pass_regexp}=${EMPTY}    ${fiveQi}=5
    Execute Egate Command    qosflow_modify default=on qos_flow=2
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${target_cell}
    ${set_ics_param}    catenate    amf_ue_ics_param id=1 core_network_assistance_info=on ue_identity_index_value=1 ue_specific_drx=64
    ...    periodic_registration_update_timer=1:10min plmn_id=311:489 tac_id=200
    Execute Egate Command    ${set_ics_param}
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu} trf_type=internal
    Execute Egate Command    ue_register id=${ue_id} ue_nr_capabilities=${ue_nr_capabilities_06}
    ...    Received REGISTRATION COMPLETE from UE
    SA UE PDU Session Setup    pdu=${pdu}    fiveQi=${fiveQi}    ue_id=${ue_id}    pass_regexp=${pass_regexp}
    Start traffic and Check Throughput




SA UE PDU Session Setup
    [Arguments]    ${pdu}=1    ${fiveQi}=5    ${ue_id}=1    ${pass_regexp}=${pass_regexp}
    Start RRC Log    PDU_Session_Setup_${ue_id}
    ${ret1}=    Execute Egate Command    ue_pdu_session_setup pdu=${pdu} ue=${ue_id} nwslice=1 gw=${ue_id}
    ...    pass_regexp=${pass_regexp}
    Should Contain    ${ret1}    Created FiveQi:Qfi mapping fiveQi ${fiveQi} qfi 1
    Get RRC Log

SA UE Register and PDU Session Setup
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${ue_nr_capabilities}=${ue_nr_capabilities_06}    
    ...    ${target_cell}=1     ${pass_regexp}=${EMPTY}    ${fiveQi}=5
    Execute Egate Command    qosflow_modify default=on qos_flow=2
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${target_cell}
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu} trf_type=internal
    Execute Egate Command    ue_register id=${ue_id} ue_nr_capabilities=${ue_nr_capabilities_06}
    ...    Received REGISTRATION COMPLETE from UE
    SA UE PDU Session Setup    pdu=${pdu}    fiveQi=${fiveQi}    ue_id=${ue_id}    pass_regexp=${pass_regexp}


Test Case Teardown
    Release UEs    ue_type=all
    OnlineParamChange    ${sCellAdditionMethod_cell1_covBasedA1}
    Common Test Teardown And Stop Capture Logs

UE PDU Session Modify to Add
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${fiveQi}=8    ${qfi}=2    ${qosflows}=9    ${pass_regexp}=${EMPTY}
    ...    ${fail_regexp}=${EMPTY}
    Start RRC Log    PDU_Session_Modify_to_Add_${ue_id}_${fiveQi}
    ${ret1}=    Execute Egate Command
    ...    ue_pdu_session_modify ue=${ue_id} pdu=${pdu} qosflows_to_add=${qosflows} by=amf
    ...    pass_regexp=${pass_regexp}    fail_regexp=${fail_regexp}
    Should Contain    ${ret1}    QosFlow with QFI:${qfi} 5QI:${fiveQi}                          
    Get RRC Log



Nsa ue register with QCI5
    [Arguments]    ${pass_regexp}    ${ue_id}=31
    Set x2 gnb link up
    Execute Egate Command    ue_attach id=${ue_id} profile=1    UE IS ACTIVE
    Execute Egate Command    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=1 bearer=2 type=split_scg    pass_regexp=${pass_regexp}
    Execute Egate Command    bearer_disp ue=31 at=ue


NSA add QCI9
    [Arguments]    ${ue_id}=31    ${pass_regexp}=${EMPTY}
    Execute Egate Command    enb_ue_dc_modify ue=${ue_id} bearer_to_add=3 by=enb cause=RN_CauseRadioNetwork_unspecified type=split_scg
    ...    pass_regexp=${pass_regexp}


NSA dorp QCI9
    [Arguments]    ${ue_id}=31    ${pass_regexp}=${EMPTY}
    Execute Egate Command    enb_ue_dc_modify ue=${ue_id} bearer_to_release=3 by=enb cause=MISC_CauseMisc_unspecified type=split_scg
    ...    pass_regexp=${pass_regexp}   


Set x2 gnb link up
    Execute Egate Command    enb_x2_link_up enb=1 target=2    ENB-1: X2AP Link with GNB-2


B001_teardown
    Delta Commission Parameters    ${CB009109_recovery_B001}
    Cells Should Be OnAir
    Test Case Teardown   



UE PDU Session Modify to Del
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${fiveQi}=1    ${qfi}=3    ${qosflows}=3    ${pass_regexp}=${EMPTY}
    ...    ${fail_regexp}=${EMPTY}
    Start RRC Log    PDU_Session_Modify_to_Del_${ue_id}_${fiveQi}
    ${ret1}=    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu} qosflows_to_del=${qosflows} by=amf
    ...    pass_regexp=${pass_regexp}    fail_regexp=${fail_regexp}
    Get RRC Log



Start traffic to trigger resume
   [Arguments]    ${ue_id}=1     
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=8 mbps=1    pass_regexp=${Resume_with_scell_regexp}
    Start traffic and Check Throughput    ue_id=${ue_id}
    
Start traffic and Check Throughput
    [Arguments]    ${ue_id}=1    ${cc_num}=2    ${dl}=0.9    ${ul}=0.9
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=1 mbps=1    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=ul trf_id=2 mbps=1    UE ${ue_id}: UDP UL
    Wait Until Keyword Succeeds    30s    3s    Verify SA DL and UL Traffic    
    
Stop traffic to Inactive
    [Arguments]    ${ue_id}=1
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=1 qfi=1 dir=ul
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=1 qfi=1 dir=dl    pass_regexp=${INACTIVE_check}    timeout=90s


Verify SA DL and UL Traffic
    [Arguments]    ${ue_id}=1    ${pdu_gw_id}=1
    builtin.sleep    10s
    ${ul_throuput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_gw_id}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${ul_throuput}/1000>0.9
    ${dl_throuput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_gw_id}    qfi=1    direction=dl    rate_type=ave
    Should Be True    ${dl_throuput}/1000>0.9



Test Case Teardown for B008
    Delta Commission Parameters    ${CB009109_recovery_B008}
    Cells Should Be OnAir
    Test Case Teardown
