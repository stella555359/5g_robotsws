*** Settings ***
Documentation
...         author: fred.li
...         contact: fred.li@nokia-sbell.com
...         squad group: RAN_PZ_HAZ_4_SG07
...         BBOX5 test

Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/CB010655_SG7/Resource/CB010655_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/ru_operation.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG7/rrm_common.robot
Library    DateTime

Force Tags        CRT    SBTS24R3

Suite Setup       Suite setup for UTE
Suite Teardown    Suite teardown

*** Variables ***
${WEBUI_ADDR}        ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${WEBUI_USER}       ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PASSWORD}   ${tl.gnbs[0].cu.oam_http_connection_details.password}
${TestPC_addr}         ${tl.test_pc.default_ssh_connection_details.addr}
${TestPC_username}     ${tl.test_pc.default_ssh_connection_details.username}
${TestPC_password}     ${tl.test_pc.default_ssh_connection_details.password}
${TEST_LOG_DIRECTORY}    ${OUTPUT_DIR}
@{ru_index_list}    1


*** Test Cases ***
[1]CB010655_I_13 enhancement_of_reset_counter_for_uncontrolled_radio_reset
    [Documentation]    This case is to verify the black box data support temperature history
    [Setup]    robot_common_operations.Common Case Setup
#    Perform RU Power Off And On    ru_index_list=${ru_index_list}
#    Wait Until Keyword Succeeds    10min   1min    COAM Check all cells should be onair
#    Check BBOX5 file On Snapshot
#    Verify Reset Counter
#    Perform RU Power Off And On    ru_index_list=${ru_index_list}
#    Wait Until Keyword Succeeds    20min   1min    COAM Check all cells should be onair    connection=GNB_OAM
#    Check BBOX5 file On Snapshot
#    Verify Reset Counter after reset
    Modify timeBetweenSaveOnNVM and Activate   init_value=86400    target_value=5    connection=GNB_OAM
    Check BBOX5 file On Snapshot
    Verify Periodical trigger occur times
    sleep   5s
    Check BBOX5 file On Snapshot
    Verify Periodical trigger occur times after Modify
    Verify temperature enhancement
    [Teardown]    CB010655 Case Teardown

[1]CB010655_I_12_enhancement_of_reset_counter_for_controlled_radio_reset
    [Documentation]    This case is to verify the enhancement point of reset counter
    [Setup]    robot_common_operations.Common Case Setup
#    Modify timeBetweenSaveOnNVM and Activate   init_value=86400    target_value=5    connection=GNB_OAM
    Check BBOX5 file On Snapshot
    Verify Reset Counter
#    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl    connection=GNB_OAM
    COAM Reset Site    connection=GNB_OAM
    Wait Until Keyword Succeeds    20min   1min    COAM Check all cells should be onair    connection=GNB_OAM
    Check BBOX5 file On Snapshot
    Verify Reset Counter after reset
    [Teardown]    CB010655 Case Teardown
