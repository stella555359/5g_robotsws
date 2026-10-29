*** Settings ***
Resource    taf/rfrl/uuf4all/uuf4all_test_cases.robot
Library     taf.ul.ue.sim.env_setup
Library     ute_fsmaccess
Library     ../../resources/Python/suite_setup_managment.py
Library     ./resources/mock_stop_and_fix.py
Variables   ./resources/topology_to_lua_mapping.py

Force Tags     L3_SIM

*** Variables ***
@{CUSTOMERS_LIST}=        Generic
@{CUSTOM_ALARMS}=         @{EMPTY}
@{CRITICAL_FAULTS}=       @{EMPTY}
${REMOTE_NODE_UPDATE}=    ${True}
${ITERATION}=             1
${TRUNK}=                 ${True}
${SHOULD_BE_REPORTED}=    ${False}
${TARGET_SW}=          ${None}      # filled dynamically
${LUA_CFG}=            ${None}      # filled dynamically


*** Test Cases ***
E2E_TL_SW_upgrade_rollback_with_OAM_KPI_LTE
    stop_and_fix_procedure_do_not_sleep
    Reload Library    uuf_rfrl_common
    ${SOURCE_SW}=    Get gNB SW release
    log to console      Starting from ${SOURCE_SW}
    log to console      Target sw ${TARGET_SW}
    Run keyword and ignore error      get_lua_for_topology
    ${LUA_CFG_FILEPATH}=      get variable value          ${LUA}        ${LUA_CFG}
    Log to console			Using lua ${LUA_CFG_FILEPATH}
    Log To Console    Before Reach OnAir
    Add 5GC    config=${LUA_CFG_FILEPATH}    edaemon_ports=10000
    Configure environment    rmod_detection_timeout=420s
    Log To Console    After Reach OnAir
    UUF4ALL_SW_UPGRADE_TEST
    ...   test_iteration=${ITERATION}
    ...   customers_list=@{CUSTOMERS_LIST}
    ...   critical_faults=@{CRITICAL_FAULTS}
    ...   5g_source_sw=${SOURCE_SW}
    ...   5g_target_sw=${TARGET_SW}
    ...   use_builds_storage=${False}
    ...   restore_to_target_sw=${False}
    ...   custom_alarms=${CUSTOM_ALARMS}
    ...   remote_node_update=${REMOTE_NODE_UPDATE}



*** Keywords ***
Get gNB SW release
    ute_fsmaccess.Setup Enb Fsm Access   alias=test5G
    ${RAW_SW_VERSION}    ute_fsmaccess.Get Enb Sw Version   alias=test5G
    ute_fsmaccess.Teardown Enb Fsm Access  alias=test5G
    ${TRUNK_SW}=   Evaluate  re.sub('SBTS.*ENB?','SBTS00_ENB', '${RAW_SW_VERSION}')     modules=re
    ${SW_VERSION}=    Set variable if    '${TRUNK}'=='${True}'   ${TRUNK_SW}    ${RAW_SW_VERSION}
    [Return]        ${SW_VERSION}
