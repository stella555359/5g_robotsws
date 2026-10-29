*** Settings ***
Documentation
...   author: Klaudia Horyn
...   contact: klaudia.horyn@nokia.com
...   Test suite for basic UUF OAM Tests in loop:

Library      taf/rfrl/csv4all/CSV4AllTestCases.py
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource     taf/rfrl/uuf4all/uuf4all_keywords.robot
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py

Suite Setup       Common Suite Setup With OnAir Test Line Preparation
...               swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt
...               prefix_tag=CB008911
...               list_of_additional_allowed_alarms=@{PREPARATION_ALARMS}
...               increase_timeout_for_update_sw=3600

Suite Teardown    Common Suite Teardown
Test Setup        Common Preconditions
Test Teardown     Common Postconditions With Restore Configuration If Test Failed

*** Variables ***
${UPDATE_TEST_ITERATION}            5
${SITE_RESET_TEST_ITERATION}        30
@{CUSTOMERS_LIST}=                  TMO US
${5G_SOURCE_SW}=                    ${Empty}
${5G_TARGET_SW}=                    ${Empty}
${QC_DOMAIN}=                       MN_RAN
${QC_PROJECT}=                      RAN_VRF
${QC_ID_UPGRADE}=                   217026
${QC_ID_RESET}=                     217028
${RP_LOCATION}                      VRF_KRK
${RP_ORGANIZATION}                  VRF_KRK_T06
${RP_CA}                            VRF_RRM
@{PREPARATION_ALARMS}               4298     7115
&{BTS0}                             node_alias=T2SK005
...                                 testline_object=${tl.gnbs[0]}
...                                 source_sw=${5G_SOURCE_SW}
...                                 target_sw=${5G_TARGET_SW}
...                                 temporary_allowed_alarms=${PREPARATION_ALARMS}
@{NODES}                            ${BTS0}
${REPORT}=                          True
${RESTORE_TO_TARGET_SW}             True
${STOP_TEST_AFTER_FAIL}             False

*** Test Cases ***
[1][1.0] E2E_TL_SW_upgrade_rollback_with_OAM_KPI
    [Timeout]    96h
    ${5G_SOURCE_SW}=    Run Keyword If  '${5G_SOURCE_SW}'=='${Empty}'  Get Source SW
    ...   ELSE  set variable  ${5G_SOURCE_SW}
    ${5G_TARGET_SW}=    Run Keyword If  '${5G_TARGET_SW}'=='${Empty}'  Get Target SW
    ...   ELSE  set variable  ${5G_TARGET_SW}
    Set To Dictionary    ${BTS0}    source_sw=${5G_SOURCE_SW}    target_sw=${5G_TARGET_SW}

    e2e_tl_sw_upgrade_rollback_with_oam_kpi
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODES}
    ...    iterations_per_node=${UPDATE_TEST_ITERATION}
    ...    report=${REPORT}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${QC_ID_UPGRADE}
    ...    qc_project=${QC_PROJECT}
    ...    customers_list=${CUSTOMERS_LIST}
    ...    restore_to_target_sw=${RESTORE_TO_TARGET_SW}
    ...    stop_test_after_fail=${STOP_TEST_AFTER_FAIL}

[1][1.0] E2E_TL_Activation_Reset_with_OAM_KPI
    [Timeout]    96h
    e2e_tl_activation_reset_test
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODES}
    ...    iterations_per_node=${SITE_RESET_TEST_ITERATION}
    ...    report=${REPORT}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${QC_ID_RESET}
    ...    qc_project=${QC_PROJECT}
    ...    customers_list=${CUSTOMERS_LIST}
    ...    stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
