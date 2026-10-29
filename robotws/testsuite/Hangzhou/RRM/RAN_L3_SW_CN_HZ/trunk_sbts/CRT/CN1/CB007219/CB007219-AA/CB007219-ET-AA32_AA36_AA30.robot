*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_VRF    SBTS00    RAN_5G    RAN_5G_TDD    team-CN1ET    owner-christine.chen
...    CLOUD_5G_I_BOO_AP_LOO    CRT    CB007219    release-SBTS24R3
Resource    ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{7219}
...    @{1416}
...    @{Scell_Rel_AA32}
...    @{CA_enable}
...    @{MimoMode_Para}
...    @{Inter_frequency_HO}
...    @{NRHOIF_Config}
...    @{HO_Config}
...    @{Scell_Rel_AA36}
...    @{Scell_Rel_AA30}
...    @{BWP_change}

@{7219}
...    NRBTS:actMfbiNrCaSupportFr1=true
...    NRBTS:actMfbiNrCaMeasConfResolv=false
@{1416}
...    NRBTS:actMultiFrequencyBandIndicatorNRSupport=true
...    NRCELL-1:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-2
...    NRCELL-1:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-2
...    NRCELL-3:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-2
...    NRCELL-3:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-2
...    NRBTS/NRCELL-4:freqBandIndicatorNR=38
...    NRBTS/NRCELL-2:freqBandIndicatorNR=77
...    NRBTS/NRCELL-1:nrarfcn=640000
...    NRBTS/NRCELL-1:gscnOrSsPbchArfcn=7920
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
...    NRBTS-1:actInterFreqHoSA=true
...    NRPMRNL-1:miNrRelReportCu=15min
...    NRBTS-1:actCarrierAggregation=true
...    NRBTS-1:caConfigurationSupport=2CCDL_2CCUL
...    NRBTS-1:actMeasBasedSCellAdditionSa=A1-based
...    NRCELL:maxNumScellsDlFr1=4
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRCELL:actK1Opt=intra-gNB
...    NRCELL-11:measGapSelectionSA=favourUeThroughput
...    NRCELL-3:measGapSelectionSA=favourUeThroughput
...    NRDU-1:carrierAggregationSupportList=${CAlist}
${CAlist}    ca_Fdd_Fr1Tdd_Sa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Any_Sa,ca_Fdd_Any_Sa,ca_Fdd_Fdd

@{MimoMode_Para}
...    NRCELL:allowUnsuppBcOrBcs=complete BCS check
...    NRCELL-1:dlMimoMode=4x4 or 4x2 Closed Loop Spatial Multiplexing
...    NRCELL-1:nrCellType=4DL4UL
...    NRCELL-2:dlMimoMode=4x4 or 4x2 Closed Loop Spatial Multiplexing
...    NRCELL-2:nrCellType=4DL4UL
...    NRCELL-3:dlMimoMode=4x4 or 4x2 Closed Loop Spatial Multiplexing
...    NRCELL-3:nrCellType=4DL4UL
...    NRCELL-4:dlMimoMode=4x4 or 4x2 Closed Loop Spatial Multiplexing
...    NRCELL-4:nrCellType=4DL4UL
...    NRCELL-13:dlMimoMode=4x4 or 4x2 Closed Loop Spatial Multiplexing
...    NRCELL-13:nrCellType=4DL4UL
...    NRCELL-14:dlMimoMode=4x4 or 4x2 Closed Loop Spatial Multiplexing
...    NRCELL-14:nrCellType=4DL4UL

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

@{Scell_Rel_AA32}
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
...    NRCELL-11/NRREL-2:sCellOperationalMode=dlOnly

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
...    NRCELL-11/NRREL-1:sCellOperationalMode=dlOnly

...    NRCELL-11/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-3:gNbId=1
...    NRCELL-11/NRREL-3:gNbIdLength=22
...    NRCELL-11/NRREL-3:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-3:removeNotAllowed=false
...    NRCELL-11/NRREL-3:lcrId=3

...    NRCELL-11/NRHOIF-3:cellDepType=SA+NSA
...    NRCELL-11/NRHOIF-3:freqBandIndicatorNR=78
...    NRCELL-11/NRHOIF-3:ifhoSsbScs=30 KHz
...    NRCELL-11/NRHOIF-3:ifhoSsbSmtcDuration=sf2
...    NRCELL-11/NRHOIF-3:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-11/NRHOIF-3:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-11/NRHOIF-3:ssBurstSetPeriod=20
...    NRCELL-11/NRHOIF-3:ssbFrequency=640416
...    NRCELL-11/NRHOIF-3:a3MeasEnabled=rsrp
...    NRCELL-11/NRHOIF-3:a3MeasSsbRsrp:a3HysteresisSsbRsrp=2
...    NRCELL-11/NRHOIF-3:a3MeasSsbRsrp:a3OffsetSsbRsrp=20
...    NRCELL-11/NRHOIF-3:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms40
...    NRCELL-11/NRHOIF-3:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-2
...    NRCELL-11/NRHOIF-3:a1BasedPCellSwitchEnabled=true

...    NRCELL-11/NRHOIF-2:cellDepType=SA+NSA
...    NRCELL-11/NRHOIF-2:freqBandIndicatorNR=77
...    NRCELL-11/NRHOIF-2:ifhoSsbScs=30 KHz
...    NRCELL-11/NRHOIF-2:ifhoSsbSmtcDuration=sf2
...    NRCELL-11/NRHOIF-2:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-11/NRHOIF-2:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-11/NRHOIF-2:ssBurstSetPeriod=20
...    NRCELL-11/NRHOIF-2:ssbFrequency=648096
...    NRCELL-11/NRHOIF-2:a3MeasEnabled=rsrp
...    NRCELL-11/NRHOIF-2:a3MeasSsbRsrp:a3HysteresisSsbRsrp=2
...    NRCELL-11/NRHOIF-2:a3MeasSsbRsrp:a3OffsetSsbRsrp=20
...    NRCELL-11/NRHOIF-2:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms40
...    NRCELL-11/NRHOIF-2:a1BasedPCellSwitchEnabled=true

...    NRCELL-11:a1MeashoEnabledSA=rsrp
...    NRCELL-11:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=40
...    NRCELL-11:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRCELL-11:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms0
...    NRCELL-11:a2MeashoEnabledSA=rsrp
...    NRCELL-11:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=25
...    NRCELL-11:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0
...    NRCELL-11:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms0

...    NRCELL-11:a1MeasSCellAddEnabled=rsrp
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=70|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=90|a1TimeToTriggerSCellAddSsbRsrp=320ms

...    NRCELL-1:a2MeasSCellRelEnabled=rsrp
...    NRCELL-1:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=480ms
...    NRCELL-1:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=40|a2TimeToTriggerSCellRelSsbRsrp=480ms

...    NRCELL-2:a2MeasSCellRelEnabled=rsrp
...    NRCELL-2:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=480ms
...    NRCELL-2:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=40|a2TimeToTriggerSCellRelSsbRsrp=480ms

@{Scell_Rel_AA30}
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
...    NRCELL-12/NRREL-4:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-4:gNbId=1
...    NRCELL-12/NRREL-4:gNbIdLength=22
...    NRCELL-12/NRREL-4:handoverAllowedSA=allowed
...    NRCELL-12/NRREL-4:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-4:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-4:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-4:removeNotAllowed=false
...    NRCELL-12/NRREL-4:lcrId=4
...    NRCELL-12/NRREL-4:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-4:sCellOperationalMode=dlOnly
...    NRCELL-12/NRREL-11:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-11:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-11:gNbId=1
...    NRCELL-12/NRREL-11:gNbIdLength=22
...    NRCELL-12/NRREL-11:handoverAllowedSA=allowed
...    NRCELL-12/NRREL-11:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-11:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-11:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-11:removeNotAllowed=false
...    NRCELL-12/NRREL-11:lcrId=11
...    NRCELL-12/NRREL-11:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-11:sCellOperationalMode=dlOnly
...    NRCELL-12:a1MeasSCellAddEnabled=rsrp
...    NRCELL-12:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-12:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=70|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-12:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=90|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-13/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-13/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-13/NRREL-1:gNbId=1
...    NRCELL-13/NRREL-1:gNbIdLength=22
...    NRCELL-13/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-13/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-13/NRREL-1:removeNotAllowed=false
...    NRCELL-13/NRREL-1:lcrId=1
...    NRCELL-13/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-13/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-13/NRREL-4:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-13/NRREL-4:gNbId=1
...    NRCELL-13/NRREL-4:gNbIdLength=22
...    NRCELL-13/NRREL-4:handoverAllowedSA=allowed
...    NRCELL-13/NRREL-4:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-4:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-4:gnbPlmn:mncLength=3
...    NRCELL-13/NRREL-4:removeNotAllowed=false
...    NRCELL-13/NRREL-4:lcrId=4
...    NRCELL-13/NRREL-4:sCellAdditionMethod=covBasedA1
...    NRCELL-13/NRREL-4:sCellOperationalMode=dlOnly
...    NRCELL-13/NRREL-14:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-13/NRREL-14:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-13/NRREL-14:gNbId=1
...    NRCELL-13/NRREL-14:gNbIdLength=22
...    NRCELL-13/NRREL-14:handoverAllowedSA=allowed
...    NRCELL-13/NRREL-14:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-14:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-14:gnbPlmn:mncLength=3
...    NRCELL-13/NRREL-14:removeNotAllowed=false
...    NRCELL-13/NRREL-14:lcrId=14
...    NRCELL-13/NRREL-14:sCellAdditionMethod=covBasedA1
...    NRCELL-13/NRREL-14:sCellOperationalMode=dlOnly
...    NRCELL-13:a1MeasSCellAddEnabled=rsrp
...    NRCELL-13:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-13:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=70|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-13:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=90|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-1/NRREL-4:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-4:gNbId=1
...    NRCELL-1/NRREL-4:gNbIdLength=22
...    NRCELL-1/NRREL-4:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-4:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-4:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-4:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-4:removeNotAllowed=false
...    NRCELL-1/NRREL-4:lcrId=4
...    NRCELL-1/NRREL-4:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-4:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-11:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-11:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-11:gNbId=1
...    NRCELL-1/NRREL-11:gNbIdLength=22
...    NRCELL-1/NRREL-11:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-11:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-11:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-11:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-11:removeNotAllowed=false
...    NRCELL-1/NRREL-11:lcrId=11
...    NRCELL-1/NRREL-11:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-11:sCellOperationalMode=dlOnly
...    NRCELL-1:a1MeasSCellAddEnabled=rsrp
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=70|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=90|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-4/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-4/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-4/NRREL-1:gNbId=1
...    NRCELL-4/NRREL-1:gNbIdLength=22
...    NRCELL-4/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-4/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-4/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-4/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-4/NRREL-1:removeNotAllowed=false
...    NRCELL-4/NRREL-1:lcrId=1
...    NRCELL-4/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-4/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-4/NRREL-11:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-4/NRREL-11:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-4/NRREL-11:gNbId=1
...    NRCELL-4/NRREL-11:gNbIdLength=22
...    NRCELL-4/NRREL-11:handoverAllowedSA=allowed
...    NRCELL-4/NRREL-11:gnbPlmn:mnc=489
...    NRCELL-4/NRREL-11:gnbPlmn:mcc=311
...    NRCELL-4/NRREL-11:gnbPlmn:mncLength=3
...    NRCELL-4/NRREL-11:removeNotAllowed=false
...    NRCELL-4/NRREL-11:lcrId=11
...    NRCELL-4/NRREL-11:sCellAdditionMethod=covBasedA1
...    NRCELL-4/NRREL-11:sCellOperationalMode=dlOnly
...    NRCELL-4:a1MeasSCellAddEnabled=rsrp
...    NRCELL-4:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-4:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=70|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-4:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=90|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a2MeasSCellRelEnabled=rsrp
...    NRCELL:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=480ms
...    NRCELL:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=40|a2TimeToTriggerSCellRelSsbRsrp=480ms
@{Inter_frequency_HO}
...    NRCELL-1:a1MeasPCellSwitchEnabled=rsrp
...    NRCELL-1:a1MeasPCellSwitchSsbRsrp:a1HysteresisPCellSwitchSsbRsrp=0|a1TimeToTriggerPCellSwitchSsbRsrp=480ms
...    NRCELL-1:a1MeasPCellSwitchSsbRsrp:a1ThresholdPCellSwitchSsbRsrp=50|a1TimeToTriggerPCellSwitchSsbRsrp=480ms

...    NRCELL-2:a1MeasPCellSwitchEnabled=rsrp
...    NRCELL-2:a1MeasPCellSwitchSsbRsrp:a1HysteresisPCellSwitchSsbRsrp=0|a1TimeToTriggerPCellSwitchSsbRsrp=480ms
...    NRCELL-2:a1MeasPCellSwitchSsbRsrp:a1ThresholdPCellSwitchSsbRsrp=50|a1TimeToTriggerPCellSwitchSsbRsrp=480ms

...    NRCELL-3:a1MeashoEnabledSA=rsrp
...    NRCELL-3:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=40
...    NRCELL-3:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRCELL-3:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms0
...    NRCELL-3:a2MeashoEnabledSA=rsrp
...    NRCELL-3:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=25
...    NRCELL-3:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0
...    NRCELL-3:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms0

...    NRCELL-3/NRREL-11:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-3/NRREL-11:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-3/NRREL-11:gNbId=1
...    NRCELL-3/NRREL-11:gNbIdLength=22
...    NRCELL-3/NRREL-11:handoverAllowedSA=allowed
...    NRCELL-3/NRREL-11:gnbPlmn:mnc=489
...    NRCELL-3/NRREL-11:gnbPlmn:mcc=311
...    NRCELL-3/NRREL-11:gnbPlmn:mncLength=3
...    NRCELL-3/NRREL-11:removeNotAllowed=false
...    NRCELL-3/NRREL-11:lcrId=11

...    NRCELL-3/NRHOIF-11:cellDepType=SA+NSA
...    NRCELL-3/NRHOIF-11:freqBandIndicatorNR=66
...    NRCELL-3/NRHOIF-11:ifhoSsbScs=15KHz
...    NRCELL-3/NRHOIF-11:ifhoSsbSmtcDuration=sf2
...    NRCELL-3/NRHOIF-11:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-3/NRHOIF-11:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-3/NRHOIF-11:ssBurstSetPeriod=20
...    NRCELL-3/NRHOIF-11:ssbFrequency=424090
...    NRCELL-3/NRHOIF-11:a3MeasEnabled=rsrp
...    NRCELL-3/NRHOIF-11:a3MeasSsbRsrp:a3HysteresisSsbRsrp=2
...    NRCELL-3/NRHOIF-11:a3MeasSsbRsrp:a3OffsetSsbRsrp=20
...    NRCELL-3/NRHOIF-11:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms40

@{NRHOIF_Config}
...    NRCELL-2/NRHOIF-1:cellDepType=SA
...    NRCELL-2/NRHOIF-1:freqBandIndicatorNR=25
...    NRCELL-2/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-2/NRHOIF-1:ifhoSsbSmtcDuration=sf2
...    NRCELL-2/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-2/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-2/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-2/NRHOIF-1:ssbFrequency=388830
...    NRCELL-2/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0|a3OffsetSsbRsrp=20|a3TimeToTriggerSsbRsrp=ms64
...    NRADJNRCELL-1:cellDepType=SA
...    NRADJNRCELL-1:freqBandIndicatorNR=77
...    NRADJNRCELL-1:gNbId=35
...    NRADJNRCELL-1:gNbIdLength=22
...    NRADJNRCELL-1:lcrId=1
...    NRADJNRCELL-1:nrAdjNrCellId=1
...    NRADJNRCELL-1:nrarfcn=633000
...    NRADJNRCELL-1:ssbFrequency=648096
...    NRADJNRCELL-1:physCellId=381
...    NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRADJNRCELL-1:gnbPlmn:mnc=489
...    NRADJNRCELL-1:gnbPlmn:mncLength=3
...    NRADJNRCELL-1:fiveGsTac=200
...    NRCELL-13/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-13/NRHOIF-1:a5MeasEnabled=none
...    NRCELL-13/NRHOIF-1:cellDepType=SA
...    NRCELL-13/NRHOIF-1:freqBandIndicatorNR=77
...    NRCELL-13/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-13/NRHOIF-1:ifhoSsbSmtcDuration=sf3
...    NRCELL-13/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-13/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-13/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-13/NRHOIF-1:ssbFrequency=648096
...    NRCELL-13/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=30
...    NRCELL-13/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=20
...    NRCELL-13/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms160

@{HO_Config}
...    NRBTS-1:actInterFreqHoSA=true
...    NRPMRNL-1:miNrRelReportCu=15min
...    NRBTS-1:actIntraNrNgHo=sourceAndTarget
...    NRCELL:a1MeashoEnabledSA=rsrp
...    NRCELL:a2MeashoEnabledSA=rsrp
...    NRCELL:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0|a1ThresholdhoSsbRsrpSA=40|a1TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0|a2ThresholdhoSsbRsrpSA=34|a2TimeToTriggerhoSsbRsrpSA=ms40
...    NRCELL-2:measGapSelectionSA=favourUeThroughput
...    NRCELL-13:measGapSelectionSA=favourUeThroughput
...    NRBTS-1:tNgRelocExecDeltN=3000
...    NRBTS-1:tNgRelocPrepN=2000
...    NRBTS-1:tNgRelocOverallN=2000
...    NRBTS-1:tNgRelocCancelN =2000
...    NRBTS-1:suppCnPartialAdNgHo=false
...    NRCELL-13/NRREL-9:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-13/NRREL-9:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-13/NRREL-9:gNbId=35
...    NRCELL-13/NRREL-9:gNbIdLength=22
...    NRCELL-13/NRREL-9:lcrId=1
...    NRCELL-13/NRREL-9:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-9:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-9:gnbPlmn:mncLength=3
...    NRCELL-13/NRREL-9:handoverAllowedSA=XnHoNotAllowed
...    NRCELL-2/NRREL-13:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-13:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-13:isRplCellForPSCell=true
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

@{Scell_Rel_AA36}
...    NRCELL-13/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-13/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-13/NRREL-1:isRplCellForPSCell=true
...    NRCELL-13/NRREL-1:gNbId=1
...    NRCELL-13/NRREL-1:gNbIdLength=22
...    NRCELL-13/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-13/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-13/NRREL-1:removeNotAllowed=false
...    NRCELL-13/NRREL-1:lcrId=1
...    NRCELL-13/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-13/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-13/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-13/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-13/NRREL-2:isRplCellForPSCell=true
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
...    NRCELL-13:a1MeasSCellAddEnabled=rsrp
...    NRCELL-13:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-13:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=70|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-13:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=90|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-2:a1MeasSCellAddEnabled=rsrp
...    NRCELL-2:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-2:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=70|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-2:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=90|a1TimeToTriggerSCellAddSsbRsrp=320ms

@{BWP_change}
...    NRBTS/BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=1
...    NRBTS/BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=2
...    NRBTS/BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=3
...    NRBTS/BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=3
...    NRBTS/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=3|searchSpaceId=1
...    NRBTS/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=1
...    NRBTS/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceId=1
...    NRBTS/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=2
...    NRBTS/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=3|searchSpaceId=3
...    NRBTS/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=3
...    NRBTS/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceId=3
...    NRBTS/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=3
...    NRBTS/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=4
...    NRBTS/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=5
...    NRBTS/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=6
...    NRBTS/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=6
...    NRBTS/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cRbStart=0
...    NRBTS/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=96
...    NRBTS/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n4|coresetId=0
...    NRBTS/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=7|coresetId=0
...    NRBTS/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|coresetId=1
...    NRBTS/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n4|coresetId=1
...    NRBTS/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=8|coresetId=1
...    NRBTS/BWP_PROFILE-3/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|coresetId=1
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=3|searchSpaceId=4
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=4
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceId=4
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=5
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=3|searchSpaceId=6
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=6
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceId=6
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=6
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=6
...    NRCELL-11:pdcchAutoConfig:fineTuneMode=disabled
...    NRCELL-11:pdcchAutoConfig:initialBWPMode=sameAsCoreset0
...    NRCELL-3:pdcchAutoConfig:fineTuneMode=disabled
...    NRCELL-3:pdcchAutoConfig:initialBWPMode=sameAsCoreset0

@{AA36_Online_Modify}
...    NRCELL-13:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-1
...    NRCELL-13:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-1

@{AA36_recovery}
...    delete:NRCELL-13:nrConnectModeProfileDN
...    delete:NRCELL-13:nrMultibandInfoProfileDN

@{CA_check_CELL1_CELL2}
...    pcid:50
...    scellIdx:0
...    pcid:51
...    scellIdx:1

@{HO_A2_Config}
...    QoS Routing Table
...    freqBandIndicatorNR 77
...    eventId eventA2

@{A3_MeasGap_check}
...    eventId eventA3
...    gapUE setup

@{HO_to_Cell13_check}
...    UE81: Intra-eNB handover from EXT_ENB-2.2 to EXT_ENB-2.13 performed
...    freqBandIndicatorNR 25
...    physCellId 62
...    eventId eventA1

@{HO_to_sim_check}
...    UE81: Inter-eNB handover from EXT_ENB-2.13 to ENB-3.1 performed
...    physCellId 381
...    eventId eventA3

@{HO_back_to_Cell13_check}
...    UE81: Inter-eNB handover from ENB-3.1 to EXT_ENB-2.13 performed
...    freqBandIndicatorNR 25
...    physCellId 62
...    eventId eventA1

@{N25_N77_N77_CA_succ}
...    rrcReconfigurationComplete
...    pcid:50, scellIdx:1
...    pcid:51, scellIdx:2
...    pcid:62, scellIdx:0
...    freqBandIndicatorNR 77

${band78}
...    freqBandIndicatorNR 78

@{AA30_online_modify}
...    NRCELL-14:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-1
...    NRCELL-14:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-1
...    NRCELL-13:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-1
...    NRCELL-13:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-1
...    NRBTS/NRCELL-4:freqBandIndicatorNR=41
...    NRCELL-4:weightForSCellSelection=15
...    delete:NRCELL-13/NRREL-2

@{AA30_recovery}
...    delete:NRCELL-14:nrConnectModeProfileDN
...    delete:NRCELL-14:nrMultibandInfoProfileDN
...    delete:NRCELL-13:nrConnectModeProfileDN
...    delete:NRCELL-13:nrMultibandInfoProfileDN
...    NRBTS/NRCELL-4:freqBandIndicatorNR=38
...    NRCELL-4:weightForSCellSelection=50
...    NRBTS:actMfbiNrCaSupportFr1=true
...    NRCELL-13/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-13/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-13/NRREL-2:isRplCellForPSCell=true
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

@{OnlineParam_enable_7219}
...    NRBTS:actMfbiNrCaSupportFr1=true

@{OnlineParam_disable_7219}
...    NRBTS:actMfbiNrCaSupportFr1=false

@{CA_check_CELL12_CELL11}
...    pcid:61
...    scellIdx:0
...    pcid:60
...    scellIdx:1
...    freqBandIndicatorNR 66
...    rrcReconfigurationComplete

@{CA_check_CELL1_CELL4}
...    pcid:61
...    scellIdx:0
...    pcid:50
...    scellIdx:2
...    pcid:53
...    scellIdx:3
...    freqBandIndicatorNR 77
...    freqBandIndicatorNR 41
...    rrcReconfigurationComplete

@{CA_check_CELL13_CELL14}
...    pcid:62
...    scellIdx:0
...    pcid:63
...    scellIdx:1
...    freqBandIndicatorNR 25
...    rrcReconfigurationComplete

@{CA_check_CELL13_CELL1_CELL4}
...    pcid:62
...    scellIdx:0
...    pcid:50
...    scellIdx:2
...    pcid:53
...    scellIdx:3
...    freqBandIndicatorNR 77
...    freqBandIndicatorNR 41
...    rrcReconfigurationComplete


@{PM_Counters_Check_for_AA32}
...    NRCELL-11:${GNB_SA_HO_ADMISSION_MFBI_REQ}=0
...    NRCELL-11:${GNB_SA_HO_ADMISSION_MFBI_SUCC}=0
...    NRCELL-11:${GNB_SA_DU_HO_ADMISS_MFBI_REQ}=0
...    NRCELL-11:${GNB_SA_DU_HO_ADMISS_MFBI_SUCC}=0
...    NRCELL-11:${GNB_DU_ADMISS_MOD_MFBI_SUCC_SA}=0
...    NRCELL-11:${GNB_DU_ADMISS_MOD_MFBI_REQ_SA}=0
...    NRCELL-3:${GNB_SA_HO_ADMISSION_MFBI_REQ}=0
...    NRCELL-3:${GNB_SA_HO_ADMISSION_MFBI_SUCC}=0
...    NRCELL-3:${GNB_SA_DU_HO_ADMISS_MFBI_REQ}=0
...    NRCELL-3:${GNB_SA_DU_HO_ADMISS_MFBI_SUCC}=0
...    NRCELL-3:${GNB_DU_ADMISS_MOD_MFBI_SUCC_SA}=0
...    NRCELL-3:${GNB_DU_ADMISS_MOD_MFBI_REQ_SA}=0
...    NRCELL-2:${UE_SCELL_2_CONF_SCELL_DL_SA}>0
...    NRCELL-1:${UE_SCELL_2_CONF_SCELL_DL_SA}>0
...    NRCELL-1:${SCELL_CONF_ALT_BAND_SA}=2
...    NRCELL-2:${SCELL_CONF_ALT_BAND_SA}=0

@{PM_Counters_Check_AA36}
...    NRCELL-1:${SCELL_CONF_ALT_BAND_SA}=2
...    NRCELL-13:${GNB_SA_HO_ADMISSION_MFBI_REQ}=3
...    NRCELL-13:${GNB_SA_HO_ADMISSION_MFBI_SUCC}=3
...    NRCELL-13:${GNB_SA_DU_HO_ADMISS_MFBI_REQ}=2
...    NRCELL-13:${GNB_SA_DU_HO_ADMISS_MFBI_SUCC}=2
...    NRCELL-13:${GNB_DU_ADMISS_MOD_MFBI_REQ_SA}=1
...    NRCELL-13:${GNB_DU_ADMISS_MOD_MFBI_SUCC_SA}=1
...    NRCELL-13:${GNB_SA_ADMISSION_MFBI_REQ}=0
...    NRCELL-13:${GNB_SA_ADMISSION_MFBI_SUCC}=0
...    NRCELL-13:${GNB_SA_DU_ADMISSION_MFBI_REQ}=0
...    NRCELL-13:${GNB_SA_DU_ADMISSION_MFBI_SUCC}=0
...    NRCELL-1:${UE_SCELL_2_CONF_SCELL_DL_SA}>0
...    NRCELL-2:${UE_SCELL_2_CONF_SCELL_DL_SA}>0

@{PM_Counters_Check_for_AA30}
...    NRCELL-1:${SCELL_CONF_ALT_BAND_SA}=2
...    NRCELL-4:${SCELL_CONF_ALT_BAND_SA}=0
...    NRCELL-11:${SCELL_CONF_ALT_BAND_SA}=0
...    NRCELL-13:${SCELL_CONF_ALT_BAND_SA}=0

${SCELL_CONF_ALT_BAND_SA}    M55118C01005    #This counter provides the number of current cell configurations as an SA SCell in an alternative band
${GNB_SA_HO_ADMISSION_MFBI_REQ}    M55138C00503    #Number of SA user radio admission HO requests where admission is requested on alternative band.
${GNB_SA_HO_ADMISSION_MFBI_SUCC}    M55138C00504    #Number of SA user-admitted HO radio admissions where admission is done on alternative band.
${GNB_SA_DU_HO_ADMISS_MFBI_REQ}    M55139C02005    #Number of radio admission handover requests on alternative band for SA users.
${GNB_SA_DU_HO_ADMISS_MFBI_SUCC}    M55139C02006    #Number of radio-admitted handover radio resources on alternative band for SA users.
${GNB_DU_ADMISS_MOD_MFBI_REQ_SA}    M55139C02007    #Number of intra DU radio resource modification requests on alternative band for SA users.
${GNB_DU_ADMISS_MOD_MFBI_SUCC_SA}    M55139C02008    #Number of successful intra DU radio resource modifications on alternative band for SA users.
${GNB_SA_ADMISSION_MFBI_REQ}    M55138C00501
#This counter provides the number of radio admission requests for the SA user, where admission is requested on the alternative band.
${GNB_SA_ADMISSION_MFBI_SUCC}    M55138C00502
#This counter provides the number of admitted radio admission requests for the SA user, where admission is done on the alternative band.
${GNB_SA_DU_ADMISSION_MFBI_REQ}    M55139C02001
#This counter provides the number of radio admission requests with MFBI for the SA user.
${GNB_SA_DU_ADMISSION_MFBI_SUCC}    M55139C02002
#This counter provides the number of radio-admitted UEs for the SA user using the alternative band.
${UE_SCELL_2_CONF_SCELL_DL_SA}    M55118C07002
#This counter indicates the sum of samples for the total number of CA UEs in the current cell configured as an SCell with 2 configured SCells
# in DL in SA mode. The counter is pegged in the secondary cell.


${N66_N77_N77_and_N66_N77_and_N66_N78}    SEPARATOR=
...    E9A09000575F5A13160003C4A0002C1262E003387A16009B20C39F30C7942C0E0980C0311C06EE3614606B04610D04083A41E006D6C98AB1
...    A1CF88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E007FE000C80000E0541B107582308682041E20F0032B64C55890E7D
...    813E238F1891C790E7D473E618F28581C0E1E13FFE00000FFF800000C80000E0551B137582308682041D20F002CB64C550D0E7C471E819F6
...    04F8C73E618F28581C0E1E05C00FFC007003FF000640000702A0D831AC1184341020F941E00656C98AB121CF88E3D813E31238F21CFA8E7C
...    C31E50B0381C3C27FFC00001FFF000001900001C0AE3612EB04610D04083A41E006D6C98AB1A1CF88E3D033EC09F1891C790E7D473E618F2
...    8581C0E1E0B801FF800E007FE000C80000E0551B133582308682041D20F002CB64C550D0E7C471E819F604F8C73E618F28581C0E1E05C00F
...    FC007003FF000640000702A0D88DAC1184341020F941E00656C98AB121CF88E3D813E31238F21CFA8E7CC31E50B0381C3C27FFC00001FFF0
...    00001900001C00E787882001C4C000000160205E1E1280071340000085808178B882001C4C000E260000020B0102F17060003830001C1800
...    0006160205E1E14000713400002058081707850001C4100000A160205E1E20800711800003058081787882001C4D00000E160205E2E14000
...    71040038820000202C040BC5C28000E2300071180000485808178B882001C41000E2300000A0B0102F1710400388C001C46000016160205E
...    1E2300071340000605808178F830001C41000E23000713000006858081007011A014404D808232800AF07428913639F0E14489B1CF871224
...    489B1CF871224489B1CF870A244D8E7C3851226C73E1C28913639F0E14489B1CF871224489B1CF871224489B1CF871224489B1CF87122448
...    9B1CF870A244D8E7C38D1224489B1CF86150E18C6318C6318C6318DFBFFFFF0D80078005038280381804A00E000C0480080C07C070040000
...    00020000040100000400800003004000020020000140100000C0080000701D81959515931591B58335831581B59534070400002594941000
...    0196525040000A594941000039652504000125949410000596525040001A594941000079652501D40EAA9555526AAA479541B2A8355503CA
...    A559434004800D02800342020040080802004101008010040100210080100202008010080200420100E01C04038070100E01C20200C01808
...    0200410100400804008010808040080200400840400801010040084020080100801002020040088040100201002004040080110080100202
...    0040080801002201002004040080101002004202004008080200430300C01A01402818010030020040C0080180100206020044010021AA1F
...    000102030406070A0B0C0D101112131418191B1C1D1F2125262728292A2D2F414182D0

${N25A_N77(2A)_and_N25A_N78A_and_N25A_N77A}    SEPARATOR=
...    E9A09000575F5A13160003C320016093170019C3D09009B20C39F30C7942C0E09804062380DDC6C28C0D608C21A08107482406D6C98AB1A1
...    CF88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E007FE00098000702A0D883AC1184341020F10480CAD931562439F604F
...    88E3C62471E439F51CF9863CA1607038784FFF800003FFE00000260001C0AA3626EB04610D04083A41202CB64C550D0E7C471E819F604F8C
...    73E618F28581C0E1E05C00FFC007003FF0004C000381506C18D608C21A08107CA090195B262AC4873E238F604F8C48E3C873EA39F30C7942
...    C0E070F09FFF000007FFC000004C0003815C6C25D608C21A08107482406D6C98AB1A1CF88E3D033EC09F1891C790E7D473E618F28581C0E1
...    E0B801FF800E007FE00098000702A8D899AC1184341020E90480B2D931543439F11C7A067D813E31CF9863CA16070387817003FF001C00FF
...    C00130000E0541B11B582308682041F28240656C98AB121CF88E3D813E31238F21CFA8E7CC31E50B0381C3C27FFC00001FFF00000130000E
...    008BC3C41000E230000000B0102F0F09400389A0000042C040BC5C28000E20800711800001058081787830001C4C000006160205E1E14000
...    713400002058081707850001C4100000A160205E1E20800711800003058081787830001C4D00000E160205E2E1400071040038820000202C
...    040BC5C28000E2300071180000485808178B882001C41000E2300000A0B0102F1710400388C001C46000016160205E1E2300071340000605
...    808178F882001C41000E2080071040000685808178F882001C4C000E2600071300000705808178B830001C4C000E2600000F0B0102F1F104
...    003882001C4D000E268000100B01020120234028809B010602607A06C84614489B1CF870A244D8E7C38912244D8E7C3851226C73E1C28913
...    639F0E14489B1CF870A244D8E7C3851226C73E1C4891226C73E1C4891226C73E1C4891226C73E1C4891226C73E1C28913639F0E344891226
...    C73E1C68912244D8E7C38912244D8E7C38D1224489B1CF8600C888C6318C6318C6318C6318CF413003C00281C1401C0C0250070006024004
...    0603E040020000000100000200800002004000018020000100100000A0080000600400003802000020086065654D64C5646D60CD60C56065
...    654D654D01C1000009652504000065949410000296525040000E594941000049652504000165949410000696525040001E5949407503AAA5
...    55549AAA91E5506CAA0D5540F2A956509004800D028004020200400808010021010080100401002100802004020040080801002101002004
...    0401002080803006020080104040100201002004202010020080100210100200404010021008020040200400808010022010040080400801
...    010020044020040080801002020040088040080101002004040080108080100202008010C0C0300680500A0600400C008010300200600400
...    81808011004008602004008080800402020010080800420100E00404048030101200C60201C00808070020202401808090063543E0002040
...    6080C0E1416181A2022242628303236383A3E424A4C4E5052545A5E828305A

${N66_N66_and_N41_N66_N77_and_N41_N66}    SEPARATOR=
...    E9A09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C4701BB8D85181AC1184341020E9068036B64C558D
...    0E7C471E819F604F8C48E3C873EA39F30C7942C0E070F05C00FFC007003FF0005C0000E0541B107582308682041E20D00656C98AB121CFB0
...    27C471E31238F21CFA8E7CC31E50B0381C3C27FFC00001FFF00000170000381546C4DD608C21A0810748340165B262A86873E238F40CFB02
...    7C639F30C7942C0E070F02E007FE003801FF8002E0000702A0D831AC1184341020F941A00CAD931562439F11C7B027C62471E439F51CF986
...    3CA1607038784FFF800003FFE000002E0000702B8D84BAC1184341020E9068036B64C558D0E7C471E819F604F8C48E3C873EA39F30C7942C
...    0E070F05C00FFC007003FF0005C0000E0551B133582308682041D20D00596C98AA1A1CF88E3D033EC09F18E7CC31E50B0381C3C0B801FF80
...    0E007FE000B80001C0A836236B04610D04083E5068032B64C55890E7C471EC09F1891C790E7D473E618F28581C0E1E13FFE00000FFF80000
...    0B80001C00E787882001C4C000000160205E1E1280071300000085808178B882001C28000E260000020B0102F17060003830001C18000006
...    160205E1E14000713000002058081707850001C4100000A160205E1E20800711800003058081787882001C4C00000E160205E2E140007104
...    0038820000202C040BC5C28000E2300071180000485808178B882001C41000E2300000A0B0102F1710400388C001C46000016160205E1E23
...    00071300000605808178F830001C41000E23000713000006858081007011A014404D80822E8015E0E851226C73E1C28913639F0E24489136
...    39F0E2448913639F0E14489B1CF870A244D8E7C3851226C73E1C28913639F0E2448913639F0E2448913639F0E2448913639F0E2448913639
...    F0E14489B1CF871A2448913639F0C2A1C318C6318C6318C631BF7FFFFE17001E00140E0A00E0601280380030120020301F01C01000000008
...    000010040000100200000C01000008008000050040000300200001C076065654564C5646D60CD60C5606D654D01C10000096525040000659
...    49410000296525040000E594941000049652504000165949410000696525040001E5949407503AAA555549AAA91E5506CAA0D5540F2A9565
...    0B0024006814001A1010020040401002080804008020080108040080101004008040100210080700E0201C038080700E10100600C0401002
...    0808020040200400840402004010020042020040080802004201004008040080101002004402008010080100202004008804008010100200
...    40400801100801002020040080801002101002004040100218180600D00A0140C008018010020600400C0080103010022008010D50F80008
...    10182030385058606880889098A0C0C8D8E0E8F909293139414951697A0A0C1680

${N66_N66_and_N41_N66}    SEPARATOR=
...    E9A09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C4701BB8D85181AC1184341020E9068036B64C558D
...    0E7C471E819F604F8C48E3C873EA39F30C7942C0E070F05C00FFC007003FF0005C0000E0541B107582308682041E20D00656C98AB121CFB0
...    27C471E31238F21CFA8E7CC31E50B0381C3C27FFC00001FFF00000170000381546C4DD608C21A0810748340165B262A86873E238F40CFB02
...    7C639F30C7942C0E070F02E007FE003801FF8002E0000702A0D831AC1184341020F941A00CAD931562439F11C7B027C62471E439F51CF986
...    3CA1607038784FFF800003FFE000002E0000702B8D84BAC1184341020E9068036B64C558D0E7C471E819F604F8C48E3C873EA39F30C7942C
...    0E070F05C00FFC007003FF0005C0000E0551B133582308682041D20D00596C98AA1A1CF88E3D033EC09F18E7CC31E50B0381C3C0B801FF80
...    0E007FE000B80001C0A836236B04610D04083E5068032B64C55890E7C471EC09F1891C790E7D473E618F28581C0E1E13FFE00000FFF80000
...    0B80001C00E787882001C28000000160205E1E1280071340000085808178B882001C28000E140000020B0102F17060003830001C18000006
...    160205E1E14000713400002058081707850001C4100000A160205E1E20800711800003058081787882001C2800000E160205E2E140007104
...    0038820000202C040BC5C28000E2300071180000485808178B882001C41000E2300000A0B0102F1710400388C001C46000016160205E1E23
...    00071340000605808178F830001C41000E2300070A000006858081007011A014404D80822E8015E0E851226C73E1C28913639F0E24489136
...    39F0E2448913639F0E14489B1CF870A244D8E7C3851226C73E1C28913639F0E2448913639F0E2448913639F0E2448913639F0E2448913639
...    F0E14489B1CF871A2448913639F0C2A1C318C6318C6318C631BF7FFFFE17001E00140E0A00E0601280380030120020301F01C01000000008
...    000010040000100200000C01000008008000050040000300200001C076065654564C5646D60CD60C5606D654D01C10000096525040000659
...    49410000296525040000E594941000049652504000165949410000696525040001E5949407503AAA555549AAA91E5506CAA0D5540F2A9565
...    0B0024006814001A1010020040401002080804008020080108040080101004008040100210080700E0201C038080700E10100600C0401002
...    0808020040200400840402004010020042020040080802004201004008040080101002004402008010080100202004008804008010100200
...    40400801100801002020040080801002101002004040100218180600D00A0140C008018010020600400C0080103010022008010D50F80008
...    10182030385058606880889098A0C0C8D8E0E8F909293139414951697A0A0C1680

${N25_N25_and_N25_N41_N77_and_N25_N41}    SEPARATOR=
...    E9A09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C4701BB8D85181AC1184341020E9068036B64C558D
...    0E7C471E819F604F8C48E3C873EA39F30C7942C0E070F05C00FFC007003FF0005C0000E0541B107582308682041E20D00656C98AB121CFB0
...    27C471E31238F21CFA8E7CC31E50B0381C3C27FFC00001FFF00000170000381546C4DD608C21A0810748340165B262A86873E238F40CFB02
...    7C639F30C7942C0E070F02E007FE003801FF8002E0000702A0D831AC1184341020F941A00CAD931562439F11C7B027C62471E439F51CF986
...    3CA1607038784FFF800003FFE000002E0000702B8D84BAC1184341020E9068036B64C558D0E7C471E819F604F8C48E3C873EA39F30C7942C
...    0E070F05C00FFC007003FF0005C0000E0551B133582308682041D20D00596C98AA1A1CF88E3D033EC09F18E7CC31E50B0381C3C0B801FF80
...    0E007FE000B80001C0A836236B04610D04083E5068032B64C55890E7C471EC09F1891C790E7D473E618F28581C0E1E13FFE00000FFF80000
...    0B80001C00E787882001C4C000000160205E1E1280071340000085808178B830001C28000E260000020B0102F17060003830001C18000006
...    160205E1E14000713400002058081707850001C1800000A160205E1E20800711800003058081787882001C4C00000E160205E2E140007104
...    0038820000202C040BC5C28000E2300071180000485808178B882001C41000E2300000A0B0102F1710400388C001C46000016160205E1E23
...    00071340000605808178F830001C41000E23000713000006858081007011A014404D80822E8015E0E851226C73E1C28913639F0E24489136
...    39F0E2448913639F0E14489B1CF870A244D8E7C3851226C73E1C28913639F0E2448913639F0E2448913639F0E2448913639F0E2448913639
...    F0E14489B1CF871A2448913639F0C2A1C318C6318C6318C631BF7FFFFE17001E00140E0A00E0601280380030120020301F01C01000000008
...    000010040000100200000C01000008008000050040000300200001C076065654564C5646D60CD60C5606D654D01C10000096525040000659
...    49410000296525040000E594941000049652504000165949410000696525040001E5949407503AAA555549AAA91E5506CAA0D5540F2A9565
...    0B0024006814001A1010020040401002080804008020080108040080101004008040100210080700E0201C038080700E10100600C0401002
...    0808020040200400840402004010020042020040080802004201004008040080101002004402008010080100202004008804008010100200
...    40400801100801002020040080801002101002004040100218180600D00A0140C008018010020600400C0080103010022008010D50F80008
...    10182030385058606880889098A0C0C8D8E0E8F909293139414951697A0A0C1680

*** Test Cases ***
CB007219_AA32_Interaction_with_inter-frequency_mobility_where_the_target_cell_shares_the_same_frequency_of_a_configured_Scell
    [Documentation]
    ...    1. This user scenario describes the gNB behavior when a UE is configured CA with at least one MFBI SCell is configured on alternative
    ...    band and a inter-frequency target cell exists which shares the same frequency of SCell configured with alternative band.
    ...    2. Configuration
    ...    CB007219:NRBTS/actMfbiNrCaSupportFr1 is set to "true"
    ...    5GC001416:NRBTS/actMultiFrequencyBandIndicatorNRSupport=true
    ...    Cell configuration:    Cell_11    Cell_12    Cell_13    Cell_14    Cell_1    Cell_2    Cell_3    Cell_4
    ...    Technology type    FDD    FDD    FDD    FDD    TDD    TDD    TDD    TDD
    ...    Frequency    F0    F1    F2    F3    F4    F5    F6    F5
    ...    Common channel bandwidth    20    20    20    20    100    100    100    20
    ...    Small BWP DL MIMO Layers    4L    4L    2L    2L    4L    4L    4L    4L
    ...    Native band    N66    N66    N2    N2    N78    N77    N78    N38
    ...    Alternative band    NA    NA    NA    NA    N77    NA    N77    NA
    ...    The frequency for cell1=cell3. Inter-frequency HO is enabled on Cell 11. cell3 is inter-freq HO target cell.
    ...    A1 for pcell change is configured for cell1 and cell2.
    ...    UE1 capability: CA relation: cell11+cell1+cell2,A1 scell addition
    ...    BC#1: N66A_N77(2A)
    ...    BC#2: N66A_N77A
    ...    BC#3: N66A_N78A
    ...    3. Test Case Steps:
    ...    a. attach UE1 to cell11 and trigger A1 for scell addition. start UL/DL traffic.
    ...    expected cell1 and cell2 are added scell successfully with BC1. cell1 and cell2 are configured in n77. traffic is OK. A2 for scell
    ...    release, A1 for pcell switch is configured to UE with n77 for cell1 and cell2. A2 for mobility is configured for pcell with n66. traffic
    ...    is OK.
    ...    b. trigger A2 for mobility.
    ...    expected measurement gap setup. A3/A5/A1 for mobility is configured to UE with n77.
    ...    c. trigger A2 for scell release for cell1.
    ...    expected scell1 is released successfully. scell2 has no impact. traffic is OK.
    ...    d. trigger A2 for scell release for cell2.
    ...    expected scell2 is released successfully. traffic is OK.
    ...    e. trigger A3 for mobility from cell11 to cell3.
    ...    expected UE HO to cell3 with n78 successfully. traffic is OK.
    ...    f. release UE and UE is released successfully.
    ...    g. attach UE1 to cell11 and trigger A2 for mobility.
    ...    expected measurement gap setup. A3/A5/A1 for mobility is configured to UE with n78.
    ...    h. trigger A1 for scell addition.
    ...    expected cell1 and cell2 are added scell successfully with BC1. cell1 and cell2 are configured in n77. traffic is OK. gNB re-configures
    ...    measurement object for cell1 with band N77 and configures A2 measurement for SCell release and A1 measurement for PCell switch on SCells
    ...    Cell 1 and Cell 2.
    ...    i. repeat stepc/d/e and same result as stepc/e/f.
    ...    j. check counters.
    [Tags]    QC_46776    christine.chen    AA32    CA_LABEL-FTT(20MHZ_FDD_n66+100MHZ_FDD_n77+100MHZ_FDD_n77)
    UE register and Scell added then trigger A2 HO mobility
    Trigger scell1 release
    Trigger scell2 release
    Trigger A3HO and check traffic then UE deregister
    UE register and trigger A2 HO mobility then Scell added
    Trigger scell1 release
    Trigger A3HO and check traffic then UE deregister
    Check Wireshark Log    ${CURDIR}${/}A2A_AA32${/}a2a.ini    wait_string=UEContextReleaseComplete::8
    Check Counters    ${PM_Counters_Check_for_AA32}

CB007219-ET-AA36_Successful CA configuration with MFBI after an incoming hand over
    [Documentation]
    ...    1. This user scenario describes the successful operation of blind SCell Addition after an incoming hand over where the list of
    ...    cells to be aggregated contains MFBI PCell/SCell(s)
    ...    2. Configuration
    ...    NRBTS/actMfbiNrCaSupportFr1=true
    ...    NRBTS/actMultiFrequencyBandIndicatorNRSupport=true
    ...    alternative band configuration as below:
    ...    Cell configuration:         Cell_11    Cell_12    Cell_13    Cell_14    Cell_1    Cell_2    Cell_3    Cell_4
    ...    Technology type             FDD        FDD        FDD        FDD        TDD       TDD       TDD       TDD
    ...    Frequency                   F0         F1         F2         F3         F4        F5        F6        F5
    ...    Common channel bandwidth    20         20         20         20         20        20        20        20
    ...    Small BWP DL MIMO Layers    4L         4L         2L         2L         4L        4L        4L        4L
    ...    Native band                 N66        N66        N2         N2         N78       N77       N78       N38
    ...    Alternative band            NA         NA         N25        NA         N77       NA        N77       NA
    ...    simulator gNB configured with band in n77 and with the same frequency with cell2.
    ...    NG HO is configured.
    ...    CA relation: cell13+cell1+cell2, A1 scell addition.
    ...    UE Capability:
    ...    BC#1: CA_n25A-n78A
    ...    BC#2: CA_n25A-n77A
    ...    BC#3: CA_n25A-n77(2A)
    ...    3. Test Case Steps:
    ...    1). Attach UE81 to cell2, Start DL/UL traffic.
    ...    2). Trigger A2 and A3 inter frequency HO from cell2 to cell13.
    ...    3). Online modify NRBTS/actMfbiNrCaSupportFr1 from true to false.
    ...    4). Trigger A1 for scell addition.
    ...    5). Online change actMfbiNrCaSupportFr1 from false to true.
    ...    6). Trigger A1 for scell addition.
    ...    7). Trigger inter frequency NG HO from cell13 to sim gNB and back.
    ...    8). Repeat Step3 to Step6.
    ...    9). check counters.
    ...    4. Expectation:
    ...    1). UE81 attach successfully, Traffic is OK.
    ...    2). Measurement gap setup after A2. then HO to cell13 successfully. A1 for scell addition is configured to UE.
    ...    3). Online modification is successful.
    ...    4). No scell added as pcell in alternative band 7219 disabled.
    ...    5). Online modification is successful.
    ...    6). Cell1 and cell2 are added as scells. BC#3 is selected. cell13 in n25. cell1 and cell2 in n77.
    ...    7). HO and back successfully.
    ...    8). The same as Step3 to Step6.
    ...    9). Counters should be updated correctly.
    [Tags]    QC_321440    jing.ye    AA36    CA_LABEL-FTT(20MHZ_FDD_n25+100MHZ_TDD_n77+100MHZ_TDD_n77)
    Clear Counter Files
    OnlineParamChange    ${AA36_Online_Modify}
    Attach UE to Target Cell    ue_id=81    cell_id=2    pass_check=${HO_A2_Config}
    HO From Cell2 to Cell13 Should Success
    Repeat Steps
    Release Ues    ue_type=all
    Check Counters    pm_counters_expression=${PM_Counters_Check_AA36}
    [Teardown]    AA36_Teardown

CB007219_AA30_Interaction_with_A1_measurement_based_SCell_change
    [Documentation]
    ...    1. This user scenario describes the gNB behaviour when MFBI is enabled on a potential candidate SCells and A1 measurement report for 
    ...    SCell change is received for a UE.
    ...    2. Configuration
    ...    CB007219:NRBTS/actMfbiNrCaSupportFr1 is set to "true"
    ...    5GC001416:NRBTS/actMultiFrequencyBandIndicatorNRSupport=true
    ...    Cell configuration:    Cell_11    Cell_12    Cell_13    Cell_14    Cell_1    Cell_2    Cell_3    Cell_4
    ...    Technology type    FDD    FDD    FDD    FDD    TDD    TDD    TDD    TDD
    ...    Frequency    F0    F1    F2    F3    F4    F5    F6    F5
    ...    Common channel bandwidth    20    20    20    20    100    100    100    20
    ...    Small BWP DL MIMO Layers    4L    4L    2L    2L    4L    4L    4L    4L
    ...    Native band    N66    N66    N2    N2    N78    N77    N78    N41
    ...    Alternative band    NA    NA    N25    N25    N77    NA    N77    NA
    ...    UE1 capability: CA relation: cell12+cell11+cell1+cell4,A1 scell addition
    ...    BC#1: N66(2A)
    ...    BC#2: N41A_N66A_N77A
    ...    BC#3: N41A_N66A
    ...    UE2 capability: CA relation: cell12+cell11+cell1+cell4,A1 scell addition
    ...    BC#1: N66(2A)
    ...    BC#2: N41A_N66A
    ...    UE3 capability: CA relation: cell13+cell14+cell4+cell1,A1 scell addition
    ...    BC#1: N25(2A)
    ...    BC#2: N25A-N41A-N77A
    ...    BC#3: N25A-N41
    ...    3. Test Case Steps:
    ...    a. attach UE1 and UE2 to cell12 and trigger A1 for scell addition lower than TDD threshold. start UL/DL traffic.
    ...    expected cell11 is added scell successfully with BC1. cell11 and cell12 are configured in n66. traffic is OK. A1 for scell change
    ...    is configured. Traffic is OK.
    ...    b. online disable 7219. trigger A1 scell change for UE1 and UE2.
    ...    expected SCell change is not triggered for UE1 (as alternative band n77 will not be considered for Cell1 since CB007219 FAF is not enabled
    ...    and the total bandwidth without Cell1 is not higher with TDD SCell compared to the already configured FDD SCell).  
    ...    SCell change is not triggered for UE2 (as the total bandwidth is not higher with TDD SCell compared to the already configured FDD SCell,
    ...    since it does not support N78/N77)
    ...    c. online enable 7219. trigger A1 scell change for UE1 and UE2.
    ...    expected UE1 undergoes an SCell change with Cell 1 and Cell 4 as SCells.
    ...    SCell change is not triggered for UE2 (as the total bandwidth is not higher with TDD SCell compared to the already configured FDD SCell,
    ...    since it does not support N78/N77 )
    ...    d. attach UE3 to cell13 and trigger A1 for scell addition lower than TDD threshold. start UL/DL traffic.
    ...    expected expected cell14 is added scell successfully with BC1. cell13 and cell14 are configured in n25. traffic is OK. A1 for scell change
    ...    is configured. Traffic is OK.
    ...    e. online disable 7219. trigger A1 scell change for UE3.
    ...    expected SCell change is not triggered for UE3 (as as PCell is in alternative band n25 and since CB007219 FAF is not enabled,
    ...    no CA band combination will be generated. However, exsiting SCell Cell1 will not be released. )
    ...    f. online enable 7219. trigger A1 scell change for UE3.
    ...    expected SCell change is triggered and cell1 and cell4 are added as scell with BC2. cell1 in n77 and cell4 in n41.
    ...    g. check counters.
    [Tags]    QC_321443    jiadan.wu    AA30    CA_LABEL-FF(20MHZ_FDD_n66+20MHZ_FDD_n66)    CA_LABEL-FF(20MHZ_FDD_n25+20MHZ_FDD_n25)
    ...    CA_LABEL-FTT(20MHZ_FDD_n66+100MHZ_TDD_n77+20MHZ_TDD_n41)    CA_LABEL-FTT(20MHZ_FDD_n25+100MHZ_TDD_n77+20MHZ_TDD_n41)
    Clear Counter Files
    OnlineParamChange    ${AA30_online_modify}
    UE1 UE2 pcell native scell change and online modify FAF
    UE3 pcell alternative scell change and online modify FAF
    Release Ues    ue_type=all
    Check Counters    ${PM_Counters_Check_for_AA30}
    [Teardown]    AA30_Teardown

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/8cells_4T4F_2N2_2N66_3N78_N38    ue_count=15

Modify Cfg
    ${gnb3_cell1}    catenate
    ...    set_cell id=1 gnb=3 pci=127:0 tac=200 nrci=0x01
    ...    tdd_cell=on proxy=10.0.2.91:9999 nr_arfcn=648096:648096 gscn=8000 mandatory_for_activation=off
    Update Cfg    ${gnb3_cell1}

AA36_Teardown
    OnlineParamChange    ${AA36_recovery}
    Common Test Teardown And Stop Capture Logs

AA30_Teardown
    OnlineParamChange    ${AA30_recovery}
    Common Test Teardown And Stop Capture Logs

Update UE capa
    [Arguments]    ${SA_Capa_perUE_Full}=none    ${ue_id}=81
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full}
    Execute Egate Command    ${cmd}

UE register and Scell added then trigger A2 HO mobility
    Clear Counter Files    wait=${False}
    Ue register and pdu session setup    ${N66_N77_N77_and_N66_N77_and_N66_N78}    ue_id=81    cell_id=11
    Trigger MR scelladd    ${CA_check_CELL1_CELL2}    ue_id=81    carrierfreq=424090
    Send Throuput and check Throuput for two scell    ue_id=81    times=10    min_dl_tput=945
    Trigger A2 measurement report    ue_id=81    carrierfreq=424090

UE register and trigger A2 HO mobility then Scell added
    Ue register and pdu session setup    ${N66_N77_N77_and_N66_N77_and_N66_N78}    ue_id=81    cell_id=11
    Send Throuput and check Throuput for pcell    ue_id=81    times=10    min_dl_tput=138
    Trigger A2 measurement report    ue_id=81    carrierfreq=424090
    Trigger MR scelladd    ${CA_check_CELL1_CELL2}    ue_id=81    carrierfreq=424090
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=81    cell_num=3    min_dl_tput=945

Trigger scell1 release
    Trigger A2 ScellRelease    carrierfreq=640416    ue_id=81    scell_id=1
    Wait Until Keyword Succeeds    30s    10s    Check Throuput for one scell    ue_id=81    min_dl_tput=500

Trigger scell2 release
    Trigger A2 ScellRelease    carrierfreq=648096    ue_id=81    scell_id=2
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=81    cell_num=1    min_dl_tput=60

Trigger A3HO and check traffic then UE deregister
    Trigger A3 Measurement Report    ue_id=81    carrierfreq=640416    phycelId=52
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=81    cell_num=1    min_dl_tput=600
    UE Deregister From gNB    ue_id=81

Ue register and pdu session setup
    [Arguments]    ${SA_Capa_perUE_Full}=null    ${ue_id}=1    ${cell_id}=2    ${gw_id}=1
    Update UE capa    ${SA_Capa_perUE_Full}    ${ue_id}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=UE now in NG RM Registere
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${gw_id}    pass_regexp=QoS Routing Table

Trigger MR scelladd
    [Arguments]    ${scell_added_log}    ${ue_id}=81    ${carrierfreq}=650016    ${srsrp_nr}=100
    ${meas_id}=    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A1
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=${srsrp_nr} srsrq_nr=52
    ...    pass_regexp=${scell_added_log}
Trigger MR scellchange and no scell change happen
    [Arguments]    ${ue_id}=81    ${carrierfreq}=650016    ${srsrp_nr}=100
    ${meas_id}=    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A1
    ${ret}    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=${srsrp_nr} srsrq_nr=52
    ...    pass_regexp=measurementReport    fail_regexp=rrcReconfigurationComplete

Trigger A2 ScellRelease
    [Arguments]    ${carrierfreq}=508110    ${ue_id}=81    ${scell_id}=3
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}    event_type=A2    carrierfreq=${carrierfreq}
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 scell=${scell_id} scell_rsrp=7 scell_rsrq=7
    ...    pass_regexp=rrcReconfigurationComplete

Send Throuput and check Throuput for pcell
    [Arguments]    ${ue_id}=83    ${times}=8    ${min_dl_tput}=645
    Send Throughput    ue_id=${ue_id}    times=${times}
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=${ue_id}    cell_num=1    min_dl_tput=${min_dl_tput}

Send Throuput and check Throuput for two scell
    [Arguments]    ${ue_id}=83    ${times}=10    ${min_dl_tput}=945
    Send Throughput    ue_id=${ue_id}    times=${times}
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=${ue_id}    cell_num=3    min_dl_tput=${min_dl_tput}

Check Throuput for one scell
    [Arguments]    ${ue_id}=81    ${cell_dl}=20    ${min_dl_tput}=945    ${ul}=8
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000 > ${cell_dl}
    ${scell2_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=2    type=pdsch    rate_type=ave
    Should Be True    ${scell2_tput}/1000 > ${cell_dl}
    ${total_dl_tput}    Evaluate    ${scell0_tput}+${scell2_tput}
    Should Be True    ${total_dl_tput}/1000 > ${min_dl_tput}
    ${ul_throughput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pusch    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul}

Send Throughput
    [Arguments]    ${ue_id}=81    ${times}=3    ${mbps}=150
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=ul mbps=10 trf_id=1    UE ${ue_id}: UDP UL
    FOR    ${I}    IN RANGE    2    ${times}
        Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=${mbps} trf_id=${I}    UE ${ue_id}: UDP DL
    END

Check Traffic
    [Arguments]     ${ue_id}=81    ${cell_num}=1    ${min_dl_tput}=20    ${min_ul_tput}=8
    ${dl_throuput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=ave
    ${ul_throuput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pusch    rate_type=ave
    ${total_dl_tput}    Set Variable    0
    FOR    ${index}    IN RANGE    0    ${cell_num}
         ${str_index}    Convert To String    ${index}
         ${scell_tput}    Ap Get Throuput On Specific Scell    ${ue_id}    ${str_index}    pdsch
         Should Be True    ${scell_tput}/1000 > 20
         ${total_dl_tput}    Evaluate    ${scell_tput}+${total_dl_tput}
    END
    Should Be True    ${total_dl_tput}/1000 > ${min_dl_tput}
    Should Be True    ${ul_throuput}/1000 > ${min_ul_tput}

UE Deregister From gNB
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s

Trigger A2 measurement report
    [Arguments]    ${ue_id}    ${carrierfreq}
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A2
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 srsrp_nr=30 srsrq_nr=30
    ...    pass_regexp=rrcReconfigurationComplete

Trigger A3 Measurement Report
    [Arguments]    ${ue_id}    ${carrierfreq}    ${phycelId}
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A3
    ${V3}    catenate
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=${phycelId} nrsrp_nr=60 nrsrq_nr=60
    Execute Egate Command    ${V3}    pass_regexp=Intra-eNB handover from EXT_ENB-2.11 to EXT_ENB-2.3 performed

Repeat Steps
    [Arguments]     ${times}=2
    FOR    ${index}    IN RANGE    0    ${times}
        OnlineParamChange    ${OnlineParam_disable_7219}
        Trigger A1 MR For Scell Addition Should Fail
        OnlineParamChange    ${OnlineParam_enable_7219}
        Trigger A1 MR For Scell Addition Should Success
        HO From Cell13 to sim-gNB and Back Should Success
    END
 
HO From Cell2 to Cell13 Should Success
    Send MR And Check    carrierfreq=648096    event=A2    pass_check=${A3_MeasGap_check}
    Send A3 MR And Check    pass_check=${HO_to_Cell13_check}
    Wait Until Keyword Succeeds    30s    5s    Check Traffic    min_dl_tput=150

Trigger A1 MR For Scell Addition Should Fail
    Trigger MR scelladd Only With Error Check    rsrp=100    ue_id=81    carrierfreq=388830    fail_check=rrcReconfigurationComplete

Trigger A1 MR For Scell Addition Should Success
    Trigger MR scelladd With Error Check    rsrp=100    ue_id=81    carrierfreq=388830    pass_check=${N25_N77_N77_CA_succ}
    ...    fail_check=${band78}
    Wait Until Keyword Succeeds    30s    5s    Check Traffic    cell_num=3    min_dl_tput=480

HO From Cell13 to sim-gNB and Back Should Success
    Send MR And Check    carrierfreq=388830    event=A2    pass_check=${A3_MeasGap_check}
    Send A3 MR And Check    carrierfreq=648096    phycell_id=381    pass_check=${HO_to_sim_check}
    Send A3 MR And Check    pass_check=${HO_back_to_Cell13_check}
    Wait Until Keyword Succeeds    30s    5s    Check Traffic    min_dl_tput=150

Attach UE to Target Cell
    [Arguments]    ${ue_id}=81    ${cell_id}=3    ${pass_check}=${EMPTY}
    Update UE capa    ${N25A_N77(2A)_and_N25A_N78A_and_N25A_N77A}    ue_id=${ue_id}
    Execute Egate Command    gnb_param id=3 xn_listening_socket=1 send_xn_setup=false measEvent=A3 sa_ho=ng_based
    Ue register and pdu session setup Without UE Capa Update    pass_check=${pass_check}    ue_id=${ue_id}    cell_id=${cell_id}
    Send Throughput    times=6
    Wait Until Keyword Succeeds    30s    5s    Check Traffic    min_dl_tput=480

Ue register and pdu session setup Without UE Capa Update
    [Arguments]    ${pass_check}    ${ue_id}=1    ${cell_id}=2
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=UE now in NG RM Registere
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=1    pass_regexp=${pass_check}

Trigger MR scelladd Only With Error Check
    [Arguments]    ${rsrp}=80    ${pass_check}=${EMPTY}    ${fail_check}=${EMPTY}    ${ue_id}=81    ${carrierfreq}=424090
    ${meas_id}=    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A1
    ${ret}    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=${rsrp} srsrq_nr=52
    ...    fail_regexp=${fail_check}

Trigger MR scelladd With Error Check
    [Arguments]    ${rsrp}=80    ${pass_check}=${EMPTY}    ${fail_check}=${EMPTY}    ${ue_id}=81    ${carrierfreq}=424090
    ${meas_id}=    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A1
    ${ret}    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=${rsrp} srsrq_nr=52
    ...    pass_regexp=${pass_check}
    Should Not Contain    ${ret}    ${fail_check}

Send MR And Check
    [Arguments]    ${ue_id}=81    ${carrierfreq}=648096    ${event}=A2    ${rsrp}=11    ${pass_check}=gapOffset
    ${meas_id}=    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=${event}
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event} srsrp_nr=${rsrp} srsrq_nr=${rsrp}
    ...    pass_regexp=${pass_check}

Send A3 MR And Check
    [Arguments]    ${ue_id}=81    ${carrierfreq}=388830    ${phycell_id}=62    ${rsrp}=80    ${pass_check}=handover
    ${meas_id}=    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A3
    ${cmd}    catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=${phycell_id}
    ...    nrsrp_nr=${rsrp} nrsrq_nr=${rsrp}
    Execute Egate Command    ${cmd}    pass_regexp=${pass_check}

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir

UE1 UE2 pcell native scell change and online modify FAF
    UE1 UE2 scell addition with FAF true
    UE1 UE2 scell change with FAF false
    UE1 UE2 scell change with FAF true
    Release Ues    ue_type=all
UE1 UE2 scell addition with FAF true
    Ue register and pdu session setup    ${N66_N66_and_N41_N66_N77_and_N41_N66}    ue_id=81    cell_id=12
    Send Throuput and check Throuput for pcell    ue_id=81    times=4    min_dl_tput=140
    Ue register and pdu session setup    ${N66_N66_and_N41_N66}    ue_id=82    cell_id=12    gw_id=2
    Send Throuput and check Throuput for pcell    ue_id=82    times=4    min_dl_tput=70
    Trigger MR scelladd    ${CA_check_CELL12_CELL11}    ue_id=81    carrierfreq=432030    srsrp_nr=80
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=81    cell_num=2    min_dl_tput=240
    Trigger MR scelladd    ${CA_check_CELL12_CELL11}    ue_id=82    carrierfreq=432030    srsrp_nr=80
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=82    cell_num=2    min_dl_tput=150
UE1 UE2 scell change with FAF false
    OnlineParamChange    ${OnlineParam_disable_7219}
    Trigger MR scellchange and no scell change happen    ue_id=81    carrierfreq=432030    srsrp_nr=100
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=81    cell_num=2    min_dl_tput=150
    Trigger MR scellchange and no scell change happen    ue_id=82    carrierfreq=432030    srsrp_nr=100
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=82    cell_num=2    min_dl_tput=150
UE1 UE2 scell change with FAF true
    OnlineParamChange    ${OnlineParam_enable_7219}
    Trigger MR scelladd    ${CA_check_CELL1_CELL4}    ue_id=81    carrierfreq=432030    srsrp_nr=100
    Wait Until Keyword Succeeds    30s    10s    Check Traffic After Scell Change    ue_id=81    total_dl_tput=240
    Trigger MR scellchange and no scell change happen    ue_id=82    carrierfreq=432030    srsrp_nr=100
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=82    cell_num=2    min_dl_tput=240
    Release Ues    ue_type=all
Check Traffic After Scell Change
    [Arguments]    ${ue_id}=81    ${total_dl_tput}=120    ${ul}=8
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000 > 0
    ${scell1_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=2    type=pdsch    rate_type=ave
    Should Be True    ${scell1_tput}/1000 > 0
    ${scell2_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=3    type=pdsch    rate_type=ave
    Should Be True    ${scell2_tput}/1000 > 0
    ${total_dl}    Evaluate    ${scell0_tput}+${scell1_tput}+${scell2_tput}
    Should Be True     ${total_dl}/1000 > ${total_dl_tput}
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul}
UE3 pcell alternative scell change and online modify FAF
    Ue register and pdu session setup    ${N25_N25_and_N25_N41_N77_and_N25_N41}    ue_id=83    cell_id=13
    Send Throuput and check Throuput for pcell    ue_id=83    times=5    min_dl_tput=280
    Trigger MR scelladd    ${CA_check_CELL13_CELL14}    ue_id=83    carrierfreq=388830    srsrp_nr=80
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=83    cell_num=2    min_dl_tput=360
    OnlineParamChange    ${OnlineParam_disable_7219}
    Trigger MR scellchange and no scell change happen    ue_id=83    carrierfreq=388830    srsrp_nr=100
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=83    cell_num=2    min_dl_tput=360
    OnlineParamChange    ${OnlineParam_enable_7219}
    Trigger MR scelladd    ${CA_check_CELL13_CELL1_CELL4}    ue_id=83    carrierfreq=388830    srsrp_nr=100
    Wait Until Keyword Succeeds    30s    10s    Check Traffic After Scell Change    ue_id=83    total_dl_tput=360
