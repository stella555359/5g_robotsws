*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    CRT    CLOUD_5G_I_[LO][LO]_AP_[LOO]_SANSA_FS_ECPRI_CMWV_TDD
...    owner-jing.ye    release-SBTS23R3    team-ROCK
Resource    ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
${NOKIA_XNAP_PLUGIN_FLAG}    ${True}
${NOKIA_F1AP_PLUGIN_FLAG}    ${True}

@{PARAMS_IN_SCF}
...    @{PARAMS_FOR_CA}
...    @{PARAMS_FOR_GNB1}
...    @{PARAMS_ADJ_REL_FOR_GNB1}
...    @{PARAMS_FOR_OTHERS}
...    @{GNB1_8290_Enable}

@{PARAMS_IN_SCF_GNB2}
...    @{PARAMS_FOR_CA}
...    @{PARAMS_FOR_GNB2}
...    @{PARAMS_ADJ_REL_FOR_GNB2}
...    @{PARAMS_FOR_OTHERS}
...    @{GNB2_8290_Enable}

@{PARAMS_FOR_CA}
...    NRBTS:actCarrierAggregation=true
...    NRBTS:sCellActivationMethod=bufferBased
...    NRBTS:caConfigurationSupport=4CCDL_2CCUL
...    NRBTS:weightForIgnbCaSelection=100
...    NRCELL:weightForSCellSelection=10
...    NRBTS:actIncXn=true
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:carrierAggregationSupportList=ca_Fdd_Fdd,ca_Fdd_Fr1Tdd_Sa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fdd_Any_Sa,ca_Fr1Tdd_Any_Sa
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRDU-1:actInterGnbCa=DLOnly
...    NRDU-1:xgUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRCELL:actK1Opt=intraAndInter-gNB
...    NRCELL:maxNumScellsDlFr1=3

@{PARAMS_FOR_GNB1}
...    NRBTS:iGnbCaXnCfUpBackOffTmr=60
...    NRBTS:iGnbCaXnSetupReqTmr=60
...    NRBTS:iGnbCaXnSetupRespTmr=60
...    NRBTS:intGnbScellTempBlockTmr=60

@{PARAMS_ADJ_REL_FOR_GNB1}
...    NRBTS/NRADJGNB-2:administrativeState=Unlocked
...    NRBTS/NRADJGNB-2:gNbIdLength=22
...    NRBTS/NRADJGNB-2:gNodeBId=2
...    NRBTS/NRADJGNB-2:weightForIgnbCaSelection=10
...    NRBTS/NRADJGNB-2:xnLinkRef=1
...    NRBTS/NRADJGNB-2:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-2:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-2:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-3:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-3:fiveGsTac=200
...    NRBTS/NRADJNRCELL-3:gNbId=2
...    NRBTS/NRADJNRCELL-3:gNbIdLength=22
...    NRBTS/NRADJNRCELL-3:lcrId=3
...    NRBTS/NRADJNRCELL-3:nrarfcn=648000
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
...    NRBTS/NRADJNRCELL-12:physCellId=61
...    NRBTS/NRADJNRCELL-12:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-12:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-12:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-12:freqBandIndicatorNR=28
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
...    NRCELL-1/NRREL-3:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-11:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-11:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-11:gNbId=2
...    NRCELL-1/NRREL-11:gNbIdLength=22
...    NRCELL-1/NRREL-11:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-11:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-11:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-11:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-11:removeNotAllowed=false
...    NRCELL-1/NRREL-11:lcrId=11
...    NRCELL-1/NRREL-11:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-11:sCellOperationalMode=dlOnly
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
...    NRCELL-1/NRREL-12:sCellOperationalMode=dlOnly
...    NRCELL:a1MeasSCellAddEnabled=rsrp
...    NRCELL:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=90|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=70|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a2MeasSCellRelEnabled=rsrp
...    NRCELL:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=480ms
...    NRCELL:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=40|a2TimeToTriggerSCellRelSsbRsrp=480ms

@{PARAMS_FOR_GNB2}
...    NRBTS:iGnbCaXnCfUpBackOffTmr=60
...    NRBTS:iGnbCaXnSetupReqTmr=90
...    NRBTS:iGnbCaXnSetupRespTmr=60
...    NRBTS:intGnbScellTempBlockTmr=60
...    NRCELL:sCellDeactivationTimerGNB=ms320

@{PARAMS_ADJ_REL_FOR_GNB2}
...    NRCELL:a1MeasSCellAddEnabled=rsrp
...    NRCELL:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=90|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=70|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a2MeasSCellRelEnabled=rsrp
...    NRCELL:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=480ms
...    NRCELL:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=40|a2TimeToTriggerSCellRelSsbRsrp=480ms
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
...    NRBTS/NRADJNRCELL-1:freqBandIndicatorNR=77
...    NRBTS/NRADJNRCELL-2:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-2:fiveGsTac=200
...    NRBTS/NRADJNRCELL-2:gNbId=1
...    NRBTS/NRADJNRCELL-2:gNbIdLength=22
...    NRBTS/NRADJNRCELL-2:lcrId=2
...    NRBTS/NRADJNRCELL-2:nrarfcn=648000
...    NRBTS/NRADJNRCELL-2:physCellId=51
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-2:freqBandIndicatorNR=77
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
...    NRCELL-12/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-2:gNbId=1
...    NRCELL-12/NRREL-2:gNbIdLength=22
...    NRCELL-12/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-12/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-2:lcrId=2
...    NRCELL-12/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-12/NRREL-2:sCellPrio=1
...    NRCELL-12/NRREL-11:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-11:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-11:gNbId=2
...    NRCELL-12/NRREL-11:gNbIdLength=22
...    NRCELL-12/NRREL-11:handoverAllowedSA=allowed
...    NRCELL-12/NRREL-11:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-11:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-11:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-11:removeNotAllowed=false
...    NRCELL-12/NRREL-11:lcrId=11
...    NRCELL-12/NRREL-11:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-11:sCellOperationalMode=dlOnly
...    NRCELL-12/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-3:gNbId=2
...    NRCELL-12/NRREL-3:gNbIdLength=22
...    NRCELL-12/NRREL-3:handoverAllowedSA=allowed
...    NRCELL-12/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-3:removeNotAllowed=false
...    NRCELL-12/NRREL-3:lcrId=3
...    NRCELL-12/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-3:sCellOperationalMode=dlOnly
...    NRCELL-12/NRREL-3:sCellPrio=2
...    NRCELL-12/NRREL-4:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-4:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-4:gNbId=2
...    NRCELL-12/NRREL-4:gNbIdLength=22
...    NRCELL-12/NRREL-4:handoverAllowedSA=allowed
...    NRCELL-12/NRREL-4:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-4:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-4:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-4:removeNotAllowed=false
...    NRCELL-12/NRREL-4:lcrId=4
...    NRCELL-12/NRREL-4:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-4:sCellOperationalMode=dlOnly
...    NRCELL-12/NRREL-4:sCellPrio=2

@{PARAMS_FOR_OTHERS}


...    NRBTS:actRanSharing=false
...    NRCELL:actCDrx=false
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS:cipherPrefL:nea0=8
...    NRBTS:cipherPrefL:nea1_128=0
...    NRBTS:cipherPrefL:nea2_128=0
...    NRBTS:cipherPrefL:nea3_128=0

@{GNB1_8290_Enable}
...    NRBTS:actSCellSwapFr1=a6BasedSa
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRCELL:a6MeasSCellSwapEnabled=rsrp
...    NRCELL:a6MeasSCellSwapSsbRsrp:a6HysteresisSCellSwapSsbRsrp=0|a6OffsetSCellSwapSsbRsrp=20|a6TimeToTrigSCellSwapSsbRsrp=ms480
...    NRCELL:a6MeasSCellSwapSsbRsrq:a6HysteresisSCellSwapSsbRsrq=0|a6OffsetSCellSwapSsbRsrq=20|a6TimeToTrigSCellSwapSsbRsrq=ms480
...    NRCELL:reportAmountA6MeasSCellSwap=r4
...    NRCELL:reportIntervalA6MeasSCellSwap=ms120
...    NRCELL:thresholdSCellSwapSourceRsrp=66
...    NRCELL:thresholdSCellSwapSourceRsrq=67
...    NRCELL-1:chBw=40MHz
...    NRCELL-2:nrarfcn=648000
...    NRCELL-2:gscnOrSsPbchArfcn=8000

@{GNB2_8290_Enable}
...    NRBTS:actSCellSwapFr1=a6BasedSa
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRCELL:a6MeasSCellSwapEnabled=rsrp
...    NRCELL:a6MeasSCellSwapSsbRsrp:a6HysteresisSCellSwapSsbRsrp=0|a6OffsetSCellSwapSsbRsrp=20|a6TimeToTrigSCellSwapSsbRsrp=ms480
...    NRCELL:a6MeasSCellSwapSsbRsrq:a6HysteresisSCellSwapSsbRsrq=0|a6OffsetSCellSwapSsbRsrq=20|a6TimeToTrigSCellSwapSsbRsrq=ms480
...    NRCELL:reportAmountA6MeasSCellSwap=r4
...    NRCELL:reportIntervalA6MeasSCellSwap=ms120
...    NRCELL:thresholdSCellSwapSourceRsrp=66
...    NRCELL:thresholdSCellSwapSourceRsrq=67
...    NRCELL-3:chBw=40MHz
...    NRCELL-3:nrarfcn=648000
...    NRCELL-3:gscnOrSsPbchArfcn=8000
...    NRCELL-12:cellDepType=SA
...    delete:NRCELL-12:configuredEpsTac

@{Online_Change_CELL3}
...    NRCELL-3:maxNumOfSCellAlloc=0

@{Online_Change_CELL3_Recover}
...    NRCELL-3:maxNumOfSCellAlloc=250

@{Expectpcell_cell12}
...    pcid:61
...    QoS Routing Table
...    eventId eventA1

@{Expectca_UE_First_Time}
...    physCellId 52
...    physCellId 60
...    SCellIndex 1 activated successfully
...    SCellIndex 2 activated successfully
...    eventId eventA6
...    eventId eventA2

@{Expectca_UE_Second_Time}
...    physCellId 53
...    physCellId 60
...    SCellIndex 1 activated successfully
...    SCellIndex 2 activated successfully
...    eventId eventA6
...    eventId eventA2

@{Expectpcell_cell1}
...    pcid:50
...    QoS Routing Table
...    eventId eventA1

@{Expectca_UE2}
...    physCellId 52
...    physCellId 60
...    physCellId 61
...    SCellIndex 1 activated successfully
...    SCellIndex 2 activated successfully
...    SCellIndex 3 activated successfully
...    eventId eventA2

@{A6_Configured}
...    eventId eventA6

${RRC_RECONF_ADD2DLSCELL_ATT_SA}    M55118C07004
#When an RRC reconfiguration message with the addition of exactly 2 SCells in DL is triggered in SA mode, this counter is updated at PCell.

${RRC_RECONF_ADD2DLSCELL_SUCC_SA}    M55118C07003
#When an RRC reconfiguration complete message following RRC reconfiguration with the addition of exactly 2 SCells in DL is received in SA mode,
# this counter is updated at PCell.

${GNB_DU_SCELL_2_ADMI_REQ_SA}    M55139C01501
#This counter indicates the number of radio admission requests for exactly 2 SCells before the CA configuration on RRC.
#It's measured in PCell in SA mode in DU only.

${GNB_DU_SCELL_2_ADMI_SUCC_SA}    M55139C01502
#This counter indicates the number of successful radio admission requests for exactly 2 SCells before the CA configuration on RRC.
#It's measured in PCell in SA mode in DU only.

${GNB_DU_SCELL_1_ADMI_REQ_SA}    M55139C01003
#The total number of radio admission requests for 1 S-Cell in addition of P-Cell in SA mode. 
#Updated to the P-Cell whenever there is an admission request for the UE in SA mode.

${GNB_DU_SCELL_1_ADMI_SUCC_SA}    M55139C01004
#This counter indicates the number of successful radio admission requests for exactly 1 SCell before the CA configuration on RRC.
#It's measured in PCell in SA mode in DU only.

${UE_PCELL_2_CONF_SCELL_DL_SA}    M55118C07001
#This counter indicates the sum of samples for the total number of CA UEs in the current cell configured as a PCell with 2 configured SCells 
#in DL in SA mode.

${SCELL_SWAP_1_ATT_SA}    M55118C10501
#The total number of SCell swap attempts for 1 SCell in the PCell for SA mode.

${SCELL_SWAP_1_SUCC_SA}    M55118C10502
#The total number of successful SCell swap attempts for 1 SCell in the PCell for SA mode.

${UE_SCELL_2_CONF_SCELL_DL_SA}    M55118C07002
#This counter indicates the sum of samples for the total number of CA UEs in the current cell configured as an SCell with 2 configured SCells 
#in DL in SA mode. The counter is pegged in the secondary cell.

${GNB_DU_SCELL_ADMI_REQ_SA}    M55139C01001
#This counter indicates the total number of radio admission requests for SCell before the CA configuration on RRC.
#It's measured in SCell in SA mode in DU only.

${GNB_DU_SCELL_ADMI_SUCC_SA}    M55139C01002
#This counter describes the total number of successful radio admission requests for SCell before the CA configuration on RRC.
#It is measured in SCell in SA mode in DU only.

*** Test Cases ***
CB008140-ET-HB02_Verify A6 scell swap failed and success with same gNB scell
    [Documentation]
    ...    The purpose of this test case is to verify when the UE reports a candidate SCell belonging to a different gNB than 
    ...    the configured SCell to swap, A6 will be ignored. when the UE reports a candidate SCell belonging to the same gNB
    ...    of the configured SCell to swap, scell swap will be triggered and success.
    ...    [GNB-1 Configuration]:
    ...    Cell id=1 gnb=1 pci=16:2 tac=200 tdd_cell=on band=n77 nr_arfcn=663400:663400 gscn=8159 chBw=40MHz
    ...    Cell id=2 gnb=1 pci=17:0 tac=200 tdd_cell=on band=n77 nr_arfcn=648000:648000 gscn=8000 chBw=40MHz
    ...    [GNB-2 Configuration]:
    ...    Cell id=3 gnb=2 pci=17:1 tac=200 tdd_cell=on band=n77 nr_arfcn=648000:648000 gscn=8000 chBw=40MHz
    ...    cell id=4 gnb=2 pci=17:2 tac=200 tdd_cell=on band=n77 nr_arfcn=648000:648000 gscn=8000 chBw=40MHz
    ...    Cell id=11 gnb=2 pci=20:0 tac=200 tdd_cell=off band=n3 nr_arfcn=349400:368400 gscn=4605 chBw=10MHz
    ...    Cell id=12 gnb=2 pci=20:0 tac=200 tdd_cell=off band=n28 nr_arfcn=143400:153400 gscn=1916 chBw=15MHz
    ...    cell1_1/cell1_2/cell2_3/cell2_4/cell2_11 has been configured as candidate SCell of Cell2_12.
    ...    cell2_3/cell2_11/cell2_12 has been configured as candidate SCell of Cell1_1.
    ...    2.Test Case Steps:
    ...         a. UE1 Attach to cell2_12 First Time And Scell Swap Should Work Fine.
    ...             a_1: initial CA cell2_12_cell2_11_cell2_3
    ...             a_2: swap to cell1_2 failed
    ...             a_3: after first swap CA cell2_12_cell2_11_cell2_4
    ...             a_4: after second swap CA cell2_12_cell2_11_cell2_3
    ...         b. UE1 Attach to cell2_12 Second Time And Scell Swap Should Work Fine.
    ...             b_1: initial CA cell2_12_cell2_11_cell2_4
    ...             b_2: after first swap CA cell2_12_cell2_11_cell2_3
    ...             b_3: after second swap CA cell2_12_cell2_11_cell2_4
    ...         c. UE1 attach to cell2_12 and trigger A1 scell addition should be Successful After Online Change CELL3.
    ...             c_1: initial CA cell2_12_cell2_11_cell2_4
    ...         d. UE2 Attach to cell1_1 and trigger A1 scell addition should be Successful After Recover Cell3.
    ...             e_1: initial CA cell1_1_cell2_11_cell2_12_cell2_3
    [Tags]    QC_277547    CA_LABEL-FFT (15MHz_FDD_n28+ 10MHz_FDD_n3+ 40MHz_TDD_n77)    
    ...    CA_LABEL-TFFT (40MHz_TDD_n77+ 15MHz_FDD_n28+ 10MHz_FDD_n3+ 40MHz_TDD_n77)
    UE1 Attach to cell2_12 First Time And Scell Swap Should Work Fine
    UE1 Attach to cell2_12 Second Time And Scell Swap Should Work Fine
    UE1 attach to cell2_12 and trigger A1 scell addition should be Successful After Online Change CELL3
    UE2 Attach to cell1_1 and trigger A1 scell addition should be Successful After Recover Cell3 	

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup 2Airphone Env    fddtdd_sansa_cmwv/6cells_gnb1_2T_gnb2_2T2F

UE1 Attach to cell2_12 First Time And Scell Swap Should Work Fine
    Clear Counter Files gnb2
    UE attach to cell2_12 and trigger A1 scell addition should be Successful    expectca_UE=${Expectca_UE_First_Time}
    Trigger A6 Scell Swap to cell1_2 Should Be Failure
    Trigger A6 Scell Swap Should Be Successful    ue_id=1    phycell_id=53    scell_id=1    scell_id_after_swap=3
    Trigger A6 Scell Swap Should Be Successful    ue_id=1    phycell_id=52    scell_id=3    scell_id_after_swap=1
    Release UEs    ue_type=all
    Check Counters in GNB2

UE1 Attach to cell2_12 Second Time And Scell Swap Should Work Fine
    UE attach to cell2_12 and trigger A1 scell addition should be Successful    expectca_UE=${Expectca_UE_Second_Time}
    Trigger A6 Scell Swap Should Be Successful    ue_id=1    phycell_id=52    scell_id=1    scell_id_after_swap=3
    Trigger A6 Scell Swap Should Be Successful    ue_id=1    phycell_id=53    scell_id=3    scell_id_after_swap=1
    Release UEs    ue_type=all
	
UE1 attach to cell2_12 and trigger A1 scell addition should be Successful After Online Change Cell3
    Delta Commission Parameters GNB2    ${Online_Change_CELL3}
    wait until keyword succeeds    2min    30sec    Cells Should Be OnAir GNB2    3
    UE attach to cell2_12 and trigger A1 scell addition should be Successful    expectca_UE=${Expectca_UE_Second_Time}    ue_id=1
	
UE2 Attach to cell1_1 and trigger A1 scell addition should be Successful After Recover Cell3 	
    Delta Commission Parameters GNB2    ${Online_Change_CELL3_Recover}
    wait until keyword succeeds    2min    30sec    Cells Should Be OnAir GNB2
    UE2 Attach to cell1_1 and trigger A1 scell addition should be Successful    expectca_UE=${Expectca_UE2}

UE attach to cell2_12 and trigger A1 scell addition should be Successful
    [Arguments]    ${expectca_UE}    ${ue_id}=1
    Ue Register And PDU Session Setup    ${Expectpcell_cell12}    ${ue_id}    3    12  
    Send Throughput    ue_id=${ue_id}
    Wait Until Keyword Succeeds    60s    10s    Verify Throuput on Pscell    ue_id=${ue_id}
    Trigger A1MR    ${expectca_UE}    153370    100    100    ue_id=${ue_id}
    Wait Until Keyword Succeeds    60s    10s    Verify Throughput 3CC on Pscell and Scell    ue_id=${ue_id}

UE2 Attach to cell1_1 and trigger A1 scell addition should be Successful
    [Arguments]    ${expectca_UE}    ${ue_id}=3
    Ue Register And PDU Session Setup    ${Expectpcell_cell1}    ${ue_id}    2    1 
    Send Throughput    ue_id=${ue_id}    times=3
    Wait Until Keyword Succeeds    60s    10s    Verify Throuput on Pscell    ue_id=${ue_id}    pcell_dl=180
    Trigger A1MR Without A6 Configured    ${expectca_UE}    663360    100    100    ue_id=${ue_id}
    Wait Until Keyword Succeeds    60s    10s    Verify Throughput 4CC on Pscell and Scell    ue_id=${ue_id}
    Release UEs    ue_type=all
	
Trigger A6 Scell Swap to cell1_2 Should Be Failure
    Trigger ScellSwap Failed    carrierfreq=648096    phycell_id=51
    Verify Throughput 3CC on Pscell and Scell

Trigger A6 Scell Swap Should Be Successful
    [Arguments]    ${ue_id}    ${phycell_id}    ${scell_id}    ${scell_id_after_swap}    ${carrierfreq}=648096    
    Trigger ScellSwap    ${ue_id}    ${carrierfreq}    ${phycell_id}    ${scell_id}    ${scell_id_after_swap}
    Wait Until Keyword Succeeds    60s    5s    Verify Throughput 3CC on Pscell and Scell    ${scell_id_after_swap}

Trigger ScellSwap Failed 
    [Arguments]    ${event_type}=A6    ${carrierfreq}=648096    ${nrsrp_nr}=30    ${nrsrq_nr}=30    ${ue_id}=1    ${scell_id}=1
    ...    ${phycell_id}=53
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type}
    ...    srsrp_nr=11 srsrq_nr=11 scell=${scell_id} scell_rsrp=20 scell_rsrq=20 phycell_id=${phycell_id} nrsrp_nr=${nrsrp_nr} nrsrq_nr=${nrsrq_nr}
    Execute Egate Command    ${cmd}    fail_regexp=rrcReconfigurationComplete
	
Trigger ScellSwap
    [Arguments]    ${ue_id}=1    ${carrierfreq}=648096    ${phycell_id}=53    ${scell_id}=1    ${scell_id_after_swap}=53
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}    event_type=A6    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A6
    ...    srsrp_nr=11 srsrq_nr=11 scell=${scell_id} scell_rsrp=20 scell_rsrq=20 phycell_id=${phycell_id} nrsrp_nr=30 nrsrq_nr=30
    Execute Egate Command    ${cmd}    pass_regexp=PhysCellId: ${phycell_id}] SCellIndex ${scell_id_after_swap} activated successfully at airphone

Trigger A1MR
    [Arguments]    ${expectca}    ${carrierfreq}=663360    ${srsrp_nr}=100    ${srsrq_nr}=50    ${ue_id}=1
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}    event_type=A1    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=${srsrp_nr} srsrq_nr=${srsrq_nr}
    Execute Egate Command    ${cmd}    pass_regexp=${expectca}
	
Trigger A1MR Without A6 Configured
    [Arguments]    ${expectca}    ${carrierfreq}=663360    ${srsrp_nr}=100    ${srsrq_nr}=50    ${ue_id}=1
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}    event_type=A1    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=${srsrp_nr} srsrq_nr=${srsrq_nr}
    Execute Egate Command    ${cmd}    pass_regexp=${expectca}    fail_regexp=${A6_Configured}

Update UE capa
    [Arguments]    ${ue_id}    ${SA_Capa}    
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa}
    Execute Egate Command    ${cmd}
	
Ue Register And PDU Session Setup
    [Arguments]    ${expectpcell}    ${ue_id}=1    ${enb_id}=2    ${cell_id}=1
    Update UE capa    ${ue_id}    ${CB008140_GG_Capa_2CC_3CC_4CC_n3_n28_n77_n78}
    Execute Egate Command    ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${ue_id}    pass_regexp=${expectpcell} 

Send Throughput
    [Arguments]    ${ue_id}=1    ${times}=2    ${dl_mbps}=150
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=ul mbps=50 trf_id=1    UE ${ue_id}: UDP UL
    ${times}     Evaluate    ${times}+2
    FOR    ${i}    IN RANGE    2    ${times}
        Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=${dl_mbps} trf_id=${i}    UE ${ue_id}: UDP DL
    END

Verify 3CC DL throughput
    [Arguments]    ${scell_id}=1    ${ue_id}=1    ${total_tput}=800
    ${pcell_dl}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${pcell_dl}/1000 > 0
    ${total_dl}    Set Variable    ${pcell_dl}
    ${scell1_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${scell_id}    type=pdsch    rate_type=ave
    Should Be True    ${scell1_tput}/1000 > 0
    ${total_dl}    Evaluate    ${scell1_tput}+${total_dl}
    ${scell2_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=2    type=pdsch    rate_type=ave
    Should Be True    ${scell2_tput}/1000 > 0
    ${total_dl}    Evaluate    ${scell2_tput}+${total_dl}
    Should Be True    ${total_dl}/1000>${total_tput}
	
Verify Throuput on Pscell
    [Arguments]    ${ue_id}=1    ${pcell_dl}=90    ${ul}=9  
    ${pcell_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${pcell_tput}/1000 > ${pcell_dl}
    ${ul_throughput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pusch    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul}
	
Verify Throughput 3CC on Pscell and Scell
    [Arguments]    ${scell_id}=1    ${ue_id}=1    ${total_dl_tput}=270    ${ul_tput}=9
    Verify 3CC DL throughput    ${scell_id}    ${ue_id}    ${total_dl_tput}
    ${ul_throughput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pusch    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul_tput}
	
Verify Throughput 4CC on Pscell and Scell
    [Arguments]    ${ue_id}=3    ${total_dl_tput}=400    ${ul_tput}=9
    Verify 4CC DL throughput    ${ue_id}    ${total_dl_tput}
    ${ul_throughput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pusch    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul_tput}
	
Verify 4CC DL throughput
    [Arguments]    ${ue_id}=3    ${total_tput}=800
    ${pcell_dl}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${pcell_dl}/1000 > 0
    ${total_dl}    Set Variable    ${pcell_dl}
    Get Scell Throughput    ue_id=${ue_id}
    ${total_dl}    Evaluate    ${total_dl}+${total_scell_dl}	
    Should Be True    ${total_dl}/1000>${total_tput}

Get Scell Throughput
    [Arguments]    ${ue_id}=3
    ${scell1_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=1    type=pdsch    rate_type=ave
    Should Be True    ${scell1_tput}/1000 > 0
    ${total_scell_dl}    Set Variable    ${scell1_tput}
    ${scell2_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=2    type=pdsch    rate_type=ave
    Should Be True    ${scell2_tput}/1000 > 0
    ${total_scell_dl}    Evaluate    ${scell2_tput}+${total_scell_dl}
    ${scell3_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=3    type=pdsch    rate_type=ave
    Should Be True    ${scell3_tput}/1000 > 0
    ${total_scell_dl}    Evaluate    ${scell3_tput}+${total_scell_dl}
    Set Test Variable    ${total_scell_dl}

Check Counters in GNB2
    ${pm_counters}    Create List    
    ...    NRCELL-12:${RRC_RECONF_ADD2DLSCELL_ATT_SA}=1
    ...    NRCELL-12:${RRC_RECONF_ADD2DLSCELL_SUCC_SA}=1
    ...    NRCELL-12:${GNB_DU_SCELL_2_ADMI_REQ_SA}=1
    ...    NRCELL-12:${GNB_DU_SCELL_2_ADMI_SUCC_SA}=1
    ...    NRCELL-12:${GNB_DU_SCELL_1_ADMI_REQ_SA}=2
    ...    NRCELL-12:${GNB_DU_SCELL_1_ADMI_SUCC_SA}=2
    ...    NRCELL-12:${UE_PCELL_2_CONF_SCELL_DL_SA}>1
    ...    NRCELL-12:${SCELL_SWAP_1_ATT_SA}=2
    ...    NRCELL-12:${SCELL_SWAP_1_SUCC_SA}=2
    ...    NRCELL-3:${UE_SCELL_2_CONF_SCELL_DL_SA}>1
    ...    NRCELL-3:${GNB_DU_SCELL_ADMI_REQ_SA}=2
    ...    NRCELL-3:${GNB_DU_SCELL_ADMI_SUCC_SA}=2
    ...    NRCELL-4:${UE_SCELL_2_CONF_SCELL_DL_SA}>1
    ...    NRCELL-4:${GNB_DU_SCELL_ADMI_REQ_SA}=1
    ...    NRCELL-4:${GNB_DU_SCELL_ADMI_SUCC_SA}=1
    ...    NRCELL-11:${UE_SCELL_2_CONF_SCELL_DL_SA}>1
    ...    NRCELL-11:${GNB_DU_SCELL_ADMI_REQ_SA}=1
    ...    NRCELL-11:${GNB_DU_SCELL_ADMI_SUCC_SA}=1
    Check Counters GNB2    ${pm_counters}    wait=true
