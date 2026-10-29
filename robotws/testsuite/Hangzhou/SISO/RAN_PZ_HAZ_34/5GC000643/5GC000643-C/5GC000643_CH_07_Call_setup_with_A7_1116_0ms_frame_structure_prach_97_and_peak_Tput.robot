# *** Settings ***
# Suite Setup          SISO Coam Suite Setup
# Suite Teardown       SISO Coam Suite Teardown
# Test Setup
# Test Teardown
# Test Timeout         100 min
# 
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
# Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
# Resource     ${BASIC_PATH_5G}/BTS/General_SiSo_Peak_with_Given_Information.robot
# 
# Documentation
# ...    Author: Annie hu
# ...    Contact: Annie.hu@nokia-sbell.com
# ...    squad group:SG_05
# ...    Feature 5GC000643-CH in 5G21A program
# 
# Force Tags           RAN_5G   RAN_5G_TDD   CLOUD_5G_CLASSICAL_SA_ASIKL_ABILB1_AEQE   STATE_SW_UPLOADED    SBTS00
# ...    PY36
# 
# *** Variables ***
# 
# *** Test Cases ***
# [1][1.0] 5GC000643-CH_07_Call_setup_with_A7_1116_0ms_frame_structure_prach 97_and_peak_Tput
#     [Tags]    master_classicalbts_all    CRT_UTE   CRT_TRUNK   CRT_22R1   CRT_22R2   CRT_22R3   CRT_22R4
#     [Setup]    SISO Coam Test Setup
#     General_SiSo_Peak_with_Given_Information    band=40    frame_structure=1116_0ms_GP2_A7    cell_id=1
#     ...    loop_times=3    duration=300    dl_ul_layer=4DL2UL    beamset=2 beams    prach_index=97
#     [Teardown]    SISO Coam Test Teardown
# 
# *** Keywords ***
