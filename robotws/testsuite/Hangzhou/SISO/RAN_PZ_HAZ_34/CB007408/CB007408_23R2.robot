# *** Settings ***
# Suite Setup          SISO Coam Suite Setup
# Suite Teardown       SISO Coam Suite Teardown
# Test Setup           SISO Coam Test Setup
# Test Teardown        SISO Coam Test Teardown
# 
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
# Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
# Resource    ${BASIC_PATH_5G}/BTS/General_SiSo_Peak_with_Given_Information.robot
# Resource    ./Resources/CB007408_keywords.robot
# Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB006502_CB007833/Resources/CB006502_Keywords.robot
# Variables    ./TestData/variables_7408.py
# 
# 
# Documentation
# ...    Author: Melinda
# ...    Contact: meinda.gao@nokia-sbell.com
# ...    squad group:SG_08
# ...    Feature CB007408 AENB eCPRI
# 
# Force Tags    CRT_23R2
# ...    PY36
# 
# *** Variables ***
# @{band1}    40M
# @{band2}    60M
# @{band3}    80M
# *** Test Cases ***
# 
# [1]General_SiSo_Auto_E2E_system_setup_with_data_transfer_conducted_80M
#     [Tags]    CRT_TRUNK    CRT_22R2
#     7408_dataTransfer_80M
# #    Commission SCF With Specific Band If Needed    band=${band3}
# #    COAM Wait gnb And Cells ready    timeout=15 min    gnb_type='${gNb_CuType}'
# #    General_SiSo_Peak_with_Given_Information    band=80    frame_structure=1116_0ms_GP2_A7    iperf_type=via_command    enable_2197=${False}
# 
# *** Keywords ***
