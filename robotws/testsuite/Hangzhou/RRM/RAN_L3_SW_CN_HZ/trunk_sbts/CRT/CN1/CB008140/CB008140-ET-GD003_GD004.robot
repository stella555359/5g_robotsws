*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    team-rock    LOLO_LOO
...    owner-xiaowen.xu    release-SBTS23R3    CRT    CLOUD_5G_I_[LO][LO]_AP_[LOO]_SANSA_FS_ECPRI_CMWV_TDD
Resource          ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${NOKIA_XNAP_PLUGIN_FLAG}    ${True}
${NOKIA_F1AP_PLUGIN_FLAG}    ${True}
@{PARAMS_IN_SWCONFIG}
...    @{rdULCaEnablerPhase}
...    @{rdUseOptimizedDpaAlgo}

@{rdULCaEnablerPhase}
...    0x580591=0
@{rdUseOptimizedDpaAlgo}
...    0x58056B=1

@{PARAMS_IN_SCF}
...    @{PARAMS_FOR_CA}
...    @{PARAMS_FOR_GNB1}
...    @{PARAMS_ADJ_REL_FOR_GNB1}
...    @{PARAMS_FOR_OTHERS}
...    @{GNB1_CA_rel}
...    @{GNB1_A2_pcell_change_enable}
...    @{GNB1_A1_pcell_switch_enbale}
...    @{For_simgnb4}

@{PARAMS_IN_SCF_GNB2}
...    @{PARAMS_FOR_CA}
...    @{PARAMS_FOR_GNB2}
...    @{PARAMS_ADJ_REL_FOR_GNB2}
...    @{PARAMS_FOR_OTHERS}
...    @{GNB2_CA_rel_for_NRCELL_11}
...    @{GNB2_6137_Ul}
...    @{GNB2_A2_pcell_change_enable}
...    @{GNB2_A1_pcell_switch_enbale}

@{For_simgnb4}
...    MRBTS/MNL-1/MNLENT-1/XPAP-1/XPIF-1/XPIFREMOTE-2:ipAddress=10.0.1.101
...    MRBTS/MNL-1/MNLENT-1/XPAP-1/XPIF-1/XPIFREMOTE-2:remoteNeType=GNB
...    NRBTS/XNLINK-2:cPlaneIpAddr=10.0.1.101
...    NRBTS/NRADJGNB-4:gNbIdLength=22
...    NRBTS/NRADJGNB-4:gNodeBId=4
...    NRBTS/NRADJGNB-4:weightForIgnbCaSelection=1
...    NRBTS/NRADJGNB-4:xnLinkRef=2
...    NRBTS/NRADJGNB-4:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-4:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-4:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-13:fiveGsTac=200
...    NRBTS/NRADJNRCELL-13:gNbId=4
...    NRBTS/NRADJNRCELL-13:gNbIdLength=22
...    NRBTS/NRADJNRCELL-13:lcrId=1
...    NRBTS/NRADJNRCELL-13:nrarfcn=368400
...    NRBTS/NRADJNRCELL-13:physCellId=381
...    NRBTS/NRADJNRCELL-13:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-13:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-13:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-13:freqBandIndicatorNR=3
...    NRBTS/NRADJNRCELL-14:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-14:fiveGsTac=200
...    NRBTS/NRADJNRCELL-14:gNbId=4
...    NRBTS/NRADJNRCELL-14:gNbIdLength=22
...    NRBTS/NRADJNRCELL-14:lcrId=2
...    NRBTS/NRADJNRCELL-14:nrarfcn=153400
...    NRBTS/NRADJNRCELL-14:physCellId=382
...    NRBTS/NRADJNRCELL-14:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-14:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-14:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-14:freqBandIndicatorNR=28

@{PARAMS_FOR_CA}
...    NRBTS:actCarrierAggregation=true
...    NRBTS:sCellActivationMethod=blind
...    NRBTS:caConfigurationSupport=4CCDL_2CCUL
...    NRBTS:weightForIgnbCaSelection=1
...    NRBTS:actIncXn=true
...    NRBTS:maxNumScellsDl=2
...    NRBTS:maxNumScellsUl=2
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:carrierAggregationSupportList=ca_Fdd_Fdd,ca_Fdd_Fr1Tdd_Sa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fdd_Fr1Tdd_Sa_WithUl,ca_Fr1Tdd_Fdd_Sa_WithUl
...    NRBTS/NRDRB_RLC_AM-1:ulTReassemblyIBCA=40
...    NRBTS/NRDRB_RLC_AM-2:ulTReassemblyIBCA=40
...    NRDU-1:dlToUlContributionRatio=0
...    NRDU-1:actInterGnbCa=DLOnly
...    NRDU-1:xgUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRCELL:actK1Opt=intraAndInter-gNB
...    NRCELL:weightForSCellSelection=50
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRDU-1:actConnectedModeMobilityCA=true
...    @{A2_scell_release_enable}

@{PARAMS_FOR_GNB1}
...    NRCELL-1:sCellDeactivationTimerGNB=infinity
...    NRCELL-2:sCellDeactivationTimerGNB=infinity
...    NRCELL:chBw=40MHz
...    NRCELL:a1MeasSCellAddEnabled=rsrp
...    NRCELL:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=2
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=100
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=60
...    NRCELL:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrq:a1HysteresisSCellAddSsbRsrq=0|a1TimeToTriggerSCellAddSsbRsrq=320ms
...    NRCELL:a1MeasSCellAddSsbRsrq:a1ThresholdSCellAddSsbRsrq=60|a1TimeToTriggerSCellAddSsbRsrq=320ms

@{PARAMS_ADJ_REL_FOR_GNB1}
...    NRBTS:iGnbCaXnCfUpBackOffTmr=60
...    NRBTS:iGnbCaXnSetupReqTmr=60
...    NRBTS:iGnbCaXnSetupRespTmr=60
...    NRBTS:intGnbScellTempBlockTmr=60
...    NRBTS/NRADJNRCELL-13:cellDepType=SA+NSA
...    NRBTS/NRADJGNB-2:administrativeState=Unlocked
...    NRBTS/NRADJGNB-2:gNbIdLength=22
...    NRBTS/NRADJGNB-2:gNodeBId=2
...    NRBTS/NRADJGNB-2:weightForIgnbCaSelection=1
...    NRBTS/NRADJGNB-2:xnLinkRef=1
...    NRBTS/NRADJGNB-2:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-2:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-2:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-3:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-3:fiveGsTac=200
...    NRBTS/NRADJNRCELL-3:gNbId=2
...    NRBTS/NRADJNRCELL-3:gNbIdLength=22
...    NRBTS/NRADJNRCELL-3:lcrId=3
...    NRBTS/NRADJNRCELL-3:nrarfcn=653400
...    NRBTS/NRADJNRCELL-3:physCellId=52
...    NRBTS/NRADJNRCELL-3:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-3:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-3:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-3:freqBandIndicatorNR=77
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
...    NRBTS/NRADJNRCELL-11:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-11:fiveGsTac=200
...    NRBTS/NRADJNRCELL-11:gNbId=2
...    NRBTS/NRADJNRCELL-11:gNbIdLength=22
...    NRBTS/NRADJNRCELL-11:lcrId=11
...    NRBTS/NRADJNRCELL-11:nrarfcn=368400
...    NRBTS/NRADJNRCELL-11:physCellId=60
...    NRBTS/NRADJNRCELL-11:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-11:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-11:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-11:freqBandIndicatorNR=3
...    NRBTS/NRADJNRCELL-12:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-12:fiveGsTac=200
...    NRBTS/NRADJNRCELL-12:gNbId=2
...    NRBTS/NRADJNRCELL-12:gNbIdLength=22
...    NRBTS/NRADJNRCELL-12:lcrId=12
...    NRBTS/NRADJNRCELL-12:nrarfcn=153400
...    NRBTS/NRADJNRCELL-12:physCellId=61
...    NRBTS/NRADJNRCELL-12:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-12:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-12:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-12:freqBandIndicatorNR=28
@{GNB1_CA_rel}
...    NRCELL-1:measGapSelectionSA=favourUeThroughput
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-2:gNbId=1
...    NRCELL-1/NRREL-2:gNbIdLength=22
...    NRCELL-1/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-2:removeNotAllowed=false
...    NRCELL-1/NRREL-2:lcrId=2
...    NRCELL-1/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-3:gNbId=2
...    NRCELL-1/NRREL-3:gNbIdLength=22
...    NRCELL-1/NRREL-3:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-3:removeNotAllowed=false
...    NRCELL-1/NRREL-3:lcrId=3
...    NRCELL-1/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-4:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-4:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-4:gNbId=2
...    NRCELL-1/NRREL-4:gNbIdLength=22
...    NRCELL-1/NRREL-4:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-4:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-4:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-4:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-4:removeNotAllowed=false
...    NRCELL-1/NRREL-4:lcrId=4
...    NRCELL-1/NRREL-4:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-12:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-12:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-12:gNbId=2
...    NRCELL-1/NRREL-12:gNbIdLength=22
...    NRCELL-1/NRREL-12:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-12:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-12:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-12:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-12:removeNotAllowed=false
...    NRCELL-1/NRREL-12:lcrId=12
...    NRCELL-1/NRREL-12:sCellAdditionMethod=covBasedA1

...    NRCELL-2:measGapSelectionSA=favourUeThroughput
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-1:gNbId=1
...    NRCELL-2/NRREL-1:gNbIdLength=22
...    NRCELL-2/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-1:removeNotAllowed=false
...    NRCELL-2/NRREL-1:lcrId=1
...    NRCELL-2/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-3:gNbId=2
...    NRCELL-2/NRREL-3:gNbIdLength=22
...    NRCELL-2/NRREL-3:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-3:removeNotAllowed=false
...    NRCELL-2/NRREL-3:lcrId=3
...    NRCELL-2/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-4:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-4:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-4:gNbId=2
...    NRCELL-2/NRREL-4:gNbIdLength=22
...    NRCELL-2/NRREL-4:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-4:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-4:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-4:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-4:removeNotAllowed=false
...    NRCELL-2/NRREL-4:lcrId=4
...    NRCELL-2/NRREL-4:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-11:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-11:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-11:gNbId=2
...    NRCELL-2/NRREL-11:gNbIdLength=22
...    NRCELL-2/NRREL-11:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-11:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-11:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-11:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-11:removeNotAllowed=false
...    NRCELL-2/NRREL-11:lcrId=11
...    NRCELL-2/NRREL-11:sCellAdditionMethod=covBasedA1

@{PARAMS_FOR_GNB2}
...    NRBTS:iGnbCaXnCfUpBackOffTmr=60
...    NRBTS:iGnbCaXnSetupReqTmr=90
...    NRBTS:iGnbCaXnSetupRespTmr=60
...    NRBTS:intGnbScellTempBlockTmr=60
...    NRCELL-3:chBw=40MHz
...    NRCELL-4:chBw=40MHz
...    NRCELL-3:gscnOrSsPbchArfcn=8060
...    NRCELL-3:sCellDeactivationTimerGNB=infinity
...    NRCELL-4:sCellDeactivationTimerGNB=infinity
...    NRCELL-11:sCellDeactivationTimerGNB=infinity
...    NRCELL-12:sCellDeactivationTimerGNB=infinity
...    NRCELL-11:measGapSelectionSA=favourUeThroughput
...    NRCELL-11:a1MeasSCellAddEnabled=rsrp
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=2
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=100
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=60
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-11:a1MeasSCellAddSsbRsrq:a1HysteresisSCellAddSsbRsrq=0|a1TimeToTriggerSCellAddSsbRsrq=320ms
...    NRCELL-11:a1MeasSCellAddSsbRsrq:a1ThresholdSCellAddSsbRsrq=60|a1TimeToTriggerSCellAddSsbRsrq=320ms

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
...    NRBTS/NRADJNRCELL-1:gNbId=1
...    NRBTS/NRADJNRCELL-1:gNbIdLength=22
...    NRBTS/NRADJNRCELL-1:lcrId=1
...    NRBTS/NRADJNRCELL-1:nrarfcn=663400
...    NRBTS/NRADJNRCELL-1:physCellId=50
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-1:ssbFrequency=663360
...    NRBTS/NRADJNRCELL-1:freqBandIndicatorNR=77
...    NRBTS/NRADJNRCELL-2:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-2:fiveGsTac=200
...    NRBTS/NRADJNRCELL-2:gNbId=1
...    NRBTS/NRADJNRCELL-2:gNbIdLength=22
...    NRBTS/NRADJNRCELL-2:lcrId=2
...    NRBTS/NRADJNRCELL-2:nrarfcn=658000
...    NRBTS/NRADJNRCELL-2:physCellId=51
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-2:ssbFrequency=657984
...    NRBTS/NRADJNRCELL-2:freqBandIndicatorNR=77

@{PARAMS_FOR_OTHERS}


...    NRBTS:actRanSharing=false
...    NRCELL:actCDrx=false
...    NRBTS:cipherPrefL:nea0=8
...    NRBTS:cipherPrefL:nea1_128=0
...    NRBTS:cipherPrefL:nea2_128=0
...    NRBTS:cipherPrefL:nea3_128=0

@{GNB2_CA_rel_for_NRCELL_11}
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-1:gNbId=1
...    NRCELL-11/NRREL-1:gNbIdLength=22
...    NRCELL-11/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-1:removeNotAllowed=false
...    NRCELL-11/NRREL-1:lcrId=1
...    NRCELL-11/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-2:gNbId=1
...    NRCELL-11/NRREL-2:gNbIdLength=22
...    NRCELL-11/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-2:removeNotAllowed=false
...    NRCELL-11/NRREL-2:lcrId=2
...    NRCELL-11/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-3:gNbId=2
...    NRCELL-11/NRREL-3:gNbIdLength=22
...    NRCELL-11/NRREL-3:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-3:removeNotAllowed=false
...    NRCELL-11/NRREL-3:lcrId=3
...    NRCELL-11/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-4:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-4:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-4:gNbId=2
...    NRCELL-11/NRREL-4:gNbIdLength=22
...    NRCELL-11/NRREL-4:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-4:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-4:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-4:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-4:removeNotAllowed=false
...    NRCELL-11/NRREL-4:lcrId=4
...    NRCELL-11/NRREL-4:sCellAdditionMethod=covBasedA1

...    NRCELL-11/NRREL-12:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-12:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-12:gNbId=2
...    NRCELL-11/NRREL-12:gNbIdLength=22
...    NRCELL-11/NRREL-12:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-12:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-12:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-12:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-12:removeNotAllowed=false
...    NRCELL-11/NRREL-12:lcrId=12
...    NRCELL-11/NRREL-12:sCellAdditionMethod=covBasedA1

@{GNB2_6137_Ul}
...    NRCELL:timingAdvanceOffset=n25600
...    NRCELL-11/NRREL-3:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-4:sCellOperationalMode=dlAndUl
...    NRCELL-11/NRREL-12:sCellOperationalMode=dlOnly
...    NRCELL:actUl256Qam=true

@{GNB1_A2_pcell_change_enable}
...    NRCELL-2:a2MeasPCellSwitchEnabled=rsrp
...    NRCELL-2:a2MeasPCellSwitchSsbRsrp:a2HysteresisPCellSwitchSsbRsrp=0
...    NRCELL-2:a2MeasPCellSwitchSsbRsrp:a2ThresholdPCellSwitchSsbRsrp=75
...    NRCELL-2:a2MeasPCellSwitchSsbRsrp:a2TimeToTriggerPCellSwitchSsbRsrp=0ms
...    NRCELL-2:a2MeasPCellSwitchSsbRsrp:pCellSwitchOffsetSsbRsrp=1
...    NRCELL-2/NRHOIF-1:a2BasedPCellSwitchEnabled=true
...    NRCELL-2/NRHOIF-1:a2BasedPCellSwitchPriority=1
...    NRCELL-2/NRHOIF-1:thresholdPCellSwitchTargetRsrp=60
...    NRCELL-2/NRHOIF-1:thresholdPCellSwitchTargetRsrq=50
...    NRCELL-2/NRHOIF-1:cellDepType=SA
...    NRCELL-2/NRHOIF-1:freqBandIndicatorNR=77
...    NRCELL-2/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-2/NRHOIF-1:ifhoSsbSmtcDuration=sf2
...    NRCELL-2/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-2/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-2/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-2/NRHOIF-1:ssbFrequency=663360
...    NRCELL-2/NRHOIF-3:a2BasedPCellSwitchEnabled=true
...    NRCELL-2/NRHOIF-3:a2BasedPCellSwitchPriority=1
...    NRCELL-2/NRHOIF-3:thresholdPCellSwitchTargetRsrp=60
...    NRCELL-2/NRHOIF-3:thresholdPCellSwitchTargetRsrq=50
...    NRCELL-2/NRHOIF-3:cellDepType=SA
...    NRCELL-2/NRHOIF-3:freqBandIndicatorNR=77
...    NRCELL-2/NRHOIF-3:ifhoSsbScs=30 KHz
...    NRCELL-2/NRHOIF-3:ifhoSsbSmtcDuration=sf2
...    NRCELL-2/NRHOIF-3:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-2/NRHOIF-3:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-2/NRHOIF-3:ssBurstSetPeriod=20
...    NRCELL-2/NRHOIF-3:ssbFrequency=653856
...    NRCELL-2/NRHOIF-4:a2BasedPCellSwitchEnabled=true
...    NRCELL-2/NRHOIF-4:a2BasedPCellSwitchPriority=2
...    NRCELL-2/NRHOIF-4:thresholdPCellSwitchTargetRsrp=60
...    NRCELL-2/NRHOIF-4:thresholdPCellSwitchTargetRsrq=50
...    NRCELL-2/NRHOIF-4:cellDepType=SA
...    NRCELL-2/NRHOIF-4:freqBandIndicatorNR=77
...    NRCELL-2/NRHOIF-4:ifhoSsbScs=30 KHz
...    NRCELL-2/NRHOIF-4:ifhoSsbSmtcDuration=sf2
...    NRCELL-2/NRHOIF-4:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-2/NRHOIF-4:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-2/NRHOIF-4:ssBurstSetPeriod=20
...    NRCELL-2/NRHOIF-4:ssbFrequency=648096

@{GNB1_A1_pcell_switch_enbale}
...    NRCELL:a1MeasPCellSwitchEnabled=rsrp
...    NRCELL:a1MeasPCellSwitchSsbRsrp:a1HysteresisPCellSwitchSsbRsrp=0|a1ThresholdPCellSwitchSsbRsrp=50|a1TimeToTriggerPCellSwitchSsbRsrp=0ms
...    NRCELL-2/NRHOIF-1:a1BasedPCellSwitchEnabled=true
...    NRCELL-2/NRHOIF-3:a1BasedPCellSwitchEnabled=true
...    NRCELL-2/NRHOIF-4:a1BasedPCellSwitchEnabled=true

@{GNB2_A2_pcell_change_enable}
...    NRCELL-11:a2MeasPCellSwitchEnabled=rsrp
...    NRCELL-11:a2MeasPCellSwitchSsbRsrp:a2HysteresisPCellSwitchSsbRsrp=0
...    NRCELL-11:a2MeasPCellSwitchSsbRsrp:a2ThresholdPCellSwitchSsbRsrp=75
...    NRCELL-11:a2MeasPCellSwitchSsbRsrp:a2TimeToTriggerPCellSwitchSsbRsrp=0ms
...    NRCELL-11:a2MeasPCellSwitchSsbRsrp:pCellSwitchOffsetSsbRsrp=1
...    NRCELL-11/NRHOIF-3:a2BasedPCellSwitchEnabled=true
...    NRCELL-11/NRHOIF-3:a2BasedPCellSwitchPriority=1
...    NRCELL-11/NRHOIF-3:thresholdPCellSwitchTargetRsrp=60
...    NRCELL-11/NRHOIF-3:thresholdPCellSwitchTargetRsrq=50
...    NRCELL-11/NRHOIF-3:cellDepType=SA
...    NRCELL-11/NRHOIF-3:freqBandIndicatorNR=77
...    NRCELL-11/NRHOIF-3:ifhoSsbScs=30 KHz
...    NRCELL-11/NRHOIF-3:ifhoSsbSmtcDuration=sf2
...    NRCELL-11/NRHOIF-3:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-11/NRHOIF-3:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-11/NRHOIF-3:ssBurstSetPeriod=20
...    NRCELL-11/NRHOIF-3:ssbFrequency=653856
...    NRCELL-11/NRHOIF-4:a2BasedPCellSwitchEnabled=true
...    NRCELL-11/NRHOIF-4:a2BasedPCellSwitchPriority=2
...    NRCELL-11/NRHOIF-4:thresholdPCellSwitchTargetRsrp=60
...    NRCELL-11/NRHOIF-4:thresholdPCellSwitchTargetRsrq=50
...    NRCELL-11/NRHOIF-4:cellDepType=SA
...    NRCELL-11/NRHOIF-4:freqBandIndicatorNR=77
...    NRCELL-11/NRHOIF-4:ifhoSsbScs=30 KHz
...    NRCELL-11/NRHOIF-4:ifhoSsbSmtcDuration=sf2
...    NRCELL-11/NRHOIF-4:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-11/NRHOIF-4:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-11/NRHOIF-4:ssBurstSetPeriod=20
...    NRCELL-11/NRHOIF-4:ssbFrequency=648096
...    NRCELL-11/NRHOIF-1:a2BasedPCellSwitchEnabled=true
...    NRCELL-11/NRHOIF-1:a2BasedPCellSwitchPriority=1
...    NRCELL-11/NRHOIF-1:thresholdPCellSwitchTargetRsrp=60
...    NRCELL-11/NRHOIF-1:thresholdPCellSwitchTargetRsrq=50
...    NRCELL-11/NRHOIF-1:cellDepType=SA
...    NRCELL-11/NRHOIF-1:freqBandIndicatorNR=77
...    NRCELL-11/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-11/NRHOIF-1:ifhoSsbSmtcDuration=sf2
...    NRCELL-11/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-11/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-11/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-11/NRHOIF-1:ssbFrequency=663360
...    NRCELL-11/NRHOIF-2:a2BasedPCellSwitchEnabled=true
...    NRCELL-11/NRHOIF-2:a2BasedPCellSwitchPriority=2
...    NRCELL-11/NRHOIF-2:thresholdPCellSwitchTargetRsrp=60
...    NRCELL-11/NRHOIF-2:thresholdPCellSwitchTargetRsrq=50
...    NRCELL-11/NRHOIF-2:cellDepType=SA
...    NRCELL-11/NRHOIF-2:freqBandIndicatorNR=77
...    NRCELL-11/NRHOIF-2:ifhoSsbScs=30 KHz
...    NRCELL-11/NRHOIF-2:ifhoSsbSmtcDuration=sf2
...    NRCELL-11/NRHOIF-2:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-11/NRHOIF-2:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-11/NRHOIF-2:ssBurstSetPeriod=20
...    NRCELL-11/NRHOIF-2:ssbFrequency=657984

@{GNB2_A1_pcell_switch_enbale}
...    NRCELL:a1MeasPCellSwitchEnabled=rsrp
...    NRCELL:a1MeasPCellSwitchSsbRsrp:a1HysteresisPCellSwitchSsbRsrp=0|a1ThresholdPCellSwitchSsbRsrp=50|a1TimeToTriggerPCellSwitchSsbRsrp=0ms
...    NRCELL-11/NRHOIF-1:a1BasedPCellSwitchEnabled=true
...    NRCELL-11/NRHOIF-2:a1BasedPCellSwitchEnabled=true
...    NRCELL-11/NRHOIF-3:a1BasedPCellSwitchEnabled=true
...    NRCELL-11/NRHOIF-4:a1BasedPCellSwitchEnabled=true

@{A2_scell_release_enable}
...    NRCELL:a2MeasSCellRelEnabled=rsrp
...    NRCELL:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=35|a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL:a2MeasSCellRelSsbRsrq:a2HysteresisSCellRelSsbRsrq=0|a2TimeToTriggerSCellRelSsbRsrq=0ms
...    NRCELL:a2MeasSCellRelSsbRsrq:a2ThresholdSCellRelSsbRsrq=10|a2TimeToTriggerSCellRelSsbRsrq=0ms

${SA_Capa_Support_n77_3A_UL_CA}    SEPARATOR=
...    E9A09000575F5A13160003C320016093170019C3D09009B20C39F30C7942C0E098040623809DC6C06C0D608C21A08107482406D6C98AB1A1C
...    F88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE00098000702A0D805AC1184341020F10480CAD931562439F604F88
...    E3C62471E439F51CF9863CA1607038784FEC000003FB000000260001C0AA36266B04610D04083A412030B64C55110E7C471E238F40CFB027C
...    639F30C7942C0E070F05C00FFC007003FF0004C000381506C1BD608C21A0810788240656C98AB121CF88E3D813E31238F21CFA8E7CC31E50B
...    0381C3C27FFC00001FFF00000130000E0551B13758230868000010090185B24CA88873E238F20C7A067D813E01CF9863CA1607038782F5555
...    5553D5555554260001C00458B804001C4C000E260000020B02B1F008003836001C4C000E260000030B02B0F0080038360000182C0AC3C0200
...    0E260000070B0201200DC0068099000A02687A01B8122448913639F0E344891226C73E1C28913639F0E14489B1CF86004820C6318F413003C
...    00281C1401C0C02500700060240040603E09002000000010008000000200000C0100000200800002004000018020000100100000A00800401
...    0040100000C0080000700400200000008000080040000480200000C010000140080000B004002048120080000C03395359535829581958335
...    82B594B7933780B581B58095811583B40D040000259490100001965260400006594901000039652404000125949010000596526040001A594
...    901000079652404000225949010000996524040002A5949010000B96525040003259490100003165240334AA2E955552A8BA55154162A82C5
...    5068AA531549A2A80C55028AA4D5541E284803C00E8140A0500000E101002004040080110080100202004008080100220100C014040080101
...    002004602018028080600A02004008080100220101001404040050101602C602018030080600A02018030080100210100C014040300508080
...    600A02004008D50F8000810182030385058606880889098A0C0C8D8E0E8F909293139414951697A0A0C1680
# 3A_77(2A), 3A_77A UL,3_28

${SA_Capa_Support_3A_28A_77(2A)}    SEPARATOR=
...    E9A09000575F5A13160003C320016093170019C3D09009B20C39F30C7942C0E098040623809DC6C06C0D608C21A08107482406D6C98AB1A1C
...    F88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE00098000702A0D805AC1184341020F10480CAD931562439F604F88
...    E3C62471E439F51CF9863CA1607038784FEC000003FB000000260001C0AA36266B04610D04083A412030B64C55110E7C471E238F40CFB027C
...    639F30C7942C0E070F05C00FFC007003FF0004C000381506C1BD608C21A0810788240656C98AB121CF88E3D813E31238F21CFA8E7CC31E50B
...    0381C3C27FFC00001FFF00000130000E0551B13758230868000010090185B24CA88873E238F20C7A067D813E01CF9863CA1607038782F5555
...    5553D5555554260001C00258F804001C1B000E260007130000018581587804001C4C00000E160402401B800D0132001404D0F401F01468912
...    244D8E7C3851226C73E180070218C1E8260078005038280381804A00E000C0480080C07C12004000000020010000000400001802000004010
...    00004008000030040000200200001401000802008020000180100000E00800400000010000100080000900400001802000028010000160080
...    0409024010000180672A6B2A6B052B032B066B056B296F266F016B036B012B022B07681A0800004B29202000032CA4C080000CB2920200007
...    2CA480800024B292020000B2CA4C0800034B292020000F2CA480800044B29202000132CA480800054B29202000172CA4A0800064B29202000
...    062CA480669545D2AAAA55174AA2A82C55058AA0D154A62A93455018AA051549AAA83C509004800D028001C20200400808010022010020040
...    40080101002004402018028080100202004008C04030050100C014040080101002004402020028080800A0202C058C04030060100C0140403
...    00601002004402018028080600A0200400840403005010020046A87C0004080C10181C282C30344044484C5060646C70747C8494989CA0A4A
...    8B4BD05060B40
# 28A_77(2A)

${SA_Capa_Support_28A_77(2A)}    SEPARATOR=
...    E9A09000575F5A13160003C320016093170019C3D09009B20C39F30C7942C0E098040623809DC6C06C0D608C21A08107482406D6C98AB1A1C
...    F88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE00098000702A0D805AC1184341020F10480CAD931562439F604F88
...    E3C62471E439F51CF9863CA1607038784FEC000003FB000000260001C0AA36266B04610D04083A412030B64C55110E7C471E238F40CFB027C
...    639F30C7942C0E070F05C00FFC007003FF0004C000381506C1BD608C21A0810788240656C98AB121CF88E3D813E31238F21CFA8E7CC31E50B
...    0381C3C27FFC00001FFF00000130000E0551B13758230868000010090185B24CA88873E238F20C7A067D813E01CF9863CA1607038782F5555
...    5553D5555554260001C00158B836001C4C000E260000030B0201200DC0068099000A02687A0088062448913639F0C02808CF413003C00281C
...    1401C0C02500700060240040603E09002000000010008000000200000C0100000200800002004000018020000100100000A00800401004010
...    0000C0080000700400200000008000080040000480200000C010000140080000B004002048120080000C0339535953582958195833582B594
...    B7933780B581B58095811583B40D040000259490100001965260400006594901000039652404000125949010000596526040001A594901000
...    079652404000225949010000996524040002A5949010000B96525040003259490100003165240334AA2E955552A8BA55154162A82C55068AA
...    531549A2A80C55028AA4D5541E284801C0028000E101002004040080110080100202004008080100220100C01404008010100200440201802
...    80801002020040088040400501010014040580B18080600C02018028080600C02004008804030050100C014040080108080600A02004008D5
...    0F8000810182030385058606880889098A0C0C8D8E0E8F909293139414951697A0A0C168

${DU-to-CU-RRCInfo}    SEPARATOR=
...    100200c0000100c1400302000000c240020100

${ExtDu-to-PrimeDu-RrcInfo}    SEPARATOR=
...    00e0014080a260631078d167cb80042cdb40000019b193e8a81d29c028806b010a02190a20860c03286d9220064401b90018000080b290202
...    51003c0200240400498118140d484362194088512f08e540c03115510011800c13aa000e110f2801c08043100038443c7000b81808a200070
...    8878e001704010c4000e110f1c102e0a02288001c221e38204100000050c30203040581c174001ca00000000200400182e001809006600000
...    00280059f10080205000000000002800554d8080000000001a0000070afff80
${CA_support_list}        SEPARATOR=
...    ca_Fdd_Fdd,ca_Fdd_Fr1Tdd_Sa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fdd_Fr1Tdd_Sa_WithUl,ca_Fr1Tdd_Fdd_Sa_WithUl,
...    ca_Fr1Tdd_Any_Sa,ca_Fdd_Any_Sa

${GNB_DU_SCELL_2_ADMI_REQ_SA}    M55139C01501
#This counter describes the number of radio admission requests for exactly 2 SCells before the CA configuration on RRC.
#It is measured in PCell in SA mode in DU only.
${GNB_DU_SCELL_2_ADMI_SUCC_SA}    M55139C01502
${GNB_DU_SCELL_ADMI_REQ_SA}    M55139C01001
#This counter describes the total number of radio admission requests for SCell before the CA configuration on RRC.
#It is measured in SCell in SA mode in DU only.
${GNB_DU_SCELL_ADMI_SUCC_SA}    M55139C01002
${IGNB_CA_ATT_2_SCELL_SA}    M55118C11002
#Counts the number of inter gNB CA attempts for SA to add two S-Cell.
#Counted by the number of XnAP: IgNB CA ADDITION REQUEST messages sent from Prime-gNB CU to ext-gNB CU to add two S-Cell for SA.
#The counter is incremented in the P-Cell.
${IGNB_CA_ATT_2_SCELL_SA_SUCC}    M55118C11005
${UE_PCELL_1_CONF_SCELL_DL_SA}    M55118C05507
#The sum of samples for total number of CA UEs in the current cell configured as a PCell, which have 1 configured SCell in DL.
#The counter is incremented in the P-Cell.This is a sample type of a counter.
${UE_PCELL_1_CONF_SCELL_UL_SA}    M55118C10005
${UE_PCELL_2_CONF_SCELL_DL_SA}    M55118C07001
#The sum of samples for total number of CA UEs in the current cell configured as a PCell, which have 2 configured SCell in DL.
#The counter is incremented in the P-Cell.This is a sample type of a counter.
${UE_SCELL_1_CONF_SCELL_DL_SA}    M55118C05508
#The sum of samples for total number of CA UEs in the current cell configured as an SCell while pegged in the secondary cell,
#which have 1 configured SCell in DL.
${UE_SCELL_2_CONF_SCELL_DL_SA}    M55118C07002
${UE_SCELL_1_CONF_SCELL_UL_SA}    M55118C10006
#The sum of samples for total number of CA UEs in the current cell configured as an SCell while pegged in the secondary cell,
#which have 1 configured SCell in UL.

*** Test Cases ***
CB008140-ET-GD003 Single UE connection setup with UL coverbased CA FT and dlToUlContributionRatio configured with 0
    [Documentation]
    ...    This case is to Verify scell selection when dlToUlContributionRatio=0
    ...    [Configuration for gnb1 external]:
    ...    Cell id=1 gnb=2 pci=16:2 tac=200 tdd_cell=on band=n77 nr_arfcn=663400:663400 gscn=8159 chBw=40MHz ssb=663360
    ...    Cell id=2 gnb=2 pci=17:0 tac=200 tdd_cell=on band=n77 nr_arfcn=658000:658000 gscn=8103 chBw=40MHz ssb=657984
    ...    [Configuration for gnb2 primary]:
    ...    Cell id=3 gnb=3 pci=17:1 tac=200 tdd_cell=on band=n77 nr_arfcn=653400:653400 gscn=8060 chBw=40MHz ssb=653856
    ...    Cell id=4 gnb=3 pci=17:2 tac=200 tdd_cell=on band=n77 nr_arfcn=648000:648000 gscn=8000 chBw=40MHz ssb=648096
    ...    Cell id=11 gnb=3 pci=20:0 tac=200 tdd_cell=off band=n3 nr_arfcn=349400:368400 gscn=4605 chBw=10MHz ssb=368430
    ...    Cell id=12 gnb=3 pci=20:1 tac=200 tdd_cell=off band=n28 nr_arfcn=143400:153400 gscn=1916 chBw=20MHz ssb=153370
    ...    2.Test Case Steps:
    ...         a. UE1 Register And PDU Session Setup On GNB2 NRCELL-11
    ...         b. A1 scelladdition with GNB2 Cell4_dlandUL ,referring 5G_CP_ARC_ALG_6746
    ...         c. A1 pcell switch , A2 scell release and A1 scell change should be configured
    ...         d. deregister UE1
    ...         e. repeat step a,b,c,d
    [Tags]    GD003    QC_250675
    repeat keyword    5 times    GD003

CB008140-ET-GD004 SCell selection with UL CA interworking with mixed CA configuration and 3CC DL CA
    [Documentation]
    ...    This case is to Verify SCell selection with UL CA, interworking with mixed CA configuration and 3CC DL CA
    ...    [Configuration for gnb1]:
    ...    Cell id=1 gnb=2 pci=16:2 tac=200 tdd_cell=on band=n77 nr_arfcn=663400:663400 gscn=8159 chBw=40MHz ssb=663360
    ...    Cell id=2 gnb=2 pci=17:0 tac=200 tdd_cell=on band=n77 nr_arfcn=658000:658000 gscn=8103 chBw=40MHz ssb=657984
    ...    cell 1 is pcell for ue 5 , 4 ca relationships , gnb1_cell2, gnb2_cell3, gnb2_cell4, gnb2_cell12
    ...    cell 2 is pcell for ue 3 , 4 ca relationships , gnb1_cell1, gnb2_cell3, gnb2_cell4, gnb2_cell11
    ...    [Configuration for gnb2]:
    ...    Cell id=3 gnb=3 pci=17:1 tac=200 tdd_cell=on band=n77 nr_arfcn=653400:653400 gscn=8060 chBw=40MHz ssb=653856
    ...    Cell id=4 gnb=3 pci=17:2 tac=200 tdd_cell=on band=n77 nr_arfcn=648000:648000 gscn=8000 chBw=40MHz ssb=648096
    ...    Cell id=11 gnb=3 pci=20:0 tac=200 tdd_cell=off band=n3 nr_arfcn=349400:368400 gscn=4605 chBw=10MHz ssb=368430
    ...    Cell id=12 gnb=3 pci=20:1 tac=200 tdd_cell=off band=n28 nr_arfcn=143400:153400 gscn=1916 chBw=20MHz ssb=153370
    ...    cell 11 is pcell for ue 1,2,4 and have 5 ca relationships ,gnb1_cell1, gnb1_cell2, gnb2_cell3, gnb2_cell4, gnb2_cell12
    ...    2.Test Case Steps:
    ...         a. UE1 attach to gnb2 cell11 , and after A1 MR to trigger scell addition ,gnb2_cell3 and gnb2_cell4 added.
    ...         b. IntraGNBCA:check measurements ,A1 pcellswitch A2 scell rlease A1 scell change configured for UE1.
    ...         c. UE2 attach to gnb2 cell11 , and after A1 MR to trigger scell addition ,gnb1_cell1 and gnb1_cell2 added.
    ...         d. InterGNBCA:check measurements ,A1 pcellswitch A1 scell change not configured A2 scell rlease configured for UE2 .
    ...         e. UE3 attach to gnb1 cell2.
    ...         f. UE4 attach to gnb2 cell11 , and after A1 MR to trigger scell addition ,gnb2_cell3 and gnb2_cell4 added.
    ...         g. IntraGNBCA:check measurements ,A1 pcellswitch A2 scell rlease A1 scell change configured for UE4.
    ...         h. Trigger scell1 released for UE2.
    ...         i. check measurements ,only A2 scell released for scell2 configured for UE2,no scell change or others.
    ...         j. UE5 attach to gnb1 cell1 , and after A1 MR to trigger scell addition ,gnb2_cell3 and gnb2_cell12 added.
    ...         k. InterGNBCA:check measurements ,A1 pcellswitch A1 scell change not configured A2 scell rlease configured for UE5 .
    ...         l. check counters and releaed all UEs.
    ...      3. Selection referring 5G_CP_ARC_ALG_6746, TP for the before UE will be lower after new UE attached.
    [Tags]    GD004    QC_250676
    OnlineParamChange_enable_3cc
    Clear Counter Files
    Clear Counter Files gnb2
    GD004 UE1
    GD004 UE2 UE3
    GD004 UE4
    GD004 UE5
    Check Counters in GNB1
    Check Counters in GNB2

*** Keywords ***
GD003
    UE Attach and CA successfully    ue_id=1    gateway=1    enb_id=3    cell_id=11    carrierfreq=368430
    Check GNB2 scell added Successfully    NRCELL-4
    check measurements for GD003
    Send Throuput
    Verify Throuput For FT
    UE Deregister From gNB    1

GD004 UE1
    Start RRC Log    ue1
    UE Attach and CA successfully    ue_id=1    gateway=1    enb_id=3    cell_id=11    carrierfreq=368430
    Check GNB2 scells added Successfully    NRCELL-3    NRCELL-4
    check measurements for GD004 UE1 and UE4    ue_id=1
    Send Throuput    ue_id=1    pdu_id=1
    wait until keyword succeeds    1 min    10 sec    Verify Throuput For FTT    ue_id=1    pcell_dl=30    scell_dl_T=110


GD004 UE2 UE3
    Start RRC Log    ue2
    UE Attach and CA successfully    ue_id=2    gateway=2    enb_id=3    cell_id=11    carrierfreq=368430
    Check GNB1 scells added Successfully    NRCELL-1    NRCELL-2
    check measurements for GD004 UE2
    Send Throuput    ue_id=2    pdu_id=2
    wait until keyword succeeds    1 min    10 sec    Verify Throuput For FTT    ue_id=2    pcell_dl=15    scell_dl_T=110
    Start RRC Log    ue3
    Sa Ue Attach    ue_id=3    gateway=3    enb_id=2    cell_id=2
    Setup pdu session    ue_id=3    gateway=3
    Send Throuput    ue_id=3    pdu_id=3

GD004 UE4
    wait until keyword succeeds    1 min    10 sec    Verify Throuput For FTT    ue_id=1    pcell_dl=15    scell_dl_T=110
    Start RRC Log    ue4
    UE Attach and CA successfully    ue_id=4    gateway=4    enb_id=3    cell_id=11    carrierfreq=368430
    Check GNB2 scells added Successfully    NRCELL-3    NRCELL-4
    check measurements for GD004 UE1 and UE4    ue_id=4
    Send Throuput    ue_id=4    pdu_id=4
    wait until keyword succeeds    1 min    10 sec    Verify Throuput For FTT    ue_id=4    pcell_dl=15    scell_dl_T=95
    Start RRC Log    ue2_2
    Trigger scellrelease    ue_id=2     carrierfreq=663360    scell_index=1    threshold=35
    check measurements for GD004 UE2 after scell1 released

GD004 UE5
    Start RRC Log    ue5
    UE Attach and CA successfully    ue_id=5    gateway=5    enb_id=2    cell_id=1    carrierfreq=663360    srsrp_nr=110
    Check GNB2 scells added Successfully    NRCELL-3    NRCELL-12
    check measurements for GD004 UE5
    Send Throuput    ue_id=5    pdu_id=5
    wait until keyword succeeds    2 min    20 sec    Verify Throuput For FTT    ue_id=1    pcell_dl=15    scell_dl_T=65
    wait until keyword succeeds    2 min    20 sec    Verify Throuput For FTT    ue_id=4    pcell_dl=15    scell_dl_T=65

Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup 2Airphone Env    fddtdd_sansa_cmwv/6cells_gnb1_2T_gnb2_2T2F
    Set sim gNB4 Parameter

Modify Cfg
    Update Cfg    ue_param id=1 ue_nr_capabilities=${SA_Capa_Support_n77_3A_UL_CA}
    Update Cfg    ue_param id=2 ue_nr_capabilities=${SA_Capa_Support_n77_3A_UL_CA}
    Update Cfg    ue_param id=3 ue_nr_capabilities=${SA_Capa_Support_3A_28A_77(2A)}
    Update Cfg    ue_param id=4 ue_nr_capabilities=${SA_Capa_Support_n77_3A_UL_CA}
    Update Cfg    ue_param id=5 ue_nr_capabilities=${SA_Capa_Support_28A_77(2A)}
    ${command_gnb4} =    catenate    SEPARATOR=
    ...           set_gnb id=4
    ...           \ type=simulated plmn=311:489 ng=10.0.1.102 gnb_id=0x4:22 daemon=$SERVER_IP:$DAEMON_PORT x2_peers=none
    ...           \ xn=10.0.1.101 nssai=0x1:0xd143a5 amf=1 xp=10.0.1.101:32742 xpu=10.0.1.101:32742 xp_management=on
    Update Cfg    ${command_gnb4}
    Update Cfg    gnb_param id=4 send_xn_setup=false sib1_period=40 xn_listening_socket=on
    ${command_gnb4_cell1} =    catenate    SEPARATOR=
    ...           set_cell id=1
    ...           \ gnb=4 pci=127:1 tac=200 nrci=0x01 tdd_cell=off proxy=10.0.1.108:9999
    ...           \ nr_arfcn=349400:368400 gscn=4605 nr_scs=15kHz bs_channel_bandwidth=10MHz
    ${command_gnb4_cell2} =    catenate    SEPARATOR=
    ...           set_cell id=2
    ...           \ gnb=4 pci=127:2 tac=200 nrci=0x02 tdd_cell=off proxy=10.0.1.109:9999
    ...           \ nr_arfcn=143400:153400 gscn=1916 nr_scs=15kHz bs_channel_bandwidth=15MHz
    Update Cfg    ${command_gnb4_cell1}
    Update Cfg    ${command_gnb4_cell2}

Set sim gNB4 Parameter
    Execute Egate Command    sim_trace enb=4 protocol=xn on
    Execute Egate Command    enb_xp_param xp_peers=2 id=4
     ...     pass_regexp=GNB-4: XpAP Link with GNB-2.*is up    timeout=100    sleep_time=10
    ${cmd1}    catenate    gnb_cell_param gnb=4 id=1 Cell_BWP_List=3,4,5,6 cell_Available=yes
    ...    weightForSCellSelection=50
    Execute Egate Command    ${cmd1}
    ${cmd2}    catenate    gnb_param id=4 bwp_profile_id=54 bwp_profile_type=dedicated
    ...    act_multiple_dedicated_bwps=no location_bw_ul=1:0 location_bw_dl=1:1 Inter_gNB_CA_Allowed=yes
    ...    CellLoadReportingPeriodicity=000 IgNBCAXpProtocolVersion=7 IgNBCAXgUProtocolVersion=7
    Execute Egate Command    ${cmd2}
    Execute Egate Command    ignb_ca_configuration_update_indication_send id=4 target=2    IgNBCAConfigurationUpdateIndication
    ${cmd3}    catenate    ignb_ca_addition_param gnb_id=4 DU-to-CU-RRCInfo=${DU-to-CU-RRCInfo}
    ...    ExtDu-to-PrimeDu-RrcInfo=${ExtDu-to-PrimeDu-RrcInfo}
    Execute Egate Command    ${cmd3}

Sa Ue Attach
    [Arguments]    ${ue_id}=1    ${gateway}=1    ${enb_id}=2    ${cell_id}=2
    ...    ${pass_regexp}=now Registered
    Execute Egate Command    ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    ${pass_regexp}

Setup pdu session
    [Arguments]    ${ue_id}=1    ${gateway}=1
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${gateway} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${gateway} nwslice=1 gw=${gateway}    pass_regexp=Initial Context Setup Successful

UE Attach and CA successfully
    [Arguments]    ${ue_id}=1    ${gateway}=1    ${enb_id}=2    ${cell_id}=2    ${carrierfreq}=368430    ${srsrp_nr}=70
    Sa Ue Attach    ue_id=${ue_id}    gateway=${gateway}    enb_id=${enb_id}    cell_id=${cell_id}
    Setup pdu session    ue_id=${ue_id}    gateway=${gateway}
    trigger mr    event_type=A1    carrierfreq=${carrierfreq}    srsrp_nr=${srsrp_nr}    srsrq_nr=80    ue_id=${ue_id}

Get the measurement id
    [Arguments]    ${event_type}=A3    ${ue_id}=1    ${carrierfreq}=368430    ${threshold}=0
    ${meas_id}    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=${event_type}
    ...    threshold=${threshold}
    [Return]    ${meas_id}

check measurements for GD003
    [Arguments]    ${ue_id}=1
    run keyword and expect error    *    Get the measurement id    ue_id=${ue_id}    event_type=A1    carrierfreq=368430    threshold=60
    Get the measurement id    ue_id=${ue_id}    event_type=A1    carrierfreq=368430    threshold=100
    Get the measurement id    ue_id=${ue_id}    event_type=A2    carrierfreq=648096    threshold=35
    Get the measurement id    ue_id=${ue_id}    event_type=A1    carrierfreq=648096    threshold=50

check measurements for GD004 UE1 and UE4
    [Arguments]    ${ue_id}=1
    run keyword and expect error    *    Get the measurement id    ue_id=${ue_id}    event_type=A1    carrierfreq=368430    threshold=60
    Get the measurement id    ue_id=${ue_id}    event_type=A1    carrierfreq=368430    threshold=100
    Get the measurement id    ue_id=${ue_id}    event_type=A2    carrierfreq=648096    threshold=35
    Get the measurement id    ue_id=${ue_id}    event_type=A1    carrierfreq=648096    threshold=50
    Get the measurement id    ue_id=${ue_id}    event_type=A2    carrierfreq=653856    threshold=35
    Get the measurement id    ue_id=${ue_id}    event_type=A1    carrierfreq=653856    threshold=50

check measurements for GD004 UE2
    [Arguments]    ${ue_id}=2
    run keyword and expect error    *    Get the measurement id    ue_id=${ue_id}    event_type=A1    carrierfreq=368430    threshold=60
    run keyword and expect error    *    Get the measurement id    ue_id=${ue_id}    event_type=A1    carrierfreq=368430    threshold=100
    Get the measurement id    ue_id=${ue_id}    event_type=A2    carrierfreq=663360    threshold=35
    run keyword and expect error    *    Get the measurement id    ue_id=${ue_id}    event_type=A1    carrierfreq=663360    threshold=50
    Get the measurement id    ue_id=${ue_id}    event_type=A2    carrierfreq=657984    threshold=35
    run keyword and expect error    *    Get the measurement id    ue_id=${ue_id}    event_type=A1    carrierfreq=657984    threshold=50

check measurements for GD004 UE2 after scell1 released
    [Arguments]    ${ue_id}=2
    run keyword and expect error    *    Get the measurement id    ue_id=${ue_id}    event_type=A1    carrierfreq=368430    threshold=60
    run keyword and expect error    *    Get the measurement id    ue_id=${ue_id}    event_type=A1    carrierfreq=368430    threshold=100
    run keyword and expect error    *    Get the measurement id    ue_id=${ue_id}    event_type=A2    carrierfreq=663360    threshold=35
    run keyword and expect error    *    Get the measurement id    ue_id=${ue_id}    event_type=A1    carrierfreq=663360    threshold=50
    Get the measurement id    ue_id=${ue_id}    event_type=A2    carrierfreq=657984    threshold=35
    run keyword and expect error    *    Get the measurement id    ue_id=${ue_id}    event_type=A1    carrierfreq=657984    threshold=50

check measurements for GD004 UE5
    [Arguments]    ${ue_id}=5
    run keyword and expect error    *    Get the measurement id    ue_id=${ue_id}    event_type=A1    carrierfreq=663360    threshold=60
    run keyword and expect error    *    Get the measurement id    ue_id=${ue_id}    event_type=A1    carrierfreq=663360    threshold=100
    run keyword and expect error    *    Get the measurement id    ue_id=${ue_id}    event_type=A2    carrierfreq=663360    threshold=50
    Get the measurement id    ue_id=${ue_id}    event_type=A2    carrierfreq=653856    threshold=35
    run keyword and expect error    *    Get the measurement id    ue_id=${ue_id}    event_type=A1    carrierfreq=653856    threshold=50
    Get the measurement id    ue_id=${ue_id}    event_type=A2    carrierfreq=153370    threshold=35
    run keyword and expect error    *    Get the measurement id    ue_id=${ue_id}    event_type=A1    carrierfreq=153370    threshold=50

Trigger MR
    [Arguments]    ${event_type}=A2    ${carrierfreq}=368430    ${srsrp_nr}=5    ${srsrq_nr}=5    ${ue_id}=81    ${phycell_id}=62
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${phycell}    Catenate    phycell_id=${phycell_id} nrsrp_nr=110 nrsrq_nr=100
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type}
    ...    srsrp_nr=${srsrp_nr} srsrq_nr=${srsrq_nr}
    Execute Egate Command    ${cmd}     pass_regexp=rrcReconfigurationComplete

Trigger scellrelease
    [Arguments]    ${event_type}=A2    ${carrierfreq}=663360    ${scell_index}=1    ${ue_id}=2    ${scell_rsrp}=10
    ...    ${scell_rsrq}=10    ${threshold}=34
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}    threshold=${threshold}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} event=${event_type} meas_id=${meas_id} srsrp_nr=50 srsrq_nr=50
    ...    scell=${scell_index} scell_rsrp=${scell_rsrp} scell_rsrq=${scell_rsrq}
    Execute Egate Command    ${cmd}    pass_regexp=rrcReconfigurationComplete

Check GNB1 scells added Successfully
    [Arguments]    ${scell1}    ${scell2}
    ${SCELL1_physCellId}    Get Scf Parameter Value    ${scell1}:physCellId
    ${SCELL2_physCellId}    Get Scf Parameter Value    ${scell2}:physCellId
    Rrc Should Contain    sCellToAddModList    physCellId ${SCELL1_physCellId}    physCellId ${SCELL2_physCellId}

Check GNB2 scells added Successfully
    [Arguments]    ${scell1}    ${scell2}
    ${SCELL1_physCellId}    Get Scf Parameter Value gnb2    ${scell1}:physCellId
    ${SCELL2_physCellId}    Get Scf Parameter Value gnb2    ${scell2}:physCellId
    Rrc Should Contain    sCellToAddModList    physCellId ${SCELL1_physCellId}    physCellId ${SCELL2_physCellId}

Check GNB2 scell added Successfully
    [Arguments]    ${scell1}
    ${SCELL1_physCellId}    Get Scf Parameter Value gnb2    ${scell1}:physCellId
    Rrc Should Contain    sCellToAddModList    physCellId ${SCELL1_physCellId}

UE Deregister From gNB
    [Arguments]    ${ue_id}
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=${ue_id}    Traffic was stopped
    Execute Egate Command    ue_pdu_session_release ue=${ue_id} pdu=${ue_id}    Successfully released PDU Session
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s

Send Throuput
    [Arguments]    ${ue_id}=1    ${pdu_id}=1
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=3    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=ul mbps=20 trf_id=1    UE ${ue_id}: UDP UL
    sleep    30s    #sleep for stable traffic

Verify Throuput For FT
    [Arguments]    ${ue_id}=1    ${ul}=10    ${scell_id}=1    ${total_dl_tput}=250
    sleep    10s     #sleep for stable traffic
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000 > 0
    ${scellF1_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${scell_id}    type=pdsch    rate_type=ave
    Should Be True    ${scellF1_tput}/1000 > 0
    ${ul_throughput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pusch    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul}
    ${total_dl}    Evaluate    ${scell0_tput}+${scellF1_tput}
    Should Be True    ${total_dl}/1000>${total_dl_tput}

Verify Throuput For FTT
    [Arguments]    ${ue_id}=1    ${pcell_dl}=30    ${scell_dl_T}=100    ${ul}=10    ${scell_id1}=1    ${scell_id2}=2
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000 > ${pcell_dl}
    ${scellT1_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${scell_id1}    type=pdsch    rate_type=ave
    Should Be True    ${scellT1_tput}/1000 > ${scell_dl_T}
    ${scellT2_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${scell_id2}    type=pdsch    rate_type=ave
    Should Be True    ${scellT2_tput}/1000 > ${scell_dl_T}
    ${ul_throughput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pusch    rate_type=ave
    Should Be True    ${ul_throughput}/1000 > ${ul}

OnlineParamChange_gNB1
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    wait until keyword succeeds    10 min    60 sec    Cells Should Be OnAir

OnlineParamChange_gNB2
    [Arguments]    ${Online_Param}
    Delta Commission Parameters gnb2    ${Online_Param}
    wait until keyword succeeds    10 min    60 sec    Cells Should Be OnAir

OnlineParamChange_enable_3cc
    ${Online_para}     create list    NRDU-1:dlToUlContributionRatio=50
    ...    NRCELL:maxNumScellsDlFr1=3
    ...    NRDU-1:carrierAggregationSupportList=${CA_support_list}
    OnlineParamChange_gNB2    ${Online_para}
    OnlineParamChange_gNB1    ${Online_para}

Check Counters in GNB1
    ${pm_counters}    Create List    NRCELL-1:RSADU:${GNB_DU_SCELL_2_ADMI_REQ_SA}=1
    ...    NRCELL-1:RSADU:${GNB_DU_SCELL_2_ADMI_SUCC_SA}=1
    ...    NRCELL-1:RSADU:${GNB_DU_SCELL_ADMI_REQ_SA}=1
    ...    NRCELL-1:RSADU:${GNB_DU_SCELL_ADMI_SUCC_SA}=1
    ...    NRCELL-1:NCAC:${IGNB_CA_ATT_2_SCELL_SA}=1
    ...    NRCELL-1:NCAC:${IGNB_CA_ATT_2_SCELL_SA_SUCC}=1
    ...    NRCELL-1:NCAC:${UE_PCELL_1_CONF_SCELL_DL_SA}=0
    ...    NRCELL-1:NCAC:${UE_PCELL_1_CONF_SCELL_UL_SA}=0
    ...    NRCELL-1:NCAC:${UE_PCELL_2_CONF_SCELL_DL_SA}>0
    ...    NRCELL-1:NCAC:${UE_SCELL_1_CONF_SCELL_DL_SA}=0
    ...    NRCELL-1:NCAC:${UE_SCELL_2_CONF_SCELL_DL_SA}=0
    ...    NRCELL-1:NCAC:${UE_SCELL_1_CONF_SCELL_UL_SA}=0

    ...    NRCELL-2:RSADU:${GNB_DU_SCELL_2_ADMI_REQ_SA}=0
    ...    NRCELL-2:RSADU:${GNB_DU_SCELL_2_ADMI_SUCC_SA}=0
    ...    NRCELL-2:RSADU:${GNB_DU_SCELL_ADMI_REQ_SA}=1
    ...    NRCELL-2:RSADU:${GNB_DU_SCELL_ADMI_SUCC_SA}=1
    ...    NRCELL-2:NCAC:${IGNB_CA_ATT_2_SCELL_SA}=0
    ...    NRCELL-2:NCAC:${IGNB_CA_ATT_2_SCELL_SA_SUCC}=0
    ...    NRCELL-2:NCAC:${UE_PCELL_1_CONF_SCELL_DL_SA}=0
    ...    NRCELL-2:NCAC:${UE_PCELL_1_CONF_SCELL_UL_SA}=0
    ...    NRCELL-2:NCAC:${UE_PCELL_2_CONF_SCELL_DL_SA}=0
    ...    NRCELL-2:NCAC:${UE_SCELL_1_CONF_SCELL_DL_SA}=0
    ...    NRCELL-2:NCAC:${UE_SCELL_2_CONF_SCELL_DL_SA}=0
    ...    last NRCELL-2:NCAC:${UE_SCELL_1_CONF_SCELL_UL_SA}=0
    Check Counters    ${pm_counters}

Check Counters in GNB2
    ${pm_counters}    Create List    NRCELL-3:RSADU:${GNB_DU_SCELL_2_ADMI_REQ_SA}=0
    ...    NRCELL-3:RSADU:${GNB_DU_SCELL_2_ADMI_SUCC_SA}=0
    ...    NRCELL-3:RSADU:${GNB_DU_SCELL_ADMI_REQ_SA}=3
    ...    NRCELL-3:RSADU:${GNB_DU_SCELL_ADMI_SUCC_SA}=3
    ...    NRCELL-3:NCAC:${IGNB_CA_ATT_2_SCELL_SA}=0
    ...    NRCELL-3:NCAC:${IGNB_CA_ATT_2_SCELL_SA_SUCC}=0
    ...    NRCELL-3:NCAC:${UE_PCELL_1_CONF_SCELL_DL_SA}=0
    ...    NRCELL-3:NCAC:${UE_PCELL_1_CONF_SCELL_UL_SA}=0
    ...    NRCELL-3:NCAC:${UE_PCELL_2_CONF_SCELL_DL_SA}=0
    ...    NRCELL-3:NCAC:${UE_SCELL_1_CONF_SCELL_DL_SA}=0
    ...    NRCELL-3:NCAC:${UE_SCELL_2_CONF_SCELL_DL_SA}>0
    ...    NRCELL-3:NCAC:${UE_SCELL_1_CONF_SCELL_UL_SA}=0
    ...    NRCELL-4:RSADU:${GNB_DU_SCELL_2_ADMI_REQ_SA}=0
    ...    NRCELL-4:RSADU:${GNB_DU_SCELL_2_ADMI_SUCC_SA}=0
    ...    NRCELL-4:RSADU:${GNB_DU_SCELL_ADMI_REQ_SA}=2
    ...    NRCELL-4:RSADU:${GNB_DU_SCELL_ADMI_SUCC_SA}=2
    ...    NRCELL-4:NCAC:${IGNB_CA_ATT_2_SCELL_SA}=0
    ...    NRCELL-4:NCAC:${IGNB_CA_ATT_2_SCELL_SA_SUCC}=0
    ...    NRCELL-4:NCAC:${UE_PCELL_1_CONF_SCELL_DL_SA}=0
    ...    NRCELL-4:NCAC:${UE_PCELL_1_CONF_SCELL_UL_SA}=0
    ...    NRCELL-4:NCAC:${UE_PCELL_2_CONF_SCELL_DL_SA}=0
    ...    NRCELL-4:NCAC:${UE_SCELL_1_CONF_SCELL_DL_SA}=0
    ...    NRCELL-4:NCAC:${UE_SCELL_2_CONF_SCELL_DL_SA}>0
    ...    NRCELL-4:NCAC:${UE_SCELL_1_CONF_SCELL_UL_SA}>0
    ...    NRCELL-11:RSADU:${GNB_DU_SCELL_2_ADMI_REQ_SA}=3
    ...    NRCELL-11:RSADU:${GNB_DU_SCELL_2_ADMI_SUCC_SA}=3
    ...    NRCELL-11:RSADU:${GNB_DU_SCELL_ADMI_REQ_SA}=0
    ...    NRCELL-11:RSADU:${GNB_DU_SCELL_ADMI_SUCC_SA}=0
    ...    NRCELL-11:NCAC:${IGNB_CA_ATT_2_SCELL_SA}=1
    ...    NRCELL-11:NCAC:${IGNB_CA_ATT_2_SCELL_SA_SUCC}=1
    ...    NRCELL-11:NCAC:${UE_PCELL_1_CONF_SCELL_DL_SA}>0
    ...    NRCELL-11:NCAC:${UE_PCELL_1_CONF_SCELL_UL_SA}>0
    ...    NRCELL-11:NCAC:${UE_PCELL_2_CONF_SCELL_DL_SA}>0
    ...    NRCELL-11:NCAC:${UE_SCELL_1_CONF_SCELL_DL_SA}=0
    ...    NRCELL-11:NCAC:${UE_SCELL_2_CONF_SCELL_DL_SA}=0
    ...    NRCELL-11:NCAC:${UE_SCELL_1_CONF_SCELL_UL_SA}=0
    ...    NRCELL-12:RSADU:${GNB_DU_SCELL_2_ADMI_REQ_SA}=0
    ...    NRCELL-12:RSADU:${GNB_DU_SCELL_2_ADMI_SUCC_SA}=0
    ...    NRCELL-12:RSADU:${GNB_DU_SCELL_ADMI_REQ_SA}=1
    ...    NRCELL-12:RSADU:${GNB_DU_SCELL_ADMI_SUCC_SA}=1
    ...    NRCELL-12:NCAC:${IGNB_CA_ATT_2_SCELL_SA}=0
    ...    NRCELL-12:NCAC:${IGNB_CA_ATT_2_SCELL_SA_SUCC}=0
    ...    NRCELL-12:NCAC:${UE_PCELL_1_CONF_SCELL_DL_SA}=0
    ...    NRCELL-12:NCAC:${UE_PCELL_1_CONF_SCELL_UL_SA}=0
    ...    NRCELL-12:NCAC:${UE_PCELL_2_CONF_SCELL_DL_SA}=0
    ...    NRCELL-12:NCAC:${UE_SCELL_1_CONF_SCELL_DL_SA}=0
    ...    NRCELL-12:NCAC:${UE_SCELL_2_CONF_SCELL_DL_SA}=0
    ...    last NRCELL-12:NCAC:${UE_SCELL_1_CONF_SCELL_UL_SA}=0
    Check Counters GNB2    ${pm_counters}
