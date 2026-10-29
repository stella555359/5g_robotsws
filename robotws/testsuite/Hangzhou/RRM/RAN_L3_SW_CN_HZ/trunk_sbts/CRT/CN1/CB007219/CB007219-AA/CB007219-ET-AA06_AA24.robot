*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    team-CN1ET    owner-ha.zheng
...    CLOUD_5G_I_BOO_AP_LOO    CRT    CB007219    release-SBTS23R4
Resource    ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{7219}
...    @{1416}
...    @{CA_enable}
...    @{MimoMode_Para}
...    @{CA_REL}

@{7219}
...    NRBTS:actMfbiNrCaSupportFr1=true
...    NRBTS:actMfbiNrCaMeasConfResolv=false
...    NRCELL-2:nrarfcn=638332
...    NRCELL-2:gscnOrSsPbchArfcn=7898
...    NRCELL-3:nrarfcn=643664
...    NRCELL-3:gscnOrSsPbchArfcn=7953
...    NRCELL-1:chBw=80MHz
...    NRCELL-2:chBw=80MHz
...    NRCELL-3:chBw=80MHz

@{1416}
...    NRBTS:actMultiFrequencyBandIndicatorNRSupport=true
...    NRCELL-1:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-1
...    NRCELL-1:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-1

...    NRCELL-3:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-1
...    NRCELL-3:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-1

...    NRCELL-4:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-2
...    NRCELL-4:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-2

...    NRBTS/NRCONNECTMODE_PROFILE-1:multiFreqBandIndicatorNR=77
...    NRBTS/NRCONNECTMODE_PROFILE-2:multiFreqBandIndicatorNR=41

...    NRBTS/NRMULTIBANDINFO_PROFILE-1:nrMultibandInfoList:nrBandPriority=1|freqBandIndicatorNR=78
...    NRBTS/NRMULTIBANDINFO_PROFILE-1:nrMultibandInfoList:nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1|freqBandIndicatorNR=78
...    NRBTS/NRMULTIBANDINFO_PROFILE-1:nrMultibandInfoList:nrBandPriority=2|freqBandIndicatorNR=77
...    NRBTS/NRMULTIBANDINFO_PROFILE-1:nrMultibandInfoList:nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1|freqBandIndicatorNR=77

...    NRBTS/NRMULTIBANDINFO_PROFILE-2:nrMultibandInfoList:nrBandPriority=1|freqBandIndicatorNR=38
...    NRBTS/NRMULTIBANDINFO_PROFILE-2:nrMultibandInfoList:nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1|freqBandIndicatorNR=38
...    NRBTS/NRMULTIBANDINFO_PROFILE-2:nrMultibandInfoList:nrBandPriority=2|freqBandIndicatorNR=41
...    NRBTS/NRMULTIBANDINFO_PROFILE-2:nrMultibandInfoList:nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1|freqBandIndicatorNR=41

...    NRBTS/NRNSPMAX_PROFILE-1:nrNsPmaxList:additionalSpectrumEmission=1
...    NRBTS/NRNSPMAX_PROFILE-1:nrNsPmaxList:nrNsPmaxPriority=1

@{CA_enable}
...    NRBTS-1:actCarrierAggregation=true
...    NRBTS-1:caConfigurationSupport=2CCDL_2CCUL
...    NRDU-1:actInterNumerologyCa=true
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRBTS-1:actMeasBasedSCellAdditionSa=A1-based
...    NRCELL:maxNumScellsDlFr1=4
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRCELL:actK1Opt=intra-gNB
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

@{CA_REL}
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
...    NRCELL-1/NRREL-2:lcrId=2
...    NRCELL-1/NRREL-2:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-3:isRplCellForPSCell=true
...    NRCELL-1/NRREL-3:gNbId=1
...    NRCELL-1/NRREL-3:gNbIdLength=22
...    NRCELL-1/NRREL-3:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-3:removeNotAllowed=false
...    NRCELL-1/NRREL-3:lcrId=3
...    NRCELL-1/NRREL-3:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-3:sCellOperationalMode=dlOnly
...    NRCELL-1:a1MeasSCellAddEnabled=rsrp
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=70|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=90|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-1:a1MeasSCellAddSsbRsrq:a1HysteresisSCellAddSsbRsrq=0|a1TimeToTriggerSCellAddSsbRsrq=320ms
...    NRCELL-1:a1MeasSCellAddSsbRsrq:a1ThresholdSCellAddSsbRsrq=30|a1TimeToTriggerSCellAddSsbRsrq=320ms

@{N77_N77_CA_succ}
...    rrcReconfigurationComplete
...    pcid:52, scellIdx:1
...    pcid:50, scellIdx:0
...    freqBandIndicatorNR 77

@{N78_N78_CA_succ}
...    rrcReconfigurationComplete
...    pcid:52, scellIdx:1
...    pcid:50, scellIdx:0
...    freqBandIndicatorNR 78


@{OnlineParam_AA06_1}
...    NRCELL-1/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-1:freqBandIndicatorNR=77
...    NRCELL-2:freqBandIndicatorNR=77
...    NRCELL-3:freqBandIndicatorNR=77
...    NRCONNECTMODE_PROFILE-1:multiFreqBandIndicatorNR=78

@{OnlineParam_AA06_2}
...    NRCELL-1/NRREL-2:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-3:sCellAdditionMethod=blind
...    NRCELL-1:freqBandIndicatorNR=78
...    NRCELL-2:freqBandIndicatorNR=78
...    NRCELL-3:freqBandIndicatorNR=78
...    NRCONNECTMODE_PROFILE-1:multiFreqBandIndicatorNR=77

@{online_modify_for_AA24}
...    NRBTS:actHighestEstNrTputBcSel=true

@{online_recovery_for_AA24}
...    NRBTS:actHighestEstNrTputBcSel=false

${N1_N77_and_N1_N77_N77_and_N1_N77_N77_N77_and_N1_N3_N77_and_N1_N3_N77_N77}    SEPARATOR=
...    E9A09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C4700EA0D801AC1184341020F1068032B64C55890E
...    7D813E238F1891C790E7D473E618F28581C0E1E13FFE00000FFF800000B80001C0A836016B04610D04083E5068032B64C55890E7C471EC09
...    F1891C790E7D473E618F28581C0E1E13FFE00000FFF800000B80001C0AA36266B04610D04083A41A00B2D931543439F11C7A067D813E31CF
...    9863CA16070387817003FF001C00FFC00170000381546C4DD608C21A0810748340165B262A86873E238F40CFB027C639F30C7942C0E070F0
...    2E007FE003801FF8002E000070015E1E0000071300000005808178B800001C4C000E260000010B0102F1F000003898001C4C000E26000002
...    0B0102F17000003804001C4C000006160205E3E000007008003898001C4C00000816020401C000800501320268BA002381614489B1CF8712
...    24489B1CF871A2448913639F0E2448913639F0E344891226C73E1805828C6318C0F417001E00140E0A00E0601280380030120020301F01C0
...    1000000008000010040000100200000C01000008008000050040000300200001C076065606D6525652D60CD60C5606D654D01C1000009652
...    504000065949410000296525040000E594941000049652504000165949410000696525040001E5949407503AAA07954A6AA94E5506CAA0D5
...    540F2A95650B0024006814000810100400804020041018020050020040C018038040080600C01C018031808010020200C01808030060200C
...    01880C0100280100206008014008010300600E010020C0C010028010020600400C008010300600E010020180300700600C6A87C0004080C1
...    0181C282C30344044484C5060646C70747C8494989CA0A4A8B4BD05060B4

${N1_N78_and_N1_N78_N78_and_N1_N78_N78_N78_and_N1_N3_N78_and_N1_N3_N78_N78}    SEPARATOR=
...    E9A09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C4700EA0D801AC1184341020F1068032B64C55890E
...    7D813E238F1891C790E7D473E618F28581C0E1E13FFE00000FFF800000B80001C0A836016B04610D04083E5068032B64C55890E7C471EC09
...    F1891C790E7D473E618F28581C0E1E13FFE00000FFF800000B80001C0AA36266B04610D04083A41A00B2D931543439F11C7A067D813E31CF
...    9863CA16070387817003FF001C00FFC00170000381546C4DD608C21A0810748340165B262A86873E238F40CFB027C639F30C7942C0E070F0
...    2E007FE003801FF8002E000070015E1E0000071340000005808178B800001C4D000E268000010B0102F1F00000389A001C4D000E26800002
...    0B0102F17000003804001C4D000006160205E3E00000700800389A001C4D00000816020401C000800501320268BA002381614489B1CF8712
...    24489B1CF871A2448913639F0E2448913639F0E344891226C73E1805828C6318C0F417001E00140E0A00E0601280380030120020301F01C0
...    1000000008000010040000100200000C01000008008000050040000300200001C076065606D6525652D60CD60C5606D654D01C1000009652
...    504000065949410000296525040000E594941000049652504000165949410000696525040001E5949407503AAA07954A6AA94E5506CAA0D5
...    540F2A95650B0024006814000810100400804020041018020050020040C018038040080600C01C018031808010020200C01808030060200C
...    01880C0100280100206008014008010300600E010020C0C010028010020600400C008010300600E010020180300700600C6A87C0004080C1
...    0181C282C30344044484C5060646C70747C8494989CA0A4A8B4BD05060B4

${N1_N77_and_N1_N77_N77_and_N1_N77_N77_N77_and_N1_N3_N77_and_N1_N3_N77_N77_and_N3_N77_N77}    SEPARATOR=
...    E9A09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C4700EA0D801AC1184341020F1068032B64C55890E
...    7D813E238F1891C790E7D473E618F28581C0E1E13FFE00000FFF800000B80001C0A836016B04610D04083E5068032B64C55890E7C471EC09
...    F1891C790E7D473E618F28581C0E1E13FFE00000FFF800000B80001C0AA36266B04610D04083A41A00B2D931543439F11C7A067D813E31CF
...    9863CA16070387817003FF001C00FFC00170000381546C4DD608C21A0810748340165B262A86873E238F40CFB027C639F30C7942C0E070F0
...    2E007FE003801FF8002E000070019E1E0000071300000005808178B800001C4C000E260000010B0102F1F000003898001C4C000E26000002
...    0B0102F17000003804001C4C000006160205E3E000007008003898001C4C000008160205E2E0100071300038980000042C0408038001000A
...    026404D174005503428913639F0E2448913639F0E344891226C73E1C4891226C73E1C68912244D8E7C38912244D8E7C3000B0618C6318DE8
...    2E003C00281C1401C0C02500700060240040603E038020000000100000200800002004000018020000100100000A008000060040000380EC
...    0CAC0DACA4ACA5AC19AC18AC0DACA9A0382000012CA4A080000CB29282000052CA4A080001CB29282000092CA4A080002CB292820000D2CA
...    4A080003CB29280EA075540F2A94D5529CAA0D9541AAA81E552ACA16004800D0280010202008010080400820300400A00400818030070080
...    100C0180380300630100200404018030100600C04018031018020050020040C010028010020600C01C020041818020050020040C00801801
...    0020600C01C020040300600E00C018D50F8000810182030385058606880889098A0C0C8D8E0E8F909293139414951697A0A0C168

${N1_N77_and_N3_N77_N77_and_N1_N77_N77_N77_and_N1_N3_N77_and_N1_N3_N77_N77_and_N1_N77_N77}    SEPARATOR=
...    E9A09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C4700EA0D801AC1184341020F1068032B64C55890E
...    7D813E238F1891C790E7D473E618F28581C0E1E13FFE00000FFF800000B80001C0A836016B04610D04083E5068032B64C55890E7C471EC09
...    F1891C790E7D473E618F28581C0E1E13FFE00000FFF800000B80001C0AA36266B04610D04083A41A00B2D931543439F11C7A067D813E31CF
...    9863CA16070387817003FF001C00FFC00170000381546C4DD608C21A0810748340165B262A86873E238F40CFB027C639F30C7942C0E070F0
...    2E007FE003801FF8002E000070019E1E0000071300000005808178B804001C4C000E260000010B0102F1F000003898001C4C000E26000002
...    0B0102F17000003804001C4C000006160205E3E000007008003898001C4C000008160205E2E0000071300038980000042C0408038001000A
...    026404D174005503428913639F0E2448913639F0E344891226C73E1C4891226C73E1C68912244D8E7C38912244D8E7C3000B0618C6318DE8
...    2E003C00281C1401C0C02500700060240040603E038020000000100000200800002004000018020000100100000A008000060040000380EC
...    0CAC0DACA4ACA5AC19AC18AC0DACA9A0382000012CA4A080000CB29282000052CA4A080001CB29282000092CA4A080002CB292820000D2CA
...    4A080003CB29280EA075540F2A94D5529CAA0D9541AAA81E552ACA16004800D0280010202008010080400820300400A00400818030070080
...    100C0180380300630100200404018030100600C04018031018020050020040C010028010020600C01C020041818020050020040C00801801
...    0020600C01C020040300600E00C018D50F8000810182030385058606880889098A0C0C8D8E0E8F909293139414951697A0A0C168

@{PM_Counters_Check_AA06}
...    NRCELL-3:${SCELL_CONF_ALT_BAND_SA}=1
...    NRCELL-1:${GNB_SA_ADMISSION_MFBI_REQ}=1
...    NRCELL-1:${GNB_SA_ADMISSION_MFBI_SUCC}=1
...    NRCELL-1:${GNB_SA_DU_ADMISSION_MFBI_REQ}=1
...    NRCELL-1:${GNB_SA_DU_ADMISSION_MFBI_SUCC}=1
...    NRCELL-3:${UE_SCELL_1_CONF_SCELL_DL_SA}>0

@{PM_Counters_Check_AA24}
...    NRCELL-3:${SCELL_CONF_ALT_BAND_SA}=2
...    NRCELL-1:${GNB_SA_ADMISSION_MFBI_REQ}=2
...    NRCELL-1:${GNB_SA_ADMISSION_MFBI_SUCC}=2
...    NRCELL-1:${GNB_SA_DU_ADMISSION_MFBI_REQ}=2
...    NRCELL-1:${GNB_SA_DU_ADMISSION_MFBI_SUCC}=2
...    NRCELL-3:${UE_SCELL_1_CONF_SCELL_DL_SA}>0

${SCELL_CONF_ALT_BAND_SA}    M55118C01005
#This counter provides the number of current cell configurations as an SA SCell in an alternative band
${GNB_SA_ADMISSION_MFBI_REQ}    M55138C00501
#This counter provides the number of radio admission requests for the SA user, where admission is
#requested on the alternative band.The counter is updated to the PCell on CU.
${GNB_SA_ADMISSION_MFBI_SUCC}    M55138C00502
#This counter provides the number of admitted radio admission requests for the SA user,
#where admission is done on the alternative band.The counter is updated to the PCell on CU.
${GNB_SA_DU_ADMISSION_MFBI_REQ}    M55139C02001
#This counter provides the number of radio admission requests with MFBI for the SA user.
#The counter is updated to the PCell on DU.
${GNB_SA_DU_ADMISSION_MFBI_SUCC}    M55139C02002
#This counter provides the number of radio-admitted UEs for the SA user using the alternative band.
#The counter is updated to the PCell on DU.
${UE_SCELL_1_CONF_SCELL_DL_SA}    M55118C05508
#This counter indicates the sum of samples for the total number of CA UEs in the current cell
#configured as an SCell with 1 configured SCell in DL in SA mode. The counter is pegged in the secondary cell.

*** Test Cases ***
CB007219-ET-AA06_Verify scell selection with the first BCFSEI with less number of UE not configured CCs at equal maximum
    [Documentation]
    ...    1. This user scenario describes the successful setup of DL intra-band CA, when one of the aggregated cells is
    ...    configured with an alternative band. if the same equal maximum aggregated channel bandwidth and number of
    ...    alternative bands, it will select BC with the first BC/FSEI with less number of UE not configured CCs.
    ...    2. Configuration
    ...    NRBTS/actMfbiNrCaSupportFr1 is set to true
    ...    NRBTS/actMultiFrequencyBandIndicatorNRSupport=true
    ...    alternative band configuration as below:
    ...    Cell configuration:
    ...    Cell_11 Cell_12 Cell_13 Cell_14 Cell_1 Cell_2 Cell_3 Cell_4
    ...    Technology type FDD FDD FDD FDD TDD TDD TDD TDD
    ...    Frequency F0 F1 F2 F3 F4 F5 F6 F7
    ...    Common channel bandwidth 20 20 20 20 80 80 80 80
    ...    Small BWP
    ...    DL MIMO Layers 2L 2L 4L 4L 4L 4L 4L 4L
    ...    Native band N66 N66 N2 N2 N78 N78 N78 N38
    ...    Alternative band NA NA NA NA N77 NA NN77 N41
    ...    cell1, cell2 and cell3 are contiguous, with F5<F6<F7
    ...    3. Test Case Steps:
    ...    a. attach UE81 to cell1, Start DL/UL traffic
    ...    b. online modification scell addition method for cell1 from blind to A1
    ...    c. attach UE82 to cell1, trigger A1 scell addtion, Start DL/UL traffic
    ...    d. check counters.
    ...    4. Expectation:
    ...    a. Cell1 in band n77 and Cell3 in band n77. BC#2FSEI#1 is selected.
    ...    BC#2:n1A-n77(2A)         N1 N77 N77
    ...    FSEI#1 DL MIMO layers    4L 2L 2L
    ...    DL ChBw (MHz)            20 80 80
    ...    c. Cell1 in band n78 and Cell3 in band n78. BC#2FSEI#1 is selected.
    ...    BC#2:n1A-n78(2A)         N1 N78 N78
    ...    FSEI#1 DL MIMO layers    4L 2L 2L
    ...    DL ChBw (MHz)            20 80 80
    ...    d. SCELL_CONF_ALT_BAND_SA update of cell3.
    [Tags]    QC_320568    ha.zheng    AA06    CA_LABEL-TT(80MHZ_TDD_n77(n78)+80MHZ_TDD_n77(n78))
    Clear Counter Files    wait=${False}
    Update UE capa    ${N1_N77_and_N1_N77_N77_and_N1_N77_N77_N77_and_N1_N3_N77_and_N1_N3_N77_N77}    ue_id=81
    Update UE capa    ${N1_N78_and_N1_N78_N78_and_N1_N78_N78_N78_and_N1_N3_N78_and_N1_N3_N78_N78}    ue_id=82
    Trigger blind ScellAdd    pass_CA=${N77_N77_CA_succ}    ue_id=81
    Check Counters    ${PM_Counters_Check_AA06}
    Clear Counter Files
    Trigger A1 ScellAdd succ    OnlineParam=${OnlineParam_AA06_1}    pass_CA=${N78_N78_CA_succ}
    ...    ue_id=82
    Check Counters    ${PM_Counters_Check_AA06}
    Check Wireshark Log    ${CURDIR}${/}A2A_AA06${/}a2a_gnb.ini    wait_string=UEContextReleaseComplete::8
    [Teardown]    AA06_Teardown

CB007219-ET-AA24_Verify scell selection with CNI81817 enable gNB-DU selects the FSEI which maximizes the DL data throughput
    [Documentation]
    ...    1. The purpose of this test case is to check that the successful setup of CA with alternative bands
    ...    when gNB-CU provides multiple Band Combinations and/or Feature Sets during the SCell addition.
    ...    2. Configuration
    ...    NRBTS/actHighestEstNrTputBcSel is set to “true”
    ...    NRBTS/actMfbiNrCaSupportFr1 is set to true
    ...    NRBTS/actMultiFrequencyBandIndicatorNRSupport=true
    ...    alternative band configuration as below:
    ...    Cell configuration:
    ...    Cell_1 Cell_3
    ...    Technology type TDD TDD
    ...    Common channel bandwidth 80 80
    ...    DL MIMO Layers 4L 4L
    ...    Native band N78 N78 
    ...    Alternative band N77 N77
    ...    UE1 capability: 
    ...    BC#1: n1A-n77A n1 n77 
    ...    FSEI#1: DL MIMO layers 4L 4L 
    ...    DL ChBw (MHz) 20 80 
    ...    BC#2: n1A-n77(2A) n1 n77 N77 
    ...    FSEI#1: DL MIMO layers 4L 2L 2L 
    ...    DL ChBw (MHz) 20 80 80 
    ...    FSEI#2: DL MIMO layers 2L 4L 2L 
    ...    DL ChBw (MHz) 20 80 80 
    ...    BC#3: n1A-n77(3A) n1 n77 n77 n77 
    ...    FSEI#1: DL MIMO layers 2L 2L 2L 2L 
    ...    DL ChBw (MHz) 20 80 80 80 
    ...    BC#4: n1A-n3A-n77A n1 n3 n77 
    ...    FSEI#1: DL MIMO layers 4L 4L 2L 
    ...    DL ChBw (MHz) 20 20 80 
    ...    FSEI#2: DL MIMO layers 2L 2L 4L 
    ...    DL ChBw (MHz) 20 20 80 
    ...    BC#5: n1A-n3A-n77(2A) n1 n3 n77 n77 
    ...    FSEI#1: DL MIMO layers 4L 2L 2L 2L 
    ...    DL ChBw (MHz) 20 20 80 80 
    ...    FSEI#2: DL MIMO layers 2L 2L 4L 2L 
    ...    DL ChBw (MHz) 20 20 80 80 
    ...    BC#6: n3A-n77(2A) n3 n77 N77 
    ...    FSEI#1: DL MIMO layers 4L 2L 2L 
    ...    DL ChBw (MHz) 20 80 80 
    ...    FSEI#2: DL MIMO layers 2L 4L 2L 
    ...    DL ChBw (MHz) 20 80 80 
    ...    UE2 capability: 
    ...    BC#1: n1A-n77A n1 n77 
    ...    FSEI#1: DL MIMO layers 4L 4L 
    ...    DL ChBw (MHz) 20 80 
    ...    BC#2: n3A-n77(2A) n3 n77 N77 
    ...    FSEI#1: DL MIMO layers 4L 2L 2L 
    ...    DL ChBw (MHz) 20 80 80 
    ...    FSEI#2: DL MIMO layers 2L 4L 2L 
    ...    DL ChBw (MHz) 20 80 80  
    ...    BC#3: n1A-n77(3A) n1 n77 n77 n77 
    ...    FSEI#1: DL MIMO layers 2L 2L 2L 2L 
    ...    DL ChBw (MHz) 20 80 80 80 
    ...    BC#4: n1A-n3A-n77A n1 n3 n77 
    ...    FSEI#1: DL MIMO layers 4L 4L 2L 
    ...    DL ChBw (MHz) 20 20 80 
    ...    FSEI#2: DL MIMO layers 2L 2L 4L 
    ...    DL ChBw (MHz) 20 20 80 
    ...    BC#5: n1A-n3A-n77(2A) n1 n3 n77 n77 
    ...    FSEI#1: DL MIMO layers 4L 2L 2L 2L 
    ...    DL ChBw (MHz) 20 20 80 80 
    ...    FSEI#2: DL MIMO layers 2L 2L 4L 2L 
    ...    DL ChBw (MHz) 20 20 80 80 
    ...    BC#6: n1A-n77(2A) n1 n77 N77 
    ...    FSEI#1: DL MIMO layers 4L 2L 2L 
    ...    DL ChBw (MHz) 20 80 80 
    ...    FSEI#2: DL MIMO layers 2L 4L 2L 
    ...    DL ChBw (MHz) 20 80 80 
    ...    3. Test Case Steps:
    ...    a. attach UE1 to cell1 and try to add scell blindly. Start DL/UL traffic.
    ...    b. attach UE2 to cell1 and try to add scell blindly. Start DL/UL traffic.
    ...    4. Expectation:
    ...    a. cell3 is added as scell successfully.Cell1 in band n77, cell3 in n77. BC#2FSEI#2 is selected.
    ...    b. cell3 is added as scell successfully.Cell1 in band n77, cell3 in n77. BC#2FSEI#2 is selected.
    [Tags]    QC_320584    jia.pan    AA24    CA_LABEL-TT(80MHZ_TDD_n77(n78)+80MHZ_TDD_n77(n78)))
    OnlineParamChange    ${online_modify_for_AA24}
    Clear Counter Files
    AA24_UE1_register_and_send_traffic
    AA24_UE2_register_and_send_traffic
    Check counters    pm_counters_expression=${PM_Counters_Check_AA24}
    Check Wireshark Log    ${CURDIR}${/}A2A_AA24${/}a2a.ini    wait_string=UEContextReleaseComplete::8
    [Teardown]    AA24_Teardown

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/8cells_4T4F_2N2_2N66_3N78_N38    ue_count=15

Trigger blind ScellAdd
    [Arguments]    ${ue_id}=81    ${cell_id}=1    ${pass_CA}=${EMPTY}
    Ue register and pdu session setup    ${pass_CA}    ue_id=${ue_id}    cell_id=${cell_id}
    Send Throughput    ue_id=${ue_id}
    Verify Throuput on Pscell and Scell    ue_id=${ue_id}
    UE Deregister From gNB    ue_id=${ue_id}

Trigger A1 ScellAdd succ
    [Arguments]    ${OnlineParam}=${EMPTY}    ${ue_id}=81    ${cell_id}=1    ${event_type}=A1    ${carrierfreq}=632736
    ...    ${srsrp_nr}=100    ${srsrq_nr}=50    ${pass_CA}=${EMPTY}
    OnlineParamChange    ${OnlineParam}
    Ue register and pdu session setup    QoS Routing Table    ue_id=${ue_id}    cell_id=${cell_id}
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type}
    ...    srsrp_nr=${srsrp_nr} srsrq_nr=${srsrq_nr}
    Execute Egate Command    ${cmd}    pass_regexp=${pass_CA}
    Send Throughput    ue_id=${ue_id}
    Verify Throuput on Pscell and Scell    ue_id=${ue_id}
    UE Deregister From gNB    ue_id=${ue_id}

AA06_Teardown
    OnlineParamChange    ${OnlineParam_AA06_2}
    Common Test Teardown And Stop Capture Logs

AA24_Teardown
    OnlineParamChange    ${online_recovery_for_AA24}
    Common Test Teardown And Stop Capture Logs

AA24_UE1_register_and_send_traffic
    Update UE capa    ${N1_N77_and_N1_N77_N77_and_N1_N77_N77_N77_and_N1_N3_N77_and_N1_N3_N77_N77_and_N3_N77_N77}    ue_id=81
    Ue register and pdu session setup without UEcapability    ${N77_N77_CA_succ}    ue_id=81    cell_id=1
    Send Throughput    ue_id=81    times=10
    Verify Throuput on Pscell and Scell for AA24
    Release Ues    ue_type=all
	
AA24_UE2_register_and_send_traffic
    Update UE capa    ${N1_N77_and_N3_N77_N77_and_N1_N77_N77_N77_and_N1_N3_N77_and_N1_N3_N77_N77_and_N1_N77_N77}    ue_id=82
    Ue register and pdu session setup without UEcapability    ${N77_N77_CA_succ}    ue_id=82    cell_id=1
    Send Throughput    ue_id=82    times=10
    Verify Throuput on Pscell and Scell for AA24    ue_id=82
    Release Ues    ue_type=all

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    wait until keyword succeeds    10 min    60 sec    Cells Should Be OnAir

Update UE capa
    [Arguments]    ${SA_Capa_perUE_Full}=none    ${ue_id}=81
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full}
    Execute Egate Command    ${cmd}

Ue register and pdu session setup
    [Arguments]    ${pduModifyCheck}    ${ue_id}=1    ${cell_id}=2
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=UE now in NG RM Registere
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=1    pass_regexp=${pduModifyCheck}

Ue register and pdu session setup without UEcapability
    [Arguments]    ${pduModifyCheck}    ${ue_id}=1    ${cell_id}=2
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=UE now in NG RM Registere
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=1    pass_regexp=${pduModifyCheck}

Send Throughput
    [Arguments]    ${ue_id}=81    ${times}=8    ${mbps}=175
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=ul mbps=10 trf_id=1    UE ${ue_id}: UDP UL
    FOR    ${I}    IN RANGE    1    ${times}
        Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=${mbps} trf_id=${I}    UE ${ue_id}: UDP DL
    END

Verify Throuput on Pscell and Scell
    [Arguments]    ${ue_id}=81    ${pcell_dl}=540    ${scell1_dl}=540    ${ul}=8    ${scell_id}=1    ${sleep_time}=10s
    sleep    ${sleep_time}
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000 > ${pcell_dl}
    ${scell1_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${scell_id}    type=pdsch    rate_type=ave
    Should Be True    ${scell1_tput}/1000 > ${scell1_dl}
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul}
	
Verify Throuput on Pscell and Scell for AA24
    [Arguments]    ${ue_id}=81    ${dl}=1400    ${ul}=8    ${scell_id}=1    ${sleep_time}=10s
    sleep    ${sleep_time}
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    ${scell1_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${scell_id}    type=pdsch    rate_type=ave
    Should Be True    ${scell1_tput}/1000+${scell0_tput}/1000 > ${dl}
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul}

UE Deregister From gNB
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s
