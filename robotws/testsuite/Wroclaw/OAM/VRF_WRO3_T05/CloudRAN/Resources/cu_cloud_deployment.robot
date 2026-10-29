*** Settings ***
Documentation
...   author: xianbiao.cheng@nokia-sbell.com
...   contact: xianbiao.cheng@nokia-sbell.com
...   cu_cloud_deployment.robot

Resource    aic_common_resources_new.robot
Library     ../Tests/HA/utils.py

*** Keywords ***
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
    [Return]  ${pods_Info}
    [Teardown]    helm.helm_master_close

_Get vCU CNF Release Values With Json Format
    [Arguments]   ${gnb_index}=0
    [Teardown]  Run Keyword And Ignore Error   aic_common_resources_new.Close Interactive Connection   ${alias}
    ${alias}=     Connect To CU K8S Master With Tenant   gnb_index=${gnb_index}
    ${out}  issh.Execute   command=helm list -A | grep -v cluster | grep -v prerequisite | grep -v NAME | awk '{print $1}'  alias=${alias}
    ...  check_result=${False}
    ${cnf_release_name}   strip prompt   ${out}
    ${cnf_release_name}   Process Variable    ${cnf_release_name}
    Log To Console     *** Stripped cnf release name ${cnf_release_name} ***
    ${out}  issh.Execute   command=helm get values ${cnf_release_name} -o json  alias=${alias}   check_result=${False}
    ${response}   strip prompt   ${out}
    ${response}   Process Variable    ${response}
    Log To Console     *** Response ${response} ***
    [Return]    ${response}


Get CU Container Name Prefix
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
    _Set CU Pod And Container Name Prefix
    [Return]  ${G_CU_CONTAINER_PREFIX}
    #[Teardown]  run keyword and ignore error   aic_common_resources_new.Close Interactive Connection   ${alias}


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
    ${out}  issh.Execute   command=${sudo} kubectl get pods -n ${ns}|grep -E "\\pm\\-"|awk -F "pm" '{print $1}'  alias=${alias}
    ${pod_prefix}  strip prompt  ${out}
    ${pod_prefix}    Process Variable    ${pod_prefix}
    ${pod_prefix}   set variable if   ${pod_prefix.__len__()>0}   ${pod_prefix}   ${EMPTY}
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
    [Teardown]  aic_common_resources_new.Close Interactive Connection   ${alias}

Get Sudo For VCU K8s Admin Command
    [Arguments]  ${gnb_index}=0
    [Documentation]   Get Sudo For VCU K8s Admin Command
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | gnb_index | no | gnb index to indicate which gnb will be used, default is 0  |
    ...
    ...    *RETURN VALUE*
    ...   if admin account is cbis-admin, return sudo, otherwise return ${EMPTY}
    ...
    ...    Example
    ...    | ${sudo} | Get Sudo For VCU K8s Admin Command |
    ...
    ${vcu_k8s_master_ssh_connection_info}   Get VCU K8s Admin SSH Connection Info   gnb_index=${gnb_index}
    ${sudo}   set variable if   "${vcu_k8s_master_ssh_connection_info["username"]}"=="cbis-admin"   sudo   ${EMPTY}

    [Return]   ${sudo}

Get CU Full Container Name By Container Abbreviation
    [Arguments]  ${ctr_abbr}
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
    ${G_CU_CONTAINER_PREFIX}=    Get CU Container Name Prefix
    ${start_with_prefix}   set variable  ${ctr_abbr.startswith("${G_CU_CONTAINER_PREFIX}")}
    return from keyword if   "${start_with_prefix}"=="${True}"      ${ctr_abbr}

    ${cu_full_ctr_name}   set variable  ${G_CU_CONTAINER_PREFIX}${ctr_abbr}
    [Return]  ${cu_full_ctr_name}

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
        @{split_ready}=    Split String    ${pods_values}[ready]    /
        Should Be Equal    ${split_ready[0]}     ${split_ready[1]}
    END

Get CU Full Pod Name By Pod Abbreviation
    [Arguments]  ${pod_abbr}  ${alias}=default  ${gnb_index}=0   ${use_m2m}=${True}
    [Documentation]  get the full pod name by pod abbreviation using kubectl get pods command?
    ...   For 2N deployment, it will return active POD name.
    ...  author:            calla.wang@nokia-sbell.com
    ...  modified by:       <06-23-2021>, <calwang>, <initial created>
    ...    2021.7.26,chris.l.cao@nokia-sbell.com, add sudo for cbis-admin user
    ...    2022.4.21,chris.l.cao@nokia-sbell.com, add to support 2N
    ...    2023.4.16,chris.l.cao@nokia-sbell.com, add '--color=never'
    ...    2023.07.18,hefeng-cookie.qu@nokia-sbell.com add "-pod_abbr"
    ...    | Input Parameters | Man. | Description |
    ...    | pod_abbr | Yes. | the pod name abbreviation. |

    ...    *RETURN VALUE*
    ...    the pod full name
    ...  *Example*
    ...    | ${alias}= | Connect To CU K8S Master With Admin  |  |
    ...    | ${pod_name} | Get CU Full Pod Name By Pod Abbreviation | oamcm | ${alias} |
    ...    | Close Interactive Connection | ${alias} |
    ...
    ${ns}   Get CU Namespace From Testline  ${gnb_index}
    ${cmd}   Set Variable   oc get pods -n ${ns}|egrep "(${pod_abbr})" --color=never|awk '{print $1}'
#   ${cmd}   Set Variable   oc get pods -n ${ns}|egrep "(-${pod_abbr})" --color=never|awk '{print $1}'
    ${out}   issh.Execute  command=${cmd}   check_result=${False}  alias=${alias}

    ${out}   strip prompt  ${out}
    ${contains_r}    Run Keyword and Return Status  Should Contain  ${out}    \r
    IF    ${contains_r}
        ${out}=    Split To Lines    ${out}
        Remove From List    ${out}    0
    END
    ${full_pod_name_list}   Set Variable    ${out}
    Run Keyword If   ${full_pod_name_list.__len__()}==0  Fail   Can not get pod by pod_abbr:${pod_abbr}!
    ...  ELSE IF   ${full_pod_name_list.__len__()}==1    Return From Keyword   ${full_pod_name_list[0]}

    ${active_pod_name}   CU Get Active Pod Name  pod_name=${pod_abbr}    use_m2m=${use_m2m}
    ${cmd}   set variable   kubectl get pods -n ${ns}|egrep "(-${active_pod_name})" --color=never|awk '{print $1}'
    ${out}   issh.Execute  command=${cmd}   check_result=${False}  alias=${alias}
    ${out}   strip prompt  ${out}
    ${out}   Process Variable  ${out}
    ${active_pod_full_name}   Set Variable  ${out.strip()}

    [Return]  ${active_pod_full_name}


CU Get Active Pod Name
    [Arguments]  ${pod_name}    ${use_m2m}=${True}
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
