*** Settings ***
Suite Setup       Start BTS With Specified Config Files
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Release All UEs And Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_FDD    CLOUD_5G_I_BOO_AP_LOO
...               team-CN3ET    owner-taotao.hu    release-SBTS23R3    CB009169    CRT
Resource          ../../../../../../resources/DevHZ5_resource.robot

*** Variables ***
${SYSCOM_FLAG}    True

${GNB_CONFIG}    fddtdd_sansa_cmwv/6cells_2T4F

# if FDD cells have a bandwidth > 25MHz, need configure FR1_WB
@{PARAMS_IN_IPHY_XML}  fddFrequencyRange=FR1_WB

@{PARAMS_IN_SWCONFIG}
...    @{rdULCaEnablerPhase}
...    @{rdUseOptimizedDpaAlgo}
...    @{rd9169Enable}

@{rdULCaEnablerPhase}
...    0x580591=0

@{rd9169Enable}
...    0x580692=1

@{rdUseOptimizedDpaAlgo}
...    0x58056B=1

@{PARAMS_IN_SCF}
...    @{CB009169}
...    @{CA}
...    @{NRREL}
...    @{gscn_Arfcn}
...    @{BWP_config}

${Cell_2_TDD_PCI}    51
${Cell_12_FDD_PCI}    61
${Cell_11_FDD_PCI}    60
${Cell_13_FDD_PCI}    62
${Cell_14_FDD_PCI}    63
${cell_13_ssbFrequency}    430830
${cell_2_ssbFrequency}    636576
${cell_1_ssbFrequency}    518430
${cell_12_ssbFrequency}    126990
${cell_14_ssbFrequency}    126990

#the following parameters are used in pdm check
${TDD_PRB_for_80M}    217
${FDD_PRB_for_10M}    52
${FDD_PRB_for_20M}    106
${FDD_PRB_for_30M}    160
${TDD_PRB_for_60M}    162
${Cell_1_TDD_PCI}    50

# GNB configuration
#TDD cell-1: band41 Chbw=60M PCI=50 (16385)
#TDD cell-2: band78 chbw=80M PCI=51 (16386)

#FDD cell-11: band66 CHbw=20M PCI=60 (16395)
#FDD cell-13: band66 CHbw=30M PCI=62 (16397)
#FDD cell-12: band71 CHbw=10M PCI=61 (16396)
#FDD cell-14: band71 CHbw=10M PCI=63 (16398)

${carrierAggregationSupportList}    SEPARATOR=
...    ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Any_Sa,ca_Fdd_Fdd,ca_Fr1Tdd_Any_Sa,
...    ca_Fdd_Fr1Tdd_Nsa,ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Fdd_Sa_WithUl

@{CB009169}

...    NRBTS/NRDU-1:carrierAggregationSupportList=${carrierAggregationSupportList}
...    NRBTS/NRDU-1:dlToUlContributionRatio=50
...    NRBTS/NRDRB_RLC_AM-1:ulTReassemblyIBCA=40
...    NRBTS/NRDRB_RLC_AM-2:ulTReassemblyIBCA=40
...    NRCELL:maxNumScellsDlFr1=3
...    NRCELL:timingAdvanceOffset=n25600
...    NRCELL:actK1Opt=intra-gNB
...    NRCELL:pucchModeSelect=longPucch

@{gscn_Arfcn}
...    NRCELL-1:nrarfcn=518598
...    NRCELL-1:gscnOrSsPbchArfcn=6480
...    NRCELL-1:chBw=60MHz

...    NRCELL-2:nrarfcn=636666
...    NRCELL-2:gscnOrSsPbchArfcn=7880
...    NRCELL-2:chBw=80MHz

...    NRCELL-11/NRCELL_FDD-1:nrarfcnDl=424000
...    NRCELL-11/NRCELL_FDD-1:nrarfcnUl=344000
...    NRCELL-11/NRCELL_FDD-1:chBwDl=20MHz
...    NRCELL-11/NRCELL_FDD-1:chBwUl=10MHz
...    NRCELL-11:gscnOrSsPbchArfcn=5297
...    NRCELL-11:pMax=400

...    NRCELL-12/NRCELL_FDD-1:nrarfcnDl=126900
...    NRCELL-12/NRCELL_FDD-1:nrarfcnUl=136100
...    NRCELL-12/NRCELL_FDD-1:chBwDl=10MHz
...    NRCELL-12/NRCELL_FDD-1:chBwUl=10MHz
...    NRCELL-12:gscnOrSsPbchArfcn=1587

...    NRCELL-13/NRCELL_FDD-1:nrarfcnDl=430920
...    NRCELL-13/NRCELL_FDD-1:nrarfcnUl=350920
...    NRCELL-13/NRCELL_FDD-1:chBwDl=30MHz
...    NRCELL-13/NRCELL_FDD-1:chBwUl=10MHz
...    NRCELL-13:gscnOrSsPbchArfcn=5385
...    NRCELL-13:pMax=400

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

@{CA}
...    NRBTS/NRDU-1:actConnectedModeMobilityCA=true
...    NRBTS/NRDU-1:flexibleCAMode=ConfigurationIndependent
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
...    NRCELL-1/NRREL-4:lcrId=2
...    NRCELL-1/NRREL-4:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-4:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-4:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-4:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-4:gnbPlmn:mncLength=3

@{FDD_asymmetric_BWP_DL_20M_UL_10M}
...    NRBTS/BWP_PROFILE-10:bwpType=dedicated
...    NRBTS/BWP_PROFILE-10:locationAndBandwidthDl:cRbSizeDl=n106
...    NRBTS/BWP_PROFILE-10:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-10:locationAndBandwidthUl:cRbSizeUl=n52
...    NRBTS/BWP_PROFILE-10:locationAndBandwidthUl:cRbStartUl=sameAsDl
...    NRBTS/BWP_PROFILE-10/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-10/PDCCH-1:dciDedicatedAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-10/PDCCH-1:dciPagingAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-10/PDCCH-1:dciRaCompletionAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-10/PDCCH-1:dciRaMsg2AggregationLevel=AL4
...    NRBTS/BWP_PROFILE-10/PDCCH-1:dciSiAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-10/PDCCH-1:downgradeAL16toAL8=notAllowed
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=11
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=11
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=11
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=11
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=10
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=10
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n4|searchSpaceId=10
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=10
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=10
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=12
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=12
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=12
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=12
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=12
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=12
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=12
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=12
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=12
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=12
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=12
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=0|dciFormat=formats0-0-And-1-0
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|dciFormat=formats0-0-And-1-0
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|dciFormat=formats0-0-And-1-0
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|dciFormat=formats0-0-And-1-0
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|dciFormat=formats0-0-And-1-0
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|dciFormat=formats0-0-And-1-0
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|dciFormat=formats0-0-And-1-0
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|dciFormat=formats0-0-And-1-0
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|dciFormat=formats0-0-And-1-0
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=15|dciFormat=formats0-0-And-1-0
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|dciFormat=formats0-0-And-1-0
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|dciFormat=formats0-0-And-1-0
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=0|dciFormat=formats0-1-And-1-1
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|dciFormat=formats0-1-And-1-1
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|dciFormat=formats0-1-And-1-1
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|dciFormat=formats0-1-And-1-1
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|dciFormat=formats0-1-And-1-1
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|dciFormat=formats0-1-And-1-1
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|dciFormat=formats0-1-And-1-1
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|dciFormat=formats0-1-And-1-1
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|dciFormat=formats0-1-And-1-1
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=16|dciFormat=formats0-1-And-1-1
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|dciFormat=formats0-1-And-1-1
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|dciFormat=formats0-1-And-1-1
...    NRBTS/BWP_PROFILE-10/PDSCH-1:pdschRat0RbgConfig=config1

@{BWP_config}
...    NRBTS:actMultipleDedicatedBWPs=true
...    NRCELL:actEnhMultipleDedicatedBWPs=false
...    NRCELL-13:msg1FrequencyStart=18
...    NRCELL-13:cellBwpList:cellBwpId=0|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-1
...    NRCELL-13:cellBwpList:cellBwpId=1|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-2
...    NRCELL-13:cellBwpList:cellBwpId=2|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-10
...    @{FDD_asymmetric_BWP_DL_20M_UL_10M}

@{CB008124_enable}
...    NRCELL:actEnhMultipleDedicatedBWPs=false
...    NRBTS:actHighestEstNrTputBcSel=false
...    NRCELL-1:actUlCgType2=true
...    NRCELL-1:ulConfiguredGrantType2:ulCgMaxNumPrbs=12
...    NRCELL-1:ulConfiguredGrantType2:ulCgMaxNumUeUl=1
...    NRCELL-1:ulConfiguredGrantType2:ulCgPrbStartOffset=0
...    NRCELL-13:actUlCgType2=true
...    NRCELL-13:ulConfiguredGrantType2:ulCgMaxNumPrbs=12
...    NRCELL-13:ulConfiguredGrantType2:ulCgMaxNumUeUl=1
...    NRCELL-13:ulConfiguredGrantType2:ulCgPrbStartOffset=0
...    NRBTS/NRDRB-11:nrDrbUlCgDN=MRBTS-1/NRBTS-1/NRULCG_PROFILE-1
...    NRBTS/NRULCG_PROFILE-1:grantedPacketSize=10
...    NRBTS/NRULCG_PROFILE-1:maxNumPrbs=12
...    NRBTS/NRULCG_PROFILE-1:periodicity=ms20

@{set_NRREL_for_cell_11_and_cell_13_and_A1_based}
...    NRCELL:actEnhMultipleDedicatedBWPs=false
...    NRBTS:actHighestEstNrTputBcSel=false
...    NRCELL-1/NRREL-1:gNbId=1
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:lcrId=11
...    NRCELL-1/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-1:sCellOperationalMode=dlAndUl
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-3:gNbId=1
...    NRCELL-1/NRREL-3:gNbIdLength=22
...    NRCELL-1/NRREL-3:lcrId=13
...    NRCELL-1/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-3:sCellOperationalMode=dlAndUl
...    NRCELL-1/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-3:gnbPlmn:mncLength=3

@{81817_enabled_and_dataprefered}
...    NRCELL:actEnhMultipleDedicatedBWPs=true
...    NRBTS/NRDU-1:fr1UlCaPreferred=dataRatePreferred
...    NRBTS:actHighestEstNrTputBcSel=true
...    NRBTS/NRDU-1:dlToUlContributionRatio=40
...    NRCELL-1/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-3:sCellOperationalMode=dlAndUl
...    NRCELL-1/NRREL-1:sCellAdditionMethod=${EMPTY}
...    NRCELL-1/NRREL-1:sCellOperationalMode=${EMPTY}
...    NRCELL-1/NRREL-2:sCellAdditionMethod=${EMPTY}
...    NRCELL-1/NRREL-2:sCellOperationalMode=${EMPTY}
...    NRCELL-1/NRREL-4:sCellAdditionMethod=${EMPTY}
...    NRCELL-1/NRREL-4:sCellOperationalMode=${EMPTY}

@{UL_CA_preferred}
...    NRBTS/NRDU-1:fr1UlCaPreferred=ulCaPreferred

@{weightForSCellSelection_25_for_TDD_2_and_A1_based_CA}
...    NRCELL:actEnhMultipleDedicatedBWPs=false
...    NRBTS:actHighestEstNrTputBcSel=false
...    NRBTS/NRDU-1:dlToUlContributionRatio=90
...    NRCELL-2:weightForSCellSelection=25
...    NRCELL-1/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-4:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-1:sCellOperationalMode=dlAndUl
...    NRCELL-1/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-3:sCellOperationalMode=dlAndUl
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=50
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=60

@{TDD_A1_threshold_large_than_FDD}
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=60
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=50

${N41DLUL_N66DLUL_asymmetric_BCS_0_1_UL_CG_type2}    SEPARATOR=
...    F9A0700047D4FFA17DF8E6BC32001A0349CF9A44F3E0048018807C07C0203F1C03EF3E26807BDEB70D0645020E0000075C12028B64B540B027C873E808
...    F18E7CC31E50B0381C3C149FF27FC48800D940001400001DE7C4100F7BD6E1A0C8A041C00000EB8240516C96A81604F90E7D011E31CF9863CA16070387
...    8327FE9FF8908C061804200601BCE08C01EF7ADC341914083800001D70480A2D92D502C09F21CFA023C639F30C7942C0E070F06EF3E14007BDEB70D064
...    5020E0000075C12028B64B540B027C873E808F18E7CC31E50B0381C3C149FF27FC48860D9400014000000210030002A0F0A00038820000002408038051
...    0136020C0460F400F00C29D3B639F0C050119FC0000009801F00158E0A00E07E120038180030007C043968000038039680000B80396800013803968000
...    1B80396800023800119417951581959495829403060000006000180001418000600008060001800030180000DCA20BE550570382B80C1424022009E0F0
...    783C1E0000008080100202014020D40380010203038D9293927814060148

${N41DLUL_N78DLUL_N66DLUL_N71DLUL_asymmetric_BCS_0_1}    SEPARATOR=
...    F9A0700047D4FFA17DF8E6BC32001A0349CF9A44F3E0048018807C07C0203F1C03EF3E26807BDEB70D0645020E0000075C12028B64B540B027C873E808
...    F18E7CC31E50B0381C3C149FF27FC48800D940001400001DE7C4100F7BD6E1A0C8A041C00000EB8240516C96A81604F90E7D011E31CF9863CA16070387
...    8327FE9FF890800A2801BCE08C01EF7ADC341914083800001D70480A2D92D502C09F21CFA023C639F30C7942C0E070F06EF3E14007BDEB70D0645020E0
...    000075C12028B64B540B027C873E808F18E7CC31E50B0381C3C149FF27FC48800D94000140000002A1F0A000309A0710400388C0000002408038051013
...    6020C0460F401300C69D3A74ED8E7C30050119FC0000009801F00158E0A00E07E120038180030007C043968000038039680000B8039680001380396800
...    01B80396800023800119417951581959495829403060000006000180001418000600008060001800030180000DCA20BE550570382B82C1424022009E0F
...    0783C1E000081808010020200800008050080200C018404008000100400820200C0180801000101006000040080100080400810100A00C040100008080
...    5000020080104140280380300700A00C140080180400900400820201401808010023500E0004080C0E364A4E49E050180520

${N41DLUL_N78DLUL_N66DLUL_N71DLUL_asymmetric_BCS_0}    SEPARATOR=
...    F9A0700047D4FFA17DF8E6BC32001A0349CF9A44F3E0048018807C07C0203F1C03EF3E26807BDEB70D0645020E0000075C12028B64B540B027C873E808
...    F18E7CC31E50B0381C3C149FF27FC48800D940001400000DE7C4100F7BD6E1A0C8A041C00000EB8240516C96A81604F90E7D011E31CF9863CA16070387
...    8327FE9FFB79C11803DEF5B8683228107000003AE090145B25AA05813E439F40478C73E618F28581C0E1E0DDE7C2800F7BD6E1A0C8A041C00000EB8240
...    516C96A81604F90E7D011E31CF9863CA160703878293FE4FF891001B2800028000000543E1400061340E20800711800000048100700A2026C041808C1E
...    8026018D3A74E9DB1CF8600A0233F80000013003E002B1C1401C0FC24007030006000F80872D0000070072D0000170072D0000270072D0000370072D00
...    004700023282F2A2B032B292B0528060C000000C000300002830000C000100C0003000060300001B94417CAA0AE070570582848044013C1E0F0783C000
...    1030100200404010000100A010040180308080100002008010404018030100200020200C0000801002001008010202014018080200010100A000040100
...    208280500700600E014018280100300801200801040402803010020046A01C000810181C6C949C93C0A0300A40

${N41DLUL_N66DLUL_asymmetric_30DL_10UL_BCS_0}    SEPARATOR=
...    F9A0700047D4FFA17DF8E6BC32001A0349CF9A44F3E0048018807C07C0203F1C03EF3E26807BDEB70D0645020E0000075C12028B64B540B027C873E808
...    F18E7CC31E50B0381C3C149FF27FC48800D940001400000DE7C4100F7BD6E1A0C8A041C00000EB8240516C96A81604F90E7D011E31CF9863CA16070387
...    8327FE9FFB79C11803DEF5B8683228107000003AE090145B25AA05813E439F40478C73E618F28581C0E1E0DDE7C2800F7BD6E1A0C8A041C00000EB8240
...    516C96A81604F90E7D011E31CF9863CA160703878293FE4FF891001B2800028000000541E14000710400000048100700A2026C041808C1E801E01853A7
...    6C73E180A0233F80000013003E002B1C1401C0FC24007030006000F80872D0000070072D0000170072D0000270072D0000370072D00004700023282F2A
...    2B032B292B0528060C000000C000300002830000C000100C0003000060300001B94417CAA0AE070570182848044013C1E0F0783C000001010020040402
...    8041A80700020406071B252724F0280C0290

${N41DLUL_N66DLUL_asymmetric_30DL_10UL_BCS_0_1}    SEPARATOR=
...    F9A0700047D4FFA17DF8E6BC32001A0349CF9A44F3E0048018807C07C0203F1C03EF3E26807BDEB70D0645020E0000075C12028B64B540B027C873E808
...    F18E7CC31E50B0381C3C149FF27FC48800D940001400001DE7C4100F7BD6E1A0C8A041C00000EB8240516C96A81604F90E7D011E31CF9863CA16070387
...    8327FE9FF890800619BCE08C01EF7ADC341914083800001D70480A2D92D502C09F21CFA023C639F30C7942C0E070F06EF3E14007BDEB70D0645020E000
...    0075C12028B64B540B027C873E808F18E7CC31E50B0381C3C149FF27FC48800D94000140000002A0F0A000388200000024080380510136020C0460F400
...    F00C29D3B639F0C050119FC0000009801F00158E0A00E07E120038180030007C043968000038039680000B803968000138039680001B80396800023800
...    119417951581959495829403060000006000180001418000600008060001800030180000DCA20BE550570382B80C1424022009E0F0783C1E0000008080
...    100202014020D40380010203038D9293927814060148

${N41DLUL_N66DLUL_asymmetric_30DL_10UL_BCS_0_2}    SEPARATOR=
...    F9A0700047D4FFA17DF8E6BC32001A0349CF9A44F3E0048018807C07C0203F1C03EF3E26807BDEB70D0645020E0000075C12028B64B540B027C873E808
...    F18E7CC31E50B0381C3C149FF27FC48800D940001400001DE7C4100F7BD6E1A0C8A041C00000EB8240516C96A81604F90E7D011E31CF9863CA16070387
...    8327FE9FF890800A2401BCE08C01EF7ADC341914083800001D70480A2D92D502C09F21CFA023C639F30C7942C0E070F06EF3E14007BDEB70D0645020E0
...    000075C12028B64B540B027C873E808F18E7CC31E50B0381C3C149FF27FC48800D94000140000002A0F0A000388200000024080380510136020C0460F4
...    00F00C29D3B639F0C050119FC0000009801F00158E0A00E07E120038180030007C043968000038039680000B803968000138039680001B803968000238
...    00119417951581959495829403060000006000180001418000600008060001800030180000DCA20BE550570382B80C1424022009E0F0783C1E00000080
...    80100202014020D40380010203038D9293927814060148

${N41DLUL_N66DLUL_asymmetric_30DL_5UL_BCS_0_1}    SEPARATOR=
...    F9A0700047D4FFA17DF8E6BC32001A0349CF9A44F3E0048018807C07C0203F1C03EF3E26807BDEB70D0645020E0000075C12028B64B540B027C873E808
...    F18E7CC31E50B0381C3C149FF27FC48800D940001400001DE7C4100F7BD6E1A0C8A041C00000EB8240516C96A81604F90E7D011E31CF9863CA16070387
...    8327FE9FF890800A2801BCE08C01EF7ADC341914083800001D70480A2D92D502C09F21CFA023C639F30C7942C0E070F06EF3E14007BDEB70D0645020E0
...    000075C12028B64B540B027C873E808F18E7CC31E50B0381C3C149FF27FC48800D94000140000002A0F0A000388200000024080380510136020C0460F4
...    00F00C29D3B639F0C050119FC0000009801F00158E0A00E07E120038180030007C043968000038039680000B803968000138039680001B803968000238
...    00119417951581959495829403060000006000180001418000600008060001800030180000DCA20BE550570382B8041424022009E0F0783C1E00000080
...    80100202014020D40380010203038D9293927814060148

${N41DLUL_N66DLUL_asymmetric_BCS_0_1_30DL10UL_30DL5UL_maxadatarate_FS2_large}    SEPARATOR=
...    F9A0700047D4FFA17DF8E6BC32001A0349CF9A44F3E0048018807C07C0203F1C03EF3E26807BDEB70D0645020E0000075C12028B64B540B027C873E808
...    F18E7CC31E50B0381C3C149FF27FC48800D940001400001DE7C4100F7BD6E1A0C8A041C00000EB8240516C96A81604F90E7D011E31CF9863CA16070387
...    8327FE9FF890800619BCE08C01EF7ADC341914083800001D70480A2D92D502C09F21CFA023C639F30C7942C0E070F06EF3E14007BDEB70D0645020E000
...    0075C12028B64B540B027C873E808F18E7CC31E50B0381C3C149FF27FC48800D94000140000002A0F0A000388200000024080380510136020C0460F400
...    F00C29D3B639F0C050119FC0000009801F00158E0A00E07E120038180030007C053968000038039680000B803968000138039680001B80796800020E00
...    E5A0000AE00056505E5456065652560A560A50101800000180006000050600018000201800060000C060021800040060000472882F95415C0E0AE01057
...    0182848044013C1E0F0783C00000103002006004008180500B00C0106A01C000810181C6C949C93C0A0300A400

${N41DLUL_N66DLUL_asymmetric_BCS_0_1_30DLonly_20DL10UL_maxdatarate_BC1_large}    SEPARATOR=
...    F9A0700047D4FFA17DF8E6BC32001A0349CF9A44F3E0048018807C07C0203F1C03EF3E26807BDEB70D0645020E0000075C12028B64B540B027C873E808
...    F18E7CC31E50B0381C3C149FF27FC48800D940001400001DE7C4100F7BD6E1A0C8A041C00000EB8240516C96A81604F90E7D011E31CF9863CA16070387
...    8327FE9FF890800619BCE08C01EF7ADC341914083800001D70480A2D92D502C09F21CFA023C639F30C7942C0E070F06EF3E14007BDEB70D0645020E000
...    0075C12028B64B540B027C873E808F18E7CC31E50B0381C3C149FF27FC48800D94000140000004A0F0A0003882000000240A83C28000E2080000109020
...    0E014404D808301183D0064050A74ED8E7C3841B1CF86001C086307F00000026007C005638280381F84800E06000C001F014E5A00000E00E5A00002E00
...    E5A00004E00E5A00006E01E5A0000838039680002B80015941795158195949581958294040600000060001800014180006000080600018000301800860
...    001001800011CA20BE550570382B80415C060A12011004F0783C1E0F000008404008010100C000202004008080500A3500E0004080C0E364A4E49E0501
...    805200

*** Test Cases ***
CB009169-SR-CB-B3_ET_02_01_verify UL scell addition with asymmetric FDD Cell BW 30MDL and 10MUL
    [Documentation]
    ...    precondition:
    ...    UE_capabilit:N41A*-N66A*
    ...    dlToUlContributionRatio=50, sCellAdditionMethod=covBasedA1, actEnhMultipleDedicatedBWPs=false
    ...    step1: Register UE1 to TDD cell-1 with asymmetricBandwidthCombinationSet 0
    ...    step2: UE-1 report A1 for T+F 2CC scell addition
    ...           scell-1: FDD cell-11 is selected as DL&UL scell(DL:20M, UL:10M)
    ...    step3: Register UE2 to TDD cell-1 with asymmetricBandwidthCombinationSet 0 and 1
    ...    step4: UE-2 report A1 for T+F 2CC scell addition
    ...           scell-1: FDD cell-13 is selected as DL&UL scell(DL:30M, UL:10M)
    ...    step5: Register UE3 to TDD cell-1 with asymmetricBandwidthCombinationSet 0 and 2
    ...    step6: UE-3 report A1 for T+F 2CC scell addition
    ...           scell-1: FDD cell-11 is selected as DL&UL scell(DL:20M, UL:10M)
    ...    step7: Register UE4 to TDD cell-1 with asymmetricBandwidthCombinationSet 0 and 1, but with channelBWs-UL not support 10Mhz
    ...    step8: UE-4 report A1 for T+F 2CC scell addition
    ...           scell-1: FDD cell-13 is selected as DLonly scell(DL:30M)
    [Tags]    CA_LABEL-TFF(60MHz_TDD_n41+30MHz_DL_10Mhz_UL_FDD_n66)
    Online Change And Wait Cell Onair     ${set_NRREL_for_cell_11_and_cell_13_and_A1_based}
    UE1 ICS to TDD cell-1 and FDD cell-11 add as DLUL scell by A1 with asymmetric BCS 0
    UE2 ICS to TDD cell-1 and FDD cell-13 add as DLUL scell by A1 with asymmetric BCS 0 and 1
    UE3 ICS to TDD cell-1 and FDD cell-11 add as DLUL scell by A1 with asymmetric BCS 0 and 2
    UE4 ICS to TDD cell-1 and FDD cell-13 add as DLonly scell by A1 with asymmetric BCS 0 and 1
    Check rrc log    ${CURDIR}${/}A2A_case_CB_B3_02${/}a2a_02.ini

CB009169-SR-CB-B3_ET_05_01_verify UL scell change with asymmetric FDD Cell
    [Documentation]
    ...    precondition:
    ...    UE_capabilit:N41A*-N66A*_N71A*-N78A for N66 (DL:30M UL:10M)
    ...    dlToUlContributionRatio=90, sCellAdditionMethod=covBasedA1, actEnhMultipleDedicatedBWPs=false
    ...    weightForSCellSelection=25 for TDD cell-2 and weightForSCellSelection=50 for all FDD
    ...    a1ThresholdSCellAddSsbRsrpTDD=50 , a1ThresholdSCellAddSsbRsrpFDD=60
    ...    step1: Register UE1 to TDD cell-1 with asymmetricBandwidthCombinationSet 0 and 1
    ...    step2: UE-1 report A1 for TDD only scell addition
    ...           scell-1: TDD cell-2 add as DL scell
    ...    step2: UE-1 report A1 for scell change from TDD to FDD:
    ...          scell-1: released
    ...          scell-2, scell-3: FDD cell-12 as DL only scell and FDD cell-13 as DL&UL scell
    ...    step3: online change a1ThresholdSCellAddSsbRsrpTDD=60, a1ThresholdSCellAddSsbRsrpFDD=50
    ...    step4: Register UE2 to TDD cell-1 with asymmetricBandwidthCombinationSet 0
    ...    step5: UE-1 report A1 for FDD only scell addition
    ...          scell-1: FDD cell-11 as DL&UL scell
    ...          scell-2: FDD cell-12 add as DL scell
    ...    step6: UE-1 report A1 for scell change from FDD to TDD:
    ...          scell-1 and scell-2 released
    ...          scell-3: TDD cell-2 as DL only scell
    [Tags]    CA_LABEL-TFF(60MHz_TDD_n41+30MHz_DL_10Mhz_UL_FDD_n66+10Mhz_FDD_n71+80Mhz_TDD_n78)
    Online Change And Wait Cell Onair     ${weightForSCellSelection_25_for_TDD_2_and_A1_based_CA}
    Ue with specified capabilitiy Register And Pdu Session Setup At TDD Cell-1    ue_id=1
    ...    ue_capa=${N41DLUL_N78DLUL_N66DLUL_N71DLUL_asymmetric_BCS_0_1}
    Send A1 report to trigger TDD cell-2 Addition with RSRP55    ue_id=1
    Send A1 report to trigger scell change from TDD cell-2 to FDD cell-12 and FDD cell-13    ue_id=1
    Release Ues    ue_type=sa    ue_id=1
    Online Change And Wait Cell Onair     ${TDD_A1_threshold_large_than_FDD}
    Ue with specified capabilitiy Register And Pdu Session Setup At TDD Cell-1    ue_id=2
    ...    ue_capa=${N41DLUL_N78DLUL_N66DLUL_N71DLUL_asymmetric_BCS_0}
    Send A1 report to trigger FDD cell-11 and FDD cell-12 addition with RSRP55    ue_id=2
    Send A1 report to trigger scell change from FDD to TDD with RSRP120    ue_id=2
    Check rrc log    ${CURDIR}${/}A2A_case_CB_B3_05${/}a2a_05.ini

CB009169-SR-CB-B3_ET_07_01_verify scell selection with asymmetric FDD Cell when CNI-81817 enabled
    [Documentation]
    ...    precondition:
    ...    UE_capabilit:N41A*-N66A* for N66 (DL:30M UL:10M)
    ...    dlToUlContributionRatio=40, sCellAdditionMethod=covBasedA1, actEnhMultipleDedicatedBWPs=true
    ...    actHighestEstNrTputBcSel=true(CNI-81817), fr1UlCaPreferred=dataRatePreferred(0)
    ...    step1: Register UE1 to TDD cell-1 with asymmetricBandwidthCombinationSet 0 and 1:
    ...           FS1: band66: DL 30M UL 10M ->DL&UL
    ...           FS2: band66: DL 30M UL 5M -> DL only 30M
    ...           maxadatarate: FS2 > FS1
    ...    step2: UE-1 report A1 for scell addition
    ...           BC1: FS2 selected and scell-1: FDD cell-13 add as DLonly scell with DL BW: 30M
    ...    step3: Register UE2 to TDD cell-1 with asymmetricBandwidthCombinationSet 0 and 1:
    ...           BC1: N41a*-N66a*, with asymmetricBandwidthCombinationSet=0,1
    ...           FS1: band66: DL 30M UL not support ->DL large only
    ...           BC2: N41a*-N66a*, with asymmetricBandwidthCombinationSet=0,1
    ...           FS1: band66: DL 20M UL 10-> DL&UL with small BWP
    ...           maxadatarate: BC1 > BC2
    ...    step4: UE-2 report A1 for scell addition
    ...           BC1: FS1 selected and scell-1: FDD cell-13 add as DLonly scell with DL BW: 30M
    ...    step5: online change fr1UlCaPreferred to ulCaPreferred
    ...    step6: Register UE3 to TDD cell-1 with same UE capability with UE-1 and report A1 for scell addition
    ...           BC1: FS1 selected and scell-1: FDD cell-13 add as DLandUL scell with large BWP DL BW: 30M and UL:10MHz
    ...    step7: Register UE4 to TDD cell-1 with same UE capability with UE-2 and report A1 for scell addition
    ...           BC2: FS1 selected and scell-1: FDD cell-13 add as DLandUL scell with samll BWP DL BW: 20M and UL:10MHz
    [Tags]    CA_LABEL-TFF(60MHz_TDD_n41+30MHz_DL_10Mhz_UL_FDD_n66)
    Online Change And Wait Cell Onair     ${81817_enabled_and_dataprefered}
    UE ICS to TDD cell-1 and FDD cell-13 as DL only scell with large BWP with special capbility    ue_id=1
    ...    ue_capa=${N41DLUL_N66DLUL_asymmetric_BCS_0_1_30DL10UL_30DL5UL_maxadatarate_FS2_large}
    UE ICS to TDD cell-1 and FDD cell-13 as DL only scell with large BWP with special capbility    ue_id=2
    ...    ue_capa=${N41DLUL_N66DLUL_asymmetric_BCS_0_1_30DLonly_20DL10UL_maxdatarate_BC1_large}
    Online Change And Wait Cell Onair     ${UL_CA_preferred}
    UE3 ICS to TDD cell-1 and FDD cell-13 as DLandUL scell with large BWP with special capability
    UE4 ICS to TDD cell-1 and FDD cell-13 as DLandUL scell with small BWP with special capability
    Check rrc log    ${CURDIR}${/}A2A_case_CB_B3_07${/}a2a_07.ini
    Check Wireshark Log    ${CURDIR}${/}A2A_case_CB_B3_07${/}a2a_07.ini    wait_string=UEContextModificationResponse::40

CB009169-SR-CB-B4_ET_03_01_verify Configured UL Grants Type 2 is configured in PCell only for UL CA UE
    [Documentation]
    ...    precondition:
    ...    UE_capabilit:N41A*-N66A* for N66 (DL:30M UL:10M)
    ...    dlToUlContributionRatio=40, sCellAdditionMethod=covBasedA1, actEnhMultipleDedicatedBWPs=false
    ...    actHighestEstNrTputBcSel=false(CNI-81817), fr1UlCaPreferred=dataRatePreferred(0)
    ...    step1: Register UE1 to TDD cell-1 with asymmetricBandwidthCombinationSet 0 and 1:
    ...           UE capability support UL CG Type2:
    ...           BandNR.enhancedSkipUplinkTxConfigured-v166: supported
    ...           BandNR.configuredUL-GrantType2-v1650: supported
    ...           check UL CG Type2 configured for Pcell in RRC reconfigureation: configuredGrantConfig setup
    ...    step2: UE-1 report A1 for scell addition
    ...           scell-1: FDD cell-13 add as DLandUL scell and check no UL CG Type2 configured for UL scell
    [Tags]    CA_LABEL-TFF(60MHz_TDD_n41+30MHz_DL_10Mhz_UL_FDD_n66)
    Online Change And Wait Cell Onair     ${CB008124_enable}
    Ue with specified capabilitiy Register And check UL CG Type2 setup for Pcell    ue_id=1
    ...    ue_capa=${N41DLUL_N66DLUL_asymmetric_BCS_0_1_UL_CG_type2}
    Send A1 report to trigger UL scell addition and no UL CG Type2    ue_id=1
    Release Ues    ue_type=sa    ue_id=1
    Check rrc log    ${CURDIR}${/}A2A_case_CB_B4_03${/}a2a_03.ini

*** Keywords ***
Ue with specified capabilitiy Register And Pdu Session Setup At TDD Cell-1
    [Arguments]    ${ue_id}    ${ue_capa}
    Execute Egate Command    ue_location_change id=${ue_id} enb=2 cell=1
    Execute Egate Command    ue_register id=${ue_id} ue_nr_capabilities=${ue_capa}    pass_regexp=UE now in NG RM Registere
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=${ue_id} nwslice=1    pass_regexp=QoS Routing Table

Ue with specified capabilitiy Register And check UL CG Type2 setup for Pcell
    [Arguments]    ${ue_id}    ${ue_capa}
    Execute Egate Command    ue_location_change id=${ue_id} enb=2 cell=1
    Execute Egate Command    ue_register id=${ue_id} ue_nr_capabilities=${ue_capa}    pass_regexp=UE now in NG RM Registere
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    ${expect_output}    Create List
    ...    QoS Routing Table
    ...    configuredGrantConfig setup
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=${ue_id} nwslice=1    pass_regexp=${expect_output}

Send A1 report to trigger FDD cell-11 as DLUL scell
    [Arguments]    ${ue_id}=1    ${cell_freq}=${cell_1_ssbFrequency}
    Start rrc log    scell_addition_UE${ue_id}
    ${measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cell_freq}    event_type=A1
    ${expect_output}    Create List
    ...    rrcReconfigurationComplete
    ...    pcid:${Cell_11_FDD_PCI}, scellIdx:1
    ...    uplinkConfigCommon
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${measid} event=A1 srsrp_nr=120 ssinr_nr=120 srsrq_nr=32
    ...    pass_regexp=${expect_output}
    Get RRC log

Send A1 report to trigger FDD cell-13 as DLUL scell
    [Arguments]    ${ue_id}=1    ${cell_freq}=${cell_1_ssbFrequency}
    Start rrc log    scell_addition_UE${ue_id}
    ${measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cell_freq}    event_type=A1
    ${expect_output}    Create List
    ...    rrcReconfigurationComplete
    ...    pcid:${Cell_13_FDD_PCI}, scellIdx:1
    ...    uplinkConfigCommon
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${measid} event=A1 srsrp_nr=120 ssinr_nr=120 srsrq_nr=32
    ...    pass_regexp=${expect_output}
    Get RRC log

Send A1 report to trigger FDD cell-13 as DLonly scell
    [Arguments]    ${ue_id}=1    ${cell_freq}=${cell_1_ssbFrequency}
    Start rrc log    scell_addition_UE${ue_id}
    ${measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cell_freq}    event_type=A1
    ${expect_output}    Create List
    ...    rrcReconfigurationComplete
    ...    pcid:${Cell_13_FDD_PCI}, scellIdx:1
    ${ret}    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${measid} event=A1 srsrp_nr=120 ssinr_nr=120 srsrq_nr=32
    ...    pass_regexp=${expect_output}
    Should Not Contain    ${ret}    uplinkConfigCommon
    Get RRC log

Send A1 report to trigger UL scell addition and no UL CG Type2
    [Arguments]    ${ue_id}=1    ${cell_freq}=${cell_1_ssbFrequency}
    Start rrc log    scell_addition_UE${ue_id}
    ${measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cell_freq}    event_type=A1
    ${expect_output}    Create List
    ...    rrcReconfigurationComplete
    ...    pcid:${Cell_13_FDD_PCI}, scellIdx:1
    ...    uplinkConfigCommon
    ${ret}    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${measid} event=A1 srsrp_nr=120 ssinr_nr=120 srsrq_nr=32
    ...    pass_regexp=${expect_output}
    Should Not Contain    ${ret}    configuredGrantConfig setup
    Get RRC log

Send A1 report to trigger TDD cell-2 Addition with RSRP55
    [Arguments]    ${ue_id}=1    ${cell_freq}=${cell_1_ssbFrequency}
    Start rrc log    scell_addition_UE${ue_id}
    ${measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cell_freq}    event_type=A1
    ${expect_output}    Create List
    ...    rrcReconfigurationComplete
    ...    pcid:${Cell_2_TDD_PCI}, scellIdx:1
    ${ret}    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${measid} event=A1 srsrp_nr=55 ssinr_nr=120 srsrq_nr=32
    ...    pass_regexp=${expect_output}
    Should Not Contain    ${ret}    uplinkConfigCommon
    Get RRC log

Send A1 report to trigger scell change from TDD cell-2 to FDD cell-12 and FDD cell-13
    [Arguments]    ${ue_id}=1    ${cell_freq}=${cell_1_ssbFrequency}
    Start rrc log    scell_change_UE${ue_id}
    ${measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cell_freq}    event_type=A1
    ${expect_output}    Create List
    ...    rrcReconfigurationComplete
    ...    pcid:${Cell_12_FDD_PCI}, scellIdx:2
    ...    pcid:${Cell_13_FDD_PCI}, scellIdx:3
    ...    uplinkConfigCommon
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${measid} event=A1 srsrp_nr=120 ssinr_nr=120 srsrq_nr=32
    ...    pass_regexp=${expect_output}
    Get RRC log

Send A1 report to trigger FDD cell-11 and FDD cell-12 addition with RSRP55
    [Arguments]    ${ue_id}=1    ${cell_freq}=${cell_1_ssbFrequency}
    Start rrc log    scell_addition_UE${ue_id}
    ${measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cell_freq}    event_type=A1
    ${expect_output}    Create List
    ...    rrcReconfigurationComplete
    ...    pcid:${Cell_11_FDD_PCI}, scellIdx:1
    ...    pcid:${Cell_12_FDD_PCI}, scellIdx:2
    ...    uplinkConfigCommon
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${measid} event=A1 srsrp_nr=55 ssinr_nr=120 srsrq_nr=32
    ...    pass_regexp=${expect_output}
    Get RRC log

Send A1 report to trigger scell change from FDD to TDD with RSRP120
    [Arguments]    ${ue_id}=1    ${cell_freq}=${cell_1_ssbFrequency}
    Start rrc log    scell_change_UE${ue_id}
    ${measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cell_freq}    event_type=A1
    ${expect_output}    Create List
    ...    rrcReconfigurationComplete
    ...    pcid:${Cell_2_TDD_PCI}, scellIdx:3
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${measid} event=A1 srsrp_nr=120 ssinr_nr=120 srsrq_nr=32
    ...    pass_regexp=${expect_output}
    Get RRC log

Send A1 report to trigger FDD cell-13 as DL only scell with large BWP
    [Arguments]    ${ue_id}=1    ${cell_freq}=${cell_1_ssbFrequency}
    Start rrc log    scell_addition_UE${ue_id}
    ${measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cell_freq}    event_type=A1
    ${expect_output}    Create List
    ...    rrcReconfigurationComplete
    ...    pcid:${Cell_13_FDD_PCI}, scellIdx:1
    ${ret}    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${measid} event=A1 srsrp_nr=120 ssinr_nr=120 srsrq_nr=32
    ...    pass_regexp=${expect_output}
    Should Not Contain    ${ret}    uplinkConfigCommon
    Get RRC log

Send A1 report to trigger FDD cell-13 as DLandUL scell with large BWP
    [Arguments]    ${ue_id}=1    ${cell_freq}=${cell_1_ssbFrequency}
    Start rrc log    scell_addition_UE${ue_id}
    ${measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cell_freq}    event_type=A1
    ${expect_output}    Create List
    ...    rrcReconfigurationComplete
    ...    pcid:${Cell_13_FDD_PCI}, scellIdx:1
    ...    uplinkConfigCommon
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${measid} event=A1 srsrp_nr=120 ssinr_nr=120 srsrq_nr=32
    ...    pass_regexp=${expect_output}
    Get RRC log

Send A1 report to trigger FDD cell-13 as DLandUL scell with small BWP
    [Arguments]    ${ue_id}=1    ${cell_freq}=${cell_1_ssbFrequency}
    Start rrc log    scell_addition_UE${ue_id}
    ${measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cell_freq}    event_type=A1
    ${expect_output}    Create List
    ...    rrcReconfigurationComplete
    ...    pcid:${Cell_13_FDD_PCI}, scellIdx:1
    ...    uplinkConfigCommon
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${measid} event=A1 srsrp_nr=120 ssinr_nr=120 srsrq_nr=32
    ...    pass_regexp=${expect_output}
    Get RRC log

Start BTS With Specified Config Files
    Common Suite Setup
    Setup Airphone Env    tl_type=${GNB_CONFIG}

Online Change And Wait Cell Onair
    [Arguments]    ${parameters}
    delta commission parameters    ${parameters}
    Cells Should Be Onair

Release All UEs And Common Test Teardown And Stop Capture Logs
    Release Ues    ue_type=all
    Common Test Teardown And Stop Capture Logs

UE1 ICS to TDD cell-1 and FDD cell-11 add as DLUL scell by A1 with asymmetric BCS 0
    Ue with specified capabilitiy Register And Pdu Session Setup At TDD Cell-1    ue_id=1    ue_capa=${N41DLUL_N66DLUL_asymmetric_30DL_10UL_BCS_0}
    Send A1 report to trigger FDD cell-11 as DLUL scell    ue_id=1
    Release Ues    ue_type=sa    ue_id=1

UE2 ICS to TDD cell-1 and FDD cell-13 add as DLUL scell by A1 with asymmetric BCS 0 and 1
    Ue with specified capabilitiy Register And Pdu Session Setup At TDD Cell-1    ue_id=2    ue_capa=${N41DLUL_N66DLUL_asymmetric_30DL_10UL_BCS_0_1}
    Send A1 report to trigger FDD cell-13 as DLUL scell    ue_id=2
    Release Ues    ue_type=sa    ue_id=2

UE3 ICS to TDD cell-1 and FDD cell-11 add as DLUL scell by A1 with asymmetric BCS 0 and 2
    Ue with specified capabilitiy Register And Pdu Session Setup At TDD Cell-1    ue_id=3    ue_capa=${N41DLUL_N66DLUL_asymmetric_30DL_10UL_BCS_0_2}
    Send A1 report to trigger FDD cell-11 as DLUL scell    ue_id=3
    Release Ues    ue_type=sa    ue_id=3

UE4 ICS to TDD cell-1 and FDD cell-13 add as DLonly scell by A1 with asymmetric BCS 0 and 1
    Ue with specified capabilitiy Register And Pdu Session Setup At TDD Cell-1    ue_id=4    ue_capa=${N41DLUL_N66DLUL_asymmetric_30DL_5UL_BCS_0_1}
    Send A1 report to trigger FDD cell-13 as DLonly scell    ue_id=4
    Release Ues    ue_type=sa    ue_id=4

UE ICS to TDD cell-1 and FDD cell-13 as DL only scell with large BWP with special capbility
    [Arguments]    ${ue_id}    ${ue_capa}
    Ue with specified capabilitiy Register And Pdu Session Setup At TDD Cell-1    ue_id=${ue_id}
    ...    ue_capa=${ue_capa}
    Send A1 report to trigger FDD cell-13 as DL only scell with large BWP    ue_id=${ue_id}
    Release Ues    ue_type=sa    ue_id=${ue_id}

UE3 ICS to TDD cell-1 and FDD cell-13 as DLandUL scell with large BWP with special capability
    Ue with specified capabilitiy Register And Pdu Session Setup At TDD Cell-1    ue_id=3
    ...    ue_capa=${N41DLUL_N66DLUL_asymmetric_BCS_0_1_30DL10UL_30DL5UL_maxadatarate_FS2_large}
    Send A1 report to trigger FDD cell-13 as DLandUL scell with large BWP    ue_id=3
    Release Ues    ue_type=sa    ue_id=3

UE4 ICS to TDD cell-1 and FDD cell-13 as DLandUL scell with small BWP with special capability
    Ue with specified capabilitiy Register And Pdu Session Setup At TDD Cell-1    ue_id=4
    ...    ue_capa=${N41DLUL_N66DLUL_asymmetric_BCS_0_1_30DLonly_20DL10UL_maxdatarate_BC1_large}
    Send A1 report to trigger FDD cell-13 as DLandUL scell with small BWP    ue_id=4
    Release Ues    ue_type=sa    ue_id=4
