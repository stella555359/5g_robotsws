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
# @{ul}    [BBMOD_R-1(ABIN)] [PCI: 111]NRCELL-1: Subcell 0
# @{dl}    [BBMOD_R-1(ABIN)] [PCI: 112]NRCELL-2: Subcell 1
# #
# #${BBMOD}   BBMOD_R-1(ABIN)
# ${NRBTS_ID}           ${tl.gnbs[0].global_bts_id}
# 
# *** Test Cases ***
# [1]CNI-85020_13_Loki_Modify IQ and mirroring configuration via webEM
#     [Tags]
#     [Documentation]    *****************
#     ...    The purpose of this test case is to verify that Modify IQ capture and L1-L2 interface mirroring in parallel
#     ...    configuration will cause parallel mirroring stop via webEM.
#     ...    *******************
#     [Setup]    Precondition
#     [Teardown]    Teardown
#     Step 1: Start Parallel L1-L2 Mirroring
#     Step 2: Modify IQ Configuration & Start Parallel L1-L2 Mirroring
#     #Step 3: Make L3 Call To Trigger Alarm
#     #Step 4: Check Logs
# 
# *** Keywords ***
# Step 1: Start Parallel L1-L2 Mirroring
#     Start Parallel L1-L2 Mirroring From WEBUI
#     #Start Parallel L1-L2 Mirroring From cli
# 
# Step 2: Modify IQ Configuration & Start Parallel L1-L2 Mirroring
# 	@{ul}    Create List    [BBMOD_R-1(ABIN)] [PCI: 112]NRCELL-2: Subcell 1
# 	@{dl}    Create List    [BBMOD_R-1(ABIN)] [PCI: 112]NRCELL-2: Subcell 1
#     Start Parallel L1-L2 Mirroring From WEBUI    ul=@{ul}    dl=@{dl}
# 
# Step 3: Make L3 Call To Trigger Alarm
#     Make L3 Call
#     #log to console    Auto Snapshot time limited
#     Wait Until Keyword Succeeds    1min    30s    Check FID:8101 Raised
# 
# Step 4: Check Logs
#     Local Collect snapshot coam And Check
