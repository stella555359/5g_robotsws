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
Force Tags    SBTS23R3    5G_RAN_TDD    RAN_5G    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    CRT    SBTS00    QCD_MN_RAN    QCP_RAN_RF
...  yanqing.li@nokia-sbell.com  release-23R3
Resource    ../resources/Airphone/Airphone_resource.robot
Resource    ../resources/common_resource_bts.robot
*** Variables ***
@{ALLOWED_FAULT}

*** Test Cases ***
CB008360_2UE_with_rank2_MU_paired
    [Documentation]
    ...    This case is used to verify  verify UL MU-MIMO scenario with 2xrank2 UE MU paired
    [Tags]
    Perform Egate Command    ul_mimo_srs_beam_pos_nr profile_id=2 mode=fixed init_quad_pos=0 init_sub_quad_pos=3 step=5 trigger_puxch_update=0
    Perform Egate Command    ul_mimo_srs_beam_pos_nr profile_id=3 mode=fixed init_quad_pos=1 init_sub_quad_pos=2 step=5 trigger_puxch_update=0
    ue_register    ue_id=1    cell_id=1
    Perform Egate Command    ue_testmode_set_nr id=1 testmode=ul_mimo_srs_beam_pos action=activate profile_id=2 scell=0
    traffic_start_and_throughput_verify    ue_id=1    ul_mbps=130    duration=60
    ue_register    ue_id=2    cell_id=1
    Perform Egate Command    ue_testmode_set_nr id=2 testmode=ul_mimo_srs_beam_pos action=activate profile_id=3 scell=0
    traffic_start_and_throughput_verify    ue_id=2    ul_mbps=130    duration=60

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup for Airphone
    Get BSR package
    Load and active BSR
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpril_mimo    cfg=wts.cfg
