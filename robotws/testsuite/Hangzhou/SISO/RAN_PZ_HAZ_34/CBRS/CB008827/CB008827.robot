# *** Settings ***
# Suite Setup          CBRS Suite Setup
# Suite Teardown       CBRS Suite Teardown
# Test Setup           CBRS Test Setup
# Test Teardown        CBRS Test Teardown
# 
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
# Resource    ${BASIC_PATH_5G}/General_SiSo_RF_module_reset_from_GUI.robot
# Resource    ../CB007857/resources/CB007857_common_keywords.robot
# Variables    ../CB007857/TestData/7857_variables.py
# 
# Documentation
# ...    Author:Ye Tianyi
# ...    contact:tianyi.ye@nokia-sbell.com
# ...    squad group:SG_08
# ...    Feature CB008827
# 
# Force Tags    SBTS00    CRT_TRUNK    CRT_23R1
# 
# *** Variables ***
# 
# *** Test Cases ***
# [1]General_SiSo_RU_module_reset_from_GUI
#     Start SAS server
#     Wait until keyword succeeds    5min    30s    verify all cells should be onair
#     General_SiSo_RF_module_reset_from_GUI
# 
# [1]CB007857_De-activation of NR CBRS for AEQM
#     Verify_the_CBRS_online_de-activation_is_successful
# 
# [1]CB007857_maxERIP_check_8DL_40MHz
#     CB007857_maxERIP_check_8DL_40MHz
# *** Keywords ***
