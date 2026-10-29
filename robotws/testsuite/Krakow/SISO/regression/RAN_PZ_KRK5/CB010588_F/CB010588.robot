*** Settings ***
Documentation
...   Test suite for regression testing of feature CB0010588
...   author: Mateusz Bugaj, Daniel Kulaga, Pawel Grabania
...   contact: mateusz.bugaj@nokia.com, daniel.kulaga@nokia.com, pawel.grabania@nokia.com

Library      Collections
Library      String
Library      taf.rfrl.utilities.cloud_manager.artifacts
Library      taf/rfrl/csv4all/CSV4AllTestCases.py
Library      testsuite/Krakow/resources/UUF/get_uuf_builds.py
Resource     taf/rfrl/ue/robot/REAL_UE.robot
Resource     ./resources/common_keywords.robot
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables    ./resources/common_variables.py
Variables    ./resources/additional_variables.py
Variables    ./resources/call_procedure/call_tmp_vars.py

Force Tags    CA_VRF_KRK    QCD_MN_RAN    QCP_RAN_VRF

Suite Setup       Custom Suite Setup
Suite Teardown    Common Suite Teardown
Test Setup        Custom Test Setup
Test Teardown     common_setups_and_teardowns.Common Postconditions With Restore Configuration If Test Failed

*** Variables ***
${SOURCE_SW}                                    ${None}
${TARGET_SW}                                    ${None}
${CUSTOMERS_LIST}              Generic
${UPDATE_TEST_ITERATION}       5
${SITE_RESET_TEST_ITERATION}   30
@{CUSTOM_ALARMS}                                @{EMPTY}
${CUSTOM_ALLOWED_ALARMS_DURING_TL_PREPARATION}  7220
${SYSLOG_IGNORED_PRINTS}                        ${None}

${SHOULD_BE_REPORTED}      True
${RESTORE_TO_TARGET_SW}    True

${RP_CA}                   VRF_SiSo
${RP_LOCATION}             VRF_KRK
${RP_ORGANIZATION}         VRF_KRK_T05
${QC_DOMAIN}               MN_RAN
${QC_PROJECT}              RAN_VRF
${QC_ID_UPGRADE}           235280
${QC_ID_RESET}             235278


&{NODE1}                    testline_object=${tl.gnbs[0]}
...                         source_sw=${SOURCE_SW}
...                         target_sw=${TARGET_SW}
...                         custom_allowed_alarms=${CUSTOM_ALARMS}
...                         syslog_ignored_prints=${SYSLOG_IGNORED_PRINTS}
@{NODES}                    ${NODE1}


@{All_cellIDs}
...                      LNCEL-111    LNCEL-112    LNCEL-121    LNCEL-131    LNCEL-211    LNCEL-212    LNCEL-213
...                      LNCEL-214    LNCEL-221    LNCEL-231
...                      NRCELL-11    NRCELL-12    NRCELL-31    NRCELL-1     NRCELL-2    NRCELL-3    NRCELL-4

@{LTE_cellIDs}           LNCEL-111    LNCEL-112    LNCEL-121    LNCEL-131    LNCEL-211    LNCEL-212    LNCEL-213
...                      LNCEL-214    LNCEL-221    LNCEL-231
@{NR_cellIDs}            NRCELL-11    NRCELL-12    NRCELL-31    NRCELL-1    NRCELL-2    NRCELL-3    NRCELL-4
${capabilities}          REAL_UE


*** Test Cases ***
E2E_TL_SW_upgrade_rollback_with_OAM_KPI
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
    ...                                     restore_to_target_sw=${RESTORE_TO_TARGET_SW}
    [Teardown]    Custom Test Teardown

E2E_TL_Activation_Reset_with_OAM_KPI
    [Timeout]    96h
    [Tags]    SITE_RESET

    Run Keyword If  '${QC_ID_RESET}'!='${None}'    Set Tags    QC_${QC_ID_RESET}
    gnbbbu.Disconnect
    E2E TL ACTIVATION RESET TEST
    ...                                     nodes_details=${NODES}
    ...                                     test_nodes_details=${NODE1}
    ...                                     iterations_per_node=${SITE_RESET_TEST_ITERATION}
    ...                                     report=${SHOULD_BE_REPORTED}
    ...                                     qc_domain=${QC_DOMAIN}
    ...                                     qc_project=${QC_PROJECT}
    ...                                     qc_id=${QC_ID_RESET}
    ...                                     sw_build=${TARGET_SW}
    ...                                     customers_list=@{CUSTOMERS_LIST}


CB010588_Manual_SiSo_CALL_L3_data_call
    [Setup]    Actions before test
    Call to selected cells    cell_list=${All_cellIDs}    duration=360s    deviation=5%
    [Teardown]    Actions after test


*** Keywords ***
Custom Suite Setup
    Common Suite Setup With OnAir Test Line Preparation
    ...                         increase_timeout_for_update_sw=${1800}
    ...                         list_of_additional_allowed_alarms=${CUSTOM_ALLOWED_ALARMS_DURING_TL_PREPARATION}
    ...                         increase_time_for_checking_cells=600
    ...                         increase_timeout_for_update_sw=3600
    ...                         swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt

    ${SOURCE_SW} =          IF    '${SOURCE_SW}'=='${None}'         Get CM Source Build    ELSE    Set Variable  ${SOURCE_SW}
    ${TARGET_SW} =          IF    '${TARGET_SW}'=='${None}'         Get Target Build       ELSE    Set Variable  ${TARGET_SW}
    @{CUSTOMERS_LIST} =     IF    '${CUSTOMERS_LIST}'!='${None}'    Split String    ${CUSTOMERS_LIST}    ,    ELSE    Create List    Generic
    ${SHOULD_BE_REPORTED}=      Evaluate    '${SHOULD_BE_REPORTED}'=='True'
    ${RESTORE_TO_TARGET_SW}=    Evaluate    '${RESTORE_TO_TARGET_SW}'=='True'

    Set Global Variable  ${SOURCE_SW}
    Set Global Variable  ${TARGET_SW}
    Set Global Variable  @{CUSTOMERS_LIST}
    Set Global Variable  ${SHOULD_BE_REPORTED}
    Set Global Variable  ${RESTORE_TO_TARGET_SW}

Custom Test Setup
    common_setups_and_teardowns.Common Preconditions
    ...    collect_syslog=${False}
    ...    collect_ru_console_log=${False}
    Run Keyword And Ignore Error    Remove Directory         path=/home/ute/.ute-ca/cache/bts/    recursive=${True}
    Run Keyword And Ignore Error    Remove Directory         path=/home/ute/UUF_SW/    recursive=${True}

Custom Test Teardown
    gnbbbu.connect    force=${True}
    common_setups_and_teardowns.Common Postconditions With Restore Configuration If Test Failed
    ...    collect_snapshot_from_ru=${False}
