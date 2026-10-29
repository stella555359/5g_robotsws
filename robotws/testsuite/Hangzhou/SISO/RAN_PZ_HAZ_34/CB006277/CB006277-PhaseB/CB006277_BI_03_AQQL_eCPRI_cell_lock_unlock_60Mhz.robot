# *** Settings ***
# Suite Setup          SISO Coam Suite Setup
# Suite Teardown       SISO Coam Suite Teardown
# Test Setup           SISO Coam Test Setup
# Test Teardown        SISO Coam Test Teardown
# Test Timeout         100 min
# 
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
# Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
# Resource    ${BASIC_PATH_5G}/General_gnb_can_be_on_air_with_Given_Information.robot
# Resource    ${BASIC_PATH_5G}/Cell/General_SiSo_Cell_lock_and_unlock.robot
# 
# Variables    TestData/variables.py
# Documentation
# ...    Author: Liu Yue
# ...    Contact: yue.2.liu@nokia-sbell.com
# ...    squad group:SG_05
# ...    Feature CB006277 in 5G22R1 program
# 
# Force Tags    RAN_5G_TDD
# ...    PY36
# 
# *** Variables ***
# 
# 
# *** Test Cases ***
# 
# [1]CB006277_BI_03_AQQL_eCPRI_cell_lock_unlock_60Mhz
#     [Tags]    master_classicalbts_all    CRT_TRUNK    CRT_22R3
#     General_gnb_can_be_on_air_with_Given_Information    band=60    beamset=2 beams
#     ...    frame_structure=1116_0ms_GP1_A8
#     General_SiSo_Cell_lock_and_unlock    with_call=${True}
#   
# 
# *** Keywords ***
