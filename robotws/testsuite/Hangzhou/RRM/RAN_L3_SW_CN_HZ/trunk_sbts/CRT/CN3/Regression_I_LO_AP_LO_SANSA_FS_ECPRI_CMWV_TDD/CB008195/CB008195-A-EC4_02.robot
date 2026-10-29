*** Settings ***
Documentation
...    author: kang.xiang
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_VRF    SBTS00    RAN_5G    RAN_5G_TDD    CLOUD_5G_I_LO_AP_LO    team-VRF3_SG8
...    release-SBTS24R3    CRT    owner-kexin.zhou    owner-yin.zhang
Resource    ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{CB008195}
...    @{NRRESOURCEGROUP_PROFILE}
...    @{SNSSAI}
...    @{TAC}
...    @{onlySA}
...    @{CB008225}
...    @{other_resource_reserve}
...    @{limit_maxNumOfRrcSA}
...    @{limit_maxNumOfUsersPerNRCell}
...    @{DuMaxRRCConnection}
...    @{limit_Bearer}
...    @{HO_relate}
...    @{NRADJNRCELL}
...    @{NRHOIF}
...    @{NRREL}
...    @{NRADJGNB}
...    @{5QI1}

@{CB008195}
...    NRBTS:actSliceAwareAdmissionCtrl=true
...    NRCELL:sliceAwareAdmissionCtrlEnabled=true
...    NRCELL-1:nrResourceGroupProfileRacDN=NRRESOURCEGROUP_PROFILE-1
...    NRCELL-2:nrResourceGroupProfileRacDN=NRRESOURCEGROUP_PROFILE-2
...    NRCELL-3:nrResourceGroupProfileRacDN=NRRESOURCEGROUP_PROFILE-3
...    NRBTS:actAdditionalSliceSupport=true
...    NRBTS/NRPMRNL-1:miNrCellUtilPerNrg=5min

@{NRRESOURCEGROUP_PROFILE}
#NRRESOURCEGROUP_PROFILE-0 - PLMN1-SNSSAI-3
...    NRBTS/NRRESOURCEGROUP_PROFILE-0:defaultRgNsaList:nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS/NRRESOURCEGROUP_PROFILE-0:defaultRgNsaList:nrResourceGroupId=1
...    NRBTS/NRRESOURCEGROUP_PROFILE-0:defaultRgSaList:nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS/NRRESOURCEGROUP_PROFILE-0:defaultRgSaList:nrResourceGroupId=1
...    NRBTS/NRRESOURCEGROUP_PROFILE-0/NRRESOURCEGROUP-1:nrResourceList:resourceDN=SNSSAI-3
...    NRBTS/NRRESOURCEGROUP_PROFILE-0/NRRESOURCEGROUP-1:racParams:maxQuota=60
...    NRBTS/NRRESOURCEGROUP_PROFILE-0/NRRESOURCEGROUP-1:racParams:minQuota=10

#NRRESOURCEGROUP_PROFILE-1 - PLMN1-SNSSAI-1,2,3
...    NRBTS/NRRESOURCEGROUP_PROFILE-1:defaultRgNsaList:nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS/NRRESOURCEGROUP_PROFILE-1:defaultRgNsaList:nrResourceGroupId=32
...    NRBTS/NRRESOURCEGROUP_PROFILE-1:defaultRgSaList:nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS/NRRESOURCEGROUP_PROFILE-1:defaultRgSaList:nrResourceGroupId=32
...    NRBTS/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-1:nrResourceList:resourceDN=SNSSAI-1|resourceDN=SNSSAI-1
...    NRBTS/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-1:nrResourceList:resourceDN=SNSSAI-2|resourceDN=SNSSAI-2
...    NRBTS/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-1:racParams:maxQuota=50
...    NRBTS/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-1:racParams:minQuota=20
...    NRBTS/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-2:nrResourceList:resourceDN=SNSSAI-3|resourceDN=SNSSAI-3
...    NRBTS/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-2:racParams:maxQuota=60
...    NRBTS/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-2:racParams:minQuota=10
...    NRBTS/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-32:nrResourceList:resourceDN=SNSSAI-2000|resourceDN=SNSSAI-2000
...    NRBTS/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-32:racParams:maxQuota=40
...    NRBTS/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-32:racParams:minQuota=20

##NRRESOURCEGROUP_PROFILE-2 - PLMN1-SNSSAI-1,2,3
...    NRBTS/NRRESOURCEGROUP_PROFILE-2:defaultRgNsaList:nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS/NRRESOURCEGROUP_PROFILE-2:defaultRgNsaList:nrResourceGroupId=32
...    NRBTS/NRRESOURCEGROUP_PROFILE-2:defaultRgSaList:nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS/NRRESOURCEGROUP_PROFILE-2:defaultRgSaList:nrResourceGroupId=32
...    NRBTS/NRRESOURCEGROUP_PROFILE-2/NRRESOURCEGROUP-1:nrResourceList:resourceDN=SNSSAI-1|resourceDN=SNSSAI-1
...    NRBTS/NRRESOURCEGROUP_PROFILE-2/NRRESOURCEGROUP-1:nrResourceList:resourceDN=SNSSAI-2|resourceDN=SNSSAI-2
...    NRBTS/NRRESOURCEGROUP_PROFILE-2/NRRESOURCEGROUP-1:racParams:maxQuota=50
...    NRBTS/NRRESOURCEGROUP_PROFILE-2/NRRESOURCEGROUP-1:racParams:minQuota=20
...    NRBTS/NRRESOURCEGROUP_PROFILE-2/NRRESOURCEGROUP-2:nrResourceList:resourceDN=SNSSAI-3|resourceDN=SNSSAI-3
...    NRBTS/NRRESOURCEGROUP_PROFILE-2/NRRESOURCEGROUP-2:racParams:maxQuota=60
...    NRBTS/NRRESOURCEGROUP_PROFILE-2/NRRESOURCEGROUP-2:racParams:minQuota=10
...    NRBTS/NRRESOURCEGROUP_PROFILE-2/NRRESOURCEGROUP-32:nrResourceList:resourceDN=SNSSAI-2000|resourceDN=SNSSAI-2000
...    NRBTS/NRRESOURCEGROUP_PROFILE-2/NRRESOURCEGROUP-32:racParams:maxQuota=40
...    NRBTS/NRRESOURCEGROUP_PROFILE-2/NRRESOURCEGROUP-32:racParams:minQuota=20

#NRRESOURCEGROUP_PROFILE-3 - PLMN1-SNSSAI-3
...    NRBTS/NRRESOURCEGROUP_PROFILE-3:defaultRgNsaList:nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS/NRRESOURCEGROUP_PROFILE-3:defaultRgNsaList:nrResourceGroupId=1
...    NRBTS/NRRESOURCEGROUP_PROFILE-3:defaultRgSaList:nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS/NRRESOURCEGROUP_PROFILE-3:defaultRgSaList:nrResourceGroupId=1
...    NRBTS/NRRESOURCEGROUP_PROFILE-3/NRRESOURCEGROUP-1:nrResourceList:resourceDN=SNSSAI-3
...    NRBTS/NRRESOURCEGROUP_PROFILE-3/NRRESOURCEGROUP-1:racParams:maxQuota=70
...    NRBTS/NRRESOURCEGROUP_PROFILE-3/NRRESOURCEGROUP-1:racParams:minQuota=30

...    NRBTS/NRRESOURCEGROUP_PROFILE-0:bypassRgLimits=0
...    NRBTS/NRRESOURCEGROUP_PROFILE-1:bypassRgLimits=0
...    NRBTS/NRRESOURCEGROUP_PROFILE-2:bypassRgLimits=0
...    NRBTS/NRRESOURCEGROUP_PROFILE-3:bypassRgLimits=0


@{SNSSAI}
#SNSSAI-1
...    NRBTS/SNSSAI-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS/SNSSAI-1:drbInactivityTimerSA=10
...    NRBTS/SNSSAI-1:sd=13714341

#SNSSAI-2
...    NRBTS/SNSSAI-2:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS/SNSSAI-2:drbInactivityTimerSA=10
...    NRBTS/SNSSAI-2:sd=13714342

#SNSSAI-3
...    NRBTS/SNSSAI-3:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS/SNSSAI-3:drbInactivityTimerSA=10
...    NRBTS/SNSSAI-3:sd=13714343

...    NRBTS/SNSSAI-2000:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS/SNSSAI-2000:drbInactivityTimerSA=10
...    NRBTS/SNSSAI-2000:sd=13714344

...    NRBTS/SNSSAI-4:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS/SNSSAI-4:drbInactivityTimerSA=10
...    NRBTS/SNSSAI-4:sd=13714345

@{TAC}
...    NRBTS/TRACKINGAREA-200:fiveGsTac=200
...    NRBTS/TRACKINGAREA-200:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1
...    NRBTS/TRACKINGAREA-200:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2
...    NRBTS/TRACKINGAREA-200:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-3|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-3
...    NRBTS/TRACKINGAREA-200:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-4|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-4
...    NRBTS/TRACKINGAREA-200:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2000|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2000

@{CB008225}
...    NRBTS:actRrcInactState=intra-gNB
...    NRBTS:act3gppBL23R1=true
...    NRCELL:ranAC=0
...    NRBTS:drbRrcInactInactivityTimerSA=200
...    NRBTS:maxUeRrcInactTime=60
...    NRBTS:drbInactivityTimerSA=600
...    NRBTS:rrcInactIMMSteeringEnabled=false
...    NRBTS:rrcInactLocationReportEnabled=false
...    NRBTS:rrcInactPreferredStateEnabled=true
...    NRBTS:actRrcReleasePreference=true
...    NRBTS:outOfConnectedPreference=inactive
...    NRBTS:timerReleasePreferenceProhibit=s3
...    NRBTS:tRanPagingGuard=4
...    NRBTS:t380=60min
...    NRBTS:actPaging=true
...    NRBTS:ranPagingCycle=v32
...    NRBTS:activityNotificationLevelSA=ue

@{5QI1}
...    NRBTS/NRDRB-15:cellAggrLevel=Not FR1 CA eligible
...    NRBTS/NRDRB-15:discardTimer=40ms
...    NRBTS/NRDRB-15:discardTimerUl=infinity
...    NRBTS/NRDRB-15:dlFlowControlAlgo=none
...    NRBTS/NRDRB-15:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-4
...    NRBTS/NRDRB-15:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-3
...    NRBTS/NRDRB-15:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRBTS/NRDRB-15:queuingDelayDiscarding=Disabled
...    NRBTS/NRDRB-15:resType=GBR
...    NRBTS/NRDRB-15:rlcMode=RLC_UM
...    NRBTS/NRDRB-15:schedulWeight=1
...    NRBTS/NRDRB-15:nrDrbRlcAmDN=${EMPTY}
...    NRBTS/NRDRB-15:nsaDrbParam=${EMPTY}
...    NRBTS/NRDRB-15:maxDataRateGbrDl=1000
...    NRBTS/NRDRB-15:maxDataRateGbrUl=1000
...    NRBTS/NRDRB-15:maxRlcQueueingDelayGbr=20
...    NRBTS/NRDRB-15:maxTransferDelayGbr=20
...    NRBTS/NRDRB_5QI-6:fiveqiValueList=1
...    NRBTS/NRDRB_5QI-6:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-15
...    NRBTS/NRDRB_MAC-4:lcgid=4
...    NRBTS/NRDRB_MAC-4:schedulBSD=100ms
...    NRBTS/NRDRB_MAC-4:schedulPrio=5
...    NRBTS/NRDRB_PDCP-3:xxFlowControlProfForCuIdx=1
...    NRBTS/NRDRB_PDCP-3:pdcpBufDiscardEnabled=false
...    delete:NRBTS/NRDRB_PDCP-3:pdcpDelayThresh1TrigType
...    delete:NRBTS/NRDRB_PDCP-3:pdcpMaxNumRetxPdu
...    delete:NRBTS/NRDRB_PDCP-3:pdcpPduRetxDelayThresh1
...    delete:NRBTS/NRDRB_PDCP-3:pdcpPduRetxDelayThresh2
...    delete:NRBTS/NRDRB_PDCP-3:pdcpRetxPduSendMaxDelay
...    NRBTS/NRDRB_RLC_UM-1:dlTReassemblyUm=ms50

@{other_resource_reserve}
...    NRBTS:srbInactivityTimerSA=60
...    NRCELL-1:actPriorityAccess=false
...    NRCELL:actEmergencyCall=false
...    NRBTS:actDrbPreemption=false
...    NRBTS:actUserPreemption=false
...    NRCELL:numOfRadioResReservForTempUse=0
...    NRCELL:numOfRadioResReservForEmergency=4
...    NRCELL:numOfRadioResReservForPa=4


@{limit_maxNumOfRrcSA}
...    NRCELL:maxNumOfRrcSA=200
...    NRCELL-2:maxNumOfRrcSA=6    #CB008195-A-EC4_ET_01_01 cell2
...    NRCELLGRP-0:nrCellList=2
...    NRCELLGRP-1:nrCellList=1
...    NRBTS/NRCELLGRP-1:maxNumOfRrcCGRPSA=16
...    NRBTS/NRCELLGRP-0:maxNumOfRrcCGRPSA=15
...    NRBTS/NRDU-1:maxNumOfRrcConUEsPerDU=2448

@{onlySA}
...    NRCELL:cellDepType=SA
...    delete:NRBTS/NRCELL:configuredEpsTac
...    NRBTS:rrcReestabTypeSA=sameGNB

@{limit_maxNumOfUsersPerNRCell}
...    NRCELL-1:maxNumOfUsersPerNRCell=275
...    NRCELL-3:maxNumOfUsersPerNRCell=275
...    NRCELL-2:maxNumOfUsersPerNRCell=6     #CB008195-A-EC4_ET_01_01 cell2
...    NRCELL:maxNumOfUsersPerCell=30
...    NRCELL-2:maxNumOfUsersPerCell=6
...    NRCELL:maxNumOfCaUsersNRCell=30
...    NRCELL-2:maxNumOfCaUsersNRCell=6
...    NRCELL:maxNumOfNrDcSnUsers=30
...    NRCELL-2:maxNumOfNrDcSnUsers=6
...    NRCELL:maxNumOfSCellAlloc=200
...    NRCELL-2:maxNumOfSCellAlloc=6

@{limit_Bearer}
...    NRCELL-1:maxNumOfNonGBRBearersSA=6    #CB008195-A-EC4_ET_27_01 & 02_01 cell1
...    NRCELL:maxNumOfGBRBearersSA=10
...    NRCELL:addNumOfGBRBearers=0
...    NRCELLGRP-0:maxNumOfNonGBRBearersCGRPSA=550
...    NRBTS/NRCELLGRP-0:addNumOfNonGBRBearersCGRPSAHo=0
...    NRCELL:actVoNR=true

@{DuMaxRRCConnection}
...    NRBTS-1:actConnRrcPooling=true
...    NRBTS-1:actScheUePooling=true

@{HO_relate}
...    NRBTS:actConflictConfiguration=true
...    NRBTS:actIntraFreqHoSA=true
...    NRBTS:actInterFreqHoSA=true
...    NRBTS:actIntraNrNgHo=sourceAndTarget
...    NRBTS:tNgRelocExecDeltN=3000
...    NRBTS:tNgRelocCancelN=2000
...    NRBTS:tNgRelocOverallN=2000
...    NRBTS:tNgRelocPrepN=2000
...    NRBTS:suppCnPartialAdNgHo=true
...    NRBTS/NRPMRNL-1:miNrRelReportCu=5min
...    NRBTS:timerXnDataFwdGuard=250
...    NRCELL:cbraPreamblesPerSsb=n64
...    NRCELL:a5MeasEnabled=rsrp
...    NRCELL:absThreshSsbRsrpConsolidation=1
...    NRCELL:absThreshSsbRsrqConsolidation=1
...    XNLINK-3:cPlaneIpAddr=10.0.1.122
...    XNLINK-5:cPlaneIpAddr=10.0.1.124
...    NRCELL:a5MeasSsbRsrp:a5HysteresisSsbRsrp=0
...    NRCELL:a5MeasSsbRsrp:a5Threshold1SsbRsrp=50
...    NRCELL:a5MeasSsbRsrp:a5Threshold2SsbRsrp=60
...    NRCELL:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms40
...    NRCELL-1:measGapSelectionSA=favourUeThroughput

@{NRADJNRCELL}
...    NRADJNRCELL-1:cellDepType=SA
...    NRADJNRCELL-1:freqBandIndicatorNR=78
...    NRADJNRCELL-1:gNbId=35
...    NRADJNRCELL-1:gNbIdLength=22
...    NRADJNRCELL-1:lcrId=1
...    NRADJNRCELL-1:nrAdjNrCellId=1
...    NRADJNRCELL-1:nrarfcn=633372
...    NRADJNRCELL-1:ssbFrequency=633408
...    NRADJNRCELL-1:physCellId=381
...    NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRADJNRCELL-1:gnbPlmn:mnc=489
...    NRADJNRCELL-1:gnbPlmn:mncLength=3
...    NRADJNRCELL-1:fiveGsTac=200

...    NRADJNRCELL-2:cellDepType=SA
...    NRADJNRCELL-2:gNbId=36
...    NRADJNRCELL-2:lcrId=1
...    NRADJNRCELL-2:nrarfcn=648000
...    NRADJNRCELL-2:physCellId=48
...    NRADJNRCELL-2:gnbPlmn:mcc=311
...    NRADJNRCELL-2:gnbPlmn:mnc=489
...    NRADJNRCELL-2:gnbPlmn:mncLength=3
...    NRADJNRCELL-2/ADJ_NRPLMNSET_SA-1:fiveGsTac=0

@{NRHOIF}
...    NRCELL-1/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-1/NRHOIF-1:a5MeasEnabled=rsrp
...    NRCELL-1/NRHOIF-1:cellDepType=SA
...    NRCELL-1/NRHOIF-1:freqBandIndicatorNR=78
...    NRCELL-1/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf3
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-1/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-1:ssbFrequency=633408
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=30
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=20
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms160
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5HysteresisSsbRsrp=0
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5Threshold1SsbRsrp=40
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5Threshold2SsbRsrp=50
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms160

@{NRREL}
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-1:gNbId=35
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:lcrId=1
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3

...    NRCELL-2/NRREL-2:gNbId=36
...    NRCELL-2/NRREL-2:gNbIdLength=22
...    NRCELL-2/NRREL-2:lcrId=1
...    NRCELL-2/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-2:handoverAllowedSA=XnHoNotAllowed

@{NRADJGNB}
...    NRADJGNB-3:administrativeState=Unlocked
...    NRADJGNB-3:gNodeBId=35
...    NRADJGNB-3:gNbIdLength=22
...    NRADJGNB-3:xnLinkRef=3
...    NRADJGNB-3:gnbPlmn:mcc=311
...    NRADJGNB-3:gnbPlmn:mnc=489
...    NRADJGNB-3:gnbPlmn:mncLength=3

...    NRADJGNB-5:administrativeState=Unlocked
...    NRADJGNB-5:gNodeBId=36
...    NRADJGNB-5:gNbIdLength=22
...    NRADJGNB-5:gnbPlmn:mcc=311
...    NRADJGNB-5:gnbPlmn:mnc=489
...    NRADJGNB-5:gnbPlmn:mncLength=3

@{params_lock_cells}
...    NRCELL-1:administrativeState=Locked
...    NRCELL-2:administrativeState=Locked

@{params_unlock_cells}
...    NRCELL-1:administrativeState=Unlocked
@{params_unlock_cell2}
...    NRCELL-2:administrativeState=Unlocked


#UE CAPE
${ue_nr_capabilities}    SEPARATOR=
...    E1A03FA0474E7AEFFFFFAFC2200782E0203C127BE7FFFFF800F00C6FBE00050370101F8E0155DF0A3FE2F08762F82087F540A083D951D2206
...    24FAC41E420F081425BE7E57771DF001DDC77C000CC005000742AEF851FF17843B17C1043FAA05041ECA8E9103127D620F2107840A12DF3F3
...    3BB8EF800EEE3BE000660028003A1577C4DFF8BC21D8BE0821FD502820F65474881893EB1079083C205096F9F95DFC7FC0077F1FF00033001
...    4001D00650389A000000C40A83C4D000C2680004C40AC1C4D080004620540E268400033102B070A0200021881507850001828000298810090
...    0A2026C04605000C2508206811B649F0214285B24F810236C93E04085B24F810276C93E042853B649F000160C318C631BFFFE000138036002
...    800301C1401C0C4270070007000603E0488200000041000002208004000004100080000882001004001040020080220800402008410008040
...    188200100C021040020180601B072F2A2B072F2A28060800004B2CA82000032CB2A0800014B2CA02000072CB2801A83D5D2AAAA0F174AA283
...    839804F9BF01C070079BF01C070079BF01C070079BF01C070079BF01C070079BF01C070079BF01C070079BF01C070079BF01C070079BF01C0
...    700001400600400C010020808020040200801001C0180180400300A00A01801001C0180380400700A01201802001C0380180800301200A028
...    01041C0080180100300400A0080103801001004002004004010001AB0602072125262728770000000361781C06000601A

${OOO_UE_Capabilities}    SEPARATOR=
...    E1A03000074E5A031E0003832001E09306400043C2400C4034026010180E01951B0A3582028680965944C2403D6C10101070EF1C39061C001
...    03278FAB80027800E0009E00151B133582028680965944C2403D6C10101070EF1C39061C00103278FAB80027800E0009E00151B1375820286
...    80965944C2403D6C10101070EF1C39061C00103278FAB80027800E0009E00151B13B582028680965944C2403D6C10101070EF1C39061C0010
...    3278FAA8000028000000841C4D000000002026878003804044F613003000281C1401C0C026007000683E0000000000000E54D000100000965
...    950034AAA84801C002C00000010020046AC4C0004080C1014181C202C4044484C648494989CA1288A0

#Counter

${XN_HO_REQ_RECEIVED}      M55143C00005
${XN_HO_REQ_ACK_SENT}      M55143C00006

${AVG_NUM_UE_NOM_NRG}    M55910C00005
${DNOM_SAMPLES_NRG}    M55910C00006
${AVE_NUM_NGBR_NOM_NRG}    M55910C00007
${PEAK_NUM_UE_NRG}    M55910C00010
${PEAK_NUM_NGBR_NRG}    M55910C00011
${RAC_REJ_DUE_DRB_MAX_QUOTA_NRG}    M55910C00015
${RAC_REJ_DUE_UE_MAX_QUOTA_NRG}    M55910C00016
${NUM_ADM_REQ_NGBR_NRG}    M55910C00017
${NUM_ADM_SUC_NGBR_NRG}    M55910C00018
${NUM_ADM_REQ_UE_NRG}    M55910C00023
${NUM_ADM_SUC_UE_NRG}    M55910C00024

@{EC4_01_01}
...    NRCELL-1/NRRESOURCEGROUP-2:${AVG_NUM_UE_NOM_NRG}>150
...    NRCELL-1/NRRESOURCEGROUP-2:${DNOM_SAMPLES_NRG}>=300
...    NRCELL-1/NRRESOURCEGROUP-2:${AVE_NUM_NGBR_NOM_NRG}>150
...    NRCELL-1/NRRESOURCEGROUP-2:${PEAK_NUM_UE_NRG}=1
...    NRCELL-1/NRRESOURCEGROUP-2:${PEAK_NUM_NGBR_NRG}=1
...    NRCELL-1/NRRESOURCEGROUP-2:${NUM_ADM_REQ_NGBR_NRG}=1
...    NRCELL-1/NRRESOURCEGROUP-2:${NUM_ADM_SUC_NGBR_NRG}=1
...    NRCELL-1/NRRESOURCEGROUP-2:${NUM_ADM_REQ_UE_NRG}=1
...    NRCELL-1/NRRESOURCEGROUP-2:${NUM_ADM_SUC_UE_NRG}=1
...    NRCELL-2/NRRESOURCEGROUP-1:${AVG_NUM_UE_NOM_NRG}>300
...    NRCELL-2/NRRESOURCEGROUP-1:${DNOM_SAMPLES_NRG}>=300
...    NRCELL-2/NRRESOURCEGROUP-1:${AVE_NUM_NGBR_NOM_NRG}>300
...    NRCELL-2/NRRESOURCEGROUP-1:${PEAK_NUM_UE_NRG}=2|3
...    NRCELL-2/NRRESOURCEGROUP-1:${PEAK_NUM_NGBR_NRG}=2|3
...    NRCELL-2/NRRESOURCEGROUP-1:${RAC_REJ_DUE_DRB_MAX_QUOTA_NRG}=0
...    NRCELL-2/NRRESOURCEGROUP-1:${RAC_REJ_DUE_UE_MAX_QUOTA_NRG}=0
...    NRCELL-2/NRRESOURCEGROUP-1:${NUM_ADM_REQ_NGBR_NRG}=4
...    NRCELL-2/NRRESOURCEGROUP-1:${NUM_ADM_SUC_NGBR_NRG}=4
...    NRCELL-2/NRRESOURCEGROUP-1:${NUM_ADM_REQ_UE_NRG}=4
...    NRCELL-2/NRRESOURCEGROUP-1:${NUM_ADM_SUC_UE_NRG}=4
...    NRCELL-2/NRRESOURCEGROUP-2:${AVG_NUM_UE_NOM_NRG}>180
...    NRCELL-2/NRRESOURCEGROUP-2:${DNOM_SAMPLES_NRG}>=300
...    NRCELL-2/NRRESOURCEGROUP-2:${AVE_NUM_NGBR_NOM_NRG}>180
...    NRCELL-2/NRRESOURCEGROUP-2:${PEAK_NUM_UE_NRG}=2
...    NRCELL-2/NRRESOURCEGROUP-2:${PEAK_NUM_NGBR_NRG}=2
...    NRCELL-2/NRRESOURCEGROUP-2:${RAC_REJ_DUE_DRB_MAX_QUOTA_NRG}=0
...    NRCELL-2/NRRESOURCEGROUP-2:${RAC_REJ_DUE_UE_MAX_QUOTA_NRG}=0
...    NRCELL-2/NRRESOURCEGROUP-2:${NUM_ADM_REQ_NGBR_NRG}=2
...    NRCELL-2/NRRESOURCEGROUP-2:${NUM_ADM_SUC_NGBR_NRG}=2
...    NRCELL-2/NRRESOURCEGROUP-2:${NUM_ADM_REQ_UE_NRG}=2
...    NRCELL-2/NRRESOURCEGROUP-2:${NUM_ADM_SUC_UE_NRG}=2
...    NRCELL-2/NRRESOURCEGROUP-32:${AVG_NUM_UE_NOM_NRG}>300
...    NRCELL-2/NRRESOURCEGROUP-32:${DNOM_SAMPLES_NRG}>=300
...    NRCELL-2/NRRESOURCEGROUP-32:${AVE_NUM_NGBR_NOM_NRG}>300
...    NRCELL-2/NRRESOURCEGROUP-32:${PEAK_NUM_UE_NRG}=2
...    NRCELL-2/NRRESOURCEGROUP-32:${PEAK_NUM_NGBR_NRG}=2
...    NRCELL-2/NRRESOURCEGROUP-32:${RAC_REJ_DUE_DRB_MAX_QUOTA_NRG}=0
...    NRCELL-2/NRRESOURCEGROUP-32:${RAC_REJ_DUE_UE_MAX_QUOTA_NRG}=1
...    NRCELL-2/NRRESOURCEGROUP-32:${NUM_ADM_REQ_NGBR_NRG}=3
...    NRCELL-2/NRRESOURCEGROUP-32:${NUM_ADM_SUC_NGBR_NRG}=2
...    NRCELL-2/NRRESOURCEGROUP-32:${NUM_ADM_REQ_UE_NRG}=3
...    NRCELL-2/NRRESOURCEGROUP-32:${NUM_ADM_SUC_UE_NRG}=2

@{RD_Counters_Cell1_case2}
...    NRCELL-1/NRRESOURCEGROUP-1:${AVG_NUM_UE_NOM_NRG}>200
...    NRCELL-1/NRRESOURCEGROUP-1:${DNOM_SAMPLES_NRG}>=300
...    NRCELL-1/NRRESOURCEGROUP-1:${AVE_NUM_NGBR_NOM_NRG}>200
...    NRCELL-1/NRRESOURCEGROUP-1:${PEAK_NUM_UE_NRG}=1
...    NRCELL-1/NRRESOURCEGROUP-1:${PEAK_NUM_NGBR_NRG}=2
...    NRCELL-1/NRRESOURCEGROUP-1:${RAC_REJ_DUE_DRB_MAX_QUOTA_NRG}=3
...    NRCELL-1/NRRESOURCEGROUP-1:${RAC_REJ_DUE_UE_MAX_QUOTA_NRG}=0
...    NRCELL-1/NRRESOURCEGROUP-1:${NUM_ADM_REQ_NGBR_NRG}=4
...    NRCELL-1/NRRESOURCEGROUP-1:${NUM_ADM_SUC_NGBR_NRG}=2
...    NRCELL-1/NRRESOURCEGROUP-1:${NUM_ADM_REQ_UE_NRG}=2
...    NRCELL-1/NRRESOURCEGROUP-1:${NUM_ADM_SUC_UE_NRG}=1
...    NRCELL-1/NRRESOURCEGROUP-2:${AVG_NUM_UE_NOM_NRG}>180
...    NRCELL-1/NRRESOURCEGROUP-2:${DNOM_SAMPLES_NRG}>=300
...    NRCELL-1/NRRESOURCEGROUP-2:${AVE_NUM_NGBR_NOM_NRG}>180
...    NRCELL-1/NRRESOURCEGROUP-2:${PEAK_NUM_UE_NRG}=2
...    NRCELL-1/NRRESOURCEGROUP-2:${PEAK_NUM_NGBR_NRG}=3
...    NRCELL-1/NRRESOURCEGROUP-2:${RAC_REJ_DUE_DRB_MAX_QUOTA_NRG}=3
...    NRCELL-1/NRRESOURCEGROUP-2:${RAC_REJ_DUE_UE_MAX_QUOTA_NRG}=0
...    NRCELL-1/NRRESOURCEGROUP-2:${NUM_ADM_REQ_NGBR_NRG}=5
...    NRCELL-1/NRRESOURCEGROUP-2:${NUM_ADM_SUC_NGBR_NRG}=3
...    NRCELL-1/NRRESOURCEGROUP-2:${NUM_ADM_REQ_UE_NRG}=3
...    NRCELL-1/NRRESOURCEGROUP-2:${NUM_ADM_SUC_UE_NRG}=2

@{RD_Counters_Cell1_case2_afterlock}
...    NRCELL-1/NRRESOURCEGROUP-1:${AVG_NUM_UE_NOM_NRG}>200
...    NRCELL-1/NRRESOURCEGROUP-1:${DNOM_SAMPLES_NRG}>300
...    NRCELL-1/NRRESOURCEGROUP-1:${AVE_NUM_NGBR_NOM_NRG}>600
...    NRCELL-1/NRRESOURCEGROUP-1:${PEAK_NUM_UE_NRG}=2
...    NRCELL-1/NRRESOURCEGROUP-1:${PEAK_NUM_NGBR_NRG}=5
...    NRCELL-1/NRRESOURCEGROUP-1:${RAC_REJ_DUE_DRB_MAX_QUOTA_NRG}=3
...    NRCELL-1/NRRESOURCEGROUP-1:${RAC_REJ_DUE_UE_MAX_QUOTA_NRG}=0
...    NRCELL-1/NRRESOURCEGROUP-1:${NUM_ADM_REQ_NGBR_NRG}=7
...    NRCELL-1/NRRESOURCEGROUP-1:${NUM_ADM_SUC_NGBR_NRG}=5
...    NRCELL-1/NRRESOURCEGROUP-1:${NUM_ADM_REQ_UE_NRG}=3
...    NRCELL-1/NRRESOURCEGROUP-1:${NUM_ADM_SUC_UE_NRG}=2
...    NRCELL-1/NRRESOURCEGROUP-2:${AVG_NUM_UE_NOM_NRG}>200
...    NRCELL-1/NRRESOURCEGROUP-2:${DNOM_SAMPLES_NRG}>300
...    NRCELL-1/NRRESOURCEGROUP-2:${AVE_NUM_NGBR_NOM_NRG}>300
...    NRCELL-1/NRRESOURCEGROUP-2:${PEAK_NUM_UE_NRG}=3
...    NRCELL-1/NRRESOURCEGROUP-2:${PEAK_NUM_NGBR_NRG}=5
...    NRCELL-1/NRRESOURCEGROUP-2:${RAC_REJ_DUE_DRB_MAX_QUOTA_NRG}=3
...    NRCELL-1/NRRESOURCEGROUP-2:${RAC_REJ_DUE_UE_MAX_QUOTA_NRG}=0
...    NRCELL-1/NRRESOURCEGROUP-2:${NUM_ADM_REQ_NGBR_NRG}=8
...    NRCELL-1/NRRESOURCEGROUP-2:${NUM_ADM_SUC_NGBR_NRG}=5
...    NRCELL-1/NRRESOURCEGROUP-2:${NUM_ADM_REQ_UE_NRG}=4
...    NRCELL-1/NRRESOURCEGROUP-2:${NUM_ADM_SUC_UE_NRG}=3

@{RD_Counters_Cell1_case3}
...    NRCELL-1:${XN_HO_REQ_RECEIVED}=3
...    NRCELL-1:${XN_HO_REQ_ACK_SENT}=2
...    NRCELL-1/NRRESOURCEGROUP-2:${AVG_NUM_UE_NOM_NRG}>200
...    NRCELL-1/NRRESOURCEGROUP-2:${DNOM_SAMPLES_NRG}>=300
...    NRCELL-1/NRRESOURCEGROUP-2:${AVE_NUM_NGBR_NOM_NRG}>200
...    NRCELL-1/NRRESOURCEGROUP-2:${PEAK_NUM_UE_NRG}=2
...    NRCELL-1/NRRESOURCEGROUP-2:${PEAK_NUM_NGBR_NRG}=2
...    NRCELL-1/NRRESOURCEGROUP-2:${RAC_REJ_DUE_DRB_MAX_QUOTA_NRG}=0
...    NRCELL-1/NRRESOURCEGROUP-2:${RAC_REJ_DUE_UE_MAX_QUOTA_NRG}=0
...    NRCELL-1/NRRESOURCEGROUP-2:${NUM_ADM_REQ_NGBR_NRG}=2
...    NRCELL-1/NRRESOURCEGROUP-2:${NUM_ADM_SUC_NGBR_NRG}=2
...    NRCELL-1/NRRESOURCEGROUP-2:${NUM_ADM_REQ_UE_NRG}=2
...    NRCELL-1/NRRESOURCEGROUP-2:${NUM_ADM_SUC_UE_NRG}=2
...    NRCELL-1/NRRESOURCEGROUP-32:${AVG_NUM_UE_NOM_NRG}>200
...    NRCELL-1/NRRESOURCEGROUP-32:${DNOM_SAMPLES_NRG}>=300
...    NRCELL-1/NRRESOURCEGROUP-32:${AVE_NUM_NGBR_NOM_NRG}>200
...    NRCELL-1/NRRESOURCEGROUP-32:${PEAK_NUM_UE_NRG}>=2
...    NRCELL-1/NRRESOURCEGROUP-32:${PEAK_NUM_UE_NRG}<=3
...    NRCELL-1/NRRESOURCEGROUP-32:${PEAK_NUM_NGBR_NRG}=2
...    NRCELL-1/NRRESOURCEGROUP-32:${RAC_REJ_DUE_DRB_MAX_QUOTA_NRG}=1
...    NRCELL-1/NRRESOURCEGROUP-32:${RAC_REJ_DUE_UE_MAX_QUOTA_NRG}=0
...    NRCELL-1/NRRESOURCEGROUP-32:${NUM_ADM_REQ_NGBR_NRG}=3
...    NRCELL-1/NRRESOURCEGROUP-32:${NUM_ADM_SUC_NGBR_NRG}=2
...    NRCELL-1/NRRESOURCEGROUP-32:${NUM_ADM_REQ_UE_NRG}=3
...    NRCELL-1/NRRESOURCEGROUP-32:${NUM_ADM_SUC_UE_NRG}=2

#check msg
@{UE_in_RRC_CONNECTED_state}
...    RrcState: NR CONNECTED
...    UE now in NG RM Registered state

@{expect_5qi8}
    ...    PDU SESSION RESOURCE MODIFY RESPONSE
    ...    Added QosFlow with
    ...    QoS Routing Table

@{expect_5qi7_5qi_9}
    ...    fiveQI 7
    ...    fiveQi 9
    ...    PDU SESSION RESOURCE MODIFY RESPONSE
    ...    Added QosFlow with
    ...    QoS Routing Table

@{FAULTS_EXCLUDED_CHECKING}    7300

*** Test Cases ***
CB008195-A-EC4_ET_02_01_Counters for SA non-GBR DRB admission static cell limits check
    [Documentation]
    ...    The test scenario is intended to verify Counters for SA non-GBR DRB admission static cell limit check.
    ...    Test Case Steps:
    ...       Step1. ICS UE1,UE3,UE5,at cell1 with default PDU session
    ...             Expected result:UE1, UE3, UE5 stays in RRC_CONNECTED state with default PDU session.
    ...       Step2. UE1 add nonGBR 5QI8
    ...             Expected result:related counter add,
    ...       Step3. ICS UE2 Register And PDU To Cell1 with 5QI5 And 5QI1 And 5QI8 Fail
    ...             Expected result:UE2 PDU fail due to RG1 MAXquota (6*50%)=3,
    ...                             UE1 (5QI5, 5QI8) + UE2 (5QI5+5QI8) =4 > 3
    ...       Step4. ICS UE4 Register And PDU To Cell1 with 5QI5 And 5QI1 And 5QI8
    ...             Expected result: UE4 PDU succssful due to RG2 MAXquota (6*60%)=3,
    ...                              UE3 (5QI5) + UE4 (5QI5+5QI8) =3
    ...       Step5. Make UE4 RLF and reestablish to cell1
    ...             Expected result: UE4 reestablish fail due to RG2 MAXquota
    ...                              nonGBR num=3, reestablish will add new nonGBR (cell1 RG2 related counter will add)
    ...       Step6,7 check counter and lock cell1&cell2 unlock cell1
    ...       Step8. SA UE6 (nwslice2) Register and ICS PDU to cell1 then add nonGBR 5QI7, 5QI9
    ...             Expected result: UE6 stays in RRC_CONNECTED state with default PDU session And with 5QI 5,7,9
    ...                              (RG1 NONGBR NUM=3)
    ...       Step9,10. UE7 Register and PDU To GNB with 5QI5 And 5QI1 And 5QI8 then add nonGBR7
    ...             Expected result: UE7 PDU succssful but add nonGBR7 fail
    ...                              (because RG3 have one dedicate pool 1,
    ...                                so RG2 allow nonGBR num = 6 - 3(RG1) - 1(RG3 dedicate)= 2,
    ...                               but counter ${RAC_REJ_DUE_DRB_MAX_QUOTA_NRG} will not add )
    [Tags]    c3
    Clear Counter Files
    SA 3UEs Register and ICS PDU GNB2
    SA UE ADD 1NonGBR    ue_id=1
    UE2 Register And PDU To Cell1 with 5QI5 And 5QI1 And 5QI8 Fail
    UE Register and PDU To GNB with 5QI5 And 5QI1 And 5QI8    ue_id=4
    Simulator UE RLF And Trigger RRC-Reestablish but release cause 8195 MAXQuota    ue_id=4    cell_id=1
    Check Counters    ${RD_Counters_Cell1_case2}
    Lock Cell1 and Cell2 then Unlock Cell1
    SA UE Register and ICS PDU    ue_id=6    nwslice=2    cell_id=1
    SA UE Add Two NonGBR79    ue_id=6
    UE Register and PDU To GNB with 5QI5 And 5QI1 And 5QI8    ue_id=7
    SA UE Add NonGBR7 Fail    ue_id=7
    Check Counters    ${RD_Counters_Cell1_case2_afterlock}
    Release all UEs


*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/3cells_ecpri
    Execute Egate Command    trace_sim protocol=xn uec=1 amf=1 enb=3 on

Modify Cfg
    Set PDU Session in WTS
    Set AMF config
    Set UE config
    Set GNB config
    Set QosFlow

Set AMF config
    Update Cfg    set_amf_region id=1 tac_list=100,200,300 plmn=311:489
    Update Cfg    amf_param id=1 full_nas_auth=on nia=null+zuc nea=null+zuc ims_voice_3gpp=on
    Update Cfg    set_amf id=1 daemon=10.0.2.1:22222 ng=10.0.1.1:38412 region=1 set_id=2 pointer=2 name=SimModeAMF1
    Update Cfg    amf_ng_setup_param id=1 relative_capacity=10 include_backup_amf_name=on ue_retention=on retention_time=indefinite
    Update Cfg    set_nwslice id=1 snssai=0x01:0xd143a5 amf=1 default=on qos_flows=9,8,7,6,5,4,3,2,1 qos_rules=1,2 ue=all
    Update Cfg    set_nwslice id=2 snssai=0x01:0xd143a6 amf=1 qos_flows=9,8,7,6,5,4,3,2,1 qos_rules=1,2 ue=all
    Update Cfg    set_nwslice id=3 snssai=0x01:0xd143a7 amf=1 qos_flows=9,8,7,6,5,4,3,2,1 qos_rules=1,2 ue=all
    Update Cfg    set_nwslice id=4 snssai=0x01:0xd143a9 amf=1 qos_flows=9,8,7,6,5,4,3,2,1 qos_rules=1,2 ue=all
    Update Cfg    set_nwslice id=2000 snssai=0x01:0xd143a8 amf=1 qos_flows=9,8,7,6,5,4,3,2,1 qos_rules=1,2 ue=all

Set PDU Session in WTS
    Update Cfg    qosrule_set id=1 proto=tcp qos_flow=1
    Update Cfg    qosrule_set id=2 proto=udp qos_flow=2

Set QosFlow
    Update Cfg    set_qosflow id=1 5qi=1 priority=1 pci=may_trigger_pre_emption pvi=pre_emptable
    Update Cfg    set_qosflow id=2 5qi=2 priority=2 pci=may_trigger_pre_emption pvi=pre_emptable
    Update Cfg    set_qosflow id=3 5qi=3 priority=3 pci=may_trigger_pre_emption pvi=pre_emptable
    Update Cfg    set_qosflow id=4 5qi=4 priority=4 pci=shall_not_trigger_pre_emption pvi=not_pre_emptable
    Update Cfg    set_qosflow id=5 5qi=5 default=on priority=5 pci=may_trigger_pre_emption pvi=pre_emptable
    Update Cfg    set_qosflow id=6 5qi=6 priority=6 pci=may_trigger_pre_emption pvi=pre_emptable
    Update Cfg    set_qosflow id=7 5qi=7 priority=7 pci=shall_not_trigger_pre_emption pvi=pre_emptable
    Update Cfg    set_qosflow id=8 5qi=8 priority=8 pci=may_trigger_pre_emption pvi=pre_emptable
    Update Cfg    set_qosflow id=9 5qi=9 priority=9 pci=may_trigger_pre_emption pvi=not_pre_emptable

Set UE config
    Update Cfg    ue_nr_capabilities id=1-19 voice_over_nr=on:on:off
    Update Cfg    ue_param id=1-19 nr_usage_setting=voice_centric ue_nr_capabilities=${ue_nr_capabilities}
    Update Cfg    ue_param id=2,4 ue_nr_capabilities=${OOO_UE_Capabilities}

SET GNB config
    Update Cfg    gnb_param id=3 xn_listening_socket=on send_xn_setup=true measEvent=A2 measEvent=A3 sib1_period=40
    ${set_gnb3}    catenate
    ...    set_gnb id=3 type=simulated plmn=311:489 ng=10.0.1.123 gnb_id=0x23:22 daemon=10.0.2.1:22222 x2_peers=none
    ...    xn=10.0.1.122 nssai=0x1:0xd143a5,0x1:0xd143a6,0x1:0xd143a7,0x1:0xd143a8 amf=1
    Update Cfg    ${set_gnb3}
    ${set_gnb3_cell1}    catenate
    ...    set_cell id=1 gnb=3 pci=127:0 tac=200 nrci=0x01 tdd_cell=on proxy=10.0.2.90:9999
    ...    nr_arfcn=633372:633372 gscn=7847 mandatory_for_activation=off
    Update Cfg    ${set_gnb3_cell1}
    Update Cfg    gnb_param id=5 xn_listening_socket=on sa_ho=ng_based measEvent=A2 measEvent=A3 sib1_period=40
    ${set_gnb5}    catenate
    ...    set_gnb id=5 type=simulated plmn=311:489 ng=10.0.1.125 gnb_id=0x24:22 daemon=10.0.2.1:22222 x2_peers=none
    ...    xn=10.0.1.124 nssai=0x1:0xd143a5,0x1:0xd143a6,0x1:0xd143a7,0x1:0xd143a8 amf=1
    Update Cfg    ${set_gnb5}
    ${set_gnb5_cell1}    catenate
    ...    set_cell id=1 gnb=5 pci=16:0 tac=200 nrci=0x01 tdd_cell=on proxy=10.0.2.92:9999
    ...    nr_arfcn=648000:648000 gscn=8000 mandatory_for_activation=off
    Update Cfg    ${set_gnb5_cell1}

GNB3 XN setup
    Execute Egate Command    gnb_param id=3 xn_listening_socket=1 send_xn_setup=true measEvent=A3
    Execute Egate Command    gnb_xn_link_up gnb=3 target=2    GNB-3: XnAP Link with GNB-2
    Execute Egate Command    gnb_param id=3 sa_ho=xn_based

Set UE History Info GNB
    [Arguments]    ${ue_id}=1    ${SimGNB_id}=3
    Execute Egate Command
    ...    ue_history_information_list_add_ngran id=${ue_id} cell_type=large nrcgi=311:489|0x01 gnb_id=2 time_ue_stayed_in_cell=97
    Execute Egate Command
    ...    ue_history_information_list_add_ngran id=${ue_id} cell_type=large nrcgi=311:489|0x01 gnb_id=${SimGNB_id} time_ue_stayed_in_cell=98
    Execute Egate Command    ue_history_information_list id=${ue_id} action=commit        committed
    Execute Egate Command    ue_enb_param id=${ue_id} ue_history_list=${ue_id}

SA 3UEs Register and ICS PDU GNB2
    [Arguments]    ${cell_id}=1
    SA UE Register and ICS PDU    ue_id=1    nwslice=1    cell_id=${cell_id}
    SA UE Register and ICS PDU    ue_id=3    nwslice=3    cell_id=${cell_id}
    SA UE Register and ICS PDU    ue_id=5    nwslice=2000    cell_id=${cell_id}

SA 4UEs Register and ICS PDU GNB2
    [Arguments]    ${cell_id}=1
    SA UE Register and ICS PDU    ue_id=1    nwslice=1    cell_id=${cell_id}
    SA UE Register and ICS PDU    ue_id=3    nwslice=3    cell_id=${cell_id}
    SA UE Register and ICS PDU    ue_id=5    nwslice=2000    cell_id=${cell_id}
    SA UE Register and ICS PDU    ue_id=6    nwslice=4    cell_id=${cell_id}

SA 2UEs Register and ICS PDU GNB2
    [Arguments]    ${cell_id}=1
    SA UE Register and ICS PDU    ue_id=2    nwslice=1    cell_id=${cell_id}
    SA UE Register and ICS PDU    ue_id=4    nwslice=3    cell_id=${cell_id}

SA 3UEs Register and ICS PDU SIM GNB
    [Arguments]    ${SimGNB_id}=3
    Set UE History Info GNB    ue_id=2    SimGNB_id=${SimGNB_id}
    Set UE History Info GNB    ue_id=4    SimGNB_id=${SimGNB_id}
    Set UE History Info GNB    ue_id=7    SimGNB_id=${SimGNB_id}
    SA UE Register and ICS PDU    ue_id=2    nwslice=1    enb_id=${SimGNB_id}
    SA UE Register and ICS PDU    ue_id=4    nwslice=3    enb_id=${SimGNB_id}
    SA UE Register and ICS PDU    ue_id=7    nwslice=4    enb_id=${SimGNB_id}

SA UE Register and ICS PDU
    [Arguments]    ${ue_id}=1    ${enb_id}=2    ${cell_id}=1    ${nwslice}=1    ${qos_flow}=5
    ...    ${plmn}=489    ${pdu}=1
    ${cmd}    catenate    amf_ue_ics_param id=1 core_network_assistance_info=on ue_identity_index_value=${ue_id} ue_specific_drx=64
    ...    periodic_registration_update_timer=1:10min plmn_id=311:${plmn} tac_id=200
    Execute Egate Command    ${cmd}
    Execute Egate Command    qosflow_modify default=on qos_flow=${qos_flow}
    Execute Egate Command    amf_param id=1 send_ics_registration=on
    UE Register To GNB    ue_id=${ue_id}    enb_id=${enb_id}    cell_id=${cell_id}
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    UE PDU Session Setup    ue_id=${ue_id}    nwslice=${nwslice}    pdu=${pdu}

SA UE Register and ICS PDU Fail
    [Arguments]    ${ue_id}=1    ${enb_id}=2    ${cell_id}=1    ${nwslice}=1    ${qos_flow}=5
    ...    ${plmn}=489    ${pdu}=1
    ${cmd}    catenate    amf_ue_ics_param id=1 core_network_assistance_info=on ue_identity_index_value=${ue_id} ue_specific_drx=64
    ...    periodic_registration_update_timer=1:10min plmn_id=311:${plmn} tac_id=200
    Execute Egate Command    ${cmd}
    Execute Egate Command    qosflow_modify default=on qos_flow=${qos_flow}
    Execute Egate Command    amf_param id=1 send_ics_registration=on
    UE Register To GNB    ue_id=${ue_id}    enb_id=${enb_id}    cell_id=${cell_id}
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    UE PDU Session Setup Fail    ue_id=${ue_id}    nwslice=${nwslice}    pdu=${pdu}
    Release Ues    ue_type=sa    ue_id=${ue_id}

UE Register To GNB
    [Arguments]    ${ue_id}=1    ${enb_id}=2    ${cell_id}=1
    Execute Egate Command    smf_param id=1 reset
    Execute Egate Command    ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=${UE_in_RRC_CONNECTED_state}

UE PDU Session Setup
    [Arguments]    ${ue_id}=1    ${nwslice}=1    ${pdu}=1
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu} trf_type=internal
    ${ret1}=    Execute Egate Command    ue_pdu_session_setup pdu=${pdu} ue=${ue_id} nwslice=${nwslice} gw=${ue_id}
        ...    QoS Routing Table
    Should Contain    ${ret1}    Created FiveQi:Qfi mapping fiveQi 5 qfi 1

UE PDU Session Setup Fail
    [Arguments]    ${ue_id}=1    ${nwslice}=1    ${pdu}=1
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup pdu=${pdu} ue=${ue_id} nwslice=${nwslice} gw=${ue_id}
    ...    RAN radio resources not available

SA UE ADD 1NonGBR
    [Arguments]    ${ue_id}=1    ${qosflows}=8
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=${qosflows} by=amf
    ...    pass_regexp=@{expect_5qi8}    timeout=30s

SA UE Add Two NonGBR79
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=7,9 by=amf
    ...    pass_regexp=@{expect_5qi7_5qi_9}    timeout=30s
    Execute Egate Command    ue_disp

SA UE Add NonGBR7 Fail
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=7 by=amf
    ...    pass_regexp=radio-resources-not-available    timeout=30s

PDU set 2 QOSflow
    [Arguments]    ${ue_id}=1
    Execute Egate Command    amf_param id=1 send_ics_registration=off
    Execute Egate Command    smf_param id=1 additional_qosflows_to_activate=1
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal

PDU set 3 QOSflow
    [Arguments]    ${ue_id}=1
    Execute Egate Command    amf_param id=1 send_ics_registration=off
    Execute Egate Command    smf_param id=1 additional_qosflows_to_activate=1,8
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal

Simulator UE RLF And Trigger RRC-Reestablish
    [Arguments]    ${ue_id}=1    ${cell_id}=2
    Execute Egate Command    rlf_testmode_nr profile_id=${ue_id} num_stop_csi_report=200 num_stop_dlharq_tx=100
    Execute Egate Command    ue_testmode_set id=${ue_id} testmode=rlf action=activate profile_index=1
    Execute Egate Command    ue_rrc_reestablish id=${ue_id} gnb=2 cell=${cell_id} cause=otherFailure
    ...    Reestablishment sucessfully completed    timeout=20s    sleep_time=5
    Execute Egate Command    ue_disp id=${ue_id}    ACTIVE    timeout=20s

Simulator UE RLF And Trigger RRC-Reestablish fail
    [Arguments]    ${ue_id}=1    ${cell_id}=2
    Execute Egate Command    rlf_testmode_nr profile_id=${ue_id} num_stop_csi_report=200 num_stop_dlharq_tx=100
    Execute Egate Command    ue_testmode_set id=${ue_id} testmode=rlf action=activate profile_index=1
    Execute Egate Command    ue_rrc_reestablish id=${ue_id} gnb=2 cell=${cell_id} cause=otherFailure
    ...    radio-resources-not-available    timeout=20s    sleep_time=5

Simulator UE RLF And Trigger RRC-Reestablish but release cause 8195 MAXQuota
    [Arguments]    ${ue_id}=1    ${cell_id}=2
    Execute Egate Command    rlf_testmode_nr profile_id=${ue_id} num_stop_csi_report=200 num_stop_dlharq_tx=100
    Execute Egate Command    ue_testmode_set id=${ue_id} testmode=rlf action=activate profile_index=1
    Execute Egate Command    ue_rrc_reestablish id=${ue_id} gnb=2 cell=${cell_id} cause=otherFailure
    ...    Reestablishment sucessfully completed    timeout=20s    sleep_time=5
    Execute Egate Command    ue_disp id=${ue_id}    IDLE    timeout=20s

XN Handover From GNB3 to GNB2 Cell1
    [Arguments]    ${ue_id}=1
    ${cmd}    catenate    ue_measurement_send_nr id=${ue_id} meas_id=1 event=A3 srsrp_nr=50 srsrq_nr=10 phycell_id=50
    ...    nrsrp_nr=90 nrsrq_nr=34
    Execute Egate Command    ${cmd}        pass_regexp=Inter-eNB handover from ENB-3.1 to EXT_ENB-2.1 performed

XN Handover From GNB3 to GNB2 Cell1 Fail
    [Arguments]    ${ue_id}=1
    ${cmd}    catenate    ue_measurement_send_nr id=${ue_id} meas_id=1 event=A3 srsrp_nr=50 srsrq_nr=10 phycell_id=50
    ...    nrsrp_nr=90 nrsrq_nr=34
    Execute Egate Command    ${cmd}    pass_regexp=no-radio-resources-available-in-target-cell

Lock Cell1 and Cell2 then Unlock Cell1
    Delta Commission Parameters    ${params_lock_cells}
    Cell Should Be Locked    1
    Cell Should Be Locked    2
    Delta Commission Parameters    ${params_unlock_cells}
    Cells Should Be Onair    1

UE7 Register and PDU To GNB with 5QI5 And 5QI1
    UE Register To GNB    ue_id=7    cell_id=2
    PDU set 2 QOSflow    ue_id=7
    UE PDU Session Setup    ue_id=7    nwslice=2    pdu=1

UE2 Register And PDU To Cell1 with 5QI5 And 5QI1 And 5QI8 Fail
    UE Register To GNB    ue_id=2
    PDU set 3 QOSflow    ue_id=2
    UE PDU Session Setup Fail    ue_id=2    nwslice=2    pdu=1

UE Register and PDU To GNB with 5QI5 And 5QI1 And 5QI8
    [Arguments]    ${ue_id}=1
    UE Register To GNB    ue_id=${ue_id}
    PDU set 3 QOSflow    ue_id=${ue_id}
    UE PDU Session Setup    ue_id=${ue_id}    nwslice=3    pdu=1

Release all UEs
    Delta Commission Parameters    ${params_unlock_cell2}
    Cells Should Be Onair    2
    Execute Egate Command    ue_deregister id=1 ue_deregister_type=switch_off    detached
    Execute Egate Command    ue_deregister id=2 ue_deregister_type=switch_off    detached
    Execute Egate Command    ue_deregister id=3 ue_deregister_type=switch_off    detached
    Execute Egate Command    ue_deregister id=4 ue_deregister_type=switch_off    detached
    Execute Egate Command    ue_deregister id=5 ue_deregister_type=switch_off    detached
    Execute Egate Command    ue_deregister id=6 ue_deregister_type=switch_off    detached
    Execute Egate Command    ue_deregister id=7 ue_deregister_type=switch_off    detached
