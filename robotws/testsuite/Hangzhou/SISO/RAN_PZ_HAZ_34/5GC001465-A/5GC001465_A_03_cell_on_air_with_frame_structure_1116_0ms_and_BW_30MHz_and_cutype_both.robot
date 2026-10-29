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
# ...    Feature 5GC0001465-A in 5G21A program
# 
# Force Tags     RAN_5G   RAN_5G_TDD   CLOUD_5G_CLASSICAL_SA_ASIKL_ABILB1_AEQE   STATE_SW_UPLOADED    SBTS00
# ...    PY36
# 
# *** Variables ***
# 
# *** Test Cases ***
# [1][1.0] 5GC001465_A_03_cell_on_air_with_frame_structure_1116_0ms_and_BW_30MHz_and_cutype_both
#     [Documentation]  recommission with commissionings/HGZ/7_5_UTE5G402Txxx/SCF_SBTS00_1S-1CC-4D2U_30M_both.xml or
#     ...    SCF_11.800_1S-1CC-4D2U_30M_both.xml if current configure not meets, refer to case tag:1S-1CC-4D2U_30M_both
#     [Tags]    1S-1CC-4D2U_30M_both    CRT_22R2    CRT_TRUNK   CRT_22R1   CRT_22R3   CRT_22R4    CRT_UTE    master_classicalbts_all
#     [Setup]    SISO Coam Test Setup
#     General_gnb_can_be_on_air_with_Given_Information    band=30    frame_structure=1116_0ms_GP1_A8    enable_2197=False
#     [Teardown]    SISO Coam Test Teardown
# 
# *** Keywords ***
