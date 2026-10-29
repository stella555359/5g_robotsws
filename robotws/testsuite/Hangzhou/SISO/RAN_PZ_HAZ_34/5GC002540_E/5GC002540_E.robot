*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           SISO Coam Test Setup
Test Teardown        SISO Coam Test Teardown
Test Timeout         400 min

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    ${BASIC_PATH_5G}/Cell/General_SiSo_Cell_lock_and_unlock.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_RU_lock_unlock.robot

Resource    ./resource/5GC002540_E_resource.robot
Variables    TestData/variables.py

Documentation
...    Author:Annie hu
...    contact:Annie.hu@nokia-sbell.com
...    squad group:SG_05
...    Feature 5GC002540-E: ABIO Configurations FR1 TDD eCPRI in 22R1 program
...    Configuration blocks: A5G-TD-3S-2CC-8DL-4UL-FR1-eCPRI-5GC002540-24/25
...    note: current no UE in this TL

Force Tags            5G_RAN_TDD
...    PY36

*** Variables ***

*** Test Cases ***
[1]5GC002540-E_04_5GC002540-25_AEQE_General_SiSo_Cell_lock_and_unlock_with_L3Call
    [Tags]    3S-2CC-8D-4U_100-100M_C4_Split_2540-25    CRT_TRUNK   CRT_22R1   CRT_22R2   CRT_22R3   CRT_22R4
    General_SiSo_Cell_lock_and_unlock    with_call=${True}
    lock_unlock_cells_2CC     cell_1=2    cell_2=5

[1]5GC002540-E_05_5GC002540-25_AEQE_General_SiSo_RU_lock_unlock_with_L3Call
    [Tags]    3S-2CC-8D-4U_100-100M_C4_Split_2540-25    CRT_TRUNK   CRT_22R1   CRT_22R2   CRT_22R3   CRT_22R4
    General_SiSo_RU_lock_unlock    with_call=${False}

#[1]5GC002540-E_03_5GC002540-24_AEQE_General_SiSo_E2E_system_L3Call_peak_throughput_verification
#    [Tags]    3S-2CC-8D-4U_50-50M_C4_2540-24    CRT_TRUNK
#    General_SiSo_E2E_system_setup_with_data_transfer    band=50
#
#
#[1]5GC002540-E_03_5GC002540-25_AEQE_General_SiSo_E2E_system_L3Call_peak_throughput_verification
#    [Tags]    3S-2CC-8D-4U_100-100M_C4_Split_2540-25    CRT_TRUNK
#    General_SiSo_E2E_system_setup_with_data_transfer    band=100
#
#[1]5GC002540-E_02_5GC002540-24_AEQE_General_SiSo_E2E_system_L3Call_setup_with_data_transfer_conducted_with_Mixed_chBw
#    [Tags]    3S-2CC-8D-4U_50-50M_C4_2540-24    CRT_TRUNK
#    ${bandlist}    create list    ${40}    ${50}
#    General_SiSo_E2E_system_setup_with_data_transfer_multi_cc_with_different_bandwith    bandlist=${bandlist}
#    ...    ue_num_each_call=2
#
#[1]5GC002540-E_02_5GC002540-25_AEQE_General_SiSo_E2E_system_L3Call_setup_with_data_transfer_conducted_mixed_chBW
#    [Tags]    3S-2CC-8D-4U_100-100M_C4_Split_2540-25    CRT_TRUNK
#    ${bandlist}    create list    ${20}    ${100}
#    General_SiSo_E2E_system_setup_with_data_transfer_multi_cc_with_different_bandwith    bandlist=${bandlist}
#    ...    ue_num_each_call=2

*** Keywords ***
