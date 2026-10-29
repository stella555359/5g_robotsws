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
# ...    contact: nnie.hu@nokia-sbell.com
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
# [1]5GC000470-E-5GC001082-B-a_001_SWM supports Download SW build package
#     [Documentation]    *****************
#     ...    Basic information
#     ...    *****************
#     ...    this case is to verify gNB can download a new version SW build package successfully via NetAct
#     ...    ******************
#     ...    - 26.04.2020 https://jiradc.int.net.nokia.com/browse/WESTLAKE- - Created
#     ...    *******************
#     [Tags]    OWNER_yang.9.yang@nokia-sbell.com    CRT_TRUNK   CRT_21A   CRT_21B   CRT_22R1
#     [Setup]   Run Keywords     Case setup      Upload target SW build to NetAct
#     [Teardown]   Run Keywords     Case teardown        Delete downloaded package
#     [Timeout]    100min
#     "step1" Login netact and Open Software Manager
#     "step2" Select Target gnb for test case
#     "step3" Select SW package and finish download for test case
#     "step4" Check Download exceution success via NetAct for test case
#     "step5" Check Download execution success via cOAM
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
#     wait until keyword succeeds    20min    1min    Check Download exceution success via NetAct
# 
# "step5" Check Download execution success via cOAM
#     log to console    check Download execution success via cOAM
#     wait until keyword succeeds    10min    10s     Check Download exceution success via cOAM
# 
# Check Download exceution success via cOAM    
#     WEBUI Login
#     &{SW_version}    Get SW version
#     ${version_from_gNB}    SW Version convert    Webui_version=&{SW_version}[Planned]
#     should be equal   ${version_from_gNB}    ${target_version}
#     run keyword and ignore error     WEBUI Logout
# 
# Upload target SW build to NetAct
#     log to console    Upload target SW build to NetAct
#     ${flag}    Check SW build exist in NetAct or not    sw_version=${target_version}
#     run keyword if    ${Flag}==None    Upload SW build to NetAct    SW_version=${target_version}
#     run keyword if    ${Flag}==True    log to console     build ${target_version} already exist in NetAct
