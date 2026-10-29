*** Settings ***
Documentation
...   Generic suite for  testing UUF
...   author: Tomasz Krol
...   contact: tomasz.krol@nokia.com

Library      String
Library      taf.rfrl.csv4all.CSV4AllTestCases
Library      taf.rfrl.utilities.cloud_manager.artifacts
Library      testsuite/Krakow/resources/UUF/get_uuf_builds.py
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py

Force Tags        CA_VRF_KRK

Suite Setup       Custom Suite Setup
Suite Teardown    common_setups_and_teardowns.Common Suite Teardown

Test Setup        Custom Test Setup
Test Teardown     common_setups_and_teardowns.Common Postconditions With Restore Configuration If Test Failed
...               collect_syslog=${False}

*** Variables ***
${SOURCE_SW}                                    ${None}
${TARGET_SW}                                    ${None}
@{CUSTOMERS_LIST}                               GENERIC
@{CUSTOM_ALARMS}                                6134  7509  6351  4420  4589  4334
${CUSTOM_ALLOWED_ALARMS}                        4334
${CUSTOM_ALLOWED_ALARMS_DURING_TL_PREPARATION}  4334
${SYSLOG_IGNORED_PRINTS}                        ${None}
${EMAIL_RECIPIENTS}                             przemyslaw.glod@nokia.com

&{NODE1}                            testline_object=${tl.gnbs[0]}
...                                 source_sw=${SOURCE_SW}
...                                 target_sw=${TARGET_SW}
...                                 custom_allowed_alarms=${CUSTOM_ALARMS}
...                                 syslog_ignored_prints=${SYSLOG_IGNORED_PRINTS}

@{NODES}                            ${NODE1}

${RP_CA}                            VRF_SiSo
${RP_LOCATION}                      VRF_KRK
${RP_ORGANIZATION}                  VRF_KRK_T05

${SHOULD_BE_REPORTED}               True
${UPDATE_TEST_ITERATION}            15
${SITE_RESET_TEST_ITERATION}        0

${QC_DOMAIN}                        MN_RAN
${QC_PROJECT}                       RAN_VRF
${QC_ID_RESET}                      ${None}
${QC_ID_UPGRADE}=                   ${None}


*** Test Cases ***
N-3-N_SW_upgrade_and_rollback_mmW_ASIB_AWKUC
    [Timeout]    96h
    [Tags]    UUF

    Run Keyword If  '${QC_ID_UPGRADE}'!='${None}'    Set Tags    QC_${QC_ID_UPGRADE}
    Set To Dictionary    ${NODE1}    source_sw    ${SOURCE_SW}
    Set To Dictionary    ${NODE1}    target_sw    ${TARGET_SW}

    E2E TL SW UPGRADE ROLLBACK WITH OAM KPI
    ...                                     nodes_details=${NODES}
    ...                                     test_nodes_details=${NODE1}
    ...                                     iterations_per_node=${UPDATE_TEST_ITERATION}
    ...                                     report=${SHOULD_BE_REPORTED}
    ...                                     qc_domain=${QC_DOMAIN}
    ...                                     qc_project=${QC_PROJECT}
    ...                                     qc_id=${QC_ID_UPGRADE}
    ...                                     sw_build=${TARGET_SW}
    ...                                     customers_list=@{CUSTOMERS_LIST}
    ...                                     restore_to_target_sw=${False}
    ...                                     download_path=/home/ute/UUF_SW

    [Teardown]    Custom Test Teardown


*** Keywords ***
Custom Suite Setup
    Common Suite Setup With OnAir Test Line Preparation
    ...                         increase_timeout_for_update_sw=${1800}
    ...                         list_of_additional_allowed_alarms=${CUSTOM_ALLOWED_ALARMS_DURING_TL_PREPARATION}

    ${SOURCE_SW} =          IF    '${SOURCE_SW}'=='${None}'         Get CM Source Build    ELSE    Set Variable  ${SOURCE_SW}
    ${TARGET_SW} =          IF    '${TARGET_SW}'=='${None}'         Get Target Build       ELSE    Set Variable  ${TARGET_SW}
    @{CUSTOMERS_LIST} =     IF    '${CUSTOMERS_LIST}'!='${None}'    Split String    ${CUSTOMERS_LIST}    ,    ELSE    Create List    Generic

    Set Global Variable  ${SOURCE_SW}
    Set Global Variable  ${TARGET_SW}
    Set Global Variable  @{CUSTOMERS_LIST}

Custom Test Setup
    common_setups_and_teardowns.Common Preconditions    collect_syslog=${False}
    Run Keyword And Ignore Error    Remove Directory         path=/home/ute/.ute-ca/cache/bts/    recursive=${True}

Custom Test Teardown
    gnbbbu.connect    force=${True}
    common_setups_and_teardowns.Common Postconditions With Restore Configuration If Test Failed
    ...    collect_syslog=${False}
