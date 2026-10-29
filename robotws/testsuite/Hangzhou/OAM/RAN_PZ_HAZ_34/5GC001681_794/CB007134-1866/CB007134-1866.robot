# *** Settings ***
# Documentation
# ...   author:Fred Li
# ...   contact: fred.li@nokia-sbell.com
# Resource   ../resources${/}case_steps.robot
# Resource    ../resources/BSR.robot
# Resource    ../../common${/}coam_resource.robot
# Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_log.robot
# 
# Force Tags   SG_08   CA_5G_OAM         CRT
# ...    PY36
# 
# *** Variables ***
# 
# 
# *** Test Cases ***
# [1]CB007134-5G-B-5GC001866_Predefine_beamset_with_CMW_RU
#     [Documentation]    *****************
#     ...    Basic information
#     ...    *****************
#     ...    this case is to verify BSR package upload to gNB via WEBEM
#     ...    *******************
#     [Tags]    OWNER_fred.li@nokia-sbell.com
#     [Timeout]    60 min
#     [Setup]       Run Keywords    robot_common_operations.Common Case Setup
#     ...   AND   WEBUI Login
#     ...    AND    Get BTS Id online
#     Step1: Check gNB status
#     Read Current RU Type
#     Step2: Download BSR package
#     Step4: Check installed BSR
#     Check gNB and Cell onAir
#     Check If there is new alarm
#     Step5: Make L3 call
#     [Teardown]   Case Teardown
# 
# [1]CB007134-5G-B-5GC001866_Activate_BSR_with_CMW_RU
#     [Documentation]    *****************
#     ...    Basic information
#     ...    *****************
#     ...    this case is to verify BSR package upload to gNB via WEBEM
#     ...    *******************
#     [Tags]    OWNER_fred.li@nokia-sbell.com
#     [Timeout]    60 min
#     [Setup]       Run Keywords   robot_common_operations.Common Case Setup
#     ...   AND   WEBUI Login
#     ...    AND    Get BTS Id online
#     Check gNB and Cell onAir
#     Read Current RU Type
#     Download BSR package
#     Check installed BSR
#     Activate BSR through WebEM
#     Check Inused BSR
#     Check gNB and Cell onAir
#     Check If there is new alarm
#     L3 call Integration
#     [Teardown]   Case Teardown
# 
# 
# [1]CB007134-5G-B-5GC001866_Deactivate_BSR_with_CMW_RU
#     [Documentation]    *****************
#     ...    Basic information
#     ...    *****************
#     ...    this case is to verify BSR package delete in gNB via WEBEM
#     ...    *******************
#     [Tags]    OWNER_fred.li@nokia-sbell.com
#     [Timeout]    60 min
#     [Setup]   Run Keywords   robot_common_operations.Common Case Setup
#     ...   AND   WEBUI Login
#     ...    AND    Get BTS Id online
#     Check gNB and Cell onAir
#     Read Current RU Type
#     Disable feature 1866
#     Delete BSR XML
#     Check gNB and Cell onAir
#     Check If there is new alarm
#     L3 call Integration
#     [Teardown]      Run Keywords    robot_common_operations.Common Case Teardown
#     ...   AND   Run Keyword and Ignore Error   COAM WEBUI Logout
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
# Step5: Make L3 call
#     L3 call Integration
# 
# Step2: Activate BSR through WebEM
#     Activate BSR through WebEM
# 
# Step3: Check Inused BSR
#     Check Inused BSR
# 
# Case Teardown
#     robot_common_operations.Common Case Teardown
#     Close feature 1866
#     Delete BSR XML
#     Check Extra Reset From Blackbox
#     run keyword and ignore error   Run Keyword and Ignore Error   COAM WEBUI Logout
