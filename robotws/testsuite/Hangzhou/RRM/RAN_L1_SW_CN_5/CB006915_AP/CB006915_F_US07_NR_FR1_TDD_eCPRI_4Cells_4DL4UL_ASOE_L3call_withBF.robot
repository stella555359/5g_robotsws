*** Settings ***
Documentation
...    Author: Huang Shujun
...    Contact: shujun.j.huang@nokia-sbell.com
...    Feature: CB006915_A
...    Release: 23R3

Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    SBTS23R1    5G_RAN_TDD    RAN_5G    CLOUD_5G_O_E_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    CRT    SBTS00    QCD_MN_RAN    QCP_RAN_RF
...  shujun.j.huang@nokia-sbell.com  release-23R1
Resource    ../resources/Airphone/Airphone_resource.robot

*** Variables ***
@{ALLOWED_FAULT}

*** Test Cases ***
CB006915_F_US07_NR_FR1_TDD_eCPRI_4Cells_4DL4UL_ASOE_L3call_withBF
    [Documentation]
    ...    This case is used to verify ASOE NR FR1 TDD eCPRI 4 cells L3 call with 4DL4UL 100MHz
    [Tags]
    ue_register    ue_id=1    cell_id=1
    ue_register    ue_id=2    cell_id=2
    ue_register    ue_id=3    cell_id=3
    ue_register    ue_id=4    cell_id=4
    traffic_start_and_throughput_verify    ue_id=1    dl_mbps=100    ul_mbps=100    duration=60
    traffic_start_and_throughput_verify    ue_id=2    dl_mbps=200    ul_mbps=100    duration=60
    traffic_start_and_throughput_verify    ue_id=3    dl_mbps=300    ul_mbps=100    duration=60
    traffic_start_and_throughput_verify    ue_id=4    dl_mbps=900    ul_mbps=100    duration=60
    traffic_data_stop   ue_id=1
    traffic_data_stop   ue_id=2
    traffic_data_stop   ue_id=3
    traffic_data_stop   ue_id=4
    release_ues    ue_id=1-4

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup for Airphone
    Setup Airphone Env  tl_type=tdd_sansa_cmwv/FS/4cells_ecpri
