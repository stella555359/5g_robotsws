*** Settings ***
Documentation
...   maintainer: Bartosz Kozlowski
...   contact: bartosz.1.kozlowski@nokia.com
...   Test suite for basic UUF site reset in loop. Handled via csv4all.

Library         taf/rfrl/csv4all/CSV4AllTestCases.py
Variables       testsuite/Wroclaw/RRM/VRF_WRO2_T07/regression/E2E_run/e2e_resources.py

*** Variables ***
${RP_CA}                       VRF_RRM
${RP_LOCATION}                 VRF_WRO2
${RP_ORGANIZATION}             VRF_WRO2_T07
${BTS_HOST_IP}=                192.168.255.1
${TEST_ITERATION}              20
@{CRITICAL_FAULTS}             10
${SHOULD_BE_REPORTED}          ${False}
@{CUSTOMERS_LIST}              Generic
#${SCOUT_HOSTNAME}              10_16_MRBTS-41810            # Uncomment & modify for lines where hostname != scout name

&{GNB1}     node_alias=5G               testline_object=${tl.gnbs[0]}
...         critical_alarms=@{CRITICAL_FAULTS}     custom_allowed_alarms=${CUSTOM_ALARMS}
#...         testline_scout_name=${SCOUT_HOSTNAME}

@{NODES}                    ${GNB1}

*** Test Cases ***
UUF4ALL_SITE_RESET_TEST
    [Timeout]   24h
    E2E TL SITE RESET WITH OAM KPI
    ...         nodes_details=@{NODES}
    ...         test_nodes_details=&{GNB1}
    ...         iterations_per_node=${TEST_ITERATION}
    ...         report=${SHOULD_BE_REPORTED}
    ...         customers_list=@{CUSTOMERS_LIST}