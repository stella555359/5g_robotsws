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
# [1]CNI-85020_15_Loki_Stop log collection via webEM
#     [Tags]
#     [Documentation]    *****************
#     ...    The purpose of this test case is to verify that Stop log collection after event trigger via webEM.
#     ...    *******************
#     [Setup]    Precondition
#     [Teardown]    Teardown
#     Start Parallel L1-L2 Mirroring From WEBUI
#     sleep    10s
#     Stop BIP Log
# 
# [1]CNI-85020_16_Loki_Stop log collection via CLI
#     [Tags]
#     [Documentation]    *****************
#     ...    The purpose of this test case is to verify that Stop log collection after vent trigger via CLI.
#     ...    *******************
#     [Setup]    Precondition
#     [Teardown]    Teardown
#     Start Parallel L1-L2 Mirroring From cli
#     sleep    10s
#     Stop BIP Log
# 
# 
# #*** Keywords ***
# #Step 1: Start Parallel L1-L2 Mirroring
# #    Start Parallel L1-L2 Mirroring From WEBUI
# #    #Start Parallel L1-L2 Mirroring From cli    subcellId=${0}    nrcellId=${1}
# #
# #Step 2: Stop BIP & Collect Logs
# #    Stop BIP Log & Collect Log
# 
# 
