*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CLOUD_5G_I_[LO][LO]_AP_[LOO]_SANSA_FS_ECPRI_CMWV_TDD    team-CN1ET
...    owner-Delun.Li    release-SBTS23R3    CRT
Resource    ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
${NOKIA_XNAP_PLUGIN_FLAG}    ${True}
${NOKIA_F1AP_PLUGIN_FLAG}    ${True}

@{PARAMS_IN_SCF}
...    @{PARAMS_FOR_CA}
...    @{PARAMS_FOR_GNB1}
...    @{PARAMS_ADJ_REL_FOR_GNB1}
...    @{PARAMS_AMF_PLMN_IPADDRS_GNB1}
...    @{PARAMS_RANSHARING_GNB1}
...    @{PARAMS_FOR_OTHERS}
@{PARAMS_IN_SCF_GNB2}
...    @{PARAMS_FOR_CA}
...    @{PARAMS_FOR_GNB2}
...    @{PARAMS_ADJ_REL_FOR_GNB2}
...    @{PARAMS_AMF_PLMN_IPADDRS_GNB2}
...    @{PARAMS_RANSHARING_GNB2}
...    @{PARAMS_FOR_OTHERS}
@{PARAMS_FOR_CA}
...    NRBTS:actCarrierAggregation=true
...    NRBTS:sCellActivationMethod=blind
...    NRBTS:caConfigurationSupport=4CCDL_2CCUL
...    NRBTS:weightForIgnbCaSelection=80
...    NRBTS:actIncXn=true
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:carrierAggregationSupportList=ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Any_Sa,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Fdd,ca_Fdd_Any_Sa
...    NRDU-1:actInterGnbCa=DLOnly
...    NRDU-1:dlToUlContributionRatio=101
...    NRCELL:actK1Opt=intraAndInter-gNB
...    NRCELL:maxNumScellsDlFr1=3
@{PARAMS_FOR_GNB1}
...    NRBTS:iGnbCaXnCfUpBackOffTmr=60
...    NRBTS:iGnbCaXnSetupReqTmr=60
...    NRBTS:iGnbCaXnSetupRespTmr=60
...    NRBTS:intGnbScellTempBlockTmr=60
...    NRCELL:sCellDeactivationTimerGNB=infinity
@{PARAMS_ADJ_REL_FOR_GNB1}
...    NRCELL:actUl256Qam=true
...    NRBTS/NRADJGNB-2:administrativeState=Unlocked
...    NRBTS/NRADJGNB-2:gNbIdLength=22
...    NRBTS/NRADJGNB-2:gNodeBId=2
...    NRBTS/NRADJGNB-2:weightForIgnbCaSelection=50
...    NRBTS/NRADJGNB-2:xnLinkRef=1
...    NRBTS/NRADJGNB-2:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-2:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-2:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-1:cellDepType=SA+NSA
...    delete:NRBTS/NRADJNRCELL-1:fiveGsTac
...    NRBTS/NRADJNRCELL-1:freqBandIndicatorNR=77
...    NRBTS/NRADJNRCELL-1:gNbId=2
...    NRBTS/NRADJNRCELL-1:gNbIdLength=22
...    NRBTS/NRADJNRCELL-1:lcrId=3
...    NRBTS/NRADJNRCELL-1:nrarfcn=653400
...    NRBTS/NRADJNRCELL-1:physCellId=52
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-1/ADJ_NRPLMNSET_SA-1:fiveGsTac=100
...    NRBTS/NRADJNRCELL-1/ADJ_NRPLMNSET_SA-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS/NRADJNRCELL-2:cellDepType=SA+NSA
...    delete:NRBTS/NRADJNRCELL-2:fiveGsTac
...    NRBTS/NRADJNRCELL-2:freqBandIndicatorNR=77
...    NRBTS/NRADJNRCELL-2:gNbId=2
...    NRBTS/NRADJNRCELL-2:gNbIdLength=22
...    NRBTS/NRADJNRCELL-2:lcrId=4
...    NRBTS/NRADJNRCELL-2:nrarfcn=648000
...    NRBTS/NRADJNRCELL-2:physCellId=53
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-2/ADJ_NRPLMNSET_SA-1:fiveGsTac=100
...    NRBTS/NRADJNRCELL-2/ADJ_NRPLMNSET_SA-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-2
...    NRBTS/NRADJNRCELL-3:cellDepType=SA+NSA
...    delete:NRBTS/NRADJNRCELL-3:fiveGsTac
...    NRBTS/NRADJNRCELL-3:freqBandIndicatorNR=3
...    NRBTS/NRADJNRCELL-3:gNbId=2
...    NRBTS/NRADJNRCELL-3:gNbIdLength=22
...    NRBTS/NRADJNRCELL-3:lcrId=11
...    NRBTS/NRADJNRCELL-3:nrarfcn=368400
...    NRBTS/NRADJNRCELL-3:physCellId=60
...    NRBTS/NRADJNRCELL-3:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-3:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-3:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-3/ADJ_NRPLMNSET_SA-1:fiveGsTac=100
...    NRBTS/NRADJNRCELL-3/ADJ_NRPLMNSET_SA-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-2
...    NRBTS/NRADJNRCELL-4:cellDepType=SA+NSA
...    delete:NRBTS/NRADJNRCELL-4:fiveGsTac
...    NRBTS/NRADJNRCELL-4:freqBandIndicatorNR=28
...    NRBTS/NRADJNRCELL-4:gNbId=2
...    NRBTS/NRADJNRCELL-4:gNbIdLength=22
...    NRBTS/NRADJNRCELL-4:lcrId=12
...    NRBTS/NRADJNRCELL-4:nrarfcn=153400
...    NRBTS/NRADJNRCELL-4:physCellId=61
...    NRBTS/NRADJNRCELL-4:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-4:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-4:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-4/ADJ_NRPLMNSET_SA-1:fiveGsTac=100
...    NRBTS/NRADJNRCELL-4/ADJ_NRPLMNSET_SA-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1,MRBTS-1/NRBTS-1/NRPLMN-2
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-1:gNbId=2
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-1:lcrId=3
...    NRCELL-1/NRREL-1:removeNotAllowed=false
...    NRCELL-1/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-2:gNbId=2
...    NRCELL-1/NRREL-2:gNbIdLength=22
...    NRCELL-1/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-2:lcrId=4
...    NRCELL-1/NRREL-2:removeNotAllowed=false
...    NRCELL-1/NRREL-2:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-3:gNbId=2
...    NRCELL-1/NRREL-3:gNbIdLength=22
...    NRCELL-1/NRREL-3:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-3:lcrId=11
...    NRCELL-1/NRREL-3:removeNotAllowed=false
...    NRCELL-1/NRREL-3:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-3:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-4:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-4:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-4:gNbId=2
...    NRCELL-1/NRREL-4:gNbIdLength=22
...    NRCELL-1/NRREL-4:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-4:lcrId=12
...    NRCELL-1/NRREL-4:removeNotAllowed=false
...    NRCELL-1/NRREL-4:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-4:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-4:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-4:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-4:gnbPlmn:mncLength=3
@{PARAMS_FOR_GNB2}
...    NRBTS:iGnbCaXnCfUpBackOffTmr=60
...    NRBTS:iGnbCaXnSetupReqTmr=60
...    NRBTS:iGnbCaXnSetupRespTmr=60
...    NRBTS:intGnbScellTempBlockTmr=60
...    NRCELL:sCellDeactivationTimerGNB=infinity
...    NRCELL-3:weightForSCellSelection=50
...    NRCELL-4:weightForSCellSelection=50
...    NRCELL-11:weightForSCellSelection=50
...    NRCELL-12:weightForSCellSelection=60
...    NRCELL-12:type0CoresetConfigurationIndex=6
...    NRCELL-12/NRCELL_FDD-1:chBwDl=10MHz
...    NRCELL-12/NRCELL_FDD-1:chBwUl=10MHz
@{PARAMS_ADJ_REL_FOR_GNB2}
...    NRCELL:actUl256Qam=true
...    NRBTS/NRADJGNB-1:administrativeState=Unlocked
...    NRBTS/NRADJGNB-1:gNbIdLength=22
...    NRBTS/NRADJGNB-1:gNodeBId=1
...    NRBTS/NRADJGNB-1:weightForIgnbCaSelection=40
...    NRBTS/NRADJGNB-1:xnLinkRef=1
...    NRBTS/NRADJGNB-1:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-1:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-1:cellDepType=SA+NSA
...    delete:NRBTS/NRADJNRCELL-1:fiveGsTac
...    NRBTS/NRADJNRCELL-1:freqBandIndicatorNR=77
...    NRBTS/NRADJNRCELL-1:gNbId=1
...    NRBTS/NRADJNRCELL-1:gNbIdLength=22
...    NRBTS/NRADJNRCELL-1:lcrId=1
...    NRBTS/NRADJNRCELL-1:nrarfcn=663400
...    NRBTS/NRADJNRCELL-1:physCellId=50
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-1/ADJ_NRPLMNSET_SA-1:fiveGsTac=200
...    NRBTS/NRADJNRCELL-1/ADJ_NRPLMNSET_SA-1:nrPlmnDNList=MRBTS-2/NRBTS-2/NRPLMN-1,MRBTS-2/NRBTS-2/NRPLMN-2
...    NRCELL-3/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-3/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-3/NRREL-1:gNbId=1
...    NRCELL-3/NRREL-1:gNbIdLength=22
...    NRCELL-3/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-3/NRREL-1:lcrId=1
...    NRCELL-3/NRREL-1:removeNotAllowed=false
...    NRCELL-3/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-3/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-3/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-3/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-3/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-4/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-4/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-4/NRREL-1:gNbId=1
...    NRCELL-4/NRREL-1:gNbIdLength=22
...    NRCELL-4/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-4/NRREL-1:lcrId=1
...    NRCELL-4/NRREL-1:removeNotAllowed=false
...    NRCELL-4/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-4/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-4/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-4/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-4/NRREL-1:gnbPlmn:mncLength=3
@{PARAMS_AMF_PLMN_IPADDRS_GNB1}
...    MRBTS/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-2:ipAddressAllocationMethod=MANUAL
...    MRBTS/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-2:localIpAddr=10.0.1.22
...    MRBTS/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-2:localIpPrefixLength=24
...    MRBTS/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-3:ipAddressAllocationMethod=MANUAL
...    MRBTS/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-3:localIpAddr=10.0.1.23
...    MRBTS/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-3:localIpPrefixLength=24
...    MRBTS/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-4:ipAddressAllocationMethod=MANUAL
...    MRBTS/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-4:localIpAddr=10.0.1.24
...    MRBTS/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-4:localIpPrefixLength=24
...    MRBTS/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-5:ipAddressAllocationMethod=MANUAL
...    MRBTS/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-5:localIpAddr=10.0.1.25
...    MRBTS/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-5:localIpPrefixLength=24
...    MRBTS/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-1:ipAddressAllocationMethod=MANUAL
...    MRBTS/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-1:localIpAddr=fc00::172:18:6:21
...    MRBTS/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-1:localIpPrefixLength=112
...    MRBTS/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-2:ipAddressAllocationMethod=MANUAL
...    MRBTS/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-2:localIpAddr=fc00::172:18:6:22
...    MRBTS/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-2:localIpPrefixLength=112
...    MRBTS/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-3:ipAddressAllocationMethod=MANUAL
...    MRBTS/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-3:localIpAddr=fc00::172:18:6:23
...    MRBTS/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-3:localIpPrefixLength=112
...    MRBTS/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-4:ipAddressAllocationMethod=MANUAL
...    MRBTS/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-4:localIpAddr=fc00::172:18:6:24
...    MRBTS/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-4:localIpPrefixLength=112
...    MRBTS/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-5:ipAddressAllocationMethod=MANUAL
...    MRBTS/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-5:localIpAddr=fc00::172:18:6:25
...    MRBTS/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-5:localIpPrefixLength=112
...    SERVEDAMF-1:amfIPAddress=10.0.1.1
...    SERVEDAMF-1:ngTnlId=1
...    SERVEDAMF-2:amfIPAddress=10.0.1.102
...    SERVEDAMF-2:ngTnlId=1
...    SERVEDAMF-3:amfIPAddress=10.0.1.103
...    SERVEDAMF-3:ngTnlId=1
...    NRPLMN-1:mcc=311
...    NRPLMN-1:mnc=489
...    NRPLMN-1:mncLength=3
...    NRPLMN-2:mcc=311
...    NRPLMN-2:mnc=402
...    NRPLMN-2:mncLength=3
...    NRPLMN-3:mcc=311
...    NRPLMN-3:mnc=403
...    NRPLMN-3:mncLength=3
@{PARAMS_RANSHARING_GNB1}
...    NRBTS:actRanSharing=true
...    NRBTS:actTrsSepaSARanSharing=true
...    NRBTS:actNgcFlexSaMode=true
...    NRBTS:ngCplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1|ngTnlId=1
...    NRBTS:ngUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1|nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS:ngUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1|nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-2
...    NRBTS:ngUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1|nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-3
...    NRBTS:xnCplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1|xnTnlId=1
...    NRBTS:xnUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1|nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS/XNLINK-1:xnTnlId=1
...    NRDU-1:xgUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1|nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRDU-1:xgUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-2|nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-2
...    NRDU-1:xgUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-3|nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-3
...    NRBTS/TRACKINGAREA-200:fiveGsTac=200
...    NRBTS/TRACKINGAREA-200:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1
...    NRBTS/TRACKINGAREA-200:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2
...    NRBTS/TRACKINGAREA-300:fiveGsTac=300
...    NRBTS/TRACKINGAREA-300:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1
...    NRBTS/TRACKINGAREA-300:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2
...    NRBTS/TRACKINGAREA-300:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-3|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-3
...    delete:NRCELL:trackingAreaDN
...    delete:NRCELL:configuredEpsTac
...    NRCELL/NRPLMNSET_SA-1:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-200
...    NRCELL/NRPLMNSET_SA-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRCELL/NRPLMNSET_SA-2:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-300
...    NRCELL/NRPLMNSET_SA-2:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-2,MRBTS-1/NRBTS-1/NRPLMN-3
...    NRCELL/NRPLMNSET_NSA-1:configuredEpsTac=222
...    NRCELL/NRPLMNSET_NSA-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1,MRBTS-1/NRBTS-1/NRPLMN-2
...    NRBTS/SNSSAI-1:administrativeState=Unlocked
...    NRBTS/SNSSAI-1:sst=1
...    delete:NRBTS/SNSSAI-1:sd
...    NRBTS/SNSSAI-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1,MRBTS-1/NRBTS-1/NRPLMN-2
...    NRBTS/SNSSAI-1:xgUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-4
...    NRBTS/SNSSAI-2:administrativeState=Unlocked
...    NRBTS/SNSSAI-2:sst=1
...    NRBTS/SNSSAI-2:sd=13714341
...    NRBTS/SNSSAI-2:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1,MRBTS-1/NRBTS-1/NRPLMN-2
...    NRBTS/SNSSAI-2:xgUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-5
...    NRBTS/SNSSAI-3:administrativeState=Unlocked
...    NRBTS/SNSSAI-3:sst=1
...    NRBTS/SNSSAI-3:sd=0
...    NRBTS/SNSSAI-3:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-2,MRBTS-1/NRBTS-1/NRPLMN-3
...    NRBTS/SNSSAI-3:xgUplane:ipV4AddressDN1=${EMPTY}
...    NRBTS/SNSSAI-3:xgUplane:ipV6AddressDN1=${EMPTY}
@{PARAMS_AMF_PLMN_IPADDRS_GNB2}
...    MRBTS/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-2:ipAddressAllocationMethod=MANUAL
...    MRBTS/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-2:localIpAddr=10.0.1.32
...    MRBTS/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-2:localIpPrefixLength=24
...    MRBTS/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-3:ipAddressAllocationMethod=MANUAL
...    MRBTS/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-3:localIpAddr=10.0.1.33
...    MRBTS/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-3:localIpPrefixLength=24
...    MRBTS/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-4:ipAddressAllocationMethod=MANUAL
...    MRBTS/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-4:localIpAddr=10.0.1.34
...    MRBTS/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-4:localIpPrefixLength=24
...    MRBTS/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-5:ipAddressAllocationMethod=MANUAL
...    MRBTS/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-5:localIpAddr=10.0.1.35
...    MRBTS/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-5:localIpPrefixLength=24
...    MRBTS/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-1:ipAddressAllocationMethod=MANUAL
...    MRBTS/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-1:localIpAddr=fc00::172:18:6:31
...    MRBTS/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-1:localIpPrefixLength=112
...    MRBTS/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-2:ipAddressAllocationMethod=MANUAL
...    MRBTS/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-2:localIpAddr=fc00::172:18:6:32
...    MRBTS/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-2:localIpPrefixLength=112
...    MRBTS/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-3:ipAddressAllocationMethod=MANUAL
...    MRBTS/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-3:localIpAddr=fc00::172:18:6:33
...    MRBTS/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-3:localIpPrefixLength=112
...    MRBTS/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-4:ipAddressAllocationMethod=MANUAL
...    MRBTS/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-4:localIpAddr=fc00::172:18:6:34
...    MRBTS/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-4:localIpPrefixLength=112
...    MRBTS/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-5:ipAddressAllocationMethod=MANUAL
...    MRBTS/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-5:localIpAddr=fc00::172:18:6:35
...    MRBTS/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-5:localIpPrefixLength=112
...    SERVEDAMF-1:amfIPAddress=10.0.1.1
...    SERVEDAMF-1:ngTnlId=1
...    SERVEDAMF-2:amfIPAddress=10.0.1.102
...    SERVEDAMF-2:ngTnlId=1
...    SERVEDAMF-4:amfIPAddress=10.0.1.104
...    SERVEDAMF-4:ngTnlId=1
...    NRPLMN-1:mcc=311
...    NRPLMN-1:mnc=489
...    NRPLMN-1:mncLength=3
...    NRPLMN-2:mcc=311
...    NRPLMN-2:mnc=402
...    NRPLMN-2:mncLength=3
...    NRPLMN-4:mcc=311
...    NRPLMN-4:mnc=404
...    NRPLMN-4:mncLength=3
@{PARAMS_RANSHARING_GNB2}
...    NRBTS:actRanSharing=true
...    NRBTS:actTrsSepaSARanSharing=true
...    NRBTS:actNgcFlexSaMode=true
...    NRBTS:ngCplane:ipV4AddressDN1=MRBTS-2/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1|ngTnlId=1
...    NRBTS:ngUplane:ipV4AddressDN1=MRBTS-2/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1|nrPlmnDN=MRBTS-2/NRBTS-2/NRPLMN-1
...    NRBTS:ngUplane:ipV4AddressDN1=MRBTS-2/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1|nrPlmnDN=MRBTS-2/NRBTS-2/NRPLMN-2
...    NRBTS:ngUplane:ipV4AddressDN1=MRBTS-2/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1|nrPlmnDN=MRBTS-2/NRBTS-2/NRPLMN-4
...    NRBTS:xnCplane:ipV4AddressDN1=MRBTS-2/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1|xnTnlId=1
...    NRBTS:xnUplane:ipV4AddressDN1=MRBTS-2/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1|nrPlmnDN=MRBTS-2/NRBTS-2/NRPLMN-1
...    NRBTS/XNLINK-1:xnTnlId=1
...    NRDU-1:xgUplane:ipV4AddressDN1=MRBTS-2/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1|nrPlmnDN=MRBTS-2/NRBTS-2/NRPLMN-1
...    NRDU-1:xgUplane:ipV6AddressDN1=MRBTS-2/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-1|nrPlmnDN=MRBTS-2/NRBTS-2/NRPLMN-1
...    NRDU-1:xgUplane:ipV4AddressDN1=MRBTS-2/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-2|nrPlmnDN=MRBTS-2/NRBTS-2/NRPLMN-2
...    NRDU-1:xgUplane:ipV6AddressDN1=MRBTS-2/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-2|nrPlmnDN=MRBTS-2/NRBTS-2/NRPLMN-2
...    NRDU-1:xgUplane:ipV4AddressDN1=${EMPTY}|nrPlmnDN=MRBTS-2/NRBTS-2/NRPLMN-4
...    NRDU-1:xgUplane:ipV6AddressDN1=MRBTS-2/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-3|nrPlmnDN=MRBTS-2/NRBTS-2/NRPLMN-4
...    NRBTS/TRACKINGAREA-100:fiveGsTac=100
...    NRBTS/TRACKINGAREA-100:snssaiList:snssaiDN=MRBTS-2/NRBTS-2/SNSSAI-1|snssaiDN=MRBTS-2/NRBTS-2/SNSSAI-1
...    NRBTS/TRACKINGAREA-100:snssaiList:snssaiDN=MRBTS-2/NRBTS-2/SNSSAI-2|snssaiDN=MRBTS-2/NRBTS-2/SNSSAI-2
...    NRBTS/TRACKINGAREA-200:fiveGsTac=200
...    NRBTS/TRACKINGAREA-200:snssaiList:snssaiDN=MRBTS-2/NRBTS-2/SNSSAI-1|snssaiDN=MRBTS-2/NRBTS-2/SNSSAI-1
...    NRBTS/TRACKINGAREA-200:snssaiList:snssaiDN=MRBTS-2/NRBTS-2/SNSSAI-2|snssaiDN=MRBTS-2/NRBTS-2/SNSSAI-2
...    NRBTS/TRACKINGAREA-200:snssaiList:snssaiDN=MRBTS-2/NRBTS-2/SNSSAI-3|snssaiDN=MRBTS-2/NRBTS-2/SNSSAI-3
...    delete:NRCELL:trackingAreaDN
...    delete:NRCELL:configuredEpsTac
...    NRCELL/NRPLMNSET_SA-1:trackingAreaDN=MRBTS-2/NRBTS-2/TRACKINGAREA-100
...    NRCELL/NRPLMNSET_SA-1:nrPlmnDNList=MRBTS-2/NRBTS-2/NRPLMN-1
...    NRCELL/NRPLMNSET_NSA-1:configuredEpsTac=222
...    NRCELL/NRPLMNSET_NSA-1:nrPlmnDNList=MRBTS-2/NRBTS-2/NRPLMN-1,MRBTS-2/NRBTS-2/NRPLMN-2
...    NRCELL-3/NRPLMNSET_SA-2:trackingAreaDN=MRBTS-2/NRBTS-2/TRACKINGAREA-200
...    NRCELL-3/NRPLMNSET_SA-2:nrPlmnDNList=MRBTS-2/NRBTS-2/NRPLMN-2,MRBTS-2/NRBTS-2/NRPLMN-4
...    NRCELL-4/NRPLMNSET_SA-2:trackingAreaDN=MRBTS-2/NRBTS-2/TRACKINGAREA-200
...    NRCELL-4/NRPLMNSET_SA-2:nrPlmnDNList=MRBTS-2/NRBTS-2/NRPLMN-2,MRBTS-2/NRBTS-2/NRPLMN-4
...    NRCELL-11/NRPLMNSET_SA-2:trackingAreaDN=MRBTS-2/NRBTS-2/TRACKINGAREA-200
...    NRCELL-11/NRPLMNSET_SA-2:nrPlmnDNList=MRBTS-2/NRBTS-2/NRPLMN-2,MRBTS-2/NRBTS-2/NRPLMN-4
...    NRBTS/SNSSAI-1:administrativeState=Unlocked
...    NRBTS/SNSSAI-1:sst=1
...    delete:NRBTS/SNSSAI-1:sd
...    NRBTS/SNSSAI-1:nrPlmnDNList=MRBTS-2/NRBTS-2/NRPLMN-1,MRBTS-2/NRBTS-2/NRPLMN-2
...    NRBTS/SNSSAI-1:xgUplane:ipV4AddressDN1=MRBTS-2/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-3
...    NRBTS/SNSSAI-1:xgUplane:ipV6AddressDN1=MRBTS-2/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-4
...    NRBTS/SNSSAI-2:administrativeState=Unlocked
...    NRBTS/SNSSAI-2:sst=1
...    NRBTS/SNSSAI-2:sd=13714341
...    NRBTS/SNSSAI-2:nrPlmnDNList=MRBTS-2/NRBTS-2/NRPLMN-1,MRBTS-2/NRBTS-2/NRPLMN-2
...    NRBTS/SNSSAI-2:xgUplane:ipV4AddressDN1=MRBTS-2/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-4
...    NRBTS/SNSSAI-2:xgUplane:ipV6AddressDN1=MRBTS-2/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-5
...    NRBTS/SNSSAI-3:administrativeState=Unlocked
...    NRBTS/SNSSAI-3:sst=1
...    NRBTS/SNSSAI-3:sd=0
...    NRBTS/SNSSAI-3:nrPlmnDNList=MRBTS-2/NRBTS-2/NRPLMN-2,MRBTS-2/NRBTS-2/NRPLMN-4
...    NRBTS/SNSSAI-3:xgUplane:ipV4AddressDN1=MRBTS-2/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-4
...    NRBTS/SNSSAI-3:xgUplane:ipV6AddressDN1=MRBTS-2/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-5
@{PARAMS_FOR_OTHERS}

...    NRCELL:actCDrx=false

@{UE1_expect}
...    pcid:52, scellIdx:1
...    pcid:61, scellIdx:2
...    SCellIndex 1 activated successfully at airphone
...    SCellIndex 2 activated successfully at airphone
@{UE2_expect}
...    pcid:53, scellIdx:1
...    pcid:60, scellIdx:2
...    SCellIndex 1 activated successfully at airphone
...    SCellIndex 2 activated successfully at airphone
@{unexpect}    sCellIndex3

@{OnlineParam_add_slice_IPV6}
...    NRBTS/SNSSAI-1:xgUplane:ipV6AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-4
...    NRBTS/SNSSAI-2:xgUplane:ipV6AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-5

@{OnlineParam_modify_SNSSAI-1_IPV4_gNB1}
...    NRBTS/SNSSAI-1:xgUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-5

@{OnlineParam_remove_SNSSAI-1_IPV6_gNB1}
...    NRBTS/SNSSAI-1:xgUplane:ipV6AddressDN1=${EMPTY}

@{OnlineParam_modify_SNSSAI-2_IPV4_gNB1}
...    NRBTS/SNSSAI-2:xgUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-3

@{OnlineParam_remove_SNSSAI-2_IPV6_gNB1}
...    NRBTS/SNSSAI-2:xgUplane:ipV6AddressDN1=${EMPTY}
##recover
@{OnlineParam_recover_gNB1}
...    NRBTS/SNSSAI-1:xgUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-4
...    NRBTS/SNSSAI-2:xgUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-5

@{OnlineParam_modify_L032_gNB1}
##delete xguplane configuration of prime-gNB SNSSAI-1 and SNSSAI-2
...    NRBTS/SNSSAI-1:xgUplane=${EMPTY}
...    NRBTS/SNSSAI-2:xgUplane=${EMPTY}

@{OnlineParam_modify_L032_gNB2}
##delete xguplane configuration of prime-gNB SNSSAI-1, SNSSAI-2 and SNSSAI-3
...    NRBTS/SNSSAI-1:xgUplane=${EMPTY}
...    NRBTS/SNSSAI-2:xgUplane=${EMPTY}
...    NRBTS/SNSSAI-3:xgUplane=${EMPTY}

@{OnlineParam_add_NRDU_IPV6}
...    NRBTS/NRDU-1:xgUplane:ipV6AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-1|nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS/NRDU-1:xgUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1|nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS/NRDU-1:xgUplane:ipV6AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-2|nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-2
...    NRBTS/NRDU-1:xgUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-2|nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-2
...    NRBTS/NRDU-1:xgUplane:ipV6AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-3|nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-3
...    NRBTS/NRDU-1:xgUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-3|nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-3

@{OnlineParam_modify_NRDU-1_PLMN-1_IPV4_gNB2}
...    NRBTS/NRDU-1:xgUplane:ipV6AddressDN1=MRBTS-2/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-1|nrPlmnDN=MRBTS-2/NRBTS-2/NRPLMN-1
...    NRBTS/NRDU-1:xgUplane:ipV4AddressDN1=MRBTS-2/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-4|nrPlmnDN=MRBTS-2/NRBTS-2/NRPLMN-1
...    NRBTS/NRDU-1:xgUplane:ipV6AddressDN1=MRBTS-2/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-2|nrPlmnDN=MRBTS-2/NRBTS-2/NRPLMN-2
...    NRBTS/NRDU-1:xgUplane:ipV4AddressDN1=MRBTS-2/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-2|nrPlmnDN=MRBTS-2/NRBTS-2/NRPLMN-2
...    NRBTS/NRDU-1:xgUplane:ipV6AddressDN1=MRBTS-2/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-3|nrPlmnDN=MRBTS-2/NRBTS-2/NRPLMN-4
...    NRBTS/NRDU-1:xgUplane:ipV4AddressDN1=${EMPTY}|nrPlmnDN=MRBTS-2/NRBTS-2/NRPLMN-4

@{OnlineParam_remove_NRDU-1_PLMN-1_IPV6_gNB2}
...    NRBTS-2/NRDU-1:xgUplane:ipV4AddressDN1=MRBTS-2/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1|nrPlmnDN=MRBTS-2/NRBTS-2/NRPLMN-1
...    NRBTS/NRDU-1:xgUplane:ipV6AddressDN1=${EMPTY}|ipV4AddressDN1=MRBTS-2/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRBTS-2/NRDU-1:xgUplane:ipV4AddressDN1=MRBTS-2/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-2|nrPlmnDN=MRBTS-2/NRBTS-2/NRPLMN-2
...    NRBTS-2/NRDU-1:xgUplane:ipV6AddressDN1=MRBTS-2/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-2|nrPlmnDN=MRBTS-2/NRBTS-2/NRPLMN-2
...    NRBTS-2/NRDU-1:xgUplane:ipV6AddressDN1=MRBTS-2/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-3|nrPlmnDN=MRBTS-2/NRBTS-2/NRPLMN-4

${V6_DN}    MRBTS-2/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6
@{OnlineParam_modify_NRDU-1_PLMN-2_gNB2}
...    NRBTS/NRDU-1:xgUplane:nrPlmnDN=MRBTS-2/NRBTS-2/NRPLMN-1|ipV4AddressDN1=MRBTS-2/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-4
...    NRBTS/NRDU-1:xgUplane:ipV6AddressDN1=${EMPTY}|ipV4AddressDN1=MRBTS-2/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-4
...    NRBTS/NRDU-1:xgUplane:ipV6AddressDN1=${V6_DN}-2|ipV4AddressDN1=MRBTS-2/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-2
...    NRBTS/NRDU-1:xgUplane:nrPlmnDN=MRBTS-2/NRBTS-2/NRPLMN-4|ipV4AddressDN1=MRBTS-2/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-2
...    NRBTS/NRDU-1:xgUplane:ipV6AddressDN1=${V6_DN}-3|ipV4AddressDN1=MRBTS-2/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRBTS/NRDU-1:xgUplane:nrPlmnDN=MRBTS-2/NRBTS-2/NRPLMN-4|ipV4AddressDN1=MRBTS-2/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1

####add recover
@{OnlineParam_recover_gNB2}
...    NRBTS/NRDU-1:xgUplane:ipV6AddressDN1=MRBTS-2/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-1|nrPlmnDN=MRBTS-2/NRBTS-2/NRPLMN-1
...    NRBTS/NRDU-1:xgUplane:ipV4AddressDN1=MRBTS-2/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1|nrPlmnDN=MRBTS-2/NRBTS-2/NRPLMN-1
...    NRBTS/NRDU-1:xgUplane:ipV6AddressDN1=MRBTS-2/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-2|nrPlmnDN=MRBTS-2/NRBTS-2/NRPLMN-2
...    NRBTS/NRDU-1:xgUplane:ipV4AddressDN1=MRBTS-2/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-2|nrPlmnDN=MRBTS-2/NRBTS-2/NRPLMN-2
...    NRBTS/NRDU-1:xgUplane:ipV6AddressDN1=MRBTS-2/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-3|nrPlmnDN=MRBTS-2/NRBTS-2/NRPLMN-4
...    NRBTS/NRDU-1:xgUplane:ipV4AddressDN1=MRBTS-2/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1|nrPlmnDN=MRBTS-2/NRBTS-2/NRPLMN-4
...    NRBTS/SNSSAI-1:xgUplane:ipV4AddressDN1=MRBTS-2/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-3
...    NRBTS/SNSSAI-1:xgUplane:ipV6AddressDN1=MRBTS-2/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-4
...    NRBTS/SNSSAI-2:xgUplane:ipV4AddressDN1=MRBTS-2/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-4
...    NRBTS/SNSSAI-2:xgUplane:ipV6AddressDN1=MRBTS-2/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-5
...    NRBTS/SNSSAI-3:xgUplane:ipV4AddressDN1=MRBTS-2/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-4
...    NRBTS/SNSSAI-3:xgUplane:ipV6AddressDN1=MRBTS-2/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-5

@{OnlineParam_lock_SNSSAI-2_gNB1}
...    NRBTS-1/SNSSAI-2:administrativeState=Locked

@{OnlineParam_Unlock_SNSSAI-2_gNB1}
...    NRBTS-1/SNSSAI-2:administrativeState=Unlocked
...    delete:NRBTS/SNSSAI-1:xgUplane:ipV6AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-4
...    delete:NRBTS/SNSSAI-2:xgUplane:ipV6AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-5

@{OnlineParam_L040_Precondition_GNB1}
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRCELL-1:a1MeasSCellAddEnabled=rsrp
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=75
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=85
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=80ms
...    NRCELL-1/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-4:sCellAdditionMethod=covBasedA1
...    NRBTS-1/NRDRB_MAC-1:maxDlHarqTxDrb=3
...    NRBTS-1/NRDRB_MAC-2:maxDlHarqTxDrb=3
...    NRBTS-1/NRDRB_MAC-3:maxDlHarqTxDrb=3
...    NRBTS-1/NRDRB_MAC-4:maxDlHarqTxDrb=3
...    NRBTS-1/NRDRB_MAC-1:maxUlHarqTxDrb=3
...    NRBTS-1/NRDRB_MAC-2:maxUlHarqTxDrb=3
...    NRBTS-1/NRDRB_MAC-3:maxUlHarqTxDrb=3
...    NRBTS-1/NRDRB_MAC-4:maxUlHarqTxDrb=3
...    NRCELL-1:actDl256Qam=true
...    NRCELL-1:actUl256Qam=true

@{OnlineParam_L040_Precondition_GNB2}
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRCELL-3:a2MeasSCellRelEnabled=rsrp
...    NRCELL-3:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-3:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=33|a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-12:a2MeasSCellRelEnabled=rsrp
...    NRCELL-12:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-12:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=33|a2TimeToTriggerSCellRelSsbRsrp=0ms

@{OnlineParam_Change_ActserviceAwareConfig_Disable_L040_GNB1}
...    NRCELL-1:actCsiMeasEthFlowControl=PastTputBased
...    NRCELLGRP-0:maxDlHarqTx=6
...    NRBTS-1/NRDRB_MAC-1:maxDlHarqTxDrb=4
...    NRBTS-1/NRDRB_MAC-2:maxDlHarqTxDrb=4
...    NRBTS-1/NRDRB_MAC-3:maxDlHarqTxDrb=4
...    NRBTS-1/NRDRB_MAC-4:maxDlHarqTxDrb=4
...    NRCELLGRP-0:maxUlHarqTx=6
...    NRBTS-1/NRDRB_MAC-1:maxUlHarqTxDrb=4
...    NRBTS-1/NRDRB_MAC-2:maxUlHarqTxDrb=4
...    NRBTS-1/NRDRB_MAC-3:maxUlHarqTxDrb=4
...    NRBTS-1/NRDRB_MAC-4:maxUlHarqTxDrb=4
...    NRCELL:allowUnsuppBcOrBcs=accept unknown BCSs
...    NRCELL-1:actDl256Qam=false
...    NRCELL-1:actUl256Qam=false

@{OnlineParam_Change_ActserviceAwareConfig_Enable_L040_GNB1}
...    NRCELL-1:actServiceAwareConfig=true
...    NRCELL-1:actAdaptiveSr=true
...    NRCELL-1:adaptiveSrLoadThresholdDown=40
...    NRCELL-1:adaptiveSrLoadThresholdUp=60
...    NRCELL-1:adaptiveSrBlockingMinimization=0
...    NRCELL-1:srPeriodicityMin=slots10
...    NRCELL-1:vonrReservation=0

@{OnlineParam_Change_After_ActserviceAwareConfig_Enable_L040_GNB1}
...    NRBTS-1/NRDRB_MAC-1:maxDlHarqTxDrb=7
...    NRBTS-1/NRDRB_MAC-2:maxDlHarqTxDrb=7
...    NRBTS-1/NRDRB_MAC-3:maxDlHarqTxDrb=7
...    NRBTS-1/NRDRB_MAC-4:maxDlHarqTxDrb=7
...    NRBTS-1/NRDRB_MAC-1:maxUlHarqTxDrb=7
...    NRBTS-1/NRDRB_MAC-2:maxUlHarqTxDrb=7
...    NRBTS-1/NRDRB_MAC-3:maxUlHarqTxDrb=7
...    NRBTS-1/NRDRB_MAC-4:maxUlHarqTxDrb=7
...    NRCELL-1:allowUnsuppBcOrBcs=accept unknown band combinations,accept unknown BCSs
...    NRCELL-1:actDl256Qam=true
...    NRCELL-1:actUl256Qam=true

@{OnlineParam_cover_L040_gNB1}
...    NRBTS:actMeasBasedSCellAdditionSa=disabled
...    delete:NRCELL-1:a1MeasSCellAddEnabled
...    NRCELL-1:actCsiMeasEthFlowControl=CSIMeasBasedAllUe
...    NRCELL-1:actServiceAwareConfig=false
...    NRCELL-1:actAdaptiveSr=false
...    delete:NRCELL-1:adaptiveSrLoadThresholdDown
...    delete:NRCELL-1:adaptiveSrLoadThresholdUp
...    delete:NRCELL-1:adaptiveSrBlockingMinimization
...    delete:NRCELL-1:srPeriodicityMin
...    delete:NRCELL-1:vonrReservation
...    delete:NRBTS-1/NRDRB_MAC-1:maxDlHarqTxDrb
...    delete:NRBTS-1/NRDRB_MAC-2:maxDlHarqTxDrb
...    delete:NRBTS-1/NRDRB_MAC-3:maxDlHarqTxDrb
...    delete:NRBTS-1/NRDRB_MAC-4:maxDlHarqTxDrb
...    delete:NRBTS-1/NRDRB_MAC-1:maxUlHarqTxDrb
...    delete:NRBTS-1/NRDRB_MAC-2:maxUlHarqTxDrb
...    delete:NRBTS-1/NRDRB_MAC-3:maxUlHarqTxDrb
...    delete:NRBTS-1/NRDRB_MAC-4:maxUlHarqTxDrb
...    NRCELL-1:allowUnsuppBcOrBcs=accept unknown band combinations
...    NRCELL-1:actDl256Qam=false
...    NRCELL-1:actUl256Qam=false
...    NRCELL-1/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-2:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-3:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-4:sCellAdditionMethod=blind

@{OnlineParam_cover_L040_gNB2}
...    delete:NRCELL-3:a2MeasSCellRelEnabled
...    delete:NRCELL-12:a2MeasSCellRelEnabled
...    NRBTS:actMeasBasedSCellAdditionSa=disabled


${F1_CU_P_RESET_RCVD}           M55150C00006
${F1_CU_P_RESET_ACK_MSG_SENT}      M55150C00007
${NR_RLC_PDU_DL_VOL_CA_SCELL}      M55310C20000
${NR_RLC_PDU_DL_VOL_CA_PCELL}      M55310C20001
${IGNB_CA_ATT_SA_REL_REQ}      M55118C11012
${E1_RESET_SENT_CUCP}       M55121C00501
${E1_RESET_ACK_RECD_CUCP}      M55121C00502
#F1_CU_P_RESET_RCVD(M55150C00006)This counter is incremented when partial F1AP: Reset message is received by gNB-CU.
#F1_CU_P_RESET_ACK_MSG_SENT(M55150C00007)This counter is incremented when partial F1AP: Reset Acknowledge is sent by gNB-CU.
#NR_RLC_PDU_DL_VOL_CA_SCELL(M55310C20000)This counter provides the DL data volume for the UEs that use this cell as S-Cell for CA.
#NR_RLC_PDU_DL_VOL_CA_PCELL(M55310C20001)This counter provides the DL data volume for the UEs that use this cell as P-Cell for CA.
#IGNB_CA_ATT_SA_REL_REQ(M55118C11012)The counter counts the number of inter gNB CA addition attempts release requests sent for SA.
#E1_RESET_SENT_CUCP (M55121C00501) shall be increased by gNB-CU-CP when a RESET message for is sent out on E1.
#E1_RESET_ACK_RECD_CUCP (M55121C00502)shall be increased by gNB-CU-CP when a RESET ACKNOWLEDGE message is received on E1

@{PM_Counters_Check_GNB2}
...    NRDU-1:NF1UU:${F1_CU_P_RESET_RCVD}=3
...    NRDU-1:NF1UU:${F1_CU_P_RESET_ACK_MSG_SENT}=3
...    NRCELL-4:NLRLC:${NR_RLC_PDU_DL_VOL_CA_SCELL}>0
...    NRCELL-11:NLRLC:${NR_RLC_PDU_DL_VOL_CA_SCELL}>0

@{PM_Counters_Check_GNB1}
...    NRCELL-1:NLRLC:${NR_RLC_PDU_DL_VOL_CA_PCELL}>0

@{PM_Counters_Check_L035}
...    NRCELL-1:NCAC:${IGNB_CA_ATT_SA_REL_REQ}=2
...    NRBTS-1:NE1CB:${E1_RESET_SENT_CUCP}<3
...    NRBTS-1:NE1CB:${E1_RESET_ACK_RECD_CUCP}<3

*** Test Cases ***
CB008140-ET-L031_online_modification_parameter_under_MOC_SNSSAI_xgUplane_in_priGNB
    [Documentation]
    ...    This user scenario verifies gNB behavior to support online modification of slice parameters in prime-gNB.
    ...    [Configuration]:
    ...    Cell id=1 gnb=2 pci=16:2 tac=200 tdd_cell=on band=n77 nr_arfcn=663400:663400 gscn=8159 chBw=100MHz Cellid=0x4001
    ...    Cell id=2 gnb=2 pci=17:0 tac=200 tdd_cell=on band=n77 nr_arfcn=658000:658000 gscn=8103 chBw=40MHz
    ...    Cell id=3 gnb=3 pci=17:1 tac=200 tdd_cell=on band=n77 nr_arfcn=653400:653400 gscn=8072 chBw=100MHz SCellWeight=50 Cellid=0x8003/32771
    ...    Cell id=4 gnb=3 pci=17:2 tac=200 tdd_cell=on band=n77 nr_arfcn=648000:648000 gscn=8000 chBw=40MHz SCellWeight=50 Cellid=0x8004/32772
    ...    Cell id=11 gnb=3 pci=20:0 tac=200 tdd_cell=off band=n3 nr_arfcn=349400:368400 gscn=4605 chBw=10MHz SCellWeight=50 Cellid=0x800b/32779
    ...    Cell id=12 gnb=3 pci=20:1 tac=200 tdd_cell=off band=n28 nr_arfcn=143400:153400 gscn=1916 chBw=10MHz SCellWeight=60 Cellid=0x800c/32780
    ...    2.Test Case Steps:
    ...         a. UE1 with PLMN1(311 489) Slice1 Register And PDU Session Setup On Cell1_1 with IPV4, Start Traffic
    ...         b. UE4 with PLMN2(311 402) Slice2 Register And PDU Session Setup On Cell1_1 with IPV4, Start Traffic
    ...         c. Since ext-gnb already support ipv6, then add ipv6 in prime-gnb for slice-1 and slice-2
    ...         d. UE3 with PLMN1(311 489) Slice1 Register And PDU Session Setup On Cell1_1 with IPV6, Start Traffic
    ...         e. UE5 with PLMN2(311 402) Slice2 Register And PDU Session Setup On Cell1_1 with IPV6, Start Traffic
    ...         f. Modify SNSSAI-1 IPV4 link
    ...         g. remove SNSSAI-1 IPV6 config of gNB1.
    ...         h. Modify SNSSAI-2 IPV4 link of gNB1.
    ...         i. delete SNSSAI-2 IPV6 relate MO of gNB1.
    ...    3. Expected Results:
    ...         Step a: UE1 Register And PDU Session Setup Successful
    ...         NRADJNRCELL of Pri gNB for Cell2_3 and Cell2_12 support PLMN1, NRCELL of Ext gNB Cell2_3 and Cell2_12 support PLMN1
    ...         Blind Add Cell2_3 and Cell2_12 as Scell, UE1 Traffic And Throughput is OK
    ...         Step b: UE4 Register And PDU Session Setup Successful
    ...         NRADJNRCELL of Pri gNB for Cell2_4, Cell2_11 and Cell2_12 support PLMN2, NRCELL of Ext gNB Cell2_4 and Cell2_11 support PLMN2
    ...         Blind Add Cell2_4 and Cell2_11 as Scell, UE4 Traffic And Throughput is OK
    ...         Step c: since ext-gnb already support ipv6, then add ipv6 in prime-gnb for slice-1 and slice-2 successful
    ...         Step d: UE3 Register And PDU Session Setup Successful
    ...         NRADJNRCELL of Pri gNB for Cell2_3 and Cell2_12 support PLMN1, NRCELL of Ext gNB Cell2_3 and Cell2_12 support PLMN1
    ...         Blind Add Cell2_3 and Cell2_12 as Scell, UE3 Traffic And Throughput is OK
    ...         Step e: UE5 Register And PDU Session Setup Successful
    ...         NRADJNRCELL of Pri gNB for Cell2_4, Cell2_11 and Cell2_12 support PLMN2, NRCELL of Ext gNB Cell2_4 and Cell2_11 support PLMN2
    ...         Blind Add Cell2_4 and Cell2_11 as Scell, UE5 Traffic And Throughput is OK
    ...         Step f: Modify SNSSAI-1 IPV4 link successful
    ...         UE1 bulk release
    ...         Step g: remove SNSSAI-1 IPV6 config successful
    ...         UE3 bulk release
    ...         Step h: Modify SNSSAI-2 IPV4 link successful
    ...         UE4 bulk release
    ...         Step i: delete SNSSAI-2 IPV6 relate MO successful
    ...         UE5 bulk release

    [Tags]    QC_282685    L031
    UE1 Register And PDU Session Setup With Blind 2 Scell Addition and set ueID    #ue_id=1    nwslice=1    gateway=1
    UE4 Register And PDU Session Setup With Blind 2 Scell Addition and set ueID    #ue_id=4    nwslice=2    gateway=4
    OnlineParamChange    ${OnlineParam_add_slice_IPV6}
    UE3 Register And PDU Session Setup With Blind 2 Scell Addition and set ueID    #ue_id=3    nwslice=1    gateway=3
    UE5 Register And PDU Session Setup With Blind 2 Scell Addition and set ueID    #ue_id=5    nwslice=2    gateway=5
    OnlineParamChange for slices of gNB1
    Check WireShark Log    ${CURDIR}${/}A2A_L_031${/}a2a.ini    wait_string=UEContextRelease::0
    [Teardown]    L031 TestTeardown

CB008140-ET-L032_online_modification_parameter_under_MOC_NRDU_xgUplane_in_extGNB
    [Documentation]
    ...    This user scenario verifies gNB behavior to support online modification of NDRU parameters in ext-gNB.
    ...    [Configuration]:
    ...    Cell id=1 gnb=2 pci=16:2 tac=200 tdd_cell=on band=n77 nr_arfcn=663400:663400 gscn=8159 chBw=100MHz Cellid=0x4001
    ...    Cell id=2 gnb=2 pci=17:0 tac=200 tdd_cell=on band=n77 nr_arfcn=658000:658000 gscn=8103 chBw=40MHz
    ...    Cell id=3 gnb=3 pci=17:1 tac=200 tdd_cell=on band=n77 nr_arfcn=653400:653400 gscn=8072 chBw=100MHz SCellWeight=50 Cellid=0x8003/32771
    ...    Cell id=4 gnb=3 pci=17:2 tac=200 tdd_cell=on band=n77 nr_arfcn=648000:648000 gscn=8000 chBw=40MHz SCellWeight=50 Cellid=0x8004/32772
    ...    Cell id=11 gnb=3 pci=20:0 tac=200 tdd_cell=off band=n3 nr_arfcn=349400:368400 gscn=4605 chBw=10MHz SCellWeight=50 Cellid=0x800b/32779
    ...    Cell id=12 gnb=3 pci=20:1 tac=200 tdd_cell=off band=n28 nr_arfcn=143400:153400 gscn=1916 chBw=10MHz SCellWeight=60 Cellid=0x800c/32780
    ...    2.Test Case Steps:
    ...    OnlineParamChange ${OnlineParam_modify_L032_gNB1}: delete xgUplane MO under prime-gnb SNSSAI-1 SNSSAI-2
    ...    OnlineParamChange GNB2 ${OnlineParam_modify_L032_gNB2}: delete xgUplane MO under ext-gnb SNSSAI-1 SNSSAI-2 SNSSAI-3
    ...    there only have IPV4 config at NRBTS-1/NRDU-1 MO of prime-gnb
    ...         a. UE1 with PLMN1(311 489) NRDU-1 Register And PDU Session Setup On Cell1_1 with IPV4, Start Traffic
    ...         b. UE4 with PLMN2(311 402) NRDU-1 Register And PDU Session Setup On Cell1_1 with IPV4, Start Traffic
    ...         c. Add IPV6 config for all xguplane at NRDU-1 of gNB1
    ...         d. UE3 with PLMN1(311 489) NRDU-1 Register And PDU Session Setup On Cell1_1 with IPV6, Start Traffic
    ...         e. UE5 with PLMN2(311 402) NRDU-1 Register And PDU Session Setup On Cell1_1 with IPV6, Start Traffic
    ...         f. remove NRDU-1 PLMN1(311 489) relate IPV6 address on gNB2.
    ...         g. modify NRDU-1 PLMN1(311 489) relate IPV4 config of gNB2 from IPN4-1 to IPN4-4.
    ...         h. Modify NRDU-1 PLMN2(311 402) to PLMN4.

    ...    3. Expected Results:
    ...         Step a: UE1 Register And PDU Session Setup Successful
    ...         NRADJNRCELL of Pri gNB for Cell2_3 and Cell2_12 support PLMN1, NRCELL of Ext gNB Cell2_3 and Cell2_12 support PLMN1
    ...         Blind Add Cell2_3 and Cell2_12 as Scell, UE1 Traffic And Throughput is OK
    ...         Step b: UE4 Register And PDU Session Setup Successful
    ...         NRADJNRCELL of Pri gNB for Cell2_4, Cell2_11 and Cell2_12 support PLMN2, NRCELL of Ext gNB Cell2_4 and Cell2_11 support PLMN2
    ...         Blind Add Cell2_4 and Cell2_11 as Scell, UE4 Traffic And Throughput is OK
    ...         Step c: AAdd IPV6 config for all xguplane at NRDU-1 of gNB1 successful
    ...         Step d: UE3 Register And PDU Session Setup Successful
    ...         NRADJNRCELL of Pri gNB for Cell2_3 and Cell2_12 support PLMN1, NRCELL of Ext gNB Cell2_3 and Cell2_12 support PLMN1
    ...         Blind Add Cell2_3 and Cell2_12 as Scell, UE3 Traffic And Throughput is OK
    ...         Step e: UE5 Register And PDU Session Setup Successful
    ...         NRADJNRCELL of Pri gNB for Cell2_4, Cell2_11 and Cell2_12 support PLMN2, NRCELL of Ext gNB Cell2_4 and Cell2_11 support PLMN2
    ...         Blind Add Cell2_4 and Cell2_11 as Scell, UE5 Traffic And Throughput is OK
    ...         Step f: remove NRDU-1 PLMN1(311 489) relate IPV6 address on gNB2 successful
    ...         UE1 bulk release
    ...         Step g: modify NRDU-1 PLMN1(311 489) relate IPV4 config of gNB2 from IPN4-1 to IPN4-4 successful
    ...         UE3 bulk release
    ...         Step h: Modify NRDU-1 PLMN2 to PLMN4 successful
    ...         UE4 and UE5 all bulk release

    [Tags]    QC_282686    L032
    OnlineParamChange L032
    UE1 Register And PDU Session Setup With Blind 2 Scell Addition and set ueID    #ue_id=1    nwslice=1    gateway=1
    UE4 Register And PDU Session Setup With Blind 2 Scell Addition and set ueID    #ue_id=4    nwslice=2    gateway=4
    OnlineParamChange Add IPV6 for gNB1
    UE3 Register And PDU Session Setup With Blind 2 Scell Addition and set ueID    #ue_id=3    nwslice=1    gateway=3
    UE5 Register And PDU Session Setup With Blind 2 Scell Addition and set ueID    #ue_id=5    nwslice=2    gateway=5
    OnlineParamChange for gNB2
    Check WireShark Log And Counter
    [Teardown]    L032 TestTeardown

CB008140-ET-L035_online_modification_SNSSAI_state_in_priGNB
    [Documentation]
    ...    This user scenario verifies gNB behavior to support online modification of NRBTS/SNSSAI/administrativeState.
    ...    [Configuration]:
    ...    Cell id=1 gnb=2 pci=16:2 tac=200 tdd_cell=on band=n77 nr_arfcn=663400:663400 gscn=8159 chBw=100MHz Cellid=0x4001
    ...    Cell id=2 gnb=2 pci=17:0 tac=200 tdd_cell=on band=n77 nr_arfcn=658000:658000 gscn=8103 chBw=40MHz
    ...    Cell id=3 gnb=3 pci=17:1 tac=200 tdd_cell=on band=n77 nr_arfcn=653400:653400 gscn=8072 chBw=100MHz SCellWeight=50 Cellid=0x8003/32771
    ...    Cell id=4 gnb=3 pci=17:2 tac=200 tdd_cell=on band=n77 nr_arfcn=648000:648000 gscn=8000 chBw=40MHz SCellWeight=50 Cellid=0x8004/32772
    ...    Cell id=11 gnb=3 pci=20:0 tac=200 tdd_cell=off band=n3 nr_arfcn=349400:368400 gscn=4605 chBw=10MHz SCellWeight=50 Cellid=0x800b/32779
    ...    Cell id=12 gnb=3 pci=20:1 tac=200 tdd_cell=off band=n28 nr_arfcn=143400:153400 gscn=1916 chBw=10MHz SCellWeight=60 Cellid=0x800c/32780
    ...    2.Test Case Steps:
    ...         a. UE1 with PLMN1 Slice1 Register And PDU Session Setup On Cell1_1 with IPV4, Start Traffic
    ...         b. UE4 with PLMN2 Slice2 Register And PDU Session Setup On Cell1_1 with IPV4, Start Traffic
    ...         c. Add IPV6 config in prim-gnb for slice1 and slice2,since ext-gnb slice1 and slice2 already has ipv6,next attached UE will use ipv6
    ...         d. UE3 with PLMN1 Slice1 Register And PDU Session Setup On Cell1_1 with IPV6, Start Traffic
    ...         e. UE5 with PLMN2 Slice2 Register And PDU Session Setup On Cell1_1 with IPV6, Start Traffic
    ...         f. lock prime-gnb Slice-2

    ...    3. Expected Results:
    ...         Step a: UE1 Register And PDU Session Setup Successful
    ...         NRADJNRCELL of Pri gNB for Cell2_3 and Cell2_12 support PLMN1, NRCELL of Ext gNB Cell2_3 and Cell2_12 support PLMN1
    ...         Blind Add Cell2_3 and Cell2_12 as Scell, UE1 Traffic And Throughput is OK
    ...         Step b: UE4 Register And PDU Session Setup Successful
    ...         NRADJNRCELL of Pri gNB for Cell2_4, Cell2_11 and Cell2_12 support PLMN2, NRCELL of Ext gNB Cell2_4 and Cell2_11 support PLMN2
    ...         Blind Add Cell2_4 and Cell2_11 as Scell, UE4 Traffic And Throughput is OK
    ...         Step c: Add IPV6 config in prim-gnb for slice1 and slice2 success, next attached UE will use ipv6
    ...         Step d: UE3 Register And PDU Session Setup Successful
    ...         NRADJNRCELL of Pri gNB for Cell2_3 and Cell2_12 support PLMN1, NRCELL of Ext gNB Cell2_3 and Cell2_12 support PLMN1
    ...         Blind Add Cell2_3 and Cell2_12 as Scell, UE3 Traffic And Throughput is OK
    ...         Step e: UE5 Register And PDU Session Setup Successful
    ...         NRADJNRCELL of Pri gNB for Cell2_4, Cell2_11 and Cell2_12 support PLMN2, NRCELL of Ext gNB Cell2_4 and Cell2_11 support PLMN2
    ...         Blind Add Cell2_4 and Cell2_11 as Scell, UE5 Traffic And Throughput is OK
    ...         Step f: Lock Slice2 of gNB1
    ...         UE4 and UE5 bulk release

    [Tags]    QC_282687    L035
    Clear Counter files    True
    UE1 Register And PDU Session Setup With Blind 2 Scell Addition and set ueID    #ue_id=1    nwslice=1    gateway=1
    UE4 Register And PDU Session Setup With Blind 2 Scell Addition and set ueID    #ue_id=4    nwslice=2    gateway=4
    OnlineParamChange    ${OnlineParam_add_slice_IPV6}
    UE3 Register And PDU Session Setup With Blind 2 Scell Addition and set ueID    #ue_id=3    nwslice=1    gateway=3
    UE5 Register And PDU Session Setup With Blind 2 Scell Addition and set ueID    #ue_id=5    nwslice=2    gateway=5
    OnlineParamChange    ${OnlineParam_lock_SNSSAI-2_gNB1}
    Release UEs    ue_type=all
    Check WireShark Log    ${CURDIR}${/}A2A_L_035${/}a2a.ini    wait_string=UEContextRelease::20
    Check Counters    ${PM_Counters_Check_L035}
    [Teardown]    L035 TestTeardown

CB008140-ET-L040_online_modification_NRCELL_in_primarygnb_xnapIGNBCAAdditionrequest
    [Documentation]
    ...    This user scenario verifies gNB behavior to support online modification of slice parameters in prime-gNB.
    ...    [Configuration]:
    ...    Cell id=1 gnb=2 pci=16:2 tac=200 tdd_cell=on band=n77 nr_arfcn=663400:663400 gscn=8159 chBw=100MHz Cellid=0x4001
    ...    Cell id=2 gnb=2 pci=17:0 tac=200 tdd_cell=on band=n77 nr_arfcn=658000:658000 gscn=8103 chBw=40MHz
    ...    Cell id=3 gnb=3 pci=17:1 tac=200 tdd_cell=on band=n77 nr_arfcn=653400:653400 gscn=8072 chBw=100MHz SCellWeight=50 Cellid=0x8003/32771
    ...    Cell id=4 gnb=3 pci=17:2 tac=200 tdd_cell=on band=n77 nr_arfcn=648000:648000 gscn=8000 chBw=40MHz SCellWeight=50 Cellid=0x8004/32772
    ...    Cell id=11 gnb=3 pci=20:0 tac=200 tdd_cell=off band=n3 nr_arfcn=349400:368400 gscn=4605 chBw=10MHz SCellWeight=50 Cellid=0x800b/32779
    ...    Cell id=12 gnb=3 pci=20:1 tac=200 tdd_cell=off band=n28 nr_arfcn=143400:153400 gscn=1916 chBw=10MHz SCellWeight=60 Cellid=0x800c/32780
    ...    2.Test Case Steps:
    ...         a. With precondition configuration for Prim Cell1_1
    ...            actCsiMeasEthFlowControl=CSIMeasBasedAllUe,
    ...            maxDlHarqTx=5,
    ...            maxDlHarqTxDrb=3,
    ...            maxUlHarqTx=5,
    ...            maxUlHarqTxDrb=3,
    ...            allowUnsuppBcOrBcs=accept unknown band combinations,
    ...            actDl256Qam=true,
    ...            actUl256Qam=true
    ...         b. UE1 with PLMN1(311 489) Slice1 Register And PDU Session Setup On Cell1_1 with IPV4, trigger A1 add scell, Start Traffic.
    ...         c. online change parameters
    ...            actCsiMeasEthFlowControl=PastTputBased,
    ...            maxDlHarqTx=6,
    ...            maxDlHarqTxDrb=4,
    ...            maxUlHarqTx=6,
    ...            maxUlHarqTxDrb=4,
    ...            allowUnsuppBcOrBcs=accept unknown BCSs,
    ...            actDl256Qam=false,
    ...            actUl256Qam=false
    ...         d. A2 release Scell, trigger A1 add scell again
    ...         e. UE2 with PLMN1(311 489) Slice1 Register And PDU Session Setup On Cell1_1 with IPV4, trigger A1 add scell, Start Traffic.
    ...         f. online change flag actserviceAwareConfig from disable to enable.
    ...         g. UE3 with PLMN1(311 489) Slice1 Register And PDU Session Setup On Cell1_1 with IPV4, trigger A1 add scell, Start Traffic.
    ...         h. online change parameters
    ...            maxDlHarqTxDrb=7,
    ...            maxUlHarqTxDrb=7,
    ...            allowUnsuppBcOrBcs=accept unknown band combinations and accept unknown BCSs
    ...            actDl256Qam=true,
    ...            actUl256Qam=true
    ...         i. UE3 A2 release Scell, trigger A1 add scell again
    ...         j. UE4 with PLMN1(311 489) Slice1 Register And PDU Session Setup On Cell1_1 with IPV4, trigger A1 add scell, Start Traffic.
    ...         k. Deregister UE.
    ...    3. Expected Results:
    ...         Step a: online change precondition configuration is ok
    ...         Step b: UE1 Register And PDU Session Setup Successful
    ...         NRADJNRCELL of Pri gNB for Cell2_3 and Cell2_12 support PLMN1, NRCELL of Ext gNB Cell2_3 and Cell2_12 support PLMN1
    ...         coverBased Add Cell2_3 and Cell2_12 as Scell, UE1 Traffic And Throughput is OK,
    ...         IE check for UE1:
    ...            actCsiMeasEthFlowControl=CSIMeasBasedAllUe,
    ...            maxDlHarqTransmission=5,
    ...            maxUlHarqTransmission=5,
    ...            allowUnsuppBcOrBcs=accept unknown band combinations,
    ...            actDl256Qam=true,
    ...            actUl256Qam=true
    ...         Step c: online change parameters ok
    ...         Step d: UE1 scell release and scell add again successfully. Check IE about parameters
    ...         IE check for UE1:
    ...            actCsiMeasEthFlowControl=CSIMeasBasedAllUe,
    ...            maxDlHarqTransmission=5,
    ...            maxUlHarqTransmission=5,
    ...            allowUnsuppBcOrBcs=accept unknown BCSs,
    ...            actDl256Qam=true,
    ...            actUl256Qam=true
    ...         Step e: UE2 Register And PDU Session Setup Successful
    ...         NRADJNRCELL of Pri gNB for Cell2_3 and Cell2_12 support PLMN1, NRCELL of Ext gNB Cell2_3 and Cell2_12 support PLMN1
    ...         coverBased Add Cell2_3 and Cell2_12 as Scell, UE2 Traffic And Throughput is OK,
    ...         IE check for UE2:
    ...            actCsiMeasEthFlowControl=PastTputBased,
    ...            maxDlHarqTransmission=6,
    ...            maxUlHarqTransmission=6,
    ...            allowUnsuppBcOrBcs=accept unknown BCSs,
    ...            actDl256Qam=false,
    ...            actUl256Qam=false
    ...         Step f: online change parameters ok
    ...         Step g: UE3 Register And PDU Session Setup Successful
    ...         NRADJNRCELL of Pri gNB for Cell2_3 and Cell2_12 support PLMN1, NRCELL of Ext gNB Cell2_3 and Cell2_12 support PLMN1
    ...         coverBased Add Cell2_3 and Cell2_12 as Scell, UE3 Traffic And Throughput is OK,
    ...         IE check for UE3:
    ...            actCsiMeasEthFlowControl=PastTputBased,
    ...            maxDlHarqTransmission=4,
    ...            maxUlHarqTransmission=4,
    ...            allowUnsuppBcOrBcs=accept unknown BCSs,
    ...            actDl256Qam=false,
    ...            actUl256Qam=false
    ...         Step h: online change parameters ok
    ...         Step i: UE3 scell release and scell add again successfully. Check IE about parameters
    ...         IE check for UE3:
    ...            actCsiMeasEthFlowControl=PastTputBased,
    ...            maxDlHarqTransmission=4,
    ...            maxUlHarqTransmission=4,
    ...            allowUnsuppBcOrBcs=accept unknown band combinations and accept unknown BCSs,
    ...            actDl256Qam=false,
    ...            actUl256Qam=false
    ...         Step j: UE4 Register And PDU Session Setup Successful
    ...         NRADJNRCELL of Pri gNB for Cell2_3 and Cell2_12 support PLMN1, NRCELL of Ext gNB Cell2_3 and Cell2_12 support PLMN1
    ...         coverBased Add Cell2_3 and Cell2_12 as Scell, UE4 Traffic And Throughput is OK,
    ...         IE check for UE4:
    ...            actCsiMeasEthFlowControl=PastTputBased,
    ...            maxDlHarqTransmission=7,
    ...            maxUlHarqTransmission=7,
    ...            allowUnsuppBcOrBcs=accept unknown band combinations and accept unknown BCSs,
    ...            actDl256Qam=true,
    ...            actUl256Qam=true
    [Tags]    QC_285311    L040    owner-jean.jing
    OnlineParamChange    ${OnlineParam_L040_Precondition_GNB1}
    OnlineParamChange GNB2    ${OnlineParam_L040_Precondition_GNB2}
    UE1 Check Params For Exist UE When actserviceAwareConfig Disable
    UE2 Check Params For New UE When actserviceAwareConfig Disable
    OnlineParamChange    ${OnlineParam_Change_ActserviceAwareConfig_Enable_L040_GNB1}
    UE3 Check Params For Exist UE When actserviceAwareConfig Enable
    UE4 Check Params For New UE When actserviceAwareConfig Enable
    Release UEs    ue_type=all
    Check WireShark Log    ${CURDIR}${/}A2A_L_040${/}a2a.ini    wait_string=UEContextRelease::30
    [Teardown]    L040 TestTeardown


*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup 2Airphone Env    fddtdd_sansa_cmwv/6cells_gnb1_2T_gnb2_2T2F

Modify Cfg
    Update Cfg Param    set_gnb id=2 amf=1-6
    Update Cfg Param    set_gnb id=3 amf=1-6
    Update Cfg    set_amf_region id=1 tac_list=0,100,200,300 plmn=311:489
    Update Cfg    set_amf_region id=2 tac_list=0,100,200,300 plmn=311:402
    Update Cfg    set_amf_region id=3 tac_list=0,100,200,300 plmn=311:403
    Update Cfg    set_amf_region id=4 tac_list=0,100,200,300 plmn=311:404
    Update Cfg    set_amf_region id=5 tac_list=0,100,200,300 plmn=311:405
    Update Cfg    set_amf_region id=6 tac_list=0,100,200,300 plmn=311:406
    Update Cfg    set_amf id=1 daemon=10.0.2.1:22222 ng=10.0.1.1:38412 region=1 set_id=1 pointer=1
    Update Cfg    set_amf id=2 daemon=10.0.2.1:22222 ng=10.0.1.102:38412 region=2 set_id=2 pointer=1
    Update Cfg    set_amf id=3 daemon=10.0.2.1:22222 ng=10.0.1.103:38412 region=3 set_id=3 pointer=1
    Update Cfg    set_amf id=4 daemon=10.0.2.1:22222 ng=10.0.1.104:38412 region=4 set_id=4 pointer=1
    Update Cfg    set_amf id=5 daemon=10.0.2.1:22222 ng=10.0.1.105:38412 region=5 set_id=5 pointer=1
    Update Cfg    set_amf id=6 daemon=10.0.2.1:22222 ng=10.0.1.106:38412 region=6 set_id=6 pointer=1
    Update Cfg    amf_param id=1 full_nas_auth=on nia=null+zuc nea=null+zuc
    Update Cfg    amf_param id=2 full_nas_auth=on nia=null+zuc nea=null+zuc
    Update Cfg    amf_param id=3 full_nas_auth=on nia=null+zuc nea=null+zuc
    Update Cfg    amf_param id=4 full_nas_auth=on nia=null+zuc nea=null+zuc
    Update Cfg    amf_param id=5 full_nas_auth=on nia=null+zuc nea=null+zuc
    Update Cfg    amf_param id=6 full_nas_auth=on nia=null+zuc nea=null+zuc
    Update Cfg    set_nwslice id=1 snssai=0x01:0xFFFFFF amf=1-6 default=on ue=all
    Update Cfg    set_nwslice id=2 snssai=0x01:0xd143a5 amf=1-6 default=off ue=all
    Update Cfg    set_nwslice id=3 snssai=0x01:0x000000 amf=1-6 default=off ue=all
    Update Cfg Param    set_ue simulated id=4 suci=0:311:402:0000:0:0:021645403
    Update Cfg Param    set_ue simulated id=5 suci=0:311:402:0000:0:0:021645404

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be Onair    check_sib=${True}

OnlineParamChange GNB2
    [Arguments]    ${Online_Param}
    Delta Commission Parameters GNB2    ${Online_Param}
    Cells Should Be Onair    check_sib=${True}

OnlineParamChange for slices of gNB1
    OnlineParamChange    ${OnlineParam_modify_SNSSAI-1_IPV4_gNB1}
    OnlineParamChange    ${OnlineParam_remove_SNSSAI-1_IPV6_gNB1}
    OnlineParamChange    ${OnlineParam_modify_SNSSAI-2_IPV4_gNB1}
    OnlineParamChange    ${OnlineParam_remove_SNSSAI-2_IPV6_gNB1}

OnlineParamChange for gNB2
    OnlineParamChange GNB2    ${OnlineParam_remove_NRDU-1_PLMN-1_IPV6_gNB2}
    OnlineParamChange GNB2    ${OnlineParam_modify_NRDU-1_PLMN-1_IPV4_gNB2}
    OnlineParamChange GNB2    ${OnlineParam_modify_NRDU-1_PLMN-2_gNB2}

OnlineParamChange Add IPV6 for gNB1
    OnlineParamChange    ${OnlineParam_add_NRDU_IPV6}

OnlineParamChange L032
    Clear Counter files    True
    Clear Counter files Gnb2    True
    OnlineParamChange    ${OnlineParam_modify_L032_gNB1}
    OnlineParamChange GNB2    ${OnlineParam_modify_L032_gNB2}

UE1 Register And PDU Session Setup With Blind 2 Scell Addition and set ueID
    ${RAN_UE_NGAP_ID_1}    UE1 Register And PDU Session Setup With Blind 2 Scell Addition    ue_id=1    nwslice=1    gateway=1
    Set Test Variable    \${RAN_UE_NGAP_ID_1}

UE1 Register And PDU Session Setup With Blind 2 Scell Addition
    [Arguments]    ${ue_id}=1    ${nwslice}=1    ${gateway}=1    ${enb_id}=2    ${cell_id}=1
    [Return]    ${RAN_UE_NGAP_ID_1[0]}
    Execute Egate Command    ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    ${output}    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=${nwslice} gw=${gateway}    pass_regexp=${UE1_expect}
    ...    fail_regexp=${unexpect}    timeout=20s
    ${RAN_UE_NGAP_ID_1}    Get Regexp Matches    ${output}    RAN_UE_NGAP_ID\=(\\d+)    1
    Run Traffic And Verify Throughput    ue_id=${ue_id}

UE3 Register And PDU Session Setup With Blind 2 Scell Addition and set ueID
    ${RAN_UE_NGAP_ID_3}    UE3 Register And PDU Session Setup With Blind 2 Scell Addition    ue_id=3    nwslice=1    gateway=3
    Set Test Variable    \${RAN_UE_NGAP_ID_3}

UE3 Register And PDU Session Setup With Blind 2 Scell Addition
    [Arguments]    ${ue_id}=1    ${nwslice}=1    ${gateway}=1    ${enb_id}=2    ${cell_id}=1
    [Return]    ${RAN_UE_NGAP_ID_3[0]}
    Execute Egate Command    ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    ${output}    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=${nwslice} gw=${gateway}    pass_regexp=${UE1_expect}
    ...    fail_regexp=${unexpect}    timeout=20s
    ${RAN_UE_NGAP_ID_3}    Get Regexp Matches    ${output}    RAN_UE_NGAP_ID\=(\\d+)    1
    Run Traffic And Verify Throughput    ue_id=${ue_id}

UE4 Register And PDU Session Setup With Blind 2 Scell Addition and set ueID
    ${RAN_UE_NGAP_ID_4}    UE4 Register And PDU Session Setup With Blind 2 Scell Addition    ue_id=4    nwslice=2    gateway=4
    Set Test Variable    \${RAN_UE_NGAP_ID_4}

UE4 Register And PDU Session Setup With Blind 2 Scell Addition
    [Arguments]    ${ue_id}=1    ${nwslice}=1    ${gateway}=1    ${enb_id}=2    ${cell_id}=1
    [Return]    ${RAN_UE_NGAP_ID_4[0]}
    Execute Egate Command    ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    ${output}    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=${nwslice} gw=${gateway}    pass_regexp=${UE2_expect}
    ...    fail_regexp=${unexpect}    timeout=20s
    ${RAN_UE_NGAP_ID_4}    Get Regexp Matches    ${output}    RAN_UE_NGAP_ID\=(\\d+)    1
    Run Large Traffic And Verify Throughput    ue_id=${ue_id}

UE5 Register And PDU Session Setup With Blind 2 Scell Addition and set ueID
    ${RAN_UE_NGAP_ID_5}    UE5 Register And PDU Session Setup With Blind 2 Scell Addition    ue_id=5    nwslice=2    gateway=5
    Set Test Variable    \${RAN_UE_NGAP_ID_5}

UE5 Register And PDU Session Setup With Blind 2 Scell Addition
    [Arguments]    ${ue_id}=1    ${nwslice}=1    ${gateway}=1    ${enb_id}=2    ${cell_id}=1
    [Return]    ${RAN_UE_NGAP_ID_5[0]}
    Execute Egate Command    ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    ${output}    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=${nwslice} gw=${gateway}    pass_regexp=${UE2_expect}
    ...    fail_regexp=${unexpect}    timeout=20s
    ${RAN_UE_NGAP_ID_5}    Get Regexp Matches    ${output}    RAN_UE_NGAP_ID\=(\\d+)    1
    Run Large Traffic And Verify Throughput    ue_id=${ue_id}

Run Traffic And Verify Throughput
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${qfi}=1
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} trf_id=1 protocol=tcp mbps=150 dir=dl
    ...    pass_regexp=Started Downlink Internal traffic over TCP on Ue
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} trf_id=1 protocol=tcp mbps=50 dir=ul
    ...    pass_regexp=Started Uplink Internal traffic over TCP on Ue
    Verify Throughput    ${ue_id}    ${pdu}    ${qfi}    135    45

Verify Throughput
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${qfi}=1    ${Tput_dl}=10    ${Tput_ul}=1    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    direction=ul    rate_type=ave
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pdsch    Throughput
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

Run Large Traffic And Verify Throughput
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${qfi}=1
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} trf_id=1 protocol=tcp mbps=150 dir=dl
    ...    pass_regexp=Started Downlink Internal traffic over TCP on Ue
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} trf_id=2 protocol=tcp mbps=150 dir=dl
    ...    pass_regexp=Started Downlink Internal traffic over TCP on Ue
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} trf_id=1 protocol=tcp mbps=50 dir=ul
    ...    pass_regexp=Started Uplink Internal traffic over TCP on Ue
    Verify Large Throughput    ${ue_id}    ${pdu}    ${qfi}    270    45


Verify Large Throughput
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${qfi}=1    ${Tput_dl}=10    ${Tput_ul}=1    ${sleep_time}=30s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    direction=ul    rate_type=ave
    ${ret0}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-5 type=pdsch    pass_regexp=Average
    ${scell0_tput}    Ap Get Throuput On Specific Scell     ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000 > 10
    ${scell1_tput}    Ap Get Throuput On Specific Scell     ue_id=${ue_id}    scell_id=1    type=pdsch    rate_type=ave
    #Should Be True    ${scell1_tput}/1000 > 0
	${scell2_tput}    Ap Get Throuput On Specific Scell     ue_id=${ue_id}    scell_id=2    type=pdsch    rate_type=ave
    #Should Be True    ${scell2_tput}/1000 > 0
    Should Be True    ${scell0_tput}/1000+${scell1_tput}/1000+${scell2_tput}/1000 > ${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}
    Should Be True    ${dl_throughput}/1000>${Tput_dl}

L031 TestTeardown
    OnlineParamChange    ${OnlineParam_recover_gNB1}
    Common Test Teardown And Stop Capture Logs

L032 TestTeardown
    OnlineParamChange    ${OnlineParam_recover_gNB1}
    OnlineParamChange GNB2    ${OnlineParam_recover_gNB2}
    Common Test Teardown And Stop Capture Logs

L035 TestTeardown
    OnlineParamChange    ${OnlineParam_Unlock_SNSSAI-2_gNB1}
    Common Test Teardown And Stop Capture Logs

Check WireShark Log And Counter
    Check WireShark Log    ${CURDIR}${/}A2A_L_032${/}a2a.ini    wait_string=UEContextRelease::0
    Check Counters    ${PM_Counters_Check_GNB1}
    Check Counters GNB2    ${PM_Counters_Check_GNB2}

UE1 Check Params For Exist UE When actserviceAwareConfig Disable
    ${RAN_UE_NGAP_ID_1}    UE Register And PDU Session Setup With covBasedA1 2 Scell Addition    ue_id=1    nwslice=1    gateway=1
    Set Test Variable     ${RAN_UE_NGAP_ID_1}
    OnlineParamChange    ${OnlineParam_Change_ActserviceAwareConfig_Disable_L040_GNB1}
    UE trigger A2 to release scell
    UE trigger A1 MR to add scell

UE2 Check Params For New UE When actserviceAwareConfig Disable
    ${RAN_UE_NGAP_ID_2}    UE Register And PDU Session Setup With covBasedA1 2 Scell Addition    ue_id=1    nwslice=1    gateway=1
    Set Test Variable     ${RAN_UE_NGAP_ID_2}

UE3 Check Params For Exist UE When actserviceAwareConfig Enable
    ${RAN_UE_NGAP_ID_3}    UE Register And PDU Session Setup With covBasedA1 2 Scell Addition    ue_id=1    nwslice=1    gateway=1
    Set Test Variable    ${RAN_UE_NGAP_ID_3}
    UE trigger A2 to release scell
    OnlineParamChange    ${OnlineParam_Change_After_ActserviceAwareConfig_Enable_L040_GNB1}
    UE trigger A1 MR to add scell

UE4 Check Params For New UE When actserviceAwareConfig Enable
    ${RAN_UE_NGAP_ID_4}    UE Register And PDU Session Setup With covBasedA1 2 Scell Addition    ue_id=1    nwslice=1    gateway=1
    Set Test Variable    ${RAN_UE_NGAP_ID_4}

UE trigger A1 MR to add scell
    trigger A1 MR to add scell    rsrp=110    ue_id=1    ssbfreq=663360

trigger A1 MR to add scell
    [Arguments]    ${rsrp}=110    ${ue_id}=1    ${ssbfreq}=663360
    ${meas_id}    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=${ssbfreq}    event_type=A1
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrq_nr=70 srsrp_nr=${rsrp}
    ...    pass_regexp=${UE1_expect}    fail_regexp=${unexpect}    timeout=20s
    Run Large Traffic And Verify Throughput L040    ue_id=${ue_id}

UE Register And PDU Session Setup With covBasedA1 2 Scell Addition
    [Arguments]    ${ue_id}=1    ${nwslice}=1    ${gateway}=1    ${enb_id}=2    ${cell_id}=1
    [Return]    ${RAN_UE_NGAP_ID_1[0]}
    Release UEs    ue_type=all
    Execute Egate Command    ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    ${output}    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=${nwslice} gw=${gateway}
    ...    pass_regexp=QoS Routing Table    timeout=20s
    ${RAN_UE_NGAP_ID_1}    Get Regexp Matches    ${output}    RAN_UE_NGAP_ID\=(\\d+)    1
    trigger A1 MR to add scell

UE trigger A2 to release scell
    get scell A2 measid and trigger A2 to release cell    carrierfreq=655008    id=1
    get scell A2 measid and trigger A2 to release cell    carrierfreq=153370    id=2

get scell A2 measid and trigger A2 to release cell
    [Arguments]    ${carrierfreq}=648096    ${id}=1
    ${meas_id_scell}    get_nr_meas_id_for_specific_type_and_frequency    ue_id=1    carrierfreq=${carrierfreq}    event_type=A2
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=1 meas_id=${meas_id_scell} event=A2 scell=${id} scell_rsrp=20 scell_rsrq=20
    ...    pass_regexp=rrcReconfigurationComplete
    Should Contain    ${ret1}    sCellToReleaseList

Run Large Traffic And Verify Throughput L040
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${qfi}=1
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} trf_id=1 protocol=tcp mbps=150 dir=dl
    ...    pass_regexp=Started Downlink Internal traffic over TCP on Ue
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} trf_id=2 protocol=tcp mbps=150 dir=dl
    ...    pass_regexp=Started Downlink Internal traffic over TCP on Ue
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} trf_id=3 protocol=tcp mbps=150 dir=dl
    ...    pass_regexp=Started Downlink Internal traffic over TCP on Ue
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} trf_id=4 protocol=tcp mbps=150 dir=dl
    ...    pass_regexp=Started Downlink Internal traffic over TCP on Ue
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} trf_id=1 protocol=tcp mbps=50 dir=ul
    ...    pass_regexp=Started Uplink Internal traffic over TCP on Ue
    Verify Large Throughput    ${ue_id}    ${pdu}    ${qfi}    540    45

L040 TestTeardown
    OnlineParamChange    ${OnlineParam_cover_L040_gNB1}
    OnlineParamChange GNB2    ${OnlineParam_cover_L040_gNB2}
    Common Test Teardown And Stop Capture Logs
