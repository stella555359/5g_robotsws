*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    team-CN1ET    owner-zora.wang    owner-zhang.yige
...    CLOUD_5G_I_BOO_AP_LOO    CRT    CB007219    release-SBTS24R3
Resource    ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{cell_frequency}
...    @{7219}
...    @{1416}
...    @{CA_enable}
...    @{MimoMode_Para}
...    @{Scell_Rel}
...    @{CB010378}

@{cell_frequency}
...    NRCELL-1:chBw=40MHz
...    NRCELL-3:chBw=40MHz
...    NRCELL-2:freqBandIndicatorNR=77     #n77E_Canada
...    MRBTS-1/NRBTS-1/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=96
...    NRCELL-3:cellBwpList:cellBwpId=0|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-5
...    NRCELL-3:cellBwpList:cellBwpId=1|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-6
...    NRCELL-1:cellBwpList:cellBwpId=0|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-5
...    NRCELL-1:cellBwpList:cellBwpId=1|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-6

@{CB010378}
...    NRBTS:actExt2N77Support=true
...    NRCELL-2:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-3
...    NRSYSINFO_PROFILE-2/NRIAFIM-1:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-3
...    NRSYSINFO_PROFILE-2/NRIRFIM-1:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-3

@{7219}
...    NRBTS:actMfbiNrCaSupportFr1=true
...    NRBTS:actMfbiNrCaMeasConfResolv=false

@{1416}
...    NRBTS:actMultiFrequencyBandIndicatorNRSupport=true
...    NRCELL-4:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-1
...    NRCELL-4:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-1

...    NRCELL-3:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-2
...    NRCELL-3:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-2
...    NRCELL-1:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-2
...    NRCELL-1:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-2

...    NRSYSINFO_PROFILE-1/NRIRFIM-1:freqBandIndicatorNR=78          #native band       inter-frequency re-selection
...    NRSYSINFO_PROFILE-1/NRIRFIM-1:multiFreqBandIndicatorNR=77        #alternative band     inter-frequency re-selection
...    NRSYSINFO_PROFILE-1/NRIAFIM-1:multiFreqBandIndicatorNR=77          #alternative band    intra-frequency re-selectio

...    NRSYSINFO_PROFILE-3/NRIRFIM-1:freqBandIndicatorNR=78          #native band
...    NRSYSINFO_PROFILE-3/NRIRFIM-1:multiFreqBandIndicatorNR=77        #alternative band
...    NRSYSINFO_PROFILE-3/NRIAFIM-1:multiFreqBandIndicatorNR=77           #alternative band
...    NRSYSINFO_PROFILE-3/NRIRFIM-1:dlCarrierFreq=640666

...    NRBTS/NRCONNECTMODE_PROFILE-1:multiFreqBandIndicatorNR=41
...    NRBTS/NRCONNECTMODE_PROFILE-2:multiFreqBandIndicatorNR=77

...    NRBTS/NRMULTIBANDINFO_PROFILE-1:nrMultibandInfoList:nrBandPriority=1|freqBandIndicatorNR=38
...    NRBTS/NRMULTIBANDINFO_PROFILE-1:nrMultibandInfoList:nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1|freqBandIndicatorNR=38
...    NRBTS/NRMULTIBANDINFO_PROFILE-1:nrMultibandInfoList:nrBandPriority=2|freqBandIndicatorNR=41
...    NRBTS/NRMULTIBANDINFO_PROFILE-1:nrMultibandInfoList:nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1|freqBandIndicatorNR=41

...    NRBTS/NRMULTIBANDINFO_PROFILE-2:nrMultibandInfoList:nrBandPriority=1|freqBandIndicatorNR=78
...    NRBTS/NRMULTIBANDINFO_PROFILE-2:nrMultibandInfoList:nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1|freqBandIndicatorNR=78
...    NRBTS/NRMULTIBANDINFO_PROFILE-2:nrMultibandInfoList:nrBandPriority=2|freqBandIndicatorNR=77
...    NRBTS/NRMULTIBANDINFO_PROFILE-2:nrMultibandInfoList:nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1|freqBandIndicatorNR=77

...    NRBTS/NRMULTIBANDINFO_PROFILE-3:nrMultibandInfoList:nrBandPriority=0|freqBandIndicatorNR=77
...    NRBTS/NRMULTIBANDINFO_PROFILE-3:nrMultibandInfoList:nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1|freqBandIndicatorNR=77

...    NRBTS/NRNSPMAX_PROFILE-1:nrNsPmaxList:additionalSpectrumEmission=2
...    NRBTS/NRNSPMAX_PROFILE-1:nrNsPmaxList:nrNsPmaxPriority=2
...    NRBTS/NRNSPMAX_PROFILE-1:nrNsPmaxList:additionalPmax=2

@{CA_enable}
...    NRBTS-1:actCarrierAggregation=true
...    NRBTS-1:caConfigurationSupport=4CCDL_2CCUL
...    NRDU-1:actInterNumerologyCa=true
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRBTS-1:actMeasBasedSCellAdditionSa=A1-based
...    NRCELL:maxNumScellsDlFr1=4
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRCELL:actK1Opt=intraAndInter-gNB
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

@{Scell_Rel}
...    NRCELL:a1MeasSCellAddEnabled=rsrp
...    NRCELL:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=85
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=75
...    NRCELL:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=80ms

...    NRCELL-2/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-2:gNbId=1
...    NRCELL-2/NRREL-2:gNbIdLength=22
...    NRCELL-2/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-2:removeNotAllowed=false
...    NRCELL-2/NRREL-2:lcrId=1
...    NRCELL-2/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-2:sCellOperationalMode=dlOnly
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
...    NRCELL-2/NRREL-11:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-11:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-11:gNbId=1
...    NRCELL-2/NRREL-11:gNbIdLength=22
...    NRCELL-2/NRREL-11:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-11:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-11:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-11:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-11:removeNotAllowed=false
...    NRCELL-2/NRREL-11:lcrId=11
...    NRCELL-2/NRREL-11:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-11:sCellOperationalMode=dlOnly

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
...    NRCELL-11/NRREL-3:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-3:sCellOperationalMode=dlOnly

${N66A_N77(3A)_and_N66A_N78(2A)_and_N66A_N78(2A)}    SEPARATOR=         #UE1_capa
...    E9A09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C4701BB8D85181AC1184341020E9068036B64C558D0E7C471E
...    819F604F8C48E3C873EA39F30C7942C0E070F05C00FFC007003FF0005C0000E0541B107582308682041E20D00656C98AB121CFB027C471E31238F21C
...    FA8E7CC31E50B0381C3C27FFC00001FFF00000170000381546C4DD608C21A0810748340165B262A86873E238F40CFB027C639F30C7942C0E070F02E0
...    07FE003801FF8002E0000702A0D831AC1184341020F941A00CAD931562439F11C7B027C62471E439F51CF9863CA1607038784FFF800003FFE000002E
...    0000702B8D84BAC1184341020E9068036B64C558D0E7C471E819F604F8C48E3C873EA39F30C7942C0E070F05C00FFC007003FF0005C0000E0551B133
...    582308682041D20D00596C98AA1A1CF88E3D033EC09F18E7CC31E50B0381C3C0B801FF800E007FE000B80001C0A836236B04610D04083E5068032B64
...    C55890E7C471EC09F1891C790E7D473E618F28581C0E1E13FFE00000FFF800000B80001C011787882001C46000000160205E1E128007134000008580
...    8178B850001C41000E230000020B0102F17060003882001C4D000006160205E1E14000713400002058081707850001C4100000A160205E1E20800711
...    800003058081787882001C4D00000E160205E2E1400071040038820000202C040BC5C28000E2300071180000485808178B882001C41000E2300000A0
...    B0102F1710400388C001C46000016160205E1E2300071340000605808178F830001C41000E2300071300000685808178F882001C4C000E2600071300
...    000705808178B882001C4D000E2680000F0B0102F1F104003882001C4D000E268000100B01020120234028809B01060260BA006D84614489B1CF870A
...    244D8E7C38912244D8E7C38912244D8E7C3851226C73E1C28913639F0E14489B1CF870A244D8E7C38912244D8E7C38912244D8E7C38912244D8E7C38
...    912244D8E7C3851226C73E1C68912244D8E7C38D1224489B1CF871224489B1CF871A2448913639F0C00C888C6318C6318C6318C6318CF417001E0014
...    0E0A00E0601280380030120020301F02001000000008000010040000100200000C01000008008000050040000300200001C01000010043032B2A2B26
...    2B236B066B062B036B2A6B26680E0800004B29282000032CA4A0800014B29282000072CA4A0800024B292820000B2CA4A0800034B292820000F2CA4A
...    03A81D552AAAA4D5548F2A8365506AAA07954AB285801200340A00100808010020200400840402004010040084020080100801002020040088040280
...    50100E01C040400808080300602008010404010020100200420201002008010021010020040401002100802004020040080801002201004008040080
...    1010020044020040080801002020040088040080101002004040080108080100202008010C0C0300680500A0600400C0080103002006004008180801
...    100400860600400C038010301000A008010180300701200C0C0180380900620100E00404048030101200C60201C00808070020202401808090063543
...    E00020406080C0E1416181A2022242628303236383A3E424A4C4E5052545A5E828305A

${N66A_N77(3A)_and_N66A_N78(2A)_and_N66A_N78(2A)_n77E_enable_Canada}    SEPARATOR=         #UE2_capa
...    E9A09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C4701BB8D85181AC1184341020E9068036B64C558D0E7C471E
...    819F604F8C48E3C873EA39F30C7942C0E070F05C00FFC007003FF0005C0000E0541B107582308682041E20D00656C98AB121CFB027C471E31238F21C
...    FA8E7CC31E50B0381C3C27FFC00001FFF00000170000381546C4DD608C21A0810748340165B262A86873E238F40CFB027C639F30C7942C0E070F02E0
...    07FE003801FF8002E0000702A0D831AC1184341020F941A00CAD931562439F11C7B027C62471E439F51CF9863CA1607038784FFF800003FFE000002E
...    0000702B8D84BAC1184341020E9068036B64C558D0E7C471E819F604F8C48E3C873EA39F30C7942C0E070F05C00FFC007003FF0005C0000E0551B133
...    582308682041D20D00596C98AA1A1CF88E3D033EC09F18E7CC31E50B0381C3C0B801FF800E007FE000B80001C0A836236B04610D04083E5068032B64
...    C55890E7C471EC09F1891C790E7D473E618F28581C0E1E13FFE00000FFF800000B80001C011787882001C46000000160205E1E128007134000008580
...    8178B850001C41000E230000020B0102F17060003882001C4D000006160205E1E14000713400002058081707850001C4100000A160205E1E20800711
...    800003058081787882001C4D00000E160205E2E1400071040038820000202C040BC5C28000E2300071180000485808178B882001C41000E2300000A0
...    B0102F1710400388C001C46000016160205E1E2300071340000605808178F830001C41000E2300071300000685808178F882001C4C000E2600071300
...    000705808178B882001C4D000E2680000F0B0102F1F104003882001C4D000E268000100B01020120234028809B01060260BA016D84614489B1CF870A
...    244D8E7C38912244D8E7C38912244D8E7C3851226C73E1C28913639F0E14489B1CF870A244D8E7C38912244D8E7C38912244D8E7C38912244D8E7C38
...    912244D8E7C3851226C73E1C68912244D8E7C38D1224489B1CF871224489B1CF871A2448913639F0C00C888C6318C6318C6318C6318C0102F417001E
...    00140E0A00E0601280380030120020301F02001000000008000010040000100200000C01000008008000050040000300200001C01000010043032B2A
...    2B262B236B066B062B036B2A6B26680E0800004B29282000032CA4A0800014B29282000072CA4A0800024B292820000B2CA4A0800034B292820000F2
...    CA4A03A81D552AAAA4D5548F2A8365506AAA07954AB285801200340A0010080801002020040084040200401004008402008010080100202004008804
...    028050100E01C04040080808030060200801040401002010020042020100200801002101002004040100210080200402004008080100220100400804
...    00801010020044020040080801002020040088040080101002004040080108080100202008010C0C0300680500A0600400C008010300200600400818
...    0801100400860600400C038010301000A008010180300701200C0C0180380900620100E00404048030101200C60201C0080807002020240180809006
...    3543E00020406080C0E1416181A2022242628303236383A3E424A4C4E5052545A5E828305A

${N66(2A)_N77(2A)_and_N66A_N77(3A)_and_N66B_N77A}    SEPARATOR=            #UE3_capa
...    E9A09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C4701BB8D85181AC1184341020E9068036B64C558D0E7C471
...    E819F604F8C48E3C873EA39F30C7942C0E070F05C00FFC007003FF0005C0000E0541B107582308682041E20D00656C98AB121CFB027C471E31238F2
...    1CFA8E7CC31E50B0381C3C27FFC00001FFF00000170000381546C4DD608C21A0810748340165B262A86873E238F40CFB027C639F30C7942C0E070F0
...    2E007FE003801FF8002E0000702A0D831AC1184341020F941A00CAD931562439F11C7B027C62471E439F51CF9863CA1607038784FFF800003FFE000
...    002E0000702B8D84BAC1184341020E9068036B64C558D0E7C471E819F604F8C48E3C873EA39F30C7942C0E070F05C00FFC007003FF0005C0000E055
...    1B133582308682041D20D00596C98AA1A1CF88E3D033EC09F18E7CC31E50B0381C3C0B801FF800E007FE000B80001C0A836236B04610D04083E5068
...    032B64C55890E7C471EC09F1891C790E7D473E618F28581C0E1E13FFE00000FFF800000B80001C011787882001C46000000160205E1E12800713400
...    00085808178B850001C41000E230000020B0102F17060003882001C4D000006160205E1E14000713400002058081707850001C4100000A160205E1E
...    20800711800003058081787882001C4D00000E160205E2E1400071040038820000202C040BC5C28000E2300071180000485808178B882001C41000E
...    2300000A0B0102F1710400388C001C46000016160205E1E2300071340000605808178F830001C41000E2300071300000685808178F882001C41000E
...    2600071300000805808178F882001C4C000E26000713000007058081787882083C4C00001E16020402404680510136020C04C17400D908C28913639
...    F0E14489B1CF871224489B1CF871224489B1CF870A244D8E7C3851226C73E1C28913639F0E14489B1CF871224489B1CF871224489B1CF871224489B
...    1CF871224489B1CF870A244D8E7C38D1224489B1CF871A2448913639F0E344891226C73E1C28913639F0C0191118C6318C6318C6318C6319E82E003
...    C00281C1401C0C02500700060240040603E0400200000001000002008000020040020180600800004004000028020000180100000E0080000802181
...    959515931591B58335831581B5953593340704000025949410000196525040000A5949410040300E594941000049652504000165949410000696525
...    040001E5949407503AAA555549AAA91E5506CAA0D5540F2A95650B00240068140020101002004040080108080400802008010804010020100200404
...    0080110080500A0201C038080801010100600C040100208080200402004008404020040100200420200400808020042010040080400801010020044
...    0200801008010020200400880400801010020040400801100801002020040080801002101002004040100218180600D00A0140C0080180100206004
...    00C0080103010022008010C0C038018070020602401C018030301200E024018180300701200C202010020080200430100E00404038010100600C040
...    48031AA1F000102030406070A0B0C0D101112131418191B1C1D1F2125262728292A2D2F414182D0

@{pm_couter_AA11}
...    NRCELL-11:${GNB_SA_ADMISSION_MFBI_REQ}=0
...    NRCELL-11:${GNB_SA_ADMISSION_MFBI_SUCC}=0
...    NRCELL-11:${GNB_SA_DU_ADMISSION_MFBI_REQ}=0
...    NRCELL-11:${GNB_SA_DU_ADMISSION_MFBI_SUCC}=0
...    NRCELL-1:${UE_SCELL_1_CONF_SCELL_DL_SA}=0
...    NRCELL-2:${UE_SCELL_1_CONF_SCELL_DL_SA}=0
...    NRCELL-3:${UE_SCELL_1_CONF_SCELL_DL_SA}=0
...    NRCELL-2:${UE_SCELL_2_CONF_SCELL_DL_SA}=0
...    NRCELL-1:${UE_SCELL_2_CONF_SCELL_DL_SA}>0
...    NRCELL-3:${UE_SCELL_2_CONF_SCELL_DL_SA}>0
...    NRCELL-1:${UE_SCELL_3_CONF_SCELL_DL_SA}>0
...    NRCELL-2:${UE_SCELL_3_CONF_SCELL_DL_SA}>0
...    NRCELL-3:${UE_SCELL_3_CONF_SCELL_DL_SA}>0
...    NRCELL-1:${SCELL_CONF_ALT_BAND_SA}=2
...    NRCELL-2:${SCELL_CONF_ALT_BAND_SA}=0
...    NRCELL-3:${SCELL_CONF_ALT_BAND_SA}=2

@{pm_couter_AA11_2}
...    NRCELL-11:${GNB_SA_ADMISSION_MFBI_REQ}=0
...    NRCELL-11:${GNB_SA_ADMISSION_MFBI_SUCC}=0
...    NRCELL-11:${GNB_SA_DU_ADMISSION_MFBI_REQ}=0
...    NRCELL-11:${GNB_SA_DU_ADMISSION_MFBI_SUCC}=0
...    NRCELL-1:${UE_SCELL_1_CONF_SCELL_DL_SA}=0
...    NRCELL-2:${UE_SCELL_1_CONF_SCELL_DL_SA}=0
...    NRCELL-3:${UE_SCELL_1_CONF_SCELL_DL_SA}=0
...    NRCELL-2:${UE_SCELL_2_CONF_SCELL_DL_SA}=0
...    NRCELL-1:${UE_SCELL_2_CONF_SCELL_DL_SA}=0
...    NRCELL-3:${UE_SCELL_2_CONF_SCELL_DL_SA}=0
...    NRCELL-1:${UE_SCELL_3_CONF_SCELL_DL_SA}>0
...    NRCELL-2:${UE_SCELL_3_CONF_SCELL_DL_SA}>0
...    NRCELL-3:${UE_SCELL_3_CONF_SCELL_DL_SA}>0
...    NRCELL-1:${SCELL_CONF_ALT_BAND_SA}=0
...    NRCELL-2:${SCELL_CONF_ALT_BAND_SA}=0
...    NRCELL-3:${SCELL_CONF_ALT_BAND_SA}=0

@{PM_Counters_Check_AA12}
...    NRCELL-3:${UE_SCELL_3_CONF_SCELL_DL_SA}>0
...    NRCELL-1:${UE_SCELL_3_CONF_SCELL_DL_SA}>0
...    NRCELL-11:${UE_SCELL_3_CONF_SCELL_DL_SA}>0
...    NRCELL-2:${GNB_SA_ADMISSION_MFBI_REQ}=0
...    NRCELL-2:${GNB_SA_ADMISSION_MFBI_SUCC}=0
...    NRCELL-2:${GNB_SA_DU_ADMISSION_MFBI_REQ}=0
...    NRCELL-2:${GNB_SA_DU_ADMISSION_MFBI_SUCC}=0
...    NRCELL-1:${SCELL_CONF_ALT_BAND_SA}=1
...    NRCELL-3:${SCELL_CONF_ALT_BAND_SA}=1

${SCELL_CONF_ALT_BAND_SA}    M55118C01005    #This counter provides the number of current cell configurations as an SA SCell in an alternative band
${GNB_SA_ADMISSION_MFBI_REQ}    M55138C00501    #This counter provides the number of radio admission requests for the SA user, where admission is
#requested on the alternative band.The counter is updated to the PCell on CU.
${GNB_SA_ADMISSION_MFBI_SUCC}    M55138C00502    #This counter provides the number of admitted radio admission requests for the SA user,
#where admission is done on the alternative band.The counter is updated to the PCell on CU.
${GNB_SA_DU_ADMISSION_MFBI_REQ}    M55139C02001    #This counter provides the number of radio admission requests with MFBI for the SA user.
#The counter is updated to the PCell on DU.
${GNB_SA_DU_ADMISSION_MFBI_SUCC}    M55139C02002    #This counter provides the number of radio-admitted UEs for the SA user
#using the alternative band.The counter is updated to the PCell on DU.
${UE_SCELL_1_CONF_SCELL_DL_SA}    M55118C05508    #This counter indicates the sum of samples for the total number of CA UEs in the current cell
#configured as an SCell with 1 configured SCell in DL in SA mode. The counter is pegged in the secondary cell.
${UE_SCELL_3_CONF_SCELL_DL_SA}    M55118C11009    #The sum of samples for total number of CA UEs in the current cell configured as an SCell
#while pegged in the secondary cell, which have three configured SCells in DL in SA mode.
${UE_SCELL_2_CONF_SCELL_DL_SA}    M55118C07002     #The sum of samples for total number of CA UEs in the current cell configured as an SCell
#while pegged in the secondary cell, which have three configured SCells in DL in SA mode.

@{scelladd_expect_UE81}
...    pcid:50, scellIdx:1
...    pcid:52, scellIdx:2
...    pcid:60, scellIdx:3
...    pcid:51, scellIdx:0
...    rrcReconfigurationComplete
...    SCellIndex 1 activated successfully at airphone
...    SCellIndex 2 activated successfully at airphone
...    SCellIndex 3 activated successfully at airphone

${pdu_id}    1
${nwslice}    1

@{pass_regexp_AA11_UE1}
...    QoS Routing Table
...    pcid:52, scellIdx:2
...    pcid:50, scellIdx:1
...    pcid:60, scellIdx:0

@{pass_regexp_AA11_UE2}
...    QoS Routing Table
...    pcid:52, scellIdx:3
...    pcid:50, scellIdx:1
...    pcid:51, scellIdx:2
...    pcid:60, scellIdx:0

@{pass_regexp_AA11_UE3}
...    QoS Routing Table
...    pcid:52, scellIdx:2
...    pcid:50, scellIdx:1
...    pcid:60, scellIdx:0

@{pass_regexp_AA11_UE4}
...    QoS Routing Table
...    pcid:52, scellIdx:3
...    pcid:50, scellIdx:1
...    pcid:51, scellIdx:2
...    pcid:60, scellIdx:0

@{AA11_Exchange_Native_Alternative}
...    NRSYSINFO_PROFILE-1/NRIRFIM-1:freqBandIndicatorNR=77          #native band       inter-frequency re-selection    nrcell-1
...    NRSYSINFO_PROFILE-1/NRIRFIM-1:multiFreqBandIndicatorNR=78        #alternative band     inter-frequency re-selection
...    NRSYSINFO_PROFILE-1/NRIAFIM-1:multiFreqBandIndicatorNR=78          #alternative band    intra-frequency re-selectio

...    NRSYSINFO_PROFILE-3/NRIRFIM-1:freqBandIndicatorNR=77          #native band       nrcell-3
...    NRSYSINFO_PROFILE-3/NRIRFIM-1:multiFreqBandIndicatorNR=78        #alternative band
...    NRSYSINFO_PROFILE-3/NRIAFIM-1:multiFreqBandIndicatorNR=78           #alternative band
...    NRCELL-1:freqBandIndicatorNR=77
...    NRCELL-3:freqBandIndicatorNR=77
...    NRBTS/NRCONNECTMODE_PROFILE-2:multiFreqBandIndicatorNR=78
...    NRBTS/NRMULTIBANDINFO_PROFILE-2:nrMultibandInfoList:nrBandPriority=1|freqBandIndicatorNR=77
...    NRBTS/NRMULTIBANDINFO_PROFILE-2:nrMultibandInfoList:nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1|freqBandIndicatorNR=77
...    NRBTS/NRMULTIBANDINFO_PROFILE-2:nrMultibandInfoList:nrBandPriority=2|freqBandIndicatorNR=78
...    NRBTS/NRMULTIBANDINFO_PROFILE-2:nrMultibandInfoList:nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1|freqBandIndicatorNR=78

@{AA11_Exchange_Native_Alternative_Recover}
...    NRSYSINFO_PROFILE-1/NRIRFIM-1:freqBandIndicatorNR=78          #native band       inter-frequency re-selection    nrcell-1
...    NRSYSINFO_PROFILE-1/NRIRFIM-1:multiFreqBandIndicatorNR=77        #alternative band     inter-frequency re-selection
...    NRSYSINFO_PROFILE-1/NRIAFIM-1:multiFreqBandIndicatorNR=77          #alternative band    intra-frequency re-selectio

...    NRSYSINFO_PROFILE-3/NRIRFIM-1:freqBandIndicatorNR=78          #native band       nrcell-3
...    NRSYSINFO_PROFILE-3/NRIRFIM-1:multiFreqBandIndicatorNR=77        #alternative band
...    NRSYSINFO_PROFILE-3/NRIAFIM-1:multiFreqBandIndicatorNR=77           #alternative band
...    NRCELL-1:freqBandIndicatorNR=78
...    NRCELL-3:freqBandIndicatorNR=78
...    NRBTS/NRCONNECTMODE_PROFILE-2:multiFreqBandIndicatorNR=77
...    NRBTS/NRMULTIBANDINFO_PROFILE-2:nrMultibandInfoList:nrBandPriority=1|freqBandIndicatorNR=78
...    NRBTS/NRMULTIBANDINFO_PROFILE-2:nrMultibandInfoList:nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1|freqBandIndicatorNR=78
...    NRBTS/NRMULTIBANDINFO_PROFILE-2:nrMultibandInfoList:nrBandPriority=2|freqBandIndicatorNR=77
...    NRBTS/NRMULTIBANDINFO_PROFILE-2:nrMultibandInfoList:nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1|freqBandIndicatorNR=77

@{Deactivate_DL256QAM_NRCELL}
...    NRCELL:actDl256Qam=false
@{activate_DL256QAM_NRCELL}
...    NRCELL:actDl256Qam=true

*** Test Cases ***
CB007219-ET-AA11_Verify intra-gNB CA scell selection with alternative bands and extended band77 in Canada
    [Documentation]
    ...    1. Purpose:This user scenario describes the successful setup of CA, when some of the aggregated cells are configured with an
    ...       alternative band and one SCell applies band 77 extended for Canada.
    ...    2. Configuration
    ...    a. NRCELL-1 TDD native:N78 alternative:N77 40Mhz dlmimo: 4x4 or 4x2 Closed Loop Spatial Multiplexing
    ...       NRCELL-2 TDD N77E_Canada 100Mhz dlmimo: 4x4 or 4x2 Closed Loop Spatial Multiplexing
    ...       NRCELL-3 TDD native:N78 alternative:N77 40Mhz dlmimo: 4x4 or 4x2 Closed Loop Spatial Multiplexing
    ...       NRCELL-4 TDD native:N38 alternative:N41 20Mhz dlmimo: 4x4 or 4x2 Closed Loop Spatial Multiplexing
    ...       NRCELL-11 FDD N66 20Mhz dlmimo: 2x2 Closed Loop Spatial Multiplexing
    ...       NRCELL-12 FDD N66 20Mhz dlmimo: 2x2 Closed Loop Spatial Multiplexing
    ...       NRCELL-13 FDD N2 20Mhz dlmimo: 4x4 or 4x2 Closed Loop Spatial Multiplexing
    ...       NRCELL-14 FDD N2 20Mhz dlmimo: 4x4 or 4x2 Closed Loop Spatial Multiplexing
    ...    3. Test Case Steps:
    ...    a. UE1 register to NRCELL-11 n66_2layer_20mhz,blind added NRCELL-1,3 n78_4layer_40mhz,n78_4layer_40mhz
    ...    b. UE2 register to NRCELL-11 n66_2layer_20mhz,blind added NRCELL-2 n77_4layer_100mhz, NRCELL-1,3 n77_2layer_40mhz,n77_2layer_40mhz
    ...    c. UE3 register to NRCELL-11 n66_2layer_20mhz,blind added NRCELL-1,3 n77_4layer_40mhz,n77_2layer_40mhz
    ...    d. change NRCELL1,3 to native N77,alternative N78
    ...    e. UE4 register to NRCELL-11 n66_2layer_20mhz,blind added NRCELL-2 n77_4layer_100mhz, NRCELL-1,3 n77_2layer_40mhz,n77_2layer_40mhz
    ...    f. deregister UEs. check counter. check wireshark log.
    [Tags]     QC_320573    AA11    zhang.yige    CA_LABEL-FTT(20MHZ_FDD_n66+40MHZ_TDD_n78+40MHZ_TDD_n78)
    ...     CA_LABEL-FTTT(20MHZ_FDD_n66+40MHZ_TDD_n77+40MHZ_TDD_n77+100MHZ_TDD_n77)    CA_LABEL-FTT(20MHZ_FDD_n66+40MHZ_TDD_n77+40MHZ_TDD_n77)
    Clear Counter Files    wait=${False}
    UE1 UE2 UE3 Register
    check counters    pm_counters_expression=${pm_couter_AA11}
    OnlineParamChange    ${AA11_Exchange_Native_Alternative}
    UE Deregister From GNB AA11    ue_num=3
    clear counter files
    UE4 Register
    check counters    pm_counters_expression=${pm_couter_AA11_2}
    UE Deregister From gNB    ue_id=4
    Check Wireshark Log    ${CURDIR}${/}A2A_AA11${/}a2a.ini    wait_string=UEContextModificationResponse::40
    [Teardown]    AA11_Teardown

CB007219-ET-AA12_Verify intra-gNB CA setup with alternative bands and with the PCell in the extended band 77 in Canada
    [Documentation]
    ...    1. This user scenario describes the successful setup of CA,when some of the aggregated cells are configured
    ...    with an alternative band and the PCell applies band 77 extended for Canada.
    ...    2. Configuration
    ...    a. NRCELL-1 TDD native:N78 alternative:N77 40Mhz dlmimo: 4x4 or 4x2 Closed Loop Spatial Multiplexing
    ...       NRCELL-2 TDD N77E_Canada 100Mhz dlmimo: 4x4 or 4x2 Closed Loop Spatial Multiplexing
    ...       NRCELL-3 TDD native:N78 alternative:N77 40Mhz dlmimo: 4x4 or 4x2 Closed Loop Spatial Multiplexing
    ...       NRCELL-4 TDD native:N38 alternative:N41 20Mhz dlmimo: 4x4 or 4x2 Closed Loop Spatial Multiplexing
    ...       NRCELL-11 FDD N66 20Mhz dlmimo: 2x2 Closed Loop Spatial Multiplexing
    ...       NRCELL-12 FDD N66 20Mhz dlmimo: 2x2 Closed Loop Spatial Multiplexing
    ...       NRCELL-13 FDD N2 20Mhz dlmimo: 4x4 or 4x2 Closed Loop Spatial Multiplexing
    ...       NRCELL-14 FDD N2 20Mhz dlmimo: 4x4 or 4x2 Closed Loop Spatial Multiplexing
    ...    3. Test Case Steps:
    ...    a. ue register to cell 2.And start traffic for DL/UL.
    ...    b. Trigger A1 for scell addition. cell 1,cell 3 ,cell 11 add as scells.
    ...    c. check traffic ok.
    ...    d. check counter ok.
    [Tags]    QC_320572    AA12    zora    CA_LABEL-TTTF(100MHZ_TDD_n77+40MHZ_TDD_n77+40MHZ_TDD_n77+20MHZ_FDD_n66)
    OnlineParamChange    ${Deactivate_DL256QAM_NRCELL}
    Clear Counter Files
    Ue register and pdu session setup    ue_id=81    cell_id=2
    Send Throughput    ue_id=81
    Trigger ScellAdd
    Check Traffic
    UE Deregister From gNB    ue_id=81
    Check Wireshark Log    ${CURDIR}${/}A2A_AA12${/}a2a.ini    wait_string=UEContextReleaseComplete::4
    check counters    pm_counters_expression=${PM_Counters_Check_AA12}
    [Teardown]    AA12_Teardown

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/8cells_4T4F_2N2_2N66_3N78_N38    ue_count=15
    Update UE capa    ${N66A_N77(3A)_and_N66A_N78(2A)_and_N66A_N78(2A)}    ue_id=1
    Update UE capa    ${N66A_N77(3A)_and_N66A_N78(2A)_and_N66A_N78(2A)_n77E_enable_Canada}    ue_id=2
    Update UE capa    ${N66(2A)_N77(2A)_and_N66A_N77(3A)_and_N66B_N77A}    ue_id=3
    Update UE capa    ${N66A_N77(3A)_and_N66A_N78(2A)_and_N66A_N78(2A)_n77E_enable_Canada}    ue_id=4
    Update UE capa    ${N66A_N77(3A)_and_N66A_N78(2A)_and_N66A_N78(2A)_n77E_enable_Canada}    ue_id=81

AA12_Teardown
    OnlineParamChange    ${activate_DL256QAM_NRCELL}
    Execute Egate Command    csi_override_testmode_nr profile_id=1 cqi_mode=fixed cqi=15 ri_mode=fixed ri=0    pass_regexp=numOfCri
    Execute Egate Command    ue_testmode_set_nr id=81 testmode=csi_override action=deactivate profile_id=1 scell=0
    Common Test Teardown And Stop Capture Logs

AA11_Teardown
    OnlineParamChange    ${AA11_Exchange_Native_Alternative_Recover}
    Common Test Teardown And Stop Capture Logs

UE1 UE2 UE3 Register
    Ue register and Scell Addition    ${pass_regexp_AA11_UE1}    cell_id=11    ue_id=1    gw_id=1
    Ue register and Scell Addition    ${pass_regexp_AA11_UE2}    cell_id=11    ue_id=2    gw_id=2
    Ue register and Scell Addition    ${pass_regexp_AA11_UE3}    cell_id=11    ue_id=3    gw_id=3

UE4 Register
    Ue register and Scell Addition    ${pass_regexp_AA11_UE4}    cell_id=11    ue_id=4    gw_id=4

UE Deregister From GNB AA11
    [Arguments]    ${ue_num}=${ue_num_All}
    FOR    ${index}    IN RANGE    1    ${ue_num}+1
        UE Deregister From gNB    ue_id=${index}
    END

UE Deregister From gNB
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s

Ue register and Scell Addition
    [Arguments]    ${pass_regexp}    ${cell_id}=11    ${ue_id}=1    ${gw_id}=1
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=${gw_id} nwslice=${nwslice}    pass_regexp=${pass_regexp}
    Send Throughput    ue_id=${ue_id}
    Verify Throughput    ue_id=${ue_id}     Tput_dl=500    Tput_ul=35
    Stop traffic    ue_id=${ue_id}

Stop traffic
    [Arguments]    ${ue_id}=1    ${pdu}=1
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=${pdu}    pass_regexp=Stopped Downlink Internal traffic on Ue:${ue_id}.*TrfId:4

Send Throughput
    [Arguments]    ${ue_id}=81    ${times}=5    ${mbps}=150
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=ul mbps=40 trf_id=1    UE ${ue_id}: UDP UL
    FOR    ${I}    IN RANGE    1    ${times}
        Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=${mbps} trf_id=${I}    UE ${ue_id}: UDP DL
    END
    sleep    10s    #sleep for stable traffic

Verify Throughput
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${qfi}=1    ${Tput_dl}=10    ${Tput_ul}=35    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    direction=ul    rate_type=ave
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pdsch    Throughput
    Should Not Match Regexp    ${scell_tput}    CellIndex-[0-3] *0 *0 *0
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

Check Traffic
    [Arguments]     ${ue_id}=81    ${cell_num}=4    ${min_dl_tput}=500    ${min_ul_tput}=35    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    ${ul_throuput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pusch    rate_type=current
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pdsch    Throughput
    ${total_dl_tput}    Set Variable    0
    FOR    ${index}    IN RANGE    0    ${cell_num}
         ${str_index}    Convert To String    ${index}
         ${scell_tput}    Ap Get Throuput On Specific Scell    ${ue_id}    ${str_index}    pdsch
         Should Be True    ${scell_tput}/1000 > 0
         ${total_dl_tput}    Evaluate    ${scell_tput}+${total_dl_tput}
    END
    Should Be True    ${total_dl_tput}/1000 > ${min_dl_tput}
    Should Be True    ${ul_throuput}/1000 > ${min_ul_tput}

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir

Update UE capa
    [Arguments]    ${SA_Capa_perUE_Full}=none    ${ue_id}=81
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full}
    Execute Egate Command    ${cmd}

Ue register and pdu session setup
    [Arguments]    ${ue_id}=1    ${cell_id}=2
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=UE now in NG RM Registere
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=1    pass_regexp=QoS Routing Table

Trigger ScellAdd
    [Arguments]    ${event_type}=A1    ${carrierfreq}=648096    ${srsrp_nr}=90    ${srsrq_nr}=90    ${ue_id}=81
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr    id=${ue_id}    meas_id=${meas_id}    event=${event_type}
    ...    srsrp_nr=${srsrp_nr}    srsrq_nr=${srsrq_nr}
    Execute Egate Command    ${cmd}    pass_regexp=${scelladd_expect_UE81}
    Execute Egate Command    csi_override_testmode_nr profile_id=1 cqi_mode=fixed cqi=15 ri_mode=fixed ri=0    pass_regexp=numOfCri
    Execute Egate Command    ue_testmode_set_nr id=${ue_id} testmode=csi_override action=activate profile_id=1 scell=0    pass_regexp=profileId
