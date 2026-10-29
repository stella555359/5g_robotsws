*** Settings ***
Documentation
...    Author:  Kong Liang
...    Contact: liang.kong@nokia-sbell.com
...    Feature: CB008205
...    Release: 24R1
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
CB008205_B_TC01_NR_FR1_FDD_eCPRI_ABIO_ORAN_SA_L3Call_20Mhz_1CC_4T4R_User_Plane_Traffic
    [Documentation]
    ...    This case is to verify ORAN DCM TDD SA NR L3 call operateability on ABIO with FR1 TDD eCPRI 2 4DL4UL cell.
    [Tags]    ABIO    CB008205    1cell4D4U    Trunk
    Wait Until Keyword Succeeds    10 min    30 sec    Check If All Cells Are OnAir
    Log To Console     \start L3 call
    Airphone L3 call    call_type=sa    cell_id=1    ue_id=1    bearer_id=2
    ...    dl_mbps=400    ul_mbps=200    level=ue_stats_nr
    Airphone L3 call    call_type=sa    cell_id=2    ue_id=2    bearer_id=2
    ...    dl_mbps=200    ul_mbps=200    level=ue_stats_nr

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup for Airphone
    Setup Airphone Env    tl_type=AP_LOOO/fdd_sansa_cmwv/FS/CB008205_2cells_ecpri    cfg=wts.cfg    withCommission=True
