*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CLOUD_5G_I_[LO][LO]_AP_[LOO]    team-VRF-07
...    owner-zhubaijie    release-SBTS25R1    CRT
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
...    NRBTS:weightForIgnbCaSelection=30
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
...    NRCELL:weightForSCellSelection=50
...    NRDU-1:xgUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRCELL:a1MeasSCellAddEnabled=rsrpAndRsrq
...    NRCELL:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=31
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=111
...    NRCELL:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrq:a1HysteresisSCellAddSsbRsrq=0
...    NRCELL:a1MeasSCellAddSsbRsrq:a1ThresholdSCellAddSsbRsrq=30
...    NRCELL:a1MeasSCellAddSsbRsrq:a1TimeToTriggerSCellAddSsbRsrq=160ms
...    NRCELL:a2MeasSCellRelEnabled=rsrp
...    NRCELL:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0
...    NRCELL:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=35
...    NRCELL:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=0ms

@{PARAMS_ADJ_REL_FOR_GNB1}
...    NRBTS/XNLINK-4:cPlaneIpAddr=10.0.1.129
...    MNL-1/MNLENT-1/XPAP-1/XPIF-1/XPIFREMOTE-4:ipAddress=10.0.1.129
...    MNL-1/MNLENT-1/XPAP-1/XPIF-1/XPIFREMOTE-4:remoteNeType=GNB
...    NRBTS/NRADJGNB-5:administrativeState=Unlocked
...    NRBTS/NRADJGNB-5:gNbIdLength=22
...    NRBTS/NRADJGNB-5:gNodeBId=33
...    NRBTS/NRADJGNB-5:weightForIgnbCaSelection=20
...    NRBTS/NRADJGNB-5:xnLinkRef=4
...    NRBTS/NRADJGNB-5:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-5:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-5:gnbPlmn:mncLength=3

...    NRBTS/XNLINK-3:cPlaneIpAddr=10.0.1.127
...    MNL-1/MNLENT-1/XPAP-1/XPIF-1/XPIFREMOTE-3:ipAddress=10.0.1.127
...    MNL-1/MNLENT-1/XPAP-1/XPIF-1/XPIFREMOTE-3:remoteNeType=GNB
...    NRBTS/NRADJGNB-4:administrativeState=Unlocked
...    NRBTS/NRADJGNB-4:gNbIdLength=22
...    NRBTS/NRADJGNB-4:gNodeBId=34
...    NRBTS/NRADJGNB-4:weightForIgnbCaSelection=20
...    NRBTS/NRADJGNB-4:xnLinkRef=3
...    NRBTS/NRADJGNB-4:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-4:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-4:gnbPlmn:mncLength=3


...    NRBTS/NRADJGNB-2:administrativeState=Unlocked
...    NRBTS/NRADJGNB-2:gNbIdLength=22
...    NRBTS/NRADJGNB-2:gNodeBId=2
...    NRBTS/NRADJGNB-2:weightForIgnbCaSelection=50
...    NRBTS/NRADJGNB-2:xnLinkRef=1
...    NRBTS/NRADJGNB-2:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-2:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-2:gnbPlmn:mncLength=3

...    NRBTS/XNLINK-2:cPlaneIpAddr=10.0.1.124
...    MNL-1/MNLENT-1/XPAP-1/XPIF-1/XPIFREMOTE-2:ipAddress=10.0.1.124
...    MNL-1/MNLENT-1/XPAP-1/XPIF-1/XPIFREMOTE-2:remoteNeType=GNB
...    NRBTS/NRADJGNB-3:administrativeState=Unlocked
...    NRBTS/NRADJGNB-3:gNbIdLength=22
...    NRBTS/NRADJGNB-3:gNodeBId=35
...    NRBTS/NRADJGNB-3:weightForIgnbCaSelection=20
...    NRBTS/NRADJGNB-3:xnLinkRef=2
...    NRBTS/NRADJGNB-3:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-3:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-3:gnbPlmn:mncLength=3

...    NRBTS/NRADJNRCELL-11:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-11:fiveGsTac=200
...    NRBTS/NRADJNRCELL-11:freqBandIndicatorNR=3
...    NRBTS/NRADJNRCELL-11:gNbId=2
...    NRBTS/NRADJNRCELL-11:gNbIdLength=22
...    NRBTS/NRADJNRCELL-11:lcrId=11
...    NRBTS/NRADJNRCELL-11:nrarfcn=368400
...    NRBTS/NRADJNRCELL-11:physCellId=60
...    NRBTS/NRADJNRCELL-11:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-11:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-11:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-12:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-12:fiveGsTac=200
...    NRBTS/NRADJNRCELL-12:freqBandIndicatorNR=28
...    NRBTS/NRADJNRCELL-12:gNbId=2
...    NRBTS/NRADJNRCELL-12:gNbIdLength=22
...    NRBTS/NRADJNRCELL-12:lcrId=12
...    NRBTS/NRADJNRCELL-12:nrarfcn=153400
...    NRBTS/NRADJNRCELL-12:physCellId=61
...    NRBTS/NRADJNRCELL-12:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-12:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-12:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-2:gNbId=1
...    NRCELL-1/NRREL-2:gNbIdLength=22
...    NRCELL-1/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-2:lcrId=2
...    NRCELL-1/NRREL-2:removeNotAllowed=false
...    NRCELL-1/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-11:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-11:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-11:gNbId=2
...    NRCELL-1/NRREL-11:gNbIdLength=22
...    NRCELL-1/NRREL-11:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-11:lcrId=11
...    NRCELL-1/NRREL-11:removeNotAllowed=false
...    NRCELL-1/NRREL-11:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-11:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-11:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-11:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-11:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-12:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-12:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-12:gNbId=2
...    NRCELL-1/NRREL-12:gNbIdLength=22
...    NRCELL-1/NRREL-12:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-12:lcrId=12
...    NRCELL-1/NRREL-12:removeNotAllowed=false
...    NRCELL-1/NRREL-12:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-12:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-12:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-12:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-12:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-5:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-5:fiveGsTac=200
...    NRBTS/NRADJNRCELL-5:gNbId=35
...    NRBTS/NRADJNRCELL-5:gNbIdLength=22
...    NRBTS/NRADJNRCELL-5:lcrId=5
...    NRBTS/NRADJNRCELL-5:nrarfcn=648000
...    NRBTS/NRADJNRCELL-5:physCellId=54
...    NRBTS/NRADJNRCELL-5:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-5:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-5:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-5:freqBandIndicatorNR=77
...    NRBTS/NRADJNRCELL-13:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-13:fiveGsTac=200
...    NRBTS/NRADJNRCELL-13:gNbId=35
...    NRBTS/NRADJNRCELL-13:gNbIdLength=22
...    NRBTS/NRADJNRCELL-13:lcrId=13
...    NRBTS/NRADJNRCELL-13:nrarfcn=368400
...    NRBTS/NRADJNRCELL-13:physCellId=63
...    NRBTS/NRADJNRCELL-13:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-13:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-13:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-13:freqBandIndicatorNR=3
...    NRBTS/NRADJNRCELL-14:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-14:fiveGsTac=200
...    NRBTS/NRADJNRCELL-14:gNbId=35
...    NRBTS/NRADJNRCELL-14:gNbIdLength=22
...    NRBTS/NRADJNRCELL-14:lcrId=14
...    NRBTS/NRADJNRCELL-14:nrarfcn=153400
...    NRBTS/NRADJNRCELL-14:physCellId=64
...    NRBTS/NRADJNRCELL-14:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-14:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-14:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-14:freqBandIndicatorNR=28

...    NRBTS/NRADJNRCELL-15:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-15:fiveGsTac=200
...    NRBTS/NRADJNRCELL-15:gNbId=34
...    NRBTS/NRADJNRCELL-15:gNbIdLength=22
...    NRBTS/NRADJNRCELL-15:lcrId=1
...    NRBTS/NRADJNRCELL-15:nrarfcn=636666
...    NRBTS/NRADJNRCELL-15:physCellId=152
...    NRBTS/NRADJNRCELL-15:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-15:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-15:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-15:freqBandIndicatorNR=77

...    NRBTS/NRADJNRCELL-16:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-16:fiveGsTac=200
...    NRBTS/NRADJNRCELL-16:gNbId=33
...    NRBTS/NRADJNRCELL-16:gNbIdLength=22
...    NRBTS/NRADJNRCELL-16:lcrId=1
...    NRBTS/NRADJNRCELL-16:nrarfcn=636666
...    NRBTS/NRADJNRCELL-16:physCellId=153
...    NRBTS/NRADJNRCELL-16:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-16:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-16:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-16:freqBandIndicatorNR=77

...    NRCELL-2/NRREL-5:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-5:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-5:gNbId=35
...    NRCELL-2/NRREL-5:gNbIdLength=22
...    NRCELL-2/NRREL-5:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-5:lcrId=5
...    NRCELL-2/NRREL-5:removeNotAllowed=false
...    NRCELL-2/NRREL-5:sCellAdditionMethod=blind
...    NRCELL-2/NRREL-5:sCellOperationalMode=dlOnly
...    NRCELL-2/NRREL-5:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-5:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-5:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-13:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-13:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-13:gNbId=35
...    NRCELL-2/NRREL-13:gNbIdLength=22
...    NRCELL-2/NRREL-13:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-13:lcrId=13
...    NRCELL-2/NRREL-13:removeNotAllowed=false
...    NRCELL-2/NRREL-13:sCellAdditionMethod=blind
...    NRCELL-2/NRREL-13:sCellOperationalMode=dlOnly
...    NRCELL-2/NRREL-13:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-13:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-13:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-14:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-14:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-14:gNbId=35
...    NRCELL-2/NRREL-14:gNbIdLength=22
...    NRCELL-2/NRREL-14:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-14:lcrId=14
...    NRCELL-2/NRREL-14:removeNotAllowed=false
...    NRCELL-2/NRREL-14:sCellAdditionMethod=blind
...    NRCELL-2/NRREL-14:sCellOperationalMode=dlOnly
...    NRCELL-2/NRREL-14:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-14:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-14:gnbPlmn:mncLength=3

...    NRCELL-2/NRREL-15:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-15:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-15:gNbId=34
...    NRCELL-2/NRREL-15:gNbIdLength=22
...    NRCELL-2/NRREL-15:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-15:lcrId=1
...    NRCELL-2/NRREL-15:removeNotAllowed=false
...    NRCELL-2/NRREL-15:sCellAdditionMethod=blind
...    NRCELL-2/NRREL-15:sCellOperationalMode=dlOnly
...    NRCELL-2/NRREL-15:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-15:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-15:gnbPlmn:mncLength=3

...    NRCELL-2/NRREL-16:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-16:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-16:gNbId=33
...    NRCELL-2/NRREL-16:gNbIdLength=22
...    NRCELL-2/NRREL-16:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-16:lcrId=1
...    NRCELL-2/NRREL-16:removeNotAllowed=false
...    NRCELL-2/NRREL-16:sCellAdditionMethod=blind
...    NRCELL-2/NRREL-16:sCellOperationalMode=dlOnly
...    NRCELL-2/NRREL-16:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-16:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-16:gnbPlmn:mncLength=3

@{PARAMS_FOR_GNB2}
...    NRBTS:iGnbCaXnCfUpBackOffTmr=60
...    NRBTS:iGnbCaXnSetupReqTmr=60
...    NRBTS:iGnbCaXnSetupRespTmr=60
...    NRBTS:intGnbScellTempBlockTmr=60
...    NRCELL:sCellDeactivationTimerGNB=infinity
...    NRCELL:weightForSCellSelection=50
...    NRDU-1:xgUplane:ipV4AddressDN1=MRBTS-2/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRCELL-11:a1MeasSCellAddEnabled=rsrpAndRsrq
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=31
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=111
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-11:a1MeasSCellAddSsbRsrq:a1HysteresisSCellAddSsbRsrq=0
...    NRCELL-11:a1MeasSCellAddSsbRsrq:a1ThresholdSCellAddSsbRsrq=30
...    NRCELL-11:a1MeasSCellAddSsbRsrq:a1TimeToTriggerSCellAddSsbRsrq=160ms
...    NRCELL:a2MeasSCellRelEnabled=rsrp
...    NRCELL:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0
...    NRCELL:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=35
...    NRCELL:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=0ms

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
...    NRBTS/NRADJNRCELL-1:fiveGsTac=200
...    NRBTS/NRADJNRCELL-1:freqBandIndicatorNR=77
...    NRBTS/NRADJNRCELL-1:gNbId=1
...    NRBTS/NRADJNRCELL-1:gNbIdLength=22
...    NRBTS/NRADJNRCELL-1:lcrId=1
...    NRBTS/NRADJNRCELL-1:nrarfcn=663400
...    NRBTS/NRADJNRCELL-1:physCellId=50
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-2:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-2:fiveGsTac=200
...    NRBTS/NRADJNRCELL-2:freqBandIndicatorNR=77
...    NRBTS/NRADJNRCELL-2:gNbId=1
...    NRBTS/NRADJNRCELL-2:gNbIdLength=22
...    NRBTS/NRADJNRCELL-2:lcrId=2
...    NRBTS/NRADJNRCELL-2:nrarfcn=658000
...    NRBTS/NRADJNRCELL-2:physCellId=51
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-1:gNbId=1
...    NRCELL-11/NRREL-1:gNbIdLength=22
...    NRCELL-11/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-1:lcrId=1
...    NRCELL-11/NRREL-1:removeNotAllowed=false
...    NRCELL-11/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-2:gNbId=1
...    NRCELL-11/NRREL-2:gNbIdLength=22
...    NRCELL-11/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-2:lcrId=2
...    NRCELL-11/NRREL-2:removeNotAllowed=false
...    NRCELL-11/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-2:gnbPlmn:mncLength=3

@{PARAMS_FOR_OTHERS}

...    NRBTS:actNgcFlexSaMode=true
...    NRBTS:ngInducedCellDeactDelayTimer=60
...    NRCELL:actCDrx=false

${DU-to-CU-RRCInfo}    SEPARATOR=
...    100200c0000100c1400302000f00c240020100

${ExtDu-to-PrimeDu-RrcInfo}    SEPARATOR=
...    0254042880b46063186ad278e800984ef240000134b19501a82929c028806d00d6021b00842a03a0093f0c184651c32cc00ca8048fffff800
...    00008001d0821b90218000140b2902025100350200240400498118140d86a4330190c6562f88e54140198aa88008c006097500151e86b6007
...    02010c4002a3d0d68000b81808a200151e86b40005c100431000a8f435a0102e0a0228800547a1ad008104000001430c080c1016070570015
...    2c00000000400800301200cc17000c02000004c8009e34038a340401000202200004c8009e3403880800000010580000070bfffd1020a80a3
...    61631078d167cb80042cdb40000019b193e8a81d29c028806b010a02190a20860c23286d9220064401b90018000080b29020251003c020024
...    0400498118140d484362194088512f08e54140188aa88008c00609d5000708879400e0402188001c221e38005c0c045100038443c7000b820
...    0862000708878e08170501144000e110f1c1020800000286181018202c0e0ba000e5000000001002000c04803305c003010000000280059f1
...    0082320400000000002800554d80800800000013d0050a51451e52853253c5463857ffd1040a080a36263107ad095c68036128d5000002731
...    9448a81d29c028806b010a02190a20860c2328a79420064401b90018000080b29020251003d0200240400498118140d484362194088512f08
...    e54140188aa88008c00609d5000e0487b400e04021880038121eb8005c0c045100070243d7000b8200862000e0487ae08170501144001c090
...    f5c1020800000286181018202c0e0ba001c5000000001002000c04803305c003018000001b8002573810232040000000001b8002302810008
...    00000013d0050a51451e52853253c546383ffe0

@{UE1_expect}
...    pcid:60, scellIdx:1
...    pcid:61, scellIdx:2
...    SCellIndex 1 activated successfully at airphone
...    SCellIndex 2 activated successfully at airphone

@{UE2_expect}
...    pcid:50, scellIdx:1
...    pcid:51, scellIdx:2
...    SCellIndex 1 activated successfully at airphone
...    SCellIndex 2 activated successfully at airphone

@{UE3_expect}
...    sCellIndex 1
...    sCellIndex 2
...    sCellIndex 3

@{online_modify_delete_NRREL_of_Cell2}
...    delete:MRBTS-1/NRBTS-1/NRCELL-2/NRREL-5
...    delete:MRBTS-1/NRBTS-1/NRCELL-2/NRREL-6
...    delete:MRBTS-1/NRBTS-1/NRCELL-2/NRREL-13
...    delete:MRBTS-1/NRBTS-1/NRCELL-2/NRREL-14
...    delete:MRBTS-1/NRBTS-1/NRCELL-2/NRREL-15
...    delete:MRBTS-1/NRBTS-1/NRCELL-2/NRREL-16

...    delete:MRBTS-1/NRBTS-1/NRCELL-1/NRREL-2
...    delete:MRBTS-1/NRBTS-1/NRCELL-1/NRREL-11
...    delete:MRBTS-1/NRBTS-1/NRCELL-1/NRREL-12

@{FAULTS_EXCLUDED_CHECKING}
...    7107    7308    7305    7311    62003

*** Test Cases ***
CNI105155-ET-A002_Verify XP link deletion with the same or different Global GNB id for the xp removal request
    [Documentation]
    ...    The purpose of this test case is to verify The purpose of this test case is to check following scenarios:
    ...    This user scenario is to verify XP link addition with the same or different Global GNB id for the xp removal request.
    ...    And verify the xp action when cut and recover the F1 link.(XP doesn't be cut when F1's down)
    ...    Requirement Coverage:
    ...    5G_CP_ARC_ALG_14099, fully covered
    [Tags]    QC_102619
    Setup XPAP Link
    Set Sim gNB ignb CA Addition Param
    SA UE1 And UE2 Register And Trigger Inter-gNB CA By A1
    UE3 Register And PDU Session Setup With Blind 2 Scells Addition
    Delta Commission To delete NRREL
    F1 down and up Test

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup 2Airphone Env    fddtdd_sansa_cmwv/6cells_gnb1_2T_gnb2_2T2F    ue_count=3

Modify Cfg
    Update Cfg    sim_trace enb=4 protocol=xp,xn,xpu on
    Update Cfg    sim_trace enb=5 protocol=xp,xn,xpu on
    Update Cfg    sim_trace enb=6 protocol=xp,xn,xpu on
	Update Cfg    set GNB5_NG_ADDR="10.0.1.126"
	Update Cfg    set GNB5_XN_ADDR="10.0.1.127"
	Update Cfg    set GNB6_NG_ADDR="10.0.1.128"
	Update Cfg    set GNB6_XN_ADDR="10.0.1.129"
	Update Cfg    set PROXY_SERVER4_IP="10.0.2.93"
	Update Cfg    set PROXY_SERVER4_IP="10.0.2.94"
	#sim gnb4
    ${gNB4_sim_configuration}    catenate
    ...    set_gnb id=4 type=simulated plmn=311:489 ng=10.0.1.125 gnb_id=0x23:22 daemon=10.0.2.1:22222 x2_peers=none xn=10.0.1.124
    ...    nssai=0x1:0xd143a5 amf=1 xp=10.0.1.124:32742 xpu=10.0.1.124:32742 xp_management=on
    Update Cfg    ${gNB4_sim_configuration}
    ${gNB4_Cell5_sim_configuration}    catenate
    ...    set_cell id=5 gnb=4 pci=18:0 tac=200 nrci=0x05 tdd_cell=on proxy=10.0.2.90:9999 nr_arfcn=648000:648000 gscn=8000
    ...    nr_scs=30kHz bs_channel_bandwidth=40MHz
    Update Cfg    ${gNB4_Cell5_sim_configuration}
    ${gNB4_Cell13_sim_configuration}    catenate
    ...    set_cell id=13 gnb=4 pci=21:0 tac=200 nrci=0x0d tdd_cell=off proxy=10.0.2.91:9999 nr_arfcn=349400:368400 gscn=4605
    ...    nr_scs=15kHz bs_channel_bandwidth=10MHz mandatory_for_activation=off
    Update Cfg    ${gNB4_Cell13_sim_configuration}
    ${gNB4_Cell14_sim_configuration}    catenate
    ...    set_cell id=14 gnb=4 pci=21:1 tac=200 nrci=0x0e tdd_cell=off proxy=10.0.2.92:9999 nr_arfcn=143400:153400 gscn=1916
    ...    nr_scs=15kHz bs_channel_bandwidth=15MHz mandatory_for_activation=off
    Update Cfg    ${gNB4_Cell14_sim_configuration}
	#sim gnb5
    ${set_gnb5}    catenate    set_gnb id=5 type=simulated plmn=311:489 ng=10.0.1.126 gnb_id=0x22:22 daemon=10.0.2.1:22222
    ...    x2_peers=none xn=10.0.1.127 nssai=0x1:0xd143a5 amf=1
    ...    xp=10.0.1.127:32742 xpu=10.0.1.127:32742 xp_management=on
    ${set_gnb5_cell1}    catenate    set_cell id=1 gnb=5 pci=50:2 tac=0 nrci=0x01 tdd_cell=on proxy=10.0.2.93:9999 nr_arfcn=636666:636666
    ...    gscn=7880 mandatory_for_activation=off
    Update Cfg    ${set_gnb5}
    Update Cfg    ${set_gnb5_cell1}
#    Update Cfg    gnb_param id=5 xn_listening_socket=on send_xn_setup=true
	#sim gnb6
    ${set_gnb6}    catenate    set_gnb id=6 type=simulated plmn=311:489 ng=10.0.1.128 gnb_id=0x21:22 daemon=10.0.2.1:22222
    ...    x2_peers=none xn=10.0.1.129 nssai=0x1:0xd143a5 amf=1
    ...    xp=10.0.1.129:32742 xpu=10.0.1.129:32742 xp_management=on
    ${set_gnb6_cell1}    catenate    set_cell id=1 gnb=6 pci=51:0 tac=0 nrci=0x01 tdd_cell=on proxy=10.0.2.94:9999 nr_arfcn=636666:636666
    ...    gscn=7880 mandatory_for_activation=off
    Update Cfg    ${set_gnb6}
    Update Cfg    ${set_gnb6_cell1}

Perform Steps After Onair
    Get Correct Xp XgU Version

Get Correct Xp XgU Version
    ${IgNBCAXpProtocol_Version}    Get Xp Version
    ${IgNBCAXgUProtocol_Version}    Get Xgu Version
    Set Suite Variable    ${IgNBCAXpVersion}    ${IgNBCAXpProtocol_Version}
    Set Suite Variable    ${IgNBCAXgUVersion}    ${IgNBCAXgUProtocol_Version}

Setup XPAP Link
    Execute Egate Command    enb_xp_param xp_peers=2 id=4,5,6
    Wait Until Keyword Succeeds    120s    20s    Object Should Exist
    ...    MRBTS-1/MNL-1/MNLENT-1/XPAP-1/XPIF-1/XPIFREMOTE_R-1:xpLinkStatus=available

Set Sim gNB ignb CA Addition Param
    ${gNB4_param}    catenate
    ...    gnb_param id=4 bwp_profile_id=1 bwp_profile_type=powersaving act_multiple_dedicated_bwps=yes location_bw_ul=1:2 location_bw_dl=3:4
    ...    Inter_gNB_CA_Allowed=yes CellLoadReportingPeriodicity=000
    ...    IgNBCAXpProtocolVersion=${IgNBCAXpVersion} IgNBCAXgUProtocolVersion=${IgNBCAXgUVersion}
    Execute Egate Command    ${gNB4_param}
    ${gNB4_cell_param}    Set Variable    Cell_BWP_List=1,2 cell_Available=yes weightForSCellSelection=40 lteNrDssMode=lteNrDssModeNone
    Execute Egate Command    gnb_cell_param gnb=4 id=5 ${gNB4_cell_param}
    Execute Egate Command    gnb_cell_param gnb=4 id=13 ${gNB4_cell_param}
    Execute Egate Command    gnb_cell_param gnb=4 id=14 ${gNB4_cell_param}
    Execute Egate Command    ignb_ca_configuration_update_indication_send id=4 target=2    IgNBCAConfigurationUpdateIndication
    ${gNB4_ca_param}    catenate    ignb_ca_addition_param gnb_id=4 DU-to-CU-RRCInfo=${DU-to-CU-RRCInfo}
    ...    ExtDu-to-PrimeDu-RrcInfo=${ExtDu-to-PrimeDu-RrcInfo}
    Execute Egate Command    ${gNB4_ca_param}

SA UE1 And UE2 Register And Trigger Inter-gNB CA By A1
    UE Register And Setup PDU Session    ue_id=1
    UE1 Send A1 To Trigger Scell Addition
    Run Traffic And Verify Throughput
    UE Register And Setup PDU Session    ue_id=2    gateway=2    enb_id=3    cell_id=11
    UE2 Send A1 To Trigger Scell Addition
    Run Traffic And Verify Throughput    ue_id=2

UE Register And Setup PDU Session
    [Arguments]    ${ue_id}=1    ${nwslice}=1    ${gateway}=1    ${enb_id}=2    ${cell_id}=1
    Execute Egate Command    ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=${nwslice} gw=${gateway}    pass_regexp=QoS Routing Table    timeout=20s

UE1 Send A1 To Trigger Scell Addition
    ${ScellAdd_A1}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=1    carrierfreq=663360    event_type=A1
    ...    threshold=RSRP\ 31
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=1 meas_id=${ScellAdd_A1} event=A1 srsrp_nr=115 srsrq_nr=40
    ...    pass_regexp=${UE1_expect}    fail_regexp=SCellIndex 3 activated successfully at airphone    timeout=20s

UE2 Send A1 To Trigger Scell Addition
    ${ScellAdd_A1}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=2    carrierfreq=368430    event_type=A1
    ...    threshold=RSRP\ 111
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=2 meas_id=${ScellAdd_A1} event=A1 srsrp_nr=115 srsrq_nr=40
    ...    pass_regexp=${UE2_expect}    fail_regexp=SCellIndex 3 activated successfully at airphone    timeout=20s

UE3 Register And PDU Session Setup With Blind 2 Scells Addition
    [Arguments]    ${ue_id}=3    ${nwslice}=1    ${gateway}=3    ${enb_id}=2    ${cell_id}=2
    Execute Egate Command    ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=${nwslice} gw=${gateway}    pass_regexp=${UE3_expect}
    ...    timeout=20s    sleep_time=5

UE3 Register And PDU Session Setup With no Scell Addition
    [Arguments]    ${ue_id}=3    ${nwslice}=1    ${gateway}=3    ${enb_id}=2    ${cell_id}=2
    Execute Egate Command    ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    ${ret1}=    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${gateway}
    ...    fail_regexp=sCellIndex 1    timeout=5s
    Execute Egate Command    ue_deregister id=3 ue_deregister_type=switch_off    pass_regexp=UE3: detached

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
    Verify Throughput    ${ue_id}    ${pdu}    ${qfi}    540    25
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

Check No Effect For UE1 And UE2
    Run Traffic And Verify Throughput
    Run Traffic And Verify Throughput    ue_id=2

F1_down
    ${output}    Execute Command On Enb     cat /ffs/run/config/NetworkPlanFileUpdate_*.xml | grep f1CLinkStatusCU
    Should Contain    ${output}    <p name="f1CLinkStatusCU">0</p>

F1_up
    ${output}    Execute Command On Enb    cat /ffs/run/config/NetworkPlanFileUpdate_*.xml | grep f1CLinkStatusCU
    Should Contain    ${output}    <p name="f1CLinkStatusCU">1</p>

Delta Commission To delete NRREL
    Delta Commission Parameters    ${online_modify_delete_NRREL_of_Cell2}
    BuiltIn.Log To Console    Online Update Parameters is done

F1 down and up Test
    Execute Command On Enb    iptables -A OUTPUT -p sctp --dport 38472 -j DROP
    Execute Command On Enb    ip6tables -A OUTPUT -p sctp --dport 38472 -j DROP
    Wait Until Keyword Succeeds    15 min    2 min    F1_down
    Execute Command On Enb    iptables -t filter -FOUTPUT
    Execute Command On Enb    ip6tables -t filter -FOUTPUT
    wait until keyword succeeds    15 min    1 min    F1_up
    Wait Until Keyword Succeeds    120s    20s    Object Should Exist    MRBTS-1/MNL-1/MNLENT-1/XPAP-1/XPIF-1/XPIFREMOTE_R-1:xpLinkStatus=available