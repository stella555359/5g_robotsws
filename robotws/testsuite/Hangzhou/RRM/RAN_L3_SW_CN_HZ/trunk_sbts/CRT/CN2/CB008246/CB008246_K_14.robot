*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    CRT    CLOUD_5G_I_[LO][LO]_AP_[LOO]_SANSA_FS_ECPRI_CMWV_TDD
...    owner-chunlan.a.yang    team-Beams   CB008246    release-SBTS24R1
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${NOKIA_XNAP_PLUGIN_FLAG}    ${True}
${NOKIA_F1AP_PLUGIN_FLAG}    ${True}
${SYSCOM_FLAG}    ${True}
@{PARAMS_IN_SCF}
...    @{PARAMS_FOR_CA}
...    @{PARAMS_FOR_GNB1}
...    @{PARAMS_ADJ_REL_FOR_GNB1}
...    @{PARAMS_FOR_OTHERS}
...    @{8246}
...    @{5qi3}

@{PARAMS_IN_SCF_GNB2}
...    @{PARAMS_FOR_CA}
...    @{PARAMS_FOR_GNB2}
...    @{PARAMS_ADJ_REL_FOR_GNB2}
...    @{PARAMS_FOR_OTHERS}

@{PARAMS_FOR_CA}
...    NRBTS:actCarrierAggregation=true
...    NRBTS:sCellActivationMethod=blind
...    NRBTS:caConfigurationSupport=4CCDL_2CCUL
...    NRBTS:weightForIgnbCaSelection=20
...    NRBTS:actIncXn=true
...    NRBTS:maxNumScellsDl=2
...    NRBTS:maxNumScellsUl=2
...    NRBTS:actFdmEnhancedScheduling=true
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:carrierAggregationSupportList=ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Any_Sa,ca_Fdd_Any_Sa,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Fdd
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRDU-1:actInterGnbCa=DLOnly
...    NRDU-1:dlToUlContributionRatio=101
...    NRDU-1:xgUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRCELL:actK1Opt=intraAndInter-gNB
...    NRCELL:maxNumOfCaUsersNRCell=250
...    NRCELL:maxNumOfGBRBearersSA=10
...    NRCELL:maxNumOfNonGBRBearersSA=550
...    NRCELL:maxNumOfRrcSA=275
...    NRCELL:maxNumOfSCellAlloc=250
...    NRCELL:maxNumOfUsersPerNRCell=275
...    NRCELL:maxNumOfUsersPerCell=275


@{PARAMS_FOR_GNB1}
...    NRCELL-1:sCellDeactivationTimerGNB=infinity
...    NRCELL-1:actBeamforming=true
...    NRCELL-1:nrCellType=4DL2UL
...    NRCELL-2:sCellDeactivationTimerGNB=infinity
...    NRCELL-2:actBeamforming=true
...    NRCELL-2:nrCellType=4DL2UL
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrInterGnbMobilityNsaPmqap=disabled
...    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrInterGnbNgMobilitySaPmqap=disabled
...    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrInterGnbXnMobilitySaPmqap=disabled
...    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrIntraGnbMobilityNsaPmqap=disabled
...    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrIntraGnbMobilitySaPmqap=disabled
...    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrNgcFlexInterface=disabled
...    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrRelReportCu=disabled

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
...    NRBTS/NRADJNRCELL-3:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-3:fiveGsTac=200
...    NRBTS/NRADJNRCELL-3:freqBandIndicatorNR=77
...    NRBTS/NRADJNRCELL-3:gNbId=2
...    NRBTS/NRADJNRCELL-3:gNbIdLength=22
...    NRBTS/NRADJNRCELL-3:lcrId=3
...    NRBTS/NRADJNRCELL-3:nrarfcn=653400
...    NRBTS/NRADJNRCELL-3:physCellId=52
...    NRBTS/NRADJNRCELL-3:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-3:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-3:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-4:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-4:fiveGsTac=200
...    NRBTS/NRADJNRCELL-4:freqBandIndicatorNR=77
...    NRBTS/NRADJNRCELL-4:gNbId=2
...    NRBTS/NRADJNRCELL-4:gNbIdLength=22
...    NRBTS/NRADJNRCELL-4:lcrId=4
...    NRBTS/NRADJNRCELL-4:nrarfcn=648000
...    NRBTS/NRADJNRCELL-4:physCellId=53
...    NRBTS/NRADJNRCELL-4:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-4:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-4:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-11:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-11:fiveGsTac=200
...    NRBTS/NRADJNRCELL-11:freqBandIndicatorNR=3
...    NRBTS/NRADJNRCELL-11:gNbId=2
...    NRBTS/NRADJNRCELL-11:gNbIdLength=22
...    NRBTS/NRADJNRCELL-11:lcrId=11
...    NRBTS/NRADJNRCELL-11:nrarfcn=368400
...    NRBTS/NRADJNRCELL-11:physCellId=60
...    NRBTS/NRADJNRCELL-11:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-11:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-11:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-12:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-12:fiveGsTac=200
...    NRBTS/NRADJNRCELL-12:freqBandIndicatorNR=28
...    NRBTS/NRADJNRCELL-12:gNbId=2
...    NRBTS/NRADJNRCELL-12:gNbIdLength=22
...    NRBTS/NRADJNRCELL-12:lcrId=12
...    NRBTS/NRADJNRCELL-12:nrarfcn=153400
...    NRBTS/NRADJNRCELL-12:physCellId=61
...    NRBTS/NRADJNRCELL-12:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-12:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-12:gnbPlmn:mncLength=3
...    NRCELL-1:chBw=40MHz
...    NRCELL-1/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-3:gNbId=2
...    NRCELL-1/NRREL-3:gNbIdLength=22
...    NRCELL-1/NRREL-3:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-3:lcrId=3
...    NRCELL-1/NRREL-3:removeNotAllowed=false
...    NRCELL-1/NRREL-3:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-3:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-4:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-4:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-4:gNbId=2
...    NRCELL-1/NRREL-4:gNbIdLength=22
...    NRCELL-1/NRREL-4:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-4:lcrId=4
...    NRCELL-1/NRREL-4:removeNotAllowed=false
...    NRCELL-1/NRREL-4:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-4:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-4:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-4:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-4:sCellOperationalMode=dlOnly

@{PARAMS_FOR_GNB2}
...    NRBTS:iGnbCaXnCfUpBackOffTmr=60
...    NRBTS:iGnbCaXnSetupReqTmr=90
...    NRBTS:iGnbCaXnSetupRespTmr=60
...    NRBTS:intGnbScellTempBlockTmr=60
...    NRCELL-3:chBw=40MHz
...    NRCELL-3:gscnOrSsPbchArfcn=8055
...    NRCELL-3:actBeamforming=true
...    NRCELL-3:nrCellType=4DL2UL
...    NRCELL-4:actBeamforming=true
...    NRCELL-4:nrCellType=4DL2UL
...    NRCELL-3:sCellDeactivationTimerGNB=infinity
...    NRCELL-4:sCellDeactivationTimerGNB=infinity
...    NRCELL-11:sCellDeactivationTimerGNB=infinity
...    NRCELL-12:sCellDeactivationTimerGNB=infinity
...    NRCELL-3:weightForSCellSelection=10
...    NRCELL-4:weightForSCellSelection=10
...    NRCELL-11:weightForSCellSelection=40
...    NRCELL-12:weightForSCellSelection=20
...    MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1
...    MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1
...    NRCELL-3:actLAForHiReliab=true
...    NRCELL-4:actLAForHiReliab=true
...    NRCELL-3:scalingStepdownHREnabled=true
...    NRCELL-4:scalingStepdownHREnabled=true
...    NRCELL-3:pdschHrLaConfig:dllaDeltaCqiStepdownHR=2000
...    NRCELL-3:puschHrLaConfig:ullaDeltaSinrStepdownHR=2000
...    NRCELL-4:pdschHrLaConfig:dllaDeltaCqiStepdownHR=2000
...    NRCELL-4:puschHrLaConfig:ullaDeltaSinrStepdownHR=2000
...    NRBTS/NRDRB-11:nrPdcchHRLaDN=MRBTS-1/NRBTS-2/NRPDCCHHRLA-1
...    NRBTS/NRDRB-11:nrPdschHRLaDN=MRBTS-1/NRBTS-2/NRPDSCHHRLA-2
...    NRBTS/NRDRB-11:nrPuschHRLaDN=MRBTS-1/NRBTS-2/NRPUSCHHRLA-2
...    NRBTS/NRDRB-12:nrPdcchHRLaDN=MRBTS-1/NRBTS-2/NRPDCCHHRLA-1
...    NRBTS/NRDRB-12:nrPdschHRLaDN=MRBTS-1/NRBTS-2/NRPDSCHHRLA-1
...    NRBTS/NRDRB-12:nrPuschHRLaDN=MRBTS-1/NRBTS-2/NRPUSCHHRLA-1
...    NRBTS/NRPDCCHHRLA-1:pdcchHRBlerOutagePercentage=50
...    NRBTS/NRPDSCHHRLA-1:dlHRBlerOutageMcsThresh64qam=1
...    NRBTS/NRPDSCHHRLA-2:dlHRBlerOutageMcsThresh64qam=1
...    NRBTS/NRPUSCHHRLA-1:scalFactorForHRGbrUl=110
...    NRBTS/NRPUSCHHRLA-2:scalFactorForHRGbrUl=110
...    NRBTS/BWP_PROFILE-1/PDCCH-1:dciDedicatedAggregationLevelHR=AL4
...    NRBTS/BWP_PROFILE-2/PDCCH-1:dciDedicatedAggregationLevelHR=AL4

@{PARAMS_ADJ_REL_FOR_GNB2}
...    NRBTS/NRADJGNB-1:administrativeState=Unlocked
...    NRBTS/NRADJGNB-1:gNbIdLength=22
...    NRBTS/NRADJGNB-1:gNodeBId=1
...    NRBTS/NRADJGNB-1:weightForIgnbCaSelection=50
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

@{PARAMS_FOR_OTHERS}


...    NRBTS:actRanSharing=false
...    NRCELL:actCDrx=false

@{8246}
...    NRBTS/BWP_PROFILE-2/PDCCH-1:dciDedicatedAggregationLevelHR=AL4
...    NRBTS/BWP_PROFILE-4/PDCCH-1:dciDedicatedAggregationLevelHR=AL4
...    NRCELL-1:pdschHrLaConfig:dllaDeltaCqiStepdownHR=2000
...    NRCELL-1:puschHrLaConfig:ullaDeltaSinrStepdownHR=2000
...    NRCELL-1:actLAForHiReliab=true
...    NRCELL-1:scalingStepdownHREnabled=true
...    NRBTS/NRDRB-11:nrPdcchHRLaDN=MRBTS-1/NRBTS-1/NRPDCCHHRLA-1
...    NRBTS/NRDRB-11:nrPdschHRLaDN=MRBTS-1/NRBTS-1/NRPDSCHHRLA-2
...    NRBTS/NRDRB-11:nrPuschHRLaDN=MRBTS-1/NRBTS-1/NRPUSCHHRLA-2
...    NRBTS/NRDRB-12:nrPdcchHRLaDN=MRBTS-1/NRBTS-1/NRPDCCHHRLA-1
...    NRBTS/NRDRB-12:nrPdschHRLaDN=MRBTS-1/NRBTS-1/NRPDSCHHRLA-1
...    NRBTS/NRDRB-12:nrPuschHRLaDN=MRBTS-1/NRBTS-1/NRPUSCHHRLA-1
...    NRBTS/NRPDCCHHRLA-1:pdcchHRBlerOutagePercentage=50
...    NRBTS/NRPDSCHHRLA-1:dlHRBlerOutageMcsThresh64qam=1
...    NRBTS/NRPDSCHHRLA-2:dlHRBlerOutageMcsThresh64qam=1
...    NRBTS/NRPUSCHHRLA-1:scalFactorForHRGbrUl=110
...    NRBTS/NRPUSCHHRLA-2:scalFactorForHRGbrUl=110

@{5qi3}
...    NRBTS:actAdditionalSliceSupport=true
...    NRCELL-1:actGBRAdmissionControl=GBRService
...    NRCELL-1:actNonVoNRGbrService=true
...    NRBTS/NRDRB-16:discardTimer=100ms
...    NRBTS/NRDRB-16:discardTimerUl=infinity
...    NRBTS/NRDRB-16:drbInactivityTimerSA=10
...    NRBTS/NRDRB-16:dscp=46
...    NRBTS/NRDRB-16:dtxDelaySinceLastScheduling=0
...    NRBTS/NRDRB-16:dtxMaxRetentionDelay=10
...    NRBTS/NRDRB-16:l2OHFactorDl=16
...    NRBTS/NRDRB-16:l2OHFactorUl=35
...    NRBTS/NRDRB-16:maxDataRateGbrDl=30720
...    NRBTS/NRDRB-16:maxDataRateGbrUl=30720
...    NRBTS/NRDRB-16:maxForwardTimeLimitX2=50
...    NRBTS/NRDRB-16:maxRlcQueueingDelayGbr=20
...    NRBTS/NRDRB-16:maxTransferDelayGbr=20
...    NRBTS/NRDRB-16:minForwardTputX2=100
...    NRBTS/NRDRB-16:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-5
...    NRBTS/NRDRB-16:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-3
...    NRBTS/NRDRB-16:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRBTS/NRDRB-16:nrPdcchHRLaDN=MRBTS-1/NRBTS-1/NRPDCCHHRLA-1
...    NRBTS/NRDRB-16:nrPdschHRLaDN=MRBTS-1/NRBTS-1/NRPDSCHHRLA-1
...    NRBTS/NRDRB-16:nrPuschHRLaDN=MRBTS-1/NRBTS-1/NRPUSCHHRLA-1
...    NRBTS/NRDRB-16:pdcpStatRepWaitTimer=40
...    NRBTS/NRDRB-16:pdcpStatRepWaitTimerOffset=60
...    NRBTS/NRDRB-16:queuingDelayDiscarding=Disabled
...    NRBTS/NRDRB-16:resType=GBR
...    NRBTS/NRDRB-16:rlcMode=RLC_UM
...    NRBTS/NRDRB-16:cellAggrLevel=FR1 CA incompatible
...    NRBTS/NRDRB-16:nrDrbRlcAmDN=${EMPTY}
...    NRBTS/NRDRB-16:nsaDrbParam=${EMPTY}
...    NRBTS/NRDRB_5QI-7:fiveqiValueList=3
...    NRBTS/NRDRB_5QI-7:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-16
...    NRBTS/NRDRB_MAC-3:delayTarget=50
...    NRBTS/NRDRB_MAC-5:delayTarget=50
...    NRBTS/NRDRB_MAC-5:lcgid=5
...    NRBTS/NRDRB_MAC-5:schedulBSD=100ms

${SA_Capa_Support_3CC_n77_3A_CA}    SEPARATOR=
...    EDA09000575F5A13160003C320016093170019C3D09009B26C39F30C7942C0E088040623809DC2C06C0D608C21A08107482406D6C98AB1A1C
...    F88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE00098000702A05805AC1184341020F10480CAD931562439F604F88
...    E3C62471E439F51CF9863CA1607038784FEC000003FB000000260001C0AA16266B04610D04083A412030B64C55110E7C471E238F40CFB027C
...    639F30C7942C0E070F05C00FFC007003FF0004C000381502C1BD608C21A0810788240656C98AB121CF88E3D813E31238F21CFA8E7CC31E50B
...    0381C3C27FFC00001FFF00000130000E0550B13758230868000010090185B24CA88873E238F20C7A067D813E01CF9863CA1607038782F5555
...    5553D5555554260001C012587898001C4C000000160562E2600071300038980000042C0AC5C02000C260184C0001058158F80400181B03098
...    061300006160562E0100060080C0D800102C0AC7C02000C030181B0309A00050B02B1700800303606130000C160561E010006130000E16056
...    1E0100060080010160561E0D800606C0012160561E0100060180014160561E03000606C0016160562E0100060180C0D800302C0AC3C1B000E
...    2600000D0B02B1713000309806008001C160563E2600061300C010181B0007858158B8980018020303600100B02B1F134003004060180C0D8
...    00442C08048037001A0264002809A1E81D212851226C73E1C4891226C73E1C4891226C73E1C68912244D8E7C38912244D8E7C38D1224489B1
...    CF871224489B1CF870A244D8E7C3851226C73E1C28913639F0E14489B1CF870A244D8E7C38912244D8E7C3851226C73E1C4891226C73E1C68
...    912244D8E7C38912244D8E7C38D1224489B1CF8603624318C6318C6318C6318C63183D04C00F000A070500703009401C0018090010180A000
...    000000090020060F8240080000000400200000008000030040000080200000801000006008000040040000280200100401004000030020000
...    1C010008000000200002001000012008000030040000500200002C01000812048020000300CC54A2A502880C40CA05514B899C02A03500880
...    840E81A0800004B29282000032CA4C080000CB29202000072CA480800024B292020000B2CA4C0800034B292020000F2CA480800044B292020
...    00132CA480800054B29202000172CA4A0800064B29202000062CA48066155615521546154202C202C2034214C2134200C20142135203C0480
...    BC04A8140A05028140A05028140A05028140A05028140A0022101002004040080110080100202004008080100220100C01404008010100200
...    4602018028080600A02004008080100220101001404040050101602C602018030080600A02018030080100220100C01404030050100200420
...    2018028080100210100C014040300508080600C02018030404030060100C014202018028080600A20100C01404030060100C0142020180300
...    80100220100200404008010100C014602004008080100202018028080600A20100200404030060100C018602004008080600A020180300806
...    00A3543E00020406080C0E1416181A2022242628303236383A3E424A4C4E5052545A5E828305A0

*** Test Cases ***
CB008246_K14_SA_Inter-gNB_Scell_Addition_FAF_Activated_Pcell_Activated_Scell_After_GBR_HRDRB_And_nonGBR_BRDRB_Setup_Alt13
    [Documentation]
    [Tags]    QC_324087    chunlan.a.yang@nokia-sbell.com
    Clear Counter Files for 2GNB
    UE Attach To Target Cell via ICS    ue_id=1    cell_id=1
    Send And Verify Throuput GBR     ue_id=1    qfi_id=2      sleep_time=10s
    Smf Param Reset After case finished
    PDU Session Setup    ue_id=1
    UE Attach To Target Cell via ICS2    ue_id=2    cell_id=1
    UE Deregister From gNB    ue_id=1
    UE Deregister From gNB    ue_id=2
    Check Wireshark Log    ${CURDIR}${/}a2a_CB008246_K_14${/}a2a.ini    wait_string=sCellNrCellIdentity::8

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup 2Airphone Env    fddtdd_sansa_cmwv/6cells_gnb1_2T_gnb2_2T2F

Modify Cfg
    Update Cfg    ue_param id=1 ue_nr_capabilities=${SA_Capa_Support_3CC_n77_3A_CA}
    Update Cfg    ue_param id=2 ue_nr_capabilities=${SA_Capa_Support_3CC_n77_3A_CA}
    Delete Cfg    set_qosflow id=1 5qi=6 default=on
    Update Cfg    set_qosflow id=1 5qi=1
    Update Cfg    set_qosflow id=2 5qi=2 gfbr_ul=30720 gfbr_dl=30720 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    Update Cfg    set_qosflow id=3 5qi=3 gfbr_ul=30720 gfbr_dl=30720 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    Update Cfg    set_qosflow id=4 5qi=4 gfbr_ul=4000 gfbr_dl=10000 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    Update Cfg    set_qosflow id=5 5qi=5
    Update Cfg    set_qosflow id=6 5qi=6 default=on
    Update Cfg    set_qosflow id=7 5qi=7
    Update Cfg    set_qosflow id=8 5qi=8
    ${set_cell3_gscn}    catenate
    ...    set_cell id=3 gnb=3 pci=17:1 tac=200 nrci=0x03 tdd_cell=on proxy=$PROXY_SERVER_IP:9999|$PROXY_SERVER_IP:8888 nr_arfcn=653400:653400
    ...    mandatory_for_activation=off gscn=8055
    Update Cfg    ${set_cell3_gscn}

UE Attach To Target Cell via ICS
    [Arguments]    ${ue_id}    ${cell_id}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    qosflow_modify default=on qos_flow=8 priority=1
    Execute Egate Command    smf_param id=1 additional_qosflows_to_activate=3
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1    QoS Routing Table

UE Attach To Target Cell via ICS2
    [Arguments]    ${ue_id}    ${cell_id}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    qosflow_modify default=on qos_flow=6 priority=1
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1    QoS Routing Table

Send And Verify Throuput GBR
    [Arguments]    ${ue_id}    ${qfi_id}    ${sleep_time}
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=${qfi_id} dir=dl mbps=80 trf_id=1    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=${qfi_id} dir=dl mbps=80 trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=${qfi_id} dir=ul mbps=10    UE ${ue_id}: UDP UL
    sleep    10s    wait for data send
    Verify Throuput on Pscell and Scell GBR    ue_id=${ue_id}    qfi_id=${qfi_id}

Verify Throuput on Pscell and Scell GBR
    [Arguments]    ${ue_id}      ${qfi_id}
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000>10
    ${scell1_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=1    type=pdsch    rate_type=ave
    Should Be True    ${scell1_tput}/1000==0
    ${scell2_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=2    type=pdsch    rate_type=ave
    Should Be True    ${scell2_tput}/1000==0
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=${qfi_id}    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=${qfi_id}    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput}/1000>120
    Should Be True    ${ul_throughput}/1000>9

Clear Counter Files for 2GNB
    Clear Counter Files    ${False}
    Clear Counter Files GNB2

UE Deregister From gNB
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s

PDU Session Setup
    [Arguments]    ${ue_id}
    Execute Egate Command    qosflow_modify default=on qos_flow=6 priority=1
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=2 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=2 gw=2 nwslice=1    QoS Routing Table

Smf Param Reset After case finished
    Execute Egate Command    smf_param id=1 reset
