*** Settings ***
Documentation
...    author: Chen Dandan
...    contact: dandan.chen@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_VRF    SBTS00    RAN_5G    CLOUD_5G_I_BOO_AP_LOO    team-CN1ET
...    owner-yige.g.zhang    release-SBTS24R3    CRT
...    STATE_CONFIGURED
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_IPHY_XML}    fddFrequencyRange=FR1_WB
${NOKIA_XNAP_PLUGIN_FLAG}    ${True}
${NOKIA_F1AP_PLUGIN_FLAG}    ${True}
${SYSCOM_FLAG}    ${True}
#${TTITRACE_FLAG}    ${True}
#${AP_BIP_FLAG}    ${True}
#${GNB_BIP_FLAG}    ${True}
${AP_UDPLOG_LEVEL}    4
${DEBUG_LOG_LEVEL}    4

@{PARAMS_IN_SCF}
...    @{PARAMS_FOR_8224}
...    @{Xn_link}
...    @{PARAMS_FOR_CA}
...    @{large_fdd_cell}
...    @{CB007552_CB008541}
...    NRCELL:actSib1ForNsaCell=true
...    MRBTS-1/NRBTS-1/NRSCTP-1:sctpProfile:sctpWaitTimeInitSeqRetry=30
...    @{CB007103_legacy}
...    @{BeamForming}
...    @{MFBI}
...    @{CB008236_11118}
...    NRCELL-1:puschMappingType=TypeA
...    NRCELL-2:puschMappingType=TypeA

@{CB008236_11118}
...    NRBTS:mcc=310
...    NRBTS:mnc=260
...    NRBTS:mncLength=3
...    NRPLMN-1:mcc=310
...    NRPLMN-1:mnc=260
...    NRPLMN-1:mncLength=3

@{B004_online}
#...    NRCELL-1:actRel16DmrsForPusch=false
#...    NRCELL-2:actRel16DmrsForPusch=false
...    NRCELL-1:actRel16DmrsForPucchF3=true
...    NRCELL-1:pucchF3Rel16Pi2BpskAlwaysOn=false
...    NRCELL-1:pucchF3ModulationScheme=qpsk_4psk
...    NRCELL-1:pucchF3MaxCodeRate=zeroDot45
...    NRCELL-2:actRel16DmrsForPucchF3=true
...    NRCELL-2:pucchF3Rel16Pi2BpskAlwaysOn=false
...    NRCELL-2:pucchF3ModulationScheme=qpsk_4psk
...    NRCELL-2:pucchF3MaxCodeRate=zeroDot45

@{B004_online_recover}
#...    NRCELL-1:actRel16DmrsForPusch=true
#...    NRCELL-2:actRel16DmrsForPusch=true
...    NRCELL-1:actRel16DmrsForPucchF3=false
#...    NRCELL-1:pucchF3Rel16Pi2BpskAlwaysOn=false
#...    NRCELL-1:pucchF3ModulationScheme=qpsk_4psk
#...    NRCELL-1:pucchF3MaxCodeRate=zeroDot15
...    NRCELL-2:actRel16DmrsForPucchF3=false
#...    NRCELL-2:pucchF3Rel16Pi2BpskAlwaysOn=false
#...    NRCELL-2:pucchF3ModulationScheme=qpsk_4psk
#...    NRCELL-2:pucchF3MaxCodeRate=zeroDot15

@{BeamForming}
...    NRCELL-2:actBeamforming=true
...    NRCELL-2:numberOfRxBeamforming=4Rx
...    NRBTS-1:actFdmEnhancedScheduling=true
...    NRCELLGRP-4:numberOfTransmittedSsBlocks=4 beams
...    NRCELL-2:beamSet:basicBeamSet=beamSet_4
...    NRCELL-2:type0SearchSpaceConfigurationIndex=5

@{MFBI}
...    NRBTS:actMfbiNrCaSupportFr1=true
...    NRBTS:actMfbiNrCaMeasConfResolv=false
...    NRBTS:actMultiFrequencyBandIndicatorNRSupport=true
...    NRCELL-2:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-3
...    NRCELL-2:nrSysInfoProfileDN=MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-3
...    NRSYSINFO_PROFILE-3/NRIAFIM-1:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-3
...    NRSYSINFO_PROFILE-3/NRIRFIM-1:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-3
...    NRBTS/NRMULTIBANDINFO_PROFILE-3:nrMultibandInfoList:nrBandPriority=0|freqBandIndicatorNR=78
...    NRBTS/NRMULTIBANDINFO_PROFILE-3:nrMultibandInfoList:nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1|freqBandIndicatorNR=78
...    NRBTS/NRMULTIBANDINFO_PROFILE-3:nrMultibandInfoList:nrBandPriority=1|freqBandIndicatorNR=77
...    NRBTS/NRMULTIBANDINFO_PROFILE-3:nrMultibandInfoList:nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1|freqBandIndicatorNR=77
...    NRBTS/NRNSPMAX_PROFILE-1:nrNsPmaxList:additionalSpectrumEmission=1
...    NRBTS/NRNSPMAX_PROFILE-1:nrNsPmaxList:nrNsPmaxPriority=1

...    NRCELL-2:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-1
...    NRBTS/NRCONNECTMODE_PROFILE-1:multiFreqBandIndicatorNR=77


...    NRSYSINFO_PROFILE-3/NRIRFIM-1:dlCarrierFreq=518598
...    NRSYSINFO_PROFILE-3/NRIRFIM-1:freqBandIndicatorNR=41
...    NRSYSINFO_PROFILE-3/NRIRFIM-1:numberOfTransmittedSsBlocks=4 beams
...    NRSYSINFO_PROFILE-3/NRIRFIM-1:qOffsetFreq=-4dB
...    NRSYSINFO_PROFILE-3/NRIRFIM-1:qRxLevMin=-56
...    NRSYSINFO_PROFILE-3/NRIRFIM-1:ssbScs=30 KHz
...    NRSYSINFO_PROFILE-3/NRIRFIM-1:threshXHighQ=22
...    NRSYSINFO_PROFILE-3/NRIRFIM-1:threshXLowQ=22
#...    NRSYSINFO_PROFILE-3:systemInformationTargetRate=0

...    NRSYSINFO_PROFILE-3:addHystSfHigh=dB-6
...    NRSYSINFO_PROFILE-3:addHystSfMedium=dB-4
...    NRSYSINFO_PROFILE-3:combRelaxedMeasCond=false
...    NRSYSINFO_PROFILE-3:highPrioMeasRelax=false
...    NRSYSINFO_PROFILE-3:nCellChangeHigh=2
...    NRSYSINFO_PROFILE-3:nCellChangeMedium=1
...    NRSYSINFO_PROFILE-3:qHyst=dB0
...    NRSYSINFO_PROFILE-3:siWindowLength=s40
...    NRSYSINFO_PROFILE-3:systemInformationTargetRate=0
...    NRSYSINFO_PROFILE-3:tEvaluation=s30
...    NRSYSINFO_PROFILE-3:tHystNormal=s30
...    NRSYSINFO_PROFILE-3:tReselectionEutra=0
...    NRSYSINFO_PROFILE-3:threshServingLowP=0
...    NRSYSINFO_PROFILE-3:threshServingLowQ=0
...    NRSYSINFO_PROFILE-3:sibSchedulingList:sibBroadcastStatus=broadcasting|sibType=sibType2
...    NRSYSINFO_PROFILE-3:sibSchedulingList:sibPeriodicity=rf8|sibType=sibType2
...    NRSYSINFO_PROFILE-3:sibSchedulingList:sibScope=cellSpecific|sibType=sibType2
...    NRSYSINFO_PROFILE-3:sibSchedulingList:sibBroadcastStatus=broadcasting|sibType=sibType3
...    NRSYSINFO_PROFILE-3:sibSchedulingList:sibPeriodicity=rf8|sibType=sibType3
...    NRSYSINFO_PROFILE-3:sibSchedulingList:sibScope=cellSpecific|sibType=sibType3

...    NRSYSINFO_PROFILE-3:sibSchedulingList:sibBroadcastStatus=broadcasting|sibType=sibType4
...    NRSYSINFO_PROFILE-3:sibSchedulingList:sibPeriodicity=rf8|sibType=sibType4
...    NRSYSINFO_PROFILE-3:sibSchedulingList:sibScope=cellSpecific|sibType=sibType4

...    NRSYSINFO_PROFILE-3:sibSchedulingList:sibBroadcastStatus=broadcasting|sibType=sibType5
...    NRSYSINFO_PROFILE-3:sibSchedulingList:sibPeriodicity=rf8|sibType=sibType5
...    NRSYSINFO_PROFILE-3:sibSchedulingList:sibScope=cellSpecific|sibType=sibType5

...    NRSYSINFO_PROFILE-3:sibSchedulingList:sibBroadcastStatus=broadcasting|sibType=sibType8
...    NRSYSINFO_PROFILE-3:sibSchedulingList:sibPeriodicity=rf8|sibType=sibType8
...    NRSYSINFO_PROFILE-3:sibSchedulingList:sibScope=cellSpecific|sibType=sibType8


@{5GC000732_8225_Base}
#732
...    NRBTS-1:rrcReestabTypeSA=sameGNB
...    MRBTS-1/NRBTS-1:tWaitingRlRecoverSA=4000ms
#8225
...    NRBTS:actRrcInactState=intra-gNB
...    NRCELL:ranAC=0
...    NRBTS:actPaging=true
...    NRBTS:act3gppBL23R1=true
...    NRBTS:drbRrcInactInactivityTimerSA=20     #Time period for the indication of the DRB inactivity in both DL and UL
#directions for RRC Inactive capable SA UEs.
...    NRBTS:maxUeRrcInactTime=360      #Maximum time for the UE in RRC Inactive state in the gNB.
...    NRBTS:srbInactivityTimerSA=20
...    NRBTS:rrcInactIMMSteeringEnabled=false
...    NRBTS:rrcInactLocationReportEnabled=false
...    NRBTS:rrcInactPreferredStateEnabled=false
...    NRBTS:outOfConnectedPreference=idle
...    NRBTS:timerReleasePreferenceProhibit=s3

...    NRBTS:actRrcReleasePreference=true
...    NRBTS:tRanPagingGuard=4
...    NRBTS:drxDefaultPaging=v128
...    NRBTS:timerRejectWait=8
...    NRBTS:drbInactivityTimerSA=600
...    NRBTS:t380=10min     #This parameter indicates the periodic RAN Area Update timer for the gNB.

@{CB007103_legacy}
...    NRCELL-1:actUlDftSOfdm=true
...    NRCELL-1:ulTransPrecodeCtl:ulTransPrecodeOffSinrThresh=150      #rdUlTransPrecodeOnSinrThreshR16DmrsOffset    0x580832     100->0db
...    NRCELL-1:ulTransPrecodeCtl:ulTransPrecodeOnSinrThresh=130      #rdUlTransPrecodeOffSinrThreshR16DmrsOffset     0x580833     100->0db
...    NRCELL-1:ulTransPrecodeCtl:ulTransPrecodePi2Bpsk=true
...    NRCELL-1:ulTransPrecodeCtl:ulTransPrePi2BpskPwrBoost=true
...    NRCELL-11:ulPowerControlCommon:p0NominalPusch=-96
...    NRCELL-12:ulPowerControlCommon:p0NominalPusch=-96
...    NRCELL-13:ulPowerControlCommon:p0NominalPusch=-96
...    NRCELL-14:ulPowerControlCommon:p0NominalPusch=-96
...    NRCELL-2:actUlDftSOfdm=true
...    NRCELL-2:ulTransPrecodeCtl:ulTransPrecodeOffSinrThresh=200
...    NRCELL-2:ulTransPrecodeCtl:ulTransPrecodeOnSinrThresh=150
...    NRCELL-2:ulTransPrecodeCtl:ulTransPrecodePi2Bpsk=true
...    NRCELL-2:ulTransPrecodeCtl:ulTransPrePi2BpskPwrBoost=true

@{CB007552_CB008541}
...    NRBTS:actMultipleDedicatedBWPs=true
...    NRCELL:actEnhMultipleDedicatedBWPs=true

...    NRBTS/BWP_PROFILE-16:bwpType=initial
...    NRBTS/BWP_PROFILE-16:locationAndBandwidthDl:cRbSizeDl=n133
...    NRBTS/BWP_PROFILE-16:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-16:locationAndBandwidthUl:cRbSizeUl=n133
...    NRBTS/BWP_PROFILE-16:locationAndBandwidthUl:cRbStartUl=crb0
...    NRBTS/BWP_PROFILE-16/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=1
...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=1
...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=1
...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=1
...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=2
...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=3
...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=3
...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=3

...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=3
...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=3
...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-38:bwpType=dedicated
...    NRBTS/BWP_PROFILE-38:locationAndBandwidthDl:cRbSizeDl=n216
...    NRBTS/BWP_PROFILE-38:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-38:locationAndBandwidthUl:cRbSizeUl=n216
...    NRBTS/BWP_PROFILE-38:locationAndBandwidthUl:cRbStartUl=crb0
...    NRBTS/BWP_PROFILE-38/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=4
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=4
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=4
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=4
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=5
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=6
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=6
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=6
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=6
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cceToRegMapping=nonInterleaved
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:coresetId=1
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cRbStart=0
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:duration=1
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:interleaverSize=none
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:regBundleSize=n6
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=120
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=0
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=0
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=0
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|coresetId=0
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=0
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=0
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=7|coresetId=0
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|coresetId=0
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=0
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|coresetId=1
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=1
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=1
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=1
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n5|coresetId=1
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=1
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=1
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=8|coresetId=1
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|coresetId=1
...    NRBTS/BWP_PROFILE-38/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=1
...    NRBTS/BWP_PROFILE-38/PDSCH-1:pdschRat0RbgConfig=config1
...    NRBTS/BWP_PROFILE-37:bwpType=dedicated
...    NRBTS/BWP_PROFILE-37:locationAndBandwidthDl:cRbSizeDl=n133
...    NRBTS/BWP_PROFILE-37:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-37:locationAndBandwidthUl:cRbSizeUl=n133
...    NRBTS/BWP_PROFILE-37:locationAndBandwidthUl:cRbStartUl=crb0
...    NRBTS/BWP_PROFILE-37/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=9
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=9
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=9
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=9
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=10
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=10
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=10
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=10
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=11
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=11
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=11
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=11
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cceToRegMapping=nonInterleaved
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:coresetId=4
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cRbStart=0
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:duration=1
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:interleaverSize=n3
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:regBundleSize=n2
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=120
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=0
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=0
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=0
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|coresetId=0
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=0
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=0
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=12|coresetId=0
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|coresetId=0
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=0
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|coresetId=4
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=4
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=4
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=4
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n5|coresetId=4
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=4
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=4
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=13|coresetId=4
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|coresetId=4
...    NRBTS/BWP_PROFILE-37/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=4
...    NRBTS/BWP_PROFILE-37/PDSCH-1:pdschRat0RbgConfig=config1
#n66    40Mhz ,25Mhz
...    NRCELL-13:cellBwpList:actPdcchCceFragmentControl=false|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-38
...    NRCELL-13:cellBwpList:pdcchResourcePreference=peakRate|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-38
...    NRCELL-13:cellBwpList:actPdcchCceFragmentControl=false|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-37
...    NRCELL-13:cellBwpList:pdcchResourcePreference=peakRate|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-37
...    NRCELL-13:cellBwpList:cellBwpId=0|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-16
...    NRCELL-13:cellBwpList:cellBwpId=1|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-38
...    NRCELL-13:cellBwpList:cellBwpId=2|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-37



...    NRBTS/BWP_PROFILE-14:bwpType=initial
...    NRBTS/BWP_PROFILE-14:locationAndBandwidthDl:cRbSizeDl=n79
...    NRBTS/BWP_PROFILE-14:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-14:locationAndBandwidthUl:cRbSizeUl=n79
...    NRBTS/BWP_PROFILE-14:locationAndBandwidthUl:cRbStartUl=crb0
...    NRBTS/BWP_PROFILE-14/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=1
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=1
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=1
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=1
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=2
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=3
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=3
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=3

...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=3
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=3
...    NRBTS/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-33:bwpType=dedicated
...    NRBTS/BWP_PROFILE-33:locationAndBandwidthDl:cRbSizeDl=n106
...    NRBTS/BWP_PROFILE-33:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-33:locationAndBandwidthUl:cRbSizeUl=n106
...    NRBTS/BWP_PROFILE-33:locationAndBandwidthUl:cRbStartUl=crb0
...    NRBTS/BWP_PROFILE-33/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=4
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=4
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=4
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=4
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=5
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=6
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=6
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=6
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=6
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cceToRegMapping=nonInterleaved
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:coresetId=1
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cRbStart=0
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:duration=1
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:interleaverSize=none
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:regBundleSize=n6
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=96
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=0
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=0
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=0
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n4|coresetId=0
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=0
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=0
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=7|coresetId=0
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|coresetId=0
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=0
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|coresetId=1
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=1
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=1
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=1
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n4|coresetId=1
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=1
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=1
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=8|coresetId=1
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|coresetId=1
...    NRBTS/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=1
...    NRBTS/BWP_PROFILE-33/PDSCH-1:pdschRat0RbgConfig=config1
...    NRBTS/BWP_PROFILE-32:bwpType=dedicated
...    NRBTS/BWP_PROFILE-32:locationAndBandwidthDl:cRbSizeDl=n79
...    NRBTS/BWP_PROFILE-32:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-32:locationAndBandwidthUl:cRbSizeUl=n79
...    NRBTS/BWP_PROFILE-32:locationAndBandwidthUl:cRbStartUl=crb0
...    NRBTS/BWP_PROFILE-32/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=9
...    NRBTS/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=9
...    NRBTS/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=9
...    NRBTS/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=9
...    NRBTS/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=10
...    NRBTS/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=10
...    NRBTS/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=10
...    NRBTS/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=10
...    NRBTS/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=11
...    NRBTS/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=11
...    NRBTS/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=11
...    NRBTS/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=11
...    NRBTS/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cceToRegMapping=nonInterleaved
...    NRBTS/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:coresetId=4
...    NRBTS/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cRbStart=0
...    NRBTS/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:duration=1
...    NRBTS/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:interleaverSize=none
...    NRBTS/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:regBundleSize=n6
...    NRBTS/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=78
...    NRBTS/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=0
...    NRBTS/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=0
...    NRBTS/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=0
...    NRBTS/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|coresetId=0
...    NRBTS/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=0
...    NRBTS/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=0
...    NRBTS/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=12|coresetId=0
...    NRBTS/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|coresetId=0
...    NRBTS/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=0
...    NRBTS/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|coresetId=4
...    NRBTS/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=4
...    NRBTS/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=4
...    NRBTS/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=4
...    NRBTS/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n3|coresetId=4
...    NRBTS/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=4
...    NRBTS/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=4
...    NRBTS/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=13|coresetId=4
...    NRBTS/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|coresetId=4
...    NRBTS/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=4
...    NRBTS/BWP_PROFILE-32/PDSCH-1:pdschRat0RbgConfig=config1

#n71    20Mhz,15Mhz
...    NRCELL-12:cellBwpList:actPdcchCceFragmentControl=false|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-14
...    NRCELL-12:cellBwpList:pdcchResourcePreference=peakRate|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-14
...    NRCELL-12:cellBwpList:actPdcchCceFragmentControl=false|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-33
...    NRCELL-12:cellBwpList:pdcchResourcePreference=peakRate|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-33
...    NRCELL-12:cellBwpList:actPdcchCceFragmentControl=false|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-32
...    NRCELL-12:cellBwpList:pdcchResourcePreference=peakRate|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-32
...    NRCELL-12:cellBwpList:cellBwpId=0|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-14
...    NRCELL-12:cellBwpList:cellBwpId=1|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-33
...    NRCELL-12:cellBwpList:cellBwpId=2|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-32

@{large_fdd_cell}
#n66    25M
...    NRCELL-11/NRCELL_FDD-1:nrarfcnDl=430900
...    NRCELL-11/NRCELL_FDD-1:nrarfcnUl=348920
...    NRCELL-11/NRCELL_FDD-1:chBwDl=25MHz
...    NRCELL-11:gscnOrSsPbchArfcn=5384
#n66    40Mhz ,25Mhz
...    NRCELL-13/NRCELL_FDD-1:nrarfcnDl=430900
...    NRCELL-13/NRCELL_FDD-1:nrarfcnUl=348920
...    NRCELL-13/NRCELL_FDD-1:chBwDl=40MHz
...    NRCELL-13:gscnOrSsPbchArfcn=5384
#n71    20Mhz,15Mhz
...    NRCELL-12/NRCELL_FDD-1:nrarfcnDl=126900
...    NRCELL-12/NRCELL_FDD-1:nrarfcnUl=136100
...    NRCELL-12/NRCELL_FDD-1:chBwDl=20MHz
...    NRCELL-12:gscnOrSsPbchArfcn=1584
#n71    15Mhz
...    NRCELL-14/NRCELL_FDD-1:nrarfcnDl=126900
...    NRCELL-14/NRCELL_FDD-1:nrarfcnUl=136100
...    NRCELL-14/NRCELL_FDD-1:chBwDl=15MHz
...    NRCELL-14:gscnOrSsPbchArfcn=1584

@{PARAMS_FOR_8224}
#...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-2
#...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-4
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-2
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-3
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-13/CHANNELGROUP-1/CHANNEL-2
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-13/CHANNELGROUP-1/CHANNEL-4
#...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-14/CHANNELGROUP-1/CHANNEL-2
#...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-14/CHANNELGROUP-1/CHANNEL-4

#...    NRCELL-11:nrCellType=2DL0UL
#...    NRCELL-11:cellBarred=barred
#...    NRCELL-11:intraFreqReselection=notAllowed
#...    MRBTS-1/NRBTS-1/NRCELL-11/NRCELL_FDD-1:chBwUl=0MHz
#RMOD-4
...    NRCELL-11:nrCellType=4DL0UL
...    NRCELL-11:cellBarred=barred
...    NRCELL-11:intraFreqReselection=notAllowed
...    MRBTS-1/NRBTS-1/NRCELL-11/NRCELL_FDD-1:chBwUl=0MHz
...    NRCELL-11:dlMimoMode=4x4 or 4x2 Open Loop Spatial Multiplexing

...    MRBTS/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-2:direction=TX
...    MRBTS/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-2:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/ANTL-2
...    MRBTS/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-3:direction=TX
...    MRBTS/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-3:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/ANTL-3
...    MRBTS/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-4:direction=TX
...    MRBTS/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-4:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/ANTL-4

...    NRCELL-12:nrCellType=2DL0UL
...    NRCELL-12:cellBarred=barred
...    NRCELL-12:intraFreqReselection=notAllowed
...    MRBTS-1/NRBTS-1/NRCELL-12/NRCELL_FDD-1:chBwUl=0MHz

...    NRCELL-13:nrCellType=2DL0UL
...    NRCELL-13:cellBarred=barred
...    NRCELL-13:intraFreqReselection=notAllowed
...    MRBTS-1/NRBTS-1/NRCELL-13/NRCELL_FDD-1:chBwUl=0MHz
#...    NRCELL-14:nrCellType=2DL0UL
#...    NRCELL-14:cellBarred=barred
#...    NRCELL-14:intraFreqReselection=notAllowed
#...    MRBTS-1/NRBTS-1/NRCELL-14/NRCELL_FDD-1:chBwUl=0MHz

...    NRCELL-11:administrativeState=Locked     #Sunil will provide the IMprovment
...    NRCELL-12:administrativeState=Locked
...    NRCELL-13:administrativeState=Locked

@{OnlineParam_8224_WA}
...    NRCELL-11:administrativeState=Unlocked
...    NRCELL-12:administrativeState=Unlocked
...    NRCELL-13:administrativeState=Unlocked

@{PARAMS_FOR_CA}
...    NRBTS:caConfigurationSupport=4CCDL_2CCUL
...    NRBTS-1:actCarrierAggregation=true
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRDU-1:carrierAggregationSupportList=ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Sa,ca_Fdd_Any_Sa,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Fdd
...    NRBTS/NRDRB_RLC_AM-1:ulTReassemblyIBCA=40
...    NRBTS/NRDRB_RLC_AM-2:ulTReassemblyIBCA=40
...    NRBTS:maxNumScellsDl=4
...    NRBTS:maxNumScellsUl=1
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRCELL:actK1Opt=intraAndInter-gNB
...    NRCELL:timingAdvanceOffset=n25600

@{Xn_link}
...    NRBTS/XNLINK-1:cPlaneIpAddr=10.0.1.122
...    NRBTS/XNLINK-1:cPlaneIpAddrCtrl=oamControlled
...    NRBTS:actIncXn=true

@{Attachment_pass}
...    maxCodeRate zeroDot45
...    rrcReconfigurationComplete

@{RRE_pass}
...    NR RRC Reestablishment sucessfully completed
...    maxCodeRate zeroDot45
...    pi2BPSK enabled
...    dmrs-UplinkTransformPrecodingPUCCH-r16 enabled
...    transformPrecoder enabled
...    tp-pi2BPSK enabled
...    powerBoostPi2BPSK TRUE
...    rrcReconfigurationComplete

@{INACTIVE_check}
...    SuspendConfig
...    fullI_RNTI
...    shortI_RNTI
...    nextHopChainingCount
...    t380
...    NR_RRC_INACTIVE

@{Resume_Check}
...    resumeCause mt-Access
...    rrcResumeComplete

${UE_Capa_N77}    SEPARATOR=
...    E9A09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C4701FB8D85181AC1184341020E906C036B64C558D0E7C471E819F60
...    4F8C48E3C873EA39F30C7942C0E070F0060001809C00FFC007003FF0005E0000E000A0541B107582308682041E20D00656C98AB121CFB027C471E31238F21C
...    FA8E7CC31E50B0381C3C27FFC00001FFF00000170000381546C4DD608C21A0810748340165B262A86873E238F40CFB027C639F30C7942C0E070F04E007C000
...    3801F00002E0000702A0D831AC1184341020F941A00CAD931562439F11C7B027C62471E439F51CF9863CA1607038784FFF800003FFE000002E0000702B8D84
...    BAC1184341020E9068036B64C558D0E7C471E819F604F8C48E3C873EA39F30C7942C0E070F05C00FFC007003FF0005C0000E0551B133582308682041D20D80
...    596C98AA1A1CF88E3D033EC09F18E7CC31E50B0381C3C00C0003013801FF800E007FE000BD0001C0014006CA0000A00000A836236B04610D04083E5068032B
...    64C55890E7C471EC09F1891C790E7D473E618F28581C0E1E13FFE00000FFF800000B80001C0A83600EB04610D04083E5068032B64C55890E7C471EC09F1891
...    C790E7D473E618F28581C0E1E13FFE00000FFF800000B80001C011787882001C46000000160205E1E1280071340000085808178B850001C41000E230000020
...    B0102F17060003882001C4D000006160205E1E14000713400002058081707850001C4100000A160205E1E20800711800003058081787882001C4D00000E160
...    205E2E1400071040038820000202C040BC5C28000E2300071180000485808178B882001C41000E2300000A0B0102F1710400388C001C46000016160205E1E2
...    300071340000605808178F830001C41000E2300071300000685808178F882001C4C000E2600071300000705808178B882001C4D000E2680000F0B0102F1F10
...    4003882001C4D000E268000100B01020120234028809B01060260BA006D84614489B1CF870A244D8E7C38912244D8E7C38912244D8E7C3851226C73E1C2891
...    3639F0E14489B1CF870A244D8E7C38912244D8E7C38912244D8E7C38912244D8E7C38912244D8E7C3851226C73E1C68912244D8E7C38D1224489B1CF871224
...    489B1CF871A2448913639F0C00C888C6318C6318C6318C6318CF417001E00140E0A00E0601280380030120020301F020010000000080000100400001002000
...    00C01000008008000050040000300200001C01000010043032B282B262B236B066B062B036B2A6B27680E0800004B29282000032CA4A0800014B2928200007
...    2CA4A0800024B292820000B2CA4A0800034B292820000F2CA4A03A81D552AAAA515548F2A8365506AAA07954AB285801200340A00100808010020200400840
...    40200401004008402008010080100202004008804028050100E01C040400808080300602008010404010020100200420201002008010021010020040401002
...    1008020040200400808010022010040080400801010020044020040080801002020040088040080101002004040080108080100202008010C0C0300680500A
...    0600400C0080103002006004008180801100400860600400C038010301000A008010180300701200C0C0180380900620100E00404048030101200C60201C00
...    808070020202401808090063543E00020406080C0E1416181A2022242628303236383A3E424A4C4E5052545A5E828305A0

${ACC_UE_CONF_R16_DMRS_PUCCH_F3}    M55165C00037
#Accumulated number of UEs configured with Rel16 DMRS for PUCCH format 3
${DEN_1_SEC_UE_SAMPLE}    M55165C00038
#This counter provides the denominator for the calculation of the average number of UEs.
${PUCCH_F3_NON_DTX_R16_DMRS}    M55370C00033
#This counter provides the sum of physical uplink control channel (PUCCH) non-DTX detections for PUCCH format 3 with Rel16 DMRS
#over the measurement period.
${PUCCH_F3_DTX_R16_DMRS}    M55370C00037
#This counter provides the sum of physical uplink control channel (PUCCH) DTX detections for PUCCH format 3 with Rel16 DMRS
#over the measurement period.
${PUCCH_FORMAT3_NON_DTX}    M55303C18001
#This counter shall provide the number of PUCCH non-DTX detections for PUCCH format 3.
${PUCCH_FORMAT3_DTX}    M55303C17001
#This counter shall provide the number of PUCCH DTX detections for PUCCH format 3.
#Note: DTX during the transient phase for SA initial access, handover cases, RRC Re-establishment and RRC Reconfiguration are counted.

@{PM_Counters_B004}
...    NRCELL-1:${ACC_UE_CONF_R16_DMRS_PUCCH_F3}>=0
...    NRCELL-1:${DEN_1_SEC_UE_SAMPLE}>=0
...    NRCELL-1:${PUCCH_F3_NON_DTX_R16_DMRS}>=0
...    NRCELL-1:${PUCCH_F3_DTX_R16_DMRS}>=0
...    NRCELL-1:${PUCCH_FORMAT3_NON_DTX}>=0
...    NRCELL-1:${PUCCH_FORMAT3_DTX}>=0

...    NRCELL-2:${ACC_UE_CONF_R16_DMRS_PUCCH_F3}>=0
...    NRCELL-2:${DEN_1_SEC_UE_SAMPLE}>=0
...    NRCELL-2:${PUCCH_F3_NON_DTX_R16_DMRS}>=0
...    NRCELL-2:${PUCCH_F3_DTX_R16_DMRS}>=0
...    NRCELL-2:${PUCCH_FORMAT3_NON_DTX}>=0
...    NRCELL-2:${PUCCH_FORMAT3_DTX}>=0
@{ue_list}
...    1
...    2
...    3
...    4
...    5

${UE_Cap_N77_file}  /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_L3_SW_CN_HZ/trunk_sbts/CRT/CN1/CB007103/ue_capability_B004/ue_cap_B004.cfg

*** Test Cases ***
CB007103-ET-B004_R16_DMRS_For_PUCCH_FT3_NOT_Always_On_And_QPSK_Reconfigure_R16_DMRS_PowerBoost_And_HalfpiBPSK_NSA_SA_CB008225_5GC000732_On_Other_Cell
    [Documentation]
    ...    1. Switching from DMRS Rel15 to DMRS Rel16 for PUCCH F3 due to Transform Precoding enabling by RRC procedure due to radio conditions in
    ...       the case when QPSK is configured in NIDD for PUCCH F3 and pi/2-BPSK and Rel16 DMRS is not always switched on for PUCCH F3 by NIDD
    ...       parameter
    ...    2. Configuration
    ...         gNBs host following cells:
    ...                                 Cell-1    Cell-2    Cell-11    Cell-12    Cell-13    Cell-14
    ...    Technology                    TDD      TDD       FDD SDL     FDD SDL    FDD SDL     FDD
    ...          Band                    n41      n78       n66         n71         n66        n71
    ...           Pci                     50       51       60          61          62         63
    ...     Bandwidth                     60       50       25          20,15       40,25      15
    ...        Arfcn<DL/UL>         518580    633372    430900/348920     126900/136100     430900/348920     126900/136100
    ...        nrCellType               4DL4UL    4DL4UL    2DL0UL      2DL0UL      2DL0UL    2DL2UL
    ...    NRCELL:actSib1ForNsaCell=true
    ...    3. Test Case Steps:
    ...           a. unlock SDL NRCELL-11,12,13, disable feature 7103-A PUSCH R16 DMRS enable feature 7103-B PUCCH F3 R16 DMRS,
    ...              enable feature 732 and 8225
    ...           b. UE1 attach to NRCELL-2 < beamforming enabled >.
    ...           c. Adjust UL pathloss, to enable UL transform precoding.
    ...           d. Adjust UL pathloss to trigger PUCCH F3 DMRS R15 switch to DMRS R16 for PUCCH.
    ...           e. Adjust UL pathloss to trigger PUCCH F3 DMRS R16 switch to DMRS R15 for PUCCH.
    ...           f. trigger UE1 RRC Reestablish to NRCELL-2
    ...           g. stop UE1 traffic to trigger UE inactive state.
    ...           h. trigger RRC resume,
    ...           i. Ajust UL pathloss, disable UL transform precoding.
    ...           j. repeat step b to step i for UE2,3,4,5
    ...    4. Expected Results:
    ...           a. All CELLs on air. bi-directional cells scheduling mib and sibs.SDL cells scheduling only mib.
    ...           b. UE1 attached, dmrs-UplinkTransformPrecodingPUCCH-r16 not enabled.
    ...           c. UL transform precoding enabled.dmrs-UplinkTransformPrecodingPUCCH-r16 enabled
    ...           d. UE1 PUCCH F3 DMRS switched to R16
    ...           e. UE1 PUCCH F3 DMRS switched to R15
    ...           f. Reestablish succeeded, and transformPrecoder enabled ,dmrs-UplinkTransformPrecodingPUCCH-r16 enabled.
    ...           g. UE in Inactive state.
    ...           h. RRC resume succeeded, and transformPrecoder enabled ,dmrs-UplinkTransformPrecodingPUCCH-r16 enabled.
    ...           i. UL transform precoding disabled, and dmrs-UplinkTransformPrecodingPUCCH-r16 deconfigured.
    ...           j. same with b to i.
    ...    5. knowlegde info <in bip LOG>:
    ...         sinr     34,35 ---> MCS 28      pathloss=80
    ...         sinr     16,18 db ---> MCS 23,24     pathloss=100
    ...         sinr     5,6,7,8db ---> MCS 11,12    pathloss=110
    ...         sinr     -0.xxx -1.xxx db ---> MCS 0,1,2    pathloss=120
    ...         TP switch according to rrmAvgSinrTpSwitch value in TTI trace even ulFdSchedData
    [Tags]    B004    QC_46959
    OnlineParamChange    ${OnlineParam_8224_WA}
    OnlineParamChange    ${B004_online}
    OnlineParamChange    ${5GC000732_8225_Base}
    Clear Counter Files
    UEs Attach and RRE and RRC Resume
    Check Counters    ${PM_Counters_B004}
    OnlineParamChange    ${B004_online_recover}

*** Keywords ***
UEs Attach and RRE and RRC Resume
    FOR    ${index}    IN    @{ue_list}
        Update UE capa    ue_id=${index}    SA_Capa_perUE_Full=UE_Capa_N77
        Ue register and pdu session setup    ue_id=${index}    cell_id=2    pass_regexp=${Attachment_pass}
    #    Start To Capture GNB BIP Log    tag=gnb_bip_${index}
        Send Throughput    ue_id=${index}
        Check Traffic    ue_id=${index}
        Adjust Sinr Target Pathloss    ue_id=${index}    sinr_target_pathloss=114    profile_id=${index}
     #   Stop To Capture GNB BIP Log    tag=gnb_bip_${index}
     #   Start To Capture GNB BIP Log    tag=gnb_bip_1_${index}
        Tigger MCS0_1 For Pusch    sinr_target_pathloss=124    profile_id=${index}
        Check Traffic    ue_id=${index}
        Tigger High Than MCS0_1 For Pusch    sinr_target_pathloss=114
        Check Traffic    ue_id=${index}
        Trigger RRC Reestablish with cause    ue_id=${index}    cell_id=2    cause=reconfigurationFailure
        Send Throughput    ue_id=${index}
        Check Traffic    ue_id=${index}
        Stop traffic to make UEs into Inactive state    ue_id=${index}
        Trigger RRC Resume    ue_id=${index}    cell_id=2
        Send Throughput    ue_id=${index}
        Check Traffic    ue_id=${index}
        Sleep    15s
      #  Stop To Capture GNB BIP Log    tag=gnb_bip_1_${index}
        Deactive Pathloss    ue_id=${index}    profile_id=${index}
    END

Stop traffic to Inactive
    [Arguments]    ${ue_id}=1
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=1    pass_regexp=${INACTIVE_check}    timeout=600s

Stop traffic to make UEs into Inactive state
    [Arguments]    ${ue_id}=1
    Stop traffic to Inactive    ue_id=${ue_id}

Trigger RRC Resume
    [Arguments]    ${ue_id}=1    ${cell_id}=11
    sleep    2s    #sleep for inactive precedure complete
    Execute Egate Command    ue_nr_rrc_resume_request_param id=${ue_id} gnb=2 cell=${cell_id} cause=mt_Access
    Execute Egate Command    ue_nr_rrc_resume id=${ue_id}    pass_regexp=${Resume_Check}

Trigger RRC Reestablish with cause
    [Arguments]    ${cause}    ${cell_id}=1    ${ue_id}=1
    Execute Egate Command    ue_rrc_reestablish id=${ue_id} gnb=2 cell=${cell_id} cause=${cause}
    ...    pass_regexp=${RRE_pass}    timeout=20s

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be Onair    cell_id=1    check_sib=${True}    timeout=600
    Cells Should Be Onair    cell_id=2    check_sib=${True}    timeout=600
    Cells Should Be Onair    cell_id=11    check_sib=${False}    timeout=600
    Cells Should Be Onair    cell_id=12    check_sib=${False}    timeout=600
    Cells Should Be Onair    cell_id=13    check_sib=${False}    timeout=600
    Cells Should Be Onair    cell_id=14    check_sib=${True}    timeout=600

Tigger MCS0_1 For Pusch
    [Arguments]    ${sinr_target_pathloss}=120        ${profile_id}=1
    Execute Egate Command    ul_sinr_testmode_nr profile_id=${profile_id} pathloss=${sinr_target_pathloss}     #sinr -0.xxx -1.xxx db
    Sleep    5s             # for uplink signal stable

Tigger High Than MCS0_1 For Pusch
    [Arguments]    ${sinr_target_pathloss}=110
    Execute Egate Command    ul_sinr_testmode_nr profile_id=1 pathloss=${sinr_target_pathloss}      #sinr 5,6,7,8db
    Sleep    5s             # for uplink signal stable

Update UE capa
    [Arguments]    ${ue_id}    ${SA_Capa_perUE_Full}=none
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full} capability_file=${UE_Cap_N77_file}
    Execute Egate Command    ${cmd}
    sleep    3s    wait for ue_cap setting done

Send Throughput
    [Arguments]    ${ue_id}=1    ${pdu}=1
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=1 dir=dl mbps=170 trf_id=1    pass_regexp=Started Downlink
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=1 dir=ul mbps=170 trf_id=1    pass_regexp=Started Uplink
    sleep    15s    #Flow stability

Check Traffic
    [Arguments]    ${ue_id}=1    ${sleep_time}=15s    ${traffic}=10
    sleep    ${sleep_time}    sleep for Tput stable
    ${Pcell_Tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${Pcell_tput}/1000 > ${traffic}
    ${ul_throughput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pusch    rate_type=ave
    Should Be True    ${ul_throughput}/1000> 0

Ue register and pdu session setup
    [Arguments]    ${ue_id}=1    ${cell_id}=1    ${enb}=2    ${pass_regexp}=QoS Routing Table
    Execute Egate Command    amf_ue_pdu_setup_param id=1 reset
    Execute Egate Command    ue_change_location id=${ue_id} enb=${enb} cell=${cell_id}

    ${core_assis_info}    catenate    amf_ue_ics_param id=1 core_network_assistance_info=on ue_identity_index_value=${ue_id} ue_specific_drx=64
    ...    periodic_registration_update_timer=1:10min plmn_id=310:260 tac_id=200
    Execute Egate Command    ${core_assis_info}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=UE now in NG RM Registere
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=1    pass_regexp=${pass_regexp}

Adjust Sinr Target Pathloss
    [Arguments]    ${ue_id}=1    ${sinr_target_pathloss}=130    ${profile_id}=1
    Execute Egate Command    ul_sinr_testmode_nr profile_id=${profile_id} pathloss=${sinr_target_pathloss}    pass_regexp=CTRL_AP_GEN_TESTMODE_NR
    Execute Egate Command    ue_testmode_set_nr id=${ue_id} testmode=ul_sinr action=activate profile_id=${profile_id}
    ...    timeout=180

Deactive Pathloss
    [Arguments]    ${ue_id}=1    ${profile_id}=1
    Execute Egate Command    ue_testmode_set_nr id=${ue_id} testmode=ul_sinr action=deactivate profile_id=${profile_id}
  #  ...    pass_regexp=${pass_regexp}

Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_2T4F    ue_count=5
    Execute Cmd On PC    sudo ip addr add 10.0.1.102/24 dev eth3
    Execute Egate Command    trace_sim amf=1 on
    Execute Egate Command    sim_trace enb=3 protocol=xn on
    Execute Egate Command    sim_trace enb=1 protocol=x2 on

Modify Cfg
    ${Update_Cfg_Cell_11}    Catenate
    ...    set_cell id=11 gnb=2 pci=20:0 tac=200 nrci=0x0B tdd_cell=off proxy=$PROXY_SERVER_IP:9999|$PROXY_SERVER_IP:8888 nr_arfcn=348920:430900
    ...    gscn=5384 mandatory_for_activation=off is_fr1sdl_cell=on

    ${Update_Cfg_Cell_12}    Catenate
    ...    set_cell id=12 gnb=2 pci=20:1 tac=200 nrci=0x0C tdd_cell=off proxy=$PROXY_SERVER_IP:9999|$PROXY_SERVER_IP:8888 nr_arfcn=136100:126900
    ...    gscn=1584 mandatory_for_activation=off is_fr1sdl_cell=on

    ${Update_Cfg_Cell_13}    Catenate
    ...    set_cell id=13 gnb=2 pci=20:2 tac=200 nrci=0x0D tdd_cell=off proxy=$PROXY_SERVER_IP:9999|$PROXY_SERVER_IP:8888 nr_arfcn=348920:430900
    ...    gscn=5384 mandatory_for_activation=off is_fr1sdl_cell=on

    Update Cfg    ${Update_Cfg_Cell_11}
    Update Cfg    ${Update_Cfg_Cell_12}
    Update Cfg    ${Update_Cfg_Cell_13}
    update cfg param    set_enb id=1 plmn=310:260
    update cfg param    set_enb id=11 plmn=310:260
    update cfg param    mme_pool_area id=1 plmn=310:260
    update cfg param    set_amf_region id=1 plmn=310:260
    update cfg param    set_gnb id=2 plmn=310:260
    update cfg param    set_gnb id=3 plmn=310:260
    update cfg param    set_gnb id=4 plmn=310:260
    update cfg param    set_ue simulated id=1 suci=0:310:260:0000:0:0:021645400
    update cfg param    set_ue simulated id=2 suci=0:310:260:0000:0:0:021645401
    update cfg param    set_ue simulated id=3 suci=0:310:260:0000:0:0:021645402
    update cfg param    set_ue simulated id=4 suci=0:310:260:0000:0:0:021645403
    update cfg param    set_ue simulated id=5 suci=0:310:260:0000:0:0:021645404
    update cfg param    set_ue simulated id=81 suci=0:310:260:0000:0:0:021645481
    update cfg param    set_ue simulated id=82 suci=0:310:260:0000:0:0:021645482
    update cfg param    set_ue simulated id=83 suci=0:310:260:0000:0:0:021645483
    update cfg param    set_ue simulated id=84 suci=0:310:260:0000:0:0:021645484
    update cfg param    set_ue simulated id=85 suci=0:310:260:0000:0:0:021645485
    update cfg param    set_ue simulated id=86 suci=0:310:260:0000:0:0:021645486

    update cfg param    set_ue simulated id=11 imsi=310:260:21645411
    update cfg param    set_ue simulated id=91 imsi=310:260:21645491
    update cfg param    set_ue simulated id=92 imsi=310:260:21645492
    update cfg param    set_ue simulated id=93 imsi=310:260:21645493
    update cfg param    set_ue simulated id=94 imsi=310:260:21645494
    update cfg param    set_ue simulated id=95 imsi=310:260:21645495
    update cfg param    set_ue simulated id=96 imsi=310:260:21645496
