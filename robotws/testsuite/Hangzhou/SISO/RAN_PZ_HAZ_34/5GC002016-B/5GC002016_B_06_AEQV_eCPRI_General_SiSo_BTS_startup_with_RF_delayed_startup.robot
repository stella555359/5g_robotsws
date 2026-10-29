# *** Settings ***
# Suite Setup          SISO Coam Suite Setup
# Suite Teardown       SISO Coam Suite Teardown
# Test Setup           SISO Coam Test Setup
# Test Teardown        SISO Coam Test Teardown
# Test Timeout         100 min
# 
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
# Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
# Resource    ${BASIC_PATH_5G}/General_SiSo_BTS_startup_with_RF_delayed_startup.robot
# Variables    TestData/variables.py
# 
# Documentation
# ...    Author:Annie hu
# ...    contact:Annie.hu@nokia-sbell.com
# ...    squad group:SG_05
# ...    Feature 5GC002016-B in 5G21A program
# 
# Force Tags            5G_RAN_TDD
# ...    PY36
# 
# *** Variables ***
# 
# *** Test Cases ***
# [1]5GC002016_B_06_AEQV_eCPRI_General_SiSo_BTS_startup_with_RF_delayed_startup
#     [Tags]    CRT_TRUNK    CRT_22R1    CRT_22R2    CRT_22R3    CRT_22R4
#     General_SiSo_BTS_startup_with_RF_delayed_startup
# 
# *** Keywords ***
