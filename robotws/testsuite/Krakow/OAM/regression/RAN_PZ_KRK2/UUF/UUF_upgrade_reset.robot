*** Settings ***
Documentation
...   Test suite for regression testing UUF
...   author: Piotr Bacior, piotr.bacior@nokia.com
...   Maintainer: Patryk Lamch, patryk.lamch@nokia.com


Library      testsuite/Krakow/resources/UUF/get_uuf_builds.py
Library      testsuite/Krakow/resources/UUF/upgrade_and_commission_bts.py
Resource     taf/rfrl/uuf4all/uuf4all_test_cases.robot
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py


Force Tags    STATE_SKIP_AGENT    RAN_5G    PY36

Suite Setup       Common Suite Setup With OnAir Test Line Preparation
...               swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt

Suite Teardown    common_setups_and_teardowns.Common Suite Teardown

Test Setup        common_setups_and_teardowns.Common Preconditions
Test Teardown     common_setups_and_teardowns.Common Postconditions With Restore Configuration If Test Failed

*** Variables ***
${UPDATE_TEST_ITERATION}            10
${SITE_RESET_TEST_ITERATION}        30

${RUNS_OF_UUF_UPGRADE}              ${3}
${SHOULD_BE_REPORTED}               True
@{CUSTOMERS_LIST}                   Generic
@{CRITICAL_FAULTS}                  0010  0016  1806  1868  4341  4352  4383
${5G_SOURCE_SW}                     ${None}
${5G_TARGET_SW}                     ${None}
${4G_SOURCE_SW}                     ${None}
${4G_TARGET_SW}                     ${None}
${UPDATE_TEST_FAILED}               ${False}
@{CUSTOM_ALLOWED_ALARMS}            No X2 link available  No X2 link available for a specific LTEENB
${QC_DOMAIN}                        MN_RAN
${QC_PROJECT}                       RAN_ST
*** Test Cases ***
[1.0] E2E_TL_SW_upgrade_rollback_with_OAM_KPI
    [Timeout]    24h
    UUF4ALL_SW_UPGRADE_TEST
    ...          test_iteration=${UPDATE_TEST_ITERATION}
    ...          customers_list=@{CUSTOMERS_LIST}
    ...          critical_faults=@{CRITICAL_FAULTS}
    ...          5g_source_sw=${5G_SOURCE_SW}
    ...          5g_target_sw=${5G_TARGET_SW}
    ...          4g_source_sw=${4G_SOURCE_SW}
    ...          4g_target_sw=${4G_TARGET_SW}
    ...          use_builds_storage=${False}
    ...          restore_to_target_sw=${True}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=${kpi_qc_ids['qc_upgrade']}
    ...          qc_project=${QC_PROJECT}
    [Teardown]    Custom Test Teardown

[1.0] E2E_TL_Site_reset_without_HWF_with_OAM_KPI
    [Timeout]    24h
    Run Keyword If    ${UPDATE_TEST_FAILED}    Fail
    UUF4ALL_SITE_RESET_TEST
    ...          test_iteration=${SITE_RESET_TEST_ITERATION}
    ...          customers_list=@{CUSTOMERS_LIST}
    ...          critical_faults=@{CRITICAL_FAULTS}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=${kpi_qc_ids['qc_site_reset']}
    ...          qc_project=${QC_PROJECT}

*** Keywords ***
Custom Test Teardown
    Run Keyword If Test Failed    Set Suite Variable    ${UPDATE_TEST_FAILED}    ${True}
    common_setups_and_teardowns.Common Postconditions With Restore Configuration If Test Failed
