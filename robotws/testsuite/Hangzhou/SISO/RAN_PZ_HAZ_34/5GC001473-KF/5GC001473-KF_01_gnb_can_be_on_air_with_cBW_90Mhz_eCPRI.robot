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
# Variables    TestData/variables.py
# 
# Documentation
# ...    Author: Annie hu
# ...    Contact: Annie.hu@nokia-sbell.com
# ...    squad group:SG_05
# ...    Feature 5GC0001473-KF in 5G21A program
# 
# Force Tags     RAN_5G   RAN_5G_TDD   CLOUD_5G_CLASSICAL_SA_ASIKL_ABILB1_AEQE   STATE_SW_UPLOADED    SBTS00
# ...    PY36
# 
# *** Variables ***
# 
# *** Test Cases ***
# [1][1.0] 5GC001473-KF_01_gnb can be on air with cBW 90Mhz_eCPRI
#     [Tags]   master_classicalbts_all   CRT_UTE    CRT_22R2    CRT_22R3    CRT_TRUNK   CRT_22R1    CRT_22R4
#     [Setup]    SISO Coam Test Setup
#     General_gnb_can_be_on_air_with_Given_Information    band=90    frame_structure=1116_0ms_GP1_A8
#     [Teardown]    SISO Coam Test Teardown
# 
# *** Keywords ***
