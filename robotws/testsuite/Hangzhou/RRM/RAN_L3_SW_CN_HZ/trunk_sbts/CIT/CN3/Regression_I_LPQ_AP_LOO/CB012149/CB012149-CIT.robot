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
...               team-CN3ET    owner-feng.2.chen    release-SBTS23R3    CB012149    CIT
Resource          ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
${GNB_CONFIG}    fddtdd_sansa_cmwv/6cells_2T4F
# if FDD cells have a bandwidth > 25MHz, need configure FR1_WB
@{PARAMS_IN_IPHY_XML}    fddFrequencyRange=FR1_WB

@{PARAMS_IN_SWCONFIG}
...    0x10041 = 5    #ERadCcs_AaSysLogOutputMode - UDP logging enabled
...    0x10040 = 1    #ERadCcs_AaSysLogOutputLevel - Severity changed from DEBUG to INFO
...    0x1003F = 1    #ERadCcs_AaSysLogInputLevel - Severity changed from DEBUG to INFO
...    0x340002 = 1    #BSTAT PM debug prints
...    0x340006 = 55118    #enable measurement flag
...    @{rdULCaEnablerPhase}
...    @{rdUseOptimizedDpaAlgo}
...    0x9D0001 = 1    #enable PMStat core flag
...    0x9D0002 = 1    #enable PMStat PM flag
...    0x9D0006 = 55156    #enable measurement flag
...    0x9D000A = 1    #enable PMStat Arr60 flag
...    0x5801CB = 0

@{PARAMS_IN_SWCONFIG_AP}
...    0x10042=0xc0a8c87e
...    0x10043=51011

@{rdULCaEnablerPhase}
...    0x580591=0

@{rdUseOptimizedDpaAlgo}
...    0x58056B=1

@{PARAMS_IN_SCF}
...    @{CB012149}
...    @{CB009169}
...    @{CA}
...    @{NRREL}
...    @{Mobillity}
...    @{VONR}
...    @{Others}
...    @{gscn_Arfcn}
...    @{frameStructureType_setting}
...    @{scellswap}

${Cell1_ssbFrequency}    518430
${Cell2_ssbFrequency}    636576
${Cell13_ssbFrequency}    430830
${Cell11_ssbFrequency}    423850
${Cell12_ssbFrequency}    126990
${Cell_1_TDD_PCI}    50
${Cell_2_TDD_PCI}    51
${Cell_11_FDD_PCI}    60
${Cell_12_FDD_PCI}    61
${Cell_13_FDD_PCI}    62
${Cell_14_FDD_PCI}    63

${carrierAggregationSupportList}    SEPARATOR=
...    ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Any_Sa,ca_Fdd_Fdd,ca_Fr1Tdd_Any_Sa,
...    ca_Fdd_Fr1Tdd_Nsa,ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Fdd_Sa_WithUl,ca_Fdd_Fr1Tdd_Sa_WithUl,ca_Fdd_Fdd_Sa_WithUl

@{CB012149}
...    NRBTS/NRDU-1:ulTxSwitchingSupportList=ca_Fr1T_F_Sa_switchedUl,ca_F_Fr1T_Sa_switchedUl

@{enable_CB012149_1}
...    @{CB012149}
...    ${ulTxSwitchingBoost_1}

@{CB009169}
#...    NRBTS:actGeneralConnectivityGold=true
...    NRBTS/NRDU-1:carrierAggregationSupportList=${carrierAggregationSupportList}
...    NRBTS/NRDU-1:dlToUlContributionRatio=50
...    NRBTS/NRDRB_RLC_AM-1:ulTReassemblyIBCA=40
...    NRBTS/NRDRB_RLC_AM-2:ulTReassemblyIBCA=40
...    NRCELL:maxNumScellsDlFr1=5
...    NRCELL:timingAdvanceOffset=n25600
...    NRCELL:actK1Opt=intra-gNB

@{enable_CB006137}
...    NRBTS/NRDU-1:carrierAggregationSupportList=${carrierAggregationSupportList}
...    NRCELL-1:increasePUSCHPrepTimeULCA=true
...    NRCELL-2:increasePUSCHPrepTimeULCA=true

@{disable_CB012149}
...    NRBTS/NRDU-1:ulTxSwitchingSupportList=none

@{enable_CB012149}
...    @{CB012149}
...    NRCELL-1/NRREL-1:sCellOperationalMode=dlAndUl
...    NRCELL-1/NRREL-2:sCellOperationalMode=dlAndUl
...    NRCELL-1/NRREL-3:sCellOperationalMode=dlAndUl
...    NRCELL-1/NRREL-4:sCellOperationalMode=dlAndUl

@{enable_6137_enable_12149_2}
...    @{enable_CB006137}
...    @{enable_CB012149}
...    ${ulTxSwitchingBoost_2}
...    @{set_A1_A2_delta}

@{set_A1_A2_delta}
...    NRBTS/NRCELL-11:a1MeasSCellAddSsbRsrp:a1ThresholdUlTxSwitchingDelta=0
...    NRBTS/NRCELL-12:a1MeasSCellAddSsbRsrp:a1ThresholdUlTxSwitchingDelta=0
...    NRBTS/NRCELL-13:a1MeasSCellAddSsbRsrp:a1ThresholdUlTxSwitchingDelta=3
...    NRBTS/NRCELL-14:a1MeasSCellAddSsbRsrp:a1ThresholdUlTxSwitchingDelta=3
...    NRBTS/NRCELL-1:a2MeasSCellRelSsbRsrp:a2ThresholdUlTxSwitchingDelta=5
...    NRBTS/NRCELL-2:a2MeasSCellRelSsbRsrp:a2ThresholdUlTxSwitchingDelta=5

@{set_A1_A2_delta_different}
...    NRBTS/NRCELL-11:a1MeasSCellAddSsbRsrp:a1ThresholdUlTxSwitchingDelta=0
...    NRBTS/NRCELL-12:a1MeasSCellAddSsbRsrp:a1ThresholdUlTxSwitchingDelta=0
...    NRBTS/NRCELL-13:a1MeasSCellAddSsbRsrp:a1ThresholdUlTxSwitchingDelta=30
...    NRBTS/NRCELL-14:a1MeasSCellAddSsbRsrp:a1ThresholdUlTxSwitchingDelta=3
...    NRBTS/NRCELL-1:a2MeasSCellRelSsbRsrp:a2ThresholdUlTxSwitchingDelta=5
...    NRBTS/NRCELL-2:a2MeasSCellRelSsbRsrp:a2ThresholdUlTxSwitchingDelta=30
@{gscn_Arfcn}
...    NRCELL-1:nrarfcn=518598
...    NRCELL-1:gscnOrSsPbchArfcn=6480
...    NRCELL-1:chBw=70MHz

...    NRCELL-2:nrarfcn=636666
...    NRCELL-2:gscnOrSsPbchArfcn=7880
...    NRCELL-2:chBw=90MHz

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

...    NRCELL-14/NRCELL_FDD-1:nrarfcnDl=126900
...    NRCELL-14/NRCELL_FDD-1:nrarfcnUl=136100
...    NRCELL-14/NRCELL_FDD-1:chBwDl=10MHz
...    NRCELL-14/NRCELL_FDD-1:chBwUl=10MHz
...    NRCELL-14:gscnOrSsPbchArfcn=1587

# for 10HZ FDD chbw, need to remove BWP coresetDedicated
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
...    NRCELL-1:increasePUSCHPrepTimeULCA=true
...    NRCELL-2:increasePUSCHPrepTimeULCA=true

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
...    NRCELL:a1MeasPCellSwitchSsbRsrp:a1HysteresisPCellSwitchSsbRsrp=1
...    NRCELL:a1MeasPCellSwitchSsbRsrp:a1ThresholdPCellSwitchSsbRsrp=70
...    NRCELL:a2MeasPCellSwitchSsbRsrp:a2TimeToTriggerPCellSwitchSsbRsrp=480ms
...    NRCELL:a2MeasPCellSwitchSsbRsrp:a2HysteresisPCellSwitchSsbRsrp=0
...    NRCELL:a2MeasPCellSwitchSsbRsrp:a2ThresholdPCellSwitchSsbRsrp=40
...    NRCELL:a2MeasPCellSwitchSsbRsrp:pCellSwitchOffsetSsbRsrp=0
...    NRCELL:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=1
...    NRCELL:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=50
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=60
...    NRCELL:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=1
...    NRCELL:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=2560ms
...    NRCELL:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=34
...    NRBTS/NRPMRNL-1:miNrCABMCCP=disabled

@{NRREL}
...    NRCELL-1/NRREL-1:gNbId=1
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:lcrId=11
...    NRCELL-1/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-1:sCellOperationalMode=dlAndUl
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3

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
...    NRCELL-1/NRHOIF-1:freqBandIndicatorNR=66
...    NRCELL-1/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf5
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf20
...    NRCELL-1/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-1:ssbFrequency=${Cell13_ssbFrequency}
...    NRCELL-1/NRHOIF-1:thresholdPCellSwitchTargetRsrp=70
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
...    NRCELL-1/NRHOIF-2:ssbFrequency=${Cell2_ssbFrequency}
...    NRCELL-1/NRHOIF-2:thresholdPCellSwitchTargetRsrp=70
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
...    NRCELL-1/NRHOIF-3:ssbFrequency=${Cell12_ssbFrequency}
...    NRCELL-1/NRHOIF-3:thresholdPCellSwitchTargetRsrp=70
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
...    NRCELL-1/NRHOIF-4:ssbFrequency=${Cell11_ssbFrequency}
...    NRCELL-1/NRHOIF-4:thresholdPCellSwitchTargetRsrp=70
...    NRCELL-1/NRHOIF-4:thresholdPCellSwitchTargetRsrq=20
...    NRCELL-1/NRHOIF-4:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms320
...    NRCELL-1/NRHOIF-4:a3MeasSsbRsrp:a3OffsetSsbRsrp=5

...    NRCELL-2/NRHOIF-1:a1BasedPCellSwitchEnabled=true
...    NRCELL-2/NRHOIF-1:a2BasedPCellSwitchEnabled=true
...    NRCELL-2/NRHOIF-1:a2BasedPCellSwitchPriority=1
...    NRCELL-2/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-2/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-2/NRHOIF-1:freqBandIndicatorNR=41
...    NRCELL-2/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-2/NRHOIF-1:ifhoSsbSmtcDuration=sf5
...    NRCELL-2/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf20
...    NRCELL-2/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-2/NRHOIF-1:ssbFrequency=${Cell13_ssbFrequency}
...    NRCELL-2/NRHOIF-1:thresholdPCellSwitchTargetRsrp=70
...    NRCELL-2/NRHOIF-1:thresholdPCellSwitchTargetRsrq=20
...    NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms320
...    NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=5

...    NRCELL-2/NRHOIF-2:a1BasedPCellSwitchEnabled=true
...    NRCELL-2/NRHOIF-2:a2BasedPCellSwitchEnabled=true
...    NRCELL-2/NRHOIF-2:a2BasedPCellSwitchPriority=1
...    NRCELL-2/NRHOIF-2:a3MeasEnabled=rsrp
...    NRCELL-2/NRHOIF-2:cellDepType=SA+NSA
...    NRCELL-2/NRHOIF-2:freqBandIndicatorNR=41
...    NRCELL-2/NRHOIF-2:ifhoSsbScs=30 KHz
...    NRCELL-2/NRHOIF-2:ifhoSsbSmtcDuration=sf5
...    NRCELL-2/NRHOIF-2:ifhoSsbSmtcPeriodicity=sf20
...    NRCELL-2/NRHOIF-2:ssBurstSetPeriod=20
...    NRCELL-2/NRHOIF-2:ssbFrequency=${Cell1_ssbFrequency}
...    NRCELL-2/NRHOIF-2:thresholdPCellSwitchTargetRsrp=70
...    NRCELL-2/NRHOIF-2:thresholdPCellSwitchTargetRsrq=20
...    NRCELL-2/NRHOIF-2:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms320
...    NRCELL-2/NRHOIF-2:a3MeasSsbRsrp:a3OffsetSsbRsrp=5

...    NRCELL-2/NRHOIF-3:a1BasedPCellSwitchEnabled=true
...    NRCELL-2/NRHOIF-3:a2BasedPCellSwitchEnabled=true
...    NRCELL-2/NRHOIF-3:a2BasedPCellSwitchPriority=1
...    NRCELL-2/NRHOIF-3:a3MeasEnabled=rsrp
...    NRCELL-2/NRHOIF-3:cellDepType=SA+NSA
...    NRCELL-2/NRHOIF-3:freqBandIndicatorNR=71
...    NRCELL-2/NRHOIF-3:ifhoSsbScs=15KHz
...    NRCELL-2/NRHOIF-3:ifhoSsbSmtcDuration=sf5
...    NRCELL-2/NRHOIF-3:ifhoSsbSmtcPeriodicity=sf20
...    NRCELL-2/NRHOIF-3:ssBurstSetPeriod=20
...    NRCELL-2/NRHOIF-3:ssbFrequency=${Cell12_ssbFrequency}
...    NRCELL-2/NRHOIF-3:thresholdPCellSwitchTargetRsrp=70
...    NRCELL-2/NRHOIF-3:thresholdPCellSwitchTargetRsrq=20
...    NRCELL-2/NRHOIF-3:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms320
...    NRCELL-2/NRHOIF-3:a3MeasSsbRsrp:a3OffsetSsbRsrp=5

...    NRCELL-2/NRHOIF-4:a1BasedPCellSwitchEnabled=true
...    NRCELL-2/NRHOIF-4:a2BasedPCellSwitchEnabled=true
...    NRCELL-2/NRHOIF-4:a2BasedPCellSwitchPriority=1
...    NRCELL-2/NRHOIF-4:a3MeasEnabled=rsrp
...    NRCELL-2/NRHOIF-4:cellDepType=SA+NSA
...    NRCELL-2/NRHOIF-4:freqBandIndicatorNR=66
...    NRCELL-2/NRHOIF-4:ifhoSsbScs=15KHz
...    NRCELL-2/NRHOIF-4:ifhoSsbSmtcDuration=sf5
...    NRCELL-2/NRHOIF-4:ifhoSsbSmtcPeriodicity=sf20
...    NRCELL-2/NRHOIF-4:ssBurstSetPeriod=20
...    NRCELL-2/NRHOIF-4:ssbFrequency=${Cell11_ssbFrequency}
...    NRCELL-2/NRHOIF-4:thresholdPCellSwitchTargetRsrp=70
...    NRCELL-2/NRHOIF-4:thresholdPCellSwitchTargetRsrq=20
...    NRCELL-2/NRHOIF-4:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms320
...    NRCELL-2/NRHOIF-4:a3MeasSsbRsrp:a3OffsetSsbRsrp=5

...    NRBTS/NRPMRNL-1:miNrNgcFlexInterface=disabled
...    NRBTS/NRPMRNL-1:miNrIntraGnbMobilitySaPmqap=disabled
...    NRBTS/NRPMRNL-1:miNrIntraGnbMobilityNsaPmqap=disabled
...    NRBTS/NRPMRNL-1:miNrInterGnbXnMobilitySaPmqap=disabled
...    NRBTS/NRPMRNL-1:miNrInterGnbNgMobilitySaPmqap=disabled
...    NRBTS/NRPMRNL-1:miNrInterGnbMobilityNsaPmqap=disabled

...    NRCELL-13/NRREL-1:gNbId=1
...    NRCELL-13/NRREL-1:gNbIdLength=22
...    NRCELL-13/NRREL-1:lcrId=11
...    NRCELL-13/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-13/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-13/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-1:gnbPlmn:mncLength=3

...    NRCELL-13/NRREL-2:gNbId=1
...    NRCELL-13/NRREL-2:gNbIdLength=22
...    NRCELL-13/NRREL-2:lcrId=12
...    NRCELL-13/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-13/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-13/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-13/NRREL-2:sCellPrio=1

...    NRCELL-13/NRREL-3:gNbId=1
...    NRCELL-13/NRREL-3:gNbIdLength=22
...    NRCELL-13/NRREL-3:lcrId=1
...    NRCELL-13/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-13/NRREL-3:sCellOperationalMode=dlAndUl
...    NRCELL-13/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-3:gnbPlmn:mncLength=3

...    NRCELL-13/NRREL-4:gNbId=1
...    NRCELL-13/NRREL-4:gNbIdLength=22
...    NRCELL-13/NRREL-4:lcrId=14
...    NRCELL-13/NRREL-4:sCellAdditionMethod=covBasedA1
...    NRCELL-13/NRREL-4:sCellOperationalMode=dlOnly
...    NRCELL-13/NRREL-4:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-4:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-4:gnbPlmn:mncLength=3
...    NRCELL-13/NRREL-4:sCellPrio=2

...    NRCELL-13/NRREL-5:gNbId=1
...    NRCELL-13/NRREL-5:gNbIdLength=22
...    NRCELL-13/NRREL-5:lcrId=2
...    NRCELL-13/NRREL-5:sCellAdditionMethod=covBasedA1
...    NRCELL-13/NRREL-5:sCellOperationalMode=dlAndUl
...    NRCELL-13/NRREL-5:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-5:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-5:gnbPlmn:mncLength=3

...    NRCELL-13/NRHOIF-1:a1BasedPCellSwitchEnabled=true
...    NRCELL-13/NRHOIF-1:a2BasedPCellSwitchEnabled=true
...    NRCELL-13/NRHOIF-1:a2BasedPCellSwitchPriority=1
...    NRCELL-13/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-13/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-13/NRHOIF-1:freqBandIndicatorNR=41
...    NRCELL-13/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-13/NRHOIF-1:ifhoSsbSmtcDuration=sf5
...    NRCELL-13/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf20
...    NRCELL-13/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-13/NRHOIF-1:ssbFrequency=${Cell1_ssbFrequency}
...    NRCELL-13/NRHOIF-1:thresholdPCellSwitchTargetRsrp=70
...    NRCELL-13/NRHOIF-1:thresholdPCellSwitchTargetRsrq=20
...    NRCELL-13/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms320
...    NRCELL-13/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=5

...    NRCELL-13/NRHOIF-2:a1BasedPCellSwitchEnabled=true
...    NRCELL-13/NRHOIF-2:a2BasedPCellSwitchEnabled=true
...    NRCELL-13/NRHOIF-2:a2BasedPCellSwitchPriority=1
...    NRCELL-13/NRHOIF-2:a3MeasEnabled=rsrp
...    NRCELL-13/NRHOIF-2:cellDepType=SA+NSA
...    NRCELL-13/NRHOIF-2:freqBandIndicatorNR=78
...    NRCELL-13/NRHOIF-2:ifhoSsbScs=30 KHz
...    NRCELL-13/NRHOIF-2:ifhoSsbSmtcDuration=sf5
...    NRCELL-13/NRHOIF-2:ifhoSsbSmtcPeriodicity=sf20
...    NRCELL-13/NRHOIF-2:ssBurstSetPeriod=20
...    NRCELL-13/NRHOIF-2:ssbFrequency=${Cell2_ssbFrequency}
...    NRCELL-13/NRHOIF-2:thresholdPCellSwitchTargetRsrp=70
...    NRCELL-13/NRHOIF-2:thresholdPCellSwitchTargetRsrq=20
...    NRCELL-13/NRHOIF-2:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms320
...    NRCELL-13/NRHOIF-2:a3MeasSsbRsrp:a3OffsetSsbRsrp=5

...    NRCELL-13/NRHOIF-3:a1BasedPCellSwitchEnabled=true
...    NRCELL-13/NRHOIF-3:a2BasedPCellSwitchEnabled=true
...    NRCELL-13/NRHOIF-3:a2BasedPCellSwitchPriority=1
...    NRCELL-13/NRHOIF-3:a3MeasEnabled=rsrp
...    NRCELL-13/NRHOIF-3:cellDepType=SA+NSA
...    NRCELL-13/NRHOIF-3:freqBandIndicatorNR=71
...    NRCELL-13/NRHOIF-3:ifhoSsbScs=15KHz
...    NRCELL-13/NRHOIF-3:ifhoSsbSmtcDuration=sf5
...    NRCELL-13/NRHOIF-3:ifhoSsbSmtcPeriodicity=sf20
...    NRCELL-13/NRHOIF-3:ssBurstSetPeriod=20
...    NRCELL-13/NRHOIF-3:ssbFrequency=${Cell12_ssbFrequency}
...    NRCELL-13/NRHOIF-3:thresholdPCellSwitchTargetRsrp=70
...    NRCELL-13/NRHOIF-3:thresholdPCellSwitchTargetRsrq=20
...    NRCELL-13/NRHOIF-3:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms320
...    NRCELL-13/NRHOIF-3:a3MeasSsbRsrp:a3OffsetSsbRsrp=5

...    NRCELL-13/NRHOIF-4:a1BasedPCellSwitchEnabled=true
...    NRCELL-13/NRHOIF-4:a2BasedPCellSwitchEnabled=true
...    NRCELL-13/NRHOIF-4:a2BasedPCellSwitchPriority=1
...    NRCELL-13/NRHOIF-4:a3MeasEnabled=rsrp
...    NRCELL-13/NRHOIF-4:cellDepType=SA+NSA
...    NRCELL-13/NRHOIF-4:freqBandIndicatorNR=66
...    NRCELL-13/NRHOIF-4:ifhoSsbScs=15KHz
...    NRCELL-13/NRHOIF-4:ifhoSsbSmtcDuration=sf5
...    NRCELL-13/NRHOIF-4:ifhoSsbSmtcPeriodicity=sf20
...    NRCELL-13/NRHOIF-4:ssBurstSetPeriod=20
...    NRCELL-13/NRHOIF-4:ssbFrequency=${Cell11_ssbFrequency}
...    NRCELL-13/NRHOIF-4:thresholdPCellSwitchTargetRsrp=70
...    NRCELL-13/NRHOIF-4:thresholdPCellSwitchTargetRsrq=20
...    NRCELL-13/NRHOIF-4:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms320
...    NRCELL-13/NRHOIF-4:a3MeasSsbRsrp:a3OffsetSsbRsrp=5

...    NRCELL-11/NRREL-1:gNbId=1
...    NRCELL-11/NRREL-1:gNbIdLength=22
...    NRCELL-11/NRREL-1:lcrId=1
...    NRCELL-11/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-1:sCellOperationalMode=dlAndUl
...    NRCELL-11/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-1:gnbPlmn:mncLength=3

...    NRCELL-11/NRREL-2:gNbId=1
...    NRCELL-11/NRREL-2:gNbIdLength=22
...    NRCELL-11/NRREL-2:lcrId=2
...    NRCELL-11/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-2:sCellOperationalMode=dlAndUl
...    NRCELL-11/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-2:gnbPlmn:mncLength=3

...    NRCELL-11/NRREL-3:gNbId=1
...    NRCELL-11/NRREL-3:gNbIdLength=22
...    NRCELL-11/NRREL-3:lcrId=12
...    NRCELL-11/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-3:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-3:sCellPrio=1

...    NRCELL-11/NRREL-4:gNbId=1
...    NRCELL-11/NRREL-4:gNbIdLength=22
...    NRCELL-11/NRREL-4:lcrId=13
...    NRCELL-11/NRREL-4:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-4:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-4:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-4:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-4:gnbPlmn:mncLength=3

...    NRCELL-11/NRREL-5:gNbId=1
...    NRCELL-11/NRREL-5:gNbIdLength=22
...    NRCELL-11/NRREL-5:lcrId=14
...    NRCELL-11/NRREL-5:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-5:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-5:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-5:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-5:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-5:sCellPrio=2

...    NRCELL-11/NRHOIF-1:a1BasedPCellSwitchEnabled=true
...    NRCELL-11/NRHOIF-1:a2BasedPCellSwitchEnabled=true
...    NRCELL-11/NRHOIF-1:a2BasedPCellSwitchPriority=1
...    NRCELL-11/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-11/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-11/NRHOIF-1:freqBandIndicatorNR=78
...    NRCELL-11/NRHOIF-1:ifhoSsbSmtcDuration=sf5
...    NRCELL-11/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf20
...    NRCELL-11/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-11/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-11/NRHOIF-1:ssbFrequency=${cell_2_ssbFrequency}
...    NRCELL-11/NRHOIF-1:thresholdPCellSwitchTargetRsrp=60
...    NRCELL-11/NRHOIF-1:thresholdPCellSwitchTargetRsrq=20
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms320
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=5

...    NRCELL-11/NRHOIF-2:a1BasedPCellSwitchEnabled=true
...    NRCELL-11/NRHOIF-2:a2BasedPCellSwitchEnabled=true
...    NRCELL-11/NRHOIF-2:a2BasedPCellSwitchPriority=1
...    NRCELL-11/NRHOIF-2:a3MeasEnabled=rsrp
...    NRCELL-11/NRHOIF-2:cellDepType=SA+NSA
...    NRCELL-11/NRHOIF-2:freqBandIndicatorNR=41
...    NRCELL-11/NRHOIF-2:ifhoSsbSmtcDuration=sf5
...    NRCELL-11/NRHOIF-2:ifhoSsbSmtcPeriodicity=sf20
...    NRCELL-11/NRHOIF-2:ifhoSsbScs=30 KHz
...    NRCELL-11/NRHOIF-2:ssBurstSetPeriod=20
...    NRCELL-11/NRHOIF-2:ssbFrequency=${cell_1_ssbFrequency}
...    NRCELL-11/NRHOIF-2:thresholdPCellSwitchTargetRsrp=60
...    NRCELL-11/NRHOIF-2:thresholdPCellSwitchTargetRsrq=20
...    NRCELL-11/NRHOIF-2:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms320
...    NRCELL-11/NRHOIF-2:a3MeasSsbRsrp:a3OffsetSsbRsrp=5

...    NRCELL-11/NRHOIF-3:a1BasedPCellSwitchEnabled=true
...    NRCELL-11/NRHOIF-3:a2BasedPCellSwitchEnabled=true
...    NRCELL-11/NRHOIF-3:a2BasedPCellSwitchPriority=1
...    NRCELL-11/NRHOIF-3:a3MeasEnabled=rsrp
...    NRCELL-11/NRHOIF-3:cellDepType=SA+NSA
...    NRCELL-11/NRHOIF-3:freqBandIndicatorNR=71
...    NRCELL-11/NRHOIF-3:ifhoSsbSmtcDuration=sf5
...    NRCELL-11/NRHOIF-3:ifhoSsbSmtcPeriodicity=sf20
...    NRCELL-11/NRHOIF-3:ifhoSsbScs=15KHz
...    NRCELL-11/NRHOIF-3:ssBurstSetPeriod=20
...    NRCELL-11/NRHOIF-3:ssbFrequency=${cell_12_ssbFrequency}
...    NRCELL-11/NRHOIF-3:thresholdPCellSwitchTargetRsrp=60
...    NRCELL-11/NRHOIF-3:thresholdPCellSwitchTargetRsrq=20
...    NRCELL-11/NRHOIF-3:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms320
...    NRCELL-11/NRHOIF-3:a3MeasSsbRsrp:a3OffsetSsbRsrp=5

...    NRCELL-11/NRHOIF-4:a1BasedPCellSwitchEnabled=true
...    NRCELL-11/NRHOIF-4:a2BasedPCellSwitchEnabled=true
...    NRCELL-11/NRHOIF-4:a2BasedPCellSwitchPriority=1
...    NRCELL-11/NRHOIF-4:a3MeasEnabled=rsrp
...    NRCELL-11/NRHOIF-4:cellDepType=SA+NSA
...    NRCELL-11/NRHOIF-4:freqBandIndicatorNR=66
...    NRCELL-11/NRHOIF-4:ifhoSsbSmtcDuration=sf5
...    NRCELL-11/NRHOIF-4:ifhoSsbSmtcPeriodicity=sf20
...    NRCELL-11/NRHOIF-4:ifhoSsbScs=15KHz
...    NRCELL-11/NRHOIF-4:ssBurstSetPeriod=20
...    NRCELL-11/NRHOIF-4:ssbFrequency=${cell_13_ssbFrequency}
...    NRCELL-11/NRHOIF-4:thresholdPCellSwitchTargetRsrp=60
...    NRCELL-11/NRHOIF-4:thresholdPCellSwitchTargetRsrq=20
...    NRCELL-11/NRHOIF-4:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms320
...    NRCELL-11/NRHOIF-4:a3MeasSsbRsrp:a3OffsetSsbRsrp=5

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
...    NRCELL:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=36
...    NRCELL:a1MeashoSsbRsrpSA:a1TimeToTriggerHoSsbRsrpVoNr=${EMPTY}
...    NRCELL:a1MeashoSsbRsrpSA:a1ThresholdHoSsbRsrpVoNr=${EMPTY}
...    NRCELL:a1MeashoSsbRsrpSA:a1HysteresisHoSsbRsrpVoNr=${EMPTY}
...    NRCELL:a2MeashoSsbRsrpSA:a2HysteresisHoSsbRsrpVoNr=${EMPTY}
...    NRCELL:a2MeashoSsbRsrpSA:a2ThresholdHoSsbRsrpVoNr=${EMPTY}
...    NRCELL:a2MeashoSsbRsrpSA:a2TimeToTriggerHoSsbRsrpVoNr=${EMPTY}

@{VONR}
...    NRCELL:actVoNR=true
...    NRCELL:actEnhancedVoNR=true

@{frameStructureType_setting}
...    NRCELL-1:tddFrameStructure:frameStructureType=semiStatic
...    NRCELL-1:tddFrameStructure:ulDlDataSlotRatio=1/4
...    NRCELL-1:prachConfigurationIndex=98
...    NRCELL-1:tddFrameStructure:guardPeriodLength=2Symbols
...    delete:NRCELL-1:tddFrameStructure:lteToNrFrameShift
...    NRCELL-2:tddFrameStructure:frameStructureType=semiStatic
...    NRCELL-2:tddFrameStructure:ulDlDataSlotRatio=1/4
...    NRCELL-2:prachConfigurationIndex=98
...    NRCELL-2:tddFrameStructure:guardPeriodLength=2Symbols
...    delete:NRCELL-2:tddFrameStructure:lteToNrFrameShift

${SYSCOM_FLAG}    true

${ulTxSwitchingBoost_1.1}
...    NRBTS:ulTxSwitchingBoost=11

${ulTxSwitchingBoost_2}
...    NRBTS:ulTxSwitchingBoost=20

${ulTxSwitchingBoost_1}
...    NRBTS:ulTxSwitchingBoost=10

@{ulTxSwitchingBoost_1.1_set_a1a2_delta}
...    ${ulTxSwitchingBoost_1.1}
...    @{set_A1_A2_delta_different}

@{scellswap}
...    NRBTS:actSCellSwapFr1=a6BasedSa

...    NRCELL-12:a6MeasSCellSwapEnabled=rsrp
...    NRCELL-12:a6MeasSCellSwapSsbRsrp:a6OffsetSCellSwapSsbRsrp=6
...    NRCELL-12:reportAmountA6MeasSCellSwap=r4
...    NRCELL-12:reportIntervalA6MeasSCellSwap=ms1024
...    NRCELL-12:thresholdSCellSwapSourceRsrp=70

...    NRCELL-14:a6MeasSCellSwapEnabled=rsrp
...    NRCELL-14:a6MeasSCellSwapSsbRsrp:a6OffsetSCellSwapSsbRsrp=6
...    NRCELL-14:reportAmountA6MeasSCellSwap=r4
...    NRCELL-14:reportIntervalA6MeasSCellSwap=ms1024
...    NRCELL-14:thresholdSCellSwapSourceRsrp=70


${6CC_UE_capa}    SEPARATOR=
...    E9A09000575F5A13160003C5200016093170019C3D0B004D9061CF9863CA160704C060188E02771B0A303582308682041D211001B5B262AC
...    6873E238F40CFB027C62471E439F51CF9863CA1607038782E007FE003801FF8003640001C006CAAAA8AAAA80A83620EB04610D04083C4220
...    032B64C55890E7D813E238F1891C790E7D473E618F28581C0E1E13FFE00000FFF800000D80000702A8D89BAC1184341020E908800C2D9315
...    44439F11C788E3D033EC09F18E7CC31E50B0381C3C17003FF001C00FFC001B20000E00365FFFE5FFFE0551B133582308682041D21100185B
...    262A88873E238F11C7A067D813E31CF9863CA1607038782E007FE003801FF8003640001C006CBFFFCBFFFC0AE3E236B04610D04083E50880
...    0AAD931561439F11C78C0000000000000000000001E027FFC00001FFF000001B00000E0033C3C28000C26800002C040BC5C28000E2080071
...    180000085808178F850001C41000C2301C4600000416020562E1400061040E208000010B02B2F0A0003882001C41000E23000711800389A0
...    000182C0ACDC28000E20800710400388C001C46000E230007134000038581007011A014404D808236C000C818100800C0020050001800005
...    830C6318C667208C270785000184D0001858081040600408C258B850001C41000E230000080B02100300204612CBC28000E2080061180E23
...    000710400389A0000142C08A00030820442A30966E1400061040E20800711800388C001C46000E268000040B023000030840413200F41F00
...    078005038280381804A00E000C0480080C07C050040000000200000401000004008000030040000200200001405E54560A5E54DE0EDA5568
...    2D00C1000009652404000065949010000296525040000E5949003F2A82B82C37CAACBA0D143C00BC04A8140A05028140A05028140A050281
...    40A05028140A0010103002006004008180100300200440600400C008010300400A008010180200500400860600400C008010300400A00801
...    018020050040080C0100280200410300200E00C0181801003006004C0600401C008030300400A00801018020050040080C01002802004060
...    08014010020300400A008010180100700200CA0600401C008030300400A00801018020050040080C0100280200406008014010020300200E
...    00401940C0280180500206018014030020300C00A018010180600500C0080C030028060040601400C0280130180500300A0040C030028060
...    0406018014030020300C00A018010180600500C0080C020028040040601400C028011008010060200801008010063543E00020406080C0E1
...    416181A2022242628303236383A3E424A4C4E5052545A5E828305A


@{disable_actVoNR_enable_actCDrx}
...    NRCELL:actCDrx=true
...    NRCELL:actVoNR=false
...    NRCELL:actEnhancedVoNR=false

${UE_PCELL_1_CONF_SCELL_UL_SA}    M55118C10005
${UE_SCELL_1_CONF_SCELL_UL_SA}    M55118C10006
${RRC_RECONF_ADD1ULSCELL_ATT_SA}    M55118C10001
${RRC_RECONF_ADD1ULSCELL_SUCC_SA}    M55118C10002

@{Counters_Check}
...    NRCELL-1:${ACC_NUM_UL_TX_SW_OP1_UE_CAP}>1
...    NRCELL-1:${ACC_NUM_UL_TX_SW_OP1_UE_CONFG}>1
...    NRCELL-1:${DEN_1_SEC_SAMPLE}>1
...    NRCELL-1:${DEN_1_SEC_SAMPLE}<=660
...    NRCELL-1:${AVG_NUM_UE_DENOM}>1
...    NRCELL-1:${AVG_NUM_UE_DENOM}<=660
...    NRCELL-1:${SUM_SA_UE_FULL_PWR_FR1}=0
...    NRCELL-1:${SUM_SA_UE_FULL_PWR1_FR1}=0
...    NRCELL-1:${SUM_SA_UE_FULL_PWR2_FR1}=0
...    NRCELL-1:${DENOM_UE_FULL_PWR_FR1}=0
...    NRCELL-1:${MAX_SA_UES_FULL_PWR_FR1}=0
...    NRCELL-1:${MAX_SA_UES_FULL_PWR1_FR1}=0
...    NRCELL-1:${MAX_SA_UES_FULL_PWR2_FR1}=0
...    NRCELL-13:${ACC_NUM_UL_TX_SW_OP1_UE_CAP}>1
...    NRCELL-13:${ACC_NUM_UL_TX_SW_OP1_UE_CONFG}>1
...    NRCELL-13:${DEN_1_SEC_SAMPLE}>1
...    NRCELL-13:${DEN_1_SEC_SAMPLE}<=660
...    NRCELL-13:${AVG_NUM_UE_DENOM}>1
...    NRCELL-13:${AVG_NUM_UE_DENOM}<=660

...    NRCELL-11:${ACC_NUM_UL_TX_SW_OP1_UE_CAP}>1
...    NRCELL-11:${ACC_NUM_UL_TX_SW_OP1_UE_CONFG}>1
...    NRCELL-11:${DEN_1_SEC_SAMPLE}>1
...    NRCELL-11:${DEN_1_SEC_SAMPLE}<=660
...    NRCELL-11:${AVG_NUM_UE_DENOM}>1
...    NRCELL-11:${AVG_NUM_UE_DENOM}<=660

...    NRCELL-1:NCAC:${UE_PCELL_1_CONF_SCELL_UL_SA}>1
...    NRCELL-13:NCAC:${UE_PCELL_1_CONF_SCELL_UL_SA}>1
...    NRCELL-11:NCAC:${UE_PCELL_1_CONF_SCELL_UL_SA}>1
...    NRCELL-2:NCAC:${UE_SCELL_1_CONF_SCELL_UL_SA}>1
...    NRCELL-13:NCAC:${UE_SCELL_1_CONF_SCELL_UL_SA}>1
...    NRCELL-12:NCAC:${UE_SCELL_1_CONF_SCELL_UL_SA}=0
...    NRCELL-14:NCAC:${UE_SCELL_1_CONF_SCELL_UL_SA}=0
...    NRCELL-11:NCAC:${A2MEAS_REL1ULSCELL_ATT_SA}=1
...    NRCELL-11:NCAC:${A2MEAS_REL1ULSCELL_SUCC_SA}=1
...    NRCELL-13:NCAC:${A2MEAS_REL1ULSCELL_ATT_SA}=1
...    NRCELL-13:NCAC:${A2MEAS_REL1ULSCELL_SUCC_SA}=1
...    NRCELL-1:NCAC:${RRC_RECONF_ADD1ULSCELL_ATT_SA}=1
...    NRCELL-1:NCAC:${RRC_RECONF_ADD1ULSCELL_SUCC_SA}=1
...    NRCELL-13:NCAC:${RRC_RECONF_ADD1ULSCELL_ATT_SA}=2
...    NRCELL-13:NCAC:${RRC_RECONF_ADD1ULSCELL_SUCC_SA}=2
...    NRCELL-11:NCAC:${RRC_RECONF_ADD1ULSCELL_ATT_SA}=1
...    NRCELL-11:NCAC:${RRC_RECONF_ADD1ULSCELL_SUCC_SA}=1
...    NRCELL-13:${SCELL_SWAP_1_ATT_SA}=2
...    NRCELL-13:${SCELL_SWAP_1_SUCC_SA}=2
...    NRCELL-13:${SCELL_CHANGE_ATT_SA}=1
...    NRCELL-13:${SCELL_CHANGE_SUCC_SA}=1
...    NRCELL-11:${SCELL_CHANGE_ATT_SA}=1
...    NRCELL-11:${SCELL_CHANGE_SUCC_SA}=1

${A2MEAS_REL1ULSCELL_ATT_SA}    M55118C10003
${A2MEAS_REL1ULSCELL_SUCC_SA}    M55118C10004

${SCELL_SWAP_1_ATT_SA}    M55118C10501
${SCELL_SWAP_1_SUCC_SA}    M55118C10502

${SCELL_CHANGE_ATT_SA}    M55118C06506    #need to add a note that SCell swaps are excluded
${SCELL_CHANGE_SUCC_SA}    M55118C06507    #need to add a note that SCell swaps are excluded


#CB008698 counter
${ACC_NUM_UL_TX_SW_OP1_UE_CAP}    M55181C00010
${ACC_NUM_UL_TX_SW_OP1_UE_CONFG}    M55118C00053
${DEN_1_SEC_SAMPLE}    M55118C00054
${AVG_NUM_UE_DENOM}    M55181C00003

${SUM_SA_UE_FULL_PWR_FR1}    M55114C01501
${SUM_SA_UE_FULL_PWR1_FR1}    M55114C01502
${SUM_SA_UE_FULL_PWR2_FR1}    M55114C01503
${DENOM_UE_FULL_PWR_FR1}    M55114C01505
${MAX_SA_UES_FULL_PWR_FR1}    M55156C00001
${MAX_SA_UES_FULL_PWR1_FR1}    M55156C00002
${MAX_SA_UES_FULL_PWR2_FR1}    M55156C00003

*** Test Cases ***
CB012149-SR-DA_ET_ultxswitch CA is correct for different operations
    [Tags]    TC_CIT
    OnlineParamChange    ${enable_6137_enable_12149_2}
    Clear Counter files
    Ue with specified capabilitiy Register And Pdu Session Setup At FDD Cell-13    ue_id=1    ue_capa=${6CC_UE_capa}
    Send And Verify Throughput    ue_id=1
    Send A1 report to trigger ultxswitch 5CC on FDD Cell-13    #ultxswitch 62+50+51*+60+61
    Trigger Scell Swap By A6 from FDD Cell-12 to FDD Cell-14    #ultxswitch 62+50+51*+60+63
    Trigger PCell change From FDD Cell-13 to FDD Cell-11 and check ultxswitch 5CC CA    #ultxswitch 60+50+51*+61+62
    OnlineParamChange    ${disable_CB012149}
    Stepwise Release All TDD Scell and Trigger Scell change to normal 3CC CA    #normal 60+50+51*
    OnlineParamChange    ${enable_CB012149_1}
    Trigger PCell change from FDD Cell-11 to TDD Cell-1 and check ultxswitch 5CC CA    #ultxswitch 50+51+60+61+62*
    OnlineParamChange    ${ulTxSwitchingBoost_1.1_set_a1a2_delta}
    Send A2 A3 report to trigger intra-gnb handover to FDD cell-13 from cell-1 and check normal 5CC    #normal 62+50+51*+60+61
    Trigger Scell Swap By A6 from FDD Cell-12 to FDD Cell-14 check no UlTxswitch
    Stepwise Release All TDD Scell and Trigger Scell change to ultxswitch 3CC CA    #ultxswitch 62+50+51*
    Detach UE    ue_id=1
    Check Counters    ${Counters_Check}

*** Keywords ***
Modify Cfg
    FOR    ${gateway_id}    IN RANGE    1    11
        Update Cfg    set_pdu_gateway id=${gateway_id} ue_nat_ip=72.23.${gateway_id}.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    END
    ${V2}    catenate
    ...    ue_param id=1-10 ue_nr_capabilities=${SA_Capa_perUE_Full}
    ${V3}    catenate
    ...    set_ue simulated id=1 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...    nea=null+snow3g+aes+zuc nia=null+snow3g+aes+zuc sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0000:0:0:021645400
    ...    enb=2 cell=1 mode=nr
    Update Cfg    ${V2}
    Update Cfg    ${V3}

Start BTS With Specified Config Files
    Common Suite Setup
    Setup Airphone Env    tl_type=${GNB_CONFIG}
    Execute Egate Command    gnb_param id=3 sib1_period=3000
    Execute Egate Command    ib_enb_cell_disp enb=3 cell=1
    Set UE Parameters Before Register

Set UE Parameters Before Register
    set UE history info    ue_id=1    history_id=1
    Execute Egate Command    gnb_param id=3 xn_listening_socket=1 send_xn_setup=true measEvent=A3
    Execute Egate Command    gnb_xn_link_up gnb=3 target=2    GNB-3: XnAP Link with GNB-2
    Execute Egate Command    set_pdu_param ue=1 pdu=1 trf_type=internal
    Execute Egate Command    set_pdu_param ue=1 pdu=2 trf_type=internal

set UE history info
    [Arguments]    ${ue_id}=1    ${history_id}=1
    Execute Egate Command
    ...    ue_history_information_list_add_ngran id=${history_id} cell_type=large nrcgi=311:489|0x01 gnb_id=2 time_ue_stayed_in_cell=97
    Execute Egate Command
    ...    ue_history_information_list_add_ngran id=${history_id} cell_type=large nrcgi=311:489|0x01 gnb_id=3 time_ue_stayed_in_cell=98
    Execute Egate Command    ue_history_information_list id=${history_id} action=commit
    Execute Egate Command    ue_enb_param id=${ue_id} ue_history_list=${history_id}
    Execute Egate Command    ue_enb_param id=2 ue_history_list=${history_id}

Scell A2 report to trigger Scell Release
    [Arguments]    ${ue_id}=31    ${carrierfreq}=${Cell2_ssbFrequency}    ${scell_id}=2    ${pass_regexp}=rrcReconfigurationComplete
    ${measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A2
    ${A2_Scell_Release}    catenate
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${measid} scell=${scell_id} scell_rsrp=20 scell_rsrq=0 event=A2
    ${ret1}=    Execute Egate Command    ${A2_Scell_Release}    pass_regexp=${pass_regexp}
    Should Contain    ${ret1}    sCellToReleaseList

Detach UE
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    detached

Ue with specified capabilitiy Register And Pdu Session Setup At FDD Cell-13
    [Arguments]    ${ue_id}    ${ue_capa}
    Execute Egate Command    ue_location_change id=${ue_id} enb=2 cell=13
    Execute Egate Command    ue_register id=${ue_id} ue_nr_capabilities=${ue_capa}    pass_regexp=UE now in NG RM Registere
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=${ue_id} nwslice=1    pass_regexp=QoS Routing Table

Send A2 A3 report to trigger intra-gnb handover to FDD cell-13 from cell-1 and check normal 5CC
    [Arguments]    ${ue_id}=1
    UE Report InterFrequency A2 event    ue_id=${ue_id}    carrierfreq=${Cell1_ssbFrequency}
    ${expect_output}    Create List
    ...    rrcReconfigurationComplete
    ...    pcid:${Cell_1_TDD_PCI}, scellIdx:1
    ...    pcid:${Cell_2_TDD_PCI}, scellIdx:2
    ...    pcid:${Cell_11_FDD_PCI}, scellIdx:3
    ...    pcid:${Cell_12_FDD_PCI}, scellIdx:4
    UE Report InterFrequency A3 event and check no ultxswitch    ue_id=${ue_id}    carrierfreq=${Cell13_ssbFrequency}    phycell_id=62
    ...    pass_regexp=${expect_output}
    Verify Throughput When 4 Scells

UE Report InterFrequency A2 event
    [Arguments]    ${ue_id}=1    ${carrierfreq}=${Cell1_ssbFrequency}    ${srsrp_nr}=34    ${srsrq_nr}=20    ${a2_thres}=36
    ${measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}
    ...    event_type=A2    measho_type=RSRP    threshold=${a2_thres}
    ${ret3}=    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${measid} event=A2 srsrp_nr=${srsrp_nr} srsrq_nr=${srsrq_nr}
    ...    pass_regexp=eventA3

UE Report InterFrequency A3 event and check no ultxswitch
    [Arguments]    ${ue_id}=1    ${carrierfreq}=${Cell1_ssbFrequency}    ${srsrp_nr}=34    ${srsrq_nr}=20
    ...    ${phycell_id}=61    ${nrsrp_nr}=75    ${nrsrq_nr}=75    ${pass_regexp}=rrcReconfigurationComplete
    ${measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A3
    ${command}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${measid} event=A3 srsrp_nr=${srsrp_nr}
    ...    srsrq_nr=${srsrq_nr} phycell_id=${phycell_id} nrsrp_nr=${nrsrp_nr} nrsrq_nr=${nrsrq_nr}
    ${ret3}=    Execute Egate Command
    ...    ${command}
    ...    pass_regexp=${pass_regexp}
    Should Not Contain    ${ret3}    uplinkTxSwitchingOption-r16 switchedUL

Send A1 report to trigger Scell Addition with RSRP
    [Arguments]    ${ue_id}=1    ${cell_freq}=${Cell13_ssbFrequency}    ${rsrp}=61    ${pass_regexp}=rrcReconfigurationComplete
    Start rrc log    RSRP${rsrp}_scell_add_UE${ue_id}
    ${measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cell_freq}    event_type=A1
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${measid} event=A1 srsrp_nr=${rsrp} ssinr_nr=59 srsrq_nr=32
    ...    pass_regexp=${pass_regexp}
    Get RRC log

Send A1 report to trigger ultxswitch 5CC on FDD Cell-13
    ${expect_output}    Create List
    ...    rrcReconfigurationComplete
    ...    pcid:${Cell_1_TDD_PCI}, scellIdx:1
    ...    pcid:${Cell_2_TDD_PCI}, scellIdx:2
    ...    pcid:${Cell_11_FDD_PCI}, scellIdx:3
    ...    pcid:${Cell_12_FDD_PCI}, scellIdx:4
    ...    uplinkTxSwitchingOption-r16 switchedUL
    Send A1 report to trigger Scell Addition with RSRP    ue_id=1    cell_freq=${Cell13_ssbFrequency}    rsrp=64
    ...    pass_regexp=${expect_output}
    Verify Throughput When 4 Scells

Send And Verify Throughput
    [Arguments]    ${ue_id}=1
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=1 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=2 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=3 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=4 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=ul trf_id=6 mbps=10    UE ${ue_id}: UDP UL
    Verify Throughput

Verify Throughput When 2 Scells
    [Arguments]    ${ue_id}=1    ${Tput_dl}=10    ${Tput_ul}=9    ${CC_num}=3
    Throughput Check    ue_id=${ue_id}    Tput_dl=${Tput_dl}    Tput_ul=${Tput_ul}    CC_num=${CC_num}
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-8 type=pdsch

Throughput Check
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${qfi}=1    ${Tput_dl}=10    ${Tput_ul}=1    ${sleep_time}=15s    ${CC_num}=4
    sleep    ${sleep_time}    sleep for Tput stable
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    direction=ul    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${Tput_ul}
    ${ret0}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-5 type=pdsch    pass_regexp=Average
    ${alldl_tput}    set variable    0
    FOR    ${id}    IN RANGE    0    ${CC_num}
        ${id}=    convert to string    ${id}
        ${cell_tput}    Scell Throughput Check    ${ue_id}    ${id}
        ${alldl_tput}    Evaluate    ${alldl_tput}+${cell_tput}
    END
    Should Be True    ${alldl_tput}/1000 > ${Tput_dl}

Scell Throughput Check
    [Arguments]    ${ue_id}=1    ${scell_id}=0
    [Return]    ${scell_tput}
    ${scell_tput}    Ap Get Throuput On Specific Scell     ue_id=${ue_id}    scell_id=${scell_id}    type=pdsch    rate_type=ave

Verify Throughput
    [Arguments]    ${ue_id}=1    ${Tput_dl}=40    ${Tput_ul}=9    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pdsch    Throughput
    Should Not Match Regexp    ${scell_tput}    CellIndex-.*Mbps.*Mbps.*Mbps.* 0 Mbps
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}


Verify Throughput When 4 Scells
    [Arguments]    ${ue_id}=1    ${Tput_dl}=10    ${Tput_ul}=9    ${CC_num}=5
    Throughput Check    ue_id=${ue_id}    Tput_dl=${Tput_dl}    Tput_ul=${Tput_ul}    CC_num=${CC_num}
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-8 type=pdsch    pass_regexp=CellIndex-3

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be Onair    check_sib=${False}

Trigger Pcell Change From FDD Cell-13 To FDD Cell-11
    [Arguments]    ${scell_index}    ${cellfreq}    ${pass_regexp}=None    ${ue_id}=1    ${log_id}=1
    Start rrc log    scell_addition_UE${ue_id}_${log_id}
    ${measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cellfreq}    event_type=A1
    ${cmd}    catenate
    ...    ue_measurement_send_nr id=${ue_id} event=A1 meas_id=${measid} srsrp_nr=11 srsrq_nr=11 scell=${scell_index}
    ...    scell_rsrp=127 scell_rsrq=127
    ${ret5}=    Execute Egate Command    ${cmd}    pass_regexp=${pass_regexp}
    Get RRC log

Trigger PCell change From FDD Cell-13 to FDD Cell-11 and check ultxswitch 5CC CA
    ${expect_output}    Create List
    ...    rrcReconfigurationComplete
    ...    pcid:${Cell_1_TDD_PCI}, scellIdx:1
    ...    pcid:${Cell_2_TDD_PCI}, scellIdx:2
    ...    pcid:${Cell_12_FDD_PCI}, scellIdx:3
    ...    pcid:${Cell_13_FDD_PCI}, scellIdx:4
    ...    uplinkTxSwitchingOption-r16 switchedUL
    Trigger PCell change From FDD Cell-13 to FDD Cell-11    ue_id=1    cellfreq=${Cell11_ssbFrequency}
    ...    scell_index=3    pass_regexp=${expect_output}
    Verify Throughput When 4 Scells

Trigger Pcell Change
    [Arguments]    ${scell_index}    ${cellfreq}    ${pass_regexp}=rrcReconfigurationComplete    ${ue_id}=1    ${log_id}=1
    Start rrc log    scell_addition_UE${ue_id}_${log_id}
    ${measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cellfreq}    event_type=A1
    ${cmd}    catenate
    ...    ue_measurement_send_nr id=${ue_id} event=A1 meas_id=${measid} srsrp_nr=11 srsrq_nr=11 scell=${scell_index}
    ...    scell_rsrp=127 scell_rsrq=127
    ${ret5}=    Execute Egate Command    ${cmd}    pass_regexp=${pass_regexp}
    Get RRC log

Trigger Scell Swap By A6
    [Arguments]    ${ue_id}    ${carrierfreq}    ${phycell_id}=51    ${scell_id}=1    ${pass_regexp}=rrcReconfigurationComplete
    ${measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A6
    ${cmd}    catenate
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${measid} event=A6 srsrp_nr=59 ssinr_nr=59 srsrq_nr=32
    ...    phycell_id=${phycell_id} nrsrp_nr=65 nsinr_nr=65 nrsrq_nr=32 scell=${scell_id} scell_rsrp=56 scell_rsrq=11
    Execute Egate Command    ${cmd}
    ...    pass_regexp=${pass_regexp}

Trigger Scell Swap By A6 from FDD Cell-12 to FDD Cell-14
    ${expect_output}    Create List
    ...    rrcReconfigurationComplete
    ...    pcid:${Cell_14_FDD_PCI}, scellIdx:5
    ...    uplinkTxSwitchingOption-r16 switchedUL
    Trigger Scell Swap By A6    ue_id=1    carrierfreq=${Cell12_ssbFrequency}    phycell_id=63    scell_id=4
    ...    pass_regexp=${expect_output}

Trigger Scell Swap By A6 from FDD Cell-12 to FDD Cell-14 check no UlTxswitch
    ${expect_output}    Create List
    ...    rrcReconfigurationComplete
    ...    pcid:${Cell_14_FDD_PCI}, scellIdx:5
    Trigger Scell Swap By A6    ue_id=1    carrierfreq=${Cell12_ssbFrequency}    phycell_id=63    scell_id=4
    ...    pass_regexp=${expect_output}

Trigger Scell Addition By A1
    [Arguments]    ${ue_id}    ${srsrp_nr}    ${carrierfreq}=${Cell13_ssbFrequency}    ${pass_regexp}=rrcReconfigurationComplete
    ${measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A1
    ${ret}    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${measid} event=A1 srsrp_nr=${srsrp_nr} ssinr_nr=59 srsrq_nr=32
    ...    pass_regexp=${pass_regexp}

Trigger Scell Addition By A1 Check no Ultxswitch
    [Arguments]    ${ue_id}    ${srsrp_nr}    ${carrierfreq}=${Cell13_ssbFrequency}    ${pass_regexp}=rrcReconfigurationComplete
    ${measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A1
    ${ret}    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${measid} event=A1 srsrp_nr=${srsrp_nr} ssinr_nr=59 srsrq_nr=32
    ...    pass_regexp=${pass_regexp}
    Should Not Contain    ${ret}    uplinkTxSwitchingOption-r16 switchedUL

Stepwise Release All TDD Scell and Trigger Scell change to normal 3CC CA
    ${expect_output1}    Create List
    ...    rrcReconfigurationComplete
    ...    uplinkTxSwitchingOption-r16 switchedUL
    Scell A2 report to trigger Scell Release    ue_id=1    carrierfreq=${Cell1_ssbFrequency}    scell_id=1    pass_regexp=${expect_output1}
    ${expect_output2}    Create List
    ...    rrcReconfigurationComplete
    ...    uplinkTxSwitching-r16 release : NULL
    Scell A2 report to trigger Scell Release    ue_id=1    carrierfreq=${Cell2_ssbFrequency}    scell_id=2    pass_regexp=${expect_output2}
    ${expect_output3}    Create List
    ...    rrcReconfigurationComplete
    ...    pcid:${Cell_1_TDD_PCI}, scellIdx:1
    ...    pcid:${Cell_2_TDD_PCI}, scellIdx:2
    Trigger Scell Addition By A1 Check no Ultxswitch    ue_id=1    srsrp_nr=65    carrierfreq=${Cell11_ssbFrequency}    pass_regexp=${expect_output3}

Stepwise Release All TDD Scell and Trigger Scell change to ultxswitch 3CC CA
    ${expect_output1}    Create List
    ...    rrcReconfigurationComplete
    Scell A2 report to trigger Scell Release    ue_id=1    carrierfreq=${Cell1_ssbFrequency}    scell_id=1    pass_regexp=${expect_output1}
    ${expect_output2}    Create List
    ...    rrcReconfigurationComplete
    Scell A2 report to trigger Scell Release    ue_id=1    carrierfreq=${Cell2_ssbFrequency}    scell_id=2    pass_regexp=${expect_output2}
    ${expect_output3}    Create List
    ...    rrcReconfigurationComplete
    ...    pcid:${Cell_1_TDD_PCI}, scellIdx:1
    ...    pcid:${Cell_2_TDD_PCI}, scellIdx:2
    ...    uplinkTxSwitchingOption-r16 switchedUL
    Trigger Scell Addition By A1    ue_id=1    srsrp_nr=91    carrierfreq=${Cell13_ssbFrequency}    pass_regexp=${expect_output3}
    Verify Throughput When 2 Scells

Trigger PCell change from FDD Cell-11 to TDD Cell-1 and check ultxswitch 5CC CA
    ${expect_output}    Create List
    ...    rrcReconfigurationComplete
    ...    pcid:${Cell_2_TDD_PCI}, scellIdx:1
    ...    pcid:${Cell_11_FDD_PCI}, scellIdx:2
    ...    pcid:${Cell_12_FDD_PCI}, scellIdx:3
    ...    pcid:${Cell_13_FDD_PCI}, scellIdx:4
    ...    uplinkTxSwitchingOption-r16 switchedUL
    Trigger PCell change    ue_id=1    cellfreq=${Cell1_ssbFrequency}
    ...    scell_index=1    pass_regexp=${expect_output}
    Verify Throughput When 4 Scells
