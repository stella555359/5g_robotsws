*** Settings ***
Documentation
...    author: ming shi
...    contact: ming.shi@nokia-sbell.com

#Suite Setup    robot_common_operations.Common Suite Setup
#
#Suite Teardown    robot_common_operations.Common Suite Teardown

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/upgrade_rollback_keywords.robot
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC001785/Resources/TDD_FDD_HO_common_keyword.robot
Variables   testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC001785/Resources/upgrade_and_rollback_parameters.py


*** Test Cases ***
[1]E2E_gNB_SW_Upgrade_rollback_reset_loops_with_WebUI
    [Setup]
#    robot_common_operations.Common Case Setup
    ${is_multi_bts_operation}    get_value_of_is_multi_bts_operation
    Run Keyword If    ${is_multi_bts_operation}==True    multi_bts_multi_times
    ...    ELSE    single_bts_multi_times
#    [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown    AND
#    ...    Run Keyword If Test Failed    CI_interface.Common Case Teardown


*** Keywords ***
single_bts_multi_times
    ${node_num}    get_bts_num
    Set Test Variable    ${node_num}
    FOR    ${num}    IN RANGE    ${node_num}
        ${node_index}    ${node_type}    ${node_upgrade_boolean}    ${node_rollback_boolean}    ${node_reset_boolean}
        ...    get_required_info    bts_index=${num}
        ${value_action_first}    get_value_of_action_first    bts_index=${num}
        Set Test Variable    ${node_index}
        Set Test Variable    ${node_type}
        Set Test Variable    ${node_upgrade_boolean}
        Set Test Variable    ${node_rollback_boolean}
        Set Test Variable    ${node_reset_boolean}
        ${run_times}    get_run_times    index=${num}
        Set Test Variable    ${test_round}    ${run_times}
        Run Keyword If    '${value_action_first}'=='upgrade'    run actions    node_no=${num}
        ...    ELSE IF    '${value_action_first}'=='rollback'    run actions rollback first    node_no=${num}
        ...    ELSE IF    '${value_action_first}'=='reset'    run actions    node_no=${num}
    END

multi_bts_multi_times
    ${run_times}    get_run_times    index=${0}
    Set Test Variable    ${test_round}    ${run_times}
    FOR    ${count}    IN RANGE    ${test_round}
        multi bts upgrade
        multi bts rollback
        multi bts reset
    END

multi bts upgrade
    ${node_num}    get_bts_num
    Set Test Variable    ${node_num}
    FOR    ${num}    IN RANGE    ${node_num}
        ${node_index}    ${node_type}    ${node_upgrade_boolean}    ${node_rollback_boolean}    ${node_reset_boolean}
        ...    get_required_info    bts_index=${num}
        Set Test Variable    ${node_index}
        Set Test Variable    ${node_type}
        Set Test Variable    ${node_upgrade_boolean}
        Set Test Variable    ${node_rollback_boolean}
        Set Test Variable    ${node_reset_boolean}
        Run Keyword If    ${node_upgrade_boolean}==True
        ...    upgrade    node_type=${node_type}    index=${node_index}    node_no=${num}
    END

multi bts rollback
    ${node_num}    get_bts_num
    Set Test Variable    ${node_num}
    FOR    ${num}    IN RANGE    ${node_num}
        ${node_index}    ${node_type}    ${node_upgrade_boolean}    ${node_rollback_boolean}    ${node_reset_boolean}
        ...    get_required_info    bts_index=${num}
        Set Test Variable    ${node_index}
        Set Test Variable    ${node_type}
        Set Test Variable    ${node_upgrade_boolean}
        Set Test Variable    ${node_rollback_boolean}
        Set Test Variable    ${node_reset_boolean}
        Run Keyword If    ${node_rollback_boolean}==True
        ...    rollback    node_type=${node_type}    index=${node_index}
    END

multi bts reset
    ${node_num}    get_bts_num
    Set Test Variable    ${node_num}
    FOR    ${num}    IN RANGE    ${node_num}
        ${node_index}    ${node_type}    ${node_upgrade_boolean}    ${node_rollback_boolean}    ${node_reset_boolean}
        ...    get_required_info    bts_index=${num}
        Set Test Variable    ${node_index}
        Set Test Variable    ${node_type}
        Set Test Variable    ${node_upgrade_boolean}
        Set Test Variable    ${node_rollback_boolean}
        Set Test Variable    ${node_reset_boolean}
        Run Keyword If    ${node_reset_boolean}==True
        ...    reset    node_type=${node_type}    index=${node_index}
    END

run actions
    [Arguments]    ${node_no}=${0}
    Set Test Variable    ${initial_num}    ${0}
    @{version_list}=    get_version    index=${node_no}
    ${version_length}=    Get Length     ${version_list}
    FOR    ${count}    IN RANGE    ${test_round}
        Run Keyword If    ${initial_num} == ${version_length}    Run Keywords
        ...    Set Test Variable    ${version_index}    ${0}
        ...    AND    Set Test Variable    ${initial_num}    ${-1}
        ...    ELSE    Set Test Variable    ${version_index}    ${initial_num}
        Run Keyword If    ${node_upgrade_boolean}==True
        ...    upgrade    node_type=${node_type}    index=${node_index}    node_no=${node_no}
        ...    v_index=${version_index}
        Run Keyword If    ${node_rollback_boolean}==True    sleep    50s
        Run Keyword If    ${node_rollback_boolean}==True
        ...    rollback    node_type=${node_type}    index=${node_index}
        Run Keyword If    ${node_reset_boolean}==True    sleep    50s
        Run Keyword If    ${node_reset_boolean}==True
        ...    reset    node_type=${node_type}    index=${node_index}
        Run Keyword If    ${node_upgrade_boolean}==True    sleep    50s
        ${initial_num}    Evaluate    ${initial_num} + 1
    END

run actions rollback first
    [Arguments]    ${node_no}=${0}
    Set Test Variable    ${initial_num}    ${0}
    @{version_list}=    get_version    index=${node_no}
    ${version_length}=    Get Length     ${version_list}
    FOR    ${count}    IN RANGE    ${test_round}
        Run Keyword If    ${node_rollback_boolean}==True
        ...    rollback    node_type=${node_type}    index=${node_index}
        Run Keyword If    ${node_upgrade_boolean}==True    sleep    50s
        Run Keyword If    ${initial_num} == ${version_length}    Run Keywords
        ...    Set Test Variable    ${version_index}    ${0}
        ...    AND    Set Test Variable    ${initial_num}    ${-1}
        ...    ELSE    Set Test Variable    ${version_index}    ${initial_num}
        Run Keyword If    ${node_upgrade_boolean}==True
        ...    upgrade    node_type=${node_type}    index=${node_index}    node_no=${node_no}
        ...    v_index=${version_index}
        Run Keyword If    ${node_reset_boolean}==True    sleep    50s
        Run Keyword If    ${node_reset_boolean}==True
        ...    reset    node_type=${node_type}    index=${node_index}
        Run Keyword If    ${node_rollback_boolean}==True    sleep    50s
        ${initial_num}    Evaluate    ${initial_num} + 1
    END

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
    [Teardown]    Run Keyword If    '${KEYWORD STATUS}' == 'FAIL'
    ...    Save snapshot Teardown for SFE    connection=GNB_OAM    gnb_index=${index}

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
    [Teardown]    Run Keyword If    '${KEYWORD STATUS}' == 'FAIL'
    ...    Save snapshot Teardown for SFE    connection=GNB_OAM    gnb_index=${index}


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
    [Teardown]    Run Keyword If    '${KEYWORD STATUS}' == 'FAIL'
    ...    Save snapshot Teardown for SFE    connection=GNB_OAM    gnb_index=${index}
