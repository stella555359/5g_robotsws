*** Settings ***
Library     taf/rfrl/csv4all/CSV4AllTestCases.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/common/btslog.robot

Documentation
...    Author: shifu lan
...    Contact: shifu.lan@nokia-sbell.com
...    squad group: VRF_HAZ4_T04
...    Feature E2E Common keywords with taf.rfrl.csv4all library


*** Keywords ***
Set Testline Scout Name
    [Arguments]    ${node}    ${nodes}
    Set To Dictionary    ${node}    testline_scout_name=${SCOUT_TL_NAME}
    Set Suite Variable    ${nodes}
    Set Suite Variable    ${node}
    Run Keyword And Ignore Error    Stop Btslog With Path Check    target_dir=${SAVE LOG DIRECTORY}

e2e_tl_cell_lock_unlock_nr_with_oam_kpi
    [Arguments]    ${report}=${True}
    ${TEST_NAME}   Set Variable   [1]e2e_tl_cell_lock_unlock_nr_with_oam_kpi
    Set Global Variable   ${TEST_NAME}
    CSV4AllTestCases.e2e_tl_cell_lock_unlock_nr_with_oam_kpi
    ...    nodes_details=${nodes}
    ...    test_nodes_details=${node}
    ...    iterations_per_node=${runs_of_cell_lock}
    ...    report=${report}
    ...    calculate_kpi=${True}                  # default value, to be replaced with variable if needed
    ...    kpi_targets=${None}                    # default value, to be replaced with variable if needed
    ...    use_dcap=${False}                      # default value, to be replaced with variable if needed
    ...    qc_domain=${qc_domain}
    ...    qc_id=${qc_id}
    ...    qc_project=${qc_project}
    ...    customers_list=${customers}
    ...    report_comment=${None}                 # default value, to be replaced with variable if needed
    ...    sw_build=${None}                       # default value, to be replaced with variable if needed
    ...    topology=${None}                       # default value, to be replaced with variable if needed
    ...    stop_test_after_fail=${False}          # default value, to be replaced with variable if needed
    ...    l3_call_method=${l3_call_method}       # default value, to be replaced with variable if needed

e2e_tl_cell_block_unblock_nr_with_oam_kpi
    [Arguments]    ${report}=${True}
    ${fault_list}    Create List    49
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    ${TEST_NAME}   Set Variable   [1]e2e_tl_cell_block_unblock_nr_with_oam_kpi
    Set Global Variable   ${TEST_NAME}
    CSV4AllTestCases.e2e_tl_cell_block_unblock_nr_with_oam_kpi
    ...    nodes_details=${nodes}
    ...    test_nodes_details=${node}
    ...    iterations_per_node=${runs_of_cell_block}
    ...    report=${report}
    ...    calculate_kpi=${True}                  # default value, to be replaced with variable if needed
    ...    kpi_targets=${None}                    # default value, to be replaced with variable if needed
    ...    use_dcap=${False}                      # default value, to be replaced with variable if needed
    ...    qc_domain=${qc_domain}
    ...    qc_id=${qc_id}
    ...    qc_project=${qc_project}
    ...    customers_list=${customers}
    ...    report_comment=${None}                 # default value, to be replaced with variable if needed
    ...    sw_build=${None}                       # default value, to be replaced with variable if needed
    ...    topology=${None}                       # default value, to be replaced with variable if needed
    ...    stop_test_after_fail=${False}          # default value, to be replaced with variable if needed
    ...    l3_call_method=${l3_call_method}       # default value, to be replaced with variable if needed

e2e_tl_capacity_module_reset_with_oam_kpi
    [Arguments]    ${report}=${True}
    ${fault_list}    Create List    7509
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    ${TEST_NAME}   Set Variable   [1]e2e_tl_capacity_module_reset_with_oam_kpi
    Set Global Variable   ${TEST_NAME}
    CSV4AllTestCases.e2e_tl_capacity_module_reset_with_oam_kpi
    ...    nodes_details=${nodes}
    ...    test_nodes_details=${node}
    ...    iterations_per_node=${runs_of_bbmd_reset}
    ...    report=${report}
    ...    calculate_kpi=${True}                  # default value, to be replaced with variable if needed
    ...    kpi_targets=${None}                    # default value, to be replaced with variable if needed
    ...    use_dcap=${False}                      # default value, to be replaced with variable if needed
    ...    qc_domain=${qc_domain}
    ...    qc_id=${qc_id}
    ...    qc_project=${qc_project}
    ...    customers_list=${customers}
    ...    report_comment=${None}                 # default value, to be replaced with variable if needed
    ...    sw_build=${None}                       # default value, to be replaced with variable if needed
    ...    topology=${None}                       # default value, to be replaced with variable if needed
    ...    stop_test_after_fail=${False}          # default value, to be replaced with variable if needed
    ...    l3_call_method=${l3_call_method}       # default value, to be replaced with variable if needed

e2e_tl_ru_reset_with_oam_kpi
    [Arguments]    ${report}=${True}
    ${fault_list}    Create List    7509
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    ${TEST_NAME}   Set Variable   [1]e2e_tl_ru_reset_with_oam_kpi
    Set Global Variable   ${TEST_NAME}
    CSV4AllTestCases.e2e_tl_ru_reset_with_oam_kpi
    ...    nodes_details=${nodes}
    ...    test_nodes_details=${node}
    ...    iterations_per_node=${runs_of_rf_reset}
    ...    report=${report}
    ...    calculate_kpi=${True}                  # default value, to be replaced with variable if needed
    ...    kpi_targets=${None}                    # default value, to be replaced with variable if needed
    ...    use_dcap=${False}                      # default value, to be replaced with variable if needed
    ...    qc_domain=${qc_domain}
    ...    qc_id=${qc_id}
    ...    qc_project=${qc_project}
    ...    customers_list=${customers}
    ...    report_comment=${None}                 # default value, to be replaced with variable if needed
    ...    sw_build=${None}                       # default value, to be replaced with variable if needed
    ...    topology=${None}                       # default value, to be replaced with variable if needed
    ...    stop_test_after_fail=${False}          # default value, to be replaced with variable if needed
    ...    l3_call_method=${l3_call_method}       # default value, to be replaced with variable if needed

e2e_tl_delta_commissioning_with_nr_rat_reset
    [Arguments]    ${report}=${True}
    ${TEST_NAME}   Set Variable   [1]e2e_tl_delta_commissioning_with_nr_rat_reset
    Set Global Variable   ${TEST_NAME}
    ${delta_file}   Get_DeltaFile_With_Modify_Parameter  connection=GNB_OAM   dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    ...   filter_parameter=Activate FDM UE skipping overload control   pattern=actFdmUeSkippingOlc
    CSV4AllTestCases.e2e_tl_delta_commissioning_with_nr_rat_reset
    ...    nodes_details=${nodes}
    ...    test_nodes_details=${node}
    ...    iterations_per_node=${runs_of_delt_commision}
    ...    delta=${delta_file}
    ...    rat_to_reset=NR
    ...    report=${report}
    ...    calculate_kpi=${True}                  # default value, to be replaced with variable if needed
    ...    kpi_targets=${None}                    # default value, to be replaced with variable if needed
    ...    use_dcap=${False}                      # default value, to be replaced with variable if needed
    ...    qc_domain=${qc_domain}
    ...    qc_id=${qc_id}
    ...    qc_project=${qc_project}
    ...    customers_list=${customers}
    ...    report_comment=${None}                 # default value, to be replaced with variable if needed
    ...    sw_build=${None}                       # default value, to be replaced with variable if needed
    ...    topology=${None}                       # default value, to be replaced with variable if needed
    ...    stop_test_after_fail=${False}          # default value, to be replaced with variable if needed
    ...    l3_call_method=${l3_call_method}       # default value, to be replaced with variable if needed

e2e_tl_delta_commissioning_with_site_reset_required
    [Arguments]    ${report}=${True}
    ${TEST_NAME}   Set Variable   [1]e2e_tl_delta_commissioning_with_site_reset_required
    Set Global Variable   ${TEST_NAME}
    ${delta_file}   Get_DeltaFile_With_Modify_Parameter  connection=GNB_OAM   dist_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/FEATCADM-1
    ...   filter_parameter=Activate support for distributed site   pattern=actDistributedSite
    CSV4AllTestCases.e2e_tl_delta_commissioning_with_site_reset_required
    ...    nodes_details=${nodes}
    ...    test_nodes_details=${node}
    ...    iterations_per_node=${runs_of_delt_commision}
    ...    delta=${delta_file}
    ...    report=${report}
    ...    calculate_kpi=${True}                  # default value, to be replaced with variable if needed
    ...    kpi_targets=${None}                    # default value, to be replaced with variable if needed
    ...    use_dcap=${False}                      # default value, to be replaced with variable if needed
    ...    qc_domain=${qc_domain}
    ...    qc_id=${qc_id}
    ...    qc_project=${qc_project}
    ...    customers_list=${customers}
    ...    report_comment=${None}                 # default value, to be replaced with variable if needed
    ...    sw_build=${None}                       # default value, to be replaced with variable if needed
    ...    topology=${None}                       # default value, to be replaced with variable if needed
    ...    stop_test_after_fail=${False}          # default value, to be replaced with variable if needed
    ...    l3_call_method=${l3_call_method}       # default value, to be replaced with variable if needed

e2e_tl_site_reset_without_hwf_with_oam_kpi
    [Arguments]    ${call_method}=${None}    ${report}=${True}
    ${TEST_NAME}   Set Variable   [1]e2e_tl_site_reset_without_hwf_with_oam_kpi
    Set Global Variable   ${TEST_NAME}
    CSV4AllTestCases.e2e_tl_site_reset_with_oam_kpi
    ...    nodes_details=${nodes}
    ...    test_nodes_details=${node}
    ...    iterations_per_node=${runs_of_uuf_reset}
    ...    report=${report}
    ...    calculate_kpi=${True}                  # default value, to be replaced with variable if needed
    ...    kpi_targets=${None}                    # default value, to be replaced with variable if needed
    ...    use_dcap=${False}                      # default value, to be replaced with variable if needed
    ...    qc_domain=${qc_domain}
    ...    qc_id=${qc_id}
    ...    qc_project=${qc_project}
    ...    customers_list=${customers}
    ...    report_comment=${None}                 # default value, to be replaced with variable if needed
    ...    sw_build=${None}                       # default value, to be replaced with variable if needed
    ...    topology=${None}                       # default value, to be replaced with variable if needed
    ...    stop_test_after_fail=${False}          # default value, to be replaced with variable if needed
    ...    l3_call_method=${call_method}
    ...    reset_without_ru=${None}               # default value, to be replaced with variable if needed
    ...    graceful_cell_shutdown=${None}         # default value, to be replaced with variable if needed
    ...    detailed_console_log=${True}           # default value, to be replaced with variable if needed
    ...    swconfig_modification=${True}          # default value, to be replaced with variable if needed

e2e_tl_sw_upgrade_rollback_with_oam_kpi
    [Arguments]    ${call_method}=${None}    ${current_version}=${None}    ${report}=${True}
	IF    '${current_version}'=='None'
        ${current_version}    E2E_Get_Current_Version
    END
    Set Test Variable    ${source_sw}    ${current_version}
    log to console   \nsource:${source_sw}
    ${package_path}   Download SW package to VM   ${target_version}
    Set Test Variable    ${Active_SW_version}    ${target_version}
    ${file_exist}   run keyword and return status  OperatingSystem.File Should Exist   ${package_path}
    ${target_sw_path}   Set Variable If   ${file_exist}   ${package_path}   ${None}
    Set To Dictionary    ${node}    source_sw=${source_sw}    target_sw=${target_version}
    ${TEST_NAME}   Set Variable   [1]e2e_tl_sw_upgrade_rollback_with_oam_kpi
    Set Global Variable   ${TEST_NAME}
    CSV4AllTestCases.e2e_tl_sw_upgrade_rollback_with_oam_kpi
    ...    nodes_details=${nodes}
    ...    test_nodes_details=${node}
    ...    iterations_per_node=${runs_of_uuf_upgrade}
    ...    report=${report}
    ...    calculate_kpi=${True}                  # default value, to be replaced with variable if needed
    ...    kpi_targets=${None}                    # default value, to be replaced with variable if needed
    ...    use_dcap=${False}                      # default value, to be replaced with variable if needed
    ...    qc_domain=${qc_domain}
    ...    qc_id=${qc_id}
    ...    qc_project=${qc_project}
    ...    customers_list=${customers}
    ...    report_comment=${None}                 # default value, to be replaced with variable if needed
    ...    sw_build=${None}                       # default value, to be replaced with variable if needed
    ...    topology=${None}                       # default value, to be replaced with variable if needed
    ...    use_external_storage=${False}          # default value, to be replaced with variable if needed
    ...    download_path=/home/ute
    ...    use_testpackage=${False}               # default value, to be replaced with variable if needed
    ...    restore_to_target_sw=${True}           # default value, to be replaced with variable if needed
    ...    stop_test_after_fail=${False}          # default value, to be replaced with variable if needed
    ...    artifactory_location=espoo2               # default value, to be replaced with variable if needed
    ...    package_suffix=A54                     # default value, to be replaced with variable if needed
    ...    synchronize_software_on_passive=${False}  # default value, to be replaced with variable if needed
    ...    yaft_path=/home/ute                    # default value, to be replaced with variable if needed
    ...    virtualenv_dir=${None}                 # default value, to be replaced with variable if needed
    ...    rollback_reverse_order=${False}        # default value, to be replaced with variable if needed
    ...    l3_call_method=${call_method}
