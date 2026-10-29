*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CLOUD_5G_I_[LO][LO]_AP_[LOO]_SANSA_FS_ECPRI_CMWV_TDD    team-L3CN1_SG02
...    owner-nanxiao.ge    release-SBTS23R4    CRT
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${BTS_STARTUP_RETRY}    3
${NOKIA_XNAP_PLUGIN_FLAG}    ${True}
${NOKIA_F1AP_PLUGIN_FLAG}    ${True}
@{PARAMS_IN_SWCONFIG}
...    ${DisableL2PS_XPU_monitoring}=0
${DisableL2PS_XPU_monitoring}    0x580647

@{PARAMS_IN_SCF}
...    @{PARAMS_FOR_CA}
...    @{PARAMS_FOR_GNB1}
...    @{PARAMS_ADJ_REL_FOR_GNB1}
...    @{PARAMS_FOR_Inter_Freq_HO_For_GNB1}
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
...    NRBTS:weightForIgnbCaSelection=50
...    NRBTS:maxNumScellsDl=3
...    NRBTS:maxNumScellsUl=3
...    NRBTS:actIncXn=true
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:carrierAggregationSupportList=ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Any_Sa,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Fdd,ca_Fdd_Any_Sa
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRDU-1:actInterGnbCa=DLOnly
...    NRDU-1:dlToUlContributionRatio=101
...    NRCELL:actK1Opt=intraAndInter-gNB
...    NRCELL:maxNumScellsDlFr1=3
@{PARAMS_FOR_GNB1}
...    MRBTS-1/NRBTS/XNLINK-1:cPlaneIpAddr=10.0.1.3
...    MRBTS-1/NRBTS/XNLINK-2:cPlaneIpAddr=10.0.1.124
...    MRBTS-1/MNL-1/MNLENT-1/XPAP-1/XPIF-1/XPIFREMOTE-2:ipAddress=10.0.1.124
...    MRBTS-1/MNL-1/MNLENT-1/XPAP-1/XPIF-1/XPIFREMOTE-2:remoteNeType=GNB
...    MRBTS-1/MNL-1/MNLENT-1/XPAP-1/XPIF-1/XPIFREMOTE-1:ipAddress=10.0.1.3
...    MRBTS-1/MNL-1/MNLENT-1/XPAP-1/XPIF-1/XPIFREMOTE-1:remoteNeType=GNB
...    NRBTS/NRADJGNB-1:administrativeState=Unlocked
...    NRBTS/NRADJGNB-1:gNbIdLength=22
...    NRBTS/NRADJGNB-1:gNodeBId=2
...    NRBTS/NRADJGNB-1:weightForIgnbCaSelection=1
...    NRBTS/NRADJGNB-1:xnLinkRef=1
...    NRBTS/NRADJGNB-1:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-1:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-1:gnbPlmn:mncLength=3
...    NRBTS:iGnbCaXnCfUpBackOffTmr=60
...    NRBTS:iGnbCaXnSetupReqTmr=60
...    NRBTS:iGnbCaXnSetupRespTmr=60
...    NRBTS:intGnbScellTempBlockTmr=60
...    NRBTS:actSaUeBasedInterFreqAnrNr=true
...    NRDU-1:xgUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRCELL:sCellDeactivationTimerGNB=infinity
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRCELL-1:a1MeasSCellAddEnabled=rsrpCombined
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=31
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=31
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-1:a1MeasSCellAddSsbRsrq:a1HysteresisSCellAddSsbRsrq=0
...    NRCELL-1:a1MeasSCellAddSsbRsrq:a1ThresholdSCellAddSsbRsrq=31
...    NRCELL-1:a1MeasSCellAddSsbRsrq:a1TimeToTriggerSCellAddSsbRsrq=40ms
...    NRCELL-1:a1MeashoEnabledSA=rsrpCombined
...    NRCELL-1:a1MeashoSsbRsrqSA:a1HysteresishoSsbRsrqSA=0
...    NRCELL-1:a1MeashoSsbRsrqSA:a1ThresholdhoSsbRsrqSA=60
...    NRCELL-1:a1MeashoSsbRsrqSA:a1TimeToTriggerhoSsbRsrqSA=ms40
...    NRCELL-1:a2MeashoEnabledSA=rsrpCombined
...    NRCELL-1:a3MeasEnabled=rsrpCombined
...    NRCELL-1:actCDrx=true
...    NRCELL-1:drxProfileNrAnr:drxControl=intraNRSAinterFreq
...    NRCELL-1:drxProfileNrAnr:drxInactivityTimer=80ms
...    NRCELL-1:drxProfileNrAnr:drxLongCycle=320ms
...    NRCELL-1:drxProfileNrAnr:drxOnDurationTimer=20ms
...    NRCELL-1:drxProfileNrAnr:drxRetransTimerDl=0slot
...    NRCELL-1:drxProfileNrAnr:drxRetransTimerUl=0slot

@{DELETE_FOR_GNB1}
...    delete:NRBTS-1/XNLINK-1
...    delete:NRBTS-1/NRADJGNB-1

@{PARAMS_ADJ_REL_FOR_GNB1}
...    NRBTS/NRADJGNB-3:administrativeState=Unlocked
...    NRBTS/NRADJGNB-3:gNbIdLength=22
...    NRBTS/NRADJGNB-3:gNodeBId=35
...    NRBTS/NRADJGNB-3:weightForIgnbCaSelection=50
...    NRBTS/NRADJGNB-3:xnLinkRef=2
...    NRBTS/NRADJGNB-3:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-3:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-3:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-63:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-63:fiveGsTac=200
...    NRBTS/NRADJNRCELL-63:freqBandIndicatorNR=3
...    NRBTS/NRADJNRCELL-63:gNbId=35
...    NRBTS/NRADJNRCELL-63:gNbIdLength=22
...    NRBTS/NRADJNRCELL-63:lcrId=5
...    NRBTS/NRADJNRCELL-63:nrarfcn=368400
...    NRBTS/NRADJNRCELL-63:ssbFrequency=368430
...    NRBTS/NRADJNRCELL-63:physCellId=63
...    NRBTS/NRADJNRCELL-63:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-63:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-63:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-64:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-64:fiveGsTac=200
...    NRBTS/NRADJNRCELL-64:freqBandIndicatorNR=28
...    NRBTS/NRADJNRCELL-64:gNbId=35
...    NRBTS/NRADJNRCELL-64:gNbIdLength=22
...    NRBTS/NRADJNRCELL-64:lcrId=6
...    NRBTS/NRADJNRCELL-64:nrarfcn=153400
...    NRBTS/NRADJNRCELL-64:ssbFrequency=153370
...    NRBTS/NRADJNRCELL-64:physCellId=64
...    NRBTS/NRADJNRCELL-64:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-64:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-64:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-65:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-65:fiveGsTac=200
...    NRBTS/NRADJNRCELL-65:freqBandIndicatorNR=77
...    NRBTS/NRADJNRCELL-65:gNbId=35
...    NRBTS/NRADJNRCELL-65:gNbIdLength=22
...    NRBTS/NRADJNRCELL-65:lcrId=7
...    NRBTS/NRADJNRCELL-65:nrarfcn=648000
...    NRBTS/NRADJNRCELL-65:ssbFrequency=648096
...    NRBTS/NRADJNRCELL-65:physCellId=65
...    NRBTS/NRADJNRCELL-65:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-65:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-65:gnbPlmn:mncLength=3
...    NRBTS/NRANR-1:actAutoEutraNbRemoval=false
...    NRBTS/NRANR-1:actAutoNrNbRemoval=true
...    NRBTS/NRANR-1:consecHoFailThres=0
...    NRBTS/NRANR-1:consecHoFailThresEutra=3
...    NRBTS/NRANR-1:consecXnResolveFailThres=3
...    NRBTS/NRANR-1:gNbIdLengthConfig:gNbIdLength=22
...    NRBTS/NRANR-1:gNbIdLengthConfig:priorityIndex=1
...    NRBTS/NRANRPR-2:anrThresRsrpNbCell=-90
...    NRBTS/NRANRPR-2:anrThresRsrqNbCell=-48
...    NRBTS/NRANRPR-2:anrThresholdSelector=RSRP
...    NRBTS/NRANRPR-2:cellDepMode=SA+NSA
...    NRBTS/NRANRPR-2:consecRecheckForNrNbRemoval=5
...    NRBTS/NRANRPR-2:idleTimeForNrNbRemoval=72
...    NRBTS/NRANRPR-2:maxNumAnrNrrelAllowed=50
...    NRBTS/NRANRPR-2:nrarfcn=653400
...    NRBTS/NRANRPR-2:ssbFrequency=655008
...    NRCELL-1/NRREL-63:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-63:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-63:gNbId=35
...    NRCELL-1/NRREL-63:gNbIdLength=22
...    NRCELL-1/NRREL-63:handoverAllowedSA=XnHoNotAllowed
...    NRCELL-1/NRREL-63:lcrId=5
...    NRCELL-1/NRREL-63:removeNotAllowed=false
...    NRCELL-1/NRREL-63:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-63:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-63:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-63:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-63:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-64:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-64:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-64:gNbId=35
...    NRCELL-1/NRREL-64:gNbIdLength=22
...    NRCELL-1/NRREL-64:handoverAllowedSA=XnHoNotAllowed
...    NRCELL-1/NRREL-64:lcrId=6
...    NRCELL-1/NRREL-64:removeNotAllowed=false
...    NRCELL-1/NRREL-64:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-64:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-64:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-64:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-64:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-65:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-65:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-65:gNbId=35
...    NRCELL-1/NRREL-65:gNbIdLength=22
...    NRCELL-1/NRREL-65:handoverAllowedSA=XnHoNotAllowed
...    NRCELL-1/NRREL-65:lcrId=7
...    NRCELL-1/NRREL-65:removeNotAllowed=false
...    NRCELL-1/NRREL-65:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-65:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-65:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-65:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-65:gnbPlmn:mncLength=3
@{PARAMS_FOR_Inter_Freq_HO_For_GNB1}
...    NRCELL-1:ifhoSsbSmtcOffset=0
...    NRCELL-1:gapOffset=0
...    NRCELL-1:mgta=ms0
...    NRBTS/NRPMRNL-1:miNrRelReportCu=15min
...    NRBTS:actInterFreqHoSA=true
...    NRCELL-1:a1MeashoEnabledSA=rsrpCombined
...    NRCELL-1:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRCELL-1:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=60
...    NRCELL-1:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL-1:measGapSelectionSA=favourUeThroughput
...    NRCELL-1:a2MeashoEnabledSA=rsrpCombined
...    NRCELL-1:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0
...    NRCELL-1:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=34
...    NRCELL-1:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL-1:a2MeashoSsbRsrqSA:a2HysteresishoSsbRsrqSA=0
...    NRCELL-1:a2MeashoSsbRsrqSA:a2ThresholdhoSsbRsrqSA=49
...    NRCELL-1:a2MeashoSsbRsrqSA:a2TimeToTriggerhoSsbRsrqSA=ms480
...    NRCELL-1:a3MeasEnabled=rsrpCombined
...    NRCELL-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=30
...    NRCELL-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms40
...    NRCELL-1:a3MeasSsbRsrq:a3HysteresisSsbRsrq=0
...    NRCELL-1:a3MeasSsbRsrq:a3OffsetSsbRsrq=30
...    NRCELL-1:a3MeasSsbRsrq:a3TimeToTriggerSsbRsrq=ms40
...    NRCELL-1:absThreshSsbRsrqConsolidation=20
...    NRCELL-1/NRHOIF-1:a3MeasEnabled=rsrpCombined
...    NRCELL-1/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-1/NRHOIF-1:freqBandIndicatorNR=77
...    NRCELL-1/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf2
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf20
...    NRCELL-1/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-1/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-1:ssbFrequency=655008
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms1024
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=4
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrq:a3TimeToTriggerSsbRsrq=ms1024
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrq:a3HysteresisSsbRsrq=0
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrq:a3OffsetSsbRsrq=6
@{PARAMS_FOR_GNB2}
...    NRBTS/XNLINK-1:cPlaneIpAddr=10.0.1.2
...    MRBTS-2/MNL-1/MNLENT-1/XPAP-1/XPIF-1/XPIFREMOTE-1:ipAddress=10.0.1.2
...    MRBTS-2/MNL-1/MNLENT-1/XPAP-1/XPIF-1/XPIFREMOTE-1:remoteNeType=GNB
...    NRBTS-2/NRADJGNB-1:administrativeState=Unlocked
...    NRBTS-2/NRADJGNB-1:gNbIdLength=22
...    NRBTS-2/NRADJGNB-1:gNodeBId=1
...    NRBTS-2/NRADJGNB-1:weightForIgnbCaSelection=1
...    NRBTS-2/NRADJGNB-1:xnLinkRef=1
...    NRBTS/NRADJGNB-1:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-1:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-1:gnbPlmn:mncLength=3
...    NRBTS/NRPMRNL-1:miNrRelReportCu=15min
...    NRBTS:actInterFreqHoSA=true
...    NRBTS:iGnbCaXnCfUpBackOffTmr=60
...    NRBTS:iGnbCaXnSetupReqTmr=60
...    NRBTS:iGnbCaXnSetupRespTmr=60
...    NRBTS:intGnbScellTempBlockTmr=60
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS:actSaUeBasedInterFreqAnrNr=true
...    NRBTS/NRANR-1:actAutoEutraNbRemoval=false
...    NRBTS/NRANR-1:actAutoNrNbRemoval=true
...    NRBTS/NRANR-1:consecHoFailThres=0
...    NRBTS/NRANR-1:consecHoFailThresEutra=3
...    NRBTS/NRANR-1:consecXnResolveFailThres=3
...    NRBTS/NRANR-1:gNbIdLengthConfig:gNbIdLength=22
...    NRBTS/NRANR-1:gNbIdLengthConfig:priorityIndex=1
...    NRBTS/NRANRPR-2:anrThresRsrpNbCell=-90
...    NRBTS/NRANRPR-2:anrThresRsrqNbCell=-48
...    NRBTS/NRANRPR-2:anrThresholdSelector=RSRP
...    NRBTS/NRANRPR-2:cellDepMode=SA+NSA
...    NRBTS/NRANRPR-2:consecRecheckForNrNbRemoval=5
...    NRBTS/NRANRPR-2:idleTimeForNrNbRemoval=72
...    NRBTS/NRANRPR-2:maxNumAnrNrrelAllowed=50
...    NRBTS/NRANRPR-2:nrarfcn=663400
...    NRBTS/NRANRPR-2:ssbFrequency=663360
...    NRDU-1:xgUplane:ipV4AddressDN1=MRBTS-2/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRCELL:sCellDeactivationTimerGNB=infinity
...    NRCELL:weightForSCellSelection=50
...    NRCELL-3:a1MeashoEnabledSA=rsrpCombined
...    NRCELL-3:a1MeasSCellAddEnabled=rsrpCombined
...    NRCELL-3:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL-3:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=60
...    NRCELL-3:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=100
...    NRCELL-3:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-3:a1MeasSCellAddSsbRsrq:a1HysteresisSCellAddSsbRsrq=0
...    NRCELL-3:a1MeasSCellAddSsbRsrq:a1ThresholdSCellAddSsbRsrq=100
...    NRCELL-3:a1MeasSCellAddSsbRsrq:a1TimeToTriggerSCellAddSsbRsrq=40ms
...    NRCELL-3:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRCELL-3:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=60
...    NRCELL-3:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms40
...    NRCELL-3:a1MeashoSsbRsrqSA:a1HysteresishoSsbRsrqSA=0
...    NRCELL-3:a1MeashoSsbRsrqSA:a1ThresholdhoSsbRsrqSA=60
...    NRCELL-3:a1MeashoSsbRsrqSA:a1TimeToTriggerhoSsbRsrqSA=ms40
...    NRCELL-3:actCDrx=true
...    NRCELL-3:drxProfileNrAnr:drxControl=intraNRSAinterFreq
...    NRCELL-3:drxProfileNrAnr:drxInactivityTimer=80ms
...    NRCELL-3:drxProfileNrAnr:drxLongCycle=320ms
...    NRCELL-3:drxProfileNrAnr:drxOnDurationTimer=20ms
...    NRCELL-3:drxProfileNrAnr:drxRetransTimerDl=0slot
...    NRCELL-3:drxProfileNrAnr:drxRetransTimerUl=0slot
@{DELETE_FOR_GNB2}
...    delete:NRBTS-2/XNLINK-1
...    delete:NRBTS-2/NRADJGNB-1
@{PARAMS_ADJ_REL_FOR_GNB2}
...    NRBTS/NRMOPR_SA-1:a1MeashoEnabledSA=rsrpCombined
@{PARAMS_FOR_OTHERS}


...    NRBTS:actRanSharing=false
...    NRBTS:cipherPrefL:nea0=8
...    NRBTS:cipherPrefL:nea1_128=0
...    NRBTS:cipherPrefL:nea2_128=0
...    NRBTS:cipherPrefL:nea3_128=0
...    NRBTS:integrityProtPrefL:nia0=0
...    NRBTS:integrityProtPrefL:nia1_128=0
...    NRBTS:integrityProtPrefL:nia2_128=0
...    NRBTS:integrityProtPrefL:nia3_128=9
...    NRBTS:actIntraNrNgHo=sourceAndTarget
...    NRBTS:tNgRelocCancelN=2000
...    NRBTS:tNgRelocExecDeltN=3000
...    NRBTS:tNgRelocOverallN=2000
...    NRBTS:tNgRelocPrepN=2000
...    NRBTS:actConflictConfiguration=true
...    NRBTS:drbInactivityTimerSA=6000

#UE_Capa with nr-CGI-Reporting supported
${SA_Capa_Support_2CC_n77_n3_n28_n78_CA}    SEPARATOR=
...    E9A09000575F5A13160003C1A00B0498B800CE1E82813641873E618F28581C130080C47013B8D80D81AC1184341020E90186D6C98AB1A1CF88E3D033EC09F1891C790E7D473
...    E618F28581C0E1E0BFFFFF800E000BE0005800702A0D805AC1184341020F1018656C98AB121CFB027C471E31238F21CFA8E7CC31E50B0381C3C27F6000001FD8000000B000E
...    0551B133582308682041D2030C2D931544439F11C788E3D033EC09F18E7CC31E50B0381C3C17003FF001C00FFC000B000E0541B06F582308682041E2030CAD931562439F11C
...    7B027C62471E439F51CF9863CA1607038784FFF800003FFE0000016001C0AA3626EB04610D000002006185B24CA88873E238F20C7A067D813E01CF9863CA1607038782F5555
...    5553D555555416001C012587898001C4D000000160562E2600071300038980000042C0AC5C02000C260184C0001058158F804001C06000E03000713400001858158B8040018
...    020303600040B02B1F00800380C001C1B000E268000050B02B1700800303606130000C160561E010006130000E160561E0100060080010160561E0D800606C0012160561E01
...    00060180014160561E03000606C0016160562E0100060180C0D800302C0AC3C1B000E2600000D0B02B1713000309806008001C160563E2600061300C010181B0007858158B8
...    980018020303600100B02B1F134003836001C06000E030000110B0201200DC0068099000A02683A7484A14489B1CF871224489B1CF871224489B1CF871A2448913639F0E244
...    8913639F0E344891226C73E1C4891226C73E1C28913639F0E14489B1CF870A244D8E7C3851226C73E1C28913639F0E2448913639F0E14489B1CF871224489B1CF871A244891
...    3639F0E2448913639F0E344891226C73E180D890C6318C6318C6318C6318C60F413003E00281C1401C0C01D00E000C0480080C07C1200400000002001000000040000180200
...    000401000004008000030040000200200001401000802008020000180100000E008004000000100001000800009004000018020000280100001600800409024010000180672
...    A6B2A6B052B032B066B056B296F266F016B036B012B022B07681A0800004B29282000032CA4C080000CB29202000072CA480800024B292020000B2CA4C0800034B292020000
...    F2CA480800044B29202000132CA480800054B29202000172CA4A0800064B29202000062CA480669555D2AAAA55174AA2A82C55058AA0D154A62A93455018AA051549AAA83C5
...    0505E02540A05028140A05028140A05028140A05028140A050011080801002020040088040080101002004040080110080600A02004008080100230100C0140403005010020
...    04040080110080800A02020028080B01630100C01804030050100C018040080110080600A02018028080100210100C014040080108080600A02018028404030060100C01820
...    2018030080600A10100C014040300510080600A02018030080600A10100C018040080110080100202004008080600A30100200404008010100C014040300510080100202018
...    030080600C30100200404030050100C01804030051AA1F000102030406070A0B0C0D101112131418191B1C1D1F2125262728292A2D2F414182D0

#IGNB_CA_ATT_SA_REL    M55118C11008
${IGNB_CA_ATT_SA_REL}    M55118C11008
${IGNB_CA_ATT_3_SCELL_SA_SUCC}    M55118C11006

${NNGCC_UE_CTXT_REL_CMD_RECD}      M55125C00501
${NG_FLOW_REL_IANR_SUC_HO}      M55125C09015
${NF1CC_UE_CTXT_REL_CMP_RECD}      M55113C01010
${NE1CS_CTXT_REL_CMD_SENT}      M55135C00001
${NNGCC_UE_CTXT_REL_CMP_SENT}      M55125C00502

${NF1CC_UECTXT_STP_REQSENT}      M55113C01001
${NG_FLOW_STP_SUC_INC_HO}      M55125C09014

@{PM_Counters_Check_GNB1}
...    NRCELL-1:NCAC:${IGNB_CA_ATT_SA_REL}=1
...    NRCELL-1:NCAC:${IGNB_CA_ATT_3_SCELL_SA_SUCC}=1
...    NRCELL-1:NNGCC:${NG_FLOW_REL_IANR_SUC_HO}=1
...    NRCELL-1:NF1CC:${NF1CC_UE_CTXT_REL_CMP_RECD}=1
...    NRBTS-1:NE1CS:${NE1CS_CTXT_REL_CMD_SENT}=1

@{PM_Counters_Check_GNB2}
...    NRCELL-3:NNGCC:${NNGCC_UE_CTXT_REL_CMD_RECD}=1
...    NRCELL-3:NNGCC:${NNGCC_UE_CTXT_REL_CMP_SENT}=1
...    NRCELL-3:NF1CC:${NF1CC_UECTXT_STP_REQSENT}=1
...    NRCELL-3:NNGCC:${NG_FLOW_STP_SUC_INC_HO}=1

@{expect}
...    GNB-4: XpAP Link with GNB-2

${DU-to-CU-RRCInfo}    SEPARATOR=
...    100200c0000100c1400302000f00c240020100

${ExtDu-to-PrimeDu-RrcInf}    SEPARATOR=
...    0254042880b360631882D278E800984EF240000134B19501A82929C028806D00D6021B00842A03A0093F0C180651C32CC00CA8048FFFFF800
...    00008001D0821B90218000140B2902025100410200240400498118140D86A4330190C6562F88E54140198AA88008C006099500151E8836007
...    02010C4002A3D1068000B81808A200151E88340005C100431000A8F441A0102E0A0228800547A20D008104000001430C080C1016070590015
...    2C00000000400800301200CC17000C000004c8009e34038a340401000202200004c8009e3403880800000010580000070bfffd1020a80a261
...    63107ED167CB80042CDB40000019B193E8A81D29C028806B010A02190A20860C03286D9220064401B90018000080B29020251003F02002404
...    00498118140D484362194088512F08E54140188AA88008C00609D500070887F400E0402188001C221FB8005C0C045100038443F7000B82008
...    6200070887EE08170501144000E110FDC1020800000286181018202C0E0BA000E5000000001002000C04803305C0030000000280059f10082
...    320400000000002800554d80800800000013d0050a51451e52853253c5463857ffd1040a080a262631080D095C68036128D50000027319448
...    A81D29C028806B010A02190A20860C0328A79420064401B90018000080B2902025100400200240400498118140D484362194088512F08E541
...    40188AA88008C00609D5000E04881400E04021880038122038005C0C04510007024407000B8200862000E04880E08170501144001C09101C1
...    020800000286181018202C0E0BA001C5000000001002000C04803305C0030000001b8002573810232040000000001b8002302810008000000
...    13d0050a51451e52853253c546383ffe0


@{UE_expect}
...    sCellIndex 1,    physCellId 65
...    sCellIndex 2,    physCellId 63
...    sCellIndex 3,    physCellId 64

*** Test Cases ***
CB008140-ET-GH007_XN inter-freq ANR Handover outgoing to 3rd gnb in IgNB-CA mode TTFF to inter-gNB CA covBasedA1_rsrpCombined
    [Documentation]
    ...    [Configuration]:
    ...    Cell id=1 gnb=2 pci=16:2 tac=200 tdd_cell=on band=n77 nr_arfcn=663400:663400 gscn=8159 chBw=100MHz Cellid=0x4001
    ...    type0coresetconfigurationIn
    ...    Cell id=2 gnb=2 pci=17:0 tac=200 tdd_cell=on band=n77 nr_arfcn=658000:658000 gscn=8103 chBw=40MHz
    ...    Cell id=3 gnb=3 pci=17:1 tac=200 tdd_cell=on band=n77 nr_arfcn=653400:653400 gscn=8072 chBw=100MHz type0coresetconfigurationIndex=10
    ...    Cell id=4 gnb=3 pci=17:2 tac=200 tdd_cell=on band=n77 nr_arfcn=648000:648000 gscn=8000 chBw=40MHz SCellWeight=50
    ...    Cell id=11 gnb=3 pci=20:0 tac=200 tdd_cell=off band=n3 nr_arfcn=349400:368400 gscn=4605 chBw=10MHz SCellWeight=50 scs=15kHz
    ...    type0coresetconfigurationIndex=10
    ...    Cell id=12 gnb=3 pci=20:1 tac=200 tdd_cell=off band=n28 nr_arfcn=143400:153400 gscn=1916 chBw=15MHz SCellWeight=50 Cellid=0x800C/32780
    ...    Cell id=5 gnb=4 pci=21:0 tac=200 tdd_cell=off band=n3 nr_arfcn=349400:368400 gscn=4605 chBw=10MHz SCellWeight=50 Cellid=0x8C005/573445
    ...    Cell id=6 gnb=4 pci=21:1 tac=200 tdd_cell=off band=n28 nr_arfcn=143400:153400 gscn=1916 chBw=15MHz SCellWeight=50 Cellid=0x8C006/573446
    ...    set_cell id=7 gnb=4 pci=21:2 tac=200 nrci=0x07 tdd_cell=on proxy=10.0.2.92:9999 nr_arfcn=648000:648000 gscn=8000 nr_scs=30kHz
    ...    bs_channel_bandwidth=40MHz mandatory_for_activation=off
    ...    2.Test Case Steps:
    ...    a. UE1 Register And PDU Session Setup On Cell1_1,A1 To Trigger 4CC CA setup
    ...    b. UE1 trigger A2
    ...    c. UE1 trigger A3 Xn link with GNB2
    ...    d. UE1 trigger A2
    ...    e. UE1 trigger A3 handover from Cell1_1 to Cell3_3
    ...    3. Expected Results:
    ...    Step a: UE1 Register And PDU Session Setup Successful, covBasedA1 Add Cell5 Cell6 and Cell7 as Scell
    ...    counter IGNB_CA_ATT_3_SCELL_SA_SUCC
    ...    Step b: UE1 A2 trigger success and A3 measid 4
    ...    Step f: Xn link success
    ...    Step g: UE1 A2 trigger success and A3 measid 8
    ...    Step h: UE1 handover success
    ...    XnAP IgNBCAReleaseRequest counter:IGNB_CA_ATT_SA_REL
    ...    XnAP IgNBCAReleaseRequestAcknowledge
    [Tags]    GH007    QC_277932    CA_LABEL-TTFF (100MHz_TDD_n77+ 30MHz_FDD_n77+ 10MHz_FDD_n3+ 15MHz_FDD_n28)
    Delta Commission Parameters    ${DELETE_FOR_GNB1}
    Delta Commission Parameters Gnb2    ${DELETE_FOR_GNB2}
    Clear Counter Files for 2GNB
    Setup XpAP Link
    Set Sim gNB ignb CA Addition Param
    Ue Register And PDU Session Setup Without Scell Addition    ue_id=1
    UE Send A1 To Trigger 4CC CA setup
    Trigger Xnlink
    InterGnb InterFreq Handover From Phy50 to Phy52
    Release UEs    ue_type=all
    Check Counters    ${PM_Counters_Check_GNB1}
    Check Counters GNB2    ${PM_Counters_Check_GNB2}

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup 2Airphone Env    fddtdd_sansa_cmwv/6cells_gnb1_2T_gnb2_2T2F    ue_count=2

Modify Cfg
    ${gNB4_sim_configuration}    catenate
    ...    set_gnb id=4 type=simulated plmn=311:489 ng=10.0.1.125 gnb_id=0x23:22 daemon=10.0.2.1:22222 x2_peers=none xn=10.0.1.124
    ...    nssai=0x1:0xd143a5 amf=1 xp=10.0.1.124:32742 xpu=10.0.1.124:32742 xp_management=on
    Update Cfg    ${gNB4_sim_configuration}
    ${gNB4_Cell5_sim_configuration}    catenate
    ...    set_cell id=5 gnb=4 pci=21:0 tac=200 nrci=0x05 tdd_cell=off proxy=10.0.2.90:9999 nr_arfcn=349400:368400 gscn=4605
    ...    nr_scs=15kHz bs_channel_bandwidth=10MHz mandatory_for_activation=off
    Update Cfg    ${gNB4_Cell5_sim_configuration}
    ${gNB4_Cell6_sim_configuration}    catenate
    ...    set_cell id=6 gnb=4 pci=21:1 tac=200 nrci=0x06 tdd_cell=off proxy=10.0.2.91:9999 nr_arfcn=143400:153400 gscn=1916
    ...    nr_scs=15kHz bs_channel_bandwidth=15MHz mandatory_for_activation=off
    Update Cfg    ${gNB4_Cell6_sim_configuration}
    ${gNB4_Cell7_sim_configuration}    catenate
    ...    set_cell id=7 gnb=4 pci=21:2 tac=200 nrci=0x07 tdd_cell=on proxy=10.0.2.92:9999 nr_arfcn=648000:648000 gscn=8000
    ...    nr_scs=30kHz bs_channel_bandwidth=40MHz mandatory_for_activation=on
    Update Cfg    ${gNB4_Cell7_sim_configuration}
    Update Cfg    ue_param id=1 ue_nr_capabilities=${SA_Capa_Support_2CC_n77_n3_n28_n78_CA}

Clear Counter Files for 2GNB
    Clear Counter Files    ${False}
    Clear Counter Files GNB2

Perform Steps After Onair
    Get Correct Xp XgU Version

Get Correct Xp XgU Version
    ${IgNBCAXpProtocol_Version}    Get Xp Version
    ${IgNBCAXgUProtocol_Version}    Get Xgu Version
    Set Suite Variable    ${IgNBCAXpVersion}    ${IgNBCAXpProtocol_Version}
    Set Suite Variable    ${IgNBCAXgUVersion}    ${IgNBCAXgUProtocol_Version}

Setup XpAP Link
    Execute Egate Command    sim_trace enb=4 protocol=xp,xn on
    ${ret1}=    Execute Egate Command    enb_xp_param xp_peers=2 id=4    pass_regexp=${expect}    timeout=180s

Set Sim gNB ignb CA Addition Param
    ${gNB4_param}    catenate
    ...    gnb_param id=4 bwp_profile_id=1 bwp_profile_type=powersaving act_multiple_dedicated_bwps=yes location_bw_ul=1:2 location_bw_dl=3:4
    ...    Inter_gNB_CA_Allowed=yes CellLoadReportingPeriodicity=000 IgNBCAXpProtocolVersion=${IgNBCAXpVersion}
    ...    IgNBCAXgUProtocolVersion=${IgNBCAXgUVersion}
    Execute Egate Command    ${gNB4_param}
    Execute Egate Command    gnb_cell_param gnb=4 id=5 Cell_BWP_List=1,2 cell_Available=yes weightForSCellSelection=80 lteNrDssMode=lteNrDssModeNone
    Execute Egate Command    gnb_cell_param gnb=4 id=6 Cell_BWP_List=1,2 cell_Available=yes weightForSCellSelection=80 lteNrDssMode=lteNrDssModeNone
    Execute Egate Command    gnb_cell_param gnb=4 id=7 Cell_BWP_List=1,2 cell_Available=yes weightForSCellSelection=80 lteNrDssMode=lteNrDssModeNone
    Execute Egate Command    ignb_ca_configuration_update_indication_send id=4 target=2    pass_regexp=Sent to GNB-2
    ${gNB4_param_ca_addition}    catenate
    ...    ignb_ca_addition_param gnb_id=4 DU-to-CU-RRCInfo=${DU-to-CU-RRCInfo} ExtDu-to-PrimeDu-RrcInfo=${ExtDu-to-PrimeDu-RrcInf}
    Execute Egate Command    ${gNB4_param_ca_addition}

Ue Register And PDU Session Setup Without Scell Addition
    [Arguments]    ${ue_id}=1    ${gateway}=1    ${enb_id}=2    ${cell_id}=1
    Execute Egate Command    ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${gateway}    pass_regexp=QoS Routing Table
    ...    fail_regexp=activated successfully at airphone
    Sleep    5s    #wait

UE Send A1 To Trigger 4CC CA setup
    [Arguments]    ${ue_id}=1    ${scell1pci}=53    ${scell2pci}=60    ${scell3pci}=61
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=2 event=A1 srsrp_nr=32 srsrq_nr=32
    ...    pass_regexp=@{UE_expect}    timeout=20s

Trigger Xnlink
    Execute Egate Command    ue_measurement_send_nr id=1 meas_id=1 event=A2 srsrp_nr=30 srsrq_nr=30
    ...    pass_regexp=eventA3
    Sleep    1s    #wait
    Execute Egate Command    ue_measurement_send_nr id=1 meas_id=4 event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=52 nrsrp_nr=80 nrsrq_nr=80
    ...    pass_regexp=eventA2

InterGnb InterFreq Handover From Phy50 to Phy52
    Execute Egate Command    ue_measurement_send_nr id=1 meas_id=6 event=A2 srsrp_nr=30 srsrq_nr=30
    ...    pass_regexp=eventA3
    Sleep    1s    #wait
    Execute Egate Command    ue_measurement_send_nr id=1 meas_id=8 event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=52 nrsrp_nr=80 nrsrq_nr=80
    ...    pass_regexp=Inter-eNB handover from EXT_ENB-2.1 to EXT_ENB-3.3 performed
    Execute Egate Command    ue_disp state=ACTIVE    3.3
