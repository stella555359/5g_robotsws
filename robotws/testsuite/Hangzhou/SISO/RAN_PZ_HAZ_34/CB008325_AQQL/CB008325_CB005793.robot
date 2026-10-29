# *** Settings ***
# Suite Setup          SISO Coam Suite Setup
# Suite Teardown       SISO Coam Suite Teardown
# Test Setup           #SISO Coam Test Setup
# Test Teardown        #SISO Coam Test Teardown
# Test Timeout         120 min
# 
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
# Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
# Resource    ${BASIC_PATH_5G}/General_SiSo_cpri_eCPRI_switch_on_WebEM.robot
# 
# #Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/get_case_variables.py
# #Variables   TestData/case_variables.yml
# 
# Documentation
# ...    Author: Liu Yue
# ...    Contact: yue.2.liu@nokia-sbell.com
# ...    squad group:SG_05
# ...    Feature CB008325-CB005793 in SBTS23R3 program
# 
# Force Tags     RAN_5G     RAN_5G_TDD    STATE_SW_UPLOADED    SBTS00    PY36    master_classicalbts_all
# 
# *** Variables ***
# 
# *** Test Cases ***
# [1]General_SiSo_upgrade_from_CPRI_to_eCPRI
#     [Tags]    CRT_TRUNK
#     [Setup]    SISO Coam Test Setup
#     General_SiSo_cpri_eCPRI_switch_on_WebEM    cell_id=1    switch_to_radio_protocol=ECRI
#     [Teardown]    SISO Coam Test Teardown
# 	
# #[1]CB008325-SR-AB7-B1_01_General_SiSo_upgrade_from_CPRI_to_eCPRI
# 	
# #[1]CB008325-SR-AB7-B1_02_General_SiSo_upgrade_from_eCPRI_to_CPRI
# 
# 
# *** Keywords ***
