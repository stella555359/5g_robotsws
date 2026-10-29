*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CLOUD_5G_I_[LO][LO]_AP_[LOO]_SANSA_FS_ECPRI_CMWV_TDD    team-ROCK
...    owner-jia.pan    release-SBTS23R3    CRT
Resource          ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${NOKIA_XNAP_PLUGIN_FLAG}    ${True}
#${NOKIA_F1AP_PLUGIN_FLAG}    ${True}

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

@{PARAMS_IN_SCF_GNB2}
...    @{PARAMS_FOR_CA}
...    @{PARAMS_FOR_GNB2}
...    @{PARAMS_ADJ_REL_FOR_GNB2}
...    @{PARAMS_FOR_OTHERS}
...    @{GNB2_CA_rel_for_NRCELL_1}
...    @{GNB2_CA_rel_for_NRCELL_14}
...    @{6137_Ul}
...    @{A1pcellchange_FOR_GNB2}

@{PARAMS_FOR_CA}
...    NRBTS:actCarrierAggregation=true
...    NRBTS:sCellActivationMethod=blind
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
...    NRDU-1:xgUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRCELL:actK1Opt=intraAndInter-gNB
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRDU-1:actConnectedModeMobilityCA=true
${CA_support_list}    ca_Fdd_Fdd,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Fr1Tdd_Sa_WithUl,ca_Fdd_Any_Sa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Fdd_Sa_WithUl

@{A1pcellchange_FOR_GNB2}
...    NRBTS:actHoOptimizationCa=true
...    NRBTS/NRCELL-14:maxNumScellsDlFr1=3
...    NRCELL-14:measGapSelectionSA=favourUeThroughput
...    NRCELL:a1MeasSCellAddEnabled=rsrp
...    NRCELL:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=90|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=70|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a2MeasSCellRelEnabled=rsrp
...    NRCELL:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=480ms
...    NRCELL:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=40|a2TimeToTriggerSCellRelSsbRsrp=480ms
...    NRCELL-14/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-14/NRHOIF-1:freqBandIndicatorNR=77
...    NRCELL-14/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-14/NRHOIF-1:ifhoSsbSmtcDuration=sf2
...    NRCELL-14/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-14/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-14/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-14/NRHOIF-1:ssbFrequency=663360
...    NRCELL-14/NRHOIF-1:a1BasedPCellSwitchEnabled=true
...    NRCELL-1:a1MeasPCellSwitchEnabled=rsrp
...    NRCELL-1:a1MeasPCellSwitchSsbRsrp:a1HysteresisPCellSwitchSsbRsrp=0|a1ThresholdPCellSwitchSsbRsrp=31|a1TimeToTriggerPCellSwitchSsbRsrp=0ms
...    NRCELL-14/NRHOIF-3:cellDepType=SA+NSA
...    NRCELL-14/NRHOIF-3:freqBandIndicatorNR=77
...    NRCELL-14/NRHOIF-3:ifhoSsbScs=30 KHz
...    NRCELL-14/NRHOIF-3:ifhoSsbSmtcDuration=sf2
...    NRCELL-14/NRHOIF-3:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-14/NRHOIF-3:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-14/NRHOIF-3:ssBurstSetPeriod=20
...    NRCELL-14/NRHOIF-3:ssbFrequency=657984
...    NRCELL-14/NRHOIF-3:a1BasedPCellSwitchEnabled=true
...    NRCELL-2:a1MeasPCellSwitchEnabled=rsrp
...    NRCELL-2:a1MeasPCellSwitchSsbRsrp:a1HysteresisPCellSwitchSsbRsrp=0|a1ThresholdPCellSwitchSsbRsrp=32|a1TimeToTriggerPCellSwitchSsbRsrp=0ms
...    NRCELL-14/NRHOIF-2:cellDepType=SA+NSA
...    NRCELL-14/NRHOIF-2:freqBandIndicatorNR=3
...    NRCELL-14/NRHOIF-2:ifhoSsbScs=15KHz
...    NRCELL-14/NRHOIF-2:ifhoSsbSmtcDuration=sf2
...    NRCELL-14/NRHOIF-2:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-14/NRHOIF-2:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-14/NRHOIF-2:ssBurstSetPeriod=20
...    NRCELL-14/NRHOIF-2:ssbFrequency=368430
...    NRCELL-14/NRHOIF-2:a1BasedPCellSwitchEnabled=true
...    NRCELL-13:a1MeasPCellSwitchEnabled=rsrp
...    NRCELL-13:a1MeasPCellSwitchSsbRsrp:a1HysteresisPCellSwitchSsbRsrp=0|a1ThresholdPCellSwitchSsbRsrp=33|a1TimeToTriggerPCellSwitchSsbRsrp=0ms

@{PARAMS_FOR_GNB1}
...    NRCELL-11/NRCELL_FDD-1:chBwDl=10MHz
...    NRCELL-11/NRCELL_FDD-1:chBwUl=10MHz
...    NRCELL-11/NRCELL_FDD-1:nrarfcnDl=368400
...    NRCELL-11/NRCELL_FDD-1:nrarfcnUl=349400
...    NRCELL-11:gscnOrSsPbchArfcn=4605
...    NRCELL:sCellDeactivationTimerGNB=infinity
...    NRCELL-11:a2MeasSCellRelEnabled=rsrp
...    NRCELL-11:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=480ms
...    NRCELL-11:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=40|a2TimeToTriggerSCellRelSsbRsrp=480ms

@{PARAMS_ADJ_REL_FOR_GNB1}
...    NRBTS:iGnbCaXnCfUpBackOffTmr=60
...    NRBTS:iGnbCaXnSetupReqTmr=60
...    NRBTS:iGnbCaXnSetupRespTmr=60
...    NRBTS:intGnbScellTempBlockTmr=60
...    NRBTS/NRADJGNB-2:administrativeState=Unlocked
...    NRBTS/NRADJGNB-2:gNbIdLength=22
...    NRBTS/NRADJGNB-2:gNodeBId=2
...    NRBTS/NRADJGNB-2:weightForIgnbCaSelection=1
...    NRBTS/NRADJGNB-2:xnLinkRef=1
...    NRBTS/NRADJGNB-2:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-2:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-2:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-1:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-1:fiveGsTac=200
...    NRBTS/NRADJNRCELL-1:gNbId=2
...    NRBTS/NRADJNRCELL-1:gNbIdLength=22
...    NRBTS/NRADJNRCELL-1:lcrId=1
...    NRBTS/NRADJNRCELL-1:nrarfcn=663400
...    NRBTS/NRADJNRCELL-1:physCellId=50
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-2:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-2:fiveGsTac=200
...    NRBTS/NRADJNRCELL-2:gNbId=2
...    NRBTS/NRADJNRCELL-2:gNbIdLength=22
...    NRBTS/NRADJNRCELL-2:lcrId=2
...    NRBTS/NRADJNRCELL-2:nrarfcn=658000
...    NRBTS/NRADJNRCELL-2:physCellId=51
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-13:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-13:fiveGsTac=200
...    NRBTS/NRADJNRCELL-13:gNbId=2
...    NRBTS/NRADJNRCELL-13:gNbIdLength=22
...    NRBTS/NRADJNRCELL-13:lcrId=13
...    NRBTS/NRADJNRCELL-13:nrarfcn=368400
...    NRBTS/NRADJNRCELL-13:physCellId=62
...    NRBTS/NRADJNRCELL-13:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-13:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-13:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-14:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-14:fiveGsTac=200
...    NRBTS/NRADJNRCELL-14:gNbId=2
...    NRBTS/NRADJNRCELL-14:gNbIdLength=22
...    NRBTS/NRADJNRCELL-14:lcrId=14
...    NRBTS/NRADJNRCELL-14:nrarfcn=153400
...    NRBTS/NRADJNRCELL-14:physCellId=63
...    NRBTS/NRADJNRCELL-14:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-14:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-14:gnbPlmn:mncLength=3

@{PARAMS_FOR_GNB2}
...    NRBTS:iGnbCaXnCfUpBackOffTmr=60
...    NRBTS:iGnbCaXnSetupReqTmr=90
...    NRBTS:iGnbCaXnSetupRespTmr=60
...    NRBTS:intGnbScellTempBlockTmr=60
...    NRCELL:sCellDeactivationTimerGNB=infinity
...    NRBTS:actInterFreqHoSA=true
...    NRPMRNL-1:miNrRelReportCu=5min

@{PARAMS_ADJ_REL_FOR_GNB2}
...    NRBTS/NRADJGNB-1:administrativeState=Unlocked
...    NRBTS/NRADJGNB-1:gNbIdLength=22
...    NRBTS/NRADJGNB-1:gNodeBId=1
...    NRBTS/NRADJGNB-1:weightForIgnbCaSelection=1
...    NRBTS/NRADJGNB-1:xnLinkRef=1
...    NRBTS/NRADJGNB-1:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-1:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-11:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-11:fiveGsTac=200
...    NRBTS/NRADJNRCELL-11:gNbId=1
...    NRBTS/NRADJNRCELL-11:gNbIdLength=22
...    NRBTS/NRADJNRCELL-11:lcrId=11
...    NRBTS/NRADJNRCELL-11:nrarfcn=368400
...    NRBTS/NRADJNRCELL-11:physCellId=60
...    NRBTS/NRADJNRCELL-11:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-11:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-11:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-11:ssbFrequency=368430
...    NRBTS/NRADJNRCELL-11:freqBandIndicatorNR=3
...    NRBTS/NRADJNRCELL-12:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-12:fiveGsTac=200
...    NRBTS/NRADJNRCELL-12:gNbId=1
...    NRBTS/NRADJNRCELL-12:gNbIdLength=22
...    NRBTS/NRADJNRCELL-12:lcrId=12
...    NRBTS/NRADJNRCELL-12:nrarfcn=374000
...    NRBTS/NRADJNRCELL-12:physCellId=61
...    NRBTS/NRADJNRCELL-12:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-12:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-12:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-12:ssbFrequency=373970
...    NRBTS/NRADJNRCELL-12:freqBandIndicatorNR=3

@{PARAMS_FOR_OTHERS}


...    NRBTS:actRanSharing=false
...    NRCELL:actCDrx=false
...    NRBTS:cipherPrefL:nea0=8
...    NRBTS:cipherPrefL:nea1_128=0
...    NRBTS:cipherPrefL:nea2_128=0
...    NRBTS:cipherPrefL:nea3_128=0
...    NRCELL:timingAdvanceOffset=n25600

@{GNB2_CA_rel_for_NRCELL_1}
...    NRCELL-1/NRREL-11:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-11:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-11:gNbId=1
...    NRCELL-1/NRREL-11:gNbIdLength=22
...    NRCELL-1/NRREL-11:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-11:lcrId=11
...    NRCELL-1/NRREL-11:removeNotAllowed=false
...    NRCELL-1/NRREL-11:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-11:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-11:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-11:gnbPlmn:mncLength=3
...    NRCELL-1:a1MeasSCellAddEnabled=rsrp
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=70|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=90|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-1:a2MeasPCellSwitchEnabled=rsrp
...    NRCELL-1:a2MeasPCellSwitchSsbRsrp:a2HysteresisPCellSwitchSsbRsrp=0|pCellSwitchOffsetSsbRsrp=0
...    NRCELL-1:a2MeasPCellSwitchSsbRsrp:a2ThresholdPCellSwitchSsbRsrp=50|pCellSwitchOffsetSsbRsrp=0
...    NRCELL-1:a2MeasPCellSwitchSsbRsrp:a2TimeToTriggerPCellSwitchSsbRsrp=0ms|pCellSwitchOffsetSsbRsrp=0
...    NRCELL-1:a2MeasRedirectEnabled=rsrp
...    NRCELL-1/NRHOIF-11:a2BasedPCellSwitchEnabled=true
...    NRCELL-1/NRHOIF-11:a2BasedPCellSwitchPriority=1
...    NRCELL-1/NRHOIF-11:thresholdPCellSwitchTargetRsrp=50
...    NRCELL-1/NRHOIF-11:thresholdPCellSwitchTargetRsrq=40
...    NRCELL-1/NRHOIF-11:cellDepType=SA
...    NRCELL-1/NRHOIF-11:freqBandIndicatorNR=3
...    NRCELL-1/NRHOIF-11:ifhoSsbScs=15KHz
...    NRCELL-1/NRHOIF-11:ifhoSsbSmtcDuration=sf2
...    NRCELL-1/NRHOIF-11:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-11:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-1/NRHOIF-11:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-11:ssbFrequency=368430
...    NRCELL-1:measGapSelectionSA=favourUeThroughput

@{GNB2_CA_rel_for_NRCELL_14}
...    NRCELL-14/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-14/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-14/NRREL-1:gNbId=2
...    NRCELL-14/NRREL-1:gNbIdLength=22
...    NRCELL-14/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-14/NRREL-1:lcrId=1
...    NRCELL-14/NRREL-1:removeNotAllowed=false
...    NRCELL-14/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-14/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-14/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-14/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-14/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-14/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-14/NRREL-2:gNbId=2
...    NRCELL-14/NRREL-2:gNbIdLength=22
...    NRCELL-14/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-14/NRREL-2:lcrId=2
...    NRCELL-14/NRREL-2:removeNotAllowed=false
...    NRCELL-14/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-14/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-14/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-14/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-14/NRREL-13:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-14/NRREL-13:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-14/NRREL-13:gNbId=2
...    NRCELL-14/NRREL-13:gNbIdLength=22
...    NRCELL-14/NRREL-13:handoverAllowedSA=allowed
...    NRCELL-14/NRREL-13:lcrId=13
...    NRCELL-14/NRREL-13:removeNotAllowed=false
...    NRCELL-14/NRREL-13:sCellAdditionMethod=covBasedA1
...    NRCELL-14/NRREL-13:gnbPlmn:mcc=311
...    NRCELL-14/NRREL-13:gnbPlmn:mnc=489
...    NRCELL-14/NRREL-13:gnbPlmn:mncLength=3
...    NRCELL-14/NRREL-12:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-14/NRREL-12:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-14/NRREL-12:gNbId=1
...    NRCELL-14/NRREL-12:gNbIdLength=22
...    NRCELL-14/NRREL-12:handoverAllowedSA=allowed
...    NRCELL-14/NRREL-12:lcrId=12
...    NRCELL-14/NRREL-12:removeNotAllowed=false
...    NRCELL-14/NRREL-12:sCellAdditionMethod=covBasedA1
...    NRCELL-14/NRREL-12:gnbPlmn:mcc=311
...    NRCELL-14/NRREL-12:gnbPlmn:mnc=489
...    NRCELL-14/NRREL-12:gnbPlmn:mncLength=3

@{6137_Ul}
...    NRCELL-14/NRREL-1:sCellOperationalMode=dlAndUl
...    NRCELL-14/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-14/NRREL-13:sCellOperationalMode=dlOnly
...    NRCELL:actUl256Qam=true
...    NRCELL:timingAdvanceOffset=n25600

@{OnlineParam_GD006}
...    NRCELL-1:weightForSCellSelection=4
...    NRCELL-2:weightForSCellSelection=5
...    NRCELL:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=50|a2TimeToTriggerSCellRelSsbRsrp=480ms

@{OnlineParam_GD006_recover}
...    NRCELL-1:weightForSCellSelection=50
...    NRCELL-2:weightForSCellSelection=50
...    NRCELL:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=40|a2TimeToTriggerSCellRelSsbRsrp=480ms

@{OnlineParam_GD002}
...    NRCELL-1/NRREL-14:sCellOperationalMode=dlAndUl
...    NRCELL-1/NRREL-11:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-11:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-11:gNbId=1
...    NRCELL-1/NRREL-11:gNbIdLength=22
...    NRCELL-1/NRREL-11:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-11:lcrId=11
...    NRCELL-1/NRREL-11:removeNotAllowed=false
...    NRCELL-1/NRREL-11:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-11:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-11:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-11:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-12:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-12:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-12:gNbId=1
...    NRCELL-1/NRREL-12:gNbIdLength=22
...    NRCELL-1/NRREL-12:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-12:lcrId=12
...    NRCELL-1/NRREL-12:removeNotAllowed=false
...    NRCELL-1/NRREL-12:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-12:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-12:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-12:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-14:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-14:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-14:gNbId=2
...    NRCELL-1/NRREL-14:gNbIdLength=22
...    NRCELL-1/NRREL-14:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-14:lcrId=14
...    NRCELL-1/NRREL-14:removeNotAllowed=false
...    NRCELL-1/NRREL-14:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-14:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-14:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-14:gnbPlmn:mncLength=3

@{OnlineParam_GD002_recover}
...    delete:NRCELL-1/NRREL-11
...    delete:NRCELL-1/NRREL-12
...    delete:NRCELL-1/NRREL-14

#supportedBandCombinationList:n3_n28 for SCELL UL capability.
#supportedBandCombinationList:n77_n28 for SCELL UL capability.
${SA_Capa_forGD006_UE1}    SEPARATOR=
...    E9A09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C47013B8D80D81AC1184341020E9068036B64C558D0
...    E7C471E819F604F8C48E3C873EA39F30C7942C0E070F05C00FFC0070005F0005C0000E0541B00B582308682041E20D00656C98AB121CFB027
...    C471E31238F21CFA8E7CC31E50B0381C3C27F6000001FD800000170000381546C4CD608C21A0810748340185B262A88873E238F11C7A067D8
...    13E31CF9863CA1607038782E007FE003801FF8002E0000702A0D837AC1184341020F1068032B64C55890E7C471EC09F1891C790E7D473E618
...    F28581C0E1E13FFE00000FFF800000B80001C0AA3626EB04610D00000201A00C2D926544439F11C79063D033EC09F00E7CC31E50B0381C3C1
...    7AAAAAAA9EAAAAAAA17000038004B0F06C00389800000C2C0AC3C1B000E010000070B0201200DC0068099000A0268BA000D80A14489B1CF87
...    0A244D8E7C3003810C60F417001E00140E0A00E0601280380030120020301F048010000000080040000001000006008000010040000100200
...    000C01000008008000050040020080200800006004000038020010000000400004002000024010000060080000A0040000580200102409004
...    00006019CA9ACA9AC14AC0CAC19AC15ACA5BC99BC05AC0DAC04AC08AC1DA0682000012CA48080000CB29302000032CA48080001CB29202000
...    092CA48080002CB293020000D2CA48080003CB29202000112CA48080004CB29202000152CA48080005CB29282000192CA480800018B292019
...    A55174AAAA9545D2A8AA0B154162A83455298AA4D154062A8145526AAA0F142C007000A000384040080101002004402004008080100202004
...    0088040300501002004040080108080600A020040088040400501010014040580B18080600C02018028080600C02004008804030050100C01
...    4040080108080600A02018028D50F8000810182030385058606880889098A0C0C8D8E0E8F909293139414951697A0A0C1680

#supportedBandCombinationList:n77(2A)_n28_n3 for SCELL UL capability.
${SA_Capa_forGD006_UE2}    SEPARATOR=
...    E9A09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C47013B8D80D81AC1184341020E9068036B64C558D0
...    E7C471E819F604F8C48E3C873EA39F30C7942C0E070F05C00FFC0070005F0005C0000E0541B00B582308682041E20D00656C98AB121CFB027
...    C471E31238F21CFA8E7CC31E50B0381C3C27F6000001FD800000170000381546C4CD608C21A0810748340185B262A88873E238F11C7A067D8
...    13E31CF9863CA1607038782E007FE003801FF8002E0000702A0D837AC1184341020F1068032B64C55890E7C471EC09F1891C790E7D473E618
...    F28581C0E1E13FFE00000FFF800000B80001C0AA3626EB04610D00000201A00C2D926544439F11C79063D033EC09F00E7CC31E50B0381C3C1
...    7AAAAAAA9EAAAAAAA17000038002B1F06C003898001C4C000E010000030B0201200DC0068099000A0268BA0009806344891226C73E1802808
...    CF417001E00140E0A00E0601280380030120020301F048010000000080040000001000006008000010040000100200000C010000080080000
...    50040020080200800006004000038020010000000400004002000024010000060080000A004000058020010240900400006019CA9ACA9AC14
...    AC0CAC19AC15ACA5BC99BC05AC0DAC04AC08AC1DA0682000012CA48080000CB29302000032CA48080001CB29202000092CA48080002CB2930
...    20000D2CA48080003CB29202000112CA48080004CB29202000152CA48080005CB29282000192CA480800018B292019A55174AAAA9545D2A8A
...    A0B154162A83455298AA4D154062A8145526AAA0F142C007000A0003840400801010020044020040080801002020040088040300501002004
...    040080118080600A020040080801002020180288040400501010014040580B18080600C02018028080600C02004008804030050100C014040
...    080108080600A02018028D50F8000810182030385058606880889098A0C0C8D8E0E8F909293139414951697A0A0C1680

*** Test Cases ***
CB008140-ET-GD005_A2_Pcell_change_not_activated_during_ext-Scell_addition
    [Documentation]
    ...    This case is to Verify A2 Pcell change not activated for IgNB CA
    ...    [Configuration]:
    ...    Cell2_1 has been configured in gNB-1 as candidate SCell of Cell3_1 via respective NRREL MOC, with SCell addition method covBasedA1
    ...    Event A1 measurement configuration for SCell Addition in gNB-1 is set to RSRP, a1ThresholdSCellAddSsbRsrpTDD and
    ...    a1ThresholdSCellAddSsbRsrpFDD set with different value.
    ...    The parameter NRBTS/NRDU/carrierAggregationSupportList in gNB-1 contains entry ca_Fr1Tdd_Fdd_Sa
    ...    CB008140 is active, i.e. NRBTS/NRDU/actInterGnbCa is set to DLOnly both in gNB-1 and in gNB-2.
    ...    Inter-gNB CA Xn and Xp between gNB-1 and gNB-2 configured.
    ...    In gNB-1:
    ...    PCell change inter-frequency HO related parameters for A2 measurement are configured.
    ...    In gNB-2:
    ...    A2 for scell release on cell2_1 is configured
    ...    UE capability:
    ...    5G-UE supports band combination n77-n3.
    ...    [Test Case Steps]:
    ...    1. UE attach to cell3_1 and start both UL/DL traffic
    ...    2. trigger scell addition A1 MR
    ...    [Expected result]:
    ...    1. UE attach successfully, Both UL/DL can reach peak TP
    ...    2. cell2_1 is added as scell,Both UL/DL can reach peak TP.scell addition A1 is removed, pcell change A2 is not configured
    ...       scell release A2 is configured. XnAP: IGNB CA RESOURCE STATUS UDPATE is periodic sent from external gNB to prime gNB.
    [Tags]    GD005    QC_250837
    Sa Ue Attach    1    1    3    1
    Setup pdu session with scelladd
    UE Deregister From gNB    1
    Check WireShark Log GNB2    ${CURDIR}${/}A2A_GD_005${/}a2a_gnb2.ini    wait_string=UEContextRelease::12

CB008140-ET-GD002_Single_UE_connection_setup_with_IgNB_blind_CA_dlToUlContributionRatio_50_and_scell_with_less_ServedUEs_Scell
    [Documentation]
    ...    This case is to Verify scell selection when dlToUlContributionRatio=50 with different servedUEs_Scell.
    ...    [Configuration]:
    ...    Cell id=11 gnb=1 pci=20:0 tac=200 tdd_cell=off band=n3 nr_arfcn=368400:349400 gscn=4605 chBw=10MHz ssbFrequency=368430
    ...    Cell id=12 gnb=1 pci=20:1 tac=200 tdd_cell=off band=n3 nr_arfcn=374000:355000 gscn=4675 chBw=15MHz ssbFrequency=373970
    ...    Cell id=1 gnb=2 pci=16:0 tac=200 tdd_cell=on band=n77 nr_arfcn=663400:663400 gscn=8159 chBw=100MHz ssbFrequency=663360
    ...    Cell id=14 gnb=2 pci=20:3 tac=200 tdd_cell=off band=n3 nr_arfcn=153400:143400 gscn=1916 chBw=15MHz ssbFrequency=153370
    ...    cell11 and cell12 are on GNB1,cell1 and cell14 are on gnb2
    ...    cell11,cell12,cell14 are configured as scell for cell1.BW-cell11< BW-cell12.cell14 has 2 ServedUEs.
    ...    2.Test Case Steps:
    ...         a. UE2 and UE3 attach to cell14,UE1 Register And PDU Session Setup On cell1.
    ...         b. blind scelladdition to cell12.
    ...         c. deregister UE1
    ...         d. repeat step a,b,c
    [Tags]    GD002    QC_250836
    OnlineParamChange    ${OnlineParam_GD002}
    Sa Ue Attach    2    1    3    14
    Sa Ue Attach    3    1    3    14
    Sa Ue Attach    1    1    3    1
    Setup pdu session with scell12add
    Send Throuput
    Verify Throuput For TF    1    200    60
    UE Deregister From gNB    1
    Check WireShark Log GNB2    ${CURDIR}${/}A2A_GD_002${/}a2a_gnb2.ini    wait_string=UEContextRelease::12
    [Teardown]    GD002 TestTeardown

CB008140-ET-GD006_Intra_gNB_scell_selected_with_smaller_chbw_for_scell
    [Documentation]
    ...    This case is to Verify A1 Scell change within intra gNB interworking with inter-gNB CA.
    ...    [Configuration]:
    ...    Cell id=1 gnb=1 pci=16:0 tac=200 tdd_cell=off band=n77 nr_arfcn=663400:663400 gscn=8159 chBw=100MHz ssbFrequency=663360
    ...    Cell id=2 gnb=1 pci=16:1 tac=200 tdd_cell=off band=n77 nr_arfcn=658000:658000 gscn=8103 chBw=40MHz ssbFrequency=657984
    ...    Cell id=13 gnb=1 pci=20:2 tac=200 tdd_cell=off band=n3 nr_arfcn=368400:349400 gscn=4605 chBw=10MHz ssbFrequency=368430
    ...    Cell id=14 gnb=1 pci=20:3 tac=200 tdd_cell=on band=n28 nr_arfcn=153400:143400 gscn=1916 chBw=15MHz ssbFrequency=153370
    ...    Cell id=12 gnb=2 pci=20:0 tac=200 tdd_cell=off band=n3 nr_arfcn=368400:349400 gscn=4605 chBw=15MHz ssbFrequency=368430
    ...    cell 1,2,13,14 are on gnb1, cell12 is on gnb2. BWcell12>BWcell13
    ...    cell 1,2,13,12 are configured as scells of cell14.
    ...    2.Test Case Steps:
    ...         a. UE1 Register And PDU Session Setup On NRCELL-14
    ...         b. trigger scell addition A1 MR for UE1(threshold reach TDD but not reach FDD),CA F(CELL14)+T(CELL1) is setup.
    ...         C. trigger scell change A1 MR (threshold reach FDD),CA F(CELL14)+F(CELL13) is setup.
    ...         d. UE2 Register And PDU Session Setup On NRCELL-14
    ...         e. trigger scell addition A1 MR (threshold exceed both TDD and FDD),CA F(CELL14)+T(CELL1)+T(CELL2)+F(CELL13) is setup.
    ...         f. trigger scell release A2 MR on UE2 for cell13.
    ...         g. deregister UEs
    [Tags]    GD006    QC_250838
    OnlineParamChange    ${OnlineParam_GD006}
    Sa Ue1 Attach 
    Trigger A1MR For TDD
    Trigger A1MR scellchange 
    Sa Ue2 Attach
    Trigger A1MR
    Trigger ScellRelease For FDD
    UE Deregister From gNB
    UE Deregister From gNB    2 
    Check WireShark Log GNB2    ${CURDIR}${/}A2A_GD_006${/}a2a_gnb2.ini    wait_string=UEContextRelease::24
    [Teardown]    GD006 TestTeardown

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup 2Airphone Env    fddtdd_sansa_cmwv/6cells_gnb1_2F_gnb2_2T2F

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters gnb2    ${Online_Param}
    wait until keyword succeeds    10 min    60 sec    Cells Should Be OnAir

GD002 TestTeardown
    OnlineParamChange    ${OnlineParam_GD002_recover}
    Common Test Teardown And Stop Capture Logs

GD006 TestTeardown
    OnlineParamChange    ${OnlineParam_GD006_recover}
    Common Test Teardown And Stop Capture Logs

Update UE capa
    [Arguments]    ${SA_Capa_perUE_Full}=${SA_Capa_Support}    ${ue_id}=1
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full}
    Execute Egate Command    ${cmd}

Sa Ue Attach
    [Arguments]    ${ue_id}=1    ${gateway}=1    ${enb_id}=2    ${cell_id}=2
    ...    ${pass_regexp}=NG RM Register
    Execute Egate Command    ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    ${pass_regexp}

Setup pdu session with scelladd
    [Arguments]    ${ue_id}=1    ${gateway}=1
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${gateway}    QoS Routing Table
    Send Throuput
    Wait Until Keyword Succeeds    60s    10s    Verify Throuput on Pscell    ue_id=${ue_id}
    Trigger MR    event_type=A1    carrierfreq=663360    srsrp_nr=100    srsrq_nr=100    ue_id=${ue_id}
    Wait Until Keyword Succeeds    60s    10s    Verify Throuput For TF    ue_id=${ue_id}

Setup pdu session with scell12add
    [Arguments]    ${ue_id}=1    ${gateway}=1
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    ${ret}=    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${gateway}
    ...    pass_regexp=QoS Routing Table    timeout=20s
    Should Contain    ${ret}    pcid:50
    Should Contain    ${ret}    Initial Context Setup Successful for UE with AMF UE ID
    Should Contain    ${ret}    AMF-1: Setup QosFlow with QFI:1 5QI:6
    Should Contain    ${ret}    sCellIndex 1
    Should Contain    ${ret}    physCellId 61

Sa Ue1 Attach
    [Arguments]    ${ue_id}=1    ${gateway}=1    ${enb_id}=3    ${cell_id}=14
    ...    ${pass_regexp}=NG RM Register
    Update UE capa    ue_id=${ue_id}    SA_Capa_perUE_Full=${SA_Capa_forGD006_UE1}  
    Execute Egate Command    ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    ${pass_regexp}
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${gateway}    QoS Routing Table
    Send Throuput
    Wait Until Keyword Succeeds    60s    10s    Verify Throuput on Pscell    1    80

Sa Ue2 Attach
    [Arguments]    ${ue_id}=2    ${gateway}=1    ${enb_id}=3    ${cell_id}=14
    ...    ${pass_regexp}=NG RM Register
    Update UE capa    ue_id=${ue_id}    SA_Capa_perUE_Full=${SA_Capa_forGD006_UE2}  
    Execute Egate Command    ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    ${pass_regexp}
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${gateway}    QoS Routing Table
    Send Throuput for UE2
    Wait Until Keyword Succeeds    60s    10s    Verify Throuput on Pscell    2    30     20

UE Deregister From gNB
    [Arguments]    ${ue_id}=1
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=1    Traffic was stopped
    Execute Egate Command    ue_pdu_session_release ue=${ue_id} pdu=1    Successfully released PDU Session
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s

Verify Throuput on Pscell
    [Arguments]    ${ue_id}=1    ${pcell_dl}=430    ${ul}=40
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000>${pcell_dl}
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul}

Verify Throuput For TF
    [Arguments]    ${ue_id}=1    ${pcell_dl}=400    ${scell_dl_F}=40    ${ul}=40    ${scell_id}=1    ${pdu_id}=1
    sleep    10s     #sleep for stable traffic
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000 > ${pcell_dl}
    ${scellF1_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${scell_id}    type=pdsch    rate_type=ave
    Should Be True    ${scellF1_tput}/1000 > ${scell_dl_F}
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul}

Trigger MR
    [Arguments]    ${event_type}=A1    ${carrierfreq}=518910    ${srsrp_nr}=5    ${srsrq_nr}=5    ${ue_id}=82
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type}
    ...    srsrp_nr=${srsrp_nr} srsrq_nr=${srsrq_nr}
    Execute Egate Command    ${cmd}    pass_regexp=rrcReconfigurationComplete

Trigger A1MR For TDD
    [Arguments]    ${event_type}=A1    ${carrierfreq}=153370    ${srsrp_nr}=80    ${srsrq_nr}=50    ${ue_id}=1
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type}
    ...    srsrp_nr=${srsrp_nr} srsrq_nr=${srsrq_nr}
    Execute Egate Command    ${cmd}    pass_regexp=rrcReconfigurationComplete
    Wait Until Keyword Succeeds    60s    10s    Verify Throuput 2CC on Pscell and Scell for UL

Trigger A1MR
    [Arguments]    ${event_type}=A1    ${carrierfreq}=153370    ${srsrp_nr}=100    ${srsrq_nr}=50    ${ue_id}=2
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type}
    ...    srsrp_nr=${srsrp_nr} srsrq_nr=${srsrq_nr}
    Execute Egate Command    ${cmd}    pass_regexp=rrcReconfigurationComplete
    Wait Until Keyword Succeeds    60s    10s    Verify Throuput 4CC on Pscell and Scell

Trigger A1MR scellchange
    [Arguments]    ${event_type}=A1    ${carrierfreq}=153370    ${srsrp_nr}=100    ${srsrq_nr}=50    ${ue_id}=1
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type}
    ...    srsrp_nr=${srsrp_nr} srsrq_nr=${srsrq_nr}
    Execute Egate Command    ${cmd}    pass_regexp=rrcReconfigurationComplete
    Wait Until Keyword Succeeds    60s    10s    Verify Throuput 2CC on Pscell and Scell
    Stop partial Throuput    

Trigger ScellRelease For FDD
    [Arguments]    ${event_type}=A2    ${carrierfreq}=368430    ${scell_rsrp}=7    ${scell_rsrq}=7    ${ue_id}=2    ${scell_id}=3
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type}
    ...    scell=${scell_id} scell_rsrp=${scell_rsrp} scell_rsrq=${scell_rsrq}
    Execute Egate Command    ${cmd}    pass_regexp=rrcReconfigurationComplete
    Wait Until Keyword Succeeds    60s    10s    Verify Throuput 3CC on Pscell and Scell     

Send Throuput
    [Arguments]    ${ue_id}=1    
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=3    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=4    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=5    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=6    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=7    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=8    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=ul mbps=50 trf_id=1    UE ${ue_id}: UDP UL
    sleep    10s    #sleep for stable traffic

Stop partial Throuput
    [Arguments]    ${ue_id}=1    
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=2    Traffic was stopped
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=3    Traffic was stopped
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=4    Traffic was stopped
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=5    Traffic was stopped
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=6    Traffic was stopped
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=7    Traffic was stopped
    sleep    10s    #sleep for stable traffic

Send Throuput for UE2
    [Arguments]    ${ue_id}=2    
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=9    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=10    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=11    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=12    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=13    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=14    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=15    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=ul mbps=50 trf_id=16    UE ${ue_id}: UDP UL
    sleep    10s    #sleep for stable traffic

Verify Throuput 2CC on Pscell and Scell for UL
    [Arguments]    ${ue_id}=1    ${pcell_dl}=80    ${scell_dl}=480    ${ul}=40    ${scell_id}=1   
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000 > ${pcell_dl}
    ${scell_tput1}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${scell_id}    type=pdsch    rate_type=ave
    Should Be True    ${scell_tput1}/1000 > ${scell_dl}
    ${ul_throughput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pusch    rate_type=ave
    ${ul_throughput_scell}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=1    type=pusch    rate_type=ave
    Should Be True    ${ul_throughput_scell}/1000+${ul_throughput}/1000>${ul}

Verify Throuput 2CC on Pscell and Scell
    [Arguments]    ${ue_id}=1    ${pcell_dl}=80    ${scell_dl}=50    ${ul}=40    ${scell_id}=2   
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000 > ${pcell_dl}
    ${scell_tput1}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${scell_id}    type=pdsch    rate_type=ave
    Should Be True    ${scell_tput1}/1000 > ${scell_dl}
    ${ul_throughput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pusch    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul}

Verify Throuput 3CC on Pscell and Scell
    [Arguments]    ${ue_id}=2    ${pcell_dl}=80    ${scell_dl1}=480    ${scell_dl2}=180    ${ul}=40   
    ...    ${scell_id1}=1    ${scell_id2}=2   
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    ${UE1scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=1    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000+${UE1scell0_tput}/1000 > ${pcell_dl}
    ${scell_tput1}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${scell_id1}    type=pdsch    rate_type=ave
    Should Be True    ${scell_tput1}/1000 > ${scell_dl1}
    ${scell_tput2}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${scell_id2}    type=pdsch    rate_type=ave
    Should Be True    ${scell_tput2}/1000 > ${scell_dl2}
    ${ul_throughput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pusch    rate_type=ave
    ${ul_throughput_scell}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=1    type=pusch    rate_type=ave
    Should Be True    ${ul_throughput_scell}/1000+${ul_throughput}/1000>${ul}

Verify Throuput 4CC on Pscell and Scell
    [Arguments]    ${ue_id}=2    ${pcell_dl}=80    ${scell_dl1}=480    ${scell_dl2}=180    ${scell_dl3}=50    ${ul}=40    
    ...    ${scell_id1}=1    ${scell_id2}=2    ${scell_id3}=3
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    ${UE1scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=1    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000+${UE1scell0_tput}/1000 > ${pcell_dl}
    ${scell_tput1}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${scell_id1}    type=pdsch    rate_type=ave
    Should Be True    ${scell_tput1}/1000 > ${scell_dl1}
    ${scell_tput2}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${scell_id2}    type=pdsch    rate_type=ave
    Should Be True    ${scell_tput2}/1000 > ${scell_dl2}
    ${scell_tput3}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${scell_id3}    type=pdsch    rate_type=ave
    ${UE1scell_tput3}    Ap Get Throuput On Specific Scell    ue_id=1    scell_id=2    type=pdsch    rate_type=ave
    Should Be True    ${scell_tput3}/1000+${UE1scell_tput3}/1000 > ${scell_dl3}
    ${ul_throughput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pusch    rate_type=ave
    ${ul_throughput_scell}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=1    type=pusch    rate_type=ave
    Should Be True    ${ul_throughput_scell}/1000+${ul_throughput}/1000>${ul}

