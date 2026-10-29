# *** Settings ***
# Force Tags    RAN_5G    RAN_5G_TDD    SBTS00    CLOUD_5G_CLASSICAL_ASIBL_ABIOB1_AEUD_AEUB_ENB    STATE_SW_UPLOADED
# ...   PY39
# 
# Suite Setup  Test suite setup
# Suite Teardown  Test suite teardown
# 
# Resource        ./Resource/5GC0000955_common_keyword_for_trunk.robot
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
#     [Tags]    CIT    CRT_UTE    5GC000955-C
#     [Documentation]    lock and unlock sfp from webem
#     [Setup]    robot_common_operations.Common Case Setup
#     Log to console    lock sfp from WebEM
#     Lock sfp lane from webEM    sfp_port=RF1    hw_name=ABIO
#     Wait until Keyword Succeeds    2min  30s    SFP status Should be disabled    port_name=RF
#     Log to console    unlock sfp from WebEM
#     unLock sfp lane from webEM    sfp_port=RF1    hw_name=ABIO
#     Wait until Keyword Succeeds    15min  30s    SFP status Should be enabled    port_name=RF
#     Wait until Keyword Succeeds    15min  30s    Verify cell status should be setup   
#     [Teardown]    robot_common_operations.Common Case Teardown
# 
# [1][1.0] 5GC000955_Parameters_check_for_transmission
#     [Tags]    CIT    CRT_UTE    5GC000955-C
#     [Documentation]     check "Max transmission rate" and "Transmission distance" have been not visible in sfp info
#     [Setup]    robot_common_operations.Common Case Setup
#     SFP info Should not include Max transmission rate and Transmission distance    port_name=RF  
#     [Teardown]    robot_common_operations.Common Case Teardown  
# 
# 
# [1][1.0] 5GC000955_Lock_Unlock_SFP_BBMOD
#     [Tags]    CIT    CRT_UTE    5GC000955-C
#     [Documentation]    lock and unlock sfp from webem
#     [Setup]    robot_common_operations.Common Case Setup
#     Log to console    lock sfp from WebEM
#     Lock sfp lane from webEM    sfp_port=RF1    hw_name=ABIO
#     Wait until Keyword Succeeds    2min  30s    SFP status Should be disabled    port_name=RF
#     Log to console    unlock sfp from WebEM
#     unLock sfp lane from webEM    sfp_port=RF1    hw_name=ABIO
#     Wait until Keyword Succeeds    15min  30s    SFP status Should be enabled    port_name=RF
#     Wait until Keyword Succeeds    15min  30s    Verify cell status should be setup
#     [Teardown]    robot_common_operations.Common Case Teardown
# 
# 
# *** Keywords ***
# Test suite setup
#     log to console  \n***Test Suite Setup***
#     robot_common_operations.Common Suite Setup
#     Sleep    600s
#     CI_interface.Common Suite Setup
#     WEBEM Login
#     Verify cell status should be setup
# 
# Test suite teardown
#     Verify cell status should be setup
#     Run Keyword And Ignore Error    WEBEM Logout
#     robot_common_operations.Common Suite Teardown
