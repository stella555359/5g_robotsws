*** Settings ***
Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    CRT    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    team-SG2
...    owner-baijie.zhu    release-5G20A
Resource          ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SWCONFIG}
...    ${NumPagingRecords_flag1}
...    ${NumPagingRecords_flag2}
${NumPagingRecords_flag1}    0x5801be=32
${NumPagingRecords_flag2}    0x5800F3=1
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

*** Test Cases ***
5GC002314-ET-K003 Verify paging records upto 32 maximum_TDD
    [Documentation]    To Verify paging records upto 32 maximum_TDD
    ...    5GC002314-ET-K001 Verify Paging for different pagingTargetRateIndex with feature flag enable disable_TDD
    [Tags]    QC_62347
    Set 5G-TMSI
    L3 call is successful
    Make UE to idle
    Start RRC Log    paging
    Paging for 32UEs from AMF and expect one paging
    UE Deregister From GNB
    check rrc log    ${CURDIR}${/}A2A_K003${/}a2a.ini

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri    ue_count=40
    Comment    Debug Enter Into Egate

Set 5G-TMSI
    ${cmd}    catenate    amf_registration_param id=1 tmsi=1,1025,2049,3073,4097,5121,6145,7169,8193,9217,10241,11265,12289,13313,14337,15361,
    ...    16385,17409,18433,19457,20481,21505,22529,23553,24577,25601,26625,27649,28673,29697,30721,31745,32769
    Execute Egate Command    ${cmd}

L3 call is successful
    FOR    ${index}    IN RANGE    1    33
        Execute Egate Command    ue_register id=${index}    NG RM Register
    END

Make UE to idle
    FOR    ${index}    IN RANGE    1    33
        Execute Egate Command    ue_ng_ctx_release id=${index} cause=NAS_normal_release    UE Context Release Complete
    END

Paging for 32UEs from AMF and expect one paging
    execute egate command    amf_paging_param id=1 default_drx=256 max_paging_retries=10        #no output in egate
    execute egate command    amf_paging_start id=1 ue=all    No response for SERVICE-REQUEST    timeout=60

UE Deregister From GNB
    FOR    ${index}    IN RANGE    1    33
        Execute Egate Command    ue_deregister id=${index} ue_deregister_type=switch_off    detached
    END