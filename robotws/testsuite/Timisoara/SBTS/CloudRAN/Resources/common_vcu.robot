*** Settings ***

Documentation    Description:  Cloud Library with common vcu keywords

Library    BuiltIn
Library    OperatingSystem
Library    taf.gnb.oam.coam.cu.interface.cu      WITH NAME    cuint

*** Keywords ***

vCU Rest Login
    [Documentation]  Description:           Login to vCU RestAPI ${\n}
    ...              Return:                vCU RestAPI login alias ${\n}
    ...              Output:                ${alias} ${\n}
    ...              Author:                szymon.romanowski@nokia.com ${\n}
    ...              Maintainer:            szymon.romanowski@nokia.com ${\n}
    ...              Last Modification:     26-02-2024 made by szymon.romanowski@nokia.com ${\n}
    [Arguments]  ${gnb_index}=0  ${restapi_version}=cuoam_22r4  ${timeout}=120  ${alias}=${None}

    Run Keyword And Ignore Error  vCU Rest Logout  connection=${alias}
    ${status}  ${restapi_version}=  Run Keyword And Ignore Error
    ...  Get vCU Rest Api Version  gnb_index=${gnb_index}  alias=default
    ${restapi_version}=  Set Variable If  '${status}'=='FAIL'
    ...  ${VCU_REST_TAF_LIB_SUPPORTED_VERSION[-1]}  ${restapi_version}
    ${index}=  Get Index From List  ${VCU_REST_TAF_LIB_SUPPORTED_VERSION}  ${restapi_version}
    ${oam_http_connection}=  Get vCU Oam Http Connection Parameters From Init File
    ...  gnb_index=${gnb_index}
    ${http_password}=  Set Variable If  ${index}>=${3}  Nokia@123
    ...  ${oam_http_connection["password"]}
    ${ip_addr}=  Set Variable  ${oam_http_connection["ip_addr"]}
    ${port}=  Set Variable  ${oam_http_connection["port"]}
    ${username}=  Set Variable  ${oam_http_connection["username"]}
    ${password}=  Set Variable  ${http_password}
    ${secure}=  Set Variable  ${True}
    cuint.Connect To  host=${ip_addr}  port=${port}  username=${username}  password=${password}
    ...  cu_version=${restapi_version}  secure=${secure}  alias=${alias}  timeout=${timeout}
    [Return]  ${alias}

vCU Rest Logout
    [Documentation]  Description:           vCU RestAPI logout ${\n}
    ...              Return:                None ${\n}
    ...              Output:                None ${\n}
    ...              Author:                szymon.romanowski@nokia.com ${\n}
    ...              Maintainer:            szymon.romanowski@nokia.com ${\n}
    ...              Last Modification:     26-02-2024 made by szymon.romanowski@nokia.com ${\n}
    [Arguments]  ${connection}=${None}

    cuint.Disconnect  connection=${connection}

Get vCU Rest Api Version
    [Documentation]  Description:           Get vDU RestAPI version from global variables file (variables.robot) ${\n}
    ...              Return:                vCU Rest Api version for example cuoam_23r3 ${\n}
    ...              Output:                ${alias} ${\n}
    ...              Author:                szymon.romanowski@nokia.com ${\n}
    ...              Maintainer:            szymon.romanowski@nokia.com ${\n}
    ...              Last Modification:     26-02-2024 made by szymon.romanowski@nokia.com ${\n}
    [Arguments]  ${gnb_index}=0  ${alias}=default

    ${build_version}=  Get vCU Build Number  gnb_index=${gnb_index}  alias=${alias}
    ${build_number_list}=  Split String  string=${build_version}  separator=.
    ${build_number}=  Set Variable  ${build_number_list[0]}.${build_number_list[1]}
    ${restapi_version}=  Set Variable  ${VCU_RESTAPI_TAF_VERSION_SW_STREAM_MAPPING['${build_number}']}
    [Return]  ${restapi_version}

Get vCU Build Number
    [Documentation]  Description:           GetvCU running build number (without prefix like vCUCNF00_) ${\n}
    ...              Return:                vCU running build number, for example 0.250.928 ${\n}
    ...              Output:                ${build_number} ${\n}
    ...              Author:                szymon.romanowski@nokia.com ${\n}
    ...              Maintainer:            szymon.romanowski@nokia.com ${\n}
    ...              Last Modification:     26-02-2024 made by szymon.romanowski@nokia.com ${\n}
    [Arguments]  ${gnb_index}=0  ${alias}=default

    Connect To vCU K8s Master Node With Tenant  gnb_index=${gnb_index}
    ${vcu_ns}=  Get vCU Namespace From Init File  gnb_index=${gnb_index}
    ${cmd_result}=  issh.Execute
    ...  command=helm list -a -n ${vcu_ns} |grep aic-vcu-cnf|awk '{print $9}'
    ...  check_result=${False}  alias=${alias}
    ${build_number}=  Get Command Result  cmd_result=${cmd_result}
    ${build_number}=  Fetch From Right  string=${build_number}  marker=-
    [Return]  ${build_number}
    [Teardown]  Run Keyword And Ignore Error  Disconnect Interactive Connection   alias=${alias}

Connect To vCU K8s Master Node With Tenant
    [Documentation]  Description:           Keyword connects to SSH K8s Master ${\n}
    ...              Return:                Connection alias ${\n}
    ...              Output:                ${alias} ${\n}
    ...              Author:                szymon.romanowski@nokia.com ${\n}
    ...              Maintainer:            szymon.romanowski@nokia.com ${\n}
    ...              Last Modification:     26-02-2024 made by szymon.romanowski@nokia.com ${\n}
    [Arguments]  ${gnb_index}=0  ${timeout}=150  ${width}=${None}  ${alias}=default

    ${vcu_ssh_connection_params}=  Get vCU K8s Master Node Ssh Connection Parameters From Init File
    ...  gnb_index=${gnb_index}
    ${ip_addr}=  Set Variable  ${vcu_ssh_connection_params['ip_addr']}
    ${username}=  Set Variable  ${vcu_ssh_connection_params['username']}
    ${password}=  Set Variable  ${vcu_ssh_connection_params['password']}
    ${prompt}=  Set Variable  \\[core@\\S+\\s\\S+\\]\\$\\s
    ${alias}=  issh.Connect To  ip=${ip_addr}  username=${username}  password=${password}
    ...  prompt=${prompt}  timeout=${timeout}  width=${width}  alias=${alias}
    [Return]  ${alias}

Get vCU K8s Master Node Ssh Connection Parameters From Init File
    [Documentation]  Description:           gets vCU K8s master node ssh connection parameters from TL configuration init file ${\n}
    ...              Return:                List of ssh connection parameters ${\n}
    ...              Output:                ${ssh_connection_parameters}  ${\n}
    ...              Author:                szymon.romanowski@nokia.com ${\n}
    ...              Maintainer:            szymon.romanowski@nokia.com ${\n}
    ...              Last Modification:     27-02-2024 made by szymon.romanowski@nokia.com ${\n}
    [Arguments]  ${gnb_index}=0

    ${ip_addr}=  Set Variable
    ...  ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.addr}
    ${username}=  Set Variable
    ...  ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.username}
    ${password}=  Set Variable
    ...  ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.password}
    ${ssh_connection_parameters}=  Create Dictionary
    ...  ip_addr=${ip_addr}  username=${username}  password=${password}
    [Return]  ${ssh_connection_parameters}

Get vCU Namespace From Init File
    [Documentation]  Description:           Get vCU namespace parameters from TL configuration init file ${\n}
    ...              Return:                vCU namespace ${\n}
    ...              Output:                ${namespace} ${\n}
    ...              Author:                szymon.romanowski@nokia.com ${\n}
    ...              Maintainer:            szymon.romanowski@nokia.com ${\n}
    ...              Last Modification:     26-02-2024 made by szymon.romanowski@nokia.com ${\n}
    [Arguments]  ${gnb_index}=0

    ${cnf}=  Set Variable
    ...  ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.namespace}
    ${vnf}=  Set Variable
    ...  ${tl.cloud_hostings[0].control_nodes[0].default_ssh_connection_details.username}
    Run Keyword If  '${cnf}'=='None'
    ...  Log  \nIt's VNF.\n  console=True
    ${namespace}=  Set Variable If  '${cnf}'=='None'  ${vnf}  ${cnf}
    [Return]  ${namespace}

Get vCU Oam Http Connection Parameters From Init File
    [Documentation]  Description:           Get vCU OAM Http connection parameters from TL configuration init file ${\n}
    ...              Return:                Http connection parameters ${\n}
    ...              Output:                ${http_connection_parameters} ${\n}
    ...              Author:                szymon.romanowski@nokia.com ${\n}
    ...              Maintainer:            szymon.romanowski@nokia.com ${\n}
    ...              Last Modification:     26-02-2024 made by szymon.romanowski@nokia.com ${\n}
    [Arguments]  ${gnb_index}=0

    ${ip_addr}=  Set Variable  ${tl.gnbs[${gnb_index}].cuint.oam_http_connection_details.addr}
    ${username}=  Set Variable  ${tl.gnbs[${gnb_index}].cuint.oam_http_connection_details.username}
    ${password}=  Set Variable  ${tl.gnbs[${gnb_index}].cuint.oam_http_connection_details.password}
    ${port}=  Set Variable  ${tl.gnbs[${gnb_index}].cuint.oam_http_connection_details.port}
    ${http_connection_parameters}=  Create Dictionary
    ...  ip_addr=${ip_addr}  username=${username}  password=${password}  port=${port}
    [Return]  ${http_connection_parameters}

vCU Get Container Logs On All Pods
    [Documentation]  Description:           Get vCU container logs from all pods ${\n}
    ...              Return:                None ${\n}
    ...              Output:                None ${\n}
    ...              Author:                szymon.romanowski@nokia.com ${\n}
    ...              Maintainer:            szymon.romanowski@nokia.com ${\n}
    ...              Last Modification:     26-02-2024 made by szymon.romanowski@nokia.com ${\n}
    [Arguments]  ${logs_dir_path}  ${gnb_index}=0  ${alias}=default

    ${vcu_pods_dir}=  Set Variable  ${logs_dir_path}/vcu_pod_logs
    Create Directory  path=${vcu_pods_dir}
    Connect To vCU K8s Master Node With Tenant  gnb_index=${gnb_index}  timeout=150
    ...  width=200  alias=${alias}
    ${ns}=  Get vCU Namespace From Init File  gnb_index=${gnb_index}
    ${remote_logs_dir}=  Set Variable  /tmp/tmp_${ns}
    issh.Execute  command=sudo mkdir -p ${remote_logs_dir}  alias=${alias}
    issh.Execute  command=sudo chmod -R 777 ${remote_logs_dir}  alias=${alias}
    vCU Get Pods For Namespace  ns=${ns}  local_dir=${vcu_pods_dir}  remote_dir=${remote_logs_dir}
    [Teardown]  Run Keyword And Ignore Error  Disconnect Interactive Connection  alias=${alias}

vCU Get Pods For Namespace
    [Documentation]  Description:           Get vCU container logs from all namespace pods ${\n}
    ...              Return:                None ${\n}
    ...              Output:                None ${\n}
    ...              Author:                szymon.romanowski@nokia.com ${\n}
    ...              Maintainer:            szymon.romanowski@nokia.com ${\n}
    ...              Last Modification:     26-02-2024 made by szymon.romanowski@nokia.com ${\n}
    [Arguments]  ${ns}  ${local_dir}  ${remote_dir}  ${alias}=default

    ${cmd_result}=  issh.Execute
    ...  command=kubectl get pod -n ${ns} | awk '{print $1}' | grep -v NAME
    ...  alias=${alias}
    ${vcu_pod_list}=  Split To Lines  string=${cmd_result}  start=1  end=-1
    FOR  ${vcu_pod}  IN  @{vcu_pod_list}
      Log  ${vcu_pod}  console=False
      Continue For Loop If  'po-' not in '${vcu_pod}'
      vCU Get Logs For One Pod  ns=${ns}  pod=${vcu_pod}   alias=${alias}
      ...  local_dir=${local_dir}  remote_dir=${remote_dir}
    END

vCU Get Logs For One Pod
    [Documentation]  Description:           Get vCU container logs from all namespace pods ${\n}
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
    ...  command=kubectl logs ${pod} -n ${ns} --all-containers=true > /tmp/tmp_${ns}/${pod_file_name}
    ...  check_result=False  alias=${alias}
    ${cmd_result}=  issh.Execute  command=sync  check_result=False  alias=${alias}
    ${cmd_result}=  issh.Downloadfile  remote_path=${remote_file_path}  local_path=${local_file_path}
    ...  alias=${alias}
