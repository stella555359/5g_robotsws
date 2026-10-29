*** Settings ***
Documentation
...  author: Chen Yin 4
...  contact: yin.4.chen@nokia-sbell.com

Resource   common.robot

*** Variables ***
${trace_folder}   /sharedvolume/ntracer5g/_data/celltrace/
${dcap_private_key_path}   ${CURDIR}/utfuser.private.key


*** Keywords ***
Get CU Latest Trace File Name
    [Arguments]   ${gnb_index}=${0}
    [Timeout]   5m

    ${cu_mrbts_id}   Get Variable Value  ${all_gnbs_detail[${gnb_index}]["cu_mrbts_id"]}
    ${cu_webem_addr}   Get Variable Value   ${all_gnbs_detail[${gnb_index}]["cu_webem_addr"]}
    ${dcap_server_ip}   Get Variable Value   ${all_gnbs_detail[${gnb_index}]["dcap_server_ip"]}
    ${dcap_server_username}   Get Variable Value   ${all_gnbs_detail[${gnb_index}]["dcap_server_username"]}
    ${connection}   Set Variable   dcap_${dcap_server_ip}


    Log To Console   ${dcap_server_ip}

    Wait Until Keyword Succeeds   5m   20s   csn.Connect to
    ...   hostname=${dcap_server_ip}   username=${dcap_server_username}    key_path=${dcap_private_key_path}   alias=${connection}
    Run Keyword and Ignore Error   csn.Execute
    ...   command=find ${trace_folder} -mtime +2 -name \"\*\.\*\" -exec rm -rf \{\} \\;   connection=${connection}
    ${trace_files}   csn.Execute   command=find ${trace_folder} -name \"ne${cu_mrbts_id}\*${cu_webem_addr}\*\" | xargs ls --sort=time -r
    ...   connection=${connection}
    ${trace_files}   Set Variable   ${trace_files.splitlines()}
    Return From Keyword If   len(${trace_files})==0 or (len(${trace_files})==1 and '${trace_files[0]}'=='')    ${EMPTY}
    [Return]   ${trace_files[-1]}
    [Teardown]   csn.Disconnect   connection=${connection}


Get CU Newest Trace Files
    [Arguments]   ${gnb_index}=${0}   ${latest_skip_file}=${EMPTY}   ${latest_file_skipped}=${true}   ${log_dir}=${OUTPUT_DIR}

    ${cu_mrbts_id}   Get Variable Value  ${all_gnbs_detail[${gnb_index}]["cu_mrbts_id"]}
    ${cu_webem_addr}   Get Variable Value   ${all_gnbs_detail[${gnb_index}]["cu_webem_addr"]}
    ${dcap_server_ip}   Get Variable Value   ${all_gnbs_detail[${gnb_index}]["dcap_server_ip"]}
    ${dcap_server_username}   Get Variable Value   ${all_gnbs_detail[${gnb_index}]["dcap_server_username"]}

    ${connection}   Set Variable   dcap_${dcap_server_ip}

    ${file_list}   Create List
    Wait Until Keyword Succeeds   5m   20s   csn.Connect to
    ...   hostname=${dcap_server_ip}   username=${dcap_server_username}    key_path=${dcap_private_key_path}   alias=${connection}
    ${trace_files}   csn.Execute   command=find ${trace_folder} -name \"ne${cu_mrbts_id}\*${cu_webem_addr}\*\" | xargs ls --sort=time -r
    ...   connection=${connection}
    ${trace_files}   Set Variable   ${trace_files.splitlines()}
    Return From Keyword If   len(${trace_files})==0 or (len(${trace_files})==1 and '${trace_files[0]}'=='')    ${EMPTY}

    ${last_index}   Run Keyword If   $latest_skip_file==''   Set Variable   ${-1}
    ...   ELSE   Get Index From List   ${trace_files}   ${latest_skip_file}
    ${total_files}   Get Length   ${trace_files}
    ${latest_file_skipped}   Set Variable If  '${total_files}'=='${last_index+1}'   ${false}   ${latest_file_skipped}
    ${start_index}   Set Variable If   ${latest_file_skipped}   ${last_index+1}   ${last_index}
    OperatingSystem.Run   mkdir ${log_dir}
    FOR   ${index}    IN RANGE    ${start_index}   ${total_files}
       ${trace_dir}   ${trace_file_name}   Split Path   ${trace_files[${index}]}
       ${trace_file_name}   Set Variable   ${trace_file_name.replace(":", "")}
       csn.Download File   remote_path=${trace_files[${index}]}   local_path=${log_dir}/${trace_file_name}   connection=${connection}
       Append To List   ${file_list}   ${log_dir}/${trace_file_name}
    END
    [Return]   ${file_list}
    [Teardown]   csn.Disconnect   connection=${connection}


Emil Decoding To JSON
    [Arguments]   ${message_name_list}   ${emil_result_dir}=${OUTPUT_DIR}
    # ${time}   DateTime.Get Current Date   UTC   + 8 hours   result_format=%Y-%m-%d-%H_%M_%S
    # ${emil_result_dir}   Set Variable   ${OUTPUT_DIR}/EMIL_Result_${time}

    # OperatingSystem.Run   rm -rf ${emil_result_dir}
    ${dcap}   Create Dictionary   host=${dcap_server_ip}    port=443    username=${dcap_server_username}    password=${dcap_server_password}
    emil.create_emil_converter_for_source
        ...   name=emil_json
        ...   file_path_pattern=${emil_result_dir}/*.lcbin
        ...   output_directory=${emil_result_dir}
        ...   dcap=${dcap}

    emil.setup   emil_json
    emil.convert   emil_json
    emil.teardown   emil_json

    ${jsonfile_list}   List Files In Directory   path=${emil_result_dir}   pattern=*.json


    OperatingSystem.Create File    ${emil_result_dir}/all_pcmd_message.json
    FOR   ${file}   IN   @{jsonfile_list}
        ${file_content}   OperatingSystem.Get File    ${emil_result_dir}/${file}
        OperatingSystem.Append To File   ${emil_result_dir}/all_pcmd_message.json   ${file_content}
    END
# #    ${json_file}    Set Variable    ${OUTPUT_DIR}/emil.json
#     [Return]    ${json_content}
    ${all_pcmd_message_str}   OperatingSystem.Get File   ${emil_result_dir}/all_pcmd_message.json
    ${all_pcmd_message_str}   Strip String   ${all_pcmd_message_str}
    @{all_pcmd_message_str_list}   Split To Lines   ${all_pcmd_message_str}

    # @{message_name_list}   Create List   NsetapX_StartRecordingSession   NsetapX_StopRecordingSession
    @{all_pcmd_message}   Create List

    FOR   ${pcmd_message_str}   IN   @{all_pcmd_message_str_list}
        ${pcmd_message}   Evaluate   json.loads($pcmd_message_str)   json
        ${Message_name}   Get Variable Value   ${pcmd_message["Message_name"]}
        ${User_data}   Get Variable Value   ${pcmd_message["User_data"]}
        ${Time}   Get Variable Value   ${pcmd_message["Time"]}
        # Log To Console   ${Message_name}, ${User_data}, ${Time}
        &{new_pcmd_message}   Create Dictionary   Message_name=${Message_name}   User_data=${User_data}   Time=${Time}
        Run Keyword If   $Message_name in $message_name_list   Append To List   ${all_pcmd_message}   ${new_pcmd_message}

    END
    # Log To Console   ${all_pcmd_message}

    [Return]   ${all_pcmd_message}


Check PCMD Message After Time
    [Arguments]   ${all_pcmd_message}   ${check_time}   ${timezone}=8 hours
    @{after_time_pcmd_message}   Create List
    FOR   ${pcmd_message}   IN   @{all_pcmd_message}
        ${message_time}   Get Variable Value   ${pcmd_message["Time"]}
        ${message_timestamp}   DateTime.Convert Date   date=${message_time}   result_format=epoch   date_format=%Y-%m-%dT%H:%M:%S.%f%z

        ${message_timestamp}   Run Keyword If   "${timezone}"!="None"
        ...   DateTime.Add Time To Date   date=${message_timestamp}   time=${timezone}   result_format=epoch
        ...   ELSE   Set Variable   ${message_timestamp}
        Run Keyword If   ${message_timestamp} > ${check_time}   Append To List   ${after_time_pcmd_message}   ${pcmd_message}
    END
    [Return]   ${after_time_pcmd_message}
