# *** Settings ***
# Suite Setup        cOAM Common Suite Setup
# Suite Teardown     cOAM Common Suite Teardown
# Test Setup
# Test Teardown
# Test Timeout
# 
# Resource          Resource/5GC000470-E-5GC001082_common_KW.robot
# Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# 
# Documentation
# ...    author: Annie.hu
# ...    contact: Annie.hu@nokia-sbell.com
# ...    squad group: SG_05
# ...    Feature 5GC000470-E-5GC001082 in 5G20A program
# 
# Force Tags    CA_5G_OAM       5G20A 
# ...    PY36
# 
# *** Variables ***
# ${MRBTS_ID}       
# #${New_url}      https://shanxilbwas.sui6.srnhz.nsn-rdnet.net
# ${New_url}      https://gansulbwas.gansu.srnhz.nsn-rdnet.net
# ${usr}    omc
# ${passwd}     Nokia126_
# 
# *** Test Cases ***
# [1]5GC000470-E-5GC001082-B-b_002_SWM supports activation SW build package via NetAct
#     [Documentation]    *****************
#     ...    Basic information
#     ...    *****************
#     ...    this case is to verify gNB can active a new version SW build package successfully
#     ...    ******************
#     ...    - 26.04.2020 https://jiradc.int.net.nokia.com/browse/WESTLAKE- - Created
#     ...    *******************
#     [Tags]    OWNER_yang.9.yang@nokia-sbell.com    CRT_TRUNK   CRT_21A   CRT_21B   CRT_22R1
#     [Setup]   Run Keywords    cOAM Common Test Setup    Case setup
#     [Teardown]   Run Keywords     Case teardown     Delete downloaded package
#     [Timeout]    100min
#     "step1" Login netact and Open Software Manager
#     "step2" Select Target gnb for test case
#     "step3" Select SW package and finish download for test case
#     "step4" Check Download exceution success via NetAct for test case
#     "step5" Activation SW build via NetAct for test case
#     "step6" Check Activatation execution success via NetAct
# 
# 
# *** Keywords ***
# "step1" Login netact and Open Software Manager
#     log to console    Login netact and Open Software Manager
#     wait until keyword succeeds    3times    2min    Login Netact
#     Open Software Manager
# 
# "step2" Select Target gnb for test case
#     log to console    Select Target gnb for test case
#     Select Target gNB     BTS_ID=${MRBTS_ID}
# 
# "step3" Select SW package and finish download for test case
#     log to console    Select SW package and finish download
#     Select SW package and finish download      sw_version=${target_version}
# 
# "step4" Check Download exceution success via NetAct for test case
#     log to console    Check Download execution success via netAct
#     wait until keyword succeeds    15min    1min    Check Download exceution success via NetAct
# 
# "step5" Activation SW build via NetAct for test case
#     Log to console    Activate SW build via NetAct
#     Activation SW build via NetAct      sw_version=${target_version}
# 
# "step6" Check Activatation execution success via NetAct
#     log to console    Check Activate execution success
#     wait until keyword succeeds     20min     1min    Check Activatation execution success
