*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_VRF    SBTS00    RAN_5G    CLOUD_5G_I_MP_AP_LOOO    team-CN1ET
...    owner-Delun.Li    release-SBTS24R3    CRT
Resource    ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
${SYSCOM_FLAG}    ${True}
@{PARAMS_IN_SCF}
...    @{PARAMS_FOR_CA}
...    @{PARAMS_FOR_other}
...    @{PARAMS_FOR_NRCELL1}
...    @{PARAMS_FOR_8950}
...    @{PARAMS_FOR_8290}
...    @{PARAMS_FOR_8290_SCellSwap}
...    @{Cell_8x4_5GC2200}
...    @{LOCK_CELL_4}
...    @{bwpmodify}

@{PARAMS_IN_IPHY_XML}    identity:txAntCount=8|serialno=6Q182502976

@{LOCK_CELL_4}    NRCELL-4:administrativeState=Locked

@{bwpmodify}
...    NRBTS/BWP_PROFILE-1:bwpType=initial
...    NRBTS/BWP_PROFILE-1:locationAndBandwidthDl:cRbSizeDl=coreset0
...    NRBTS/BWP_PROFILE-1:locationAndBandwidthDl:cRbStartDl=coreset0
...    NRBTS/BWP_PROFILE-1:locationAndBandwidthUl:cRbSizeUl=allRb
...    NRBTS/BWP_PROFILE-1:locationAndBandwidthUl:cRbStartUl=crb0
...    NRBTS/BWP_PROFILE-1/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-1/PDCCH-1:dciDedicatedAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-1/PDCCH-1:dciPagingAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-1/PDCCH-1:dciRaCompletionAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-1/PDCCH-1:dciRaMsg2AggregationLevel=AL4
...    NRBTS/BWP_PROFILE-1/PDCCH-1:dciSiAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-1/PDCCH-1:downgradeAL16toAL8=notAllowed
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
...    NRBTS/BWP_PROFILE-27:bwpType=dedicated
...    NRBTS/BWP_PROFILE-27:locationAndBandwidthDl:cRbSizeDl=allRb
...    NRBTS/BWP_PROFILE-27:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-27:locationAndBandwidthUl:cRbSizeUl=sameAsDl
...    NRBTS/BWP_PROFILE-27:locationAndBandwidthUl:cRbStartUl=sameAsDl
...    NRBTS/BWP_PROFILE-27/PDSCH-1:pdschId=1
...    NRBTS/BWP_PROFILE-27/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-27/PDCCH-1:dciDedicatedAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-27/PDCCH-1:dciPagingAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-27/PDCCH-1:dciRaCompletionAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-27/PDCCH-1:dciRaMsg2AggregationLevel=AL4
...    NRBTS/BWP_PROFILE-27/PDCCH-1:dciSiAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-27/PDCCH-1:downgradeAL16toAL8=notAllowed
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=4
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=4
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=4
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=4
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=5
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=6
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=6
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=6
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=6
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-0-And-1-0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|searchSpaceId=7
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=7
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|searchSpaceId=7
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|searchSpaceId=7
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|searchSpaceId=7
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=0|searchSpaceId=8
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|searchSpaceId=8
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|searchSpaceId=8
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=8
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|searchSpaceId=8
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceId=8
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|searchSpaceId=8
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|searchSpaceId=8
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceId=8
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|searchSpaceId=8
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|searchSpaceId=8
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|searchSpaceId=8
...    NRCELL-11:cellBwpList:cellBwpId=0|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-1
...    NRCELL-11:cellBwpList:cellBwpId=1|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-27
...    NRCELL-12:cellBwpList:cellBwpId=0|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-1
...    NRCELL-12:cellBwpList:cellBwpId=1|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-27
...    NRCELL-11:maxNumPdschAllocationPerSlot=2
...    NRCELL-12:maxNumPdschAllocationPerSlot=2
...    NRCELL-13:maxNumPdschAllocationPerSlot=2
...    NRCELL-14:maxNumPdschAllocationPerSlot=2
...    NRCELL-15:maxNumPdschAllocationPerSlot=2
...    NRCELL-16:maxNumPdschAllocationPerSlot=2
...    NRCELL-17:maxNumPdschAllocationPerSlot=2
...    NRCELL-18:maxNumPdschAllocationPerSlot=2
...    NRCELL-19:maxNumPdschAllocationPerSlot=2
...    NRCELL-20:maxNumPdschAllocationPerSlot=2
...    NRCELL-21:maxNumPdschAllocationPerSlot=2
...    NRCELL-22:maxNumPdschAllocationPerSlot=2

@{PARAMS_FOR_NRCELL1}
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-2:gNbId=1
...    NRCELL-1/NRREL-2:gNbIdLength=22
...    NRCELL-1/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-2:handoverAllowedSARedCap=forbidden
...    NRCELL-1/NRREL-2:lcrId=2
...    NRCELL-1/NRREL-2:nrDcAllowed=false
...    NRCELL-1/NRREL-2:removeNotAllowed=false
...    NRCELL-1/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-2:isRplCellForPSCell=true
...    NRCELL-1/NRREL-5:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-5:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-5:gNbId=1
...    NRCELL-1/NRREL-5:gNbIdLength=22
...    NRCELL-1/NRREL-5:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-5:handoverAllowedSARedCap=forbidden
...    NRCELL-1/NRREL-5:lcrId=5
...    NRCELL-1/NRREL-5:nrDcAllowed=false
...    NRCELL-1/NRREL-5:removeNotAllowed=false
...    NRCELL-1/NRREL-5:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-5:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-5:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-5:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-5:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-5:isRplCellForPSCell=true
...    NRCELL-1/NRREL-11:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-11:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-11:gNbId=1
...    NRCELL-1/NRREL-11:gNbIdLength=22
...    NRCELL-1/NRREL-11:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-11:handoverAllowedSARedCap=forbidden
...    NRCELL-1/NRREL-11:lcrId=11
...    NRCELL-1/NRREL-11:nrDcAllowed=false
...    NRCELL-1/NRREL-11:removeNotAllowed=false
...    NRCELL-1/NRREL-11:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-11:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-11:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-11:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-11:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-11:isRplCellForPSCell=true
...    NRCELL-11:actK1Opt=intra-gNB
...    NRCELL-1/NRREL-12:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-12:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-12:gNbId=1
...    NRCELL-1/NRREL-12:gNbIdLength=22
...    NRCELL-1/NRREL-12:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-12:handoverAllowedSARedCap=forbidden
...    NRCELL-1/NRREL-12:lcrId=12
...    NRCELL-1/NRREL-12:nrDcAllowed=false
...    NRCELL-1/NRREL-12:removeNotAllowed=false
...    NRCELL-1/NRREL-12:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-12:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-12:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-12:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-12:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-12:isRplCellForPSCell=true
...    NRCELL-1/NRREL-15:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-15:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-15:gNbId=1
...    NRCELL-1/NRREL-15:gNbIdLength=22
...    NRCELL-1/NRREL-15:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-15:handoverAllowedSARedCap=forbidden
...    NRCELL-1/NRREL-15:lcrId=15
...    NRCELL-1/NRREL-15:nrDcAllowed=false
...    NRCELL-1/NRREL-15:removeNotAllowed=false
...    NRCELL-1/NRREL-15:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-15:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-15:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-15:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-15:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-15:isRplCellForPSCell=true
...    NRCELL-15:actK1Opt=intra-gNB
...    NRCELL-1/NRREL-19:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-19:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-19:gNbId=1
...    NRCELL-1/NRREL-19:gNbIdLength=22
...    NRCELL-1/NRREL-19:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-19:handoverAllowedSARedCap=forbidden
...    NRCELL-1/NRREL-19:lcrId=19
...    NRCELL-1/NRREL-19:nrDcAllowed=false
...    NRCELL-1/NRREL-19:removeNotAllowed=false
...    NRCELL-1/NRREL-19:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-19:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-19:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-19:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-19:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-19:isRplCellForPSCell=true
...    NRCELL-1/NRREL-20:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-20:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-20:gNbId=1
...    NRCELL-1/NRREL-20:gNbIdLength=22
...    NRCELL-1/NRREL-20:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-20:handoverAllowedSARedCap=forbidden
...    NRCELL-1/NRREL-20:lcrId=20
...    NRCELL-1/NRREL-20:nrDcAllowed=false
...    NRCELL-1/NRREL-20:removeNotAllowed=false
...    NRCELL-1/NRREL-20:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-20:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-20:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-20:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-20:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-20:isRplCellForPSCell=true
...    NRCELL-5/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-5/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-5/NRREL-1:gNbId=1
...    NRCELL-5/NRREL-1:gNbIdLength=22
...    NRCELL-5/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-5/NRREL-1:handoverAllowedSARedCap=forbidden
...    NRCELL-5/NRREL-1:lcrId=1
...    NRCELL-5/NRREL-1:nrDcAllowed=false
...    NRCELL-5/NRREL-1:removeNotAllowed=false
...    NRCELL-5/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-5/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-5/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-5/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-5/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-5/NRREL-1:isRplCellForPSCell=true
...    NRCELL-5/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-5/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-5/NRREL-3:gNbId=1
...    NRCELL-5/NRREL-3:gNbIdLength=22
...    NRCELL-5/NRREL-3:handoverAllowedSA=allowed
...    NRCELL-5/NRREL-3:handoverAllowedSARedCap=forbidden
...    NRCELL-5/NRREL-3:lcrId=3
...    NRCELL-5/NRREL-3:nrDcAllowed=false
...    NRCELL-5/NRREL-3:removeNotAllowed=false
...    NRCELL-5/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-5/NRREL-3:sCellOperationalMode=dlOnly
...    NRCELL-5/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-5/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-5/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-5/NRREL-3:isRplCellForPSCell=true
...    NRCELL-12:actK1Opt=intra-gNB
...    NRCELL-19:actK1Opt=intra-gNB
...    NRCELL-20:actK1Opt=intra-gNB
...    NRCELL-13:actK1Opt=intra-gNB
...    NRCELL-17:actK1Opt=intra-gNB
...    NRCELL-3:actK1Opt=intra-gNB
...    NRCELL-1/NRREL-5:sCellPrio=1
...    NRCELL-1/NRREL-15:sCellPrio=3
...    NRCELL-1/NRREL-2:sCellPrio=5
...    NRCELL-1/NRREL-11:sCellPrio=2
...    NRCELL-1/NRREL-12:sCellPrio=12
...    NRCELL-1/NRREL-19:sCellPrio=19
...    NRCELL-1/NRREL-20:sCellPrio=19
...    NRCELL-5/NRREL-1:sCellPrio=1
...    NRCELL-5/NRREL-3:sCellPrio=3
...    NRCELL:a1MeasSCellAddEnabled=rsrp
...    NRCELL:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=70|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=90|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a2MeasSCellRelEnabled=rsrp
...    NRCELL:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=480ms
...    NRCELL:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=50|a2TimeToTriggerSCellRelSsbRsrp=480ms

@{PARAMS_FOR_other}
...    NRBTS:actSaUeBasedAnrNr=false
...    NRANR-1:actAutoNrNbRemoval=false
...    NRCELL:actCDrx=false
...    NRBTS:cipherPrefL:nea0=8
...    NRBTS:cipherPrefL:nea1_128=0
...    NRBTS:cipherPrefL:nea2_128=0
...    NRBTS:cipherPrefL:nea3_128=0
...    NRBTS:actBbPoolExtensionTddFr1=true
...    NRBTS:srbInactivityTimerSA=60
...    NRCELL:filterCoeffSsbRsrq=fc4
...    NRBTS/NRSCTP-1:sctpProfile:sctpRtoInit=30000
...    NRBTS/NRSCTP-1:sctpProfile:sctpRtoMin=30000

@{PARAMS_FOR_CA}
...    NRBTS/NRDU-1:carrierAggregationSupportList=ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Sa
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRBTS:sCellActivationMethod=blind
...    NRCELL:sCellDeactivationTimerGNB=infinity

@{PARAMS_FOR_8950}
...    NRBTS:actFlexSCellSelectFr1=true
...    NRCELL:sCellDeactivationTimerGNB=infinity
...    NRBTS:sCellActivationMethod=blind
...    NRCELL-1/NRREL-6:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-6:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-6:gNbId=1
...    NRCELL-1/NRREL-6:gNbIdLength=22
...    NRCELL-1/NRREL-6:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-6:handoverAllowedSARedCap=forbidden
...    NRCELL-1/NRREL-6:lcrId=6
...    NRCELL-1/NRREL-6:nrDcAllowed=false
...    NRCELL-1/NRREL-6:removeNotAllowed=false
...    NRCELL-1/NRREL-6:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-6:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-6:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-6:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-6:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-6:isRplCellForPSCell=true
...    NRCELL-1/NRREL-13:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-13:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-13:gNbId=1
...    NRCELL-1/NRREL-13:gNbIdLength=22
...    NRCELL-1/NRREL-13:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-13:handoverAllowedSARedCap=forbidden
...    NRCELL-1/NRREL-13:lcrId=13
...    NRCELL-1/NRREL-13:nrDcAllowed=false
...    NRCELL-1/NRREL-13:removeNotAllowed=false
...    NRCELL-1/NRREL-13:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-13:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-13:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-13:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-13:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-13:isRplCellForPSCell=true
...    NRCELL-1/NRREL-17:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-17:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-17:gNbId=1
...    NRCELL-1/NRREL-17:gNbIdLength=22
...    NRCELL-1/NRREL-17:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-17:handoverAllowedSARedCap=forbidden
...    NRCELL-1/NRREL-17:lcrId=17
...    NRCELL-1/NRREL-17:nrDcAllowed=false
...    NRCELL-1/NRREL-17:removeNotAllowed=false
...    NRCELL-1/NRREL-17:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-17:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-17:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-17:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-17:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-17:isRplCellForPSCell=true
...    NRCELL-1/NRREL-17:sCellPrio=19
...    NRCELL-1/NRREL-6:sCellPrio=7
...    NRCELL-1/NRREL-13:sCellPrio=13

@{PARAMS_FOR_8290}
...    NRBTS:actMeasBasedSCellAdditionNsa=false
...    NRBTS:actSCellSwapFr1=a6BasedSa
...    NRCELL:a6MeasSCellSwapEnabled=rsrp
...    NRCELL:reportAmountA6MeasSCellSwap=r4
...    NRCELL:reportIntervalA6MeasSCellSwap=ms120
...    NRCELL:thresholdSCellSwapSourceRsrp=66
...    NRCELL:thresholdSCellSwapSourceRsrq=67
...    NRCELL:a6MeasSCellSwapSsbRsrp:a6HysteresisSCellSwapSsbRsrp=0
...    NRCELL-1:maxNumScellsDlFr1=${EMPTY}
...    NRCELL-11:weightForSCellSelection=60
...    NRCELL-12:weightForSCellSelection=60
...    NRBTS/NRPMRNL-1:miNrRelReportCu=15min
...    NRBTS:actAllowedBcListMrdcPrioBcSel=true
...    NRBTS:actCarrierAggregation=true
...    NRBTS:actHighestEstNrTputBcSel=true
...    NRBTS:actInterFreqIntraGnbMobilityNSA=true
...    NRBTS:caConfigurationSupport=4CCDL_2CCUL
...    NRBTS:maxNumScellsDl=3
...    NRBTS:maxNumScellsUl=3

@{PARAMS_FOR_8290_SCellSwap}
...    NRBTS:actSCellSwapFr1=a6BasedSa
...    NRCELL:a6MeasSCellSwapEnabled=rsrp
...    NRCELL:a6MeasSCellSwapSsbRsrp:a6HysteresisSCellSwapSsbRsrp=0|a6TimeToTrigSCellSwapSsbRsrp=ms480
...    NRCELL:a6MeasSCellSwapSsbRsrp:a6OffsetSCellSwapSsbRsrp=20|a6TimeToTrigSCellSwapSsbRsrp=ms480
...    NRCELL:a6MeasSCellSwapSsbRsrq:a6HysteresisSCellSwapSsbRsrq=0|a6TimeToTrigSCellSwapSsbRsrq=ms480
...    NRCELL:a6MeasSCellSwapSsbRsrq:a6OffsetSCellSwapSsbRsrq=20|a6TimeToTrigSCellSwapSsbRsrq=ms480
...    NRCELL:reportAmountA6MeasSCellSwap=r4
...    NRCELL:reportIntervalA6MeasSCellSwap=ms120
...    NRCELL:thresholdSCellSwapSourceRsrp=66
...    NRCELL:thresholdSCellSwapSourceRsrq=67

@{Cell_8x4_5GC2200}
...    NRCELL-3:dlMimoMode=8x4 Closed Loop Spatial Multiplexing
...    NRCELL-3:periodicCsiAcquisition:csirsNumberWithinReportPeriod_Set1=2
...    NRCELL-3:periodicCsiAcquisition:maxCsirsNumber=4
...    NRCELL-3:periodicCsiAcquisition:csirsPower=6
...    NRCELL-3:nrCellType=8DL4UL
...    NRCELL-3:actCsirsMultiplexing=true
...    LCELNR-3/CHANNELGROUP-1/CHANNEL-1:direction=TX
...    LCELNR-3/CHANNELGROUP-1/CHANNEL-2:direction=TX
...    LCELNR-3/CHANNELGROUP-1/CHANNEL-3:direction=TX
...    LCELNR-3/CHANNELGROUP-1/CHANNEL-4:direction=TX
...    LCELNR-3/CHANNELGROUP-1/CHANNEL-1:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1
...    LCELNR-3/CHANNELGROUP-1/CHANNEL-2:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1
...    LCELNR-3/CHANNELGROUP-1/CHANNEL-3:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1
...    LCELNR-3/CHANNELGROUP-1/CHANNEL-4:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1
...    NRCELL-3:pucchF3MaxCodeRate=zeroDot08
...    NRCELL-3:pucchF3ModulationScheme=pi2bpsk

@{expect_regexp_UE1}
...    pcid:50, scellIdx:0] configure_0_1
...    pcid:50, scellIdx:0] configure_1_1
...    pcid:66, scellIdx:1] configure_1_1
...    SCellIndex 1 activated successfully at airphone

@{expect_regexp_UE2}
...    pcid:50, scellIdx:0] configure_0_1
...    pcid:50, scellIdx:0] configure_1_1
...    pcid:68, scellIdx:1] configure_1_1
...    SCellIndex 1 activated successfully at airphone

@{expect_regexp_UE3}
...    pcid:50, scellIdx:0] configure_0_1
...    pcid:50, scellIdx:0] configure_1_1
...    pcid:69, scellIdx:1] configure_1_1
...    SCellIndex 1 activated successfully at airphone

@{expect_regexp_UE4}
...    pcid:50, scellIdx:0] configure_0_1
...    pcid:50, scellIdx:0] configure_1_1
...    pcid:55, scellIdx:1] configure_1_1
...    SCellIndex 1 activated successfully at airphone

@{expect_regexp_UE5}
...    pcid:54, scellIdx:0] configure_0_1
...    pcid:54, scellIdx:0] configure_1_1
...    pcid:50, scellIdx:1] configure_1_1
...    SCellIndex 1 activated successfully at airphone

@{swap_checkList}
...    sCellToAddModList
...    sCellToReleaseList

@{swap_checkList_with_Resourceid}
...    sCellToAddModList
...    nzp-CSI-RS-ResourceId 0
...    nzp-CSI-RS-ResourceId 181
...    nzp-CSI-RS-ResourceId 182
...    nzp-CSI-RS-ResourceId 183
...    sCellToReleaseList

*** Test Cases ***
CB008950-ET-C003-C004-SCell_swap_with_unique_SCellprio_SA_intragNBCA
    [Documentation]
    ...    1. This user scenario validates the A6 measurement based SCell swap for SA UE when there are more than 2 SCell
    ...    candidates on the same SCell carrier frequency.
    ...    2. Configuration
    ...    gNBs host following cells:
    ...                   Cell-1    Cell-3    Cell-5    Cell-6    Cell-11    Cell-12      Cell-13      Cell-17    Cell-19    Cell-20
    ...    Technology      TDD      TDD      TDD         TDD         FDD         FDD         FDD         FDD         FDD      FDD
    ...          Band      n41      n77      n77         n77         n66         n66        n66          n71        n71       n71
    ...           Pci       50       52       54         55          60          61          62           66         68        69
    ...     Bandwidth      100      100       100        100         10          10          10           15         15        15
    ...         Arfcn     517800    656000    656000     424000      424000    424000      425100         126000    126000     126000
    ...    3. Test Case Steps:
    ...           a. UE1 attach to cell-1, setup PDU session.
    ...           b. UE2 start traffic and trigger A1 CA scell addition.
    ...           c. UE3 attach to cell-1, setup PDU session.
    ...           d. UE4 start traffic and trigger A1 CA scell addition.
    ...           e. UE5 start traffic and trigger A1 CA scell addition.
    ...           6. UE1/UE2/UE5 scell swap 5 times.
    ...    4. Expected Results:
    ...           a. UE1-UE5 attach to cell-1, setup PDU session successfully, no tput issue.
    ...           b. UE1/UE2/UE3 scell swap succesfully and no tput issue.
    [Tags]    QC_47176    C003    CA_LABEL-TF(100M_TDD_n41+10M_FDD_n71)    CA_LABEL-TT(100M_TDD_n41+100M_TDD_n77)
    UE attach and Scell added coverbase     cellid=1    ${expect_regexp_UE1}    ue_id=1    CC_num=2    srsrp=80    srsrq=50    carrierfreq=517710
    UE attach and Scell added coverbase     cellid=1    ${expect_regexp_UE2}    ue_id=2    CC_num=2    srsrp=80    srsrq=50    carrierfreq=517710
    UE attach and Scell added coverbase     cellid=1    ${expect_regexp_UE3}    ue_id=3    CC_num=2    srsrp=80    srsrq=50    carrierfreq=517710
    UE attach and Scell added coverbase     cellid=1    ${expect_regexp_UE4}    ue_id=4    CC_num=2    srsrp=100    srsrq=50    carrierfreq=517710
    UE attach and Scell added coverbase     cellid=5    ${expect_regexp_UE5}    ue_id=5    CC_num=2    srsrp=100    srsrq=50    carrierfreq=655968
    UE1 Trigger ScellSwap
    UE2 Trigger ScellSwap
    UE5 Trigger ScellSwap
    Release Ues    ue_type=all

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/18cells_6T12F

Modify Cfg
    ${UE5}    catenate
    ...    set_ue simulated id=5 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...    nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g sec_key=0102030405060708090A0B0C0D0EFF00
    ...    suci=0:311:489:0000:0:0:021645404 mode=nr enb=2 cell=5
    Update Cfg    ${UE5}

UE Send A1 Trigger Scell Addition
    [Arguments]    ${ue_id}    ${cellfreq}    ${expect_regexp}    ${srsrp}    ${srsrq}
    ${meas_id}=    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=${cellfreq}    event_type=A1

    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=${srsrp} srsrq_nr=${srsrq}
    ...    pass_regexp=${expect_regexp}

UE attach and Scell added coverbase
    [Arguments]    ${cell_id}    ${expect_regexp}    ${ue_id}=1    ${CC_num}=5    ${srsrp}=80    ${srsrq}=50    ${carrierfreq}=517710
    Update UE capa    ue_id=${ue_id}    SA_Capa_perUE_Full=${CB008950_Capa_5CC_n41_n66_n66_n71_n77}
    SA UE Attach To Target Cell    cell_id=${cell_id}    ue_id=${ue_id}
    UE Send A1 Trigger Scell Addition    ${ue_id}    ${carrierfreq}    ${expect_regexp}    ${srsrp}    ${srsrq}
    Traffic Send    ue_id=${ue_id}
    sleep    15s    sleep for Tput stable
    Check Throughput with Type    ue_id=${ue_id}    Tput_expect=50    CC_num=1    type=pdsch

Update UE capa
    [Arguments]    ${SA_Capa_perUE_Full}=none    ${ue_id}=81
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full}
    Execute Egate Command    ${cmd}

SA UE Attach To Target Cell
    [Arguments]    ${cell_id}    ${ue_id}=81
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1    QoS Routing Table

Traffic Send
    [Arguments]    ${ue_id}=1
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=2 mbps=50    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=ul trf_id=1 mbps=15    UE ${ue_id}: UDP UL
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0 type=pdsch

Traffic Send UE
    [Arguments]    ${ue_id}=1
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=3

Check Throughput with Type
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${qfi}=1    ${Tput_expect}=20    ${CC_num}=2    ${type}=pdsch
    ${scell_tput}    Ap Get Throuput On Specific Scell     ue_id=${ue_id}    scell_id=0    type=pusch    rate_type=ave
    Should Be True    ${scell_tput}/1000 > 10
    ${ret0}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pdsch    pass_regexp=Average
    ${all_tput}    set variable    0
    FOR    ${id}    IN RANGE    0    ${CC_num}
        ${id}=    convert to string    ${id}
        ${cell_tput}    Scell Throughput    ${ue_id}    ${id}    ${type}
        ${all_tput}    Evaluate    ${all_tput}+${cell_tput}
    END
    Should Be True    ${all_tput}/1000 > ${Tput_expect}

Scell Throughput
    [Arguments]    ${ue_id}=1    ${scell_id}=0    ${type}=pdsch
    [Return]    ${scell_tput}
    ${scell_tput}    Ap Get Throuput On Specific Scell     ue_id=${ue_id}    scell_id=${scell_id}    type=${type}    rate_type=ave

UE1 Trigger ScellSwap
    Traffic Send UE    1
    FOR    ${index}    IN RANGE    0    5
        Trigger ScellSwap    event_type=A6    carrierfreq=125790    nrsrp_nr=30    nrsrq_nr=30    ue_id=1    phycell_id=68    scell_id=1
        sleep    10s    sleep for Tput swap stable
        Trigger ScellSwap    event_type=A6    carrierfreq=125790    nrsrp_nr=30    nrsrq_nr=30    ue_id=1    phycell_id=66    scell_id=2
        sleep    10s    sleep for Tput swap stable
        Wait Until Keyword Succeeds    2min    10s    Check Throughput with Type    ue_id=1    Tput_expect=135    CC_num=2    type=pdsch
    END
    Execute Egate Command    trf_data_stop ue=1    pass_regexp=Traffic was stopped

UE2 Trigger ScellSwap
    Traffic Send UE    2
    FOR    ${index}    IN RANGE    0    5
        Trigger ScellSwap    event_type=A6    carrierfreq=125790    nrsrp_nr=30    nrsrq_nr=30    ue_id=2    phycell_id=69    scell_id=1
        sleep    10s    sleep for Tput swap stable
        Trigger ScellSwap    event_type=A6    carrierfreq=125790    nrsrp_nr=30    nrsrq_nr=30    ue_id=2    phycell_id=68    scell_id=2
        sleep    10s    sleep for Tput swap stable
        Wait Until Keyword Succeeds    2min    10s    Check Throughput with Type    ue_id=2    Tput_expect=135    CC_num=2    type=pdsch
    END
    Execute Egate Command    trf_data_stop ue=2    pass_regexp=Traffic was stopped

UE5 Trigger ScellSwap
    Traffic Send UE    5
    sleep    20s    sleep for Tput stable
    FOR    ${index}    IN RANGE    0    5
        Trigger ScellSwap Check With Resourceid    event_type=A6    carrierfreq=517710    nrsrp_nr=30    nrsrq_nr=30
        ...    ue_id=5    phycell_id=52    scell_id=1
        sleep    10s    sleep for Tput swap stable
        Trigger ScellSwap    event_type=A6    carrierfreq=517710    nrsrp_nr=30    nrsrq_nr=30    ue_id=5    phycell_id=50    scell_id=2
        sleep    10s    sleep for Tput swap stable
        Wait Until Keyword Succeeds    2min    10s    Check Throughput with Type    ue_id=5    Tput_expect=135    CC_num=2    type=pdsch
    END
    Execute Egate Command    trf_data_stop ue=5    pass_regexp=Traffic was stopped

Trigger ScellSwap
    [Arguments]    ${event_type}=A6    ${carrierfreq}=638496    ${nrsrp_nr}=5    ${nrsrq_nr}=5    ${ue_id}=81    ${scell_id}=1
    ...    ${phycell_id}=63
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type}
    ...    srsrp_nr=11 srsrq_nr=11 scell=${scell_id} scell_rsrp=20 scell_rsrq=20 phycell_id=${phycell_id} nrsrp_nr=${nrsrp_nr} nrsrq_nr=${nrsrq_nr}
    Execute Egate Command    ${cmd}    pass_regexp=${swap_checkList}

Trigger ScellSwap Check With Resourceid
    [Arguments]    ${event_type}=A6    ${carrierfreq}=638496    ${nrsrp_nr}=5    ${nrsrq_nr}=5    ${ue_id}=81    ${scell_id}=1
    ...    ${phycell_id}=63
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type}
    ...    srsrp_nr=11 srsrq_nr=11 scell=${scell_id} scell_rsrp=20 scell_rsrq=20 phycell_id=${phycell_id} nrsrp_nr=${nrsrp_nr} nrsrq_nr=${nrsrq_nr}
    Execute Egate Command    ${cmd}    pass_regexp=${swap_checkList_with_Resourceid}
