# *** Settings ***
# Suite Setup          SISO Coam Suite Setup
# Suite Teardown       SISO Coam Suite Teardown
# Test Setup
# Test Teardown        
# Test Timeout         100 min
# 
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
# Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
# Resource    ${BASIC_PATH_5G}/BTS/General_SiSo_Peak_with_Given_Information.robot
# 
# Documentation
# ...    Author: Annie hu
# ...    Contact: Annie.hu@nokia-sbell.com
# ...    squad group:SG_05
# ...    Feature CB005750-5G-EDAJ in 5G21A program
# 
# Force Tags            5G_RAN_TDD    STATE_GNB_COMMISSIONED    CLOUD_5G_CLASSICAL_ASIKL_ABILB1_AEQE_ENB
# ...    PY36
# 
# *** Variables ***
# 
# *** Test Cases ***
# [1]CB005750-EDAJ_data_traffic_peak_throughput_LAenabled_MIMO4x4_256QAM_chbw_60MHz
#     [Tags]    master_classicalbts_all    CRT_TRUNK   CRT_22R2   CRT_22R3   CRT_22R4
#     [Setup]    SISO Coam Test Setup
#     General_SiSo_Peak_with_Given_Information     band=60    frame_structure=1116_0ms_GP2_A7
#     [Teardown]    SISO Coam Test Teardown
# 
# 
# 
# *** Keywords ***
