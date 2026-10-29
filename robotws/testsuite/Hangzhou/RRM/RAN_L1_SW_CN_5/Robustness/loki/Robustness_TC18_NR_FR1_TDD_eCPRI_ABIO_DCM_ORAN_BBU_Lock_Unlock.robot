*** Settings ***
Documentation
...    Author:  Kong Liang
...    Contact: liang.kong@nokia-sbell.com
...    Feature: Robustness
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    5G_RAN_TDD    RAN_5G    CLOUD_5G_I_LO_AP_LOOO
...    SBTS00    CRT    QL3    QCD_MN_RAN    QCP_RAN_RF
Resource    ../../resources/Airphone/Airphone_resource.robot

*** Variables ***
@{ALLOWED_FAULT}
${repeat_number}    10
${WTS_DIR}    /opt/iphy/latest
${DEBUG_LOG_LEVEL}    2

*** Test Cases ***
Robustness_TC18_NR_FR1_TDD_eCPRI_ABIO_DCM_ORAN_BBU_Lock_Unlock
    [Tags]    Robustness    ABIO    BBULock    Trunk    QL3
    Wait Until Keyword Succeeds    3 min    30 sec    Check If All Cells Are OnAir
    Ue Attach to cell and data traffic
    ${mrbtsid}=    selenium_coam.get_bts_id    sbts=suite
    Set Global Variable    ${btsid}    ${mrbtsid}
    FOR    ${item}    IN RANGE    ${repeat_number}
        Log To Console     \n[INFO] ----------Round-${item+1} BBU Lock Unlock ...----------
        BBU Lock Unlock And Wts Reconf
        Ue Attach to cell and data traffic
    END

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup for Airphone
    Setup Airphone Env    tl_type=AP_LOOO/tdd_sansa_cmwv/FS/DCM_2cells_ecpri    cfg=wts.cfg    withCommission=True

Ue Attach to cell and data traffic
    Log To Console     \start L3 call
    Airphone L3 call    call_type=sa    cell_id=1    ue_id=1    bearer_id=2
    ...    dl_mbps=200    ul_mbps=100    level=ue_stats_nr
    Airphone L3 call    call_type=sa    cell_id=2    ue_id=2    bearer_id=2
    ...    dl_mbps=200    ul_mbps=100    level=ue_stats_nr

BBU Lock Unlock And Wts Reconf
    BBMOD operation via WebUI    Locked    ABIO
    BBMOD operation via WebUI    Unlocked    ABIO
    Start Wts And Wait Until Gnb Onair    ${WTS_DIR}/wts.cfg    ${DEBUG_LOG_LEVEL}    300    tag=startup_1
    Wait Until Keyword Succeeds    3 min    30 sec    Check If All Cells Are OnAir
