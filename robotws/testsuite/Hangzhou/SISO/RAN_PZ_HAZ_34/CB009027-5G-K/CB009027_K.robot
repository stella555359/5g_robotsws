# *** Settings ***
# Suite Setup          SISO Coam Suite Setup
# Suite Teardown       SISO Coam Suite Teardown
# Test Setup           SISO Coam Test Setup
# Test Teardown        SISO Coam Test Teardown
# Test Timeout         2h
# 
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
# Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
# Resource    ./resource/CB009027_Common_KW.robot
# 
# Documentation
# ...    Author: Zhang Xuewen
# ...    Contact: xuewen.zhang@nokia-sbell.com
# ...    squad group:SG_05
# ...    Feature CB009027 in SBTS23R3 program
# 
# Force Tags            5G_RAN    5G_RAN_TDD    RAN_5G_TDD    RAN_5G
# 
# *** Variables ***
# 
# *** Test Cases ***
# [1]CB009027-5G-K_01_General_SiSo_Cell_block_and_unblock_with_5GC001086_enabled_4x8DL4UL_100M
#     [Tags]    SBTS00    2S-2CC-8D-4U
#     General_SiSo_Cell_block_and_unblock_with_5GC001086_enabled_4x8DL4UL_100M
# 
# [1]CB009027-5G-K_05_Manual_SiSo_SM_RF_Module_lock_unlock_with_5GC001086_enabled_4x8DL4U_100M
#     [Tags]    SBTS00    2S-2CC-8D-4U
#     Manual_SiSo_SM_RF_Module_lock_unlock_with_5GC001086_enabled_4x8DL4U_100M
# 
# *** Keywords ***
