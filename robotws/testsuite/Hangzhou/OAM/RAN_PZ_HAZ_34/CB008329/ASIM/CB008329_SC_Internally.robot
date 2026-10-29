# *** Settings ***
# Documentation
# ...  author: Lei Nie
# ...  contact: lei.nie@nokia-sbell.com
# 
# Resource   ../Resource/Common.robot
# 
# Force Tags   SG_07   CA_5G_OAM   STATE_SW_UPDATED   RAN_5G   RAN_5G_TDD
# ...   SBTS00
# ...   AUTHOR_lei.nie@nokia-sbell.com
# 
# Test Timeout   1h
# 
# Suite Setup   Common Suite Setup
# Suite Teardown   Common Suite Teardown
# Test Setup   Run Keywords
# ...   robot_common_operations.Common Case Setup   AND
# ...   Append To List   ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}
# 
# *** Variables ***
# ${UTE_FLAG}   ${True}
# ${DUAL_CORE}   ${False}
# @{ALL_TEST_STATUS}
# 
# 
# *** Test Cases ***
# CB008329_001_Sanity_Checker_Detects_Netboot_Enabled
#     [Documentation]   Author: lei.nie@nokia-sbell.com
#     # [Setup]   Case Setup: 001
#     001_Netboot_Enable
#     [Teardown]   Case Teardown: 001
# 
# CB008329_002_Sanity_Checker_Detects_Missing_Files_Referred_In_FileDirectoryXML_On_Active_Partition
#     [Documentation]   Author: lei.nie@nokia-sbell.com
#     # [Setup]   Case Setup: 002
#     002_SC_Detects_Missing_Files_Referred_In_FileDirectoryXML_On_Active_Partition
#     [Teardown]   Case Teardown: 002
# 
# CB008329_003_Sanity_Checker_Detects_Missing_Files_Referred_In_FileDirectoryXML_On_Passive_Partition
#     [Documentation]   Author: lei.nie@nokia-sbell.com
#     # [Setup]   Case Setup: 003
#     003_SC_Detects_Missing_Files_Referred_In_FileDirectoryXML_On_Passive_Partition
#     [Teardown]   Case Teardown: 003
# 
# CB008329_004_Scheduled_Sanity_Checker_Detects_Netboot_Enabled
#     [Documentation]   Author: lei.nie@nokia-sbell.com
#     # [Setup]   Case Setup: 004
#     004_Scheduled_SC_Netboot_Enable
#     [Teardown]   Case Teardown: 004
# 
# CB008329_005_Scheduled_Sanity_Checker_Detects_Missing_Files_Referred_In_FileDirectoryXML
#     [Documentation]   Author: lei.nie@nokia-sbell.com
#     # [Setup]   Case Setup: 005
#     005_Scheduled_SC_Detects_Missing_Files_Referred_In_FileDirectoryXML
#     [Teardown]   Case Teardown: 005
# 
# CB008329_ALL_BTS_System_Module_Sanity_Checker_Extension
#     List Should Not Contain Value   ${ALL_TEST_STATUS}   FAIL
# 
# 
# *** Keywords ***
# Common Suite Setup
#     robot_common_operations.Common Suite Setup
#     SC Internally Common Setup
# 
# Common Suite Teardown
#     SC Internally Common Teardown
#     robot_common_operations.Common Suite Teardown
# 
# SC Internally Common Setup
#     Common Setup CB008329
#     Enable SC Feature Flag
#     Configure Scheduled SC
# 
# SC Internally Common Teardown
#     Disable SC Feature Flag
#     Run Keyword And Ignore Error   Remove Configured Scheduled SC
#     Common Teardown CB008329
