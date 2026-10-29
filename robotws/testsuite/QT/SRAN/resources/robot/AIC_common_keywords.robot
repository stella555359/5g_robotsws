*** Settings ***
Documentation  Common resource for Cloud testing

Library             OperatingSystem
Library             Collections
Library             Telnet
Library             String
Library             taf.config.scf    WITH NAME    cscf
Library             taf.transport.ssh.interface.ssh            WITH NAME    ssh
Library             taf.gnb.oam.commissioning  WITH NAME  commissioning
Library             taf.sbts.oam.coam.admin    WITH NAME    coam
Library             taf.gnb.oam.coam.cu    WITH NAME    coam_cu
Library             taf.selenium.gnb.oam.coam.vdu    WITH NAME    selenium_vdu
Library             taf.selenium.gnb.oam.coam.cu   WITH NAME    selenium_cu
Library             taf.config.testline.info.testline_info.TestlineInfo    WITH NAME    ti
Library             taf.ul.vdu.helm.interface.helm   WITH NAME    helm
Library             taf.gnb.oam.coam.vdu.interface.Vdu    WITH NAME    vdu
Library             taf.vran.vdu.enb.rest.interface.LTEvDU    WITH NAME    lte_vdu
Library             ${CURDIR}/../python/common.py
Library             ${CURDIR}/../python/cloud_keywords.py
Resource            ${CURDIR}/../robot/loki_driver.robot
Resource            ${CURDIR}/../robot/log_collector.robot
Resource            ${CURDIR}/../robot/connections.robot
Resource            ${CURDIR}/../robot/loki_driver.robot
Resource            ${CURDIR}/../robot/NOP.robot
Resource            ${CURDIR}/../robot/FHGW.robot

*** Variables ***
&{e1_link_dict}    e1CLinkStatusCuCp=available    e1CLinkStatusCuUp=available
&{x2_link_dict}    x2linkstatus=available
&{ng_link_dict}    nglinkstatus=Active

*** Keywords ***
Create AIC log directories
    Create Directory    ${LOG_PATH}
    helm.helm_master_connect   ${${par_prefix}_k8s_addr}   ${${par_prefix}_k8s_port}   ${${par_prefix}_k8s_user}
    ...    ${${par_prefix}_k8s_pwd}
    ${output}=    helm.execute_command_on_master_cluster    test -d ${pkg_path}
    run keyword if    '${output.status}'=='1'    helm.execute_command_on_master_cluster    mkdir ${pkg_path}

AIC Test suite setup
    [Documentation]    Do some common thing for every postcondition of cases
    Common variables setup
    QT Setup
    Get test timestamp
    Set AiC Suite Variables
    Check FHGW_Ethernet
    Get controller host name
    Generate sshkey for VM
    Run Keyword And Ignore Error    Cleanup coredump log in vDU
    Create AIC log directories
    Run Keyword And Ignore Error    Check And Recover kubelet service
    Wait until keyword succeeds    5min   30s    OE Authentication  par_prefix=${par_prefix}
    Get Alarms Before Cloud Test
    [Teardown]  Run Keyword And Ignore Error   ssh.disconnect   connection=RM_alias

Check And Recover kubelet service
    [Documentation]  If kubelet service cannot be connected then restart kubelet serivice will be performed.
    FOR   ${CU_DU}   IN    CU  DU
        ssh.Connect to   hostname=${${CU_DU}_k8s_addr}   username=${${CU_DU}_k8s_user}   password=${${CU_DU}_k8s_pwd}  alias=RM_alias
        ${result}=  kubectl_get_pods
        ...   namespace=${${CU_DU}_tenant}
        ...   conn=RM_alias
        ${re_str}=   Get Regexp Matches   ${result}   The connection.*was refused
        ${bool_res}=  Run Keyword And Return Status   Should Not Be Empty  ${re_str}
        Run Keyword If   ${bool_res}    ssh.execute
        ...   command=sudo systemctl restart kubelet   connection=RM_alias  timeout=60s
    END

Common variables setup
    [Documentation]  set common variables before test
    ${CU_exists}    Run Keyword And Return Status    Variable Should Exist
    ...    ${tl.gnbs[0].cu.oam_http_connection_details.addr}
    ${is_LTE}    Set Variable If    ${CU_exists}    False    True
    Set Suite Variable    ${is_LTE}
    ${5g_or_lte}    Set Variable If    ${is_LTE}    enb    gnb
    Set Suite Variable    ${5g_or_lte}
    ${du_or_dus}    Set Variable If    ${is_LTE}    du    dus[0]
    Set Suite Variable    ${du_or_dus}
    Set Suite Variable    ${DU_WEBUI_IP}   ${tl.${5g_or_lte}s[0].${du_or_dus}.oam_http_connection_details.addr}
    Set Suite Variable    ${DU_k8s_addr}
    ...    ${tl.${5g_or_lte}s[0].${du_or_dus}.cloud_deployment.cloud_hosting.master_node.k8s_connection_details.ip_addr}
    Set Suite Variable    ${DU_k8s_user}
    ...    ${tl.${5g_or_lte}s[0].${du_or_dus}.cloud_deployment.cloud_hosting.master_node.k8s_connection_details.username}
    Set Suite Variable    ${DU_k8s_pwd}
    ...    ${tl.${5g_or_lte}s[0].${du_or_dus}.cloud_deployment.cloud_hosting.master_node.k8s_connection_details.password}
    Set Suite Variable    ${DU_k8s_port}
    ...    ${tl.${5g_or_lte}s[0].${du_or_dus}.cloud_deployment.cloud_hosting.master_node.k8s_connection_details.port}
    IF    not ${is_LTE}
        Set Suite Variable    ${CU_k8s_addr}   ${tl.gnbs[0].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.ip_addr}
        Set Suite Variable    ${CU_WEBUI_IP}   ${tl.gnbs[0].cu.oam_http_connection_details.addr}
        Set Suite Variable    ${CU_k8s_port}   ${tl.gnbs[0].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.port}
        Set Suite Variable    ${CU_k8s_user}   ${tl.gnbs[0].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.username}
        Set Suite Variable    ${CU_k8s_pwd}   ${tl.gnbs[0].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.password}
        Set Suite Variable    ${CU_tenant}        ${tl.gnbs[0].cloud_deployment.cloud_hosting.namespace}
        Set Suite Variable    ${CU_pvcname}       ${tl.gnbs[0].cloud_deployment.networks[0].name}
        Set Suite Variable    ${CU_cnfname}      ${tl.gnbs[0].cloud_deployment.vnfs[0].name}
        ${CU_ACM_based_installation}    is_ocp_version_higher_than_4_18
        ...    hostname=${CU_k8s_addr}
        ...    username=${CU_k8s_user}
        ...    password=${CU_k8s_pwd}
        Set Suite Variable    ${CU_ACM_based_installation}
    END
    ${FHGW_Exist}    Run Keyword And Return Status    Variable Should Exist    ${tl.${5g_or_lte}s[0].${du_or_dus}.fhgws[0]}
    ${RANNIC_Exist}    Run Keyword And Return Status    Variable Should Exist    ${tl.${5g_or_lte}s[0].${du_or_dus}.rannics[0]}
    Set Suite Variable    ${FHGW_Exist}
    Set Suite Variable    ${RANNIC_Exist}
    Run Keyword If        ${FHGW_Exist}    Run Keywords    Set Suite Variable    ${FHGW_IP}    ${tl.${5g_or_lte}s[0].${du_or_dus}.fhgws[0].ip}
    ...    AND    Set Suite Variable    ${FHGW_USERNAME}   ${tl.${5g_or_lte}s[0].${du_or_dus}.fhgws[0].username}
    ...    AND    Set Suite Variable    ${FHGW_PASSWORD}   ${tl.${5g_or_lte}s[0].${du_or_dus}.fhgws[0].password}
    ...    AND    Set Suite Variable    ${FHGW_Ethernet_Ports}   ${tl.${5g_or_lte}s[0].${du_or_dus}.fhgws[0].Ethernet_Ports}
    Run Keyword If    ${RANNIC_Exist}   Run Keywords    Set Suite Variable
    ...    ${RU_USERNAME}     ${tl.${5g_or_lte}s[0].${du_or_dus}.rannics[0].rus[0].default_ssh_connection_details.username}
    ...    AND    Set Suite Variable
    ...    ${RU_PASSWORD}    ${tl.${5g_or_lte}s[0].${du_or_dus}.rannics[0].rus[0].default_ssh_connection_details.password}
    Set Suite Variable    ${DU_tenant}        ${tl.${5g_or_lte}s[0].${du_or_dus}.cloud_deployment.cloud_hosting.namespace}
    Set Suite Variable    ${DU_cnfname}     ${tl.${5g_or_lte}s[0].${du_or_dus}.cloud_deployment.vnfs[0].name}
    Set Suite Variable    ${DU_pvcname}      ${tl.${5g_or_lte}s[0].${du_or_dus}.cloud_deployment.networks[0].name}
    ${gnss_sync_in_rinline2}    Get Variable Value    ${tl.custom['gnss_sync_in_rinline2']}    ${False}
    Set Suite Variable    ${gnss_sync_in_rinline2}
    ${DU_ACM_based_installation}    is_ocp_version_higher_than_4_18
    ...    hostname=${DU_k8s_addr}
    ...    username=${DU_k8s_user}
    ...    password=${DU_k8s_pwd}
    Set Suite Variable    ${DU_ACM_based_installation}

Get controller host name
    [Documentation]    Get controller host name
    ...    KW as side effect propagating CONTROLLER_HOSTNAME variable
    [Arguments]  ${addr}=${${par_prefix}_k8s_addr}  ${username}=${${par_prefix}_k8s_user}  ${password}=${${par_prefix}_k8s_pwd}
    ${conn}=     helm.helm_master_connect
    ...   ${addr}
    ...  22
    ...  ${username}
    ...  ${password}
    ${output}=    helm.execute_command_on_master_cluster    hostname
    Set Suite Variable    ${CONTROLLER_HOSTNAME}     ${output.stdout.strip()}
    helm.helm_master_close    ${conn}

AiC Test suite Teardown
    [Documentation]  Do some common things for every postcondition of cases
    [Timeout]    20 min
    ${skip_log_collection}    ${l3call_status}    ${vcu_web_con}    ${vdu_web_con}    ${dptrace_started}    ${FHGW_SNAPSHOT}
    ...    ${cloud_syslog_path}    Get Teardown variables
    Log    --> Log Active Alarms for CU and DU if web connection created
    IF    ${vcu_web_con}
        Log Active Alarms Cloud   CUorDU=CU
    END
    IF    ${vdu_web_con}
        ${vdu_active_alarms}    Log Active Alarms Cloud   CUorDU=DU    setup_connection=${False}
    ELSE
        ${vdu_active_alarms}    Set Variable    ${EMPTY}
    END
    Log   --> Get healingctl log if it is not gate test
    IF    not ${is_gate}
        TRY
            Get Healingctl Log
        EXCEPT  AS  ${error}
            Log  --> Get Healingctl Log failed due to ${error}    WARN
        END
    END
    Log    --> Stop l2rt dptrace if it is started
    IF    ${dptrace_started}
        TRY
            Stop l2rt dptrace
        EXCEPT  AS  ${error}
            Log  --> Stop l2rt dptrace failed due to ${error}    WARN
        END
    END
    Log   --> Get syslog and snapshot if not skip_log_collection
    IF    not ${skip_log_collection}
        ${snapshot_before_teardown_status}=    get test case status by name    Snapshot Collection
        ${additional_case_status}  Get Variable Value   ${additional_case_status}  True
        ${tc_bool}  Evaluate   "${snapshot_before_teardown_status}"=="PASS" and "${additional_case_status}"=="True" and "${l3call_status}"=="NA"
        Run Keyword If  ${vcu_web_con} and ${vCU_build_flag} and not ${tc_bool}
        ...    Save Cloud Snapshot    vCUorvDU=vCU
        Run Keyword If  ${vdu_web_con} and ${vDU_build_flag} and not ${tc_bool}
        ...    Save Cloud Snapshot    vCUorvDU=vDU
        ${snapshot_path}     Get Variable Value    ${${par_prefix}_snapshot_path}    ${Empty}
        Run Keyword If Any Tests Failed        Run Keyword If    '${snapshot_path}'!=''
        ...   Check Error in Snapshot    snapshot_path=${snapshot_path}
        Run Keyword If    ${FHGW_SNAPSHOT}
        ...    Collecting FHGW Snapshot
        Run Keyword and continue on failure    Run Keywords    Get ocp logservice     ${cloud_syslog_path}
        ...    AND    Run Keyword and continue on failure    Additonal Check in OCP sys Logs     cloud_syslog_path=${cloud_syslog_path}
        Run Keyword If Any Tests Failed        Run Keyword If    ${vcu_web_con} and ${vDU_build_flag}
        ...    Run Keyword And Ignore Error    Save Cloud Snapshot    vCUorvDU=vCU
        Run Keyword If Any Tests Failed        Run Keyword If    ${vdu_web_con} and ${vCU_build_flag}
        ...    Run Keyword And Ignore Error    Save Cloud Snapshot    vCUorvDU=vDU
    END
    Log   --> Get ${par_prefix} SCF file
    TRY
        Run Keyword if   ${${pre_flag}_web_con}  Get Cloud SCF File
    EXCEPT  AS  ${error}
        Log To Console  --> !!!Warning!!! SCF collection failed due to ${error}
    END
    Log    --> DU recovery if there are F1 setup related active alarms on vDU
    IF    ${{len($vdu_active_alarms)}}>0
        IF    ${vdu_active_alarms['total']} > 0 and ${vCU_build_flag}
            Run Keyword And Ignore Error   DU Recovery For F1 Setup Issue In CU test     ${vdu_active_alarms}
        END
    END
    IF    ${vdu_tcpdump_started} and ${vDU_build_flag}
        Stop vDU Tcpdump Collection
    END
    Move Logs To Additional Execution Logs
    [Teardown]    Run Keywords
    ...    Run Keyword and ignore error    coam_cu.disconnect
    ...    AND  Run Keyword and ignore error    vdu.disconnect   vdu_connection=du_admin
    ...    AND  Cloud Env Health Stop And Fix Check
    ...    AND  L3Call Stop And Fix Check

Get Teardown variables
    [Documentation]    Get all the variables needed for teardown
    ${skip_log_collection}    Get Variable Value    ${skip_log_collection}    False
    ${l3call_5G_status}=    get test case status by name    L3 Call 5G
    ${l3call_4G_status}=    get test case status by name    L3 Call 4G
    IF    '${l3call_5G_status}' != 'NA'
        ${l3call_status}    Set Variable    ${l3call_5G_status}
    ELSE
        ${l3call_status}    Set Variable    ${l3call_4G_status}
    END
    ${vdu_web_con}    Set Variable    ${False}
    ${vcu_web_con}    Set Variable    ${False}
    IF    not ${is_gate} or '${l3call_status}'!='NA'
        ${vdu_web_con}    Run keyword and return status   Connect To vDU
        ...    host_ip=${DU_WEBUI_IP}    connection_name=DU_admin    loop_check=${4}
        IF    not ${is_LTE}
            ${vcu_web_con}    Run keyword and return status    Connect To vCU
            ...    host_ip=${CU_WEBUI_IP}    loop_check=${4}
        END
    END
    ${dptrace_started}    Get variable value    ${dptrace_started}    ${False}
    ${FHGW_SNAPSHOT}    Get Variable Value    ${FHGW_SNAPSHOT}    False
    ${cloud_syslog_path}    Get Variable Value    ${cloud_syslog_path}    ${None}
    RETURN    ${skip_log_collection}    ${l3call_status}    ${vcu_web_con}    ${vdu_web_con}
    ...       ${dptrace_started}    ${FHGW_SNAPSHOT}    ${cloud_syslog_path}

Get Cloud SCF File
    Connect To vDU   host_ip=${${par_prefix}_WEBUI_IP}    connection_name=${EMPTY}    loop_check=${4}
    Log To Console  --> Collecting SCF file [...]
    TRY
        ${get_current_plan}=  Run Keyword And Return Status  vdu.get_current_plan_file   local_dir_path=${OUTPUT_DIR}/
        ...  filename=scf_from_webui_${tl.tl_cloud_topology}.xml    timeout=120s
        IF    ${get_current_plan}
            Log To Console  --> SCF Collection [DONE]
        ELSE
            ${scf_file}    RUN    sudo find /tmp -name 'tmp_SCF_${node_name_short}_${cellConfiguration}*.xml'
            IF    len($scf_file)!=0
                RUN     cp ${scf_file} ${OUTPUT_DIR}/${scf_file.split('/')[-1]}
                Log To Console  --> SCF Collection [DONE]
            ELSE
                Log To Console  --> !!!Warning!!! SCF Collection Failed from web and no SCF found in /tmp  WARN
            END
        END
    EXCEPT    AS    ${error}
        Log To Console  --> !!!Warning!!! SCF Collection Failed due to ${error}  WARN
    END
    [Teardown]    vdu.disconnect

Cancel Snapshot Operation If Snapshot Status is Not idle
    [Documentation]    Cancel snapshot operation if snapshot status is not idle.
    ...                Keyword return True if snapshot status is idle and False if cancel snapshot operation fails
    [Arguments]    ${CUorDU}    ${use_m2m}    ${connection}
    TRY
        FOR    ${_}    IN RANGE    0    6
            ${get_snapshot_status}
            ...    vdu.check_snapshot_status    use_m2m=${use_m2m.capitalize()}    vdu_connection=${connection}
            IF    '${get_snapshot_status}'!='idle'
                IF    '${use_m2m}' == 'false'
                    ${console_log}    Catenate    ${CUorDU} snapshot collection status is ${get_snapshot_status}
                    ...    and there is no way to cancel it with m2m interface disabled
                    Log    ${console_log}    WARN
                    BREAK
                ELSE
                    ${snapshot_info}    vdu.get_snapshot_operations_information    vdu_connection=${connection}
                    IF    $snapshot_info is not None
                        vdu.cancel_snapshot_operation
                        ...   operation_id=${snapshot_info[0]['operation_id']}    vdu_connection=${connection}
                        BuiltIn.Sleep    10s
                    ELSE
                        ${console_log}    Catenate    ${CUorDU} snapshot collection status is ${get_snapshot_status}
                        ...    and due to get snapshot operations information failure snapshot operation cancellation
                        ...    cannot be performed
                        Log    ${console_log}    WARN
                        BREAK
                    END
                END
            ELSE
                RETURN     ${True}
            END
        END
    EXCEPT  AS  ${error}
        Log To Console  --> !!!Warning!!! snapshot cancellation failed due to ${error}
    END
    RETURN     ${False}

Save Cloud Snapshot
    [Documentation]  fetch cloud snapshot from admin
    [Arguments]     ${vCUorvDU}    ${compressed_or_not}=${False}    ${name}=${empty}
    [Timeout]    18 min
    ${CUorDU}=    Get Substring    ${vCUorvDU}   1
    Log to console    --> Collecting ${CUorDU} snapshot [...]
    ${use_m2m}    Get actcli Info    ${CUorDU}
    Connect To vDU
    ...    host_ip=${${CUorDU}_WEBUI_IP}
    ...    connection_name=snapshot_${vCUorvDU}
    ${snapshot_staus_idle}    Cancel Snapshot Operation If Snapshot Status is Not idle
    ...    vCUorvDU=${vCUorvDU}    use_m2m=${use_m2m}    connection=snapshot_${vCUorvDU}
    IF    ${snapshot_staus_idle}
        TRY
            IF    not ${compressed_or_not}
                ${snapshot_directory}    Set Variable    ${OUTPUT_DIR}/snapshot_${CUorDU}_${timestamp}
                ${snapshot_name}    Set Variable    ${sw_version}_${tl.tl_cloud_topology}_Snapshot_${CUorDU}_${name}${timestamp}.zip
                Run    mkdir ${snapshot_directory}
            ELSE
                ${snapshot_directory}    Set Variable    ${OUTPUT_DIR}
            END
            ${snapshot_path}    vdu.get_local_snapshot   directory=${snapshot_directory}
            ...                                          use_m2m=${use_m2m.capitalize()}
            ...                                          operation_timeout=720
            ...                                          vdu_connection=snapshot_${vCUorvDU}
            ...                                          compressed_or_not=${compressed_or_not}
            ${snapshot_path}    Get Variable Value    ${snapshot_path}    None
            IF    '${snapshot_path}' != 'None'
                IF    ${compressed_or_not}
                    ${snapshot_name}    Set Variable    ${snapshot_path.split('/')[-1]}
                    Run   mv ${OUTPUT_DIR}/${snapshot_name} ${OUTPUT_DIR}/${sw_version}_${tl.tl_cloud_topology}_${vCUorvDU}_${name}_${snapshot_name}
                    Set Suite Variable
                    ...    ${${CUorDU}_snapshot_path}    ${OUTPUT_DIR}/${sw_version}_${tl.tl_cloud_topology}_${vCUorvDU}_${name}_${snapshot_name}
                ELSE
                    Run    cd ${OUTPUT_DIR}; zip -r ${snapshot_name} snapshot_${CUorDU}_${timestamp}
                    Run    rm -rf ${OUTPUT_DIR}/snapshot_${CUorDU}_${timestamp}
                    Set Suite Variable    ${${CUorDU}_snapshot_path}    ${OUTPUT_DIR}/${snapshot_name}
                END
                ${snapshot_res}=    Set Variable    ${True}
            ELSE
                ${snapshot_res}=    Set Variable    ${False}
            END
        EXCEPT    AS    ${error}
            Log     Collecting ${CUorDU} snapshot failed due to ${error}     WARN
            ${ignore_error}    Get Regexp Matches    ${error}    Operation timeout exceeded|KeyError.*content-type
            IF    ${ignore_error}
                RETURN    #Do not fail snapshot check TC if Operation timeout exceeded or content-type keyerror
            ELSE
                ${snapshot_res}=    Set Variable    ${False}
            END
        END
    ELSE
        ${snapshot_res}=    Set Variable    ${False}
    END
    Run Keyword If     ${snapshot_res} and '${use_m2m}'=='true'    Log to console    --> Collecting ${CUorDU} snapshot [DONE]
    ...    ELSE IF     ${snapshot_res}                   Log to console    --> Collecting ${CUorDU} snapshot with use_m2m=False [DONE]
    ...    ELSE        Run Keywords                      Log to console    --> Collecting ${CUorDU} snapshot Failed   WARN
    ...    AND                                           Fail    ${CUorDU} snapshot collection FAILED!!!
    [Teardown]   Run Keyword And Ignore Error   vdu.disconnect    vdu_connection=snapshot_${vCUorvDU}

Get actcli Info
    [Arguments]    ${CUorDU}
    Connect To vCU
    ...    host_ip=${${CUorDU}_WEBUI_IP}
    ...    alias=snapshot_${CUorDU}
    ...    loop_check=${10}
    TRY
        &{parameter_info}=    coam_cu.search_parameters_of_current_plan    actcli    connection=snapshot_${CUorDU}
        ${use_m2m}=    Set Variable    ${parameter_info['items'][0]['parameter']['simple_parameter']['value']}
    EXCEPT    AS    ${error}
        Log     Get actcli from current plan failed due to ${error}
        ${use_m2m}=    Set Variable    false
    END
    RETURN    ${use_m2m}
    [Teardown]    coam_cu.disconnect    connection=snapshot_${CUorDU}

DU Recovery For F1 Setup Issue In CU test
    [Documentation]  Add this WA to avoid F1 setup failure in CU testing.
    ...              DU reset will be triggered for FID 4540:5G cell update failure
    ...              and FID 7523: Cell Activation timeout at gNB-DU
    [Arguments]  ${active_alarms}
    FOR    ${alarm}    IN    @{active_alarms['alarms']}
        Run keyword if   "${alarm["fault_id"]}"=="7523" or "${alarm["fault_id"]}"=="4540"   Run Keywords
        ...   Log To Console  --> DU is not healthy and it will be rebooted for recovery
        ...   AND   Connect To vDU  host_ip=${DU_WEBUI_IP}    connection_name=du_admin    loop_check=${4}
    END
    Run Keyword and ignore error  vdu.reset_vdu   vdu_connection=du_admin
    [Teardown]    Run Keyword and ignore error    vdu.disconnect    vdu_connection=du_admin

Set containers Variable
    [Documentation]  set contsiners and APPs variables
    ssh.Connect to   hostname=${${par_prefix}_k8s_addr}   username=${${par_prefix}_k8s_user}
    ...    password=${${par_prefix}_k8s_pwd}  alias=RM_alias
    @{pod_containers_list}=  get_pod_containers  namespace=${${par_prefix}_tenant}  conn=RM_alias

Enable vCU C-Plane debug log
    [Documentation]  online open c-plane debug log
    ssh.Connect to   hostname=${CU_k8s_addr}   username=${CU_k8s_user}
    ...    password=${CU_k8s_pwd}  alias=RM_alias
    Get pod name   namespace=${cu_tenant}
    Set vCU cplane container variables
    FOR  ${cm}  IN  @{pod_list}
        ${container_key}=   set variable    ${${cm}_pod}
        Online Open Debug log   cm=${cm}   list=${container['${container_key}']}
        ...    tenant=${CU_tenant}
    END

Online Open Debug log
    [Documentation]  enable cplane debug log
    [Arguments]  ${cm}    ${list}   ${tenant}
    ${container_prefix}    Set Variable If    '${tenant}' in '${${cm}_pod}'
    ...    ctr-${tenant}    ctr
    FOR   ${cont}   IN   @{list}
        ssh.Connect to   hostname=${CU_k8s_addr}   username=${CU_k8s_user}
        ...    password=${CU_k8s_pwd}  alias=RM_alias
        ${cont_split1}=   Get Substring   ${cont}  0    2
        ${cont_split2}=   Get Substring   ${cont}  2    10
        ${cont_name}    Catenate   SEPARATOR=_    ${cont_split1}    ${cont_split2}
        ${control_cont}   set variable if   '${cont}' == 'cpcl'   cpcell   ${cont}
        ${connection}=   ssh.get_connection_by_alias   alias=RM_alias
        ${channel}    Call Method    ${connection}    invoke_shell
        Call Method
        ...    ${channel}    send    kubectl -ti exec -n ${${par_prefix}_tenant} ${${cm}_pod} -c ${container_prefix}-${cont} -- /bin/bash\n
        BuiltIn.Sleep   1s
        Call Method    ${channel}    recv    ${65535}
        Call Method    ${channel}    send   grep Control /opt/nokia/SS_CPLANE/etc/${cont_name}.enb_conf.ini | grep -i ${control_cont}\n
        BuiltIn.Sleep   3s
        ${output}    Call Method    ${channel}    recv    ${65535}
        ${output}    Convert To String    ${output}
        ${port}=   fetch from right   ${output}   =
        ${port}=   fetch from left   ${port}   ]
        ${port}=    Remove String    ${port}   \r\n\x1b
        ${port}=   Get Line    ${port}    0
        Call Method    ${channel}    send   netstat -l | grep ${port}\n
        BuiltIn.Sleep   3s
        ${output}    Call Method    ${channel}    recv    ${65535}
        ${output}    Convert To String    ${output}
        ${ip_res}      Get Regexp Matches    ${output}    ([0-9]{1,3})[.-]([0-9]{1,3})[.-]([0-9]{1,3})[.-]([0-9]{1,3})
        ${IP}          Get Variable Value    ${ip_res[0]}
        ${ip_addr}=    Replace string    ${IP}    search_for=-     replace_with=.
        Call Method    ${channel}    send   /opt/nokia/SS_CPLANE/bin/set_logging_level --level trace --port ${port} --ip ${ip_addr}\n
        BuiltIn.Sleep   3s
        ${output}   Call Method    ${channel}    recv    ${65535}
        ${output}=  Decode Bytes To String  ${output}  UTF-8
        Should Contain      ${output}     Logging level changed
        Call Method    ${channel}    close
    END

Set vCU cplane container variables
    [Documentation]  set cplane contsiner
        @{pod_list}   Create List
    ...  cpif  cpcl  cpue  cpnb
    @{cpif_cont}  Create List  cpif
    @{cpue_cont}  Create List  cpue
    @{cpcl_cont}  Create List  cpcl
    @{cpnb_cont}  Create List  cpnb
    ${container}  Create Dictionary   ${cpue_pod}=@{cpue_cont}   ${cpif_pod}=@{cpif_cont}
    ...  ${cpcl_pod}=@{cpcl_cont}   ${cpnb_pod}=@{cpnb_cont}
    Set Suite Variable    @{cpif_cont}
    Set Suite Variable    @{cpue_cont}
    Set Suite Variable    @{cpcl_cont}
    Set Suite Variable    @{cpnb_cont}
    Set Suite Variable    @{pod_list}
    Set Suite Variable     ${container}

Check SCF Activation Status in log
    [Documentation]   This keyword will Check SCF Activation Status for CNF CU about coam cloudbts.
    ssh.Connect to   hostname=${${par_prefix}_k8s_addr}   username=${${par_prefix}_k8s_user}
    ...    password=${${par_prefix}_k8s_pwd}  alias=RM_alias
    ${tenant}=    set variable    ${${par_prefix}_tenant}
    ssh.execute
    ...   command=cd /tmp/${tl.tl_cloud_topology};rm -rf ${pre_flag}_log;mkdir ${pre_flag}_log   connection=RM_alias
    ...   timeout=60s
    Get pod name
    ssh.Connect to   hostname=${${par_prefix}_k8s_addr}   username=${${par_prefix}_k8s_user}
    ...    password=${${par_prefix}_k8s_pwd}  alias=RM_alias
    ${oam_journal_log_path}    Set Variable     /tmp/${tl.tl_cloud_topology}/${pre_flag}_log/oam_journal.log
    IF   not ${vDU_build_flag}
        ${container_prefix}    Set Variable If    '${tenant}' in '${oamconfig_pod}'
        ...    ctr-${tenant}    ctr
        ssh.execute
        ...  kubectl logs -n ${tenant} ${oamconfig_pod} -c ${container_prefix}-oamconfig > ${oam_journal_log_path}
        ...  connection=RM_alias    timeout=60s
    ELSE
        ${container_prefix}    Set Variable If    '${tenant}' in '${oam_pod}'
        ...    ctr-${tenant}    ctr
        ssh.execute
        ...  kubectl logs -n ${tenant} ${oam_pod} -c ${container_prefix}-oam > ${oam_journal_log_path}
        ...  connection=RM_alias    timeout=60s
    END
    ${check}=   ssh.Execute  sudo tac ${oam_journal_log_path} | grep -i "NRBTS_R operational state" -m 1
    ...    connection=RM_alias    timeout=60s
    Should Contain      ${check}    Enabled
    [Teardown]     ssh.disconnect   connection=RM_alias

Collect journal and startup logs for cm
    [Arguments]  ${cm}    ${list}   ${folder_name}   ${tenant}
    ${prefix}    Set Variable If  '${tenant}' in '${${cm}_pod}'
    ...    ctr-${tenant}    ctr
    FOR  ${cont}  IN  @{list}
        ssh.Connect to   hostname=${${CU_DU}_k8s_addr}   username=${${CU_DU}_k8s_user}
        ...    password=${${CU_DU}_k8s_pwd}  alias=RM_alias
        ssh.execute
        ...  kubectl logs -n ${tenant} ${${cm}_pod} -c ${prefix}-${cont} > /tmp/${tl.tl_cloud_topology}/${folder_name}/${cm}_journal.log
        ...  connection=RM_alias    timeout=60s
        BuiltIn.Sleep   3s
        ${startup_def}    Catenate    kubectl cp -n ${tenant} ${${cm}_pod}:/tmp/${tl.tl_cloud_topology}/startup_DEFAULT.log
        ...   /tmp/${tl.tl_cloud_topology}/${folder_name}/${cm}_startup_DEFAULT.log -c ${prefix}-${cont} > /dev/null 2>&1
        ssh.execute       ${startup_def}    connection=RM_alias    timeout=60s
    END


Set AiC Suite Variables
   [Documentation]  Set Suite Variables for vCU
   ...    author: min.zheng
    ${is_gate}=    Get Variable Value    ${is_gate}    False
    ${skip_pkg_deletion}=     Get Variable Value    ${skip_pkg_deletion}    False
    ${pkg_path}=    set variable if    ${is_gate}     /tmp/Gate_Builds    /tmp/${tl.tl_cloud_topology}
    IF    '${AF_PATH}'!='null'
        Log    AF_PATH: ${AF_PATH}
        ${sw_build}      get_build_name          ${AF_PATH}
        ${sw_version}    get_cloud_sw_version    ${AF_PATH}
        ${len}    Get Length    ${sw_build.replace('${sw_version}', '').split('-')}
        IF    ${len}==1
            ${pkg_suffix}    Set Variable    ${EMPTY}
        ELSE
            ${pkg_suffix}    Set Variable    -${sw_build.split('-')[-1].replace(".zip", "").replace("_install_files", "")}
        END
    ELSE
        ${sw_build}      Set Variable    ${branch}.default
        ${sw_version}    Set Variable    ${branch}.default
        ${pkg_suffix}    Set Variable    ${EMPTY}
    END
    Should Not Be Empty   ${sw_build}     ERROR! Could not fetch sw build from AF_PATH,please check if pkg exist.
    Set Suite Variable     ${sw_version}
    Set Suite Variable     ${pkg_suffix}
    ${build_name}=    Fetch From Left    ${sw_version}    marker=_
    Set Suite Variable     ${build_name}
    @{sw_version_list}=   Split String    ${sw_version}    separator=.
    @{output}=  Split String From Right     ${sw_version}      separator=.    max_split=1
    ${stream_number}=  Set Variable    ${output[0]}
#    ${stream_number}     ${build_version}     Split String From Right     ${sw_version}      separator=.    max_split=1
    ${stream_str}=   Run Keyword And Return Status   BuiltIn.Should Start With   ${stream_number}   9
    ${stream_prefix}=      Set Variable if  "${stream_str}"=="True"   0    ${sw_version_list}[0]
    ${stream_number}=    Set Variable if  "${stream_str}"=="True"   ${stream_prefix}.${sw_version_list}[1]   ${stream_number}
    Set Suite Variable     ${stream_number}
    ${is_TDD}   Set Variable If    'TDD' in '${NODE_NAME}'    True    False
    set suite variable   ${is_TDD}
    ${is_FDD}   Set Variable If    'FDD' in '${NODE_NAME}'    True    False
    set suite variable   ${is_FDD}
    IF    ${is_LTE}
        ${cnf_conversion_prefix}    Set Variable    cloudran-4gvdu
    ELSE
        ${cnf_conversion_prefix}    set variable if
        ...   'vDU' in '${STREAM}'    aic-vdu
        ...   'VDU' in '${STREAM}'    aic-vdu
        ...    'CU' in '${STREAM}'    aic-vcu
    END
    ${par_prefix}   set variable if
    ...   'vDU' in '${STREAM}'    DU
    ...   'VDU' in '${STREAM}'    DU
    ...    'CU' in '${STREAM}'    CU
    ${pre_flag}    set variable if
    ...   'vDU' in '${STREAM}'    vdu
    ...   'VDU' in '${STREAM}'    vdu
    ...    'CU' in '${STREAM}'    vcu
    ${vCU_build_flag}    set variable if    'CU' in '${STREAM}'    True    False
    ${vDU_build_flag}    set variable if
    ...   'vDU' in '${STREAM}'    True
    ...   'VDU' in '${STREAM}'    True
    ...   False
    ${isVDU}    Run Keyword And Return Status    Variable Should Exist    ${DU_k8s_addr}
    ${isVCU}    Run Keyword And Return Status    Variable Should Exist    ${CU_k8s_addr}
    IF    "_install_files" in "${AF_PATH}"
        ${is_global_ccr_reachable}    is_host_reachable    host=${${site}_global_registry_url}
        IF    ${is_global_ccr_reachable}
            ${image_registry}    Set Variable    ${${site}_global_registry_url}
        ELSE
            Log
            ...    Global image registry ${${site}_global_registry_url} is not reachable, use local image registry instead
            ...    WARN
            ${image_registry}    Set Variable    ${${site}_local_registry_url}/${${par_prefix}_tenant}
        END
    ELSE
        ${image_registry}    Set Variable    ${${site}_local_registry_url}/${${par_prefix}_tenant}
    END
    Set Suite Variable    ${sw_build}
    Set Suite Variable    ${STREAM_NUMBER}
    Set Suite Variable    ${cnf_conversion_prefix}
    # ${par_prefix} is used to define DU_<varible> or CU_<variable> from scf.py
    Set Suite Variable    ${par_prefix}
    # ${vCU_build_flag} is used to checking if testing vCU build
    Set Suite Variable    ${vCU_build_flag}
    # ${vDU_build_flag} is used to checking if testing vCU build
    Set Suite Variable    ${vDU_build_flag}
    # ${tdd/fdd} flag is used to check if it is vDU TDD Tl or vCU TDD TL
#    Set Suite Variable    ${tdd/fdd}
    # ${pre_flag} is used to define vcu_<folder> or vdu_<folder> which are used in sw deployment
    Set Suite Variable    ${pre_flag}
    # ${isVDU} is used to check if it is a vDU TL
    Set Suite Variable    ${isVDU}
    # ${isVCU} is used to check if it is a vCU TL
    Set Suite Variable    ${isVCU}
    Set Suite Variable    ${is_gate}
    Set Suite Variable    ${skip_pkg_deletion}
    Set Suite Variable    ${pkg_path}
    # flag used to test vcu setup on OCP Clusters Centralization
    Set Suite Variable    ${image_registry}

Undeploy AIC
    [Documentation]  undeploy cnf
    ...   author: min.zheng
    [Arguments]  ${hanging_resource_cleanup}=${False}
    ssh.Connect to   hostname=${${par_prefix}_k8s_addr}   username=${${par_prefix}_k8s_user}
    ...              password=${${par_prefix}_k8s_pwd}  alias=RM_alias
    ${release_name_list}    get_release_name_from_helm_list    ${${par_prefix}_tenant}
    ${rancnf_result_dict}    get_rancnf_result    namespace=${${par_prefix}_tenant}
    IF    not ${release_name_list} and ${rancnf_result_dict['cnf_quantity']} == ${0}
        Log to console    \n\nNo CNF deployed, skip undeploy steps!!!\n
        RETURN
    END
    IF    ${rancnf_result_dict['cnf_quantity']} > ${1}
        Fail    Multiple CNFs found, unable to undeploy
    END
    IF    ${rancnf_result_dict['cnf_quantity']} == ${0} or ${hanging_resource_cleanup}
        IF    ${rancnf_result_dict['cnf_quantity']} == ${1}
            Log To Console    \n\nBefore undeployment:\n${rancnf_result_dict['console_output']}
            Log To Console    \n -- WA to undeploy rancnf with hanging resource cleanup enabled --
        END
        ${release_name_dict}    get_cnf_pvc_cluster_release_names_from_helm_list
        ...    ${${par_prefix}_tenant}
        Undeploy AIC With Helm
        ...    ${hanging_resource_cleanup}
        ...    cnf_name=${release_name_dict['cnf_release']}
        ...    pvc_name=${release_name_dict['pvc_release']}
        ...    cluster_name=${release_name_dict['cluster_release']}
        IF    ${rancnf_result_dict['cnf_quantity']} == ${1}
            delete_helm_secrets    ${${par_prefix}_tenant}
            force_delete_rancnf    ${rancnf_result_dict['cnf_name']}    ${${par_prefix}_tenant}
        END
        RETURN
    END
    Log To Console    \n\nBefore undeployment:\n${rancnf_result_dict['console_output']}
    Undeploy AIC with CNF LCM Operator    rancnf_name=${rancnf_result_dict['cnf_name']}
    ...    release_name_list=${release_name_list}

####### CNF LCM related Keywords ##########
Save RANCNF Result Yaml
    [Documentation]  Save RANCNF result to yaml file and log status to console if needed
    [Arguments]  ${namespace}    ${output_path}    ${local_path}   ${cnf_phase}
    get_rancnf_result_yaml
    ...    namespace=${namespace}
    ...    output_path=${output_path}
    ssh.download_file
    ...    ${output_path}
    ...    ${local_path}
    ...    connection=RM_alias
    get_cnf_creation_status_from_yaml
    ...    save_error_to_file_path=${LOG_PATH}/gnb_startup_failure.log
    ...    namespace=${namespace}
    ...    cnf_phase=${cnf_phase}
    ssh.execute
    ...  rm -f ${output_path}
    ...  connection=RM_alias

RANCNF Deletion Timeout WA
    [Documentation]  Workaround for RANCNF deletion timeout issue
    [Arguments]    ${rancnf_name}    ${release_name_list}
    Log To Console    \nUndeploy AIC with CNF LCM Operator timedout, recovery initiated
    FOR    ${release_name}    IN    @{release_name_list}
        Wait Until Keyword Succeeds    3x    10s   Recover CNF Undeploy Timeout Issue
        ...    ${release_name}
        ...    ${${par_prefix}_tenant}
    END
    remove_rancnf_finalizer    ${rancnf_name}    ${${par_prefix}_tenant}
    ${rancnf_result_dict}    get_rancnf_result    namespace=${${par_prefix}_tenant}
    IF    ${rancnf_result_dict['cnf_quantity']} == ${0}
        Log To Console    RANCNF deletion SUCCESS
    ELSE
        Fail    RANCNF still exists after recovery, manual check needed!!!
    END

Undeploy AIC with CNF LCM Operator
    [Documentation]  undeploy cnf with cnf lcm operator
    [Arguments]  ${rancnf_name}    ${release_name_list}
    ${conn}    helm.helm_master_connect
    ...  ${${par_prefix}_k8s_addr}
    ...  22
    ...  ${${par_prefix}_k8s_user}
    ...  ${${par_prefix}_k8s_pwd}
    TRY
        Log To Console    \nUndeploy ${rancnf_name} started
        ${undeploy_output}    helm.execute_command_on_master_cluster
        ...    kubectl delete rancnf ${rancnf_name} -n ${${par_prefix}_tenant}
        ...    timeout=360
        IF    '${undeploy_output.status}' == '0'
            Log To Console     ------> DONE
        ELSE
            Log To Console     ------> FAILED
            Fail    Undeploy ${rancnf_name} failed due to ${undeploy_output.stderr.strip()}
        END
    EXCEPT    AS    ${error}
        Save RANCNF Result Yaml
        ...    namespace=${${par_prefix}_tenant}
        ...    output_path=/tmp/${tl.tl_cloud_topology}_${sw_version}_rancnf_uninstall_result.yaml
        ...    local_path=${LOG_PATH}/${tl.tl_cloud_topology}_${sw_version}_rancnf_uninstall_result.yaml
        ...    cnf_phase=uninstall
        ${assertion_error_occurs}    Get Regexp Matches    ${error}    failed due to
        IF    ${assertion_error_occurs}    Fail
        ${timeout}    Get Regexp Matches    ${error}    CommandOutputTimeoutError|timed out
        IF    ${timeout}
            RANCNF Deletion Timeout WA    ${rancnf_name}    ${release_name_list}
        ELSE
            Fail    Undeploy AIC with CNF LCM Operator failed due to ${error}
        END
    END

Deploy AIC With CNF LCM Operator
    [Documentation]  install or upgrade cnf with cnf lcm operator
    [Arguments]    ${clean_deploy}=${False}
    Precheck Before Deployment
    Set Target Path
    # WA before CBSCMS-93218 resolved
    ${sw_build}    Set Variable    ${sw_build.replace('_install_files', '')}
    Set Suite Variable    ${sw_build}
    ${is_local_image_registry_used}
    ...    Get Regexp Matches    ${image_registry}    ${${site}_local_registry_url}
    IF    ${is_local_image_registry_used} or ${clean_deploy}
        ssh.Connect to   hostname=${${par_prefix}_k8s_addr}   username=${${par_prefix}_k8s_user}
        ...    password=${${par_prefix}_k8s_pwd}  alias=RM_alias
        ssh.execute     command=rm -f /tmp/${tl.tl_cloud_topology}_rancnfconfig.cr.yaml
        ...    connection=RM_alias
    END
    ${ccr_yaml_exists}    Check If TL CR Yaml File Exists
    IF   not ${ccr_yaml_exists}
        Log To Console
        ...    No existing CR yaml file found or deploy with local CCR, start to generate new CR yaml file...
        Prepare cloud package
        Upload cnf/pvc/net override file
        Convert and Upload CR Yaml File
        IF    ${is_local_image_registry_used}
            Upload And Push Image
        END
    ELSE
        Log To Console
        ...    Existing CR yaml file /tmp/${tl.tl_cloud_topology}_rancnfconfig.cr.yaml found, start to update yaml file
        ${update_result}    Download And Update CR Yaml File
        ...    remote_path=/tmp/${tl.tl_cloud_topology}_rancnfconfig.cr.yaml
        ...    local_path=/tmp/rancnfconfig.cr.yaml
        ...    sw_build_name=${sw_build.replace('.zip', '')}
        ...    rancnf_name=${${par_prefix}_cnfname}
        ...    namespace=${${par_prefix}_tenant}
        ...    imageRegistry=${image_registry}
        IF    ${update_result}
            Log To Console    ------> DONE
        ELSE
            Log To Console    ------> FAILED
            Fail    Update CR yaml file FAILED!!!
        END
        Upload CR Yaml File And Copy To Log Path
    END
    Install/Upgrade CNF
    [Teardown]    Run Keyword If    ${is_local_image_registry_used}
    ...    ssh.execute
    ...    command=mv /tmp/${tl.tl_cloud_topology}_rancnfconfig.cr.yaml /tmp/${tl.tl_cloud_topology}_local_rancnfconfig.cr.yaml
    ...    connection=RM_alias

Check If TL CR Yaml File Exists
    [Documentation]  check if tl cr yaml file exists
    [Arguments]    ${cr_yaml_file_path}=/tmp/${tl.tl_cloud_topology}_rancnfconfig.cr.yaml
    ssh.Connect to   hostname=${${par_prefix}_k8s_addr}   username=${${par_prefix}_k8s_user}
    ...    password=${${par_prefix}_k8s_pwd}  alias=RM_alias
    ${cr_file_exists}    ssh.file_exists
    ...    ${cr_yaml_file_path}
    ...    connection=RM_alias
    RETURN    ${cr_file_exists}

Convert and Upload CR Yaml File
    [Documentation]  convert and upload cr yaml file
    Run    rm -f /tmp/rancnfconfig.cr.yaml
    ${generate_cr_yaml_cmd}    Catenate
    ...    cd ${target_path} && falcon convertReverse -m ${target_path}/manifest.json
    ...    --md ${target_path}/ParameterMetadata
    ...    --ovcnf ${target_path}/${cnf_override_path}/values-override.yaml
    ...    --ovclusterprep ${target_path}/${cluster_override_path}/values-override.yaml
    ...    --ovprerequisite ${target_path}/${pvc_override_path}/values-override.yaml
    ${tries}    Set Variable    ${5}
    FOR    ${index}    IN RANGE    1    ${tries+1}
        Log To Console    \nConverting CR yaml file, try ${index} of ${tries}...
        ${convert_result}    ssh.execute
        ...    command=${generate_cr_yaml_cmd}    connection=RM_alias    timeout=60s
        ${convert_success}    Get Regexp Matches    ${convert_result}    success
        IF    not ${convert_success}    Fail    Convert CR yaml file FAILED due to ${convert_result.strip()}!!!
        ssh.execute
        ...    command=cd ${target_path} && ls -ll *.cr.yaml
        ...    connection=RM_alias
        BuiltIn.Sleep   1s
        ${cnfSWBuild}     Set Variable If    ${is_gate}    ${STREAM}_${sw_version.split('_')[0]}${pkg_suffix}
        ...    ${sw_build.split('_')[0]}_${sw_version.split('_')[0]}${pkg_suffix}
        ${update_result}    Download And Update CR Yaml File
        ...    remote_path=${target_path}/rancnfconfig.cr.yaml
        ...    local_path=/tmp/rancnfconfig.cr.yaml
        ...    sw_build_name=${cnfSWBuild}
        ...    rancnf_name=${${par_prefix}_cnfname}
        ...    namespace=${${par_prefix}_tenant}
        ...    imageRegistry=${image_registry}
        IF    ${update_result}
            Log To Console    ------> DONE
            BREAK
        ELSE
            Log To Console    ------> FAILED
            IF    ${index}==${tries}
                Fail    Update CR yaml file FAILED!!!
            END
            BuiltIn.Sleep    5s
        END
    END
    BuiltIn.Sleep   1s
    Upload CR Yaml File And Copy To Log Path

Download And Update CR Yaml File
    [Documentation]  download and update cr yaml file with new build and rancnf name
    [Arguments]  ${remote_path}    ${local_path}    ${sw_build_name}
    ...          ${rancnf_name}    ${namespace}    ${imageRegistry}    ${connection}=RM_alias
    ssh.download file
    ...   remote_path=${remote_path}
    ...   local_path=${local_path}
    ...   connection=${connection}
    BuiltIn.Sleep   1s
    ${api_version}    get_cnf_apiVersion    conn=${connection}
    IF    '${api_version}' == ''    Fail    Get apiVersion from current cluster failed!!!
    ${update_result}    update_cr_yaml_file
    ...    yaml_file_path=${local_path}
    ...    sw_build=${sw_build_name}
    ...    rancnf_name=${rancnf_name}
    ...    namespace=${namespace}
    ...    imageRegistry=${imageRegistry}
    ...    apiVersion=cnf.k8s.nokia.com/${api_version}
    RETURN    ${update_result}

Upload CR Yaml File And Copy To Log Path
    [Arguments]  ${local_path}=/tmp/rancnfconfig.cr.yaml
    ...          ${remote_path}=/tmp/${tl.tl_cloud_topology}_rancnfconfig.cr.yaml
    ...          ${connection}=RM_alias
    ssh.upload_file
    ...   local_path=${local_path}
    ...   remote_path=${remote_path}
    ...   connection=${connection}
    Run    cp ${local_path} ${LOG_PATH}/${tl.tl_cloud_topology}_${sw_version}_rancnfconfig.cr.yaml

Install/Upgrade CNF
    [Documentation]  install or upgrade cnf with cnf lcm operator
    [Arguments]    ${timeout}=${22}
    ${rancnf_result_dict}    get_rancnf_result    namespace=${${par_prefix}_tenant}
    IF    ${rancnf_result_dict['cnf_quantity']} == ${0}
        ${error_status}     Get Regexp Matches    ${rancnf_result_dict['console_output']}    (E|e)rror
        IF    ${error_status}
            Fail    Get rancnf status error: ${rancnf_result_dict['console_output']}
        ELSE
            Log To Console    \nNo CNF is deployed, start to install CNF...\n\nCCR Address: ${image_registry}\n
            ${cnf_command}    Set Variable    kubectl create -f /tmp/${tl.tl_cloud_topology}_rancnfconfig.cr.yaml
        END
    ELSE IF    ${rancnf_result_dict['cnf_quantity']} == ${1}
        Log To Console
        ...    \nBefore Upgrade:\n${rancnf_result_dict['console_output']}\n\nCCR Address: ${image_registry}\n
        IF    '${rancnf_result_dict['cnf_phase']}' == 'Running'
            Log To Console    Start to upgrade CNF...
            ${cnf_command}    Set Variable    kubectl apply -f /tmp/${tl.tl_cloud_topology}_rancnfconfig.cr.yaml
        ELSE
            Log To Console
            ...    Start to undeploy CNF...
            Undeploy AIC
            ${cnf_command}    Set Variable    kubectl create -f /tmp/${tl.tl_cloud_topology}_rancnfconfig.cr.yaml
        END
    ELSE
        Fail    Multiple cnf are deployed, please check manually!!!\n${rancnf_result_dict['console_output']}
    END
    ${install_cnf_result}    ssh.execute
    ...    command=${cnf_command}
    ...    connection=RM_alias
    ${install_success}    Get Regexp Matches    ${install_cnf_result}    ${${par_prefix}_cnfname} created|updated|unchanged|configured
    IF    not ${install_success}    Fail    Install/Upgrade CNF FAILED due to ${install_cnf_result.strip()}!!!
    FOR    ${index}    IN RANGE    1    ${timeout+1}
        BuiltIn.Sleep    60s
        ${rancnf_result_dict}    get_rancnf_result    namespace=${${par_prefix}_tenant}
        IF    ${rancnf_result_dict['cnf_quantity']} == ${0}
            IF    ${index}==${timeout}
                Save RANCNF Result Yaml
                ...    namespace=${${par_prefix}_tenant}
                ...    output_path=/tmp/${tl.tl_cloud_topology}_${sw_version}_rancnf_install_result.yaml
                ...    local_path=${LOG_PATH}/${tl.tl_cloud_topology}_${sw_version}_rancnf_install_result.yaml
                ...    cnf_phase=install
                Get Necessary Info after Deployment
                Fail
                ...    CNF not found after installation, output is ${rancnf_result_dict['console_output']}
            END
            Log To Console
            ...    CNF not found after installation, output is ${rancnf_result_dict['console_output']}, wait for next check...
            CONTINUE
        END
        IF    '${rancnf_result_dict['status']}'=='Succeed'
            Log To Console    ------> DONE
            Log To Console    \nAfter Deployment:\n${rancnf_result_dict['console_output']}
            RETURN
        ELSE IF    '${rancnf_result_dict['status']}'=='Failed' or ${index}==${timeout}
            Log    CNF installation FAILED:\n${rancnf_result_dict['console_output']}    WARN
            Save RANCNF Result Yaml
            ...    namespace=${${par_prefix}_tenant}
            ...    output_path=/tmp/${tl.tl_cloud_topology}_${sw_version}_rancnf_install_result.yaml
            ...    local_path=${LOG_PATH}/${tl.tl_cloud_topology}_${sw_version}_rancnf_install_result.yaml
            ...    cnf_phase=install
            Get Necessary Info after Deployment
            Fail
            ...    CNF installation FAILED, please check ${OUTPUT_DIR}/${tl.tl_cloud_topology}_${sw_version}_rancnf_install_result.yaml for details!!!
        END
        Log To Console
        ...    \nCNF installation in progress, current status: ${rancnf_result_dict['status']}, current phase: ${rancnf_result_dict['cnf_phase']}
        BuiltIn.Sleep    60s
    END
    [Teardown]    collect_cnf_lcm_pod_and_logs
    ...           controller_log_path=/tmp/${tl.tl_cloud_topology}_cnf_controller.log
    ...           engine_log_path=/tmp/${tl.tl_cloud_topology}_cnf_engine.log
    ...           upload_path_prefix=${LOG_PATH}/${tl.tl_cloud_topology}_${sw_version}

Check AIC Version In CR
    [Documentation]  check aic version in rancnf cr
    ssh.Connect to   hostname=${${par_prefix}_k8s_addr}   username=${${par_prefix}_k8s_user}
    ...    password=${${par_prefix}_k8s_pwd}  alias=RM_alias
    ${rancnf_result_dict}    get_rancnf_result    namespace=${${par_prefix}_tenant}
    IF    ${rancnf_result_dict['cnf_quantity']} == ${0}    Fail    No CNF deployed, unable to check version!
    Should Be True    '${build_name}' in '${rancnf_result_dict['effective_cnf_build']}'
    ...    CNF version in CR: ${rancnf_result_dict['effective_cnf_build']}, expected version: ${build_name}
#######################

Undeploy AIC With Helm
    [Documentation]  undeploy cnf
    ...   author: min.zheng
    [Arguments]    ${hanging_resource_cleanup}=${False}
    ...            ${cnf_name}=${${par_prefix}_cnfname}
    ...            ${pvc_name}=${${par_prefix}_pvcname}
    ...            ${cluster_name}=cluster-${pre_flag}
    ...            ${namespace}=${${par_prefix}_tenant}
    ${conn}    helm.helm_master_connect
    ...  ${${par_prefix}_k8s_addr}
    ...  22
    ...  ${${par_prefix}_k8s_user}
    ...  ${${par_prefix}_k8s_pwd}
    IF    '${cnf_name}' !=''
        Log To Console    \nUndeploy pods started
        TRY
            Check helm delete command executed successfully
            ...  release_name=${cnf_name}
            ...  namespace=${${par_prefix}_tenant}
        EXCEPT   .*Command(OutputTimeout|Execution)Error.*    type=Regexp
            Log    helm delete execution failed, start to reconnect ${par_prefix}!!!    WARN
            helm.helm_master_close    ${conn}
            helm.helm_master_connect
            ...  ${${par_prefix}_k8s_addr}
            ...  22
            ...  ${${par_prefix}_k8s_user}
            ...  ${${par_prefix}_k8s_pwd}
            Check helm delete command executed successfully
            ...  release_name=${cnf_name}
            ...  namespace=${namespace}
        END
        Cleanup redundant job on OCP
        Cleanup redundant pod on OCP
        ${res_bool}=   Run Keyword And Return Status    Wait Until Keyword Succeeds    10x    30s     Check pods empty
        IF    not ${res_bool}
            helm.execute_command_on_master_cluster
            ...  kubectl get pods -n ${namespace} |awk '{print $1}' |xargs kubectl delete pod -n ${namespace} --force --grace-period=0
            Wait Until Keyword Succeeds    10x    30s     Check pods empty
        END
        Log To Console    ------> DONE
    END
    ${console_msg}     Set Variable If     ${hanging_resource_cleanup}    with hanging resource cleanup    without hanging resource cleanup
    IF    '${pvc_name}' !=''
        Log To Console    Undeploy pvc ${console_msg} started
        IF    ${hanging_resource_cleanup}
            Helm delete pvc on OCP    ${pvc_name}
        ELSE
            Check helm delete command executed successfully
            ...  release_name=${pvc_name}
            ...  namespace=${namespace}
        END
        BuiltIn.Sleep    20s
        Check release removed  ${pvc_name}
        Log To Console    ------> DONE
    END
    IF    '${cluster_name}' !=''
        Log To Console    Undeploy cluster started
        Wait Until Keyword Succeeds    2x    30s   Check helm delete command executed successfully
        ...  release_name=${cluster_name}
        ...  namespace=${namespace}
        BuiltIn.Sleep    20s
        Check release removed  ${cluster_name}
        Log To Console    ------> DONE
    END
    Cleanup redundant pvc on OCP
    [Teardown]   Run Keywords
    ...  Run Keyword And Ignore Error   helm.helm_master_connect
    ...  ${${par_prefix}_k8s_addr}
    ...  22
    ...  ${${par_prefix}_k8s_user}
    ...  ${${par_prefix}_k8s_pwd}
    ...   AND     Run Keyword And Ignore Error  helm.execute_command_on_master_cluster
    ...   kubectl get all -n ${${par_prefix}_tenant}
    ...   AND     Run Keyword if  ${vCU_build_flag}    Run Keyword And Ignore Error  Cleanup exited container

Helm delete pvc on OCP
    [Documentation]  remove pvc with arguments --no-hooks
    [Arguments]    ${pvc_name}=${${par_prefix}_pvcname}
    ssh.Connect to   hostname=${${par_prefix}_k8s_addr}   username=${${par_prefix}_k8s_user}
    ...    password=${${par_prefix}_k8s_pwd}  alias=RM_alias
    ssh.send_command   command=helm del ${pvc_name} -n ${${par_prefix}_tenant} --no-hooks   connection=RM_alias
    ${output}=   ssh.read_output    connection=RM_alias
    Should Not Contain Any   ${output}   error   failed
    [Teardown]  Run Keyword And Ignore Error   ssh.disconnect   connection=RM_alias

Check helm delete command executed successfully
    [Documentation]  Helem delete command will be passed if release is uninstalled or release is not found
    [Arguments]  ${release_name}    ${namespace}
    ${output}=    helm.helm_delete
    ...   release_name=${release_name}
    ...   namespace=${namespace}
    ...   fail_on_error=False
    ${undeploy_wa_condition}     Get Regexp Matches
    ...    ${output}[1]    timed out waiting for the condition|graceful-cell-shutdown failed
    IF    ${undeploy_wa_condition}
        Log To Console
        ...    --> Undeploy CNF timeout occurs or job graceful-cell-shutdown failed, start to run undeploy_cnf.sh for recovery
        TRY
            Recover CNF Undeploy Timeout Issue    ${release_name}    ${namespace}
        EXCEPT   AS    ${error}
            ${assertionerror_occurs}    Get Regexp Matches    ${error}    Recover CNF undeployment issue
            IF    ${assertionerror_occurs}
                Fail    ${error}
            ELSE
                Set Suite Variable    ${undeploy_timeout}    True
                Fail    Recover CNF undeployment issue failed due to ${error}
            END
        END
    ELSE IF    'uninstalled' not in '${output[0].strip()}'
        Should Contain   ${output}[1]    release: not found
    END

Recover CNF Undeploy Timeout Issue
    [Documentation]  This keyword is used to recover undeploy timeout issue
    [Arguments]  ${release_name}    ${namespace}
    ssh.Connect to   hostname=${${par_prefix}_k8s_addr}   username=${${par_prefix}_k8s_user}
    ...    password=${${par_prefix}_k8s_pwd}  alias=RM_alias
    ssh.upload file    local_path=${CURDIR}/../scripts/undeploy_cnf.sh
    ...    remote_path=/tmp/${tl.tl_cloud_topology}/undeploy_cnf.sh
    ...    connection=RM_alias
    ${output}    ssh.execute
    ...    command=. /tmp/${tl.tl_cloud_topology}/undeploy_cnf.sh ${release_name} ${namespace} 180
    ...    connection=RM_alias
    ${release_name_list}    get_release_name_from_helm_list    ${namespace}
    ${is_recovered}    Run Keyword And Return Status
    ...    List Should Not Contain Value    ${release_name_list}   ${release_name}
    IF    ${is_recovered}
        Log To Console    --> Recover CNF undeployment issue of ${release_name} SUCCESS
    ELSE
        Set Suite Variable    ${undeploy_timeout}    True
        Fail    Recover CNF undeployment issue of ${release_name} FAILED. Output:\n${output}
    END

Cloud Env Health Stop And Fix Check
    [Documentation]  check if cloud env is healthy after deployment
    ${undeploy_timeout}     Get Variable Value    ${undeploy_timeout}    False
    IF    ${undeploy_timeout}
        ${is_data_after_test_file_exist}    Run Keyword And Return Status
        ...    File Should Exist    ${OUTPUT_DIR}/data_after_test.txt
        IF    not ${is_data_after_test_file_exist}
            Create File        ${OUTPUT_DIR}/data_after_test.txt    ${EMPTY}
        END
        Append To file
        ...    ${OUTPUT_DIR}/data_after_test.txt
        ...    stop_and_fix=true\nstop_and_fix_reason=Undeployment timeout occurs, please manually fix cloud env issue!\n
    END

Check AIC version with helm
    [Documentation]  check cnf, cluster version after deployment with helm command on OE
    helm.helm_master_connect
    ...  ${${par_prefix}_k8s_addr}
    ...  22
    ...  ${${par_prefix}_k8s_user}
    ...  ${${par_prefix}_k8s_pwd}
    ${result}=    Run Keyword    helm.helm_get_release_list  ${${par_prefix}_tenant}
    ${result_length}    Get Length    ${result}
    Should Not Be Equal As Integers    ${result_length}    0
    FOR    ${index}    IN RANGE    ${result_length}
        ${result_check}    Get From List    ${result}  ${index}
        ${version}    Get From Dictionary    ${result_check}  chart
        ${name}   Get From Dictionary    ${result_check}  name
        run keyword if   '${name}'=='${${par_prefix}_cnfname}'   Should be true  '${build_name}' in '${version}'
    ...  ELSE   log    ${name} version check skipped
    END

Check Containers status after deployment
    [Documentation]  check if all containers are up after deployment
    [Arguments]  ${par_prefix}=${par_prefix}
    Log To Console  ----> Start to check containers status
    Check Containers status with Helm    par_prefix=${par_prefix}

Check Containers status with Helm
    [Arguments]  ${par_prefix}=${par_prefix}
    BuiltIn.Sleep   120s
    ssh.Connect to   hostname=${${par_prefix}_k8s_addr}   username=${${par_prefix}_k8s_user}
    ...    password=${${par_prefix}_k8s_pwd}  alias=RM_alias
    Get pod name   namespace=${${par_prefix}_tenant}
    FOR    ${_}    IN RANGE    0    4
        ${result}=  check_all_pods_status  namespace=${${par_prefix}_tenant}   conn=RM_alias
        ${res_bool}=  Run Keyword And Return Status  Should Be True  ${result}
        exit for loop if  '${result}'=='True'
        BuiltIn.Sleep  30s
    END
    Run Keyword If  '${res_bool}'=='False'  Run Keywords
    ...  Get Pod status
    ...  AND  Fail  !!!Warning!!! container status check failed!  WARN
    Run Keyword If   '${par_prefix}'=='CU'    Run keyword and Continue on Failure  Wait Until Keyword Succeeds   120s   40s
    ...     check vCU oamep status
    Run Keyword If   '${par_prefix}'=='DU'    Run keyword and Continue on Failure  Wait Until Keyword Succeeds   120s   40s
    ...     check vDU oamep status
    [Teardown]    Run Keyword And Ignore Error    ssh.reset_cache

Cleanup exited container
    [Documentation]  remove exited container on OE
    ${conn}=   helm.helm_master_connect
    ...  ${${par_prefix}_k8s_addr}
    ...  22
    ...  ${${par_prefix}_k8s_user}
    ...  ${${par_prefix}_k8s_pwd}
    helm.execute_command_on_master_cluster
    ...  for id in $(sudo crictl ps -a | grep -i exited | awk '{print $1}') ; do sudo crictl rm $id ; done
    ${output}=  helm.execute_command_on_master_cluster  sudo crictl ps -a |grep -i exited
    Should Be Empty  ${output.stdout}
    [Teardown]  Run Keyword And Ignore Error     helm.helm_master_close    ${conn}

Check release removed
   [Documentation]  check if pvc was cleanup in helm list
   [Arguments]  ${release_name}
   ssh.Connect to   hostname=${${par_prefix}_k8s_addr}   username=${${par_prefix}_k8s_user}
    ...    password=${${par_prefix}_k8s_pwd}  alias=RM_alias
   ${output}=   ssh.execute  command=helm list -n ${${par_prefix}_tenant}   connection=RM_alias    timeout=60s
   Should Not Contain  ${output}   ${release_name}

Cleanup redundant ${pvc_pod_job} on OCP
    [Timeout]       10 min
    [Documentation]  cleanup all postinstall and preinstall job once deployment failure
    ssh.Connect to   hostname=${${par_prefix}_k8s_addr}   username=${${par_prefix}_k8s_user}
    ...    password=${${par_prefix}_k8s_pwd}  alias=RM_alias
    @{result}=   get_node_list    cmd=kubectl get ${pvc_pod_job} -n ${${par_prefix}_tenant}   alias=RM_alias
    FOR   ${job}  IN   @{result}
        ssh.send_command    command=kubectl delete ${pvc_pod_job} ${job} -n ${${par_prefix}_tenant} --grace-period=0 --force
        ...   connection=RM_alias
        ${output}=    ssh.read_output    connection=RM_alias
        Should Not Contain Any   ${output}  Error   failed
    END

Deploy AIC
    [Documentation]  create network, pvc and cnf
    ...   author: min.zheng
    [Arguments]  ${skip_cloud_pkg_preparation}=${False}    ${clean_deploy}=${False}
    ${cnf_lcm_deploy}     Get Variable Value    ${cnf_lcm_deploy}    False
    IF    ${cnf_lcm_deploy}
        Log To Console   \n-----> Deploy via CNF LCM Operator Started\n
        Deploy AIC With CNF LCM Operator    ${clean_deploy}
        RETURN
    END
    Log To Console   \n-----> AIC Deployment Started\n
    IF    "_install_files" in "${AF_PATH}"
        Handle CCR With Fallback
        ...    skip_cloud_pkg_preparation=${skip_cloud_pkg_preparation}
    ELSE
        Deploy AIC With Helm
        ...    skip_cloud_pkg_preparation=${skip_cloud_pkg_preparation}
    END

Handle CCR With Fallback
    [Documentation]    Attempts to deploy AIC with CCR. If the deployment fails, logs the failure
    ...    and proceeds to deploy AIC from local source. This keyword prevents the test case from failing due to CCR failure.
    ...    author: krystian.wachowski
    [Arguments]    ${skip_cloud_pkg_preparation}
    ${site}    Get Variable Value    ${site}    None
    Log To Console    CCR address: ${image_registry}
    TRY
        Deploy AIC With Helm
        ...    image_registry=${image_registry}
        ...    skip_cloud_pkg_preparation=${skip_cloud_pkg_preparation}
        ...    global_ccr_deployment=True
    EXCEPT    AS    ${error}
        IF    ${${par_prefix}_ACM_based_installation}
            Fail    CCR deployment failed: ${error}
        ELSE
            Log    CCR deployment failed: ${error}    WARN
            Log To Console    Switching to default helm deployment ...
            ${sw_build} =    Set Variable    ${sw_build.replace('_install_files', '')}
            Set Suite Variable    ${sw_build}
            Undeploy AIC With Helm
            Deploy AIC With Helm
            ...    skip_cloud_pkg_preparation=${skip_cloud_pkg_preparation}
            Set Suite Variable    ${CCR_Fallback}    True
        END
    END

Precheck Before Deployment
    [Documentation]  Precheck the environment before deployment
    ${res_bool}=  Run Keyword And Return Status   Check GNSSEMOD-1 state in FHGW
    Run Keyword If   '${res_bool}' == 'False'   Restart FPGA service
    ...   cmd=systemctl restart switch-manager startfpga fpgaAgent syncApp gpsd
    IF   ${vDU_build_flag}
        Check if loki driver is active
        Check rannic sw controller status
    END

Set Target Path
    ${target_path}    Get Variable Value    ${target_path}    Not Set
    IF    '${target_path}' == 'Not Set'
        ${target_path}    Set Variable If    ${is_gate}   /tmp/Gate_Builds/${sw_version}
        ...    /tmp/${tl.tl_cloud_topology}/${sw_version}
        Set Suite Variable   ${target_path}
    END

Deploy AIC With Helm
    [Documentation]  create pvc,cnf and cluster with helm command
    [Arguments]  ${skip_cloud_pkg_preparation}    ${image_registry}=${image_registry}    ${global_ccr_deployment}=${False}
    Precheck Before Deployment
    Set Target Path
    ${force_pkg_upload_flag}     Get Variable Value   ${tl.custom['force_pkg_upload_flag']}    None
    IF   '${skip_cloud_pkg_preparation}' == 'False' or '${force_pkg_upload_flag}' == 'True'
        Prepare cloud package    global_ccr_deployment=${global_ccr_deployment}
        IF    not ${global_ccr_deployment}
            Upload And Push Image
        END
        Upload cnf/pvc/net override file
    ELSE
        BuiltIn.Sleep   3min
    END
    IF    ${vDU_build_flag} and not ${DU_ACM_based_installation}    Wait Until Keyword Succeeds   5min  30s   Get PV status
    Run Keyword And Ignore Error     Start live pod status
    &{helm_values}=    Create Dictionary
    Run Keyword If    '${image_registry}' != 'None'    Set To Dictionary    ${helm_values}    global.image.registry=${image_registry}
    Create Cluster  &{helm_values}
    Create pvc  &{helm_values}
    ${timeout}    Set Variable If     ${global_ccr_deployment}    6m    16m
    ${cnf_creation_status}   Run Keyword And Return Status    Create cnf    ${timeout}    &{helm_values}
    IF    not ${cnf_creation_status}
        Run Keyword If    ${vDU_build_flag}
        ...    Log To Console  \n CNF deploy failed, starts to check RanNicNodeConfig status:
        Run Keyword If  ${vDU_build_flag}   Check and Collect RanNicNodeConfig log
        Get Necessary Info after Deployment
    END
    Should Be True       ${cnf_creation_status}     Create cnf failed!!!
    [Teardown]  Run Keyword And Ignore Error     Stop live pod status

Get Necessary Info after Deployment
    [Documentation]  get necessary info after deployment
    Log To Console    \n\t CNF deploy failed, starts to check pods status: \n
    Run Keyword And Ignore Error    Get Pod status
    Run Keyword And Ignore Error     Get Events
    Run Keyword And Ignore Error     Get describe log

Output pattern matches
    [Arguments]     ${invoke_object}    ${match}
    BuiltIn.Sleep    10s
    ${status}    Call Method    ${invoke_object}    recv_ready
    ${output}    run keyword if    ${status}    Call Method    ${invoke_object}    recv    ${65535}
    ${output}    convert to string    ${output}
    should contain    ${output}    ${match}    ignore_case=True

Check if OE is restart
     [Arguments]  ${timeout}=120
     FOR  ${_}   IN RANGE   0   ${timeout}+1
        ${not_pingable}   Run Keyword And Return Status    Check If OE is not pingable
        Run Keyword If   ${not_pingable}    Log To Console   ----> OE automatically restart, waiting....
        Exit For Loop If    "${not_pingable}"=="True"
     END
     ${pingable}=   Run Keyword And Return Status  Wait Until Keyword Succeeds    100x    5s    Check If OE is not pingable   Not_Pingable=False
     Run Keyword If   ${not_pingable} and ${pingable}    Log To Console   ----> OE restart done,loki driver will be checked.
     ...   ELSE IF  '${not_pingable}'=='True' and '${pingable}'=='False'
     ...   Log To Console   ----> !!!Warning!!! OE restart failed and now is not pingable, pls manually check!   WARN
     should be true   ${not_pingable} and ${pingable}

Check If OE is not pingable
    [Arguments]  ${timeout}=5   ${Not_Pingable}=True
    ${output}    Run    ping -c ${timeout} ${DU_k8s_addr}
    Run Keyword If   ${Not_Pingable}    Should Contain   ${output}    ${timeout} packets transmitted, 0 received
    ...   ELSE   Should Contain    ${output}    ${timeout} packets transmitted, ${timeout} received

Create Cluster
    [Documentation]  create cluster for every build
    [Arguments]  &{helm_values}
    ${conn}=    helm.helm_master_connect
    ...  ${${par_prefix}_k8s_addr}
    ...  ${${par_prefix}_k8s_port}
    ...  ${${par_prefix}_k8s_user}
    ...  ${${par_prefix}_k8s_pwd}
    Log To Console    Deploy cluster started
    Helm Install with K8s Reconnection
    ...  release_name=cluster-${pre_flag}
    ...  chart_path=${target_path}/${cnf_conversion_prefix}-cluster-preparation/
    ...  value_files=${target_path}/${cnf_conversion_prefix}-cluster-preparation/values-override.yaml
    ...  install_timeout=16m
    ...  connection=${conn}
    ...  step_error=Create Cluster
    ...  values=&{helm_values}
    Log To Console    ------> DONE
    [Teardown]    Run Keyword And Ignore Error     helm.helm_master_close    ${conn}

Create pvc
    [Documentation]  create pvc for every build
    ...   author: min.zheng
    [Arguments]  &{helm_values}
    ${conn}=    helm.helm_master_connect
    ...  ${${par_prefix}_k8s_addr}
    ...  ${${par_prefix}_k8s_port}
    ...  ${${par_prefix}_k8s_user}
    ...  ${${par_prefix}_k8s_pwd}
    Log To Console    Deploy pvc started
    ${pvc_override_path}  Get variable value  ${pvc_override_path}  None
    IF    '${pvc_override_path}' == 'None'
        Fail    pvc_override_path cannot be found in redeployment case, pls run the deployment case first with SW_DEPL tag!
    ELSE
        Helm Install with K8s Reconnection
        ...  release_name=${${par_prefix}_pvcname}
        ...  chart_path=${target_path}/${pvc_override_path}/
        ...  value_files=${target_path}/${pvc_override_path}/values-override.yaml
        ...  install_timeout=16m
        ...  connection=${conn}
        ...  step_error=Create PVC
        ...  values=&{helm_values}
    END
    Log To Console    ------> DONE
    [Teardown]    Run Keyword And Ignore Error     helm.helm_master_close   ${conn}

Create cnf
    [Documentation]  create pod
    ...   author: min.zheng
    [Arguments]  ${timeout}    &{helm_values}
    Log To Console    Deploy cnf started
    ${conn}=    helm.helm_master_connect
    ...  ${${par_prefix}_k8s_addr}
    ...  ${${par_prefix}_k8s_port}
    ...  ${${par_prefix}_k8s_user}
    ...  ${${par_prefix}_k8s_pwd}
    ${cnf_override_path}  Get Variable Value  ${cnf_override_path}  None
    IF     '${cnf_override_path}' == 'None'
        Fail    cnf_override_path cannot be found in redeployment case, pls run the deployment case first with SW_DEPL tag!
    ELSE
        Helm Install with K8s Reconnection
        ...  release_name=${${par_prefix}_cnfname}
        ...  chart_path=${target_path}/${cnf_override_path}/
        ...  value_files=${target_path}/${cnf_override_path}/values-override.yaml
        ...  install_timeout=${timeout}
        ...  connection=${conn}
        ...  step_error=Create CNF
        ...  values=&{helm_values}
    END
    ${output}=  Wait Until Keyword Succeeds   1min   10s   helm.execute_command_on_master_cluster
    ...    kubectl get pods -n ${${par_prefix}_tenant}
    Should Contain    ${output.stdout}    healing-controller
    Log To Console    ------> DONE
    ssh.Connect to   hostname=${${par_prefix}_k8s_addr}   username=${${par_prefix}_k8s_user}
    ...    password=${${par_prefix}_k8s_pwd}  alias=RM_alias
    Run Keyword And Ignore Error    ssh.download file   ${target_path}/${cnf_override_path}/values-override.yaml
    ...    ${LOG_PATH}/values-override.yaml   connection=RM_alias
    [Teardown]    Run Keyword And Ignore Error     helm.helm_master_close    ${conn}

Prepare cloud package
    [Documentation]  get and modify yaml file
    ...   author: min.zheng
    [Arguments]    ${global_ccr_deployment}=${False}
    helm.helm_master_connect   ${${par_prefix}_k8s_addr}   ${${par_prefix}_k8s_port}   ${${par_prefix}_k8s_user}
    ...    ${${par_prefix}_k8s_pwd}
    ${NFS_build_path}    Set Variable If    'WRO' in '${site}' and ${is_gate}
    ...    /media/builds/Aic_Gate_Builds/${sw_version}
    ...    'WRO' in '${site}' and '${is_gate}' == 'False'
    ...    /media/builds/${sw_version}
    ...    ${is_gate}    /media/builds/Aic_Gate_Builds/${sw_version}
    ...    /media/builds/${sw_version}
    Set Test Variable    ${NFS_build_path}
    ssh.Connect to   hostname=${${par_prefix}_k8s_addr}   username=${${par_prefix}_k8s_user}
    ...    password=${${par_prefix}_k8s_pwd}  alias=RM_alias
    ${vdu_zip_pkg}=   ssh.file_exists
    ...   remote_path=${target_path}/${sw_build}  connection=RM_alias
    ${sha256_check} =    Run Keyword If    ${vdu_zip_pkg}
    ...    sha256 check    target_file_path=${target_path}/${sw_build}    remote_file_path=${NFS_build_path}/${sw_build}
    ...    connection=RM_alias
    ...    ELSE    Set Variable    ${False}
    ${not_knife}=   Run Keyword And Return Status    Should Not Be Equal   '${knife}'    'true'
    IF    not ${global_ccr_deployment}
        ${onboarding_pkg}=   ssh.file_exists
        ...   remote_path=${target_path}/onBoardingApp.tgz  connection=RM_alias
        IF    ${vdu_zip_pkg} and ${onboarding_pkg} and ${sha256_check}
            Log To Console    Package exists on server, unzip process started....
        ELSE
            Clean old releases and download new aic package
        END
        ${output}=   ssh.execute   command=cd ${target_path};7za x -y ${sw_build}  connection=RM_alias    timeout=120s
        BuiltIn.Sleep    1 sec
        @{pkg_tmp}=   Split String From Right  ${sw_build}    separator=.    max_split=1
        ${bool_res}=   ssh.file_exists   remote_path=${target_path}/${pkg_tmp[0]}.sig
        ${bool_res}=   Run Keyword And Return Status   Should Be True   ${bool_res}
        Run Keyword If   '${bool_res}'=='True'
        ...   ssh.execute   command=cd ${target_path};7za x -y ${sw_build}  connection=RM_alias    timeout=180s
        BuiltIn.Sleep    1 sec
        Should Contain   ${output}   Everything is Ok
        ${output}=    Run Keyword If    ${is_gate}
        ...    ssh.execute    command=cd ${target_path}/artifacts;cp onBoardingApp.tgz ../  connection=RM_alias    timeout=60s
        IF    ${is_gate}
            BuiltIn.Sleep    1 sec
            Should Not Contain Any   ${output}   No such file or directory   Error is not recoverable
        END
    ELSE IF    ${global_ccr_deployment}
        IF   ${vdu_zip_pkg} and ${sha256_check}
            Log To Console    Package exists on server, unzip process started....
        ELSE
            Clean old releases and download new aic package    global_ccr_deployment=${global_ccr_deployment}
        END
        ssh.execute    command=cd ${target_path};7za x -y ${sw_build}    connection=RM_alias    timeout=60s
    END
    ${exist_prerequisite_file}=   ssh.file_exists
    ...   remote_path=${target_path}/values-override.${cnf_conversion_prefix}-prerequisite.yaml  connection=RM_alias
    IF    not ${exist_prerequisite_file}
        ${output}=  ssh.execute    command=cd ${target_path};mv HelmChart/* .;rm -rf HelmChart  connection=RM_alias    timeout=60s
        BuiltIn.Sleep    1 sec
        Should Be Empty    ${output}   ERROR! Please check if HelmChart exists
        ${exist_prerequisite_file}=   ssh.file_exists
        ...   remote_path=${target_path}/values-override.${cnf_conversion_prefix}-prerequisite.yaml  connection=RM_alias
    END
    Should Be True  ${exist_prerequisite_file}
    ### Uncompression pre-prerequisites file
    ${result}  ${pvc_override_path}=  get_vcu_vdu_helm_file  ${target_path}  ${cnf_conversion_prefix}-prerequisite-.*.tgz  alias=RM_alias
    Should Be True  ${result}
    Set Suite Variable    ${pvc_override_path}
    ### Uncompression cnf file ###
    ${result}  ${cnf_override_path}=  get_vcu_vdu_helm_file  ${target_path}  ${cnf_conversion_prefix}-?[^-]*-${build_name}.tgz  alias=RM_alias
    Should Be True  ${result}
    Set Suite Variable    ${cnf_override_path}
    ### Uncompression cluster file ###
    ${result}  ${cluster_override_path}=  get_vcu_vdu_helm_file  ${target_path}  ${cnf_conversion_prefix}-cluster-.*.tgz  alias=RM_alias
    Should Be True  ${result}
    Set Suite Variable    ${cluster_override_path}

Upload cnf/pvc/net override file
    [Documentation]  get values-override.yaml file from pipeline configuration
    ...   author: min.zheng
    Set Test Variable    ${cnf_override_dir}    ${tl.${5g_or_lte}s[0].cloud_deployment.cnf_override_dir}
    Set Test Variable    ${pvc_override_dir}     ${tl.${5g_or_lte}s[0].cloud_deployment.pvc_override_dir}
    Set Test Variable   ${DU_cnf_override_yaml}   ${tl.${5g_or_lte}s[0].${du_or_dus}.du_cnf_yaml}
    Set Test Variable   ${DU_pvc_override_yaml}   ${tl.${5g_or_lte}s[0].${du_or_dus}.du_pvc_yaml}
    IF    not ${is_LTE}
        Set Test Variable   ${CU_cnf_override_yaml}   ${tl.${5g_or_lte}s[0].cu.cu_cnf_yaml}
        Set Test Variable   ${CU_pvc_override_yaml}   ${tl.${5g_or_lte}s[0].cu.cu_pvc_yaml}
    END
#    ${DU_net_device}=   Get Variable Value       ${DU_net_ens}    ens1f1
    ssh.Connect to   hostname=${${par_prefix}_k8s_addr}   username=${${par_prefix}_k8s_user}
    ...    password=${${par_prefix}_k8s_pwd}  alias=RM_alias
    ${exist_prerequisite_file}=   ssh.file_exists
    ...   remote_path=${target_path}/values-override.${cnf_conversion_prefix}-prerequisite.yaml  connection=RM_alias
    set suite variable   ${exist_prerequisite_file}
    Should Be True   ${exist_prerequisite_file}
    ###    convert and update cnf override yaml file
    ssh.download file
    ...   remote_path=${target_path}/${cnf_override_path}/values-override.yaml
    ...   local_path=${cnf_override_dir}
    ...   connection=RM_alias
    BuiltIn.Sleep   1s
    IF   ${vDU_build_flag} and not ${DU_ACM_based_installation}
        ssh.execute
        ...    sed -i 's/autoGetSecret: false/autoGetSecret: true/g' ${target_path}/${cnf_override_path}/values.yaml
        ...    connection=RM_alias    timeout=60s
    END
    update_yaml_file
    ...    template_file=${${par_prefix}_cnf_override_yaml}
    ...    new_yaml_file=${cnf_override_dir}
    BuiltIn.Sleep   1s
    ssh.upload_file  remote_path=${target_path}/${cnf_override_path}/values-override.yaml
    ...    local_path=${cnf_override_dir}
    ...    connection=RM_alias
    BuiltIn.Sleep   1s
    ###   convert and update pvc override yaml file
    ssh.download file
    ...   remote_path=${target_path}/${pvc_override_path}/values-override.yaml
    ...   local_path=${pvc_override_dir}
    ...   connection=RM_alias
    BuiltIn.Sleep   1s
    update_yaml_file
    ...    template_file=${${par_prefix}_pvc_override_yaml}
    ...    new_yaml_file=${pvc_override_dir}
    BuiltIn.Sleep   1s
    ssh.upload_file  remote_path=${target_path}/${pvc_override_path}/values-override.yaml
    ...    local_path=${pvc_override_dir}
    ...    connection=RM_alias
    BuiltIn.Sleep   1s
    # Currently, restoreData is used as a WA to keep the environment clean
    IF    ${is_LTE}
        ${cmd}    Catenate   sed -i '/storageClassName: lvms-vg1/a\\ \  restoreData: false'
        ...                   ${target_path}/${pvc_override_path}/values-override.yaml
        ssh.execute
        ...    command=${cmd}    connection=RM_alias    timeout=60s
    END
    [Teardown]    Run    command=rm ${cnf_override_dir} && rm ${pvc_override_dir}

Clean old releases and download new aic package
    [Documentation]   Keyword will delete all old 0.250 vCU releases from /tmp at cluster master node
    ...               and download new release. If release folder already exists, download will be skipped
    ...   author: min.zheng
    [Arguments]    ${global_ccr_deployment}=${False}
    Run Keyword If    not (${is_gate} and ${skip_pkg_deletion} and ${vCU_build_flag})
    ...   ssh.execute  command=cd ${pkg_path};rm -rf *    connection=RM_alias    timeout=30s
    ssh.execute    command=mkdir -p ${pkg_path}/${sw_version}     connection=RM_alias    timeout=30s
    ${host_ip}=      Set Variable    ${tl.test_pc.default_ssh_connection_details.addr}
    ${host_name}=    Set Variable    ${tl.test_pc.default_ssh_connection_details.username}
    ${host_pwd}=     Set Variable    ${tl.test_pc.default_ssh_connection_details.password}
    ${scp_remote}=   Set Variable    ${host_name}@${host_ip}:${NFS_build_path}
    Log To Console     Upload zip package started
    scp image to OCP    host_pwd=${host_pwd}    remote_path=${scp_remote}      sw_package=${sw_build}
    ${pkg_exists}=   ssh.file_exists
    ...   remote_path=${target_path}/${sw_build}  connection=RM_alias
    Should Be True     ${pkg_exists}
    ${sha256_check}=    sha256 check    target_file_path=${target_path}/${sw_build}    remote_file_path=${NFS_build_path}/${sw_build}
    ...    connection=RM_alias
    Should Be True     ${sha256_check}    sha256 check failed!
    BuiltIn.Sleep   1 sec
    IF    not ${global_ccr_deployment}
        Run Keyword If    not ${is_gate}
        ...   scp image to OCP    host_pwd=${host_pwd}    remote_path=${scp_remote}/artifacts    sw_package=onBoardingApp.tgz
        ${pkg_exists}=   Run Keyword If    not ${is_gate}   ssh.file_exists
        ...   remote_path=${target_path}/onBoardingApp.tgz  connection=RM_alias
        Run Keyword If    not ${is_gate}    Should Be True     ${pkg_exists}
    END
    BuiltIn.Sleep   1 sec
    # donwload 4gvdu.images.properties.OCP for 4G cloud for uploading image purpose
    IF    ${is_LTE} and not ${global_ccr_deployment}
        scp image to OCP    host_pwd=${host_pwd}    remote_path=${scp_remote}/artifacts    sw_package=4gvdu.images.properties.OCP
        ${pkg_exists}    ssh.file_exists    remote_path=${target_path}/4gvdu.images.properties.OCP  connection=RM_alias
        Should Be True    ${pkg_exists}
    END
    Log To Console     ------> DONE

scp image to OCP
    [Documentation]  Keyword to copy image to OCP from VM mount disk
    ...   author: jie.yin
    [Arguments]   ${host_pwd}     ${remote_path}   ${sw_package}    ${connection}=RM_alias    ${timeout}=900s
    ${scp_cmd}    Set Variable    sshpass -p ${host_pwd} scp ${remote_path}/${sw_package} ${target_path}/${sw_package}
    TRY
        ${output}    ssh.execute    command=${scp_cmd}    connection=${connection}    timeout=${timeout}
        IF   len($output)!=0
            Fail    ${\n}ERROR! scp image command is ${scp_cmd}, it fails due to ${output.strip()}, please check manually!
        END
    EXCEPT    .*timed out while reading stdout.*    type=Regexp    AS    ${error}
        Fail    ${\n}ERROR! scp package fails due to uploading image is not finished in ${timeout}
    EXCEPT     AS    ${error}
        Fail    ${\n}ERROR! scp image command is ${scp_cmd}, it fails due to ${output.strip()}, please check manually!
    END

Upload And Push Image
    [Documentation]  upload image to respository
    ...   author: min.zheng
    Log To Console    Upload image started
    ssh.Connect to   hostname=${${par_prefix}_k8s_addr}   username=${${par_prefix}_k8s_user}
    ...    password=${${par_prefix}_k8s_pwd}  alias=RM_alias
    ${output}=  ssh.execute  command=cd ${target_path}; tar zxvf onBoardingApp.tgz  connection=RM_alias    timeout=120s
    BuiltIn.Sleep   1sec
    Should Not Contain   ${output}    Error is not recoverable
    ssh.upload file    local_path=${CURDIR}/../scripts/loadImages.sh
    ...    remote_path=${target_path}/Image/loadImages.sh
    ...    connection=RM_alias
    # Copy 4gvdu.images.properties.OCP Image to image folder for uploading image purpose
    IF    ${is_LTE}
        ${output}=      ssh.execute
        ...    command=cd ${target_path}; cp 4gvdu.images.properties.OCP Image
        ...    connection=RM_alias    timeout=60s
    ELSE
        ${output}=      ssh.execute
        ...    command=cd ${target_path}; cp onBoardingApp/images.properties.OCP Image
        ...    connection=RM_alias    timeout=60s
    END
    BuiltIn.Sleep   1sec
    Should Not Contain  ${output}   Error
    Run Keyword and Ignore Error   ssh.execute   command=rm -rf /run/user/1000/libpod/tmp/pause.pid   connection=RM_alias   timeout=60
    ${OCP_cmd}    Catenate    cd ${target_path}/Image;
    ...    chmod +x loadImages.sh;
    ...    ./loadImages.sh -n ${${par_prefix}_tenant} -url ${${site}_local_registry_url} -cred '${${site}_local_registry_auth}'
    IF    ${is_LTE}
        ${cmd}=     set variable       ${OCP_cmd} -p 4gvdu.images.properties.OCP
    ELSE
        ${cmd}=     set variable       ${OCP_cmd}
    END
    ${output}=   ssh.execute   command=${cmd}    connection=RM_alias   timeout=1500
    ${image_load_success}    Get Regexp Matches    ${output}    All images load success
    IF    ${image_load_success}
        Log To Console    ------> DONE
    ELSE
        Fail    Load image failed, pls check:\n${output}
    END

Check pods empty
    [Documentation]    Check pod empty
    helm.helm_master_connect
    ...  ${${par_prefix}_k8s_addr}
    ...  22
    ...  ${${par_prefix}_k8s_user}
    ...  ${${par_prefix}_k8s_pwd}
    ${output}=    helm.execute_command_on_master_cluster
    ...   kubectl get pods -n ${${par_prefix}_tenant}
    should be empty    ${output.stdout}


Get pod name
    [Documentation]    Get pod name
    [Arguments]   ${namespace}=${${par_prefix}_tenant}
    ${result}=  kubectl_get_pods
    ...   namespace=${namespace}
    ...   conn=RM_alias
    Should Not Contain Any   ${result}    error  Unauthorized  No resources found  specify the right host or port
    set_all_pods_name    ${result}
    [Teardown]

check ${vCU_vDU} oamep status
    [Documentation]  check if all vdu vcu  oam ep can get ip from host name
    @{CU_oamep_list}   Create List   oam-transportconfig  oam-configurationmanagement  oam-cplaneconfig  oam-faultmanagement
    ...  oam-asm  oam-p  apigw  oam-agent
    @{DU_oamep_list}   Create List   oam-agent  oam-asm  oam-cplaneconfig  oam-faultmanagement
    ...  oam-p  oam-transportconfig
    ${branch}    Get Variable Value    ${branch}    ${EMPTY}
    Run Keyword if    '${branch}'=='vDUCNF24R2'   Append To List    ${DU_oamep_list}    oam-ctp    oam-eaxc
    ${CU_DU}=   Get Substring    ${vCU_vDU}   1
    ssh.Connect to   hostname=${${CU_DU}_k8s_addr}   username=${${CU_DU}_k8s_user}
    ...    password=${${CU_DU}_k8s_pwd}  alias=RM_alias
    FOR  ${ep}  IN  @{${CU_DU}_oamep_list}
        ${output}=     ssh.execute
        ...   command=kubectl get ep -n ${${CU_DU}_tenant} |grep ${ep}     connection=RM_alias    timeout=60s
        Run Keyword and continue on failure   Should Not Be Empty   ${output}
    END
    [Teardown]     ssh.disconnect   connection=RM_alias

Load And Active SCF
    [Arguments]    ${oam_web_ip}    ${filepath}
    [Documentation]   load SCF and active SCF
    ${loop_check}    Set Variable    10
    Log To Console     \n Load And Activate SCF on ${oam_web_ip}
    Log To Console     SCF path: ${filepath}
    Run Keyword And Ignore Error    Start live pod status
    Connect To vDU
        ...    host_ip=${oam_web_ip}
        ...    connection_name=${EMPTY}
        ...    loop_check=${4}
    ${upload_plan_response}=  vdu.upload_plan    ${filepath}
    wait until keyword succeeds  10s  1s
    ...    Upload Plan Operation Should Be Successful  ${upload_plan_response['action_id']}
    ${validate_plan_response}=  vdu.validate_plan   ${upload_plan_response['plan_id']}
    FOR    ${index}     IN RANGE     ${loop_check}
        ${validate_plan_response}=  vdu.get_validate_plan_operation_status
        ...  ${upload_plan_response['plan_id']}
        ...  ${validate_plan_response['action_id']}
        ${validation_status}    Set Variable    ${validate_plan_response['status']}
        ${validation_error}    Set Variable    ${validate_plan_response['error_message']}
        ${validation_id}    Set Variable    ${validate_plan_response['validation_id']}
        IF    '${validate_plan_response['status']}'=='success'
            Log To Console    Validate Plan Success
            BREAK
        ELSE IF    ${index}==${${loop_check}-1}
            Fail
            ...    Validate Plan Failed. Validation status is ${validation_status} and error message is ${validation_error}
        ELSE
            BuiltIn.Sleep    1s
        END
    END
    ${validation_result}    vdu.get_staged_plan_validation_results
    ...    plan_id=${upload_plan_response['plan_id']}
    ...    validation_id=${validation_id}
    ${check_validation_result}    Check Plan Validation Errors    ${validation_result}
    IF    not ${check_validation_result}
        Fail    Validation errors visible!!!
    END
    ${activate_plan_response}=  vdu.activate_plan  ${upload_plan_response['plan_id']}
    ${dptrace_flag}=   Get Variable Value       ${dptrace_flag}    None
    Run Keyword And Ignore Error      Run keyword if    '${dptrace_flag}'=='True'    Start l2rt dptrace
    wait until keyword succeeds  10m  20s  Activate Plan Operation Should Be Successful
    ...  ${upload_plan_response['plan_id']}
    ...  ${activate_plan_response['id']}
    [Teardown]  Run Keyword And Ignore Error    Run Keywords    vdu.disconnect
    ...    AND    Stop live pod status

Upload Plan Operation Should Be Successful
     [Arguments]  ${upload_action_id}
    [Documentation]   checking upload plan operation status should be successful
    ...    *AUTHOR*  calla.wang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | upload_action_id | yes | upload action id, get from upload_plan |
    ...    *RETURN VALUE*
    ...    None
    ${upload_operation_response}=  vdu.get_upload_plan_operation_status  ${upload_action_id}
    should be equal as strings  ${upload_operation_response['status']}  success
    Log To Console    Upload Plan Success

Validate Plan Operation Should Be Successful
    [Arguments]  ${plan_id}  ${action_id}
    [Documentation]   checking validate plan operation status should be successful
    ...    *AUTHOR*  calla.wang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | plan_id | yes | the plan file id, get from upload_plan |
    ...    | action_id | Yes | the validate action id, get from validate_plan |
    ...    *RETURN VALUE*
    ...    None
    ${validate_plan_response}=  vdu.get_validate_plan_operation_status  ${plan_id}  ${action_id}
    should be equal as strings  ${validate_plan_response['status']}  success
    Log To Console    Validate Plan Success

Fix SCF Validation Errors Should Be Successful
    [Arguments]  ${plan_id}  ${action_id}
    ${fix_err_response}=   vdu.get_fix_vdu_staged_plan_operation_status  ${plan_id}  ${action_id}
    should be equal as strings  ${fix_err_response['status']}  success
    Log To Console    Fix SCF Errors Success

Activate Plan Operation Should Be Successful
    [Arguments]  ${plan_id}  ${action_id}
    [Documentation]   checking activate plan operation status should be successful
    ...    *AUTHOR*  calla.wang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | plan_id | yes | the plan file id, get from upload_plan |
    ...    | action_id | Yes | the activate action id, get from activate_plan |
    ...    *RETURN VALUE*
    ...    None
    ${activate_plan_response}=  vdu.get_activate_plan_operation_status  ${plan_id}  ${action_id}   60
    should be equal as strings  ${activate_plan_response['status']}  success
    Log To Console    Activate Plan Success
    Set test variable   ${activate_plan_response}
    [Teardown]    Run Keyword And Ignore Error    Run Keyword If   'Unauthorized' in '${activate_plan_response['Reason']}'
    ...    Run Keywords   Run Keyword And Ignore Error  vdu.disconnect
    ...    AND   Connect To vDU
    ...    host_ip=${${par_prefix}_WEBUI_IP}
    ...    connection_name=${EMPTY}
    ...    loop_check=${4}

Check Cell setup for vDU
    [Documentation]    Do some common thing for every postcondition of cases
    [Arguments]    ${loop_check}=11
    ${oam_web_ip}   set variable if   ':' in '''${DU_WEBUI_IP}'''   [${DU_WEBUI_IP}]    ${DU_WEBUI_IP}
    ${lib_used}    Set Variable If    ${is_LTE}    lte_vdu    vdu
    IF    ${is_LTE}
        Wait Until Keyword Succeeds    2min    10s   ${lib_used}.connect to
        ...    host=${oam_web_ip}
        ...    port=${EMPTY}
        ...    username=Nemuadmin
        ...    password=Nokia@123
        ...    secure=True
    ELSE
        Connect To vDU
        ...    host_ip=${oam_web_ip}
        ...    connection_name=${EMPTY}
        ...    loop_check=${4}
    END
    FOR    ${index}    IN RANGE    ${loop_check}
        TRY
            IF    ${is_LTE}
                ${cell_status}=   lte_vdu.get_cells_info
                ${avail_out}=  Get From Dictionary  ${cell_status['lncel'][0]}    availabilityStatus
                ${oper_out}=  Get From Dictionary  ${cell_status['lncel'][0]['basicCell']}    operationalState
            ELSE
                ${cell_status}=   vdu.get_vdu_cells_status
                ${avail_out}=  Get From Dictionary  ${cell_status[0]}    availability_status
                ${oper_out}=  Get From Dictionary  ${cell_status[0]}    operational_state
            END
            Should Be Equal  ${avail_out}  on line  ignore_case=True
            Should Be Equal  ${oper_out}  enabled   ignore_case=True
            BREAK
        EXCEPT    AS    ${error}
            ${err_msg}    Set Variable    ${error.replace('"', '')}
            IF    "Machine-to-Machine interface was disabled" in """${err_msg}""" or ${index}==${${loop_check}-1}
                Fail    vdu.get_vdu_cells_status failed due to ${error}
            ELSE IF    ${index}!=${${loop_check}-1}
                BuiltIn.Sleep    30s
                CONTINUE
            END
        END
    END
    Run Keyword and Ignore Error    Init Pods Filter
    [Teardown]  Run Keyword And Ignore Error    vdu.disconnect

Record 5G attach log on l2rt for vdu
    [Documentation]  Record attach log in l2rt log
    ssh.Connect to   hostname=${DU_k8s_addr}   username=${DU_k8s_user}
    ...    password=${DU_k8s_pwd}  alias=RM_alias
    ${output}=    csn.execute    command=cd /tmp/${tl.tl_cloud_topology}     connection=RM_alias    timeout=30s
    ${output}=    Strip String    ${output}
    run keyword if    'No such file or directory' in '${output}'
    ...     csn.send_command    command=cd /tmp;mkdir ${tl.tl_cloud_topology}    connection=RM_alias
    ...     ELSE     csn.send_command    command=rm -f /tmp/${tl.tl_cloud_topology}/l2rt_ue_attach.log   connection=RM_alias
    set test variable   ${up_pod}   ${EMPTY}
    Get pod name   namespace=${DU_tenant}
    ${listening_pod}   set variable if   '${up_pod}'!='${EMPTY}'    ${up_pod}   ${l2rt_pod}
    ${attach_start_timestamp}=  ssh.execute  command=date +%d.%m' '%H:%M:%S.%N| cut -b 1-14  connection=RM_alias    timeout=30s
    set suite variable  ${attach_start_timestamp}
    ${container_name}    Set Variable If  '${DU_tenant}' in '${listening_pod}'
    ...    ctr-${DU_tenant}-l2rt    ctr-l2rt
    ssh.send_command
    ...  command=kubectl logs --since=1s -f ${listening_pod} -c ${container_name} -n ${DU_tenant}>/tmp/${tl.tl_cloud_topology}/l2rt_ue_attach.log
    ...  connection=RM_alias

Verify 5G attach on l2rt for vdu
   [Documentation]  verify attach result on l2rt log
    ssh.Connect to   hostname=${DU_k8s_addr}   username=${DU_k8s_user}
    ...    password=${DU_k8s_pwd}  alias=RM_alias
    set test variable   ${up_pod}   ${EMPTY}
    Get pod name   namespace=${DU_tenant}
    ${attach_end_timestamp}=  ssh.execute  command=date +%d.%m' '%H:%M:%S.%N| cut -b 1-14  connection=RM_alias    timeout=30s
    set suite variable  ${attach_end_timestamp}
    ${listening_pod}   set variable if   '${up_pod}'!='${EMPTY}'    ${up_pod}   ${l2rt_pod}
    Log To Console   ---> Attach start time is ${attach_start_timestamp} and end time is ${attach_end_timestamp}
    ${container_name}   Set Variable If  '${DU_tenant}' in '${listening_pod}'
    ...    ctr-${DU_tenant}-l2rt    ctr-l2rt
    ssh.send_command
    ...   command=ps -ef|grep "kubectl logs --since=1s -f ${listening_pod} -c ${container_name} -n ${DU_tenant}"|awk '{print $2}'|xargs kill -9
    ...    connection=RM_alias
    ${output}   ssh.execute    command=cat /tmp/${tl.tl_cloud_topology}/l2rt_ue_attach.log|grep "UE attached"|grep -av grep
    ...   connection=RM_alias    timeout=60s
    BuiltIn.Sleep   2s
    ssh.download file
    ...  /tmp/${tl.tl_cloud_topology}/l2rt_ue_attach.log  ${LOG_PATH}/${sw_version}_${tl.tl_cloud_topology}_l2rt_ue_attach.log   connection=RM_alias
    should contain    ${output}    UE attached
    [Teardown]    ssh.disconnect   connection=RM_alias

Verify RF status on WebEm
    [Documentation]  check rf status on webem
    [Arguments]      ${log_to_console}=${False}    ${loop_check}=30
    ${oam_web_ip}   set variable if   ':' in '''${DU_WEBUI_IP}'''   [${DU_WEBUI_IP}]    ${DU_WEBUI_IP}
    ${rf_versions_map_exist}    Run Keyword And Return Status    Variable Should exist    ${RF_VERSIONS_MAP}
    Connect To vDU
    ...    host_ip=${oam_web_ip}
    ...    connection_name=${EMPTY}
    FOR    ${index}    IN RANGE    ${loop_check}
        TRY
            ${cell_status}=   vdu.get_rmods_status
            ${avail_out}=  Get From Dictionary  ${cell_status[0]}    availability_status
            ${oper_out}=  Get From Dictionary  ${cell_status[0]}    operational_state
            Run Keyword If    ${log_to_console}    Log to Console    RF is ${avail_out}
            Should Be Equal  ${avail_out}  on line  ignore_case=True    msg=RF is ${avail_out}
            Should Be Equal  ${oper_out}  enabled  ignore_case=True
            IF    ${rf_versions_map_exist}
                IF    '${RF_VERSIONS_MAP['${cell_status[0]['product_name']}']}'!='not_set'
                    ${build_version}    Get From Dictionary  ${cell_status[0]}    active_sw_build
                    ${msg}    Catenate    \nRF version on site: ${build_version} does not match with the
                    ...    version: ${RF_VERSIONS_MAP['${cell_status[0]['product_name']}']} from WFT, manually check needed
                    Should Be Equal    ${build_version}    ${RF_VERSIONS_MAP['${cell_status[0]['product_name']}']}    ${msg}    ignore_case=True
                ELSE
                    Log    \nSkip RF sw version check as the target version is not given!!!    level=WARN    console=True
                END
            END
            BREAK
        EXCEPT    AS    ${error}
            ${err_msg}    Set Variable    ${error.replace('"', '')}
            ${condition}    Evaluate
            ...   "AssertionError" in """${err_msg}""" or "KeyError" in """${err_msg}""" or "RF is" in """${err_msg}"""
            ${web_reconnect_condition}    Run Keyword And Return status
            ...    Should Contain Any    ${err_msg}
            ...    Token expired or invalid    Connection aborted    Refresh token failed
            IF    ${condition} and ${index}!=${${loop_check}-1}
                BuiltIn.Sleep    60s
                CONTINUE
            ELSE IF    ${web_reconnect_condition}
                Connect To vDU
                ...    host_ip=${oam_web_ip}
                ...    connection_name=${EMPTY}
                BuiltIn.Sleep    60s
                CONTINUE
            ELSE IF    "list index out of range" in """${err_msg}""" and ${index}!=${${loop_check}-1}
                BuiltIn.Sleep    20s
                CONTINUE
            ELSE
                Log    Check RF state failed due to ${error}    WARN
                Fail
            END
        END
    END
    [Teardown]    Run Keyword And Ignore Error    vdu.disconnect

Get Pod status
    [Documentation]  Check pods status
    [Arguments]  ${par_prefix}=${par_prefix}
    ${conn}=   helm.helm_master_connect
    ...  ${${par_prefix}_k8s_addr}
    ...  ${${par_prefix}_k8s_port}
    ...  ${${par_prefix}_k8s_user}
    ...  ${${par_prefix}_k8s_pwd}
    ${output}=  helm.execute_command_on_master_cluster
    ...    kubectl get pods -n ${${par_prefix}_tenant}
    Log To Console    ${output}
    [Teardown]    helm.helm_master_close    ${conn}

Get Events
    [Documentation]  Check events
    ${conn}=  helm.helm_master_connect
    ...  ${${par_prefix}_k8s_addr}
    ...  ${${par_prefix}_k8s_port}
    ...  ${${par_prefix}_k8s_user}
    ...  ${${par_prefix}_k8s_pwd}
    ${output}=  helm.execute_command_on_master_cluster
    ...    kubectl get events --sort-by=firstTimestamp -n ${${par_prefix}_tenant}
    Run
    ...    echo "\n>>>>>>PODs EVENTs LOG:<<<<<\n" >> ${LOG_PATH}/gnb_startup_failure.log
    Append To File    path=${LOG_PATH}/gnb_startup_failure.log    content=${output}\n\n
	[Teardown]    helm.helm_master_close    ${conn}

Get describe log
    [Documentation]  this keyword is used to get the describe log
    ssh.Connect to   hostname=${${par_prefix}_k8s_addr}   username=${${par_prefix}_k8s_user}
    ...    password=${${par_prefix}_k8s_pwd}  alias=pod_alias
    ssh.Send command
    ...  command=rm -rf /tmp/${${par_prefix}_tenant}-describe.log
    ...  connection=pod_alias
    ssh.Send command
    ...  command=kubectl describe pod -n ${${par_prefix}_tenant} > /tmp/${${par_prefix}_tenant}-describe.log
    ...  connection=pod_alias
    BuiltIn.Sleep    5s
    ssh.download file
    ...  remote_path=/tmp/${${par_prefix}_tenant}-describe.log
    ...  local_path=${LOG_PATH}/${par_prefix}_describe_${timestamp}.log
    ...  connection=pod_alias
    ssh.Disconnect   connection=pod_alias
	Log To Console    describe log captured

OE Authentication
    [Documentation]   This keyword should be used for OE Authentication.
    ...    author: lisa.yang
    [Arguments]  ${par_prefix}=None
    ssh.Connect to   hostname=${${par_prefix}_k8s_addr}   username=${${par_prefix}_k8s_user}
    ...    password=${${par_prefix}_k8s_pwd}  alias=RM_alias
    ssh.send_command    command= kubectl cluster-info | grep -o "https:.*6443"    connection=RM_alias
    ${output}=    ssh.read_output    connection=RM_alias
    ${domain}    Get Substring    ${output}   0
    ssh.send_command    command=oc login -u nokiaadmin -p nokiaadmin ${domain}    connection=RM_alias
    ${result}=   ssh.read_output    connection=RM_alias
    Should Contain    ${result}    successful  msg=OE authentication failed!  values=False
    Run keyword if    '${par_prefix}'=='CU'    run keywords    ssh.send_command
    ...    command=oc adm policy add-scc-to-user privileged -z default -n ${${par_prefix}_tenant}
    ...    connection=RM_alias
    ...    AND    ssh.send_command    command=oc adm policy add-scc-to-user privileged -z kubeapi-data-provider -n ${${par_prefix}_tenant}
    ...    connection=RM_alias
    ...    AND    ssh.send_command    command=oc adm policy add-scc-to-user privileged -z post-check -n ${${par_prefix}_tenant}
    ...    connection=RM_alias
    ...    AND    ssh.send_command    command=oc adm policy add-scc-to-user privileged -z healing-controller -n ${${par_prefix}_tenant}
    ...    connection=RM_alias

Check if linuxptp-daemon pod is running
    [Documentation]  Check if linuxptp-daemon pod is running after restarting on OE
    ssh.Connect to   hostname=${DU_k8s_addr}   username=${DU_k8s_user}   password=${DU_k8s_pwd}  alias=RM_alias
    ssh.send_command  command=kubectl get pods -n openshift-ptp | grep linuxptp-daemon|awk '{print $3}'   connection=RM_alias
    ${output} =   ssh.read_output   connection=RM_alias
    Should Contain   ${output}   Running
    [Teardown]   ssh.disconnect    connection=RM_alias

Verify vDU_OAM F1 Setup
    [Documentation]   This keyword is used to Get the X2 link status by admin api to CU.
    ...    author: kongshuai.fan
    [Arguments]  ${value}=available
    ${mrbts_id}    Set Variable    ${tl.du_scf_variables['mrbts']}
    ${nrbts_id}    Set Variable    ${tl.du_scf_variables['nrbts']}
    Connect To vDU    host_ip=${DU_WEBUI_IP}    loop_check=${4}
    ${f1CLinkStatusDU}        vdu.search_parameter_of_current_plan    mo_dn=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRDU-1
    ...                       para_name=f1CLinkStatusDU    vdu_connection=du_admin
    Should Be Equal As Strings    ${f1CLinkStatusDU}    ${value}    ignore_case=True
    [Teardown]  Run Keyword And Ignore Error  vdu.disconnect    vdu_connection=du_admin

Verify Link Status on OAM_CU
    [Documentation]   This keyword is used to Get the E1/X2/NG link status on OAM CU.
    [Arguments]    ${expected_parameter_value_dict}    ${oam_ip}=${CU_WEBUI_IP}    ${loop_check}=1
    Connect To vCU    host_ip=${oam_ip}
    ...    alias=cu_admin
    ...    loop_check=${4}
    &{actual_parameter_value_dict}    Create Dictionary
    FOR    ${index}    IN RANGE    ${loop_check}
        TRY
            FOR     ${parameter_name}    ${parameter_value}    IN    &{expected_parameter_value_dict}
                ${summary}    coam_cu.search_parameters_of_current_plan
                ...           parameter_name=${parameter_name}
                ...           connection=cu_admin
                ${status}    set variable    ${summary['items'][0]}
                ${status}    set variable    ${status['parameter']['simple_parameter']['value']}
                Set to Dictionary    ${actual_parameter_value_dict}    ${parameter_name}    ${status}
                Should Be Equal    ${status}    ${parameter_value}
            END
            RETURN    ${True}    ${actual_parameter_value_dict}
        EXCEPT    AS    ${error}
            ${err_msg}    Set Variable    ${error.replace('"', '')}
            IF    "404 Client Error" in """${err_msg}"""
                Fail    CU is in uncommissioned status: ${error}
            ELSE IF    ${index}!=${${loop_check}-1}
                BuiltIn.Sleep    30s
                CONTINUE
            ELSE
                RETURN    ${False}    ${actual_parameter_value_dict}
            END
        END
    END

    [Teardown]    Run Keyword And Ignore Error    coam_cu.Disconnect    connection=cu_admin

Verify E1 Status on OAM_CU
    [Arguments]    ${oam_ip}=${CU_WEBUI_IP}    ${loop_check}=1
    ${e1_link_status}    ${e1_link_result}    Verify Link Status on OAM_CU
    ...                                        expected_parameter_value_dict=&{e1_link_dict}
    ...                                        oam_ip=${oam_ip}
    ...                                        loop_check=${loop_check}
    IF    not ${e1_link_status}
        Fail    E1 link status is not correct, the actual result is ${e1_link_result}
    ELSE
        Log    E1 link status is correct
    END

Verify CU_OAM NG Setup
    [Documentation]   This keyword is used to Get the NG link status.
    [Arguments]    ${oam_ip}=${CU_WEBUI_IP}    ${loop_check}=1
    ${ng_link_status}    ${ng_link_result}    Verify Link Status on OAM_CU
    ...                                       expected_parameter_value_dict=&{ng_link_dict}
    ...                                       oam_ip=${oam_ip}
    ...                                       loop_check=${loop_check}
    IF    not ${ng_link_status}
        Fail    NG link status is not correct, the actual result is ${ng_link_result}
    ELSE
        Log    NG link status is correct
    END

Verify CU_OAM X2 Setup
    [Documentation]   This keyword is used to Get the X2 link status by admin api to CU.
    [Arguments]    ${oam_ip}=${CU_WEBUI_IP}    ${loop_check}=1
    ${x2_link_status}    ${x2_link_result}    Verify Link Status on OAM_CU
    ...                                       expected_parameter_value_dict=&{x2_link_dict}
    ...                                       oam_ip=${oam_ip}
    ...                                       loop_check=${loop_check}
    IF    not ${x2_link_status}
        Fail    X2 link status is not correct, the actual result is ${x2_link_result}
    ELSE
        Log    X2 link status is correct
    END

Check Cell Setup after ${par_prefix} reset
    [Documentation]  This keyword is used to reset vcu or vdu on webui and then check if F1/x2/e1 link can be automatically recovered
    ${webui_connection}=  Run Keyword And Return Status  Run Keyword If  ${vDU_build_flag}
    ...  Connect To vCU  host_ip=${${par_prefix}_WEBUI_IP}  alias=web_connection  loop_check=${4}
    ...  ELSE IF  ${vCU_build_flag}  Connect To vDU
    ...  host_ip=${${par_prefix}_WEBUI_IP}    connection_name=web_connection    loop_check=${4}
    ${site_reset}=  Run Keyword And Return Status  Run Keyword If  ${vDU_build_flag} and ${webui_connection}
    ...  wait until keyword succeeds  3x  5s  coam_cu.reset_cu  connection=web_connection
    ...  ELSE IF  ${vCU_build_flag} and ${webui_connection}  wait until keyword succeeds  3x  5s  vdu.reset_vdu  vdu_connection=web_connection
    ...  ELSE  PASS EXECUTION  ${\n}!!!Warning!!! ${par_prefix} admin connection failed, additional site reset case skipped ${\n}  WARN
    ${site_connection}=  Run Keyword And Return Status  Run Keyword If  ${site_reset}  Run Keywords
    ...  Connect To vDU  host_ip=${DU_WEBUI_IP}  connection_name=web_connection  loop_check=${4}
    ...  AND  Connect To vCU    host_ip=${CU_WEBUI_IP}    alias=cu_admin    loop_check=${4}
    ...  ELSE  PASS EXECUTION
    ...  ${\n}!!!Warning!!! ${${par_prefix}_WEBUI_IP} resetting failed, additional site reset case skipped ${\n}  WARN
    ${f1_connection_dropped}=  Run Keyword And Return Status  Run Keyword If  ${site_connection}
    ...  wait until keyword succeeds  4min  20s  Verify vDU_OAM F1 Setup  value=unavailable
    ...  ELSE  PASS EXECUTION  ${\n}!!!Warning!!! ${par_prefix} admin connection failed, additional site reset case skipped ${\n}  WARN
    ${e1_connection_available}=   Run Keyword And Return Status  Run Keyword If  ${f1_connection_dropped}
    ...  Verify E1 Status on OAM_CU   oam_ip=${CU_WEBUI_IP}    loop_check=20
    ...  ELSE  PASS EXECUTION  ${\n}!!!Warning!!! f1 didn't dropped, additional site reset case skipped ${\n}  WARN
    ${rf_online}=  Run Keyword And Return Status  Run Keyword If  ${f1_connection_dropped} and ${e1_connection_available}
    ...  Verify RF status on WebEm    loop_check=5
    ...  ELSE  PASS EXECUTION  ${\n}!!!Warning!!! f1 didn't dropped or e1 unavailable, additional site reset case skipped ${\n}  WARN
    ${pod_status} =  Run Keyword And Return Status  Run Keyword If  ${rf_online}
    ...  wait until keyword succeeds  4min  20s    Check Containers status after deployment    par_prefix=${par_prefix}
    ...  ELSE  PASS EXECUTION  ${\n}!!!Warning!!! RF setup failed, additional site reset case skipped${\n}  WARN
    ${f1_status} =  Run Keyword And Return Status      Run Keyword If  ${pod_status}
    ...  wait until keyword succeeds  12min  1min  Verify vDU_OAM F1 Setup
    ...  ELSE  PASS EXECUTION  ${\n}!!!Warning!!! ${par_prefix} pods status is not correct, additional site reset case skipped ${\n}  WARN
    Run Keyword If    ${vCU_build_flag} and '${f1_status}'=='False'    Run Keywords
    ...  Connect To vDU
    ...  host_ip=${${par_prefix}_WEBUI_IP}  connection_name=web_connection
    ...  AND  Run Keyword And Ignore Error    wait until keyword succeeds  3x  5s  vdu.reset_vdu  vdu_connection=web_connection
    ...  AND  PASS EXECUTION  ${\n}!!!Warning!!! vDU site reset is triggered to recover PR743047, additional site reset case skipped ${\n}  WARN
    ...  ELSE IF   '${f1_status}'=='False'     Fail     F1 setup failed!!!
    IF    '${is_TDD}' == 'False'
        Verify CU_OAM X2 Setup    loop_check=20
    END
    ${additional_case_status}=  Run Keyword And Return Status  Check Cell setup for vDU    loop_check=8
    Set Suite Variable  ${additional_case_status}
    Should Be True  ${additional_case_status}    Cell Setup failed after ${par_prefix} reset!!!

Generate sshkey for VM
    [Documentation]  Generate sshkey for VM and this key will be used for scp cmd in upload pkg process
    ...   author: Yin Jie
    ssh.Connect to   hostname=${${par_prefix}_k8s_addr}   username=${${par_prefix}_k8s_user}
    ...    password=${${par_prefix}_k8s_pwd}  alias=RM_alias
    ${cleanup_key_cmd}     set variable    ssh-keygen -R ${tl.test_pc.default_ssh_connection_details.addr}
    ${generate_key_cmd}    set variable    ssh-keyscan -t rsa ${tl.test_pc.default_ssh_connection_details.addr} >> ~/.ssh/known_hosts
    ${output}   ssh.execute    command=cat ~/.ssh/known_hosts |grep ${tl.test_pc.default_ssh_connection_details.addr}
    ...    connection=RM_alias    timeout=60s
    ${line}    get line count    ${output}
    Run Keyword If    '${line}' != '0'    ssh.execute    command=${cleanup_key_cmd}    connection=RM_alias    timeout=60s
    ssh.execute    command=${generate_key_cmd}    connection=RM_alias    timeout=60s
    [Teardown]  ssh.disconnect   connection=RM_alias

Start live pod status
    [Documentation]  this keyword is used to get live pod status
    ...   author: tong weichao
    ssh.Connect to   hostname=${${par_prefix}_k8s_addr}   username=${${par_prefix}_k8s_user}
    ...    password=${${par_prefix}_k8s_pwd}  alias=pod_alias
    ssh.Send command
    ...  command=kubectl get pods -n ${${par_prefix}_tenant} -w > /tmp/${${par_prefix}_tenant}-live-pod-status.txt &
    ...  connection=pod_alias
    Log to console   Get live pod status started

Stop live pod status
    [Documentation]  this keyword is used to stop live pod status
    ...   author: tong weichao
    ${logname}       Replace String    ${TEST_NAME}    ${SPACE}    _
    ssh.Connect to   hostname=${${par_prefix}_k8s_addr}   username=${${par_prefix}_k8s_user}
    ...    password=${${par_prefix}_k8s_pwd}  alias=pod_alias
    ssh.download file
    ...  remote_path=/tmp/${${par_prefix}_tenant}-live-pod-status.txt
    ...  local_path=${LOG_PATH}/${par_prefix}_${logname}_live-pod-status_${timestamp}.txt
    ...  connection=pod_alias
    ssh.Disconnect   connection=pod_alias
    Log to console    Get live pod status stopped

Check vDU RF Number
    IF    ${is_LTE}
        ${cell_info}    lte_vdu.get_cells_info
        ${LTE_CELL_length}   Get Length    ${cell_info}
        ${rmod_list}    lte_vdu.get_rmods_info
        Set Suite Variable    ${LTE_CELL_length}
    ELSE
        ${cell_info}    vdu.get_vdu_cell_id
        ${5G_CELL_length}   Get Length    ${cell_info}
        ${rmod_list}    vdu.get_rmods_status
        Set Suite Variable   ${5G_CELL_length}
    END
    ${rf_number}	  Get Length    ${rmod_list}
    Set Suite Variable    ${rf_number}
    @{LTE_RF_LIST}    Create List
    @{5G_RF_LIST}     Create List
    ${5G_LTE}     Set Variable If    ${is_LTE}    LTE    5G
    Append To List        ${${5G_LTE}_RF_LIST}    RF${rf_number}
    Set Suite Variable    ${${5G_LTE}_RF_LIST}
    ${gnb_enb}    Set Variable If    ${is_LTE}    enb    gnb
    ${vdu_lib}    Set Variable If    ${is_LTE}    lte_vdu    vdu
    IF    ${FHGW_Exist}
        Log to console    --> UE type is ${UE} and the gnb is ${tl.${5g_or_lte}s[0].${du_or_dus}.fhgws[0].rus[0].length} cell(s) configuration \n
    ELSE IF    ${RANNIC_Exist}
        Log to console
        ...    --> UE type is ${UE} and the ${gnb_enb} is ${tl.${5g_or_lte}s[0].${du_or_dus}.rannics[0].rus[0].length} cell(s) configuration \n
    ELSE
        Log to console    --> UE type is ${UE} and the gnb is ${tl.${5g_or_lte}s[0].${du_or_dus}.rus[0].length} cell(s) configuration \n
    END
    RETURN    ${cell_info}
    [Teardown]    Run Keyword And Ignore Error    ${vdu_lib}.disconnect

Get PV status
    [Documentation]  this keyword is used to get pv status
    ...   author: tong weichao
    ssh.Connect to   hostname=${${par_prefix}_k8s_addr}   username=${${par_prefix}_k8s_user}
    ...    password=${${par_prefix}_k8s_pwd}  alias=pv_alias
    ${bod_num}    ssh.execute    command=kubectl get pv|grep -ic Bound    connection=pv_alias    timeout=10s
    Log to console    Bound pv num is: ${bod_num}
    ${rel_num}    ssh.execute    command=kubectl get pv|grep -ic Released    connection=pv_alias    timeout=10s
    ${rel_num}    Strip String   ${rel_num}
    ${status}     Run Keyword And Return Status     Should Not Be Equal       ${rel_num}     0
    Run Keyword If    ${status}    Run Keywords
    ...  Log to console    Released pv num is: ${rel_num}, start to patch pv....
    ...  AND   Del Released Pv    connection=pv_alias
    ssh.Disconnect    connection=pv_alias

Clean tmp after test
    ${CU_DU}    Set Variable If   '${vCU_build_flag}'=='True'    CU    DU
    ssh.Connect to   hostname=${${CU_DU}_k8s_addr}   username=${${CU_DU}_k8s_user}
        ...    password=${${CU_DU}_k8s_pwd}  alias=RM_alias
    ssh.execute    rm ${pkg_path}/${sw_version}/*.zip  connection=RM_alias    timeout=30s
    ssh.execute    rm -rf ${pkg_path}/${sw_version}/Image  connection=RM_alias    timeout=30s
    [Teardown]   ssh.disconnect   connection=RM_alias

Check Podman Login
    [Documentation]  check Podman Login
    [Arguments]    ${hostname}=${${par_prefix}_k8s_addr}   ${username}=${${par_prefix}_k8s_user}
    ...            ${password}=${${par_prefix}_k8s_pwd}
    ssh.Connect to   hostname=${hostname}   username=${username}    password=${password}  alias=Podman_alias
    ${username}=   ssh.execute   command=oc whoami    connection=Podman_alias    timeout=60s
    ${username}=    Strip String    ${username}
    ${token}=   ssh.execute   command=oc whoami -t    connection=Podman_alias    timeout=60s
    ${token}=    Strip String    ${token}
    ${registry}    Set Variable    image-registry.openshift-image-registry.svc:5000
    ${podmancmd}    set variable    podman login ${registry} -u ${username} -p ${token} --tls-verify=false --log-level=debug 2>&1
    ${podoutput}=   ssh.execute   command=${podmancmd}    connection=Podman_alias    timeout=60s
    ${result}=    Run Keyword And Return Status     Should Contain    ${podoutput}    Login Succeeded
    Run Keyword If    not ${result}    Log To Console    Podman login log: \n ${podoutput}
    RETURN     ${result}
    [Teardown]   ssh.disconnect   connection=Podman_alias

Del Released Pv
    [Documentation]  delete released pv
    [Arguments]    ${connection}
    ${pv_check_loop}    Set Variable    5
    ${pv_sta}    ssh.execute    command=kubectl get pv|grep -i Released   connection=${connection}    timeout=60s
    Log    released pvs status: /n ${pv_sta}
    ssh.upload file    local_path=${CURDIR}/../scripts/pv_clear.sh
    ...    remote_path=/tmp/${tl.tl_cloud_topology}/pv_clear.sh
    ...    connection=${connection}
    ssh.execute  command=chmod +x /tmp/${tl.tl_cloud_topology}/pv_clear.sh  connection=${connection}    timeout=30s
    FOR    ${index}   IN RANGE    1    ${pv_check_loop}
        ${pv_res}    ssh.execute  command=. /tmp/${tl.tl_cloud_topology}/pv_clear.sh    connection=${connection}    timeout=1200s
        IF    "result is" in """${pv_res}"""
            BREAK
        ELSE IF    ${index} == ${${pv_check_loop}-1}
            Log    Failed to delete released pv after ${pv_check_loop} retries, continue PV check    WARN
        ELSE
            ${left_retries}   Evaluate    ${pv_check_loop} - ${index} - 1
            Log to console    Failed to delete released pv, ${left_retries} retries left...
            BuiltIn.Sleep   10s
        END
    END
    BuiltIn.Sleep   90s
    ${release_num}    ssh.execute    command=kubectl get pv|grep -ic Released    connection=${connection}    timeout=60s
    ${release_num}    Strip String   ${release_num}
    Should Be Equal       ${release_num}     0
    Log to console    Released pv have been deleted successfully

Debug Podman Login
    [Documentation]  Debug Podman Login, get env info
    ssh.Connect to   hostname=${${par_prefix}_k8s_addr}   username=${${par_prefix}_k8s_user}
    ...    password=${${par_prefix}_k8s_pwd}  alias=Podman_alias
    ${podmaninfo}=   ssh.execute   command=podman info    connection=Podman_alias    timeout=30s
    Log    Podman info log: \n ${podmaninfo}
    ${envinfo}=   ssh.execute   command=env    connection=Podman_alias    timeout=30s
    Log    Podman env log: \n${envinfo}
    [Teardown]   ssh.disconnect   connection=Podman_alias

Init Pods Filter
    [Documentation]  Filter Out Init Pod
    ssh.Connect to   hostname=${${par_prefix}_k8s_addr}   username=${${par_prefix}_k8s_user}
    ...    password=${${par_prefix}_k8s_pwd}  alias=init_alias
    ${output}=  ssh.execute   command=oc get pods -n ${${par_prefix}_tenant} | grep Init    connection=init_alias    timeout=60s
    ${init_pod_num}=  ssh.execute   command=oc get pods -n ${${par_prefix}_tenant} | grep -c Init    connection=init_alias    timeout=60s
    ${init_pod_num}=    Strip String    ${init_pod_num}
    ${message}=    set variable     ${\n}!!!Warning!!! There are init pods in vDU after commissioning finished:${\n}
    Run Keyword If    '${init_pod_num}' != '0'  Run Keywords
    ...  Log To Console    ${message}    level=WARN
    ...  AND    Log To Console    ${output}
    [Teardown]    ssh.disconnect   connection=init_alias

Helm Install with K8s Reconnection
    [Documentation]  Helm install command will be executed again after k8s server reconnection
                 ...    if command exeuction failed
    [Arguments]  ${release_name}   ${chart_path}    ${value_files}    ${install_timeout}    ${connection}    ${step_error}    &{values}
    FOR    ${index}    IN RANGE    2
        ${output}    helm.helm_install
        ...  ${release_name}
        ...  ${chart_path}
        ...  ${${par_prefix}_tenant}
        ...  value_files=${value_files}
        ...  install_timeout=${install_timeout}
        ...  fail_on_error=False
        ...  &{values}
        IF    '${output.status}' == '0'
            BREAK
        END
        ${command_timeout}    Get Regexp Matches    ${output.stderr.strip()}    Command(OutputTimeout|Execution)Error
        IF    ${command_timeout}
            Log    ${step_error} failed, start to reconnect ${par_prefix}!!!    WARN
            helm.helm_master_close    ${connection}
            helm.helm_master_connect
            ...  ${${par_prefix}_k8s_addr}
            ...  22
            ...  ${${par_prefix}_k8s_user}
            ...  ${${par_prefix}_k8s_pwd}
            CONTINUE
        END
        Log    ${output.stderr.strip()}    WARN
        Run
        ...    echo "\n>>>>>>Below error logs are about helm install:<<<<<\n" >> ${LOG_PATH}/gnb_startup_failure.log
        Append To File    path=${LOG_PATH}/gnb_startup_failure.log    content=${output.stderr.strip()}\n\n
        Fail    ${step_error} failed!!!
    END

Selenium Login And Version Check On WebEM
    [Documentation]    This keyword is used to perform login and software version verification on the WebEM by selenium library
    ...    for both CU and vDU systems.It dynamically selects the appropriate Selenium library (`selenium_cu` or `selenium_vdu`)
    ...    based on the `par_prefix` variable
    [Arguments]    ${par_prefix}    ${loop_check}=3
    ${selenium_lib}    Set Variable If    "${par_prefix}"=="CU"    selenium_cu    selenium_vdu
    FOR    ${index}    IN RANGE    ${loop_check}
        TRY
            Run Keyword    ${selenium_lib}.Enable Virtual Display
            Run Keyword    ${selenium_lib}.login    url=https://${${par_prefix}_WEBUI_IP}    browser='Firefox'
            ...    timeout=60    coam=webem
            IF    "${par_prefix}"=="CU"
                ${output}    selenium_cu.get_cu_properties_status_info    coam=webem
                ${version}    Set Variable    ${output['Software version'].strip()}
                Should Not Be Empty    ${version}
                BREAK
            ELSE
                &{output}    selenium_vdu.get_vdu_site_properties_info    coam=webem
                ${version}    Set Variable    ${output['gNB vDU properties']['Software version'].strip()}
                Should Not Be Empty     ${version}
                BREAK
            END
        EXCEPT    .*Caom(vDU|CU)VersionNotSupported.*    type=regexp    AS    ${error}
            Fail    v${par_prefix} webem check via selenium failed due to ${error}!!!
        EXCEPT    AS    ${error}
            IF    ${index}==${${loop_check}-1}
                Save Cloud WebEM Screenshot
                ...    selenium_lib=${selenium_lib}
                ...    screenshot_name=${par_prefix}_webem_screenshot
                Fail   v${par_prefix} webem check via selenium failed due to ${error}!!!
            ELSE
                Run Keyword And Ignore Error    ${selenium_lib}.logout    timeout=60    coam=webem
                Run Keyword And Ignore Error    ${selenium_lib}.disable_virtual_display
                BuiltIn.Sleep    5s
                CONTINUE
            END
        END
    END
    Save Cloud WebEM Screenshot
    ...    selenium_lib=${selenium_lib}
    ...    screenshot_name=${par_prefix}_webem_screenshot
    ...    log_screenshot_path_to_console=False
    [Teardown]  Run Keywords    Run Keyword And Continue On Failure    ${selenium_lib}.logout    timeout=60    coam=webem
    ...         AND             Run Keyword And Ignore Error   ${selenium_lib}.disable_virtual_display

Save Cloud WebEM Screenshot
    [Documentation]  This keyword is used to save screenshot on WebEM
    [Arguments]  ${selenium_lib}    ${screenshot_name}=${build_name}_webem_screenshot
    ...          ${screenshot_path}=${OUTPUT_DIR}/Additional_Execution_Logs
    ...          ${coam}=webem     ${log_screenshot_path_to_console}=True
    TRY
        Run Keyword
        ...    ${selenium_lib}.save_screenshot
        ...    ${screenshot_name}
        ...    ${screenshot_path}
        ...    coam=${coam}
        IF   ${log_screenshot_path_to_console}
            Log
            ...    Please check screenshot under ${screenshot_path} for webem functionality verification failure!!!!
            ...    WARN
        END
    EXCEPT    AS    ${error}
        Log    Failed to save webem screenshot due to ${error}!!!    WARN
    END

Pass Execution if CCR Fallback Occurs
    [Documentation]  This keyword is used to pass the test if CCR Fallback occurs.
    [Arguments]  ${checkpoint}
    ${msg}     Set Variable
    ...    ${checkpoint} check before commission will be skipped!
    ${CCR_Fallback}    Get Variable Value    ${CCR_Fallback}    ${False}
    Pass Execution IF   ${CCR_Fallback}
    ...    First deployment with CCR failed, configuration file is deleted from site and so ${msg}

Check RF Power On DU
    [Documentation]  This keyword is used to check RF power for TDD and lte cloud case
    ssh.Connect to   hostname=${DU_k8s_addr}   username=${DU_k8s_user}   password=${DU_k8s_pwd}  alias=RM_alias
    Get pod name    namespace=${DU_tenant}
    ${rf_check}=    check_rf_power   ipaddr=${DU_k8s_addr}    conn_username=${DU_k8s_user}    conn_password=${DU_k8s_pwd}
    ...  oam_node=${oamfh_pod}    tenant=${DU_tenant}    rf_username=${RU_USERNAME}
    ...  rf_password=${RU_PASSWORD}    is_fdd=False    is_lte=${is_LTE}    site=${site}
    Should Be True    ${rf_check}    msg=RF power Check Failed
