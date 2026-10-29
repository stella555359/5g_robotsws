*** Settings ***
Documentation
  ...  AUTHOR-piotr.korczynski@nokia.com  Maintainers: @I_SRAN_PROD_SISO_WRO_CRTDEV_GMS
  ...
  ...  - 30.09.2024 - Initial creation
  ...  template tetst cases with UUF CS4ALL keywords

Resource    ../../Resources/Setup/setup_and_teardown.robot
Library  taf/rfrl/csv4all/CSV4AllTestCases.py
Library  XML  use_lxml=true
Library  OperatingSystem
Library  String
Library  Collections

Resource  taf/rfrl/uuf4all/uuf4all_keywords.robot


Suite Setup       Suite Precondition
Suite Teardown    Suite Postcondition
*** Variables ***
${CUSTOMERS}=   Generic



*** Test Cases ***
[Feature_TI][x.0] e2e_tl_site_reset_without_hwf_with_oam_kpi
    [Setup]    Configuration Precondition    CN=REF_10_16_UTESRANSISO909
    ${UUF_NODES}  ${UUF_ITERATIONS}=  UUF Create Dictionary Description For UUF Type Regular Testcases  ${cfg.active_bts_list}
    e2e_tl_site_reset_without_hwf_with_oam_kpi
    ...  nodes_details=${UUF_NODES}
    ...  test_nodes_details=${UUF_NODES}
    ...  iterations_per_node=${UUF_ITERATIONS}
    ...  report=${False}
    ...  customers_list=${CUSTOMERS}
    [Teardown]    Configuration Postcondition

[Feature_TI][x.0] e2e_tl_power_site_reset_without_hwf_with_oam_kpi
    [Setup]    Configuration Precondition    CN=REF_10_16_UTESRANSISO909
    ${UUF_NODES}  ${UUF_ITERATIONS}=  UUF Create Dictionary Description For UUF Type Regular Testcases  ${cfg.active_bts_list}
    e2e_tl_power_site_reset_without_hwf_with_oam_kpi
    ...  nodes_details=${UUF_NODES}
    ...  test_nodes_details=${UUF_NODES}
    ...  iterations_per_node=${UUF_ITERATIONS}
    ...  report=${False}
    ...  customers_list=${CUSTOMERS}
    [Teardown]    Configuration Postcondition

[Feature_TI][x.0] e2e_tl_upgrade_test
    [Setup]    Configuration Precondition    CN=REF_10_16_UTESRANSISO909     N=5
    ${UUF_NODES}  ${UUF_ITERATIONS}=  UUF Create Dictionary Description For UUF Type Regular Testcases  ${cfg.active_bts_list}
    e2e_tl_upgrade_test
    ...  nodes_details=${UUF_NODES}
    ...  test_nodes_details=${UUF_NODES}
    ...  iterations_per_node=${UUF_ITERATIONS}
    ...  report=${False}
    ...  customers_list=${CUSTOMERS}
    [Teardown]    Configuration Postcondition

[Feature_TI][x.0] e2e_tl_sw_upgrade_rollback_with_oam_kpi
    [Setup]    Run Keywords
    ...  Set Test Variable   ${EXECUTE_UUF_UPGRADE_PROCEDURE}   ${FALSE}
    ...  AND  Configuration Precondition    CN=REF_10_16_UTESRANSISO909    N=1
    ${UUF_NODES}  ${UUF_CLOUD_EXECUTION}  ${UUF_ITERATIONS}=  UUF Create Dictionary Description For UUF Type Testcases  ${cfg.active_bts_list}
    e2e_tl_sw_upgrade_rollback_with_oam_kpi
    ...  nodes_details=${UUF_NODES}
    ...  test_nodes_details=${UUF_NODES}
    ...  iterations_per_node=${UUF_ITERATIONS}
    ...  report=${False}
    ...  customers_list=${CUSTOMERS}
    [Teardown]    Configuration Postcondition

[Feature_TI][x.0] netact_feature_test
    [Setup]    Configuration Precondition    CN=REF_10_16_UTESRANSISO909     #N=${UUF_ITERATIONS}
    ${UUF_NODES}  ${UUF_ITERATIONS}=  UUF Create Dictionary Description For UUF Type Regular Testcases  ${cfg.active_bts_list}
    netact_feature_test
    ...  nodes_details=${UUF_NODES}
    ...  test_nodes_details=${UUF_NODES}
    ...  iterations_per_node=${UUF_ITERATIONS}
    ...  report=${False}
    ...  customers_list=${CUSTOMERS}
    ...  netact_dict=&{NETACT_DICT}
    [Teardown]    Configuration Postcondition

[Feature_TI][x.0] fdsw_test
    [Setup]    Configuration Precondition    CN=REF_10_16_UTESRANSISO909     #N=${UUF_ITERATIONS}
    ${UUF_NODES}  ${UUF_ITERATIONS}=  UUF Create Dictionary Description For UUF Type Regular Testcases  ${cfg.active_bts_list}
    fdsw_test
    ...  nodes_details=${UUF_NODES}
    ...  test_nodes_details=${UUF_NODES}
    ...  iterations_per_node=${UUF_ITERATIONS}
    ...  report=${False}
    ...  customers_list=${CUSTOMERS}
    [Teardown]    Configuration Postcondition

[Feature_TI][x.0] e2e_tl_capacity_module_reset_with_oam_kpi
    [Setup]    Configuration Precondition    CN=REF_10_16_UTESRANSISO909     #N=${UUF_ITERATIONS}
    ${UUF_NODES}  ${UUF_ITERATIONS}=  UUF Create Dictionary Description For UUF Type Regular Testcases  ${cfg.active_bts_list}
    e2e_tl_capacity_module_reset_with_oam_kpi
    ...  nodes_details=${UUF_NODES}
    ...  test_nodes_details=${UUF_NODES}
    ...  iterations_per_node=${UUF_ITERATIONS}
    ...  report=${False}
    ...  customers_list=${CUSTOMERS}
    [Teardown]    Configuration Postcondition

[Feature_TI][x.0] e2e_tl_ru_reset_with_oam_kpi
    [Setup]    Configuration Precondition    CN=REF_10_16_UTESRANSISO909     #N=${UUF_ITERATIONS}
    ${UUF_NODES}  ${UUF_ITERATIONS}=  UUF Create Dictionary Description For UUF Type Regular Testcases  ${cfg.active_bts_list}
    e2e_tl_ru_reset_with_oam_kpi
    ...  nodes_details=${UUF_NODES}
    ...  test_nodes_details=${UUF_NODES}
    ...  iterations_per_node=${UUF_ITERATIONS}
    ...  report=${False}
    ...  customers_list=${CUSTOMERS}
    [Teardown]    Configuration Postcondition

[Feature_TI][x.0] e2e_tl_cell_lock_unlock_nr_with_oam_kpi
    [Setup]    Configuration Precondition    CN=REF_10_16_UTESRANSISO909     #N=${UUF_ITERATIONS}
    ${UUF_NODES}  ${UUF_ITERATIONS}=  UUF Create Dictionary Description For UUF Type Regular Testcases  ${cfg.active_bts_list}
    e2e_tl_cell_lock_unlock_nr_with_oam_kpi
    ...  nodes_details=${UUF_NODES}
    ...  test_nodes_details=${UUF_NODES}
    ...  iterations_per_node=${UUF_ITERATIONS}
    ...  report=${False}
    ...  customers_list=${CUSTOMERS}
    [Teardown]    Configuration Postcondition

[Feature_TI][x.0] e2e_tl_cell_lock_unlock_lte_with_oam_kpi
    [Setup]    Configuration Precondition    CN=REF_10_16_UTESRANSISO909     #N=${UUF_ITERATIONS}
    ${UUF_NODES}  ${UUF_ITERATIONS}=  UUF Create Dictionary Description For UUF Type Regular Testcases  ${cfg.active_bts_list}
    e2e_tl_cell_lock_unlock_lte_with_oam_kpi
    ...  nodes_details=${UUF_NODES}
    ...  test_nodes_details=${UUF_NODES}
    ...  iterations_per_node=${UUF_ITERATIONS}
    ...  report=${False}
    ...  customers_list=${CUSTOMERS}
    [Teardown]    Configuration Postcondition

[Feature_TI][x.0] e2e_tl_capacity_module_lock_unlock
    [Setup]    Configuration Precondition    CN=REF_10_16_UTESRANSISO909     #N=${UUF_ITERATIONS}
    ${UUF_NODES}  ${UUF_ITERATIONS}=  UUF Create Dictionary Description For UUF Type Regular Testcases  ${cfg.active_bts_list}
    e2e_tl_capacity_module_lock_unlock
    ...  nodes_details=${UUF_NODES}
    ...  test_nodes_details=${UUF_NODES}
    ...  iterations_per_node=${UUF_ITERATIONS}
    ...  report=${False}
    ...  customers_list=${CUSTOMERS}
    [Teardown]    Configuration Postcondition

[Feature_TI][x.0] e2e_tl_ru_lock_unlock
    [Setup]    Configuration Precondition    CN=REF_10_16_UTESRANSISO909     #N=${UUF_ITERATIONS}
    ${UUF_NODES}  ${UUF_ITERATIONS}=  UUF Create Dictionary Description For UUF Type Regular Testcases  ${cfg.active_bts_list}
    e2e_tl_ru_lock_unlock
    ...  nodes_details=${UUF_NODES}
    ...  test_nodes_details=${UUF_NODES}
    ...  iterations_per_node=${UUF_ITERATIONS}
    ...  report=${False}
    ...  customers_list=${CUSTOMERS}
    [Teardown]    Configuration Postcondition

[Feature_TI][x.0] e2e_tl_bts_block_unblock
    [Setup]    Configuration Precondition    CN=REF_10_16_UTESRANSISO909     #N=${UUF_ITERATIONS}
    ${UUF_NODES}  ${UUF_ITERATIONS}=  UUF Create Dictionary Description For UUF Type Regular Testcases  ${cfg.active_bts_list}
    e2e_tl_bts_block_unblock
    ...  nodes_details=${UUF_NODES}
    ...  test_nodes_details=${UUF_NODES}
    ...  iterations_per_node=${UUF_ITERATIONS}
    ...  report=${False}
    ...  customers_list=${CUSTOMERS}
    [Teardown]    Configuration Postcondition

[Feature_TI][x.0] e2e_tl_cell_block_unblock_nr_with_oam_kpi
    [Setup]    Configuration Precondition    CN=REF_10_16_UTESRANSISO909     #N=${UUF_ITERATIONS}
    ${UUF_NODES}  ${UUF_ITERATIONS}=  UUF Create Dictionary Description For UUF Type Regular Testcases  ${cfg.active_bts_list}
    e2e_tl_cell_block_unblock_nr_with_oam_kpi
    ...  nodes_details=${UUF_NODES}
    ...  test_nodes_details=${UUF_NODES}
    ...  iterations_per_node=${UUF_ITERATIONS}
    ...  report=${False}
    ...  customers_list=${CUSTOMERS}
    [Teardown]    Configuration Postcondition

[Feature_TI][x.0] e2e_tl_cell_block_unblock_lte_with_oam_kpi
    [Setup]    Configuration Precondition    CN=REF_10_16_UTESRANSISO909     #N=${UUF_ITERATIONS}
    ${UUF_NODES}  ${UUF_ITERATIONS}=  UUF Create Dictionary Description For UUF Type Regular Testcases  ${cfg.active_bts_list}
    e2e_tl_cell_block_unblock_lte_with_oam_kpi
    ...  nodes_details=${UUF_NODES}
    ...  test_nodes_details=${UUF_NODES}
    ...  iterations_per_node=${UUF_ITERATIONS}
    ...  report=${False}
    ...  customers_list=${CUSTOMERS}
    [Teardown]    Configuration Postcondition


[Feature_TI][x.0] e2e_tl_cell_block_unblock_wcdma_with_oam_kpi
    [Setup]    Configuration Precondition    CN=REF_10_16_UTESRANSISO909     #N=${UUF_ITERATIONS}
    ${UUF_NODES}  ${UUF_ITERATIONS}=  UUF Create Dictionary Description For UUF Type Regular Testcases  ${cfg.active_bts_list}
    e2e_tl_cell_block_unblock_wcdma_with_oam_kpi
    ...  nodes_details=${UUF_NODES}
    ...  test_nodes_details=${UUF_NODES}
    ...  iterations_per_node=${UUF_ITERATIONS}
    ...  report=${False}
    ...  customers_list=${CUSTOMERS}
    [Teardown]    Configuration Postcondition

[Feature_TI][x.0] e2e_tl_cell_block_unblock_gsm_with_oam_kpi
    [Setup]    Configuration Precondition    CN=REF_10_16_UTESRANSISO909     #N=${UUF_ITERATIONS}
    ${UUF_NODES}  ${UUF_ITERATIONS}=  UUF Create Dictionary Description For UUF Type Regular Testcases  ${cfg.active_bts_list}
    e2e_tl_cell_block_unblock_gsm_with_oam_kpi
    ...  nodes_details=${UUF_NODES}
    ...  test_nodes_details=${UUF_NODES}
    ...  iterations_per_node=${UUF_ITERATIONS}
    ...  report=${False}
    ...  customers_list=${CUSTOMERS}
    [Teardown]    Configuration Postcondition

[Feature_TI][x.0] e2e_tl_delta_commissioning_with_online_parameter_modification
    [Setup]    Configuration Precondition    CN=REF_10_16_UTESRANSISO909     #N=${UUF_ITERATIONS}
    ${UUF_NODES}  ${UUF_ITERATIONS}=  UUF Create Dictionary Description For UUF Type Regular Testcases  ${cfg.active_bts_list}
    e2e_tl_delta_commissioning_with_online_parameter_modification
    ...  nodes_details=${UUF_NODES}
    ...  test_nodes_details=${UUF_NODES}
    ...  iterations_per_node=${UUF_ITERATIONS}
    ...  report=${False}
    ...  customers_list=${CUSTOMERS}
    ...  delta=${delta_file_path}
    [Teardown]    Configuration Postcondition

[Feature_TI][x.0] e2e_tl_delta_commissioning_with_site_reset_required
    [Setup]    Configuration Precondition    CN=REF_10_16_UTESRANSISO909     #N=${UUF_ITERATIONS}
    ${UUF_NODES}  ${UUF_ITERATIONS}=  UUF Create Dictionary Description For UUF Type Regular Testcases  ${cfg.active_bts_list}
    e2e_tl_delta_commissioning_with_site_reset_required
    ...  nodes_details=${UUF_NODES}
    ...  test_nodes_details=${UUF_NODES}
    ...  iterations_per_node=${UUF_ITERATIONS}
    ...  report=${False}
    ...  customers_list=${CUSTOMERS}
    ...  delta=${delta_file_path}
    [Teardown]    Configuration Postcondition

[Feature_TI][x.0] e2e_tl_ru_power_reset
    [Setup]    Configuration Precondition    CN=REF_10_16_UTESRANSISO909     #N=${UUF_ITERATIONS}
    ${rmod_list_under_test_dictionary}=  UUF Prepare Rmod Under Test Dictionary Description  ${CFG.scf_rmods_under_test}
    ${UUF_NODES}  ${UUF_ITERATIONS}=  UUF Create Dictionary Description For UUF Type Regular Testcases  ${cfg.active_bts_list}
    e2e_tl_ru_power_reset
    ...  nodes_details=${UUF_NODES}
    ...  test_nodes_details=${UUF_NODES}
    ...  iterations_per_node=${UUF_ITERATIONS}
    ...  report=${False}
    ...  customers_list=${CUSTOMERS}
    ...  rmods_with_pdu_ports=${rmod_list_under_test_dictionary}
    [Teardown]    Configuration Postcondition

[Feature_TI][x.0] e2e_parallel_sw_upgrade_rollback_with_oam_kpi
    [Setup]    Configuration Precondition    CN=REF_10_16_UTESRANSISO909     #N=${UUF_ITERATIONS}
    ${UUF_NODES}  ${UUF_ITERATIONS}=  UUF Create Dictionary Description For UUF Type Regular Testcases  ${cfg.active_bts_list}
    e2e_parallel_sw_upgrade_rollback_with_oam_kpi
    ...  nodes_details=${UUF_NODES}
    ...  test_nodes_details=${UUF_NODES}
    ...  iterations_per_node=${UUF_ITERATIONS}
    ...  report=${False}
    ...  customers_list=${CUSTOMERS}
    [Teardown]    Configuration Postcondition

[Feature_TI][x.0] e2e_parallel_sw_upgrade
    [Setup]    Configuration Precondition    CN=REF_10_16_UTESRANSISO909     #N=${UUF_ITERATIONS}
    ${UUF_NODES}  ${UUF_ITERATIONS}=  UUF Create Dictionary Description For UUF Type Regular Testcases  ${cfg.active_bts_list}
    e2e_parallel_sw_upgrade
    ...  nodes_details=${UUF_NODES}
    ...  test_nodes_details=${UUF_NODES}
    ...  iterations_per_node=${UUF_ITERATIONS}
    ...  report=${False}
    ...  customers_list=${CUSTOMERS}
    [Teardown]    Configuration Postcondition


