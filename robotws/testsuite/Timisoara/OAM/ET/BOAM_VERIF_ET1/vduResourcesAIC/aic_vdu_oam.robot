*** Settings ***

Documentation
...     22.01.2025 -- updated FOR functions and solved RF5.0 issues

Library           taf.transport.ssh                     WITH NAME    tafssh

*** Variables ***
${G_VDU_NAME}           vdu1
${CLUSTER_NAME}         cran1
${G_OAM_PODS_NAME}      po-${CLUSTER_NAME}-oam-0
${G_USER}               core

*** Keywords ***
Get vDU Host IP
    [Documentation]  Get vDU Host IP
    ...  author: miao.a.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...    host_info_list
    ...
    ...    Example
    ...   | Get vDU Host IP |
    csn.Connect To   ${ncir_addr}   ${ncir_tenant}   ${ncir_password}   alias=vDU_get_host_ip
    ${host_info}   csn.Execute    kubectl exec -it ${G_OAM_PODS_NAME} -c oam -- ifconfig -v oam3 |grep inet    connection=vDU_get_host_ip
    ${host_info_list}    Split String     ${host_info}
    [Return]    ${host_info_list[1]}

Check vDU Containers Application Status Should Be As Expected
    [Arguments]  ${pod_name}  ${container_name}  #${vdu_index}=0  ${gnb_index}=0
    [Documentation]  check vdu application status should be as expected
    ...  author: qixuan.zhang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | pod_name | Yes. | the pods name that containers belong to |
    ...	   | container_name | Yes. | the container name |
    ...    *RETURN VALUE*
    ...    None
    ${app_and_status_dict}=   set variable   ${ALL_CONTAINER_APP.${container_name}}
    ${program_list}=  Get Dictionary Keys  ${app_and_status_dict}
    For  ${program}  IN  @{program_list}
      ${result}=  helm.execute_command_on_master_cluster
    ...   kubectl exec -it ${pod_name} -c ctr-${CLUSTER_NAME}-${container_name} -n ${CLUSTER_NAME} -- netstat -anp|grep -i ${program}
      Should Contain  ${result.stdout}  ${app_and_status_dict.${program}}
    END

Check VDU restart times
    [Arguments]  ${Restart_Time}
    [Documentation]  Check VDU restart times
    ...  author: xin.6.wang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | Restart_Time | yes | e.g, |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...   | Check VDU restart times |
    ${oam_json}    tafssh.Execute
    ...  kubectl exec -it ${G_OAM_PODS_NAME} -c ctr-${CLUSTER_NAME}-oam -n ${CLUSTER_NAME} -- cat /mnt/services/SS_OAM/OAMAGENT/recoveryCounter.json
    ...  | grep "retries"
    Should Contain    ${oam_json}        "retries" : ${Restart_Time}

Download File From VDU via OCP
    [Arguments]     ${pod_name}   ${container_name}   ${file_path}  ${file_name}  ${store_path}     #${vdu_index}
    [Documentation]    download file from vDU specifical container to ute
    ...    *AUTHOR* luofei.tu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    21.07.2021,qixuan.zhang@nokia-sbell.com, create
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | vdu_index | yes | the vdu index is specified in init.py |
    ...    | pod_name | yes | like oam, up |
    ...    | container_name | yes | oam, oamfh |
    ...    | file_path | yes | your need download file path in vDU |
    ...    | store_path | yes | the target file you need download |
    ...    *RETURN VALUE*
    ...    none
    ...    Example
    ...    |Download file from vDU | index=0 | pod_name=oam | container_name=oamfh | file_path=/tmp |  file_name=start.log
    ...    |stroe_path=/home/ute
    tafssh.Reset_Cache
    ${command}=     catenate  SEPARATOR=    kubectl cp -n ${CLUSTER_NAME} -c ${container_name} po-${CLUSTER_NAME}-${pod_name}-0:
    ...     ${file_path}/${file_name} /home/${G_USER}/${file_name} connection=NODE timeout=5
    tafssh.Execute       ${command}
    tafssh.File_Exists     /home/${G_USER}/${file_name}
    tafssh.Execute     command=sudo chmod 777 /home/${G_USER}/${file_name}       timeout=5
    tafssh.Download_File   remote_path=/home/${G_USER}/${file_name}    local_path=${store_path}/${file_name}
    tafssh.Reset_Cache

vDU Rest API Login
    [Arguments]  ${restapi_version}=cuoam_21b  ${vdu_index}=0  ${gnb_index}=0  ${alias}=default
    [Documentation]  login webem by rest api
    ...  history change:
    ...  author:calla.wang@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...
    ${oam_httpaddr}   set variable   ${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.addr}
    ${oam_web_ip}   set variable if   ':' in '''${oam_httpaddr}'''   [${oam_httpaddr}]    ${oam_httpaddr}
    run keyword and ignore error  vDU Rest API Logout   vdu_index=${vdu_index}
    ${vdu_connection}=   Run Keyword If  '${restapi_version}'=='cuoam_21b'  vdu.connect to
    ...  host=${oam_web_ip}
    ...  port=${EMPTY}
    ...  username=${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.username}
    ...  password=${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.password}
    ...  secure=True
    ...  connection_name=${alias}
    ...  ELSE  vdu.connect to
    ...  host=${oam_web_ip}
    ...  port=8081
    ...  username=${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.username}
    ...  password=${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.password}

vDU Rest API Logout
    [Arguments]    ${alias}=default     #${vdu_index}=0
    [Documentation]  vDU Rest api Logout
    ...  history change:
    ...  author:calla.wang@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   4.09.2020,chris.l.cao@nokia-sbell.com, add check for OAM up or down
    ...   11.9.2020,chris.l.cao@nokia-sbell.com, change to use 'Wait Until VDU OAM Up'
    ...
    vdu.disconnect  ${alias}

vDU SSH Login
    [Arguments]  ${vdu_index}=0  ${gnb_index}=0
    ${conn}=  helm.helm_master_connect
    ...  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.ip_addr}
    ...  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.port}
    ...  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.username}
    ...  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.password}
    [Return]   ${conn}

Block or Unblock Cell with M2M
    [Arguments]     ${cell_id}      ${operation}
    ${Token}     Get Token via M2M
    ${operation_output}   tafssh.Execute
    ...    ${head}/${operation} -k -X POST -d '{"id": "${cell_id}"}' -H "Authorization: Bearer ${Token}"
    should contain     ${operation_output}    No error
    sleep  60s
    ${status_output}     tafssh.Execute
    ...    ${head}/${operation}/${cell_id} -k -X GET -H "Accept: application/json" -H "Authorization: Bearer ${Token}"
    should contain     ${status_output}    success
    tafssh.Execute     ${head}/${operation}/${cell_id} -k -X DELETE -H "Accept: application/json" -H "Authorization: Bearer ${Token}"

Get Token via M2M
    ${base64_code}      tafssh.Execute     command=echo -n Nemuadmin:nemuuser| base64|tr -d '\r\n'
    ${Token_output}     tafssh.Execute        command= ${TOKEN_COMMAND} "Authorization: Basic ${base64 code}"
    log to console    ${Token_output}
    ${Token}=    Run   echo "${Token_output}"|grep "Token"| awk -F ":" '{print $2}' | tr -d ',' | tr -d ' '
    [Return]    ${Token}
