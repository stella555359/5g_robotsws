*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    team-rock
...    owner-xiaowen.xu    release-SBTS23R3    CRT    CLOUD_5G_I_[LO][LO]_AP_[LOO]
Resource          ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${NOKIA_XNAP_PLUGIN_FLAG}    ${True}
${NOKIA_F1AP_PLUGIN_FLAG}    ${True}

@{PARAMS_IN_SCF}
...    @{PARAMS_FOR_CA}
...    @{PARAMS_FOR_GNB1}
...    @{PARAMS_ADJ_REL_FOR_GNB1}
...    @{PARAMS_FOR_OTHERS}
...    @{GNB1_CA_rel_for_NRCELL_1}
...    @{A2Redirect_enable_gnb1}

@{PARAMS_IN_SCF_GNB2}
...    @{PARAMS_FOR_CA}
...    @{PARAMS_FOR_GNB2}
...    @{PARAMS_ADJ_REL_FOR_GNB2}
...    @{PARAMS_FOR_OTHERS}
...    @{GNB2_CA_rel_for_NRCELL_11}
...    @{8696_710}

@{PARAMS_FOR_CA}
...    NRBTS:actCarrierAggregation=true
...    NRBTS:sCellActivationMethod=blind
...    NRBTS:caConfigurationSupport=4CCDL_2CCUL
...    NRBTS:weightForIgnbCaSelection=1
...    NRBTS:actIncXn=true
...    NRBTS:maxNumScellsDl=2
...    NRBTS:maxNumScellsUl=2
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:carrierAggregationSupportList=ca_Fdd_Fdd,ca_Fdd_Fr1Tdd_Sa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Any_Sa,ca_Fdd_Any_Sa
...    NRDU-1:actInterGnbCa=DLOnly
...    NRDU-1:xgUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRCELL:actK1Opt=intraAndInter-gNB
...    NRCELL:weightForSCellSelection=50
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRCELL:maxNumScellsDlFr1=3
@{PARAMS_FOR_OTHERS}


...    NRCELL:actCDrx=false
...    NRBTS:cipherPrefL:nea0=8
...    NRBTS:cipherPrefL:nea1_128=0
...    NRBTS:cipherPrefL:nea2_128=0
...    NRBTS:cipherPrefL:nea3_128=0

@{A2Redirect_enable_gnb1}
...    NRCELL:cellDepType=SA
...    NRBTS:actRedirect=true
...    NRCELL:a2MeasRedirectEnabled=none
...    NRCELL:a2MeasRedirectSsbRsrp:a2HysteresisRedirectSsbRsrp=0
...    NRCELL:a2MeasRedirectSsbRsrp:a2ThresholdRedirectSsbRsrp=45
...    NRCELL:a2MeasRedirectSsbRsrp:a2TimeToTriggerRedirectSsbRsrp=ms480
...    NRBTS/NRMORED-1:redirRat=nr
...    NRBTS/NRMORED-1:redirFreqNr=633364
...    NRBTS/NRMORED-1:redirPrio=1
...    NRCELL/NRREDRT-1:redirRat=nr
...    NRCELL/NRREDRT-1:redirFreqNr=633364
...    NRCELL/NRREDRT-1:redirPrio=1
...    NRCELL/NRREDRT-1:redirSsbScs=30 KHz

...    NRBTS:actRanSharing=true
...    NRCELL/NRPLMNSET_SA-1
...    NRCELL/NRPLMNSET_SA-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRCELL/NRPLMNSET_SA-1:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-200
...    delete:NRBTS/NRCELL:configuredEpsTac
...    delete:NRBTS/NRCELL:trackingAreaDN
...    NRBTS:actSPID=true

...    NRBTS:actMobilityProfile=true
...    NRBTS:actInterFreqHoSA=true
...    NRBTS:actIntraFreqHoSA=true
...    NRPMRNL-1:miNrRelReportCu=15min
...    NRBTS/NRMOPR_SA-1:a2MeasRedirectEnabled=rsrp
...    delete:NRBTS/NRMOPR_SA-1:a1MeashoEnabledSA
...    delete:NRBTS/NRMOPR_SA-1:a3MeasEnabled
...    NRCELL:nrDefMoPrSaDN=MRBTS-1/NRBTS-1/NRMOPR_SA-1
...    NRBTS/NRMOPR_SA-1:nrMoRedDNList=MRBTS-1/NRBTS-1/NRMORED-1

@{8696_710}
...    NRBTS:actIdlMMEnDcSteering=true
...    NRBTS:drbInactivityTimerSA=10
...    NRBTS:srbInactivityTimerSA=10

...    NRCELL-11:a4ReportTimerEnDc=6000
...    NRCELL-11:idleMMEnDcSteeringPercentageOfUes=100
...    NRCELL-11:idleMMEnDcSteeringSsbFrequency=2075419
...    NRCELL-11:idleMMEnDcSteeringWRREnabled=true
...    NRCELL-11:t320EnDc=min10
...    NRCELL-11:cellReselectionPriority=5
...    NRCELL-11:nrSysInfoProfileDN=MRBTS-1/NRBTS-2/NRSYSINFO_PROFILE-11
...    NRCELL:a4PeriodicMeasControlSA:a4Fr1SupervisionTimer=10000
...    NRCELL:a4PeriodicMeasControlSA:a4Fr2SupervisionTimer=10000
...    NRCELL:a4PeriodicMeasControlSA:a4MeasMaxNumber=1
...    NRCELL:a4PeriodicMeasControlSA:a4RetryTimer=3

...    NRCELL-11/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-11/NRHOIF-1:freqBandIndicatorNR=257
...    NRCELL-11/NRHOIF-1:ifhoSsbScs=240 KHz
...    NRCELL-11/NRHOIF-1:ifhoSsbSmtcDuration=sf2
...    NRCELL-11/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-11/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-11/NRHOIF-1:ssbFrequency=2075419
...    NRCELL-11/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-11/NRHOIF-1:a4MeasEnDcSteeringEnabled=rsrp
...    NRCELL-11/NRHOIF-1:a4MeasEnDcSteeringSsbRsrp:a4HysteresisEnDcSteeringSsbRsrp=0
...    NRCELL-11/NRHOIF-1:a4MeasEnDcSteeringSsbRsrp:a4ThresholdEnDcSteeringSsbRsrp=56
...    NRCELL-11/NRHOIF-1:a4MeasEnDcSteeringSsbRsrp:a4TimeToTriggerEnDcSteeringSsbRsrp=ms0

...    NRBTS/NRSYSINFO_PROFILE-11:addHystSfHigh=dB-2
...    NRBTS/NRSYSINFO_PROFILE-11:addHystSfMedium=dB-2
...    NRBTS/NRSYSINFO_PROFILE-11:nCellChangeHigh=16
...    NRBTS/NRSYSINFO_PROFILE-11:nCellChangeMedium=15
...    NRBTS/NRSYSINFO_PROFILE-11:qHyst=dB0
...    NRBTS/NRSYSINFO_PROFILE-11:siWindowLength=s40
...    NRBTS/NRSYSINFO_PROFILE-11:systemInformationTargetRate=1
...    NRBTS/NRSYSINFO_PROFILE-11:tEvaluation=s30
...    NRBTS/NRSYSINFO_PROFILE-11:tHystNormal=s30
...    NRBTS/NRSYSINFO_PROFILE-11:tReselectionEutra=0
...    NRBTS/NRSYSINFO_PROFILE-11:threshServingLowP=0
...    NRBTS/NRSYSINFO_PROFILE-11:threshServingLowQ=0
...    NRBTS/NRSYSINFO_PROFILE-11:sibSchedulingList:sibBroadcastStatus=broadcasting|sibType=sibType2
...    NRBTS/NRSYSINFO_PROFILE-11:sibSchedulingList:sibPeriodicity=rf8|sibType=sibType2
...    NRBTS/NRSYSINFO_PROFILE-11:sibSchedulingList:sibScope=cellSpecific|sibType=sibType2
...    NRBTS/NRSYSINFO_PROFILE-11:sibSchedulingList:sibBroadcastStatus=broadcasting|sibType=sibType3
...    NRBTS/NRSYSINFO_PROFILE-11:sibSchedulingList:sibPeriodicity=rf8|sibType=sibType3
...    NRBTS/NRSYSINFO_PROFILE-11:sibSchedulingList:sibScope=cellSpecific|sibType=sibType3
...    NRBTS/NRSYSINFO_PROFILE-11:sibSchedulingList:sibBroadcastStatus=broadcasting|sibType=sibType4
...    NRBTS/NRSYSINFO_PROFILE-11:sibSchedulingList:sibPeriodicity=rf8|sibType=sibType4
...    NRBTS/NRSYSINFO_PROFILE-11:sibSchedulingList:sibScope=cellSpecific|sibType=sibType4
...    NRBTS/NRSYSINFO_PROFILE-11:sibSchedulingList:sibBroadcastStatus=broadcasting|sibType=sibType5
...    NRBTS/NRSYSINFO_PROFILE-11:sibSchedulingList:sibPeriodicity=rf8|sibType=sibType5
...    NRBTS/NRSYSINFO_PROFILE-11:sibSchedulingList:sibScope=cellSpecific|sibType=sibType5
...    NRBTS/NRSYSINFO_PROFILE-11/NRIAFIM-1:numberOfTransmittedSsBlocks=1 beam
...    NRBTS/NRSYSINFO_PROFILE-11/NRIAFIM-1:qRxLevMin=-56
...    NRBTS/NRSYSINFO_PROFILE-11/NRIAFIM-1:sIntraSearchP=22
...    NRBTS/NRSYSINFO_PROFILE-11/NRIAFIM-1:sIntraSearchQ=0
...    NRBTS/NRSYSINFO_PROFILE-11/NRIAFIM-1:tReselectionNr=1
...    NRBTS/NRSYSINFO_PROFILE-11/NRIRFIM-1:cellReselectionPriority=7
...    NRBTS/NRSYSINFO_PROFILE-11/NRIRFIM-1:dlCarrierFreq=2075419
...    NRBTS/NRSYSINFO_PROFILE-11/NRIRFIM-1:dssCellsDeployed=false
...    NRBTS/NRSYSINFO_PROFILE-11/NRIRFIM-1:freqBandIndicatorNR=257
...    NRBTS/NRSYSINFO_PROFILE-11/NRIRFIM-1:numberOfTransmittedSsBlocks=1 beam
...    NRBTS/NRSYSINFO_PROFILE-11/NRIRFIM-1:qOffsetFreq=-4dB
...    NRBTS/NRSYSINFO_PROFILE-11/NRIRFIM-1:qRxLevMin=-56
...    NRBTS/NRSYSINFO_PROFILE-11/NRIRFIM-1:ssbScs=240 KHz
...    NRBTS/NRSYSINFO_PROFILE-11/NRIRFIM-1:tReselectionNr=1
...    NRBTS/NRSYSINFO_PROFILE-11/NRIRFIM-1:threshXHighP=30
...    NRBTS/NRSYSINFO_PROFILE-11/NRIRFIM-1:threshXHighQ=30
...    NRBTS/NRSYSINFO_PROFILE-11/NRIRFIM-1:threshXLowP=22
...    NRBTS/NRSYSINFO_PROFILE-11/NRIRFIM-1:threshXLowQ=22
...    NRBTS/NRSYSINFO_PROFILE-11/NRLIM-1:allowedMeasBw=mbw100
...    NRBTS/NRSYSINFO_PROFILE-11/NRLIM-1:carrierFreq=400
...    NRBTS/NRSYSINFO_PROFILE-11/NRLIM-1:cellReselectionPriority=6
...    NRBTS/NRSYSINFO_PROFILE-11/NRLIM-1:cellReselectionSubPriority=oDot4
...    NRBTS/NRSYSINFO_PROFILE-11/NRLIM-1:idleMMEutraCelResWeightEnDc=25
...    NRBTS/NRSYSINFO_PROFILE-11/NRLIM-1:pMaxEutra=23
...    NRBTS/NRSYSINFO_PROFILE-11/NRLIM-1:presenceAntPort1=false
...    NRBTS/NRSYSINFO_PROFILE-11/NRLIM-1:qQualMin=-34
...    NRBTS/NRSYSINFO_PROFILE-11/NRLIM-1:qRxLevMin=-22
...    NRBTS/NRSYSINFO_PROFILE-11/NRLIM-1:threshXHigh=0
...    NRBTS/NRSYSINFO_PROFILE-11/NRLIM-1:threshXHighQ=30
...    NRBTS/NRSYSINFO_PROFILE-11/NRLIM-1:threshXLow=0
...    NRBTS/NRSYSINFO_PROFILE-11/NRLIM-1:threshXLowQ=22

...    NRBTS:actMobilityProfile=true
...    NRBTS:actRanSharing=true
...    NRCELL/NRPLMNSET_SA-1
...    NRCELL/NRPLMNSET_SA-1:nrPlmnDNList=MRBTS-1/NRBTS-2/NRPLMN-1
...    NRCELL/NRPLMNSET_SA-1:trackingAreaDN=MRBTS-1/NRBTS-2/TRACKINGAREA-200
...    NRCELL/NRPLMNSET_NSA-1
...    NRCELL/NRPLMNSET_NSA-1:configuredEpsTac=200
...    NRCELL/NRPLMNSET_NSA-1:nrPlmnDNList=MRBTS-1/NRBTS-2/NRPLMN-1
...    delete:NRBTS/NRCELL:configuredEpsTac
...    delete:NRBTS/NRCELL:trackingAreaDN
...    NRBTS/NRMOPR_NSA-1:a3MeasEnabled=rsrp
...    NRCELL:nrDefMoPrNsaDN=MRBTS-1/NRBTS-2/NRMOPR_NSA-1
...    NRCELL:nrDefMoPrSaDN=MRBTS-1/NRBTS-2/NRMOPR_SA-11
...    NRBTS/NRMOPR_SA-11:a2MeasRedirectEnabled=none
...    NRBTS/NRMOPR_SA-11:a3MeasEnabled=none
...    NRBTS/NRMOPR_SA-11:a5MeasEnabled=none
...    NRBTS/NRMOPR_SA-11:emergencyCallFails=disabled
...    NRBTS/NRMOPR_SA-11:emergencyFBMode=disabled
...    NRBTS/NRMOPR_SA-11:voiceFBMode=disabled
...    delete:NRBTS/NRMOPR_SA-1
...    NRBTS/NRMOPRMA_SA-1:mobilityProfilePriority=5
...    NRBTS/NRMOPRMA_SA-1:nrMoPrSaDN=MRBTS-1/NRBTS-2/NRMOPR_SA-11
...    NRBTS/NRMOPRMA_SA-1:nrPlmnDNList=MRBTS-1/NRBTS-2/NRPLMN-1
...    NRBTS/NRMOPR_SA-11/NRMOIMP_SA-1:idleMMSteeringAlgo=non CA aware
...    NRBTS/NRMOPR_SA-11/NRMOIMP_SA-1:dlCarFreqEutraList:dlCarFreqEutra=400
...    NRBTS/NRMOPR_SA-11/NRMOIMP_SA-1:dlCarFreqEutraList:idleMMEutraCelResWeight=50
...    NRBTS/NRMOPR_SA-11/NRMOIMP_SA-1:dlCarFreqEutraList:idleMMEutraCelResWeightEnDc=100
...    NRBTS/NRMOPR_SA-11/NRMOIMP_SA-1:idleMMEnDcSteeringSsbFrequency=2075419

@{PARAMS_FOR_GNB1}
...    NRCELL-1:sCellDeactivationTimerGNB=infinity
...    NRCELL-2:sCellDeactivationTimerGNB=infinity
...    NRCELL:chBw=40MHz

@{PARAMS_ADJ_REL_FOR_GNB1}
...    NRBTS:iGnbCaXnCfUpBackOffTmr=60
...    NRBTS:iGnbCaXnSetupReqTmr=60
...    NRBTS:iGnbCaXnSetupRespTmr=60
...    NRBTS:intGnbScellTempBlockTmr=60
...    NRBTS/NRADJGNB-2:administrativeState=Unlocked
...    NRBTS/NRADJGNB-2:gNbIdLength=22
...    NRBTS/NRADJGNB-2:gNodeBId=2
...    NRBTS/NRADJGNB-2:weightForIgnbCaSelection=1
...    NRBTS/NRADJGNB-2:xnLinkRef=1
...    NRBTS/NRADJGNB-2:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-2:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-2:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-3:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-3:fiveGsTac=200
...    NRBTS/NRADJNRCELL-3:gNbId=2
...    NRBTS/NRADJNRCELL-3:gNbIdLength=22
...    NRBTS/NRADJNRCELL-3:lcrId=3
...    NRBTS/NRADJNRCELL-3:nrarfcn=653400
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
...    NRBTS/NRADJNRCELL-11:physCellId=60
...    NRBTS/NRADJNRCELL-11:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-11:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-11:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-11:freqBandIndicatorNR=3
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

@{GNB2_CA_rel_for_NRCELL_11}
...    NRCELL-11:measGapSelectionSA=favourUeThroughput
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

@{GNB1_CA_rel_for_NRCELL_1}
...    NRCELL-1:measGapSelectionSA=favourUeThroughput
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
...    NRCELL-1/NRREL-3:sCellAdditionMethod=blind
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
...    NRCELL-1/NRREL-11:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-11:sCellOperationalMode=dlOnly
...    NRCELL-1/NRHOIF-1:cellDepType=SA
...    NRCELL-1/NRHOIF-1:freqBandIndicatorNR=77
...    NRCELL-1/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf2
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-1/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-1:ssbFrequency=663366

@{PARAMS_FOR_GNB2}
...    NRBTS:iGnbCaXnCfUpBackOffTmr=60
...    NRBTS:iGnbCaXnSetupReqTmr=90
...    NRBTS:iGnbCaXnSetupRespTmr=60
...    NRBTS:intGnbScellTempBlockTmr=60
...    NRCELL-3:chBw=40MHz
...    NRCELL-4:chBw=40MHz
...    NRCELL-3:gscnOrSsPbchArfcn=8060
...    NRCELL-3:sCellDeactivationTimerGNB=infinity
...    NRCELL-4:sCellDeactivationTimerGNB=infinity
...    NRCELL-11:sCellDeactivationTimerGNB=infinity
...    NRCELL-12:sCellDeactivationTimerGNB=infinity
...    NRCELL-4:measGapSelectionSA=favourUeThroughput
...    NRCELL:a1MeasSCellAddEnabled=rsrp
...    NRCELL:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=90|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=70|a1TimeToTriggerSCellAddSsbRsrp=320ms

@{PARAMS_ADJ_REL_FOR_GNB2}
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
...    NRBTS/NRADJNRCELL-1:ssbFrequency=663360
...    NRBTS/NRADJNRCELL-1:freqBandIndicatorNR=77
...    NRBTS/NRADJNRCELL-2:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-2:fiveGsTac=200
...    NRBTS/NRADJNRCELL-2:gNbId=1
...    NRBTS/NRADJNRCELL-2:gNbIdLength=22
...    NRBTS/NRADJNRCELL-2:lcrId=2
...    NRBTS/NRADJNRCELL-2:nrarfcn=658000
...    NRBTS/NRADJNRCELL-2:physCellId=51
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-2:ssbFrequency=657984
...    NRBTS/NRADJNRCELL-2:freqBandIndicatorNR=77

# 3A_77(2A) # 28A_77(2A)
${SA_Capa_Support_3cc_CA}    SEPARATOR=
...    E9A09000575F5A13160003C320016093170019C3D09009B20C39F30C7942C0E098040623807DC6C4CC0D608C21A08107482406D6C98AB1A1C
...    F88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE00098000702A0D805AC1184341020F10480CAD931562439F604F88
...    E3C62471E439F51CF9863CA1607038784FEC000003FB000000260001C0A8360DEB04610D04083C412032B64C55890E7C471EC09F1891C790E
...    7D473E618F28581C0E1E13FFE00000FFF80000098000702A05A01BC718434005479F8A12022F6CC554800F1E00438820C22A051FBF9025F78
...    9400060019E1E26000700800000858081507898001C1B000002160562E2600070080038980000102C0AC5C4C000E01000706C00001058158B
...    898001C1B000E260000040B02107400000038038037013200141000F404B03428913639F0E14489B1CF871224489B1CF871204081B1CF8112
...    04081B1CF810206C30E000B0618C6318DE8260078007838280381804A00E000C0480080C07C12004000000020000040100000000800001004
...    0000100200000C01000008008000050040020080200800006004000038020010000000400004002000024010000180080000A004000058020
...    010240900400006019CA9ACA9AC14AC0CAC19AC15ACA5AC99AC05AC0DAC04AC08AE5681A0800004B29282000032CA4A0800014B2920200007
...    2CA480800024B292020000B2CA480800034B292020000F2CA480800044B29202000132CA480800054B29202000172CA4A0800064B29202000
...    182CA480669555D2AAAA55174AA2A82C55058AA0D154A62A93455018AA051549AAACB142402600B40A05028140A0000708080600C02004008
...    404008020100C018402004008080600C02018030404030060100C018402004008080600C02004008804030060100C01804030060808010040
...    20040100040780E1AA1F000102030406070A0B0C0D101112131418191B1C1D1F2125262728292A2D2F414182D0
${UE_Capa_eutra}    SEPARATOR=
...    A107C088460001D00000E800007400003A000000000882600008003A004100040800C10000026001440A84E9D3A74E9D3A74ED9E3CB893A74
...    ED9E3CB02002400010041C0900680E00101C01A048000381200D024002038004070060702401A0480040700080E00C0E0480340900080E001
...    01C01840002008000800160480340800680E00102000203801407006

${NRRCC_RRC_RELEASE_REDIR_NR}    M55124C01501
#The counter is updated when the RRC RELEASE with redirectedCarrierInfo IE and NR carrier frequency (ARFCN-ValueNR) is sent to UE.
${NRMOP_SA_PROFILE_SELECTED_01}    M55157C00033
#Updated when SA mobility profile 1 is selected after an initial access or after an handover.
${NRMOP_SA_PROFILE_SELECTED_11}    M55157C00043
#Updated when SA mobility profile 11 is selected after an initial access or after an handover.
${NRRCC_RRC_RELEASE_IMM_ENDC_LTE}    M55124C07501
#The counter is updated when the F1AP: UE CONTEXT RELEASE COMMAND containing RRC RELEASE with cellReselectionPriorities IE
#including LTE EN-DC carrier as primary target for Idle Mode Mobility EN-DC aware steering algorithm is sent from gNB-CU to gNB-DU.
${NRRCC_A4_MEAS_IMM_REC}    M55124C07502
#The counter is updated when the F1AP: UL RRC Message Transfer containing RRC Measurement Report for an A4 event for
#Idle Mode Mobility EN-DC aware steering is received by gNB-CU.

${IGNB_CA_ATT_SA_REL}    M55118C11008

@{expect}
...    cellReselectionPriorities
...    freqPriorityListEUTRA
...    freqPriorityListNR
...    carrierFreq 400
...    carrierFreq 2075419
...    UE CONTEXT RELEASE COMPLETE
*** Test Cases ***
CB008140-ET-GC003 UE with inter-gNB CA established is released with redirection to NR with mobility profile
    [Documentation]
    ...    This case is to check UE with inter-gNB CA established is released with redirection to NR.
    ...    [Configuration for gnb1]:
    ...    Cell id=1 gnb=2 pci=16:2 tac=200 tdd_cell=on band=n77 nr_arfcn=663400:663400 gscn=8159 chBw=40MHz ssb=663360
    ...    Cell id=2 gnb=2 pci=17:0 tac=200 tdd_cell=on band=n77 nr_arfcn=658000:658000 gscn=8103 chBw=40MHz ssb=657984
    ...    [Configuration for gnb2]:
    ...    Cell id=3 gnb=3 pci=17:1 tac=200 tdd_cell=on band=n77 nr_arfcn=653400:653400 gscn=8060 chBw=40MHz ssb=653856
    ...    Cell id=4 gnb=3 pci=17:2 tac=200 tdd_cell=on band=n77 nr_arfcn=648000:648000 gscn=8000 chBw=40MHz ssb=648096
    ...    Cell id=11 gnb=3 pci=20:0 tac=200 tdd_cell=off band=n3 nr_arfcn=349400:368400 gscn=4605 chBw=10MHz ssb=368430
    ...    Cell id=12 gnb=3 pci=20:1 tac=200 tdd_cell=off band=n28 nr_arfcn=143400:153400 gscn=1916 chBw=20MHz ssb=153370
    ...    gnb 1 cell 1 is pcell in this case , two CA relationships are gnb2 cell3 ,gnb2 cell11
    ...    2.Test Case Steps:
    ...         a. UE1 attach to gnb1 cell1, blind added NRCELL-3 NRCELL-11.
    ...         b. Trigger A2Redirect NR.
    ...         c. Check interGNBca release procedure during RRC release
    ...         d. Check counters
    [Tags]    GC003    QC_253761
    Clear Counter Files
    ue attach and send Throuput
    Check GNB2 scells added Successfully    NRCELL-3    NRCELL-11
    Trigger Redirect
    Release UEs    ue_type=all
    Check Counters in GNB1
    Check WireShark Log    ${CURDIR}${/}A2A_GC_003${/}a2a_gnb1.ini     wait_string=UEContextReleaseComplete::6
    Check WireShark Log GNB2    ${CURDIR}${/}A2A_GC_003${/}a2a_gnb2.ini

CB008140-ET-GC004 UE with inter-gNB CA established is released with reselection to LTE with mobility profile
    [Documentation]
    ...    This case is to  check UE with inter-gNB CA established is released with reselection to LTE.
    ...    [Configuration for gnb1]:
    ...    Cell id=1 gnb=2 pci=16:2 tac=200 tdd_cell=on band=n77 nr_arfcn=663400:663400 gscn=8159 chBw=40MHz ssb=663360
    ...    Cell id=2 gnb=2 pci=17:0 tac=200 tdd_cell=on band=n77 nr_arfcn=658000:658000 gscn=8103 chBw=40MHz ssb=657984
    ...    [Configuration for gnb2]:
    ...    Cell id=3 gnb=3 pci=17:1 tac=200 tdd_cell=on band=n77 nr_arfcn=653400:653400 gscn=8060 chBw=40MHz ssb=653856
    ...    Cell id=4 gnb=3 pci=17:2 tac=200 tdd_cell=on band=n77 nr_arfcn=648000:648000 gscn=8000 chBw=40MHz ssb=648096
    ...    Cell id=11 gnb=3 pci=20:0 tac=200 tdd_cell=off band=n3 nr_arfcn=349400:368400 gscn=4605 chBw=10MHz ssb=368430
    ...    Cell id=12 gnb=3 pci=20:1 tac=200 tdd_cell=off band=n28 nr_arfcn=143400:153400 gscn=1916 chBw=20MHz ssb=153370
    ...    gnb 2 cell 11 is pcell in this case , two CA relationships are gnb1 cell1 ,gnb1 cell2
    ...    2.Test Case Steps:
    ...         a. UE1 attach to gnb2 cell11, blind added NRCELL-1 NRCELL-2.
    ...         b. After inactivity timer timeout , A4 have configured for UE.
    ...         c. Trigger A4 MR before a4ReportTimerEnDc timeout , RRC release triggerrd wth a4MeasEnDcSteering
    ...         d. check IEs in RRC release procedure , and check counters.
    [Tags]    GC004    QC_253760
    clear counter files gnb2
    Sa Ue Attach    ue_id=2    enb_id=3    cell_id=11
    Setup pdu session    ue_id=2
    Check GNB1 scells added Successfully    NRCELL-1    NRCELL-2
    wait until keyword succeeds    10s    1s    Trigger A4EnDcSteering
    Release UEs    ue_type=all
    Check Counters in GNB2
    Check WireShark Log GNB2    ${CURDIR}${/}A2A_GC_004${/}a2a_gnb2.ini    wait_string=UEContextReleaseComplete::6
    Check WireShark Log    ${CURDIR}${/}A2A_GC_004${/}a2a_gnb1.ini    wait_string=UEContextReleaseComplete::1
*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup 2Airphone Env    fddtdd_sansa_cmwv/6cells_gnb1_2T_gnb2_2T2F

Modify Cfg
    Update Cfg    ue_param id=1 ue_nr_capabilities=${SA_Capa_Support_3cc_CA}
    Update Cfg    ue_param id=2 ue_nr_capabilities=${SA_Capa_Support_3cc_CA} dual_conn=eutra_nr ue_eutra_nr_capabilities=${UE_Capa_eutra}

ue attach and send Throuput
    [Arguments]    ${ue_id}=1    ${enb_id}=2    ${cell_id}=1
    Sa Ue Attach    ue_id=${ue_id}    enb_id=${enb_id}    cell_id=${cell_id}
    Setup pdu session    ue_id=${ue_id}
    Send Throuput    ue_id=${ue_id}    pdu_id=${ue_id}
    wait until keyword succeeds    2 min    10    Verify Throuput    ue_id=${ue_id}

Sa Ue Attach
    [Arguments]    ${ue_id}=1    ${enb_id}=2    ${cell_id}=2
    ...    ${pass_regexp}=now Registered
    Execute Egate Command    ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    ${pass_regexp}

Setup pdu session
    [Arguments]    ${ue_id}=1
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${ue_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${ue_id} nwslice=1 gw=${ue_id}    pass_regexp=Initial Context Setup Successful

Trigger Redirect
    [Arguments]    ${event_type}=A2    ${carrierfreq}=663360    ${srsrp_nr}=5    ${srsrq_nr}=5    ${ue_id}=1
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type}
    ...    srsrp_nr=${srsrp_nr} srsrq_nr=${srsrq_nr}
    Execute Egate Command    ${cmd}     pass_regexp=Received UE Context Release Complete

Trigger A4EnDcSteering
    [Arguments]    ${event_type}=A4    ${carrierfreq}=2075419    ${nrsrp_nr}=60    ${nrsrq_nr}=30    ${ue_id}=2
    ...    ${phycell_id}=11
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type} phycell_id=${phycell_id}
    ...    nrsrp_nr=${nrsrp_nr} nrsrq_nr=${nrsrq_nr}
    Execute Egate Command    ${cmd}     pass_regexp=@{expect}

Check GNB1 scells added Successfully
    [Arguments]    ${scell1}    ${scell2}
    ${SCELL1_physCellId}    Get Scf Parameter Value    ${scell1}:physCellId
    ${SCELL2_physCellId}    Get Scf Parameter Value    ${scell2}:physCellId
    Rrc Should Contain    sCellToAddModList    physCellId ${SCELL1_physCellId}    physCellId ${SCELL2_physCellId}

Check GNB2 scells added Successfully
    [Arguments]    ${scell1}    ${scell2}
    ${SCELL1_physCellId}    Get Scf Parameter Value gnb2    ${scell1}:physCellId
    ${SCELL2_physCellId}    Get Scf Parameter Value gnb2    ${scell2}:physCellId
    Rrc Should Contain    sCellToAddModList    physCellId ${SCELL1_physCellId}    physCellId ${SCELL2_physCellId}

Send Throuput
    [Arguments]    ${ue_id}=1    ${pdu_id}=1
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=3    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=4    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=5    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=ul mbps=20 trf_id=1    UE ${ue_id}: UDP UL
    sleep    30s    #sleep for stable traffic

Verify Throuput
    [Arguments]    ${ue_id}=1    ${pcell_dl}=60    ${ul}=10    ${scell_id}=0
    sleep    10s     #sleep for stable traffic
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000 > ${pcell_dl}
    ${ul_throughput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pusch    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul}
    ${scell1_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=1    type=pdsch    rate_type=ave
    Should Be True    ${scell1_tput}/1000 > ${pcell_dl}
    ${scell2_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=2    type=pdsch    rate_type=ave
    Should Be True    ${scell2_tput}/1000 > ${pcell_dl}

Check Counters in GNB1
    ${pm_counters}    Create List    NRCELL-1:NRRCC:${NRRCC_RRC_RELEASE_REDIR_NR}=1
    ...    NRCELL-1:NRMOP:${NRMOP_SA_PROFILE_SELECTED_01}=1
    ...    NRCELL-1:NCAC:${IGNB_CA_ATT_SA_REL}=1
    Check Counters    ${pm_counters}

Check Counters in GNB2
    ${pm_counters}    Create List    NRCELL-11:NRRCC:${NRRCC_RRC_RELEASE_IMM_ENDC_LTE}=1
    ...    NRCELL-11:NRMOP:${NRMOP_SA_PROFILE_SELECTED_11}=1
    ...    NRCELL-11:NRRCC:${NRRCC_A4_MEAS_IMM_REC}=1
    ...    NRCELL-11:NCAC:${IGNB_CA_ATT_SA_REL}=1
    Check Counters GNB2    ${pm_counters}    wait=True
