*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CLOUD_5G_I_[LO][LO]_AP_[LOO]    team-rock
...    owner-christine.chen    release-SBTS23R3    CRT
Resource          ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${DEBUG_LOG_LEVEL}    4
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
...    @{GNB_PMQAP}
...    @{DRB}

@{PARAMS_IN_SCF_GNB2}
...    @{PARAMS_FOR_CA}
...    @{PARAMS_FOR_GNB2}
...    @{PARAMS_ADJ_REL_FOR_GNB2}
...    @{PARAMS_FOR_OTHERS}
...    @{GNB2_CA_rel_for_NRCELL_1}
...    @{GNB_PMQAP}

@{PARAMS_FOR_CA}
...    NRBTS:actCarrierAggregation=true
...    NRBTS:sCellActivationMethod=bufferBased
...    NRBTS:caConfigurationSupport=4CCDL_2CCUL
...    NRBTS:weightForIgnbCaSelection=1
...    NRBTS:rrcReestabTypeSA=sameGNB
...    NRBTS:tWaitingRlRecover=4000ms
...    NRBTS:tWaitingRlRecoverSA=4000ms
...    NRBTS:actIncXn=true
...    NRBTS:maxNumScellsDl=2
...    NRBTS:maxNumScellsUl=2
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:carrierAggregationSupportList=${CAlist}
...    NRBTS/NRDRB_RLC_AM-1:ulTReassemblyIBCA=40
...    NRBTS/NRDRB_RLC_AM-2:ulTReassemblyIBCA=40
...    NRDU-1:actInterGnbCa=DLOnly
...    NRDU-1:dlToUlContributionRatio=101
...    NRCELL:actK1Opt=intraAndInter-gNB
...    NRCELL:weightForSCellSelection=50
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRDU-1:xgUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
${CAlist}    ca_Fdd_Fr1Tdd_Sa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Any_Sa,ca_Fdd_Any_Sa,ca_Fdd_Fdd

@{PARAMS_FOR_GNB1}
...    NRCELL-1:sCellDeactivationTimerGNB=infinity
...    NRCELL-2:sCellDeactivationTimerGNB=infinity
...    NRCELL:chBw=40MHz

@{PARAMS_ADJ_REL_FOR_GNB1}
...    NRBTS:iGnbCaXnCfUpBackOffTmr=60
...    NRBTS:iGnbCaXnSetupReqTmr=60
...    NRBTS:iGnbCaXnSetupRespTmr=60
...    NRBTS:intGnbScellTempBlockTmr=60
...    NRBTS/NRADJGNB-2:administrativeState=Unlocked
...    NRBTS/NRADJGNB-2:gNbIdLength=22
...    NRBTS/NRADJGNB-2:gNodeBId=2
...    NRBTS/NRADJGNB-2:weightForIgnbCaSelection=50
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
...    NRBTS/NRADJNRCELL-3:freqBandIndicatorNR=77
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
...    NRBTS/NRADJNRCELL-4:freqBandIndicatorNR=77
...    NRBTS/NRADJNRCELL-4:physCellId=53
...    NRBTS/NRADJNRCELL-4:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-4:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-4:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-11:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-11:fiveGsTac=200
...    NRBTS/NRADJNRCELL-11:gNbId=2
...    NRBTS/NRADJNRCELL-11:gNbIdLength=22
...    NRBTS/NRADJNRCELL-11:lcrId=11
...    NRBTS/NRADJNRCELL-11:nrarfcn=368400
...    NRBTS/NRADJNRCELL-11:freqBandIndicatorNR=3
...    NRBTS/NRADJNRCELL-11:physCellId=60
...    NRBTS/NRADJNRCELL-11:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-11:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-11:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-12:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-12:fiveGsTac=200
...    NRBTS/NRADJNRCELL-12:gNbId=2
...    NRBTS/NRADJNRCELL-12:gNbIdLength=22
...    NRBTS/NRADJNRCELL-12:lcrId=12
...    NRBTS/NRADJNRCELL-12:nrarfcn=153400
...    NRBTS/NRADJNRCELL-12:freqBandIndicatorNR=28
...    NRBTS/NRADJNRCELL-12:physCellId=61
...    NRBTS/NRADJNRCELL-12:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-12:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-12:gnbPlmn:mncLength=3

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
...    NRCELL-1/NRREL-11:sCellOperationalMode=dlOnly

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
...    NRCELL-1/NRREL-12:sCellOperationalMode=dlOnly

...    NRCELL-2/NRREL-11:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-11:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-11:gNbId=2
...    NRCELL-2/NRREL-11:gNbIdLength=22
...    NRCELL-2/NRREL-11:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-11:lcrId=11
...    NRCELL-2/NRREL-11:removeNotAllowed=false
...    NRCELL-2/NRREL-11:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-11:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-11:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-11:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-11:sCellOperationalMode=dlOnly

...    NRCELL-2/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-3:gNbId=2
...    NRCELL-2/NRREL-3:gNbIdLength=22
...    NRCELL-2/NRREL-3:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-3:lcrId=3
...    NRCELL-2/NRREL-3:removeNotAllowed=false
...    NRCELL-2/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-3:sCellOperationalMode=dlOnly

...    NRCELL-1:a1MeasSCellAddEnabled=rsrp
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=70|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=90|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-2:a1MeasSCellAddEnabled=rsrp
...    NRCELL-2:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-2:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=70|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-2:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=90|a1TimeToTriggerSCellAddSsbRsrp=320ms

...    NRCELL-1:a2MeasSCellRelEnabled=rsrp
...    NRCELL-1:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=480ms
...    NRCELL-1:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=40|a2TimeToTriggerSCellRelSsbRsrp=480ms

...    NRCELL-2:a2MeasSCellRelEnabled=rsrp
...    NRCELL-2:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=480ms
...    NRCELL-2:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=40|a2TimeToTriggerSCellRelSsbRsrp=480ms

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

@{PARAMS_ADJ_REL_FOR_GNB2}
...    NRBTS/NRADJGNB-1:administrativeState=Unlocked
...    NRBTS/NRADJGNB-1:gNbIdLength=22
...    NRBTS/NRADJGNB-1:gNodeBId=1
...    NRBTS/NRADJGNB-1:weightForIgnbCaSelection=50
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
...    NRBTS/NRADJNRCELL-2:freqBandIndicatorNR=77

@{PARAMS_FOR_OTHERS}


...    NRBTS:actRanSharing=false
...    NRCELL:actCDrx=false
...    NRBTS:cipherPrefL:nea0=8
...    NRBTS:cipherPrefL:nea1_128=0
...    NRBTS:cipherPrefL:nea2_128=0
...    NRBTS:cipherPrefL:nea3_128=0
...    NRCELL:timingAdvanceOffset=n25600

@{GNB2_CA_rel_for_NRCELL_1}
...    NRCELL-3/NRREL-12:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-3/NRREL-12:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-3/NRREL-12:gNbId=2
...    NRCELL-3/NRREL-12:gNbIdLength=22
...    NRCELL-3/NRREL-12:handoverAllowedSA=allowed
...    NRCELL-3/NRREL-12:gnbPlmn:mnc=489
...    NRCELL-3/NRREL-12:gnbPlmn:mcc=311
...    NRCELL-3/NRREL-12:gnbPlmn:mncLength=3
...    NRCELL-3/NRREL-12:removeNotAllowed=false
...    NRCELL-3/NRREL-12:lcrId=12
...    NRCELL-3/NRREL-12:sCellAdditionMethod=covBasedA1
...    NRCELL-3/NRREL-12:sCellOperationalMode=dlOnly

...    NRCELL-12/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-1:gNbId=1
...    NRCELL-12/NRREL-1:gNbIdLength=22
...    NRCELL-12/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-12/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-1:removeNotAllowed=false
...    NRCELL-12/NRREL-1:lcrId=1
...    NRCELL-12/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-1:sCellOperationalMode=dlOnly

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
...    NRCELL-11/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-1:sCellOperationalMode=dlOnly

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
...    NRCELL-11/NRREL-2:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-2:sCellOperationalMode=dlOnly

...    NRCELL-3:a1MeasSCellAddEnabled=rsrp
...    NRCELL-3:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-3:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=70|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-3:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=90|a1TimeToTriggerSCellAddSsbRsrp=320ms

...    NRCELL-12:a1MeasSCellAddEnabled=rsrp
...    NRCELL-12:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-12:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=70|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-12:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=90|a1TimeToTriggerSCellAddSsbRsrp=320ms

...    NRCELL-11:a1MeasSCellAddEnabled=rsrp
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=70|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=90|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-11:a2MeasSCellRelEnabled=rsrp
...    NRCELL-11:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=480ms
...    NRCELL-11:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=40|a2TimeToTriggerSCellRelSsbRsrp=480ms
...    NRCELL-12:a2MeasSCellRelEnabled=rsrp
...    NRCELL-12:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=480ms
...    NRCELL-12:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=40|a2TimeToTriggerSCellRelSsbRsrp=480ms
...    NRCELL-3:a2MeasSCellRelEnabled=rsrp
...    NRCELL-3:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=480ms
...    NRCELL-3:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=40|a2TimeToTriggerSCellRelSsbRsrp=480ms
...    NRCELL-4:a2MeasSCellRelEnabled=rsrp
...    NRCELL-4:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=480ms
...    NRCELL-4:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=40|a2TimeToTriggerSCellRelSsbRsrp=480ms

@{DRB}
...    NRBTS-1/NRDRB_5QI-6:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-15
...    NRBTS-1/NRDRB_5QI-6:fiveqiValueList=1
...    NRBTS-1/NRDRB_5QI-1:fiveqiValueList=5
...    NRBTS-1/NRDRB-15:dlFlowControlAlgo=none
...    NRBTS-1/NRDRB-15:dscp=46
...    NRBTS-1/NRDRB-15:nrDrbId=15
...    NRBTS-1/NRDRB-15:actDddsReduction=false
...    NRBTS-1/NRDRB-15:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-3
...    NRBTS-1/NRDRB-15:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-2
...    NRBTS-1/NRDRB-15:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRBTS-1/NRDRB-15:numSduDiscard=1
...    NRBTS-1/NRDRB-15:queuingDelayDiscarding=Disabled
...    NRBTS-1/NRDRB-15:queuingDelaySduDiscardThreshold=750
...    NRBTS-1/NRDRB-15:resType=GBR
...    NRBTS-1/NRDRB-15:rlcMode=RLC_UM
...    NRBTS-1/NRDRB-15:sduDiscardIntervalTmr=500
...    NRBTS-1/NRDRB-15:discardTimer=10ms
...    NRBTS-1/NRDRB-15:l2OHFactorDl=16
...    NRBTS-1/NRDRB-15:l2OHFactorUl=35
...    NRBTS-1/NRDRB-15:maxDddsPeriodCpuOvld=40
...    NRBTS-1/NRDRB-15:schedulWeight=1
...    NRBTS-1/NRDRB-15:maxDataRateGbrDl=1000
...    NRBTS-1/NRDRB-15:actLostPduFastRetx=false
...    NRBTS-1/NRDRB-15:maxTransferDelayGbr=20
...    NRBTS-1/NRDRB-15:maxRlcQueueingDelayGbr=20
...    NRBTS-1/NRDRB-15:maxDataRateGbrUl=1000
...    NRBTS-1/NRDRB_RLC_UM-1:dlTReassemblyUm=ms40
...    NRBTS-1/NRDRB_RLC_UM-1:nrDrbRlcUmId=1
...    NRBTS-1/NRDRB_RLC_UM-1:ulTReassemblyUm=ms40
...    NRBTS-1/NRDRB_RLC_UM-1:rlcUMDrbSNLength=rlcUm12bitSN
...    NRBTS-1/NRDRB_PDCP-2:pdcpBufDiscardEnabled=false
...    NRBTS-1/NRDRB_PDCP-2:maxCidAllowed=4
...    NRBTS-1/NRDRB_MAC-3:lcgid=4
...    NRBTS-1/NRDRB_MAC-3:delayTarget=50
...    NRBTS-1/NRDRB_MAC-3:schedulPrio=5
...    NRBTS-1/NRDRB_MAC-3:prioritisedBitRate=16kBps
...    NRBTS-1/NRPMRNL-1:miNrRelReportCu=disabled
...    NRCELL-1:actVoNR=true
...    NRCELL-1:actEnhancedVoNR=true
...    NRCELL-1:n310VoNR=n10
...    NRCELL-1:t310VoNR=100ms
...    NRCELL-2:actVoNR=true
...    NRCELL-2:actEnhancedVoNR=true
...    NRCELL-2:n310VoNR=n10
...    NRCELL-2:t310VoNR=100ms

@{GNB_PMQAP}
...    NRBTS:actNrpmqapProfiles=true
...    NRPMRNL-1/NRPMQAP-1:cfgProfType=SA
...    NRPMRNL-1/NRPMQAP-1:cfg5qiRange=1-9
...    NRPMRNL-1/NRPMQAP-1:cfgArpRange=15
...    NRPMRNL-1/NRPMQAP-1:cfgPlmnId:mncLength=3
...    NRPMRNL-1/NRPMQAP-1:cfgPlmnId:mcc=311
...    NRPMRNL-1/NRPMQAP-1:cfgPlmnId:mnc=489
...    NRPMRNL-1/NRPMQAP-1:cfgSliceId:sst=1
...    NRPMRNL-1/NRPMQAP-1:cfgSliceId:sd=13714341
...    NRPMRNL-1/NRPMQAP-2:cfgProfType=SA
...    NRPMRNL-1/NRPMQAP-2:cfg5qiRange=1
...    NRPMRNL-1/NRPMQAP-2:cfgArpRange=15,1
...    NRPMRNL-1/NRPMQAP-2:cfgPlmnId:mncLength=3
...    NRPMRNL-1/NRPMQAP-2:cfgPlmnId:mcc=420
...    NRPMRNL-1/NRPMQAP-2:cfgPlmnId:mnc=06
...    NRPMRNL-1/NRPMQAP-2:cfgSliceId:sst=1
...    NRPMRNL-1/NRPMQAP-2:cfgSliceId:sd=13714341
...    NRPMRNL-1/NRPMQAP-3:cfgProfType=NSA
...    NRPMRNL-1/NRPMQAP-3:cfgArpRange=15,1
...    NRPMRNL-1/NRPMQAP-3:cfgPlmnId:mncLength=3
...    NRPMRNL-1/NRPMQAP-3:cfgPlmnId:mcc=311
...    NRPMRNL-1/NRPMQAP-3:cfgPlmnId:mnc=489

@{OnlineParam_GC015_for_GNB1}
...    NRCELL-1:maxNumOfUsersPerNRCell=1
...    NRCELL-1:maxNumOfCaUsersNRCell=1
...    NRCELL-1:maxNumOfSCellAlloc=1
...    NRCELL-1:maxNumOfUsersPerCell=1
...    NRCELL-1:maxNumOfRrcSA=1
...    NRCELL-1:maxNumOfNrDcSnUsers=1

@{OnlineParam_GC015_for_GNB2}
...    NRCELL-11/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-2:sCellAdditionMethod=covBasedA1

@{OnlineParam_GC015_recovery_for_GNB1}
...    NRCELL-1:maxNumOfUsersPerNRCell=275
...    NRCELL-1:maxNumOfCaUsersNRCell=250
...    NRCELL-1:maxNumOfSCellAlloc=250
...    NRCELL-1:maxNumOfUsersPerCell=275
...    NRCELL-1:maxNumOfRrcSA=275
...    NRCELL-1:maxNumOfNrDcSnUsers=275

@{OnlineParam_GC015_recovery_for_GNB2}
...    NRCELL-11/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-2:sCellAdditionMethod=blind

${HandoverFailure}    handoverFailure

@{PM_Counters_Check_GC010_GNB1}
...    NRDU-1:${RRC_REESTAB_HO_FAILURE_DU}=2
...    NRCELL-2:${NRD_RRC_REESTABREQ_PER_CELL}=1
...    NRCELL-2:${RRC_REESTAB_HO_FAILURE}=1
...    NRCELL-1:${NF1CC_DL_RRC_MSG_TRANSFER}=13
...    NRDU-1:${NF1CD_DL_RRC_MSG_TRANSFER}=16
...    NRCELL-2:${NRD_RRC_REESTREQ_PER_CELL_SUCC}=1
...    NRCELL-2:${REESTAB_ACC_HO_FAIL}=1
...    NRCELL-1:${NF1CC_UL_RRC_MSG_TRANSFER}=18
...    NRBTS-1:${NE1CS_CTXT_MOD_REQ_SENT}=11
...    NRBTS-1:${NE1CS_CTXT_MOD_RSP_RECD}=11
...    NRCELL-1:${F1_UE_CTXT_MOD_REQ_SENT}=13
...    NRDU-1:${REESTAB_ACC_HO_FAIL_DU}=2
...    NRDU-1:${F1_UE_CTXT_MOD_RESP_SENT}=18
...    NRCELL-1:${F1_UE_CTXT_MOD_RESP_RECEIVED}=13
...    NRCELL-1:${NRRCC_RRC_RECONF_SENT}=6
...    NRCELL-2:${REESTAB_RRCRECONFIG_SUCC}=1
...    NRCELL-1:${NRRCC_RRC_RECONF_CMP_RECD}=6
...    NRCELL-2:${NG_FLOW_STP_ATT_RES_IADU_PMQAP}=3
...    NRCELL-2:${NG_FLOW_STP_ATT_RES_IADU_5QI1}=1
...    NRCELL-2:${NG_FLOW_STP_SUC_RES_IADU_PMQAP}=3
...    NRCELL-2:${NG_FLOW_STP_SUC_RES_IADU_5QI1}=1

...    NRCELL-1:${NRD_RRC_REESTABREQ_PER_CELL}=1
...    NRCELL-1:${RRC_REESTAB_HO_FAILURE}=1
...    NRCELL-2:${NF1CC_DL_RRC_MSG_TRANSFER}=3
...    NRCELL-1:${NRD_RRC_REESTREQ_PER_CELL_SUCC}=1
...    NRCELL-1:${REESTAB_ACC_HO_FAIL}=1
...    NRCELL-2:${NF1CC_UL_RRC_MSG_TRANSFER}=4
...    NRCELL-2:${F1_UE_CTXT_MOD_REQ_SENT}=5
...    NRCELL-2:${F1_UE_CTXT_MOD_RESP_RECEIVED}=5
...    NRCELL-2:${NRRCC_RRC_RECONF_SENT}=2
...    NRCELL-1:${REESTAB_RRCRECONFIG_SUCC}=1
...    NRCELL-2:${NRRCC_RRC_RECONF_CMP_RECD}=2
...    NRCELL-1:${NG_FLOW_STP_ATT_RES_IADU_PMQAP}=3
...    NRCELL-1:${NG_FLOW_STP_ATT_RES_IADU_5QI1}=1
...    NRCELL-1:${NG_FLOW_STP_SUC_RES_IADU_PMQAP}=3
...    NRCELL-1:${NG_FLOW_STP_SUC_RES_IADU_5QI1}=1
...    NRCELL-1:NCAC:${IGNB_CA_ATT_SA_REL}=1
...    NRCELL-2:NCAC:${IGNB_CA_ATT_SA_REL}=1

@{PM_Counters_Check_GC012_GNB2}
...    NRCELL-3:${UE_PCELL_1_CONF_SCELL_DL_SA}>1
...    NRCELL-12:${UE_PCELL_1_CONF_SCELL_DL_SA}>1
...    NRCELL-12:${UE_SCELL_1_CONF_SCELL_DL_SA}>1
...    NRCELL-11:${UE_PCELL_2_CONF_SCELL_DL_SA}>1

@{PM_Counters_Check_GC015_GNB2}
...    NRCELL-11:${UE_PCELL_1_CONF_SCELL_DL_SA}>1
...    NRCELL-11:${UE_PCELL_2_CONF_SCELL_DL_SA}>1

@{PM_Counters_Check_GC016_GNB2}
...    NRCELL-11:${REESTAB_ACC_FALLBACK}=1
...    NRCELL-11:${RRC_REESTAB_FALLBACK}=1

${IGNB_CA_ATT_SA_REL}    M55118C11008
${RRC_REESTAB_HO_FAILURE_DU}    M55127C00502
${NRD_RRC_REESTABREQ_PER_CELL}    M55166C00501
${RRC_REESTAB_HO_FAILURE}    M55124C00504
${NF1CC_DL_RRC_MSG_TRANSFER}    M55113C00501
${NF1CD_DL_RRC_MSG_TRANSFER}    M55117C02001
${NRD_RRC_REESTREQ_PER_CELL_SUCC}    M55166C00504
${REESTAB_ACC_HO_FAIL}    M55124C00511
${NF1CC_UL_RRC_MSG_TRANSFER}    M55113C00502
${NE1CS_CTXT_MOD_REQ_SENT}    M55135C00505
${NE1CS_CTXT_MOD_RSP_RECD}    M55135C00506
${F1_UE_CTXT_MOD_REQ_SENT}    M55113C00001
${REESTAB_ACC_HO_FAIL_DU}    M55127C00511
${F1_UE_CTXT_MOD_RESP_SENT}    M55117C00002
${F1_UE_CTXT_MOD_RESP_RECEIVED}    M55113C00002
${NRRCC_RRC_RECONF_SENT}    M55124C03001
${REESTAB_RRCRECONFIG_SUCC}    M55124C00516
${NRRCC_RRC_RECONF_CMP_RECD}    M55124C03002
${NG_FLOW_STP_ATT_RES_IADU_PMQAP}    M55163C00530
${NG_FLOW_STP_ATT_RES_IADU_5QI1}    M55125C09531
${NG_FLOW_STP_SUC_RES_IADU_PMQAP}    M55163C00531
${NG_FLOW_STP_SUC_RES_IADU_5QI1}    M55125C09532

${UE_PCELL_1_CONF_SCELL_DL_SA}    M55118C05507
${UE_SCELL_1_CONF_SCELL_DL_SA}    M55118C05508
${UE_PCELL_2_CONF_SCELL_DL_SA}    M55118C07001
${REESTAB_ACC_FALLBACK}    M55124C00515
${RRC_REESTAB_FALLBACK}    M55124C00502

*** Test Cases ***
CB008140-ET-GC010_VONR RRE success to new cell in coverbased IgNB-CA mode
    [Documentation]
    ...    This case is to Verify VONR call re-establishment with valid UE context in coverbased IgNB-CA mode.(TFF->TTF)
    ...    [Configuration]:
    ...    CB008140 is active, i.e. NRBTS/NRDU/actInterGnbCa is set to "DLOnly" in gNB-1.
    ...    Cell2_11/cell2_12 has been configured in gNB-1 as candidate SCell of Cell1_1 with respective NRBTS/NRCELL/NRREL/sCellAdditionMethod
    ...    set to coverbased.
    ...    Cell2_3/cell2_11 has been configured in gNB-1 as candidate SCell of Cell1_2 with respective NRBTS/NRCELL/NRREL/sCellAdditionMethod
    ...    set to coverbased.
    ...    732 is active (NRBTS/rrcReestabTypeSA=sameGNB) and NRBTS/tWaitingRlRecover=4000ms on gNB-1.
    ...    VONR enabled on cell1_1 and cell1_2.
    ...    NRBTS.actNrpmqapProfiles=true on both gNBs, and related NEPMQAP object configured.
    ...    2.Test Case Steps:
    ...         a. UE attach to cell1_1 and Setup a new 5QI5 DRB and then 5QI1 DRB in PDU 2,start both UL/DL traffic in PDU1
    ...         b. trigger A1 MR for scell addition.
    ...         c. trigger RRE to cell1_2 with cause HO_FAILURE.
    ...         d. trigger A1 MR to scell addition.
    ...         e. trigger RRE back to cell1_1 with cause HO_FAILURE.
    ...         f. trigger A1 MR to scell addition.
    ...         g. check counter
    ...    3.expect result:
    ...         a. UE attach successfully,PUD setup successfully, scell addition A1 is configured to UE side, both UL/DL traffic is ok.
    ...         b. cell2_11/cell2_12 added as scell successfully,All DRB split to scells successfully,both UL/DL traffic is ok.
    ...         c. RRE success, no scell added,Both UL/DL in all DRB recover to peak TP without CA, All PDU and DRB recovers.
    ...         d. cell2_3/cell2_11 added as scell successfully,All DRB split to scells successfully.
    ...         e. RRE success, A1 scell addition configured to UE side.Both UL/DL in all DRB recover to peak TP without CA.
    ...         f. cell2_11/cell2_12 added as scell successfully,All DRB split to scells successfully.
    ...         g. check counter are ok.

    [Tags]    GC010    QC_257146
    Clear counter
    Ue register and pdu session setup for GC010
    Trigger MR scelladd    ue_id=1    carrierfreq=663360
    Check Throughput for case10 TFF
    Trigger RRC Reestablish    ue_id=1    gnb_id=2    cell_id=2    pcell_dl=175
    Trigger MR scelladd    ue_id=1    carrierfreq=657984
    Check Throughput for case10 TTF
    Trigger RRC Reestablish    ue_id=1    gnb_id=2    cell_id=1    pcell_dl=175
    Trigger MR scelladd    ue_id=1    carrierfreq=663360
    Check Throughput for case10 TFF
    Check Counters    ${PM_Counters_Check_GC010_GNB1}
    UE Deregister From gNB    ue_id=1
    Check WireShark Log    ${CURDIR}${/}A2A_GC_010${/}a2a.ini    wait_string=UEContextRelease::10
    [Teardown]    GC010 TestTeardown

CB008140-ET-GC012_RRE success to new intra-gnb cell with intra-gNB CA in coverbased IgNB-CA mode
    [Documentation]
    ...    This case is to check RRE success to new intra-gnb cell with intra-gNB CA in coverbased IgNB-CA mod.(FTT->TF)
    ...    [Configuration]:
    ...    CB008140 is active, i.e. NRBTS/NRDU/actInterGnbCa is set to "DLOnly" in gNB-1.
    ...    Cell1_1/cell1_2 has been configured in gNB-1 as candidate SCell of Cell2_11 with respective NRBTS/NRCELL/NRREL/sCellAdditionMethod
    ...    set to blind.
    ...    Cell2_12 has been configured in gNB-1 as candidate SCell of Cell2_3 with respective NRBTS/NRCELL/NRREL/sCellAdditionMethod
    ...    set to coverbased.
    ...    Cell1_1 has been configured in gNB-1 as candidate SCell of Cell2_12 with respective NRBTS/NRCELL/NRREL/sCellAdditionMethod
    ...    set to coverbased.
    ...    732 is active (NRBTS/rrcReestabTypeSA=sameGNB) and NRBTS/tWaitingRlRecover=4000ms on gNB-1.
    ...    2.Test Case Steps:
    ...         a. UE attach to cell2_11 and Setup a new PDU 2 with non GBR DRB and start DL traffic on new DRB
    ...         b. trigger RRE to cell2_3.
    ...         c. trigger A1 MR for scell addition.
    ...         d. trigger RRE back to cell2_11.
    ...         e. trigger RRE back to cell2_12.
    ...         f. trigger A1 MR to scell addition.
    ...         g. check counter
    ...    3.expect result:
    ...         a. UE attach successfully,PUD setup successfully, cell1_1/cell1_2 added as scell successful, both UL/DL traffic is ok.
    ...         b. RRE success, A1 for scell addition configured to UE side.Both UL DL in all DRB recover to peak TP with CA.
    ...         c. cell2_12 added as scell successfully,A2 for scell release is configured to UE side,All DRB split to scells successfully.
    ...         d. RRE success,no scell added,Both UL/DL in all DRB recover to peak TP with CA.
    ...         e. RRE success, A1 scell addition configured to UE side.Both UL/DL in all DRB recover to peak TP without CA.
    ...         f. cell1_1 added as scell successfully,A2 for scell release is configured to UE side,All DRB split to scells successfully.
    ...         g. check counter are ok.

    [Tags]    GC012    QC_257147
    Clear counter
    Ue register and pdu session setup and scelladded    ue_id=1    enb_id=3    cell_id=11
    Check Throughput for FTT
    Trigger RRC Reestablish    ue_id=1    gnb_id=3    cell_id=3    pcell_dl=175
    Trigger MR scelladd    ue_id=1    carrierfreq=653856
    Check Throughput for TF
    Trigger RRC Reestablish    ue_id=1    gnb_id=3    cell_id=11    pcell_dl=50
    Trigger RRC Reestablish    ue_id=1    gnb_id=3    cell_id=12    pcell_dl=50
    Trigger MR scelladd    ue_id=1    carrierfreq=153370
    Check Throughput for FT
    Check Counters GNB2    ${PM_Counters_Check_GC012_GNB2}    wait=True
    UE Deregister From gNB    ue_id=1
    Check WireShark Log GNB2    ${CURDIR}${/}A2A_GC_012${/}a2a_gnb2.ini    wait_string=UEContextRelease::10

CB008140-ET-GC016_RRE fallback to scell in coverbased IgNB-CA
    [Documentation]
    ...    This case is to check RRE fallback to scell in coverbased IgNB-CA.(TTF->F)
    ...    [Configuration]:
    ...    CB008140 is active, i.e. NRBTS/NRDU/actInterGnbCa is set to "DLOnly" in gNB-1.
    ...    Cell2_3/cell2_11 has been configured in gNB-1 as candidate SCell of Cell1_2 with respective NRBTS/NRCELL/NRREL/sCellAdditionMethod
    ...    set to coverbased.
    ...    732 is active (NRBTS/rrcReestabTypeSA=sameGNB) and NRBTS/tWaitingRlRecover=4000ms on gNB-1.
    ...    2.Test Case Steps:
    ...         a. UE attach to cell1_2 and Setup a new PDU 2 with non GBR DRB and start DL traffic on new DRB
    ...         b. trigger A1 MR for scell addition.
    ...         c. trigger RRE to cell2_11.
    ...         d. check counter
    ...    3.expect result:
    ...         a. UE attach successfully,PUD setup successfully, scell addition A1 is configured to UE side,both UL/DL traffic is ok.
    ...         b. cell2_3/cell2_11 added as scell successful,A2 for scell release is configured to UE side,All DRB split to scells successfully.
    ...         c. RE fallback to RRC setup, UE active on cell2_11, Original PDU and DRB all not recover on cell2_11, only AMF default DRB is setup.
    ...            in prime cell1_2, UE was released and ext-scells was released at ext-gNB via XnAP: IGNB CA RELEASE REQUEST
    ...         d. check counter are ok.

    [Tags]    GC016    QC_253764
    Clear counter
    Ue register and pdu session setup    ue_id=1    enb_id=2    cell_id=2    cmd_pdu_regexp=QoS Routing Table
    Trigger MR scelladd    ue_id=1    carrierfreq=657984
    Check Throughput for TTF
    Trigger RRC Reestablish    ue_id=1    gnb_id=3    cell_id=11    pcell_dl=0
    Check Throughput for case016 FTT
    check Counters GNB2    ${PM_Counters_Check_GC016_GNB2}    wait=True
    UE Deregister From gNB    ue_id=1
    Check WireShark Log    ${CURDIR}${/}A2A_GC_016${/}a2a.ini    wait_string=UEContextRelease::15
    Check WireShark Log GNB2    ${CURDIR}${/}A2A_GC_016${/}a2a_gnb2.ini    wait_string=UEContextRelease::14

CB008140-ET-GC015_partial Scell added after RRE to ori-cell in coverbased IgNB-CA mode due to resource change
    [Documentation]
    ...    This case is to check partial Scell added after RRE to ori-cell in coverbased IgNB-CA mode due to resource change.(FTT->FT)
    ...    [Configuration]:
    ...    CB008140 is active, i.e. NRBTS/NRDU/actInterGnbCa is set to "DLOnly" in gNB-1.
    ...    Cell1_1/cell1_2 has been configured in gNB-1 as candidate SCell of Cell2_11 with respective NRBTS/NRCELL/NRREL/sCellAdditionMethod
    ...    set to coverbased.
    ...    732 is active (NRBTS/rrcReestabTypeSA=sameGNB) and NRBTS/tWaitingRlRecover=4000ms on gNB-1.
    ...    NRCELL.maxNumOfUsersPerNRCell=1 in cell1_1.
    ...    2.Test Case Steps:
    ...         a. UE attach to cell2_11 and Setup a new PDU 2 with non GBR DRB and start DL traffic on new DRB
    ...         b. trigger A1 MR for scell addition.
    ...         c. trigger RRE back to cell2_11.
    ...         d. UE attach to cell2_1 and start both UL/DL traffic.
    ...         e. trigger A1 MR for scell addition.
    ...         f. check counter
    ...    3.expect result:
    ...         a. UE attach successfully,PUD setup successfully, scell addition A1 is configured to UE side,both UL/DL traffic is ok.
    ...         b. cell1_1/cell1_2 added as scell successful,A2 for scell release is configured to UE side,All DRB split to scells successfully.
    ...         c. RRE success, A1 scell addition configured to UE side.Both UL/DL in all DRB recover to peak TP without CA.
    ...         d. UE2 attach successfully,Both UL/DL can reach peak TP
    ...         e. cell1_2 added as scell successfully,cell1_1 added failed because no resource, All DRB split to scells successfully.
    ...         f. check counter are ok.

    [Tags]    GC015    QC_257148
    GC015 Online ParamChange
    Clear counter
    Ue register and pdu session setup    ue_id=1    enb_id=3    cell_id=11    cmd_pdu_regexp=QoS Routing Table
    Trigger MR scelladd    ue_id=1    carrierfreq=368430
    Check Throughput for FTT
    Trigger RRC Reestablish    ue_id=1    gnb_id=3    cell_id=11    pcell_dl=50
    Sa Ue Attach    ue_id=2
    Trigger MR scelladd    ue_id=1    carrierfreq=368430
    Check Throughput for cases15 FT
    Check Counters GNB2    ${PM_Counters_Check_GC015_GNB2}    wait=True
    UE Deregister From gNB for GC015    ue_id=1    ue_id1=2
    Check WireShark Log GNB2    ${CURDIR}${/}A2A_GC_015${/}a2a_gnb2.ini    wait_string=UEContextRelease::10
    [Teardown]    GC015 TestTeardown



*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup 2Airphone Env    fddtdd_sansa_cmwv/6cells_gnb1_2T_gnb2_2T2F

Modify Cfg
    Update Cfg    amf_param id=1 full_nas_auth=on nia=null nea=null ims_voice_3gpp=on
    Update Cfg    set_nwslice id=1 snssai=0x01:0xD143A5 qos_flows=1,2,3,4 qos_rules=1,2 default=on ue=all amf=1
    Update Cfg    set_nwslice id=2 snssai=0x01:0xD143A6 qos_flows=2,3,4 qos_rules=1,2 ue=all amf=1
    Update Cfg    set_qosflow id=2 5qi=5
    Update Cfg    set_qosflow id=3 5qi=1
    Update Cfg    set_qosflow id=4 5qi=9
    Update Cfg    set_qosrule id=1 proto=tcp qos_flow=2
    Update Cfg    set_qosrule id=2 proto=udp qos_flow=3

OnlineParamChange_gNB1
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    wait until keyword succeeds    10 min    60 sec    Cells Should Be OnAir

OnlineParamChange_gNB2
    [Arguments]    ${Online_Param}
    Delta Commission Parameters gnb2    ${Online_Param}
    wait until keyword succeeds    10 min    60 sec    Cells Should Be OnAir

GC015 Online ParamChange
    OnlineParamChange_gNB1    ${OnlineParam_GC015_for_GNB1}
    OnlineParamChange_gNB2    ${OnlineParam_GC015_for_GNB2}

GC015 TestTeardown
    OnlineParamChange_gNB1    ${OnlineParam_GC015_recovery_for_GNB1}
    OnlineParamChange_gNB2    ${OnlineParam_GC015_recovery_for_GNB2}
    Common Test Teardown And Stop Capture Logs

Clear counter
    Clear Counter Files
    Clear Counter Files GNB2

GC010 TestTeardown
    Execute Egate Command    qosflow_modify qos_flow=1 default=on
    Common Test Teardown And Stop Capture Logs

Trigger MR scelladd
    [Arguments]    ${ue_id}=1    ${carrierfreq}=650016
    Trigger MR    event_type=A1    carrierfreq=${carrierfreq}    srsrp_nr=100    srsrq_nr=100    ue_id=${ue_id}

UE Deregister From gNB
    [Arguments]    ${ue_id}
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=1    Traffic was stopped
    Execute Egate Command    ue_pdu_session_release ue=${ue_id} pdu=1    Successfully released PDU Session
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=2    Traffic was stopped
    Execute Egate Command    ue_pdu_session_release ue=${ue_id} pdu=2    Successfully released PDU Session
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s

UE Deregister From gNB for GC015
    [Arguments]    ${ue_id}    ${ue_id1}
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=1    Traffic was stopped
    Execute Egate Command    ue_pdu_session_release ue=${ue_id} pdu=1    Successfully released PDU Session
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=2    Traffic was stopped
    Execute Egate Command    ue_pdu_session_release ue=${ue_id} pdu=2    Successfully released PDU Session
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s
    Execute Egate Command    trf_data_stop ue=${ue_id1} pdu=1    Traffic was stopped
    Execute Egate Command    ue_pdu_session_release ue=${ue_id1} pdu=1    Successfully released PDU Session
    Execute Egate Command    ue_deregister id=${ue_id1} ue_deregister_type=switch_off    UE${ue_id1}: detached    timeout=10s

Trigger MR
    [Arguments]    ${event_type}=A1    ${carrierfreq}=518910    ${srsrp_nr}=5    ${srsrq_nr}=5    ${ue_id}=82
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type}
    ...    srsrp_nr=${srsrp_nr} srsrq_nr=${srsrq_nr}
    Execute Egate Command    ${cmd}    pass_regexp=rrcReconfigurationComplete

Trigger RRC Reestablish
    [Arguments]    ${ue_id}    ${gnb_id}    ${cell_id}    ${pcell_dl}
    ${ret1}=    Execute Egate Command    ue_rrc_reestablish id=${ue_id} gnb=${gnb_id} cell=${cell_id} cause=${HandoverFailure}
    ...    rrcReconfigurationComplete    timeout=20s
    Wait Until Keyword Succeeds    60s    10s    Check Throughput for pcell    ue_id=${ue_id}    pcell_dl=${pcell_dl}

PDU2 session setup
    [Arguments]    ${ue_id}=1
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=2 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=2 nwslice=1 gw=2    pass_regexp=PDU Session ID 2
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=2 qosflows_to_add=4 by=amf    pass_regexp=QoS Routing Table

Send Throughput
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${qfi}=1    ${times}=3    ${mbps}=25
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} dir=ul mbps=10 trf_id=1    UE ${ue_id}: UDP UL
    FOR    ${I}    IN RANGE    2    ${times}
        Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} dir=dl mbps=${mbps} trf_id=${I}    UE ${ue_id}: UDP DL
    END

Check Throughput for pcell
    [Arguments]    ${ue_id}=1    ${pcell_dl}=10
    ${pcell_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${pcell_tput}/1000 >= ${pcell_dl}

Check Throughput for scell1
    [Arguments]    ${ue_id}=1    ${scell1_dl}=10
    ${scell_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=1    type=pdsch    rate_type=ave
    Should Be True    ${scell_tput}/1000 >= ${scell1_dl}

Check Throughput for scell2
    [Arguments]    ${ue_id}=1    ${scell2_dl}=10
    ${scell2_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=2    type=pdsch    rate_type=ave
    Should Be True    ${scell2_tput}/1000 >= ${scell2_dl}

Check Throughput for UL
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${qfi}=1    ${TP_ul}=6
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    direction=ul    rate_type=ave
    Should Be True    ${ul_throughput}/1000 >= ${TP_ul}

Check Throughput for FTT
    Send Throughput    ue_id=1    pdu=1    qfi=1    times=7    mbps=5
    Send Throughput    ue_id=1    pdu=2    qfi=2    times=7    mbps=5
    Wait Until Keyword Succeeds    60s    10s    Check Throughput for pcell    ue_id=1    pcell_dl=40
    Wait Until Keyword Succeeds    60s    10s    Check Throughput for scell1    ue_id=1    scell1_dl=0
    Wait Until Keyword Succeeds    60s    10s    Check Throughput for scell2    ue_id=1    scell2_dl=0
    Send Throughput    ue_id=1    pdu=2    qfi=2    times=7    mbps=100
    Wait Until Keyword Succeeds    60s    10s    Check Throughput for pcell    ue_id=1    pcell_dl=50
    Wait Until Keyword Succeeds    60s    10s    Check Throughput for scell1    ue_id=1    scell1_dl=200
    Wait Until Keyword Succeeds    60s    10s    Check Throughput for scell2    ue_id=1    scell2_dl=200
    Wait Until Keyword Succeeds    60s    10s    Check Throughput for UL    ue_id=1    pdu=1    qfi=1    TP_ul=6
    Wait Until Keyword Succeeds    60s    10s    Check Throughput for UL    ue_id=1    pdu=2    qfi=2    TP_ul=6

Check Throughput for TF
    Send Throughput    ue_id=1    pdu=1    qfi=1    times=7    mbps=5
    Send Throughput    ue_id=1    pdu=2    qfi=2    times=7    mbps=5
    Wait Until Keyword Succeeds    60s    10s    Check Throughput for pcell    ue_id=1    pcell_dl=40
    Wait Until Keyword Succeeds    60s    10s    Check Throughput for scell1    ue_id=1    scell1_dl=0
    Send Throughput    ue_id=1    pdu=1    qfi=1    times=7    mbps=100
    Wait Until Keyword Succeeds    60s    10s    Check Throughput for pcell    ue_id=1    pcell_dl=175
    Wait Until Keyword Succeeds    60s    10s    Check Throughput for scell1    ue_id=1    scell1_dl=50
    Wait Until Keyword Succeeds    60s    10s    Check Throughput for UL    ue_id=1    pdu=1    qfi=1    TP_ul=6
    Wait Until Keyword Succeeds    60s    10s    Check Throughput for UL    ue_id=1    pdu=2    qfi=2    TP_ul=6

Check Throughput for FT
    Send Throughput    ue_id=1    pdu=1    qfi=1    times=7    mbps=5
    Send Throughput    ue_id=1    pdu=2    qfi=2    times=7    mbps=5
    Wait Until Keyword Succeeds    60s    10s    Check Throughput for pcell    ue_id=1    pcell_dl=40
    Wait Until Keyword Succeeds    60s    10s    Check Throughput for scell1    ue_id=1    scell1_dl=0
    Send Throughput    ue_id=1    pdu=1    qfi=1    times=7    mbps=30
    Send Throughput    ue_id=1    pdu=2    qfi=2    times=7    mbps=30
    Wait Until Keyword Succeeds    60s    10s    Check Throughput for pcell    ue_id=1    pcell_dl=50
    Wait Until Keyword Succeeds    60s    10s    Check Throughput for scell1    ue_id=1    scell1_dl=200
    Wait Until Keyword Succeeds    60s    10s    Check Throughput for UL    ue_id=1    pdu=1    qfi=1    TP_ul=6
    Wait Until Keyword Succeeds    60s    10s    Check Throughput for UL    ue_id=1    pdu=2    qfi=2    TP_ul=6

Check Throughput for cases15 FT
    Send Throughput    ue_id=1    pdu=1    qfi=1    times=7    mbps=5
    Send Throughput    ue_id=1    pdu=2    qfi=2    times=7    mbps=5
    Wait Until Keyword Succeeds    60s    10s    Check Throughput for pcell    ue_id=1    pcell_dl=40
    Wait Until Keyword Succeeds    60s    10s    Check Throughput for scell2    ue_id=1    scell2_dl=0
    Send Throughput    ue_id=1    pdu=1    qfi=1    times=7    mbps=30
    Send Throughput    ue_id=1    pdu=2    qfi=2    times=7    mbps=30
    Wait Until Keyword Succeeds    60s    10s    Check Throughput for pcell    ue_id=1    pcell_dl=50
    Wait Until Keyword Succeeds    60s    10s    Check Throughput for scell2    ue_id=1    scell2_dl=200
    Wait Until Keyword Succeeds    60s    10s    Check Throughput for UL    ue_id=1    pdu=1    qfi=1    TP_ul=6
    Wait Until Keyword Succeeds    60s    10s    Check Throughput for UL    ue_id=1    pdu=2    qfi=2    TP_ul=6

Check Throughput for TTF
    Send Throughput    ue_id=1    pdu=1    qfi=1    times=7    mbps=25
    Send Throughput    ue_id=1    pdu=2    qfi=2    times=7    mbps=25
    Wait Until Keyword Succeeds    60s    10s    Check Throughput for pcell    ue_id=1    pcell_dl=175
    Wait Until Keyword Succeeds    60s    10s    Check Throughput for scell1    ue_id=1    scell1_dl=0
    Wait Until Keyword Succeeds    60s    10s    Check Throughput for scell2    ue_id=1    scell2_dl=0
    Send Throughput    ue_id=1    pdu=1    qfi=1    times=7    mbps=150
    Wait Until Keyword Succeeds    60s    10s    Check Throughput for pcell    ue_id=1    pcell_dl=175
    Wait Until Keyword Succeeds    60s    10s    Check Throughput for scell1    ue_id=1    scell1_dl=200
    Wait Until Keyword Succeeds    60s    10s    Check Throughput for scell2    ue_id=1    scell2_dl=50
    Wait Until Keyword Succeeds    60s    10s    Check Throughput for UL    ue_id=1    pdu=1    qfi=1    TP_ul=6
    Wait Until Keyword Succeeds    60s    10s    Check Throughput for UL    ue_id=1    pdu=2    qfi=2    TP_ul=6

Ue register and pdu session setup and scelladded
    [Arguments]    ${ue_id}=1    ${gateway}=1    ${enb_id}=2    ${cell_id}=2    ${cmd_regexp}=UE now in NG RM Registere
    ...    ${scell1pci}=50    ${scell2pci}=51    ${cmd_pdu_regexp}=scellIdx:2
    Execute Egate Command    ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    ${cmd_regexp}
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${gateway}    ${cmd_pdu_regexp}
    Rrc Should Contain    sCellToAddModList    physCellId ${scell1pci}    physCellId ${scell2pci}
    PDU2 session setup    ue_id=${ue_id}

Ue register and pdu session setup
    [Arguments]    ${ue_id}=1    ${gateway}=1    ${enb_id}=2    ${cell_id}=2    ${cmd_regexp}=UE now in NG RM Registere
    ...    ${cmd_pdu_regexp}=QoS Routing Table
    Execute Egate Command    ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    ${cmd_regexp}
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${gateway}    ${cmd_pdu_regexp}
    PDU2 session setup    ue_id=${ue_id}

Check Throughput for case10 TTF
    Wait Until Keyword Succeeds    60s    10s    Check Throughput for pcell    ue_id=1    pcell_dl=175
    Wait Until Keyword Succeeds    60s    10s    Check Throughput for scell1    ue_id=1    scell1_dl=200
    Wait Until Keyword Succeeds    60s    10s    Check Throughput for scell2    ue_id=1    scell2_dl=50

Check Throughput for case10 TFF
    Wait Until Keyword Succeeds    60s    10s    Check Throughput for pcell    ue_id=1    pcell_dl=175
    Wait Until Keyword Succeeds    60s    10s    Check Throughput for scell1    ue_id=1    scell1_dl=50
    Wait Until Keyword Succeeds    60s    10s    Check Throughput for scell2    ue_id=1    scell2_dl=50

Sa Ue Attach
    [Arguments]    ${ue_id}=2    ${gateway}=1    ${enb_id}=2    ${cell_id}=1    ${pass_regexp}=NG RM Register
    Execute Egate Command    ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    ${pass_regexp}
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${gateway}    QoS Routing Table
    Send Throughput    ue_id=${ue_id}    pdu=1    qfi=1    times=7    mbps=50
    Wait Until Keyword Succeeds    60s    10s    Check Throughput for pcell    ue_id=${ue_id}    pcell_dl=175

Pdu session setup for GC010
    [Arguments]    ${ue_id}=1    ${gateway}=2    ${pdu}=2    ${qosflows}=3
    Execute Egate Command    qosflow_modify qos_flow=2 default=on
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu} nwslice=1 gw=${gateway}    pass_regexp=QoS Routing Table
    Wait Until Keyword Succeeds    120s    10s    Check Throughput for pcell    ue_id=1    pcell_dl=175
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu} qosflows_to_add=${qosflows} by=amf    pass_regexp=QoS Routing Table
    Wait Until Keyword Succeeds    120s    10s    Check Throughput for pcell    ue_id=1    pcell_dl=175

Ue register and pdu session setup for GC010
    Sa Ue Attach     ue_id=1    enb_id=2    cell_id=1
    Send Throughput    ue_id=1    pdu=1    qfi=1    times=7    mbps=100
    Pdu session setup for GC010

Check Throughput for case016 FTT
    Send Throughput    ue_id=1    pdu=1    qfi=1    times=7    mbps=100
    Wait Until Keyword Succeeds    60s    10s    Check Throughput for pcell    ue_id=1    pcell_dl=50
    Wait Until Keyword Succeeds    60s    10s    Check Throughput for scell1    ue_id=1    scell1_dl=200
    Wait Until Keyword Succeeds    60s    10s    Check Throughput for scell2    ue_id=1    scell2_dl=200
    Wait Until Keyword Succeeds    60s    10s    Check Throughput for UL    ue_id=1    pdu=1    qfi=1    TP_ul=6

