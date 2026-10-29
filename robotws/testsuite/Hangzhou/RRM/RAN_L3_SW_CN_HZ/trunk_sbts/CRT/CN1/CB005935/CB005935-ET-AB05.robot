*** Settings ***
Documentation
...    author:  ruifang.zhu@nokia-sbell.com
...    contact: ruifang.zhu@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    RAN_5G_FDD    SBTS00    team-CN1ET    owner-lena.zhuo
...    CLOUD_5G_I_BOO_AP_LOO    CRT    CB005935-AB    release-5G24R3
...    STATE_CONFIGURED    RAN_5G
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
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
...    NRBTS-1/NRDRB-15:nrDrxDN=MRBTS-1/NRBTS-1/NRDRX-2
...    @{Mobility_related}
...    @{CA_related}
...    @{IRAT_related}
...    @{ANR_related}
...    @{IMME_CAaware}
...    @{chbw_related}
...    @{CB008225_CB006597}
...    @{732}

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
...    NRCELL:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=2560ms
...    NRCELL:a1MeasSCellAddEnabled=rsrp
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=70
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=90
...    NRCELL-1:a2MeasPCellSwitchEnabled=rsrp
...    NRCELL-1:a2MeasPCellSwitchSsbRsrp:a2ThresholdPCellSwitchSsbRsrp=50
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
...    NRBTS/NRCELL-12:drxProfileNrAnr:drxControl=any
#...    NRBTS/NRCELL-12:drxProfileNrAnr:drxInactivityTimer=10ms
#...    NRBTS/NRCELL-12:drxProfileNrAnr:drxLongCycle=80ms
#...    NRBTS/NRCELL-12:drxProfileNrAnr:drxOnDurationTimer=20ms
#...    NRBTS/NRCELL-12:drxProfileNrAnr:drxRetransTimerDl=0slot
#...    NRBTS/NRCELL-12:drxProfileNrAnr:drxRetransTimerUl=0slot
...    NRCELL-1:actCDrx=true
#...    NRCELL-1:drxProfileNrAnr:drxLongCycle=320ms|drxControl=intraNRSAinterFreq
...    NRCELL-1:drxProfileNrAnr:drxControl=any

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
...    NRCELL-1/NRHOIF-12:a2BasedPCellSwitchEnabled=true
...    NRCELL-1/NRHOIF-12:a2BasedPCellSwitchPriority=1
...    NRCELL-1/NRHOIF-12:cellDepType=SA
...    NRCELL-1/NRHOIF-12:deriveSsbIndexFromCell=true
...    NRCELL-1/NRHOIF-12:freqBandIndicatorNR=66
...    NRCELL-1/NRHOIF-12:ifhoSsbSmtcDuration=sf1
...    NRCELL-1/NRHOIF-12:ifhoSsbSmtcPeriodicity=sf5
...    NRCELL-1/NRHOIF-12:ssbFrequency=427970
...    NRCELL-1/NRHOIF-12:thresholdPCellSwitchTargetRsrp=40
...    NRCELL-1/NRHOIF-12:thresholdPCellSwitchTargetRsrq=40
...    NRCELL-1/NRHOIF-12:a4MeasNrDcSsbRsrp:a4HysteresisNrDcSsbRsrp=0
...    NRCELL-1/NRHOIF-12:a4MeasNrDcSsbRsrq:a4HysteresisNrDcSsbRsrq=0
...    NRCELL-1/NRHOIF-12:a4MeasSCellAddSsbRsrp:a4HysteresisSCellAddSsbRsrp=0
...    NRCELL-1/NRHOIF-12:a4MeasSCellAddSsbRsrq:a4HysteresisSCellAddSsbRsrq=0
...    NRCELL-1/NRHOIF-12:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-1/NRHOIF-12:a4MeasSsbRsrq:a4HysteresisSsbRsrq=0
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
...    NRCELL-1/NRHOIF-14:a4MeasNrDcSsbRsrp:a4HysteresisNrDcSsbRsrp=0
...    NRCELL-1/NRHOIF-14:a4MeasNrDcSsbRsrq:a4HysteresisNrDcSsbRsrq=0
...    NRCELL-1/NRHOIF-14:a4MeasSCellAddSsbRsrp:a4HysteresisSCellAddSsbRsrp=0
...    NRCELL-1/NRHOIF-14:a4MeasSCellAddSsbRsrq:a4HysteresisSCellAddSsbRsrq=0
...    NRCELL-1/NRHOIF-14:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-1/NRHOIF-14:a4MeasSsbRsrq:a4HysteresisSsbRsrq=0
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
...    NRCELL-14/NRREL-12:gNbId=1
...    NRCELL-14/NRREL-12:handoverAllowedSARedCap=allowed
...    NRCELL-14/NRREL-12:lcrId=12
...    NRCELL-14/NRREL-12:removeNotAllowed=true
...    NRCELL-14/NRREL-12:sCellAdditionMethod=blind
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

@{OnlineParamChange_HoOptimizeToFalse}
...    NRBTS:actHoOptimizationCa=false

@{OnlineParamChange_HoOptimizeToTrue}
...    NRBTS:actHoOptimizationCa=true

@{CA_check_CELL12_CELL11_CELL14}
...    eventId eventA2
...    pcid:61, scellIdx:0
...    pcid:60, scellIdx:1
...    pcid:63, scellIdx:2
...    rrcReconfigurationComplete

@{blindCA_cell11_cell12_cell13}
...    QoS Routing Table
...    eventId eventA2
...    pcid:62, scellIdx:2
...    pcid:61, scellIdx:1
...    pcid:60, scellIdx:0
...    rrcReconfigurationComplete

@{resum_success_cell11}
...    rrcResumeRequest1
...    resumeCause mo-Data
...    rrcResumeComplete
...    pcid:60, scellIdx:0
...    pcid:61, scellIdx:1
...    eventId eventA2
...    freqBandIndicatorNR 66
...    rrcReconfigurationComplete

@{Check_TriggerA2HO}
...    eventId eventA1
...    eventId eventA3
...    gapFR1 setup
...    drx-Config release
...    rrcReconfigurationComplete

@{Check_TriggerA2HO_simGNB}
...    gapUE setup
...    eventId eventA3
...    rrcReconfigurationComplete

@{cell11_HO_cell381}
...    gapUE setup
...    Inter-eNB handover from EXT_ENB-2.11 to ENB-3.1 performed
...    rrcReconfigurationComplete

@{cell12_HO_cell382}
...    gapUE setup
...    Inter-eNB handover from EXT_ENB-2.12 to ENB-4.1 performed
...    rrcReconfigurationComplete

@{cell382_HO_cell12}
...    drx-Config setup
...    eventId eventA1
...    pcid:61, scellIdx:0
...    Inter-eNB handover from ENB-4.1 to EXT_ENB-2.12 performed
...    rrcReconfigurationComplete

@{cell381_HO_cell12}
...    drx-Config setup
...    pcid:60, scellIdx:1
...    pcid:63, scellIdx:2
...    pcid:61, scellIdx:0
...    Inter-eNB handover from ENB-3.1 to EXT_ENB-2.12 performed
...    rrcReconfigurationComplete

@{cell381_HO_cell11}
...    drx-Config setup
...    pcid:60, scellIdx:0
...    pcid:62, scellIdx:2
...    pcid:61, scellIdx:1
...    Inter-eNB handover from ENB-3.1 to EXT_ENB-2.11 performed
...    rrcReconfigurationComplete

@{cell12_HO_cell1}
...    gapFR1 release
...    drx-Config setup
...    eventId eventA1
...    pcid:50, scellIdx:0
...    rrcReconfigurationComplete

@{cell12_HO_cell13}
...    gapFR1 release
...    drx-Config setup
...    pcid:61, scellIdx:1
...    pcid:62, scellIdx:0
...    Intra-eNB handover from EXT_ENB-2.12 to EXT_ENB-2.13 performed
...    rrcReconfigurationComplete

@{CA_cell12_cell11_cell14_cell1_cell2}
...    pcid:50, scellIdx:1
...    pcid:51, scellIdx:2
...    pcid:60, scellIdx:3
...    pcid:63, scellIdx:4
...    pcid:61, scellIdx:0
...    rrcReconfigurationComplete

@{CA_cell1_cell12_cell14}
...    pcid:50, scellIdx:0
...    pcid:63, scellIdx:2
...    pcid:61, scellIdx:1
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

@{cell14_HO_LTE}
...    Successful handover from EXT_ENB-2.14 to ENB-5.1
...    IRAT Handover from NR to EUTRA completed

@{LTE_HO_cell12}
...    drx-Config setup
...    pcid:61, scellIdx:0
...    Inter-eNB handover from ENB-5.1 to EXT_ENB-2.12 performed
...    rrcReconfigurationComplete

@{Trigger_IRATHO}
...    eventId eventA1
...    eventId eventB2
...    gapFR1 setup
...    drx-Config release
...    rrcReconfigurationComplete

@{INACTIVE_check}
...    SuspendConfig
...    fullI_RNTI
...    shortI_RNTI
...    ran-AreaCodeList
...    t380
...    UE81: Is INACTIVE

@{RRE_to_cell12}
...    rrcReestablishmentComplete
...    pcid:61, scellIdx:0
...    rrcReconfigurationComplete

@{CA_aware_check}
...    freqPriorityListNR
...    cellReselectionPriority 7
...    carrierFreq 424000

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
CB005935-ET-AB005_scell addition during kinds of HO
    [Documentation]
    ...    1. The purpose of this test case is to check the successful operation of the inter-band FDD - FDD FR1 UL CA feature for incoming
    ...    handover UE with SA option 2 call. For target cell, PCell is FDD carrier and single SCell is FDD FR1 carrier.
    ...    The handover can be inter-gNB,or intra-gNB intra-DU.
    ...    For classical gNB, there is no intra-gNB inter-DU handover case as there is only one gNB-DU for classical gNB.
    ...    2. Configuration configuration:
    ...    gnb sim1 has Xn link with real gnb2
    ...    gnb sim2 has NG link with real gnb2
    ...    DRX and measurement gap configured properly for each cell.
    ...    3. Test Case Steps:
    ...         a. UE attach to cell-11(n66), blind CA: 66(cell12)_25(cell13)[U], start proper UL/DL data.
    ...         b. Trigger UE inactive and resume, CA auto added, start proper UL/DL data.
    ...         c. Xn HO to sim gnb1,Xn HO back to real gnb2 cell11: blind CA: 66(cell11)_66(cell12)_25(cell13)[U]
    ...         d. Xn HO to sim gnb1,Xn HO to real gnb2 cell12: coverbase CA: 66(cell12)_66(cell11)_25(cell14)[U]
    ...         e. trigger RRE to cell12, then trigger scell addation.
    ...         f. OnlineParamChange HoOptimize To False, then NG HO to gnb2, NG HO back to gnb2 cell12:66(cell12), no scell added
    ...         g. Trigger cell-12 scell addation.
    ...         h. trigger HO to cell1,and trigger scell addation.
    ...         i. pcell change to cell14.
    ...         j. IRAT HO to LTE and HO back to real gnb2 cell12, than trigger FDD scell addation.
    ...         k. OnlineParamChange HoOptimize To True, AMR HO to cell13, scell auto added.
    ...         l. UE deregister is successfully and check CA aware.
    ...    4. Expect result:
    ...        a. blind CA: 66(cell11)_66(cell12)_25(cell13)[U] added successfully, both UL/DL data can be transferred on P/Scell.
    ...        b. UE inactive and resume successful, blind CA: 66(cell11)_66(cell12)_25(cell13)[U] added successfully, both UL/DL data can be
    ...     transferred on P/Scell.
    ...        c. blind CA: 66(cell11)_66(cell12)_25(cell13)[U] added successfully, both UL/DL data can be transferred on P/Scell.
    ...        d. coverbase CA:66(cell12)_66(cell11)_25(cell14)[U] added successfully, both UL/DL data can be transferred on P/Scell.
    ...        e. RRE successful, and CA:66(cell12)_66(cell11)_25(cell14)[U] added successfully.
    ...        f. OnlineParamChange HoOptimize To False, then NG HO to gnb2, NG HO back to gnb2 cell12:66(cell12), no scell added
    ...        g. scell addation successful, 66(cell12)_66(cell11)_25(cell14)[U]_78(cell1)_78(cell2) added successfully, and both UL/DL data
    ...     can be transferred on P/Scell.
    ...        h. trigger HO to 78cell1, 66(cell12)_25(cell14)[U] scell added, both UL/DL data can be transferred on P/Scell.
    ...        i. pcell change to cell14, 66(cell12) scell auto added, both UL/DL data can be transferred on P/Scell.
    ...        j. IRAT HO to LTE and HO back to real gnb2 cell12, 66(cell12)_66(cell11)_25(cell14)[U] added successful,both UL/DL data can be
    ...     transferred on P/Scell.
    ...        k. OnlineParamChange HoOptimize To True, AMR HO to cell13, 25(cell13)_66(cell12) added successful.
    ...        l. UE deregister is successfully and check CA aware.
    [Tags]    QC_46930    AB005    lena.zhuo
    UE Attach and check throughput
    Trigger UE inactive and resume
    InterGNB XN HO between real cell and sim cell
    RRE to original cell and trigger scell added
    InterGNB NG HO between real cell and sim cell
    Intra-DU HO and pcell change
    IRAT HO and ANR HO and CA aware
    [Teardown]    AB005_Teardown

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

AB005_Teardown
    OnlineParamChange    ${OnlineParamChange_HoOptimizeToTrue}
    Common Test Teardown And Stop Capture Logs

Update UE capa
    [Arguments]    ${SA_Capa_perUE_Full}=none    ${ue_id}=81
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full}
    Execute Egate Command    ${cmd}

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
    ...    pass_regexp=${blindCA_cell11_cell12_cell13}

Send Throughput
    [Arguments]    ${ue_id}=81    ${times}=3    ${mbps}=150
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=ul mbps=70 trf_id=10    UE ${ue_id}: UDP UL
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

UE Attach and check throughput
    UE Attach To Target Cell    ue_id=81    cell_id=11
    Send Throughput    times=3
    Verify Throughput    Tput_dl=240    Tput_ul=50

Trigger UE inactive and resume
    Trigger UE Inactive by UAI
    Trigger RRC Resume Success    cell_id=11
    Send Throughput    times=7
    Verify Throughput    Tput_dl=280    Tput_ul=50

InterGNB XN HO between real cell and sim cell
    [Arguments]    ${ue_id}=81
    #cell-11 - cell-381, XN HO
    InterFreq_HO    event_type=A2    carrier_source=423130    carrier_target=513150    srsrp=30    physcell_id=381    nrsrp_nr=80    ue_id=${ue_id}
    ...    A2_pass_regrxp=${Check_TriggerA2HO}    A3_pass_regrxp=${cell11_HO_cell381}
    #cell-381 - cell-11, XN HO
    InterFreq_HO    event_type=A2    carrier_source=513150    carrier_target=423130    srsrp=3    physcell_id=60    nrsrp_nr=80    ue_id=${ue_id}
    ...    A2_pass_regrxp=${Check_TriggerA2HO_simGNB}    A3_pass_regrxp=${cell381_HO_cell11}
    Verify Throughput    Tput_dl=280    Tput_ul=50
    #cell-11 - cell-381, XN HO
    InterFreq_HO    event_type=A2    carrier_source=423130    carrier_target=513150    srsrp=30    physcell_id=381    nrsrp_nr=80    ue_id=${ue_id}
    ...    A2_pass_regrxp=${Check_TriggerA2HO}    A3_pass_regrxp=${cell11_HO_cell381}
    #cell-381 - cell-12, XN HO
    InterFreq_HO    event_type=A2    carrier_source=513150    carrier_target=437550    srsrp=3    physcell_id=61    nrsrp_nr=80    ue_id=${ue_id}
    ...    A2_pass_regrxp=${Check_TriggerA2HO_simGNB}    A3_pass_regrxp=${cell381_HO_cell12}
    Verify Throughput    Tput_dl=280    Tput_ul=50

RRE to original cell and trigger scell added
    [Arguments]    ${ue_id}=81
    Trigger RRCReestablishment    ue_id=${ue_id}    cell_id=12    RRE_check=${RRE_to_cell12}
    Trigger A12 MR    event_type=A1    carrierfreq=437550    srsrp_nr=80    ue_id=${ue_id}    pass_regrxp=${CA_cell12_cell11_cell14}
    Verify Throughput    Tput_dl=280    Tput_ul=50

InterGNB NG HO between real cell and sim cell
    [Arguments]    ${ue_id}=81
    OnlineParamChange    ${OnlineParamChange_HoOptimizeToFalse}
    #cell-12 - cell-382, NG HO
    InterFreq_HO    event_type=A2    carrier_source=437550    carrier_target=127210    srsrp=30    physcell_id=382    nrsrp_nr=80    ue_id=${ue_id}
    ...    A2_pass_regrxp=${Check_TriggerA2HO}    A3_pass_regrxp=${cell12_HO_cell382}
    #cell-382 - cell-12, NG HO
    InterFreq_HO    event_type=A2    carrier_source=127210    carrier_target=437550    srsrp=3    physcell_id=61    nrsrp_nr=80    ue_id=${ue_id}
    ...    A2_pass_regrxp=${Check_TriggerA2HO_simGNB}    A3_pass_regrxp=${cell382_HO_cell12}
    Verify Throughput    Tput_dl=130    Tput_ul=50
    #cell-12 scell addtion
    Trigger A12 MR    event_type=A1    carrierfreq=437550    srsrp_nr=100    ue_id=${ue_id}    pass_regrxp=${CA_cell12_cell11_cell14_cell1_cell2}
    Verify Throughput    Tput_dl=600    Tput_ul=50

Intra-DU HO and pcell change
    [Arguments]    ${ue_id}=81
    #cell-12 - cell-1, intra-DU HO
    InterFreq_HO    event_type=A2    carrier_source=437550    carrier_target=633312    srsrp=30    physcell_id=50    nrsrp_nr=80    ue_id=${ue_id}
    ...    A2_pass_regrxp=${Check_TriggerA2HO}    A3_pass_regrxp=${cell12_HO_cell1}
    Verify Throughput    Tput_dl=600    Tput_ul=50
    #cell-1 scell addtion
    Trigger A12 MR    event_type=A1    carrierfreq=633312    srsrp_nr=80    ue_id=${ue_id}    pass_regrxp=${CA_cell1_cell12_cell14}
    Verify Throughput    Tput_dl=600    Tput_ul=50
    #pcell change from cell-1 to cell-14
    Trigger A1 or A2 PCell Change    event_type=A2    carrierfreq=633312    ue_id=${ue_id}    scell_id=2    pass_check=${pcell_change_cell14}

IRAT HO and ANR HO and CA aware
    [Arguments]    ${ue_id}=81
    # Cell-14 - LTE IRAT HO
    Trigger B2 MR to HO to LTE    ue_id=${ue_id}    carrierfreq=391450    B2_pass_regexp=${cell14_HO_LTE}    A2_pass_regrxp=${Trigger_IRATHO}
    # LTE IRAT HO - Cell-12
    Trigger HO back from LTE    ue_id=${ue_id}    pass_check=${LTE_HO_cell12}
    #scell add
    Trigger MR scelladd    ${CA_check_CELL12_CELL11_CELL14}    ue_id=${ue_id}    carrierfreq=437550
    OnlineParamChange    ${OnlineParamChange_HoOptimizeToTrue}
    #ANR HO to cell-13
    ANR HO From Ncell 12 to Ncell 13    carrier_source=437550    carrier_target=388830    ue_id=${ue_id}
    ...    A2_pass_regrxp=${Check_TriggerA2HO}    A3_pass_regrxp=${cell12_HO_cell13}
    #Trigger UE release and CA aware
    ${ret}    Execute Egate Command    ue_deregister id=81 ue_deregister_type=switch_off    detached
    should contain    ${ret}    @{CA_aware_check}

InterFreq_HO
    [Arguments]    ${event_type}    ${carrier_source}    ${carrier_target}    ${srsrp}=30    ${physcell_id}=381    ${nrsrp_nr}=80    ${ue_id}=81
    ...    ${A2_pass_regrxp}=rrcReconfigurationComplete    ${A3_pass_regrxp}=rrcReconfigurationComplete
    Trigger A12 MR    event_type=${event_type}    carrierfreq=${carrier_source}    srsrp_nr=${srsrp}    ue_id=${ue_id}
    ...    pass_regrxp=${A2_pass_regrxp}
    Trigger InterFreA3 Ho    carrierfreq=${carrier_target}    phycell_id=${physcell_id}    nrsrp_nr=${nrsrp_nr}    ue_id=${ue_id}
    ...    pass_regrxp=${A3_pass_regrxp}

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir

Trigger MR scelladd
    [Arguments]    ${scell_added_log}    ${ue_id}=81    ${carrierfreq}=650016
    ${meas_id}=    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A1
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=80 srsrq_nr=52
    ...    pass_regexp=${scell_added_log}
    Verify Throughput    Tput_dl=400    Tput_ul=50

Trigger A12 MR
    [Arguments]    ${event_type}=A1    ${carrierfreq}=518910    ${srsrp_nr}=5    ${srsrq_nr}=5    ${ue_id}=81
    ...    ${pass_regrxp}=rrcReconfigurationComplete
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type}
    ...    srsrp_nr=${srsrp_nr} srsrq_nr=${srsrq_nr}
    Execute Egate Command    ${cmd}    pass_regexp=${pass_regrxp}

Trigger InterFreA3 Ho
    [Arguments]    ${carrierfreq}    ${phycell_id}    ${nrsrp_nr}=5    ${ue_id}=81    ${pass_regrxp}=rrcReconfigurationComplete
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A3
    ${ret1}=     Execute Egate Command
    ...    ue_measurement_send_nr id=81 meas_id=${meas_id} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=${phycell_id} nrsrp_nr=${nrsrp_nr} nrsrq_nr=60
    ...    pass_regexp=${pass_regrxp}

Trigger A1 or A2 PCell Change
    [Arguments]    ${event_type}=A1    ${carrierfreq}=640416    ${scell_rsrp}=100    ${scell_rsrq}=100    ${ue_id}=81
    ...    ${scell_id}=2    ${pass_check}=rrcReconfigurationComplete    ${threshold}=50
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}    threshold=${threshold}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type}
    ...    srsrp_nr=11 srsrq_nr=11 scell=${scell_id} scell_rsrp=${scell_rsrp} scell_rsrq=${scell_rsrq}
    Execute Egate Command    ${cmd}    pass_regexp=${pass_check}
    Verify Throughput    Tput_dl=280    Tput_ul=50

Trigger B2 MR to HO to LTE
    [Arguments]    ${ue_id}=81    ${carrierfreq}=648096    ${event_type}=B2    ${B2_pass_regexp}=IRAT Handover from NR to EUTRA completed
    ...    ${A2_pass_regrxp}=rrcReconfigurationComplete
    Trigger A12 MR    event_type=A2    ue_id=${ue_id}    carrierfreq=${carrierfreq}    pass_regrxp=${A2_pass_regrxp}
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=1    event_type=B2    carrierfreq_rat=EUTRAN
    ${meas_para}    catenate
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type} srsrp_nr=11
    ...    srsrq_nr=11 phycell_id=11 nrsrp_nr=30 nrsrq_nr=30
    Execute Egate Command    ${meas_para}    pass_regexp=${B2_pass_regexp}
    sleep    20s    reason=wait timer

Trigger HO back from LTE
    [Arguments]    ${ue_id}=81    ${pass_check}=rrcReconfigurationComplete
    Execute Egate Command    gnb_trigger_inter_rat_handover_to_5g ue=${ue_id} target_gnb=2 target_cell=12 plmn=311:489
    ...    pass_regexp=${pass_check}
    Verify Throughput    Tput_dl=130    Tput_ul=50

ANR HO From Ncell 12 to Ncell 13
    [Arguments]    ${ue_id}=81    ${carrier_source}=368430    ${carrier_target}=388830    ${phycell_id}=62
    ...    ${A2_pass_regrxp}=rrcReconfigurationComplete    ${A3_pass_regrxp}=rrcReconfigurationComplete
    ${measid}    get nr meas id for specific type and frequency    ue_id=${ue_id}    carrierfreq=${carrier_source}    event_type=A2
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${measid} event=A2 srsrp_nr=7 srsrq_nr=7
    ...    pass_regexp=${A2_pass_regrxp}
    ${measid}    get nr meas id for specific type and frequency    ue_id=${ue_id}    carrierfreq=${carrier_target}    event_type=A3
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${measid} event=A3 srsrp_nr=100 phycell_id=${phycell_id} nrsrp_nr=100
    ...    pass_regexp=${A3_pass_regrxp}
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-8 type=pdsch    pass_regexp=CellIndex
    Verify Throughput    Tput_dl=300    Tput_ul=50

Trigger UE Inactive by UAI
    [Arguments]    ${ue_id}=81
    Stop traffic
    Execute Egate Command    ue_assistance_send_nr ue_id=${ue_id} PreferredRRCState=inactive    pass_regexp=${INACTIVE_check}
    sleep    1s    #sleep for inactive procedure complete

Trigger RRC Resume Success
    [Arguments]    ${ue_id}=81    ${cell_id}=13    ${pass_regexp}=${resum_success_cell11}
    Execute Egate Command    ue_nr_rrc_resume_request_param id=${ue_id} gnb=2 cell=${cell_id} cause=mo_Data
    Execute Egate Command    ue_nr_rrc_resume id=${ue_id}    pass_regexp=${pass_regexp}

Trigger UE send UEAssistanceInformation
    Execute Egate Command    ue_assistance_send_nr ue_id=2 PreferredRRCState=inactive    pass_regexp=UE2 has no FSM allocated

Stop traffic
    [Arguments]    ${ue_id}=81
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=1 qfi=1 dir=ul    UE${ue_id}: Stopping
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=1 qfi=1 dir=dl    UE ${ue_id}: DL Traffic was stopped

Trigger RRCReestablishment
    [Arguments]    ${ue_id}=81    ${cell_id}=11    ${RRE_check}=RRC
    Execute Egate Command    ue_rrc_reestablish id=${ue_id} gnb=2 cell=${cell_id} cause=reconfigurationFailure    pass_regexp=${RRE_check}
    Verify Throughput    Tput_dl=130    Tput_ul=50
