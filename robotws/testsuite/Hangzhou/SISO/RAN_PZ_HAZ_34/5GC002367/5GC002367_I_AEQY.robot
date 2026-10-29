# *** Settings ***
# Suite Setup          SISO Coam Suite Setup
# Suite Teardown       SISO Coam Suite Teardown
# Test Setup           SISO Coam Test Setup
# Test Teardown        SISO Coam Test Teardown
# Test Timeout         100 min
# 
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
# Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
# Resource    ${BASIC_PATH_5G}/BTS/General_SiSo_Peak_with_Given_Information.robot
# #Resource    ${BASIC_PATH_5G}/General_gnb_can_be_on_air_with_Given_Information.robot
# 
# Documentation
# ...    Author: zhihao shi
# ...    Contact: zhihao.shi@nokia-sbell.com
# ...    squad group:SG_04
# ...    Feature 5GC002367-I in 5G21A program
# 
# Force Tags            5G_RAN_TDD    5G_RAN_TDD    RAN_5G_TDD    RAN_5G    STATE_SW_UPLOADED   CLOUD_5G_CLASSICAL_ASIKL_ABILB1_AEQY
# ...    PY36
# 
# *** Variables ***
# 
# *** Test Cases ***
# #[1][1.0] 5GC001076-KF_01_gnb_can_be_onair_with_cBW_50Mhz_eCPRI
# #    General_gnb_can_be_on_air_with_Given_Information    band=50    frame_structure=1116_3ms_GP1_A5
# #
# [1][1.0] 5GC001076-KF_03_peak_Tput_with_Cbw_50Mhz_256QAM_eCPRI
#     [Tags]    CRT_TRUNK    SBTS00    master_classicalbts_all   CRT_UTE
#     General_SiSo_Peak_with_Given_Information    band=50    frame_structure=1116_3ms_GP1_A5
#     ...    suite_name=${SUITE NAME}    test_name=${TEST NAME}
# 
# #[1][1.0] 5GC001076-KF_02_peak_Tput_with_Cbw_50Mhz_64QAM_eCPRI
# #    General_SiSo_Peak_with_Given_Information    band=50    frame_structure=1116_3ms_GP1_A5    prach_index=157
# #    ...    dl_modulation=dl_64QAM
# 
# *** Keywords ***
