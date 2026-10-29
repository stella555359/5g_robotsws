*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           SISO Coam Test Setup
Test Teardown        SISO Coam Test Teardown
Test Timeout         2h

Resource    ./resource/CB008278_Common_KW.robot

Documentation
...    Author: Zhang Xuewen
...    Contact: xuewen.zhang@nokia-sbell.com
...    squad group:SG_05
...    Feature CB008278 in SBTS23R3 program

Force Tags            RAN_5G_TDD    RAN_5G

*** Variables ***

*** Test Cases ***
#[1]CB008278-B_001_General_SiSo_Commissioning_BTS_Template_Commissioning_for_10MHz_AWHHF

[1]CB008278-B_002_UE_attach_and_peak_TP_at_5GC001116_3ms_long_PUCCH_4DL_256QAM_4UL_256QAM_NSA_Mode_for_10MHz_AWHHF
    [Tags]    SBTS00
    ${cell_list}    create list    ${1}
    Get UE From Init File and Make call    cell_list=${cell_list}    with_peak=${True}    duration=${300}

#[1]CB008278-B_003_UE_attach_and_peak_TP_with_Different_Frame_Structures_5GC001070_CB008406_5GC001116_0ms_DL_256QAM_SA_Mode_for_10MHz_AWHHF
#[1]CB008278-B_004_UE_attach_and_peak_TP_at_5GC001208_frame_structure_long_PUCCH_4DL_256QAM_4UL_64QAM_Enhanced_
#PDSCH_Scheduling_on_Speical_slot_SA_for_10MHz_AWHHF

[1]CB008278-B_005_cell_block_and_unblock_for_10MHz_AWHHF
    [Tags]    SBTS00
    General_SiSo_Cell_block_and_unblock    with_call=${False}
#[1]CB008278-B_010_Manual_SiSo_SM_LTE_RAT_reset_10MHz_AWHHF
#[1]CB008278-B_011_Manual_SiSo_SM_NR_RAT_reset_10MHz_AWHHF


*** Keywords ***
