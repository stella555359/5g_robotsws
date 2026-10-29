*** Settings ***
Documentation
...    Author:  Kong Liang
...    Contact: liang.kong@nokia-sbell.com
...    Feature: Robustness
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    5G_RAN_TDD    RAN_5G    CLOUD_5G_I_MP_AP_LOOO
...    SBTS00    CRT    QL3    QCD_MN_RAN    QCP_RAN_RF
Resource    ../../resources/Airphone/Airphone_resource.robot

*** Variables ***
@{ALLOWED_FAULT}
${repeat_number}    10

*** Test Cases ***
Robustness_TC28_NR_FR1_FDD_eCPRI_ABIP_WMP_ORAN_BBU_Lock_Unlock
    [Tags]    QL3    Trunk    Robustness    ABIP    WMP    ORAN    BBULock
    Wait Until Keyword Succeeds     300s    30s    Check If All Cells Are OnAir
    ${mrbtsid}=    selenium_coam.get_bts_id    sbts=suite
    Set Global Variable    ${btsid}    ${mrbtsid}
    FOR    ${round}    IN RANGE    ${repeat_number}
        Log To Console     \n-------------------------------- Round-${round+1} --------------------------------
        BBMOD operation via WebUI    Locked    ABIP
        BBMOD operation via WebUI    Unlocked    ABIP
        Wait Until Keyword Succeeds     300s    30s    Check If All Cells Are OnAir
        Log To Console     \start L3 call
        Airphone L3 call    call_type=sa    cell_id=1    ue_id=1    bearer_id=2
        ...    dl_mbps=400    ul_mbps=200    level=ue_stats_nr
        Airphone L3 call    call_type=sa    cell_id=2    ue_id=2    bearer_id=2
        ...    dl_mbps=200    ul_mbps=200    level=ue_stats_nr
    END

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup for Airphone
    Setup Airphone Env    tl_type=AP_LOOO/fdd_sansa_cmwv/FS/WMP_ecpri_FDD    cfg=wts.cfg    withCommission=True
