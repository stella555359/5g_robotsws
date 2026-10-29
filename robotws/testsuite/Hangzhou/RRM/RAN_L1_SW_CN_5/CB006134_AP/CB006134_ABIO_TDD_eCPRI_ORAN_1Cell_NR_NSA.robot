*** Settings ***
Documentation
...    Author:  Kong Liang
...    Contact: liang.kong@nokia-sbell.com
...    Feature: CB006134
...    Release: 24R2
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    5G_RAN_TDD    RAN_5G    CLOUD_5G_I_LO_AP_LOOO
...    SBTS00    CRT    QL3    QCD_MN_RAN    QCP_RAN_RF
Resource    ../resources/Airphone/Airphone_resource.robot

*** Variables ***
@{ALLOWED_FAULT}

*** Test Cases ***
CB006134_TC01_NR_FR1_TDD_eCPRI_ABIO_ORAN_1Cell_NSA_BTS_reset_100MHZ
    [Documentation]
    ...    This case is to verify ORAN DCM TDD NSA NR L3 call operateability on ABIO after BTS reset.
    [Tags]    ABIO    CB006134_TC01    1cell4D4U    Trunk
    Site Reset Via WebUI
    Log To Console    \n[INFO] Site resetting ...
    Sleep    180s
    Wait Until Keyword Succeeds    10 min    30 sec    Check If All Cells Are OnAir
    Log To Console     \start L3 call
    Airphone L3 call    call_type=nsa    cell_id=1    ue_id=11    bearer_id=2
    ...    dl_mbps=700    ul_mbps=100    level=ue_stats_nr

CB006134_TC02_NR_FR1_TDD_eCPRI_ABIO_ORAN_1Cell_NSA_cell_block_unblock_100MHZ
    [Documentation]
    ...    This case is to verify ORAN DCM TDD NSA NR L3 call operateability on ABIO after cell block unblock.
    [Tags]    ABIO    CB006134_TC02    1cell4D4U    Trunk
    Wait Until Keyword Succeeds    10 min    30 sec    Check If All Cells Are OnAir
    Perform block NR Cell 1 via WebUI
    Sleep    60s
    Perform unblock NR Cell 1 via WebUI
    Wait Until Keyword Succeeds    10 min    30 sec    Check If All Cells Are OnAir
    Log To Console     \start L3 call
    Airphone L3 call    call_type=nsa    cell_id=1    ue_id=11    bearer_id=2
    ...    dl_mbps=700    ul_mbps=100    level=ue_stats_nr

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup for Airphone
    Setup Airphone Env    tl_type=AP_LOOO/tdd_sansa_cmwv/FS/CB010856_2cells_ecpri    cfg=wts.cfg    withCommission=True
