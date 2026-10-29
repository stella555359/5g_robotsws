# *** Settings ***
# Documentation
# ...    author: y6lu
# ...    contact: lu.yu@nokia-sbell.com
# ...    Description:
# 
# 
# Resource          ./Resources/CNI85020_Common_KW.robot
# 
# Suite Setup    robot_common_operations.Common Suite Setup
# Suite Teardown    robot_common_operations.Common Suite Teardown
# 
# Force Tags
# Test Timeout
# 
# Resource    ../common/taf_coam.robot
# *** Variables ***
# ${WEBUI_ADDR}    ${tl.gnbs[0].cu.oam_http_connection_details.addr}
# ${WEBUI_USER}    ${tl.gnbs[0].cu.oam_http_connection_details.username}
# ${WEBUI_PASSWORD}    ${tl.gnbs[0].cu.oam_http_connection_details.password}
# 
# @{ul}    [BBMOD_R-1(ABIN)] [PCI: 112]NRCELL-2: Subcell 1
# @{dl}    [BBMOD_R-1(ABIN)] [PCI: 112]NRCELL-2: Subcell 1
# #
# #${BBMOD}   BBMOD_R-1(ABIN)
# ${NRBTS_ID}           ${tl.gnbs[0].global_bts_id}
# 
# *** Test Cases ***
# [1]CNI-85020_05_Loki_Event trigger parallel L1-L2 Mirroring, snapshot to local
#     [Tags]
#     [Documentation]    *****************
#     ...    The purpose of this test case is to verify that L1 UL event trigger Snapshot includes IQ samples and BIP in parallel to locall.
#     ...    *******************
#     [Setup]    Precondition
#     [Teardown]    Teardown
#     Step 1: config RAD parameter
#     Step 2: delete LSS Parameters
#     Step 3: Start Parallel L1-L2 Mirroring
#     Step 4: Make L3 Call To Trigger Alarm
#     Step 5: Check Logs
# 
# [1]CNI-85020_01_Loki_Start and stop parallel L1-L2 Mirroring via webEM
#     [Tags]
#     [Documentation]    *****************
#     ...    The purpose of this test case is to verify that Activate and deactivate collect BIP log along with event trigger IQ snapshot via webEM.
#     ...    *******************
#     [Setup]
#     Log To Console    \n tryed in case_05
# 
# *** Keywords ***
# Step 1: config RAD parameter
#     Config Trigger Event On BBMod    Event_type=L2
# 
# Step 2: delete LSS Parameters
#     run keyword and ignore error  config Auto Snapshot Trigger Fault    operation=delete
# 
# Step 3: Start Parallel L1-L2 Mirroring
#     Start Parallel L1-L2 Mirroring From WEBUI
#     #Start Parallel L1-L2 Mirroring From cli
# 
# Step 4: Make L3 Call To Trigger Alarm
#     Make L3 Call
#     Wait Until Keyword Succeeds    3min    30s    Check FID:8101 Raised
# 
# Step 5: Check Logs
#     Local Collect snapshot coam And Check
