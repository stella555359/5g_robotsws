*** Settings ***
Documentation
...    author: Zhang Yin
...    contact: yin.zhang@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_VRF    SBTS00    RAN_5G    RAN_5G_TDD    team-VRF3_8    owner-Chendong.He
...    CLOUD_5G_I_LO_AP_LO    release-SBTS24R3    STATE_CONFIGURED
Resource    testsuite/Hangzhou/RRM/RAN_L3_SW_CN_HZ/resources/DevHZ5_resource.robot


*** Variables ***
${CONFIG_WA}    ${False}
@{PARAMS_IN_SCF}
...    @{8195_parameters}
...    @{SA_mode}
...    @{8225_parameters}
...    @{UEAssistanceInformation_para}
...    @{5GC000732}
...    @{5GC000876}
...    @{EC4_ET_25_parameters}

@{5GC000876}
# cell1 RAC parameter
...    NRBTS-1/NRCELLGRP-0:maxNumOfRrcCGRPSA=275
...    NRCELL-1:maxNumOfRrcSA=5
...    NRCELL-1:maxNumOfSCellAlloc=5
# cell2 RAC parameter
...    NRBTS-1/NRCELLGRP-1:maxNumOfRrcCGRPSA=3
...    NRBTS-1/NRCELLGRP-1:maxNumOfNonGBRBearersCGRPSA=2
...    NRCELL-2:maxNumOfNonGBRBearersSA=3
...    NRCELL-2:maxNumOfRrcSA=3
...    NRCELL-2:maxNumOfSCellAlloc=3
...    NRCELL-2:maxNumOfUsersPerNRCell=3
...    NRCELL-2:maxNumOfUsersPerCell=3
...    NRCELL-2:maxNumOfCaUsersNRCell=3
...    NRCELL-2:maxNumOfNrDcSnUsers=3
...    NRBTS/NRCELLGRP-1:addNumOfNonGBRBearersCGRPSAHo=0
...    NRBTS/NRCELLGRP-1:addNumOfRrcCGRPSAHo=0

@{SA_mode}
...    MRBTS-1/NRBTS-1:gNbCuType=SA
...    MRBTS-1/NRBTS-1/NRCELL-1:cellDepType=SA
...    MRBTS-1/NRBTS-1/NRCELL-2:cellDepType=SA
...    MRBTS-1/NRBTS-1:x2LinkSupervisionTmr=0
...    delete:MRBTS-1/NRBTS-1/NRCELL-1:configuredEpsTac
...    delete:MRBTS-1/NRBTS-1/NRCELL-2:configuredEpsTac

@{8195_parameters}
...    NRBTS:actSliceAwareAdmissionCtrl=true
...    NRCELL-1:sliceAwareAdmissionCtrlEnabled=true
...    NRCELL-2:sliceAwareAdmissionCtrlEnabled=true
...    @{irrelevant_paramaters}
...    NRCELL-1:nrResourceGroupProfileRacDN=MRBTS-1/NRBTS-1/NRRESOURCEGROUP_PROFILE-1
...    NRCELL-2:nrResourceGroupProfileRacDN=MRBTS-1/NRBTS-1/NRRESOURCEGROUP_PROFILE-2
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
...    NRBTS/NRRESOURCEGROUP_PROFILE-2/NRRESOURCEGROUP-1:racParams:maxQuota=0
...    NRBTS/NRRESOURCEGROUP_PROFILE-2/NRRESOURCEGROUP-1:racParams:minQuota=0
...    NRBTS/NRRESOURCEGROUP_PROFILE-2/NRRESOURCEGROUP-2:nrResourceList:resourceDN=MRBTS-1/NRBTS-1/SNSSAI-2
...    NRBTS/NRRESOURCEGROUP_PROFILE-2/NRRESOURCEGROUP-2:racParams:maxQuota=0
...    NRBTS/NRRESOURCEGROUP_PROFILE-2/NRRESOURCEGROUP-2:racParams:minQuota=0
...    NRBTS/NRRESOURCEGROUP_PROFILE-2/NRRESOURCEGROUP-3:nrResourceList:resourceDN=MRBTS-1/NRBTS-1/SNSSAI-3
...    NRBTS/NRRESOURCEGROUP_PROFILE-2/NRRESOURCEGROUP-3:racParams:maxQuota=100
...    NRBTS/NRRESOURCEGROUP_PROFILE-2/NRRESOURCEGROUP-3:racParams:minQuota=70
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
...    NRCELL-2:actPriorityAccess=false
...    NRCELL-2:actEmergencyCall=false
...    NRBTS:actDrbPreemption=false
...    NRBTS:actUserPreemption=false

@{8225_parameters}
...    NRBTS:actRrcInactState=intra-gNB
...    NRBTS:drbRrcInactInactivityTimerSA=20
...    NRBTS:rrcInactIMMSteeringEnabled=false
...    NRBTS:rrcInactLocationReportEnabled=false
...    NRBTS:drbInactivityTimerSA=60
...    NRBTS:maxUeRrcInactTime=4     # ue will release after UE in inactive timeout
...    NRBTS:outOfConnectedPreference=idle
...    NRBTS:srbInactivityTimerSA=30
...    NRBTS:t380=10min
...    NRBTS:act3gppBL23R1=true
...    NRCELL:ranAC=0

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
...    TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-1|snssaiDN=SNSSAI-1
...    TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-2|snssaiDN=SNSSAI-2
...    TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-3|snssaiDN=SNSSAI-3

@{5GC000732}
...    NRBTS-1:rrcReestabTypeSA=sameGNB
...    MRBTS-1/NRBTS-1:tWaitingRlRecover=4000ms

${NRPLMNDNLIST_1}    MRBTS-1/NRBTS-1/NRPLMN-1

@{INACTIVE_check_UE2}
...    SuspendConfig
...    fullI_RNTI
...    shortI_RNTI
...    nextHopChainingCount
...    t380
...    NR_RRC_INACTIVE
...    UE2: Is INACTIVE

@{rrcResumeRequest_regexp_with_mo_Data}
...    rrcResumeRequest
...    resumeCause mo-Data
...    rrcResume
...    UE now in NG RM Registere
...    reestablishment complete
...    pcid:50, scellIdx:0


@{releasePreference_check}
...     QoS Routing Table
...     releasePreference-r16 supported

#supported UE Power Saving's releasePreference-r16
${SA_Capa_UAI_Inactive}    SEPARATOR=
...    FFA00000074E5A031E000383A000F04983200021E12006201A013
...    0080C0700CA8D851AC10143404B2CA261A007AD8202020E1DE387
...    20C38002064F1F570004F001C0013C002A36266B04050D012CB28
...    986801EB608080838778E1C830E0008193C7D5C0013C0070004F0
...    00A8D89BAC10143404B2CA261A007AD8202020E1DE38720C38002
...    064F1F570004F001C0013C002A36276B04050D012CB28986801EB
...    608080838778E1C830E0008193C7D54000014000000820E268000
...    0008385000000000404D15000160201100883FFFFFFE17801F001
...    E00180E0A00E06013003800340D7705807800701AEE0B00F000E0
...    4002000000500080000017C0000000000001CA9A0002000012CB2
...    A00695550B001C002C00000010020046AC4C0004080C1014181C2
...    02C4044484C648494989CA12814A2000042

@{EC4_ET_25_parameters}
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
...    @{NRADJGNB}
...    @{NRADJNRCELL}

@{adjust_inactivity_timer}
...    NRBTS:drbRrcInactInactivityTimerSA=7200
...    NRBTS:drbInactivityTimerSA=604800
...    NRBTS:srbInactivityTimerSA=600

@{NRADJGNB}
...    NRBTS/NRADJGNB-1:administrativeState=Unlocked
...    NRBTS/NRADJGNB-1:gNbIdLength=22
...    NRBTS/NRADJGNB-1:gNodeBId=35
...    NRBTS/NRADJGNB-1:gNodeBIdCtrl=oamControlled
...    NRBTS/NRADJGNB-1:weightForIgnbCaSelection=1
...    NRBTS/NRADJGNB-1:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-1:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-1:gnbPlmn:mncLength=3

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

@{PM_Counters_Check_B1_02}
...    NRCELL-1:NNGCC:${NG_FLOW_SETUP_FAIL_RRNA}=2
...    NRCELL-1:NF1CC:${NRD_RRC_STPREQ_PER_CELL_REJ_CU}=0
...    NRCELL-1:NRRCC:${NRRRC_RRC_REJECT_DU_TRIGG_RECD}=0
...    NRCELL-1:NRRCC:${NRRCC_RRC_STPREJ_MO_DATA}=0
...    NRCELL-1:NRCCD:${NRD_RRC_RESUME_REQUEST1_REJECT}=0
...    NRCELL-1/NRRESOURCEGROUP-1:${AVG_NUM_UE_NOM_NRG}>0
...    NRCELL-1/NRRESOURCEGROUP-1:${DNOM_SAMPLES_NRG}>0
...    NRCELL-1/NRRESOURCEGROUP-1:${AVE_NUM_NGBR_NOM_NRG}>0
...    NRCELL-1/NRRESOURCEGROUP-1:${PEAK_NUM_UE_NRG}=1
...    NRCELL-1/NRRESOURCEGROUP-2:${PEAK_NUM_UE_NRG}=2
...    NRCELL-1/NRRESOURCEGROUP-1:${PEAK_NUM_NGBR_NRG}=1
...    NRCELL-1/NRRESOURCEGROUP-2:${PEAK_NUM_NGBR_NRG}=2
...    NRCELL-1/NRRESOURCEGROUP-1:${NUM_ADM_REQ_NGBR_NRG}=1
...    NRCELL-1/NRRESOURCEGROUP-1:${NUM_ADM_SUC_NGBR_NRG}=1
...    NRCELL-1/NRRESOURCEGROUP-2:${NUM_ADM_REQ_NGBR_NRG}=6
...    NRCELL-1/NRRESOURCEGROUP-2:${NUM_ADM_SUC_NGBR_NRG}=4
...    NRCELL-1/NRRESOURCEGROUP-1:${NUM_ADM_REQ_UE_NRG}=1
...    NRCELL-1/NRRESOURCEGROUP-1:${NUM_ADM_SUC_UE_NRG}=1
...    NRCELL-1/NRRESOURCEGROUP-2:${NUM_ADM_REQ_UE_NRG}=6
...    NRCELL-1/NRRESOURCEGROUP-2:${NUM_ADM_SUC_UE_NRG}=4
...    NRCELL-1/NRRESOURCEGROUP-1:${RAC_REJ_DUE_DRB_MAX_QUOTA_NRG}=0
...    NRCELL-1/NRRESOURCEGROUP-1:${RAC_REJ_DUE_UE_MAX_QUOTA_NRG}=0
...    NRCELL-1/NRRESOURCEGROUP-2:${RAC_REJ_DUE_DRB_MAX_QUOTA_NRG}=0
...    NRCELL-1/NRRESOURCEGROUP-2:${RAC_REJ_DUE_UE_MAX_QUOTA_NRG}=2

${NG_FLOW_SETUP_FAIL_RRNA}    M55125C10501
${NRD_RRC_STPREQ_PER_CELL_REJ_CU}    M55113C03001
${NRRRC_RRC_REJECT_DU_TRIGG_RECD}    M55124C01011
${NRRCC_RRC_STPREJ_MO_DATA}    M55124C01022
${NRD_RRC_RESUME_REQUEST1_REJECT}    M55166C00509
${SGNB_SA_RAC_REJ_DUE_TO_NGBR}    M55138C00007

@{PM_Counters_Check_EC4_25}
...    NRCELL-2:NNGCC:${NG_FLOW_SETUP_FAIL_RRNA}=0
...    NRCELL-2:NF1CC:${NRD_RRC_STPREQ_PER_CELL_REJ_CU}=0
...    NRCELL-2:NRRCC:${NRRRC_RRC_REJECT_DU_TRIGG_RECD}=0
...    NRCELL-2:NRRCC:${NRRCC_RRC_STPREJ_MO_DATA}=0
...    NRCELL-2:NRCCD:${NRD_RRC_RESUME_REQUEST1_REJECT}=0
...    NRCELL-2:RSACU:${SGNB_SA_RAC_REJ_DUE_TO_NGBR}=1
...    NRCELL-2/NRRESOURCEGROUP-3:${AVG_NUM_UE_NOM_NRG}>0
...    NRCELL-2/NRRESOURCEGROUP-3:${DNOM_SAMPLES_NRG}>0
...    NRCELL-2/NRRESOURCEGROUP-3:${AVE_NUM_NGBR_NOM_NRG}>0
...    NRCELL-2/NRRESOURCEGROUP-3:${PEAK_NUM_UE_NRG}=3
...    NRCELL-2/NRRESOURCEGROUP-3:${PEAK_NUM_NGBR_NRG}=3
...    NRCELL-2/NRRESOURCEGROUP-3:${NUM_ADM_REQ_NGBR_NRG}=4
...    NRCELL-2/NRRESOURCEGROUP-3:${NUM_ADM_SUC_NGBR_NRG}=4
...    NRCELL-2/NRRESOURCEGROUP-3:${NUM_ADM_REQ_UE_NRG}=4
...    NRCELL-2/NRRESOURCEGROUP-3:${NUM_ADM_SUC_UE_NRG}=4
...    NRCELL-2/NRRESOURCEGROUP-3:${RAC_REJ_DUE_DRB_MAX_QUOTA_NRG}=0
...    NRCELL-2/NRRESOURCEGROUP-3:${RAC_REJ_DUE_UE_MAX_QUOTA_NRG}=0

@{delta_commission_EC4_25}
...    NRBTS/NRCELLGRP-1:addNumOfNonGBRBearersCGRPSAHo=1
...    NRBTS/NRCELLGRP-1:addNumOfRrcCGRPSAHo=1

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

*** Test Cases ***
CB008195-A-B1_ET_02_01_SA RRC connection admission for resumed UE context
    [Documentation]
    ...    The test scenario is intended to verify SA RRC connection admission for resumed UE context.
    ...    2. Configuration
    ...       a.SA,TDD+TDD, CA(band 78+band 78)
    ...    3. Test Case Steps:
    ...       Test Scenario 1: Check UE2 resume normally on Cell1 RG2
    ...           a.Set UE2 Core Network Assistance Information for RRC INACTIVE state in the Initial Context Setup Request.
    ...             And trigger UE2 register to Cell1.
    ...           Expected result:UE2 registers successfully to Cell1.
    ...           b.UE2 wait srbInactivityTimerSA
    ...           Expected result:UE2 release to RRC_INACTIVITE UE Assistance Information.
    ...           c.UE1 and UE3 Register to Cell1.
    ...           Expected result:UE1/3 Register successfully.
    ...           d.UE2 Send ResumeRequest1 to RRC_ACTIVE state
    ...           Expected result: UE2 stay in RRC_connection state
    ...       Test Scenario 2:check Cell1 RG2 maxquota reaches and UE1 can't ressign to Cell1 RG2.
    ...           e.UE1 Deregister
    ...           Expected result: UE1 Deregister Successfully.
    ...           f.UE1 Register Resource Group 1 Slice2.
    ...           Expected result: UE1 Register Resource Group 1 Slice2 failure due to RG1 Slice2 beyond MaxQuota limitation.
    ...       Test Scenario 3:check UE2 resume failure due to Cell1 RG2 maxquota reaches.
    ...           g.wait UE2 become inactive again and UE1 register to RG1 slice2
    ...           Expected result: UE1 Register Resource Group 1 Slice2 successfully due to RG1 Slice2 resource enough.
    ...           h.UE2 Send ResumeRequest1 to RRC_ACTIVE state
    ...           Expected result:UE2 resume failure due to RG1 Slice2 MaxQuota limitation reaches.
    [Tags]    owner-chendong.he    c1
    Clear Counter files
    Register UE2 Slice2 with UAI at Cell1
    Wait UE2 for srbInactivityTimerSA expired
    Register UE1 Slice1 at Cell1 And Send Traffic
    Register UE3 Slice2 at Cell1 And Send Traffic
    Make UE2 send ResumeRequest
    UE1 Deregister And Register UE1 Slice2 Reject at Cell1
    UE1 Deregister And Wait UE2 for srbInactivityTimerSA expired
    Register UE1 Slice2 at Cell1 And Send Traffic
    Make UE2 Send ResumeRequest with Reject
    Release Ues    ue_type=sa    ue_id=1-3
    Check Counters    pm_counters_expression=${PM_Counters_Check_B1_02}
    [Teardown]    Test teardown for A_B1_02

CB008195-A-EC4_ET_25_01_SA UE admission static cell limits check failure during incoming inter-gNB NG handover
    [Documentation]
    ...    The test scenario is intended to verify SA RRC connection admission during incoming inter-gNB NG handover.
    ...       TDD Scaling Factor: 1 for static cell limits check
    ...    2. Configuration
    ...       a.SA,TDD+TDD, CA(band 78+band 78)
    ...    3. Test Case Steps:
    ...       a.UE1 UE2 Register RG1 Slice3 of Cell2.
    ...       Expected result:UE1 and UE2 Register and Setup Pdu Successfully.
    ...       b.UE2 NG Handover to Sim Gnb3 Cell1 PCI381.
    ...       Expected result: UE2 NG Handoverto Sim Gnb3 Cell1 PCI381 Successfully.
    ...       c.UE3 Register RG1 Slice3 of Cell2.
    ...       Expected result:UE3 Register and Setup Pdu Successfully.
    ...       d.UE2 NG Handover back Real Gnb2 Cell1 PCI51.
    ...       Expected result: UE2 NG Handover Failure due to RG1 Slice1 beyond MaxQuota limitation.
    ...       e.modify addNumOfNonGBRBearersCGRPSAHo and addNumOfRrcCGRPSAHo to 1
    ...       Expected result: modification successfully.
    ...       f.UE2 NG Handover back Real Gnb2 Cell1 PCI51.
    ...       Expected result: UE2 NG Handover successfully.
    [Tags]    owner-chendong.he    c2
    Online Param Change    ${adjust_inactivity_timer}
    Clear Counter files
    Register UE1 UE2 Slice3 at Cell2
    UE2 Inter Gnb NG Handover To Sim381
    Register UE3 Slice3 at Cell2
    UE2 Inter Gnb NG Handover back Cell2 Failure
    Online Update HO cell group additional resouce    ${delta_commission_EC4_25}
    UE2 Inter Gnb NG Handover back Cell2
    Check Counters    pm_counters_expression=${PM_Counters_Check_EC4_25}
    Release Ues    ue_type=sa    ue_id=1-3

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri    ue_count=10
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
    ...    xn=10.0.1.122 nssai=0x1:0xd143a5 amf=1
    Update Cfg    ${set_gnb3}
    ${set_gnb3_cell1}    catenate    set_cell id=1 gnb=3 pci=127:0 tac=200 nrci=0x01 tdd_cell=on proxy=10.0.2.90:9999 nr_arfcn=513234:513234
    ...    gscn=6414 mandatory_for_activation=off
    Update Cfg    ${set_gnb3_cell1}

Update UE capa
    [Arguments]    ${ue_id}    ${SA_Capa_perUE_Full}=none
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full}
    Execute Egate Command    ${cmd}

Register UE1 Slice1 at Cell1
    UE attach with PDU    ue_id=1    target_cell_id=1    gw1=1    nwslice1=1

Register UE1 Slice2 at Cell1
    UE attach with PDU    ue_id=1    target_cell_id=1    gw1=1    nwslice1=2

Register UE1 Slice2 Reject at Cell1
    UE attach with PDU    ue_id=1    target_cell_id=1    gw1=1    nwslice1=2
    ...    pass_regexp=UE now in NG RM Register     pdu_pass_regexp=radio resources not available

Register UE2 Slice2 with UAI at Cell1
    UE attach with UAI    ue_id=2    target_cell_id=1    plmn=489    tac=200    gw1=2    nwslice1=2    amf_id=1

Register UE3 Slice2 at cell1
    UE attach with PDU    ue_id=3    target_cell_id=1    gw1=3    nwslice1=2

UE2 Inter Gnb NG Handover To Sim381
    Trigger A2 measurement report    ue_id=2    carrierfreq=636576
    Trigger A3 Measurement Report    ue_id=2    carrierfreq=513150    phycelId=381
    ...    pass_check=Inter-eNB handover from EXT_ENB-2.2 to ENB-3.1 performed

UE2 Inter Gnb NG Handover back Cell2 Failure
    Trigger A2 measurement report    ue_id=2    carrierfreq=513150
    Trigger A3 Measurement Report    ue_id=2    carrierfreq=636576    phycelId=51    pass_check=RAN radio resources not available

UE2 Inter Gnb NG Handover back Cell2
    Trigger A3 Measurement Report    ue_id=2    carrierfreq=636576    phycelId=51
    ...    pass_check=Inter-eNB handover from ENB-3.1 to EXT_ENB-2.2 performed

Wait UE2 for srbInactivityTimerSA expired
    Execute Egate Command    Wait UE2 for srbInactivityTimerSA expired    pass_regexp=${INACTIVE_check_UE2}    timeout=31s

Make UE2 Send ResumeRequest
    Trigger UE resume    ue_id=2    cell_id=1    cause=mo_Data    pass_regexp=${rrcResumeRequest_regexp_with_mo_Data}

Make UE2 Send ResumeRequest with Reject
    Trigger UE resume    ue_id=2    cell_id=1    cause=mo_Data    pass_regexp=RAN radio resources not available

UE Attach with UAI
    [Arguments]    ${ue_id}=1    ${target_cell_id}=1    ${plmn}=489    ${tac}=200     ${gw1}=1
    ...    ${nwslice1}=1    ${amf_id}=1    ${pass_regexp}=UE now in NG RM Register
    Update UE capa    ue_id=${ue_id}    SA_Capa_perUE_Full=${SA_Capa_UAI_Inactive}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${target_cell_id}
    ${set_ics_param}    catenate     amf_ue_ics_param id=${amf_id} core_network_assistance_info=on ue_identity_index_value=${ue_id}
    ...     ue_specific_drx=64 periodic_registration_update_timer=1:10min plmn_id=311:${plmn} tac_id=${tac}
    Execute Egate Command    ${set_ics_param}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=${pass_regexp}
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=${gw1} nwslice=${nwslice1}    pass_regexp=${releasePreference_check}

UE attach with PDU
    [Arguments]    ${ue_id}=1    ${target_cell_id}=1    ${gw1}=1
    ...    ${nwslice1}=1    ${pass_regexp}=UE now in NG RM Register    ${pdu_pass_regexp}=${releasePreference_check}
    Update UE capa    ue_id=${ue_id}    SA_Capa_perUE_Full=${SA_Capa_UAI_Inactive}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${target_cell_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=${pass_regexp}
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${ue_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${ue_id} gw=${gw1} nwslice=${nwslice1}    pass_regexp=${pdu_pass_regexp}

Trigger UE resume
   [Arguments]    ${ue_id}=1    ${cell_id}=1    ${cause}=mo_Data    ${pass_regexp}=${Resume_regexp_with_mo_Data}
    Execute Egate Command    ue_nr_rrc_resume_request_param id=${ue_id} gnb=2 cell=${cell_id} cause=${cause} msg=resume_request
    Execute Egate Command    ue_nr_rrc_resume id=${ue_id}     pass_regexp=${pass_regexp}

Online Param Change
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be Onair    check_sib=${False}

UE1 Deregister
    UE Deregister From gNB    ue_id=1

UE Deregister From gNB
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s

Test teardown for A_B1_02
    Online Param Change    ${adjust_inactivity_timer}
    Common Test Teardown And Stop Capture Logs

Trigger A2 measurement report
    [Arguments]    ${ue_id}    ${carrierfreq}    ${pass_check}=rrcReconfigurationComplete
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A2
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 srsrp_nr=3 srsrq_nr=5
    ...    pass_regexp=${pass_check}

Trigger A3 Measurement Report
    [Arguments]    ${ue_id}    ${carrierfreq}    ${phycelId}    ${pass_check}    ${nrsrp_nr}=60    ${nrsrq_nr}=60
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A3
    ${V3}    catenate
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=${phycelId} nrsrp_nr=${nrsrp_nr}
    ...    nrsrq_nr=${nrsrq_nr}
    Execute Egate Command    ${V3}    pass_regexp=${pass_check}

Send Multiple UE Traffic
    [Arguments]    ${ue_id_start}    ${ue_id_end}    ${pdu_id}    ${dir}
    FOR    ${ue_id}    IN RANGE    ${ue_id_start}    ${${ue_id_end}+1}
        Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=${dir} kbps=64
    END

Register UE3 Slice2 at Cell1 And Send Traffic
    Register UE3 Slice2 at Cell1
    Send Multiple UE Traffic    ue_id_start=3    ue_id_end=3    pdu_id=3    dir=dl

Register UE1 Slice1 at Cell1 And Send Traffic
    Register UE1 Slice1 at Cell1
    Send Multiple UE Traffic    ue_id_start=1    ue_id_end=1    pdu_id=1    dir=dl

Register UE1 Slice2 at Cell1 And Send Traffic
    Register UE1 Slice2 at Cell1
    Send Multiple UE Traffic    ue_id_start=1    ue_id_end=1    pdu_id=1    dir=dl

UE1 Deregister And Register UE1 Slice2 Reject at Cell1
    UE1 Deregister
    Register UE1 Slice2 Reject at Cell1

UE1 Deregister And Wait UE2 for srbInactivityTimerSA expired
    UE1 Deregister
    Wait UE2 for srbInactivityTimerSA expired

Online Update HO cell group additional resouce
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir

Register UE1 Slice3 at Cell2
    UE attach with PDU    ue_id=1    target_cell_id=2    gw1=1    nwslice1=3

Register UE2 Slice3 at Cell2
    UE attach with PDU    ue_id=2    target_cell_id=2    gw1=1    nwslice1=3

Register UE1 UE2 Slice3 at Cell2
    Register UE1 Slice3 at Cell2
    Register UE2 Slice3 at Cell2

Register UE3 Slice3 at Cell2
    UE attach with PDU    ue_id=3    target_cell_id=2    gw1=1    nwslice1=3
