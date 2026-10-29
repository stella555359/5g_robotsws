*** Settings ***
Documentation    This is keyword file used for feature CB010411.

Resource     CB010411_variables.robot
Variables    commissionings/HGZ/${testline_name}/__init_10411__.py
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/Cloud_VRAN40/common_setup_teardown.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/CA/Resources/CA_Common_New/ca_specifical_step.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/CA/Resources/CA_keywords.robot
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/Cloud_VRAN40/python/cloud_online_modify.py
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/Cloud_VRAN40/python/cloud_nrrel_operations.py
Library      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/CA/TestData/Parameters_modify_lib.py    WITH NAME    param_modify_lib

*** Keywords ***
Import NIDD variables for 10411
    [Documentation]  Author: Dandan Fang
    ...    import common variable for CB010411
    #This parameter is open by taf to indicate the absolute path for commission folder
    get variable value  ${commissionings_path}
    ${is_tl_delta_file_exists}    Run keyword and return status    File should exist    ${commissionings_path}/HGZ/${testline_name}/TLDelta.py
    Run keyword if    ${is_tl_delta_file_exists}
    ...    Import variables  ${commissionings_path}/HGZ/${testline_name}/TLDelta.py
    import variables    ${CURDIR}/../TestData/NIDD_modify_scf.py
    ${DL_TPUT_IPERF}    run keyword if      'sdx80' in @{tl.ues[0].capabilities}
    ...    set variable    ${DL_TPUT_IPERF_6CC}
    ...    ELSE    set variable    ${DL_TPUT_IPERF_4CC}
    Set suite variable     ${DL_TPUT_IPERF}

10411 Suite preparation
    [Documentation]  Author: Dandan Fang
    ...    exp_cc_num_in_use: refers to 3CC/4CC/${None}, if set as 3CC or 4CC will return the input value directly,
    ...        otherwise will judge based on ue type. sdx65: 3CC, sdx70: 4CC, other ue type will default to 3CC
    ...    Added new parameter for ${ca_group_mapping_3cc} and ${ca_group_mapping_4cc}, parameter need to be added based on exp_cc_num_in_use
    ...    ${ca_group_mapping_3cc} equals to ${ca_group_mapping} by default,
    ...    ToDo: ${ca_group_mapping} can be removed when all cases has removed this param
    [Arguments]
    ...    ${ca_group_mapping_4cc}=${F1_F2_T1_T2_4CC_CA_GROUP_COMMON}   ${ca_group_mapping_6cc}=${F1_F2_T1_T2_6CC_CA_GROUP_COMMON}
    ...    ${exp_cc_num_in_use}=${None}
    ...    ${gnb_index}=${0}    ${du_index_list}=@{LIST_DU_INDEX_0}
    ...    ${is_prepare_ue_needed}=${True}    ${detach_request}=${True}    ${ue_index}=${0}

    Decode CA group mapping and set CA Cell variable    is_called_in_suite_level=${True}
    ...    ca_group_mapping_6cc=${ca_group_mapping_6cc}    ca_group_mapping_4cc=${ca_group_mapping_4cc}
    ...    exp_cc_num_in_use=${exp_cc_num_in_use}

    Import NIDD variables for 10411
    ${CU_SCF_TEMPATE_PATH}    catenate  SEPARATOR=   /home/ute/Projects/mmw1_config/${testline_name}/
    ...   GNB_SCF_CU_MMW1_TL${tl.gnbs[${gnb_index}].cu.instance_id}.xml
    &{cu_dict_params_modify}     create dictionary
    ...  param_to_del=${CU_SCF_DELETE}     param_to_upd=${CU_SCF_MODIFY}    param_to_add=${CU_SCF_ADD}

    &{du_dict_params_modify}     create dictionary
    ...  param_to_del=${DU_SCF_DELETE}     param_to_upd=${DU_SCF_MODIFY}    param_to_add=${DU_SCF_ADD}

    ${du_scf_params_modify_list}       create list
    ${du_scf_file_path_list}   create list
    FOR    ${index}    ${du_index}   IN ENUMERATE    @{du_index_list}
          ${DU_SCF_TEMPATE_PATH}    catenate  SEPARATOR=   /home/ute/Projects/mmw1_config/${testline_name}/
    ...   GNB_SCF_DU_MMW1_TL${tl.gnbs[${gnb_index}].dus[${du_index}].instance_id}.xml
          Append to list       ${du_scf_file_path_list}     ${DU_SCF_TEMPATE_PATH}
          Append to list       ${du_scf_params_modify_list}     ${du_dict_params_modify}
    END

    Aic Suite common setup preparation
    ...    cu_dict_params_modify=${cu_dict_params_modify}    cu_scf_file_path=${CU_SCF_TEMPATE_PATH}
    ...    du_scf_params_modify_list=${du_scf_params_modify_list}    du_scf_file_path_list=${du_scf_file_path_list}
    ...    du_index_list=${du_index_list}     gnb_index=${gnb_index}
    ...    is_prepare_ue_needed=${is_prepare_ue_needed}    detach_request=${detach_request}    ue_index=${ue_index}
    ...    pa_values_mapping=${INIT_PA_VALUE}   attenuator_out_ports=${PA_OUT_PORTS}

10411 Case setup
    [Documentation]    Author: Dandan Fang
    ...    Please note only one DU is supported.
    ...    If ca relationship need to be modified, input by ${ca_group_mapping}, NRREL will be updated accordingly.
    ...    If other NIDD parameters need to be modified, input by ${dict_params_to_modify}.
    ...    ${exp_cc_num_in_use}: refers to 3CC/4CC/${None}, if set as 3CC or 4CC will return the input value directly,
    ...        otherwise will judge based on ue type. sdx65: 3CC, sdx70: 4CC, other ue type will default to 3CC
    ...    Added new parameter for ${ca_group_mapping_3cc} and ${ca_group_mapping_4cc}, parameter need to be added based on exp_cc_num_in_use
    ...    ${ca_group_mapping_3cc} equals to ${ca_group_mapping} by default,
    [Arguments]
    ...    ${ca_group_mapping_5cc}=${None}     ${ca_group_mapping_4cc}=${F1_F2_T1_T2_4CC_CA_GROUP_COMMON}
    ...    ${ca_group_mapping_6cc}=${F1_F2_T1_T2_6CC_CA_GROUP_COMMON}    ${exp_cc_num_in_use}=${None}
    ...    ${gnb_index}=${0}   ${du_index}=${0}
    ...    ${pa_values_mapping}=${None}
    ...    ${cu_params_modify_dict_via_api}=&{EMPTY_DICT}     ${du_params_modify_via_api}=&{EMPTY_DICT}
    ...    ${cu_scf_dict_params_modify}=&{EMPTY_DICT}    ${cu_scf_template_path}=${None}
    ...    ${du_scf_dict_params_modify}=&{EMPTY_DICT}    ${du_scf_template_path}=${None}
    ...    ${fail_with_alarms}=${True}    ${allowed_faults_ids}=${None}
    ${du_index_list}    Create list    ${du_index}
    @{du_scf_params_modify_list}    Run keyword if    ${du_scf_dict_params_modify}    Create list    ${du_scf_dict_params_modify}
    ...    ELSE    Create list
    @{du_scf_file_path_list}    Run keyword if    '${du_scf_template_path}'=='${None}'    Create list
    ...    ELSE    Create list    ${du_scf_template_path}
    ${cu_connection}    ${du_connection_list}    common_setup_teardown.Create CU And DU Connections    gnb_index=${gnb_index}
    ...    du_index_list=${du_index_list}
    Decode CA group mapping and set CA Cell variable    is_called_in_suite_level=${True}
    ...    ca_group_mapping_6cc=${ca_group_mapping_6cc}   ca_group_mapping_4cc=${ca_group_mapping_4cc}
    ...    ca_group_mapping_5cc=${ca_group_mapping_5cc}    exp_cc_num_in_use=${exp_cc_num_in_use}
    &{cu_params_nrrel}    param_modify_lib.get_nrrel_params_for_online_update_based_on_ca_group_mapping_no_increasePUSCHPrepTimeULCA
    ...    ca_group_mapping=${CA_GROUP_MAPPING}   bts_type=cu    is_nrrel_id_needed=${False}

    ${pcell_tech}  set variable   ${NR_CELL_ID_MAPPING[${PCELL_ID}]['detail_cells_info']['technology']}
    &{du_params_increasePUSCHPrepTimeULCA}    run keyword if  '${pcell_tech}'=='FDD' and ${SCELL_ID_UL_ADD}
    ...        param_modify_lib.get_nrrel_increasePUSCHPrepTimeULCA    ca_group_mapping=${CA_GROUP_MAPPING}
    ...            connection_alias=${du_connection_list[0]}
    ...    ELSE    Create dictionary
    ${cu_params_modify_combine}    Combine params for online modify    dict_params1=${cu_params_modify_dict_via_api}
    ...    dict_params2=${cu_params_nrrel}
    ${du_params_modify_combine}    Combine params for online modify    dict_params1=${du_params_modify_via_api}
    ...    dict_params2=${du_params_increasePUSCHPrepTimeULCA}
    ${du_params_modify_combine_list}    Run keyword if    ${du_params_modify_via_api} or ${du_params_increasePUSCHPrepTimeULCA}
    ...    Create list    ${du_params_modify_combine}
    ...    ELSE    Create list
    Aic Common case setup
    ...    gnb_index=${gnb_index}   du_index_list=${du_index_list}
    ...    cu_params_modify_dict_via_api=${cu_params_modify_combine}        du_params_modify_via_api_list=${du_params_modify_combine_list}
    ...    cu_scf_dict_params_modify=${cu_scf_dict_params_modify}    cu_scf_file_path=${cu_scf_template_path}
    ...    du_scf_params_modify_list=${du_scf_params_modify_list}    du_scf_file_path_list=${du_scf_file_path_list}
    ...    is_scf_backup_needed=${False}    pa_values_mapping=${pa_values_mapping}
    ...    fail_with_alarms=${fail_with_alarms}    allowed_faults_ids=${allowed_faults_ids}
    Change status for parameter cellBarred on GNB DU    exp_status=notBarred   list_cell_ids=${PCELL_ID}
    ...        gnb_index=${gnb_index}    du_index=${du_index}   connection=${du_connection_list[0]}

Prepare NRREL under specific cell for Cloud
    [Documentation]    Author: Dandan Fang
    ...    Generate and activate parameters for nrrel update based on ca_group_mapping.
    [Arguments]    ${ca_group_mapping}=${F1_F2_T1_T2_6CC_CA_GROUP_COMMON}
    ...        ${gnb_index}=${0}    ${du_index_list}=${LIST_DU_INDEX_0}
    #CU create NRREL
    ${cu_conn}    set variable     OAM_CU${gnb_index}
    &{cu_params_to_modify}    param_modify_lib.get_nrrel_params_for_online_update_based_on_ca_group_mapping_no_increasePUSCHPrepTimeULCA
    ...    ca_group_mapping=${ca_group_mapping}   bts_type=cu
    ${result}    cloud_online_modify.online_modify_for_params_update_with_non_provision_method
    ...    params_to_modify=${cu_params_to_modify}   connection=${cu_conn}  bts_type=cu
    vCU.Teardown vcu connection  connection=${cu_conn}
    vCU.Wait for vcu ready and cells are on air    gnb_index=${gnb_index}    connection=${cu_conn}

    ${pcell_tech}  set variable   ${NR_CELL_ID_MAPPING[${PCELL_ID}]['detail_cells_info']['technology']}
    run keyword if  '${pcell_tech}'=='FDD' and ${SCELL_ID_UL_ADD}
    ...     _update increasePUSCHPrepTimeULCA for 6137 for Cloud DUs    gnb_index=${gnb_index}    du_index_list=${du_index_list}
    ...     ca_group_mapping=${ca_group_mapping}

_update increasePUSCHPrepTimeULCA for 6137 for Cloud DUs
    [Documentation]    Author: Dandan Fang
    ...    Generate and activate parameters for nrrel update based on ca_group_mapping.
    ...    Reason for update the nidd, please refer PR681812
    [Arguments]    ${ca_group_mapping}    ${gnb_index}     ${du_index_list}
    #DU Update increasePUSCHPrepTimeULCA as True for 6137
    FOR    ${index}    ${du_index}    IN ENUMERATE    @{du_index_list}
        Log to console    DU index: ${du_index}
        ${du_conn}    set variable     OAM_gnb${gnb_index}_du${du_index}
        &{du_params_to_modify}    param_modify_lib.get_nrrel_increasePUSCHPrepTimeULCA
        ...    ca_group_mapping=${ca_group_mapping}   connection_alias=${du_conn}
        ${result}    cloud_online_modify.online_modify_for_params_update_with_non_provision_method
        ...    params_to_modify=${du_params_to_modify}   connection=${du_conn}  bts_type=du
        vDU.Teardown vdu connection    connection=${du_conn}
        vDU.Wait for vdu ready and cells are on air    gnb_index=${gnb_index}    du_index=${du_index}
        ...      connection=${du_conn}
    END

CB011178-CR_07_S2 Reset RU for pcell and wait until status are back to normal
    [Documentation]  Author: Ding Binmei
    ${cell_relation_mapping}    cloud_gnb.get_relation_mapping_between_cell_and_others
    ${rmod_id_for_pcell}    Set variable    ${cell_relation_mapping[${PCELL_ID}]['detail_ru_info']['id']}
    Run Keyword And Ignore Error     AlarmWatchdog.add_allow_alarms     fault_id=4675
    vDU.Perform reset RUs    rmods_list=${rmod_id_for_pcell}
    Wait until keyword succeeds    2 min    10 sec    vDU.Verify RU status are as expected    rmods_list=${rmod_id_for_pcell}
    ...    exp_availability_status=not installed    exp_operational_state=disabled
    common_setup_teardown.Aic Close all connection
    common_setup_teardown.Aic Check CU and DUs Onair
    Run Keyword And Ignore Error     AlarmWatchdog.remove_allow_alarms     fault_id=4675
