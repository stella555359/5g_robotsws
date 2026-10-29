*** Settings ***
Documentation
...  author: Chen Yin 4
...  contact: yin.4.chen@nokia-sbell.com

Resource   common.robot


*** Keywords ***
Kill CU Pod
    [Arguments]   ${pod_name}=cpue   ${pod_index}=${0}   ${container}=${pod_name}   ${gnb_index}=${0}   ${connection}=COAM_CU

    ${cu_ssh_addr}   Get Variable Value   ${all_gnbs_detail[${gnb_index}]['cu_ssh_addr']}
    ${cu_ssh_username}   Get Variable Value   ${all_gnbs_detail[${gnb_index}]['cu_ssh_username']}
    ${cu_ssh_password}   Get Variable Value   ${all_gnbs_detail[${gnb_index}]['cu_ssh_password']}
    ${cu_k8s_namespace}   Get Variable Value   ${all_gnbs_detail[${gnb_index}]['cu_k8s_namespace']}

    ${full_pod}   Set Variable   po-${cu_k8s_namespace}-${pod_name}-${pod_index}
    ${full_container}   Set Variable   ctr-${cu_k8s_namespace}-${container}

    csn.Connect To   hostname=${cu_ssh_addr}   username=${cu_ssh_username}   password=${cu_ssh_password}   alias=${connection}

    csn.Execute
    ...   command=kubectl exec -it ${full_pod} -c ${full_container} -n ${cu_k8s_namespace} -- bash -c "kill 1"
    ...   timeout=${60}   connection=${connection}

    [Teardown]   Run Keyword And Ignore Error   csn.Disconnect   connection=${connection}


Kill CU TCC
    [Arguments]   ${gnb_index}=${0}   ${connection}=COAM_CU

    ${cu_ssh_addr}   Get Variable Value   ${all_gnbs_detail[${gnb_index}]['cu_ssh_addr']}
    ${cu_ssh_username}   Get Variable Value   ${all_gnbs_detail[${gnb_index}]['cu_ssh_username']}
    ${cu_ssh_password}   Get Variable Value   ${all_gnbs_detail[${gnb_index}]['cu_ssh_password']}
    ${cu_k8s_namespace}   Get Variable Value   ${all_gnbs_detail[${gnb_index}]['cu_k8s_namespace']}

    csn.Connect To   hostname=${cu_ssh_addr}   username=${cu_ssh_username}   password=${cu_ssh_password}   alias=${connection}

    ${pod_name_0}   Set Variable   po-${cu_k8s_namespace}-oamext-0
    ${pod_name_1}   Set Variable   po-${cu_k8s_namespace}-oamext-1
    ${container_name}   Set Variable   ctr-${cu_k8s_namespace}-tracecontroller
    ${pod_command}   Set Variable   ps -ef | grep -i /usr/bin/TC-Configurator | grep -v pipefail | grep -v grep

    ${output1}   csn.Execute
    ...   command=kubectl exec -it ${pod_name_0} -c ${container_name} -n ${cu_k8s_namespace} -- bash -c "ps -ef | grep TC"
    ...   timeout=${60}   connection=${connection}
    ${output2}   csn.Execute
    ...   command=kubectl exec -it ${pod_name_1} -c ${container_name} -n ${cu_k8s_namespace} -- bash -c "ps -ef | grep TC"
    ...   timeout=${60}   connection=${connection}
    ${status1}   Run Keyword And Return Status   Should Contain   ${output1}   /usr/bin/TC-Master-NR
    ${status2}   Run Keyword And Return Status   Should Contain   ${output2}   /usr/bin/TC-Master-NR

    ${pod_name}   Set Variable If
    ...   ${status1}   ${pod_name_0}
    ...   ${status2}   ${pod_name_1}
    ...   ERR
    Run Keyword If   "${pod_name}"=="ERR"   FAIL   msg=No TCC Process. Please Check Manually.


    ${tcc_pid}   csn.Execute
    ...   command=kubectl exec -it ${pod_name} -c ${container_name} -n ${cu_k8s_namespace} -- bash -c "${pod_command}" | awk '{print $2}'
    ...   timeout=${60}   connection=${connection}
    ${tcc_pid}   Strip String   ${tcc_pid}


    ${kill_command}   Set Variable   kill -9 ${tcc_pid}
    csn.Execute
    ...   command=kubectl exec -it ${pod_name} -c ${container_name} -n ${cu_k8s_namespace} -- bash -c "${kill_command}"
    ...   timeout=${60}   connection=${connection}

    csn.Execute
    ...   command=kubectl exec -it ${pod_name} -c ${container_name} -n ${cu_k8s_namespace} -- bash -c "ps -ef | grep TC"
    ...   timeout=${60}   connection=${connection}

    [Teardown]   Run Keyword And Ignore Error   csn.Disconnect   connection=${connection}


Check CU Pod Status
    [Arguments]   ${pod_name}=all   ${pod_index}=${0}   ${check_restarts}=${0}   ${gnb_index}=${0}   ${connection}=COAM_CU

    ${cu_ssh_addr}   Get Variable Value   ${all_gnbs_detail[${gnb_index}]['cu_ssh_addr']}
    ${cu_ssh_username}   Get Variable Value   ${all_gnbs_detail[${gnb_index}]['cu_ssh_username']}
    ${cu_ssh_password}   Get Variable Value   ${all_gnbs_detail[${gnb_index}]['cu_ssh_password']}
    ${cu_k8s_namespace}   Get Variable Value   ${all_gnbs_detail[${gnb_index}]['cu_k8s_namespace']}

    csn.Connect To   hostname=${cu_ssh_addr}   username=${cu_ssh_username}   password=${cu_ssh_password}   alias=${connection}

    # ${pods_status}   csn.Execute   command=kubectl get pods -n ${cu_k8s_namespace}   timeout=${60}   connection=${connection}
    # Log To Console   ${pods_status}

    ${pods_info}   Get CU Pods Info   gnb_index=${gnb_index}   connection=${connection}
    ${full_pod_name}   Set Variable   po-${cu_k8s_namespace}-${pod_name}-${pod_index}

    FOR   ${pod_detail}   IN   @{pods_info.values()}
       #  {'age': '3d',
       # 'ip': '172.21.48.58',
       # 'name': 'po-cran877-cpcl-0',
       # 'node': 'master2.hzdx-vrf3-10-57-187-2.ocp.hz.nsn-rdnet.net',
       # 'nominated_node': '<none>',
       # 'readiness_gates': '<none>',
       # 'ready': '3/3',
       # 'restarts': '0',
       # 'status': 'Running'}

        ${name}   Get Variable Value   ${pod_detail["name"]}
        Continue For Loop If   "${pod_name}"!="all" and "${name}"!="${full_pod_name}"

        ${restarts}   Get Variable Value   ${pod_detail["restarts"]}
        Run Keyword If   "${check_restarts}"!="-1"   Should Be Equal As Numbers   ${restarts}   ${check_restarts}

        ${ready}   Get Variable Value   ${pod_detail["ready"]}
        ${ready_container}   ${all_container}   Split String   ${ready}   /
        Should Be Equal As Numbers    ${ready_container}   ${all_container}

        ${status}   Get Variable Value   ${pod_detail["status"]}
        Should Be Equal   ${status}   Running
    END


    [Teardown]   Run Keyword And Ignore Error   csn.Disconnect   connection=${connection}



Get CU Pods Info
    [Arguments]   ${gnb_index}=${0}   ${connection}=COAM_CU   ${pod_name}=all

    ${cu_k8s_namespace}   Get Variable Value   ${all_gnbs_detail[${gnb_index}]['cu_k8s_namespace']}

    # ${pod_name}=  Run Keyword If  '${pod_name}'!='all' and '${ns}' not in '${pod_name}'
    # ...  Get CU Full Pod Name By Pod Abbreviation  ${pod_name}  ${alias}  ${gnb_index}
    # ...  ELSE  set variable  ${pod_name}

    ${cmd}   Set Variable If  '${pod_name}'=='all'   kubectl get pods -n ${cu_k8s_namespace} -o wide
    ...   kubectl get pods ${pod_name} -n ${cu_k8s_namespace} -o wide
    ${output}   csn.Execute   command=${cmd}   connection=${connection}
    ${output}   Strip String   ${output}
    ${pods_info}  parse_output_with_ps_format_to_dict  ${output}
    [Return]  ${pods_info}
