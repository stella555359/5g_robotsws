*** Settings ***
Documentation
...   author: Tomasz Szylkowski
...   contact: tomasz.szylkowski@nokia.com
...   Example test suite to perform upgrade before any other test

Library  taf.sbts.oam.coam.admin  WITH NAME  admin

Library                         Collections
Library                         taf/rfrl/csv4all/CSV4AllTestCases.py
Resource                        taf/rfrl/uuf4all/uuf4all_keywords.robot

# set proper CA for RP reporting to work properly
Force Tags                      VRF_WRO3_SG05

# Suite setup uses keyword to fetch the build automatically from CM execution,
# remove if running from CLI
Suite Setup                     Set Initial And Candidate

*** Variables ***
# Helper variable do teremine status of ST4.7 upgrade
${UPDATE_TEST_FAILED}          ${False}

@{CUSTOMERS}=                   Generic
${INITIAL}=                     ${None}
${CANDIDATE}=                   ${None}
${UPGRADE_ITERATION}=           1
${TEMP_ALLOWED_FAULTS}=         ${None}
@{CUSTOM_ALLOWED_ALARMS}        4700    61675

&{node1}                        node_alias=4G
...                             testline_object=${tl.enbs[0]}
...                             source_sw=${INITIAL}
...                             target_sw=${CANDIDATE}
...                             temporary_allowed_alarms=${TEMP_ALLOWED_FAULTS}
...                             custom_allowed_alarms=${CUSTOM_ALLOWED_ALARMS}

@{nodes}                        ${node1}

*** Test Cases ***
PRELIMINARY UPGRADE
    [Timeout]   24h
    # Here is where the magic happens, single keyword to run the upgrade
    # the bts to target software
    # after which you can continue with our scope

    e2e_tl_upgrade_test
    ...   nodes_details=${nodes}
    ...   test_nodes_details=${node1}
    ...   iterations_per_node=1
    ...   report=${True}
    ...   customers_list=${CUSTOMERS}

    # In test teardown we change the value of our global flag to indicate
    # the status of an upgrade
    [Teardown]   Run Keyword If Test Failed   Set Test Failed

*** Keywords ***
Set Test Failed
    Set Suite Variable  ${UPDATE_TEST_FAILED}  ${True}

Check Update Status
    Run Keyword If      ${UPDATE_TEST_FAILED}  Fail

Set Initial And Candidate
    ${initial_sw}             Get Source SW
    ${candidate_sw}           Get Target SW
    Set to dictionary         ${node1}
    ...                       source_sw=${initial_sw}
    ...                       target_sw=${candidate_sw}

