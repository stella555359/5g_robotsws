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
# [1]5GC001866_E_Upload_BSR_to_gNB_WebEM_NSA_Classical_Below_6GHz_gen3_cpri
#     [Documentation]    *****************
#     ...    Basic information
#     ...    *****************
#     ...    this case is to verify BSR package upload to gNB via WEBEM
#     ...    *******************
#     [Tags]    OWNER_fred.li@nokia-sbell.com
#     [Timeout]    30 min
#     [Setup]   Run Keywords    WEBUI Login
#     ...    AND    Get BTS Id online
#     Step1: Check gNB status
#     Read Current RU Type
#     Step2: Download BSR package
#     Step3: Enable feature 1866
#     Step4: Check installed BSR
#     Step5: Check gNB and Cell onAir
#     [Teardown]   Case Teardown
# 
# *** Keywords ***
# Step1: Check gNB status
#     Check gNB and Cell onAir
# 
# 
# Step2: Download BSR package
#     Download BSR package
# 
# Step3: Enable feature 1866
#     Enable feature 1866
# 
# Step4: Check installed BSR
#     Check installed BSR
# 
# Step5: Check gNB and Cell onAir
#     Check gNB and Cell onAir
#     Check If there is new alarm
# 
# Case Teardown
#     Close feature 1866
#     Delete BSR XML
#     Check Extra Reset From Blackbox
#     run keyword and ignore error   Run Keyword and Ignore Error   COAM WEBUI Logout
