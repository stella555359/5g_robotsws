*** Settings ***
Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_FDD    CLOUD_5G_I_[LO][LO]_AP_[LOO]_SANSA_FS_ECPRI_CMWV_TDD
...               CRT    release-SBTS23R3    owner-jolin.fan    team-jazz
Resource          ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
${NOKIA_XNAP_PLUGIN_FLAG}    ${True}
${NOKIA_F1AP_PLUGIN_FLAG}    ${True}
${W_XpVersion}    12
${W_XgUVersion}    1000
${7108_fault_name}    Inter-gNB CA Xp version mismatch
${7109_fault_name}    Inter-gNB CA Xg-U version mismatch
${7328_fault_name}    Inter-gNB CA Xn version mismatch
${DisableL2PS_XPU_monitoring}    0x580647

@{PARAMS_IN_SWCONFIG}
...    ${DisableL2PS_XPU_monitoring}=0

@{PARAMS_IN_SCF}
...    @{CA_basic_config}
...    @{CB008140_config_GNB1}
...    @{PARAMS_ADJ_REL_FOR_GNB1_to_simGNB4}

@{PARAMS_IN_SCF_GNB2}
...    @{CB008140_config_GNB2}
...    @{CA_basic_config}

@{CB008140_config_GNB1}
...    NRCELL-1:maxNumScellsDlFr1=3
...    NRCELL-2:maxNumScellsDlFr1=3
...    NRBTS/NRADJGNB-1:administrativeState=Unlocked
...    NRBTS/NRADJGNB-1:gNbIdLength=22
...    NRBTS/NRADJGNB-1:gNodeBId=2
...    NRBTS/NRADJGNB-1:weightForIgnbCaSelection=1
...    NRBTS/NRADJGNB-1:xnLinkRef=1
...    NRBTS/NRADJGNB-1:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-1:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-1:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-1:fiveGsTac=200
...    NRBTS/NRADJNRCELL-1:freqBandIndicatorNR=3
...    NRBTS/NRADJNRCELL-1:gNbId=2
...    NRBTS/NRADJNRCELL-1:gNbIdLength=22
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-1:lcrId=11
...    NRBTS/NRADJNRCELL-1:nrarfcn=368400
...    NRBTS/NRADJNRCELL-1:physCellId=60
...    NRBTS/NRADJNRCELL-1:ssbFrequency=368430
...    NRBTS/NRADJNRCELL-2:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-2:fiveGsTac=200
...    NRBTS/NRADJNRCELL-2:freqBandIndicatorNR=28
...    NRBTS/NRADJNRCELL-2:gNbId=2
...    NRBTS/NRADJNRCELL-2:gNbIdLength=22
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-2:lcrId=12
...    NRBTS/NRADJNRCELL-2:nrarfcn=153400
...    NRBTS/NRADJNRCELL-2:physCellId=61
...    NRBTS/NRADJNRCELL-3:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-3:fiveGsTac=200
...    NRBTS/NRADJNRCELL-3:freqBandIndicatorNR=77
...    NRBTS/NRADJNRCELL-3:gNbId=2
...    NRBTS/NRADJNRCELL-3:gNbIdLength=22
...    NRBTS/NRADJNRCELL-3:lcrId=3
...    NRBTS/NRADJNRCELL-3:nrarfcn=653400
...    NRBTS/NRADJNRCELL-3:physCellId=52
...    NRBTS/NRADJNRCELL-3:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-3:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-3:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-4:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-4:fiveGsTac=200
...    NRBTS/NRADJNRCELL-4:gNbId=2
...    NRBTS/NRADJNRCELL-4:gNbIdLength=22
...    NRBTS/NRADJNRCELL-4:lcrId=4
...    NRBTS/NRADJNRCELL-4:nrarfcn=648000
...    NRBTS/NRADJNRCELL-4:physCellId=53
...    NRBTS/NRADJNRCELL-4:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-4:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-4:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-4:freqBandIndicatorNR=77
...    NRBTS:iGnbCaXnSetupReqTmr=30
...    NRBTS:iGnbCaXnRemovalTmr=10
...    NRCELL:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-200
...    NRBTS:caConfigurationSupport=2CCDL_2CCUL
...    MNL-1/MNLENT-1/XPAP-1/XPIF-1/XPIFREMOTE-2:ipAddress=10.0.1.124
...    MNL-1/MNLENT-1/XPAP-1/XPIF-1/XPIFREMOTE-2:remoteNeType=GNB

@{CB008140_config_GNB2}
...    NRBTS/NRADJGNB-1:administrativeState=Unlocked
...    NRBTS/NRADJGNB-1:gNbIdLength=22
...    NRBTS/NRADJGNB-1:gNodeBId=1
...    NRBTS/NRADJGNB-1:weightForIgnbCaSelection=1
...    NRBTS/NRADJGNB-1:xnLinkRef=1
...    NRBTS/NRADJGNB-1:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-1:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-1:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-1:fiveGsTac=200
...    NRBTS/NRADJNRCELL-1:gNbId=1
...    NRBTS/NRADJNRCELL-1:gNbIdLength=22
...    NRBTS/NRADJNRCELL-1:lcrId=1
...    NRBTS/NRADJNRCELL-1:nrarfcn=663400
...    NRBTS/NRADJNRCELL-1:physCellId=50
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mncLength=3
...    NRBTS:iGnbCaXnSetupReqTmr=40
...    NRBTS:iGnbCaXnRemovalTmr=10
...    NRCELL:trackingAreaDN=MRBTS-1/NRBTS-2/TRACKINGAREA-200
...    NRBTS:caConfigurationSupport=2CCDL_2CCUL

@{PARAMS_ADJ_REL_FOR_GNB1_to_simGNB4}
...    NRBTS/XNLINK-2:cPlaneIpAddr=10.0.1.124
...    NRBTS/NRADJGNB-3:administrativeState=Unlocked
...    NRBTS/NRADJGNB-3:gNbIdLength=22
...    NRBTS/NRADJGNB-3:gNodeBId=35
...    NRBTS/NRADJGNB-3:weightForIgnbCaSelection=10
...    NRBTS/NRADJGNB-3:xnLinkRef=2
...    NRBTS/NRADJGNB-3:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-3:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-3:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-44:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-44:fiveGsTac=200
...    NRBTS/NRADJNRCELL-44:gNbId=35
...    NRBTS/NRADJNRCELL-44:gNbIdLength=22
...    NRBTS/NRADJNRCELL-44:lcrId=5
...    NRBTS/NRADJNRCELL-44:nrarfcn=648000
...    NRBTS/NRADJNRCELL-44:physCellId=54
...    NRBTS/NRADJNRCELL-44:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-44:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-44:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-44:freqBandIndicatorNR=77
...    NRBTS/NRADJNRCELL-411:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-411:fiveGsTac=200
...    NRBTS/NRADJNRCELL-411:gNbId=35
...    NRBTS/NRADJNRCELL-411:gNbIdLength=22
...    NRBTS/NRADJNRCELL-411:lcrId=6
...    NRBTS/NRADJNRCELL-411:nrarfcn=368400
...    NRBTS/NRADJNRCELL-411:physCellId=63
...    NRBTS/NRADJNRCELL-411:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-411:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-411:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-411:freqBandIndicatorNR=3
...    NRBTS/NRADJNRCELL-412:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-412:fiveGsTac=200
...    NRBTS/NRADJNRCELL-412:gNbId=35
...    NRBTS/NRADJNRCELL-412:gNbIdLength=22
...    NRBTS/NRADJNRCELL-412:lcrId=7
...    NRBTS/NRADJNRCELL-412:nrarfcn=153400
...    NRBTS/NRADJNRCELL-412:physCellId=64
...    NRBTS/NRADJNRCELL-412:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-412:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-412:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-412:freqBandIndicatorNR=28

@{CA_basic_config}
...    NRDU-1:actInterGnbCa=DLOnly
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRDU-1:actInterNumerologyCa=true
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:carrierAggregationSupportList=ca_Fdd_Fdd,ca_Fdd_Fr1Tdd_Sa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fdd_Any_Sa,ca_Fr1Tdd_Any_Sa
...    NRCELL:actK1Opt=intraAndInter-gNB
...    NRBTS:actConflictConfiguration=true
...    NRBTS:actIncXn=true
...    NRBTS:actFdmEnhancedScheduling=true
...    NRBTS:actCarrierAggregation=true
...    NRBTS:sCellActivationMethod=blind
...    NRBTS:actChannelMapVal=Disabled
...    NRBTS:actRanSharing=false
...    NRBTS:maxNumScellsDl=4
...    NRBTS:maxNumScellsUl=4
...    NRBTS:iGnbCaXnCfUpBackOffTmr=0
...    NRBTS:iGnbCaXnSetupRespTmr=1
...    NRBTS:weightForIgnbCaSelection=1

...    NRBTS:intGnbScellTempBlockTmr=60
...    delete:NRCELL/NRPLMNSET_NSA-1
...    delete:NRCELL/NRPLMNSET_SA-1
...    NRCELL:configuredEpsTac=200
...    NRCELL:actCDrx=false
...    NRBTS:cipherPrefL:nea0=8
...    NRBTS:cipherPrefL:nea1_128=0
...    NRBTS:cipherPrefL:nea2_128=0
...    NRBTS:cipherPrefL:nea3_128=0
...    NRDU-1:xgUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRCELL:sCellDeactivationTimerGNB=infinity
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based

@{ADD_NRREL3_NRREL12}
...    NRCELL-1/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-3:gNbId=2
...    NRCELL-1/NRREL-3:gNbIdLength=22
...    NRCELL-1/NRREL-3:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-3:lcrId=3
...    NRCELL-1/NRREL-3:removeNotAllowed=false
...    NRCELL-1/NRREL-3:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-3:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-12:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-12:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-12:gNbId=2
...    NRCELL-2/NRREL-12:gNbIdLength=22
...    NRCELL-2/NRREL-12:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-12:lcrId=12
...    NRCELL-2/NRREL-12:removeNotAllowed=false
...    NRCELL-2/NRREL-12:sCellAdditionMethod=blind
...    NRCELL-2/NRREL-12:sCellOperationalMode=dlOnly
...    NRCELL-2/NRREL-12:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-12:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-12:gnbPlmn:mncLength=3

${ADD_NRREL11}    NRCELL-1/NRREL-3:lcrId=11

@{ADD_GNB4_NRREL11}
...    NRCELL-1/NRREL-3:gNbId=35
...    NRCELL-1/NRREL-3:lcrId=6

@{PM_Counters_Check_L025_PRIM}
...    NRBTS-1:${F1_DU_P_RESET_RCV}=2
...    NRBTS-1:${F1_DU_P_RESET_ACK_SENT}=2
...    NRBTS-1:${E1_RESET_SENT_CUCP}=2
...    NRBTS-1:${E1_RESET_ACK_RECD_CUCP}=2
...    NRBTS-1:${XN_RESET_REQUEST_SENT}=2
...    NRBTS-1:${XN_RESET_RESPONSE_RECEIVED}=2

@{PM_Counters_Check_L025_EXT}
...    NRBTS-2:${F1_DU_P_RESET_RCV}=2
...    NRBTS-2:${F1_DU_P_RESET_ACK_SENT}=2
...    NRBTS-2:${XN_RESET_REQUEST_RECEIVED}=2
...    NRBTS-2:${XN_RESET_RESPONSE_SENT}=2
...    NRBTS-2:${XN_NGRAN_CONF_UPDATE_RCVD}=4
...    NRBTS-2:${XN_NGRAN_CONF_UPDATE_ACK_SENT}=4
...    NRBTS-2:${F1_CU_P_RESET_MSG_ATT}=2
...    NRBTS-2:${F1_CU_P_RESET_MSG_SUCC}=2

#para for L001_L006
@{PARAMS_add_NRREL_FOR_GNB1}
...    NRCELL-1/NRREL-4:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-4:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-4:gNbId=2
...    NRCELL-1/NRREL-4:gNbIdLength=22
...    NRCELL-1/NRREL-4:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-4:lcrId=4
...    NRCELL-1/NRREL-4:removeNotAllowed=false
...    NRCELL-1/NRREL-4:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-4:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-4:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-4:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-11:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-11:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-11:gNbId=2
...    NRCELL-1/NRREL-11:gNbIdLength=22
...    NRCELL-1/NRREL-11:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-11:lcrId=11
...    NRCELL-1/NRREL-11:removeNotAllowed=false
...    NRCELL-1/NRREL-11:sCellAdditionMethod=covBasedA1
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
...    NRCELL-1/NRREL-12:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-12:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-12:gnbPlmn:mncLength=3
...    NRCELL-1:a1MeasSCellAddEnabled=rsrp
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=2
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=70
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=80
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-1:a1MeasSCellAddSsbRsrq:a1HysteresisSCellAddSsbRsrq=0|a1TimeToTriggerSCellAddSsbRsrq=320ms
...    NRCELL-1:a1MeasSCellAddSsbRsrq:a1ThresholdSCellAddSsbRsrq=60|a1TimeToTriggerSCellAddSsbRsrq=320ms
...    NRCELL-1/NRREL-4:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-11:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-12:sCellOperationalMode=dlOnly
...    NRCELL-2/NRREL-4:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-4:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-4:gNbId=35
...    NRCELL-2/NRREL-4:gNbIdLength=22
...    NRCELL-2/NRREL-4:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-4:lcrId=5
...    NRCELL-2/NRREL-4:removeNotAllowed=false
...    NRCELL-2/NRREL-4:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-4:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-4:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-11:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-11:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-11:gNbId=35
...    NRCELL-2/NRREL-11:gNbIdLength=22
...    NRCELL-2/NRREL-11:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-11:lcrId=6
...    NRCELL-2/NRREL-11:removeNotAllowed=false
...    NRCELL-2/NRREL-11:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-11:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-11:gnbPlmn:mncLength=3
...    NRCELL-2:a1MeasSCellAddEnabled=rsrp
...    NRCELL-2:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=2
...    NRCELL-2:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=70
...    NRCELL-2:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=80
...    NRCELL-2:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-2:a1MeasSCellAddSsbRsrq:a1HysteresisSCellAddSsbRsrq=0|a1TimeToTriggerSCellAddSsbRsrq=320ms
...    NRCELL-2:a1MeasSCellAddSsbRsrq:a1ThresholdSCellAddSsbRsrq=60|a1TimeToTriggerSCellAddSsbRsrq=320ms
...    @{GNB1_A2_for_NRCELL_1}

@{GNB1_A2_for_NRCELL_1}
...    NRCELL-1:a2MeasSCellRelEnabled=rsrq
...    NRCELL-1:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=5120ms
...    NRCELL-1:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=50|a2TimeToTriggerSCellRelSsbRsrp=5120ms
...    NRCELL-1:a2MeasSCellRelSsbRsrq:a2HysteresisSCellRelSsbRsrq=0|a2TimeToTriggerSCellRelSsbRsrq=5120ms
...    NRCELL-1:a2MeasSCellRelSsbRsrq:a2ThresholdSCellRelSsbRsrq=35|a2TimeToTriggerSCellRelSsbRsrq=5120ms

@{PARAMS_ADJ_REL_FOR_GNB2}
...    NRBTS/NRADJGNB-1:administrativeState=Unlocked
...    NRBTS/NRADJGNB-1:gNbIdLength=22
...    NRBTS/NRADJGNB-1:gNodeBId=1
...    NRBTS/NRADJGNB-1:weightForIgnbCaSelection=1
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
...    NRCELL-12/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-1:gNbId=1
...    NRCELL-12/NRREL-1:gNbIdLength=22
...    NRCELL-12/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-12/NRREL-1:lcrId=1
...    NRCELL-12/NRREL-1:removeNotAllowed=false
...    NRCELL-12/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-12/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-3:weightForSCellSelection=10
...    NRCELL-4:weightForSCellSelection=30
...    NRCELL-11:weightForSCellSelection=50
...    NRCELL-12:weightForSCellSelection=60
...    @{GNB2_CA_for_NRCELL_A2rel}


@{GNB2_CA_for_NRCELL_A2rel}
...    NRCELL-4:a2MeasSCellRelEnabled=rsrp
...    NRCELL-4:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-4:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=33|a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-4:a2MeasSCellRelSsbRsrq:a2HysteresisSCellRelSsbRsrq=0|a2TimeToTriggerSCellRelSsbRsrq=0ms
...    NRCELL-4:a2MeasSCellRelSsbRsrq:a2ThresholdSCellRelSsbRsrq=23|a2TimeToTriggerSCellRelSsbRsrq=0ms
...    NRCELL-11:a2MeasSCellRelEnabled=rsrq
...    NRCELL-11:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-11:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=31|a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-11:a2MeasSCellRelSsbRsrq:a2HysteresisSCellRelSsbRsrq=0|a2TimeToTriggerSCellRelSsbRsrq=0ms
...    NRCELL-11:a2MeasSCellRelSsbRsrq:a2ThresholdSCellRelSsbRsrq=21|a2TimeToTriggerSCellRelSsbRsrq=0ms
...    NRCELL-12:a2MeasSCellRelEnabled=rsrpAndRsrq
...    NRCELL-12:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-12:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=32|a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-12:a2MeasSCellRelSsbRsrq:a2HysteresisSCellRelSsbRsrq=0|a2TimeToTriggerSCellRelSsbRsrq=0ms
...    NRCELL-12:a2MeasSCellRelSsbRsrq:a2ThresholdSCellRelSsbRsrq=22|a2TimeToTriggerSCellRelSsbRsrq=0ms

@{add_NRREL_11_under_NRCELL_2_for_simgnb}
...    NRCELL-2/NRREL-11:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-11:sCellOperationalMode=dlOnly

@{add_NRREL_4_under_NRCELL_2_for_simgnb}
...    NRCELL-2/NRREL-4:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-4:sCellOperationalMode=dlOnly

@{gnb1_actInterGnbCa_disable}
...    NRDU-1:actInterGnbCa=disabled

@{gnb1_actInterGnbCa_enable}
...    NRDU-1:actInterGnbCa=DLOnly

@{add_NRREL_12_under_NRCELL_2_for_simgnb}
...    NRCELL-2/NRREL-12:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-12:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-12:gNbId=35
...    NRCELL-2/NRREL-12:gNbIdLength=22
...    NRCELL-2/NRREL-12:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-12:lcrId=7
...    NRCELL-2/NRREL-12:removeNotAllowed=false
...    NRCELL-2/NRREL-12:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-12:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-12:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-12:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-12:sCellOperationalMode=dlOnly

@{recover_env_gnb1_nrcell2_nrrel}
...    delete:NRCELL-2/NRREL-11
...    delete:NRCELL-2/NRREL-4
...    delete:NRCELL-2/NRREL-12
...    NRDU-1:actInterGnbCa=DLOnly
...    NRBTS:iGnbCaXnCfUpBackOffTmr=0

@{recover_env_gnb1_nrcell1_nrrel}
...    delete:NRCELL-1/NRREL-3
...    delete:NRCELL-1/NRREL-4
...    delete:NRCELL-1/NRREL-11
...    delete:NRCELL-1/NRREL-12
...    delete:NRCELL-1/NRREL-45
...    delete:NRCELL-1/NRREL-46
...    delete:NRCELL-1/NRREL-47

@{recover_env_gnb2_nrrel}
...    delete:NRCELL-12/NRREL-1
...    NRDU-1:actInterGnbCa=DLOnly
...    NRCELL-3:weightForSCellSelection=10
...    NRCELL-4:weightForSCellSelection=30
...    NRCELL-11:weightForSCellSelection=50
...    NRCELL-12:weightForSCellSelection=60

@{PM_Counters_L001_L004_GNB1}
...    NRCELL-1:NCAC:${UE_PCELL_1_CONF_SCELL_DL_SA}>=1
...    NRCELL-1:NCAC:${A2MEAS_REL1DLSCELL_ATT_SA}=3
...    NRCELL-1:NCAC:${A2MEAS_REL1DLSCELL_SUCC_SA}=3
...    NRCELL-1:NCAC:${UE_PCELL_3_CONF_SCELL_DL_SA}>0
...    NRCELL-1:NCAC:${UE_PCELL_2_CONF_SCELL_DL_SA}>0
...    NRCELL-1:RSADU:${GNB_DU_SCELL_3_ADMI_REQ_SA}=3
...    NRCELL-1:RSADU:${GNB_DU_SCELL_3_ADMI_SUCC_SA}=3
...    NRCELL-1:NCAC:${IGNB_CA_ATT_3_SCELL_SA}=3
...    NRCELL-1:NCAC:${IGNB_CA_ATT_3_SCELL_SA_SUCC}=3

@{PM_Counters_L001_L004_GNB2}
...    NRCELL-4:RSADU:${GNB_DU_SCELL_ADMI_REQ_SA}=3
...    NRCELL-11:RSADU:${GNB_DU_SCELL_ADMI_REQ_SA}=3
...    NRCELL-12:RSADU:${GNB_DU_SCELL_ADMI_REQ_SA}=3
...    NRBTS-1:ADJNB:${IGNB_CA_ADD_REQ_SA_NRADJ}=3
...    NRCELL-4:RSACU:${IGNB_CA_SCELL_ADMI_REQ_SA}=3
...    NRCELL-4:RSACU:${IGNB_CA_SCELL_ADMI_SUCC_SA}=3
...    NRCELL-11:RSACU:${IGNB_CA_SCELL_ADMI_REQ_SA}=3
...    NRCELL-11:RSACU:${IGNB_CA_SCELL_ADMI_SUCC_SA}=3
...    NRCELL-12:RSACU:${IGNB_CA_SCELL_ADMI_REQ_SA}=3
...    NRCELL-12:RSACU:${IGNB_CA_SCELL_ADMI_SUCC_SA}=3
...    NRBTS-1:ADJNB:${IGNB_CA_ADD_REQ_SA_REJ_NRADJ}=0

${E1_RESET_SENT_CUCP}    M55121C00501
#Number increased by prime-gNB1-CU-CP when a RESET message for is sent out on E1.
${E1_RESET_ACK_RECD_CUCP}    M55121C00502
#Number increased by prime-gNB1-CU-CP when a RESET ACKNOWLEDGE message is received on E1.
${F1_DU_P_RESET_RCV}    M55117C01512
#Number shall be increased by ext-gNB2-DU when a RESET message for Partial Reset is received on F1.
${F1_DU_P_RESET_ACK_SENT}    M55117C01513
#Number shall be increased by ext-gNB2-DU when a RESET ACKNOWLEDGE for Partial Reset is sent out on F1.
${XN_RESET_REQUEST_SENT}    M55126C00012
#Number shall be increased by prime-gNB1-CU-CP when a RESET REQUEST message for Partial Reset is sent out on XN.
${XN_RESET_REQUEST_RECEIVED}    M55126C00010
#Number shall be increased by ext-gNB2-CU-CP when a RESET REQUEST message for Partial Reset is received on XN.
${XN_RESET_RESPONSE_SENT}    M55126C00011
#Number shall be increased by ext-gNB2-CU-CP when a RESET RESPONSE for Partial Reset is sent out on XN.
${XN_RESET_RESPONSE_RECEIVED}    M55126C00013
#Number shall be increased by prime-gNB1-CU-CP when a RESET RESPONSE for Partial Reset is received on XN.
${XN_NGRAN_CONF_UPDATE_RCVD}    M55126C00032
#Number of Xn NG-RAN Node Configuration Update received from remote gNB.
${XN_NGRAN_CONF_UPDATE_ACK_SENT}    M55126C00033
#Number of successful incoming Xn NG-RAN Node Configuration Update procedure.
${F1_CU_P_RESET_MSG_ATT}    M55150C00008
#Number of partial F1AP: Reset procedure attempted by gNB-CU.
${F1_CU_P_RESET_MSG_SUCC}    M55150C00009
#Number of successfull partial F1AP: Reset procedure completed by gNB-CU.

#count for L001_L006
${IGNB_CA_ADD_REQ_SA_NRADJ}    M55175C00001
${IGNB_CA_ATT_3_SCELL_SA}    M55118C11003
${IGNB_CA_ATT_3_SCELL_SA_SUCC}    M55118C11006
${IGNB_CA_SCELL_ADMI_REQ_SA}    M55138C03501
${IGNB_CA_SCELL_ADMI_SUCC_SA}    M55138C03502
${IGNB_CA_ADD_REQ_SA_REJ_NRADJ}    M55175C00002

${UE_PCELL_1_CONF_SCELL_DL_SA}    M55118C05507
#The sum of samples for total number of CA UEs in the current cell configured as a PCell, which have 1 configured SCell in DL.
${GNB_DU_SCELL_ADMI_REQ_SA}    M55139C01001
#This counter is updated on the SCell if an SCell was requested which is newly added in the SCell-ToBeSetupMod-List IE
#as part of F1AP: UE CONTEXT MODIFICATION REQUEST or F1AP: UE CONTEXT SETUP REQUEST (in case of Inter gNB CA) messages
#received by the DU during SCell Addition and SCell Change procedures.
${A2MEAS_REL1DLSCELL_ATT_SA}    M55118C06501
#When RRC Reconfiguration message releasing 1 S-Cell in DL is sent to UE triggered by A2 measurement on S-Cell.
#Counter is updated on the PCell.
${A2MEAS_REL1DLSCELL_SUCC_SA}    M55118C06502
#When RRC Reconfiguration Complete message, following RRC Reconfiguration releasing 1 S-Cell in DL triggered by
#A2 measurement on S-Cell, is received.
#Counter is updated on the PCell.
${UE_PCELL_3_CONF_SCELL_DL_SA}    M55118C09501
#The total number of CA UEs in the current cell configured as a PCell, which have exactly 3 configured SCells in DL in SA mode.
${UE_PCELL_2_CONF_SCELL_DL_SA}    M55118C07001
#The sum of total number of CA UEs in the current cell configured as a PCell, which have 2 configured SCells in DL in SA mode.
${UE_PCELL_1_CONF_SCELL_DL_SA}    M55118C05507
#Current number of PCell UEs with 1 configured SCell in DL is calculated when sample timer expires.
#This counter is updated on the PCell if exactly 3 SCells were requested which are newly added in the
#SCell-ToBeSetupMod-List IE as part of F1AP: UE CONTEXT MODIFICATION REQUEST messages received by the DU
#during SCell Addition procedure.
${GNB_DU_SCELL_3_ADMI_REQ_SA}    M55139C03001
${GNB_DU_SCELL_3_ADMI_SUCC_SA}    M55139C03002

@{expected_for_UE2}
...    sCellIndex 1
...    physCellId 53
...    sCellIndex 2
...    physCellId 60
...    sCellIndex 3
...    physCellId 61

#para for L024
@{PARAMS_add_NRREL_FOR_GNB1_L024}
...    NRBTS:iGnbCaXnCfUpBackOffTmr=0
...    NRCELL-1/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-3:gNbId=2
...    NRCELL-1/NRREL-3:gNbIdLength=22
...    NRCELL-1/NRREL-3:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-3:lcrId=3
...    NRCELL-1/NRREL-3:removeNotAllowed=false
...    NRCELL-1/NRREL-3:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-3:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-11:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-11:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-11:gNbId=2
...    NRCELL-1/NRREL-11:gNbIdLength=22
...    NRCELL-1/NRREL-11:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-11:lcrId=11
...    NRCELL-1/NRREL-11:removeNotAllowed=false
...    NRCELL-1/NRREL-11:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-11:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-11:gnbPlmn:mncLength=3
...    NRCELL-1:a1MeasSCellAddEnabled=rsrp
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=2
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=70
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=80
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-1:a1MeasSCellAddSsbRsrq:a1HysteresisSCellAddSsbRsrq=0|a1TimeToTriggerSCellAddSsbRsrq=320ms
...    NRCELL-1:a1MeasSCellAddSsbRsrq:a1ThresholdSCellAddSsbRsrq=60|a1TimeToTriggerSCellAddSsbRsrq=320ms
...    @{PARAMS_ADJ_REL_FOR_GNB1_to_simGNB4_L024}

@{PARAMS_ADJ_REL_FOR_GNB1_to_simGNB4_L024}
...    NRCELL-2/NRREL-4:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-4:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-4:gNbId=35
...    NRCELL-2/NRREL-4:gNbIdLength=22
...    NRCELL-2/NRREL-4:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-4:lcrId=5
...    NRCELL-2/NRREL-4:removeNotAllowed=false
...    NRCELL-2/NRREL-4:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-4:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-4:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-11:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-11:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-11:gNbId=35
...    NRCELL-2/NRREL-11:gNbIdLength=22
...    NRCELL-2/NRREL-11:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-11:lcrId=6
...    NRCELL-2/NRREL-11:removeNotAllowed=false
...    NRCELL-2/NRREL-11:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-11:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-11:gnbPlmn:mncLength=3
...    NRCELL-2:a1MeasSCellAddEnabled=rsrp
...    NRCELL-2:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=2
...    NRCELL-2:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=70
...    NRCELL-2:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=80
...    NRCELL-2:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-2:a1MeasSCellAddSsbRsrq:a1HysteresisSCellAddSsbRsrq=0|a1TimeToTriggerSCellAddSsbRsrq=320ms
...    NRCELL-2:a1MeasSCellAddSsbRsrq:a1ThresholdSCellAddSsbRsrq=60|a1TimeToTriggerSCellAddSsbRsrq=320ms

@{add_sCellAdditionMethod_under_NRREL_11}
...    NRCELL-1/NRREL-11:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-11:sCellOperationalMode=dlOnly

@{add_NRREL_45_46_under_NRCELL_1}
...    NRCELL-1/NRREL-45:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-45:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-45:gNbId=35
...    NRCELL-1/NRREL-45:gNbIdLength=22
...    NRCELL-1/NRREL-45:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-45:lcrId=5
...    NRCELL-1/NRREL-45:removeNotAllowed=false
...    NRCELL-1/NRREL-45:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-45:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-45:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-45:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-45:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-46:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-46:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-46:gNbId=35
...    NRCELL-1/NRREL-46:gNbIdLength=22
...    NRCELL-1/NRREL-46:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-46:lcrId=6
...    NRCELL-1/NRREL-46:removeNotAllowed=false
...    NRCELL-1/NRREL-46:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-46:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-46:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-46:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-46:sCellOperationalMode=dlOnly

@{update_NRREL_45_to_gnb2_nrcell12}
...    NRCELL-1/NRREL-45:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-45:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-45:gNbId=2
...    NRCELL-1/NRREL-45:gNbIdLength=22
...    NRCELL-1/NRREL-45:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-45:lcrId=12
...    NRCELL-1/NRREL-45:removeNotAllowed=false
...    NRCELL-1/NRREL-45:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-45:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-45:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-45:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-45:sCellOperationalMode=dlOnly

@{iGnbCaXnCfUpBackOffTmr_300s}
...    NRBTS:iGnbCaXnCfUpBackOffTmr=300

@{add_NRREL_4_under_NRCELL_1}
...    NRCELL-1/NRREL-4:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-4:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-4:gNbId=2
...    NRCELL-1/NRREL-4:gNbIdLength=22
...    NRCELL-1/NRREL-4:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-4:lcrId=4
...    NRCELL-1/NRREL-4:removeNotAllowed=false
...    NRCELL-1/NRREL-4:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-4:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-4:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-4:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-4:sCellOperationalMode=dlOnly

@{add_NRREL_47_under_NRCELL_1}
...    NRCELL-1/NRREL-47:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-47:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-47:gNbId=35
...    NRCELL-1/NRREL-47:gNbIdLength=22
...    NRCELL-1/NRREL-47:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-47:lcrId=7
...    NRCELL-1/NRREL-47:removeNotAllowed=false
...    NRCELL-1/NRREL-47:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-47:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-47:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-47:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-47:sCellOperationalMode=dlOnly

@{add_NRREL_48_under_NRCELL_1_for_simgnb_cell5}
...    NRCELL-1/NRREL-48:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-48:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-48:gNbId=35
...    NRCELL-1/NRREL-48:gNbIdLength=22
...    NRCELL-1/NRREL-48:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-48:lcrId=5
...    NRCELL-1/NRREL-48:removeNotAllowed=false
...    NRCELL-1/NRREL-48:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-48:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-48:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-48:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-48:sCellOperationalMode=dlOnly

@{delete_NRREL_45_to_gnb2_nrcell12_and_NRREL_48_under_NRCELL_1_for_simgnb_cell5}
...    delete:NRCELL-1/NRREL-45
...    delete:NRCELL-1/NRREL-48

@{add_NRREL_45_to_simgnb_cell5_delete_NRREL-3_add_NRREL-12}
...    NRCELL-1/NRREL-45:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-45:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-45:gNbId=35
...    NRCELL-1/NRREL-45:gNbIdLength=22
...    NRCELL-1/NRREL-45:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-45:lcrId=5
...    NRCELL-1/NRREL-45:removeNotAllowed=false
...    NRCELL-1/NRREL-45:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-45:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-45:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-45:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-45:sCellOperationalMode=dlOnly
...    delete:NRCELL-1/NRREL-3
...    NRCELL-1/NRREL-12:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-12:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-12:gNbId=2
...    NRCELL-1/NRREL-12:gNbIdLength=22
...    NRCELL-1/NRREL-12:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-12:lcrId=12
...    NRCELL-1/NRREL-12:removeNotAllowed=false
...    NRCELL-1/NRREL-12:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-12:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-12:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-12:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-12:sCellOperationalMode=dlOnly

@{PARAMS_FOR_GNB2_L024}
...    NRDU-1:actInterGnbCa=DLOnly
...    NRCELL-3:weightForSCellSelection=60
...    NRCELL-4:weightForSCellSelection=60
...    NRCELL-11:weightForSCellSelection=60
...    NRCELL-12:weightForSCellSelection=60

@{expected_for_add_scell_physCellId_53}
...    sCellIndex 1
...    physCellId 52

@{expected_for_add_scell_physCellId_53_physCellId_60}
...    sCellIndex 1
...    physCellId 52
...    sCellIndex 2
...    physCellId 60

@{expected_for_add_scell_physCellId_53_physCellId_60_physCellId_61}
...    sCellIndex 1
...    physCellId 52
...    sCellIndex 2
...    physCellId 60
...    sCellIndex 3
...    physCellId 61

*** Test Cases ***
CB008140-ET-L025_Online_modification_Add_ext_caRel_firstextscellofextgnb_nopre_IGNBxnxp_inPrimeGNB
    [Documentation]
    ...    [purpose]:
    ...    This user scenario verifies gNB's behavior to support addition of ext_ca_Rel instance:the addition of sCellAdditionMethod for
    ...    an existing NRREL instance referring to an NRADJNRCELL instance, or the addition of an NRREL instance referring to an NRADJNRCELL
    ...    instance with sCellAdditionMethod configured,or the modification of NRREL.lcrId and or NRREL.gNbId and or NRREL.gNbIdLength and or
    ...    NRREL.gnbPlmn for an NRREL instance with sCellAdditionMethod configured.
    ...    Such modification actually removes an old ext_ca_Rel and adds a new ext_ca_Rel.
    ...    [Configuration]:
    ...    GNB-1 Pri: cell1-TDD(n77)(pci:50) cell2-TDD(n77)(pci:51)
    ...    GNB-2 ext: cell3-TDD(n77)(pci:52) cell4-TDD(n77)(pci:53) cell11-FDD(n3)(pci:60) cell12-FDD(n28)(pci:61)
    ...    [Test Case Steps]
    ...         a.online modify add new ext_ca_NRREL cell2_3 for cell1_1 and cell2_12 for cell1_2
    ...         b.UE1 register to gnb1-cell1
    ...         c.PDU session setup, scell cell2_3 blind addition successful
    ...         d.run dl/ul traffic for UE1
    ...         e.online modify change ext_ca_NRREL from cell2_3 to cell2_11 for cell1_1, then UE1 Bulk Release and E1,F1,NG,XN reset.
    ...           Tow Msgs IgNBCAConfigurationUpdateIndication of cell2_3 remove and cell2_11 add are triggerd cause 'iGnbCaXnCfUpBackOffTmr=0'.
    ...         f.UE2 register to gnb1-cell1
    ...         g.PDU session setup for UE2, scell cell2_11 blind addition successful
    ...         d.run dl/ul traffic for UE2
    ...         h.online modify change ext_ca_NRREL sim gnb cell4_11, then UE2 Bulk Release and E1,F1,NG,XN reset.
    ...         i.Check counters and logs
    [Tags]    QC_279998    CA_LABLE-TF(100MHz_TDD_n77+10MHz_FDD_n3)    CA_LABLE-TT(100MHz_TDD_n77+100MHz_TDD_n77)
    OnlineParamChange    ${ADD_NRREL3_NRREL12}
    Get correct xp xgu version
    Ue Register And PDU Session Setup with blind scell addition    ue_id=1    gateway=1    enb_id=2    cell_id=1
    ...    regexp=PhysCellId: 52] SCellIndex 1 activated
    Run Traffic And Verify Throughput    ue_id=1    pdu_id=1
    OnlineParamChange    ${ADD_NRREL11}
    Ue Register And PDU Session Setup with blind scell addition    ue_id=2    gateway=2    enb_id=2    cell_id=1
    ...    regexp=PhysCellId: 60] SCellIndex 1 activated
    Run Traffic And Verify Throughput    ue_id=2    pdu_id=1
    Setup XpAP Link
    Set Sim gNB ignb CA Addition Param    IgNBCAXpProtocolVersion=${C_XpVersion}    IgNBCAXgUProtocolVersion=${C_XgUVersion}
    OnlineParamChange    ${ADD_GNB4_NRREL11}
    send ignbcaconfigurationupdate from simgnb4
    Check alarm of Xp Xg version with simGNB mismatch is not raised    xpfaultid=7108    xgfaultid=7109
    Release UEs    ue_type=all
    Check Wireshark Log    ${CURDIR}${/}A2A_L_025${/}a2a.ini    wait_string=UEContextRelease::0
    Check Counters    ${PM_Counters_Check_L025_PRIM}
    Check Counters GNB2    ${PM_Counters_Check_L025_EXT}
    [Teardown]    case recover

CB008140-ET-L001_L004_InterGnbCaXpVersionMismatchAl_raise_and_alarm_cancel
    [Documentation]
    ...    This user scenario describes recovery from the incompatible inter-gNB CA Xp-U protocol version alarm with the
    ...    ext-gNB by the disabling Inter-gNB CA feature activation flag on the prime-gNB1 side. and also recovery from
    ...    the incompatible inter-gNB CA Xp-U protocol version alarm with the ext-gNB by the upgrading ext-gNB to the
    ...    software load with the proper inter-gNB CA Xp-U protocol version.
    ...    [Configuration]:
    ...    Cell id=1 gnb=2 pci=16:2 tac=200 tdd_cell=on band=n77 nr_arfcn=663400:663400 gscn=8159 chBw=100MHz
    ...    Cell id=2 gnb=2 pci=17:0 tac=200 tdd_cell=on band=n77 nr_arfcn=658000:658000 gscn=8103 chBw=40MHz
    ...    Cell id=3 gnb=3 pci=17:1 tac=200 tdd_cell=on band=n77 nr_arfcn=653400:653400 gscn=8072 chBw=100MHz SCellWeight=10
    ...    Cell id=4 gnb=3 pci=17:2 tac=200 tdd_cell=on band=n77 nr_arfcn=648000:648000 gscn=8000 chBw=40MHz SCellWeight=30
    ...    Cell id=11 gnb=3 pci=20:0 tac=200 tdd_cell=off band=n3 nr_arfcn=349400:368400 gscn=4605 chBw=10MHz SCellWeight=50
    ...    Cell id=12 gnb=3 pci=20:1 tac=200 tdd_cell=off band=n28 nr_arfcn=143400:153400 gscn=1916 chBw=15MHz SCellWeight=60
    ...    Cell id=5 gnb=4 pci=18:0 tac=200 tdd_cell=on band=n77 nr_arfcn=648000:648000 gscn=8000 chBw=40MHz SCellWeight=50
    ...    Cell id=6 gnb=4 pci=21:0 tac=200 tdd_cell=off band=n3 nr_arfcn=349400:368400 gscn=4605 chBw=10MHz SCellWeight=50
    ...    Cell id=7 gnb=4 pci=21:1 tac=200 tdd_cell=off band=n28 nr_arfcn=143400:153400 gscn=1916 chBw=15MHz SCellWeight=50
    ...    2.Test Case Steps:
    ...         a. alarm raise when version mismatch and make a background CAUE, update message IgNBCAConfigurationUpdateIndication
    ...            about add NRREL_11 lcrId=6 (ext_sim_gnb-4_lcrId=6) stillsendout when XpVersion is NOK
    ...             CA UE:PCell_gnb2-1(100Mhz_TDD_n77)
    ...                   SCell_gnb3-4(40Mhz_TDD_n77)+ SCell_gnb3-11(10Mhz_FDD_n3)+ SCell_gnb3-12(15Mhz_FDD_n28)
    ...         b. alarm cancel when actInterGnbCa disable, the background CAUE is not affected
    ...         c. make a normal CA UE, but no intergnb A1 can be configured or no scell added
    ...         d. alarm raise again about XpVersion mismatch when (prime-gnb2) actInterGnbCa enable
    ...         e. alarm cancel when find (Set ext-gnb-4'Xp Version to be same with prime-gnb-2) version match
    ...         f. make a normal CA UE, scell can be added
    ...         g. alarm notraise with (prime-gnb2) actInterGnbCa disable and enable again, the background CAUE is ok with scellrelease and scelladd
    [Tags]    QC_280500    CA_LABLE-TTFF(100Mhz_TDD_n77+40Mhz_TDD_n77+10Mhz_FDD_n3+15Mhz_FDD_n28)
    preconfiguration add for case
    Clear Counter Files for 2GNB
    alarm_raise_when_versionmismatch_and_make_a_background_CAUE    XpVersion=${W_XpVersion}
    ...    XgUVersion=${C_XgUVersion}    faultid=7108    alarmid=7115    faultname=${7108_fault_name}
    alarm_cancel_when_actInterGnbCa_disable    faultid=7108
    Make Normal CA SA UE1 nonCA
    alarm_raise_again_about_versionmismatch_when_actInterGnbCa_enable    faultid=7108    alarmid=7115    faultname=${7108_fault_name}
    alarm_cancel_when_versionmatch    faultid=7108
    Make Normal CA SA UE3
    alarm_notraise_with_FAF_change    faultid=7108
    ALLUE Deregister From gNB
    Check Wireshark and Counter
    [Teardown]    case recover

CB008140-ET-L002_L005_InterGnbCaXguVersionMismatchAl_raise_and_alarm_cancel
    [Documentation]
    ...    This user scenario describes recovery from the incompatible inter-gNB CA Xg-U protocol version alarm with the
    ...    ext-gNB by the disabling Inter-gNB CA feature activation flag on the prime-gNB1 side. and also recovery
    ...    from the incompatible inter-gNB CA Xg-U protocol version alarm with the ext-gNB by the upgrading ext-gNB to
    ...    the software load with the proper inter-gNB CA Xp-U protocol version.
    ...    [Configuration]:
    ...    same as L001_L004
    ...    2.Test Case Steps:
    ...         a. alarm raise when Xg-U version mismatch and make a background CAUE, update IgNBCAConfigurationUpdateIndication
    ...            about add NRREL_11 lcrId=6 (ext_sim_gnb-4_lcrId=6) stillsendout when Xg-U version is NOK
    ...         b. alarm cancel when (prime-gnb2) actInterGnbCa disable, the background CAUE is not affected
    ...         c. alarm raise again about versionmismatch when (prime-gnb2) actInterGnbCa enable
    ...         d. alarm cancel when find (Set ext-gnb-4'Xg Version to be same with prime-gnb-2) version match
    ...         e. alarm notraise with (prime-gnb2) actInterGnbCa disable and enable again, the background CAUE is ok with scellrelease and scelladd
    [Tags]    QC_280501    CA_LABLE-TTFF(100Mhz_TDD_n77+40Mhz_TDD_n77+10Mhz_FDD_n3+15Mhz_FDD_n28)
    preconfiguration add for case
    alarm_raise_when_versionmismatch_and_make_a_background_CAUE    XpVersion=${C_XpVersion}
    ...    XgUVersion=${W_XgUVersion}    faultid=7109    alarmid=7115    faultname=${7109_fault_name}
    alarm_cancel_when_actInterGnbCa_disable    faultid=7109
    alarm_raise_again_about_versionmismatch_when_actInterGnbCa_enable    faultid=7109    alarmid=7115    faultname=${7109_fault_name}
    alarm_cancel_when_versionmatch    faultid=7109
    alarm_notraise_with_FAF_change    faultid=7109
    check ue alive and deregister    ue_id=2    pdu_id=2
    Check Wireshark Log    ${CURDIR}${/}A2A_L_002_005${/}a2a.ini    wait_string=UEContextRelease::10
    [Teardown]    case recover

CB008140-ET-L003_L006_InterGnbCaXnVersionMismatchAl_raise_and_alarm_cancel
    [Documentation]
    ...    This user scenario describes recovery from the incompatible inter-gNB CA Xn protocol version alarm with the ext-gNB3
    ...    by the disabling Inter-gNB CA feature activation flag on the prime-gNB1 side.
    ...    [Configuration]:
    ...    same as L001_L004
    ...         a. alarm raise when XnVersion Mismatch and make a background CAUE, update IgNBCAConfigurationUpdateIndication
    ...            message about add NRREL_11 lcrId=6 (ext_sim_gnb-4_lcrId=6) not sendout when XnVersionMismatch is NOK
    ...         b. alarm cancel when (prime-gnb2) actInterGnbCa disable, the background CAUE is not affected,
    ...         c. alarm raise again about (XnVersionMissmatch) when (prime-gnb2) actInterGnbCa enable
    ...         d. alarm cancel when find (Drop Xn Link between prime-gnb2 and ext-sim_gnb4 and then Setup XnLink) version match
    ...         e. alarm notraise after FAF change, the background CAUE is ok with scellrelease and scelladd
    [Tags]    QC_280502    CA_LABLE-TTFF(100Mhz_TDD_n77+40Mhz_TDD_n77+10Mhz_FDD_n3+15Mhz_FDD_n28)
    preconfiguration add for case
    set ignb_ca_setup_param precondition
    alarm_raise_when_versionmismatch_and_make_a_background_CAUE    XpVersion=${C_XpVersion}
    ...    XgUVersion=${C_XgUVersion}    faultid=7328    alarmid=7115    faultname=${7328_fault_name}
    alarm_cancel_when_actInterGnbCa_disable    faultid=7328
    alarm_raise_again_about_versionmismatch_when_actInterGnbCa_enable    faultid=7328    alarmid=7115    faultname=${7328_fault_name}
    alarm cancel after resetup xnlink then ignbcasetup
    alarm_notraise_with_FAF_change    faultid=7328
    check ue alive and deregister    ue_id=2    pdu_id=2
    Check Wireshark Log    ${CURDIR}${/}A2A_L_003_006${/}a2a.ini    wait_string=UEContextRelease::10
    [Teardown]    case recover

CB008140-ET-L024_Online_modification_Add_ext_caRel_notfirstextscellofextgnb_inPrimeGNB_with_iGnbCaXnCfUpBackOffTmr_configure
    [Documentation]
    ...    This user scenario describes gNB behavior to support addition of ext_ca_Rel instance: 5G_CP_ARC_ALG_9727
    ...    [Configuration]:
    ...    same as L001_L004
    ...    2.Test Case Steps:
    ...         a. set the scf configuration and simgnb configure: on gnb2 configure NRREL-3 refer to gnb3
    ...         b. make a CA UE-2 with scell nrcell-3 gnb3
    ...         c. online add nrrel of nrcell-11 gnb3, make a CA ue-3 with scell nrcell-3 nrcell-11 gnb3
    ...         d. add simgnb nrrel refer to lcrld 5 6, then update lcrld 5 to nrcell-12 gnb3
    ...         e. make a CA ue-2 with nrcell-3 nrcell-11 nrcell-12 gnb3
    ...         f. set GnbCaXnCfUpBackOffTmr timer, and do online change
    ...            1. add NRREL-4 refer to gnb3 nrcell-4, igNBCAConfigurationUpdate sendout, GnbCaXnCfUpBackOffTmr for gnb3 start
    ...            2. add NRREL-47 refer to simgnb4 lcrld 7, igNBCAConfigurationUpdate sendout, GnbCaXnCfUpBackOffTmr for gnb4 start
    ...            3. add_NRREL_48_under_NRCELL_1_for_simgnb_cell5
    ...            4. delete_NRREL_45_to_gnb2_nrcell12_and_NRREL_48_under_NRCELL_1_for_simgnb_cell5
    ...            5. add_NRREL_45_to_simgnb_cell5_delete_NRREL-3_add_NRREL-12
    ...            check the message conbine is correct
    ...            only one igNBCAConfigurationUpdate about celltoremove nrcell-3 gnb3,
    ...            only one igNBCAConfigurationUpdate about celltoadd to simgnb lcrld 5
    ...            6. now on gnb2: the nrcell-4 nrcell-11 nrcell-12 of gnb3 are configured
    ...                            the nrrel-46 nrrel-47 nrrel-45 of gnb4 are configured
    [Tags]    QC_281426    CA_LABLE-TTFF(100Mhz_TDD_n77+40Mhz_TDD_n77+10Mhz_FDD_n3+15Mhz_FDD_n28)
    preconfiguration add for case    ${PARAMS_add_NRREL_FOR_GNB1_L024}    ${PARAMS_FOR_GNB2_L024}
    Setup XpAP Link
    Set Sim gNB ignb CA Addition Param    IgNBCAXpProtocolVersion=${C_XpVersion}    IgNBCAXgUProtocolVersion=${C_XgUVersion}
    Make Normal CA SA UE2 with one scell nrcell-3
    OnlineParamChange_on_gnb1    ${add_sCellAdditionMethod_under_NRREL_11}
    Make Normal CA SA UE3 with two scells nrcell-3 nrcell-11
    OnlineParamChange_on_gnb1    ${add_NRREL_45_46_under_NRCELL_1}
    send ignbcaconfigurationupdate from simgnb4
    OnlineParamChange_on_gnb1    ${update_NRREL_45_to_gnb2_nrcell12}
    Make Normal CA SA UE2 after release with scells nrcell-3 nrcell-11 nrcell-12
    OnlinemodifyiGnbCaXnCfUpBackOffTmr_test_messagecombine
    Check Wireshark Log    ${CURDIR}${/}A2A_L_024${/}a2a.ini    wait_string=UEContextRelease::0
    [Teardown]    case recover

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup    #wait for XNAP setup
    Setup 2Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_gnb1_2T_gnb2_2T2F

Check alarm of Xp Xg version with simGNB mismatch is not raised
    [Arguments]    ${xpfaultid}=7108    ${xgfaultid}=7109
    FM Fault Should Be Cleared    fault_id=${xpfaultid}
    FM Fault Should Be Cleared    fault_id=${xgfaultid}

Setup XpAP Link
    Execute Egate Command    sim_trace enb=4 protocol=xp,xn on
    Execute Egate Command    link_drop link=xp msg_type=shutdown by=gnb:4 to=gnb:2
    BuiltIn.Log    check expect xplink setup as expect    console=${True}
    Wait Until Keyword Succeeds    5 min    10 sec    Object Should Exist    XPIFREMOTE_R-2:xpLinkStatus=unavailable
    Execute Egate Command    enb_xp_param xp_peers=2 id=4    pass_regexp=is up    timeout=260s

OnlineParamChange
    [Arguments]    ${Online_Param1}
    Delta Commission Parameters    ${Online_Param1}
    Cells Should Be Onair    check_sib=${True}

Ue Register And PDU Session Setup with blind scell addition
    [Arguments]    ${ue_id}=1    ${gateway}=1    ${enb_id}=2    ${cell_id}=1    ${regexp}=SCellIndex 1 activated
    Execute Egate Command    ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${gateway}    pass_regexp=${regexp}
    Sleep    5s    #wait all sysinfo

Run Traffic And Verify Throughput
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${sleep_time}=15s
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=3    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=4    UE ${ue_id}: UDP DL
	Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=5    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=ul mbps=50 trf_id=1    UE ${ue_id}: UDP UL
    Verify Throughput    ue_id=${ue_id}    pdu_id=${pdu_id}    Tput_dl=540    Tput_ul=40

Verify Throughput
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${Tput_dl}=360    ${Tput_ul}=40    ${sleep_time}=10s
    Execute Egate Command    ue_disp
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=ul    rate_type=ave
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-5 type=pdsch    Throughput
    Should Not Match Regexp    ${scell_tput}    CellIndex-. *0 *0 *0 *0
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

preconfiguration add for case
    [Arguments]    ${PARAMS_FOR_GNB1}=${PARAMS_add_NRREL_FOR_GNB1}    ${PARAMS_FOR_GNB2}=${PARAMS_ADJ_REL_FOR_GNB2}
    OnlineParamChange_on_gnb1    ${PARAMS_FOR_GNB1}
    OnlineParamChange_on_gnb2    ${PARAMS_FOR_GNB2}
    Get correct xp xgu version

Get correct xp xgu version
    ${IgNBCAXpProtocol_Version}    Get Xp Version
    ${IgNBCAXgUProtocol_Version}    Get Xgu Version
    set test variable    ${C_XpVersion}    ${IgNBCAXpProtocol_Version}
    set test variable    ${C_XgUVersion}    ${IgNBCAXgUProtocol_Version}

case recover
    OnlineParamChange_on_gnb1    ${recover_env_gnb1_nrcell1_nrrel}
    OnlineParamChange_on_gnb1    ${recover_env_gnb1_nrcell2_nrrel}
    OnlineParamChange_on_gnb2    ${recover_env_gnb2_nrrel}
    Common Test Teardown And Stop Capture Logs

set ignb_ca_setup_param precondition
    Execute Egate Command    ignb_ca_setup_param id=4 action=fail fail_cause=incompatible_xn_protocol_version

ALLUE Deregister From gNB
    check ue alive and deregister    ue_id=1    pdu_id=1
    check ue alive and deregister    ue_id=2    pdu_id=2
    check ue alive and deregister    ue_id=3    pdu_id=3

check ue alive and deregister
    [Arguments]    ${ue_id}    ${pdu_id}
    execute egate command    ue_disp id=${ue_id} state=ACTIVE     pass_regexp=ACTIVE
    UE Deregister From gNB    ${ue_id}    ${pdu_id}

UE Deregister From gNB
    [Arguments]    ${ue_id}    ${pdu}
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=${pdu}    Traffic was stopped
    Execute Egate Command    ue_pdu_session_release ue=${ue_id} pdu=${pdu}    Successfully released PDU Session
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s

Check Wireshark and Counter
    Check Wireshark Log    ${CURDIR}${/}A2A_L_001_004${/}a2a.ini    wait_string=UEContextRelease::30
    Check Counters    ${PM_Counters_L001_L004_GNB1}
    Check Counters GNB2    ${PM_Counters_L001_L004_GNB2}

alarm_raise_when_versionmismatch_and_make_a_background_CAUE
    [Arguments]    ${XpVersion}=13    ${XgUVersion}=1    ${faultid}=7108    ${alarmid}=7115    ${faultname}=${7108_fault_name}
    Setup XpAP Link
    Set Sim gNB ignb CA Addition Param    IgNBCAXpProtocolVersion=${XpVersion}    IgNBCAXgUProtocolVersion=${XgUVersion}
    OnlineParamChange_on_gnb1    ${add_NRREL_4_under_NRCELL_2_for_simgnb}
    send ignbcaconfigurationupdate from simgnb4
    Check fault raised    fault_id=${faultid}    alarm_id=${alarmid}    faultid_fault_name=${faultname}
    Make Normal CA SA UE2
    OnlineParamChange_on_gnb1    ${add_NRREL_11_under_NRCELL_2_for_simgnb}

Check xnLink refer to simgnb should be unavailable
    BuiltIn.Log    check expect xnlink setup as expect    console=${True}
    Object Should Exist    XNLINK-2:xnLinkStatus=unavailable

alarm cancel after resetup xnlink then ignbcasetup
    Execute Egate Command    ignb_ca_setup_param id=4 reset
    Execute Egate Command    link_drop link=xn by=gnb:4 to=gnb:2
    Wait Until Keyword Succeeds    5 min    10 sec    Check xnLink refer to simgnb should be unavailable
    Execute Egate Command    gnb_xn_link_up gnb=4 target=2    GNB-4: XnAP Link with GNB-2
    sleep    30s    #sleep for ignbcasetuprequest
    send ignbcaconfigurationupdate from simgnb4
    Wait Until Keyword Succeeds    5 min    10 sec    FM Fault Should Be Cleared    fault_id=7328

alarm_cancel_when_actInterGnbCa_disable
    [Arguments]    ${faultid}=7108
    OnlineParamChange_on_gnb1    ${gnb1_actInterGnbCa_disable}
    Wait Until Keyword Succeeds    5 min    10 sec    FM Fault Should Be Cleared    fault_id=${faultid}
    OnlineParamChange_on_gnb1    ${add_NRREL_12_under_NRCELL_2_for_simgnb}

alarm_raise_again_about_versionmismatch_when_actInterGnbCa_enable
    [Arguments]    ${faultid}=7108    ${alarmid}=7115    ${faultname}=${7108_fault_name}
    OnlineParamChange_on_gnb1    ${gnb1_actInterGnbCa_enable}
    Check fault raised    fault_id=${faultid}    alarm_id=${alarmid}    faultid_fault_name=${faultname}

alarm_cancel_when_versionmatch
    [Arguments]    ${faultid}=7108
    Send Correct Version Again    IgNBCAXpProtocolVersion=${C_XpVersion}    IgNBCAXgUProtocolVersion=${C_XgUVersion}
    Wait Until Keyword Succeeds    5 min    10 sec    FM Fault Should Be Cleared    fault_id=${faultid}

alarm_notraise_with_FAF_change
    [Arguments]    ${faultid}=7108
    OnlineParamChange_on_gnb1    ${gnb1_actInterGnbCa_disable}
    OnlineParamChange_on_gnb1    ${gnb1_actInterGnbCa_enable}
    send ignbcaconfigurationupdate from simgnb4
    Wait Until Keyword Succeeds    5 min    10 sec    FM Fault Should Be Cleared    fault_id=${faultid}
    Trigger stepwise A2releaes scells213 and check traffic    ue_id=2    pdu_id=2

Check fault raised
    [Arguments]    ${fault_id}=7108    ${alarm_id}=7115    ${faultid_fault_name}=${7108_fault_name}
    ${fault_alarm}    Create List    fault_id=${fault_id}    alarm_id=${alarm_id}    severity=Minor
    ...    fault_name=${faultid_fault_name}
    wait until keyword succeeds    300    5    Fm Fault Should Be Raised    ${fault_alarm}    40

Send Correct Version Again
    [Arguments]    ${IgNBCAXpProtocolVersion}=12    ${IgNBCAXgUProtocolVersion}=1
    ${gNB4_param}    catenate
    ...    gnb_param id=4 bwp_profile_id=1 bwp_profile_type=powersaving act_multiple_dedicated_bwps=yes location_bw_ul=1:2 location_bw_dl=3:4
    ...    Inter_gNB_CA_Allowed=yes CellLoadReportingPeriodicity=000 IgNBCAXpProtocolVersion=${IgNBCAXpProtocolVersion}
    ...    IgNBCAXgUProtocolVersion=${IgNBCAXgUProtocolVersion}
    Execute Egate Command    ${gNB4_param}
    Execute Egate Command    ignb_ca_configuration_update_indication_send id=4 target=2    pass_regexp=Sent to GNB-2

Modify Cfg
    ${gNB4_sim_configuration}    catenate
    ...    set_gnb id=4 type=simulated plmn=311:489 ng=10.0.1.125 gnb_id=0x23:22 daemon=10.0.2.1:22222 x2_peers=none xn=10.0.1.124
    ...    nssai=0x1:0xd143a5 amf=1 xp=10.0.1.124:32742 xpu=10.0.1.124:32742 xp_management=on
    Update Cfg    ${gNB4_sim_configuration}
    ${gNB4_Cell11_sim_configuration}    catenate
    ...    set_cell id=6 gnb=4 pci=21:0 tac=200 nrci=0x06 tdd_cell=off proxy=10.0.2.90:9999 nr_arfcn=349400:368400 gscn=4605
    ...    nr_scs=15kHz bs_channel_bandwidth=10MHz mandatory_for_activation=off
    Update Cfg    ${gNB4_Cell11_sim_configuration}
    ${gNB4_Cell12_sim_configuration}    catenate    set_cell id=7 gnb=4 pci=21:1 tac=200 nrci=0x07 tdd_cell=off proxy=10.0.2.91:9999
    ...    nr_arfcn=143400:153400 gscn=1916 nr_scs=15kHz bs_channel_bandwidth=15MHz mandatory_for_activation=off
    Update Cfg    ${gNB4_Cell12_sim_configuration}
    ${gNB4_Cell4_sim_configuration}    catenate    set_cell id=5 gnb=4 pci=18:0 tac=200 nrci=0x05 tdd_cell=on proxy=10.0.2.92:9999
    ...    nr_arfcn=648000:648000 gscn=8000 nr_scs=30kHz bs_channel_bandwidth=40MHz
    Update Cfg    ${gNB4_Cell4_sim_configuration}

Clear Counter Files for 2GNB
    Clear Counter Files    ${False}
    Clear Counter Files GNB2

Set Sim gNB ignb CA Addition Param
    [Arguments]    ${IgNBCAXpProtocolVersion}=12    ${IgNBCAXgUProtocolVersion}=1
    ${gNB4_param}    catenate
    ...    gnb_param id=4 bwp_profile_id=1 bwp_profile_type=powersaving act_multiple_dedicated_bwps=yes location_bw_ul=1:2 location_bw_dl=3:4
    ...    Inter_gNB_CA_Allowed=yes CellLoadReportingPeriodicity=000 IgNBCAXpProtocolVersion=${IgNBCAXpProtocolVersion}
    ...    IgNBCAXgUProtocolVersion=${IgNBCAXgUProtocolVersion}
    Execute Egate Command    ${gNB4_param}
    Execute Egate Command    gnb_cell_param gnb=4 id=6 Cell_BWP_List=1,2 cell_Available=yes weightForSCellSelection=50 lteNrDssMode=lteNrDssModeNone
    Execute Egate Command    gnb_cell_param gnb=4 id=7 Cell_BWP_List=1,2 cell_Available=yes weightForSCellSelection=50 lteNrDssMode=lteNrDssModeNone
    Execute Egate Command    gnb_cell_param gnb=4 id=5 Cell_BWP_List=1,2 cell_Available=yes weightForSCellSelection=50 lteNrDssMode=lteNrDssModeNone

send ignbcaconfigurationupdate from simgnb4
    Execute Egate Command    ignb_ca_configuration_update_indication_send id=4 target=2    pass_regexp=Sent to GNB-2

Make Normal CA SA UE2
    Sa Ue Attach    ue_id=2    gateway=2    enb_id=2    cell_id=1
    Setup pdu session with no scell    ue_id=2    gateway=2    pdu_id=2
    trigger A1 MR to add scell    rsrp=100    ue_id=2
    Send And Verify Throuput    ue_id=2    pdu_id=2

Make Normal CA SA UE1 nonCA
    Sa Ue Attach    ue_id=1    gateway=1    enb_id=2    cell_id=1
    Setup pdu session with no scell    ue_id=1    gateway=1    pdu_id=1    fail_reg=eventId eventA1
    Execute Egate Command    ue_meas_cfg_disp id=1
    Execute Egate Command    data_trf_start ue=1 pdu=1 qfi=1 dir=dl mbps=10 trf_id=2    UE 1: UDP DL

Make Normal CA SA UE3
    Sa Ue Attach    ue_id=3    gateway=3    enb_id=2    cell_id=1
    Setup pdu session with no scell    ue_id=3    gateway=3    pdu_id=3    fail_reg=sCellIndex 1
    Execute Egate Command    data_trf_start ue=3 pdu=3 qfi=1 dir=dl mbps=10 trf_id=2    UE 3: UDP DL
    trigger A1 MR to add scell    rsrp=100    ue_id=3

Sa Ue Attach
    [Arguments]    ${ue_id}=1    ${gateway}=1    ${enb_id}=2    ${cell_id}=2    ${pass_regexp}=NG RM Register
    Execute Egate Command    sim_debug_log level=4
    Execute Egate Command    ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    ${pass_regexp}

Setup pdu session with no scell
    [Arguments]    ${ue_id}=1    ${gateway}=1    ${pdu_id}=1    ${fail_reg}=sCellIndex 1
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    ${ret1}=    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} nwslice=1 gw=${gateway}
    ...    fail_regexp=${fail_reg}

trigger A1 MR to add scell
    [Arguments]    ${rsrp}=80    ${ue_id}=1    ${ssbfreq}=663360
    ${meas_id}    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=${ssbfreq}    event_type=A1
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrq_nr=70 srsrp_nr=${rsrp}
    ...    pass_regexp=${expected_for_UE2}    timeout=20s

Send And Verify Throuput
    [Arguments]    ${ue_id}=91    ${pdu_id}=2
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=2 qfi=1 dir=dl mbps=150 trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=2 qfi=1 dir=dl mbps=150 trf_id=3    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=2 qfi=1 dir=dl mbps=150 trf_id=4    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=2 qfi=1 dir=dl mbps=150 trf_id=5    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=2 qfi=1 dir=dl mbps=150 trf_id=6    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=2 qfi=1 dir=dl mbps=100 trf_id=7    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=2 qfi=1 dir=ul mbps=10 trf_id=1    UE ${ue_id}: UDP UL
    Verify Throughput    ue_id=${ue_id}    pdu_id=${pdu_id}    Tput_dl=750    Tput_ul=8

OnlineParamChange_on_gnb1
    [Arguments]    ${Online_Param}    ${check_sib}=${True}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be Onair    check_sib=${check_sib}

OnlineParamChange_on_gnb2
    [Arguments]    ${Online_Param}
    Delta Commission Parameters GNB2    ${Online_Param}
    Cells Should Be Onair    check_sib=${True}

Trigger stepwise A2releaes scells213 and check traffic
    [Arguments]    ${ue_id}=2    ${pdu_id}=2
    trigger A2 MR to stepwise release scells 213
    trigger A1 MR to add scell    85    ue_id=${ue_id}
    Verify Throughput    ue_id=${ue_id}    pdu_id=${pdu_id}    Tput_dl=750    Tput_ul=8

trigger A2 MR to stepwise release scells 213
    get scell A2 measid and trigger A2 to release cell    368430    2
    get scell A2 measid and trigger A2 to release cell    648096    1
    get scell A2 measid and trigger A2 to release cell    153370    3

get scell A2 measid and trigger A2 to release cell
    [Arguments]    ${carrierfreq}=648096    ${id}=1
    ${meas_id_scell}    get_nr_meas_id_for_specific_type_and_frequency    ue_id=2    carrierfreq=${carrierfreq}    event_type=A2
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=2 meas_id=${meas_id_scell} event=A2 scell=${id} scell_rsrp=20 scell_rsrq=20
    ...    pass_regexp=rrcReconfigurationComplete
    Should Contain    ${ret1}    sCellToReleaseList

Make Normal CA SA UE2 with one scell nrcell-3
    Sa Ue Attach    ue_id=2    gateway=2    enb_id=2    cell_id=1
    Setup pdu session with blind add scell    ue_id=2    gateway=2    pdu_id=2    pass_regexp=${expected_for_add_scell_physCellId_53}
    Execute Egate Command    data_trf_start ue=2 pdu=2 qfi=1 dir=dl mbps=10 trf_id=2    UE 2: UDP DL

Make Normal CA SA UE3 with two scells nrcell-3 nrcell-11
    Sa Ue Attach    ue_id=3    gateway=3    enb_id=2    cell_id=1
    Setup pdu session with blind add scell    ue_id=3    gateway=3    pdu_id=3    pass_regexp=${expected_for_add_scell_physCellId_53_physCellId_60}
    Execute Egate Command    data_trf_start ue=3 pdu=3 qfi=1 dir=dl mbps=10 trf_id=2    UE 3: UDP DL

Make Normal CA SA UE2 after release with scells nrcell-3 nrcell-11 nrcell-12
    Sa Ue Attach    ue_id=2    gateway=2    enb_id=2    cell_id=1
    Setup pdu session with blind add scell    ue_id=2    gateway=2    pdu_id=2
    ...    pass_regexp=${expected_for_add_scell_physCellId_53_physCellId_60_physCellId_61}
    Send And Verify Throuput    ue_id=2    pdu_id=2

Setup pdu session with blind add scell
    [Arguments]    ${ue_id}=1    ${gateway}=1    ${pdu_id}=1    ${pass_regexp}=${expected_for_UE2}
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    ${ret1}=    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} nwslice=1 gw=${gateway}
    ...    pass_regexp=${pass_regexp}    timeout=20s

OnlinemodifyiGnbCaXnCfUpBackOffTmr_test_messagecombine
    OnlineParamChange_on_gnb1    ${iGnbCaXnCfUpBackOffTmr_300s}    ${False}
    OnlineParamChange_on_gnb1    ${add_NRREL_4_under_NRCELL_1}    ${False}
    OnlineParamChange_on_gnb1    ${add_NRREL_47_under_NRCELL_1}    ${False}
    OnlineParamChange_on_gnb1    ${add_NRREL_48_under_NRCELL_1_for_simgnb_cell5}    ${False}
    OnlineParamChange_on_gnb1    ${delete_NRREL_45_to_gnb2_nrcell12_and_NRREL_48_under_NRCELL_1_for_simgnb_cell5}    ${False}
    OnlineParamChange_on_gnb1    ${add_NRREL_45_to_simgnb_cell5_delete_NRREL-3_add_NRREL-12}
    sleep    110s    #timer for message sendout
