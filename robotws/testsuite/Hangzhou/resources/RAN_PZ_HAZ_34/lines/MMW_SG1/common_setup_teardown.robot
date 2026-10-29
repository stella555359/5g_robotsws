*** Settings ***
Documentation
...   This is for common setup and teardown keywords

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    ./mmw_coam_gnb_cloud.robot
Resource    ./logs.robot
Resource    ./l3call.robot
Resource    ./SISO_Pre.robot
Resource    ./common_other.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Library     ./lib/scf_process.py
Library     ./lib/mmw1_util.py
Library     scf_process.SCFProcess    WITH NAME    scfpro
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot

*** Variables ***
${CU_SCF_TEMPATE_PATH}    /home/ute/Projects/mmw1_config/${testline_name}/GNB_SCF_CU_MMW1_TL${tl.gnbs[0].cu.instance_id}.xml
${DU_SCF_TEMPATE_PATH}    /home/ute/Projects/mmw1_config/${testline_name}/GNB_SCF_DU_MMW1_TL${tl.gnbs[0].dus[0].instance_id}.xml

${SCF_DEFAULT_FILE_PATH}             /home/ute/Projects/mmw1_config/${testline_name}/scf/SCF_MMW1_TL${tl.gnbs[0].instance_id}.xml
${SWCONFIG_DEFAULT_FILE_PATH}      /home/ute/Projects/mmw1_config/${testline_name}/swconfig/swconfig_MMW1_TL${tl.gnbs[0].instance_id}.txt
${CLASSICAL_COMMISSION_ONAIR_TIMEOUT}    15min
${CLOUD_CU_COMMISSION_ONAIR_TIMEOUT}     15min
${CLOUD_DU_COMMISSION_ONAIR_TIMEOUT}     20min
${DEFAULT_ONAIR_TIMEOUT}                 3min
${DEFAULT_DU_ONAIR_TIMEOUT}              3min
${COMMISSION_API_TIMEOUT}                    10min
${IS_LOG_CAPTURED_CASE_LEVEL}                       ${True}              # Flag used to define whether snapshot/ bts logs are needed in case teardown
${ALLOWED_FAULTS_IDS}    ${None}


*** Keywords ***
Suite common setup preparation
    [Documentation]    author: Wang Yixiang
    ...    suite setup for both classical and cloud
    ...    the keyword will replace the old keywords:
    ...        Common suite setup preparation(for cloud)
    ...        Suite preparation common(for classical)
    ...    classical testline example:
    ...    Suite common setup preparation    scf_modify_parameters=${scf_modify_parameters}
    ...    cloud testline example:
    ...    Suite common setup preparation    cu_scf_parameters_list=${MODIFY_GNB_CU_COUNTER}
    ...    cu_scf_template_path=${SCF_DEFAULT_FILE_PATH_CU}    cu_timeout=${CU_TIMEOUT}
    ...    is_pdl_checking_needed=${False}    du_timeout=${DU_TIMEOUT}
    ...    if ${enb_default_scf_file}!=${None}, commission LTE
    ...    there will be suite variable ${PDL_VALIDATION_RESULT} generated after KW executed.
    ...        if you need to check PDL validation result, you can check the this suite variable in case part, then it will affect minimum case.
    ...        for example: run keyword and continue on failure    Should be true    ${PDL_VALIDATION_RESULT}!=${False}
    ...                     msg=Commissioned with error exists, pdl validation result is not in OK status.
    ...    Process cloud du/classical gnb scf  example:
    ...         can be referred in 2056-AIAJ, if process scf is needed, then the unified arguments should be set
    ...         ${PARAMS_TO_DELETE} for delete, ${PARAMS_TO_MODIFY} for modify, ${PARAMS_TO_ADD} for add, seperately.
    ...         format of the arguments can be referred in scf_process.py
    ...    Following action need to be done if testline run with UTE Cloud environment ,for example tl045 :
    ...         if you need to use eNB or case run with NSA, note1,2 is needed, else ignore.
    ...         1. enb object predefined in testline configuration __init__.py, but added to ues, not into enbs, else enb install package
    ...         will be triggered by ute task, and meet others preprare issue;
    ...         2. add enb object into testline enbs with robotws/commissionings/HGZ/7_5_UTE5G402T045/__init__.py
    ...         3. Call "Set variables for UTE cloud" keyword before keyword "Suite common setup preparation", some parameters need to be predefined,
    ...         for example ${testline_name} need to be setted first, then scf path value can be setted normal, else meet error.
    # classical testline commission
    [Arguments]     ${scf_modify_parameters}=${PARAMS_TO_MODIFY_SCF}    ${swconfig_modify}=${None}
    ...    ${is_pdl_checking_needed}=${False}    ${cluster_start_up_timeout}=${CLASSICAL_COMMISSION_ONAIR_TIMEOUT}
    ...    ${scf_template_path}=${SCF_DEFAULT_FILE_PATH}
    # cloud testline commission
    ...    ${cu_scf_parameters_list}=${None}    ${cu_scf_template_path}=${CU_SCF_TEMPATE_PATH}
    ...    ${du_scf_parameters_list}=${None}    ${du_scf_template_path}=${DU_SCF_TEMPATE_PATH}
    ...    ${swconfig_template_path}=${SWCONFIG_DEFAULT_FILE_PATH}
    ...    ${cu_timeout}=${CLOUD_CU_COMMISSION_ONAIR_TIMEOUT}    ${du_timeout}=${CLOUD_DU_COMMISSION_ONAIR_TIMEOUT}
    # LTE commission
    ...    ${enb_default_scf_file}=${None}    ${is_enb_pdl_checking_needed}=${False}
    ...    ${prepare_ue}=${False}    ${detach_request}=${true}    ${ue_index}=${0}    ${enb_index}=${None}
    ...    ${is_enb_status_check_needed}=${True}    ${ui_version}=default
    ...    ${is_x2_check_from_enb_needed}=${True}
    # NSA need to check enb status and x2, but SA don't need to check enb and x2
    ...    ${NSA_SA}=NSA
    ...    &{kwargs}
    ${is_enb_status_check_needed}     set variable if    '${NSA_SA}'=='SA'    ${False}    ${is_enb_status_check_needed}
    ${is_x2_check_from_enb_needed}    set variable if    '${NSA_SA}'=='SA'    ${False}    ${is_x2_check_from_enb_needed}

    # if scf content had been updated due to deleted or modify or add, then no call Common Suite Setup for UTE cloud,
    # which use default scf to do commission. need to do second commission else many error meet , ssl can not connect
    # please define f1_m_ip_addr as 192.168.255.129 , then we no need to call CI_interface.Common Suite Setup
     ${IS_UTE_ENV}      get_variable_value    ${IS_UTE_ENV}
     run keyword if     ${IS_UTE_ENV}    Set Suite Variable      ${SUITE_LOG_PATH}    ${TS_LOG_PATH_BASE}
     run keyword if     ${IS_UTE_ENV}    CI_interface.Common Suite Setup     # ute cloud commission

    robot_common_operations.Common Suite Setup

    ${cur_program}    gnb_classical_hangzhou.Get program version based on stream version
    set suite variable    ${PROGRAM}    ${cur_program}
    COAM Create log directory    is_set_to_test_case_level=${False}
    ${UE_status}    run keyword and return status    ue.translate_power_ue_type_from_testline    ue_index=${ue_index}
    ${UE_TYPE}   run keyword if   ${UE_status}   ue.translate_power_ue_type_from_testline    ue_index=${ue_index}
    run keyword if   ${UE_status}    set suite variable    ${UE_TYPE}

    ${has_enb}    testline_info.has_enb    ${tl}
    run keyword if    '${enb_default_scf_file}'!='${None}' and ${has_enb}
    ...    Commission on LTE
    ...    enb_default_scf_file=${enb_default_scf_file}    is_pdl_checking_needed=${is_enb_pdl_checking_needed}
    ${has_cbts}    testline_info.has_cloudBts    ${tl}
    # Process cloud du/classical gnb scf
    ${PARAMS_TO_DELETE}      get_variable_value    ${PARAMS_TO_DELETE}
    ${PARAMS_TO_MODIFY}     get_variable_value    ${PARAMS_TO_MODIFY}
    ${PARAMS_TO_ADD}        get_variable_value    ${PARAMS_TO_ADD}
    ${scf_template_path}    Get scf template file with release considered    scf_template_file_path=${scf_template_path}    program=${PROGRAM}
    ${template_for_process}     set variable if    ${has_cbts}       ${du_scf_template_path}     ${scf_template_path}
    ${template_for_process}    scfpro.SCFProcess    scf_template_path=${template_for_process}    scf_process_folder=${SUITE_LOG_PATH}
    ...    list_para_to_delete=${PARAMS_TO_DELETE}    list_para_to_modify=${PARAMS_TO_MODIFY}    list_para_to_add=${PARAMS_TO_ADD}

    run keyword if    ${has_cbts}    _Sub cloud suite setup
    ...    cu_scf_parameters_list=${cu_scf_parameters_list}    cu_scf_template_path=${cu_scf_template_path}
    ...    du_scf_parameters_list=${du_scf_parameters_list}    du_scf_template_path=${template_for_process}
    ...    cu_timeout=${cu_timeout}    is_pdl_checking_needed=${is_pdl_checking_needed}
    ...    swconfig_template_path=${swconfig_template_path}    swconfig_modify=${swconfig_modify}
    ...    du_timeout=${du_timeout}
    ...    ELSE    _Sub classical suite setup
    ...    scf_modify_parameters=${scf_modify_parameters}    swconfig_modify=${swconfig_modify}
    ...    is_pdl_checking_needed=${is_pdl_checking_needed}    cluster_start_up_timeout=${cluster_start_up_timeout}
    ...    scf_template_path=${template_for_process}    enb_index=${enb_index}
    ...    is_enb_status_check_needed=${is_enb_status_check_needed}    is_x2_check_from_enb_needed=${is_x2_check_from_enb_needed}
    ...    swconfig_template_path=${swconfig_template_path}

    run keyword if    ${prepare_ue}    power_ue.Prepare UE    ue_type=${UE_TYPE}    ue_index=${ue_index}   detach_request=${detach_request}
    ...    ui_version=${ui_version}

_Sub cloud suite setup
    [Documentation]    Private
    ...     author: Wang Yixiang
    [Arguments]    ${cu_scf_parameters_list}=${None}    ${cu_scf_template_path}=${CU_SCF_TEMPATE_PATH}
    ...    ${du_scf_parameters_list}=${None}    ${du_scf_template_path}=${DU_SCF_TEMPATE_PATH}
    ...    ${cu_timeout}=${CLOUD_CU_COMMISSION_ONAIR_TIMEOUT}    ${is_pdl_checking_needed}=${True}
    ...    ${swconfig_template_path}=${SWCONFIG_DEFAULT_FILE_PATH}    ${swconfig_modify}=${None}
    ...    ${du_timeout}=${CLOUD_DU_COMMISSION_ONAIR_TIMEOUT}
    WA Connect to Common Unit Master
    ${default_swconfig_file_path}    Copy file    source=${swconfig_template_path}    destination=${SUITE_LOG_PATH}
    run keyword if    ${swconfig_modify}!=${None}
    ...    swconf.modify swconfig file    parametersList=${swconfig_modify}    filePath=${default_swconfig_file_path}
    swconf.Upload swConfig file to asik and crasign    localFilePath=${default_swconfig_file_path}    asik_alias=ASIK Master
    csn.disconnect    connection=ASIK Master
    csn.disconnect    connection=OAM
    Modify CU and DU parameter commission and onair
    ...    cu_scf_parameters_list=${cu_scf_parameters_list}    du_scf_parameters_list=${du_scf_parameters_list}
    ...    cu_scf_template_path=${cu_scf_template_path}    du_scf_template_path=${du_scf_template_path}
    ...    local_scf_path=${SUITE_LOG_PATH}    cu_timeout=${cu_timeout}    du_timeout=${du_timeout}
    ...    is_pdl_checking_needed=${is_pdl_checking_needed}

_Sub classical suite setup
    [Arguments]     ${scf_modify_parameters}=${PARAMS_TO_MODIFY_SCF}    ${swconfig_modify}=${None}
    ...    ${is_pdl_checking_needed}=${False}    ${cluster_start_up_timeout}=${CLASSICAL_COMMISSION_ONAIR_TIMEOUT}
    ...    ${scf_template_path}=${SCF_DEFAULT_FILE_PATH}    ${enb_index}=${None}
    ...    ${is_enb_status_check_needed}=${True}
    ...    ${is_x2_check_from_enb_needed}=${True}
    ...    ${swconfig_template_path}=${SWCONFIG_DEFAULT_FILE_PATH}
    Do commission and return PDL validation result for classical
    ...    swconfig_modify=${swconfig_modify}    scf_modify_parameters=${scf_modify_parameters}
    ...    is_pdl_checking_needed=${is_pdl_checking_needed}    scf_template_path=${scf_template_path}
    ...    swconfig_template_path=${swconfig_template_path}
    run keyword if    '${is_pdl_checking_needed}' == '${True}'    run keywords
    ...    should be true    ${PDL_VALIDATION_RESULT}     AND
    ...    log to console    commission passed with PDL validation success.
    Wait until cluster is on cell on air status    timeout=${cluster_start_up_timeout}    is_all_cells_checking_needed=${True}
    ...    enb_index=${enb_index}
    ...    is_enb_status_check_needed=${is_enb_status_check_needed}    is_x2_check_from_enb_needed=${is_x2_check_from_enb_needed}

Do commission and return PDL validation result for classical
    [Documentation]    author: Liu Zheng
    [Arguments]     ${scf_modify_parameters}=${PARAMS_TO_MODIFY_SCF}    ${swconfig_modify}=${None}
    ...    ${is_pdl_checking_needed}=${False}    ${scf_template_path}=${SCF_DEFAULT_FILE_PATH}
    ...    ${swconfig_template_path}=${SWCONFIG_DEFAULT_FILE_PATH}
    ${PDL_VALIDATION_RESULT}    Preparation with swconfig modification and comissioning    swconfig_modify=${swconfig_modify}
    ...    scf_modify=${scf_modify_parameters}    is_called_in_test_case_level=${False}
    ...    is_pdl_checking_needed=${is_pdl_checking_needed}    scf_template_path=${scf_template_path}
    ...    swconfig_template_path=${swconfig_template_path}
    Set suite variable    ${PDL_VALIDATION_RESULT}

# WARN  deprecated, please donot use it
Common suite setup preparation
    [Documentation]    author: Wang Yixiang
    ...    1. Create suite log path:${SUITE_LOG_PATH}
    ...    2. Commission gNB and verify status
    ...    3. UE related operation
    ...    deprecated, please use keyword "Suite common setup preparation"
    [Arguments]    ${cu_scf_parameters_list}=${None}    ${cu_scf_template_path}=${CU_SCF_TEMPATE_PATH}
    ...    ${du_scf_parameters_list}=${None}    ${du_scf_template_path}=${DU_SCF_TEMPATE_PATH}
    ...    ${cu_timeout}=${CLOUD_CU_COMMISSION_ONAIR_TIMEOUT}    ${is_pdl_checking_needed}=${True}
    ...    ${swconfig_template_path}=${SWCONFIG_DEFAULT_FILE_PATH}    ${swconfig_modify}=${None}
    ...    ${du_timeout}=${CLOUD_DU_COMMISSION_ONAIR_TIMEOUT}

    Suite common setup preparation    cu_scf_parameters_list=${cu_scf_parameters_list}
    ...    cu_scf_template_path=${cu_scf_template_path}
    ...    du_scf_parameters_list=${du_scf_parameters_list}
    ...    du_scf_template_path=${du_scf_template_path}
    ...    cu_timeout=${cu_timeout}
    ...    is_pdl_checking_needed=${is_pdl_checking_needed}
    ...    swconfig_template_path=${swconfig_template_path}
    ...    swconfig_modify=${swconfig_modify}
    ...    du_timeout=${du_timeout}

Common suite recovery
    [Documentation]    author: Wang Yixiang
    ...    suite environment recovery
    [Arguments]    ${is_log_required}=${False}    ${swconfig_template_path}=${SWCONFIG_DEFAULT_FILE_PATH}    ${enb_index}=${0}
    robot_common_operations.Common Suite Teardown

    # Collect btslog, snapshot, alarm logs in teardown
    run keyword if    ${is_log_required}    Collect logs in teardown classical and cloud
    ...    is_called_in_test_case_level=${False}    name=btslog    is_btslog_required=${False}

    Run keyword if    '${SUITE STATUS}' == 'FAIL' and ${is_log_required}     run keywords
    ...    Connect to eNB via ssl    enb_index=${enb_index}    connection=enblte_${enb_index}    AND
    ...    COAM Save snapshot via rest api    connection=enblte_${enb_index}    log_path=${SUITE_LOG_PATH}    timeout=${1200}   AND
    ...    Enblte close down    connection=enblte_${enb_index}

    Connect to Common Unit Master
    run keyword and ignore error    swconf.Upload swConfig file to asik and crasign    localFilePath=${swconfig_template_path}
    ...    asik_alias=ASIK Master
    run keyword and ignore error   Clear unuseful log in teardown    log_path=${SUITE_LOG_PATH}    is_called_in_test_case_level=${False}
    run keyword and ignore error    Close all connection

Common case setup
    [Documentation]    author: Wang Yixiang
    ...    1. Create case log path:${TS_CASE_LOG_PATH}
    ...    2. Wait cell ready
    ...    3. Modify nidd via rest api(classical and cloud DU)
    ...    4. Modify nidd via rest api(cloud CU)
    ...    5. if ${nidd_modify_via_api}!=${None} means modify classical or cloud DU NIDD via rest api
    ...    6. if ${cu_nidd_modify_via_api}!=${None} means modify cloud CU NIDD via rest api
    ...    7. if ${is_log_required}==${True} means start bts log in case setup
    ...    ${allowed_faults_ids}: Refer to the extra faults to be ignored in case.
    ...        -- Input format should be a sting. like: 4655, 61524.
    ...        -- If None, then will only ignore alarms in CI's white list
    [Arguments]    ${nidd_modify_via_api}=${None}
    ...    ${cu_nidd_modify_via_api}=${None}
    ...    ${is_log_required}=${False}
    ...    ${is_alias_created}=${False}
    ...    ${if_create_ru_alias_needed}=${False}
    ...    ${onair_timeout}=${DEFAULT_ONAIR_TIMEOUT}
    ...    ${timeout_restapi}=${60}
    ...    ${is_enb_status_check_needed}=${True}
    ...    ${is_x2_check_from_enb_needed}=${True}
    ...    ${enb_index}=${None}
    # parameter for SCF commission
    ...    ${scf_modify_parameters}=${None}    ${swconfig_modify}=${None}
    ...    ${is_pdl_checking_needed}=${False}    ${cluster_start_up_timeout}=${CLASSICAL_COMMISSION_ONAIR_TIMEOUT}
    ...    ${scf_template_path}=${None}
    ...    ${cu_scf_parameters_list}=${None}    ${cu_scf_template_path}=${CU_SCF_TEMPATE_PATH}
    ...    ${du_scf_parameters_list}=${None}    ${du_scf_template_path}=${DU_SCF_TEMPATE_PATH}
    ...    ${swconfig_template_path}=${SWCONFIG_DEFAULT_FILE_PATH}
    ...    ${cu_timeout}=${CLOUD_CU_COMMISSION_ONAIR_TIMEOUT}    ${du_timeout}=${CLOUD_DU_COMMISSION_ONAIR_TIMEOUT}
    # NSA need to check enb status and x2, but SA don't need to check enb and x2
    ...    ${NSA_SA}=NSA
    # legacy compatible
    ...    ${name}=btslog    ${btslog_path}=/opt/btslog/btslog    ${btslog_launcher_path}=/opt/btslog/btslog_launcher
    ...    ${log_storage_dir}=/tmp/btslog2    ${host}=${tl.test_pc.default_ssh_connection_details.addr}
    ...    ${is_scf_backup_needed}=${True}    ${fail_with_alarms}=${True}    ${allowed_faults_ids}=${ALLOWED_FAULTS_IDS}
    ...    &{kwargs}

    ${IS_UTE_ENV}      get_variable_value    ${IS_UTE_ENV}
    run keyword if     ${IS_UTE_ENV}    CI_interface.Common Case Setup     # ute cloud case setup

    COAM Create log directory
    #no matter ute cloud or lightweight, need to call following KW, report configuration ID
    robot_common_operations.Common Case Setup    allowed_faults_ids=${allowed_faults_ids}    fail_with_alarms=${fail_with_alarms}

    ${is_enb_status_check_needed}     set variable if    '${NSA_SA}'=='SA'    ${False}    ${is_enb_status_check_needed}
    ${is_x2_check_from_enb_needed}    set variable if    '${NSA_SA}'=='SA'    ${False}    ${is_x2_check_from_enb_needed}

    Connect to gnb coam via ssl

    # Modify scf via commission if need
    ${scf_template_path}        run keyword if    '${scf_template_path}'!='${None}'
    ...       Get scf template file with release considered    scf_template_file_path=${scf_template_path}    program=${PROGRAM}
    run keyword if    ${scf_modify_parameters}!=${None} or '${scf_template_path}'!='${None}'
    ...    _Sub classical suite setup
    ...    scf_modify_parameters=${scf_modify_parameters}    swconfig_modify=${swconfig_modify}
    ...    is_pdl_checking_needed=${is_pdl_checking_needed}    cluster_start_up_timeout=${cluster_start_up_timeout}
    ...    is_enb_status_check_needed=${is_enb_status_check_needed}    is_x2_check_from_enb_needed=${is_x2_check_from_enb_needed}
    ...    scf_template_path=${scf_template_path}     swconfig_template_path=${swconfig_template_path}

    ${cloud_scf_modify}    evaluate    ${cu_scf_parameters_list}!=${None} or ${du_scf_parameters_list}!=${None}
    run keyword if    ${cloud_scf_modify}
    ...    _Sub cloud suite setup
    ...    cu_scf_parameters_list=${cu_scf_parameters_list}    cu_scf_template_path=${cu_scf_template_path}
    ...    du_scf_parameters_list=${du_scf_parameters_list}    du_scf_template_path=${du_scf_template_path}
    ...    cu_timeout=${cu_timeout}    is_pdl_checking_needed=${is_pdl_checking_needed}
    ...    swconfig_template_path=${swconfig_template_path}    swconfig_modify=${swconfig_modify}
    ...    du_timeout=${du_timeout}

    _capture log in case setup    is_log_required=${is_log_required}
    ...    name=${name}    btslog_path=${btslog_path}
    ...    btslog_launcher_path=${btslog_launcher_path}
    ...    log_storage_dir=${log_storage_dir}    host=${host}
    run keyword if    ${is_alias_created}    _create alias in case setup    if_create_ru_alias_needed=${if_create_ru_alias_needed}

    # Modify NIDD parameter via rest api if needed
    run keyword if    ${nidd_modify_via_api}!=${None}
    ...    Modify nidd parameters via rest api
    ...    nidd_modify_via_api=${nidd_modify_via_api}    timeout=${timeout_restapi}
    run keyword if    ${cu_nidd_modify_via_api}!=${None}
    ...    CU Delta Commission update    parameters=${cu_nidd_modify_via_api}

    Wait cell onair classical cloud
    ...    timeout=${onair_timeout}    du_timeout=${onair_timeout}
    ...    is_enb_status_check_needed=${is_enb_status_check_needed}    is_x2_check_from_enb_needed=${is_x2_check_from_enb_needed}
    ...    enb_index=${enb_index}

    # download SCF file to log path for mannual rerun or mannual debug issue
    Run keyword if   ${is_scf_backup_needed}
    ...    run keyword and ignore error    Download SCF file to log path

Common case teardown
    [Documentation]    Author: Wang Yixiang   Common case teardown
    ...    1. If ${detach_ue}!=${False}, close iperf progress, detach UE
    ...    2. If ${restapi_restore_nidd} or ${restapi_cu_restore_nidd}!=${None}, modify NIDD via restapi method, aim to restore NIDD values back.
    ...    3. If ${is_onair_check}!=${False}, check cell onair status
    ...    4. If ${is_close_connection}!=${True}, close connection
    [Arguments]    ${is_log_required}=${IS_LOG_CAPTURED_CASE_LEVEL}
    ...    ${ue_index}=${0}    ${detach_ue}=${False}
    ...    ${is_onair_check}=${False}
    ...    ${onair_timeout}=${DEFAULT_ONAIR_TIMEOUT}
    ...    ${is_close_connection}=${True}
    ...    ${is_scf_restore}=${False}
    ...    ${scf_file_path_for_restore}=${None}
    ...    ${restapi_restore_nidd}=${None}
    ...    ${restapi_cu_restore_nidd}=${None}
    ...    ${is_need_to_clear_unused_logs}=${True}
    ...    ${is_btslog_required}=${True}
    ...    ${rest_api_timeout}=120
    ...    ${NSA_SA}=NSA
    ...    ${is_enb_status_check_needed}=${True}
    ...    ${is_x2_check_from_enb_needed}=${True}
    ...    &{kwargs}
    robot_common_operations.Common Case Teardown

    # Close iperf and detach UE
    run keyword if    ${detach_ue}    run keyword and ignore error    Stop data transfer based on direction
    run keyword if    ${detach_ue}    run keyword and ignore error    power_ue.UE Detach    ue_type=${UE_TYPE}    ue_index=${ue_index}
    run keyword if    ${detach_ue}    run keywords
    ...    run keyword and ignore error    Get Commercial UE IP    ue_index=${ue_index}    AND
    ...    run keyword and ignore error    log to console    UE IP captured after the case is ${UE_IP}

    # Collect btslog, snapshot, alarm logs in teardown
    run keyword if    ${is_log_required}    Collect logs in teardown classical and cloud
    ...    is_called_in_test_case_level=${True}    name=btslog    is_btslog_required=${is_btslog_required}

    run keyword if    ${is_scf_restore}    Restore SCF in case teardown    scf_file_path_for_restore=${scf_file_path_for_restore}
    ...    ELSE     run keyword if    ${restapi_restore_nidd}!=${None}    run keywords    Connect to gnb coam via ssl
    ...    AND    COAM Update several parameters via rest api    timeout=${rest_api_timeout}
    ...    parameters_to_update_via_api=${restapi_restore_nidd}
    run keyword if    ${restapi_cu_restore_nidd}!=${None}    CU Delta Commission update
    ...    parameters=${restapi_cu_restore_nidd}
    ${is_enb_status_check_needed}     set variable if    '${NSA_SA}'=='SA'    ${False}    ${is_enb_status_check_needed}
    ${is_x2_check_from_enb_needed}    set variable if    '${NSA_SA}'=='SA'    ${False}    ${is_x2_check_from_enb_needed}

    Run keyword if    ${is_onair_check}    Wait cell onair classical cloud    timeout=${onair_timeout}   du_timeout=${onair_timeout}
    ...    is_enb_status_check_needed=${is_enb_status_check_needed}    is_x2_check_from_enb_needed=${is_x2_check_from_enb_needed}
    Run keyword if    ${is_close_connection}    run keyword and ignore error    Close all connection
    run keyword and ignore error    ssh.disconnect    connection=cpc_${ue_index}
    run keyword and ignore error    ssh.disconnect    connection=cygwin
    run keyword and ignore error    run keyword if    ${is_need_to_clear_unused_logs}
    ...    Clear unuseful log in teardown    log_path=${TS_CASE_LOG_PATH}   is_called_in_test_case_level=${True}
    # Should be called at the end of case teardown. Don't move, otherwise report data to powerBI will be failed
    CI_interface.Common Case Teardown

Wait cell onair classical cloud
    [Documentation]    Wait cell on air for both cloud and classical testline
    [Arguments]    ${timeout}=${DEFAULT_ONAIR_TIMEOUT}    ${du_timeout}=${DEFAULT_DU_ONAIR_TIMEOUT}    ${enb_index}=${None}
    ...    ${is_enb_status_check_needed}=${True}    ${is_x2_check_from_enb_needed}=${True}
    ${has_cbts}    testline_info.has_cloudBts    ${tl}
    run keyword if    ${has_cbts}
    ...    COAM GNB Wait CU and DU cells are on air status    timeout=${timeout}    du_timeout=${du_timeout}
    ...    ELSE
    ...    Wait until cluster is on cell on air status    timeout=${timeout}    is_all_cells_checking_needed=${True}    enb_index=${enb_index}
    ...    is_enb_status_check_needed=${is_enb_status_check_needed}    is_x2_check_from_enb_needed=${is_x2_check_from_enb_needed}

Close all connection
    [Documentation]    Author: Wang Yixiang    Release all connections
    Tear down all SISO connections
    ssh.reset_cache

Kill tcpdump on gNB
    [Documentation]    Author: Wang Yixiang   Kill tcpdump process
    wait until keyword succeeds    1 min    2 sec    Connect to Common Unit Master    alias=ASIK Master
    csn.send command    command=killall tcpdump     connection=ASIK Master
    [Teardown]    csn.disconnect    connection=ASIK Master

Kill tcpdump on gNB CU
    [Documentation]    Kill tcpdump process of CU
    [Arguments]    ${gnb_index}=${0}
    csn.Connect to    hostname=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...               username=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.username}
    ...               password=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.password}
    ...               alias=gNB_CU
    csn.send command    command=sudo killall tcpdump     connection=gNB_CU
    [Teardown]    csn.disconnect    connection=gNB_CU

Kill tcpdump on asik slave
    [Documentation]    Author: Cui Lingxue
    ...    Kill all tcpdump process on asik slave.
    [Arguments]    ${gnb_index}=${0}    ${du_index}=${0}    ${asik_alias}=ASIK Master    ${asik_slave_alias}=ASIK Slave
    wait until keyword succeeds    1 min    2 sec    Connect to Common Unit Slave    gnb_index=${gnb_index}    du_index=${du_index}
    ...    alias=${asik_slave_alias}    asik_alias=${asik_alias}
    csn.send command    command=killall tcpdump     connection=${asik_slave_alias}
    [Teardown]    csn.disconnect    connection=${asik_slave_alias}

Kill tcpdump on asik slave or asib master
    [Documentation]    Author: Cheng Catherine
    ...    Kill all tcpdump process on asik slave or asib master.
    [Arguments]    ${gnb_index}=${0}    ${du_index}=${0}    ${asik_alias}=ASIK Master    ${asik_slave_alias}=ASIK Slave
    ${asib_flag}    If ASIB card used    alias=${asik_alias}    gnb_index=${gnb_index}
    ${has_cbts}    testline_info.has_cloudBts    ${tl}
    run keyword if    '${asib_flag}'=='${True}' and '${has_cbts}' == '${False}'    Kill tcpdump on gNB
    ...    ELSE    Kill tcpdump on asik slave    gnb_index=${gnb_index}    du_index=${du_index}    asik_alias=${asik_alias}
    ...        asik_slave_alias=${asik_slave_alias}

Collect logs in teardown classical and cloud
    [Documentation]  Author: Wang Yixiang
    ...              Description: Collect common logs in teardown phase for trouble shooting
    [Arguments]    ${is_called_in_test_case_level}=${True}    ${name}=btslog    ${is_btslog_required}=${False}
    ${has_cbts}    testline_info.has_cloudBts    ${tl}
    run keyword if    ${has_cbts}    Collect logs in teardown cloud
    ...    is_called_in_test_case_level=${is_called_in_test_case_level}    name=${name}
    ...    is_btslog_required=${is_btslog_required}
    ...    ELSE    common_setup_teardown.Collect logs in teardown
    ...    is_called_in_test_case_level=${is_called_in_test_case_level}    name=${name}
    ...    is_btslog_required=${is_btslog_required}

Collect logs in teardown cloud
    [Documentation]  Author: Wang Yixiang
    ...              Description: Collect common logs in teardown phase for trouble shooting
    [Timeout]  15 min
    [Arguments]    ${is_called_in_test_case_level}=${True}    ${name}=btslog    ${is_btslog_required}=${False}
    ${status}    Set variable if    ${is_called_in_test_case_level}    ${TEST STATUS}    ${SUITE STATUS}
    ${log_path}    Set variable if    ${is_called_in_test_case_level}    ${TS_CASE_LOG_PATH}    ${SUITE_LOG_PATH}
    Cloud DU connect to gnb coam via ssl
    Run keyword if    '${status}' == 'FAIL'    run keywords
    ...    COAM Verify if alarm exists    log_path_alarm=${log_path}    AND
    ...    Collect DU snapshot via coam    log_path=${log_path}    AND
    ...    Veriy if alarms exist on CU    log_path_alarm=${log_path}    AND
    ...    CU Collect Snapshot    log_path=${log_path}
    run keyword if    ${is_btslog_required}    stop btslog and collect logs    status=${status}    name=${name}

Collect DU snapshot via coam
    [Documentation]  Author: Wang Yixiang
    [Arguments]    ${log_path}=${TS_CASE_LOG_PATH}
    COAM Teardown gnb connections
    Cloud DU connect to gnb coam via ssl
    ${timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    ${snapshot_zip_file_path}    Join Path    ${log_path}    snapshot_DU_${timestamp}.zip
    coam.get_snapshot    target_file_name=${snapshot_zip_file_path}   timeout=600   connection=GNB_OAM
    [Teardown]  COAM Teardown gnb connections

# WARN  deprecated, please donot use it
Suite preparation common
    [Documentation]  Author: Ding Binmei
    ...              Description: ${PARAMS_TO_MODIFY_SCF} should be defined in TL files related with env info
    ...              deprecated, please use keyword "Suite common setup preparation"
    [Timeout]    20 min
    [Arguments]    ${scf_modify_parameters}=${PARAMS_TO_MODIFY_SCF}    ${swconfig_modify}=${None}    ${is_pdl_checking_needed}=${False}
    ...            ${cluster_start_up_timeout}=${RECOVERY_TIMEOUT}    ${scf_template_path}=${SCF_DEFAULT_FILE_PATH}
    Suite common setup preparation    scf_modify_parameters=${scf_modify_parameters}    swconfig_modify=${swconfig_modify}
    ...    is_pdl_checking_needed=${is_pdl_checking_needed}    cluster_start_up_timeout=${cluster_start_up_timeout}
    ...    scf_template_path=${scf_template_path}

Suite teardown common
    [Documentation]  Author: Ding Binmei
    Connect to gnb coam via ssl
    Connect to Common Unit Master    alias=ASIK Master
    swconf.Restore swConfig file on asik and crasign    asik_alias=ASIK Master
    common_setup_teardown.Collect logs in teardown    is_called_in_test_case_level=${False}    is_btslog_required=${False}
    Run keyword and ignore error    Tear down all SISO connections

# WARN  deprecated, please donot use it
Case preparation common
    [Documentation]  Author: Ding Binmei
    ...              2020/04/27 Cui Lingxue: add btslog capture
    [Arguments]    ${name}=btslog    ${btslog_path}=/opt/btslog/btslog    ${btslog_launcher_path}=/opt/btslog/btslog_launcher
    ...    ${log_storage_dir}=/tmp/btslog2    ${host}=${tl.test_pc.default_ssh_connection_details.addr}    ${is_btslog_required}=${True}
    Common case setup    is_log_required=${is_btslog_required}    is_alias_created=${True}
    ...    name=${name}    btslog_path=${btslog_path}    btslog_launcher_path=${btslog_launcher_path}
    ...    log_storage_dir=${log_storage_dir}    host=${host}

_capture log in case setup
    [Documentation]  Author: Wang Yixiang
    ...              for case setup
    [Arguments]    ${is_log_required}=${True}    ${name}=btslog    ${btslog_path}=/opt/btslog/btslog
    ...    ${btslog_launcher_path}=/opt/btslog/btslog_launcher
    ...    ${log_storage_dir}=/tmp/btslog2    ${host}=${tl.test_pc.default_ssh_connection_details.addr}
    run keyword if    ${is_log_required}    start btslog capture    name=${name}    btslog_path=${btslog_path}
    ...    btslog_launcher_path=${btslog_launcher_path}    log_dir=${log_storage_dir}    host=${host}

_create alias in case setup
    [Documentation]  Author: Wang Yixiang
    ...              for case setup
    [Arguments]    ${if_create_ru_alias_needed}=${False}
    Connect to Common Unit Master    alias=ASIK Master
    run keyword and ignore error
    ...    Connect to Capacity Unit Loner    alias=ABIL Loner_1
    run keyword if    ${if_create_ru_alias_needed}    wait until keyword succeeds    1 min    1 sec
    ...    _create alias for RU and set alias to suite variable
    Connect to Capacity Unit Slave

_create alias for RU and set alias to suite variable
    @{RUS_ALIAS}    Connect to all rus with allocated IP
    Set suite variable    ${RUS_ALIAS}

Modify nidd parameters via rest api
    [Documentation]    Author: Wang Yixiang
    ...    Use this keyword to update nidd paramter via rest api.
    ...    It can be use for classical gnb and cloud DU
    [Arguments]    ${nidd_modify_via_api}    ${log_path}=${TS_CASE_LOG_PATH}    ${connection}=GNB_OAM    ${timeout}=${60}
    coam_gnb_classical.COAM Update several parameters via rest api
    ...    parameters_to_update_via_api=${nidd_modify_via_api}    timeout=${timeout}
    ${timestamp}    Get Current Date    result_format=%Y%m%d-%H%M%S
    ${scf_file_path}    coam.get_current_scf_file    local_dir_path=${log_path}
    ...    file_name=SCF_after_nidd_modification_${timestamp}    connection=${connection}
    Log to console    Downloading current scf from gNB. SCF file path is ${scf_file_path}

# WARN  deprecated, please donot use it
Case env recovery common
    [Documentation]  Author: Ding Binmei
    ...              Description: is_need_to_wait_cluster_ready, if set to ${True}, then need to wait for the cluster to recovery
    ...                                                          if set to ${False}, then skip the waiting for recovery
    ...                           ${RECOVERY_TIMEOUT}: Should be defined based on cluster start up duration
    [Arguments]  ${is_need_to_wait_cluster_ready}=${True}    ${timeout}=${RECOVERY_TIMEOUT}
    ...    ${ue_index}=${0}
    Common case teardown    is_log_required=${False}    ue_index=${ue_index}    detach_ue=${False}
    ...    is_onair_check=${is_need_to_wait_cluster_ready}    onair_timeout=${timeout}

Tear down all SISO connections
    [Documentation]  Author: Ding Binmei
    ...              Description: Release all connections
    coam_gnb_classical.COAM Teardown gnb connections
    enb_lte.Enblte close down    connection=enblte
    @{ru_alias}    Create list    RU    RU_1    RU_2    RU_3
    Disconnect ssh connections    list_alias=${ru_alias}
    @{ssh_alias}    Create list    ABIL Loner_1    ABIL Master    ASIK Master    ABIL Slave    ABIL Loner    ENB    OAM    ASIK Slave
    Disconnect ssh connections    list_alias=${ssh_alias}

Collect logs in teardown
    [Documentation]  Author: Ding Binmei
    ...              Description: The keyword use for classical testline
    ...                           Collect common logs in teardown phase for trouble shooting
    ...                           This keyword can be called in both suite teardown and case teardown with ${is_called_in_test_case_level}
    ...              2020/04/27 Cui Lingxue: add btslog capture
    [Timeout]  15 min
    [Arguments]    ${is_called_in_test_case_level}=${True}    ${name}=btslog    ${is_btslog_required}=${True}
    ...    ${gnb_index}=0    ${connection}=GNB_OAM
    ${status}    Set variable if    ${is_called_in_test_case_level}    ${TEST STATUS}    ${SUITE STATUS}
    ${log_path}    Set variable if    ${is_called_in_test_case_level}    ${TS_CASE_LOG_PATH}    ${SUITE_LOG_PATH}
#    Connect to gnb coam via ssl
    Connect to gnb coam via ssl    gnb_index=${gnb_index}    connection=${connection}
    run keyword and ignore error
    ...    Download SCF file to log path  extended_name=tear_down_scf_save      local_dir=${log_path}    connection=${connection}
    Run keyword if    '${status}' == 'FAIL'
    ...    COAM Save snapshot via webUI    download_dir=${log_path}   url=https://${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}
    ...    username=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...    password=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    run keyword if    ${is_btslog_required}    stop btslog and collect logs    status=${status}    name=${name}
    [Teardown]  COAM Teardown gnb connections    connection=${connection}

WA Connect to Common Unit Master
    [Documentation]  Author: Wang Yixiang
    ...    clear public key of UTE when ssh to CU throws exception "Permission denied (publickey,password,keyboard-interactive)."
    ${conn_status}    run keyword and return status    Connect to Common Unit Master
    run keyword if    ${conn_status}==${False}    run keywords
    ...    Run   command=ssh-keygen -f "/home/ute/.ssh/known_hosts" -R "${tl.gnbs[0].cu.oam_ssh_connection_details.addr}"
    ...    AND
    ...    Connect to Common Unit Master

Restore SCF in case teardown
    [Documentation]  Author: Wang Yixiang
    ...    restore default SCF in teardown
    [Arguments]    ${classical_timeout}=${COMMISSION_API_TIMEOUT}
    ...    ${cu_timeout}=${CLOUD_CU_COMMISSION_ONAIR_TIMEOUT}    ${du_timeout}=${CLOUD_DU_COMMISSION_ONAIR_TIMEOUT}
    ...    ${scf_file_path_for_restore}=${SCF_DEFAULT_FILE_PATH}
    Log to console    Restore SCF in case teardown
    ${cu_scf_parameters_list}    create list
    ${du_scf_parameters_list}    create list
    ${has_cbts}    testline_info.has_cloudBts    ${tl}
    run keyword if    ${has_cbts}    Modify CU and DU parameter commission and onair
    ...    cu_scf_parameters_list=${cu_scf_parameters_list}    du_scf_parameters_list=${du_scf_parameters_list}
    ...    cu_scf_template_path=${CU_SCF_TEMPATE_PATH}    du_scf_template_path=${DU_SCF_TEMPATE_PATH}
    ...    local_scf_path=${SUITE_LOG_PATH}    cu_timeout=${cu_timeout}    du_timeout=${du_timeout}
    ...    is_pdl_checking_needed=${False}
    ...    ELSE    Run keywords    Connect to gnb coam via ssl    AND
    ...        COAM Commission with scf file    scf_file_path=${scf_file_path_for_restore}    timeout=${classical_timeout}
    ...    is_pdl_checking_needed=${False}

Download SCF file to log path
    [Documentation]    Author: Wang Yixiang
    ...     Downlaod scf file to log path, it's useful for mannual rerun test case
    [Arguments]    ${connection}=GNB_OAM    ${config_type}=configuration    ${local_dir}=${TS_CASE_LOG_PATH}
    ...    ${gnb_index}=0        ${extended_name}=${NONE}
    ${current_time}    DateTime.Get Current Date    result_format=%Y%m%d%H%M%S%f
    ${scf_file_path}     set variable if  '${extended_name}' == '${NONE}'
    ...        ${local_dir}/SCF_mannual_commission_caseSetup_du_${current_time}.xml
    ...        ${local_dir}/SCF_mannual_caseSetup_du_${extended_name}_${current_time}.xml
    coam.collect_scf    target_file_name=${scf_file_path}    export_type=${config_type}
    ...    timeout=30    connection=${connection}
    ${has_cbts}    testline_info.has_cloudBts    ${tl}
    run keyword if    ${has_cbts}    _Download SCF file to log path CU    current_time=${current_time}
    ...    gnb_index=${gnb_index}    local_dir=${local_dir}


_Download SCF file to log path CU
    [Documentation]    author: Wang Yixiang
    ...    download cu scf file
    [Arguments]     ${current_time}    ${gnb_index}=0    ${local_dir}=${TS_CASE_LOG_PATH}
    ${cu_scf_file_path}     Set Variable    ${local_dir}/SCF_mannual_commission_cu_${current_time}.xml
    CU Login    ${gnb_index}
    cu.get_current_plan_file    path=${cu_scf_file_path}    timeout=60
    [Teardown]  run keyword and continue on failure    CU Logout

Clear unuseful log in teardown
    [Documentation]    author: Wang Yixiang
    ...    Clear unuseful log in teardown
    ...    log_path can be ${TS_CASE_LOG_PATH} or ${SUITE_LOG_PATH}
    [Arguments]     ${log_path}=${TS_CASE_LOG_PATH}    ${is_called_in_test_case_level}=${True}
    ${pattern}    create list    scf_classical_\\d{2,}.*xml    scf_du_\\d{2,}.*xml    scf_cu_\\d{2,}.*xml    update_\\d+.*json
    delete_unuseful_file_py    file_path=${log_path}    pattern=${pattern}
    ${pattern_pdml}    create list    .*\\.pdml
    ${status}    Set variable if    ${is_called_in_test_case_level}    ${TEST STATUS}    ${SUITE STATUS}
    Run keyword if    '${status}' == 'PASS'    delete_unuseful_file_py    file_path=${log_path}    pattern=${pattern_pdml}

Get file path for ute cloud
    [Documentation]    author: Wang Yixiang
    ...    ${ute_cloud_flag}    Get Variable Value    ${CONFIGURATION}
    ...    run keyword if    '${ute_cloud_flag}' != '${None}'    ute cloud env.
    [Arguments]     ${template_path}

    ${file_path}    ${file_name}    Split Path     ${template_path}
    ${template_path}    set variable    ${WORKSPACE_DIR}/commissionings/HGZ/${testline_name}/${file_name}
    [Return]    ${template_path}

Set variables for UTE cloud
    [Documentation]    author: Wang Yixiang
    ...    set global variable for test
    ${IS_UTE_ENV}    run keyword and return status    run keywords
    ...    Variable Should Exist    ${CONFIGURATION}    AND    Variable Should Exist    ${ENB_BUILD}
    ${testline_name}   run keyword if    ${IS_UTE_ENV}    String.Fetch From Right    string=${CONFIGURATION}    marker=.
    ...           ELSE    set variable     ${testline_name}
    ${WORKSPACE_DIR}    Fetch From Left     ${CURDIR}    /testsuite
    set suite variable    ${IS_UTE_ENV}
    set suite variable    ${WORKSPACE_DIR}
    set suite variable    ${testline_name}

Download SCF file and return with file path
    [Documentation]    Author: Ding Binmei
    ...    export_type: configuration, configurationAndRuntimeObjects, runtimeObjects
    [Arguments]    ${extended_name}=${None}    ${connection}=GNB_OAM    ${local_dir}=${TS_CASE_LOG_PATH}
    ...    ${export_type}=configuration
    ${current_time}    DateTime.Get Current Date    result_format=%Y%m%d%H%M%S%f
    ${file_name}     set variable if  '${extended_name}' == '${None}'
    ...        SCF_backup_${current_time}.xml
    ...        SCF_backup_${extended_name}_${current_time}.xml
    ${backup_scf_file_path}    coam.get_current_scf_file    local_dir_path=${local_dir}    file_name=${file_name}
    ...    timeout=30    connection=${connection}    export_type=${export_type}
    [Return]    ${backup_scf_file_path}
