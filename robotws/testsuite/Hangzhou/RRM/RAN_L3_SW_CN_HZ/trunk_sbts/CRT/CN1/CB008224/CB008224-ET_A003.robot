*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CLOUD_5G_I_BOO_AP_LOO    team-CN1ET
...    owner-yige.g.zhang    release-SBTS24R3    CRT
...    STATE_CONFIGURED
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_IPHY_XML}    fddFrequencyRange=FR1_WB
${NOKIA_XNAP_PLUGIN_FLAG}    ${True}
${NOKIA_F1AP_PLUGIN_FLAG}    ${True}
${SYSCOM_FLAG}    ${True}

@{PARAMS_IN_SCF}
...    @{PARAMS_FOR_8224}
...    @{PowerSaving}
...    @{Xn_link}
...    @{PARAMS_FOR_CA}
...    @{large_fdd_cell}
...    @{CB007552_CB008541}
...    NRCELL:actSib1ForNsaCell=true
...    MRBTS-1/NRBTS-1/NRSCTP-1:sctpProfile:sctpWaitTimeInitSeqRetry=30
#...    @{UN_PARAMS_FOR_8224}

@{CB007552_CB008541}
...    NRBTS:actMultipleDedicatedBWPs=true
...    NRCELL:actEnhMultipleDedicatedBWPs=true

...    NRBTS/BWP_PROFILE-16:bwpType=initial
...    NRBTS/BWP_PROFILE-16:locationAndBandwidthDl:cRbSizeDl=n133
...    NRBTS/BWP_PROFILE-16:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-16:locationAndBandwidthUl:cRbSizeUl=n133
...    NRBTS/BWP_PROFILE-16:locationAndBandwidthUl:cRbStartUl=crb0
...    NRBTS/BWP_PROFILE-16/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=1
...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=1
...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=1
...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=1
...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=2
...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=3
...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=3
...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=3

...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=3
...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=3
...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-38:bwpType=dedicated
...    NRBTS/BWP_PROFILE-38:locationAndBandwidthDl:cRbSizeDl=n216
...    NRBTS/BWP_PROFILE-38:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-38:locationAndBandwidthUl:cRbSizeUl=n216
...    NRBTS/BWP_PROFILE-38:locationAndBandwidthUl:cRbStartUl=crb0
...    NRBTS/BWP_PROFILE-38/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=4
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=4
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=4
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=4
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=5
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=6
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=6
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=6
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=6
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cceToRegMapping=nonInterleaved
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:coresetId=1
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cRbStart=0
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:duration=1
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:interleaverSize=none
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:regBundleSize=n6
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=120
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=0
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=0
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=0
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|coresetId=0
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=0
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=0
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=7|coresetId=0
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|coresetId=0
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=0
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|coresetId=1
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=1
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=1
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=1
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n5|coresetId=1
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=1
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=1
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=8|coresetId=1
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|coresetId=1
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=1
...    NRBTS/BWP_PROFILE-38/PDSCH-1:pdschRat0RbgConfig=config1
...    NRBTS/BWP_PROFILE-37:bwpType=dedicated
...    NRBTS/BWP_PROFILE-37:locationAndBandwidthDl:cRbSizeDl=n133
...    NRBTS/BWP_PROFILE-37:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-37:locationAndBandwidthUl:cRbSizeUl=n133
...    NRBTS/BWP_PROFILE-37:locationAndBandwidthUl:cRbStartUl=crb0
...    NRBTS/BWP_PROFILE-37/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=9
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=9
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=9
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=9
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=10
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=10
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=10
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=10
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=11
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=11
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=11
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=11
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cceToRegMapping=nonInterleaved
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:coresetId=4
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cRbStart=0
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:duration=1
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:interleaverSize=n3
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:regBundleSize=n2
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=120
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=0
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=0
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=0
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|coresetId=0
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=0
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=0
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=12|coresetId=0
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|coresetId=0
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=0
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|coresetId=4
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=4
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=4
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=4
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n5|coresetId=4
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=4
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=4
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=13|coresetId=4
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|coresetId=4
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=4
...    NRBTS/BWP_PROFILE-37/PDSCH-1:pdschRat0RbgConfig=config1
#n66    40Mhz ,25Mhz
...    NRCELL-13:cellBwpList:actPdcchCceFragmentControl=false|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-38
...    NRCELL-13:cellBwpList:pdcchResourcePreference=peakRate|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-38
...    NRCELL-13:cellBwpList:actPdcchCceFragmentControl=false|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-37
...    NRCELL-13:cellBwpList:pdcchResourcePreference=peakRate|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-37
...    NRCELL-13:cellBwpList:cellBwpId=0|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-16
...    NRCELL-13:cellBwpList:cellBwpId=1|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-38
...    NRCELL-13:cellBwpList:cellBwpId=2|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-37



...    NRBTS/BWP_PROFILE-14:bwpType=initial
...    NRBTS/BWP_PROFILE-14:locationAndBandwidthDl:cRbSizeDl=n79
...    NRBTS/BWP_PROFILE-14:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-14:locationAndBandwidthUl:cRbSizeUl=n79
...    NRBTS/BWP_PROFILE-14:locationAndBandwidthUl:cRbStartUl=crb0
...    NRBTS/BWP_PROFILE-14/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=1
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=1
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=1
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=1
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=2
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=3
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=3
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=3

...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=3
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=3
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-33:bwpType=dedicated
...    NRBTS/BWP_PROFILE-33:locationAndBandwidthDl:cRbSizeDl=n106
...    NRBTS/BWP_PROFILE-33:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-33:locationAndBandwidthUl:cRbSizeUl=n106
...    NRBTS/BWP_PROFILE-33:locationAndBandwidthUl:cRbStartUl=crb0
...    NRBTS/BWP_PROFILE-33/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=4
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=4
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=4
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=4
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=5
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=6
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=6
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=6
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=6
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cceToRegMapping=nonInterleaved
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:coresetId=1
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cRbStart=0
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:duration=1
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:interleaverSize=none
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:regBundleSize=n6
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=96
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=0
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=0
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=0
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n4|coresetId=0
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=0
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=0
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=7|coresetId=0
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|coresetId=0
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=0
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|coresetId=1
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=1
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=1
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=1
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n4|coresetId=1
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=1
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=1
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=8|coresetId=1
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|coresetId=1
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=1
...    NRBTS/BWP_PROFILE-33/PDSCH-1:pdschRat0RbgConfig=config1
...    NRBTS/BWP_PROFILE-32:bwpType=dedicated
...    NRBTS/BWP_PROFILE-32:locationAndBandwidthDl:cRbSizeDl=n79
...    NRBTS/BWP_PROFILE-32:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-32:locationAndBandwidthUl:cRbSizeUl=n79
...    NRBTS/BWP_PROFILE-32:locationAndBandwidthUl:cRbStartUl=crb0
...    NRBTS/BWP_PROFILE-32/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=9
...    NRBTS/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=9
...    NRBTS/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=9
...    NRBTS/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=9
...    NRBTS/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=10
...    NRBTS/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=10
...    NRBTS/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=10
...    NRBTS/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=10
...    NRBTS/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=11
...    NRBTS/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=11
...    NRBTS/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=11
...    NRBTS/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=11
...    NRBTS/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cceToRegMapping=nonInterleaved
...    NRBTS/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:coresetId=4
...    NRBTS/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cRbStart=0
...    NRBTS/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:duration=1
...    NRBTS/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:interleaverSize=none
...    NRBTS/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:regBundleSize=n6
...    NRBTS/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=78
...    NRBTS/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=0
...    NRBTS/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=0
...    NRBTS/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=0
...    NRBTS/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|coresetId=0
...    NRBTS/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=0
...    NRBTS/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=0
...    NRBTS/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=12|coresetId=0
...    NRBTS/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|coresetId=0
...    NRBTS/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=0
...    NRBTS/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|coresetId=4
...    NRBTS/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=4
...    NRBTS/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=4
...    NRBTS/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=4
...    NRBTS/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n3|coresetId=4
...    NRBTS/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=4
...    NRBTS/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=4
...    NRBTS/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=13|coresetId=4
...    NRBTS/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|coresetId=4
...    NRBTS/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=4
...    NRBTS/BWP_PROFILE-32/PDSCH-1:pdschRat0RbgConfig=config1

#n71    20Mhz,15Mhz
...    NRCELL-12:cellBwpList:actPdcchCceFragmentControl=false|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-14
...    NRCELL-12:cellBwpList:pdcchResourcePreference=peakRate|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-14
...    NRCELL-12:cellBwpList:actPdcchCceFragmentControl=false|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-33
...    NRCELL-12:cellBwpList:pdcchResourcePreference=peakRate|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-33
...    NRCELL-12:cellBwpList:actPdcchCceFragmentControl=false|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-32
...    NRCELL-12:cellBwpList:pdcchResourcePreference=peakRate|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-32
...    NRCELL-12:cellBwpList:cellBwpId=0|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-14
...    NRCELL-12:cellBwpList:cellBwpId=1|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-33
...    NRCELL-12:cellBwpList:cellBwpId=2|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-32

@{large_fdd_cell}
#n66    25M
...    NRCELL-11/NRCELL_FDD-1:nrarfcnDl=430900
...    NRCELL-11/NRCELL_FDD-1:nrarfcnUl=348920
...    NRCELL-11/NRCELL_FDD-1:chBwDl=25MHz
...    NRCELL-11:gscnOrSsPbchArfcn=5384
#n66    40Mhz ,25Mhz
...    NRCELL-13/NRCELL_FDD-1:nrarfcnDl=430900
...    NRCELL-13/NRCELL_FDD-1:nrarfcnUl=348920
...    NRCELL-13/NRCELL_FDD-1:chBwDl=40MHz
...    NRCELL-13:gscnOrSsPbchArfcn=5384
#n71    20Mhz,15Mhz
...    NRCELL-12/NRCELL_FDD-1:nrarfcnDl=126900
...    NRCELL-12/NRCELL_FDD-1:nrarfcnUl=136100
...    NRCELL-12/NRCELL_FDD-1:chBwDl=20MHz
...    NRCELL-12:gscnOrSsPbchArfcn=1584
#n71    15Mhz
...    NRCELL-14/NRCELL_FDD-1:nrarfcnDl=126900
...    NRCELL-14/NRCELL_FDD-1:nrarfcnUl=136100
...    NRCELL-14/NRCELL_FDD-1:chBwDl=15MHz
...    NRCELL-14:gscnOrSsPbchArfcn=1584

@{UN_PARAMS_FOR_8224}
...    NRCELL-11/NRCELL_FDD-1:chBwUl=25MHz
...    NRCELL-13/NRCELL_FDD-1:chBwUl=40MHz
...    NRCELL-12/NRCELL_FDD-1:chBwUl=20MHz
...    NRCELL-14/NRCELL_FDD-1:chBwUl=15MHz

@{PARAMS_FOR_8224}
#...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-2
#...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-4
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-2
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-3
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-13/CHANNELGROUP-1/CHANNEL-2
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-13/CHANNELGROUP-1/CHANNEL-4
#...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-14/CHANNELGROUP-1/CHANNEL-2
#...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-14/CHANNELGROUP-1/CHANNEL-4

#...    NRCELL-11:nrCellType=2DL0UL
#...    NRCELL-11:cellBarred=barred
#...    NRCELL-11:intraFreqReselection=notAllowed
#...    MRBTS-1/NRBTS-1/NRCELL-11/NRCELL_FDD-1:chBwUl=0MHz
#RMOD-4
...    NRCELL-11:nrCellType=4DL0UL
...    NRCELL-11:cellBarred=barred
...    NRCELL-11:intraFreqReselection=notAllowed
...    MRBTS-1/NRBTS-1/NRCELL-11/NRCELL_FDD-1:chBwUl=0MHz
...    NRCELL-11:dlMimoMode=4x4 or 4x2 Open Loop Spatial Multiplexing

...    MRBTS/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-2:direction=TX
...    MRBTS/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-2:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/ANTL-2
...    MRBTS/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-3:direction=TX
...    MRBTS/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-3:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/ANTL-3
...    MRBTS/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-4:direction=TX
...    MRBTS/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-4:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/ANTL-4

...    NRCELL-12:nrCellType=2DL0UL
...    NRCELL-12:cellBarred=barred
...    NRCELL-12:intraFreqReselection=notAllowed
...    MRBTS-1/NRBTS-1/NRCELL-12/NRCELL_FDD-1:chBwUl=0MHz

...    NRCELL-13:nrCellType=2DL0UL
...    NRCELL-13:cellBarred=barred
...    NRCELL-13:intraFreqReselection=notAllowed
...    MRBTS-1/NRBTS-1/NRCELL-13/NRCELL_FDD-1:chBwUl=0MHz
#...    NRCELL-14:nrCellType=2DL0UL
#...    NRCELL-14:cellBarred=barred
#...    NRCELL-14:intraFreqReselection=notAllowed
#...    MRBTS-1/NRBTS-1/NRCELL-14/NRCELL_FDD-1:chBwUl=0MHz

@{PARAMS_FOR_CA}
...    NRBTS:caConfigurationSupport=4CCDL_2CCUL
...    NRBTS-1:actCarrierAggregation=true
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRDU-1:carrierAggregationSupportList=ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Sa,ca_Fdd_Any_Sa,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Fdd
...    NRBTS/NRDRB_RLC_AM-1:ulTReassemblyIBCA=40
...    NRBTS/NRDRB_RLC_AM-2:ulTReassemblyIBCA=40
...    NRBTS:maxNumScellsDl=4
...    NRBTS:maxNumScellsUl=1
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRCELL:actK1Opt=intraAndInter-gNB
...    NRCELL:timingAdvanceOffset=n25600

@{PowerSaving}
...    NRBTS:actNrLBPowerSaving=true
...    NRBTS:actCoordinated4g5gPowerSaving=cellDeactivation
...    NRBTS/NRPGRP-10:lbpsCSONCtlEnabled=true
...    NRBTS/NRPGRP-10:lbpsLastCellMinLoad=20
...    NRBTS/NRPGRP-10:lbpsLastCellRTXMinLoad=10
...    NRBTS/NRPGRP-10:lbpsLastCellSOEnabled=true
...    NRBTS/NRPGRP-10:lbpsMaxLoad=60
...    NRBTS/NRPGRP-10:lbpsMinLoad=20
...    NRBTS/NRPGRP-10:lbpsMonWinForCellSOff=120
...    NRBTS/NRPGRP-10:lbpsMonWinForCellSOn=120
...    NRBTS/NRPGRP-10:lbpsPdcchLoadOffset=4
...    NRBTS/NRPGRP-10:lbpsRTXCellCapOffset=80
...    NRBTS/NRPGRP-10:lbpsRTXMaxLoad=60
...    NRBTS/NRPGRP-10:lbpsRTXMinLoad=20
...    NRBTS/NRPGRP-10:lbpsRTXSOffTime=300
...    NRBTS/NRPGRP-10:lbpsRTXSOnTime=120
...    NRBTS/NRPGRP-10:lbpsSOMethod=cell switch off
...    NRBTS/NRPGRP-10:lbpsCellList:lbpsCellSOOrder=70|nrCellId=1
...    NRPGRP-10:lbpsPeriodList:lbpsDuration=35|lbpsDayOfWeek=Wed
...    NRPGRP-10:lbpsPeriodList:lbpsStartTimeHour=8|lbpsDayOfWeek=Wed
...    NRPGRP-10:lbpsPeriodList:lbpsStartTimeMinute=20|lbpsDayOfWeek=Wed
...    NRBTS:x2EnDcCfUpRspTmr=3
...    NRBTS:maxX2EnDcCfUpRetry=3
...    NRBTS:x2EnDcCfUpRdmDelayTmr=3
...    NRBTS:xnNgRanCfUpRdmDelayTmr=3
...    NRBTS:actLbpsCtrlLogicEnh=true
...    NRBTS/NRPGRP-10:lbpsLoadCalcMethod=Max(G, C, P)
...    NRBTS/NRPGRP-10:lbpsSOnTrRule=MinValueMethod
...    NRBTS/NRPGRP-10:lbpsSOffTrRule=MaxValueMethod

@{Xn_link}
...    NRBTS/XNLINK-1:cPlaneIpAddr=10.0.1.122
...    NRBTS/XNLINK-1:cPlaneIpAddrCtrl=oamControlled
...    NRBTS:actIncXn=true

${LOOP}    2


*** Test Cases ***
CB008224-ET-A003_Support_SDL_cell_in_FDD_band_N66_N71
    [Documentation]
    ...    1. This User Scenario validates that an SDL cell is up and running in the n66 FDD band
    ...       and that no UE can camp on this SDL cell as the cell is barred
    ...    2. Configuration
    ...         gNBs host following cells:
    ...                                 Cell-1    Cell-2    Cell-11    Cell-12    Cell-13    Cell-14
    ...    Technology                    TDD      TDD       FDD SDL     FDD SDL    FDD SDL     FDD
    ...          Band                    n41      n78       n66         n71         n66        n71
    ...           Pci                     50       51       60          61          62         63
    ...     Bandwidth                     60       50       25          20,15       40,25      15
    ...        Arfcn<DL/UL>         518580    633372    430900/348920     126900/136100     430900/348920     126900/136100
    ...        nrCellType               4DL4UL    4DL4UL    2DL0UL      2DL0UL      2DL0UL    2DL2UL
    ...    NRCELL:actSib1ForNsaCell=true
    ...    3. Test Case Steps:
    ...           a. All CELLs on air
    ...           b. trigger SDL NRCELL-11,12,13 locked and unlocked twice.
    ...    4. Expected Results:
    ...           a. All CELLs on air. bi-directional cells scheduling mib and sibs.SDL cells scheduling only mib.
    ...           b. same with step a.
    [Tags]    A003    QC_348956
    SDL CELL LOCK Unlock
  #  Drop Ng Link         after PR748896 resolved
  #  Check cells on Air
    Check Wireshark Log    ${CURDIR}/A2A_A003/a2a.ini    wait_string=UEContextReleaseComplete::0

*** Keywords ***
Check cells on Air
    Cells Should Be Onair    cell_id=1    check_sib=${True}    timeout=600
    Cells Should Be Onair    cell_id=2    check_sib=${True}    timeout=600
    Cells Should Be Onair    cell_id=11    check_sib=${False}    timeout=600
    Cells Should Be Onair    cell_id=12    check_sib=${False}    timeout=600
    Cells Should Be Onair    cell_id=13    check_sib=${False}    timeout=600
    Cells Should Be Onair    cell_id=14    check_sib=${True}    timeout=600

Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_2T4F
    Execute Cmd On PC    sudo ip addr add 10.0.1.102/24 dev eth3
    Execute Egate Command    trace_sim amf=1 on
    Execute Egate Command    sim_trace enb=3 protocol=xn on
    Execute Egate Command    sim_trace enb=1 protocol=x2 on

Drop Ng Link
    execute egate command    link_drop link=ng by=amf:1 to=gnb:2 msg_type=shutdown    NG Link Drop
    object should exist    MRBTS-1/NRBTS-1/SERVEDAMF-1:ngLinkStatus=Inactive

SDL CELL LOCK Unlock
    FOR    ${index}    IN RANGE    0    ${LOOP}
         Lock Cell11
         Lock Cell12
         Lock Cell13
         Unlock Cell11
         Unlock Cell12
         Unlock Cell13
    END

#NR-ARFCN values UL:DL
Modify Cfg
    ${Update_Cfg_Cell_11}    Catenate
    ...    set_cell id=11 gnb=2 pci=20:0 tac=200 nrci=0x0B tdd_cell=off proxy=$PROXY_SERVER_IP:9999|$PROXY_SERVER_IP:8888 nr_arfcn=348920:430900
    ...    gscn=5384 mandatory_for_activation=off is_fr1sdl_cell=on

    ${Update_Cfg_Cell_12}    Catenate
    ...    set_cell id=12 gnb=2 pci=20:1 tac=200 nrci=0x0C tdd_cell=off proxy=$PROXY_SERVER_IP:9999|$PROXY_SERVER_IP:8888 nr_arfcn=136100:126900
    ...    gscn=1584 mandatory_for_activation=off is_fr1sdl_cell=on

    ${Update_Cfg_Cell_13}    Catenate
    ...    set_cell id=13 gnb=2 pci=20:2 tac=200 nrci=0x0D tdd_cell=off proxy=$PROXY_SERVER_IP:9999|$PROXY_SERVER_IP:8888 nr_arfcn=348920:430900
    ...    gscn=5384 mandatory_for_activation=off is_fr1sdl_cell=on

    Update Cfg    ${Update_Cfg_Cell_11}
    Update Cfg    ${Update_Cfg_Cell_12}
    Update Cfg    ${Update_Cfg_Cell_13}


