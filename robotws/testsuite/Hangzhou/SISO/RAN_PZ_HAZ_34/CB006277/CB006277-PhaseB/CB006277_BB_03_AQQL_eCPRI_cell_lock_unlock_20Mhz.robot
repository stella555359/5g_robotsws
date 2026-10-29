# *** Settings ***
# Suite Setup          SISO Coam Suite Setup
# Suite Teardown       SISO Coam Suite Teardown
# Test Setup           SISO Coam Test Setup
# Test Teardown        SISO Coam Test Teardown
# Test Timeout         100 min
# 
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
# Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
# Resource    ${BASIC_PATH_5G}/Cell/General_SiSo_Cell_block_and_unblock.robot
# Resource     ../resource/resources_l3call.robot
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
# [1]CB006277_BB_03_AQQL_eCPRI_cell_lock_unlock_20Mhz
#     [Tags]    master_classicalbts_all    CRT_TRUNK    CRT_22R3    CRT_22R4
#     Modify_Band_Frame_Structure    band=20    beamset=2 beams
#     ...    frame_structure=1116_0ms_GP1_A8    prach_index=195
#     sleep    5s
#     General_SiSo_Cell_block_and_unblock    with_call=${False}
#     sleep    3s
#     ${cell_list}    create list    ${1}
#     Get UE info and do L3 Call    cell_list=${cell_list}    with_peak=${False}
# *** Keywords ***
