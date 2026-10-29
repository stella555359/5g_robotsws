*** Settings ***
Documentation   Test suite for basic UUF OAM Tests in loop

Resource        taf/rfrl/uuf4all/uuf4all_test_cases.robot

Force Tags      CA_RAN_PZ_WRO_4

*** Variables ***
${UPDATE_TEST_ITERATION}            10
${SITE_RESET_TEST_ITERATION}        30
@{CUSTOMERS_LIST}                   Generic
${SHOULD_BE_REPORTED}               ${True}
@{CUSTOM_ALARMS}                    @{EMPTY}
@{CRITICAL_FAULTS}                  @{EMPTY}
${5G_SOURCE_SW}                     ${None}
${5G_TARGET_SW}                     ${None}
${5G_TARGET_SW_PATH}                ${None}
${USE_REMOTE_NODE}                  ${False}
${RESTORE_TO_TARGET_SW}             ${True}
${USE_BUILDS_STORAGE}               ${False}
${UPDATE_TEST_FAILED}               ${False}

*** Test Cases ***
E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI
    [Timeout]   24h
    UUF4ALL_SW_UPGRADE_TEST
    ...          test_iteration=${UPDATE_TEST_ITERATION}
    ...          custom_alarms=@{CUSTOM_ALARMS}
    ...          critical_faults=@{CRITICAL_FAULTS}
    ...          should_be_reported=${SHOULD_BE_REPORTED}
    ...          customers_list=@{CUSTOMERS_LIST}
    ...          5g_source_sw=${5G_SOURCE_SW}
    ...          5g_target_sw=${5G_TARGET_SW}
    ...          5g_target_sw_path=${5G_TARGET_SW_PATH}
    ...          use_remote_node=${USE_REMOTE_NODE}
    ...          use_builds_storage=${USE_BUILDS_STORAGE}
    ...          restore_to_target_sw=${RESTORE_TO_TARGET_SW}
    [Teardown]   Run Keyword If Test Failed   Set Update Test Failed

*** Keywords ***
Set Update Test Failed
    Set Suite Variable  ${UPDATE_TEST_FAILED}  ${True}
