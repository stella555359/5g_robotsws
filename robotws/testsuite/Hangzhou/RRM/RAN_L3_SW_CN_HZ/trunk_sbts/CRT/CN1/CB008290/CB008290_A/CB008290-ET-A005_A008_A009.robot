*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    RAN_5G_TDD    SBTS00    team-Blues_SGT&A    owner-ha.zheng
...    CLOUD_5G_I_BOO_AP_LOO    CRT    CB008290    release-5G23R1    owner-zora.wang
...    STATE_CONFIGURED    RAN_5G
Resource    ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
${DEBUG_LOG_LEVEL}    4
@{PARAMS_IN_SCF}
...    NRBTS-1:cipherPrefL:nea0=8
...    NRBTS-1:cipherPrefL:nea1_128=0
...    NRBTS-1:cipherPrefL:nea2_128=0
...    NRBTS-1:cipherPrefL:nea3_128=0
...    NRBTS-1:integrityProtPrefL:nia0=0
...    NRBTS-1:integrityProtPrefL:nia1_128=0
...    NRBTS-1:integrityProtPrefL:nia2_128=0
...    NRBTS-1:integrityProtPrefL:nia3_128=9
...    @{PARAMS_FOR_IODT_ABIO_4T2F}
...    @{same frequency}
...    @{NRREL}
...    @{8290_enable}
...    @{BOO_AP_LOO}

@{BOO_AP_LOO}
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-7:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-7:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-8:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-8:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-7:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-7:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-8:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-8:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-7:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-7:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-8:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-8:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-7:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-7:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-8:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-8:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1
...    NRCELL:actUlSrsBm=false
...    NRCELL:actDlSrsBm=false

...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=1
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=1
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=9|searchSpaceId=1
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=1
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=1
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n4|searchSpaceId=1
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n2|searchSpaceId=1
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n1|searchSpaceId=1
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|searchSpaceId=1
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=1
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=4|searchSpaceId=1
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=2
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=2
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=2
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=2
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=2
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n4|searchSpaceId=2
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=2
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=2
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=2
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=2
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=2
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=3
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=3
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=2|searchSpaceId=3
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=3
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=3
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n4|searchSpaceId=3
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n2|searchSpaceId=3
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n1|searchSpaceId=3
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceId=3
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=3
...    BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=3

...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=4
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=4
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=9|searchSpaceId=4
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=4
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=4
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n4|searchSpaceId=4
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n2|searchSpaceId=4
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n1|searchSpaceId=4
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|searchSpaceId=4
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=4
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=4|searchSpaceId=4
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=5
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=5
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=5
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=5
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=5
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=5
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=5
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=5
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=5
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=5
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=5
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=6
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=6
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=2|searchSpaceId=6
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=6
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=6
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n4|searchSpaceId=6
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n2|searchSpaceId=6
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n1|searchSpaceId=6
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceId=6
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=6
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=6

@{NRREL}
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-1:gNbId=1
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-1:removeNotAllowed=false
...    NRCELL-1/NRREL-1:lcrId=3
...    NRCELL-1/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-1:sCellPrio=1
...    NRCELL-1/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-2:gNbId=1
...    NRCELL-1/NRREL-2:gNbIdLength=22
...    NRCELL-1/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-2:removeNotAllowed=false
...    NRCELL-1/NRREL-2:lcrId=4
...    NRCELL-1/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-2:sCellPrio=2
...    NRCELL-1/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-3:gNbId=1
...    NRCELL-1/NRREL-3:gNbIdLength=22
...    NRCELL-1/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-3:removeNotAllowed=false
...    NRCELL-1/NRREL-3:lcrId=11
...    NRCELL-1/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-3:sCellPrio=1
...    NRCELL-1/NRREL-3:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-4:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-4:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-4:gNbId=1
...    NRCELL-1/NRREL-4:gNbIdLength=22
...    NRCELL-1/NRREL-4:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-4:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-4:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-4:removeNotAllowed=false
...    NRCELL-1/NRREL-4:lcrId=12
...    NRCELL-1/NRREL-4:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-4:sCellPrio=2
...    NRCELL-1/NRREL-4:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-1:gNbId=1
...    NRCELL-11/NRREL-1:gNbIdLength=22
...    NRCELL-11/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-1:removeNotAllowed=false
...    NRCELL-11/NRREL-1:lcrId=3
...    NRCELL-11/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-1:sCellPrio=1
...    NRCELL-11/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-2:gNbId=1
...    NRCELL-11/NRREL-2:gNbIdLength=22
...    NRCELL-11/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-2:removeNotAllowed=false
...    NRCELL-11/NRREL-2:lcrId=4
...    NRCELL-11/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-2:sCellPrio=2
...    NRCELL-11/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-3:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-4:sCellOperationalMode=dlOnly

@{8290_enable}
...    NRDU-1:actInterNumerologyCa=true
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRBTS-1:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS-1:actMeasBasedSCellAdditionNsa=true
...    NRBTS-1:actSCellSwapFr1=a6BasedSa
...    NRBTS-1:sCellActivationMethod=bufferBased
...    NRCELL:cellDepType=SA+NSA

...    NRCELL:actK1Opt=intra-gNB
...    NRCELL:a6MeasSCellSwapEnabled=rsrp
...    NRCELL:a6MeasSCellSwapSsbRsrp:a6HysteresisSCellSwapSsbRsrp=0|a6OffsetSCellSwapSsbRsrp=6|a6TimeToTrigSCellSwapSsbRsrp=ms480
...    NRCELL:a6MeasSCellSwapSsbRsrq:a6HysteresisSCellSwapSsbRsrq=0|a6OffsetSCellSwapSsbRsrq=6|a6TimeToTrigSCellSwapSsbRsrq=ms480
...    NRCELL:reportAmountA6MeasSCellSwap=infinity
...    NRCELL:reportIntervalA6MeasSCellSwap=ms1024
...    NRCELL:thresholdSCellSwapSourceRsrp=56
...    NRCELL:thresholdSCellSwapSourceRsrq=66
...    NRCELL:a1MeasSCellAddEnabled=rsrp
...    NRCELL:a2MeasSCellRelEnabled=rsrp
...    NRCELL:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=70|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=80|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrq:a1HysteresisSCellAddSsbRsrq=0|a1TimeToTriggerSCellAddSsbRsrq=320ms
...    NRCELL:a1MeasSCellAddSsbRsrq:a1ThresholdSCellAddSsbRsrq=30|a1TimeToTriggerSCellAddSsbRsrq=320ms
...    NRCELL:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=480ms
...    NRCELL:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=34|a2TimeToTriggerSCellRelSsbRsrp=480ms
...    NRCELL:a2MeasSCellRelSsbRsrq:a2HysteresisSCellRelSsbRsrq=0|a2TimeToTriggerSCellRelSsbRsrq=480ms
...    NRCELL:a2MeasSCellRelSsbRsrq:a2ThresholdSCellRelSsbRsrq=5|a2TimeToTriggerSCellRelSsbRsrq=480ms
...    NRCELL-1:weightForSCellSelection=70
...    NRCELL-2:weightForSCellSelection=70
...    NRCELL-3:weightForSCellSelection=60
...    NRCELL-4:weightForSCellSelection=60
...    NRCELL-11:weightForSCellSelection=40
...    NRCELL-12:weightForSCellSelection=40
...    NRDU-1:carrierAggregationSupportList=ca_Fdd_Fr1Tdd_Sa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fdd_Fr1Tdd_Nsa,ca_Fr1Tdd_Fdd_Nsa,ca_Fr1Tdd_Nsa

@{same frequency}
...    MRBTS-1/NRBTS-1/NRCELL-1:chBw=80MHz
...    MRBTS-1/NRBTS-1/NRCELL-2:gscnOrSsPbchArfcn=7840
...    MRBTS-1/NRBTS-1/NRCELL-2:nrarfcn=633000
...    MRBTS-1/NRBTS-1/NRCELL-2:chBw=80MHz
...    MRBTS-1/NRBTS-1/NRCELL-2:type0CoresetConfigurationIndex=12
...    MRBTS-1/NRBTS-1/NRCELL-12:gscnOrSsPbchArfcn=1562
...    MRBTS-1/NRBTS-1/NRCELL-12/NRCELL_FDD-1:nrarfcnDl=124900
...    MRBTS-1/NRBTS-1/NRCELL-12/NRCELL_FDD-1:nrarfcnUl=134100
...    MRBTS-1/NRBTS-1/NRCELL-12/NRCELL_FDD-1:chBwDl=10MHz
...    MRBTS-1/NRBTS-1/NRCELL-12/NRCELL_FDD-1:chBwUl=10MHz
...    MRBTS-1/NRBTS-1/NRCELL-12:type0CoresetConfigurationIndex=7

@{OnlineParamChange_A005}
...    NRBTS-1:actSCellSwapFr1=disabled
...    NRCELL-3:maxNumOfSCellAlloc=0
...    NRCELL-11:maxNumOfSCellAlloc=0

@{OnlineParam_A005_recover}
...    NRBTS-1:actSCellSwapFr1=a6BasedSa
...    NRCELL:maxNumOfSCellAlloc=250

@{OnlineParamChange_A009}
...    NRCELL-3:maxNumOfSCellAlloc=0
...    NRCELL-11:maxNumOfSCellAlloc=0

@{OnlineParam_A009_recover}
...    NRCELL:maxNumOfSCellAlloc=250

${SA_Capa_Support}        SEPARATOR=
...    E9A09000575F5A13160003C1A00B0498B800CE1E82813641873E618F28581C130080C4700FB8D85181AC1184341020E90
...    186D6C98AB1A1CF88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE0005800702A0D883AC1184341020F1018656C98
...    AB121CFB027C471E31238F21CFA8E7CC31E50B0381C3C27F6000001FD8000000B000E0551B137582308682041D2030C2D931544439F11C78
...    8E3D033EC09F18E7CC31E50B0381C3C17003FF001C00FFC000B000E0571F11B582308682041F280C2AB64C55850E7C471E30000000000000
...    0000010387809FFF000007FFC000002C003801EF0F1340038820000042C040A83C28000E230000010B02B0F11800388200000C2C0AC3C280
...    00E208000010B02B0F13400388C0000042C0AC5C46000E208007104000028581587850001C4D00000C160562E2680071040038500000102C
...    0AC5C4D000E23000711800001058158B850001C41000E230000020B02B170A0003882001C41000004160562E26800710400388C0000082C0
...    AC5C28000E23000711800001058158B89A001C46000E140000040B02B0F11800388C00000C2C0803808D00A2026C041074BB07C28913639F
...    0E14489B1CF870A244D8E7C3851226C73E1C28913639F0E2448913639F0E14081B1CF811204081B1CF811204081B1CF811204081B1CF8112
...    04081B1CF811204081B1CF811204081B1CF811204081B1CF810A040D8E7C00170F18C6318C6318C6318C61E8260078005038280381803A01
...    C0018090010180F82400800000004000008020000000100000200800002004000018020000100100000A008004010040100000C008000070
...    0400200000008000080040000480200000C010000140080000B004002048120080000C0339535953582958195833582B594B5933580B581B
...    58095811583B40D04000025949410000196525040000A594901000039652404000125949010000596524040001A594901000079652404000
...    225949010000996524040002A5949010000B96525040003259490100003165240334AAAE955552A8BA55154162A82C55068AA531549A2A80
...    C55028AA4D5541E28282F012A05028140A05028140A05028140A05028140A0502800304040300601002004202004010080600C2010020040
...    4030060100C018202018030080600C201002004040300601002004402018030080600C0201803040400802010020086A87C0004080C10181
...    C282C30344044484C5060646C70747C8494989CA0A4A8B4BD05060B40

${MRDC_Capa_Support}    SEPARATOR=
...    A11FF83BC4C0C03850001C46000000162205E260601C4D000E230000000B1102F130300E26800710400000058881789
...    818070A00038820000002C040BC4C0C03882001C46000002160205E360601C46000E208007104000010580817898180713400385000000C2
...    C040804808D00A001C041809A1E80B907893A244D8E7C3893A244D8E7C3893A244D8E7C3893A244D8E7C3893A24498E7D1A7448912639F44
...    9D1224C73E01A0718C6318C60C02080002010100200804030061000040202004008080600C3000080404030060100C018040300610000402
...    02004010080100400000000

*** Test Cases ***
CB008290-ET-A005_Verify_scell_addition_failed_with_high_sCellPrio_and_will_not_retry_low_sCellPrio_scell_for_NSA_call_when_actSCellSwapFr1_disabled
    [Documentation]
    ...    1. This user scenario Verify_scell_addition_failed_with_high_sCellPrio_and_will_not_retry_low_sCellPrio_
    ...        scell_for_NSA_call_when_actSCellSwapFr1_disabled_and_both_cell_type
    ...    2. Configuration:
    ...        TDD Cell1/Cell2 configure to same frequency, TDD Cell3/Cell4 configure to another same frequency.
    ...        FDD cell11/cell12 configure to same frequency.
    ...        Configure CA Relations: Cell1-Cell3, Cell1-Cell4, Cell1-Cell11, Cell1-Cell12, Cell11-Cell3, Cell11-Cell4
    ...        NRBTS-1/NRCELL-3:maxNumOfSCellAlloc = 0, NRBTS-1/NRCELL-11:maxNumOfSCellAlloc = 0,NRBTS-1:actSCellSwapFr1=disabled
    ...    3. Test Case Steps:
    ...         a. NSA UE91 attach to NRCELL-11 successfully and bearer is setup successfully.
    ...            A1 measurement rsrp for TDD with a1ThresholdSCellAddSsbRsrpTDD for SCell Addition.
    ...         b. UE sends A1 measurement higher than a1ThresholdSCellAddSsbRsrpTDD.
    ...            higher priority TDD scell3 addition failure due to AC failure and will not retry the lower priority one.
    ...         c. UE detach successfully.
    ...         d. NSA UE91 attach to NRCELL-1 successfully and bearer is setup successfully.
    ...            A1 measurement rsrp for FDD with a1ThresholdSCellAddSsbRsrpFDD for SCell Addition.
    ...         e. UE sends A1 measurement higher than a1ThresholdSCellAddSsbRsrpTDD.
    ...            higher priority TDD scell3 addition failure due to AC failure and will not retry the lower priority one.
    ...         f. UE detach successfully.
    ...         g. NSA UE91 attach to NRCELL-1 successfully and bearer is setup successfully.
    ...            A1 measurement rsrp for FDD with a1ThresholdSCellAddSsbRsrpFDD for SCell Addition.
    ...         h. UE sends A1 measurement higher than a1ThresholdSCellAddSsbRsrpFDD.
    ...            higher priority FDD scell11 addition failure due to AC failure and will not retry the lower priority one.
    ...         i. UE detach successfully.
    [Tags]    QC_219244    owner-zora    A005
    OnlineParamChange    ${OnlineParamChange_A005}
    Update UE capa    91    ${SA_Capa_Support}    ${MRDC_Capa_Support}
    Scell Addtion failed due to AC failure    cell_id=11    ue_id=91    pcell_dl=70    ul=25    carrierfreq=125050
    Scell Addtion failed due to AC failure    cell_id=1    ue_id=91    pcell_dl=750    ul=130
    Scell Addtion failed due to AC failure    cell_id=1    ue_id=91    pcell_dl=750    ul=130    srsrp_nr=71
    [Teardown]    A005_Teardown

CB008290-ET-A008_Verify_scell_with_high_sCellPrio_will_be_selected_for_NSA_call_when_actSCellSwapFr1_enabled_and_both_cell_type
    [Documentation]
    ...    1. This user scenario Verify scell_with_high_sCellPrio_will_be_selected_for_NSA_call_
    ...        when_actSCellSwapFr1_enabled_and_both_cell_type
    ...    2. Configuration:
    ...        TDD Cell1/Cell2 configure to same frequency, TDD Cell3/Cell4 configure to another same frequency.
    ...        FDD cell11/cell12 configure to same frequency.
    ...        Configure CA Relations: Cell1-Cell3, Cell1-Cell4, Cell1-Cell11, Cell1-Cell12, Cell11-Cell3, Cell11-Cell4
    ...    3. Test Case Steps:
    ...         a. NSA UE91 attach to NRCELL-11 successfully and bearer is setup successfully.
    ...            A1 measurement rsrp for TDD with a1ThresholdSCellAddSsbRsrpTDD for SCell Addition.
    ...         b. UE sends A1 measurement higher than a1ThresholdSCellAddSsbRsrpTDD.
    ...            higher priority TDD scell3 addition successfully.and no A6 meas config.
    ...         c. A2 SCell release successfully, UE detach successfully.
    ...         d. NSA UE91 attach to NRCELL-1 successfully and bearer is setup successfully.
    ...            A1 measurement rsrp for FDD with a1ThresholdSCellAddSsbRsrpFDD for SCell Addition.
    ...         e. UE sends A1 measurement higher than a1ThresholdSCellAddSsbRsrpTDD.
    ...            higher priority TDD scell3 addition successfully.and no A6 meas config.
    ...         f. A2 SCell release successfully, UE detach successfully.
    ...         g. NSA UE91 attach to NRCELL-1 successfully and bearer is setup successfully.
    ...            A1 measurement rsrp for FDD with a1ThresholdSCellAddSsbRsrpFDD for SCell Addition.
    ...         h. UE sends A1 measurement higher than a1ThresholdSCellAddSsbRsrpFDD.
    ...            higher priority FDD scell11 addition successfully.and no A6 meas config.
    ...         i. A2 SCell release successfully, UE detach successfully.
    [Tags]    QC_219245    owner-zora    A008
    Update UE capa    91    ${SA_Capa_Support}    ${MRDC_Capa_Support}
    NSA FT high scellPrio scell will be select with actScellSwapFr1 enable
    NSA TT high scellPrio scell will be select with actScellSwapFr1 enable
    NSA TF high scellPrio scell will be select with actScellSwapFr1 enable
    Check Wireshark Log    ${CURDIR}${/}a2a_CB008290A008${/}a2a.ini    wait_string=UEContextReleaseComplete::6
    [Teardown]    Common Test Teardown And Stop Capture Logs

#CB008290-ET-A009_Verify_scell_addition_failed_with_high_sCellPrio_and_will_not_retry_low_sCellPrio_scell_for_NSA_call_when_actSCellSwapFr1_enabled
#    [Documentation]
#    ...    1. This user scenario Verify scell addition failed with high sCellPrio and will not retry low sCellPrio scell
#    ...       for NSA call when actSCellSwapFr1 disabled and both cell type.
#    ...    2. Configuration:
#    ...        TDD Cell1/Cell2 configure to same frequency, TDD Cell3/Cell4 configure to another same frequency.
#    ...        FDD cell11/cell12 configure to same frequency.
#    ...        Configure CA Relations: Cell1-Cell3, Cell1-Cell4, Cell1-Cell11, Cell1-Cell12, Cell11-Cell3, Cell11-Cell4
#    ...        NRBTS-1/NRCELL-3:maxNumOfSCellAlloc = 0, NRBTS-1/NRCELL-11:maxNumOfSCellAlloc = 0
#    ...    3. Test Case Steps:
#    ...         a. NSA UE91 attach to NRCELL-11 successfully and bearer is setup successfully.
#    ...            A1 measurement rsrp for TDD with a1ThresholdSCellAddSsbRsrpTDD for SCell Addition.
#    ...         b. UE sends A1 measurement higher than a1ThresholdSCellAddSsbRsrpTDD.
#    ...            higher priority TDD scell3 addition failure due to AC failure and will not retry the lower priority one.
#    ...         c. UE detach successfully.
#    ...         d. NSA UE91 attach to NRCELL-1 successfully and bearer is setup successfully.
#    ...            A1 measurement rsrp for FDD with a1ThresholdSCellAddSsbRsrpFDD for SCell Addition.
#    ...         e. UE sends A1 measurement higher than a1ThresholdSCellAddSsbRsrpTDD.
#    ...            higher priority TDD scell3 addition failure due to AC failure and will not retry the lower priority one.
#    ...         f. UE detach successfully.
#    ...         g. NSA UE91 attach to NRCELL-1 successfully and bearer is setup successfully.
#    ...            A1 measurement rsrp for FDD with a1ThresholdSCellAddSsbRsrpFDD for SCell Addition.
#    ...         h. UE sends A1 measurement higher than a1ThresholdSCellAddSsbRsrpFDD.
#    ...            higher priority FDD scell11 addition failure due to AC failure and will not retry the lower priority one.
#    ...         i. UE detach successfully.
#    [Tags]    QC_219246    owner-ha.zheng    A009
#    OnlineParamChange    ${OnlineParamChange_A009}
#    Update UE capa    91    ${SA_Capa_Support}    ${MRDC_Capa_Support}
#    Scell Addtion failed due to AC failure    cell_id=11    ue_id=91    pcell_dl=80    ul=25    carrierfreq=125050
#    Scell Addtion failed due to AC failure    cell_id=1    ue_id=91    pcell_dl=750    ul=130
#    Scell Addtion failed due to AC failure    cell_id=1    ue_id=91    pcell_dl=750    ul=130    srsrp_nr=71
#    [Teardown]    A009_Teardown

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_4T2F

Modify Cfg
    ${V2}    catenate
    ...    set_sgw id=1 s5u_rcv_buff_size=20M s1u_snd_buff_size=20M s1u_rcv_buff_size=20M gtpu_read_packets_threshold=10
    update cfg param    ${V2}
    ${V1}    catenate
    ...    set_pgw id=1 type=simulated sgi_rcv_buff_size=20M sgi_snd_buff_size=20M
    ...    s5u_rcv_buff_size=20M s5u_snd_buff_size=20M gtpu_read_packets_threshold=10
    update cfg param    ${V1}

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir

Update UE capa
    [Arguments]    ${ue_id}=91    ${SA_Capa_perUE_Full}=none    ${CAPA_LTE}=none
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full} dual_conn=eutra_nr
    ...    ue_eutra_nr_capabilities=${CAPA_LTE}
    Execute Egate Command    ${cmd}

UE Attach To Target Cell
    [Arguments]    ${cell_id}=11    ${ue_id}=91
    Execute Egate Command    ue_attach id=${ue_id}    UE IS ACTIVE
    Execute Egate Command    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${cell_id} bearer=2 type=split_scg
    ...    reported successful RA

Send Throuput
    [Arguments]    ${ue_id}=91
    Execute Egate Command    trf_data_start ue=${ue_id} id=2 dir=dl mbps=175 trf_id=1    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} id=2 dir=dl mbps=175 trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} id=2 dir=dl mbps=175 trf_id=3    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} id=2 dir=dl mbps=175 trf_id=4    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} id=2 dir=dl mbps=175 trf_id=5    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} id=2 dir=dl mbps=175 trf_id=6    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} id=2 dir=dl mbps=175 trf_id=7    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} id=2 dir=dl mbps=175 trf_id=8    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} id=2 dir=ul mbps=175 trf_id=1    UE ${ue_id}: UDP UL
    sleep    30s    #sleep for stable traffic

Verify Throuput on Pscell
    [Arguments]    ${ue_id}=91    ${pcell_dl}=700    ${ul}=130
    sleep    10s    #sleep for stable traffic
    ${scell8_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=8    type=pdsch    rate_type=ave
    Should Be True    ${scell8_tput}/1000>${pcell_dl}
    ${ul_throughput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=8    type=pusch    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul}

UE Detach
    [Arguments]    ${ue_id}=91
    Execute Egate Command    ue_detach id=${ue_id}    detached

Trigger ScellAdd failed
    [Arguments]    ${event_type}=A1    ${carrierfreq}=632736    ${srsrp_nr}=81    ${srsrq_nr}=50    ${ue_id}=91
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type}
    ...    srsrp_nr=${srsrp_nr} srsrq_nr=${srsrq_nr}
    ${ret1}=    Execute Egate Command    ${cmd}    pass_regexp=measurementReport
    Should Not Contain    ${ret1}    rrcConnectionReconfigurationComplete

Scell Addtion failed due to AC failure
    [Arguments]    ${cell_id}=11    ${ue_id}=91    ${pcell_dl}=700    ${ul}=130    ${carrierfreq}=632736    ${srsrp_nr}=81
    UE Attach To Target Cell    ${cell_id}    ${ue_id}
    Send Throuput    ${ue_id}
    Verify Throuput on Pscell    ${ue_id}    ${pcell_dl}    ${ul}
    Trigger ScellAdd failed    carrierfreq=${carrierfreq}    srsrp_nr=${srsrp_nr}
    UE Detach    ${ue_id}

Verify Throuput on Pscell and Scell
    [Arguments]    ${ue_id}=91    ${pcell_dl}=700    ${ul}=130    ${scell_dl}=200
    sleep    10s     #sleep for stable traffic
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=8    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000 > ${pcell_dl}
    ${scell_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=9    type=pdsch    rate_type=ave
    Should Be True    ${scell_tput}/1000 > ${scell_dl}
    ${ul_throughput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=8    type=pusch    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul}

A009_Teardown
    OnlineParamChange    ${OnlineParam_A009_recover}
    Common Test Teardown And Stop Capture Logs

A005_Teardown
    OnlineParamChange    ${OnlineParam_A005_recover}
    Common Test Teardown And Stop Capture Logs

NSA FT high scellPrio scell will be select with actScellSwapFr1 enable
    Scell Addtion successfully    cell_id=11    ue_id=91    pcell_dl=60    ul=25    carrierfreq=125050
    Verify Throuput on Pscell and Scell    ue_id=91    pcell_dl=50    ul=25    scell_dl=500
    Trigger ScellRel    carrierfreq=508110    ue_id=91
    Verify Throuput on Pscell    ue_id=91    pcell_dl=60    ul=25
    UE Detach    ue_id=91

NSA TT high scellPrio scell will be select with actScellSwapFr1 enable
    Scell Addtion successfully    cell_id=1    ue_id=91    pcell_dl=650    ul=130
    Verify Throuput on Pscell and Scell    ue_id=91    pcell_dl=450    ul=130    scell_dl=300
    Trigger ScellRel    carrierfreq=508110    ue_id=91
    Verify Throuput on Pscell    ue_id=91    pcell_dl=650    ul=130
    UE Detach    ue_id=91

NSA TF high scellPrio scell will be select with actScellSwapFr1 enable
    Scell Addtion successfully    cell_id=1    ue_id=91    pcell_dl=650    ul=130    srsrp_nr=71
#    wait until keyword succeeds    1min    5s
#    ...    Verify Throuput on Pscell and Scell    ue_id=91    pcell_dl=450    ul=130    scell_dl=50
    Trigger ScellRel    carrierfreq=125050    ue_id=91
    Verify Throuput on Pscell    pcell_dl=650    ul=130
    UE Detach    ue_id=91

Scell Addtion successfully
    [Arguments]    ${cell_id}=11    ${ue_id}=91    ${pcell_dl}=700    ${ul}=130    ${carrierfreq}=632736    ${srsrp_nr}=81
    UE Attach To Target Cell    ${cell_id}    ${ue_id}
    Send Throuput    ${ue_id}
    Verify Throuput on Pscell    ${ue_id}    ${pcell_dl}    ${ul}
    Trigger ScellAdd    carrierfreq=${carrierfreq}    srsrp_nr=${srsrp_nr}    ue_id=${ue_id}

Trigger ScellAdd
    [Arguments]    ${event_type}=A1    ${carrierfreq}=518910    ${srsrp_nr}=5    ${srsrq_nr}=5    ${ue_id}=91
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr    id=${ue_id}    meas_id=${meas_id}    event=${event_type}
    ...    srsrp_nr=${srsrp_nr}    srsrq_nr=${srsrq_nr}
    Execute Egate Command    ${cmd}    pass_regexp=rrcConnectionReconfigurationComplete

Trigger ScellRel
    [Arguments]    ${event_type}=A2    ${carrierfreq}=518910    ${scell}=9    ${scell_rsrp}=30    ${ue_id}=91
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type}
    ...    scell=${scell} scell_rsrp=${scell_rsrp}
    Execute Egate Command    ${cmd}    pass_regexp=Sending SgNB Modification Confirm

