*** Settings ***
Documentation
...    author:  baijie.zhu@nokia-sbell.com
...    contact: baijie.zhu@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_VRF    SBTS00    RAN_5G    CLOUD_5G_I_[LO][LO]_AP_[LOOO]    team-L3CN1_SG14
...    owner-ye.3.ye    release-SBTS23R4    CRT    RAN_5G_FDD    RAN_5G_TDD
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${NOKIA_XNAP_PLUGIN_FLAG}    ${True}
${NOKIA_F1AP_PLUGIN_FLAG}    ${True}

@{PARAMS_IN_SCF}
...    @{PARAMS_FOR_CA}
...    @{PARAMS_FOR_GNB1}
...    @{PARAMS_ADJ_REL_FOR_GNB1}
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
...    NRBTS:weightForIgnbCaSelection=80
...    NRBTS:actIncXn=true
...    NRBTS:actFdmEnhancedScheduling=true
...    NRBTS:iGnbCaXnRemovalTmr=10
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:carrierAggregationSupportList=ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Any_Sa,ca_Fdd_Any_Sa,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Fdd
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRDU-1:actInterGnbCa=DLOnly
...    NRDU-1:dlToUlContributionRatio=101
...    NRDU-1:numOfDrbsReservForTempUse=120

@{PARAMS_FOR_GNB1}
...    NRCELL-11:sCellDeactivationTimerGNB=infinity
...    NRCELL-12:sCellDeactivationTimerGNB=infinity
...    NRBTS:iGnbCaXnCfUpBackOffTmr=60
...    NRBTS:iGnbCaXnSetupReqTmr=60
...    NRBTS:iGnbCaXnSetupRespTmr=60
...    NRBTS:intGnbScellTempBlockTmr=60
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRCELL-11:iniNumSCellsToActivate=3
...    NRCELL-11:actARPBasedAC=on
...    NRBTS:actUserPreemption=true
...    NRBTS:actDrbPreemption=true
...    NRBTS:actRedirect=true
...    NRCELL-11/NRREDRT-0:redirFreqEutra=39750
...    NRCELL-11/NRREDRT-0:redirRat=eutra
...    delete:NRCELL-11/NRREDRT-0:redirSsbScs
...    NRCELL-11:allowEmergencyReservForTempUse=false
...    NRCELL-11:numOfRadioResReservForTempUse=2
...    NRCELL-11:preferNsaPreemption=false
...    NRCELL-11:maxNumOfRrcSA=5
...    NRCELL-11:maxNumOfNonGBRBearersSA=2
...    NRCELLGRP-1:maxNumOfNonGBRBearersCGRPSA=3
...    NRBTS:maxNumOfPreemptions=2
...    NRCELL-11:a1MeasSCellAddEnabled=rsrp
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=31
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=111
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-12:allowEmergencyReservForTempUse=false
...    NRCELL-12:numOfRadioResReservForTempUse=2
...    NRCELL-12:preferNsaPreemption=false
#...    NRBTS/SNSSAI-2:sd=13714342
#...    NRBTS/SNSSAI-2:administrativeState=Unlocked
#...    NRBTS/SNSSAI-2:sst=1
#...    NRBTS/SNSSAI-2:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
#...    NRBTS/SNSSAI-3:sd=13714343
#...    NRBTS/SNSSAI-3:administrativeState=Unlocked
#...    NRBTS/SNSSAI-3:sst=1
#...    NRBTS/SNSSAI-3:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
#...    NRBTS/TRACKINGAREA-200:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1,MRBTS-1/NRBTS-1/SNSSAI-2,MRBTS-1/NRBTS-1/SNSSAI-3
...    NRDU-1:xgUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRCELL:actK1Opt=intraAndInter-gNB
...    NRBTS:thpTimeCalc=enabled
...    NRBTS:actIpThpt=true
...    NRBTS:actThpDist=true
...    NRBTS:actNrpmqapProfiles=true
...    NRPMRNL-1/NRPMQAP-1:cfg5qiRange=6
...    NRPMRNL-1/NRPMQAP-1:cfgArpRange=15
...    NRPMRNL-1/NRPMQAP-1:cfgProfType=both
...    NRPMRNL-1/NRPMQAP-1:nrPmqapId=1
...    NRPMRNL-1/NRPMQAP-1:thpHistDownlinkMaxRange=1000000
...    NRPMRNL-1/NRPMQAP-1:thpHistDownlinkMinRange=100
...    NRPMRNL-1/NRPMQAP-1:thpHistScale=linear
...    NRPMRNL-1/NRPMQAP-1:thpHistUplinkMaxRange=100000
...    NRPMRNL-1/NRPMQAP-1:thpHistUplinkMinRange=100
...    NRPMRNL-1/NRPMQAP-1:cfgSliceId:sd=13714341
...    NRPMRNL-1/NRPMQAP-1:cfgSliceId:sst=1
...    NRPMRNL-1/NRPMQAP-2:cfg5qiRange=7
...    NRPMRNL-1/NRPMQAP-2:cfgArpRange=12
...    NRPMRNL-1/NRPMQAP-2:cfgProfType=both
...    NRPMRNL-1/NRPMQAP-2:nrPmqapId=1
...    NRPMRNL-1/NRPMQAP-2:thpHistDownlinkMaxRange=1000000
...    NRPMRNL-1/NRPMQAP-2:thpHistDownlinkMinRange=100
...    NRPMRNL-1/NRPMQAP-2:thpHistScale=linear
...    NRPMRNL-1/NRPMQAP-2:thpHistUplinkMaxRange=100000
...    NRPMRNL-1/NRPMQAP-2:thpHistUplinkMinRange=100
...    NRPMRNL-1/NRPMQAP-2:cfgSliceId:sd=13714342
...    NRPMRNL-1/NRPMQAP-2:cfgSliceId:sst=1
...    NRPMRNL-1/NRPMQAP-3:cfg5qiRange=8
...    NRPMRNL-1/NRPMQAP-3:cfgArpRange=11
...    NRPMRNL-1/NRPMQAP-3:cfgProfType=both
...    NRPMRNL-1/NRPMQAP-3:nrPmqapId=1
...    NRPMRNL-1/NRPMQAP-3:thpHistDownlinkMaxRange=1000000
...    NRPMRNL-1/NRPMQAP-3:thpHistDownlinkMinRange=100
...    NRPMRNL-1/NRPMQAP-3:thpHistScale=linear
...    NRPMRNL-1/NRPMQAP-3:thpHistUplinkMaxRange=100000
...    NRPMRNL-1/NRPMQAP-3:thpHistUplinkMinRange=100
...    NRPMRNL-1/NRPMQAP-3:cfgSliceId:sd=13714343
...    NRPMRNL-1/NRPMQAP-3:cfgSliceId:sst=1
...    @{SNSSAI_1}
...    @{TRACKINGAREA}
...    ${NRPLMNDNLIST_1}


@{PARAMS_ADJ_REL_FOR_GNB1}
...    NRBTS/NRADJGNB-2:administrativeState=Unlocked
...    NRBTS/NRADJGNB-2:gNbIdLength=22
...    NRBTS/NRADJGNB-2:gNodeBId=2
...    NRBTS/NRADJGNB-2:weightForIgnbCaSelection=40
...    NRBTS/NRADJGNB-2:xnLinkRef=1
...    NRBTS/NRADJGNB-2:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-2:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-2:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-1:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-1:fiveGsTac=200
...    NRBTS/NRADJNRCELL-1:freqBandIndicatorNR=77
...    NRBTS/NRADJNRCELL-1:gNbId=2
...    NRBTS/NRADJNRCELL-1:gNbIdLength=22
...    NRBTS/NRADJNRCELL-1:lcrId=1
...    NRBTS/NRADJNRCELL-1:nrarfcn=656094
...    NRBTS/NRADJNRCELL-1:physCellId=50
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-2:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-2:fiveGsTac=200
...    NRBTS/NRADJNRCELL-2:freqBandIndicatorNR=77
...    NRBTS/NRADJNRCELL-2:gNbId=2
...    NRBTS/NRADJNRCELL-2:gNbIdLength=22
...    NRBTS/NRADJNRCELL-2:lcrId=2
...    NRBTS/NRADJNRCELL-2:nrarfcn=658000
...    NRBTS/NRADJNRCELL-2:physCellId=51
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-13:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-13:fiveGsTac=200
...    NRBTS/NRADJNRCELL-13:freqBandIndicatorNR=3
...    NRBTS/NRADJNRCELL-13:gNbId=2
...    NRBTS/NRADJNRCELL-13:gNbIdLength=22
...    NRBTS/NRADJNRCELL-13:lcrId=13
...    NRBTS/NRADJNRCELL-13:nrarfcn=368400
...    NRBTS/NRADJNRCELL-13:physCellId=62
...    NRBTS/NRADJNRCELL-13:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-13:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-13:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-14:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-14:fiveGsTac=200
...    NRBTS/NRADJNRCELL-14:freqBandIndicatorNR=28
...    NRBTS/NRADJNRCELL-14:gNbId=2
...    NRBTS/NRADJNRCELL-14:gNbIdLength=22
...    NRBTS/NRADJNRCELL-14:lcrId=14
...    NRBTS/NRADJNRCELL-14:nrarfcn=153400
...    NRBTS/NRADJNRCELL-14:physCellId=63
...    NRBTS/NRADJNRCELL-14:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-14:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-14:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-1:gNbId=2
...    NRCELL-11/NRREL-1:gNbIdLength=22
...    NRCELL-11/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-1:lcrId=1
...    NRCELL-11/NRREL-1:removeNotAllowed=false
...    NRCELL-11/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-2:gNbId=2
...    NRCELL-11/NRREL-2:gNbIdLength=22
...    NRCELL-11/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-2:lcrId=2
...    NRCELL-11/NRREL-2:removeNotAllowed=false
...    NRCELL-11/NRREL-2:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-13:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-13:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-13:gNbId=2
...    NRCELL-11/NRREL-13:gNbIdLength=22
...    NRCELL-11/NRREL-13:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-13:lcrId=13
...    NRCELL-11/NRREL-13:removeNotAllowed=false
...    NRCELL-11/NRREL-13:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-13:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-13:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-13:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-13:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-14:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-14:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-14:gNbId=2
...    NRCELL-11/NRREL-14:gNbIdLength=22
...    NRCELL-11/NRREL-14:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-14:lcrId=14
...    NRCELL-11/NRREL-14:removeNotAllowed=false
...    NRCELL-11/NRREL-14:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-14:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-14:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-14:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-14:gnbPlmn:mncLength=3

@{PARAMS_FOR_GNB2}
...    NRBTS:iGnbCaXnCfUpBackOffTmr=60
...    NRBTS:iGnbCaXnSetupReqTmr=60
...    NRBTS:iGnbCaXnSetupRespTmr=60
...    NRBTS:intGnbScellTempBlockTmr=60
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRCELL-1:gscnOrSsPbchArfcn=8062
...    NRCELL-1:nrarfcn=656094
...    NRCELL-1:sCellDeactivationTimerGNB=infinity
...    NRCELL-1:nrCellType=4DL4UL
...    NRCELL-1:dlMimoMode=4x4 or 4x2 Closed Loop Spatial Multiplexing
...    NRCELL-2:sCellDeactivationTimerGNB=infinity
...    NRCELL-2:nrCellType=4DL4UL
...    NRCELL-2:dlMimoMode=4x4 or 4x2 Closed Loop Spatial Multiplexing
...    NRCELL-13:sCellDeactivationTimerGNB=infinity
...    NRCELL-14:sCellDeactivationTimerGNB=infinity
...    NRCELL-1:actBeamforming=true
...    NRCELL-2:actBeamforming=true
...    NRCELL:a2MeasSCellRelEnabled=rsrp
...    NRCELL-1:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0
...    NRCELL-1:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=34
...    NRCELL-1:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-2:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0
...    NRCELL-2:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=34
...    NRCELL-2:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-13:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0
...    NRCELL-13:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=35
...    NRCELL-13:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-14:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0
...    NRCELL-14:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=35
...    NRCELL-14:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=40ms
...    NRCELL-13:maxNumOfUsersPerNRCell=1
...    NRCELL-13:maxNumOfCaUsersNRCell=1
...    NRCELL-13:maxNumOfSCellAlloc=1
...    NRCELL-13:maxNumOfUsersPerCell=1
...    NRCELL-13:maxNumOfRrcSA=1
...    NRCELL-13:maxNumOfNrDcSnUsers=1
...    NRCELL-1:weightForSCellSelection=5
...    NRCELL-2:weightForSCellSelection=5
...    NRCELL-13:weightForSCellSelection=80
...    NRCELL-14:weightForSCellSelection=60
#...    NRBTS/SNSSAI-2:sd=13714342
#...    NRBTS/SNSSAI-2:administrativeState=Unlocked
#...    NRBTS/SNSSAI-2:sst=1
#...    NRBTS/SNSSAI-2:nrPlmnDNList=MRBTS-2/NRBTS-2/NRPLMN-1
#...    NRBTS/SNSSAI-3:sd=13714343
#...    NRBTS/SNSSAI-3:administrativeState=Unlocked
#...    NRBTS/SNSSAI-3:sst=1
#...    NRBTS/SNSSAI-3:nrPlmnDNList=MRBTS-2/NRBTS-2/NRPLMN-1
#...    NRBTS/TRACKINGAREA-200:snssaiDNList=MRBTS-2/NRBTS-2/SNSSAI-1,MRBTS-2/NRBTS-2/SNSSAI-2,MRBTS-2/NRBTS-2/SNSSAI-3
...    NRDU-1:xgUplane:ipV4AddressDN1=MRBTS-2/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRCELL:actK1Opt=intraAndInter-gNB
...    @{SNSSAI_2}
...    @{TRACKINGAREA}
...    ${NRPLMNDNLIST_2}
...    @{LOLO_AP_LOO}

@{SNSSAI_1}
...    SNSSAI-2:sst=1
...    SNSSAI-2:sd=13714342
...    SNSSAI-2:nrPlmnDNList=${NRPLMNDNLIST_1}
...    SNSSAI-3:sst=1
...    SNSSAI-3:sd=13714343
...    SNSSAI-3:nrPlmnDNList=${NRPLMNDNLIST_1}

@{SNSSAI_2}
...    SNSSAI-2:sst=1
...    SNSSAI-2:sd=13714342
...    SNSSAI-2:nrPlmnDNList=${NRPLMNDNLIST_2}
...    SNSSAI-3:sst=1
...    SNSSAI-3:sd=13714343
...    SNSSAI-3:nrPlmnDNList=${NRPLMNDNLIST_2}

@{TRACKINGAREA}
...    TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-1|snssaiDN=SNSSAI-1
...    TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-2|snssaiDN=SNSSAI-2
...    TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-3|snssaiDN=SNSSAI-3

${NRPLMNDNLIST_1}    MRBTS-1/NRBTS-1/NRPLMN-1

${NRPLMNDNLIST_2}    MRBTS-2/NRBTS-2/NRPLMN-1

@{LOLO_AP_LOO}
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-2/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-6:direction=RX
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-2/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-7:direction=TX
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-7:resourceDN=MRBTS-2/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-8:direction=RX
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-8:resourceDN=MRBTS-2/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-2/EQM-1/APEQM-1/RMOD-4/PHYANT-1
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-6:direction=RX
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-2/EQM-1/APEQM-1/RMOD-4/PHYANT-1
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-7:direction=TX
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-7:resourceDN=MRBTS-2/EQM-1/APEQM-1/RMOD-4/PHYANT-1
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-8:direction=RX
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-8:resourceDN=MRBTS-2/EQM-1/APEQM-1/RMOD-4/PHYANT-1
...    NRCELL-1:beamSet:basicBeamSet=beamSet_2
...    NRCELLGRP-0:numberOfTransmittedSsBlocks=2 beams
...    NRCELL-2:beamSet:basicBeamSet=beamSet_2
...    NRCELLGRP-1:numberOfTransmittedSsBlocks=2 beams
...    NRCELL-1:numberOfRxBeamforming=4Rx
...    NRCELL-2:numberOfRxBeamforming=4Rx

@{PARAMS_ADJ_REL_FOR_GNB2}
...    NRBTS/NRADJGNB-1:administrativeState=Unlocked
...    NRBTS/NRADJGNB-1:gNbIdLength=22
...    NRBTS/NRADJGNB-1:gNodeBId=1
...    NRBTS/NRADJGNB-1:weightForIgnbCaSelection=40
...    NRBTS/NRADJGNB-1:xnLinkRef=1
...    NRBTS/NRADJGNB-1:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-1:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-11:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-11:fiveGsTac=200
...    NRBTS/NRADJNRCELL-11:freqBandIndicatorNR=3
...    NRBTS/NRADJNRCELL-11:gNbId=1
...    NRBTS/NRADJNRCELL-11:gNbIdLength=22
...    NRBTS/NRADJNRCELL-11:lcrId=11
...    NRBTS/NRADJNRCELL-11:nrarfcn=364000
...    NRBTS/NRADJNRCELL-11:physCellId=60
...    NRBTS/NRADJNRCELL-11:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-11:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-11:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-12:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-12:fiveGsTac=200
...    NRBTS/NRADJNRCELL-12:freqBandIndicatorNR=3
...    NRBTS/NRADJNRCELL-12:gNbId=1
...    NRBTS/NRADJNRCELL-12:gNbIdLength=22
...    NRBTS/NRADJNRCELL-12:lcrId=12
...    NRBTS/NRADJNRCELL-12:nrarfcn=374000
...    NRBTS/NRADJNRCELL-12:physCellId=61
...    NRBTS/NRADJNRCELL-12:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-12:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-12:gnbPlmn:mncLength=3
@{PARAMS_FOR_OTHERS}


...    NRBTS:actRanSharing=false
...    NRCELL:actCDrx=false

@{Ue1activatedSuccessfullyAirphoneCheck}
...    pcid:62, scellIdx:1
...    pcid:63, scellIdx:2
...    SCellIndex 2 activated successfully at airphone
...    SCellIndex 1 activated successfully at airphone

@{unexpect_check}    sCellIndex3

@{Ue2activatedSuccessfullyAirphoneCheck}
...    pcid:50, scellIdx:1
...    pcid:63, scellIdx:2
...    SCellIndex 2 activated successfully at airphone
...    SCellIndex 1 activated successfully at airphone

@{UE2PDU2sessionCheck}
...    redirectedCarrierInfo eutra
...    eutraFrequency 39750
...    deprioritisationTimer min5
...    UE1: IS IDLE
...    UE-2 PDU SESSION ID-2 setup/reestablishment complete
...    QoS Routing Table

@{activatedSuccessfullyAndUE2IDLECheck}
...    UE2: IS IDLE
...    pcid:62, scellIdx:1
...    pcid:63, scellIdx:2
...    SCellIndex 2 activated successfully at airphone
...    SCellIndex 1 activated successfully at airphone

${IGNB_CA_ATT_SA_REL}    M55118C11008

@{Counters_Check_priGNB}
...    NRCELL-11:NCAC:${IGNB_CA_ATT_SA_REL}=3

${SA_Capa_Support_3CC_n77_3A_CA}    SEPARATOR=
...    E9A09000575F5A13160003C4A0002C1262E003387A16009B20C39F30C7942C0E0980C0311C04EE3603606B04610D04083A41E006D6C98AB1A1CF88E3D033EC09F1891C790E7D4
...    73E618F28581C0E1E0BFFFFF800FFF8BE000C80000E0541B00B582308682041E20F0032B64A55890E7D813E238F1891C790E7D473E618F28581C0E1E13FB000000FEC000000C8
...    0000E0551B133582308682041D20F0030B64A55110E7C471E238F40CFB027C639F30C7942C0E070F05C00FFC007003FF000640000702A0D837AC1184341020F10780195B252AC
...    4873E238F604F8C48E3C873EA39F30C7942C0E070F09FFF000007FFC00000640000702A8D89BAC1184340000080780185B24CA88873E238F20C7A067D813E01CF9863CA160703
...    8782F55555553D555555432000038028B0F1300038980000002C0AC5C4C000E26000713000000858158B80400184C0309800020B02B1F008003036061300C260000C2C0AC5C02
...    000C010181B0002058158F8040018060303606134000A161758B80400181B0309800060B02B0F00800309800070B02B0F00800300400080B02B0F06C00303600090B02B0F0080
...    0300C000A0B02B0F018003036000B0B02B1700800300C0606C0018160561E0D800713000006858158B89800184C03004000E0B02B1F130003098060080C0D8003C2C0AC5C4C00
...    0C010181B0008058158F89A0018020300C0606C0022160561E26800700810009058158F80400181B0309A0613400261617009006E003404C8005013465002020614851226C73E
...    1C4891226C73E1C4891226C73E1C68912244D8E7C38912244D8E7C38D1224489B1CF871224489B1CF870A244D8E7C3851226C73E1C28913639F0E14489B1CF870A244D8E7C389
...    12244D8E7C3851226C73E1C4891226C73E1C68912244D8E7C38912244D8E7C38D1224489B1CF870A244D8E7C38D1224489B1CF8603A28318C6318C6318C6318C6318C63D06C00
...    3C00281C1401C0C02500700060240040603E09002000000010008000000200000C0100000200800002004000018020000100100000A008004010040100000C008000070040020
...    0000008000080040000480200000C010000140080000B004002048120080000C0339535953582958195833582B594B7833780B581B58095811583B40D04000025949410000196
...    5260400006594901000039652404000125949010000596526040001A594901000079652404000225949010000996524040002A5949010000B9652504000325949010000316524
...    0334AAAE955552A8BA55154162A82C55068AA531549A2A80C55028AA4D5541E286802F012A05028140A05028140A05028140A05028140A0502800984040080101002004402004
...    0080801002020040088040300501002004040080118080600A020180280801002020040088040400501010014040580B18080600C02018028080600C02004008804030050100C
...    014040080108080600A02004008404030050100C014202018030080600C10100C018040300508080600A02018028804030050100C018040300508080600C02004008804008010
...    1002004040300518080100202004008080600A02018028804008010100C018040300618080100202018028080600C020180284040080101024014602018028080600C02004008
...    08010023543E00020406080C0E1416181A2022242628303236383A3E424A4C4E5052545A5E828305A

*** Test Cases ***
CB008140_ET_GF002_Verify_IgNB-CA_DRB_been_preempted_and_release_with_redirect_to_LTE
    [Documentation]
    ...    1. The purpose of this test case is to check following scenarios:
    ...    SA UE Context with inter-gNB SCell is preempted,RRC Release with redirection to LTE.
    ...    Requirement Coverage:
    ...    5G_RAN_USR_RRM_18331, fully covered
    ...    It is about CB008140-GF#B2: Resource preemption for SA higher priority request (SA UE Context with inter-gNB SCell is pre-empted,
    ...    RRC Release with redirection) (interaction with CB008698)
    ...    [Configuration]:
    ...    Cell id=11 gnb=2 pci=20:0 tac=200 tdd_cell=off band=n3 nr_arfcn=345000:364000 gscn=4547 chBw=15MHz
    ...    Cell id=12 gnb=2 pci=20:1 tac=200 tdd_cell=off band=n3 nr_arfcn=355000:374000 gscn=4675 chBw=15MHz
    ...    Cell id=1 gnb=3 pci=16:2 tac=200 tdd_cell=on band=n77 nr_arfcn=656094:656094 gscn=8062 chBw=100MHz weightForSCellSelection=5
    ...    Cell id=2 gnb=3 pci=17:0 tac=200 tdd_cell=on band=n77 nr_arfcn=658000:658000 gscn=8103 chBw=40MHz weightForSCellSelection=5
    ...    Cell id=13 gnb=3 pci=20:2 tac=200 tdd_cell=off band=n3 nr_arfcn=349400:368400 gscn=4605 chBw=10MHz weightForSCellSelection=80
    ...    Cell id=14 gnb=3 pci=21:0 tac=200 tdd_cell=off band=n28 nr_arfcn=143400:153400 gscn=1916 chBw=15MHz weightForSCellSelection=60
    ...    2.Test Case Steps:
    ...         Step a. UE1 Register And PDU Session Setup On Cell1_11 with 5QI6
    ...         Step b. UE1 Start Traffic and Verify Throughput
    ...         Step c. UE2 Register And PDU Session Setup On Cell1_11 with 5QI6
    ...         Step d. Ue2 PDU2 Session Setup with 5QI7
    ...         Step e. Stop PDU and release UE1
    ...         Step f. Ue1 re-attach and PDU Session Setup With 5QI8
    ...         Step g. PM counter and wireshark logs check
    ...    3. Expected Results:
    ...         Step a: UE1 Register And PDU Session Setup Successful with scell cell2_13 and cell2_14
    ...         Step b: UE1 Start Traffic and Verify Throughput is OK
    ...         Step c: UE2 Register And PDU Session Setup Successful with scell cell2_1 and cell2_14
    ...         Step d: UE2 PDU Session Setup Successful and UE1 is IDLE
    ...         Step e: PDU and UE1 deregister successfully
    ...         Step f: Ue1 re-attach and PDU Session Setup Successful with scell cell2_13 and cell2_14
    ...         Step g.
    ...         1.Prime-gNB-DU encodes F1AP: UE CONTEXT RELEASE REQUEST and sends it to prime-gNB-CU-CP.
    ...         2.Prime-gNB-CU encodes RRC: RRCRelease message with redirection information (i.e. redirectedCarrierInfo IE) and send it to
    ...         UE via DL RRC message transfer procedure.
    ...         3.Prime-gNB-CU-CP encodes NGAP:UE CONTEXT RELEASE REQUEST and sends it to AMF
    ...         4.AMF sends NGAP: UE CONTEXT RELEASE COMMAND towards prime-gNB to request UE context release.
    ...         5.Prime-gNB-CU-CP sends F1AP: UE CONTEXT RELEASE COMMAND towards prime-gNB-DU. Prime-gNB-DU notifies ext-gNB-DU via Xp-U link
    ...         that DPA and scheduling should stop in ext-SCell(s),releases all resources allocated for the UE including those allocated for
    ...         inter-gNB CA (PUCCH,GTP-U tunnels) and replies with F1AP:UE CONTEXT RELEASE COMPLETE.
    ...         6.In parallel to steps 5,gNB-1 CU-CP executes E1 Bearer Context Release procedure.
    ...         7.Prime-gNB-CU-CP sends NGAP:UE CONTEXT RELEASE COMPLETE towards AMF.
    ...         8.Prime-gNB-CU-CP sends XnAP:IgNB CA RELEASE REQUEST towards ext-gNB-CU-CP.
    ...         9.Ext-gNB-CU-CP sends F1AP: IgNB CA UE CONTEXT RELEASE COMMAND towards ext-gNB-DU, which releases all resources allocated for
    ...         the UE together with UE context and replies with F1AP:IgNB CA UE CONTEXT RELEASE COMPLETE.
    ...         10.Ext-gNB-CU-CP releases all resources allocated for UE and replies to prime-gNB-CU-CP with XnAP:IgNB CA RELEASE ACKNOWLEDGE.
    ...         11.Prime-gNB-CU-CP increments M55118C11008 IGNB_CA_ATT_REL PM counter, releases all resources allocated for the UE in prime-gNB-CU
    ...         and removes UE context.

    [Tags]    QC_47087
    Clear Counter Files for 2GNB
    Ue1 Register And PDU Session Setup With Scell Addition    ue_id=1    enb_id=2    cell_id=11
    Run Traffic and Activation and Verify Throughput    ue_id=1
    Ue2 Register And PDU Session Setup With Scell Addition    ue_id=2    enb_id=2    cell_id=11
    Ue2 PDU2 Session Setup
    release UE1
    Ue1 re-attach and PDU Session Setup With Scell Addition
    Release UEs    ue_type=all
    Check Counters    ${Counters_Check_priGNB}
    Check WireShark Log    ${CURDIR}${/}A2A_GF_002${/}a2a.ini    wait_string=UEContextModificationResponse::22
#    Check WireShark Log GNB2    ${CURDIR}${/}A2A_GF_002${/}a2a_gnb2.ini    wait_string=IgNBCAReleaseRequestAcknowledge::3

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup 2Airphone Env    fddtdd_sansa_cmwv/6cells_gnb1_2F_gnb2_2T2F

Modify Cfg
    Update Cfg    ue_param id=1 ue_nr_capabilities=${SA_Capa_Support_3CC_n77_3A_CA}
    Update Cfg    set_qosflow id=1 5qi=6 default=on priority=15 pci=shall_not_trigger_pre_emption pvi=pre_emptable
    Update Cfg    set_qosflow id=2 5qi=7 ue=2 priority=12 pci=may_trigger_pre_emption pvi=pre_emptable
    Update Cfg    set_qosflow id=3 5qi=8 ue=1 priority=11 pci=may_trigger_pre_emption pvi=not_pre_emptable
    Update Cfg    set_nwslice id=2 snssai=0x01:0xD143A6 ue=2 amf=1 qos_flows=2 default=off
    Update Cfg    set_nwslice id=3 snssai=0x01:0xD143A7 ue=1 amf=1 qos_flows=3 default=off
    ${gNB2_cell1_configuration}    catenate
    ...    set_cell id=1 gnb=3 pci=16:2 tac=200 nrci=0x01 tdd_cell=on proxy=$PROXY_SERVER_IP:9999|$PROXY_SERVER_IP:8888
    ...    nr_arfcn=656094:656094 mandatory_for_activation=off gscn=8062
    update Cfg    ${gNB2_cell1_configuration}

Clear Counter Files for 2GNB
    Clear Counter Files    ${False}
    Clear Counter Files GNB2

Verify Throughput
    [Arguments]    ${ue_id}=1    ${Tput_dl}=10    ${Tput_ul}=10    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pdsch    Throughput
    Should Not Match Regexp    ${scell_tput}    CellIndex-.*Mbps.*Mbps.*Mbps.* 0 Mbps
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

Ue1 Register And PDU Session Setup With Scell Addition
    [Arguments]    ${ue_id}=1    ${gateway}=1    ${enb_id}=2    ${cell_id}=11
    Execute Egate Command    ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${gateway}
    ...    pass_regexp=${Ue1activatedSuccessfullyAirphoneCheck}    fail_regexp=${unexpect_check}    timeout=20s
    Sleep    5s    #wait all Scell info print

Ue2 Register And PDU Session Setup With Scell Addition
    [Arguments]    ${ue_id}=1    ${gateway}=1    ${enb_id}=2    ${cell_id}=11
    Execute Egate Command    ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${gateway}
    ...    pass_regexp=${Ue2activatedSuccessfullyAirphoneCheck}    fail_regexp=${unexpect_check}    timeout=20s
    Sleep    5s    #wait all Scell info print

Ue2 PDU2 Session Setup
    Execute Egate Command    qosflow_modify qos_flow=2 default=on
    Execute Egate Command    ue_pdu_session_setup ue=2 pdu=2 nwslice=2 gw=2    pass_regexp=${UE2PDU2sessionCheck}

Run Traffic and Activation and Verify Throughput
    [Arguments]    ${ue_id}=1
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=1 protocol=tcp mbps=150 dir=dl
    ...    pass_regexp=Started Downlink Internal traffic over TCP on Ue
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=2 protocol=tcp mbps=150 dir=dl
    ...    pass_regexp=Started Downlink Internal traffic over TCP on Ue
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=1 protocol=tcp mbps=50 dir=ul
    Verify Throughput    ue_id=1    Tput_dl=270    Tput_ul=42

release UE1
    Execute Egate Command    ue_deregister id=1 ue_deregister_type=switch_off    pass_regexp=Released PDU session

Ue1 re-attach and PDU Session Setup With Scell Addition
    [Arguments]    ${ue_id}=1    ${gateway}=1    ${enb_id}=2    ${cell_id}=11
    Execute Egate Command    qosflow_modify qos_flow=3 default=on
    Execute Egate Command    ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${gateway}
    ...    pass_regexp=${activatedSuccessfullyAndUE2IDLECheck}    fail_regexp=${unexpect_check}    timeout=20s
    Sleep    5s    #wait all Scell info print
