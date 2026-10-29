# *** Settings ***
# Documentation
# ...   author:Fred Li
# ...   contact: fred.li@nokia-sbell.com
# Resource   resources${/}case_steps.robot
# Resource    resources/BSR.robot
# Resource    ../common/coam_resource.robot
# Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_log.robot
# Force Tags   SG_08   CA_5G_OAM         CRT
# ...    PY36
# 
# *** Variables ***
# 
# 
# *** Test Cases ***
# [1]5GC001866_E_Activate_BSR_to_gNB_through_parameter_WebEM_NSA_Classical_Below_6GHz_gen3_cpri
#     [Documentation]    *****************
#     ...    Basic information
#     ...    *****************
#     ...    this case is to activate BSR package to gNB via WEBEM
#     ...    *******************
#     [Tags]    OWNER_fred.li@nokia-sbell.com
#     [Timeout]    60 min
#     [Setup]   Run Keywords    WEBUI Login
#     ...    AND    Get BTS Id online
#     Step1: Check gNB status
#     Read Current RU Type
#     Step2: Activate BSR through WebEM
#     Step3: Check Inused BSR
#     Step4: Check gNB and Cell onAir
#     Step5: Make L3 call
#     [Teardown]   Case Teardown
# 
# *** Keywords ***
# Step1: Check gNB status
#     Check gNB and Cell onAir
# 
# Step2: Activate BSR through WebEM
#     Activate BSR through WebEM
# 
# Step3: Check Inused BSR
#     Check Inused BSR
# 
# Step4: Check gNB and Cell onAir
#     Check gNB and Cell onAir
#     Check If there is new alarm
# 
# Step5: Make L3 call
#     L3 call Integration
# 
# Case Teardown
#     Disable feature 1866
#     Delete BSR XML
#     Check Extra Reset From Blackbox
#     run keyword and ignore error   Run Keyword and Ignore Error   COAM WEBUI Logout
