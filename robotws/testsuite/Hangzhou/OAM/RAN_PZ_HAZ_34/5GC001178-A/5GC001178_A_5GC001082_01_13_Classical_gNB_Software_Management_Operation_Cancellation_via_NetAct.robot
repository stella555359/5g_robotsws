# *** Settings ***
# Suite Setup          cOAM Common Suite Setup
# Suite Teardown      run keywords      Rollback tear down       Delete downloaded package
# Test Setup
# Test Teardown
# Test Timeout      60min
# 
# Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# #Resource          ../../../../resources/common/DEPRECATED/variables.robot
# Resource          ../common/taf_coam.robot
# Resource          ../common/coam_resource.robot
# Resource          Resource/5GC001178-A-5GC001082_common_KW.robot
# #Library    collections
# 
# Documentation
# ...    author: Jeffrey.Shi ;Jackie Ji; Yanfang.liu
# ...    contact: jeffrey.shi@nokia-sbell.com; jackie.ji@nokia-sbell.com ; yanfang.liu@nokia-sbell.com
# ...    squad group: SG_05
# ...    Feature 5GC0001178-A-5GC001082 in 5G19B program
# 
# Force Tags    CA_5G_OAM        
# ...    PY36
# 
# *** Variables ***
# ${MRBTS_ID}
# #${New_url}}      https://na19lbwas.qin1.srnhz.nsn-rdnet.net
# #${user_name}    omc
# #${pwd}     Nokia123!
# #${New_url}      https://gansulbwas.gansu.srnhz.nsn-rdnet.net
# #${user_name}    omc
# #${passwd}     Nokia126_
# #{New_url}      https://shanxilbwas.sui6.srnhz.nsn-rdnet.net
# #${user_name}    omc
# #${passwd}     Nokia126_
# ${New_url}      https://han5lbwas.han5.srnhz.nsn-rdnet.net/
# ${user_name}    omc
# ${passwd}     Nokia126_
# 
# *** Test Cases ***
# [1]5GC001178_A_5GC001082_01_13_Classical gNB Software Management Operation Cancellation via NetAct
#     [Documentation]    *****************
#     ...    this case is to verify cancels any software management operation that the operator has already requested to be executed via NetAct.
#     ...    ******************
#     ...    - 22.02.2019 https://jiradc.int.net.nokia.com/browse/WESTLAKE-1120   - Created
#     ...    *******************
#     [Tags]    yanfang.liu@nokia-sbell.com     CRT_TRUNK   CRT_22R3
#     [Timeout]    60min
#     [Setup]   run keywords      Case setup      Upload target SW build to NetAct
#     [Teardown]    run keywords   robot_common_operations.Common Case Teardown    Logout NetAct
#     Login netact and Open Software Manager
#     Select Target gnb for test case
#     Select SW package and finish download for test case
#     Cancel SW download
#     Check download cancellation success
# 
# *** Keywords ***
# 5GC001638-EA-5GC001082_009_activation_steps
#     Select Target gnb for test case
#     Activation SW build via NetAct for test case
#     Check Activatation execution success via NetAct
# 
# 5GC001638-EA-5GC001082_009_activation_full_steps
#     Select Target gnb for test case
#     Select SW package and finish download for test case
#     Check Download exceution success via NetAct for test case
#     Activation SW build via NetAct for test case
#     Check Activatation execution success via NetAct
# 
# Get BTS ID from WebUI
#     log to console    Get TestLine BTS ID and SW version from WebUI
#     WEBUI Login
#     ${bts_id}     selenium_coam.get_bts_id
#     set suite variable    ${MRBTS_ID}    MRBTS-${bts_id}
#     run keyword and ignore error     WEBUI Logout
# 
# Upload target SW build to NetAct
#     log to console    Upload target SW build to NetAct
#     ${flag}    Check SW build exist in NetAct or not     sw_version=${target_version}
#     run keyword if    ${Flag}==None    Upload SW build to NetAct     SW_version=${target_version}
#     run keyword if    ${Flag}==True    log to console     build ${target_version} already exist in NetAct
# 
# Login netact and Open Software Manager
#     log to console    Login netact and Open Software Manager
#     wait until keyword succeeds    3times    2min    Login Netact
#     wait until keyword succeeds    3times    10s     Open Software Manager
# 
# Select Target gnb for test case
#     log to console    Select Target gnb for test case
#     Select Target gNB     BTS_ID=${MRBTS_ID}
# 
# Select SW package and finish download for test case
#     log to console    Select SW package and finish download
#     Select SW package and finish download     sw_version=${target_version}
# 
# Check Download exceution success via NetAct for test case
#     log to console    Check Download execution success via netAct
#     wait until keyword succeeds    15min    1min    Check Download exceution success via NetAct
# 
# Cancel SW download
#     log to console    Cancel SW download
#     Cancel SW download via NetAct
# 
# Check download cancellation success
#     log to console    Check download cancellation success
#     wait until keyword succeeds    15min    10s    Check download cancellation success via NetAct
# 
# Check Download execution success via cOAM
#     log to console    check Download execution success via cOAM
#     WEBUI Login
#     &{SW_version}    Get SW version
#     ${version_from_gNB}    SW Version convert    &{SW_version}[Planned]
#     should be equal   ${version_from_gNB}    ${target_version}
#     run keyword and ignore error     WEBUI Logout
# 
# Activation SW build via NetAct for test case
#     Log to console    Activate SW build via NetAct
#     Activation SW build via NetAct      sw_version=${target_version}
# 
# Check Activatation execution success via NetAct
#     log to console    Check Activate execution success
#     wait until keyword succeeds     15min     1min    Check Activatation execution success
# 
# Select New task and finish rollback
#     log to console    Select New task and finish rollback
#     Select New Task and rollback option done
# 
# Check whether rollback succeeds via NetAct
#     log to console    Check whether rollback succeeds
#     wait until keyword succeeds    5min    20s    Check Rollback excetion success
# 
# Upgrade back to CI build
#     ${CIT_build}    get CIT build
#     ${flag}    Check SW build exist in NetAct or not    ${CIT_build}
#     run keyword if    ${Flag}==None    Upload SW build to NetAct     SW_version=${CIT_build}
#     run keyword if    ${Flag}==True    log to console     build ${CIT_build} already exist in NetAct
#     Login netact and Open Software Manager
#     Select Target gnb for test case
#     Select SW package and finish provision     sw_version=${CIT_build}
#     Check provision exceution success via NetAct for test case
# 
# Check provision exceution success via NetAct for test case
#     log to console    Check provision execution success via netAct
#     wait until keyword succeeds    15min    1min    Check Provision exceution success
# 
# Rollback tear down
#     ${CIT_build}    get CIT build
#     set suite variable        ${CIT_build}
#     WEBUI Login
#     @{version}     check SW version    Active
