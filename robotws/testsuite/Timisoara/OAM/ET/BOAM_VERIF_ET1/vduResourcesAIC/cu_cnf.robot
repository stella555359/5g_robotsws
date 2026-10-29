*** Settings ***
Documentation
...     RF5.0 issues




#*** Variables ***


*** Keyword ***

vCU Cluster helm Login With Tenant
    [Arguments]  ${gnb_index}=0
     [Documentation]    helm connect to CU cluster with tenant permission
    ...  author:            luofei.tu@nokia-sbell.com
    ...  modified by:        <07-12-2021>, <luofei.tu>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    | gnb_index | No. | the gnb index, default value is 0. |

    ...    *RETURN VALUE*
    ...    the connection alias used to execute command later.
    ...    Example
    ...    |  vCU Cluster helm Login With Tenant  |    |
    ${conn}=    helm.helm_master_connect
    ...  ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.addr}
    ...  22
    ...  ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.username}
    ...  ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.password}
    [Return]   ${conn}


Get CU Pod Located Node
    [Arguments]  ${pod_abbr}   ${alias}=${EMPTY}   ${gnb_index}=0
    [Teardown]  run keyword and ignore error   run keyword if   "${alias}"=="${EMPTY}"
       ...   disconnect interactive connection  alias=${alias_new}
    [Documentation]    get the node which the pod located.
    ...  author:            calla.wang@nokia-sbell.com
    ...  modified by:       <06-23-2021>, <calwang>, <initial created>
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

    ${cmd}   set variable  kubectl get pods -n ${ns} -o wide|egrep "(-${pod_abbr}-)"|awk '{print $7}'
    ${pod_located_node}   issh.Execute  command=${cmd}   alias=${alias_new}
    ${pod_located_node}   Set Variable  ${pod_located_node.strip()}
    ${pod_located_node}   strip prompt  ${pod_located_node}
    should not be empty  ${pod_located_node}

    [Return]  ${pod_located_node}


_Set CU Pod And Container Name Prefix
    [Arguments]  ${gnb_index}=0
    [Documentation]    set cu pod and container name prefix, like po-cran1- and ctr-cran1-
    ...  author:            calla.wang@nokia-sbell.com
    ...  modified by:       <06-23-2021>, <calwang>, <initial created>
    ...    14.7.2021,chris.l.cao@nokia-sbell.com, rename KW to private KW, and let it be called in 'aic common test setup'
    ...    26.7.2021,chris.l.cao@nokia-sbell.com, support sudo for cbis-admin user
    ...    28.7.2021,chris.l.cao@nokia-sbell.com, add to check "No resources found" not in ${out}
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | gnb_index | No. | the gnb index, default value is 0. |

    ...    *RETURN VALUE*
    ...    the node name
    ...
    ${ns}=  Get CU Namespace From Testline  ${gnb_index}
    ${alias}=    Connect To CU K8S Master With Admin    gnb_index=${gnb_index}

    ${vcu_k8s_master_ssh_connection_info}   Get VCU K8s Admin SSH Connection Info   gnb_index=${gnb_index}

    ${sudo}  Get Sudo For VCU K8s Admin Command  gnb_index=${gnb_index}

    ${out}  issh.Execute   command=${sudo} kubectl get pods -n ${ns}  alias=${alias}
    should be true   "No resources found" not in """${out}"""

    ${out}  issh.Execute   command=${sudo} kubectl get pods -n ${ns}|grep -E "\\-pm\\-"|awk -F "-pm-" '{print $1}'  alias=${alias}
    ${pod_prefix}  strip prompt  ${out}
    ${pod_prefix}   set variable if   ${pod_prefix.__len__()>0}   ${pod_prefix}-   ${EMPTY}
    #set suite variable   ${G_CU_POD_PREFIX}    ${pod_prefix}
    ${G_CU_POD_PREFIX}   set variable   ${pod_prefix}
    set test variable   ${G_CU_POD_PREFIX}

    ${out}   issh.Execute
    ...   command=${sudo} kubectl describe pod ${pod_prefix}pm-0 -n ${ns}|grep pmcore:|head -n 1|awk -F pmcore '{print $1}'
    ...    alias=${alias}
    ${out}   strip prompt  ${out}
    ${out}   set variable   ${out.strip()}
    ${container_prefix}   set variable   ${out}
    #set suite variable   ${G_CU_CONTAINER_PREFIX}  ${container_prefix}
    ${G_CU_CONTAINER_PREFIX}   set variable    ${container_prefix}
    set test variable   ${G_CU_CONTAINER_PREFIX}

    [Teardown]  Disconnect Interactive Connection   ${alias}


Get CU Pod Name Prefix
    #[Arguments]  ${gnb_index}=0
    [Documentation]    Get CU Pod Name Prefix like po-cran1-
    ...  author:            calla.wang@nokia-sbell.com
    ...  modified by:       <06-23-2021>, <calwang>, <initial created>
    ...    history change: 14.7.2021,chris.l.cao@nokia-sbell.com, rename KW to 'Get CU Pod Name Prefix' and optimize code
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | gnb_index | No. | the gnb index, default value is 0. |

    ...    *RETURN VALUE*
    ...    CU Pod Name Prefix
    ...
    ${r}  ${out}  run keyword and ignore error   set variable   ${G_CU_POD_PREFIX}
    return from keyword if  "${r}"=="PASS"   ${G_CU_POD_PREFIX}
    #${ns}=  Get CU Namespace From Testline  ${gnb_index}
    #${alias}=  Connect To CU K8S Master With Admin    gnb_index=${gnb_index}
    #${out}  issh.Execute   command=kubectl get pods -n ${ns}|grep -E "\\-pm\\-"|awk -F "-pm-" '{print $1}'  alias=${alias}
    #${pod_prefix}  strip prompt  ${out}

    #${G_CU_POD_PREFIX}   set variable if   ${pod_prefix.__len__()>0}   ${pod_prefix}-   ${EMPTY}
    #set test variable    ${G_CU_POD_PREFIX}
    _Set CU Pod And Container Name Prefix
    [Return]  ${G_CU_POD_PREFIX}
    #[Teardown]  run keyword and ignore error   Disconnect Interactive Connection   ${alias}


Get CU Container Name Prefix
    #[Arguments]  ${gnb_index}=0
    [Documentation]    Get CU Container Name Prefix like ctr-cran1-
    ...  author:            calla.wang@nokia-sbell.com
    ...  modified by:       <06-23-2021>, <calwang>, <initial created>
    ...    history change: 14.7.2021,chris.l.cao@nokia-sbell.com, rename KW to 'Get CU Container Name Prefix' and optimize code
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | gnb_index | No. | the gnb index, default value is 0. |

    ...    *RETURN VALUE*
    ...    CU Pod Name Prefix
    ...
    ${r}  ${out}  run keyword and ignore error    set variable  ${G_CU_CONTAINER_PREFIX}
    return from keyword if   "${r}"=="PASS"   ${G_CU_CONTAINER_PREFIX}
   # ${pod_prefix}   Get CU Pod Name Prefix

    #${ns}=  Get CU Namespace From Testline  ${gnb_index}
    #${alias}=   Connect To CU K8S Master With Admin    gnb_index=${gnb_index}

    #${out}   issh.Execute
    #...   command=kubectl describe pod ${pod_prefix}pm-0 -n ${ns}|grep pmcore:|head -n 1|awk -F pmcore '{print $1}'
    #...    alias=${alias}
    #${out}   strip prompt  ${out}
    #${G_CU_CONTAINER_PREFIX}   set variable   ${out.strip()}
    #set test variable   ${G_CU_CONTAINER_PREFIX}
    _Set CU Pod And Container Name Prefix
    [Return]  ${G_CU_CONTAINER_PREFIX}
    #[Teardown]  run keyword and ignore error   Disconnect Interactive Connection   ${alias}


CU Kubectl Exec
    [Arguments]  ${pod_abbr}   ${container}   ${command}   ${alias}=default   ${check_result}=${True}  ${gnb_index}=0
    [Documentation]  execute kubectl exec command in CU cluster
    ...  author:            calla.wang@nokia-sbell.com
    ...  modified by:       <06-23-2021>, <calwang>, <initial created>
    ...    26.7.2021,chris.l.cao@nokia-sbell.com, add sudo for cbis-admin user
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | pod_abbr | Yes. | the pod name abbreviation, do not give the full pod name. |
    ...    | container | Yes. | the container name abbreviation. |
    ...    | command | Yes. | the command need to be executed. |
    ...    | alias | Yes. | the alias that connected to the CU cluster. |
    ...    | gnb_index | No. | the gnb index, default value is 0. |

    ...    *RETURN VALUE*
    ...    the command output
    ...  *Example*
    ...    | ${alisa}= | Connect To CU K8S Master With Admin  |  |
    ...    | ${output}= | CU Kubectl Exec | oamcm | oamcm | date | ${alias} |
    ...    | Disconnect Interactive Connection | ${alias} |

    ${ns}   Get CU Namespace From Testline  ${gnb_index}
    ${cu_full_container_name}  Get CU Full Container Name By Container Abbreviation  ${container}
    ${cu_full_pod_name}=  Get CU Full Pod Name By Pod Abbreviation  ${pod_abbr}  ${alias}  ${gnb_index}

    ${sudo_outer}  Get VCU Sudo For Current User   alias=${alias}

    ${kubectl_cmd}   Set Variable   ${sudo_outer} kubectl exec -it ${cu_full_pod_name} -c ${cu_full_container_name} -n ${ns} -- ${command}
    ${out}   issh.Execute    command=${kubectl_cmd}   check_result=${check_result}   alias=${alias}
    ${out}   strip prompt  ${out}
    [Return]  ${out}

Trigger CU Container Recovery
    [Arguments]   ${pod_abbr}   ${container}  ${alias}=default  ${process_name}=CCSMCU  ${check_result}=${True}  ${gnb_index}=0
    [Documentation]  trigger cu container recovery by killing the ministarter process
    ...  author:            calla.wang@nokia-sbell.com
    ...  modified by:       <06-23-2021>, <calwang>, <initial created>
    ...  modified by:       <07-29-2021>, <lutu>, <replace kill 1 with pkill CCSMCU>
    ...    | Input Parameters | Man. | Description |
    ...    | pod_abbr | Yes. | the pod name abbreviation, do not give the full pod name. |
    ...    | container | Yes. | the container name abbreviation. |
    ...    | alias | Yes. | the alias that connected to the CU cluster. |
    ...    | gnb_index | No. | the gnb index, default value is 0. |

    ...    *RETURN VALUE*
    ...    None
    ...  *Example*
    ...    | ${alisa}= | Connect To CU K8S Master With Admin  |  |
    ...    | Trigger CU Container Recovery | oamcm | oamcm | ${alias} |
    ...    | Disconnect Interactive Connection | ${alias} |
    ${cmd}  set variable  /bin/sh -c "pkill ${process_name}"
    CU Kubectl Exec  ${pod_abbr}  ${container}  ${cmd}  alias=${alias}  check_result=${check_result}  gnb_index=${gnb_index}

Trigger CU Pod Recovery
    [Arguments]  ${pod_name}  ${alias}=default   ${gnb_index}=0 #${check_result}=${True}
    [Documentation]  trigger cu pod recovery by deleting the pod
    ...  author:            calla.wang@nokia-sbell.com
    ...  modified by:       <06-23-2021>, <calwang>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    | pod_name | Yes. | the pod name abbreviation or the full pod name |
    ...    | alias | Yes. | the alias that connected to the CU cluster. |
    ...    | gnb_index | No. | the gnb index, default value is 0. |

    ...    *RETURN VALUE*
    ...    the command output
    ...  *Example*
    ...    | ${alisa}= | Connect To CU K8S Master With Admin  |  |
    ...    | Trigger CU Pod Recovery | oamcm | ${alias} |
    ...    | Disconnect Interactive Connection | ${alias} |
    ${ns}   Get CU Namespace From Testline  ${gnb_index}
    ${pod_name}=  Run Keyword If  '${ns}' not in '${pod_name}'
    ...  Get CU Full Pod Name By Pod Abbreviation  ${pod_name}  ${alias}  ${gnb_index}
    ...  ELSE  set variable  ${pod_name}

    ${out}  issh.Execute  command=kubectl delete pod ${pod_name} -n ${ns}  alias=${alias}
    ${out}   strip prompt  ${out}
    ${out}   Set Variable  ${out.strip()}
    [Return]  ${out}

Trigger CU Process Recovery
    [Arguments]   ${pod_abbr}   ${container}   ${process}  ${alias}=default   ${check_result}=${True}  ${gnb_index}=0
    [Documentation]  trigger cu process recovery by killing it
    ...  author:            calla.wang@nokia-sbell.com
    ...  modified by:       <06-23-2021>, <calwang>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    | pod_abbr | Yes. | the pod name abbreviation, do not give the full pod name. |
    ...    | container | Yes. | the container name abbreviation. |
    ...    | process | Yes. | the process, like l2hicu. |
    ...    | alias | Yes. | the alias that connected to the CU cluster. |
    ...    | gnb_index | No. | the gnb index, default value is 0. |

    ...    *RETURN VALUE*
    ...    None
    ...  *Example*
    ...    | ${alisa}= | Connect To CU K8S Master With Admin  |  |
    ...    | Trigger CU Process Recovery | oamcm | oamcm | xxx | ${alias} |
    ...    | Disconnect Interactive Connection | ${alias} |
    ${cmd}  set variable  bash -c "ps -ef|grep ${process}|awk '{print $2}'|xargs kill -9"
    CU Kubectl Exec  ${pod_abbr}  ${container}  ${cmd}  alias=${alias}  check_result=${check_result}  gnb_index=${gnb_index}

Trigger CU Pod Recovery Together
    [Arguments]  ${pod_abbr}  ${alias}=default  ${gnb_index}=0
    [Documentation]  get the full pod name by pod abbreviation using kubectl get pods command
    ...  author:            rebecca.yan@nokia-sbell.com
    ...  modified by:       <10-01-2021>, <rebecca>, <initial created>
    ...    2021.7.26,chris.l.cao@nokia-sbell.com, add sudo for cbis-admin user
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | pod_abbr | Yes. | the pod name abbreviation. |

    ...    *RETURN VALUE*
    ...    the pod full name
    ...  *Example*
    ...    | ${alias}= | Connect To CU K8S Master With Admin  |  |
    ...    | Trigger CU Pod Recovery Together | oamcm | ${alias} |
    ...    | Disconnect Interactive Connection | ${alias} |
    ...
    ${pods_name_list}   create list
    ${sudo_outer}  Get Sudo For VCU K8s Admin Command  gnb_index=${gnb_index}
    ${ns}   Get CU Namespace From Testline  ${gnb_index}
    ${cmd}   set variable   ${sudo_outer} kubectl get pods -n ${ns}|egrep "(${pod_abbr})" |awk '{print $1}'|xargs kubectl delete pod -n ${ns}
    ${out}   issh.Execute  command=${cmd}   alias=${alias}
    ${out}   strip prompt  ${out}
    ${out}   set variable  ${out.strip()}
    [Return]  ${out}

Get CU Container ID
    [Arguments]  ${pod_abbr}   ${ctn_abbr}  ${alias}=default  #${gnb_index}=0
    [Documentation]  get the given cu container id
    ...  author:            calla.wang@nokia-sbell.com
    ...  modified by:       <06-23-2021>, <calwang>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    | pod_abbr | Yes. | the pod name abbreviation, do not give the full pod name. |
    ...    | container | Yes. | the container name abbreviation. |
    ...    | alias | Yes. | the alias that connected to the CU cluster. |
    ...    | gnb_index | No. | the gnb index, default value is 0. |

    ...    *RETURN VALUE*
    ...    the container id
    ...  *Example*
    ...    | ${alias}= | Connect To CU Node  | ${pod_abbr}|
    ...    | Get CU Container ID | oamcm | oamcm | ${alias} |
    ...    | Disconnect Interactive Connection | ${alias} |
    ...
    ${cu_full_ctn_name}=  Get CU Full Container Name By Container Abbreviation   ${ctn_abbr}
    ${out}=  issh.Execute  command=docker ps -q -f name=.*${cu_full_ctn_name}.*  alias=${alias}
    ${out}   strip prompt  ${out}
    ${cu_ctn_id}   set variable   ${out.strip()}
    [Return]  ${cu_ctn_id}

Get CU Full Container Name By Container Abbreviation
    [Arguments]  ${ctr_abbr}
    [Documentation]  get the given cu container full name by the given container abbreviation,
    ...  You should call the keyword - Set CU Pod And Container Name Prefix firstly before using this keyword.
    ...  author:            calla.wang@nokia-sbell.com
    ...  modified by:       <06-23-2021>, <calwang>, <initial created>
    ...  modified by:       <07-29-2021>, <lutu>, <miss G_CU_CONTAINER_PREFIX>
    ...    | Input Parameters | Man. | Description |
    ...    | ctn_abbr | Yes. | the container name abbreviation. |

    ...    *RETURN VALUE*
    ...    the container full name
    ...  *Example*
    ...    | Set CU Pod And Container Name Prefix |
    ...    | ${ctr_name} | Get CU Full Container Name By Container Abbreviation | oamcm |
    ${G_CU_CONTAINER_PREFIX}=    Get CU Container Name Prefix
    ${start_with_prefix}   set variable  ${ctr_abbr.startswith("${G_CU_CONTAINER_PREFIX}")}
    return from keyword if   "${start_with_prefix}"=="${True}"      ${ctr_abbr}

    ${cu_full_ctr_name}   set variable  ${G_CU_CONTAINER_PREFIX}${ctr_abbr}
    [Return]  ${cu_full_ctr_name}

Get CU Full Pod Name By Pod Abbreviation
    [Arguments]  ${pod_abbr}  ${alias}=default  ${gnb_index}=0
    [Documentation]  get the full pod name by pod abbreviation using kubectl get pods command
    ...  author:            calla.wang@nokia-sbell.com
    ...  modified by:       <06-23-2021>, <calwang>, <initial created>
    ...    2021.7.26,chris.l.cao@nokia-sbell.com, add sudo for cbis-admin user
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
    ${sudo_outer}  Get Sudo For VCU K8s Admin Command  gnb_index=${gnb_index}
    ${ns}   Get CU Namespace From Testline  ${gnb_index}
    ${cmd}   set variable   ${sudo_outer} kubectl get pods -n ${ns}|egrep -w "(${pod_abbr})" |awk '{print $1}'

    ${out}   issh.Execute  command=${cmd}   alias=${alias}
    ${out}   strip prompt  ${out}
    ${full_pod_name}   Set Variable  ${out.strip()}
    [Return]  ${full_pod_name}


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
   ${out}  issh.Execute  command=${cmd}  alias=${alias}
   ${out}   strip prompt  ${out}
   ${out}   Set Variable  ${out.strip()}
   ${pods_info}  parse_output_with_ps_format_to_dict  ${out}
   [Return]  ${pods_info}

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
    ...    {'ctr-cran5-cpcl': ['running', '2021-05-26T07:14:06Z'],
    ...     'ctr-cran5-givaxi': ['running', '2021-05-26T07:14:07Z'],
    ...     'ctr-cran5-nwinit': ['terminated', '2021-05-26T07:13:59Z'],
    ...     'ctr-cran5-nwmgmt': ['running', '2021-05-26T07:14:06Z']}

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

Get CU Pods Name List
    [Arguments]  ${alias}=default  ${gnb_index}=0
    [Documentation]  get the CU pods name list
    ...  author:            calla.wang@nokia-sbell.com
    ...  modified by:       <06-23-2021>, <calwang>, <initial created>
    ...    | Input Parameters | Man. | Description |

    ...    *RETURN VALUE*
    ...    pod name list
    ...    ['po-cran5-cpcl-0',
    ...    'po-cran5-cpif-0',
    ...    'po-cran5-cpnb-0',
    ...    'po-cran5-cpnrt-0',
    ...    .......
    ...     ]

    ...  *EXAMPLE(
    ...    | ${alias}= | Connect To CU K8S Master With Admin  |  |
    ...    | ${pod_name_list} | Get CU Pods Name List | cpif | ${alias} |
    ...    | Disconnect Interactive Connection | ${alias} |

    ${pods_name_list}   create list
    ${ns}   Get CU Namespace From Testline  ${gnb_index}
    ${out}   issh.Execute  command=kubectl get pods -n ${ns}  alias=${alias}
    ${out}   strip prompt  ${out}
    ${out}   Set Variable  ${out.strip()}
    ${lines}   Split To Lines  ${out}
    Remove From List  ${lines}  0
    FOR  ${line}  IN  @{lines}
      Append To List    ${pods_name_list}  ${line.split()[0].strip()}
    END
    [Return]  ${pods_name_list}

One Pod Containers Status Should Be Normal
    [Arguments]  ${pod_name}  ${alias}=default  ${gnb_index}=0
    [Documentation]  CU containers status in one pod should be normal, running or terminated
    ...  author:            calla.wang@nokia-sbell.com
    ...  modified by:       <06-23-2021>, <calwang>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    | pod_name | Yes. | the pod name abbreviation, or the full pod name. |

    ...    *RETURN VALUE*
    ...    None

    ...  *EXAMPLE*
    ...    | ${alias}= | Connect To CU K8S Master With Admin  |  |
    ...    | ${pod_name_list} | One Pod Containers Status Should Be Normal | cpif | ${alias} |
    ...    | Disconnect Interactive Connection | ${alias} |
    ${ctns_status}=  Get CU One Pod Containers Status  ${pod_name}  ${alias}  ${gnb_index}
    FOR  ${ctn}  IN  @{ctns_status.keys()}
      Run Keyword If  'init' in '${ctn}' or 'chown' in '${ctn}'
    ...  Should Be Equal As Strings  ${ctns_status['${ctn}'][0]}  terminated
    ...   ELSE  Should Be Equal As Strings  ${ctns_status['${ctn}'][0]}  running
    END

All CU Containers Should Be Normal
    [Arguments]  ${alias}=default  ${gnb_index}=0
    [Documentation]  CU containers status in all pods should be normal, running or terminated
    ...  author:            calla.wang@nokia-sbell.com
    ...  modified by:       <06-23-2021>, <calwang>, <initial created>
    ...    | Input Parameters | Man. | Description |

    ...    *RETURN VALUE*
    ...    None

    ...  *EXAMPLE*
    ...    | ${alias}= | Connect To CU K8S Master With Admin  |  |
    ...    | ${pod_name_list} | All CU Containers Should Be Normal | ${alias} |
    ...    | Disconnect Interactive Connection | ${alias} |
    ${pods_name_list}   Get CU Pods Name List  ${alias}  ${gnb_index}
    FOR  ${pod}   IN   @{pods_name_list}
      Run Keyword And Continue On Failure  One Pod Containers Status Should Be Normal   ${pod}  ${alias}  ${gnb_index}
    END

Verify all CU containers are running
    ${alias_cu}=    Connect To CU K8S Master With Admin
    wait until keyword succeeds    10min    10s            All CU Containers Should Be Normal   alias=${alias_cu}
    Disconnect Interactive Connection    ${alias_cu}

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

vCU Pods Status Should Be Terminating
    [Arguments]   ${gnb_index}=0
    ${namespace}  Get vCU Namespace From TestLine  ${gnb_index}
    ${result}=    tafssh.Execute  command=kubectl get pods -n ${namespace} |grep -i "Terminating"
    should contain   ${result}    Terminating
    Log to console   ${result}

Verify if pods are Terminating
    vCU Cluster Login With Admin
    wait until keyword succeeds    10min    10s            vCU Pods Status Should Be Terminating
    [Teardown]    helm.helm_master_close

Docker Restart CU Container
    [Arguments]  ${pod_abbr}   ${container}    ${gnb_index}=0
    [Documentation]    Restart CU Container using docker restart
    ...    *AUTHOR* calla.wang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | pod_abbr     | yes | pod abbreviation, e.g, oamcp, up |
    ...    | container    | yes | container, e.g, oamfh, l2hi |
    ...    | vdu_index    | no | vdu_index, default value is 0 |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...   | Docker Restart CU Container| pod_abbr=oamcm | container=oamcm |
    ...
    ${alias}=  Connect To CU Node   ${pod_abbr}  ${gnb_index}

    ${ns}   Get CU Namespace From TestLine    gnb_index=${gnb_index}
    ${cu_ctn_id}  Get CU Container ID  ${pod_abbr}  ${container}  ${alias}  ${gnb_index}
    ${cmd}   Set Variable  docker restart ${container_id}
    issh.Execute    ${cmd}   alias=${alias}
    Sleep   10
    [Teardown]  Run Keyword And Ignore Error  Disconnect Interactive Connection   alias=${alias}

Get CU Namespace From Testline
    [Arguments]  ${gnb_index}=0
    [Documentation]    get cu namespace from testline
    ...    *AUTHOR* calla.wang@nokia-sbell.com
    ...  history change:
    ...  modified by:       <06-23-2021>, <calwang>, <initial created>
    ...  27.11.2021,chris.l.cao@nokia-sbell.com, add support to VCU NCIR
    ...
    ...   *RETURN VALUE*
    ...   namespace for CNF, tenant name for VNF
    ...
    ${r}  ${cu_namespace}   Run Keyword And Ignore Error
        ...   set variable  ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.namespace}
    ${cu_namespace}   Run Keyword If  "${r}"=="FAIL"  Set Variable
              ...  ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.control_nodes[0].default_ssh_connection_details.username}
       ...   ELSE  Set Variable   ${cu_namespace}
    [Return]   ${cu_namespace}


Get CU Pod Located Node List
    [Arguments]  ${pod_abbr}   ${alias}=default   ${gnb_index}=0
    [Documentation]    get the node list which the pod located.
    ...  author:            lingting.sun@nokia-sbell.com
    ...  modified by:       <09-07-2021>, <lingtsun>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    | pod_abbr | Yes. | the pod name abbreviation, do not give the full pod name. |
    ...    | alias | Yes. | the alias that connected to the CU cluster. |
    ...    | gnb_index | No. | the gnb index, default value is 0. |

    ...    *RETURN VALUE*
    ...    the node name list
    ...    Example
    ...    | ${alisa}= | Connect To CU K8S Master With Admin  |  |
    ...    | ${node}= | Get CU Pod Located Node List | upue | ${alisa} |
    ...    | Disconnect Interactive Connection | ${alias} |
    ${pod_located_node}=    Get CU Pod Located Node    ${pod_abbr}    ${alias}    ${gnb_index}
    @{pod_located_node_list}    split string    ${pod_located_node}    \r\n
    [Return]     ${pod_located_node_list}

Download File From VCU Container
    [Arguments]  ${pod_abbr}   ${container}   ${file_source_path}  ${log_local_stored_path}  ${alias}=default
    ...          ${check_result}=${True}  ${gnb_index}=0
    [Documentation]  Download file from vcu container
    ...  author:            lingting.usn@nokia-sbell.com
    ...  modified by:       <08-16-2021>, <lingtsun>, <initial created>
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | pod_abbr | Yes. | the pod name abbreviation, do not give the full pod name. such as oamcm |
    ...    | container | Yes. | the container name abbreviation. such as oamcm |
    ...    | file_source_path | Yes. | file_path in container. |
    ...    | log_local_stored_path | Yes. | target stored path in local env. |
    ...    | alias | Yes. | the alias that connected to the CU cluster. |
    ...    | gnb_index | No. | the gnb index, default value is 0. |

    ...    *RETURN VALUE*
    ...  *Example*
    ...    | ${alisa}= | Connect To CU K8S Master With Admin  |  |
    ...    | ${output}= | Download File From VCU Container | oamcm | oamcm | tmp/test.txt | /tmp/test.txt | ${alias} |
    ...    | Disconnect Interactive Connection | ${alias} |
    ${platform}=   Get vCU Platform Name
    run keyword if  "${platform}"=="NCS" or "${platform}"=="OCP"  _Download File From VCU Container NCS And OCP
    ...    pod_abbr=${pod_abbr}   container=${container}   file_source_path=${file_source_path}
    ...    log_local_stored_path=${log_local_stored_path}    alias=${alias}  check_result=${check_result}
    ...    gnb_index=${gnb_index}


_Download File From VCU Container NCS And OCP
    [Arguments]  ${pod_abbr}   ${container}   ${file_source_path}  ${log_local_stored_path}  ${alias}=default
    ...          ${check_result}=${True}  ${gnb_index}=0
    [Documentation]  Internal KW for Download file from vcu container (NCS and OCP supported)
    ...  author:            lingting.usn@nokia-sbell.com
    ...  modified by:       <08-16-2021>, <lingtsun>, <initial created>
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | pod_abbr | Yes. | the pod name abbreviation, do not give the full pod name. such as oamcm |
    ...    | container | Yes. | the container name abbreviation. such as oamcm |
    ...    | file_source_path | Yes. | file_path in container. |
    ...    | log_local_stored_path | Yes. | target stored path in local env. |
    ...    | alias | Yes. | the alias that connected to the CU cluster. |
    ...    | gnb_index | No. | the gnb index, default value is 0. |

    ...    *RETURN VALUE*
    ${ns}   Get CU Namespace From Testline  ${gnb_index}
    ${container_name}  Get CU Full Container Name By Container Abbreviation  ${container}
    ${pod_name}=  Get CU Full Pod Name By Pod Abbreviation  ${pod_abbr}  ${alias}  ${gnb_index}

    ${sudo_outer}  Get VCU Sudo For Current User   alias=${alias}
    ${temp_path}  set variable   ${file_source_path}
    ${kubectl_cmd}   Set Variable   ${sudo_outer} kubectl cp ${pod_name}:${file_source_path} -c ${container_name} tmp/${file_source_path} -n ${ns}
    ${out}   issh.Execute    command=${kubectl_cmd}   check_result=${check_result}   alias=${alias}
    ${out}    issh.Execute     command=ls   alias=${alias}
    issh.Download File   remote_path=${file_source_path}   local_path=${log_local_stored_path}   alias=${alias}
    ${out}  issh.Execute  command=rm -f ${file_source_path}     alias=${alias}
