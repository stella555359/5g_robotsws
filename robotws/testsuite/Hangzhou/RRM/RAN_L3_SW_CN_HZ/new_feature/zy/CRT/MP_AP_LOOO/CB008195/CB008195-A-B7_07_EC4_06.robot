*** Settings ***
Documentation
...    author: Zhang Yin
...    contact: yin.zhang@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup       Common Suite Setup And Setup IPHY Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_VRF    SBTS00    RAN_5G    RAN_5G_FDD    CRT    CLOUD_5G_I_MP_AP_LOOO
...               team-VRF3_8    owner-chendong.he    release-SBTS24R3
Resource    testsuite/Hangzhou/RRM/RAN_L3_SW_CN_HZ/resources/DevHZ5_resource.robot

*** Variables ***
${CONFIG_WA}    ${False}
${GNB1_CONFIG}    fdd_sansa_cmwv/FS/6cells

@{PARAMS_IN_SCF}
...    @{CB008847}
...    @{8195_parameters}
...    @{SA_mode}
...    @{8225_parameters}
...    @{UEAssistanceInformation_para}
...    @{5GC000732}
...    @{5GC000876}
...    @{5GC002426}
...    @{B7_ET_07_parameters}
...    @{EC4_ET_06_parameters}
...    @{delete_nsa_config_in_golden}
...    @{inter_RAT_HO_modification}
...    NRCELL-1:numOfRadioResReservForTempUse=0
...    NRCELL-2:numOfRadioResReservForTempUse=0
...    NRCELL-3:numOfRadioResReservForTempUse=0
...    NRCELL-4:numOfRadioResReservForTempUse=1
...    NRCELL-5:numOfRadioResReservForTempUse=0
...    NRCELL-6:numOfRadioResReservForTempUse=0

@{5GC002426}
...    NRBTS:actConnRrcPooling=true    NRBTS:actScheUePooling=true
...    NRCELL:pucchModeSelect=longPucch

@{5GC000876}
# poolid 12 cell1 RAC parameter
...    NRBTS-1/NRCELLGRP-0:maxNumOfRrcCGRPSA=5
...    NRBTS-1/NRCELLGRP-0:maxNumOfNonGBRBearersCGRPSA=5
...    NRCELL-1:maxNumOfUsersPerNRCell=10
...    NRCELL-1:maxNumOfCaUsersNRCell=10
...    NRCELL-1:maxNumOfUsersPerCell=10
...    NRCELL-1:maxNumOfRrcSA=10
...    NRCELL-1:maxNumOfNrDcSnUsers=10
...    NRCELL-1:maxNumOfSCellAlloc=10
...    NRCELL-1:maxNumOfNonGBRBearersSA=10

# poolid 12 cell4 RAC parameter
...    NRBTS-1/NRCELLGRP-3:maxNumOfRrcCGRPSA=10
...    NRBTS-1/NRCELLGRP-3:maxNumOfNonGBRBearersCGRPSA=10
...    NRCELL-4:maxNumOfUsersPerNRCell=5
...    NRCELL-4:maxNumOfCaUsersNRCell=5
...    NRCELL-4:maxNumOfUsersPerCell=5
...    NRCELL-4:maxNumOfRrcSA=5
...    NRCELL-4:maxNumOfSCellAlloc=5
...    NRCELL-4:maxNumOfNrDcSnUsers=5
...    NRCELL-4:maxNumOfNonGBRBearersSA=5

# poolid 12 cell 5 RAC parameter
...    NRBTS-1/NRCELLGRP-4:maxNumOfRrcCGRPSA=275
...    NRCELL-5:maxNumOfUsersPerNRCell=275
...    NRCELL-5:maxNumOfCaUsersNRCell=250
...    NRCELL-5:maxNumOfUsersPerCell=275
...    NRCELL-5:maxNumOfRrcSA=275
...    NRCELL-5:maxNumOfSCellAlloc=250
...    NRCELL-5:maxNumOfNrDcSnUsers=275

@{SA_mode}
...    MRBTS-1/NRBTS-1:gNbCuType=SA
...    MRBTS-1/NRBTS-1/NRCELL-1:cellDepType=SA
...    MRBTS-1/NRBTS-1/NRCELL-2:cellDepType=SA
...    MRBTS-1/NRBTS-1/NRCELL-3:cellDepType=SA
...    MRBTS-1/NRBTS-1/NRCELL-4:cellDepType=SA
...    MRBTS-1/NRBTS-1/NRCELL-5:cellDepType=SA
...    MRBTS-1/NRBTS-1/NRCELL-6:cellDepType=SA
...    MRBTS-1/NRBTS-1:x2LinkSupervisionTmr=0
...    delete:MRBTS-1/NRBTS-1/NRCELL-1:configuredEpsTac
...    delete:MRBTS-1/NRBTS-1/NRCELL-2:configuredEpsTac
...    delete:MRBTS-1/NRBTS-1/NRCELL-3:configuredEpsTac
...    delete:MRBTS-1/NRBTS-1/NRCELL-4:configuredEpsTac
...    delete:MRBTS-1/NRBTS-1/NRCELL-5:configuredEpsTac
...    delete:MRBTS-1/NRBTS-1/NRCELL-6:configuredEpsTac

@{8195_parameters}
...    NRBTS:actSliceAwareAdmissionCtrl=true
...    NRCELL-1:sliceAwareAdmissionCtrlEnabled=true
...    NRCELL-4:sliceAwareAdmissionCtrlEnabled=true
...    @{irrelevant_paramaters}
...    NRCELL-1:nrResourceGroupProfileRacDN=MRBTS-1/NRBTS-1/NRRESOURCEGROUP_PROFILE-1
...    NRCELL-4:nrResourceGroupProfileRacDN=MRBTS-1/NRBTS-1/NRRESOURCEGROUP_PROFILE-2
...    NRBTS/NRRESOURCEGROUP_PROFILE-1:applyCellRacForPrivilegedUE=0
...    NRBTS/NRRESOURCEGROUP_PROFILE-1:defaultRgNsaList:nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS/NRRESOURCEGROUP_PROFILE-1:defaultRgNsaList:nrResourceGroupId=1
...    NRBTS/NRRESOURCEGROUP_PROFILE-1:defaultRgSaList:nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS/NRRESOURCEGROUP_PROFILE-1:defaultRgSaList:nrResourceGroupId=1
...    NRBTS/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-1:nrResourceList:resourceDN=MRBTS-1/NRBTS-1/SNSSAI-1
...    NRBTS/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-1:racParams:maxQuota=70
...    NRBTS/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-1:racParams:minQuota=30
...    NRBTS/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-2:nrResourceList:resourceDN=MRBTS-1/NRBTS-1/SNSSAI-2
...    NRBTS/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-2:racParams:maxQuota=40
...    NRBTS/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-2:racParams:minQuota=10
...    NRBTS/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-3:nrResourceList:resourceDN=MRBTS-1/NRBTS-1/SNSSAI-3
...    NRBTS/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-3:racParams:maxQuota=40
...    NRBTS/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-3:racParams:minQuota=20
...    NRBTS/NRRESOURCEGROUP_PROFILE-2:applyCellRacForPrivilegedUE=0
...    NRBTS/NRRESOURCEGROUP_PROFILE-2:defaultRgNsaList:nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS/NRRESOURCEGROUP_PROFILE-2:defaultRgNsaList:nrResourceGroupId=1
...    NRBTS/NRRESOURCEGROUP_PROFILE-2:defaultRgSaList:nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS/NRRESOURCEGROUP_PROFILE-2:defaultRgSaList:nrResourceGroupId=1
...    NRBTS/NRRESOURCEGROUP_PROFILE-2/NRRESOURCEGROUP-1:nrResourceList:resourceDN=MRBTS-1/NRBTS-1/SNSSAI-1
...    NRBTS/NRRESOURCEGROUP_PROFILE-2/NRRESOURCEGROUP-1:racParams:maxQuota=20
...    NRBTS/NRRESOURCEGROUP_PROFILE-2/NRRESOURCEGROUP-1:racParams:minQuota=20
...    NRBTS/NRRESOURCEGROUP_PROFILE-2/NRRESOURCEGROUP-2:nrResourceList:resourceDN=MRBTS-1/NRBTS-1/SNSSAI-2
...    NRBTS/NRRESOURCEGROUP_PROFILE-2/NRRESOURCEGROUP-2:racParams:maxQuota=40
...    NRBTS/NRRESOURCEGROUP_PROFILE-2/NRRESOURCEGROUP-2:racParams:minQuota=20
...    NRBTS/NRRESOURCEGROUP_PROFILE-2/NRRESOURCEGROUP-3:nrResourceList:resourceDN=MRBTS-1/NRBTS-1/SNSSAI-3
...    NRBTS/NRRESOURCEGROUP_PROFILE-2/NRRESOURCEGROUP-3:racParams:maxQuota=40
...    NRBTS/NRRESOURCEGROUP_PROFILE-2/NRRESOURCEGROUP-3:racParams:minQuota=20
...    NRBTS:rgMinQuotaReservationLevel=cell_and_multicell_level
...    NRBTS/NRRESOURCEGROUP_PROFILE-1:bypassRgLimits=4
...    NRBTS/NRRESOURCEGROUP_PROFILE-2:bypassRgLimits=4
...    NRBTS/NRPMRNL-1:miNrCellUtilPerNrg=15min
...    NRBTS/NRPMRNL-1:miNrF1CC=15min
...    NRBTS/NRPMRNL-1:miNrRRCC=15min
...    NRBTS/NRPMRNL-1:miNrNGCC=15min
...    @{Slice_config}

@{irrelevant_paramaters}
...    NRCELL-1:actPriorityAccess=false
...    NRCELL-1:actEmergencyCall=false
...    NRCELL-4:actPriorityAccess=false
...    NRCELL-4:actEmergencyCall=false
...    NRBTS:actDrbPreemption=false
...    NRBTS:actUserPreemption=false

@{8225_parameters}
...    NRBTS:actRrcInactState=intra-gNB
...    NRBTS:drbRrcInactInactivityTimerSA=600
...    NRBTS:rrcInactIMMSteeringEnabled=false
...    NRBTS:rrcInactLocationReportEnabled=false
...    NRBTS:drbInactivityTimerSA=600
...    NRBTS:maxUeRrcInactTime=4     # ue will release after UE in inactive timeout
...    NRBTS:outOfConnectedPreference=idle
...    NRBTS:srbInactivityTimerSA=600
...    NRBTS:t380=10min
...    NRBTS:act3gppBL23R1=true
...    NRCELL-1/NRPLMNSET_SA-1:ranAC=0
...    NRCELL-4/NRPLMNSET_SA-1:ranAC=0

@{UEAssistanceInformation_para}
...    NRBTS:actRrcReleasePreference=true
...    NRBTS:rrcInactPreferredStateEnabled=true
...    NRBTS:tRanPagingGuard=4
...    NRBTS:timerReleasePreferenceProhibit=s5

@{Slice_config}
...    SNSSAI-1:sst=1
...    SNSSAI-1:sd=13714341
...    SNSSAI-1:nrPlmnDNList=${NRPLMNDNLIST_1}
...    SNSSAI-2:sst=1
...    SNSSAI-2:sd=13714342
...    SNSSAI-2:nrPlmnDNList=${NRPLMNDNLIST_1}
...    SNSSAI-3:sst=1
...    SNSSAI-3:sd=13714343
...    SNSSAI-3:nrPlmnDNList=${NRPLMNDNLIST_1}
...    @{TRACKINGAREA}

@{TRACKINGAREA}
...    TRACKINGAREA-788:snssaiList:snssaiDN=SNSSAI-1|snssaiDN=SNSSAI-1
...    TRACKINGAREA-788:snssaiList:snssaiDN=SNSSAI-2|snssaiDN=SNSSAI-2
...    TRACKINGAREA-788:snssaiList:snssaiDN=SNSSAI-3|snssaiDN=SNSSAI-3

@{5GC000732}
...    NRBTS-1:rrcReestabTypeSA=sameGNB
...    MRBTS-1/NRBTS-1:tWaitingRlRecover=4000ms

${NRPLMNDNLIST_1}    MRBTS-1/NRBTS-1/NRPLMN-1

@{CB008847}
...    NRBTS:actBbPoolTddFr1=true
...    NRBTS:actBbPoolExtensionTddFr1=true
...    NRBTS:actBbPoolTddFr1AlgEnh=true
...    NRBTS:actBbPoolTddFr1Enh

@{delete_nsa_config_in_golden}
...    delete:MRBTS-1/NRBTS-1/NRCELL-1/NRPLMNSET_NSA-1
...    delete:MRBTS-1/NRBTS-1/NRCELL-2/NRPLMNSET_NSA-1
...    delete:MRBTS-1/NRBTS-1/NRCELL-3/NRPLMNSET_NSA-1
...    delete:MRBTS-1/NRBTS-1/NRCELL-4/NRPLMNSET_NSA-1
...    delete:MRBTS-1/NRBTS-1/NRCELL-5/NRPLMNSET_NSA-1
...    delete:MRBTS-1/NRBTS-1/NRCELL-6/NRPLMNSET_NSA-1

@{B7_ET_07_parameters}
...    @{CB008806}

@{CB008806}
...    NRBTS-1:actIntraFreqHoSA=true
...    NRBTS-1:actInterFreqHoSA=true
...    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrRelReportCu=15min
...    NRBTS:actIntraNrNgHo=sourceAndTarget
...    NRBTS-1:suppCnPartialAdNgHo=false
...    NRBTS:tNgRelocExecDeltN=3000
...    NRBTS:tNgRelocCancelN=2000
...    NRBTS:tNgRelocOverallN=2000
...    NRBTS:tNgRelocPrepN=2000
...    NRBTS:timerXnDataFwdGuard=2000
...    NRCELL:a1MeashoEnabledSA=rsrp
...    NRCELL:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=20
...    NRCELL:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=80
...    NRCELL:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL:a2MeashoEnabledSA=rsrp
...    NRCELL:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=26
...    NRCELL:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=80
...    NRCELL:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms40
...    NRCELL:a3MeasEnabled=rsrp
...    NRCELL:a3MeasSsbRsrp:a3HysteresisSsbRsrp=4
...    NRCELL:a3MeasSsbRsrp:a3OffsetSsbRsrp=2
...    NRCELL:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms320
...    NRCELL:absThreshSsbRsrpConsolidation=0
...    NRCELL:measGapSelectionSA=favourUeThroughput
...    NRCELL/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRCELL/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms80
...    NRCELL/NRHOIF-1:cellDepType=SA
...    NRCELL/NRHOIF-1:freqBandIndicatorNR=41
...    NRCELL/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL/NRHOIF-1:ssbFrequency=513150
...    NRCELL/NRHOIF-1:ssBurstSetPeriod=20

...    NRCELL/NRHOIF-2:a3MeasEnabled=rsrp
...    NRCELL/NRHOIF-2:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRCELL/NRHOIF-2:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL/NRHOIF-2:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms80
...    NRCELL/NRHOIF-2:cellDepType=SA
...    NRCELL/NRHOIF-2:freqBandIndicatorNR=66
...    NRCELL/NRHOIF-2:ifhoSsbScs=15KHz
...    NRCELL/NRHOIF-2:ifhoSsbSmtcDuration=sf1
...    NRCELL/NRHOIF-2:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL/NRHOIF-2:numberOfTransmittedSsBlocks=1 beam
...    NRCELL/NRHOIF-2:ssbFrequency=427970
...    NRCELL/NRHOIF-2:ssBurstSetPeriod=20
...    NRCELL/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL/NRREL-1:gNbId=35
...    NRCELL/NRREL-1:gNbIdLength=22
...    NRCELL/NRREL-1:lcrId=1
...    NRCELL/NRREL-1:removeNotAllowed=false
...    NRCELL/NRREL-1:nrDcAllowed=false
...    NRCELL/NRREL-1:gnbPlmn:mcc=311
...    NRCELL/NRREL-1:gnbPlmn:mnc=489
...    NRCELL/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL/NRREL-1:handoverAllowedSA=XnHoNotAllowed
...    NRCELL/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL/NRREL-2:gNbId=36
...    NRCELL/NRREL-2:gNbIdLength=22
...    NRCELL/NRREL-2:lcrId=1
...    NRCELL/NRREL-2:removeNotAllowed=false
...    NRCELL/NRREL-2:nrDcAllowed=false
...    NRCELL/NRREL-2:gnbPlmn:mcc=311
...    NRCELL/NRREL-2:gnbPlmn:mnc=489
...    NRCELL/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL/NRREL-2:handoverAllowedSA=allowed

...    NRCELL-3/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-3/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-3/NRREL-3:gNbId=1
...    NRCELL-3/NRREL-3:gNbIdLength=22
...    NRCELL-3/NRREL-3:lcrId=4
...    NRCELL-3/NRREL-3:removeNotAllowed=false
...    NRCELL-3/NRREL-3:nrDcAllowed=false
...    NRCELL-3/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-3/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-3/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-3/NRREL-3:handoverAllowedSA=allowed
...    @{NRADJGNB}
...    @{NRADJNRCELL}

@{NRADJGNB}
...    NRBTS/NRADJGNB-1:administrativeState=Unlocked
...    NRBTS/NRADJGNB-1:gNbIdLength=22
...    NRBTS/NRADJGNB-1:gNodeBId=35
...    NRBTS/NRADJGNB-1:gNodeBIdCtrl=oamControlled
...    NRBTS/NRADJGNB-1:weightForIgnbCaSelection=1
...    NRBTS/NRADJGNB-1:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-1:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJGNB-2:administrativeState=Unlocked
...    NRBTS/NRADJGNB-2:gNbIdLength=22
...    NRBTS/NRADJGNB-2:gNodeBId=36
...    NRBTS/NRADJGNB-2:gNodeBIdCtrl=oamControlled
...    NRBTS/NRADJGNB-2:weightForIgnbCaSelection=1
...    NRBTS/NRADJGNB-2:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-2:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-2:gnbPlmn:mncLength=3

@{NRADJNRCELL}
...    NRBTS/NRADJNRCELL-1:cellDepType=SA
...    NRBTS/NRADJNRCELL-1:fiveGsTac=200
...    NRBTS/NRADJNRCELL-1:freqBandIndicatorNR=41
...    NRBTS/NRADJNRCELL-1:gNbId=35
...    NRBTS/NRADJNRCELL-1:gNbIdLength=22
...    NRBTS/NRADJNRCELL-1:lcrId=1
...    NRBTS/NRADJNRCELL-1:nrarfcn=513234
...    NRBTS/NRADJNRCELL-1:physCellId=381
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mncLength=3
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:ssbFrequency=513150
...    NRBTS/NRADJNRCELL-2:cellDepType=SA
...    NRBTS/NRADJNRCELL-2:fiveGsTac=200
...    NRBTS/NRADJNRCELL-2:freqBandIndicatorNR=41
...    NRBTS/NRADJNRCELL-2:gNbId=36
...    NRBTS/NRADJNRCELL-2:gNbIdLength=22
...    NRBTS/NRADJNRCELL-2:lcrId=1
...    NRBTS/NRADJNRCELL-2:nrarfcn=513234
...    NRBTS/NRADJNRCELL-2:physCellId=382
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mncLength=3
...    MRBTS-1/NRBTS-1/NRADJNRCELL-2:ssbFrequency=513150

#supported UE Power Saving's releasePreference-r16
${SA_Capa_UAI_Inactive}    SEPARATOR=
...    E9A09000575F5A13160003C3A000B0498B800CE1E84804D9061CF
...    9863CA160704C020311C03EE3614606B04610D04083A41A00DAD9
...    31563439F11C7A067D813E31238F21CFA8E7CC31E50B0381C3C17
...    0005F001C0017C00170000381D06C4DC0D608C21A081074834019
...    5B262AC4873EC09F11C78C48E3C873EA39F30C7942C0E070F09FD
...    817C007F605F0005C0000E0541B11B582308682041E20D00656C9
...    8AB121CFB027C471E31238F21CFA8E7CC31E50B0381C3C27F0000
...    001FC000000170000381506C41D608C21A0810788340195B262AC
...    4873EC09F11C78C48E3C873EA39F30C7942C0E070F09FC0AAAAA7
...    F02AAAA85C0000E003281C46040000120541C1401C46000002120
...    561E1400061180004120560E14040003010758785000182800020
...    083A85C41000E208007118000028483803808D00A200040411500
...    08606813B639F0E14E9DB1CF870A24ED8E7C38113639F0E1449DB
...    1CF8712006C73E1BD05C0078005038280381804A00E000C048008
...    0C07C120040000000200000401000000008000010040000100200
...    000C0100000800800005004002008020080000600400003802001
...    00000004000040020000240100080601802000028010000160080
...    0409024010000180672A6B2A6B052B032B066B056B296B266B016
...    B036B012B022B07681A0800004B29282000032CA4A0800014B292
...    02000072CA480800024B292020000B2CA480800034B292020000F
...    2CA480800044B29202000132CA480800054B29202000172CA4A08
...    00064B29202000062CA480629555D2AAAA55174AA2A82C55038AA
...    0D154A62A93455018AA051549AAA83C50B00BC04A8140A0502814
...    0A05028140A05028140A05028140A000A00101E01820200400008
...    0600C101002008040300000080C00410100200804008001008060
...    0C02018030080600C3543E00020406080C0E1416181A202224262
...    8303236383A3E424A4C4E5052545A5E82822F0380C000C029440000840

@{releasePreference_check}
...     QoS Routing Table
...     releasePreference-r16 supported

@{delta_commission_B7_07}
...    NRBTS/NRCELLGRP-0:addNumOfNonGBRBearersCGRPSAHo=1
...    NRBTS/NRCELLGRP-0:addNumOfRrcCGRPSAHo=1

@{PM_Counters_Check_B7_07}
...    NRCELL-1:NNGCC:${NG_FLOW_SETUP_FAIL_RRNA}=0
...    NRCELL-1:NF1CC:${NRD_RRC_STPREQ_PER_CELL_REJ_CU}=0
...    NRCELL-1:NRRCC:${NRRRC_RRC_REJECT_DU_TRIGG_RECD}=0
...    NRCELL-1:NRRCC:${NRRCC_RRC_STPREJ_MO_DATA}=0
...    NRCELL-1:NRCCD:${NRD_RRC_RESUME_REQUEST1_REJECT}=0
...    NRCELL-1/NRRESOURCEGROUP-1:${AVG_NUM_UE_NOM_NRG}>0
...    NRCELL-1/NRRESOURCEGROUP-1:${DNOM_SAMPLES_NRG}>0
...    NRCELL-1/NRRESOURCEGROUP-1:${AVE_NUM_NGBR_NOM_NRG}>0
...    NRCELL-1/NRRESOURCEGROUP-1:${PEAK_NUM_UE_NRG}=5
...    NRCELL-1/NRRESOURCEGROUP-1:${PEAK_NUM_NGBR_NRG}=5
...    NRCELL-1/NRRESOURCEGROUP-1:${NUM_ADM_REQ_NGBR_NRG}=7
...    NRCELL-1/NRRESOURCEGROUP-1:${NUM_ADM_SUC_NGBR_NRG}=6
...    NRCELL-1/NRRESOURCEGROUP-1:${NUM_ADM_REQ_UE_NRG}=7
...    NRCELL-1/NRRESOURCEGROUP-1:${NUM_ADM_SUC_UE_NRG}=6
...    NRCELL-1/NRRESOURCEGROUP-1:${RAC_REJ_DUE_DRB_MAX_QUOTA_NRG}=0
...    NRCELL-1/NRRESOURCEGROUP-1:${RAC_REJ_DUE_UE_MAX_QUOTA_NRG}=0

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

${NG_FLOW_SETUP_FAIL_RRNA}    M55125C10501
${NRD_RRC_STPREQ_PER_CELL_REJ_CU}    M55113C03001
${NRRRC_RRC_REJECT_DU_TRIGG_RECD}    M55124C01011
${NRRCC_RRC_STPREJ_MO_DATA}    M55124C01022
${NRD_RRC_RESUME_REQUEST1_REJECT}    M55166C00509

@{EC4_ET_06_parameters}
...    XNLINK-1:cPlaneIpAddr=10.0.1.125

@{inter_RAT_HO_modification}
...    NRBTS:actInterRatHoFromEutraToSA=true
...    NRBTS:actInterRatHoSA=true
...    NRBTS:nonContentRachAcFullConfigHo=true
...    NRBTS:tNgRelocExecDeltL=5000
...    NRBTS/NRADJECELL-1:eNodeBId=18
...    NRBTS/NRADJECELL-1:ePSTrackingAreaCode=0
...    NRBTS/NRADJECELL-1:earfcnValue=1
...    NRBTS/NRADJECELL-1:lcrId=1
...    NRBTS/NRADJECELL-1:physCellId=11
...    NRBTS/NRADJECELL-1:ecgiPlmn:mcc=311
...    NRBTS/NRADJECELL-1:ecgiPlmn:mnc=489
...    NRBTS/NRADJECELL-1:ecgiPlmn:mncLength=3
...    NRBTS/NRADJECELL-1:enbPlmn:mcc=311
...    NRBTS/NRADJECELL-1:enbPlmn:mnc=489
...    NRBTS/NRADJECELL-1:enbPlmn:mncLength=3

...    NRHOIR-1:allowedMeasBandwidth=mbw100
...    NRHOIR-1:b2MeashoEnabled=rsrp
...    NRHOIR-1:b2Threshold1hoRsrp=35
...    NRHOIR-1:b2Threshold1hoRsrpVoNr=35
...    NRHOIR-1:b2Threshold1hoRsrq=50
...    NRHOIR-1:b2Threshold1hoRsrqVoNr=50
...    NRHOIR-1:earfcnValue=1
...    NRHOIR-1:eutraFreqQOffsetRange=0dB
...    NRHOIR-1:eutraB2MeashoRsrp:b2HysteresishoRsrp=0|b2TimeToTriggerhoRsrpVoNr=ms512
...    NRHOIR-1:eutraB2MeashoRsrp:b2HysteresishoRsrpVoNr=4|b2TimeToTriggerhoRsrpVoNr=ms512
...    NRHOIR-1:eutraB2MeashoRsrp:b2Threshold2hoRsrp=18|b2TimeToTriggerhoRsrpVoNr=ms512
...    NRHOIR-1:eutraB2MeashoRsrp:b2Threshold2hoRsrpVoNr=28|b2TimeToTriggerhoRsrpVoNr=ms512
...    NRHOIR-1:eutraB2MeashoRsrp:b2TimeToTriggerhoRsrp=ms480|b2TimeToTriggerhoRsrpVoNr=ms512
...    NRHOIR-1:eutraB2MeashoRsrq:b2HysteresishoRsrq=0|b2TimeToTriggerhoRsrqVoNr=ms512
...    NRHOIR-1:eutraB2MeashoRsrq:b2HysteresishoRsrqVoNr=4|b2TimeToTriggerhoRsrqVoNr=ms512
...    NRHOIR-1:eutraB2MeashoRsrq:b2Threshold2hoRsrq=2|b2TimeToTriggerhoRsrqVoNr=ms512
...    NRHOIR-1:eutraB2MeashoRsrq:b2Threshold2hoRsrqVoNr=10|b2TimeToTriggerhoRsrqVoNr=ms512
...    NRHOIR-1:eutraB2MeashoRsrq:b2TimeToTriggerhoRsrq=ms480|b2TimeToTriggerhoRsrqVoNr=ms512

...    NRCELL-4:measGapSelectionSA=favourUeThroughput
...    NRCELL-4:a1MeashoEnabled=rsrpAndRsrq
...    NRCELL-4:a2MeashoEnabled=rsrpAndRsrq
...    NRCELL-4:a1MeashoEnabledSA=rsrpAndRsrq
...    NRCELL-4:a1MeashoSsbRsrqSA:a1HysteresishoSsbRsrqSA=0|a1TimeToTriggerHoSsbRsrqVoNr=ms256
...    NRCELL-4:a1MeashoSsbRsrqSA:a1HysteresisHoSsbRsrqVoNr=6|a1TimeToTriggerHoSsbRsrqVoNr=ms256
...    NRCELL-4:a1MeashoSsbRsrqSA:a1ThresholdhoSsbRsrqSA=30|a1TimeToTriggerHoSsbRsrqVoNr=ms256
...    NRCELL-4:a1MeashoSsbRsrqSA:a1ThresholdHoSsbRsrqVoNr=40|a1TimeToTriggerHoSsbRsrqVoNr=ms256
...    NRCELL-4:a1MeashoSsbRsrqSA:a1TimeToTriggerhoSsbRsrqSA=ms480|a1TimeToTriggerHoSsbRsrqVoNr=ms256
...    NRCELL-4/NRRELE-1:cellIndividualOffset=0dB
...    NRCELL-4/NRRELE-1:eNodeBId=18
...    NRCELL-4/NRRELE-1:eutranCellExcluded=false
...    NRCELL-4/NRRELE-1:lcrId=1
...    NRCELL-4/NRRELE-1:removeNotAllowed=false
...    NRCELL-4/NRRELE-1:ecgiPlmn:mcc=311
...    NRCELL-4/NRRELE-1:ecgiPlmn:mnc=489
...    NRCELL-4/NRRELE-1:ecgiPlmn:mncLength=3
...    NRCELL-4:nrhoirDNList=MRBTS-1/NRBTS-1/NRHOIR-1

@{PM_Counters_Check_EC4_06}
...    NRCELL-4:NNGCC:${NG_FLOW_SETUP_FAIL_RRNA}=0
...    NRCELL-4:NF1CC:${NRD_RRC_STPREQ_PER_CELL_REJ_CU}=0
...    NRCELL-4:NRRCC:${NRRRC_RRC_REJECT_DU_TRIGG_RECD}=0
...    NRCELL-4:NRRCC:${NRRCC_RRC_STPREJ_MO_DATA}=0
...    NRCELL-4:NRCCD:${NRD_RRC_RESUME_REQUEST1_REJECT}=0
...    NRCELL-4/NRRESOURCEGROUP-1:${AVG_NUM_UE_NOM_NRG}>0
...    NRCELL-4/NRRESOURCEGROUP-1:${DNOM_SAMPLES_NRG}>0
...    NRCELL-4/NRRESOURCEGROUP-1:${AVE_NUM_NGBR_NOM_NRG}>0
...    NRCELL-4/NRRESOURCEGROUP-1:${PEAK_NUM_UE_NRG}=1
...    NRCELL-4/NRRESOURCEGROUP-1:${PEAK_NUM_NGBR_NRG}=1
...    NRCELL-4/NRRESOURCEGROUP-1:${NUM_ADM_REQ_NGBR_NRG}=1
...    NRCELL-4/NRRESOURCEGROUP-1:${NUM_ADM_SUC_NGBR_NRG}=1
...    NRCELL-4/NRRESOURCEGROUP-1:${NUM_ADM_REQ_UE_NRG}=1
...    NRCELL-4/NRRESOURCEGROUP-1:${NUM_ADM_SUC_UE_NRG}=1
...    NRCELL-4/NRRESOURCEGROUP-1:${RAC_REJ_DUE_DRB_MAX_QUOTA_NRG}=0
...    NRCELL-4/NRRESOURCEGROUP-1:${RAC_REJ_DUE_UE_MAX_QUOTA_NRG}=0

...    NRCELL-4/NRRESOURCEGROUP-2:${AVG_NUM_UE_NOM_NRG}>0
...    NRCELL-4/NRRESOURCEGROUP-2:${DNOM_SAMPLES_NRG}>0
...    NRCELL-4/NRRESOURCEGROUP-2:${AVE_NUM_NGBR_NOM_NRG}>0
...    NRCELL-4/NRRESOURCEGROUP-2:${PEAK_NUM_UE_NRG}=1
...    NRCELL-4/NRRESOURCEGROUP-2:${PEAK_NUM_NGBR_NRG}=1
...    NRCELL-4/NRRESOURCEGROUP-2:${NUM_ADM_REQ_NGBR_NRG}=1
...    NRCELL-4/NRRESOURCEGROUP-2:${NUM_ADM_SUC_NGBR_NRG}=1
...    NRCELL-4/NRRESOURCEGROUP-2:${NUM_ADM_REQ_UE_NRG}=1
...    NRCELL-4/NRRESOURCEGROUP-2:${NUM_ADM_SUC_UE_NRG}=1
...    NRCELL-4/NRRESOURCEGROUP-2:${RAC_REJ_DUE_DRB_MAX_QUOTA_NRG}=0
...    NRCELL-4/NRRESOURCEGROUP-2:${RAC_REJ_DUE_UE_MAX_QUOTA_NRG}=0

...    NRCELL-4/NRRESOURCEGROUP-3:${AVG_NUM_UE_NOM_NRG}>0
...    NRCELL-4/NRRESOURCEGROUP-3:${DNOM_SAMPLES_NRG}>0
...    NRCELL-4/NRRESOURCEGROUP-3:${AVE_NUM_NGBR_NOM_NRG}>0
...    NRCELL-4/NRRESOURCEGROUP-3:${PEAK_NUM_UE_NRG}=2
...    NRCELL-4/NRRESOURCEGROUP-3:${PEAK_NUM_NGBR_NRG}=2
...    NRCELL-4/NRRESOURCEGROUP-3:${NUM_ADM_REQ_NGBR_NRG}=6
...    NRCELL-4/NRRESOURCEGROUP-3:${NUM_ADM_SUC_NGBR_NRG}=5
...    NRCELL-4/NRRESOURCEGROUP-3:${NUM_ADM_REQ_UE_NRG}=6
...    NRCELL-4/NRRESOURCEGROUP-3:${NUM_ADM_SUC_UE_NRG}=5
...    NRCELL-4/NRRESOURCEGROUP-3:${RAC_REJ_DUE_DRB_MAX_QUOTA_NRG}=0
...    NRCELL-4/NRRESOURCEGROUP-3:${RAC_REJ_DUE_UE_MAX_QUOTA_NRG}=1

*** Test Cases ***
CB008195-A-B7_ET_07_01_SA UE admission dynamic cell limits check for during incoming inter-gNB NG handover
    [Documentation]
    ...    The test scenario is intended to verify SA UE admission dynamic cell limits check
    ...    for during incoming inter-gNB NG handover, scaling Factor is smaller than 1.
    ...    2. Configuration
    ...       a.SA,FDD+FDD, CA(band 71+band 71)
    ...       b.rgRacMinQuotaLimitationInfo saclingFactor 0.833 = 5 / 10 * 60%
    ...    3. Test Case Steps:
    ...       a.Register 4 UEs Slice1 at Cell1 to make Cell1 RG1 resource maxQuota reaches.
    ...       Expected result:4 UEs Slice MaxQuota Reaches.
    ...       b.UE2 NG Handover to Sim Gnb3 Cell1 PCI381.
    ...       Expected result:UE2 NG handover to Sim Gnb3 Successfully.
    ...       c.Register UE4 Slice1 to LNCELL-1 to make Cell1 RG1 resource maxQuota reaches again.
    ...       Expected result:UE4 Setup Slice1 successfully.
    ...       d.UE2 NG Handover from Sim Gnb3 Cell1 PCI381 back LNCELL-1.
    ...       Expected result: UE2 NG Handover Failure due to LNCELL-1 RG1 maxQuota reaches.
    ...       e. modify NRBTS/NRCELLGRP-0:addNumOfNonGBRBearersCGRPSAHo=1 and NRBTS/NRCELLGRP-0:addNumOfRrcCGRPSAHo=1
    ...       Expected result: delta commission successfully.
    ...       f. UE2 NG Handover from Sim Gnb3 Cell1 PCI381 back LNCELL-1 again.
    ...       Expected result: UE2 NG Handover from Sim Gnb3 Cell1 PCI381 successfully due to additional cell group resources for HO configured.
    [Tags]    c1    owner-chendong.he
    Clear Counter files
    Register 4 UEs Slice1 at Cell1
    UE2 Inter Gnb NG Handover To Sim381
    Register UE5 Slice1 at Cell1
    UE2 Inter Gnb NG Handover back Cell1 Failure
    Online Update HO cell group additional resouce    ${delta_commission_B7_07}
    UE2 Inter Gnb NG Handover back Cell1 Successfully
    Check Counters    pm_counters_expression=${PM_Counters_Check_B7_07}
    Release Ues    ue_type=sa    ue_id=1-5

CB008195-A-EC4_ET_06_01_Counters for Admission for incoming HO dynamic cell limits check
    [Documentation]
    ...    The test scenario is intended to verify Counters for admission for incoming HO dynamic cell limits check
    ...    refer: USCB008195-PMO-A#7: Counters for Admission for incoming HO - failure
    ...           CB008195-A#EC4: Admission for incoming HO - failure
    ...           5G_RAN_USR_RRM_23885,5G_RAN_USR_RRM_23892,5G_RAN_USR_RRM_24525,5G_RAN_USR_RRM_23889
    ...    2. Configuration
    ...       a.SA,FDD+FDD, CA(band 66+band 66)
    ...       b.NRCELL-4:numOfRadioResReservForTempUse=1
    ...         NRCELL-4:maxNumOfRrcSA=5
    ...         NRCELL-4:maxNumOfNonGBRBearersSA=5
    ...       c.NRCELL-4 RG1 minQuota=1 maxQuota=1
    ...         NRCELL-4 RG2 minQuota=1 maxQuota=2
    ...         NRCELL-4 RG3 minQuota=1 maxQuota=2
    ...    3. Test Case Steps:
    ...       a.Register batch UEs to fill RG1 RG2 dedicated pool full and RG3 dedicated pool and common pool.
    ...         Register UE1 Slice1 to cell4
    ...         Register UE2 Slice2 to cell4
    ...         Register UE3 Slice3 to cell4
    ...         Register UE4 Slice3 to cell4
    ...       Expected result:4 UEs Registers successfully.
    ...       b.Register UE5 Slice3 at Cell3 and prepare to Inter-frequency to Cell3.
    ...       Expected result:UE5 register successfully.
    ...       c.UE5 Inter-frequency handover to cell4.
    ...       Expected result:UE5 Inter-frequency failure due to maxQuota reaches in RG3 and counter will increase.
    ...       d.UE4 deregister.
    ...       Expected result:UE4 deregister successfully.
    ...       e.UE5 Inter-frequency handover to cell4 again.
    ...       Expected result:UE5 Inter-frequency successfully.
    ...       f.UE5 XN HO to simGnb and back to cell4.
    ...       Expected result:UE5 XN handover successfully.
    ...       g.UE5 Inter-RAT handover and back to cell4.
    ...       Expected result:UE5 Inter-RAT handover back successfully.
    [Tags]    c2    owner-chendong.he    crt-true
    Clear Counter files
    Register 5 UEs to Cell4 and Cell3
    UE5 interFrequency HO to Cell4 Unsuccessfully
    UE4 Deregister
    UE5 interFrequency HO to Cell4 Successfully
    UE5 XN HO to simGnb4 and Back to Cell4 successfully
    UE5 interRat HO to simGnb5 and Back to Cell4 successfully
    Check Counters    pm_counters_expression=${PM_Counters_Check_EC4_06}
    Release Ues    ue_type=sa    ue_id=1-5

*** Keywords ***
Common Suite Setup And Setup IPHY Env
    Common Suite Setup
    Setup Airphone Env    tl_type=${GNB1_CONFIG}    ue_count=40
    Execute Egate Command    gnb_param id=3 sa_ho=ng_based measEvent=A2 measEvent=A3
    Execute Egate Command    gnb_endc_param id=3 use_nr_ran_cont=true
    Execute Egate Command    gnb_endc_param id=3 scg_dl_dist_percent=0
    Execute Egate Command    gnb_endc_param id=3 enable_dud_poll_bit=0

Modify Cfg
    Update Cfg    set_qosflow id=1 5qi=8 default=on
    Update Cfg    set_qosflow id=2 5qi=7 ue=all
    Update Cfg    set_qosflow id=3 5qi=6 ue=all
    Update Cfg    set_qosflow id=4 5qi=9 ue=all
    Update Cfg    set_qosflow id=5 5qi=5 ue=all
    Update Cfg    set_nwslice id=1 snssai=0x01:0xD143A5 ue=all amf=1 default=on
    Update Cfg    set_nwslice id=2 snssai=0x01:0xD143A6 ue=all amf=1 qos_flows=2 default=off
    Update Cfg    set_nwslice id=3 snssai=0x01:0xD143A7 ue=all amf=1 qos_flows=3 default=off
    ${set_gnb3}    catenate
    ...    set_gnb id=3 type=simulated plmn=311:489 ng=10.0.1.123 gnb_id=0x23:22 daemon=10.0.2.1:22222 x2_peers=none
    ...    xn=10.0.1.122 nssai=0x1:0xd143a5,0x01:0xD143A6,0x01:0xD143A7 amf=1
    Update Cfg    ${set_gnb3}
    ${set_gnb3_cell1}    catenate    set_cell id=1 gnb=3 pci=127:0 tac=788 nrci=0x01 tdd_cell=on proxy=10.0.2.90:9999 nr_arfcn=513234:513234
    ...    gscn=6414 mandatory_for_activation=off
    Update Cfg    ${set_gnb3_cell1}
    ${set_gnb4}    catenate
    ...    set_gnb id=4 type=simulated plmn=311:489 ng=10.0.1.124 gnb_id=0x24:22 daemon=10.0.2.1:22222 x2_peers=none
    ...    xn=10.0.1.125 nssai=0x1:0xd143a5,0x01:0xD143A6,0x01:0xD143A7 amf=1
    Update Cfg    ${set_gnb4}
    ${set_gnb4_cell1}    catenate    set_cell id=1 gnb=4 pci=127:1 tac=788 nrci=0x01 tdd_cell=on proxy=10.0.2.91:9999 nr_arfcn=513234:513234
    ...    gscn=6414 mandatory_for_activation=off
    ${set_gnb5}    catenate    set_gnb id=5 type=simulated plmn=311:489 ng=10.0.1.126 daemon=10.0.2.1:22222 gnb_id=0x12:28
    ...    nssai=0x01:0xD143A5
    Update Cfg    ${set_gnb5}
    ${set_gnb5_cell1}    catenate    set_cell id=1 gnb=5 pci=3:2 earfcn=1:18001 tac=0 proxy=10.0.2.92:12218 nrci=0x1
    ...    tdd_cell=on bw=20MHz technology=lte
    Update Cfg    ${set_gnb5_cell1}
    Update Cfg    gnb_param id=5 xn_listening_socket=true
    Update Cfg    ${set_gnb4_cell1}
    Delete Cfg    set_ue simulated id=11
    Delete Cfg    ue_param id=11
    Delete Cfg    set_bearer id=2 ue=11

Register 4 UEs Slice1 at Cell1
    Register UE1 Slice1 at Cell1
    Register UE2 Slice1 at Cell1
    Register UE3 Slice1 at cell1
    Register UE4 Slice1 at cell1

Register UE1 Slice1 at Cell1
    UE attach with PDU    ue_id=1    target_cell_id=1    pdu_id=1    gw1=1    nwslice1=1

Register UE2 Slice1 at Cell1
    UE attach with PDU    ue_id=2    target_cell_id=1    pdu_id=1    gw1=1    nwslice1=1

Register UE3 Slice1 at cell1
    UE attach with PDU    ue_id=3    target_cell_id=1    pdu_id=1    gw1=1    nwslice1=1

UE2 Inter Gnb NG Handover To Sim381
    Trigger A2 measurement report    ue_id=2    carrierfreq=126290
    Trigger A3 Measurement Report    ue_id=2    carrierfreq=513150    phycelId=381
    ...    pass_check=Inter-eNB handover from EXT_ENB-2.1 to ENB-3.1 performed

Register UE4 Slice1 at Cell1
    UE attach with PDU    ue_id=4    target_cell_id=1    pdu_id=1    gw1=1    nwslice1=1

Register UE5 Slice1 at Cell1
    UE attach with PDU    ue_id=5    target_cell_id=1    pdu_id=1    gw1=1    nwslice1=1

UE attach with PDU
    [Arguments]    ${ue_id}=1    ${target_cell_id}=1    ${pdu_id}=1    ${gw1}=1
    ...    ${nwslice1}=1    ${pass_regexp}=UE now in NG RM Register    ${pdu_pass_regexp}=${releasePreference_check}
    Update UE capa    ue_id=${ue_id}    SA_Capa_perUE_Full=${SA_Capa_UAI_Inactive}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${target_cell_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=${pass_regexp}
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=${gw1} nwslice=${nwslice1}    pass_regexp=${pdu_pass_regexp}

UE2 Inter Gnb NG Handover back Cell1 Failure
    Trigger A2 measurement report    ue_id=2    carrierfreq=513150
    Trigger A3 Measurement Report    ue_id=2    carrierfreq=126290    phycelId=50    pass_check=RAN radio resources not available

UE2 Inter Gnb NG Handover back Cell1 Successfully
    Trigger A3 Measurement Report    ue_id=2    carrierfreq=126290    phycelId=50    pass_check=handover from ENB-3.1 to EXT_ENB-2.1 performed

Trigger A2 measurement report
    [Arguments]    ${ue_id}    ${carrierfreq}    ${pass_check}=rrcReconfigurationComplete
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A2
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 srsrp_nr=3 srsrq_nr=5
    ...    pass_regexp=${pass_check}    sleep_time=1

Trigger A3 Measurement Report
    [Arguments]    ${ue_id}    ${carrierfreq}    ${phycelId}    ${pass_check}    ${nrsrp_nr}=60    ${nrsrq_nr}=60
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A3
    ${V3}    catenate
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=${phycelId} nrsrp_nr=${nrsrp_nr}
    ...    nrsrq_nr=${nrsrq_nr}
    Execute Egate Command    ${V3}    pass_regexp=${pass_check}    sleep_time=2

Trigger A3 Measurement Report And Wait Failure
    [Arguments]    ${ue_id}    ${carrierfreq}    ${phycelId}    ${fail_check}    ${nrsrp_nr}=60    ${nrsrq_nr}=60
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A3
    ${V3}    catenate
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=${phycelId} nrsrp_nr=${nrsrp_nr}
    ...    nrsrq_nr=${nrsrq_nr}
    Execute Egate Command    ${V3}    fail_regexp=${fail_check}    sleep_time=3

Trigger B2 Measurement Report
    [Arguments]    ${ue_id}    ${carrierfreq}    ${phycelId}    ${pass_check}    ${nrsrp_nr}=30    ${nrsrq_nr}=30
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}
    ...    event_type=B2    carrierfreq_rat=EUTRAN
    ${V3}    catenate
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=B2 srsrp_nr=11 srsrq_nr=11 phycell_id=${phycelId} nrsrp_nr=${nrsrp_nr}
    ...    nrsrq_nr=${nrsrq_nr}
    Execute Egate Command    ${V3}    pass_regexp=${pass_check}    sleep_time=2

Update UE capa
    [Arguments]    ${ue_id}    ${SA_Capa_perUE_Full}=none
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full}
    Execute Egate Command    ${cmd}

Online Update HO cell group additional resouce
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir

Register 5 UEs to Cell4 and Cell3
    Register UE1 Slice1 at Cell4
    Register UE2 Slice2 at Cell4
    Register UE3 Slice3 at Cell4
    Register UE4 Slice3 at Cell4
    Register UE5 Slice3 at Cell3

Register UE1 Slice1 at Cell4
    UE attach with PDU    ue_id=1    target_cell_id=4    pdu_id=1    gw1=1    nwslice1=1

Register UE2 Slice2 at Cell4
    UE attach with PDU    ue_id=2    target_cell_id=4   pdu_id=1    gw1=1    nwslice1=2

Register UE3 Slice3 at Cell4
    UE attach with PDU    ue_id=3    target_cell_id=4    pdu_id=1    gw1=1    nwslice1=3

Register UE4 Slice3 at Cell4
    UE attach with PDU    ue_id=4    target_cell_id=4    pdu_id=1    gw1=1    nwslice1=3

Register UE5 Slice3 at Cell3
    UE attach with PDU    ue_id=5    target_cell_id=3    pdu_id=1    gw1=1    nwslice1=3

UE5 interFrequency HO to Cell4 Unsuccessfully
    Trigger A2 measurement report    ue_id=5    carrierfreq=424090
    Trigger A3 Measurement Report And Wait Failure
    ...    ue_id=5    carrierfreq=427970    phycelId=53    fail_check=Intra-eNB handover from EXT_ENB-2.3 to EXT_ENB-2.4

UE5 interFrequency HO to Cell4 Successfully
    Trigger A3 Measurement Report
    ...    ue_id=5    carrierfreq=427970    phycelId=53    pass_check=Intra-eNB handover from EXT_ENB-2.3 to EXT_ENB-2.4

UE5 XN HO to simGnb4 and Back to Cell4 successfully
    UE5 XN Handover to simGnb4
    UE5 XN Handover back to Cell4

UE5 XN Handover to simGnb4
    Trigger A2 measurement report    ue_id=5    carrierfreq=427970
    Trigger A3 Measurement Report
    ...    ue_id=5    carrierfreq=513150    phycelId=382    pass_check=Inter-eNB handover from EXT_ENB-2.4 to ENB-4.1 performed

UE5 XN Handover back to Cell4
    Trigger A2 measurement report    ue_id=5    carrierfreq=513150
    Trigger A3 Measurement Report
    ...    ue_id=5    carrierfreq=427970    phycelId=53    pass_check=handover from ENB-4.1 to EXT_ENB-2.4 performed

UE5 InterRat HO to simGnb5 and Back to Cell4 successfully
    UE5 InterRAT HO to simGnb5
    UE5 InterRAT HO Back to Cell4 successfully

UE5 InterRat HO to simGnb5
    Trigger A2 measurement report    ue_id=5    carrierfreq=427970
    Trigger B2 Measurement Report    ue_id=5    carrierfreq=1    phycelId=11
    ...    pass_check=Successful handover from EXT_ENB-2.4 to ENB-5.1

UE5 InterRAT HO Back to Cell4 successfully
    Execute Egate Command    gnb_trigger_inter_rat_handover_to_5g ue=5 target_gnb=2 target_cell=4 plmn=311:489
    ...    pass_regexp=ENB-5.1 to EXT_ENB-2.4    sleep_time=2

UE4 Deregister
    UE Deregister From gNB    ue_id=4

UE Deregister From gNB
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s
