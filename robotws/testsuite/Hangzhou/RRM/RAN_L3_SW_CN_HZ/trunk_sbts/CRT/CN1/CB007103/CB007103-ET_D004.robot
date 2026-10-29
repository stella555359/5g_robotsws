*** Settings ***
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
${GNB_BIP_FLAG}    ${True}

@{PARAMS_IN_SCF}
...    @{PARAMS_FOR_8224}
...    @{PowerSaving}
...    @{Xn_link}
...    @{PARAMS_FOR_CA}
...    @{large_fdd_cell}
...    @{CB007552_CB008541}
...    NRCELL:actSib1ForNsaCell=true
...    MRBTS-1/NRBTS-1/NRSCTP-1:sctpProfile:sctpWaitTimeInitSeqRetry=30
...    @{CB007103_legacy}
...    @{CB008236_11118}
...    @{BeamForming}
...    @{MFBI}
...    @{CB007103_C}
#...    @{UN_PARAMS_FOR_8224}


@{PARAMS_FOR_CA}
...    NRBTS:caConfigurationSupport=4CCDL_2CCUL
...    NRBTS-1:actCarrierAggregation=true
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRDU-1:carrierAggregationSupportList=ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Sa,ca_Fdd_Any_Sa,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Fdd,ca_Fr1Tdd_Fdd_Sa_WithUl

...    NRBTS/NRDRB_RLC_AM-1:ulTReassemblyIBCA=40
...    NRBTS/NRDRB_RLC_AM-2:ulTReassemblyIBCA=40
...    NRBTS:maxNumScellsDl=4
...    NRBTS:maxNumScellsUl=1
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRCELL:actK1Opt=intraAndInter-gNB
...    NRCELL:timingAdvanceOffset=n25600
...    @{D006_online}

@{D006_online}
...    NRBTS/NRDU-1:dlToUlContributionRatio=50

...    NRCELL-1/NRREL-14:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-14:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-14:gNbId=1
...    NRCELL-1/NRREL-14:gNbIdLength=22
...    NRCELL-1/NRREL-14:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-14:lcrId=14
...    NRCELL-1/NRREL-14:removeNotAllowed=false
...    NRCELL-1/NRREL-14:gnbPlmn:mcc=310
...    NRCELL-1/NRREL-14:gnbPlmn:mnc=260
...    NRCELL-1/NRREL-14:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-14:sCellOperationalMode=dlAndUl
...    NRCELL-1/NRREL-14:sCellAdditionMethod=blind
# weightForSCellSelection
...    NRCELL-1/NRREL-11:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-11:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-11:gNbId=1
...    NRCELL-1/NRREL-11:gNbIdLength=22
...    NRCELL-1/NRREL-11:handoverAllowedSA=forbidden
...    NRCELL-1/NRREL-11:lcrId=11
...    NRCELL-1/NRREL-11:removeNotAllowed=false
...    NRCELL-1/NRREL-11:gnbPlmn:mcc=310
...    NRCELL-1/NRREL-11:gnbPlmn:mnc=260
...    NRCELL-1/NRREL-11:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-11:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-11:sCellAdditionMethod=blind

@{CB007103_C}
...    NRCELL-1:actRel16DmrsForPusch=true
...    NRCELL-1:actRel16DmrsForPucchF3=true
...    NRCELL-1:pucchF3Rel16Pi2BpskAlwaysOn=true
...    NRCELL-1:pucchF3ModulationScheme=qpsk_4psk
...    NRCELL-1:pucchF3MaxCodeRate=zeroDot25

...    NRCELL-2:actRel16DmrsForPusch=true
...    NRCELL-2:actRel16DmrsForPucchF3=true
...    NRCELL-2:pucchF3Rel16Pi2BpskAlwaysOn=true
...    NRCELL-2:pucchF3ModulationScheme=qpsk_4psk
...    NRCELL-2:pucchF3MaxCodeRate=zeroDot25

@{CB008236_11118}
...    NRBTS:mcc=310
...    NRBTS:mnc=260
...    NRBTS:mncLength=3
...    NRPLMN-1:mcc=310
...    NRPLMN-1:mnc=260
...    NRPLMN-1:mncLength=3
...    NRCELL-1:actUlSlotAgg=Enabled_VoNr
...    NRCELL-1:actDrxSleepOff=Enabled_VoNr_SAg
...    NRCELL-1:actEnhancedVoNR=true
...    NRCELL-1:actVoNR=true
...    NRCELL-1:maxHarqBundlesUlSlotAgg=10
...    NRCELL-1:minTbsUlSlotAgg=384
...    NRCELL-1:sCellDeactInPoorRf=Deact_Scells_VoNr_SAg      #None
...    NRCELL-1:ulTransPrecodeCtl:ulSlotAggOffTotPwrThresh=33
...    NRCELL-1:ulTransPrecodeCtl:ulSlotAggOnTotPwrThresh=30
#...    NRCELL-1:drxProfile2:drxLongCycle = 40ms
#...    NRCELL-1:drxProfile2:drxOnDurationTimer = 6ms
#...    NRCELL-1:drxProfile2:drxInactivityTimer = 6ms
...    NRCELL-1:actCDrxVoNR=true
...    NRCELL-1:actCDrx=true

...    NRCELL-1:actEmergencyCall=true
...    MRBTS-1/NRBTS-1/NRCELL-1:emergencyCallRestrictions:emergencyCallMrListIgnore=true
...    MRBTS-1/NRBTS-1/NRCELL-1:emergencyCallRestrictions:emergencyCallPlmnHoAllowed=true
@{CB007103_legacy}
...    NRCELL-1:actUlDftSOfdm=true
...    NRCELL-1:ulTransPrecodeCtl:ulTransPrecodeOffSinrThresh=160      #rdUlTransPrecodeOnSinrThreshR16DmrsOffset    0x580832     100->0db
...    NRCELL-1:ulTransPrecodeCtl:ulTransPrecodeOnSinrThresh=130      #rdUlTransPrecodeOffSinrThreshR16DmrsOffset     0x580833     100->0db
...    NRCELL-1:ulTransPrecodeCtl:ulTransPrecodePi2Bpsk=true
...    NRCELL-1:ulTransPrecodeCtl:ulTransPrePi2BpskPwrBoost=true

...    NRCELL-2:actUlDftSOfdm=true
...    NRCELL-2:ulTransPrecodeCtl:ulTransPrecodeOffSinrThresh=160
...    NRCELL-2:ulTransPrecodeCtl:ulTransPrecodeOnSinrThresh=130
...    NRCELL-2:ulTransPrecodeCtl:ulTransPrecodePi2Bpsk=true
...    NRCELL-2:ulTransPrecodeCtl:ulTransPrePi2BpskPwrBoost=true

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

@{UN_PARAMS_FOR_8224}
...    NRCELL-11/NRCELL_FDD-1:chBwUl=25MHz
...    NRCELL-13/NRCELL_FDD-1:chBwUl=40MHz
...    NRCELL-12/NRCELL_FDD-1:chBwUl=20MHz
...    NRCELL-14/NRCELL_FDD-1:chBwUl=15MHz

@{PARAMS_FOR_8224}
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-2
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-3
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-13/CHANNELGROUP-1/CHANNEL-2
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-13/CHANNELGROUP-1/CHANNEL-4

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

...    NRCELL-11:administrativeState=Locked     #Sunil will provide the IMprovment
...    NRCELL-12:administrativeState=Locked
...    NRCELL-13:administrativeState=Locked

@{OnlineParam_8224_WA}
...    NRCELL-11:administrativeState=Unlocked
...    NRCELL-12:administrativeState=Unlocked
...    NRCELL-13:administrativeState=Unlocked

@{PowerSaving}
...    NRBTS:actNrLBPowerSaving=true
...    NRBTS:actCoordinated4g5gPowerSaving=cellDeactivation
...    NRBTS/NRPGRP-10:lbpsCSONCtlEnabled=true
...    NRBTS/NRPGRP-10:lbpsLastCellMinLoad=20
...    NRBTS/NRPGRP-10:lbpsLastCellRTXMinLoad=10
...    NRBTS/NRPGRP-10:lbpsLastCellSOEnabled=true
...    NRBTS/NRPGRP-10:lbpsMaxLoad=60
...    NRBTS/NRPGRP-10:lbpsMinLoad=20
...    NRBTS/NRPGRP-10:lbpsMonWinForCellSOff=120
...    NRBTS/NRPGRP-10:lbpsMonWinForCellSOn=120
...    NRBTS/NRPGRP-10:lbpsPdcchLoadOffset=4
...    NRBTS/NRPGRP-10:lbpsRTXCellCapOffset=80
...    NRBTS/NRPGRP-10:lbpsRTXMaxLoad=60
...    NRBTS/NRPGRP-10:lbpsRTXMinLoad=20
...    NRBTS/NRPGRP-10:lbpsRTXSOffTime=300
...    NRBTS/NRPGRP-10:lbpsRTXSOnTime=120
...    NRBTS/NRPGRP-10:lbpsSOMethod=cell switch off
...    NRBTS/NRPGRP-10:lbpsCellList:lbpsCellSOOrder=70|nrCellId=1
...    NRPGRP-10:lbpsPeriodList:lbpsDuration=35|lbpsDayOfWeek=Wed
...    NRPGRP-10:lbpsPeriodList:lbpsStartTimeHour=8|lbpsDayOfWeek=Wed
...    NRPGRP-10:lbpsPeriodList:lbpsStartTimeMinute=20|lbpsDayOfWeek=Wed
...    NRBTS:x2EnDcCfUpRspTmr=3
...    NRBTS:maxX2EnDcCfUpRetry=3
...    NRBTS:x2EnDcCfUpRdmDelayTmr=3
...    NRBTS:xnNgRanCfUpRdmDelayTmr=3
...    NRBTS:actLbpsCtrlLogicEnh=true
...    NRBTS/NRPGRP-10:lbpsLoadCalcMethod=Max(G, C, P)
...    NRBTS/NRPGRP-10:lbpsSOnTrRule=MinValueMethod
...    NRBTS/NRPGRP-10:lbpsSOffTrRule=MaxValueMethod

@{Xn_link}
...    NRBTS/XNLINK-1:cPlaneIpAddr=10.0.1.122
...    NRBTS/XNLINK-1:cPlaneIpAddrCtrl=oamControlled
...    NRBTS:actIncXn=true

${UE_Capa_SAG1_ULCA}    SEPARATOR=
...    E9A0900057C5F5A13561803C428005801400000806024C5C00670F424026C830E7CC31E50B038260300C4701FB8D85181AC1184341020E906C036B64C558D0E7C471E819F
...    604F8C48E3C873EA39F30C7942C0E070F0060001809C00FFC007003FF0005E0000E000A0541B107582308682041E20D00656C98AB121CFB027C471E31238F21CFA8E7CC31
...    E50B0381C3C27FFC00001FFF00000170000381546C4DD608C21A0810748340165B262A86873E238F40CFB027C639F30C7942C0E070F04E007C0003801F00002E0000702A0
...    D831AC1184341020F941A00CAD931562439F11C7B027C62471E439F51CF9863CA1607038784FFF800003FFE000002E0000702B8D84BAC1184341020E9068036B64C558D0E
...    7C471E819F604F8C48E3C873EA39F30C7942C0E070F05C00FFC007003FF0005C0000E0551B133582308682041D20D80596C98AA1A1CF88E3D033EC09F18E7CC31E50B0381
...    C3C00C0003013801FF800E007FE000BD0001C0014006CA0000A00000A836236B04610D04083E5068032B64C55890E7C471EC09F1891C790E7D473E618F28581C0E1E13FFE
...    00000FFF800000B80001C0A83600EB04610D04083E5068032B64C55890E7C471EC09F1891C790E7D473E618F28581C0E1E13FFE00000FFF800000B80001C011787882001C
...    46000000160205E1E1280071340000085808178B850001C41000E230000020B0102F17060003882001C4D000006160205E1E14000713400002058081707850001C4100000
...    A160205E1E20800711800003058081787882001C4D00000E160205E2E1400071040038820000202C040BC5C28000E2300071180000485808178B882001C41000E2300000A
...    0B0102F1710400388C001C46000016160205E1E2300071340000605808178F830001C41000E2300071300000685808178F882001C4C000E2600071300000705808178B882
...    001C4D000E2680000F0B0102F1F104003882001C4D000E268000100B01020120234028809B01060260BA006D84614489B1CF870A244D8E7C38912244D8E7C38912244D8E7
...    C3851226C73E1C28913639F0E14489B1CF870A244D8E7C38912244D8E7C38912244D8E7C38912244D8E7C38912244D8E7C3851226C73E1C68912244D8E7C38D1224489B1C
...    F871224489B1CF871A2448913639F0C00C888C6318C6318C6318C6318CF417001E00140E0A00E0601280380030120020301F02001000000008000010040000100200000C0
...    1000008008000050040000300200001C01000010043032B282B262B236B066B062B036B2A6B27680E0800004B29202000032CA480800014B29282000072CA4A0800024B29
...    2820000B2CA4A0800034B292820000F2CA4A03A81C552A8AA515548F2A8365506AAA07954AB285801200340A0010080801002020040084040200401004008402008010080
...    100202004008804028050100E01C0404008080803006020080104040100201002004202010020080100210100200404010021008020040200400808010022010040080400
...    801010020044020040080801002020040088040080101002004040080108080100202008010C0C0300680500A0600400C0080103002006004008180801100400860600400
...    C038010301000A008010180300701200C0C0180380900620100E00404048030101200C60201C00808070020202401808090063543E00020406080C0E1416181A202224262
...    8303236383A3E424A4C4E5052545A5E828305A

${PRB_USED_PUSCH_SAG_REP1}    M55370C00019
#The number of PUSCH PRBs that were allocated to slot aggregation bundle repetition 1 transmission with DFT-s-OFDM and 64QAM table
#over the measurement period.
${PRB_USED_PUSCH_SAG_REP2}    M55370C00020
#The number of PUSCH PRBs that were allocated to slot aggregation bundle repetition 2 transmission with DFT-s-OFDM and 64QAM table
#over the measurement period.
${PRB_USED_PUSCH_SAG_REP4}    M55370C00021
#The number of PUSCH PRBs that were allocated to slot aggregation bundle repetition 4 transmission with DFT-s-OFDM and 64QAM table
#over the measurement period.
${MAX_UE_SAG}    M55370C00023    #This counter describes the maximum number of users that are in SAG mode.
${ACC_UE_SAG}    M55370C00022    #This counter describes the number of users that are in SAG mode.

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

${ACC_UE_CONF_DFT_R16_DMRS_PUSCH}    M55165C00036
#This counter provides the number of UEs configured with DFT-s-OFDM and Rel16 DMRS for a physical uplink shared channel (PUSCH).
${PUSCH_SUC_ANY_TX_DFT_R16_DMRS}    M55370C00032
#This counter provides the sum of physical uplink shared channel (PUSCH) CRC-OK detections made for any transmission attempt
#on a PUSCH with DFT-s-OFDM and Rel16 DMRS over the measurement period.
${PUSCH_INI_TX_DFT_R16_DMRS}    M55370C00034
#This counter provides the sum of initial transmissions on a physical uplink shared channel (PUSCH) with DFT-s-OFDM and Rel16 DMRS
#over the measurement period.
${PUSCH_SUC_INI_TX_DFT_R16_DMRS}    M55370C00035
#This counter provides the sum of physical uplink shared channel (PUSCH) CRC-OK detections made for the initial transmission attempt
#over a PUSCH with DFT-s-OFDM and Rel16 DMRS over the measurement period.
${PUSCH_UNSUC_TX_DFT_R16_DMRS}    M55370C00036
#This counter provides the sum of unsuccessful last retransmissions on a physical uplink shared channel (PUSCH) with DFT-s-OFDM
#and Rel16 DMRS over the measurement period.

@{PM_Counters_D004}
...    NRCELL-1:${PRB_USED_PUSCH_SAG_REP1}>0
...    NRCELL-1:${PRB_USED_PUSCH_SAG_REP2}>0
...    NRCELL-1:${PRB_USED_PUSCH_SAG_REP4}>0
...    NRCELL-1:${MAX_UE_SAG}<=4
...    NRCELL-1:${ACC_UE_CONF_R16_DMRS_PUCCH_F3}>0
...    NRCELL-1:${DEN_1_SEC_UE_SAMPLE}>0
...    NRCELL-1:${PUCCH_F3_NON_DTX_R16_DMRS}>0
...    NRCELL-1:${PUCCH_F3_DTX_R16_DMRS}>=0
...    NRCELL-1:${PUCCH_FORMAT3_NON_DTX}>0
...    NRCELL-1:${PUCCH_FORMAT3_DTX}>=0

...    NRCELL-1:${ACC_UE_CONF_DFT_R16_DMRS_PUSCH}>0
...    NRCELL-1:${PUSCH_INI_TX_DFT_R16_DMRS}>0
...    NRCELL-1:${PUSCH_SUC_INI_TX_DFT_R16_DMRS}>0
...    NRCELL-1:${PUSCH_UNSUC_TX_DFT_R16_DMRS}>=0
...    NRCELL-1:${PUSCH_SUC_ANY_TX_DFT_R16_DMRS}>0

*** Test Cases ***
CB007103-ET-D004_Interaction_with_CB009169_Interband_TDD_FDD_UL_CA_2CCs_TDD_at_Pcell
    [Documentation]
    ...    1. This user scenario describes operation of interband TDD+FDD UL CA 2CCs (TDD at PCell)
    ...        with Rel16 DMRS used for PUSCH and PUCCH F3
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
    ...           a. unblock All SDL CELLs
    ...           b. UE1 and UE2 emergency Call setup to Nrcell-1, blind scell addition Ncell-14
    ...           c. adjust UL sinr to enable transform precode. and make MCS0,1
    ...    4. Expected Results:
    ...           a. All CELLs on air.
    ...           b. UE1 and UE2 in UL CA status.PUCCH-F3 with R16 configured due to NRCELL-1:pucchF3Rel16Pi2BpskAlwaysOn=true
    ...           c. TP enabled. PUSCH with R16 configured.
    ...    5. knowlegde info:
    ...         sinr     34,35 ---> MCS 28      pathloss=80
    ...         sinr     16,18 db ---> MCS 23,24     pathloss=100
    ...         sinr     5,6,7,8db ---> MCS 11,12    pathloss=110
    ...         sinr     -0.xxx -1.xxx db ---> MCS 0,1,2    pathloss=120
    [Tags]    D004    QC_46962
    OnlineParamChange    ${OnlineParam_8224_WA}
    Clear Counter Files
    Update UE capa    ue_id=1    SA_Capa_perUE_Full=${UE_Capa_SAG1_ULCA}
    Deactive Pathloss
    EC Call
    UE PDU Session Setup    ue_id=1    pdu=2    gw=2    fiveQi=6    qfi=1
    Send Throughput
    Update UE capa    ue_id=2    SA_Capa_perUE_Full=${UE_Capa_SAG1_ULCA}
    Deactive Pathloss    ue_id=2
    EC Call    ue_id=2
    UE PDU Session Setup    ue_id=2    pdu=2    gw=2    fiveQi=6    qfi=1
    Start To Capture GNB BIP Log    tag=gnb_bip
    Send Throughput    ue_id=2
    Check Traffic CA
    Check Traffic CA    ue_id=2
    Adjust Sinr Target Pathloss    1    138
    Adjust Sinr Target Pathloss    2    138
    Sleep    10s         #to wait traffic stable
    Stop To Capture GNB BIP Log    tag=gnb_bip
    Deactive Pathloss
    Deactive Pathloss    ue_id=2
    Check Traffic CA
    Check Traffic CA    ue_id=2
    Check Counters    ${PM_Counters_D004}

*** Keywords ***
UE PDU Session Setup
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${gw}=1    ${fiveQi}=5    ${qfi}=1
    Execute Egate Command    qosflow_modify qos_flow=3 default=on
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu} trf_type=internal
    ${ret1}=    Execute Egate Command    ue_pdu_session_setup pdu=${pdu} ue=${ue_id} nwslice=1 gw=${gw}
    ...    pass_regexp=QoS Routing Table
    Should Contain    ${ret1}    QFI:${qfi} 5QI:${fiveQi}

EC Call
    [Arguments]    ${ue_id}=1
    Execute Egate Command    qosflow_modify qos_flow=1 priority=1 default=on
    Execute Egate Command    qosflow_modify qos_flow=2 priority=1
    UE Register And Add Pdu With emergency call    ue_id=${ue_id}    pdu_id=1
    PDU Add QoSFlow 5QI1    ue_id=${ue_id}

UE Register And Add Pdu With emergency call
    [Arguments]    ${ue_id}    ${pdu_id}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=1
    Execute Egate Command    ue_nr_rrc_setup_param id=${ue_id} establishment_cause=emergency
    Execute Egate Command    ue_register id=${ue_id} nwslice=1    pass_regexp=Received REGISTRATION COMPLETE
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    ${cmd_emergency}=    Catenate    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${ue_id}
    ...    request_type=initial-emergency-request
    Execute Egate Command    ${cmd_emergency}
    ...    pass_regexp=UE${ue_id}: Ue ${ue_id} PduId 1 Created FiveQi:Qfi mapping fiveQi 5 qfi 1

PDU Add QoSFlow 5QI1
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=2 by=amf    pass_regexp=Added QosFlow with QFI:2 fiveQI:1

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be Onair    cell_id=1    check_sib=${True}    timeout=600
    Cells Should Be Onair    cell_id=2    check_sib=${True}    timeout=600
    Cells Should Be Onair    cell_id=14    check_sib=${True}    timeout=600

Update UE capa
    [Arguments]    ${ue_id}    ${SA_Capa_perUE_Full}=none
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full} nr_usage_setting=voice_centric
    Execute Egate Command    ${cmd}

Send Throughput
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${pdu_2}=2
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=2 dir=dl mbps=1 trf_id=1    pass_regexp=Started Downlink
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_2} qfi=1 dir=dl mbps=170 trf_id=2    pass_regexp=Started Downlink
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_2} qfi=1 dir=dl mbps=170 trf_id=3    pass_regexp=Started Downlink
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_2} qfi=1 dir=ul mbps=170 trf_id=1    pass_regexp=Started Uplink
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=2 dir=ul mbps=1 trf_id=2    pass_regexp=Started Uplink
    sleep    5s    #Flow stability

Check Traffic CA
    [Arguments]    ${ue_id}=1    ${Pcell_Tput_Target}=7    ${sleep_time}=15s    ${traffic}=10
    sleep    ${sleep_time}    sleep for Tput stable
    ${Pcell_Tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${Pcell_tput}/1000 > ${traffic}
    ${Scell1_Tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=1    type=pdsch    rate_type=ave
    Should Be True    ${Scell1_Tput}/1000 > 0

    ${ul_throughput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pusch    rate_type=ave
    Should Be True    ${ul_throughput}/1000> 0
    ${ul_throughput2}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=1    type=pusch    rate_type=ave
    Should Be True    ${ul_throughput2}/1000> 0

Adjust Sinr Target Pathloss
    [Arguments]    ${ue_id}=1    ${sinr_target_pathloss}=130    ${pusch_type}=typeB
    Execute Egate Command    ul_sinr_testmode_nr profile_id=2 sinr_target_pusch=-30
    Execute Egate Command    ue_testmode_set_nr id=${ue_id} testmode=ul_sinr action=activate profile_id=2
    Execute Egate Command    ul_sinr_testmode_nr profile_id=1 pathloss=${sinr_target_pathloss}    pass_regexp=CTRL_AP_TEST_UL_SINR_NR

    Execute Egate Command    ue_testmode_set_nr id=${ue_id} testmode=ul_sinr action=activate profile_id=1    #pass_regexp=rrcReconfigurationComplete
    ...    timeout=180

Deactive Pathloss
    [Arguments]    ${ue_id}=1    ${profile_id}=1
    Execute Egate Command    ue_testmode_set_nr id=${ue_id} testmode=ul_sinr action=deactivate profile_id=${profile_id}
    Execute Egate Command    ue_testmode_set_nr id=${ue_id} testmode=ul_sinr action=deactivate profile_id=2

Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_2T4F
    Execute Cmd On PC    sudo ip addr add 10.0.1.102/24 dev eth3
    Execute Egate Command    trace_sim amf=1 on
    Execute Egate Command    sim_trace enb=3 protocol=xn on
    Execute Egate Command    sim_trace enb=1 protocol=x2 on

#NR-ARFCN values UL:DL
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

    Update Cfg    set_qosflow id=1 5qi=5 default=on
    Update Cfg    set_qosflow id=2 5qi=1 ue=1-12
    Update Cfg    set_qosflow id=3 5qi=6
    Update Cfg    set_qosrule id=1 proto=tcp qos_flow=1
    Update Cfg    set_qosrule id=2 proto=udp qos_flow=2
    Update Cfg    set_nwslice id=1 snssai=0x01:0xD143A5 default=on ue=1-12 qos_flows=2,1,3 qos_rules=1,2 amf=1
    Update Cfg    ue_nr_capabilities id=1-12 voice_over_nr=on:on:off
    Update Cfg    amf_param id=1 full_nas_auth=on ims_voice_3gpp=on nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g
