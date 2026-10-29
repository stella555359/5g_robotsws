*** Settings ***
Suite Setup       Common Suite Setup And Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CRT    CLOUD_R4LAPO_CUS
...               team-DevHZ5_SG4    owner-kang.xiang    release-L18A
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{deltaSCFC_setup}
...    @{deltaSCFC_other_consischeck}
...    @{IFGDPR_parameter}
...    @{CatM_Cell2_parameter}
...    delete:LNADJ.*
...    delete:LNHO.*
...    delete:IFGPR.*
...    delete:LNCEL-1/MBSFNCEL-0

@{deltaSCFC_setup}
...    LNBTS-1:actIncCarrMonit=true
...    LNBTS-1:actExtMeasCtrl=true
...    LNCEL-1:actSixIfMeasurements=false
...    LNCEL-1:act3fdd3tddRestrict=false
...    LNBTS-1:actSelMobPrf=false
...    LNBTS-1:actIfHo=enabled
...    LNBTS-1:actHOtoWcdma=false
...    LNBTS-1:acteNACCtoGSM=false
...    LNBTS-1/LNBTS_FDD-0:actSrvccToGsm=false
...    LNBTS-1/LNBTS_FDD-0:actSrvccToWcdma=false
...    LNBTS-1:actLTES1Ho=true
...    LNCEL-1:maxNumIFCarrMeas=16
...    LNCEL-1:incIRATHeadroom=0
...    LNBTS-1:actRedirect=disabled
...    LNBTS-1/MODPR-0:autoAdapt=true
...    LNCEL-1:threshold2InterFreq=52

@{deltaSCFC_other_consischeck}
...    LNCEL-2:incIRATHeadroom=0
...    LNCEL-3:incIRATHeadroom=0
...    LNCEL-2:maxNumIFCarrMeas=16
...    LNCEL-3:maxNumIFCarrMeas=16
...    LNCEL-2:actSixIfMeasurements=false
...    LNCEL-3:actSixIfMeasurements=false
...    LNCEL-2:act3fdd3tddRestrict=false
...    LNCEL-3:act3fdd3tddRestrict=false
...    LNBTS-1/LNMCE-0/MBSFNSYNCAREA_FDD-0:mbsfnChBw=10 MHz
...    LNBTS-1/CATMPR-1:catMVoLTETab:qci1ProtectionTimerCatM=80
...    LNCEL-2/CATMCEL-0:acbPlmnNumStepsCatM=0
...    delete:LNCEL-2/CATMCEL-0:threshServingLowQR9CatM

@{IFGDPR_parameter}
...    LNCEL-1/IFGDPR-0:algSelection=fixed order within the group
...    LNCEL-1/IFGDPR-0:groupSize=16
...    LNCEL-2/IFGDPR-0:algSelection=fixed order within the group
...    LNCEL-2/IFGDPR-0:groupSize=16

@{CatM_Cell2_parameter}
...    LNCEL-2/CATMCEL-0:a2TimeToTriggerCatM=480ms
...    LNCEL-2/CATMCEL-0:actAcBarringCatM=false
...    LNCEL-2/CATMCEL-0:actAmcCatM=disabled
...    LNCEL-2/CATMCEL-0:actCatMSpecMeas=false
...    LNCEL-2/CATMCEL-0:actConvVoiceCatM=false
...    LNCEL-2/CATMCEL-0:actDlPciBasedNarBandCatM=false
...    LNCEL-2/CATMCEL-0:actDrxCatM=false
...    LNCEL-2/CATMCEL-0:actDynamicRepMpdcchCatM=false
...    LNCEL-2/CATMCEL-0:actDynamicRepMpdschCatM=false
...    LNCEL-2/CATMCEL-0:actDynamicRepMpuschCatM=false
...    LNCEL-2/CATMCEL-0:actDynamicRepVoLTECatM=false
...    LNCEL-2/CATMCEL-0:actEDrxIdleCatM=false
...    LNCEL-2/CATMCEL-0:actHARQBundlingCatM=false
...    LNCEL-2/CATMCEL-0:actHighHarqCatM=disabled
...    LNCEL-2/CATMCEL-0:actIMSEmerSessCatM=false
...    LNCEL-2/CATMCEL-0:actIdleLBCatM=false
...    LNCEL-2/CATMCEL-0:actInterFreqHoCatM=enabled
...    LNCEL-2/CATMCEL-0:actIntraFreqHoCatM=true
...    LNCEL-2/CATMCEL-0:actLoadbasedNBSelectionCatM=false
...    LNCEL-2/CATMCEL-0:actMultiHarqCatM=false
...    LNCEL-2/CATMCEL-0:actPuschMaxTbsCatM=false
...    LNCEL-2/CATMCEL-0:actQci1CatMSpecMeas=false
...    LNCEL-2/CATMCEL-0:actRLFbasedRCRCatM=false
...    LNCEL-2/CATMCEL-0:actRaiCatM=false
...    LNCEL-2/CATMCEL-0:actSchedBypassCatM=disabled
...    LNCEL-2/CATMCEL-0:actSelMobPrfCatM=disabled
...    LNCEL-2/CATMCEL-0:actSf9InvalidLVRBCatM=true
...    LNCEL-2/CATMCEL-0:actUeDataInactivityCatM=false
...    LNCEL-2/CATMCEL-0:cellReSelPrioCatM=7
...    LNCEL-2/CATMCEL-0:dFpucchF1CatM=0
...    LNCEL-2/CATMCEL-0:deltaPreMsg3CatM=1
...    LNCEL-2/CATMCEL-0:dl3HarqMcsCatM=MCS12
...    LNCEL-2/CATMCEL-0:hysThreshold2CatM=2
...    LNCEL-2/CATMCEL-0:idleLBPercentageOfUesCatM=0
...    LNCEL-2/CATMCEL-0:immediateS1ReleaseCatM=true
...    LNCEL-2/CATMCEL-0:moProfileSelectCatM=spid
...    LNCEL-2/CATMCEL-0:numCELevelCatM=1
...    LNCEL-2/CATMCEL-0:numNarBandModeACatM=1
...    LNCEL-2/CATMCEL-0:p0NomPucchCatM=-104
...    LNCEL-2/CATMCEL-0:p0NomPuschCatM=-102
...    LNCEL-2/CATMCEL-0:prachPwrRampCatM=2
...    LNCEL-2/CATMCEL-0:prachRsrpThr1CatM=-140
...    LNCEL-2/CATMCEL-0:prachRsrpThr2CatM=-140
...    LNCEL-2/CATMCEL-0:prachRsrpThrCatM=-140
...    LNCEL-2/CATMCEL-0:qRxLevMinCe1CatM=-156
...    LNCEL-2/CATMCEL-0:qRxLevMinCeCatM=-136
...    LNCEL-2/CATMCEL-0:qRxLevMinIntraFCatM=-140
...    LNCEL-2/CATMCEL-0:qRxLevMinIntraFCe1CatM=-156
...    LNCEL-2/CATMCEL-0:siNarBandSelectionCatM=ModeA
...    LNCEL-2/CATMCEL-0:startingCovLevelPagingOptCatM=Coverage Level 0
...    LNCEL-2/CATMCEL-0:tReselEutrCatM=1
...    LNCEL-2/CATMCEL-0:threshSrvLowCatM=4
...    LNCEL-2/CATMCEL-0:threshold2CatM=42
...    LNCEL-2/CATMCEL-0:ulpcAlphaCatM=alpha 1
...    LNCEL-2/CATMCEL-0:ulpcIniPrePwrCatM=-104
...    LNCEL-2/CATMCEL-0:ulpcRarespTpcCatM=4
...    LNCEL-2/LNCEL_FDD-0/APUCCH_FDD-0:selectPrachRegion=InnerLowerEdge
...    LNCEL-2/LNCEL_FDD-0:catMProfId=1
...    LNCEL-2/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNCEL-2/SIB-0:siWindowLen=20ms
...    LNCEL-2/LNCEL_FDD-0:actCatM=true
...    CATMODPR-0:autoAdaptCatM=enabled
...    CATMPR-1:inactivityTimerCatM=60

@{LNHOIF_parameter_Aa_02}
...    LNCEL-1/LNHOIF-1:eutraCarrierInfo=300
...    LNCEL-1/LNHOIF-1:iFPrio=2
...    LNCEL-1/LNHOIF-1:eventMeasPrio:prioA3RSRP=1
...    LNCEL-1/LNHOIF-1:eventMeasPrio:prioA3RSRQ=1
...    LNCEL-1/LNHOIF-1:eventMeasPrio:prioA5=1
...    LNCEL-1/LNHOIF-2:eutraCarrierInfo=900
...    LNCEL-1/LNHOIF-2:iFPrio=4
...    LNCEL-1/LNHOIF-2:eventMeasPrio:prioA3RSRP=1
...    LNCEL-1/LNHOIF-2:eventMeasPrio:prioA3RSRQ=1
...    LNCEL-1/LNHOIF-2:eventMeasPrio:prioA5=1
...    LNCEL-1/LNHOIF-3:eutraCarrierInfo=1500
...    LNCEL-1/LNHOIF-3:iFPrio=3
...    LNCEL-1/LNHOIF-3:eventMeasPrio:prioA3RSRP=1
...    LNCEL-1/LNHOIF-3:eventMeasPrio:prioA3RSRQ=1
...    LNCEL-1/LNHOIF-3:eventMeasPrio:prioA5=1
...    LNCEL-1/LNHOIF-4:eutraCarrierInfo=2525
...    LNCEL-1/LNHOIF-4:iFPrio=7
...    LNCEL-1/LNHOIF-4:eventMeasPrio:prioA3RSRP=1
...    LNCEL-1/LNHOIF-4:eventMeasPrio:prioA3RSRQ=1
...    LNCEL-1/LNHOIF-4:eventMeasPrio:prioA5=1
...    LNCEL-1/LNHOIF-5:eutraCarrierInfo=2700
...    LNCEL-1/LNHOIF-5:iFPrio=9
...    LNCEL-1/LNHOIF-5:eventMeasPrio:prioA3RSRP=1
...    LNCEL-1/LNHOIF-5:eventMeasPrio:prioA3RSRQ=1
...    LNCEL-1/LNHOIF-5:eventMeasPrio:prioA5=1
...    LNCEL-1/LNHOIF-6:eutraCarrierInfo=3000
...    LNCEL-1/LNHOIF-6:iFPrio=1
...    LNCEL-1/LNHOIF-6:eventMeasPrio:prioA3RSRP=1
...    LNCEL-1/LNHOIF-6:eventMeasPrio:prioA3RSRQ=1
...    LNCEL-1/LNHOIF-6:eventMeasPrio:prioA5=1
...    LNCEL-1/LNHOIF-7:eutraCarrierInfo=3600
...    LNCEL-1/LNHOIF-7:iFPrio=5
...    LNCEL-1/LNHOIF-7:eventMeasPrio:prioA3RSRP=1
...    LNCEL-1/LNHOIF-7:eventMeasPrio:prioA3RSRQ=1
...    LNCEL-1/LNHOIF-7:eventMeasPrio:prioA5=1
...    LNCEL-1/LNHOIF-8:eutraCarrierInfo=4000
...    LNCEL-1/LNHOIF-8:iFPrio=8
...    LNCEL-1/LNHOIF-8:eventMeasPrio:prioA3RSRP=1
...    LNCEL-1/LNHOIF-8:eventMeasPrio:prioA3RSRQ=1
...    LNCEL-1/LNHOIF-8:eventMeasPrio:prioA5=1
...    LNCEL-1/LNHOIF-9:eutraCarrierInfo=4500
...    LNCEL-1/LNHOIF-9:iFPrio=6
...    LNCEL-1/LNHOIF-9:eventMeasPrio:prioA3RSRP=1
...    LNCEL-1/LNHOIF-9:eventMeasPrio:prioA3RSRQ=1
...    LNCEL-1/LNHOIF-9:eventMeasPrio:prioA5=1
...    LNCEL-1/LNHOIF-10:eutraCarrierInfo=4600
...    LNCEL-1/LNHOIF-10:iFPrio=12
...    LNCEL-1/LNHOIF-10:eventMeasPrio:prioA3RSRP=1
...    LNCEL-1/LNHOIF-10:eventMeasPrio:prioA3RSRQ=1
...    LNCEL-1/LNHOIF-10:eventMeasPrio:prioA5=1
...    LNCEL-1/LNHOIF-11:eutraCarrierInfo=36000
...    LNCEL-1/LNHOIF-11:iFPrio=10
...    LNCEL-1/LNHOIF-11:eventMeasPrio:prioA3RSRP=1
...    LNCEL-1/LNHOIF-11:eventMeasPrio:prioA3RSRQ=1
...    LNCEL-1/LNHOIF-11:eventMeasPrio:prioA5=1
...    LNCEL-1/LNHOIF-12:eutraCarrierInfo=36200
...    LNCEL-1/LNHOIF-12:iFPrio=13
...    LNCEL-1/LNHOIF-12:eventMeasPrio:prioA3RSRP=1
...    LNCEL-1/LNHOIF-12:eventMeasPrio:prioA3RSRQ=1
...    LNCEL-1/LNHOIF-12:eventMeasPrio:prioA5=1
...    LNCEL-1/LNHOIF-13:eutraCarrierInfo=36350
...    LNCEL-1/LNHOIF-13:iFPrio=14
...    LNCEL-1/LNHOIF-13:eventMeasPrio:prioA3RSRP=1
...    LNCEL-1/LNHOIF-13:eventMeasPrio:prioA3RSRQ=1
...    LNCEL-1/LNHOIF-13:eventMeasPrio:prioA5=1
...    LNCEL-1/LNHOIF-14:eutraCarrierInfo=36950
...    LNCEL-1/LNHOIF-14:iFPrio=15
...    LNCEL-1/LNHOIF-14:eventMeasPrio:prioA3RSRP=1
...    LNCEL-1/LNHOIF-14:eventMeasPrio:prioA3RSRQ=1
...    LNCEL-1/LNHOIF-14:eventMeasPrio:prioA5=1
...    LNCEL-1/LNHOIF-15:eutraCarrierInfo=37550
...    LNCEL-1/LNHOIF-15:iFPrio=16
...    LNCEL-1/LNHOIF-15:eventMeasPrio:prioA3RSRP=1
...    LNCEL-1/LNHOIF-15:eventMeasPrio:prioA3RSRQ=1
...    LNCEL-1/LNHOIF-15:eventMeasPrio:prioA5=1
...    LNCEL-1/LNHOIF-16:eutraCarrierInfo=37750
...    LNCEL-1/LNHOIF-16:iFPrio=11
...    LNCEL-1/LNHOIF-16:eventMeasPrio:prioA3RSRP=1
...    LNCEL-1/LNHOIF-16:eventMeasPrio:prioA3RSRQ=1
...    LNCEL-1/LNHOIF-16:eventMeasPrio:prioA5=1
...    LNCEL-1/LNHOIF-1:iFGroupPrio=12
...    LNCEL-1/LNHOIF-1:measQuantInterFreq=both
...    LNCEL-1/LNHOIF-2:iFGroupPrio=12
...    LNCEL-1/LNHOIF-2:measQuantInterFreq=both
...    LNCEL-1/LNHOIF-3:iFGroupPrio=12
...    LNCEL-1/LNHOIF-3:measQuantInterFreq=both
...    LNCEL-1/LNHOIF-4:iFGroupPrio=12
...    LNCEL-1/LNHOIF-4:measQuantInterFreq=both
...    LNCEL-1/LNHOIF-5:iFGroupPrio=12
...    LNCEL-1/LNHOIF-5:measQuantInterFreq=both
...    LNCEL-1/LNHOIF-6:iFGroupPrio=12
...    LNCEL-1/LNHOIF-6:measQuantInterFreq=both
...    LNCEL-1/LNHOIF-7:iFGroupPrio=12
...    LNCEL-1/LNHOIF-7:measQuantInterFreq=both
...    LNCEL-1/LNHOIF-8:iFGroupPrio=12
...    LNCEL-1/LNHOIF-8:measQuantInterFreq=both
...    LNCEL-1/LNHOIF-9:iFGroupPrio=12
...    LNCEL-1/LNHOIF-9:measQuantInterFreq=both
...    LNCEL-1/LNHOIF-10:iFGroupPrio=12
...    LNCEL-1/LNHOIF-10:measQuantInterFreq=both
...    LNCEL-1/LNHOIF-11:iFGroupPrio=12
...    LNCEL-1/LNHOIF-11:measQuantInterFreq=both
...    LNCEL-1/LNHOIF-12:iFGroupPrio=12
...    LNCEL-1/LNHOIF-12:measQuantInterFreq=both
...    LNCEL-1/LNHOIF-13:iFGroupPrio=12
...    LNCEL-1/LNHOIF-13:measQuantInterFreq=both
...    LNCEL-1/LNHOIF-14:iFGroupPrio=12
...    LNCEL-1/LNHOIF-14:measQuantInterFreq=both
...    LNCEL-1/LNHOIF-15:iFGroupPrio=1
...    LNCEL-1/LNHOIF-15:measQuantInterFreq=both
...    LNCEL-1/LNHOIF-16:iFGroupPrio=1
...    LNCEL-1/LNHOIF-16:measQuantInterFreq=both
...    LNCEL-1:maxNumIFCarrMeas=8
...    LNCEL-1/IFGPR-1:groupSize=12
...    LNCEL-1/IFGPR-1:groupPrio=1
...    LNCEL-1/IFGPR-1:algSelection=fixed order within the group

${Ue_Capabilities_Aa_02_04_07}  SEPARATOR=
...    918001E0008206102860E2048A163069022489A74C95223448501F3A7870F0000DFFFBFED1DF00443214C74254B6360E12161A2629CF808182
...    87888B8C8D8E8F280110C8531D0952A00210620A30E41251661A71E822926A2A5400420C41461C824A2CC34E3D04524D4540

${attach_msg_rrcConnRec}
...    measConfig contains (
...      measObjectToAddModList contains (
...        measObjectEUTRA contains (carrierFreq eq 1400)
...      )and
...      reportConfigToAddModList contains (
...        eventA3 contains (a3-Offset eq 4),
...        eventA5 contains (a5-Threshold1 contains (threshold-RSRP eq 45)),
...        eventA2 contains (a2-Threshold contains (threshold-RSRP eq 52))
...      )
...    )

${trigger_A2_event}
...    measConfig contains (
...      measObjectToAddModList contains (
...        measObjectEUTRA contains (carrierFreq eq 37750),
...        measObjectEUTRA contains (carrierFreq eq 37550),
...        measObjectEUTRA contains (carrierFreq eq 3000),
...        measObjectEUTRA contains (carrierFreq eq 300),
...        measObjectEUTRA contains (carrierFreq eq 1500),
...        measObjectEUTRA contains (carrierFreq eq 900),
...        measObjectEUTRA contains (carrierFreq eq 3600),
...        measObjectEUTRA contains (carrierFreq eq 4500)
...      )and
...      reportConfigToAddModList contains (
...        eventA1 contains (a1-Threshold contains (threshold-RSRP eq 67)),
...        eventA3 contains (a3-Offset eq 6),
...        eventA3 contains (a3-Offset eq 0),
...        eventA5 contains (a5-Threshold1 contains (threshold-RSRP eq 24))
...      )and
...      measIdToAddModList contains (
...        (measId eq 5 and measObjectId eq 1 and reportConfigId eq 4),
...        (measId eq 3 and measObjectId eq 2 and reportConfigId eq 5),
...        (measId eq 4 and measObjectId eq 2 and reportConfigId eq 6),
...        (measId eq 6 and measObjectId eq 2 and reportConfigId eq 7),
...        (measId eq 7 and measObjectId eq 3 and reportConfigId eq 5),
...        (measId eq 8 and measObjectId eq 3 and reportConfigId eq 6),
...        (measId eq 9 and measObjectId eq 3 and reportConfigId eq 7),
...        (measId eq 10 and measObjectId eq 4 and reportConfigId eq 5),
...        (measId eq 11 and measObjectId eq 4 and reportConfigId eq 6),
...        (measId eq 12 and measObjectId eq 4 and reportConfigId eq 7),
...        (measId eq 13 and measObjectId eq 5 and reportConfigId eq 5),
...        (measId eq 14 and measObjectId eq 5 and reportConfigId eq 6),
...        (measId eq 15 and measObjectId eq 5 and reportConfigId eq 7),
...        (measId eq 16 and measObjectId eq 6 and reportConfigId eq 5),
...        (measId eq 17 and measObjectId eq 6 and reportConfigId eq 6),
...        (measId eq 18 and measObjectId eq 6 and reportConfigId eq 7),
...        (measId eq 19 and measObjectId eq 7 and reportConfigId eq 5),
...        (measId eq 20 and measObjectId eq 7 and reportConfigId eq 6),
...        (measId eq 21 and measObjectId eq 7 and reportConfigId eq 7),
...        (measId eq 22 and measObjectId eq 8 and reportConfigId eq 5),
...        (measId eq 23 and measObjectId eq 8 and reportConfigId eq 6),
...        (measId eq 24 and measObjectId eq 8 and reportConfigId eq 7),
...        (measId eq 25 and measObjectId eq 9 and reportConfigId eq 5),
...        (measId eq 26 and measObjectId eq 9 and reportConfigId eq 6),
...        (measId eq 27 and measObjectId eq 9 and reportConfigId eq 7)
...      )
...    )

*** Test Cases ***
LTE4259_A_a_ET_02_Extended_Amount_Of_Inter_Frequency_Carriers_For_A3A5_With_MaxNumIFCarrMeas_With_2_Priority_Group
    [Tags]    CDRT    RAN_4G    RAN_4G_FDD
    Online Parameter Adding LNHOIF
    UE Attach To Cell1
    Trigger A2 Event

*** Keywords ***
Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs_FDD
    Create UE Alias    UE_1    ue_id=1    id_type=cus
    Create Enb Alias    ENB_1    enb_id=1    id_type=wts
    Create MME Alias    alias=MME_1    mme_id=1    id_type=wts


Online Parameter Adding LNHOIF
    Delta Commission Parameters    ${LNHOIF_parameter_Aa_02}
    Cells Should Be OnAir

UE Attach To Cell1
    [Arguments]    ${ue_id}=1
    Expect Message Flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (${attach_msg_rrcConnRec})
    ...    alias=UE_attach_A3A5A2    overall_timeout=20
    Execute Uex Command    ue_attach id=${ue_id} cell=1 ue_eutra_capabilities=${Ue_Capabilities_Aa_02_04_07}
    Flow Occurred As Expected    alias=UE_attach_A3A5A2

Trigger A2 Event
    [Arguments]    ${ue_id}=1
    Expect Message Flow
    ...    UE_${ue_id}:RRC_MeasurementReport (measId eq 7)
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (${trigger_A2_event})
    ...    alias=UE_attach_A3A5A2    overall_timeout=20
    Expect Message Will Not Occur
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (measObjectToAddModList contains (measObjectId eq 10))
    ...    alias=A2_no_measObjId10_flow    overall_timeout=20
    Execute Uex Command    ue_measurement_send id=${ue_id} event=A2 srsrp=24 srsrq=34
    Flow Occurred As Expected    alias=UE_attach_A3A5A2
    Flow Not Occurred For Message    alias=A2_no_measObjId10_flow