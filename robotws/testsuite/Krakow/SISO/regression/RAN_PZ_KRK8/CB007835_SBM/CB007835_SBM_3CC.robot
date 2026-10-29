*** Settings ***
Documentation
...   Test suite for regression testing of feature CB007835-A
...   author: Bartosz Odziomek, Antonina Kosar
...   contact: bartosz.odziomek@nokia.com, antonina.kosar@nokia.com

Library      ute_ue
Library      taf.rfrl.bts.devices.du.logs_collecting.btslog_collector.GnbBtslogCollector  WITH NAME    btslog_collector
Library      taf.rfrl.bts.devices.du.pm_counters.GnbPmCounter    WITH NAME    gnb_pm_counter
Library      ../../../regression/RAN_PZ_KRK1/CB007835/resources/resources.py    WITH NAME    imported_resources
Resource     ./resources/keywords.robot
Variables    ./resources/variables.py
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py

Test Timeout  72 hours
Force Tags    STATE_SW_UPLOADED    PY39    CLOUD_5G_CLASSICAL_ASIBL_ABIOB1B2_ABILB3_4xAWEUA_ECPRI    CDRT    CRT
...     CA_VRF_KRK

Suite Setup       Custom Suite Setup
Suite Teardown    common_setups_and_teardowns.Common Suite Teardown

Test Setup        Custom Test Setup
Test Teardown     common_setups_and_teardowns.Common Postconditions With Restore Configuration If Test Failed



*** Variables ***
################## Call Processing ####################
${interval}                 15
${throughput_duration}      20min
${divisor}                  ${900000}

# single ue tput config ##################
${single_ue_tput_dl}        4000Mbits/sec
${single_ue_tput_ul}        250Mbits/sec

${min_single_ue_tput_dl}    1900Mbits/sec
${min_single_ue_tput_ul}    210Mbits/sec

# endc tput config #######################
${endc_tput_dl}             4200Mbits/sec
${min_endc_tput_dl_5G}      4000Mbits/sec
${min_endc_tput_dl_4G}      92000

${endc_tput_ul}             300Mbits/sec
${min_endc_tput_ul_5G}      240Mbits/sec
${min_endc_tput_ul_4G}      32000

# multi ue tput config ###################
${multi_ue_tput_dl}         3000Mbits/sec
${multi_ue_tput_ul}         125Mbits/sec

${min_multi_ue_tput_dl}     2000Mbits/sec
${min_multi_ue_tput_ul}     115Mbits/sec

############### OAM and UUF #########################

@{CUSTOMERS_LIST}                               SBM
${TOPOLOGY}                                     CLOUD_5G_CLASSICAL_ASIBL_ABIOB1B2_ABILB3_4xAWEUA_ECPRI
${SHOULD_BE_REPORTED}=                          ${True}
@{CUSTOM_ALLOWED_ALARMS}=                       @{EMPTY}
${CUSTOM_ALLOWED_ALARMS_DURING_TL_PREPARATION}  4592
@{CRITICAL_FAULTS}=                             0010  0016  1806  1868  4341  4352  4383  4590
${SOURCE_SW}                                    ${None}
${TARGET_SW}=                                   ${None}


${QC_DOMAIN}                                    MN_RAN
${QC_PROJECT}                                   RAN_VRF
${RP_CA}                                        VRF_OAM
${RP_LOCATION}                                  VRF_KRK
${RP_ORGANIZATION}                              VRF_KRK_T08
${RESTORE_TO_TARGET_AFTER_SW_UPGRADE}           ${True}
${SITE_RESET_TEST_ITERATION}                    ${10}
${ACTIVATION_RESET_TEST_ITERATION}              ${10}
${UPDATE_TEST_ITERATION}                        ${5}
${UPDATE_TEST_ITERATION_L3}                     ${1}
${runs_of_ru_reset}                             ${20}
${runs_of_bb_reset}                             ${10}
${others_iterations}                            ${10}
${test_iteration}                               ${1}
@{IGNORED_PRINTS}                               is not defined in SysinfoQuota.xml. Please contact the owner

&{NODE1}                                        testline_object=${tl.gnbs[0]}
...                                             source_sw=${SOURCE_SW}
...                                             target_sw=${TARGET_SW}
...                                             custom_allowed_alarms=${CUSTOM_ALLOWED_ALARMS}
...                                             syslog_ignored_prints=${IGNORED_PRINTS}

@{NODES}                                        ${NODE1}

${delta_rat_reset}                  testsuite/Krakow/SISO/regression/RAN_PZ_KRK8/CB007835_SBM/resources/delta_rat.json
${sw_config_path}                   testsuite/Krakow/SISO/regression/RAN_PZ_KRK8/UUF4ALL/resources/swconfig.txt



*** Test Cases ***
E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI
    [Timeout]    96h
    [Tags]    UUF

    Set To Dictionary    ${NODE1}    source_sw    ${SOURCE_SW}
    Set To Dictionary    ${NODE1}    target_sw    ${TARGET_SW}

    Sleep    18 minutes    reason=Waiting till scout connect to BTS(It is temporary WA)
    E2E TL SW UPGRADE ROLLBACK WITH OAM KPI
    ...     nodes_details=${NODES}
    ...     test_nodes_details=${NODE1}
    ...     iterations_per_node=${UPDATE_TEST_ITERATION}
    ...     report=${True}
    ...     qc_domain=${QC_DOMAIN}
    ...     qc_project=${QC_PROJECT}
    ...     qc_id=${kpi_qc_ids['qc_upgrade']}
    ...     sw_build=${TARGET_SW}
    ...     customers_list=@{CUSTOMERS_LIST}
    ...     restore_to_target_sw=${RESTORE_TO_TARGET_AFTER_SW_UPGRADE}
    [Teardown]    Custom Test Teardown

E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI_and_L3_Call
    [Timeout]    96h
    [Tags]    UUF

    Set To Dictionary    ${NODE1}    source_sw    ${SOURCE_SW}
    Set To Dictionary    ${NODE1}    target_sw    ${TARGET_SW}

    Sleep    18 minutes    reason=Waiting till scout connect to BTS(It is temporary WA)
    E2E TL SW UPGRADE ROLLBACK WITH OAM KPI
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODE1}
    ...    iterations_per_node=${UPDATE_TEST_ITERATION_L3}
    ...    report=${True}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_project=${QC_PROJECT}
    ...    qc_id=${kpi_qc_ids['qc_upgrade_l3call']}
    ...    sw_build=${TARGET_SW}
    ...    customers_list=@{CUSTOMERS_LIST}
    ...    restore_to_target_sw=${True}
    ...    l3_call_method=Simple L3 call keyword
    [Teardown]    Custom Test Teardown

E2E_TL_Site_Reset_with_OAM_KPI
    [Timeout]    96h
    [Tags]    SITE_RESET
    gnbbbu.Disconnect
    E2E TL SITE RESET WITH OAM KPI
    ...     nodes_details=${NODES}
    ...     test_nodes_details=${NODE1}
    ...     iterations_per_node=${SITE_RESET_TEST_ITERATION}
    ...     report=${True}
    ...     qc_domain=${QC_DOMAIN}
    ...     qc_project=${QC_PROJECT}
    ...     qc_id=${kpi_qc_ids['qc_site_reset']}
    ...     sw_build=${TARGET_SW}
    ...     customers_list=@{CUSTOMERS_LIST}

E2E_TL_RU_Reset_with_OAM_KPI
    QC Set Project
    E2E TL RU RESET WITH OAM KPI
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODE1}
    ...    iterations_per_node=${runs_of_ru_reset}
    ...    report=${SHOULD_BE_REPORTED}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${kpi_qc_ids['qc_ru_reset']}
    ...    qc_project=${QC_PROJECT}
    ...    customers_list=@{CUSTOMERS_LIST}
    ...    topology=${TOPOLOGY}

E2E_TL_Capacity_Module_Reset_with_OAM_KPI
    QC Set Project
    E2E TL CAPACITY MODULE LOCK UNLOCK
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODE1}
    ...    iterations_per_node=${runs_of_bb_reset}
    ...    report=${SHOULD_BE_REPORTED}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${kpi_qc_ids['qc_capacity_reset']}
    ...    qc_project=${QC_PROJECT}
    ...    customers_list=@{CUSTOMERS_LIST}
    ...    topology=${TOPOLOGY}

E2E_TL_Cell_Lock_Unlock_NR_with_OAM_KPI
    QC Set Project
    E2E TL CELL LOCK UNLOCK NR WITH OAM KPI
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODE1}
    ...    iterations_per_node=${others_iterations}
    ...    report=${SHOULD_BE_REPORTED}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${kpi_qc_ids['qc_cell_lock_unlock']}
    ...    qc_project=${QC_PROJECT}
    ...    customers_list=@{CUSTOMERS_LIST}
    ...    topology=${TOPOLOGY}

E2E_TL_Cell_Block_Unblock_NR_with_OAM_KPI
    QC Set Project
    E2E TL CELL BLOCK UNBLOCK NR WITH OAM KPI
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODE1}
    ...    iterations_per_node=${others_iterations}
    ...    report=${SHOULD_BE_REPORTED}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${kpi_qc_ids['qc_cell_block_unblock_v2']}
    ...    qc_project=${QC_PROJECT}
    ...    customers_list=@{CUSTOMERS_LIST}
    ...    topology=${TOPOLOGY}

E2E_TL_Delta_Commissioning_With_Online_Parameter_Modification
    QC Set Project
    E2E TL DELTA COMMISSIONING WITH ONLINE PARAMETER MODIFICATION
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODE1}
    ...    iterations_per_node=${test_iteration}
    ...    report=${SHOULD_BE_REPORTED}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${kpi_qc_ids['commissioning_online']}
    ...    qc_project=${QC_PROJECT}
    ...    customers_list=@{CUSTOMERS_LIST}
    ...    topology=${TOPOLOGY}

E2E_TL_Delta_Commissioning_With_Site_Reset_Required
    QC Set Project
    E2E TL DELTA COMMISSIONING WITH SITE RESET REQUIRED
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODE1}
    ...    iterations_per_node=${test_iteration}
    ...    report=${SHOULD_BE_REPORTED}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${kpi_qc_ids['commissioning_reset']}
    ...    qc_project=${QC_PROJECT}
    ...    customers_list=@{CUSTOMERS_LIST}
    ...    topology=${TOPOLOGY}

E2E_TL_Delta_Commissioning_With_NR_Rat_Reset
    QC Set Project
    E2E TL DELTA COMMISSIONING WITH NR RAT RESET
    ...    delta=${delta_rat_reset}
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODE1}
    ...    iterations_per_node=${test_iteration}
    ...    report=${SHOULD_BE_REPORTED}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${kpi_qc_ids['commissioning_rat']}
    ...    qc_project=${QC_PROJECT}
    ...    customers_list=@{CUSTOMERS_LIST}
    ...    topology=${TOPOLOGY}

CB007835-5G-A_25_Attach_tput_mix_3min_parallel
    Run throughput and verify gNB State
    [Teardown]    Custom Test Teardown for tput test


E2E_TL_Activation_Reset_Test
    [Timeout]    96h
    [Tags]    SITE_RESET

    gnbbbu.Disconnect
    E2E TL ACTIVATION RESET TEST
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODE1}
    ...    iterations_per_node=${ACTIVATION_RESET_TEST_ITERATION}
    ...    report=${True}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_project=${QC_PROJECT}
    ...    qc_id=${kpi_qc_ids['qc_activation_reset']}
    ...    sw_build=${TARGET_SW}
    ...    customers_list=@{CUSTOMERS_LIST}




