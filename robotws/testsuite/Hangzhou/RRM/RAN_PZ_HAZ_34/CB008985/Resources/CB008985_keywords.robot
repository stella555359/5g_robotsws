*** Settings ***
Resource     Beam_Counter_Variables.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/CA/Resources/CA_Common_New/Check_CA_via_tcpdump_log.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/CA/Resources/case_keywords.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/CA/Resources/CA_Common_New/ca_specifical_step.robot
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/CA/TestData/Parameters_modify_lib.py    WITH NAME    param_modify_lib
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/lib/online_nidd_process.py    WITH NAME    nidd_modify

Documentation
...   This is for Supercell CB008985 keywords.
...   author: Qi Xin
...   contact: xin.qi@nokia-sbell.com
...   squad group: MMW_SG1

*** Variables ***
${testline_name}    null
${ENB_SCF_DEFAULT_FILE_PATH}   ${None}

*** Keywords ***
Import NIDD variables for 8985
    import variables    commissionings/HGZ/${testline_name}/__init__.py
    ${is_tl_delta_file_exists}    Run keyword and return status    File should exist    commissionings/HGZ/${testline_name}/TLDelta.py
    Run keyword if    ${is_tl_delta_file_exists}
    ...    Import variables  commissionings/HGZ/${testline_name}/TLDelta.py

    import resource     ${CURDIR}/../Resources/CB008985_variables.robot
    import variables    ${CURDIR}/../TestData/NIDD_modify_scf.py

UTE Cloud Or Lightweight Ci Variable Prepare
    set suite variable    ${NRBTS_ID}                 ${tl.gnbs[0].global_bts_id}
    ${HAS_ENB_TESTLINE_INIT}  Run Keyword and Return Status  Should Be True  ${tl.enbs}
    set suite variable      ${HAS_ENB_TESTLINE_INIT}
    run keyword if  ${HAS_ENB_TESTLINE_INIT}
    ...           set suite variable     ${ENB_ID}                             ${tl.enbs[0].instance_id}
    Set variables for UTE cloud
    ###### keyword for ute cloud #######
    run keyword if    ${IS_UTE_ENV}         Update Default directory for ute cloud
    ...   ELSE      Update Default directory for lightweight ci

Update Default directory for ute cloud
    [Documentation]    Author: Dandan Fang
    ...     Description: default dir scf and swconfig and log dir for ute cloud.
    ...     ${WORKSPACE_DIR} defined by Set variables for UTE cloud
    ${stream}    ${build}     CI_commssion._Get Stream From Variable    ${ENB_BUILD}
    set suite variable     ${SCF_DEFAULT_FILE_PATH}    ${WORKSPACE_DIR}/commissionings/HGZ/${testlinename}/SCF_${stream}.xml
    set suite variable     ${SWCONFIG_DEFAULT_FILE_PATH}    ${WORKSPACE_DIR}/commissionings/HGZ/${testlinename}/swconfig.txt
    run keyword if  ${HAS_ENB_TESTLINE_INIT}
    ...    set suite variable     ${ENB_SCF_DEFAULT_FILE_PATH}          ${WORKSPACE_DIR}/commissionings/HGZ/${testlinename}/ENB_SCF_SBTS00.xml

Update Default directory for lightweight ci
    [Documentation]    Author: Dandan Fang
    ...     Description: default dir scf and swconfig for lightweight ci.
    set suite variable   ${SCF_DEFAULT_FILE_PATH}
    ...     /home/ute/Projects/mmw1_config/${testline_name}/scf/SCF_MMW1_TL${NRBTS_ID}.xml
    set suite variable   ${SWCONFIG_DEFAULT_FILE_PATH}
    ...     /home/ute/Projects/mmw1_config/${testline_name}/swconfig/swconfig_MMW1_TL${NRBTS_ID}.txt

8985 CA Suite preparation
    [Documentation]  Author: Dandan Fang
    ...   8985 T-T CA case prepare.
    [Arguments]    ${NSA_SA}=SA      ${is_pdl_checking_needed}=${False}
    UTE Cloud Or Lightweight Ci Variable Prepare
    Import NIDD variables for 8985

    Decode CA group mapping and set global variable    is_called_in_suite_level=${True}    ca_group_mapping=${T_T_2CC_CA_GROUP_COMMON}
    set suite variable    ${PARAMS_TO_DELETE}    ${DELETE_SCF_DEFAULT}
    set suite variable    ${PARAMS_TO_ADD}       ${ADD_SCF_DEFAULT}
    set suite variable    ${PARAMS_TO_MODIFY}    ${MODIFY_SCF_CA_DEFAULT}
    CA Suite preparation    prepare_ue=${True}    NSA_SA=${NSA_SA}    enb_default_scf_file=${ENB_SCF_DEFAULT_FILE_PATH}
    ...     is_pdl_checking_needed=${is_pdl_checking_needed}      pa_values_mapping=${CA_PCELL_SCELL_PA_INIT}
    ...     scf_template_path=${SCF_DEFAULT_FILE_PATH}     ue_index=${0}
    Prepare NRREL under specific cell    ca_group_mapping=${ca_group_mapping}
    Online Enable IWK Feature on Cells by rest api   cell_id_list=${CELL_INDEX_LIST}    NSA_SA=${NSA_SA}

8985 NonCA Suite preparation
    [Documentation]    Author: Qi Xin
    [Arguments]    ${NSA_SA}=SA
    UTE Cloud Or Lightweight Ci Variable Prepare
    Import NIDD variables for 8985
    Suite common setup preparation       NSA_SA=${NSA_SA}    is_x2_check_from_enb_needed=${true}    prepare_ue=${true}

    #COMMON_PCELL_ID defined in each testline init py
    Set suite variable    ${PCELL_ID}    ${COMMON_PCELL_ID}

    ${cell_id_list}   create list  ${PCELL_ID}
    Online Enable IWK Feature on Cells by rest api   cell_id_list=${cell_id_list}   NSA_SA=${NSA_SA}

    run keyword and ignore error
    ...    Switch NSA SA mode via cell bar/unbar nr cells    pa_values_mapping=${NONCA_SUBCELL0_ATTACH_PA_INIT}    pcell_id=${PCELL_ID}
    ...    ue_index=${ue_index}    is_prepare_ue_needed=${False}    prefer_5g_nr_mode=${NSA_SA}

8985 Case Setup
    [Arguments]  ${NSA_SA}=SA   ${is_pdl_checking_needed}=${true}
    Set test variable    ${NSA_SA}    ${NSA_SA}
    #used in NSA case
    Set test variable   @{GNB_PS_CELL_INDEX_LIST}   ${PCELL_ID}

    Common case setup   NSA_SA=${NSA_SA}   is_pdl_checking_needed=${is_pdl_checking_needed}     is_log_required=${false}

    run keyword if    '${NSA_SA}'=='SA'
    ...    Change status for parameter cellBarred on GNB    exp_status=notBarred   list_cell_ids=${PCELL_ID}   timeout=2min
    ...    ELSE     Change status for parameter cellBarred on GNB    exp_status=barred   list_cell_ids=all   timeout=2min

CB008985_C3_2 Case Setup
    [Documentation]  Author: Dandan Fang
    8985 Case Setup   NSA_SA=SA   is_pdl_checking_needed=${true}
    Modify radio link monitoring parameters work on scell        badrlqcount=${0}    cell_index=${SCELL_ID}
    ...       period=${2000}  goodthreshold=${20}  badthreshold=${15}

8985 6xSubcell Case Setup
    [Arguments]  ${NSA_SA}=SA   ${is_pdl_checking_needed}=${true}
    Set test variable    ${NSA_SA}    ${NSA_SA}

    #6 Subcell switch use special scf
    COAM Create log directory    is_set_to_test_case_level=${True}

    ${template_for_subcell_switch}    scfpro.SCFProcess
    ...     scf_template_path=${SCF_DEFAULT_FILE_PATH}  scf_process_folder=${TS_CASE_LOG_PATH}
    ...     list_para_to_modify=${MODIFY_SCF_COMMON_DEFAULT}
    ...     list_para_to_add=${DU_SCF_ADD_6xSubcell}
    ...     list_para_to_delete=${TL_PARAMS_TO_DELETE_Second_Cell}

    #COMMON_PCELL_ID defined in each testline init py
    Set test variable    ${PCELL_ID}    ${COMMON_PCELL_ID}

    Common case setup   NSA_SA=${NSA_SA}   is_pdl_checking_needed=${is_pdl_checking_needed}     is_log_required=${false}
    ...           scf_template_path=${template_for_subcell_switch}

    ${cell_id_list}   create list  ${PCELL_ID}
    Online Enable IWK Feature on Cells by rest api   cell_id_list=${cell_id_list}    NSA_SA=${NSA_SA}

    run keyword if    '${NSA_SA}'=='SA'
    ...    Change status for parameter cellBarred on GNB    exp_status=notBarred   list_cell_ids=${PCELL_ID}   timeout=2min
    ...    ELSE     Change status for parameter cellBarred on GNB    exp_status=barred   list_cell_ids=all   timeout=2min

Decode CA group mapping and set global variable
    [Documentation]  Author: Dandan Fang
    ...   Not sure whether SuperCell TDD more than 2CC , example 3CC or 4CC, then choose the keyword from 6137, easy to extended.
    ...   Currently just support 2 supercells
    [Arguments]  ${ca_group_mapping}=${None}     ${is_called_in_suite_level}=${False}
    ${pcell_id_list}    create list    ${ca_group_mapping['pcell_id']}
    ${scell_id_list}    create list    ${ca_group_mapping['verify_scell_add_dl']}
    ${CELL_INDEX_LIST}    combine lists    ${pcell_id_list}    ${scell_id_list}

    run keyword if    ${is_called_in_suite_level}    Run keywords
    ...    Set suite variable    ${CA_GROUP_MAPPING}    ${ca_group_mapping}    AND
    ...    Set suite variable    ${PCELL_ID}    ${ca_group_mapping['pcell_id']}    AND
    ...    Set suite variable    ${SCELL_ID}    ${ca_group_mapping['verify_scell_add_dl']}  AND
    ...    Set suite variable    ${CELL_INDEX_LIST}
    ...    ELSE    Run keywords
    ...    Set test variable    ${CA_GROUP_MAPPING}    ${ca_group_mapping}    AND
    ...    Set test variable    ${PCELL_ID}    ${ca_group_mapping['pcell_id']}    AND
    ...    Set test variable    ${SCELL_ID}    ${ca_group_mapping['verify_scell_add_dl']}   AND
    ...    Set test variable    ${CELL_INDEX_LIST}

Prepare NRREL under specific cell
    [Documentation]    Author: Dandan Fang
    ...    Generate and activate parameters for nrrel update based on ca_group_mapping.
    [Arguments]    ${ca_group_mapping}
    &{dict_nrrel_params}    param_modify_lib.get_nrrel_params_for_online_update_based_on_ca_group_mapping_config
    ...    ca_group_mapping=${ca_group_mapping}  program=${PROGRAM}
    ${result}    nidd_modify.online_modify_nidd_parameters_via_restapi    params_modify_dict=${dict_nrrel_params}
    ...    skip_parameter_relation_errors=${False}    should_activate=${True}
    Wait until cluster is on cell on air status    timeout=${CLASSICAL_COMMISSION_ONAIR_TIMEOUT}    is_all_cells_checking_needed=${True}
    ...    is_enb_status_check_needed=${False}    is_x2_check_from_enb_needed=${False}
    [Return]    ${result}

Online Enable IWK Feature on Cells by rest api
    [Documentation]   author: Dandan Fang
    ...    Following IWK just supported after 23R3
    ...    Update parameter list:
    ...        MRBTS-564/NRBTS-564/NRCELL-1/actCsirsMultiplexing
    ...        MRBTS-564/NRBTS-564/NRCELL-1/actPerCsiReportBundlingTddFr1
    [Arguments]    ${cell_id_list}    ${NSA_SA}    ${timeout}=${TIMER_FOR_MODIFY_VIA_API}
    ${iwk_enable}   set variable if  '${PROGRAM}'=='23R1' or '${PROGRAM}'=='23R2'   ${False}    ${True}

    ${params_to_upd_list}    create list
    FOR    ${cell_index}    IN    @{cell_id_list}
        ${actCsirsMultiplexing}    evaluate
        ...    dict(dist_name='NRBTS-${NRBTS_ID}/NRCELL-${cell_index}', parameter='actCsirsMultiplexing', value=${iwk_enable})

        ${actPerCsiReportBundlingTddFr1}    evaluate
        ...    dict(dist_name='NRBTS-${NRBTS_ID}/NRCELL-${cell_index}', parameter='actPerCsiReportBundlingTddFr1', value=${iwk_enable})

        append to list    ${params_to_upd_list}    ${actCsirsMultiplexing}   ${actPerCsiReportBundlingTddFr1}
    END

    COAM Update several parameters via rest api    parameters_to_update_via_api=${params_to_upd_list}    timeout=${timeout}
    Wait until cluster ready based on NSA_SA type        NSA_SA=${NSA_SA}

Adjust PA And Check Attach Status
    [Documentation]     author: dandan.fang@nokia-sbell.com
    [Arguments]  ${pa_values_mapping}=${None}   ${pcell_id}=${PCELL_ID}
    ...          ${4G_check}=${False}      ${NSA_SA}=SA
    ...          ${tcpdump_log_name}=SuperCell_l3_call     ${ue_type}=${UE_TYPE}     ${ue_index}=${0}
    ...          ${CA_enable}=${False}     ${scell_addition_method}=blind    ${check_counter}=${False}

    Run keyword if    '${tl.attenuators}'!='[None]'
    ...    Initialize attenuator values for testline    pa_values_mapping=${pa_values_mapping}
    ...     if_change_ENB_PA=${True}    NSA_SA=${NSA_SA}

    ${ute_log_path}    UE attach and check Scell addition in tcpdump log    CA_enable=${CA_enable}    4G_check=${4G_check}
    ...    tcpdump_log_name=${tcpdump_log_name}    scell_addition_method=${scell_addition_method}    pcell_id=${pcell_id}
    ...    check_counter=${check_counter}    ue_index=${ue_index}   ue_type=${ue_type}   NSA_SA=${NSA_SA}

Start data transfer and Check Tput As Expected
    [Documentation]     author: dandan.fang@nokia-sbell.com
    [Arguments]  ${dl_iperf_tput}    ${ul_iperf_tput}    ${exp_ul_indiv}     ${exp_dl_indiv}
    ...          ${cell_id}=${PCELL_ID}    ${data_transfer_direction}=both
    ...          ${customized_log_name}=supercell_dl_ul_tput_check
    Start data transfer based on direction    data_transfer_direction=${data_transfer_direction}    dl_tput=${dl_iperf_tput}
    ...        ul_tput=${ul_iperf_tput}       duration=${DURATION_OF_TPUT_SEND}
    Collect Tput and Check Tput As Expected    cell_id=${cell_id}     direction=${data_transfer_direction}
    ...       exp_ul_indiv=${exp_ul_indiv}    exp_dl_indiv=${exp_dl_indiv}
    ...       customized_log_name=${customized_log_name}

Collect Tput and Check Tput As Expected
    [Documentation]     author: dandan.fang@nokia-sbell.com
    ...     use to collect Tput and check check whether tput as expected for special Cell.
    ...     8985 just peak case, then min_percent, target_avg_percent keep default
    [Arguments]  ${cell_id}       ${customized_log_name}      ${exp_ul_indiv}    ${exp_dl_indiv}
    ...          ${duration}=${DURATION_OF_TPUT_CHECK}  ${direction}=both    ${ignore_time}=1min
    ${tput_log}    power_ue.Collect Tput     ue_type=${UE_TYPE}    duration=${duration}
    ...        ignore_time=${ignore_time}    filter=L2Lo    check_source=Aasyslog

    run keyword and ignore error    check iperf process on appserver
    run keyword and continue on failure    Check tput via power UE optimized    cell_index=${cell_id}    exp_ul=1
    ...        exp_dl=1    tput_log_path=${tput_log}  direction=${direction}  customized_log_name=${CUSTOMIZED_LOG_NAME}
    ...        exp_ul_indiv=${exp_ul_indiv}    exp_dl_indiv=${exp_dl_indiv}
    ...        is_analysis_log_captured=${False}

Trigger PCELL Subcell Switch And Check Tput BF Counter
    [Documentation]     author: dandan.fang@nokia-sbell.com
    ...      After SUbcell switch, check tput or BF Counter
    ...      tput_check_cell_id, bf_counter_cell_id : just be Pcell ID
    ...      counter_name:which counter you want to check, details please refer to couner define.
    ...      counter_expected_number: expected value.
    [Arguments]  ${source_target_subcell_pa_info}     ${counter_name}      ${counter_expected_number}
    ...          ${exp_ul_indiv}       ${exp_dl_indiv}
    ...          ${bf_counter_cell_id}=${PCELL_ID}    ${tput_check_cell_id}=${PCELL_ID}
    ${starting_log_timestamp}    Prepare for counter log

    _Adjust PA Value For Source And Target Subcell
    ...    source_subcell_pa=${source_target_subcell_pa_info['source_subcell']}
    ...    target_subcell_pa=${source_target_subcell_pa_info['target_subcell']}

    Collect Tput and Check Tput As Expected    cell_id=${tput_check_cell_id}     direction=both
    ...       exp_ul_indiv=${exp_ul_indiv}    exp_dl_indiv=${exp_dl_indiv}
    ...       customized_log_name=pcell_subcell_switch_tput    duration=${DURATION_OF_SUBCELL_SWITCH_TPUT_CHECK}

    check Beamforming Counter For Specific Cell After Subcell Switch
    ...    starting_log_timestamp=${starting_log_timestamp['log_generator_timestamp']}   cell_id=${bf_counter_cell_id}
    ...    counter_name=${counter_name}        counter_expected_number=${counter_expected_number}

Trigger SCELL Subcell Switch And Check Tput
    [Documentation]     author: dandan.fang@nokia-sbell.com
    ...     After SUbcell switch, check tput (BF Counter not available for Scell)
    ...     source_target_subcell_pa_info define format, please refer to commission testline init file
    ...     for exmaple , SCELL_Subcell_1_SwitchTo_Subcell_2_PA = {
    ...                          'source_subcell': {'ru_index': 4, 'pa_value': 30},
    ...                          'target_subcell': {'ru_index': 5, 'pa_value': 0}
    ...                   }
    [Arguments]  ${tput_check_cell_id}    ${exp_ul_indiv}  ${exp_dl_indiv}
    ...          ${source_target_subcell_pa_info}   ${data_transfer_direction}=both
    _Adjust PA Value For Source And Target Subcell
    ...    source_subcell_pa=${source_target_subcell_pa_info['source_subcell']}
    ...    target_subcell_pa=${source_target_subcell_pa_info['target_subcell']}

    Collect Tput and Check Tput As Expected    cell_id=${tput_check_cell_id}     direction=${data_transfer_direction}
    ...       exp_ul_indiv=${exp_ul_indiv}    exp_dl_indiv=${exp_dl_indiv}
    ...       customized_log_name=scell_subcell_switch_tput    duration=${DURATION_OF_SUBCELL_SWITCH_TPUT_CHECK}

_Adjust PA Value For Source And Target Subcell
    [Documentation]     author: dandan.fang@nokia-sbell.com
    ...      Use to check beam forming counter update after subcell switch
    ...      cell_id: beam forming is based on Cell, it can be Pcell_Id or Scell_Id
    ...      counter_name:which counter you want to check, details please refer to couner define.
    ...      counter_expected_number: expected value.
    [Arguments]       ${source_subcell_pa}     ${target_subcell_pa}
    #target subcell is good first.Else sometime meet Max RLC transmission Fail
    Initialize attenuator for specified RU
    ...      ru_index=${target_subcell_pa['ru_index']}   exp_pa_value=${target_subcell_pa['pa_value']}

    Initialize attenuator for specified RU
    ...      ru_index=${source_subcell_pa['ru_index']}   exp_pa_value=${source_subcell_pa['pa_value']}

check Beamforming Counter For Specific Cell After Subcell Switch
    [Documentation]     author: dandan.fang@nokia-sbell.com
    ...      Use to check beam forming counter update after subcell switch
    ...      cell_id: beam forming is based on Cell, it can be Pcell_Id or Scell_Id
    ...      counter_name:which counter you want to check, details please refer to couner define.
    ...      counter_expected_number: expected value.
    [Arguments]       ${starting_log_timestamp}   ${cell_id}   ${counter_expected_number}   ${counter_name}
    ${pm_files_local_path}    Wait for PM file generated and download    starting_log_timestamp=${starting_log_timestamp}
    ${cell_check_list}    create list     ${cell_id}
    ${list_measurement_ids}    create list    ${counter_name}
    ${dict_measurements_value}    counter.get_total_cell_counter_from_multiple_files
    ...      list_file_path=${pm_files_local_path}      list_cell=${cell_check_list}
    ...      list_measurement_ids=${list_measurement_ids}

    ${counter_value}    set variable    ${dict_measurements_value['${cell_id}']['${counter_name}']}
    run keyword and continue on failure   Should be true      ${counter_value}==${counter_expected_number}

Verify scell data suspened and not deactivated when scell subcell in bad
    [Documentation]    Author: Dandan Fang
    ...    Note: check scell bad rlq happened and no DL Data on Scell DL.But Scell is still in activated.
    ...    scell_rlq_ruindex_pa_value value, for exp,SCELL_RLQ_Subcell0_RU_INDEX_PA_VALUE = {'ru_index': 3, 'pa_value': 40}
    [Arguments]
    ...             ${scell_rlq_ruindex_pa_value}
    ...             ${scell_deactivation_method}=qualitybased
    ...             ${log_name}=scell_suspend_no_deactive_when_rlq_go_into_bad.txt
    Prepare and start aasyslog   log_name=${log_name}

    Adjust attenuator to expected value based specific interval for specified RU
    ...      ru_index=${scell_rlq_ruindex_pa_value['ru_index']}
    ...      exp_pa_value=${scell_rlq_ruindex_pa_value['pa_value']}     pa_interval=${10}

    ${tput_log}    power_ue.Collect Tput     ue_type=${UE_TYPE}    duration=${DURATION_OF_SUBCELL_SWITCH_TPUT_CHECK}
    ...        ignore_time=1min    filter=L2Lo

    run keyword and continue on failure    Check tput via power UE optimized    cell_index=${CELL_INDEX_LIST}
    ...        tput_log_path=${tput_log}  direction=both  customized_log_name=bad_rlq_trigger_tput_check
    ...        exp_ul_indiv=${PCELL_EXP_UL_TP},-1   exp_dl_indiv=${PCELL_EXP_DL_TP},0
    ...        is_analysis_log_captured=${False}      exp_ul=1    exp_dl=1

    #during 60s, no scell deactive happened
    ${is_scell_deactivated}    Run keyword and return status    Stop aasyslog to check scell deactivation
    ...                sCelldeactivationMethod=${scell_deactivation_method}   log_name=${log_name}      timeout=60s
    should not be true    ${is_scell_deactivated}
    [Teardown]    run keyword and ignore error    Teardown the Aasyslog save progress
