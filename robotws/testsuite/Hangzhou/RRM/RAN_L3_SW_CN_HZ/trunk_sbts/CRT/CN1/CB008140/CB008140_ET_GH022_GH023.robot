*** Settings ***
Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    RAN_5G    RAN_5G_FDD    SBTS00    CRT    CAL09692    CLOUD_5G_I_[LO][LO]_AP_[LOO]
...            owner-ha.zheng    team-SGT&A    release-SBTS23R3
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${NOKIA_XNAP_PLUGIN_FLAG}    ${True}
${NOKIA_F1AP_PLUGIN_FLAG}    ${True}

@{PARAMS_IN_SCF}
...    @{PARAMS_FOR_CA}
...    @{PARAMS_FOR_GNB1}
...    @{PARAMS_ADJ_REL_FOR_GNB1}
...    @{PARAMS_FOR_OTHERS}
...    @{ANR_gnb}

@{PARAMS_IN_SCF_GNB2}
...    @{PARAMS_FOR_CA}
...    @{PARAMS_FOR_GNB2}
...    @{PARAMS_ADJ_REL_FOR_GNB2}
...    @{PARAMS_FOR_OTHERS}
...    @{gscn_Arfcn}
...    @{ANR_gnb}

@{PARAMS_FOR_CA}
...    NRBTS:actCarrierAggregation=true
...    NRBTS:sCellActivationMethod=blind
...    NRBTS:caConfigurationSupport=4CCDL_2CCUL
...    NRBTS:weightForIgnbCaSelection=20
...    NRBTS:actIncXn=true
...    NRBTS:maxNumScellsDl=2
...    NRBTS:maxNumScellsUl=2
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:carrierAggregationSupportList=ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Sa,ca_Fdd_Any_Sa,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Fdd
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRDU-1:dlToUlContributionRatio=101
...    NRCELL:actK1Opt=intraAndInter-gNB
...    NRDU-1:xgUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRDU-1:actInterGnbCa=DLOnly

@{PARAMS_FOR_GNB1}
...    NRCELL:sCellDeactivationTimerGNB=infinity
...    NRCELL:nrCellType=2DL2UL
...    NRCELL:maxNumScellsDlFr1=3
...    NRCELL:dlMimoMode=2x2 Open Loop Spatial Multiplexing
...    NRCELL:actCDrx=true
...    NRPMRNL-1:miNrInterGnbMobilityNsaPmqap=disabled
...    NRPMRNL-1:miNrInterGnbNgMobilitySaPmqap=disabled
...    NRPMRNL-1:miNrInterGnbXnMobilitySaPmqap=disabled
...    NRPMRNL-1:miNrIntraGnbMobilityNsaPmqap=disabled
...    NRPMRNL-1:miNrIntraGnbMobilitySaPmqap=disabled
...    NRCELL-11:a5MeasEnabled=rsrpCombined
...    NRCELL-11:a5MeasSsbRsrp:a5HysteresisSsbRsrp=0
...    NRCELL-11:a5MeasSsbRsrp:a5Threshold1SsbRsrp=20
...    NRCELL-11:a5MeasSsbRsrp:a5Threshold2SsbRsrp=40
...    NRCELL-11:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms40
...    NRCELL-11:a5MeasSsbRsrq:a5HysteresisSsbRsrq=0
...    NRCELL-11:a5MeasSsbRsrq:a5Threshold1SsbRsrq=50
...    NRCELL-11:a5MeasSsbRsrq:a5Threshold2SsbRsrq=70
...    NRCELL-11:a5MeasSsbRsrq:a5TimeToTriggerSsbRsrq=ms40
...    NRCELL-11:drxProfileNrAnr:drxControl=intraNRSAintraFreq
...    NRCELL-11:drxProfileNrAnr:drxInactivityTimer=80ms
...    NRCELL-11:drxProfileNrAnr:drxLongCycle=320ms
...    NRCELL-11:drxProfileNrAnr:drxOnDurationTimer=20ms
...    NRCELL-11:drxProfileNrAnr:drxRetransTimerDl=0slot
...    NRCELL-11:drxProfileNrAnr:drxRetransTimerUl=0slot
...    NRCELL-12:a1MeashoEnabledSA=rsrp
...    NRCELL-12:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=10
...    NRCELL-12:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=60
...    NRCELL-12:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL-12:a2MeashoEnabledSA=rsrp
...    NRCELL-12:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0
...    NRCELL-12:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=34
...    NRCELL-12:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL-12/NRHOIF-1:cellDepType=SA
...    NRCELL-12/NRHOIF-1:freqBandIndicatorNR=3
...    NRCELL-12/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-12/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-12/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-12/NRHOIF-1:ssbFrequency=363850
...    NRCELL-12/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-12/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-12/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=30
...    NRCELL-12/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms64
...    NRCELL-12/NRHOIF-1:a5MeasEnabled=rsrp
...    NRCELL-12/NRHOIF-1:a5MeasSsbRsrp:a5HysteresisSsbRsrp=0
...    NRCELL-12/NRHOIF-1:a5MeasSsbRsrp:a5Threshold1SsbRsrp=30
...    NRCELL-12/NRHOIF-1:a5MeasSsbRsrp:a5Threshold2SsbRsrp=40
...    NRCELL-12/NRHOIF-1:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms64
...    NRCELL-12:measGapSelectionSA=favourUeThroughput
...    NRCELL-12:drxProfileNrAnr:drxControl=intraNRSAinterFreq
...    NRCELL-12:drxProfileNrAnr:drxInactivityTimer=80ms
...    NRCELL-12:drxProfileNrAnr:drxLongCycle=320ms
...    NRCELL-12:drxProfileNrAnr:drxOnDurationTimer=20ms
...    NRCELL-12:drxProfileNrAnr:drxRetransTimerDl=0slot
...    NRCELL-12:drxProfileNrAnr:drxRetransTimerUl=0slot

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
...    NRBTS/NRADJNRCELL-1:freqBandIndicatorNR=77
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
...    NRBTS/NRADJNRCELL-2:freqBandIndicatorNR=77
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
...    NRBTS/NRADJNRCELL-14:freqBandIndicatorNR=28
...    NRCELL/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL/NRREL-1:gNbId=2
...    NRCELL/NRREL-1:gNbIdLength=22
...    NRCELL/NRREL-1:handoverAllowedSA=allowed
...    NRCELL/NRREL-1:lcrId=1
...    NRCELL/NRREL-1:removeNotAllowed=false
...    NRCELL/NRREL-1:gnbPlmn:mcc=311
...    NRCELL/NRREL-1:gnbPlmn:mnc=489
...    NRCELL/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL/NRREL-2:gNbId=2
...    NRCELL/NRREL-2:gNbIdLength=22
...    NRCELL/NRREL-2:handoverAllowedSA=allowed
...    NRCELL/NRREL-2:lcrId=2
...    NRCELL/NRREL-2:removeNotAllowed=false
...    NRCELL/NRREL-2:gnbPlmn:mcc=311
...    NRCELL/NRREL-2:gnbPlmn:mnc=489
...    NRCELL/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL/NRREL-14:cellIndividualSsbRsrpOffset=0dB
...    NRCELL/NRREL-14:cellIndividualSsbRsrqOffset=0dB
...    NRCELL/NRREL-14:gNbId=2
...    NRCELL/NRREL-14:gNbIdLength=22
...    NRCELL/NRREL-14:handoverAllowedSA=allowed
...    NRCELL/NRREL-14:lcrId=14
...    NRCELL/NRREL-14:removeNotAllowed=false
...    NRCELL/NRREL-14:gnbPlmn:mcc=311
...    NRCELL/NRREL-14:gnbPlmn:mnc=489
...    NRCELL/NRREL-14:gnbPlmn:mncLength=3
...    NRCELL/NRREL-14:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-2:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-14:sCellAdditionMethod=blind
...    NRCELL-12/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-14:sCellAdditionMethod=covBasedA1
...    NRCELL-12:a1MeasSCellAddEnabled=rsrq
...    NRCELL-12:a1MeasSCellAddSsbRsrq:a1HysteresisSCellAddSsbRsrq=0
...    NRCELL-12:a1MeasSCellAddSsbRsrq:a1ThresholdSCellAddSsbRsrq=111
...    NRCELL-12:a1MeasSCellAddSsbRsrq:a1TimeToTriggerSCellAddSsbRsrq=320ms

@{PARAMS_FOR_GNB2}
...    NRBTS:iGnbCaXnCfUpBackOffTmr=60
...    NRBTS:iGnbCaXnSetupReqTmr=90
...    NRBTS:iGnbCaXnSetupRespTmr=60
...    NRBTS:intGnbScellTempBlockTmr=60
...    NRMOPR_SA-1:a5MeasEnabled=rsrp
...    NRCELL-1:sCellDeactivationTimerGNB=infinity
...    NRCELL-2:sCellDeactivationTimerGNB=infinity
...    NRCELL-13:sCellDeactivationTimerGNB=infinity
...    NRCELL-14:sCellDeactivationTimerGNB=infinity
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRPMRNL-1:miNrInterGnbMobilityNsaPmqap=disabled
...    NRPMRNL-1:miNrInterGnbNgMobilitySaPmqap=disabled
...    NRPMRNL-1:miNrInterGnbXnMobilitySaPmqap=disabled
...    NRPMRNL-1:miNrIntraGnbMobilityNsaPmqap=disabled
...    NRPMRNL-1:miNrIntraGnbMobilitySaPmqap=disabled
...    NRCELL-13:a5MeasEnabled=rsrq
...    NRCELL-13:a5MeasSsbRsrp:a5HysteresisSsbRsrp=0
...    NRCELL-13:a5MeasSsbRsrp:a5Threshold1SsbRsrp=20
...    NRCELL-13:a5MeasSsbRsrp:a5Threshold2SsbRsrp=40
...    NRCELL-13:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms40
...    NRCELL-13:a5MeasSsbRsrq:a5HysteresisSsbRsrq=0
...    NRCELL-13:a5MeasSsbRsrq:a5Threshold1SsbRsrq=75
...    NRCELL-13:a5MeasSsbRsrq:a5Threshold2SsbRsrq=85
...    NRCELL-13:a5MeasSsbRsrq:a5TimeToTriggerSsbRsrq=ms40
...    NRCELL-13:actCDrx=true
...    NRCELL-13:drxProfileNrAnr:drxControl=intraNRSA
...    NRCELL-13:drxProfileNrAnr:drxInactivityTimer=80ms
...    NRCELL-13:drxProfileNrAnr:drxLongCycle=320ms
...    NRCELL-13:drxProfileNrAnr:drxOnDurationTimer=20ms
...    NRCELL-13:drxProfileNrAnr:drxRetransTimerDl=0slot
...    NRCELL-13:drxProfileNrAnr:drxRetransTimerUl=0slot
...    NRCELL-2:measGapSelectionSA=favourUeThroughput

@{PARAMS_ADJ_REL_FOR_GNB2}
...    NRBTS/NRADJGNB-1:administrativeState=Unlocked
...    NRBTS/NRADJGNB-1:gNbIdLength=22
...    NRBTS/NRADJGNB-1:gNodeBId=1
...    NRBTS/NRADJGNB-1:weightForIgnbCaSelection=50
...    NRBTS/NRADJGNB-1:xnLinkRef=1
...    NRBTS/NRADJGNB-1:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-1:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-1:gnbPlmn:mncLength=3
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
...    NRBTS/NRADJNRCELL-12:freqBandIndicatorNR=3
...    NRCELL-13/NRREL-12:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-13/NRREL-12:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-13/NRREL-12:gNbId=1
...    NRCELL-13/NRREL-12:gNbIdLength=22
...    NRCELL-13/NRREL-12:handoverAllowedSA=allowed
...    NRCELL-13/NRREL-12:lcrId=12
...    NRCELL-13/NRREL-12:removeNotAllowed=false
...    NRCELL-13/NRREL-12:sCellAdditionMethod=covBasedA1
...    NRCELL-13/NRREL-12:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-12:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-12:gnbPlmn:mncLength=3
...    NRCELL-13/NRREL-12:sCellOperationalMode=dlOnly
...    NRCELL-13:a1MeasSCellAddEnabled=rsrp
...    NRCELL-13:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=2
...    NRCELL-13:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=70
...    NRCELL-13:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=80
...    NRCELL-13:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms

@{gscn_Arfcn}
...    NRCELL-13:gscnOrSsPbchArfcn=4547
...    NRCELL-13/NRCELL_FDD-1:chBwDl=15MHz
...    NRCELL-13/NRCELL_FDD-1:chBwUl=15MHz
...    NRCELL-13/NRCELL_FDD-1:nrarfcnDl=364000
...    NRCELL-13/NRCELL_FDD-1:nrarfcnUl=345000

@{PARAMS_FOR_OTHERS}


...    NRBTS:actRanSharing=false
...    NRBTS:actHoOptimizationCa=true
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS:cipherPrefL:nea0=8
...    NRBTS:cipherPrefL:nea1_128=0
...    NRBTS:cipherPrefL:nea2_128=0
...    NRBTS:cipherPrefL:nea3_128=0
...    NRBTS:actIntraFreqHoSA=true
...    NRBTS:actInterFreqHoSA=true
...    NRPMRNL-1:miNrRelReportCu=5min

@{ANR_gnb}
...    NRBTS:actSaUeBasedAnrNr=true
...    NRBTS:actDedicatedAnrDrxProfile=true
...    NRBTS:actSaIntraFreqAnrDrxProf=true
...    NRANR-1:actAutoEutraNbRemoval=false
...    NRANR-1:actAutoNrNbRemoval=true
...    NRANR-1:consecHoFailThres=0
...    NRANR-1:consecHoFailThresEutra=3
...    NRANR-1:consecXnResolveFailThres=3
...    NRANR-1:gNbIdLengthConfig:gNbIdLength=22
...    NRANR-1:gNbIdLengthConfig:priorityIndex=1
...    NRANR-1:nrAnrId=1
...    NRANRPR-1:anrThresholdSelector=RSRP
...    NRANRPR-1:anrThresRsrpNbCell=-90
...    NRANRPR-1:anrThresRsrqNbCell=-12
...    NRANRPR-1:cellDepMode=SA+NSA
...    NRANRPR-1:consecRecheckForNrNbRemoval=5
...    NRANRPR-1:idleTimeForNrNbRemoval=72
...    NRANRPR-1:maxNumAnrNrrelAllowed=50
...    NRANRPR-1:nrAnrPrId=1
...    NRBTS:actSaUeBasedInterFreqAnrNr=true
...    NRANRPR-2:anrThresholdSelector=RSRP
...    NRANRPR-2:anrThresRsrpNbCell=-90
...    NRANRPR-2:anrThresRsrqNbCell=-12
...    NRANRPR-2:cellDepMode=SA+NSA
...    NRANRPR-2:consecRecheckForNrNbRemoval=5
...    NRANRPR-2:idleTimeForNrNbRemoval=72
...    NRANRPR-2:maxNumAnrNrrelAllowed=50
...    NRANRPR-2:nrAnrPrId=2
...    NRANRPR-2:nrarfcn=364000
...    NRANRPR-2:ssbFrequency=363850

${Online_Param_EDA}
...    NRCELL-2/NRHOIF-1:a3MeasEnabled=none


${ue_id}    1
${pdu_id}    1
${UE_NUM}    3
${Xn-c_link_unavailable}    7311

@{FTTF 4CC check}
...    physCellId 50
...    physCellId 51
...    physCellId 63
...    SCellIndex 3 activated successfully at airphone
...    SCellIndex 1 activated successfully at airphone
...    SCellIndex 2 activated successfully at airphone

@{default DRX setup}
...    drx-Config setup
...    drx-onDurationTimer milliSeconds : ms10
...    drx-LongCycleStartOffset ms40

@{blind_CA_and_default_drx}
...    @{FTTF 4CC check}
...    @{default DRX setup}

@{DRX release}
...    drx-Config release

@{CGI}
...    reportType reportCGI
...    cgi-Info

@{ANR DRX setup}
...    drx-Config setup
...    drx-onDurationTimer milliSeconds : ms10
...    drx-LongCycleStartOffset ms320

@{FF 2CC check}
...    physCellId 61
...    SCellIndex 1 activated successfully at airphone

@{ho_succ}
...    Inter-eNB handover from EXT_ENB

@{ANR_ho_succ}
...    drx-Config release:::2
...    drx-Config setup:::2
...    rrcReconfigurationComplete:::10
...    @{CGI}
...    cellForWhichToReportCGI 62
...    @{ANR DRX setup}
...    Inter-eNB handover from EXT_ENB
...    @{FF 2CC check}
...    @{default DRX setup}

@{ANR_ho_back_succ}
...    drx-Config release:::2
...    drx-Config setup:::2
...    rrcReconfigurationComplete:::10
...    @{CGI}
...    cellForWhichToReportCGI 60
...    @{ANR DRX setup}
...    Inter-eNB handover from EXT_ENB
...    @{FTTF 4CC check}
...    @{default DRX setup}

@{A2_MR}
...    @{DRX release}
...    eventId eventA1
...    eventId eventA3
...    eventId eventA5

@{A3_HO_60}
...    gapUE release
...    reportType reportCGI
...    cgi-Info
...    drx-Config setup
...    drx-onDurationTimer milliSeconds : ms20
...    drx-LongCycleStartOffset ms320
...    Intra-eNB handover from EXT_ENB-2.12 to EXT_ENB-2.11 performed

@{A3_HO_62_EDA}
...    gapUE release
...    reportType reportCGI
...    cgi-Info
...    drx-Config setup
...    drx-onDurationTimer milliSeconds : ms10
...    drx-LongCycleStartOffset ms40
...    Inter-eNB handover from EXT_ENB-2.12 to EXT_ENB-3.13 performed
...    rrcReconfigurationComplete

@{A3_HO_62}
...    gapUE release
...    reportType reportCGI
...    cgi-Info
...    drx-Config setup
...    drx-onDurationTimer milliSeconds : ms10
...    drx-LongCycleStartOffset ms40
...    Inter-eNB handover from EXT_ENB-2.12 to EXT_ENB-3.13 performed

@{A3_HO_fail}
...    gapUE release
...    drx-Config setup
...    drx-onDurationTimer milliSeconds : ms10
...    drx-LongCycleStartOffset ms320

@{DELETE_FOR_GNB1}
...    delete:MRBTS-1/NRBTS-1/NRCELL-11/NRREL-1
...    delete:MRBTS-1/NRBTS-1/NRCELL-11/NRREL-2
...    delete:MRBTS-1/NRBTS-1/NRCELL-11/NRREL-14
...    delete:MRBTS-1/NRBTS-1/NRCELL-12/NRREL-1
...    delete:MRBTS-1/NRBTS-1/NRCELL-12/NRREL-14
...    delete:MRBTS-1/NRBTS-1/NRCELL-12/NRREL-2
...    delete:MRBTS-1/NRBTS-1/NRADJNRCELL-12288
...    delete:MRBTS-1/NRBTS-1/NRCELL-11/NRREL-256
...    delete:NRADJGNB.*
...    delete:XNLINK.*

@{DELETE_FOR_GNB2}
...    delete:NRCELL-13/NRREL-12
...    delete:NRADJGNB.*
...    delete:XNLINK.*

${SA_Capa_Support_4CC_CA_n3A-n28A-n77(2A)_ANR}    SEPARATOR=
...    E9A09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C47013B8D80D81AC1184341020E9068036B64C558D0
...    E7C471E819F604F8C48E3C873EA39F30C7942C0E070F05C00FFC0070005F0005C0000E0541B00B582308682041E20D00656C98AB121CFB027
...    C471E31238F21CFA8E7CC31E50B0381C3C27F6000001FD800000170000381546C4CD608C21A0810748340185B262A88873E238F11C7A067D8
...    13E31CF9863CA1607038782E007FE003801FF8002E0000702A0D837AC1184341020F1068032B64C55890E7C471EC09F1891C790E7D473E618
...    F28581C0E1E13FFE00000FFF800000B80001C0AA3626EB04610D00000201A00C2D926544439F11C79063D033EC09F00E7CC31E50B0381C3C1
...    7AAAAAAA9EAAAAAAA17000038024B0F1300038980000002C0AC5C4C000E26000713000000858158B80400184C0309800020B02B1F00800303
...    6061300C260000C2C0AC5C02000C010181B0002058158F8040018060303606134000A160562E01000606C0C26000182C0AC3C02000C260001
...    C2C0AC3C02000C01000202C0AC3C1B000C0D800242C0AC3C02000C03000282C0AC3C06000C0D8002C2C0AC5C02000C030181B000605815878
...    36001C4C00001A160562E2600061300C01000382C0AC7C4C000C260180203036000F0B02B171300030040606C0020160563E2680060080C03
...    0181B00088581009006E003404C800501345D003A4250A244D8E7C38912244D8E7C38912244D8E7C38D1224489B1CF871224489B1CF871A24
...    48913639F0E2448913639F0E14489B1CF870A244D8E7C3851226C73E1C28913639F0E14489B1CF871224489B1CF870A244D8E7C38912244D8
...    E7C38D1224489B1CF871224489B1CF871A2448913639F0C06C486318C6318C6318C6318C6307A0B800F800A070500703009401C0018090010
...    180F82400800000004002000000080000300400000802000008010000060080000400400002802001004010040000300200001C0100080000
...    00200002001000012008000030040000500200002C01000812048020000300CE54D654D60A5606560CD60AD652DE4CDE02D606D6025604560
...    ED0341000009652504000065949810000196524040000E594901000049652404000165949810000696524040001E594901000089652404000
...    265949010000A96524040002E5949410000C96524040000C594900CD2AABA55554AA2E95455058AA0B1541A2A94C55268AA031540A2A93555
...    078A160178095028140A05028140A05028140A05028140A050281400442020040080801002201002004040080101002004402018028080100
...    202004008C04030050100C014040080101002004402020028080800A0202C058C04030060100C014040300601002004402018028080600A02
...    0040084040300501002004202018028080600A10100C018040300608080600C02018028404030050100C014402018028080600C0201802840
...    40300601002004402004008080100202018028C04008010100200404030050100C014402004008080600C02018030C04008010100C0140403
...    0060100C0146A87C0004080C10181C282C30344044484C5060646C70747C8494989CA0A4A8B4BD05060B40

*** Test Cases ***
CB008140-ET-GH023_inter-freq ANR DRX setup with MG release after covBasedA1 IgNB-CA addition then HO fail with T321
    [Documentation]
    ...    This user scenario verifies the case that ANR specific DRX setup is triggered after SCell addition,
    ...    ANR specific DRX profile should be applied to all serving cells; verifies the case that MG setup is triggered
    ...    after SCell addition, MG configuration should be applied to all serving cells; verifies the case that
    ...    measurement gap release is triggered after SCell addition, measurement gap release
    ...    [Configuration]:
    ...       GNB1 cell1_11, cell1_12 F+F
    ...       GNB2 cell2_1, cell2_2, cell2_13, cell2_14 T+T+F+F
    ...    [TL seting]: 2 classical cmWave gNb
    ...    [Cover Feature]: CB008140 GH
    ...    [Configuration]:
    ...    GNB-1 Pri: cell11-FDD(n3)(pci:60) cell12-FDD(n3)(pci:61)
    ...    set_cell id=11 gnb=2 pci=20:0 tac=200 nrci=0x0B tdd_cell=off nr_arfcn=345000:364000 gscn=4547
    ...    set_cell id=12 gnb=2 pci=20:1 tac=200 nrci=0x0C tdd_cell=off nr_arfcn=355000:374000 gscn=4675
    ...    GNB-2 ext: cell1-TDD(n77)(pci:50) cell2-TDD(n77)(pci:51) cell13-FDD(n3)(pci:62) cell14-FDD(n28)(PCI63)
    ...    set_cell id=1 gnb=3 pci=16:2 tac=200 nrci=0x01 tdd_cell=on nr_arfcn=663400:663400 gscn=8159
    ...    set_cell id=2 gnb=3 pci=17:0 tac=200 nrci=0x02 tdd_cell=on nr_arfcn=658000:658000 gscn=8103
    ...    set_cell id=13 gnb=3 pci=20:2 tac=200 nrci=0x0D tdd_cell=off nr_arfcn=349400:368400 gscn=4605
    ...    set_cell id=14 gnb=3 pci=21:0 tac=200 nrci=0x0E tdd_cell=off nr_arfcn=143400:153400 gscn=1916
    ...    scell gnb2-cell1 gnb2-cell2 and gnb2-cell14
    ...    2.Test Case Steps:
    ...        a. UE1 Register And PDU Session Setup On Cell1_12
    ...        b. Trigger A1 to setup 4CCs CA via rsrq measurement
    ...        c. UE1 send A2 MR to trigger MG setup
    ...        d. set ue not send NRCGI
    ...        e. UE1 send A3 MR with RSRP satisfied to trigger inter-frequency intergnb ANR handover
    ...    3. Expected Results:
    ...         Step a: UE1 Register And PDU Session Setup Successfully
    ...         Step b: After measurement works , add Cell2_1,Cell2_2 and Cell2_14 as Scells
    ...         Step c: default DRX release, A3/A5 and A1 measconfig IE to UE
    ...         Step e: release measurement gap and setup DRX with NRCGI report configuration, NRCGI measConfig IE to UE,
    ...                 and A2 measconfig
    [Tags]    GH023    QC_277937    CA_LABEL-FTTF(20Mhz_FDD_n3+100Mhz_TDD_n77+40Mhz_TDD_n77+15Mhz_FDD_n28)
    Ue Register And PDU Session Setup Without Scell Addition    cell_id=12
    UE Send A1 To Trigger 4CC CA setup
    Report A2 and configured A3 for UE
    Report A3 and Trigger HO    phycell_id=60    pass_regexp=${A3_HO_60}
    Ue Register And PDU Session Setup Without Scell Addition    ue_id=3    cell_id=12
    Report A2 and configured A3 for UE    ue_id=3
    set ue not send NRCGI    ue_id=3
    Report A3 and Trigger HO failed    ue_id=3
    Ue Register And PDU Session Setup Without Scell Addition    ue_id=2    cell_id=12
    Delta Commission Parameters Gnb2     ${Online_Param_EDA}
    Report A2 and configured A3 for UE    ue_id=2
    Report A3 and Trigger HO    ue_id=2    phycell_id=62    pass_regexp=${A3_HO_62_EDA}
    Check Wireshark Log    ${CURDIR}${/}A2A_GH_023${/}a2a_gnb1.ini    wait_string=IgNBCAModificationRequestAcknowledge::12

CB008140-ET-GH022_intra-freq ANR DRX setup after covBasedA1 IgNB-CA FFT addition then Xn HO success to cell with IgNB-CA mode
    [Documentation]
    ...    1. This user scenario verifies the case that ANR specific DRX setup is triggered after SCell addition,
    ...       ANR specific DRX profile should be applied to all serving cells.
    ...    2. Configuration
    ...       GNB1 cell1_11, cell1_12 F+F
    ...       GNB2 cell2_1, cell2_2, cell2_13, cell2_14 T+T+F+F
    ...    [TL seting]: 2 classical cmWave gNb
    ...    [Cover Feature]: CB008140 GH
    ...    [Configuration]:
    ...    GNB-1 Pri: cell11-FDD(n3)(pci:60) cell12-FDD(n3)(pci:61)
    ...    set_cell id=11 gnb=2 pci=20:0 tac=200 nrci=0x0B tdd_cell=off nr_arfcn=345000:364000 gscn=4547
    ...    set_cell id=12 gnb=2 pci=20:1 tac=200 nrci=0x0C tdd_cell=off nr_arfcn=355000:374000 gscn=4675
    ...    GNB-2 ext: cell1-TDD(n77)(pci:50) cell2-TDD(n77)(pci:51) cell13-FDD(n3)(pci:62) cell14-FDD(n28)(PCI63)
    ...    set_cell id=1 gnb=3 pci=16:2 tac=200 nrci=0x01 tdd_cell=on nr_arfcn=663400:663400 gscn=8159
    ...    set_cell id=2 gnb=3 pci=17:0 tac=200 nrci=0x02 tdd_cell=on nr_arfcn=658000:658000 gscn=8103
    ...    set_cell id=13 gnb=3 pci=20:2 tac=200 nrci=0x0D tdd_cell=off nr_arfcn=349400:368400 gscn=4605
    ...    set_cell id=14 gnb=3 pci=21:0 tac=200 nrci=0x0E tdd_cell=off nr_arfcn=143400:153400 gscn=1916
    ...    scell gnb2-cell1 gnb2-cell2 and gnb2-cell14
    ...    [Test Case Steps]
    ...         a. UE register to gnb1-cell11
    ...            blind 4CC FFTT scells add successful
    ...         b. UE1 send A5 MR with RSRP satisfied to trigger intra-frequency intergnb ANR handover
    ...            coverBasedA1 add interGnb cell as scell
    ...         c. UE1 send A5 MR with NRMOPR_SA RSRP satisfied to trigger intra-frequency intergnb ANR handover back
    ...    [Expected Results]:
    ...         a.scell: gnb2-cell1 gnb2-cell2 and gnb2-cell14 add successfully, traffic ok, , default DRX setup
    ...         b.HO from gnb1-cell11 to gnb2-cell13 successfully, release default DRX,
    ...           setup dedicated intra-NR intra-frequency DRX profile,
    ...           gnb send the measConfig including measurement configuration of intra-frequency NRCGI report to UE
    ...           scell: gnb2-cell12 add successfully as actHoOptimizationCa configured
    ...         c. HO back from gnb2-cell13 to gnb1-cell11 successfully
    [Tags]    GH022    QC_277936    CA_LABEL-FTTF(20Mhz_FDD_n3+100Mhz_TDD_n77+40Mhz_TDD_n77+15Mhz_FDD_n28)
    UE Attach To Target Cell Then Send And Verify Throughput
    Intrafreq InterGNB Handover
    Intrafreq InterGNB Handover Back
    Delete Xnlink and handover loop
    Check Wireshark Log    ${CURDIR}${/}A2A_GH_022${/}a2a_gnb1.ini    wait_string=UEContextRelease::30
    Check WireShark Log GNB2    ${CURDIR}${/}A2A_GH_022${/}a2a_gnb2.ini    wait_string=IgNBCAUeContextReleaseComplete::1
    [Teardown]    GH022_Teardown


*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup 2Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_gnb1_2F_gnb2_2T2F

GH022_Teardown
    Common Test Teardown And Stop Capture Logs

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir


Delete Xnlink and handover loop
    FOR    ${index}    IN RANGE    1    5
        Check Xn Link Status and Delete XnLink
        sleep    80s
        UE Attach To Target Cell    ue_id=${index}
        Trigger Xnlink    ue_id=${index}
        Intrafreq InterGNB Handover    ue_id=${index}    pass_regexp=${ho_succ}
    END

Check Xn Link Status and Delete XnLink
    Delta Commission Parameters     ${DELETE_FOR_GNB1}
    Delta Commission Parameters Gnb2    ${DELETE_FOR_GNB2}

Trigger Xnlink
    [Arguments]    ${ue_id}=1    ${carrierfreq}=363850
    ${meas_id}    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A5
    ${event_cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A5
    ...    srsrp_nr=11 srsrq_nr=11 phycell_id=62 nrsrp_nr=110 nrsrq_nr=110
    Execute Egate Command    ${event_cmd}
    sleep    120s    wait for xnlink and nrrel setup

UE Attach To Target Cell
     [Arguments]    ${cell_id}=11    ${ue_id}=1    ${pdu_id}=1    ${gw_id}=1
    Execute Egate Command    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_Support_4CC_CA_n3A-n28A-n77(2A)_ANR}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=${gw_id} nwslice=1
    ...    pass_regexp=${default DRX setup}    timeout=10s
    Send traffic    ${ue_id}

Intrafreq InterGNB Handover failure
    [Arguments]    ${ue_id}=1    ${carrierfreq}=363850    ${target_phycell_id}=62
    Execute Egate Command    ue_disp
    ${meas_id_scell}    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A5
    ${event_cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id_scell} event=A5
    ...    srsrp_nr=11 srsrq_nr=11 phycell_id=${target_phycell_id} nrsrp_nr=110 nrsrq_nr=110
    Execute Egate Command    ${event_cmd}
    ...    fail_regexp=Inter-eNB handover from EXT_ENB

UE Attach To Target Cell Then Send And Verify Throughput
    [Arguments]    ${cell_id}=11    ${ue_id}=1    ${pdu_id}=1    ${gw}=1
    Execute Egate Command    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_Support_4CC_CA_n3A-n28A-n77(2A)_ANR}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=${gw} nwslice=1
    ...    pass_regexp=${blind_CA_and_default_drx}    timeout=10s
    Send traffic
    Verify Throuput

Verify Throughput After Add Scell
    [Arguments]    ${ue_id}=1    ${Tput_dl}=70    ${Tput_ul}=9.5    ${sleep_time}=15s    ${pdu_id}=1
    sleep    ${sleep_time}    sleep for Tput stable
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${Tput_ul}
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000 > ${Tput_dl}
    ${scell1_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=1    type=pdsch    rate_type=ave
    Should Be True    ${scell1_tput}/1000 > ${Tput_dl}

Intrafreq InterGNB Handover
    [Arguments]    ${ue_id}=1    ${carrierfreq}=363850    ${target_phycell_id}=62    ${pass_regexp}=${ANR_ho_succ}
    Execute Egate Command    ue_disp
    ${meas_id_scell}    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A5
    ${event_cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id_scell} event=A5
    ...    srsrp_nr=11 srsrq_nr=11 phycell_id=${target_phycell_id} nrsrp_nr=110 nrsrq_nr=110
    Execute Egate Command    ${event_cmd}
    ...    pass_regexp=${pass_regexp}

Intrafreq InterGNB Handover Back
    [Arguments]    ${ue_id}=1    ${carrierfreq}=363850    ${target_phycell_id}=60
    Execute Egate Command    ue_disp
    ${meas_id_scell}    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A5
    ${event_cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id_scell} event=A5
    ...    srsrp_nr=11 srsrq_nr=11 phycell_id=${target_phycell_id} nrsrp_nr=110 nrsrq_nr=110
    Execute Egate Command    ${event_cmd}
    ...    pass_regexp=${ANR_ho_back_succ}
    Verify Throuput on Pcell and Scell

Send traffic
    [Arguments]    ${ue_id}=1    ${pdu_id}=1
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=3    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=4    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=5    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=6    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=7    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=ul mbps=10 trf_id=1    UE ${ue_id}: UDP UL

Verify Throuput
       Verify Throuput on Pcell and Scell    sleep_time=10s

Stop traffic
    [Arguments]    ${ue_id}=1
    Execute Egate Command    trf_data_stop ue=${ue_id} pass_regexp=Traffic was stopped

Scell traffic check
    [Arguments]    ${scell1_tput1}    ${scell2_tput2}    ${scell3_tput3}    ${scell1_tput1_except}=30
    ...    ${scell2_tput2_except}=30    ${scell3_tput3_except}=30
    Should Be True    ${scell1_tput1}/1000>${scell1_tput1_except}
    Should Be True    ${scell2_tput2}/1000>${scell2_tput2_except}
    Should Be True    ${scell3_tput3}/1000>${scell3_tput3_except}

Verify Throuput on Pcell and Scell
    [Arguments]    ${ue_id}=1    ${qfi}=1    ${sleep_time}=10s    ${scell1_tput1_except}=470    ${scell2_tput2_except}=180
    ...    ${scell3_tput3_except}=70    ${pcell_tput_except}=70
    sleep    ${sleep_time}
    ${scell1_tput1}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=1    type=pdsch    rate_type=ave
    ${scell2_tput2}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=2    type=pdsch    rate_type=ave
    ${scell3_tput3}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=3    type=pdsch    rate_type=ave
    Scell traffic check    ${scell1_tput1}    ${scell2_tput2}    ${scell3_tput3}    ${scell1_tput1_except}
    ...    ${scell2_tput2_except}    ${scell3_tput3_except}
    ${pcell_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${pcell_tput}/1000>${pcell_tput_except}
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=${qfi}    direction=ul    rate_type=ave
    Should Be True    ${ul_throughput}/1000>9

Ue Register And PDU Session Setup Without Scell Addition
    [Arguments]    ${ue_id}=1    ${gateway}=1    ${enb_id}=2    ${cell_id}=11
    Execute Egate Command    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_Support_4CC_CA_n3A-n28A-n77(2A)_ANR}
    Execute Egate Command    ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    ${ret1}=    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${gateway}    pass_regexp=QoS Routing Table

UE Send A1 To Trigger 4CC CA setup
    [Arguments]    ${ue_id}=1    ${cellfreq}=373970
    ${ScellAdd_A1}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cellfreq}    event_type=A1
    ...    threshold=RSRQ\ 111
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${ScellAdd_A1} event=A1 srsrq_nr=120
    ...    pass_regexp=${FTTF 4CC check}
    Send traffic
    Verify Throuput on Pcell and Scell

Report A2 and configured A3 for UE
    [Arguments]    ${ue_id}=1    ${ssbfreq}=373970
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}    ${ssbfreq}    A2
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 srsrp_nr=30 srsrq_nr=30
    ...    ${A2_MR}

set ue not send NRCGI
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_nr_rrc_reconf_param id=${ue_id} if_contains=report_cgi action=donot_send_NRCGI

Report A3 and Trigger HO failed
    [Arguments]    ${ue_id}=1    ${ssbfreq}=363850    ${phycell_id}=62
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}    ${ssbfreq}    A3
    ${A3_cmd}    catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A3 srsrp_nr=11 srsrq_nr=11
    ...    phycell_id=${phycell_id} nrsrp_nr=91 nrsrq_nr=91
    Execute Egate Command    ${A3_cmd}
    ...    pass_regexp=${A3_HO_fail}    fail_regexp=Inter-eNB handover from EXT_ENB-2.12 to EXT_ENB-3.13 performed

Report A3 and Trigger HO
    [Arguments]    ${ue_id}=1    ${ssbfreq}=363850    ${phycell_id}=60    ${pass_regexp}=${A3_HO_60}
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}    ${ssbfreq}    A3
    ${A3_cmd}    catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A3 srsrp_nr=11 srsrq_nr=11
    ...    phycell_id=${phycell_id} nrsrp_nr=91 nrsrq_nr=91
    Execute Egate Command    ${A3_cmd}
    ...    pass_regexp=${pass_regexp}
