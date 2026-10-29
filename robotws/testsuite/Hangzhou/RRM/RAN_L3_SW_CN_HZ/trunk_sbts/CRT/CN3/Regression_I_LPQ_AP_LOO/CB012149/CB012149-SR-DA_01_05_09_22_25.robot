*** Settings ***
Documentation
...    author: Lishuo Geng
...    contact: lishuo.geng@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup       Start BTS With Specified Config Files
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_FDD    CLOUD_5G_I_LPQ_AP_LOO
...               team-CN3ET    owner-annie.nie    release-SBTS24R3    CB012149
Resource    ../../../../../resources/DevHZ5_resource.robot

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
...    @{CB009169_enable}
...    @{CA}
...    @{NRREL}
...    @{Mobillity}
...    @{Others}
...    @{gscn_Arfcn}
...    @{5GC000704}
...    @{dlToUlContributionRatio50 and frameStructureType semiStatic}
...    @{BWP_config}
${Cell1_ssbFrequency}    518430
${Cell2_ssbFrequency}    636576
${Cell11_ssbFrequency}    423850
${Cell12_ssbFrequency}    126990
${Cell13_ssbFrequency}    430830
${Cell14_ssbFrequency}    128910

${carrierAggregationSupportList_with_Ul}    SEPARATOR=
...    ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Any_Sa,ca_Fdd_Fdd,ca_Fr1Tdd_Any_Sa,
...    ca_Fdd_Fr1Tdd_Nsa,ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Fdd_Sa_WithUl

@{CB012149_enable}
...    NRBTS/NRDU-1:ulTxSwitchingSupportList=ca_Fr1T_F_Sa_switchedUl
...    NRBTS:ulTxSwitchingBoost=20
...    NRCELL-1:weightForSCellSelection=50
...    NRCELL-2:weightForSCellSelection=50
...    NRCELL-11:weightForSCellSelection=50
...    NRCELL-12:weightForSCellSelection=50
...    NRCELL-13:weightForSCellSelection=50
...    NRCELL-14:weightForSCellSelection=50

@{CB009169_enable}
...    NRBTS/NRDU-1:carrierAggregationSupportList=${carrierAggregationSupportList_with_Ul}
...    NRBTS/NRDU-1:dlToUlContributionRatio=50
...    NRBTS/NRDRB_RLC_AM-1:ulTReassemblyIBCA=40
...    NRCELL:maxNumScellsDlFr1=4
...    NRBTS/NRDRB_RLC_AM-2:ulTReassemblyIBCA=40
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
...    NRCELL-11/NRCELL_FDD-1:chBwDl=20MHz
...    NRCELL-11/NRCELL_FDD-1:chBwUl=20MHz
...    NRCELL-11:gscnOrSsPbchArfcn=5297

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
...    NRCELL:pucchModeSelect=longPucch
...    NRCELL:actBeamforming=false
...    NRBTS:actMultipleDedicatedBWPs=false

...    NRBTS:actMultiDrbNSA=true
...    NRBTS:actIncXn=true
...    NRBTS:actConflictConfiguration=true
...    NRBTS:rrcReestabTypeSA=sameGNB
...    NRBTS:tWaitingRlRecover=4000ms
...    NRBTS:actDrbDrx=false
...    NRCELL:actCDrx=true
#...    NRPMRNL:miNrOranTrxStats=disabled
@{CA}
...    NRBTS/NRDU-1:actConnectedModeMobilityCA=true

...    NRBTS:actSlowPrbPooling=true
...    NRBTS:actConnRrcPooling=true
...    NRBTS:actScheUePooling=true

...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS:actMeasBasedSCellAdditionNsa=true
...    NRCELL:a2MeasSCellRelEnabled=rsrp
...    NRCELL:a1MeasSCellAddEnabled=rsrp
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=50
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=60
...    NRCELL:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=40

...    NRBTS/NRDU-1:flexibleCAMode=NumberCellAmount

...    NRBTS:actHoOptimizationCa=true
...    NRBTS:sCellActivationMethod=bufferBased
...    NRBTS:actBcsCheck=disabled
...    NRCELL:allowUnsuppBcOrBcs=accept unknown band combinations,accept unknown BCSs
...    NRCELL:a1MeasPCellSwitchEnabled=rsrp
...    NRCELL:a2MeasPCellSwitchEnabled=rsrp


...    NRCELL:a1MeasPCellSwitchSsbRsrp:a1TimeToTriggerPCellSwitchSsbRsrp=480ms
...    NRCELL:a1MeasPCellSwitchSsbRsrp:a1HysteresisPCellSwitchSsbRsrp=0
...    NRCELL:a1MeasPCellSwitchSsbRsrp:a1ThresholdPCellSwitchSsbRsrp=60
...    NRCELL:a2MeasPCellSwitchSsbRsrp:a2TimeToTriggerPCellSwitchSsbRsrp=480ms
...    NRCELL:a2MeasPCellSwitchSsbRsrp:a2HysteresisPCellSwitchSsbRsrp=0
...    NRCELL:a2MeasPCellSwitchSsbRsrp:a2ThresholdPCellSwitchSsbRsrp=40
...    NRCELL:a2MeasPCellSwitchSsbRsrp:pCellSwitchOffsetSsbRsrp=0
...    NRCELL:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms

...    NRCELL:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0
...    NRCELL:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=2560ms


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

...    NRCELL-1/NRHOIF-5:a1BasedPCellSwitchEnabled=true
...    NRCELL-1/NRHOIF-5:a2BasedPCellSwitchEnabled=true
...    NRCELL-1/NRHOIF-5:a2BasedPCellSwitchPriority=1
...    NRCELL-1/NRHOIF-5:a3MeasEnabled=rsrp
...    NRCELL-1/NRHOIF-5:cellDepType=SA+NSA
...    NRCELL-1/NRHOIF-5:freqBandIndicatorNR=71
...    NRCELL-1/NRHOIF-5:ifhoSsbScs=15KHz
#...    NRCELL-1/NRHOIF-5:scs=30 KHz
...    NRCELL-1/NRHOIF-5:ifhoSsbSmtcDuration=sf5
...    NRCELL-1/NRHOIF-5:ifhoSsbSmtcPeriodicity=sf20
...    NRCELL-1/NRHOIF-5:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-5:ssbFrequency=126530
...    NRCELL-1/NRHOIF-5:thresholdPCellSwitchTargetRsrp=60
...    NRCELL-1/NRHOIF-5:thresholdPCellSwitchTargetRsrq=20
...    NRCELL-1/NRHOIF-5:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms320
...    NRCELL-1/NRHOIF-5:a3MeasSsbRsrp:a3OffsetSsbRsrp=5
...    NRCELL-1/NRHOIF-5:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0


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
...    NRADJNRCELL-1:nrarfcn=126530
...    NRADJNRCELL-1:physCellId=381
...    NRADJNRCELL-1:gnbPlmn:mcc=311|mncLength=3
...    NRADJNRCELL-1:gnbPlmn:mnc=489|mncLength=3
...    NRADJNRCELL-1:freqBandIndicatorNR=71

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


${disable_12149}    NRBTS/NRDU-1:ulTxSwitchingSupportList=none
${disable_81817}    NRBTS:actHighestEstNrTputBcSel=false

@{CB009059}
...    NRCELL:actVoNR=true
...    NRCELL:actEnhancedVoNR=true
...    NRBTS:actDrbProfileForCellAggrLevel=FR1_SA
...    NRBTS/NRDRB-10:cellAggrLevel=FR1 CA eligible    #5QI-5
...    NRBTS/NRDRB-11:cellAggrLevel=Not FR1 CA eligible    #5QI-6
...    NRBTS/NRDRB-12:cellAggrLevel=FR1 CA incompatible    #5QI-7

@{BWP_config}
...    @{TDD_BWP_70M}
...    @{TDD_BWP_50M_cell1}
...    @{TDD_BWP_60M}
...    @{TDD_BWP_50M_cell2}
...    @{FDD_BWP_25M}
...    @{FDD_BWP_20M}
...    @{COMMON_BWP}
...    @{FDD_BWP_30M_full}
...    NRBTS:actMultipleDedicatedBWPs=true
...    NRCELL-1:actEnhMultipleDedicatedBWPs=true
...    NRCELL-1:msg1FrequencyStart=46
...    NRCELL-2:msg1FrequencyStart=46
...    NRCELL-1:cellBwpList:cellBwpId=0|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-3
...    NRCELL-1:cellBwpList:cellBwpId=1|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-4
...    NRCELL-1:cellBwpList:cellBwpId=2|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-52    #70M
...    NRCELL-1:cellBwpList:cellBwpId=3|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-53    #50M

...    NRCELL-2:cellBwpList:cellBwpId=0|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-3
...    NRCELL-2:cellBwpList:cellBwpId=1|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-4
...    NRCELL-2:cellBwpList:cellBwpId=2|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-54    #60M
...    NRCELL-2:cellBwpList:cellBwpId=3|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-55    #50M

...    NRCELL-13:cellBwpList:cellBwpId=0|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-1
...    NRCELL-13:cellBwpList:cellBwpId=1|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-7
...    NRCELL-13:cellBwpList:cellBwpId=2|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-56    #20M
...    NRCELL-13:cellBwpList:cellBwpId=3|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-57    #25M

@{BWP_CONFIG_Case25}
...    delete:NRCELL-1:cellBwpList:cellBwpId=2
...    delete:NRCELL-13:cellBwpList:cellBwpId=3
...    NRBTS/BWP_PROFILE-1:locationAndBandwidthDl:cRbSizeDl=n106
...    NRBTS/BWP_PROFILE-3:locationAndBandwidthDl:cRbSizeDl=n133
...    NRBTS:actMultipleDedicatedBWPs=true
...    NRCELL:actEnhMultipleDedicatedBWPs=true
...    NRCELL-1:msg1FrequencyStart=46
...    NRCELL-2:msg1FrequencyStart=46
...    NRCELL-1:cellBwpList:cellBwpId=0|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-3
...    NRCELL-1:cellBwpList:cellBwpId=1|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-4
...    NRCELL-1:cellBwpList:cellBwpId=3|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-53    #50M

...    NRCELL-2:cellBwpList:cellBwpId=0|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-8
...    NRCELL-2:cellBwpList:cellBwpId=1|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-4
...    NRCELL-2:cellBwpList:cellBwpId=2|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-54    #60M

...    NRCELL-13:cellBwpList:cellBwpId=0|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-1
...    NRCELL-13:cellBwpList:cellBwpId=1|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-7
...    NRCELL-13:cellBwpList:cellBwpId=2|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-56    #20M


@{COMMON_BWP}
...    NRBTS/BWP_PROFILE-1:locationAndBandwidthDl:cRbSizeDl=n106
...    NRBTS/BWP_PROFILE-1:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-1:locationAndBandwidthUl:cRbSizeUl=sameAsDl
...    NRBTS/BWP_PROFILE-1:locationAndBandwidthUl:cRbStartUl=sameAsDl

...    NRBTS/BWP_PROFILE-3:locationAndBandwidthDl:cRbSizeDl=n133
...    NRBTS/BWP_PROFILE-3:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-3:locationAndBandwidthUl:cRbSizeUl=sameAsDl
...    NRBTS/BWP_PROFILE-3:locationAndBandwidthUl:cRbStartUl=sameAsDl
...    NRBTS/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=2|searchSpaceId=1
...    NRBTS/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=2|searchSpaceId=3
...    NRBTS/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceId=1
...    NRBTS/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceId=3
...    NRBTS/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=1
...    NRBTS/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=3
...    NRBTS/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=3

...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=2|searchSpaceId=4
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=2|searchSpaceId=6
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceId=4
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceId=6
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=4
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=6
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=6

...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:coresetId=1
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cRbStart=0
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:duration=1
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:interleaverSize=none
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:regBundleSize=n6
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=120
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-0-And-1-0|coresetId=0
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|coresetId=0
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=0
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=0
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=0
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=0
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|coresetId=0
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=0
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|coresetId=0
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=7|coresetId=0
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|coresetId=0
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=0
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|coresetId=1
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|coresetId=1
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=1
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=1
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=1
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=1
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n5|coresetId=1
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=1
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|coresetId=1
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=8|coresetId=1
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|coresetId=1
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=1
...    NRBTS/BWP_PROFILE-4/PDSCH-1:pdschRat0RbgConfig=config1
#case25 cell2 initial BWP
...    NRBTS/BWP_PROFILE-8:bwpType=initial
...    NRBTS/BWP_PROFILE-8:locationAndBandwidthDl:cRbSizeDl=n162
...    NRBTS/BWP_PROFILE-8:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-8:locationAndBandwidthUl:cRbSizeUl=sameAsDl
...    NRBTS/BWP_PROFILE-8:locationAndBandwidthUl:cRbStartUl=sameAsDl
...    NRBTS/BWP_PROFILE-8/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-8/PDCCH-1:dciDedicatedAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-8/PDCCH-1:dciPagingAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-8/PDCCH-1:dciRaCompletionAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-8/PDCCH-1:dciRaMsg2AggregationLevel=AL4
...    NRBTS/BWP_PROFILE-8/PDCCH-1:dciSiAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-8/PDCCH-1:downgradeAL16toAL8=notAllowed
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=2|searchSpaceId=1
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=1
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceId=1
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=1
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=2
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=2|searchSpaceId=3
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=3
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceId=3
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=3
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=3


#70M
@{TDD_BWP_70M}
...    NRBTS/BWP_PROFILE-52:bwpType=dedicated
...    NRBTS/BWP_PROFILE-52:locationAndBandwidthDl:cRbSizeDl=n189
...    NRBTS/BWP_PROFILE-52:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-52:locationAndBandwidthUl:cRbSizeUl=sameAsDl
...    NRBTS/BWP_PROFILE-52:locationAndBandwidthUl:cRbStartUl=sameAsDl
...    NRBTS/BWP_PROFILE-52/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-52/PDCCH-1:dciDedicatedAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-52/PDCCH-1:dciPagingAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-52/PDCCH-1:dciRaCompletionAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-52/PDCCH-1:dciRaMsg2AggregationLevel=AL4
...    NRBTS/BWP_PROFILE-52/PDCCH-1:dciSiAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-52/PDCCH-1:downgradeAL16toAL8=notAllowed
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=2|searchSpaceId=9
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=9
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceId=9
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=9
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=10
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=10
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=10
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=10
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=10
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=2|searchSpaceId=11
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=11
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceId=11
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=11
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cceToRegMapping=nonInterleaved
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:coresetId=4
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cRbStart=0
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:duration=1
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:interleaverSize=none
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:regBundleSize=n6
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=120
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-0-And-1-0|coresetId=0
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|coresetId=0
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=0
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=0
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=0
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=0
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|coresetId=0
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=0
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|coresetId=0
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=12|coresetId=0
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|coresetId=0
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=0
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|coresetId=4
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|coresetId=4
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=4
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=4
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=4
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=4
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n5|coresetId=4
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=4
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|coresetId=4
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=13|coresetId=4
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|coresetId=4
...    NRBTS/BWP_PROFILE-52/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=4
...    NRBTS/BWP_PROFILE-52/PDSCH-1:pdschRat0RbgConfig=config1
#50M
@{TDD_BWP_50M_cell1}
...    NRBTS/BWP_PROFILE-53:bwpType=dedicated
...    NRBTS/BWP_PROFILE-53:locationAndBandwidthDl:cRbSizeDl=n133
...    NRBTS/BWP_PROFILE-53:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-53:locationAndBandwidthUl:cRbSizeUl=sameAsDl
...    NRBTS/BWP_PROFILE-53:locationAndBandwidthUl:cRbStartUl=sameAsDl
...    NRBTS/BWP_PROFILE-53/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-53/PDCCH-1:dciDedicatedAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-53/PDCCH-1:dciPagingAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-53/PDCCH-1:dciRaCompletionAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-53/PDCCH-1:dciRaMsg2AggregationLevel=AL4
...    NRBTS/BWP_PROFILE-53/PDCCH-1:dciSiAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-53/PDCCH-1:downgradeAL16toAL8=notAllowed
...    NRBTS/BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=14
...    NRBTS/BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=14
...    NRBTS/BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=2|searchSpaceId=14
...    NRBTS/BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=14
...    NRBTS/BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=14
...    NRBTS/BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=14
...    NRBTS/BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=14
...    NRBTS/BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=14
...    NRBTS/BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceId=14
...    NRBTS/BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=14
...    NRBTS/BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=14
...    NRBTS/BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=15
...    NRBTS/BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=15
...    NRBTS/BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=15
...    NRBTS/BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=15
...    NRBTS/BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=15
...    NRBTS/BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=15
...    NRBTS/BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=15
...    NRBTS/BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=15
...    NRBTS/BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=15
...    NRBTS/BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=15
...    NRBTS/BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=15
...    NRBTS/BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=16
...    NRBTS/BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=16
...    NRBTS/BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=2|searchSpaceId=16
...    NRBTS/BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=16
...    NRBTS/BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=16
...    NRBTS/BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=16
...    NRBTS/BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=16
...    NRBTS/BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=16
...    NRBTS/BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceId=16
...    NRBTS/BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=16
...    NRBTS/BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=16
...    NRBTS/BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cceToRegMapping=nonInterleaved
...    NRBTS/BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:coresetId=7
...    NRBTS/BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cRbStart=0
...    NRBTS/BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:duration=1
...    NRBTS/BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:interleaverSize=none
...    NRBTS/BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:regBundleSize=n6
...    NRBTS/BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=120
...    NRBTS/BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-0-And-1-0|coresetId=0
...    NRBTS/BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|coresetId=0
...    NRBTS/BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=0
...    NRBTS/BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=0
...    NRBTS/BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=0
...    NRBTS/BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=0
...    NRBTS/BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n4|coresetId=0
...    NRBTS/BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=0
...    NRBTS/BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|coresetId=0
...    NRBTS/BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=17|coresetId=0
...    NRBTS/BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|coresetId=0
...    NRBTS/BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=0
...    NRBTS/BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|coresetId=7
...    NRBTS/BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|coresetId=7
...    NRBTS/BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=7
...    NRBTS/BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=7
...    NRBTS/BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=7
...    NRBTS/BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=7
...    NRBTS/BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n5|coresetId=7
...    NRBTS/BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=7
...    NRBTS/BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|coresetId=7
...    NRBTS/BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=18|coresetId=7
...    NRBTS/BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|coresetId=7
...    NRBTS/BWP_PROFILE-53/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=7
...    NRBTS/BWP_PROFILE-53/PDSCH-1:pdschRat0RbgConfig=config1

#60M
@{TDD_BWP_60M}
...    NRBTS/BWP_PROFILE-54:bwpType=dedicated
...    NRBTS/BWP_PROFILE-54:locationAndBandwidthDl:cRbSizeDl=n162
...    NRBTS/BWP_PROFILE-54:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-54:locationAndBandwidthUl:cRbSizeUl=sameAsDl
...    NRBTS/BWP_PROFILE-54:locationAndBandwidthUl:cRbStartUl=sameAsDl
...    NRBTS/BWP_PROFILE-54/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-54/PDCCH-1:dciDedicatedAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-54/PDCCH-1:dciPagingAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-54/PDCCH-1:dciRaCompletionAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-54/PDCCH-1:dciRaMsg2AggregationLevel=AL4
...    NRBTS/BWP_PROFILE-54/PDCCH-1:dciSiAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-54/PDCCH-1:downgradeAL16toAL8=notAllowed
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=2|searchSpaceId=9
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=9
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceId=9
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=9
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=10
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=10
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=10
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=10
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=10
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=2|searchSpaceId=11
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=11
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceId=11
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=11
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cceToRegMapping=nonInterleaved
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:coresetId=4
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cRbStart=0
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:duration=1
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:interleaverSize=none
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:regBundleSize=n6
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=120
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-0-And-1-0|coresetId=0
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|coresetId=0
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=0
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=0
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=0
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=0
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n4|coresetId=0
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=0
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|coresetId=0
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=12|coresetId=0
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|coresetId=0
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=0
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|coresetId=4
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|coresetId=4
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=4
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=4
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=4
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=4
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n5|coresetId=4
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=4
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|coresetId=4
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=13|coresetId=4
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|coresetId=4
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=4
...    NRBTS/BWP_PROFILE-54/PDSCH-1:pdschRat0RbgConfig=config1
#50M
@{TDD_BWP_50M_cell2}
...    NRBTS/BWP_PROFILE-55:bwpType=dedicated
...    NRBTS/BWP_PROFILE-55:locationAndBandwidthDl:cRbSizeDl=n133
...    NRBTS/BWP_PROFILE-55:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-55:locationAndBandwidthUl:cRbSizeUl=sameAsDl
...    NRBTS/BWP_PROFILE-55:locationAndBandwidthUl:cRbStartUl=sameAsDl
...    NRBTS/BWP_PROFILE-55/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-55/PDCCH-1:dciDedicatedAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-55/PDCCH-1:dciPagingAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-55/PDCCH-1:dciRaCompletionAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-55/PDCCH-1:dciRaMsg2AggregationLevel=AL4
...    NRBTS/BWP_PROFILE-55/PDCCH-1:dciSiAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-55/PDCCH-1:downgradeAL16toAL8=notAllowed
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=14
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=14
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=2|searchSpaceId=14
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=14
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=14
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=14
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=14
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=14
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceId=14
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=14
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=14
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=15
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=15
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=15
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=15
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=15
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=15
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=15
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=15
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=15
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=15
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=15
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=16
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=16
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=2|searchSpaceId=16
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=16
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=16
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=16
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=16
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=16
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceId=16
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=16
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=16
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cceToRegMapping=nonInterleaved
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:coresetId=7
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cRbStart=0
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:duration=1
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:interleaverSize=none
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:regBundleSize=n6
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=120
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-0-And-1-0|coresetId=0
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|coresetId=0
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=0
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=0
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=0
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=0
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n4|coresetId=0
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=0
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|coresetId=0
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=17|coresetId=0
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|coresetId=0
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=0
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|coresetId=7
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|coresetId=7
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=7
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=7
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=7
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=7
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n5|coresetId=7
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=7
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|coresetId=7
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=18|coresetId=7
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|coresetId=7
...    NRBTS/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=7
...    NRBTS/BWP_PROFILE-55/PDSCH-1:pdschRat0RbgConfig=config1
#30M
@{FDD_BWP_30M_full}
...    NRBTS/BWP_PROFILE-7:bwpType=dedicated
...    NRBTS/BWP_PROFILE-7:locationAndBandwidthDl:cRbSizeDl=allRb
...    NRBTS/BWP_PROFILE-7:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-7:locationAndBandwidthUl:cRbSizeUl=sameAsDl
...    NRBTS/BWP_PROFILE-7:locationAndBandwidthUl:cRbStartUl=sameAsDl
...    NRBTS/BWP_PROFILE-7/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-7/PDCCH-1:dciDedicatedAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-7/PDCCH-1:dciPagingAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-7/PDCCH-1:dciRaCompletionAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-7/PDCCH-1:dciRaMsg2AggregationLevel=AL4
...    NRBTS/BWP_PROFILE-7/PDCCH-1:dciSiAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-7/PDCCH-1:downgradeAL16toAL8=notAllowed
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=4
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=4
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=4
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=4
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n4|searchSpaceId=5
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=6
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=6
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=6
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=6
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cceToRegMapping=nonInterleaved
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:coresetId=1
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cRbStart=0
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:duration=1
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:interleaverSize=none
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:regBundleSize=n6
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=120
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-0-And-1-0|coresetId=0
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|coresetId=0
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=0
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=0
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=0
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=0
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|coresetId=0
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=0
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|coresetId=0
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=7|coresetId=0
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|coresetId=0
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=0
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|coresetId=1
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|coresetId=1
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=1
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=1
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=1
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=1
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n5|coresetId=1
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=1
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|coresetId=1
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=8|coresetId=1
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|coresetId=1
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=1
...    NRBTS/BWP_PROFILE-7/PDSCH-1:pdschRat0RbgConfig=config1
#20M
@{FDD_BWP_20M}
...    NRBTS/BWP_PROFILE-56:bwpType=dedicated
...    NRBTS/BWP_PROFILE-56:locationAndBandwidthDl:cRbSizeDl=n106
...    NRBTS/BWP_PROFILE-56:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-56:locationAndBandwidthUl:cRbSizeUl=sameAsDl
...    NRBTS/BWP_PROFILE-56:locationAndBandwidthUl:cRbStartUl=sameAsDl
...    NRBTS/BWP_PROFILE-56/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-56/PDCCH-1:dciDedicatedAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-56/PDCCH-1:dciPagingAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-56/PDCCH-1:dciRaCompletionAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-56/PDCCH-1:dciRaMsg2AggregationLevel=AL4
...    NRBTS/BWP_PROFILE-56/PDCCH-1:dciSiAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-56/PDCCH-1:downgradeAL16toAL8=notAllowed
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=9
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=9
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=9
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=9
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=10
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=10
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=10
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=10
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=10
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=11
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=11
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=11
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=11
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cceToRegMapping=nonInterleaved
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:coresetId=4
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cRbStart=0
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:duration=1
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:interleaverSize=none
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:regBundleSize=n6
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=120
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-0-And-1-0|coresetId=0
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|coresetId=0
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=0
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=0
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=0
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=0
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n4|coresetId=0
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=0
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|coresetId=0
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=12|coresetId=0
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|coresetId=0
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=0
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|coresetId=4
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|coresetId=4
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=4
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=4
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=4
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=4
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n4|coresetId=4
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=4
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|coresetId=4
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=13|coresetId=4
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|coresetId=4
...    NRBTS/BWP_PROFILE-56/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=4
...    NRBTS/BWP_PROFILE-56/PDSCH-1:pdschRat0RbgConfig=config1

#25M
@{FDD_BWP_25M}
...    NRBTS/BWP_PROFILE-57:bwpType=dedicated
...    NRBTS/BWP_PROFILE-57:locationAndBandwidthDl:cRbSizeDl=n133
...    NRBTS/BWP_PROFILE-57:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-57:locationAndBandwidthUl:cRbSizeUl=sameAsDl
...    NRBTS/BWP_PROFILE-57:locationAndBandwidthUl:cRbStartUl=sameAsDl
...    NRBTS/BWP_PROFILE-57/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-57/PDCCH-1:dciDedicatedAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-57/PDCCH-1:dciPagingAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-57/PDCCH-1:dciRaCompletionAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-57/PDCCH-1:dciRaMsg2AggregationLevel=AL4
...    NRBTS/BWP_PROFILE-57/PDCCH-1:dciSiAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-57/PDCCH-1:downgradeAL16toAL8=notAllowed
...    NRBTS/BWP_PROFILE-57/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=14
...    NRBTS/BWP_PROFILE-57/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=14
...    NRBTS/BWP_PROFILE-57/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=14
...    NRBTS/BWP_PROFILE-57/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=14
...    NRBTS/BWP_PROFILE-57/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=14
...    NRBTS/BWP_PROFILE-57/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=14
...    NRBTS/BWP_PROFILE-57/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=14
...    NRBTS/BWP_PROFILE-57/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=14
...    NRBTS/BWP_PROFILE-57/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=14
...    NRBTS/BWP_PROFILE-57/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=14
...    NRBTS/BWP_PROFILE-57/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=14
...    NRBTS/BWP_PROFILE-57/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=15
...    NRBTS/BWP_PROFILE-57/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=15
...    NRBTS/BWP_PROFILE-57/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=15
...    NRBTS/BWP_PROFILE-57/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=15
...    NRBTS/BWP_PROFILE-57/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=15
...    NRBTS/BWP_PROFILE-57/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=15
...    NRBTS/BWP_PROFILE-57/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=15
...    NRBTS/BWP_PROFILE-57/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=15
...    NRBTS/BWP_PROFILE-57/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=15
...    NRBTS/BWP_PROFILE-57/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=15
...    NRBTS/BWP_PROFILE-57/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=15
...    NRBTS/BWP_PROFILE-57/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=16
...    NRBTS/BWP_PROFILE-57/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=16
...    NRBTS/BWP_PROFILE-57/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=16
...    NRBTS/BWP_PROFILE-57/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=16
...    NRBTS/BWP_PROFILE-57/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=16
...    NRBTS/BWP_PROFILE-57/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=16
...    NRBTS/BWP_PROFILE-57/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=16
...    NRBTS/BWP_PROFILE-57/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=16
...    NRBTS/BWP_PROFILE-57/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=16
...    NRBTS/BWP_PROFILE-57/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=16
...    NRBTS/BWP_PROFILE-57/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=16
...    NRBTS/BWP_PROFILE-57/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cceToRegMapping=nonInterleaved
...    NRBTS/BWP_PROFILE-57/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:coresetId=7
...    NRBTS/BWP_PROFILE-57/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cRbStart=0
...    NRBTS/BWP_PROFILE-57/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:duration=1
...    NRBTS/BWP_PROFILE-57/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:interleaverSize=none
...    NRBTS/BWP_PROFILE-57/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:regBundleSize=n2
...    NRBTS/BWP_PROFILE-57/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=78
...    NRBTS/BWP_PROFILE-57/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-0-And-1-0|coresetId=0
...    NRBTS/BWP_PROFILE-57/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|coresetId=0
...    NRBTS/BWP_PROFILE-57/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=0
...    NRBTS/BWP_PROFILE-57/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=0
...    NRBTS/BWP_PROFILE-57/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=0
...    NRBTS/BWP_PROFILE-57/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=0
...    NRBTS/BWP_PROFILE-57/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|coresetId=0
...    NRBTS/BWP_PROFILE-57/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=0
...    NRBTS/BWP_PROFILE-57/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|coresetId=0
...    NRBTS/BWP_PROFILE-57/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=17|coresetId=0
...    NRBTS/BWP_PROFILE-57/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|coresetId=0
...    NRBTS/BWP_PROFILE-57/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=0
...    NRBTS/BWP_PROFILE-57/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|coresetId=7
...    NRBTS/BWP_PROFILE-57/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|coresetId=7
...    NRBTS/BWP_PROFILE-57/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=7
...    NRBTS/BWP_PROFILE-57/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=7
...    NRBTS/BWP_PROFILE-57/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=7
...    NRBTS/BWP_PROFILE-57/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=7
...    NRBTS/BWP_PROFILE-57/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n3|coresetId=7
...    NRBTS/BWP_PROFILE-57/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=7
...    NRBTS/BWP_PROFILE-57/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|coresetId=7
...    NRBTS/BWP_PROFILE-57/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=18|coresetId=7
...    NRBTS/BWP_PROFILE-57/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|coresetId=7
...    NRBTS/BWP_PROFILE-57/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=7
...    NRBTS/BWP_PROFILE-57/PDSCH-1:pdschRat0RbgConfig=config1


@{case5_enable_9169_12147_81817}
...    NRBTS/NRDU-1:carrierAggregationSupportList=${carrierAggregationSupportList_with_Ul}
...    NRBTS/NRDU-1:ulTxSwitchingSupportList=ca_Fr1T_F_Sa_switchedUl
...    NRBTS:actHighestEstNrTputBcSel=true
...    NRBTS:ulTxSwitchingBoost=10
...    NRCELL:a1MeasSCellAddEnabled=rsrp
...    delete:NRCELL-1/NRREL-1
@{case25_9169_12149_enable_81817_disable}
...    NRBTS/NRDU-1:carrierAggregationSupportList=${carrierAggregationSupportList_with_Ul}
...    NRBTS/NRDU-1:ulTxSwitchingSupportList=ca_Fr1T_F_Sa_switchedUl
...    NRBTS:actHighestEstNrTputBcSel=false
...    NRBTS:ulTxSwitchingBoost=20
...    NRCELL:a1MeasSCellAddEnabled=rsrp
...    NRCELL-11:weightForSCellSelection=25
...    NRBTS:actDrbProfileForCellAggrLevel=disabled
...    @{NRREL}
...    @{BWP_CONFIG_Case25}
@{case1_9169_12149_enable_81817_disable}
...    NRBTS/NRDU-1:carrierAggregationSupportList=${carrierAggregationSupportList_with_Ul}
...    NRBTS/NRDU-1:ulTxSwitchingSupportList=ca_Fr1T_F_Sa_switchedUl
...    NRBTS:actHighestEstNrTputBcSel=false
...    NRBTS:ulTxSwitchingBoost=10
...    NRCELL:a1MeasSCellAddEnabled=rsrp
...    NRCELL:weightForSCellSelection=50
...    @{NRREL}
...    NRBTS:actMultipleDedicatedBWPs=false
...    NRBTS:actDrbProfileForCellAggrLevel=disabled
...    NRCELL:actEnhMultipleDedicatedBWPs=false
...    NRBTS/BWP_PROFILE-3:locationAndBandwidthDl:cRbSizeDl=allRb
...    NRBTS/BWP_PROFILE-1:locationAndBandwidthDl:cRbSizeDl=allRb
...    delete:NRCELL-1:cellBwpList:cellBwpId=2
...    delete:NRCELL-1:cellBwpList:cellBwpId=3
...    delete:NRCELL-2:cellBwpList:cellBwpId=2
...    delete:NRCELL-2:cellBwpList:cellBwpId=3
...    delete:NRCELL-13:cellBwpList:cellBwpId=2
...    delete:NRCELL-13:cellBwpList:cellBwpId=3
@{case9_9169_12149_9059_enable_81817_disable}
...    NRBTS/NRDU-1:carrierAggregationSupportList=${carrierAggregationSupportList_with_Ul}
...    NRBTS/NRDU-1:ulTxSwitchingSupportList=ca_Fr1T_F_Sa_switchedUl
...    NRBTS:actHighestEstNrTputBcSel=false
...    NRBTS:ulTxSwitchingBoost=20
...    NRCELL:a1MeasSCellAddEnabled=rsrp
...    NRCELL:weightForSCellSelection=50
...    NRBTS:actMultipleDedicatedBWPs=false
...    NRCELL:actEnhMultipleDedicatedBWPs=false
...    NRBTS/BWP_PROFILE-3:locationAndBandwidthDl:cRbSizeDl=allRb
...    NRBTS/BWP_PROFILE-1:locationAndBandwidthDl:cRbSizeDl=allRb
...    delete:NRCELL-1:cellBwpList:cellBwpId=2
...    delete:NRCELL-1:cellBwpList:cellBwpId=3
...    delete:NRCELL-2:cellBwpList:cellBwpId=2
...    delete:NRCELL-2:cellBwpList:cellBwpId=3
...    delete:NRCELL-13:cellBwpList:cellBwpId=2
...    delete:NRCELL-13:cellBwpList:cellBwpId=3
...    @{CB009059}
@{case22_9169_12149_enable_81817_disable}
...    NRBTS/NRDU-1:carrierAggregationSupportList=${carrierAggregationSupportList_with_Ul}
...    NRBTS/NRDU-1:ulTxSwitchingSupportList=ca_Fr1T_F_Sa_switchedUl
...    NRBTS:actHighestEstNrTputBcSel=false
...    NRBTS:ulTxSwitchingBoost=20
...    NRCELL:a1MeasSCellAddEnabled=rsrp
...    NRCELL:weightForSCellSelection=50
...    NRBTS:actMultipleDedicatedBWPs=false
...    NRCELL:actEnhMultipleDedicatedBWPs=false
...    NRBTS:actDrbProfileForCellAggrLevel=disabled
...    NRBTS/BWP_PROFILE-3:locationAndBandwidthDl:cRbSizeDl=allRb
...    NRBTS/BWP_PROFILE-1:locationAndBandwidthDl:cRbSizeDl=allRb
...    delete:NRCELL-1:cellBwpList:cellBwpId=2
...    delete:NRCELL-1:cellBwpList:cellBwpId=3
...    delete:NRCELL-2:cellBwpList:cellBwpId=2
...    delete:NRCELL-2:cellBwpList:cellBwpId=3
...    delete:NRCELL-13:cellBwpList:cellBwpId=2
...    delete:NRCELL-13:cellBwpList:cellBwpId=3
@{ulTxSwitchingBoost_1.8_no_NRREL3}
...    NRBTS:ulTxSwitchingBoost=18
...    delete:NRCELL-1/NRREL-3
@{ulTxSwitchingBoost_eq_1}
...    NRBTS:ulTxSwitchingBoost=10
${enable_81817}
...    NRBTS:actHighestEstNrTputBcSel=true
@{ADD_NRREL_BACK}
...    NRCELL-1/NRREL-3:gNbId=1
...    NRCELL-1/NRREL-3:gNbIdLength=22
...    NRCELL-1/NRREL-3:lcrId=13
...    NRCELL-1/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-3:sCellOperationalMode=dlAndUl
...    NRCELL-1/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-3:gnbPlmn:mncLength=3
...    NRBTS:ulTxSwitchingBoost=20
${case1_UE_1_3}    SEPARATOR=
...    E9A09000575F5A13160003C5200016093170019C3D0B004D9061CF9863CA160704C060188E02771B0A303582308682041D211001B5B262AC6873E238F40CFB027C62471E4
...    39F51CF9863CA1607038782E007FE003801FF8003600001C0A83620EB04610D04083C4220032B64C55890E7D813E238F1891C790E7D473E618F28581C0E1E13FFE00000FF
...    F800000D80000702A8D89BAC1184341020E908800C2D931544439F11C788E3D033EC09F18E7CC31E50B0381C3C17003FF001C00FFC001B20000E00365FFFE5FFFE0551B13
...    3582308682041D21100185B262A88873E238F11C7A067D813E31CF9863CA1607038782E007FE003801FF8003640001C006CBFFFCBFFFC0AE3E236B04610D04083E508800A
...    AD931561439F11C78C0000000000000000000001E027FFC00001FFF000001B00000E002383C28000C26800002C040B85C28000E2080071180000085808170F850001C4100
...    0C2301C4600000416020542E1400061040E208000010B0200E0234028809B01046D800110202010018004000090418C6309E41184F0F0A000309A00030B0102080C008118
...    4B170A0003882001C460000081604200600408C258F850001C41000C2301C4600000A160430018010230962E1400061040E208000040B021003004041E83E000F000A0705
...    00703009401C0018090010180F80600800000004000008020000080100000601F2A2B052F2A6F0768060800004B29202000032CA480800014B29282000072CA4801F95415
...    C161BE5565D068A1E005E02540A05028140A05028140A05028140A05028140A0500050818010030020040C0080180100220300200600400818020050040080C0100280200
...    430300200600400818020050040080C01002802004060080140100208180100700200C0C0080380100620300200E00401818020050040080C0100280200430300200E0040
...    1818020050040080C0100280200406008014010021AA1F000102030406070A0B0C0D101112131418191B1C1D1F2125262728292A2D2F414182D0
${case5_UE_1}    SEPARATOR=
...    E9A09000575F5A13160003C2A002C1262E003387A0E026C9F0E7CC31E50B03826010188E01F71B0A303582308682041D207036B64C558D0E7C471E819F604F8C48E3C873E
...    A39F30C7942C0E070F05C00FFC007003FF0003C000E0541B107582308682041E207032B64C55890E7D813E238F1891C790E7D473E618F28581C0E1E13FFE00000FFF80000
...    078001C0AA3626EB04610D04083A40E0616C98AA221CF88E3C471E819F604F8C73E618F28581C0E1E0B801FF800E007FE00079001C006CBFFFCBFFFC0AE3E236B04610D04
...    083E5038155B262AC2873E238F180000000000000000000003C04FFF800003FFE000001E0007000DE1E14000710400000858081587850001C46000004160561E140006134
...    0006160401C0468051013602085B01603040100400E06318C9081309C1E14000711800002858081040600408C2787850001C4100000C160204101801023D04C00F000A070
...    500703009401C0018090010180F80A008000000040000080200000801000006008000040040000280BCA8AC14BCA9BC1DB4AAD07A0182000012CA48080000CB2920200005
...    2CA4A080001CB292007A55154162E955DD068A1202F012A05028140A05028140A05028140A05028140A050280030C04008010100400804010020100600420200400808020
...    04101002004040100208080100202004008804000000100000004000000808010060200801040400803010040086A87C0004080C10181C282C30344044484C5060646C707
...    47C8494989CA0A4A8B4BD05060B4
${case5_UE_2}    SEPARATOR=
...    E9A09000575F5A13160003C2A002C1262E003387A0E026C9F0E7CC31E50B03826010188E01F71B0A303582308682041D207036B64C558D0E7C471E819F604F8C48E3C873E
...    A39F30C7942C0E070F05C00FF8007003FE0003C800E00365FFFE5FFFE0541B107582308682041E207032B64C55890E7D813E238F1891C790E7D473E618F28581C0E1E13FF
...    E00000FFF80000078001C0AA3626EB04610D04083A40E0616C98AA221CF88E3C471E819F604F8C73E618F28581C0E1E0B801FF000E007FC00079001C006CBFFFCBFFFC0AE
...    3E236B04610D04083E5038155B262AC2873E238F180000000000000000000003C04FFF800003FFE000001E0007000DE1E14000710400000858083AC3C28000E230000020B
...    0758785000184D00018583803808D00A2026C0410B602C06080200801C0C6319290261383C28000E230000050B0107040600408C2787850001C4100000C16020E080C0081
...    007A09801E00140E0A00E0601280380030120020301F01C01000000008000010040000100200000C01000008008000050040000300200001C07E54560A5E54DE0EDE525E0
...    85E025E50D01C1000009652404000065949010000296525040000E594901000049652404000165949010000696524040001E5949407D288AA0B174AAEE8345D298BA09174
...    062E94DD090178095028140A05028140A05028140A05028140A05028140018602014008080200402008010080300210100A014040300608080500A0201C03840402805010
...    10004402000000080000002000000404028080100E01C202014040080600C3543E00020406080C0E1416181A2022242628303236383A3E424A4C4E5052545A5E828305A0
${case5_UE_3}    SEPARATOR=
...    E9A09000575F5A13160003C2A002C1262E003387A0E026C9F0E7CC31E50B03826010188E01F71B0A303582308682041D207036B64C558D0E7C471E819F604F8C48E3C873E
...    A39F30C7942C0E070F05C00FF8007003FE0003C800E00365FFFE5FFFE0541B107582308682041E207032B64C55890E7D813E238F1891C790E7D473E618F28581C0E1E13FF
...    E00000FFF80000078001C0AA3626EB04610D04083A40E0616C98AA221CF88E3C471E819F604F8C73E618F28581C0E1E0B801FF800E007FE00079001C006CBFFFCBFFFC0AE
...    3E236B04610D04083E5038155B262AC2873E238F180000000000000000000003C04FFF800003FFE000001E0007000DE1E14000710400000858081587850001C4600000416
...    0561E1400061340006160401C0468051013602085B01603040100400E06318C9481309C1E14000711800002858083820300204613C3C28000E208000060B0107040600408
...    03D04C00F000A070500703009401C0018090010180F80E00800000004000008020000080100000600800004004000028020000180100000E03F282B052F2A6F056F292F04
...    2F012F29680E0800004B29202000032CA480800014B29282000072CA480800024B292020000B2CA480800034B292020000F2CA4A03E94455058BA557741A2E94C5D048BA0
...    3174A6E8480BC04A8140A05028140A05028140A05028140A05028140A000C30100A004040100201004008040180108080500A02018030404028050100E01C202014028080
...    1002201000000040000001000000202014040080700E10100A02004030061AA1F000102030406070A0B0C0D101112131418191B1C1D1F2125262728292A2D2F414182D
${case5_UE_4}    SEPARATOR=
...    E9A09000575F5A13160003C2A002C1262E003387A0E026C9F0E7CC31E50B03826010188E01F71B0A303582308682041D207036B64C558D0E7C471E819F604F8C48E3C873E
...    A39F30C7942C0E070F05C00FFC007003FF0003C800E00365FFFE5FFFE0541B107582308682041E207032B64C55890E7D813E238F1891C790E7D473E618F28581C0E1E13FF
...    E00000FFF80000078001C0AA3626EB04610D04083A40E0616C98AA221CF88E3C471E819F604F8C73E618F28581C0E1E0B801FF800E007FE00079001C006CBFFFCBFFFC0AE
...    3E236B04610D04083E5038155B262AC2873E238F180000000000000000000003C04FFF800003FFE000001E0007000DE1E14000710400000858081587850001C4600000416
...    0561E1400061340006160401C0468051013602085B01603040100400E06318C9481309C1E14000711800002858083820300204613C3C28000E208000060B0107040600408
...    03D04C00F000A070500703009401C0018090010180F80E00800000004000008020000080100000600800004004000028020000180100000E03F2A2B052F2A6F076F272F03
...    2F012F29680E0800004B29202000032CA480800014B29282000072CA480800024B292020000B2CA480800034B292020000F2CA4A03E95455058BA557741A2E93C5D038BA0
...    31749EE8480BC04A8140A05028140A05028140A05028140A05028140A000C30100A004040100201004008040180108080500A02018030404028050100E01C202014028080
...    500A201000000040000001000000202014040080700E10100A02004030061AA1F000102030406070A0B0C0D101112131418191B1C1D1F2125262728292A2D2F414182D
${case9_UE_1}    SEPARATOR=
...    E9A09000575F5A13160003C5200016093170019C3D0B004D9061CF9863CA160704C060188E02771B0A303582308682041D211001B5B262AC6873E238F40CFB027C62471E4
...    39F51CF9863CA1607038782E007FE003801FF8003600001C0A83620EB04610D04083C4220032B64C55890E7D813E238F1891C790E7D473E618F28581C0E1E13FFE00000FF
...    F800000D80000702A8D89BAC1184341020E908800C2D931544439F11C788E3D033EC09F18E7CC31E50B0381C3C17003FF001C00FFC001B20000E00365FFFE5FFFE0551B13
...    3582308682041D21100185B262A88873E238F11C7A067D813E31CF9863CA1607038782E007FE003801FF8003640001C006CBFFFCBFFFC0AE3E236B04610D04083E508800A
...    AD931561439F11C78C0000000000000000000001E027FFC00001FFF000001B00000E0023C5C28000E2300061340004160205E2E1400071040038980000082C040AC7C2800
...    0E2300061180C26800042C0AC5C28000E2300061300004160401C046805101360208DB00022040800800C0020001208318C60B081309C2E14000711800309800030B01021
...    0030020461387C28000E2300061180C26800102C04086003002043D07C001E00140E0A00E0601280380030120020301F00C01000000008000010040000100200000C03E54
...    560A5E54DE0ED00C1000009652404000065949010000296525040000E5949003F2A86B82C37CAACBA0D143C00BC04A8140A05028140A05028140A05028140A05028140A00
...    0A20100200404010020100600C6020040080802004020080100803002201002004040100201006004402004018080200402004008C0400803010040080401002010020044
...    0200C01808040080200C018D50F8000810182030385058606880889098A0C0C8D8E0E8F909293139414951697A0A0C168
${case22_UE_1}    SEPARATOR=
...    E9A09000575F5A13160003C5200016093170019C3D0B004D9061CF9863CA160704C060188E01F71B0A303582308682041D211001B5B262AC6873E238F40CFB027C62471E4
...    39F51CF9863CA1607038782E007FE003801FF8003600001C0A83620EB04610D04083C4220032B64C55890E7D813E238F1891C790E7D473E618F28581C0E1E13FFE00000FF
...    F800000D80000702A8D89BAC1184341020E908800C2D931544439F11C788E3D033EC09F18E7CC31E50B0381C3C17003FF001C00FFC001B20000E00365FFFE5FFFE0571F11
...    B582308682041F284400556C98AB0A1CF88E3C60000000000000000000000F013FFE00000FFF800000D800007000DE2E1400061040E208000000B0102F1F0A00038820018
...    460388C0000042C040AC5C28000C230184D00010581007011A014404D808236C000680C20030008003818C633B206C270785000184D0001858081040600402C270B850001
...    C41000E230000040B0102100300201613C5C28000E230006134000A1602042006004020F41F00078005038280381804A00E000C0480080C07C03004000000020000040100
...    00040080000300F95358297953783B40304000025949010000196524040000A594941000039652400F4AA2A82C5D2ABBA0D143C00BC04A8140A05028140A05028140A0502
...    8140A05028140A000A201002004040100201004008602004008080200402008010080200420100200404010020100200420200C018080300220100600C040200401008010
...    40200C01808040080200C008D50F8000810182030385058606880889098A0C0C8D8E0E8F909293139414951697A0A0C168

${case22_UE_2}    SEPARATOR=
...    E9A09000575F5A13160003C5200016093170019C3D0B004D9061CF9863CA160704C060188E01F71B0A303582308682041D211001B5B262AC6873E238F40CFB027C62471E4
...    39F51CF9863CA1607038782E007FE003801FF8003600001C0A83620EB04610D04083C4220032B64C55890E7D813E238F1891C790E7D473E618F28581C0E1E13FFE00000FF
...    F800000D80000702A8D89BAC1184341020E908800C2D931544439F11C788E3D033EC09F18E7CC31E50B0381C3C17003FF001C00FFC001B20000E00365FFFE5FFFE0571F11
...    B582308682041F284400556C98AB0A1CF88E3C60000000000000000000000F013FFE00000FFF800000D800007000DE2E1400061040E208000000B0102F1F0A00038820018
...    460388C0000042C040AC5C28000C230184D00010581007011A014404D808236C000680C20030008003818C6349206C270785000184D000185808104062840830820410030
...    9C2E14000710400388C0000102C0408400C50810610408200613C5C28000E230006134000A1602042006284083082041000F41F00078005038280381804A00E000C048008
...    0C07C0300400000002000004010000040080000300F95358297953783B40304000025949010000196524040000A594941000039652400F4AA2A82C5D2ABBA0D143C00BC04
...    A8140A05028140A05028140A05028140A05028140A000A201002004040100201004008602004008080200402008010080200420100200404010020100200420200C018080
...    300220100600C04020040100801040200C01808040080200C008D50F8000810182030385058606880889098A0C0C8D8E0E8F909293139414951697A0A0C168

${case22_UE_3}    SEPARATOR=
...    E9A09000575F5A13160003C5200016093170019C3D0B004D9061CF9863CA160704C060188E01F71B0A303582308682041D211001B5B262AC6873E238F40CFB027C62471E4
...    39F51CF9863CA1607038782E007FE003801FF8003600001C0A83620EB04610D04083C4220032B64C55890E7D813E238F1891C790E7D473E618F28581C0E1E13FFE00000FF
...    F800000D80000702A8D89BAC1184341020E908800C2D931544439F11C788E3D033EC09F18E7CC31E50B0381C3C17003FF001C00FFC001B20000E00365FFFE5FFFE0571F11
...    B582308682041F284400556C98AB0A1CF88E3C60000000000000000000000F013FFE00000FFF800000D800007000DE2E1400061040E208000000B0102F1F0A00038820018
...    460388C0000042C040AC5C28000C230184D00010581007011A014404D808236C000680C20030008003818C633C206C2707898001C0100000616020410180104309C2E1400
...    0710400388C0000102C0408400C0082184F170A000388C001C4D00000A160204200600410F41F00078005038280381804A00E000C0480080C07C030040000000200000401
...    0000040080000300F95358297953783B40304000025949010000196524040000A594941000039652400F4AA2A82C5D2ABBA0D143C00BC04A8140A05028140A05028140A05
...    028140A05028140A000A201002004040100201004008602004008080200402008010080200420100200404010020100200420200C018080400820100600C0402004010080
...    1040200C01808040080200C008D50F8000810182030385058606880889098A0C0C8D8E0E8F909293139414951697A0A0C168

${case22_UE_4}    SEPARATOR=
...    E9A09000575F5A13160003C5200016093170019C3D0B004D9061CF9863CA160704C060188E01F71B0A303582308682041D211001B5B262AC6873E238F40CFB027C62471E4
...    39F51CF9863CA1607038782E007FE003801FF8003600001C0A83620EB04610D04083C4220032B64C55890E7D813E238F1891C790E7D473E618F28581C0E1E13FFE00000FF
...    F800000D80000702A8D89BAC1184341020E908800C2D931544439F11C788E3D033EC09F18E7CC31E50B0381C3C17003FF001C00FFC001B20000E00365FFFE5FFFE0571F11
...    B582308682041F284400556C98AB0A1CF88E3C60000000000000000000000F013FFE00000FFF800000D800007000DE2E1400061040E208000000B0102F1F0A00038820018
...    460388C0000042C040AC5C28000C230184D00010581007011A014404D808236C000680C20030008003818C632B204C270B802001C41000E230000040B0102100300204613
...    C5C28000E230007130000028580810801801020F41F00078005038280381804A00E000C0480080C07C0300400000002000004010000040080000300F95358297953783B40
...    304000025949010000196524040000A594941000039652400F4AA2A82C5D2ABBA0D143C00BC04A8140A05028140A05028140A05028140A05028140A000A20100200404010
...    0201004008602004008080200402008010080200420100200404010020100200420200C018080400820100801004020040100801040200C01808040080200C008D50F8000
...    810182030385058606880889098A0C0C8D8E0E8F909293139414951697A0A0C168

${case22_UE_5}    SEPARATOR=
...    E9A09000575F5A13160003C5200016093170019C3D0B004D9061CF9863CA160704C060188E01F71B0A303582308682041D211001B5B262AC6873E238F40CFB027C62471E4
...    39F51CF9863CA1607038782E007FE003801FF8003600001C0A83620EB04610D04083C4220032B64C55890E7D813E238F1891C790E7D473E618F28581C0E1E13FFE00000FF
...    F800000D80000702A8D89BAC1184341020E908800C2D931544439F11C788E3D033EC09F18E7CC31E50B0381C3C17003FF001C00FFC001B20000E00365FFFE5FFFE0571F11
...    B582308682041F284400556C98AB0A1CF88E3C60000000000000000000000F013FFE00000FFF800000D800007000DE2E1400061040E208000000B0102F1F0A00038820018
...    460388C0000042C040AC5C28000C230184D00010581007011A014404D808236C000680C20030008003818C632A204C270B802001C00000E260000040B0102100300204613
...    C5C4C000E010006010000A160204200600408F41F00078005038280381804A00E000C0480080C07C0300400000002000004010000040080000300F95358297953783B4030
...    4000025949010000196524040000A594941000039652400F4AA2A82C5D2ABBA0D143C00BC04A8140A05028140A05028140A05028140A05028140A000A2010020040401002
...    01004008602004008080200402008010080200420100200404010020100200420200C018080400820100801004020040100200440200C018080400802010020D50F800081
...    0182030385058606880889098A0C0C8D8E0E8F909293139414951697A0A0C168


${case25_UE_1}    SEPARATOR=
...    E9A09000575F5A13160003C2A002C1262E003387A0E026C9F0E7CC31E50B03826010188E01F71B0A303582308682041D207036B64C558D0E7C471E819F604F8C48E3C873E
...    A39F30C7942C0E070F05C00FFC007003FF0003C800E00365FFFE5FFFE0541B107582308682041E207032B64C55890E7D813E238F1891C790E7D473E618F28581C0E1E13FF
...    E00000FFF80000078001C0AA3626EB04610D04083A40E0616C98AA221CF88E3C471E819F604F8C73E618F28581C0E1E0B801FF800E007FE00079001C006CBFFFCBFFFC0AE
...    3E236B04610D04083E5038155B262AC2873E238F180000000000000000000003C04FFF800003FFE000001E00070011E2E14000710400308200010B0102B1F0A000388C001
...    C41000C23000082C0AC5C28000C26818460001858158B850001C41000C26800102C0803808D00A2026C0410B6044081001800400400024106318C3390561383C28000C268
...    00142C040820300204613C7C28000E20800711800308C00060B01021800C20810808C258B850001C46000E268000070B02100300204612C5C28000E208007104000040581
...    080184102101184B170A000388200184D0004858108018010207A09801E00140E0A00E0601280380030120020301F01C01000000008000010040000100200000C01000008
...    008000050040000300200001C07E54560A5E54DE0EDE4E5E065E025E4ED01C1000009652404000065949010000296525040000E5949010000496524040001659490100006
...    96524040001E5949407D2A8AA0B174AAEE8345D278BA07174062E93DD090178095028140A05028140A05028140A05028140A0502814002460201400808020040200801008
...    03002201002004040100201004008602004008080200402008010080200420100200404018010100400840200400808020040200C00840400803010020046020040180802
...    00402008010080200420100200C040100201002004402004018080200402008010804008030100400804008011AA1F000102030406070A0B0C0D101112131418191B1C1D1
...    F2125262728292A2D2F414182D0
${case25_UE_2}    SEPARATOR=
...    E9A09000575F5A13160003C2A002C1262E003387A0E026C9F0E7CC31E50B03826010188E01F71B0A303582308682041D207036B64C558D0E7C471E819F604F8C48E3C873E
...    A39F30C7942C0E070F05C00FFC007003FF0003C800E00365FFFE5FFFE0541B107582308682041E207032B64C55890E7D813E238F1891C790E7D473E618F28581C0E1E13FF
...    E00000FFF80000078001C0AA3626EB04610D04083A40E0616C98AA221CF88E3C471E819F604F8C73E618F28581C0E1E0B801FF800E007FE00079001C006CBFFFCBFFFC0AE
...    3E236B04610D04083E5038155B262AC2873E238F180000000000000000000003C04FFF800003FFE000001E00070011E2E1400071040038820000042C040AC7C28000E2300
...    0710400308C00020B02B170A000309A061180006160562E14000710400309A00040B0200E0234028809B01042D8110204006001001000090418C630CE41584E0F0A000309
...    A00050B0102080C0081184F1F0A0003882001C46000C23000182C040860030820420230962E14000711800389A00001C2C08400C0081184B170A0003882001C4100001016
...    04200610408404612C5C28000E208006134001216042006004081E8260078005038280381804A00E000C0480080C07C070040000000200000401000004008000030040000
...    20020000140100000C0080000701F951582979537819794178197809794340704000025949010000196524040000A59494100003965240400012594941000059652404000
...    1A594901000079652401F4AA2A82C5D2AABA071749EEE81C5D018BA51142405E02540A05028140A05028140A05028140A05028140A0500091808050020200801008020040
...    200C00880400801010040080401002180801002020080100802004020080108040080101006004040100210080100202010020080801010100200C0402808180801006020
...    100200802004020080108040080301004008040280810080100602010020080400820100200C04020040100A0206A87C0004080C10181C282C30344044484C5060646C707
...    47C8494989CA0A4A8B4BD05060B40

${case25_UE_3}    SEPARATOR=
...    E9A09000575F5A13160003C2A002C1262E003387A0E026C9F0E7CC31E50B03826010188E01F71B0A303582308682041D207036B64C558D0E7C471E819F604F8C48E3C873E
...    A39F30C7942C0E070F05C00FFC007003FF0003C800E00365FFFE5FFFE0541B107582308682041E207032B64C55890E7D813E238F1891C790E7D473E618F28581C0E1E13FF
...    E00000FFF80000078001C0AA3626EB04610D04083A40E0616C98AA221CF88E3C471E819F604F8C73E618F28581C0E1E0B801FF800E007FE00079001C006CBFFFCBFFFC0AE
...    3E236B04610D04083E5038155B262AC2873E238F180000000000000000000003C04FFF800003FFE000001E00070011E2E1400071040038820000042C040AC7C28000E2300
...    0710400308C00020B02B170A000309A061180006160562E14000710400309A00040B0200E0234028809B01042D8110204006001001000090418C630CE41584E0F0A000309
...    A00050B0102080C0081184F1F0A0003882001C46000C23000182C040860030820420230962E14000711800389A00001C2C08400C0081184B170A0003882001C4100001016
...    04200610408404612C5C28000E208006134001216042006004081E8260078005038280381804A00E000C0480080C07C070040000000200000401000004008000030040000
...    20020000140100000C0080000701F951582979537819793978197809794340704000025949010000196524040000A59494100003965240400012594941000059652404000
...    1A594901000079652401F4AA2A82C5D2AABA071749EEE81C5D018BA51142405E02540A05028140A05028140A05028140A05028140A0500091808050020200801008020040
...    200C00880400801010040080401002180801002020080100802004020080108040080101006004040100210080100202010020080801010100200C0404008180801006020
...    100200802004020080108040080301004008040400810080100602010020080400820100200C0402004010100206A87C0004080C10181C282C30344044484C5060646C707
...    47C8494989CA0A4A8B4BD05060B40

${case25_UE_4}    SEPARATOR=
...    E9A09000575F5A13160003C2A002C1262E003387A0E026C9F0E7CC31E50B03826010188E01F71B0A303582308682041D207036B64C558D0E7C471E819F604F8C48E3C873E
...    A39F30C7942C0E070F05C00FFC007003FF0003C800E00365FFFE5FFFE0541B107582308682041E207032B64C55890E7D813E238F1891C790E7D473E618F28581C0E1E13FF
...    E00000FFF80000078001C0AA3626EB04610D04083A40E0616C98AA221CF88E3C471E819F604F8C73E618F28581C0E1E0B801FF800E007FE00079001C006CBFFFCBFFFC0AE
...    3E236B04610D04083E5038155B262AC2873E238F180000000000000000000003C04FFF800003FFE000001E00070011E2E14000710400308200010B0102B1F0A000388C001
...    C41000C23000082C0AC5C28000C26818460001858158B850001C41000C26800102C0803808D00A2026C0410B6044081001800400400024106318C2890461383C28000C268
...    00142C040820300204613C5C28000E20800711800003058081080184102101184B170A000388C001C4D00000E1604200600408C258B850001C41000E208000080B0210030
...    82042027A09801E00140E0A00E0601280380030120020301F01C01000000008000010040000100200000C01000008008000050040000300200001C07E54560A5E54DE065E
...    505E065E025E50D01C1000009652404000065949010000296525040000E594901000049652504000165949010000696524040001E5949007D2A8AA0B174AAAE81C5D27ABA
...    07174062E9445090178095028140A05028140A05028140A05028140A050281400246020140080802004020080100803002201002004040100201004008602004008080200
...    40200801008020042010020040401801010040084020040080804008020200404040080301010020402004018080400802008010804008030100400804040081008010060
...    2010020080400820100200C0402004010100206A87C0004080C10181C282C30344044484C5060646C70747C8494989CA0A4A8B4BD05060B4

@{case22_enable_12149}
...    NRCELL-1:${DEN_1_SEC_SAMPLE}>1
...    NRCELL-1:${DEN_1_SEC_SAMPLE}<=310
...    NRCELL-1:${AVG_NUM_UE_DENOM}>1
...    NRCELL-1:${AVG_NUM_UE_DENOM}<=310
...    NRCELL-1:${ACC_NUM_UL_TX_SW_OP1_UE_CAP}>0
...    NRCELL-1:${ACC_NUM_UL_TX_SW_OP1_UE_CONFG}>0    #12149

...    NRCELL-1:NCAC:${UE_SCELL_1_CONF_SCELL_UL_SA}=0
...    NRCELL-13:NCAC:${UE_SCELL_1_CONF_SCELL_UL_SA}>=1
...    NRCELL-2:NCAC:${UE_SCELL_1_CONF_SCELL_UL_SA}=0
...    NRCELL-1:NCAC:${UE_PCELL_1_CONF_SCELL_UL_SA}>1
...    NRCELL-1:CUCM:${MAX_UE_PCELL_1_CONF_SCEL_UL_SA}=1
...    NRCELL-1:NCAC:${RRC_RECONF_ADD1ULSCELL_ATT_SA}=5
...    NRCELL-1:NCAC:${RRC_RECONF_ADD1ULSCELL_SUCC_SA}=5
...    NRCELL-1:NCAC:${A2MEAS_REL1ULSCELL_SUCC_SA}=0
@{case22_disable_12149}
...    NRCELL-1:${DEN_1_SEC_SAMPLE}>1
...    NRCELL-1:${DEN_1_SEC_SAMPLE}<=300
...    NRCELL-1:${AVG_NUM_UE_DENOM}>1
...    NRCELL-1:${AVG_NUM_UE_DENOM}<=300
...    NRCELL-1:${ACC_NUM_UL_TX_SW_OP1_UE_CAP}=0
...    NRCELL-1:${ACC_NUM_UL_TX_SW_OP1_UE_CONFG}=0    #12149

...    NRCELL-1:NCAC:${UE_SCELL_1_CONF_SCELL_UL_SA}=0
...    NRCELL-13:NCAC:${UE_SCELL_1_CONF_SCELL_UL_SA}>0
...    NRCELL-2:NCAC:${UE_SCELL_1_CONF_SCELL_UL_SA}=0
...    NRCELL-1:NCAC:${UE_PCELL_1_CONF_SCELL_UL_SA}>1
...    NRCELL-1:CUCM:${MAX_UE_PCELL_1_CONF_SCEL_UL_SA}=1
...    NRCELL-1:NCAC:${RRC_RECONF_ADD1ULSCELL_ATT_SA}=5
...    NRCELL-1:NCAC:${RRC_RECONF_ADD1ULSCELL_SUCC_SA}=5
...    NRCELL-1:NCAC:${A2MEAS_REL1ULSCELL_SUCC_SA}=0
#CB012149 counter
${ACC_NUM_UL_TX_SW_OP1_UE_CAP}    M55181C00010
${ACC_NUM_UL_TX_SW_OP1_UE_CONFG}    M55118C00053
${DEN_1_SEC_SAMPLE}    M55118C00054
${AVG_NUM_UE_DENOM}    M55181C00003
##
${UE_PCELL_1_CONF_SCELL_UL_SA}    M55118C10005
${UE_SCELL_1_CONF_SCELL_UL_SA}    M55118C10006
${MAX_UE_PCELL_1_CONF_SCEL_UL_SA}    M55156C10007
${RRC_RECONF_ADD1ULSCELL_ATT_SA}    M55118C10001
${RRC_RECONF_ADD1ULSCELL_SUCC_SA}    M55118C10002
${A2MEAS_REL1ULSCELL_SUCC_SA}    M55118C10004

*** Test Cases ***
CB012149-SR-DA_ET_05_01_scell selection with BWP profile for TDD pcell with single UE
    [Documentation]
    ...    == Precondition: ==
    ...    GNB:
    ...        CELL      TEC    BAND    CHBW    NRARFCN          GSCN    ssbFrequency    PCI    nrCellIdentity
    ...        CELL1     TDD    N41     80M     518598           6480    518430          50     16385
    ...        CELL2     TDD    N78     70M     636666           7880    636576          51     16386
    ...        CELL11    FDD    N66     20M     424000/344000    5297    423850          60     16395
    ...        CELL12    FDD    N71     10M     126900/136100    1587    126990          61     16396
    ...        CELL13    FDD    N66     30M     430920/350920    5385    430830          62     16397
    ...        CELL14    FDD    N71     10M     129000/138200    1611    128910          63     16398
    ...     NRCELL-1(80M):NRBTS/BWP_PROFILE-52:locationAndBandwidthDl:cRbSizeDl=n189    ---70M  (middle bwp)
    ...     NRCELL-1(80M):NRBTS/BWP_PROFILE-53:locationAndBandwidthDl:cRbSizeDl=n133    ---50M  (small bwp)
    ...     NRCELL-2(70M):NRBTS/BWP_PROFILE-54:locationAndBandwidthDl:cRbSizeDl=n162    ---60M  (middle bwp)
    ...     NRCELL-2(70M):NRBTS/BWP_PROFILE-55:locationAndBandwidthDl:cRbSizeDl=n133    ---50M  (small bwp)
    ...     NRCELL-13(30M):NRBTS/BWP_PROFILE-56:locationAndBandwidthDl:cRbSizeDl=n133    ---25M  (middle bwp)
    ...     NRCELL-13(30M):NRBTS/BWP_PROFILE-57:locationAndBandwidthDl:cRbSizeDl=n106    ---20M  (small bwp)
    ...     precondition: 9169/12149/81817 enable, ulTxSwitchingBoost=1
    ...     UE:
    ...        UE1 normal BC:(All large BWP, 2 layer, A1>a1ThresholdSCellAddSsbRsrpTDD)
    ...                BC#1:N41a*-N66a*=50*50*(30+30*0.6)=120,000
    ...                BC#2:N41a*-N71a*=50*50*(10+10*0.6)=40,000
    ...                BC#3:N41a*-N78=50*50*(70*0.7)=122,500.0---select this BC
    ...            ultxswitch BC(all large BWP, 2 layer):
    ...                BC#1:N41a*-N71a*=50*50*(10+10*0.6)=40,000
    ...                BC#2:N41a*-N66a*=50*50*(30+30*0.6)=120,000
    ...        UE2 (A1 > a1ThresholdSCellAddSsbRsrpTDD, ulTxSwitchingBoost=1.8, no NRREL with NRCELL-13(n66_30M))
    ...            normal BC:(middle BWP, n41/n66/n71-2 layer, n78-4layer)
    ...                BC#1:N41a*-N66a*=50*50*(25+25*0.6)=100,000
    ...                     maxdatarate=2*2*70*0.7*(1-0.14)+1*2*70*0.3*(1-0.08)+2*1*20*(1-0.14)+1*1*20*0.6*(1-0.08)=252.64
    ...                BC#2:N41a*-N71a*=50*50*(10+10*0.6)=40,000
    ...                BC#3:N41a*-N78a*=50*50*(60*0.7)=105,000.0
    ...            ultxswitch BC:(middle BWP, n41_70M/n66_25M/n71-2 layer, n78_60M-2layer)
    ...                BC#1:N41a*-N71a*=50*50*(10+10*0.6+0.8*70*0.3)=82,000.0
    ...                BC#2:N41a*-N66a*=50*50*(25+25*0.6+0.8*70*0.3)=122,000.0---select this  BC
    ...                     maxdatarate=2*2*70*0.7*(1-0.14)+1.8*2*70*0.3*(1-0.08)+2*1*20*(1-0.14)+1*1*20*0.6*(1-0.08)=283.552
    ...        UE3 (A1 > a1ThresholdSCellAddSsbRsrpTDD, ulTxSwitchingBoost=2, add NRREL with NRCELL-13(n66_30M) back)
    ...            normal BC:(pcell small BWP, other middle BWP, n41_50M/n66_25M/n71-2 layer, n78_60M-4layer)
    ...                BC#1:N41a*-N66a*=50*50*(25+25*0.6)=100,000
    ...                maxdatarate=2*2*70*0.7*(1-0.14)+1*2*70*0.3*(1-0.08)+2*1*25*(1-0.14)+1*1*25*0.6*(1-0.08)=264.0
    ...                BC#2:N41a*-N71a*=50*50*(10+10*0.6)=40,000
    ...                BC#3:N41a*-N78a*=50*50*(60*0.7)=105,000.0
    ...            ultxswitch BC:(pcell small BWP, other middle BWP, n41_50M/n66_25M/n71-2 layer, n78_60M-4layer)
    ...                BC#1:N41a*-N71a*=50*50*(10+10*0.6+50*0.3)=77,500
    ...                BC#2:N41a*-N66a*=50*50*(25+25*0.6+50*0.3)=137,500----select this  BC
    ...                     maxdatarate=2*2*70*0.7*(1-0.14)+2*2*70*0.3*(1-0.08)+2*1*25*(1-0.14)+1*1*25*0.6*(1-0.08)=302.64
    ...        UE4 (A1 > a1ThresholdSCellAddSsbRsrpTDD, ulTxSwitchingBoost=2)
    ...            normal BC:(small BWP, all 2 layer, n41_50M/n66_20M/n71/n78_50M-2layer)
    ...                BC#1:N41a*-N66a*=50*50*(20+20*0.6)=80,000
    ...                BC#2:N41a*-N71a*=50*50*(10+10*0.6)=40,000
    ...                BC#3:N41a*-N78a*=50*50*(50*0.7)=87,500
    ...            ultxswitch BC:(small BWP, n41_50M/n66_20M/n71-2 layer, n78_50M-4layer)
    ...                BC#1:N41a*-N71a*=50*50*(10+10*0.6+50*0.3)=77,500
    ...                BC#2:N41a*-N66a*=50*50*(20+20*0.6+50*0.3)=117,500----select this BC
    ...    == Test steps: ==
    ...    step 1. UE1 ICS to cell1 and report A1 with RSRP=61, select normal BC#3:N41a*-N78, then deregister
    ...    step 2. online change ulTxSwitchingBoost=1.8 and delete NRCELL-13 neighbor relation
    ...    step 3. UE2 ICS to cell1 and report A1 with RSRP=61, select ultxswitch BC#2:N41a*-N66a*, then deregister
    ...    step 4. ADD NRCELL-13 neighbor relation back and change ulTxSwitchingBoost=2
    ...    step 5. UE3 ICS to cell1 and report A1 with RSRP=61, select ultxswitch BC#2:N41a*-N66a*, then deregister
    ...    step 6. UE4 ICS to cell1 and report A1 with RSRP=61, select ultxswitch BC#2:N41a*-N66a*, then deregister
    [Tags]    owner-annie.nie    t05
    OnlineParamChange    ${case5_enable_9169_12147_81817}
    UE Register Setup PDU Trigger Scell Addition By A1    ue_id=1    srsrp_nr=61    ue_capa=${case5_UE_1}
    UE Deregister    ue_id=1
    OnlineParamChange    ${ulTxSwitchingBoost_1.8_no_NRREL3}    #deelete NRCELL-13 relation
    UE Register Setup PDU Trigger Scell Addition By A1    ue_id=2    srsrp_nr=61    ue_capa=${case5_UE_2}
    UE Deregister    ue_id=2
    OnlineParamChange    ${ADD_NRREL_BACK}
    UE Register Setup PDU Trigger Scell Addition By A1    ue_id=3    srsrp_nr=61    ue_capa=${case5_UE_3}
    UE Deregister    ue_id=3
    UE Register Setup PDU Trigger Scell Addition By A1    ue_id=4    srsrp_nr=61    ue_capa=${case5_UE_4}
    UE Deregister    ue_id=4
    Check RRC Log    ${CURDIR}${/}A2A_DA_case5${/}a2a.ini

CB012149-SR-DA_ET_25_01_scell selection with BWP profile for TDD pcell with multi UE
    [Documentation]
    ...     NRCELL-1(80M):NRBTS/BWP_PROFILE-53:locationAndBandwidthDl:cRbSizeDl=n133    ---50M  (small bwp)
    ...     NRCELL-2(70M):NRBTS/BWP_PROFILE-54:locationAndBandwidthDl:cRbSizeDl=n162    ---60M  (small bwp)
    ...     NRCELL-13(30M):NRBTS/BWP_PROFILE-57:locationAndBandwidthDl:cRbSizeDl=n106    ---20M  (small bwp)
    ...     precondition: 9169/12149 enable,81817 disable, ulTxSwitchingBoost=2
    ...     steps:
    ...        1. UE1 register to cell1 and send A1 RSRP=51, UL TX switch BC#2: N41a*-N66a*(30M)-N71a*-N71a slected
    ...        2. UE2 register to cell1 and send A1 RSRP=61,  UL TX switch BC#5: N41a*-N66a*(30M)-N78a slected
    ...        3. UE3 register to cell1 and send A1 RSRP=61,  UL TX switch BC#5: N41a*-N66a*(20M)-N78a slected
    ...        4. UE4 register to cell1 and send A1 RSRP=51,  normal BC#2: N41a*-N66a*(30M)-N71a-N71a*(UL/DL) slected
    ...        5. UE3 report A2 to release scells
    ...        6. online  change ulTxSwitchingBoost=1
    ...        7. UE3 register to cell1 and send A1 RSRP=61,  UL TX switch BC#5: N41a*-N66a*(20M)-N78a slected
    ...        8. enable 81817 and deregister UE3/UE4
    ...        7. UE3 register to cell1 and send A1 RSRP=61,  normal BC#4: N41a*-N66a*(20M)-N78a slected
    [Tags]    owner-annie.nie    t25
    OnlineParamChange    ${case25_9169_12149_enable_81817_disable}
    UE Register Setup PDU Trigger Scell Addition By A1    ue_id=1    srsrp_nr=51    ue_capa=${case25_UE_1}
    UE Register Setup PDU Trigger Scell Addition By A1    ue_id=2    srsrp_nr=61    ue_capa=${case25_UE_2}
    UE Register Setup PDU Trigger Scell Addition By A1    ue_id=3    srsrp_nr=61    ue_capa=${case25_UE_3}
    UE Register Setup PDU Trigger Scell Addition By A1    ue_id=4    srsrp_nr=51    ue_capa=${case25_UE_4}
    Report A2 With RSRP to Release SCell    ue_id=3    srsrp_nr=39
    OnlineParamChange    ${ulTxSwitchingBoost_eq_1}
    Trigger Scell Addition By A1    ue_id=3    srsrp_nr=61
    OnlineParamChange    ${enable_81817}
    Deregister UE3 and UE4
    UE Register Setup PDU Trigger Scell Addition By A1    ue_id=3    srsrp_nr=61    ue_capa=${case25_UE_3}
    Check RRC Log    ${CURDIR}${/}A2A_DA_case25${/}a2a.ini

CB012149-SR-DA_ET_01_01_scell selection with the same bandwidth and maxdatarate then change CNI-81817 feature flag to on and off
    [Documentation]
    ...     precondition: 9169/12149 enable,81817 disable, ulTxSwitchingBoost=1
    ...     steps:
    ...        1. UE1 register to cell1 and send A1 RSRP=61, UL TX swtich BC#5: N41a*-N66a-N66a* selected
    ...        2. Online change 81817 to enable
    ...        3. UE2 register to cell1 and send A1 RSRP=61,  normal BC#4: N41a*-N66a*-N71a-N71a slected
    ...        4. Online change 81817 to disabled
    ...        5. UE3 register to cell1 and send A1 RSRP=61,  UL TX swtich BC#5: N41a*-N66a-N66a*
    [Tags]    owner-annie.nie    t01
    OnlineParamChange    ${case1_9169_12149_enable_81817_disable}
    UE Register Setup PDU Trigger Scell Addition By A1    ue_id=1    srsrp_nr=61    ue_capa=${case1_UE_1_3}
    UE Deregister    ue_id=1
    OnlineParamChange    ${enable_81817}
    UE Register Setup PDU Trigger Scell Addition By A1    ue_id=2    srsrp_nr=61    ue_capa=${case1_UE_1_3}
    UE Deregister    ue_id=2
    OnlineParamChange    ${disable_81817}
    UE Register Setup PDU Trigger Scell Addition By A1    ue_id=3    srsrp_nr=61    ue_capa=${case1_UE_1_3}
    UE Deregister    ue_id=3
    Check RRC Log    ${CURDIR}${/}A2A_DA_case01${/}a2a.ini

CB012149-SR-DA_ET_09_01_scell selection with DRB profile based CA with CNI-81817 off when pcell is TDD
    [Documentation]
    ...    precondition: 9169/12149/9059 enable,81817 disable, ulTxSwitchingBoost=2
    ...    NRBTS/NRDRB-10:cellAggrLevel=FR1 CA eligible    5QI-5    qosflow id=5
    ...    NRBTS/NRDRB-11:cellAggrLevel=Not FR1 CA eligible    5QI-6(default)    qosflow id=1
    ...    NRBTS/NRDRB-12:cellAggrLevel=FR1 CA incompatible    5QI-7    qosflow id=2
    ...     steps:
    ...        1. UE1 register and setup PDU session with NRDRB-11(5QI6) Not FR1 CA eligible
    ...        2. UE1 PDU session modify to add DRB10(5QI5) FR1 CA eligible
    ...        3. UE1 send A1 RSRP=61,  UL TX switch BC#2: N41a*-N71a*-N71a-N78a selected
    ...        4. UE1 PDU seesion modify to add DRB12(5QI7) FR1 CA incompatible DRB, all scell released
    ...        5. UE1 PDU seesion modify to delete DRB12(5QI7) FR1 CA incompatible DRB
    ...        6. UE1 send A1 RSRP=61, UL TX switch BC#2: N41a*-N71a*-N71a-N78a selected
    [Tags]    owner-annie.nie    t09
    OnlineParamChange    ${case9_9169_12149_9059_enable_81817_disable}
    UE register and setup multiple PDU session    ue_id=1    ue_capa=${case9_UE_1}    qosflows_to_activate=5
    Trigger Scell Addition By A1    ue_id=1    srsrp_nr=61
    UE PDU Session Modify to Add incompatible DRB    ue_id=1
    UE PDU Session Modify to Del incompatible DRB    ue_id=1
    Trigger Scell Addition By A1    ue_id=1    srsrp_nr=61
    UE Deregister    ue_id=1
    Check RRC Log    ${CURDIR}${/}A2A_DA_case09${/}a2a.ini

CB012149-SR-DA_ET_22_01_PM counter check with the feature on to off when UL CA is activated
    [Documentation]
    ...    precondition: 9169/12149 enable,81817 disable, ulTxSwitchingBoost=2
    ...     steps:
    ...        1. UE1 register and send A1 RSRP=61, normal BC#1: N41a*-N66a-N66a* selected, ue deregister
    ...        2. UE2 register and send A1 RSRP=61, UL TX switch BC#3: N41a*-N71a*-N78a selected, ue deregister
    ...        3. UE3 register and send A1 RSRP=61, normal BC#1: N41a*-N66a-N66a* selected, ue deregister
    ...        4. UE4 register and send A1 RSRP=61, normal BC#1: N41a*-N66a-N66a* selected, ue deregister
    ...        5. UE5 register and send A1 RSRP=61, normal BC#1: N41a*-N66a-N66a* selected, ue deregister
    ...        6. check counters
    ...        7. Onlinechange to disable CB012149, NRBTS/NRDU/ulTxSwitchingSupportList=none
    ...        8. UE1 register and send A1 RSRP=61, normal BC#1: N41a*-N66a-N66a* selected, ue deregister
    ...        9. UE2 register and send A1 RSRP=61, normal BC#1:: N41a*-N66a-N66a* selected, ue deregister
    ...        10. UE3 register and send A1 RSRP=61, normal BC#1: N41a*-N66a-N66a* selected, ue deregister
    ...        11. UE4 register and send A1 RSRP=61, normal BC#1: N41a*-N66a-N66a* selected, ue deregister
    ...        12. UE5 register and send A1 RSRP=61, normal BC#1: N41a*-N66a-N66a* selected, ue deregister
    ...        13. check counters
    [Tags]    owner-annie.nie    t22
    OnlineParamChange    ${case22_9169_12149_enable_81817_disable}
    clear counter files
    5 UE Register Setup PDU Trigger Scell Addition By A1
    Check Counters    ${case22_enable_12149}
    OnlineParamChange    ${disable_12149}
    clear counter files
    5 UE Register Setup PDU Trigger Scell Addition By A1
    Check Counters    ${case22_disable_12149}
    Check RRC Log    ${CURDIR}${/}A2A_DA_case22${/}a2a.ini

*** Keywords ***
Start BTS With Specified Config Files
    Common Suite Setup
    Setup Airphone Env    tl_type=${GNB_CONFIG}

Modify Cfg
    ${set_gnb3}    catenate    set_gnb id=3 type=simulated plmn=311:489 ng=10.0.1.123 gnb_id=0x23:22 daemon=10.0.2.1:22222
    ...    x2_peers=none xn=10.0.1.122 nssai=0x1:0xd143a5 amf=1
    ${set_gnb3_cell1}    catenate    set_cell id=1 gnb=3 pci=127:0 tac=200 nrci=0x01 tdd_cell=on proxy=10.0.2.91:9999 nr_arfcn=135760:126380
    ...    gscn=1582 mandatory_for_activation=off
    Update Cfg    ${set_gnb3}
    Update Cfg    ${set_gnb3_cell1}
    Update Cfg    gnb_param id=3 xn_listening_socket=1 send_xn_setup=true measEvent=A3

    Update Cfg    set_qosflow id=1 5qi=6 default=on
    Update Cfg    set_qosflow id=2 5qi=7
    Update Cfg    set_qosflow id=3 5qi=8
    Update Cfg    set_qosflow id=4 5qi=9
    Update Cfg    set_qosflow id=5 5qi=5
    Update Cfg    set_qosflow id=6 5qi=1

Set UE Parameters Before Attach
    [Arguments]    ${ue_id}=1    ${cell_id}=1    ${qos_flow}=1
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    smf_param id=1 reset
    Execute Egate Command    qosflow_modify qos_flow=${qos_flow} default=on
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    gnb_xn_link_up gnb=3 target=2    GNB-3: XnAP Link with GNB-2

UE PDU Session Modify to Add incompatible DRB
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${qosflows_to_add}=2
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu} qosflows_to_add=${qosflows_to_add} by=amf    pass_regexp=sCellToReleaseList
UE PDU Session Modify to Del incompatible DRB
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${qosflows_to_del}=2
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu} qosflows_to_del=${qosflows_to_del} by=amf
    ...    pass_regexp=Removed FiveQi:Qfi mapping fiveQi
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

Report A2 With RSRP to Release SCell
    [Arguments]    ${ue_id}    ${srsrp_nr}
    ${measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${Cell2_ssbFrequency}    event_type=A2
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${measid} event=A2 scell=1 scell_rsrp=${srsrp_nr}
    ...    pass_regexp=rrcReconfigurationComplete
    ${measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${Cell11_ssbFrequency}    event_type=A2
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${measid} event=A2 scell=2 scell_rsrp=${srsrp_nr}
    ...    pass_regexp=rrcReconfigurationComplete

UE Deregister
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s

Deregister UE3 and UE4
    [Arguments]    ${ue_id1}=3    ${ue_id2}=4
    Execute Egate Command    ue_deregister id=${ue_id1} ue_deregister_type=switch_off    UE${ue_id1}: detached    timeout=10s
    Execute Egate Command    ue_deregister id=${ue_id2} ue_deregister_type=switch_off    UE${ue_id2}: detached    timeout=10s

UE Register Setup PDU Trigger Scell Addition By A1
    [Arguments]    ${ue_capa}    ${ue_id}    ${srsrp_nr}
    UE Register And Setup PDU Session    ue_id=${ue_id}    ue_capa=${ue_capa}
    Trigger Scell Addition By A1    ue_id=${ue_id}    srsrp_nr=${srsrp_nr}

UE register and setup multiple PDU session
    [Arguments]    ${ue_id}    ${ue_capa}    ${qos_flow}=1    ${qosflows_to_activate}=5
    Set UE Parameters Before Attach    ${ue_id}    ${qos_flow}
    Execute Egate Command    ue_register id=${ue_id} ue_nr_capabilities=${ue_capa}    pass_regexp=UE now in NG RM Register
    Execute Egate Command    smf_param id=1 additional_qosflows_to_activate=${qosflows_to_activate}
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1    pass_regexp=QoS Routing Table


5 UE Register Setup PDU Trigger Scell Addition By A1
    UE Register Setup PDU Trigger Scell Addition By A1    ue_id=1    srsrp_nr=61    ue_capa=${case22_UE_1}
    sleep    1s    #sleep 3s to wait counter update
    UE Deregister    ue_id=1
    UE Register Setup PDU Trigger Scell Addition By A1    ue_id=2    srsrp_nr=61    ue_capa=${case22_UE_2}
    sleep    3s    #sleep 3s to wait counter update
    UE Deregister    ue_id=2
    UE Register Setup PDU Trigger Scell Addition By A1    ue_id=3    srsrp_nr=61    ue_capa=${case22_UE_3}
    UE Deregister    ue_id=3
    UE Register Setup PDU Trigger Scell Addition By A1    ue_id=4    srsrp_nr=61    ue_capa=${case22_UE_4}
    UE Deregister    ue_id=4
    sleep    1s    #sleep 3s to wait counter update
    UE Register Setup PDU Trigger Scell Addition By A1    ue_id=5    srsrp_nr=61    ue_capa=${case22_UE_5}
    UE Deregister    ue_id=5
