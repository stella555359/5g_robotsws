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
# ${BSR_path}    /home/ute/${BSR_name}.zip
# ${BSR_name}    BSR_AAHF_4_H4_ALN60_ARP60_P00_VSPLIT_00422_00001.zip
# 
# *** Test Cases ***
# [1]5GC001866_E_Deactivate_Customer_BSR_WebEM_NSA_Classical_Below_6GHz_gen3_cpri
#     [Documentation]    *****************
#     ...    Basic information
#     ...    *****************
#     ...    this case is to verify BSR package delete in gNB via WEBEM
#     ...    *******************
#     [Tags]    OWNER_fred.li@nokia-sbell.com
#     [Timeout]    60 min
#     [Setup]   Run Keywords    WEBUI Login
#     ...    AND    Get BTS Id online
#     Step1: Check gNB status
#     Step2: Disable 1866
#     Step3: Check Inused BSR
#     Step4: Check gNB and Cell onAir
#     Step5: Make L3 call
#     [Teardown]   Case Teardown
# 
# *** Keywords ***
# Step1: Check gNB status
#     Check gNB and Cell onAir
# 
# Step2: Disable 1866
#     Disable feature 1866
# 
# Step3: Check Inused BSR
#     Check BSR not Inuse
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
