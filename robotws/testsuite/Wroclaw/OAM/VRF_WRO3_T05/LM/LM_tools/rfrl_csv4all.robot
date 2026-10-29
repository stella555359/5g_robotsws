*** Settings ***
Documentation
...   author: Szymon Romanowski
...   contact: szymon.romanowski@nokia.com
...   Example test suite to perform upgrade before any other test

Library                         Collections
Library                         taf/rfrl/csv4all/CSV4AllTestCases.py
Resource                        taf/rfrl/uuf4all/uuf4all_keywords.robot


# set proper CA for RP reporting to work properly
#Force Tags                      CA_VRF_WRO3

# Suite setup uses keyword to fetch the build automatically from CM execution,
# remove if running from CLI
#Suite Setup                     Set Initial And Candidate

*** Variables ***

@{CUSTOMERS}=                   Generic
${INITIAL}=                     SBTS00_ENB_9999_251120_000005
${CANDIDATE}=                   SBTS00_ENB_9999_251124_000005
${UPGRADE_ITERATION}=           5
@{TEMP_ALLOWED_FAULTS}=         6203  4291  4700  7107  7116  4476    4290
@{CUSTOM_ALLOWED_ALARMS}        4700  7107  6203  4291  7116  4476    4290


&{node1}                        node_alias=LM_BTS
...                             testline_object=${tl.enbs[0]}
...                             source_sw=${INITIAL}
...                             target_sw=${CANDIDATE}
...                             temporary_allowed_alarms=${TEMP_ALLOWED_FAULTS}
...                             custom_allowed_alarms=${CUSTOM_ALLOWED_ALARMS}


@{nodes}                        ${node1}

*** Test Cases ***
E2E TL SW UPGRADE ROLLBACK WITH OAM KPI
    [Timeout]   72h
    # Here is where the magic happens, single keyword to run the upgrade
    # the bts to target software
    # after which you can continue with our scope

    e2e_tl_sw_upgrade_rollback_with_oam_kpi
    ...   nodes_details=${nodes}
    ...   test_nodes_details=${node1}
    ...   iterations_per_node=${UPGRADE_ITERATION}
    ...   report=${True}
    ...   customers_list=${CUSTOMERS}



#*** Keywords ***
#Set Initial And Candidate
#    ${initial_sw}             Get Source SW
#    ${candidate_sw}           Get Target SW
#    Set to dictionary         ${node1}
#    ...                       source_sw=${initial_sw}
#    ...                       target_sw=${candidate_sw}
