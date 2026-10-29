# *** Settings ***
# Suite Setup          SISO Coam Suite Setup
# Suite Teardown       SISO Coam Suite Teardown
# Test Setup
# Test Teardown
# Test Timeout         100 min
# 
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
# Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
# Resource    ${BASIC_PATH_5G}/General_gnb_can_be_on_air_with_Given_Information.robot
# 
# Documentation
# ...    Author: Annie hu
# ...    Contact: Annie.hu@nokia-sbell.com
# ...    squad group:SG_05
# ...    Feature 5GC000643-CG in 5G21A program
# ...    Configurtion:1S-2CC-4DL-2UL for ASIK+ABIL+AEQE eCPRI
# 
# Force Tags            5G_RAN_TDD
# ...    PY36
# 
# *** Variables ***
# 
# *** Test Cases ***
# [1]5GC000643-CG_01_gnb_can_be_on_air_with_Dual_carrier_40+40Mhz_eCPRI
#     [Tags]    1S-2CC-4D2U_40-40M    CRT_TRUNK   CRT_23R1   CRT_23R2   CRT_22R4
#     [Setup]    SISO Coam Test Setup
#     General_gnb_can_be_on_air_with_Given_Information    band=40   frame_structure=1208_GP1_A1   dl_ul_layer=4DL2UL
#     [Teardown]   SISO Coam Test Teardown
# 
# #[1]5GC000643-CG_02_peak_Tput_with_Dual_carrier_40+40Mhz_eCPRI
# #    [Tags]    1S-2CC-4D-2U
# #    [Setup]    SISO Coam Test Setup
# #    General_SiSo_E2E_system_setup_with_data_transfer    band=40   beamset=2 beams   dl_ul_layer=4DL2UL
# #    [Teardown]   SISO Coam Test Teardown
# #
# #[1]5GC000643-CG_03_cell_lock_unlock_with_Dual_carrier_40+40Mhz_eCPRI
# #    [Tags]    1S-2CC-4D-2U
# #    [Setup]    SISO Coam Test Setup
# #    General_SiSo_Cell_lock_and_unlock    with_call=${True}    with_peak=${False}
# #    [Teardown]   SISO Coam Test Teardown
# 
# *** Keywords ***
