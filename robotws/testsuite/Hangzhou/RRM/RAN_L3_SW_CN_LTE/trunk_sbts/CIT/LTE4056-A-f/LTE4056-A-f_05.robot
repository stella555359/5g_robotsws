*** Setting ***
Suite Setup       Setup CUS Env And Common Suite Setup
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    4G_FDD    RAN_4G    RAN_4G_FDD    CIT
...               CLOUD_R4LAPO_CUS    release-SBTS18    owner-shelly.song,annie.nie    team-CN3ET
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{PARAMS_FOR_CATM}
...    @{PARAMS_FOR_CATM_Volte}
...    @{PARAMS_FOR_NormalUE}
...    @{PARAMS_FOR_GLOBAL}
...    @{PARAMS_FOR_BbPooling}
@{PARAMS_FOR_CATM}
...    LNCEL-1/LNCEL_FDD-0:actCatM=true
...    LNCEL-1/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNCEL-1/LNCEL_FDD-0:catMProfId=1
...    LNCEL-1/LNCEL_FDD-0/APUCCH_FDD-0:selectPrachRegion=InnerLowerEdge
...    LNBTS/CATMPR-1:siWindowLenCatM=160ms
@{PARAMS_FOR_NormalUE}
...    LNCEL-1:inactivityTimerQci5Sign=100
...    LNBTS:qciTab5:schedulType=SIGNALLING
...    LNBTS:qciTab5:lcgid=0
...    LNBTS:actMultBearers=true
...    LNBTS/LNBTS_FDD-0:actConvVoice=true
...    LNBTS:actRrcConnNoActivity=true
...    LNCEL:inactivityTimer=180
...    LNCEL:qci1ProtectionTimer=180
@{PARAMS_FOR_CATM_Volte}
...    LNBTS:qciTabOperator:gbrOverbookingFactor=0
...    LNBTS:qciTabOperator:lcgid=2|qci=130
...    LNCEL-1/CATMCEL-0:actConvVoiceCatM=true
...    LNBTS/CATMPR-1:cpInactivityTimerCatM=60
...    LNBTS/CATMPR-1:inactivityTimerCatM=120
...    LNBTS/CATMPR-1:srbInactivityTimerCatM=60
...    LNBTS/CATMPR-1:catMVoLTETab:qci1ProtectionTimerCatM=180
...    LNBTS/CATMPR-1:qciForVoLTECatM=130
...    LNBTS/CATMPR-1:maxNumQci1DrbCatM=10
...    LNBTS/CATMPR-1:minNumRrcCatM=15
...    LNBTS/CATMPR-1:maxNumRrcCatM=360
...    LNBTS/CATMPR-1:catMVoLTETab:dlMaxHarqTxQci1CatM=4
...    LNBTS/CATMPR-1:catMVoLTETab:maxGbrDlQci1CatM=80
...    LNBTS/CATMPR-1:catMVoLTETab:maxGbrUlQci1CatM=80
...    LNBTS/CATMPR-1:catMVoLTETab:tDiscardPdcpQci1CatM=infinity
...    LNBTS/CATMPR-1:catMVoLTETab:tDiscardPdcpQci5CatM=300ms
...    LNBTS/CATMPR-1:catMVoLTETab:ulMaxHarqTxQci1CatM=2
@{PARAMS_FOR_GLOBAL}
...    LNCEL-1/LNCEL_FDD-0:maxNumActDrb=265
...    LNCEL-1/LNCEL_FDD-0:maxNumActUE=265
...    LNCEL-1/LNCEL_FDD-0:maxNumCaConfUe=0
...    LNCEL-1/LNCEL_FDD-0:maxNumCaConfUe3c=0
...    LNCEL-1/LNCEL_FDD-0:maxNumCaConfUeDc=0
...    LNCEL-1/LNCEL_FDD-0:maxNumQci1Drb=100
...    LNCEL-1/LNCEL_FDD-0/APUCCH_FDD-0:aPucchMinNumRrc=5
...    LNCEL-1/LNCEL_FDD-0/APUCCH_FDD-0:aPucchMinNumRrcNoDrb=5
...    LNCEL-1/SIB-0:siWindowLen=40ms
...    LNCEL-1/LNCEL_FDD-0:addNumQci1DrbTimeCriticalHo=0
...    LNCEL-1/LNCEL_FDD-0:addNumQci1DrbRadioReasHo=0
@{PARAMS_FOR_BbPooling}
...    LNBTS:actBbPooling=true
...    LNBTS:actEnhAcAndGbrServices=true
...    LNCEL/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:actLbPucchReg=true
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:pucchArRateEvalWinLength=0
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:aPucchSrPeriodUpperLimit=20
...    LNCEL/BBPOOLALLOC-0:bbPoolLogicalGroupId=1
...    LNCEL/BBPOOLALLOC-0:bbPoolTargetId=1
...    LNBTS:bbPoolMinResource=50
...    LNBTS:bbPoolEvalPeriod=20
...    BBMOD-1:bbCardUsage=2
${ERROR}    sErrBearerAcquireUiBearerAllocationReject
*** Test Cases ***
LTE4056-A-f_ET_05_Check VOLTE Threshold for Multi CAT-M
    [Tags]
    CAT-M UE1-UE11 attach to Cell1 and start UL_DL UDP traffic
    Cat-M UE1-UE10 setup QCI5 and QCI130
    Cat-M UE11 setup QCI5 OK and QCI130 Fail

*** Keywords ***
Setup CUS Env And Common Suite Setup
    Common Suite Setup
    Setup CUS Env
    create alias
    execute egate command    trace_sim on mme=1 protocol=s1
    execute egate command    trace_sim uec=1 protocol=rrc on

Create Alias
    Create UE Group Aliases    UE_GROUP    start_ue_id=1    stop_ue_id=100    id_type=cus
    Create Enb Alias    ENB_1    enb_id=1    id_type=wts
    create mme alias    MME_1    mme_id=1    id_type=wts

Modify Yaml
    add yaml    UEs/bearer_sets/bearer_set_2
    ...     - {qci: 8, default: on, pdn: 1, trf_type: external}
    ...     - {qci: 5, gbr_ul: 30, gbr_dl: 30, mbr_ul: 31, mbr_dl: 31, priority: 15, pdn: 1}
    ...     - {qci: 1, gbr_ul: 30, gbr_dl: 30, mbr_ul: 31, mbr_dl: 31, preemption: on, priority: 15,
    ...        vulnerability: on, pdn: 1}
    ...     - {qci: 130, gbr_ul: 30, gbr_dl: 30, mbr_ul: 31, mbr_dl: 31, preemption: on, priority: 15,
    ...        vulnerability: on, delay: 100, pdn: 1}
    FOR    ${ue_id}    IN RANGE    1    12
        Update Yaml    UEs/UE_sets/${ue_id}     bearer: bearer_set_2
    END

CAT-M UE1-UE11 attach to Cell1 and start UL_DL UDP traffic
    FOR    ${ue_id}    IN RANGE    1    12
        expect message flow
        ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfigurationComplete
        ...    alias=UE${ue_id}_attach_flow    overall_timeout=30
    END
    execute uex command    ue_attach id=1-11 cell=1 ue_eutra_capabilities=D6000000800055555D55001000804510021200055C041900
    FOR    ${ue_id}    IN RANGE    1    12
        flow occurred as expected    alias=UE${ue_id}_attach_flow
    END
    execute uex command    trf_data_start ue=1-5 dir=dl protocol=udp kbps=90 trf_id=1
    execute uex command    trf_data_start ue=6-11 dir=ul protocol=udp kbps=10

Cat-M UE1-UE10 setup QCI5 and QCI130
    FOR    ${ue_id}    IN RANGE    1    11
        expect message flow
        ...    MME_1:S1AP_E-RABSetupRequest (E-RABToBeSetupListBearerSUReq contains (e-RAB-ID eq 6 and qCI eq 5))
        ...    MME_1:S1AP_E-RABSetupResponse (E-RABSetupListBearerSURes contains (e-RAB-ID eq 6))
        ...    alias=UE${ue_id}_qci5     overall_timeout=20
    END
    execute uex command    bearer_add ue=1-10 qci=5
    FOR    ${ue_id}    IN RANGE    1    11
        flow occurred as expected    alias=UE${ue_id}_qci5
    END
    FOR    ${ue_id}    IN RANGE    1    11
        expect message flow
        ...    MME_1:S1AP_E-RABSetupRequest (E-RABToBeSetupListBearerSUReq contains (e-RAB-ID eq 7 and qCI eq 130))
        ...    MME_1:S1AP_E-RABSetupResponse (E-RABSetupListBearerSURes contains (e-RAB-ID eq 7))
        ...    alias=UE${ue_id}_qci130     overall_timeout=20
    END
    execute uex command    bearer_add ue=1-10 qci=130 mbr_ul=31 mbr_dl=31 gbr_ul=30 gbr_dl=30
    FOR    ${ue_id}    IN RANGE    1    11
        flow occurred as expected    alias=UE${ue_id}_qci130
    END

Cat-M UE11 setup QCI5 OK and QCI130 Fail
    expect message flow
    ...    MME_1:S1AP_E-RABSetupRequest (E-RABToBeSetupListBearerSUReq contains (e-RAB-ID eq 6 and qCI eq 5))
    ...    MME_1:S1AP_E-RABSetupResponse (E-RABSetupListBearerSURes contains (e-RAB-ID eq 6))
    ...    alias=UE11_qci5     overall_timeout=20
    execute uex command    bearer_add ue=11 qci=5
    flow occurred as expected    alias=UE11_qci5
    expect message flow
    ...    MME_1:S1AP_E-RABSetupRequest (E-RABToBeSetupListBearerSUReq contains (e-RAB-ID eq 7 and qCI eq 130))
    ...    MME_1:S1AP_E-RABSetupResponse (e-RAB-ID eq 7 and cause contains (radioNetwork eq "radio-resources-not-available"))
    ...    alias=UE11_qci130     overall_timeout=20
    execute_uex_command_and_expect_error    bearer_add ue=11 qci=130 mbr_ul=31 mbr_dl=31 gbr_ul=30 gbr_dl=30    ${ERROR}
    flow occurred as expected    alias=UE11_qci130