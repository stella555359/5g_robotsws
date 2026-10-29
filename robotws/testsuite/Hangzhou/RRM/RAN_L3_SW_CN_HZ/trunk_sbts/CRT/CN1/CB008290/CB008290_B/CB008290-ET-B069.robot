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
...    NRBTS-1/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=96

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
...    NRCELL-1/NRREL-1:lcrId=11
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
...    NRCELL-1/NRREL-2:lcrId=12
...    NRCELL-1/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-2:sCellPrio=2
...    NRCELL-1/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-1:gNbId=1
...    NRCELL-11/NRREL-1:gNbIdLength=22
...    NRCELL-11/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-1:removeNotAllowed=false
...    NRCELL-11/NRREL-1:lcrId=1
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
...    NRCELL-11/NRREL-2:lcrId=2
...    NRCELL-11/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-2:sCellPrio=2
...    NRCELL-11/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-3:gNbId=1
...    NRCELL-11/NRREL-3:gNbIdLength=22
...    NRCELL-11/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-3:removeNotAllowed=false
...    NRCELL-11/NRREL-3:lcrId=3
...    NRCELL-11/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-3:sCellPrio=1
...    NRCELL-11/NRREL-3:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-4:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-4:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-4:gNbId=1
...    NRCELL-11/NRREL-4:gNbIdLength=22
...    NRCELL-11/NRREL-4:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-4:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-4:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-4:removeNotAllowed=false
...    NRCELL-11/NRREL-4:lcrId=4
...    NRCELL-11/NRREL-4:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-4:sCellPrio=2
...    NRCELL-11/NRREL-4:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-3:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-4:sCellOperationalMode=dlOnly

@{8290_enable}
...    NRDU-1:actInterNumerologyCa=true
...    NRDU-1:flexibleCAMode=NumberCellAmount
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRBTS-1:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS-1:actSCellSwapFr1=a6BasedSa
...    NRBTS-1:sCellActivationMethod=bufferBased
...    NRBTS:sCellDeactivationBadRlqCount=1
...    NRCELL:actDl256Qam=false
...    NRCELL:sCellDeactivationTimerGNB=ms1280
...    NRCELL:cellDepType=SA+NSA
...    NRCELL:actK1Opt=intra-gNB
...    NRCELL:a6MeasSCellSwapEnabled=rsrp
...    NRCELL:a6MeasSCellSwapSsbRsrp:a6HysteresisSCellSwapSsbRsrp=0|a6OffsetSCellSwapSsbRsrp=6|a6TimeToTrigSCellSwapSsbRsrp=ms480
...    NRCELL:a6MeasSCellSwapSsbRsrq:a6HysteresisSCellSwapSsbRsrq=0|a6OffsetSCellSwapSsbRsrq=6|a6TimeToTrigSCellSwapSsbRsrq=ms480
...    NRCELL:reportAmountA6MeasSCellSwap=r4
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
...    NRDU-1:carrierAggregationSupportList=ca_Fdd_Fdd,ca_Fdd_Fr1Tdd_Sa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fdd_Any_Sa,ca_Fr1Tdd_Any_Sa

@{same frequency}
...    MRBTS-1/NRBTS-1/NRCELL-1:chBw=40MHz
...    MRBTS-1/NRBTS-1/NRCELL-2:gscnOrSsPbchArfcn=8000
...    MRBTS-1/NRBTS-1/NRCELL-2:nrarfcn=648000
...    MRBTS-1/NRBTS-1/NRCELL-2:chBw=40MHz
...    MRBTS-1/NRBTS-1/NRCELL-2:type0CoresetConfigurationIndex=12
...    MRBTS-1/NRBTS-1/NRCELL-2:srsForBeamMgmt:cSRS=25
...    MRBTS-1/NRBTS-1/NRCELL-3:chBw=40MHz
...    MRBTS-1/NRBTS-1/NRCELL-4:chBw=40MHz
...    MRBTS-1/NRBTS-1/NRCELL-4:srsForBeamMgmt:cSRS=25
...    MRBTS-1/NRBTS-1/NRCELL-12:gscnOrSsPbchArfcn=1562
...    MRBTS-1/NRBTS-1/NRCELL-12/NRCELL_FDD-1:nrarfcnDl=124900
...    MRBTS-1/NRBTS-1/NRCELL-12/NRCELL_FDD-1:nrarfcnUl=134100
...    MRBTS-1/NRBTS-1/NRCELL-12/NRCELL_FDD-1:chBwDl=10MHz
...    MRBTS-1/NRBTS-1/NRCELL-12/NRCELL_FDD-1:chBwUl=10MHz
...    MRBTS-1/NRBTS-1/NRCELL-12:type0CoresetConfigurationIndex=7

@{OnlineParamChange_rsrpCombined}
...    NRCELL-1:a6MeasSCellSwapEnabled=rsrpCombined

@{OnlineParamChange_rsrp}
...    NRCELL-1:a6MeasSCellSwapEnabled=rsrp

@{OnlineParamChange_B069_1}
...    NRCELL:a6MeasSCellSwapEnabled=rsrqCombined

@{OnlineParamChange_B069_2}
...    NRCELL-11:a6MeasSCellSwapSsbRsrp:a6HysteresisSCellSwapSsbRsrp=0|a6OffsetSCellSwapSsbRsrp=8

@{OnlineParamChange_B069_3}
...    NRCELL-11:a6MeasSCellSwapSsbRsrp:a6HysteresisSCellSwapSsbRsrp=0|a6OffsetSCellSwapSsbRsrp=6

@{OnlineParam_B069_recover}
...    NRCELL:a6MeasSCellSwapEnabled=rsrp
...    NRCELL:a6MeasSCellSwapSsbRsrp:a6HysteresisSCellSwapSsbRsrp=0|a6OffsetSCellSwapSsbRsrp=6

@{Result_2cc}
...    rrcReconfigurationComplete
...    pcid:60, scellIdx:1
...    SCellIndex 1 activated successfully

@{Result_3cc}
...    rrcReconfigurationComplete
...    pcid:50, scellIdx:1
...    pcid:52, scellIdx:2
...    SCellIndex 1 activated successfully
...    SCellIndex 2 activated successfully

${pdu_id}    1
${gw_id}    1
${nwslice}    1

*** Test Cases ***
CB008290-ET-B069_Verify_online_modify_a6OffsetSCellSwapSsbRsrp_when_6MeasSCellSwapEnabled_set_as_rsrqCombined
    [Documentation]
    ...    1. This user scenario describes the gNB behavior when SCell swap related parameter is modified before the
    ...       receipt of A6 measurement for SCell swap.
    ...    2. Configuration:
    ...        TDD Cell1/Cell2 configure to same frequency, TDD Cell3/Cell4 configure to another same frequency.
    ...        FDD cell11/cell12 configure to same frequency.
    ...        Configure CA Relations: Cell1-Cell11, Cell1-Cell12, Cell11-Cell1, Cell11-Cell2,Cell11-Cell3, Cell11-Cell4
    ...        a6MeasSCellSwapEnabled=rsrqCombined
    ...    3. Test Case Steps:
    ...         a. UE registers successfully and PDU session is setup successfully on cell 1, Start traffic and check traffic
    ...         b. UE sends A1 measurement for SCell1 Addition, check traffic.
    ...         c. UE sends A6 measurement for SCell2 swap and check traffic.
    ...         d. UE sends A6 measurement for SCell1 swap and check traffic.
    ...         e. online set cell11.a6OffsetSCellSwapSsbRsrp=8
    ...            UE sends A6 measurement for SCell2 swap and check traffic.
    ...         f. online set cell11.a6OffsetSCellSwapSsbRsrp=6
    ...            UE sends A6 measurement for SCell2 swap and check traffic.
    ...         g. UE deregister
    ...     4. Expect result:
    ...         a. UE registers successfully, PDU session is setup successfully, A1 meas for scell addition configured
    ...            DL/UL throughput on TDD PCell can reach the expected value.
    ...         b. UE is successfully configured with TDD PCell and FDD SCell1-cell11 as SCell,
    ...            A1 for scell addition is released.
    ...            A2 for scell release and A6 for scell swap is configured to UE.
    ...            Aggregate UE peak DL/UL throughput on TDD PCell and TDD SCell1 can reach the expected value.
    ...         c. scell swap to scell2-cell12 successfully.
    ...            A2 for scell release and A6 for scell swap on Scell1 is removed to UE.
    ...            A2 for scell release and A6 for scell swap on Scell2 is configured to UE.
    ...            Aggregate UE peak DL/UL throughput on TDD PCell and TDD SCell4 can reach the expected value.
    ...         d. scell swap to scell1-cell11 successfully.
    ...            A2 for scell release and A6 for scell swap on Scell4 is removed to UE.
    ...            A2 for scell release and A6 for scell swap on Scell1 is configured to UE.
    ...            Aggregate UE peak DL/UL throughput on TDD PCell and TDD SCell1 can reach the expected value.
    ...         e. scell swap to scell2-cell12 failed.
    ...            Aggregate UE peak DL/UL throughput on TDD PCell and TDD SCell1 can continue the expected value.
    ...         f. scell swap to scell2-cell12 successfully.
    ...            A2 for scell release and A6 for scell swap on Scell1 is removed to UE.
    ...            A2 for scell release and A6 for scell swap on Scell2 is configured to UE.
    ...            Aggregate UE peak DL/UL throughput on TDD PCell and TDD SCell4 can reach the expected value.
    ...         g. UE deregister is successfully.
    [Tags]    QC_47033    owner-hzheng    B069
    Trigger scell swap and swap back
    OnlineParamChange    ${OnlineParamChange_B069_2}
    Trigger ScellSwap fail    nrsrp_nr=24    nrsrq_nr=24    scell_id=1    phycell_id=61
    OnlineParamChange    ${OnlineParamChange_B069_3}
    Trigger ScellSwap    nrsrp_nr=24    nrsrq_nr=24    scell_id=1    phycell_id=61
    UE Deregister From gNB    81
    Check Wireshark Log    ${CURDIR}${/}a2a_CB008290B069${/}a2a.ini    wait_string=UEContextRelease::12
    [Teardown]    B069_Teardown
*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_4T2F

Modify Cfg
    ${gNB2_cell2_configuration}    catenate
    ...    set_cell id=2 gnb=2 pci=17:0 tac=200 nrci=0x02 tdd_cell=on proxy=$PROXY_SERVER_IP:9999|$PROXY_SERVER_IP:8888
    ...    nr_arfcn=648000:648000 gscn=8000 mandatory_for_activation=off
    update Cfg    ${gNB2_cell2_configuration}

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir

B067_Teardown
    OnlineParamChange    ${OnlineParamChange_rsrp}
    Common Test Teardown And Stop Capture Logs

B069_Teardown
    OnlineParamChange    ${OnlineParam_B069_recover}
    Common Test Teardown And Stop Capture Logs

B072_Teardown
    Execute Egate Command    ue_testmode_set_nr id=81 scell=0-3 testmode=bler action=deactivate profile_id=1
    Execute Egate Command    bler_testmode_nr profile_id=1 delete=on    sleep_time=2    pass_regexp=[ACTIVE]
    Common Test Teardown And Stop Capture Logs

UE Attach To Target Cell
    [Arguments]    ${cell_id}=1    ${ue_id}=81    ${pcell_dl}=200
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    ${ret1}=    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=${gw_id} nwslice=${nwslice}    QoS Routing Table
    Send Throuput    ue_id=${ue_id}
    Verify Throuput on Pcell    pcell_dl=${pcell_dl}

Send Throuput
    [Arguments]    ${ue_id}=81
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=1    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=3    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=4    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=5    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=ul mbps=10 trf_id=1    UE ${ue_id}: UDP UL
    sleep    30s    #sleep for stable traffic

Verify Throuput on Pcell
    [Arguments]    ${ue_id}=81    ${pcell_dl}=60    ${ul}=0
    sleep    10s    #sleep for stable traffic
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000>${pcell_dl}
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul}

Verify Throuput on Pcell and Scell
    [Arguments]    ${ue_id}=81    ${pcell_dl}=10    ${scell_dl}=10    ${ul}=0    ${scell_id}=1
    sleep    10s     #sleep for stable traffic
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000 > ${pcell_dl}
    ${scell_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${scell_id}    type=pdsch    rate_type=ave
    Should Be True    ${scell_tput}/1000 > ${scell_dl}
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul}

Verify Throuput is 0 on Scell
    [Arguments]    ${ue_id}=81    ${scell_id}=1
    sleep    10s    #sleep for stable traffic
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${scell_id}    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000 == 0

UE Deregister From gNB
    [Arguments]    ${ue_id}=81
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s

Trigger ScellAdd 2CC
    [Arguments]    ${event_type}=A1    ${carrierfreq}=648096    ${srsrp_nr}=81    ${srsrq_nr}=50    ${ue_id}=81
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type}
    ...    srsrp_nr=${srsrp_nr} srsrq_nr=${srsrq_nr}
    ${ret1}=    Execute Egate Command    ${cmd}    pass_regexp=${Result_2cc}
#    Verify Throuput on Pcell and Scell    pcell_dl=${pcell_dl}    scell_dl=${scell_dl}    scell_id=${scell_id}

Trigger ScellAdd 3CC
    [Arguments]    ${event_type}=A1    ${carrierfreq}=125050    ${srsrp_nr}=100    ${srsrq_nr}=50    ${ue_id}=81
    ...    ${pcell_dl}=30    ${scell_dl_1}=190    ${scell_dl_2}=190    ${scell_id_1}=1    ${scell_id_2}=2
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type}
    ...    srsrp_nr=${srsrp_nr} srsrq_nr=${srsrq_nr}
    Execute Egate Command    ${cmd}    pass_regexp=${Result_3cc}
    Verify Throuput on Pcell and Scell    ue_id=${ue_id}    pcell_dl=${pcell_dl}    scell_dl=${scell_dl_1}    scell_id=${scell_id_1}
    Verify Throuput on Pcell and Scell    ue_id=${ue_id}    pcell_dl=${pcell_dl}    scell_dl=${scell_dl_2}    scell_id=${scell_id_2}

Trigger ScellSwap
    [Arguments]    ${event_type}=A6    ${carrierfreq}=125050    ${nrsrp_nr}=30    ${nrsrq_nr}=30    ${ue_id}=81    ${scell_id}=1
    ...    ${phycell_id}=63
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type}
    ...    srsrp_nr=11 srsrq_nr=11 scell=${scell_id} scell_rsrp=20 scell_rsrq=20 phycell_id=${phycell_id}
    ...    nrsrp_nr=${nrsrp_nr} nrsrq_nr=${nrsrq_nr}
    Execute Egate Command    ${cmd}    pass_regexp=rrcReconfigurationComplete
#    Verify Throuput on Pcell and Scell    ue_id=${ue_id}    pcell_dl=${pcell_dl}    scell_dl=${scell_dl}    scell_id=${scell_id_1}

Trigger ScellSwap fail
    [Arguments]    ${event_type}=A6    ${carrierfreq}=125050    ${nrsrp_nr}=30    ${nrsrq_nr}=30    ${ue_id}=81    ${scell_id}=1
    ...    ${phycell_id}=63
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type}
    ...    srsrp_nr=11 srsrq_nr=11 scell=${scell_id} scell_rsrp=20 scell_rsrq=20 phycell_id=${phycell_id}
    ...    nrsrp_nr=${nrsrp_nr} nrsrq_nr=${nrsrq_nr}
    Execute Egate Command    ${cmd}    fail_regexp=rrcReconfigurationComplete
#    Verify Throuput on Pcell and Scell    ue_id=${ue_id}    pcell_dl=${pcell_dl}    scell_dl=${scell_dl}    scell_id=${scell_id_1}

Trigger scell swap fail when a6MeasSCellSwapEnabled is rsrpCombined
    UE Attach To Target Cell    cell_id=11    ue_id=81    pcell_dl=60
    Trigger ScellAdd 3CC
    OnlineParamChange    ${OnlineParamChange_rsrpCombined}
    Trigger ScellSwap fail    carrierfreq=648096    nrsrp_nr=23    nrsrq_nr=24    scell_id=1    phycell_id=51
    Trigger ScellSwap    carrierfreq=648096    scell_id=1    phycell_id=51

Trigger scell swap succ when a6MeasSCellSwapEnabled is rsrpCombined
    UE Attach To Target Cell    cell_id=11    ue_id=82    pcell_dl=20
    Verify Throuput on Pcell    ue_id=81    pcell_dl=20
    Trigger ScellAdd 3CC    ue_id=82    pcell_dl=20    scell_dl_1=190    scell_dl_2=95
    Verify Throuput on Pcell and Scell    ue_id=81    pcell_dl=20    scell_dl=95    scell_id=2
    Verify Throuput on Pcell and Scell    ue_id=81    pcell_dl=20    scell_dl=170    scell_id=3
    Trigger ScellSwap    ue_id=82    carrierfreq=648096    scell_id=1    phycell_id=51
    Verify Throuput on Pcell and Scell    ue_id=81    pcell_dl=20    scell_dl=95    scell_id=2
    Verify Throuput on Pcell and Scell    ue_id=81    pcell_dl=20    scell_dl=95    scell_id=3
    UE Deregister From gNB    82

Trigger scell swap succ when a6MeasSCellSwapEnabled is rsrp
    OnlineParamChange    ${OnlineParamChange_rsrp}
    UE Attach To Target Cell    cell_id=11    ue_id=82    pcell_dl=20
    Verify Throuput on Pcell    ue_id=81    pcell_dl=20
    Trigger ScellAdd 3CC    ue_id=82    pcell_dl=20    scell_dl_1=180    scell_dl_2=95
    Verify Throuput on Pcell and Scell    ue_id=81    pcell_dl=20    scell_dl=95    scell_id=2
    Verify Throuput on Pcell and Scell    ue_id=81    pcell_dl=20    scell_dl=170    scell_id=3
    Trigger ScellSwap    ue_id=82    carrierfreq=648096    nrsrp_nr=23    nrsrq_nr=24    scell_id=1    phycell_id=51
    Verify Throuput on Pcell and Scell    ue_id=81    pcell_dl=20    scell_dl=95    scell_id=2
    Verify Throuput on Pcell and Scell    ue_id=81    pcell_dl=20    scell_dl=95    scell_id=3

Trigger scell permanent deactived
    [Arguments]    ${ue_id}=81    ${scell_id}=1    ${pcell_dl}=60    ${scell_id_1}=2    ${scell_dl}=190
    Execute Egate Command    bler_testmode_nr profile_id=1 target_mcs=0 num_dl_pkts=10000    pass_regexp=[ACTIVE]
    Execute Egate Command    ue_testmode_set_nr id=${ue_id} scell=${scell_id} testmode=bler action=activate profile_id=1
    ...    pass_regexp=SCellIndex 1 deactivated    timeout=30s
    Verify Throuput on Pcell and Scell    pcell_dl=${pcell_dl}    scell_dl=${scell_dl}    scell_id=${scell_id_1}
    Verify Throuput is 0 on Scell
    Execute Egate Command    ue_testmode_set_nr id=81 scell=0-3 testmode=bler action=deactivate profile_id=1
    Execute Egate Command    bler_testmode_nr profile_id=1 delete=on    sleep_time=2    pass_regexp=[ACTIVE]


Trigger scell swap and swap back
    OnlineParamChange    ${OnlineParamChange_B069_1}
    UE Attach To Target Cell
    Trigger ScellAdd 2CC    phycell_id=60
    Trigger ScellSwap    nrsrp_nr=24    nrsrq_nr=24    scell_id=1    phycell_id=61
    Trigger ScellSwap    nrsrp_nr=24    nrsrq_nr=24    scell_id=2    phycell_id=60
