*** Settings ***
Documentation
...    author:  baijie.zhu@nokia-sbell.com
...    contact: baijie.zhu@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    CRT    CLOUD_5G_I_BOO_AP_LOO
...    team-VRF3_7    owner-zhubaijie    release-5G25R1
Resource    ../../../resources/DevHZ5_resource.robot

*** Variables ***
${SYSCOM_FLAG}    ${True}

@{PARAMS_IN_SCF}
...    @{Common_Config}
...    @{CELL12_Config}
...    @{CELL14_Config}
...    @{cell1_Config}
...    @{CELL2_Config}
...    @{CB008227}
...    @{CB008290_Enable}
...    @{CB008195}
...    @{NRRESOURCEGROUP_PROFILE}
...    @{RANsharing}
...    @{PLMN}

@{PLMN}
...    MRBTS-1/NRBTS-1/NRPLMN-1:mcc=311
...    MRBTS-1/NRBTS-1/NRPLMN-1:mnc=489
...    MRBTS-1/NRBTS-1/NRPLMN-1:mncLength=3
...    MRBTS-1/NRBTS-1/NRPLMN-2:mcc=311
...    MRBTS-1/NRBTS-1/NRPLMN-2:mnc=500
...    MRBTS-1/NRBTS-1/NRPLMN-2:mncLength=3

@{RANsharing}
...    NRBTS:actNgcFlexSaMode=true
...    NRBTS:actRanSharing=true
...    NRBTS:actRanSharingEnh=disabled
...    NRBTS:actTrsSepaSARanSharing=true
...    NRBTS:ngCplane:ngTnlId=1
...    NRBTS:ngUplane:nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS:xnCplane:xnTnlId=1
...    NRBTS:xnUplane:nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRCELL:configuredEpsTac=${EMPTY}
...    NRCELL:ranAC=${EMPTY}
...    NRCELL:trackingAreaDN=${EMPTY}
...    NRCELL/NRPLMNSET_NSA-1:configuredEpsTac=222
...    NRCELL/NRPLMNSET_NSA-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1,MRBTS-1/NRBTS-1/NRPLMN-2
...    NRCELL/NRPLMNSET_SA-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRCELL/NRPLMNSET_SA-1:ranAC=0
...    NRCELL/NRPLMNSET_SA-1:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-200
...    NRCELL/NRPLMNSET_SA-2:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-2
...    NRCELL/NRPLMNSET_SA-2:ranAC=0
...    NRCELL/NRPLMNSET_SA-2:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-300
...    NRBTS/SERVEDAMF-1:ngTnlId=1
...    NRBTS/XNLINK-1:xnTnlId=1
...    @{SNSSAI}
...    @{TRACKINGAREA}

@{SNSSAI}
...    NRBTS-1/SNSSAI-1:sst=1
...    NRBTS-1/SNSSAI-1:sd=13714341
...    NRBTS-1/SNSSAI-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1,MRBTS-1/NRBTS-1/NRPLMN-2
...    NRBTS-1/SNSSAI-2:sst=1
...    NRBTS-1/SNSSAI-2:sd=13714342
...    NRBTS-1/SNSSAI-2:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1,MRBTS-1/NRBTS-1/NRPLMN-2

@{TRACKINGAREA}
...    TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-1|snssaiDN=SNSSAI-1
...    TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-2|snssaiDN=SNSSAI-2
...    TRACKINGAREA-300:snssaiList:snssaiDN=SNSSAI-2|snssaiDN=SNSSAI-2

@{CB008195}
...    NRBTS-1:actRrcInactState=none
...    MRBTS-1/NRBTS-1:rgMinQuotaReservationLevel=cell_and_multicell_level
...    MRBTS-1/NRBTS-1:drbRrcInactInactivityTimerSA=90
...    MRBTS-1/NRBTS-1:drbInactivityTimerSA=90
...    MRBTS-1/NRBTS-1:srbInactivityTimerSA=90
...    MRBTS-1/NRBTS-1:maxUeRrcInactTime=90
...    MRBTS-1/NRBTS-1:gNbCuType=SA+NSA
...    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrCellUtilPerNrg=5min
...    MRBTS-1/NRBTS-1:actSliceAwareAdmissionCtrl=true
...    MRBTS-1/NRBTS-1:actDrbPreemption=false
...    MRBTS-1/NRBTS-1:actUserPreemption=false
...    MRBTS-1/NRBTS-1:actConnRrcPooling=true
...    MRBTS-1/NRBTS-1:actScheUePooling=true
...    NRBTS-1/NRCELL-1:sliceAwareAdmissionCtrlEnabled=true
...    NRBTS-1/NRCELL-2:sliceAwareAdmissionCtrlEnabled=false
...    NRBTS-1/NRCELL-11:sliceAwareAdmissionCtrlEnabled=true
...    NRBTS-1/NRCELL-12:sliceAwareAdmissionCtrlEnabled=true
...    NRBTS-1/NRCELL-1:actPriorityAccess=false
...    NRBTS-1/NRCELL-2:actPriorityAccess=false
...    NRBTS-1/NRCELL-1:actEmergencyCall=false
...    NRBTS-1/NRCELL-2:actEmergencyCall=false
...    NRCELL:numOfRadioResReservForTempUse=0
...    NRCELL:numOfRadioResReservForEmergency=0
...    NRCELL:numOfRadioResReservForPa=0

...    NRBTS-1/NRCELL-11:nrResourceGroupProfileRacDN=NRBTS-1/NRRESOURCEGROUP_PROFILE-2
...    NRBTS-1/NRCELL-12:nrResourceGroupProfileRacDN=NRBTS-1/NRRESOURCEGROUP_PROFILE-2
...    NRBTS-1/NRCELL-1:nrResourceGroupProfileRacDN=NRBTS-1/NRRESOURCEGROUP_PROFILE-1

@{NRRESOURCEGROUP_PROFILE}
#NRRESOURCEGROUP_PROFILE-2 - PLMN1 PLMN2
...    NRBTS-1/NRRESOURCEGROUP_PROFILE-2:bypassRgLimits=4
...    NRBTS-1/NRRESOURCEGROUP_PROFILE-2:defaultRgSaList:nrResourceGroupId=1|nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS-1/NRRESOURCEGROUP_PROFILE-2:defaultRgSaList:nrResourceGroupId=2|nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-2
...    NRBTS-1/NRRESOURCEGROUP_PROFILE-2:defaultRgNsaList:nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1|nrResourceGroupId=1
...    NRBTS-1/NRRESOURCEGROUP_PROFILE-2:defaultRgNsaList:nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-2|nrResourceGroupId=2
...    NRBTS-1/NRRESOURCEGROUP_PROFILE-2/NRRESOURCEGROUP-1:nrResourceList:resourceDN=SNSSAI-1|resourceDN=NRPLMN-1
...    NRBTS-1/NRRESOURCEGROUP_PROFILE-2/NRRESOURCEGROUP-1:racParams:maxQuota=26
...    NRBTS-1/NRRESOURCEGROUP_PROFILE-2/NRRESOURCEGROUP-1:racParams:minQuota=0
...    NRBTS-1/NRRESOURCEGROUP_PROFILE-2/NRRESOURCEGROUP-2:nrResourceList:resourceDN=SNSSAI-2|resourceDN=NRPLMN-1
...    NRBTS-1/NRRESOURCEGROUP_PROFILE-2/NRRESOURCEGROUP-2:racParams:maxQuota=74
...    NRBTS-1/NRRESOURCEGROUP_PROFILE-2/NRRESOURCEGROUP-2:racParams:minQuota=24
...    NRBTS-1/NRRESOURCEGROUP_PROFILE-2:nrResourceGroupProfileId=2

#NRRESOURCEGROUP_PROFILE-1 - PLMN1 PLMN2
...    NRBTS-1/NRRESOURCEGROUP_PROFILE-1:bypassRgLimits=4
...    NRBTS-1/NRRESOURCEGROUP_PROFILE-1:defaultRgSaList:nrResourceGroupId=1|nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS-1/NRRESOURCEGROUP_PROFILE-1:defaultRgSaList:nrResourceGroupId=2|nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-2
...    NRBTS-1/NRRESOURCEGROUP_PROFILE-1:defaultRgNsaList:nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1|nrResourceGroupId=1
...    NRBTS-1/NRRESOURCEGROUP_PROFILE-1:defaultRgNsaList:nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-2|nrResourceGroupId=2
...    NRBTS-1/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-1:nrResourceList:resourceDN=SNSSAI-1|resourceDN=NRPLMN-1
...    NRBTS-1/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-1:racParams:maxQuota=76
...    NRBTS-1/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-1:racParams:minQuota=75
...    NRBTS-1/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-2:nrResourceList:resourceDN=SNSSAI-2|resourceDN=NRPLMN-2
...    NRBTS-1/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-2:racParams:maxQuota=24
...    NRBTS-1/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-2:racParams:minQuota=14
...    NRBTS-1/NRRESOURCEGROUP_PROFILE-1:nrResourceGroupProfileId=1

@{CB008227}
...    NRBTS-1/NRDRB-13:nsaDrbParam:nsa3xBearerAllowed=true
...    NRBTS-1/NRDRB-6:nsaDrbParam:nsa3xBearerAllowed=true
...    NRBTS-1/NRDRB-7:nsaDrbParam:nsa3xBearerAllowed=true
...    NRBTS-1/NRDRB-8:nsaDrbParam:nsa3xBearerAllowed=true
...    NRBTS-1/NRDRB-9:nsaDrbParam:nsa3xBearerAllowed=true
...    NRBTS-1/NRDRB-3:nsaDrbParam:nsa3xBearerAllowed=true
...    NRCELL:congDetectPeriod=ms100
...    NRBTS-1:actNonGbrServiceDiff=true
...    NRCELL:actNbrForNonGbrBearers=false
...    NRCELL-1:congWeightAlg=arpPrioPerVul
...    NRCELL-2:congWeightAlg=priorityLevel
...    NRCELL-11:congWeightAlg=priorityLevel
...    NRCELL-13:congWeightAlg=priorityLevel
...    NRCELL:maxNbrTrafficLimit=80
...    NRCELL:maxPrbsPerNbrUe=30
...    NRCELL:nbrPdcchCongHandlingDl=true
...    NRCELL:nbrPdcchCongHandlingUl=true
...    NRCELL:nbrPdschCongHandling=true
...    NRCELL:nbrPuschCongHandling=true
...    NRCELL-12:congWeightAlg=priorityLevel
...    NRCELL-14:nbrPdcchCongHandlingDl=false
...    NRCELL-14:nbrPdcchCongHandlingUl=false
...    NRCELL-14:nbrPdschCongHandling=false
...    NRCELL-14:nbrPuschCongHandling=false
...    NRBTS-1/NRDRB_5QI-80:fiveqiValueList=80
...    NRBTS-1/NRDRB_5QI-80:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-11
...    NRBTS-1/NRDRB_5QI-2:fiveqiValueList=6
...    NRBTS-1/NRDRB_5QI-2:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-14
#...    NRCELL:maxNumOfNbrBearers=30
...    NRCELL-1:maxNumOfNbrBearers=10
...    NRCELL-11:maxNumOfNbrBearers=10
...    NRCELL-12:maxNumOfNbrBearers=10
...    NRCELL-13:maxNumOfNbrBearers=80
...    NRCELL-14:maxNumOfNbrBearers=80
...    NRCELL-2:maxNumOfNbrBearers=80
...    NRBTS/NRDRB-13:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-6
...    NRBTS/NRDRB-13:priorityLevel=17
...    NRBTS/NRDRB-1:priorityLevel=68
...    NRBTS/NRDRB-2:priorityLevel=68
...    NRBTS/NRDRB-3:priorityLevel=68
...    NRBTS/NRDRB-4:priorityLevel=68
...    NRBTS/NRDRB-5:priorityLevel=68
...    NRBTS/NRDRB-6:priorityLevel=68
...    NRBTS/NRDRB-7:priorityLevel=68
...    NRBTS/NRDRB-3:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-2
...    NRBTS-1:actMultiDrbNSA=true
...    NRBTS/NRDRB-13:nsaDrbParam:dlDataSplitMode=dlOverF1U
...    NRBTS/NRDRB-13:nsaDrbParam:dlPreferredPath=${EMPTY}
...    NRBTS/NRDRB-13:nsaDrbParam:inactPeriodX2PdcpDuplication=${EMPTY}
...    NRBTS/NRDRB-8:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-5
...    NRBTS/NRDRB-8:priorityLevel=100
...    NRBTS/NRDRB-9:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-6
...    NRBTS/NRDRB-9:priorityLevel=19
...    NRBTS/NRDRB_MAC-1:nbrDl=500
...    NRBTS/NRDRB_MAC-1:nbrUl=100
...    NRBTS/NRDRB_MAC-1:schedulBSD=1000ms
...    NRBTS/NRDRB_MAC-5:nbrDl=50
...    NRBTS/NRDRB_MAC-6:nbrUl=10
...    NRBTS/NRDRB_MAC-6:schedulBSD=5ms
...    NRBTS/NRDRB_QCI-5:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-7
...    NRBTS/NRDRB_QCI-4:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-9
...    NRBTS/NRDRB_QCI-3:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-8
...    NRBTS/NRDRB-14:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-2
...    NRBTS/NRDRB-14:priorityLevel=2
...    NRBTS/NRDRB-11:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-1
...    NRBTS/NRDRB-11:priorityLevel=3
...    NRBTS/NRDRB-12:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-5
...    NRBTS/NRDRB-12:priorityLevel=3

@{CB008290_Enable}
...    NRBTS:actSCellSwapFr1=a6BasedSa
...    NRCELL-12:a6MeasSCellSwapEnabled=rsrp
...    NRCELL-12:reportAmountA6MeasSCellSwap=infinity
...    NRCELL-12:reportIntervalA6MeasSCellSwap=ms1024
...    NRCELL-12:thresholdSCellSwapSourceRsrp=66
...    NRCELL-12:a6MeasSCellSwapSsbRsrp:a6OffsetSCellSwapSsbRsrp=20
...    NRCELL-14:a6MeasSCellSwapEnabled=rsrp
...    NRCELL-14:reportAmountA6MeasSCellSwap=infinity
...    NRCELL-14:reportIntervalA6MeasSCellSwap=ms1024
...    NRCELL-14:thresholdSCellSwapSourceRsrp=66
...    NRCELL-14:a6MeasSCellSwapSsbRsrp:a6OffsetSCellSwapSsbRsrp=20

@{Common_Config}
...    NRBTS:actConflictConfiguration=true
...    NRBTS:sCellActivationMethod=blind
...    NRBTS:actInterFreqInterGnbMobilityNSA=true
...    NRBTS:actInterFreqIntraGnbMobilityNSA=true
...    NRBTS:srb3SupportEnabled=false
...    NRDU-1:flexibleCAMode=NumberCellAmount
...    NRDU-1:actInterNumerologyCa=true
...    NRDU-1:carrierAggregationSupportList=ca_Fr1Tdd_Fdd_Nsa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fdd_Fdd,ca_Fdd_Fr1Tdd_Sa,ca_Fr1Tdd_Any_Sa
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRCELL:configuredEpsTac=200
...    NRCELL:sCellDeactivationTimerGNB=infinity
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS:actMeasBasedSCellAdditionNsa=true
...    NRBTS:actBufferBasedSCellAddition=oneShot_Dl_Fr1
...    NRCELL:dlSCellConfigLevel=10
...    NRCELL:dlSCellConfigLevelNum=20
...    NRBTS:maxNumScellsDl=7
...    NRBTS:maxNumScellsUl=7
...    NRBTS:actIntraFreqIntraGnbMobilityNSA=true
...    NRCELL:a3MeasEnabled=rsrp
...    NRCELL:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL:absThreshSsbRsrpConsolidation=1
...    NRCELL:sMeasConfigSsbRsrp=1
...    NRCELL-11/NRCELL_FDD-1:chBwDl=20MHz
...    NRCELL-11/NRCELL_FDD-1:chBwUl=20MHz

...    NRCELL:a2MeasRedirectSsbRsrp:a2ThresholdRedirectSsbRsrp=19

@{cell1_Config}
...    NRCELL-1:chBw=60MHz
...    NRCELL-1:nrarfcn=518580
...    NRCELL-1:freqBandIndicatorNR=41
...    NRCELL-1:gscnOrSsPbchArfcn=6486
...    NRCELL:actK1Opt=intra-gNB

...    NRCELL:a1MeasSCellAddEnabled=rsrp
...    NRCELL:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=70|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=90|a1TimeToTriggerSCellAddSsbRsrp=320ms

...    NRCELL:a2MeasSCellRelEnabled=rsrp
...    NRCELL:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=480ms
...    NRCELL:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=40|a2TimeToTriggerSCellRelSsbRsrp=480ms

...    NRCELL-1/NRREL-12:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-12:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-12:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-12:gNbId=1
...    NRCELL-1/NRREL-12:gNbIdLength=22
...    NRCELL-1/NRREL-12:lcrId=12
...    NRCELL-1/NRREL-12:removeNotAllowed=false
...    NRCELL-1/NRREL-12:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-12:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-12:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-12:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-12:handoverAllowedSA=allowed

@{CELL2_Config}
...    NRCELL-2:maxNumScellsDlFr1=3
...    NRCELL-2/NRREL-1:gNbId=1
...    NRCELL-2/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-2/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-11:gNbId=1
...    NRCELL-2/NRREL-11:lcrId=11
...    NRCELL-2/NRREL-11:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-11:sCellOperationalMode=dlOnly
...    NRCELL-2/NRREL-11:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-11:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-11:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-12:gNbId=1
...    NRCELL-2/NRREL-12:lcrId=12
...    NRCELL-2/NRREL-12:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-12:sCellOperationalMode=dlOnly
...    NRCELL-2/NRREL-12:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-12:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-12:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-13:gNbId=1
...    NRCELL-2/NRREL-13:lcrId=13
...    NRCELL-2/NRREL-13:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-13:sCellOperationalMode=dlOnly
...    NRCELL-2/NRREL-13:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-13:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-13:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-14:gNbId=1
...    NRCELL-2/NRREL-14:lcrId=14
...    NRCELL-2/NRREL-14:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-14:sCellOperationalMode=dlOnly
...    NRCELL-2/NRREL-14:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-14:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-14:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-12:sCellPrio=1
...    NRCELL-2/NRREL-14:sCellPrio=2

@{CELL12_Config}
...    NRCELL-12/NRCELL_FDD-1:chBwDl=15MHz
...    NRCELL-12/NRCELL_FDD-1:chBwUl=15MHz
...    NRCELL-12/NRCELL_FDD-1:nrarfcnUl=134980
...    NRCELL-12/NRCELL_FDD-1:nrarfcnDl=127180
...    NRCELL-12:freqBandIndicatorNR=71
...    NRCELL-12:gscnOrSsPbchArfcn=1586

...    NRCELL-12:rsrpThresholdSSB=11

...    NRCELL-12:absThreshSsbRsrqConsolidation=1
...    NRCELL-12:filterCoeffSsbRsrp=fc4

...    NRCELL-12:actCDrx=true
...    NRCELL-12:cbraPreamblesPerSsb=n60

...    NRCELL-12:a1MeashoEnabled=rsrp
...    NRCELL-12:a1MeashoSsbRsrp:a1ThresholdhoSsbRsrp=34
...    NRCELL-12:a1MeashoSsbRsrp:a1TimeToTriggerhoSsbRsrp=ms480
...    NRCELL-12:a1MeashoSsbRsrp:a1HysteresishoSsbRsrp=0
...    NRCELL-12:a2MeashoEnabled=rsrp
...    NRCELL-12:a2MeashoSsbRsrp:a2HysteresishoSsbRsrp=1
...    NRCELL-12:a2MeashoSsbRsrp:a2ThresholdhoSsbRsrp=34
...    NRCELL-12:a2MeashoSsbRsrp:a2TimeToTriggerhoSsbRsrp=ms480
...    NRCELL-12:measGapSelectionSA=favourUeThroughput

...    NRCELL-12/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-12/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-1:gNbId=1
...    NRCELL-12/NRREL-1:gNbIdLength=22
...    NRCELL-12/NRREL-1:lcrId=1
...    NRCELL-12/NRREL-1:removeNotAllowed=false
...    NRCELL-12/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-1:handoverAllowedSA=allowed

...    NRCELL-12/NRREL-11:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-11:sCellOperationalMode=dlOnly
...    NRCELL-12/NRREL-11:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-11:gNbId=1
...    NRCELL-12/NRREL-11:gNbIdLength=22
...    NRCELL-12/NRREL-11:lcrId=11
...    NRCELL-12/NRREL-11:removeNotAllowed=false
...    NRCELL-12/NRREL-11:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-11:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-11:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-11:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-11:handoverAllowedSA=allowed

...    NRCELL-12/NRREL-14:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-14:gNbId=1
...    NRCELL-12/NRREL-14:gNbIdLength=22
...    NRCELL-12/NRREL-14:lcrId=14
...    NRCELL-12/NRREL-14:removeNotAllowed=false
...    NRCELL-12/NRREL-14:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-14:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-14:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-14:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-14:handoverAllowedSA=allowed

...    NRCELL-12/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-12/NRHOIF-1:a5MeasEnabled=rsrp
...    NRCELL-12/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-12/NRHOIF-1:freqBandIndicatorNR=71
...    NRCELL-12/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-12/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-12/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-12/NRHOIF-1:scs=15 KHz
...    NRCELL-12/NRHOIF-1:ssBurstSetPeriod=10
...    NRCELL-12/NRHOIF-1:ssbFrequency=126750
...    NRCELL-12/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL-12/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL-12/NRHOIF-1:a5MeasSsbRsrp:a5HysteresisSsbRsrp=10
...    NRCELL-12/NRHOIF-1:a5MeasSsbRsrp:a5Threshold1SsbRsrp=30
...    NRCELL-12/NRHOIF-1:a5MeasSsbRsrp:a5Threshold2SsbRsrp=55
...    NRCELL-12/NRHOIF-1:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms0

...    NRCELL-12/NRHOIF-2:a3MeasEnabled=rsrp
...    NRCELL-12/NRHOIF-2:a5MeasEnabled=rsrp
...    NRCELL-12/NRHOIF-2:cellDepType=SA+NSA
...    NRCELL-12/NRHOIF-2:freqBandIndicatorNR=41
...    NRCELL-12/NRHOIF-2:ifhoSsbScs=30 KHz
...    NRCELL-12/NRHOIF-2:ifhoSsbSmtcDuration=sf1
...    NRCELL-12/NRHOIF-2:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-12/NRHOIF-2:scs=30 KHz
...    NRCELL-12/NRHOIF-2:ssBurstSetPeriod=10
...    NRCELL-12/NRHOIF-2:ssbFrequency=518910
...    NRCELL-12/NRHOIF-2:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL-12/NRHOIF-2:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL-12/NRHOIF-2:a5MeasSsbRsrp:a5HysteresisSsbRsrp=10
...    NRCELL-12/NRHOIF-2:a5MeasSsbRsrp:a5Threshold1SsbRsrp=30
...    NRCELL-12/NRHOIF-2:a5MeasSsbRsrp:a5Threshold2SsbRsrp=55
...    NRCELL-12/NRHOIF-2:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms0


@{CELL14_Config}
...    NRCELL-14/NRCELL_FDD-1:chBwDl=15MHz
...    NRCELL-14/NRCELL_FDD-1:chBwUl=15MHz
...    NRCELL-14/NRCELL_FDD-1:nrarfcnUl=134980
...    NRCELL-14/NRCELL_FDD-1:nrarfcnDl=127180
...    NRCELL-14:freqBandIndicatorNR=71
...    NRCELL-14:gscnOrSsPbchArfcn=1586

...    NRCELL-14:a1MeashoEnabled=rsrp
...    NRCELL-14:a1MeashoSsbRsrp:a1ThresholdhoSsbRsrp=34
...    NRCELL-14:a1MeashoSsbRsrp:a1TimeToTriggerhoSsbRsrp=ms480
...    NRCELL-14:a1MeashoSsbRsrp:a1HysteresishoSsbRsrp=0
...    NRCELL-14:a2MeashoEnabled=rsrp
...    NRCELL-14:a2MeashoSsbRsrp:a2HysteresishoSsbRsrp=1
...    NRCELL-14:a2MeashoSsbRsrp:a2ThresholdhoSsbRsrp=34
...    NRCELL-14:a2MeashoSsbRsrp:a2TimeToTriggerhoSsbRsrp=ms480
...    NRCELL-14:measGapSelectionSA=favourUeThroughput

...    NRCELL-14/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-14/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-14/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-14/NRREL-1:gNbId=1
...    NRCELL-14/NRREL-1:gNbIdLength=22
...    NRCELL-14/NRREL-1:lcrId=1
...    NRCELL-14/NRREL-1:removeNotAllowed=false
...    NRCELL-14/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-14/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-14/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-14/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-14/NRREL-1:handoverAllowedSA=allowed

...    NRCELL-14/NRREL-12:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-14/NRREL-12:gNbId=1
...    NRCELL-14/NRREL-12:gNbIdLength=22
...    NRCELL-14/NRREL-12:lcrId=12
...    NRCELL-14/NRREL-12:removeNotAllowed=false
...    NRCELL-14/NRREL-12:gnbPlmn:mcc=311
...    NRCELL-14/NRREL-12:gnbPlmn:mnc=489
...    NRCELL-14/NRREL-12:gnbPlmn:mncLength=3
...    NRCELL-14/NRREL-12:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-14/NRREL-12:handoverAllowedSA=allowed

...    NRCELL-14/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-14/NRHOIF-1:a5MeasEnabled=rsrp
...    NRCELL-14/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-14/NRHOIF-1:freqBandIndicatorNR=71
...    NRCELL-14/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-14/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-14/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-14/NRHOIF-1:scs=15 KHz
...    NRCELL-14/NRHOIF-1:ssBurstSetPeriod=10
...    NRCELL-14/NRHOIF-1:ssbFrequency=126970
...    NRCELL-14/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL-14/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL-14/NRHOIF-1:a5MeasSsbRsrp:a5HysteresisSsbRsrp=10
...    NRCELL-14/NRHOIF-1:a5MeasSsbRsrp:a5Threshold1SsbRsrp=30
...    NRCELL-14/NRHOIF-1:a5MeasSsbRsrp:a5Threshold2SsbRsrp=55
...    NRCELL-14/NRHOIF-1:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms0

${carrierfreq_phycell61_63}    126970
${carrierfreq_phycell50}    518910
${carrierfreq_phycell60}    424090

@{PARAMS_FOR_UPD003_92}
...    NRBTS:actBufferBasedSCellAddition=disabled
...    NRCELL-11:weightForSCellSelection=100
...    NRCELL-1:weightForSCellSelection=100
...    NRCELL:actNbrForNonGbrBearers=true

@{PARAMS_FOR_UPD003_92_2}
...    NRBTS-1/NRDRB_5QI-2:fiveqiValueList=6
...    NRBTS-1/NRDRB_5QI-2:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-11

#CA_n41A-n66(2A)-n71A-n78A
${E001_UE}    SEPARATOR=
...    E9A09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C4700FB8D85181AC1184341020E9068036B64C558D0E7C471E819F604F8C48
...    E3C873EA39F30C7942C0FFFFF05C00FFC0070005F0005C0000E0541B107582308682041E20D00656C98AB121CFB027C471E31238F21CFA8E7CC31E50B0381C3C27F6
...    000001FD800000170000381546C4DD608C21A0810748360185B262A88873E238F11C7A067D813E31CF9863CA1607FFFF806400000C000002E007FE003801FF8002E0
...    000702B8F88DAC1184341020F941A00AAD931561439F11C78C0000000000000000007FFFE027FFC00001FFF0000017000038020F0F1300038820000042C040A83C28
...    000E230000010B02B0F11800388200000C2C0AC3C28000E208000010B02B0F13000388C0000042C0AC5C46000E208007130000028581587850001C4C00000C160562
...    E2600071040038500000102C0AC5C4C000E23000711800001058158B850001C41000E230000020B02B170A0003882001C41000004160562E26000710400388C00000
...    82C0AC5C28000E23000711800001058158B898001C46000E140000040B02B0F11800388C00000C2C0AC9C41000E208007118003850001C4D00000E1617007011A014
...    404C80822EC019610851226C73E1C28913639F0E14489B1CF870A244D8E7C3851226C73E1C4891226C73E1C28103639F022408103639F022408103639F0224081036
...    39F022408103639F022408103639F022408103639F022408103639F0214081B1CF8122040810206CB5E183220318C6318C6318C6318C600560800000000000000000
...    00000000010000800300003D05C0078005038280381804A00E000C0480080C07C120040000000200000401000000008000010040000100200000C010000080080000
...    50040020080200800006004000038020010000000400004002000024010000060080000A004000058020010240900400006019CA9ACA9AC14AC0CAC19AC15ACA5AC9
...    9AC05AC0DAC04AC08AC1DA0682000012CA4A080000CB29282000052CA48080001CB29202000092CA48080002CB292020000D2CA48080003CB29202000112CA480800
...    04CB29202000152CA48080005CB29282000192CA480800018B292019A55574AAAA9545D2A8AA0B1540E2A83455298AA4D154062A8145526AAA0F142C02F012A05028
...    140A05028140A05028140A05028140A0502800384040300601002004202004010080600C20100200404030060100C018202018030080600C20100200404030060100
...    2004402018030080600C020180304040080201002008802018030080600C02018030080100202004008D50F8000810182030385058606880889098A0C0C8D8E0E8F9
...    09293139414951697A0A0C1680

@{Cell12_Attach}
...    physCellId 61
...    qCI 9
...    eventId eventA1

@{Cell1_Attach}
...    physCellId 50
...    qCI 9
...    eventId eventA1

@{Cell12_Cell1}
...    pcid:61, scellIdx:8
...    pcid:50, scellIdx:9
...    rrcConnectionReconfigurationComplete
...    PhysCellId: 50] SCellIndex 9 activated successfully at airphone

@{Cell14_Cell1}
...    pcid:63, scellIdx:8
...    pcid:50, scellIdx:9
...    rrcConnectionReconfigurationComplete
...    PhysCellId: 50] SCellIndex 9 activated successfully at airphone

@{Cell1_Cell12}
...    pcid:50, scellIdx:8
...    pcid:61, scellIdx:9
...    rrcConnectionReconfigurationComplete
...    PhysCellId: 61] SCellIndex 9 activated successfully at airphone

@{UE_register_and_A1_configured}
...    QoS Routing Table
...    Setup QosFlow with QFI:1 5QI:6
...    eventA1

@{CA_check}
...    rrcReconfigurationComplete
...    pcid:60, scellIdx:1
...    SCellIndex 1 activated successfully at airphone

${PLMN_1}    311:489
${PLMN_2}    311:500

@{PM_Counters_Check_E003}
...    NRCELL-12:${NSA_DU_DRB_NBR_DL}>1
...    NRCELL-12:${NSA_DU_DRB_NBR_UL}>1
...    NRCELL-14:${NSA_DU_DRB_NBR_DL}>1
...    NRCELL-14:${NSA_DU_DRB_NBR_UL}>1
...    NRCELL-1:${NSA_DU_DRB_NBR_DL}>1
...    NRCELL-1:${NSA_DU_DRB_NBR_UL}>1
...    NRCELL-12:${NSA_DU_DRB_NBR_REQ}=9
...    NRCELL-14:${NSA_DU_DRB_NBR_REQ}=3
...    NRCELL-1:${NSA_DU_DRB_NBR_REQ}=10
...    NRCELL-12:${NSA_DU_DRB_NBR_ADMIT_WITH_NBR}=9
...    NRCELL-14:${NSA_DU_DRB_NBR_ADMIT_WITH_NBR}=3
...    NRCELL-1:${NSA_DU_DRB_NBR_ADMIT_WITH_NBR}=10
...    NRCELL-12:${NSA_DRB_NBR_DENOM}>1
...    NRCELL-14:${NSA_DRB_NBR_DENOM}>1
...    NRCELL-1:${NSA_DRB_NBR_DENOM}>1

#@{PM_Counters_Check_upd002_92}
#...    NRCELL-1:${SA_DU_DRB_NBR_DL}>1
#...    NRCELL-2:${SA_DU_DRB_NBR_DL}>1
#...    NRCELL-11:${SA_DU_DRB_NBR_DL}>1
#...    NRCELL-12:${SA_DU_DRB_NBR_DL}>1
#...    NRCELL-13:${SA_DU_DRB_NBR_DL}>1
#...    NRCELL-14:${SA_DU_DRB_NBR_DL}>1
#...    NRCELL-2:${SA_DU_DRB_NBR_UL}>1
#...    NRCELL-13:${SA_DU_DRB_NBR_UL}>1
#...    NRCELL-1:${SA_DU_DRB_NBR_REQ}=3
#...    NRCELL-2:${SA_DU_DRB_NBR_REQ}=4
#...    NRCELL-11:${SA_DU_DRB_NBR_REQ}=4
#...    NRCELL-12:${SA_DU_DRB_NBR_REQ}=5
#...    NRCELL-13:${SA_DU_DRB_NBR_REQ}=1
#...    NRCELL-14:${SA_DU_DRB_NBR_REQ}=3
#...    NRCELL-1:${SA_DU_DRB_NBR_ADMIT_WITH_NBR}=3
#...    NRCELL-2:${SA_DU_DRB_NBR_ADMIT_WITH_NBR}=4
#...    NRCELL-11:${SA_DU_DRB_NBR_ADMIT_WITH_NBR}=1
#...    NRCELL-12:${SA_DU_DRB_NBR_ADMIT_WITH_NBR}=5
#...    NRCELL-13:${SA_DU_DRB_NBR_ADMIT_WITH_NBR}=1
#...    NRCELL-14:${SA_DU_DRB_NBR_ADMIT_WITH_NBR}=3
#...    NRCELL-11:${SA_DU_DRB_NBR_ADMIT_NOT_NBR}=3
#...    NRCELL-1:${SA_DRB_NBR_DENOM}>1
#...    NRCELL-2:${SA_DRB_NBR_DENOM}>1
#...    NRCELL-11:${SA_DRB_NBR_DENOM}>1
#...    NRCELL-12:${SA_DRB_NBR_DENOM}>1
#...    NRCELL-13:${SA_DRB_NBR_DENOM}>1
#...    NRCELL-14:${SA_DRB_NBR_DENOM}>1

@{PM_Counters_Check_upd002_92}
...    NRCELL-1/NRRESOURCEGROUP-2:${NUM_ADM_SUC_NBR_NRG}=3
...    NRCELL-1/NRRESOURCEGROUP-2:${NUM_ADM_REQ_NBR_NRG}=4
...    NRCELL-1/NRRESOURCEGROUP-2:${PEAK_NUM_NBR_NRG}=2
...    NRCELL-1/NRRESOURCEGROUP-2:${AVE_NUM_NBR_NOM_NRG}>60
...    NRCELL-1/NRRESOURCEGROUP-2:${AVG_NUM_UE_NOM_NRG}>60
...    NRCELL-1/NRRESOURCEGROUP-2:${DNOM_SAMPLES_NRG}>60
...    NRCELL-1/NRRESOURCEGROUP-2:${AVE_NUM_NGBR_NOM_NRG}>60
...    NRCELL-1/NRRESOURCEGROUP-2:${PEAK_NUM_UE_NRG}>=2
...    NRCELL-1/NRRESOURCEGROUP-2:${PEAK_NUM_NGBR_NRG}>=2
...    NRCELL-1/NRRESOURCEGROUP-2:${NUM_ADM_REQ_NGBR_NRG}=3
...    NRCELL-1/NRRESOURCEGROUP-2:${NUM_ADM_SUC_NGBR_NRG}=3
...    NRCELL-1/NRRESOURCEGROUP-2:${NUM_ADM_REQ_UE_NRG}=3
...    NRCELL-1/NRRESOURCEGROUP-2:${NUM_ADM_SUC_UE_NRG}=3
...    NRCELL-1/NRRESOURCEGROUP-2:${RAC_REJ_DUE_DRB_MAX_QUOTA_NRG}=0
...    NRCELL-1/NRRESOURCEGROUP-2:${RAC_REJ_DUE_UE_MAX_QUOTA_NRG}=0
...    NRCELL-12/NRRESOURCEGROUP-2:${NUM_ADM_SUC_NBR_NRG}=1
...    NRCELL-12/NRRESOURCEGROUP-2:${NUM_ADM_REQ_NBR_NRG}=1
...    NRCELL-12/NRRESOURCEGROUP-2:${PEAK_NUM_NBR_NRG}=1
...    NRCELL-12/NRRESOURCEGROUP-2:${AVE_NUM_NBR_NOM_NRG}>0
...    NRCELL-12/NRRESOURCEGROUP-1:${AVG_NUM_UE_NOM_NRG}=0
...    NRCELL-12/NRRESOURCEGROUP-1:${DNOM_SAMPLES_NRG}>0
...    NRCELL-12/NRRESOURCEGROUP-1:${AVE_NUM_NGBR_NOM_NRG}=0
...    NRCELL-12/NRRESOURCEGROUP-1:${PEAK_NUM_UE_NRG}=0
...    NRCELL-12/NRRESOURCEGROUP-1:${PEAK_NUM_NGBR_NRG}=0
...    NRCELL-12/NRRESOURCEGROUP-1:${NUM_ADM_REQ_NGBR_NRG}=0
...    NRCELL-12/NRRESOURCEGROUP-1:${NUM_ADM_SUC_NGBR_NRG}=0
...    NRCELL-12/NRRESOURCEGROUP-1:${NUM_ADM_REQ_UE_NRG}=0
...    NRCELL-12/NRRESOURCEGROUP-1:${NUM_ADM_SUC_UE_NRG}=0
...    NRCELL-12/NRRESOURCEGROUP-1:${RAC_REJ_DUE_DRB_MAX_QUOTA_NRG}=0
...    NRCELL-12/NRRESOURCEGROUP-1:${RAC_REJ_DUE_UE_MAX_QUOTA_NRG}=0

#Counter
${AVG_NUM_UE_NOM_NRG}    M55910C00005
${DNOM_SAMPLES_NRG}    M55910C00006
${AVE_NUM_NGBR_NOM_NRG}    M55910C00007
${PEAK_NUM_UE_NRG}    M55910C00010
${PEAK_NUM_NGBR_NRG}    M55910C00011
${NUM_ADM_REQ_NGBR_NRG}    M55910C00017
${NUM_ADM_SUC_NGBR_NRG}    M55910C00018
${NUM_ADM_REQ_UE_NRG}    M55910C00023
${NUM_ADM_SUC_UE_NRG}    M55910C00024
${RAC_REJ_DUE_DRB_MAX_QUOTA_NRG}    M55910C00015
${RAC_REJ_DUE_UE_MAX_QUOTA_NRG}    M55910C00016
${AVE_NUM_NBR_NOM_NRG}    M55910C00009
${PEAK_NUM_NBR_NRG}    M55910C00013
${NUM_ADM_REQ_NBR_NRG}    M55910C00019
${NUM_ADM_SUC_NBR_NRG}    M55910C00020


${NSA_DU_DRB_NBR_DL}    M55115C03509    #This counter provides the accumulated number of NBR-configured non-GBR bearers in DL for NSA users.
#This counter considers nominal bit rate (NBR) non-GBR DRBs when the cell is used as either PSCell or SCell.
${NSA_DU_DRB_NBR_UL}    M55115C03510    #This counter provides the accumulated number of NBR-configured non-GBR bearers in UL for NSA users.
#This counter considers nominal bit rate (NBR) non-GBR DRBs when the cell is used as either PSCell or SCell.
${NSA_DU_DRB_NBR_REQ}    M55115C03506    #This counter provides the number of non-GBR bearers with configured nominal bit rate (NBR)
#admission requests for NSA users.
${NSA_DU_DRB_NBR_ADMIT_WITH_NBR}    M55115C03507    #This counter provides the number of non-GBR bearers with configured nominal bit rate (NBR)
#successfully admitted by applying NBR during the radio admission control for NSA users.
${NSA_DRB_NBR_DENOM}    M55115C03511    #This counter indicates the number of samples taken to NBR-configured bearer counters for NSA.
${SA_DU_DRB_NBR_DL}    M55139C03509    #This counter provides the accumulated number of NBR-configured non-GBR bearers in DL for SA users.
#This counter considers nominal bit rate (NBR) non-GBR DRBs when the cell is used as either PCell or SCell.
${SA_DU_DRB_NBR_UL}    M55139C03510    #This counter provides the accumulated number of NBR-configured non-GBR bearers in UL for SA users.
#This counter considers nominal bit rate (NBR) non-GBR DRBs when the cell is used as either PCell or SCell.
${SA_DU_DRB_NBR_REQ}    M55139C03506    #This counter provides the number of non-GBR bearers with configured nominal bit rate (NBR)
#admission requests for SA users.
${SA_DU_DRB_NBR_ADMIT_WITH_NBR}    M55139C03507    #This counter provides the number of non-GBR bearers with configured nominal bit rate (NBR)
#successfully admitted with applying NBR during the radio admission control for SA users.
${SA_DU_DRB_NBR_ADMIT_NOT_NBR}    M55139C03508    #This counter provides the number of non-GBR bearers with configured nominal bit rate (NBR)
#admitted without applying NBR during the radio admission control due to exceeding the limit of NRCELL.maxNumOfNBRBearers for SA users.
${SA_DRB_NBR_DENOM}    M55139C03511    #This counter indicates the number of samples taken to NBR-configured bearer counters for SA.
#This counter can be used to calculate the average number of nominal bit rate (NBR) DRBs for SA.


*** Test Cases ***
CB008195_SR_H_UPD003_92_Verify_A1_scell_add_then_online_enable_8227_FAF_on_scell_and_setup_NBR_via_pdu_s_modify_then_scell_change
    [Documentation]
    ...    1. This case will test Nominal Bitrate interworking with DL CA.
    ...    Test Case Setings:
    ...    CA relation: Cell2+Cell1+Cell11+Cell12(Cell14)+Cell13
    ...    CB008227 is enabled: NRCELL/actNbrForNonGbrBearers = TRUE
    ...    configure 5QI-80:NRBTS/NRDRB-11 NRBTS-1/NRDRB_MAC-1 with NBR configured, default=on, UL(500)+DL(100)
    ...    configure 5QI-7:NRBTS/NRDRB-12 NRBTS-1/NRDRB_MAC-5 with NBR configured; DL(50)
    ...    configure 5QI-8:NRBTS/NRDRB-13 NRBTS-1/NRDRB_MAC-6 with NBR configured; UL(10)
    ...    configure 5QI-6:NRBTS/NRDRB-14 NRBTS-1/NRDRB_MAC-2 without NBR configured.
    ...    NRCELL-1:maxNumOfNbrBearers=10
    ...    NRCELL-11:maxNumOfNbrBearers=10
    ...    NRCELL-12:maxNumOfNbrBearers=10
    ...    NRBTS-1/NRCELL-1:nrResourceGroupProfileRacDN=NRBTS-1/NRRESOURCEGROUP_PROFILE-1
    ...    NRBTS-1/NRCELL-12:nrResourceGroupProfileRacDN=NRBTS-1/NRRESOURCEGROUP_PROFILE-2
    ...    NRBTS-1/NRCELL-11:nrResourceGroupProfileRacDN=NRBTS-1/NRRESOURCEGROUP_PROFILE-2
    ...    ================================================================================================================
    ...    NRBTS-1/NRRESOURCEGROUP_PROFILE-2/NRRESOURCEGROUP-1:nrResourceList:resourceDN=SNSSAI-1|resourceDN=SNSSAI-1
    ...    NRBTS-1/NRRESOURCEGROUP_PROFILE-2/NRRESOURCEGROUP-1:racParams:maxQuota=26    # 26%*10 = 2.6, max 2 NbrBearer,  common pool
    ...    NRBTS-1/NRRESOURCEGROUP_PROFILE-2/NRRESOURCEGROUP-1:racParams:minQuota=0     # 0*10 = 0, max 0 NbrBearer,  dedicated pool
    ...    NRBTS-1/NRRESOURCEGROUP_PROFILE-2/NRRESOURCEGROUP-2:nrResourceList:resourceDN=SNSSAI-2|resourceDN=SNSSAI-2
    ...    NRBTS-1/NRRESOURCEGROUP_PROFILE-2/NRRESOURCEGROUP-2:racParams:maxQuota=74    # 74%*10 = 7.4, max 7 NbrBearer,  common pool
    ...    NRBTS-1/NRRESOURCEGROUP_PROFILE-2/NRRESOURCEGROUP-2:racParams:minQuota=24    # 24%*10 = 2.4, max 2 NbrBearer,  dedicated pool
    ...    =================================================================================================================
    ...    NRBTS-1/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-1:nrResourceList:resourceDN=SNSSAI-1|resourceDN=SNSSAI-1
    ...    NRBTS-1/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-1:racParams:maxQuota=76     # 76%*10 = 7.6, max 7 NbrBearer,  common pool
    ...    NRBTS-1/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-1:racParams:minQuota=75     # 75%*10 = 7.5, max 7 NbrBearer,  dedicated pool
    ...    NRBTS-1/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-2:nrResourceList:resourceDN=SNSSAI-2|resourceDN=SNSSAI-2
    ...    NRBTS-1/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-2:racParams:maxQuota=24     # 24%*10 = 2.4, max 2 NbrBearer,  common pool.
    ...    NRBTS-1/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-2:racParams:minQuota=14     # 14%*10 = 1.4, max 1 NbrBearer,  dedicated pool.
    ...    ==================================================================================================================s
    [Tags]    QC_****    UPD003_92    CA_LABLE-TTFF(50MHz_TDD_n78+60MHz_TDD_n41+20MHz_FDD_n66+10MHz_FDD_n71)
    Clear Counter files
    Delta Commission Parameters    ${PARAMS_FOR_UPD003_92}
    UE91 NSA Attach to cell1
    UE81 SA Attach to cell12
    Trigger MR scelladd    ${CA_check}
    UE81 setup NBR bearer via PDU session modify
    Trigger ScellChange
    Delta Commission Parameters    ${PARAMS_FOR_UPD003_92_2}
    UE82 SA Attach to cell1 with NBR configured as normal non-gbr drb on scell cell1 since exceed max quota
    Release Ues    ue_id=82
    UE81 NBR bearer deletion via PDU session modify
    UE82 SA Attach to cell1 with NBR bearer successfully
    Check Counters    ${PM_Counters_Check_upd002_92}
#    check wireshark log    ${CURDIR}${/}a2a_E001${/}a2a.ini    wait_string=UEContextReleaseComplete::12
    [Teardown]    E001_Teardown

*** Keywords ***
Common Suite Setup And Setup Airphone Env
  Common Suite Setup
  Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_2T4F

Modify Cfg
    Update Cfg    set_qosflow id=2 5qi=7
    Update Cfg    set_qosflow id=3 5qi=8
    Update Cfg    set_qosflow id=4 5qi=80
    Update Cfg    enb_param id=1 drb_id_begin=3 endc_capable_qci=all
    Update Cfg    set_bearer id=2 ue=91 qci=9 pdn=1 ip=4.7.254.209 default=on trf_type=internal
    Update Cfg    set_bearer id=3 ue=91 qci=8 pdn=1 default=off preprovisioned=on filter=3 precedence=3
    Update Cfg    set_bearer id=4 ue=91 qci=7 pdn=1 default=off preprovisioned=on filter=4 precedence=4
    Update Cfg    set_bearer id=5 ue=91 qci=6 pdn=1 default=off preprovisioned=on filter=5 precedence=5
    Update Cfg    set_bearer id=2 ue=92 qci=9 pdn=1 ip=4.7.254.210 default=on trf_type=internal
    Update Cfg    set_bearer id=3 ue=92 qci=8 pdn=1 default=off preprovisioned=on filter=3 precedence=3
    Update Cfg    set_bearer id=4 ue=92 qci=7 pdn=1 default=off preprovisioned=on filter=4 precedence=4
    Update Cfg    set_bearer id=5 ue=92 qci=6 pdn=1 default=off preprovisioned=on filter=5 precedence=5
    Update Cfg    mme_pool_area id=1 mmegi=1 plmn=311:489 tac_list=777,111,222,444,333,200
    Update Cfg    set_nwslice id=2 snssai=0x01:0xD143A6 ue=all amf=1
    ${V2}    catenate    ue_param id=91 ue_nr_capabilities=${SA_Capa_perUE_Full_1} dual_conn=eutra_nr
    ...    ue_eutra_nr_capabilities=${Capa_LTE}
    Update Cfg    ${V2}
    ${V3}    catenate    ue_param id=92 ue_nr_capabilities=${SA_Capa_perUE_Full_1} dual_conn=eutra_nr
    ...    ue_eutra_nr_capabilities=${Capa_LTE}
    Update Cfg    ${V3}

E001_Teardown
#    Delta Commission Parameters    ${RECOVER_PARAMS_FOR_UPD003_92}
    Common Test Teardown And Stop Capture Logs

UE81 SA Attach to cell12
    Ue register and pdu setup    ${E001_UE}    ue_id=81    cell_id=12    nwslice=2
#    Send Throughput    ue_id=1    times=2
#    Wait Until Keyword Succeeds    30s    5s    Verify Throughput    ue_id=1    Tput_dl=60

UE82 SA Attach to cell1 with NBR configured as normal non-gbr drb on scell cell1 since exceed max quota
    Ue register and pdu setup    ${E001_UE}    ue_id=82    cell_id=1    nwslice=2

UE82 SA Attach to cell1 with NBR bearer successfully
    Ue register and pdu setup    ${E001_UE}    ue_id=82    cell_id=1    nwslice=2

Attach UE2 and trigger scell addition and new drbs added
    Ue register and pdu setup    ${E001_UE}    ue_id=2    cell_id=2    pass_regexp=${UE_register_and_A1_configured}
    Trigger MR scelladd    ${CA_check_E001}    ue_id=2
    Send Throughput    ue_id=2    times=4
    Wait Until Keyword Succeeds    30s    5s    Verify Throughput    ue_id=2    Tput_dl=360
    Add new drbs

Add new drbs
    Execute Egate Command    ue_pdu_session_modify ue=2 pdu=1 qosflows_to_add=3 by=amf    pass_regexp=Added QosFlow with QFI:2 5QI:8
    Send Throughput    ue_id=2    qfi=2
    Execute Egate Command    ue_pdu_session_modify ue=2 pdu=1 qosflows_to_add=4 by=amf    pass_regexp=Added QosFlow with QFI:3 fiveQI:80
    Send Throughput    ue_id=2    qfi=3
    Execute Egate Command    set_pdu_param ue=2 pdu=2 trf_type=internal
    ${ret}    Execute Egate Command    ue_pdu_session_setup ue=2 pdu=2 nwslice=1 gw=2    pass_regexp=Setup QosFlow with QFI:1 5QI:6
    Send Throughput    ue_id=2    pdu=2    qfi=1
    Wait Until Keyword Succeeds    30s    5s    Check Traffic    ue_id=2    cell_num=4    min_dl_tput=720

Trigger Scell swap and add new drb
    Trigger ScellSwap    ue_id=2    scell_id=3    phycell_id=63
    Wait Until Keyword Succeeds    5s    1s    Check Traffic After Swap    ue_id=2    cell_num=3    min_dl_tput=720
    Execute Egate Command    ue_pdu_session_modify ue=2 pdu=1 qosflows_to_add=2 by=amf    pass_regexp=Added QosFlow with QFI:4 5QI:7
    Send Throughput    ue_id=2    qfi=4
    Wait Until Keyword Succeeds    5s    1s    Check Traffic After Swap    ue_id=2    cell_num=3    min_dl_tput=840

Trigger Scell swap back
    Trigger ScellSwap    ue_id=2    scell_id=4    phycell_id=61
    Wait Until Keyword Succeeds    5s    1s    Check Traffic    ue_id=2    cell_num=4    min_dl_tput=840

UE91 NSA Attach to cell1
    NSA UE Initial ENDC    ue_id=91    target_cells=1    selected_plmn=${PLMN_2}    pass_regexp=${Cell1_Attach}
    Start And Check Traffic

UE91 add Bearers
    Add New DRB    ue_id=91    bearer_id=5
    Start And Check Traffic    ue_id=91    bearer_id=5
    Add New DRB    ue_id=91    bearer_id=3
    Start And Check Traffic    ue_id=91    bearer_id=3    total_dl=30

UE92 add and release bearers
    NSA UE Initial ENDC    ue_id=92    target_cells=1    pass_regexp=${Cell1_Attach}
    Start And Check Traffic    ue_id=92    bearer_id=2    dl_traffic=160    total_dl=130
    UE92 add bearers
    Release DRB    ue_id=92    bearer_id=4
    Release DRB    ue_id=92    bearer_id=5
    Add New DRB    ue_id=92    bearer_id=5
    Start And Check Traffic    ue_id=92    bearer_id=5    dl_traffic=160    total_dl=130
    Add New DRB    ue_id=92    bearer_id=4
    Start And Check Traffic    ue_id=92    bearer_id=4    dl_traffic=160    total_dl=100

UE92 add bearers
    Add New DRB    ue_id=92    bearer_id=5
    Start And Check Traffic    ue_id=92    bearer_id=5    dl_traffic=160    total_dl=130
    Add New DRB    ue_id=92    bearer_id=4
    Start And Check Traffic    ue_id=92    bearer_id=4    dl_traffic=160    total_dl=130
    Add New DRB    ue_id=92    bearer_id=3
    Start And Check Traffic    ue_id=92    bearer_id=3    dl_traffic=160    total_dl=100

UE91 add and release bearers and scell addition after HO
    Trigger A2 ScellRelease    ue_id=91    carrierfreq=${carrierfreq_phycell50}
    Trigger Intra gNB Inter Freq HO From Cell14 to Cell12
    Release DRB    ue_id=91    bearer_id=3
    Add gNB Cell1 As Scell By A1    ue_id=91    carrierfreq=${carrierfreq_phycell61_63}    pass_CA=${Cell12_Cell1}
    Add New DRB    ue_id=91    bearer_id=5
    Start And Check Traffic    ue_id=91    bearer_id=5
    Add New DRB    ue_id=91    bearer_id=3
    Start And Check Traffic    ue_id=91    bearer_id=3

Add New DRB
    [Arguments]    ${ue_id}=91    ${bearer_id}=3
    Execute Egate Command    enb_ue_dc_modify ue=${ue_id} bearer_to_add=${bearer_id} by=enb cause=RN_action_desirable_for_radio_reasons
    ...    pass_regexp=rrcConnectionReconfigurationComplete

Release DRB
    [Arguments]    ${ue_id}=91    ${bearer_id}=3
    Execute Egate Command    enb_ue_dc_modify ue=${ue_id} bearer_to_release=${bearer_id} by=enb cause=RN_action_desirable_for_radio_reasons
    ...    pass_regexp=rrcConnectionReconfigurationComplete

Add gNB Cell1 As Scell By A1
    [Arguments]    ${ue_id}=91    ${carrierfreq}=${carrierfreq_phycell61_63}    ${pass_CA}=none
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A1
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=90 ssinr_nr=59 srsrq_nr=90
    ...    pass_regexp=${pass_CA}

NSA UE Initial ENDC
    [Arguments]    ${ue_id}=91    ${target_cells}=12    ${selected_plmn}=311:489    ${pass_regexp}=Successfully reconfigured dual connectivity
    Execute Egate Command    ue_attach id=${ue_id}    UE IS ACTIVE
    Execute Egate Command    enb_endc_param id=1 selected_plmn=${selected_plmn}
    Execute Egate Command    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${target_cells} bearer=2 type=split_scg
    ...    pass_regexp=${pass_regexp}

Start And Check Traffic
    [Arguments]    ${ue_id}=91    ${bearer_id}=2    ${dl_traffic}=55    ${total_dl}=45
    Execute Egate Command    data_trf_start ue=${ue_id} id=${bearer_id} dir=dl mbps=${dl_traffic}    UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} id=${bearer_id} dir=ul mbps=10    UDP UL
    Wait Until Keyword Succeeds    30s    5s    Verify Throughput on Pcell    ue_id=${ue_id}    bearer_id=${bearer_id}    total_dl=${total_dl}

Verify Throughput on Pcell
    [Arguments]    ${ue_id}=91    ${total_dl}=8    ${total_ul}=8    ${bearer_id}=2
    ${scell8_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=8    type=pdsch    rate_type=ave
    ${ul_throuput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=${bearer_id}    direction=ul    dc_cell_group=all    rate_type=ave
    Should Be True    ${ul_throuput}/1000>${total_ul}
    ${dl_throuput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=${bearer_id}    direction=dl    dc_cell_group=scg    rate_type=ave
    Should Be True    ${dl_throuput}/1000>${total_dl}

Trigger Intra gNB Inter Freq HO From Cell12 to Cell14
    Trigger UE A3 Measurement Report    ue_id=91

Trigger Intra gNB Inter Freq HO From Cell14 to Cell12
    Trigger UE A3 Measurement Report    ue_id=91    carrierfreq=${carrierfreq_phycell61_63}    phycell_id=61

Trigger UE A3 Measurement Report
    [Arguments]    ${ue_id}=91    ${carrierfreq}=${carrierfreq_phycell61_63}    ${phycell_id}=63
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A3
    ${V3}    catenate
    ...    ue_measurement_send_nr id=91 meas_id=${meas_id} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=${phycell_id} nrsrp_nr=60 nrsrq_nr=60
    ...    rs_type=ssb index=0 nrs_result=30:30:30
    Execute Egate Command    ${V3}    SgNBModificationConfirm
    Wait Until Keyword Succeeds    30s    5s    Verify Throughput on Pcell

Trigger A2 ScellRelease
    [Arguments]    ${carrierfreq}=${carrierfreq_phycell50}    ${ue_id}=92    ${scell_id}=9
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}    event_type=A2    carrierfreq=${carrierfreq}
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 scell=${scell_id} scell_rsrp=7 scell_rsrq=7
    ...    pass_regexp=SgNBModificationConfirm

Verify Throuput For 2CC
    [Arguments]    ${ue_id}=91    ${total_dl_tput}=30    ${ul}=15
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=8    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000 > 0
    ${scell1_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=9    type=pdsch    rate_type=ave
    Should Be True    ${scell1_tput}/1000 > 0
    ${total_dl}    Evaluate    ${scell0_tput}+${scell1_tput}
    Should Be True     ${total_dl}/1000 > ${total_dl_tput}
    ${ul_throughput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=8    type=pusch    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul}

Ue register and pdu setup
    [Arguments]    ${SA_Capa_perUE_Full}=null    ${ue_id}=1    ${cell_id}=2    ${nwslice}=1    ${pass_regexp}=QoS Routing Table
    Update UE capa    ${SA_Capa_perUE_Full}    ${ue_id}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=UE now in NG RM Registere
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    ${ret}    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=${nwslice} gw=${ue_id}    pass_regexp=${pass_regexp}

Trigger MR scelladd
    [Arguments]    ${scell_added_log}    ${ue_id}=81    ${carrierfreq}=126970
    ${meas_id}=    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A1
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=80 srsrq_nr=52
    ...    pass_regexp=${scell_added_log}

Update UE capa
    [Arguments]    ${SA_Capa_perUE_Full}=none    ${ue_id}=1
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full}
    Execute Egate Command    ${cmd}

Send Throughput
    [Arguments]    ${ue_id}=1    ${times}=2    ${mbps}=150    ${pdu}=1    ${qfi}=1
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} dir=ul mbps=20 trf_id=10    UE ${ue_id}: UDP UL
    :For    ${I}    IN RANGE    1    ${times}
    \    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} dir=dl mbps=${mbps} trf_id=${I}    UE ${ue_id}: UDP DL
    END

Verify Throughput
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${qfi}=1    ${Tput_dl}=800    ${Tput_ul}=16
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    direction=ul    rate_type=ave
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pdsch    Throughput
    Should Not Match Regexp    ${scell_tput}    CellIndex-[0-3] *0 *0 *0
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

Trigger ScellSwap
    [Arguments]    ${event_type}=A6    ${carrierfreq}=126970    ${nrsrp_nr}=5    ${nrsrq_nr}=5    ${ue_id}=2    ${scell_id}=3
    ...    ${phycell_id}=63
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type}
    ...    srsrp_nr=11 srsrq_nr=11 scell=${scell_id} scell_rsrp=20 scell_rsrq=20 phycell_id=${phycell_id} nrsrp_nr=${nrsrp_nr} nrsrq_nr=${nrsrq_nr}
    Execute Egate Command    ${cmd}    pass_regexp=rrcReconfigurationComplete

Check Traffic
    [Arguments]     ${ue_id}=2    ${cell_num}=4    ${min_dl_tput}=500    ${min_ul_tput}=8
    ${ul_throuput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pusch    rate_type=ave
    ${total_dl_tput}    Set Variable    0
    FOR    ${index}    IN RANGE    0    ${cell_num}
         ${str_index}    Convert To String    ${index}
         ${scell_tput}    Ap Get Throuput On Specific Scell    ${ue_id}    ${str_index}    pdsch
         Should Be True    ${scell_tput}/1000 > 10
         ${total_dl_tput}    Evaluate    ${scell_tput}+${total_dl_tput}
    END
    Should Be True    ${total_dl_tput}/1000 > ${min_dl_tput}
    Should Be True    ${ul_throuput}/1000 > ${min_ul_tput}

Check Traffic After Swap
    [Arguments]     ${ue_id}=2    ${cell_num}=3    ${min_dl_tput}=500    ${min_ul_tput}=60
    ${ul_throuput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pusch    rate_type=ave
    ${total_dl_tput}    Set Variable    0
    FOR    ${index}    IN RANGE    0    ${cell_num}
         ${str_index}    Convert To String    ${index}
         ${scell_tput}    Ap Get Throuput On Specific Scell    ${ue_id}    ${str_index}    pdsch
         Should Be True    ${scell_tput}/1000 > 10
         ${total_dl_tput}    Evaluate    ${scell_tput}+${total_dl_tput}
    END
    ${scell_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=4    type=pdsch    rate_type=ave
    ${total_dl_tput}    Evaluate    ${scell_tput}+${total_dl_tput}
    Should Be True    ${total_dl_tput}/1000 > ${min_dl_tput}
    Should Be True    ${ul_throuput}/1000 > ${min_ul_tput}

Trigger A2 ScellRelease for SA
    [Arguments]    ${carrierfreq}=508110    ${ue_id}=81    ${scell_id}=3    ${pass_check}=rrcReconfigurationComplete
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}    event_type=A2    carrierfreq=${carrierfreq}
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 scell=${scell_id} scell_rsrp=7 scell_rsrq=7
    ...    pass_regexp=${pass_check}

Scell release one by one For UE2
    [Arguments]    ${ue_id}=2
    Trigger A2 ScellRelease for SA    carrierfreq=${carrierfreq_phycell61_63}    ue_id=${ue_id}    scell_id=3
    Wait Until Keyword Succeeds    30s    5s    Check Traffic    ue_id=${ue_id}    cell_num=3    min_dl_tput=840
    Trigger A2 ScellRelease for SA    carrierfreq=${carrierfreq_phycell60}    ue_id=${ue_id}    scell_id=2
    Wait Until Keyword Succeeds    30s    5s    Check Traffic    ue_id=${ue_id}    cell_num=2    min_dl_tput=840
    Trigger A2 ScellRelease for SA    carrierfreq=${carrierfreq_phycell50}    ue_id=${ue_id}    scell_id=1
    Wait Until Keyword Succeeds    30s    5s    Check Traffic    ue_id=${ue_id}    cell_num=1    min_dl_tput=500

Trigger ScellChange
    [Arguments]    ${event_type}=A1    ${carrierfreq}=126970    ${srsrp_nr}=100    ${ue_id}=81
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type}
    ...    srsrp_nr=${srsrp_nr}
    ${rst}=    Execute Egate Command    ${cmd}    pass_regexp=rrcReconfigurationComplete
#    ${ret1}=    Remove String    ${rst}    \r    \n    ${SPACE}
#    Should not Contain    ${ret1}    eventIdeventA6

UE PDU Session Modify to Add
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${fiveQi}=5    ${qfi}=2    ${qosflows}=2    ${pass_regexp}=${EMPTY}
    ...    ${fail_regexp}=${EMPTY}
    Start RRC Log    PDU_Session_Modify_to_Add_${ue_id}_${fiveQi}
    ${ret1}=    Execute Egate Command
    ...    ue_pdu_session_modify ue=${ue_id} pdu=${pdu} qosflows_to_add=${qosflows} by=amf
    ...    pass_regexp=${pass_regexp}    fail_regexp=${fail_regexp}
    Should Contain    ${ret1}    Created FiveQi:Qfi mapping fiveQi ${fiveQi} qfi ${qfi}
    Get RRC Log

UE PDU Session Modify to Del
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${fiveQi}=1    ${qfi}=3    ${qosflows}=3    ${pass_regexp}=${EMPTY}
    ...    ${fail_regexp}=${EMPTY}
    Start RRC Log    PDU_Session_Modify_to_Del_${ue_id}_${fiveQi}
    ${ret1}=    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu} qosflows_to_del=${qosflows} by=amf
    ...    pass_regexp=${pass_regexp}    fail_regexp=${fail_regexp}
    Should Contain    ${ret1}    Removed FiveQi:Qfi mapping fiveQi ${fiveQi} qfi ${qfi}
    Get RRC Log

UE81 setup NBR bearer via PDU session modify
    [Arguments]    ${ue_id}=81
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=2 by=amf    Pdu Session Resource Modify Response

UE81 NBR bearer deletion via PDU session modify
    [Arguments]    ${ue_id}=81
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_del=2 by=amf    Pdu Session Resource Modify Response




