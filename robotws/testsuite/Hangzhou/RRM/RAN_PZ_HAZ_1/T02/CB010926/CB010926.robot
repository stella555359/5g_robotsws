*** Settings ***
Documentation
...    Author: mengli yang
...    Contact: mengli.yang@nokia-sbell.com
...    this file is module case template,you can create your test case according to this template.
...    Please do not modify the file without notification to author


Suite Setup    Common Suite Setup For RRM
#Suite Teardown    Common Suite Teardown For RRM

Force Tags
...      CRT             #Tag Item
...      VRF_HAZ1             #Competence Area

Test Timeout    600 minutes

Resource          ../../Resources/Classical/RRM_Common_Resource.robot
Resource          ../../T02/Common_Case/common_resource_new.robot
Library           taf.transport.ssh                WITH NAME   ssh
Library           ../CB010926/UE_Traffic.py    WITH NAME    traffic

*** Test Cases ***
CB010926_01
    [Tags]    CRT    case1
    [Documentation]
    ...    Author: XXXXXX@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    [Setup]    Case Precondition
    Execute Traffic with Shell Script
    [Teardown]    Case Postcondition


*** Keywords ***
Case Precondition
    log to console    Case Precondition
    Common Test Setup For RRM

Common Test Setup For RRM
    ${timestamp}=    DateTime.Get Current Date    result_format=%Y%m%d%H%M%S
    ${tc_name}=    Replace String    ${TEST_NAME}    ${SPACE}    _
    ${case_log_path}    Join path    ${SUITE_LOG_DIRECTORY}    ${tc_name}_${timestamp}
    Set Suite Variable    ${TEST_LOG_DIRECTORY}    ${case_log_path}
    Create directory    ${TEST_LOG_DIRECTORY}

Common Suite Setup For RRM
    _Create Suite Directory

Case Postcondition
    log to console    Case Postcondition


Execute Traffic with Shell Script
    [Arguments]    ${ue_index}=${0}
    @{script_paths}=    Create List    C:\\Users\\rr3-tester\\Desktop\\UE_control\\TA_debug\\UE2
    ...                                C:\\Users\\rr3-tester\\Desktop\\UE_control\\TA_debug\\UE3
    @{script_names}=    Create List    main_controller_mate60pro.sh
    ...                                main_controller_mate40pro.sh
    main_execute_traffic_script    ip=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...                            user=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...                            password=${tl.ues[${ue_index}].ssh_connection_details.password}
    ...                            script_path=${script_paths}
    ...                            script_name=${script_names}
