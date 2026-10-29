*** Settings ***
Documentation
...   author: Tomasz Mozola
...   contact: tomasz.mozola@nokia.com
...   Description:   UUF and Robustness tests


Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/UUF/resources/keywords.resource
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T01/UUF/resources/keywords.py
Library         taf/rfrl/csv4all/CSV4AllTestCases.py
Library         Collections

Force Tags       CA_VRF_WRO2

Test Setup     Run keywords
...             Set Tester Name                                    AND
...             check_and_update_flag


*** Variables ***
${node_mrbts_id}                      ${tl.gnbs[0].instance_id}
${TEST_ITERATION}                     30
${TEST_ITERATION2}                    5
${RP_CA}                              VRF_RRM
${RP_LOCATION}                        VRF_WRO2
${RP_ORGANIZATION}                    VRF_WRO2_T01
@{customers_list}                     General
@{CRITICAL_FAULTS}                    10
@{custom_alarms}                      4681  2002  4367  4352  4670
${rep_comment}                        VRF_WRO2_T01_01
@{CUSTOM_ALARMS_LTE_LOCK}             61631  7509  6351  6134  4011  7513  8150  7511  8000
${tester_name}                        ${None}
${domain}                             MN_RAN
${project}                            RAN_VRF
${q_id}                               ${None}
${INITIAL_SW}                         ${None}
${TARGET_SW}                          ${None}
@{SYSLOG_IGNORED_PRINTS}              INF
${Item_BBMOD_ID}                      1
${Item_RMOD_ID}                       1


&{NODE1}                    testline_object=${tl.gnbs[0]}
...                         node_vm=${tl.test_pc.default_ssh_connection_details.addr}
...                         node_alias=NR
...                         source_sw=${INITIAL_SW}
...                         target_sw=${TARGET_SW}
...                         custom_allowed_alarms=${custom_alarms}

@{FINALNODES}            ${NODE1}


*** Test Cases ***
[1]UUF_E2E_SW_Activation_reset
    [Timeout]    96h
    e2e_tl_activation_reset_test
    ...    nodes_details=${FINALNODES}
    ...    test_nodes_details=${FINALNODES}
    ...    iterations_per_node=${TEST_ITERATION}
    ...    qc_domain=${domain}
    ...    qc_id=${q_id}
    ...    qc_project=${project}
    ...    customers_list=${customers_list}
    ...    report_comment=${rep_comment}

[1]Robustness_E2E_Rmod_reset
    e2e_tl_ru_reset_with_oam_kpi
    ...    nodes_details=${FINALNODES}
    ...    test_nodes_details=${FINALNODES}
    ...    iterations_per_node=${TEST_ITERATION2}
    ...    qc_domain=${domain}
    ...    qc_project=${project}
    ...    customers_list=${customers_list}
    ...    report_comment=${rep_comment}

[1]Robustness_E2E_Rmod_Lock_unLock
    e2e_tl_ru_lock_unlock
    ...    nodes_details=${FINALNODES}
    ...    test_nodes_details=${FINALNODES}
    ...    iterations_per_node=${TEST_ITERATION2}
    ...    qc_domain=${domain}
    ...    qc_project=${project}
    ...    customers_list=${customers_list}
    ...    report_comment=${rep_comment}

[1]Robustness_E2E_BBmod_reset
    e2e_tl_capacity_module_reset_with_oam_kpi
    ...    nodes_details=${FINALNODES}
    ...    test_nodes_details=${FINALNODES}
    ...    iterations_per_node=${TEST_ITERATION2}
    ...    qc_domain=${domain}
    ...    qc_project=${project}
    ...    customers_list=${customers_list}
    ...    report_comment=${rep_comment}

[1]Robustness_E2E_BBmod_Lock_unLock
    e2e_tl_capacity_module_lock_unlock
    ...    nodes_details=${FINALNODES}
    ...    test_nodes_details=${FINALNODES}
    ...    iterations_per_node=${TEST_ITERATION2}
    ...    qc_domain=${domain}
    ...    qc_project=${project}
    ...    customers_list=${customers_list}
    ...    report_comment=${rep_comment}

[1]Robustness_E2E_NR_cell_Lock_unlock
    e2e_tl_cell_lock_unlock_nr_with_oam_kpi
    ...    nodes_details=${FINALNODES}
    ...    test_nodes_details=${FINALNODES}
    ...    iterations_per_node=${TEST_ITERATION2}
    ...    qc_domain=${domain}
    ...    qc_project=${project}
    ...    customers_list=${customers_list}
    ...    report_comment=${rep_comment}

[1]Robustness_E2E_NR_cell_Block_unBlock
    e2e_tl_cell_block_unblock_nr_with_oam_kpi
    ...    nodes_details=${FINALNODES}
    ...    test_nodes_details=${FINALNODES}
    ...    iterations_per_node=${TEST_ITERATION2}
    ...    qc_domain=${domain}
    ...    qc_project=${project}
    ...    customers_list=${customers_list}
    ...    report_comment=${rep_comment}

[1]Robustness_E2E_BTS_Block_unBlock
        e2e_tl_bts_block_unblock
    ...    nodes_details=${FINALNODES}
    ...    test_nodes_details=${FINALNODES}
    ...    iterations_per_node=${TEST_ITERATION2}
    ...    qc_domain=${domain}
    ...    qc_project=${project}
    ...    customers_list=${customers_list}
    ...    report_comment=${rep_comment}

[1]Robustness_E2E_LTE_cell_Lock_unlock
    e2e_tl_cell_lock_unlock_lte_with_oam_kpi
    ...    nodes_details=${FINALNODES}
    ...    test_nodes_details=${FINALNODES}
    ...    iterations_per_node=${TEST_ITERATION2}
    ...    qc_domain=${domain}
    ...    qc_project=${project}
    ...    customers_list=${customers_list}
    ...    report_comment=${rep_comment}

[1]Robustness_E2E_LTE_cell_Block_unBlock
    e2e_tl_cell_block_unblock_lte_with_oam_kpi
    ...    nodes_details=${FINALNODES}
    ...    test_nodes_details=${FINALNODES}
    ...    iterations_per_node=${TEST_ITERATION2}
    ...    qc_domain=${domain}
    ...    qc_project=${project}
    ...    customers_list=${customers_list}
    ...    report_comment=${rep_comment}

[2]Specific_Item_BBMOD_LOCK_UNLOCK
    [Documentation]    Lock and unlock specific number BBMOD. i.e. for BBMOD-2 use flag: -v Item_BBMOD_ID:2, default flag:1
    Set Test Variable   ${BBMOD}  MRBTS-${node_mrbts_id}/EQM-1/APEQM-1/CABINET-1/BBMOD-${Item_BBMOD_ID}
    ${modifications_dict} =  Create Dictionary  modules_for_test=${BBMOD}
    ${NODE2}  ${NODES2} =  Temporarily Modify Node  ${NODE1}  ${modifications_dict}
    e2e_tl_capacity_module_lock_unlock
    ...    nodes_details=${NODES2}
    ...    test_nodes_details=${NODE2}
    ...    iterations_per_node=${TEST_ITERATION2}
    ...    qc_domain=${domain}
    ...    qc_project=${project}
    ...    customers_list=${customers_list}
    ...    report_comment=${rep_comment}

[2]Specific_Item_BBMOD_RESET
    [Documentation]    Reset specific number BBMOD. i.e. for BBMOD-3 use flag: -v Item_BBMOD_ID:3, default flag:1
    Set Test Variable   ${BBMOD}  MRBTS-${node_mrbts_id}/EQM-1/APEQM-1/CABINET-1/BBMOD-${Item_BBMOD_ID}
    ${modifications_dict} =  Create Dictionary  modules_for_test=${BBMOD}
    ${NODE2}  ${NODES2} =  Temporarily Modify Node  ${NODE1}  ${modifications_dict}
    e2e_tl_capacity_module_reset_with_oam_kpi
    ...    nodes_details=${NODES2}
    ...    test_nodes_details=${NODE2}
    ...    iterations_per_node=${TEST_ITERATION2}
    ...    qc_domain=${domain}
    ...    qc_project=${project}
    ...    customers_list=${customers_list}
    ...    report_comment=${rep_comment}

[2]Specific_Item_RMOD_LOCK_UNLOCK
    [Documentation]    Lock and unlock specific number RMOD. i.e. for RMOD-2 use flag: -v Item_RMOD_ID:2, default flag:1
    Set Test Variable   ${RMOD}  MRBTS-${node_mrbts_id}/EQM-1/APEQM-1/RMOD-${Item_RMOD_ID}
    ${modifications_dict} =  Create Dictionary  modules_for_test=${RMOD}
    ${NODE2}  ${NODES2} =  Temporarily Modify Node  ${NODE1}  ${modifications_dict}
    e2e_tl_ru_lock_unlock
    ...    nodes_details=${NODES2}
    ...    test_nodes_details=${NODE2}
    ...    iterations_per_node=${TEST_ITERATION2}
    ...    qc_domain=${domain}
    ...    qc_project=${project}
    ...    customers_list=${customers_list}
    ...    report_comment=${rep_comment}

[2]Specific_Item_RMOD_RESET
    [Documentation]    Reset specific number RMOD. i.e. for RMOD-5 use flag: -v Item_RMOD_ID:5, default flag:1
    Set Test Variable   ${RMOD}  MRBTS-${node_mrbts_id}/EQM-1/APEQM-1/RMOD-${Item_RMOD_ID}
    ${modifications_dict} =  Create Dictionary  modules_for_test=${RMOD}
    ${NODE2}  ${NODES2} =  Temporarily Modify Node  ${NODE1}  ${modifications_dict}
    e2e_tl_ru_reset_with_oam_kpi
    ...    nodes_details=${NODES2}
    ...    test_nodes_details=${NODE2}
    ...    iterations_per_node=${TEST_ITERATION2}
    ...    qc_domain=${domain}
    ...    qc_project=${project}
    ...    customers_list=${customers_list}
    ...    report_comment=${rep_comment}

*** Keywords ***
Temporarily Modify Node
    [Arguments]  ${node}  ${modifications_dict}  ${print_to_console}=False
    ${NODE2} =  Create Dictionary  &{node}
    Set To Dictionary  ${NODE2}  &{modifications_dict}
    ${NODES2} =  Create List  ${NODE2}
    Log  Nodes are modified for ${TEST_NAME} test case.\n\nNODE2: ${NODE2}\n\nNODES2: ${NODES2}  console=${print_to_console}
    [Return]  ${NODE2}  ${NODES2}
