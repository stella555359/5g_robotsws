# *** Settings ***
# Suite Setup  Test suite setup
# Suite Teardown  Test suite teardown
# 
# Force Tags            
# ...    PY36
# Resource        ./Resource/5GC0000955_common_keyword.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# 
# Documentation
# ...   author: jiangrong.wang@nokia-sbell.com
# ...   squad group: mmw_SG2
# ...   Feature 5GC000955-C
# ...   test mmw part about 5GC000955
# 
# 
# *** Test Cases ***
# [2][1.0] 5GC000955_Lock_Unlock_SFP_BBMOD
#     [Tags]    5GC000955-C
#     [Documentation]
#     ...    lock and unlock sfp from webem
#     [Setup]    robot_common_operations.Common Case Setup
#     Log to console    lock sfp from WebEM
#     Lock sfp lane from webEM
#     Wait until Keyword Succeeds    2min  30s    SFP status Should be disabled
#     Log to console    unlock sfp from WebEM
#     unLock sfp lane from webEM
#     Wait until Keyword Succeeds    15min  30s    SFP status Should be enabled
#     Wait until Keyword Succeeds    15min  30s    Verify cell status should be setup
#     [Teardown]    robot_common_operations.Common Case Teardown
#     
# [1][1.0] 5GC000955_Lock_Unlock_SFP_BBMOD
#     [Tags]    5GC000955-C
#     [Documentation]
#     ...    lock and unlock sfp from cli
#     [Setup]    robot_common_operations.Common Case Setup
#     Log to console    lock sfp from cli
#     Lock sfp lane from CLI
#     Wait until Keyword Succeeds    2min  30s    SFP status Should be disabled
#     Log to console    unlock sfp from cli
#     unLock sfp lane from CLI
#     Wait until Keyword Succeeds    15min  30s    SFP status Should be enabled
#     Wait until Keyword Succeeds    15min  30s    Verify cell status should be setup
#     [Teardown]    robot_common_operations.Common Case Teardown
# 
# [1][1.0] 5GC000955_Parameters_check_for_transmission
#     [Tags]    5GC000955-C
#     [Documentation]
#     ...    check "Max transmission rate" and "Transmission distance" have been not visible in sfp info
#     [Setup]    robot_common_operations.Common Case Setup
#     SFP info Should not include Max transmission rate and Transmission distance
#     [Teardown]    robot_common_operations.Common Case Teardown
# 
# 
# *** Keywords ***
# Test suite setup
#     log to console  \n***Test Suite Setup***
#     robot_common_operations.Common Suite Setup
#     CI_interface.Common Suite Setup
#     WEBEM Login
#     Verify cell status should be setup
# 
# Test suite teardown
#     Verify cell status should be setup
#     WEBEM Logout
#     robot_common_operations.Common Suite Teardown
