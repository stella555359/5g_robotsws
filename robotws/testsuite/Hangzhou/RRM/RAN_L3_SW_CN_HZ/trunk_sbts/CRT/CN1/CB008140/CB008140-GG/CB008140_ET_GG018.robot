*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CLOUD_5G_I_[LO][LO]_AP_[LOO]    team-L3CN1_SG14
...    owner-jun.15.zhang    release-SBTS23R3
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
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRCELL:a1MeasSCellAddEnabled=rsrpAndRsrq
...    NRCELL:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=31
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=111
...    NRCELL:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrq:a1HysteresisSCellAddSsbRsrq=0
...    NRCELL:a1MeasSCellAddSsbRsrq:a1ThresholdSCellAddSsbRsrq=30
...    NRCELL:a1MeasSCellAddSsbRsrq:a1TimeToTriggerSCellAddSsbRsrq=160ms
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
...    NRBTS/NRADJNRCELL-1/ADJ_NRPLMNSET_SA-1:nrPlmnDNList=NRPLMN-1,NRPLMN-2
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
...    NRBTS/NRADJNRCELL-2/ADJ_NRPLMNSET_SA-1:nrPlmnDNList=NRPLMN-1,NRPLMN-2
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
...    NRBTS/NRADJNRCELL-3/ADJ_NRPLMNSET_SA-1:nrPlmnDNList=NRPLMN-1,NRPLMN-2
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
...    NRBTS/NRADJNRCELL-4/ADJ_NRPLMNSET_SA-1:nrPlmnDNList=NRPLMN-1,NRPLMN-2
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-1:gNbId=2
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-1:lcrId=3
...    NRCELL-1/NRREL-1:removeNotAllowed=false
...    NRCELL-1/NRREL-1:sCellAdditionMethod=covBasedA1
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
...    NRCELL-1/NRREL-2:sCellAdditionMethod=covBasedA1
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
...    NRCELL-1/NRREL-3:sCellAdditionMethod=covBasedA1
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
...    NRCELL-1/NRREL-4:sCellAdditionMethod=covBasedA1
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
...    NRCELL-3:weightForSCellSelection=80
...    NRCELL-4:weightForSCellSelection=50
...    NRCELL-11:weightForSCellSelection=50
...    NRCELL-12:weightForSCellSelection=60
...    NRCELL-12:type0CoresetConfigurationIndex=6
...    NRCELL-12/NRCELL_FDD-1:chBwDl=10MHz
...    NRCELL-12/NRCELL_FDD-1:chBwUl=10MHz
#Update Cell2_12 BW due to CA_n28A-n77(3A) only support n28 BW 5/10MHz
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
...    NRBTS/NRADJNRCELL-1/ADJ_NRPLMNSET_SA-1:nrPlmnDNList=NRPLMN-1,NRPLMN-2
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
...    TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-2:ipAddressAllocationMethod=MANUAL
...    TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-2:localIpAddr=10.0.1.22
...    TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-2:localIpPrefixLength=24
...    TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-3:ipAddressAllocationMethod=MANUAL
...    TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-3:localIpAddr=10.0.1.23
...    TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-3:localIpPrefixLength=24
...    TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-4:ipAddressAllocationMethod=MANUAL
...    TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-4:localIpAddr=10.0.1.24
...    TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-4:localIpPrefixLength=24
...    TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-5:ipAddressAllocationMethod=MANUAL
...    TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-5:localIpAddr=10.0.1.25
...    TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-5:localIpPrefixLength=24
...    TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-1:ipAddressAllocationMethod=MANUAL
...    TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-1:localIpAddr=fc00::172:18:6:21
...    TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-1:localIpPrefixLength=112
...    TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-2:ipAddressAllocationMethod=MANUAL
...    TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-2:localIpAddr=fc00::172:18:6:22
...    TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-2:localIpPrefixLength=112
...    TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-3:ipAddressAllocationMethod=MANUAL
...    TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-3:localIpAddr=fc00::172:18:6:23
...    TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-3:localIpPrefixLength=112
...    TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-4:ipAddressAllocationMethod=MANUAL
...    TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-4:localIpAddr=fc00::172:18:6:24
...    TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-4:localIpPrefixLength=112
...    TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-5:ipAddressAllocationMethod=MANUAL
...    TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-5:localIpAddr=fc00::172:18:6:25
...    TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-5:localIpPrefixLength=112
...    SERVEDAMF-1:amfIPAddress=10.0.1.1
...    SERVEDAMF-1:ngTnlId=1
...    SERVEDAMF-2:amfIPAddress=10.0.1.102
...    SERVEDAMF-2:ngTnlId=1
...    NRPLMN-1:mcc=311
...    NRPLMN-1:mnc=489
...    NRPLMN-1:mncLength=3
...    NRPLMN-2:mcc=311
...    NRPLMN-2:mnc=402
...    NRPLMN-2:mncLength=3
@{PARAMS_RANSHARING_GNB1}
...    NRBTS:actRanSharing=true
...    NRBTS:actTrsSepaSARanSharing=true
...    NRBTS:actNgcFlexSaMode=true
...    NRBTS:ngCplane:ipV4AddressDN1=TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1|ngTnlId=1
...    NRBTS:ngUplane:ipV4AddressDN1=TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1|nrPlmnDN=NRPLMN-1
...    NRBTS:ngUplane:ipV4AddressDN1=TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1|nrPlmnDN=NRPLMN-2
...    NRBTS:xnCplane:ipV4AddressDN1=TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1|xnTnlId=1
...    NRBTS:xnUplane:ipV4AddressDN1=TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1|nrPlmnDN=NRPLMN-1
...    NRBTS/XNLINK-1:xnTnlId=1
...    NRDU-1:xgUplane:ipV4AddressDN1=TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1|ipV6AddressDN1=TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-1
...    NRDU-1:xgUplane:nrPlmnDN=NRPLMN-1|ipV6AddressDN1=TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-1
...    NRDU-1:xgUplane:ipV4AddressDN1=TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-2|ipV6AddressDN1=TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-2
...    NRDU-1:xgUplane:nrPlmnDN=NRPLMN-2|ipV6AddressDN1=TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-2
...    NRDU-1:xgUplane:ipV4AddressDN1=TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-3|ipV6AddressDN1=TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-3
...    NRDU-1:xgUplane:nrPlmnDN=NRPLMN-1|ipV6AddressDN1=TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-3
...    NRDU-1:xgUplane:ipV4AddressDN1=TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-4|ipV6AddressDN1=TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-4
...    NRDU-1:xgUplane:nrPlmnDN=NRPLMN-1|ipV6AddressDN1=TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-4
...    NRBTS/TRACKINGAREA-200:fiveGsTac=200
...    TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-1|snssaiDN=SNSSAI-1
...    TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-2|snssaiDN=SNSSAI-2
...    NRBTS/TRACKINGAREA-300:fiveGsTac=300
...    TRACKINGAREA-300:snssaiList:snssaiDN=SNSSAI-1|snssaiDN=SNSSAI-1
...    TRACKINGAREA-300:snssaiList:snssaiDN=SNSSAI-2|snssaiDN=SNSSAI-2
...    TRACKINGAREA-300:snssaiList:snssaiDN=SNSSAI-3|snssaiDN=SNSSAI-3
...    delete:NRCELL:trackingAreaDN
...    delete:NRCELL:configuredEpsTac
...    NRCELL/NRPLMNSET_SA-1:trackingAreaDN=TRACKINGAREA-200
...    NRCELL/NRPLMNSET_SA-1:nrPlmnDNList=NRPLMN-1
#PLMN-1 + TRACKINGAREA-200:SNSSAI-1/SNSSAI-2==>PLMN-1 + SNSSAI-1/SNSSAI-2
...    NRCELL/NRPLMNSET_SA-2:trackingAreaDN=TRACKINGAREA-300
...    NRCELL/NRPLMNSET_SA-2:nrPlmnDNList=NRPLMN-2
#PLMN-2 + TRACKINGAREA-300:SNSSAI-1/SNSSAI-2/SNSSAI-3==>PLMN-2 + SNSSAI-3
...    NRCELL/NRPLMNSET_NSA-1:configuredEpsTac=222
...    NRCELL/NRPLMNSET_NSA-1:nrPlmnDNList=NRPLMN-1,NRPLMN-2
...    NRBTS/SNSSAI-1:administrativeState=Unlocked
...    NRBTS/SNSSAI-1:sst=1
...    delete:NRBTS/SNSSAI-1:sd
...    NRBTS/SNSSAI-1:nrPlmnDNList=NRPLMN-1
...    NRBTS/SNSSAI-1:xgUplane:ipV4AddressDN1=${EMPTY}
...    NRBTS/SNSSAI-1:xgUplane:ipV6AddressDN1=${EMPTY}
...    NRBTS/SNSSAI-2:administrativeState=Unlocked
...    NRBTS/SNSSAI-2:sst=1
...    NRBTS/SNSSAI-2:sd=13714341
...    NRBTS/SNSSAI-2:nrPlmnDNList=NRPLMN-1
...    NRBTS/SNSSAI-2:xgUplane:ipV4AddressDN1=${EMPTY}
...    NRBTS/SNSSAI-2:xgUplane:ipV6AddressDN1=TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-5
...    NRBTS/SNSSAI-3:administrativeState=Unlocked
...    NRBTS/SNSSAI-3:sst=1
...    NRBTS/SNSSAI-3:sd=0
...    NRBTS/SNSSAI-3:nrPlmnDNList=NRPLMN-2
...    NRBTS/SNSSAI-3:xgUplane:ipV4AddressDN1=${EMPTY}
...    NRBTS/SNSSAI-3:xgUplane:ipV6AddressDN1=${EMPTY}
@{PARAMS_AMF_PLMN_IPADDRS_GNB2}
...    TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-2:ipAddressAllocationMethod=MANUAL
...    TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-2:localIpAddr=10.0.1.32
...    TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-2:localIpPrefixLength=24
...    TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-3:ipAddressAllocationMethod=MANUAL
...    TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-3:localIpAddr=10.0.1.33
...    TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-3:localIpPrefixLength=24
...    TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-4:ipAddressAllocationMethod=MANUAL
...    TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-4:localIpAddr=10.0.1.34
...    TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-4:localIpPrefixLength=24
...    TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-5:ipAddressAllocationMethod=MANUAL
...    TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-5:localIpAddr=10.0.1.35
...    TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-5:localIpPrefixLength=24
...    TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-1:ipAddressAllocationMethod=MANUAL
...    TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-1:localIpAddr=fc00::172:18:6:31
...    TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-1:localIpPrefixLength=112
...    TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-2:ipAddressAllocationMethod=MANUAL
...    TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-2:localIpAddr=fc00::172:18:6:32
...    TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-2:localIpPrefixLength=112
...    TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-3:ipAddressAllocationMethod=MANUAL
...    TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-3:localIpAddr=fc00::172:18:6:33
...    TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-3:localIpPrefixLength=112
...    TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-4:ipAddressAllocationMethod=MANUAL
...    TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-4:localIpAddr=fc00::172:18:6:34
...    TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-4:localIpPrefixLength=112
...    TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-5:ipAddressAllocationMethod=MANUAL
...    TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-5:localIpAddr=fc00::172:18:6:35
...    TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-5:localIpPrefixLength=112
...    SERVEDAMF-1:amfIPAddress=10.0.1.1
...    SERVEDAMF-1:ngTnlId=1
...    SERVEDAMF-2:amfIPAddress=10.0.1.102
...    SERVEDAMF-2:ngTnlId=1
...    NRPLMN-1:mcc=311
...    NRPLMN-1:mnc=489
...    NRPLMN-1:mncLength=3
...    NRPLMN-2:mcc=311
...    NRPLMN-2:mnc=402
...    NRPLMN-2:mncLength=3
@{PARAMS_RANSHARING_GNB2}
...    NRBTS:actRanSharing=true
...    NRBTS:actTrsSepaSARanSharing=true
...    NRBTS:actNgcFlexSaMode=true
...    NRBTS:ngCplane:ipV4AddressDN1=TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1|ngTnlId=1
...    NRBTS:ngUplane:ipV4AddressDN1=TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1|nrPlmnDN=NRPLMN-1
...    NRBTS:ngUplane:ipV4AddressDN1=TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1|nrPlmnDN=NRPLMN-2
...    NRBTS:xnCplane:ipV4AddressDN1=TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1|xnTnlId=1
...    NRBTS:xnUplane:ipV4AddressDN1=TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1|nrPlmnDN=NRPLMN-1
...    NRBTS/XNLINK-1:xnTnlId=1
...    NRDU-1:xgUplane:ipV4AddressDN1=TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1|ipV6AddressDN1=TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-1
...    NRDU-1:xgUplane:nrPlmnDN=NRPLMN-1|ipV6AddressDN1=TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-1
...    NRDU-1:xgUplane:ipV4AddressDN1=TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-3|ipV6AddressDN1=TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-3
...    NRDU-1:xgUplane:nrPlmnDN=NRPLMN-1|ipV6AddressDN1=TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-3
...    NRDU-1:xgUplane:ipV4AddressDN1=TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-2|ipV6AddressDN1=TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-2
...    NRDU-1:xgUplane:nrPlmnDN=NRPLMN-1|ipV6AddressDN1=TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-2
...    NRDU-1:xgUplane:ipV4AddressDN1=TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-4|ipV6AddressDN1=TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-4
...    NRDU-1:xgUplane:nrPlmnDN=NRPLMN-2|ipV6AddressDN1=TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-4
...    NRBTS/TRACKINGAREA-100:fiveGsTac=100
...    TRACKINGAREA-100:snssaiList:snssaiDN=SNSSAI-1|snssaiDN=SNSSAI-1
...    TRACKINGAREA-100:snssaiList:snssaiDN=SNSSAI-2|snssaiDN=SNSSAI-2
...    NRBTS/TRACKINGAREA-200:fiveGsTac=200
...    TRACKINGAREA-200:snssaiList:snssaiDNLast=SNSSAI-4|snssaiDN=SNSSAI-1
...    NRBTS/TRACKINGAREA-300:fiveGsTac=300
...    TRACKINGAREA-300:snssaiList:snssaiDN=SNSSAI-1|snssaiDN=SNSSAI-1
...    TRACKINGAREA-300:snssaiList:snssaiDN=SNSSAI-3|snssaiDN=SNSSAI-3
...    delete:NRCELL:trackingAreaDN
...    delete:NRCELL:configuredEpsTac
...    NRCELL-3/NRPLMNSET_SA-1:trackingAreaDN=TRACKINGAREA-300
...    NRCELL-3/NRPLMNSET_SA-1:nrPlmnDNList=NRPLMN-1
#PLMN-1 + TRACKINGAREA-200:SNSSAI-1/SNSSAI-3==>PLMN-1 + SNSSAI-1/SNSSAI-3
...    NRCELL-4/NRPLMNSET_SA-1:trackingAreaDN=TRACKINGAREA-100
...    NRCELL-4/NRPLMNSET_SA-1:nrPlmnDNList=NRPLMN-1
#PLMN-1 + TRACKINGAREA-100:SNSSAI-1/SNSSAI-2==>PLMN-1 + SNSSAI-1/SNSSAI-2
...    NRCELL-11/NRPLMNSET_SA-1:trackingAreaDN=TRACKINGAREA-200
...    NRCELL-11/NRPLMNSET_SA-1:nrPlmnDNList=NRPLMN-1,NRPLMN-2
#PLMN-1 + TRACKINGAREA-200:SNSSAI-1/SNSSAI-2/SNSSAI-3/SNSSAI-4==>PLMN-1 + SNSSAI-1/SNSSAI-2/SNSSAI-4
#PLMN-2 + TRACKINGAREA-200:SNSSAI-1/SNSSAI-2/SNSSAI-3/SNSSAI-4==>PLMN-2 + SNSSAI-3
...    NRCELL-12/NRPLMNSET_SA-1:trackingAreaDN=TRACKINGAREA-100
...    NRCELL-12/NRPLMNSET_SA-1:nrPlmnDNList=NRPLMN-1
#PLMN-1 + TRACKINGAREA-100:SNSSAI-1/SNSSAI-2==>PLMN-1 + SNSSAI-1/SNSSAI-2
...    NRCELL/NRPLMNSET_NSA-1:configuredEpsTac=222
...    NRCELL/NRPLMNSET_NSA-1:nrPlmnDNList=NRPLMN-1,NRPLMN-2
...    NRBTS/SNSSAI-1:administrativeState=Unlocked
...    NRBTS/SNSSAI-1:sst=1
...    delete:NRBTS/SNSSAI-1:sd
...    NRBTS/SNSSAI-1:nrPlmnDNList=NRPLMN-1
...    NRBTS/SNSSAI-1:xgUplane:ipV4AddressDN1=TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-3
...    NRBTS/SNSSAI-1:xgUplane:ipV6AddressDN1=TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-4
...    NRBTS/SNSSAI-2:administrativeState=Unlocked
...    NRBTS/SNSSAI-2:sst=1
...    NRBTS/SNSSAI-2:sd=13714341
...    NRBTS/SNSSAI-2:nrPlmnDNList=NRPLMN-1
...    NRBTS/SNSSAI-2:xgUplane:ipV4AddressDN1=${EMPTY}
...    NRBTS/SNSSAI-2:xgUplane:ipV6AddressDN1=${EMPTY}
...    NRBTS/SNSSAI-3:administrativeState=Unlocked
...    NRBTS/SNSSAI-3:sst=1
...    NRBTS/SNSSAI-3:sd=0
...    NRBTS/SNSSAI-3:nrPlmnDNList=NRPLMN-2
...    NRBTS/SNSSAI-3:xgUplane:ipV4AddressDN1=TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-4
...    NRBTS/SNSSAI-3:xgUplane:ipV6AddressDN1=TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-5
...    NRBTS/SNSSAI-4:administrativeState=Unlocked
...    NRBTS/SNSSAI-4:sst=1
...    NRBTS/SNSSAI-4:sd=13714342
...    NRBTS/SNSSAI-4:nrPlmnDNList=NRPLMN-1
...    NRBTS/SNSSAI-4:xgUplane:ipV4AddressDN1=TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-3
...    NRBTS/SNSSAI-4:xgUplane:ipV6AddressDN1=TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-4
@{PARAMS_FOR_OTHERS}

...    NRBTS:actSliceAwareScheduler=false
...    NRCELL:actCDrx=false

@{actSliceAwareScheduler_True}
...    NRBTS:actSliceAwareScheduler=true

@{UE1_expect}
...    pcid:53, scellIdx:2
...    pcid:61, scellIdx:3
...    SCellIndex 2 activated successfully at airphone
...    SCellIndex 3 activated successfully at airphone
@{UE2_expect}
...    pcid:53, scellIdx:1
...    pcid:60, scellIdx:2
...    pcid:61, scellIdx:3
...    SCellIndex 1 activated successfully at airphone
...    SCellIndex 2 activated successfully at airphone
...    SCellIndex 3 activated successfully at airphone

*** Test Cases ***
CB008140-ET-GG018_ext-SCell_partial_addition_due_to_incompatible_slice_of_the_candidate_ext-Scells_with_RAN_sharing
    [Documentation]
    ...    The successful blind inter-gNB CA SCell addition for SA UE with partial ext-SCell unsupported Slice.
    ...    [Configuration]:
    ...    Cell id=1  gnb=2 pci=16:2 tac=200 tdd_cell=on  band=n77 nr_arfcn=663400:663400 gscn=8159 chBw=100MHz Cellid=0x4001
    ...    Cell id=2  gnb=2 pci=17:0 tac=200 tdd_cell=on  band=n77 nr_arfcn=658000:658000 gscn=8103 chBw=40MHz
    ...    Cell id=3  gnb=3 pci=17:1 tac=200 tdd_cell=on  band=n77 nr_arfcn=653400:653400 gscn=8072 chBw=100MHz SCellWeight=50 Cellid=0x8003/32771
    ...    Cell id=4  gnb=3 pci=17:2 tac=200 tdd_cell=on  band=n77 nr_arfcn=648000:648000 gscn=8000 chBw=40MHz  SCellWeight=50 Cellid=0x8004/32772
    ...    Cell id=11 gnb=3 pci=20:0 tac=200 tdd_cell=off band=n3  nr_arfcn=349400:368400 gscn=4605 chBw=10MHz  SCellWeight=50 Cellid=0x800b/32779
    ...    Cell id=12 gnb=3 pci=20:1 tac=200 tdd_cell=off band=n28 nr_arfcn=143400:153400 gscn=1916 chBw=10MHz  SCellWeight=50 Cellid=0x800c/32780
    ...    2.Test Case Steps:
    ...         a. UE1 Register And PDU Session 1/2 Setup On Cell1_1
    ...         b: UE1 Trigger A1 to Add SCells
    ...         c. UE1 Start Traffic And Verify Throughput On PDU Session 1/2
    ...         d. Online modify set Pri gNB and Ext gNB SCF para actSliceAwareScheduler to true
    ...         e. UE2 Register And PDU Session 1/2 Setup On Cell1_1
    ...         f. UE2 Trigger A1 to Add SCells
    ...         g. UE2 Start Traffic And Verify Throughput On PDU Session 1/2
    ...    3. Expected Results:
    ...         Step a: UE1 Register And PDU Session 1/2 Setup Successful
    ...         Step b: Due to actSliceAwareScheduler disable, Pri gNB will not check Cell PLMN+Slice, select Cell2_3, Cell2_4 and Cell2_12 as
    ...                 Scell, but Cell2_3 add fail by Ext gNB. UE1 Add Cell2_4 and Cell2_12 as Scells for 3CC
    ...         Step c: UE1 Traffic And Throughput On PDU Session 1/2 is OK
    ...         Step d: SCF para Online modify successfully
    ...         Step e: UE2 Register And PDU Session 1/2 Setup Successful
    ...         Step f: Due to actSliceAwareScheduler disable, Pri gNB will check Cell PLMN+Slice, select Cell2_4, Cell2_11 and Cell2_12 as Scell.
    ...                 UE2 Add Cell2_4, Cell2_11 and Cell2_12 as Scells for 4CC
    ...         Step g: UE2 Traffic And Throughput On PDU Session 1/2 is OK
    [Tags]    QC_277461    GG018    CA_LABEL-TTTF(100MHz_TDD_n77+100MHz_TDD_n77+40MHz_TDD_n77+10MHz_FDD_n28)
    ...    CA_LABEL-TTFF(100MHz_TDD_n77_n77+40MHz_TDD_n77+10MHz_FDD_n3+10MHz_FDD_n28)
    UE1 Register And Setup 2 PDU Session
    UE1 Send A1 To Trigger Scell Addition
    Run Traffic And Verify Throughput    ue_id=1    pdu=1
    Run Traffic And Verify Throughput    ue_id=1    pdu=2
    Delta Commission To Enable actSliceAwareScheduler
    UE2 Register And Setup 2 PDU Session
    UE2 Send A1 To Trigger Scell Addition
    Run Traffic And Verify Throughput    ue_id=2    pdu=1
    Run Traffic And Verify Throughput    ue_id=2    pdu=2
    Release UEs    ue_type=all
    Check WireShark Log    ${CURDIR}${/}A2A_GG_018${/}a2a.ini    wait_string=IgNBCAReleaseRequestAcknowledge::2
    Check WireShark Log GNB2    ${CURDIR}${/}A2A_GG_018${/}a2a_gnb2.ini    wait_string=UEContextRelease::8

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup 2Airphone Env    fddtdd_sansa_cmwv/6cells_gnb1_2T_gnb2_2T2F    ue_count=4

Modify Cfg
    Update Cfg Param    set_gnb id=2 amf=1-2
    Update Cfg Param    set_gnb id=3 amf=1-2
    Update Cfg    set_amf_region id=1 tac_list=0,100,200,300 plmn=311:489
    Update Cfg    set_amf_region id=2 tac_list=0,100,200,300 plmn=311:402
    Update Cfg    set_amf id=1 daemon=10.0.2.1:22222 ng=10.0.1.1:38412 region=1 set_id=1 pointer=1
    Update Cfg    set_amf id=2 daemon=10.0.2.1:22222 ng=10.0.1.102:38412 region=2 set_id=2 pointer=1
    Update Cfg    amf_param id=1 full_nas_auth=on nia=null+zuc nea=null+zuc
    Update Cfg    amf_param id=2 full_nas_auth=on nia=null+zuc nea=null+zuc
    Update Cfg    set_nwslice id=1 snssai=0x01:0xFFFFFF amf=1-2 default=on ue=all
    Update Cfg    set_nwslice id=2 snssai=0x01:0xd143a5 amf=1-2 default=off ue=all
    Update Cfg    set_nwslice id=3 snssai=0x01:0x000000 amf=1-2 default=off ue=all
    Update Cfg    set_nwslice id=4 snssai=0x01:0xd143a6 amf=1-2 default=off ue=all
    Update Cfg    ue_param id=1 ue_nr_capabilities=${CB008140_GG_Capa_2CC_3CC_4CC_n3_n28_n77_n78}
    Update Cfg    ue_param id=2 ue_nr_capabilities=${CB008140_GG_Capa_2CC_3CC_4CC_n3_n28_n77_n78}

Delta Commission To Enable actSliceAwareScheduler
    Delta Commission Parameters    ${actSliceAwareScheduler_True}
    Delta Commission Parameters GNB2    ${actSliceAwareScheduler_True}

UE1 Register And Setup 2 PDU Session
    Execute Egate Command    ue_change_location id=1 enb=2 cell=1
    Execute Egate Command    ue_register id=1    pass_regexp=NG RM Registered
    Execute Egate Command    set_pdu_param ue=1 pdu=1 trf_type=internal
    ${ret1}=    Execute Egate Command    ue_pdu_session_setup ue=1 pdu=1 nwslice=1 gw=1    pass_regexp=QoS Routing Table
    Execute Egate Command    set_pdu_param ue=1 pdu=2 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=1 pdu=2 nwslice=2 gw=2    pass_regexp=QoS Routing Table    timeout=20s

UE2 Register And Setup 2 PDU Session
    Execute Egate Command    ue_change_location id=2 enb=2 cell=1
    Execute Egate Command    ue_register id=2    pass_regexp=NG RM Registered
    Execute Egate Command    set_pdu_param ue=2 pdu=1 trf_type=internal
    ${ret1}=    Execute Egate Command    ue_pdu_session_setup ue=2 pdu=1 nwslice=1 gw=3    pass_regexp=QoS Routing Table
    Execute Egate Command    set_pdu_param ue=2 pdu=2 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=2 pdu=2 nwslice=2 gw=4    pass_regexp=QoS Routing Table    timeout=20s

UE1 Send A1 To Trigger Scell Addition
    ${ScellAdd_A1}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=1    carrierfreq=663360    event_type=A1
    ...    threshold=RSRP\ 31
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=1 meas_id=${ScellAdd_A1} event=A1 srsrp_nr=115 srsrq_nr=40
    ...    pass_regexp=${UE1_expect}    fail_regexp=SCellIndex 1 activated successfully at airphone    timeout=20s

UE2 Send A1 To Trigger Scell Addition
    ${ScellAdd_A1}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=2    carrierfreq=663360    event_type=A1
    ...    threshold=RSRP\ 31
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=2 meas_id=${ScellAdd_A1} event=A1 srsrp_nr=115 srsrq_nr=40
    ...    pass_regexp=${UE2_expect}    timeout=20s

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
