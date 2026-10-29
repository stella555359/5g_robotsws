*** Settings ***
Documentation
...    Author:  Kong Liang
...    Contact: liang.kong@nokia-sbell.com
...    Feature: CB010856
...    Release:

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
CB010856_A_TC01_NR_FR1_TDD_eCPRI_ABIO_ORAN_ODU_conformance testing_CAT_A_NoBF
    [Documentation]
    ...    This case is to verify ORAN DCM TDD SA NR L3 call operateability on ABIO with FR1 TDD eCPRI 2 4DL4UL cell.
    [Tags]    ABIO    CB010856    2cell4D4U    Trunk
    Wait Until Keyword Succeeds    10 min    30 sec    Check If All Cells Are OnAir
    Log To Console     \start L3 call
    Airphone L3 call    call_type=sa    cell_id=1    ue_id=1    bearer_id=2
    ...    dl_mbps=700    ul_mbps=100    level=ue_stats_nr
    Airphone L3 call    call_type=sa    cell_id=2    ue_id=2    bearer_id=2
    ...    dl_mbps=700    ul_mbps=100    level=ue_stats_nr

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup for Airphone
    Setup Airphone Env    tl_type=AP_LOOO/tdd_sansa_cmwv/FS/CB010856_2cells_ecpri    cfg=wts.cfg    withCommission=True
