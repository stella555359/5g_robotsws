*** Settings ***
Documentation    This is for TMO common keywords.
...              Please do not modify the file without notification to author
...              Author: stella.lin@nokia-sbell.com

Resource    ./TMO_common_keywords.robot

*** Keywords ***
TMO_Common_Suite_Setup
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${is_commission}=${False}    ${whether_do_prepare_ue}=${True}  ${upload_swconfig}=${True}
    ...            ${ue_index}=${0}    ${ute_space}=20    ${prefer_5g_nr_mode}=SA    ${gnb_scf_name}=None
    ...            ${turn_off_pa}=${True}
    log     ${ute_space}
    log     ${prefer_5g_nr_mode}
    csn.reset_cache
    Clearup UTE Space while keep syslog
    ${stream_version}    Common_setup_and_teardown.Get Active SW Version Based On Stream Version
    Set Suite Variable    ${stream_version}
    ## get how many UEs
    ${ue_length}    Get Length    ${tl.ues}
    Set Suite Variable    ${ue_length}
    ## get tl_prefix, such as T813/T073
    Set Suite Variable    ${tl_prefix}    ${testline_name.split('_')[-1][-4:]}
#    ${SCOUT_TL_NAME}=  Set Variable If    '${tl_prefix}'=='T813' or '${tl_prefix}'=='T284'
#    ...    ${testline_name}_5G    ${testline_name}
#    Set Suite Variable    ${SCOUT_TL_NAME}
    ## get how many ENBs
    ${enb_length}    Get Length    ${tl.enbs}
    Set Suite Variable    ${enb_length}
    ${dict_enb_Technology_index}    Get LTE Technology Value
    Set Suite Variable    ${DICT_ENB_TECHNOLOGY_INDEX}    ${dict_enb_Technology_index}
    Suite Log Path Create
    Run Keyword If    ${upload_swconfig}     Uplaod Default Swconfig File Before Commission
    log to console    --- start to commission---
    ${gnb_scf_name}    Set Variable If    '${gnb_scf_name}'!='${None}'
    ...    ${tl_prefix}_gNB_${stream_version}_${gnb_scf_name}.xml    ${tl_prefix}_gNB_${stream_version}.xml
    Set Suite Variable    ${BASIC_SCF}    ${SCF_PATH_ON_UTE}/${gnb_scf_name}
    Run Keyword And Continue On Failure    Common_setup_and_teardown.Common Suite Setup    scf_name=${gnb_scf_name}
    ...    is_commission=${is_commission}
    ...    timeout_for_commission=20 min
#    Update BasedPCellSwitchEnabled Status
    Check TMO Gnb Ready And All Cell On Air
#    ${delete_nrrel_param_list}    ${add_nrrel_param_list}   Get The Parameter List Of NRREL Config
#    Set Suite Variable    ${DELETE_NRREL_PARAM_LIST}    ${delete_nrrel_param_list}
#    Set Suite Variable    ${ADD_NRREL_PARAM_LIST}    ${add_nrrel_param_list}
#    Verify All Enbs Cell On Air
    Run Keyword If    ${turn_off_pa}    Trun Off All PA Ports
    ${ue_index}=  Get Variable Value    ${CASE_FOR_3CC_CHOOSED_UE['${tl_prefix}']}    ${ue_index}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    Set Suite Variable    ${ue_type}
    Kill Adb App    ue_index=${ue_index}
    ${whether_do_prepare_ue}    Set Variable If    'spark' in '${ue_type}'
    ...    ${False}     ${whether_do_prepare_ue}
#     turn off airphon mode and clear ELT space for MTK UE
    Run Keyword If    '${ue_type}' == 'mtk'     Clear Temp File Of ELT For MTK
    Run keyword if    '${ue_type}' == 'mtk'    Run Keyword And Ignore Error
    ...    MTK_common_keywords.Get UE Airmode status and Turnoff Airplane Mode    ue_index=${ue_index}
    Run Keyword If    ${whether_do_prepare_ue} and '${ue_type}' != 'mtk'    Procedures.Start UE Prepare    ue_index=${ue_index}
    ...               ue_type=${ue_type}
    ...    ELSE IF    ${whether_do_prepare_ue} and '${ue_type}' == 'mtk'    Procedures.Start UE Prepare MTK80    ue_index=${ue_index}
    ...               ue_type=${ue_type}
    Run Keyword And Continue On Failure    Run Keyword If    '${ue_type}'=='qct_dx50' and '${whether_do_prepare_ue}'=='${True}'
    ...    Procedures.Check network mode    ue_index=${ue_index}
    &{fault_4203}     Create Dictionary     faultId=${4203}
    &{fault_4459}     Create Dictionary     faultId=${4459}
    &{fault_8000}     Create Dictionary     faultId=${8000}
    &{fault_1932}     Create Dictionary     faultId=${1932}
    &{fault_1933}     Create Dictionary     faultId=${1933}
    &{fault_1934}     Create Dictionary     faultId=${1934}
    &{fault_61631}     Create Dictionary     faultId=${61631}
    &{fault_1838}     Create Dictionary     faultId=${1838}
    &{fault_4741}     Create Dictionary     faultId=${4741}
    &{fault_4681}     Create Dictionary     faultId=${4681}
    &{fault_4334}     Create Dictionary     faultId=${4334}
    &{fault_7311}     Create Dictionary     faultId=${7311}
    &{fault_4293}     Create Dictionary     faultId=${4293}
    &{fault_4203}     Create Dictionary     faultId=${4203}
    &{fault_4775}     Create Dictionary     faultId=${4775}
    &{fault_7319}     Create Dictionary     faultId=${7319}
    &{fault_4297}     Create Dictionary     faultId=${4297}
    &{fault_4420}     Create Dictionary     faultId=${4420}
    &{fault_6261}     Create Dictionary     faultId=${6261}
    &{fault_4776}     Create Dictionary     faultId=${4776}
    &{fault_4569}     Create Dictionary     faultId=${4569}
    ${GNB_ALLOWED_FAULT}   Create List   @{ALLOWED_FAULT}   ${fault_4203}    ${fault_4459}   ${fault_1932}   ${fault_1934}
    ...                    ${fault_1838}     ${fault_4741}    ${fault_1933}    ${fault_4681}    ${fault_4334}    ${fault_7311}
    ...                    ${fault_4293}     ${fault_4297}    ${fault_7319}     ${fault_4420}    ${fault_4775}    ${fault_6261}
    ...                    ${fault_4776}    ${fault_4569}    ${fault_8000}
    Set Suite Variable    ${GNB_ALLOWED_FAULT}
    ${ALLOWED_HISTORY_FAULT}   Create List   @{ALLOWED_HISTORY_FAULT}   ${fault_61631}   ${fault_1838}   ${fault_4741}    ${fault_4459}
    ...     ${fault_4775}    ${fault_6261}    ${fault_4776}    ${fault_4569}    ${fault_7311}    ${fault_8000}
    Set Suite Variable    ${ALLOWED_HISTORY_FAULT}
    robot_common_operations.Common Suite Setup
    Suite Log Path Create

TMO_Common_Case_Setup
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${ue_index}=${0}    ${whether_get_ca_info}=${True}
    ...            ${whether_set_pa_value}=${True}    ${3CC_support}=${False}
    ...            ${scf_name}=None    ${is_commission}=False    ${is_pdl_checking_needed}=${True}
    ...            ${swconfig_flag}=${None}
    log     ${is_pdl_checking_needed}
    csn.reset_cache
    Common_setup_and_teardown.Common Case Setup    scf_name=${scf_name}    is_commission=${is_commission}
    ...    timeout_for_commission=20 min
    Create Case Log Path
    Run Keyword If    '${swconfig_flag}'!='${None}'
    ...     Run Keywords    Backup and Modify swconfig file    swconfig_modify=@{SWCONFIG_${swconfig_flag}}    AND
    ...                     Perform gNB Reset site and Wait Onair
    Trun Off All PA Ports
    Set Test Variable    ${test_case_id}    ${TEST NAME.split('_')[0]}
    Set Test Variable    ${case_params}    ${GNB_INFO_MAPPING_TO_CASE_TABLE['${test_case_id}']['${tl_prefix}']}
    Set Test Variable    ${PCELL_INDEX}    ${case_params.get('pcell_idx')}
    Set Test Variable    ${attenuator_list}    ${case_params.get('attenuator')}
    Set Test Variable    ${ca_technology}    ${case_params.get('ca_technology')}
    ${ca_technology_status}    Run Keyword And Return Status    Dictionary Should Contain Key    ${case_params}    ca_technology
    Run Keyword If    ${ca_technology_status}    Set Test Variable    ${scell_technology}
    ...                                                               ${case_params.get('ca_technology').split('+')[-1]}
    Set Test Variable    ${LTE_CELL_INDEX}    ${case_params.get('lte_cell_idx')}
#    Set Test Variable    ${NSA_PA_RU_INDEX}    ${case_params.get('nsa_pa_ru_idx')}
    Set Test Variable    ${HO_PCELL_INDEX}    ${case_params.get('after_ho_pcell_idx')}
    ${ho_ca_technology_status}    Run Keyword And Return Status    Dictionary Should Contain Key    ${case_params}    ho_ca_technology
    Run Keyword If    ${ho_ca_technology_status}    Set Test Variable    ${HO_SCELL_TECHNOLOGY}
    ...                                                                  ${case_params.get('ho_ca_technology').split('+')[-1]}
    Run Keyword If    ${whether_get_ca_info} and ${3CC_support}==${False}    Get CA Related Infomation    pcell_index=${PCELL_INDEX}
    ...    ELSE IF    ${whether_get_ca_info} and ${3CC_support}    Get 3CC Related Infomation    pcell_index=${PCELL_INDEX}
#    Run Keyword If    ${3CC_support}    Run Keyword And Continue On Failure    Update The Flag Whether Support 3CC
#    ...   3CC_flag=${True}    is_pdl_checking_needed=${is_pdl_checking_needed}
#    ...    ELSE    Update The Flag Whether Support 3CC    is_pdl_checking_needed=${is_pdl_checking_needed}
    Run Keyword If    ${whether_set_pa_value}    Set Case PA Or MCS Port Value    attenuator_list=${attenuator_list}    ue_index=${ue_index}
    Check TMO Gnb Ready And All Cell On Air
    Verify All Enbs Cell On Air
    ${lte_whether_in_gnb}    Check LTE Whether In Gnb
    Set Test Variable    ${LTE_WHETHER_IN_GNB}    ${lte_whether_in_gnb}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    Set Test Variable    ${ue_type}
    ${gnb_allowed_fault_Before_Commission}   Create List    4203    1838    4741    4681   7311   7331    7107
    ...                                                     4293    4297    4420    4775   1932   1934    1933    8150
    ...                                                     4589    6261    4776    4569    8000    6117
    Set Test Variable    ${gnb_allowed_fault_Before_Commission}
    robot_common_operations.Common Case Setup    fail_with_alarms=${False}
    AlarmWatchdog.add_allow_alarms    fault_id=${gnb_allowed_fault_Before_Commission}


TMO_Common_Case_Setup_OAM
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${swconfig_flag}=${None}    ${is_commission}=${True}
    csn.reset_cache
    Common_setup_and_teardown.Common Case Setup
    Create Case Log Path
    Run Keyword If    '${swconfig_flag}'!='${None}'    Backup and Modify swconfig file    swconfig_modify=@{SWCONFIG_${swconfig_flag}}
    log to console    --- start to commission---
    ${is_commission}    Set Variable If    '${btsName_in_gnb}'=='${btsName_in_scf}'    ${False}    ${is_commission}
    Common_setup_and_teardown.Common Suite Setup    scf_name=${tl_prefix}_gNB_${stream_version}.xml    is_commission=${is_commission}
    ...    timeout_for_commission=20 min
    Check TMO Gnb Ready And All Cell On Air
    Verify All Enbs Cell On Air
    Set Test Variable    ${test_case_id}    ${TEST NAME.split('_')[0]}
    ${case_params}    Set Variable    ${GNB_INFO_MAPPING_TO_CASE_TABLE['${test_case_id}']['${tl_prefix}']}
    Set Test Variable    ${PCELL_INDEX}    ${case_params.get('pcell_idx')}
    ${lte_whether_in_gnb}    Check LTE Whether In Gnb
    Set Test Variable    ${LTE_WHETHER_IN_GNB}    ${lte_whether_in_gnb}
    ${gnb_allowed_fault_Before_Commission}   Create List    4203    1838    4741    4681   7311   7331    7107
    ...                                                     4293    4297    4420    4775   1932   1934    1933    8150
    ...                                                     4589    6261    4776    7535    7525   4569    8000
    Set Test Variable    ${gnb_allowed_fault_Before_Commission}
    robot_common_operations.Common Case Setup    fail_with_alarms=${False}
    AlarmWatchdog.add_allow_alarms    fault_id=${gnb_allowed_fault_Before_Commission}


TMO_Common_Case_Setup_SISO
    [Documentation]    Author: lei.jia@nokia-sbell.com
    [Arguments]    ${scf_name}=${None}    ${is_commission}=${True}
    csn.reset_cache
    ${scf_name_case}    Set Variable If    '${scf_name}'!='${None}'    ${scf_name}    ${tl_prefix}_gNB_${stream_version}.xml
    Common_setup_and_teardown.Common Case Setup    scf_name=${scf_name_case}    is_commission=${is_commission}
    ...    timeout_for_commission=20 min
    Create Case Log Path
    Check TMO Gnb Ready And All Cell On Air
    Verify All Enbs Cell On Air
    ${gnb_allowed_fault_Before_Commission}   Create List    4203    1838    4741    4681   7311   7331    7107    4776
    ...                                                     4293    4297    4420    4775   1932   1934    1933    8150    6261
    ...                                                     4569    8000
    Set Test Variable    ${gnb_allowed_fault_Before_Commission}
    robot_common_operations.Common Case Setup    fail_with_alarms=${False}
    AlarmWatchdog.add_allow_alarms    fault_id=${gnb_allowed_fault_Before_Commission}

TMO_Common_Case_Teardown
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${ue_index}=${0}    ${3CC_support}=${True}    ${ue_type}=${ue_type}    ${is_power_ue_code}=${False}
    ...            ${is_save_snapshot}=${False}   ${apn_address}=${tl.core.pdns[0].apn}    ${power_reset}=False
    ...            ${is_history_alarm_check}=${True}    ${allowed_history_faults}=${ALLOWED_HISTORY_FAULT}
    ...            ${is_operations_teardown}=${True}
    log    ${3CC_support}
    Run Keyword If    ${is_operations_teardown}    robot_common_operations.Common Case Teardown
    Run Keyword If    '${ue_type}'=='huawei_sigspark'    Run Keyword And Ignore Error
    ...    Spark_common_keywords.Spark Stop UE Log    ue_index=${ue_index}
    Procedures.Stop TMO L3 Call And Detach    ue_index=${ue_index}    ue_type=${ue_type}
    ...                                       is_power_ue_code=${is_power_ue_code}
    ...                                       apn_address=${apn_address}    power_reset=${power_reset}
    Run Keyword And Ignore Error    Stop Aasyslog And Download To TestPC    log_prefix=aasyslog
    Run Keyword And Ignore Error    Common Case Teardown    is_save_snapshot=${is_save_snapshot}
    Run Keyword And Ignore Error    mcs_common.Teardown MCS    mcs_type=${mcs_type}
    Unexpect Alarm and History Alarm Should Not Exist    is_history_alarm_check=${is_history_alarm_check}
    ...    allowed_history_faults=${allowed_history_faults}
    Run Keyword And Ignore Error     Recover Collect Syslog On GNB
    run keyword and ignore error    Run Keyword If Test Failed    Collect Snapshot Log in gnb and enb    timeout=${2400}

TMO_Suite_Teardown
    [Documentation]    Author: lei.jia@nokia-sbell.com
    [Arguments]    ${ue_index}=${0}
#    Run Keyword And Continue On Failure    Update The Flag Whether Support 3CC    3CC_flag=${True}
    log    ${ue_index}
    robot_common_operations.Common Suite Teardown
    run keyword and ignore error    Collect Snapshot Log in gnb and enb    log_path=${SUITE_LOG_PATH}
    ...     timeout=${2400}

TMO_AZHL_case_setup
    [Documentation]    Author: tingting.1.liu@nokia-sbell.com
    csn.reset_cache
    Common_setup_and_teardown.Common Case Setup
    Wait Until Keyword Succeeds    5 min    5 sec    connection_alias_store.Connect to Common Unit Master
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl
#    COAM Create log directory
    Common_setup_and_teardown.Create Case Log Path
    Verify Gnb Type Cells Should Be Onair
    ${lte_whether_in_gnb}    Check LTE Whether In Gnb
    Set Test Variable    ${LTE_WHETHER_IN_GNB}    ${lte_whether_in_gnb}
#    COAM Wait For Gnb Ready And Cell Setup    timeout=15 min
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl
    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist   allowed_faults=${GNB_ALLOWED_FAULT}
    ${fdd_enb_index}    Select ENB Index based on LTE Technology    used_enb_technology=FDD
    ${cell_list}    Get Cell Index List   cell_type=lte    enb_index=${fdd_enb_index}
    Set Test Variable    ${LTE_CELL_LIST}    ${cell_list}
    run keyword and ignore error    COAM Teardown gnb connections
    ${gnb_allowed_fault_Before_Commission}   Create List    4203    1838    4741    4681   7311   7331    7107
    ...                                                     4293    4297    4420    4775   1932   1934    1933   6261
    ...                                                     4569   8000
    Set Test Variable    ${gnb_allowed_fault_Before_Commission}
    robot_common_operations.Common Case Setup    fail_with_alarms=${False}
    AlarmWatchdog.add_allow_alarms    fault_id=${gnb_allowed_fault_Before_Commission}

Multi-UE_Case_Setup
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${ue_index}=${1}    ${connection}=GNB_OAM0    ${gnb_id}=${0}    ${timeout}=${600}    ${specified_scell_index}=${None}
    ...            ${first_beam_begin_output_port}=${13}
    ...            ${first_beam_end_output_port}=${14}
    ...            ${second_beam_begin_output_port}=${15}
    ...            ${second_beam_end_output_port}=${16}
    ...            ${first_beam_horizontal_angle}=${7}
    ...            ${second_beam_horizontal_angle}=${22}
    ...            ${vertical_angle}=${-6}
    csn.reset_cache
    log    ${gnb_id}
    log    ${timeout}
    log    ${vertical_angle}
    log    ${connection}
    Run Keyword If    '${tl_prefix}'=='T073' and ${ue_index}==${1}    Turn off TL283 AEHC0 PA ports
    ${case_params_1}    Set Variable    ${GNB_INFO_MAPPING_TO_CASE_TABLE['${test_case_id}']['${tl_prefix}']['UEs_info'][${ue_index}]}
    ${cell_index}    Set Variable    PCELL_INDEX_${ue_index}
    ${lte_cell_index}    Set Variable    LTE_CELL_INDEX_${ue_index}
    Set Test Variable    ${${cell_index}}    ${case_params_1.get('pcell_idx')}
    Set Test Variable    ${${lte_cell_index}}    ${case_params_1.get('lte_cell_idx')}
    Set Test Variable    ${attenuator_list_1}        ${case_params_1.get('attenuator')}
    Set Test Variable    ${scell_technology_1}        ${case_params_1.get('ca_technology').split('+')[-1]}
    ${cell_list_info}    Get CA Related Infomation For Multi-UE    pcell_index=${${cell_index}}    scell_technology=${scell_technology_1}
    ...    specified_scell_index=${specified_scell_index}
    ${scell_index_list_name}    Set Variable    SCELL_INDEX_LIST_${ue_index}
    Set Test Variable    ${${scell_index_list_name}}    ${cell_list_info['scell_index_list']}
    ${all_scell_list_name}    Set Variable    ALL_SCELL_LIST_${ue_index}
    Set Test Variable    ${${all_scell_list_name}}    ${cell_list_info['all_scell_list']}
    ${pcell_ru_index_name}    Set Variable    pcell_ru_index_${ue_index}
    Set Test Variable    ${${pcell_ru_index_name}}    ${cell_list_info['pcell_ru_index']}
    ${scell_ru_index_list_name}    Set Variable    scell_ru_index_list_${ue_index}
    Set Test Variable    ${${scell_ru_index_list_name}}    ${cell_list_info['scell_ru_index_list']}
    ${pcell_mapping_name}    Set Variable    PCELL_MAPPING_${ue_index}
    Set Test Variable    ${${pcell_mapping_name}}    ${cell_list_info['pcell_mapping']}
    ${scell_mapping_name}    Set Variable    SCELL_MAPPING_${ue_index}
    Set Test Variable    ${${scell_mapping_name}}    ${cell_list_info['scell_mapping']}
#    Modify WeightForSCellSelection Parameter Value On Gnb    scell_list_used_in_fact=${${scell_index_list_name}}
#    ...                                                      scell_list_supported=${${all_scell_list_name}}
#    ...                                                      connection=${connection}
#    ...                                                      gnb_id=${gnb_id}
#    ...                                                      timeout=${timeout}
    FOR    ${attenuator}    IN    @{attenuator_list_1}
        Run Keyword If    '${attenuator}'=='pa'
        ...    Run Keywords    Modify PA Value Setting For Required RU    modify_ru_id=${${pcell_ru_index_name}}    ue_index=${ue_index}
        ...             AND    Modify PA Value Setting For Required RU    modify_ru_id=${${scell_ru_index_list_name}}    ue_index=${ue_index}
        ...    ELSE IF    '${attenuator}'=='mcs'    Set Case Related MCS Port Value    ue_index=${ue_index}    whether_do_mcs_setup=${False}
        ...    first_beam_begin_output_port=${first_beam_begin_output_port}
        ...    first_beam_end_output_port=${first_beam_end_output_port}
        ...    second_beam_begin_output_port=${second_beam_begin_output_port}
        ...    second_beam_end_output_port=${second_beam_end_output_port}
        ...    first_beam_horizontal_angle=${first_beam_horizontal_angle}
        ...    second_beam_horizontal_angle=${second_beam_horizontal_angle}
        ...    ELSE    Log To Console     ${\n}INFO: --Use the wrong attenuator type(${attenuator}), need to check TMO_Data.py--
    END

TMO_Sleeping_Cell_Suite_Setup
    [Documentation]    Author: tingting.1.liu@nokia-sbell.com
    [Arguments]    ${is_commission}=${False}    ${whether_do_prepare_ue}=${True}
    ...            ${ue_index}=${0}    ${ute_space}=20
    csn.reset_cache
#    ${stream_version}    gnb_classical_hangzhou.Get program version based on stream version
    ${stream_version}    Common_setup_and_teardown.Get Active SW Version Based On Stream Version
    Set Suite Variable    ${stream_version}
    Set Suite Variable    ${tl_prefix}    ${testline_name.split('_')[-1][-4:]}
#    ${SCOUT_TL_NAME}=  Set Variable If    '${tl_prefix}'=='T813'    ${testline_name}_5G    ${testline_name}
#    Set Suite Variable    ${SCOUT_TL_NAME}
    ${ue_index}    Set Variable If    '${tl_prefix}'=='T080'    ${15}
    ...                               '${tl_prefix}'=='T816'   ${2}    ${0}
    Set Suite Variable    ${ue_index}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    Set Suite Variable    ${ue_type}
#     get tl_prefix, such as T813/T073
#    Run Keyword If    '${tl_prefix}'=='T080'     Clear Temp File Of ELT For MTK
#     get how many ENBs
    ${enb_length}    Get Length    ${tl.enbs}
    Set Suite Variable    ${enb_length}
    ${dict_enb_Technology_index}    Get LTE Technology Value
    Set Suite Variable    ${DICT_ENB_TECHNOLOGY_INDEX}    ${dict_enb_Technology_index}
    Suite Log Path Create
    Backup And Delete Parameter Of Swconfig File    swconfig_modify=@{delete_flag}
    Perform gNB Reset site and Wait Onair
    Common_setup_and_teardown.Common Suite Setup    scf_name=${tl_prefix}_gNB_${stream_version}.xml    is_commission=${is_commission}
    ...    timeout_for_commission=20 min
#    Check TMO Gnb Ready And All Cell On Air
    Verify All Enbs Cell On Air
    Trun Off All PA Ports
    Check And Clear TestPC Space    ute_space=${ute_space}
    Kill Adb App    ue_index=${ue_index}
    FOR    ${enb_index}    IN RANGE    ${enb_length}
        Change cellBarred Parameter Value Of Lte Cells    list_cell_ids=all    exp_status=barred    enb_index=${enb_index}
    END
    Run Keyword If    ${whether_do_prepare_ue}    Procedures.Start UE Prepare    ue_index=${ue_index}    ue_type=${ue_type}
    &{fault_4203}     Create Dictionary     faultId=${4203}
    &{fault_4459}     Create Dictionary     faultId=${4459}
    &{fault_1932}     Create Dictionary     faultId=${1932}
    &{fault_1934}     Create Dictionary     faultId=${1934}
    &{fault_61631}     Create Dictionary     faultId=${61631}
    &{fault_1838}     Create Dictionary     faultId=${1838}
    &{fault_4741}     Create Dictionary     faultId=${4741}
    &{fault_4293}     Create Dictionary     faultId=${4293}
    &{fault_1898}     Create Dictionary     faultId=${1898}
    &{fault_4297}     Create Dictionary     faultId=${4297}
    &{fault_7319}     Create Dictionary     faultId=${7319}
    &{fault_6261}     Create Dictionary     faultId=${6261}
    &{fault_8000}     Create Dictionary     faultId=${8000}
    &{fault_4776}     Create Dictionary     faultId=${4776}
    ${GNB_ALLOWED_FAULT}   Create List   @{ALLOWED_FAULT}   ${fault_4203}    ${fault_4459}   ${fault_1932}   ${fault_1934}
    ...                    ${fault_1838}     ${fault_4741}    ${fault_4293}    ${fault_4297}    ${fault_7319}    ${fault_6261}
    ...     ${fault_8000}    ${fault_4776}
    Run Keyword If    '${tl_prefix}'=='T813' or '${tl_prefix}'=='T284'         append to list    ${GNB_ALLOWED_FAULT}    ${fault_1898}
    Set Suite Variable    ${GNB_ALLOWED_FAULT}
    ${ALLOWED_HISTORY_FAULT}   Create List   @{ALLOWED_HISTORY_FAULT}   ${fault_61631}   ${fault_1838}   ${fault_4741}    ${fault_4459}
    ...    ${fault_6261}    ${fault_8000}
    Set Suite Variable    ${ALLOWED_HISTORY_FAULT}
    robot_common_operations.Common Suite Setup

TMO_Common_Case_Setup_Kpi
    [Documentation]    Author: xiangsheng.chu@nokia-sbell.com
    [Arguments]    ${ue_index}=${0}    ${whether_get_ca_info}=${True}    ${whether_set_pa_value}=${True}
    csn.reset_cache
    log    ${whether_get_ca_info}
    log    ${whether_set_pa_value}
    Common_setup_and_teardown.Common Case Setup
    Set Test Variable    ${test_case_id}    ${TEST NAME.split('_')[0]}
    ${case_params}    Set Variable    ${GNB_INFO_MAPPING_TO_CASE_TABLE['${test_case_id}']['${tl_prefix}']}
    Set Test Variable    ${PCELL_INDEX}    ${case_params.get('pcell_idx')}
    Set Test Variable    ${attenuator_list}    ${case_params.get('attenuator')}
    Set Test Variable    ${ca_technology}    ${case_params.get('ca_technology')}
    ${ca_technology_status}    Run Keyword And Return Status    Dictionary Should Contain Key    ${case_params}    ca_technology
    Run Keyword If    ${ca_technology_status}    Set Test Variable    ${scell_technology}
    ...                                                               ${case_params.get('ca_technology').split('+')[-1]}
    Set Test Variable    ${LTE_CELL_INDEX}    ${case_params.get('lte_cell_idx')}
#    Set Test Variable    ${NSA_PA_RU_INDEX}    ${case_params.get('nsa_pa_ru_idx')}
    Set Test Variable    ${HO_PCELL_INDEX}    ${case_params.get('after_ho_pcell_idx')}
    ${ho_ca_technology_status}    Run Keyword And Return Status    Dictionary Should Contain Key    ${case_params}    ho_ca_technology
    Run Keyword If    ${ho_ca_technology_status}    Set Test Variable    ${HO_SCELL_TECHNOLOGY}
    ...                                                                  ${case_params.get('ho_ca_technology').split('+')[-1]}
#    Run Keyword If    '${tl_prefix}'=='T080'    Update_TMO_3CC_Configration    3CC_support=${True}
#    Run Keyword If    '${tl_prefix}'=='T073'    Update_TMO_3CC_Configration    3CC_support=${False}
#    Run Keyword If    '${tl_prefix}'=='T284'    Update_TMO_3CC_Configration    3CC_support=${False}
#    Run Keyword If    '${tl_prefix}'=='T283'    Update_TMO_3CC_Configration    3CC_support=${False}
#    Run Keyword If    ${whether_set_pa_value}    Set Case PA Or MCS Port Value    attenuator_list=${attenuator_list}    ue_index=${ue_index}
#    Check TMO Gnb Ready And All Cell On Air
#    Verify All Enbs Cell On Air
    ${lte_whether_in_gnb}    Check LTE Whether In Gnb
    Set Test Variable    ${LTE_WHETHER_IN_GNB}    ${lte_whether_in_gnb}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    Set Test Variable    ${ue_type}
    ${gnb_allowed_fault_Before_Commission}   Create List    4203    1838    4741    4681   7311   7331    7107
    ...                                                     4293    4297    4420    4775   1932   1934    1933    6261   4569   8000
    Set Test Variable    ${gnb_allowed_fault_Before_Commission}
    robot_common_operations.Common Case Setup    fail_with_alarms=${False}
    AlarmWatchdog.add_allow_alarms    fault_id=${gnb_allowed_fault_Before_Commission}

SetUp.Precondition For Second gNB
    [Documentation]   stella.lin@nokia0sbell.com
    [Arguments]     ${gnb_scf_name}=${None}
    ...             ${connection}=GNB_OAM1
    ...             ${is_commission}=False
    ...             ${timeout_for_commission}=900
    ...             ${is_pdl_checking_needed}=${True}
    ...             ${active_sw_flag}=High
    ...             ${check_rollback_is_needed}=${True}
    Run Keyword If    ${check_rollback_is_needed}    Check Rollback is needed before sw upgrade
    ...                                              active_sw_flag=${active_sw_flag}
    ...                                              gnb_connection=${connection}
    ...                                              gnb_index=${1}
    ${version}    Common_setup_and_teardown.Get Active SW Version Based On Stream Version    connection=${connection}
    ...    gnb_index=${1}
    ${gnb_scf_name}    Set Variable If    '${gnb_scf_name}'!='${None}'    ${gnb_scf_name}    ${tl_prefix}_gNB1_${version}.xml
    log to console    start to commssion scf ${gnb_scf_name}
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${1}
    Run Keyword If    ${is_commission}
    ...    COAM Commission with scf file    scf_file_path=${SCF_PATH_ON_UTE}/${gnb_scf_name}
    ...                                     connection=${connection}
    ...                                     timeout=${timeout_for_commission}
    ...                                     is_pdl_checking_needed=${is_pdl_checking_needed}
    Check TMO Gnb Ready And All Cell On Air    gnb_id=${1}    connection=${connection}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

SetUp.Precondition For First gNB
    [Documentation]    Author: stella.lin@nokia-sbell.com
    [Arguments]    ${gnb_scf_name}=${None}
    ...            ${connection}=GNB_OAM0
    ...            ${is_commission}=False
    ...            ${timeout_for_commission}=900
    ...            ${is_pdl_checking_needed}=${True}
    ...            ${active_sw_flag}=High
    ...            ${check_rollback_is_needed}=${True}
    Run Keyword If    ${check_rollback_is_needed}    Check Rollback is needed before sw upgrade
    ...                                              active_sw_flag=${active_sw_flag}
    ...                                              gnb_connection=${connection}
    ...                                              gnb_index=${0}
    ${version}    Common_setup_and_teardown.Get Active SW Version Based On Stream Version    connection=${connection}
    ...    gnb_index=${0}
    ${gnb_scf_name}    Set Variable If    '${gnb_scf_name}'!='${None}'    ${gnb_scf_name}    ${tl_prefix}_gNB_${version}.xml
    log to console    start to commssion scf ${gnb_scf_name}
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${0}
    Run Keyword If    ${is_commission}
    ...    COAM Commission with scf file    scf_file_path=${SCF_PATH_ON_UTE}/${gnb_scf_name}
    ...                                     connection=${connection}
    ...                                     timeout=${timeout_for_commission}
    ...                                     is_pdl_checking_needed=${is_pdl_checking_needed}
    Check TMO Gnb Ready And All Cell On Air    gnb_id=${0}    connection=${connection}

SetUp.Case Common Operation
    [Arguments]    ${ue_index}=${0}    ${whether_set_pa_value}=False    ${all_pa_trun_off}=${True}    ${test_case_prefix}=${None}
    log    ${whether_set_pa_value}
    log    ${all_pa_trun_off}
    log    ${test_case_prefix}
    ${test_name_prefix}     Set Variable If    '${test_case_prefix}'=='${None}'    ${TEST NAME.split('_')[0]}
    ...       ${test_case_prefix}
    Set Test Variable    ${test_case_id}    ${test_name_prefix}
    Set Test Variable    ${case_params}    ${GNB_INFO_MAPPING_TO_CASE_TABLE['${test_case_id}']['${tl_prefix}']}
    Set Test Variable    ${PCELL_INDEX}    ${case_params.get('pcell_idx')}
    Set Test Variable    ${attenuator_list}    ${case_params.get('attenuator')}
    Set Test Variable    ${ca_technology}    ${case_params.get('ca_technology')}
    ${ca_technology_status}    Run Keyword And Return Status    Dictionary Should Contain Key    ${case_params}    ca_technology
    Run Keyword If    ${ca_technology_status}    Set Test Variable    ${scell_technology}
    ...                                                               ${case_params.get('ca_technology').split('+')[-1]}
    Set Test Variable    ${LTE_CELL_INDEX}    ${case_params.get('lte_cell_idx')}
    ${lte_whether_in_gnb}    Check LTE Whether In Gnb
    Set Test Variable    ${LTE_WHETHER_IN_GNB}    ${lte_whether_in_gnb}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    Set Test Variable    ${ue_type}
    Run Keyword If    ${all_pa_trun_off}    Trun Off All PA Ports
    Run Keyword If    ${whether_set_pa_value}    Set Case PA Or MCS Port Value    attenuator_list=${attenuator_list}
    ...    ue_index=${ue_index}

SetUp.TMO Case Common SetUp
    [Arguments]    ${is_first_gnb_used}=${False}
    ...            ${is_second_gnb_used}=${False}
    ...            ${is_commission_for_first_gnb}=${False}
    ...            ${is_commission_for_second_gnb}=${False}
    ...            ${active_sw_flag}=High
    ...            ${ue_index}=${0}
    ...            ${whether_set_pa_value}=${False}
    ...            ${gnb_scf_name_for_first_gnb}=${None}
    ...            ${gnb_scf_name_for_second_gnb}=${None}
    ...            ${all_pa_trun_off}=${True}
    ...            ${test_case_prefix}=${None}
    log    ${whether_set_pa_value}
    log    ${all_pa_trun_off}
    csn.reset_cache
    Create Case Log Path
    ${gnb_allowed_fault_Before_Commission}   Create List    4203    1838    4741    4681   7311   7331    7107
    ...                                                     4293    4297    4420    4775   1932   1934    1933    8150    6261
    ...    4569    8000
    Set Test Variable    ${gnb_allowed_fault_Before_Commission}
    robot_common_operations.Common Case Setup    fail_with_alarms=${False}
    AlarmWatchdog.add_allow_alarms    fault_id=${gnb_allowed_fault_Before_Commission}
    Run Keyword If    ${is_first_gnb_used}    SetUp.Precondition For First gNB    gnb_scf_name=${gnb_scf_name_for_first_gnb}
    ...    is_commission=${is_commission_for_first_gnb}    active_sw_flag=${active_sw_flag}
    Run Keyword If    ${is_second_gnb_used}    SetUp.Precondition For Second gNB    gnb_scf_name=${gnb_scf_name_for_second_gnb}
    ...    is_commission=${is_commission_for_second_gnb}    active_sw_flag=${active_sw_flag}
    SetUp.Case Common Operation    ue_index=${ue_index}    whether_set_pa_value=${whether_set_pa_value}
    ...    all_pa_trun_off=${all_pa_trun_off}    test_case_prefix=${test_case_prefix}
    ${currenttime}    robot.libraries.DateTime.Get current date    result_format=%Y-%m-%d%H:%M:%S
    Set Test Variable    ${TEST_EXECUTION_TIME}    ${currenttime}
