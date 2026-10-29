*** Settings ***
Documentation
...    author:  baijie.zhu@nokia-sbell.com
...    contact: baijie.zhu@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup    Common Suite Setup And Setup 2Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_VRF    SBTS00    RAN_5G    RAN_5G_TDD    CLOUD_5G_I_[LO][LO]_AP_[LOO]_SANSA_FS_ECPRI_CMWV_TDD    team-CN1ET
...    owner-jolin.fan    release-SBTS24R1    CRT
Resource    ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
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
...    MRBTS-1/NRBTS-1/SNSSAI-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    MRBTS-1/NRBTS-1/SNSSAI-1:xgUplane:ipV4AddressDN1=${EMPTY}
...    MRBTS-1/NRBTS-1/SNSSAI-1:xgUplane:ipV6AddressDN1=${EMPTY}
...    MRBTS-1/NRBTS-1/SNSSAI-2:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    MRBTS-1/NRBTS-1/SNSSAI-2:sst=1
...    MRBTS-1/NRBTS-1/SNSSAI-2:administrativeState=Unlocked
...    delete:MRBTS-1/NRBTS-1/SNSSAI-2:sd
...    MRBTS-1/NRBTS-1/SNSSAI-2:xgUplane:ipV4AddressDN1=${EMPTY}
...    MRBTS-1/NRBTS-1/SNSSAI-2:xgUplane:ipV6AddressDN1=${EMPTY}
...    delete:MRBTS-1/NRBTS-1/SNSSAI-2:drbInactivityTimerSA
...    TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-1|snssaiDN=SNSSAI-1
...    TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-2|snssaiDN=SNSSAI-2
...    NRCELL:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-200
...    NRBTS/XNLINK-1:cPlaneIpAddr=10.0.1.3
...    NRBTS/XNLINK-1:cPlaneIpAddrCtrl=oamControlled

@{PARAMS_FOR_GNB2}
...    NRBTS:sCellActivationMethod=bufferBased
...    MRBTS-1/NRBTS-2/SNSSAI-1:nrPlmnDNList=MRBTS-1/NRBTS-2/NRPLMN-1
...    MRBTS-1/NRBTS-2/SNSSAI-1:xgUplane:ipV4AddressDN1=${EMPTY}
...    MRBTS-1/NRBTS-2/SNSSAI-1:xgUplane:ipV6AddressDN1=${EMPTY}
...    MRBTS-1/NRBTS-2/SNSSAI-2:nrPlmnDNList=MRBTS-1/NRBTS-2/NRPLMN-1
...    MRBTS-1/NRBTS-2/SNSSAI-2:sst=1
...    MRBTS-1/NRBTS-2/SNSSAI-2:administrativeState=Unlocked
...    delete:MRBTS-1/NRBTS-2/SNSSAI-2:sd
...    MRBTS-1/NRBTS-2/SNSSAI-2:xgUplane:ipV4AddressDN1=${EMPTY}
...    MRBTS-1/NRBTS-2/SNSSAI-2:xgUplane:ipV6AddressDN1=${EMPTY}
...    delete:MRBTS-1/NRBTS-2/SNSSAI-2:drbInactivityTimerSA
...    MRBTS-1/NRBTS-2/TRACKINGAREA-100:fiveGsTac=100
...    TRACKINGAREA-100:snssaiList:snssaiDN=SNSSAI-1|snssaiDN=SNSSAI-1
...    TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-1|snssaiDN=SNSSAI-1
...    TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-2|snssaiDN=SNSSAI-2
...    NRCELL-1:trackingAreaDN=MRBTS-1/NRBTS-2/TRACKINGAREA-100
...    NRCELL-13:trackingAreaDN=MRBTS-1/NRBTS-2/TRACKINGAREA-100
...    NRCELL-2:trackingAreaDN=MRBTS-1/NRBTS-2/TRACKINGAREA-200
...    NRCELL-14:trackingAreaDN=MRBTS-1/NRBTS-2/TRACKINGAREA-200

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
...    NRBTS/NRADJNRCELL-1:fiveGsTac=100
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
...    NRBTS/NRADJNRCELL-2:fiveGsTac=200
...    NRBTS/NRADJNRCELL-13:cellDepType=SA
...    NRBTS/NRADJNRCELL-13:gNbId=2
...    NRBTS/NRADJNRCELL-13:gNbIdLength=22
...    NRBTS/NRADJNRCELL-13:lcrId=13
...    NRBTS/NRADJNRCELL-13:nrarfcn=368400
...    NRBTS/NRADJNRCELL-13:physCellId=62
...    NRBTS/NRADJNRCELL-13:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-13:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-13:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-13:freqBandIndicatorNR=28
...    NRBTS/NRADJNRCELL-13:fiveGsTac=100
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
...    NRBTS/NRADJNRCELL-14:fiveGsTac=200

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
...    NRBTS/NRADJNRCELL-11:fiveGsTac=200

@{PARAMS_FOR_OTHERS}
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
...    NRCELL:actCDrx=true
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
...    NRBTS:actRanSharing=false

...    NRBTS:actNgcFlexSaMode=false
...    NRCELL:configuredEpsTac=200
...    NRBTS:actTrsSepaSARanSharing=false
...    NRBTS:actRrcInactState=intra-gNB
...    NRBTS:drbRrcInactInactivityTimerSA=20
...    NRBTS:drbInactivityTimerSA=600
...    NRBTS:srbInactivityTimerSA=20
...    NRBTS:maxUeRrcInactTime=360
...    NRBTS:rrcInactIMMSteeringEnabled=false
...    NRBTS:rrcInactLocationReportEnabled=false
...    NRBTS:outOfConnectedPreference=idle
...    NRBTS:t380=5min
...    NRBTS:actPaging=true
...    NRBTS:tRanPagingGuard=4
...    NRBTS:drxDefaultPaging=v256
...    NRBTS:ranPagingCycle=v32
...    NRBTS:actRrcReleasePreference=true
...    NRBTS:rrcInactPreferredStateEnabled=true
...    NRBTS:timerReleasePreferenceProhibit=s5
...    NRBTS:actSliceAwareScheduler=true
...    NRDU-1:xgUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRCELL:ranAC=1
...    NRBTS:act3gppBL23R1=true

@{GNB1_CA_rel}
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
...    NRCELL-12/NRREL-13:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-13:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-13:gNbId=2
...    NRCELL-12/NRREL-13:gNbIdLength=22
...    NRCELL-12/NRREL-13:handoverAllowedSA=allowed
...    NRCELL-12/NRREL-13:lcrId=13
...    NRCELL-12/NRREL-13:removeNotAllowed=false
...    NRCELL-12/NRREL-13:sCellAdditionMethod=blind
...    NRCELL-12/NRREL-13:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-13:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-13:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-13:sCellOperationalMode=dlOnly
...    NRCELL-12/NRREL-14:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-14:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-14:gNbId=2
...    NRCELL-12/NRREL-14:gNbIdLength=22
...    NRCELL-12/NRREL-14:handoverAllowedSA=allowed
...    NRCELL-12/NRREL-14:lcrId=14
...    NRCELL-12/NRREL-14:removeNotAllowed=false
...    NRCELL-12/NRREL-14:sCellAdditionMethod=blind
...    NRCELL-12/NRREL-14:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-14:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-14:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-14:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-12:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-12:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-12:gNbId=1
...    NRCELL-11/NRREL-12:gNbIdLength=22
...    NRCELL-11/NRREL-12:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-12:lcrId=12
...    NRCELL-11/NRREL-12:removeNotAllowed=false
...    NRCELL-11/NRREL-12:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-12:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-12:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-12:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-12:sCellOperationalMode=dlOnly

@{E009_parameter_update}
...    delete:NRCELL-11/NRREL-12
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
...    NRCELL-11/NRREL-13:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-13:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-13:gNbId=2
...    NRCELL-11/NRREL-13:gNbIdLength=22
...    NRCELL-11/NRREL-13:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-13:lcrId=13
...    NRCELL-11/NRREL-13:removeNotAllowed=false
...    NRCELL-11/NRREL-13:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-13:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-13:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-13:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-13:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-14:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-14:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-14:gNbId=2
...    NRCELL-11/NRREL-14:gNbIdLength=22
...    NRCELL-11/NRREL-14:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-14:lcrId=14
...    NRCELL-11/NRREL-14:removeNotAllowed=false
...    NRCELL-11/NRREL-14:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-14:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-14:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-14:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-14:sCellOperationalMode=dlOnly
...    NRCELL-12/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-13:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-14:sCellAdditionMethod=covBasedA1

@{E009_parameter_recover}
...    delete:NRCELL-11/NRREL-1
...    delete:NRCELL-11/NRREL-2
...    delete:NRCELL-11/NRREL-13
...    delete:NRCELL-11/NRREL-14
...    NRCELL-11/NRREL-12:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-12:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-12:gNbId=1
...    NRCELL-11/NRREL-12:gNbIdLength=22
...    NRCELL-11/NRREL-12:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-12:lcrId=12
...    NRCELL-11/NRREL-12:removeNotAllowed=false
...    NRCELL-11/NRREL-12:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-12:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-12:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-12:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-12:sCellOperationalMode=dlOnly
...    NRCELL-12/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-12/NRREL-2:sCellAdditionMethod=blind
...    NRCELL-12/NRREL-13:sCellAdditionMethod=blind
...    NRCELL-12/NRREL-14:sCellAdditionMethod=blind

@{INACTIVE_check}
...    SuspendConfig
...    fullI_RNTI
...    shortI_RNTI
...    nextHopChainingCount
...    t380
...    NR_RRC_INACTIVE

@{Resume_Check}
...    resumeCause mt-Access
...    rrcResumeComplete
...    rrcReconfigurationComplete

@{blind_3CC_regexp}
...    pcid:60, scellIdx:0
...    pcid:51, scellIdx:1
...    pcid:63, scellIdx:2
...    PhysCellId: 63] SCellIndex 2 activated successfully
...    PhysCellId: 51] SCellIndex 1 activated successfully

@{covbase_3CC_regexp}
...    pcid:61, scellIdx:0
...    pcid:51, scellIdx:1
...    pcid:63, scellIdx:2
...    PhysCellId: 63] SCellIndex 2 activated successfully
...    PhysCellId: 51] SCellIndex 1 activated successfully

@{resume_cell12_3CC_regexp}
...    resumeCause mt-Access
...    rrcResumeComplete
...    rrcReconfigurationComplete
...    pcid:61, scellIdx:0
...    pcid:51, scellIdx:1
...    pcid:63, scellIdx:2
...    PhysCellId: 63] SCellIndex 2 activated successfully
...    PhysCellId: 51] SCellIndex 1 activated successfully

@{blind_2CC_regexp}
...    QoS Routing Table
...    releasePreference-r16 supported
...    pcid:60, scellIdx:0
...    pcid:61, scellIdx:1

@{Resume_blind_2CC_regexp}
...    resumeCause mt-Access
...    rrcResumeComplete
...    rrcReconfigurationComplete
...    pcid:60, scellIdx:0
...    pcid:61, scellIdx:1

@{PM_Counters_Check_E009}
...    NRCELL-11:${IGNB_CA_ATT_SA_REL}=3
...    NRCELL-12:${IGNB_CA_ATT_SA_REL}=1
...    NRCELL-11:${NRRCC_RRC_REL_WITH_SUSP_NRNAU}=2
...    NRCELL-11:${NRRCC_RRC_RESUME_REQUEST1}=2
...    NRCELL-12:${NRRCC_RRC_RESUME_REQUEST1}=1
...    NRCELL-11:${NRRCC_RRC_RESUME_SUCC}=1
...    NRCELL-12:${NRRCC_RRC_RESUME_SUCC}=1
...    NRCELL-11:${NRRCC_RRC_RESUME_REQUEST1_RNAU}=1
...    NRCELL-11:${NRRCC_RRC_REL_WITH_SUSP_RNAU}=1

@{PM_Counters_Check_E008_GNB1}
...    NRCELL-11:${NRRCC_RRC_REL_WITH_SUSP_NRNAU}=1
...    NRCELL-12:${NRRCC_RRC_REL_WITH_SUSP_NRNAU}=1
...    NRCELL-12:${NRRCC_RRC_RESUME_REQUEST1_RNAU}=1
...    NRCELL-12:${NRRCC_RRC_REL_WITH_SUSP_RNAU}=1
...    NRCELL-11:${NRRCC_RRC_RESUME_REQUEST1}=1
...    NRCELL-12:${NRRCC_RRC_RESUME_REQUEST1}=2
...    NRCELL-11:${NRRCC_RRC_RESUME_SUCC}=1
...    NRCELL-12:${NRRCC_RRC_RESUME_SUCC}=1
...    NRCELL-12:${IGNB_CA_ATT_SA_REL}=1
...    NRCELL-11:${GNB_SCELL_1_ADMI_REQ_SA}=2
...    NRCELL-11:${GNB_SCELL_1_ADMI_SUCC_SA}=2
...    NRCELL-12:${GNB_DU_SCELL_ADMI_REQ_SA}=2
...    NRCELL-12:${GNB_DU_SCELL_ADMI_SUCC_SA}=2
...    NRCELL-11:${GNB_DU_SCELL_1_ADMI_REQ_SA}=2
...    NRCELL-11:${GNB_DU_SCELL_1_ADMI_SUCC_SA}=2
...    NRCELL-12:${SCELL_ACTIVATIONS}=2
...    NRCELL-12:${GNB_DU_SCELL_2_ADMI_REQ_SA}=1
...    NRCELL-12:${GNB_DU_SCELL_2_ADMI_SUCC_SA}=1
...    NRCELL-12:${IGNB_CA_ATT_2_SCELL_SA}=1
...    NRCELL-12:${IGNB_CA_ATT_2_SCELL_SA_SUCC}=1

@{PM_Counters_Check_E008_GNB2}
...    NRCELL-2:${GNB_DU_SCELL_ADMI_REQ_SA}=1
...    NRCELL-14:${GNB_DU_SCELL_ADMI_REQ_SA}=1
...    NRCELL-2:${GNB_DU_SCELL_ADMI_SUCC_SA}=1
...    NRCELL-14:${GNB_DU_SCELL_ADMI_SUCC_SA}=1
...    NRCELL-2:${IGNB_CA_SCELL_ADMI_REQ_SA}=1
...    NRCELL-14:${IGNB_CA_SCELL_ADMI_REQ_SA}=1
...    NRCELL-2:${IGNB_CA_SCELL_ADMI_SUCC_SA}=1
...    NRCELL-14:${IGNB_CA_SCELL_ADMI_SUCC_SA}=1
...    NRBTS-2:${IGNB_CA_ADD_REQ_SA_ADJ}=1

${NRRCC_RRC_REL_WITH_SUSP_NRNAU}    M55124C00006    #Number of RRC Releases with suspension for non-RNA update resume cause
${IGNB_CA_ATT_SA_REL}    M55118C11008    #Counts the number of inter gNB CA addition attempts released for SA.
${NRRCC_RRC_RESUME_REQUEST1}    M55124C00007    #This counter provides the total number of RRCResumeRequests1 received at the gNB-CU.
${NRRCC_RRC_RESUME_SUCC}    M55124C00010
#This counter provides the total number of successful RRC Resume procedures from RRC_INACTIVE to RRC_CONNECTED state.
${NRRCC_RRC_RESUME_REQUEST1_RNAU}    M55124C00011
#This counter provides the total number of RRCResumeRequest1 received at the gNB-CU for RNA update.
${NRRCC_RRC_REL_WITH_SUSP_RNAU}    M55124C00012
#This counter provides the total number of RRC releases with suspendConfig IE sent from the gNB-CU in response to an RRC resume request
#for an RNA update.
${GNB_SCELL_1_ADMI_REQ_SA}    M55138C01501    #Radio admission requests for 1 SCell in SA mode
${GNB_SCELL_1_ADMI_SUCC_SA}    M55138C01502    #Successful radio admissions for 1 SCell addition in SA mode
${GNB_DU_SCELL_ADMI_REQ_SA}    M55139C01001    #Radio admission requests for the SCell in DU in SA mode
${GNB_DU_SCELL_ADMI_SUCC_SA}    M55139C01002    #Successful radio admissions for the SCell in DU in SA mode
${GNB_DU_SCELL_1_ADMI_REQ_SA}    M55139C01003    #Radio admission requests for 1 SCell in DU in SA mode
${GNB_DU_SCELL_1_ADMI_SUCC_SA}    M55139C01004    #Successful radio admissions for 1 SCell addition in DU in SA mode
${SCELL_ACTIVATIONS}    M55316C09000    #The number of SCell activations
${GNB_DU_SCELL_2_ADMI_REQ_SA}    M55139C01501    #Radio admission requests for 2 SCells in DU in SA mode
${GNB_DU_SCELL_2_ADMI_SUCC_SA}    M55139C01502    #Successful radio admissions for 2 SCell additions in DU in SA mode
${IGNB_CA_ATT_2_SCELL_SA}    M55118C11002    #Number of times two S-Cell Inter gNB CA addition attempted SA
${IGNB_CA_ATT_2_SCELL_SA_SUCC}    M55118C11005    #Number of times two S-Cell Inter gNB CA addition succeeded
${IGNB_CA_SCELL_ADMI_REQ_SA}    M55138C03501    #Number of radio admission requests for Inter gNB S-Cell setup
${IGNB_CA_SCELL_ADMI_SUCC_SA}    M55138C03502    #Number of successful radio admissions for Inter gNB S-Cell additions in SA mode
#${IGNB_CA_ADD_REQ_SA_NRADJ}    M55175C00001    #Number of times Inter gNB CA addition requests in ext-gNB   Before 24R2
${IGNB_CA_ADD_REQ_SA_ADJ}      M55199C00001    #Number of times Inter gNB CA addition requests in ext-gNB

${SA_Capa_Inactive_N3_N28_N77}    SEPARATOR=
...    E9A09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C47013B8D80D81AC1184341020E9068036B64C558D0E7C471E81
...    9F604F8C48E3C873EA39F30C7942C0E070F05C00FFC0070005F0005C0000E0541B00B582308682041E20D00656C98AB121CFB027C471E31238F21CFA8E
...    7CC31E50B0381C3C27F6000001FD800000170000381546C4CD608C21A0810748340185B262A88873E238F11C7A067D813E31CF9863CA1607038782E007
...    FE003801FF8002E0000702A0D837AC1184341020F1068032B64C55890E7C471EC09F1891C790E7D473E618F28581C0E1E13FFE00000FFF800000B80001
...    C0EE36147FEB04610D04083A41A00DAD931563439F11C7A067D813E31238F21CFA8E7CC31E50B0381C3C17AABFFAA9EAAFFEAA17000038026B0F130003
...    8980000002C0AC5C4C000E26000713000000858158B80400184C0309800020B02B1F008003836001C4C000E260000030B02B170080030040606C000816
...    0563E0100060180C0D8184D0002858158B80400181B0309800060B02B0F00800309800070B02B0F00800300400080B02B0F06C00303600090B02B0F008
...    00300C000A0B02B0F018003036000B0B02B1700800300C0606C0018160563E0D800713000309806130001A160562E2600061300C01000382C0AC780203
...    89800184C03098000F0B02B171300030040606C0020160563E2680060080C030181B0008858158F80400180203098061300024160402401B800D013200
...    1402817400F709C28913639F0E2448913639F0E2448913639F0E344891226C73E1C4891226C73E1C68912244D8E7C38912244D8E7C3851226C73E1C289
...    13639F0E14489B1CF870A244D8E7C3851226C73E1C4891226C73E1C28913639F0E2448913639F0E344891226C73E1C4891226C73E1C68912244D8E7C38
...    D1224489B1CF861B1318C6318C6318C6318C6318C7E82E003C00281C1401C0C02500700060240040603E09002000000010008000000200000C01000002
...    00800002004000018020000100100000A008004010040100000C0080000700400200000008000080040000480200000C010000140080000B0040020481
...    20080000C0339535953582958195833582B594B7933780B581B58095811583B40D04000025949410000196526040000659490100003965240400012594
...    9010000596526040001A594901000079652404000225949010000996524040002A5949010000B96525040003259490100003165240334AAAE955552A8B
...    A55154162A82C55068AA531549A2A80C55028AA4D5541E285805E02540A05028140A05028140A05028140A05028140A050012080801002020040088040
...    080101002004040080110080600A02004008080100230100C014040300501002004040080110080800A02020028080B01630100C01804030050100C018
...    040080110080600A02018028080100210100C014040080108080600A02018028404030060100C018202018030080600A10100C014040300510080600A0
...    2018030080600A30100C018040080101002004040080110080100202004008080600A30100C01404008010100200404008011008010020201803008060
...    0C30100200404030050100C018040300518080600A02018028080100202004008D50F8000810182030385058606880889098A0C0C8D8E0E8F909293139
...    414951697A0A0C96A510000210

*** Test Cases ***
CB008225-ET-E009_Successful_transition_of_Suspended_UE_in_RRC_INACTIVE_to_CONNECTED_with_RNA_update_resume_with_inter_gNB_Meas_based_CA_config
    [Documentation]
    ...    This user scenario describes the gNB behaviour for UE in RRC_INACTIVE state that is successfully transitioned to RRC_CONNECTED state.
    ...    Successful Resume procedure with blind inter-gNB CA Scell addition triggered per legacy features CB008140 the same way. As well as
    ...    Cell with inter-gNB Meas_based CA config. Trigger RAN Paging RRC_INACTIVE UE or resume to RRC_CONNECTED state.
    ...    1.[Configuration]:
    ...    Cell id=11 gnb=1 pci=20:0 tac=200 tdd_cell=off band=n3 nr_arfcn=364000:345000 chBw=15MHz
    ...    Cell id=12 gnb=1 pci=20:1 tac=200 tdd_cell=off band=n3 nr_arfcn=374000:355000 chBw=15MHz
    ...    Cell id=1 gnb=2 pci=16:2 tac=100 tdd_cell=on band=n77 nr_arfcn=663400:663400 chBw=100MHz
    ...    Cell id=2 gnb=2 pci=17:0 tac=200 tdd_cell=on band=n77 nr_arfcn=658000:658000 chBw=40MHz
    ...    Cell id=13 gnb=2 pci=20:2 tac=100 tdd_cell=off band=n3 nr_arfcn=368400:349400 chBw=10MHz
    ...    Cell id=14 gnb=2 pci=21:0 tac=200 tdd_cell=off band=n28 nr_arfcn=153400:143400 chBw=15MHz
    ...    cell 11,12 is on gnb1, cell1,2,13,14 are on gnb2.
    ...    cell 1,2,13,14 are configured as scells of cell11 and cell12.
    ...    2.Test Case Steps:
    ...         a.Set UE1,UE2 Core Network Assistance Information for RRC INACTIVE state in the Initial Context Setup Request.
    ...           And trigger UE1,UE2 register to Cell1_11 with PDU 1 Slice 1. UE capability support band N3+N77+N28.
    ...           3CC InterGNB Blind CA(scell:cell2_2+cell2_14)is setup.
    ...         b.Setup new PDU with slice2 on UE1,UE2 and start traffic.
    ...         c.Stop all traffic.Wait until parameter drbRrcInactInactivityTimerSA and srbInactivityTimerSA expire.
    ...           UE1,UE2 is released to RRC_INACTIVE state.
    ...         d.Trigger UE1 send RRCResume with cause:mt_Access,UE1 RRCResume to Cell1_12
    ...         e.UE1 sends A1 MR for scell addition. 3CC InterGNB covBased CA(scell:cell2_2+cell2_14)is setup.
    ...         f.start traffic for UE1 on PDU1 and PDU2, traffic is ok.
    ...         g.Trigger UE2 send RRCResume with rna_Update,UE2 RRCResume to Cell1_11, still in RRC_INACTIVE state.
    ...         h.Trigger paging resume, update UE2 resume request cause:mt_Access. rrcResumeComplete and PDU session 1,2 are setup successfully.
    ...         i.start traffic for UE2 on PDU1 and PDU2, 3CC InterGNB Blind CA(scell:cell2_2+cell2_14) is setup.
    ...         j.stop UE1 UE2 traffic and release UEs sccessfully.
    ...         k.check counters and log.
    [Tags]    QC_47126    owner-jolin.fan    E009    CA_LABEL-FTF(15MHz_FDD_n3+40MHz_TDD_n77+15MHz_FDD_n28)
    Clear Counter files    True
    OnlineParamChange    ${E009_parameter_update}
    Sa UEs Attach and setup new PDU
    Start traffic for UEs and Check Throughput
    Stop traffic to make UEs into Inactive state
    Trigger RRC Resume    ue_id=1    cell_id=12
    UE Send A1 MR Trigger Scell Addition    ue_id=1    cellfreq=373970    pass_reg_ca=${covbase_3CC_regexp}    CC_NUM=3
    Trigger RRC Resume with RNA Update    ue_id=2    cell_id=11
    Trigger Paging Resume and CA successful    ue_id=2    cell_id=11    pass_reg_ca=${blind_3CC_regexp}    CC_NUM=3
    UEs Deregister and check counter and log
    [Teardown]    E009_Teardown

CB008225-ET-E008_Successful_transition_of_Suspended_UE_in_RRC_INACTIVE_to_RRC_CONNECTED_resume_to_Cell_with_inter-gNB_Blind_CA_config
    [Documentation]
    ...    This case is to Verify the gNB behavior for UE in RRC_CONNECTED and configured with inter-gNB CA that is successfully transitioned
    ...    to RRC_INACTIVE state based on the UE inactivity. Successful suspend procedure. CA resources allocated for the UE at gNB1 and gNB2 are
    ...    released during suspend procedure.Cell with inter-gNB Blind CA.Triggers UE release to RRC_INACTIVE state by UE Assistance Information.
    ...    [Configuration]:
    ...    Cell id=11 gnb=1 pci=20:0 tac=200 tdd_cell=off band=n3 nr_arfcn=364000:345000 chBw=15MHz
    ...    Cell id=12 gnb=1 pci=20:1 tac=200 tdd_cell=off band=n3 nr_arfcn=374000:355000 chBw=15MHz
    ...    Cell id=1 gnb=2 pci=16:2 tac=100 tdd_cell=on band=n77 nr_arfcn=663400:663400 chBw=100MHz
    ...    Cell id=2 gnb=2 pci=17:0 tac=200 tdd_cell=on band=n77 nr_arfcn=658000:658000 chBw=40MHz
    ...    Cell id=13 gnb=2 pci=20:2 tac=100 tdd_cell=off band=n3 nr_arfcn=368400:349400 chBw=10MHz
    ...    Cell id=14 gnb=2 pci=21:0 tac=200 tdd_cell=off band=n28 nr_arfcn=153400:143400 chBw=15MHz
    ...    cell 11,12 is on gnb1, cell1,2,13,14 are on gnb2.
    ...    cell 12 is configured as scell of cell11.
    ...    cell 1,2,13,14 are configured as scells of cell12.
    ...    2.Test Case Steps:
    ...         a.Set UE1 Core Network Assistance Information for RRC INACTIVE state in the Initial Context Setup Request.
    ...           And trigger UE1 register to Cell1_11 with PDU 1 Slice 1.Blind CA(cell11+cell12)is setup.
    ...         b.Setup new PDU with slice2 on UE1 and start traffic.
    ...         c.Stop all traffic.Wait until parameter drbRrcInactInactivityTimerSA and srbInactivityTimerSA expire.
    ...           UE1 is released to RRC_INACTIVE state.
    ...         d.Trigger UE1 send RRCResume with rna_Update,UE1 RRCResume to Cell1_12, still in RRC_INACTIVE state.
    ...         e.Trigger paging resume,PDU session 1 and 2 are setup successfully.Blind CA(2+cell2+cell14)is setup.
    ...         f.UE1 PDU session 1/2 start traffic and stop traffic.
    ...         g.Trigger UE1 send UEAssistanceInformation with ReleasePreference-r16=inactive
    ...           UE1 is released to RRC_INACTIVE state.
    ...         h.Triggle mt_Access resume to cell 11,PDU session 1 and 2 are setup successfully.
    ...           Blind CA(cell11+cell2)is setup.PDU session 1/2 start traffic and stop traffic.
    [Tags]    QC_47125    owner-jing.ye    E008    CA_LABEL-FTF(15MHz_FDD_n3+40MHz_TDD_n77+15MHz_FDD_n3)    CA_LABEL-FF(15MHz_FDD_n3+15MHz_FDD_n3)
    Clear Counter Files    wait=${False}
    Clear Counter Files GNB2    wait=${False}
    Sa UE Attach With 2 PDUs
    Start traffic and Check Throughput    ue_id=1    cc_num=2    dl=180    ul=18
    Stop traffic to Inactive
    Trigger RRC Resume with RNA Update
    Trigger Paging Resume and CA successful    ue_id=1    cell_id=12    pass_reg_ca=${resume_cell12_3CC_regexp}    CC_NUM=3
    Trigger UE to INACTIVE by UAI
    Trigger RRC Resume    pass_regexp=${Resume_blind_2CC_regexp}
    Start traffic and Check Throughput    ue_id=1    cc_num=2    dl=180    ul=18
    Check Counters    ${PM_Counters_Check_E008_GNB1}
    Check Counters GNB2    ${PM_Counters_Check_E008_GNB2}

*** Keywords ***
Common Suite Setup And Setup 2Airphone Env
    Common Suite Setup
    Setup 2Airphone Env    fddtdd_sansa_cmwv/6cells_gnb1_2F_gnb2_2T2F

E009_Teardown
    OnlineParamChange    ${E009_parameter_recover}
    Common Test Teardown And Stop Capture Logs

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be Onair    check_sib=${True}

Update UE capa
    [Arguments]    ${SA_Capa_perUE_Full}=${SA_Capa_Inactive_N3_N28_N77}    ${ue_id}=1
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full}
    Execute Egate Command    ${cmd}

Sa UE Attach With 2 PDUs
    Sa Ue Attach    PDU_regexp=${blind_2CC_regexp}
    UE setup new PDU    ue_id=1    pdu_id=2    nwslice_id=2    gateway=2

Sa Ue Attach
    [Arguments]    ${ue_id}=1    ${gateway}=1    ${enb_id}=2    ${cell_id}=11    ${pass_regexp}=NG RM Register
    ...    ${PDU_regexp}=activated
    Update UE capa    ue_id=${ue_id}
    Execute Egate Command    ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}
    ${core_assis_info}    catenate    amf_ue_ics_param id=1 core_network_assistance_info=on ue_identity_index_value=${ue_id} ue_specific_drx=64
    ...    periodic_registration_update_timer=1:10min plmn_id=311:489 tac_id=200
    Execute Egate Command    ${core_assis_info}
    Execute Egate Command    ue_register id=${ue_id}    ${pass_regexp}
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${gateway}    ${PDU_regexp}

UE setup new PDU
    [Arguments]    ${ue_id}=1    ${pdu_id}=2    ${nwslice_id}=2    ${gateway}=2
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} nwslice=${nwslice_id} gw=${gateway}    QoS Routing Table

Trigger RRC Resume with RNA Update
    [Arguments]    ${ue_id}=1    ${cell_id}=12
    sleep    2s    #sleep for inactive precedure complete
    Execute Egate Command    ue_nr_rrc_resume_request_param id=${ue_id} gnb=2 cell=${cell_id} cause=rna_Update
    Execute Egate Command    ue_nr_rrc_resume id=${ue_id}    pass_regexp=${INACTIVE_check}

Trigger RRC Resume
    [Arguments]    ${ue_id}=1    ${cell_id}=11    ${pass_regexp}=${Resume_Check}
    sleep    2s    #sleep for inactive precedure complete
    Execute Egate Command    ue_nr_rrc_resume_request_param id=${ue_id} gnb=2 cell=${cell_id} cause=mt_Access
    Execute Egate Command    ue_nr_rrc_resume id=${ue_id}    pass_regexp=${pass_regexp}

UE Deregister From gNB
    [Arguments]    ${ue_id}=1
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=1    Traffic was stopped
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=2    Traffic was stopped
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s

Modify Cfg
    Update Cfg    set_amf_region id=1 tac_list=0,100,200 plmn=311:489
    ${set_ue1}    catenate    set_ue simulated id=1 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...    nia=null+zuc nea=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0000:0:0:021645400 mode=nr enb=2 cell=11
    Update Cfg    ${set_ue1}
    Update Cfg    set_nwslice id=1 snssai=0x01:0xFFFFFF default=on ue=all amf=1
    Update Cfg    set_nwslice id=2 snssai=0x01:0xd143a5 ue=all amf=1

Verify Throuput on Pscell and Scell
    [Arguments]    ${ue_id}=1    ${CC_num}=3    ${dl}=160    ${ul}=8
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-5 type=pdsch    pass_regexp=Average
    ${all_tput}    set variable    0
    FOR    ${id}    IN RANGE    0    ${CC_num}
        ${sid}    convert to string    ${id}
        ${scell_tput}    Ap Get Throuput On Specific Scell     ue_id=${ue_id}    scell_id=${sid}    type=pdsch    rate_type=ave
        Should Be True    ${scell_tput}/1000 > 0
        ${all_tput}    Evaluate    ${all_tput}+${scell_tput}
    END
    Should Be True    ${all_tput}/1000 > ${dl}
    ${ul_throughput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pusch    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul}

Stop traffic to Inactive
    [Arguments]    ${ue_id}=1
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=1
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=2    pass_regexp=${INACTIVE_check}    timeout=21s

Stop traffic
    [Arguments]    ${ue_id}=1
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=1 qfi=1 dir=ul
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=1 qfi=1 dir=dl
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=2 qfi=1 dir=ul
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=2 qfi=1 dir=dl

Start traffic and Check Throughput
    [Arguments]    ${ue_id}=1    ${cc_num}=3    ${dl}=180    ${ul}=18
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=1 mbps=100    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=2 qfi=1 dir=dl trf_id=2 mbps=100    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=ul trf_id=3 mbps=10    UE ${ue_id}: UDP UL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=2 qfi=1 dir=ul trf_id=4 mbps=10    UE ${ue_id}: UDP UL
    Wait Until Keyword Succeeds    30s    5s    Verify Throuput on Pscell and Scell    ue_id=${ue_id}    CC_num=${cc_num}    dl=${dl}    ul=${ul}

UE Send A1 MR Trigger Scell Addition
    [Arguments]    ${ue_id}=1    ${cellfreq}=373970    ${pass_reg_ca}=activated    ${CC_NUM}=3
    ${meas_id}=    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=${cellfreq}    event_type=A1
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=100 srsrq_nr=50
    ...    pass_regexp=${pass_reg_ca}
    Start traffic and Check Throughput    ue_id=${ue_id}    cc_num=${CC_NUM}

Trigger Paging Resume and CA successful
    [Arguments]    ${ue_id}=2    ${cell_id}=11    ${pass_reg_ca}=activated    ${CC_NUM}=3
    Execute Egate Command    ue_nr_rrc_resume_request_param id=${ue_id} gnb=2 cell=${cell_id} cause=mt_Access
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=8 mbps=80    pass_regexp=${pass_reg_ca}
    Start traffic and Check Throughput    ue_id=${ue_id}    cc_num=${CC_NUM}    dl=250    ul=18

Sa UEs Attach and setup new PDU
    Sa Ue Attach    ue_id=1    gateway=1    cell_id=11    PDU_regexp=${blind_3CC_regexp}
    Sa Ue Attach    ue_id=2    gateway=3    cell_id=11    PDU_regexp=${blind_3CC_regexp}
    UE setup new PDU    ue_id=1    pdu_id=2    nwslice_id=2    gateway=2
    UE setup new PDU    ue_id=2    pdu_id=2    nwslice_id=2    gateway=4

Start traffic for UEs and Check Throughput
    Start traffic and Check Throughput    ue_id=1    cc_num=3    dl=180    ul=18
    Start traffic and Check Throughput    ue_id=2    cc_num=3    dl=180    ul=18

Stop traffic to make UEs into Inactive state
    Stop traffic to Inactive    ue_id=1
    Stop traffic to Inactive    ue_id=2

UEs Deregister and check counter and log
    UE Deregister From gNB    ue_id=1
    UE Deregister From gNB    ue_id=2
    #Check WireShark Log    ${CURDIR}${/}A2A_E009${/}a2a.ini    wait_string=UEContextReleaseComplete::14
    Check Counters    ${PM_Counters_Check_E009}

Trigger UE1 send UEAssistanceInformation
    Execute Egate Command    ue_assistance_send_nr ue_id=1 PreferredRRCState=inactive    pass_regexp=${INACTIVE_check}

Trigger UE to INACTIVE by UAI
    Stop traffic
    Trigger UE1 send UEAssistanceInformation
