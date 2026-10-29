*** Settings ***
Suite Setup       Common Suite Setup And Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    4G_FDD    RAN_4G    RAN_4G_FDD    CRT    team-DEVHZ5_FT1
...               CLOUD_R4LAPO_CUS    release-xL18    owner-haibwang    owner-rebecca.zhong
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{PARAMS_FOR_CATM}
...    @{PARAMS_FOR_NormalUE}
@{PARAMS_FOR_CATM}
...    LNBTS-1/CATMPR-1:siWindowLenCatM=160ms
...    LNBTS-1/CATMPR-1:raPreGrCSizeCatM=1
...    LNBTS-1/CATMPR-1:inactivityTimerCatM=15
...    LNBTS-1/CATMPR-1:pagAreaScopeCheckCatM=true
...    LNCEL/CATMCEL-0:threshold2CatM=42
...    LNCEL/LNCEL_FDD-0:actCatM=true
...    LNCEL/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNCEL/LNCEL_FDD-0:catMProfId=1
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:selectPrachRegion=InnerLowerEdge
...    LNCEL/SIB-0:siWindowLen=20ms
...    @{fix_relation_error}
@{fix_relation_error}
...    LNCEL/SIB-0:threshServingLowQR9=0
...    LNCEL/SIB-0:cellSelectionInfoV920:qQualMinR9=-34
@{PARAMS_FOR_NormalUE}
...    LNCEL:inactivityTimer=30
${CatMUE_eutra_capabilities}    D6000000800055555D55001000804510021200055C041900
${NormalUE_eutra_capabilities}    C580000A00007F068C4F0000C2
${User_Inactivity_Time}    30
@{PM_Counters}
...    ${RRC_PAGING_ECGI_LTEM}=2
...    ${RRC_CONN_SET_MT_ECGI_LTEM}=2
${RRC_PAGING_ECGI_LTEM}    M8061C211
${RRC_CONN_SET_MT_ECGI_LTEM}    M8061C210
@{PM_Counters_Initial}
...    ${RRC_PAGING_ECGI_LTEM}=0
...    ${RRC_CONN_SET_MT_ECGI_LTEM}=0


*** Test Cases ***
LTE4494-A-l_ET_01_01_Paging CAT-M UE attempts and respose successful with ECGI matched
    [Tags]
    UE Attach to eNB1 CELL1    ue_id=1    ue_eutra_capabilities=${CatMUE_eutra_capabilities}    #CatM-UE1 attach in eNB1 cell1
    UE Attach to eNB1 CELL1    ue_id=2    ue_eutra_capabilities=${CatMUE_eutra_capabilities}    #CatM-UE2 attach in eNB1 cell1
    sleep    ${User_Inactivity_Time}
    UE Paging by MME    ue_id=1    attempt_count=1    paging_attempts=2    #CatM-UE1 paging with Paging optimization condition 1
    UE Paging by MME    ue_id=2    attempt_count=1    paging_attempts=2    #CatM-UE2 paging with Paging optimization condition 1
    Check Counters    ${PM_Counters}


*** Keywords ***
Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs_FDD    ue_count=100
    Create UE Group Aliases    UE_GROUP    start_ue_id=1    stop_ue_id=20    id_type=cus
    Create Enb Alias    ENB_1    enb_id=1    id_type=wts
    Create MME Alias    MME_1    mme_id=1    id_type=wts
    Create CELL alias    alias=CELL_1    cell_id=1    cell_type=cus
    Create CELL alias    alias=CELL_2    cell_id=2    cell_type=cus
    Execute Egate Command    trace_sim on mme=1 protocol=s1
    Execute Egate Command    trace_sim uec=1 protocol=rrc on

UE Attach to eNB1 CELL1
    [Arguments]    ${ue_id}    ${ue_eutra_capabilities}    ${cell_id}=1
    Expect Message Flow
    ...    MME_1:S1AP_InitialContextSetupRequest
    ...    MME_1:S1AP_UECapabilityInfoIndication (UE-EUTRA-Capability contains (ue-CategoryDL-v1310 eq "m1"))
    ...    alias=ue_attach_catm  overall_timeout=30
    Execute Uex Command    ue_attach id=${ue_id} ue_eutra_capabilities=${ue_eutra_capabilities} cell=${cell_id}
    Flow Occurred As Expected    alias=ue_attach_catm

UE Paging by MME
    [Arguments]    ${ue_id}=1    ${attempt_count}=1    ${paging_attempts}=2
    Expect Message Flow
    ...    MME_1:S1AP_Paging (pagingAttemptInformation contains (pagingAttemptCount eq 1 and intendedNumberOfPagingAttempts eq 2))
    ...    alias=ue_paging  overall_timeout=30
    ${V_1}  catenate  ue_im_exit id=${ue_id} by=mme paging_attempt_count=${attempt_count} intended_number_of_paging_attempts=${paging_attempts}
    ...  next_paging_area_scope=same
    Execute Egate Command   ${V_1}
    sleep    3
    Flow Occurred As Expected    alias=ue_paging

