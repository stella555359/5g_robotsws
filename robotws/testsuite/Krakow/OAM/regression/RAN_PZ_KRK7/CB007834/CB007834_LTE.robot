*** Settings ***
Documentation
...   Test suite for CB007834 E2E TMO
...   author: Dominik Wieczorek
...   contact: dominik.wieczorek@nokia.com

Library      String
Library      taf.rfrl.csv4all.CSV4AllTestCases
Library      taf.rfrl.utilities.cloud_manager.artifacts
Library      testsuite/Krakow/resources/UUF/get_uuf_builds.py
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Resource     ./resources/keywords.robot

Suite Setup    Custom Suite Setup
Suite Teardown    Common Suite Teardown
Test Setup       Custom Preconditions With Watching Alarms
Test Teardown    Custom Postconditions With Watching Alarms

*** Variables ***
@{PREPARATION_ALARMS}       No connection to unit
...                         Cell problem due to associated X2 links and/or NG links and/or E1 link unavailability
...                         Failure detected on assigned antennas

@{CUSTOM_ALLOWED_ALARMS}    8000    6261
...                         Failure in connection between BTS and 3rd party tool
...                         Failure in internal BTS connection or connection to 3rd party tool
...                         User Account has Default Password
...                         Cell problem due to associated X2 links and/or NG links and/or E1 link unavailability
...                         Failure detected on assigned antennas
...                         Cell blocked
...                         Setup of X2 connectivity to gNB failed
...                         No X2 link available for a specific LTEENB
...                         No X2 link available
...                         BTS Reset Cause
...                         Cell problem due to unavailability of associated links

@{ASIR_ALLOWED_ALARMS}      ${61648}

${SOURCE_SW}                ${None}
${TARGET_SW}                ${None}

&{NETACT_DICT}
...                         name=${tl.netact_name}
...                         username=${tl.nms.netact.ssh_connections_info.username}
...                         password=${tl.nms.netact.ssh_connections_info.password}
...                         ip_version=IPv4
...                         security_mode=no TLS
...                         netact_host_ip=${tl.nms.netact.ssh_connections_info.addr}

&{NODE2}                    testline_object=${tl.gnbs[1]}
...                         node_alias=4gANCHOR
...                         source_sw=${SOURCE_SW}
...                         target_sw=${TARGET_SW}
...                         custom_allowed_alarms=${CUSTOM_ALLOWED_ALARMS}
...                         testline_scout_name=${SCOUT_HOSTNAME_LTE}

${SCOUT_HOSTNAME_LTE}       ${None}

@{LTE_NODES}                ${NODE2}

${CUSTOMERS_LIST}           TMO US
${QC_DOMAIN}                MN_RAN
${QC_PROJECT}               RAN_VRF

${RP_CA}                    VRF_OAM
${RP_ORGANIZATION}          VRF_KRK_T07
${RP_LOCATION}              VRF_KRK

${UPDATE_TEST_ITERATION}                     5
${ACTIVATION_RESET_TEST_ITERATION}           20
${SITE_RESET_TEST_ITERATION}                 10
${BBMOD_RESET_TEST_ITERATION}                10
${SHUB_RESET_TEST_ITERATION}                 20
${CELL_LOCK_UNLOCK_TEST_ITERATION}           3
${CELL_BLOCK_UNBLOCK_TEST_ITERATION}         3
${DELTA_COMMISSIONING_TEST_ITERATION}        1

*** Test Cases ***
E2E_TL_SW_upgrade_rollback_with_OAM_KPI_LTE
    [Tags]    uuf    upgrade
    ${QC_ID}=             bts_data.Get Qc Ids   ${TARGET_SW}

    E2E TL SW UPGRADE ROLLBACK WITH OAM KPI
    ...                                     nodes_details=${LTE_NODES}
    ...                                     test_nodes_details=${NODE2}
    ...                                     iterations_per_node=${UPDATE_TEST_ITERATION}
    ...                                     report=${True}
    ...                                     qc_domain=${QC_DOMAIN}
    ...                                     qc_project=${QC_PROJECT}
    ...                                     qc_id=${QC_ID['qc_upgrade_lte']}
    ...                                     sw_build=${TARGET_SW}
    ...                                     customers_list=@{CUSTOMERS_LIST}
    ...                                     restore_to_target_sw=${True}

[1][1.0] E2E_TL_Activation_Reset_with_OAM_KPI
    [Timeout]    96h
    [Tags]    uuf    activation_reset
    gnbbbu.Disconnect
    ${QC_ID}=             bts_data.Get Qc Ids   ${TARGET_SW}
    E2E TL ACTIVATION RESET TEST
    ...                                     nodes_details=${LTE_NODES}
    ...                                     test_nodes_details=${NODE2}
    ...                                     iterations_per_node=${ACTIVATION_RESET_TEST_ITERATION}
    ...                                     report=${True}
    ...                                     qc_domain=${QC_DOMAIN}
    ...                                     qc_project=${QC_PROJECT}
    ...                                     qc_id=${QC_ID['qc_activation_reset_lte']}
    ...                                     sw_build=${TARGET_SW}
    ...                                     customers_list=@{CUSTOMERS_LIST}

E2E_TL_Site_Reset_with_OAM_KPI_LTE
    [Timeout]    96h
    [Tags]    uuf    site_reset
    gnbbbu.Disconnect
    ${QC_ID}=                 bts_data.Get Qc Ids   ${TARGET_SW}
    E2E TL SITE RESET WITH OAM KPI
    ...                                     nodes_details=${LTE_NODES}
    ...                                     test_nodes_details=${NODE2}
    ...                                     iterations_per_node=${SITE_RESET_TEST_ITERATION}
    ...                                     report=${True}
    ...                                     qc_domain=${QC_DOMAIN}
    ...                                     qc_project=${QC_PROJECT}
    ...                                     qc_id=${QC_ID['qc_site_reset_lte']}
    ...                                     sw_build=${TARGET_SW}
    ...                                     customers_list=@{CUSTOMERS_LIST}

E2E_TL_RU_Reset_with_OAM_KPI_LTE
    [Tags]    ru_reset
    Reset Hub In Loop    iterations=${SHUB_RESET_TEST_ITERATION}
    ...                  allowed_alarms=@{ASIR_ALLOWED_ALARMS}
    ...                  bts_id=1

E2E_TL_Capacity_Module_Reset_with_OAM_KPI_LTE
    [Timeout]    96h
    [Tags]    bbmod_reset
    E2E TL CAPACITY MODULE RESET WITH OAM KPI
    ...                                     nodes_details=${LTE_NODES}
    ...                                     test_nodes_details=${NODE2}
    ...                                     iterations_per_node=${BBMOD_RESET_TEST_ITERATION}
    ...                                     report=${False}

E2E_TL_Cell_Lock_Unlock_LTE_with_OAM_KPI
    [Tags]    cell_lock
    E2E TL CELL LOCK UNLOCK LTE WITH OAM KPI
    ...                                     nodes_details=${LTE_NODES}
    ...                                     test_nodes_details=${NODE2}
    ...                                     iterations_per_node=${CELL_LOCK_UNLOCK_TEST_ITERATION}
    ...                                     report=${False}

E2E_TL_Cell_Block_Unblock_LTE_with_OAM_KPI
    [Timeout]   24h
    [Tags]    cell_block
    E2E TL CELL BLOCK UNBLOCK LTE WITH OAM KPI
    ...                                     nodes_details=${LTE_NODES}
    ...                                     test_nodes_details=${NODE2}
    ...                                     iterations_per_node=${CELL_BLOCK_UNBLOCK_TEST_ITERATION}
    ...                                     report=${False}

E2E_TL_Delta_Commissioning_With_Online_Parameter_Modification
    [Tags]    delta_online    delta
    ${DELTA_PARAM}=    Get Online Parameters Delta on Enb
    E2E TL DELTA COMMISSIONING WITH ONLINE PARAMETER MODIFICATION
    ...                                     nodes_details=${LTE_NODES}
    ...                                     test_nodes_details=${NODE2}
    ...                                     iterations_per_node=${DELTA_COMMISSIONING_TEST_ITERATION}
    ...                                     delta=${DELTA_PARAM}
    ...                                     report=${False}

E2E_TL_Delta_Commissioning_With_Site_Reset_Required
    [Tags]    delta_site_reset    delta
    ${DELTA_PARAM}=    Get Site Reset Delta on Enb
    E2E TL DELTA COMMISSIONING WITH SITE RESET REQUIRED
    ...                                     nodes_details=${LTE_NODES}
    ...                                     test_nodes_details=${NODE2}
    ...                                     iterations_per_node=${DELTA_COMMISSIONING_TEST_ITERATION}
    ...                                     delta=${DELTA_PARAM}
    ...                                     report=${False}

E2E_TL_Delta_Commissioning_With_LTE_Rat_Reset
    [Tags]    delta_rat_reset    delta
    ${DELTA_PARAM}=    Get LTE Rat Reset Delta on Enb
    E2E TL DELTA COMMISSIONING WITH ONLINE PARAMETER MODIFICATION
    ...                                     nodes_details=${LTE_NODES}
    ...                                     test_nodes_details=${NODE2}
    ...                                     iterations_per_node=${DELTA_COMMISSIONING_TEST_ITERATION}
    ...                                     delta=${DELTA_PARAM}
    ...                                     report=${False}

*** Keywords ***
Custom Suite Setup
    Run Keywords    Prepare gNB Neighbour
    ...      AND    Common Suite Setup With OnAir Test Line Preparation    should_5G_neighbour_be_changed=${False}
    ...                                                    swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt
    ...                                                    upload_swconfig_to_neighbour=${False}
    ...                                                    enable_sleeping_cell_detection=${False}
    ...                                                    list_of_additional_allowed_alarms=${PREPARATION_ALARMS}

    ${SOURCE_SW} =          IF    '${SOURCE_SW}'=='${None}'         Get CM Source Build    ELSE    Set Variable  ${SOURCE_SW}
    ${TARGET_SW} =          IF    '${TARGET_SW}'=='${None}'         Get Target Build       ELSE    Set Variable  ${TARGET_SW}
    @{CUSTOMERS_LIST} =     IF    '${CUSTOMERS_LIST}'!='${None}'    Split String    ${CUSTOMERS_LIST}    ,    ELSE    Create List    Generic
    ${SCOUT_HOSTNAME_LTE} =     IF    '${SCOUT_HOSTNAME_LTE}'=='${None}'    bts_data.Get Scout BTS Name LTE
    ...                                                             ELSE    Set Variable    ${SCOUT_HOSTNAME_LTE}

    Set Global Variable  ${SOURCE_SW}
    Set Global Variable  ${TARGET_SW}
    Set Global Variable  @{CUSTOMERS_LIST}
    Set Global Variable  ${SCOUT_HOSTNAME_LTE}

Remove Dirs
    [Arguments]    @{directory_path}
    FOR    ${dir}    IN    @{directory_path}
        ${status}=    Run Keyword And Return Status    Directory Should Exist    ${dir}
        Run Keyword If    ${status}    Remove Directory    ${dir}    force=True
    END

Custom Preconditions With Watching Alarms
    Common Preconditions With Watching Alarms
    Remove Dirs       directory_path=/home/ute/.ute-ca/cache/bts/
    gnbalarm.Start watching alarms     bts_id=1    allowed_alarms=${allowed_alarms}
    gnbalarm.Watch Active Alarms and Collect Logs on Unexpected    bts_id=1

    Set To Dictionary    ${NODE2}    source_sw    ${SOURCE_SW}
    Set To Dictionary    ${NODE2}    target_sw    ${TARGET_SW}
    @{LTE_NODES}=    Create List    ${NODE2}
    Set Global Variable  @{LTE_NODES}

Custom Postconditions With Watching Alarms
    gnbbbu.connect    force=${True}
    Common Postconditions       collect_syslog=${True}

    [Teardown]    Run Keywords    gnb_alarm.Stop watching alarms
    ...                    AND    gnbalarm.Stop watching alarms    bts_id=1
    ...                    AND    Remove Custom Allowed Alarms If Defined
