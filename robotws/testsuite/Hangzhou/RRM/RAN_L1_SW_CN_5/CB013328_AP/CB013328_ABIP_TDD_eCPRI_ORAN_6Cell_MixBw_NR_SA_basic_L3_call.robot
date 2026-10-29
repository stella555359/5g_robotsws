*** Settings ***
Documentation
...    Author:  Kong Liang
...    Contact: liang.kong@nokia-sbell.com
...    Feature: CB013328-B
...    Release:

Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    5G_RAN_TDD    RAN_5G    CLOUD_5G_I_MP_AP_LOOO
...    SBTS00    CRT    QL3    QCD_MN_RAN    QCP_RAN_RF
Resource    ../resources/Airphone/Airphone_resource.robot


*** Variables ***
@{ALLOWED_FAULT}

*** Test Cases ***
CB013328_B_TC11_NR_TDD_eCPRI_ABIP_KDDI_ORU_L3_Call_with_6_Cells_20M_30M_50M_70M_90M_100M
    [Documentation]
    ...    This case is to verify ORAN KDDI TDD SA NR L3 call operateability on ABIP with FR1 TDD eCPRI 6 cell.
    [Tags]    ABIP    CB013328_B_TC11    CB013328TDD1    Trunk
    Wait Until Keyword Succeeds    10 min    30 sec    Check If All Cells Are OnAir
    Log To Console     \start L3 call on cell 1
    Airphone L3 call    call_type=sa    cell_id=1    ue_id=1    bearer_id=2
    ...    dl_mbps=200    ul_mbps=30    level=ue_stats_nr    duration=60    thresh=0.7
    sleep    5s
    Log To Console     \start L3 call on cell 2
    Airphone L3 call    call_type=sa    cell_id=2    ue_id=2    bearer_id=2
    ...    dl_mbps=300    ul_mbps=40    level=ue_stats_nr    duration=60    thresh=0.7
    sleep    5s
    Log To Console     \start L3 call on cell 3
    Airphone L3 call    call_type=sa    cell_id=3    ue_id=3    bearer_id=2
    ...    dl_mbps=500    ul_mbps=50    level=ue_stats_nr    duration=60    thresh=0.7
    sleep    5s
    Log To Console     \start L3 call on cell 4
    Airphone L3 call    call_type=sa    cell_id=4    ue_id=4    bearer_id=2
    ...    dl_mbps=600    ul_mbps=100    level=ue_stats_nr    duration=60    thresh=0.7
    sleep    5s
    Log To Console     \start L3 call on cell 5
    Airphone L3 call    call_type=sa    cell_id=5    ue_id=5    bearer_id=2
    ...    dl_mbps=700    ul_mbps=100    level=ue_stats_nr    duration=60    thresh=0.7
    sleep    5s
    Log To Console     \start L3 call on cell 6
    Airphone L3 call    call_type=sa    cell_id=6    ue_id=6    bearer_id=2
    ...    dl_mbps=800    ul_mbps=100    level=ue_stats_nr    duration=60    thresh=0.7

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup for Airphone
    Setup Airphone Env    tl_type=AP_LOOO/tdd_sansa_cmwv/FS/CB013328_6cells_ecpri    cfg=wts.cfg    withCommission=True
