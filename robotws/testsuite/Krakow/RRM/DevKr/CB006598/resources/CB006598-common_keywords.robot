*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...      == AUTHORS C-PLANE ==
...       - Konrad Bem <konrad.bem@nokia.com>
...       - Maciej Madej <maciej.madej@nokia.com>
...      == MAINTAINER ==
...      I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>

Resource    ../../../resources/Robot/common_settings.robot
Resource    CB006598_setups_and_teardowns.robot
Library     ../../resources/python/mock_stop_egate.py
Library     taf.sbts.oam.coam.admin      WITH NAME    coam
Library     make_sib2_query_to_verify_payload.py

*** Variables ***
@{yaml_paths_to_configure}=     ${disable_ciphering_yaml_path}
${ADMIN_CONNECTION}=  admin_connection

*** Keywords ***
Run Setup
    Log To Console    Setup started
    Reliable emss setup         bts_id=1
    Setup connection to admin  ${ADMIN_CONNECTION}
    ${run_update}    get variable value      ${configure}    "True"     # do not ever change that line!
    Run Keyword if  ${run_update} != ${False}
    ...    Reach onAir state
    Run Keyword if  ${run_update} != "True"
    ...    Setup egate  egate_port=20000  alias=default
    Setup devices aliases

Reach onAir state
    Wait for gnb to reach configured state
    discover bts
    Log To Console    Before Reach OnAir
    Run keyword and ignore error      get_lua_for_topology
    ${LUA_CFG_FILE}=      get variable value           ${LUA_CFG}
    reach onair with retries    lua_cfg=${LUA_CFG_FILE}
    Log To Console    After Reach OnAir
    Do not stop egate and daemon
    Configure       ${yaml_paths_to_configure}

Setup devices aliases
    Create UEs alias    alias=UE   id_type=wts_5g
    Create ENB device with alias 'eNB1' identified by ip=10.0.1.21
    Create GNB device with alias 'gNB2' identified by ip=10.0.1.2
    Create AMF device with alias 'AMF1' identified by ip=10.0.1.1
    Enable internal mirroring for alias    gNB2
    Create cells alias     alias=NRCELL    cells_type=wts_5g

Verify that in SIB2 broadcasted by NRCELL-${cell_id} ${query}
    ${query_ready}=  make_sib2_query_to_verify_payload.make_sib2_query  ${query}
    Verify that in SIB2 broadcasted by NRCELL query
    ...     ${cell_id}
    ...     ${query_ready}

Verify that in SIB2 broadcasted by NRCELL query
    [Arguments]     ${cell_id}      ${query}
    ${flow_alias_rrc}=     Get flow name
    ...     SystemInformation
    ...     device=NRCELL_2_${cell_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     ${query}
    ...     message_alias=SystemInformation
    ...     flow_alias=${flow_alias_rrc}

Block NRCELL-${cell_id:\d+}
    coam.block_cell   dist_name=MRBTS-1/NRBTS-1/NRCELL-${cell_id}  timeout=${100}  connection=${ADMIN_CONNECTION}
    sleep   3

Unblock NRCELL-${cell_id:\d+}
    coam.unblock_cell   dist_name=MRBTS-1/NRBTS-1/NRCELL-${cell_id}  timeout=${100}  connection=${ADMIN_CONNECTION}
    sleep   3

Set ${MO}-${MO_id}.${parameter} to ${value}
    Configure  {'MOC': '${MO}', 'ID': '${MO_id}', '${parameter}': '${value}'}
