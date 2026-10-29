*** Settings ***
Documentation
...    Author: mengli yang
...    Contact: mengli.yang@nokia-sbell.com
...    this file is collect some Common KWs of AIC,you can use it in your case directly.
...    Please do not modify the file without notification to author



*** Keywords ***
Case Precondition
    log to console    Case Precondition
    Common Test Setup For AIC
    ${vdu_hostname_dict}    ${vdu_username_dict}    ${vdu_password_dict}    ${vdu_ns_dict}
    ...                                               Get SSH Connection Infor For Multiple vDU With Different vCU
    Set Test Variable    ${vdu_hostname_dict}
    Set Test Variable    ${vdu_username_dict}
    Set Test Variable    ${vdu_password_dict}
    Set Test Variable    ${vdu_ns_dict}
    ${vcu_hostname_list}  ${vcu_username_list}  ${vcu_password_list}  ${vcu_ns_list}
    ...                                               Get SSH Connection Infor For Multiple vCU K8s Master
    Set Test Variable    ${vcu_hostname_list}
    Set Test Variable    ${vcu_username_list}
    Set Test Variable    ${vcu_password_list}
    Set Test Variable    ${vcu_ns_list}

Case Postcondition
    log to console    Case Postcondition
    Common Test Teardown For AIC


############################## call ##############################
Prepare And Attach UE
    [Arguments]    ${ue_index}=${0}    ${ui_version}=MATE40PROUI1.0
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    Set Test Variable    ${ue_${ue_index}_type}    ${ue_type}
    Log to Console    \n***Prepare UE***
    Prepare UE    ${ue_${ue_index}_type}    ue_index=${ue_index}    ui_version=${ui_version}
    UE Attach    ${ue_${ue_index}_type}    ue_index=${ue_index}    verify_attach=True
    [Return]     ${ue_${ue_index}_type}

Start traffic For UE
    [Arguments]    ${ue_index}=${0}     ${ue_type}=${ue_${ue_index}_type}    ${direction}=dl
    ...            ${capabilities}=huawei1    ${call_number}=004488
    Run Keyword If    '${direction}' == 'dl'    Start traffic    ue_type=${ue_type}    ue_index=${ue_index}    direction=dl
    ...                                                          dt_index=${ue_index}
    ...              throughput=110M    duration=${600}
    ...       ELSE IF     '${direction}' == 'ul'    Start traffic    ue_type=${ue_type}    ue_index=${ue_index}    direction=ul
    ...                                                              dt_index=${ue_index}
    ...              throughput=110M    duration=${600}
    ...       ELSE IF     '${direction}' == 'all'    Start DL and UL Call For UE    ue_index=${ue_index}    ue_type=${ue_type}
    ...              throughput=110M    duration=${600}
    ...       ELSE IF     '${direction}' == 'vonr'    Start VONR Call For UE    ue_index=${ue_index}    capabilities=${capabilities}
    ...              call_number=${call_number}

Start Call For UE
    [Arguments]    ${ue_index}=${0}     ${ue_type}=${ue_${ue_index}_type}    ${direction}=dl
    Start traffic    ue_type=${ue_type}    ue_index=${ue_index}    direction=${direction}    dt_index=${ue_index}
	...              throughput=110M    duration=${600}

Start DL and UL Call For UE
    [Arguments]    ${ue_index}=${0}     ${ue_type}=${ue_${ue_index}_type}
    Start traffic    ue_type=${ue_type}    ue_index=${ue_index}    direction=dl    dt_index=${ue_index}
	...              throughput=110M    duration=${600}
	Start traffic    ue_type=${ue_type}    ue_index=${ue_index}    direction=ul    dt_index=${ue_index}
	...              throughput=110M    duration=${600}

Start VONR Call For UE
    [Arguments]    ${ue_index}=${0}    ${capabilities}=huawei1    ${call_number}=004488
    Log To Console    ${capabilities}
    Start VONR Call    ue_type=${ue_${ue_index}_type}    ue_index=${ue_index}    vc_alias=VC_1    call_number=${call_number}
    ...            duration=600s    capabilities=huawei1

Reboot UE
    [Arguments]    ${ue_index}=${0}
    ADB Reboot UE    ue_index=${ue_index}
    sleep    300s    reason=wait reboot UE suceesfully

Start Emergency Call For UE
    [Arguments]    ${ue_index}=${0}     ${ue_type}=${ue_${ue_index}_type}
    Start VONR Call    ue_type=${ue_type}    ue_index=${ue_index}    vc_alias=VC_1    call_number=911
    ...            duration=600s    capabilities=huawei1

Stop VONR Call For UE
    [Arguments]    ${ue_index}=${0}     ${ue_type}=${ue_${ue_index}_type}
    Stop VONR Call    ue_type=${ue_type}    vc_alias=VC_1

Start VONR Call Without Require Ue
    [Arguments]    ${ue_index}=${0}
    Start Voice Call    vc_alias=VC_1   ue_alias=UE_${ue_index}    to=004488    duration=600s

############################## log ##############################
Collect Container Log In vDU
    ${k8s_oamconfig_local_file_path}    Collect And Download K8s Log In vDU    gnb_index=${0}    vdu_index=${0}
    ...                       container_name=oamconfig    pod_name=oamconfig    timeout=${10}    duration=60s
    Set Test Variable    ${k8s_oamconfig_local_file_path}

Collect Container Log In vCU
    ${local_file_path}    Collect And Download K8s Log In vCU    gnb_index=${0}    vdu_index=${0}    container_name=cpif
    ...                                                          pod_name=cpif    timeout=${10}
    Set Test Variable    ${local_file_path}

Check Container Log In vDU
    Log    Check Symbols By K8s Log.    console=True
    ${k8slog_prints}=    Create list
    ...    guardPeriodLength.*?6Symbols
    Check K8s Log    local_file_path=${local_file_path}
    ...              k8slog_prints=${k8slog_prints}
    ...              filter=ctr-cran1-oamfh

Check Container Log In vCU
    Log    Check Symbols By K8s Log.    console=True
	${k8slog_prints}=    Create list
	...    ngap
    Check K8s Log    local_file_path=${local_file_path}
    ...              k8slog_prints=${k8slog_prints}
    ...              filter=cpif

Check DL Tput By K8s Log
    ${dl_l2rt_tput_local_file_path}    Collect And Download K8s Log In vDU    gnb_index=${0}    vdu_index=${0}
    ...                                      container_name=l2rt    pod_name=up   timeout=${10}    duration=60s
    Set Test Variable    ${dl_l2rt_tput_local_file_path}
    ${ave_dl_tput}    ${max_dl_tput}    ${min_dl_tput}    k8s.get_dl_tput_from_k8s_log    ${dl_l2rt_tput_local_file_path}
    should be true  ${max_dl_tput}>10

Check UL Tput By K8s Log
    ${ul_l2rt_tput_local_file_path}    Collect And Download K8s Log In vDU    gnb_index=${0}    vdu_index=${0}
    ...                                 container_name=l2rt    pod_name=up   timeout=${10}    duration=60s
    Set Test Variable    ${ul_l2rt_tput_local_file_path}
    ${ave_ul_tput}    ${max_ul_tput}    ${min_ul_tput}    k8s.get_ul_tput_from_k8s_log    ${ul_l2rt_tput_local_file_path}
    should be true  ${max_ul_tput}>10

Start Collect Wireshark Log
    [Arguments]    ${container_name}=nwmgmt    ${pod_name}=cpif    ${NE}=vDU    ${gnb_index}=${0}
    ...            ${gnb2_index}=${1}    ${index}=${0}    ${index1}=${0}
    Run Keyword If    '${NE}'=='vCU'    Start Collect Wireshark Log In vCU
    ...                                                           container_name=${container_name}
    ...                                                           pod_name=${pod_name}
    ...                                                           index=${index}
    ...       ELSE IF    '${NE}'=='vDU'    Start Collect Wireshark Log In vDU
    ...                                                           container_name=${container_name}
    ...                                                           pod_name=${pod_name}
    ...                                                           gnb_index=${gnb_index}
    ...                                                           index=${index}
    ...       ELSE IF    '${NE}'=='all'    Start Collect Wireshark Log Both vCU And vDU
    ...                                                           container_name=${container_name}
    ...                                                           vdu_pod_name=cprt
    ...                                                           vcu_pod_name=cpif
    ...                                                           gnb_index=${gnb_index}
    ...                                                           index=${index}
    ...                                                           index1=${index1}
    ...       ELSE IF    '${NE}'=='Multi_vDU'    Start Collect Wireshark Log For Multi vDU
    ...                                                           container_name=${container_name}
    ...                                                           pod_name=${pod_name}
    ...                                                           gnb_index=${gnb_index}
    ...                                                           gnb2_index=${gnb2_index}
    ...                                                           index=${index}
    ...                                                           index1=${index1}
    ...       ELSE IF    '${NE}'=='Multi_vCU'    Start Collect Wireshark Log For Multi vCU
    ...                                                           container_name=${container_name}
    ...                                                           pod_name=${pod_name}
    ...                                                           index=${index}
    ...                                                           index1=${index1}


Start Collect Wireshark Log In vCU
    [Arguments]    ${container_name}=nwmgmt    ${pod_name}=cpif    ${index}=${0}
    Log to Console    \n***Start Wireshark Log In vCU***
    Start Wireshark Log In vCU   container_name=${container_name}
    ...                          pod_name=${pod_name}
    ...                          timeout=${10}
    ...                          protocol=sctp
    ...                          interface=any
    ...                          hostname=${vcu_hostname_list[${index}]}
    ...                          username=${vcu_username_list[${index}]}
    ...                          password=${vcu_password_list[${index}]}
    ...                          namespace=${vcu_ns_list[${index}]}

Start Collect Wireshark Log In vDU
    [Arguments]    ${container_name}=nwmgmt    ${pod_name}=cprt    ${gnb_index}=${0}    ${index}=${0}
    Log to Console    \n***Start Wireshark Log In vCU***
    Start Wireshark Log In vDU   container_name=${container_name}
    ...                          pod_name=${pod_name}
    ...                          timeout=${10}
    ...                          protocol=sctp
    ...                          interface=any
    ...                          hostname=${vdu_hostname_dict['vcu_${gnb_index}_vdu_hostname'][${index}]}
    ...                          username=${vdu_username_dict['vcu_${gnb_index}_vdu_username'][${index}]}
    ...                          password=${vdu_password_dict['vcu_${gnb_index}_vdu_password'][${index}]}
    ...                          namespace=${vdu_ns_dict['vcu_${gnb_index}_vdu_ns'][${index}]}

Start Collect Wireshark Log For Multi vDU
    [Arguments]    ${container_name}=nwmgmt    ${pod_name}=cprt    ${gnb_index}=${0}
    ...            ${gnb2_index}=${0}    ${index}=${0}    ${index1}=${0}
    Log to Console    \n***Start Wireshark Log In vCU***
    Start Wireshark Log In vDU   container_name=${container_name}
    ...                          pod_name=${pod_name}
    ...                          timeout=${10}
    ...                          protocol=sctp
    ...                          interface=any
    ...                          hostname=${vdu_hostname_dict['vcu_${gnb_index}_vdu_hostname'][${index}]}
    ...                          username=${vdu_username_dict['vcu_${gnb_index}_vdu_username'][${index}]}
    ...                          password=${vdu_password_dict['vcu_${gnb_index}_vdu_password'][${index}]}
    ...                          namespace=${vdu_ns_dict['vcu_${gnb_index}_vdu_ns'][${index}]}
    Start Wireshark Log In vDU   container_name=${container_name}
    ...                          pod_name=${pod_name}
    ...                          timeout=${10}
    ...                          protocol=sctp
    ...                          interface=any
    ...                          hostname=${vdu_hostname_dict['vcu_${gnb2_index}_vdu_hostname'][${index1}]}
    ...                          username=${vdu_username_dict['vcu_${gnb2_index}_vdu_username'][${index1}]}
    ...                          password=${vdu_password_dict['vcu_${gnb2_index}_vdu_password'][${index1}]}
    ...                          namespace=${vdu_ns_dict['vcu_${gnb2_index}_vdu_ns'][${index1}]}

Start Collect Wireshark Log Both vCU And vDU
    [Arguments]    ${container_name}=nwmgmt    ${vdu_pod_name}=cprt    ${vcu_pod_name}=cpif
    ...            ${gnb_index}=${0}    ${index}=${0}    ${index1}=${0}
    Log to Console    \n***Start Wireshark Log In vCU***
    Start Wireshark Log In vCU   container_name=${container_name}
    ...                          pod_name=${vcu_pod_name}
    ...                          timeout=${10}
    ...                          protocol=sctp
    ...                          interface=any
    ...                          hostname=${vcu_hostname_list[${index}]}
    ...                          username=${vcu_username_list[${index}]}
    ...                          password=${vcu_password_list[${index}]}
    ...                          namespace=${vcu_ns_list[${index}]}
    Start Wireshark Log In vDU   container_name=${container_name}
    ...                          pod_name=${vdu_pod_name}
    ...                          timeout=${10}
    ...                          protocol=sctp
    ...                          interface=any
    ...                          hostname=${vdu_hostname_dict['vcu_${gnb_index}_vdu_hostname'][${index1}]}
    ...                          username=${vdu_username_dict['vcu_${gnb_index}_vdu_username'][${index1}]}
    ...                          password=${vdu_password_dict['vcu_${gnb_index}_vdu_password'][${index1}]}
    ...                          namespace=${vdu_ns_dict['vcu_${gnb_index}_vdu_ns'][${index1}]}


Start Collect Wireshark Log For Multi vCU
    [Arguments]    ${container_name}=nwmgmt    ${pod_name}=cpif    ${index}=${0}    ${index1}=${0}
    Log to Console    \n***Start Wireshark Log In vCU***
    Start Wireshark Log In vCU   container_name=${container_name}
    ...                          pod_name=${pod_name}
    ...                          timeout=${10}
    ...                          protocol=sctp
    ...                          interface=any
    ...                          hostname=${vcu_hostname_list[${index}]}
    ...                          username=${vcu_username_list[${index}]}
    ...                          password=${vcu_password_list[${index}]}
    ...                          namespace=${vcu_ns_list[${index}]}

    Start Wireshark Log In vCU   container_name=${container_name}
    ...                          pod_name=${pod_name}
    ...                          timeout=${10}
    ...                          protocol=sctp
    ...                          interface=any
    ...                          hostname=${vcu_hostname_list[${index1}]}
    ...                          username=${vcu_username_list[${index1}]}
    ...                          password=${vcu_password_list[${index1}]}
    ...                          namespace=${vcu_ns_list[${index1}]}

Stop Wireshark Log
    [Arguments]    ${container_name}=nwmgmt    ${pod_name}=cpif    ${NE}=vDU
    ...            ${gnb_index}=${0}    ${gnb2_index}=${0}    ${index}=${0}    ${index1}=${0}
    ...            ${vdu_pod_name}=cprt    ${vcu_pod_name}=cpif
    Log To Console    ${gnb2_index}
    Run Keyword If    '${NE}'=='vDU'    Stop Wireshark Log In vDU
    ...                                                           container_name=${container_name}
    ...                                                           pod_name=${pod_name}
    ...                                                           gnb_index=${gnb_index}
    ...                                                           index=${index}
    ...    ELSE IF    '${NE}'=='vCU'    Stop Wireshark Log In vCU
    ...                                                           container_name=${container_name}
    ...                                                           pod_name=${pod_name}
    ...                                                           index=${index}
    ...    ELSE IF    '${NE}'=='all'    Stop Wireshark Log Both vCU And vDU
    ...                                                           container_name=${container_name}
    ...                                                           vdu_pod_name=${vdu_pod_name}
    ...                                                           vcu_pod_name=${vcu_pod_name}
    ...                                                           gnb_index=${gnb_index}
    ...                                                           index=${index}
    ...    ELSE IF    '${NE}'=='Multi_vDU'    Stop Wireshark Log For Multi vDU
    ...                                                           container_name=${container_name}
    ...                                                           pod_name=${pod_name}
    ...                                                           gnb_index=${gnb_index}
    ...                                                           gnb2_index=${gnb_index}
    ...                                                           index=${index}
    ...                                                           index1=${index1}
    ...    ELSE IF    '${NE}'=='Multi_vCU'    Stop Wireshark Log For Multi vCU
    ...                                                           container_name=${container_name}
    ...                                                           pod_name=${pod_name}
    ...                                                           index=${index}
    ...                                                           index1=${index1}

Stop Wireshark Log In vCU
    [Arguments]    ${container_name}=cpif    ${pod_name}=cpif    ${index}=${0}
    ${wireshark_local_file_path_vCU}    Stop Wireshark Log And Download To K8s Master In vCU
    ...                                               container_name=${container_name}
    ...                                               pod_name=${pod_name}
    ...                                               timeout=${10}
    ...                                               hostname=${vcu_hostname_list[${index}]}
    ...                                               username=${vcu_username_list[${index}]}
    ...                                               password=${vcu_password_list[${index}]}
    ...                                               namespace=${vcu_ns_list[${index}]}
    Set Test Variable    ${wireshark_local_file_path_vCU}


Stop Wireshark Log In vDU
    [Arguments]    ${container_name}=cpif    ${pod_name}=cpif
    ...            ${gnb_index}=${0}    ${index}=${0}
    ${wireshark_local_file_path_vDU}    Stop Wireshark Log And Download To K8s Master In vDU
    ...                          container_name=${container_name}
    ...                          pod_name=${pod_name}
    ...                          timeout=${10}
    ...                          hostname=${vdu_hostname_dict['vcu_${gnb_index}_vdu_hostname'][${index}]}
    ...                          username=${vdu_username_dict['vcu_${gnb_index}_vdu_username'][${index}]}
    ...                          password=${vdu_password_dict['vcu_${gnb_index}_vdu_password'][${index}]}
    ...                          namespace=${vdu_ns_dict['vcu_${gnb_index}_vdu_ns'][${index}]}
    Set Test Variable    ${wireshark_local_file_path_vDU}

Stop Wireshark Log For Multi vDU
    [Arguments]    ${container_name}=cpif    ${pod_name}=cpif    ${gnb_index}=${0}    ${gnb2_index}=${0}
    ...            ${index}=${0}    ${index1}=${0}
    ${wireshark_local_file_path_vDU}    Stop Wireshark Log And Download To K8s Master In vDU
    ...                          container_name=${container_name}
    ...                          pod_name=${pod_name}
    ...                          timeout=${10}
    ...                          hostname=${vdu_hostname_dict['vcu_${gnb_index}_vdu_hostname'][${index}]}
    ...                          username=${vdu_username_dict['vcu_${gnb_index}_vdu_username'][${index}]}
    ...                          password=${vdu_password_dict['vcu_${gnb_index}_vdu_password'][${index}]}
    ...                          namespace=${vdu_ns_dict['vcu_${gnb_index}_vdu_ns'][${index}]}}
    ${wireshark_local_file_path_vDU}    Stop Wireshark Log And Download To K8s Master In vDU
    ...                          container_name=${container_name}
    ...                          pod_name=${pod_name}
    ...                          timeout=${10}
    ...                          hostname=${vdu_hostname_dict[vcu_${gnb2_index}_vdu_hostname][${index1}]}
    ...                          username=${vdu_hostname_dict[vcu_${gnb2_index}_vdu_hostname][${index1}]}
    ...                          password=${vdu_hostname_dict[vcu_${gnb2_index}_vdu_hostname][${index1}]}
    ...                          namespace=${vdu_hostname_dict[vcu_${gnb2_index}_vdu_hostname][${index1}]}
    Set Test Variable    ${wireshark_local_file_path_vDU}

Stop Wireshark Log For Multi vCU
    [Arguments]    ${container_name}=cpif    ${pod_name}=cpif    ${index}=${0}    ${index1}=${1}
    ${wireshark_local_file_path_vCU}    Stop Wireshark Log And Download To K8s Master In vCU
    ...                                               container_name=${container_name}
    ...                                               pod_name=${pod_name}
    ...                                               timeout=${10}
    ...                                               hostname=${vcu_hostname_list[${index}]}
    ...                                               username=${vcu_username_list[${index}]}
    ...                                               password=${vcu_password_list[${index}]}
    ...                                               namespace=${vcu_ns_list[${index}]}
    Set Test Variable    ${wireshark_local_file_path_vCU}
    ${wireshark_local_file_path_vCU}    Stop Wireshark Log And Download To K8s Master In vCU
    ...                                               container_name=${container_name}
    ...                                               pod_name=${pod_name}
    ...                                               timeout=${10}
    ...                                               hostname=${vcu_hostname_list[${index1}]}
    ...                                               username=${vcu_username_list[${index1}]}
    ...                                               password=${vcu_password_list[${index1}]}
    ...                                               namespace=${vcu_ns_list[${index1}]}
    Set Test Variable    ${wireshark_local_file_path_vCU}

Stop Wireshark Log Both vCU And vDU
    [Arguments]    ${container_name}=nwmgmt    ${vdu_pod_name}=cprt    ${vcu_pod_name}=cpif   ${gnb_index}=${0}
    ...            ${index}=${0}    ${index1}=${0}
    ${wireshark_local_file_path_vCU}    Stop Wireshark Log And Download To K8s Master In vCU
    ...                                               container_name=${container_name}
    ...                                               pod_name=${vcu_pod_name}
    ...                                               timeout=${10}
    ...                                               hostname=${vcu_hostname_list[${index}]}
    ...                                               username=${vcu_username_list[${index}]}
    ...                                               password=${vcu_password_list[${index}]}
    ...                                               namespace=${vcu_ns_list[${index}]}
    Set Test Variable    ${wireshark_local_file_path_vCU}
    ${wireshark_local_file_path_vDU}    Stop Wireshark Log And Download To K8s Master In vDU
    ...                          container_name=${container_name}
    ...                          pod_name=${vdu_pod_name}
    ...                          timeout=${10}
    ...                          hostname=${vdu_hostname_dict['vcu_${gnb_index}_vdu_hostname'][${index1}]}
    ...                          username=${vdu_username_dict['vcu_${gnb_index}_vdu_username'][${index1}]}
    ...                          password=${vdu_password_dict['vcu_${gnb_index}_vdu_password'][${index1}]}
    ...                          namespace=${vdu_ns_dict['vcu_${gnb_index}_vdu_ns'][${index1}]}
    Set Test Variable    ${wireshark_local_file_path_vDU}

Check Wireshark Log
    [Arguments]    ${input_file}=${wireshark_local_file_path_vCU}
    ${filter_list} =    Create list    f1ap.service_state == 0
    ${expect_message}=    Create list    UEContextReleaseCommand
    ${filter_length}    get length    ${filter_list}
    FOR    ${index}    IN RANGE    ${filter_length}
        ${result} =    Analysis Wireshark Log    input_file=${input_file}
        ...                                      filter_expression=${filter_list[${index}]}
        should contain    ${result}    ${expect_message[${index}]}
    END

Stop Wireshark Log And Check Wireshark Log
    [Arguments]    ${container_name}=cpif    ${pod_name}=cpif    ${log_name}=vcu_wireshark    ${NE}=vDU
    Run Keyword If    '${NE}'=='vDU'    Stop Wireshark Log And Check Wireshark Log In vDU
    ...                                                           container_name=${container_name}
    ...                                                           pod_name=${pod_name}
    ...                                                           log_name=${log_name}
    ...       ELSE     Stop Wireshark Log And Check Wireshark Log In vCU
    ...                                                           container_name=${container_name}
    ...                                                           pod_name=${pod_name}
    ...                                                           log_name=${log_name}


Stop Wireshark Log And Check Wireshark Log In vCU
    [Arguments]    ${container_name}=cpif    ${pod_name}=cpif    ${log_name}=vcu_wireshark
    ${wireshark_local_file_path}    Stop Wireshark Log And Download To K8s Master In vCU   gnb_index=${0}
    ...                                                                    container_name=${container_name}
    ...                                                                    pod_name=${pod_name}
    ...                                                                    timeout=${10}
    ...                                                                    log_name=${log_name}
    ${filter_list} =    Create list    f1ap.service_state == 0
    ${expect_message}=    Create list    UEContextReleaseCommand
    ${filter_length}    get length    ${filter_list}
    FOR    ${index}    IN RANGE    ${filter_length}
        ${result} =    Analysis Wireshark Log    input_file=${wireshark_local_file_path}
        ...                                      filter_expression=${filter_list[${index}]}
        should contain    ${result}    ${expect_message[${index}]}
    END

Stop Wireshark Log And Check Wireshark Log In vDU
    [Arguments]    ${container_name}=cpif    ${pod_name}=cpif    ${log_name}=vdu_wireshark
    ${wireshark_local_file_path}    Stop Wireshark Log And Download To K8s Master In vDU   gnb_index=${0}
    ...                                                                    container_name=${container_name}
    ...                                                                    pod_name=${pod_name}
    ...                                                                    timeout=${10}
    ...                                                                    log_name=${log_name}
    ${filter_list} =    Create list    f1ap.service_state == 0
    ${expect_message}=    Create list    UEContextReleaseCommand
    ${filter_length}    get length    ${filter_list}
    FOR    ${index}    IN RANGE    ${filter_length}
        ${result} =    Analysis Wireshark Log    input_file=${wireshark_local_file_path}
        ...                                      filter_expression=${filter_list[${index}]}
        should contain    ${result}    ${expect_message[${index}]}
    END


Check Counter In vDU
    [Arguments]    ${counter_id_list}    ${dim_dn}    ${gnb_index}=0
    ...            ${comparison}=greater    ${expected_value}=0    ${get_number}=3
    Log to Console    \n***check counter in vDU***
    FOR    ${counter_id}    IN    @{counter_id_list}
        Check Counter For vDU   counter_id=${counter_id}
        ...                     dimension_dn=${dim_dn}
        ...                     comparison=${comparison}
        ...                     expected_value=${expected_value}
        ...                     get_number=${get_number}
        ...                     gnb_index=${gnb_index}
    END

Check Counter In vCU
    [Arguments]    ${counter_id_list}    ${dim_dn}    ${gnb_index}=0
    ...            ${comparison}=greater    ${expected_value}=0    ${get_number}=3
    Log to Console    \n***check counter in vCU***
    FOR    ${counter_id}    IN    @{counter_id_list}
        @{words}=    split string    ${counter_id}   C
        ${mea_id}=   Fetch From Right    ${words[0]}  M
        Check Counter For vCU   counter_id=${counter_id}
        ...                     measurement_id=${mea_id}
        ...                     dimension_dist_name=${dim_dn}
        ...                     comparison=${comparison}
        ...                     expected_value=${expected_value}
        ...                     get_number=${get_number}
        ...                     gnb_index=${gnb_index}
    END

Check Any One Value In Multiple Counters In vDU
    [Arguments]    ${counter_id_list}    ${dim_dn}    ${gnb_index}=0
    ...            ${comparison}=greater    ${expected_value}=0    ${get_number}=3
    Log to Console    \n***check any one value in multiple counters in vDU***
    ${status}=   set variable   False
    ${counter_values_final_list}    Create List
    FOR    ${counter_id}    IN    @{counter_id_list}
        ${counter_values_final_list}    Run Keyword And Ignore Error    Check Counter For vDU
        ...                                            counter_id=${counter_id}
        ...                                            dimension_dn=${dim_dn}
        ...                                            comparison=${comparison}
        ...                                            expected_value=${expected_value}
        ...                                            get_number=${get_number}
        ...                                            gnb_index=${gnb_index}
        ${status}=    set variable if    '${counter_values_final_list[0]}'=='PASS'    True
        exit for loop if    '${status}'=='True'
    END
    should be equal    ${status}    True    Check counter value failed!

Check Any One Value In Multiple Counters In vCU
    [Arguments]    ${counter_id_list}    ${dim_dn}    ${gnb_index}=0
    ...            ${comparison}=greater    ${expected_value}=0    ${get_number}=3
    Log to Console    \n***check any one value in multiple counters in vCU***
    ${status}=   set variable   False
    ${counter_values_final_list}    Create List
    FOR    ${counter_id}    IN    @{counter_id_list}
        @{words}=    split string    ${counter_id}   C
        ${mea_id}=   Fetch From Right    ${words[0]}  M
        ${counter_values_final_list}    Run Keyword And Ignore Error    Check Counter For vCU
        ...                                            counter_id=${counter_id}
        ...                                            measurement_id=${mea_id}
        ...                                            dimension_dist_name=${dim_dn}
        ...                                            comparison=${comparison}
        ...                                            expected_value=${expected_value}
        ...                                            get_number=${get_number}
        ...                                            gnb_index=${gnb_index}
        ${status}=    set variable if    '${counter_values_final_list[0]}'=='PASS'    True
        exit for loop if    '${status}'=='True'
    END
    should be equal    ${status}    True    Check counter value failed!

Start Bip Log In vDU
    Start Bip Log    gnb_index=${0}    vdu_index=${0}    container_name=l2hi    pod_name=up
    ...              pod_prefix=po-cran1    container_prefix=ctr-cran1    port_name=l2biphi
    ...              timeout=${10}

Stop Bip Log In vDU
    ${bip_local_file_path}=    Stop Bip Log And Download To K8s Master    gnb_index=${0}    vdu_index=${0}
    ...                                                               container_name=l2rt    pod_name=up
    ...                                                               pod_prefix=po-cran1    container_prefix=ctr-cran1
    ...                                                               timeout=${10}

Check Bip Log In vDU
    [Arguments]    ${name}=l1hi
    ${filter}=    Set Variable
    ...    3gpp.slot||dldata_pdschsendreq||uldata_puschreceiverespps
    ${csv_title}=    Set Variable    -e dldata_pdschsendreq -e uldata_puschreceiverespps -e 3gpp.slot
    Convert BIP To CSV By MCShark    local_file_path=${bip_local_file_path}
    ...                              output_file=${TEST_LOG_DIRECTORY}/bip/csv_${name}.csv
    ...                              filter=${filter}
    ...                              csv_title=${csv_title}
    ${filename} =    Set Variable    ${TEST_LOG_DIRECTORY}/bip/csv_${name}.csv
    ${value_column_list}=    Create List    3gpp.slot
    log to console    dldata_pdschsendreq
    ${dldata}=    Create List    dldata_pdschsendreq
    ${result_line}   ${result_value} =    Check Bip Log    file_path=${filename}
    ...                                          value_column_list=${value_column_list}
    ...                                          expected_list=${dldata}
    ${executed_value_list}=    Create List    0    1    2    3    5    6    7    8    10    11
    FOR    ${executed_value}    IN    @{executed_value_list}
        should contain    ${result_value}    ${executed_value}
    END
    log to console    uldata_puschreceiverespps
    ${uldata}=    Create List    uldata_puschreceiverespps
    ${result_line}   ${result_value} =    Check Bip Log    file_path=${filename}
    ...                                          value_column_list=${value_column_list}
    ...                                          expected_list=${uldata}
    ${executed_value_list}=    Create List    4    9    14    19
    FOR    ${executed_value}    IN    @{executed_value_list}
        should contain    ${result_value}    ${executed_value}
    END


Check TTI Log In vDU
    [Arguments]    ${name}=l1hi
    ${filter}=    Set Variable
    ...    3gpp.slot||dldata_pdschsendreq||uldata_puschreceiverespps
    ${csv_title}=    Set Variable    -e dldata_pdschsendreq -e uldata_puschreceiverespps -e 3gpp.slot
    Convert BIP To CSV By MCShark    local_file_path=${bip_local_file_path}
    ...                              output_file=${TEST_LOG_DIRECTORY}/bip/csv_${name}.csv
    ...                              filter=${filter}
    ...                              csv_title=${csv_title}
    ${filename} =    Set Variable    ${TEST_LOG_DIRECTORY}/bip/csv_${name}.csv
    ${value_column_list}=    Create List    3gpp.slot
    log to console    dldata_pdschsendreq
    ${dldata}=    Create List    dldata_pdschsendreq
    ${result_line}   ${result_value} =    Check Bip Log    file_path=${filename}
    ...                                          value_column_list=${value_column_list}
    ...                                          expected_list=${dldata}
    ${executed_value_list}=    Create List    0    1    2    3    5    6    7    8    10    11
    FOR    ${executed_value}    IN    @{executed_value_list}
        should contain    ${result_value}    ${executed_value}
    END
    log to console    uldata_puschreceiverespps
    ${uldata}=    Create List    uldata_puschreceiverespps
    ${result_line}   ${result_value} =    Check Bip Log    file_path=${filename}
    ...                                          value_column_list=${value_column_list}
    ...                                          expected_list=${uldata}
    ${executed_value_list}=    Create List    4    9    14    19
    FOR    ${executed_value}    IN    @{executed_value_list}
        should contain    ${result_value}    ${executed_value}
    END

Start Capture Log By Dcap
    [Arguments]    ${dcap_ip}    ${alias}=dcap    ${ne_type}=vdu   ${vdu_custom_profile}=${None}   ${vcu_custom_profile}=${None}
    ...            ${gnb_index}=0    ${vdu_index}=0
    Log To Console    ${gnb_index}
    Log To Console    ${vdu_index}
#    ${ssh_info}    Get Ssh Info    ne_type=${ne_type}   gnb_index=0    vdu_index=0
    ${webem_info}    Get WebEM Info    ne_type=${ne_type}   gnb_index=0    vdu_index=0
    Update DCAP Controller White List
    ...                     hostname=${ssh_info['hostname']}
    ...                     username=${ssh_info['username']}
    ...                     password=${ssh_info['password']}
    ...                     namespace=${ssh_info['namespace']}
    ...                     dcap_ip=${dcap_ip}    operation_type=add
    Connect To DCAP    host=${dcap_ip}     port=443    username=dcapuser
    ...                password=dcapadmin!    alias=${alias}
    Make Sure BTS Integrated In DCAP    ${webem_info}
    ${trace_id}    Run Keyword If   '''${vdu_custom_profile}'''!='''${None}''' and '''${vcu_custom_profile}'''=='''${None}'''
    ...         Start Trace In DCAP    ${webem_info}    vdu_custom_profile=${vdu_custom_profile}
    ...  ELSE IF  '''${vdu_custom_profile}'''=='''${None}''' and '''${vcu_custom_profile}'''!='''${None}'''
    ...         Start Trace In DCAP    ${webem_info}    vcu_custom_profile=${vcu_custom_profile}
    [Return]    ${trace_id}

Stop Trace Log By Dcap
    [Arguments]    ${ne_type}=vdu    ${gnb_index}=0    ${vdu_index}=0
    Log To Console    ${gnb_index}
    Log To Console    ${vdu_index}
    ${webem_info}    Get WebEM Info    ne_type=${ne_type}   gnb_index=0    vdu_index=0
    Stop Trace In DCAP    btsip=${webem_info['host']}

Save Trace Log By Dcap
    [Arguments]    ${ne_type}=vdu    ${gnb_index}=0    ${vdu_index}=0
    Log To Console    ${gnb_index}
    Log To Console    ${vdu_index}
    ${webem_info}    Get WebEM Info    ne_type=${ne_type}   gnb_index=0    vdu_index=0
    ${trace_file_path}    Download Trace File    btsip=${webem_info['host']}
    @{zip_file_path}    List Files In Directory    ${trace_file_path}    *.zip
    [Return]    ${zip_file_path}

Get WebEM Info
    [Arguments]    ${ne_type}=vdu   ${gnb_index}=0    ${vdu_index}=0
    ${oam_httpaddr}    Set Variable If    '${ne_type.upper()}'=='VDU'
    ...                 ${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.addr}
    ...                                   '${ne_type.upper()}'=='VCU'
    ...                 ${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}

    ${oam_web_ip}    set variable if    ':' in '''${oam_httpaddr}'''   [${oam_httpaddr}]    ${oam_httpaddr}
    &{webem_info}=    create dictionary    host=${oam_web_ip}    username=Nemuadmin    password=Nokia@123    port=443
    [return]    ${webem_info}

############################## parameter ##############################
Commission Full SCF For vDU
    [Arguments]    ${scf_path}=${CURDIR}/scf_CB007922_vdu.xml    ${vdu_index}=${0}
    vDU Update Full SCF By Rest    scf_path=${scf_path}
    ...                               vdu_index=${vdu_index}

Commission Full SCF For vCU
    [Arguments]    ${scf_path}=${CURDIR}/scf_CB007922_vcu.xml    ${plan_name}=Plan_scf_CB007922_vcu
    vCU Full Commssion By Rest    path_of_commission_file=${scf_path}
    ...                               plan_name=${plan_name}

Modify Parameters By Stage Plan In vDU
    ${mo_dn}   Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
    &{drxProfile1_delta_dict}   create dictionary     drxProfile1=${None}
    ...                                   drxProfile1/0/drxInactivityTimer=80ms
    ...                                   drxProfile1/1/drxLongCycle=160ms
    ...                                   drxProfile1/2/drxOnDurationTimer=10ms
    ...                                   drxProfile1/3/drxRetransTimerDl=0slot
    ...                                   drxProfile1/4/drxRetransTimerUl=0slot
    &{csi_delta_list}   create dictionary     periodicCsiAcquisition=${None}
    ...                                   periodicCsiAcquisition/0/drxInactivityTimer=40ms
    ...                                   drxProfile1/1/csiReportPeriodicity=slots160
	VDU Online Modify Staged Parameters By Rest    mo_dn=${mo_dn}
	...                                          updated_paras_dict=${drxProfile1_delta_dict}
    wait until keyword succeeds  600s  10s    vDU Check All Cells Status Should Be Onair For All DUs    gnb_index=${0}
    [Teardown]    Run Keyword And Ignore error    vDU Logout By Rest


Modify Parameters By Delta Plan
    [Arguments]   ${ne}=vDU    ${parameter}=actCDrx    ${value}=true
    ...           ${mo_dn}=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
    Run Keyword If    '${ne}'=='vDU'    Modify Parameters By Delta Plan In vDU    parameter=${parameter}
    ...                                                                           value=${value}
    ...                                                                           mo_dn=${mo_dn}
    ...            ELSE IF   '${ne}'=='vCU'    Modify Parameters By Delta Plan In vCU    parameter=${parameter}
    ...                                                                                  value=${value}
    ...                                                                                  mo_dn=${mo_dn}
    ...            ELSE IF   '${ne}'=='all'    Modify Parameters By Delta Plan In vCU And vDU    parameter=${parameter}
    ...                                                                                   value=${value}
    ...                                                                                   mo_dn=${mo_dn}

Modify Parameters By Delta Plan In vDU
    [Arguments]   ${parameter}=actCDrx    ${value}=true    ${mo_dn}=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
    &{parameter_dict}    Create Dictionary   ${parameter}=${value}
    &{parameter_dict1}    Judge Whether The Parameter Needs To Be Modified    mo_dn=${mo_dn}
    ...                                                                      mo_parameter_dict=&{parameter_dict}
    vDU Login By Rest
    Run Keyword If    &{parameter_dict1} != &{Empty}    VDU Online Modify Parameters By Delta Plan REST
    ...                                          mo_dn=${mo_dn}
    ...                                          updated_paras_list=${parameter_dict}
    ...                                          operation=replace
    ...                                          activate=${True}
    ...                                          force_reset=${False}
    ...                                          auto_lock_cells=${False}
    ...                                          wait_vdu_up=${False}
    vDU Logout By Rest
    [Teardown]    Run Keyword And Ignore error    vDU Logout By Rest

Modify Parameters By Delta Plan In vCU
    [Arguments]   ${parameter}=actCDrx    ${value}=true    ${mo_dn}=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
    &{vcu_param}    create dictionary    operation_type=replace    parameter_path=/${parameter}
    ...                                                                         value=${value}
    @{updated_vcu_param}    Create List    ${vcu_param}
    vCU Online modify Simple Parameters Via Rest With Compare    parameter_name=${parameter}
    ...                                                   updated_paras_dict=${updated_vcu_param}
    ...                                                   compare_value=${value}
    ...                                                   mo_dn=${mo_dn}

Modify Parameters By Delta Plan In vCU And vDU
    [Arguments]   ${parameter}=actCDrx    ${value}=true    ${mo_dn}=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
    &{vcu_param}    create dictionary    operation_type=replace    parameter_path=/${parameter}
    ...                                                                         value=${value}
    @{updated_vcu_param}    Create List    ${vcu_param}
    vCU Online modify Simple Parameters Via Rest With Compare    parameter_name=${parameter}
    ...                                                   updated_paras_dict=${updated_vcu_param}
    ...                                                   compare_value=${value}
    ...                                                   mo_dn=${mo_dn}
    &{parameter_dict}    Create Dictionary   ${parameter}=${value}
    &{parameter_dict1}    Judge Whether The Parameter Needs To Be Modified    mo_dn=${mo_dn}
    ...                                                                      mo_parameter_dict=&{parameter_dict}
    vDU Login By Rest
    Run Keyword If  &{parameter_dict1} != &{Empty}
    ...             VDU Online Modify Parameters By Delta Plan REST    mo_dn=${mo_dn}
	...                                          updated_paras_list=${parameter_dict}
	...                                          operation=replace
	...                                          activate=${True}
    ...                                          force_reset=${False}
    ...                                          auto_lock_cells=${False}
    ...                                          wait_vdu_up=${False}
    vDU Logout By Rest

Check Cell Is Deactived
    [Arguments]        ${expected_value}=0
    ${cell_number}    Get VDU Cell Number From SCF    vdu_index=${0}    gnb_index=${0}
    ${alias}=    get unique id
    vDU Login By Rest    vdu_index=${0}    gnb_index=${0}    alias=${alias}
    ${vdu_cells_summary}=    vdu.get_vdu_cells_summary    vdu_connection=${alias}
    ${disabled_number}    set variable    ${vdu_cells_summary['basic_cells_summary']['operational_state']['disabled']}
    should be equal     "${disabled_number}"    "${expected_value}"    Cell State is not expected

############################## Operate ##############################
Lock Cell From vDU
    [Arguments]    ${cell_id}=1
    ${cell_id_list}    Run Keyword If    '${cell_id}'=='all'    Get Cell ID List    vdu_index=0    gnb_index=0
    ...                ELSE    Create List    ${cell_id}
    Lock Cell In vDU    cell_id_list=${cell_id_list}

Unlock Cell From vDU
    [Arguments]    ${cell_id}=1
    ${cell_id_list}    Run Keyword If    '${cell_id}'=='all'    Get Cell ID List    vdu_index=0    gnb_index=0
    ...                ELSE    Create List    ${cell_id}
    Unlock Cell In vDU    cell_id_list=${cell_id_list}

Block Cell From vDU
    [Arguments]    ${cell_id}=all
    ${cell_id_list}    Run Keyword If    '${cell_id}'=='all'    Get Cell ID List    vdu_index=0    gnb_index=0
    ...                ELSE    Create List    ${cell_id}
    FOR    ${cell_index}    IN    @{cell_id_list}
        Block Cell In vDU    cell_id=${cell_index}
    END

Unblock Cell From vDU
    [Arguments]    ${cell_id}=all
    ${cell_id_list}    Run Keyword If    '${cell_id}'=='all'    Get Cell ID List    vdu_index=0    gnb_index=0
    ...                ELSE    Create List    ${cell_id}
    FOR    ${cell_index}    IN    @{cell_id_list}
        Unblock Cell In vDU    cell_id=${cell_index}
    END

Lock NG-C Links In vCU
    ${mo_dn}   Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/SERVEDAMF-1
    &{param}    create dictionary    operation_type=replace    parameter_path=/administrativeState
    ...                                                                         value=Locked
    @{updated_param}    Create List    ${param}
    vCU Online modify Simple Parameters Via Rest With Compare    parameter_name=administrativeState
    ...                                                   updated_paras_dict=${updated_param}
    ...                                                   compare_value=Locked
    ...                                                   mo_dn=${mo_dn}

Unlock NG-C Links In vCU
    ${mo_dn}   Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/SERVEDAMF-1
    &{param}    create dictionary    operation_type=replace    parameter_path=/administrativeState
    ...                                                                         value=Unlocked
    @{updated_param}    Create List    ${param}
    vCU Online modify Simple Parameters Via Rest With Compare    parameter_name=administrativeState
    ...                                                   updated_paras_dict=${updated_param}
    ...                                                   compare_value=Unlocked
    ...                                                   mo_dn=${mo_dn}
    wait until keyword succeeds    10min    20s    Check All Cells On Air In vCU

Lock X2 Links In vCU
    ${mo_dn}   Set Variable    MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-1/LNRELGNBCELL-0
    &{param}    create dictionary    operation_type=replace    parameter_path=/administrativeState
    ...                                                                         value=Locked
    @{updated_param}    Create List    ${param}
    vCU Online modify Simple Parameters Via Rest With Compare    parameter_name=administrativeState
    ...                                                   updated_paras_dict=${updated_param}
    ...                                                   compare_value=Locked
    ...                                                   mo_dn=${mo_dn}

Unlock X2 Links In vCU
    ${mo_dn}   Set Variable    MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-1/LNRELGNBCELL-0
    &{param}    create dictionary    operation_type=replace    parameter_path=/administrativeState
    ...                                                                         value=Unlocked
    @{updated_param}    Create List    ${param}
    vCU Online modify Simple Parameters Via Rest With Compare    parameter_name=administrativeState
    ...                                                   updated_paras_dict=${updated_param}
    ...                                                   compare_value=Unlocked
    ...                                                   mo_dn=${mo_dn}
    wait until keyword succeeds    10min    20s    Check All Cells On Air In vCU


Lock NG Link
    ${ng_links_list}    Create List    1    2    3
    Lock NG Links In vCU     ng_links_list=${ng_links_list}    gnb_index=0
    ...                      parameter_name=administrativeState
    ...                      mo_dn=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/SERVEDAMF-1
    ...                      expected_value=Locked

Unlock NG Link
    ${ng_links_list}    Create List    1    2    3
    Unlock NG Links In vCU     ng_links_list=${ng_links_list}    gnb_index=0
    ...                      parameter_name=administrativeState
    ...                      mo_dn=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/SERVEDAMF-1
    ...                      expected_value=Unlocked


Lock All NG-C Links
    ${mo_dn}   Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/SERVEDAMF-1
    ${mo_dn1}   Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/SERVEDAMF-2
    ${mo_dn2}   Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/SERVEDAMF-3
    &{param}    create dictionary    operation_type=replace    parameter_path=/administrativeState
    ...                                                                         value=Locked
    @{updated_param}    Create List    ${param}
    vCU Online modify Simple Parameters Via Rest With Compare    parameter_name=administrativeState
    ...                                                   updated_paras_dict=${updated_param}
    ...                                                   compare_value=Locked
    ...                                                   mo_dn=${mo_dn}
    vCU Online modify Simple Parameters Via Rest With Compare    parameter_name=administrativeState
    ...                                                   updated_paras_dict=${updated_param}
    ...                                                   compare_value=Locked
    ...                                                   mo_dn=${mo_dn1}
    vCU Online modify Simple Parameters Via Rest With Compare    parameter_name=administrativeState
    ...                                                   updated_paras_dict=${updated_param}
    ...                                                   compare_value=Locked
    ...                                                   mo_dn=${mo_dn2}
    sleep    60s    reason=wait generate counter

Unlock All NG-C Links
    ${mo_dn}   Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/SERVEDAMF-1
    ${mo_dn1}   Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/SERVEDAMF-2
    ${mo_dn2}   Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/SERVEDAMF-3
    &{param}    create dictionary    operation_type=replace    parameter_path=/administrativeState
    ...                                                                         value=Unlocked
    @{updated_param}    Create List    ${param}
    vCU Online modify Simple Parameters Via Rest With Compare    parameter_name=administrativeState
    ...                                                   updated_paras_dict=${updated_param}
    ...                                                   compare_value=Unlocked
    ...                                                   mo_dn=${mo_dn}
    vCU Online modify Simple Parameters Via Rest With Compare    parameter_name=administrativeState
    ...                                                   updated_paras_dict=${updated_param}
    ...                                                   compare_value=Unlocked
    ...                                                   mo_dn=${mo_dn1}
    vCU Online modify Simple Parameters Via Rest With Compare    parameter_name=administrativeState
    ...                                                   updated_paras_dict=${updated_param}
    ...                                                   compare_value=Unlocked
    ...                                                   mo_dn=${mo_dn2}
    wait until keyword succeeds    10min    20s    Check All Cells On Air In vCU


Delete Mo In vCU
    [Arguments]    ${gnb_index}=${0}    ${mo_dn}=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/SERVEDAMF-3
    Log To Console    ${gnb_index}
    Log To Console    ${mo_dn}
    vCU Online Delete MO Via Rest    mo_dn=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/SERVEDAMF-3    gnb_index=${0}

Create Mo In vCU
    ${mo_dn}   Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/SERVEDAMF-3
    &{param}    create dictionary    operation_type=replace    parameter_path=/amfIPAddress
    ...                                                                         value=10.110.90.68
    @{updated_param}    Create List    ${param}
    vCU Online Create MO With Modify Parameter Via Rest    para_list=${updated_param}
    ...                                                    name=com.nokia.srbts.nrbts:SERVEDAMF
    ...                                                    instance_id=${3}
    ...                                                    create_mo_dn=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}
    ...                                                    gnb_index=${0}
    ...                                                    mo_dn=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/SERVEDAMF-3


Lock Xn Link In vCU
    [Arguments]    ${mo_dn}=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRADJGNB-1
    &{param}    create dictionary    operation_type=replace    parameter_path=/administrativeState
    ...                                                                         value=Locked
    @{updated_param}    Create List    ${param}
    vCU Online modify Simple Parameters Via Rest With Compare    parameter_name=administrativeState
    ...                                                   updated_paras_dict=${updated_param}
    ...                                                   compare_value=Locked
    ...                                                   mo_dn=${mo_dn}

Unlock Xn Link In vCU
    ${mo_dn}   Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRADJGNB-1
    &{param}    create dictionary    operation_type=replace    parameter_path=/administrativeState
    ...                                                                         value=Unlocked
    @{updated_param}    Create List    ${param}
    vCU Online modify Simple Parameters Via Rest With Compare    parameter_name=administrativeState
    ...                                                   updated_paras_dict=${updated_param}
    ...                                                   compare_value=Unlocked
    ...                                                   mo_dn=${mo_dn}

Lock RU In vDU
    @{rmod_id_list}    Create List    ${1}
    Lock RU And Check Status In vDU    rmod_id_list=@{rmod_id_list}

Unlock RU In vDU
    @{rmod_id_list}    Create List    ${1}
    Unlock RU And Check Status In vDU    rmod_id_list=@{rmod_id_list}

Lock vDU
    ${du_id_list}=    Create List    1
    Lock vDU In vCU    du_id_list=${du_id_list}    gnb_index=0
    Get vDU Status In vCU    expected_dn=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRDU-1   compare_value=Locked

Unlock vDU
    ${du_id_list}=    Create List    1
    Unlock vDU In vCU    du_id_list=${du_id_list}    gnb_index=0
    Get vDU Status In vCU    compare_value=Unlocked

Remove Xn Neighbor
    ${mo_dn}   Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRADJGNB-2
    ${name}   Set Variable    NRADJGNB-2
    Login To vCU By Rest    gnb_index=${0}
    get_current_plan_tree_diff
    &{current_plan_tree}    cu.get_current_plan_tree_diff
    @{plan_tree}=    set variable    ${current_plan_tree["created"]}
    FOR    ${mo_info}    IN    @{plan_tree}
       run keyword if    '${mo_info["name"]}'=='${name}'    run keywords    set test variable    ${result}    true
       ...                                                  AND    exit for loop
    END
    Run Keyword If    '${result}'== 'true'    vCU Online Delete MO Via Rest    mo_dn=${mo_dn}
    ...                                                                        gnb_index=${0}
    [Teardown]   Run keyword and ignore error    Logout To vCU By Rest


Recover Xn Neighbor
    ${mo_dn}   Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRADJGNB-2
    &{param1}    create dictionary    operation_type=replace    parameter_path=/administrativeState
    ...                                                                         value=Unlocked
    &{param2}    create dictionary    operation_type=replace    parameter_path=/gNbIdLength
    ...                                                                         value=22
    &{param3}    create dictionary    operation_type=replace    parameter_path=/gNodeBId
    ...                                                                         value=11078
    &{param4}    create dictionary    operation_type=replace    parameter_path=/gnbPlmn/mcc
    ...                                                                         value=262
    &{param5}    create dictionary    operation_type=replace    parameter_path=/gnbPlmn/mnc
    ...                                                                         value=3
    &{param6}    create dictionary    operation_type=replace    parameter_path=/gnbPlmn/mncLength
    ...                                                                         value=2
    @{updated_param}    Create List    ${param1}    ${param2}    ${param3}    ${param4}    ${param5}    ${param6}
    vCU Online Create MO With Modify Parameter Via Rest    para_list=${updated_param}
    ...                                                    name=com.nokia.srbts.nrbts:NRADJGNB
    ...                                                    instance_id=${2}
    ...                                                    gnb_index=${0}
    ...                                                    mo_dn=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRADJGNB-2


############################## CMAS ##############################
Trigger CMAS Notification
    Log to console    trigger cmas
    CMAS Notification    amf=${amf2-amfsui1}
    ...                          message_identifier=4372    serial_number=51
    ...                          repetition_period=5
    ...                          number_of_broadcasts_requested=${10}
    ...                          connection=${cbctest_alias}
	...                          nr_of_bits_g_node_b_id=22
    ...                          cell_id=1
    ...                          test_amf_name=test_amf_RRM3.py

Trigger PWS Cancel
    CMAS PWS Cancel        amf=&{amf2-amfsui1}
    ...                    nr_of_bits_g_node_b_id=32
    ...                    cell_id=1
    ...                    connection=${cbctest_alias}
