*** Settings ***
Documentation  vDU/vCU operations keywords.
...  Author: slawomir.jastrzebski@nokia.com
...  Maintainer: slawomir.jastrzebski@nokia.com

Library    BuiltIn
Library    DateTime
Library    taf.ul.vdu.helm    WITH NAME    helm
Library    taf.transport.ssh    WITH NAME    tafssh

Resource    ../../../resources/Robot/tl_init.robot
Resource    ./common_resources.robot

*** Keywords ***
#Connections
Connect To vDU K8s Master Node
    [Arguments]  ${gnb_index}=0  ${vdu_index}=0  ${timeout}=150  ${alias}=default
    [Documentation]
    ...  Description:
    ...  Keyword connects to vDU k8s master node.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | gnb_index              |  No  | Index of gnb object list.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_index              |  No  | Index of DU (Distributed Unit) class instance objects list.                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | timeout                |  No  | Timeout for the ssh connect operation.                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | alias                  |  No  | Alias of ssh connection. If not specified, default alias is used.          |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Return:
    ...  Connection alias.
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${vdu_k8s_connection_params}=  Get vDU K8s Master Node Connection Parameters From Init File
    ...  gnb_index=${gnb_index}  vdu_index=${vdu_index}
    ${ip_addr}=  Set Variable  ${vdu_k8s_connection_params['ip_addr']}
    ${username}=  Set Variable  ${vdu_k8s_connection_params['username']}
    ${password}=  Set Variable  ${vdu_k8s_connection_params['password']}
    ${port}=  Set Variable  ${vdu_k8s_connection_params['port']}
    ${alias}=  tafssh.Connect To  hostname=${ip_addr}  username=${username}
    ...  password=${password}  port=${port}  alias=${alias}  timeout=${timeout}
    [Return]  ${alias}

Connect To vDU K8s Master Node With Tenant
    [Arguments]  ${gnb_index}=0  ${vdu_index}=0  ${alias}=default  ${timeout}=30
    [Documentation]
    ...  Description:
    ...  Keyword connects to vDU K8s Master with tenant permission.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | gnb_index              |  No  | Index of gnb object list.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_index              |  No  | Index of DU (Distributed Unit) class instance objects list.                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | alias                  |  No  | Alias of ssh connection. If not specified, default alias is used.          |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | timeout                |  No  | Timeout for the ssh connect operation.                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Return:
    ...  Connection alias.
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${vdu_ssh_connection_params}=  Get vDU K8s Master Node Ssh Connection Parameters From Init File
    ...  gnb_index=${gnb_index}  vdu_index=${vdu_index}
    ${ip_addr}=  Set Variable  ${vdu_ssh_connection_params['ip_addr']}
    ${username}=  Set Variable  ${vdu_ssh_connection_params['username']}
    ${password}=  Set Variable  ${vdu_ssh_connection_params['password']}
    ${alias}=  tafssh.Connect To  hostname=${ip_addr}  username=${username}
    ...  password=${password}  alias=${alias}  timeout=${timeout}
    [Return]  ${alias}

Connect To vCU K8s Master Node With Tenant
    [Arguments]  ${gnb_index}=0  ${timeout}=30  ${alias}=default
    [Documentation]
    ...  Description:
    ...  Keyword connects to SSH K8s Master
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | gnb_index              |  No  | Index of gnb object list.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | timeout                |  No  | Timeout for the ssh connect operation.                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | alias                  |  No  | Alias of ssh connection. If not specified, default alias is used.          |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Return:
    ...  Connection alias.
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${vcu_ssh_connection_params}=  Get vCU K8s Master Node Ssh Connection Parameters From Init File
    ...  gnb_index=${gnb_index}
    ${ip_addr}=  Set Variable  ${vcu_ssh_connection_params['ip_addr']}
    ${username}=  Set Variable  ${vcu_ssh_connection_params['username']}
    ${password}=  Set Variable  ${vcu_ssh_connection_params['password']}
    ${alias}=  tafssh.Connect To  hostname=${ip_addr}  username=${username}
    ...  password=${password}  alias=${alias}  timeout=${timeout}
    [Return]  ${alias}

Disconnect Interactive Connection
    [Arguments]  ${connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword disconnects ssh connection.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | connection             |  No  | Alias of ssh connection. If not specified, default alias is used.          |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com
    ...
    Should Not Be Empty  ${connection}
    tafssh.disconnect  connection=${connection}

Connect To vCU K8s Helm Master With Tenant
    [Arguments]  ${gnb_index}=0
    [Documentation]
    ...  Description:
    ...  Keyword connects to vCU k8s helm master with tenant permission.
    ...  Keyword returns connection alias.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | gnb_index              |  No  | Index of gnb object list.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Return:
    ...  Connection alias.
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${vcu_ssh_connection_params}=  Get vCU K8s Master Node Ssh Connection Parameters From Init File
    ...  gnb_index=${gnb_index}
    ${ip_addr}=  Set Variable  ${vcu_ssh_connection_params['ip_addr']}
    ${username}=  Set Variable  ${vcu_ssh_connection_params['username']}
    ${password}=  Set Variable  ${vcu_ssh_connection_params['password']}
    ${port}=  Set Variable  22
    ${alias}=  helm.helm_master_connect  ip=${ip_addr}  port=${port}
    ...  user=${username}  password=${password}
    [Return]  ${alias}

#Operations
K8s Master Delete Temporary Files
    [Arguments]  ${gnb_index}=0  ${vdu_index}=0  ${timeout}=150  ${alias}=default
    [Documentation]
    ...  Description:
    ...  Keyword deletes temporary files
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | gnb_index              | Yes  | Index of gnb object list.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_index              | Yes  | Index of DU (Distributed Unit) class instance objects list.                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | alias                  |  No  | Alias of ssh connection. If not specified, default alias is used.          |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Connect To vDU K8s Master Node  gnb_index=${gnb_index}  vdu_index=${vdu_index}  timeout=${timeout}  alias=${alias}
    ${vdu_ns}=  Get vDU Namespace From Init File  gnb_index=${gnb_index}  vdu_index=${vdu_index}
    ${vcu_ns}=  Get vCU Namespace From Init File  gnb_index=${gnb_index}
    ${vdu_ns_folder}=  Set Variable  /tmp/tmp_${vdu_ns}
    ${cmd_result}=  tafssh.Execute  command=sudo chmod 777 -R ${vdu_ns_folder}  connection=${alias}
    ${cmd_result}=  tafssh.Execute   command=sudo rm -rf ${vdu_ns_folder}  connection=${alias}
    ${vcu_ns_folder}=  Set Variable  /tmp/tmp_${vcu_ns}
    ${cmd_result}=  tafssh.Execute  command=sudo chmod 777 -R ${vcu_ns_folder}  connection=${alias}
    ${cmd_result}=  tafssh.Execute   command=sudo rm -rf ${vcu_ns_folder}   connection=${alias}
    [Teardown]  Run Keyword And Ignore Error  Disconnect Interactive Connection  connection=${alias}

Get vDU Namespace
    [Arguments]  ${gnb_index}=0  ${vdu_index}=0  ${alias}=default
    [Documentation]
    ...  Description:
    ...  Keyword gets vDU namespace.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | gnb_index              | Yes  | Index of gnb object list.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_index              | Yes  | Index of DU (Distributed Unit) class instance objects list.                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | alias                  |  No  | Alias of ssh connection. If not specified, default alias is used.          |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Connect To vDU K8s Master Node With Tenant  gnb_index=${gnb_index}  vdu_index=${vdu_index}  alias=${alias}
    ${cmd_result}=  tafssh.Execute
    ...  command=helm list --all-namespaces |grep aic-vdu-|grep -v prerequisite|grep -v rbac|grep -v preparation|awk '{print $2}'
    ...  connection=${alias}
    ${vdu_namespace}=  Get Command Result  cmd_result=${cmd_result}
    [Return]  ${vdu_namespace}
    [Teardown]  Run Keyword And Ignore Error  Disconnect Interactive Connection  connection=${alias}

Get vDU Build Number
    [Arguments]  ${gnb_index}=0  ${vdu_index}=0  ${alias}=default
    [Documentation]
    ...  Description:
    ...  Keyword gets vDU running build number based on release for a specified namespace (without prefix like vDUCNF00_).
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | gnb_index              |  No  | Index of gnb object list.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_index              |  No  | Index of DU (Distributed Unit) class instance objects list.                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | alias                  |  No  | Alias of ssh connection. If not specified, default alias is used.          |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Return:
    ...  vDU running build number, for example: 0.300.12394
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Connect To vDU K8s Master Node With Tenant  gnb_index=${gnb_index}  vdu_index=${vdu_index}  alias=${alias}
    ${vdu_ns}=  Get vDU Namespace From Init File  gnb_index=${gnb_index}  vdu_index=${vdu_index}
    ${helm_command}=  Set Variable  helm list -a -n ${vdu_ns} | grep -E 'aic-vdu-[0-9]|cloudran-4gvdu-[0-9]' | awk '{print $9}'
    ${cmd_result}=  tafssh.Execute  command=${helm_command}  connection=${alias}
    ${build_number}=  Get Regexp Matches  string=${cmd_result}  pattern=\\d+.\\d+.\\d+
    [Teardown]  Run Keyword And Ignore Error  Disconnect Interactive Connection  connection=${alias}
    [Return]  ${build_number[0]}

Get vCU Build Number
    [Arguments]  ${gnb_index}=0  ${alias}=default
    [Documentation]
    ...  Description:
    ...  Keyword gets vCU running build number based on release for a specified namespace (without prefix like vCUCNF00_).
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | gnb_index              |  No  | Index of gnb object list.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | alias                  |  No  | Alias of ssh connection. If not specified, default alias is used.          |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Return:
    ...  vCU running build number, for example: 0.250.928
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Connect To vCU K8s Master Node With Tenant  gnb_index=${gnb_index}
    ${vcu_ns}=  Get vCU Namespace From Init File  gnb_index=${gnb_index}
    ${helm_command}=  Set Variable  helm list -a -n ${vcu_ns}|grep aic-vcu-[0-9]|awk '{print $9}'
    ${cmd_result}=  tafssh.Execute  command=${helm_command}  connection=${alias}
    ${build_number}=  Get Regexp Matches  string=${cmd_result}  pattern=\\d+.\\d+.\\d+
    [Return]  ${build_number[0]}
    [Teardown]  Run Keyword And Ignore Error  Disconnect Interactive Connection  connection=${alias}

Get VDU timestamp
    [Documentation]  KW logs to specified node using ssh session and returns current timestamp for further usage
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com

    ${vdu_connection_parameters}=  Get vDU K8s Master Node Connection Parameters From Init File
    tafssh.Connect To
    ...  hostname=${vdu_connection_parameters['ip_addr']}
    ...  username=${vdu_connection_parameters['username']}
    ...  password=${vdu_connection_parameters['password']}
    ...  alias=vdu_ssh
    ${bts_timestamp}=  tafssh.Execute  command=date +%Y%m%d%H%M%S  connection=vdu_ssh
    ${real_time_bts_timestamp}=  tafssh.Execute  command=date -u +"%Y-%m-%dT%H:%M:%S%z"  connection=vdu_ssh
    tafssh.Disconnect  connection=vdu_ssh
    ${bts_timestamp}=  Strip String  ${bts_timestamp}
    [Return]  ${bts_timestamp}  ${real_time_bts_timestamp}

Get Current Container Time
    [Arguments]  ${gnb_index}=0  ${vdu_index}=0  ${pod_name}=po-oamfh-0
    ...  ${ctr_name}=ctr-oamfh  ${alias}=default
    [Documentation]
    ...  Description:
    ...  Keyword returns the current time on the container.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | gnb_index              |  No  | Index of gnb object list.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_index              |  No  | Index of DU (Distributed Unit) class instance objects list.                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | pod_name               |  No  | Pod name.                                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | ctr_name               |  No  | Container name.                                                            |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | alias                  |  No  | Alias of ssh connection. If not specified, default alias is used.          |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Return:
    ...  Current time on the container (format HH:MM:SS).
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Connect To vDU K8s Master Node With Tenant  gnb_index=${gnb_index}  vdu_index=${vdu_index}  alias=${alias}
    ${vdu_ns}=  Get vDU Namespace From Init File  gnb_index=${gnb_index}  vdu_index=${vdu_index}
    ${kube_command}=  Set Variable  kubectl exec -it -n ${vdu_ns} ${pod_name} -c ${ctr_name} -- /bin/bash -c 'date +%H:%M:%S'
    ${ctr_time}=  tafssh.Execute  command=${kube_command}  connection=${alias}
    [Teardown]  Run Keyword And Ignore Error  Disconnect Interactive Connection  connection=${alias}
    [Return]  ${ctr_time}

Get Container And Host Time Difference
    [Arguments]  ${gnb_index}=0  ${vdu_index}=0  ${pod_name}=po-oamfh-0
    ...  ${ctr_name}=ctr-oamfh  ${alias}=default
    [Documentation]
    ...  Description:
    ...  Keyword returns the difference (number of hours) between the time zones set on the host
    ...  from which the tests are run and the selected container.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | gnb_index              |  No  | Index of gnb object list.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_index              |  No  | Index of DU (Distributed Unit) class instance objects list.                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | pod_name               |  No  | Pod name.                                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | ctr_name               |  No  | Container name.                                                            |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | alias                  |  No  | Alias of ssh connection. If not specified, default alias is used.          |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Return:
    ...  Time difference (number of hours).
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Connect To vDU K8s Master Node With Tenant  gnb_index=${gnb_index}  vdu_index=${vdu_index}  alias=${alias}
    ${vdu_ns}=  Get vDU Namespace From Init File  gnb_index=${gnb_index}  vdu_index=${vdu_index}
    ${kube_command}=  Set Variable  kubectl exec -it -n ${vdu_ns} ${pod_name} -c ${ctr_name} -- /bin/bash -c 'date +%H:%M:%S'
    ${ctr_time}=  tafssh.Execute  command=${kube_command}  connection=${alias}
    ${host_time}=  Get Current Date  result_format=%H:%M:%S
    ${ctr_minutes}=  Set Variable  ${ctr_time[3:5]}
    ${ctr_seconds}=  Set Variable  ${ctr_time[6:8]}
    IF  '${ctr_minutes}'=='59' and '${ctr_seconds}'=='59'
      Sleep  2s
      ${ctr_time}=  tafssh.Execute  command=${kube_command}  connection=${alias}
      ${host_time}=  Get Current Date  result_format=%H:%M:%S
    END
    ${ctr_hour}=  Convert To Integer  item=${ctr_time[0:2]}
    ${host_hour}=  Convert To Integer  item=${host_time[0:2]}
    ${time_diff}=  Evaluate  expression=${ctr_hour}-${host_hour}
    [Teardown]  Run Keyword And Ignore Error  Disconnect Interactive Connection  connection=${alias}
    [Return]  ${time_diff}
