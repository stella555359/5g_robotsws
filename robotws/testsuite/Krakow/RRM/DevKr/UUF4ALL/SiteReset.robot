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
${ITERATION}=             2
${SHOULD_BE_REPORTED}=    ${False}
${LUA_CFG}=            ${None}      # filled dynamically


*** Test Cases ***
E2E_TL_Site_Reset_without_HWF_with_OAM_KPI
    stop_and_fix_procedure_do_not_sleep
    Reload Library    uuf_rfrl_common
    Run keyword and ignore error      get_lua_for_topology
    ${LUA_CFG_FILEPATH}=      get variable value          ${LUA}        ${LUA_CFG}
    Log to console			Using lua ${LUA_CFG_FILEPATH}
    Log To Console    Before Reach OnAir
    Add 5GC    config=${LUA_CFG_FILEPATH}    edaemon_ports=10000
    Configure environment    rmod_detection_timeout=420s
    Log To Console    After Reach OnAir
    UUF4ALL_SITE_RESET_TEST
    ...   test_iteration=${ITERATION}
    ...   customers_list=@{CUSTOMERS_LIST}
    ...   critical_faults=@{CRITICAL_FAULTS}
    ...   custom_alarms=${CUSTOM_ALARMS}
