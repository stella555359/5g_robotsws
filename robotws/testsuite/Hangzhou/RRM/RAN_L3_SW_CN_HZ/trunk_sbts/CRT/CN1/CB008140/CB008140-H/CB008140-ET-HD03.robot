*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CLOUD_5G_I_[LO][LO]_AP_[LOO]_SANSA_FS_ECPRI_CMWV_TDD
...    team-ROCK    owner-jia.pan    release-SBTS23R3    CRT
Resource    ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
${NOKIA_XNAP_PLUGIN_FLAG}    ${True}
${NOKIA_F1AP_PLUGIN_FLAG}    ${True}

@{PARAMS_IN_SCF}
...    @{PARAMS_FOR_CA}
...    @{PARAMS_FOR_GNB1}
...    @{PARAMS_ADJ_REL_FOR_GNB1}
...    @{PARAMS_FOR_OTHERS}
...    @{GNB1_CA_rel_for_NRCELL_11}

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
...    NRBTS/NRCELL-11:maxNumScellsDlFr1=3
...    NRCELL-11:measGapSelectionSA=favourUeThroughput
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
...    MRBTS-1/NRBTS-1/SNSSAI-2:sd=13714342
...    MRBTS-1/NRBTS-1/SNSSAI-2:xgUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-3
...    MRBTS-1/NRBTS-1/SNSSAI-2:xgUplane:ipV6AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-3
...    delete:MRBTS-1/NRBTS-1/SNSSAI-2:drbInactivityTimerSA
...    TRACKINGAREA-200:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1
...    TRACKINGAREA-200:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2
...    MRBTS-1/NRBTS-1/NRPLMN-2:mcc=311
...    MRBTS-1/NRBTS-1/NRPLMN-2:mnc=402
...    MRBTS-1/NRBTS-1/NRPLMN-2:mncLength=3
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
...    MRBTS-1/NRBTS-2/SNSSAI-2:sd=13714342
...    MRBTS-1/NRBTS-2/SNSSAI-2:xgUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-3
...    MRBTS-1/NRBTS-2/SNSSAI-2:xgUplane:ipV6AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-3
...    delete:MRBTS-1/NRBTS-2/SNSSAI-2:drbInactivityTimerSA
...    MRBTS-1/NRBTS-2/TRACKINGAREA-200:snssaiList:snssaiDN=MRBTS-1/NRBTS-2/SNSSAI-1|snssaiDN=MRBTS-1/NRBTS-2/SNSSAI-1
...    MRBTS-1/NRBTS-2/TRACKINGAREA-200:snssaiList:snssaiDN=MRBTS-1/NRBTS-2/SNSSAI-2|snssaiDN=MRBTS-1/NRBTS-2/SNSSAI-2
...    MRBTS-1/NRBTS-2/NRPLMN-2:mcc=311
...    MRBTS-1/NRBTS-2/NRPLMN-2:mnc=402
...    MRBTS-1/NRBTS-2/NRPLMN-2:mncLength=3
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
...    NRBTS:iGnbCaXnSetupReqTmr=30
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

@{GNB1_CA_rel_for_NRCELL_11}
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
...    NRCELL-11/NRREL-14:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-14:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-14:gNbId=2
...    NRCELL-11/NRREL-14:gNbIdLength=22
...    NRCELL-11/NRREL-14:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-14:lcrId=14
...    NRCELL-11/NRREL-14:removeNotAllowed=false
...    NRCELL-11/NRREL-14:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-14:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-14:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-14:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-14:sCellOperationalMode=dlOnly

@{OnlineParam_XNLINK_LOCK_GNB1}
...    NRBTS/NRADJGNB-2:administrativeState=Locked

@{OnlineParam_XNLINK_UNLOCK_GNB1}
...    NRBTS/NRADJGNB-2:administrativeState=Unlocked

@{OnlineParam_XNLINK_DEL_NRADJ_GNB2}
...    delete:NRBTS/NRADJGNB-1

@{OnlineParam_DEL_NRREL_GNB1}
...    delete:NRCELL-11/NRREL-1
...    delete:NRCELL-11/NRREL-2
...    delete:NRCELL-11/NRREL-14

@{OnlineParam_NRDU_xgUplane_ipAddress_GNB1}
...    NRDU-1:xgUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-3|nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1
...    MRBTS-1/NRBTS-1/SNSSAI-2:xgUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-4
...    MRBTS-1/NRBTS-1/SNSSAI-2:xgUplane:ipV6AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-4

@{OnlineParam_NSSAI_xgUplane_ipAddress_GNB2}
...    MRBTS-1/NRBTS-2/SNSSAI-2:xgUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-4
...    MRBTS-1/NRBTS-2/SNSSAI-2:xgUplane:ipV6AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-4

@{OnlineParam_xnUplane_xgUplane_same_ipAddress_GNB1}
...    NRDU-1:xgUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1|nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1
...    MRBTS-1/NRBTS-1/SNSSAI-2:xgUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    delete:MRBTS-1/NRBTS-1/SNSSAI-2:xgUplane:ipV6AddressDN1

@{OnlineParam_xnUplane_xgUplane_same_ipAddress_GNB2}
...    NRDU-1:xgUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1|nrPlmnDN=MRBTS-1/NRBTS-2/NRPLMN-1
...    MRBTS-1/NRBTS-2/SNSSAI-2:xgUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    delete:MRBTS-1/NRBTS-2/SNSSAI-2:xgUplane:ipV6AddressDN1

@{expect_for_UE1}
...    pcid:60
...    sCellIndex 1
...    sCellIndex 2
...    sCellIndex 3
...    PhysCellId: 50
...    PhysCellId: 51 
...    PhysCellId: 63
...    rrcReconfigurationComplete

*** Test Cases ***
CB008140-ET-HD03_Verify remove firewall configuration for inter-gNB CA Xg-U traffic due to SCTP association failure for Xn-C link
    [Documentation]
    ...    This case is to Verify remove firewall configuration for inter-gNB CA Xg-U traffic due to SCTP association failure for Xn-C link
    ...    [Configuration]:
    ...    Cell id=11 gnb=1 pci=20:0 tac=200 tdd_cell=off band=n3 nr_arfcn=364000:345000 chBw=15MHz 
    ...    Cell id=1 gnb=2 pci=16:2 tac=200 tdd_cell=on band=n77 nr_arfcn=663400:663400 chBw=100MHz 
    ...    Cell id=2 gnb=2 pci=17:0 tac=200 tdd_cell=on band=n77 nr_arfcn=658000:658000 chBw=40MHz 
    ...    Cell id=14 gnb=2 pci=21:0 tac=200 tdd_cell=off band=n28 nr_arfcn=153400:143400 chBw=15MHz 
    ...    cell 11 is on gnb1, cell1,2,14 are on gnb2. 
    ...    cell 1,2,14 are configured as scells of cell11.
    ...    2.Test Case Steps:
    ...         a. UE1 register And PDU1 Slice1 session setup On NRCELL-11,trigger traffic.
    ...         b. Trigger scell addition A1 MR for UE1,CA F(CELL11)+T(CELL1)+T(CELL2)+F(CELL14) is setup,verify traffic.
    ...            Traffic is OK in pcell and scell,check FirewallOpenReq and FirewallOpenResp in gnb1 and gnb2 syslog
    ...         C. PDU2 Slice2 session setup,verify traffic.
    ...            Ttraffic is OK in pcell and scell,check FirewallOpenReq and FirewallOpenResp in gnb1 and gnb2 syslog
    ...         d. Trigger XNLINK failure then deregister UE and repeat steps a,b,c.
    ...            Check FirewallCloseReq and FirewallCloseResp in gnb1 and gnb2 syslog
    ...            Check traffic is OK in pcell and scell,check FirewallOpenReq and FirewallOpenResp in gnb1 and gnb2 syslog
    ...         e. Trigger NRREL delete then repeat steps a,b,c.
    ...            Check FirewallCloseReq and FirewallCloseResp in gnb1 and gnb2 syslog
    ...            Check traffic is OK in pcell and scell,check FirewallOpenReq and FirewallOpenResp in gnb1 and gnb2 syslog
    ...         f. Modify NRDU xgUplane ip address then deregister UE and repeat steps a,b,c.
    ...            Check FirewallCloseReq and FirewallCloseResp in gnb1 and gnb2 syslog for old Xg-U IP address
    ...            Traffic is OK in pcell and scell,check FirewallOpenReq and Resp in gnb1 and gnb2 syslog for new xg-u IP
    ...         g. Modify NSSAI xgUplane ip address then deregister UE,repeat steps a,b,c then deregister UE again.
    ...            Check FirewallCloseReq and FirewallCloseResp in gnb1 and gnb2 syslog for old Xg-U IP address
    ...            Traffic is OK in pcell and scell,check FirewallOpenReq and Resp in gnb1 and gnb2 syslog for new xg-u IP
    ...         h. Modify xnUplaneip and xgUplaneip to the same ipaddress,repeat steps a,b,c
    ...            Traffic is OK in pcell and scell,check FirewallOpenReq and FirewallOpenResp in gnb1 and gnb2 syslog
    ...         i. Trigger XNLINK failure then deregister UE and repeat steps a,b,c.
    ...            Check FirewallCloseReq and FirewallCloseResp in gnb1 and gnb2 syslog
    ...            Check traffic is OK in pcell and scell,check FirewallOpenReq and FirewallOpenResp in gnb1 and gnb2 syslog
    ...         j. Deregister UE.
	
    [Tags]    QC_277558    CA_LABEL-TTFF(100MHz_TDD_n77_n77+40MHz_TDD_n77+10MHz_FDD_n3+10MHz_FDD_n28)
    Sa Ue Attach 
    add pdu new slice 
    Xnfailureandrecover	
    NRRELdelandrecover
    ModifyNRDUxgUplaneipAddress
    ModifyNSSAIxgUplaneipAddress
    Xnfailureandrecoverwithsameip
    UE Deregister From gNB
	
*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup 2Airphone Env    fddtdd_sansa_cmwv/6cells_gnb1_2F_gnb2_2T2F

Xnfailureandrecover
    Delta Commission Parameters    ${OnlineParam_XNLINK_LOCK_GNB1}
    Cells Should Be onair
    Delta Commission Parameters    ${OnlineParam_XNLINK_UNLOCK_GNB1}
    Cells Should Be onair
    UE Deregister From gNB
    Sa Ue Attach 
    add pdu new slice

NRRELdelandrecover
    Delta Commission Parameters    ${OnlineParam_DEL_NRREL_GNB1}
    Cells Should Be onair
    Delta Commission Parameters    ${GNB1_CA_rel_for_NRCELL_11}
    Cells Should Be onair
    Sa Ue Attach 
    add pdu new slice

ModifyNRDUxgUplaneipAddress 
    Delta Commission Parameters    ${OnlineParam_NRDU_xgUplane_ipAddress_GNB1}
    Cells Should Be onair
    UE Deregister From gNB 
    Sa Ue Attach 
    add pdu new slice
	
ModifyNSSAIxgUplaneipAddress
    Delta Commission Parameters GNB2    ${OnlineParam_NSSAI_xgUplane_ipAddress_GNB2}
    Cells Should Be onair
    UE Deregister From gNB 
    Sa Ue Attach 
    add pdu new slice
    UE Deregister From gNB

Xnfailureandrecoverwithsameip
    XnUplanexgUplanesameip
    Sa Ue Attach 
    add pdu new slice 
    Delta Commission Parameters GNB2    ${OnlineParam_XNLINK_DEL_NRADJ_GNB2}
    Cells Should Be onair
    Delta Commission Parameters GNB2    ${PARAMS_ADJ_REL_FOR_GNB2}
    Cells Should Be onair
    UE Deregister From gNB
    Sa Ue Attach 
    add pdu new slice

XnUplanexgUplanesameip
    Delta Commission Parameters    ${OnlineParam_xnUplane_xgUplane_same_ipAddress_GNB1}
    Delta Commission Parameters GNB2    ${OnlineParam_xnUplane_xgUplane_same_ipAddress_GNB2}
    Cells Should Be onair

Update UE capa
    [Arguments]    ${SA_Capa_perUE_Full}=${SA_Capa_Support}    ${ue_id}=1
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full}
    Execute Egate Command    ${cmd}

Sa Ue Attach
    [Arguments]    ${ue_id}=1    ${gateway}=1    ${enb_id}=2    ${cell_id}=11
    ...    ${pass_regexp}=NG RM Register
    Update UE capa    ue_id=${ue_id}    SA_Capa_perUE_Full=${CB008140_GG_Capa_2CC_3CC_4CC_n3_n28_n77_n78}  
    Execute Egate Command    ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    ${pass_regexp}
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${gateway}    QoS Routing Table
    Trigger A1MR

Trigger A1MR
    [Arguments]    ${carrierfreq}=363850    ${ue_id}=1
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=A1    carrierfreq=${carrierfreq}
    Send Throuput
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=100 srsrq_nr=100
    ...    pass_regexp=${expect_for_UE1}    timeout=20s
    Wait Until Keyword Succeeds    60s    10s    Verify Throuput 4CC on Pscell and Scell

add pdu new slice
    [Arguments]    ${ue_id}=1    ${gateway}=1    ${nwslice_id}=2    ${pdu_id}=2  
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal	
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} nwslice=${nwslice_id} gw=${gateway}    QoS Routing Table
    Send Throuput for PDU2
    Wait Until Keyword Succeeds    60s    10s    Verify Throuput 4CC on Pscell and Scell    1    60    200    100    60  

UE Deregister From gNB
    [Arguments]    ${ue_id}=1
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=1    Traffic was stopped
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=2    Traffic was stopped
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s
	
Modify Cfg
    Update Cfg    set_amf_region id=1 tac_list=0,200 plmn=311:489,311:402
    ${set_ue1}    catenate    set_ue simulated id=1 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...    nia=null+zuc nea=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0000:0:0:021645400 mode=nr enb=2 cell=11
    Update Cfg    ${set_ue1}
    Update Cfg    set_nwslice id=1 snssai=0x01:0xd143a5 default=on ue=all amf_region_id=1 plmn_list=311:489,311:402
    Update Cfg    set_nwslice id=2 snssai=0x01:0xd143a6 ue=all amf_region_id=1 plmn_list=311:489,311:402

Send Throuput
    [Arguments]    ${ue_id}=1    
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=3    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=4    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=ul mbps=50 trf_id=1    UE ${ue_id}: UDP UL
    sleep    10s    #sleep for stable traffic

Send Throuput for PDU2
    [Arguments]    ${ue_id}=1    
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=2 qfi=1 dir=dl mbps=150 trf_id=9    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=2 qfi=1 dir=dl mbps=150 trf_id=10    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=2 qfi=1 dir=dl mbps=150 trf_id=11    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=2 qfi=1 dir=ul mbps=50 trf_id=16    UE ${ue_id}: UDP UL
    sleep    10s    #sleep for stable traffic

Verify Throuput 4CC on Pscell and Scell
    [Arguments]    ${ue_id}=1    ${pcell_dl}=30    ${scell_dl1}=100    ${scell_dl2}=50    ${scell_dl3}=30    ${ul}=5    
    ...    ${scell_id1}=1    ${scell_id2}=2    ${scell_id3}=3
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000 > ${pcell_dl}
    ${scell_tput1}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${scell_id1}    type=pdsch    rate_type=ave
    Should Be True    ${scell_tput1}/1000 > ${scell_dl1}
    ${scell_tput2}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${scell_id2}    type=pdsch    rate_type=ave
    Should Be True    ${scell_tput2}/1000 > ${scell_dl2}
    ${scell_tput3}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${scell_id3}    type=pdsch    rate_type=ave
    Should Be True    ${scell_tput3}/1000 > ${scell_dl3}
    ${ul_throughput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pusch    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul}
