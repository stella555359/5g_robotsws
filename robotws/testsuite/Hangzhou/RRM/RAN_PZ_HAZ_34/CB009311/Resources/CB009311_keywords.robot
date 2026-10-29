*** Settings ***
Resource     testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB006137/Resources/CB006137_keywords.robot
Resource     CB009311_variables.robot
Variables    commissionings/HGZ/${testline_name}/__init_9311_B__.py

*** Keywords ***
9311 Suite preparation
    [Documentation]  Author: Fang ludan
    [Arguments]    ${swconfig_modify}=${None}
    Set Variables for 9311
    CA Suite preparation    prepare_ue=${True}    NSA_SA=NSA   enb_default_scf_file=${ENB_SCF_DEFAULT_FILE_PATH}
    ...    scf_modify_parameters=${MOD_SCF_WEIGHTOFFR1PSCELL}  pa_values_mapping=${INIT_PA_F1_F2_T1_T2_9311}
    change B1 on enb side     parameters_to_update_via_api=${ENABLE_B1_MEAS}
    Run keyword and continue on failure    Prepare NRREL under specific cell    ca_group_mapping=${T1_F4_2CC_CA_T1_F5_T2_T3_NonCA_GROUP}
    Run keyword and continue on failure    Prepare NRREL under specific cell    ca_group_mapping=${F4_T1_2CC_CA_GROUP}
    Run keyword and continue on failure    Prepare NRREL under specific cell    ca_group_mapping=${T2_T1_NonCA_GROUP}
    Run keyword and continue on failure    Prepare NRREL under specific cell    ca_group_mapping=${T3_T1_NonCA_GROUP}
    Run keyword and continue on failure    Prepare NRREL under specific cell    ca_group_mapping=${F5_T1_NonCA_GROUP}

Set Variables for 9311
    import NIDD variables
    import variables      ${CURDIR}/../TestData/NIDD_modify_scf.py
    Set suite variable    ${PARAMS_TO_ADD}       ${ADD_SCF_DEFAULT}
    ${CELL_list_CA_T1_F4}   Create List    ${1}  ${2}
    ${CELL_list_CA_F4_T1}   Create List    ${2}  ${1}
    ${EXP_UL_CA_F4_T1}      Create List    ${EXP_UL_F20M}   0
    ${EXP_DL_CA_F4_T1}      Create List    ${EXP_DL_F20M}   ${EXP_DL_T60M}
    ${EXP_UL_CA_T1_F4}      Create List    ${EXP_UL_T60M}   0
    ${EXP_DL_CA_T1_F4}      Create List    ${EXP_DL_T60M}   ${EXP_DL_F20M}
    Set suite variable   ${CELL_list_CA_T1_F4}
    Set suite variable   ${CELL_list_CA_F4_T1}
    Set suite variable   ${EXP_UL_CA_F4_T1}
    Set suite variable   ${EXP_DL_CA_F4_T1}
    Set suite variable   ${EXP_UL_CA_T1_F4}
    Set suite variable   ${EXP_DL_CA_T1_F4}

change B1 on enb side
     [Arguments]     ${parameters_to_update_via_api}
     Connect to gnb coam via ssl
    ...    connection=enblte_0
    ...    bts_host=${tl.enbs[${0}].airscale.common_units[0].lmp_connection.addr}
     ${update_status}    COAM Update several parameters via rest api    connection=enblte_0
     ...     parameters_to_update_via_api=${parameters_to_update_via_api}    timeout=6 min
     Should be true    '${update_status}'=='PASS'
     [Teardown]     run keyword and ignore error     coam.teardown    connection=enblte_0

Restore B1 on enb side
     [Arguments]     ${parameters_to_update_via_api}
     Connect to gnb coam via ssl
    ...    connection=enblte_0
    ...    bts_host=${tl.enbs[${0}].airscale.common_units[0].lmp_connection.addr}
     ${update_status}    COAM Update several parameters via rest api    connection=enblte_0
     ...     parameters_to_update_via_api=${parameters_to_update_via_api}    timeout=6 min
     Should be true    '${update_status}'=='PASS'
     [Teardown]     run keyword and ignore error     coam.teardown    connection=enblte_0

9311 Suite teardown
    change B1 on enb side       parameters_to_update_via_api=${DISABLE_B1_MEAS}
    CA Suite teardown    is_log_required=${False}
    run keyword and ignore error    Close all connection
    run keyword and ignore error    coam teardown gnb connections

Add B1 measurement cell
    [Documentation]    Author: fang ludan
    [Arguments]     ${timeout_restapi}=${TIMER_FOR_MODIFY_VIA_API}    ${connection}=GNB_OAM
    ${result}    nidd_modify.online_modify_nidd_parameters_via_restapi    params_modify_dict=${dict_nrrel_params}
    ...    skip_parameter_relation_errors=${False}    should_activate=${True}    connection=${connection}    timeout=${timeout_restapi}
    Wait until cluster ready based on NSA_SA type   NSA_SA=${NSA_SA}    is_need_to_setup_gnb_connection=${False}
    [Return]    ${result}

check counter M55114C00505 M55114C00506 M55114C00507
    [Documentation]     author: ludan.fang@nokia-sbell.com
    [Arguments]       ${starting_log_timestamp}   ${cell_list_ca}   ${counter_expected_number}=${0}
    ${pm_files_local_path}    Wait for PM file generated and download    starting_log_timestamp=${starting_log_timestamp}

    ${list_measurement_ids}    create list    M55114C00505    M55114C00506   M55114C00507
    ...     M55114C00001     M55114C00002    M55114C00004     M55114C00003
    ${dict_measurements_value}    counter.get_total_cell_counter_from_multiple_files
    ...      list_file_path=${pm_files_local_path}      list_cell=${cell_list_ca}
    ...      list_measurement_ids=${list_measurement_ids}

    ${M55114C00505_cell1}    set variable    ${dict_measurements_value['${cell_list_ca[0]}']['M55114C00505']}
    ${M55114C00506_cell1}    set variable    ${dict_measurements_value['${cell_list_ca[0]}']['M55114C00506']}
    ${M55114C00507_cell1}    set variable    ${dict_measurements_value['${cell_list_ca[0]}']['M55114C00507']}
    ${M55114C00505_cell2}    set variable    ${dict_measurements_value['${cell_list_ca[1]}']['M55114C00505']}
    ${M55114C00506_cell2}    set variable    ${dict_measurements_value['${cell_list_ca[1]}']['M55114C00506']}
    ${M55114C00507_cell2}    set variable    ${dict_measurements_value['${cell_list_ca[1]}']['M55114C00507']}
    ${M55114C00001_cell1}    set variable    ${dict_measurements_value['${cell_list_ca[0]}']['M55114C00001']}
    ${M55114C00002_cell1}    set variable    ${dict_measurements_value['${cell_list_ca[0]}']['M55114C00002']}
    ${M55114C00003_cell1}    set variable    ${dict_measurements_value['${cell_list_ca[0]}']['M55114C00003']}
    ${M55114C00004_cell1}    set variable    ${dict_measurements_value['${cell_list_ca[0]}']['M55114C00004']}
    ${M55114C00001_cell2}    set variable    ${dict_measurements_value['${cell_list_ca[1]}']['M55114C00001']}
    ${M55114C00002_cell2}    set variable    ${dict_measurements_value['${cell_list_ca[1]}']['M55114C00002']}
    ${M55114C00003_cell2}    set variable    ${dict_measurements_value['${cell_list_ca[1]}']['M55114C00003']}
    ${M55114C00004_cell2}    set variable    ${dict_measurements_value['${cell_list_ca[1]}']['M55114C00004']}

    run keyword and continue on failure   run keywords    Should be true      ${M55114C00505_cell1}==${counter_expected_number}
    ...                                        AND        Should be true      ${M55114C00506_cell1}==${1}
    ...                                        AND        Should be true      ${M55114C00507_cell1}==${counter_expected_number}
    ...                                        AND        Should be true      ${M55114C00505_cell2}==${counter_expected_number}
    ...                                        AND        Should be true      ${M55114C00506_cell2}==${counter_expected_number}
    ...                                        AND        Should be true      ${M55114C00507_cell2}==${1}
    ...                                        AND        Should be true      ${M55114C00001_cell1}==${0}
    ...                                        AND        Should be true      ${M55114C00002_cell1}==${0}
    ...                                        AND        Should be true      ${M55114C00003_cell1}==${0}
    ...                                        AND        Should be true      ${M55114C00004_cell1}==${0}
    ...                                        AND        Should be true      ${M55114C00001_cell2}==${1}
    ...                                        AND        Should be true      ${M55114C00002_cell2}==${1}
    ...                                        AND        Should be true      ${M55114C00003_cell2}==${1}
    ...                                        AND        Should be true      ${M55114C00004_cell2}==${1}

check counter CB009311-B
    [Documentation]     Author: Zhang Yuan
    [Arguments]       ${starting_log_timestamp}    ${cell_list}    ${counter_expected_number_rusult}    ${gnb_id}=0
    ${pm_files_local_path}    Wait for PM file generated and download    starting_log_timestamp=${starting_log_timestamp}
    ${list_measurement_ids}    create list    M55114C00505    M55114C00506   M55114C00507
    ${dict_measurements_value}    counter.get_total_cell_counter_from_multiple_files
    ...      list_file_path=${pm_files_local_path}      list_cell=@{cell_list}
    ...      list_measurement_ids=${list_measurement_ids}

    ${mr_bts_id}    Set variable    ${tl.gnbs[${gnb_id}].instance_id}
    ${nr_bts_id}    Set variable    ${tl.gnbs[${gnb_id}].global_bts_id}
#   quzhi
    FOR    ${cell_idx}    IN    @{cell_list}
           Run keyword and continue on failure      log to console      ${cell_idx}
           ${nr_dist_name}    Set variable    MRBTS-${mr_bts_id}/NRBTS-${nr_bts_id}/NRCELL-${cell_idx}
           ${M55114C00505_cell1}    set variable    ${dict_measurements_value[str(${cell_idx})]['M55114C00505']}
           ${M55114C00506_cell1}    set variable    ${dict_measurements_value[str(${cell_idx})]['M55114C00506']}
           ${M55114C00507_cell1}    set variable    ${dict_measurements_value[str(${cell_idx})]['M55114C00507']}
           run keyword and continue on failure   run keywords
           ...                          Should be true      ${M55114C00505_cell1}== ${counter_expected_number_rusult[str(${cell_idx})][0]}
           ...               AND        Should be true      ${M55114C00506_cell1}== ${counter_expected_number_rusult[str(${cell_idx})][1]}
           ...               AND        Should be true      ${M55114C00507_cell1}== ${counter_expected_number_rusult[str(${cell_idx})][2]}
    END
    [Return]     ${pm_files_local_path}

check counter RAC REJ
    [Documentation]     author: ludan.fang@nokia-sbell.com
    [Arguments]       ${starting_log_timestamp}   ${cell_list_ca}    ${log_path}
    ${pm_files_local_path}    Wait for PM file generated and download    starting_log_timestamp=${starting_log_timestamp}

    ${list_measurement_ids}    create list    M55114C00005    M55114C00006    M55114C00007    M55114C00020
    ${dict_measurements_value}    counter.get_total_cell_counter_from_multiple_files
    ...      list_file_path=${log_path}      list_cell=${cell_list_ca}
    ...      list_measurement_ids=${list_measurement_ids}
    ${M55114C00005_cell1}    set variable    ${dict_measurements_value['${cell_list_ca[0]}']['M55114C00005']}
    ${M55114C00006_cell1}    set variable    ${dict_measurements_value['${cell_list_ca[0]}']['M55114C00006']}
    ${M55114C00007_cell1}    set variable    ${dict_measurements_value['${cell_list_ca[0]}']['M55114C00007']}
    ${M55114C00020_cell1}    set variable    ${dict_measurements_value['${cell_list_ca[0]}']['M55114C00020']}
    run keyword and continue on failure   run keywords    Should be true      ${M55114C00005_cell1}==${0}
    ...                                        AND        Should be true      ${M55114C00006_cell1}==${0}
    ...                                        AND        Should be true      ${M55114C00007_cell1}==${0}
    ...                                        AND        Should be true      ${M55114C00020_cell1}==${0}


#Adjust Replacement cell signal and check pscell select from aasyslog
#    [Documentation]    Author: Zhang Yuan
#    ...    collect aasyslog and check pscell select
#    ...    messageInfo can be:
#    ...    checkRsrq ReplaceCell fail
#    ...    exp_pa_value is set to the same pa value of listed RUs at once
#    [Arguments]    ${messageInfo}    ${exp_pa_value}    ${ru_idx_list}
#    ...    ${aasyslog_name}=aasyslog_rsrp.txt
#    log to console   Adjust PA and check RSRP value state:${messageInfo}.
#    Prepare and start aasyslog    log_name=${aasyslog_name}
#    Set attenuator ports of specified RUs to same value    exp_pa_value=${exp_pa_value}    ru_idx_list=${ru_idx_list}
#    Check messageInfo in aasyslog   messageInfo=${messageInfo}    timeout=90s    aasyslog_name=${aasyslog_name}
#    [Teardown]    Teardown the Aasyslog save progress
