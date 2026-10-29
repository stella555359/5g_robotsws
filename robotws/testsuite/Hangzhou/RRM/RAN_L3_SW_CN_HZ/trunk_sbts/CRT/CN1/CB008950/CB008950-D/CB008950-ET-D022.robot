*** Settings ***
Documentation
...    author: Zhou Lingyan
...    contact: lingyan.zhou@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_VRF    RAN_5G    SBTS00    team-CN1ET    owner-jia.pan
...    CLOUD_5G_I_BOO_AP_LOO    CRT    release-SBTS24R3
Resource    ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
${SYSCOM_FLAG}    ${True}
@{FAULTS_EXCLUDED_CHECKING}    4741

@{PARAMS_IN_SCF}
...    NRBTS-1:actIncXn=true
...    NRBTS-1:timerRRCGuard=6000
...    NRBTS-1:cipherPrefL:nea0=8
...    NRBTS-1:cipherPrefL:nea1_128=0
...    NRBTS-1:cipherPrefL:nea2_128=0
...    NRBTS-1:cipherPrefL:nea3_128=0
...    NRBTS-1:integrityProtPrefL:nia0=0
...    NRBTS-1:integrityProtPrefL:nia1_128=0
...    NRBTS-1:integrityProtPrefL:nia2_128=0
...    NRBTS-1:integrityProtPrefL:nia3_128=9
...    @{Mobility_related}
...    @{CA_related}
...    @{IRAT_related}
...    @{ANR_related}
...    @{IMME_CAaware}
...    @{chbw_related}
...    @{CB008225_CB006597}
...    @{732}
...    NRCELL-1:fPdcchMonOccsnPo=2
...    NRCELL-2:fPdcchMonOccsnPo=2
...    NRCELL-3:fPdcchMonOccsnPo=2
...    NRCELL-4:fPdcchMonOccsnPo=2
...    NRCELL-3:msg1FrequencyStart=0
...    NRCELL-4:msg1FrequencyStart=1
...    NRCELL:reportAmountA6MeasSCellSwap=r4

@{732}
...    NRBTS:rrcReestabTypeSA=sameGNB

@{CB008225_CB006597}
...    NRBTS:act3gppBL23R1=true
...    NRBTS:actRrcInactState=intra-gNB
...    NRBTS:actRrcReleasePreference=true
...    NRBTS:drbRrcInactInactivityTimerSA=20
...    NRBTS:maxUeRrcInactTime=60
...    NRBTS:outOfConnectedPreference=inactive
...    NRBTS:ranPagingCycle=v32
...    NRBTS:rrcInactIMMSteeringEnabled=false
...    NRBTS:rrcInactLocationReportEnabled=false
...    NRBTS:rrcInactPreferredStateEnabled=true
...    NRBTS:srbInactivityTimerSA=30
...    NRBTS:t380=5min
...    NRBTS:tRanPagingGuard=4
...    NRBTS:timerReleasePreferenceProhibit=s3

@{chbw_related}
...    NRCELL-11:gscnOrSsPbchArfcn=5288
...    NRCELL-11/NRCELL_FDD-1:chBwDl=15MHz
...    NRCELL-11/NRCELL_FDD-1:chBwUl=15MHz
...    NRCELL-11/NRCELL_FDD-1:nrarfcnDl=424000
...    NRCELL-11/NRCELL_FDD-1:nrarfcnUl=344000
...    NRCELL-11:type0CoresetConfigurationIndex=2
...    NRCELL-12:gscnOrSsPbchArfcn=5469
...    NRCELL-12/NRCELL_FDD-1:chBwDl=15MHz
...    NRCELL-12/NRCELL_FDD-1:chBwUl=15MHz
...    NRCELL-12/NRCELL_FDD-1:nrarfcnDl=438000
...    NRCELL-12/NRCELL_FDD-1:nrarfcnUl=354000
...    NRCELL-12:type0CoresetConfigurationIndex=7
...    NRBTS/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=0|dciFormat=formats0-0-And-1-0
...    NRBTS/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n5|dciFormat=formats0-1-And-1-1
...    NRBTS/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=8|dciFormat=formats0-1-And-1-1
...    NRBTS/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|dciFormat=formats0-1-And-1-1
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=0|dciFormat=formats0-0-And-1-0
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n5|dciFormat=formats0-1-And-1-1
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=8|dciFormat=formats0-1-And-1-1
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|dciFormat=formats0-1-And-1-1

@{Mobility_related}
...    NRBTS:actHoOptimizationCa=true
...    NRBTS:actInterFreqHoSA=true
...    NRBTS:actIntraFreqHoSA=true
...    NRBTS:actIntraNrNgHo=sourceAndTarget
...    NRBTS:suppCnPartialAdNgHo=true
...    NRBTS:tNgRelocCancelN=2000
...    NRBTS:tNgRelocExecDeltN=3000
...    NRBTS:tNgRelocOverallN=3000
...    NRBTS:tNgRelocPrepN=2000
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRCELL:measGapSelectionSA=favorFastMeasurements
...    NRBTS/NRPMRNL-1:miNrRelReportCu=5min
...    NRBTS/XNLINK-2:cPlaneIpAddr=10.0.1.122
...    NRCELL:a1MeashoEnabledSA=rsrp
...    NRCELL:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRCELL:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=60
...    NRCELL:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL:a2MeashoEnabledSA=rsrp
...    NRCELL:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0
...    NRCELL:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=40
...    NRCELL:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms480
...    @{NRADJGNB}
...    @{NRHOIF}
...    @{NRREL}

@{CA_related}
...    NRCELL:actK1Opt=intra-gNB
...    NRBTS/NRDU-1:actConnectedModeMobilityCA=true
...    NRBTS/NRDU-1:carrierAggregationSupportList=${CAlist}
...    NRCELL:a2MeasSCellRelEnabled=rsrp
...    NRCELL:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=480ms
...    NRCELL:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=50|a2TimeToTriggerSCellRelSsbRsrp=480ms
...    NRCELL:a1MeasSCellAddEnabled=rsrp
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=70
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=90
...    NRCELL-1:a2MeasPCellSwitchEnabled=rsrp
...    NRCELL-1:a2MeasPCellSwitchSsbRsrp:a2ThresholdPCellSwitchSsbRsrp=50
...    NRCELL-1:a1MeasPCellSwitchEnabled=rsrp
...    NRCELL-1:a1MeasPCellSwitchSsbRsrp:a1HysteresisPCellSwitchSsbRsrp=0
...    NRCELL-1:a1MeasPCellSwitchSsbRsrp:a1ThresholdPCellSwitchSsbRsrp=40
...    NRCELL-1:a1MeasPCellSwitchSsbRsrp:a1TimeToTriggerPCellSwitchSsbRsrp=80ms
...    NRCELL-11:increaseK1ULCA=K1 increased by 1 slot
...    NRCELL-12:increaseK1ULCA=K1 increased by 1 slot
...    NRCELL-13:increaseK1ULCA=K1 increased by 1 slot
...    NRCELL-14:increaseK1ULCA=K1 increased by 1 slot
...    NRCELL:maxNumScellsDlFr1=5
...    NRBTS:actBcsCheck=disabled
${CAlist}    ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Fr1Tdd_Sa_WithUl,ca_Fdd_Fdd,ca_Fdd_Fdd_Sa_WithUl,ca_Fdd_Any_Sa,ca_Fr1Tdd_Any_Sa,ca_Fr1Tdd_Fdd_Sa_WithUl,
...    ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Sa

@{NRADJGNB}
...    NRBTS/NRADJGNB-2:administrativeState=Unlocked
...    NRBTS/NRADJGNB-2:gNodeBId=35
...    NRBTS/NRADJGNB-2:xnLinkRef=2
...    NRBTS/NRADJGNB-2:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-2:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-2:gnbPlmn:mncLength=3
...    @{NRADJNRCELL}

@{NRADJNRCELL}
...    NRBTS/NRADJNRCELL-1:fiveGsTac=200
...    NRBTS/NRADJNRCELL-1:gNbId=36
...    NRBTS/NRADJNRCELL-1:nrarfcn=127420
...    NRBTS/NRADJNRCELL-1:physCellId=382
...    NRBTS/NRADJNRCELL-1:ssbFrequency=127210
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-1:freqBandIndicatorNR=66
...    NRBTS/NRADJNRCELL-2:fiveGsTac=200
...    NRBTS/NRADJNRCELL-2:gNbId=35
...    NRBTS/NRADJNRCELL-2:nrarfcn=513234
...    NRBTS/NRADJNRCELL-2:physCellId=381
...    NRBTS/NRADJNRCELL-2:ssbFrequency=513150
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-2:freqBandIndicatorNR=41

@{IRAT_related}
...    NRBTS:actInterRatHoSA=true
...    NRBTS:actInterRatHoFromEutraToSA=true
...    NRBTS:nonContentRachAcFullConfigHo=true
...    NRBTS:tNgRelocExecDeltL=5000
...    NRCELL:actCDrx=true
...    NRCELL-14:nrhoirDNList=MRBTS-1/NRBTS-1/NRHOIR-1
...    @{NRADJECELL}
...    @{NRRELE}
...    @{NRHOIR}

@{NRADJECELL}
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

@{NRRELE}
...    NRCELL-14/NRRELE-1:cellIndividualOffset=0dB
...    NRCELL-14/NRRELE-1:eNodeBId=18
...    NRCELL-14/NRRELE-1:eutranCellExcluded=false
...    NRCELL-14/NRRELE-1:lcrId=1
...    NRCELL-14/NRRELE-1:removeNotAllowed=false
...    NRCELL-14/NRRELE-1:ecgiPlmn:mcc=311
...    NRCELL-14/NRRELE-1:ecgiPlmn:mnc=489
...    NRCELL-14/NRRELE-1:ecgiPlmn:mncLength=3

@{NRHOIR}
...    NRBTS/NRHOIR-1:allowedMeasBandwidth=mbw100
...    NRBTS/NRHOIR-1:b2MeashoEnabled=rsrp
...    NRBTS/NRHOIR-1:b2Threshold1hoRsrp=35
...    NRBTS/NRHOIR-1:b2Threshold1hoRsrpVoNr=35
...    NRBTS/NRHOIR-1:b2Threshold1hoRsrq=50
...    NRBTS/NRHOIR-1:b2Threshold1hoRsrqVoNr=50
...    NRBTS/NRHOIR-1:eutraFreqQOffsetRange=0dB
...    NRBTS/NRHOIR-1:eutraB2MeashoRsrp:b2HysteresishoRsrpVoNr=0
...    NRBTS/NRHOIR-1:eutraB2MeashoRsrp:b2TimeToTriggerhoRsrpVoNr=ms480
...    NRBTS/NRHOIR-1:eutraB2MeashoRsrq:b2HysteresishoRsrqVoNr=0
...    NRBTS/NRHOIR-1:eutraB2MeashoRsrq:b2Threshold2hoRsrqVoNr=2
...    NRBTS/NRHOIR-1:eutraB2MeashoRsrq:b2TimeToTriggerhoRsrqVoNr=ms480

@{ANR_related}
...    NRBTS:actSaUeBasedAnrNr=true
...    NRBTS:actSaUeBasedInterFreqAnrNr=true
...    NRBTS:actDedicatedAnrDrxProfile=true
#remove since CB009109
#...    NRBTS/NRCELL-12:drxProfileNrAnr:drxControl=any
#...    NRBTS/NRCELL-12:drxProfileNrAnr:drxInactivityTimer=10ms
#...    NRBTS/NRCELL-12:drxProfileNrAnr:drxLongCycle=80ms
#...    NRBTS/NRCELL-12:drxProfileNrAnr:drxOnDurationTimer=20ms
#...    NRBTS/NRCELL-12:drxProfileNrAnr:drxRetransTimerDl=0slot
#...    NRBTS/NRCELL-12:drxProfileNrAnr:drxRetransTimerUl=0slot
...    NRCELL-1:actCDrx=true
#...    NRCELL-1:drxProfileNrAnr:drxLongCycle=320ms|drxControl=any

...    MRBTS-1/NRBTS-1/NRANR-1:actAutoEutraNbRemoval=false
...    MRBTS-1/NRBTS-1/NRANR-1:actAutoNrNbRemoval=true
...    MRBTS-1/NRBTS-1/NRANR-1:consecHoFailThres=3
...    MRBTS-1/NRBTS-1/NRANR-1:consecHoFailThresEutra=3
...    MRBTS-1/NRBTS-1/NRANR-1:consecXnResolveFailThres=3

...    MRBTS-1/NRBTS-1/NRANRPR-2:anrThresholdSelector=RSRP
...    MRBTS-1/NRBTS-1/NRANRPR-2:anrThresRsrpNbCell=-90
...    MRBTS-1/NRBTS-1/NRANRPR-2:anrThresRsrqNbCell=-12
...    MRBTS-1/NRBTS-1/NRANRPR-2:cellDepMode=SA
...    MRBTS-1/NRBTS-1/NRANRPR-2:consecRecheckForNrNbRemoval=5
...    MRBTS-1/NRBTS-1/NRANRPR-2:idleTimeForNrNbRemoval=72
...    MRBTS-1/NRBTS-1/NRANRPR-2:maxNumAnrNrrelAllowed=50
...    MRBTS-1/NRBTS-1/NRANRPR-2:nrAnrPrId=2
...    MRBTS-1/NRBTS-1/NRANRPR-2:nrarfcn=390000
...    MRBTS-1/NRBTS-1/NRANRPR-2:ssbFrequency=388830

@{IMME_CAaware}
...    NRBTS:actIdleMMSteering=true
...    NRBTS/NRCAIMP-1:pCellConfig:nrarfcnDl=424000
...    NRBTS/NRCAIMP-1/NRCAIMS-1:sCellConfig:nrarfcnDl=390000
...    NRCELL:idleMMSteeringAlgo=CA aware
...    NRCELL:idleMMSteeringPercentageOfUes=100
...    NRCELL:idleMMSteeringWRREnabled=false
...    NRCELL:idleMMSteeringWRREnabledSec=Disabled
...    NRCELL-13:cellReselectionPriority=2
...    NRCELL-13:cellReselectionSubPriority=oDot2
...    NRCELL-13:idleMMServCelResWeight=77
...    NRCELL-13:t320=min10
...    NRBTS/NRSYSINFO_PROFILE-12/NRIRFIM-1:cellReselectionPriority=4
...    NRBTS/NRSYSINFO_PROFILE-12/NRIRFIM-1:cellReselectionSubPriority=oDot2
...    NRBTS/NRSYSINFO_PROFILE-12/NRIRFIM-1:dlCarrierFreq=424000
...    NRBTS/NRSYSINFO_PROFILE-12/NRIRFIM-1:freqBandIndicatorNR=66
...    NRBTS/NRSYSINFO_PROFILE-12/NRIRFIM-1:idleMMNrCelResWeight=4
...    NRBTS/NRSYSINFO_PROFILE-12/NRIRFIM-1:numberOfTransmittedSsBlocks=1 beam
...    NRBTS/NRSYSINFO_PROFILE-12/NRIRFIM-1:qOffsetFreq=-4dB
...    NRBTS/NRSYSINFO_PROFILE-12/NRIRFIM-1:qRxLevMin=-56
...    NRBTS/NRSYSINFO_PROFILE-12/NRIRFIM-1:ssbScs=15KHz
...    NRBTS/NRSYSINFO_PROFILE-12/NRIRFIM-1:threshXHighQ=${EMPTY}
...    NRBTS/NRSYSINFO_PROFILE-12/NRIRFIM-1:threshXLowQ=${EMPTY}

@{NRHOIF}
...    NRCELL-1/NRHOIF-13:a3MeasEnabled=rsrp
...    NRCELL-1/NRHOIF-13:cellDepType=SA
...    NRCELL-1/NRHOIF-13:deriveSsbIndexFromCell=true
...    NRCELL-1/NRHOIF-13:freqBandIndicatorNR=25
...    NRCELL-1/NRHOIF-13:ifhoSsbSmtcDuration=sf1
...    NRCELL-1/NRHOIF-13:ifhoSsbSmtcPeriodicity=sf5
...    NRCELL-1/NRHOIF-13:ssbFrequency=388830
...    NRCELL-1/NRHOIF-13:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-1/NRHOIF-13:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL-1/NRHOIF-13:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms64
...    NRCELL-1/NRHOIF-13:a4MeasNrDcSsbRsrp:a4HysteresisNrDcSsbRsrp=0
...    NRCELL-1/NRHOIF-13:a4MeasNrDcSsbRsrq:a4HysteresisNrDcSsbRsrq=0
...    NRCELL-1/NRHOIF-13:a4MeasSCellAddSsbRsrp:a4HysteresisSCellAddSsbRsrp=0
...    NRCELL-1/NRHOIF-13:a4MeasSCellAddSsbRsrq:a4HysteresisSCellAddSsbRsrq=0
...    NRCELL-1/NRHOIF-13:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-1/NRHOIF-13:a4MeasSsbRsrq:a4HysteresisSsbRsrq=0

...    NRCELL-1/NRHOIF-14:a2BasedPCellSwitchEnabled=true
...    NRCELL-1/NRHOIF-14:a2BasedPCellSwitchPriority=1
...    NRCELL-1/NRHOIF-14:cellDepType=SA
...    NRCELL-1/NRHOIF-14:deriveSsbIndexFromCell=true
...    NRCELL-1/NRHOIF-14:freqBandIndicatorNR=25
...    NRCELL-1/NRHOIF-14:ifhoSsbSmtcDuration=sf1
...    NRCELL-1/NRHOIF-14:ifhoSsbSmtcPeriodicity=sf5
...    NRCELL-1/NRHOIF-14:ssbFrequency=391450
...    NRCELL-1/NRHOIF-14:thresholdPCellSwitchTargetRsrp=40
...    NRCELL-1/NRHOIF-14:thresholdPCellSwitchTargetRsrq=40
...    NRCELL-11/NRHOIF-34:a3MeasEnabled=rsrp
...    NRCELL-11/NRHOIF-34:cellDepType=SA
...    NRCELL-11/NRHOIF-34:deriveSsbIndexFromCell=true
...    NRCELL-11/NRHOIF-34:freqBandIndicatorNR=41
...    NRCELL-11/NRHOIF-34:ifhoSsbScs=30 KHz
...    NRCELL-11/NRHOIF-34:ifhoSsbSmtcDuration=sf1
...    NRCELL-11/NRHOIF-34:ifhoSsbSmtcPeriodicity=sf5
...    NRCELL-11/NRHOIF-34:ssbFrequency=513150
...    NRCELL-11/NRHOIF-34:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-11/NRHOIF-34:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL-11/NRHOIF-34:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms64
...    NRCELL-11/NRHOIF-34:a4MeasNrDcSsbRsrp:a4HysteresisNrDcSsbRsrp=0
...    NRCELL-11/NRHOIF-34:a4MeasNrDcSsbRsrq:a4HysteresisNrDcSsbRsrq=0
...    NRCELL-11/NRHOIF-34:a4MeasSCellAddSsbRsrp:a4HysteresisSCellAddSsbRsrp=0
...    NRCELL-11/NRHOIF-34:a4MeasSCellAddSsbRsrq:a4HysteresisSCellAddSsbRsrq=0
...    NRCELL-11/NRHOIF-34:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-11/NRHOIF-34:a4MeasSsbRsrq:a4HysteresisSsbRsrq=0
...    NRCELL-12/NRHOIF-1:a1BasedPCellSwitchEnabled=true
...    NRCELL-12/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-12/NRHOIF-1:cellDepType=SA
...    NRCELL-12/NRHOIF-1:deriveSsbIndexFromCell=true
...    NRCELL-12/NRHOIF-1:freqBandIndicatorNR=77
...    NRCELL-12/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-12/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-12/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-12/NRHOIF-1:ssbFrequency=633312
...    NRCELL-12/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-12/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL-12/NRHOIF-1:a4MeasNrDcSsbRsrp:a4HysteresisNrDcSsbRsrp=0
...    NRCELL-12/NRHOIF-1:a4MeasNrDcSsbRsrq:a4HysteresisNrDcSsbRsrq=0
...    NRCELL-12/NRHOIF-1:a4MeasSCellAddSsbRsrp:a4HysteresisSCellAddSsbRsrp=0
...    NRCELL-12/NRHOIF-1:a4MeasSCellAddSsbRsrq:a4HysteresisSCellAddSsbRsrq=0
...    NRCELL-12/NRHOIF-1:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-12/NRHOIF-1:a4MeasSsbRsrq:a4HysteresisSsbRsrq=0
...    NRCELL-12/NRHOIF-35:a3MeasEnabled=rsrp
...    NRCELL-12/NRHOIF-35:cellDepType=SA
...    NRCELL-12/NRHOIF-35:deriveSsbIndexFromCell=true
...    NRCELL-12/NRHOIF-35:freqBandIndicatorNR=71
...    NRCELL-12/NRHOIF-35:ifhoSsbSmtcDuration=sf1
...    NRCELL-12/NRHOIF-35:ifhoSsbSmtcPeriodicity=sf5
...    NRCELL-12/NRHOIF-35:ssbFrequency=127210
...    NRCELL-12/NRHOIF-35:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-12/NRHOIF-35:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL-12/NRHOIF-35:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms64
...    NRCELL-12/NRHOIF-35:a4MeasNrDcSsbRsrp:a4HysteresisNrDcSsbRsrp=0
...    NRCELL-12/NRHOIF-35:a4MeasNrDcSsbRsrq:a4HysteresisNrDcSsbRsrq=0
...    NRCELL-12/NRHOIF-35:a4MeasSCellAddSsbRsrp:a4HysteresisSCellAddSsbRsrp=0
...    NRCELL-12/NRHOIF-35:a4MeasSCellAddSsbRsrq:a4HysteresisSCellAddSsbRsrq=0
...    NRCELL-12/NRHOIF-35:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-12/NRHOIF-35:a4MeasSsbRsrq:a4HysteresisSsbRsrq=0

...    NRCELL-12/NRHOIF-13:a3MeasEnabled=rsrp
...    NRCELL-12/NRHOIF-13:cellDepType=SA
...    NRCELL-12/NRHOIF-13:deriveSsbIndexFromCell=true
...    NRCELL-12/NRHOIF-13:freqBandIndicatorNR=25
...    NRCELL-12/NRHOIF-13:ifhoSsbSmtcDuration=sf1
...    NRCELL-12/NRHOIF-13:ifhoSsbSmtcPeriodicity=sf5
...    NRCELL-12/NRHOIF-13:ssbFrequency=388830
...    NRCELL-12/NRHOIF-13:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-12/NRHOIF-13:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL-12/NRHOIF-13:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms64
...    NRCELL-12/NRHOIF-13:a4MeasNrDcSsbRsrp:a4HysteresisNrDcSsbRsrp=0
...    NRCELL-12/NRHOIF-13:a4MeasNrDcSsbRsrq:a4HysteresisNrDcSsbRsrq=0
...    NRCELL-12/NRHOIF-13:a4MeasSCellAddSsbRsrp:a4HysteresisSCellAddSsbRsrp=0
...    NRCELL-12/NRHOIF-13:a4MeasSCellAddSsbRsrq:a4HysteresisSCellAddSsbRsrq=0
...    NRCELL-12/NRHOIF-13:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-12/NRHOIF-13:a4MeasSsbRsrq:a4HysteresisSsbRsrq=0

@{NRREL}
...    NRCELL-3:nrarfcn=635400
...    NRCELL-3:gscnOrSsPbchArfcn=7840
...    NRBTS-1:actSCellSwapFr1=a6BasedSa
...    NRCELL:a6MeasSCellSwapEnabled=rsrp
...    NRCELL:a6MeasSCellSwapSsbRsrp:a6HysteresisSCellSwapSsbRsrp=0|a6OffsetSCellSwapSsbRsrp=6|a6TimeToTrigSCellSwapSsbRsrp=ms480
...    NRCELL:a6MeasSCellSwapSsbRsrq:a6HysteresisSCellSwapSsbRsrq=0|a6OffsetSCellSwapSsbRsrq=6|a6TimeToTrigSCellSwapSsbRsrq=ms480
...    NRCELL:reportAmountA6MeasSCellSwap=infinity
...    NRCELL:reportIntervalA6MeasSCellSwap=ms1024
...    NRCELL:thresholdSCellSwapSourceRsrp=56
...    NRCELL:thresholdSCellSwapSourceRsrq=66

...    NRCELL-1:increasePUSCHPrepTimeULCA=true
...    NRCELL-3:increasePUSCHPrepTimeULCA=true
...    NRCELL-14/NRREL-1:gNbId=1
...    NRCELL-14/NRREL-1:handoverAllowedSARedCap=allowed
...    NRCELL-14/NRREL-1:lcrId=1
...    NRCELL-14/NRREL-1:removeNotAllowed=true
...    NRCELL-14/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-14/NRREL-1:sCellOperationalMode=dlAndUl
...    NRCELL-14/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-14/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-14/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-14/NRREL-1:sCellPrio=2

...    NRCELL-14/NRREL-3:gNbId=1
...    NRCELL-14/NRREL-3:handoverAllowedSARedCap=allowed
...    NRCELL-14/NRREL-3:lcrId=3
...    NRCELL-14/NRREL-3:removeNotAllowed=true
...    NRCELL-14/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-14/NRREL-3:sCellOperationalMode=dlAndUl
...    NRCELL-14/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-14/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-14/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-14/NRREL-3:sCellPrio=3

...    NRCELL-14/NRREL-12:gNbId=1
...    NRCELL-14/NRREL-12:handoverAllowedSARedCap=allowed
...    NRCELL-14/NRREL-12:lcrId=12
...    NRCELL-14/NRREL-12:removeNotAllowed=true
...    NRCELL-14/NRREL-12:sCellAdditionMethod=covBasedA1
...    NRCELL-14/NRREL-12:sCellOperationalMode=dlAndUl
...    NRCELL-14/NRREL-12:gnbPlmn:mcc=311
...    NRCELL-14/NRREL-12:gnbPlmn:mnc=489
...    NRCELL-14/NRREL-12:gnbPlmn:mncLength=3

...    NRCELL-13/NRREL-12:gNbId=1
...    NRCELL-13/NRREL-12:handoverAllowedSARedCap=allowed
...    NRCELL-13/NRREL-12:lcrId=12
...    NRCELL-13/NRREL-12:removeNotAllowed=true
...    NRCELL-13/NRREL-12:sCellAdditionMethod=covBasedA1
...    NRCELL-13/NRREL-12:sCellOperationalMode=dlAndUl
...    NRCELL-13/NRREL-12:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-12:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-12:gnbPlmn:mncLength=3

...    NRCELL-13/NRREL-14:gNbId=1
...    NRCELL-13/NRREL-14:handoverAllowedSARedCap=allowed
...    NRCELL-13/NRREL-14:lcrId=14
...    NRCELL-13/NRREL-14:removeNotAllowed=true
...    NRCELL-13/NRREL-14:sCellAdditionMethod=covBasedA1
...    NRCELL-13/NRREL-14:sCellOperationalMode=dlOnly
...    NRCELL-13/NRREL-14:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-14:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-14:gnbPlmn:mncLength=3

...    NRCELL-12/NRREL-1:gNbId=1
...    NRCELL-12/NRREL-1:handoverAllowedSARedCap=allowed
...    NRCELL-12/NRREL-1:removeNotAllowed=true
...    NRCELL-12/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-12/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-1:gnbPlmn:mncLength=3

...    NRCELL-12/NRREL-11:gNbId=1
...    NRCELL-12/NRREL-11:handoverAllowedSARedCap=allowed
...    NRCELL-12/NRREL-11:lcrId=11
...    NRCELL-12/NRREL-11:removeNotAllowed=true
...    NRCELL-12/NRREL-11:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-11:sCellOperationalMode=dlOnly
...    NRCELL-12/NRREL-11:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-11:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-11:gnbPlmn:mncLength=3

...    NRCELL-12/NRREL-13:gNbId=1
...    NRCELL-12/NRREL-13:handoverAllowedSARedCap=allowed
...    NRCELL-12/NRREL-13:lcrId=14
...    NRCELL-12/NRREL-13:removeNotAllowed=true
...    NRCELL-12/NRREL-13:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-13:sCellOperationalMode=dlAndUl
...    NRCELL-12/NRREL-13:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-13:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-13:gnbPlmn:mncLength=3

...    NRCELL-12/NRREL-2:gNbId=1
...    NRCELL-12/NRREL-2:handoverAllowedSARedCap=allowed
...    NRCELL-12/NRREL-2:lcrId=2
...    NRCELL-12/NRREL-2:removeNotAllowed=true
...    NRCELL-12/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-12/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-35:gNbId=36
...    NRCELL-12/NRREL-35:handoverAllowedSARedCap=allowed
...    NRCELL-12/NRREL-35:removeNotAllowed=true
...    NRCELL-12/NRREL-35:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-35:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-35:gnbPlmn:mncLength=3

...    NRCELL-11/NRREL-12:gNbId=1
...    NRCELL-11/NRREL-12:handoverAllowedSARedCap=allowed
...    NRCELL-11/NRREL-12:lcrId=12
...    NRCELL-11/NRREL-12:removeNotAllowed=true
...    NRCELL-11/NRREL-12:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-12:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-12:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-12:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-12:gnbPlmn:mncLength=3

...    NRCELL-11/NRREL-13:gNbId=1
...    NRCELL-11/NRREL-13:handoverAllowedSARedCap=allowed
...    NRCELL-11/NRREL-13:lcrId=13
...    NRCELL-11/NRREL-13:removeNotAllowed=true
...    NRCELL-11/NRREL-13:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-13:sCellOperationalMode=dlAndUl
...    NRCELL-11/NRREL-13:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-13:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-13:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-34:gNbId=35
...    NRCELL-11/NRREL-34:handoverAllowedSARedCap=allowed
...    NRCELL-11/NRREL-34:removeNotAllowed=true
...    NRCELL-11/NRREL-34:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-34:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-34:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-12:gNbId=1
...    NRCELL-1/NRREL-12:handoverAllowedSARedCap=allowed
...    NRCELL-1/NRREL-12:lcrId=12
...    NRCELL-1/NRREL-12:removeNotAllowed=true
...    NRCELL-1/NRREL-12:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-12:sCellOperationalMode=dlAndUl
...    NRCELL-1/NRREL-12:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-12:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-12:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-14:gNbId=1
...    NRCELL-1/NRREL-14:handoverAllowedSARedCap=allowed
...    NRCELL-1/NRREL-14:lcrId=14
...    NRCELL-1/NRREL-14:removeNotAllowed=true
...    NRCELL-1/NRREL-14:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-14:sCellOperationalMode=dlAndUl
...    NRCELL-1/NRREL-14:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-14:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-14:gnbPlmn:mncLength=3

@{OnlineParamChange_RemoveANRMO}
...    delete:NRCELL-1/NRREL-256
...    delete:NRCELL-12/NRREL-256

@{OnlineParamChange_A4}
...    NRBTS:actHoOptimizationCa=false
...    NRBTS:actBufferBasedSCellAddition=oneShot_Dl_Fr1
...    NRCELL:a4PeriodicMeasControlSA:a4Fr1SupervisionTimer=6000
...    NRCELL:a4PeriodicMeasControlSA:a4Fr2SupervisionTimer=6000
...    NRCELL:a4PeriodicMeasControlSA:a4MeasMaxNumber=8
...    NRCELL:a4PeriodicMeasControlSA:a4RetryTimer=5
...    NRCELL:dlSCellConfigLevel=1
...    NRCELL:dlSCellConfigLevelNum=1
...    NRBTS:actMeasBasedSCellAdditionSa=A4-based
...    NRCELL-1/NRREL-14:sCellAdditionMethod=covBasedA4
...    delete:NRCELL-1/NRREL-12
...    delete:NRCELL-1/NRHOIF-13
...    NRCELL-14/NRREL-1:sCellAdditionMethod=covBasedA4
...    NRCELL-14/NRREL-3:sCellAdditionMethod=covBasedA4
...    NRCELL-14/NRREL-12:sCellAdditionMethod=covBasedA4
...    NRCELL-13/NRREL-12:sCellAdditionMethod=covBasedA4
...    NRCELL-13/NRREL-14:sCellAdditionMethod=covBasedA4
...    NRCELL-12/NRREL-1:sCellAdditionMethod=covBasedA4
...    NRCELL-12/NRREL-11:sCellAdditionMethod=covBasedA4
...    NRCELL-12/NRREL-13:sCellAdditionMethod=covBasedA4
...    NRCELL-12/NRREL-2:sCellAdditionMethod=covBasedA4

...    NRCELL-1/NRHOIF-14:a4MeasSCellAddEnabled=rsrp
...    NRCELL-1/NRHOIF-14:a4MeasSCellAddSsbRsrp:a4HysteresisSCellAddSsbRsrp=0
...    NRCELL-1/NRHOIF-14:a4MeasSCellAddSsbRsrp:a4ThresholdSCellAddSsbRsrp=40
...    NRCELL-1/NRHOIF-14:a4MeasSCellAddSsbRsrp:a4TimeToTriggerSCellAddSsbRsrp=ms0

...    NRCELL-1/NRHOIF-14:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-1/NRHOIF-14:a4MeasSsbRsrp:a4ThresholdSsbRsrp=34
...    NRCELL-1/NRHOIF-14:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms0

@{OnlineParamChange_A4_RE}
...    NRBTS:actHoOptimizationCa=true
...    NRBTS:actBufferBasedSCellAddition=disabled
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    delete:NRCELL:a4PeriodicMeasControlSA

...    NRCELL-1/NRREL-12:gNbId=1
...    NRCELL-1/NRREL-12:handoverAllowedSARedCap=allowed
...    NRCELL-1/NRREL-12:lcrId=12
...    NRCELL-1/NRREL-12:removeNotAllowed=true
...    NRCELL-1/NRREL-12:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-12:sCellOperationalMode=dlAndUl
...    NRCELL-1/NRREL-12:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-12:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-12:gnbPlmn:mncLength=3

...    NRCELL-1/NRREL-14:sCellAdditionMethod=covBasedA1
...    NRCELL-14/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-14/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-14/NRREL-12:sCellAdditionMethod=covBasedA1
...    NRCELL-13/NRREL-12:sCellAdditionMethod=covBasedA1
...    NRCELL-13/NRREL-14:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-11:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-13:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-2:sCellAdditionMethod=covBasedA1

...    NRCELL-1/NRHOIF-13:a3MeasEnabled=rsrp
...    NRCELL-1/NRHOIF-13:cellDepType=SA
...    NRCELL-1/NRHOIF-13:deriveSsbIndexFromCell=true
...    NRCELL-1/NRHOIF-13:freqBandIndicatorNR=25
...    NRCELL-1/NRHOIF-13:ifhoSsbSmtcDuration=sf1
...    NRCELL-1/NRHOIF-13:ifhoSsbSmtcPeriodicity=sf5
...    NRCELL-1/NRHOIF-13:ssbFrequency=388830
...    NRCELL-1/NRHOIF-13:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-1/NRHOIF-13:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL-1/NRHOIF-13:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms64
...    NRCELL-1/NRHOIF-13:a4MeasNrDcSsbRsrp:a4HysteresisNrDcSsbRsrp=0
...    NRCELL-1/NRHOIF-13:a4MeasNrDcSsbRsrq:a4HysteresisNrDcSsbRsrq=0
...    NRCELL-1/NRHOIF-13:a4MeasSCellAddSsbRsrp:a4HysteresisSCellAddSsbRsrp=0
...    NRCELL-1/NRHOIF-13:a4MeasSCellAddSsbRsrq:a4HysteresisSCellAddSsbRsrq=0
...    NRCELL-1/NRHOIF-13:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-1/NRHOIF-13:a4MeasSsbRsrq:a4HysteresisSsbRsrq=0

@{resum_success_cell12}
...    rrcResumeRequest1
...    resumeCause mo-Data
...    rrcResumeComplete
...    pcid:61, scellIdx:0

@{Check_TriggerA2HO}
...    eventId eventA1
...    eventId eventA3
...    gapFR1 setup
...    drx-Config release
...    rrcReconfigurationComplete

@{cell12_HO_cell13}
...    gapFR1 release
...    drx-Config setup
...    pcid:61, scellIdx:1
...    pcid:62, scellIdx:0
...    Intra-eNB handover from EXT_ENB-2.12 to EXT_ENB-2.13 performed
...    rrcReconfigurationComplete

@{cell1_HO_cell13}
...    pcid:61, scellIdx:1
...    pcid:62, scellIdx:0
...    Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.13 performed
...    rrcReconfigurationComplete

@{CA_cell12_cell11_cell14_cell1_cell2}
...    pcid:50, scellIdx:1
...    pcid:51, scellIdx:2
...    pcid:60, scellIdx:3
...    pcid:63, scellIdx:4
...    pcid:61, scellIdx:0
...    rrcReconfigurationComplete

@{CA_cell12_cell11_cell14}
...    pcid:60, scellIdx:1
...    pcid:63, scellIdx:2
...    pcid:61, scellIdx:0
...    rrcReconfigurationComplete

@{pcell_change_cell14}
...    drx-Config setup
...    eventId eventA2
...    pcid:61, scellIdx:1
...    pcid:63, scellIdx:0
...    Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.14 performed
...    rrcReconfigurationComplete

@{A1PCELLCHANGE}
...    pcid:63, scellIdx:2
...    pcid:61, scellIdx:1
...    pcid:50, scellIdx:0
...    rrcReconfigurationComplete

@{INACTIVE_check}
...    SuspendConfig
...    fullI_RNTI
...    shortI_RNTI
...    ran-AreaCodeList
...    t380
...    UE81: Is INACTIVE

@{RRE_to_cell1}
...    rrcReestablishmentComplete
...    pcid:50, scellIdx:0
...    rrcReconfigurationComplete

@{RRE_to_cell12}
...    rrcReestablishmentComplete
...    pcid:61, scellIdx:0
...    rrcReconfigurationComplete

@{PM_Counters_Check}
...    NRCELL-12:${GNB_SCELL_4_ADMI_REQ_SA}=2
...    NRCELL-12:${GNB_SCELL_4_ADMI_SUCC_SA}=2
...    NRCELL-12:${UE_PCELL_4_CONF_SCELL_DL_SA}>0
...    NRCELL-11:${UE_SCELL_4_CONF_SCELL_DL_SA}>0
...    NRCELL-14:${UE_SCELL_4_CONF_SCELL_DL_SA}>0
...    NRCELL-1:${UE_SCELL_4_CONF_SCELL_DL_SA}>0
...    NRCELL-2:${UE_SCELL_4_CONF_SCELL_DL_SA}>0
...    NRCELL-12:${GNB_DU_SCELL_4_ADMI_REQ_SA}=2
...    NRCELL-12:${GNB_DU_SCELL_4_ADMI_SUCC_SA}=2
...    NRCELL-12:${RRC_RECONF_ADD4DLSCELL_ATT_SA}=2
...    NRCELL-12:${RRC_RECONF_ADD4DLSCELL_SUCC_SA}=2

...    NRCELL-12:${NRRCC_RRC_REL_WITH_SUSP_NRNAU}=1
...    NRCELL-12:${NRRCC_RRC_RESUME_REQUEST1}=1
...    NRCELL-12:${NRRCC_RRC_RESUME_SUCC}=1

#...    NRCELL-14:${SCELL_SWAP_1_ATT_SA}=1
#...    NRCELL-14:${SCELL_SWAP_1_SUCC_SA}=1

...    NRCELL-14:${SCELL_CHANGE_ATT_SA}=1
...    NRCELL-14:${SCELL_CHANGE_SUCC_SA}=1

...    NRDU-1:${RRC_REESTAB_RECONF_FAILURE_DU}=2
...    NRDU-1:${REESTAB_ACC_RECONF_FAIL_DU}=2
...    NRCELL-1:${RRC_REESTAB_RECONF_FAILURE}=1
...    NRCELL-1:${REESTAB_ACC_RECONF_FAIL}=1
...    NRCELL-12:${RRC_REESTAB_RECONF_FAILURE}=1
...    NRCELL-12:${REESTAB_ACC_RECONF_FAIL}=1
...    NRCELL-1:${ATT_A2_IF_INTRA_DU_HO_SA_PLMN}=1
...    NRCELL-12:${ATT_A2_IF_INTRA_DU_HO_SA_PLMN}=0
...    NRCELL-13:${ATT_A2_IF_INTRA_DU_HO_SA_PLMN}=0
...    NRCELL-1:${SUCC_A2_IF_INTRA_DU_HO_SA_PLMN}=1
...    NRCELL-12:${SUCC_A2_IF_INTRA_DU_HO_SA_PLMN}=0
...    NRCELL-13:${SUCC_A2_IF_INTRA_DU_HO_SA_PLMN}=0
#...    NRCELL-1:${ATT_IF_INTRA_DU_HO_SA_PLMN}=1
#...    NRCELL-1:${SUCC_IF_INTRA_DU_HO_SA_PLMN}=1
...    NRCELL-12:${ATT_IF_INTRA_DU_HO_SA_PLMN}=1
...    NRCELL-12:${SUCC_IF_INTRA_DU_HO_SA_PLMN}=1
...    NRCELL-1:${NMOCU_ANR_NRREL_ADD}=1
...    NRCELL-12:${NMOCU_ANR_NRREL_ADD}=1
...    NRCELL-1:${TOT_INTER_FREQ_HO_DECISION_A3}=1
...    NRCELL-12:${TOT_INTER_FREQ_HO_DECISION_A3}=1

@{PM_Counters_Check_phase2}
...    NRCELL-1:${A4_MEASUR_ACT_SCELL_ADD_SA}=1
...    NRCELL-1:${A4_SCELL_ADDED_SA}=1

${GNB_SCELL_4_ADMI_REQ_SA}    M55138C00048
#GNB_SCELL_4_ADMI_REQ_SA    This counter describes the number of radio admission requests for exactly 4 SCells before the
#CA configuration on RRC.
${GNB_SCELL_4_ADMI_SUCC_SA}    M55138C00049
#GNB_SCELL_4_ADMI_SUCC_SA    This counter describes the number of successful radio admission requests for exactly 4 SCells
#before the CA configuration on RRC
${UE_PCELL_4_CONF_SCELL_DL_SA}    M55118C02016
#UE_PCELL_4_CONF_SCELL_DL_SA    The total number of CA UEs in the current cell configured as a PCell that have exactly 4
#configured SCells in DL in SA mode
${UE_SCELL_4_CONF_SCELL_DL_SA}    M55118C07510
#UE_SCELL_4_CONF_SCELL_DL_SA    The sum of samples for the total number of CA UEs in the current cell configured as an
#SCell while pegged in the secondary cell that has four configured SCells in DL in SA mode.
${GNB_DU_SCELL_4_ADMI_REQ_SA}    M55139C00023
#GNB_DU_SCELL_4_ADMI_REQ_SA    This counter describes the number of radio admission requests for exactly 4 SCells before
#the CA configuration on RRC.
${GNB_DU_SCELL_4_ADMI_SUCC_SA}    M55139C00024
#GNB_DU_SCELL_4_ADMI_SUCC_SA    This counter describes the number of successful radio admission requests for exactly 4
#SCells before the CA configuration on RRC
${RRC_RECONF_ADD4DLSCELL_ATT_SA}    M55118C02015
#RRC_RECONF_ADD4DLSCELL_ATT_SA    This counter indicates the total number of RRC Reconfiguration attempts for 4 SCells
#Addition in DL for SA mode
${RRC_RECONF_ADD4DLSCELL_SUCC_SA}    M55118C02014
#RRC_RECONF_ADD4DLSCELL_SUCC_SA    This counter indicates the total number of successful RRC Reconfiguration attempts for
#4 SCells Addition in DL for SA mode.

${NRRCC_RRC_REL_WITH_SUSP_NRNAU}    M55124C00006    #This counter provides the total number of RRC releases with suspendConfig IE sent
#from the gNB-CU
${NRRCC_RRC_RESUME_REQUEST1}    M55124C00007    #This counter provides the total number of RRCResumeRequests1 received at the gNB-CU.
${NRRCC_RRC_RESUME_SUCC}    M55124C00010    #Number of RRC Resume Successes at gNB-CU

${SCELL_SWAP_1_ATT_SA}    M55118C10501
#The total number of SCell swap attempts for 1 SCell in the PCell for SA mode.
${SCELL_SWAP_1_SUCC_SA}    M55118C10502
#The total number of successful SCell swap attempts for 1 SCell in the PCell for SA mode.

${SCELL_CHANGE_ATT_SA}    M55118C06506
#The total number of RRC Reconfiguration Request messages changing SCell(s) in SA mode.
${SCELL_CHANGE_SUCC_SA}    M55118C06507
#The total number of successful RRC Reconfiguration Changing current SCell(s) in SA mode.

${RRC_REESTAB_RECONF_FAILURE_DU}    M55127C00501
#Number of RRC Re-establishment Request caused by reconfiguration failure

${RRC_REESTAB_RECONF_FAILURE}       M55124C00503
#Number of RRC Re-establishment Request caused by reconfiguration failure

${REESTAB_ACC_RECONF_FAIL_DU}       M55127C00510
#Number of accepted RRC Re-establishment when reestablishment cause is reconfiguration failure

${REESTAB_ACC_RECONF_FAIL}          M55124C00510
#Number of accepted RRC Re-establishment when reestablishment cause is reconfiguration failure

${A4_MEASUR_ACT_SCELL_ADD_SA}    M55118C00030
#This counter shows the number of A4 measurement activations for FR1 CA SCell Addition in SA mode.
${A4_SCELL_ADDED_SA}    M55118C00031
#This counter shows the number of SCells added as A4-based SCells during FR1 CA SCell Addition.
${TOT_INTER_FREQ_HO_DECISION_A3}    M55147C00024    #Total number of inter-frequency handover decisions due to A3 measurement report

${NMOCU_ANR_NRREL_ADD}    M55147C01001    #Number of neighbor relations added by ANR for NRCELL

${ATT_A2_IF_INTRA_DU_HO_SA_PLMN}    M55145C03001
#The number of A2 based inter-frequency intra-DU HO execution attempts for SA per PLMN-ID.
#This is a PCell switch (inter-frequency handover to configured SCell based on A2 measurement on the PCell.
${SUCC_A2_IF_INTRA_DU_HO_SA_PLMN}    M55145C03002
#The number of successful A2 based inter-frequency intra-DU HO executions for SA per PLMN-ID.
#This is a PCell switch (inter-frequency handover to configured SCell based on A2 measurement on the PCell.

${ATT_IF_INTRA_DU_HO_SA_PLMN}    M55145C00321
#The number of inter-frequency intra-DU HO execution attempts for SA per PLMN-ID

${SUCC_IF_INTRA_DU_HO_SA_PLMN}    M55145C00322
#The number of successful inter-frequency intra-DU HO executions for SA per PLMN-ID

#5CC: n71A-2N66A-N25A-2N78A, support lch-ToScellRestriction
${FF_ULCA_Support_AB05}    SEPARATOR=
...    FFA0F20047C5F7A6B5F83820D600006800BB802002024107CC0202481B0018FFFC000A07C0A00C0701AA1F851BF30342A08A596544130017
...    BFF3039036FFFB7FFDBFFEDFFF6FFFB7FFDBFFE7FFFA7FFDF1F9F87FC7FFB7FFDBFFEDFFF6FFFB7FFDBFFEDFFF51804DFE7FEDFE7FE41400
...    0028015B300078003300078000150FC41DF981A150452CB2A209800BDFF981C81B7FFDBFFEDFFF6FFFB7FFDBFFEDFFF3FFFD3FFEF8FCFC3F
...    E3FFDBFFEDFFF6FFFB7FFDBFFEDFFF6FFFA8C026FF3FF6FF3FF20A00001400AD98003C00198003C0000A87E26EFCC0D0A82296595104C005
...    EFFCC0E40DBFFEDFFF6FFFB7FFDBFFEDFFF6FFF9FFFE9FFF7C7E7E1FF1FFEDFFF6FFFB7FFDBFFEDFFF6FFFB7FFD460137F9FFB7F9FF90500
...    000A0056CC001E000CC001E0000543F1337E606854114B2CA8826002F7FE607206DFFF6FFFB7FFDBFFEDFFF6FFFB7FFCFFFF4FFFBE3F3F0F
...    F8FFF6FFFB7FFDBFFEDFFF6FFFB7FFDBFFEA3009BFCFFDBFCFFC82800005002B66000F00066000F00002A0F831BF30342A08A59654413001
...    7BFF3039036FFFB7FFDBFFEDFFF6FFFB7FFDBFFE7FFFA7FFDF1F9F87FC7FFB7FFDBFFEDFFF6FFFB7FFDBFFEDFFF51804DFE7FEDFE7FE4140
...    00028015B3000780033000780001507C46DF981A150452CB2A209800B5FF981C81B7FFDBFFEDFFF6FFFB7FFDBFFEDFFF3FFFD3FFEF8FCFC3
...    FE3FFBBFFEDFFF6FFFB7FFDBFFEDFFF518026FF3FF6FF3FF20A00001400AD98003C00198003C0000A816806F1C610D00151E7E28980045ED
...    98AA9001E3C0087104184540A3F7A2049082000006000D45E268007134003850001C41000E2080071180000015BF0000000020713400000F
...    F0000000145E0C0007104003882001C46000E2600071340000115BF0000000000A00C404D808C4E800004A03813F03FD7B7027E07FAF6E04
...    FC0FF5ED800E06318FF7FFFFE2B8000F800F000C0705807800703F09801E001806BB82C02C00380D77058058007020010000000800400000
...    0DE00C88000001644000002A00B066F2A68064F000029659427800054B2CA1200004A5965490000352CB2A01A8345D2A8AA557541AE80450
...    1004008040100201004008040080101002004040080100080200650100200404008010100200404008010100400804010021AA2000010203
...    040506070A0B0C0D101112131418191B1C1D1F2125262728292A2D2F414142D0

${ue_id}    81
${pdu_id}    1
${gw_id}    1
${nwslice}    1


*** Test Cases ***
CB008950-ET-D022-FR1_SA_CA_RRE_PcellChange_ScellChange_ScellSwap_ANR_A4ScellAdd_RrcInactive_Rrcresume
    [Documentation]
    ...    1. The purpose of this test case is to verify CA RRE PcellChange ScellChange ScellSwap ANR A4ScellAdd
    ...     RrcInactive and Rrcresume.
    ...    2. Test Case Steps:
    ...         a. UE attach to cell-12(n66), start proper UL/DL data.
    ...         b. Trigger UE inactive and resume, trigger A1 to add CA.
    ...         c. Trigger scellrelease 66(cell11)
    ...         d. Trigger scellrelease 78(cell2)
    ...         e. Trigger A1pcellchange to 78(cell1)
    ...         f. Trigger A2pcellchange to 25(cell14)[U]
    ...         g. Trigger A1scellchange to 78(cell1)[U]
    ...         h. Trigger A6scellswap to 78(cell3)[U]
    ...         i. trigger RRE to cell12, then trigger scell addation.
    ...         j. ANR HO to cell13, scell auto added.
    ...         k. trigger RRE to cell1
    ...         l. ANR HO to cell13, scell auto added.
    ...         m. UE deregister then attach to cell1 and trigger A4 to add scell.
    ...    3. Expect result:
    ...        a. scell addation successful, 5CC is setup 66(cell12)_66(cell11)_25(cell14)[U]_78(cell1)_78(cell2)
    ...        b. UE inactive and resume successful, CA is setup 66(cell12)_66(cell11)_25(cell14)[U]_78(cell1)_78(cell2)
    ...        c. scell release successfully, 4CC is setup 66(cell12)_25(cell14)[U]_78(cell1)_78(cell2)
    ...        d. scell release successfully, 3CC is setup 66(cell12)_25(cell14)[U]_78(cell1)
    ...        e. a1pcellchange successfully, 3CC is setup 78(cell1)_66(cell12)[U]_25(cell14)
    ...        f. a2pcellchange successfully, 2CC is setup 25(cell14)[U]_66(cell12)[U]
    ...        g. a1scellchange successfully, 2CC is setup 25(cell14)[U]_78(cell1)[U]
    ...        h. A6scellswap successfully, 2CC is setup 25(cell14)[U]_78(cell3)[U]
    ...        i. RRE to cell12successful, and CA:66(cell12)_66(cell11)_25(cell14)[U] added successfully.
    ...        j. ANR HO to cell13, 25(cell13)_66(cell12) added successful.
    ...        k. RRE to cell1 successful successfully.
    ...        l. ANR HO to cell13, 25(cell13)_66(cell12) added successful.
    ...        m. CA 78(cell1)_25(cell14) is setup.
    [Tags]    CIT    QC_46935
    Clear Counter Files    ${True}
    Setup 5CC CA trigger UE inactive and resume
    5CC release to 3CC trigger A1 pcellchange and A2 pcellchange
    Trigger scellchange and scellswap
    RRE and ANR
    A4 scell add
    Check Counters    ${PM_Counters_Check}
    Check Counters    ${PM_Counters_Check_phase2}
    [Teardown]    CIT_Teardown

*** Keywords ***
Modify Cfg
    Update Cfg    gnb_endc_param id=4 use_nr_ran_cont=true
    Update Cfg    gnb_endc_param id=4 scg_dl_dist_percent=0
    Update Cfg    gnb_endc_param id=4 enable_dud_poll_bit=0
    Update Cfg    gnb_param id=3 xn_listening_socket=on send_xn_setup=true measEvent=A2 measEvent=A3
    Update Cfg    gnb_param id=4 sa_ho=ng_based measEvent=A2 measEvent=A3
    ${set_gnb4}    catenate    set_cell id=1 gnb=4 pci=127:1 tac=200 nrci=0x01 tdd_cell=off proxy=10.0.2.90:9999
    ...    nr_arfcn=136360:127420 gscn=1589 mandatory_for_activation=off
    Update Cfg    ${set_gnb4}
    ${set_gnb5}    catenate    set_gnb id=5 type=simulated plmn=311:489 ng=10.0.1.15 daemon=10.0.2.1:22222 gnb_id=0x12:28
    ...    nssai=0x01:0xD143A5
    Update Cfg    ${set_gnb5}
    ${set_gnb5_cell1}    catenate    set_cell id=1 gnb=5 pci=3:2 earfcn=1:18001 tac=0 proxy=10.0.2.92:12218 nrci=0x1
    ...    tdd_cell=on bw=20MHz technology=lte
    Update Cfg    ${set_gnb5_cell1}
    Update Cfg    gnb_param id=5 xn_listening_socket=true

Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/8cells_4T4F_2N25_2N66_3N78_N38

5CC release to 3CC trigger A1 pcellchange and A2 pcellchange
    Trigger scellrelease
    Wait Until Keyword Succeeds    60s    10s    Verify Throughput    Tput_dl=250    Tput_ul=50
    Trigger scellrelease    carrierfreq=648096    scell_index=2
    Wait Until Keyword Succeeds    60s    10s    Verify Throughput    Tput_dl=200    Tput_ul=50
    Trigger A1 or A2 PCell Change    event_type=A1    ue_id=81    scell_id=1    pass_check=${A1PCELLCHANGE}    threshold=40
    Wait Until Keyword Succeeds    60s    10s    Verify Throughput    Tput_dl=200    Tput_ul=38
    Trigger A1 or A2 PCell Change    event_type=A2    scell_rsrp=80    scell_rsrq=80    ue_id=81    scell_id=2
    Wait Until Keyword Succeeds    60s    10s    Verify Throughput    Tput_dl=120    Tput_ul=38

Trigger scellchange and scellswap
    Trigger A1MR scellchange
    Wait Until Keyword Succeeds    60s    10s    Verify Throughput    Tput_dl=200    Tput_ul=38
#    Trigger ScellSwap
#    Wait Until Keyword Succeeds    60s    10s    Verify Throughput    Tput_dl=200    Tput_ul=38

A4 scell add
    Execute Egate Command    ue_deregister id=81 ue_deregister_type=switch_off    pass_regexp=detached
    OnlineParamChange    ${OnlineParamChange_A4}
    OnlineParamChange    ${OnlineParamChange_RemoveANRMO}
    UE Attach To Target Cell    ue_id=81    cell_id=1
    Send Throughput    times=6
    Send Single A4 MR to Trigger A4    63
    Wait Until Keyword Succeeds    60s    10s    Verify Throughput    Tput_dl=200    Tput_ul=38

RRE and ANR
    RRE to cell12 and trigger scell added
    ANR HO    carrier_source=437550    carrier_target=388830    ue_id=81
    ...    A2_pass_regrxp=${Check_TriggerA2HO}    A3_pass_regrxp=${cell12_HO_cell13}
    RRE to cell1
    ANR HO    carrier_source=633312    carrier_target=388830    ue_id=81
    ...    A2_pass_regrxp=${Check_TriggerA2HO}    A3_pass_regrxp=${cell1_HO_cell13}

CIT_Teardown
    OnlineParamChange    ${OnlineParamChange_A4_RE}
    Common Test Teardown And Stop Capture Logs

Update UE capa
    [Arguments]    ${SA_Capa_perUE_Full}=none    ${ue_id}=81
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full}
    Execute Egate Command    ${cmd}

Send Single A4 MR to Trigger A4
    [Arguments]    ${phycell_id}
#    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=81    carrierfreq=391450    event_type=A4
#    ${cmd}    catenate    ue_measurement_send_nr event=A4 phycell_id=${phycell_id} nrsrp_nr=80 nrsrq_nr=80 id=81 meas_id=${meas_id}
    ${cmd}    catenate    ue_schedule_measurement_send_nr id=81 action=SEND_IMMEDIATELY periodicity=100 delay=10
    ...    meas_id=1 event=A4 phycell_id=${phycell_id} nrsrp_nr=80 nrsrq_nr=80
    Execute Egate Command    ${cmd}    pcid:63

Trigger ScellSwap
    [Arguments]    ${event_type}=A6    ${carrierfreq}=633312    ${nrsrp_nr}=63    ${nrsrq_nr}=20    ${ue_id}=81    ${scell_id}=2
    ...    ${phycell_id}=52
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type}
    ...    srsrp_nr=11 srsrq_nr=11 scell=${scell_id} scell_rsrp=20 scell_rsrq=20 phycell_id=${phycell_id} nrsrp_nr=${nrsrp_nr} nrsrq_nr=${nrsrq_nr}
    Execute Egate Command    ${cmd}    pass_regexp=rrcReconfigurationComplete

Trigger scellrelease
    [Arguments]    ${event_type}=A2    ${carrierfreq}=423130    ${scell_index}=3    ${ue_id}=81    ${scell_rsrp}=10
    ...    ${scell_rsrq}=61    ${threshold}=50
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}    threshold=${threshold}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} event=${event_type} meas_id=${meas_id} srsrp_nr=50 srsrq_nr=50
    ...    scell=${scell_index} scell_rsrp=${scell_rsrp} scell_rsrq=${scell_rsrq}
    Execute Egate Command    ${cmd}    pass_regexp=rrcReconfigurationComplete

Trigger A1MR scellchange
    [Arguments]    ${event_type}=A1    ${carrierfreq}=391450    ${srsrp_nr}=100    ${srsrq_nr}=100    ${ue_id}=81
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type}
    ...    srsrp_nr=${srsrp_nr} srsrq_nr=${srsrq_nr}
    Execute Egate Command    ${cmd}    pass_regexp=rrcReconfigurationComplete

UE Attach To Target Cell
    [Arguments]    ${ue_id}    ${cell_id}
    Update UE capa    ${FF_ULCA_Support_AB05}    ${ue_id}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    ${core_assis_info}    catenate    amf_ue_ics_param id=1 core_network_assistance_info=on ue_identity_index_value=${ue_id} ue_specific_drx=64
    ...    periodic_registration_update_timer=1:10min plmn_id=311:489 tac_id=200
    Execute Egate Command    ${core_assis_info}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=${gw_id} nwslice=${nwslice}
    ...    pass_regexp=rrcReconfigurationComplete

Send Throughput
    [Arguments]    ${ue_id}=81    ${times}=3    ${mbps}=150
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=ul mbps=100 trf_id=10    UE ${ue_id}: UDP UL
    FOR    ${I}    IN RANGE    1    ${times}
        Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=${mbps} trf_id=${I}    UE ${ue_id}: UDP DL
    END

Verify Throughput
    [Arguments]    ${ue_id}=81    ${pdu}=1    ${qfi}=1    ${Tput_dl}=40    ${Tput_ul}=16
    sleep    10s    #wait throughput
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    direction=ul    rate_type=ave
    ${scell_tputdl}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pdsch    Throughput
    ${scell_tputul}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pusch    Throughput
    Should Not Match Regexp    ${scell_tputdl}    CellIndex-[0-5] *0 *0 *0 *0 *0
    Should Not Match Regexp    ${scell_tputul}    CellIndex-[0-3] *0 *0 *0
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

Setup 5CC CA trigger UE inactive and resume
    UE Attach To Target Cell    ue_id=81    cell_id=12
    Send Throughput    times=8
    Trigger A12 MR    event_type=A1    carrierfreq=437550    srsrp_nr=100    ue_id=${ue_id}    pass_regrxp=${CA_cell12_cell11_cell14_cell1_cell2}
    Wait Until Keyword Succeeds    60s    10s    Verify Throughput    Tput_dl=300    Tput_ul=50
    Trigger UE inactive and resume
    Send Throughput    times=8
    Wait Until Keyword Succeeds    60s    10s    Verify Throughput    Tput_dl=120    Tput_ul=10
    Trigger A12 MR    event_type=A1    carrierfreq=437550    srsrp_nr=100    ue_id=${ue_id}    pass_regrxp=${CA_cell12_cell11_cell14_cell1_cell2}
    Wait Until Keyword Succeeds    60s    10s    Verify Throughput    Tput_dl=300    Tput_ul=50

Trigger UE inactive and resume
    Trigger UE Inactive by UAI
    Trigger RRC Resume Success    cell_id=12

RRE to cell12 and trigger scell added
    [Arguments]    ${ue_id}=81
    Trigger RRCReestablishment    ue_id=${ue_id}    cell_id=12    RRE_check=${RRE_to_cell12}
    Trigger A12 MR    event_type=A1    carrierfreq=437550    srsrp_nr=80    ue_id=${ue_id}    pass_regrxp=${CA_cell12_cell11_cell14}
    Wait Until Keyword Succeeds    60s    10s    Verify Throughput    Tput_dl=100    Tput_ul=10

RRE to cell1
    [Arguments]    ${ue_id}=81
    Trigger RRCReestablishment    ue_id=${ue_id}    cell_id=1    RRE_check=${RRE_to_cell1}

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir

Trigger A12 MR
    [Arguments]    ${event_type}=A1    ${carrierfreq}=518910    ${srsrp_nr}=5    ${srsrq_nr}=5    ${ue_id}=81
    ...    ${pass_regrxp}=rrcReconfigurationComplete
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type}
    ...    srsrp_nr=${srsrp_nr} srsrq_nr=${srsrq_nr}
    Execute Egate Command    ${cmd}    pass_regexp=${pass_regrxp}

Trigger A1 or A2 PCell Change
    [Arguments]    ${event_type}=A1    ${carrierfreq}=633312    ${scell_rsrp}=100    ${scell_rsrq}=100    ${ue_id}=81
    ...    ${scell_id}=2    ${pass_check}=${pcell_change_cell14}    ${threshold}=50
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}    threshold=${threshold}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type}
    ...    srsrp_nr=11 srsrq_nr=11 scell=${scell_id} scell_rsrp=${scell_rsrp} scell_rsrq=${scell_rsrq}
    Execute Egate Command    ${cmd}    pass_regexp=${pass_check}

ANR HO
    [Arguments]    ${ue_id}=81    ${carrier_source}=368430    ${carrier_target}=388830    ${phycell_id}=62
    ...    ${A2_pass_regrxp}=rrcReconfigurationComplete    ${A3_pass_regrxp}=rrcReconfigurationComplete
    ${measid}    get nr meas id for specific type and frequency    ue_id=${ue_id}    carrierfreq=${carrier_source}    event_type=A2
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${measid} event=A2 srsrp_nr=7 srsrq_nr=7
    ...    pass_regexp=${A2_pass_regrxp}
    ${measid}    get nr meas id for specific type and frequency    ue_id=${ue_id}    carrierfreq=${carrier_target}    event_type=A3
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${measid} event=A3 srsrp_nr=100 phycell_id=${phycell_id} nrsrp_nr=100
    ...    pass_regexp=${A3_pass_regrxp}
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-8 type=pdsch    pass_regexp=CellIndex
    Wait Until Keyword Succeeds    60s    10s    Verify Throughput    Tput_dl=200    Tput_ul=50

Trigger UE Inactive by UAI
    [Arguments]    ${ue_id}=81
    Stop traffic
    Execute Egate Command    ue_assistance_send_nr ue_id=${ue_id} PreferredRRCState=inactive    pass_regexp=${INACTIVE_check}    timeout=30s
    #sleep    1s    #sleep for inactive procedure complete

Trigger RRC Resume Success
    [Arguments]    ${ue_id}=81    ${cell_id}=13    ${pass_regexp}=${resum_success_cell12}
    Execute Egate Command    ue_nr_rrc_resume_request_param id=${ue_id} gnb=2 cell=${cell_id} cause=mo_Data
    Execute Egate Command    ue_nr_rrc_resume id=${ue_id}    pass_regexp=${pass_regexp}

Stop traffic
    [Arguments]    ${ue_id}=81
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=1 qfi=1 dir=ul    UE${ue_id}: Stopping
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=1 qfi=1 dir=dl    UE ${ue_id}: DL Traffic was stopped

Trigger RRCReestablishment
    [Arguments]    ${ue_id}=81    ${cell_id}=11    ${RRE_check}=RRC
    Execute Egate Command    ue_rrc_reestablish id=${ue_id} gnb=2 cell=${cell_id} cause=reconfigurationFailure    pass_regexp=${RRE_check}
    Wait Until Keyword Succeeds    60s    10s    Verify Throughput    Tput_dl=120    Tput_ul=45
