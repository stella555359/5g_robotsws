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
@{PARAMS_IN_SCF}
...    @{TAC}
...    @{CB008225}
...    @{other_resource_reserve}
...    @{limit_maxNumOfRrcSA}
...    @{limit_maxNumOfUsersPerNRCell}
...    @{cellDepType}
...    @{gnbCutyp_NSA_only}
...    @{nsaDrbParam}
...    @{C003}

#C003 settings
@{C003}
...    NRBTS:actSpidBasedSlicingNSA=true
...    NRBTS:actSliceAwareScheduler=true
...    NRCELL:maxNumOfUsersPerNRCell=10
...    NRCELL:maxNumOfUsersPerCell=10
...    NRBTS/NRPMRNL-1:miNrCellUtilPerPLMN=disabled
...    @{SPIDGRP}
...    @{CB008195}
...    @{NRRESOURCEGROUP_PROFILE}
...    @{5GC000710}

@{SPIDGRP}
...    NRBTS-1/NRSPIDGRP-1:nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS-1/NRSPIDGRP-1:nrSpidGrpId=1
...    NRBTS-1/NRSPIDGRP-1:spid=54
...    NRBTS-1/NRSPIDGRP-1:spidLast=59
...    NRBTS-1/NRSPIDGRP-2:nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS-1/NRSPIDGRP-2:nrSpidGrpId=2
...    NRBTS-1/NRSPIDGRP-2:spid=256
...    NRBTS-1/NRSPIDGRP-3:nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS-1/NRSPIDGRP-3:nrSpidGrpId=3
...    NRBTS-1/NRSPIDGRP-3:spid=30
...    NRBTS-1/NRSPIDGRP-3:spidLast=35

@{5GC000710}
...    NRBTS:actMobilityProfile=true
...    NRBTS:actSPID=true
...    NRBTS/NRMOPR_NSA-1:a2MeashoEnabled=none
...    NRBTS/NRMOPR_NSA-1:a3MeasEnabled=none
...    NRBTS/NRMOPR_NSA-1:a5MeasEnabled=none
...    NRCELL:nrDefMoPrNsaDN=MRBTS-1/NRBTS-1/NRMOPR_NSA-1
...    NRCELL:a2MeasRedirectSsbRsrp:a2ThresholdRedirectSsbRsrp=19
...    NRCELL:a2MeasReleaseSsbRsrp:a2ThresholdReleaseSsbRsrp=19

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
...    NRCELL:configuredEpsTac=222
...    NRCELL:cellDepType=NSA
...    delete:NRCELL:ranAC
...    delete:NRCELL:trackingAreaDN
...    NRCELL:msg1FrequencyStart=18

@{CB008195}
...    MRBTS/NRBTS:rgMinQuotaReservationLevel=cell_and_multicell_level
...    NRBTS:actDrbPreemption=false
...    NRBTS:actUserPreemption=false
...    NRBTS/NRCELL:actPriorityAccess=false
...    NRBTS/NRCELL:actEmergencyCall=false
...    NRBTS:actSliceAwareAdmissionCtrl=true
...    NRCELL:sliceAwareAdmissionCtrlEnabled=true
...    NRCELL-1:nrResourceGroupProfileRacDN=NRRESOURCEGROUP_PROFILE-1
...    NRCELL-2:nrResourceGroupProfileRacDN=NRRESOURCEGROUP_PROFILE-0
...    NRCELL-3:nrResourceGroupProfileRacDN=NRRESOURCEGROUP_PROFILE-3
...    NRBTS/NRPMRNL-1:miNrCellUtilPerNrg=5min

@{NRRESOURCEGROUP_PROFILE}
#NRRESOURCEGROUP_PROFILE-0 - PLMN1-SPIDGBR 1,2,3
...    NRBTS/NRRESOURCEGROUP_PROFILE-0:bypassRgLimits=4
...    NRBTS/NRRESOURCEGROUP_PROFILE-0:defaultRgNsaList:nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS/NRRESOURCEGROUP_PROFILE-0:defaultRgNsaList:nrResourceGroupId=1
...    NRBTS/NRRESOURCEGROUP_PROFILE-0:defaultRgSaList:nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS/NRRESOURCEGROUP_PROFILE-0:defaultRgSaList:nrResourceGroupId=1
...    NRBTS/NRRESOURCEGROUP_PROFILE-0/NRRESOURCEGROUP-1:nrResourceList:resourceDN=MRBTS-1/NRBTS-1/NRSPIDGRP-1
...    NRBTS/NRRESOURCEGROUP_PROFILE-0/NRRESOURCEGROUP-1:racParams:maxQuota=20   # 20%*10 = 2, max 2 UEs, common pool
...    NRBTS/NRRESOURCEGROUP_PROFILE-0/NRRESOURCEGROUP-1:racParams:minQuota=19   # 19%*10 = 1.9, min 1 UEs, dedicated pool
...    NRBTS/NRRESOURCEGROUP_PROFILE-0/NRRESOURCEGROUP-2:nrResourceList:resourceDN=MRBTS-1/NRBTS-1/NRSPIDGRP-2
...    NRBTS/NRRESOURCEGROUP_PROFILE-0/NRRESOURCEGROUP-2:racParams:maxQuota=1    # 1%*10 = 0.1, max 0 UEs, common pool
...    NRBTS/NRRESOURCEGROUP_PROFILE-0/NRRESOURCEGROUP-2:racParams:minQuota=0    # 0%*10 = 0, min 0 UEs, dedicated pool
...    NRBTS/NRRESOURCEGROUP_PROFILE-0/NRRESOURCEGROUP-3:nrResourceList:resourceDN=MRBTS-1/NRBTS-1/NRSPIDGRP-3
...    NRBTS/NRRESOURCEGROUP_PROFILE-0/NRRESOURCEGROUP-3:racParams:maxQuota=81   # 81%*10 = 8.1, max 8 UEs, common pool
...    NRBTS/NRRESOURCEGROUP_PROFILE-0/NRRESOURCEGROUP-3:racParams:minQuota=80   # 80%*10 = 8.0, max 8 UEs, dedicated pool

#NRRESOURCEGROUP_PROFILE-1 - PLMN1-SPIDGRP 1,2,3
...    NRBTS/NRRESOURCEGROUP_PROFILE-1:bypassRgLimits=4
...    NRBTS/NRRESOURCEGROUP_PROFILE-1:defaultRgNsaList:nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS/NRRESOURCEGROUP_PROFILE-1:defaultRgNsaList:nrResourceGroupId=1
...    NRBTS/NRRESOURCEGROUP_PROFILE-1:defaultRgSaList:nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS/NRRESOURCEGROUP_PROFILE-1:defaultRgSaList:nrResourceGroupId=1
...    NRBTS/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-1:nrResourceList:resourceDN=MRBTS-1/NRBTS-1/NRSPIDGRP-1
...    NRBTS/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-1:racParams:maxQuota=20    # 20%*10 = 2, max 2 UEs, common pool
...    NRBTS/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-1:racParams:minQuota=10    # 10%*10 = 1，min 1 UEs, dedicated pool
...    NRBTS/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-2:nrResourceList:resourceDN=MRBTS-1/NRBTS-1/NRSPIDGRP-2
...    NRBTS/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-2:racParams:maxQuota=10    # 10*10 =  1，max 1 UEs, common pool
...    NRBTS/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-2:racParams:minQuota=0     # 0%*10 =  0, min 0 UEs, dedicated pool
...    NRBTS/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-3:nrResourceList:resourceDN=MRBTS-1/NRBTS-1/NRSPIDGRP-3
...    NRBTS/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-3:racParams:maxQuota=90    # 90*10 =  9，max 9 UEs, common pool
...    NRBTS/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-3:racParams:minQuota=80    # 80*10 =  8，max 8 UEs, dedicated pool

##NRRESOURCEGROUP_PROFILE-2 - PLMN1-NRSPIDGRP-1
...    NRBTS/NRRESOURCEGROUP_PROFILE-2:bypassRgLimits=4
...    NRBTS/NRRESOURCEGROUP_PROFILE-2:defaultRgNsaList:nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS/NRRESOURCEGROUP_PROFILE-2:defaultRgNsaList:nrResourceGroupId=1
...    NRBTS/NRRESOURCEGROUP_PROFILE-2:defaultRgSaList:nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS/NRRESOURCEGROUP_PROFILE-2:defaultRgSaList:nrResourceGroupId=1
...    NRBTS/NRRESOURCEGROUP_PROFILE-2/NRRESOURCEGROUP-1:nrResourceList:resourceDN=MRBTS-1/NRBTS-1/NRSPIDGRP-1
...    NRBTS/NRRESOURCEGROUP_PROFILE-2/NRRESOURCEGROUP-1:racParams:maxQuota=80
...    NRBTS/NRRESOURCEGROUP_PROFILE-2/NRRESOURCEGROUP-1:racParams:minQuota=20

#NRRESOURCEGROUP_PROFILE-3 - PLMN1-NRSPIDGRP-1
...    NRBTS/NRRESOURCEGROUP_PROFILE-3:bypassRgLimits=4
...    NRBTS/NRRESOURCEGROUP_PROFILE-3:defaultRgNsaList:nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS/NRRESOURCEGROUP_PROFILE-3:defaultRgNsaList:nrResourceGroupId=1
...    NRBTS/NRRESOURCEGROUP_PROFILE-3:defaultRgSaList:nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS/NRRESOURCEGROUP_PROFILE-3:defaultRgSaList:nrResourceGroupId=1
...    NRBTS/NRRESOURCEGROUP_PROFILE-3/NRRESOURCEGROUP-1:nrResourceList:resourceDN=MRBTS-1/NRBTS-1/NRSPIDGRP-1
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
...    NRCELL-1:actPriorityAccess=false
...    NRCELL:actEmergencyCall=false
...    NRBTS:actDrbPreemption=false
...    NRBTS:actUserPreemption=false
...    NRCELL:numOfRadioResReservForTempUse=30
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

@{PM_Counters_Check_ET_C0304}
...    NRCELL-1/NRRESOURCEGROUP-1:${AVG_NUM_UE_NOM_NRG}>0
...    NRCELL-1/NRRESOURCEGROUP-1:${DNOM_SAMPLES_NRG}>0
...    NRCELL-1/NRRESOURCEGROUP-1:${AVE_NUM_NGBR_NOM_NRG}>0
...    NRCELL-1/NRRESOURCEGROUP-1:${PEAK_NUM_UE_NRG}=4
...    NRCELL-1/NRRESOURCEGROUP-1:${PEAK_NUM_NGBR_NRG}=4
...    NRCELL-1/NRRESOURCEGROUP-1:${NUM_ADM_REQ_NGBR_NRG}=4
...    NRCELL-1/NRRESOURCEGROUP-1:${NUM_ADM_SUC_NGBR_NRG}=3
...    NRCELL-1/NRRESOURCEGROUP-1:${NUM_ADM_REQ_UE_NRG}=4
...    NRCELL-1/NRRESOURCEGROUP-1:${NUM_ADM_SUC_UE_NRG}=3
...    NRCELL-1/NRRESOURCEGROUP-1:${RAC_REJ_DUE_DRB_MAX_QUOTA_NRG}=0
...    NRCELL-1/NRRESOURCEGROUP-1:${RAC_REJ_DUE_UE_MAX_QUOTA_NRG}=1
...    NRCELL-1/NRRESOURCEGROUP-2:${AVG_NUM_UE_NOM_NRG}>0
...    NRCELL-1/NRRESOURCEGROUP-2:${DNOM_SAMPLES_NRG}>0
...    NRCELL-1/NRRESOURCEGROUP-2:${AVE_NUM_NGBR_NOM_NRG}>0
...    NRCELL-1/NRRESOURCEGROUP-2:${PEAK_NUM_UE_NRG}>=1
...    NRCELL-1/NRRESOURCEGROUP-2:${PEAK_NUM_NGBR_NRG}>=1
...    NRCELL-1/NRRESOURCEGROUP-2:${NUM_ADM_REQ_NGBR_NRG}=2
...    NRCELL-1/NRRESOURCEGROUP-2:${NUM_ADM_SUC_NGBR_NRG}=1
...    NRCELL-1/NRRESOURCEGROUP-2:${NUM_ADM_REQ_UE_NRG}=2
...    NRCELL-1/NRRESOURCEGROUP-2:${NUM_ADM_SUC_UE_NRG}=1
...    NRCELL-1/NRRESOURCEGROUP-2:${RAC_REJ_DUE_DRB_MAX_QUOTA_NRG}=0
...    NRCELL-1/NRRESOURCEGROUP-2:${RAC_REJ_DUE_UE_MAX_QUOTA_NRG}=0
...    NRCELL-1/NRRESOURCEGROUP-3:${AVG_NUM_UE_NOM_NRG}>0
...    NRCELL-1/NRRESOURCEGROUP-3:${DNOM_SAMPLES_NRG}>0
...    NRCELL-1/NRRESOURCEGROUP-3:${AVE_NUM_NGBR_NOM_NRG}>0
...    NRCELL-1/NRRESOURCEGROUP-3:${PEAK_NUM_UE_NRG}>=15
...    NRCELL-1/NRRESOURCEGROUP-3:${PEAK_NUM_NGBR_NRG}>=15
...    NRCELL-1/NRRESOURCEGROUP-3:${NUM_ADM_REQ_NGBR_NRG}=9
...    NRCELL-1/NRRESOURCEGROUP-3:${NUM_ADM_SUC_NGBR_NRG}=9
...    NRCELL-1/NRRESOURCEGROUP-3:${NUM_ADM_REQ_UE_NRG}=9
...    NRCELL-1/NRRESOURCEGROUP-3:${NUM_ADM_SUC_UE_NRG}=9
...    NRCELL-1/NRRESOURCEGROUP-3:${RAC_REJ_DUE_DRB_MAX_QUOTA_NRG}=0
...    NRCELL-1/NRRESOURCEGROUP-3:${RAC_REJ_DUE_UE_MAX_QUOTA_NRG}=0

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


##supported UE Power Saving's releasePreference-r16
${ue_nr_capabilities}    SEPARATOR=
...    E1A00000074E5A031E000383A000F04983200021E12006201A0130080C0700CA8D851AC101434
...    04B2CA261A007AD8202020E1DE38720C38002064F1F570004F001C0013C002A36266B04050D01
...    2CB28986801EB608080838778E1C830E0008193C7D5C0013C0070004F000A8D89BAC10143404B
...    2CA261A007AD8202020E1DE38720C38002064F1F570004F001C0013C002A36276B04050D012CB
...    28986801EB608080838778E1C830E0008193C7D54000014000000420E26800000001013454000
...    3804044F617001800140E0A00E06013003800341F000000000000072A68000800004B2CA801A5
...    5542C007000B00000004008011AB130001020304050607080B101112131921252627284A052880001080

*** Test Cases ***
CB008195-C-ET_003_004_Verify NSA UE Context Static cell limits check Success With resource allcated in Dedicate and Common pool As Per SPID
    [Documentation]
    ...    The test scenario is intended to verify NSA UE Context Static cell limits check Success With resource
    ...    allcated in Dedicate pool and Common pool As Per SPID. ue_id 27 has no NUM_ADM_REQ_UE_NRG beacuse cpcl rejects it due to the max
    ...    maxUsersPerCell:10.
    ...    Test Case Steps:
    ...    NRCELL:maxNumOfUsersPerNRCell=10
    ...    NRCELL:maxNumOfUsersPerCell=10
    ...    ================================================================================================================
    ...    NRCELL-1:nrResourceGroupProfileRacDN=NRRESOURCEGROUP_PROFILE-1
    ...    NRBTS/NRRESOURCEGROUP_PROFILE-1:defaultRgNsaList:nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1
    ...    NRBTS/NRRESOURCEGROUP_PROFILE-1:defaultRgNsaList:nrResourceGroupId=1
    ...    NRBTS/NRRESOURCEGROUP_PROFILE-1:defaultRgSaList:nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1
    ...    NRBTS/NRRESOURCEGROUP_PROFILE-1:defaultRgSaList:nrResourceGroupId=1
    ...    NRBTS/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-1:nrResourceList:resourceDN=MRBTS-1/NRBTS-1/NRSPIDGRP-1
    ...    NRBTS/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-1:racParams:maxQuota=20    # 20%*10 = 2, max 2 UEs, common pool
    ...    NRBTS/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-1:racParams:minQuota=10    # 10%*10 = 1, min 1 UEs, dedicate pool
    ...    NRBTS/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-2:nrResourceList:resourceDN=MRBTS-1/NRBTS-1/NRSPIDGRP-2
    ...    NRBTS/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-2:racParams:maxQuota=10    # 10%*10 = 1, max 1 UEs, common pool
    ...    NRBTS/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-2:racParams:minQuota=0     # 0%*10 = 0, min 0 UEs, dedicate pool
    ...    NRBTS/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-3:nrResourceList:resourceDN=MRBTS-1/NRBTS-1/NRSPIDGRP-3
    ...    NRBTS/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-3:racParams:maxQuota=90    # 90%*10 = 9, max 9 UEs, common pool
    ...    NRBTS/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-3:racParams:minQuota=80    # 80%*10 = 8, min 8 UEs, dedicate pool
    ...    =================================================================================================================
    ...    NRCELL-2:nrResourceGroupProfileRacDN=NRRESOURCEGROUP_PROFILE-0
    ...    NRBTS/NRRESOURCEGROUP_PROFILE-0:defaultRgNsaList:nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1
    ...    NRBTS/NRRESOURCEGROUP_PROFILE-0:defaultRgNsaList:nrResourceGroupId=1
    ...    NRBTS/NRRESOURCEGROUP_PROFILE-0:defaultRgSaList:nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1
    ...    NRBTS/NRRESOURCEGROUP_PROFILE-0:defaultRgSaList:nrResourceGroupId=1
    ...    NRBTS/NRRESOURCEGROUP_PROFILE-0/NRRESOURCEGROUP-1:nrResourceList:resourceDN=MRBTS-1/NRBTS-1/NRSPIDGRP-1
    ...    NRBTS/NRRESOURCEGROUP_PROFILE-0/NRRESOURCEGROUP-1:racParams:maxQuota=20   # 20%*10 = 2, max 2 UEs, common pool
    ...    NRBTS/NRRESOURCEGROUP_PROFILE-0/NRRESOURCEGROUP-1:racParams:minQuota=19   # 19%*10 = 1.9, min 1 UEs, dedicated pool
    ...    NRBTS/NRRESOURCEGROUP_PROFILE-0/NRRESOURCEGROUP-2:nrResourceList:resourceDN=MRBTS-1/NRBTS-1/NRSPIDGRP-2
    ...    NRBTS/NRRESOURCEGROUP_PROFILE-0/NRRESOURCEGROUP-2:racParams:maxQuota=1    # 1%*10 = 0.1, max 0 UEs, common pool
    ...    NRBTS/NRRESOURCEGROUP_PROFILE-0/NRRESOURCEGROUP-2:racParams:minQuota=0    # 0%*10 = 0, min 0 UEs, dedicated pool
    ...    NRBTS/NRRESOURCEGROUP_PROFILE-0/NRRESOURCEGROUP-3:nrResourceList:resourceDN=MRBTS-1/NRBTS-1/NRSPIDGRP-3
    ...    NRBTS/NRRESOURCEGROUP_PROFILE-0/NRRESOURCEGROUP-3:racParams:maxQuota=81   # 81%*10 = 8.1, max 8 UEs, common pool
    ...    NRBTS/NRRESOURCEGROUP_PROFILE-0/NRRESOURCEGROUP-3:racParams:minQuota=80   # 80%*10 = 8.0, max 8 UEs, dedicated pool
    ...    ==================================================================================================================s
    ...    ue11 with spid 54    NRSPIDGRP-1  54-59
    ...    ue12 with spid 55    NRSPIDGRP-1  54-59
    ...    ue13 with spid 56    NRSPIDGRP-1  54-59
    ...    ue14 with spid 256   NRSPIDGRP-2  256
    ...    ue15 with spid 256   NRSPIDGRP-2  256
    ...    ue16 with spid 30    NRSPIDGRP-3  30-35
    ...    ue17 with spid 31    NRSPIDGRP-3  30-35
    ...    ue18 with spid 32    NRSPIDGRP-3  30-35
    ...    ue19 with spid 33    NRSPIDGRP-3  30-35
    ...    ue20 with spid 34    NRSPIDGRP-3  30-35
    ...    ue21 with spid 35    NRSPIDGRP-3  30-35
    ...    ue22 with spid 35    NRSPIDGRP-3  30-35
    ...    ue23 with spid 35    NRSPIDGRP-3  30-35
    ...    ue24 with spid 35    NRSPIDGRP-3  30-35
    ...    ue25 with spid 35    NRSPIDGRP-3  30-35
    [Tags]    QC_****    owner-zhubaijie
    Clear Counter files
    Set Spid For UEs
    RG1 1 dedicated pool and 1 common pool are used by NSA attach procedure
    UE attach unsucessfully using RG2 common resoure beacuse no common resource left
    RG3 8 dedicated pool and 0 common pool are used by NSA attach procedure
    UE attach sucessfully using RG2 Common resource after releasing RG1 common Resource
    UE attach unsucessfully using RG3 common resoure beacuse no common resource left
    UE attach sucessfully using RG3 common resoure after releasing RG2 common resource
    No spid definition for the UE will take as in the RG1
    Check Counters    pm_counters_expression=${PM_Counters_Check_ET_C0304}
    Release UEs    ue_type=all
    RG1 1 dedicated pool and 0 common pool are used by NSA attach procedure
    RG3 1 dedicated pool and 0 common pool are used by NSA attach procedure
    RG2 1 common pool are used by NSA attach procedure and no common resource left
    UE attach unsucessfully using RG1 common resoure beacuse no common resource left
    UE attach sucessfully using RG1 Common resource after releasing RG2 common Resource
    Release UEs    ue_type=all
    Cell2 RG Exploratory Testing

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

NSA Addition expect unsuccessfully
    [Arguments]    ${cell_id}=1    ${ue_id}=11
    UE Attach To Target Cell   ${cell_id}    ${ue_id}

NSA Addition successfully
    [Arguments]    ${cell_id}=1    ${ue_id}=11
    UE Attach To Target Cell   ${cell_id}    ${ue_id}
    Send Throuput For NSA    ${ue_id}
    Verify Throuput on Pscell For NSA    ${ue_id}

Send Throuput For NSA
    [Arguments]    ${ue_id}=11
    Execute Egate Command    trf_data_start ue=${ue_id} id=2 dir=dl mbps=10 trf_id=1    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} id=2 dir=ul mbps=10 trf_id=1    UE ${ue_id}: UDP UL
    sleep    10s    #sleep for stable traffic

UE Attach To Target Cell
    [Arguments]    ${cell_id}=1    ${ue_id}=11
    Log To Console    attach:${ue_id} to cell:${cell_id}
    Execute Egate Command    ue_attach id=${ue_id}    UE IS ACTIVE
    Execute Egate Command    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${cell_id} bearer=2 type=split_scg
    ...    reported successful RA

UE Attach To Target Cell expect failed
    [Arguments]    ${cell_id}=1    ${ue_id}=11
    Log To Console    attach:${ue_id} to cell:${cell_id}
    Execute Egate Command    ue_attach id=${ue_id}    UE IS ACTIVE
    Execute Egate Command    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${cell_id} bearer=2 type=split_scg
    ...    no-radio-resources-available

Verify Throuput on Pscell For NSA
    [Arguments]    ${ue_id}=11    ${pcell_dl}=0    ${ul}=0
    sleep    5s    #sleep for stable traffic
    ${scell8_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=8    type=pdsch    rate_type=ave
    Should Be True    ${scell8_tput}/1000>${pcell_dl}
    ${ul_throughput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=8    type=pusch    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul}

set spid for UE
    [Documentation]    set spid before attach in wts
    ...     :param ${ue_id}:   number of UE
    ...     :param ${spid}:    spid value to be set
    [Arguments]     ${ue_id}     ${spid}
    sleep     2s
    Log To Console    set UE:${ue_id} to spid:${spid}
    Execute Egate Command    ue_enb_param id=${ue_id} spid=${spid}

Set Spid For UEs
    set spid for UE    ue_id=11     spid=54
    set spid for UE    ue_id=12     spid=55
    set spid for UE    ue_id=13     spid=56
    set spid for UE    ue_id=14     spid=256
    set spid for UE    ue_id=15     spid=256
    set spid for UE    ue_id=16     spid=30
    set spid for UE    ue_id=17     spid=31
    set spid for UE    ue_id=18     spid=32
    set spid for UE    ue_id=19     spid=33
    set spid for UE    ue_id=20     spid=34
    set spid for UE    ue_id=21     spid=35
    set spid for UE    ue_id=22     spid=35
    set spid for UE    ue_id=23     spid=35
    set spid for UE    ue_id=24     spid=35
    set spid for UE    ue_id=25     spid=35

RG1 1 dedicated pool and 1 common pool are used by NSA attach procedure
    NSA Addition successfully    ue_id=11
    NSA Addition successfully    ue_id=12
    UE Attach To Target Cell expect failed    ue_id=13
    Release Ues    ue_type=nsa    ue_id=13

RG3 8 dedicated pool and 0 common pool are used by NSA attach procedure
    NSA Addition successfully    ue_id=16
    NSA Addition successfully    ue_id=17
    NSA Addition successfully    ue_id=18
    NSA Addition successfully    ue_id=19
    NSA Addition successfully    ue_id=20
    NSA Addition successfully    ue_id=21
    NSA Addition successfully    ue_id=22
    NSA Addition successfully    ue_id=23
    UE Attach To Target Cell expect failed    ue_id=24
    Release Ues    ue_type=nsa    ue_id=24

UE attach unsucessfully using RG2 common resoure beacuse no common resource left
    UE Attach To Target Cell expect failed    ue_id=14
    Release Ues    ue_type=nsa    ue_id=14

UE attach sucessfully using RG2 Common resource after releasing RG1 common Resource
    Release Ues    ue_type=nsa    ue_id=12
    NSA Addition successfully    ue_id=14

UE attach unsucessfully using RG3 common resoure beacuse no common resource left
    UE Attach To Target Cell expect failed    ue_id=24
    Release Ues    ue_type=nsa    ue_id=24

UE attach sucessfully using RG3 common resoure after releasing RG2 common resource
    Release Ues    ue_type=nsa    ue_id=14
    NSA Addition successfully    ue_id=24
    Release Ues    ue_type=nsa    ue_id=24

No spid definition for the UE will take as in the RG1
    NSA Addition successfully    ue_id=26
    UE Attach To Target Cell expect failed    ue_id=27
    Release Ues    ue_type=nsa    ue_id=27

Cell2 RG Exploratory Testing
    NSA Addition successfully    2    11
    NSA Addition successfully    2    12
    UE Attach To Target Cell expect failed    2    13
    Release Ues    ue_type=nsa    ue_id=13
    UE Attach To Target Cell expect failed    2    14
    Release Ues    ue_type=nsa    ue_id=14
    Release Ues    ue_type=nsa    ue_id=12
    UE Attach To Target Cell expect failed    2    14
    Release Ues    ue_type=nsa    ue_id=14
    NSA Addition successfully    2    16
    NSA Addition successfully    2    17
    NSA Addition successfully    2    18
    NSA Addition successfully    2    19
    NSA Addition successfully    2    20
    NSA Addition successfully    2    21
    NSA Addition successfully    2    22
    NSA Addition successfully    2    23
    UE Attach To Target Cell expect failed    2    24
    Release UEs    ue_type=all

RG1 1 dedicated pool and 0 common pool are used by NSA attach procedure
    NSA Addition successfully    ue_id=11

RG3 1 dedicated pool and 0 common pool are used by NSA attach procedure
    NSA Addition successfully    ue_id=16

RG2 1 common pool are used by NSA attach procedure and no common resource left
    NSA Addition successfully    ue_id=14

UE attach unsucessfully using RG1 common resoure beacuse no common resource left
    UE Attach To Target Cell expect failed    1    12
    Release Ues    ue_type=nsa    ue_id=12

UE attach sucessfully using RG1 Common resource after releasing RG2 common Resource
    Release Ues    ue_type=nsa    ue_id=14
    NSA Addition successfully    ue_id=12

