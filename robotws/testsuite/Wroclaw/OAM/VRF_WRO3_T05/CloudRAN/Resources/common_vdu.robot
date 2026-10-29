*** Settings ***

Documentation    Description:  Cloud Library with common vdu keywords

Library    BuiltIn
Library    OperatingSystem
Library    taf.gnb.oam.coam.vdu.interface.vdu    WITH NAME    vdu

*** Keywords ***

vDU Rest Login
    [Documentation]  Description:           Login to vDU RestAPI ${\n}
    ...              Return:                vDU RestAPI login alias ${\n}
    ...              Output:                ${alias} ${\n}
    ...              Author:                szymon.romanowski@nokia.com ${\n}
    ...              Maintainer:            szymon.romanowski@nokia.com ${\n}
    ...              Last Modification:     23-02-2024 made by szymon.romanowski@nokia.com ${\n}
    [Arguments]  ${gnb_index}=0  ${vdu_index}=0  ${restapi_version}=cuoam_23r4  ${timeout}=30  ${alias}=default

    Run Keyword And Ignore Error  vDU Rest Logout  alias=${alias}
    ${status}  ${restapi_version}=  Run Keyword And Ignore Error
    ...  Get vDU Rest Api Version  gnb_index=${gnb_index}  vdu_index=${vdu_index}
    ${restapi_version}=  Set Variable If  '${status}'=='FAIL'
    ...  ${VDU_REST_TAF_LIB_SUPPORTED_VERSION[-1]}  ${restapi_version}
    ${index}=  Get Index From List  ${VDU_REST_TAF_LIB_SUPPORTED_VERSION}  ${restapi_version}
    ${oam_http_connection}=  Get vDU Oam Http Connection Parameters From Init File
    ...  gnb_index=${gnb_index}  vdu_index=${vdu_index}
    ${http_password}=  Set Variable If  ${index}>=${4}  Nokia@123
    ...  ${oam_http_connection["password"]}
    ${ip_addr}=  Set Variable  ${oam_http_connection["ip_addr"]}
    ${port}=  Set Variable  ${oam_http_connection["port"]}
    ${username}=  Set Variable  ${oam_http_connection["username"]}
    ${password}=  Set Variable  ${http_password}
    ${secure}=  Set Variable  True
    vdu.Connect To  host=${ip_addr}  port=${port}  username=${username}  password=${password}
    ...  vdu_version=${restapi_version}  secure=${secure}  connection_name=${alias}  timeout=${timeout}
    [Return]  ${alias}

vDU Rest Logout
    [Documentation]  Description:           vDU RestAPI logout ${\n}
    ...              Return:                None ${\n}
    ...              Output:                None ${\n}
    ...              Author:                szymon.romanowski@nokia.com ${\n}
    ...              Maintainer:            szymon.romanowski@nokia.com ${\n}
    ...              Last Modification:     23-02-2024 made by szymon.romanowski@nokia.com ${\n}
    [Arguments]  ${alias}=default

    vdu.Disconnect  vdu_connection=${alias}

Get vDU Rest Api Version
    [Documentation]  Description:           Get vDU RestAPI version from global variables file (variables.robot) ${\n}
    ...              Return:                vDU Rest Api version for example cuoam_23r3 ${\n}
    ...              Output:                ${restapi_version} ${\n}
    ...              Author:                szymon.romanowski@nokia.com ${\n}
    ...              Maintainer:            szymon.romanowski@nokia.com ${\n}
    ...              Last Modification:     23-02-2024 made by szymon.romanowski@nokia.com ${\n}
    [Arguments]  ${gnb_index}=0  ${vdu_index}=0  ${alias}=default

    ${build_version}=  Get vDU Build Number  gnb_index=${gnb_index}  vdu_index=${vdu_index}  alias=${alias}
    ${build_number_list}=  Split String  string=${build_version}  separator=.
    ${built_stream}=  Set Variable  ${build_number_list[0]}.${build_number_list[1]}
    ${restapi_version}=  Set Variable  ${VDU_RESTAPI_TAF_VERSION_SW_STREAM_MAPPING['${built_stream}']}
    [Return]  ${restapi_version}

Get vDU Build Number
    [Documentation]  Description:           Get vDU build number ${\n}
    ...              Return:                vDU running build number, for example 0.300.12394 ${\n}
    ...              Output:                ${restapi_version} ${\n}
    ...              Author:                szymon.romanowski@nokia.com ${\n}
    ...              Maintainer:            szymon.romanowski@nokia.com ${\n}
    ...              Last Modification:     26-02-2024 made by szymon.romanowski@nokia.com ${\n}
    [Arguments]  ${gnb_index}=0  ${vdu_index}=0  ${alias}=default

    Connect To vDU K8s Master Node With Tenant  gnb_index=${gnb_index}  vdu_index=${vdu_index}  alias=${alias}
    ${vdu_ns}=  Get vDU Namespace From Init File  gnb_index=${gnb_index}  vdu_index=${vdu_index}
    ${cmd_result}=  issh.Execute
    ...  command=helm list -a -n ${vdu_ns}|grep aic-vdu-|grep -v aic-vdu-prerequisite|grep -v aic-vdu-cluster|awk '{print $9}'
    ...  alias=${alias}
    ${build_number}=  Get Command Result  cmd_result=${cmd_result}
    ${build_number}=  Fetch From Right  string=${build_number}  marker=-
    [Teardown]  Run Keyword And Ignore Error  Disconnect Interactive Connection  alias=${alias}
    [Return]  ${build_number}

Connect To vDU K8s Master Node With Tenant
    [Documentation]  Description:           Keyword connects to vDU K8s Master with tenant permission ${\n}
    ...              Return:                Connection alias ${\n}
    ...              Output:                ${alias} ${\n}
    ...              Author:                szymon.romanowski@nokia.com ${\n}
    ...              Maintainer:            szymon.romanowski@nokia.com ${\n}
    ...              Last Modification:     26-02-2024 made by szymon.romanowski@nokia.com ${\n}
    [Arguments]  ${gnb_index}=0    ${timeout}=150  ${vdu_index}=0  ${alias}=default

    ${vdu_ssh_connection_params}=  Get vDU K8s Master Node Ssh Connection Parameters From Init File
    ...  gnb_index=${gnb_index}  vdu_index=${vdu_index}
    ${ip_addr}=  Set Variable  ${vdu_ssh_connection_params['ip_addr']}
    ${username}=  Set Variable  ${vdu_ssh_connection_params['username']}
    ${password}=  Set Variable  ${vdu_ssh_connection_params['password']}
#    ${prompt}=  Set Variable  \\[core@\\S+\\s\\S+\\]\\$\\s
    ${prompt}  Set Variable   ${VDU_OE_SERVER_PROMPT}|${VDU_CONTAINER_PROMPT}|${VDU_CONTAINER_PROMPT_ROOT}
    ${alias}=  issh.Connect To  ip=${ip_addr}  username=${username}  password=${password}
    ...  prompt=${prompt}  timeout=${timeout}    alias=${alias}  width=200
    [Return]  ${alias}

Get vDU K8s Master Node Ssh Connection Parameters From Init File
    [Documentation]  Description:           Keyword gets vDU K8s master node ssh connection parameters from TL configuration init file ${\n}
    ...              Return:                SSH connection parameters ${\n}
    ...              Output:                ${ssh_connection_parameters} ${\n}
    ...              Author:                szymon.romanowski@nokia.com ${\n}
    ...              Maintainer:            szymon.romanowski@nokia.com ${\n}
    ...              Last Modification:     26-02-2024 made by szymon.romanowski@nokia.com ${\n}
    [Arguments]  ${gnb_index}=0  ${vdu_index}=0

    ${ip_addr}=  Set Variable
    ...  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.addr}
    ${username}=  Set Variable
    ...  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.username}
    ${password}=  Set Variable
    ...  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.password}
    ${ssh_connection_parameters}=  Create Dictionary
    ...  ip_addr=${ip_addr}  username=${username}  password=${password}
    [Return]  ${ssh_connection_parameters}

Get vDU Namespace From Init File
    [Documentation]  Description:           Keyword gets vDU namespace parameters from TL configuration init file ${\n}
    ...              Return:                vDU namespace ${\n}
    ...              Output:                ${namespace} ${\n}
    ...              Author:                szymon.romanowski@nokia.com ${\n}
    ...              Maintainer:            szymon.romanowski@nokia.com ${\n}
    ...              Last Modification:     26-02-2024 made by szymon.romanowski@nokia.com ${\n}
    [Arguments]  ${gnb_index}=0  ${vdu_index}=0

    ${namespace}=  Set Variable
    ...  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.namespace}
    [Return]  ${namespace}

Get vDU Oam Http Connection Parameters From Init File
    [Documentation]  Description:           Keyword gets vDU OAM Http connection parameters from TL configuration init file ${\n}
    ...              Return:                Http connection parameters ${\n}
    ...              Output:                ${http_connection_parameters} ${\n}
    ...              Author:                szymon.romanowski@nokia.com ${\n}
    ...              Maintainer:            szymon.romanowski@nokia.com ${\n}
    ...              Last Modification:     26-02-2024 made by szymon.romanowski@nokia.com ${\n}
    [Arguments]  ${gnb_index}=0  ${vdu_index}=0

    ${ip_addr}=  Set Variable  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.addr}
    ${username}=  Set Variable  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.username}
    ${password}=  Set Variable  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.password}
    ${port}=  Set Variable  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.port}
    ${http_connection_parameters}=  Create Dictionary
    ...  ip_addr=${ip_addr}  username=${username}  password=${password}  port=${port}
    [Return]  ${http_connection_parameters}

vDU Get Container Logs On All Pods
    [Documentation]  Description:           Get vDU container logs from all pods ${\n}
    ...              Return:                None ${\n}
    ...              Output:                None ${\n}
    ...              Author:                szymon.romanowski@nokia.com ${\n}
    ...              Maintainer:            szymon.romanowski@nokia.com ${\n}
    ...              Last Modification:     26-02-2024 made by szymon.romanowski@nokia.com ${\n}
    [Arguments]  ${logs_dir_path}  ${gnb_index}=0  ${vdu_index}=0  ${alias}=default

    ${vdu_pods_dir}=  Set Variable  ${logs_dir_path}/vdu_pod_logs
    Create Directory  path=${vdu_pods_dir}
    Connect To vDU K8s Master Node With Tenant  gnb_index=${gnb_index}  vdu_index=${vdu_index}  alias=${alias}
    ${ns}=  Get vDU Namespace From Init File  gnb_index=${gnb_index}  vdu_index=${vdu_index}
    ${remote_logs_dir}=  Set Variable  /tmp/tmp_${ns}
    issh.Execute  command=sudo mkdir -p ${remote_logs_dir}  alias=${alias}
    issh.Execute  command=sudo chmod -R 777 ${remote_logs_dir}  alias=${alias}
    vDU Get Pods For Namespace  ns=${ns}  local_dir=${vdu_pods_dir}  remote_dir=${remote_logs_dir}
    [Teardown]  Run Keyword And Ignore Error  Disconnect Interactive Connection  alias=${alias}

vDU Get Pods For Namespace
    [Documentation]  Description:           Get vDU container logs from all namespace pods ${\n}
    ...              Return:                None ${\n}
    ...              Output:                None ${\n}
    ...              Author:                szymon.romanowski@nokia.com ${\n}
    ...              Maintainer:            szymon.romanowski@nokia.com ${\n}
    ...              Last Modification:     26-02-2024 made by szymon.romanowski@nokia.com ${\n}
    [Arguments]  ${ns}  ${local_dir}  ${remote_dir}  ${alias}=default

    ${cmd_result}=  issh.Execute
    ...  command=kubectl get pod -n ${ns} | awk '{print $1}' | grep -v NAME
    ...  alias=${alias}
    ${vdu_pod_list}=  Split To Lines  string=${cmd_result}  start=1  end=-1
    FOR  ${vdu_pod}  IN  @{vdu_pod_list}
      Log  ${vdu_pod}  console=False
      Continue For Loop If  'po-' not in '${vdu_pod}'
      vDU Get Logs For One Pod  ns=${ns}  pod=${vdu_pod}   alias=${alias}
      ...  local_dir=${local_dir}  remote_dir=${remote_dir}
    END

vDU Get Logs For One Pod
    [Documentation]  Description:           Get vDU container logs from Pod ${\n}
    ...              Return:                None ${\n}
    ...              Output:                None ${\n}
    ...              Author:                szymon.romanowski@nokia.com ${\n}
    ...              Maintainer:            szymon.romanowski@nokia.com ${\n}
    ...              Last Modification:     26-02-2024 made by szymon.romanowski@nokia.com ${\n}
    [Arguments]  ${ns}  ${pod}  ${local_dir}  ${remote_dir}  ${alias}=default

    ${pod_file_name}=  Set Variable  ${ns}_${pod}_kubectl_logs.log
    ${local_file_path}=  Set Variable  ${local_dir}/${pod_file_name}
    ${remote_file_path}=  Set Variable  ${remote_dir}/${pod_file_name}
    ${cmd_result}=  issh.Execute
    ...  command=kubectl logs ${pod} -n ${ns} --all-containers > /tmp/tmp_${ns}/${pod_file_name}
    ...  check_result=False  alias=${alias}
    ${cmd_result}=  issh.Execute  command=sync  check_result=False  alias=${alias}
    ${cmd_result}=  issh.Downloadfile  remote_path=${remote_file_path}  local_path=${local_file_path}
    ...  alias=${alias}