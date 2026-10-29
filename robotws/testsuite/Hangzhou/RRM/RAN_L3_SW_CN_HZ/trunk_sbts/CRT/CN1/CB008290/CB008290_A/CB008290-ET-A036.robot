*** Settings ***
Documentation
...    author:  baijie.zhu@nokia-sbell.com
...    contact: baijie.zhu@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_VRF    RAN_5G_TDD    SBTS00    team-Blues_SGT&A    owner-ha.zheng
...    CLOUD_5G_I_BOO_AP_LOO    CRT    CB008290    release-5G23R1
...    STATE_CONFIGURED    RAN_5G
Resource    ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
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
...    @{same frequency}
...    @{NRREL}
...    @{8290_enable}
...    @{DRX}
...    @{A1pcellchange}
...    @{BOO_AP_LOO}

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
...    NRCELL-1/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-3:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-10:sCellOperationalMode=dlOnly
...    NRCELL-12/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-12/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-12/NRREL-3:sCellOperationalMode=dlOnly
...    NRCELL-12/NRREL-10:sCellOperationalMode=dlOnly
...    NRCELL-13/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-13/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-13/NRREL-3:sCellOperationalMode=dlOnly
...    NRCELL-13/NRREL-10:sCellOperationalMode=dlOnly
...    NRCELL-2/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-2/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-2/NRREL-3:sCellOperationalMode=dlOnly
...    NRCELL-2/NRREL-10:sCellOperationalMode=dlOnly

@{DRX}
...    NRCELL:actCDrx=true

@{8290_enable}
...    NRDU-1:actInterNumerologyCa=true
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRBTS-1:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS-1:actMeasBasedSCellAdditionNsa=true
...    NRBTS-1:actSCellSwapFr1=a6BasedSa
...    NRBTS-1:sCellActivationMethod=blind
...    NRCELL:sCellDeactivationTimerGNB=infinity
...    NRCELL:cellDepType=SA+NSA
...    NRCELL:actK1Opt=intra-gNB
...    NRCELL:a6MeasSCellSwapEnabled=rsrp
...    NRCELL:a6MeasSCellSwapSsbRsrp:a6HysteresisSCellSwapSsbRsrp=0|a6OffsetSCellSwapSsbRsrp=20|a6TimeToTrigSCellSwapSsbRsrp=ms480
...    NRCELL:a6MeasSCellSwapSsbRsrq:a6HysteresisSCellSwapSsbRsrq=0|a6OffsetSCellSwapSsbRsrq=20|a6TimeToTrigSCellSwapSsbRsrq=ms480
...    NRCELL:reportAmountA6MeasSCellSwap=infinity
...    NRCELL:reportIntervalA6MeasSCellSwap=ms1024
...    NRBTS/NRPMRNL-1:miNrCABMCCP=disabled
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
...    NRCELL:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0|a2ThresholdhoSsbRsrpSA=36|a2TimeToTriggerhoSsbRsrpSA=ms64
...    NRCELL:a3MeasEnabled=rsrp
...    NRCELL:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0|a3OffsetSsbRsrp=20|a3TimeToTriggerSsbRsrp=ms64
...    NRCELL:absThreshSsbRsrpConsolidation=1
...    NRCELL:sMeasConfigSsbRsrp=1
#...    NRCELL:a5MeasEnabled=rsrp
#...    NRCELL:a5MeasSsbRsrp:a5HysteresisSsbRsrp=0|a5Threshold1SsbRsrp=20|a5Threshold2SsbRsrp=40|a5TimeToTriggerSsbRsrp=ms64
...    NRCELL:a2MeasSCellRelEnabled=rsrp
...    NRCELL:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2ThresholdSCellRelSsbRsrp=34|a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-12:weightForSCellSelection=50
...    NRCELL-14:weightForSCellSelection=50
...    NRCELL-11:weightForSCellSelection=60
...    NRCELL-13:weightForSCellSelection=60
...    NRCELL-1:weightForSCellSelection=80
...    NRCELL-2:weightForSCellSelection=80
...    NRDU-1:carrierAggregationSupportList=ca_Fdd_Fdd,ca_Fdd_Fr1Tdd_Sa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa

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

@{NRCELL-13}
...    NRCELL-13:a2MeasSCellRelEnabled=none
...    NRCELL-13:a6MeasSCellSwapEnabled=none

@{NRCELL-1_1}
...    NRCELL-1:maxNumOfSCellAlloc=0

@{NRCELL-1_2}
...    NRCELL-1:maxNumOfSCellAlloc=250

${pdu_id}    1
${gw_id}    1
${nwslice}    1

*** Test Cases ***
CB008290-ET-A036_Verify_A6_config_swap_deconfig_with_DRX_blind_scell_activation_when_both_cell
    [Documentation]
    ...    1. This user scenario describes A6 configuration and swap with DRX blind scell activation when both cell
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
    ...         1). UE registers successfully and PDU session is setup successfully on cell 1, Start UL/DL data.
    ...             A1 meas for scell addition configured, mobility A2/A3 configured, DRX setup.
    ...             DL/UL throughput on TDD PCell can reach the expected value.
    ...         2). Measurement report to the gNB for A1 event, lower than a1ThresholdSCellAddSsbRsrpTDD,
    ...             higher than a1ThresholdSCellAddSsbRsrpFDD.
    ...             higher priority FDD cell11 addition successfully, Scell activated successfully,
    ...             A6 meas configed to UE, A2 meas for scell release configured, A2 meas for pcell switch configured.
    ...             DL/UL throughput on TDD PCell and FDD Scell can reach the expected value.
    ...         3). A2 for mobility measurement report from 5G-UE
    ...             A3 meas for inter-frequency ho configured, DRX release.
    ...             DL/UL throughput on TDD PCell and FDD Scell can reach the expected value.
    ...         4). A3 for mobility measurement report from 5G-UE.
    ...             inter frequency handover to FDD cell12 successfully,
    ...             deconfigures A6 meas for SCell swap,deconfigures A2 measurement for SCell Release, DRX setup.
    ...             DL/UL throughput on FDD PCell can reach the expected value.
    ...         5). Measurement report to the gNB for A1 event, lower than a1ThresholdSCellAddSsbRsrpTDD,
    ...             higher than a1ThresholdSCellAddSsbRsrpFDD.
    ...             higher priority FDD cell11 addition successfully, Scell activated successfully.
    ...             A6 meas configed to UE, A2 meas for scell release configured, A1 for scell change configured.
    ...             DL/UL throughput on FDD PCell and FDD Scell can reach the expected value.
    ...         6). nidd no configure A2 scell release and A6 scell swap in cell13
    ...             A6 for scell swap measurement report from 5G-UE
    ...             scell swap to FDD cell13 successfully, Scell activated successfully
    ...             meas ID and report config for A6/A2 removed
    ...             DL/UL throughput on FDD PCell and FDD Scell can reach the expected value.
    ...         7). set NRCELL-1:maxNumOfSCellAlloc=0,
    ...             Measurement report to the gNB for A1 event, higher than a1ThresholdSCellAddSsbRsrpTDD
    ...             higher priority TDD cell1 is OOS, SCell change to lower priority TDD cell2 successfully,
    ...             gNB reconfigure A2 for scell release, A6 for scell swap.
    ...             DL/UL throughput on FDD PCell and TDD Scell can reach the expected value.
    ...         8). set NRCELL-1:maxNumOfSCellAlloc=250, A6 for scell swap measurement report from 5G-UE
    ...             scell swap to TDD cell1 successfully, Scell activated successfully,
    ...             A6 meas reconfiged to UE, A2 meas for scell release reconfigured
    ...             DL/UL throughput on FDD PCell and TDD Scell can reach the expected value.
    ...         9). A2 for scell release measurement report from UE
    ...             scell release successfully, A6 for scell swap, A2 for scell release,A1 for scell change removed.
    ...             DL/UL throughput on FDD PCell can reach the expected value.
    ...         10).add 2nd pdu, Measurement report to the gNB for A1 event, higher than a1ThresholdSCellAddSsbRsrpTDD
    ...             higher priority TDD cell1 addition successfully, Scell activated successfully,
    ...             A6 meas configed to UE, A1 for pcell change, A2 meas for scell release configured
    ...             DL/UL throughput on FDD PCell and TDD Scell can reach the expected value.
    ...         11).A6 for scell swap measurement report from 5G-UE
    ...             scell swap to TDD cell2 successfully, Scell activated successfully ,
    ...             A6 meas configed to UE, A2 meas for scell release configured A1 for pcell change.
    ...             DL/UL throughput on FDD PCell and TDD Scell can reach the expected value.
    ...         12).A2 for mobility measurement report from 5G-UE
    ...             A3 meas for inter-frequency ho configured, DRX release.
    ...             DL/UL throughput on FDD PCell and TDD Scell can reach the expected value.
    ...         13).A3 for mobility measurement report from 5G-UE
    ...             inter frequency handover to another TDD cell1 successfully
    ...             deconfigures A6 meas for SCell swap,deconfigures A2 measurement for SCell Release,
    ...             new A1 for scell addition configured, DRX setup.
    ...             DL/UL throughput on TDD PCell can reach the expected value.
    ...         14).Measurement report to the gNB for A1 event, lower than a1ThresholdSCellAddSsbRsrpTDD,
    ...             higher than a1ThresholdSCellAddSsbRsrpFDD
    ...             higher priority FDD cell11 addition successfully, Scell activated successfully,
    ...             A6 meas configed to UE, A2 meas for scell release configured, A2 for pcell change.
    ...             DL/UL throughput on TDD PCell and FDD Scell can reach the expected value.
    ...         15).A6 for scell swap measurement report from 5G-UE
    ...             scell swap to FDD cell13 successfully, Scell activated successfully
    ...             A6 meas configed to UE, A2 meas for scell release configured
    ...             DL/UL throughput on TDD PCell and FDD Scell can reach the expected value.
    ...         16).A3 for mobility measurement report from 5G-UE
    ...             intra frequency to cell2, new A1 for scell addition configured.
    ...             DL/UL throughput on TDD PCell can reach the expected value, DRX release, then DRX setup.
    ...         17).Measurement report to the gNB for A1 event, lower than a1ThresholdSCellAddSsbRsrpTDD,
    ...             higher than a1ThresholdSCellAddSsbRsrpFDD
    ...             higher priority FDD cell11 addition successfully, Scell activated successfully,
    ...             A6 meas configed to UE, A2 meas for scell release configured, A2 for pcell change, DRX release, then DRX setup.
    ...             DL/UL throughput on TDD PCell and FDD Scell can reach the expected value
    ...         18).A6 for scell swap measurement report from 5G-UE
    ...             scell swap to FDD cell13 successfully, Scell activated successfully
    ...             DL/UL throughput on TDD PCell and FDD Scell can reach the expected value
    ...         19).A2 for Pcell switch measurement report from 5G-UE
    ...             Pcell switch to FDD cell13 successfully, A1 for scell addition configured.
    ...             DL/UL throughput on FDD PCell can reach the expected value
    ...         20).Measurement report to the gNB for A1 event, lower than a1ThresholdSCellAddSsbRsrpTDD,
    ...             higher than a1ThresholdSCellAddSsbRsrpFDD
    ...             higher priority FDD cell12 addition successfully, Scell activated successfully
    ...             A6 meas configed to UE, A2 meas for scell release configured, A1 for scell change configured,
    ...             A1 for pcell change configured.
    ...             DL/UL throughput on FDD PCell and FDD Scell can reach the expected value
    ...         21).A1 for Pcell switch measurement report from 5G-UE
    ...             Pcell switch to FDD cell12 successfully, A1 for scell addition configured.
    ...             DL/UL throughput on FDD PCell can reach the expected value
    ...         22).Measurement report to the gNB for A1 event, lower than a1ThresholdSCellAddSsbRsrpTDD,
    ...             higher than a1ThresholdSCellAddSsbRsrpFDD
    ...             higher priority FDD cell3 addition successfully, Scell activated successfully,
    ...             A6 meas configed to UE, A2 meas for scell release configured, A1 for scell change configured
    ...             DL/UL throughput on FDD PCell and FDD Scell can reach the expected value
    ...         23).A6 for scell swap measurement report from 5G-UE
    ...             cell swap to FDD cell13 successfully, Scell activated successfully,
    ...             A6 for scell swap, A2 for scell release
    ...             DL/UL throughput on FDD PCell and FDD Scell can reach the expected value
    ...         24).A1 for scell change measurement report from 5G-UE
    ...             SCell change to higher priority TDD cell1 successfully,
    ...             A6/A2/A1 for scell4 released, and new A6/A2/A1 for scell6 configured
    ...         25).A2 for scell release measurement report from UE
    ...             scell release successfully
    ...             DL/UL throughput on FDD PCell can reach the expected value.
    ...         26).release UE
    ...             UE release successfully
    [Tags]    QC_47026    owner-ha.zheng    A036
    inter frequency ho then A6 scell swap
    scell change then A6 scell swap and A2 scell release then add 2nd PDU and A6 scell swap
    inter frequency ho then A6 scell swap and intra frequency ho then A6 scell swap
    A2 pcell switch and A1 pcell switch then A6 scell swap
    scell change then A2 scell release
    Check Wireshark Log    ${CURDIR}${/}a2a_CB008290A036${/}a2a.ini    wait_string=UEContextReleaseComplete::4

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_2T4F_2N41_2N71_2N66

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir

UE Attach To Target Cell
    [Arguments]    ${cell_id}=1    ${ue_id}=81    ${pcell_dl}=300
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    ${ret1}=    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=${gw_id} nwslice=${nwslice}    QoS Routing Table
    Should Contain    ${ret1}    drx-Config setup
    Send Throuput
    Verify Throuput on Pcell    pcell_dl=${pcell_dl}

Send Throuput
    [Arguments]    ${ue_id}=81
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=3    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=4    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=ul mbps=10 trf_id=1    UE ${ue_id}: UDP UL
    sleep    30s    #sleep for stable traffic

Verify Throuput on Pcell
    [Arguments]    ${ue_id}=81    ${pcell_dl}=60    ${ul}=8
    sleep    10s    #sleep for stable traffic
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000>${pcell_dl}
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul}

Verify Throuput on Pcell and Scell
    [Arguments]    ${ue_id}=81    ${pcell_dl}=10    ${scell_dl}=10    ${ul}=8    ${scell_id}=1
    sleep    10s     #sleep for stable traffic
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000 > ${pcell_dl}
    ${scell_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${scell_id}    type=pdsch    rate_type=ave
    Should Be True    ${scell_tput}/1000 > ${scell_dl}
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
    ${ret}    Execute Egate Command    ${cmd}    pass_regexp=${expect}    timeout=10s
    Verify Throuput on Pcell and Scell    pcell_dl=${pcell_dl}    scell_dl=${scell_dl}    scell_id=${scell_id}

Trigger ScellSwap
    [Arguments]    ${event_type}=A6    ${carrierfreq}=127450    ${nrsrp_nr}=30    ${nrsrq_nr}=30    ${ue_id}=81    ${scell_id}=1
    ...    ${phycell_id}=63    ${pcell_dl}=0    ${scell_dl}=0    ${scell_id_1}=2
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type}
    ...    srsrp_nr=11 srsrq_nr=11 scell=${scell_id} scell_rsrp=20 scell_rsrq=20 phycell_id=${phycell_id}
    ...    nrsrp_nr=${nrsrp_nr} nrsrq_nr=${nrsrq_nr}
    Execute Egate Command    ${cmd}    pass_regexp=rrcReconfigurationComplete
    Verify Throuput on Pcell and Scell    pcell_dl=${pcell_dl}    scell_dl=${scell_dl}    scell_id=${scell_id_1}

trigger A2 event
    [Arguments]    ${event_type}=A2    ${carrierfreq}=518910    ${ue_id}=81
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type} srsrp_nr=7 srsrq_nr=7
    ...    pass_regexp=rrcReconfigurationComplete
    Should Contain    ${ret1}    drx-Config release

trigger A3 event
    [Arguments]    ${event_type}=A3    ${carrierfreq}=127450    ${srsrp_nr}=20    ${srsrq_nr}=20    ${ue_id}=81
    ...    ${phycell_id}=61    ${nrsrp_nr}=61    ${nrsrq_nr}=61    ${source_cell}=1    ${target_cell}=12
    ...    ${drx}=${EMPTY}    ${pcell_dl}=0
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type} srsrp_nr=${srsrp_nr}
    ...    srsrq_nr=${srsrq_nr} phycell_id=${phycell_id} nrsrp_nr=${nrsrp_nr} nrsrq_nr=${nrsrq_nr}
    ${ret1}=    Execute Egate Command    ${cmd}
    ...    pass_regexp=drx-Config setup
    Should Contain    ${ret1}    Intra-eNB handover from EXT_ENB-2.${source_cell} to EXT_ENB-2.${target_cell} performed
    Should Contain    ${ret1}    drx-Config setup
    Should Contain    ${ret1}    ${drx}
    Verify Throuput on Pcell    pcell_dl=${pcell_dl}

trigger A2 Scell Release
    [Arguments]    ${event_type}=A2    ${carrierfreq}=518910    ${srsrp_nr}=7    ${srsrq_nr}=7    ${ue_id}=81    ${scell_id}=2
    ...    ${pcell_dl}=0
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type} scell=${scell_id}
    ...    srsrp_nr=${srsrp_nr} srsrq_nr=${srsrq_nr}
    ${ret1}=    Execute Egate Command    ${cmd}    pass_regexp=rrcReconfigurationComplete
    Verify Throuput on Pcell    pcell_dl=${pcell_dl}

Add 2nd PDU
    Execute Egate Command    ue_pdu_session_setup ue=81 pdu=2 gw=2 nwslice=1    pass_regexp=Pdu Session Resource Setup

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
    Verify Throuput on Pcell    pcell_dl=${pcell_dl}

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
    Verify Throuput on Pcell    pcell_dl=${pcell_dl}

inter frequency ho then A6 scell swap
    OnlineParamChange    ${NRCELL-13}
    UE Attach To Target Cell    #step1
    Trigger ScellAdd or ScellChange    carrierfreq=518910    phycell_id=60    pcell_dl=250    scell_dl=30    #step2
    trigger A2 event    #step3
    trigger A3 event    pcell_dl=0    #step4-tp 62
    Trigger ScellAdd or ScellChange    carrierfreq=127450    phycell_id=60    pcell_dl=0    scell_dl=30    #step5
    Trigger ScellSwap    carrierfreq=424090    scell_id=1    phycell_id=62    pcell_dl=0    scell_dl=30    #step6

scell change then A6 scell swap and A2 scell release then add 2nd PDU and A6 scell swap
    OnlineParamChange    ${NRCELL-1_1}    #step7
    Trigger ScellAdd or ScellChange    carrierfreq=127450    phycell_id=51    srsrp_nr=91    pcell_dl=0    scell_dl=250
    OnlineParamChange    ${NRCELL-1_2}    #step8
    Trigger ScellSwap    carrierfreq=518910    scell_id=1    phycell_id=50    pcell_dl=0    scell_dl=250
    trigger A2 Scell Release    carrierfreq=518910    scell_id=2    pcell_dl=0    #step9
    Add 2nd PDU
    Trigger ScellAdd or ScellChange    carrierfreq=127450    phycell_id=50    srsrp_nr=91    pcell_dl=0    scell_dl=250    #step10
    Trigger ScellSwap    carrierfreq=518910    scell_id=1    phycell_id=51    pcell_dl=0    scell_dl=250    #step11

inter frequency ho then A6 scell swap and intra frequency ho then A6 scell swap
    trigger A2 event    carrierfreq=127450    #step12
    trigger A3 event    carrierfreq=518910    phycell_id=50    source_cell=12    target_cell=1    pcell_dl=250    #step13
    Trigger ScellAdd or ScellChange    carrierfreq=518910    phycell_id=60    pcell_dl=250    scell_dl=60    #step14
    Trigger ScellSwap    carrierfreq=424090    scell_id=1    phycell_id=62    pcell_dl=250    scell_dl=60    #step15
    trigger A3 event    carrierfreq=518910    phycell_id=51    source_cell=1    target_cell=2    drx=drx-Config release    pcell_dl=250    #step16
    Trigger ScellAdd or ScellChange    carrierfreq=518910    phycell_id=60    pcell_dl=250    scell_dl=60    #step17
    Trigger ScellSwap    carrierfreq=424090    scell_id=1    phycell_id=62    pcell_dl=250    scell_dl=60    #step18

A2 pcell switch and A1 pcell switch then A6 scell swap
    trigger A2 Pcell Switch    carrierfreq=518910    scell_id=2    source_cell=2    target_cell=13    pcell_dl=0    #step19
    Trigger ScellAdd or ScellChange    carrierfreq=424090    phycell_id=61    pcell_dl=0    scell_dl=40    #step20
    trigger A1 Pcell Switch    carrierfreq=127450    scell_id=1    source_cell=13    target_cell=12    pcell_dl=0    #step21
    Trigger ScellAdd or ScellChange    carrierfreq=127450    phycell_id=60    pcell_dl=0    scell_dl=40    #step22
    Trigger ScellSwap    carrierfreq=424090    scell_id=1    phycell_id=62    pcell_dl=0    scell_dl=40    #step23

scell change then A2 scell release
    Trigger ScellAdd or ScellChange    carrierfreq=127450    phycell_id=50    srsrp_nr=91    pcell_dl=0    scell_dl=250    #step24
    trigger A2 Scell Release    carrierfreq=518910    scell_id=1    pcell_dl=0    #step25
    UE Deregister From gNB    81    #step26






