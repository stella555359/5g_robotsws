*** Settings ***
Documentation
...    author:  baijie.zhu@nokia-sbell.com
...    contact: baijie.zhu@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_VRF    SBTS00    RAN_5G    RAN_5G_TDD    team-VRF3_7    owner-zhubaijie
...    CLOUD_5G_I_LO_AP_LO    release-SBTS25R1
Resource    ../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_VENDOR}
...    maxNumOfUserL2Pool=18    maxNumPucchF1SRPerSlotL1Pool=30    maxNumPucchF3PCSIPerSlotL1Pool=30

@{PARAMS_IN_SCF}
...    @{TAC}
...    @{CB008225}
...    @{other_resource_reserve}
...    @{limit_maxNumOfRrcSA}
...    @{limit_maxNumOfUsersPerNRCell}
...    @{cellDepType}
...    @{gnbCutyp_NSA_only}
...    @{nsaDrbParam}
...    @{CB008195}
...    @{NRRESOURCEGROUP_PROFILE}
...    @{RANsharing}
...    @{PLMN}
...    @{BBPooling}

@{BBPooling}
...    NRBTS:actConnRrcPooling=true    NRBTS:actScheUePooling=true
...    @{CB008847}

@{CB008847}
...    NRBTS:actBbPoolTddFr1=true
...    NRBTS:actBbPoolExtensionTddFr1=true
...    NRBTS:actBbPoolTddFr1AlgEnh=true
...    NRBTS:actBbPoolTddFr1Enh=true

@{PLMN}
...    MRBTS-1/NRBTS-1/NRPLMN-1:mcc=311
...    MRBTS-1/NRBTS-1/NRPLMN-1:mnc=489
...    MRBTS-1/NRBTS-1/NRPLMN-1:mncLength=3
...    MRBTS-1/NRBTS-1/NRPLMN-2:mcc=262
...    MRBTS-1/NRBTS-1/NRPLMN-2:mnc=3
...    MRBTS-1/NRBTS-1/NRPLMN-2:mncLength=3

@{RANsharing}
...    NRBTS:actRanSharing=true
...    NRBTS:actRanSharingEnh=disabled
...    NRCELL/NRPLMNSET_NSA-1:configuredEpsTac=222
...    NRCELL/NRPLMNSET_NSA-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1,MRBTS-1/NRBTS-1/NRPLMN-2

@{gnbCutyp_NSA_only}
...    NRBTS:gNbCuType=NSA
...    NRBTS:actSACallProcessingDU=false
...    delete:MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRLIM-1

@{nsaDrbParam}
...    NRBTS:actMultiDrbNSA=true
...    NRBTS-1/NRDRB-10:nsaDrbParam:actPrioritizeX2AfterInactivity=true
...    NRBTS-1/NRDRB-10:nsaDrbParam:actX2DuplicateTxNSA3x=false
...    NRBTS-1/NRDRB-10:nsaDrbParam:dlDataSplitBufferBuildUpThreshold=5
...    NRBTS-1/NRDRB-10:nsaDrbParam:dlDataSplitBufferBuildUpThresholdPrioritizeX2=5
...    NRBTS-1/NRDRB-10:nsaDrbParam:dlDataSplitGainThreshold=5
...    NRBTS-1/NRDRB-10:nsaDrbParam:dlDataSplitMode=dlOverF1UX2U
...    NRBTS-1/NRDRB-10:nsaDrbParam:inactivityThresholdForPrioritizeX2=300
...    NRBTS-1/NRDRB-10:nsaDrbParam:inactivityThresholdForRestartPrioritizeX2=100
...    NRBTS-1/NRDRB-10:nsaDrbParam:inactPeriodX2PdcpDuplication=300
...    NRBTS-1/NRDRB-10:nsaDrbParam:initialDLTrafficRouting=initDLoverX2U
...    NRBTS-1/NRDRB-10:nsaDrbParam:nsa3xBearerAllowed=true
...    NRBTS-1/NRDRB-10:nsaDrbParam:prioritizeX2Period=500
...    NRBTS-1/NRDRB-10:nsaDrbParam:ulDataPath=ulOverNr
...    NRBTS-1/NRDRB-10:nsaDrbParam:ulDataSplitThreshold=infinity
...    NRBTS-1/NRDRB-11:nsaDrbParam:actPrioritizeX2AfterInactivity=true
...    NRBTS-1/NRDRB-11:nsaDrbParam:actX2DuplicateTxNSA3x=false
...    NRBTS-1/NRDRB-11:nsaDrbParam:dlDataSplitBufferBuildUpThreshold=5
...    NRBTS-1/NRDRB-11:nsaDrbParam:dlDataSplitBufferBuildUpThresholdPrioritizeX2=5
...    NRBTS-1/NRDRB-11:nsaDrbParam:dlDataSplitGainThreshold=5
...    NRBTS-1/NRDRB-11:nsaDrbParam:dlDataSplitMode=dlOverF1UX2U
...    NRBTS-1/NRDRB-11:nsaDrbParam:inactivityThresholdForPrioritizeX2=300
...    NRBTS-1/NRDRB-11:nsaDrbParam:inactivityThresholdForRestartPrioritizeX2=100
...    NRBTS-1/NRDRB-11:nsaDrbParam:inactPeriodX2PdcpDuplication=300
...    NRBTS-1/NRDRB-11:nsaDrbParam:initialDLTrafficRouting=initDLoverX2U
...    NRBTS-1/NRDRB-11:nsaDrbParam:nsa3xBearerAllowed=true
...    NRBTS-1/NRDRB-11:nsaDrbParam:prioritizeX2Period=500
...    NRBTS-1/NRDRB-11:nsaDrbParam:ulDataPath=ulOverNr
...    NRBTS-1/NRDRB-11:nsaDrbParam:ulDataSplitThreshold=infinity
...    NRBTS-1/NRDRB-12:nsaDrbParam:actPrioritizeX2AfterInactivity=true
...    NRBTS-1/NRDRB-12:nsaDrbParam:actX2DuplicateTxNSA3x=false
...    NRBTS-1/NRDRB-12:nsaDrbParam:dlDataSplitBufferBuildUpThreshold=5
...    NRBTS-1/NRDRB-12:nsaDrbParam:dlDataSplitBufferBuildUpThresholdPrioritizeX2=5
...    NRBTS-1/NRDRB-12:nsaDrbParam:dlDataSplitGainThreshold=5
...    NRBTS-1/NRDRB-12:nsaDrbParam:dlDataSplitMode=dlOverF1UX2U
...    NRBTS-1/NRDRB-12:nsaDrbParam:inactivityThresholdForPrioritizeX2=300
...    NRBTS-1/NRDRB-12:nsaDrbParam:inactivityThresholdForRestartPrioritizeX2=100
...    NRBTS-1/NRDRB-12:nsaDrbParam:inactPeriodX2PdcpDuplication=300
...    NRBTS-1/NRDRB-12:nsaDrbParam:initialDLTrafficRouting=initDLoverX2U
...    NRBTS-1/NRDRB-12:nsaDrbParam:nsa3xBearerAllowed=true
...    NRBTS-1/NRDRB-12:nsaDrbParam:prioritizeX2Period=500
...    NRBTS-1/NRDRB-12:nsaDrbParam:ulDataPath=ulOverNr
...    NRBTS-1/NRDRB-12:nsaDrbParam:ulDataSplitThreshold=infinity
...    NRBTS-1/NRDRB-13:nsaDrbParam:actPrioritizeX2AfterInactivity=true
...    NRBTS-1/NRDRB-13:nsaDrbParam:actX2DuplicateTxNSA3x=false
...    NRBTS-1/NRDRB-13:nsaDrbParam:dlDataSplitBufferBuildUpThreshold=5
...    NRBTS-1/NRDRB-13:nsaDrbParam:dlDataSplitBufferBuildUpThresholdPrioritizeX2=5
...    NRBTS-1/NRDRB-13:nsaDrbParam:dlDataSplitGainThreshold=5
...    NRBTS-1/NRDRB-13:nsaDrbParam:dlDataSplitMode=dlOverF1UX2U
...    NRBTS-1/NRDRB-13:nsaDrbParam:inactivityThresholdForPrioritizeX2=300
...    NRBTS-1/NRDRB-13:nsaDrbParam:inactivityThresholdForRestartPrioritizeX2=100
...    NRBTS-1/NRDRB-13:nsaDrbParam:inactPeriodX2PdcpDuplication=300
...    NRBTS-1/NRDRB-13:nsaDrbParam:initialDLTrafficRouting=initDLoverX2U
...    NRBTS-1/NRDRB-13:nsaDrbParam:nsa3xBearerAllowed=true
...    NRBTS-1/NRDRB-13:nsaDrbParam:prioritizeX2Period=500
...    NRBTS-1/NRDRB-13:nsaDrbParam:ulDataPath=ulOverNr
...    NRBTS-1/NRDRB-13:nsaDrbParam:ulDataSplitThreshold=infinity
...    NRBTS-1/NRDRB-14:nsaDrbParam:actPrioritizeX2AfterInactivity=true
...    NRBTS-1/NRDRB-14:nsaDrbParam:actX2DuplicateTxNSA3x=false
...    NRBTS-1/NRDRB-14:nsaDrbParam:dlDataSplitBufferBuildUpThreshold=5
...    NRBTS-1/NRDRB-14:nsaDrbParam:dlDataSplitBufferBuildUpThresholdPrioritizeX2=5
...    NRBTS-1/NRDRB-14:nsaDrbParam:dlDataSplitGainThreshold=5
...    NRBTS-1/NRDRB-14:nsaDrbParam:dlDataSplitMode=dlOverF1UX2U
...    NRBTS-1/NRDRB-14:nsaDrbParam:inactivityThresholdForPrioritizeX2=300
...    NRBTS-1/NRDRB-14:nsaDrbParam:inactivityThresholdForRestartPrioritizeX2=100
...    NRBTS-1/NRDRB-14:nsaDrbParam:inactPeriodX2PdcpDuplication=300
...    NRBTS-1/NRDRB-14:nsaDrbParam:initialDLTrafficRouting=initDLoverX2U
...    NRBTS-1/NRDRB-14:nsaDrbParam:nsa3xBearerAllowed=true
...    NRBTS-1/NRDRB-14:nsaDrbParam:prioritizeX2Period=500
...    NRBTS-1/NRDRB-14:nsaDrbParam:ulDataPath=ulOverNr
...    NRBTS-1/NRDRB-14:nsaDrbParam:ulDataSplitThreshold=infinity

@{cellDepType}
...    NRCELL:cellDepType=NSA
...    delete:NRCELL:ranAC
...    delete:NRCELL:trackingAreaDN
...    delete:NRCELL:configuredEpsTac
...    NRCELL:msg1FrequencyStart=18
...    NRCELL:a2MeasRedirectSsbRsrp:a2ThresholdRedirectSsbRsrp=19
...    NRCELL:a2MeasReleaseSsbRsrp:a2ThresholdReleaseSsbRsrp=19


@{CB008195}
...    MRBTS/NRBTS:rgMinQuotaReservationLevel=cell_and_multicell_level
...    NRBTS:actSliceAwareAdmissionCtrl=true
...    NRBTS:actSpidBasedSlicingNSA=false
...    NRCELL:sliceAwareAdmissionCtrlEnabled=true
...    NRBTS:actSliceAwareScheduler=false
...    NRCELL:maxNumOfUsersPerNRCell=10
...    NRCELL:maxNumOfUsersPerCell=10
...    NRBTS/NRPMRNL-1:miNrCellUtilPerPLMN=disabled
...    NRBTS:actDrbPreemption=false
...    NRBTS:actUserPreemption=false
...    NRBTS/NRCELL:actPriorityAccess=false
...    NRBTS/NRCELL:actEmergencyCall=false
...    NRCELL-1:nrResourceGroupProfileRacDN=NRRESOURCEGROUP_PROFILE-0
...    NRCELL-3:nrResourceGroupProfileRacDN=NRRESOURCEGROUP_PROFILE-1
...    NRBTS/NRPMRNL-1:miNrCellUtilPerNrg=5min
...    NRBTS-1/NRCELL-1:sliceAwareAdmissionCtrlEnabled=true
...    NRBTS-1/NRCELL-2:sliceAwareAdmissionCtrlEnabled=false
...    NRBTS-1/NRCELL-3:sliceAwareAdmissionCtrlEnabled=true

@{NRRESOURCEGROUP_PROFILE}
#NRRESOURCEGROUP_PROFILE-0 - PLMN1 and PLMN2
...    NRBTS/NRRESOURCEGROUP_PROFILE-0:bypassRgLimits=4
...    NRBTS/NRRESOURCEGROUP_PROFILE-0:defaultRgNsaList:nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1|nrResourceGroupId=1
...    NRBTS/NRRESOURCEGROUP_PROFILE-0:defaultRgNsaList:nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-2|nrResourceGroupId=2
...    NRBTS/NRRESOURCEGROUP_PROFILE-0/NRRESOURCEGROUP-1:nrResourceList:resourceDN=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS/NRRESOURCEGROUP_PROFILE-0/NRRESOURCEGROUP-1:racParams:maxQuota=80
...    NRBTS/NRRESOURCEGROUP_PROFILE-0/NRRESOURCEGROUP-1:racParams:minQuota=60
...    NRBTS/NRRESOURCEGROUP_PROFILE-0/NRRESOURCEGROUP-2:nrResourceList:resourceDN=MRBTS-1/NRBTS-1/NRPLMN-2
...    NRBTS/NRRESOURCEGROUP_PROFILE-0/NRRESOURCEGROUP-2:racParams:maxQuota=40
...    NRBTS/NRRESOURCEGROUP_PROFILE-0/NRRESOURCEGROUP-2:racParams:minQuota=10

#NRRESOURCEGROUP_PROFILE-1 - PLMN1 and PLMN2
...    NRBTS/NRRESOURCEGROUP_PROFILE-1:bypassRgLimits=4
...    NRBTS/NRRESOURCEGROUP_PROFILE-1:defaultRgNsaList:nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1|nrResourceGroupId=1
...    NRBTS/NRRESOURCEGROUP_PROFILE-1:defaultRgNsaList:nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-2|nrResourceGroupId=2
...    NRBTS/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-1:nrResourceList:resourceDN=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-1:racParams:maxQuota=20
...    NRBTS/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-1:racParams:minQuota=0
...    NRBTS/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-2:nrResourceList:resourceDN=MRBTS-1/NRBTS-1/NRPLMN-2
...    NRBTS/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-2:racParams:maxQuota=100
...    NRBTS/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-2:racParams:minQuota=80

##NRRESOURCEGROUP_PROFILE-2 - PLMN1
...    NRBTS/NRRESOURCEGROUP_PROFILE-2:bypassRgLimits=4
...    NRBTS/NRRESOURCEGROUP_PROFILE-2:defaultRgNsaList:nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS/NRRESOURCEGROUP_PROFILE-2:defaultRgNsaList:nrResourceGroupId=1
...    NRBTS/NRRESOURCEGROUP_PROFILE-2:defaultRgSaList:nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS/NRRESOURCEGROUP_PROFILE-2:defaultRgSaList:nrResourceGroupId=1
...    NRBTS/NRRESOURCEGROUP_PROFILE-2/NRRESOURCEGROUP-1:nrResourceList:resourceDN=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS/NRRESOURCEGROUP_PROFILE-2/NRRESOURCEGROUP-1:racParams:maxQuota=80
...    NRBTS/NRRESOURCEGROUP_PROFILE-2/NRRESOURCEGROUP-1:racParams:minQuota=20

#NRRESOURCEGROUP_PROFILE-3 - PLMN1
...    NRBTS/NRRESOURCEGROUP_PROFILE-3:bypassRgLimits=4
...    NRBTS/NRRESOURCEGROUP_PROFILE-3:defaultRgNsaList:nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS/NRRESOURCEGROUP_PROFILE-3:defaultRgNsaList:nrResourceGroupId=1
...    NRBTS/NRRESOURCEGROUP_PROFILE-3:defaultRgSaList:nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS/NRRESOURCEGROUP_PROFILE-3:defaultRgSaList:nrResourceGroupId=1
...    NRBTS/NRRESOURCEGROUP_PROFILE-3/NRRESOURCEGROUP-1:nrResourceList:resourceDN=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS/NRRESOURCEGROUP_PROFILE-3/NRRESOURCEGROUP-1:racParams:maxQuota=80
...    NRBTS/NRRESOURCEGROUP_PROFILE-3/NRRESOURCEGROUP-1:racParams:minQuota=30

@{TAC}
...    NRBTS/TRACKINGAREA-200:fiveGsTac=200
...    delete:TRACKINGAREA-200:snssaiList
...    delete:NRBTS/SNSSAI-1

@{CB008225}
...    NRBTS:actRrcInactState=none
...    NRBTS:outOfConnectedPreference=idle
...    NRBTS:act3gppBL23R1=true
...    NRBTS:drbRrcInactInactivityTimerSA=20
...    NRBTS:maxUeRrcInactTime=20         # ue will release after UE in inactive timeout
...    NRBTS:drbInactivityTimerSA=60
...    NRBTS:rrcInactIMMSteeringEnabled=false
...    NRBTS:rrcInactLocationReportEnabled=false
...    NRBTS:rrcInactPreferredStateEnabled=true
...    NRBTS:actRrcReleasePreference=true
...    NRBTS:timerReleasePreferenceProhibit=s5
...    NRBTS:tRanPagingGuard=4
...    NRBTS:t380=10min
...    NRBTS:actPaging=true
...    NRBTS:ranPagingCycle=v32
...    NRBTS:activityNotificationLevelSA=ue
...    NRBTS:srbInactivityTimerSA=30

@{other_resource_reserve}
...    NRCELL:actPriorityAccess=false
...    NRCELL:actEmergencyCall=false
...    NRBTS:actDrbPreemption=false
...    NRBTS:actUserPreemption=false
#...    NRCELL:numOfRadioResReservForTempUse=30
...    NRCELL:numOfRadioResReservForTempUse=0
...    NRCELL:numOfRadioResReservForEmergency=0
...    NRCELL:numOfRadioResReservForPa=0

@{limit_maxNumOfRrcSA}
...    NRCELL:maxNumOfRrcSA=10
...    NRBTS/NRCELLGRP-0:maxNumOfRrcCGRPSA=9
...    NRCELL-2:maxNumOfNonGBRBearersSA=8

@{limit_maxNumOfUsersPerNRCell}
...    NRCELL:maxNumOfUsersPerNRCell=10
...    NRCELL:maxNumOfUsersPerCell=10
...    NRCELL:maxNumOfCaUsersNRCell=10
...    NRCELL:maxNumOfNrDcSnUsers=10
...    NRCELL:maxNumOfSCellAlloc=10
...    NRBTS/NRCELLGRP-0:maxNumOfUsers=50
...    NRBTS/NRCELLGRP-1:maxNumOfUsers=50
...    NRBTS/NRCELLGRP-2:maxNumOfUsers=50
...    MRBTS/NRBTS/NRDU-1:maxNumOfRrcConUEsPerDU=20

##supported UE Power Saving's releasePreference-r16
${ue_nr_capabilities}    SEPARATOR=
...    E1A00000074E5A031E000383A000F04983200021E12006201A0130080C0700CA8D851AC101434
...    04B2CA261A007AD8202020E1DE38720C38002064F1F570004F001C0013C002A36266B04050D01
...    2CB28986801EB608080838778E1C830E0008193C7D5C0013C0070004F000A8D89BAC10143404B
...    2CA261A007AD8202020E1DE38720C38002064F1F570004F001C0013C002A36276B04050D012CB
...    28986801EB608080838778E1C830E0008193C7D54000014000000420E26800000001013454000
...    3804044F617001800140E0A00E06013003800341F000000000000072A68000800004B2CA801A5
...    5542C007000B00000004008011AB130001020304050607080B101112131921252627284A052880001080

${PLMN_1}    311:489
${PLMN_2}    262:003

*** Test Cases ***
CB008195-C-ET_013_Verify Successful NSA UE Context m-cell pooled resource check that reach minQuota but has no unused m-cell pooled resources
    [Documentation]
    ...    The test scenario is intended to verify Verify Successful NSA UE Context multiple-cell pooled resource limits check that
    ...    reach minQuota and there has unused and unreserved multiple-cell pooled resources.
    ...    Test Case Setings:
    ...    Vendor parameters update: maxNumOfUserL2Pool=18    maxNumPucchF1SRPerSlotL1Pool=30    maxNumPucchF3PCSIPerSlotL1Pool=30
    ...    NRCELL:maxNumOfUsersPerNRCell=10
    ...    NRCELL:maxNumOfUsersPerCell=10
    ...    ================================================================================================================
    ...    NRCELL-1:nrResourceGroupProfileRacDN=NRRESOURCEGROUP_PROFILE-0
    ...    NRBTS/NRRESOURCEGROUP_PROFILE-0:defaultRgNsaList:nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1
    ...    NRBTS/NRRESOURCEGROUP_PROFILE-0:defaultRgNsaList:nrResourceGroupId=1
    ...    NRBTS/NRRESOURCEGROUP_PROFILE-0:defaultRgSaList:nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-2
    ...    NRBTS/NRRESOURCEGROUP_PROFILE-0:defaultRgSaList:nrResourceGroupId=2
    ...    NRBTS/NRRESOURCEGROUP_PROFILE-0/NRRESOURCEGROUP-1:nrResourceList:resourceDN=MRBTS-1/NRBTS-1/NRPLMN-1
    ...    NRBTS/NRRESOURCEGROUP_PROFILE-0/NRRESOURCEGROUP-1:racParams:maxQuota=80    # 80%*10 = 8, max 8 UEs, common pool
    ...    NRBTS/NRRESOURCEGROUP_PROFILE-0/NRRESOURCEGROUP-1:racParams:minQuota=60    # 60%*10 = 6, min 6 UEs, dedicate pool
    ...    NRBTS/NRRESOURCEGROUP_PROFILE-0/NRRESOURCEGROUP-2:nrResourceList:resourceDN=MRBTS-1/NRBTS-1/NRPLMN-2
    ...    NRBTS/NRRESOURCEGROUP_PROFILE-0/NRRESOURCEGROUP-2:racParams:maxQuota=40     # 40%*10 = 4, max 4 UEs, common pool
    ...    NRBTS/NRRESOURCEGROUP_PROFILE-0/NRRESOURCEGROUP-2:racParams:minQuota=10     # 10%*10 = 1, min 1 UEs, dedicate pool
    ...    =================================================================================================================
    ...    NRCELL-3:nrResourceGroupProfileRacDN=NRRESOURCEGROUP_PROFILE-1
    ...    NRBTS/NRRESOURCEGROUP_PROFILE-1:defaultRgNsaList:nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1
    ...    NRBTS/NRRESOURCEGROUP_PROFILE-1:defaultRgNsaList:nrResourceGroupId=1
    ...    NRBTS/NRRESOURCEGROUP_PROFILE-1:defaultRgSaList:nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-2
    ...    NRBTS/NRRESOURCEGROUP_PROFILE-1:defaultRgSaList:nrResourceGroupId=2
    ...    NRBTS/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-1:nrResourceList:resourceDN=MRBTS-1/NRBTS-1/NRPLMN-1
    ...    NRBTS/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-1:racParams:maxQuota=20    # 20%*10 = 2, max 2 UEs, common pool
    ...    NRBTS/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-1:racParams:minQuota=0    # 0%*10 = 0, min 0 UEs, dedicated pool
    ...    NRBTS/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-2:nrResourceList:resourceDN=MRBTS-1/NRBTS-1/NRPLMN-2
    ...    NRBTS/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-2:racParams:maxQuota=100    # 100%*10 = 10, max 10 UEs, common pool
    ...    NRBTS/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-2:racParams:minQuota=80    # 80%*10 = 8, min 8 UEs, dedicated pool
    ...    ==================================================================================================================s

    [Tags]    QC_****    owner-zhubaijie
    UE11 and UE12 attach to CELL3 with PLMN-1 to occupy ResourceGroupId-1 common resources
    UE13 attach to CELL1 with PLMN-2 to occupy ResourceGroupId-2 dedicated resources
    UE14 attach CELL1 with PLMN-2 sucessfully using ResourceGroup-2 common resource and then no pool resouce left
    UE15 attach CELL1 with PLMN-2 failed due to no pool resource left
    Release UE12 to release ResourceGroupId-1 common resource and UE15 attach to CELL1 with PLMN-2 success

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/3cells_ecpri

Modify Cfg
    Set PDU Session in WTS
    Set AMF config
    Set UE config
    Set Bearer

Set Bearer
    Update Cfg    set_bearer id=3 ue=11 qci=8 pdn=1 preprovisioned=on filter=2 precedence=2
    Update Cfg    set_bearer id=3 ue=12 qci=8 pdn=1 preprovisioned=on filter=2 precedence=2
    Update Cfg    set_bearer id=3 ue=13 qci=8 pdn=1 preprovisioned=on filter=2 precedence=2
    Update Cfg    enb_param id=1 drb_id_begin=3 endc_capable_qci=all

Set AMF config
    Update Cfg    set_amf_region id=1 tac_list=100,200,300 plmn=311:489
    Update Cfg    amf_param id=1 full_nas_auth=on nia=null+zuc nea=null+zuc ims_voice_3gpp=on
    Update Cfg    set_amf id=1 daemon=10.0.2.1:22222 ng=10.0.1.1:38412 region=1 set_id=2 pointer=2 name=SimModeAMF1
    Update Cfg    amf_ng_setup_param id=1 relative_capacity=10 include_backup_amf_name=on ue_retention=on retention_time=indefinite
    Update Cfg    set_nwslice id=1 snssai=0x01:0xd143a5 amf=1 default=on qos_flows=7,6,5,4,3,2,1 qos_rules=1,2 ue=all
    Update Cfg    set_nwslice id=2 snssai=0x01:0xd143a6 amf=1 qos_flows=7,6,5,4,3,2,1 qos_rules=1,2 ue=all
    Update Cfg    set_nwslice id=3 snssai=0x01:0xd143a7 amf=1 qos_flows=7,6,5,4,3,2,1 qos_rules=1,2 ue=all

Set PDU Session in WTS
    Update Cfg    set_qosflow id=1 5qi=1 priority=1 pci=may_trigger_pre_emption pvi=pre_emptable
    Update Cfg    set_qosflow id=2 5qi=2 priority=2 pci=may_trigger_pre_emption pvi=pre_emptable
    Update Cfg    set_qosflow id=3 5qi=3 priority=3 pci=may_trigger_pre_emption pvi=pre_emptable
    Update Cfg    set_qosflow id=4 5qi=4 priority=4 pci=shall_not_trigger_pre_emption pvi=not_pre_emptable
    Update Cfg    set_qosflow id=5 5qi=5 default=on priority=5 pci=may_trigger_pre_emption pvi=pre_emptable
    Update Cfg    set_qosflow id=6 5qi=6 priority=6 pci=may_trigger_pre_emption pvi=pre_emptable
    Update Cfg    set_qosflow id=7 5qi=7 priority=7 pci=shall_not_trigger_pre_emption pvi=pre_emptable
    Update Cfg    qosrule_set id=1 proto=tcp qos_flow=1
    Update Cfg    qosrule_set id=2 proto=udp qos_flow=2

Set UE config
    Update Cfg    ue_nr_capabilities id=1-6 voice_over_nr=on:on:off
    Update Cfg    ue_param id=1-6 nr_usage_setting=voice_centric ue_nr_capabilities=${ue_nr_capabilities}
    ${set_ue11}    catenate    set_ue simulated id=11 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00
    ...    nia=null+snow3g+aes+zuc nea=null+snow3g+aes+zuc imsi=${PLMN_1}:21645400
    ${set_ue12}    catenate    set_ue simulated id=12 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00
    ...    nia=null+snow3g+aes+zuc nea=null+snow3g+aes+zuc imsi=${PLMN_1}:21645401
    ${set_ue13}    catenate    set_ue simulated id=13 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00
    ...    nia=null+snow3g+aes+zuc nea=null+snow3g+aes+zuc imsi=${PLMN_2}:21645402
    ${set_ue14}    catenate    set_ue simulated id=14 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00
    ...    nia=null+snow3g+aes+zuc nea=null+snow3g+aes+zuc imsi=${PLMN_2}:21645403
    ${set_ue15}    catenate    set_ue simulated id=15 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00
    ...    nia=null+snow3g+aes+zuc nea=null+snow3g+aes+zuc imsi=${PLMN_2}:21645404
    Update Cfg    ${set_ue11}
    Update Cfg    ${set_ue12}
    Update Cfg    ${set_ue13}
    Update Cfg    ${set_ue14}
    Update Cfg    ${set_ue15}

Send Throuput For NSA
    [Arguments]    ${ue_id}=11
    Execute Egate Command    trf_data_start ue=${ue_id} id=2 dir=dl mbps=10 trf_id=1    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} id=2 dir=ul mbps=10 trf_id=1    UE ${ue_id}: UDP UL
    sleep    10s    #sleep for stable traffic

Verify Throuput on Pscell For NSA
    [Arguments]    ${ue_id}=11    ${pcell_dl}=0    ${ul}=0
    sleep    5s    #sleep for stable traffic
    ${scell8_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=8    type=pdsch    rate_type=ave
    Should Be True    ${scell8_tput}/1000>${pcell_dl}
    ${ul_throughput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=8    type=pusch    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul}

NSA UE attach
    [Arguments]  ${ue_id}=11    ${selected_plmn}=311:489    ${target_cells}=1
    Execute Egate Command    ue_attach id=${ue_id}    UE IS ACTIVE
    Execute Egate Command    enb_endc_param id=1 selected_plmn=${selected_plmn}
    Execute Egate Command    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${target_cells} bearer=2 type=split_scg
    ...    UE${ue_id}: Proxy \\(eNB 2 cell ${target_cells}\\) reported successful RA

NSA UE detach
    [Arguments]  ${ue_id}=11
    Execute Egate Command    ue_detach id=${ue_id}    UE${ue_id}: ----- UE-initiated NAS DETACH PROCEDURE IS COMPLETED -----

NSA UE attach failed
    [Arguments]  ${ue_id}=11    ${selected_plmn}=311:489    ${target_cells}=1
    Execute Egate Command    ue_attach id=${ue_id}    UE IS ACTIVE
    Execute Egate Command    enb_endc_param id=1 selected_plmn=${selected_plmn}
    Execute Egate Command    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${target_cells} bearer=2 type=split_scg
    ...    no-radio-resources-available
    Execute Egate Command    ue_detach id=${ue_id}    UE${ue_id}: ----- UE-initiated NAS DETACH PROCEDURE IS COMPLETED -----

UE11 and UE12 attach to CELL3 with PLMN-1 to occupy ResourceGroupId-1 common resources
    NSA UE attach    ue_id=11    selected_plmn=${PLMN_1}    target_cells=3
    NSA UE attach    ue_id=12    selected_plmn=${PLMN_1}    target_cells=3

UE13 attach to CELL1 with PLMN-2 to occupy ResourceGroupId-2 dedicated resources
    NSA UE attach    ue_id=13    selected_plmn=${PLMN_2}    target_cells=1

UE14 attach CELL1 with PLMN-2 sucessfully using ResourceGroup-2 common resource and then no pool resouce left
    NSA UE attach    ue_id=14    selected_plmn=${PLMN_2}    target_cells=1

UE15 attach CELL1 with PLMN-2 failed due to no pool resource left
    NSA UE attach failed    ue_id=15    selected_plmn=${PLMN_2}    target_cells=1

Release UE12 to release ResourceGroupId-1 common resource and UE15 attach to CELL1 with PLMN-2 success
    NSA UE detach    ue_id=12
    NSA UE attach    ue_id=15    selected_plmn=${PLMN_2}    target_cells=1