*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    CRT    CLOUD_5G_I_[LO][LO]_AP_[LOO]_SANSA_FS_ECPRI_CMWV_TDD
...    team-L3CN1_SG14    owner-alex.2.wang    release-SBTS23R3
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${NOKIA_XNAP_PLUGIN_FLAG}    ${True}
${NOKIA_F1AP_PLUGIN_FLAG}    ${True}

@{PARAMS_IN_SCF}
...    @{PARAMS_FOR_CA}
...    @{PARAMS_FOR_GNB1}
...    @{PARAMS_ADJ_REL_FOR_GNB1}
...    @{PARAMS_FOR_OTHERS}
@{PARAMS_IN_SCF_GNB2}
...    @{PARAMS_FOR_CA}
...    @{PARAMS_FOR_GNB2}
...    @{PARAMS_ADJ_REL_FOR_GNB2}
...    @{PARAMS_FOR_OTHERS}

@{PARAMS_FOR_CA}
...    NRBTS:actCarrierAggregation=true
...    NRBTS:sCellActivationMethod=blind
...    NRBTS:caConfigurationSupport=4CCDL_2CCUL
...    NRBTS:weightForIgnbCaSelection=20
...    NRBTS:actIncXn=true
...    NRBTS:maxNumScellsDl=2
...    NRBTS:maxNumScellsUl=2
...    NRBTS:cuUeIdToLinkMappingUpdateDelay=1ms
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:carrierAggregationSupportList=ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Sa,ca_Fdd_Any_Sa,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Fdd
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRDU-1:actInterGnbCa=DLOnly
...    NRDU-1:dlToUlContributionRatio=101
...    NRDU-1:xgUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRCELL:actK1Opt=intraAndInter-gNB


@{PARAMS_FOR_GNB1}
...    NRCELL-11:sCellDeactivationTimerGNB=infinity
...    NRCELL-12:sCellDeactivationTimerGNB=infinity
...    NRCELL:nrCellType=2DL2UL
...    NRCELL-11:maxNumScellsDlFr1=3
...    NRCELL-11:dlMimoMode=2x2 Open Loop Spatial Multiplexing
...    NRCELL-12:dlMimoMode=2x2 Open Loop Spatial Multiplexing
...    NRPMRNL-1:miNrInterGnbMobilityNsaPmqap=disabled
...    NRPMRNL-1:miNrInterGnbNgMobilitySaPmqap=disabled
...    NRPMRNL-1:miNrInterGnbXnMobilitySaPmqap=disabled
...    NRPMRNL-1:miNrIntraGnbMobilityNsaPmqap=disabled
...    NRPMRNL-1:miNrIntraGnbMobilitySaPmqap=disabled
...    NRBTS:actNgcFlexSaMode=true
...    NRPMRNL-1:miNrRelReportCu=disabled
...    MNL-1/MNLENT-1/XPAP-1/XPIF-1/XPIFREMOTE-2:ipAddress=10.0.1.124
...    MNL-1/MNLENT-1/XPAP-1/XPIF-1/XPIFREMOTE-2:remoteNeType=GNB

@{PARAMS_ADJ_REL_FOR_GNB1}
...    NRBTS/XNLINK-2:cPlaneIpAddr=10.0.1.124
...    NRBTS:actGrflShdn=false
...    NRBTS:iGnbCaXnCfUpBackOffTmr=60
...    NRBTS:iGnbCaXnSetupReqTmr=60
...    NRBTS:iGnbCaXnSetupRespTmr=60
...    NRBTS:intGnbScellTempBlockTmr=60
...    NRBTS/NRADJGNB-2:administrativeState=Unlocked
...    NRBTS/NRADJGNB-2:gNbIdLength=22
...    NRBTS/NRADJGNB-2:gNodeBId=2
...    NRBTS/NRADJGNB-2:weightForIgnbCaSelection=50
...    NRBTS/NRADJGNB-2:xnLinkRef=1
...    NRBTS/NRADJGNB-2:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-2:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-2:gnbPlmn:mncLength=3
...    NRBTS/NRADJGNB-3:administrativeState=Unlocked
...    NRBTS/NRADJGNB-3:gNbIdLength=22
...    NRBTS/NRADJGNB-3:gNodeBId=35
...    NRBTS/NRADJGNB-3:weightForIgnbCaSelection=50
...    NRBTS/NRADJGNB-3:xnLinkRef=2
...    NRBTS/NRADJGNB-3:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-3:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-3:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-1:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-1:fiveGsTac=200
...    NRBTS/NRADJNRCELL-1:gNbId=2
...    NRBTS/NRADJNRCELL-1:gNbIdLength=22
...    NRBTS/NRADJNRCELL-1:lcrId=1
...    NRBTS/NRADJNRCELL-1:nrarfcn=663400
...    NRBTS/NRADJNRCELL-1:physCellId=50
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-1:freqBandIndicatorNR=77
...    NRBTS/NRADJNRCELL-2:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-2:fiveGsTac=200
...    NRBTS/NRADJNRCELL-2:gNbId=2
...    NRBTS/NRADJNRCELL-2:gNbIdLength=22
...    NRBTS/NRADJNRCELL-2:lcrId=2
...    NRBTS/NRADJNRCELL-2:nrarfcn=658000
...    NRBTS/NRADJNRCELL-2:physCellId=51
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-2:freqBandIndicatorNR=77
...    NRBTS/NRADJNRCELL-54:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-54:fiveGsTac=200
...    NRBTS/NRADJNRCELL-54:freqBandIndicatorNR=77
...    NRBTS/NRADJNRCELL-54:gNbId=35
...    NRBTS/NRADJNRCELL-54:gNbIdLength=22
...    NRBTS/NRADJNRCELL-54:lcrId=1
...    NRBTS/NRADJNRCELL-54:nrarfcn=663400
...    NRBTS/NRADJNRCELL-54:physCellId=54
...    NRBTS/NRADJNRCELL-54:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-54:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-54:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-55:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-55:fiveGsTac=200
...    NRBTS/NRADJNRCELL-55:freqBandIndicatorNR=77
...    NRBTS/NRADJNRCELL-55:gNbId=35
...    NRBTS/NRADJNRCELL-55:gNbIdLength=22
...    NRBTS/NRADJNRCELL-55:lcrId=2
...    NRBTS/NRADJNRCELL-55:nrarfcn=658000
...    NRBTS/NRADJNRCELL-55:physCellId=55
...    NRBTS/NRADJNRCELL-55:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-55:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-55:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-56:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-56:fiveGsTac=200
...    NRBTS/NRADJNRCELL-56:freqBandIndicatorNR=3
...    NRBTS/NRADJNRCELL-56:gNbId=35
...    NRBTS/NRADJNRCELL-56:gNbIdLength=22
...    NRBTS/NRADJNRCELL-56:lcrId=13
...    NRBTS/NRADJNRCELL-56:nrarfcn=368400
...    NRBTS/NRADJNRCELL-56:physCellId=56
...    NRBTS/NRADJNRCELL-56:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-56:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-56:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-57:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-57:fiveGsTac=200
...    NRBTS/NRADJNRCELL-57:freqBandIndicatorNR=28
...    NRBTS/NRADJNRCELL-57:gNbId=35
...    NRBTS/NRADJNRCELL-57:gNbIdLength=22
...    NRBTS/NRADJNRCELL-57:lcrId=14
...    NRBTS/NRADJNRCELL-57:nrarfcn=153400
...    NRBTS/NRADJNRCELL-57:physCellId=57
...    NRBTS/NRADJNRCELL-57:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-57:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-57:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-1:gNbId=2
...    NRCELL-11/NRREL-1:gNbIdLength=22
...    NRCELL-11/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-1:lcrId=1
...    NRCELL-11/NRREL-1:removeNotAllowed=false
...    NRCELL-11/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-2:gNbId=2
...    NRCELL-11/NRREL-2:gNbIdLength=22
...    NRCELL-11/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-2:lcrId=2
...    NRCELL-11/NRREL-2:removeNotAllowed=false
...    NRCELL-11/NRREL-2:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-54:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-54:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-54:gNbId=35
...    NRCELL-11/NRREL-54:gNbIdLength=22
...    NRCELL-11/NRREL-54:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-54:lcrId=1
...    NRCELL-11/NRREL-54:removeNotAllowed=false
...    NRCELL-11/NRREL-54:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-54:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-54:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-54:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-54:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-55:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-55:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-55:gNbId=35
...    NRCELL-11/NRREL-55:gNbIdLength=22
...    NRCELL-11/NRREL-55:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-55:lcrId=2
...    NRCELL-11/NRREL-55:removeNotAllowed=false
...    NRCELL-11/NRREL-55:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-55:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-55:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-55:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-55:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-56:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-56:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-56:gNbId=35
...    NRCELL-11/NRREL-56:gNbIdLength=22
...    NRCELL-11/NRREL-56:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-56:lcrId=13
...    NRCELL-11/NRREL-56:removeNotAllowed=false
...    NRCELL-11/NRREL-56:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-56:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-56:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-56:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-56:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-57:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-57:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-57:gNbId=35
...    NRCELL-11/NRREL-57:gNbIdLength=22
...    NRCELL-11/NRREL-57:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-57:lcrId=14
...    NRCELL-11/NRREL-57:removeNotAllowed=false
...    NRCELL-11/NRREL-57:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-57:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-57:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-57:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-57:gnbPlmn:mncLength=3

@{PARAMS_FOR_GNB2}
...    NRBTS:iGnbCaXnCfUpBackOffTmr=60
...    NRBTS:iGnbCaXnSetupReqTmr=90
...    NRBTS:iGnbCaXnSetupRespTmr=60
...    NRBTS:intGnbScellTempBlockTmr=60
...    NRCELL-1:sCellDeactivationTimerGNB=infinity
...    NRCELL-2:sCellDeactivationTimerGNB=infinity
...    NRCELL-13:sCellDeactivationTimerGNB=infinity
...    NRCELL-14:sCellDeactivationTimerGNB=infinity
...    NRCELL-1:weightForSCellSelection=50
...    NRCELL-2:weightForSCellSelection=50
...    NRCELL-13:weightForSCellSelection=50
...    NRCELL-14:weightForSCellSelection=50
...    NRCELL-1:nrCellType=4DL4UL
...    NRCELL-2:nrCellType=4DL4UL
...    NRCELL-1:dlMimoMode=4x4 or 4x2 Open Loop Spatial Multiplexing
...    NRCELL-2:dlMimoMode=4x4 or 4x2 Open Loop Spatial Multiplexing
...    NRBTS:maxNumScellsDl=2

...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-7:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-7:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-8:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-8:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-3/PHYANT-1

...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-7:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-7:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-8:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-8:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1

@{PARAMS_ADJ_REL_FOR_GNB2}
...    NRBTS/NRADJGNB-1:administrativeState=Unlocked
...    NRBTS/NRADJGNB-1:gNbIdLength=22
...    NRBTS/NRADJGNB-1:gNodeBId=1
...    NRBTS/NRADJGNB-1:weightForIgnbCaSelection=50
...    NRBTS/NRADJGNB-1:xnLinkRef=1
...    NRBTS/NRADJGNB-1:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-1:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-11:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-11:fiveGsTac=200
...    NRBTS/NRADJNRCELL-11:gNbId=1
...    NRBTS/NRADJNRCELL-11:gNbIdLength=22
...    NRBTS/NRADJNRCELL-11:lcrId=11
...    NRBTS/NRADJNRCELL-11:nrarfcn=364000
...    NRBTS/NRADJNRCELL-11:physCellId=60
...    NRBTS/NRADJNRCELL-11:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-11:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-11:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-12:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-12:fiveGsTac=200
...    NRBTS/NRADJNRCELL-12:gNbId=1
...    NRBTS/NRADJNRCELL-12:gNbIdLength=22
...    NRBTS/NRADJNRCELL-12:lcrId=12
...    NRBTS/NRADJNRCELL-12:nrarfcn=374000
...    NRBTS/NRADJNRCELL-12:physCellId=61
...    NRBTS/NRADJNRCELL-12:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-12:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-12:gnbPlmn:mncLength=3

@{PARAMS_FOR_OTHERS}


...    NRBTS:actRanSharing=false
...    NRCELL:actCDrx=false

@{UE1Expect}
...    pcid:50, scellIdx:1
...    pcid:51, scellIdx:2
...    SCellIndex 1 activated successfully at airphone
...    SCellIndex 2 activated successfully at airphone

@{online_modify_delete_NRREL_of_Cell2_11}
...    delete:MRBTS-1/NRBTS-1/NRCELL-11/NRREL-1
...    delete:MRBTS-1/NRBTS-1/NRCELL-11/NRREL-2

@{online_modify_delete_NRREL_of_sim_gNB}
...    delete:MRBTS-1/NRBTS-1/NRCELL-11/NRREL-54
...    delete:MRBTS-1/NRBTS-1/NRCELL-11/NRREL-55
...    delete:MRBTS-1/NRBTS-1/NRCELL-11/NRREL-56
...    delete:MRBTS-1/NRBTS-1/NRCELL-11/NRREL-57

${EFaultId_InterGnbCaXpVersionMismatchAl}    7108

@{XP_setup_expect}
...    GNB-4: XpAP Link with GNB-2 .* is up

*** Test Cases ***
CB008140-ET-KC008_Incompatible inter-gNB CA Xp-U protocol version alarm recovery via removing ext-gNB3 from the CA relation
    [Documentation]
    ...    The purpose of this test case is to check following scenarios:
    ...      recovery from the incompatible inter-gNB CA Xp-U protocol version alarm with the ext-gNB3 by removing ext-gNB3
    ...      from the CA relation with the prime gNB1
    ...      5G_RAN_USR_RRM_17967, fully covered
    ...        It is about CB008140-K#B10: Incompatible inter-gNB CA Xp-U protocol version alarm recovery via removing ext-gNB3
    ...        from the CA relation
    ...    [Configuration]:
    ...    Cell id=11 gnb=2 pci=20:0 tac=200 tdd_cell=off band=n3 nr_arfcn=345000:364000 gscn=4547 chBw=15MHz
    ...    Cell id=12 gnb=2 pci=20:1 tac=200 tdd_cell=off band=n3 nr_arfcn=355000:374000 gscn=4675 chBw=15MHz
    ...    Cell id=1 gnb=3 pci=16:2 tac=200 tdd_cell=on band=n77 nr_arfcn=663400:663400 gscn=8159 chBw=100MHz
    ...    weightForSCellSelection=50
    ...    Cell id=2 gnb=3 pci=17:0 tac=200 tdd_cell=on band=n77 nr_arfcn=658000:658000 gscn=8103 chBw=40MHz
    ...    weightForSCellSelection=50
    ...    Cell id=13 gnb=3 pci=20:2 tac=200 tdd_cell=off band=n3 nr_arfcn=349400:368400 gscn=4605 chBw=10MHz
    ...    weightForSCellSelection=50
    ...    Cell id=14 gnb=3 pci=21:0 tac=200 tdd_cell=off band=n28 nr_arfcn=143400:153400 gscn=1916 chBw=15MHz
    ...    weightForSCellSelection=50
    ...    sim gNB:
    ...    Cell id=1 gnb=4 pci=18:0 tac=200 tdd_cell=on band=n77 nr_arfcn=663400:663400 gscn=8159 chBw=100MHz
    ...    Cell id=2 gnb=4 pci=18:1 tac=200 tdd_cell=on band=n77 nr_arfcn=658000:658000 gscn=8103 chBw=40MHz 
    ...    Cell id=3 gnb=4 pci=18:2 tac=200 tdd_cell=off band=n3 nr_arfcn=349400:368400 gscn=4605 chBw=10MHz
    ...    Cell id=4 gnb=4 pci=19:0 tac=200 tdd_cell=off band=n28 nr_arfcn=143400:153400 gscn=1916 chBw=15MHz
    ...    2.Test Case Steps:
    ...         Step a. Setup XP link between gNB-2 and sim gNB-4
    ...         Step b. Set Incompatible inter-gNB CA Xp-U protocol version
    ...         Step c. Delete gNB-2 NRRELs of sim gNB-4
    ...    3. Expected Results:
    ...         Step a: XP link setup successfully
    ...         Step b: Indication is sent to gNB-2 from gNB-4,then fault id 7108 raises
    ...         Step c: Deletion is done,fault is cleared
    [Tags]    QC_281486    KC008
    Setup XpAP Link
    Set Incompatible inter-gNB CA Xp-U protocol version
    Delta Commission To delete sim gNB NRREL
    Check WireShark Log    ${CURDIR}${/}A2A_KC_008${/}a2a.ini    wait_string=IgNBCAXpRemovalResponse::1

CB008140-ET-KC001_Normal IGNB CA REMOVAL when Delete sCellAdditionMethod then without relationship between primary gnb and external gnb
    [Documentation]
    ...    The purpose of this test case is to check following scenarios:
    ...    Parameters are modified to remove the last CA relationship between PCell and ext-SCells
    ...      This case partly covered CB008140-K#B1: PCell lock with Graceful Cell Shutdown and CB008140-K#B5: PCell unlock
    ...    Requirement Coverage:
    ...    5G_RAN_USR_RRM_19030 partially covered
    ...      It is about CB008140-K#B7: CA Relationship removal requiring a cell reset
    ...    [Configuration]:
    ...    Cell id=11 gnb=2 pci=20:0 tac=200 tdd_cell=off band=n3 nr_arfcn=345000:364000 gscn=4547 chBw=15MHz
    ...    Cell id=12 gnb=2 pci=20:1 tac=200 tdd_cell=off band=n3 nr_arfcn=355000:374000 gscn=4675 chBw=15MHz
    ...    Cell id=1 gnb=3 pci=16:2 tac=200 tdd_cell=on band=n77 nr_arfcn=663400:663400 gscn=8159 chBw=100MHz
    ...    weightForSCellSelection=50
    ...    Cell id=2 gnb=3 pci=17:0 tac=200 tdd_cell=on band=n77 nr_arfcn=658000:658000 gscn=8103 chBw=40MHz
    ...    weightForSCellSelection=50
    ...    Cell id=13 gnb=3 pci=20:2 tac=200 tdd_cell=off band=n3 nr_arfcn=349400:368400 gscn=4605 chBw=10MHz
    ...    weightForSCellSelection=50
    ...    Cell id=14 gnb=3 pci=21:0 tac=200 tdd_cell=off band=n28 nr_arfcn=143400:153400 gscn=1916 chBw=15MHz
    ...    weightForSCellSelection=50
    ...    2.Test Case Steps:
    ...         Step a. UE1 Register And PDU Session Setup On Cell2_11,then start traffic
    ...         Step b. Delete gNB-2 NRRELS of gNB-3,check wireshark,then release UE1
    ...         Step c. Add back NRRELS of gNB-3 to gNB-2, UE1 one more time Register And PDU Session Setup On Cell2_11,
    ...                 then start traffic
    ...    3. Expected Results:
    ...         Step a: UE1 Register And PDU Session Setup Successfully, blindly add Cell3_1Cell3_2 as Scells,traffic is ok
    ...         Step b: IGNB CA REMOVAL produce happens and checking wireshark log is ok
    ...                gNB-1-CU-CP sends XnAP: IGNB CA REMOVAL REQUEST to gNB2-CU-CP
    ...                If gNB2 plays neither prime-gNB role (i.e. no CA NRREL pointing to gNB1) nor ext-gNB role 
    ...                  (i.e. XnAP: IGNB CA CONFIGURATION UPDATE INDICATION message with IE cellsToRemove which removes all cells of gNB2 as
    ...                  ext-SCells has been received from gNB1), gNB2-CU-CP sends F1AP: IGNB CA XP REMOVAL REQUEST to gNB2-DU and sets internal
    ...                  status of Xp link as unavailable
    ...                gNB2-DU unsubscribes in XPIF component for Xp link status notifications and replies with F1AP: IGNB CA XP REMOVAL RESPONSE
    ...                  to gNB2-CU-CP.
    ...                gNB2-CU-CP replies XnAP: IGNB CA REMOVAL RESPONSE to gNB1-CU-CP
    ...                gNB1-CU-CP sends F1AP: IGNB CA XP REMOVAL REQUEST to gNB1-DU and sets internal status of Xp link as unavailable
    ...                gNB1-DU unsubscribes in XPIF component for Xp link status notifications and replies with F1AP: IGNB CA XP REMOVAL RESPONSE to
    ...                  gNB1-CU-CP
    ...         Step c: UE1 Register And PDU Session Setup Successfully, blindly add Cell3_1Cell3_2 as Scells,traffic is ok
    [Tags]    QC_281493    KC001    CA_LABEL-TTT(15MHz_FDD_n3+100MHz_TDD_n77+40MHz_TDD_n77)
    SA UE attach with scell addition and verify traffic
    Delta Commission To delete NRREL
    Check WireShark Log    ${CURDIR}${/}A2A_KC_001${/}a2a.ini    wait_string=IgNBCAXpRemovalResponse::1
    Check WireShark Log GNB2    ${CURDIR}${/}A2A_KC_001${/}a2a_gnb2.ini    wait_string=IgNBCAXpRemovalResponse::1
    Release UEs    ue_type=all
    Delta Commission To add NRREL
    SA UE attach with scell addition and verify traffic
    Release UEs    ue_type=all

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup 2Airphone Env    fddtdd_sansa_cmwv/6cells_gnb1_2F_gnb2_2T2F

Modify Cfg
    ${gNB4_sim_configuration}    catenate
    ...    set_gnb id=4 type=simulated plmn=311:489 ng=10.0.1.125 gnb_id=0x23:22 daemon=10.0.2.1:22222 x2_peers=none xn=10.0.1.124 
    ...    nssai=0x1:0xd143a5 amf=1 xp=10.0.1.124:32742 xpu=10.0.1.124:32742 xp_management=on
    Update Cfg    ${gNB4_sim_configuration}
    ${gNB4_Cell1_sim_configuration}    catenate
    ...    set_cell id=1 gnb=4 pci=18:0 tac=200 nrci=0x01 tdd_cell=on proxy=10.0.2.90:9999 nr_arfcn=663400:663400 gscn=8159
    ...    nr_scs=30kHz bs_channel_bandwidth=100MHz mandatory_for_activation=off
    ${gNB4_Cell2_sim_configuration}    catenate
    ...    set_cell id=2 gnb=4 pci=18:1 tac=200 nrci=0x02 tdd_cell=on proxy=10.0.2.90:9998 nr_arfcn=658000:658000 gscn=8103
    ...    nr_scs=30kHz bs_channel_bandwidth=40MHz mandatory_for_activation=off
    ${gNB4_Cell3_sim_configuration}    catenate
    ...    set_cell id=13 gnb=4 pci=18:2 tac=200 nrci=0x0D tdd_cell=off proxy=10.0.2.90:9997 nr_arfcn=349400:368400 gscn=4605
    ...    nr_scs=15kHz bs_channel_bandwidth=10MHz mandatory_for_activation=off
    ${gNB4_Cell4_sim_configuration}    catenate
    ...    set_cell id=14 gnb=4 pci=19:0 tac=200 nrci=0x0E tdd_cell=off proxy=10.0.2.90:9996 nr_arfcn=143400:153400 gscn=1916
    ...    nr_scs=15kHz bs_channel_bandwidth=15MHz mandatory_for_activation=off
    Update Cfg    ${gNB4_Cell1_sim_configuration}
    Update Cfg    ${gNB4_Cell2_sim_configuration}
    Update Cfg    ${gNB4_Cell3_sim_configuration}
    Update Cfg    ${gNB4_Cell4_sim_configuration}

Setup XpAP Link
    Execute Egate Command    sim_trace enb=4 protocol=xp,xn on
    Execute Egate Command    enb_xp_param xp_peers=2 id=4    pass_regexp=${XP_setup_expect}    timeout=180s

Set Incompatible inter-gNB CA Xp-U protocol version
    ${gNB4_param}    catenate
    ...    gnb_param id=4 bwp_profile_id=1 bwp_profile_type=powersaving act_multiple_dedicated_bwps=yes location_bw_ul=1:2 location_bw_dl=3:4
    ...    Inter_gNB_CA_Allowed=yes CellLoadReportingPeriodicity=000 IgNBCAXpProtocolVersion=1000 IgNBCAXgUProtocolVersion=1
    Execute Egate Command    ${gNB4_param}
    Execute Egate Command    ignb_ca_configuration_update_indication_send id=4 target=2    pass_regexp=Sent to GNB-2
    fm fault should be raised    fault_id=${EFaultId_InterGnbCaXpVersionMismatchAl}    timeout=600

Delta Commission To delete sim gNB NRREL
    Delta Commission Parameters    ${online_modify_delete_NRREL_of_sim_gNB}
    BuiltIn.Log To Console    Online Update Parameters is done
    fm fault should be cleared    fault_id=${EFaultId_InterGnbCaXpVersionMismatchAl}    timeout=600

SA UE attach with scell addition and verify traffic
    [Arguments]    ${ue_id}=1    ${enb_id}=2    ${cell_id}=11    ${Expect}=${UE1Expect}
    Execute Egate Command    ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=1    pass_regexp=${Expect}
    Run Traffic And Verify Throughput    ue_id=${ue_id}

Run Traffic And Verify Throughput
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${qfi}=1
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} trf_id=1 protocol=tcp mbps=150 dir=dl
    ...    pass_regexp=Started Downlink Internal traffic over TCP on Ue    sleep_time=2
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} trf_id=2 protocol=tcp mbps=150 dir=dl
    ...    pass_regexp=Started Downlink Internal traffic over TCP on Ue    sleep_time=2
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} trf_id=1 protocol=tcp mbps=50 dir=ul
    ...    pass_regexp=Started Uplink Internal traffic over TCP on Ue
    Verify Throughput    ${ue_id}    ${pdu}    ${qfi}    270    45
    [teardown]    Stop Traffic    ${ue_id}    ${pdu}

Verify Throughput
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${qfi}=1    ${Tput_dl}=10    ${Tput_ul}=10    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    direction=ul    rate_type=ave
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pdsch    Throughput
    Should Not Match Regexp    ${scell_tput}    CellIndex-.*Mbps.*Mbps.*Mbps.* 0 Mbps
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

Stop Traffic
    [Arguments]    ${ue_id}=1    ${pdu}=1
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=${pdu} dir=dl trf_id=1
    ...    pass_regexp=Stopped Downlink Internal traffic on Ue
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=${pdu} dir=dl trf_id=2
    ...    pass_regexp=Stopped Downlink Internal traffic on Ue
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=${pdu} dir=ul trf_id=1
    ...    pass_regexp=Stopping Uplink Internal traffic on Ue

Delta Commission To delete NRREL
    Delta Commission Parameters    ${online_modify_delete_NRREL_of_Cell2_11}
    BuiltIn.Log To Console    Online Update Parameters is done

Delta Commission To add NRREL
    Delta Commission Parameters    ${PARAMS_ADJ_REL_FOR_GNB1}
    BuiltIn.Log To Console    Online Update Parameters is done
