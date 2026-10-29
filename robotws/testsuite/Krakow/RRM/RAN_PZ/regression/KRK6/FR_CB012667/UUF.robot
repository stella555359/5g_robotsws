*** Settings ***
Documentation
...   maintainer: Dawid Dabrowski
...   contact: dawid.dabrowski@nokia.com
...   Test suite for basic UUF OAM Tests in loop

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
${SOURCE_SW}                                    ${None}
${TARGET_SW}                                    ${None}
${CUSTOMERS_LIST}                               Chunghwa Telecom
@{CUSTOM_ALARMS}                                @{EMPTY}
${CUSTOM_ALLOWED_ALARMS_DURING_TL_PREPARATION}  ${None}
${SYSLOG_IGNORED_PRINTS}                        ${None}
${UUF_TEMPORARY_ALLOWED_ALARMS}                 ${None}
${SWCONFIG_PATH}                                commissionings/Krakow/swconfig/default_swconfig.txt
${REPORT}                                       ${True}
${RESTORE_TO_TARGET_SW}                         ${True}

&{NODE1}                            testline_object=${tl.gnbs[0]}
...                                 source_sw=${SOURCE_SW}
...                                 target_sw=${TARGET_SW}
...                                 custom_allowed_alarms=${CUSTOM_ALARMS}
...                                 syslog_ignored_prints=${SYSLOG_IGNORED_PRINTS}

@{NODES}                            ${NODE1}

${UPDATE_TEST_ITERATION}            5
${SITE_RESET_TEST_ITERATION}        30

${QC_DOMAIN}                        MN_RAN
${QC_PROJECT}                       RAN_VRF
${QC_ID_UPGRADE}=                   60981
${QC_ID_RESET}=                     228158

${RP_CA}                            VRF_OAM
${RP_ORGANIZATION}                  VRF_KRK_T06
${RP_LOCATION}                      VRF_KRK


*** Test Cases ***
E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI
    [Timeout]    96h
    [Tags]    UUF

    Run Keyword If  '${QC_ID_UPGRADE}'!='${None}'    Set Tags    QC_${QC_ID_UPGRADE}
    Set To Dictionary    ${NODE1}    source_sw    ${SOURCE_SW}
    Set To Dictionary    ${NODE1}    target_sw    ${TARGET_SW}

    Sleep    18 minutes    reason=Waiting till scout connect to BTS(It is temporary WA)

    E2E TL SW UPGRADE ROLLBACK WITH OAM KPI
    ...                                     nodes_details=${NODES}
    ...                                     test_nodes_details=${NODE1}
    ...                                     iterations_per_node=${UPDATE_TEST_ITERATION}
    ...                                     report=${REPORT}
    ...                                     qc_domain=${QC_DOMAIN}
    ...                                     qc_project=${QC_PROJECT}
    ...                                     qc_id=${QC_ID_UPGRADE}
    ...                                     sw_build=${TARGET_SW}
    ...                                     customers_list=@{CUSTOMERS_LIST}
    ...                                     restore_to_target_sw=${RESTORE_TO_TARGET_SW}

    [Teardown]    Custom Test Teardown

E2E_TL_Activation_Reset_Test
    [Timeout]    96h
    [Tags]    SITE_RESET

    Run Keyword If  '${QC_ID_RESET}'!='${None}'    Set Tags    QC_${QC_ID_RESET}
    gnbbbu.Disconnect
    E2E TL ACTIVATION RESET TEST
    ...                                     nodes_details=${NODES}
    ...                                     test_nodes_details=${NODE1}
    ...                                     iterations_per_node=${SITE_RESET_TEST_ITERATION}
    ...                                     report=${REPORT}
    ...                                     qc_domain=${QC_DOMAIN}
    ...                                     qc_project=${QC_PROJECT}
    ...                                     qc_id=${QC_ID_RESET}
    ...                                     sw_build=${TARGET_SW}
    ...                                     customers_list=@{CUSTOMERS_LIST}


*** Keywords ***
Custom Suite Setup
    Common Suite Setup With OnAir Test Line Preparation
    ...                         increase_timeout_for_update_sw=${1800}
    ...                         list_of_additional_allowed_alarms=${CUSTOM_ALLOWED_ALARMS_DURING_TL_PREPARATION}
    ...                         swconfig_from_path=${SWCONFIG_PATH}
    ...                         prefix_tag=EDA

    ${SOURCE_SW} =          IF    '${SOURCE_SW}'=='${None}'         Get CM Source Build    ELSE    Set Variable  ${SOURCE_SW}
    ${TARGET_SW} =          IF    '${TARGET_SW}'=='${None}'         Get Target Build       ELSE    Set Variable  ${TARGET_SW}
    @{CUSTOMERS_LIST} =     IF    '${CUSTOMERS_LIST}'!='${None}'    Split String    ${CUSTOMERS_LIST}    ,    ELSE    Create List    Generic
    ${REPORT}=                  Evaluate    '${REPORT}'=='True'
    ${RESTORE_TO_TARGET_SW}=    Evaluate    '${RESTORE_TO_TARGET_SW}'=='True'

    Set Global Variable  ${SOURCE_SW}
    Set Global Variable  ${TARGET_SW}
    Set Global Variable  @{CUSTOMERS_LIST}
    Set Global Variable  ${REPORT}
    Set Global Variable  ${RESTORE_TO_TARGET_SW}

Custom Test Setup
    common_setups_and_teardowns.Common Preconditions
    ...    collect_syslog=${False}
    ...    collect_ru_console_log=${False}
    Run Keyword And Ignore Error    Remove Directory         path=/home/ute/.ute-ca/cache/bts/    recursive=${True}

Custom Test Teardown
    gnbbbu.connect    force=${True}
    common_setups_and_teardowns.Common Postconditions With Restore Configuration If Test Failed
    ...    collect_snapshot_from_ru=${False}
