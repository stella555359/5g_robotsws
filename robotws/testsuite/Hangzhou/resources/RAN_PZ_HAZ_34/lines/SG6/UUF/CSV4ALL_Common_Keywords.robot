*** Settings ***
Documentation       Test suite for basic CSV4ALL Tests in loop
...                 Author: Lin Stella
...                 Contact: stella.lin@nokia-sbell.com

Library             taf/rfrl/csv4all/CSV4AllTestCases.py     WITH NAME      CSV4ALL
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/TMO/TMO_common_keywords.robot

*** Variables ***
${ITERATION_SITE_RESET}                    1
${ITERATION_BBMOD_RESET}                   10
${ITERATION_SW_UPGRADE_ROLLBACK}           1
${ITERATION_LOCK_UNLOCK}           15
${ITERATION_RU_RESET}           20
${ITERATION_DELTA}           1
${SOURCE_SW_TEMP}                               ${EMPTY}
${TARGET_SW_TEMP}                               ${EMPTY}

${SITE_RESET_TEST_QC_ID}                   ${EMPTY}
${SW_UPGRADE_ROLLBACK_TEST_QC_ID}          ${EMPTY}

@{CUSTOM_ALLOWED_ALARMS}                   4203    4459    8000    1932    1933    1934    61631    4293    4297    4589    7307    4741    1815
...    6261    7535    7525    6331    16    4569    4776    4367    4352    4670    6150
${SERIAL_CONSOLE}                          ${False}

${REPORT}                                  ${False}
${QC_REPORT}                               ${False}
${STOP_TEST_AFTER_FAIL}                    ${False}

@{CUSTOMERS}                               TMO US
${QC_DOMAIN}                               MN_RAN
${QC_PROJECT}                              RAN_VRF
${RP_LOCATION}                             VRF_HAZ4
${RP_ORGANIZATION}                         VRF_HAZ4_T06
${RP_CA}                                   VRF_SiSo
${CALCULATE_KPI}                           ${True}
${QC_ID_TEMP}                              None

&{GNB}                                     node_vm=${tl.test_pcs[0].default_ssh_connection_details.addr}
...                                        testline_object=${tl.gnbs[0]}
...                                        source_sw=${SOURCE_SW_TEMP}
...                                        target_sw=${TARGET_SW_TEMP}
...                                        custom_allowed_alarms=${CUSTOM_ALLOWED_ALARMS}
...                                        bts_host_ip=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}

&{ENB}
...                                        node_vm=${tl.test_pcs[1].default_ssh_connection_details.addr}
...                                        testline_object=${tl.enbs[0]}
...                                        source_sw=${SOURCE_SW_TEMP}
...                                        target_sw=${TARGET_SW_TEMP}
...                                        custom_allowed_alarms=${CUSTOM_ALLOWED_ALARMS}
...                                        bts_host_ip=${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}

@{NODES}                                   ${GNB}
@{NODES_ENB}                               ${ENB}
@{UPGRADE_NODES}                           ${GNB}    ${ENB}
@{UPGRADE_NODES_GNB_FIRST}                 ${GNB}    ${ENB}
@{UPGRADE_NODES_ENB_FIRST}                 ${ENB}    ${GNB}


*** Keywords ***
#Test_Case_Steps
E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI_WebUI
    [Timeout]   8h
    ${version_splitted}    Split String    ${package_version_1525-CA}    _
    ${tmp_gnb_version}    Replace String Using Regexp    string=${version_splitted[0]}    pattern=SBTS|5G    replace_with=${EMPTY}
#    ${qc_id}     Set Variable If    '${tmp_gnb_version}'=='24R3'     850005
#    ...                             '${tmp_gnb_version}'=='00'    35487
#    ...                             '${tmp_gnb_version}'=='24R2'    834521
#    ...                             '${tmp_gnb_version}'=='25R2'    150553
    ${qc_id}     Set Variable If    '${tmp_gnb_version}'=='24R3'     850005
    ...                             '${tmp_gnb_version}'=='00'    104319
    ...                             '${tmp_gnb_version}'=='24R2'    834521
    ...                             '${tmp_gnb_version}'=='25R2'    150553
    ...                             '${tmp_gnb_version}'=='25R1'    136399
    Check Rollback is needed before sw upgrade
    Check TMO Gnb Ready And All Cell On Air
    CSV4ALL_PARAMS.Set_Target_Source_SW_Build
    Set To Dictionary    ${GNB}    source_sw    ${SOURCE_SW}
    Set To Dictionary    ${GNB}    target_sw    ${TARGET_SW}
    log to console    GNB info is: ${GNB}
    CSV4ALL.e2e_tl_sw_upgrade_rollback_with_oam_kpi
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODES}
    ...    iterations_per_node=${ITERATION_SW_UPGRADE_ROLLBACK}
    ...    report=${REPORT}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${qc_id}
    ...    qc_project=${QC_PROJECT}
    ...    customers_list=${CUSTOMERS}
    ...    stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...    calculate_kpi=${CALCULATE_KPI}

E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI_WebUI_and_L3_call
    [Timeout]   12h
    ${version_splitted}    Split String    ${package_version_1525-CA}    _
    ${tmp_gnb_version}    Replace String Using Regexp    string=${version_splitted[0]}    pattern=SBTS|5G    replace_with=${EMPTY}
    ${qc_id}     Set Variable If    '${tmp_gnb_version}'=='00'    35491
    Check Rollback is needed before sw upgrade
    Check TMO Gnb Ready And All Cell On Air
    CSV4ALL_PARAMS.Set_Target_Source_SW_Build
    Set To Dictionary    ${GNB}    source_sw    ${SOURCE_SW}
    Set To Dictionary    ${GNB}    target_sw    ${TARGET_SW}
    log to console    GNB info is: ${GNB}
#    #perform upgrade
#    CSV4ALL.e2e_parallel_sw_upgrade
#    ...    nodes_details=${NODES}
#    ...    test_nodes_details=${NODES}
#    ...    iterations_per_node=${ITERATION_SW_UPGRADE_ROLLBACK}
#    ...    report=${False}
#    ...    qc_domain=${QC_DOMAIN}
#    ...    qc_id=${qc_id}
#    ...    qc_project=${QC_PROJECT}
#    ...    customers_list=${CUSTOMERS}
#    ...    stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
#    #L3 call
#    Local_node_attach_test_keyword
#    #perform rollback
#    Set To Dictionary    ${GNB}    source_sw    ${TARGET_SW}
#    Set To Dictionary    ${GNB}    target_sw    ${SOURCE_SW}
#    CSV4ALL.e2e_tl_rollback_test
#    ...    nodes_details=${NODES}
#    ...    test_nodes_details=${NODES}
#    ...    iterations_per_node=${ITERATION_SW_UPGRADE_ROLLBACK}
#    ...    customers_list=${CUSTOMERS}
#    ...    stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ${ue_index}    Set Variable If    '${tl_prefix}'=='T080'    ${15}    ${0}
    Set Test Variable    ${ue_index}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    Procedures.Start UE Prepare    ue_index=${ue_index}    ue_type=${ue_type}
    ...                                           detach_request=${true}      power_reset=False
    ...                                           get_spark_license=${true}
    CSV4ALL.e2e_tl_sw_upgrade_rollback_with_oam_kpi
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODES}
    ...    iterations_per_node=${ITERATION_SW_UPGRADE_ROLLBACK}
    ...    report=${REPORT}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${qc_id}
    ...    qc_project=${QC_PROJECT}
    ...    customers_list=${CUSTOMERS}
    ...    stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...    calculate_kpi=${CALCULATE_KPI}
    ...    l3_call_method=Local_node_attach_test_keyword


E2E_TL_Cell_Block_Unblock_LTE_with_OAM_KPI
    [Timeout]   8h
    ${version_splitted}    Split String    ${package_version_1525-CA}    _
    ${tmp_gnb_version}    Replace String Using Regexp    string=${version_splitted[0]}    pattern=SBTS|5G    replace_with=${EMPTY}
    ${qc_id}     Set Variable If    '${tmp_gnb_version}'=='00'    35492
    CSV4ALL.e2e_tl_cell_block_unblock_lte_with_oam_kpi
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODES}
    ...    iterations_per_node=${ITERATION_LOCK_UNLOCK}
    ...    report=${REPORT}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${qc_id}
    ...    qc_project=${QC_PROJECT}
    ...    customers_list=${CUSTOMERS}
    ...    stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...    calculate_kpi=${CALCULATE_KPI}


E2E_TL_Capacity_Module_Reset_with_OAM_KPI
    [Timeout]   8h
    ${version_splitted}    Split String    ${package_version_1525-CA}    _
    ${tmp_gnb_version}    Replace String Using Regexp    string=${version_splitted[0]}    pattern=SBTS|5G    replace_with=${EMPTY}
    ${qc_id}     Set Variable If    '${tmp_gnb_version}'=='00'    104323
#    Run    '/opt/btslog/btslog_launcher' stop_udplog
#    Run    killall btslog
    CSV4ALL.e2e_tl_capacity_module_reset_with_oam_kpi
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODES}
    ...    iterations_per_node=${ITERATION_BBMOD_RESET}
    ...    report=${REPORT}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${qc_id}
    ...    qc_project=${QC_PROJECT}
    ...    customers_list=${CUSTOMERS}
    ...    stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...    calculate_kpi=${CALCULATE_KPI}

E2E_TL_Delta_Commissioning_With_Site_Reset_Required
    [Timeout]   8h
    ${version_splitted}    Split String    ${package_version_1525-CA}    _
    ${tmp_gnb_version}    Replace String Using Regexp    string=${version_splitted[0]}    pattern=SBTS|5G    replace_with=${EMPTY}
    ${qc_id}     Set Variable If    '${tmp_gnb_version}'=='00'    35495
    ${site_reset_delta_update}    CSV4ALL_PARAMS.SiteReset_Delta_Update
    CSV4ALL.e2e_tl_delta_commissioning_with_site_reset_required
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODES}
    ...    iterations_per_node=${ITERATION_DELTA}
    ...    delta=${site_reset_delta_update}
    ...    report=${REPORT}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${qc_id}
    ...    qc_project=${QC_PROJECT}
    ...    customers_list=${CUSTOMERS}
    ...    stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...    calculate_kpi=${CALCULATE_KPI}

E2E_TL_Cell_Lock_Unlock_LTE_with_OAM_KPI
    [Timeout]   8h
    ${version_splitted}    Split String    ${package_version_1525-CA}    _
    ${tmp_gnb_version}    Replace String Using Regexp    string=${version_splitted[0]}    pattern=SBTS|5G    replace_with=${EMPTY}
    ${qc_id}     Set Variable If    '${tmp_gnb_version}'=='00'    35494
    CSV4ALL.e2e_tl_cell_lock_unlock_lte_with_oam_kpi
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODES}
    ...    iterations_per_node=${ITERATION_LOCK_UNLOCK}
    ...    report=${REPORT}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${qc_id}
    ...    qc_project=${QC_PROJECT}
    ...    customers_list=${CUSTOMERS}
    ...    stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...    calculate_kpi=${CALCULATE_KPI}


E2E_TL_Cell_Block_Unblock_NR_with_OAM_KPI
    [Timeout]   8h
    ${version_splitted}    Split String    ${package_version_1525-CA}    _
    ${tmp_gnb_version}    Replace String Using Regexp    string=${version_splitted[0]}    pattern=SBTS|5G    replace_with=${EMPTY}
    ${qc_id}     Set Variable If    '${tmp_gnb_version}'=='00'    35498
    CSV4ALL.e2e_tl_cell_block_unblock_nr_with_oam_kpi
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODES}
    ...    iterations_per_node=${ITERATION_LOCK_UNLOCK}
    ...    report=${REPORT}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${qc_id}
    ...    qc_project=${QC_PROJECT}
    ...    customers_list=${CUSTOMERS}
    ...    stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...    calculate_kpi=${CALCULATE_KPI}

E2E_TL_RU_Reset_with_OAM_KPI
    [Timeout]   10h
    ${version_splitted}    Split String    ${package_version_1525-CA}    _
    ${tmp_gnb_version}    Replace String Using Regexp    string=${version_splitted[0]}    pattern=SBTS|5G    replace_with=${EMPTY}
    ${qc_id}     Set Variable If    '${tmp_gnb_version}'=='00'    35497
    CSV4ALL.e2e_tl_ru_reset_with_oam_kpi
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODES}
    ...    iterations_per_node=${ITERATION_RU_RESET}
    ...    report=${REPORT}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${qc_id}
    ...    qc_project=${QC_PROJECT}
    ...    customers_list=${CUSTOMERS}
    ...    stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...    calculate_kpi=${CALCULATE_KPI}


E2E_TL_Cell_Lock_Unlock_NR_with_OAM_KPI
    [Timeout]   8h
    ${version_splitted}    Split String    ${package_version_1525-CA}    _
    ${tmp_gnb_version}    Replace String Using Regexp    string=${version_splitted[0]}    pattern=SBTS|5G    replace_with=${EMPTY}
    ${qc_id}     Set Variable If    '${tmp_gnb_version}'=='00'    35496
    CSV4ALL.e2e_tl_cell_lock_unlock_nr_with_oam_kpi
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODES}
    ...    iterations_per_node=${ITERATION_LOCK_UNLOCK}
    ...    report=${REPORT}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${qc_id}
    ...    qc_project=${QC_PROJECT}
    ...    customers_list=${CUSTOMERS}
    ...    stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...    calculate_kpi=${CALCULATE_KPI}


E2E_TL_Delta_Commissioning_With_LTE_Rat_Reset
    [Timeout]   8h
    ${version_splitted}    Split String    ${package_version_1525-CA}    _
    ${tmp_gnb_version}    Replace String Using Regexp    string=${version_splitted[0]}    pattern=SBTS|5G    replace_with=${EMPTY}
    ${qc_id}     Set Variable If    '${tmp_gnb_version}'=='00'    35503
    ${lte_rat_reset_delta_update}    CSV4ALL_PARAMS.Lte_Rat_Reset_Delta_Update
    CSV4ALL.e2e_tl_delta_commissioning_with_lte_rat_reset
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODES}
    ...    iterations_per_node=${ITERATION_DELTA}
    ...    delta=${lte_rat_reset_delta_update}
    ...    report=${REPORT}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${qc_id}
    ...    qc_project=${QC_PROJECT}
    ...    customers_list=${CUSTOMERS}
    ...    stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...    calculate_kpi=${CALCULATE_KPI}


E2E_TL_Delta_Commissioning_With_NR_Rat_Reset
    [Timeout]   8h
    ${version_splitted}    Split String    ${package_version_1525-CA}    _
    ${tmp_gnb_version}    Replace String Using Regexp    string=${version_splitted[0]}    pattern=SBTS|5G    replace_with=${EMPTY}
    ${qc_id}     Set Variable If    '${tmp_gnb_version}'=='00'    35504
    ${nr_rat_reset_delta_update}     CSV4ALL_PARAMS.NR_Rat_Reset_Delta_Update
    CSV4ALL.e2e_tl_delta_commissioning_with_nr_rat_reset
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODES}
    ...    iterations_per_node=${ITERATION_DELTA}
    ...    delta=${nr_rat_reset_delta_update}
    ...    report=${REPORT}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${qc_id}
    ...    qc_project=${QC_PROJECT}
    ...    customers_list=${CUSTOMERS}
    ...    stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...    calculate_kpi=${CALCULATE_KPI}


E2E_TL_Delta_Commissioning_With_Online_Parameter_Modification
    [Timeout]   8h
    ${version_splitted}    Split String    ${package_version_1525-CA}    _
    ${tmp_gnb_version}    Replace String Using Regexp    string=${version_splitted[0]}    pattern=SBTS|5G    replace_with=${EMPTY}
    ${qc_id}     Set Variable If    '${tmp_gnb_version}'=='00'    35505
    ${online_delta_update}     CSV4ALL_PARAMS.Online_Modify_Delta_Update
    CSV4ALL.e2e_tl_delta_commissioning_with_online_parameter_modification
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODES}
    ...    iterations_per_node=${ITERATION_DELTA}
    ...    delta=${online_delta_update}
    ...    report=${REPORT}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${qc_id}
    ...    qc_project=${QC_PROJECT}
    ...    customers_list=${CUSTOMERS}
    ...    stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...    calculate_kpi=${CALCULATE_KPI}


E2E_TL_Cell_Block_Unblock_GSM_with_OAM_KPI
    [Timeout]   8h
    ${version_splitted}    Split String    ${package_version_1525-CA}    _
    ${tmp_gnb_version}    Replace String Using Regexp    string=${version_splitted[0]}    pattern=SBTS|5G    replace_with=${EMPTY}
    ${qc_id}     Set Variable If    '${tmp_gnb_version}'=='00'    35509
    CSV4ALL.e2e_tl_cell_block_unblock_gsm_with_oam_kpi
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODES}
    ...    iterations_per_node=${ITERATION_LOCK_UNLOCK}
    ...    report=${REPORT}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${qc_id}
    ...    qc_project=${QC_PROJECT}
    ...    customers_list=${CUSTOMERS}
    ...    stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...    calculate_kpi=${CALCULATE_KPI}


E2E_TL_Delta_Commissioning_With_GSM_Rat_Reset
    [Timeout]   8h
    ${version_splitted}    Split String    ${package_version_1525-CA}    _
    ${tmp_gnb_version}    Replace String Using Regexp    string=${version_splitted[0]}    pattern=SBTS|5G    replace_with=${EMPTY}
    ${qc_id}     Set Variable If    '${tmp_gnb_version}'=='00'    35510
    ${gsm_delta_update}     CSV4ALL_PARAMS.GSM_Reset_Delta_Update
    CSV4ALL.e2e_tl_delta_commissioning_with_gsm_rat_reset
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODES}
    ...    iterations_per_node=${ITERATION_DELTA}
    ...    delta=${gsm_delta_update}
    ...    report=${REPORT}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${qc_id}
    ...    qc_project=${QC_PROJECT}
    ...    customers_list=${CUSTOMERS}
    ...    stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...    calculate_kpi=${CALCULATE_KPI}


E2E_TL_Activation_Reset_with_OAM_KPI
    [Timeout]   8h
    ${version_splitted}    Split String    ${package_version_1525-CA}    _
    ${tmp_gnb_version}    Replace String Using Regexp    string=${version_splitted[0]}    pattern=SBTS|5G    replace_with=${EMPTY}
    ${qc_id}     Set Variable If    '${tmp_gnb_version}'=='00'    187961
    Run Keyword And Continue On Failure    CSV4ALL.e2e_tl_activation_reset_test
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODES}
    ...    iterations_per_node=${2}
    ...    report=${REPORT}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${qc_id}
    ...    qc_project=${QC_PROJECT}
    ...    customers_list=${CUSTOMERS}
    ...    stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...    calculate_kpi=${CALCULATE_KPI}

E2E_TL_Site_Reset_with_OAM_KPI
    ${version_splitted}    Split String    ${package_version_1525-CA}    _
    ${tmp_gnb_version}    Replace String Using Regexp    string=${version_splitted[0]}    pattern=SBTS|5G    replace_with=${EMPTY}
    ${qc_id}     Set Variable If    '${tmp_gnb_version}'=='00'    187337
    CSV4ALL.e2e_tl_site_reset_with_oam_kpi
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODES}
    ...    iterations_per_node=${ITERATION_SITE_RESET}
    ...    report=${REPORT}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${qc_id}
    ...    qc_project=${QC_PROJECT}
    ...    customers_list=${CUSTOMERS}
    ...    stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...    calculate_kpi=${CALCULATE_KPI}

5603156_E2E_TL_Site_Reset_without_HWF_with_OAM_KPI_energy_saving_phase
    [Timeout]   12h
    ${version_splitted}    Split String    ${package_version_1525-CA}    _
    ${tmp_gnb_version}    Replace String Using Regexp    string=${version_splitted[0]}    pattern=SBTS|5G    replace_with=${EMPTY}
    ${qc_id}     Set Variable If    '${tmp_gnb_version}'=='25R1'     136394
    ...                             '${tmp_gnb_version}'=='00'    169316
    ...                             '${tmp_gnb_version}'=='25R2'    168456
#    Check Rollback is needed before sw upgrade
#    Check TMO Gnb Ready And All Cell On Air
#    CSV4ALL_PARAMS.Set_Target_Source_SW_Build
#    Set To Dictionary    ${GNB}    source_sw    ${TARGET_SW}
#    Set To Dictionary    ${GNB}    target_sw    ${SOURCE_SW}
    ${Duration}      Set Variable If    '${tl_prefix}'=='T073'    55    30
    ${cell_list}    ${lbpsCellList_length}    ${lbpsCellPeriodList_length}    Get The Cell List What Will Be Enter Energy Saving Mode
    CSV4ALL.e2e_tl_site_reset_without_hwf_with_oam_kpi
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODES}
    ...    iterations_per_node=${ITERATION_SITE_RESET}
    ...    report=${REPORT}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${qc_id}
    ...    qc_project=${QC_PROJECT}
    ...    customers_list=${CUSTOMERS}
    ...    stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...    calculate_kpi=${CALCULATE_KPI}
    ...    swconfig_modification=${False}
#    CSV4ALL.e2e_tl_activation_reset_test
#    ...    nodes_details=${NODES}
#    ...    test_nodes_details=${NODES}
#    ...    iterations_per_node=${ITERATION_SITE_RESET}
#    ...    report=${REPORT}
#    ...    qc_domain=${QC_DOMAIN}
#    ...    qc_id=${qc_id}
#    ...    qc_project=${QC_PROJECT}
#    ...    customers_list=${CUSTOMERS}
#    ...    stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
#    ...    calculate_kpi=${CALCULATE_KPI}
#    ...    sw_build=${TARGET_SW}
    Check Gnb Startup Log
    Check Cell energySavingState    cell_list=${cell_list}    whether_check_energy_saving=${False}
    ${hour}    ${minute}    Get The Time For Energy Saving
    Update Related Parameters For Energy Saving    Duration=${Duration}
    ...                                            Hour=${hour}
    ...                                            Minute=${minute}
    ...                                            lbpsCellList_num=${lbpsCellList_length}
    ...                                            lbpsCellPeriodList_num=${lbpsCellPeriodList_length}
    Wait Until Keyword Succeeds    55 min    60 sec    Check Cell energySavingState    cell_list=${cell_list}
    Check TMO Gnb Ready And All Cell On Air
    Wait Until Keyword Succeeds    5 min    15 sec    Check Cell energySavingState    cell_list=${cell_list}
    ...                                                                               whether_check_energy_saving=${False}
    ${gnb_state}   ${gnb_error_log}=   Run Keyword And Ignore Error
    ...            Check GNB On Air And Unexpect Alarm Should Not Exist without snapshot
    ${enb_state}   ${enb_error_log}=   Run Keyword And Ignore Error    Run Keyword If     '${LTE_WHETHER_IN_GNB}'=='${False}'
    ...                Check ENB On Air And Unexpect Alarm Should Not Exist without snapshot
    [Teardown]      Run Keyword And Ignore Error    COAM Teardown gnb connections

5603159_E2E_TL_Site_Reset_without_HWF_with_OAM_KPI_during_Cells_in_energy_saving
    [Timeout]   12h
    ${version_splitted}    Split String    ${package_version_1525-CA}    _
    ${tmp_gnb_version}    Replace String Using Regexp    string=${version_splitted[0]}    pattern=SBTS|5G    replace_with=${EMPTY}
    ${qc_id}     Set Variable If    '${tmp_gnb_version}'=='25R1'     136394
    ...                             '${tmp_gnb_version}'=='00'    169316
    ...                             '${tmp_gnb_version}'=='25R2'    168456
    #power_save_mode_on_source_build
    ${Duration}      Set Variable If    '${tl_prefix}'=='T073'    55    30
    ${cell_list}    ${lbpsCellList_length}    ${lbpsCellPeriodList_length}    Get The Cell List What Will Be Enter Energy Saving Mode
    ${hour}    ${minute}    Get The Time For Energy Saving
    Update Related Parameters For Energy Saving    Duration=${Duration}
    ...                                            Hour=${hour}
    ...                                            Minute=${minute}
    ...                                            lbpsCellList_num=${lbpsCellList_length}
    ...                                            lbpsCellPeriodList_num=${lbpsCellPeriodList_length}
    Wait Until Keyword Succeeds    55 min    60 sec    Check Cell energySavingState    cell_list=${cell_list}

    CSV4ALL.e2e_tl_site_reset_without_hwf_with_oam_kpi
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODES}
    ...    iterations_per_node=${ITERATION_SITE_RESET}
    ...    report=${REPORT}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${qc_id}
    ...    qc_project=${QC_PROJECT}
    ...    customers_list=${CUSTOMERS}
    ...    stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...    calculate_kpi=${CALCULATE_KPI}
    ...    swconfig_modification=${False}

    Check Gnb Startup Log
    Check TMO Gnb Ready And All Cell On Air
    Wait Until Keyword Succeeds    30 min    15 sec    Check Cell energySavingState    cell_list=${cell_list}
    ...                                                                                whether_check_energy_saving=${False}
    ${gnb_state}   ${gnb_error_log}=   Run Keyword And Ignore Error
    ...            Check GNB On Air And Unexpect Alarm Should Not Exist without snapshot
    ${enb_state}   ${enb_error_log}=   Run Keyword And Ignore Error    Run Keyword If     '${LTE_WHETHER_IN_GNB}'=='${False}'
    ...                Check ENB On Air And Unexpect Alarm Should Not Exist without snapshot
    [Teardown]      Run Keyword And Ignore Error    COAM Teardown gnb connections

5603158_gNB_enb_SW_Upgrade_loops_with_WebUI_after_cells_enter_energysaving
    [Timeout]   12h
    ${version_splitted}    Split String    ${package_version_1525-CA}    _
    ${tmp_gnb_version}    Replace String Using Regexp    string=${version_splitted[0]}    pattern=SBTS|5G    replace_with=${EMPTY}
    ${qc_id}     Set Variable If    '${tmp_gnb_version}'=='00'     171608
    ...                             '${tmp_gnb_version}'=='25R2'    171607
    Check Rollback is needed before sw upgrade
    Check TMO Gnb Ready And All Cell On Air
    CSV4ALL_PARAMS.Set_Target_Source_SW_Build
    Set To Dictionary    ${GNB}    source_sw    ${SOURCE_SW}
    Set To Dictionary    ${GNB}    target_sw    ${TARGET_SW}
    log to console    GNB info is: ${GNB}
    #power_save_mode_on_source_build
    ${cell_list}    ${lbpsCellList_length}    ${lbpsCellPeriodList_length}    Get The Cell List What Will Be Enter Energy Saving Mode
    Update Related Parameters For Exit Energy Saving    cell_list=${cell_list}
    ...                                                 reportAmountCA_value=r2
    ...                                                 qRxLevMin_value=-60
    ...                                                 actBadUplinkRadioRedirect_vlaue=highUlBlerBased
    ...                                                 ulBlerThresholdRedirectData=40
    ...                                                 ulBlerThresholdRedirectVoNR=20
    Check Cell energySavingState    cell_list=${cell_list}    whether_check_energy_saving=${False}
    ${hour}    ${minute}    Get The Time For Energy Saving
    Update Related Parameters For Energy Saving    Duration=360
    ...                                            Hour=${hour}
    ...                                            Minute=${minute}
    ...                                            lbpsCellList_num=${lbpsCellList_length}
    ...                                            lbpsCellPeriodList_num=${lbpsCellPeriodList_length}
    IF    '${tl_prefix}'=='T073' or '${tl_prefix}'=='T813'
        Update windowDuration For AVHA Power State
    END
    Wait Until Keyword Succeeds    55 min    60 sec    Check Cell energySavingState    cell_list=${cell_list}
    IF    '${tl_prefix}'=='T073' or '${tl_prefix}'=='T813'
        Check RU Should Be SLEEP
    END
    Set Test Variable    ${recover_hour}    ${hour}
    Set Test Variable    ${recover_minute}    ${minute}
    Set Test Variable    ${recover_lbpsCellList_num}    ${lbpsCellList_length}
    Set Test Variable    ${recover_lbpsCellPeriodList_num}    ${lbpsCellPeriodList_length}
    #perform upgrade
    CSV4ALL.e2e_tl_upgrade_test
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODES}
    ...    iterations_per_node=${ITERATION_SW_UPGRADE_ROLLBACK}
    ...    report=${False}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${qc_id}
    ...    qc_project=${QC_PROJECT}
    ...    customers_list=${CUSTOMERS}
    ...    stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    #power_save_mode_offtarget_build
    ${hour}    ${minute}    Get The Time For Energy Saving
    Update Related Parameters For Energy Saving    Duration=80
    ...                                            Hour=${hour}
    ...                                            Minute=${minute}
    ...                                            lbpsCellList_num=${lbpsCellList_length}
    ...                                            lbpsCellPeriodList_num=${lbpsCellPeriodList_length}
    Wait Until Keyword Succeeds    55 min    60 sec    Check Cell energySavingState    cell_list=${cell_list}
    IF    '${tl_prefix}'=='T073' or '${tl_prefix}'=='T813'
        Check RU Should Be SLEEP
    ELSE
    #parameter change didn't trigger cell exit energysaving for AVHA which is EDSM
        Sleep  30sec
        Update Related Parameters For Exit Energy Saving    cell_list=${cell_list}
        ...                                             actBadUplinkRadioRedirect_vlaue=voNrRimAndHubOrUnf_dataHubOrUnf

        Wait Until Keyword Succeeds    55 min    15 sec    Check Cell energySavingState    cell_list=${cell_list}
        ...                                                whether_check_energy_saving=${False}
    END
    #perform rollback
    Set To Dictionary    ${GNB}    source_sw    ${TARGET_SW}
    Set To Dictionary    ${GNB}    target_sw    ${SOURCE_SW}
    CSV4ALL.e2e_tl_rollback_test
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODES}
    ...    iterations_per_node=${ITERATION_SW_UPGRADE_ROLLBACK}
    ...    customers_list=${CUSTOMERS}
    ...    stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    #power_save_mode_on_off_source_build
    Update Related Parameters For Energy Saving    Duration=10
    ...                                            Hour=${recover_hour}
    ...                                            Minute=${recover_minute}
    ...                                            lbpsCellList_num=${lbpsCellList_length}
    ...                                            lbpsCellPeriodList_num=${lbpsCellPeriodList_length}
    Check TMO Gnb Ready And All Cell On Air

5603154_E2E_TL_Site_Reset_without_HWF_with_OAM_KPI_on_LTE
    [Timeout]   8h
    ${version_splitted}    Split String    ${package_version_1525-CA}    _
    ${tmp_gnb_version}    Replace String Using Regexp    string=${version_splitted[0]}    pattern=SBTS|5G    replace_with=${EMPTY}
     ${qc_id}     Set Variable    136398
#    Check ENB Rollback is needed before sw upgrade
#    Check TMO Gnb Ready And All Cell On Air
#    Verify All Enbs Cell On Air
#    CSV4ALL_PARAMS.Set_Target_Source_SW_Build
    log to console     ${ENB}
    CSV4ALL.e2e_tl_site_reset_without_hwf_with_oam_kpi
    ...    nodes_details=${NODES_ENB}
    ...    test_nodes_details=${NODES_ENB}
    ...    iterations_per_node=${ITERATION_SITE_RESET}
    ...    report=${REPORT}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${qc_id}
    ...    qc_project=${QC_PROJECT}
    ...    customers_list=${CUSTOMERS}
    ...    stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...    calculate_kpi=${CALCULATE_KPI}
    ...    swconfig_modification=${False}

5603157_gNB_enb_SW_Upgrade_loops_with_WebUI_RFS_after_cells_enter_energysaving_gNB_1st
    Set Test Variable    ${whether_do_lte_first}    ${False}
    gNB_enb_SW_Upgrade_loops_with_WebUI_RFS_Precondition
    CSV4ALL_PARAMS.Set_Target_Source_SW_Build
    CSV4ALL_PARAMS.Set_ENB_Target_Source_SW_Build
    Set To Dictionary    ${GNB}    source_sw    ${SOURCE_SW}
    Set To Dictionary    ${GNB}    target_sw    ${TARGET_SW}
    Set To Dictionary    ${ENB}    source_sw    ${ENB_ACTIVE_SW}
    Set To Dictionary    ${ENB}    target_sw    ${TARGET_SW}
    log to console    GNB info is: ${GNB}
    log to console    GNB info is: ${ENB}
    ${cell_list}    ${lbpsCellList_length}    ${lbpsCellPeriodList_length}    Get The Cell List What Will Be Enter Energy Saving Mode
    Update Related Parameters For Exit Energy Saving    cell_list=${cell_list}
    ...                                                 reportAmountCA_value=r2
    ...                                                 qRxLevMin_value=-60
    ...                                                 actBadUplinkRadioRedirect_vlaue=highUlBlerBased
    ...                                                 ulBlerThresholdRedirectData=40
    ...                                                 ulBlerThresholdRedirectVoNR=20
    Check Cell energySavingState    cell_list=${cell_list}    whether_check_energy_saving=${False}
    ${hour}    ${minute}    Get The Time For Energy Saving
    Update Related Parameters For Energy Saving    Duration=360
    ...                                            Hour=${hour}
    ...                                            Minute=${minute}
    ...                                            lbpsCellList_num=${lbpsCellList_length}
    ...                                            lbpsCellPeriodList_num=${lbpsCellPeriodList_length}
    Wait Until Keyword Succeeds    60 min    60 sec    Check Cell energySavingState    cell_list=${cell_list}
    #perform upgrade gnb enb
    CSV4ALL.e2e_tl_upgrade_test
    ...    nodes_details=${UPGRADE_NODES}
    ...    test_nodes_details=${UPGRADE_NODES_GNB_FIRST}
    ...    iterations_per_node=${ITERATION_SW_UPGRADE_ROLLBACK}
    ...    report=${REPORT}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${QC_ID_TEMP}
    ...    qc_project=${QC_PROJECT}
    ...    customers_list=${CUSTOMERS}
    ...    stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ${hour}    ${minute}    Get The Time For Energy Saving
    Update Related Parameters For Energy Saving    Duration=80
    ...                                            Hour=${hour}
    ...                                            Minute=${minute}
    ...                                            lbpsCellList_num=${lbpsCellList_length}
    ...                                            lbpsCellPeriodList_num=${lbpsCellPeriodList_length}
    Wait Until Keyword Succeeds    60 min    60 sec    Check Cell energySavingState    cell_list=${cell_list}
    Sleep  30sec
    Update Related Parameters For Exit Energy Saving    cell_list=${cell_list}
    ...                                                 actBadUplinkRadioRedirect_vlaue=voNrRimAndHubOrUnf_dataHubOrUnf
    Wait Until Keyword Succeeds    60 min    15 sec    Check Cell energySavingState    cell_list=${cell_list}
    ...                                                                                whether_check_energy_saving=${False}
    Check TMO Gnb Ready And All Cell On Air
    #perform rollback
    Set To Dictionary    ${GNB}    source_sw    ${TARGET_SW}
    Set To Dictionary    ${GNB}    target_sw    ${SOURCE_SW}
    Set To Dictionary    ${ENB}    source_sw    ${TARGET_SW}
    Set To Dictionary    ${ENB}    target_sw    ${ENB_ACTIVE_SW}
    log to console    GNB info is: ${GNB}
    log to console    GNB info is: ${ENB}
    CSV4ALL.e2e_tl_rollback_test
    ...    nodes_details=${UPGRADE_NODES}
    ...    test_nodes_details=${UPGRADE_NODES_GNB_FIRST}
    ...    iterations_per_node=${ITERATION_SW_UPGRADE_ROLLBACK}
    ...    customers_list=${CUSTOMERS}
    ...    stop_test_after_fail=${STOP_TEST_AFTER_FAIL}

5603157_gNB_enb_SW_Upgrade_loops_with_WebUI_RFS_after_cells_enter_energysaving_LTE_1st
    Set Test Variable    ${whether_do_lte_first}    ${True}
    gNB_enb_SW_Upgrade_loops_with_WebUI_RFS_Precondition
    CSV4ALL_PARAMS.Set_Target_Source_SW_Build
    CSV4ALL_PARAMS.Set_ENB_Target_Source_SW_Build
    Set To Dictionary    ${GNB}    source_sw    ${SOURCE_SW}
    Set To Dictionary    ${GNB}    target_sw    ${TARGET_SW}
    Set To Dictionary    ${ENB}    source_sw    ${ENB_ACTIVE_SW}
    Set To Dictionary    ${ENB}    target_sw    ${TARGET_SW}
    log to console    GNB info is: ${GNB}
    log to console    GNB info is: ${ENB}
    ${cell_list}    ${lbpsCellList_length}    ${lbpsCellPeriodList_length}    Get The Cell List What Will Be Enter Energy Saving Mode
    Update Related Parameters For Exit Energy Saving    cell_list=${cell_list}
    ...                                                 reportAmountCA_value=r2
    ...                                                 qRxLevMin_value=-60
    ...                                                 actBadUplinkRadioRedirect_vlaue=highUlBlerBased
    ...                                                 ulBlerThresholdRedirectData=40
    ...                                                 ulBlerThresholdRedirectVoNR=20
    Check Cell energySavingState    cell_list=${cell_list}    whether_check_energy_saving=${False}
    ${hour}    ${minute}    Get The Time For Energy Saving
    Update Related Parameters For Energy Saving    Duration=360
    ...                                            Hour=${hour}
    ...                                            Minute=${minute}
    ...                                            lbpsCellList_num=${lbpsCellList_length}
    ...                                            lbpsCellPeriodList_num=${lbpsCellPeriodList_length}
    Wait Until Keyword Succeeds    60 min    60 sec    Check Cell energySavingState    cell_list=${cell_list}
    #perform upgrade gnb enb
    CSV4ALL.e2e_tl_upgrade_test
    ...    nodes_details=${UPGRADE_NODES}
    ...    test_nodes_details=${UPGRADE_NODES_ENB_FIRST}
    ...    iterations_per_node=${ITERATION_SW_UPGRADE_ROLLBACK}
    ...    report=${REPORT}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${QC_ID_TEMP}
    ...    qc_project=${QC_PROJECT}
    ...    customers_list=${CUSTOMERS}
    ...    stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ${hour}    ${minute}    Get The Time For Energy Saving
    Update Related Parameters For Energy Saving    Duration=80
    ...                                            Hour=${hour}
    ...                                            Minute=${minute}
    ...                                            lbpsCellList_num=${lbpsCellList_length}
    ...                                            lbpsCellPeriodList_num=${lbpsCellPeriodList_length}
    Wait Until Keyword Succeeds    60 min    60 sec    Check Cell energySavingState    cell_list=${cell_list}
    Sleep  30sec
    Update Related Parameters For Exit Energy Saving    cell_list=${cell_list}
    Wait Until Keyword Succeeds    60 min    15 sec    Check Cell energySavingState    cell_list=${cell_list}
    ...                                                                                whether_check_energy_saving=${False}
    Check TMO Gnb Ready And All Cell On Air
    #perform rollback
    Set To Dictionary    ${GNB}    source_sw    ${TARGET_SW}
    Set To Dictionary    ${GNB}    target_sw    ${SOURCE_SW}
    Set To Dictionary    ${ENB}    source_sw    ${TARGET_SW}
    Set To Dictionary    ${ENB}    target_sw    ${ENB_ACTIVE_SW}
    log to console    GNB info is: ${GNB}
    log to console    GNB info is: ${ENB}
    CSV4ALL.e2e_tl_rollback_test
    ...    nodes_details=${UPGRADE_NODES}
    ...    test_nodes_details=${UPGRADE_NODES_ENB_FIRST}
    ...    iterations_per_node=${ITERATION_SW_UPGRADE_ROLLBACK}
    ...    customers_list=${CUSTOMERS}
    ...    stop_test_after_fail=${STOP_TEST_AFTER_FAIL}

#keywords_common
CSV4ALL_PARAMS.Set_Target_Source_SW_Build
    [Arguments]    ${connection}=GNB_OAM     ${gnb_index}=${0}
    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
	${gnb_current_version}    coam.get_sw_version    timeout=60    connection=${connection}
    ${new_sw_version}   Evaluate    "_".join(["SBTS00", "${gnb_current_version.split("_", 1)[1]}"])
    ${is_trunk}    Run Keyword And Return Status    Should Contain Any    ${gnb_current_version}    9999    9990
    ${gnb_current_version}    Set Variable If    ${is_trunk}    ${new_sw_version}    ${gnb_current_version}
	Set Suite Variable    ${SOURCE_SW}         ${gnb_current_version}
    Set Suite Variable    ${TARGET_SW}         ${package_version_1525-CA}
   [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}


CSV4ALL_PARAMS.SiteReset_Delta_Update
    [Documentation]    Author: stella.lin@nokia-sbell.com
    [Arguments]    ${totalDelayFromSHM_value}=200    ${connection}=GNB_OAM    ${timeout}=600
    ${cur_totalDelayFromSHM_value}    Get totalDelayFromSHM parameter in Gnb
    ${cur_totalDelayFromSHM_value_type}    Evaluate    type(${cur_totalDelayFromSHM_value}).__name__
    ${convert_cur_totalDelayFromSHM_value}    Create List    ${cur_totalDelayFromSHM_value}
    ${cur_totalDelayFromSHM_value_list}    Set Variable If    'list' in '${cur_totalDelayFromSHM_value_type}'
    ...    ${cur_totalDelayFromSHM_value}    ${convert_cur_totalDelayFromSHM_value}
    ${value_length}    Get Length    ${cur_totalDelayFromSHM_value}
    ${modify_totalDelayFromSHM}    Set Variable If
    ...    ${value_length}==${0}    ${totalDelayFromSHM_value}
    ...    ${value_length}!=${0} and '${cur_totalDelayFromSHM_value[0]}'=='${totalDelayFromSHM_value}'    210
    ...    ${totalDelayFromSHM_value}
    ${param}    Create Dictionary    dist_name=${gnb_dist_name}
    ...    parameter=totalDelayFromSHM    value=${modify_totalDelayFromSHM}
    ${params_for_update}    Evaluate    [${param}]
    Wait until keyword succeeds    2min    20 sec    Connect to gnb coam via ssl    connection=${connection}
    ${params_delta}    coam_parameter.Create Update Parameters Delta     parameters=${params_for_update}
    ...    connection=${connection}    timeout=${timeout}
    log    ${params_delta}
    log to console      update delta is :${params_delta['updated']}
    [Return]    ${params_delta['updated']}
    [Teardown]    run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

CSV4ALL_PARAMS.Lte_Rat_Reset_Delta_Update
    [Documentation]    Author: stella.lin@nokia-sbell.com
    [Arguments]    ${actTransportSeparationLte}=true     ${connection}=GNB_OAM     ${timeout}=600
    ${cur_actTransportSeparationLte}    Get actTransportSeparationLte parameters in LTE
    ${modify_actTransportSeparationLte}     set variable if   '${cur_actTransportSeparationLte}'=='${actTransportSeparationLte}'
    ...    fasle    true
    @{params_for_update}   create list
    ${param}    Create Dictionary    dist_name=${LTE_dist_name}    parameter=actTransportSeparationLte
    ...    value=${modify_actTransportSeparationLte}
    Append To List    ${params_for_update}    ${param}
    Wait until keyword succeeds    2min    20 sec    Connect to gnb coam via ssl    connection=${connection}
    ${params_delta}    coam_parameter.Create Update Parameters Delta     parameters=${params_for_update}
    ...    connection=${connection}    timeout=${timeout}
    log    ${params_delta}
    log to console      update delta is :${params_delta['updated']}
    [Return]    ${params_delta['updated']}
    [Teardown]    run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

CSV4ALL_PARAMS.NR_Rat_Reset_Delta_Update
    [Documentation]    Author: stella.lin@nokia-sbell.com
    [Arguments]    ${actBeamControlImprovement1}=false    ${connection}=GNB_OAM     ${timeout}=600
    ${cur_actBeamControlImprovement1}    Get actBeamControlImprovement1 parameters in Gnb
    ${modify_actBeamControlImprovement1}     set variable if   '${cur_actBeamControlImprovement1}'=='${actBeamControlImprovement1}'
    ...                              true    ${actBeamControlImprovement1}
    @{params_for_update}   create list
    ${param}    Create Dictionary    dist_name=${gnb_dist_name}    parameter=actBeamControlImprovement1    value=${modify_actBeamControlImprovement1}
    Append To List    ${params_for_update}    ${param}
    Wait until keyword succeeds    2min    20 sec    Connect to gnb coam via ssl    connection=${connection}
    ${params_delta}    coam_parameter.Create Update Parameters Delta     parameters=${params_for_update}
    ...    connection=${connection}    timeout=${timeout}
    log    ${params_delta}
    log to console      update delta is :${params_delta['updated']}
    [Return]    ${params_delta['updated']}
    [Teardown]    run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

CSV4ALL_PARAMS.Online_Modify_Delta_Update
    [Documentation]    Author: stella.lin@nokia-sbell.com
     [Arguments]    ${cell_idx}=${PCELL_INDEX}    ${exp_status}=notBarred    ${connection}=GNB_OAM    ${gnb_index}=0    ${timeout}=${600}
    ${dist_name}    set variable    MRBTS-${tl.gnbs[${gnb_index}].instance_id}/NRBTS-${tl.gnbs[${gnb_index}].global_bts_id}/NRCELL-${cell_idx}
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${cell_status}    coam_parameter.get_single_value_from_scf_file    parameter=cellBarred    dist_name=${dist_name}
    ...                                                               connection=${connection}      timeout=${timeout}
    ${exp_status}    Set Variable If    '${cell_status}'=='barred'    notBarred     barred
    ${params}    create dictionary    dist_name=${dist_name}    parameter=cellBarred    value=${exp_status}
    @{params_for_update}    create list
    Append to list      ${params_for_update}     ${params}
    ${params_delta}    coam_parameter.Create Update Parameters Delta     parameters=${params_for_update}
    ...    connection=${connection}    timeout=${timeout}
    log    ${params_delta}
    log to console      update delta is :${params_delta['updated']}
    [Return]    ${params_delta['updated']}
    [Teardown]    run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

CSV4ALL_PARAMS.GSM_Reset_Delta_Update
    [Documentation]    Author: stella.lin@nokia-sbell.com
    [Arguments]    ${perTrxPower}=393     ${connection}=GNB_OAM     ${timeout}=600
    ${cur_perTrxPower}    Get perTrxPower parameters in GSM cell
    ${modify_perTrxPower}     set variable if   '${cur_perTrxPower}'=='${perTrxPower}'      391      ${perTrxPower}
    @{params_for_update}   create list
    ${param}    Create Dictionary    dist_name=${gsm_dist_name}    parameter=perTrxPower    value=${modify_perTrxPower}
    Append To List    ${params_for_update}    ${param}
    Wait until keyword succeeds    2min    20 sec    Connect to gnb coam via ssl    connection=${connection}
    ${params_delta}    coam_parameter.Create Update Parameters Delta     parameters=${params_for_update}
    ...    connection=${connection}    timeout=${timeout}
    log    ${params_delta}
    log to console      update delta is :${params_delta['updated']}
    [Return]    ${params_delta['updated']}
    [Teardown]    run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

CSV4ALL_PARAMS.Set_ENB_Target_Source_SW_Build
    [Documentation]    author: stella.lin@nokia-sbell.com
    [Arguments]    ${enb_index}=${0}    ${enb_connection}=enblte   ${timeout}=180
    wait until keyword succeeds     5 min   10 sec     Connect to eNB via ssl    connection=${enb_connection}
    ...    enb_index=${enb_index}
    ${BTS_SW_Info}=   coam.get_software_info    timeout=${timeout}    connection=${enb_connection}
    ${active_SW}=     Get from dictionary    ${BTS_SW_Info}    Active SW version
    ${passive_SW}=    Get from dictionary    ${BTS_SW_Info}    Passive SW version
    ${new_active_sw_version}   Evaluate    "_".join(["SBTS00", "${active_SW.split("_", 1)[1]}"])
    ${new_passive_sw_version}   Evaluate    "_".join(["SBTS00", "${passive_SW.split("_", 1)[1]}"])
    ${is_trunk}    Run Keyword And Return Status    Should Contain Any    ${active_SW}    9999    9990
    ${new_active_SW}    Set Variable If    ${is_trunk}    ${new_active_sw_version}    ${active_SW}
    ${new_passive_SW}    Set Variable If    ${is_trunk}    ${new_passive_sw_version}    ${passive_SW}
    Log To Console    Active partition SW: ${new_active_SW}
    Log To Console    Passive partition SW: ${new_passive_SW}\n
    Set Test Variable    ${ENB_ACTIVE_SW}    ${new_active_SW}
    Set Test Variable    ${ENB_PASSIVE_SW}    ${new_passive_SW}
    [Teardown]    run keyword and ignore error    Enblte close down    connection=${enb_connection}

CSV4ALL_PARAMS.Set_HWF_Target_Source_SW_Build
    [Arguments]    ${gnb_index}=${0}    ${connection}=GNB_OAM${gnb_index}    ${timeout}=180
    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl    gnb_index=${gnb_index}    connection=${connection}
    ${BTS_SW_Info}=   coam.get_software_info    timeout=${timeout}    connection=${connection}
    ${active_SW}=     Get from dictionary    ${BTS_SW_Info}    Active SW version
    ${passive_SW}=    Get from dictionary    ${BTS_SW_Info}    Passive SW version
    ${new_active_sw_version}   Evaluate    "_".join(["SBTS00", "${active_SW.split("_", 1)[1]}"])
    ${new_passive_sw_version}   Evaluate    "_".join(["SBTS00", "${passive_SW.split("_", 1)[1]}"])
    ${is_trunk}    Run Keyword And Return Status    Should Contain Any    ${gnb_current_version}    9999    9990
    ${new_active_SW}    Set Variable If    ${is_trunk}    ${new_active_sw_version}    ${active_SW}
    ${new_passive_SW}    Set Variable If    ${is_trunk}    ${new_passive_sw_version}    ${passive_SW}
    Log To Console    Active partition SW: ${new_active_SW}
    Log To Console    Passive partition SW: ${new_passive_SW}\n
    Set Test Variable    ${HWF_ACTIVE_SW}    ${new_active_SW}
    Set Test Variable    ${HWF_PASSIVE_SW}    ${new_passive_SW}
   [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}


5603159_TOL_case_OAM_snapshot_collection_LTE
    [Arguments]    ${ru_index}=1    ${enb_index}=${0}    ${enb_connection}=enb_${enb_index}    ${timeout}=180
    log    ${timeout}
    Wait Until Keyword Succeeds    1 min    5 sec    Connect to eNB via ssl    enb_index=${enb_index}    connection=${enb_connection}
    ${active_version}    coam.get_sw_version    timeout=60    connection=${enb_connection}
    ${version_splitted}    Split String    ${active_version}    _
	${tmp_program_version}    Replace String Using Regexp    string=${version_splitted[0]}    pattern=SBTS|5G    replace_with=${EMPTY}
	${is_trunk}    Run Keyword And Return Status    Should Contain Any    ${active_version}    _9999_    _9990_
	${stream_version}    Set Variable If    ${is_trunk}    master    ${tmp_program_version}
    ${ENB_MRBTS_ID}    Set Variable    ${tl.enbs[${enb_index}].instance_id}
    ${prefix_name}    Set Variable If    '${stream_version}'=='25R1'    BTS    BTS${ENB_MRBTS_ID}
    Connect to eNB    alias=ENB_ASIK_Master    enb_index=${enb_index}
    Connect to RU With Allocated IP   ru_index=${ru_index}   ru_alias=RU_${ru_index}   asik_alias=ENB_ASIK_Master
    ...    connection=${enb_connection}
    ...    ru_username=${tl.gnbs[0].dus[0].rus[6].default_ssh_connection_details.username}
    ...    ru_password=${tl.gnbs[0].dus[0].rus[6].default_ssh_connection_details.password}
    Verify RFSW Log Include In Snapshot    ru_index=${ru_index}    ru_alias=RU_${ru_index}    prefix_name=${prefix_name}
    ...    connection=${enb_connection}
    [Teardown]    Run keywords
    ...     run keyword and ignore error    Enblte close down    connection=${enb_connection}    AND
    ...    Run Keyword And Ignore Error    csn.Disconnect    connection=RU_${ru_index}    AND
    ...    Run Keyword And Ignore Error    csn.disconnect    connection=ENB_ASIK_Master

Request Scf By Scout For LTE
    [Timeout]    8 minutes
    [Arguments]    ${no_ute}=${True}
    ${no_ute_env}    run keyword and return status    Environment Variable Should Not Be Set    CM_EXECUTION_ID
    ${testline}   run keyword if    ${no_ute_env}    set variable     ${testline_name}
    ...           ELSE    String.Fetch From Right    string=${CONFIGURATION}    marker=.
    ${specail}    run keyword and return status    Dictionary Should Contain Key    ${TL_IN_SCOUT}    ${testline}
    ${testline}    set variable if    ${specail}    ${TL_IN_SCOUT}[${testline}]    ${testline}_SRAN
#    ${scout_tl}    Get Variable Value  ${SCOUT_TL_NAME}    ${testline}
    ${success}    run keyword and return status    __Request Scf By Scout    scout_tl=${testline}    no_ute=${no_ute_env}
    ${tl_on_scout}    run keyword and return status    taf.sw.scout.setup_scout    ${testline}
    return from keyword if    '${tl_on_scout}'=='False'
    ${scf_id}    Wait Until Keyword Succeeds    3x    5 sec    taf.sw.scout.request_scf
    ...    use_scout_internal_id=${no_ute}    timeout=${90}
    run keyword if    ${no_ute}    set tags   ute:id:${scf_id}
    [Teardown]    run keyword if    ${tl_on_scout}    taf.sw.scout.teardown_scout_api


5603159_robot_common_operations.Common Case Teardown
    [Documentation]    Common keyword to set in Case Teardown for tribe level common operations.
    ...                Author: Civen Chen
    ...                maintainer: Civen Chen
    [Timeout]          20 min
    run keyword and ignore error    Request Scf By Scout For LTE
    robot_common_operations.Common Case Teardown
#    run keyword and ignore error    AlarmWatchdog.teardown_watchdog
#    run keyword and ignore error    Request Scf By Scout For LTE
#    run keyword and ignore error    Stop to Collect and Save RU Logs
#    Check Alarm and stop robot testing when unexpected alarm raised

Compared_OAM_KPI_Results
    [Arguments]    ${kpi_ids}=00015.00016
    ...            ${gnb_index}=${0}
    ...            ${connection}=GNB_OAM${gnb_index}
    ...            ${diff_threshold}=10
    ${kpi_id_list}    Evaluate    [id.strip() for id in ${kpi_ids.split(',')}]
    ${bts_name}    ${sw_version}    Wait Until Keyword Succeeds    3x    30s
    ...     Get BtsName and SwVersion    gnb_id=${gnb_index}    connection=${connection}
    ${oam_kpi_log}    get_oam_kpi_from_debug_log    debug_log_path=${DEBUG FILE}
    ...                                             kpi_id_list=${kpi_id_list}
    ...                                             kpi_restore_path=/home/ute/OAM_KPI_Report/${TEST NAME}/${sw_version}
    Run Keyword If   '${oam_kpi_log}'!='${None}'    compared_oam_kpi    oam_kpi_path=${oam_kpi_log}
    ...    diff_threshold=${diff_threshold}
    log to console   start to upload to remote server
    Run Keyword And Ignore Error     Compass.Upload Result To Remote Server    restore_path=/home/ute/OAM_KPI_Report
    ...     server_path=/home/hz4sg6/shared/05_OAM_KPI_Report/${TEST NAME}/${tl_prefix}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}