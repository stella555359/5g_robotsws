# *** Settings ***
# Documentation
# ...    author: Kaijia Chen
# ...    contact: kaijia.chen@nokia-sbell.com
# ...    squad group: VRF3_SG04
# ...    feature : CB009183
# 
# 
# Resource    ./Resources/CB009903_A_B1_common_keywords.robot
# Resource    ./Resources/Modify_SCF.robot
# Library     ./Resources/CB009903_A_B1_common_keywords.py
# Library    SSHLibrary
# 
# 
# Suite Setup       CB009183 Suite Setup
# Suite Teardown
# 
# *** Test Cases ***
# [1]CB009903-SR-A-B1_01_AWEUB_migration_rule_for_VoltThreshold_from_23R4_to_24R3_and_Critical_Fault_2919_trigger_and_recover
#     [Tags]  CRT_TRUNK
#     [Setup]  Case Setup
#     Test1
#     [Teardown]   Case Teardown
# 
# 
# *** Keywords ***
# 
