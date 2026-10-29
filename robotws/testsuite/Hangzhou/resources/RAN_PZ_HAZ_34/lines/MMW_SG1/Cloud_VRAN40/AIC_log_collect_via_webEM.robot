*** Settings ***
Documentation    Author: Ding Binmei
...    This resource file is used to collect tcpdump log via webEM for cloud vran4.0
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/Cloud_VRAN40/vCU.robot
Library    ../lib/decompress_file.py
Library    Collections
Library    OperatingSystem


*** Variables ***
${TIMEOUT_STATUS_CHANGE}    10s

*** Keywords ***
__keywords for search__
    [Documentation]    This is a separator for keywords used for searching purpose only. Do not remove this line.
    Start F1AP log capture via webEM
    Stop F1AP log capture via webEM
    Release IP traffic capture connections on vcu in teardown

Verify IP traffic capture status
    [Documentation]    Author: Ding Binmei
    ...    This keyword is used to verify ip traffic capture status via webEM
    ...    ${exp_serviceStatus}: Expected service status, possible values: idle, capturing, captureCompleted, generationCompleted, ...
    ...    ${connection}: The connection identifier for the vCU (default is 'ip_traffic_capture_vcu').
    [Arguments]    ${exp_serviceStatus}    ${connection}=ip_traffic_capture_vcu
    ${ip_traffic_capture_status}    cu.get_ip_traffic_capture_status    connection=${connection}
    ${act_serviceStatus}    Set Variable    ${ip_traffic_capture_status['service_status']}
    Should Be Equal As Strings    ${act_serviceStatus}    ${exp_serviceStatus}    ignore_case=${True}

Get generated file name from ip traffic capture status
    [Documentation]    Author: Ding Binmei
    ...    This keyword is used to get generated file name from ip traffic capture status
    ...    ${list_pod_names}: A list of pod names for which to retrieve log file names.
    ...        Available values: po-cpif-0, po-upue-0, po-oamext-0
    ...    ${connection}: The connection identifier for the vCU (default is 'ip_traffic_capture_vcu').
    ...    The returned dictionary will have pod names as keys and their corresponding log file names as values.
    ...    E.G: {'po-cpif-0': 'gNB_vCU_37241_po-cpif-0_20250919T145428.pcap.gz'}
    [Arguments]    ${list_pod_names}    ${connection}=ip_traffic_capture_vcu
    ${is_instance_a_list}    Evaluate    isinstance(${list_pod_names}, list)
    Should Be True    ${is_instance_a_list}    msg=The argument list_pod_names should be a list.
    ${ip_traffic_capture_status}    cu.get_ip_traffic_capture_status    connection=${connection}
    ${all_pods_info}    Set Variable        ${ip_traffic_capture_status['pod_status']}
    ${dict_log_file_name_for_pods}    Create Dictionary
    FOR    ${pod_info}    IN    @{all_pods_info}
        ${pod_name}    Set Variable    ${pod_info['pod_name']}
        Run Keyword If    '${pod_name}' in ${list_pod_names}    Run Keywords
        ...    Should Be Equal As Strings    ${pod_info['capture_status']}    generationCompleted    ignore_case=${True}    AND
        ...    Should Contain    ${pod_info['file_name']}    .pcap.gz    AND
        ...    Set To Dictionary    ${dict_log_file_name_for_pods}    ${pod_name}=${pod_info['file_name']}
    END
    ${len_log_file_name_for_pods}    Get Length    ${dict_log_file_name_for_pods}
    ${len_pod_names}    Get Length    ${list_pod_names}
    Should Be Equal As Integers    ${len_log_file_name_for_pods}    ${len_pod_names}
    [Return]    ${dict_log_file_name_for_pods}

Download log files for pods
    [Documentation]    Author: Ding Binmei
    ...    This keyword is used to download log files for pods via webEM
    ...    ${dict_log_file_name_for_pods}: A dictionary where keys are pod names and values are their corresponding log file names.
    ...        Example: {'po-cpif-0': 'ip_traffic_capture_po-cpif-0_20231010_101010.pcap.gz',
    ...                  'po-upue-0': 'ip_traffic_capture_po-upue-0_20231010_101010.pcap.gz'}
    ...    ${target_dir}: The directory where the downloaded log files will be saved (default is '${TS_CASE_LOG_PATH}').
    ...    ${connection}: The connection identifier for the vCU (default is 'ip_traffic_capture_vcu').
    [Arguments]    ${dict_log_file_name_for_pods}    ${target_dir}=${TS_CASE_LOG_PATH}    ${connection}=ip_traffic_capture_vcu
    ${upload_info}=    cu.activated_file_upload_operation    connection=${connection}
    Should be equal as strings    ${upload_info['status']}    success    ignore_case=${True}
    ${list_pod_names}    Get Dictionary Keys    ${dict_log_file_name_for_pods}
    ${dict_log_file_path_for_pods}    Create Dictionary
    FOR    ${pod_name}    IN    @{list_pod_names}
        ${log_file_name}    Set Variable    ${dict_log_file_name_for_pods['${pod_name}']}
        Log To Console    message=Downloading log file for pod '${pod_name}': ${log_file_name}
        ${log_file_path_compressed}    cu.upload_ip_traffic_capture_file    operation_id=${upload_info['operation_id']}
        ...    file_name=${log_file_name}    local_path=${target_dir}    connection=${connection}
        File should not be empty    ${log_file_path_compressed}
        ${pcap_file_path}    decompress_file.get_file_path_after_decompress    file_path_compressed=${log_file_path_compressed}
        Log To Console    message=Decompressed log file for pod '${pod_name}' to: ${pcap_file_path}
        File should not be empty    ${pcap_file_path}
        Set To Dictionary    ${dict_log_file_path_for_pods}    ${pod_name}=${pcap_file_path}
    END
    [Return]    ${dict_log_file_path_for_pods}

Start Ip Traffic Capture on vCU
    [Documentation]    Author: Ding Binmei
    ...                This kw is used to This keyword is to capture ip traffic via webEM
    ...    ${list_pod_names}: A list of pod names for which to start log capture.
    ...        Available values: po-cpif-0, po-upue-0, po-oamext-0
    ...    ${capture_type}: Type of ip traffic capture area, one of [all, plane, pod(default)]
    ...    ${measurement_point}: The measurement point for the capture. Possible values are NE_Terminated (default) or Transport_Interface.
    ...    ${plane_type}: Type of ip traffic capture plane provided when captureType = plane.
    ...        allowed value are [ uplane, cplane, mplane, others ], default is None
    ...    ${gnb_index}: The index of the gNB (default is 0).
    ...    ${connection}: The connection identifier for the vCU (default is 'ip_traffic_capture_vcu').
    [Arguments]    ${list_pod_names}    ${capture_type}=pod    ${measurement_point}=NE_Terminated    ${plane_type}=None
    ...            ${gnb_index}=${0}    ${connection}=oam_cu_${gnb_index}_ip_traffic_capture_vcu
    Connect to vcu via rest api    gnb_index=${gnb_index}    connection=${connection}
    Log to console    Start Ip Traffic Capture In vCU
    cu.start_ip_traffic_capture    capture_type=${capture_type}    measurement_point=${measurement_point}
    ...                                   plane_type=${plane_type}    pod_names=${list_pod_names}
    ...                                   connection=${connection}
    Wait Until Keyword Succeeds    ${TIMEOUT_STATUS_CHANGE}    1s    Verify IP traffic capture status
    ...    exp_serviceStatus=capturing    connection=${connection}
    Log to console    IP traffic capture status is capturing

Release IP traffic capture connections on vcu in teardown
    [Documentation]    Author: Ding Binmei
    ...                This keyword will release ip traffic capture connections on vCU.
    [Arguments]    ${gnb_index}=${0}    ${connection}=oam_cu_${gnb_index}_ip_traffic_capture_vcu
    cu.stop_ip_traffic_capture    connection=${connection}
    cu.delete_file_upload_operation    connection=${connection}
    Teardown vcu connection    connection=${connection}

Stop Ip Traffic Capture on vCU
    [Documentation]    Author: Ding Binmei
    ...                This keyword will stop, generate and download ip traffic from webem.

    [Arguments]    ${list_pod_names}    ${target_dir}=${TS_CASE_LOG_PATH}
    ...    ${gnb_index}=${0}    ${connection}=oam_cu_${gnb_index}_ip_traffic_capture_vcu
    cu.stop_ip_traffic_capture    connection=${connection}
    Wait Until Keyword Succeeds    ${TIMEOUT_STATUS_CHANGE}    1s    Verify IP traffic capture status
    ...    exp_serviceStatus=captureCompleted    connection=${connection}
    Log to console    IP traffic capture status is captureCompleted
    cu.generate_ip_traffic_capture_files    credentials=     connection=${connection}
    Wait Until Keyword Succeeds    ${TIMEOUT_STATUS_CHANGE}    1s    Verify IP traffic capture status
    ...    exp_serviceStatus=generationCompleted    connection=${connection}
    Log To Console    message=IP traffic capture status is generationCompleted
    ${dict_log_file_name_for_pods}    Get generated file name from ip traffic capture status
    ...    list_pod_names=${list_pod_names}    connection=${connection}
    ${dict_log_file_path_for_pods}    Download log files for pods    dict_log_file_name_for_pods=${dict_log_file_name_for_pods}
    ...    target_dir=${target_dir}    connection=${connection}
    [Return]    ${dict_log_file_path_for_pods}
    [Teardown]    Run Keyword and Ignore Error    Release IP traffic capture connections on vcu in teardown    connection=${connection}

Start F1AP log capture via webEM
    [Documentation]  This keyword is used to start F1AP log capture via webEM
    ...  Author: Ding Binmei
    [Arguments]    ${gnb_index}=${0}    ${connection}=oam_cu_${gnb_index}_ip_traffic_capture_vcu
    ${list_pod_names}    Create list    po-cpif-0
    Start Ip Traffic Capture on vCU    list_pod_names=${list_pod_names}    capture_type=pod    plane_type=cplane
    ...    gnb_index=${gnb_index}    connection=${connection}

Stop F1AP log capture via webEM
    [Documentation]  This keyword is used to stop F1AP log capture via webEM
    ...  Author: Ding Binmei
    [Arguments]   ${gnb_index}=${0}    ${connection}=oam_cu_${gnb_index}_ip_traffic_capture_vcu    ${target_dir}=${TS_CASE_LOG_PATH}
    ${list_pod_names}    Create list    po-cpif-0
    ${dict_file_path}    Stop Ip Traffic Capture on vCU    list_pod_names=${list_pod_names}    target_dir=${target_dir}
    ...    gnb_index=${gnb_index}    connection=${connection}
    [Return]    ${dict_file_path['po-cpif-0']}