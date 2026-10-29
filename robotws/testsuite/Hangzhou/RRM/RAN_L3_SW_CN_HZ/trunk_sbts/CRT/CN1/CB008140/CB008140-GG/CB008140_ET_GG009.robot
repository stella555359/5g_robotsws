*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CLOUD_5G_I_[LO][LO]_AP_[LOO]    team-L3CN1_SG14
...    owner-alex.2.wang    release-SBTS23R3    CRT
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
...    NRBTS/NRADJNRCELL-1:fiveGsTac=100
...    NRBTS/NRADJNRCELL-1:freqBandIndicatorNR=77
...    NRBTS/NRADJNRCELL-1:gNbId=2
...    NRBTS/NRADJNRCELL-1:gNbIdLength=22
...    NRBTS/NRADJNRCELL-1:lcrId=3
...    NRBTS/NRADJNRCELL-1:nrarfcn=653400
...    NRBTS/NRADJNRCELL-1:physCellId=52
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mncLength=3
...    delete:NRBTS/NRADJNRCELL-1:fiveGsTac
...    NRBTS/NRADJNRCELL-1/ADJ_NRPLMNSET_SA-1:fiveGsTac=100
...    NRBTS/NRADJNRCELL-1/ADJ_NRPLMNSET_SA-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS/NRADJNRCELL-2:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-2:fiveGsTac=100
...    NRBTS/NRADJNRCELL-2:freqBandIndicatorNR=77
...    NRBTS/NRADJNRCELL-2:gNbId=2
...    NRBTS/NRADJNRCELL-2:gNbIdLength=22
...    NRBTS/NRADJNRCELL-2:lcrId=4
...    NRBTS/NRADJNRCELL-2:nrarfcn=648000
...    NRBTS/NRADJNRCELL-2:physCellId=53
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mncLength=3
...    delete:NRBTS/NRADJNRCELL-2:fiveGsTac
...    NRBTS/NRADJNRCELL-2/ADJ_NRPLMNSET_SA-1:fiveGsTac=100
...    NRBTS/NRADJNRCELL-2/ADJ_NRPLMNSET_SA-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS/NRADJNRCELL-3:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-3:fiveGsTac=100
...    NRBTS/NRADJNRCELL-3:freqBandIndicatorNR=3
...    NRBTS/NRADJNRCELL-3:gNbId=2
...    NRBTS/NRADJNRCELL-3:gNbIdLength=22
...    NRBTS/NRADJNRCELL-3:lcrId=11
...    NRBTS/NRADJNRCELL-3:nrarfcn=368400
...    NRBTS/NRADJNRCELL-3:physCellId=60
...    NRBTS/NRADJNRCELL-3:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-3:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-3:gnbPlmn:mncLength=3
...    delete:NRBTS/NRADJNRCELL-3:fiveGsTac
...    NRBTS/NRADJNRCELL-3/ADJ_NRPLMNSET_SA-1:fiveGsTac=100
...    NRBTS/NRADJNRCELL-3/ADJ_NRPLMNSET_SA-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS/NRADJNRCELL-4:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-4:fiveGsTac=100
...    NRBTS/NRADJNRCELL-4:freqBandIndicatorNR=28
...    NRBTS/NRADJNRCELL-4:gNbId=2
...    NRBTS/NRADJNRCELL-4:gNbIdLength=22
...    NRBTS/NRADJNRCELL-4:lcrId=12
...    NRBTS/NRADJNRCELL-4:nrarfcn=153400
...    NRBTS/NRADJNRCELL-4:physCellId=61
...    NRBTS/NRADJNRCELL-4:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-4:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-4:gnbPlmn:mncLength=3
...    delete:NRBTS/NRADJNRCELL-4:fiveGsTac
...    NRBTS/NRADJNRCELL-4/ADJ_NRPLMNSET_SA-1:fiveGsTac=100
...    NRBTS/NRADJNRCELL-4/ADJ_NRPLMNSET_SA-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
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
...    NRBTS:actSliceAwareScheduler=true
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
...    NRDU-1:xgUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1|nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-3
...    NRDU-1:xgUplane:ipV6AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-1|nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-3
...    NRBTS/TRACKINGAREA-200:fiveGsTac=200
...    TRACKINGAREA-200:snssaiList:snssaiDNLast=SNSSAI-4|snssaiDN=SNSSAI-1
...    NRBTS/SNSSAI-1:administrativeState=Unlocked
...    NRBTS/SNSSAI-1:sst=1
...    delete:NRBTS/SNSSAI-1:sd
...    NRBTS/SNSSAI-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS/SNSSAI-1:xgUplane:ipV4AddressDN1=${EMPTY}
...    NRBTS/SNSSAI-1:xgUplane:ipV6AddressDN1=${EMPTY}
...    NRBTS/SNSSAI-2:administrativeState=Unlocked
...    NRBTS/SNSSAI-2:sst=1
...    NRBTS/SNSSAI-2:sd=13714341
...    NRBTS/SNSSAI-2:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS/SNSSAI-2:xgUplane:ipV4AddressDN1=${EMPTY}
...    NRBTS/SNSSAI-2:xgUplane:ipV6AddressDN1=${EMPTY}
...    NRBTS/SNSSAI-3:administrativeState=Unlocked
...    NRBTS/SNSSAI-3:sst=1
...    NRBTS/SNSSAI-3:sd=0
...    NRBTS/SNSSAI-3:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-2
...    NRBTS/SNSSAI-3:xgUplane:ipV4AddressDN1=${EMPTY}
...    NRBTS/SNSSAI-3:xgUplane:ipV6AddressDN1=${EMPTY}
...    NRBTS/SNSSAI-4:administrativeState=Unlocked
...    NRBTS/SNSSAI-4:sst=1
...    NRBTS/SNSSAI-4:sd=0
...    NRBTS/SNSSAI-4:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-3
...    NRBTS/SNSSAI-4:xgUplane:ipV4AddressDN1=${EMPTY}
...    NRBTS/SNSSAI-4:xgUplane:ipV6AddressDN1=${EMPTY}
...    delete:NRCELL:trackingAreaDN
...    delete:NRCELL:configuredEpsTac
...    NRCELL/NRPLMNSET_SA-1:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-200
...    NRCELL/NRPLMNSET_SA-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1,MRBTS-1/NRBTS-1/NRPLMN-2,,MRBTS-1/NRBTS-1/NRPLMN-3
#PLMN-1 + TRACKINGAREA-200:SNSSAI-1/SNSSAI-2/SNSSAI-3/SNSSAI-4==>PLMN-1 + SNSSAI-1/SNSSAI-2
#PLMN-2 + TRACKINGAREA-200:SNSSAI-1/SNSSAI-2/SNSSAI-3/SNSSAI-4==>PLMN-2 + SNSSAI-3
#PLMN-3 + TRACKINGAREA-200:SNSSAI-1/SNSSAI-2/SNSSAI-3/SNSSAI-4==>PLMN-3 + SNSSAI-4
...    NRCELL/NRPLMNSET_NSA-1:configuredEpsTac=222
...    NRCELL/NRPLMNSET_NSA-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1,MRBTS-1/NRBTS-1/NRPLMN-2,MRBTS-1/NRBTS-1/NRPLMN-3
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
...    NRBTS:actSliceAwareScheduler=true
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
...    NRBTS/TRACKINGAREA-200:fiveGsTac=200
...    TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-2|snssaiDN=SNSSAI-2
...    TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-3|snssaiDN=SNSSAI-3
...    TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-4|snssaiDN=SNSSAI-4
...    delete:NRCELL:trackingAreaDN
...    delete:NRCELL:configuredEpsTac
...    NRCELL/NRPLMNSET_SA-1:trackingAreaDN=MRBTS-2/NRBTS-2/TRACKINGAREA-100
...    NRCELL/NRPLMNSET_SA-1:nrPlmnDNList=MRBTS-2/NRBTS-2/NRPLMN-1
#PLMN-1 + TRACKINGAREA-100:SNSSAI-1/SNSSAI-2/SNSSAI-3==>PLMN-1 + SNSSAI-1
...    NRCELL/NRPLMNSET_SA-2:trackingAreaDN=MRBTS-2/NRBTS-2/TRACKINGAREA-200
...    NRCELL/NRPLMNSET_SA-2:nrPlmnDNList=MRBTS-2/NRBTS-2/NRPLMN-2,MRBTS-2/NRBTS-2/NRPLMN-4
#PLMN-2 + TRACKINGAREA-200:SNSSAI-2/SNSSAI-3/SNSSAI-4==>PLMN-2 + SNSSAI-2
#PLMN-4 + TRACKINGAREA-200:SNSSAI-2/SNSSAI-3/SNSSAI-4==>PLMN-4 + SNSSAI-3/SNSSAI-4
...    NRCELL/NRPLMNSET_NSA-1:configuredEpsTac=222
...    NRCELL/NRPLMNSET_NSA-1:nrPlmnDNList=MRBTS-2/NRBTS-2/NRPLMN-1,MRBTS-2/NRBTS-2/NRPLMN-2
...    NRBTS/SNSSAI-1:administrativeState=Unlocked
...    NRBTS/SNSSAI-1:sst=1
...    delete:NRBTS/SNSSAI-1:sd
...    NRBTS/SNSSAI-1:nrPlmnDNList=MRBTS-2/NRBTS-2/NRPLMN-1
...    NRBTS/SNSSAI-1:xgUplane:ipV4AddressDN1=MRBTS-2/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-3
...    NRBTS/SNSSAI-1:xgUplane:ipV6AddressDN1=${EMPTY}
...    NRBTS/SNSSAI-2:administrativeState=Unlocked
...    NRBTS/SNSSAI-2:sst=1
...    NRBTS/SNSSAI-2:sd=13714341
...    NRBTS/SNSSAI-2:nrPlmnDNList=MRBTS-2/NRBTS-2/NRPLMN-2
...    NRBTS/SNSSAI-2:xgUplane:ipV4AddressDN1=MRBTS-2/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-4
...    NRBTS/SNSSAI-2:xgUplane:ipV6AddressDN1=${EMPTY}
...    NRBTS/SNSSAI-3:administrativeState=Unlocked
...    NRBTS/SNSSAI-3:sst=1
...    NRBTS/SNSSAI-3:sd=0
...    NRBTS/SNSSAI-3:nrPlmnDNList=MRBTS-2/NRBTS-2/NRPLMN-4
...    NRBTS/SNSSAI-3:xgUplane:ipV4AddressDN1=MRBTS-2/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-5
...    NRBTS/SNSSAI-3:xgUplane:ipV6AddressDN1=${EMPTY}
...    NRBTS/SNSSAI-4:administrativeState=Unlocked
...    NRBTS/SNSSAI-4:sst=1
...    NRBTS/SNSSAI-4:sd=13714342
...    NRBTS/SNSSAI-4:nrPlmnDNList=MRBTS-2/NRBTS-2/NRPLMN-4
...    NRBTS/SNSSAI-4:xgUplane:ipV4AddressDN1=MRBTS-2/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-4
...    NRBTS/SNSSAI-4:xgUplane:ipV6AddressDN1=MRBTS-2/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-5
@{PARAMS_FOR_OTHERS}

...    NRCELL:actCDrx=false

*** Test Cases ***
CB008140-ET-GG009_ext-SCell_Addition_procedure_is_not_triggered_due_to_incompatible_slice_of_the_candidate_ext-Scells_with_RAN_sharing
    [Documentation]
    ...    Ext-SCell Addition procedure is not triggered due to incompatible slice of the candidate ext-Scells, with RAN sharing enabled
    ...    both in prime and external gNB, with Transport RAN sharing
    ...    1.[Configuration]:
    ...    Cell id=1 gnb=2 pci=16:2 tac=200 tdd_cell=on band=n77 nr_arfcn=663400:663400 gscn=8159 chBw=100MHz Cellid=0x4001
    ...    Cell id=2 gnb=2 pci=17:0 tac=200 tdd_cell=on band=n77 nr_arfcn=658000:658000 gscn=8103 chBw=40MHz
    ...    Cell id=3 gnb=3 pci=17:1 tac=200 tdd_cell=on band=n77 nr_arfcn=653400:653400 gscn=8072 chBw=100MHz SCellWeight=50 Cellid=0x8003/32771
    ...    Cell id=4 gnb=3 pci=17:2 tac=200 tdd_cell=on band=n77 nr_arfcn=648000:648000 gscn=8000 chBw=40MHz SCellWeight=50 Cellid=0x8004/32772
    ...    Cell id=11 gnb=3 pci=20:0 tac=200 tdd_cell=off band=n3 nr_arfcn=349400:368400 gscn=4605 chBw=10MHz SCellWeight=50 Cellid=0x800b/32779
    ...    Cell id=12 gnb=3 pci=20:1 tac=200 tdd_cell=off band=n28 nr_arfcn=143400:153400 gscn=1916 chBw=10MHz SCellWeight=50 Cellid=0x800c/32780
    ...    2.Test Case Steps:
    ...         a. UE1 Register And first PDU Session Setup On Cell1_1,then UE1 Start Traffic And Verify Throughput
    ...         b. UE2 Register And first PDU Session Setup On Cell1_1,then UE2 Start Traffic And Verify Throughput
    ...    3. Expected Results:
    ...         Step a: UE1 Register and PDU Session Setup Successfully,no CA setup,traffic can start and stop successfully
    ...         Step b: UE2 Register and PDU Session Setup Successfully,no CA setup,traffic can start and stop successfully
    ...    a.PLMN(311,489) with SLICE-1 (0x01,0xFFFFFF) and SLICE-2 (0x01,0xD143A5)
    ...    PLMN(311,402) with SLICE-3 (0x01,0x000000)
    ...    PLMN(311,403) with SLICE-4 (0x01,0xD143A6) for gNB-1
    ...    b.PLMN(311,489) with SLICE-1 (0x01,0xFFFFFF)
    ...    PLMN(311,402) with SLICE-2 (0x01,0xD143A5)
    ...    PLMN(311,404) with SLICE-3 (0x01,0x000000) and SLICE-4 (0x01,0xD143A6) for gNB-2
    ...    c.While NRBTS:actSliceAwareScheduler=true,it requires scell plmn+sclice combinations at least contain the combinations of pcell
    ...        ,then CA would setup
    [Tags]    QC_277248    GG09
    UE Register And PDU Session Setup Without Scell Addition    ue_id=1    nwslice=1    gateway=1
    Run Traffic And Verify Throughput
    UE Register And PDU Session Setup Without Scell Addition    ue_id=2    nwslice=3    gateway=2
    Run Traffic And Verify Throughput    ue_id=2
    Release UEs    ue_type=all

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup 2Airphone Env    fddtdd_sansa_cmwv/6cells_gnb1_2T_gnb2_2T2F    ue_count=2

Modify Cfg
    Update Cfg Param    set_gnb id=2 amf=1-4
    Update Cfg Param    set_gnb id=3 amf=1-4
    Update Cfg    set_amf_region id=1 tac_list=0,100,200,300 plmn=311:489
    Update Cfg    set_amf_region id=2 tac_list=0,100,200,300 plmn=311:402
    Update Cfg    set_amf_region id=3 tac_list=0,100,200,300 plmn=311:403
    Update Cfg    set_amf_region id=4 tac_list=0,100,200,300 plmn=311:404
    Update Cfg    set_amf id=1 daemon=10.0.2.1:22222 ng=10.0.1.1:38412 region=1 set_id=1 pointer=1
    Update Cfg    set_amf id=2 daemon=10.0.2.1:22222 ng=10.0.1.102:38412 region=2 set_id=2 pointer=1
    Update Cfg    set_amf id=3 daemon=10.0.2.1:22222 ng=10.0.1.103:38412 region=3 set_id=3 pointer=1
    Update Cfg    set_amf id=4 daemon=10.0.2.1:22222 ng=10.0.1.104:38412 region=4 set_id=4 pointer=1
    Update Cfg    amf_param id=1 full_nas_auth=on nia=null+zuc nea=null+zuc
    Update Cfg    amf_param id=2 full_nas_auth=on nia=null+zuc nea=null+zuc
    Update Cfg    amf_param id=3 full_nas_auth=on nia=null+zuc nea=null+zuc
    Update Cfg    amf_param id=4 full_nas_auth=on nia=null+zuc nea=null+zuc
    Update Cfg    set_nwslice id=1 snssai=0x01:0xFFFFFF amf=1-4 default=on ue=all
    Update Cfg    set_nwslice id=2 snssai=0x01:0xd143a5 amf=1-4 default=off ue=all
    Update Cfg    set_nwslice id=3 snssai=0x01:0x000000 amf=1-4 default=off ue=all
    Update Cfg    set_pdu_gateway id=3 ue_nat_ip=72.23.2.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    ue_param id=1 ue_nr_capabilities=${CB008140_GG_Capa_2CC_3CC_4CC_n3_n28_n77_n78}
    Update Cfg Param    set_ue simulated id=2 suci=0:311:402:0000:0:0:021645401
    Update Cfg    ue_param id=2 ue_nr_capabilities=${CB008140_GG_Capa_2CC_3CC_4CC_n3_n28_n77_n78}

UE Register And PDU Session Setup Without Scell Addition
    [Arguments]    ${ue_id}=1    ${nwslice}=1    ${gateway}=1    ${enb_id}=2    ${cell_id}=1
    Execute Egate Command    ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=${nwslice} gw=${gateway}
    ...    fail_regexp=activated successfully at airphone

Run Traffic And Verify Throughput
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${qfi}=1
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} trf_id=1 protocol=tcp mbps=150 dir=dl
    ...    pass_regexp=Started Downlink Internal traffic over TCP on Ue
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} trf_id=2 protocol=tcp mbps=150 dir=dl
    ...    pass_regexp=Started Downlink Internal traffic over TCP on Ue
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} trf_id=3 protocol=tcp mbps=150 dir=dl
    ...    pass_regexp=Started Downlink Internal traffic over TCP on Ue
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} trf_id=4 protocol=tcp mbps=150 dir=dl
    ...    Started Downlink Internal traffic over TCP on Ue    sleep_time=2
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} trf_id=1 protocol=tcp mbps=50 dir=ul
    ...    pass_regexp=Started Uplink Internal traffic over TCP on Ue
    Verify Throughput    ${ue_id}    ${pdu}    ${qfi}    540    45
    [teardown]    Stop Traffic    ${ue_id}    ${pdu}

Stop Traffic
    [Arguments]    ${ue_id}=1    ${pdu}=1
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=${pdu} dir=dl trf_id=1
    ...    pass_regexp=Stopped Downlink Internal traffic on Ue
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=${pdu} dir=dl trf_id=2
    ...    pass_regexp=Stopped Downlink Internal traffic on Ue
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=${pdu} dir=dl trf_id=3
    ...    pass_regexp=Stopped Downlink Internal traffic on Ue
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=${pdu} dir=dl trf_id=4
    ...    pass_regexp=Stopped Downlink Internal traffic on Ue
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=${pdu} dir=ul trf_id=1
    ...    pass_regexp=Stopping Uplink Internal traffic on Ue

Verify Throughput
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${qfi}=1    ${Tput_dl}=10    ${Tput_ul}=10    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    direction=ul    rate_type=ave
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pdsch    Throughput
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}
