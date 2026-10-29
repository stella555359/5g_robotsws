*** Settings ***
Suite Setup       Common Suite Setup And Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_TDD    CRT    CLOUD_R4LAPO_CUS
...               release-RL25    team-RT1    owner-jianping.ying and rebecca.zhong
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    LNCEL-1:actSmartDrx=true
...    LNCEL-1:inactivityTimer=2000
...    LNCEL-1:actDrx=true
...    LNBTS-1:actIfHo=enabled
...    LNBTS-1:actMultBearers=true
...    LNBTS-1:actNonGbrServiceDiff=true
...    LNCEL-1/LNCEL_TDD-0:actAutoPucchAlloc=true
...    LNBTS-1:actSelMobPrf=true
...    LNBTS-1/MODPR-0:autoAdapt=true
...    delete:LNBTS-1/MODPR-0
...    LNBTS-1:actLTES1Ho=true
...    LNCEL-1:threshold2InterFreq=60
...    LNCEL-1:threshold2a=70
...    LNBTS-1:qciTab8:drxProfileIndex=5
...    LNCEL-1/SDRX-0:drxSmartProfile5:drxLongCycle=2560ms
...    LNCEL-1/SDRX-0:drxSmartProfile5:drxInactivityT=50
...    LNCEL-1/SDRX-0:drxSmartProfile5:drxOnDuratT=10
...    LNCEL-1/SDRX-0:drxSmartProfile5:drxShortCycle=80ms
...    LNCEL-1/LNHOIF-1:eutraCarrierInfo=38150
...    LNBTS-1/LNADJ-1/LNADJL-1:fDlEarfcn=38150
...    LNCEL-1/SDRX-0:drxSmartProfile2:drxLongCycle=40ms
...    LNCEL-1/SDRX-0:drxSmartProfile2:drxShortCycle=40ms
...    LNBTS-1:qciTab1:drxProfileIndex=2
@{QCI1_BEARER}
...    LNBTS-1:qciTab1:maxGbrDl=1024
...    LNBTS-1:qciTab1:maxGbrUl=1024
${ue_cap}         C5BFF0441B3E6D196000FFFFFFFFFC0401040104010401052A8380
@{delta_para}
...    LNBTS-1:actMultBearers=true
...    LNBTS-1:actNonGbrServiceDiff=true
...    LNBTS-1:actIfHo=enabled
...    LNCEL-1:threshold2InterFreq=60
...    LNCEL-1:threshold2a=70
...    LNBTS-1:qciTab8:drxProfileIndex=5
...    LNCEL-1/SDRX-0:drxSmartProfile5:drxLongCycle=2560ms
...    LNCEL-1/SDRX-0:drxSmartProfile5:drxInactivityT=50
...    LNCEL-1/SDRX-0:drxSmartProfile5:drxOnDuratT=10
...    LNCEL-1/SDRX-0:drxSmartProfile5:drxShortCycle=80ms
...    LNCEL-1/LNHOIF-1:eutraCarrierInfo=38150
...    LNBTS-1/LNADJ-1/LNADJL-1:fDlEarfcn=38150
...    LNCEL-1/DRX-0:applyOutOfSyncState=allUEs
@{PM_COUNTERS}
...    LNCEL-1:${SUBFRAME_DRX_ACTIVE_UE}>=1000
...    LNCEL-1:${SUBFRAME_DRX_SLEEP_UE}>=0
...    LNCEL-1:${CELL_LOAD_UL_IN_SYNC}>=1
...    LNCEL-1:${CELL_LOAD_UL_IN_SYNC_AVG}>=1
...    LNCEL-1:${CELL_LOAD_UL_OUT_SYNC_100_INF}>=1
${SUBFRAME_DRX_ACTIVE_UE}    M8013C24
${SUBFRAME_DRX_SLEEP_UE}    M8013C25
${CELL_LOAD_UL_IN_SYNC}    M8001C427
${CELL_LOAD_UL_IN_SYNC_AVG}    M8001C428
${CELL_LOAD_UL_OUT_SYNC_100_INF}    M8001C434
${out_of_sync}    40s
${wait_ue_attach}    120s
${wait_ue_traffic}    5s

*** Test Cases ***
LTE42_TD_LTE_DRX verification for related PM Counter
    [Tags]
    Delta Commission Parameters    ${delta_para}
    UE Trigger Data     ue_id=1
    UE Trigger Outofsync_100     ue_id=3
    Check Counters    ${PM_COUNTERS}

*** Keyword ***
Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs    ue_count=100
    Create UE Alias    UE_1    ue_id=1    id_type=cus
    Create UE Alias    UE_3    ue_id=3    id_type=cus
    Create Enb Alias    ENB_1    enb_id=1    id_type=wts
    Create MME Alias    alias=MME_1    mme_id=1    id_type=wts


UE Trigger Data
    [Arguments]    ${ue_id}=1    ${cell_id}=1
    Execute Uex Command    ue_attach id=${ue_id} ue_eutra_capabilities=C59FF41032C10381D38346201002008200 cell=${cell_id}
    Execute Uex Command    trf_data_start ue=${ue_id} bearer=5 Mbps=1 dir=dl protocol=udp trf_id=1
    Execute Uex Command    trf_data_start ue=${ue_id} bearer=5 Mbps=1 dir=ul protocol=udp trf_id=1
    sleep    ${wait_ue_traffic}

UE Trigger Outofsync_100
    [Arguments]    ${ue_id}=3    ${cell_id}=1
    Execute Uex Command    ue_attach id=${ue_id} ue_eutra_capabilities=C59FF41032C10381D58346201002008200 cell=${cell_id}
    sleep    ${wait_ue_attach}
    Execute Uex Command    ue_error id=${ue_id} after=now action=cqi_misalignment
    Execute Uex Command    trf_data_start ue=${ue_id} bearer=5 Mbps=1 dir=ul protocol=udp trf_id=1 duration=120 duration_unit=seconds
    Execute Uex Command    trf_data_start ue=${ue_id} bearer=5 Mbps=1 dir=dl protocol=udp trf_id=1 duration=120 duration_unit=seconds
    sleep    ${out_of_sync}
