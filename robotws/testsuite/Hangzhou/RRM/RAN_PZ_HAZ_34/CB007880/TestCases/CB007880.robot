*** Settings ***
Documentation    CB007880 NR uplink time difference of arrival positioning for Non-BF radios
Resource    ../Resources/CB007880_keywords.robot
Force Tags        5G_SISO
Suite Setup        Suite preparation
Suite Teardown     run keyword and ignore error    Suite teardown


*** Test Cases ***
CB007880_A_TC03_B1_UL-TDOA_Positioning_service_for_one_Supercell_with_RU-ACCESS_different_srs_configuration
    [Documentation]    Ding Binmei
    ...    This case is test for super cell.
    ...    Detail steps, please refers to documentation in keyword:
    ...    Common case steps for UL TDOA positioning service for Supercell or normal Cell with RU-ACCESS
    [Setup]    Test case setup
    Common case steps for UL TDOA positioning service for Supercell or normal Cell with RU-ACCESS
    ...    cell_id_for_attach=401    exp_TRP_num=6    exp_TRP_num_for_measurement_report=6
    [Teardown]    Run Keyword And Ignore Error    Test case teardown

CB007880_A_TC13_B2_UL-TDOA_Positioning_service_for_one_normal_Cell_with_RU-ACCESS_different_srs_configuration
    [Documentation]    Ding Binmei
    ...    This case is test for normal cell.
    ...    Detail steps, please refers to documentation in keyword:
    ...    Common case steps for UL TDOA positioning service for Supercell or normal Cell with RU-ACCESS
    [Setup]    CB007880_A_TC13_B2_normal_cell_case_setup    cell_id=401
    Common case steps for UL TDOA positioning service for Supercell or normal Cell with RU-ACCESS
    ...    cell_id_for_attach=401    exp_TRP_num=4    exp_TRP_num_for_measurement_report=4
    [Teardown]    Run Keyword And Ignore Error    Test case teardown

CB007880_A_TC21_B9_Successful_UL-TDOA_Positioning_service_with_RU-ACCESS_Measurement_session_stop_Measurement_Abort_by_LMF
    [Documentation]    Qi Xin
    ...    S1 UE attach and trigger MT-LR procedure from LMF
    ...    S2 Verify log and check UE attach and LCS trigger procedures are as expected.
    ...    S3 Trigger LMF measurement abort from LMF.
    ...    S4 Verify log and check LMF measurement abort procedures are as expected.

    [Setup]    CB007880_A_TC13_B2_normal_cell_case_setup    cell_id=401
    UL TDOA positioning service for one normal Cell with RU-ACCESS different srs configuration CB007880_A_TC21_B9
    ...    cell_id_for_attach=401    exp_TRP_num=4    exp_TRP_num_for_measurement_report=4
    ${f1ap_log_path}    F1AP and BIP log capture started then trigger MT-LR abort procedure from LMF
    ...    tcpdump_log_name=f1ap_attach_and_trigger_positioning_procedures
    Verify LMF measurement abort is successful between LMF and GNB    log_file_path=${f1ap_log_path}
    [Teardown]    Run Keyword And Ignore Error    Test case teardown

*** Keywords ***
Test case setup
    [Documentation]    Author: Ding Binmei
    ...    Common case setup, and online modify parameters if needed
    [Arguments]    ${dict_params_to_modify}=${None}    ${timeout_online_modify}=${TIMER_FOR_MODIFY_VIA_API}
    Common case setup    NSA_SA=${NSA_SA}    is_scf_backup_needed=${False}
    run keyword if    ${dict_params_to_modify}!=${None}
    ...    Run keywords    nidd_modify.online_modify_nidd_parameters_via_restapi    params_modify_dict=${dict_params_to_modify}
    ...        timeout=${timeout_online_modify}    AND
    ...        Wait until cluster ready based on NSA_SA type   NSA_SA=${NSA_SA}    is_need_to_setup_gnb_connection=${False}
    # download SCF file to log path for mannual rerun or mannual debug issue
    run keyword and ignore error    Download SCF file to log path

CB007880_A_TC13_B2_normal_cell_case_setup
    [Documentation]    Author: Ding Binmei
    ...    Update from super cell to normal cell, then do common case setup
    ...    ${cell_id}: cell id to be updated from super cell to normal cell
    [Arguments]    ${cell_id}
    Log to console    Update from super cell to normal cell: ${cell_id}
    Connect to gnb coam via ssl
    ${dict_params_to_modify}    param_modify_lib_7880.get_params_to_update_from_super_cell_to_normal_cell    cell_id=${cell_id}
    Test case setup    dict_params_to_modify=${dict_params_to_modify}

Test case teardown
    [Documentation]    Author: Ding Binmei
    [Arguments]    ${is_scf_restore}=${False}    ${scf_file_path_for_restore}=${None}    ${is_onair_check}=${False}
    ...    ${detach_ue}=${True}    ${restapi_restore_nidd}=${None}

    Common case teardown    detach_ue=${detach_ue}
    ...    is_scf_restore=${is_scf_restore}    scf_file_path_for_restore=${scf_file_path_for_restore}
    ...    restapi_restore_nidd=${restapi_restore_nidd}
    ...    is_btslog_required=${False}    is_onair_check=${is_onair_check}    onair_timeout=${TIMER_FOR_CELL_ON_AIR}    NSA_SA=${NSA_SA}
