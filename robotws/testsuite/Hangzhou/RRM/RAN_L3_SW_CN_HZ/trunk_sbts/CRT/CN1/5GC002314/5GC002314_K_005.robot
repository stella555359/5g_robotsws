*** Settings ***
Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    CRT    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    team-SG2
...    owner-baijie.zhu    release-5G20A
Resource          ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SWCONFIG}    ${NumPagingRecords_flags}
${NumPagingRecords_flags}    0x5801be=1
@{PARAMS_IN_SCF}
...    MRBTS-1/NRBTS-1:actPaging=true
...    MRBTS-1/NRBTS-1:drxDefaultPaging=v256
...    MRBTS-1/NRBTS-1:drbInactivityTimerSA=600
...    MRBTS-1/NRBTS-1:srbInactivityTimerSA=600
...    MRBTS-1/NRBTS-1/NRCELL-1:numOfPagingFrames=quaterT
...    MRBTS-1/NRBTS-1/NRCELL-1:pagingOffset=1
...    MRBTS-1/NRBTS-1/NRCELL-1:numPagingOccsnPagingFrame=one
...    MRBTS-1/NRBTS-1/NRCELL-1:pagingTargetRate=MCS9_SF0
...    MRBTS-1/NRBTS-1/NRCELL-1:tddFrameStructure:frameStructureType=semiStatic
...    MRBTS-1/NRBTS-1/NRCELL-1:tddFrameStructure:guardPeriodLength=2Symbols
...    MRBTS-1/NRBTS-1/NRCELL-1:tddFrameStructure:ulDlDataSlotRatio=1/4
...    MRBTS-1/NRBTS-1/NRCELL-1:tddFrameStructure:tdLteUlDlConfig=tdLteConfig2
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1:dciPagingAggregationLevel=AL4
...    MRBTS-1/NRBTS-1/BWP_PROFILE-54/PDCCH-1:dciPagingAggregationLevel=AL4
...    MRBTS-1/NRBTS-1/NRCELLGRP-0:numberOfTransmittedSsBlocks=1 beam
...    @{ADD_PARAMS}
@{ADD_PARAMS}
...    MRBTS-1/NRBTS-1/NRCELL-1:cellDepType=SA+NSA
...    MRBTS-1/NRBTS-1/NRCELL-2:cellDepType=SA+NSA
@{pm_couter_K005}
...    NRCELL-1:${NRPAG_PAGING_SUCC_SENT}==5
...    NRCELL-1:${NRPAG_PAG_DROP_MAX_PGRCD_EXCD}==10
${NRPAG_PAGING_SUCC_SENT}    M55331C00001
${NRPAG_PAG_DROP_MAX_PGRCD_EXCD}    M55331C00002


*** Test Cases ***
5GC002314-ET-K005 Verify paging counter update_TDD
    [Documentation]    Verification of paging counters for every paging message arrival
    ...    and paging drop counter for more than paging messages arrival
    [Tags]    QC_62346
    Set 5G-TMSI
    L3 call is successful
    Make UE to idle
    Clear counter files
    start rrc log    paging
    Paging for 5UEs from AMF and expect one paging
    UE Deregister From GNB
    check rrc log    ${CURDIR}${/}A2A_K005${/}a2a.ini
    check counters    ${pm_couter_K005}

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri
    Comment    Debug Enter Into Egate


Set 5G-TMSI
    Execute Egate Command    amf_registration_param id=1 tmsi=1,1025,2049,3073,4097

L3 call is successful
    FOR    ${index}    IN RANGE    1    6
        Execute Egate Command    ue_register id=${index}    NG RM Registered
        Execute Egate Command    ue_pdu_session_setup ue=${index} pdu=1 nwslice=1 gw=${index}    Initial Context Setup Successful
    END

Make UE to idle
    FOR    ${index}    IN RANGE    1    6
        Execute Egate Command    ue_ng_ctx_release id=${index} cause=NAS_normal_release    UE Context Release Complete
    END

Paging for 5UEs from AMF and expect one paging
    execute egate command    amf_paging_param id=1 default_drx=256 max_paging_retries=10        #no output in egate
    execute egate command    amf_paging_start id=1 ue=all    AMF-1: Setup QosFlow with QFI:1 5QI:8 SEID:1    timeout=30

UE Deregister From GNB
    FOR    ${index}    IN RANGE    1    6
        Execute Egate Command    ue_deregister id=${index} ue_deregister_type=switch_off    detached
    END



