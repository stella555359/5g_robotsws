*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_VRF    SBTS00    RAN_5G    RAN_5G_TDD    team-CN1ET    owner-zora.wang
...    CLOUD_5G_I_BOO_AP_LOO    CRT    CB007219    release-SBTS24R3
Resource    ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{cell_frequency}
...    @{1416}
...    @{7219}
...    @{MimoMode_Para}
...    @{CA_enable}
...    @{Scell_Rel}
...    @{CB007552_CB008541}
...    @{PScell_Switch_And_HO}

@{cell_frequency}
...    NRCELL-1:chBw=40MHz
...    NRCELL-2:chBw=40MHz
...    NRCELL-3:chBw=40MHz
...    NRCELL-3:nrarfcn=519000
...    NRCELL-3:gscnOrSsPbchArfcn=6462
...    NRCELL-3:type0CoresetConfigurationIndex=10
...    NRCELL-3:msg1FrequencyStart=20
...    NRBTS-1/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=96

@{7219}
...    NRBTS:actMfbiNrCaSupportFr1=true
...    NRBTS:actMfbiNrCaMeasConfResolv=false

@{1416}
...    NRBTS:actMultiFrequencyBandIndicatorNRSupport=true

...    NRCELL-1:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-2
...    NRCELL-1:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-2
...    NRCELL-2:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-2
...    NRCELL-2:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-2

...    NRCELL-3:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-3
...    NRCELL-3:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-3

...    NRCELL-13:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-1
...    NRCELL-13:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-1

...    NRCELL-14:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-1
...    NRCELL-14:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-1

...    NRBTS/NRCONNECTMODE_PROFILE-1:multiFreqBandIndicatorNR=25
...    NRBTS/NRCONNECTMODE_PROFILE-2:multiFreqBandIndicatorNR=77
...    NRBTS/NRCONNECTMODE_PROFILE-3:multiFreqBandIndicatorNR=41

...    NRBTS/NRMULTIBANDINFO_PROFILE-1:nrMultibandInfoList:nrBandPriority=1|freqBandIndicatorNR=2
...    NRBTS/NRMULTIBANDINFO_PROFILE-1:nrMultibandInfoList:nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1|freqBandIndicatorNR=2
...    NRBTS/NRMULTIBANDINFO_PROFILE-1:nrMultibandInfoList:nrBandPriority=2|freqBandIndicatorNR=25
...    NRBTS/NRMULTIBANDINFO_PROFILE-1:nrMultibandInfoList:nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1|freqBandIndicatorNR=25

...    NRBTS/NRMULTIBANDINFO_PROFILE-2:nrMultibandInfoList:nrBandPriority=1|freqBandIndicatorNR=78
...    NRBTS/NRMULTIBANDINFO_PROFILE-2:nrMultibandInfoList:nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1|freqBandIndicatorNR=78
...    NRBTS/NRMULTIBANDINFO_PROFILE-2:nrMultibandInfoList:nrBandPriority=2|freqBandIndicatorNR=77
...    NRBTS/NRMULTIBANDINFO_PROFILE-2:nrMultibandInfoList:nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1|freqBandIndicatorNR=77

...    NRBTS/NRMULTIBANDINFO_PROFILE-3:nrMultibandInfoList:nrBandPriority=1|freqBandIndicatorNR=38
...    NRBTS/NRMULTIBANDINFO_PROFILE-3:nrMultibandInfoList:nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1|freqBandIndicatorNR=38
...    NRBTS/NRMULTIBANDINFO_PROFILE-3:nrMultibandInfoList:nrBandPriority=2|freqBandIndicatorNR=41
...    NRBTS/NRMULTIBANDINFO_PROFILE-3:nrMultibandInfoList:nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1|freqBandIndicatorNR=41

...    NRBTS/NRNSPMAX_PROFILE-1:nrNsPmaxList:additionalSpectrumEmission=1
...    NRBTS/NRNSPMAX_PROFILE-1:nrNsPmaxList:nrNsPmaxPriority=1

@{CA_enable}
...    NRBTS-1:actCarrierAggregation=true
...    NRBTS-1:caConfigurationSupport=2CCDL_2CCUL
...    NRBTS-1:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS-1:actMeasBasedSCellAdditionNsa=true
...    NRCELL:maxNumScellsDlFr1=4
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRCELL:actK1Opt=intra-gNB
...    NRDU-1:carrierAggregationSupportList=${CAlist}
${CAlist}    ca_Fdd_Fr1Tdd_Sa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Any_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fdd_Any_Sa,ca_Fdd_Fdd,
...    ca_Fdd_Fr1Tdd_Nsa,ca_Fr1Tdd_Nsa,ca_Fr1Tdd_Fdd_Nsa

@{PScell_Switch_And_HO}
...    NRBTS:actInterFreqHoSA=true
...    NRBTS:actInterFreqIntraGnbMobilityNSA=true
...    NRPMRNL-1:miNrRelReportCu=5min
...    NRCELL:a1MeashoEnabled=rsrp
...    NRCELL:a1MeashoSsbRsrp:a1HysteresishoSsbRsrp=0|a1ThresholdhoSsbRsrp=40|a1TimeToTriggerhoSsbRsrp=ms64
...    NRCELL:a2MeashoEnabled=rsrp
...    NRCELL:a2MeashoSsbRsrp:a2HysteresishoSsbRsrp=0|a2ThresholdhoSsbRsrp=30|a2TimeToTriggerhoSsbRsrp=ms64
...    NRCELL:a3MeasEnabled=rsrp
...    NRCELL:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0|a3OffsetSsbRsrp=20|a3TimeToTriggerSsbRsrp=ms64
...    NRCELL:a5MeasEnabled=rsrp
...    NRCELL:a5MeasSsbRsrp:a5HysteresisSsbRsrp=0|a5Threshold1SsbRsrp=20|a5Threshold2SsbRsrp=40|a5TimeToTriggerSsbRsrp=ms64
...    NRCELL:sMeasConfigSsbRsrp=1
...    NRCELL:sCellDeactivationTimerGNB=infinity
#AB13
...    NRCELL-14/NRHOIF-1:a1BasedPCellSwitchEnabled=true
...    NRCELL-14/NRHOIF-1:thresholdPCellSwitchTargetRsrp=20
...    NRCELL-14/NRHOIF-1:thresholdPCellSwitchTargetRsrq=20
...    NRCELL-14/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-14/NRHOIF-1:freqBandIndicatorNR=38
...    NRCELL-14/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-14/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-14/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-14/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-14/NRHOIF-1:scs=30 KHz
...    NRCELL-14/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-14/NRHOIF-1:ssbFrequency=516990
...    NRCELL-14/NRHOIF-1:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-3
...    NRCELL-14:measGapSelectionSA=favourUeThroughput

...    NRCELL-3/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-3/NRHOIF-1:a2BasedPCellSwitchEnabled=true
...    NRCELL-3/NRHOIF-1:a2BasedPCellSwitchPriority=1
...    NRCELL-3/NRHOIF-1:thresholdPCellSwitchTargetRsrp=10
...    NRCELL-3/NRHOIF-1:thresholdPCellSwitchTargetRsrq=10
...    NRCELL-3/NRHOIF-1:freqBandIndicatorNR=2
...    NRCELL-3/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-3/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-3/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf5
...    NRCELL-3/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-3/NRHOIF-1:scs=15 KHz
...    NRCELL-3/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-3/NRHOIF-1:ssbFrequency=394370
...    NRCELL-3/NRHOIF-1:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-1
...    NRCELL-3:measGapSelectionSA=favourUeThroughput
...    NRCELL-3:a2MeasPCellSwitchEnabled=rsrp
...    NRCELL-3:a2MeasPCellSwitchSsbRsrp:a2HysteresisPCellSwitchSsbRsrp=0
...    NRCELL-3:a2MeasPCellSwitchSsbRsrp:a2ThresholdPCellSwitchSsbRsrp=70
...    NRCELL-3:a2MeasPCellSwitchSsbRsrp:a2TimeToTriggerPCellSwitchSsbRsrp=0ms
...    NRCELL-3:a2MeasPCellSwitchSsbRsrp:pCellSwitchOffsetSsbRsrp=5
...    NRCELL-3:a1MeasPCellSwitchEnabled=rsrp
...    NRCELL-3:a1MeasPCellSwitchSsbRsrp:a1HysteresisPCellSwitchSsbRsrp=0
...    NRCELL-3:a1MeasPCellSwitchSsbRsrp:a1ThresholdPCellSwitchSsbRsrp=40
...    NRCELL-3:a1MeasPCellSwitchSsbRsrp:a1TimeToTriggerPCellSwitchSsbRsrp=80ms
#AB12
...    NRCELL-13/NRHOIF-1:a1BasedPCellSwitchEnabled=true
...    NRCELL-13/NRHOIF-1:thresholdPCellSwitchTargetRsrp=20
...    NRCELL-13/NRHOIF-1:thresholdPCellSwitchTargetRsrq=20
...    NRCELL-13/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-13/NRHOIF-1:freqBandIndicatorNR=38
...    NRCELL-13/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-13/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-13/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-13/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-13/NRHOIF-1:scs=30 KHz
...    NRCELL-13/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-13/NRHOIF-1:ssbFrequency=648096
...    NRCELL-13/NRHOIF-1:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-2
...    NRCELL-13:measGapSelectionSA=favourUeThroughput

...    NRCELL-2/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-2/NRHOIF-1:a2BasedPCellSwitchEnabled=true
...    NRCELL-2/NRHOIF-1:a2BasedPCellSwitchPriority=1
...    NRCELL-2/NRHOIF-1:thresholdPCellSwitchTargetRsrp=10
...    NRCELL-2/NRHOIF-1:thresholdPCellSwitchTargetRsrq=10
...    NRCELL-2/NRHOIF-1:freqBandIndicatorNR=2
...    NRCELL-2/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-2/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-2/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf5
...    NRCELL-2/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-2/NRHOIF-1:scs=15 KHz
...    NRCELL-2/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-2/NRHOIF-1:ssbFrequency=390770
...    NRCELL-2/NRHOIF-1:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-1
...    NRCELL-2:measGapSelectionSA=favourUeThroughput
...    NRCELL-2:a2MeasPCellSwitchEnabled=rsrp
...    NRCELL-2:a2MeasPCellSwitchSsbRsrp:a2HysteresisPCellSwitchSsbRsrp=0
...    NRCELL-2:a2MeasPCellSwitchSsbRsrp:a2ThresholdPCellSwitchSsbRsrp=70
...    NRCELL-2:a2MeasPCellSwitchSsbRsrp:a2TimeToTriggerPCellSwitchSsbRsrp=0ms
...    NRCELL-2:a2MeasPCellSwitchSsbRsrp:pCellSwitchOffsetSsbRsrp=5
...    NRCELL-2:a1MeasPCellSwitchEnabled=rsrp
...    NRCELL-2:a1MeasPCellSwitchSsbRsrp:a1HysteresisPCellSwitchSsbRsrp=0
...    NRCELL-2:a1MeasPCellSwitchSsbRsrp:a1ThresholdPCellSwitchSsbRsrp=40
...    NRCELL-2:a1MeasPCellSwitchSsbRsrp:a1TimeToTriggerPCellSwitchSsbRsrp=80ms

@{Scell_Rel}
...    NRBTS:actHoOptimizationCa=true
...    NRCELL:a1MeasSCellAddEnabled=rsrp
...    NRCELL:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=85
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=75
...    NRCELL:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=80ms
...    NRCELL:a2MeasSCellRelEnabled=rsrp
...    NRCELL:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2ThresholdSCellRelSsbRsrp=34|a2TimeToTriggerSCellRelSsbRsrp=0ms
#AB14 AB15 NRREL
...    NRCELL-2/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-3:gNbId=1
...    NRCELL-2/NRREL-3:gNbIdLength=22
...    NRCELL-2/NRREL-3:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-3:removeNotAllowed=false
...    NRCELL-2/NRREL-3:lcrId=3
...    NRCELL-2/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-3:sCellOperationalMode=dlOnly
#AB13 NRREL
...    NRCELL-14/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-14/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-14/NRREL-3:gNbId=1
...    NRCELL-14/NRREL-3:gNbIdLength=22
...    NRCELL-14/NRREL-3:handoverAllowedSA=allowed
...    NRCELL-14/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-14/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-14/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-14/NRREL-3:removeNotAllowed=false
...    NRCELL-14/NRREL-3:lcrId=3
...    NRCELL-14/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-14/NRREL-3:sCellOperationalMode=dlOnly
...    NRCELL-3/NRREL-14:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-3/NRREL-14:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-3/NRREL-14:gNbId=1
...    NRCELL-3/NRREL-14:gNbIdLength=22
...    NRCELL-3/NRREL-14:handoverAllowedSA=allowed
...    NRCELL-3/NRREL-14:gnbPlmn:mnc=489
...    NRCELL-3/NRREL-14:gnbPlmn:mcc=311
...    NRCELL-3/NRREL-14:gnbPlmn:mncLength=3
...    NRCELL-3/NRREL-14:removeNotAllowed=false
...    NRCELL-3/NRREL-14:lcrId=14
...    NRCELL-3/NRREL-14:sCellAdditionMethod=covBasedA1
...    NRCELL-3/NRREL-14:sCellOperationalMode=dlOnly
#AB12 NRREL
...    NRCELL-13/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-13/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-13/NRREL-2:gNbId=1
...    NRCELL-13/NRREL-2:gNbIdLength=22
...    NRCELL-13/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-13/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-13/NRREL-2:removeNotAllowed=false
...    NRCELL-13/NRREL-2:lcrId=2
...    NRCELL-13/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-13/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-2/NRREL-13:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-13:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-13:gNbId=1
...    NRCELL-2/NRREL-13:gNbIdLength=22
...    NRCELL-2/NRREL-13:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-13:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-13:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-13:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-13:removeNotAllowed=false
...    NRCELL-2/NRREL-13:lcrId=13
...    NRCELL-2/NRREL-13:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-13:sCellOperationalMode=dlOnly

@{MimoMode_Para}
...    NRCELL:allowUnsuppBcOrBcs=complete BCS check
...    NRCELL:dlMimoMode=4x4 or 4x2 Closed Loop Spatial Multiplexing
...    NRCELL:nrCellType=4DL4UL

...    MRBTS-1/EQM-1/APEQM-1/RMOD-5/ANTL-3:antennaPathDelayDL=20
...    MRBTS-1/EQM-1/APEQM-1/RMOD-5/ANTL-3:antennaPathDelayUL=20
...    MRBTS-1/EQM-1/APEQM-1/RMOD-5/ANTL-3:antlId=3
...    MRBTS-1/EQM-1/APEQM-1/RMOD-5/ANTL-3:antPortId=3
...    MRBTS-1/EQM-1/APEQM-1/RMOD-5/ANTL-3:cIBAdvance=0
...    MRBTS-1/EQM-1/APEQM-1/RMOD-5/ANTL-3:cwaThreshold=215
...    MRBTS-1/EQM-1/APEQM-1/RMOD-5/ANTL-3:dcVoltage=OFF
...    MRBTS-1/EQM-1/APEQM-1/RMOD-5/ANTL-3:hdlcCommunicationAllowed=false
...    delete:MRBTS-1/EQM-1/APEQM-1/RMOD-5/ANTL-3:hdlcStartAddr
...    MRBTS-1/EQM-1/APEQM-1/RMOD-5/ANTL-3:totalLoss=3
...    MRBTS-1/EQM-1/APEQM-1/RMOD-5/ANTL-3:ulDelay=0
...    delete:MRBTS-1/EQM-1/APEQM-1/RMOD-5/ANTL-3:vswrAlarmTxPwrThreshold
...    MRBTS-1/EQM-1/APEQM-1/RMOD-5/ANTL-4:antennaPathDelayDL=20
...    MRBTS-1/EQM-1/APEQM-1/RMOD-5/ANTL-4:antennaPathDelayUL=20
...    MRBTS-1/EQM-1/APEQM-1/RMOD-5/ANTL-4:antlId=4
...    MRBTS-1/EQM-1/APEQM-1/RMOD-5/ANTL-4:antPortId=4
...    MRBTS-1/EQM-1/APEQM-1/RMOD-5/ANTL-4:cIBAdvance=0
...    MRBTS-1/EQM-1/APEQM-1/RMOD-5/ANTL-4:cwaThreshold=215
...    MRBTS-1/EQM-1/APEQM-1/RMOD-5/ANTL-4:dcVoltage=OFF
...    MRBTS-1/EQM-1/APEQM-1/RMOD-5/ANTL-4:hdlcCommunicationAllowed=false
...    delete:MRBTS-1/EQM-1/APEQM-1/RMOD-5/ANTL-4:hdlcStartAddr
...    MRBTS-1/EQM-1/APEQM-1/RMOD-5/ANTL-4:totalLoss=3
...    MRBTS-1/EQM-1/APEQM-1/RMOD-5/ANTL-4:ulDelay=0
...    delete:MRBTS-1/EQM-1/APEQM-1/RMOD-5/ANTL-4:vswrAlarmTxPwrThreshold

...    MRBTS-1/EQM-1/APEQM-1/RMOD-6/ANTL-3:antennaPathDelayDL=20
...    MRBTS-1/EQM-1/APEQM-1/RMOD-6/ANTL-3:antennaPathDelayUL=20
...    MRBTS-1/EQM-1/APEQM-1/RMOD-6/ANTL-3:antlId=3
...    MRBTS-1/EQM-1/APEQM-1/RMOD-6/ANTL-3:antPortId=3
...    MRBTS-1/EQM-1/APEQM-1/RMOD-6/ANTL-3:cIBAdvance=0
...    MRBTS-1/EQM-1/APEQM-1/RMOD-6/ANTL-3:cwaThreshold=215
...    MRBTS-1/EQM-1/APEQM-1/RMOD-6/ANTL-3:dcVoltage=OFF
...    MRBTS-1/EQM-1/APEQM-1/RMOD-6/ANTL-3:hdlcCommunicationAllowed=false
...    delete:MRBTS-1/EQM-1/APEQM-1/RMOD-6/ANTL-3:hdlcStartAddr
...    MRBTS-1/EQM-1/APEQM-1/RMOD-6/ANTL-3:totalLoss=3
...    MRBTS-1/EQM-1/APEQM-1/RMOD-6/ANTL-3:ulDelay=0
...    delete:MRBTS-1/EQM-1/APEQM-1/RMOD-6/ANTL-3:vswrAlarmTxPwrThreshold
...    MRBTS-1/EQM-1/APEQM-1/RMOD-6/ANTL-4:antennaPathDelayDL=20
...    MRBTS-1/EQM-1/APEQM-1/RMOD-6/ANTL-4:antennaPathDelayUL=20
...    MRBTS-1/EQM-1/APEQM-1/RMOD-6/ANTL-4:antlId=4
...    MRBTS-1/EQM-1/APEQM-1/RMOD-6/ANTL-4:antPortId=4
...    MRBTS-1/EQM-1/APEQM-1/RMOD-6/ANTL-4:cIBAdvance=0
...    MRBTS-1/EQM-1/APEQM-1/RMOD-6/ANTL-4:cwaThreshold=215
...    MRBTS-1/EQM-1/APEQM-1/RMOD-6/ANTL-4:dcVoltage=OFF
...    MRBTS-1/EQM-1/APEQM-1/RMOD-6/ANTL-4:hdlcCommunicationAllowed=false
...    delete:MRBTS-1/EQM-1/APEQM-1/RMOD-6/ANTL-4:hdlcStartAddr
...    MRBTS-1/EQM-1/APEQM-1/RMOD-6/ANTL-4:totalLoss=3
...    MRBTS-1/EQM-1/APEQM-1/RMOD-6/ANTL-4:ulDelay=0
...    delete:MRBTS-1/EQM-1/APEQM-1/RMOD-6/ANTL-4:vswrAlarmTxPwrThreshold

...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-7:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-7:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-8:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-8:direction=RX

...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-7:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-7:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-8:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-8:direction=RX

...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-7:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-7:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-8:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-8:direction=RX

...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-7:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-7:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-8:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-8:direction=RX

...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-5:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-5/ANTL-3
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-6:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-5/ANTL-3
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-6:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-7:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-5/ANTL-4
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-7:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-8:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-5/ANTL-4
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-8:direction=RX
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-5:resourceDN
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-6:resourceDN
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-7:resourceDN
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-8:resourceDN
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-5:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-6/ANTL-3
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-6:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-6/ANTL-3
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-6:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-7:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-6/ANTL-4
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-7:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-8:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-6/ANTL-4
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-8:direction=RX
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-5:resourceDN
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-6:resourceDN
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-7:resourceDN
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-8:resourceDN
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-13/CHANNELGROUP-1/CHANNEL-5:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-7/ANTL-3
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-13/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-13/CHANNELGROUP-1/CHANNEL-6:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-7/ANTL-3
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-13/CHANNELGROUP-1/CHANNEL-6:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-13/CHANNELGROUP-1/CHANNEL-7:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-7/ANTL-4
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-13/CHANNELGROUP-1/CHANNEL-7:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-13/CHANNELGROUP-1/CHANNEL-8:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-7/ANTL-4
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-13/CHANNELGROUP-1/CHANNEL-8:direction=RX
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-13/CHANNELGROUP-1/CHANNEL-5:resourceDN
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-13/CHANNELGROUP-1/CHANNEL-6:resourceDN
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-13/CHANNELGROUP-1/CHANNEL-7:resourceDN
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-13/CHANNELGROUP-1/CHANNEL-8:resourceDN
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-14/CHANNELGROUP-1/CHANNEL-5:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-8/ANTL-3
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-14/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-14/CHANNELGROUP-1/CHANNEL-6:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-8/ANTL-3
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-14/CHANNELGROUP-1/CHANNEL-6:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-14/CHANNELGROUP-1/CHANNEL-7:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-8/ANTL-4
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-14/CHANNELGROUP-1/CHANNEL-7:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-14/CHANNELGROUP-1/CHANNEL-8:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-8/ANTL-4
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-14/CHANNELGROUP-1/CHANNEL-8:direction=RX
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-14/CHANNELGROUP-1/CHANNEL-5:resourceDN
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-14/CHANNELGROUP-1/CHANNEL-6:resourceDN
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-14/CHANNELGROUP-1/CHANNEL-7:resourceDN
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-14/CHANNELGROUP-1/CHANNEL-8:resourceDN

@{CB007552_CB008541}
...    NRBTS:actMultipleDedicatedBWPs=true
...    NRCELL:actEnhMultipleDedicatedBWPs=true
...    NRBTS/BWP_PROFILE-7:bwpType=initial
...    NRBTS/BWP_PROFILE-7:locationAndBandwidthDl:cRbSizeDl=n51
...    NRBTS/BWP_PROFILE-7:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-7:locationAndBandwidthUl:cRbSizeUl=n51
...    NRBTS/BWP_PROFILE-7:locationAndBandwidthUl:cRbStartUl=crb0
...    NRBTS/BWP_PROFILE-7/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=3|searchSpaceId=1
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=1
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceId=1
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=1
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=2
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=3|searchSpaceId=3
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=3
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceId=3
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=3
...    NRBTS/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-8:bwpType=dedicated
...    NRBTS/BWP_PROFILE-8:locationAndBandwidthDl:cRbSizeDl=n106
...    NRBTS/BWP_PROFILE-8:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-8:locationAndBandwidthUl:cRbSizeUl=n106
...    NRBTS/BWP_PROFILE-8:locationAndBandwidthUl:cRbStartUl=crb0
...    NRBTS/BWP_PROFILE-8/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=3|searchSpaceId=4
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=4
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceId=4
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=4
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=5
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=3|searchSpaceId=6
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=6
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceId=6
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=6
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cceToRegMapping=nonInterleaved
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:coresetId=1
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cRbStart=0
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:duration=1
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:interleaverSize=none
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:regBundleSize=n6
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=96
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=0
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=0
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=0
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=0
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|coresetId=0
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=0
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=7|coresetId=0
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|coresetId=0
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=0
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|coresetId=1
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=1
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=1
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=1
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=1
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n4|coresetId=1
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=1
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=8|coresetId=1
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|coresetId=1
...    NRBTS/BWP_PROFILE-8/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=1
...    NRBTS/BWP_PROFILE-8/PDSCH-1:pdschRat0RbgConfig=config1
...    NRBTS/BWP_PROFILE-9:bwpType=dedicated
...    NRBTS/BWP_PROFILE-9:locationAndBandwidthDl:cRbSizeDl=n51
...    NRBTS/BWP_PROFILE-9:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-9:locationAndBandwidthUl:cRbSizeUl=n51
...    NRBTS/BWP_PROFILE-9:locationAndBandwidthUl:cRbStartUl=crb0
...    NRBTS/BWP_PROFILE-9/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=3|searchSpaceId=9
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=9
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceId=9
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=9
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=10
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=10
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=10
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=10
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=3|searchSpaceId=11
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=11
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceId=11
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=11
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cceToRegMapping=nonInterleaved
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:coresetId=4
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cRbStart=0
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:duration=1
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:interleaverSize=none
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:regBundleSize=n6
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=48
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=0
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=0
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=0
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=0
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|coresetId=0
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=0
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=12|coresetId=0
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|coresetId=0
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=0
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|coresetId=4
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=4
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=4
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=4
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=4
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|coresetId=4
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=4
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=13|coresetId=4
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|coresetId=4
...    NRBTS/BWP_PROFILE-9/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=4
...    NRBTS/BWP_PROFILE-9/PDSCH-1:pdschRat0RbgConfig=config1
...    NRCELL-3:cellBwpList:cellBwpId=0|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-7
...    NRCELL-3:cellBwpList:cellBwpId=1|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-8
...    NRCELL-3:cellBwpList:cellBwpId=2|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-9

...    NRCELL-13:gscnOrSsPbchArfcn=4885
...    NRCELL-13/NRCELL_FDD-1:nrarfcnDl=392000
...    NRCELL-13/NRCELL_FDD-1:nrarfcnUl=376000
...    NRBTS/BWP_PROFILE-10:bwpType=initial
...    NRBTS/BWP_PROFILE-10:locationAndBandwidthDl:cRbSizeDl=n79
...    NRBTS/BWP_PROFILE-10:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-10:locationAndBandwidthUl:cRbSizeUl=n79
...    NRBTS/BWP_PROFILE-10:locationAndBandwidthUl:cRbStartUl=crb0
...    NRBTS/BWP_PROFILE-10/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=1
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=1
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=1
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=1
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=2
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=3
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=3
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=3
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=3
...    NRBTS/BWP_PROFILE-10/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-11:bwpType=dedicated
...    NRBTS/BWP_PROFILE-11:locationAndBandwidthDl:cRbSizeDl=n106
...    NRBTS/BWP_PROFILE-11:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-11:locationAndBandwidthUl:cRbSizeUl=n106
...    NRBTS/BWP_PROFILE-11:locationAndBandwidthUl:cRbStartUl=crb0
...    NRBTS/BWP_PROFILE-11/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-11/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-11/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=4
...    NRBTS/BWP_PROFILE-11/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-11/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-11/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=4
...    NRBTS/BWP_PROFILE-11/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-11/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=4
...    NRBTS/BWP_PROFILE-11/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=4
...    NRBTS/BWP_PROFILE-11/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-11/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-11/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-11/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-11/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-11/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-11/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=5
...    NRBTS/BWP_PROFILE-11/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-11/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-11/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-11/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-11/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=6
...    NRBTS/BWP_PROFILE-11/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-11/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-11/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=6
...    NRBTS/BWP_PROFILE-11/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-11/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=6
...    NRBTS/BWP_PROFILE-11/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=6
...    NRBTS/BWP_PROFILE-11/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-11/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cceToRegMapping=nonInterleaved
...    NRBTS/BWP_PROFILE-11/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:coresetId=1
...    NRBTS/BWP_PROFILE-11/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cRbStart=0
...    NRBTS/BWP_PROFILE-11/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:duration=1
...    NRBTS/BWP_PROFILE-11/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:interleaverSize=none
...    NRBTS/BWP_PROFILE-11/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:regBundleSize=n6
...    NRBTS/BWP_PROFILE-11/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=96
...    NRBTS/BWP_PROFILE-11/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=0
...    NRBTS/BWP_PROFILE-11/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=0
...    NRBTS/BWP_PROFILE-11/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=0
...    NRBTS/BWP_PROFILE-11/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=0
...    NRBTS/BWP_PROFILE-11/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n4|coresetId=0
...    NRBTS/BWP_PROFILE-11/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=0
...    NRBTS/BWP_PROFILE-11/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=7|coresetId=0
...    NRBTS/BWP_PROFILE-11/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|coresetId=0
...    NRBTS/BWP_PROFILE-11/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=0
...    NRBTS/BWP_PROFILE-11/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|coresetId=1
...    NRBTS/BWP_PROFILE-11/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=1
...    NRBTS/BWP_PROFILE-11/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=1
...    NRBTS/BWP_PROFILE-11/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=1
...    NRBTS/BWP_PROFILE-11/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=1
...    NRBTS/BWP_PROFILE-11/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n4|coresetId=1
...    NRBTS/BWP_PROFILE-11/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=1
...    NRBTS/BWP_PROFILE-11/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=8|coresetId=1
...    NRBTS/BWP_PROFILE-11/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|coresetId=1
...    NRBTS/BWP_PROFILE-11/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=1
...    NRBTS/BWP_PROFILE-11/PDSCH-1:pdschRat0RbgConfig=config1
...    NRBTS/BWP_PROFILE-12:bwpType=dedicated
...    NRBTS/BWP_PROFILE-12:locationAndBandwidthDl:cRbSizeDl=n79
...    NRBTS/BWP_PROFILE-12:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-12:locationAndBandwidthUl:cRbStartUl=crb0
...    NRBTS/BWP_PROFILE-12:locationAndBandwidthUl:cRbSizeUl=n79
...    NRBTS/BWP_PROFILE-12/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=9
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=9
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=10
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=10
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=10
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=11
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=11
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cceToRegMapping=nonInterleaved
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:coresetId=4
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cRbStart=0
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:duration=1
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:interleaverSize=n3
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:regBundleSize=n2
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=78
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=0
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=0
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=0
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=0
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|coresetId=0
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=0
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=12|coresetId=0
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|coresetId=0
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=0
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|coresetId=4
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=4
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=4
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=4
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=4
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n3|coresetId=4
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=4
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=13|coresetId=4
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|coresetId=4
...    NRBTS/BWP_PROFILE-12/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=4
...    NRBTS/BWP_PROFILE-12/PDSCH-1:pdschRat0RbgConfig=config1
...    NRCELL-13:cellBwpList:cellBwpId=0|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-10
...    NRCELL-13:cellBwpList:cellBwpId=1|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-11
...    NRCELL-13:cellBwpList:cellBwpId=2|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-12

${DC_1A-3A-n38A-n78A_and_DC_1A-3A-n41A-n78A}    SEPARATOR=         #AB14_AB15_capa_nr
...    E9A09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C4701BB8D85181AC1184341020E9068036B64C558D0E7C
...    471E819F604F8C48E3C873EA39F30C7942C0E070F05C00FFC007003FF0005C0000E0541B107582308682041E20D00656C98AB121CFB027C471E3
...    1238F21CFA8E7CC31E50B0381C3C27FFC00001FFF00000170000381546C4DD608C21A0810748340165B262A86873E238F40CFB027C639F30C794
...    2C0E070F02E007FE003801FF8002E0000702A0D831AC1184341020F941A00CAD931562439F11C7B027C62471E439F51CF9863CA1607038784FFF
...    800003FFE000002E0000702B8D84BAC1184341020E9068036B64C558D0E7C471E819F604F8C48E3C873EA39F30C7942C0E070F05C00FFC007003
...    FF0005C0000E0551B133582308682041D20D00596C98AA1A1CF88E3D033EC09F18E7CC31E50B0381C3C0B801FF800E007FE000B80001C0A83623
...    6B04610D04083E5068032B64C55890E7C471EC09F1891C790E7D473E618F28581C0E1E13FFE00000FFF800000B80001C00378B850001C46000E2
...    30000000B0102F0F1040038980000042C040BC3C41000E268000020B01020120234028809B01060260BA101380E2448913639F0E14489B1CF870
...    A244D8E7C303818C630180F417001E00140E0A00E0601280380030120020301F02001000000008000010040000100200000C0100000800800005
...    0040000300200001C01000010043032B2A2B262B236B066B062B036B2A6B26680E0800004B29282000032CA4A0800014B29282000072CA4A0800
...    024B292820000B2CA4A0800034B292820000F2CA4A03A81D552AAAA4D5548F2A8365506AAA07954AB285801200340A0002100802004020040080
...    801002101002004040400208080100202020010D50F8000810182030385058606880889098A0C0C8D8E0E8F909293139414951697A0A0C1680

${Capa_LTE_DC_1A-3A-n38A-n78A_and_DC_1A-3A-n41A-n78A}    SEPARATOR=         #AB14_AB15_UE_capa
...    A11FF813C4C000389A001C25000000162205E260001C4D000E140000010B1102012023402800701060268BA000F40A24E8913639F0E24E891363
...    9F0C0038086303002200008040401803010080104000100808030060200C0180

${DC_66A_n5A-n25A-n41A-n38A}    SEPARATOR=         #AB12-13_capa_nr
...    E9A09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C4701BB8D85181AC1184341020E9068036B64C558D0E7
...    C471E819F604F8C48E3C873EA39F30C7942C0E070F05C00FFC007003FF0005C0000E0541B107582308682041E20D00656C98AB121CFB027C471
...    E31238F21CFA8E7CC31E50B0381C3C27FFC00001FFF00000170000381546C4DD608C21A0810748340165B262A86873E238F40CFB027C639F30C
...    7942C0E070F02E007FE003801FF8002E0000702A0D831AC1184341020F941A00CAD931562439F11C7B027C62471E439F51CF9863CA160703878
...    4FFF800003FFE000002E0000702B8D84BAC1184341020E9068036B64C558D0E7C471E819F604F8C48E3C873EA39F30C7942C0E070F05C00FFC0
...    07003FF0005C0000E0551B133582308682041D20D00596C98AA1A1CF88E3D033EC09F18E7CC31E50B0381C3C0B801FF800E007FE000B80001C0
...    A83600EB04610D04083E5068032B64C55890E7C471EC09F1891C790E7D473E618F28581C0E1E13FFE00000FFF800000B80001C00378B850001C
...    46000E230000000B0102F0F1040038980000042C040BC3C41000E268000020B01020120234028809B01060260BA101380E2448913639F0E1448
...    9B1CF870A244D8E7C303818C630180F417001E00140E0A00E0601280380030120020301F02401000000008000010040000100200000C0100000
...    8008000050040000300200001C010000100080000902581959195931591B58335831581B5953593358134080400002594941000019652504000
...    0A594941000039652504000125949410000596525040001A594941000079652504000225949408503AAA555549AAA91E5506CAA0D5540F2A856
...    5502CA16004800D0280008402008010080100202004008404008010101000820200400808080043543E00020406080C0E1416181A2022242628
...    303236383A3E424A4C4E5052545A5E828305A0

${Capa_LTE_DC_n25A-n38A_and_n25A-n41A}    SEPARATOR=         #AB13_UE11_capa
...    A11FF813C4D0403830001C25000000162205E268201C18000E140000010B1102012023402800701060268BA000F40A24E8913639F0E24E891
...    3639F0C003808630300220000804040380101004010400010080807002020240180

${Capa_LTE_DC_n25A-n38A_and_n25A-n41A_and_no_UL_in_n38}    SEPARATOR=         #AB13_UE12_capa
...    A11FF813C4D04038300018250000058881789A08070600038500000042C440804808D00A001C041809A2E8003D02893A244D8E7C3893A244
...    D8E7C3000E0218C0C00880002010100E0040401000100004020201C00808090060

${Capa_LTE_DC_n25A-n38A_and_n25A-n41A_and_no_UL_in_n38-n41}    SEPARATOR=         #AB13_UE13_capa
...    A11FF813C4D04038300018250000058881789A080706000305000010B1102012023402800701060268BA000F40A24E8913639F0E24E89136
...    39F0C00380863030022000080404038010100400040001008080700202024000
${Capa_LTE_DC_n2A-n77A_and_n25A-n77A}    SEPARATOR=         #AB12_UE11_capa DC_66A_n2A-n5A-n66A-n77A_and_DC_66A_n5A-n25A-n66A-n77A
...    A11FF813C4D0403802001C4C000000162205E268201C18000E260000010B1102012023402800701060268BA000F40A24E8913639F0E24E891
...    3639F0C00380863030022000080404050090100600C40001008080700E0200C0180

${Capa_LTE_DC_n2A-n77A_and_n25A-n77A_and_no_UL_in_n2}    SEPARATOR=         #AB12_UE12_capa
...    A11FF813C4D04030020713000000058881789A08070600038980000042C440804808D00A001C041809A2E8003D02893A244D8E7C3893A244D
...    8E7C3000E0218C0C0088000201010140000401803100004020201C03808030060

${Capa_LTE_DC_n2A-n77A_and_n25A-n77A_and_no_UL_in_n2-n25}    SEPARATOR=         #AB12_UE13_capa
...    A11FF813C4D04030020713000000058881789A08060600E260000010B1102012023402800701060268BA000F40A24E8913639F0E24E891363
...    9F0C00380863030022000080404050000100600C4000100808070000200C018

${Capa_LTE_DC_n25A-n78A}    SEPARATOR=         #AB12_UE14_capa    DC_66A_n5A-n25A-n66A-n78A
...    A11FF80BC4D0403830001C4D000000162204024046805000E020C04D174001080C49D1226C73E1805008C600040001008080700E0200C018

@{pm_couter_AB12}
...    NRCELL-13:${SGNB_NSA_ADMISSION_MFBI_REQ}=0
...    NRCELL-13:${SGNB_NSA_ADMISSION_MFBI_SUCC}=0
...    NRCELL-13:${SGNB_DU_NSA_ADMISS_MFBI_REQ}=1
...    NRCELL-13:${SGNB_DU_NSA_ADMISS_MFBI_SUCC}=1
...    NRCELL-13:${SCELL_CONF_ALT_BAND_NSA}=6
...    NRCELL-13:${SGNB_NSA_HO_ADMISS_MFBI_REQ}=1
...    NRCELL-13:${SGNB_NSA_HO_ADMISS_MFBI_SUCC}=1

...    NRCELL-2:${SGNB_NSA_ADMISSION_MFBI_REQ}=3
...    NRCELL-2:${SGNB_NSA_ADMISSION_MFBI_SUCC}=3
...    NRCELL-2:${SGNB_DU_NSA_ADMISS_MFBI_REQ}=5
...    NRCELL-2:${SGNB_DU_NSA_ADMISS_MFBI_SUCC}=5
...    NRCELL-2:${SCELL_CONF_ALT_BAND_NSA}=2
...    NRCELL-2:${SGNB_NSA_HO_ADMISS_MFBI_REQ}=2
...    NRCELL-2:${SGNB_NSA_HO_ADMISS_MFBI_SUCC}=2

@{pm_couter_AB13}
...    NRCELL-3:${SGNB_NSA_ADMISSION_MFBI_REQ}=0
...    NRCELL-3:${SGNB_NSA_ADMISSION_MFBI_SUCC}=0
...    NRCELL-3:${SGNB_DU_NSA_ADMISS_MFBI_REQ}=1
...    NRCELL-3:${SGNB_DU_NSA_ADMISS_MFBI_SUCC}=1
...    NRCELL-3:${SCELL_CONF_ALT_BAND_NSA}=5
...    NRCELL-3:${SGNB_NSA_HO_ADMISS_MFBI_REQ}=1
...    NRCELL-3:${SGNB_NSA_HO_ADMISS_MFBI_SUCC}=1

...    NRCELL-14:${SGNB_NSA_ADMISSION_MFBI_REQ}=3
...    NRCELL-14:${SGNB_NSA_ADMISSION_MFBI_SUCC}=3
...    NRCELL-14:${SGNB_DU_NSA_ADMISS_MFBI_REQ}=5
...    NRCELL-14:${SGNB_DU_NSA_ADMISS_MFBI_SUCC}=5
...    NRCELL-14:${SCELL_CONF_ALT_BAND_NSA}=2
...    NRCELL-14:${SGNB_NSA_HO_ADMISS_MFBI_REQ}=2
...    NRCELL-14:${SGNB_NSA_HO_ADMISS_MFBI_SUCC}=2

@{pm_couter_AB14_AB15}
...    NRCELL-2:${SGNB_NSA_ADMISSION_MFBI_REQ}=0
...    NRCELL-2:${SGNB_NSA_ADMISSION_MFBI_SUCC}=0
...    NRCELL-2:${SGNB_DU_NSA_ADMISS_MFBI_REQ}=0
...    NRCELL-2:${SGNB_DU_NSA_ADMISS_MFBI_SUCC}=0
...    NRCELL-2:${SCELL_CONF_ALT_BAND_NSA}=0
...    NRCELL-3:${SCELL_CONF_ALT_BAND_NSA}=2

${SCELL_CONF_ALT_BAND_NSA}    M55316C00042    #This counter provides the number of current cell configurations as an NSA
#SCell in an alternative band.
${SGNB_NSA_ADMISSION_MFBI_REQ}    M55114C00501    #The number of radio admission requests for NSA user when admission is requested on the
#alternative band. Updated to the strongest PS-Cell (on alternative band) in the selected cell group (DU) in case of multiple PS-Cell candidates.
${SGNB_NSA_ADMISSION_MFBI_SUCC}    M55114C00502    #This counter provides the number of admitted NSA users when radio admission is done on the
#alternative band. Updated to the strongest PS-Cell (on alternative band) in the selected cell group (DU) in case of multiple PS-Cell candidates.
${SGNB_DU_NSA_ADMISS_MFBI_REQ}    M55115C01501    #This counter provides the number of radio admission requests with MFBI for the NSA user.
#Updated to the PS-Cell in the DU whenever CP-RT receives radio admission request for UE Context Setup or UE Context Modification request.
${SGNB_DU_NSA_ADMISS_MFBI_SUCC}    M55115C01502    #This counter provides the number of radio admitted NSA users with alternative band.
#Updated to the PS-Cell in the DU whenever CP-RT makes successful radio admission for UE Context Setup or UE Context Modification request.
${SGNB_NSA_HO_ADMISS_MFBI_REQ}    M55114C00503    #The number of radio admission requests for handover for NSA user where admission is requested on
#the alternative band.Updated to the strongest PS-Cell(on alternative band) in the selected cell group (DU) in case of multiple PS-Cell candidates
${SGNB_NSA_HO_ADMISS_MFBI_SUCC}    M55114C00504    #The number of admitted NSA users for handovers where radio admission is done on the alternative
#band. Updated to the strongest PS-Cell (on alternative band) in the selected cell group (DU) in case of multiple PS-Cell candidates.

@{nsa_ue_attach_expect}
...    pcid:51, scellIdx:8
...    freqBandIndicatorNR 78
...    Successfully reconfigured dual connectivity
...    reported successful RA

@{nsa_ue_A1_scellAdd_N38_expect}
...    pcid:51, scellIdx:8
...    pcid:52, scellIdx:9
...    freqBandIndicatorNR 38
...    SCellIndex 9 activated successfully at airphone
...    Successfully reconfigured dual connectivity

@{nsa_ue_A1_scellAdd_N41_expect}
...    pcid:51, scellIdx:8
...    pcid:52, scellIdx:9
...    freqBandIndicatorNR 41
...    SCellIndex 9 activated successfully at airphone
...    Successfully reconfigured dual connectivity

@{Deactivate_CB007219}
...    NRBTS:actMfbiNrCaSupportFr1=false

@{add_alternative_band_n41_for_cell3}
...    NRCELL-3:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-3
...    NRCELL-3:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-3

@{delete_alternative_band_n41_for_cell3}
...    delete:NRCELL-3:nrConnectModeProfileDN
...    delete:NRCELL-3:nrMultibandInfoProfileDN

@{nsa_ue_attach_AB13}
...    pcid:63, scellIdx:8
...    freqBandIndicatorNR 25
...    subcarrierSpacing kHz15
...    carrierBandwidth 106    #20MHZ
...    a1-Threshold rsrp : 75    #A1 for scell add is configured
...    Successfully reconfigured dual connectivity
...    reported successful RA

@{nsa_ue_A1_scellAdd_N41_AB13}
...    pcid:63, scellIdx:8
...    pcid:52, scellIdx:9
...    freqBandIndicatorNR 41
...    subcarrierSpacing kHz30
...    carrierBandwidth 106    #40MHZ
...    a1-Threshold rsrp : 40    #A1 for pcell change is configured
...    SCellIndex 9 activated successfully at airphone
...    Successfully reconfigured dual connectivity

@{A1_Pscell_Change_N25_N38_AB13}
...    pcid:52, scellIdx:8
...    pcid:63, scellIdx:9
...    freqBandIndicatorNR 25
...    freqBandIndicatorNR 38
...    subcarrierSpacing kHz15
...    carrierBandwidth 106    #20MHZ
...    subcarrierSpacing kHz30
...    carrierBandwidth 51    #20MHZ
...    a2-Threshold rsrp : 70    #A2 for pcell change is configured
...    SgNBModificationConfirm
...    SCellIndex 9 activated successfully at airphone

@{A2_Pcell_Change_N25_N41_AB13}
...    pcid:63, scellIdx:8
...    pcid:52, scellIdx:9
...    freqBandIndicatorNR 25
...    freqBandIndicatorNR 41
...    subcarrierSpacing kHz15
...    carrierBandwidth 106    #20MHZ
...    subcarrierSpacing kHz30
...    a1-Threshold rsrp : 40    #A1 for pcell change is configured
...    SgNBModificationConfirm
...    SCellIndex 9 activated successfully at airphone

@{A1_Pscell_Change_N25_N41_AB13}
...    pcid:52, scellIdx:8
...    pcid:63, scellIdx:9
...    freqBandIndicatorNR 25
...    freqBandIndicatorNR 41
...    subcarrierSpacing kHz15
...    carrierBandwidth 106    #20MHZ
...    subcarrierSpacing kHz30
...    a2-Threshold rsrp : 70    #A2 for pcell change is configured
...    SgNBModificationConfirm
...    SCellIndex 9 activated successfully at airphone

@{nsa_ue13_A1_scellAdd_N41_AB13}
...    pcid:63, scellIdx:8
...    pcid:52, scellIdx:9
...    freqBandIndicatorNR 41
...    subcarrierSpacing kHz30
...    carrierBandwidth 106    #40MHZ
...    SCellIndex 9 activated successfully at airphone
...    Successfully reconfigured dual connectivity

@{nsa_ue_attach_AB12}
...    pcid:51, scellIdx:8
...    freqBandIndicatorNR 77
...    subcarrierSpacing kHz30
...    carrierBandwidth 106    #40MHZ
...    a1-Threshold rsrp : 85    #A1 for scell add is configured
...    Successfully reconfigured dual connectivity
...    reported successful RA

@{nsa_ue_A1_scellAdd_N25_AB12}
...    pcid:51, scellIdx:8
...    pcid:62, scellIdx:9
...    freqBandIndicatorNR 25
...    subcarrierSpacing kHz15
...    carrierBandwidth 106    #20MHZ
...    a2-Threshold rsrp : 70    #A2 for pcell change is configured
...    SCellIndex 9 activated successfully at airphone
...    Successfully reconfigured dual connectivity

@{A2_Pcell_Change_N2_N77_AB12}
...    pcid:62, scellIdx:8
...    pcid:51, scellIdx:9
...    freqBandIndicatorNR 2
...    freqBandIndicatorNR 77
...    subcarrierSpacing kHz15
...    carrierBandwidth 79    #15MHZ
...    subcarrierSpacing kHz30
...    carrierBandwidth 106    #40MHZ
...    a1-Threshold rsrp : 40    #A1 for pcell change is configured
...    SgNBModificationConfirm
...    SCellIndex 9 activated successfully at airphone

@{A1_Pscell_Change_N25_N77_AB12}
...    pcid:51, scellIdx:8
...    pcid:62, scellIdx:9
...    freqBandIndicatorNR 25
...    freqBandIndicatorNR 77
...    subcarrierSpacing kHz15
...    carrierBandwidth 106    #20MHZ
...    subcarrierSpacing kHz30
...    a2-Threshold rsrp : 70    #A2 for pcell change is configured
...    SgNBModificationConfirm
...    SCellIndex 9 activated successfully at airphone

@{A2_Pscell_Change_N25_N77_AB12}
...    pcid:62, scellIdx:8
...    pcid:51, scellIdx:9
...    freqBandIndicatorNR 25
...    freqBandIndicatorNR 77
...    subcarrierSpacing kHz15
...    carrierBandwidth 106    #20MHZ
...    subcarrierSpacing kHz30
...    a1-Threshold rsrp : 40    #A1 for pcell change is configured
...    SgNBModificationConfirm
...    SCellIndex 9 activated successfully at airphone

@{nsa_ue13_A1_scellAdd_N25_AB12}
...    pcid:51, scellIdx:8
...    pcid:62, scellIdx:9
...    freqBandIndicatorNR 25
...    subcarrierSpacing kHz15
...    carrierBandwidth 106    #20MHZ
...    SCellIndex 9 activated successfully at airphone
...    Successfully reconfigured dual connectivity

@{nsa_ue_attach_AB12_UE14}
...    pcid:51, scellIdx:8
...    freqBandIndicatorNR 78
...    subcarrierSpacing kHz30
...    carrierBandwidth 106    #40MHZ
...    a1-Threshold rsrp : 85    #A1 for scell add is configured
...    Successfully reconfigured dual connectivity
...    reported successful RA

@{nsa_ue_attach_AB12_UE14_no_A1}
...    pcid:51, scellIdx:8
...    subcarrierSpacing kHz30
...    carrierBandwidth 106    #40MHZ
...    Successfully reconfigured dual connectivity
...    reported successful RA

*** Test Cases ***
CB007219-ET-AB12_Verify MFBI NSA CA Interaction with A2 based PSCell change
    [Documentation]
    ...    1. Purpose:This user scenario describes the SgNB behavior, when a UE for which carrier aggregation is configured
    ...      and at least one SCell is configured in alternative band. In addition, A2 measurement is enabled on PSCell in
    ...      order to trigger PSCell change and UE sends A2 measurement report for PSCell. 5G_RAN_USR_RRM_20962
    ...    2. Configuration
    ...    a.NRCELL-13 FDD native:N2 alternative:N25; 20Mhz, small bwp:15MHZ; DL MIMO Layers: 4L
    ...    NRCELL-2 TDD native:N78 alternative:N77 40Mhz dlmimo: 4x4 or 4x2 Closed Loop Spatial Multiplexing
    ...    b.5GC001416 enable:actMultiFrequencyBandIndicatorNRSupport=true; CB007219:actMfbiNrCaSupportFr1 set to true.
    ...    c.ue capability:
    ...     UE11 capability: LTE cell1 + NR cell-2 + NR cell-13, A1 scell addition
    ...    BC#1:DC_66A_n2A-n5A-n66A-n77A n2    n77
    ...    DL FSEI#1    DL MIMO layers    4L    2L
    ...                 DL ChBw (MHz)     15    40
    ...                 UL MIMO layers    4L    2L
    ...                 UL ChBw (MHz)     15    40
    ...    BC#2:DC_66A_n5A-n25A-n66A-n77A n25    n77
    ...    DL FSEI#1    DL MIMO layers    4L    2L
    ...                 DL ChBw (MHz)     20    40
    ...                 UL MIMO layers    4L    2L
    ...                 UL ChBw (MHz)     20    40
    ...    UE12 capability:the same as UE11 but UE has UL capability in band n25, not in band n2,
    ...         nr : {
    ...         bandNR 2,
    ...         ca-BandwidthClassDL-NR a
    ...               },
    ...    UE13 capability:the same as UE11 but UE does not have UL capability in band n2 and n25
    ...         nr : {
    ...         bandNR 2,
    ...         ca-BandwidthClassDL-NR a
    ...               },
    ...         nr : {
    ...         bandNR 25,
    ...         ca-BandwidthClassDL-NR a
    ...               },
    ...    UE14 capability: LTE cell1 + NR cell-2 + NR cell-13, A1 scell addition
    ...    BC#1:DC_66A_n5A-n25A-n66A-n78A n25    n78
    ...    DL FSEI#1    DL MIMO layers    4L    2L
    ...                 DL ChBw (MHz)    20    40
    ...                 UL MIMO layers    4L    2L
    ...                 UL ChBw (MHz)     20    40
    ...    3. Test Case Steps:
    ...    a.UE11 attach to LTE1 cell1 NRCELL-2.traffic should ok.Then A1 add cell 13 as scell.traffic should ok.
    ...      Then BC2#FS1(N25_N77) selected. larger aggregated DL BW according to CB008015
    ...      A2 PCell change to cell 13 ,and the signal meet for scell addition,cell 2 add as scell.BC1#FS1(N2_N77) selected. if UE support
    ...               PCell natvie band,UE always select it.
    ...      A1 PCell change to cell 2 ,and the signal meet for scell addition,cell 13 add as scell.BC2#FS1(N25_N77) selected.
    ...               larger aggregated DL BW according to CB008015
    ...    b.UE12 attach to LTE1 cell1 NRCELL-2.traffic should ok.Then A1 add cell 13 as scell.traffic should ok.
    ...      Then BC2#FS1(N25_N77) selected. larger aggregated DL BW according to CB008015
    ...      A2 PCell change to cell 13 ,and the signal meet for scell addition,cell 2 add as scell.BC2#FS1(N25_N77) selected.if UE support
    ...               PCell natvie band,UE always select it. but here UE does not suppor N2 UL, so still use N25.
    ...      A1 PCell change to cell 2 ,and the signal meet for scell addition,cell 13 add as scell.BC2#FS1(N25_N77) selected.
    ...               larger aggregated DL BW according to CB008015
    ...    c.UE13 attach to LTE1 cell1 NRCELL-2.traffic should ok.Then A1 add cell 13 as scell.traffic should ok.
    ...      Then BC2#FS1(N25_N77) selected.no A1 for pcell change is configured. because N25 and N2 cannot be Pcell, no pcell change.
    ...    d.UE14 attach to LTE1 cell1 NRCELL-2.traffic should ok. Online change 7219 from true to false,A1 will be discard and no scell addition.
    ...      online change 7219 from false to true.Then A1 add cell 13 as scell.BC1#FS1(N25_N78) selected.traffic should ok.
    ...      Online change 7219 from true to false,release scell13 for UE14,scell release successfully,but no A1 for scell additon is configured.
    ...               without CB007129, CA not support alternative band.
    ...      release UE14.UE14 attach to LTE1 cell1 NRCELL-2(N78).traffic should ok. but no A1 for scell addition is configured.
    ...    e.check counter.
    [Tags]    CA_LABEL-TF(40MHZ_TDD_n77+20MHZ_FDD_n25)    CA_LABEL-TF(40MHZ_TDD_n77+15MHZ_FDD_n2)    CA_LABEL-TF(40MHZ_TDD_n78+20MHZ_FDD_n25)
    ...    QC_322181    AB12
    clear counter files    wait=${False}
    UE attach and PSchange by A2 and A1    ue_mrdc_cap=${Capa_LTE_DC_n2A-n77A_and_n25A-n77A}    A1_Pscell=${A1_Pscell_Change_N25_N77_AB12}
    ...    A2_Pscell=${A2_Pcell_Change_N2_N77_AB12}
    UE attach and PSchange by A2 and A1    ue_id=12    ue_mrdc_cap=${Capa_LTE_DC_n2A-n77A_and_n25A-n77A_and_no_UL_in_n2}
    ...    A1_Pscell=${A1_Pscell_Change_N25_N77_AB12}    A2_Pscell=${A2_Pscell_Change_N25_N77_AB12}
    UE13 attch and A1 scell add and pcell change should not config    target_cell=2    carrierfreq=648096    p_dl=240
    ...    ue_mrdc_cap=${Capa_LTE_DC_n2A-n77A_and_n25A-n77A_and_no_UL_in_n2-n25}    pass_AT=${nsa_ue_attach_AB12}
    ...    pass_CA=${nsa_ue13_A1_scellAdd_N25_AB12}    ret_not_cont=a2-Threshold rsrp : 70
    UE14 attach and scell add with feature on
    UE14 attach and scell should not config with feature off
    check counters    pm_counters_expression=${pm_couter_AB12}
    [Teardown]    AB15_Teardown

CB007219-ET-AB13_Verify MFBI NSA CA Interaction with A1 measurement based PSCell switch
    [Documentation]
    ...    1. Purpose:This user scenario describes the SgNB behaviour when a UE has been configured with CA using MFBI
    ...      Cells and A1 measurement based PSCell switch is enabled. 5G_RAN_USR_RRM_20967
    ...    2. Configuration
    ...    a.NRCELL-14 FDD native:N2 alternative:N25; 20Mhz; DL MIMO Layers: 4L
    ...    NRCELL-3 TDD native:N38 alternative:N41; 40Mhz, small bwp:20MHZ; DL MIMO Layers: 4L
    ...    b.5GC001416 enable:actMultiFrequencyBandIndicatorNRSupport=true; CB007219:actMfbiNrCaSupportFr1 set to true.
    ...    c.ue capability:UE11 capability: LTE cell1 + NR cell14+NR cell3, A1 scell addition
    ...    BC#1:DC_66A_n5A-n25A-n66A-n38A n25    n38
    ...    DL FSEI#1    DL MIMO layers    4L    2L
    ...                 DL ChBw (MHz)     20    20
    ...                 UL MIMO layers    2L    4L
    ...                 UL ChBw (MHz)     20    20
    ...    BC#2:DC_66A_n5A-n25A-n66A-n41A n25    n41
    ...    DL FSEI#1    DL MIMO layers    4L    4L
    ...                  DL ChBw (MHz)    20    40
    ...                 UL MIMO layers    2L    2L
    ...                 UL ChBw (MHz)     20    40
    ...    UE12 capability: the same as UE11 but UE has UL capability in band n25 and n41, not in band n38
    ...             nr : {
    ...                   bandNR 38,
    ...                   ca-BandwidthClassDL-NR a }
    ...    UE13 capability: the same as UE11 but UE has UL capability in band n25, but not in band n41 and n38
    ...             nr : {
    ...                   bandNR 38,
    ...                   ca-BandwidthClassDL-NR a }
    ...             nr : {
    ...                   bandNR 41,
    ...                   ca-BandwidthClassDL-NR a }
    ...    3. Test Case Steps:
    ...    a.UE11 attach to LTE1 cell1 NRCELL-14.traffic should ok.Then A1 add cell 3 as scell.traffic should ok.
    ...      Then BC2#FS1(N25_N41) selected. larger aggregated DL BW according to CB008015
    ...      A1 PCell change to cell 3 ,and the signal meet for scell addition,cell 14 add as scell.BC1#FS1(N25_N38) selected.if UE support
    ...               PCell natvie band,UE always select it. N38 is native
    ...      A2 PCell change to cell 14 ,and the signal meet for scell addition,cell 3 add as scell.BC2#FS1(N25_N41) selected.
    ...               larger aggregated DL BW according to CB008015
    ...    b.UE12 attach to LTE1 cell1 NRCELL-14.traffic should ok.Then A1 add cell 3 as scell.traffic should ok.
    ...      Then BC2#FS1(N25_N41) selected.larger aggregated DL BW according to CB008015
    ...      A1 PCell change to cell 3 ,and the signal meet for scell addition,cell 14 add as scell.BC2#FS1(N25_N41) selected.if UE support
    ...               PCell natvie band,UE always select it. N38 is native.but UE not support N38 UL. so still use N41
    ...      A2 PCell change to cell 14 ,and the signal meet for scell addition,cell 3 add as scell.BC2#FS1(N25_N41) selected.
    ...    c.UE13 attach to LTE1 cell1 NRCELL-14.traffic should ok.Then A1 add cell 3 as scell.traffic should ok.
    ...      Then BC2#FS1(N25_N41) selected.no A1 for pcell change is configured in n41 due to scell cannot be Pcell ,lack of UL capability.
    ...    d.check counter.
    [Tags]    QC_322201    AB13    CA_LABEL-FT(20MHZ_FDD_n25+20MHZ_TDD_n38)    CA_LABEL-FT(20MHZ_FDD_n25+40MHZ_TDD_n41)
    clear counter files
    UE attach and PSchange by A1 and A2    ue_mrdc_cap=${Capa_LTE_DC_n25A-n38A_and_n25A-n41A}    A1_Pscell=${A1_Pscell_Change_N25_N38_AB13}
    ...    A2_Pscell=${A2_Pcell_Change_N25_N41_AB13}
    UE attach and PSchange by A1 and A2    ue_id=12    ue_mrdc_cap=${Capa_LTE_DC_n25A-n38A_and_n25A-n41A_and_no_UL_in_n38}
    ...    A1_Pscell=${A1_Pscell_Change_N25_N41_AB13}    A2_Pscell=${A2_Pcell_Change_N25_N41_AB13}
    UE13 attch and A1 scell add and pcell change should not config    ue_mrdc_cap=${Capa_LTE_DC_n25A-n38A_and_n25A-n41A_and_no_UL_in_n38-n41}
    ...    ret_not_cont=a1-Threshold rsrp : 40
    check counters    pm_counters_expression=${pm_couter_AB13}

CB007219-ET-AB14_Verify MFBI NSA CA online modification alternative band
    [Documentation]
    ...    1. Purpose:This user scenario describes the gNB behavior when an alternative band is added/deleted and a UE is
    ...    connected after the modification.The modified values will not make an impact on the UEs already connected to the gNB
    ...    (till the next trigger for scell addition/change/swap).5G_RAN_USR_RRM_21062
    ...    2. Configuration
    ...    a.NRCELL-2 TDD native:N78 alternative:N77 40Mhz dlmimo: 4x4 or 4x2 Closed Loop Spatial Multiplexing
    ...    NRCELL-3 TDD native:N38 alternative:N41 40Mhz, small bwp:20MHZ dlmimo: 4x4 or 4x2 Closed Loop Spatial Multiplexing
    ...    b.5GC001416 enable:actMultiFrequencyBandIndicatorNRSupport=true; CB007219:actMfbiNrCaSupportFr1 set to true.
    ...    c.ue capability:
    ...    BC#1: DC_1A-3A-n38A-n78A       n38    n78
    ...    DL FSEI#1    DL MIMO layers    4L    2L
    ...                 DL ChBw (MHz)     20    40
    ...    BC#2: DC_1A-3A-n41A-n78A       n41    n78
    ...    DL FSEI#1    DL MIMO layers    2L    2L
    ...                  DL ChBw (MHz)    40    40
    ...    3. Test Case Steps:
    ...    a. online delete alternative band n41 for cell3.UE11 attach to LTE1 cell3 NRCELL-2.traffic should ok.
    ...       Then A1 add cell 3 add as scell.Then BC1#FS1(N78_N38) selected.traffic should ok.
    ...    b. online add alternative band n41 for cell3.UE12 attach to LTE1 cell3 NRCELL-2.traffic should ok.
    ...       Then A1 add cell 3 add as scell.Then BC2#FS1(N78_N41) selected.traffic should ok.
    ...       release scell for UE11 and trigger scell addition again.Then BC2#FS1(N78_N41) selected.traffic should ok.
    ...    c. online delete alternative band n41 for cell3.UE13 attach to LTE1 cell3 NRCELL-2.traffic should ok.
    ...       Then A1 add cell 3 add as scell.Then BC1#FS1(N78_N38) selected.traffic should ok.
    ...       release scell for UE11 and trigger scell addition again.Then BC1#FS1(N78_N38) selected.traffic should ok.
    ...    d. check counter.
    [Tags]    AB14    QC_322193    CA_LABEL-TT(40MHZ_TDD_n78+20MHZ_TDD_n38)    CA_LABEL-TT(40MHZ_TDD_n78+40MHZ_TDD_n41)
    clear counter files
    OnlineParamChange    ${delete_alternative_band_n41_for_cell3}
    NSA attach to cell 2 and A1 add cell3 as scell    p_dl=250    total_dl=300    pass_CA=${nsa_ue_A1_scellAdd_N38_expect}
    OnlineParamChange    ${add_alternative_band_n41_for_cell3}
    Another UE attch and UE11 scell release and UE11 scell add again    ue_id=12    pass_CA=${nsa_ue_A1_scellAdd_N41_expect}
    OnlineParamChange    ${delete_alternative_band_n41_for_cell3}
    Another UE attch and UE11 scell release and UE11 scell add again    ue_id=13    p_dl=60    total_dl=120
    ...    pass_CA=${nsa_ue_A1_scellAdd_N38_expect}
    check counters    pm_counters_expression=${pm_couter_AB14_AB15}
    [Teardown]    AB14_Teardown

CB007219-ET-AB15_Verify MFBI NSA CA online modification FAF
    [Documentation]
    ...    1. Purpose:This user scenario describes the gNB behavior when the feature activation flag of CB007219 is modified online.The
    ...    modified values will not make an impact on the UEs already connected to the gNB (till the next trigger for scell
    ...     addition/change/swap, see note 1).5G_RAN_USR_RRM_21063
    ...    2. Configuration
    ...    a.NRCELL-2 TDD native:N78 alternative:N77 40Mhz dlmimo: 4x4 or 4x2 Closed Loop Spatial Multiplexing
    ...    NRCELL-3 TDD native:N38 alternative:N41 40Mhz, small bwp:20MHZ dlmimo: 4x4 or 4x2 Closed Loop Spatial Multiplexing
    ...    b.5GC001416 enable:actMultiFrequencyBandIndicatorNRSupport=true; CB007219:actMfbiNrCaSupportFr1 set to true.
    ...    c.ue capability:
    ...    BC#1: DC_1A-3A-n38A-n78A       n38    n78
    ...    DL FSEI#1    DL MIMO layers    4L    2L
    ...                 DL ChBw (MHz)     20    40
    ...    BC#2: DC_1A-3A-n41A-n78A       n41    n78
    ...    DL FSEI#1    DL MIMO layers    2L    2L
    ...                  DL ChBw (MHz)    40    40
    ...    3. Test Case Steps:
    ...    a. online deactive 7219.UE11 attach to LTE1 cell3 NRCELL-2.traffic should ok.
    ...       Then A1 add cell 3 add as scell.Then BC1#FS1(N78_N38) selected.traffic should ok.
    ...    b. online set 7219 as true.UE12 attach to LTE1 cell3 NRCELL-2.traffic should ok.
    ...       Then A1 add cell 3 add as scell.Then BC2#FS1(N78_N41) selected.traffic should ok.
    ...       release scell for UE11 and trigger scell addition again.Then BC2#FS1(N78_N41) selected.traffic should ok.
    ...    c. online deactive 7219.UE13 attach to LTE1 cell3 NRCELL-2.traffic should ok.
    ...       Then A1 add cell 3 add as scell.Then BC1#FS1(N78_N38) selected.traffic should ok.
    ...       release scell for UE11 and trigger scell addition again.Then BC1#FS1(N78_N38) selected.traffic should ok.
    ...    d. check counter.
    [Tags]    AB15    QC_46790    CA_LABEL-TT(40MHZ_TDD_n78+20MHZ_TDD_n38)    CA_LABEL-TT(40MHZ_TDD_n78+40MHZ_TDD_n41)
    clear counter files
    OnlineParamChange    ${Deactivate_CB007219}
    NSA attach to cell 2 and A1 add cell3 as scell    p_dl=250    total_dl=300    pass_CA=${nsa_ue_A1_scellAdd_N38_expect}
    OnlineParamChange    ${7219}
    Another UE attch and UE11 scell release and UE11 scell add again    ue_id=12    pass_CA=${nsa_ue_A1_scellAdd_N41_expect}
    OnlineParamChange    ${Deactivate_CB007219}
    Another UE attch and UE11 scell release and UE11 scell add again    ue_id=13    p_dl=60    total_dl=120
    ...    pass_CA=${nsa_ue_A1_scellAdd_N38_expect}
    check counters    pm_counters_expression=${pm_couter_AB14_AB15}
    [Teardown]    AB15_Teardown

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/8cells_4T4F_2N2_N66_N71_2N78_2N38    ue_count=10

Modify Cfg
    ${C_1}    catenate
    ...    set_cell id=1 enb=1 eci=0x1234601 pci=4:0 tac=222 proxy=$DAEMON_IP:12219|$DAEMON_IP:8889
    ...    earfcn=66886:132422 mandatory_for_activation=off
    ${C_2}    catenate
    ...    set_cell id=2 enb=1 eci=0x1234602 pci=4:1 tac=222 proxy=$DAEMON_IP:12220|$DAEMON_IP:8890
    ...    earfcn=3100:21100 mandatory_for_activation=off
    ${C_3}    catenate
    ...    set_cell id=3 enb=1 eci=0x1234603 pci=4:2 tac=222 proxy=$DAEMON_IP:12221|$DAEMON_IP:8891
    ...    earfcn=300:18300 mandatory_for_activation=off
    Update Cfg    ${C_1}
    Update Cfg    ${C_2}
    Update Cfg    ${C_3}
    ${C_4}    catenate
    ...    set_cell id=3 gnb=2 pci=17:1 tac=200 nrci=0x03 tdd_cell=on proxy=$PROXY_SERVER_IP:9999|$PROXY_SERVER_IP:8888
    ...    nr_arfcn=519000:519000 gscn=6462 mandatory_for_activation=off bwp_arfcn=517020:517020
    Update Cfg    ${C_4}
    ${C_5}    catenate
    ...    set_cell id=13 gnb=2 pci=20:2 tac=200 nrci=0x0d tdd_cell=off proxy=$PROXY_SERVER_IP:9999|$PROXY_SERVER_IP:8888
    ...    nr_arfcn=376000:392000 gscn=4885 mandatory_for_activation=off bwp_arfcn=391514:391514
    Update Cfg    ${C_5}

NSA attach to cell 2 and A1 add cell3 as scell
    [Arguments]    ${ue_id}=11    ${p_dl}=100    ${total_dl}=200    ${pass_AT}=${nsa_ue_attach_expect}    ${pass_CA}=none
    NSA UE Attach To Sim Enb1 And Start ENDC With Real Gnb2    SA_Capa_perUE_Full=${DC_1A-3A-n38A-n78A_and_DC_1A-3A-n41A-n78A}
    ...    ue_mrdc_cap=${Capa_LTE_DC_1A-3A-n38A-n78A_and_DC_1A-3A-n41A-n78A}    ue_id=${ue_id}    pass_AT=${pass_AT}
    Send Throughput    ue_id=${ue_id}
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=${ue_id}    cell_num=1    dl=${p_dl}
    Trigger ScellAdd    ue_id=${ue_id}    pass_CA=${pass_CA}
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=${ue_id}    dl=${total_dl}

AB14_Teardown
    OnlineParamChange    ${add_alternative_band_n41_for_cell3}
    Common Test Teardown And Stop Capture Logs

AB15_Teardown
    OnlineParamChange    ${7219}
    Common Test Teardown And Stop Capture Logs

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir

NSA UE Attach To Sim Enb1 And Start ENDC With Real Gnb2
    [Arguments]    ${ue_id}=11    ${target_gnb}=2    ${target_cells}=2    ${bearer_id}=2    ${target_enb}=3
    ...    ${SA_Capa_perUE_Full}=none    ${ue_mrdc_cap}=none    ${bc_list_mrdc}=1:1|2:1    ${pass_AT}=${nsa_ue_attach_expect}
    Update UE capa    ue_id=${ue_id}    SA_Capa_perUE_Full=${SA_Capa_perUE_Full}    Capa_LTE=${ue_mrdc_cap}
    Execute Egate Command    enb_endc_param id=1 allowed_bc_list_mrdc=${bc_list_mrdc}
    Execute Egate Command    ue_change_location id=${ue_id} enb=1 cell=${target_enb}
    Execute Egate Command    ue_attach id=${ue_id}    pass_regexp=UE${ue_id}: === UE IS ACTIVE
    Execute Egate Command    ue_disp id=${ue_id}    timeout=20s
    ${cmd}     Catenate    ue_dc_enb_start ue=${ue_id} target_gnb=${target_gnb}
    ...    target_cells=${target_cells} bearer=${bearer_id} type=split_scg
    ${ret1}=    Execute Egate Command    ${cmd}    pass_regexp=${pass_AT}    timeout=20s
    [Return]    ${ret1}

Send Throughput
    [Arguments]    ${ue_id}=11    ${times}=2    ${mbps}=175
    Execute Egate Command    trf_data_start ue=${ue_id} id=2 dir=ul mbps=10 trf_id=1    UE ${ue_id}: UDP UL
    FOR    ${I}    IN RANGE    1    ${times}+1
        Execute Egate Command    trf_data_start ue=${ue_id} id=2 dir=dl mbps=${mbps} trf_id=${I}    UE ${ue_id}: UDP DL
    END
    sleep    10s    sleep for stable traffic

Check Traffic
    [Arguments]    ${ue_id}=11    ${cell_num}=2    ${dl}=100    ${ul}=8
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=8-11 type=pdsch    Throughput
    ${ul_throughput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=8    type=pusch    rate_type=ave
    ${total_dl_tput}    Set Variable    0
    FOR    ${index}    IN RANGE    8    ${cell_num}+8
         ${str_index}    Convert To String    ${index}
         ${scell_tput}    Ap Get Throuput On Specific Scell    ${ue_id}    ${str_index}    pdsch
         Should Be True    ${scell_tput}/1000 > 0
         ${total_dl_tput}    Evaluate    ${scell_tput}+${total_dl_tput}
    END
    Should Be True    ${total_dl_tput}/1000 > ${dl}
    Should Be True    ${ul_throughput}/1000>${ul}

Update UE capa
    [Arguments]    ${ue_id}=11    ${SA_Capa_perUE_Full}=none    ${Capa_LTE}=none
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full}
    ...    dual_conn=eutra_nr ue_eutra_nr_capabilities=${Capa_LTE}
    Execute Egate Command    ${cmd}

Trigger ScellAdd
    [Arguments]    ${event_type}=A1    ${carrierfreq}=648096    ${srsrp_nr}=90    ${srsrq_nr}=90    ${ue_id}=11
    ...    ${pass_CA}=none
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr    id=${ue_id}    meas_id=${meas_id}    event=${event_type}
    ...    srsrp_nr=${srsrp_nr}    srsrq_nr=${srsrq_nr}
    ${ret}    Execute Egate Command    ${cmd}    pass_regexp=${pass_CA}
    [Return]    ${ret}

trigger A2 Scell Release
    [Arguments]    ${event_type}=A2    ${carrierfreq}=516990    ${srsrp_nr}=7    ${srsrq_nr}=7    ${ue_id}=11    ${scell_id}=9    ${dl}=100
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type} scell=${scell_id}
    ...    srsrp_nr=${srsrp_nr} srsrq_nr=${srsrq_nr}
    ${ret1}=    Execute Egate Command    ${cmd}    pass_regexp=SgNB Modification Confirm
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=${ue_id}    cell_num=1    dl=${dl}
    [Return]    ${ret1}

Another UE attch and UE11 scell release and UE11 scell add again
    [Arguments]    ${ue_id}=12    ${p_dl}=100    ${total_dl}=200    ${pass_CA}=none
    NSA attach to cell 2 and A1 add cell3 as scell    ue_id=${ue_id}    p_dl=${p_dl}    total_dl=${total_dl}    pass_CA=${pass_CA}
    trigger A2 Scell Release    dl=${p_dl}
    Trigger ScellAdd    pass_CA=${pass_CA}
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    dl=${total_dl}

Pscell change by A1
    [Arguments]    ${ue_id}=11    ${carrierfreq}=516990    ${A1_Pscell}=SgNBModificationConfirm
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A1
    ${cmd}    catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=35 srsrq_nr=35 scell=9
    ...    scell_rsrp=90 scell_rsrq=90
    Execute Egate Command    ${cmd}    pass_regexp=${A1_Pscell}

Pscell change by A2
    [Arguments]    ${ue_id}=11    ${carrierfreq}=516990    ${A2_Pscell}=SgNBModificationConfirm
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A2
    Execute Egate Command
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 srsrp_nr=0 srsrq_nr=0 scell=9 scell_rsrp=115 scell_rsrq=95
    ...    pass_regexp=${A2_Pscell}

UE attach and PSchange by A1 and A2
    [Arguments]    ${ue_id}=11    ${A1_Pscell}=SgNBModificationConfirm    ${A2_Pscell}=SgNBModificationConfirm    ${p_dl}=320    ${t_dl}=440
    ...    ${SA_Capa_perUE_Full}=${DC_66A_n5A-n25A-n41A-n38A}    ${ue_mrdc_cap}=none
    NSA UE Attach To Sim Enb1 And Start ENDC With Real Gnb2    ue_id=${ue_id}    SA_Capa_perUE_Full=${SA_Capa_perUE_Full}
    ...    ue_mrdc_cap=${ue_mrdc_cap}    target_cells=14    pass_AT=${nsa_ue_attach_AB13}    target_enb=1
    Send Throughput    ue_id=${ue_id}    times=3
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=${ue_id}    cell_num=1    dl=${p_dl}
    Trigger ScellAdd    ue_id=${ue_id}    carrierfreq=394370    pass_CA=${nsa_ue_A1_scellAdd_N41_AB13}
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=${ue_id}    dl=${t_dl}
    Pscell change by A1    ue_id=${ue_id}    A1_Pscell=${A1_Pscell}
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=${ue_id}    dl=${t_dl}
    Pscell change by A2    ue_id=${ue_id}    A2_Pscell=${A2_Pscell}
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=${ue_id}    dl=${t_dl}
    Release Ues    ue_type=all

UE attach and PSchange by A2 and A1
    [Arguments]    ${ue_id}=11    ${A1_Pscell}=SgNBModificationConfirm    ${A2_Pscell}=SgNBModificationConfirm    ${p_dl}=240    ${t_dl}=440
    ...    ${SA_Capa_perUE_Full}=${DC_66A_n5A-n25A-n41A-n38A}    ${ue_mrdc_cap}=none
    NSA UE Attach To Sim Enb1 And Start ENDC With Real Gnb2    ue_id=${ue_id}    SA_Capa_perUE_Full=${SA_Capa_perUE_Full}
    ...    ue_mrdc_cap=${ue_mrdc_cap}    target_cells=2    pass_AT=${nsa_ue_attach_AB12}    target_enb=1
    Send Throughput    ue_id=${ue_id}    times=3
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=${ue_id}    cell_num=1    dl=${p_dl}
    Trigger ScellAdd    ue_id=${ue_id}    carrierfreq=648096    pass_CA=${nsa_ue_A1_scellAdd_N25_AB12}
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=${ue_id}    dl=${t_dl}
    Pscell change by A2    ue_id=${ue_id}    carrierfreq=648096    A2_Pscell=${A2_Pscell}
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=${ue_id}    dl=${t_dl}
    Pscell change by A1    ue_id=${ue_id}    carrierfreq=648096    A1_Pscell=${A1_Pscell}
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=${ue_id}    dl=${t_dl}
    Release Ues    ue_type=all

UE13 attch and A1 scell add and pcell change should not config
    [Arguments]    ${ue_id}=13    ${target_cell}=14    ${ue_mrdc_cap}=none    ${carrierfreq}=394370    ${p_dl}=320
    ...    ${pass_AT}=${nsa_ue_attach_AB13}    ${total_dl}=440    ${pass_CA}=${nsa_ue13_A1_scellAdd_N41_AB13}     ${ret_not_cont}=none
    NSA UE Attach To Sim Enb1 And Start ENDC With Real Gnb2    ue_id=${ue_id}    SA_Capa_perUE_Full=${DC_66A_n5A-n25A-n41A-n38A}
    ...    target_enb=1    ue_mrdc_cap=${ue_mrdc_cap}    target_cells=${target_cell}    pass_AT=${pass_AT}
    Send Throughput    ue_id=${ue_id}    times=3
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=${ue_id}    cell_num=1    dl=${p_dl}
    ${ret}    Trigger ScellAdd    ue_id=${ue_id}    carrierfreq=${carrierfreq}    pass_CA=${pass_CA}
    Execute Egate Command    ue_meas_cfg_disp id=13 meas_obj_type=nr    pass_regexp=NR MEASUREMENT IDENTITIES
    Should Not Contain      ${ret}     ${ret_not_cont}    #A1 for pcell change should not configured
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=${ue_id}    dl=${total_dl}
    Release Ues    ue_type=all

UE14 attach and scell add with feature on
    NSA UE Attach To Sim Enb1 And Start ENDC With Real Gnb2    ue_id=14    SA_Capa_perUE_Full=${DC_66A_n5A-n25A-n41A-n38A}
    ...    ue_mrdc_cap=${Capa_LTE_DC_n25A-n78A}    target_cells=2    pass_AT=${nsa_ue_attach_AB12_UE14}    target_enb=1    bc_list_mrdc=1:1
    Send Throughput    ue_id=14    times=3
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=14    cell_num=1    dl=240
    OnlineParamChange    ${Deactivate_CB007219}
    ${ret}    Trigger ScellAdd    ue_id=14    carrierfreq=648096    pass_CA=Measurements
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=14    cell_num=1    dl=240
    OnlineParamChange    ${7219}
    ${ret}    Trigger ScellAdd    ue_id=14    carrierfreq=648096        pass_CA=${nsa_ue_A1_scellAdd_N25_AB12}
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=14    dl=440

UE14 attach and scell should not config with feature off
    OnlineParamChange    ${Deactivate_CB007219}
    ${ret}    trigger A2 Scell Release    ue_id=14    carrierfreq=390770
    Should Not Contain      ${ret}     a1-Threshold rsrp : 85    #A1 for scell add is configured
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=14    cell_num=1    dl=240
    Release Ues    ue_type=all
    ${ret}    NSA UE Attach To Sim Enb1 And Start ENDC With Real Gnb2    ue_id=14    SA_Capa_perUE_Full=${DC_66A_n5A-n25A-n41A-n38A}
    ...    ue_mrdc_cap=${Capa_LTE_DC_n25A-n78A}    target_cells=2    pass_AT=${nsa_ue_attach_AB12_UE14_no_A1}    target_enb=1
    Should Not Contain      ${ret}     a1-Threshold rsrp : 85    #A1 for scell add is configured
    Send Throughput    ue_id=14    times=3
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=14    cell_num=1    dl=240
    Release Ues    ue_type=all
