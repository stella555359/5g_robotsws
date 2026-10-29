*** Settings ***
Documentation
...   Test suite for regression testing of feature CB011091/92
...   author: Mateusz Bugaj
...   contact: mateusz.bugaj@nokia.com

Library      taf.rfrl.utilities.test_config
Library      taf.ue     WITH NAME   ue
Library      testsuite/Krakow/resources/UUF/get_uuf_builds.py
Library      taf/rfrl/csv4all/CSV4AllTestCases.py
Library      taf.rfrl.utilities.cloud_manager.artifacts

Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource     taf/rfrl/procedures/SISO/General_SiSo_Cell_block_and_unblock.robot
Resource     taf/rfrl/bts/robot/gnb.robot
Resource     testsuite/Krakow/resources/RAN_VRF_KRK5/robot/snapshot_validation/snapshot_validation_keywords.robot
Resource     ./resources/common_keywords.robot

Variables    ./resources/common_variables.py
Variables    ./resources/sfp_lock_variables.py
Variables    ./resources/additional_variables.py
Variables    ./resources/call_procedure/call_tmp_vars.py
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py

Force Tags    CA_VRF_KRK

Suite Setup       Common Suite Setup With OnAir Test Line Preparation
...               swconfig_from_path=commissionings/Krakow/7_7_UTE5GCLOUDT11SK073/default_swconfig.txt
...               increase_timeout_for_update_sw=3600
...               increase_time_for_checking_cells=480
Suite Teardown     Common Suite Teardown

Test Timeout    24 hours

*** Variables ***
@{cell_list_b3}            NRCELL-1_B3      NRCELL-2_B3    NRCELL-3_B3     NRCELL-4_B3
...                        NRCELL-5_B3      NRCELL-7_B3     NRCELL-8_B3

@{cell_list_b3_supercell}  NRCELL-5_B3_supercell

${capabilities}                 REAL_UE

${SOURCE_SW}                        ${None}
${TARGET_SW}                        ${None}
@{CUSTOMERS_LIST}=                  Generic
@{CUSTOM_ALARMS}=                   6134    7509    6351    4479    61675
@{CUSTOM_ALLOWED_ALARMS}            61675   4479

&{NODE1}                            testline_object=${tl.gnbs[0]}
...                                 source_sw=${SOURCE_SW}
...                                 target_sw=${TARGET_SW}
...                                 custom_allowed_alarms=@{CUSTOM_ALARMS}

@{NODES}                            ${NODE1}

${UPDATE_TEST_ITERATION}            5
${SITE_RESET_TEST_ITERATION}        30

${SHOULD_BE_REPORTED}=              ${True}

${QC_DOMAIN}=                       MN_RAN
${QC_PROJECT}=                      RAN_VRF
${RP_CA}                            VRF_SiSo
${RP_ORGANIZATION}                  VRF_KRK_T05
${RP_LOCATION}                      VRF_KRK

*** Test Cases ***
CB011092_B3_E2E_TL_SW_upgrade_rollback_with_OAM_KPI
    [Timeout]    96h
    [Setup]     Custom Test Setup For Upgrade
    Remove Dirs       /home/ute/.ute-ca/cache/bts/

    Run Keyword If  '${QC_ID_UPGRADE}'!='${None}'    Set Tags    QC_${QC_ID_UPGRADE}

    Sleep    18 minutes    reason=Waiting till scout connect to BTS(It is temporary WA)

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

CB011092_D2_General_SiSo_reset_ASiR_HUB_via_ASiR_WebEM
    [Setup]    Actions before test     alarms_for_test=${ADDITIONAL_ALARMS_FOR_TESTS}[pRRH_Reset]    prefix_tag=supercell
    Reset Hubs Via AsirWebEm
    Call to selected cells      cell_list=${cell_list_b3_supercell}      duration=120s
    [Teardown]    Actions after test

CB011091_F1_lock_unlock_ASiR_HUB_via_WebEM
     [Setup]    Actions before test     alarms_for_test=${ADDITIONAL_ALARMS_FOR_TESTS}[pRRH_Reset]
    Lock And Ublock Hubs Via AsirWebEm
    Call to selected cells      cell_list=${cell_list_b3}      duration=120s
    [Teardown]    Actions after test

CB011092_B1_General_SiSo_Cell_block_and_unblock
    [Setup]    Actions before test     alarms_for_test=${ADDITIONAL_ALARMS_FOR_TESTS}[Cell_block_unblock]
    Call to selected cells      cell_list=${cell_list_b3}      duration=120s
    General SiSo Cell block and unblock
    Call to selected cells      cell_list=${cell_list_b3}      duration=120s
    [Teardown]    Actions after test

CB011092_B3_General_SiSo_E2E_system_setup_with_data_transfer_for_configuration_feature_testing
    [Setup]    Actions before test
    Call to selected cells      cell_list=${cell_list_b3}      duration=360s       deviation=5%
    [Teardown]    Actions after test

CB011092_B3_General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
    [Setup]    Actions before test     alarms_for_test=${ADDITIONAL_ALARMS_FOR_TESTS}[Snapshot]
    Verify snapshot
    [Teardown]    Actions after test

CB011092_B3_General_SiSo_SFP_lock_unlock_for_configuration_testing
    [Timeout]    24h
    [Setup]    Actions before test     alarms_for_test=${ADDITIONAL_ALARMS_FOR_TESTS}[sfp_lock]
    SFP Lock And Unlock
    [Teardown]    Actions after test

E2E_TL_Activation_Reset_Test
    [Timeout]    96h
    [Setup]     Custom Test Setup For UUF
    Run Keyword If  '${QC_ID_RESET}'!='${None}'    Set Tags    QC_${QC_ID_RESET}
    gnbbbu.Disconnect

    E2E TL ACTIVATION RESET TEST
    ...                                     nodes_details=${NODES}
    ...                                     test_nodes_details=${NODE1}
    ...                                     iterations_per_node=${SITE_RESET_TEST_ITERATION}
    ...                                     report=${True}
    ...                                     qc_domain=${QC_DOMAIN}
    ...                                     qc_project=${QC_PROJECT}
    ...                                     qc_id=${QC_ID_RESET}
    ...                                     sw_build=${TARGET_SW}
    ...                                     customers_list=@{CUSTOMERS_LIST}

E2E_TL_Site_reset_with_OAM_KPI
    [Timeout]    96h
    [Setup]     Custom Test Setup For UUF
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
    ...                                     sw_build=${TARGET_SW}
    ...                                     customers_list=@{CUSTOMERS_LIST}

*** Keywords ***
Custom Test Setup For Upgrade
    Common Suite Setup With OnAir Test Line Preparation
    ...               increase_timeout_for_update_sw=${900}
    ...               increase_time_for_checking_cells=${480}
    ...               swconfig_from_path=commissionings/Krakow/7_7_UTE5GCLOUDT11SK073/default_swconfig.txt
    Custom Test Setup For UUF

Custom Test Setup For UUF
    ${SOURCE_SW}=    run keyword if  '${SOURCE_SW}'=='${None}'  Get CM Source Build
    ...   ELSE  Set Variable  ${SOURCE_SW}
    ${TARGET_SW}=    run keyword if  '${TARGET_SW}'=='${None}'  Get Target Build
    ...   ELSE  Set Variable  ${TARGET_SW}

    Set Global Variable  ${SOURCE_SW}
    Set Global Variable  ${TARGET_SW}
    Set To Dictionary    ${NODE1}    source_sw    ${SOURCE_SW}
    Set To Dictionary    ${NODE1}    target_sw    ${TARGET_SW}

Custom Test Teardown
    gnbbbu.connect    force=${True}
    common_setups_and_teardowns.Common Postconditions With Restore Configuration If Test Failed
    btslogcollector.Setup Btslog Collector
