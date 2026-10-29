# *** Settings ***
# Suite Setup
# Suite Teardown
# Test Setup
# Test Teardown
# Test Timeout      30 min
# 
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# #Resource   ../../../../resources/common/DEPRECATED/variables.robot
# Resource    ../common/taf_coam.robot
# Resource    ../common/coam_resource.robot
# Resource    ../5GC001638/Resource/5GC001638_Common_KW.robot
# Library     collections
# 
# Documentation
# ...    author: Jeffrey.Shi
# ...    contact: jeffrey.shi@nokia-sbell.com
# ...    squad group: SG_05
# ...    Feature 5GC001638-EA-5GC001082 in 5G19A program
# 
# Force Tags    CA_5G_OAM      
# ...    PY36
# 
# *** Variables ***
# ${BTS_ID}
# &{SW_version}
# #${New_url}      https://shanxilbwas.sui6.srnhz.nsn-rdnet.net
# ${New_url}      https://gansulbwas.gansu.srnhz.nsn-rdnet.net
# ${user_name}    omc
# ${pwd}    Nokia126_
# 
# *** Test Cases ***
# [1]5GC001638-EA-5GC001082_017_Classical gNB software version upload via NetAct
#     [Documentation]    *****************
#     ...    this case is to verify user gets information related to the Classical gNB activte, planned and passive software versions via NetAct.
#     ...    ******************
#     ...    - 22.02.2019 https://jiradc.int.net.nokia.com/browse/WESTLAKE-1121   - Created
#     ...    *******************
#     [Tags]    Owner_yanfang.liu@nokia-sbell.com    CRT_TRUNK   CRT_20B   CRT_21B
#     [Timeout]    10min
#     [Setup]    Run Keywords   robot_common_operations.Common Case Setup    Login netact and Open Software Manager
#     [Teardown]    Run Keywords   robot_common_operations.Common Case Teardown    Logout NetAct
#     Step1: Get SW version and BTS ID from WebUI
#     Step2: Select Target gnb for test case
#   	Step3: Upload Target gNB SW version
# 
# *** Keywords ***
# Step1: Get SW version and BTS ID from WebUI
#     log to console    Get TestLine BTS ID and SW version from WebUI
#     WEBUI Login
#     &{SW_version}    5GC001638_Common_KW.Get SW version
#     set suite variable    &{SW_version}
#     ${scf_path}     selenium_coam.Backup BTS Site Configuration
#     ${MRBTS_ID}     Get BTS ID from Testline    ${scf_path}
#     set suite variable    ${MRBTS_ID}
#     run keyword and ignore error     WEBUI Logout
# 
# Step2: Select Target gnb for test case
#     log to console    Select Target gnb for test case
#     Select Target gNB    ${MRBTS_ID}
# 
# Step3: Upload Target gNB SW version
#     log to console    Upload Target gNB SW version
#     ${Update Status}    Upload Target gNB
#     ${Active_SW_info}    Get Active SW ID via NetAct
#     ${Passive_SW_info}    Get Passive SW ID via NetAct
#     should contain    ${Update Status}    ok_NSN
#     should be equal    ${Active_SW_info}    &{SW_version}[Active]
#     should be equal    ${Passive_SW_info}    &{SW_version}[Passive]
# 
# Login netact and Open Software Manager
#     log to console    Login netact and Open Software Manager
#     wait until keyword succeeds    3times    2min    Login Netact
#     wait until keyword succeeds    3times    10s    Open Software Manager