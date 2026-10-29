*** Settings ***
Documentation
...    Author:  Gao Claire
...    Contact: Claire.gao@nokia-sbell.com
...    Feature: CB010580
...    Release: 25R2

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
CB010580_D_TC05_NR_FR1_TDD_eCPRI_ABIP_DCM_ORAN_100MHz_1CC_4T4R_Cell_Block_Unblock
    [Documentation]
    ...    This case is to verify ORAN DCM TDD NSA NR L3 call operateability on ABIP with FR1 TDD eCPRI 4DL4UL cell.
    [Tags]    ABIP    CB010580    1cell4D4U    Trunk    ORAN     DCM    TC05    CellBlock
    Wait Until Keyword Succeeds    10 min    30 sec    Check If All Cells Are OnAir
    Perform block NR Cell 1 via WebUI
    Perform unblock NR Cell 1 via WebUI
    Wait Until Keyword Succeeds    10 min    30 sec    Check If All Cells Are OnAir
    Log To Console     \start L3 call
    Airphone L3 call    nsa    1    11    2    700    100    ue_stats_nr    60    0.85

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup for Airphone
    Setup Airphone Env    tl_type=AP_LOOO/tdd_sansa_cmwv/FS/DCM_ORAN_ecpri/NoBF    cfg=wts.cfg    withCommission=True
