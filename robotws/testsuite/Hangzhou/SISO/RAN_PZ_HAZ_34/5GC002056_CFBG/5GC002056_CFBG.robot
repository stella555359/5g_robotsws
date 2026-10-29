*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup
Test Teardown        
Test Timeout         100 min

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_RU_lock_unlock.robot
Resource     ${BASIC_PATH_5G}/BTS/General_SiSo_Peak_with_Given_Information.robot

Documentation
...    Author: Annie hu
...    Contact: Annie.hu@nokia-sbell.com
...    squad group:SG_05
...    Feature 5GC000643-CB in 5G21A program

Force Tags            5G_RAN_TDD
...    PY36

*** Variables ***

*** Test Cases ***
[1][1.0] 5GC002056_CFBG_018_NSA_UL_and_DL_traffic_QAM256_2X2MIMO_with_frame_structure_1116_and_60MHz_without_BF
    [Tags]    master_classicalbts_all    CRT_TRUNK    CRT_21A    CRT_21B
    [Setup]    SISO Coam Test Setup
    #General_Peak_with_Given_Frame_Structure         frame_structure==1116_0ms_GP2_A7      dl_ul_layer=2DL2UL
    General_SiSo_Peak_with_Given_Information     band=60     frame_structure=1116_0ms_GP1_A7     prach_index=156
    ...    beamset=single beam   dl_ul_layer=2DL2UL    dl_modulation=dl_256QAM
    [Teardown]    SISO Coam Test Teardown


[1][1.0] 5GC002056_CFBG_018_SA_UL_and_DL_traffic_QAM256_2X2MIMO_with_frame_structure_1116_and_40MHz_without_BF
    [Tags]    master_classicalbts_all   CRT_TRUNK    CRT_21A    CRT_21B
    [Setup]    SISO Coam Test Setup
    General_SiSo_Peak_with_Given_Information     band=40     frame_structure=1116_0ms_GP1_A7     prach_index=156
    ...    beamset=single beam   dl_ul_layer=2DL2UL    dl_modulation=dl_256QAM
   [Teardown]    SISO Coam Test Teardown

[1][1.0] 5GC002056_CFBG_018_SA_UL_and_DL_traffic_QAM256_2X2MIMO_with_frame_structure_1116_and_50MHz_without_BF
    [Tags]    master_classicalbts_all   CRT_TRUNK    CRT_22R3    CRT_22R2   CRT_22R1
    [Setup]    SISO Coam Test Setup
    #General_SiSo_E2E_system_setup_with_data_transfer     band=50     prach_index=156
    #...    beamset=single beam   dl_ul_layer=2DL2UL    dl_modulation=dl_256QAM
    General_SiSo_Peak_with_Given_Information    band=50     frame_structure=1116_0ms_GP1_A7
    ...    prach_index=156     beamset=single beam    dl_ul_layer=2DL2UL     dl_modulation=dl_256QAM
   [Teardown]    SISO Coam Test Teardown

[1]5GC002056_CFBG_04_AEQE_eCPRI_General_SiSo_RU_lock_and_unlock_with_L3call
   [Tags]    master_classicalbts_all   CRT_TRUNK    CRT_22R1   CRT_22R2   CRT_22R3
    [Setup]    SISO Coam Test Setup
    General_SiSo_RU_lock_unlock
   [Teardown]    SISO Coam Test Teardown


[1][1.0] 5GC002056_CFBG_017_NSA_UL_and_DL_traffic_peak_Tput_QAM256_4X4MIMO_with_frame_structure_1116_and_60MHz
    [Documentation]
    ...   Configuration: NSA_4X4
    [Tags]    master_classicalbts_all    CRT_TRUNK    CRT_22R1   CRT_22R2   CRT_22R3
    [Setup]    SISO Coam Test Setup
    #General_SiSo_E2E_system_setup_with_data_transfer     band=60
    General_SiSo_Peak_with_Given_Information    band=60    frame_structure=1116_0ms_GP1_A7
    [Teardown]    SISO Coam Test Teardown


[1][1.0] 5GC002056_CFBG_019_NSA_UL_and_DL_mass_traffic_QAM256_4X4MIMO_with_frame_structure_1208_and_40MHz
    [Documentation]
    ...   Configuration: NSA_4X4
    [Tags]    master_classicalbts_all   CRT_22R3    CRT_22R2    CRT_TRUNK    CRT_22R1
    [Setup]    SISO Coam Test Setup
    #General_Peak_with_Given_Frame_Structure      frame_structure=1208_GP1_A1
    General_SiSo_Peak_with_Given_Information     band=40    frame_structure=1208_GP1_A1
    [Teardown]    SISO Coam Test Teardown
    
    
*** Keywords ***
