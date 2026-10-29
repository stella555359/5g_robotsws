*** Settings ***
Documentation
...   Suite for  testing UUF for USCC
...   author: Piotr Bacior
...   contact: piotr.bacior@nokia.com

Library      String
Library      taf.rfrl.csv4all.CSV4AllTestCases
Library      taf.rfrl.utilities.cloud_manager.artifacts
Library      testsuite/Krakow/resources/UUF/get_uuf_builds.py
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py


Force Tags    CA_VRF_KRK    QCD_MN_RAN    QCP_RAN_VRF

Suite Setup       Custom Suite Setup
Suite Teardown    common_setups_and_teardowns.Common Suite Teardown

Test Setup        Custom Test Setup
Test Teardown     common_setups_and_teardowns.Common Postconditions With Restore Configuration If Test Failed

*** Variables ***
${SOURCE_SW}                                    SBTS25R2_ENB_0000_000606_000015
${TARGET_SW}                                    SBTS00_ENB_9999_251018_000012
${CUSTOMERS_LIST}                               Reliance India     # Customer list separated by comma
@{CUSTOM_ALARMS}                                @{EMPTY}
@{CUSTOM_ALLOWED_ALARMS_DURING_TL_PREPARATION}	    Create List
...                                                 Wifi Enabled Alarm
...                                                 NRRELNotConfiguredA3A5
${SYSLOG_IGNORED_PRINTS}                        ${None}     # String separated by |
${SWCONFIG_PATH}                                commissionings/Krakow/swconfig/default_swconfig.txt

&{NODE1}                            testline_object=${tl.gnbs[0]}
...                                 source_sw=${SOURCE_SW}
...                                 target_sw=${TARGET_SW}
...                                 custom_allowed_alarms=${CUSTOM_ALARMS}
...                                 syslog_ignored_prints=${SYSLOG_IGNORED_PRINTS}

@{NODES}                            ${NODE1}

${UPDATE_TEST_ITERATION}                    5
${ACTIVATION_RESET_TEST_ITERATION}          10
${SITE_RESET_TEST_ITERATION}                10
${RU_RESET_TEST_ITERATION}                  20
${CELL_LOCK_TEST_ITERATION}                 1
${CELL_BLOCK_TEST_ITERATION}                1
${COMM_ONLINE_TEST_ITERATION}               1
${COMM_RESET_TEST_ITERATION}                1
${COMM_RAT_TEST_ITERATION}                  1

${QC_DOMAIN}                        MN_RAN
${QC_PROJECT}                       RAN_VRF

#trunk
${QC_ID_UPGRADE}                    184901
${QC_ID_RESET}                      184907
${QC_ID_ACTIV_RESET}                184908
${QC_ID_RU_RESET}                   184902
${QC_ID_CELL_BLOCK}                 184900
${QC_ID_CELL_LOCK}                  184899
${QC_ID_COMM_ONLINE}                184905
${QC_ID_COMM_RESET}                 184898
${QC_ID_COMM_RAT}                   184903

${RP_CA}                            VRF_OAM
${RP_ORGANIZATION}                  VRF_KRK_T01
${RP_LOCATION}                      VRF_KRK


*** Test Cases ***
E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI
    [Timeout]    96h
    [Tags]    UUF

    Run Keyword If  '${QC_ID_UPGRADE}'!='${None}'    Set Tags    QC_${QC_ID_UPGRADE}
    Set To Dictionary    ${NODE1}    source_sw    ${SOURCE_SW}
    Set To Dictionary    ${NODE1}    target_sw    ${TARGET_SW}

    E2E TL SW UPGRADE ROLLBACK WITH OAM KPI
    ...                                     nodes_details=${NODES}
    ...                                     test_nodes_details=${NODE1}
    ...                                     iterations_per_node=${UPDATE_TEST_ITERATION}
    ...                                     report=${True}
    ...                                     qc_domain=${QC_DOMAIN}
    ...                                     qc_project=${QC_PROJECT}
    ...                                     qc_id=${QC_ID_UPGRADE}
    ...                                     sw_build=${TARGET_SW}
    ...                                     customers_list=@{CUSTOMERS_LIST}
    ...                                     restore_to_target_sw=${True}

    [Teardown]    Custom Test Teardown

E2E_TL_Activation_Reset_Test
    [Timeout]    96h
    [Tags]    SITE_RESET

    Run Keyword If  '${QC_ID_ACTIV_RESET}'!='${None}'    Set Tags    QC_${QC_ID_ACTIV_RESET}
    gnbbbu.Disconnect
    E2E TL ACTIVATION RESET TEST
    ...                                     nodes_details=${NODES}
    ...                                     test_nodes_details=${NODE1}
    ...                                     iterations_per_node=${ACTIVATION_RESET_TEST_ITERATION}
    ...                                     report=${True}
    ...                                     qc_domain=${QC_DOMAIN}
    ...                                     qc_project=${QC_PROJECT}
    ...                                     qc_id=${QC_ID_ACTIV_RESET}
    ...                                     sw_build=${TARGET_SW}
    ...                                     customers_list=@{CUSTOMERS_LIST}

E2E_TL_Site_Reset_with_OAM_KPI
    [Timeout]   24h

    Run Keyword If  '${QC_ID_RESET}'!='${None}'    Set Tags    QC_${QC_ID_RESET}
    gnbbbu.Disconnect
    E2E TL SITE RESET WITH OAM KPI
    ...                                     nodes_details=${NODES}
    ...                                     test_nodes_details=${NODE1}
    ...                                     iterations_per_node=${SITE_RESET_TEST_ITERATION}
    ...                                     report=${True}
    ...                                     qc_domain=${QC_DOMAIN}
    ...                                     qc_project=${QC_PROJECT}
    ...                                     qc_id=${QC_ID_RESET}
    ...                                     customers_list=@{CUSTOMERS_LIST}

E2E_TL_RU_Reset_with_OAM_KPI
    [Timeout]   24h

    Run Keyword If  '${QC_ID_RU_RESET}'!='${None}'    Set Tags    QC_${QC_ID_RU_RESET}
    gnbbbu.Disconnect
    E2E TL RU RESET WITH OAM KPI
    ...                                     nodes_details=${NODES}
    ...                                     test_nodes_details=${NODE1}
    ...                                     iterations_per_node=${RU_RESET_TEST_ITERATION}
    ...                                     report=${True}
    ...                                     qc_domain=${QC_DOMAIN}
    ...                                     qc_project=${QC_PROJECT}
    ...                                     qc_id=${QC_ID_RU_RESET}
    ...                                     customers_list=@{CUSTOMERS_LIST}

E2E_TL_Cell_Lock_Unlock_NR_with_OAM_KPI
    [Timeout]   24h

    Run Keyword If  '${QC_ID_CELL_LOCK}'!='${None}'    Set Tags    QC_${QC_ID_CELL_LOCK}
    gnbbbu.Disconnect
    E2E TL CELL LOCK UNLOCK NR WITH OAM KPI
    ...                                     nodes_details=${NODES}
    ...                                     test_nodes_details=${NODE1}
    ...                                     iterations_per_node=${CELL_LOCK_TEST_ITERATION}
    ...                                     report=${True}
    ...                                     qc_domain=${QC_DOMAIN}
    ...                                     qc_project=${QC_PROJECT}
    ...                                     qc_id=${QC_ID_CELL_LOCK}
    ...                                     customers_list=@{CUSTOMERS_LIST}

E2E_TL_Cell_Block_Unblock_NR_with_OAM_KPI
    [Timeout]   24h

    Run Keyword If  '${QC_ID_CELL_BLOCK}'!='${None}'    Set Tags    QC_${QC_ID_CELL_BLOCK}
    gnbbbu.Disconnect
    E2E TL CELL BLOCK UNBLOCK NR WITH OAM KPI
    ...                                     nodes_details=${NODES}
    ...                                     test_nodes_details=${NODE1}
    ...                                     iterations_per_node=${CELL_BLOCK_TEST_ITERATION}
    ...                                     report=${True}
    ...                                     qc_domain=${QC_DOMAIN}
    ...                                     qc_project=${QC_PROJECT}
    ...                                     qc_id=${QC_ID_CELL_BLOCK}
    ...                                     customers_list=@{CUSTOMERS_LIST}

E2E_TL_Delta_Commissioning_With_Online_Parameter_Modification
    [Timeout]   24h

    Run Keyword If  '${QC_ID_COMM_ONLINE}'!='${None}'    Set Tags    QC_${QC_ID_COMM_ONLINE}
    gnbbbu.Disconnect
    E2E TL DELTA COMMISSIONING WITH ONLINE PARAMETER MODIFICATION
    ...                                     nodes_details=${NODES}
    ...                                     test_nodes_details=${NODE1}
    ...                                     iterations_per_node=${COMM_ONLINE_TEST_ITERATION}
    ...                                     report=${True}
    ...                                     qc_domain=${QC_DOMAIN}
    ...                                     qc_project=${QC_PROJECT}
    ...                                     qc_id=${QC_ID_COMM_ONLINE}
    ...                                     customers_list=@{CUSTOMERS_LIST}

E2E_TL_Delta_Commissioning_With_Site_Reset_Required
    [Timeout]   24h

    Run Keyword If  '${QC_ID_COMM_RESET}'!='${None}'    Set Tags    QC_${QC_ID_COMM_RESET}
    gnbbbu.Disconnect
    E2E TL DELTA COMMISSIONING WITH SITE RESET REQUIRED
    ...                                     nodes_details=${NODES}
    ...                                     test_nodes_details=${NODE1}
    ...                                     iterations_per_node=${COMM_RESET_TEST_ITERATION}
    ...                                     report=${True}
    ...                                     qc_domain=${QC_DOMAIN}
    ...                                     qc_project=${QC_PROJECT}
    ...                                     qc_id=${QC_ID_COMM_RESET}
    ...                                     customers_list=@{CUSTOMERS_LIST}

E2E_TL_Delta_Commissioning_With_NR_Rat_Reset
    [Timeout]   24h

    Run Keyword If  '${QC_ID_COMM_RAT}'!='${None}'    Set Tags    QC_${QC_ID_COMM_RAT}
    gnbbbu.Disconnect
    E2E TL DELTA COMMISSIONING WITH NR RAT RESET
    ...                                     nodes_details=${NODES}
    ...                                     test_nodes_details=${NODE1}
    ...                                     iterations_per_node=${COMM_RAT_TEST_ITERATION}
    ...                                     delta=testsuite/Krakow/SISO/regression/RAN_PZ_KRK1/CB007835/resources/delta_RJIO.json
    ...                                     report=${True}
    ...                                     qc_domain=${QC_DOMAIN}
    ...                                     qc_project=${QC_PROJECT}
    ...                                     qc_id=${QC_ID_COMM_RAT}
    ...                                     customers_list=@{CUSTOMERS_LIST}

*** Keywords ***
Custom Suite Setup
    Common Suite Setup With OnAir Test Line Preparation
    ...                         increase_timeout_for_update_sw=${1800}
    ...                         list_of_additional_allowed_alarms=${CUSTOM_ALLOWED_ALARMS_DURING_TL_PREPARATION}
    ...                         swconfig_from_path=${SWCONFIG_PATH}

    ${SOURCE_SW} =          IF    '${SOURCE_SW}'=='${None}'         Get CM Source Build    ELSE    Set Variable  ${SOURCE_SW}
    ${TARGET_SW} =          IF    '${TARGET_SW}'=='${None}'         Get Target Build       ELSE    Set Variable  ${TARGET_SW}
    @{CUSTOMERS_LIST} =     IF    '${CUSTOMERS_LIST}'!='${None}'    Split String    ${CUSTOMERS_LIST}    ,    ELSE    Create List    Generic

    Set Global Variable  ${SOURCE_SW}
    Set Global Variable  ${TARGET_SW}
    Set Global Variable  @{CUSTOMERS_LIST}

Custom Test Setup
    common_setups_and_teardowns.Common Preconditions
    ...    collect_syslog=${False}
    ...    collect_ru_console_log=${False}
    Run Keyword And Ignore Error    Remove Directory         path=/home/ute/.ute-ca/cache/bts/    recursive=${True}

Custom Test Teardown
    gnbbbu.connect    force=${True}
    common_setups_and_teardowns.Common Postconditions With Restore Configuration If Test Failed
    ...    collect_snapshot_from_ru=${False}























