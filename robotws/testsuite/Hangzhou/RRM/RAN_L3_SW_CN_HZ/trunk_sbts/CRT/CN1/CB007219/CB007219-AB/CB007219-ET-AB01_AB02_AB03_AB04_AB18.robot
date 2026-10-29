*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    team-CN1ET    owner-ha.zheng    owner-yige.g.zhang
...    CLOUD_5G_I_BOO_AP_LOO    CRT    CB007219    release-SBTS24R3
Resource    ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{7219}
...    @{1416}
...    @{CA_enable}
...    @{MimoMode_Para}
...    @{CA_REL_AB01}
...    @{CA_REL_AB04}
...    @{CA_REL_NRHOIF_AB18}

@{7219}
...    NRBTS:actMfbiNrCaSupportFr1=true
...    NRBTS:actMfbiNrCaMeasConfResolv=false
...    NRCELL-1:chBw=40MHz
...    NRCELL-2:chBw=40MHz
...    NRCELL-3:chBw=40MHz
...    NRBTS-1/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=96

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
${CAlist}    ca_Fdd_Fr1Tdd_Sa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Any_Sa,ca_Fdd_Any_Sa,ca_Fdd_Fdd,ca_Fdd_Fr1Tdd_Nsa,ca_Fr1Tdd_Nsa

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

@{CA_REL_AB01}
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-1:isRplCellForPSCell=true
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
...    NRCELL-11/NRREL-2:isRplCellForPSCell=true
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
...    NRCELL-13/NRREL-1:sCellAdditionMethod=blind
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
...    NRCELL-13/NRREL-2:sCellAdditionMethod=blind
...    NRCELL-13/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-11:a1MeasSCellAddEnabled=rsrp
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=85
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=75
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=80ms
...    NRCELL-13:a1MeasSCellAddEnabled=rsrp
...    NRCELL-13:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL-13:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=85
...    NRCELL-13:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=75
...    NRCELL-13:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=80ms
...    NRCELL-1:a2MeasSCellRelEnabled=rsrp
...    NRCELL-1:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=480ms
...    NRCELL-1:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=40|a2TimeToTriggerSCellRelSsbRsrp=480ms
...    NRCELL-2:a2MeasSCellRelEnabled=rsrp
...    NRCELL-2:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=480ms
...    NRCELL-2:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=40|a2TimeToTriggerSCellRelSsbRsrp=480ms

@{CA_REL_AB04}
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-1:isRplCellForPSCell=true
...    NRCELL-1/NRREL-1:gNbId=1
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-1:removeNotAllowed=false
...    NRCELL-1/NRREL-1:lcrId=3
...    NRCELL-1/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-1:a1MeasSCellAddEnabled=rsrp
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=85
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=75
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=80ms
...    NRCELL-3:a2MeasSCellRelEnabled=rsrp
...    NRCELL-3:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=480ms
...    NRCELL-3:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=40|a2TimeToTriggerSCellRelSsbRsrp=480ms

@{CA_REL_NRHOIF_AB18}
...    NRBTS:actIntraFreqIntraGnbMobilityNSA=true
...    NRBTS:actInterFreqIntraGnbMobilityNSA=true
...    NRBTS:actIntraFreqInterGnbMobilityNSA3x=true
...    NRCELL:a1MeashoEnabled=rsrp
...    NRCELL:a1MeashoSsbRsrp:a1HysteresishoSsbRsrp=0|a1ThresholdhoSsbRsrp=40|a1TimeToTriggerhoSsbRsrp=ms480
...    NRCELL:a2MeashoEnabled=rsrp
...    NRCELL:a2MeashoSsbRsrp:a2HysteresishoSsbRsrp=0|a2ThresholdhoSsbRsrp=31|a2TimeToTriggerhoSsbRsrp=ms480
...    NRCELL:a3MeasEnabled=rsrp
...    NRCELL:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0|a3OffsetSsbRsrp=10|a3TimeToTriggerSsbRsrp=ms40
...    NRCELL:sMeasConfigSsbRsrp=10
...    NRCELL:measGapSelection=favourUeThroughput
...    NRCELL:measGapSelectionSA=favourUeThroughput
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-2:isRplCellForPSCell=true
...    NRCELL-1/NRREL-2:gNbId=1
...    NRCELL-1/NRREL-2:gNbIdLength=22
...    NRCELL-1/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-2:removeNotAllowed=false
...    NRCELL-1/NRREL-2:lcrId=13
...    NRCELL-1/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-1/NRHOIF-1:freqBandIndicatorNR=25
...    NRCELL-1/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf5
...    NRCELL-1/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-1/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-1:ssbFrequency=388830
...    NRCELL-1/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1|a3OffsetSsbRsrp=15|a3TimeToTriggerSsbRsrp=40ms
...    NRADJNRCELL-1:cellDepType=SA+NSA
...    NRADJNRCELL-1:fiveGsTac=0
...    NRADJNRCELL-1:freqBandIndicatorNR=25
...    NRADJNRCELL-1:gNbId=35
...    NRADJNRCELL-1:gNbIdLength=22
...    NRADJNRCELL-1:lcrId=1
...    NRADJNRCELL-1:nrarfcn=390000
...    NRADJNRCELL-1:physCellId=381
...    NRADJNRCELL-1:gnbPlmn:mnc=489
...    NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRADJNRCELL-1:gnbPlmn:mncLength=3
...    NRCELL-13/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-13/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-13/NRREL-3:gNbId=35
...    NRCELL-13/NRREL-3:gNbIdLength=22
...    NRCELL-13/NRREL-3:handoverAllowedSA=allowed
...    NRCELL-13/NRREL-3:lcrId=1
...    NRCELL-13/NRREL-3:removeNotAllowed=true
...    NRCELL-13/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-3:gnbPlmn:mncLength=3

@{N2_N78_CA_succ}
...    rrcConnectionReconfigurationComplete
...    pcid:50, scellIdx:9
...    pcid:62, scellIdx:8
...    frequencyBandList.*\{.*2.*\}\.
...    frequencyBandList.*\{.*78.*\}\.

@{N66_N78_CA_succ}
...    rrcConnectionReconfigurationComplete
...    pcid:50, scellIdx:9
...    pcid:60, scellIdx:8
...    frequencyBandList.*\{.*66.*\}\.
...    frequencyBandList.*\{.*78.*\}\.

@{N25_succ}
...    rrcConnectionReconfigurationComplete
...    pcid:62, scellIdx:8
...    frequencyBandList.*\{.*25.*\}\.

@{N2_PCell}
...    pcid:62, scellIdx:8
...    reported successful RA

@{N2_N77_SCell}
...    pcid:50, scellIdx:9
...    pcid:62, scellIdx:8
...    SCellIndex 9 activated successfully

@{N66_PCell}
...    pcid:60, scellIdx:8
...    reported successful RA

@{N66_N77_SCell}
...    pcid:50, scellIdx:9
...    pcid:60, scellIdx:8
...    SCellIndex 9 activated successfully

@{N78_PCell}
...    pcid:50, scellIdx:8
...    reported successful RA

@{N41_SCell}
...    pcid:52, scellIdx:9
...    pcid:50, scellIdx:8
...    SCellIndex 9 activated successfully

@{N78_PCell_A2_config}
...    eventId eventA2
...    pcid:50, scellIdx:8
...    frequencyBandList.*\{.*78.*\}\.
...    reported successful RA

@{N25_PCell_A1_config}
...    eventId eventA1
...    pcid:62, scellIdx:8
...    frequencyBandList.*\{.*25.*\}\.
...    reported successful RA

@{N78_SCell_A3_config}
#...    eventId eventA3
...    rrcConnectionReconfigurationComplete
...    frequencyBandList.*\{.*78.*\}\.
...    pcid:62, scellIdx:8
...    pcid:50, scellIdx:9
...    SgNB Modification Confirm

@{PM_Counters_Check_AB01_AB03}
...    NRCELL-1:${SCELL_CONF_ALT_BAND_NSA}=0
...    NRCELL-11:${SGNB_NSA_ADMISSION_MFBI_REQ}=0
...    NRCELL-11:${SGNB_NSA_ADMISSION_MFBI_SUCC}=0
...    NRCELL-11:${SGNB_DU_NSA_ADMISS_MFBI_REQ}=0
...    NRCELL-11:${SGNB_DU_NSA_ADMISS_MFBI_SUCC}=0
...    NRCELL-13:${SGNB_NSA_ADMISSION_MFBI_REQ}=0
...    NRCELL-13:${SGNB_NSA_ADMISSION_MFBI_SUCC}=0
...    NRCELL-13:${SGNB_DU_NSA_ADMISS_MFBI_REQ}=0
...    NRCELL-13:${SGNB_DU_NSA_ADMISS_MFBI_SUCC}=0
...    NRCELL-1:${UE_SCELL_1_CONF_SCELL_DL}>0

@{PM_Counters_Check_AB02}
...    NRCELL-13:${SGNB_NSA_ADMISSION_MFBI_REQ}=0
...    NRCELL-13:${SGNB_NSA_ADMISSION_MFBI_SUCC}=0
...    NRCELL-13:${SGNB_DU_NSA_ADMISS_MFBI_REQ}=0
...    NRCELL-13:${SGNB_DU_NSA_ADMISS_MFBI_SUCC}=0

@{PM_Counters_Check_AB04}
...    NRCELL-1:${SGNB_NSA_ADMISSION_MFBI_REQ}=0
...    NRCELL-1:${SGNB_NSA_ADMISSION_MFBI_SUCC}=0
...    NRCELL-1:${SGNB_DU_NSA_ADMISS_MFBI_REQ}=0
...    NRCELL-1:${SGNB_DU_NSA_ADMISS_MFBI_SUCC}=0
...    NRCELL-3:${SCELL_CONF_ALT_BAND_NSA}=1

@{PM_Counters_Check_AB18}
...    NRCELL-1:${SCELL_CONF_ALT_BAND_NSA}=0
...    NRCELL-1:${UE_SCELL_1_CONF_SCELL_DL}>0
...    NRCELL-1:${SGNB_NSA_ADMISSION_MFBI_REQ}=0
...    NRCELL-1:${SGNB_NSA_ADMISSION_MFBI_SUCC}=0
...    NRCELL-1:${SGNB_DU_NSA_ADMISS_MFBI_REQ}=0
...    NRCELL-1:${SGNB_DU_NSA_ADMISS_MFBI_SUCC}=0
...    NRCELL-13:${SGNB_NSA_ADMISSION_MFBI_REQ}=0
...    NRCELL-13:${SGNB_NSA_ADMISSION_MFBI_SUCC}=0
...    NRCELL-13:${SGNB_DU_NSA_ADMISS_MFBI_REQ}=2
...    NRCELL-13:${SGNB_DU_NSA_ADMISS_MFBI_SUCC}=2
...    NRCELL-13:${SGNB_NSA_HO_ADMISS_MFBI_REQ}=2
...    NRCELL-13:${SGNB_NSA_HO_ADMISS_MFBI_SUCC}=2

@{OnlineParam_AB02_1}
...    NRCELL-13/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-13/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-13:freqBandIndicatorNR=25
...    NRCONNECTMODE_PROFILE-1:multiFreqBandIndicatorNR=2

@{OnlineParam_AB02_2}
...    NRCELL-13/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-13/NRREL-2:sCellAdditionMethod=blind
...    NRCELL-13:freqBandIndicatorNR=2
...    NRCONNECTMODE_PROFILE-1:multiFreqBandIndicatorNR=25

@{OnlineParam_AB03_1}
...    NRCELL-11/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-13/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-13/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-1:freqBandIndicatorNR=77
...    NRCELL-2:freqBandIndicatorNR=77
...    NRBTS/NRCONNECTMODE_PROFILE-2:multiFreqBandIndicatorNR=78
...    NRBTS/NRMULTIBANDINFO_PROFILE-2:nrMultibandInfoList:nrBandPriority=1|freqBandIndicatorNR=77
...    NRBTS/NRMULTIBANDINFO_PROFILE-2:nrMultibandInfoList:nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1|freqBandIndicatorNR=77
...    NRBTS/NRMULTIBANDINFO_PROFILE-2:nrMultibandInfoList:nrBandPriority=2|freqBandIndicatorNR=78
...    NRBTS/NRMULTIBANDINFO_PROFILE-2:nrMultibandInfoList:nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1|freqBandIndicatorNR=78

@{OnlineParam_AB03_2}
...    NRCELL-11/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-2:sCellAdditionMethod=blind
...    NRCELL-13/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-13/NRREL-2:sCellAdditionMethod=blind

...    NRCELL-1:freqBandIndicatorNR=78
...    NRCELL-2:freqBandIndicatorNR=78
...    NRBTS/NRCONNECTMODE_PROFILE-2:multiFreqBandIndicatorNR=77
...    NRBTS/NRMULTIBANDINFO_PROFILE-2:nrMultibandInfoList:nrBandPriority=1|freqBandIndicatorNR=78
...    NRBTS/NRMULTIBANDINFO_PROFILE-2:nrMultibandInfoList:nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1|freqBandIndicatorNR=78
...    NRBTS/NRMULTIBANDINFO_PROFILE-2:nrMultibandInfoList:nrBandPriority=2|freqBandIndicatorNR=77
...    NRBTS/NRMULTIBANDINFO_PROFILE-2:nrMultibandInfoList:nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1|freqBandIndicatorNR=77

@{OnlineParam_AB18_1}
...    NRCELL-13/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-13/NRREL-2:sCellAdditionMethod=covBasedA1

@{OnlineParam_AB18_2}
...    NRCELL-13/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-13/NRREL-2:sCellAdditionMethod=blind
...    NRBTS:actMfbiNrCaSupportFr1=true

@{7219_false}
...    NRBTS:actMfbiNrCaSupportFr1=false

@{7219_true}
...    NRBTS:actMfbiNrCaSupportFr1=true

${SCELL_CONF_ALT_BAND_NSA}    M55118C01006    #This counter provides the number of current cell configurations as an NSA
#SCell in an alternative band.
${SGNB_NSA_ADMISSION_MFBI_REQ}    M55114C00501    #The number of radio admission requests for NSA user when admission is requested on the
#alternative band. Updated to the strongest PS-Cell (on alternative band) in the selected cell group (DU) in case of multiple PS-Cell candidates.
${SGNB_NSA_ADMISSION_MFBI_SUCC}    M55114C00502    #The number of admitted NSA users when radio admission is done on the alternative band.
#Updated to the strongest PS-Cell (on alternative band) in the selected cell group (DU) in case of multiple PS-Cell candidates.
${SGNB_DU_NSA_ADMISS_MFBI_REQ}    M55115C01501    #The number of radio admission requests with MFBI for NSA user. Updated to the PS-Cell in the DU
#whenever CP-RT receives radio admission request for UE Context Setup or UE Context Modification request.
${SGNB_DU_NSA_ADMISS_MFBI_SUCC}    M55115C01502    #The number of radio admitted NSA users with alternative band. Updated to the PS-Cell in the DU
#whenever CP-RT makes successful radio admission for UE Context Setup or UE Context Modification request.
${UE_SCELL_1_CONF_SCELL_DL}    M55118C05000    #This counter indicates the total number of CA UEs in the current cell configured as an S-Cell,
#which have 1 configured S-Cell in DL in NSA 3x mode.
${SGNB_NSA_HO_ADMISS_MFBI_REQ}    M55114C00503
${SGNB_NSA_HO_ADMISS_MFBI_SUCC}    M55114C00504


${N2_N77_and_N2_N78}    SEPARATOR=
...    E9A09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C4700EA0D803AC1184341020F1068032B64C55890E
...    7D813E238F1891C790E7D473E618F28581C0E1E13FFE00000FFF800000B80001C0A8360C6B04610D04083E5068032B64C55890E7C471EC09
...    F1891C790E7D473E618F28581C0E1E13FFE00000FFF800000B80001C0AA36266B04610D04083A41A00B2D931543439F11C7A067D813E31CF
...    9863CA16070387817003FF001C00FFC00170000381546C4DD608C21A0810748340165B262A86873E238F40CFB027C639F30C7942C0E070F0
...    2E007FE003801FF8002E000070011E0E0C0000000B0102F0700400000858081787802001C4C000004160205E1E0080071340000185808100
...    70062000C04C809A2E8005A048113639F0E044D8E7C3851226C73E1C28913639F0C1208318C63D05C0078005038280381804A00E000C0480
...    080C07C07004000000020000040100000400800003004000020020000140100000C0080000701D819581B5931593358335831581B5953407
...    04000025949410000196525040000A594941000039652504000125949410000596525040001A594941000079652501D40EAA81E5529AAA53
...    9541B2A8355503CAA55942C009001A05000180040100200080200410300400A0040081803007008010206008014008010300600E010020D5
...    0F8000810182030385058606880889098A0C0C8D8E0E8F909293139414951697A0A0C168

${N25_66_66_5_and_N2_66_66_5_and_N2_N77_66_66_5_and_N2_N78_66_66_5}    SEPARATOR=
...    BD1FF823C7C1800068200D040182000000B1182F1F004001A08034100608000002C460BC9C01000E260003410068200C1000008588C17938
...    02001C4D00068200D040182000010B11820142080480030062026404D17400428246893A74ED8E7C38D1274E9DB1CF87222449D3A76C73E1
...    C8891274E9DB1CF86009020C631864DE680430100400800020100008040002012018020050020040C0180380400804010080201020080401
...    008100402000002000200808010020

${N66_N77_and_N66_N78}    SEPARATOR=
...    E9A09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C4700EA0D883AC1184341020F1068032B64C55890E
...    7D813E238F1891C790E7D473E618F28581C0E1E13FFE00000FFF800000B80001C0A8360C6B04610D04083E5068032B64C55890E7C471EC09
...    F1891C790E7D473E618F28581C0E1E13FFE00000FFF800000B80001C0AA36266B04610D04083A41A00B2D931543439F11C7A067D813E31CF
...    9863CA16070387817003FF001C00FFC00170000381546C4DD608C21A0810748340165B262A86873E238F40CFB027C639F30C7942C0E070F0
...    2E007FE003801FF8002E00007000DE0E208000000B0102F0F1040038980000042C040BC3C41000E268000020B010200E00C4041809901345
...    D00094070226C73E1C28913639F0E14489B1CF860024106318C7A0B800F000A070500703009401C0018090010180F80E0080000000400000
...    8020000080100000600800004004000028020000180100000E03B032B036B262B266B066B062B036B2A680E0800004B29282000032CA4A08
...    00014B29282000072CA4A0800024B292820000B2CA4A0800034B292820000F2CA4A03A81D5503CAA53554A72A8365506AAA07954AB285801
...    200340A000200080200410100400804018030808020040200C018D50F8000810182030385058606880889098A0C0C8D8E0E8F90929313941
...    4951697A0A0C1680

${N66_5_7_7_and_N66_N77_7_7_and_N66_N78_7_7}    SEPARATOR=
...    BD1FF81BC7C4100060800C180183000000B1182F1F104003898000C180183000010B1182F1F10400389A000C180183000010B11820100200
...    6808301320268BA001840E3449D3A76C73E1C6891274ED8E7C38D1224E9DB1CF8600480C63180326F3402180802004000100800040200010
...    08C04010020100600C0002010000804200020080801002

${N38A_N78A_and_N41A_N78A}    SEPARATOR=
...    E9A09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C4701FB8D85181AC1184341020E9068036B64C558D
...    0E7C471E819F604F8C48E3C873EA39F30C7942C0E070F05C00FFC007003FF0005C0000E0541B107582308682041E20D00656C98AB121CFB0
...    27C471E31238F21CFA8E7CC31E50B0381C3C27FFC00001FFF00000170000381546C4DD608C21A0810748340165B262A86873E238F40CFB02
...    7C639F30C7942C0E070F02E007FE003801FF8002E0000702A0D831AC1184341020F941A00CAD931562439F11C7B027C62471E439F51CF986
...    3CA1607038784FFF800003FFE000002E0000702B8D84BAC1184341020E9068036B64C558D0E7C471E819F604F8C48E3C873EA39F30C7942C
...    0E070F05C00FFC007003FF0005C0000E0551B133582308682041D20D00596C98AA1A1CF88E3D033EC09F18E7CC31E50B0381C3C0B801FF80
...    0E007FE000B80001C0A836236B04610D04083E5068032B64C55890E7C471EC09F1891C790E7D473E618F28581C0E1E13FFE00000FFF80000
...    0B80001C0A83600EB04610D04083E5068032B64C55890E7C471EC09F1891C790E7D473E618F28581C0E1E13FFE00000FFF800000B80001C0
...    11787882001C46000000160205E1E1280071340000085808178B850001C41000E230000020B0102F17060003882001C4D000006160205E1E
...    14000713400002058081707850001C4100000A160205E1E20800711800003058081787882001C4D00000E160205E2E140007104003882000
...    0202C040BC5C28000E2300071180000485808178B882001C41000E2300000A0B0102F1710400388C001C46000016160205E1E23000713400
...    00605808178F830001C41000E2300071300000685808178F882001C4C000E2600071300000705808178B882001C4D000E2680000F0B0102F
...    1F104003882001C4D000E268000100B01020160234028809B0106026402517400DB08C28913639F0E14489B1CF871224489B1CF871224489
...    B1CF870A244D8E7C3851226C73E1C28913639F0E14489B1CF871224489B1CF871224489B1CF871224489B1CF871224489B1CF870A244D8E7
...    C38D1224489B1CF871A2448913639F0E2448913639F0E344891226C73E180191118C6318C6318C6318C6319E82E003C00281C1401C0C0250
...    0700060240040603E040020000000100000200800002004000018020000100100000A0080000600400003802000020086065654564C5646D
...    60CD60C5606D654D64ED01C1000009652504000065949410000296525040000E594941000049652504000165949410000696525040001E59
...    49407503AAA555549EAA91E5506CAA0D5540F2A95650B0024006814002010100200404008010808040080200C01080401002010020040400
...    80110080500A0201C038080801010100600C0401802080802004020040084040200401002004202004008080200420100400804008010100
...    200440200801008010020200400880400801010020040400801100801002020040080801002101002004040100218180600D00A0140C0080
...    18010020600400C0080103010022008010C0C0080180700206020014010020300600E024018180300701200C40201C008080900602024018
...    C04038010100E00404048030101200C6A87C0004080C10181C282C30344044484C5060646C70747C8494989CA0A4A8B4BD05060B40

${N38A_N78A_N1A_N3A_and_N41A_N78A_N1A_N3A}    SEPARATOR=
...    A11FF823C4D040389A001C01000000162205E268201C4C000E008000010B1102F1B000060401C25000E268000020B1102F1B000060401C28
...    000E268000030B110201E0234028007010602680000500945D000EA091274489B1CF871274489B1CF871A74E8103639F0E34E9D0206C73E1
...    82408318C61803100004020202004008010022000080404048030100200460001008000402020100200803004300008040002010100600C0
...    401802

${N25_N77_and_N25_N78}    SEPARATOR=
...    E9A09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C4700EA0D883AC1184341020F1068032B64C55890E
...    7D813E238F1891C790E7D473E618F28581C0E1E13FFE00000FFF800000B80001C0A8360C6B04610D04083E5068032B64C55890E7C471EC09
...    F1891C790E7D473E618F28581C0E1E13FFE00000FFF800000B80001C0AA36266B04610D04083A41A00B2D931543439F11C7A067D813E31CF
...    9863CA16070387817003FF001C00FFC00170000381546C4DD608C21A0810748340165B262A86873E238F40CFB027C639F30C7942C0E070F0
...    2E007FE003801FF8002E000070009E1E0C000713000000858081787830001C4D00000416020401C018808301320268BA000D80A14489B1CF
...    870A244D8E7C3003810C60F417001E00140E0A00E0601280380030120020301F01C01000000008000010040000100200000C010000080080
...    00050040000300200001C076065606D64C564CD60CD60C5606D654D01C1000009652504000065949410000296525040000E5949410000496
...    52504000165949410000696525040001E5949407503AAA07954A6AA94E5506CAA0D5540F2A95650B00240068140004001004008202008010
...    080300610100400804018031AA1F000102030406070A0B0C0D101112131418191B1C1D1F2125262728292A2D2F414182D0

${N66_N77_5_66_66_and_N66_N78_5_66_66}    SEPARATOR=
...    BD1FF813C9C18000E260003040068200D0400008588C1793830001C4D00060800D0401A0800010B118201002041803101320268BA001240A
...    444893A74ED8E7C3911224E9D3B639F0C03808630326F340218080200400010080004020001009004010020100600C000201000080400020
...    108000802020040080

*** Test Cases ***
CB007219-ET-AB01_Verify successful EN-DC setup and NR CA configuration when some of the aggregated cells operate
    [Documentation]
    ...    1. This user scenario describes the successful EN-DC setup and NR CA configuration when the target PSCell and
    ...    NR SCell operate in multiple bands. When CNI-81817 and CNI-80045 are both disabled, at equal maximum
    ...    aggregated channel, gNB-CU selects the band combination and its first associated FSEI which is associated
    ...    to the first built FLS, assumed to be with native cell bands. Besides, when there is the choice between two
    ...    carriers in the same band, gNB-CU selects the one with lower NRCELL MOC instance value.
    ...    2. Configuration
    ...    NRBTS/actMfbiNrCaSupportFr1 is set to true
    ...    NRBTS/actMultiFrequencyBandIndicatorNRSupport=true
    ...    alternative band configuration as below:
    ...    Cell configuration:
    ...    Cell_11 Cell_12 Cell_13 Cell_14 Cell_1 Cell_2 Cell_3 Cell_4
    ...    Technology type FDD FDD FDD FDD TDD TDD TDD TDD
    ...    Frequency F0 F1 F2 F3 F4 F5 F6 F7
    ...    Common channel bandwidth 20 20 20 20 40 40 40 20
    ...    DL MIMO Layers 4L 4L 4L 4L 4L 4L 4L 4L
    ...    Native band N66 N71 N2 N2 N78 N78 N38 N38
    ...    Alternative band NA NA N25 NA N77 N77 N41 NA
    ...    3. Test Case Steps:
    ...    a. attach UE11 to LTE cell1 and trigger EN-DC setup toward the SgNB to NR cell13, Start DL/UL traffic
    ...    b. attach UE12 to LTE cell2 and trigger EN-DC setup toward the SgNB to NR cell11, Start DL/UL traffic
    ...    c. check counters.
    ...    4. Expectation:
    ...    a. NR cell13 is PSCell and cell1 is added as scell. BC#4FSEI#1 is selected.
    ...    BC#4: DC_5A-66A-66A-n2A-n78A n2 n78
    ...    FSEI#1: DL MIMO layers4L     2L 2L 4L 4L
    ...    DL ChBw (MHz)                20 40
    ...    b. NR cell11 is PSCell and cell1 is added as scell. BC#3FSEI#1 is selected.
    ...    BC#3: DC_7A-7A-n66A-n78A     n66 n78
    ...    FSEI#1: DL MIMO layers       4L 2L 4L 4L
    ...    DL ChBw (MHz)                20 40
    ...    c. SCELL_CONF_ALT_BAND_SA not update of cell1.
    [Tags]    ha.zheng    QC_322190    AB01    CA_LABEL-FT(20MHZ_FDD_n2(n66)+40MHZ_TDD_n78)
    Clear Counter Files    wait=${False}
    blind CA add when NSA UE Attach To Sim Enb1 And Start ENDC With Real Gnb2
    ...    ue_id=11    cell=1    target_cells=13    SA_Capa_perUE_Full=${N2_N77_and_N2_N78}    bc_list_mrdc=2:1|3:1|4:2|3:2|4:1|1:1
    ...    ue_mrdc_cap=${N25_66_66_5_and_N2_66_66_5_and_N2_N77_66_66_5_and_N2_N78_66_66_5}    pass_CA=${N2_N78_CA_succ}
    blind CA add when NSA UE Attach To Sim Enb1 And Start ENDC With Real Gnb2
    ...    ue_id=12    cell=2    target_cells=11    SA_Capa_perUE_Full=${N66_N77_and_N66_N78}    bc_list_mrdc=1:1|2:1|3:1
    ...    ue_mrdc_cap=${N66_5_7_7_and_N66_N77_7_7_and_N66_N78_7_7}    pass_CA=${N66_N78_CA_succ}
    Check Counters    ${PM_Counters_Check_AB01_AB03}
    Check Wireshark Log    ${CURDIR}${/}A2A_AB01${/}a2a_gnb.ini    wait_string=UEContextReleaseComplete::4

CB007219-ET-AB02_Verify successful EN-DC setup without LTE CA nor NR CA configuration when some of the aggregated cells operate
    [Documentation]
    ...    1. This user scenario describes the successful EN-DC setup without NR CA configuration when the target PSCell
    ...    and NR SCell operate in multiple bands.When there is the choice, gNB-CU and gNB-DU always select the native
    ...    band for the UE's PSCell.
    ...    2. Configuration
    ...    NRBTS/actMfbiNrCaSupportFr1 is set to true
    ...    NRBTS/actMultiFrequencyBandIndicatorNRSupport=true
    ...    alternative band configuration as below:
    ...    Cell configuration:
    ...    Cell_11 Cell_12 Cell_13 Cell_14 Cell_1 Cell_2 Cell_3 Cell_4
    ...    Technology type FDD FDD FDD FDD TDD TDD TDD TDD
    ...    Frequency F0 F1 F2 F3 F4 F5 F6 F7
    ...    Common channel bandwidth 20 20 20 20 40 40 40 20
    ...    DL MIMO Layers 4L 4L 4L 4L 4L 4L 4L 4L
    ...    Native band N66 N71 N25 N2 N78 N78 N38 N38
    ...    Alternative band NA NA N2 NA N77 N77 N41 NA
    ...    3. Test Case Steps:
    ...    a. attach UE11 to LTE cell1 and trigger EN-DC setup toward the SgNB to NR cell13, Start DL/UL traffic
    ...    b. check counters.
    ...    4. Expectation:
    ...    a. NR cell13 is PSCell and no A1 for scell addition is configured. BC#1FSEI#1 is selected.
    ...    BC#1: DC_66A-n25A       n25
    ...    FSEI#1: DL MIMO layers 4L 4L
    ...    DL ChBw (MHz)           20
    [Tags]    ha.zheng    QC_322188    AB02
    Clear Counter Files
    OnlineParamChange    ${OnlineParam_AB02_1}
    no A1 configured when NSA UE Attach To Sim Enb1 And Start ENDC With Real Gnb2
    ...    ue_id=11    cell=1    target_cells=13    SA_Capa_perUE_Full=${N2_N77_and_N2_N78}    bc_list_mrdc=2:1|3:1|4:2|3:2|4:1|1:1
    ...    ue_mrdc_cap=${N25_66_66_5_and_N2_66_66_5_and_N2_N77_66_66_5_and_N2_N78_66_66_5}     pass_CA=${N25_succ}
    Check Counters    ${PM_Counters_Check_AB02}
    Check Wireshark Log    ${CURDIR}${/}A2A_AB02${/}a2a_gnb.ini    wait_string=UEContextReleaseComplete::2
    [Teardown]    AB02_Teardown

CB007219-ET-AB03_Verify_successful_EN-DC_setup_and_NR_CA_configuration_when_some_of_the_aggregated_cells_operate_A1_scell_addition
    [Documentation]
    ...    1. This user scenario describes the successful EN-DC setup and NR CA configuration when the target PSCell and
    ...    NR SCell operate in multiple bands. When CNI-81817 and CNI-80045 are both disabled, at equal maximum
    ...    aggregated channel, gNB-CU selects the band combination and its first associated FSEI which is associated
    ...    to the first built FLS, assumed to be with native cell bands. Besides, when there is the choice between two
    ...    carriers in the same band, gNB-CU selects the one with lower NRCELL MOC instance value.
    ...    2. Configuration
    ...    NRBTS/actMfbiNrCaSupportFr1 is set to true
    ...    NRBTS/actMultiFrequencyBandIndicatorNRSupport=true
    ...    alternative band configuration as below:
    ...    Cell configuration:
    ...    Cell_11 Cell_12 Cell_13 Cell_14 Cell_1 Cell_2 Cell_3 Cell_4
    ...    Technology type FDD FDD FDD FDD TDD TDD TDD TDD
    ...    Frequency F0 F1 F2 F3 F4 F5 F6 F7
    ...    Common channel bandwidth 20 20 20 20 40 40 40 20
    ...    DL MIMO Layers 4L 4L 4L 4L 4L 4L 4L 4L
    ...    Native band N66 N71 N2 N2 N77 N77 N38 N38
    ...    Alternative band NA NA N25 NA N78 N78 N41 NA
    ...    3. Test Case Steps:
    ...    a. attach UE11 to LTE cell1 and trigger EN-DC setup toward the SgNB to NR cell13, Start DL/UL traffic
    ...    b. attach UE12 to LTE cell2 and trigger EN-DC setup toward the SgNB to NR cell11, Start DL/UL traffic
    ...    c. check counters.
    ...    4. Expectation:
    ...    a. NR cell13 is PSCell and cell1 is added as scell. BC#3FSEI#1 is selected.
    ...    BC#3: DC_5A-66A-66A-n2A-n77A    n2 n77    LTE-66 LTE-66 LTE-5
    ...    FSEI#1: DL MIMO layers          4L 2L       2L 4L 4L    4L 4L
    ...    DL ChBw (MHz)                   20 40
    ...    b. NR cell11 is PSCell and cell1 is added as scell. BC#2FSEI#1 is selected.
    ...    BC#2: DC_7A-7A-n66A-n77A    n66 n77 LTE-7 LTE-7
    ...    FSEI#1: DL MIMO layers      4L 2L 4L 4L
    ...    DL ChBw (MHz)               20 40
    [Tags]    yige.g.zhang    QC_322198    AB03    CA_LABEL-FT(20MHZ_FDD_n2(n66)+40MHZ_TDD_n77)
    Clear Counter Files
    OnlineParamChange    ${OnlineParam_AB03_1}
    covBasedA1 CA add when NSA UE Attach To Sim Enb1 And Start ENDC With Real Gnb2
    ...    ue_id=11    cell=1    target_cells=13    SA_Capa_perUE_Full=${N2_N77_and_N2_N78}    bc_list_mrdc=2:1|3:1|4:2|3:2|4:1|1:1
    ...    ue_mrdc_cap=${N25_66_66_5_and_N2_66_66_5_and_N2_N77_66_66_5_and_N2_N78_66_66_5}    carrierfreq=388830
    ...    pass_PCell=${N2_PCell}    pass_SCell=${N2_N77_SCell}
    covBasedA1 CA add when NSA UE Attach To Sim Enb1 And Start ENDC With Real Gnb2
    ...    ue_id=12    cell=2    target_cells=11    SA_Capa_perUE_Full=${N66_N77_and_N66_N78}    bc_list_mrdc=1:1|2:1|3:1
    ...    ue_mrdc_cap=${N66_5_7_7_and_N66_N77_7_7_and_N66_N78_7_7}    carrierfreq=424090
    ...    pass_PCell=${N66_PCell}    pass_SCell=${N66_N77_SCell}
    Check Counters    ${PM_Counters_Check_AB01_AB03}
    Check Wireshark Log    ${CURDIR}${/}A2A_AB03${/}a2a.ini    wait_string=UEContextReleaseComplete::4
    [Teardown]    AB03_Teardown

CB007219-ET-AB04_Verify_successful_NSA_with_the_NR_SCell_in_the_alternative_band_because_it_provides_higher_DL_aggregated_channel_bandwidth
    [Documentation]
    ...    1. This user scenario describes the successful setup of EN-DC setup and NR CA configuration when the NR SCell
    ...    is selected to operate the alternative band because it provides higher DL aggregated channel bandwidth.
    ...    2. Configuration
    ...    NRBTS/actMfbiNrCaSupportFr1 is set to true
    ...    NRBTS/actMultiFrequencyBandIndicatorNRSupport=true
    ...    alternative band configuration as below:
    ...    Cell configuration:
    ...    Cell_11 Cell_12 Cell_13 Cell_14 Cell_1 Cell_2 Cell_3 Cell_4
    ...    Technology type FDD FDD FDD FDD TDD TDD TDD TDD
    ...    Frequency F0 F1 F2 F3 F4 F5 F6 F7
    ...    Common channel bandwidth 20 20 20 20 40 40 40 20
    ...    DL MIMO Layers 4L 4L 4L 4L 4L 4L 4L 4L
    ...    Native band N66 N71 N25 N2 N78 N78 N38 N38
    ...    Alternative band NA NA N2 NA N77 N77 N41 NA
    ...    3. Test Case Steps:
    ...    a. attach UE11 to LTE cell3 band1 and trigger EN-DC setup toward the SgNB to NR cell-1, Start DL/UL traffic. BC#2FSEI#1 selected due
    ...       to larger aggregated ChBw
    ...     BC#1: DC_1A-3A-n38A- n78A n38 n78 LTE-1 LTE-3
    ...     FSEI#1: DL MIMO layers 4L 2L 4L 4L
    ...     DL ChBw (MHz) 20 40
    ...     BC#2: DC_1A-3A-n41A-n78A n41 n78 LTE-1 LTE-3
    ...     FSEI#1: DL MIMO layers 2L 2L 2L 2L
    ...     DL ChBw (MHz) 40 40
    [Tags]    yige.g.zhang    QC_322196    AB04    CA_LABEL-TT(n78_TDD_40Mhz+n41_TDD_40Mhz)
    Clear Counter Files
    covBasedA1 CA add when NSA UE Attach To Sim Enb1 And Start ENDC With Real Gnb2
    ...    ue_id=11    cell=3    target_cells=1    SA_Capa_perUE_Full=${N38A_N78A_and_N41A_N78A}    bc_list_mrdc=3:1|4:1
    ...    ue_mrdc_cap=${N38A_N78A_N1A_N3A_and_N41A_N78A_N1A_N3A}    carrierfreq=632736
    ...    pass_PCell=${N78_PCell}    pass_SCell=${N41_SCell}
    Check Counters    ${PM_Counters_Check_AB04}
    Check Wireshark Log    ${CURDIR}${/}A2A_AB04${/}a2a.ini    wait_string=UEContextReleaseComplete::2

CB007219-ET-AB18_Successful CA configuration with MFBI NRCell after an incoming hand over
    [Documentation]
    ...    1. This user scenario describes the successful operation of blind SCell Addition after an incoming hand over
    ...    where the list of cells to be aggregated contains MFBI P(S)Cell/SCell(s)
    ...    2. Configuration
    ...    NRBTS/actMfbiNrCaSupportFr1 is set to true
    ...    NRBTS/actMultiFrequencyBandIndicatorNRSupport=true
    ...    NRBTS:actIntraFreqIntraGnbMobilityNSA=true
    ...    NRBTS:actInterFreqIntraGnbMobilityNSA=true
    ...    NRBTS:actIntraFreqInterGnbMobilityNSA3x=true
    ...    alternative band configuration as below:
    ...    Cell configuration:
    ...    Cell_11 Cell_12 Cell_13 Cell_14 Cell_1 Cell_2 Cell_3 Cell_4
    ...    Technology type FDD FDD FDD FDD TDD TDD TDD TDD
    ...    Frequency F0 F1 F2 F3 F4 F5 F6 F7
    ...    Common channel bandwidth 20 20 20 20 40 40 40 20
    ...    DL MIMO Layers 2L 2L 4L 4L 4L 4L 4L 4L
    ...    Native band N66 N71 N2 N2 N78 N78 N38 N38
    ...    Alternative band NA NA N25 NA N77 N77 N41 NA
    ...    UE1 capability: LTE cell1 + NR cell13+ NR cell1+NR cell2, A1 scell addition
    ...    BC#1: DC_5A-66A-66A-n25A-n77A
    ...    BC#2: DC_5A-66A-66A-n25A-n78A
    ...    3. Test Case Steps:
    ...    a. attach UE11 to LTE cell1 and trigger EN-DC setup toward the SgNB to NR cell1
    ...    b. trigger A2 and A3 for inter frequency mobility from NR cell1 to cell13.
    ...    c. online change actMfbiNrCaSupportFr1 from true to false.
    ...    d. trigger A1 for scell addition.
    ...    e. online change actMfbiNrCaSupportFr1 from false to true.
    ...    f. trigger A1 for scell addition.
    ...    g. trigger A3 for intra-frequency HO from NR cell13 to gnb simulator
    ...    h. trigger A3 for intra-frequency HO from gnb simulator to NR Cell 13
    ...    i. repeat step c-step f
    ...    j. online change actMfbiNrCaSupportFr1 from true to false.
    ...    k. trigger A2 for scell release
    ...    l. check counters.
    ...    4. Expectation:
    ...    a. Cell1 in band n78, BC#2FSEI#1 is selected.A2 for inter-frequency is configured to UE.
    ...    b. Measurement gap setup after A2. HO from NR cell1 to cell13 successfully. NR cell13 is PSCell in n25.
    ...       A1 for scell addition is configured to UE.
    ...    d. no scell added as pcell in alternative band 7219 disabled
    ...    f. cell1 is added as scell. BC#2FSEI#1 is selected. traffic is OK. Measurement objects configured at 5G-UE
    ...       for its NR serving cells are as follows: Cell13 in band n25 and Cell1 in band n78.
    ...       A3 for intra-frequency HO is configured to UE.
    ...    g. HO successfully
    ...    h. HO successfully. NR cell13 is PSCell in n25. A1 for scell addition is configured to UE.
    ...    i. the same as step c-step f
    ...    k. scell is released and no A1 for scell addition is configured.
    [Tags]    ha.zheng    QC_322186    AB18    CA_LABEL-FT(n25_FDD_20Mhz+n78_TDD_40Mhz)
    OnlineParamChange    ${OnlineParam_AB18_1}
    Clear Counter Files
    NSA UE Attach To Sim Enb1 And Start ENDC With Real Gnb2
    ...    ue_id=11    cell=1    target_cells=1    SA_Capa_perUE_Full=${N25_N77_and_N25_N78}    bc_list_mrdc=1:1|2:1
    ...    ue_mrdc_cap=${N66_N77_5_66_66_and_N66_N78_5_66_66}    meas_config=${N78_PCell_A2_config}
    UE Send A2 A3 Trigger InterFreq HO to target    expreg_ho=${N25_PCell_A1_config}
    set feature flag false trigger scell addtion and set feature flag true then trigger scell addtion
    ...    pass_SCell=${N78_SCell_A3_config}
    Initial IntraFreA3 Ho to simgnb and back
    set feature flag false trigger scell addtion and set feature flag true then trigger scell addtion
    ...    pass_SCell=${N78_SCell_A3_config}
    set feature flag false trigger scell release
    Check Counters    ${PM_Counters_Check_AB18}
    Check Wireshark Log    ${CURDIR}${/}A2A_AB18${/}a2a.ini    wait_string=UEContextReleaseComplete::2
    [Teardown]    AB18_Teardown

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/8cells_4T4F_2N2_N66_N71_2N78_2N38    ue_count=10

X2 Link for simulated gNB-35
    Execute Egate Command    enb_x2_link_up enb=1 target=3    pass_regexp=X2AP Link with GNB-3 .* is up

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
    ${C_4}    catenate
    ...    set_cell id=1 gnb=3 pci=127:0 tac=0 nrci=0x01 tdd_cell=off proxy=10.0.2.91:9999 nr_arfcn=374000:390000
    ...    gscn=4860 mapped_MFBI=25 mandatory_for_activation=off
    ${C_5}    catenate
    ...    gnb_set id=3 s1u=10.0.1.126 plmn=311:489 gnb_id=0x23:22 type=simulated daemon=:22222 x2=10.0.1.126:36422
    Update Cfg    ${C_1}
    Update Cfg    ${C_2}
    Update Cfg    ${C_3}
    Update Cfg    ${C_4}
    Update Cfg    ${C_5}
    Update Cfg    gnb_endc_param id=3 use_nr_ran_cont=true scg_dl_dist_percent=0 enable_dud_poll_bit=0

Update UE capa
    [Arguments]    ${ue_id}=16    ${SA_Capa_perUE_Full}=none    ${ue_mrdc_cap}=none
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full} dual_conn=eutra_nr
    ...    ue_eutra_nr_capabilities=${ue_mrdc_cap}
    Execute Egate Command    ${cmd}

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir

AB02_Teardown
    OnlineParamChange    ${OnlineParam_AB02_2}
    Common Test Teardown And Stop Capture Logs

AB03_Teardown
    OnlineParamChange    ${OnlineParam_AB03_2}
    Common Test Teardown And Stop Capture Logs

AB18_Teardown
    OnlineParamChange    ${OnlineParam_AB18_2}
    Common Test Teardown And Stop Capture Logs

blind CA add when NSA UE Attach To Sim Enb1 And Start ENDC With Real Gnb2
    [Arguments]    ${ue_id}=11    ${cell}=1    ${target_gnb}=2    ${target_cells}=13    ${bearer_id}=2
    ...    ${bc_list_mrdc}=2:1|3:1|4:1|3:2|4:2|1:1    ${SA_Capa_perUE_Full}=none    ${ue_mrdc_cap}=none    ${pass_CA}=none
    Execute Egate Command    ue_change_location id=${ue_id} enb=1 cell=${cell}
    Update UE capa    ${ue_id}    ${SA_Capa_perUE_Full}    ${ue_mrdc_cap}
    Execute Egate Command    enb_endc_param id=1 allowed_bc_list_mrdc=${bc_list_mrdc}
    Execute Egate Command    ue_attach id=${ue_id}    pass_regexp=UE${ue_id}: === UE IS ACTIVE
    Execute Egate Command    ue_disp id=${ue_id}    timeout=20s
    ${cmd}     Catenate    ue_dc_enb_start ue=${ue_id} target_gnb=${target_gnb}
    ...    target_cells=${target_cells} bearer=${bearer_id} type=split_scg
    ${ret1}=    Execute Egate Command    ${cmd}
    ...    pass_regexp=${pass_CA}    timeout=20s
    Send Throughput    ue_id=${ue_id}
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=${ue_id}
    Release Ues    ue_type=all

covBasedA1 CA add when NSA UE Attach To Sim Enb1 And Start ENDC With Real Gnb2
    [Arguments]    ${ue_id}=11    ${cell}=1    ${target_gnb}=2    ${target_cells}=13    ${bearer_id}=2    ${carrierfreq}=388830
    ...    ${bc_list_mrdc}=2:1|3:1|4:1|3:2|4:2|1:1    ${SA_Capa_perUE_Full}=none    ${ue_mrdc_cap}=none    ${pass_PCell}=none
    ...    ${pass_SCell}=none
    Execute Egate Command    ue_change_location id=${ue_id} enb=1 cell=${cell}
    Update UE capa    ${ue_id}    ${SA_Capa_perUE_Full}    ${ue_mrdc_cap}
    Execute Egate Command    enb_endc_param id=1 allowed_bc_list_mrdc=${bc_list_mrdc}
    Execute Egate Command    ue_attach id=${ue_id}    pass_regexp=UE${ue_id}: === UE IS ACTIVE
    Execute Egate Command    ue_disp id=${ue_id}    timeout=20s
    ${cmd}     Catenate    ue_dc_enb_start ue=${ue_id} target_gnb=${target_gnb}
    ...    target_cells=${target_cells} bearer=${bearer_id} type=split_scg
    ${ret1}=    Execute Egate Command    ${cmd}
    ...    pass_regexp=${pass_PCell}    timeout=20s
    Send Throughput    ue_id=${ue_id}
    Add gNB Cell1 As Scell By A1    ue_id=${ue_id}    carrierfreq=${carrierfreq}    pass_CA=${pass_SCell}
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=${ue_id}
    Release Ues    ue_type=all

Add gNB Cell1 As Scell By A1
    [Arguments]    ${ue_id}=92    ${carrierfreq}=633216    ${srsrp_nr}=90    ${srsrq_nr}=90    ${pass_CA}=none    ${fail_CA}=none
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A1
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=${srsrp_nr} ssinr_nr=59 srsrq_nr=${srsrp_nr}
    ...    pass_regexp=${pass_CA}    fail_regexp=${fail_CA}

no A1 configured when NSA UE Attach To Sim Enb1 And Start ENDC With Real Gnb2
    [Arguments]    ${ue_id}=11    ${cell}=1    ${target_gnb}=2    ${target_cells}=13    ${bearer_id}=2
    ...    ${bc_list_mrdc}=2:1|3:1|4:1|3:2|4:2|1:1    ${SA_Capa_perUE_Full}=none    ${ue_mrdc_cap}=none    ${pass_CA}=none
    Execute Egate Command    ue_change_location id=${ue_id} enb=1 cell=${cell}
    Update UE capa    ${ue_id}    ${SA_Capa_perUE_Full}    ${ue_mrdc_cap}
    Execute Egate Command    enb_endc_param id=1 allowed_bc_list_mrdc=${bc_list_mrdc}
    Execute Egate Command    ue_attach id=${ue_id}    pass_regexp=UE${ue_id}: === UE IS ACTIVE
    Execute Egate Command    ue_disp id=${ue_id}    timeout=20s
    ${cmd}     Catenate    ue_dc_enb_start ue=${ue_id} target_gnb=${target_gnb}
    ...    target_cells=${target_cells} bearer=${bearer_id} type=split_scg
    ${ret1}=    Execute Egate Command    ${cmd}
    ...    pass_regexp=${pass_CA}    timeout=20s
    should not contain    ${ret1}    eventA1
    Send Throughput    ue_id=${ue_id}
    Wait Until Keyword Succeeds    30s    10s    Check Traffic    ue_id=${ue_id}    cell_num=1    min_dl_tput=160
    Release Ues    ue_type=all

Send Throughput
    [Arguments]    ${ue_id}=11    ${times}=3    ${mbps}=150
    Execute Egate Command    trf_data_start ue=${ue_id} id=2 dir=ul mbps=10 trf_id=1    UE ${ue_id}: UDP UL
    FOR    ${I}    IN RANGE    1    ${times}+1
        Execute Egate Command    trf_data_start ue=${ue_id} id=2 dir=dl mbps=${mbps} trf_id=${I}    UE ${ue_id}: UDP DL
    END

Check Traffic
    [Arguments]     ${ue_id}=11    ${cell_num}=2    ${min_dl_tput}=420    ${min_ul_tput}=8
    ${dl_throuput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=dl    dc_cell_group=all    rate_type=ave
    ${ul_throuput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=8    type=pusch    rate_type=ave
    ${total_dl_tput}    Set Variable    0
    FOR    ${index}    IN RANGE    8    ${cell_num}+8
         ${str_index}    Convert To String    ${index}
         ${scell_tput}    Ap Get Throuput On Specific Scell    ${ue_id}    ${str_index}    pdsch
         Should Be True    ${scell_tput}/1000 > 20
         ${total_dl_tput}    Evaluate    ${scell_tput}+${total_dl_tput}
    END
    Should Be True    ${total_dl_tput}/1000 > ${min_dl_tput}
    Should Be True    ${ul_throuput}/1000 > ${min_ul_tput}

NSA UE Attach To Sim Enb1 And Start ENDC With Real Gnb2
    [Arguments]    ${ue_id}=11    ${cell}=1    ${target_gnb}=2    ${target_cells}=1    ${bearer_id}=2
    ...    ${bc_list_mrdc}=1:1|2:1|3:1    ${SA_Capa_perUE_Full}=none    ${ue_mrdc_cap}=none    ${meas_config}=none
    Execute Egate Command    ue_change_location id=${ue_id} enb=1 cell=${cell}
    Update UE capa    ${ue_id}    ${SA_Capa_perUE_Full}    ${ue_mrdc_cap}
    Execute Egate Command    enb_endc_param id=1 allowed_bc_list_mrdc=${bc_list_mrdc}
    Execute Egate Command    ue_attach id=${ue_id}    pass_regexp=UE${ue_id}: === UE IS ACTIVE
    Execute Egate Command    ue_disp id=${ue_id}    timeout=20s
    ${cmd}     Catenate    ue_dc_enb_start ue=${ue_id} target_gnb=${target_gnb}
    ...    target_cells=${target_cells} bearer=${bearer_id} type=split_scg
    ${ret1}=    Execute Egate Command    ${cmd}
    ...    pass_regexp=${meas_config}    timeout=20s

UE Send A2 A3 Trigger InterFreq HO to target
    [Arguments]    ${ue_id}=11    ${a2cellfreq}=632736    ${a3cellfreq}=388830    ${target_pid}=62    ${expreg_ho}=SgNB Modification Confirm
    Execute Egate Command    ue_enb_param id=${ue_id} measurement_gap=gp0:12 gap_trigger=gnb_triggered
    ${meas_id}=    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=${a2cellfreq}    event_type=A2
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 srsrp_nr=11 srsrq_nr=11
    ...    pass_regexp=Sending SgNB Modification Confirm
    ${meas_id}=    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=${a3cellfreq}    event_type=A3
    ${result}=    Execute Egate Command
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=${target_pid} nrsrp_nr=80 nrsrq_nr=80
    ...    pass_regexp=${expreg_ho}
    Send Throughput

set feature flag false trigger scell addtion and set feature flag true then trigger scell addtion
    [Arguments]    ${ue_id}=11    ${carrierfreq}=388830    ${no_CA}=Dispatch UlInformationTransferMRDC Message
    ...    ${pass_SCell}=none
    OnlineParamChange    ${7219_false}
    Add gNB Cell1 As Scell By A1    ue_id=${ue_id}    carrierfreq=${carrierfreq}    pass_CA=${no_CA}    fail_CA=${pass_SCell}
    OnlineParamChange    ${7219_true}
    Add gNB Cell1 As Scell By A1    ue_id=${ue_id}    carrierfreq=${carrierfreq}    pass_CA=${pass_SCell}
    Wait Until Keyword Succeeds    30s    10s    Check Traffic

Initial IntraFreA3 Ho to simgnb and back
    [Arguments]    ${phycell_id_1}=381    ${phycell_id_2}=62    ${ue_id}=11    ${carrierfreq}=388830
    X2 Link for simulated gNB-35
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A3
    ${ret1}=     Execute Egate Command
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=${phycell_id_1} nrsrp_nr=30 nrsrq_nr=30
    ...    pass_regexp=Bearer-type change from MCG to SCG-split is successful
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A3
    ${ret1}=     Execute Egate Command
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=${phycell_id_2} nrsrp_nr=30 nrsrq_nr=30
    ...    pass_regexp=Inter Sgnb Handover is successful

set feature flag false trigger scell release
    [Arguments]    ${ue_id}=11    ${carrierfreq}=632736
    OnlineParamChange    ${7219_false}
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A2
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 scell=9 scell_rsrp=7 scell_rsrq=7
    ...    pass_regexp=Successfully reconfigured dual connectivity    fail_regexp=eventId eventA1
