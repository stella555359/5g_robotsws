*** Settings ***
Documentation
...   author: xianbiao.cheng@nokia-sbell.com
...   contact: xianbiao.cheng@nokia-sbell.com
...   cu_cloud_deployment.robot



*** Variables ***



*** Keywords ***
Get Current CU Version
    [Arguments]    ${gnb_index}=0  ${with_prefix}=${False}   ${print_or_not}=${False}
    [Documentation]  get current cu version
    ...    *Author:* chris.l.cao@nokia-sbell.com
    ...    *Change History*
    ...    | date | who | what or how |
    ...    | 2022-3-1 | r3li | update kw support that cu name not contain vdutest |
    ...    | 2022-5-10 | rifeng |  change "grep vcu" to "grep vcu-cnf"   |
    ...    | 19.1.2023 | chris.l.cao@nokia-sbell.com | add parameter with_prefix and print_or_not |
    ...
    ...    *Argument Description*
    ...    | Input arg | Main | Description |
    ...    | gnb_index | No | vcu index, default is 0 |
    ...    | with_prefix    | No | with_prefix, if ${True} it has the prefix like vCUCNF00_, default is ${False} |
    ...    | print_or_not   | No | print_or_not, if ${True} it prints the buil number, default is ${False} |
    ...
    ...    *Example*
    ...    | ${vcu_build_number} | Get Current Cu Version |
    ...    | ${vcu_build_number} | Get Current Cu Version | with_prefix=${True} |
    ...
    ...    *Return*
    ...    - vcu current version, such as 0.250.301, or vCUCNF00_0.250.301
    ...
    ${conn}    vCU Cluster helm Login With Tenant
    ${ns}   Get CU Namespace From TestLine
    ${result}=    helm.Execute Command On Master Cluster    helm list -n ${ns} |grep vcu-cnf |awk '{print $9}'
    log    ${result.stdout}
    ${vcu_current_version}=    Convert To String    ${result.stdout}
    ${vcu_current_version}=    Strip String    ${vcu_current_version}
    @{vcu_current_version}=    Split String    ${vcu_current_version}    -
    ${vcu_current_version}=    Set Variable    ${vcu_current_version[-1]}

    Return From Keyword If  "${with_prefix}"=="${False}"   ${vcu_current_version}

    ${SW_version_list1}    split string  ${vcu_current_version}    .
    ${stream_name}    Set Variable    ${SW_version_list1[0]}.${SW_version_list1[1]}
    ${build_prefix}    set variable   ${PACKAGE_PRE_MAPPING["${stream_name}"]}

    Run Keyword If   "${print_or_not}"=="${True}"  Log To Console  VCU Full Build Name:${build_prefix}_${vcu_current_version}

    [Return]   ${build_prefix}_${vcu_current_version}


Get VCU Build Prefix
    [Arguments]    ${gnb_index}=0
    [Documentation]   Get VCU Build Prefix
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | gnb_index | no | gnb_index, default value is 0  |
    ...
    ...    *RETURN VALUE*
    ...    return vDUCNF, vDUCNF22R4, etc.
    ...
    ...    Example
    ...
    ...    | ${build_prefix} | Get VCU Build Prefix |
    ...    | ${build_prefix} | Get VCU Build Prefix | gnb_index=0 |
    ...
    ${build_number}   Get Current CU Version   gnb_index=${gnb_index}
    ${build_prefix}   Get Package Prefix From Global Variables File   build_number=${build_number}

    [Return]   ${build_prefix}


Get CU Container ID
    [Arguments]  ${pod_abbr}   ${ctr_abbr}  ${alias}=${EMPTY}  ${gnb_index}=0
    [Teardown]  Run Keyword If   "${alias}"=="${EMPTY}"  Run Keyword And Ignore Error   Disconnect Interactive Connection   alias=${real_alias}
    [Documentation]  get the given cu container id
    ...  author:            calla.wang@nokia-sbell.com
    ...  history change:
    ...  modified by:       <06-23-2021>, <calwang>, <initial created>
    ...    history change: 14.7.2022,lingting.sun@nokia-sbell.com, adaption for multi gnb
    ...  24.12.2021,chris.l.cao@nokia-sbell.com, add support to OCP
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | pod_abbr | Yes. | the pod name abbreviation, do not give the full pod name. |
    ...    | ctr_abbr | Yes. | the container name abbreviation. |
    ...    | alias | Yes. | the alias that connected to the CU cluster. |
    ...    | gnb_index | No. | the gnb index, default value is 0. |

    ...    *RETURN VALUE*
    ...    the container id
    ...
    ...  *Example*
    ...    Get container id without alias parameter:
    ...    | ${container_id} | Get CU Container ID | pod_abbr=upue |  ctr_abbr=l2hicu |
    ...
    ...    Get container id with alias parameter:
    ...    | ${alias} | Connect To CU Node  | ${pod_abbr}|
    ...    | ${container_id} | Get CU Container ID | pod_abbr=upue |  ctr_abbr=l2hicu | alias=${alias} |
    ...    | Disconnect Interactive Connection | ${alias} |
    ...
    ${real_alias}   Run Keyword If   "${alias}"=="${EMPTY}"   Connect To CU Node  pod_abbr=${pod_abbr}  gnb_index=${gnb_index}
       ...    ELSE   Set Variable   ${alias}
    ${full_container_name}   Get CU Full Container Name By Container Abbreviation  ctr_abbr=${ctr_abbr}  gnb_index=${gnb_index}
    ${ssh_command}   Set Variable   sudo crictl ps|grep "${full_container_name} "|awk '{print $1}'
    ${out}  issh.Execute  command=${ssh_command}  alias=${real_alias}
    ${out}  Strip Prompt  ${out}

    ${container_id}   Set Variable  ${out.strip()}

    [Return]  ${container_id}





Get CU Pods Info
   [Arguments]  ${pod_name}=all  ${alias}=default  ${gnb_index}=0
   [Documentation]  get the all CU pods info or get the given pod info.
   ...  author:            calla.wang@nokia-sbell.com
   ...  modified by:       <06-23-2021>, <calwang>, <initial created>
   ...    | Input Parameters | Man. | Description |
   ...    | pod_name | Yes. | the pod name abbreviation or the full pod name |

   ...    *RETURN VALUE*
   ...    the pod info
   ...    {'po-cran5-cpcl-0': {'age': '5d23h', 'ip': '10.10.4.26',
   ...                         'name': 'po-cran5-cpcl-0', 'node': 'ngdc-i201-3m12w-workerbm-0',
   ...                         'nominated_node': '<none>', 'readiness_gates': '<none>', 'ready': '3/3',
   ...                         'restarts': '0', 'status': 'Running'},
   ...      'po-cran5-cpif-0': {'age': '5d23h', 'ip': '10.10.66.133',
   ...                           'name': 'po-cran5-cpif-0', 'node': 'ngdc-i201-3m12w-workerbm-6',
   ...                           'nominated_node': '<none>', 'readiness_gates': '<none>', 'ready': '5/5',
   ...                           'restarts': '0', 'status': 'Running'}
   ...      ........
   ...    }
   ...    OR
   ...    {'po-cran5-cpif-0': {'age': '5d23h', 'ip': '10.10.66.133',
   ...                         'name': 'po-cran5-cpif-0', 'node': 'ngdc-i201-3m12w-workerbm-6',
   ...                         'nominated_node': '<none>', 'readiness_gates': '<none>', 'ready': '5/5',
   ...                         'restarts': '0', 'status': 'Running'}
   ...    }
   ...  *Example*
   ...    | ${alias}= | Connect To CU K8S Master With Admin  |  |
   ...    | ${pod_name} | Get CU Pods Info | all | ${alias} |
   ...    | Disconnect Interactive Connection | ${alias} |
   ...
   ...    | ${alias}= | Connect To CU K8S Master With Admin  |  |
   ...    | ${pod_name} | Get CU Pods Info | cpif | ${alias} |
   ...    | Disconnect Interactive Connection | ${alias} |

   ${ns}   Get CU Namespace From Testline  ${gnb_index}
   ${pod_name}=  Run Keyword If  '${pod_name}'!='all' and '${ns}' not in '${pod_name}'
   ...  Get CU Full Pod Name By Pod Abbreviation  ${pod_name}  ${alias}  ${gnb_index}
   ...  ELSE  set variable  ${pod_name}

   ${cmd}  set variable if  '${pod_name}'=='all'   kubectl get pods -n ${ns} -o wide
   ...  kubectl get pods ${pod_name} -n ${ns} -o wide
   ${out}  issh.Execute  command=${cmd}  alias=${alias}  check_result=${false}
   ${out}   strip prompt  ${out}
   ${out}   Set Variable  ${out.strip()}
   ${pods_info}  parse_output_with_ps_format_to_dict  ${out}
   [Return]  ${pods_info}

Get Specifical Pod Age With Tenant 
    [Arguments]  ${pod_atrr}=oamext-0   ${gnb_index}=0
    [Documentation]  get the container status in one CU pod
    ...  author:            luofei.tu@nokia-sbell.com
    ...  modified by:       <09-04-2023>, <lutu>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    | pod_atrr | No. | Pod part name or full name |
    ...    | gnb_index | No. |  gnb index |

    ...    *RETURN VALUE*
    ...    pod age
    ${pods_info}   vCU Get Pods Full Info   gnb_index=${gnb_index}
    ${itmes}  Get Dictionary Items  ${pods_info}  gnb_index=${gnb_index}
    FOR  ${pod}  ${pods_values}  IN  @{itmes}
        ${pod_age}  Set Variable If  '${pod_atrr}' in '${pod}'   ${pods_values}[age]
        Exit For Loop If   '${pod_age}' != 'None'
    END
    [Return]  ${pod_age}

Get CU One Pod Containers Status
    [Arguments]  ${pod_name}  ${alias}=default  ${gnb_index}=0
    [Documentation]  get the container status in one CU pod
    ...  author:            calla.wang@nokia-sbell.com
    ...  modified by:       <06-23-2021>, <calwang>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    | pod_name | Yes. | the pod name abbreviation or the full pod name |

    ...    *RETURN VALUE*
    ...    the container status, the key is the container name, the first value is the status, and the second value is
    ...    the container start time.
    ...    {'ctr-cran5-cpcl': {'state': 'running', 'startedAt': '2023-01-19T05:52:05Z', 'ready': True, 'restartCount': 0},
    ...     'ctr-cran5-givaxi': {'state': 'running', 'startedAt': '2023-01-19T05:52:05Z', 'ready': True, 'restartCount': 0},
    ...     'ctr-cran5-nwinit': {'state': 'running', 'startedAt': '2023-01-19T05:52:05Z', 'ready': True, 'restartCount': 0},
    ...     'ctr-cran5-nwmgmt': {'state': 'running', 'startedAt': '2023-01-19T05:52:05Z', 'ready': True, 'restartCount': 0}}

    ...  *EXAMPLE(
    ...    | ${alias}= | Connect To CU K8S Master With Admin  |  |
    ...    | ${pod_name} | Get CU One Pod Containers Status | cpif | ${alias} |
    ...    | Disconnect Interactive Connection | ${alias} |

    ${ns}   Get CU Namespace From Testline  ${gnb_index}
    ${pod_name}=  Run Keyword If  '${ns}' not in '${pod_name}'
    ...  Get CU Full Pod Name By Pod Abbreviation  ${pod_name}  ${alias}  ${gnb_index}
    ...  ELSE  set variable  ${pod_name}

    ${cmd}=  set variable  kubectl get pods ${pod_name} -n ${ns} --output=json
    ${out}  issh.Execute  command=${cmd}  alias=${alias}
    ${out}   strip prompt  ${out}
    ${out}   Set Variable  ${out.strip()}
    ${one_pod_containers_status}=  parse_one_pod_container_status_from_json_string  ${out}
    [Return]  ${one_pod_containers_status}


CU Pods Status Should Be Normal
    [Arguments]  ${pod_name}=all  ${alias}=default  ${gnb_index}=0
    [Documentation]  CU pods status should be normal, supporting one pod or all pods
    ...  author:            calla.wang@nokia-sbell.com
    ...  modified by:       <06-23-2021>, <calwang>, <initial created>
    ...    | Input Parameters | Man. | Description |

    ...    *RETURN VALUE*
    ...    None

    ...  *EXAMPLE*
    ...    | ${alias}= | Connect To CU K8S Master With Admin  |  |
    ...    | ${pod_name_list} | CU Pods Status Should Be Normal | all | ${alias} |
    ...    | Disconnect Interactive Connection | ${alias} |
    ...
    ...    | ${alias}= | Connect To CU K8S Master With Admin  |  |
    ...    | ${pod_name_list} | CU Pods Status Should Be Normal | cpif | ${alias} |
    ...    | Disconnect Interactive Connection | ${alias} |

    ${pods_info}=  Get CU Pods Info  ${pod_name}  ${alias}  ${gnb_index}
    FOR  ${pod}  IN  @{pods_info.keys()}
        ${ready}=  set variable  ${pods_info['${pod}']['ready'].split('/')}
        Run Keyword And Continue On Failure  Should Be Equal As Integers  ${ready[0]}  ${ready[1]}
        Run Keyword And Continue On Failure  Should Be Equal As Strings   ${pods_info['${pod}']['status']}  Running
    END


Get CU Pod Located Node
    [Arguments]  ${pod_abbr}   ${alias}=${EMPTY}   ${gnb_index}=0
    [Teardown]  run keyword and ignore error   run keyword if   "${alias}"=="${EMPTY}"
       ...   disconnect interactive connection  alias=${alias_new}
    [Documentation]    get the node which the pod located.
    ...  author:            calla.wang@nokia-sbell.com
    ...  modified by:       <06-23-2021>, <calwang>, <initial created>
    ...    history change: 14.7.2022,lingting.sun@nokia-sbell.com, adaption for multi gnb
    ...    history change: 14.7.2021,chris.l.cao@nokia-sbell.com, add support for EMPTY alias
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | pod_abbr | Yes. | the pod name abbreviation, do not give the full pod name. |
    ...    | alias | Yes. | the alias that connected to the CU cluster. |
    ...    | gnb_index | No. | the gnb index, default value is 0. |

    ...    *RETURN VALUE*
    ...    the node name
    ...    Example
    ...    | ${node}= | Get CU Pod Located Node | oamcm  |
    ...    or
    ...    | ${alisa}= | Connect To CU K8S Master With Admin  |  |
    ...    | ${node}= | Get CU Pod Located Node | oamcm | ${alisa} |
    ...    | Disconnect Interactive Connection | ${alias} |
    ...
    ${ns}=  Get CU Namespace From Testline  ${gnb_index}
    ${alias_new}  run keyword if   "${alias}"=="${EMPTY}"      Connect To CU K8S Master With Admin   gnb_index=${gnb_index}
    ...   ELSE    set variable   ${alias}

#    ${cmd}   set variable  kubectl get pods -n ${ns} -o wide|egrep "(-${pod_abbr}-)"|awk '{print $7}'
    ${full_pod_name}  Get CU Full Pod Name By Pod Abbreviation  pod_abbr=${pod_abbr}   alias=${alias_new}  gnb_index=${gnb_index}
    ${cmd}   set variable  kubectl get pod ${full_pod_name} -o yaml -n ${ns}|grep nodeName|awk -F ": " '{print $2}'

    ${pod_located_node}   issh.Execute  command=${cmd}   alias=${alias_new}
    ${pod_located_node}   Set Variable  ${pod_located_node.strip()}
    ${pod_located_node}   strip prompt  ${pod_located_node}
    should not be empty  ${pod_located_node}

    [Return]  ${pod_located_node}


Check vCU Pods and Containers Status With Tenant
    [Arguments]    ${gnb_index}=0
    [Documentation]  Check vCU pods and containers status
    ...   author: luofei.tu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    SCF file name
    ...
    ...    Example
    ...    | ${vcu_scf} | Get VCU Scf File From Test Line |
    ${pods_info}=    vCU Get Pods Full Info   gnb_index=${gnb_index}
    ${itmes}   get dictionary items  ${pods_info}
    FOR  ${pod}  ${pods_values}  IN  @{itmes}
        Should Be Equal    ${pods_values}[status]   Running
        ${split_ready}=    Split String    ${pods_values}[ready]    /
        Should Be Equal    ${split_ready[0]}     ${split_ready[1]}
    END

Check vCU Pods and Containers Status Should Be Expect Login With Tenant
    [Arguments]   ${pods_name}   ${gnb_index}=0
    [Documentation]  Check vCU pods should be expect
    ...   author: luofei.tu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    SCF file name
    ...
    ...    Example
    ...    | ${vcu_scf} | Get VCU Scf File From Test Line |
    ${pods_info}=    vCU Get Pods Full Info
    ${items}   get dictionary items  ${pods_info}
    FOR    ${pod}  ${pods_values}  IN  @{items}
        ${pods_}  set variable  ${pods_values}
        Exit For Loop If  '${pod}'=='${pods_name}'
    END
    Should Be Equal  ${pods_}[status]     Running
    log to console  current ${pods_name} status is ${pods_}[status]
    ${split_ready}=    Split String    ${pods_}[ready]    /
    Should Be Equal    ${split_ready[0]}     ${split_ready[1]}


UnDeploy vCU
    [Arguments]   ${gnb_index}=0
    [Documentation]    Undeploy VCU, PVC, Intnet
    ...    *AUTHOR* luofei.tu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | UnDeploy VCU For NCS |

    ${ns}  Get CU Namespace From Testline
    ${vcu_release_name_list}   Get VCU Helm List   namespace=${ns}
    vCU Cluster helm Login With Tenant
    FOR   ${release_name}  IN  @{vcu_release_name_list}
         helm.helm_delete    ${release_name}  ${ns}
         sleep  20s
    END
    run keyword and ignore error   Remove vCU Network OCP   namespace=${ns}
    Wait Until Keyword Succeeds  300   10s    Make Sure VCU Is Deleted
    [Teardown]   helm.helm_master_close

Get VCU Helm List
    [Arguments]   ${namespace}
     [Documentation]  Get vCU Package Prefix From Global Variables File
    ...    *AUTHOR* luofei.tu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | namespace | Yes | namespace |
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Get VCU Helm List | namespace |

    vCU Cluster helm Login With Tenant
    ${chart_list}   helm.helm_get_release_list  namespace=${namespace}
    @{cluster_name_list}    Create List
    @{prerequisite_name_list}    Create List
    @{cnf_name_list}    Create List
    FOR   ${i}   IN   @{chart_list}
       ${tmp}   get_from_dictionary   ${i}  name
       ${tmp_chat}   get_from_dictionary   ${i}  chart
       run keyword if   "cnf" in "${tmp_chat}"   append to list   ${cnf_name_list}   ${tmp}
       ...  ELSE IF  "cluster" in "${tmp_chat}"   append to list   ${cluster_name_list}   ${tmp}
       ...  ELSE IF  "prerequisite" in "${tmp_chat}"   append to list   ${prerequisite_name_list}   ${tmp}
    END
    ${helm_name_list_final}    Combine Lists     ${cnf_name_list}  ${prerequisite_name_list}  ${cluster_name_list}
    [Return]   ${helm_name_list_final}
    [Teardown]   helm.helm_master_close

Make Sure VCU Is Deleted
    [Arguments]     ${gnb_index}=0
    [Teardown]  Run Keyword And Ignore Error  Disconnect Interactive Connection  alias=${alias}
    [Documentation]  Make Sure VCU Is Deleted
    ...    *AUTHOR* luofei.tu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   4.8.2020,luofei.tu@nokia-sbell.com, change detecting method to 'kubectl get pod'
    ...
    ...    |  Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Make Sure VCU Is Deleted |
    ...
    ${alias}    Connect To CU K8S Master With Tenant
    ${ns}  Get CU Namespace From Testline
    ${out}  issh.Execute   command=kubectl get pod -n ${ns}  alias=${alias}
    Should Contain    ${out}   No resources found
    ${out}  issh.Execute   command=kubectl get network-attachment-definitions.k8s.cni.cncf.io -n ${ns}  alias=${alias}
    Should Contain    ${out}   No resources found


Deploy VCU
    [Arguments]   ${gnb_index}=0  ${build_number}=None  ${cnflayout}=basic  ${cpifInstanceCount}=${1}
    [Documentation]    Deploy VCU
    ...    *AUTHOR* luofei.tu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   27.6.2023,chris.l.cao@nokia-sbell.com, remove 'Get vCU Platform Name' to shorten pipeline time
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | gnb_index    | No. | the gnb index, default value is 0. |
    ...    | build_number | No. | build_number, default is None |
    ...    | cnflayout    | No. | cnflayout, default is basic |
    ...    | cpifInstanceCount | No. | cpifInstanceCount, default is 1 |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ${build_number}    Run Keyword If    '${build_number}'=='None'  Get Current CU Version
    ...   ELSE   Set Variable    ${build_number}

    ${package_name}   Get Package Prefix From Global Variables File   build_number=${build_number}
    ${conf_dic}     Get VCU One Click Config Dictionary From TestLine

    ${release_name}   Deploy VCU For OCP    build_number=${build_number}  package_name=${package_name}
    ...   cnflayout=${cnflayout}  cpifInstanceCount=${cpifInstanceCount}

    wait until keyword succeeds  30 min  20sec   CU Rest First Login
    [Teardown]  CU Logout


CU Rest First Login
   [Arguments]   ${gnb_index}=0   ${alias}=${None}   ${restapi_version}=cuoam_22r4  ${delay}=${EMPTY}
   [Documentation]  Create rest session to CU.
    ${host}   set variable  ${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}
    run keyword and ignore error  CU Rest Logout   connection=${alias}
    #${host}   set variable if   ':' in '''${host_ip}'''   [${host_ip}]    ${host_ip}
    ${status}  ${restapi_version}  Run Keyword And Ignore Error   _Get VCU Rest Api Version  gnb_index=${gnb_index}
    ${restapi_version}   Set Variable If    '${status}'=='FAIL'    ${VCU_REST_TAF_LIB_SUPPORTED_VERSION[-1]}     ${restapi_version}

    cu.connect to    host=${host}
    ...    port=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.port}
    ...    username=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...    password=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    ...    cu_version=${restapi_version}
    ...    secure=${True}
    ...    alias=${alias}
    ...    timeout=120

    Run Keyword If  "${delay}"!="${EMPTY}"  Sleep   ${delay}

    [Return]  ${alias}


Deploy VCU For OCP
    [Arguments]   ${gnb_index}=0  ${build_number}=None   ${cnflayout}=basic   ${package_name}=CU_CNF  ${cpifInstanceCount}=${1}
    [Documentation]    Download vcu zip file and upload images and create intnet,pvc,vcu
    ...    *AUTHOR* luofei.tu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...	   | build_number | Yes | build_number |
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Deploy VCU For NCS | build_number=0.250.903 |
    ...
    ${build_number}    Run Keyword If    '${build_number}'=='None'  Get Current CU Version
    ...   ELSE   Set Variable   ${build_number}
    vCU Cluster helm Login With Tenant
    ${tenant_name}     Get VCU Tenant Name
    ${tl_name}    Get TestLine Name From TestLine
    ${output}=    helm.execute_command_on_master_cluster    test -d /var/home/${tenant_name}/${build_number}
    run keyword if    '${output.status}'=='1'   _Clean Old Releases And Download New vCU Package
    ...   build_number=${build_number}  tenant_name=${tenant_name}  package_name=${package_name}

    ${download_result}   ${agent_cluster_preparation_yaml}  ${agent_prerequisite_yaml}   ${agent_cnf_yaml}
    ...   _Download And Check Agent Values Override Files  tl=${tl_name}  build=${build_number}
    ${pvc_yaml_file}   run keyword if   '${download_result}' == 'False'  Get vCU PVC Vnf Config Yaml From TestLine   gnb_index=${gnb_index}
    ...  ELSE   set variable   ${agent_prerequisite_yaml}
    ${vcu_yaml_file}   run keyword if   '${download_result}' == 'False'   Get vCU Vnf Config Yaml From TestLine  gnb_index=${gnb_index}
     ...  ELSE   set variable   ${agent_cnf_yaml}
    ${cluster_prep_yaml_file}  run keyword if   '${download_result}' == 'False'
    ...  Get vCU Cluster Prep Config Yaml From TestLine   gnb_index=${gnb_index}
    ...  ELSE   set variable   ${agent_cluster_preparation_yaml}

    ${pvc_file}   ${pvc_filename}   OperatingSystem.split_path    ${pvc_yaml_file}
    ${cnf_file}   ${cnf_filename}   OperatingSystem.split_path    ${vcu_yaml_file}
    ${cluster_file}   ${cluster_filename}   OperatingSystem.split_path    ${cluster_prep_yaml_file}

    run keyword if   "${cnflayout}" == "basic"    yaml_modify_content    file_path=${vcu_yaml_file}
    ...   key=global  modify_content=basic  child_key=cnfLayout
    ...    ELSE   yaml_modify_content    file_path=${vcu_yaml_file}
    ...   key=global  modify_content=redundant  child_key=cnfLayout

    yaml_modify_content    file_path=${vcu_yaml_file}   key=global   modify_content=${cpifInstanceCount}  child_key=cpifInstanceCount

    ${vcu_release_name}   Get VCU Release Name From Testline  gnb_index=${gnb_index}
    ${Prerequisite_release_name}  Get VCU Prerequisite Release Name From Testline  gnb_index=${gnb_index}
    ${cluster_release_name}  set variable   aic-vcu-cluster-preparation

    ${alias_k8s_tenant}   Connect To CU K8S Master With Tenant
    issh.Upload File  local_path=${pvc_yaml_file}
    ...    remote_path=/var/home/${tenant_name}/${build_number}/HelmChart/${Prerequisite_release_name}/
    ...    alias=${alias_k8s_tenant}
    issh.Upload File  local_path=${vcu_yaml_file}
    ...    remote_path=/var/home/${tenant_name}/${build_number}/HelmChart/${vcu_release_name}/
    ...    alias=${alias_k8s_tenant}
    issh.Upload File  local_path=${cluster_prep_yaml_file}
    ...    remote_path=/var/home/${tenant_name}/${build_number}/HelmChart/${cluster_release_name}/
    ...    alias=${alias_k8s_tenant}

    Create vCU Cluster Prap and Verify
    ...    remote_dst_file=/var/home/${tenant_name}/${build_number}/HelmChart/${cluster_release_name}/${cluster_filename}
    ...    remote_dst_path=/var/home/${tenant_name}/${build_number}/HelmChart/${cluster_release_name}
    ...    prep_release_name=${cluster_release_name}
    Create vCU PVC and Verify PVC creation
    ...    remote_dst_file=/var/home/${tenant_name}/${build_number}/HelmChart/${Prerequisite_release_name}/${pvc_filename}
    ...    remote_dst_path=/var/home/${tenant_name}/${build_number}/HelmChart/${Prerequisite_release_name}
    Create vCU cnf and Verify
    ...    remote_dst_file=/var/home/${tenant_name}/${build_number}/HelmChart/${vcu_release_name}/${cnf_filename}
    ...    remote_dst_path=/var/home/${tenant_name}/${build_number}/HelmChart/${vcu_release_name}


_Download And Check Agent Values Override Files
    [Arguments]   ${S3_server_dir}=http://10.109.2.147:8099/AGENT_AIC_VCU_YAML  ${tl}=7_5_UTE5GAIC001T00138  ${build}=0.250.3074  ${local_path}=/tmp
    run keyword and ignore error   Run  rm -rf ${local_path}/aic_prerequisite_yaml_vCU_0.yaml
    run keyword and ignore error   Run  rm -rf ${local_path}/aic_vcu_yaml_vCU_0.yaml
    run keyword and ignore error   Run  rm -rf ${local_path}/aic_cluster_preparation_yaml_vCU_0.yaml
    ${remote_cluster_preparation_out}   OperatingSystem.Run
    ...  wget ${S3_server_dir}/${tl}_${build}_values_override_aic_cluster_preparation_yaml_vCU_0.yaml --no-check-certificate --spider
    ${remote_prerequisite_out}   OperatingSystem.Run
    ...  wget ${S3_server_dir}/${tl}_${build}_values_override_aic_prerequisite_yaml_vCU_0.yaml --no-check-certificate --spider
    ${remote_cnf_out}   OperatingSystem.Run
    ...  wget ${S3_server_dir}/${tl}_${build}_values_override_aic_vcu_yaml_vCU_0.yaml --no-check-certificate --spider
    ${cluster_preparation_exist}    set variable if   '200 OK' in """${remote_cluster_preparation_out}"""   True    False
    ${prerequisite_exist}    set variable if   '200 OK' in """${remote_prerequisite_out}"""   True    False
    ${cnf_exist}    set variable if   '200 OK' in """${remote_cnf_out}"""   True    False
    ${res}  run keyword if    "${prerequisite_exist}"=="${True}"   run keyword and return status  OperatingSystem.Run
    ...  wget ${S3_server_dir}/${tl}_${build}_values_override_aic_prerequisite_yaml_vCU_0.yaml -O ${local_path}/aic_prerequisite_yaml_vCU_0.yaml
    ...  ELSE   set variable   ${False}
    run keyword if    "${cnf_exist}"=="${True}"  run keyword and return status  OperatingSystem.Run
    ...  wget ${S3_server_dir}/${tl}_${build}_values_override_aic_vcu_yaml_vCU_0.yaml -O ${local_path}/aic_vcu_yaml_vCU_0.yaml
    ...  ELSE   set variable   ${False}
    run keyword if    "${cluster_preparation_exist}"=="${True}"  run keyword and return status  OperatingSystem.Run
    ...  wget ${S3_server_dir}/${tl}_${build}_values_override_aic_cluster_preparation_yaml_vCU_0.yaml -O ${local_path}/aic_cluster_vCU_0.yaml
    ...  ELSE   set variable   ${False}
    ${cluster_preparation_yaml}   set variable   ${local_path}/aic_cluster_vCU_0.yaml
    ${prerequisite_yaml}   set variable   ${local_path}/aic_prerequisite_yaml_vCU_0.yaml
    ${cnf_yaml}  set variable   ${local_path}/aic_vcu_yaml_vCU_0.yaml
    [Return]   ${res}  ${cluster_preparation_yaml}  ${prerequisite_yaml}   ${cnf_yaml}


_Clean Old Releases And Download New vCU Package
    [Arguments]   ${build_number}  ${tenant_name}  ${package_name}=CU_CNF
    [Documentation]  _Clean Old Releases And Download New vCU Package
    ...  author: luofei.tu@nokia-sbell.com
    ${fuzzy_name}   _Get Install Package Fuzzy Name   ${build_number}
    helm.execute_command_on_master_cluster    cd /var/home/${tenant_name};rm -rf ${fuzzy_name}
    helm.execute_command_on_master_cluster    mkdir ${build_number}
    helm.helm_download_cnf_package    /var/home/${tenant_name}/${build_number}  ${package_name}  ${build_number}
    helm.execute_command_on_master_cluster
    ...    cd /var/home/${tenant_name}/${build_number}/HelmChart;tar -zxvf aic-vcu-${build_number}.tgz
    helm.execute_command_on_master_cluster
    ...    cd /var/home/${tenant_name}/${build_number}/HelmChart;tar -zxvf aic-vcu-prerequisite-*.tgz
    helm.execute_command_on_master_cluster
    ...    cd /var/home/${tenant_name}/${build_number}/HelmChart;tar -zxvf aic-vcu-cluster-preparation-*.tgz


Upload vCU Image To Repository For NCS
    [Arguments]  ${tenant_name}  ${gnb_index}=0  ${image_check}=False  ${build_number}=None
    [Documentation]    Upload vCU image to repository for NCS
    ...    *AUTHOR* luofei.tu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...	   | image_check | no | image_check, default is False |
    ...	   | build_number | Yes | build_number |
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Upload image to repository for NCS | build_number=0.250.800|
    ...
    ${build_number}    Run Keyword If    '${build_number}'=='None'  Get Current CU Version
    ...   ELSE   Set Variable   ${build_number}
    run keyword if  ${image_check}==False  Upload vCU Image NCS  tenant_name=${tenant_name}  gnb_index=${gnb_index}  build_number=${build_number}
    run keyword if  ${image_check}==True  log  images already exist  console=true


Upload vCU Image NCS
    [Arguments]  ${tenant_name}  ${gnb_index}=0  ${build_number}=None
    [Documentation]    Upload vCU Image
    ...    *AUTHOR* luofei.tu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Upload Image | build_number=0.250.800|
    ${build_number}    Run Keyword If    '${build_number}'=='None'  Get Current CU Version
    ...   ELSE   Set Variable   ${build_number}
    vCU Cluster helm Login With Tenant
    helm.download_onboard_app_tool    target_path=/home/${tenant_name}/${build_number}/Images    chart_version=${build_number}
    helm.execute_command_on_master_cluster
    ...    cp /home/${tenant_name}/${build_number}/Images/onBoardingApp/loadImages.sh /home/${tenant_name}/${build_number}/Images/
    helm.execute_command_on_master_cluster
    ...    cp /home/${tenant_name}/${build_number}/Images/onBoardingApp/images.properties.NCS /home/${tenant_name}/${build_number}/Images/
    helm.execute_command_on_master_cluster    cd /home/${tenant_name}/${build_number}/Images;chmod 777 *;./loadImages.sh
    log    upload images done    console=true
    [Teardown]    helm.helm_master_close


Upload vCU Image To Repository For OCP
    [Arguments]  ${tenant_name}  ${gnb_index}=0  ${image_check}=False  ${build_number}=None
    [Documentation]    Upload vCU image to repository for NCS
    ...    *AUTHOR* luofei.tu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...	   | image_check | no | image_check, default is False |
    ...	   | build_number | Yes | build_number |
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Upload image to repository for NCS | build_number=0.250.800|
    ...
    ${build_number}    Run Keyword If    '${build_number}'=='None'  Get Current CU Version
    ...   ELSE   Set Variable   ${build_number}
    run keyword if  ${image_check}==False  Upload vCU Image OCP  tenant_name=${tenant_name}   gnb_index=${gnb_index}  build_number=${build_number}
    run keyword if  ${image_check}==True  log  images already exist  console=true


Upload vCU Image OCP
    [Arguments]  ${tenant_name}   ${gnb_index}=0  ${build_number}=None
    [Documentation]    Upload vCU Image
    ...    *AUTHOR* luofei.tu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Upload Image | build_number=0.250.800|
    ${build_number}    Run Keyword If    '${build_number}'=='None'  Get Current CU Version
    ...   ELSE   Set Variable   ${build_number}
    ${ns}   Get CU Namespace From TestLine
    vCU Cluster helm Login With Tenant
    ${package_prefix}   Get Package Prefix From Global Variables File   build_number=${build_number}
    ${full_package_name}    Set Variable    ${package_prefix}_${build_number}
    helm.download_onboard_app_tool    target_path=/home/${tenant_name}/${build_number}/Image    chart_version=${full_package_name}
    helm.execute_command_on_master_cluster
    ...    cp /home/${tenant_name}/${build_number}/Image/onBoardingApp/loadImages.sh /home/${tenant_name}/${build_number}/Image/
    helm.execute_command_on_master_cluster
    ...    cp /home/${tenant_name}/${build_number}/Image/onBoardingApp/images.properties.OCP /home/${tenant_name}/${build_number}/Image/
    helm.execute_command_on_master_cluster    cd /home/${tenant_name}/${build_number}/Image;chmod 777 *;./loadImages.sh -n ${ns}
    log    upload images done    console=true
    [Teardown]    helm.helm_master_close



Remove vCU Network OCP
    [Arguments]   ${namespace}   ${gnb_index}=0
    [Documentation]    Create network and Verify network creation
    ...    *AUTHOR* luofei.tu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
   ...	   | namespace | Yes | namespace |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Remove vCU Network OCP |
    ...
    ${alias}=   Connect To CU K8S Master With Tenant
    ${cmd1}   Set Variable    result=`oc get network-attachment-definitions.k8s.cni.cncf.io -n ${namespace} | grep -iv NAMe | awk '{print $1}'`
    ${cmd2}   Set Variable   ${cmd1};oc delete network-attachment-definitions.k8s.cni.cncf.io -n ${namespace} $result
    ${status} =   issh.Execute  command=${cmd2}  alias=${alias}


Create vCU PVC and Verify PVC creation
    [Arguments]  ${gnb_index}=0  ${remote_dst_file}=values-override.yaml
    ...    ${remote_dst_path}=/home/cranuser/aic-pvc
    [Documentation]    Create PVC and Verify PVC creation
    ...    *AUTHOR* luofei.tu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...	   | remote_dst_file | Yes | remote_dst_file on OE |
    ...	   | remote_dst_path | Yes | remote_dst_path on OE |
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Create PVC and Verify PVC creation | remote_dst_file=values-override.yaml | remote_dst_path=home/cranuser/aic-pvc |
    ...
    ${pvc_release_name}   Get VCU Prerequisite Release Name From Testline
    vCU Cluster helm Login With Tenant
    ${ns}    Get CU Namespace From Testline
    helm.helm_install
    ...   ${pvc_release_name}
    ...   ${remote_dst_path}
    ...   ${ns}
    ...   value_files=${remote_dst_file}
    log    Deloy PVC done    console=true
    [Teardown]    helm.helm_master_close


Create vCU cnf and Verify
    [Arguments]   ${gnb_index}=0   ${remote_dst_file}=values-override.yaml
    ...   ${remote_dst_path}=/home/cranuser/aic-vcu
    [Documentation]    Create VCU and Verify VCU creation
    ...    *AUTHOR* luofei.tu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...	   | remote_dst_file | Yes | remote_dst_file on OE |
    ...	   | remote_dst_path | Yes | remote_dst_path on OE |
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Create VCU and Verify VCU creation | remote_dst_file=values-override.yaml | remote_dst_path=home/cranuser/aic-vcu |
    ...

    ${vcu_release_name}   Get VCU Release Name From Testline
    vCU Cluster helm Login With Tenant
    ${ns}    Get CU Namespace From Testline
    helm.helm_install
    ...   ${vcu_release_name}
    ...   ${remote_dst_path}
    ...   ${ns}
    ...   value_files=${remote_dst_file}
    log    Deloy vCU done    console=true
    [Teardown]    helm.helm_master_close

Create vCU Cluster Prap and Verify
    [Arguments]   ${gnb_index}=0   ${remote_dst_file}=values-override.yaml
    ...   ${remote_dst_path}=/home/cranuser/aic-vcu   ${prep_release_name}=aic-vcu-cluster-preparation
    [Documentation]    Create Cluster Prap and Verify VCU creation
    ...    *AUTHOR* luofei.tu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...	   | remote_dst_file | Yes | remote_dst_file on OE |
    ...	   | remote_dst_path | Yes | remote_dst_path on OE |
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Create vCU Cluster Prap and Verify | remote_dst_file=values-override.yaml | remote_dst_path=home/cranuser/aic-vcu |
    ...
    vCU Cluster helm Login With Tenant
    ${ns}    Get CU Namespace From Testline
    helm.helm_install
    ...   ${prep_release_name}
    ...   ${remote_dst_path}
    ...   ${ns}
    ...   value_files=${remote_dst_file}
    log    Deloy aic-vcu-cluster-preparation done    console=true
    [Teardown]    helm.helm_master_close


CU OCP OC Login Auth
    [Arguments]   ${gnb_index}=0
    _CU OC Login Auth With OCP Admin
    _CU OC Login Auth With OCP Tenant


_CU OC Login Auth With OCP Admin
    [Arguments]   ${gnb_index}=0
    [Documentation]   _CU OC Login Auth With OCP Admin
    ...   *AUTHOR* luofei.tu@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...   | _CU OC Login Auth With OCP Admin |
    ...
    ${alias}    Connect To CU K8S Master With Tenant    ${gnb_index}
    ${out}  issh.Execute   command=oc login -u ${OCP_LOGIN_USERNAME} -p ${OCP_LOGIN_PASSWORD} --insecure-skip-tls-verify=true
    ...   alias=${alias}   check_result=${False}
    [Teardown]   issh.disconnect   alias=${alias}


_CU OC Login Auth With OCP Tenant
    [Arguments]   ${gnb_index}=0
    [Documentation]  _CU OC Login Auth With OCP Tenant
    ...   *AUTHOR* luofei.tu@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...   | _CU OC Login Auth With OCP Tenant |
    ...
    ${alias}    Connect To CU K8S Master With Tenant
    ${out}  issh.Execute   command=oc login -u ${OCP_LOGIN_USERNAME} -p ${OCP_LOGIN_PASSWORD} --insecure-skip-tls-verify=true
    ...   alias=${alias}
    [Teardown]   issh.disconnect   alias=${alias}



Construct VCU Scf File Name
    [Arguments]  ${build_number}=None
    [Documentation]  Construct VCU Scf File Name
    ...  author: luofei.tu@nokia-sbell.com
    ${build_number}    Run Keyword If    '${build_number}'=='None'  Get Current CU Version
    ...   ELSE   Set Variable   ${build_number}
    ${sub_number_list}   set variable   ${build_number.split(".")}
    ${scf_file_name}   set variable   CU_SCF_${sub_number_list[0]}.${sub_number_list[1]}.xml
    [Return]    ${scf_file_name}


vCU Get Pods Full Info
    [Arguments]    ${pod_name}=all   ${gnb_index}=0
    [Documentation]  get pods full infomation
    ...  author: luofei.tu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | pod_name | No. | the pods name that containers belong to, default value is all pods |
    ...    | namespace | No. | the namespace that the pod belongs to, if not given, using the tenant namespace |
    ...    *RETURN VALUE*
    ...    pods info dict
    vCU Cluster helm Login With Tenant   gnb_index=${gnb_index}
    ${ns}    Get CU Namespace From Testline   gnb_index=${gnb_index}
    ${pods_info}=    get_vdu_pods_info    ${pod_name}    namespace=${ns} # just use get_vdu_pods_info to get vCU pods info
    ${Pods_Info}     Set Variable     ${pods_info}
    [Return]  ${Pods_Info}
    [Teardown]    helm.helm_master_close



Get CU Container Name Prefix
    [Arguments]  ${gnb_index}=0
    [Documentation]    Get CU Container Name Prefix like ctr-cran1-
    ...  author:            calla.wang@nokia-sbell.com
    ...  modified by:       <06-23-2021>, <calwang>, <initial created>
    ...    history change: 14.7.2022,lingting.sun@nokia-sbell.com, adaption for multi gnb
    ...    history change: 14.7.2021,chris.l.cao@nokia-sbell.com, rename KW to 'Get CU Container Name Prefix' and optimize code
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | gnb_index | No. | the gnb index, default value is 0. |

    ...    *RETURN VALUE*
    ...    CU Pod Name Prefix
    ...
#    ${r}  ${out}  run keyword and ignore error    set variable  ${G_CU_CONTAINER_PREFIX}
#    return from keyword if   "${r}"=="PASS"   ${G_CU_CONTAINER_PREFIX}
    ${G_CU_POD_PREFIX}   ${G_CU_CONTAINER_PREFIX}=   _Set CU Pod And Container Name Prefix   gnb_index=${gnb_index}
    [Return]  ${G_CU_CONTAINER_PREFIX}



_Set CU Pod And Container Name Prefix
    [Arguments]  ${gnb_index}=0
    [Teardown]  Run Keyword And Ignore Error   Disconnect Interactive Connection   ${alias}
    [Documentation]    set cu pod and container name prefix, like po-cran1- and ctr-cran1-
    ...  *Author* calla.wang@nokia-sbell.com
    ...  *Change History*:
    ...  | Date | Who | What and How
    ...  | 06-23-2021 | calwang | initial created |
    ...  | 14.7.2021 | chris.l.cao@nokia-sbell.com | rename KW to private KW, and let it be called in 'aic common test setup' |
    ...  | 26.7.2021 | chris.l.cao@nokia-sbell.com | support sudo for cbis-admin user |
    ...  | 28.7.2021 | chris.l.cao@nokia-sbell.com | add to check "No resources found" not in ${out} |
    ...  | 20.1.2022 | rui.3.li@nokia-sbell.com | take sudo out, and change check_result to false when execute command |
    ...  *Arguments Description*
    ...  | Input Parameters | Man. | Description |
    ...  | gnb_index | No. | the gnb index, default value is 0. |
    ...  *RETURN VALUE*
    ...  - none, but will set test variable ${G_CU_POD_PREFIX} and ${G_CU_CONTAINER_PREFIX}
    ...
    ${ns}=  Get CU Namespace From Testline  ${gnb_index}
    ${alias}=     Connect To CU K8S Master With Tenant   gnb_index=${gnb_index}
    sleep   1

    ${out}  issh.Execute   command=kubectl get pods -n ${ns}  alias=${alias}   check_result=${False}
    ${out}   strip prompt   ${out}
    should be true   "No resources found" not in """${out}"""

    ${out}  issh.Execute   command=kubectl get pods -n ${ns}|grep -E "\\-pm\\-"|awk -F "-pm-" '{print $1}'  alias=${alias}
    ...    check_result=${False}
    ${pod_prefix}  strip prompt  ${out}
    ${pod_prefix}   set variable if   ${pod_prefix.__len__()>0}   ${pod_prefix}-   ${EMPTY}

    ${G_CU_POD_PREFIX}   set variable   ${pod_prefix}
#    set test variable   ${G_CU_POD_PREFIX}

    ${out}   issh.Execute
    ...   command=kubectl describe pod ${pod_prefix}pm-0 -n ${ns}|grep pmcore:|head -n 1|awk -F pmcore '{print $1}'
    ...    alias=${alias}    check_result=${False}
    ${out}   strip prompt  ${out}
    ${out}   set variable   ${out.strip()}
    ${container_prefix}   set variable   ${out}

    ${G_CU_CONTAINER_PREFIX}   set variable    ${container_prefix}
#    set test variable   ${G_CU_CONTAINER_PREFIX}
    [Return]   ${G_CU_POD_PREFIX}   ${G_CU_CONTAINER_PREFIX}


Get CU Full Container Name By Container Abbreviation
    [Arguments]  ${ctr_abbr}   ${gnb_index}=0
    [Documentation]  get the given cu container full name by the given container abbreviation,
    ...  You should call the keyword - Set CU Pod And Container Name Prefix firstly before using this keyword.
    ...  author:            calla.wang@nokia-sbell.com
    ...  modified by:       <06-23-2021>, <calwang>, <initial created>
    ...  modified by:       <07-29-2021>, <lutu>, <miss G_CU_CONTAINER_PREFIX>
    ...  history change: 14.7.2022,lingting.sun@nokia-sbell.com, adaption for multi gnb
    ...    | Input Parameters | Man. | Description |
    ...    | ctn_abbr | Yes. | the container name abbreviation. |

    ...    *RETURN VALUE*
    ...    the container full name
    ...  *Example*
    ...    | Set CU Pod And Container Name Prefix |
    ...    | ${ctr_name} | Get CU Full Container Name By Container Abbreviation | oamcm |
    ${G_CU_CONTAINER_PREFIX}=    Get CU Container Name Prefix   gnb_index=${gnb_index}
    ${start_with_prefix}   set variable  ${ctr_abbr.startswith("${G_CU_CONTAINER_PREFIX}")}
    return from keyword if   "${start_with_prefix}"=="${True}"      ${ctr_abbr}

    ${cu_full_ctr_name}   set variable  ${G_CU_CONTAINER_PREFIX}${ctr_abbr}
    [Return]  ${cu_full_ctr_name}


Get CU Full Pod Name By Pod Abbreviation
    [Arguments]  ${pod_abbr}  ${alias}=default  ${gnb_index}=0   ${use_m2m}=${True}
    [Documentation]  get the full pod name by pod abbreviation using kubectl get pods command。
    ...   For 2N deployment, it will return active POD name.
    ...  author:            calla.wang@nokia-sbell.com
    ...  modified by:       <06-23-2021>, <calwang>, <initial created>
    ...    2021.7.26,chris.l.cao@nokia-sbell.com, add sudo for cbis-admin user
    ...    2022.4.21,chris.l.cao@nokia-sbell.com, add to support 2N
    ...    2023.4.16,chris.l.cao@nokia-sbell.com, add '--color=never'
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | pod_abbr | Yes. | the pod name abbreviation. |

    ...    *RETURN VALUE*
    ...    the pod full name
    ...  *Example*
    ...    | ${alias}= | Connect To CU K8S Master With Admin  |  |
    ...    | ${pod_name} | Get CU Full Pod Name By Pod Abbreviation | oamcm | ${alias} |
    ...    | Disconnect Interactive Connection | ${alias} |
    ...
    ${ns}   Get CU Namespace From Testline  ${gnb_index}
#    ${cmd}   set variable   kubectl get pods -n ${ns}|egrep -w "(${pod_abbr})" |awk '{print $1}'
    ${cmd}   Set Variable   oc get pods -n ${ns}|egrep "(${pod_abbr})" --color=never|awk '{print $1}'
    ${out}   issh.Execute  command=${cmd}   check_result=${False}  alias=${alias}

    ${out}   strip prompt  ${out}
    ${full_pod_name}   Set Variable  ${out.strip()}
    ${full_pod_name_list}   String.Split To Lines   ${full_pod_name}
    Run Keyword If   ${full_pod_name_list.__len__()}==0  Fail   Can not get pod by pod_abbr:${pod_abbr}!
    ...  ELSE IF   ${full_pod_name_list.__len__()}==1    Return From Keyword   ${full_pod_name_list[0]}

    ${active_pod_name}   CU Get Active Pod Name  pod_name=${pod_abbr}    alias=${alias}   use_m2m=${use_m2m}
#    ${cmd}   set variable   kubectl get pods -n ${ns}|egrep -w "(${active_pod_name})" --color=never|awk '{print $1}'
    ${cmd}   set variable   kubectl get pods -n ${ns}|egrep "(-${active_pod_name})" --color=never|awk '{print $1}'
    ${out}   issh.Execute  command=${cmd}   check_result=${False}  alias=${alias}
    ${out}   strip prompt  ${out}
    ${active_pod_full_name}   Set Variable  ${out.strip()}

    [Return]  ${active_pod_full_name}


CU Get Active Pod Name
    [Arguments]  ${pod_name}  ${container}=${EMPTY}  ${alias}=default   ${gnb_index}=0   ${use_m2m}=${True}
    [Documentation]    CU Get Active Pod Name
    ...    *AUTHOR* nate_lee.li@nokia-sbell.com
    ...    *Change History*
    ...    | date | who | what and how |
    ...    | 21.4.2022 | chris.l.cao@nokia-sbell.com | support not using container parameter, update KW description |
    ...    | 7.5.2022 | rui.3.li@nokia-sbell.com | get by rest api |
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | pod_name          | Yes  | pod name, eg, cpif,cpcl |
    ...    | container         | no   | container name, e.g. cpif, cpnrt, etc. |
    ...    | alias             | No   | alias, Default value is default |
    ...
    ...    *RETURN VALUE*
    ...    return the number of active pod, e.g. cpif-0 or cpif-1
    ...
    ...    Example
    ...    | ${active_pod_name}  | CU Get Active Pod Name | pod_name=cpif |
    ...
    ${full_pod_name}    CU Get Active Pod Name By Specified Pod    ${pod_name}   use_m2m=${use_m2m}
    ${name_list}    Split String    ${full_pod_name}    -
    ${active_pod_name}    Set Variable     ${name_list}[-2]-${name_list}[-1]

    [Return]   ${active_pod_name}


CU Get Standby Pod Name
    [Arguments]  ${pod_name}  ${container}=${EMPTY}  ${alias}=default   ${gnb_index}=0   ${use_m2m}=${True}
    [Documentation]    CU Get Standby Pod Name
    ...    *AUTHOR* nate_lee.li@nokia-sbell.com
    ...    *Change History*
    ...    | date | who | what and how |
    ...    | 21.4.2022 | chris.l.cao@nokia-sbell.com | support not using container parameter, update KW description |
    ...    | 7.5.2022 | rui.3.li@nokia-sbell.com | get by rest api |
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | pod_name          | Yes  | pod name, eg, cpif,cpcl |
    ...    | container         | no   | container name, e.g. cpif, cpnrt, etc. |
    ...    | alias             | No   | alias, Default value is default |
    ...
    ...    *RETURN VALUE*
    ...    return the number of active pod, e.g. cpif-0 or cpif-1
    ...
    ...    Example
    ...    | ${standby_pod_name}  | CU Get Standby Pod Name | pod_name=cpif |
    ...
    ${full_pod_name}    CU Get Standby Pod Name By Specified Pod    ${pod_name}   use_m2m=${use_m2m}
    ${name_list}    Split String    ${full_pod_name}    -
    ${standby_pod_name}    Set Variable     ${name_list}[-2]-${name_list}[-1]

    [Return]   ${standby_pod_name}
