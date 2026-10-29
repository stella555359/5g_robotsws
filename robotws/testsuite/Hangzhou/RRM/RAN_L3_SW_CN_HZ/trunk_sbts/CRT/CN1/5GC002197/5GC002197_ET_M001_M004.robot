*** Settings ***
Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN  QCP_RAN_ET  SBTS00  RAN_5G  RAN_5G_FDD  CRT  CLOUD_5G_I_MP_AP_LO    VARIANT_SANSA_FS_CPRI_CMWV_FDD  team-SG2
...               owner-flora.du  release-SBTS00
Resource          ../../../../resources/DevHZ5_resource.robot
*** Variables ***
@{PARAMS_IN_SCF}
...    @{paramsForCaseM001}
...    @{paramsForCaseM004}
...    MRBTS-1/MNL-1/MNLENT-1/SECADM-1:sshSessionIdleTimer=0
...    NRBTS:sgnbRelForNoHandoverEnabled=false
...    NRBTS:shutdownNoX2TrafficTmr=12
...    NRBTS:shutdownNoXnTrafficTmr=2
...    NRBTS:shutdownNogNBCellTmr=30
...    NRBTS:tDCoverall=5000
...    NRBTS:tDiscardLteTimer=300
...    NRBTS:tRLFindForDU=2000ms
...    NRBTS:timerX2UeProcGuard=5000

${SNAPSHOT_FLAG}     pass:True,fail:True
${SOS_REPORT_FLAG}    pass:True,fail:True

@{paramsForCaseM001}
...    @{frequencyAndBandwidth}
...    @{bwpProfile252Config}
...    @{bwpProfile253CommonConfig}
...    @{bwpProfile253DedicateConfig}
...    NRCELL-1:actPrachMultiplexing=false
...    NRCELL-1:ccLoadThreshold=30
...    NRCELL-1:dllaIniMcs=27
...    NRCELL-1:ullaIniMcs=27
...    NRCELL-1:nrofHARQProcessesForPDSCH=8
...    NRCELL-1:pMax=380
...    NRCELL-1:raResponseWindow=sl80
...    NRCELL-1:rlpDetCsiBsiThreshold=75
...    NRCELL-1:ssPbchBlockPower=15
...    NRCELL-1:ulDMRSAdditionalPosition=No additional DMRS
...    NRCELL-1:ulSchedTimeInterval=40
...    NRCELL-1:periodicCsiAcquisition:csiReportPeriodicity=slots160
...    NRCELL-1:ulPowerControlCommon:p0NominalPucch=-82
...    NRCELL-1:ulPowerControlCommon:p0NominalPusch=-72
...    NRCELL-1:ulPowerControlCommon:p0NominalSrs=-72
...    MRBTS/NRBTS/NRCELL-1:cellBwpList:bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-252|cellBwpId=0
...    MRBTS/NRBTS/NRCELL-1:cellBwpList:bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-253|cellBwpId=1
...    MRBTS/NRBTS/NRCELL-1:nrSysInfoProfileDN=MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1
...    NRBTS/NRSYSINFO_PROFILE-1:systemInformationTargetRate=0
...    NRBTS/NRSYSINFO_PROFILE-1:addHystSfHigh=dB-2
...    NRBTS/NRSYSINFO_PROFILE-1:addHystSfMedium=dB-2
...    NRBTS/NRSYSINFO_PROFILE-1:nCellChangeHigh=16
...    NRBTS/NRSYSINFO_PROFILE-1:nCellChangeMedium=15
...    NRBTS/NRSYSINFO_PROFILE-1:tEvaluation=s30
...    NRBTS/NRSYSINFO_PROFILE-1:tHystNormal=s30
...    NRBTS/NRSYSINFO_PROFILE-1/NRIAFIM-1:sIntraSearchQ=0
...    NRBTS/NRSYSINFO_PROFILE-1/NRIRFIM-1:qOffsetFreq=-4dB
...    NRBTS/NRSYSINFO_PROFILE-1/NRIRFIM-1:qRxLevMin=-56
...    NRBTS/NRSYSINFO_PROFILE-1/NRIRFIM-1:threshXHighQ=30
...    NRBTS/NRSYSINFO_PROFILE-1/NRIRFIM-1:threshXLowQ=22
...    NRBTS/NRSYSINFO_PROFILE-1/NRLIM-1:threshXHigh=10

@{paramsForCaseM004}
...    @{frequencyAndBandwidthM004}
...    @{bwpProfile254Config}
...    @{bwpProfile255CommonConfig}
...    @{bwpProfile255DedicateConfig}
...    MRBTS/NRBTS/NRCELL-2:cellBwpList:bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-254|cellBwpId=0
...    MRBTS/NRBTS/NRCELL-2:cellBwpList:bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-255|cellBwpId=1
...    MRBTS/NRBTS/NRCELL-2:nrSysInfoProfileDN=MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-2
...    NRBTS/NRSYSINFO_PROFILE-2:systemInformationTargetRate=0
...    NRBTS/NRSYSINFO_PROFILE-2:addHystSfHigh=dB-2
...    NRBTS/NRSYSINFO_PROFILE-2:addHystSfMedium=dB-2
...    NRBTS/NRSYSINFO_PROFILE-2:nCellChangeHigh=16
...    NRBTS/NRSYSINFO_PROFILE-2:nCellChangeMedium=15
...    NRBTS/NRSYSINFO_PROFILE-2/NRIAFIM-1:sIntraSearchQ=0
...    NRBTS/NRSYSINFO_PROFILE-2/NRIRFIM-1:qOffsetFreq=-4dB
...    NRBTS/NRSYSINFO_PROFILE-2/NRIRFIM-1:qRxLevMin=-56
...    NRBTS/NRSYSINFO_PROFILE-2/NRIRFIM-1:threshXHighQ=30
...    NRBTS/NRSYSINFO_PROFILE-2/NRIRFIM-1:threshXLowQ=22
...    NRBTS/NRSYSINFO_PROFILE-2/NRLIM-1:threshXHigh=10
...    NRBTS/NRSYSINFO_PROFILE-2:tEvaluation=s30
...    NRBTS/NRSYSINFO_PROFILE-2:tHystNormal=s30

@{frequencyAndBandwidth}
...    NRCELL-1:gscnOrSsPbchArfcn=1547
...    NRCELL-1:type0CoresetConfigurationIndex=0
...    NRCELL-1/NRCELL_FDD-1:chBwDl=5MHz
...    NRCELL-1/NRCELL_FDD-1:chBwUl=5MHz
...    NRCELL-1/NRCELL_FDD-1:nrarfcnDl=123940
...    NRCELL-1/NRCELL_FDD-1:nrarfcnUl=136100

@{frequencyAndBandwidthM004}
...    NRCELL-2:gscnOrSsPbchArfcn=1587
...    NRCELL-2:type0CoresetConfigurationIndex=7
...    NRCELL-2/NRCELL_FDD-1:chBwDl=10MHz
...    NRCELL-2/NRCELL_FDD-1:chBwUl=10MHz
...    NRCELL-2/NRCELL_FDD-1:nrarfcnDl=126900
...    NRCELL-2/NRCELL_FDD-1:nrarfcnUl=136100

@{bwpProfile252Config}
...    NRBTS/BWP_PROFILE-252:bwpType=initial
...    NRBTS/BWP_PROFILE-252:locationAndBandwidthDl:cRbSizeDl=coreset0
...    NRBTS/BWP_PROFILE-252:locationAndBandwidthDl:cRbStartDl=coreset0
...    NRBTS/BWP_PROFILE-252:locationAndBandwidthUl:cRbSizeUl=allRb
...    NRBTS/BWP_PROFILE-252:locationAndBandwidthUl:cRbStartUl=crb0
...    MRBTS/NRBTS/BWP_PROFILE-252/PDCCH-1:alSelection=static
...    MRBTS/NRBTS/BWP_PROFILE-252/PDCCH-1:dciDedicatedAggregationLevel=AL4
...    MRBTS/NRBTS/BWP_PROFILE-252/PDCCH-1:dciPagingAggregationLevel=AL4
...    MRBTS/NRBTS/BWP_PROFILE-252/PDCCH-1:dciRaCompletionAggregationLevel=AL4
...    MRBTS/NRBTS/BWP_PROFILE-252/PDCCH-1:dciRaMsg2AggregationLevel=AL4
...    MRBTS/NRBTS/BWP_PROFILE-252/PDCCH-1:dciSiAggregationLevel=AL4
...    MRBTS/NRBTS/BWP_PROFILE-252/PDCCH-1:downgradeAL16toAL8=notAllowed
...    NRBTS/BWP_PROFILE-252/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-252/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-252/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=1
...    NRBTS/BWP_PROFILE-252/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-252/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-252/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-252/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=1
...    NRBTS/BWP_PROFILE-252/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-252/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=1
...    NRBTS/BWP_PROFILE-252/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=1
...    NRBTS/BWP_PROFILE-252/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-252/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-252/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-252/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-252/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-252/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-252/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-252/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=2
...    NRBTS/BWP_PROFILE-252/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-252/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-252/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-252/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-252/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-252/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-252/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=3
...    NRBTS/BWP_PROFILE-252/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-252/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-252/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-252/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=3
...    NRBTS/BWP_PROFILE-252/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-252/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=3
...    NRBTS/BWP_PROFILE-252/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=3
...    NRBTS/BWP_PROFILE-252/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=3

@{bwpProfile253CommonConfig}
...    NRBTS/BWP_PROFILE-253:bwpType=dedicated
...    NRBTS/BWP_PROFILE-253:locationAndBandwidthDl:cRbSizeDl=allRb
...    NRBTS/BWP_PROFILE-253:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-253:locationAndBandwidthUl:cRbSizeUl=allRb
...    NRBTS/BWP_PROFILE-253:locationAndBandwidthUl:cRbStartUl=crb0
...    MRBTS/NRBTS/BWP_PROFILE-253/PDCCH-1:alSelection=static
...    MRBTS/NRBTS/BWP_PROFILE-253/PDCCH-1:dciDedicatedAggregationLevel=AL4
...    MRBTS/NRBTS/BWP_PROFILE-253/PDCCH-1:dciPagingAggregationLevel=AL4
...    MRBTS/NRBTS/BWP_PROFILE-253/PDCCH-1:dciRaCompletionAggregationLevel=AL4
...    MRBTS/NRBTS/BWP_PROFILE-253/PDCCH-1:dciRaMsg2AggregationLevel=AL4
...    MRBTS/NRBTS/BWP_PROFILE-253/PDCCH-1:dciSiAggregationLevel=AL4
...    MRBTS/NRBTS/BWP_PROFILE-253/PDCCH-1:downgradeAL16toAL8=notAllowed
...    NRBTS/BWP_PROFILE-253/PDSCH-1:pdschRat0RbgConfig=config1
...    NRBTS/BWP_PROFILE-253/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-253/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-253/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=4
...    NRBTS/BWP_PROFILE-253/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-253/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-253/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-253/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=4
...    NRBTS/BWP_PROFILE-253/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-253/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=4
...    NRBTS/BWP_PROFILE-253/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=4
...    NRBTS/BWP_PROFILE-253/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-253/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-253/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-253/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-253/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-253/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-253/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-253/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=5
...    NRBTS/BWP_PROFILE-253/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-253/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-253/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-253/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-253/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-253/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-253/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=6
...    NRBTS/BWP_PROFILE-253/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-253/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-253/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-253/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=6
...    NRBTS/BWP_PROFILE-253/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-253/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=6
...    NRBTS/BWP_PROFILE-253/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=6
...    NRBTS/BWP_PROFILE-253/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=6

@{bwpProfile253DedicateConfig}
...    NRBTS/BWP_PROFILE-253/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cceToRegMapping=interleaved
...    NRBTS/BWP_PROFILE-253/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:coresetId=4
...    NRBTS/BWP_PROFILE-253/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cRbStart=0
...    NRBTS/BWP_PROFILE-253/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:duration=1
...    NRBTS/BWP_PROFILE-253/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:interleaverSize=n3
...    NRBTS/BWP_PROFILE-253/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:regBundleSize=n2
...    NRBTS/BWP_PROFILE-253/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=24
...    NRBTS/BWP_PROFILE-253/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=4|searchSpaceId=7
...    NRBTS/BWP_PROFILE-253/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-0-And-1-0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-253/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|searchSpaceId=7
...    NRBTS/BWP_PROFILE-253/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_2|searchSpaceId=7
...    NRBTS/BWP_PROFILE-253/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-253/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-253/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-253/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|searchSpaceId=7
...    NRBTS/BWP_PROFILE-253/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-253/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|searchSpaceId=7
...    NRBTS/BWP_PROFILE-253/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|searchSpaceId=7
...    NRBTS/BWP_PROFILE-253/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-253/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=4|searchSpaceId=8
...    NRBTS/BWP_PROFILE-253/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-0-And-1-0|searchSpaceId=8
...    NRBTS/BWP_PROFILE-253/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|searchSpaceId=8
...    NRBTS/BWP_PROFILE-253/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_2|searchSpaceId=8
...    NRBTS/BWP_PROFILE-253/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|searchSpaceId=8
...    NRBTS/BWP_PROFILE-253/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceId=8
...    NRBTS/BWP_PROFILE-253/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|searchSpaceId=8
...    NRBTS/BWP_PROFILE-253/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|searchSpaceId=8
...    NRBTS/BWP_PROFILE-253/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceId=8
...    NRBTS/BWP_PROFILE-253/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|searchSpaceId=8
...    NRBTS/BWP_PROFILE-253/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|searchSpaceId=8
...    NRBTS/BWP_PROFILE-253/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|searchSpaceId=8
...    NRBTS/BWP_PROFILE-253/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-253/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-0-And-1-0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-253/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|searchSpaceId=9
...    NRBTS/BWP_PROFILE-253/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-253/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-253/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-253/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-253/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|searchSpaceId=9
...    NRBTS/BWP_PROFILE-253/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-253/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|searchSpaceId=9
...    NRBTS/BWP_PROFILE-253/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|searchSpaceId=9
...    NRBTS/BWP_PROFILE-253/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-253/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-253/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|searchSpaceId=10
...    NRBTS/BWP_PROFILE-253/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|searchSpaceId=10
...    NRBTS/BWP_PROFILE-253/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-253/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-253/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-253/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-253/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|searchSpaceId=10
...    NRBTS/BWP_PROFILE-253/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-253/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|searchSpaceId=10
...    NRBTS/BWP_PROFILE-253/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|searchSpaceId=10
...    NRBTS/BWP_PROFILE-253/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|searchSpaceId=10

@{deltaParameterM001}
...    NRBTS/BWP_PROFILE-252/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=33
...    NRBTS/BWP_PROFILE-252/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=33
...    NRBTS/BWP_PROFILE-252/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=33
...    NRBTS/BWP_PROFILE-252/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=33
...    NRBTS/BWP_PROFILE-252/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=33
...    NRBTS/BWP_PROFILE-252/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=33
...    NRBTS/BWP_PROFILE-252/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=33
...    NRBTS/BWP_PROFILE-252/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=33
...    NRBTS/BWP_PROFILE-252/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=33
...    NRBTS/BWP_PROFILE-252/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=33
...    NRBTS/BWP_PROFILE-252/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=33
...    NRBTS/BWP_PROFILE-252/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-252/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-252/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-252/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-252/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-252/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-252/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=2
...    NRBTS/BWP_PROFILE-252/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-252/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-252/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-252/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-252/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-252/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-252/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=3
...    NRBTS/BWP_PROFILE-252/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-252/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-252/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-252/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=3
...    NRBTS/BWP_PROFILE-252/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-252/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=3
...    NRBTS/BWP_PROFILE-252/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=3
...    NRBTS/BWP_PROFILE-252/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=3

@{bwpProfile254Config}
...    NRBTS/BWP_PROFILE-254:bwpType=initial
...    NRBTS/BWP_PROFILE-254:locationAndBandwidthDl:cRbSizeDl=coreset0
...    NRBTS/BWP_PROFILE-254:locationAndBandwidthDl:cRbStartDl=coreset0
...    NRBTS/BWP_PROFILE-254:locationAndBandwidthUl:cRbSizeUl=allRb
...    NRBTS/BWP_PROFILE-254:locationAndBandwidthUl:cRbStartUl=crb0
...    MRBTS/NRBTS/BWP_PROFILE-254/PDCCH-1:alSelection=static
...    MRBTS/NRBTS/BWP_PROFILE-254/PDCCH-1:dciDedicatedAggregationLevel=AL4
...    MRBTS/NRBTS/BWP_PROFILE-254/PDCCH-1:dciPagingAggregationLevel=AL4
...    MRBTS/NRBTS/BWP_PROFILE-254/PDCCH-1:dciRaCompletionAggregationLevel=AL4
...    MRBTS/NRBTS/BWP_PROFILE-254/PDCCH-1:dciRaMsg2AggregationLevel=AL4
...    MRBTS/NRBTS/BWP_PROFILE-254/PDCCH-1:dciSiAggregationLevel=AL4
...    MRBTS/NRBTS/BWP_PROFILE-254/PDCCH-1:downgradeAL16toAL8=notAllowed
...    NRBTS/BWP_PROFILE-254/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-254/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-254/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=1
...    NRBTS/BWP_PROFILE-254/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-254/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-254/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-254/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=1
...    NRBTS/BWP_PROFILE-254/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-254/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=1
...    NRBTS/BWP_PROFILE-254/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=1
...    NRBTS/BWP_PROFILE-254/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-254/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-254/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-254/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-254/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-254/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-254/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-254/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=2
...    NRBTS/BWP_PROFILE-254/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-254/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-254/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-254/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-254/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-254/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-254/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=3
...    NRBTS/BWP_PROFILE-254/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-254/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-254/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-254/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=3
...    NRBTS/BWP_PROFILE-254/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-254/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=3
...    NRBTS/BWP_PROFILE-254/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=3
...    NRBTS/BWP_PROFILE-254/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=3

@{bwpProfile255CommonConfig}
...    NRBTS/BWP_PROFILE-255:bwpType=dedicated
...    NRBTS/BWP_PROFILE-255:locationAndBandwidthDl:cRbSizeDl=allRb
...    NRBTS/BWP_PROFILE-255:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-255:locationAndBandwidthUl:cRbSizeUl=allRb
...    NRBTS/BWP_PROFILE-255:locationAndBandwidthUl:cRbStartUl=crb0
...    MRBTS/NRBTS/BWP_PROFILE-255/PDCCH-1:alSelection=static
...    MRBTS/NRBTS/BWP_PROFILE-255/PDCCH-1:dciDedicatedAggregationLevel=AL4
...    MRBTS/NRBTS/BWP_PROFILE-255/PDCCH-1:dciPagingAggregationLevel=AL4
...    MRBTS/NRBTS/BWP_PROFILE-255/PDCCH-1:dciRaCompletionAggregationLevel=AL4
...    MRBTS/NRBTS/BWP_PROFILE-255/PDCCH-1:dciRaMsg2AggregationLevel=AL4
...    MRBTS/NRBTS/BWP_PROFILE-255/PDCCH-1:dciSiAggregationLevel=AL4
...    MRBTS/NRBTS/BWP_PROFILE-255/PDCCH-1:downgradeAL16toAL8=notAllowed
...    NRBTS/BWP_PROFILE-255/PDSCH-1:pdschRat0RbgConfig=config1
...    NRBTS/BWP_PROFILE-255/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-255/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-255/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=4
...    NRBTS/BWP_PROFILE-255/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-255/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-255/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-255/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=4
...    NRBTS/BWP_PROFILE-255/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-255/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=4
...    NRBTS/BWP_PROFILE-255/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=4
...    NRBTS/BWP_PROFILE-255/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-255/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-255/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-255/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-255/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-255/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-255/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-255/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=5
...    NRBTS/BWP_PROFILE-255/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-255/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-255/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-255/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-255/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-255/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-255/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=6
...    NRBTS/BWP_PROFILE-255/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-255/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-255/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-255/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=6
...    NRBTS/BWP_PROFILE-255/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-255/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=6
...    NRBTS/BWP_PROFILE-255/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=6
...    NRBTS/BWP_PROFILE-255/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=6

@{bwpProfile255DedicateConfig}
...    NRBTS/BWP_PROFILE-255/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cceToRegMapping=interleaved
...    NRBTS/BWP_PROFILE-255/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:coresetId=4
...    NRBTS/BWP_PROFILE-255/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cRbStart=0
...    NRBTS/BWP_PROFILE-255/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:duration=1
...    NRBTS/BWP_PROFILE-255/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:interleaverSize=n3
...    NRBTS/BWP_PROFILE-255/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:regBundleSize=n2
...    NRBTS/BWP_PROFILE-255/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=24
...    NRBTS/BWP_PROFILE-255/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=4|searchSpaceId=7
...    NRBTS/BWP_PROFILE-255/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-0-And-1-0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-255/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|searchSpaceId=7
...    NRBTS/BWP_PROFILE-255/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_2|searchSpaceId=7
...    NRBTS/BWP_PROFILE-255/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-255/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-255/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-255/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|searchSpaceId=7
...    NRBTS/BWP_PROFILE-255/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-255/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|searchSpaceId=7
...    NRBTS/BWP_PROFILE-255/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|searchSpaceId=7
...    NRBTS/BWP_PROFILE-255/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-255/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=4|searchSpaceId=8
...    NRBTS/BWP_PROFILE-255/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-0-And-1-0|searchSpaceId=8
...    NRBTS/BWP_PROFILE-255/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|searchSpaceId=8
...    NRBTS/BWP_PROFILE-255/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_2|searchSpaceId=8
...    NRBTS/BWP_PROFILE-255/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|searchSpaceId=8
...    NRBTS/BWP_PROFILE-255/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceId=8
...    NRBTS/BWP_PROFILE-255/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|searchSpaceId=8
...    NRBTS/BWP_PROFILE-255/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|searchSpaceId=8
...    NRBTS/BWP_PROFILE-255/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceId=8
...    NRBTS/BWP_PROFILE-255/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|searchSpaceId=8
...    NRBTS/BWP_PROFILE-255/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|searchSpaceId=8
...    NRBTS/BWP_PROFILE-255/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|searchSpaceId=8
...    NRBTS/BWP_PROFILE-255/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-255/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-0-And-1-0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-255/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|searchSpaceId=9
...    NRBTS/BWP_PROFILE-255/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-255/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-255/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-255/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-255/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|searchSpaceId=9
...    NRBTS/BWP_PROFILE-255/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-255/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|searchSpaceId=9
...    NRBTS/BWP_PROFILE-255/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|searchSpaceId=9
...    NRBTS/BWP_PROFILE-255/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-255/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-255/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|searchSpaceId=10
...    NRBTS/BWP_PROFILE-255/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|searchSpaceId=10
...    NRBTS/BWP_PROFILE-255/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-255/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-255/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-255/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-255/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|searchSpaceId=10
...    NRBTS/BWP_PROFILE-255/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-255/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|searchSpaceId=10
...    NRBTS/BWP_PROFILE-255/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|searchSpaceId=10
...    NRBTS/BWP_PROFILE-255/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|searchSpaceId=10


@{deltaParameterM004}
...    NRBTS/BWP_PROFILE-254/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=33
...    NRBTS/BWP_PROFILE-254/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=33
...    NRBTS/BWP_PROFILE-254/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=33
...    NRBTS/BWP_PROFILE-254/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=33
...    NRBTS/BWP_PROFILE-254/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=33
...    NRBTS/BWP_PROFILE-254/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=33
...    NRBTS/BWP_PROFILE-254/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=33
...    NRBTS/BWP_PROFILE-254/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=33
...    NRBTS/BWP_PROFILE-254/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=33
...    NRBTS/BWP_PROFILE-254/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=33
...    NRBTS/BWP_PROFILE-254/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=33
...    NRBTS/BWP_PROFILE-254/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-254/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-254/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-254/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-254/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-254/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-254/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=2
...    NRBTS/BWP_PROFILE-254/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-254/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-254/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-254/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-254/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-254/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-254/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=3
...    NRBTS/BWP_PROFILE-254/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-254/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-254/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-254/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=3
...    NRBTS/BWP_PROFILE-254/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-254/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=3
...    NRBTS/BWP_PROFILE-254/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=3
...    NRBTS/BWP_PROFILE-254/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=3

${ue_id_M001}    1
${ue_id_M004}    2

${GNB_BIP_FLAG}    True

*** Test Cases ***
5GC002197-ET-M001 Verify FDD 5MHz with SA UE attach in SA NSA cell and traffic in DL
    [Documentation]   5GC002197 Spillover of 5GC00742 System Information Broadcast intra NR Configuring dynamic PDCCH
    ...    This user scenario verifies FDD 5MHz with SA UE attach in SA+NSA cell and traffic in DL
    ...    Step1:    SA UE1 Register on 5Mhz FDD with BWP_PROFILE 252 and 253
    ...    Step2:    the UL and DL traffic should be OK
    ...    Step3:    trigger modify BWP parameters
    ...    Step4:    check initial BWP in SIB1 changed after modification period
    ...    Step5: check blow message in pcap message:
    ...           nr-rrc.searchSpaceId == 33
    ...           GNBDUConfigurationUpdateAcknowledge
    ...    Step6: SA Attach UE1 again
    ...    Step7: the UL and DL traffic should be OK
    [Tags]    QC_81123    Chendong.He
    SA Attach UE With External Traffic
    traffic should be ok    ue_id=${ue_id_M001}    pdu=1    type=SA
    Execute Egate Command    ue_deregister id=${ue_id_M001} ue_deregister_type=switch_off    UE${ue_id_M001}: detached
    #Iperf Dl Traffic Should Be Ok    ue_id=${ue_id_M001}    bw_thresh=90
    #Iperf Ul Traffic Should Be Ok    ue_id=${ue_id_M001}    bw_thresh=90
    Trigger Modify BWP Parameters
    sleep    3s
    Check Wireshark Log    ${CURDIR}${/}a2a_M001${/}a2a.ini    name=M001    wait_string=GNBDUConfigurationUpdateAcknowledge::6
    SA Attach UE With External Traffic
    traffic should be ok    ue_id=${ue_id_M001}    pdu=1    type=SA
    #Iperf Dl Traffic Should Be Ok    ue_id=${ue_id_M001}    bw_thresh=90
    #Iperf Ul Traffic Should Be Ok    ue_id=${ue_id_M001}    bw_thresh=90
    UE Deregister From GNB

5GC002197-ET-M004 Verify FDD 10MHz with SA UE attach in SA NSA cell and traffic in UL
    [Documentation]
    ...    1. Test Case Step:
    ...       Step1:    SA UE2 Register on 10Mhz FDD with BWP_PROFILE 254 and 255
    ...       Step2:    the UL and DL traffic should be OK
    ...       Step3:    trigger modify BWP parameters
    ...       Step4:    check initial BWP in SIB1 changed after modification period
    ...       Step5:    check blow message in pcap message:
    ...                      nr-rrc.searchSpaceId == 33
    ...                      GNBDUConfigurationUpdateAcknowledge
    ...       Step6:    SA UE2 register again
    ...       Step7:    the UL and DL traffic should be OK
    ...    2. Expected Result:
    ...        1. UE register success
    ...        2. Check the dedicated BWP in RRC Reconfig is same as changed
    [Tags]    QC_81124    Chendong.He
    SA Attach UE With External Traffic    ue_id=${ue_id_M004}    pdu_id=2    gw_id=2    cell_id=2
    traffic should be ok    ue_id=${ue_id_M004}    pdu=2    type=SA
    #Iperf Dl Traffic Should Be Ok    ue_id=${ue_id_M004}    bandwith=10M    bw_thresh=85
    #Iperf Ul Traffic Should Be Ok    ue_id=${ue_id_M004}    bandwith=10M    bw_thresh=85
    Trigger Modify BWP Parameters M004
    Check Wireshark Log    ${CURDIR}${/}a2a_M004${/}a2a.ini    name=M004    wait_string=GNBDUConfigurationUpdateAcknowledge::6
    SA Attach UE With External Traffic    ue_id=${ue_id_M004}    pdu_id=2    gw_id=2    cell_id=2
    traffic should be ok    ue_id=${ue_id_M004}    pdu=2    type=SA
    #Iperf Dl Traffic Should Be Ok    ue_id=${ue_id_M004}    bandwith=10M    bw_thresh=85
    #Iperf Ul Traffic Should Be Ok    ue_id=${ue_id_M004}    bandwith=10M    bw_thresh=85
    UE Deregister From GNB    ${ue_id_M004}

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fdd_sansa_cmwv/2cells

SA Attach UE With External Traffic
    [Arguments]    ${ue_id}=1    ${pdu_id}=1   ${gw_id}=1    ${cell_id}=1
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Reg
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=${gw_id} nwslice=1    QoS Routing Table

Trigger Modify BWP Parameters
    Start To Capture Wireshark Log    M001
    Delta Commission Parameters    ${deltaParameterM001}
    wait until keyword succeeds    3 min    10 sec    cells should be on air
    Wait Cell Has Sib Message    cell_id=1    sib_times=6

Trigger Modify BWP Parameters M004
    Start To Capture Wireshark Log    M004
    Delta Commission Parameters    ${deltaParameterM004}
    wait until keyword succeeds    3 min    10 sec    cells should be on air
    Wait Cell Has Sib Message    cell_id=2    sib_times=6

Wait Cell Has Sib Message
    [Arguments]    ${cell_id}    ${sib_times}=5
    Wait Until Keyword Succeeds    1min    2s    Check Cell Has Sib Message    cell_id=${cell_id}    sib_times=${sib_times}

Check Cell Has Sib Message
    [Arguments]    ${cell_id}    ${sib_times}=5
    ${ret}    Execute Egate Command    ib_enb_cell_disp enb=2 cell=${cell_id}    SIB
    Should Contain X Times    ${ret}    yes    ${sib_times}

UE Deregister From GNB
  [Arguments]  ${ue_id}=1
  Execute Egate Command  ue_deregister id=${ue_id} ue_deregister_type=switch_off  detached
