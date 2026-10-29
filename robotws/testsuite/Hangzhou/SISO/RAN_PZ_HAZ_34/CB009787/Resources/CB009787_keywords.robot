*** Settings ***
Documentation
...   author: Liu Zheng
...   contact: zheng.4.liu@nokia-sbell.com
...   squad group: SG_04
...   Feature  in  program
...   SISO_COMMON_BASIC_PATH = 'testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/'
...   BASIC_PATH_5G = SISO_COMMON_BASIC_PATH + '5G'
...   BASIC_PATH_LTE = SISO_COMMON_BASIC_PATH + 'LTE'
...   BASIC_PATH_COMMON = SISO_COMMON_BASIC_PATH + 'Common'

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_RF_module_power_reset.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_RU_lock_unlock.robot
Resource    ${BASIC_PATH_5G}/Cell/E2E_SiSo_Cell_block_and_unblock_gNB.robot
#Resource    ${BASIC_PATH_5G}/General_SiSo_RF_module_reset_from_GUI.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_RF_module_reset_from_GUI_with_L3call.robot
Resource    ${BASIC_PATH_5G}/BTS/Manual_SiSo_SM_NR_RAT_reset.robot
Resource    ${BASIC_PATH_5G}/E2E_SiSo_RAT_block_unblock_via_WEBUI.robot
Resource    ${BASIC_PATH_5G}/Cell/General_SiSo_Online_Cell_addition_deletion.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/common_setup_teardown.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/5G/General_SiSo_NR-ARFCN_check.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/basic/simple_ue.robot
Variables    commissionings/HGZ/${testline_name}/__init__.py

*** Variables ***
${testline_name}    7_5_UTE5G402T2123    # dummy variable, just for pipeline
${ENB_SCF_DEFAULT_FILE_PATH}   ${None}
${DURATION_OF_TRAFFIC}        3000
${DURATION_OF_TPUT_CHECK}     5min
${PERCENT_TARGET_AVG}         0.95
${PERCENT_TARGET_MIN}         0.85
${IPERF_UL}                   300M
${IPERF_DL}                   1000M

${TIMEOUT_CELL_ONAIR}         15min
${TIMEOUT_FAULT}              10min

*** Keywords ***
9787 Suite preparation
    [Documentation]    Author: Liu Zheng
    [Arguments]    ${NSA_SA}=SA    ${gnb_index}=0
    UTE Cloud Or Lightweight Ci Variable Prepare
    Generate suite log path
    set suite variable      ${SAVE_LOG _DIRECTORY}    ${SUITE_LOG_PATH}
    ${is_asod_asoe_asof}    If ASOD or ASOE or ASOF testline    gnb_index=${gnb_index}    du_index=${0}
    set suite variable    ${is_asod_asoe_asof}
    ${SCF_DEFAULT_FILE_PATH}    Get scf template file with release considered    scf_template_file_path=${SCF_DEFAULT_FILE_PATH}
    Set suite variable    ${SCF_DEFAULT_FILE_PATH}
    import variables    ${CURDIR}/../TestData/NIDD_modify_scf.py
    Run keyword if    '${tl.attenuators}'!='[None]'
    ...    Initialize attenuator values for testline    pa_values_mapping=${INIT_PA}    if_change_ENB_PA=${False}
    ...        NSA_SA=${NSA_SA}
    Suite common setup preparation       NSA_SA=${NSA_SA}    is_x2_check_from_enb_needed=${False}    prepare_ue=${False}
    ...    scf_template_path=${SCF_PATH_RFS_N25_20M_B25_10M}
    ${connection}    set variable if    ${gnb_index}==0    GNB_OAM    GNB_OAM_${gnb_index}
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${Active_SW_version}    Get Active SW Version    connection=${connection}
    set suite variable      ${Active_SW_version}
    ${gNb_CuType}   Get gNB CU type    connection=${connection}
    set suite variable      ${gNb_CuType}
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
    ...    connection=${connection}    gnb_index=${gnb_index}
    ${scf_path}    Download SCF Download Via Rest Api    scf_dir_path=${SAVE LOG DIRECTORY}    connection=${connection}
    set suite variable    ${scf_path}
    ${mrbtsID}    ${nrbtsID}   Get mrbtsID and nrbtsID via SCF for gNB    scf_path=${scf_path}
    log to console  MRBTS_ID:${mrbtsID}, NRBTS_ID:${nrbtsID}
    set suite variable  ${mrbtsID}
    set suite variable  ${nrbtsID}
    ${ru_type_init}    get_ru_type_from_init    ru_type=${ru_type}
    set suite variable    ${ru_type_init}
    set suite variable    ${suite_setup_fail_flag}    ${False}

UTE Cloud Or Lightweight Ci Variable Prepare
    [Documentation]    Author: Liu Zheng
#    set suite variable    ${NRBTS_ID}    ${tl.gnbs[0].global_bts_id}
    Set variables for UTE cloud
    ###### keyword for ute cloud #######
    run keyword if    ${IS_UTE_ENV}         Update Default directory for ute cloud
    ...   ELSE      Update Default directory for lightweight ci

Update Default directory for ute cloud
    [Documentation]    Author: Liu Zheng
    ...     Description: default dir scf and swconfig and log dir for ute cloud.
    ...     ${WORKSPACE_DIR} defined by Set variables for UTE cloud
    set suite variable     ${SCF_DEFAULT_FILE_PATH}    ${WORKSPACE_DIR}/commissionings/HGZ/${testlinename}/SCF_SBTS00.xml
    set suite variable     ${SWCONFIG_DEFAULT_FILE_PATH}    ${WORKSPACE_DIR}/commissionings/HGZ/${testlinename}/swconfig.txt

Update Default directory for lightweight ci
    [Documentation]    Author: Liu Zheng
    ...     Description: default dir scf and swconfig for lightweight ci.
    set suite variable   ${SCF_DEFAULT_FILE_PATH}
    ...     /home/ute/Projects/mmw1_config/${testline_name}/scf/SCF_MMW1_TL${tl.gnbs[0].instance_id}.xml
    set suite variable   ${SWCONFIG_DEFAULT_FILE_PATH}
    ...     /home/ute/Projects/mmw1_config/${testline_name}/swconfig/swconfig_MMW1_TL${tl.gnbs[0].instance_id}.txt

9787 Case Setup
    [Documentation]    Author: Liu Zheng
    ...    if the  ${if_commission_needed} is ${None},  then commission with specific configuration.
    ...    or check the configuration(band, chbw, multi_rat_config), if not as expected, then do commission with specific configuration.
    [Arguments]  ${NSA_SA}=SA   ${is_pdl_checking_needed}=${true}    ${scf_template_path}=${SCF_DEFAULT_FILE_PATH}
    ...    ${if_commission_needed}=${False}    ${expect_band}=n25    ${expect_chbw}=20MHz    ${expect_multi_rat_config}=${True}
    robot_common_operations.Common Case Setup

    Set test variable    ${NSA_SA}    ${NSA_SA}
    COAM Create log directory    is_set_to_test_case_level=${True}
    Set Test Variable    ${SAVE LOG DIRECTORY}    ${TS_CASE_LOG_PATH}

    ${config_info}    get band chbw and multirat
    ${band}    set variable    ${config_info['band']}
    ${chbw}    set variable    ${config_info['chbw']}
    ${if_multi_rat}    set variable    ${config_info['if_multi_rat']}

    ${conf}  Catenate  '${band}'!='${expect_band}' or '${chbw}'!='${expect_chbw}' or '${if_multi_rat}'!='${expect_multi_rat_config}'
    ${if_commission_needed_after_check_config}    set variable if   ${conf}    ${True}    ${False}

    run keyword if    ${if_commission_needed}==${True} or ${if_commission_needed_after_check_config}==${True}
    ...    Common case setup   NSA_SA=${NSA_SA}   is_pdl_checking_needed=${is_pdl_checking_needed}
    ...    is_log_required=${false}       scf_template_path=${scf_template_path}

    run keyword if    ${if_commission_needed}==${False} and ${if_commission_needed_after_check_config}==${False}
    ...    Connect to gnb coam via ssl
    ${current_time}    DateTime.Get Current Date    result_format=%Y%m%d%H%M%S%f
    ${scf_file_path_test}     set variable    ${TS_CASE_LOG_PATH}/SCF_${current_time}.xml
    coam.collect_scf    target_file_name=${scf_file_path_test}    export_type=configuration
    ...    timeout=30    connection=GNB_OAM
    Set Test Variable    ${Case_SCF_Path}    ${scf_file_path_test}
    Set Test Variable    ${Case_SCF_Path}
    ${ue_reboot_dict}    create dictionary
    set test variable    ${ue_reboot_dict}
    Wait cell onair classical cloud    timeout=${TIMEOUT_CELL_ONAIR}    du_timeout=${TIMEOUT_CELL_ONAIR}
    ...    is_enb_status_check_needed=${False}    is_x2_check_from_enb_needed=${False}


LTE Case setup
    [Documentation]    Author: Cui Lingxue
    robot_common_operations.Common Case Setup
    COAM Create log directory    is_set_to_test_case_level=${True}
    Set Test Variable    ${SAVE LOG DIRECTORY}        ${TS_CASE_LOG_PATH}
    Set Test Variable    ${CASE_LOG_PATH}    ${TS_CASE_LOG_PATH}

    Commission on LTE    enb_default_scf_file=${SCF_PATH_LTE_B25_10M}
    Connect to gnb coam via ssl
    Wait until keyword succeeds    ${TIMEOUT_CELL_ONAIR}    10s    Verify all cells should be onair    cell_type=lte

    ${current_time}    DateTime.Get Current Date    result_format=%Y%m%d%H%M%S%f
    ${scf_file_path_test}     set variable    ${TS_CASE_LOG_PATH}/SCF_${current_time}.xml
    coam.collect_scf    target_file_name=${scf_file_path_test}    export_type=configuration
    ...    timeout=30    connection=GNB_OAM
    Set Test Variable    ${Case_SCF_Path}    ${scf_file_path_test}
    ${ue_reboot_dict}    create dictionary
    set test variable    ${ue_reboot_dict}


get band chbw and multirat
    [Documentation]   Author: Liu Zheng
    [Arguments]    ${cell_idx}=1
    Connect to gnb coam via ssl
    &{config_info}    Create dictionary
    &{NR_CELL_ID_MAPPING}    coam_gnb_classical.get_relation_mapping_between_cell_index_and_other_ids
    ${band_value}    set variable    ${NR_CELL_ID_MAPPING[${cell_idx}]['detail_cells_info']['band']}
    ${chbw_value}    set variable    ${NR_CELL_ID_MAPPING[${cell_idx}]['detail_cells_info']['chBwDl']}
    ${if_multi_rat}      Check If MultiRAT BTS
    set to dictionary    ${config_info}    band=${band_value}   chbw=${chbw_value}    if_multi_rat=${if_multi_rat}
    [Return]    ${config_info}

Step 1: UE attach, start UL traffic and verify
    [Documentation]    Author: Cui Lingxue
    [Arguments]    ${prepare_ue_needed}=${True}    ${4G_check}=${False}    ${iperf_ul_tput}=${IPERF_UL}    ${exp_ul}=100
    ...    ${customized_log_name}=9787_NR_Only_peak    ${cell_index}=1

    log to console    Step 1: UE attach, start UL traffic and verify
    Retry commercial ue attach if failed
    ...    prepare_ue_needed=${prepare_ue_needed}    4G_check=${4G_check}
    Start data transfer based on direction    data_transfer_direction=ul    ul_tput=${iperf_ul_tput}    duration=${DURATION_OF_TRAFFIC}
    ...    dl_tput=1M
    ${tput_log_path}    power_ue.Collect Tput     ue_type=${UE_TYPE}    duration=${DURATION_OF_TPUT_CHECK}    filter=L2Lo    check_source=Aasyslog
    run keyword and continue on failure    check tput via power ue optimized
    ...    cell_index=${cell_index}    direction=ul
    ...    tput_log_path=${tput_log_path}
    ...    exp_ul=${exp_ul}    target_avg_percent=${PERCENT_TARGET_AVG}    min_percent=${PERCENT_TARGET_MIN}
    ...    customized_log_name=${customized_log_name}_ul    actCarrierAggregation=${False}

Step 2: Stop UL traffic, start DL traffic and verify
    [Documentation]    Author: Cui Lingxue
    [Arguments]    ${iperf_dl_tput}=${IPERF_DL}    ${exp_dl}=400
    ...    ${customized_log_name}=9787_NR_Only_peak    ${cell_index}=1
    log to console    Step 2: Stop UL traffic, start DL traffic and verify
    Stop data transfer based on direction    data_transfer_direction=ul
    sleep    1min    reason=Need to wait some time before start DL traffic, otherwise DL layer will degrade.
    start data transfer based on direction    data_transfer_direction=dl    dl_tput=${iperf_dl_tput}    duration=${DURATION_OF_TRAFFIC}
    ...    ul_tput=1M
    ${tput_log_path}    power_ue.collect tput    ue_type=${UE_TYPE}    duration=${DURATION_OF_TPUT_CHECK}    filter=L2Lo    check_source=Aasyslog
    run keyword and continue on failure    check tput via power ue optimized
    ...    cell_index=${cell_index}    direction=dl
    ...    tput_log_path=${tput_log_path}
    ...    exp_dl=${exp_dl}    target_avg_percent=${PERCENT_TARGET_AVG}    min_percent=${PERCENT_TARGET_MIN}
    ...    customized_log_name=${customized_log_name}_dl    actCarrierAggregation=${False}

Step 3: Start UL traffic and verify bi-direction traffic
    [Documentation]    Author: Cui Lingxue
    [Arguments]    ${iperf_ul_tput}=${IPERF_UL}    ${exp_ul}=100    ${exp_dl}=400
    ...    ${customized_log_name}=9787_NR_Only_peak    ${cell_index}=1
    log to console    Step 3: Start UL traffic and verify bi-direction traffic
    start data transfer based on direction    data_transfer_direction=ul    ul_tput=${iperf_ul_tput}    duration=${DURATION_OF_TRAFFIC}
    ...    dl_tput=1M
    ${tput_log_path}    power_ue.collect tput     ue_type=${UE_TYPE}    duration=${DURATION_OF_TPUT_CHECK}    filter=L2Lo    check_source=Aasyslog
    run keyword and continue on failure    check tput via power ue optimized
    ...    cell_index=${cell_index}    direction=both
    ...    tput_log_path=${tput_log_path}
    ...    exp_ul=${exp_ul}    exp_dl=${exp_dl}    target_avg_percent=${PERCENT_TARGET_AVG}    min_percent=${PERCENT_TARGET_MIN}
    ...    customized_log_name=${customized_log_name}_both    actCarrierAggregation=${False}

Backup original value of nrarfcn and earfcn
    [Documentation]    Author: Cui Lingxue
    [Arguments]    ${connection}=GNB_OAM    ${timeout}=5min
    @{MOs_nrcell}    coam.get_managed_objects    class_name=NRCELL_FDD_A    connection=${connection}    timeout=${timeout}
    &{dict_nrarfcn}    coam.get_parameters    dist_name=${MOs_nrcell[0]['distName']}    pattern=nrarfcn    connection=${connection}
    @{MOs_lncel}    coam.get_managed_objects    class_name=LNCEL_FDD_A    connection=${connection}    timeout=${timeout}
    &{dict_earfcn}    coam.get_parameters    dist_name=${MOs_lncel[0]['distName']}    pattern=earfcn    connection=${connection}

    ${dict_earfcn_nrarfcn}    create dictionary
    set_to_dictionary    ${dict_earfcn_nrarfcn}
    ...    nrarfcnDl=${dict_nrarfcn['nrarfcnDl']}    nrarfcnUl=${dict_nrarfcn['nrarfcnUl']}
    ...    earfcnDL=${dict_earfcn['earfcnDL']}    earfcnUL=${dict_earfcn['earfcnUL']}
    [Return]    ${dict_earfcn_nrarfcn}

Online modify arfcn of NR FDD cell or LTE FDD cell
    [Documentation]    Author: Cui Lingxue
    [Arguments]    ${nrarfcnDl}=${None}    ${nrarfcnUl}=${None}    ${earfcnDL}=${None}    ${earfcnUL}=${None}    ${timeout}=5min
    ${params_to_upd}    create list
    ${parameter_nrarfcnDl}    run keyword if    '${nrarfcnDl}'!='${None}'    evaluate
    ...    dict(dist_name='${DN_NRCELL_1}/NRCELL_FDD-1', parameter='nrarfcnDl', value='${nrarfcnDl}')
    ${parameter_nrarfcnUl}    run keyword if    '${nrarfcnUl}'!='${None}'    evaluate
    ...    dict(dist_name='${DN_NRCELL_1}/NRCELL_FDD-1', parameter='nrarfcnUl', value='${nrarfcnUl}')
    ${parameter_earfcnDL}    run keyword if    '${earfcnDL}'!='${None}'    evaluate
    ...    dict(dist_name='${DN_LNCEL}/LNCEL_FDD-0', parameter='earfcnDL', value='${earfcnDL}')
    ${parameter_earfcnUL}    run keyword if    '${earfcnUL}'!='${None}'    evaluate
    ...    dict(dist_name='${DN_LNCEL}/LNCEL_FDD-0', parameter='earfcnUL', value='${earfcnUL}')

    run keyword if    '${nrarfcnDl}'!='${None}'    append to list  ${params_to_upd}  ${parameter_nrarfcnDl}
    run keyword if    '${nrarfcnUl}'!='${None}'    append to list  ${params_to_upd}  ${parameter_nrarfcnUl}
    run keyword if    '${earfcnDL}'!='${None}'     append to list  ${params_to_upd}  ${parameter_earfcnDL}
    run keyword if    '${earfcnUL}'!='${None}'     append to list  ${params_to_upd}  ${parameter_earfcnUL}

    ${update_status}    COAM Update several parameters via rest api    parameters_to_update_via_api=${params_to_upd}
    ...    should_activate=${True}    skip_parameter_relation_errors=${True}    timeout=${timeout}
    [Return]    ${update_status}

Verify no PDL error for parameter update
    [Arguments]    ${parameter_update_result}
    should be equal    ${parameter_update_result}    PASS

Verify PDL error for NRARFCN out of band range
    [Arguments]    ${parameter_update_result}    ${freqBandIndicatorNR}=66
    ${pdl_error}    set variable    ${parameter_update_result['validationResult']['pdlValidationResult']['logs']['relationErrors']}[${0}]
    ${pdl_error}    set variable    ${pdl_error['pdl']}
    should contain  ${pdl_error}    Assertion not met: NRCELL(freqBandIndicatorNR = ${freqBandIndicatorNR})/NRCELL_FDD have (nrarfcnDl in range
    ...     422000..440000) and (mod(nrarfcnDl,20) = 0)

Verify fault 1900 appear
    [Arguments]    ${timeout}=${TIMEOUT_FAULT}
    Wait Until Keyword Succeeds   ${timeout}   5 sec    Expect Fault Should Present    faultId=1900    timeout=${timeout}
    ...    is_need_to_setup_gnb_connection=${False}    severity=Critical    alarmId=7116    configObjectName=${DN_MRBTS}/EQM-1/APEQM-1/RMOD-1

Verify fault 1807 appear
    [Arguments]    ${timeout}=${TIMEOUT_FAULT}
    Wait Until Keyword Succeeds   ${timeout}   5 sec    Expect Fault Should Present    faultId=1807    timeout=${timeout}
    ...    is_need_to_setup_gnb_connection=${False}    severity=Critical    alarmId=7112    configObjectName=${DN_LNCEL}

Check SM and RF module status
    [Arguments]  ${timeout}=10 min    ${connection}=GNB_OAM    ${retry_interval}=5 sec    ${du_index}=0    ${gnb_index}=0
    ${is_asod_asoe_asof}    If ASOD or ASOE or ASOF testline    gnb_index=${gnb_index}    du_index=${du_index}
    ...    timeout=${timeout}    retry_interval=${retry_interval}
    Wait until keyword succeeds    ${timeout}    ${retry_interval}    COAM Check GNB ASIK status    connection=${connection}
    Run keyword if    ${is_asod_asoe_asof}==${False}
    ...    Wait until keyword succeeds    ${timeout}    ${retry_interval}    COAM Check GNB ABIL status    connection=${connection}
    ...    ELSE    Log to console    Skip the status checking for ABIL as the blade type is ASOD or ASOE or ASOF
    Wait until keyword succeeds    ${timeout}    ${retry_interval}    COAM Check GNB RU status    connection=${connection}
