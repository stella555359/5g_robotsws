*** Settings ***
Documentation
...   Test suite for regression testing of UUF
...   author: Piotr Bacior
...   contact: piotr.bacior@nokia.com

Library      testsuite/Krakow/resources/UUF/get_uuf_builds.py
Library      testsuite/Krakow/resources/UUF/upgrade_and_commission_bts.py
Resource     taf/rfrl/uuf4all/uuf4all_test_cases.robot
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py


Force Tags    CA_VRF_KRK

Suite Setup       Common Suite Setup With OnAir Test Line Preparation
...               swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt

Suite Teardown    common_setups_and_teardowns.Common Suite Teardown

Test Setup        common_setups_and_teardowns.Common Preconditions
Test Teardown     common_setups_and_teardowns.Common Postconditions With Restore Configuration If Test Failed


*** Variables ***
${UPDATE_TEST_ITERATION}            10

${SHOULD_BE_REPORTED}=  True
@{CUSTOMERS_LIST}=      Generic
@{CRITICAL_FAULTS}=     0010  0016  1806  1868  4341  4352  4383
${5G_SOURCE_SW}=        ${None}
${5G_TARGET_SW}=        ${None}
${4G_SOURCE_SW}=        ${None}
${4G_TARGET_SW}=        ${None}
${UPDATE_TEST_FAILED}   ${False}
${QC_DOMAIN}=           MN_RAN
${QC_PROJECT}=          RAN_ST
${QC_ID_UPGRADE}=       ${None}
@{CUSTOM_ALARMS}=       ${None}


*** Test Cases ***
SW_upgrade_and_rollback_NSA_CPRI_TDD_FDD_ASIK_N-4-N
    UUF4ALL_SW_UPGRADE_TEST
    ...          test_iteration=${UPDATE_TEST_ITERATION}
    ...          customers_list=@{CUSTOMERS_LIST}
    ...          critical_faults=@{CRITICAL_FAULTS}
    ...          5g_source_sw=${5G_SOURCE_SW}
    ...          5g_target_sw=${5G_TARGET_SW}
    ...          remote_node_update=${False}
    ...          use_builds_storage=${False}
    ...          restore_to_target_sw=${False}
    ...          use_remote_node=${False}
    ...          custom_alarms=${CUSTOM_ALARMS}

SW_upgrade_and_rollback_SA_eCPRI_TDD_ASIL_Gen4_prrh_N-2-N
    UUF4ALL_SW_UPGRADE_TEST
    ...          test_iteration=${UPDATE_TEST_ITERATION}
    ...          customers_list=@{CUSTOMERS_LIST}
    ...          critical_faults=@{CRITICAL_FAULTS}
    ...          5g_source_sw=${5G_SOURCE_SW}
    ...          5g_target_sw=${5G_TARGET_SW}
    ...          remote_node_update=${False}
    ...          use_builds_storage=${False}
    ...          restore_to_target_sw=${False}
    ...          use_remote_node=${False}
    ...          custom_alarms=${CUSTOM_ALARMS}

SW_upgrade_and_rollback_SA_ECPRI_TDD_ASOE_N-1-N
    UUF4ALL_SW_UPGRADE_TEST
    ...          test_iteration=${UPDATE_TEST_ITERATION}
    ...          customers_list=@{CUSTOMERS_LIST}
    ...          critical_faults=@{CRITICAL_FAULTS}
    ...          5g_source_sw=${5G_SOURCE_SW}
    ...          5g_target_sw=${5G_TARGET_SW}
    ...          remote_node_update=${False}
    ...          use_builds_storage=${False}
    ...          restore_to_target_sw=${False}
    ...          use_remote_node=${False}
    ...          custom_alarms=${CUSTOM_ALARMS}

SW_upgrade_and_rollback_SA_CPRI_FDD_ASIM_N-0-N
    UUF4ALL_SW_UPGRADE_TEST
    ...          test_iteration=${UPDATE_TEST_ITERATION}
    ...          customers_list=@{CUSTOMERS_LIST}
    ...          critical_faults=@{CRITICAL_FAULTS}
    ...          5g_source_sw=${5G_SOURCE_SW}
    ...          5g_target_sw=${5G_TARGET_SW}
    ...          remote_node_update=${False}
    ...          use_builds_storage=${False}
    ...          restore_to_target_sw=${False}
    ...          use_remote_node=${False}
    ...          custom_alarms=${CUSTOM_ALARMS}

*** Keywords ***
Custom Test Teardown
    Run Keyword If Test Failed    Set Suite Variable  ${UPDATE_TEST_FAILED}  ${True}
    common_setups_and_teardowns.Common Postconditions With Restore Configuration If Test Failed



