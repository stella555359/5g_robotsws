*** Settings ***
Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    C*T    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    team-SG2
...    owner-baijie.zhu    release-5G20A
Resource          ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    MRBTS-1/NRBTS-1:actPaging=true
...    MRBTS-1/NRBTS-1:drxDefaultPaging=v256
...    MRBTS-1/NRBTS-1:drbInactivityTimerSA=600
...    MRBTS-1/NRBTS-1:srbInactivityTimerSA=600
...    MRBTS-1/NRBTS-1/NRCELL-1:numOfPagingFrames=quaterT
...    MRBTS-1/NRBTS-1/NRCELL-1:pagingOffset=1
...    MRBTS-1/NRBTS-1/NRCELL-1:numPagingOccsnPagingFrame=one
...    MRBTS-1/NRBTS-1/NRCELL-1:pagingTargetRate=MCS9_SF0
...    MRBTS-1/NRBTS-1/NRCELL-1:siChangeIndDuration=2
...    MRBTS-1/NRBTS-1/NRCELL-1:modPeriodCoeff=n2
...    MRBTS-1/NRBTS-1/NRCELL-1:t300=1000ms
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
...    MRBTS-1/NRBTS-1/NRCELL-2:t300=400ms
@{Delta_param1}
...    MRBTS-1/NRBTS-1/NRCELL-1:t300=1500ms
@{Delta_param2}
...    MRBTS-1/NRBTS-1/NRCELL-1:t300=2000ms

*** Test Cases ***
5GC002314-ET-K004 Verify short message for SI modification_TDD
    [Documentation]    To verify short message for SI modification_TDD
    [Tags]    QC_62345
    egate console log should contain    ${WTS_DIR}${/}egate_console.log    t300 ms1000
    start rrc log    setSIB
    Modify T300 param    change_param=${Delta_param1}
    Modify T300 param    change_param=${Delta_param2}
    Check RRC log    ${CURDIR}${/}A2A_K004${/}a2a.ini


*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri
    Comment    Debug Enter Into Egate

wait for cell stable
    sleep    10

Modify T300 param
    [Arguments]    ${change_param}
    Delta commission parameters    ${change_param}
    Cells should be onair
    wait for cell stable

