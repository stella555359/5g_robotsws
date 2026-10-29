*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CLOUD_5G_I_[LO][LO]_AP_[LOO]    team-L3CN1_SG14
...    owner-jun.15.zhang    release-SBTS23R3    CRT
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
...    NRDU-1:xgUplane:ipV6AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-1|nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRDU-1:xgUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-2|nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-2
...    NRDU-1:xgUplane:ipV6AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-2|nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-2
...    NRDU-1:xgUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-3|nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-3
...    NRDU-1:xgUplane:ipV6AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-3|nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-3
...    NRBTS/TRACKINGAREA-200:fiveGsTac=200
...    TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-1|snssaiDN=SNSSAI-1
...    TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-2|snssaiDN=SNSSAI-2
...    NRBTS/TRACKINGAREA-300:fiveGsTac=300
...    TRACKINGAREA-300:snssaiList:snssaiDN=SNSSAI-1|snssaiDN=SNSSAI-1
...    TRACKINGAREA-300:snssaiList:snssaiDN=SNSSAI-2|snssaiDN=SNSSAI-2
...    TRACKINGAREA-300:snssaiList:snssaiDN=SNSSAI-3|snssaiDN=SNSSAI-3
...    delete:NRCELL:trackingAreaDN
...    delete:NRCELL:configuredEpsTac
...    NRCELL/NRPLMNSET_SA-1:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-200
...    NRCELL/NRPLMNSET_SA-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
#  PLMN-1 + TRACKINGAREA-200:SNSSAI-1/SNSSAI-2==>PLMN-1 + SNSSAI-1/SNSSAI-2
...    NRCELL/NRPLMNSET_SA-2:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-300
...    NRCELL/NRPLMNSET_SA-2:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-2,MRBTS-1/NRBTS-1/NRPLMN-3
#  PLMN-2 + TRACKINGAREA-300:SNSSAI-1/SNSSAI-2/SNSSAI-3==>PLMN-2 + SNSSAI-1/SNSSAI-2/SNSSAI-3
#  PLMN-3 + TRACKINGAREA-300:SNSSAI-1/SNSSAI-2/SNSSAI-3==>PLMN-3 + SNSSAI-3
...    NRCELL/NRPLMNSET_NSA-1:configuredEpsTac=222
...    NRCELL/NRPLMNSET_NSA-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1,MRBTS-1/NRBTS-1/NRPLMN-2
...    NRBTS/SNSSAI-1:administrativeState=Unlocked
...    NRBTS/SNSSAI-1:sst=1
...    delete:NRBTS/SNSSAI-1:sd
...    NRBTS/SNSSAI-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1,MRBTS-1/NRBTS-1/NRPLMN-2
...    NRBTS/SNSSAI-1:xgUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-4
...    NRBTS/SNSSAI-1:xgUplane:ipV6AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-4
...    NRBTS/SNSSAI-2:administrativeState=Unlocked
...    NRBTS/SNSSAI-2:sst=1
...    NRBTS/SNSSAI-2:sd=13714341
...    NRBTS/SNSSAI-2:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1,MRBTS-1/NRBTS-1/NRPLMN-2
...    NRBTS/SNSSAI-2:xgUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-5
...    NRBTS/SNSSAI-2:xgUplane:ipV6AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-5
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
...    TRACKINGAREA-100:snssaiList:snssaiDN=SNSSAI-1|snssaiDN=SNSSAI-1
...    TRACKINGAREA-100:snssaiList:snssaiDN=SNSSAI-2|snssaiDN=SNSSAI-2
...    NRBTS/TRACKINGAREA-200:fiveGsTac=200
...    TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-1|snssaiDN=SNSSAI-1
...    TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-2|snssaiDN=SNSSAI-2
...    TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-3|snssaiDN=SNSSAI-3
...    delete:NRCELL:trackingAreaDN
...    delete:NRCELL:configuredEpsTac
...    NRCELL/NRPLMNSET_SA-1:trackingAreaDN=MRBTS-2/NRBTS-2/TRACKINGAREA-100
...    NRCELL/NRPLMNSET_SA-1:nrPlmnDNList=MRBTS-2/NRBTS-2/NRPLMN-1
#  PLMN-1 + TRACKINGAREA-100:SNSSAI-1/SNSSAI-2==>PLMN-1 + SNSSAI-1/SNSSAI-2
...    NRCELL/NRPLMNSET_NSA-1:configuredEpsTac=222
...    NRCELL/NRPLMNSET_NSA-1:nrPlmnDNList=MRBTS-2/NRBTS-2/NRPLMN-1,MRBTS-2/NRBTS-2/NRPLMN-2
...    NRCELL-3/NRPLMNSET_SA-2:trackingAreaDN=MRBTS-2/NRBTS-2/TRACKINGAREA-200
...    NRCELL-3/NRPLMNSET_SA-2:nrPlmnDNList=MRBTS-2/NRBTS-2/NRPLMN-2,MRBTS-2/NRBTS-2/NRPLMN-4
...    NRCELL-4/NRPLMNSET_SA-2:trackingAreaDN=MRBTS-2/NRBTS-2/TRACKINGAREA-200
...    NRCELL-4/NRPLMNSET_SA-2:nrPlmnDNList=MRBTS-2/NRBTS-2/NRPLMN-2,MRBTS-2/NRBTS-2/NRPLMN-4
...    NRCELL-11/NRPLMNSET_SA-2:trackingAreaDN=MRBTS-2/NRBTS-2/TRACKINGAREA-200
...    NRCELL-11/NRPLMNSET_SA-2:nrPlmnDNList=MRBTS-2/NRBTS-2/NRPLMN-2,MRBTS-2/NRBTS-2/NRPLMN-4
#  PLMN-2 + TRACKINGAREA-200:SNSSAI-1/SNSSAI-2/SNSSAI-3==>PLMN-2 + SNSSAI-1/SNSSAI-2/SNSSAI-3
#  PLMN-4 + TRACKINGAREA-200:SNSSAI-1/SNSSAI-2/SNSSAI-3==>PLMN-4 + SNSSAI-3
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

#SA UE support CA_n3A-n77(3A), CA_n28A-n77(3A), CA_n3A-n28-n77(2A)
${SA_Capa_Support_CA_n3_n28_n77_n77_n77}    SEPARATOR=
...    E9A09000575F5A13160003C4A0002C1262E003387A16009B20C39F30C7942C0E0980C0311C04EE3603606B04610D04083A41E006D6C98AB1A1CF88E3D033EC09F1891C790E7D
...    473E618F28581C0E1E0B801FF800E000BE000C80000E0541B00B582308682041E20F0032B64C55890E7D813E238F1891C790E7D473E618F28581C0E1E13FB000000FEC000000
...    C80000E0551B133582308682041D20F0030B64C55110E7C471E238F40CFB027C639F30C7942C0E070F05C00FFC007003FF000640000702A0D837AC1184341020F10780195B26
...    2AC4873E238F604F8C48E3C873EA39F30C7942C0E070F09FFF000007FFC00000640000703B8D851FFAC1184341020E907801B5B262AC6873E238F40CFB027C62471E439F51CF
...    9863CA1607038782F557FF553D55FFD5432000038024B0F1300038980000002C0AC5C4C000E26000713000000858158B80400184C0309800020B02B1E0080C0D81C4C000C260
...    000C2C0AC5C02000C010181B0002058158F8040018060303606134000A160562E01000606C0C26000182C0AC3C02000C260001C2C0AC3C02000C01000202C0AC3C1B000C0D80
...    0242C0AC3C02000C03000282C0AC3C06000C0D8002C2C0AC5C02000C030181B0006058158F836001C4C000C260184C0006858158B89800184C03004000E0B02B1E0080E26000
...    61300C260003C2C0AC5C4C000C010181B0008058158F89A0018020300C0606C0022160402401B800D01320014028194007484A14489B1CF871224489B1CF871224489B1CF871
...    A2448913639F0E2448913639F0E344891226C73E1C4891226C73E1C28913639F0E14489B1CF870A244D8E7C3851226C73E1C28913639F0E2448913639F0E14489B1CF8712244
...    89B1CF871A2448913639F0E2448913639F0E344891226C73E180D890C6318C6318C6318C6318C60F41B000F000A070500703009401C0018090010180F8240080000000400200
...    0000080000300400000802000008010000060080000400400002802001004010040000300200001C010008000000200002001000012008000030040000500200002C01000812
...    048020000300CE54D654D60A5606560CD60AD652DE4CDE02D606D6025604560ED0341000009652504000065949810000196524040000E5949010000496524040001659498100
...    00696524040001E594901000089652404000265949010000A96524040002E5949410000C96524040000C594900CD2AABA55554AA2E95455058AA0B1541A2A94C55268AA03154
...    0A2A93555078A1A00BC04A8140A05028140A05028140A05028140A05028140A0022101002004040080110080100202004008080100220100C014040080101002004602018028
...    080600A02004008080100220101001404040050101602C602018030080600A02018030080100220100C014040300501002004202018028080100210100C01404030050808060
...    0C02018030404030060100C014202018028080600A20100C01404030060100C014602018030080100202004008080100220100200404008010100C01460201802808010020200
...    4008080100220100200404030060100C018602004008080600A02018030080600A3543E00020406080C0E1416181A2022242628303236383A3E424A4C4E5052545A5E828305A0

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

*** Test Cases ***
CB008140-ET-GG015_ext-SCell_partial_addition_due_to_unsupported_PLMN_Id_in_candidate_ext-SCells_with_RAN_sharing_both_in_prime_and_external_gNB
    [Documentation]
    ...    The successful blind inter-gNB CA SCell addition for SA UE with partial ext-SCell unsupported PLMN_Id.
    ...    [Configuration]:
    ...    Cell id=1  gnb=2 pci=16:2 tac=200 tdd_cell=on  band=n77 nr_arfcn=663400:663400 gscn=8159 chBw=100MHz Cellid=0x4001
    ...    Cell id=2  gnb=2 pci=17:0 tac=200 tdd_cell=on  band=n77 nr_arfcn=658000:658000 gscn=8103 chBw=40MHz
    ...    Cell id=3  gnb=3 pci=17:1 tac=200 tdd_cell=on  band=n77 nr_arfcn=653400:653400 gscn=8072 chBw=100MHz SCellWeight=50 Cellid=0x8003/32771
    ...    Cell id=4  gnb=3 pci=17:2 tac=200 tdd_cell=on  band=n77 nr_arfcn=648000:648000 gscn=8000 chBw=40MHz  SCellWeight=50 Cellid=0x8004/32772
    ...    Cell id=11 gnb=3 pci=20:0 tac=200 tdd_cell=off band=n3  nr_arfcn=349400:368400 gscn=4605 chBw=10MHz  SCellWeight=50 Cellid=0x800b/32779
    ...    Cell id=12 gnb=3 pci=20:1 tac=200 tdd_cell=off band=n28 nr_arfcn=143400:153400 gscn=1916 chBw=10MHz  SCellWeight=50 Cellid=0x800c/32780
    ...    2.Test Case Steps:
    ...         a. UE1 with PLMN1 Slice1 Register And PDU Session Setup On Cell1_1
    ...         b. UE1 Start Traffic And Verify Throughput
    ...         c. UE2 with PLMN2 Slice2 Register And PDU Session Setup On Cell1_1
    ...         d. UE2 Start Traffic And Verify Throughput
    ...    3. Expected Results:
    ...         Step a: UE1 Register And PDU Session Setup Successful
    ...         NRADJNRCELL of Pri gNB for Cell2_3 and Cell2_12 support PLMN1, NRCELL of Ext gNB Cell2_3 and Cell2_12 support PLMN1
    ...         Blind Add Cell2_3 and Cell2_12 as Scell
    ...         Step b: UE1 Traffic And Throughput is OK
    ...         Step c: UE2 Register And PDU Session Setup Successful
    ...         NRADJNRCELL of Pri gNB for Cell2_4, Cell2_11 and Cell2_12 support PLMN2, NRCELL of Ext gNB Cell2_4 and Cell2_11 support PLMN2
    ...         Blind Add Cell2_4 and Cell2_11 as Scell
    ...         Step d: UE2 Traffic And Throughput is OK
    [Tags]    QC_272670    GG015
    UE1 Register And PDU Session Setup With Blind 2 Scell Addition    ue_id=1    nwslice=1    gateway=1
    Run Traffic And Verify Throughput
    UE2 Register And PDU Session Setup With Blind 2 Scell Addition    ue_id=2    nwslice=2    gateway=2
    Run Traffic And Verify Throughput    ue_id=2
    Release UEs    ue_type=all

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
    Update Cfg    ue_param id=1 ue_nr_capabilities=${SA_Capa_Support_CA_n3_n28_n77_n77_n77}
    Update Cfg Param    set_ue simulated id=2 suci=0:311:402:0000:0:0:021645401
    Update Cfg    ue_param id=2 ue_nr_capabilities=${SA_Capa_Support_CA_n3_n28_n77_n77_n77}

UE1 Register And PDU Session Setup With Blind 2 Scell Addition
    [Arguments]    ${ue_id}=1    ${nwslice}=1    ${gateway}=1    ${enb_id}=2    ${cell_id}=1
    Execute Egate Command    ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=${nwslice} gw=${gateway}    pass_regexp=${UE1_expect}
    ...    fail_regexp=sCellIndex3    timeout=20s

UE2 Register And PDU Session Setup With Blind 2 Scell Addition
    [Arguments]    ${ue_id}=1    ${nwslice}=1    ${gateway}=1    ${enb_id}=2    ${cell_id}=1
    Execute Egate Command    ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=${nwslice} gw=${gateway}    pass_regexp=${UE2_expect}
    ...    fail_regexp=sCellIndex3    timeout=20s

Run Traffic And Verify Throughput
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${qfi}=1
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} trf_id=1 protocol=tcp mbps=150 dir=dl
    ...    pass_regexp=Started Downlink Internal traffic over TCP on Ue
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} trf_id=2 protocol=tcp mbps=150 dir=dl
    ...    pass_regexp=Started Downlink Internal traffic over TCP on Ue
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} trf_id=3 protocol=tcp mbps=150 dir=dl
    ...    pass_regexp=Started Downlink Internal traffic over TCP on Ue
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} trf_id=4 protocol=tcp mbps=150 dir=dl
    ...    pass_regexp=Started Downlink Internal traffic over TCP on Ue    sleep_time=2
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} trf_id=1 protocol=tcp mbps=50 dir=ul
    ...    pass_regexp=Started Uplink Internal traffic over TCP on Ue
    Verify Throughput    ${ue_id}    ${pdu}    ${qfi}    540    45
    [teardown]    Stop Traffic    ${ue_id}    ${pdu}

Stop Traffic
    [Arguments]    ${ue_id}=1    ${pdu}=1
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=${pdu} dir=dl trf_id=1    pass_regexp=Stopped Downlink Internal traffic on Ue
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=${pdu} dir=dl trf_id=2    pass_regexp=Stopped Downlink Internal traffic on Ue
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=${pdu} dir=dl trf_id=3    pass_regexp=Stopped Downlink Internal traffic on Ue
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=${pdu} dir=dl trf_id=4    pass_regexp=Stopped Downlink Internal traffic on Ue
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=${pdu} dir=ul trf_id=1    pass_regexp=Stopping Uplink Internal traffic on Ue

Verify Throughput
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${qfi}=1    ${Tput_dl}=10    ${Tput_ul}=10    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    direction=ul    rate_type=ave
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pdsch    Throughput
    Should Not Match Regexp    ${scell_tput}    CellIndex-[0-3] *0 *0 *0 *0
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}
