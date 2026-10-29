*** Settings ***
Documentation
...   Test suite for regression testing of feature CB007835-A
...   author: Mateusz Iwankiewicz
...   contact: mateusz.iwankiewicz@nokia.com

Resource     resources/CB007835-5G-A-6ABIO_keywords.robot

Force Tags    CA_VRF_KRK    QCD_MN_RAN    QCP_RAN_VRF

Suite Setup       Test Suite Setup
Suite Teardown    Test Suite Teardown

Test Setup        Test Setup
Test Teardown     CB007835-5G-A-6ABIO_keywords.Test Teardown

*** Test Cases ***
E2E_TL_SW_upgrade_rollback_with_OAM_KPI
    E2E TL SW UPGRADE ROLLBACK WITH OAM KPI
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODE1}
    ...    topology=${TOPOLOGY}
    ...    iterations_per_node=${runs_of_uuf_upgrade}
    ...    customers_list=@{CUSTOMERS_LIST}
    ...    sw_build=${TARGET_SW}
    ...    restore_to_target_sw=${True}
    ...    report=${SHOULD_BE_REPORTED}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${kpi_qc_ids['qc_upgrade']}
    ...    qc_project=${QC_PROJECT}
    [Teardown]    Run Keyword And Ignore Error    setups_and_teardowns_keywords.Add Main BTS Metadata to Report

E2E_TL_Capacity_Module_Reset_with_OAM_KPI
    E2E TL CAPACITY MODULE RESET WITH OAM KPI
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODE1}
    ...    iterations_per_node=${runs_of_bb_reset}
    ...    report=${SHOULD_BE_REPORTED}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${kpi_qc_ids['qc_capacity_reset']}
    ...    qc_project=${QC_PROJECT}
    ...    customers_list=@{CUSTOMERS_LIST}
    ...    topology=${TOPOLOGY}
    [Teardown]    Run Keyword And Ignore Error    setups_and_teardowns_keywords.Add Main BTS Metadata to Report

E2E_TL_RU_Reset_with_OAM_KPI
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
    [Teardown]    Run Keyword And Ignore Error    setups_and_teardowns_keywords.Add Main BTS Metadata to Report

E2E_TL_Cell_Lock_Unlock_NR_with_OAM_KPI
    E2E TL CELL LOCK UNLOCK NR WITH OAM KPI
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODE1}
    ...    iterations_per_node=${test_iteration}
    ...    report=${SHOULD_BE_REPORTED}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${kpi_qc_ids['qc_cell_lock_unlock']}
    ...    qc_project=${QC_PROJECT}
    ...    customers_list=@{CUSTOMERS_LIST}
    ...    topology=${TOPOLOGY}
    [Teardown]    Run Keyword And Ignore Error    setups_and_teardowns_keywords.Add Main BTS Metadata to Report

E2E_TL_Cell_Block_Unblock_NR_with_OAM_KPI
    E2E TL CELL BLOCK UNBLOCK NR WITH OAM KPI
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODE1}
    ...    iterations_per_node=${test_iteration}
    ...    report=${SHOULD_BE_REPORTED}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${kpi_qc_ids['qc_cell_block_unblock_v2']}
    ...    qc_project=${QC_PROJECT}
    ...    customers_list=@{CUSTOMERS_LIST}
    ...    topology=${TOPOLOGY}
    [Teardown]    Run Keyword And Ignore Error    setups_and_teardowns_keywords.Add Main BTS Metadata to Report

E2E_TL_Delta_Commissioning_With_Online_Parameter_Modification
    E2E TL DELTA COMMISSIONING WITH ONLINE PARAMETER MODIFICATION
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODE1}
    ...    iterations_per_node=1
    ...    report=${SHOULD_BE_REPORTED}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${kpi_qc_ids['commissioning_online']}
    ...    qc_project=${QC_PROJECT}
    ...    customers_list=@{CUSTOMERS_LIST}
    ...    topology=${TOPOLOGY}
    [Teardown]    Run Keyword And Ignore Error    setups_and_teardowns_keywords.Add Main BTS Metadata to Report

E2E_TL_Delta_Commissioning_With_Site_Reset_Required
    E2E TL DELTA COMMISSIONING WITH SITE RESET REQUIRED
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODE1}
    ...    iterations_per_node=1
    ...    report=${SHOULD_BE_REPORTED}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${kpi_qc_ids['commissioning_reset']}
    ...    qc_project=${QC_PROJECT}
    ...    customers_list=@{CUSTOMERS_LIST}
    ...    topology=${TOPOLOGY}
    [Teardown]    Run Keyword And Ignore Error    setups_and_teardowns_keywords.Add Main BTS Metadata to Report

E2E_TL_Delta_Commissioning_With_NR_Rat_Reset
    E2E TL DELTA COMMISSIONING WITH NR RAT RESET
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODE1}
    ...    iterations_per_node=1
    ...    report=${SHOULD_BE_REPORTED}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${kpi_qc_ids['commissioning_rat']}
    ...    qc_project=${QC_PROJECT}
    ...    customers_list=@{CUSTOMERS_LIST}
    ...    topology=${TOPOLOGY}
    [Teardown]    Run Keyword And Ignore Error    setups_and_teardowns_keywords.Add Main BTS Metadata to Report

E2E_TL_Activation_Reset_with_OAM_KPI
    E2E TL ACTIVATION RESET TEST
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODE1}
    ...    topology=${TOPOLOGY}
    ...    iterations_per_node=${runs_of_activation_reset}
    ...    customers_list=@{CUSTOMERS_LIST}
    ...    report=${SHOULD_BE_REPORTED}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${kpi_qc_ids['qc_activation_reset']}
    ...    qc_project=${QC_PROJECT}
    [Teardown]    Run Keyword And Ignore Error    setups_and_teardowns_keywords.Add Main BTS Metadata to Report

E2E_TL_Site_Reset_with_OAM_KPI
    E2E TL SITE RESET WITH OAM KPI
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODE1}
    ...    topology=${TOPOLOGY}
    ...    iterations_per_node=${runs_of_uuf_reset}
    ...    customers_list=@{CUSTOMERS_LIST}
    ...    report=${SHOULD_BE_REPORTED}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${kpi_qc_ids['qc_site_reset']}
    ...    qc_project=${QC_PROJECT}
    [Teardown]    Run Keyword And Ignore Error    setups_and_teardowns_keywords.Add Main BTS Metadata to Report
