*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    team-CN1ET    owner-yige.g.zhang
...    CLOUD_5G_I_BOO_AP_LOO    CRT    CB007219    release-SBTS24R3
Resource    ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{7219}
...    @{1416}
...    @{CA_enable}
...    @{MimoMode_Para}
...    @{Scell_Rel_AA13}
...    @{CB007552_CB008541}

@{CB007552_CB008541}
...    NRBTS:actMultipleDedicatedBWPs=true
...    NRCELL:actEnhMultipleDedicatedBWPs=true
...    NRBTS/BWP_PROFILE-7:bwpType=initial
...    NRBTS/BWP_PROFILE-7:locationAndBandwidthDl:cRbSizeDl=n51
...    NRBTS/BWP_PROFILE-7:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-7:locationAndBandwidthUl:cRbSizeUl=n51
...    NRBTS/BWP_PROFILE-7:locationAndBandwidthUl:cRbStartUl=crb0
...    NRBTS/BWP_PROFILE-7/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=9|searchSpaceId=1
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=1
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|searchSpaceId=1
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=1
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=4|searchSpaceId=1
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=2
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=9|searchSpaceId=3
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=3
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|searchSpaceId=3
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=3
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=4|searchSpaceId=3
...    NRBTS/BWP_PROFILE-8:bwpType=dedicated
...    NRBTS/BWP_PROFILE-8:locationAndBandwidthDl:cRbSizeDl=n106
...    NRBTS/BWP_PROFILE-8:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-8:locationAndBandwidthUl:cRbSizeUl=n106
...    NRBTS/BWP_PROFILE-8:locationAndBandwidthUl:cRbStartUl=crb0
...    NRBTS/BWP_PROFILE-8/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=9|searchSpaceId=4
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=4
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|searchSpaceId=4
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=4
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=4|searchSpaceId=4
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=5
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=9|searchSpaceId=6
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=6
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|searchSpaceId=6
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=6
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=4|searchSpaceId=6
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cceToRegMapping=nonInterleaved
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:coresetId=1
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cRbStart=0
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:duration=1
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:interleaverSize=none
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:regBundleSize=n6
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=96
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=0
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=0
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=0
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=0
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|coresetId=0
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=0
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=7|coresetId=0
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|coresetId=0
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=0
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|coresetId=1
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=1
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=1
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=1
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=1
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n4|coresetId=1
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=1
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=8|coresetId=1
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|coresetId=1
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=1
...    NRBTS/BWP_PROFILE-8/PDSCH-1:pdschRat0RbgConfig=config1
...    NRBTS/BWP_PROFILE-9:bwpType=dedicated
...    NRBTS/BWP_PROFILE-9:locationAndBandwidthDl:cRbSizeDl=n51
...    NRBTS/BWP_PROFILE-9:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-9:locationAndBandwidthUl:cRbSizeUl=n51
...    NRBTS/BWP_PROFILE-9:locationAndBandwidthUl:cRbStartUl=crb0
...    NRBTS/BWP_PROFILE-9/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=9|searchSpaceId=9
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=9
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|searchSpaceId=9
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=9
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=4|searchSpaceId=9
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=10
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=10
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=10
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=10
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=9|searchSpaceId=11
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=11
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|searchSpaceId=11
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=11
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=4|searchSpaceId=11
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cceToRegMapping=nonInterleaved
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:coresetId=4
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cRbStart=0
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:duration=1
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:interleaverSize=none
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:regBundleSize=n6
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=48
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=0
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=0
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=0
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=0
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|coresetId=0
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=0
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=12|coresetId=0
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|coresetId=0
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=0
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|coresetId=4
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=4
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=4
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=4
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=4
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|coresetId=4
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=4
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=13|coresetId=4
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|coresetId=4
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=4
...    NRBTS/BWP_PROFILE-9/PDSCH-1:pdschRat0RbgConfig=config1

@{7219}
...    NRBTS:actMfbiNrCaSupportFr1=true
...    NRBTS:actMfbiNrCaMeasConfResolv=false
@{1416}
...    NRBTS:actMultiFrequencyBandIndicatorNRSupport=true

...    NRCELL-1:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-4
...    NRCELL-1:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-4
...    NRCELL-2:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-2
...    NRCELL-2:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-2
...    NRCELL-3:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-3
...    NRCELL-3:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-3
...    NRCELL-4:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-3
...    NRCELL-4:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-3

...    NRCELL-13:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-1
...    NRCELL-13:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-1
...    NRCELL-14:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-1
...    NRCELL-14:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-1
...    NRBTS/NRCONNECTMODE_PROFILE-1:multiFreqBandIndicatorNR=2
...    NRBTS/NRCONNECTMODE_PROFILE-2:multiFreqBandIndicatorNR=77
...    NRBTS/NRCONNECTMODE_PROFILE-3:multiFreqBandIndicatorNR=41
...    NRBTS/NRCONNECTMODE_PROFILE-4:multiFreqBandIndicatorNR=78

...    NRBTS/NRMULTIBANDINFO_PROFILE-2:nrMultibandInfoList:nrBandPriority=0|freqBandIndicatorNR=78
...    NRBTS/NRMULTIBANDINFO_PROFILE-2:nrMultibandInfoList:nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1|freqBandIndicatorNR=78
...    NRBTS/NRMULTIBANDINFO_PROFILE-2:nrMultibandInfoList:nrBandPriority=1|freqBandIndicatorNR=77
...    NRBTS/NRMULTIBANDINFO_PROFILE-2:nrMultibandInfoList:nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-2|freqBandIndicatorNR=77

...    NRBTS/NRMULTIBANDINFO_PROFILE-3:nrMultibandInfoList:nrBandPriority=0|freqBandIndicatorNR=38
...    NRBTS/NRMULTIBANDINFO_PROFILE-3:nrMultibandInfoList:nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1|freqBandIndicatorNR=38
...    NRBTS/NRMULTIBANDINFO_PROFILE-3:nrMultibandInfoList:nrBandPriority=1|freqBandIndicatorNR=41
...    NRBTS/NRMULTIBANDINFO_PROFILE-3:nrMultibandInfoList:nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1|freqBandIndicatorNR=41


...    NRBTS/NRMULTIBANDINFO_PROFILE-4:nrMultibandInfoList:nrBandPriority=0|freqBandIndicatorNR=77
...    NRBTS/NRMULTIBANDINFO_PROFILE-4:nrMultibandInfoList:nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-2|freqBandIndicatorNR=77
...    NRBTS/NRMULTIBANDINFO_PROFILE-4:nrMultibandInfoList:nrBandPriority=1|freqBandIndicatorNR=78
...    NRBTS/NRMULTIBANDINFO_PROFILE-4:nrMultibandInfoList:nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1|freqBandIndicatorNR=78

...    NRBTS/NRMULTIBANDINFO_PROFILE-1:nrMultibandInfoList:nrBandPriority=0|freqBandIndicatorNR=25
...    NRBTS/NRMULTIBANDINFO_PROFILE-1:nrMultibandInfoList:nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-2|freqBandIndicatorNR=25
...    NRBTS/NRMULTIBANDINFO_PROFILE-1:nrMultibandInfoList:nrBandPriority=1|freqBandIndicatorNR=2
...    NRBTS/NRMULTIBANDINFO_PROFILE-1:nrMultibandInfoList:nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-3|freqBandIndicatorNR=2

...    NRBTS/NRNSPMAX_PROFILE-1:nrNsPmaxList:additionalSpectrumEmission=1
...    NRBTS/NRNSPMAX_PROFILE-1:nrNsPmaxList:nrNsPmaxPriority=1
...    NRBTS/NRNSPMAX_PROFILE-1:nrNsPmaxList:additionalPmax=1

...    NRBTS/NRNSPMAX_PROFILE-2:nrNsPmaxList:additionalSpectrumEmission=2
...    NRBTS/NRNSPMAX_PROFILE-2:nrNsPmaxList:nrNsPmaxPriority=1
...    NRBTS/NRNSPMAX_PROFILE-2:nrNsPmaxList:additionalPmax=2

...    NRBTS/NRNSPMAX_PROFILE-3:nrNsPmaxList:additionalSpectrumEmission=3
...    NRBTS/NRNSPMAX_PROFILE-3:nrNsPmaxList:nrNsPmaxPriority=1
...    NRBTS/NRNSPMAX_PROFILE-3:nrNsPmaxList:additionalPmax=3

...    NRCELL-1:freqBandIndicatorNR=77
...    NRCELL-1:nrarfcn=633000
...    NRCELL-1:gscnOrSsPbchArfcn=7836
...    NRCELL-13:freqBandIndicatorNR=25
...    NRCELL-14:freqBandIndicatorNR=25
...    NRBTS-1/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=48

...    NRCELL-2:nrarfcn=635594    #635660
...    NRCELL-2:gscnOrSsPbchArfcn=7864

...    NRCELL-1:cellBwpList:cellBwpId=0|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-7
...    NRCELL-1:cellBwpList:cellBwpId=1|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-8
...    NRCELL-1:cellBwpList:cellBwpId=2|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-9
...    NRCELL-2:cellBwpList:cellBwpId=0|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-7
...    NRCELL-2:cellBwpList:cellBwpId=1|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-8
...    NRCELL-2:cellBwpList:cellBwpId=2|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-9
...    NRCELL-1:chBw=40MHz
...    NRCELL-2:chBw=40MHz
...    NRCELL-1:msg1FrequencyStart=20
...    NRCELL-2:msg1FrequencyStart=20

@{CA_enable}
...    NRBTS-1:actCarrierAggregation=true
...    NRBTS-1:caConfigurationSupport=2CCDL_2CCUL
...    NRBTS-1:actMeasBasedSCellAdditionSa=A1-based
...    NRCELL:maxNumScellsDlFr1=4
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRCELL:actK1Opt=intra-gNB
...    NRDU-1:carrierAggregationSupportList=${CAlist}
${CAlist}    ca_Fdd_Fr1Tdd_Sa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Any_Sa,ca_Fdd_Any_Sa,ca_Fdd_Fdd,ca_Fdd_Fr1Tdd_Sa_WithUl

@{MimoMode_Para}
...    NRCELL:allowUnsuppBcOrBcs=complete BCS check
...    NRCELL-1:dlMimoMode=4x4 or 4x2 Closed Loop Spatial Multiplexing
...    NRCELL-1:nrCellType=4DL4UL
...    NRCELL-2:dlMimoMode=4x4 or 4x2 Closed Loop Spatial Multiplexing
...    NRCELL-2:nrCellType=4DL4UL
...    NRCELL-3:dlMimoMode=4x4 or 4x2 Closed Loop Spatial Multiplexing
...    NRCELL-3:nrCellType=4DL4UL
...    NRCELL-4:dlMimoMode=4x4 or 4x2 Closed Loop Spatial Multiplexing
...    NRCELL-4:nrCellType=4DL4UL
...    NRCELL-13:dlMimoMode=4x4 or 4x2 Closed Loop Spatial Multiplexing
...    NRCELL-13:nrCellType=4DL4UL
...    NRCELL-14:dlMimoMode=4x4 or 4x2 Closed Loop Spatial Multiplexing
...    NRCELL-14:nrCellType=4DL4UL

...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-7:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-7:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-8:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-8:direction=RX

...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-7:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-7:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-8:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-8:direction=RX

...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-7:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-7:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-8:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-8:direction=RX

...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-7:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-7:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-8:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-8:direction=RX

...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-13/CHANNELGROUP-1/CHANNEL-5:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-7/ANTL-3
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-13/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-13/CHANNELGROUP-1/CHANNEL-6:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-7/ANTL-3
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-13/CHANNELGROUP-1/CHANNEL-6:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-13/CHANNELGROUP-1/CHANNEL-7:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-7/ANTL-4
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-13/CHANNELGROUP-1/CHANNEL-7:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-13/CHANNELGROUP-1/CHANNEL-8:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-7/ANTL-4
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-13/CHANNELGROUP-1/CHANNEL-8:direction=RX
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-13/CHANNELGROUP-1/CHANNEL-5:resourceDN
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-13/CHANNELGROUP-1/CHANNEL-6:resourceDN
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-13/CHANNELGROUP-1/CHANNEL-7:resourceDN
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-13/CHANNELGROUP-1/CHANNEL-8:resourceDN
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-14/CHANNELGROUP-1/CHANNEL-5:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-8/ANTL-3
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-14/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-14/CHANNELGROUP-1/CHANNEL-6:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-8/ANTL-3
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-14/CHANNELGROUP-1/CHANNEL-6:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-14/CHANNELGROUP-1/CHANNEL-7:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-8/ANTL-4
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-14/CHANNELGROUP-1/CHANNEL-7:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-14/CHANNELGROUP-1/CHANNEL-8:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-8/ANTL-4
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-14/CHANNELGROUP-1/CHANNEL-8:direction=RX
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-14/CHANNELGROUP-1/CHANNEL-5:resourceDN
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-14/CHANNELGROUP-1/CHANNEL-6:resourceDN
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-14/CHANNELGROUP-1/CHANNEL-7:resourceDN
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-14/CHANNELGROUP-1/CHANNEL-8:resourceDN

@{Scell_Rel_AA13}
...    NRCELL-1:increasePUSCHPrepTimeULCA=true
...    NRCELL-13:timingAdvanceOffset=n25600
...    NRCELL-14:timingAdvanceOffset=n25600
...    MRBTS-1/NRBTS-1/NRDRB_RLC_AM-1:ulTReassemblyIBCA=40
...    MRBTS-1/NRBTS-1/NRDRB_RLC_AM-2:ulTReassemblyIBCA=40

...    NRCELL-13:a1MeasSCellAddEnabled=rsrp
...    NRCELL-13:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL-13:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=85
...    NRCELL-13:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=75
...    NRCELL-13:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=80ms
...    NRCELL-14:a2MeasSCellRelEnabled=rsrp
...    NRCELL-14:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=480ms
...    NRCELL-14:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=40|a2TimeToTriggerSCellRelSsbRsrp=480ms

...    NRCELL-1:a2MeasSCellRelEnabled=rsrp
...    NRCELL-1:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=480ms
...    NRCELL-1:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=40|a2TimeToTriggerSCellRelSsbRsrp=480ms

...    NRCELL-2:a2MeasSCellRelEnabled=rsrp
...    NRCELL-2:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=480ms
...    NRCELL-2:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=40|a2TimeToTriggerSCellRelSsbRsrp=480ms

...    NRCELL-13/NRREL-14:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-13/NRREL-14:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-13/NRREL-14:gNbId=1
...    NRCELL-13/NRREL-14:gNbIdLength=22
...    NRCELL-13/NRREL-14:handoverAllowedSA=allowed
...    NRCELL-13/NRREL-14:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-14:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-14:gnbPlmn:mncLength=3
...    NRCELL-13/NRREL-14:removeNotAllowed=false
...    NRCELL-13/NRREL-14:lcrId=14
...    NRCELL-13/NRREL-14:sCellAdditionMethod=covBasedA1
...    NRCELL-13/NRREL-14:sCellOperationalMode=dlOnly

...    NRCELL-13/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-13/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-13/NRREL-1:gNbId=1
...    NRCELL-13/NRREL-1:gNbIdLength=22
...    NRCELL-13/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-13/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-13/NRREL-1:removeNotAllowed=false
...    NRCELL-13/NRREL-1:lcrId=1
...    NRCELL-13/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-13/NRREL-1:sCellOperationalMode=dlAndUl

...    NRCELL-1:weightForSCellSelection=50
...    NRCELL-14:weightForSCellSelection=10      #need caculation
...    MRBTS-1/NRBTS-1/NRDU-1:dlToUlContributionRatio=50

@{AA13_online_1}
...    NRCELL-14:weightForSCellSelection=11     #need caculation

@{AA13_online_2}
...    NRCELL-13/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-13/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-13/NRREL-1:gNbId=1
...    NRCELL-13/NRREL-1:gNbIdLength=22
...    NRCELL-13/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-13/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-13/NRREL-1:removeNotAllowed=false
...    NRCELL-13/NRREL-1:lcrId=2
...    NRCELL-13/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-13/NRREL-1:sCellOperationalMode=dlAndUl
...    NRCELL-2:increasePUSCHPrepTimeULCA=true
...    NRCELL-1:increasePUSCHPrepTimeULCA=false
@{AA13_online_3}
...    NRCELL-14:weightForSCellSelection=10     #need caculation

@{AA13_online_4}
...    NRCELL-14:weightForSCellSelection=10     #need caculation

...    NRCELL-13/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-13/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-13/NRREL-1:gNbId=1
...    NRCELL-13/NRREL-1:gNbIdLength=22
...    NRCELL-13/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-13/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-13/NRREL-1:removeNotAllowed=false
...    NRCELL-13/NRREL-1:lcrId=1
...    NRCELL-13/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-13/NRREL-1:sCellOperationalMode=dlAndUl
...    NRCELL-1:increasePUSCHPrepTimeULCA=true
...    NRCELL-2:increasePUSCHPrepTimeULCA=false

@{AA27_online_2}
...    NRCELL-1:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-4
...    NRCELL-1:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-4
...    NRCELL-1:freqBandIndicatorNR=77

...    NRCELL-13/NRREL-14:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-13/NRREL-14:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-13/NRREL-14:gNbId=1
...    NRCELL-13/NRREL-14:gNbIdLength=22
...    NRCELL-13/NRREL-14:handoverAllowedSA=allowed
...    NRCELL-13/NRREL-14:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-14:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-14:gnbPlmn:mncLength=3
...    NRCELL-13/NRREL-14:removeNotAllowed=false
...    NRCELL-13/NRREL-14:lcrId=14
...    NRCELL-13/NRREL-14:sCellAdditionMethod=covBasedA1
...    NRCELL-13/NRREL-14:sCellOperationalMode=dlOnly

...    NRCELL-13/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-13/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-13/NRREL-1:gNbId=1
...    NRCELL-13/NRREL-1:gNbIdLength=22
...    NRCELL-13/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-13/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-13/NRREL-1:removeNotAllowed=false
...    NRCELL-13/NRREL-1:lcrId=1
...    NRCELL-13/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-13/NRREL-1:sCellOperationalMode=dlAndUl

...    NRCELL-1:weightForSCellSelection=50
...    NRCELL-14:weightForSCellSelection=10      #need caculation
...    MRBTS-1/NRBTS-1/NRDU-1:dlToUlContributionRatio=50
...    delete:NRCELL-13/NRREL-2
...    NRCELL-1:increasePUSCHPrepTimeULCA=true
@{AA27_online}
...    NRCELL-1:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-2
...    NRCELL-1:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-2
...    NRCELL-1:freqBandIndicatorNR=78

...    NRCELL-1:increasePUSCHPrepTimeULCA=false
...    NRCELL-13/NRREL-14:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-13/NRREL-14:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-13/NRREL-14:gNbId=1
...    NRCELL-13/NRREL-14:gNbIdLength=22
...    NRCELL-13/NRREL-14:handoverAllowedSA=allowed
...    NRCELL-13/NRREL-14:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-14:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-14:gnbPlmn:mncLength=3
...    NRCELL-13/NRREL-14:removeNotAllowed=false
...    NRCELL-13/NRREL-14:lcrId=14
...    NRCELL-13/NRREL-14:sCellAdditionMethod=blind
...    NRCELL-13/NRREL-14:sCellOperationalMode=dlOnly
...    NRCELL-14:weightForSCellSelection=50

...    NRCELL-13/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-13/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-13/NRREL-1:gNbId=1
...    NRCELL-13/NRREL-1:gNbIdLength=22
...    NRCELL-13/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-13/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-13/NRREL-1:removeNotAllowed=false
...    NRCELL-13/NRREL-1:lcrId=1
...    NRCELL-13/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-13/NRREL-1:sCellOperationalMode=dlOnly

...    NRCELL-13/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-13/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-13/NRREL-2:gNbId=1
...    NRCELL-13/NRREL-2:gNbIdLength=22
...    NRCELL-13/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-13/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-13/NRREL-2:removeNotAllowed=false
...    NRCELL-13/NRREL-2:lcrId=2
...    NRCELL-13/NRREL-2:sCellAdditionMethod=blind
...    NRCELL-13/NRREL-2:sCellOperationalMode=dlOnly

@{AA14_online_1}
...    NRBTS:actHighestEstNrTputBcSel=true      #CNI-81817
@{AA14_online_2}
...    NRBTS:actHighestEstNrTputBcSel=false      #CNI-81817

${n25A_n77A_and_n25(2A)_n77A_and_n25A_n78A}    SEPARATOR=
...     E9A09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C4701BB8D85181AC1184341020E9068036B64C558D0E7
...     C471E819F604F8C48E3C873EA39F30C7942C0E070F05C00FFC007003FF0005C0000E0541B107582308682041E20D00656C98AB121CFB027C471
...     E31238F21CFA8E7CC31E50B0381C3C27FFC00001FFF00000170000381546C4DD608C21A0810748340165B262A86873E238F40CFB027C639F30C
...     7942C0E070F02E007FE003801FF8002E0000702A0D831AC1184341020F941A00CAD931562439F11C7B027C62471E439F51CF9863CA160703878
...     4FFF800003FFE000002E0000702B8D84BAC1184341020E9068036B64C558D0E7C471E819F604F8C48E3C873EA39F30C7942C0E070F05C00FFC0
...     07003FF0005C0000E0551B133582308682041D20D00596C98AA1A1CF88E3D033EC09F18E7CC31E50B0381C3C0B801FF800E007FE000B80001C0
...     A836236B04610D04083E5068032B64C55890E7C471EC09F1891C790E7D473E618F28581C0E1E13FFE00000FFF800000B80001C00F787882001C
...     46000000160205E1E1280071340000085808178B850001C41000E230000020B0102F0F0A000389A0000102C040B83C28000E208000050B0102F
...     0F10400388C0000182C040BC3C41000E268000070B0102F170A0003882001C41000010160205E2E14000711800388C0000242C040BC5C41000E
...     2080071180000505808178B882001C46000E2300000B0B0102F0F11800389A0000302C040BC3C18000E2600000E0B0102F17060003830001C4C
...     00001E160205E1E0C000713400008058081007011A014404D80822E8016E0F851226C73E1C28913639F0E2448913639F0E14489B1CF870A244D
...     8E7C3851226C73E1C28913639F0E2448913639F0E2448913639F0E2448913639F0E2448913639F0E14489B1CF870A240D8E7C38912244D8E7C3
...     851206C73E182E1E318C6318C6318C6318C3D05C0078005038280381804A00E000C0480080C07C0700400000002000004010000040080000300
...     4000020020000140100000C0080000701D81959195931591B58335831581B595340904000025949410000196525040000A59494100003965250
...     4000125949410000596525040001A59494100007965250400022594901000099652402540EAA9555526AAA479541B2A8355503CAA559540E2A9
...     1C50B002400681400201010020040400801080804008020080108040100201002004040080118180100300E01C0C008018010020600400C0080
...     1030100220080104040180301004008202008010080100210100801004008010808010020200801080401002010020040400801100802004020
...     040080801002201002004040080101002004402004008080100202004008404008010100400860600400C038070300200600400818010030020
...     040C0400880200410300E00601C048180400100402840201C00808070000201000040C03801807012060100040100A1AA1F000102030406070A
...     0B0C0D101112131418191B1C1D1F2125262728292A2D2F414182D

${n25A_n78A_and_n25(2A)_n78A_and_n25A_n77A_n25A_n77(2A)}    SEPARATOR=
...    E9A09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C4701BB8D85181AC1184341020E9068036B64C558D0E7C
...    471E819F604F8C48E3C873EA39F30C7942C0E070F05C00FFC007003FF0005C0000E0541B107582308682041E20D00656C98AB121CFB027C471E3
...    1238F21CFA8E7CC31E50B0381C3C27FFC00001FFF00000170000381546C4DD608C21A0810748340165B262A86873E238F40CFB027C639F30C794
...    2C0E070F02E007FE003801FF8002E0000702A0D831AC1184341020F941A00CAD931562439F11C7B027C62471E439F51CF9863CA1607038784FFF
...    800003FFE000002E0000702B8D84BAC1184341020E9068036B64C558D0E7C471E819F604F8C48E3C873EA39F30C7942C0E070F05C00FFC007003
...    FF0005C0000E0551B133582308682041D20D00596C98AA1A1CF88E3D033EC09F18E7CC31E50B0381C3C0B801FF800E007FE000B80001C0A83623
...    6B04610D04083E5068032B64C55890E7C471EC09F1891C790E7D473E618F28581C0E1E13FFE00000FFF800000B80001C010787882001C4600000
...    0160205E1E1280071340000085808178B850001C41000E230000020B0102F0F0A000389A0000102C040B83C28000E208000050B0102F0F104003
...    88C0000182C040BC3C41000E268000070B0102F170A0003882001C41000010160205E2E14000711800388C0000242C040BC5C41000E208007118
...    0000505808178B882001C46000E2300000B0B0102F0F11800389A0000302C040BC3C18000E2680000E0B0102F17060003830001C4D00001E1602
...    05E1E0C00071300000805808178B830001C4C000E260000110B010200E0234028809B01045D00314210A244D8E7C3851226C73E1C4891226C73E
...    1C28913639F0E14489B1CF870A244D8E7C3851226C73E1C4891226C73E1C4891226C73E1C4891226C73E1C4891226C73E1C28913639F0E14481B
...    1CF871224489B1CF870A240D8E7C38902040D8E7C30064406318C6318C6318C6318C07A0B800F000A070500703009401C0018090010180F80E00
...    800000004000008020000080100000600800004004000028020000180100000E03B032B232B262B236B066B062B036B2A68120800004B2928200
...    0032CA4A0800014B29282000072CA4A0800024B292820000B2CA4A0800034B292820000F2CA4A0800044B29202000132CA4804A81D552AAAA4D5
...    548F2A8365506AAA07954AB2A81C55238A16004800D0280044202004008080100210100801004010021008020040200400808010023030020060
...    1C03818010030020040C008018010020602004401002080803006020080104040100201002004202010020080100210100200404010021008020
...    040200400808010022010040080400801010020044020040080801002020040088040080101002004040080108080100202008010C0C00801807
...    00E0600400C0080103002006004008180801100400820201C008080400020100E00404038000100800020201C008080400020100E00404018030
...    100600C6A87C0004080C10181C282C30344044484C5060646C70747C8494989CA0A4A8B4BD05060B40


@{scelladd_expect_AA13_1}
...    pcid:50, scellIdx:1] configure_1_1
...    pcid:50, scellIdx:1] configure_0_1
...    pcid:62, scellIdx:0] configure_1_1
...    pcid:62, scellIdx:0] configure_0_1
...    rrcReconfigurationComplete

@{scelladd_expect_AA13_2}
...    pcid:50, scellIdx:1] configure_1_1
...    pcid:62, scellIdx:0] configure_1_1
...    pcid:62, scellIdx:0] configure_0_1
...    pcid:63, scellIdx:2] configure_1_1
...    rrcReconfigurationComplete

@{scelladd_expect_AA13_3}
...    pcid:51, scellIdx:1] configure_1_1
...    pcid:62, scellIdx:0] configure_1_1
...    pcid:62, scellIdx:0] configure_0_1
...    pcid:63, scellIdx:2] configure_1_1
...    rrcReconfigurationComplete

@{scelladd_expect_AA13_4}
...    pcid:51, scellIdx:1] configure_1_1
...    pcid:51, scellIdx:1] configure_0_1
...    pcid:62, scellIdx:0] configure_1_1
...    pcid:62, scellIdx:0] configure_0_1
...    rrcReconfigurationComplete

@{scelladd_expect_AA14}
...    pcid:50, scellIdx:1] configure_1_1
...    pcid:62, scellIdx:0] configure_1_1
...    pcid:62, scellIdx:0] configure_0_1
...    rrcReconfigurationComplete

@{scelladd_expect_AA27}
...    pcid:50, scellIdx:1] configure_1_1
...    pcid:51, scellIdx:2] configure_1_1
...    pcid:62, scellIdx:0] configure_1_1
...    pcid:62, scellIdx:0] configure_0_1


${SCELL_CONF_ALT_BAND_SA}    M55118C01005    #This counter provides the number of current cell configurations as an SA SCell in an alternative band
${GNB_SA_ADMISSION_MFBI_REQ}    M55138C00501    #This counter provides the number of radio admission requests for the SA user, where admission is
#requested on the alternative band.The counter is updated to the PCell on CU.
${GNB_SA_ADMISSION_MFBI_SUCC}    M55138C00502    #This counter provides the number of admitted radio admission requests for the SA user,
#where admission is done on the alternative band.The counter is updated to the PCell on CU.
${GNB_SA_DU_ADMISSION_MFBI_REQ}    M55139C02001    #This counter provides the number of radio admission requests with MFBI for the SA user.
#The counter is updated to the PCell on DU.
${GNB_SA_DU_ADMISSION_MFBI_SUCC}    M55139C02002    #This counter provides the number of radio-admitted UEs for the SA user using the
#alternativeband .The counter is updated to the PCell on DU.
${UE_SCELL_1_CONF_SCELL_DL_SA}    M55118C05508    #This counter indicates the sum of samples for the total number of CA UEs in the current cell
#configured as an SCell with 1 configured SCell in DL in SA mode. The counter is pegged in the secondary cell.
${UE_SCELL_2_CONF_SCELL_DL_SA}    M55118C07002     #The sum of samples for total number of CA UEs in the current cell configured as an SCell
#while pegged in the secondary cell, which have three configured SCells in DL in SA mode.
${UE_SCELL_1_CONF_SCELL_UL_SA}    M55118C10006    #This counter shows the sum of samples for the total number of CA UEs in the current cell
#configured as UL SCell, while pegged in the secondary cell, which have 1 configured UL SCell in UL.
@{pm_couter_AA13_1}
...    NRCELL-13:${GNB_SA_ADMISSION_MFBI_REQ}=0
...    NRCELL-13:${GNB_SA_ADMISSION_MFBI_SUCC}=0
...    NRCELL-13:${GNB_SA_DU_ADMISSION_MFBI_REQ}=0
...    NRCELL-13:${GNB_SA_DU_ADMISSION_MFBI_SUCC}=0
...    NRCELL-1:${UE_SCELL_1_CONF_SCELL_DL_SA}>0
...    NRCELL-1:${UE_SCELL_2_CONF_SCELL_DL_SA}>0
...    NRCELL-14:${UE_SCELL_2_CONF_SCELL_DL_SA}>0
...    NRCELL-1:${SCELL_CONF_ALT_BAND_SA}=0
...    NRCELL-1:${UE_SCELL_1_CONF_SCELL_UL_SA}>0
...    NRCELL-2:${SCELL_CONF_ALT_BAND_SA}=0

@{pm_couter_AA13_2}
...    NRCELL-13:${GNB_SA_ADMISSION_MFBI_REQ}=0
...    NRCELL-13:${GNB_SA_ADMISSION_MFBI_SUCC}=0
...    NRCELL-13:${GNB_SA_DU_ADMISSION_MFBI_REQ}=0
...    NRCELL-13:${GNB_SA_DU_ADMISSION_MFBI_SUCC}=0
...    NRCELL-2:${UE_SCELL_1_CONF_SCELL_DL_SA}>0
...    NRCELL-2:${UE_SCELL_2_CONF_SCELL_DL_SA}>0
...    NRCELL-14:${UE_SCELL_2_CONF_SCELL_DL_SA}>0
...    NRCELL-1:${SCELL_CONF_ALT_BAND_SA}=0
...    NRCELL-2:${SCELL_CONF_ALT_BAND_SA}=1
...    NRCELL-2:${UE_SCELL_1_CONF_SCELL_UL_SA}>0

@{pm_couter_AA14_1}
...    NRCELL-13:${GNB_SA_ADMISSION_MFBI_REQ}=0
...    NRCELL-13:${GNB_SA_ADMISSION_MFBI_SUCC}=0
...    NRCELL-13:${GNB_SA_DU_ADMISSION_MFBI_REQ}=0
...    NRCELL-13:${GNB_SA_DU_ADMISSION_MFBI_SUCC}=0
...    NRCELL-1:${UE_SCELL_1_CONF_SCELL_DL_SA}>0
...    NRCELL-1:${UE_SCELL_2_CONF_SCELL_DL_SA}=0
...    NRCELL-1:${SCELL_CONF_ALT_BAND_SA}=0
...    NRCELL-1:${UE_SCELL_1_CONF_SCELL_UL_SA}=0

@{pm_couter_AA27_1}
...    NRCELL-13:${GNB_SA_ADMISSION_MFBI_REQ}=0
...    NRCELL-13:${GNB_SA_ADMISSION_MFBI_SUCC}=0
...    NRCELL-13:${GNB_SA_DU_ADMISSION_MFBI_REQ}=0
...    NRCELL-13:${GNB_SA_DU_ADMISSION_MFBI_SUCC}=0
...    NRCELL-1:${UE_SCELL_1_CONF_SCELL_DL_SA}=0
...    NRCELL-1:${UE_SCELL_2_CONF_SCELL_DL_SA}>0
...    NRCELL-1:${SCELL_CONF_ALT_BAND_SA}=1
...    NRCELL-1:${UE_SCELL_1_CONF_SCELL_UL_SA}=0
...    NRCELL-2:${UE_SCELL_1_CONF_SCELL_DL_SA}=0
...    NRCELL-2:${UE_SCELL_2_CONF_SCELL_DL_SA}>0
...    NRCELL-2:${SCELL_CONF_ALT_BAND_SA}=1
...    NRCELL-2:${UE_SCELL_1_CONF_SCELL_UL_SA}=0

*** Test Cases ***
CB007219_AA13_Verify_intra-gNB_basic_UL_CA_with_MFBI_enable
    [Documentation]
    ...    1. This user scenario describes the successful setup of DL&UL CA when some of the aggregated cells
    ...    are configured with an alternative band.
    ...    2. Configuration
    ...    CB007219:NRBTS/actMfbiNrCaSupportFr1 is set to "true"
    ...    5GC001416:NRBTS/actMultiFrequencyBandIndicatorNRSupport=true
    ...       NRCELL-1 TDD native:N77/alternative:N78 large:40Mhz small:20Mhz dlmimo: 4x4 or 4x2 Closed Loop Spatial Multiplexing
    ...       NRCELL-2 TDD native:N78/alternative:N77 large:40Mhz small:20Mhz dlmimo: 4x4 or 4x2 Closed Loop Spatial Multiplexing
    ...       NRCELL-13 FDD native:N25/alternative:N2 20Mhz dlmimo: 4x4 or 4x2 Closed Loop Spatial Multiplexing
    ...       NRCELL-14 FDD native:N25/alternative:N2 20Mhz dlmimo: 4x4 or 4x2 Closed Loop Spatial Multiplexing
    ...    UE capability:
    ...       BC#1: n25A-n77A      N25 N77
    ...       DL FSEI#1 DL MIMO layers 4L 4L
    ...       DL ChBw (MHz) 20 20
    ...       UL FSEI#1 UL MIMO layers 2L
    ...       UL ChBw (MHz) 20
    ...       DL FSEI#2 DL MIMO layers 4L 2L
    ...       DL ChBw (MHz) 20 20
    ...       UL FSEI#2 UL MIMO layers 1L 1L
    ...       UL ChBw (MHz) 20 20
    ...
    ...       BC#2:n25(2A)-n77A      N25 N25 N77
    ...       DL FSEI#1 DL MIMO layers 4L 4L 4L
    ...       DL ChBw (MHz) 20 20 20
    ...       UL FSEI#1 UL MIMO layers 2L
    ...       UL ChBw (MHz) 20
    ...
    ...       BC#3:n25A-n78A        N25 N78
    ...       DL FSEI#1 DL MIMO layers 4L 4L
    ...       DL ChBw (MHz) 20 20
    ...       UL FSEI#1 UL MIMO layers 2L
    ...       UL ChBw (MHz) 20
    ...       DL FSEI#2 DL MIMO layers 4L 2L
    ...       DL ChBw (MHz) 20 20
    ...       UL FSEI#2 UL MIMO layers 1L 1L
    ...       UL ChBw (MHz) 20 20
    ...    A1 for scell addition is configured in PCell and A2 for scell is configured in SCells.
    ...    3. Test Case Steps:
    ...       a. CA relation: Pcell: NRCELL-13 Scell: NRCELL-1(weightForSCellSelection=50, dlAndUl) & 14(weightForSCellSelection=10, dlOnly)
    ...          ue register to cell 13, Trigger A1 for scell addition. cell 1 add as dlAndUl scells. BC#1:FSEI#2
    ...       b. online change NRCELL-14(weightForSCellSelection=10, dlOnly) to NRCELL-14(weightForSCellSelection=11, dlOnly)
    ...          ue register to cell 13, Trigger A1 for scell addition. cell 1 (native band n77),cell 14 add as dlOnly scells. BC#2
    ...       c. online change CA relation: Pcell:NRCELL-13
    ...          Scell:NRCELL-2 (weightForSCellSelection=50,dlAndUl) & NRCELL-14(weightForSCellSelection=11,dlOnly)
    ...          ue register to cell 13, Trigger A1 for scell addition. cell 2(alternative band n77),cell 14 add as dlOnly scells. BC#2
    ...      d. online change NRCELL-14(weightForSCellSelection=11, dlOnly) to NRCELL-14(weightForSCellSelection=10, dlOnly)
    ...          ue register to cell 13, Trigger A1 for scell addition. cell 2 add as dlAndUl scells. BC#3:FSEI#2
    [Tags]    QC_320589    AA13    zhang.yige    CA_LABEL-FT(20MHZ_FDD_n25+20MHZ_TDD_n77)
    ...    CA_LABEL-FTT(20MHZ_FDD_n25+20MHZ_FDD_n25+20MHZ_TDD_n77)    CA_LABEL-FT(20MHZ_FDD_n25+20MHZ_TDD_n78)
    Clear Counter Files    wait=${False}
    Ue Register and Deregister    DL_CC=2    UL_CC=2    para_change=${AA13_online_4}    ue_id=1    cell_id=13
    ...    result_check=${scelladd_expect_AA13_1}
    Ue Register and Deregister    DL_CC=3    UL_CC=1    para_change=${AA13_online_1}    ue_id=1    cell_id=13
    ...    result_check=${scelladd_expect_AA13_2}
    check counters    pm_counters_expression=${pm_couter_AA13_1}
    Clear Counter Files
    Ue Register and Deregister    DL_CC=3    UL_CC=1    para_change=${AA13_online_2}    ue_id=1    cell_id=13
    ...    result_check=${scelladd_expect_AA13_3}
    Ue Register and Deregister    DL_CC=2    UL_CC=2    para_change=${AA13_online_3}    ue_id=1    cell_id=13
    ...    result_check=${scelladd_expect_AA13_4}
    check counters    pm_counters_expression=${pm_couter_AA13_2}
    Check Wireshark Log    ${CURDIR}${/}A2A_AA13${/}a2a.ini    wait_string=UEContextReleaseComplete::16
    [Teardown]    AA13_Teardown

CB007219_AA14_Verify_intra-gNB_UL_CA_with_MFBI_enable_IWK_CNI_81817
    [Documentation]
    ...    1. This user scenario describes the successful setup of DL&UL CA when some of the aggregated cells are configured
    ...       with an alternative band.
    ...    2. Configuration
    ...    CNI-81817:NRBTS/actHighestEstNrTputBcSel is set to "true"
    ...    CB007219:NRBTS/actMfbiNrCaSupportFr1 is set to "true"
    ...    5GC001416:NRBTS/actMultiFrequencyBandIndicatorNRSupport=true
    ...       NRCELL-1 TDD native:N77/alternative:N78 large:40Mhz small:20Mhz dlmimo: 4x4 or 4x2 Closed Loop Spatial Multiplexing
    ...       NRCELL-2 TDD native:N78/alternative:N77 large:40Mhz small:20Mhz dlmimo: 4x4 or 4x2 Closed Loop Spatial Multiplexing
    ...       NRCELL-13 FDD native:N25/alternative:N2 20Mhz dlmimo: 4x4 or 4x2 Closed Loop Spatial Multiplexing
    ...       NRCELL-14 FDD native:N25/alternative:N2 20Mhz dlmimo: 4x4 or 4x2 Closed Loop Spatial Multiplexing
    ...    UE capability:
    ...       BC#1: n25A-n77A      N25 N77
    ...       DL FSEI#1 DL MIMO layers 4L 4L
    ...       DL ChBw (MHz) 20 20
    ...       UL FSEI#1 UL MIMO layers 2L
    ...       UL ChBw (MHz) 20
    ...       DL FSEI#2 DL MIMO layers 4L 2L
    ...       DL ChBw (MHz) 20 20
    ...       UL FSEI#2 UL MIMO layers 1L 1L
    ...       UL ChBw (MHz) 20 20
    ...
    ...       BC#2:n25(2A)-n77A      N25 N25 N77
    ...       DL FSEI#1 DL MIMO layers 4L 4L 4L
    ...       DL ChBw (MHz) 20 20 20
    ...       UL FSEI#1 UL MIMO layers 2L
    ...       UL ChBw (MHz) 20
    ...
    ...       BC#3:n25A-n78A        N25 N78
    ...       DL FSEI#1 DL MIMO layers 4L 4L
    ...       DL ChBw (MHz) 20 20
    ...       UL FSEI#1 UL MIMO layers 2L
    ...       UL ChBw (MHz) 20
    ...       DL FSEI#2 DL MIMO layers 4L 2L
    ...       DL ChBw (MHz) 20 20
    ...       UL FSEI#2 UL MIMO layers 1L 1L
    ...       UL ChBw (MHz) 20 20
    ...    Blind scell addition.
    ...    3. Test Case Steps:
    ...       a. CA relation: Pcell: NRCELL-13 Scell: NRCELL-1(weightForSCellSelection=50, dlAndUl) & 14(weightForSCellSelection=10, dlOnly)
    ...          ue register to cell 13 n25, blind scell addition. BC#1 with FSEI#1 and FSEI#2; BC#2 with FSEI#1 sent from CU to DU
    ...          BC#1:FSEI#1 selected in DU side. cell 1 add as dlonly scell.
    [Tags]    QC_320567    AA14    zhang.yige    CA_LABEL-FT(20MHZ_FDD_n25+20MHZ_TDD_n77)
    Clear Counter Files
    Ue Register and Deregister    DL_CC=2    UL_CC=1    para_change=${AA14_online_1}    ue_id=1    cell_id=13
    ...    result_check=${scelladd_expect_AA14}
    check counters    pm_counters_expression=${pm_couter_AA14_1}
    Check Wireshark Log    ${CURDIR}${/}A2A_AA14${/}a2a.ini    wait_string=UEContextReleaseComplete::4
    [Teardown]    AA14_Teardown

CB007219_AA27_Verify_successful_CA_setup_with_alternative_bands_when_one_of_the_SCells_is_configured_with_small_dedicated_BWP
    [Documentation]
    ...    1. This user scenario describes the successful setup of DL&UL CA when some of the aggregated cells are configured
    ...       with an alternative band.
    ...    2. Configuration
    ...    CB007219:NRBTS/actMfbiNrCaSupportFr1 is set to "true"
    ...    5GC001416:NRBTS/actMultiFrequencyBandIndicatorNRSupport=true
    ...    CB008541_CB007552:actEnhMultipleDedicatedBWPs =true and actMultipleDedicatedBWPs=true
    ...       NRCELL-1 TDD native:N77/alternative:N78 large:40Mhz small:20Mhz dlmimo: 4x4 or 4x2 Closed Loop Spatial Multiplexing
    ...       NRCELL-2 TDD native:N78/alternative:N77 large:40Mhz small:20Mhz dlmimo: 4x4 or 4x2 Closed Loop Spatial Multiplexing
    ...       NRCELL-13 FDD native:N25/alternative:N2 20Mhz dlmimo: 4x4 or 4x2 Closed Loop Spatial Multiplexing
    ...       NRCELL-14 FDD native:N25/alternative:N2 20Mhz dlmimo: 4x4 or 4x2 Closed Loop Spatial Multiplexing
    ...    UE capability:
    ...       BC#1: n25A-n78A N25 N78
    ...       FSEI#1 DL MIMO layers 4L 4L
    ...       DL ChBw (MHz) 20 20
    ...       BC#2:n25(2A-)n78A N25 N25 N78
    ...       FSEI#1 DL MIMO layers 4L 4L 4L
    ...       DL ChBw (MHz) 20 20 20
    ...       BC#3:n25A-n77A N25 N77
    ...       FSEI#1 DL MIMO layers 4L 4L
    ...       DL ChBw (MHz) 20 20
    ...       BC#4:n25A-n77(2A) N25 N77 N77
    ...       FSEI#1 DL MIMO layers 4L 4L 4L
    ...       DL ChBw (MHz) 20 40/20 40/20
    ...    3. Test Case Steps:
    ...       a. CA relation: Pcell: NRCELL-13
    ...          Scell: NRCELL-1 ,NRCELL-2(two 40Mhz contiguous CC,Frequency of NRCELL-1 < Frequency of NRCELL-2),NRCELL-14
    ...          ue register to cell 13 n25, Trigger A1 for scell addition.
    ...          NRCELL-1 & 2 added as scells. BC#4:FSEI#1 selected.
    ...          NRCELL-1 configured with large BWP,NRCELL-2 configured with small BWP
    [Tags]    QC_320582    AA27    zhang.yige    CA_LABEL-FTT(20MHZ_FDD_n25+40MHZ_TDD_n77+20MHZ_TDD_n77)
    Update UE capa    ${n25A_n78A_and_n25(2A)_n78A_and_n25A_n77A_n25A_n77(2A)}    ue_id=2
    Clear Counter Files
    Ue Register and Deregister Blind Addition    DL_CC=3    UL_CC=1    para_change=${AA27_online}    ue_id=2    cell_id=13
    ...    result_check=${scelladd_expect_AA27}
    check counters    pm_counters_expression=${pm_couter_AA27_1}
    Check Wireshark Log    ${CURDIR}${/}A2A_AA27${/}a2a.ini    wait_string=UEContextReleaseComplete::4
    [Teardown]    AA27_Teardown

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/8cells_4T4F_2N2_N66_N71_2N78_2N38    ue_count=15
    Update UE capa    ${n25A_n77A_and_n25(2A)_n77A_and_n25A_n78A}    ue_id=1

AA13_Teardown
    OnlineParamChange    ${AA13_online_4}
    Common Test Teardown And Stop Capture Logs

AA14_Teardown
    OnlineParamChange    ${AA14_online_2}
    Common Test Teardown And Stop Capture Logs

AA27_Teardown
    OnlineParamChange    ${AA27_online_2}
    Common Test Teardown And Stop Capture Logs

Ue Register and Deregister
    [Arguments]    ${DL_CC}    ${UL_CC}    ${para_change}=${AA13_online_4}    ${ue_id}=1    ${cell_id}=13
    ...    ${result_check}=${scelladd_expect_AA13_1}
    OnlineParamChange    ${para_change}
    Ue register and pdu session setup    ue_id=${ue_id}    cell_id=${cell_id}
    Trigger ScellAdd    ue_id=${ue_id}    scelladd_expect=${result_check}
    Send Throughput    ue_id=${ue_id}
    Wait Until Keyword Succeeds    30s    10s    Check Traffic DL    ue_id=${ue_id}    cell_num=${DL_CC}
    Wait Until Keyword Succeeds    30s    10s    Check Traffic UL    ue_id=${ue_id}    cell_num=${UL_CC}
    UE Deregister From gNB    ue_id=${ue_id}

Ue Register and Deregister Blind Addition
    [Arguments]    ${DL_CC}    ${UL_CC}    ${para_change}=${AA13_online_4}    ${ue_id}=1    ${cell_id}=13
    ...    ${result_check}=${scelladd_expect_AA13_1}
    OnlineParamChange    ${para_change}
    Ue register and pdu session setup    ue_id=${ue_id}    cell_id=${cell_id}    result_check=${result_check}
    Send Throughput    ue_id=${ue_id}
    Wait Until Keyword Succeeds    30s    10s    Check Traffic DL    ue_id=${ue_id}    cell_num=${DL_CC}
    Wait Until Keyword Succeeds    30s    10s    Check Traffic UL    ue_id=${ue_id}    cell_num=${UL_CC}
    UE Deregister From gNB    ue_id=${ue_id}

Check Traffic DL
    [Arguments]     ${ue_id}=81    ${cell_num}=4    ${min_dl_tput}=200
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pdsch    Throughput
    ${total_dl_tput}    Set Variable    0
    FOR    ${index}    IN RANGE    0    ${cell_num}
         ${str_index}    Convert To String    ${index}
         ${scell_tput}    Ap Get Throuput On Specific Scell    ${ue_id}    ${str_index}    pdsch
         Should Be True    ${scell_tput}/1000 > 0
         ${total_dl_tput}    Evaluate    ${scell_tput}+${total_dl_tput}
    END
    Should Be True    ${total_dl_tput}/1000 > ${min_dl_tput}

Check Traffic UL
    [Arguments]     ${ue_id}=81    ${cell_num}=4    ${min_ul_tput}=60
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pusch    Throughput
    ${total_ul_tput}    Set Variable    0
    FOR    ${index}    IN RANGE    0    ${cell_num}
         ${str_index}    Convert To String    ${index}
         ${scell_tput}    Ap Get Throuput On Specific Scell    ${ue_id}    ${str_index}    pusch
         Should Be True    ${scell_tput}/1000 > 0
         ${total_ul_tput}    Evaluate    ${scell_tput}+${total_ul_tput}
    END
    Should Be True    ${total_ul_tput}/1000 > ${min_ul_tput}


Send Throughput
    [Arguments]    ${ue_id}=81    ${times}=5    ${mbps}=150
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=ul mbps=80 trf_id=1    UE ${ue_id}: UDP UL
    FOR    ${I}    IN RANGE    1    ${times}
        Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=${mbps} trf_id=${I}    UE ${ue_id}: UDP DL
    END

Ue register and pdu session setup
    [Arguments]    ${ue_id}=1    ${cell_id}=2     ${result_check}=QoS Routing Table
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=UE now in NG RM Registere
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=1    pass_regexp=${result_check}

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir

Trigger ScellAdd
    [Arguments]    ${event_type}=A1    ${carrierfreq}=388830    ${srsrp_nr}=90    ${srsrq_nr}=90    ${ue_id}=1
    ...    ${scelladd_expect}=${scelladd_expect_AA13_1}
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr    id=${ue_id}    meas_id=${meas_id}    event=${event_type}
    ...    srsrp_nr=${srsrp_nr}    srsrq_nr=${srsrq_nr}
    Execute Egate Command    ${cmd}    pass_regexp=${scelladd_expect}

Update UE capa
    [Arguments]    ${SA_Capa_perUE_Full}=none    ${ue_id}=81
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full}
    Execute Egate Command    ${cmd}

UE Deregister From gNB
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s
