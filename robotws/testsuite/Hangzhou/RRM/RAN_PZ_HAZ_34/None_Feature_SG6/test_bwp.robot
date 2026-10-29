*** Settings ***
Documentation    Author: lei.jia@nokia-sbell.com
...    squad group:SG_06
...    Feature Modify BWP Related PARAMS and Start L3 call
Suite Setup    TMO_Sleeping_Cell_Suite_Setup    is_commission=${False}
Test Teardown    TMO_Common_Case_Teardown
Suite Teardown   Run Keyword And Ignore Error    COAM Teardown gnb connections
Force Tags    5G_RRM    SG_06

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/Resources.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/TMO/TMO_common_keywords.robot


*** Variables ***
${SBTS23R3_package_link}     https://artifactory-hz1.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-remote/build/SBTS23R3/
${SBTS23R2_package_link}     https://artifactory-hz1.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-remote/build/SBTS23R2
${SBTS00_package_link}       https://artifactory-hz1.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-remote/build/SBTS00
${SBTS23R1_package_link}     https://artifactory-hz1.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-remote/build/SBTS23R1


*** Keywords ***
Start Test Or Modify Params based on category
    [Documentation]   lei.jia@nokia-sbell.com
    [Arguments]    ${category_values}    ${test_count}    ${file_path}    ${SCF_PATH_ON_UTE}=/home/ute/SCF
    ...            ${gnb_index}=0    ${timeout}=${600}    ${connection}=GNB_OAM    ${is_pdl_checking_needed}=${True}
    log many    ${is_pdl_checking_needed}    ${SCF_PATH_ON_UTE}
    Sort List    ${category_values}
    FOR    ${category_value}    IN  @{category_values}
        &{dict_testing_records_for_output_csv_original}    Create dictionary
        ${dict_testing_records_for_output_csv} =    get_testing_related_params_based_on_testcount
        ...                      file_path=${file_path}
        ...                      test_count=${test_count}
        Run Keyword If    'parameter' in '${category_value.lower()}'    Generate And Modify BWP Params based on Test Count
        ...                                                                         file_path=${file_path}
        ...                                                                         test_count=${test_count}
        ...                                                                         category_value=${category_value}
        ...                                                                         connection=${connection}
        ...                                                                         gnb_index=${gnb_index}
        ...                                                                         timeout=${timeout}
        ...                                                            dict_testing_records_for_output_csv=${dict_testing_records_for_output_csv}
        ${unexpect_alarms_faultid}    ${Active_SW_Build}    Record Unexpect Alarms    allowed_faults=@{GNB_ALLOWED_FAULT}
        ${unexpect_history_alarms}    Record Unexpect History Alarms    allowed_faults=@{ALLOWED_HISTORY_FAULT}
        ${unexpect_alarms_len}    Get Length    ${unexpect_alarms_faultid}
        ${unexpect_history_alarms_len}    Get Length    ${unexpect_history_alarms}
        Set To Dictionary    ${dict_testing_records_for_output_csv}    Test_Build=${Active_SW_Build}
        Run Keyword If    ${unexpect_alarms_len} > 0    Set To Dictionary    ${dict_testing_records_for_output_csv}
        ...    UnexpectActiveAlarm=${unexpect_alarms_faultid}
        Run Keyword If    ${unexpect_history_alarms_len} > 0    Set To Dictionary    ${dict_testing_records_for_output_csv}
        ...    UnexpectHistoryAlarm=${unexpect_history_alarms}
        ${is_gnb_cell_onAir}    Run Keyword And Return Status    Check TMO Gnb Ready And All Cell On Air
        Run Keyword If    ${unexpect_alarms_len} > 0 or not ${is_gnb_cell_onAir}    Common_keywords.Collect Snapshot Log    timeout=${2400}
        ${ttitrace_ul_file}    ${ttitrace_dl_file}    Run Keyword If    'testing' in '${category_value.lower()}'
        ...                                    Start L3 call based on Category Testing
        ...                                                       file_path=${file_path}
        ...                                                       test_count=${test_count}
        ...                                                       testing_params=${dict_testing_records_for_output_csv}
#        Run Keyword And Continue On Failure    Run Keyword If    'testing' in '${category_value.lower()}'
#        ...                                   Evaluate Single UE Average Tput For With TTI
#        ...                                             ul_file_path=${ttitrace_ul_file}
#        ...                                             dl_file_path=${ttitrace_dl_file}
#        ...                                             dict_test_tput_and_bler=${dict_testing_records_for_output_csv}
    END
    [Return]    ${dict_testing_records_for_output_csv}

Get Ignored Alarms list based on Test Count
    [Documentation]   lei.jia@nokia-sbell.com
    [Arguments]    ${test_count}    ${file_path}    ${category_value}=Ignore_gNB_Fault_Alarm
    ${ignored_alarms_list}    get_parameters_value_based_on_testcount_and_category
    ...                      file_path=${file_path}
    ...                      test_count=${test_count}
    ...                      category_value=${category_value}
    ${ignored_alarms_list}    Set Variable    ${ignored_alarms_list.split(';')}
    [Return]    ${ignored_alarms_list}

Create Ignored GNB AND ENB Alarms list based on Test Count
    [Documentation]   lei.jia@nokia-sbell.com
    [Arguments]    ${test_count}    ${file_path}    ${category_values}
    Log To Console    "create ingored gnb and enb alarms list!"
    ${ignored_gnb_alarms}    Run Keyword If    'Ignore_gNB_Fault_Alarm' in ${category_values}
    ...                                             Get Ignored Alarms list based on Test Count
    ...                                                                         category_value=Ignore_gNB_Fault_Alarm
    ...                                                                         file_path=${file_path}
    ...                                                                         test_count=${test_count}
    ...      ELSE    Create List
    ${ignored_enb_alarms}    Run Keyword If    'Ignore_eNB_Fault_Alarm' in ${category_values}
    ...                                             Get Ignored Alarms list based on Test Count
    ...                                                                        category_value=Ignore_eNB_Fault_Alarm
    ...                                                                        file_path=${file_path}
    ...                                                                        test_count=${test_count}
    ...      ELSE    Create List
    ${ENB_ALLOWED_FAULT}    Create List    @{GNB_ALLOWED_FAULT}
    Set Suite Variable    ${ENB_ALLOWED_FAULT}
    ${ignored_gnb_alarms_length}    Get Length    ${ignored_gnb_alarms}
    ${ignored_enb_alarms_length}    Get Length    ${ignored_enb_alarms}
    ${ignored_gnb_alarms_list}    Run Keyword If    ${ignored_gnb_alarms_length}>=${1}    Convert alarms string list to dict list
    ...                                                                                       ignored_alarms=${ignored_gnb_alarms}
    ...    ELSE    Set Variable    ${ignored_gnb_alarms}
    ${ignored_enb_alarms_list}    Run Keyword If    ${ignored_enb_alarms_length}>=${1}     Convert alarms string list to dict list
    ...                                                                                       ignored_alarms=${ignored_enb_alarms}
    ...    ELSE    Set Variable    ${ignored_enb_alarms}
    ${GNB_ALLOWED_FAULT}    Run Keyword If    ${ignored_gnb_alarms_length}>=${1}    Combine Lists
    ...                     ${GNB_ALLOWED_FAULT} 	${ignored_gnb_alarms_list}
    ${ENB_ALLOWED_FAULT}    Run Keyword If    ${ignored_enb_alarms_length}>=${1}    Combine Lists
    ...                     ${ENB_ALLOWED_FAULT}    ${ignored_enb_alarms_list}

Convert alarms string list to dict list
    [Documentation]   lei.jia@nokia-sbell.com
    [Arguments]    ${ignored_alarms}
    @{ignored_alarms_list} = 	Create List
    FOR    ${fault_id}    IN    @{ignored_alarms}
        ${fault_id} = 	Convert To Integer    ${fault_id}
        &{fault_dict}     Create Dictionary     faultId=${fault_id}
        Append To List 	  ${ignored_alarms_list} 	${fault_dict}
    END
    [Return]    ${ignored_alarms_list}


Commission on GNB based on Test Count
    [Documentation]   lei.jia@nokia-sbell.com
    [Arguments]    ${test_count}    ${file_path}    ${category_value}=scf    ${SCF_PATH_ON_UTE}=/home/ute/SCF
    ...            ${gnb_index}=0    ${timeout}=${1200}    ${connection}=GNB_OAM    ${is_pdl_checking_needed}=${True}
    Log To Console    "Start to commission GNB for test_count ${test_count}!"
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${scf_name}    get_parameters_value_based_on_testcount_and_category
    ...                      file_path=${file_path}
    ...                      test_count=${test_count}
    ...                      category_value=${category_value}
    ${scf_length}    Get Length    ${scf_name}
    Run Keyword If     ${scf_length}>0    run keywords    COAM Commission with scf file
    ...                                     scf_file_path=${SCF_PATH_ON_UTE}/${scf_name}
    ...                                     connection=${connection}
    ...                                     timeout=${timeout}
    ...                                     is_pdl_checking_needed=${is_pdl_checking_needed}
    ...    AND          Wait Gnb Ready And Cell On Air    gnb_id=${gnb_index}
    ...                                                   timeout=${timeout}
    ...                                                   connection=${connection}

Start L3 call based on Category Testing
    [Documentation]   lei.jia@nokia-sbell.com
    [Arguments]    ${file_path}=${None}    ${test_count}=${None}    ${testing_params}=${None}
    ...    ${whether_do_stop_call}=${True}    ${ue_mode}=SA    ${3CC_support}=${False}
    log    ${file_path}
    Log To Console    "Start testing L3 call for test_count ${test_count}!"
    Run Keyword If    ${3CC_support}==${False}    Get CA Related Infomation    pcell_index=${PCELL_INDEX}
    ...    ELSE IF    ${3CC_support}    Get 3CC Related Infomation    pcell_index=${PCELL_INDEX}
    ${ue_index}   Convert To Integer 	${testing_params['TestUEIndex']}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    Set Test Variable    ${bwp_ue_type}    ${ue_type}
    ${ue_PcellIndex}   Convert To Integer 	${testing_params['PcellIndex']}
    ${ue_LteCellIndex}   Convert To Integer 	${testing_params['LteCellIndex']}
    ${ue_mode}    set variable         ${testing_params['TestUEMode']}
    ${TestMode}    set variable         ${testing_params['TestMode']}
    ${Attenuation_Start}    set variable         ${testing_params['Attenuation_Start']}
    ${Attenuation_End}    set variable         ${testing_params['Attenuation_End']}
    ${Attenuation_Step}    set variable         ${testing_params['Attenuation_Step']}
    ${TargetTput_DL}    set variable         ${testing_params['TargetTput_DL(Mbps)']}
    ${TargetTput_UL}    set variable         ${testing_params['TargetTput_UL(Mbps)']}
    ${pa_off_value}   set variable if    '${TestMode}'=='Fixed'    ${Attenuation_Start}    ${None}
    Set Test Variable     ${PCELL_INDEX}    ${ue_PcellIndex}
    Set Test Variable     ${LTE_CELL_INDEX}    ${ue_LteCellIndex}
    Run Keyword If    ${pa_off_value}!=${None}    Set Case PA Or MCS Port Value    attenuator_list=${attenuator_list}
    ...    ue_index=${ue_index}    whether_do_mcs_setup=${False}    pa_off_value=${pa_off_value}
    Run Keyword If     '${ue_mode}'=='SA'    Change cellBarred Parameter Value Of Lte Cells
    ...                                      list_cell_ids=all    exp_status=barred    enb_index=${0}
    ${fdd_enb_index}    Select ENB Index based on LTE Technology    used_enb_technology=FDD
    Run Keyword If     '${ue_mode}'=='SA'    Change cellBarred Parameter Value Of Lte Cells
    ...                                      list_cell_ids=all    exp_status=barred
    ...                                      enb_index=${fdd_enb_index}
    ${exp_status}   set variable if    '${ue_mode}'=='SA'    notBarred    barred
    ${whether_check_tupt}   set variable if    '${TestMode}'=='Fixed'    ${True}    ${False}
    ${whether_do_lte_barred_action}   set variable if    '${ue_mode}'=='SA'    ${False}    ${True}
    ${notbarred_cell_index}   set variable if    '${ue_mode}'=='SA'    ${PCELL_INDEX}    all
    Modify PA Value Setting For Required RU    modify_ru_id=1
    ...    ue_index=${15}
    Modify PA Value Setting For Required RU    modify_ru_id=4
    ...    ue_index=${15}
    Modify PA Value Setting For Required RU    modify_ru_id=7
    ...    ue_index=${15}
    Procedures.Verify CA Basic L3 Call    ul_throughput=190M    dl_throughput=2500MKbits/sec
    ...                                   ue_mode=${ue_mode}
    ...                                   whether_do_barred_action=${True}
    ...                                   exp_status=${exp_status}
    ...                                   whether_do_lte_barred_action=${whether_do_lte_barred_action}
    ...                                   whether_check_tupt=${whether_check_tupt}
    ...                                   notbarred_cell_index=${notbarred_cell_index}
    ...                                   enb_index=${fdd_enb_index}
    ...                                   whether_do_ue_prepare=${False}
    ...                                   ue_index=${ue_index}
    ...                                   ue_type=${bwp_ue_type}
    ...                                   target_DL_avg_percent=0.5
    ...                                   target_UL_avg_percent=0.5
    ...                                   min_DL_percent=0.1
    ...                                   min_UL_percent=0.1
    ${bbmod_slots_id}    Get TTI used BBMOD ID based on cell id    cell_index=${PCELL_INDEX}
    ${ttitrace_ul_file}    ${ttitrace_dl_file}    Run Keyword If     '${TestMode}'=='Attenuation'
    ...                                Set Attenuation From Start To End And Check Tput
    ...                                    ue_index=${ue_index}    Attenuation_Start=${Attenuation_Start}    Attenuation_End=${Attenuation_End}
    ...                                    Attenuation_Step=${Attenuation_Step}    TargetTput_DL=${TargetTput_DL}
    ...                                    TargetTput_UL=${TargetTput_UL}    bbmod_slots=${bbmod_slots_id}    cell_index=${PCELL_INDEX}
    ...    ELSE IF    '${TestMode}'=='Fixed'
    ...                                     Get UL And DL TTI Logs
    Run Keyword If    ${whether_do_stop_call}    Procedures.Stop TMO L3 Call And Detach    ue_index=${ue_index}    ue_type=${ue_type}
    [Return]    ${ttitrace_ul_file}    ${ttitrace_dl_file}

Capture TTI Trace for ul and dl
    [Documentation]   lei.jia@nokia-sbell.com
    [Arguments]    ${bbmod_slots}=1
    ...            ${duration}=20
    ...            ${cell_index}=1
    ...            ${gnb_logs_script_path}=/home/ute/gnb_logs
    ...            ${gnb_index}=0
    ...            ${du_index}=0
    ...            ${target_dir}=${TS_CASE_LOG_PATH}
    ...            ${direction}=ul
    ...            ${remove_files_needed}=${True}
    log    ${direction}
    log    ${gnb_logs_script_path}
    log    ${gnb_index}
    log    ${du_index}
    log    ${target_dir}
    log    ${remove_files_needed}
    Log To Console    \nCapture TTI with gnb logs
#    Capture Logs With gNB_logs    bbmod_slots=${bbmod_slots}    duration=${duration}
#    ...                           gnb_logs_script_path=${gnb_logs_script_path}    timeout=900
#    ...                           gnb_index=${gnb_index}    du_index=${du_index}    cell_index=${du_index}
#    ${ttitrace_ul_file}    Get Specific TTItrace File    target_dir=${target_dir}
#    ...                                                             cell_index=${cell_index}
#    ...                                                             gnb_logs_script_path=${gnb_logs_script_path}
#    ...                                                             direction=ul
#    ...                                                             gnb_index=${gnb_index}    du_index=${du_index}
#    ...                                                             remove_files_needed=${remove_files_needed}
#    ${ttitrace_dl_file}    Get Specific TTItrace File    target_dir=${target_dir}
#    ...                                                             cell_index=${cell_index}
#    ...                                                             gnb_logs_script_path=${gnb_logs_script_path}
#    ...                                                             direction=dl
#    ...                                                             gnb_index=${gnb_index}    du_index=${du_index}
#    ...                                                             remove_files_needed=${remove_files_needed}
    ${ttitrace_ul_file}    Run Keyword And Continue On Failure       Capture TTI with gnb logs
    ...    bbmod_slots=${bbmod_slots}
    ...    cell_index=${cell_index}
    ...    duration=${duration}
    ...    direction=ul
    ...    tti_log_option=T
    ...    tti_package_file_name=tti_packed
    ${ttitrace_dl_file}    Run Keyword And Continue On Failure       Capture TTI with gnb logs
    ...    bbmod_slots=${bbmod_slots}
    ...    cell_index=${cell_index}
    ...    duration=${duration}
    ...    direction=dl
    ...    tti_log_option=T
    ...    tti_package_file_name=tti_packed
    [Return]    ${ttitrace_ul_file}    ${ttitrace_dl_file}


Set Attenuation From Start To End And Check Tput
    [Documentation]   lei.jia@nokia-sbell.com
    [Arguments]    ${ue_index}=${0}    ${Attenuation_Start}=${None}    ${Attenuation_End}=${None}    ${cell_index}=1
    ...    ${Attenuation_Step}=${None}    ${TargetTput_DL}=${None}     ${TargetTput_UL}=${None}    ${bbmod_slots}=1
    log   ${cell_index}
    ${ttitrace_ul_file}    Set Variable    ${None}
    ${ttitrace_dl_file}    Set Variable    ${None}
    log many   ${TargetTput_DL}    ${TargetTput_UL}    ${bbmod_slots}
    Log To Console    \n***modify att from ${Attenuation_Start}db to ${Attenuation_End}db, and check tput***\n
#    Start Capture L2Trace WO Duration With gNB_logs    cell_index=${cell_index}
    FOR    ${att_value}   IN RANGE    ${Attenuation_Start}    ${Attenuation_End}    ${Attenuation_Step}
            Set Case PA Or MCS Port Value    attenuator_list=${attenuator_list}
            ...    ue_index=${ue_index}    pa_off_value=${att_value}    whether_do_mcs_setup=${True}
            sleep    0.5s
    END
#    Stop Capture Trace WO Duration With gNB_logs
#    ${ttitrace_ul_file}    ${ttitrace_dl_file}    Get UL And DL TTI Logs
    [Return]    ${ttitrace_ul_file}    ${ttitrace_dl_file}

Generate And Modify BWP Params based on Test Count
    [Documentation]   lei.jia@nokia-sbell.com
    [Arguments]    ${test_count}    ${category_value}    ${file_path}    ${dict_testing_records_for_output_csv}=${None}
    ...            ${gnb_index}=0    ${timeout}=${600}    ${connection}=GNB_OAM
    ...            ${skip_parameter_relation_errors}=${False}
    log    ${skip_parameter_relation_errors}
    log    ${dict_testing_records_for_output_csv}
    log    ${category_value}
    log    ${file_path}
    Log To Console    "Start generate chbw related parameters for test_count ${test_count}!"
    ${bts_name}    ${sw_version}    Wait Until Keyword Succeeds    3x    30s
    ...     Get BtsName and SwVersion    gnb_id=${gnb_index}    connection=${connection}
    ${release_info}    Set Variable     ${sw_version.split('_')[0].split('BTS')[1]}
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${updated_params}    ${deleted_params}    ${added_params}   ${bwp_diff_list}     generate_modified_params_bwp
    ...     testcount=${test_count}    release=${release_info}
#    ${delete_params_delta}    coam_parameter.create_delete_parameters_delta     parameters=${deleted_params}
#    ...    connection=${connection}
#    coam_parameter.perform_scf_delta_commission    delta_file=${delete_params_delta['updated']}
#    ...    skip_parameter_relation_errors=True
#    ...    should_activate=True
#    ...    timeout=600
#    ...    connection=${connection}
    ${update_params_delta}    coam_parameter.Create Update Parameters Delta     parameters=${updated_params}
    ...    connection=${connection}    timeout=600
    ${status1}    ${update_params_bwp_delta1}    Run Keyword And Ignore Error
    ...    coam_parameter.Create Update Parameters Delta     parameters=${added_params}
    ...    connection=${connection}    timeout=600
    ${status2}    ${update_params_bwp_delta2}    Run Keyword And Ignore Error
    ...    coam_parameter.create_add_parameters_delta     parameters=${added_params}
    ...    connection=${connection}
    ${status3}    ${update_params_bwp_delta3}    Run Keyword And Ignore Error
    ...    conver_bwp_params_to_json_file    bwp_params=${added_params}
    ...    output_file=/home/ute/BWP/parameter_modified_bwp.json
    ${update_params_bwp_delta}    Run Keyword If   '${status1}'=='PASS'    Set Variable    ${update_params_bwp_delta1['updated']}
    ...    ELSE IF   '${status2}'=='PASS'    Set Variable    ${update_params_bwp_delta2['updated']}
    ...    ELSE     Set Variable    ${update_params_bwp_delta3}
    process_json   json_file=${update_params_bwp_delta}
    ...    output_file=/home/ute/BWP/parameter_modified_update.json
    ...    deleted_file=/home/ute/BWP/parameter_modified_delete.json
    ...    distname_cellbwpid_list=${bwp_diff_list}
    ${params_delta}    Create List    /home/ute/BWP/parameter_modified_update.json
    ...      ${update_params_delta['updated']}
    log to console      update delta is :${params_delta}
    ${delta_json}    merge_JsonFiles    filename=${params_delta}    output_file_path=/home/ute/BWP/parameter_modified_all.json
    coam_parameter.perform_scf_delta_commission    delta_file=/home/ute/BWP/parameter_modified_all.json
    ...    skip_parameter_relation_errors=True
    ...    should_activate=True
    ...    timeout=600
    ...    connection=${connection}
#    Perform gNB Reset site and Wait Onair    connection=${connection}
    Run Keyword And Continue On Failure    Wait Gnb Ready And Cell On Air    timeout=20 min    connection=${connection}
    Connect to gnb coam via ssl    connection=GNB_OAM
    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist   allowed_faults=${GNB_ALLOWED_FAULT}
    Run Keyword If     '${LTE_WHETHER_IN_GNB}'=='${False}'    Check ENB On Air And Unexpect Alarm Should Not Exist    timeout=${timeout}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Change bwp related params with coam adimn
    [Arguments]    ${updated_params}    ${added_params}    ${deleted_params}
    ...            ${timeout}=${600}    ${connection}=GNB_OAM
    Run Keyword If    ${added_params}    Run Keywords
    ...           Run Keyword And Ignore Error    COAM delete parameters via rest api
    ...                                    parameters_to_delete_via_api=${deleted_params}
    ...                                    timeout=${timeout}
    ...                                    connection=${connection}
    ...    AND    Run Keyword And Ignore Error    COAM add several parameters via rest api
    ...                                    parameters_to_add_via_api=${added_params}
    ...                                    timeout=${timeout}
    ...                                    connection=${connection}
    Sleep    30s
    COAM Update several parameters via rest api    parameters_to_update_via_api=${updated_params}
    ...                                    timeout=${timeout}
    ...                                    connection=${connection}

Change bwp related params with WebUI
    [Arguments]    ${updated_params}    ${added_params}    ${deleted_params}    ${whether_login_selenium}=${True}
    ...            ${dict_testing_records_for_output_csv}=${None}
    ${paramlist_len}    get length   ${updated_params}
    ${paramadd_len}    get length    ${added_params}
    ${paramdel_len}    get length    ${deleted_params}
    run keyword if   ${whether_login_selenium}    Login To WEBUI With Selenium     browser=Chrome
#    run keyword if   ${whether_login_selenium}    Run Keywords
#    ...    COAM Navigate to login page via webUI    download_dir=${TS_CASE_LOG_PATH}    AND
#    ...    selenium_coam.enable_virtual_display
    log to console    --- start to delete parameters via webui---
    FOR  ${i}  IN RANGE  ${paramdel_len}
        ${node_index}    Set Variable    ${deleted_params[${i}].get('node_index', ${None})}
        ${abbr}    Set Variable    ${deleted_params[${i}].get('abbr', ${None})}
        ${dist_name}    Set Variable If    'NRCELL' in '${deleted_params[${i}]['dist_name']}'
        ...    ${deleted_params[${i}]['dist_name'].split('/')[-1]}    ${deleted_params[${i}]['dist_name']}
        log to console    “try ${i}, delete ${abbr} for ${deleted_params[${i}]['dist_name']} node_index${node_index}”
        WEBUI Set Param And Remove Element
        ...   dist_name=${dist_name}
        ...   filter_param=${deleted_params[${i}]['filter_param']}
        ...   new_value=${None}
        ...   node_index=${node_index}
    END
    log to console    --- start to add parameters via webui---
    FOR  ${i}  IN RANGE  ${paramadd_len}
        ${new_value}    Set Variable    ${added_params[${i}].get('new_value', ${None})}
        ${new_value}    Set Variable if    '${new_value}'=='FALSE' or '${new_value}'=='TRUE'    ${new_value.lower()}    ${new_value}
        ${abbr}    Set Variable    ${added_params[${i}].get('abbr', ${None})}
        ${bwpdn_index}    Set Variable    ${added_params[${i}].get('bwpdn_index', ${added_params[${i}]['node_index']})}
        ${dist_name}    Set Variable If    'NRCELL' in '${added_params[${i}]['dist_name']}'
        ...    ${added_params[${i}]['dist_name'].split('/')[-1]}    ${added_params[${i}]['dist_name']}
        log to console    “try ${i}, add ${abbr} to ${new_value} for ${added_params[${i}]['dist_name']}”
        WEBUI Add Element For bwpDN
        ...   dist_name=${dist_name}
        ...   filter_param=${added_params[${i}]['filter_param']}
        ...   new_value=${new_value}
        ...   bwpdn_index=${bwpdn_index}
        ...   node_index=${added_params[${i}]['node_index']}
    END
    log to console    --- start to modify parameters via webui---
    FOR  ${i}  IN RANGE  ${paramlist_len}
        ${new_value}    Set Variable    ${updated_params[${i}].get('new_value', ${None})}
        ${new_value}    Set Variable if    '${new_value}'=='FALSE' or '${new_value}'=='TRUE'    ${new_value.lower()}    ${new_value}
        ${node_index}    Set Variable    ${updated_params[${i}].get('node_index', ${None})}
        ${abbr}    Set Variable    ${updated_params[${i}].get('abbr', ${None})}
        ${dist_name}    Set Variable If    'NRCELL' in '${updated_params[${i}]['dist_name']}'
        ...    ${updated_params[${i}]['dist_name'].split('/')[-1]}    ${updated_params[${i}]['dist_name']}
        log to console    “try ${i}, modify ${abbr} to ${new_value} for ${updated_params[${i}]['dist_name']}”
        WEBUI Set Param And Remove Element
        ...   dist_name=${dist_name}
        ...   filter_param=${updated_params[${i}]['filter_param']}
        ...   new_value=${new_value}
        ...   node_index=${node_index}
    END
    log to console    --- start to validate and activate plan---
    selenium_coam.validate_plan
    ${status}    run keyword and return status    COAM check validation errors from webui    is_need_to_check_validation_errors=${True}
    run keyword if  not ${status}    Set To Dictionary    ${dict_testing_records_for_output_csv}
    ...               PDLError=PDL ERROR!
    Run Keyword And Continue On Failure    run keyword if  not ${status}    Fail    msg=pdl error exist。
    Run Keyword If    ${status}    selenium_coam.activate_plan   download_plan_without_activation=${False}
    ...    activate_plan_despite_errors=${True}
    ...   execute=${True}   timeout=600
    sleep  30s
#    Close Start Up View    timeout=60
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    COAM selenium logout    AND
    ...    Run Keyword And Ignore Error    selenium_coam.disable_message_box

WEBUI Set Param And Remove Element
    [Arguments]   ${dist_name}   ${filter_param}   ${new_value}    ${node_index}=${0}
    run keyword if   '${new_value}'=='${None}'    Wait Until Keyword Succeeds    2x    5sec    WebUI Get AND Remove element
    ...   dist_name=${dist_name}
    ...   filter_param=${filter_param}
    ...   node_index=${node_index}
    ...    ELSE    Wait Until Keyword Succeeds    2x    5sec    WEBUI Set Parameter Value
    ...   dist_name=${dist_name}
    ...   filter_param=${filter_param}
    ...   new_value=${new_value}
    ...   node_index=${node_index}

WEBUI Set Parameter Value
    [Documentation]   Set Parameter Value
    [Arguments]   ${dist_name}   ${filter_param}   ${new_value}    ${node_index}=${0}
    ${value}    Run Keyword And Return Status    selenium_coam.get_parameter_value    dist_name=${dist_name}
     ...                filter_param=${filter_param}    node_index=${node_index}    abbr=${abbr}    timeout=${300}
    run keyword if   '${new_value}'!='${value}'    selenium_coam.set_parameter_value
    ...   dist_name=${dist_name}
    ...   filter_param=${filter_param}
    ...   new_value=${new_value}
    ...   node_index=${node_index}
    ...   timeout=${300}

WEBUI Add Element For bwpDN
    [Documentation]   only for adding bwpDN and set parameter value
    [Arguments]   ${dist_name}   ${filter_param}    ${new_value}    ${bwpdn_index}    ${node_index}=${0}
    selenium_coam.add_element
    ...    dist_name=${dist_name}    filter_param=Cell bandwidth part list
    selenium_coam.set_parameter_value
    ...    dist_name=${dist_name}
    ...    filter_param=Cell bandwidth part Identifier
    ...    new_value=str(${node_index})
    ...    node_index=${bwpdn_index}
    ...    timeout=${300}
    selenium_coam.set_parameter_value
    ...    dist_name=${dist_name}
    ...    filter_param=${filter_param}
    ...    new_value=${new_value}
    ...    node_index=${bwpdn_index}
    ...    timeout=${300}
    sleep    1s

Modify CellType releated param WEBMEM
    [Arguments]   ${MRBTS_id}=${tl.gnbs[0].instance_id}    ${NRBTS_ID}=${tl.gnbs[0].global_bts_id}    ${cell_id}=301
    ...           ${nrCellType_value}=8DL8UL
    WEBUI Set Parameter Value    dist_name=MRBTS-${MRBTS_id}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
    ...    filter_param=NR Cell type   abbr=nrCellType   new_value=${nrCellType_value}

Remove The Channel WEBMEM
    [Arguments]   ${MRBTS_id}=${tl.gnbs[0].instance_id}    ${cell_id}=301   ${channelgrp_id}=2    ${channel_id}=1
    selenium_coam.remove_object
    ...    object_name=MRBTS-${MRBTS_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id}/CHANNELGROUP-${channelgrp_id}/CHANNEL-${channel_id}
    ...    timeout=300

Remove The Channelgrp WEBMEM
    [Arguments]   ${MRBTS_id}=${tl.gnbs[0].instance_id}    ${cell_id}=301   ${channelgrp_id}=2
    ${value_status}    Run Keyword And Return Status    selenium_coam.get_parameter_value    dist_name=LCELNR-${cell_id}/CHANNELGROUP-${channelgrp_id}
    ...                filter_param=Channel Group identifier    abbr=channelGroupId    timeout=${300}
    run keyword if    ${value_status}    selenium_coam.remove_object
    ...    object_name=MRBTS-${MRBTS_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id}/CHANNELGROUP-${channelgrp_id}
    ...    timeout=300

Get and Update nrcellType related params
    [Documentation]   lei.jia@nokia-sbell.com
    [Arguments]    ${file_path}    ${test_count}
    ${is_nrcelltype_exist}    Run Keyword And Return Status    get_nrCellType_related_params_based_on_testcount
    ...                      file_path=${file_path}
    ...                      test_count=${test_count}
    Run Keyword If    ${is_nrcelltype_exist}        Get and Update nrcellType related params while nrcelltype exist
    ...                      file_path=${file_path}
    ...                      test_count=${test_count}
    [Teardown]    Run Keyword And Ignore Error    run    command=ps -ef | grep firefox |awk '{print $2}' | xargs kill -9

Get and Update nrcellType related params while nrcelltype exist
    [Documentation]   lei.jia@nokia-sbell.com
    [Arguments]    ${file_path}    ${test_count}
    ${nrcelltype_values}    ${celltype_related_params}    get_nrCellType_related_params_based_on_testcount
    ...                      file_path=${file_path}
    ...                      test_count=${test_count}
    ${nrcelltype_length}    Get Length    ${nrcelltype_values}
    Run Keyword If    '${nrcelltype_length}'!='${0}'    WebUI update nrcellType related params
    ...                                                 nrcelltype_values=${nrcelltype_values}
    ...                                                 celltype_related_params=${celltype_related_params}

WebUI update nrcellType related params
    [Documentation]   lei.jia@nokia-sbell.com
    [Arguments]    ${nrcelltype_values}    ${celltype_related_params}
    Selenium Login And Disable Screen Lock    browser=Chrome
    WebUI Get nrCellType Parameter Value and Modify Channel Group    nrcelltype_values=${nrcelltype_values}
    Change bwp related params with WebUI    updated_params=${celltype_related_params}    added_params=${EMPTY}
    ...                                     deleted_params=${EMPTY}    whether_login_selenium=${False}
    Check TMO Gnb Ready And All Cell On Air
    Verify All Enbs Cell On Air
    [Teardown]    run keyword and ignore error    selenium logout and close browser

WebUI Get nrCellType Parameter Value and Modify Channel Group
     [Arguments]    ${nrcelltype_values}
    FOR    ${item}    IN    @{nrcelltype_values}
        ${cur_nrcelltype_value}    WebUI Get Parameter Value    dist_name=${item['dist_name']}
        ...        filter_param=${item['filter_param']}    abbr=${item['abbr']}    node_index=${None}
        ${new_value}    Set Variable    ${item.get('new_value', ${None})}
        Run keyword if    '${cur_nrcelltype_value}'=='8DL4UL' and '${new_value}'=='8DL8UL'    WEBUI Add Channel From 8DL4UL to 8DL8UL
        Run keyword if    '${cur_nrcelltype_value}'=='8DL4UL' and '${new_value}'=='16DL8UL'    WEBUI Add Channelgrp From 8DL4UL to 16DL8UL
        Run keyword if    '${cur_nrcelltype_value}'=='8DL8UL' and '${new_value}'=='16DL8UL'    WEBUI Add Channelgrp From 8DL8UL to 16DL8UL
        Run keyword if    '${cur_nrcelltype_value}'=='8DL8UL' and '${new_value}'=='8DL4UL'    WEBUI Remove Channel From 8DL8UL to 8DL4UL
        Run keyword if    '${cur_nrcelltype_value}'=='16DL8UL' and '${new_value}'=='8DL8UL'    WEBUI Remove Channelgrp From 16DL8UL to 8DL8UL
        Run keyword if    '${cur_nrcelltype_value}'=='16DL8UL' and '${new_value}'=='8DL4UL'    WEBUI Remove Channelgrp From 16DL8UL to 8DL4UL
    END

WEBUI Remove Channel From 8DL8UL to 8DL4UL
    [Documentation]   remove RX channel 5/6/7/8
    [Arguments]   ${cell_id}=301   ${channelgrp_id}=2
    Remove The Channel WEBMEM    cell_id=${cell_id}   channelgrp_id=${channelgrp_id}    channel_id=5
    Remove The Channel WEBMEM    cell_id=${cell_id}   channelgrp_id=${channelgrp_id}    channel_id=6
    Remove The Channel WEBMEM    cell_id=${cell_id}   channelgrp_id=${channelgrp_id}    channel_id=7
    Remove The Channel WEBMEM    cell_id=${cell_id}   channelgrp_id=${channelgrp_id}    channel_id=8

WEBUI Remove Channelgrp From 16DL8UL to 8DL4UL
    [Documentation]   remove RX channel 5/6/7/8 and channelgrp 3/4
    [Arguments]   ${cell_id}=301   ${channelgrp_id}=2    ${channelgrp3_id}=3    ${channelgrp4_id}=4
    Remove The Channelgrp WEBMEM    cell_id=${cell_id}   channelgrp_id=${channelgrp3_id}
    Remove The Channelgrp WEBMEM    cell_id=${cell_id}   channelgrp_id=${channelgrp4_id}
    Remove The Channel WEBMEM    cell_id=${cell_id}   channelgrp_id=${channelgrp_id}    channel_id=5
    Remove The Channel WEBMEM    cell_id=${cell_id}   channelgrp_id=${channelgrp_id}    channel_id=6
    Remove The Channel WEBMEM    cell_id=${cell_id}   channelgrp_id=${channelgrp_id}    channel_id=7
    Remove The Channel WEBMEM    cell_id=${cell_id}   channelgrp_id=${channelgrp_id}    channel_id=8

WEBUI Remove Channelgrp From 16DL8UL to 8DL8UL
    [Documentation]   remove channel Group3/4
    [Arguments]   ${cell_id}=301   ${channelgrp3_id}=3    ${channelgrp4_id}=4
    Remove The Channelgrp WEBMEM    cell_id=${cell_id}   channelgrp_id=${channelgrp3_id}
    Remove The Channelgrp WEBMEM    cell_id=${cell_id}   channelgrp_id=${channelgrp4_id}

WEBUI Add Channel From 8DL4UL to 8DL8UL
    [Documentation]   add channel group for one cell
    [Arguments]   ${cell_id}=301   ${channelgrp_id}=2
    WEBUI Add Object For Channel    cell_id=${cell_id}   channelgrp_id=${channelgrp_id}    channel_id=5
    WEBUI Add Object For Channel    cell_id=${cell_id}   channelgrp_id=${channelgrp_id}    channel_id=6
    WEBUI Add Object For Channel    cell_id=${cell_id}   channelgrp_id=${channelgrp_id}    channel_id=7
    WEBUI Add Object For Channel    cell_id=${cell_id}   channelgrp_id=${channelgrp_id}    channel_id=8
    WEBUI Set Parameter Value FOR TX Channels    cell_id=${cell_id}   channelgrp_id=${channelgrp_id}
    WEBUI Set Parameter Value FOR RX Channels    cell_id=${cell_id}   channelgrp_id=${channelgrp_id}

WEBUI Add Channelgrp From 8DL4UL to 16DL8UL
    [Documentation]   add channel group for one cell
    [Arguments]   ${cell_id}=301   ${channelgrp_id}=2    ${channelgrp3_id}=3    ${channelgrp4_id}=4
    WEBUI Add Channel From 8DL4UL to 8DL8UL    cell_id=${cell_id}   channelgrp_id=${channelgrp_id}
    WEBUI Add Channelgrp From 8DL8UL to 16DL8UL    cell_id=${cell_id}
    ...                                            channelgrp3_id=${channelgrp3_id}    channelgrp4_id=${channelgrp4_id}

WEBUI Add Channelgrp From 8DL8UL to 16DL8UL
    [Documentation]   add channel group for one cell
    [Arguments]   ${cell_id}=301   ${channelgrp3_id}=3    ${channelgrp4_id}=4
    WEBUI Add Object For Channelgrp      cell_id=${cell_id}   channelgrp_id=${channelgrp3_id}
    Remove The Channel WEBMEM    cell_id=${cell_id}   channelgrp_id=${channelgrp3_id}    channel_id=5
    Remove The Channel WEBMEM    cell_id=${cell_id}   channelgrp_id=${channelgrp3_id}    channel_id=6
    Remove The Channel WEBMEM    cell_id=${cell_id}   channelgrp_id=${channelgrp3_id}    channel_id=7
    Remove The Channel WEBMEM    cell_id=${cell_id}   channelgrp_id=${channelgrp3_id}    channel_id=8
    WEBUI Set Parameter Value FOR TX Channels    cell_id=${cell_id}   channelgrp_id=${channelgrp3_id}
    WEBUI Add Object For Channelgrp      cell_id=${cell_id}   channelgrp_id=${channelgrp4_id}
    Remove The Channel WEBMEM    cell_id=${cell_id}   channelgrp_id=${channelgrp4_id}    channel_id=5
    Remove The Channel WEBMEM    cell_id=${cell_id}   channelgrp_id=${channelgrp4_id}    channel_id=6
    Remove The Channel WEBMEM    cell_id=${cell_id}   channelgrp_id=${channelgrp4_id}    channel_id=7
    Remove The Channel WEBMEM    cell_id=${cell_id}   channelgrp_id=${channelgrp4_id}    channel_id=8
    WEBUI Set Parameter Value FOR TX Channels    cell_id=${cell_id}   channelgrp_id=${channelgrp4_id}

WebUI Get Parameter Value
     [Arguments]    ${dist_name}    ${filter_param}   ${abbr}    ${node_index}
     ${value}    selenium_coam.get_parameter_value    dist_name=${dist_name}
     ...                filter_param=${filter_param}    node_index=${node_index}    abbr=${abbr}    timeout=${300}
     [Return]    ${value}

WEBUI Add Object For Channelgrp
    [Documentation]   add channel group for one cell
    [Arguments]   ${cell_id}=301   ${channelgrp_id}=2    ${MRBTS_id}=${tl.gnbs[0].instance_id}
    selenium_coam.add_object   object_name=MRBTS-${MRBTS_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id}
    ...   object_class_name=CHANNELGROUP
    ...   plan_to_copy_from=CURRENT_BTS_CONF-1
    ...   copy_from=MRBTS-${MRBTS_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id}/CHANNELGROUP-1
    ...   include_subobject=${true}   id_value=${channelgrp_id}   is_load_default_values=${false}

WEBUI Add Object For Channel
    [Documentation]   add channel for one cell
    [Arguments]   ${cell_id}=301   ${channelgrp_id}=2    ${MRBTS_id}=${tl.gnbs[0].instance_id}    ${channel_id}=5
    selenium_coam.add_object   object_name=MRBTS-${MRBTS_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id}/CHANNELGROUP-${channelgrp_id}
    ...   object_class_name=CHANNEL
    ...   plan_to_copy_from=CURRENT_BTS_CONF-1
    ...   copy_from=MRBTS-${MRBTS_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id}/CHANNELGROUP-1/CHANNEL-${channel_id}
    ...   include_subobject=${true}   id_value=${channel_id}   is_load_default_values=${false}

WEBUI Set Parameter Value FOR TX Channels
    [Documentation]   channel 1-4 is Tx
    [Arguments]   ${cell_id}=301   ${channelgrp_id}=2    ${MRBTS_id}=${tl.gnbs[0].instance_id}
    FOR   ${channel_id}   IN RANGE   1   5
        selenium_coam.set_parameter_value
        ...    dist_name=MRBTS-${MRBTS_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id}/CHANNELGROUP-${channelgrp_id}/CHANNEL-${channel_id}
        ...   filter_param=Direction of the channel   abbr=direction    new_value=TX
    END

WEBUI Set Parameter Value FOR RX Channels
    [Documentation]   channel 5-8 is RX
    [Arguments]   ${cell_id}=301   ${channelgrp_id}=2    ${MRBTS_id}=${tl.gnbs[0].instance_id}
    FOR   ${channel_id}   IN RANGE   5   9
        selenium_coam.set_parameter_value
        ...    dist_name=MRBTS-${MRBTS_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id}/CHANNELGROUP-${channelgrp_id}/CHANNEL-${channel_id}
        ...   filter_param=Direction of the channel   abbr=direction    new_value=RX
    END

WebUI Get AND Remove element
     [Arguments]    ${dist_name}    ${filter_param}   ${node_index}
     ${value_status}    Run Keyword And Return Status    selenium_coam.get_parameter_value    dist_name=${dist_name}
     ...                filter_param=${filter_param}    node_index=${node_index}    timeout=${300}
     run keyword if    ${value_status}    selenium_coam.remove_element
     ...   dist_name=${dist_name}
     ...   filter_param=${filter_param}
     ...   node_index=${node_index}

Evaluate Single UE Average Tput For With TTI
    [Documentation]    Author:lei.jia@nokia-sbell.com
    [Arguments]    ${dict_test_tput_and_bler}    ${ul_file_path}=${None}    ${dl_file_path}=${None}    ${is_bler_cal}=${True}
    ${ue_ultputs}    Run Keyword If    '${ul_file_path}' != '${None}'    Run Keyword And Continue On Failure
    ...    calculate_ubler_and_ultput_for_ues
    ...                                                                  file_path=${ul_file_path}
    ...                                                                  is_bler_cal=${is_bler_cal}
    ${ue_dltputs}    Run Keyword If    '${dl_file_path}' != '${None}'    calculate_dlbler_and_dltput_for_ues
    ...                                                                  file_path=${dl_file_path}
    ...                                                                  is_bler_cal=${is_bler_cal}
    ${ue_tputs_info}    Set Variable If    '${dl_file_path}' != '${None}'    ${ue_dltputs}    ${ue_ultputs}
    ${ue_rnti_list}    Get Dictionary Keys    ${ue_tputs_info}
    FOR    ${rnti}    IN    @{ue_rnti_list}
         Set to dictionary    ${dict_test_tput_and_bler}    UL_Thp_TTI(Mbps)=${ue_ultputs['${rnti}']['tput']}
         Set to dictionary    ${dict_test_tput_and_bler}    DL_Thp_TTI(Mbps)=${ue_dltputs['${rnti}']['tput']}
         ${dl_bler}    Evaluate    "%.2f%%" % (${ue_dltputs['${rnti}']['bler']} * 100)
         Set to dictionary    ${dict_test_tput_and_bler}    DL_BLER(%)=${dl_bler}
         ${dl_ibler}    Evaluate    "%.2f%%" % (${ue_dltputs['${rnti}']['ibler']} * 100)
         Set to dictionary    ${dict_test_tput_and_bler}    DL_iBLER(%)=${dl_ibler}
         ${ul_bler}    Evaluate    "%.2f%%" % (${ue_ultputs['${rnti}']['bler']} * 100)
         Set to dictionary    ${dict_test_tput_and_bler}    UL_BLER(%)=${ul_bler}
         ${ul_ibler}    Evaluate    "%.2f%%" % (${ue_ultputs['${rnti}']['ibler']} * 100)
         Set to dictionary    ${dict_test_tput_and_bler}    UL_iBLER(%)=${ul_ibler}
    END

Update chbw Params and Start Test based on csv file
    [Documentation]   lei.jia@nokia-sbell.com
    ...                this keyword is used modify chbw and bwpdn based on csv file.
    ...                input csv file be put under /home/ute folder, file name like: BWP_Auto_test_input_T283_V01.csv
    [Arguments]    ${local_input_file_folder}=/home/ute    ${SCF_PATH_ON_UTE}=/home/ute/SCF    ${local_output_log_folder}=/home/ute/KPI_report/
    ...            ${gnb_id}=0    ${timeout}=${1200}    ${connection}=GNB_OAM    ${is_pdl_checking_needed}=${True}
    ${file_path}    Join path     ${local_input_file_folder}    BWP_Auto_test_input_${tl_prefix}.csv
    ${csv_file_header_list}    ${csv_output_file_path}    Create Output CSV File Under Local Folder
     ...    local_output_log_folder=${local_output_log_folder}
    ${test_count_list}    get_testcount_from_csv_file    file_path=${file_path}
    FOR    ${test_count}    IN  @{test_count_list}
           ${category_values}    get_category_based_on_testcount    file_path=${file_path}    test_count=${test_count}
           ${current_run_time}=    DateTime.Get current date    exclude_millis=True    result_format=%Y-%m-%d_%H:%M:%S
           Run Keyword If    'upgrade' in ${category_values}    SW Upgrade based on Test Count
           ...                                                                         file_path=${file_path}
           ...                                                                         test_count=${test_count}
           Run Keyword If    'SCF' in ${category_values}    Commission on GNB based on Test Count
           ...                                                                         file_path=${file_path}
           ...                                                                         test_count=${test_count}
           ...                                                                         category_value=SCF
           ...                                                                         connection=${connection}
           ...                                                                         gnb_index=${gnb_id}
           ...                                                                         timeout=${timeout}
           ...                                                                         SCF_PATH_ON_UTE=${SCF_PATH_ON_UTE}
           ...                                                                         is_pdl_checking_needed=${is_pdl_checking_needed}
           sleep    45s
           Run Keyword If    'rollback' in ${category_values}    E2E_TL_SW_rollback
           Create Ignored GNB AND ENB Alarms list based on Test Count
           ...                                                                         file_path=${file_path}
           ...                                                                         test_count=${test_count}
           ...                                                                         category_values=${category_values}
           Get and Update nrcellType related params    file_path=${file_path}    test_count=${test_count}
           ${dict_testing_result_for_output_csv}     Start Test Or Modify Params based on category
           ...                                              category_values=${category_values}
           ...                                              test_count=${test_count}
           ...                                              file_path=${file_path}
           ...                                              connection=${connection}
           ...                                              gnb_index=${gnb_id}
           ...                                              timeout=${timeout}
           ...                                              SCF_PATH_ON_UTE=${SCF_PATH_ON_UTE}
           Set To Dictionary    ${dict_testing_result_for_output_csv}    Run_Time=${current_run_time}
           Report Test Results to CSV File    csv_file_header_list=${csv_file_header_list}
           ...                                csv_output_file_path=${csv_output_file_path}
           ...                                dict_testing_result_for_output_csv=${dict_testing_result_for_output_csv}
    END

Create Output CSV File Under Local Folder
    [Documentation]    Author: lei.jia@nokia-sbell.com
    [Arguments]    ${local_output_log_folder}=/home/ute/KPI_report/
    ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    ${csv_output_file_path}    Join path    ${local_output_log_folder}    BWP_Auto_test_output_${tl_prefix}_${timestamp}.csv
    ${status}    ${value}    Run Keyword And Ignore Error    File Should Not Exist    ${csv_output_file_path}
    Run Keyword If    '${status}'!='PASS'       Remove File    ${csv_output_file_path}
    ${data_header}      catenate
    ...                TestCount,
    ...                Scenario,
    ...                Test_Build,
    ...                Run_Time,
    ...                UnexpectActiveAlarm,
    ...                UnexpectHistoryAlarm,
    ...                PDLError,
    ...                TestUEIndex,
    ...                PcellIndex,
    ...                LteCellIndex,
    ...                TestUEMode,
    ...                TestMode,
    ...                Attenuation_Start,
    ...                Attenuation_End,
    ...                DL_Thp_TTI(Mbps),
    ...                DL_iBLER(%),
    ...                DL_BLER(%),
    ...                UL_Thp_TTI(Mbps),
    ...                UL_iBLER(%),
    ...                UL_BLER(%),
    ...                TargetTput_DL(Mbps),
    ...                TargetTput_UL(Mbps),
    ...                Target_Bler(%)\n
    Append To File    ${csv_output_file_path}    ${data_header}
    ${csv_file_header}    OperatingSystem.Get File    path=${csv_output_file_path}    encoding_errors=ignore
    ${csv_file_header_list}    Evaluate    [x.strip() for x in ${csv_file_header.split(',')}]
    [Return]    ${csv_file_header_list}    ${csv_output_file_path}

Report Test Results to CSV File
    [Documentation]    Author: lei.jia@nokia-sbell.com
    [Arguments]    ${csv_file_header_list}    ${csv_output_file_path}    ${dict_testing_result_for_output_csv}
    ${first_column}    Set Variable    ${csv_file_header_list[0]}
    ${test_results}    Set Variable    ${dict_testing_result_for_output_csv.get('${first_column}')},
    ${slice_csv_file_header_list}    Set Variable    ${csv_file_header_list[1:-1]}
    FOR    ${header_column}    IN  @{slice_csv_file_header_list}
       ${key} = 	Set Variable  	${header_column.strip()}
       ${value}    Set Variable    ${dict_testing_result_for_output_csv.get('${key}')}
       ${test_results}    catenate  ${test_results}    ${value},
    END
    ${test_results}    catenate  ${test_results}    ${dict_testing_result_for_output_csv.get('${csv_file_header_list[-1]}')}\n
    Append To File    ${csv_output_file_path}    ${test_results}

Record Unexpect Alarms
    [Documentation]   Author: lei.jia@nokia-sbell.com
    ...               Description: check unexpect alarm and report to csv file
    [Arguments]   ${allowed_faults}
    ...           ${file_path}=${TS_CASE_LOG_PATH}
    ...           ${connection}=GNB_OAM
    log    ${file_path}
    run keyword and ignore error    COAM Teardown gnb connections     connection=${connection}
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl    connection=${connection}
    ${Active_SW_Build}     coam.get_sw_version    connection=${connection}
    ${active_alarms_list}    coam.get_active_alarms    connection=${connection}
    ${active_alarms_num}     Get Length    ${active_alarms_list}
    ${unexpect_alarms_faultid}    Set Variable
    ${unexpect_alarms_faultid}    Create List
    FOR  ${alarm}  IN  @{active_alarms_list}
       Exit For Loop If   ${active_alarms_num}==${0}
       ${status}   Run Keyword And Return Status   Check Alarm Is Allowed
       ...                                         allowed_alarm_list=${allowed_faults}
       ...                                         check_alarm=${alarm}
       Run Keyword If   ${status}==${False}    Append To List    ${unexpect_alarms_faultid}   '${alarm['faultId']}: ${alarm['faultName']}'
    END
    ${unexpect_alarms_faultid}    Evaluate    '|'.join(str(x) for x in ${unexpect_alarms_faultid})
    [Return]    ${unexpect_alarms_faultid}    ${Active_SW_Build}

Record Unexpect History Alarms
    [Documentation]   Author: lei.jia@nokia-sbell.com
    ...               Description: check unexpect alarm and report to csv file
    [Arguments]   ${allowed_faults}
    ...           ${file_path}=${TS_CASE_LOG_PATH}
    ...           ${connection}=GNB_OAM
    log    ${file_path}
    run keyword and ignore error    COAM Teardown gnb connections     connection=${connection}
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl    connection=${connection}
    ${history_alarms_list}    coam.get_historic_alarms    connection=${connection}    timeout=100    load_history=${True}
    ${history_alarms_num}     Get Length    ${history_alarms_list}
    ${unexpect_history_alarms}    Create List
    ${empty_history_alarms}    Create List
    FOR  ${alarm}  IN  @{history_alarms_list}
       Exit For Loop If   ${history_alarms_num}==${0}
       ${status}   Run Keyword And Return Status   Check Alarm Is Allowed
       ...                                         allowed_alarm_list=${allowed_faults}
       ...                                         check_alarm=${alarm}
       Run Keyword If   ${status}==${False}    Append To List    ${unexpect_history_alarms}    '${alarm['faultId']}: ${alarm['faultName']}'
       ${unexpect_history_alarms_faultid}    Evaluate    '|'.join(str(x) for x in ${unexpect_history_alarms})
    END
     ${unexpect_history_alarms_faultid}    Set Variable If    ${history_alarms_num}==${0}
     ...    ${empty_history_alarms}    ${unexpect_history_alarms_faultid}
    [Return]    ${unexpect_history_alarms_faultid}

Get TTI used BBMOD ID based on cell id
    [Documentation]    tingting.1.liu@nokia-sbell.com
    ...                20230705 Jia Lei: update for TL073 one AEHC connect to two BBMOD
    [Arguments]         ${cell_index}    ${expect_bbmod_status}=${None}   ${gnb_connection}=GNB_OAM0
    ...     ${enb_index}=${0}    ${enb_connection}=enblte_${enb_index}   ${cell_type}=nr   ${timeout}=300
    log    ${expect_bbmod_status}
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl   connection=${gnb_connection}
    Run Keyword If    ${LTE_WHETHER_IN_GNB}==${False} and '${enb_length}'!='0'
    ...    Wait Until Keyword Succeeds    1 min    5 sec    Connect to eNB via ssl    enb_index=${enb_index}    connection=${enb_connection}
    ${connection}    Set Variable If    ${LTE_WHETHER_IN_GNB}==${False} and '${cell_type}'=='lte'
    ...    ${enb_connection}    ${gnb_connection}
    ${cell_info}   coam.get_cells_info    cell_type=${cell_type}    timeout=${timeout}    connection=${connection}
    &{cell_list_info}    Create Dictionary
    FOR    ${item}    IN    @{cell_info}
        ${rmod_info}    Get From List    ${item['carrierList']}    0
        ${rmod_id}    Get Regexp Matches    ${rmod_info['antennaLineId']['configuration']}    RMOD-(\\d+)    1
        ${cell_id}    Set variable    ${item['id']['configuration'].split('-')[-1]}
        Set To Dictionary    ${cell_list_info}    ${cell_id}=${rmod_id}[0]
    END
    ${cell_index}    Convert To string    ${cell_index}
    ${cell_rmod_index}   get from dictionary   ${cell_list_info}   ${cell_index}
    ${rmod_mapping}    coam.get_detected_hw_info   connection=${connection}
    ${rmod_bbmod_mapping}   get from dictionary   ${rmod_mapping}   cables
    &{rmod_bbmod_list_info}    Create Dictionary
    &{bbmod_linkmode_list_info}    Create Dictionary
    FOR  ${bbmod}   IN  @{rmod_bbmod_mapping}
        @{bbmod_value_list}    Create List
        ${rmod_port_id}    Get Regexp Matches    ${bbmod['secondEndPointId']['configuration']}   RMOD-(\\d+)    1
        ${bbmod_port_id}   Get Regexp Matches    ${bbmod['firstEndPointId']['configuration']}    BBMOD-(\\d+)    1
        ${bbmod_port_num}   Get Length  ${bbmod_port_id}
        Append To List    ${bbmod_value_list}    ${bbmod_port_id[0]}
        ${existing_bbmod_port_id_value_list}   set variable   ${rmod_bbmod_list_info.get('${rmod_port_id[0]}')}
        ${bbmod_value_list_new}    Run Keyword If    ${existing_bbmod_port_id_value_list} is not ${None}
        ...    Combine Lists    ${bbmod_value_list}    ${existing_bbmod_port_id_value_list}
        ...    ELSE    Set Variable    ${bbmod_value_list}
        ${bbmod_value_list_latest}    Remove Duplicates    ${bbmod_value_list_new}
        Run Keyword If    '${bbmod_port_num}'!='0'
        ...                       Set To Dictionary    ${rmod_bbmod_list_info}    ${rmod_port_id}[0]=${bbmod_value_list_latest}
    END
    &{rmod_bbmod_tti_id_info}    Create Dictionary
    FOR  ${key}   IN  @{rmod_bbmod_list_info.keys()}
        ${bbmod_id_str_list}    get from dictionary   ${rmod_bbmod_list_info}   ${key}
        ${bbmod_tti_id_str}    Convert BBMOD ID to TTI BBMOD ID    bbmod_id_str_list=${bbmod_id_str_list}
        Set To Dictionary    ${rmod_bbmod_tti_id_info}    ${key}=${bbmod_tti_id_str}
    END
    ${tti_used_bbmod_id}   get from dictionary   ${rmod_bbmod_tti_id_info}   ${cell_rmod_index}
    [Return]    ${tti_used_bbmod_id}

Convert BBMOD ID to TTI BBMOD ID
    [Documentation]    lei.jia@nokia-sbell.com
    [Arguments]         ${bbmod_id_str_list}
    @{bbmod_tti_id_str_list}    Create List
    FOR    ${item}    IN    @{bbmod_id_str_list}
        ${bbmod_id_int} = 	Convert To Integer    ${item}
        ${bbmod_tti_id_int}    Evaluate    ${bbmod_id_int}+1
        ${bbmod_tti_id_int} = 	Set Variable If 	${bbmod_id_int} > 3 	${bbmod_tti_id_int} 	${bbmod_id_int}
        ${bbmod_tti_id_str}    Convert To String    ${bbmod_tti_id_int}
        Append To List    ${bbmod_tti_id_str_list}    ${bbmod_tti_id_str}
    END
    ${bbmod_tti_id_str}=    Evaluate    ",".join(${bbmod_tti_id_str_list})
    [Return]    ${bbmod_tti_id_str}

Start Capture L2Trace WO Duration With gNB_logs
    [Documentation]    Author: lei.jia@nokia-sbell.com
    [Arguments]    ${gnb_logs_script_path}=/home/ute/gnb_logs
    ...            ${gnb_index}=0
    ...            ${du_index}=0
    ...            ${cell_index}=1
    ...            ${log_type}=L2Trace
    ...            ${connection}=ute
    ...            ${trace_type}=l2ps
    ...            ${timeout}=10 min
    ...            ${retry_interval}=15 sec
    log to console    --- start gnb_logs collection---
    ${log_type_to_command_mapping}    Create Dictionary    L2Trace=o    BIP=b   m=m
    ${gnb_ip}    Set Variable    ${tl.gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}
    ssh.Connect to    hostname=${tl.test_pc.default_ssh_connection_details.addr}
    ...               username=${tl.test_pc.default_ssh_connection_details.username}
    ...               password=${tl.test_pc.default_ssh_connection_details.password}
    ...               alias=${connection}
    ${connection}    csn.get_connection_by_alias    alias=${connection}
    ${channel}    Call Method   ${connection}    invoke_shell
    Set Test Variable    ${gnb_logs_channel}    ${channel}
    Call Method    ${channel}    send    cd ${gnb_logs_script_path}&&rm -rf *${gnb_ip}*${log_type}.zip\n
    sleep   10s
    ${output}    Call Method    ${channel}    recv    ${65535}
    ${start_capture_command}     Catenate    sudo ./gnb_logs ${gnb_ip} -${log_type_to_command_mapping['${log_type}']} ${trace_type} -C ${cell_index}
    Call Method    ${channel}    send    cd ${gnb_logs_script_path}&&${start_capture_command}\n
    Wait until keyword succeeds    ${timeout}    ${retry_interval}    Check Trace Start And Stop Normally
    ...    channel=${gnb_logs_channel}     message=monitoring    cell_index=${cell_index}

Stop Capture Trace WO Duration With gNB_logs
    [Documentation]    author:lei.jia@nokia-sbell.com
    [Arguments]    ${gnb_logs_script_path}=/home/ute/gnb_logs
    ...            ${gnb_index}=0
    ...            ${du_index}=0
    ...            ${connection}=ute
    ...            ${timeout}=25 min
    ...            ${retry_interval}=15 sec
    ...            ${cell_index}=1
    log    ${connection}
    log    ${du_index}
    log many    ${gnb_logs_script_path}    ${gnb_index}
    Log To Console    \***stop collect gnb logs***\
    Check the gnb_logs progress exist
    Call Method    ${gnb_logs_channel}    send    \n
    Sleep    60 sec
    Wait until keyword succeeds    ${timeout}    ${retry_interval}    Check Trace Start And Stop Normally
    ...    channel=${gnb_logs_channel}     message=finished        cell_index=${cell_index}
    [Teardown]    Run Keyword And Ignore Error    ssh.disconnect    connection=ute

Check the gnb_logs progress exist
    [Arguments]     ${connection}=ute
    ...            ${gnb_index}=0
    ...            ${du_index}=0
    ...            ${gnb_ip}= ${tl.gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}
    ${gnb_logs_pid}    Get the gnb_logs pid    connection=${connection}
    ...                       gnb_ip=${gnb_ip}
    ...                       gnb_index=${gnb_index}    du_index=${du_index}
    should be true    ${gnb_logs_pid} > ${0}

Get the gnb_logs pid
    [Arguments]     ${connection}=ute
    ...            ${gnb_index}=0
    ...            ${du_index}=0
    ...            ${gnb_ip}=${tl.gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}
    ssh.Connect to    hostname=${tl.test_pc.default_ssh_connection_details.addr}
    ...               username=${tl.test_pc.default_ssh_connection_details.username}
    ...               password=${tl.test_pc.default_ssh_connection_details.password}
    ...               alias=${connection}
    ssh.send_command    command=ps -ef |grep gnb_logs |grep ${gnb_ip} |awk '{print $2}'    connection=${connection}    timeout=120
    ${output}    ssh.read_output    size=1000    connection=${connection}
    ${gnb_logs_pids}    Set Variable    ${output.split()}
    ${gnb_logs_pid}    evaluate    ${gnb_logs_pids[0].strip()}
    [Return]    ${gnb_logs_pid}

Check Trace Start And Stop Normally
    [Documentation]    author:lei.jia@nokia-sbell.com
    [Arguments]    ${channel}    ${cell_index}=1    ${message}=finished
    log    ${cell_index}
    ${output}    Call Method    ${channel}    recv    ${65535}
    ${output}    Convert To String    ${output}
    should contain    ${output}   ${message}

Get Specific L2trace File
    [Documentation]    Author: lei.jia@nokia-sbell.com
    [Arguments]    ${cell_index}=1
    ...            ${gnb_logs_script_path}=/home/ute/gnb_logs
    ...            ${target_dir}=${TS_CASE_LOG_PATH}
    ...            ${gnb_index}=0
    ...            ${du_index}=0
    ...            ${log_type}=L2Trace
    ${ul_ttitrace_file_list}    ${dl_ttitrace_file_list}    Get Specific Direction L2trace File    gnb_logs_script_path=${gnb_logs_script_path}
    ...                                                         target_dir=${target_dir}
    ...                                                         gnb_index=${gnb_index}
    ...                                                         du_index=${du_index}
    ...                                                         log_type=${log_type}
    ${cell_name}    Set Variable    NRCELL_R_${cell_index}
    Check L2trace File Captured Properly    tti_file_list=${ul_ttitrace_file_list}    cell_name=${cell_name}
    Check L2trace File Captured Properly    tti_file_list=${dl_ttitrace_file_list}    cell_name=${cell_name}
    [Return]    ${ul_ttitrace_file_list}    ${dl_ttitrace_file_list}

Check L2trace File Captured Properly
    [Documentation]    Author: lei.jia@nokia-sbell.com
    [Arguments]    ${tti_file_list}    ${cell_name}
    ${specific_ttitrace_file_list}    Evaluate    list(filter(lambda x:'${cell_name}_TTI' in x,${tti_file_list}))
    ${file_length}    Get Length    ${specific_ttitrace_file_list}
    Should Be True    ${file_length}>=${1}    msg=ttitrace is not captured properly.
    log to console    specific ttitrace file list : ${specific_ttitrace_file_list}

Get Specific Direction L2trace File
    [Documentation]    Author: lei.jia@nokia-sbell.com
    [Arguments]    ${gnb_logs_script_path}=/home/ute/gnb_logs
    ...            ${target_dir}=${TS_CASE_LOG_PATH}
    ...            ${gnb_index}=0
    ...            ${du_index}=0
    ...            ${log_type}=L2Trace
    ssh.Connect to    hostname=${tl.test_pc.default_ssh_connection_details.addr}
    ...               username=${tl.test_pc.default_ssh_connection_details.username}
    ...               password=${tl.test_pc.default_ssh_connection_details.password}
    ...               alias=ute
    ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    ${specific_ttitrace_file_list}    Create List
    log to console    --- start to Download tti trace result to specific folder ---
    ${gnb_ip}    Set Variable    ${tl.gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}
    @{ttitrace_files}    List Files In Directory	${gnb_logs_script_path}	   BTS*_${gnb_ip}_*_${log_type}.zip
    Copy Files    ${gnb_logs_script_path}/BTS*_${gnb_ip}_*.zip    ${target_dir}
    FOR    ${ttitrace_file}    IN    @{ttitrace_files}
        ${file_name}    Set Variable    ${ttitrace_file.split('.zip')[0]}
        ssh.send command    command=unzip -o -d ${target_dir} ${target_dir}/${ttitrace_file}    connection=ute
        Sleep    30 sec
        ${ul_ttitrace_file}    List Files In Directory	${target_dir}/${file_name}/L2_trace/tti_packed/
        ...                                                     *.ul__all.csv
        ...                                                     absolute=${True}
        ${dl_ttitrace_file}    List Files In Directory	${target_dir}/${file_name}/L2_trace/tti_packed/
        ...                                                     *.dl__all.csv
        ...                                                     absolute=${True}
    END
    [Return]    ${ul_ttitrace_file}    ${dl_ttitrace_file}
    [Teardown]    Run Keyword And Ignore Error    Run    rm ${gnb_logs_script_path}/gNB_${gnb_ip}_*_${log_type}.zip

Start TTI Trace WO Duration With gNB_logs
    [Documentation]    Author: lei.jia@nokia-sbell.com
    [Arguments]    ${bbmod_slots}=1
    ...            ${gnb_logs_script_path}=/home/ute/gnb_logs
    ...            ${gnb_index}=0
    ...            ${du_index}=0
    ...            ${log_type}=TTI
    ...            ${connection}=ute
    ...            ${timeout}=10 min
    ...            ${retry_interval}=5 sec
    log to console    --- start gnb_logs collection---
    ${log_type_to_command_mapping}    Create Dictionary    TTI=T    BIP=b   m=m
    ${gnb_ip}    Set Variable    ${tl.gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}
    ssh.Connect to    hostname=${tl.test_pc.default_ssh_connection_details.addr}
    ...               username=${tl.test_pc.default_ssh_connection_details.username}
    ...               password=${tl.test_pc.default_ssh_connection_details.password}
    ...               alias=${connection}
    ${connection}    csn.get_connection_by_alias    alias=${connection}
    ${channel}    Call Method   ${connection}    invoke_shell
    Set Test Variable    ${gnb_logs_channel}    ${channel}
    Call Method    ${channel}    send    cd ${gnb_logs_script_path}&&rm *${gnb_ip}*${log_type}.zip\n
    ${start_capture_command}     Catenate    ./gnb_logs ${gnb_ip} -c${bbmod_slots} -${log_type_to_command_mapping['${log_type}']}
    Call Method    ${channel}    send    cd ${gnb_logs_script_path}&&./${start_capture_command}\n
    Wait until keyword succeeds    ${timeout}    ${retry_interval}    Check Trace Start And Stop Normally
    ...    channel=${gnb_logs_channel}     message=monitoring

SW Upgrade based on Test Count
    [Documentation]   lei.jia@nokia-sbell.com
    [Arguments]    ${test_count}    ${file_path}    ${category_value}=upgrade    ${gnb_connection}=GNB_OAM    ${timeout}=7200
    ${sw_version}    get_parameters_value_based_on_testcount_and_category
    ...                      file_path=${file_path}
    ...                      test_count=${test_count}
    ...                      category_value=${category_value}
    ${sw_version_len}    Get Length    ${sw_version}
    Check SW In Lower Version
    Run Keyword If     ${sw_version_len}>0    E2E_TL_SW_upgrade    sw_version=${sw_version}
    ...                                                            gnb_connection=${gnb_connection}
    ...                                                            timeout=${timeout}

Get SW Package Path
    [Documentation]    :Author: lei.jia@nokis-sbell.com
    ...    If SW Package doesn't exist, will download it from artifactory
    [Arguments]    ${sw_version}    ${package_regex}=${sw_version}_release_BTSSM_downloadable_A54.zip    ${PACKAGE_PATH}=/home/ute
    ${no_package}=    Run Keyword And Return Status    File Should Exist    ${PACKAGE_PATH}/${package_regex}    msg=Download SW first!
    Run Keyword If    ${no_package}==${False}    Download SW Package from Artifactory    sw_version=${sw_version}
    ...                                                                        package_regex=${package_regex}
    ...                                                                        PACKAGE_PATH=${PACKAGE_PATH}
    [Return]     ${PACKAGE_PATH}/${package_regex}


Download SW Package from Artifactory
    [Documentation]    :Author: lei.jia@nokis-sbell.com
    [Arguments]    ${sw_version}    ${package_regex}=${sw_version}_release_BTSSM_downloadable_A54.zip    ${PACKAGE_PATH}=/home/ute
    ${package_url}=    Set Variable If    'SBTS23R2' in '${sw_version}'    ${SBTS23R2_package_link}/${sw_version}/${package_regex}
    ...                                  'SBTS23R1' in '${sw_version}'     ${SBTS23R1_package_link}/${sw_version}/${package_regex}
    ...                                  'SBTS00' in '${sw_version}'       ${SBTS00_package_link}/${sw_version}/${package_regex}
    ...                                  'SBTS23R3' in '${sw_version}'     ${SBTS23R3_package_link}/${sw_version}/${package_regex}
    ${output}=    Run    wget ${package_url} -nv -P ${PACKAGE_PATH}/
    Should Contain    ${output}    ${package_regex}    SW Package Download failed!

E2E_TL_SW_upgrade
    [Arguments]    ${sw_version}    ${gnb_connection}=GNB_OAM    ${timeout}=7200    ${PACKAGE_PATH}=/home/ute
    Log To Console    ${\n}INFO:-- start to do GNB/ENB upgrade --
    wait until keyword succeeds     5 min   10 sec     Connect to gnb coam via ssl
    ${upgrade_package_path}    Get SW Package Path    sw_version=${sw_version}    PACKAGE_PATH=${PACKAGE_PATH}
    Set Test Variable    ${upgrade_package_path}
    log to console    --- start to upgrade---
    coam.update_software    sw_package=${upgrade_package_path}    timeout=${timeout}    connection=${gnb_connection}
    Run Keyword And Ignore Error    COAM Teardown gnb connections
    FOR    ${enb_id}    IN RANGE    ${enb_length}
        Wait Until Keyword Succeeds    1 min    5 sec    Connect to eNB via ssl    enb_index=${enb_id}    connection=enblte_${enb_id}
        Run Keyword If    ${LTE_WHETHER_IN_GNB}==${False}    coam.update_software    sw_package=${upgrade_package_path}
        ...    timeout=${timeout}    connection=enblte_${enb_id}
        Run Keyword And Ignore Error    Enblte close down    connection=enblte_${enb_id}
    END
    sleep   1min
    Check GNB On Air And Unexpect Alarm Should Not Exist
    Check ENB On Air And Unexpect Alarm Should Not Exist
    [Teardown]   Teardown GNB and ENB Connections

E2E_TL_SW_rollback
    Log To Console    ${\n}INFO:-- start to do GNB/ENB rollback --
    Gnb And All Enb Rallback
    sleep   2min
    Check GNB On Air And Unexpect Alarm Should Not Exist
    Check ENB On Air And Unexpect Alarm Should Not Exist

Check SW In Lower Version
    wait until keyword succeeds     5 min   10 sec     Connect to gnb coam via ssl
    Check Rollback is needed before sw upgrade
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections

Get UL And DL TTI Logs
    ${ul_ttitrace}    Set Variable    ${None}
    ${dl_ttitrace}    Set Variable    ${None}
#    ${ul_ttitrace}    Capture And Decode TTitrace Log    direction=ul
#    ${dl_ttitrace}    Capture And Decode TTitrace Log    direction=dl
    [Return]    ${ul_ttitrace}    ${dl_ttitrace}

*** Test Cases ***
BWP_Test_Case
    [Setup]  TMO_Common_Case_Setup    ue_index=15
    Get Syslog Start Time
    Update chbw Params and Start Test based on csv file
    ${syslog_file}    Run Keyword And Continue On Failure    Get Syslog File During Specific Time    syslog_start_time=${SYSLOG_START_TIME}
    ${syslog_file_path}    Run Keyword And Continue On Failure   Evaluate    '/'.join(${syslog_file.split('/')[0:-1]})
    Run Keyword And Ignore Error    Check ERR Or WRN From Syslog    sys_logs_path=${syslog_file_path}
    ...     UTE_logs_path=/home/ute/ERR_WRN_logs    Fail_Case=True    Check_RF_Log=True    timeout=50 minutes
    Run Keyword And Continue On Failure    Check ERR Syslog Existed
    [Teardown]    Run Keywords    Run Keyword And Continue On Failure    TMO_Common_Case_Teardown    AND
    ...    Run Keyword And Continue On Failure    SetUp.Precondition For First gNB   is_commission=${True}
    ...    check_rollback_is_needed=${False}
###    for debug
#    Generate And Modify BWP Params based on Test Count
#    ...    test_count=1
#    ...    category_value=Parameter
#    ...    file_path=/home/ute/BWP_Auto_test_input_T080.csv
#    Connect to gnb coam via ssl    connection=GNB_OAM   gnb_index=${0}
#    ${updated_params}    ${deleted_params}    ${added_params}   ${bwp_diff_list}     generate_modified_params_bwp
#    ...     testcount=6   release=25R3
#    log   ${updated_params}
#    ${updated_params}    ${deleted_params}    ${added_params}   ${bwp_diff_list}     generate_modified_params_bwp
#    ...     testcount=8
#    log   ${updated_params}
#    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=GNB_OAM