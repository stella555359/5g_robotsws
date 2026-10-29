*** Settings ***
Documentation
...   Author: Xiang Liang
...   Contact: liang.xiang@nokia-sbell.com



*** Keywords ***
# ------------------------------------Get Simple Parameters Of Current Plan For VCU  ----------------------------------
Get Simple Parameters Of Current Plan For VCU
    [Arguments]    ${parameter_name}=administrativeState    ${gnb_index}=0
    ...            ${mo_dn}=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}
    [Documentation]   Check plan activate status should be as expected.
        ...    Author: Cao Ge
        ...    Contact: ge.cao@nokia-sbell.com
        ...    | Input Parameters | Man. | Description |
        ...	   |  parameter_name  | Yes. |  Plan file id  |
        ...	   |  gnb_index  | No. |  gnb index  |
        ...	   |  mo_dn  | Yes. |  Dist Name of Target Parameter   |
        ...    | Return Value | Description |
        ...    | ${para_value} | return parameter value |
        ...    Example
        ...    |  Get Simple Parameters Of Current Plan For VCU   |
        ...    |  ...       |  parameter_name=administrativeState |  mo_dn=MRBTS-10868/NRBTS-10868
    Log To Console    ${gnb_index}
    ${para_result}    cu.get_parameters    dist_name=${mo_dn}
    ${result_length}    get length    ${para_result['parameters']}
    FOR    ${index}    IN RANGE    ${result_length}
        Continue For Loop If       "${para_result['parameters'][${index}]['parameter_type']}" != "simple"
        ${simple_para_name}    set variable    ${para_result['parameters'][${index}]['simple_parameter'].name}
        Run Keyword If    "${simple_para_name}" == "${parameter_name}"
        ...                Set Test Variable    ${index}
        exit for loop if    "${simple_para_name}" == "${parameter_name}"
        Run Keyword If    ${index}==${result_length}-${1}   fail    get parameter is failed
    END
    ${para_value}    set variable    ${para_result['parameters'][${index}]['simple_parameter'].value}
    Set Test variable    ${para_value}
    [Return]    ${para_value}


# ------------------------------------Get Active Alarm In vCU  ----------------------------------
Get Fault ID Of Active Alarm In vCU
    [Arguments]    ${gnb_index}=0
    [Documentation]   Get Fault ID Of Active Alarm In vCU
        ...    Author: Xiang Liang
        ...    Contact: liang.xiang@nokia-sbell.com
        ...    | Input Parameters | Man. | Description |
        ...	   |  gnb_index  | No. |  gnb index  |
        ...    *RETURN VALUE*
        ...    |  fault_id_list  |
        ...    Example
        ...    |  ${GET_FAULT_LIST}  |  Get Fault ID Of Active Alarm In vCU  |
    Log To Console      Get Fault ID Of Active Alarm In vCU
    Login To vCU By Rest    gnb_index=${gnb_index}
    ${active_alarm_list}=    cu.get_active_alarms    page_number=${1}    items_per_page=${1000}
    ${fault_id_list}=    create list
    FOR    ${index}    IN RANGE    ${active_alarm_list["total"]}
        log to Console    ${active_alarm_list['alarms'][${index}]['fault_id']}
        append to list    ${fault_id_list}     ${active_alarm_list['alarms'][${index}]['fault_id']}
    END
    [Return]      ${fault_id_list}
    [Teardown]    Run keyword and ignore error    Logout To vCU By Rest


# ------------------------------------UE Related  ----------------------------------
Prepare UE0
    ${ue0_type}    translate_power_ue_type_from_testline    ue_index=${0}
	Set Test Variable    ${ue0_type}
	Log to Console    \n***Prepare UE***
    Prepare UE    ${ue0_type}    ue_index=${0}


Attach UE0
    Log to Console    \n***UE Attach***
    UE Attach    ${ue0_type}    ue_index=${0}


Check UL Tput By K8s Log
    ${ul_l2rt_tput_local_file_path}    Collect And Download K8s Log In vDU    gnb_index=${0}    vdu_index=${0}
    ...                                                     container_name=l2rt    pod_name=up   timeout=${10}
    Set Test Variable    ${ul_l2rt_tput_local_file_path}
    ${ave_ul_tput}    ${max_ul_tput}    ${min_ul_tput}    k8s.get_ul_tput_from_k8s_log    ${ul_l2rt_tput_local_file_path}
    should be true  ${max_ul_tput}>0


Check DL Tput By K8s Log
    ${dl_l2rt_tput_local_file_path}    Collect And Download K8s Log In vDU    gnb_index=${0}    vdu_index=${0}
    ...                                      container_name=l2rt    pod_name=up   timeout=${10}
    Set Test Variable    ${dl_l2rt_tput_local_file_path}
    ${ave_dl_tput}    ${max_dl_tput}    ${min_dl_tput}    k8s.get_dl_tput_from_k8s_log    ${dl_l2rt_tput_local_file_path}
    should be true  ${max_dl_tput}>0


Detach UE0
    Log to Console    \n***UE Detach***
    UE Detach    ${ue0_type}    ue_index=${0}

Start Capture Cplane Wireshark Log In vCU With Shell
    [Arguments]    ${file_name}=capture_cplane_nsenter_tcpdump.sh    ${duration}=30    ${alias}=gNB
    [Documentation]    This kw is used to Start Capture Cplane wireshark Log in VCU
    ...    Author: gcao
    ...    Contact: ge.cao@nokia-sbell.com
    ...    | file_name | no | vcu capture wireshark command file name|
    ...    | duration | yes | capture duration |
    ...    | alias | no | define the alais of vcu connect|
    ...
    ...    Example
    ...    | Start Capture Cplane Wireshark Log In vCU |
    ...    | ${file_name}=capture_cplane_nsenter_tcpdump.sh | ${duration}=30 | ${alias}=gNB |
    ...
    set suite variable   ${cu_file_path}   /var/home/${cu_master_username}
    set suite variable    ${cplane_log_dir}   cplane_log
    ${capture_file_path}    Set Variable
    ...   https://gitlabe1.ext.net.nokia.com/xiaomiaz/5g_aic_toolset/-/raw/master/aic_cplane_data_handler/${file_name}
    ${curl_capture}    catenate    curl -o ${file_name}    ${capture_file_path}
    ${capture_cmd}    catenate    bash ${file_name} -n ${VCU_NAMESPACE} -u ${cu_master_username}
    ...    -p '${cu_master_password}' -c yes -f yes -d ${duration} -b ${cu_file_path}/${cplane_log_dir}
    Wait until Keyword Succeeds  60s   1s
    ...   issh.connect_to     ip=${cu_master_ip}    username=${cu_master_username}
    ...   password=${cu_master_password}    prompt=$    alias=${alias}    timeout=30
    issh.set prompt   $  alias=${alias}
    issh.Execute   command=rm -rf ${cu_file_path}/${cplane_log_dir}    check_result=${False}  alias=${alias}
    sleep  10s
    issh.Execute   command=mkdir ${cplane_log_dir};chmod 777 ${cplane_log_dir}    check_result=${False}  alias=${alias}
    issh.Execute   command=cd ${cu_file_path}/${cplane_log_dir};${curl_capture};chmod 777 ${file_name}
    ...            check_result=${False}  alias=${alias}
    sleep  15s
    issh.Execute   command=find ${cu_file_path}/${cplane_log_dir}/${file_name}   check_result=${False}  alias=${alias}
    issh.read_output_until    prompt=${cu_file_path}/${cplane_log_dir}/${file_name}    alias=${alias}
    issh.Execute   command=${capture_cmd}    check_result=${False}    alias=${alias}


Stop Capture Cplane Wireshark Log In vCU With Shell
    [Arguments]    ${alias}=gNB
    [Documentation]    This kw is used to Stop Capture Cplane wireshark Log in VCU
    ...    Author: gcao
    ...    Contact: ge.cao@nokia-sbell.com
    ...    | alias | no | define the alais of vcu connect,should be consistent with start capture cplane wireshark log|
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Stop Capture Cplane Wireshark Log In vCU |  ${alias}=gNB |
    ...
    Wait until Keyword Succeeds  30s   5s   issh.read_output_until    prompt=to local successfully    alias=${alias}
    ${scp_capture_cmd}    catenate   sshpass -p ${cu_master_password} scp
    ...  ${cu_master_username}@${cu_master_ip}:${cu_file_path}/${cplane_log_dir}/cpif_*.pcap
    ...  ${TEST_LOG_DIRECTORY}/cplane.pcap
    Run   ${scp_capture_cmd}
    ${local_file_path}    Set Variable    ${TEST_LOG_DIRECTORY}/cplane.pcap
    [Return]    ${local_file_path}
    [Teardown]    run keyword and ignore error  issh.disconnect  alias=gNB


Custom Suite Teardown For AIC
    Common Suite Teardown For AIC
    ${cmd}=    Set Variable    find ${SUITE_LOG_DIRECTORY} -name '*napshot*.zip'
    ${result}    Run Process    ${cmd}    shell=True
    log to console    ${result.stdout}

    ${cmd_new}=    Set Variable    ${cmd} -delete
    ${result}    Run Process    ${cmd_new}    shell=True
    log to console    ${result.stdout}
    log to console    ${result.stderr}
    log to console    ${result.rc}
