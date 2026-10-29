*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CLOUD_5G_I_BOO_AP_LOO    team-PZ3_6
...    owner-xiaowen.xu    release-SBTS24R3    CRT
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${TL_TYPE_PATH}    fddtdd_sansa_cmwv/6cells_2T4F
${SYSCOM_FLAG}    ${True}
@{PARAMS_IN_SWCONFIG}
# rdFeatureFlagBitmapLevel = 3 (INFO level)
...    0x58057A=3
# rdFeatureFlagBitmap1 = 0x4000 (bit14=PRB_POOLING.PDCCH)
...    0x58057C=16384
# rdFeatureFlagBitmap2 = 0x74000000 (bit26=PDCCH.CCE_ALLOC, bit 28=PDCCH.DYN_ALLOC, bit 29=FDM_CCE_ALLOC, bit30=PDCCH.DYN_TD_MGT)
...    0x58057D=1946157056
# rdComponentBitMapProfile = 2 , bit1 = 1, ie: activate ttiTrace profile 1, ie: default TtiTraces + ul/dl pdcchPatternData
...    0x5808FF = 2
@{PARAMS_IN_SCF}
...    @{732}
...    @{FR1_CA_cell1_cell11}
...    @{7552_8541_9355}
@{732}
...    NRBTS:rrcReestabTypeSA=sameGNB
...    NRBTS:tWaitingRlRecover=4000ms

@{FR1_CA_cell1_cell11}
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS/NRDU-1:actConnectedModeMobilityCA=true
...    NRBTS/NRDU-1:carrierAggregationSupportList=ca_Fdd_Fr1Tdd_Sa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fdd_Any_Sa,ca_Fr1Tdd_Any_Sa,ca_Fdd_Fdd
...    NRBTS/NRSYSINFO_PROFILE-1:systemInformationTargetRate=157
...    NRCELL-1:a1MeasSCellAddEnabled=rsrp
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=60
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=90
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-1/NRREL-1:actA4ToA1BasedSCellFallbackNsa=false
...    NRCELL-1/NRREL-1:gNbId=1
...    NRCELL-1/NRREL-1:lcrId=11
...    NRCELL-1/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-11:a2MeasSCellRelEnabled=rsrp
...    NRCELL-11:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0
...    NRCELL-11:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=34
...    NRCELL-11:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=2560ms
...    NRCELL-11/NRREL-2:actA4ToA1BasedSCellFallbackNsa=false
...    NRCELL-11/NRREL-2:gNbId=1
...    NRCELL-11/NRREL-2:lcrId=1
...    NRCELL-11/NRREL-2:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-2:gnbPlmn:mncLength=3

@{7552_8541_9355}
...    NRBTS:actMultipleDedicatedBWPs=true
...    NRCELL-1:actEnhMultipleDedicatedBWPs=true
...    NRCELL-11:actEnhMultipleDedicatedBWPs=true

...    NRCELL-1:chBw=15MHz
...    NRCELL-1:gscnOrSsPbchArfcn=6477
...    NRCELL-1:msg1FrequencyStart=10
...    NRCELL-1:nrarfcn=518640
...    NRCELL-1:prachConfigurationIndex=9
...    NRCELL-1:type0CoresetConfigurationIndex=2
...    NRCELL-1:dmrsTypeAPosition=pos3

...    NRCELL-1:cellBwpList:actPdcchCceFragmentControl=false|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-8
...    NRCELL-1:cellBwpList:cellBwpId=1|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-7
...    NRCELL-1:cellBwpList:cellBwpId=2|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-9
...    NRCELL-1:pdcchAutoConfig:initialBWPMode=sameAsCoreset0
...    NRCELL-1:pdcchAutoConfig:pucchSize=14
...    NRCELL-1:pdcchAutoConfig:startCRBOfCoreset0=4

...    NRBTS/BWP_PROFILE-7:bwpType=dedicated
...    NRBTS/BWP_PROFILE-7:locationAndBandwidthDl:cRbSizeDl=allRb
...    NRBTS/BWP_PROFILE-7:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-7:locationAndBandwidthUl:cRbSizeUl=sameAsDl
...    NRBTS/BWP_PROFILE-7:locationAndBandwidthUl:cRbStartUl=sameAsDl
...    NRBTS/BWP_PROFILE-7/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=9|searchSpaceId=4
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=4
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|searchSpaceId=4
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=4
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=4|searchSpaceId=4
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=5
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=9|searchSpaceId=6
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=6
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|searchSpaceId=6
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=6
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=4|searchSpaceId=6
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cceToRegMapping=nonInterleaved
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:coresetId=1
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cRbStart=0
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:duration=1
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:interleaverSize=none
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:regBundleSize=n6
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=36
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-0-And-1-0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|searchSpaceId=7
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|searchSpaceId=7
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|searchSpaceId=7
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|searchSpaceId=7
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=1|searchSpaceId=8
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-0-And-1-0|searchSpaceId=8
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=39|searchSpaceId=8
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_2|searchSpaceId=8
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|searchSpaceId=8
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceId=8
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|searchSpaceId=8
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n1|searchSpaceId=8
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceId=8
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl40|searchSpaceId=8
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|searchSpaceId=8
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=1|searchSpaceId=8
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|searchSpaceId=9
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|searchSpaceId=9
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|searchSpaceId=9
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|searchSpaceId=9
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|searchSpaceId=9
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=1|searchSpaceId=10
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|searchSpaceId=10
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=39|searchSpaceId=10
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_2|searchSpaceId=10
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n1|searchSpaceId=10
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl40|searchSpaceId=10
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|searchSpaceId=10
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=1|searchSpaceId=10
...    NRBTS/BWP_PROFILE-7/PDSCH-1:pdschRat0RbgConfig=config1
...    NRBTS/BWP_PROFILE-8:bwpType=initial
...    NRBTS/BWP_PROFILE-8:locationAndBandwidthDl:cRbSizeDl=n24
...    NRBTS/BWP_PROFILE-8:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-8:locationAndBandwidthUl:cRbSizeUl=n24
...    NRBTS/BWP_PROFILE-8:locationAndBandwidthUl:cRbStartUl=crb0
...    NRBTS/BWP_PROFILE-8/PDCCH-1:alSelection=static

...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=9|searchSpaceId=1
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=1
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|searchSpaceId=1
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=1
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=4|searchSpaceId=1
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=2
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=9|searchSpaceId=3
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=3
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|searchSpaceId=3
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=3
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=4|searchSpaceId=3
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=18
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=18
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=9|searchSpaceId=18
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=18
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=18
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=18
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=18
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=18
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|searchSpaceId=18
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=18
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=4|searchSpaceId=18
...    NRBTS/BWP_PROFILE-9:bwpType=dedicated
...    NRBTS/BWP_PROFILE-9:locationAndBandwidthDl:cRbSizeDl=n24
...    NRBTS/BWP_PROFILE-9:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-9:locationAndBandwidthUl:cRbSizeUl=n24
...    NRBTS/BWP_PROFILE-9:locationAndBandwidthUl:cRbStartUl=crb0
...    NRBTS/BWP_PROFILE-9/PDCCH-1:alSelection=static

...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=9|searchSpaceId=11
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=11
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|searchSpaceId=11
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=11
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=4|searchSpaceId=11
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=12
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=12
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=12
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=12
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=12
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=12
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=12
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=12
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=12
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=12
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=12
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=13
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=13
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=9|searchSpaceId=13
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=13
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=13
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=13
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=13
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=13
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|searchSpaceId=13
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=13
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=4|searchSpaceId=13
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cceToRegMapping=nonInterleaved
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:coresetId=4
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cRbStart=0
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:duration=1
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:interleaverSize=none
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:regBundleSize=n6
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=24
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=0|searchSpaceId=14
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-0-And-1-0|searchSpaceId=14
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|searchSpaceId=14
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=14
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|searchSpaceId=14
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceId=14
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|searchSpaceId=14
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|searchSpaceId=14
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceId=14
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|searchSpaceId=14
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|searchSpaceId=14
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|searchSpaceId=14
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=4|searchSpaceId=15
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-0-And-1-0|searchSpaceId=15
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=39|searchSpaceId=15
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_2|searchSpaceId=15
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|searchSpaceId=15
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceId=15
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|searchSpaceId=15
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n1|searchSpaceId=15
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceId=15
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl40|searchSpaceId=15
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|searchSpaceId=15
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=1|searchSpaceId=15
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=0|searchSpaceId=16
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|searchSpaceId=16
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|searchSpaceId=16
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=16
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|searchSpaceId=16
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceId=16
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|searchSpaceId=16
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|searchSpaceId=16
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceId=16
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|searchSpaceId=16
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|searchSpaceId=16
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|searchSpaceId=16
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=4|searchSpaceId=17
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|searchSpaceId=17
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=39|searchSpaceId=17
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_2|searchSpaceId=17
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|searchSpaceId=17
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceId=17
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|searchSpaceId=17
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n1|searchSpaceId=17
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceId=17
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl40|searchSpaceId=17
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|searchSpaceId=17
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=1|searchSpaceId=17
...    NRBTS/BWP_PROFILE-9/PDSCH-1:pdschRat0RbgConfig=config1

${ue_capa_15M}    SEPARATOR=
...    E9A09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C4700FB8D85181AC1184341020E9068036B64C558D0
...    E7C471E819F604F8C48E3C873EA39F30C7942C0E070F05C00E00007003800005C0000E0541B107582308682041E20D00656C98AB121CFB027
...    C471E31238F21CFA8E7CC31E50B0381C3C27FFC00001FFF00000170000381546C4DD608C21A0810748340165B262A86873E238F40CFB027C6
...    39F30C7942C0E070F02E007FE003801FF8002E0000702A8D899AC1184341020E906802CB64C550D0E7C471E819F604F8C73E618F28581C0E1
...    E05C00FFC007003FF0005C0000E001BC3C41000E260000000B0102F0F0A00038980000142C040B83C28000E208000050B010200E023402880
...    9B01045D0009C070A244D8E7C3851226C73E1C28913639F0C001C0C631FEFFFFFC2E003C00281C1401C0C02500700060240040603E0380200
...    00000100000200800002004000018020000100100000A008000060040000380EC0CACA8AC98AC89AC19AC18AC0DACA9A0382000012CA4A080
...    000CB29282000052CA4A080001CB29282000092CA4A080002CB292820000D2CA4A080003CB29280EA07554AAAA9355522CAA0D9541AAA81E5
...    52ACA16004800D02800142020100200801002101008010040080110080100202010020080100220100E01C04038070100E01C20200C018080
...    200410100801004008011AA1F000102030406070A0B0C0D101112131418191B1C1D1F2125262728292A2D2F414182D0

${ue_capa_10M}    SEPARATOR=
...    E9A09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C4700FB8D85181AC1184341020E9068036B64C558D0
...    E7C471E819F604F8C48E3C873EA39F30C7942C0E070F05C00C00007003000005C0000E0541B107582308682041E20D00656C98AB121CFB027
...    C471E31238F21CFA8E7CC31E50B0381C3C27FFC00001FFF00000170000381546C4DD608C21A0810748340165B262A86873E238F40CFB027C6
...    39F30C7942C0E070F02E007FE003801FF8002E0000702A8D899AC1184341020E906802CB64C550D0E7C471E819F604F8C73E618F28581C0E1
...    E05C00FFC007003FF0005C0000E001BC3C41000E260000000B0102F0F0A00038980000142C040B83C28000E208000050B010200E023402880
...    9B01045D0009C070A244D8E7C3851226C73E1C28913639F0C001C0C631FEFFFFFC2E003C00281C1401C0C02500700060240040603E0380200
...    00000100000200800002004000018020000100100000A008000060040000380EC0CACA8AC98AC85AC19AC18AC0DACA9A0382000012CA4A080
...    000CB29282000052CA4A080001CB29282000092CA4A080002CB292820000D2CA4A080003CB29280EA07554AAAA9355521CAA0D9541AAA81E5
...    52ACA16004800D02800142020100200801002101008010040080110080100202010020080100220100E01C04038070100E01C20200C018080
...    200410100801004008011AA1F000102030406070A0B0C0D101112131418191B1C1D1F2125262728292A2D2F414182D0

&{CELLS_CARRIER_FREQ}
...     1=518190
...     11=424090

*** Test Cases ***
CB009355_D001_SA_UE_IWK1_CB007552_MultiBWP_enabled_IWK13_CB008541_scell_support_MultiBwp_enable
    [Documentation]    This case will test SA Carrier Aggregation - TDD SCell selection iwk with 8541
    ...    preconditions:
    ...        1.UE1 supports 15MHz (large BWP) when non CA, when do TF CA, the pcell only support small BWP, check the BWP switch.
    ...        2.UE2 supports 10MHz (small BWP)
    ...        3.Cell1 configured multiBWP 15MHz and 10MHz, CA relationship with Cell 11 as A1based
    ...        4.Cell11 support 8541 ,CA relationship with Cell 1 as blind
    ...    Case steps:
    ...        1.Cell 1 TDD n41 on air with multiBWP, large 15Mhz, small 10Mhz ,cell 11 FDD on air.
    ...        2.Trigger Ue1 attach to Cell-1,check configure with large BWP ,Trigger A1based CA,FDD Cell-11 added as scell
    ...        3.Trigger Ue2 attach to Cell-1,check configure with small BWP ,Trigger A1based CA,FDD Cell-11 added as scell
    ...        4.Release all Ues
    ...        5.Trigger Ue2 attach to Cell-11,Cell-1 blindly added as scell
    ...        6.Trigger Ue1 attach to Cell-11,Cell-1 blindly added as scell
    ...        7.Release all Ues
    ...     checkpoints:
    ...      a.check PRB used for 15Mhz/10Mhz:SCS-SpecificCarrier carrierBandwidth
    ...      b.check freqHopping.c-SRS IE in srs-Config IE
    ...      c.CA status and traffic

    [Tags]    D001    QC_46944
    [Timeout]     60 min
    UE Attach To Cell1 and A1based Add Scell-11    UE_ID=1
    UE Attach To Cell1 and A1based Add Scell-11    UE_ID=2
    Wait Until Keyword Succeeds    60s    5s    Verify SA DL and UL Traffic
    Release Ues    ue_type=all
    UE Attach To Cell11 and Blindly Add Scell-1    UE_ID=2
    UE Attach To Cell11 and Blindly Add Scell-1    UE_ID=1
    Wait Until Keyword Succeeds    60s    5s    Verify SA DL and UL Traffic
    Release Ues    ue_type=all
    check wireshark log    a2a_ini_file=${CURDIR}/A2A_D001/a2a.ini    wait_string=UEContextReleaseComplete::16
*** Keywords ***
Verify SA DL and UL Traffic
    Builtin.sleep    5s
    ${ul_throuput_1}    Ap Get SA Throughput    ue_id=1    pdu=1    qfi=1    direction=ul    rate_type=ave
    ${ul_throuput_2}    Ap Get SA Throughput    ue_id=2    pdu=2    qfi=1    direction=ul    rate_type=ave
    ${ul_sum}=    Evaluate    ${ul_throuput_1}+${ul_throuput_2}
    Should Be True    ${ul_sum}/1000>9
    ${dl_throuput_1}    Ap Get SA Throughput    ue_id=1    pdu=1    qfi=1    direction=dl    rate_type=ave
    ${dl_throuput_2}    Ap Get SA Throughput    ue_id=2    pdu=2    qfi=1    direction=dl    rate_type=ave
    ${dl_sum}=    Evaluate    ${dl_throuput_1}+${dl_throuput_2}
    Should Be True    ${dl_sum}/1000>100

UE Attach To Cell1 and A1based Add Scell-11
    [Arguments]     ${UE_ID}=1
    ${ret}    Execute Egate Command    ue_change_location id=${UE_ID} enb=2 cell=1    pass_regexp=location
    Should Contain Any    ${ret}    location updated    already there
    Execute Egate Command    ue_register id=${UE_ID}     pass_regexp=Received REGISTRATION COMPLETE
    ${enb_id}    ${cell_id}    Get UE Location    ${UE_ID}
    Should Be Equal    ${cell_id}    1
    Execute Egate Command    set_pdu_param ue=${UE_ID} pdu=${UE_ID} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup pdu=${UE_ID} ue=${UE_ID} nwslice=1 gw=${UE_ID}
    ...                      pass_regexp=Initial Context Setup Successful
    Start Traffic    UE_ID=${UE_ID}
    Trigger Scell Addition by A1 Event    UE_ID=${UE_ID}

Trigger Scell Addition by A1 Event
    [Arguments]    ${UE_ID}    ${pcell_id}=1    ${scell_num}=1
    ${pcell_carrier_freq}    Get From Dictionary    ${CELLS_CARRIER_FREQ}    ${pcell_id}
    ${meas_id}    Get Nr Meas Id For Specific Type And Frequency    ${UE_ID}    ${pcell_carrier_freq}    A1
    Execute Egate Command
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=112 srsrq_nr=80
    ...    pass_regexp=sCellToAddModList

UE Attach To Cell11 and Blindly Add Scell-1
    [Arguments]     ${UE_ID}=1
    ${ret}    Execute Egate Command    ue_change_location id=${UE_ID} enb=2 cell=11    pass_regexp=location
    Should Contain Any    ${ret}    location updated    already there
    Execute Egate Command    ue_register id=${UE_ID}     pass_regexp=Received REGISTRATION COMPLETE
    ${enb_id}    ${cell_id}    Get UE Location    ${UE_ID}
    Should Be Equal    ${cell_id}    11
    Setup PDU Session and Add Scell-1 Blindly    UE_ID=${UE_ID}

Setup PDU Session and Add Scell-1 Blindly
    [Arguments]     ${UE_ID}=1
    Start RRC Log      scell_blind_addition
    Execute Egate Command    set_pdu_param ue=${UE_ID} pdu=${UE_ID} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup pdu=${UE_ID} ue=${UE_ID} nwslice=1 gw=${UE_ID}
    ...                      pass_regexp=Initial Context Setup Successful
    Rrc Should Contain    sCellToAddModList    sCellIndex 1    physCellId 50
    Start Traffic    UE_ID=${UE_ID}

Start Traffic
    [Arguments]    ${UE_ID}=1
    Execute Egate Command    trf_data_start ue=${UE_ID} pdu=${UE_ID} qfi=1 dir=dl mbps=55 trf_id=2
    ...    pass_regexp=UE ${UE_ID}: UDP DL
    Execute Egate Command    trf_data_start ue=${UE_ID} pdu=${UE_ID} qfi=1 dir=ul mbps=6 trf_id=2
    ...    pass_regexp=UE ${UE_ID}: UDP UL

Modify Cfg
    Update Cfg    ue_param id=1 ue_nr_capabilities=${ue_capa_15M}
    Update Cfg    ue_param id=2 ue_nr_capabilities=${ue_capa_10M}
    Update Cfg    set_qosflow id=1 5qi=6 default=off
    Update Cfg    set_qosflow id=2 5qi=5 default=on
    Update Cfg    set_qosflow id=3 5qi=1
    Update Cfg    set_qosflow id=4 5qi=2
    Update Cfg    set_qosrule id=1 proto=tcp qos_flow=2
    Update Cfg    set_qosrule id=2 proto=udp qos_flow=3
    Update Cfg    set_qosrule id=3 proto=udp qos_flow=4
    Update Cfg    set_nwslice id=1 snssai=0x01:0xD143A5 default=on ue=all amf=1 qos_flows=1,2,3,4 qos_rules=1,2,3
