*** Settings ***
Resource   Common.robot

*** Variables ***
@{gnb_custom_profile}   cp_5g   Tracer_5g
@{vcu_custom_profile}   tracerVcu   flowTracerVcu
@{vdu_custom_profile}   tracerVdu   flowTracerVdu


*** Keywords ***
Connect To DCAP Basic WEB
    [Arguments]   ${host}=${dcap_trace_host}   ${username}=${dcap_trace_user}   ${password}=${dcap_trace_password}   ${port}=${dcap_trace_port}
    ...   ${alias}=DCAP_WEB
    Log To Console   Connect To DCAP Basic WEB
    rd.connect_to
    ...   host=${host}
    ...   port=${port}
    ...   username=${username}
    ...   password=${password}
    ...   rd_version=dcapv3
    ...   secure=${True}
    ...   alias=${alias}


Create BTS On DCAP Basic WEB
    [Arguments]   ${bts_dict}   ${connection}=DCAP_WEB
    Log To Console   Create BTS On DCAP Basic WEB


    ${bts_host}   Set Variable   ${bts_dict["host"]}

    ${all_bts_info}   rd.get_all_bts_info   connection=${connection}
    ${bts_exist_id}   Set Variable   NONE
    FOR   ${bts_info}   IN   @{all_bts_info}
        ${bts_exist_id}   Set Variable If   "${bts_info['host']}"=="${bts_host}"   ${bts_info['id']}   ${bts_exist_id}
        Exit For Loop If   "${bts_info['host']}"=="${bts_host}"
    END

    ${output}   Run Keyword If   "${bts_exist_id}"=="NONE"
    ...   rd.create_bts   &{bts_dict}   bts_alias=${bts_host}   connection=${connection}


Start Trace On DCAP Basic WEB
    [Arguments]   ${bts_dict}   ${connection}=DCAP_WEB
    Log To Console   Start Trace On DCAP Basic WEB
    &{custom_profile}   Run Keyword If
    ...   "${TESTLINE_TYPE}"=="CLASSICAL"
    ...      Create Dictionary   gnb_custom_profile=${gnb_custom_profile}
    ...   ELSE IF   "${TESTLINE_TYPE}"=="CLOUD"
    ...      Create Dictionary   vcu_custom_profile=${vcu_custom_profile}   vdu_custom_profile=${vdu_custom_profile}

    ${output}   rd.start_trace
    ...   bts=${bts_dict}
    # ...   gnb_custom_profile=${gnb_custom_profile}
    # ...   vcu_custom_profile=${vcu_custom_profile}
    # ...   vdu_custom_profile=${vdu_custom_profile}
    ...   wait_for_activation=${True}
    ...   control_plane_interface=${True}
    ...   allow_start_failures=${False}
    ...   connection=${connection}
    ...   &{custom_profile}

    Log   ${output}[tracer_id]
    ${result_id}   Convert To Integer   ${output}[tracer_id]
    Set Suite Variable    ${result_id}
    Log To Console   result_id: ${result_id}
    [Return]   ${result_id}


Stop Trace On DCAP Basic WEB
    [Arguments]   ${result_id}   ${connection}=DCAP_WEB
    Log To Console   Stop Trace On DCAP Basic WEB

    Wait Until Keyword Succeeds   10min   30s   rd.stop_trace   trace_id=${result_id}   connection=${connection}
    ${downloaded_emil_file_path}   Wait Until Keyword Succeeds   20min   30s
    ...   rd.get_results   result_id=${result_id}   target_dir=${OUTPUT_DIR}   connection=${connection}
    [Return]   ${downloaded_emil_file_path}


Exact DCAP Log
    [Arguments]    ${downloaded_emil_file_path}

    Log To Console   Get the exact dcap log
    ${curr_data}   DateTime.Get Current Date   UTC   + 8 hours   result_format=%Y-%m-%d-%H_%M_%S
    OperatingSystem.Run   unzip -o ${downloaded_emil_file_path} -d ${OUTPUT_DIR}/dcap_tmp_${curr_data}

    ${local_emil_log_path}   OperatingSystem.Run   find ${OUTPUT_DIR}/dcap_tmp_${curr_data} -name "*.5gm"
    Should Not Be Empty   ${local_emil_log_path}
    ${local_emil_log_path}   Strip String   ${local_emil_log_path}
    ${emil_log_file_list}   Split String   ${local_emil_log_path}    \n
    Log To Console   ${emil_log_file_list}

    ${local_ida_file_path}   OperatingSystem.Run   find ${OUTPUT_DIR}/dcap_tmp_${curr_data} -name "sack"
    Should Not Be Empty   ${local_ida_file_path}
    ${local_ida_file_path}   Strip String   ${local_ida_file_path}
    @{local_ida_file_list}   List Files In Directory   ${local_ida_file_path}
    Log To Console   ${local_ida_file_list}
    Should Not Be Empty   ${local_ida_file_list}

    @{sack_file_list}   Create List
    FOR   ${sack_file_name}   IN   @{local_ida_file_list}
        ${sack_file_version}   Should Match Regexp   ${sack_file_name}   SBTS.*_IDA_\\d+_\\d+_\\d+\\.zip
        ${sack_file_version}   Remove String   ${sack_file_version}   .zip
        OperatingSystem.Run   unzip -o ${local_ida_file_path}/${sack_file_name} -d ${OUTPUT_DIR}/${sack_file_version}
        OperatingSystem.Run   cd ${OUTPUT_DIR}; tar -cvf ${sack_file_version}.tar ${sack_file_version}
        Append To List   ${sack_file_list}   ${OUTPUT_DIR}/${sack_file_version}.tar
    END
    Log To Console   ${sack_file_list}
    [Return]    ${emil_log_file_list}   ${sack_file_list}
