# *** Settings ***
# Suite Setup       Run Keywords    robot_common_operations.Common Suite Setup    cOAM Common Suite Setup
# Suite Teardown    Run Keywords    robot_common_operations.Common Suite Teardown    cOAM Common Suite Teardown
# Test Setup        robot_common_operations.Common Case Setup
# Test Teardown     Run Keywords   robot_common_operations.Common Case Teardown   step7:logout webui   CI_interface.Common Case Teardown
# Test Timeout      100 minutes
# 
# Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# Resource          ../common/coam_resource.robot
# Resource          Resource/5GC001525-CA-5GC001082_common_KW.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# Library           taf.transport.ssh    WITH NAME    csn
# Library           taf.sbts.oam.coam.admin   WITH NAME   coam
# 
# Documentation
# ...    author: hellen.liu
# ...    contact: hellen.liu@nokia-sbell.com
# ...    squad group: SG_05
# ...    Feature 5GC0001525-CA-5GC001082 in 5G19A program
# 
# Force Tags    CA_5G_OAM     
# ...    PY36
# 
# *** Variables ***
# ${testpc_host}    ${host_addr}
# ${testpc_user}    ${host_username}
# ${testpc_pswd}    ${host_password}
# ${search_text}   	Operational state
# #ssh gNB
# ${asik_addr}        ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
# ${asik_username}    ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
# ${asik_password}    ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
# 
# *** Test Cases ***
# [1]5GC001525-CA-5GC001082_020_SWM supports provision SW build package via WebUI
#     [Documentation]    *****************
#     ...    Basic information
#     ...    *****************
#     ...    this case is to verify gNB can download a new version SW build package successfully
#     ...    ******************
#     ...    History of changes
#     ...    ******************
#     ...    - 06.05.2019 https://jiradc.int.net.nokia.com/browse/WESTLAKE-1016 - Created
#     ...    *******************
#     ...    Test case flowchart
#     ...    *******************
#     [Tags]    OWNER_yanfang.liu@nokia-sbell.com   CIT_21B    CIT_TRUNK    CIT_20A   CIT_21A   SBTS00
#     step1:Login WebUI
#     step2:check current sw version 1
#     step3:upgrade site with active
#     step4:check SW version after upgrade
#     step5:check sw update report
#     step6:check site status
# 
# [1]5GC001525-CA-5GC001082_035_Classical gNB Software Rollback successfully via WebUI
#     [Documentation]    *****************
#     ...    Basic information
#     ...    *****************
#     ...    this case is to verify gNB Software Rollback successfully via WebUI
#     ...    ******************
#     ...    History of changes
#     ...    ******************
#     ...    - 07.05.2019 https://jiradc.int.net.nokia.com/browse/WESTLAKE-1017 - Created
#     ...    *******************
#     ...    Test case flowchart
#     ...    *******************
#     [Tags]    OWNER_yanfang.liu@nokia-sbell.com   CIT_21B    CIT_TRUNK    CIT_20A   CIT_21A
#     step1:Login WebUI
#     step2:check current sw version 2
#     step3:execute rollback
#     step4:confirm rollback success
#     step5:ENV recovery
#     step6:check site status
# 
# *** Keywords ***
# step1:Login WebUI
#     log to console    step1:Login WebUI
#     Wait Until Keyword Succeeds    2min    10s    WEBUI Login    ${TRUE}
# 
# step2:check current sw version 1
#     log to console   step2:check current sw version 1
#     ${pre_active_version_1}    wait until keyword succeeds    1min    10s    check SW version    Active
#     set suite variable    ${pre_active_version_1}
#     sleep    5s
# 
# step2:check current sw version 2
#     log to console    step2:check current sw version 2
#     ${output}    ${version}    wait until keyword succeeds    1min    10s    check SW version    Active
#     ${pre_active_version_2}    set variable    ${output}
#     set suite variable    ${pre_active_version_2}
#     ${pre_passive_version_2}    set variable    &{version}[Passive]
#     set suite variable    ${pre_passive_version_2}
#     sleep    5s
# 
# step3:upgrade site with active
#     log to console    step3:upgrade site with active
#     csn.Connect to    hostname=${testpc_host}    username=${testpc_user}    password=${testpc_pswd}    alias=TESTPC
#     ${package_full_link}    Get link For Download from external value      version_type=Active
#     ${upgrade_package_path}    Download SW Build to VM     package_full_link=${package_full_link}
#     set suite variable    ${upgrade_package_path}
#     csn.disconnect    connection=TESTPC
#     wait until keyword succeeds     5 min   10 sec
#     ...     coam.connect to       bts_host=${asik_addr}     name=coam_admin
#     coam.update_software    sw_package=${upgrade_package_path}    timeout=7200    connection=coam_admin
#     #sleep    5s
#     #run keyword and ignore error     selenium_coam.disable_screen_lock
#     #sleep    2s
#     #Download package to site    if_active=${True}    upgrade_package_path=${upgrade_package_path}
# 
# step3:execute rollback
#     log to console    step3:execute rollback
#     run keyword and ignore error     selenium_coam.disable_screen_lock
#     wait until keyword succeeds    1min    10s    selenium_coam.software_rollback
#     sleep    5min
# 
# step4:check SW version after upgrade
#     log to console    step4:check SW version after upgrade
#     wait until keyword succeeds     40min    2min    Check if Airscal Upgrade Successfully
#     check if SW upgrade success
# 
# step4:confirm rollback success
#     log to console    step4:confirm rollback success
#     run keyword and ignore error    selenium_coam.continue_after_reload_modal_appear
#     run Keyword and Ignore Error    selenium_coam.refresh_page
#     wait until keyword succeeds    15min    1min    check if rollback success
#     sleep    5s
# 
# step5:check sw update report
#     log to console    step5:check sw update report
#     wait until keyword succeeds    10min    1min    check the update report
# 
# step5:ENV recovery
#     log to console    step5:ENV recovery
#     run keyword if    "${update_result}"=="FAIL"    step3:execute rollback
# 
# step6:check site status
#     log to console    step6:check site status
#     wait until keyword succeeds    40min    2min    check board and cell status
#     run keyword and ignore error     selenium_coam.enable_screen_lock
# 
# step7:logout webui
#     log to console    step7:logout webui
#     run keyword and ignore error    WEBUI Logout    virtual_disable=${TRUE}
#     run keyword and ignore error    Empty Directory    ${SW_build_path}
# 
# check if SW upgrade success
#     ${update_result}    ${version}    run keyword and ignore error    check sw version with external package value    check_version=Active
#     set suite variable    ${update_result}
#     ${result_2}    should match regexp    &{version}[Planned]    ${EMPTY}
# 
# check if rollback success
#     ${output}    ${version}    wait until keyword succeeds    1min    10s    check SW version    Active
#     should match regexp    ${output}    ${pre_passive_version_2}
#     sleep    5s
#     should match regexp    &{version}[Passive]    ${pre_active_version_2}
#     sleep    5s
#     should match regexp    &{version}[Planned]    ${EMPTY}
#     sleep    5s
