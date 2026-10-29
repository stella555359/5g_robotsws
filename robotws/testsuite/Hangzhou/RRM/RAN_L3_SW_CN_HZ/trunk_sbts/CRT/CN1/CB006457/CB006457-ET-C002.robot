*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_VRF    RAN_5G_TDD    SBTS00    owner-lena.zhuo
...    CLOUD_5G_I_BOO_AP_LOO    CRT    CB006457    release-5G24R3
...    STATE_CONFIGURED    RAN_5G
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${SYSCOM_FLAG}    ${True}

@{PARAMS_IN_SCF}
...    NRBTS-1:cipherPrefL:nea0=8
...    NRBTS-1:cipherPrefL:nea1_128=0
...    NRBTS-1:cipherPrefL:nea2_128=0
...    NRBTS-1:cipherPrefL:nea3_128=0
...    NRBTS-1:integrityProtPrefL:nia0=0
...    NRBTS-1:integrityProtPrefL:nia1_128=0
...    NRBTS-1:integrityProtPrefL:nia2_128=0
...    NRBTS-1:integrityProtPrefL:nia3_128=9
...    @{PARAMS_FOR_IODT_ABIO_2T4F}
...    @{8290_enable}
...    @{DRX}
...    @{BOO_AP_LOO}
...    @{6457}
...    @{ULCA}

@{6457}
...    NRBTS:actArpBasedQosScaling=true
...    NRBTS:actNonGbrServiceDiff=true
...    NRBTS:multiArpBasedParam:nbrUlDlSF=52|arpPrioLev=2
...    NRBTS:multiArpBasedParam:schedulingWeightSF=52|arpPrioLev=2
...    NRBTS:multiArpBasedParam:nbrUlDlSF=4|arpPrioLev=14
...    NRBTS:multiArpBasedParam:schedulingWeightSF=4|arpPrioLev=14
...    NRBTS:multiArpBasedParam:nbrUlDlSF=1|arpPrioLev=15
...    NRBTS:multiArpBasedParam:schedulingWeightSF=1|arpPrioLev=15
...    @{NBR}

@{NBR}
...    NRCELL-12:maxNbrTrafficLimit=90
...    NRCELL-12:maxNumOfNbrBearers=80
...    NRCELL-12:maxPrbsPerNbrUe=30
...    NRCELL-12:nbrPdcchCongHandlingDl=true
...    NRCELL-12:nbrPdcchCongHandlingUl=true
...    NRCELL-12:nbrPdschCongHandling=true
...    NRCELL-12:nbrPuschCongHandling=true
...    NRCELL-11:maxNbrTrafficLimit=90
...    NRCELL-11:maxNumOfNbrBearers=80
...    NRCELL-11:maxPrbsPerNbrUe=30
...    NRCELL-11:nbrPdcchCongHandlingDl=true
...    NRCELL-11:nbrPdcchCongHandlingUl=true
...    NRCELL-11:nbrPdschCongHandling=true
...    NRCELL-11:nbrPuschCongHandling=true
...    NRCELL-12:actNbrForNonGbrBearers=true
...    NRCELL-12:congDetectPeriod=ms100
...    NRCELL-12:congWeightAlg=arpPrioPerVul
...    NRCELL-11:actNbrForNonGbrBearers=true
...    NRCELL-11:congDetectPeriod=ms100
...    NRCELL-11:congWeightAlg=priorityLevel
...    NRCELL-2:maxNbrTrafficLimit=90
...    NRCELL-2:maxNumOfNbrBearers=80
...    NRCELL-2:maxPrbsPerNbrUe=30
...    NRCELL-2:nbrPdcchCongHandlingDl=false
...    NRCELL-2:nbrPdcchCongHandlingUl=false
...    NRCELL-2:nbrPdschCongHandling=false
...    NRCELL-2:nbrPuschCongHandling=false
...    NRCELL-2:actNbrForNonGbrBearers=true
...    NRCELL-2:congDetectPeriod=ms100
...    NRCELL-2:congWeightAlg=arpPrioPerVul
...    NRBTS/NRDRB-11:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-5
...    NRBTS/NRDRB-11:priorityLevel=60
...    NRBTS/NRDRB-11:schedulWeight=15
...    NRBTS/NRDRB-13:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-6
...    NRBTS/NRDRB-13:priorityLevel=80
...    NRBTS/NRDRB-13:schedulWeight=50
...    NRBTS/NRDRB_MAC-5:nbrDl=10000
...    NRBTS/NRDRB_MAC-5:nbrUl=5000
...    NRBTS/NRDRB_MAC-6:nbrDl=15000
...    NRBTS/NRDRB_MAC-6:nbrUl=8000

@{scellActivation}
...    NRBTS:actBufferBasedSCellAddition=oneShot_Dl_Fr1
...    NRCELL:dlSCellConfigLevel=2
...    NRCELL:dlSCellConfigLevelNum=5

@{BOO_AP_LOO}
...    BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=1
...    BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=1
...    BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=9|searchSpaceId=1
...    BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=1
...    BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=1
...    BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=1
...    BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=1
...    BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=1
...    BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|searchSpaceId=1
...    BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=1
...    BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=4|searchSpaceId=1
...    BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=2
...    BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=2
...    BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=2
...    BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=2
...    BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=2
...    BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n4|searchSpaceId=2
...    BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=2
...    BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=2
...    BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=2
...    BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=2
...    BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=2
...    BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=3
...    BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=3
...    BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=2|searchSpaceId=3
...    BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=3
...    BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=3
...    BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=3
...    BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=3
...    BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=3
...    BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceId=3
...    BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=3
...    BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=3
...    BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=4
...    BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=4
...    BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=9|searchSpaceId=4
...    BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=4
...    BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=4
...    BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=4
...    BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=4
...    BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=4
...    BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|searchSpaceId=4
...    BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=4
...    BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=4|searchSpaceId=4
...    BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=5
...    BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=5
...    BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=5
...    BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=5
...    BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=5
...    BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n4|searchSpaceId=5
...    BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=5
...    BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=5
...    BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=5
...    BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=5
...    BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=5
...    BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=6
...    BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=6
...    BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=2|searchSpaceId=6
...    BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=6
...    BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=6
...    BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=6
...    BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=6
...    BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=6
...    BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceId=6
...    BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=6
...    BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=6
...    @{same frequency}

@{NRREL}
...    NRCELL-1/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-10:gNbId=1
...    NRCELL-1/NRREL-10:gNbIdLength=22
...    NRCELL-1/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-10:removeNotAllowed=false
...    NRCELL-1/NRREL-10:lcrId=11
...    NRCELL-1/NRREL-10:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-10:sCellPrio=1
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-1:gNbId=1
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-1:removeNotAllowed=false
...    NRCELL-1/NRREL-1:lcrId=13
...    NRCELL-1/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-1:sCellPrio=2
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-2:gNbId=1
...    NRCELL-1/NRREL-2:gNbIdLength=22
...    NRCELL-1/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-2:removeNotAllowed=false
...    NRCELL-1/NRREL-2:lcrId=12
...    NRCELL-1/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-2:sCellPrio=1
...    NRCELL-1/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-3:gNbId=1
...    NRCELL-1/NRREL-3:gNbIdLength=22
...    NRCELL-1/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-3:removeNotAllowed=false
...    NRCELL-1/NRREL-3:lcrId=14
...    NRCELL-1/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-3:sCellPrio=2
...    NRCELL-1/NRREL-4:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-4:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-4:gNbId=1
...    NRCELL-1/NRREL-4:gNbIdLength=22
...    NRCELL-1/NRREL-4:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-4:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-4:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-4:removeNotAllowed=false
...    NRCELL-1/NRREL-4:lcrId=2
...    NRCELL-2/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-10:gNbId=1
...    NRCELL-2/NRREL-10:gNbIdLength=22
...    NRCELL-2/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-10:removeNotAllowed=false
...    NRCELL-2/NRREL-10:lcrId=11
...    NRCELL-2/NRREL-10:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-10:sCellPrio=1
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-1:gNbId=1
...    NRCELL-2/NRREL-1:gNbIdLength=22
...    NRCELL-2/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-1:removeNotAllowed=false
...    NRCELL-2/NRREL-1:lcrId=13
...    NRCELL-2/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-1:sCellPrio=2
...    NRCELL-2/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-2:gNbId=1
...    NRCELL-2/NRREL-2:gNbIdLength=22
...    NRCELL-2/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-2:removeNotAllowed=false
...    NRCELL-2/NRREL-2:lcrId=12
...    NRCELL-2/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-2:sCellPrio=1
...    NRCELL-2/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-3:gNbId=1
...    NRCELL-2/NRREL-3:gNbIdLength=22
...    NRCELL-2/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-3:removeNotAllowed=false
...    NRCELL-2/NRREL-3:lcrId=14
...    NRCELL-2/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-3:sCellPrio=2
...    NRCELL-12/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-10:gNbId=1
...    NRCELL-12/NRREL-10:gNbIdLength=22
...    NRCELL-12/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-10:removeNotAllowed=false
...    NRCELL-12/NRREL-10:lcrId=1
...    NRCELL-12/NRREL-10:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-10:sCellPrio=1
...    NRCELL-12/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-1:gNbId=1
...    NRCELL-12/NRREL-1:gNbIdLength=22
...    NRCELL-12/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-1:removeNotAllowed=false
...    NRCELL-12/NRREL-1:lcrId=2
...    NRCELL-12/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-1:sCellPrio=2
...    NRCELL-12/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-2:gNbId=1
...    NRCELL-12/NRREL-2:gNbIdLength=22
...    NRCELL-12/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-2:removeNotAllowed=false
...    NRCELL-12/NRREL-2:lcrId=11
...    NRCELL-12/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-2:sCellPrio=1
...    NRCELL-12/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-3:gNbId=1
...    NRCELL-12/NRREL-3:gNbIdLength=22
...    NRCELL-12/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-3:removeNotAllowed=false
...    NRCELL-12/NRREL-3:lcrId=13
...    NRCELL-12/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-3:sCellPrio=2
...    NRCELL-13/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-13/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-13/NRREL-10:gNbId=1
...    NRCELL-13/NRREL-10:gNbIdLength=22
...    NRCELL-13/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-13/NRREL-10:removeNotAllowed=false
...    NRCELL-13/NRREL-10:lcrId=1
...    NRCELL-13/NRREL-10:sCellAdditionMethod=covBasedA1
...    NRCELL-13/NRREL-10:sCellPrio=1
...    NRCELL-13/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-13/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-13/NRREL-1:gNbId=1
...    NRCELL-13/NRREL-1:gNbIdLength=22
...    NRCELL-13/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-13/NRREL-1:removeNotAllowed=false
...    NRCELL-13/NRREL-1:lcrId=2
...    NRCELL-13/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-13/NRREL-1:sCellPrio=2
...    NRCELL-13/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-13/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-13/NRREL-2:gNbId=1
...    NRCELL-13/NRREL-2:gNbIdLength=22
...    NRCELL-13/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-13/NRREL-2:removeNotAllowed=false
...    NRCELL-13/NRREL-2:lcrId=12
...    NRCELL-13/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-13/NRREL-2:sCellPrio=1
...    NRCELL-13/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-13/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-13/NRREL-3:gNbId=1
...    NRCELL-13/NRREL-3:gNbIdLength=22
...    NRCELL-13/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-13/NRREL-3:removeNotAllowed=false
...    NRCELL-13/NRREL-3:lcrId=14
...    NRCELL-13/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-13/NRREL-3:sCellPrio=2
...    NRCELL-11/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-10:gNbId=1
...    NRCELL-11/NRREL-10:gNbIdLength=22
...    NRCELL-11/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-10:removeNotAllowed=false
...    NRCELL-11/NRREL-10:lcrId=13
...    NRCELL-11/NRREL-4:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-4:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-4:gNbId=1
...    NRCELL-11/NRREL-4:gNbIdLength=22
...    NRCELL-11/NRREL-4:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-4:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-4:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-4:removeNotAllowed=false
...    NRCELL-11/NRREL-4:lcrId=2
...    NRCELL-11/NRREL-4:sCellPrio=1
...    NRCELL-11/NRREL-4:handoverAllowedSA=forbidden
...    NRCELL-11/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-3:gNbId=1
...    NRCELL-11/NRREL-3:gNbIdLength=22
...    NRCELL-11/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-3:removeNotAllowed=false
...    NRCELL-11/NRREL-3:lcrId=1
...    NRCELL-11/NRREL-3:sCellPrio=2
...    NRCELL-11/NRREL-3:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-2:gNbId=1
...    NRCELL-11/NRREL-2:gNbIdLength=22
...    NRCELL-11/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-2:removeNotAllowed=false
...    NRCELL-11/NRREL-2:lcrId=14
...    NRCELL-11/NRREL-2:sCellPrio=2
...    NRCELL-11/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-1:gNbId=1
...    NRCELL-11/NRREL-1:gNbIdLength=22
...    NRCELL-11/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-1:removeNotAllowed=false
...    NRCELL-11/NRREL-1:lcrId=12
...    NRCELL-11/NRREL-1:sCellPrio=1
...    NRCELL-11/NRREL-1:handoverAllowedSA=allowed

@{ULCA}
...    NRCELL-1:increasePUSCHPrepTimeULCA=true
...    NRCELL-1/NRREL-1:sCellOperationalMode=dlAndUl
...    NRCELL-1/NRREL-10:sCellOperationalMode=dlAndUl
...    NRCELL-1/NRREL-2:sCellOperationalMode=dlAndUl
...    NRCELL-1/NRREL-3:sCellOperationalMode=dlAndUl
...    NRCELL-11:timingAdvanceOffset=n25600
...    NRCELL-12:timingAdvanceOffset=n25600
...    NRCELL-12/NRREL-1:sCellOperationalMode=dlAndUl
...    NRCELL-12/NRREL-10:sCellOperationalMode=dlAndUl
...    NRCELL-12/NRREL-2:sCellOperationalMode=dlAndUl
...    NRCELL-12/NRREL-3:sCellOperationalMode=dlAndUl
...    NRCELL-13:timingAdvanceOffset=n25600
...    NRCELL-13/NRREL-1:sCellOperationalMode=dlAndUl
...    NRCELL-13/NRREL-10:sCellOperationalMode=dlAndUl
...    NRCELL-13/NRREL-2:sCellOperationalMode=dlAndUl
...    NRCELL-13/NRREL-3:sCellOperationalMode=dlAndUl
...    NRCELL-14:timingAdvanceOffset=n25600
...    NRCELL-2:increasePUSCHPrepTimeULCA=true
...    NRCELL-2/NRREL-1:sCellOperationalMode=dlAndUl
...    NRCELL-2/NRREL-10:sCellOperationalMode=dlAndUl
...    NRCELL-2/NRREL-2:sCellOperationalMode=dlAndUl
...    NRCELL-2/NRREL-3:sCellOperationalMode=dlAndUl
...    NRBTS/NRDRB_RLC_AM-1:ulTReassemblyIBCA=40
...    NRBTS/NRDRB_RLC_AM-2:ulTReassemblyIBCA=40
...    NRBTS/NRDU-1:carrierAggregationSupportList=${CAlist}
...    NRBTS/NRDU-1:ulTxSwitchingSupportList=ca_F_Fr1T_Sa_switchedUl,ca_Fr1T_F_Sa_switchedUl
${CAlist}    ca_Fdd_Fdd,ca_Fdd_Fr1Tdd_Sa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fdd_Fr1Tdd_Sa_WithUl,ca_Fdd_Fdd_Sa_WithUl,ca_Fr1Tdd_Fdd_Sa_WithUl,
...    ca_Fdd_Any_Sa,ca_Fr1Tdd_Any_Sa

@{DRX}
...    NRCELL:actCDrx=true

@{8290_enable}
...    NRDU-1:actInterNumerologyCa=true
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRBTS-1:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS-1:actMeasBasedSCellAdditionNsa=true
...    NRBTS-1:actSCellSwapFr1=a6BasedSa
...    NRBTS-1:sCellActivationMethod=bufferBased
...    NRCELL:sCellDeactivationTimerGNB=infinity
...    NRCELL:cellDepType=SA+NSA
...    NRCELL:actK1Opt=intra-gNB
...    NRCELL:a6MeasSCellSwapEnabled=rsrp
...    NRCELL:a6MeasSCellSwapSsbRsrp:a6HysteresisSCellSwapSsbRsrp=0|a6OffsetSCellSwapSsbRsrp=20|a6TimeToTrigSCellSwapSsbRsrp=ms480
...    NRCELL:a6MeasSCellSwapSsbRsrq:a6HysteresisSCellSwapSsbRsrq=0|a6OffsetSCellSwapSsbRsrq=20|a6TimeToTrigSCellSwapSsbRsrq=ms480
...    NRCELL:reportAmountA6MeasSCellSwap=infinity
...    NRCELL:reportIntervalA6MeasSCellSwap=ms1024
...    NRCELL:thresholdSCellSwapSourceRsrp=66
...    NRCELL:thresholdSCellSwapSourceRsrq=67
...    NRCELL:a1MeasSCellAddEnabled=rsrp
...    NRCELL:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=70|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=90|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrq:a1HysteresisSCellAddSsbRsrq=0|a1TimeToTriggerSCellAddSsbRsrq=320ms
...    NRCELL:a1MeasSCellAddSsbRsrq:a1ThresholdSCellAddSsbRsrq=30|a1TimeToTriggerSCellAddSsbRsrq=320ms
...    NRCELL:a1MeashoEnabledSA=rsrp
...    NRCELL:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0|a1ThresholdhoSsbRsrpSA=40|a1TimeToTriggerhoSsbRsrpSA=ms64
...    NRCELL:a2MeashoEnabledSA=rsrp
...    NRCELL:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0|a2ThresholdhoSsbRsrpSA=30|a2TimeToTriggerhoSsbRsrpSA=ms64
...    NRCELL:a3MeasEnabled=rsrp
...    NRCELL:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0|a3OffsetSsbRsrp=20|a3TimeToTriggerSsbRsrp=ms64
...    NRCELL:absThreshSsbRsrpConsolidation=1
...    NRCELL:sMeasConfigSsbRsrp=1
...    NRCELL:a2MeasSCellRelEnabled=rsrp
...    NRCELL:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2ThresholdSCellRelSsbRsrp=34|a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-12:weightForSCellSelection=50
...    NRCELL-14:weightForSCellSelection=50
...    NRCELL-11:weightForSCellSelection=60
...    NRCELL-13:weightForSCellSelection=60
...    NRCELL-1:weightForSCellSelection=80
...    NRCELL-2:weightForSCellSelection=80
...    @{scellActivation}
...    @{A1pcellchange}
...    @{NRREL}

@{same frequency}
...    MRBTS-1/NRBTS-1/NRCELL-13/NRCELL_FDD-1:nrarfcnDl=424000
...    MRBTS-1/NRBTS-1/NRCELL-13/NRCELL_FDD-1:nrarfcnUl=344000
...    MRBTS-1/NRBTS-1/NRCELL-13/NRCELL_FDD-1:chBwDl=10MHz
...    MRBTS-1/NRBTS-1/NRCELL-13/NRCELL_FDD-1:chBwUl=10MHz
...    MRBTS-1/NRBTS-1/NRCELL-13:type0CoresetConfigurationIndex=7
...    MRBTS-1/NRBTS-1/NRCELL-13:gscnOrSsPbchArfcn=5300
...    MRBTS-1/NRBTS-1/NRCELL-12:gscnOrSsPbchArfcn=1592
...    MRBTS-1/NRBTS-1/NRCELL-12/NRCELL_FDD-1:nrarfcnDl=127420
...    MRBTS-1/NRBTS-1/NRCELL-12/NRCELL_FDD-1:nrarfcnUl=136620
...    MRBTS-1/NRBTS-1/NRCELL-12/NRCELL_FDD-1:chBwDl=10MHz
...    MRBTS-1/NRBTS-1/NRCELL-12/NRCELL_FDD-1:chBwUl=10MHz
...    MRBTS-1/NRBTS-1/NRCELL-12:type0CoresetConfigurationIndex=8
...    MRBTS-1/NRBTS-1/NRCELL-14:gscnOrSsPbchArfcn=1592
...    MRBTS-1/NRBTS-1/NRCELL-14/NRCELL_FDD-1:nrarfcnDl=127420
...    MRBTS-1/NRBTS-1/NRCELL-14/NRCELL_FDD-1:nrarfcnUl=136620
...    MRBTS-1/NRBTS-1/NRCELL-14/NRCELL_FDD-1:chBwDl=10MHz
...    MRBTS-1/NRBTS-1/NRCELL-14/NRCELL_FDD-1:chBwUl=10MHz
...    MRBTS-1/NRBTS-1/NRCELL-14:type0CoresetConfigurationIndex=8

@{A1pcellchange}
...    NRBTS-1:actInterFreqHoSA=true
...    NRBTS-1:actIntraFreqHoSA=true
...    NRPMRNL-1:miNrRelReportCu=15min
...    NRCELL:a1MeasPCellSwitchEnabled=rsrp
...    NRCELL:a1MeasPCellSwitchSsbRsrp:a1HysteresisPCellSwitchSsbRsrp=0
...    NRCELL:a1MeasPCellSwitchSsbRsrp:a1ThresholdPCellSwitchSsbRsrp=100
...    NRCELL:a1MeasPCellSwitchSsbRsrp:a1TimeToTriggerPCellSwitchSsbRsrp=0ms
...    NRCELL-1/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-1/NRHOIF-1:freqBandIndicatorNR=71
...    NRCELL-1/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-1/NRHOIF-1:scs=15 KHz
...    NRCELL-1/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-1:ssbFrequency=127450
...    NRCELL-1:measGapSelectionSA=favourUeThroughput
...    NRCELL-1/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0|a3OffsetSsbRsrp=30|a3TimeToTriggerSsbRsrp=ms64
...    NRCELL-12/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-12/NRHOIF-1:a1BasedPCellSwitchEnabled=true
...    NRCELL-12/NRHOIF-1:freqBandIndicatorNR=41
...    NRCELL-12/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-12/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-12/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-12/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-12/NRHOIF-1:scs=30 KHz
...    NRCELL-12/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-12/NRHOIF-1:ssbFrequency=518910
...    NRCELL-12:measGapSelectionSA=favourUeThroughput
...    NRCELL-12/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-12/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0|a3OffsetSsbRsrp=30|a3TimeToTriggerSsbRsrp=ms64
...    NRCELL:a2MeasPCellSwitchEnabled=rsrp
...    NRCELL:a2MeasPCellSwitchSsbRsrp:a2HysteresisPCellSwitchSsbRsrp=0
...    NRCELL:a2MeasPCellSwitchSsbRsrp:a2ThresholdPCellSwitchSsbRsrp=111
...    NRCELL:a2MeasPCellSwitchSsbRsrp:a2TimeToTriggerPCellSwitchSsbRsrp=0ms
...    NRCELL:a2MeasPCellSwitchSsbRsrp:pCellSwitchOffsetSsbRsrp=1
...    NRCELL-1/NRHOIF-2:cellDepType=SA+NSA
...    NRCELL-1/NRHOIF-2:a2BasedPCellSwitchEnabled=true
...    NRCELL-1/NRHOIF-2:freqBandIndicatorNR=66
...    NRCELL-1/NRHOIF-2:ifhoSsbScs=15KHz
...    NRCELL-1/NRHOIF-2:ifhoSsbSmtcDuration=sf1
...    NRCELL-1/NRHOIF-2:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-2:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-1/NRHOIF-2:scs=15 KHz
...    NRCELL-1/NRHOIF-2:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-2:ssbFrequency=424090
...    NRCELL-1/NRHOIF-2:thresholdPCellSwitchTargetRsrp=122
...    NRCELL-1/NRHOIF-2:thresholdPCellSwitchTargetRsrq=2
...    NRCELL-1/NRHOIF-2:a2BasedPCellSwitchPriority=1
...    NRCELL-2/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-2/NRHOIF-1:a2BasedPCellSwitchEnabled=true
...    NRCELL-2/NRHOIF-1:freqBandIndicatorNR=66
...    NRCELL-2/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-2/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-2/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-2/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-2/NRHOIF-1:scs=15 KHz
...    NRCELL-2/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-2/NRHOIF-1:ssbFrequency=424090
...    NRCELL-2/NRHOIF-1:thresholdPCellSwitchTargetRsrp=122
...    NRCELL-2/NRHOIF-1:thresholdPCellSwitchTargetRsrq=2
...    NRCELL-2/NRHOIF-1:a2BasedPCellSwitchPriority=1
...    NRCELL-2:measGapSelectionSA=favourUeThroughput
...    NRCELL-13/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-13/NRHOIF-1:a1BasedPCellSwitchEnabled=true
...    NRCELL-13/NRHOIF-1:freqBandIndicatorNR=71
...    NRCELL-13/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-13/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-13/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-13/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-13/NRHOIF-1:scs=15 KHz
...    NRCELL-13/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-13/NRHOIF-1:ssbFrequency=127450
...    NRCELL-13:measGapSelectionSA=favourUeThroughput
...    @{NRCELL-13}

@{NRCELL-13}
...    NRCELL-13:a2MeasSCellRelEnabled=none
...    NRCELL-13:a6MeasSCellSwapEnabled=none

@{NRCELL-1_1}
...    NRCELL-1:maxNumOfSCellAlloc=0

#CA_ULCA
${ULCA_UE}    SEPARATOR=
...    E9A09000575F5A13160003C4A0002C1262E003387A16009B20C39F30C7942C0E0980C0311C03EE3614606B04610D04083A41E006D6C98AB1A1CF88E3D033
...    EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE000C80000E0541B107582308682041E20F0032B64C55890E7D813E238F1891C790E7D473E6
...    18F28581C0E1E13FB000000FEC000000C80000E0551B137582308682041D20F0030B64C55110E7C471E238F40CFB027C639F30C7942C0E070F05C00FFC00
...    7003FF000640000702A0D88DAC1184341020F10780195B262AC4873E238F604F8C48E3C873EA39F30C7942C0E070F09FFF000007FFC000006400007003DE
...    1E26800710400000858081507850001C46000002160561E230007104000018581587850001C41000002160561E26800711800000858158B88C001C41000E
...    208000050B02B0F0A000389A0000182C0AC5C4D000E2080070A000002058158B89A001C46000E230000020B02B170A0003882001C46000004160562E1400
...    071040038820000082C0AC5C4D000E20800711800001058158B850001C46000E230000020B02B1713400388C001C28000008160561E23000711800001858
...    1007011A014404D808232800BB07C28913639F0E14489B1CF870A244D8E7C3851226C73E1C28913639F0E2448913639F0E14081B1CF811204081B1CF8112
...    04081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF810A040D8E7C00170F18C6318C6318C6318C61E836001E0014
...    0E0A00E0601280380030120020301F0480100000000800001004000000020000040100000400800003004000020020000140100080200802000018010000
...    0E008004000000100001000800009004000018020000280100001600800409024010000180672A6B2A6B052B032B066B056B296B266B016B036B012B022B
...    07681A0800004B29202000032CA480800014B29202000072CA480800024B292020000B2CA480800034B292020000F2CA480800044B29202000132CA48080
...    0054B29202000172CA480800064B29202000062CA480669545D2A8AA55174AA2A82C55058AA0D154A62A93455018AA051549A2A83C50D005E02540A05028
...    140A05028140A05028140A05028140A05000608080600C02004008404008020100C018402004008080600C02018030404030060100C01840200400808060
...    0C02004008804030060100C018040300608080100402004010D50F8000810182030385058606880889098A0C0C8D8E0E8F909293139414951697A0A0C168

${pdu_id}    1
${gw_id}    1
${nwslice}    1

*** Test Cases ***
CB006457-ET-C002_ARP_based_scaling_interworking_with_scell_swap_and_pcell_scell_change_scells_with_different_schedulingWeight_and_NBR
    [Documentation]
    ...    1. This user scenario describes describes the ARP based scaling in Carrier Aggregation scenarios.
    ...       The scaling factor will be applied independently on PCell and SCell.
    ...    2. Configuration:
    ...        TDD Cell1/Cell2 configure to same frequency, FDD Cell11/Cell13 configure to same frequency.
    ...        FDD cell12/cell14 configure to another same frequency.
    ...        Configure nrrel Relations:
    ...        cell1-cell11, cell1-cell13, cell1-cell12, cell1-cell14, cell1-cell2
    ...        cell2-cell11, cell2-cell13, cell2-cell12, cell2-cell14
    ...        cell11-cell1, cell11-cell2, cell11-cell12, cell11-cell14, cell11-cell13
    ...        cell12-cell1, cell12-cell2, cell12-cell11, cell12-cell13
    ...        cell13-cell1, cell13-cell2, cell13-cell12, cell13-cell14
    ...    3. Test Case Steps:
    ...         1). UE1/2 registers successfully and PDU session is setup successfully on cell 12, Start UL/DL data.
    ...             A1 meas for scell addition configured, mobility A2/A3 configured, DRX setup.
    ...             DL/UL throughput on TDD PCell can reach the expected value.
    ...         2). Measurement report to the gNB for A1 event, lower than a1ThresholdSCellAddSsbRsrpTDD,
    ...             higher than a1ThresholdSCellAddSsbRsrpFDD.
    ...             higher priority FDD cell11 addition successfully, Scell activated successfully.
    ...             A6 meas configed to UE, A2 meas for scell release configured, A1 for scell change configured.
    ...             DL/UL throughput on FDD PCell and FDD Scell can reach the expected value.
    ...         3). nidd no configure A2 scell release and A6 scell swap in cell13
    ...             A6 for scell swap measurement report from 5G-UE
    ...             scell swap to FDD cell13 successfully, Scell activated successfully
    ...             meas ID and report config for A6/A2 removed
    ...             DL/UL throughput on FDD PCell and FDD Scell can reach the expected value.
    ...         4). set NRCELL-1:maxNumOfSCellAlloc=0,
    ...             Measurement report to the gNB for A1 event, higher than a1ThresholdSCellAddSsbRsrpTDD
    ...             higher priority TDD cell1 is OOS, SCell change to lower priority TDD cell2 successfully,
    ...             gNB reconfigure A2 for scell release, A6 for scell swap.
    ...             DL/UL throughput on FDD PCell and TDD Scell can reach the expected value.
    ...         5). UE3/4 registers successfully and PDU session is setup successfully on cell 2, Start UL/DL data.
    ...             A1 meas for scell addition configured, mobility A2/A3 configured, DRX setup.
    ...             DL/UL throughput on TDD PCell can reach the expected value.
    ...         6). Measurement report to the gNB for A1 event, lower than a1ThresholdSCellAddSsbRsrpTDD,
    ...             higher than a1ThresholdSCellAddSsbRsrpFDD
    ...             higher priority FDD cell11 addition successfully, Scell activated successfully,
    ...             A6 meas configed to UE, A2 meas for scell release configured, A2 for pcell change, DRX release, then DRX setup.
    ...             DL/UL throughput on TDD PCell and FDD Scell can reach the expected value
    ...         7).A6 for scell swap measurement report from 5G-UE
    ...             scell swap to FDD cell13 successfully, Scell activated successfully
    ...             DL/UL throughput on TDD PCell and FDD Scell can reach the expected value
    ...         8).A2 for Pcell switch measurement report from 5G-UE
    ...             Pcell switch to FDD cell13 successfully, A1 for scell addition configured.
    ...             DL/UL throughput on FDD PCell can reach the expected value
    ...         9).Measurement report to the gNB for A1 event, lower than a1ThresholdSCellAddSsbRsrpTDD,
    ...             higher than a1ThresholdSCellAddSsbRsrpFDD
    ...             higher priority FDD cell12 addition successfully, Scell activated successfully
    ...             A6 meas configed to UE, A2 meas for scell release configured, A1 for scell change configured,
    ...             A1 for pcell change configured.
    ...             DL/UL throughput on FDD PCell and FDD Scell can reach the expected value
    ...         10).A1 for Pcell switch measurement report from 5G-UE
    ...             Pcell switch to FDD cell12 successfully, A1 for scell addition configured.
    ...             DL/UL throughput on FDD PCell can reach the expected value
    ...         11).Measurement report to the gNB for A1 event, lower than a1ThresholdSCellAddSsbRsrpTDD,
    ...             higher than a1ThresholdSCellAddSsbRsrpFDD
    ...             higher priority FDD cell3 addition successfully, Scell activated successfully,
    ...             A6 meas configed to UE, A2 meas for scell release configured, A1 for scell change configured
    ...             DL/UL throughput on FDD PCell and FDD Scell can reach the expected value
    ...         12).A6 for scell swap measurement report from 5G-UE
    ...             cell swap to FDD cell13 successfully, Scell activated successfully,
    ...             A6 for scell swap, A2 for scell release
    ...             DL/UL throughput on FDD PCell and FDD Scell can reach the expected value
    ...         13).release UEs
    ...             UE release successfully
    [Tags]    C002    QC_46954
    ScellAdd and Swap then scellChange    cell_id=12    ue_id=81    pcell_dl=0    qos_flow=1    priority=2
    ScellAdd and Swap then scellChange    cell_id=12    ue_id=82    pcell_dl=0    qos_flow=2    priority=14
    ScellAdd and Swap then A1A2PcellSwitch    cell_id=2    ue_id=83    pcell_dl=0    qos_flow=1    priority=2
    ScellAdd and Swap then A1A2PcellSwitch    cell_id=2    ue_id=84    pcell_dl=0    qos_flow=2    priority=14
    Release Ues    ue_type=all
    Check Wireshark Log    ${CURDIR}${/}a2a_C002${/}a2a.ini    wait_string=UEContextReleaseComplete::16

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_2T4F_2N41_2N71_2N66

Modify Cfg
    Update Cfg    set_qosflow id=2 5qi=8 default=off
    Update Cfg    qosrule_set id=1 proto=udp qos_flow=1
    Update Cfg    qosrule_set id=2 proto=udp qos_flow=2
    Update Cfg    set_nwslice id=1 snssai=0x01:0xD143A5 default=on amf=1 ue=all qos_flows=1,2 qos_rules=1,2

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir

ScellAdd and Swap then scellChange
    [Arguments]    ${cell_id}=12    ${ue_id}=81    ${pcell_dl}=50    ${qos_flow}=6    ${priority}=2
    UE Attach To Target Cell    cell_id=${cell_id}    ue_id=${ue_id}    pcell_dl=${pcell_dl}    qos_flow=${qos_flow}    priority=${priority}
    Trigger ScellAdd or ScellChange    carrierfreq=127450    ue_id=${ue_id}    phycell_id=60    pcell_dl=${pcell_dl}    scell_dl=0
    Trigger ScellSwap    carrierfreq=424090    ue_id=${ue_id}    scell_id=1    phycell_id=62    pcell_dl=${pcell_dl}    scell_dl=0
    OnlineParamChange    ${NRCELL-1_1}    #step7
    Trigger ScellAdd or ScellChange    carrierfreq=127450    ue_id=${ue_id}    phycell_id=51    srsrp_nr=91    pcell_dl=${pcell_dl}    scell_dl=0

ScellAdd and Swap then A1A2PcellSwitch
    [Arguments]    ${cell_id}=12    ${ue_id}=81    ${pcell_dl}=50    ${qos_flow}=6    ${priority}=2
    UE Attach To Target Cell    cell_id=${cell_id}    ue_id=${ue_id}    pcell_dl=${pcell_dl}    qos_flow=${qos_flow}    priority=${priority}
    Trigger ScellAdd or ScellChange    carrierfreq=518910    ue_id=${ue_id}    phycell_id=60    pcell_dl=${pcell_dl}    scell_dl=0    #step17
    Trigger ScellSwap    carrierfreq=424090    ue_id=${ue_id}    scell_id=1    phycell_id=62    pcell_dl=${pcell_dl}    scell_dl=0    #step18
    A2 pcell switch and A1 pcell switch then A6 scell swap    ue_id=${ue_id}

UE Attach To Target Cell
    [Arguments]    ${cell_id}=12    ${ue_id}=81    ${pcell_dl}=50    ${qos_flow}=6    ${priority}=2
    @{expect}     Create List     QoS Routing Table
    ...    drx-Config setup
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    qosflow_modify qos_flow=${qos_flow} default=on priority=${priority}
    Update UE capa    ${ULCA_UE}    ${ue_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=${gw_id} nwslice=${nwslice}    pass_regexp=${expect}    timeout=5s
    Send Throuput    ue_id=${ue_id}
    Verify Throuput on Pcell    ue_id=${ue_id}    pcell_dl=${pcell_dl}

Send Throuput
    [Arguments]    ${ue_id}=81
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=3    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=4    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=ul mbps=10 trf_id=1    UE ${ue_id}: UDP UL
    sleep    30s    #sleep for stable traffic

Verify Throuput on Pcell
    [Arguments]    ${ue_id}=81    ${pcell_dl}=60    ${ul}=0
    sleep    10s    #sleep for stable traffic
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pdsch
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pusch
    FOR    ${ue}    IN RANGE    81    ${ue_id}+1
        Execute Egate Command    ue_stats_nr id=${ue} scell=0-7 type=pdsch
        Execute Egate Command    ue_stats_nr id=${ue} scell=0-7 type=pusch
    END
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000>${pcell_dl}
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul}

Verify Throuput on Pcell and Scell
    [Arguments]    ${ue_id}=81    ${pcell_dl}=10    ${scell_dl}=10    ${ul}=0    ${scell_id}=1
    sleep    10s     #sleep for stable traffic
    FOR    ${ue}    IN RANGE    81    ${ue_id}+1
        Execute Egate Command    ue_stats_nr id=${ue} scell=0-7 type=pdsch
        Execute Egate Command    ue_stats_nr id=${ue} scell=0-7 type=pusch
    END
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pdsch
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pusch
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000 > ${pcell_dl}
    ${scell_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${scell_id}    type=pdsch    rate_type=ave
#    Should Be True    ${scell_tput}/1000 > ${scell_dl}
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul}

UE Deregister From gNB
    [Arguments]    ${ue_id}=81
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s

Trigger ScellAdd or ScellChange
    [Arguments]    ${event_type}=A1    ${carrierfreq}=518910    ${srsrp_nr}=80    ${srsrq_nr}=50    ${ue_id}=81    ${phycell_id}=60
    ...    ${pcell_dl}=0    ${scell_dl}=0    ${scell_id}=1
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type}
    ...    srsrp_nr=${srsrp_nr} srsrq_nr=${srsrq_nr}
    @{expect}     Create List     rrcReconfigurationComplete
    ...    activated successfully at airphone
    ...    physCellId ${phycell_id}
    ${ret}    Execute Egate Command    ${cmd}    pass_regexp=${expect}    timeout=120s
    Verify Throuput on Pcell and Scell    ue_id=${ue_id}    pcell_dl=${pcell_dl}    scell_dl=${scell_dl}    scell_id=${scell_id}

Trigger ScellSwap
    [Arguments]    ${event_type}=A6    ${carrierfreq}=127450    ${nrsrp_nr}=30    ${nrsrq_nr}=30    ${ue_id}=81    ${scell_id}=1
    ...    ${phycell_id}=63    ${pcell_dl}=0    ${scell_dl}=0    ${scell_id_1}=2
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type}
    ...    srsrp_nr=11 srsrq_nr=11 scell=${scell_id} scell_rsrp=20 scell_rsrq=20 phycell_id=${phycell_id}
    ...    nrsrp_nr=${nrsrp_nr} nrsrq_nr=${nrsrq_nr}
    Execute Egate Command    ${cmd}    pass_regexp=rrcReconfigurationComplete
    Verify Throuput on Pcell and Scell    ue_id=${ue_id}    pcell_dl=${pcell_dl}    scell_dl=${scell_dl}    scell_id=${scell_id_1}

trigger A1 Pcell Switch
    [Arguments]    ${event_type}=A1    ${carrierfreq}=127450    ${scell_rsrp}=127    ${ue_id}=81    ${scell_id}=1
    ...    ${source_cell}=13    ${target_cell}=12    ${pcell_dl}=0
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type} scell=${scell_id} scell_rsrp=${scell_rsrp}
    ${ret1}=    Execute Egate Command    ${cmd}
    ...    pass_regexp=drx-Config setup
    Should Contain    ${ret1}    Intra-eNB handover from EXT_ENB-2.${source_cell} to EXT_ENB-2.${target_cell}
    Should Contain    ${ret1}    drx-Config setup
    Should Contain    ${ret1}    drx-Config release
    Verify Throuput on Pcell    ue_id=${ue_id}    pcell_dl=${pcell_dl}

trigger A2 Pcell Switch
    [Arguments]    ${event_type}=A2    ${carrierfreq}=518910    ${srsrp_nr}=60    ${srsrq_nr}=11    ${ue_id}=81    ${scell_id}=2
    ...    ${source_cell}=2    ${target_cell}=13    ${pcell_dl}=0
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type} srsrp_nr=${srsrp_nr}
    ...    srsrq_nr=${srsrq_nr} scell=${scell_id} scell_rsrp=123 scell_rsrq=55
    ${ret1}=    Execute Egate Command     ${cmd}    pass_regexp=drx-Config setup
    Should Contain    ${ret1}    Intra-eNB handover from EXT_ENB-2.${source_cell} to EXT_ENB-2.${target_cell} performed
    Should Contain    ${ret1}    drx-Config setup
    Should Contain    ${ret1}    drx-Config release
    Verify Throuput on Pcell    ue_id=${ue_id}    pcell_dl=${pcell_dl}

A2 pcell switch and A1 pcell switch then A6 scell swap
    [Arguments]    ${ue_id}=81
    trigger A2 Pcell Switch    carrierfreq=518910    ue_id=${ue_id}    scell_id=3    source_cell=2    target_cell=13    pcell_dl=0
    Trigger ScellAdd or ScellChange    carrierfreq=424090    ue_id=${ue_id}    phycell_id=61    pcell_dl=0    scell_dl=0    #step20
    trigger A1 Pcell Switch    carrierfreq=127450    ue_id=${ue_id}    scell_id=1    source_cell=13    target_cell=12    pcell_dl=0    #step21
    Trigger ScellAdd or ScellChange    carrierfreq=127450    ue_id=${ue_id}    phycell_id=60    pcell_dl=0    scell_dl=0    #step22
    Trigger ScellSwap    carrierfreq=424090    ue_id=${ue_id}    scell_id=1    phycell_id=62    pcell_dl=0    scell_dl=0    #step23

Update UE capa
    [Arguments]    ${SA_Capa_perUE_Full}=none    ${ue_id}=1
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full}
    Execute Egate Command    ${cmd}





