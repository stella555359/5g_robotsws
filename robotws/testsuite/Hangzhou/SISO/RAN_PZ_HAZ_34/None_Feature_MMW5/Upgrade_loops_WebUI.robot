*** Settings ***
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot

Suite Setup          Run Keywords    robot_common_operations.Common Suite Setup
...    AND     GlobeCommon_Suite_Setup
Suite Teardown       Run Keyword    robot_common_operations.Common Suite Teardown
Test Setup           robot_common_operations.Common Case Setup 
Test Teardown        robot_common_operations.Common Case Teardown

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/coam_resource.robot
Resource    Resources/Globe_keywords_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Library           taf.transport.ssh    WITH NAME    csn
Library           taf.sbts.oam.coam.admin   WITH NAME   coam

Force Tags    5G_SISO    mmw_05    CRT_22R1    CRT_Trunk
...   PY36

*** Variables ***
${testpc_host}    ${host_addr}
${testpc_user}    ${host_username}
${testpc_pswd}    ${host_password}
${search_text}   	Operational state
#ssh gNB
${smod_addr}        ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${asik_username}    ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
${asik_password}    ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
${TS_CASE_LOG_PATH}   ${OUTPUT DIR}

*** Test Cases ***
[1]E2E_gNB_SW_Upgrade_loops_with_WebUI
    [Documentation]    author: chun.li@nokia-sbell.com
    ...    squad group: mmW_5
    ...    Feature Upgrade loops - WebUI  UUF4ALL
    ...    *****************
    ...    Basic information
    ...    *****************
    ...    this case is to verify gNB can download and Rollback a new version SW build package successfully
    ...    *******************
    ...    Test case flowchart
    ...    *******************
    [Tags]    CRT_22R1    CRT_Trunk

    AlarmWatchdog.add_allow_alarms    fault_id=6327
    AlarmWatchdog.add_allow_alarms    fault_id=7319
    AlarmWatchdog.add_allow_alarms    fault_id=7300
    AlarmWatchdog.add_allow_alarms    fault_id=62003
    SWM supports provision SW build package via WebUI
    sleep    50s
    Classical gNB Software Rollback successfully via WebUI

    [Teardown]     Run Keyword    Common Case Teardown  is_save_snapshot=True

*** Keywords ***
