# *** Settings ***
# Suite Setup          SISO Coam Suite Setup
# Suite Teardown       SISO Coam Suite Teardown
# Test Setup           SISO Coam Test Setup
# Test Teardown        SISO Coam Test Teardown
# Test Timeout         12h
# 
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
# Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
# Resource    ${BASIC_PATH_5G}/Baseband_module_reset_via_WEBUI.robot
# Resource    ${BASIC_PATH_5G}/Cell/General_SiSo_Cell_block_and_unblock.robot
# Resource    ${BASIC_PATH_5G}/General_SiSo_RU_lock_unlock.robot
# Documentation
# ...    Author:liu yue
# ...    contact:yue.2.liu@nokia-sbell.com
# ...    squad group:SG_05
# ...    Feature SRAN in 23R2 program
# 
# *** Variables ***
# 
# *** Test Cases ***
# 
# [1]CB008325-5G-A_30_General_SiSo_BB_sub-unit_reset_with_L3_call
#     [Tags]    CRT_TRUNK
#     Baseband_module_reset_via_WEBUI    with_call=${False}
# 
# [1]CB008325-5G-A_05_General_SiSo_Cell_block_and_unblock_with_L3call
#     [Tags]    CRT_TRUNK
#     General_SiSo_Cell_block_and_unblock    with_call=${False}
# 
# [1]CB008325-5G-A_06_Manual_SiSo_SM_RF_Module_lock_unlock
#     [Tags]    CRT_TRUNK
#     General_SiSo_RU_lock_unlock    with_call=${False}
# *** Keywords ***
