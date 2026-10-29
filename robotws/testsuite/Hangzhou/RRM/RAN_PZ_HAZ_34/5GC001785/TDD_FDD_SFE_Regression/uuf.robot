*** Settings ***
Documentation
...    author: ming shi
...    contact: ming.shi@nokia-sbell.com

Suite Setup    robot_common_operations.Common Suite Setup

Suite Teardown    robot_common_operations.Common Suite Teardown

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/upgrade_rollback_keywords.robot
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC001785/Resources/TDD_FDD_HO_common_keyword.robot
Variables   testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC001785/Resources/upgrade_and_rollback_parameters.py



*** Variables ***
@{gnb_index}    ${0}    ${1}


*** Test Cases ***
[1]E2E_gNB_SW_Upgrade_uuf
    [Tags]    classical    uuf
    [Setup]
    upgrade
    [Teardown]    Run Keyword If Test Failed    Common Case Teardown for COAM    gnb_list=@{gnb_index}

[1]E2E_gNB_SW_rollback_uuf
    [Tags]    classical    uuf
    [Setup]
    rollback
    [Teardown]    Run Keyword If Test Failed    Common Case Teardown for COAM    gnb_list=@{gnb_index}

[1]E2E_gNB_SW_reset_uuf
    [Tags]    classical    uuf
    [Setup]
    reset
    [Teardown]    Run Keyword If Test Failed    Common Case Teardown for COAM    gnb_list=@{gnb_index}


*** Keywords ***
upgrade
    [Arguments]    ${node_type}=gnb    ${index}=${0}    ${connection}=${node_type}_${index}
    ...    ${timeout}=10 min    ${retry_interval}=5 sec    ${du_index}=0
    ...    ${is_x2_check_from_gnb_needed}=${True}
    ...    ${check_tl_type_timeout}=5s    ${check_tl_type_retry_interval}=1s    ${node_no}=${0}
    ...    ${v_index}=${0}
#   Run Keyword If    '${node_type}'=='enb'    modify parmeters via interface    parameters_to_update=${PARAM_enb_Lock_SFP_LANE}
#   ...    connection=${connection}    node_type=${node_type}    gnb_index=${index}    enb_index=${index}
    get_download_link_release_name
    get version info    index=${node_no}    v_index=${v_index}
    check_and_download_packet
    ${is_make_traffic}    get_value_of_is_make_traffic
    Run Keyword If    ${is_make_traffic}==True
    ...    Prepare all online UE with DL data start    cell_type=SA
    Set Test Variable    ${test_result}    ${False}
    Log to console    1.check current version
    Get current version to check    connection=${connection}    node_type=${node_type}    gnb_index=${index}    enb_index=${index}
    Log to console    2.upgrade
    Wait Until Keyword Succeeds    3x    1m    upgrade build    connection=${connection}
    ...    node_type=${node_type}    gnb_index=${index}    enb_index=${index}
    sleep    1m
    Log to console    3. check version after upgrade
    wait until keyword succeeds     40min    2min    Check if Upgrade Successfully    connection=${connection}
    ...    node_type=${node_type}    gnb_index=${index}    enb_index=${index}
    Log to console    4. check sw upgrade report
    Get upgrade report    connection=${connection}    node_type=${node_type}    gnb_index=${index}    enb_index=${index}
#   wait until keyword succeeds     60min    1min
#   ...    Run Keyword If    '${node_type}'=='enb'    modify parmeters via interface    parameters_to_update=${PARAM_enb_Unlock_SFP_LANE}
#   ...    connection=${connection}    node_type=${node_type}    gnb_index=${index}    enb_index=${index}
    Log to console    5. check site status
    Wait Until Keyword Succeeds    3x    1m
    ...    Get and check node detail info    connection=${connection}    timeout=${timeout}    retry_interval=${retry_interval}
    ...    du_index=${du_index}    node_type=${node_type}
    ...    is_x2_check_from_gnb_needed=${is_x2_check_from_gnb_needed}
    ...    check_tl_type_timeout=${check_tl_type_timeout}
    ...    check_tl_type_retry_interval=${check_tl_type_retry_interval}    gnb_index=${index}    enb_index=${index}
    sleep   5m
    Wait Until Keyword Succeeds    10min    1min
    ...    Get alarms to check    connection=${connection}    node_type=${node_type}    gnb_index=${index}    enb_index=${index}
    Set Test Variable    ${test_result}    ${True}

rollback
    [Arguments]    ${node_type}=gnb    ${index}=${0}    ${connection}=${node_type}_${index}
    ...    ${timeout}=10 min    ${retry_interval}=5 sec    ${du_index}=0
    ...    ${is_x2_check_from_gnb_needed}=${True}
    ...    ${check_tl_type_timeout}=5s    ${check_tl_type_retry_interval}=1s
    Set Test Variable    ${test_result}    ${False}
    Log to console    1.check current version
    Get current version to check    connection=${connection}    node_type=${node_type}    gnb_index=${index}    enb_index=${index}
    Log to console    2.rollback
    Wait Until Keyword Succeeds    3x    1m    rollback_build    connection=${connection}
    ...    node_type=${node_type}    gnb_index=${index}    enb_index=${index}
    sleep    1m
    Log to console    3. check version after rollback
    wait until keyword succeeds     40min    2min    Check if rollback Successfully    connection=${connection}
    ...    node_type=${node_type}    gnb_index=${index}    enb_index=${index}
#   wait until keyword succeeds     60min    1min
#   ...    Run Keyword If    '${node_type}'=='enb'    modify parmeters via interface    parameters_to_update=${PARAM_enb_Unlock_SFP_LANE}
#   ...    connection=${connection}    node_type=${node_type}    gnb_index=${index}    enb_index=${index}
    Log to console    4. check site status
    Wait Until Keyword Succeeds    3x    1m
    ...    Get and check node detail info    connection=${connection}    timeout=${timeout}    retry_interval=${retry_interval}
    ...    du_index=${du_index}    node_type=${node_type}
    ...    is_x2_check_from_gnb_needed=${is_x2_check_from_gnb_needed}
    ...    check_tl_type_timeout=${check_tl_type_timeout}
    ...    check_tl_type_retry_interval=${check_tl_type_retry_interval}    gnb_index=${index}    enb_index=${index}
    sleep    5m
    Wait Until Keyword Succeeds    10min    1min
    ...    Get alarms to check    connection=${connection}    node_type=${node_type}    gnb_index=${index}    enb_index=${index}
    Set Test Variable    ${test_result}    ${True}


reset
    [Arguments]    ${node_type}=gnb    ${index}=${0}    ${connection}=${node_type}_${index}
    ...    ${timeout}=10 min    ${retry_interval}=5 sec    ${du_index}=0
    ...    ${is_x2_check_from_gnb_needed}=${True}
    ...    ${check_tl_type_timeout}=5s    ${check_tl_type_retry_interval}=1s
    Set Test Variable    ${test_result}    ${False}
    Log to console    1.check current version
    Get current version to check    connection=${connection}    node_type=${node_type}    gnb_index=${index}    enb_index=${index}
    Log to console    2.reset
    Wait Until Keyword Succeeds    3x    1m    reset node    connection=${connection}    node_type=${node_type}
    ...    gnb_index=${index}    enb_index=${index}
    sleep    1m
    Log to console    3. check version after reset
    wait until keyword succeeds     40min    2min    Check if reset Successfully    connection=${connection}
    ...    node_type=${node_type}    gnb_index=${index}    enb_index=${index}
    Log to console    4. check site status
    Wait Until Keyword Succeeds    3x    1m    Get and check node detail info    connection=${connection}
    ...    timeout=${timeout}    retry_interval=${retry_interval}
    ...    du_index=${du_index}    node_type=${node_type}
    ...    is_x2_check_from_gnb_needed=${is_x2_check_from_gnb_needed}
    ...    check_tl_type_timeout=${check_tl_type_timeout}
    ...    check_tl_type_retry_interval=${check_tl_type_retry_interval}    gnb_index=${index}    enb_index=${index}
    sleep    5m
    Wait Until Keyword Succeeds    10min    1min    Get alarms to check    connection=${connection}
    ...    node_type=${node_type}    gnb_index=${index}    enb_index=${index}
    Set Test Variable    ${test_result}    ${True}
