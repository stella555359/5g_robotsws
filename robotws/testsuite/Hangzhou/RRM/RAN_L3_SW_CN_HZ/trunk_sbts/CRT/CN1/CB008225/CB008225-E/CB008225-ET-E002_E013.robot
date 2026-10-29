*** Settings ***
Suite Setup    Common Suite Setup And Setup 2Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CLOUD_5G_I_[LO][LO]_AP_[LOO]    team-CN1ET    owner-jing.ye    release-SBTS24R1    CRT
Resource    ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
${NOKIA_XNAP_PLUGIN_FLAG}    ${True}
${NOKIA_F1AP_PLUGIN_FLAG}    ${True}

@{PARAMS_IN_SCF}
...    @{PARAMS_FOR_CA}
...    @{PARAMS_FOR_GNB1}
...    @{PARAMS_ADJ_REL_FOR_GNB1}
...    @{PARAMS_FOR_OTHERS}
...    @{GNB1_CA_rel}

@{PARAMS_IN_SCF_GNB2}
...    @{PARAMS_FOR_CA}
...    @{PARAMS_FOR_GNB2}
...    @{PARAMS_ADJ_REL_FOR_GNB2}
...    @{PARAMS_FOR_OTHERS}

@{PARAMS_FOR_CA}
...    NRBTS:actCarrierAggregation=true
...    NRBTS:caConfigurationSupport=4CCDL_2CCUL
...    NRBTS:weightForIgnbCaSelection=1
...    NRBTS:actIncXn=true
...    NRBTS:maxNumScellsUl=2
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:carrierAggregationSupportList=${CA_support_list}
...    NRBTS/NRDRB_RLC_AM-1:ulTReassemblyIBCA=40
...    NRBTS/NRDRB_RLC_AM-2:ulTReassemblyIBCA=40
...    NRDU-1:actInterGnbCa=DLOnly
...    NRDU-1:dlToUlContributionRatio=50
...    NRCELL:actK1Opt=intraAndInter-gNB
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRDU-1:actConnectedModeMobilityCA=true
${CA_support_list}    ca_Fdd_Fdd,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Fr1Tdd_Sa_WithUl,ca_Fdd_Any_Sa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Fdd_Sa_WithUl

@{PARAMS_FOR_GNB1}
...    NRBTS:sCellActivationMethod=blind
...    NRCELL-11:measGapSelectionSA=favourUeThroughput
...    NRBTS:actBufferBasedSCellAddition=oneShot_Dl_Fr1
...    NRCELL:dlSCellConfigLevel=10
...    NRCELL:dlSCellConfigLevelNum=20
...    NRBTS:rrcInactPreferredStateEnabled=true
...    NRBTS:actRrcReleasePreference=true
...    NRBTS:timerReleasePreferenceProhibit=s5
...    MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-2:ipAddressAllocationMethod=MANUAL
...    MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-2:localIpAddr=10.0.1.22
...    MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-2:localIpPrefixLength=24
...    MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-3:ipAddressAllocationMethod=MANUAL
...    MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-3:localIpAddr=10.0.1.23
...    MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-3:localIpPrefixLength=24
...    MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-3:ipAddressAllocationMethod=MANUAL
...    MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-3:localIpAddr=fc00::172:18:6:23
...    MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-3:localIpPrefixLength=112
...    MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-4:ipAddressAllocationMethod=MANUAL
...    MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-4:localIpAddr=10.0.1.24
...    MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-4:localIpPrefixLength=24
...    MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-4:ipAddressAllocationMethod=MANUAL
...    MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-4:localIpAddr=fc00::172:18:6:24
...    MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-4:localIpPrefixLength=112
...    MRBTS-1/NRBTS-1/SNSSAI-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1,MRBTS-1/NRBTS-1/NRPLMN-2
...    MRBTS-1/NRBTS-1/SNSSAI-1:xgUplane:ipV4AddressDN1=${EMPTY}
...    MRBTS-1/NRBTS-1/SNSSAI-1:xgUplane:ipV6AddressDN1=${EMPTY}
...    MRBTS-1/NRBTS-1/SNSSAI-2:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1,MRBTS-1/NRBTS-1/NRPLMN-2
...    MRBTS-1/NRBTS-1/SNSSAI-2:sst=1
...    MRBTS-1/NRBTS-1/SNSSAI-2:administrativeState=Unlocked
...    delete:MRBTS-1/NRBTS-1/SNSSAI-2:sd
...    MRBTS-1/NRBTS-1/SNSSAI-2:xgUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-3
...    MRBTS-1/NRBTS-1/SNSSAI-2:xgUplane:ipV6AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-3
...    delete:MRBTS-1/NRBTS-1/SNSSAI-2:drbInactivityTimerSA
...    TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-1|snssaiDN=SNSSAI-1
...    TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-2|snssaiDN=SNSSAI-2
...    MRBTS-1/NRBTS-1/NRPLMN-2:mcc=311
...    MRBTS-1/NRBTS-1/NRPLMN-2:mnc=402
...    MRBTS-1/NRBTS-1/NRPLMN-2:mncLength=3
...    NRCELL/NRPLMNSET_SA-1:ranAC=0
...    NRCELL/NRPLMNSET_SA-1:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-200
...    NRCELL/NRPLMNSET_SA-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1,MRBTS-1/NRBTS-1/NRPLMN-2
...    NRCELL/NRPLMNSET_NSA-1:configuredEpsTac=200
...    NRCELL/NRPLMNSET_NSA-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1,MRBTS-1/NRBTS-1/NRPLMN-2
...    NRDU-1:xgUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-2|nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRDU-1:xgUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1|nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-2
...    MRBTS-1/NRBTS-1:ngUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1|nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1
...    MRBTS-1/NRBTS-1:ngUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1|nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-2
...    MRBTS-1/NRBTS-1:xnUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1|nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1

@{PARAMS_FOR_GNB2}
...    NRBTS:sCellActivationMethod=bufferBased
...    MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-2:ipAddressAllocationMethod=MANUAL
...    MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-2:localIpAddr=10.0.1.32
...    MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-2:localIpPrefixLength=24
...    MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-3:ipAddressAllocationMethod=MANUAL
...    MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-3:localIpAddr=10.0.1.33
...    MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-3:localIpPrefixLength=24
...    MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-3:ipAddressAllocationMethod=MANUAL
...    MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-3:localIpAddr=fc00::172:18:6:33
...    MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-3:localIpPrefixLength=112
...    MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-4:ipAddressAllocationMethod=MANUAL
...    MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-4:localIpAddr=10.0.1.34
...    MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-4:localIpPrefixLength=24
...    MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-4:ipAddressAllocationMethod=MANUAL
...    MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-4:localIpAddr=fc00::172:18:6:34
...    MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-4:localIpPrefixLength=112
...    MRBTS-1/NRBTS-2/SNSSAI-1:nrPlmnDNList=MRBTS-1/NRBTS-2/NRPLMN-1,MRBTS-1/NRBTS-2/NRPLMN-2
...    MRBTS-1/NRBTS-2/SNSSAI-1:xgUplane:ipV4AddressDN1=${EMPTY}
...    MRBTS-1/NRBTS-2/SNSSAI-1:xgUplane:ipV6AddressDN1=${EMPTY}
...    MRBTS-1/NRBTS-2/SNSSAI-2:nrPlmnDNList=MRBTS-1/NRBTS-2/NRPLMN-1,MRBTS-1/NRBTS-2/NRPLMN-2
...    MRBTS-1/NRBTS-2/SNSSAI-2:sst=1
...    MRBTS-1/NRBTS-2/SNSSAI-2:administrativeState=Unlocked
...    delete:MRBTS-1/NRBTS-2/SNSSAI-2:sd
...    MRBTS-1/NRBTS-2/SNSSAI-2:xgUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-3
...    MRBTS-1/NRBTS-2/SNSSAI-2:xgUplane:ipV6AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-3
...    delete:MRBTS-1/NRBTS-2/SNSSAI-2:drbInactivityTimerSA
...    TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-1|snssaiDN=SNSSAI-1
...    TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-2|snssaiDN=SNSSAI-2
...    MRBTS-1/NRBTS-2/NRPLMN-2:mcc=311
...    MRBTS-1/NRBTS-2/NRPLMN-2:mnc=402
...    MRBTS-1/NRBTS-2/NRPLMN-2:mncLength=3
...    NRCELL/NRPLMNSET_SA-1:ranAC=0
...    NRCELL/NRPLMNSET_SA-1:trackingAreaDN=MRBTS-1/NRBTS-2/TRACKINGAREA-200
...    NRCELL/NRPLMNSET_SA-1:nrPlmnDNList=MRBTS-1/NRBTS-2/NRPLMN-1,MRBTS-1/NRBTS-2/NRPLMN-2
...    NRCELL/NRPLMNSET_NSA-1:configuredEpsTac=200
...    NRCELL/NRPLMNSET_NSA-1:nrPlmnDNList=MRBTS-1/NRBTS-2/NRPLMN-1,MRBTS-1/NRBTS-2/NRPLMN-2
...    NRDU-1:xgUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-2|nrPlmnDN=MRBTS-1/NRBTS-2/NRPLMN-1
...    NRDU-1:xgUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1|nrPlmnDN=MRBTS-1/NRBTS-2/NRPLMN-2
...    MRBTS-1/NRBTS-2:ngUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1|nrPlmnDN=MRBTS-1/NRBTS-2/NRPLMN-1
...    MRBTS-1/NRBTS-2:ngUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1|nrPlmnDN=MRBTS-1/NRBTS-2/NRPLMN-2
...    MRBTS-1/NRBTS-2:xnUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1|nrPlmnDN=MRBTS-1/NRBTS-2/NRPLMN-1

@{PARAMS_ADJ_REL_FOR_GNB1}
...    NRBTS/NRADJGNB-2:administrativeState=Unlocked
...    NRBTS/NRADJGNB-2:gNbIdLength=22
...    NRBTS/NRADJGNB-2:gNodeBId=2
...    NRBTS/NRADJGNB-2:weightForIgnbCaSelection=1
...    NRBTS/NRADJGNB-2:xnLinkRef=1
...    NRBTS/NRADJGNB-2:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-2:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-2:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-1:cellDepType=SA
...    NRBTS/NRADJNRCELL-1:gNbId=2
...    NRBTS/NRADJNRCELL-1:gNbIdLength=22
...    NRBTS/NRADJNRCELL-1:lcrId=1
...    NRBTS/NRADJNRCELL-1:nrarfcn=663400
...    NRBTS/NRADJNRCELL-1:physCellId=50
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-1:freqBandIndicatorNR=77
...    NRBTS/NRADJNRCELL-1/ADJ_NRPLMNSET_SA-1:fiveGsTac=200
...    NRBTS/NRADJNRCELL-1/ADJ_NRPLMNSET_SA-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1,MRBTS-1/NRBTS-1/NRPLMN-2
...    NRBTS/NRADJNRCELL-2:cellDepType=SA
...    NRBTS/NRADJNRCELL-2:gNbId=2
...    NRBTS/NRADJNRCELL-2:gNbIdLength=22
...    NRBTS/NRADJNRCELL-2:lcrId=2
...    NRBTS/NRADJNRCELL-2:nrarfcn=658000
...    NRBTS/NRADJNRCELL-2:physCellId=51
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-2:freqBandIndicatorNR=77
...    NRBTS/NRADJNRCELL-2/ADJ_NRPLMNSET_SA-1:fiveGsTac=200
...    NRBTS/NRADJNRCELL-2/ADJ_NRPLMNSET_SA-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1,MRBTS-1/NRBTS-1/NRPLMN-2
...    NRBTS/NRADJNRCELL-14:cellDepType=SA
...    NRBTS/NRADJNRCELL-14:gNbId=2
...    NRBTS/NRADJNRCELL-14:gNbIdLength=22
...    NRBTS/NRADJNRCELL-14:lcrId=14
...    NRBTS/NRADJNRCELL-14:nrarfcn=153400
...    NRBTS/NRADJNRCELL-14:physCellId=63
...    NRBTS/NRADJNRCELL-14:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-14:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-14:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-14:freqBandIndicatorNR=28
...    NRBTS/NRADJNRCELL-14/ADJ_NRPLMNSET_SA-1:fiveGsTac=200
...    NRBTS/NRADJNRCELL-14/ADJ_NRPLMNSET_SA-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1,MRBTS-1/NRBTS-1/NRPLMN-2

@{PARAMS_ADJ_REL_FOR_GNB2}
...    NRBTS/NRADJGNB-1:administrativeState=Unlocked
...    NRBTS/NRADJGNB-1:gNbIdLength=22
...    NRBTS/NRADJGNB-1:gNodeBId=1
...    NRBTS/NRADJGNB-1:weightForIgnbCaSelection=1
...    NRBTS/NRADJGNB-1:xnLinkRef=1
...    NRBTS/NRADJGNB-1:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-1:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-11:cellDepType=SA
...    NRBTS/NRADJNRCELL-11:gNbId=1
...    NRBTS/NRADJNRCELL-11:gNbIdLength=22
...    NRBTS/NRADJNRCELL-11:lcrId=11
...    NRBTS/NRADJNRCELL-11:nrarfcn=364000
...    NRBTS/NRADJNRCELL-11:physCellId=60
...    NRBTS/NRADJNRCELL-11:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-11:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-11:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-11:freqBandIndicatorNR=3
...    NRBTS/NRADJNRCELL-11/ADJ_NRPLMNSET_SA-1:fiveGsTac=200
...    NRBTS/NRADJNRCELL-11/ADJ_NRPLMNSET_SA-1:nrPlmnDNList=MRBTS-1/NRBTS-2/NRPLMN-1,MRBTS-1/NRBTS-2/NRPLMN-2

@{PARAMS_FOR_OTHERS}
...    NRX2LINK_TRUST-1:ipV4Addr=10.0.1.137
...    NRBTS:actDynamicFirewall=true
...    NRBTS:iGnbCaXnCfUpBackOffTmr=60
...    NRBTS:iGnbCaXnSetupReqTmr=60
...    NRBTS:iGnbCaXnSetupRespTmr=60
...    NRBTS:intGnbScellTempBlockTmr=60

...    NRBTS:cipherPrefL:nea0=1
...    NRBTS:cipherPrefL:nea2_128=0
...    NRBTS:cipherPrefL:nea1_128=0
...    NRBTS:cipherPrefL:nea3_128=0
...    NRBTS:integrityProtPrefL:nia3_128=2
...    NRBTS:integrityProtPrefL:nia2_128=4
...    NRBTS:integrityProtPrefL:nia0=0
...    NRBTS:integrityProtPrefL:nia1_128=3
...    NRCELL:actCDrx=false
...    NRCELL:timingAdvanceOffset=n25600
...    NRCELL:cellDepType=SA+NSA
...    NRCELL:sCellDeactivationTimerGNB=infinity
...    NRCELL:a1MeasSCellAddEnabled=rsrp
...    NRCELL:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=90|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=70|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a2MeasSCellRelEnabled=rsrp
...    NRCELL:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=480ms
...    NRCELL:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=40|a2TimeToTriggerSCellRelSsbRsrp=480ms
...    NRBTS:actRanSharing=true

...    NRBTS:actNgcFlexSaMode=true
...    delete:NRCELL:trackingAreaDN
...    delete:NRCELL:configuredEpsTac
...    NRBTS:actTrsSepaSARanSharing=true
...    SERVEDAMF-1:ngTnlId=1
...    NRBTS:ngCplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1|ngTnlId=1
...    NRBTS/XNLINK-1:xnTnlId=1
...    NRBTS:xnCplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1|xnTnlId=1
...    NRBTS:actRrcInactState=intra-gNB
...    NRBTS:drbRrcInactInactivityTimerSA=20
...    NRBTS:drbInactivityTimerSA=60
...    NRBTS:srbInactivityTimerSA=30
...    NRBTS:maxUeRrcInactTime=60
...    NRBTS:rrcInactIMMSteeringEnabled=false
...    NRBTS:rrcInactLocationReportEnabled=false
...    NRBTS:rrcInactPreferredStateEnabled=false
...    NRBTS:outOfConnectedPreference=idle
...    NRBTS:t380=5min
...    NRBTS:actPaging=true
...    NRBTS:tRanPagingGuard=4
...    NRBTS:drxDefaultPaging=v256
...    NRBTS:ranPagingCycle=v32
...    NRBTS:act3gppBL23R1=true

@{GNB1_CA_rel}
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-1:gNbId=2
...    NRCELL-11/NRREL-1:gNbIdLength=22
...    NRCELL-11/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-1:lcrId=1
...    NRCELL-11/NRREL-1:removeNotAllowed=false
...    NRCELL-11/NRREL-1:sCellAdditionMethod=covBasedA1
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
...    NRCELL-11/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-12/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-1:gNbId=2
...    NRCELL-12/NRREL-1:gNbIdLength=22
...    NRCELL-12/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-12/NRREL-1:lcrId=1
...    NRCELL-12/NRREL-1:removeNotAllowed=false
...    NRCELL-12/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-12/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-12/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-2:gNbId=2
...    NRCELL-12/NRREL-2:gNbIdLength=22
...    NRCELL-12/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-12/NRREL-2:lcrId=2
...    NRCELL-12/NRREL-2:removeNotAllowed=false
...    NRCELL-12/NRREL-2:sCellAdditionMethod=blind
...    NRCELL-12/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-2:sCellOperationalMode=dlOnly

...    NRBTS:actBufferBasedSCellAddition=oneShot_Dl_Fr1
...    NRCELL:dlSCellConfigLevel=10
...    NRCELL:dlSCellConfigLevelNum=20
...    NRBTS:rrcInactPreferredStateEnabled=true
...    NRBTS:actRrcReleasePreference=true
...    NRBTS:timerReleasePreferenceProhibit=s5

${BufferMonitor_disable}
...    NRBTS:actBufferBasedSCellAddition=disabled

${BufferMonitor_enable}
...    NRBTS:actBufferBasedSCellAddition=oneShot_Dl_Fr1

@{releasePreference_check}
...     QoS Routing Table
...     releasePreference-r16 supported 

@{expect_for_CA_pcell11}
...    pcid:60
...    sCellIndex 1
...    sCellIndex 2
...    PhysCellId: 50
...    PhysCellId: 51 
...    rrcReconfigurationComplete

@{expect_for_CA_pcell12}
...    pcid:61
...    sCellIndex 1
...    sCellIndex 2
...    PhysCellId: 50
...    PhysCellId: 51 
...    rrcReconfigurationComplete

@{INACTIVE_check}
...    SuspendConfig
...    fullI_RNTI
...    shortI_RNTI
...    ran-AreaCodeList
...    t380
...    NR_RRC_INACTIVE

@{Resum_success}
...    rrcResumeRequest1
...    resumeCause mo-Data
...    rrcResume
...    pcid:60, scellIdx:0

@{PM_Counters_Check_E002}
...    NRCELL-11:${NRRCC_RRC_REL_WITH_SUSP_NRNAU}=1
...    NRCELL-11:${IGNB_CA_ATT_SA_REL}=1

@{PM_Counters_Check_E013_GNB1}
...    NRCELL-12:${IGNB_CA_ATT_SA_REL}=1
...    NRCELL-11:${IGNB_CA_ATT_SA_REL}=1
...    NRCELL-12:${NRRCC_RRC_REL_WITH_SUSP_NRNAU}=1
...    NRCELL-11:${NRRCC_RRC_RESUME_REQUEST1}=1
...    NRCELL-11:${NRRCC_RRC_RESUME_SUCC}=1
...    NRCELL-12:${GNB_DU_SCELL_2_ADMI_REQ_SA}=1
...    NRCELL-11:${GNB_DU_SCELL_2_ADMI_REQ_SA}=1
...    NRCELL-12:${GNB_DU_SCELL_2_ADMI_SUCC_SA}=1
...    NRCELL-11:${GNB_DU_SCELL_2_ADMI_SUCC_SA}=1
...    NRCELL-12:${IGNB_CA_ATT_2_SCELL_SA}=1
...    NRCELL-11:${IGNB_CA_ATT_2_SCELL_SA}=1
...    NRCELL-12:${IGNB_CA_ATT_2_SCELL_SA_SUCC}=1
...    NRCELL-11:${IGNB_CA_ATT_2_SCELL_SA_SUCC}=1

@{PM_Counters_Check_E013_GNB2}
...    NRCELL-1:${GNB_DU_SCELL_ADMI_REQ_SA}=2
...    NRCELL-2:${GNB_DU_SCELL_ADMI_REQ_SA}=2
...    NRCELL-1:${GNB_DU_SCELL_ADMI_SUCC_SA}=2
...    NRCELL-2:${GNB_DU_SCELL_ADMI_SUCC_SA}=2
...    NRCELL-1:${IGNB_CA_SCELL_ADMI_REQ_SA}=2
...    NRCELL-2:${IGNB_CA_SCELL_ADMI_REQ_SA}=2
...    NRCELL-1:${IGNB_CA_SCELL_ADMI_SUCC_SA}=2
...    NRCELL-2:${IGNB_CA_SCELL_ADMI_SUCC_SA}=2
...    NRBTS-1:${IGNB_CA_ADD_REQ_SA_NRADJ}=2

${NRRCC_RRC_REL_WITH_SUSP_NRNAU}    M55124C00006    #Number of RRC Releases with suspension for non-RNA update resume cause
${IGNB_CA_ATT_SA_REL}    M55118C11008    #Number of times Inter gNB CA is released
${NRRCC_RRC_RESUME_REQUEST1}    M55124C00007    #Number of RRC Resume Requests1 received at gNB-CU
${NRRCC_RRC_RESUME_SUCC}    M55124C00010    #Number of RRC Resume Successes at gNB-CU
${GNB_DU_SCELL_2_ADMI_REQ_SA}    M55139C01501    #Radio admission requests for 2 SCells in DU in SA mode
${GNB_DU_SCELL_2_ADMI_SUCC_SA}    M55139C01502    #Successful radio admissions for 2 SCell additions in DU in SA mode
${IGNB_CA_ATT_2_SCELL_SA}    M55118C11002    #Number of times two S-Cell Inter gNB CA addition attempted SA
${IGNB_CA_ATT_2_SCELL_SA_SUCC}    M55118C11002    #Number of times two S-Cell Inter gNB CA addition succeeded
${GNB_DU_SCELL_ADMI_REQ_SA}    M55139C01001    #Radio admission requests for the SCell in DU in SA mode
${GNB_DU_SCELL_ADMI_SUCC_SA}    M55139C01002    #Successful radio admissions for the SCell in DU in SA mode
${IGNB_CA_SCELL_ADMI_REQ_SA}    M55138C03501    #Number of radio admission requests for Inter gNB S-Cell setup
${IGNB_CA_SCELL_ADMI_SUCC_SA}    M55138C03502    #Number of successful radio admissions for Inter gNB S-Cell additions in SA mode
${IGNB_CA_ADD_REQ_SA_NRADJ}    M55175C00001    #Number of times Inter gNB CA addition requests in ext-gNB

${SA_Capa_UAI_Inactive}    SEPARATOR=
...    E9A09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C47013B8D80D81AC1184341020E9068036B64C558D0E7C471E81
...    9F604F8C48E3C873EA39F30C7942C0E070F05C00FFC0070005F0005C0000E0541B00B582308682041E20D00656C98AB121CFB027C471E31238F21CFA8E
...    7CC31E50B0381C3C27F6000001FD800000170000381546C4CD608C21A0810748340185B262A88873E238F11C7A067D813E31CF9863CA1607038782E007
...    FE003801FF8002E0000702A0D837AC1184341020F1068032B64C55890E7C471EC09F1891C790E7D473E618F28581C0E1E13FFE00000FFF800000B80001
...    C0AA3626EB04610D00000201A00C2D926544439F11C79063D033EC09F00E7CC31E50B0381C3C17AAAAAAA9EAAAAAAA17000038024B0F13000389800000
...    02C0AC5C4C000E26000713000000858158B80400184C0309800020B02B1F008003036061300C260000C2C0AC5C02000C010181B0002058158F80400180
...    60303606134000A160562E01000606C0C26000182C0AC3C02000C260001C2C0AC3C02000C01000202C0AC3C1B000C0D800242C0AC3C02000C03000282C
...    0AC3C06000C0D8002C2C0AC5C02000C030181B00060581587836001C4C00001A160562E2600061300C01000382C0AC7C4C000C260180203036000F0B02
...    B171300030040606C0020160563E2680060080C030181B00088581009006E003404C800501345D003A4250A244D8E7C38912244D8E7C38912244D8E7C3
...    8D1224489B1CF871224489B1CF871A2448913639F0E2448913639F0E14489B1CF870A244D8E7C3851226C73E1C28913639F0E14489B1CF871224489B1C
...    F870A244D8E7C38912244D8E7C38D1224489B1CF871224489B1CF871A2448913639F0C06C486318C6318C6318C6318C6307A0B800F000A070500703009
...    401C0018090010180F82400800000004002000000080000300400000802000008010000060080000400400002802001004010040000300200001C01000
...    8000000200002001000012008000030040000500200002C01000812048020000300CE54D654D60A5606560CD60AD652DE4CDE02D606D6025604560ED03
...    41000009652504000065949810000196524040000E594901000049652404000165949810000696524040001E594901000089652404000265949010000A
...    96524040002E5949410000C96524040000C594900CD2AABA55554AA2E95455058AA0B1541A2A94C55268AA031540A2A93555078A160178095028140A05
...    028140A05028140A05028140A050281400442020040080801002201002004040080101002004402018028080100202004008C04030050100C014040080
...    101002004402020028080800A0202C058C04030060100C014040300601002004402018028080600A020040084040300501002004202018028080600A10
...    100C018040300608080600C02018028404030050100C014402018028080600C020180284040300601002004402004008080100202018028C0400801010
...    0200404030050100C014402004008080600C02018030C04008010100C01404030060100C0146A87C0004080C10181C282C30344044484C5060646C7074
...    7C8494989CA0A4A8B4BD05064B5288000108

*** Test Cases ***
CB008225-ET-E002_Successful_transition_of_UE_in_RRC_CONNECTED_to_RRC_INACTIVE_Suspend_Cell_with_inter-gNB_MeasBased_CA_config
    [Documentation]
    ...    This case is to Verify gNB behavior for UE in RRC_CONNECTED state and configured with inter-gNB CA (SCells configured at gNB1 and gNB2)
    ...    that is successfully transitioned to RRC_INACTIVE state based on measbased CA.
    ...    [Configuration]:
    ...    Cell id=11 gnb=1 pci=20:0 tac=200 tdd_cell=off band=n3 nr_arfcn=364000:345000 chBw=15MHz 
    ...    Cell id=1 gnb=2 pci=16:2 tac=200 tdd_cell=on band=n77 nr_arfcn=663400:663400 chBw=100MHz 
    ...    Cell id=2 gnb=2 pci=17:0 tac=200 tdd_cell=on band=n77 nr_arfcn=658000:658000 chBw=40MHz 
    ...    cell 11 is on gnb1, cell1,2 are on gnb2. 
    ...    cell 1,2 are configured as scells of cell11.
    ...    2.Test Case Steps:
    ...         a. Set UE1 Core Network Assistance Information for RRC INACTIVE state in the Initial Context Setup Request. 
    ...            And trigger UE1 register to Cell1_11 with PDU 1 and slice 1, and setup PDU 2 with slice 2.
    ...            trigger A1 MR to setup CA,UE1 add Cell2_1 and Cell2_2 for inter gNB 3CC CA, start traffic.
    ...         C. Stop all traffic.Wait until parameter drbRrcInactInactivityTimerSA and srbInactivityTimerSA expire.
    ...            UE1 is released to RRC_INACTIVE state.
    [Tags]    QC_325689    owner-jia.pan    E002    CA_LABEL-FTT(15MHz_FDD_n3+100MHz_TDD_n77+40MHz_TDD_n77)
    Clear Counter Files    wait=${False}
    OnlineParamChange    ${BufferMonitor_disable}
    Sa Ue Attach With 2 PDUs
    Trigger A1MR For Scell Addition
    Send Throuput for both PDUs
    Wait Until Keyword Succeeds    30s    5s    Check Traffic
    Stop traffic for both PDUs to Trigger UE Release to INACTIVE State
    Release Ues    ue_type=all
    check counters    ${PM_Counters_Check_E002}
    [Teardown]    E002_Teardown

CB008225-ET-E013_Successful_transition_of_Suspended_UE_in_RRC_INACTIVE_to_RRC_CONNECTED_resume_to_Cell_with_inter-gNB_BFBased_MeasBased_CA_config
    [Documentation]
    ...    This case is to Verify gNB behavior for UE in RRC_CONNECTED state and configured with 
    ...    inter-gNB CA (SCells configured at gNB1 and gNB2) that is successfully transitioned
    ...    to RRC_INACTIVE state based on bufferBased CA.
    ...    [Configuration]:
    ...    Cell id=11 gnb=1 pci=20:0 tac=200 tdd_cell=off band=n3 nr_arfcn=364000:345000 chBw=15MHz 
    ...    Cell id=12 gnb=1 pci=20:1 tac=200 tdd_cell=off band=n3 nr_arfcn=374000:355000 chBw=15MHz 
    ...    Cell id=1 gnb=2 pci=16:2 tac=200 tdd_cell=on band=n77 nr_arfcn=663400:663400 chBw=100MHz 
    ...    Cell id=2 gnb=2 pci=17:0 tac=200 tdd_cell=on band=n77 nr_arfcn=658000:658000 chBw=40MHz 
    ...    cell 11,12 is on gnb1, cell1,2 are on gnb2. 
    ...    cell 1,2 are configured as scells of cell11 and cell12.
    ...    2.Test Case Steps:
    ...         a. Set UE1 Core Network Assistance Information for RRC INACTIVE state in the Initial Context Setup Request. 
    ...            And trigger UE1 register to Cell1_12 with PDU 1 and slice 1.
    ...         b. Trigger new PDU 2 with slice 2 and start traffic.trigger buffer overflow happens.
    ...            CA is setup,cell2_1 and cell2_2 are added as scells.
    ...         c. Trigger UEAssistanceInformation with ReleasePreference-r16=inactive
    ...            UE1 is released to RRC_INACTIVE state.
    ...         d.Trigger rrc resume to cell1_11,PDU session 1 and 2 are setup successfully.
    ...            A1 measurement is configured for SCell addition.
    ...         e.UE1 sends A1 MR for scell addition,UE1 PDU session 1 start low DL traffic, PDU session 2 start high DL traffic
    ...            trigger buffer overflow happens,CA is setup,cell2_1 and cell2_2 are added as scells.
    [Tags]    QC_325690    owner-jing.ye    E013    CA_LABEL-FTT(15MHz_FDD_n3+100MHz_TDD_n77+40MHz_TDD_n77)
    clear counter files
    Clear Counter Files GNB2    
    Sa Ue Attach with PDU1    ue_id=2    cell_id=12    UE_capa=${SA_Capa_UAI_Inactive}    pass_regexp=${releasePreference_check}
    Add new slice PDU and send traffic for E013 
    Trigger UEAssistanceInformation and RRC Resume
    Trigger A1MR For E013
    Send Low Throuput
    Send High Throuput to Trigger Scell addition
    Release Ues    ue_type=all
    check counters    ${PM_Counters_Check_E013_GNB1}
    Check Counters GNB2    ${PM_Counters_Check_E013_GNB2}

*** Keywords ***
Common Suite Setup And Setup 2Airphone Env
    Common Suite Setup
    Setup 2Airphone Env    fddtdd_sansa_cmwv/6cells_gnb1_2F_gnb2_2T2F

E002_Teardown
    OnlineParamChange    ${BufferMonitor_enable}
    Common Test Teardown And Stop Capture Logs

Update UE capa
    [Arguments]    ${SA_Capa_perUE_Full}=${SA_Capa_Support}    ${ue_id}=1
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full}
    Execute Egate Command    ${cmd}
	
Sa Ue Attach With 2 PDUs
    Sa Ue Attach with PDU1    ue_id=1    cell_id=11
    Add pdu2 with new slice

Sa Ue Attach with PDU1
    [Arguments]    ${ue_id}=1    ${cell_id}=11    ${UE_capa}=${CB008140_GG_Capa_2CC_3CC_4CC_n3_n28_n77_n78}    ${pass_regexp}=QoS Routing Table
    Update UE capa    ue_id=${ue_id}    SA_Capa_perUE_Full=${UE_capa} 
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    ${core_assis_info_1}    catenate    amf_ue_ics_param id=1 core_network_assistance_info=on ue_identity_index_value=1 ue_specific_drx=64
    ...    periodic_registration_update_timer=1:10min plmn_id=311:489 tac_id=200
    ${core_assis_info_2}    catenate    amf_ue_ics_param id=1 core_network_assistance_info=on ue_identity_index_value=1 ue_specific_drx=64
    ...    periodic_registration_update_timer=1:10min plmn_id=311:402 tac_id=200
    Execute Egate Command    ${core_assis_info_1}
    Execute Egate Command    ${core_assis_info_2}
    Execute Egate Command    ue_register id=${ue_id}    NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${ue_id}    ${pass_regexp}
	
Add pdu2 with new slice
    [Arguments]    ${ue_id}=1    ${nwslice_id}=2    ${pdu_id}=2  
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal	
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} nwslice=${nwslice_id} gw=${pdu_id}    QoS Routing Table

Trigger A1MR For Scell Addition
    [Arguments]    ${carrierfreq}=363850    ${ue_id}=1
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}    event_type=A1    carrierfreq=${carrierfreq}
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=100 srsrq_nr=100
    ...    pass_regexp=${expect_for_CA_pcell11}    timeout=20s
	
Trigger A1MR For E013
    [Arguments]    ${carrierfreq}=363850    ${ue_id}=2
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}    event_type=A1    carrierfreq=${carrierfreq}
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=100 srsrq_nr=100    fail_regexp=sCellIndex 1

Add new slice PDU and send traffic for E013
    [Arguments]    ${ue_id}=2
    Add pdu2 with new slice    ue_id=2
    Send Throughput to Trigger Scell Addition    ue_id=2    pdu=2
    Send Throughput    ue_id=2    times=3    pdu=1
    Wait Until Keyword Succeeds    30s    5s    Check Traffic    2
    Stop traffic for E013
	
Send Throughput to Trigger Scell Addition
    [Arguments]    ${ue_id}=2    ${pdu}=2
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=1 dir=dl mbps=150 trf_id=9    pass_regexp=${expect_for_CA_pcell12}
    ...    timeout=30s
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=1 dir=dl mbps=150 trf_id=10
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=1 dir=ul mbps=10 trf_id=16    UE ${ue_id}: UDP UL

Trigger UEAssistanceInformation and RRC Resume
    Execute Egate Command    ue_assistance_send_nr ue_id=2 PreferredRRCState=inactive    pass_regexp=${INACTIVE_check}
    sleep    2s    #sleep for inactive procedure complete
    Trigger RRC Resume    ue_id=2
	
Trigger RRC Resume
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_nr_rrc_resume_request_param id=${ue_id} gnb=2 cell=11 cause=mo_Data
    Execute Egate Command    ue_nr_rrc_resume id=${ue_id}    pass_regexp=${Resum_success}

Stop traffic for both PDUs to Trigger UE Release to INACTIVE State
    [Arguments]    ${ue_id}=1
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=1 qfi=1 dir=ul    UE${ue_id}: Stopping
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=1 qfi=1 dir=dl    UE ${ue_id}: DL Traffic was stopped
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=2 qfi=1 dir=ul    UE${ue_id}: Stopping
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=2 qfi=1 dir=dl    pass_regexp=${INACTIVE_check}    timeout=21s
    #srbInactivityTimerSA is timeout before drbRrcInactInactivityTimerSA, so case just need wait for drbRrcInactInactivityTimerSA timout here
    Sleep    1s    #UE in active state done

Stop traffic for E013
    [Arguments]    ${ue_id}=2
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=1 qfi=1 dir=ul    UE${ue_id}: Stopping
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=1 qfi=1 dir=dl    UE ${ue_id}: DL Traffic was stopped
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=2 qfi=1 dir=ul    UE${ue_id}: Stopping
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=2 qfi=1 dir=dl    UE ${ue_id}: DL Traffic was stopped
	
Modify Cfg
    Update Cfg    set_amf_region id=1 tac_list=0,200 plmn=311:489,311:402
    ${set_ue1}    catenate    set_ue simulated id=1 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...    nia=null+zuc nea=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0000:0:0:021645400 mode=nr enb=2 cell=11
    Update Cfg    ${set_ue1}
    Update Cfg    set_nwslice id=1 snssai=0x01:0xd143a5 default=on ue=all amf_region_id=1 plmn_list=311:489,311:402
    Update Cfg    set_nwslice id=2 snssai=0x01:0xFFFFFF ue=all amf_region_id=1 plmn_list=311:489,311:402
	
Send Throughput
    [Arguments]    ${ue_id}=1    ${times}=3    ${pdu}=1    ${mbps_dl}=150
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=1 dir=ul mbps=10 trf_id=1    UE ${ue_id}: UDP UL
    FOR    ${I}    IN RANGE    1    ${times}
        Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=1 dir=dl mbps=${mbps_dl} trf_id=${I}    UE ${ue_id}: UDP DL
    END

Send Low Throuput
    Send Throughput    ue_id=2    times=2    pdu=1    mbps_dl=10

Send Throuput for both PDUs
    Send Throughput    ue_id=1    times=3    pdu=1
    Send Throughput    ue_id=1    times=3    pdu=2

Send High Throuput to Trigger Scell addition
    [Arguments]    ${ue_id}=2    ${pass_regexp}=${expect_for_CA_pcell11}
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=2 qfi=1 dir=dl mbps=150 trf_id=9    pass_regexp=${pass_regexp}
    Send Throughput    ue_id=2    times=4    pdu=2
    Wait Until Keyword Succeeds    30s    5s    Check Traffic    2

Check Traffic
    [Arguments]     ${ue_id}=1    ${cell_num}=3    ${min_dl_tput}=480    ${min_ul_tput}=16
    ${dl_throuput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=ave
    ${ul_throuput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pusch    rate_type=ave
    ${total_dl_tput}    Set Variable    0
    FOR    ${index}    IN RANGE    0    ${cell_num}
         ${str_index}    Convert To String    ${index}
         ${scell_tput}    Ap Get Throuput On Specific Scell    ${ue_id}    ${str_index}    pdsch
         Should Be True    ${scell_tput}/1000 > 10
         ${total_dl_tput}    Evaluate    ${scell_tput}+${total_dl_tput}
    END
    Should Be True    ${total_dl_tput}/1000 > ${min_dl_tput}
    Should Be True    ${ul_throuput}/1000 > ${min_ul_tput}
	
OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir

