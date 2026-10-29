*** Settings ***
Documentation
...    author: Li Zhiguo
...    contact: zhiguo.li@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup       Start BTS With Specified Config Files
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_FDD    CLOUD_5G_I_LPQ_AP_LOO
...               team-CN3ET    owner-xu.wang    release-SBTS24R3    CB012149
Resource          ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
${GNB_CONFIG}    fddtdd_sansa_cmwv/6cells_2T4F
${SYSCOM_FLAG}    true

# if FDD cells have a bandwidth > 25MHz, need configure FR1_WB
@{PARAMS_IN_IPHY_XML}    fddFrequencyRange=FR1_WB

@{PARAMS_IN_SWCONFIG}
...    @{AaSysLogOutputMode}
...    @{AaSysLogOutputLevel}
...    @{AaSysLogInputLevel}
...    @{BSTAT_PM_debug_prints}
...    @{enable_measurement_flag}
...    @{rdULCaEnablerPhase}
...    @{rdUseOptimizedDpaAlgo}
@{AaSysLogOutputMode}
...    0x10041 = 5
@{AaSysLogOutputLevel}
...    0x10040 = 1
@{AaSysLogInputLevel}
...    0x1003F = 1
@{BSTAT_PM_debug_prints}
...    0x340002 = 1
@{enable_measurement_flag}
...    0x340006 = 55118
@{rdULCaEnablerPhase}
...    0x580591=0
@{rdUseOptimizedDpaAlgo}
...    0x58056B=1

@{PARAMS_IN_SCF}
...    @{CB012149_enable}
...    @{CB009169_disable}
...    @{CA}
...    @{NRREL}
...    @{Mobillity}
...    @{Others}
...    @{gscn_Arfcn}
...    @{5GC000704}
...    @{dlToUlContributionRatio50 and frameStructureType semiStatic}
...    @{ulTxSwitchingBoost_18}


${Cell1_ssbFrequency}    518430

${carrierAggregationSupportList_wo_Ul}    SEPARATOR=
...    ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Any_Sa,ca_Fdd_Fdd,ca_Fr1Tdd_Any_Sa,
...    ca_Fdd_Fr1Tdd_Nsa

@{CB012149_enable}
...    NRBTS/NRDU-1:ulTxSwitchingSupportList=ca_Fr1T_F_Sa_switchedUl

@{CB009169_disable}
...    NRBTS/NRDU-1:carrierAggregationSupportList=${carrierAggregationSupportList_wo_Ul}
...    NRBTS/NRDU-1:dlToUlContributionRatio=50
...    NRBTS/NRDRB_RLC_AM-1:ulTReassemblyIBCA=40
...    NRBTS/NRDRB_RLC_AM-2:ulTReassemblyIBCA=40
...    NRCELL:maxNumScellsDlFr1=3
...    NRCELL:timingAdvanceOffset=n25600
...    NRCELL:actK1Opt=intra-gNB

@{gscn_Arfcn}
...    NRCELL-1:nrarfcn=518598
...    NRCELL-1:gscnOrSsPbchArfcn=6480
...    NRCELL-1:chBw=80MHz

...    NRCELL-2:nrarfcn=636666
...    NRCELL-2:gscnOrSsPbchArfcn=7880
...    NRCELL-2:chBw=70MHz

...    NRCELL-11/NRCELL_FDD-1:nrarfcnDl=424000
...    NRCELL-11/NRCELL_FDD-1:nrarfcnUl=344000
...    NRCELL-11/NRCELL_FDD-1:chBwDl=10MHz
...    NRCELL-11/NRCELL_FDD-1:chBwUl=10MHz
...    NRCELL-11:gscnOrSsPbchArfcn=5300

...    NRCELL-12/NRCELL_FDD-1:nrarfcnDl=126900
...    NRCELL-12/NRCELL_FDD-1:nrarfcnUl=136100
...    NRCELL-12/NRCELL_FDD-1:chBwDl=10MHz
...    NRCELL-12/NRCELL_FDD-1:chBwUl=10MHz
...    NRCELL-12:gscnOrSsPbchArfcn=1587

...    NRCELL-13/NRCELL_FDD-1:nrarfcnDl=430920
...    NRCELL-13/NRCELL_FDD-1:nrarfcnUl=350920
...    NRCELL-13/NRCELL_FDD-1:chBwDl=30MHz
...    NRCELL-13/NRCELL_FDD-1:chBwUl=30MHz
...    NRCELL-13:gscnOrSsPbchArfcn=5385

...    NRCELL-14/NRCELL_FDD-1:nrarfcnDl=129000
...    NRCELL-14/NRCELL_FDD-1:nrarfcnUl=138200
...    NRCELL-14/NRCELL_FDD-1:chBwDl=10MHz
...    NRCELL-14/NRCELL_FDD-1:chBwUl=10MHz
...    NRCELL-14:gscnOrSsPbchArfcn=1611
...    NRCELL-14:type0CoresetConfigurationIndex=6

...    MRBTS-1/NRBTS-1/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=0|searchSpaceId=7
...    MRBTS-1/NRBTS-1/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|searchSpaceId=7
...    MRBTS-1/NRBTS-1/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-0-And-1-0|searchSpaceId=7
...    MRBTS-1/NRBTS-1/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|searchSpaceId=8
...    MRBTS-1/NRBTS-1/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|searchSpaceId=8
...    delete:MRBTS-1/NRBTS-1/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated

@{Others}
...    NRBTS:actMultiDrbNSA=true
...    NRBTS:actIncXn=true
...    NRBTS:actConflictConfiguration=true
...    NRBTS:rrcReestabTypeSA=sameGNB
...    NRBTS:tWaitingRlRecover=4000ms
...    NRCELL:pucchModeSelect=longPucch
...    NRBTS:actDrbDrx=false
...    NRCELL:actCDrx=true

@{CA}
...    NRBTS/NRDU-1:actConnectedModeMobilityCA=true
...    NRBTS/NRDU-1:flexibleCAMode=NumberCellAmount
...    NRBTS:actSlowPrbPooling=true
...    NRBTS:actConnRrcPooling=true
...    NRBTS:actScheUePooling=true
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

@{NRREL}
...    NRCELL-1/NRREL-1:gNbId=1
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:lcrId=11
...    NRCELL-1/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-1:sCellOperationalMode=dlAndUl
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-1:sCellPrio=1

...    NRCELL-1/NRREL-2:gNbId=1
...    NRCELL-1/NRREL-2:gNbIdLength=22
...    NRCELL-1/NRREL-2:lcrId=12
...    NRCELL-1/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-2:sCellOperationalMode=dlAndUl
...    NRCELL-1/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-2:sCellPrio=1

...    NRCELL-1/NRREL-3:gNbId=1
...    NRCELL-1/NRREL-3:gNbIdLength=22
...    NRCELL-1/NRREL-3:lcrId=13
...    NRCELL-1/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-3:sCellOperationalMode=dlAndUl
...    NRCELL-1/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-3:gnbPlmn:mncLength=3

...    NRCELL-1/NRREL-4:gNbId=1
...    NRCELL-1/NRREL-4:gNbIdLength=22
...    NRCELL-1/NRREL-4:lcrId=14
...    NRCELL-1/NRREL-4:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-4:sCellOperationalMode=dlAndUl
...    NRCELL-1/NRREL-4:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-4:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-4:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-4:sCellPrio=2

...    NRCELL-1/NRREL-5:gNbId=1
...    NRCELL-1/NRREL-5:gNbIdLength=22
...    NRCELL-1/NRREL-5:lcrId=2
...    NRCELL-1/NRREL-5:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-5:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-5:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-5:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-5:gnbPlmn:mncLength=3

...    NRCELL-2/NRREL-1:gNbId=1
...    NRCELL-2/NRREL-1:gNbIdLength=22
...    NRCELL-2/NRREL-1:lcrId=11
...    NRCELL-2/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-1:sCellOperationalMode=dlAndUl
...    NRCELL-2/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-1:sCellPrio=1

...    NRCELL-2/NRREL-2:gNbId=1
...    NRCELL-2/NRREL-2:gNbIdLength=22
...    NRCELL-2/NRREL-2:lcrId=12
...    NRCELL-2/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-2:sCellOperationalMode=dlAndUl
...    NRCELL-2/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-2:sCellPrio=1

...    NRCELL-2/NRREL-3:gNbId=1
...    NRCELL-2/NRREL-3:gNbIdLength=22
...    NRCELL-2/NRREL-3:lcrId=13
...    NRCELL-2/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-3:sCellOperationalMode=dlAndUl
...    NRCELL-2/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-3:gnbPlmn:mncLength=3

...    NRCELL-2/NRREL-4:gNbId=1
...    NRCELL-2/NRREL-4:gNbIdLength=22
...    NRCELL-2/NRREL-4:lcrId=14
...    NRCELL-2/NRREL-4:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-4:sCellOperationalMode=dlAndUl
...    NRCELL-2/NRREL-4:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-4:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-4:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-4:sCellPrio=2

...    NRCELL-2/NRREL-5:gNbId=1
...    NRCELL-2/NRREL-5:gNbIdLength=22
...    NRCELL-2/NRREL-5:lcrId=1
...    NRCELL-2/NRREL-5:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-5:sCellOperationalMode=dlOnly
...    NRCELL-2/NRREL-5:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-5:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-5:gnbPlmn:mncLength=3

...    NRCELL-1/NRHOIF-1:a1BasedPCellSwitchEnabled=true
...    NRCELL-1/NRHOIF-1:a2BasedPCellSwitchEnabled=true
...    NRCELL-1/NRHOIF-1:a2BasedPCellSwitchPriority=1
...    NRCELL-1/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-1/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-1/NRHOIF-1:freqBandIndicatorNR=41
...    NRCELL-1/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf5
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf20
...    NRCELL-1/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-1:ssbFrequency=428910
...    NRCELL-1/NRHOIF-1:thresholdPCellSwitchTargetRsrp=60
...    NRCELL-1/NRHOIF-1:thresholdPCellSwitchTargetRsrq=20
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms320
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=5

...    NRCELL-1/NRHOIF-2:a1BasedPCellSwitchEnabled=true
...    NRCELL-1/NRHOIF-2:a2BasedPCellSwitchEnabled=true
...    NRCELL-1/NRHOIF-2:a2BasedPCellSwitchPriority=1
...    NRCELL-1/NRHOIF-2:a3MeasEnabled=rsrp
...    NRCELL-1/NRHOIF-2:cellDepType=SA+NSA
...    NRCELL-1/NRHOIF-2:freqBandIndicatorNR=78
...    NRCELL-1/NRHOIF-2:ifhoSsbScs=30 KHz
...    NRCELL-1/NRHOIF-2:ifhoSsbSmtcDuration=sf5
...    NRCELL-1/NRHOIF-2:ifhoSsbSmtcPeriodicity=sf20
...    NRCELL-1/NRHOIF-2:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-2:ssbFrequency=636576
...    NRCELL-1/NRHOIF-2:thresholdPCellSwitchTargetRsrp=60
...    NRCELL-1/NRHOIF-2:thresholdPCellSwitchTargetRsrq=20
...    NRCELL-1/NRHOIF-2:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms320
...    NRCELL-1/NRHOIF-2:a3MeasSsbRsrp:a3OffsetSsbRsrp=5

...    NRCELL-1/NRHOIF-3:a1BasedPCellSwitchEnabled=true
...    NRCELL-1/NRHOIF-3:a2BasedPCellSwitchEnabled=true
...    NRCELL-1/NRHOIF-3:a2BasedPCellSwitchPriority=1
...    NRCELL-1/NRHOIF-3:a3MeasEnabled=rsrp
...    NRCELL-1/NRHOIF-3:cellDepType=SA+NSA
...    NRCELL-1/NRHOIF-3:freqBandIndicatorNR=71
...    NRCELL-1/NRHOIF-3:ifhoSsbScs=15KHz
...    NRCELL-1/NRHOIF-3:ifhoSsbSmtcDuration=sf5
...    NRCELL-1/NRHOIF-3:ifhoSsbSmtcPeriodicity=sf20
...    NRCELL-1/NRHOIF-3:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-3:ssbFrequency=126990
...    NRCELL-1/NRHOIF-3:thresholdPCellSwitchTargetRsrp=60
...    NRCELL-1/NRHOIF-3:thresholdPCellSwitchTargetRsrq=20
...    NRCELL-1/NRHOIF-3:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms320
...    NRCELL-1/NRHOIF-3:a3MeasSsbRsrp:a3OffsetSsbRsrp=5

...    NRCELL-1/NRHOIF-4:a1BasedPCellSwitchEnabled=true
...    NRCELL-1/NRHOIF-4:a2BasedPCellSwitchEnabled=true
...    NRCELL-1/NRHOIF-4:a2BasedPCellSwitchPriority=1
...    NRCELL-1/NRHOIF-4:a3MeasEnabled=rsrp
...    NRCELL-1/NRHOIF-4:cellDepType=SA+NSA
...    NRCELL-1/NRHOIF-4:freqBandIndicatorNR=66
...    NRCELL-1/NRHOIF-4:ifhoSsbScs=15KHz
...    NRCELL-1/NRHOIF-4:ifhoSsbSmtcDuration=sf5
...    NRCELL-1/NRHOIF-4:ifhoSsbSmtcPeriodicity=sf20
...    NRCELL-1/NRHOIF-4:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-4:ssbFrequency=423850
...    NRCELL-1/NRHOIF-4:thresholdPCellSwitchTargetRsrp=60
...    NRCELL-1/NRHOIF-4:thresholdPCellSwitchTargetRsrq=20
...    NRCELL-1/NRHOIF-4:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms320
...    NRCELL-1/NRHOIF-4:a3MeasSsbRsrp:a3OffsetSsbRsrp=5

...    NRCELL-2/NRHOIF-1:a1BasedPCellSwitchEnabled=true
...    NRCELL-2/NRHOIF-1:a2BasedPCellSwitchEnabled=true
...    NRCELL-2/NRHOIF-1:a2BasedPCellSwitchPriority=1
...    NRCELL-2/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-2/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-2/NRHOIF-1:freqBandIndicatorNR=78
...    NRCELL-2/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-2/NRHOIF-1:ifhoSsbSmtcDuration=sf5
...    NRCELL-2/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf20
...    NRCELL-2/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-2/NRHOIF-1:ssbFrequency=${Cell1_ssbFrequency}
...    NRCELL-2/NRHOIF-1:thresholdPCellSwitchTargetRsrp=60
...    NRCELL-2/NRHOIF-1:thresholdPCellSwitchTargetRsrq=20
...    NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms320
...    NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=5

...    NRBTS/NRPMRNL-1:miNrNgcFlexInterface=disabled
...    NRBTS/NRPMRNL-1:miNrIntraGnbMobilitySaPmqap=disabled
...    NRBTS/NRPMRNL-1:miNrIntraGnbMobilityNsaPmqap=disabled
...    NRBTS/NRPMRNL-1:miNrInterGnbXnMobilitySaPmqap=disabled
...    NRBTS/NRPMRNL-1:miNrInterGnbNgMobilitySaPmqap=disabled
...    NRBTS/NRPMRNL-1:miNrInterGnbMobilityNsaPmqap=disabled
...    NRBTS/NRPMRNL-1:miNrCABMCCP=disabled

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
...    NRBTS:cipherPrefL:nea3_128=8
...    NRCELL:a3MeasEnabled=rsrp
...    NRCELL:absThreshSsbRsrpConsolidation=1
...    NRCELL:sMeasConfigSsbRsrp=1
...    NRCELL:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms512
...    NRCELL:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL:a3MeasSsbRsrp:a3OffsetSsbRsrp=5
...    NRCELL:a1MeashoEnabledSA=rsrp
...    NRCELL:a2MeashoEnabledSA=rsrp
...    NRCELL:measGapSelectionSA=favourUeThroughput
...    NRCELL:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRCELL:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=60
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

@{5GC000704}
...    NRBTS:actConflictConfiguration=true
...    NRBTS:actUeCapaEnquiryHoCa=true
...    NRBTS:actIntraFreqHoSA=true
...    NRBTS:actHoOptimizationCa=false
...    NRPMRNL-1:miNrRelReportCu=5min

...    NRCELL-1:a3MeasEnabled=rsrp
...    NRCELL-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=3
...    NRCELL-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms320
...    NRCELL-1:filterCoeffSsbRsrp=fc4
...    NRCELL-1:absThreshSsbRsrpConsolidation=80
...    NRCELL-1:sMeasConfigSsbRsrp=20
...    NRCELL-2:a3MeasEnabled=rsrp
...    NRCELL-2:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-2:a3MeasSsbRsrp:a3OffsetSsbRsrp=3
...    NRCELL-2:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms320
...    NRCELL-2:filterCoeffSsbRsrp=fc4
...    NRCELL-2:absThreshSsbRsrpConsolidation=80
...    NRCELL-2:sMeasConfigSsbRsrp=20

...    NRBTS:actIncXn=true
...    XNLINK-1:cPlaneIpAddr=10.0.1.122
...    NRADJGNB-1:administrativeState=Unlocked
...    NRADJGNB-1:gNbIdLength=22
...    NRADJGNB-1:gNodeBId=35
...    NRADJGNB-1:xnLinkRef=1
...    NRADJGNB-1:gnbPlmn:mcc=311|mncLength=3
...    NRADJGNB-1:gnbPlmn:mnc=489|mncLength=3
...    NRADJNRCELL-1:cellDepType=SA
...    NRADJNRCELL-1:fiveGsTac=200
...    NRADJNRCELL-1:gNbId=35
...    NRADJNRCELL-1:gNbIdLength=22
...    NRADJNRCELL-1:lcrId=1
...    NRADJNRCELL-1:nrarfcn=513234
...    NRADJNRCELL-1:physCellId=381
...    NRADJNRCELL-1:gnbPlmn:mcc=311|mncLength=3
...    NRADJNRCELL-1:gnbPlmn:mnc=489|mncLength=3
...    delete:NRADJNRCELL-1:freqBandIndicatorNR

...    NRCELL-1/NRREL-6:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-6:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-6:gNbId=35
...    NRCELL-1/NRREL-6:gNbIdLength=22
...    NRCELL-1/NRREL-6:lcrId=1
...    NRCELL-1/NRREL-6:removeNotAllowed=false
...    NRCELL-1/NRREL-6:gnbPlmn:mcc=311|mncLength=3
...    NRCELL-1/NRREL-6:gnbPlmn:mnc=489|mncLength=3


@{dlToUlContributionRatio50}
...    NRBTS/NRDU-1:dlToUlContributionRatio=50

@{frameStructureType_setting}
...    NRCELL-1:tddFrameStructure:frameStructureType=semiStatic
...    NRCELL-1:prachConfigurationIndex=98
...    NRCELL-1:tddFrameStructure:guardPeriodLength=2Symbols
...    NRCELL-1:tddFrameStructure:ulDlDataSlotRatio=3/7
...    delete:NRCELL-1:tddFrameStructure:lteToNrFrameShift
...    NRCELL-2:tddFrameStructure:frameStructureType=semiStatic
...    NRCELL-2:prachConfigurationIndex=98
...    NRCELL-2:tddFrameStructure:guardPeriodLength=2Symbols
...    NRCELL-2:tddFrameStructure:ulDlDataSlotRatio=3/7
...    delete:NRCELL-2:tddFrameStructure:lteToNrFrameShift

@{dlToUlContributionRatio50 and frameStructureType semiStatic}
...    @{dlToUlContributionRatio50}
...    @{frameStructureType_setting}

@{ulTxSwitchingBoost_18}
...    NRBTS-1:ulTxSwitchingBoost=18

@{Remove_NRREL_TO_CELL13}
...    delete:NRCELL-1/NRREL-3

@{Remove_NRREL_TO_CELL11}
...    delete:NRCELL-1/NRREL-1
...    NRCELL-1/NRREL-3:gNbId=1
...    NRCELL-1/NRREL-3:gNbIdLength=22
...    NRCELL-1/NRREL-3:lcrId=13
...    NRCELL-1/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-3:sCellOperationalMode=dlAndUl
...    NRCELL-1/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-3:gnbPlmn:mncLength=3

${AA_16_UE_1}    SEPARATOR=
...    E9A09000575F5A13160003C5200016093170019C3D0B004D9061CF9863CA160704C060188E01F71B0A303582308682041D211001B5B262AC6873E238F4
...    0CFB027C62471E439F51CF9863CA1607038782E007FE003801FF8003600001C0A83620EB04610D04083C4220032B64C55890E7D813E238F1891C790E7D
...    473E618F28581C0E1E13FFE00000FFF800000D80000702A8D89BAC1184341020E908800C2D931544439F11C788E3D033EC09F18E7CC31E50B0381C3C17
...    003FF001C00FFC001B20000E00365FFFE5FFFE0571F11B582308682041F284400556C98AB0A1CF88E3C60000000000000000000000F013FFE00000FFF8
...    00000D8000070009E3E14000710400308C061180002160205E1E14000710400001058081007011A014404D808236C0005808300040003810C6012202C2
...    507850001C460000061604101801020F41F00078005038280381804A00E000C0480080C07C120040000000200000401000000008000010040000100200
...    000C01000008008000050040020080200800006004000038020010000000400004002000024010000060080000A004000058020010240900400006019C
...    A9ACA9AC14AC14AC19AC15ACA5AC99AC05AC0DAC04AC08AC1DA0682000012CA48080000CB29282000052CA48080001CB29202000092CA48080002CB292
...    020000D2CA48080003CB29202000112CA48080004CB29202000152CA48080005CB29202000192CA480800018B292019A55174AAAA9545D2A8AA0B15416
...    2A83455298AA4D154062A81455268AA0F143C00BC04A8140A05028140A05028140A05028140A05028140A000C10100C018040080118080100202018030
...    080600C02018030404008010100C018202004010080600C101002008040080110080100402018030080600C2010020080403006010020046A87C000408
...    0C10181C282C30344044484C5060646C70747C8494989CA0A4A8B4BD05060B40

${AA_16_UE_2_4}    SEPARATOR=
...    E9A09000575F5A13160003C5200016093170019C3D0B004D9061CF9863CA160704C060188E01F71B0A303582308682041D211001B5B262AC6873E238F4
...    0CFB027C62471E439F51CF9863CA1607038782E007FE003801FF8003600001C0A83620EB04610D04083C4220032B64C55890E7D813E238F1891C790E7D
...    473E618F28581C0E1E13FFE00000FFF800000D80000702A8D89BAC1184341020E908800C2D931544439F11C788E3D033EC09F18E7CC31E50B0381C3C17
...    003FF001C00FFC001B20000E00365FFFE5FFFE0571F11B582308682041F284400556C98AB0A1CF88E3C60000000000000000000000F013FFE00000FFF8
...    00000D800007000DE1E14000710400000858081787850001C46000002160205E1E14000713400001058081007011A014404D808236C000580C10040100
...    3818C6323204C2507850001C4600000616041018010230901E14000710400001858101841001008F41F00078005038280381804A00E000C0480080C07C
...    120040000000200000401000000008000010040000100200000C0100000800800005004002008020080000600400003802001000000040000400200002
...    4010000060080000A004000058020010240900400006019CA9ACA9AC14AC14AC19AC15ACA5AC99AC05AC0DAC04AC08AC1DA0682000012CA48080000CB2
...    9282000052CA48080001CB29202000092CA48080002CB292020000D2CA48080003CB29202000112CA48080004CB29202000152CA48080005CB29202000
...    192CA480800018B292019A55174AAAA9545D2A8AA0B154162A83455298AA4D154062A81455268AA0F143C00BC04A8140A05028140A05028140A0502814
...    0A05028140A000C10100C0180400801080801002020180304040080101002004202004010080600C101002008040080110080100402018030080600C20
...    10020080403006010020046A87C0004080C10181C282C30344044484C5060646C70747C8494989CA0A4A8B4BD05060B4

${AA_16_UE_3}    SEPARATOR=
...    E9A09000575F5A13160003C5200016093170019C3D0B004D9061CF9863CA160704C060188E01F71B0A303582308682041D211001B5B262AC6873E238F4
...    0CFB027C62471E439F51CF9863CA1607038782E007FE003801FF8003600001C0A83620EB04610D04083C4220032B64C55890E7D813E238F1891C790E7D
...    473E618F28581C0E1E13FFE00000FFF800000D80000702A8D89BAC1184341020E908800C2D931544439F11C788E3D033EC09F18E7CC31E50B0381C3C17
...    003FF001C00FFC001B20000E00365FFFE5FFFE0571F11B582308682041F284400556C98AB0A1CF88E3C60000000000000000000000F013FFE00000FFF8
...    00000D8000070009E1E14000710400000858081787850001C4600000216020401C046805101360208DB00012020401000E0431804880B0941E14000711
...    80000185810406004083D07C001E00140E0A00E0601280380030120020301F048010000000080000100400000002000004010000040080000300400002
...    00200001401000802008020000180100000E008004000000100001000800009004000018020000280100001600800409024010000180672A6B2A6B052B
...    052B066B056B296B266B016B036B012B022B07681A0800004B29202000032CA4A0800014B29202000072CA480800024B292020000B2CA480800034B292
...    020000F2CA480800044B29202000132CA480800054B29202000172CA480800064B29202000062CA480669545D2AAAA55174AA2A82C55058AA0D154A62A
...    93455018AA051549A2A83C50F002F012A05028140A05028140A05028140A05028140A0502800304040300601002004202004008080600C101002004040
...    0801080801004020180304040080201002004402004010080600C02018030804008020100C01804008011AA1F000102030406070A0B0C0D10111213141
...    8191B1C1D1F2125262728292A2D2F414182D


*** Test Cases ***
CB012149-SR-AA_ET_16_01_scell selection with select lower index BC and larger bandwidth BC when UL CA feature deactivated
    [Documentation]
    ...    == Precondition: ==
    ...    GNB:
    ...        CELL      TEC    BAND    CHBW    NRARFCN          GSCN    ssbFrequency    PCI    nrCellIdentity
    ...        CELL1     TDD    N41     80M     518598           6480    518430          50     16385
    ...        CELL2     TDD    N78     70M     636666           7880    636576          51     16386
    ...        CELL11    FDD    N66     10M     424000/344000    5300    424090          60     16395
    ...        CELL12    FDD    N71     10M     126900/136100    1587    126990          61     16396
    ...        CELL13    FDD    N66     30M     430920/350920    5385    430830          62     16397
    ...        CELL14    FDD    N71     10M     129000/138200    1611    128910          63     16398

    ...        CB012149 enable/CB009169 disable/ulTxSwitchingBoost=1.8

    ...    UE:
    ...        UE1 (A1 < a1ThresholdSCellAddSsbRsrpTDD/N66 NRREL TO CELL11(10M))
    ...            normal BC:
    ...                BC#1:N41a*-N66a*-N71a-N71a=7500000
    ...                BC#2:N41a*-N66a*=2500000
    ...            ultxswitch BC:
    ...                BC#1:N41a*-N71a*=8800000
    ...                ->bestsolution index 3 ultxswitch BC#1
    ...        UE2 (A1 > a1ThresholdSCellAddSsbRsrpTDD/N66 NRREL TO CELL11(10M))
    ...            normal BC:
    ...                BC#1:N41a*-N66a*
    ...                BC#2:N41a*-N71a*
    ...                BC#3:N41a*-N78a*=12250000
    ...            ultxswitch BC:
    ...                BC#1:N41a*-N71a*=8800000
    ...                BC#2:N41a*-N66a*=8800000
    ...                ->bestsolution index 3 normal BC#3
    ...        UE3 (A1 < a1ThresholdSCellAddSsbRsrpTDD/N66 NRREL TO CELL13(30M))
    ...            normal BC:
    ...                BC#1:N41a*-N66a*=7500000
    ...                BC#2:N41a*-N71a*
    ...            ultxswitch BC:
    ...                BC#1:N41a*-N71a*=8800000
    ...                ->bestsolution index 3 ultxswitch BC#1
    ...        UE4 (A1 < a1ThresholdSCellAddSsbRsrpTDD/N66 NRREL TO CELL13(30M))
    ...            normal BC:
    ...                BC#1:N41a*-N66a*=75000000
    ...                BC#2:N41a*-N71a*
    ...                BC#3:N41a*-N78a*
    ...            ultxswitch BC:
    ...                BC#1:N41a*-N71a*=8800000
    ...                BC#2:N41a*-N66a*=16800000
    ...                ->bestsolution index 5 ultxswitch BC#2
    ...    == Test steps: ==
    ...    step 1. remove neighbor relation to cell13
    ...    step 2. UE1/UE2 register and setup pdu session, report A1 to trigger scell addition
    ...            different BC selsected for different UE,details please check UE cap above
    ...    step 3. remove neighbor relation to cell11 , add neighbor relation to cell13
    ...    step 3. UE3/UE4 register and setup pdu session, report A1 to trigger scell addition
    ...            different BC selsected for different UE,details please check UE cap above
    [Tags]    owner-xu.wang
    OnlineParamChange    ${Remove_NRREL_TO_CELL13}
    UE Register Setup PDU Trigger Scell Addition By A1 Then Deregister    ue_id=1    srsrp_nr=51    ue_capa=${AA_16_UE_1}
    UE Register Setup PDU Trigger Scell Addition By A1 Then Deregister    ue_id=2    srsrp_nr=60    ue_capa=${AA_16_UE_2_4}
    OnlineParamChange    ${Remove_NRREL_TO_CELL11}
    UE Register Setup PDU Trigger Scell Addition By A1 Then Deregister    ue_id=3    srsrp_nr=51    ue_capa=${AA_16_UE_3}
    UE Register Setup PDU Trigger Scell Addition By A1 Then Deregister    ue_id=4    srsrp_nr=51    ue_capa=${AA_16_UE_2_4}
    Check RRC Log    ${CURDIR}${/}A2A_AA_case16${/}a2a.ini

*** Keywords ***
Start BTS With Specified Config Files
    Common Suite Setup
    Setup Airphone Env    tl_type=${GNB_CONFIG}

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be Onair    check_sib=${False}

UE Register And Setup PDU Session
    [Arguments]    ${ue_id}    ${ue_capa}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=1
    Execute Egate Command    ue_register id=${ue_id} ue_nr_capabilities=${ue_capa}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1    QoS Routing Table

Trigger Scell Addition By A1
    [Arguments]    ${ue_id}    ${srsrp_nr}
    ${measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${Cell1_ssbFrequency}    event_type=A1
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${measid} event=A1 srsrp_nr=${srsrp_nr} ssinr_nr=59 srsrq_nr=32
    ...    pass_regexp=rrcReconfigurationComplete

UE Deregister
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s

UE Register Setup PDU Trigger Scell Addition By A1 Then Deregister
    [Arguments]    ${ue_capa}    ${ue_id}    ${srsrp_nr}
    UE Register And Setup PDU Session    ue_id=${ue_id}    ue_capa=${ue_capa}
    Trigger Scell Addition By A1    ue_id=${ue_id}    srsrp_nr=${srsrp_nr}
    UE Deregister    ue_id=${ue_id}
