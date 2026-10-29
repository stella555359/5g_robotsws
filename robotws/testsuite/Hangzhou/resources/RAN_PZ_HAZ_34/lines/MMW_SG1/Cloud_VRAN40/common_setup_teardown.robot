*** Settings ***
Documentation
...   This is for common setup and teardown keywords for cloud BTS

Library    taf.config.scf    WITH NAME    scf
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/lib/scf_process.py
Library     scf_process.SCFProcess    WITH NAME    scfpro
Library    String
Library    Collections
Library    OperatingSystem
Library    DateTime
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/lib/string_list.py
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/Cloud_VRAN40/python/cloud_online_modify.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/Cloud_VRAN40/vCU.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/Cloud_VRAN40/vDU.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/Cloud_VRAN40/AiC_l3call.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/Cloud_VRAN40/AiC_log_Collect.robot

*** Variables ***
&{EMPTY_DICT}
@{EMPTY_LIST}
${TS_LOG_PATH_BASE}      ${OUTPUT DIR}/Case_Logs
@{LIST_DU_CONNECTION}    OAM_gnb0_du0
${CLOUD_COMMISSION_ONAIR_TIMEOUT}      15min
${CLOUD_CU_COMMISSION_ONAIR_TIMEOUT}      15min
${CLOUD_DU_COMMISSION_ONAIR_TIMEOUT}      20min
${CU_CONNECTION}         OAM_CU0
@{LIST_DU_INDEX_0}         ${0}
${IS_LOG_CAPTURED_CASE_LEVEL}                       ${True}              # Flag used to define whether snapshot/ bts logs are needed in case teardown
${HAS_CASE_FAILED}           ${False}    # Flag for monitoring if case has failed in a test suite. Will update in test case teardown if failed
@{VCU_UNEXPECTED_ACTIVE_ALARMS}    10    16    1806    1868    4341    4352    4383    4350    4592    4539    4527    6450
@{VDU_UNEXPECTED_ACTIVE_ALARMS}    @{VCU_UNEXPECTED_ACTIVE_ALARMS}


*** Keywords ***
_Main Functions for search
    Get updated SCF file path after modify
    Commission on BTS with cu du modify
    Aic Check CU and DUs Onair
    Online modify on cu du
    Aic Suite common setup preparation
    Aic Suite teardown
    Aic Common case setup
    Aic Common case teardown
    Aic Collect CU And DU Logs in teardown
    ###### Alarm check ###########
    Get fault id list on CU from active alarm list
    Get fault id list on DU from active alarm list
    Verify for active alarms in case teardown

_Cloud Generate suite log path
    [Documentation]    Author: Ding Binmei [PRIVATE]
    ...                Description: Create log directory with test suite level and open a common variable ${SUITE_LOG_PATH}
    [Arguments]    ${timeout}=1min
    ${ts_name}=    Replace String    string=${SUITE NAME}    search_for=${SPACE}    replace_with=_
    wait until keyword succeeds    ${timeout}    2sec    Connect to vdu via rest api
    ${sw_version} =     vDU.Get vDU Version via rest api
    ${suite_log_path}    Join path    ${TS_LOG_PATH_BASE}    ${sw_version}    TS_${ts_name}
    Set Suite Variable    ${SUITE_LOG_PATH}    ${suite_log_path}
    Create directory    ${SUITE_LOG_PATH}
    [Teardown]    Run keyword and ignore error    Teardown vdu connection

_Cloud Generate test case log path
    [Documentation]    Author: Ding Binmei  [PRIVATE]
    ...                Description: Create log directory with test case level and open a common variable ${TS_CASE_LOG_PATH}
    ...                This keyword should be executed after Generate suite log path
    ${tc_name}=    Replace String    string=${TEST NAME}    search_for=${SPACE}    replace_with=_
    ${case_log_path}    Join path    ${SUITE_LOG_PATH}    TC_${tc_name}
    Set test variable    ${TS_CASE_LOG_PATH}    ${case_log_path}
    Create directory    ${TS_CASE_LOG_PATH}

Create log directory on cloud
    [Documentation]    Author: Ding Binmei
    ...                Description: Open a common variable  ${SUITE_LOG_PATH}/ ${TS_CASE_LOG_PATH} and also create test case log path
    ...                This keyword can be executed both on suite setup and test setup; Default to use this keyword in test case setup
    ...                ${is_set_to_test_case_level}: Value can be ${True} or ${False};
    ...                  If set to ${True}, test case log path will set to test case name level;
    ...                  Otherwise, case log will set to test suite level
    ...                 ${LOG_PATH} is required in common keyword coam_parameter.py
    [Arguments]  ${is_set_to_test_case_level}=${True}    ${timeout}=1min
    _Cloud Generate suite log path    timeout=${timeout}
    Run keyword if  ${is_set_to_test_case_level}
    ...    Run keywords    _Cloud Generate test case log path    AND
    ...    Set test variable    ${LOG_PATH}    ${TS_CASE_LOG_PATH}
    ...    ELSE    Set suite variable    ${LOG_PATH}    ${SUITE_LOG_PATH}

_Get_scf_file_name_with_timestamp_added
    [Documentation]  Author: Ding Binmei
    ...    will return file name with _${timestamp}_updated.xml added
    [Arguments]    ${scf_file_path}
    ${scf_file_name}    Fetch from right    ${scf_file_path}    /
    ${file_name_without_extention}    String.Replace string    ${scf_file_name}    .xml    ${EMPTY}
    ${timestamp}    DateTime.Get current date    result_format=%Y%m%d%H%M%S
    ${scf_file_name_after_modify}    catenate  SEPARATOR=${EMPTY}    ${file_name_without_extention}    _${timestamp}_updated.xml
    [Return]  ${scf_file_name_after_modify}

Get updated SCF file path after modify
    [Documentation]  Author: Ding Binmei
    ...    scf_file_path: if None, then skip the SCF process. Return ${None}
    ...    dict_params_modify:
    ...      --if leave it as empty, then skip the SCF process.
    ...        1. copy scf template file to case/suite level folder.
    ...        2. Return file path in case/suite level
    ...      --if would like to update something, then input format should be in dict. as: {'param_to_del':[], 'param_to_upd':[], 'param_to_add':[]}
    ...          paramaeter update format follow guide in scf_process
    ...    is_called_in_test_case_level: False/True.
    ...      --if False, then SCF file will be stored in suite log folder
    ...      --if True, then SCF file will be stored in case log folder
    ...    Return: file path after scf modify
    [Arguments]    ${scf_file_path}    ${dict_params_modify}=&{EMPTY_DICT}    ${is_called_in_test_case_level}=${False}
    Run keyword if    '${scf_file_path}'=='${None}'    Log to console    scf_file_path is none. Skilp SCF process and return with None
    Return from keyword if    '${scf_file_path}'=='${None}'    ${None}

    ${local_log_file_folder}    set variable if  ${is_called_in_test_case_level}==${True}    ${TS_CASE_LOG_PATH}    ${SUITE_LOG_PATH}
    ${default_scf_file_path}    OperatingSystem.Copy file    source=${scf_file_path}    destination=${local_log_file_folder}
    ${len_dict_params_modify}    Get length    ${dict_params_modify}
    Run keyword if    ${len_dict_params_modify}==0
    ...    Log to console    No prameter update is needed. Skip the SCF process. And return with default scf file path
    Return from keyword if    ${len_dict_params_modify}==0    ${default_scf_file_path}

    ${dict_params_modify_type}    get_dictionary_keys    ${dict_params_modify}
    ${params_to_del}    set variable if    'param_to_del' in @{dict_params_modify_type}    ${dict_params_modify['param_to_del']}
    ...    ${None}
    ${params_to_upd}    set variable if    'param_to_upd' in @{dict_params_modify_type}    ${dict_params_modify['param_to_upd']}
    ...    ${None}
    ${params_to_add}    set variable if    'param_to_add' in @{dict_params_modify_type}    ${dict_params_modify['param_to_add']}
    ...    ${None}
    ${scf_file_name_after_modify}    _Get_scf_file_name_with_timestamp_added    scf_file_path=${scf_file_path}
    ${scf_file_path_after_modify}    scfpro.SCFProcess    scf_template_path=${scf_file_path}
    ...    scf_process_folder=${local_log_file_folder}    list_para_to_delete=${params_to_del}    list_para_to_modify=${params_to_upd}
    ...    list_para_to_add=${params_to_add}    scf_file_name_after_process=${scf_file_name_after_modify}
    Log to console    Finish SCF process, new scf file path: ${scf_file_path_after_modify}
    [Return]  ${scf_file_path_after_modify}

Commission on BTS with cu du modify
    [Documentation]  Author: Ding Binmei
    ...    ${cu_dict_params_modify}:
    ...      --if leave it as empty, then skip the SCF process.
    ...        1. copy scf template file to case/suite level folder.
    ...        2. Return file path in case/suite level
    ...      --if would like to update something, then input format should be in dict. as: {'param_to_del':[], 'param_to_upd':[], 'param_to_add':[]}
    ...          paramaeter update format follow guide in scf_process
    ...    ${du_scf_params_modify_list}: Extend to support list. [{VDU0}, ${None}], if not going to modify for du, then set as ${None}
    ...    ${cu_scf_file_path}: if None, then skip the SCF process and commission on CU/DU part
    ...    ${du_index_list}: support str/list type. 0 or 0,1
    ...    ${du_scf_file_path_list}: Extend to support list type. [${None},${None}], length should be align with du_index_list
    ...    is_called_in_test_case_level: False/True.
    ...      --if False, then SCF file will be stored in suite log folder
    ...      --if True, then SCF file will be stored in case log folder
    ...    timeout_commission: Timeout for waiting for SCF activation
    [Arguments]  ${cu_dict_params_modify}=&{EMPTY_DICT}    ${cu_scf_file_path}=${None}    ${gnb_index}=0
    ...    ${du_scf_params_modify_list}=@{EMPTY_LIST}    ${du_scf_file_path_list}=${EMPTY_LIST}    ${du_index_list}=${LIST_DU_INDEX_0}
    ...    ${is_called_in_test_case_level}=${False}    ${timeout_commission}=10 min
    ${cu_connection}    ${du_connection_list}    Create CU And DU Connections   gnb_index=${gnb_index}   du_index_list=${du_index_list}
    ${cu_scf_file_path_after_modify}     Get updated SCF file path after modify    scf_file_path=${cu_scf_file_path}
    ...    dict_params_modify=${cu_dict_params_modify}    is_called_in_test_case_level=${is_called_in_test_case_level}

    Run keyword if    '${cu_scf_file_path_after_modify}'!='${None}'
    ...    vCU.Commission on vcu    cu_scf_file_path=${cu_scf_file_path_after_modify}    connection=${cu_connection}
    ...        timeout_commission=${timeout_commission}
    ...    ELSE    Log to console    CU commission is skipped since cu_scf_file_path is None
    ${du_index_list}    string_list.string2list    ${du_index_list}
    ${len_du_index_list}    Get length    ${du_index_list}
    ${len_du_scf_file_path_list}    Get length    ${du_scf_file_path_list}
    Run keyword if    ${len_du_scf_file_path_list}!=0
    ...    Should be equal as integers    ${len_du_index_list}    ${len_du_scf_file_path_list}
    ...        msg=du scf file number should be same with du index number
    ${len_du_scf_params_modify_list}    Get length    ${du_scf_params_modify_list}
    Should be equal as integers    ${len_du_scf_params_modify_list}    ${len_du_scf_file_path_list}
    ...    msg=provided parameters should be align with du scf file numbers

    FOR    ${index}    ${du_index}    IN ENUMERATE    @{du_index_list}
        Run keyword if    ${len_du_scf_file_path_list}==0    Log to console    No du scf provided, skip the commission
        Exit for loop if    ${len_du_scf_file_path_list}==0
        Log to console    Start commission for DU: ${du_index}
        ${du_connection}    Set variable    ${du_connection_list[${index}]}
        _get scf and do commission for each du    du_connection=${du_connection}    du_scf_file_path=${du_scf_file_path_list[${index}]}
        ...    du_dict_params_modify=${du_scf_params_modify_list[${index}]}    is_called_in_test_case_level=${is_called_in_test_case_level}
        ...    timeout_commission=${timeout_commission}
    END
    [Teardown]  Run keyword and ignore error    Aic Close all connection    gnb_index=${gnb_index}    du_index_list=${du_index_list}

Aic Check CU and DUs Onair
    [Timeout]  15 min
    [Documentation]    author: Dandan Fang
    ...   check cu and du onair
    [Arguments]
    ...    ${gnb_index}=${0}      ${du_index_list}=${LIST_DU_INDEX_0}
    ...    ${cu_status_check_timeout}=${CLOUD_CU_COMMISSION_ONAIR_TIMEOUT}    ${du_status_check_timeout}=${CLOUD_DU_COMMISSION_ONAIR_TIMEOUT}
    ...    ${status_check_interval}=10s    ${NSA_SA}=SA
    ${cu_connection}    set variable     OAM_CU${gnb_index}
    Run keyword and continue on failure    wait until keyword succeeds    ${cu_status_check_timeout}    ${status_check_interval}
    ...    Connect to vcu via rest api    gnb_index=${gnb_index}    connection=${cu_connection}
    Run keyword and continue on failure    wait until keyword succeeds    ${cu_status_check_timeout}    ${status_check_interval}
    ...    Check vnfc status are as expected on vcu    connection=${cu_connection}
    FOR    ${du_index}    IN    @{du_index_list}
        ${du_connection}    set variable     OAM_gnb${gnb_index}_du${du_index}
        Run keyword and continue on failure    wait until keyword succeeds    ${du_status_check_timeout}    ${status_check_interval}
        ...    Connect to vdu via rest api    gnb_index=${gnb_index}    du_index=${du_index}    connection=${du_connection}
        Run keyword and continue on failure    wait until keyword succeeds    ${du_status_check_timeout}    ${status_check_interval}
        ...    Check vnfc status are as expected on vdu    connection=${du_connection}
        Run keyword and continue on failure    wait until keyword succeeds    ${du_status_check_timeout}    ${status_check_interval}
        ...    Check RU status on vdu    connection=${du_connection}
    END
    Run keyword and continue on failure    wait until keyword succeeds    ${cu_status_check_timeout}    ${status_check_interval}
    ...    Check F1 link is up on vcu    connection=${cu_connection}
    Run keyword and continue on failure    wait until keyword succeeds    ${cu_status_check_timeout}    ${status_check_interval}
    ...    Check all cells are on cell on air status on vcu    connection=${cu_connection}
    FOR    ${du_index}    IN    @{du_index_list}
        ${du_connection}    set variable     OAM_gnb${gnb_index}_du${du_index}
        Run keyword and continue on failure    wait until keyword succeeds    ${du_status_check_timeout}    ${status_check_interval}
        ...    Check all cells are on cell on air status on vdu    connection=${du_connection}
    END
    run keyword if    '${NSA_SA}'=='NSA'    Run keyword and continue on failure
    ...    wait until keyword succeeds    ${cu_status_check_timeout}    ${status_check_interval}
    ...    Check X2 status on vcu    connection=${cu_connection}

_get scf and do commission for each du
    [Arguments]  ${du_connection}  ${du_scf_file_path}   ${du_dict_params_modify}    ${is_called_in_test_case_level}
    ...   ${timeout_commission}
    ${du_scf_file_path_after_modify}    Get updated SCF file path after modify    scf_file_path=${du_scf_file_path}
    ...    dict_params_modify=${du_dict_params_modify}    is_called_in_test_case_level=${is_called_in_test_case_level}
    Run keyword if    '${du_scf_file_path_after_modify}'!='${None}'
    ...    vDU.Commission on vdu    du_scf_file_path=${du_scf_file_path_after_modify}    connection=${du_connection}
    ...        timeout_commission=${timeout_commission}
    ...    ELSE    Log to console    DU commission is skipped since cu_scf_file_path is None

Aic Suite common setup preparation
    [Documentation]    author: Dandan Fang
    ...       cu_dict_params_modify :
    ...       Format :    create dictionary  param_to_del=${CU_SCF_DELETE}     param_to_upd=${CU_SCF_MODIFY}    param_to_add=${CU_SCF_ADD}
    ...       du_scf_params_modify_list:
    ...       PA_MAX_SUPPORTED_VALUE: Should be defined in init file under commission
    ...       Format :   du0 - [&{du_dict_params_modify}],du_dict_params_modify format like cu_dict_params_modify
    ...       Parameters  pa_values_mapping: if atten defined, please set it when call "Aic Suite common setup preparation"
    [Timeout]  30 min
    [Arguments]
    # cloud testline commission
    ...    ${cu_dict_params_modify}=&{EMPTY_DICT}    ${cu_scf_file_path}=${None}
    ...    ${cu_status_check_timeout}=${CLOUD_CU_COMMISSION_ONAIR_TIMEOUT}
    ...    ${du_scf_params_modify_list}=${EMPTY_LIST}    ${du_scf_file_path_list}=${EMPTY_LIST}
    ...    ${gnb_index}=${0}      ${du_index_list}=${LIST_DU_INDEX_0}    ${du_status_check_timeout}=${CLOUD_DU_COMMISSION_ONAIR_TIMEOUT}
    ...    ${status_check_interval}=5s
    ...    ${timeout_commission}=10 min
    # PA Related
    ...    ${pa_values_mapping}=${None}    ${attenuator_out_ports}=${PA_OUT_PORTS}
    ...    ${attenuator_rows}=${PA_ROWS}    ${attenuator_max_column_num}=${PA_MAX_COLUMN_NUM}
    ...    ${if_change_ENB_PA}=${False}    ${NSA_SA}=SA
    # UE Related
    ...    ${is_prepare_ue_needed}=${True}    ${detach_request}=${true}    ${ue_index}=${0}

    ${du_index_list}=         Convert data type to a list     input_data=${du_index_list}
    Create log directory on cloud    is_set_to_test_case_level=${False}
    ${UE_status}    run keyword and return status    ue.translate_power_ue_type_from_testline    ue_index=${ue_index}
    ${UE_TYPE}   run keyword if   ${UE_status}   ue.translate_power_ue_type_from_testline    ue_index=${ue_index}
    run keyword if   ${UE_status}    set suite variable    ${UE_TYPE}

    Commission on BTS with cu du modify
    ...   cu_dict_params_modify=${cu_dict_params_modify}   cu_scf_file_path=${cu_scf_file_path}
    ...   du_scf_params_modify_list=${du_scf_params_modify_list}   du_scf_file_path_list=${du_scf_file_path_list}    du_index_list=${du_index_list}
    ...   gnb_index=${gnb_index}      is_called_in_test_case_level=${False}     timeout_commission=${timeout_commission}
    Aic Check CU and DUs Onair   gnb_index=${gnb_index}    du_index_list=${du_index_list}
    ...   cu_status_check_timeout=${cu_status_check_timeout}     du_status_check_timeout=${du_status_check_timeout}
    ...  status_check_interval=${status_check_interval}

    _Get Cell Mapping Info For CU And Set As Global    cu_conn=OAM_CU${gnb_index}

    Run keyword if   ${is_prepare_ue_needed}    power_ue.Prepare UE    ue_type=${UE_TYPE}    ue_index=${ue_index}
    Run keyword if   ${detach_request}    power_ue.UE Detach   ue_type=${UE_TYPE}    ue_index=${ue_index}

    Run keyword if    "${tl.attenuators}"!="[None]" and "${attenuator_out_ports}"!="None"
    ...    run keyword and ignore error    Block whole attenuator ports for testline    attenuator_out_ports=${attenuator_out_ports}
    ...        attenuator_rows=${attenuator_rows}    attenuator_max_column_num=${attenuator_max_column_num}
    Run keyword if    "${tl.attenuators}"!="[None]" and "${pa_values_mapping}"!="None"
    ...    Initialize attenuator values for testline    if_change_ENB_PA=${if_change_ENB_PA}    NSA_SA=${NSA_SA}
    ...    pa_values_mapping=${pa_values_mapping}

_Get Cell Mapping Info For CU And Set As Global
    [Documentation]    author: Dandan Fang
    ...    ${NR_CELL_ID_MAPPING} as global variable, is align with classical, cloud set it from cu
    [Arguments]
    ...      ${cu_conn}=OAM_CU0
    ${NR_CELL_ID_MAPPING}=    cloud_gnb.get_relation_mapping_between_cell_and_others_from_cu    connection=${cu_conn}
    Set suite variable    ${NR_CELL_ID_MAPPING}

Online modify on cu du
    [Documentation]  Author: Ding Binmei
    ...    ${cu_params_modify_dict}: Should be in format as bellow:
    ...        {'param_to_upd': [{'dist_name': 'MRBTS-413/NRBTS-11171/NRCELL-1', 'parameter': 'actCDrx', 'value': 'true')}],
    ...        'param_to_add': [{'dist_name': 'MRBTS-37241/NRBTS-37241/NRCELL-1','parameter': 'drxProfile2',  'value': [{'drxLongCycle':'20ms'}]}],
    ...        'object_to_add': [{'dist_name': dist_name_nradj, 'parameter': 'cellDepType', 'value': 'SA'},
    ...                        {'dist_name': dist_name_nradj, 'parameter': 'cellReservedForOperatorUse', 'value': 'notReserved'}],
    ...        'param_to_del': [dict(dist_name='MRBTS-37241/NRBTS-37241/NRDU-1/NRECPRI-1', parameter='uPlanePcp')],
    ...            Note: delete list type parameter(like drxProfile2) is not supported by this method in cloud
    ...        'object_to_del': [dict(dist_name= 'MRBTS-37241/NRBTS-37241/NRADJNRCELL-1')]}
    ...    ${du_params_modify_list}: Shoule be a list to support multiple DU updates. format as bellow:
    ...        [{param_to_upd:[updates for vdu1]},{param_to_upd:[updates for vdu2]}]
    ...    ${du_connections_list}: Should be a list and connection should match with ${du_params_modify_list}

    [Arguments]    ${cu_params_modify_dict}=&{EMPTY_DICT}    ${du_params_modify_list}=@{EMPTY_LIST}    ${gnb_index}=${0}
    ...    ${du_index_list}=@{LIST_DU_INDEX_0}    ${timeout}=300
    ${cu_connection}    ${du_connection_list}    _Create CU And DUs Alias   gnb_index=${gnb_index}   du_index_list=${du_index_list}
    Run keyword if    ${cu_params_modify_dict}
    ...    online_nidd_process.online_modify_nidd_parameters_via_restapi    params_modify_dict=${cu_params_modify_dict}
    ...        connection=${cu_connection}    timeout=${timeout}    bts_type=cu
    ...    ELSE    Log to console    No need to do online modification for CU
    Run keyword if    ${du_params_modify_list}
    ...    _online modify for dus    du_params_modify_list=${du_params_modify_list}    du_connections_list=${du_connection_list}
    ...        timeout=${timeout}
    ...    ELSE    Log to console    No need to do online modification for DU

Aic Suite teardown
    [Documentation]    author: Dandan Fang
    ...    2024-4-16 Ding Binmei: optimize for log capturing in suite teardown
    ...    ${is_log_required}: ${True}/${False}
    ...        If set to ${True} will force to capture log in suite teardown
    ...        If set to ${False}, then decide by flag ${HAS_CASE_FAILED}: if case has failed, then capture log;
    ...        ${HAS_CASE_FAILED} will be updated to ${True} in case teardown if case status failed
    [Arguments]      ${is_log_required}=${False}  ${gnb_index}=${0}  ${du_index_list}=${LIST_DU_INDEX_0}
    ...    ${is_called_in_test_case_level}=${False}
    ...    ${pa_values_mapping}=${INIT_PA_F_T}
    Verify for active alarms in case teardown     list_cu_active_fault_id_setup=${None}    dict_vdu_active_fault_id_setup=${None}
    ...    gnb_index=${gnb_index}    du_index_list=${du_index_list}
    Run Keyword And Ignore Error   robot_common_operations.Common Suite Teardown     #not available to cloud
    # Collect btslog, snapshot, alarm logs in teardown
    run keyword if    ${is_log_required} or ${HAS_CASE_FAILED}==${False}    Aic Collect CU And DU Logs in teardown
    ...    gnb_index=${gnb_index}   is_called_in_test_case_level=${is_called_in_test_case_level}
    ...    du_index_list=${du_index_list}

    run keyword and ignore error    Aic Download SCF file to log path
    ...          gnb_index=${gnb_index}   du_index_list=${du_index_list}
    ...          is_called_in_test_case_level=${False}   scf_name_suffix=suite_teardown

    ${cu_connection}    ${du_connection_list}    Create CU And DU Connections        gnb_index=${gnb_index}   du_index_list=${du_index_list}
    FOR    ${index}    ${du_connection}    IN ENUMERATE    @{du_connection_list}
        Change status for parameter cellBarred on GNB DU   exp_status=notBarred   list_cell_ids=all
    ...        gnb_index=${gnb_index}   du_index=${du_index_list[${index}]}    connection=${du_connection}
    END
    run keyword and ignore error    Aic Close all connection  gnb_index=${gnb_index}   du_index_list=${du_index_list}
    run keyword   Clear unuseful log in teardown    log_path=${SUITE_LOG_PATH}
    ...      is_called_in_test_case_level=${is_called_in_test_case_level}


    Run keyword if    "${tl.attenuators}"!="[None]" and "${pa_values_mapping}"!="None"
    ...    Initialize attenuator values for testline
    ...    pa_values_mapping=${pa_values_mapping}

Aic Common case setup
    [Documentation]    author: Dandan Fang,   logic follow classical
    ...    1. Create case log path:${TS_CASE_LOG_PATH}
    ...    2. Wait cell ready
    ...    3. if ${cu_scf_dict_params_modify}!=${None} means modify cloud CU NIDD via SCF
    ...    4. if ${du_scf_params_modify_list}!=${None} means modify cloud DU NIDD via SCF
    ...    5. if ${cu_params_modify_dict_via_api}!=${None} means modify cloud CU NIDD via rest api
    ...    6. if ${du_params_modify_via_api_list}!=${None} means modify cloud DU NIDD via rest api
    ...    ${allowed_faults_ids}: Refer to the extra faults to be ignored in case.
    ...        -- Input format must be string, for example: 6450,4350
    ...        -- If None, then will only ignore alarms in CI's white list
    [Timeout]  30 min
    [Arguments]
    # parameter for SCF commission
    ...    ${gnb_index}=${0}   ${du_index_list}=${LIST_DU_INDEX_0}
    ...    ${du_params_modify_via_api_list}=@{EMPTY_LIST}   ${cu_params_modify_dict_via_api}=&{EMPTY_DICT}
    ...    ${cu_scf_dict_params_modify}=&{EMPTY_DICT}    ${cu_scf_file_path}=${None}
    ...    ${du_scf_params_modify_list}=${EMPTY_LIST}    ${du_scf_file_path_list}=${EMPTY_LIST}    ${timeout_commission}=10 min
    ...    ${cu_status_check_timeout}=${CLOUD_CU_COMMISSION_ONAIR_TIMEOUT}    ${du_status_check_timeout}=${CLOUD_DU_COMMISSION_ONAIR_TIMEOUT}
    ...    ${status_check_interval}=5s
    ...    ${is_scf_backup_needed}=${False}
    ...    ${pa_values_mapping}=${None}    ${if_change_ENB_PA}=${False}    ${NSA_SA}=SA
    ...    ${fail_with_alarms}=${True}    ${allowed_faults_ids}=${None}
    ...    &{kwargs}

    #no matter ute cloud or lightweight, need to call following KW, report configuration ID
    Run Keyword And Ignore Error     robot_common_operations.Common Case Setup
    ...    allowed_faults_ids=${allowed_faults_ids}    fail_with_alarms=${fail_with_alarms}
    Add list of allowed alarms    allowed_faults_ids=7504,7505,4405,4681

    Create log directory on cloud     is_set_to_test_case_level=${True}
    ${du_index_list}=         Convert data type to a list     input_data=${du_index_list}
    Commission on BTS with cu du modify
    ...   cu_dict_params_modify=${cu_scf_dict_params_modify}   cu_scf_file_path=${cu_scf_file_path}
    ...   du_scf_params_modify_list=${du_scf_params_modify_list}   du_scf_file_path_list=${du_scf_file_path_list}    du_index_list=${du_index_list}
    ...   gnb_index=${gnb_index}      is_called_in_test_case_level=${True}     timeout_commission=${timeout_commission}
    Aic Check CU and DUs Onair   gnb_index=${gnb_index}    du_index_list=${du_index_list}
    ...   cu_status_check_timeout=${cu_status_check_timeout}     du_status_check_timeout=${du_status_check_timeout}
    ...  status_check_interval=${status_check_interval}    NSA_SA=${NSA_SA}
    run keyword if    ${cu_params_modify_dict_via_api} or ${du_params_modify_via_api_list}    run keywords
    ...    Online modify on cu du    cu_params_modify_dict=${cu_params_modify_dict_via_api}
    ...        du_params_modify_list=${du_params_modify_via_api_list}   gnb_index=${gnb_index}
    ...        du_index_list=${du_index_list}    AND
    ...    Aic Check CU and DUs Onair   gnb_index=${gnb_index}    du_index_list=${du_index_list}
    ...        cu_status_check_timeout=${cu_status_check_timeout}     du_status_check_timeout=${du_status_check_timeout}
    ...        status_check_interval=${status_check_interval}    NSA_SA=${NSA_SA}
    Remove list of allowed alarms    allowed_faults_ids=7504,7505,4405,4681
    run keyword if   "${allowed_faults_ids}"!="${None}"
    ...    Add list of allowed alarms    allowed_faults_ids=${allowed_faults_ids}

    # download SCF file to log path for mannual rerun or mannual debug issue
    Run keyword if   ${is_scf_backup_needed}
    ...    Aic Download SCF file to log path   gnb_index=${gnb_index}    du_index_list=${du_index_list}
    ...    is_called_in_test_case_level=${True}     scf_name_suffix=case_setup

    Run keyword if    "${tl.attenuators}"!="[None]" and "${pa_values_mapping}"!="None"
    ...    Run Keyword And Ignore Error    Initialize attenuator values for testline    if_change_ENB_PA=${if_change_ENB_PA}    NSA_SA=${NSA_SA}
    ...    pa_values_mapping=${pa_values_mapping}
    ${LIST_CU_ACTIVE_FAULT_ID_SETUP}    Get fault id list on CU from active alarm list    gnb_index=${gnb_index}    du_index_list=${du_index_list}
    ${DICT_VDU_ACTIVE_FAULT_ID_SETUP}    Get fault id list on DU from active alarm list    gnb_index=${gnb_index}    du_index_list=${du_index_list}
    Set test variable    ${LIST_CU_ACTIVE_FAULT_ID_SETUP}
    Set test variable    ${DICT_VDU_ACTIVE_FAULT_ID_SETUP}
    Create CU And DU Connections   gnb_index=${gnb_index}   du_index_list=${du_index_list}

Aic Common case teardown
    [Documentation]    Author: Dandan Fang   Common case teardown
    ...    1. If ${detach_ue}!=${False}, close iperf progress, detach UE
    ...    2. If ${is_onair_check}!=${False}, check cell onair status
    ...    3. cu_status_check_timeout, du_status_check_timeout -recheck cell onair normal or not after case ended. if timeout is small,
    ...       please define specific value to meet your requirement.
    [Arguments]    ${is_log_required}=${IS_LOG_CAPTURED_CASE_LEVEL}
    ...    ${ue_index}=${0}    ${detach_ue}=${True}
    ...    ${gnb_index}=${0}      ${du_index_list}=${LIST_DU_INDEX_0}
    ...    ${is_onair_check}=${True}
    ...    ${is_need_to_clear_unused_logs}=${True}
    ...    ${pa_values_mapping}=${None}
    ...    ${cu_status_check_timeout}=2min
    ...    ${du_status_check_timeout}=2min
    ${LIST_CU_ACTIVE_FAULT_ID_SETUP}    Get variable value    ${LIST_CU_ACTIVE_FAULT_ID_SETUP}
    ${DICT_VDU_ACTIVE_FAULT_ID_SETUP}    Get variable value    ${DICT_VDU_ACTIVE_FAULT_ID_SETUP}
    Verify for active alarms in case teardown     list_cu_active_fault_id_setup=${LIST_CU_ACTIVE_FAULT_ID_SETUP}
    ...    dict_vdu_active_fault_id_setup=${DICT_VDU_ACTIVE_FAULT_ID_SETUP}    gnb_index=${gnb_index}    du_index_list=${du_index_list}
    Run Keyword And Ignore Error    robot_common_operations.Common Case Teardown
    Run keyword if    "${TEST STATUS}"=="FAIL"    Set suite variable    ${HAS_CASE_FAILED}    ${True}
    run keyword and ignore error    Aic Download SCF file to log path
    ...          gnb_index=${gnb_index}   du_index_list=${du_index_list}
    ...          is_called_in_test_case_level=${True}   scf_name_suffix=case_teardown

    # Close iperf and detach UE-follow classical
    run keyword if    ${detach_ue}    run keyword and ignore error    Stop data transfer based on direction
    run keyword if    ${detach_ue}    run keyword and ignore error    power_ue.UE Detach    ue_type=${UE_TYPE}    ue_index=${ue_index}
    run keyword if    ${detach_ue}    run keywords
    ...    run keyword and ignore error    Get Commercial UE IP    ue_index=${ue_index}    AND
    ...    run keyword and ignore error    log to console    UE IP captured after the case is ${UE_IP}

    # Collect btslog, snapshot, alarm logs in teardown
    run keyword if    ${is_log_required}    run keyword and ignore error       Aic Collect CU And DU Logs in teardown
    ...    gnb_index=${gnb_index}    du_index_list=${du_index_list}
    ...    is_called_in_test_case_level=${True}

    Run keyword if    ${is_onair_check}
    ...    Run keywords    Run Keyword And Ignore Error   Aic Close all connection  gnb_index=${gnb_index}   du_index_list=${du_index_list}    AND
    ...    Aic Check CU and DUs Onair     gnb_index=${gnb_index}      du_index_list=${du_index_list}
    ...    cu_status_check_timeout=${cu_status_check_timeout}   du_status_check_timeout=${du_status_check_timeout}

    run keyword and ignore error    Aic Close all connection
    ...       gnb_index=${gnb_index}     du_index_list=${du_index_list}
    run keyword and ignore error    ssh.disconnect    connection=cpc_${ue_index}
    run keyword and ignore error    ssh.disconnect    connection=cygwin
    run keyword and ignore error    run keyword if    ${is_need_to_clear_unused_logs}
    ...    Clear unuseful log in teardown    log_path=${TS_CASE_LOG_PATH}   is_called_in_test_case_level=${True}

    Run keyword if    "${tl.attenuators}"!="[None]" and "${pa_values_mapping}"!="None"
    ...    Run Keyword And Ignore Error    Initialize attenuator values for testline
    ...    pa_values_mapping=${pa_values_mapping}
    # Should be called at the end of case teardown. Don't move, otherwise report data to powerBI will be failed
    CI_interface.Common Case Teardown

Aic Download SCF file to log path
    [Documentation]    Author: Dandan Fang
    ...     Downlaod scf file to log path, it's useful for mannual rerun test case
    [Arguments]    ${gnb_index}=${0}    ${du_index_list}=${LIST_DU_INDEX_0}    ${local_dir}=${SUITE_LOG_PATH}
    ...            ${is_called_in_test_case_level}=${False}
    ...            ${scf_name_suffix}=suite_setup
    ${local_dir}    Set variable if    ${is_called_in_test_case_level}    ${TS_CASE_LOG_PATH}    ${SUITE_LOG_PATH}
    ${current_time}    DateTime.Get Current Date    result_format=%Y%m%d%H%M%S%f
    vCU.Download vCU SCF file to Local   current_time=${current_time}    gnb_index=${gnb_index}   local_dir=${local_dir}
    ...      cu_scf_name=gnb_cu0_scf_${scf_name_suffix}

    FOR    ${index}    ${du_index}    IN ENUMERATE    @{du_index_list}
        Log to console    index:${index}, du_index:${du_index}
        vDU.Download vDU SCF file to Local   current_time=${current_time}
        ...       gnb_index=${gnb_index}     du_index=${du_index}
        ...       local_dir=${local_dir}    scf_name_suffix=${scf_name_suffix}
    END

Get fault id from alarm list
    [Documentation]    Author: Ding Binmei
    ...    param active_alarms: return data from CU/DU get_active_alarms / vdu_get_active_alarms
    ...    Return as a list like: ['6450', '10']
    [Arguments]    ${active_alarms}
    @{list_active_alarms}    Set variable    ${active_alarms['alarms']}
    @{list_fault_id}    Create list
    FOR    ${alarm}    IN    @{list_active_alarms}
        Append to list    ${list_fault_id}    ${alarm['fault_id']}
    END
    [Return]    ${list_fault_id}

Get active alarms on CU DU
    [Documentation]  Author: Ding Binmei
    [Arguments]    ${gnb_index}=${0}    ${du_index_list}=${LIST_DU_INDEX_0}
    ${cu_connection}    ${du_connection_list}    Create CU And DU Connections    gnb_index=${gnb_index}    du_index_list=${du_index_list}
    Run keyword and continue on failure    cu.get_active_alarms    connection=${cu_connection}
    Get active alarms on VDUs    du_connection_list=${du_connection_list}
    [Teardown]  Aic Close all connection    gnb_index=${gnb_index}   du_index_list=${du_index_list}

Get fault id list on CU from active alarm list
    [Documentation]  Author: Ding Binmei
    ...    Get fault id from CU.
    ...    Return as a list like: ['6450', '10']
    [Arguments]    ${gnb_index}=${0}    ${du_index_list}=${LIST_DU_INDEX_0}
    ${cu_connection}    ${du_connection_list}    Create CU And DU Connections    gnb_index=${gnb_index}    du_index_list=${du_index_list}
    ${cu_active_alarms}    cu.get_active_alarms    connection=${cu_connection}
    ${list_fault_id_cu}    Get fault id from alarm list    active_alarms=${cu_active_alarms}
    [Return]    ${list_fault_id_cu}
    [Teardown]  Aic Close all connection    gnb_index=${gnb_index}   du_index_list=${du_index_list}

Get fault id list on DU from active alarm list
    [Documentation]    Author: Ding Binmei
    ...    Get fault id from all DUs and return with fault id listed for each vDU.
    ...    Example output: {'OAM_gnb0_du0': ['6450', '10'], 'OAM_gnb0_du1': ['6450', '10']}
    [Arguments]    ${gnb_index}=${0}    ${du_index_list}=${LIST_DU_INDEX_0}
    ${cu_connection}    ${du_connection_list}    Create CU And DU Connections    gnb_index=${gnb_index}    du_index_list=${du_index_list}
    &{dict_vdu_alarms}    Get active alarms on VDUs    du_connection_list=${du_connection_list}
    ${dict_fault_id_vdus}    Create dictionary
    FOR    ${du_connection}    IN    @{du_connection_list}
        &{vdu_active_alarms}    Set variable    ${dict_vdu_alarms['${du_connection}']}
        ${list_fault_id_vdu}    Get fault id from alarm list    active_alarms=${vdu_active_alarms}
        Set to dictionary    ${dict_fault_id_vdus}    ${du_connection}    ${list_fault_id_vdu}
    END
    [Return]    ${dict_fault_id_vdus}
    [Teardown]  Aic Close all connection    gnb_index=${gnb_index}   du_index_list=${du_index_list}

Compare active fault id between case setup and case teardown for both CU and DU
    [Documentation]    Author: Ding Binmei
    ...    --Will notify as bellow: CU active fault id list in case setup: {'7104'}, CU active fault id list in case teardown: {"'10', '16'"}
    ...    --OAM_gnb0_du0: VDU active fault id list in case setup: {'49'}, VDU active fault id list in case teardown: {'16', '10'}
    ...    :param list_cu_active_fault_id_setup: result from keyword: Get fault id list on CU from active alarm list
    ...    :param list_cu_active_fault_id_teardown: result from keyword: Get fault id list on CU from active alarm list
    ...    :param dict_vdu_active_fault_id_setup: result from keyword: Get fault id list on DU from active alarm list
    ...    :param dict_vdu_active_fault_id_teardown: result from keyword: Get fault id list on DU from active alarm list
    [Arguments]    ${list_cu_active_fault_id_setup}    ${list_cu_active_fault_id_teardown}
    ...    ${dict_vdu_active_fault_id_setup}    ${dict_vdu_active_fault_id_teardown}
    ${list_cu_active_fault_id_setup}    Evaluate    set(${list_cu_active_fault_id_setup})
    ${list_cu_active_fault_id_teardown}    Evaluate    set(${list_cu_active_fault_id_teardown})
    ${cu_active_fault_id_gap}    Evaluate    list(${list_cu_active_fault_id_setup}^${list_cu_active_fault_id_teardown})
    ${CU_active_fault_id_verify_failed_message}    Catenate    CU active fault id list in case setup: ${list_cu_active_fault_id_setup},
    ...    CU active fault id list in case teardown: ${list_cu_active_fault_id_teardown}
    Run keyword and continue on failure    Should be empty    ${cu_active_fault_id_gap}    msg=${CU_active_fault_id_verify_failed_message}

    ${du_connection_list}    Get dictionary keys    ${dict_vdu_active_fault_id_setup}
    FOR    ${du_connection}    IN    @{du_connection_list}
        ${vdu_active_fault_id_setup}    Evaluate    set(${dict_vdu_active_fault_id_setup['${du_connection}']})
        ${vdu_active_fault_id_teardown}    Evaluate    set(${dict_vdu_active_fault_id_teardown['${du_connection}']})
        ${vdu_active_fault_id_gap}    Evaluate    list(${vdu_active_fault_id_setup}^${vdu_active_fault_id_teardown})
        ${VDU_active_fault_id_verify_failed_message}    Catenate    ${du_connection}: VDU active fault id list in case setup:
        ...    ${vdu_active_fault_id_setup}, VDU active fault id list in case teardown: ${vdu_active_fault_id_teardown}
        Run keyword and continue on failure    Should be empty    ${vdu_active_fault_id_gap}
        ...    msg=${VDU_active_fault_id_verify_failed_message}
    END

Verify for active alarms in case teardown
    [Documentation]    Author: Ding Binmei
    ...    1) Compare alarms in case setup and teardown and verify no additional alarms are generated
    ...    2) Verify no unexpected alarms exist on both CU and DU in case teardown phase.
    ...    :param list_cu_active_fault_id_setup/ dict_vdu_active_fault_id_setup: test variable defined in keyword: Aic Common case setup
    ...        if list_cu_active_fault_id_setup/dict_vdu_active_fault_id_setup is ${None}, will skip the alarm compare between setup and teardown
    ...    :param vcu_unexp_active_fault_ids: list. fault ids which are not allowed in case teardown check for vcu
    ...    :param vdu_unexp_active_fault_ids: list. fault ids which are not allowed in case teardown check for vdus
    [Arguments]    ${list_cu_active_fault_id_setup}    ${dict_vdu_active_fault_id_setup}    ${gnb_index}=${0}    ${du_index_list}=${LIST_DU_INDEX_0}
    ...    ${vcu_unexp_active_fault_ids}=${VCU_UNEXPECTED_ACTIVE_ALARMS}    ${vdu_unexp_active_fault_ids}=${VDU_UNEXPECTED_ACTIVE_ALARMS}
    ${list_cu_active_fault_id_teardown}    Get fault id list on CU from active alarm list    gnb_index=${gnb_index}    du_index_list=${du_index_list}
    ${dict_vdu_active_fault_id_teardown}    Get fault id list on DU from active alarm list    gnb_index=${gnb_index}   du_index_list=${du_index_list}
    Run keyword if    "${list_cu_active_fault_id_setup}"!="${None}" and "${dict_vdu_active_fault_id_setup}"!="${None}"
    ...    Compare active fault id between case setup and case teardown for both CU and DU
    ...        list_cu_active_fault_id_setup=${list_cu_active_fault_id_setup}
    ...        list_cu_active_fault_id_teardown=${list_cu_active_fault_id_teardown}
    ...        dict_vdu_active_fault_id_setup=${dict_vdu_active_fault_id_setup}
    ...        dict_vdu_active_fault_id_teardown=${dict_vdu_active_fault_id_teardown}

    ${current_unexp_fault_ids_cu_case_teardown}    Evaluate    list(set(${list_cu_active_fault_id_teardown})&set(${vcu_unexp_active_fault_ids}))
    Run keyword and continue on failure    Should Be Empty    ${current_unexp_fault_ids_cu_case_teardown}
    ...    msg=Unexpected alarms: ${current_unexp_fault_ids_cu_case_teardown} exist on CU in case teardown, please check
    ${cu_connection}    ${du_connection_list}    _Create CU And DUs Alias    gnb_index=${gnb_index}    du_index_list=${du_index_list}
    FOR    ${du_connection}    IN    @{du_connection_list}
        ${current_unexp_fault_ids_vdu_case_teardown}    Evaluate
        ...    list(set(${dict_vdu_active_fault_id_teardown['${du_connection}']})&set(${vdu_unexp_active_fault_ids}))
        Run keyword and continue on failure    Should Be Empty    ${current_unexp_fault_ids_vdu_case_teardown}
        ...    msg=Unexpected alarms: ${current_unexp_fault_ids_vdu_case_teardown} exist on VDU ${du_connection} in case teardown, please check
    END

Aic Collect CU And DU Logs in teardown
    [Documentation]  Author: Dandan Fang
    ...              Description: Collect common logs in teardown phase for trouble shooting
    [Timeout]  15 min
    [Arguments]    ${is_called_in_test_case_level}=${True}
    ...    ${gnb_index}=${0}   ${du_index_list}=${LIST_DU_INDEX_0}
    ...    ${ocp_log_type}=startup,syslog
    ${status}    Set variable if    ${is_called_in_test_case_level}    ${TEST STATUS}    ${SUITE STATUS}
    ${log_path}    Set variable if    ${is_called_in_test_case_level}    ${TS_CASE_LOG_PATH}    ${SUITE_LOG_PATH}

    Run keyword if    '${status}' == 'FAIL'    run keywords
    ...    run keyword and continue on failure    Get snapshot logs on CU and DUs
    ...        is_called_in_test_case_level=${is_called_in_test_case_level}    gnb_index=${gnb_index}    du_index_list=${du_index_list}
    ...    AND    run keyword and continue on failure    collect multiple vdu logs on ocp
    ...              log_type=${ocp_log_type}    local_dir=${log_path}    remove_remote_file=${True}
    ...              gnb_index=${gnb_index}    du_index_list=${du_index_list}

Get snapshot logs on CU and DUs
    [Documentation]  Author: Ding Binmei
    ...    Get snapshot logs on CU and DUs
    [Timeout]  15 min
    [Arguments]    ${is_called_in_test_case_level}=${True}    ${gnb_index}=${0}   ${du_index_list}=${LIST_DU_INDEX_0}
    ${log_path}    Set variable if    ${is_called_in_test_case_level}    ${TS_CASE_LOG_PATH}    ${SUITE_LOG_PATH}
    run keyword and continue on failure    _Capture snapshot file for dus    gnb_index=${gnb_index}    du_index_list=${du_index_list}
    ...    log_path=${log_path}
    vCU.VCU Collect Snapshot To Local    snapshot_file_dir=${log_path}/vcu_snapshot    gnb_index=${gnb_index}

_Capture snapshot file for dus
    [Documentation]  Author: Dandan Fang
    [Arguments]      ${gnb_index}=${0}   ${du_index_list}=${LIST_DU_INDEX_0}  ${log_path}=${SUITE_LOG_PATH}
    ${du_index_list}    string_list.string2list    ${du_index_list}
    FOR    ${list_index}    ${du_index}    IN ENUMERATE    @{du_index_list}
        Log to console    index:${list_index}, du_index:${du_index}
        vDU.VDU Collect Snapshot To Local    snapshot_file_dir=${log_path}/vdu${du_index}_snapshot
        ...     gnb_index=${gnb_index}    du_index=${du_index}
    END

Create CU And DU Connections
    [Documentation]  Author: Ding Binmei
    ...    Create connections for CU and DUs and return with connection alias
    [Arguments]    ${gnb_index}=${0}    ${du_index_list}=${LIST_DU_INDEX_0}
    ${du_index_list}    string_list.string2list    ${du_index_list}
    ${cu_connection}    ${du_connection_list}    _Create CU And DUs Alias    gnb_index=${gnb_index}    du_index_list=${du_index_list}
    Log to console    Create vCU connection, connection alias: ${cu_connection}
    vCU.Connect to vcu via rest api   gnb_index=${gnb_index}   connection=${cu_connection}
    FOR    ${index}    ${du_connection}   IN ENUMERATE    @{du_connection_list}
           Log to console    Create VDU connection for du_index: ${du_index_list[${index}]}, connection alias: ${du_connection}
           vDU.Connect to vdu via rest api   gnb_index=${gnb_index}   du_index=${du_index_list[${index}]}    connection=${du_connection}
    END
    [Return]    ${cu_connection}    ${du_connection_list}

_Create CU And DUs Alias
    [Documentation]  Author: Dandan Fang
    ...              Use to create connection alias, please always follow the format.
    [Arguments]    ${gnb_index}=${0}   ${du_index_list}=${0}
    ${cu_connection}    set variable  OAM_CU${gnb_index}
    ${du_index_list}    string_list.string2list    ${du_index_list}
    @{du_connection_list}    Create list
    FOR    ${du_index}    IN    @{du_index_list}
           Append to list    ${du_connection_list}    OAM_gnb${gnb_index}_du${du_index}
    END
    [Return]  ${cu_connection}    ${du_connection_list}

Aic Close all connection
    [Documentation]  Author: Dandan Fang
    ...              Description: Release all cu and du connections
    [Arguments]    ${gnb_index}=${0}   ${du_index_list}=${0}
    #cu connection
    Teardown vcu connection  connection=OAM_CU${gnb_index}
    ${du_index_list}    string_list.string2list    ${du_index_list}
    FOR    ${du_index}    IN    @{du_index_list}
           ${du_connection}    set variable    OAM_gnb${gnb_index}_du${du_index}
           Run keyword and continue on failure   Teardown vdu connection    connection=${du_connection}
    END

_online modify for dus
    [Documentation]  Author: Ding Binmei
    [Arguments]  ${du_params_modify_list}    ${du_connections_list}=${LIST_DU_CONNECTION}    ${timeout}=300
    ${is_input_data_a_list_param}    Evaluate    isinstance(${du_params_modify_list}, list)
    Should be true    ${is_input_data_a_list_param}    msg=Input param list for modify should be a list
    ${is_input_data_a_list_connection}    Evaluate    isinstance(${du_connections_list}, list)
    Should be true    ${is_input_data_a_list_connection}    msg=Input connection should be a list
    ${len_du_params_modify}    Get length    ${du_params_modify_list}
    ${len_du_connections}    Get length    ${du_connections_list}
    Should be equal as integers    ${len_du_params_modify}    ${len_du_connections}
    ...    msg=provided parameters should be align with du connections
    FOR    ${index}    ${du_params_modify}    IN ENUMERATE    @{du_params_modify_list}
        Log to console    index:${index}, du_params_modify:${du_params_modify}
        online_nidd_process.online_modify_nidd_parameters_via_restapi    params_modify_dict=${du_params_modify}
        ...    connection=${du_connections_list[${index}]}    timeout=${timeout}    bts_type=du
    END

Add list of allowed alarms
    [Documentation]    Author: Lingxue Cui
    ...    Temporary WA until CI support list type of faults.
    ...    ${allowed_faults_ids}: must be string, for example: 6450,4350
    [Arguments]    ${allowed_faults_ids}
    ${allowed_faults_ids}    String2list    ${allowed_faults_ids}
    FOR    ${fault_id}    IN    @{allowed_faults_ids}
        Run Keyword And Continue On Failure     AlarmWatchdog.add_allow_alarms     fault_id=${fault_id}
    END


Remove list of allowed alarms
    [Documentation]    Author: Lingxue Cui
    ...    Temporary WA until CI support list type of faults.
    ...    ${allowed_faults_ids}: must be string, for example: 6450,4350
    [Arguments]    ${allowed_faults_ids}
    ${allowed_faults_ids}    String2list    ${allowed_faults_ids}
    FOR    ${fault_id}    IN    @{allowed_faults_ids}
        Run Keyword And Continue On Failure     AlarmWatchdog.remove_allow_alarms     fault_id=${fault_id}
    END
