*** Settings ***
Documentation
...    author:  susana.yan@nokia-sbell.com
...    contact: susana.yan@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_VRF    SBTS00    RAN_5G    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    team-PZ3_7
...     owner-susana.yan    release-SBTS24R3     CNI108979
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${SYSCOM_FLAG}    ${True}
@{PARAMS_IN_SCF}    @{CB008236}    @{CB006112}    @{5GC000545}    @{PARAMS_FOR_5QI9}    @{PARAMS_FOR_5QI5}
...    @{PARAMS_FOR_5QI1}    @{PARAMS_FOR_SECURITY}    @{PARAMS_FOR_HO}    @{CNI108979}    @{relation}

@{CNI108979}
...    NRCELL-1:actUlTransPreEnhHo=false
...    NRCELL-3:actUlTransPreEnhHo=false
...    NRCELL-1:ulPtrs:actUlPtrs=false
...    NRCELL-3:ulPtrs:actUlPtrs=false
...    NRCELL:actDl256Qam=true
...    NRCELL:actUl256Qam=true

@{relation}
...    NRBTS/NRDRB-15:queuingDelayDiscarding=Disabled
...    NRCELL:ulDMRSAdditionalPosition=No additional DMRS
...    NRCELL:pdcchAutoConfig:cellCoverageLevel=normal
...    NRCELL:pdcchAutoConfig:initialBWPMode=sameAsCoreset0
...    NRCELL:pdcchAutoConfig:fineTuneMode=disabled
...    delete:MRBTS-2/NRBTS-2/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated
...    NRBTS/BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=1
...    NRBTS/BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=1
...    NRBTS/BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=1
...    NRBTS/BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=1
...    NRBTS/BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=2
...    NRBTS/BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=3
...    NRBTS/BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=3
...    NRBTS/BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=3
...    NRBTS/BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=3
...    NRBTS/BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=4
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=4
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=4
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=4
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=5
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=6
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=6
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=6
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=6
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-0-And-1-0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|searchSpaceId=7
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=7
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|searchSpaceId=7
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|searchSpaceId=7
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|searchSpaceId=7
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=0|searchSpaceId=8
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|searchSpaceId=8
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|searchSpaceId=8
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=8
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|searchSpaceId=8
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceId=8
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|searchSpaceId=8
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n4|searchSpaceId=8
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceId=8
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|searchSpaceId=8
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|searchSpaceId=8
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|searchSpaceId=8
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=3|searchSpaceId=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceId=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=2
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=3|searchSpaceId=3
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=3
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceId=3
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=3
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=3|searchSpaceId=4
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=4
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceId=4
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=4
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=5
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=3|searchSpaceId=6
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=6
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceId=6
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=6
...    NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=6


@{CB008236}
...    NRCELL-1:actUlSlotAgg=Enabled_VoNr
...    NRCELL-1:actDrxSleepOff=Enabled_VoNr_SAg
...    NRCELL-1:sCellDeactInPoorRf=Deact_Scells_VoNr_SAg
...    NRCELL-1:ulTransPrecodeCtl:ulSlotAggOffTotPwrThresh=33
...    NRCELL-1:ulTransPrecodeCtl:ulSlotAggOnTotPwrThresh=30
...    NRCELL-1:maxHarqBundlesUlSlotAgg=10
...    NRCELL-1:minTbsUlSlotAgg=384
...    NRCELL-3:actUlSlotAgg=Disabled
...    NRCELL-3:actDrxSleepOff=Enabled_VoNr_SAg
...    NRCELL-3:sCellDeactInPoorRf=Deact_Scells_VoNr_SAg
...    NRCELL-3:ulTransPrecodeCtl:ulSlotAggOffTotPwrThresh=33
...    NRCELL-3:ulTransPrecodeCtl:ulSlotAggOnTotPwrThresh=30
...    NRCELL-3:maxHarqBundlesUlSlotAgg=10
...    NRCELL-3:minTbsUlSlotAgg=384

@{CB006112}
...    NRCELL-1:actEnhancedVoNR=true
...    NRCELL-1:actAdaptVoipTbs=true
...    NRCELL-1:actCDrxVoNR=true
...    NRCELL-1:actCDrx=true
...    NRCELL-1:actVoNR=true
...    NRCELL-1:srPeriodicityMin=slots20
...    NRCELL-1:srPeriodicity=slots40
...    NRCELL-1:periodicCsiAcquisition:csiReportPeriodicity=slots80
...    NRCELL-1:actVoipPacketAggr=true
...    NRCELL-3:actEnhancedVoNR=true
...    NRCELL-3:actAdaptVoipTbs=true
...    NRCELL-3:actCDrxVoNR=true
...    NRCELL-3:actCDrx=true
...    NRCELL-3:actVoNR=true
...    NRCELL-3:srPeriodicityMin=slots20
...    NRCELL-3:srPeriodicity=slots40
...    NRCELL-3:periodicCsiAcquisition:csiReportPeriodicity=slots80
...    NRCELL-3:actVoipPacketAggr=true

@{5GC000545}
...    NRCELL-1:actUlDftSOfdm=true
...    NRBTS:actTdraFallback=false
...    NRCELL-1:pucchModeSelect=longPucch
...    NRCELL-1:puschMappingType=TypeB
...    NRCELL-1:ulTransPrecodeCtl:ulTransPrecodeOffSinrThresh=200
...    NRCELL-1:ulTransPrecodeCtl:ulTransPrecodeOnSinrThresh=180
...    NRCELL-3:actUlDftSOfdm=true
...    NRCELL-3:pucchModeSelect=longPucch
...    NRCELL-3:puschMappingType=TypeB
...    NRCELL-3:ulTransPrecodeCtl:ulTransPrecodeOffSinrThresh=200
...    NRCELL-3:ulTransPrecodeCtl:ulTransPrecodeOnSinrThresh=180

@{PARAMS_FOR_5QI9}
...    NRBTS/NRDRB_5QI-2:fiveqiValueList=6
...    NRBTS/NRDRB_5QI-2:nrDrbDN=MRBTS-2/NRBTS-2/NRDRB-14
...    NRBTS/NRDRB-14:nrDrbMacDN=MRBTS-2/NRBTS-2/NRDRB_MAC-2
...    NRBTS/NRDRB-14:nrDrbPdcpDN=MRBTS-2/NRBTS-2/NRDRB_PDCP-2
...    NRBTS/NRDRB-14:nrDrbRlcAmDN=MRBTS-2/NRBTS-2/NRDRB_RLC_AM-2
...    NRBTS/NRDRB-14:resType=nonGBR
...    NRBTS/NRDRB-14:rlcMode=RLC_AM
...    NRBTS/NRDRB_MAC-2:lcgid=1
...    NRBTS/NRDRB_PDCP-2:cuFlowControlProfId=1
...    NRBTS/NRDRB_RLC_AM-2:duFlowControlProfId=1

@{PARAMS_FOR_5QI5}
...    NRBTS/NRDRB_5QI-1:fiveqiValueList=5
...    NRBTS/NRDRB_5QI-1:nrDrbDN=MRBTS-2/NRBTS-2/NRDRB-10
...    NRBTS/NRDRB-10:nrDrbMacDN=MRBTS-2/NRBTS-2/NRDRB_MAC-3
...    NRBTS/NRDRB-10:nrDrbPdcpDN=MRBTS-2/NRBTS-2/NRDRB_PDCP-2
...    NRBTS/NRDRB-10:nrDrbRlcAmDN=MRBTS-2/NRBTS-2/NRDRB_RLC_AM-2
...    NRBTS/NRDRB-10:resType=nonGBR_Signaling
...    NRBTS/NRDRB-10:rlcMode=RLC_AM
...    NRBTS/NRDRB_MAC-3:lcgid=0
...    NRBTS/NRDRB_MAC-3:schedulPrio=4

@{PARAMS_FOR_5QI1}
...    NRCELL-1:actVoNR=true
...    NRCELL-2:actVoNR=true
...    NRBTS:actNormVCFallback=false
...    NRBTS/NRDRB_5QI-6:fiveqiValueList=1
...    NRBTS/NRDRB_5QI-6:nrDrbDN=MRBTS-2/NRBTS-2/NRDRB-15
...    NRBTS/NRDRB-15:nrDrbMacDN=MRBTS-2/NRBTS-2/NRDRB_MAC-4
...    NRBTS/NRDRB-15:nrDrbPdcpDN=MRBTS-2/NRBTS-2/NRDRB_PDCP-3
...    NRBTS/NRDRB-15:nrDrbRlcUmDN=MRBTS-2/NRBTS-2/NRDRB_RLC_UM-1
...    NRBTS/NRDRB-15:nrDrbRlcAmDN=${EMPTY}
...    NRBTS/NRDRB-15:dlFlowControlAlgo=none
...    NRBTS/NRDRB-15:dscp=46
...    NRBTS/NRDRB-15:maxDddsPeriodCpuOvld=40
...    NRBTS/NRDRB-15:numSduDiscard=1
...    NRBTS/NRDRB-15:queuingDelaySduDiscardThreshold=200
...    NRBTS/NRDRB-15:resType=GBR
...    NRBTS/NRDRB-15:rlcMode=RLC_UM
...    NRBTS/NRDRB-15:schedulWeight=1
...    NRBTS/NRDRB-15:sduDiscardIntervalTmr=100
...    NRBTS/NRDRB-15:maxDataRateGbrDl=1000
...    NRBTS/NRDRB-15:maxDataRateGbrUl=1000
...    NRBTS/NRDRB-15:cellAggrLevel=Not FR1 CA eligible
...    NRBTS/NRDRB_MAC-4:lcgid=4
...    NRBTS/NRDRB_MAC-4:schedulPrio=5
...    NRBTS/NRDRB_RLC_UM-1:dlTReassemblyUm=ms40
...    NRBTS/NRDRB_RLC_UM-1:ulTReassemblyUm=ms40
...    NRBTS/NRDRB_RLC_UM-1:rlcUMDrbSNLength=rlcUm12bitSN
...    NRBTS/NRDRB_PDCP-3:tReorderingDl=ms300
...    NRBTS/NRDRB_PDCP-3:tReorderingUl=ms300
...    NRBTS/NRDRB_PDCP-3:pdcpBufDiscardEnabled=false
...    NRBTS/NRDRB-15:discardTimer=10ms
...    NRBTS/NRDRB-15:maxRlcQueueingDelayGbr=20
...    NRBTS/NRDRB-15:maxTransferDelayGbr=20

@{PARAMS_FOR_SECURITY}
...    NRBTS:cipherPrefL:nea0=9
...    NRBTS:cipherPrefL:nea1_128=0
...    NRBTS:cipherPrefL:nea2_128=0
...    NRBTS:cipherPrefL:nea3_128=0
...    NRBTS:integrityProtPrefL:nia0=0
...    NRBTS:integrityProtPrefL:nia1_128=0
...    NRBTS:integrityProtPrefL:nia2_128=9
...    NRBTS:integrityProtPrefL:nia3_128=0

@{PARAMS_FOR_HO}
...    NRBTS:actInterFreqHoSA=true
...    NRBTS:actIntraFreqHoSA=true
...    NRBTS/NRPMRNL-1:miNrRelReportCu=5min
...    NRDU-1:carrierAggregationSupportList=ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Any_Sa,ca_Fdd_Any_Sa,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Fdd
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRCELL-1:a1MeashoSsbRsrp:a1ThresholdhoSsbRsrp=34
...    NRCELL-1:a1MeashoSsbRsrp:a1TimeToTriggerhoSsbRsrp=ms480
...    NRCELL-1:a1MeashoSsbRsrp:a1HysteresishoSsbRsrp=0
...    NRCELL-1:a2MeasRedirectSsbRsrp:a2HysteresisRedirectSsbRsrp=0
...    NRCELL-1:a2MeasRedirectSsbRsrp:a2TimeToTriggerRedirectSsbRsrp=ms480
...    NRCELL-1:a2MeasRedirectSsbRsrp:a2ThresholdRedirectSsbRsrp=33
...    NRCELL-1:a2MeashoSsbRsrp:a2HysteresishoSsbRsrp=1
...    NRCELL-1:a2MeashoSsbRsrp:a2ThresholdhoSsbRsrp=34
...    NRCELL-1:a2MeashoSsbRsrp:a2TimeToTriggerhoSsbRsrp=ms480
...    NRCELL-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRCELL-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=15
...    NRCELL-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms40
...    NRCELL-1:a3MeasSsbRsrq:a3HysteresisSsbRsrq=0
...    NRCELL-1:a3MeasSsbRsrq:a3OffsetSsbRsrq=5
...    NRCELL-1:a3MeasSsbRsrq:a3TimeToTriggerSsbRsrq=ms0
...    NRCELL-1:a2MeashoEnabled=rsrp
...    NRCELL-1:a1MeashoEnabled=rsrp
...    NRCELL-1:a3MeasEnabled=rsrp
...    NRCELL-1:a1MeashoEnabledSA=rsrp
...    NRCELL-1:a1MeashoSsbRsrpSA:a1HysteresisHoSsbRsrpVoNr=0
...    NRCELL-1:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRCELL-1:a1MeashoSsbRsrpSA:a1ThresholdHoSsbRsrpVoNr=60
...    NRCELL-1:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=60
...    NRCELL-1:a1MeashoSsbRsrpSA:a1TimeToTriggerHoSsbRsrpVoNr=ms480
...    NRCELL-1:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL-1:a2MeashoEnabledSA=rsrp
...    NRCELL-1:a2MeashoSsbRsrpSA:a2HysteresisHoSsbRsrpVoNr=0
...    NRCELL-1:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0
...    NRCELL-1:a2MeashoSsbRsrpSA:a2ThresholdHoSsbRsrpVoNr=34
...    NRCELL-1:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=34
...    NRCELL-1:a2MeashoSsbRsrpSA:a2TimeToTriggerHoSsbRsrpVoNr=ms480
...    NRCELL-1:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL-1:absThreshSsbRsrpConsolidation=1
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-1:gNbId=2
...    NRCELL-1/NRREL-1:lcrId=3
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-3/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-3/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-3/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-3/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-3/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-3/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-3/NRREL-1:gNbId=2
...    NRCELL-3/NRREL-1:lcrId=1
...    NRCELL-3/NRREL-1:gNbIdLength=22
...    NRCELL-3:a1MeashoSsbRsrp:a1ThresholdhoSsbRsrp=34
...    NRCELL-3:a1MeashoSsbRsrp:a1TimeToTriggerhoSsbRsrp=ms480
...    NRCELL-3:a1MeashoSsbRsrp:a1HysteresishoSsbRsrp=0
...    NRCELL-3:a2MeasRedirectSsbRsrp:a2HysteresisRedirectSsbRsrp=0
...    NRCELL-3:a2MeasRedirectSsbRsrp:a2TimeToTriggerRedirectSsbRsrp=ms480
...    NRCELL-3:a2MeasRedirectSsbRsrp:a2ThresholdRedirectSsbRsrp=33
...    NRCELL-3:a2MeashoSsbRsrp:a2HysteresishoSsbRsrp=1
...    NRCELL-3:a2MeashoSsbRsrp:a2ThresholdhoSsbRsrp=34
...    NRCELL-3:a2MeashoSsbRsrp:a2TimeToTriggerhoSsbRsrp=ms480
...    NRCELL-3:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRCELL-3:a3MeasSsbRsrp:a3OffsetSsbRsrp=15
...    NRCELL-3:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms40
...    NRCELL-3:a3MeasSsbRsrq:a3HysteresisSsbRsrq=0
...    NRCELL-3:a3MeasSsbRsrq:a3OffsetSsbRsrq=5
...    NRCELL-3:a3MeasSsbRsrq:a3TimeToTriggerSsbRsrq=ms0
...    NRCELL-3:a2MeashoEnabled=rsrp
...    NRCELL-3:a1MeashoEnabled=rsrp
...    NRCELL-3:a3MeasEnabled=rsrp
...    NRCELL-3:a1MeashoEnabledSA=rsrp
...    NRCELL-3:a1MeashoSsbRsrpSA:a1HysteresisHoSsbRsrpVoNr=0
...    NRCELL-3:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRCELL-3:a1MeashoSsbRsrpSA:a1ThresholdHoSsbRsrpVoNr=60
...    NRCELL-3:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=60
...    NRCELL-3:a1MeashoSsbRsrpSA:a1TimeToTriggerHoSsbRsrpVoNr=ms480
...    NRCELL-3:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL-3:a2MeashoEnabledSA=rsrp
...    NRCELL-3:a2MeashoSsbRsrpSA:a2HysteresisHoSsbRsrpVoNr=0
...    NRCELL-3:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0
...    NRCELL-3:a2MeashoSsbRsrpSA:a2ThresholdHoSsbRsrpVoNr=34
...    NRCELL-3:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=34
...    NRCELL-3:a2MeashoSsbRsrpSA:a2TimeToTriggerHoSsbRsrpVoNr=ms480
...    NRCELL-3:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL-3:absThreshSsbRsrpConsolidation=1
...    NRCELL-1:maxNumPdschAllocationPerSlot=4
...    NRCELL-1:maxNumPuschAllocationPerSlot=4
...    NRCELL-3:maxNumPdschAllocationPerSlot=4
...    NRCELL-3:maxNumPuschAllocationPerSlot=4

###enabled ue support dynamic betaoffsets and non-SharedSpectrumChAccess-r16###
${SA_Capa_Support_SAG}    SEPARATOR=
...    E9A09000575F5A13560003C4A8002C00A0000040301262E003387A16009B20C39F30C7942C0E0980C0311C03EE3614606B04610D04083A41E006D6C98AB1A1CF88E3D033EC09F
...    1891C790E7D473E618F28581C0E1E0B801FF800E000BE000C80000E0541B107582308682041E20F0032B64C55890E7D813E238F1891C790E7D473E618F28581C0E1E13FB00000
...    0FEC000000C80000E0551B137582308682041D20F0030B64C55110E7C471E238F40CFB027C639F30C7942C0E070F05C00FFC007003FF000640000702A0D88DAC1184341020F10
...    780195B262AC4873E238F604F8C48E3C873EA39F30C7942C0E070F09FFF000007FFC000006400007003DE1E26800710400000858081507850001C46000002160561E230007104
...    000018581587850001C41000002160561E26800711800000858158B88C001C41000E208000050B02B0F0A000389A0000182C0AC5C4D000E2080070A000002058158B89A001C46
...    000E230000020B02B170A0003882001C46000004160562E1400071040038820000082C0AC5C4D000E20800711800001058158B850001C46000E230000020B02B1713400388C00
...    1C28000008160561E230007118000018581007011A014404D808232800BB07C28913639F0E14489B1CF870A244D8E7C3851226C73E1C28913639F0E2448913639F0E14081B1CF
...    811204081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF810A040D8E7C00170F18C6318C6318C6318C61E836001E0014
...    0E0A00E0601280380030120020301F04801000000008000010040000000200000401000004008000030040000200200001401000802008020000180100000E008004000000100
...    001000800009004000018020000280100001600800409024010000180672A6B2A6B052B032B066B056B296B266B016B036B012B022B07681A0800004B29202000032CA4A08000
...    14B29202000072CA480800024B292020000B2CA480800034B292020000F2CA480800044B29202000132CA480800054B29202000172CA4A0800064B29202000062CA480669545D
...    2AAAA55174AA2A82C55058AA0D154A62A93455018AA051549AAA83C50D005E02540A05028140A05028140A05028140A05028140A05000608080600C02004008404008020100C0
...    18402004008080600C02018030404030060100C018402004008080600C02004008804030060100C018040300608080100402004010D50F8000810182030385058606880889098
...    A0C0C8D8E0E8F909293139414951697A0A0C168

@{TP_activate_check}
...    transformPrecoder enabled
...    tp-pi2BPSK enabled
...    criticalExtensions rrcReconfigurationComplete

@{TP_and_SAG_activate_check}
...    transformPrecoder enabled
...    tp-pi2BPSK enabled
...    pusch-TimeDomainAllocationListDCI-0-1-r16 setup
...    pusch-RepTypeIndicatorDCI-0-1-r16 pusch-RepTypeA
...    criticalExtensions rrcReconfigurationComplete
...    betaOffsets dynamic

@{TP_disable}
...    criticalExtensions rrcReconfiguration
...    transformPrecoder disabled
...    criticalExtensions rrcReconfigurationComplete

@{PUSCH_initial_DFT-s-OFDM_PM}    NRCELL-3:NULHQ:M55302C06000    NRCELL-3:NULHQ:M55302C06001    NRCELL-3:NULHQ:M55302C06002
...    NRCELL-3:NULHQ:M55302C06003    NRCELL-3:NULHQ:M55302C06004    NRCELL-3:NULHQ:M55302C06005    NRCELL-3:NULHQ:M55302C06006
...    NRCELL-3:NULHQ:M55302C06007    NRCELL-3:NULHQ:M55302C06008    NRCELL-3:NULHQ:M55302C06009    NRCELL-3:NULHQ:M55302C06010
...    NRCELL-3:NULHQ:M55302C06011    NRCELL-3:NULHQ:M55302C06012    NRCELL-3:NULHQ:M55302C06013    NRCELL-3:NULHQ:M55302C06014
...    NRCELL-3:NULHQ:M55302C06015    NRCELL-3:NULHQ:M55302C06016    NRCELL-3:NULHQ:M55302C06017    NRCELL-3:NULHQ:M55302C06018
...    NRCELL-3:NULHQ:M55302C06019    NRCELL-3:NULHQ:M55302C06020    NRCELL-3:NULHQ:M55302C06021    NRCELL-3:NULHQ:M55302C06022
...    NRCELL-3:NULHQ:M55302C06023    NRCELL-3:NULHQ:M55302C06024    NRCELL-3:NULHQ:M55302C06025    NRCELL-3:NULHQ:M55302C06026
...    NRCELL-3:NULHQ:M55302C06027

@{Success_initial_Tx_DFTsOFDM_PM}    NRCELL-3:NULHQ:M55302C08000    NRCELL-3:NULHQ:M55302C08001    NRCELL-3:NULHQ:M55302C08002
...    NRCELL-3:NULHQ:M55302C08003    NRCELL-3:NULHQ:M55302C08004    NRCELL-3:NULHQ:M55302C08005    NRCELL-3:NULHQ:M55302C08006
...    NRCELL-3:NULHQ:M55302C08007    NRCELL-3:NULHQ:M55302C08008    NRCELL-3:NULHQ:M55302C08009    NRCELL-3:NULHQ:M55302C08010
...    NRCELL-3:NULHQ:M55302C08011    NRCELL-3:NULHQ:M55302C08012    NRCELL-3:NULHQ:M55302C08013    NRCELL-3:NULHQ:M55302C08014
...    NRCELL-3:NULHQ:M55302C08015    NRCELL-3:NULHQ:M55302C08016    NRCELL-3:NULHQ:M55302C08017    NRCELL-3:NULHQ:M55302C08018
...    NRCELL-3:NULHQ:M55302C08019    NRCELL-3:NULHQ:M55302C08020    NRCELL-3:NULHQ:M55302C08021    NRCELL-3:NULHQ:M55302C08022
...    NRCELL-3:NULHQ:M55302C08023    NRCELL-3:NULHQ:M55302C08024    NRCELL-3:NULHQ:M55302C08025    NRCELL-3:NULHQ:M55302C08026
...    NRCELL-3:NULHQ:M55302C08027

@{Successful_any_Tx_with_DFTsOFDM}    NRCELL-3:NULHQ:M55302C09000    NRCELL-3:NULHQ:M55302C09001    NRCELL-3:NULHQ:M55302C09002
...    NRCELL-3:NULHQ:M55302C09003    NRCELL-3:NULHQ:M55302C09004    NRCELL-3:NULHQ:M55302C09005    NRCELL-3:NULHQ:M55302C09006
...    NRCELL-3:NULHQ:M55302C09007    NRCELL-3:NULHQ:M55302C09008    NRCELL-3:NULHQ:M55302C09009    NRCELL-3:NULHQ:M55302C09010
...    NRCELL-3:NULHQ:M55302C09011    NRCELL-3:NULHQ:M55302C09012    NRCELL-3:NULHQ:M55302C09013    NRCELL-3:NULHQ:M55302C09014
...    NRCELL-3:NULHQ:M55302C09015    NRCELL-3:NULHQ:M55302C09016    NRCELL-3:NULHQ:M55302C09017    NRCELL-3:NULHQ:M55302C09018
...    NRCELL-3:NULHQ:M55302C09019    NRCELL-3:NULHQ:M55302C09020    NRCELL-3:NULHQ:M55302C09021    NRCELL-3:NULHQ:M55302C09022
...    NRCELL-3:NULHQ:M55302C09023    NRCELL-3:NULHQ:M55302C09024    NRCELL-3:NULHQ:M55302C09025    NRCELL-3:NULHQ:M55302C09026
...    NRCELL-3:NULHQ:M55302C09027

@{Unsuccessful_HARQ_reTx_with_DFTsOFDM}    NRCELL-3:NULHQ:M55302C07000    NRCELL-3:NULHQ:M55302C07001    NRCELL-3:NULHQ:M55302C07002
...    NRCELL-3:NULHQ:M55302C07003    NRCELL-3:NULHQ:M55302C07004    NRCELL-3:NULHQ:M55302C07005    NRCELL-3:NULHQ:M55302C07006
...    NRCELL-3:NULHQ:M55302C07007    NRCELL-3:NULHQ:M55302C07008    NRCELL-3:NULHQ:M55302C07009    NRCELL-3:NULHQ:M55302C07010
...    NRCELL-3:NULHQ:M55302C07011    NRCELL-3:NULHQ:M55302C07012    NRCELL-3:NULHQ:M55302C07013    NRCELL-3:NULHQ:M55302C07014
...    NRCELL-3:NULHQ:M55302C07015    NRCELL-3:NULHQ:M55302C07016    NRCELL-3:NULHQ:M55302C07017    NRCELL-3:NULHQ:M55302C07018
...    NRCELL-3:NULHQ:M55302C07019    NRCELL-3:NULHQ:M55302C07020    NRCELL-3:NULHQ:M55302C07021    NRCELL-3:NULHQ:M55302C07022
...    NRCELL-3:NULHQ:M55302C07023    NRCELL-3:NULHQ:M55302C07024    NRCELL-3:NULHQ:M55302C07025    NRCELL-3:NULHQ:M55302C07026
...    NRCELL-3:NULHQ:M55302C07027

@{CNI108979enable}
...    NRCELL-1:actUlTransPreEnhHo=true
...    NRCELL-3:actUlTransPreEnhHo=true

@{All_TP_Counters}    @{PUSCH_initial_DFT-s-OFDM_PM}    @{Success_initial_Tx_DFTsOFDM_PM}    @{Successful_any_Tx_with_DFTsOFDM}
...    @{Unsuccessful_HARQ_reTx_with_DFTsOFDM}

#wireshark check reference
# tpStateInSourceCell_item == 0 disabled 1 enabled
# transformPrecoderInd == 1 disabled 2 enabled
# sagStateInSourceCell_item == 0 disabled 1 enabled

*** Test Cases ***
CNI108979-ET-001_Verify_TP_Keep_On_After_Intra_Gnb_HO_With_Feature_Online_modification
    [Documentation]
    ...    The purpose of this test case is to check following scenarios:
    ...    When a UE in poor RF coverage and configured with PUSCH DFT-s-OFDM at a cell with CNI-108979 enabled perform
    ...    intra gnb HO with target cell CNI-108979 enabled. Upon completion of the handover, the UE at the target cell
    ...    continues configured for PUSCH DFT-s-OFDM (without the need for additional, dedicated RRC Reconfiguration)
    ...    Requirement Coverage:
    ...    5G_RAN_USR_RRM_25544, partially covered
    ...    CNI-108979#1: PUSCH Transform Precoder Continues at Target Cell
    ...    2.Test Case Steps:
    ...         Step A.Online change both cells ulTransPreEnhHo to true
    ...         Step B.SA UE1 attach to CELL1 with Non GBR DRB with Traffic and trigger TP ON.
    ...         Step C.UE1 perform intra gnb HO from CELL1 to CELL3.
    ...         Step D.UE1 adjust SINR to make TP off and TP on some times.
    ...         Step E.Attach UE2 with VONR call and Trigger TP ON.
    ...         Step F.UE2 perform intra gnb HO from CELL1 to CELL3.
    ...         Step G.UE2 adjust SINR to make TP off and TP on some times.
    ...         Step H.UE1 and UE2 perform intra gnb HO from CELL3 to CELL1.
    ...         Step I.UE1 and UE2 release.
    ...    3. Expected Results:
    ...         Step A: param online change successfully.
    ...         Step B: UE attach successfully with stable traffic, transformPrecoder set to true.
    ...         Step C: Handover successfully.
    ...          1)check on PsUser_UserSetupReq tpStateInSourceCell should be enabled
    ...          2)Upon receipt of RrcReconfigurationComplete from UE for HO completion, no dedicated RRC ReConfiguration procedure for TP.
    ...          3)check counters M55302C06XXXX M55302C07XXXX M55302C08XXXX M55302C09XXXX update successfully.
    ...         Step D:
    ...          1)Verify transformPrecoder set to disabled when tp off
    ...          2)Verify transformPrecoder set to enabled when tp on
    ...         Step E.
    ...          1)UE attach successfully with stable traffic, transformPrecoder set to true.
    ...          2)gNB configures UE with SAg specific dynamic betaoffsets in UCI-onPUSCH IE
    ...         Step F: Handover successfully.
    ...          1)check on PsUser_UserSetupReq tpStateInSourceCell should be enabled,sagStateInSourceCell should be disabled
    ...          2)Upon receipt of RrcReconfigurationComplete from UE for HO completion, no dedicated RRC ReConfiguration procedure for TP.
    ...         Step G:
    ...          1)Verify transformPrecoder set to disabled when tp off
    ...          2)Verify transformPrecoder set to enabled when tp on
    ...         Step H: Handover successfully.
    ...          1)UE1 PsUser_UserSetupReq tpStateInSourceCell should be enabled
    ...          2)UE1 Upon receipt of RrcReconfigurationComplete from UE for HO completion, no dedicated RRC ReConfiguration procedure for TP.
    ...          1)UE2 PsUser_UserSetupReq tpStateInSourceCell is disabled due to target actUlSlotAgg enable and 5QI1 presents(5G_CP_IF_RRC_160080)
    ...         Step I: UEs release successfully.
    [Tags]    001    QC_47184
    OnlineParamChange    ${CNI108979enable}
    UE register with Traffic and Trigger TP On    ue_id=1
    clear counter files
    Intragnb IntraFre A3 Handover    ue_id=1    sourcecell=1    targetcell=3    targetpci=61
    Check DFT-s-OFDM related PM counter
    Trigger TP Off and On multi times    ue_id=1
    UE make VONR call with Traffic and Trigger TP On    ue_id=2     TPCHECK=${TP_and_SAG_activate_check}
    Intragnb IntraFre A3 Handover    ue_id=2    sourcecell=1    targetcell=3    targetpci=61
    Trigger TP Off and On multi times    ue_id=2
    Intragnb IntraFre A3 Handover    ue_id=1    sourcecell=3    targetcell=1    targetpci=60
    Intragnb IntraFre A3 Handover TP off    ue_id=2    sourcecell=3    targetcell=1    targetpci=60
    Release UEs    ue_type=all

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/3cells_1T2F

Modify Cfg
    Update Cfg    ue_param id=1 ue_nr_capabilities=${SA_Capa_Support_SAG} nr_usage_setting=voice_centric
    Update Cfg    ue_param id=2 ue_nr_capabilities=${SA_Capa_Support_SAG} nr_usage_setting=voice_centric
    Update Cfg    amf_param id=1 full_nas_auth=on nia=null+aes nea=null+aes ims_voice_3gpp=on
    ${set_ue1}    catenate
    ...    set_ue simulated id=1 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56
    ...    opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+aes nea=null+aes sec_key=0102030405060708090A0B0C0D0EFF00
    ...    suci=0:311:489:0000:0:0:021645400 mode=nr enb=2 cell=1
    Update Cfg    ${set_ue1}
    Update Cfg    ue_nr_capabilities id=1 voice_over_nr=on:on:off
    ${set_ue2}    catenate
    ...    set_ue simulated id=2 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56
    ...    opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+aes nea=null+aes sec_key=0102030405060708090A0B0C0D0EFF00
    ...    suci=0:311:489:0000:0:0:021645401 mode=nr enb=2 cell=1
    Update Cfg    ${set_ue2}
    Update Cfg    ue_nr_capabilities id=2 voice_over_nr=on:on:off
    Update Cfg    set_qosflow id=1 5qi=5 default=on
    Update Cfg    set_qosflow id=2 5qi=1
    Update Cfg    set_qosflow id=3 5qi=6 default=off
    Update Cfg    set_qosrule id=1 proto=tcp qos_flow=1
    Update Cfg    set_qosrule id=2 proto=udp qos_flow=2
    Update Cfg    set_qosrule id=3 proto=udp qos_flow=3
    Update Cfg    set_nwslice id=1 snssai=0x01:0xD143A5 qos_flows=1,2,3 qos_rules=1,2,3 default=on ue=1-6 amf=1

UE Register And Add Pdu With Default 5QI6
    [Arguments]    ${ue_id}=1    ${cell}=1
    Execute Egate Command    ue_change_location id=${ue_id} cell=${cell} enb=2
    Execute Egate Command    qosflow_modify qos_flow=3 default=on ue=${ue_id}
    Execute Egate Command    ue_register id=${ue_id} nwslice=1    pass_regexp=Received REGISTRATION COMPLETE
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${ue_id}
    ...    pass_regexp=UE${ue_id}: Ue ${ue_id} PduId 1 Created FiveQi:Qfi mapping fiveQi 6 qfi 1

UE register with Traffic and Trigger TP On
    [Arguments]    ${ue_id}=1    ${cell}=1
    BuiltIn.Log    UE register with Traffic and Trigger TP On...    console=${True}
    Start To Capture Wireshark Log    ue${ue_id}RegisterAndTPOn
    UE Register And Add Pdu With Default 5QI6    ue_id=${ue_id}    cell=${cell}
    start Traffic    ue_id=${ue_id}
    UE Moves Towards Cell Edge to trigger TP ON    ue_id=${ue_id}
    Stop Capture Wireshark Log

UE make VONR call with Traffic and Trigger TP On
    [Arguments]    ${ue_id}=1    ${cell}=1    ${TPCHECK}=@{TP_activate_check}
    Start To Capture Wireshark Log    ue${ue_id}RegisterAndTPOn
    UE Register And Add Pdu With Default 5QI6    ue_id=${ue_id}    cell=${cell}
    start Traffic    ue_id=${ue_id}
    UE trigger VONR Call    ue_id=${ue_id}
    UE Moves Towards Cell Edge to trigger TP ON    ue_id=${ue_id}    TPCHECK=${TPCHECK}
    Stop Capture Wireshark Log

UE trigger VONR Call
    [Arguments]    ${ue_id}=1
    Execute Egate Command    qosflow_modify qos_flow=1 default=on ue=${ue_id}
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=2 gw=2 nwslice=1
    ...    pass_regexp=PduId 2 Created FiveQi:Qfi mapping fiveQi 5 qfi 1
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=2 qosflows_to_add=2 by=amf
    ...    pass_regexp=Adding QosFlow with QFI:2 5QI:1

start Traffic
    [Arguments]    ${ue_id}=1
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 trf_id=1 mbps=40 dir=dl
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=1 mbps=10 dir=ul
    Verify Throughput    ue_id=${ue_id}

Verify Throughput
    [Arguments]    ${ue_id}=1    ${Tput_dl}=36    ${Tput_ul}=8    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

Intragnb IntraFre A3 Handover
    [Arguments]    ${ue_id}=1    ${sourcecell}=1    ${targetcell}=3    ${targetpci}=61
    BuiltIn.Log    UE perform handover to CELL${targetcell}...    console=${True}
    Start To Capture Wireshark Log    UE${ue_id}HOtoCELL${targetcell}
    ${meas_id_A3}    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=127210    event_type=A3
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id_A3} event=A3 phycell_id=${targetpci}
    ...    pass_regexp=(transformPrecoder enabled|Intra-eNB handover from EXT_ENB-2.${sourcecell} to EXT_ENB-2.${targetcell} performed)
    sleep    5s    #wait for TP stable
    Stop Capture Wireshark Log
    check_num_of_wireshark_as_excepted    ${SAVE LOG DIRECTORY}${/}/wireshark_UE${ue_id}HOtoCELL${targetcell}.pcap
    ...    (itf_l2_ps_user_UserSetupReq_t.tpStateInSourceCell_item == 1) && !(itf_l2_ps_user_UserSetupReq_t.sagStateInSourceCell_item==1) @1

Intragnb IntraFre A3 Handover TP off
    [Arguments]    ${ue_id}=1    ${sourcecell}=1    ${targetcell}=3    ${targetpci}=61
    BuiltIn.Log    UE perform handover to CELL${targetcell}...    console=${True}
    Start To Capture Wireshark Log    UE${ue_id}HOtoCELL${targetcell}
    ${meas_id_A3}    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=127210    event_type=A3
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id_A3} event=A3 phycell_id=${targetpci}
    ...    pass_regexp=(transformPrecoder enabled|Intra-eNB handover from EXT_ENB-2.${sourcecell} to EXT_ENB-2.${targetcell} performed)
    sleep    5s    #wait for TP stable
    Stop Capture Wireshark Log
    check_num_of_wireshark_as_excepted    ${SAVE LOG DIRECTORY}${/}/wireshark_UE${ue_id}HOtoCELL${targetcell}.pcap
    ...    (itf_l2_ps_user_UserSetupReq_t.sagStateInSourceCell_item == False) && (itf_l2_ps_user_UserSetupReq_t.tpStateInSourceCell_item == False) @1

OnlineParamChange
    [Arguments]    ${Online_Param}
    BuiltIn.Log    Online change feature flag on...    console=${True}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir
    Execute Egate Command     ue_testmode_set_nr id=1 testmode=ul_sinr profile_id=1 action=deactivate
    Execute Egate Command     ue_testmode_set_nr id=2 testmode=ul_sinr profile_id=2 action=deactivate
    Execute Egate Command     ul_sinr_testmode_nr profile_id=1 delete=1
    Execute Egate Command     ul_sinr_testmode_nr profile_id=2 delete=1

UE Moves Towards Cell Center to trigger TP OFF
    [Arguments]    ${ue_id}=1
    ${ret1}=    Run Keyword And Ignore Error
    ...    Execute Egate Command     ul_sinr_testmode_nr profile_id=${ue_id} pathloss=30    pass_regexp=${TP_disable}
    ${ret2}=    Run Keyword And Ignore Error
    ...    Execute Egate Command     ue_testmode_set_nr id=${ue_id} testmode=ul_sinr profile_id=${ue_id} action=activate    pass_regexp=${TP_disable}
    Evaluate    '${ret1[0]} == "PASS" or ${ret2[0]} == "PASS"'
    Verify Throughput    ue_id=${ue_id}

UE Moves Towards Cell Edge to trigger TP ON
    [Arguments]    ${ue_id}=1    ${TPCHECK}=@{TP_activate_check}
    ${ret1}=     Run Keyword And Ignore Error    Execute Egate Command     ul_sinr_testmode_nr profile_id=${ue_id} pathloss=118
    ...    pass_regexp=${TPCHECK}
    ${ret2}=     Run Keyword And Ignore Error
    ...    Execute Egate Command     ue_testmode_set_nr id=${ue_id} testmode=ul_sinr profile_id=${ue_id} action=activate    pass_regexp=${TPCHECK}
    Evaluate    '${ret1[0]} == "PASS" or ${ret2[0]} == "PASS"'
    Verify Throughput    ue_id=${ue_id}    Tput_ul=5

Trigger TP Off and On multi times
    [Arguments]    ${repeattime}=5    ${ue_id}=1
    BuiltIn.Log    Trigger TP Off and On multi times...    console=${True}
    Start To Capture Wireshark Log    triggerTPonAndOffMultiTimesUE${ue_id}
    FOR    ${item}    IN RANGE    0    ${repeattime}
        UE Moves Towards Cell Center to trigger TP OFF    ue_id=${ue_id}
        UE Moves Towards Cell Edge to trigger TP ON    ue_id=${ue_id}
    END
    Stop Capture Wireshark Log

Check DFT-s-OFDM related PM counter
    BuiltIn.Log    start to check DFT-s-OFDM related PM counters...    console=${True}
    ${All_TP_Counters_PM}    Get Counters Value    ${All_TP_Counters}
    ${Count_PUSCH_initial_DFT-s-OFDM_PM}    Get Slice From List    ${All_TP_Counters_PM}    0    27
    ${Count_Success_initial_Tx_DFTsOFDM_PM}    Get Slice From List    ${All_TP_Counters_PM}    28    55
    ${Count_Successful_any_Tx_with_DFTsOFDM}    Get Slice From List    ${All_TP_Counters_PM}    56    83
    ${Count_Unsuccessful_HARQ_reTx_with_DFTsOFDM}    Get Slice From List    ${All_TP_Counters_PM}    84    111
    ${Sum_PUSCH_initial_DFT-s-OFDM_PM}    Set Variable    0
    ${Sum_Success_initial_Tx_DFTsOFDM_PM}    Set Variable    0
    ${Sum_Successful_any_Tx_with_DFTsOFDM}    Set Variable    0
    ${Sum_Unsuccess_HARQ_reTx_with_DFTsOFDM}    Set Variable    0
    FOR    ${value}    IN    @{Count_PUSCH_initial_DFT-s-OFDM_PM}
        ${Sum_PUSCH_initial_DFT-s-OFDM_PM}    evaluate    ${Sum_PUSCH_initial_DFT-s-OFDM_PM}+ ${value}
	END
    FOR    ${value}    IN    @{Count_Success_initial_Tx_DFTsOFDM_PM}
        ${Sum_Success_initial_Tx_DFTsOFDM_PM}    evaluate    ${Sum_Success_initial_Tx_DFTsOFDM_PM}+ ${value}
	END
    FOR    ${value}    IN    @{Count_Successful_any_Tx_with_DFTsOFDM}
        ${Sum_Successful_any_Tx_with_DFTsOFDM}    evaluate    ${Sum_Successful_any_Tx_with_DFTsOFDM}+ ${value}
	END
    FOR    ${value}    IN    @{Count_Unsuccessful_HARQ_reTx_with_DFTsOFDM}
        ${Sum_Unsuccess_HARQ_reTx_with_DFTsOFDM}    evaluate    ${Sum_Unsuccess_HARQ_reTx_with_DFTsOFDM}+ ${value}
	END
    log    ${Sum_PUSCH_initial_DFT-s-OFDM_PM}
    log    ${Sum_Success_initial_Tx_DFTsOFDM_PM}
    log    ${Sum_Successful_any_Tx_with_DFTsOFDM}
    log    ${Sum_Unsuccess_HARQ_reTx_with_DFTsOFDM}
    Should Be True    ${Sum_PUSCH_initial_DFT-s-OFDM_PM}>0
    Should Be True    ${Sum_Success_initial_Tx_DFTsOFDM_PM}>0
    Should Be True    ${Sum_Successful_any_Tx_with_DFTsOFDM}>0
    Should Be True    ${Sum_Unsuccess_HARQ_reTx_with_DFTsOFDM}==0
