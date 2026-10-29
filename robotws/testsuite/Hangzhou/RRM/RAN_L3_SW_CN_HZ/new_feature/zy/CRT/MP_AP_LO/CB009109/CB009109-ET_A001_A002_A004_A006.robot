*** Settings ***
Documentation
...    author: Zhang Yin
...    contact: yin.zhang@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_VRF    RAN_5G    RAN_5G_TDD    SBTS00    CRT    CLOUD_5G_I_MP_AP_LO
...           owner-jing.ye    team-CN1ET    release-SBTS24R3
Resource    testsuite/Hangzhou/RRM/RAN_L3_SW_CN_HZ/resources/DevHZ5_resource.robot

*** Variables ***
${SYSCOM_FLAG}    ${True}
@{FAULTS_EXCLUDED_CHECKING}    4741    4452

@{TF_CA}
...    NRCELL:actK1Opt=intraAndInter-gNB
...    NRCELL:a1MeasSCellAddEnabled=rsrp
...    NRCELL:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=90
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=70
...    NRBTS/NRDU-1:carrierAggregationSupportList=ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Fdd_Nsa
...    NRCELL-2/NRREL-10:sCellAdditionMethod=blind
...    NRCELL-2/NRREL-10:sCellOperationalMode=dlOnly
...    MRBTS-2/NRBTS-2:sCellActivationMethod=blind

@{PARAMS_IN_SCF}
...    @{IntragNB_IntraDU_HO_Config}
...    @{CB009109_parameters}
...    @{732}
...    @{CB008225_CB006597}
...    @{TF_CA}
#CNI-105411

...    MRBTS-2/NRBTS-2:actNrpmqapProfiles=true
...    NRPMRNL-1/NRPMQAP-1:cfgProfType=SA
...    NRPMRNL-1/NRPMQAP-1:cfg5qiRange=1-9
...    NRPMRNL-1/NRPMQAP-1:cfgArpRange=1-15
...    NRPMRNL-1/NRPMQAP-1:cfgPlmnId:mncLength=3
...    NRPMRNL-1/NRPMQAP-1:cfgPlmnId:mcc=311
...    NRPMRNL-1/NRPMQAP-1:cfgPlmnId:mnc=489
...    NRPMRNL-1/NRPMQAP-1:cfgSliceId:sst=1
...    NRPMRNL-1/NRPMQAP-1:cfgSliceId:sd=13714341
...    NRPMRNL-1/NRPMQAP-19:cfgProfType=SA
...    NRPMRNL-1/NRPMQAP-19:cfg5qiRange=5,1
...    NRPMRNL-1/NRPMQAP-19:cfgArpRange=15
...    NRPMRNL-1/NRPMQAP-19:cfgPlmnId:mncLength=3
...    NRPMRNL-1/NRPMQAP-19:cfgPlmnId:mcc=311
...    NRPMRNL-1/NRPMQAP-19:cfgPlmnId:mnc=489
...    NRPMRNL-1/NRPMQAP-19:cfgSliceId:sst=1
...    NRPMRNL-1/NRPMQAP-19:cfgSliceId:sd=13714341
...    NRBTS/NRPMRNL-1/NRPMQAP-11:cfg5qiRange=6
...    NRBTS/NRPMRNL-1/NRPMQAP-11:cfgArpRange=1-15
...    NRBTS/NRPMRNL-1/NRPMQAP-11:cfgProfType=SA
...    NRBTS/NRPMRNL-1/NRPMQAP-11:cfgPlmnId:mcc=311
...    NRBTS/NRPMRNL-1/NRPMQAP-11:cfgPlmnId:mnc=489
...    NRBTS/NRPMRNL-1/NRPMQAP-11:cfgPlmnId:mncLength=3
...    NRBTS/NRPMRNL-1/NRPMQAP-11:cfgSliceId:sd=13714341
...    NRBTS/NRPMRNL-1/NRPMQAP-11:cfgSliceId:sst=1
...    MRBTS-2/NRBTS-2:actLatencyPmCount=true
...    MRBTS-2/NRBTS-2:actThpDist=false
...    MRBTS-2/NRBTS-2:actIpThpt=true

#alignment with pdcch tool
...    NRBTS/BWP_PROFILE-33:bwpType=dedicated
...    NRBTS/BWP_PROFILE-33:locationAndBandwidthDl:cRbSizeDl=allRb
...    NRBTS/BWP_PROFILE-33:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-33:locationAndBandwidthUl:cRbSizeUl=sameAsDl
...    NRBTS/BWP_PROFILE-33:locationAndBandwidthUl:cRbStartUl=sameAsDl
...    NRBTS/BWP_PROFILE-33/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-33/PDCCH-1:dciDedicatedAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-33/PDCCH-1:dciPagingAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-33/PDCCH-1:dciRaCompletionAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-33/PDCCH-1:dciRaMsg2AggregationLevel=AL4
...    NRBTS/BWP_PROFILE-33/PDCCH-1:dciSiAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-33/PDCCH-1:downgradeAL16toAL8=notAllowed
...    NRBTS/BWP_PROFILE-33/PDCCH-1:downgradeALProactive=false
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=4
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=4
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=4
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=4
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=5
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=6
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=6
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=6
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=6
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cceToRegMapping=interleaved
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:coresetId=1
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cRbStart=0
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:duration=1
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:interleaverSize=n3
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:regBundleSize=n2
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=96
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-0-And-1-0|coresetId=0
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|coresetId=0
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=0
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=0
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=0
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=0
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n4|coresetId=0
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=0
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|coresetId=0
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=7|coresetId=0
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|coresetId=0
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=0
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|coresetId=1
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|coresetId=1
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=1
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=1
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=1
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=1
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n4|coresetId=1
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=1
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|coresetId=1
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=8|coresetId=1
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|coresetId=1
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=1
...    NRBTS/BWP_PROFILE-33/PDSCH-1:pdschRat0RbgConfig=config1
...    NRBTS/BWP_PROFILE-4:bwpType=initial
...    NRBTS/BWP_PROFILE-4:locationAndBandwidthDl:cRbSizeDl=coreset0
...    NRBTS/BWP_PROFILE-4:locationAndBandwidthDl:cRbStartDl=coreset0
...    NRBTS/BWP_PROFILE-4:locationAndBandwidthUl:cRbSizeUl=allRb
...    NRBTS/BWP_PROFILE-4:locationAndBandwidthUl:cRbStartUl=crb0
...    NRBTS/BWP_PROFILE-4/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-4/PDCCH-1:dciDedicatedAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-4/PDCCH-1:dciPagingAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-4/PDCCH-1:dciRaCompletionAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-4/PDCCH-1:dciRaMsg2AggregationLevel=AL4
...    NRBTS/BWP_PROFILE-4/PDCCH-1:dciSiAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-4/PDCCH-1:downgradeAL16toAL8=notAllowed
...    NRBTS/BWP_PROFILE-4/PDCCH-1:downgradeALProactive=false
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=1
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=1
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=1
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=1
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=2
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=3
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=3
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=3
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=3
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-7:bwpType=initial
...    NRBTS/BWP_PROFILE-7:locationAndBandwidthDl:cRbSizeDl=coreset0
...    NRBTS/BWP_PROFILE-7:locationAndBandwidthDl:cRbStartDl=coreset0
...    NRBTS/BWP_PROFILE-7:locationAndBandwidthUl:cRbSizeUl=sameAsDl
...    NRBTS/BWP_PROFILE-7:locationAndBandwidthUl:cRbStartUl=sameAsDl
...    NRBTS/BWP_PROFILE-7/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-7/PDCCH-1:dciDedicatedAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-7/PDCCH-1:dciPagingAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-7/PDCCH-1:dciRaCompletionAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-7/PDCCH-1:dciRaMsg2AggregationLevel=AL4
...    NRBTS/BWP_PROFILE-7/PDCCH-1:dciSiAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-7/PDCCH-1:downgradeAL16toAL8=notAllowed
...    NRBTS/BWP_PROFILE-7/PDCCH-1:downgradeALProactive=false
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|duration=4
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|duration=4
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|duration=4
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|duration=4
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|duration=4
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|duration=4
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|duration=4
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|duration=4
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=1|duration=4
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|duration=4
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=6|duration=4
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|duration=1
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|duration=1
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|duration=1
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|duration=1
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|duration=1
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|duration=1
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|duration=1
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|duration=1
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=2|duration=1
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|duration=1
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|duration=1
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|duration=3
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|duration=3
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|duration=3
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|duration=3
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|duration=3
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|duration=3
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|duration=3
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|duration=3
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=3|duration=3
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|duration=3
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|duration=3
...    NRBTS/BWP_PROFILE-77:bwpType=dedicated
...    NRBTS/BWP_PROFILE-77:locationAndBandwidthDl:cRbSizeDl=allRb
...    NRBTS/BWP_PROFILE-77:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-77:locationAndBandwidthUl:cRbSizeUl=sameAsDl
...    NRBTS/BWP_PROFILE-77:locationAndBandwidthUl:cRbStartUl=sameAsDl
...    NRBTS/BWP_PROFILE-77/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-77/PDCCH-1:dciDedicatedAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-77/PDCCH-1:dciPagingAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-77/PDCCH-1:dciRaCompletionAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-77/PDCCH-1:dciRaMsg2AggregationLevel=AL4
...    NRBTS/BWP_PROFILE-77/PDCCH-1:dciSiAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-77/PDCCH-1:downgradeAL16toAL8=notAllowed
...    NRBTS/BWP_PROFILE-77/PDCCH-1:downgradeALProactive=false
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|duration=4
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|duration=4
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|duration=4
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|duration=4
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|duration=4
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|duration=4
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|duration=4
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|duration=4
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=4|duration=4
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|duration=4
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=6|duration=4
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|duration=1
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|duration=1
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|duration=1
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|duration=1
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|duration=1
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|duration=1
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|duration=1
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|duration=1
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=5|duration=1
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|duration=1
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|duration=1
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|duration=3
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|duration=3
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|duration=3
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|duration=3
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|duration=3
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|duration=3
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|duration=3
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|duration=3
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=6|duration=3
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|duration=3
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|duration=3
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cceToRegMapping=nonInterleaved
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:coresetId=1
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cRbStart=0
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:duration=1
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:interleaverSize=none
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:regBundleSize=n6
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=120
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-0-And-1-0|coresetId=0
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|coresetId=0
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=0
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=0
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=0
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=0
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|coresetId=0
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=0
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|coresetId=0
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=7|coresetId=0
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|coresetId=0
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=0
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|coresetId=1
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|coresetId=1
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=1
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=1
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=1
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=1
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n5|coresetId=1
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=1
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|coresetId=1
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=8|coresetId=1
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|coresetId=1
...    NRBTS/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=1
...    NRBTS/BWP_PROFILE-77/PDSCH-1:pdschRat0RbgConfig=config1
...    NRCELL-1:cellBwpList:actPdcchCceFragmentControl=false|bwpDN=MRBTS-2/NRBTS-2/BWP_PROFILE-4
...    NRCELL-1:cellBwpList:actUpperThrAckNackFiltering=false|bwpDN=MRBTS-2/NRBTS-2/BWP_PROFILE-4
...    NRCELL-1:cellBwpList:actUpperThrAckNackHrFiltering=false|bwpDN=MRBTS-2/NRBTS-2/BWP_PROFILE-4
...    NRCELL-1:cellBwpList:cellBwpId=0|bwpDN=MRBTS-2/NRBTS-2/BWP_PROFILE-4
...    NRCELL-1:cellBwpList:pdcchResourcePreference=peakRate|bwpDN=MRBTS-2/NRBTS-2/BWP_PROFILE-4
...    NRCELL-1:cellBwpList:actPdcchCceFragmentControl=false|bwpDN=MRBTS-2/NRBTS-2/BWP_PROFILE-33
...    NRCELL-1:cellBwpList:actUpperThrAckNackFiltering=false|bwpDN=MRBTS-2/NRBTS-2/BWP_PROFILE-33
...    NRCELL-1:cellBwpList:actUpperThrAckNackHrFiltering=false|bwpDN=MRBTS-2/NRBTS-2/BWP_PROFILE-33
...    NRCELL-1:cellBwpList:cellBwpId=1|bwpDN=MRBTS-2/NRBTS-2/BWP_PROFILE-33
...    NRCELL-1:cellBwpList:pdcchResourcePreference=peakRate|bwpDN=MRBTS-2/NRBTS-2/BWP_PROFILE-33
...    NRCELL-2:cellBwpList:actPdcchCceFragmentControl=false|bwpDN=MRBTS-2/NRBTS-2/BWP_PROFILE-7
...    NRCELL-2:cellBwpList:actUpperThrAckNackFiltering=false|bwpDN=MRBTS-2/NRBTS-2/BWP_PROFILE-7
...    NRCELL-2:cellBwpList:actUpperThrAckNackHrFiltering=false|bwpDN=MRBTS-2/NRBTS-2/BWP_PROFILE-7
...    NRCELL-2:cellBwpList:cellBwpId=0|bwpDN=MRBTS-2/NRBTS-2/BWP_PROFILE-7
...    NRCELL-2:cellBwpList:pdcchResourcePreference=peakRate|bwpDN=MRBTS-2/NRBTS-2/BWP_PROFILE-7
...    NRCELL-2:cellBwpList:actPdcchCceFragmentControl=false|bwpDN=MRBTS-2/NRBTS-2/BWP_PROFILE-77
...    NRCELL-2:cellBwpList:actUpperThrAckNackFiltering=false|bwpDN=MRBTS-2/NRBTS-2/BWP_PROFILE-77
...    NRCELL-2:cellBwpList:actUpperThrAckNackHrFiltering=false|bwpDN=MRBTS-2/NRBTS-2/BWP_PROFILE-77
...    NRCELL-2:cellBwpList:cellBwpId=1|bwpDN=MRBTS-2/NRBTS-2/BWP_PROFILE-77
...    NRCELL-2:cellBwpList:pdcchResourcePreference=peakRate|bwpDN=MRBTS-2/NRBTS-2/BWP_PROFILE-77
...    NRCELL-2:msg1FrequencyStart=14
...    NRCELL-3:cellBwpList:actPdcchCceFragmentControl=false|bwpDN=MRBTS-2/NRBTS-2/BWP_PROFILE-4
...    NRCELL-3:cellBwpList:actUpperThrAckNackFiltering=false|bwpDN=MRBTS-2/NRBTS-2/BWP_PROFILE-4
...    NRCELL-3:cellBwpList:actUpperThrAckNackHrFiltering=false|bwpDN=MRBTS-2/NRBTS-2/BWP_PROFILE-4
...    NRCELL-3:cellBwpList:cellBwpId=0|bwpDN=MRBTS-2/NRBTS-2/BWP_PROFILE-4
...    NRCELL-3:cellBwpList:pdcchResourcePreference=peakRate|bwpDN=MRBTS-2/NRBTS-2/BWP_PROFILE-4
...    NRCELL-3:cellBwpList:actPdcchCceFragmentControl=false|bwpDN=MRBTS-2/NRBTS-2/BWP_PROFILE-33
...    NRCELL-3:cellBwpList:actUpperThrAckNackFiltering=false|bwpDN=MRBTS-2/NRBTS-2/BWP_PROFILE-33
...    NRCELL-3:cellBwpList:actUpperThrAckNackHrFiltering=false|bwpDN=MRBTS-2/NRBTS-2/BWP_PROFILE-33
...    NRCELL-3:cellBwpList:cellBwpId=1|bwpDN=MRBTS-2/NRBTS-2/BWP_PROFILE-33
...    NRCELL-3:cellBwpList:pdcchResourcePreference=peakRate|bwpDN=MRBTS-2/NRBTS-2/BWP_PROFILE-33
...    NRBTS/NRFSOPGRP-1:cellSwitchOffType=TimeWindow
...    NRBTS/NRFSOPGRP-1:timeWindowCellSwitchOffList:fsoDayOfWeek=Sun
...    NRBTS/NRFSOPGRP-1:timeWindowCellSwitchOffList:fsoDuration=1
...    NRBTS/NRFSOPGRP-1:timeWindowCellSwitchOffList:fsoStartHour=3
...    NRBTS/NRFSOPGRP-1:timeWindowCellSwitchOffList:fsoStartMinute=0
...    delete:NRBTS/BWP_PROFILE-1
...    delete:NRBTS/BWP_PROFILE-1/PDCCH-1
...    delete:NRBTS/BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_COMMON-1
...    delete:NRBTS/BWP_PROFILE-14
...    delete:NRBTS/BWP_PROFILE-14/PDCCH-1
...    delete:NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1
...    delete:NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_DEDICATED-1
...    delete:NRBTS/BWP_PROFILE-14/PDSCH-1
...    delete:NRBTS/BWP_PROFILE-5
...    delete:NRBTS/BWP_PROFILE-5/PDCCH-1
...    delete:NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1
...    delete:NRBTS/BWP_PROFILE-54
...    delete:NRBTS/BWP_PROFILE-54/PDCCH-1
...    delete:NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1
...    delete:NRBTS/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1
...    delete:NRBTS/BWP_PROFILE-54/PDSCH-1

@{IntragNB_IntraDU_HO_Config}
...    NRBTS:actIntraFreqHoSA=true
...    NRBTS/NRPMRNL-1:miNrRelReportCu=5min
...    NRCELL:a3MeasEnabled=rsrp

@{732}
...    NRBTS:rrcReestabTypeSA=sameGNB

@{CB008225_CB006597}
...    NRBTS:act3gppBL23R1=true
...    NRBTS:actRrcInactState=none
...    NRBTS:actRrcReleasePreference=false
...    NRBTS:drbRrcInactInactivityTimerSA=20
...    NRBTS:maxUeRrcInactTime=60
...    NRBTS:outOfConnectedPreference=idle
...    NRBTS:ranPagingCycle=v32
...    NRBTS:actPaging=true
...    NRBTS:rrcInactIMMSteeringEnabled=false
...    NRBTS:rrcInactLocationReportEnabled=false
...    NRBTS:rrcInactPreferredStateEnabled=false
...    NRBTS:srbInactivityTimerSA=600
...    NRBTS:t380=5min
...    NRBTS:tRanPagingGuard=4
...    NRBTS:timerReleasePreferenceProhibit=s3
...    NRCELL-1:ranAC=0

@{CB009109_parameters}
...    NRBTS:actMultiDrbNSA=true
...    NRCELL:actCDrx=true
...    NRCELL:actCDrxVoNR=true
...    NRCELL:actEnhancedVoNR=true
...    NRCELL:actVoNR=true

...    NRBTS:actDisableUlProactGrantAnr=true
...    NRBTS:actEnhanceIntraNrIntraFreqAnr=true
...    NRBTS:actInterFreqHoSA=true
...    NRBTS:actNsaUeBasedAnrNr=true
...    NRBTS:actNsaUeBasedInterFreqAnrNr=true
...    NRBTS:actSaIntraFreqAnrDrxProf=true
...    NRBTS:actSaUeBasedAnrNr=true
...    NRBTS:actSaUeBasedInterFreqAnrNr=true
...    NRBTS/NRANR-1:consecXnResolveFailThres=3
...    NRBTS/NRDRB-15:discardTimer=10ms
...    NRBTS/NRDRB-15:discardTimerUl=infinity
...    NRBTS/NRDRB-15:dlFlowControlAlgo=none
...    NRBTS/NRDRB-15:maxDataRateGbrDl=1000
...    NRBTS/NRDRB-15:maxDataRateGbrUl=1000
...    NRBTS/NRDRB-15:maxRlcQueueingDelayGbr=10
...    NRBTS/NRDRB-15:maxTransferDelayGbr=20
...    NRBTS/NRDRB-15:nrDrbMacDN=MRBTS-2/NRBTS-2/NRDRB_MAC-3
...    NRBTS/NRDRB-15:nrDrbPdcpDN=MRBTS-2/NRBTS-2/NRDRB_PDCP-3
...    NRBTS/NRDRB-15:nrDrbRlcAmDN=MRBTS-2/NRBTS-2/NRDRB_RLC_AM-2
...    NRBTS/NRDRB-15:nrDrbRlcUmDN=MRBTS-2/NRBTS-2/NRDRB_RLC_UM-1

...    NRBTS/NRDRB-15:resType=GBR
...    NRBTS/NRDRB-15:rlcMode=RLC_UM
...    NRBTS/NRDRB-15:schedulWeight=1
...    NRBTS/NRDRB-15:cellAggrLevel=Not FR1 CA eligible
...    NRBTS/NRDRB-15:nsaDrbParam=${EMPTY}
...    NRBTS/NRDRB-15:queuingDelayDiscarding=Disabled
...    NRBTS/NRDRB_5QI-6:fiveqiValueList=1
...    NRBTS/NRDRB_5QI-6:nrDrbDN=MRBTS-2/NRBTS-2/NRDRB-15
...    NRBTS/NRDRB_MAC-3:lcgid=4
...    NRBTS/NRDRB_MAC-3:schedulBSD=5ms
...    NRBTS/NRDRB_PDCP-3:xxFlowControlProfForCuIdx=1
...    NRBTS/NRDRB_RLC_UM-1:dlTReassemblyUm=ms50
...    NRBTS:actDedicatedAnrDrxProfile=true
...    NRBTS:actDrbDrx=false
...    NRCELL:nonGbrNrDrxDN=NRDRX-1
...    NRCELL:voNRNrDrxDN=MRBTS-2/NRBTS-2/NRDRX-2

...    NRCELL:drxProfileNrAnr:nrDrxDN=NRDRX-3|drxControl=intraNR
...    NRCELL:drxProfileNrAnr:nrDrxDN=NRDRX-11|drxControl=intraNRFR2
...    NRCELL:drxProfileNrAnr:nrDrxDN=NRDRX-8|drxControl=intraNRSAinterFreq
...    NRBTS/NRDRX-0:drxHarqRttTimerDl=0symbols
...    NRBTS/NRDRX-0:drxHarqRttTimerUl=0symbols
...    NRBTS/NRDRX-0:drxInactivityTimer=0ms
...    NRBTS/NRDRX-0:drxLongCycle=10ms
...    NRBTS/NRDRX-0:drxOnDurationTimer=1ms
...    NRBTS/NRDRX-0:drxRetransTimerDl=0slot
...    NRBTS/NRDRX-0:drxRetransTimerUl=0slot
...    NRBTS/NRDRX-0:drxPriority=0
...    NRBTS/NRDRX-1:drxHarqRttTimerDl=0symbols
...    NRBTS/NRDRX-1:drxHarqRttTimerUl=0symbols
...    NRBTS/NRDRX-1:drxInactivityTimer=10ms
...    NRBTS/NRDRX-1:drxLongCycle=20ms
...    NRBTS/NRDRX-1:drxOnDurationTimer=10ms
...    NRBTS/NRDRX-1:drxRetransTimerDl=0slot
...    NRBTS/NRDRX-1:drxRetransTimerUl=0slot
...    NRBTS/NRDRX-1:drxPriority=31
...    NRBTS/NRDRX-2:drxHarqRttTimerDl=0symbols
...    NRBTS/NRDRX-2:drxHarqRttTimerUl=0symbols
...    NRBTS/NRDRX-2:drxInactivityTimer=4ms
...    NRBTS/NRDRX-2:drxLongCycle=40ms
...    NRBTS/NRDRX-2:drxOnDurationTimer=20ms
...    NRBTS/NRDRX-2:drxRetransTimerDl=0slot
...    NRBTS/NRDRX-2:drxRetransTimerUl=0slot
...    NRBTS/NRDRX-2:drxPriority=3
...    NRBTS/NRDRX-3:drxHarqRttTimerDl=0symbols
...    NRBTS/NRDRX-3:drxHarqRttTimerUl=0symbols
...    NRBTS/NRDRX-3:drxInactivityTimer=80ms
...    NRBTS/NRDRX-3:drxLongCycle=320ms
...    NRBTS/NRDRX-3:drxOnDurationTimer=40ms
...    NRBTS/NRDRX-3:drxPriority=15
...    NRBTS/NRDRX-3:drxRetransTimerDl=0slot
...    NRBTS/NRDRX-3:drxRetransTimerUl=0slot
...    NRBTS/NRDRX-4:drxHarqRttTimerDl=0symbols
...    NRBTS/NRDRX-4:drxHarqRttTimerUl=0symbols
...    NRBTS/NRDRX-4:drxInactivityTimer=80ms
...    NRBTS/NRDRX-4:drxLongCycle=160ms
...    NRBTS/NRDRX-4:drxOnDurationTimer=10ms
...    NRBTS/NRDRX-4:drxPriority=16
...    NRBTS/NRDRX-4:drxRetransTimerDl=0slot
...    NRBTS/NRDRX-4:drxRetransTimerUl=0slot
...    NRBTS/NRDRX-5:drxHarqRttTimerDl=0symbols
...    NRBTS/NRDRX-5:drxHarqRttTimerUl=0symbols
...    NRBTS/NRDRX-5:drxInactivityTimer=10ms
...    NRBTS/NRDRX-5:drxLongCycle=20ms
...    NRBTS/NRDRX-5:drxOnDurationTimer=10ms
...    NRBTS/NRDRX-5:drxRetransTimerDl=0slot
...    NRBTS/NRDRX-5:drxRetransTimerUl=0slot
...    NRBTS/NRDRX-5:drxPriority=2
...    NRBTS/NRDRX-6:drxHarqRttTimerDl=0symbols
...    NRBTS/NRDRX-6:drxHarqRttTimerUl=0symbols
...    NRBTS/NRDRX-6:drxInactivityTimer=80ms
...    NRBTS/NRDRX-6:drxLongCycle=160ms
...    NRBTS/NRDRX-6:drxOnDurationTimer=10ms
...    NRBTS/NRDRX-6:drxPriority=4
...    NRBTS/NRDRX-6:drxRetransTimerDl=0slot
...    NRBTS/NRDRX-6:drxRetransTimerUl=0slot
...    NRBTS/NRDRX-7:drxHarqRttTimerDl=0symbols
...    NRBTS/NRDRX-7:drxHarqRttTimerUl=0symbols
...    NRBTS/NRDRX-7:drxInactivityTimer=80ms
...    NRBTS/NRDRX-7:drxLongCycle=160ms
...    NRBTS/NRDRX-7:drxOnDurationTimer=10ms
...    NRBTS/NRDRX-7:drxPriority=30
...    NRBTS/NRDRX-7:drxRetransTimerDl=0slot
...    NRBTS/NRDRX-7:drxRetransTimerUl=0slot
...    NRBTS/NRDRX-8:drxPriority=18
...    NRBTS/NRDRX-8:drxRetransTimerDl=0slot
...    NRBTS/NRDRX-8:drxRetransTimerUl=0slot
...    NRBTS/NRDRX-8:drxInactivityTimer=80ms
...    NRBTS/NRDRX-8:drxLongCycle=160ms
...    NRBTS/NRDRX-8:drxOnDurationTimer=20ms
...    NRBTS/NRDRX-10:drxHarqRttTimerDl=0symbols
...    NRBTS/NRDRX-10:drxHarqRttTimerUl=0symbols
...    NRBTS/NRDRX-10:drxInactivityTimer=8ms
...    NRBTS/NRDRX-10:drxLongCycle=20ms
...    NRBTS/NRDRX-10:drxOnDurationTimer=10ms
...    NRBTS/NRDRX-10:drxRetransTimerDl=0slot
...    NRBTS/NRDRX-10:drxRetransTimerUl=0slot
...    NRBTS/NRDRX-10:drxPriority=2
...    NRBTS/NRDRX-11:drxHarqRttTimerDl=0symbols
...    NRBTS/NRDRX-11:drxHarqRttTimerUl=0symbols
...    NRBTS/NRDRX-11:drxInactivityTimer=80ms
...    NRBTS/NRDRX-11:drxLongCycle=160ms
...    NRBTS/NRDRX-11:drxOnDurationTimer=10ms
...    NRBTS/NRDRX-11:drxPriority=16
...    NRBTS/NRDRX-11:drxRetransTimerDl=0slot
...    NRBTS/NRDRX-11:drxRetransTimerUl=0slot
...    NRCELL-1/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-2/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL:a2MeashoEnabledSA=rsrp
...    NRCELL:a1MeashoEnabledSA=rsrp
...    NRCELL:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=60
...    NRCELL:a1MeashoSsbRsrpSA:a1HysteresisHoSsbRsrpVoNr=${EMPTY}
...    NRCELL:a1MeashoSsbRsrpSA:a1ThresholdHoSsbRsrpVoNr=${EMPTY}
...    NRCELL:a1MeashoSsbRsrpSA:a1TimeToTriggerHoSsbRsrpVoNr=${EMPTY}
...    NRCELL:a2MeashoSsbRsrpSA:a2HysteresisHoSsbRsrpVoNr=${EMPTY}
...    NRCELL:a2MeashoSsbRsrpSA:a2ThresholdHoSsbRsrpVoNr=${EMPTY}
...    NRCELL:a2MeashoSsbRsrpSA:a2TimeToTriggerHoSsbRsrpVoNr=${EMPTY}
...    delete:NRCELL-1/NRREL-10
...    NRBTS/NRANRPR-2:anrThresRsrqNbCell=-24
...    NRBTS/NRANRPR-2:nrarfcn=518598
...    NRBTS/NRANRPR-2:ssbFrequency=518670


${Support_CGI}    SEPARATOR=
...    E9A09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C47007B8D85181AC1184341020E9068036B64C558D0E7C471E819F604F8C48
...    E3C873EA39F30C7942C0E070F05C00FFC007003FF0005C0000E0541B11B582308682041F28340125B262A82873E238F180000000000000000009FFF000007FFC0000
...    05C0000E000BC3C46000E140000000B01020060234028174001300C68912244D8E7C30050119E82C003E1C1401C0C02500700060240040603E008020000000100000
...    200B036B2A68020800004B29282000032CA4A00A81D552AAA16004800D028000020200400808020043543E00020406080C0E1416181A2022242628303236383A3E42
...    4A4C4E5052545A5E828305A0

@{Disable_DRX_and_Enable_CB008225}
...    NRCELL-1:actCDrx=false
...    NRCELL-1:actCDrxVoNR=false
...    NRBTS:actDedicatedAnrDrxProfile=false
...    NRBTS:actDisableUlProactGrantAnr=false
...    NRBTS:actSaIntraFreqAnrDrxProf=false
...    NRBTS:actSaUeBasedInterFreqAnrNr=false
...    NRBTS:actRrcInactState=intra-gNB
...    NRBTS:outOfConnectedPreference=inactive
...    NRBTS:rrcInactPreferredStateEnabled=true
...    NRBTS:actRrcReleasePreference=true
...    NRBTS:srbInactivityTimerSA=30

@{Enable_DRX}
...    NRCELL-1:actCDrx=true
...    NRCELL-1:actCDrxVoNR=true
...    NRBTS:actDedicatedAnrDrxProfile=true
...    NRBTS:actDisableUlProactGrantAnr=true
...    NRBTS:actSaIntraFreqAnrDrxProf=true
...    NRBTS:actSaUeBasedInterFreqAnrNr=true

@{Enable_VONR_DRX}
...    NRCELL-1:actCDrxVoNR=true
#CNI-105411
#...    MRBTS-2/NRBTS-2:actRtwpMeasurement=false
#...    MRBTS-2/MNL-1:tmpActFeat1=${EMPTY}
#...    NRCELL-2:configuredEpsTac=222
#...    NRCELL-1:ulProGrantTimer=1200
#...    NRCELLGRP-0:maxHarqMsg3Tx=5
...    delete:NRBTS/NRPMRNL-1/NRPMQAP-19
#...    NRBTS/NRSYSINFO_PROFILE-1:sibSchedulingList:sibBroadcastStatus=broadcasting|sibPeriodicity=rf8
#...    MRBTS-2/NRBTS-2:actNrpmqapProfiles=false

@{Disable_VONR_DRX}
...    NRCELL-1:actCDrxVoNR=false
#CNI-105411
#...    MRBTS-2/NRBTS-2:actRtwpMeasurement=true
#...    MRBTS-2/MNL-1:tmpActFeat1=1
#...    NRCELL-2:configuredEpsTac=200
#...    NRCELL-1:ulProGrantTimer=1300
#...    NRCELLGRP-0:maxHarqMsg3Tx=4
...    NRBTS/NRPMRNL-1/NRPMQAP-11:cfg5qiRange=6
...    NRBTS/NRPMRNL-1/NRPMQAP-19:cfg5qiRange=5,1
#...    NRBTS/NRSYSINFO_PROFILE-1:sibSchedulingList:sibBroadcastStatus=broadcasting|sibPeriodicity=rf16


${A001_voNRNrDrxDN_update}
...    NRCELL-1:voNRNrDrxDN=NRDRX-5

@{A002_drxOnDurationTimer_update}
...    NRBTS/NRDRX-1:drxOnDurationTimer=8ms

@{A006_Diable_cDRX_CELL_2}
...    NRCELL-2:actCDrx=false
...    NRCELL-2:actCDrxVoNR=false
...    delete:NRCELL-1/NRREL-256

@{A006_Enable_cDRX_CELL_2}
...    NRCELL-2:actCDrx=true
...    NRCELL-2:actCDrxVoNR=true
...    NRCELL:drxProfileNrAnr:nrDrxDN=NRDRX-3|drxControl=intraNR
...    NRCELL:drxProfileNrAnr:nrDrxDN=NRDRX-11|drxControl=intraNRFR2
...    NRCELL:drxProfileNrAnr:nrDrxDN=NRDRX-8|drxControl=intraNRSAinterFreq
...    NRCELL-2/NRREL-10:sCellAdditionMethod=blind

@{A004_voNRNrDrxDN_update}
...    NRCELL-1:voNRNrDrxDN=NRDRX-10
#CNI-105411
...    delete:NRBTS/NRPMRNL-1/NRPMQAP-11
#...    NRBTS/NRPMRNL-1/NRPMQAP-12:cfg5qiRange=6
#...    NRBTS/NRPMRNL-1/NRPMQAP-12:cfgArpRange=1-15
#...    NRBTS/NRPMRNL-1/NRPMQAP-12:cfgProfType=SA
#...    NRBTS/NRPMRNL-1/NRPMQAP-12:cfgPlmnId:mcc=311
#...    NRBTS/NRPMRNL-1/NRPMQAP-12:cfgPlmnId:mnc=489
#...    NRBTS/NRPMRNL-1/NRPMQAP-12:cfgPlmnId:mncLength=3
#...    NRBTS/NRPMRNL-1/NRPMQAP-12:cfgSliceId:sd=13714341
#...    NRBTS/NRPMRNL-1/NRPMQAP-12:cfgSliceId:sst=1
#...    MRBTS-2/NRBTS-2:actNrpmqapProfiles=true

${A004_Recover}
...    NRCELL-1:voNRNrDrxDN=MRBTS-2/NRBTS-2/NRDRX-2

@{A006_ANR_Recover}
...    delete:NRCELL-1/NRREL-256
...    NRCELL-2/NRREL-10:sCellAdditionMethod=covBasedA1

@{drxControl_Set_any}

...    NRCELL-1:drxProfileNrAnr:nrDrxDN=NRDRX-3|drxControl=intraNR
...    NRCELL-1:drxProfileNrAnr:nrDrxDN=NRDRX-11|drxControl=intraNRFR2
...    NRCELL-1:drxProfileNrAnr:nrDrxDN=NRDRX-8|drxControl=any
...    delete:NRCELL-1/NRREL-256

@{update_nrDrxDN}

...    NRCELL-1:drxProfileNrAnr:nrDrxDN=NRDRX-8|drxControl=intraNR
...    NRCELL-1:drxProfileNrAnr:nrDrxDN=NRDRX-11|drxControl=intraNRFR2
...    NRCELL-1:drxProfileNrAnr:nrDrxDN=NRDRX-8|drxControl=any

@{A001_onlinechange_nonGbrNrDrxDN}
...    NRCELL-1:nonGbrNrDrxDN=NRDRX-7

@{A001_Recovy_and_Disable_8225}
...    NRCELL-1:actCDrx=true
...    NRCELL-1:nonGbrNrDrxDN=NRDRX-1
...    NRBTS:actRrcInactState=none
...    NRBTS:outOfConnectedPreference=idle
...    NRBTS:rrcInactPreferredStateEnabled=false
...    NRBTS:actRrcReleasePreference=false
...    NRBTS:srbInactivityTimerSA=600
...    NRCELL-1:voNRNrDrxDN=MRBTS-2/NRBTS-2/NRDRX-2

@{A002_para_Recovy}
...    NRCELL-1:nonGbrNrDrxDN=NRDRX-1
...    NRBTS/NRDRX-1:drxOnDurationTimer=10ms

@{5QI6_PDU1_DRX1}
...    QoS Routing Table
...    Setup QosFlow with QFI:1 fiveQI:6
...    PDUSessionId:1
...    drx-onDurationTimer milliSeconds : ms10
...    drx-InactivityTimer ms10
...    drx-HARQ-RTT-TimerDL 0
...    drx-HARQ-RTT-TimerUL 0
...    drx-RetransmissionTimerDL sl0
...    drx-RetransmissionTimerUL sl0
...    drx-LongCycleStartOffset ms20
...    drx-SlotOffset 0

@{5QI1_PDU2}
...    QoS Routing Table
...    Added QosFlow with QFI:2 5QI:1
...    drx-Config release

@{5QI6_PDU1_Release_DRX2_Setup}
...    Successfully released PDU Session with ID 1
...    rrcReconfigurationComplete
...    drx-Config setup
...    drx-onDurationTimer milliSeconds : ms20
...    drx-InactivityTimer ms4
...    drx-HARQ-RTT-TimerDL 0
...    drx-HARQ-RTT-TimerUL 0
...    drx-RetransmissionTimerDL sl0
...    drx-RetransmissionTimerUL sl0
...    drx-LongCycleStartOffset ms40
...    drx-SlotOffset 0

@{meas_gap_setup_drx_release}
...    gapUE setup
...    rrcReconfigurationComplete
...    drx-Config release

@{meas_gap_setup}
...    gapUE setup
...    rrcReconfigurationComplete

@{meas_gap_release_DRX10_setup}
...    gapUE release
...    drx-onDurationTimer milliSeconds : ms10
...    drx-InactivityTimer ms8
...    drx-HARQ-RTT-TimerDL 0
...    drx-HARQ-RTT-TimerUL 0
...    drx-RetransmissionTimerDL sl0
...    drx-RetransmissionTimerUL sl0
...    drx-LongCycleStartOffset ms20
...    drx-SlotOffset 0

@{HO_From_Cell1_To_Cell2_DRX8_Setup}
...    Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.2 performed
...    rrcReconfigurationComplete
...    cellForWhichToReportCGI 50
...    drx-Config setup
...    drx-onDurationTimer milliSeconds : ms20
...    drx-InactivityTimer ms80
...    drx-HARQ-RTT-TimerDL 0
...    drx-HARQ-RTT-TimerUL 0
...    drx-RetransmissionTimerDL sl0
...    drx-RetransmissionTimerUL sl0
...    drx-LongCycleStartOffset ms160
...    drx-SlotOffset 0
...    drx-Config release : NULL

@{HO_From_Cell1_To_Cell2_DRX3_Setup}
...    Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.2 performed
...    rrcReconfigurationComplete
...    cellForWhichToReportCGI 50
...    drx-Config setup
...    drx-onDurationTimer milliSeconds : ms40
...    drx-InactivityTimer ms80
...    drx-HARQ-RTT-TimerDL 0
...    drx-HARQ-RTT-TimerUL 0
...    drx-RetransmissionTimerDL sl0
...    drx-RetransmissionTimerUL sl0
...    drx-LongCycleStartOffset ms320
...    drx-SlotOffset 0
...    drx-Config release : NULL

@{HO_From_Cell2_To_Cell1_DRX1_Setup}
...    Intra-eNB handover from EXT_ENB-2.2 to EXT_ENB-2.1 performed
...    rrcReconfigurationComplete
...    drx-Config setup
...    drx-onDurationTimer milliSeconds : ms10
...    drx-InactivityTimer ms10
...    drx-HARQ-RTT-TimerDL 0
...    drx-HARQ-RTT-TimerUL 0
...    drx-RetransmissionTimerDL sl0
...    drx-RetransmissionTimerUL sl0
...    drx-LongCycleStartOffset ms20
...    drx-SlotOffset 0

#case001
@{5QI9_PDU1}
...    QoS Routing Table
...    Setup QosFlow with QFI:1 5QI:9
...    PDUSessionId:1

@{RRE_to_cell1}
...    rrcReestablishmentComplete
...    pcid:60, scellIdx:0
...    rrcReconfigurationComplete
...    drx-onDurationTimer milliSeconds : ms10
...    drx-LongCycleStartOffset ms20

@{RRE_to_cell1_with_drx7}
...    rrcReestablishmentComplete
...    pcid:60, scellIdx:0
...    rrcReconfigurationComplete
...    drx-onDurationTimer milliSeconds : ms10
...    drx-LongCycleStartOffset ms160

@{5QI5_PDU2}
...    QoS Routing Table
...    Setup QosFlow with QFI:1 5QI:5
...    PDUSessionId:2

@{5QI5_PDU1_with_drx7}
...    QoS Routing Table
...    Added QosFlow with QFI:2 fiveQI:5
...    drx-Config setup
...    drx-onDurationTimer milliSeconds : ms10
...    drx-LongCycleStartOffset ms160

@{5QI1_PDU3}
...    QoS Routing Table
...    Adding QosFlow with QFI:1 5QI:1
#...    drx-Config release
...    drx-Config setup
...    drx-onDurationTimer milliSeconds : ms10
...    drx-LongCycleStartOffset ms20

@{5QI1_drop}
...    Deleting QosFlow with QFI:1 5QI:1
...    QoS Routing Table
...    rrcReconfigurationComplete
...    Pdu Session Resource Modify Response
...    drx-Config setup
...    drx-onDurationTimer milliSeconds : ms10
...    drx-LongCycleStartOffset ms160

@{5QI9_drop}
...    Removed FiveQi:Qfi mapping fiveQi 9 qfi 1
...    QoS Routing Table
...    rrcReconfigurationComplete
...    Pdu Session Resource Modify Response

@{INACTIVE_check}
...    SuspendConfig
...    fullI_RNTI
...    shortI_RNTI
...    ran-AreaCodeList
...    t380
...    UE1: Is INACTIVE

@{Nsa_5QI6_add_UE1}
...    reported successful RA
...    rrcConnectionReconfigurationComplete
...    drx-onDurationTimer milliSeconds : ms10
...    drx-LongCycleStartOffset ms20

@{Nsa_5QI6_add_UE2}
...    reported successful RA
...    rrcConnectionReconfigurationComplete
...    drx-onDurationTimer milliSeconds : ms10
...    drx-LongCycleStartOffset ms160

@{Nsa_5QI9_add}
...    rrcConnectionReconfigurationComplete
...    UE31: Successfully reconfigured dual connectivity
#...    drx-onDurationTimer milliSeconds : ms10
#...    drx-LongCycleStartOffset ms160

@{Nsa_5QI9_del}
...    UE31: Successfully reconfigured dual connectivity
...    rrcConnectionReconfigurationComplete

@{resum_success_cell1}
...    rrcResumeRequest1
...    rrcResumeComplete
...    pcid:60, scellIdx:0
...    rrcReconfigurationComplete
...    drx-Config setup
...    drx-onDurationTimer milliSeconds : ms10
...    drx-InactivityTimer ms80
...    drx-RetransmissionTimerDL sl0
...    drx-RetransmissionTimerUL sl0
...    drx-LongCycleStartOffset ms160

@{pm_counter_Check_A006}
...    NRBTS-2:LTEMO:${HO_ATT_UE_IN_DRX}=3
...    NRBTS-2:LTEMO:${HO_SUCC_UE_IN_DRX}=3
#CA XIAOXU
...    NRBTS-2/NRCELL-2:NCAC:${BLIND_SCELL_ADDED_SA}=2
...    NRBTS-2/NRCELL-2:NCAC:${A1_SCELL_ADDED_SA}=1
${BLIND_SCELL_ADDED_SA}    M55118C00033
${A1_SCELL_ADDED_SA}    M55118C00032

${HO_ATT_UE_IN_DRX}    M55128C01001    #Number of Handover attempts for UEs running in DRX mode
${HO_SUCC_UE_IN_DRX}    M55128C01002    #Number of successful Handover completions for UEs running in DRX mode

*** Test Cases ***
CB009109-5G-ET_A001_nonGBR_DRX1_installed_for_SA_call_setup_when_actDrbDrx_false
    [Documentation]
    ...    1. The purpose of this test case is to check following scenarios: Perform call setup (SA), with nonGBR (5QI-5) bearer then validate that
    ...    default NRDRX[1] instance can be used as the nonGBR DRX.
    ...    2. Configuration:
    ...       actCDrx = False
    ...    3. Test Case Steps:
    ...        1.UE register and attach to cell-1 with 5QI-9 bearer setup
    ...        2.Online change actCDrx to True and trigger RRE
    ...        3.Online change nonGbrNrDrxDN from NRDRX-1 to MRBTS-1/NRBTS-1/NRDRX-7, and add 5qi-5 and trigger RRE
    ...        4.Drop 5QI-9 and start traffic on 5QI-5
    ...        5.Wait for 30s for UE inactive, then start traffic again
    ...        6.Online change vonrNrDrxDN from NRDRX-2 to MRBTS-1/NRBTS-1/NRDRX-5, add 5QI-1
    ...        7.Drop 5QI-1
    ...    4. Expected Results:
    ...        1.No DRX installed becasuse actCDrx is false
    ...        2.actCDrx online changed and still no DRX for current UE. But NRDRX[1] is installed for UE after RRE succeed
    ...        3.NRDRX-1 keeps using before add 5qi-5, NRDRX-7 is used after add 5qi-5 and RRE
    ...        4.NRDRX-7 keeps using, and traffic started
    ...        5.NRDRX-7 released when ue in inactive state, and setup again when UE RRC resumed after start traffic
    ...        6.NRDRX-5 will be installed
    ...        7.NRDRX-5 will be uninstalled, NRDRX-7 will be used.
    [Tags]    A001    christine.chen    QC_361224
    OnlineParamChange    ${Disable_DRX_and_Enable_CB008225}
    Ue Attach to Cell1 with 5QI9    ue_id=1    pdu=1    pass_regexp=${5QI9_PDU1}
    Online enable DRX and RRE
    Online change nonGbrNrDrxDN and add 5QI5 then RRE
    Drop 5QI9 and start traffic on 5QI-5
    Trigger UE Inactive
    Trigger RRC Resume Success    ue_id=1
    Online change vonrNrDrxDN and add 5QI1
    Drop 5QI1
    [Teardown]    A001_Teardown

CB009109-5G-ET_A002_nonGBR_DRX1_installed_for_NSA_call_setup_when_actDrbDrx_false
    [Documentation]
    ...    1. The purpose of this test case is to check following scenarios: When CB009109 FAF NRTBS/actDrbDrx=False, nonGBR DRX value of NRDRX[1]
    ...    will be used in RRC Reconfiguration.In this case: Perform NSA call setup (SgNB addition Request). NSA call is setup successfully with
    ...    DRX (NRDRX[1]).
    ...    2. Configuration:
    ...       actCDrx = True
    ...    3. Test Case Steps:
    ...        1.UE register and attach to cell-1 with QCI-6 bearer setup
    ...        2.online change nonGbrNrDrxDN from NRDRX-1 to MRBTS-1/NRBTS-1/NRDRX-7, and add 5qi-9
    ...        3.online change drxOnDurationTimer for NRDRX-1, drop 5qi-9
    ...        4.Another UE register and attach to cell-1 with QCI-6 bearer setup
    ...    4. Expected Results:
    ...        1.UE attached and bearer QCI-6 setup, and nonGBR DRX profile NRDRX[1] is installed for the UE
    ...        2.NRDRX-7 is using
    ...        3.NRDRX-1 keeps using old value.
    ...        4.UE-2 attached and bearer QCI-6 setup, and nonGBR DRX profile NRDRX[7] is installed for the UE
    [Tags]    A002    christine.chen    QC_361223
    Nsa ue register with 5QI6    pass_regexp=${Nsa_5QI6_add_UE1}    ue_id=31
    OnlineParamChange    ${A001_onlinechange_nonGbrNrDrxDN}
    NSA add 5QI9
    OnlineParamChange    ${A002_drxOnDurationTimer_update}
    NSA dorp 5QI9
    Nsa ue register with 5QI6    pass_regexp=${Nsa_5QI6_add_UE2}    ue_id=32
    [Teardown]    A002_Teardown

CB009109-5G-ET_A004_VoNR_DRX_override_nonGBR_DRX_when_actDrbDrx_false
    [Documentation]
    ...    1. The purpose of this test case is to check following scenarios:
    ...       a. VoNR DRX configuration will override the nonGBR DRX configuration.
    ...       b. Online change of actCDrxVoNR and vonrNrDrxDN will take effect for the next transaction.
    ...    2. Configuration:
    ...       actCDrxVoNR = False
    ...    3. Test Case Steps:
    ...        1.UE register and attach to cell-1 and setup PDU-1 with 5QI-6 bearer setup.
    ...        2.Setup PDU-2 with 5qi-5.
    ...        3.Setup 5qi-1 within PDUSessionModify message to start VoNR.
    ...        4.Online change actCDrxVoNR to True and drop the pdu-1 with 5qi-6.
    ...        5.Online change vonrNrDrxDN from MRBTS-1/NRBTS-1/NRDRX-2 to NRDRX-10.
    ...        6.trigger measGap setup and release
    ...    4. Expected Results:
    ...        1.UE attached and bearer 5QI-6 setup, and nonGBR DRX profile NRDRX[1] is installed for the UE.
    ...        2.PDU2 with 5qi-5 setup successfully. NRDRX[1] keeps.
    ...        3.VoNR call setup successfully. NRDRX[1] is released since 5QI-1 cannot co-exist with common drx.
    ...        4.No drx setup after online change. Then PDU-1 is released and VoNR DRX NRDRX[2] is setup.
    ...        5.NRDRX[2] for VoNR keeps because vonrNrDrxDN online change will take effect on the next transaction.
    ...        6.NRDRX[10] for VoNR takes effect.
    [Tags]    A004    yejing    QC_361226
    OnlineParamChange    ${Disable_VONR_DRX}
    Ue Attach to Cell1 with 5QI6    ue_id=1    pdu=1    pass_regexp=${5QI6_PDU1_DRX1}
    Add PDU for VoNR Call To Cell1
    Send Throughput    ue_id=1
    OnlineParamChange    ${Enable_VONR_DRX}
    Release PDU1
    OnlineParamChange    ${A004_voNRNrDrxDN_update}
    Trigger UE A2 Measurement Report
    Trigger UE A1 Measurement Report
    Ue Attach to Cell1 with 5QI6    ue_id=2    pdu=3
    [Teardown]    A004 Teardown

CB009109-5G-ET_A006_ANR_DRX_override_nonGBR_DRX_and_released_after_inter_freq_HO_done_for_SA_call_when_actDrbDrx_false
    [Documentation]
    ...    1. This case is to verify the ANR DRX profile will be installed and uninstalled for interFreq HO of SA call.
    ...    2. Configuration:
    ...       NRBTS/NRCELL/nonGbrNrDrxDN = NRBTS/NRDRX[1].
    ...       NRBTS/NRCELL/vonrNrDrxDN = NRBTS/NRDRX[2].
    ...       NRBTS/NRCELL/drxProfileNrAnr[1].nrDrxDN = NRBTS/NRDRX[3].
    ...       NRBTS/NRCELL/drxProfileNrAnr[1].drxControl = intraNR.
    ...       NRBTS/NRCELL/drxProfileNrAnr[2].nrDrxDN = NRBTS/NRDRX[4].
    ...       NRBTS/NRCELL/drxProfileNrAnr[2].drxControl = intraNRFR2.
    ...       NRBTS/NRCELL/drxProfileNrAnr[3].nrDrxDN = NRBTS/NRDRX[8].
    ...       NRBTS/NRCELL/drxProfileNrAnr[3].drxControl = intraNRSAinterFreq.
    ...       NRCELL-1.actCDrx = True
    ...       NRCELL-2.actCDrx = False
    ...    3. Test Case Steps:
    ...        1.UE register and attach to cell-1 with 5QI-6 bearer setup.
    ...        2.trigger inter-freq handover with ANR to target cell-2.
    ...        3.trigger inter-freq handover back from cell-2 to cell-1.
    ...        4.online change NRCELL-1.drxProfileNrAnr[3].drxControl from intraNRSAintraFreq to any.
    ...        5.trigger inter-freq handover with ANR to target cell-2.
    ...        6.online change NRCELL-1.drxProfileNrAnr[1].nrDrxDN from NRDRX-3 to NRDRX-8.
    ...        7.trigger inter-freq handover back from cell-2 to cell-1.
    ...        8.trigger inter-freq handover with ANR to target cell-2.
    ...        9.check counters
    ...    4. Expected Results:
    ...        1.UE attached and bearer 5QI-6 setup, and nonGBR DRX profile NRDRX[1] is installed for the UE.
    ...        2.nonGBR DRX is uninstalled and drxProfileNrAnr[3] (NRDRX-8) is installed, then ANR DRX NRDRX-8 is uninstalled after
    ...          inter-freq handover compeletd and nonGBR DRX will not be installed due to actCDrx is false on cell-2.
    ...        3.ANR is not configured and inter-freq handover is trigger. nonGBR DRX is installed after HO.
    ...        4.NIDD online modified
    ...        5.nonGBR DRX is uninstalled and drxProfileNrAnr[1] (NRDRX-3) which is more dedicated is installed.after inter-freq handover
    ...          compeletd, ANR DRX NRDRX-3 is uninstalled and nonGBR DRX will not be installed due to actCDrx is false on cell-2.
    ...        6.NIDD online modified.
    ...        7.ANR is not configured and inter-freq handover is trigger. nonGBR DRX is installed after HO.
    ...        8.nonGBR DRX is uninstalled and drxProfileNrAnr[3] (NRDRX-8) is installed, then ANR DRX NRDRX-8 is uninstalled after
    ...          inter-freq handover compeletd and nonGBR DRX will not be installed due to actCDrx is false on cell-2.
    ...        9.check counters
    [Tags]    A006    yejing    QC_46908
    Clear Counter Files
    UE Attach to Cell1
    HO With ANR From Cell1 to Cell2
    HO From Cell2 to Cell1
    Remove ANR Generated NRREL and Online Change drxControl
    HO With ANR From Cell1 to Cell2    A3_pass_regexp=${HO_From_Cell1_To_Cell2_DRX3_Setup}
    OnlineParamChange    ${update_nrDrxDN}
    HO From Cell2 to Cell1
    Remove ANR Generated NRREL
    HO With ANR From Cell1 to Cell2
#CA XIAOXU
    Trigger UE A1 Measurement Report to add scell
    Execute Egate Command    data_trf_start ue=1 pdu=1 qfi=1 dir=dl trf_id=2 mbps=100    UE 1: UDP DL
    check counters    ${pm_counter_Check_A006}
    [Teardown]    A006 Teardown
*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/FS/3cells_1T2F

Modify Cfg
    Update Cfg    set_qosflow id=2 5qi=5
    Update Cfg    set_qosflow id=3 5qi=1
    Update Cfg    set_qosflow id=4 5qi=9
    Update Cfg    set_qosrule id=1 proto=tcp qos_flow=2
    Update Cfg    set_qosrule id=2 proto=udp qos_flow=3
    Update Cfg    set_nwslice id=1 qos_flows=1,2,3,4 qos_rules=1,2 snssai=0x01:0xD143A5 default=on ue=all amf=1
    Update Cfg    enb_param id=1 drb_id_begin=3 endc_capable_qci=all
    Update Cfg    set_bearer id=2 ue=31 qci=6 pdn=1 ip=4.7.254.208 default=on trf_type=internal
    Update Cfg    set_bearer id=2 ue=32 qci=6 pdn=1 ip=4.7.254.209 default=on trf_type=internal
    Update Cfg    set_bearer id=3 ue=31 qci=9 pdn=1 default=off preprovisioned=on filter=3 precedence=3
    Update Cfg    set_bearer id=3 ue=32 qci=9 pdn=1 default=off preprovisioned=on filter=3 precedence=3
    Update Cfg    set_bearer id=4 ue=31 qci=7 pdn=1 default=off preprovisioned=on filter=4 precedence=4

A001_Teardown
    OnlineParamChange    ${A001_Recovy_and_Disable_8225}
    Common Test Teardown And Stop Capture Logs

A002_Teardown
    OnlineParamChange    ${A002_para_Recovy}
    Common Test Teardown And Stop Capture Logs

A004 Teardown
    OnlineParamChange    ${A004_Recover}
    Common Test Teardown And Stop Capture Logs

UE Attach to Cell1
    OnlineParamChange    ${A006_Diable_cDRX_CELL_2}
    Update UE capa    ${Support_CGI}
    Ue Attach to Cell1 with 5QI6    ue_id=1    pdu=1    pass_regexp=${5QI6_PDU1_DRX1}

Remove ANR Generated NRREL and Online Change drxControl
    Object Should Exist    NRCELL-1/NRREL-256:gNbId=2
    OnlineParamChange    ${drxControl_Set_any}

Remove ANR Generated NRREL
    Object Should Exist    NRCELL-1/NRREL-256:gNbId=2
    OnlineParamChange    ${A006_ANR_Recover}

A006 Teardown
    OnlineParamChange    ${A006_Enable_cDRX_CELL_2}
    Common Test Teardown And Stop Capture Logs

Ue Attach to Cell1 with 5QI6
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${nwslice}=1    ${pass_regexp}=${EMPTY}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=1
    ${core_assis_info}    catenate    amf_ue_ics_param id=1 core_network_assistance_info=on ue_identity_index_value=${ue_id} ue_specific_drx=64
    ...    periodic_registration_update_timer=1:10min plmn_id=311:489 tac_id=200
    Execute Egate Command    ${core_assis_info}
    Execute Egate Command    qosflow_modify qos_flow=1 default=on
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=UE now in NG RM Registered
    execute egate command    set_pdu_param ue=${ue_id} pdu=${pdu} trf_type=internal
    execute egate command    ue_pdu_session_setup pdu=${pdu} ue=${ue_id} nwslice=${nwslice} gw=${pdu}    ${pass_regexp}
	Send Throughput    ue_id=${ue_id}

Ue Attach to Cell1 with 5QI9
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${nwslice}=1    ${pass_regexp}=${EMPTY}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=1
    ${core_assis_info}    catenate    amf_ue_ics_param id=1 core_network_assistance_info=on ue_identity_index_value=${ue_id} ue_specific_drx=64
    ...    periodic_registration_update_timer=1:10min plmn_id=311:489 tac_id=200
    Execute Egate Command    ${core_assis_info}
    Execute Egate Command    qosflow_modify qos_flow=4 default=on
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=UE now in NG RM Registered
    execute egate command    set_pdu_param ue=${ue_id} pdu=${pdu} trf_type=internal
    ${ret}    execute egate command    ue_pdu_session_setup pdu=${pdu} ue=${ue_id} nwslice=${nwslice} gw=${pdu}    ${pass_regexp}
    Should Not Contain    ${ret}    drx
    Send Throughput

Online enable DRX and RRE
    OnlineParamChange    ${Enable_DRX}
    Execute Egate Command    ue_rrc_reestablish id=1 gnb=2 cell=1 cause=reconfigurationFailure
    ...    pass_regexp=${RRE_to_cell1}

Online change nonGbrNrDrxDN and add 5QI5 then RRE
    OnlineParamChange    ${A001_onlinechange_nonGbrNrDrxDN}
    ${ret}    Execute Egate Command    ue_pdu_session_modify ue=1 pdu=1 qosflows_to_add=2 by=amf    pass_regexp=${5QI5_PDU1_with_drx7}
    Execute Egate Command    ue_rrc_reestablish id=1 gnb=2 cell=1 cause=reconfigurationFailure
    ...    pass_regexp=${RRE_to_cell1_with_drx7}

Set x2 gnb link up
    Execute Egate Command    enb_x2_link_up enb=1 target=2    ENB-1: X2AP Link with GNB-2

Nsa ue register with 5QI6
    [Arguments]    ${pass_regexp}    ${ue_id}=31
    Set x2 gnb link up
    Execute Egate Command    ue_attach id=${ue_id}    UE IS ACTIVE
    Execute Egate Command    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=1 bearer=2 type=split_scg    pass_regexp=${pass_regexp}

Send Throughput NSA
    [Arguments]    ${ue_id}=11    ${times}=1    ${mbps}=150
    Execute Egate Command    trf_data_start ue=${ue_id} id=2 dir=ul mbps=10 trf_id=1    UE ${ue_id}: UDP UL
    FOR    ${I}    IN RANGE    1    ${times}+1
        Execute Egate Command    trf_data_start ue=${ue_id} id=2 dir=dl mbps=${mbps} trf_id=${I}    UE ${ue_id}: UDP DL
	END

Add PDU for VoNR Call To Cell1
    [Arguments]    ${ue_id}=1    ${pdu}=2
    Execute Egate Command    qosflow_modify qos_flow=2 default=on
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu} trf_type=internal
    ${ret}    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu} nwslice=1 gw=${pdu}    pass_regexp=${5QI5_PDU2}
    Should Not Contain    ${ret}    drx
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu} qosflows_to_add=3 by=amf    pass_regexp=${5QI1_PDU2}

Release PDU1
    [Arguments]    ${ue_id}=1    ${pdu}=1
    ${ret}    Execute Egate Command    ue_pdu_session_release ue=${ue_id} pdu=${pdu} by=amf    pass_regexp=${5QI6_PDU1_Release_DRX2_Setup}

Online change vonrNrDrxDN and add 5QI1
    [Arguments]    ${ue_id}=1    ${pdu}=1
    OnlineParamChange    ${A001_voNRNrDrxDN_update}
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu} qosflows_to_add=3 by=amf    pass_regexp=${5QI1_PDU3}

NSA add 5QI9
    [Arguments]    ${ue_id}=31
    Execute Egate Command    enb_ue_dc_modify ue=${ue_id} bearer_to_add=3 by=enb cause=RN_CauseRadioNetwork_unspecified type=split_scg
    ...    pass_regexp=${Nsa_5QI9_add}

NSA dorp 5QI9
    [Arguments]    ${ue_id}=31
    Execute Egate Command    enb_ue_dc_modify ue=${ue_id} bearer_to_release=3 by=enb cause=MISC_CauseMisc_unspecified type=split_scg
    ...    pass_regexp=${Nsa_5QI9_del}    fail_regexp=drx

Drop 5QI9 and start traffic on 5QI-5
    [Arguments]    ${ue_id}=1    ${pdu}=1
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu} qosflows_to_del=4 by=ue    pass_regexp=${5QI9_drop}
    ...    fail_regexp=drx
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=3 mbps=1    UE ${ue_id}: UDP DL

Drop 5QI1
    [Arguments]    ${ue_id}=1    ${pdu}=1
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu} qosflows_to_del=3 by=ue    pass_regexp=${5QI1_drop}

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir

Trigger UE Inactive
    [Arguments]    ${ue_id}=1
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=1 qfi=1 dir=dl
    ...    pass_regexp=${INACTIVE_check}    timeout=31s

Trigger RRC Resume Success
    [Arguments]    ${ue_id}=1
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=2 dir=dl trf_id=4 mbps=1    pass_regexp=${resum_success_cell1}

Send Throughput
    [Arguments]    ${ue_id}=1    ${mbps}=10
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=2 mbps=${mbps}    UE ${ue_id}: UDP DL

HO With ANR From Cell1 to Cell2
    [Arguments]    ${A3_pass_regexp}=${HO_From_Cell1_To_Cell2_DRX8_Setup}
    Trigger UE A2 Measurement Report
    sleep    4s    sleep for command execute
    Trigger UE A3 Measurement Report Without nonGBR DRX Setup    pass_regexp=${A3_pass_regexp}

HO From Cell2 to Cell1
    Trigger UE A2 Measurement Report    carrierfreq=518670
    Trigger UE A3 Measurement Report    carrierfreq=127210    phycell_id=60    pass_regexp=${HO_From_Cell2_To_Cell1_DRX1_Setup}

Trigger UE A2 Measurement Report
    [Arguments]    ${ue_id}=1    ${carrierfreq}=127210
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A2
    ${V3}    catenate
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 srsrp_nr=11 srsrq_nr=11
    Execute Egate Command    ${V3}    pass_regexp=${meas_gap_setup}

Trigger UE A1 Measurement Report to add scell
    [Arguments]    ${ue_id}=1    ${carrierfreq}=518670
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A1
    ${CA_A1}    catenate
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=100 srsrq_nr=80
    Execute Egate Command    ${CA_A1}    sCellToAddModList

Trigger UE A1 Measurement Report
    [Arguments]    ${ue_id}=1    ${carrierfreq}=127210
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A1
    ${V3}    catenate
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=80 srsrq_nr=80
    Execute Egate Command    ${V3}    ${meas_gap_release_DRX10_setup}

Trigger UE A3 Measurement Report
    [Arguments]    ${ue_id}=1    ${carrierfreq}=518670    ${phycell_id}=50    ${pass_regexp}=${HO_From_Cell1_To_Cell2_DRX8_Setup}
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A3
    ${V3}    catenate
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=${phycell_id} nrsrp_nr=100 nrsrq_nr=100
    ...    rs_type=ssb index=0 nrs_result=30:30:30
    ${ret}    Execute Egate Command    ${V3}    ${pass_regexp}
    Should Not Contain    ${ret}    reportType reportCGI

Trigger UE A3 Measurement Report Without nonGBR DRX Setup
    [Arguments]    ${ue_id}=1    ${carrierfreq}=518670    ${phycell_id}=50    ${pass_regexp}=${HO_From_Cell1_To_Cell2_DRX8_Setup}
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A3
    ${V3}    catenate
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=${phycell_id} nrsrp_nr=100 nrsrq_nr=100
    ...    rs_type=ssb index=0 nrs_result=30:30:30
    ${ret}    Execute Egate Command    ${V3}    ${pass_regexp}
    Should Not Contain    ${ret}    drx-LongCycleStartOffset ms20

Update UE capa
    [Arguments]    ${SA_Capa_perUE_Full}=none    ${ue_id}=1
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full}
    Execute Egate Command    ${cmd}
