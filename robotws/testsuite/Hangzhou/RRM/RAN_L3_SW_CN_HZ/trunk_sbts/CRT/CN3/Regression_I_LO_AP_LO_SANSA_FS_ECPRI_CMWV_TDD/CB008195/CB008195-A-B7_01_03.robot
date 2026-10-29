*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_VRF    SBTS00    RAN_5G    RAN_5G_TDD    team-VRF3_8    owner-kexin.zhou
...    CLOUD_5G_I_LO_AP_LO    release-SBTS24R3
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
...    NRCELLGRP-0:nrCellList=2
...    NRCELLGRP-1:nrCellList=1
...    NRBTS/NRCELLGRP-1:maxNumOfRrcCGRPSA=6
...    NRBTS/NRCELLGRP-0:maxNumOfRrcCGRPSA=15
...    NRBTS/NRDU-1:maxNumOfRrcConUEsPerDU=2448

@{onlySA}
...    NRCELL:cellDepType=SA
...    delete:NRBTS/NRCELL:configuredEpsTac

@{limit_maxNumOfUsersPerNRCell}
...    NRCELL:maxNumOfUsersPerNRCell=275
...    NRCELL:maxNumOfUsersPerCell=30
...    NRCELL:maxNumOfCaUsersNRCell=30
...    NRCELL:maxNumOfNrDcSnUsers=30
...    NRCELL:maxNumOfSCellAlloc=200

@{limit_Bearer}
...    NRCELL-1:maxNumOfNonGBRBearersSA=550
...    NRCELL-2:maxNumOfNonGBRBearersSA=6
...    NRCELL:maxNumOfGBRBearersSA=10
...    NRCELL:addNumOfGBRBearers=0
...    NRCELLGRP-0:maxNumOfNonGBRBearersCGRPSA=550
...    NRBTS/NRCELLGRP-0:addNumOfNonGBRBearersCGRPSAHo=0

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

${NG_HO_RES_ALC_ATT_TRG}    M55125C07503
${NG_HO_RES_ALC_SUCC_TRG}    M55125C07504
${NG_HO_EXEC_NOTIFY_TRG}    M55125C07520

@{XN_HO_Counters}
...    NRCELL-1:${XN_HO_REQ_RECEIVED}=2
...    NRCELL-1:${XN_HO_REQ_ACK_SENT}=2

@{NG_HO_Counters}
...    NRCELL-2:${NG_HO_EXEC_NOTIFY_TRG}=2
...    NRCELL-2:${NG_HO_RES_ALC_ATT_TRG}=2
...    NRCELL-2:${NG_HO_RES_ALC_SUCC_TRG}=2

#check msg
@{UE_in_RRC_CONNECTED_state}
...    RrcState: NR CONNECTED
...    UE now in NG RM Registered state

*** Test Cases ***
CB008195-A-B7_ET_01_01_SA UE admission static cell limits check for during incoming inter-gNB Xn handover
    [Documentation]
    ...    The test scenario is intended to verify SA UE admission static cell limits check during incoming
    ...    inter-gNB Xn handover.
    ...    Test Case Steps:
    ...       Step1. ICS UE1,UE3,UE5,UE6 at cell1 with default PDU session
    ...             Expected result:all UE stays in RRC_CONNECTED state with default PDU session.
    ...       Step2. ICS UE2,UE4 at GNB3 cell1 with default PDU session
    ...             Expected result:UE2, UE4 stays in RRC_CONNECTED state with default PDU session.
    ...       Step3. Trigger UE2 Inter-frequency HO to cell1 of Gnb1
    ...             Expected result:UE2 Inter-frequency HO to cell1 of Gnb1,
    ...                             within RG maxNumOfRrcCGRPSA level dedicated pool
    ...                              (due to no counter mapping to it only message or log can be checked)
    ...       Step4. Trigger UE4 Inter-frequency HO to cell1 of Gnb1
    ...             Expected result: UE4 Inter-frequency HO to cell1 of Gnb1,
    ...                             within RG maxNumOfRrcCGRPSA level common pool
    ...                              (due to no counter mapping to it only message or log can be checked)
    ...       RG configurton: maxNumOfRrcCGRPSA=6
    ...       RG1 MAX=50 MIN=20 (UE POOL:max:3 min=1)
    ...       RG2 MAX=60 MIN=10 (UE POOL:max:3 min=0)
    ...       RG3 MAX=40 MIN=10 (UE POOL:max:2 min=1)
    [Tags]    owner-kexin.zhou
    GNB3 XN setup
    SA 4UEs Register and ICS PDU GNB2
    SA 2UEs Register and ICS PDU SIM GNB    SimGNB_id=3
    XN Handover From GNB3 to GNB2 Cell1    ue_id=2
    XN Handover From GNB3 to GNB2 Cell1    ue_id=4
    Release UEs    ue_type=all
    Check Counters    ${XN_HO_Counters}

CB008195-A-B7_ET_03_01_SA UE admission static cell limits check for during incoming inter-gNB NG handover
    [Documentation]
    ...    The test scenario is intended to verify SA UE admission static cell limits check during incoming
    ...    inter-gNB Xn handover.
    ...    Test Case Steps:
    ...       Step1. ICS UE1,UE3,UE5,UE6 at cell1 with default PDU session
    ...             Expected result:all UE stays in RRC_CONNECTED state with default PDU session.
    ...       Step2. ICS UE2,UE4 at GNB3 cell1 with default PDU session
    ...             Expected result:UE2, UE4 stays in RRC_CONNECTED state with default PDU session.
    ...       Step3. Trigger UE2 Inter-frequency HO to cell1 of Gnb1
    ...             Expected result:UE2 Inter-frequency HO to cell1 of Gnb1,
    ...                             within RG maxNumOfNonGBRBearersSA level dedicated pool
    ...                              (due to no counter mapping to it only message or log can be checked)
    ...       Step4. Trigger UE4 Inter-frequency HO to cell1 of Gnb1
    ...             Expected result: UE4 Inter-frequency HO to cell1 of Gnb1,
    ...                             within RG maxNumOfNonGBRBearersSA level common pool
    ...                              (due to no counter mapping to it only message or log can be checked)
    ...       RG configurton: maxNumOfNonGBRBearersSA=6
    ...       RG1 MAX=50 MIN=20 (UE POOL:max:3 min=1)
    ...       RG2 MAX=60 MIN=10 (UE POOL:max:3 min=0)
    ...       RG3 MAX=40 MIN=10 (UE POOL:max:2 min=1)
    [Tags]    owner-kexin.zhou
    GNB5 XN setup
    SA 4UEs Register and ICS PDU GNB2    cell_id=2
    SA 2UEs Register and ICS PDU SIM GNB    SimGNB_id=5
    NG Handover From GNB5 to GNB2 Cell2    ue_id=2
    NG Handover From GNB5 to GNB2 Cell2    ue_id=4
    Release UEs    ue_type=all
    Check Counters    ${NG_HO_Counters}

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

GNB5 XN setup
    Execute Egate Command    gnb_param id=3 xn_listening_socket=1 send_xn_setup=true measEvent=A3
    Execute Egate Command    gnb_xn_link_up gnb=5 target=2    GNB-5: XnAP Link with GNB-2
    Execute Egate Command    gnb_param id=5 sa_ho=ng_based

Set UE History Info GNB
    [Arguments]    ${ue_id}=1    ${SimGNB_id}=3
    Execute Egate Command
    ...    ue_history_information_list_add_ngran id=${ue_id} cell_type=large nrcgi=311:489|0x01 gnb_id=2 time_ue_stayed_in_cell=97
    Execute Egate Command
    ...    ue_history_information_list_add_ngran id=${ue_id} cell_type=large nrcgi=311:489|0x01 gnb_id=${SimGNB_id} time_ue_stayed_in_cell=98
    Execute Egate Command    ue_history_information_list id=${ue_id} action=commit        committed
    Execute Egate Command    ue_enb_param id=${ue_id} ue_history_list=${ue_id}

SA 4UEs Register and ICS PDU GNB2
    [Arguments]    ${cell_id}=1
    SA UE Register and ICS PDU    ue_id=1    nwslice=1    cell_id=${cell_id}
    SA UE Register and ICS PDU    ue_id=3    nwslice=3    cell_id=${cell_id}
    SA UE Register and ICS PDU    ue_id=5    nwslice=2000    cell_id=${cell_id}
    SA UE Register and ICS PDU    ue_id=6    nwslice=4    cell_id=${cell_id}

SA 2UEs Register and ICS PDU SIM GNB
    [Arguments]    ${SimGNB_id}=3
    Set UE History Info GNB    ue_id=2    SimGNB_id=${SimGNB_id}
    Set UE History Info GNB    ue_id=4    SimGNB_id=${SimGNB_id}
    SA UE Register and ICS PDU    ue_id=2    nwslice=1    enb_id=${SimGNB_id}
    SA UE Register and ICS PDU    ue_id=4    nwslice=3    enb_id=${SimGNB_id}

SA UE Register and ICS PDU
    [Arguments]    ${ue_id}=1    ${enb_id}=2    ${cell_id}=1    ${nwslice}=1    ${qos_flow}=5
    ...    ${plmn}=489    ${pdu}=1
    ${cmd}    catenate    amf_ue_ics_param id=1 core_network_assistance_info=on ue_identity_index_value=${ue_id} ue_specific_drx=64
    ...    periodic_registration_update_timer=1:10min plmn_id=311:${plmn} tac_id=200
    Execute Egate Command    ${cmd}
    Execute Egate Command    qosflow_modify default=on qos_flow=${qos_flow}
    Execute Egate Command    ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}
    Execute Egate Command    amf_param id=1 send_ics_registration=on
    UE Register To GNB    ue_id=${ue_id}
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    UE PDU Session Setup    ue_id=${ue_id}    nwslice=${nwslice}    pdu=${pdu}

UE Register To GNB
    [Arguments]    ${ue_id}=1    ${nwslice}=1
    Execute Egate Command    smf_param id=1 reset
    Execute Egate Command    ue_register id=${ue_id} nwslice=${nwslice}    pass_regexp=${UE_in_RRC_CONNECTED_state}

UE PDU Session Setup
    [Arguments]    ${ue_id}=1    ${nwslice}=1    ${pdu}=1
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu} trf_type=internal
    ${ret1}=    Execute Egate Command    ue_pdu_session_setup pdu=${pdu} ue=${ue_id} nwslice=${nwslice} gw=${ue_id}    QoS Routing Table
    Should Contain    ${ret1}    Created FiveQi:Qfi mapping fiveQi 5 qfi 1

XN Handover From GNB3 to GNB2 Cell1
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=1 event=A3 srsrp_nr=50 srsrq_nr=10 phycell_id=50 nrsrp_nr=90 nrsrq_nr=34
    ...    pass_regexp=Inter-eNB handover from ENB-3.1 to EXT_ENB-2.1 performed


NG Handover From GNB5 to GNB2 Cell2
    [Arguments]    ${ue_id}=1    ${source_carrierfreq}=636576
    BuiltIn.Log    UE${ue_id} Trigger Intra-Frequency Inter-gnb HO To Real gNB2 Cell1 By A3...    console=${True}
    ${mea_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${source_carrierfreq}    event_type=A3
    ${cmd_HO}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${mea_id} event=A3 srsrp_nr=25 phycell_id=51 nrsrp_nr=85
    Execute Egate Command    ${cmd_HO}    pass_regexp=Inter-eNB handover from ENB-5.1 to EXT_ENB-2.2 performed

