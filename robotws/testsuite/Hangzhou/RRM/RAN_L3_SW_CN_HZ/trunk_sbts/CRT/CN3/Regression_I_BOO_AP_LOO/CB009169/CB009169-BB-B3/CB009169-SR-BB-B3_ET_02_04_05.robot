*** Settings ***
Suite Setup       Start BTS With Specified Config Files
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Release All UEs And Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_FDD    CLOUD_5G_I_BOO_AP_LOO
...    team-CN3ET    owner-lishuo.geng    release-SBTS23R3    CB009169    CRT    CA_LABEL-TFF(60MHz_TDD_n41+ 30MHz_FDD_n66+10MHz_FDD_n71)
Resource          ../../../../../../resources/DevHZ5_resource.robot


*** Variables ***
${SYSCOM_FLAG}    True
${GNB_CONFIG}    fddtdd_sansa_cmwv/6cells_2T4F
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
${Cell_13_FDD_PCI}    62


${cell_1_ssbFrequency}    518430

# GNB configuration
#TDD cell-1: band41 Chbw=60M PCI=50
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
...    NRCELL-12/NRCELL_FDD-1:nrarfcnDl=126900
...    NRCELL-12/NRCELL_FDD-1:nrarfcnUl=136100
...    NRCELL-12/NRCELL_FDD-1:chBwDl=10MHz
...    NRCELL-12/NRCELL_FDD-1:chBwUl=10MHz
...    NRCELL-12:gscnOrSsPbchArfcn=1587
# for 10HZ FDD chbw, need to remove BWP coresetDedicated
...    MRBTS-1/NRBTS-1/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=0|searchSpaceId=7
...    MRBTS-1/NRBTS-1/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|searchSpaceId=7
...    MRBTS-1/NRBTS-1/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-0-And-1-0|searchSpaceId=7
...    MRBTS-1/NRBTS-1/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|searchSpaceId=8
...    MRBTS-1/NRBTS-1/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|searchSpaceId=8
...    delete:MRBTS-1/NRBTS-1/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated

...    NRCELL-14/NRCELL_FDD-1:nrarfcnDl=126900
...    NRCELL-14/NRCELL_FDD-1:nrarfcnUl=136100
...    NRCELL-14/NRCELL_FDD-1:chBwDl=10MHz
...    NRCELL-14/NRCELL_FDD-1:chBwUl=10MHz
...    NRCELL-14:gscnOrSsPbchArfcn=1587
...    NRCELL-11:pMax=400
...    NRCELL-11/NRCELL_FDD-1:nrarfcnDl=424000
...    NRCELL-11/NRCELL_FDD-1:nrarfcnUl=344000
...    NRCELL-11/NRCELL_FDD-1:chBwDl=20MHz
...    NRCELL-11/NRCELL_FDD-1:chBwUl=20MHz
...    NRCELL-11:gscnOrSsPbchArfcn=5297
...    NRCELL-13:pMax=400
...    NRCELL-13/NRCELL_FDD-1:nrarfcnDl=430920
...    NRCELL-13/NRCELL_FDD-1:nrarfcnUl=350920
...    NRCELL-13/NRCELL_FDD-1:chBwDl=30MHz
...    NRCELL-13/NRCELL_FDD-1:chBwUl=30MHz
...    NRCELL-13:gscnOrSsPbchArfcn=5385


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
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=60
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=50
...    NRCELL:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0
...    NRCELL:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=2560ms
...    NRCELL:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=34

@{NRREL}
...    NRCELL-1/NRREL-2:gNbId=1
...    NRCELL-1/NRREL-2:gNbIdLength=22
...    NRCELL-1/NRREL-2:lcrId=12
...    NRCELL-1/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-2:sCellOperationalMode=dlAndUl
...    NRCELL-1/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-3:gNbId=1
...    NRCELL-1/NRREL-3:gNbIdLength=22
...    NRCELL-1/NRREL-3:lcrId=13
...    NRCELL-1/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-3:sCellOperationalMode=dlAndUl
...    NRCELL-1/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-5:gNbId=1
...    NRCELL-1/NRREL-5:gNbIdLength=22
...    NRCELL-1/NRREL-5:lcrId=2
...    NRCELL-1/NRREL-5:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-5:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-5:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-5:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-5:gnbPlmn:mncLength=3
...    NRCELL-2:weightForSCellSelection=25


@{FDD_BWP_20M}
...    NRBTS/BWP_PROFILE-12:bwpType=dedicated
...    NRBTS/BWP_PROFILE-12:locationAndBandwidthDl:cRbSizeDl=n106
...    NRBTS/BWP_PROFILE-12:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-12:locationAndBandwidthUl:cRbSizeUl=sameAsDl
...    NRBTS/BWP_PROFILE-12:locationAndBandwidthUl:cRbStartUl=sameAsDl
...    NRBTS/BWP_PROFILE-12/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-12/PDCCH-1:dciDedicatedAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-12/PDCCH-1:dciPagingAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-12/PDCCH-1:dciRaCompletionAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-12/PDCCH-1:dciRaMsg2AggregationLevel=AL4
...    NRBTS/BWP_PROFILE-12/PDCCH-1:dciSiAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-12/PDCCH-1:downgradeAL16toAL8=notAllowed
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=21
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=21
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=21
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=21
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=21
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=21
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=21
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=21
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=21
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=21
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=21
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=22
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=22
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=22
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=22
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=22
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=22
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n4|searchSpaceId=22
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=22
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=22
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=22
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=22
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=23
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=23
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=23
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=23
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=23
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=23
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=23
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=23
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=23
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=23
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=23
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=0|dciFormat=formats0-0-And-1-0
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|dciFormat=formats0-0-And-1-0
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|dciFormat=formats0-0-And-1-0
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|dciFormat=formats0-0-And-1-0
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|dciFormat=formats0-0-And-1-0
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|dciFormat=formats0-0-And-1-0
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|dciFormat=formats0-0-And-1-0
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|dciFormat=formats0-0-And-1-0
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|dciFormat=formats0-0-And-1-0
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=25|dciFormat=formats0-0-And-1-0
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|dciFormat=formats0-0-And-1-0
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|dciFormat=formats0-0-And-1-0
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=0|dciFormat=formats0-1-And-1-1
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|dciFormat=formats0-1-And-1-1
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|dciFormat=formats0-1-And-1-1
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|dciFormat=formats0-1-And-1-1
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|dciFormat=formats0-1-And-1-1
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|dciFormat=formats0-1-And-1-1
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|dciFormat=formats0-1-And-1-1
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|dciFormat=formats0-1-And-1-1
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|dciFormat=formats0-1-And-1-1
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=26|dciFormat=formats0-1-And-1-1
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|dciFormat=formats0-1-And-1-1
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|dciFormat=formats0-1-And-1-1
...    NRBTS/BWP_PROFILE-12/PDSCH-1:pdschRat0RbgConfig=config1

@{BWP_config}
...    NRBTS:actMultipleDedicatedBWPs=true
...    NRCELL:actEnhMultipleDedicatedBWPs=true
...    NRCELL-13:msg1FrequencyStart=18
...    NRCELL-13:cellBwpList:cellBwpId=0|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-1
...    NRCELL-13:cellBwpList:cellBwpId=1|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-2
...    NRCELL-13:cellBwpList:cellBwpId=2|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-12
...    @{FDD_BWP_20M}

@{dlToUlContributionRatio_change_to_70}
...    NRBTS/NRDU-1:dlToUlContributionRatio=70


${dlToUlContributionRatio_change_to_50}
...    NRBTS/NRDU-1:dlToUlContributionRatio=50


${N41DLUL_N66DLUL_N71DLUL_support_N66DL_to_10M}    SEPARATOR=
...    F9A0700047D0FFA17DF8E6BC32001A0349CF9A44F3E0048018807C07C0203F1C03EF3E26807BDEB70D0645020E0000075C12028B64B540B027C873
...    E808F18E7CC31E50B0381C3C149FF27FC48800D940001400000DE7C4100F7BD6E1A0C8A041C00000EB8240516C96A81604F90E7D011E31CF9863CA
...    160703878326009F8379F11803DEF5B8683228107000003AE090145B25AA05813E439F40478C73E618F28581C0E1E0C9FFA7FFDE7C2800F7BD6E1A
...    0C8A041C00000EB8240516C96A81604F90E7D011E31CF9863CA160703878313FE4FF891001B2800028000000542E2080070A000388C00002026020
...    0E014404D808301183D003403100D8E7C30140467F00000026007C005638280381F84800E06000C001F010E5A00000E00E5A00002E00E5A00004E0
...    0E5A00006E00E5A00008E00046505E5456065652560A500C1800000180006000050600018000201800060000C060000372882F95415C160AE53050
...    9008802783C1E0F0780002020200400808020001010020000401002080803006020040004040180001002004002010020404028030100400020201
...    4000080200410500A00E00C01C0280305002006010024010021008050060200400808050063500E0004080C0E364A4E49E0501805200

${N41DLUL_N66DLUL_N71DLUL_support_N66DL_to_20M_N66UL_support_30M_no_20M}    SEPARATOR=  
...    F9A0700047D0FFA17DF8E6BC32001A0349CF9A44F3E0048018807C07C0203F1C03EF3E26807BDEB70D0645020E0000075C12028B64B540B027C873
...    E808F18E7CC31E50B0381C3C149FF27FC48800D940001400000DE7C4100F7BD6E1A0C8A041C00000EB8240516C96A81604F90E7D011E31CF9863CA
...    160703878327809C8379F11803DEF5B8683228107000003AE090145B25AA05813E439F40478C73E618F28581C0E1E0C9FFA7FFDE7C2800F7BD6E1A
...    0C8A041C00000EB8240516C96A81604F90E7D011E31CF9863CA160703878313FE4FF891001B2800028000000542E2080070A000388C00002026020
...    0E014404D808301183D003403100D8E7C30140467F00000026007C005638280381F84800E06000C001F010E5A00000E00E5A00002E00E5A00004E0
...    0E5A00006E00E5A00008E00046505E5456065652560A500C1800000180006000050600018000201800060000C060000372882F95415C160AE53050
...    9008802783C1E0F0780002020200400808020001010020000401002080803006020040004040180001002004002010020404028030100400020201
...    4000080200410500A00E00C01C0280305002006010024010021008050060200400808050063500E0004080C0E364A4E49E0501805200

${N41DLUL_N66DLUL_N71DLUL_support_N66DL_to_30M_N66UL_to_10M}    SEPARATOR=  
...    F9A0700047D0FFA17DF8E6BC32001A0349CF9A44F3E0048018807C07C0203F1C03EF3E26807BDEB70D0645020E0000075C12028B64B540B027C873
...    E808F18E7CC31E50B0381C3C149FF27FC48800D940001400000DE7C4100F7BD6E1A0C8A041C00000EB8240516C96A81604F90E7D011E31CF9863CA
...    160703878327E0980379F11803DEF5B8683228107000003AE090145B25AA05813E439F40478C73E618F28581C0E1E0C9FFA7FFDE7C2800F7BD6E1A
...    0C8A041C00000EB8240516C96A81604F90E7D011E31CF9863CA160703878313FE4FF891001B2800028000000542E2080070A000388C00002026020
...    0E014404D808301183D003403100D8E7C30140467F00000026007C005638280381F84800E06000C001F010E5A00000E00E5A00002E00E5A00004E0
...    0E5A00006E00E5A00008E00046505E5456065652560A500C1800000180006000050600018000201800060000C060000372882F95415C160AE53050
...    9008802783C1E0F0780002020200400808020001010020000401002080803006020040004040180001002004002010020404028030100400020201
...    4000080200410500A00E00C01C0280305002006010024010021008050060200400808050063500E0004080C0E364A4E49E0501805200

${N41DLUL_N66DLUL_N71DL_support_N66DL_to_30M_N66UL_to_20M}    SEPARATOR=  
...    F9A0700047D0FFA17DF8E6BC32001A0349CF9A44F3E0048018807C07C0203F1C03EF3E26807BDEB70D0645020E0000075C12028B64B540B027C873
...    E808F18E7CC31E50B0381C3C149FF27FC48800D940001400000DE7C4100F7BD6E1A0C8A041C00000EB8240516C96A81604F90E7D011E31CF9863CA
...    160703878327E09E0379F11803DEF5B8683228107000003AE090145B25AA05813E439F40478C73E618F28581C0E1E0C9FFA7FFDE7C2800F7BD6E1A
...    0C8A041C00000EB8240516C96A81604F90E7D011E31CF9863CA160703878313FE4FF891001B2800028000000542E2080070A000308C00080981401
...    C028809B010602307A006806201B1CF8602808CFE0000004C00F800AC70500703F09001C0C0018003E021CB400001C01CB400005C01CB400009C01
...    CB40000DC01CB400011C0008CA0BCA8AC0CACA4AC14A018300000030000C0000A0C000300004030000C000180C00006E5105F2A82B82C15CA60A12
...    011004F0783C1E0F0000404040080101004000202004000080200410100600C0400800080803000020040080040200408080500602008000404028
...    000100400820A01401C018038050060A00400C0200480200420100A00C04008010100A00C6A01C000810181C6C949C93C0A0300A40

${N41DLUL_N66DLUL_N71DL_N78DL_support_N66DL_to_30M_N66UL_to_20M}    SEPARATOR=  
...    F9A0700047D0FFA17DF8E6BC32001A0349CF9A44F3E0048018807C07C0203F1C03EF3E26807BDEB70D0645020E0000075C12028B64B540B027C873
...    E808F18E7CC31E50B0381C3C149FF27FC48800D940001400000DE7C4100F7BD6E1A0C8A041C00000EB8240516C96A81604F90E7D011E31CF9863CA
...    160703878327E09E0379F11803DEF5B8683228107000003AE090145B25AA05813E439F40478C73E618F28581C0E1E0C9FFA7FFDE7C2800F7BD6E1A
...    0C8A041C00000EB8240516C96A81604F90E7D011E31CF9863CA160703878313FE4FF891001B2800028000000543E2080070A000308C06134001013
...    0280380510136020C0460F400F00C600D8E7C300050119FC0000009801F00158E0A00E07E120038180030007C043968000038039680000B8039680
...    00138039680001B80396800023800119497951581959495829403060000006000180001418000600008060001800030180000DCA20BE550570582B
...    94C1424022009E0F0783C1E0000808080100202008000404008000100400820200C0180801000101006000040080100080400810100A00C0401000
...    080805000020080104140280380300700A00C140080180400900400860201401808010020201401808010023500E0004080C0E364A4E49E050180520

@{COUNTER_CHECK_case4}
...    NRCELL-1:NCADC:${SUM_UE_SCELL_CONF_S_BWP}>1
...    NRCELL-1:RSADU:${GNB_DU_SCELL_ADM_S_BWP_SUCC}=1
...    NRCELL-1:NCADC:${SUM_UE_SCELL_CONF_L_BWP}=0
...    NRCELL-1:RSADU:${GNB_DU_SCELL_ADM_L_BWP_SUCC}=0

@{COUNTER_CHECK_case5}
...    NRCELL-1:NCADC:${SUM_UE_SCELL_CONF_L_BWP}>1
...    NRCELL-1:RSADU:${GNB_DU_SCELL_ADM_L_BWP_SUCC}=2
...    NRCELL-1:NCADC:${SUM_UE_SCELL_CONF_S_BWP}=0
...    NRCELL-1:RSADU:${GNB_DU_SCELL_ADM_S_BWP_SUCC}=0

${SUM_UE_SCELL_CONF_S_BWP}    M55167C00002
${SUM_UE_SCELL_CONF_L_BWP}    M55167C00003
${GNB_DU_SCELL_ADM_S_BWP_SUCC}    M55139C04001
${GNB_DU_SCELL_ADM_L_BWP_SUCC}    M55139C04002

*** Test Cases ***
CB009169-SR-BB-B3_ET_02_01_Verify SCell selection without UL CA when UE not support large BWP and small BWP and actEnhMultipleDedicatedBWPs is true
    [Documentation]
    ...    The purpose of this test case is to check following scenarios:
    ...    Verify UL scell selection when UE not support large BWP and small BWP for DL scell and actEnhMultipleDedicatedBWPs enabled
    ...    UE CA Capability:
    ...    UE1:BC#1: N41a*-N66a*-N71a*,Ony ChannelBWs-DL: not support 20M,30M
    ...    Setting ChannelBWs-DL: not support 30M and 20M->no scell add with FDD cell-13
    ...    cell-12 DL and UL scell addition for UE-1
    ...    UE2:BC#1: N41a*-N66a*-N71a*,UE supports only small BWP for DL but does not support small BWP for UL of FDD cell-13
    ...    Setting ChannelBWs-DL: not support 30M but support 20M
    ...    ChannelBWs-UL: support 30M, not support 20M
    ...    ->DLonly scell(20M) add with FDD cell-13
    ...    cell-12 DL and UL scell addition, cell-13 DLonly(20M:carrierBandwidth 106) scell addition for UE-2
    ...    UE3:BC#1: N41a*-N66a*-N71a*,UE supports full BWP for DL but does not support full BWP for UL of FDD cell-13
    ...    Setting ChannelBWs-DL: support 30M
    ...    ChannelBWs-UL: not support 30M->DLonly scell(30M) add with FDD cell-13
    ...    cell-12 DL and UL scell addition, cell-13 DLonly(30M:carrierBandwidth 160) scell addition for UE-3
    [Tags] 
    Ue with specified capabilitiy Register And Pdu Session Setup At TDD Cell-1    ue_id=1
    ...    ue_capa=${N41DLUL_N66DLUL_N71DLUL_support_N66DL_to_10M}
    UE Send A1 report And Check Cell12 DL And UL Scell Addition
    Release Ues    ue_type=all
    Ue with specified capabilitiy Register And Pdu Session Setup At TDD Cell-1    ue_id=2
    ...    ue_capa=${N41DLUL_N66DLUL_N71DLUL_support_N66DL_to_20M_N66UL_support_30M_no_20M}
    UE Send A1 report And Check Cell12 DL UL Scell Addition Cell13 DLonly Scell Addition With Small BWP
    Release Ues    ue_type=all
    Ue with specified capabilitiy Register And Pdu Session Setup At TDD Cell-1    ue_id=3
    ...    ue_capa=${N41DLUL_N66DLUL_N71DLUL_support_N66DL_to_30M_N66UL_to_10M}
    UE Send A1 report And Check Cell12 DL UL Scell Addition Cell13 DLonly Scell Addition With Large BWP
    Check rrc log    ${CURDIR}${/}A2A_case_02${/}a2a_02.ini	

CB009169-SR-BB-B3_ET_04_01_Verify SCell selection with UL CA when UE support large BWP for DL and small BWP for UL
    [Documentation]
    ...    The purpose of this test case is to check following scenarios:
    ...    Verify UL scell is selected when UE only support large BWP for DL and small BWP for UL scell and actEnhMultipleDedicatedBWPs enabled.
    ...    same UE CA Capability and different dlToUlContributionRatio:
    ...    UE1:BC#1: N41a*-N66a*-N71a,UE support large BWP for DL and small BWP for UL
    ...    Setting ChannelBWs-DL: support to 30M
    ...    Setting ChannelBWs-UL: support to 20M
    ...    dlToUlContributionRatio =50:
    ...    solution 1- DLonly: (10+30)*50+0*50=2000
    ...    solution 2- DL&UL:(10+20)*50+(20*0.8)*50=2300
    ...    ->DL&UL scell with band66 add with small BWP(20M:carrierBandwidth 106)
    ...    UE2:BC#1: N41a*-N66a*-N71a,UE support large BWP for DL and small BWP for UL
    ...    Setting ChannelBWs-DL: support to 30M
    ...    Setting ChannelBWs-UL: support to 20M
    ...    dlToUlContributionRatio =70:
    ...    solution 1- DLonly: (10+30)*70+0*30=2800
    ...    solution 2- DL&UL:(10+20)*70+(20*0.8)*30=2580
    ...    ->DLonly scell with band66 add with full BWP(30M:carrierBandwidth 160)
    [Tags]
    Online Change And Wait Cell Onair And Clear Counter Files    ${dlToUlContributionRatio_change_to_50} 
    Ue with specified capabilitiy Register And Pdu Session Setup At TDD Cell-1    ue_id=1
    ...    ue_capa=${N41DLUL_N66DLUL_N71DL_support_N66DL_to_30M_N66UL_to_20M}
    UE Send A1 Report And Check Cell12 DLonly Scell Addition Cell13 DL UL Scell Addition With Small BWP
    Check Counters     ${COUNTER_CHECK_case4}
    Release Ues And Clear Counters
    Online Change And Wait Cell Onair And Clear Counter Files    ${dlToUlContributionRatio_change_to_70}
    Ue with specified capabilitiy Register And Pdu Session Setup At TDD Cell-1    ue_id=2
    ...    ue_capa=${N41DLUL_N66DLUL_N71DL_support_N66DL_to_30M_N66UL_to_20M}
    UE Send A1 report And Check Cell12 DLonly Scell Addition Cell13 DLonly Scell Addition With Large BWP
    Check rrc log    ${CURDIR}${/}A2A_case_04${/}a2a_04.ini		

CB009169-SR-BB-B3_ET_05_01_Verify SCell change with UL CA when UE support large BWP for DL and small BWP for UL
    [Documentation]
    ...    The purpose of this test case is to check following scenarios:
    ...    Verify UL scell is selected when UE only support large BWP for DL and small BWP for UL and actEnhMultipleDedicatedBWPs enabled
    ...    same UE CA Capability and different dlToUlContributionRatio:
    ...    UE1:BC#1: N41a*-N66a*-N71a-N78a*,UE support large BWP for DL and small BWP for UL
    ...    Setting ChannelBWs-DL: support to 30M
    ...    Setting ChannelBWs-UL: support to 20M
    ...    dlToUlContributionRatio =70:
    ...    solution 1- DLonly: (10+30)*70+0*30=2800
    ...    solution 2- DL&UL:(10+20)*70+(20*0.8)*30=2580
    ...    ->UE-1 report A1 RSRP> a1ThresholdSCellAddSsbRsrpTDD, TDD cell-2 scell addition
    ...    ->UE-1 report A1 RSRP> a1ThresholdSCellAddSsbRsrpFDD, trigger scell change
    ...    ->FDD cell-12 and FDD cell-13 scell addition: DLonly scell with band66(cell-13) add with full BWP(30M:carrierBandwidth 160)
    ...    UE2:BC#1: N41a*-N66a*-N71a-N78a*,UE support large BWP for DL and small BWP for UL
    ...    Setting ChannelBWs-DL: support to 30M
    ...    Setting ChannelBWs-UL: support to 20M
    ...    dlToUlContributionRatio =50:
    ...    solution 1- DLonly: (10+30)*50+0*50=2000
    ...    solution 2- DL&UL:(10+20)*50+(20*0.8)*50=2300
    ...    ->UE-2 report A1 RSRP> a1ThresholdSCellAddSsbRsrpTDD, TDD cell-2 scell addition
    ...    ->UE-2 report A1 RSRP> a1ThresholdSCellAddSsbRsrpFDD, trigger scell change
    ...    ->FDD cell-12 and FDD cell-13 scell addition:DL&UL scell with band66 add with small BWP(20M:carrierBandwidth 106)
    [Tags]
    Online Change And Wait Cell Onair And Clear Counter Files    ${dlToUlContributionRatio_change_to_70}
    Ue with specified capabilitiy Register And Pdu Session Setup At TDD Cell-1    ue_id=1
    ...    ue_capa=${N41DLUL_N66DLUL_N71DL_N78DL_support_N66DL_to_30M_N66UL_to_20M} 
    Send A1 report to trigger TDD Scell Addition with RSRP large than TDD threshold Ande Check Cell2 Scell Addition    ue_id=1
    Send A1 report to trigger TDD scell change to FDD And Check Cell12 DLonly Cell13 Dlonly with Large BWP For Scell Addition
    Check Counters And Release UE
    Online Change And Wait Cell Onair And Clear Counter Files    ${dlToUlContributionRatio_change_to_50}
    Ue with specified capabilitiy Register And Pdu Session Setup At TDD Cell-1    ue_id=2
    ...    ue_capa=${N41DLUL_N66DLUL_N71DL_N78DL_support_N66DL_to_30M_N66UL_to_20M}
    Send A1 report to trigger TDD Scell Addition with RSRP large than TDD threshold Ande Check Cell2 Scell Addition    ue_id=2
    Send A1 report to trigger TDD scell change to FDD And Check Cell12 DLonly Cell13 DlUl with Small BWP For Scell Addition
    Check rrc log    ${CURDIR}${/}A2A_case_05${/}a2a_05.ini	
*** Keywords ***
Ue with specified capabilitiy Register And Pdu Session Setup At TDD Cell-1
    [Arguments]    ${ue_id}    ${ue_capa}
    Execute Egate Command    ue_location_change id=${ue_id} enb=2 cell=1
    Execute Egate Command    ue_register id=${ue_id} ue_nr_capabilities=${ue_capa}    pass_regexp=UE now in NG RM Registere
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=${ue_id} nwslice=1    pass_regexp=QoS Routing Table
	
Release Ues And Clear Counters
    Release Ues    ue_type=all
    Clear Counter Files
	
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


Send A1 report to trigger TDD Scell Addition with RSRP large than TDD threshold Ande Check Cell2 Scell Addition
    [Arguments]    ${ue_id}=1    ${cell_freq}=${cell_1_ssbFrequency}
    Start rrc log    scell_add_UE${ue_id}
    ${measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cell_freq}    event_type=A1
    ${expect_output}    Create List
    ...    rrcReconfigurationComplete
    ...    pcid:${Cell_2_TDD_PCI}, scellIdx:1
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${measid} event=A1 srsrp_nr=55 ssinr_nr=120 srsrq_nr=32
    ...    pass_regexp=${expect_output}
    Should Not Contain    ${ret1}    uplinkConfigCommon
    Get Rrc Log

Send A1 report to trigger TDD scell change to FDD And Check Cell12 DLonly Cell13 Dlonly with Large BWP For Scell Addition
    [Arguments]    ${ue_id}=1    ${cell_freq}=${cell_1_ssbFrequency}
    Start rrc log    scell_change_to_FDD_UE${ue_id}
    ${measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cell_freq}    event_type=A1
    ${expect_output}    Create List
    ...    rrcReconfigurationComplete
    ...    pcid:${Cell_12_FDD_PCI}, scellIdx:2
    ...    pcid:${Cell_13_FDD_PCI}, scellIdx:3
    ...    carrierBandwidth 160
    ...    locationAndBandwidth 32174
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${measid} event=A1 srsrp_nr=70 ssinr_nr=120 srsrq_nr=32
    ...    pass_regexp=${expect_output}
    Should Not Contain    ${ret1}    uplinkConfigCommon
    Get RRC log

Send A1 report to trigger TDD scell change to FDD And Check Cell12 DLonly Cell13 DlUl with Small BWP For Scell Addition
    [Arguments]    ${ue_id}=2    ${cell_freq}=${cell_1_ssbFrequency}
    Start rrc log    scell_change_to_FDD_UE${ue_id}
    ${measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cell_freq}    event_type=A1
    ${expect_output}    Create List
    ...    rrcReconfigurationComplete
    ...    pcid:${Cell_12_FDD_PCI}, scellIdx:2
    ...    pcid:${Cell_13_FDD_PCI}, scellIdx:3
    ...    carrierBandwidth 106
    ...    locationAndBandwidth 28875
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${measid} event=A1 srsrp_nr=70 ssinr_nr=120 srsrq_nr=32
    ...    pass_regexp=${expect_output}
    Get RRC log
	
Online Change And Wait Cell Onair And Clear Counter Files
    [Arguments]    ${online_change}
    Online Change And Wait Cell Onair    ${online_change}
    Clear Counter Files
	
UE Send A1 report And Check Cell12 DL And UL Scell Addition
    [Arguments]    ${ue_id}=1    ${cell_freq}=${cell_1_ssbFrequency}
    Start rrc log    scell_add_UE${ue_id}
    ${measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cell_freq}    event_type=A1
    ${expect_output}    Create List
    ...    rrcReconfigurationComplete
    ...    pcid:${Cell_12_FDD_PCI}, scellIdx:1
    ...    uplinkConfigCommon
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${measid} event=A1 srsrp_nr=70 ssinr_nr=120 srsrq_nr=32
    ...    pass_regexp=${expect_output}
    Should Not Contain    ${ret1}    physCellId ${Cell_13_FDD_PCI}
    Get Rrc Log

UE Send A1 report And Check Cell12 DL UL Scell Addition Cell13 DLonly Scell Addition With Small BWP
    [Arguments]    ${ue_id}=2    ${cell_freq}=${cell_1_ssbFrequency}
    Start rrc log    scell_add_UE${ue_id}
    ${measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cell_freq}    event_type=A1
    ${expect_output}    Create List
    ...    rrcReconfigurationComplete
    ...    pcid:${Cell_12_FDD_PCI}, scellIdx:1
    ...    uplinkConfigCommon
    ...    pcid:${Cell_13_FDD_PCI}, scellIdx:2
    ...    carrierBandwidth 106
    ...    locationAndBandwidth 28875
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${measid} event=A1 srsrp_nr=70 ssinr_nr=120 srsrq_nr=32
    ...    pass_regexp=${expect_output}
    Get Rrc Log	

UE Send A1 Report And Check Cell12 DLonly Scell Addition Cell13 DL UL Scell Addition With Small BWP
    [Arguments]    ${ue_id}=1    ${cell_freq}=${cell_1_ssbFrequency}
    Start rrc log    scell_add_UE${ue_id}
    ${measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cell_freq}    event_type=A1
    ${expect_output}    Create List
    ...    rrcReconfigurationComplete
    ...    pcid:${Cell_12_FDD_PCI}, scellIdx:1
    ...    uplinkConfigCommon
    ...    pcid:${Cell_13_FDD_PCI}, scellIdx:2
    ...    carrierBandwidth 106
    ...    locationAndBandwidth 28875
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${measid} event=A1 srsrp_nr=70 ssinr_nr=120 srsrq_nr=32
    ...    pass_regexp=${expect_output}
    Get Rrc Log	
UE Send A1 report And Check Cell12 DL UL Scell Addition Cell13 DLonly Scell Addition With Large BWP
    [Arguments]    ${ue_id}=3    ${cell_freq}=${cell_1_ssbFrequency}
    Start rrc log    scell_add_UE${ue_id}
    ${measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cell_freq}    event_type=A1
    ${expect_output}    Create List
    ...    rrcReconfigurationComplete
    ...    pcid:${Cell_12_FDD_PCI}, scellIdx:1
    ...    uplinkConfigCommon
    ...    pcid:${Cell_13_FDD_PCI}, scellIdx:2
    ...    carrierBandwidth 160
    ...    locationAndBandwidth 32174
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${measid} event=A1 srsrp_nr=70 ssinr_nr=120 srsrq_nr=32
    ...    pass_regexp=${expect_output}
    Get Rrc Log
	
UE Send A1 report And Check Cell12 DLonly Scell Addition Cell13 DLonly Scell Addition With Large BWP
    [Arguments]    ${ue_id}=2    ${cell_freq}=${cell_1_ssbFrequency}
    Start rrc log    scell_add_UE${ue_id}
    ${measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cell_freq}    event_type=A1
    ${expect_output}    Create List
    ...    rrcReconfigurationComplete
    ...    pcid:${Cell_12_FDD_PCI}, scellIdx:1
    ...    pcid:${Cell_13_FDD_PCI}, scellIdx:2
    ...    carrierBandwidth 160
    ...    locationAndBandwidth 32174
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${measid} event=A1 srsrp_nr=70 ssinr_nr=120 srsrq_nr=32
    ...    pass_regexp=${expect_output}
    Should Not Contain    ${ret1}    uplinkConfigCommon
    Get Rrc Log
	
Check Counters And Release UE
    Check Counters     ${COUNTER_CHECK_case5}
    Release Ues    ue_type=all