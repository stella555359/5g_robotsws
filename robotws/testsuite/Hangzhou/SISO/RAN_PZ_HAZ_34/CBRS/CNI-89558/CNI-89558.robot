# *** Settings ***
# Suite Setup          CNI-89558 CBRS Suite Setup
# Suite Teardown       CBRS Suite Teardown
# Test Setup           CBRS Test Setup
# Test Teardown        CBRS Test Teardown
# 
# Resource    resources/CNI-89558_common_keywords.robot
# 
# Documentation
# ...    Author:wangqingqing
# ...    contact:qingqing.wang@nokia-sbell.com
# ...    squad group:SG_08
# ...    Feature CNI-89558
# 
# Force Tags    SBTS00    CRT_23R1
# ...   PY36
# 
# *** Variables ***
# 
# *** Test Cases ***
# [1]CNI-89558_1_Activation of NR CBRS with two CBSD cells on one AEQM_40MHz+20MHz
#     [Tags]    CRT_TRUNK
#     CNI-89558_1_Activation of NR CBRS with two CBSD cells on one AEQM_40MHz+20MHz
# 
# [1]CNI-89558_2_Online_add_one_same_priority_CBRS_cell
#     [Tags]    CRT_TRUNK
#     CNI-89558_2_Online_add_one_same_priority_CBRS_cell
# 
# [1]CNI-89558_6_Online_upgrade_combination_from 20MHz+20MHz_to_40MHz+20MHz
#     [Tags]    CRT_TRUNK
#     CNI-89558_6_Online_upgrade_combination_from 20MHz+20MHz_to_40MHz+20MHz
# 
# *** Keywords ***
