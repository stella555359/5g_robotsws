*** Settings ***
Documentation
...         author: yingying.li
...         contact: yingying.li@nokia-sbell.com
...         squad group: 5G_PZ_MMW_HZ_3_SG
...         BBOX5 test
Suite Setup       Suite setup
Suite Teardown    Suite teardown
Force Tags        CRT    SBTS24R3
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/CB010655/Resource/CB010655_common.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_coam.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot

*** Variables ***
${WEBUI_ADDR}        ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${WEBUI_USER}       ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PASSWORD}   ${tl.gnbs[0].cu.oam_http_connection_details.password}
${TestPC_addr}         ${tl.test_pc.default_ssh_connection_details.addr}
${TestPC_username}     ${tl.test_pc.default_ssh_connection_details.username}
${TestPC_password}     ${tl.test_pc.default_ssh_connection_details.password}
${TEST_LOG_DIRECTORY}    /home/ute/Downloads/

*** Test Cases ***
[1]CB010655_E_08_enhancement_the_record_of_temperature_related_data
    [Documentation]    This case is to verify the black box data support temperature history
    [Tags]    CRT_TRUNK
    [Setup]    robot_common_operations.Common Case Setup
    Get BBOX5 file On Snapshot
    check temperature enhancement
    [Teardown]    Run keywords    RUN KEYWORD AND CONTINUE ON FAILURE
    ...    robot_common_operations.Common Case Teardown    AND
    ...    CI_interface.Common Case Teardown    AND
    ...    Clear snapshot on UTE

[1]CB010655_I_11_enhancement_of_reset_counter_for_controlled_radio_reset
    [Documentation]    This case is to verify the enhancement point of reset counter
    [Tags]    CRT_TRUNK
    [Setup]    robot_common_operations.Common Case Setup
    Get BBOX5 file On Snapshot
    check Reset Counter
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl    connection=COAM
    COAM Reset Site
    sleep     300s
    Get BBOX5 file On Snapshot
    check Reset Counter after reset
    [Teardown]    Run keywords    RUN KEYWORD AND CONTINUE ON FAILURE
    ...    robot_common_operations.Common Case Teardown    AND
    ...    CI_interface.Common Case Teardown    AND
    ...    Clear snapshot on UTE

