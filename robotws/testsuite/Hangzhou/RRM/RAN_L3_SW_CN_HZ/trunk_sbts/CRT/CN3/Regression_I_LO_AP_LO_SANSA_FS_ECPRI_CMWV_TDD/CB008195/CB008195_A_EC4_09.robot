*** Settings ***
Documentation
...    author: kang.xiang
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_VRF    SBTS00    RAN_5G    RAN_5G_TDD    CLOUD_5G_I_LO_AP_LO    team-VRF3_SG8    owner-lola.ren
...    release-SBTS25R1    CRT
Resource    ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{CB008195}
...    @{SNSSAI}
...    @{NRRESOURCEGROUP_PROFILE}
...    @{TAC}
...    @{intra_HO}
...    @{CB008225}
...    @{rrcReestabTypeSA}
...    @{CB008195_resource_params}
@{rrcReestabTypeSA}
...    NRBTS-1:rrcReestabTypeSA=sameGNB
@{CB008195}
...    NRBTS:actSliceAwareAdmissionCtrl=true
...    NRCELL-1:sliceAwareAdmissionCtrlEnabled=true
...    NRCELL-1:nrResourceGroupProfileRacDN=NRRESOURCEGROUP_PROFILE-1
...    NRCELL-2:sliceAwareAdmissionCtrlEnabled=true
...    NRCELL-2:nrResourceGroupProfileRacDN=NRRESOURCEGROUP_PROFILE-2
...    NRCELL-3:sliceAwareAdmissionCtrlEnabled=true
...    NRCELL-3:nrResourceGroupProfileRacDN=NRRESOURCEGROUP_PROFILE-1
...    NRBTS:actAdditionalSliceSupport=true
...    NRBTS/NRPMRNL-1:miNrCellUtilPerNrg=5min
...    NRCELL:cellDepType=SA
...    delete:NRCELL:configuredEpsTac

@{NRRESOURCEGROUP_PROFILE}
...    NRBTS/NRRESOURCEGROUP_PROFILE-1:defaultRgNsaList:nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS/NRRESOURCEGROUP_PROFILE-1:defaultRgNsaList:nrResourceGroupId=1
...    NRBTS/NRRESOURCEGROUP_PROFILE-1:defaultRgSaList:nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS/NRRESOURCEGROUP_PROFILE-1:defaultRgSaList:nrResourceGroupId=1

...    NRBTS/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-1:nrResourceList:resourceDN=SNSSAI-1
...    NRBTS/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-1:racParams:minQuota=60
...    NRBTS/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-1:racParams:maxQuota=60

...    NRBTS/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-2:nrResourceList:resourceDN=SNSSAI-2
...    NRBTS/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-2:racParams:minQuota=0
...    NRBTS/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-2:racParams:maxQuota=10

...    NRBTS/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-3:nrResourceList:resourceDN=SNSSAI-3
...    NRBTS/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-3:racParams:minQuota=20
...    NRBTS/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-3:racParams:maxQuota=40

...    NRBTS/NRRESOURCEGROUP_PROFILE-2:defaultRgNsaList:nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS/NRRESOURCEGROUP_PROFILE-2:defaultRgNsaList:nrResourceGroupId=1
...    NRBTS/NRRESOURCEGROUP_PROFILE-2:defaultRgSaList:nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS/NRRESOURCEGROUP_PROFILE-2:defaultRgSaList:nrResourceGroupId=1

...    NRBTS/NRRESOURCEGROUP_PROFILE-2/NRRESOURCEGROUP-1:nrResourceList:resourceDN=SNSSAI-4
...    NRBTS/NRRESOURCEGROUP_PROFILE-2/NRRESOURCEGROUP-1:racParams:minQuota=30
...    NRBTS/NRRESOURCEGROUP_PROFILE-2/NRRESOURCEGROUP-1:racParams:maxQuota=40

...    NRBTS:rgMinQuotaReservationLevel=cell_and_multicell_level
...    NRBTS/NRRESOURCEGROUP_PROFILE-1:bypassRgLimits=0
...    NRBTS/NRRESOURCEGROUP_PROFILE-2:bypassRgLimits=0

@{SNSSAI}
...    NRBTS/SNSSAI-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS/SNSSAI-1:drbInactivityTimerSA=10
...    NRBTS/SNSSAI-1:sd=13714341
...    NRBTS/SNSSAI-2:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS/SNSSAI-2:drbInactivityTimerSA=10
...    NRBTS/SNSSAI-2:sd=13714342
...    NRBTS/SNSSAI-3:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS/SNSSAI-3:drbInactivityTimerSA=10
...    NRBTS/SNSSAI-3:sd=13714343
...    NRBTS/SNSSAI-4:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS/SNSSAI-4:drbInactivityTimerSA=10
...    NRBTS/SNSSAI-4:sd=13714344
...    NRBTS:actAdditionalSliceSupport=true
@{TAC}
...    NRBTS/TRACKINGAREA-200:fiveGsTac=200
...    NRBTS/TRACKINGAREA-200:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1
...    NRBTS/TRACKINGAREA-200:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2
...    NRBTS/TRACKINGAREA-200:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-3|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-3
...    NRBTS/TRACKINGAREA-200:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-4|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-4
@{CB008225}
...    NRBTS:actRrcInactState=intra-gNB
...    NRBTS:act3gppBL23R1=true
...    NRCELL:ranAC=0
...    NRBTS:srbInactivityTimerSA=600
...    NRBTS:drbRrcInactInactivityTimerSA=30
...    NRBTS:maxUeRrcInactTime=2         # ue will release after UE in inactive timeout
...    NRBTS:drbInactivityTimerSA=60
...    NRBTS:rrcInactIMMSteeringEnabled=false
...    NRBTS:rrcInactLocationReportEnabled=false
...    NRBTS:rrcInactPreferredStateEnabled=true
...    NRBTS:actRrcReleasePreference=true
...    NRBTS:outOfConnectedPreference=inactive
...    NRBTS:timerReleasePreferenceProhibit=s5
...    NRBTS:tRanPagingGuard=4
...    NRBTS:t380=10min
...    NRBTS:actPaging=true
...    NRBTS:ranPagingCycle=v32
...    NRBTS:activityNotificationLevelSA=ue
@{intra_HO}
...    NRBTS:actIntraFreqHoSA=true
...    NRPMRNL-1:miNrRelReportCu=5min
...    NRCELL:a3MeasEnabled=rsrp
...    NRCELL:sMeasConfigSsbRsrp=80
...    NRCELL:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0|a3OffsetSsbRsrp=30|a3TimeToTriggerSsbRsrp=ms64
...    NRCELL:a3MeasSsbRsrq:a3HysteresisSsbRsrq=0|a3OffsetSsbRsrq=20|a3TimeToTriggerSsbRsrq=ms64


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

@{CB008195_resource_params}
#@{CB008195_A_EC4_09}
...    NRCELL-2:numOfRadioResReservForTempUse=1
...    NRCELL-2:maxNumOfUsersPerNRCell=5
...    NRCELL-2:maxNumOfCaUsersNRCell=5
...    NRCELL-2:maxNumOfUsersPerCell=5
...    NRCELL-2:maxNumOfRrcSA=5
...    NRCELL-2:maxNumOfSCellAlloc=5
...    NRCELL-2:maxNumOfNrDcSnUsers=5
...    NRCELL-2:maxNumOfNonGBRBearersSA=20
...    NRBTS-1/NRCELLGRP-1:maxNumOfRrcCGRPSA=200
...    NRBTS-1/NRCELLGRP-1:maxNumOfNonGBRBearersCGRPSA=200
#@{CB008195_A_EC4_12}
...    NRCELL-1:numOfRadioResReservForTempUse=0
...    NRCELL-1:maxNumOfUsersPerNRCell=275
...    NRCELL-1:maxNumOfCaUsersNRCell=275
...    NRCELL-1:maxNumOfUsersPerCell=275
...    NRCELL-1:maxNumOfRrcSA=275
...    NRCELL-1:maxNumOfSCellAlloc=275
...    NRCELL-1:maxNumOfNrDcSnUsers=275
...    NRCELL-1:maxNumOfNonGBRBearersSA=550
...    NRBTS-1/NRCELLGRP-0:maxNumOfRrcCGRPSA=20
...    NRBTS-1/NRCELLGRP-0:maxNumOfNonGBRBearersCGRPSA=550
#@{CB008195_A_EC4_21}
...    NRDU-1:maxNumOfRrcConUEsPerDU=2448
...    NRCELL-3:numOfRadioResReservForTempUse=0
...    NRCELL-3:maxNumOfUsersPerNRCell=275
...    NRCELL-3:maxNumOfCaUsersNRCell=250
...    NRCELL-3:maxNumOfUsersPerCell=275
...    NRCELL-3:maxNumOfRrcSA=275
...    NRCELL-3:maxNumOfSCellAlloc=275
...    NRCELL-3:maxNumOfNrDcSnUsers=275
...    NRCELL-3:maxNumOfNonGBRBearersSA=8
...    NRBTS-1/NRCELLGRP-2:maxNumOfRrcCGRPSA=275
...    NRBTS-1/NRCELLGRP-2:maxNumOfNonGBRBearersCGRPSA=5

${NG_FLOW_SETUP_FAIL_RRNA}    M55125C10501
${NRD_RRC_STPREQ_PER_CELL_REJ_CU}    M55113C03001
${NRRRC_RRC_REJECT_DU_TRIGG_RECD}    M55124C01011
${NRRCC_RRC_STPREJ_MO_DATA}    M55124C01022
${NRD_RRC_RESUME_REQUEST1_REJECT}    M55166C00509

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

@{PM_Counters_case09}
...    NRCELL-2:NNGCC:${NG_FLOW_SETUP_FAIL_RRNA}=1
...    NRCELL-2:NF1CC:${NRD_RRC_STPREQ_PER_CELL_REJ_CU}=0
...    NRCELL-2:NRRCC:${NRRRC_RRC_REJECT_DU_TRIGG_RECD}=0
...    NRCELL-2:NRRCC:${NRRCC_RRC_STPREJ_MO_DATA}=0
...    NRCELL-2:NRCCD:${NRD_RRC_RESUME_REQUEST1_REJECT}=0
#@{RD_Counters_case09}
...    NRCELL-2/NRRESOURCEGROUP-1:${AVG_NUM_UE_NOM_NRG}>0
...    NRCELL-2/NRRESOURCEGROUP-1:${DNOM_SAMPLES_NRG}>0
...    NRCELL-2/NRRESOURCEGROUP-1:${AVE_NUM_NGBR_NOM_NRG}>0
...    NRCELL-2/NRRESOURCEGROUP-1:${PEAK_NUM_UE_NRG}=2
...    NRCELL-2/NRRESOURCEGROUP-1:${PEAK_NUM_NGBR_NRG}=2
...    NRCELL-2/NRRESOURCEGROUP-1:${NUM_ADM_REQ_NGBR_NRG}=5
...    NRCELL-2/NRRESOURCEGROUP-1:${NUM_ADM_SUC_NGBR_NRG}=2
...    NRCELL-2/NRRESOURCEGROUP-1:${NUM_ADM_REQ_UE_NRG}=5
...    NRCELL-2/NRRESOURCEGROUP-1:${NUM_ADM_SUC_UE_NRG}=2
...    NRCELL-2/NRRESOURCEGROUP-1:${RAC_REJ_DUE_DRB_MAX_QUOTA_NRG}=0
...    NRCELL-2/NRRESOURCEGROUP-1:${RAC_REJ_DUE_UE_MAX_QUOTA_NRG}=3
@{PM_Counters_case12}
...    NRCELL-1:NNGCC:${NG_FLOW_SETUP_FAIL_RRNA}=0
...    NRCELL-1:NF1CC:${NRD_RRC_STPREQ_PER_CELL_REJ_CU}=0
...    NRCELL-1:NRRCC:${NRRRC_RRC_REJECT_DU_TRIGG_RECD}=0
...    NRCELL-1:NRRCC:${NRRCC_RRC_STPREJ_MO_DATA}=0
...    NRCELL-1:NRCCD:${NRD_RRC_RESUME_REQUEST1_REJECT}=0
#@{RD_Counters_case12}
...    NRCELL-1/NRRESOURCEGROUP-1:${AVG_NUM_UE_NOM_NRG}=0
...    NRCELL-1/NRRESOURCEGROUP-1:${DNOM_SAMPLES_NRG}=300
...    NRCELL-1/NRRESOURCEGROUP-1:${AVE_NUM_NGBR_NOM_NRG}=0
...    NRCELL-1/NRRESOURCEGROUP-1:${PEAK_NUM_UE_NRG}=0
...    NRCELL-1/NRRESOURCEGROUP-1:${PEAK_NUM_NGBR_NRG}=0
...    NRCELL-1/NRRESOURCEGROUP-1:${NUM_ADM_REQ_NGBR_NRG}=0
...    NRCELL-1/NRRESOURCEGROUP-1:${NUM_ADM_SUC_NGBR_NRG}=0
...    NRCELL-1/NRRESOURCEGROUP-1:${NUM_ADM_REQ_UE_NRG}=0
...    NRCELL-1/NRRESOURCEGROUP-1:${NUM_ADM_SUC_UE_NRG}=0
...    NRCELL-1/NRRESOURCEGROUP-1:${RAC_REJ_DUE_DRB_MAX_QUOTA_NRG}=0
...    NRCELL-1/NRRESOURCEGROUP-1:${RAC_REJ_DUE_UE_MAX_QUOTA_NRG}=0

...    NRCELL-1/NRRESOURCEGROUP-2:${AVG_NUM_UE_NOM_NRG}>0
...    NRCELL-1/NRRESOURCEGROUP-2:${DNOM_SAMPLES_NRG}=300
...    NRCELL-1/NRRESOURCEGROUP-2:${AVE_NUM_NGBR_NOM_NRG}>0
...    NRCELL-1/NRRESOURCEGROUP-2:${PEAK_NUM_UE_NRG}=2
...    NRCELL-1/NRRESOURCEGROUP-2:${PEAK_NUM_NGBR_NRG}=2
...    NRCELL-1/NRRESOURCEGROUP-2:${NUM_ADM_REQ_NGBR_NRG}=3
...    NRCELL-1/NRRESOURCEGROUP-2:${NUM_ADM_SUC_NGBR_NRG}=2
...    NRCELL-1/NRRESOURCEGROUP-2:${NUM_ADM_REQ_UE_NRG}=3
...    NRCELL-1/NRRESOURCEGROUP-2:${NUM_ADM_SUC_UE_NRG}=2
...    NRCELL-1/NRRESOURCEGROUP-2:${RAC_REJ_DUE_DRB_MAX_QUOTA_NRG}=0
...    NRCELL-1/NRRESOURCEGROUP-2:${RAC_REJ_DUE_UE_MAX_QUOTA_NRG}=0

...    NRCELL-1/NRRESOURCEGROUP-3:${AVG_NUM_UE_NOM_NRG}>0
...    NRCELL-1/NRRESOURCEGROUP-3:${DNOM_SAMPLES_NRG}=300
...    NRCELL-1/NRRESOURCEGROUP-3:${AVE_NUM_NGBR_NOM_NRG}>0
...    NRCELL-1/NRRESOURCEGROUP-3:${PEAK_NUM_UE_NRG}=4
...    NRCELL-1/NRRESOURCEGROUP-3:${PEAK_NUM_NGBR_NRG}=5
...    NRCELL-1/NRRESOURCEGROUP-3:${NUM_ADM_REQ_NGBR_NRG}=5
...    NRCELL-1/NRRESOURCEGROUP-3:${NUM_ADM_SUC_NGBR_NRG}=5
...    NRCELL-1/NRRESOURCEGROUP-3:${NUM_ADM_REQ_UE_NRG}=4
...    NRCELL-1/NRRESOURCEGROUP-3:${NUM_ADM_SUC_UE_NRG}=4
...    NRCELL-1/NRRESOURCEGROUP-3:${RAC_REJ_DUE_DRB_MAX_QUOTA_NRG}=0
...    NRCELL-1/NRRESOURCEGROUP-3:${RAC_REJ_DUE_UE_MAX_QUOTA_NRG}=0

...    NRCELL-2/NRRESOURCEGROUP-1:${AVG_NUM_UE_NOM_NRG}>=4
...    NRCELL-2/NRRESOURCEGROUP-1:${DNOM_SAMPLES_NRG}=300
...    NRCELL-2/NRRESOURCEGROUP-1:${AVE_NUM_NGBR_NOM_NRG}>0
...    NRCELL-2/NRRESOURCEGROUP-1:${PEAK_NUM_UE_NRG}=1
...    NRCELL-2/NRRESOURCEGROUP-1:${PEAK_NUM_NGBR_NRG}=2
...    NRCELL-2/NRRESOURCEGROUP-1:${NUM_ADM_REQ_NGBR_NRG}=5
...    NRCELL-2/NRRESOURCEGROUP-1:${NUM_ADM_SUC_NGBR_NRG}=5
...    NRCELL-2/NRRESOURCEGROUP-1:${NUM_ADM_REQ_UE_NRG}=4
...    NRCELL-2/NRRESOURCEGROUP-1:${NUM_ADM_SUC_UE_NRG}=4
...    NRCELL-2/NRRESOURCEGROUP-1:${RAC_REJ_DUE_DRB_MAX_QUOTA_NRG}=0
...    NRCELL-2/NRRESOURCEGROUP-1:${RAC_REJ_DUE_UE_MAX_QUOTA_NRG}=0

@{PM_Counters_case21}
...    NRCELL-3:NNGCC:${NG_FLOW_SETUP_FAIL_RRNA}=1
...    NRCELL-3:NF1CC:${NRD_RRC_STPREQ_PER_CELL_REJ_CU}=0
...    NRCELL-3:NRRCC:${NRRRC_RRC_REJECT_DU_TRIGG_RECD}=0
...    NRCELL-3:NRRCC:${NRRCC_RRC_STPREJ_MO_DATA}=0
...    NRCELL-3:NRCCD:${NRD_RRC_RESUME_REQUEST1_REJECT}=0
#@{RD_Counters_case21}
...    NRCELL-3/NRRESOURCEGROUP-1:${AVG_NUM_UE_NOM_NRG}>0
...    NRCELL-3/NRRESOURCEGROUP-1:${DNOM_SAMPLES_NRG}>0
...    NRCELL-3/NRRESOURCEGROUP-1:${AVE_NUM_NGBR_NOM_NRG}>0
...    NRCELL-3/NRRESOURCEGROUP-1:${PEAK_NUM_UE_NRG}=2
...    NRCELL-3/NRRESOURCEGROUP-1:${PEAK_NUM_NGBR_NRG}=4
...    NRCELL-3/NRRESOURCEGROUP-1:${NUM_ADM_REQ_NGBR_NRG}=5
...    NRCELL-3/NRRESOURCEGROUP-1:${NUM_ADM_SUC_NGBR_NRG}=4
...    NRCELL-3/NRRESOURCEGROUP-1:${NUM_ADM_REQ_UE_NRG}=3
...    NRCELL-3/NRRESOURCEGROUP-1:${NUM_ADM_SUC_UE_NRG}=2
...    NRCELL-3/NRRESOURCEGROUP-1:${RAC_REJ_DUE_DRB_MAX_QUOTA_NRG}=0
...    NRCELL-3/NRRESOURCEGROUP-1:${RAC_REJ_DUE_UE_MAX_QUOTA_NRG}=0

*** Test Cases ***
CB008195-A-EC4_ET_09_01_SA UE context admission static cell limits check failure for re-established UE
    [Documentation]
    ...    this case will trigger UE reestablish fail due to cell level uecontext resource unavailable.
    ...    two kind of reestablish: reestablish from other cell and reestablish from own cell.
    ...    note that old context is released after reestablish succeessfully.
    ...    for cell2: maxNumOfRrcSA=5, numOfRadioResReservForTempUse=1.
    ...    RG profile2: [30-40]
    ...    so RG1 dedicated=rounddown(5*30%)=1, max = roundown (5*40%)=2
    ...    max rrc is 2+1=3, but max ue context is 2.
    ...    dynamic level resources are enough
    [Tags]    case09
    Clear Counter files
    UE1_2_3 use all rrc in cell2 RG1
    UE1_2_3 PDU session setup but one UE will fail
    UE4 reestablish from other cell fail
    UE1 reestablish to own cell fail
    Check Counters    pm_counters_expression=${PM_Counters_case09}
    Release Ues    ue_type=all

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/3cells_ecpri    ue_count=9
    Execute Egate Command    trace_sim protocol=xn uec=1 amf=1 enb=3 on
    Execute Egate Command    link_lock link=x2 at=enb:1 to=gnb:2    #locked

Modify Cfg
    Set PDU Session in WTS
    Set AMF config
    Set UE config

Set AMF config
    Update Cfg    set_amf_region id=1 tac_list=100,200,300 plmn=311:489
    Update Cfg    amf_param id=1 full_nas_auth=on nia=null+zuc nea=null+zuc ims_voice_3gpp=on
    Update Cfg    set_amf id=1 daemon=10.0.2.1:22222 ng=10.0.1.1:38412 region=1 set_id=2 pointer=2 name=SimModeAMF1
    Update Cfg    amf_ng_setup_param id=1 relative_capacity=10 include_backup_amf_name=on ue_retention=on retention_time=indefinite
    Update Cfg    set_nwslice id=1 snssai=0x01:0xd143a5 amf=1 default=off qos_flows=9,8,7,6,5,4,3,2,1 qos_rules=1,2 ue=all
    Update Cfg    set_nwslice id=2 snssai=0x01:0xd143a6 amf=1 default=on qos_flows=9,8,7,6,5,4,3,2,1 qos_rules=1,2 ue=all
    Update Cfg    set_nwslice id=3 snssai=0x01:0xd143a7 amf=1 default=off qos_flows=9,8,7,6,5,4,3,2,1 qos_rules=1,2 ue=all
    Update Cfg    set_nwslice id=4 snssai=0x01:0xd143a8 amf=1 default=off qos_flows=9,7,6,4,3,2,1 qos_rules=1,2 ue=all

Set PDU Session in WTS
    Update Cfg    set_qosflow id=1 5qi=1 priority=1 pci=may_trigger_pre_emption pvi=pre_emptable
    Update Cfg    set_qosflow id=2 5qi=2 priority=2 pci=may_trigger_pre_emption pvi=pre_emptable
    Update Cfg    set_qosflow id=3 5qi=3 priority=3 pci=may_trigger_pre_emption pvi=pre_emptable
    Update Cfg    set_qosflow id=4 5qi=4 priority=4 pci=shall_not_trigger_pre_emption pvi=not_pre_emptable
    Update Cfg    set_qosflow id=5 5qi=5 priority=5 pci=may_trigger_pre_emption pvi=pre_emptable
    Update Cfg    set_qosflow id=6 5qi=6 priority=6 pci=may_trigger_pre_emption pvi=pre_emptable
    Update Cfg    set_qosflow id=7 5qi=7 default=on priority=7 pci=shall_not_trigger_pre_emption pvi=pre_emptable
    Update Cfg    set_qosflow id=8 5qi=8 priority=8 pci=may_trigger_pre_emption pvi=pre_emptable
    Update Cfg    set_qosflow id=9 5qi=9 priority=9 pci=may_trigger_pre_emption pvi=not_pre_emptable
    Update Cfg    qosrule_set id=1 proto=tcp qos_flow=1
    Update Cfg    qosrule_set id=2 proto=udp qos_flow=2

Set UE config
    Update Cfg    ue_nr_capabilities id=1-9 voice_over_nr=on:on:off
    Update Cfg    ue_param id=1-9 nr_usage_setting=voice_centric ue_nr_capabilities=${ue_nr_capabilities}

UE Register To GNB
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_register id=${ue_id} ue_nr_capabilities=${ue_nr_capabilities}    pass_regexp=UE now in NG RM Regist

UE1_2_3 use all rrc in cell2 RG1
    Execute Egate Command    ue_change_location id=1-3 enb=2 cell=2
    UE Register To GNB    ue_id=1
    UE Register To GNB    ue_id=2
    UE Register To GNB    ue_id=3

UE1_2_3 PDU session setup but one UE will fail
    Execute Egate Command    ue_pdu_session_setup ue=1 pdu=1 nwslice=1 gw=1    QoS Routing Table
    Execute Egate Command    ue_pdu_session_setup ue=2 pdu=1 nwslice=2 gw=2    QoS Routing Table
    Execute Egate Command    ue_pdu_session_setup ue=3 pdu=1 nwslice=4 gw=3    radioNetwork : radio-resources-not-available

UE4 reestablish from other cell fail
    Execute Egate Command    ue_change_location id=4 enb=2 cell=1
    UE Register To GNB    ue_id=4
    Execute Egate Command    ue_pdu_session_setup ue=4 pdu=1 nwslice=4 gw=4    QoS Routing Table
    Execute Egate Command    ue_rrc_reestablish id=4 gnb=2 cell=2    Received UE Context Release Complete

UE1 reestablish to own cell fail
    Execute Egate Command    ue_rrc_reestablish id=1 gnb=2 cell=2    Received UE Context Release Complete

UE1 use 1 uecontext in cell1 RG2 on cell group level
    Execute Egate Command    ue_change_location id=1 enb=2 cell=1
    UE Register To GNB    ue_id=1
    Execute Egate Command    ue_pdu_session_setup ue=1 pdu=1 nwslice=2 gw=1    QoS Routing Table

UE2_3 use 2 uecontext in cell1 RG3
    Execute Egate Command    ue_change_location id=2,3 enb=2 cell=1
    UE Register To GNB    ue_id=2
    Execute Egate Command    ue_pdu_session_setup ue=2 pdu=1 nwslice=3 gw=2    QoS Routing Table
    UE Register To GNB    ue_id=3
    Execute Egate Command    ue_pdu_session_setup ue=3 pdu=1 nwslice=3 gw=3    QoS Routing Table

UE4 use 1 uecontext in cell1 RG3 through reestablish
    Execute Egate Command    ue_change_location id=4 enb=2 cell=2
    UE Register To GNB    ue_id=4
    Execute Egate Command    ue_pdu_session_setup ue=4 pdu=1 nwslice=3 gw=4    QoS Routing Table
    sleep    1s    #to make counter value stable
    Execute Egate Command    ue_rrc_reestablish id=4 gnb=2 cell=1    rrcReconfigurationComplete
    sleep    1s    #to make counter value stable

UE5 use 1 uecontext in cell1 RG2 and 1 uecontext in cell1 RG3 through reestablish
    Execute Egate Command    ue_change_location id=5 enb=2 cell=2
    UE Register To GNB    ue_id=5
    Execute Egate Command    ue_pdu_session_setup ue=5 pdu=1 nwslice=2 gw=5    QoS Routing Table
    sleep    1s    #to make counter 'PEAK_NUM_NGBR_NRG' value stable
    Execute Egate Command    ue_pdu_session_setup ue=5 pdu=2 nwslice=3 gw=8    QoS Routing Table
    sleep    1s    #to make counter value stable
    Execute Egate Command    ue_rrc_reestablish id=5 gnb=2 cell=1    rrcReconfigurationComplete
    sleep    1s    #to make counter value stable

UE6 reestablish fail with RG2 uecontext due to SA UE context admission dynamic cell limits check failure
    Execute Egate Command    ue_change_location id=6 enb=2 cell=2
    UE Register To GNB    ue_id=6
    Execute Egate Command    ue_pdu_session_setup ue=6 pdu=1 nwslice=2 gw=6    QoS Routing Table
    sleep    1s    #to make counter value stable
    Execute Egate Command    ue_rrc_reestablish id=6 gnb=2 cell=1    UE6: IS IDLE
    sleep    1s    #to make counter value stable

UE7 reestablish success with RG3 uecontext
    Execute Egate Command    ue_change_location id=7 enb=2 cell=2
    UE Register To GNB    ue_id=7
    Execute Egate Command    ue_pdu_session_setup ue=7 pdu=1 nwslice=3 gw=7    QoS Routing Table
    sleep    1s    #to make counter value stable
    Execute Egate Command    ue_rrc_reestablish id=7 gnb=2 cell=1    rrcReconfigurationComplete
    sleep    1s    #to make counter 'PEAK_NUM_NGBR_NRG' value stable

UE1 set to ICS without default PDU session
    Execute Egate Command    amf_param id=1 send_ics_registration=on
    Execute Egate Command    ue_change_location id=1 enb=2 cell=3
    UE Register To GNB    ue_id=1
    Execute Egate Command    ue_pdu_session_setup ue=1 pdu=1 nwslice=1 gw=1    QoS Routing Table

UE2_3_4 register
    Execute Egate Command    amf_param id=1 send_ics_registration=off
    Execute Egate Command    ue_change_location id=2,3,4 enb=2 cell=3
    UE Register To GNB    ue_id=2
    UE Register To GNB    ue_id=3
    UE Register To GNB    ue_id=4

UE2 use 3 non GBR DRB in cell3 RG1
    Execute Egate Command    ue_pdu_session_setup ue=2 pdu=1 nwslice=1 gw=2    QoS Routing Table
    Execute Egate Command    ue_pdu_session_modify ue=2 pdu=1 qosflows_to_add=6,8 by=amf    QoS Routing Table

UE3 ICS fail due to SA non-GBR DRB admission dynamic cell limits check failure
    Execute Egate Command    amf_param id=1 send_ics_registration=on
    Execute Egate Command    ue_pdu_session_setup ue=3 pdu=1 nwslice=1 gw=3    radioNetwork : radio-resources-not-available

Common Test Teardown And Stop Capture Logs and send_ics_registration off
    Execute Egate Command    amf_param id=1 send_ics_registration=off
    Common Test Teardown And Stop Capture Logs
