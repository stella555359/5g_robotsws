*** Settings ***
Documentation
...   author: xianbiao.cheng@nokia-sbell.com
...   contact: xianbiao.cheng@nokia-sbell.com
...   vdu_cloud_deployment.robot



*** Variables ***


*** Keywords ***
Get Current vDU Version
    [Arguments]    ${vdu_index}=0   ${login_account}=core
    [Documentation]  get current vDU version
    run keyword if     "${login_account}"=="core"   vDU Cluster Login With Admin    ${vdu_index}
    ...   ELSE   vDU Cluster Login With Tenant    ${vdu_index}  ${gnb_index}
    ${ns}   Get vDU Namespace From TestLine   vdu_index=${vdu_index}
    #${result}=    helm.Execute Command On Master Cluster    helm list -n ${ns} |grep vdu |awk '{print $9}'
    ${result}=    helm.Execute Command On Master Cluster
    ...   helm list -n ${ns} |egrep "aic-vdu-[0-9]+\.[0-9]+\.[0-9]+"|awk '{print $9}'
    log    ${result.stdout}
    ${vdu_current_version}=    Convert To String    ${result.stdout}
    ${vdu_current_version}=    Strip String    ${vdu_current_version}
    @{vdu_current_version}=    Split String    ${vdu_current_version}    -
    ${vdu_current_version}=    Set Variable    ${vdu_current_version[-1]}
    [Return]    ${vdu_current_version}


Reboot Radio Unit
    [Arguments]  ${vdu_index}=0   ${fhgw_index}=0  ${ru_index}=1
    [Teardown]  Run Keyword And Ignore Error  Disconnect Interactive Connection  alias=${alias}
    [Documentation]   Reboot Radio Unit/Reboot RU/Restart RU/Restart Radio Unit
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | vdu_index  | No | vdu_index, default value is 0  |
    ...    | fhgw_index | No | fhgw_index, default value is 0  |
    ...    | ru_index   | No | ru_index, default value is 1  |
    ...
    ...    *RETURN VALUE*
    ...   None
    ...
    ...    Example
    ...   | Reboot Radio Unit |
    ...
    ${alias}   Get Unique Id
    Connect To Radio Unit    vdu_index=${vdu_index}   fhgw_index=${fhgw_index}     alias=${alias}   ru_index=${ru_index}
    ${cmd}  Set Variable    reboot
    ${out}   issh.Execute   command=${cmd}    check_result=${False}  alias=${alias}
    #sleep   240
    sleep   120

Get RU Image File Name
    [Arguments]     ${gnb_index}=0   ${vdu_index}=0   ${fhgw_index}=0
    [Teardown]   run keyword and ignore error  disconnect interactive connection   alias=${alias}
    [Documentation]  Get RU Image File Name
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | gnb_index        |  no | gnb_index, default value is 0 |
    ...    | vdu_index        |  no | vdu_index, default value is 0 |
    ...    | fhgw_index       |  no | fhgw_index, default value is 0 |
    ...
    ...    *RETURN VALUE*
    ...     RU Image File Name
    ...
    ...    Example
    ...    | ${rf_image_file} | Get RU Image File Name |
    ...

    run Keyword If  """${TRANS_PARA}"""=="""${NONE}"""   FAIL   there is no ${TRANS_PARA} defined!
    ${result}  ${tools_repository}    Run Keyword And Ignore Error   Set Variable  ${TRANS_PARA["tools_repository"]}
    run Keyword If  """${result}"""=="""FAIL"""   Fail   there is no tools_repository defined in __init__.py!

    ${alias}  get unique id
    Connect to FHGW  alias=${alias}   gnb_index=${gnb_index}   vdu_index=${vdu_index}  fhgw_index=${fhgw_index}
    ${out}   issh.Execute   command=ls -l ${TOOLS_INFO["work_folder_data"]}|grep rfsw|wc -l   check_result=${False}   alias=${alias}
    ${out}  strip prompt  ${out}
    ${count}  strip prompt  ${out}    remove_first_line=${False}

    should be true  ${count}>=1   Only one rf image file is allowed!

    #${out}   issh.Execute   command=ls -l ${TOOLS_INFO["work_folder_data"]}|grep rfsw|awk '{print $9}'    alias=${alias}
    ${out}   issh.Execute   command=ls -lt ${TOOLS_INFO["work_folder_data"]}|grep rfsw|tail -n 1 |awk '{print $9}'    alias=${alias}

    ${out}  strip prompt  ${out}
    ${rf_image_file}  strip prompt  ${out}    remove_first_line=${False}
    [Return]  ${rf_image_file}


Get VDU Release Name
    [Arguments]     ${vdu_index}=0  ${gnb_index}=0
    [Documentation]   Get VDU release name
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   10.3.2023,chris.l.cao@nokia-sbell.com, remove NCIR code branch
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | vdu_index      | No | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    vdu release name, e.g, 'vdu' for environment deployed by jenkins agent.
    ...       or 'vdutest' for deployment by kuafu.
    ...
    ...    Example
    ...    | ${vdu_release_name} | Get VDU release name |
    ...
    ${release_name}     _Get VDU Release Name NCS   vdu_index=${vdu_index}  gnb_index=${gnb_index}

    [Return]  ${release_name}


_Get VDU Release Name NCS
    [Arguments]     ${vdu_index}=0   ${gnb_index}=0
    [Teardown]  Run Keyword And Ignore Error  Disconnect Interactive Connection  alias=${alias}
    [Documentation]   _Get VDU release name NCS
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   18.8.2021,chris.l.cao@nokia-sbell.com, exclude prerequisite for latest vdu software
    ...   10.3.2023,chris.l.cao@nokia-sbell.com, change from admin to tenant
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | vdu_index      | No | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    vdu release name, eg, aic-vdu
    ...
    ...    Example
    ...    | ${vdu_release_name} | Get VDU release name NCS |
    ...
    ${alias}  Get Unique Id
    Connect To K8s Master With Tenant Interactively   gnb_index=${gnb_index}  vdu_index=${vdu_index}  alias=${alias}
    ${out}  issh.Execute
     ...  command=helm list|grep aic-vdu-|grep -v prerequisite|grep -v rbac|grep -v preparation|awk '{print $1}'
     ...  alias=${alias}
    ${release_name}  Strip Prompt  ${out}

    ${tmp_list}  Split To Lines   ${release_name}
    ${tmp_list_length}   get length    ${tmp_list}
    should be true    ${tmp_list_length}==1

    [Return]  ${release_name}


Get VDU Build Prefix
    [Arguments]    ${gnb_index}=0  ${vdu_index}=0
    [Documentation]   Get VDU Build Prefix
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | gnb_index | no | gnb_index, default value is 0  |
    ...    | vdu_index | no | vdu_index, default value is 0  |
    ...
    ...    *RETURN VALUE*
    ...    return vDUCNF, vDUCNF22R4, etc.
    ...
    ...    Example
    ...
    ...    | ${build_prefix} | Get VDU Build Prefix |
    ...    | ${build_prefix} | Get VDU Build Prefix | vdu_index=0 |
    ...
    ${build_number}   Get Running Build Number   gnb_index=${gnb_index}   vdu_index=${vdu_index}
    ${build_prefix}   Get Package Prefix From Global Variables File   build_number=${build_number}

    [Return]   ${build_prefix}


vDU Get Pods Full Info
    [Arguments]    ${pod_name}=all    ${namespace}=${EMPTY}  ${vdu_index}=0   ${gnb_index}=0
    [Documentation]  get pods full infomation
    ...  author: calla.wang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | pod_name | No. | the pods name that containers belong to, default value is all pods |
    ...    | namespace | No. | the namespace that the pod belongs to, if not given, using the tenant namespace |
    ...    *RETURN VALUE*
    ...    pods info dict
    Run Keyword If    '${namespace}' != '${EMPTY}'    vDU Cluster Login With Admin  ${vdu_index}  ${gnb_index}
    ...    ELSE    vDU Cluster Login With Tenant  ${vdu_index}  ${gnb_index}
    ${pods_info}=    get_vdu_pods_info    ${pod_name}    ${namespace}
    Set Test Variable    ${Pods_Info}    ${pods_info}
    [Return]  ${Pods_Info}
    [Teardown]    helm.helm_master_close


vDU Pod Status Should Be As Expected
    [Arguments]   ${expect_status}    ${pod_name}=all    ${namespace}=${EMPTY}   ${vdu_index}=0
    [Documentation]  judging pods status should be as expected
    ...  author: calla.wang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | expect_status | Yes. | the expected status of the pod |
    ...	   | pod_name | No. | the pods name that containers belong to, default value is all pods |
    ...    | namespace | No. | the namespace that the pod belongs to, if not given, using the tenant namespace |
    ${pods_info}=    vDU Get Pods Full Info    ${pod_name}    ${namespace}   ${vdu_index}
    ${pods_name_list}=    Get Dictionary Keys    ${pods_info}
    FOR  ${pod}  IN  @{pods_name_list}
        Should Be Equal As Strings    ${pods_info['${pod}']['status']}    ${expect_status}
    END


Get Full Pod Name By Pod Abbreviation
    [Arguments]    ${pod_abbr}    ${connection}=default   ${vdu_index}=0   ${gnb_index}=0
    [Documentation]   Get Full Pod Name By Pod Abbrevation
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | pod_abbr          |  Yes | pod name appreviation, eg, oamcp, uprt |
    ...    | connection        | No | connection. Default value is default |
    ...    | vdu_index         | No | vdu_index. Default value is 0 |
    ...
    ...    *RETURN VALUE*
    ...    Full pod name.
    ...
    ...    Example
    ...    | Connect To K8s master |
    ...    | ${full_pod_name} | Get Full Pod Name By Pod Abbreviation | pod_abbr=oamcp |
    ...    | ${full_pod_name} | Get Full Pod Name By Pod Abbreviation | pod_abbr=up | vdu_index=0 |
    ...    | ${full_pod_name} | Get Full Pod Name By Pod Abbreviation | pod_abbr=up | vdu_index=0 | connection=myalias |
    ...    | Disconnect From K8s Master |
    ...
    ${ns}   Get vDU Namespace From TestLine   vdu_index=${vdu_index}  gnb_index=${gnb_index}
    ${cmd}   set variable  kubectl get pods -n ${ns}
    ${cmd}   set variable  ${cmd}|egrep "(-${pod_abbr}-)" |awk '{print $1}'

    #${cmd}   run keyword if   "${pod_abbr}"!="securestorage"    set variable  ${cmd}|egrep "(${pod_abbr})" |awk '{print $1}'
    #...   ELSE  set variable  ${cmd}|egrep "(${pod_abbr})" |awk '{print $1}'

    ${full_pod_name}   tafssh.Execute    command=${cmd}   connection=${connection}
    ${full_pod_name}   Set Variable  ${full_pod_name.strip()}
    [Return]  ${full_pod_name}


Get Pod Abbreviation By Container Abbreviation
    [Arguments]    ${container_abbr}=oamfh  ${vdu_index}=0   ${gnb_index}=0
    [Documentation]   Get Pod Abbreviation By Container Abbreviation
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   15.12.2021,chris.l.cao@nokia-sbell.com, Fix problem that some PODs have multiple containers whose name are simular,
    ...                                e.g, in oamconfig pod, there are two containers oamconfig and appsecretinitoamconfig.
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | container_abbr    |  No | container_abbr, eg, oamfh, l1hi |
    ...
    ...    *RETURN VALUE*
    ...    pod abbreviation, e.g, oam, cprt, up.
    ...
    ...    Example
    ...    | ${pod_abbr} | Get Pod Abbreviation By Container Abbreviation | container_abbr=oamfh |
    ...
    ${container_prefix}  Get Container Name Prefix  vdu_index=${vdu_index}   gnb_index=${gnb_index}
    ${start_with_prefix}   set variable  ${container_abbr.startswith("${container_prefix}")}
    ${container_abbr}  run keyword if   "${start_with_prefix}"=="${True}"   set variable  ${container_abbr.replace("${container_prefix}","")}
        ...   ELSE   set variable    ${container_abbr}

    ${pod_keys}   Evaluate    list(${AIC_VDU_PODS})

    ${pod_abbr}   set variable   ${EMPTY}
    FOR   ${pod}  IN   @{pod_keys}
        ${containers_list}    set variable    ${AIC_VDU_PODS_CONTAINER_ABBR["${pod}"]}
        ${number}   Collections.Count Values In List   ${containers_list}    ${container_abbr}
        run keyword if   ${number}>=2   Fail   There are two container whose names are same !
        Return From keyword if   ${number}==1   ${pod}
    END

    [Return]  ${pod_abbr}


Get Full Pod Name By Pod Abbreviation Interactively
    [Arguments]  ${pod_abbr}  ${alias}=default  ${vdu_index}=0  ${gnb_index}=0  ${pod_index}=0
    [Documentation]   Get Full Pod Name By Pod Abbreviation Interactively
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...  modified by:       <06-23-2021>, <calwang>, <initial created>
    ...    28.7.2021,chris.l.cao@nokia-sbell.com, add to check "No resources found" not in ${out}
    ...    24.4.2022,hongysun, add pod_index parameter
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | pod_abbr          |  Yes | pod name appreviation, eg, oamcp, uprt |
    ...    | alias             | No | alias. Default value is default |
    ...    | gnb_index         | No | gnb_index. Default value is 0 |
    ...    | vdu_index         | No | vdu_index. Default value is 0 |
    ...    | pod_index         | No | default is 0, e.g: if up-1, pod_index=1 |
    ...
    ...    *RETURN VALUE*
    ...    Full pod name.
    ...
    ...    Example
    ...    | Connect To K8s Master Interactively |
    ...    | ${full_pod_name} | Get Full Pod Name By Pod Abbreviation Interactively | pod_abbr=oamcp |
    ...    | ${full_pod_name} | Get Full Pod Name By Pod Abbreviation Interactively | pod_abbr=up | vdu_index=0 |
    ...    | ${full_pod_name} | Get Full Pod Name By Pod Abbreviation Interactively | pod_abbr=up | vdu_index=0 | alias=myalias |
    ...    | ${full_pod_name} | Get Full Pod Name By Pod Abbreviation Interactively | pod_abbr=up | vdu_index=0 | pod_index=1 | alias=myalias |
    ...    | disconnect interactive connection  |
    ...

    ${ns}   Get vDU Namespace From TestLine   vdu_index=${vdu_index}  gnb_index=${gnb_index}
    ${cmd}   set variable  kubectl get pods -n ${ns}

    ${out}   issh.Execute   command=${cmd}   alias=${alias}
    should be true   "No resources found" not in """${out}"""

    ${cmd}   set variable  ${cmd}|egrep "(-${pod_abbr}-)" |awk '{print $1}'

    ${out}   issh.Execute  command=${cmd}   alias=${alias}
    ${out}   strip prompt  ${out}
    ${full_pod_name}   Set Variable  ${out.strip()}
    ${full_pod_name_tmp}  Get Regexp Matches  ${full_pod_name}  po-${ns}-${pod_abbr}-${pod_index}
    ${full_pod_name}  set variable if  ${full_pod_name_tmp}!=[]  ${full_pod_name_tmp}[0]
    ...  ${full_pod_name}
    [Return]  ${full_pod_name}


Get Full Pod Name By Pod Abbreviation Interactively In Python
    [Arguments]    ${pod_abbr}    ${alias}=default   ${vdu_index}=0     ${gnb_index}=0   ${pod_index}=${EMPTY}
    [Documentation]   Get Full Pod Name By Pod Abbreviation Interactively In Python
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...  modified by:       <06-23-2021>, <calwang>, <initial created>
    ...  modified by:       <05-06-2022>, <lingtsun>, <add pod_index for cran multi-pod>
    ...    28.7.2021,chris.l.cao@nokia-sbell.com, add to check "No resources found" not in ${out}
    ...  modified by:       <24-04-2023>, <r3li>, <update for multi pods has same abbr>
    ...    |  Input Parameters | Man. | Description |
    ...    | pod_abbr          |  Yes | pod name appreviation, eg, oamcp, uprt |
    ...    | alias             | No | alias. Default value is default |
    ...    | gnb_index         | No | gnb_index. Default value is 0 |
    ...    | vdu_index         | No | vdu_index. Default value is 0 |
    ...
    ...    *RETURN VALUE*
    ...    Full pod name.
    ...
    ...    Example
    ...    |  ${alias} |  get unique id |
    ...    | fast_connect_to_k8s_master |   alias=${alias} |
    ...    | ${full_pod_name} | Get Full Pod Name By Pod Abbreviation Interactively In Python | pod_abbr=oamcp |
    ...    | ${full_pod_name} | Get Full Pod Name By Pod Abbreviation Interactively In Python | pod_abbr=up | vdu_index=0 |
    ...    | ${full_pod_name} | Get Full Pod Name By Pod Abbreviation Interactively In Python | pod_abbr=up | vdu_index=0 | alias=myalias |
    ...    | fast_disconnect  alias=${alias}
    ...

    ${command}  Set Variable  kubectl get pod

    ${out}  fast_execute   command=${command}
     ...   gnb_index=${gnb_index}  vdu_index=${vdu_index}  alias=${alias}
    should be true   "No resources found" not in """${out}"""

    ${with_pipeline_command}  Set Variable  |egrep "(-${pod_abbr}-${pod_index})" |awk '{print $1}'
    ${full_pod_name}  fast_execute   command=${command}  with_pipeline_command=${with_pipeline_command}
     ...   gnb_index=${gnb_index}  vdu_index=${vdu_index}  alias=${alias}
    ${full_pod_list}    Split String   ${full_pod_name}   \n
    [Return]  ${full_pod_list}


Get Full Pod Name By Container Abbreviation Interactively
    [Arguments]    ${container_abbr}     ${vdu_index}=0     ${gnb_index}=0
    [Teardown]  run keyword and ignore error   Disconnect Interactive Connection   alias=${alias_tmp}
    [Documentation]   Get Full Pod Name By Container Abbreviation Interactively
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | container_abbr    |  No | container name appreviation, eg, oamfh, l1hi |
    ...    | gnb_index         | No | gnb_index. Default value is 0 |
    ...    | vdu_index         | No | vdu_index. Default value is 0 |
    ...
    ...    *RETURN VALUE*
    ...    Full pod name.
    ...
    ...    Example
    ...    | ${full_pod_name} | Get Full Pod Name By Container Abbreviation Interactively | container_abbr=oamfh |
    ...
    Run Keyword If   "${container_abbr}"=="nwmgmt"   Fail  This KW can't be used for container nwmgmt !

    ${pod_abbr}   Get Pod Abbreviation By Container Abbreviation   container_abbr=${container_abbr}
    ${alias_tmp}   Get Unique Id
    Connect To K8s Master With Tenant Interactively  alias=${alias_tmp}
    ${full_pod_name}   Get Full Pod Name By Pod Abbreviation Interactively
    ...   pod_abbr=${pod_abbr}   alias=${alias_tmp}   vdu_index=${vdu_index}   gnb_index=${gnb_index}
    [Return]  ${full_pod_name}

Get Work Node Ip By Pod Abbreviation
    [Arguments]    ${pod_abbr}   ${connection}=default   ${vdu_index}=0
    [Documentation]   Get Work Node Ip By Pod Abbreviation
    ...    **AUTHOR**  chris.l.cao@nokia-sbell.com
    ...   **CHANGE HISTORY**
    ...   | Date | Who | What and how |
    ...   | 19-Jan-2022 | r3li | update get node name style more flexible |
    ...   **Arguments Description**
    ...   | Input Parameters | Man. | Description |
    ...   | pod_abbr |  Yes | pod name appreviation, eg, oamcp, uprt |
    ...   | connection | No | connection. Default value is default |
    ...   | vdu_index | No | vdu_index. Default value is 0 |
    ...   **ETURN VALUE**
    ...  - full pod name.
    ...   **Example**
    ...  | Connect To K8s master |
    ...  | ${work_node_ip} | Get Work Node Ip By Pod Abbreviation | pod_abbr=oamcp |
    ...  | ${work_node_ip} | Get Work Node Ip By Pod Abbreviation | pod_abbr=up | vdu_index=0 | connection=myalias |
    ...  | Disconnect From K8s Master |
    ${ns}    Get vDU Namespace From TestLine  vdu_index=${vdu_index}
    ${cmd}   set variable  kubectl get pods -n ${ns} -o wide | egrep "(-${pod_abbr}-)"
    ${out}   tafssh.Execute  command=${cmd}   connection=${connection}
    ${matches}  Get Regexp Matches  ${out}   .*?(\\d+\\.\\d+\\.\\d+\\.\\d+).*   1
    should not be empty  ${matches}
    ${work_node_ip}   set variable    ${matches}[0]
    ${node_name}   _Get Work Node Name   ${out}    ${work_node_ip}
    [Return]  ${node_name}


_Get Work Node Name
    [Arguments]   ${out}   ${work_node_ip}
    [Return]    ${node_name}
    ${out}    Replace string     ${out}     ${SPACE}    ${EMPTY}
    ${out}    Replace string     ${out}     <none>    ${EMPTY}
    ${matches}  Get Regexp Matches   ${out}    (?<=(${work_node_ip}))\\S+
    ${node_name}   set variable    ${matches}[0]


Get Full Container Name By Container Abbreviation
    [Arguments]    ${ctr_abbr}       ${vdu_index}=${0}    ${gnb_index}=${0}
    [Documentation]   Get Full Container Name By Container Abbreviation
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: 15.7.2022,lingting.sun@nokia-sbell.com, adaption for multi gnb
    ...    |  Input Parameters | Man. | Description |
    ...    | ctr_abbr          |  Yes | container name abbreviation, eg, oamfh, oam, cprt, nwmgmt,etc |
    ...    | vdu_index         | No | vdu_index. Default value is 0 |
    ...    | gnb_index         | No | gnb_index. Default value is 0 |
    ...
    ...    *RETURN VALUE*
    ...    Full Container name, e.g, ctr_cran1_oamfh
    ...
    ...    Example
    ...    | ${full_ctr_name} | Get Full Container Name By Container Abbreviation | ctr_abbr=oamfh |
    ...    | ${full_ctr_name} | Get Full Container Name By Container Abbreviation | ctr_abbr=nwmgmt | vdu_index=0 |
    ...    | ${full_ctr_name} | Get Full Container Name By Container Abbreviation | ctr_abbr=cprt | vdu_index=0 |
    ...

    #@{ctr_list}  create list   appsecretinithttpd  appsecretinitne3sagent  appsecretinitprovidercontroller  httpdstunnel
    #...  ne3sagentstunnel  providercontrollerstunnel  httpdcredmediator  ne3sagentcredmediator  providercontrollercredmediator
    #: FOR    ${ctr}    IN    @{ctr_list}
    #\   return from keyword if   "${ctr_abbr}"=="${ctr}"   ${ctr_abbr}

    ${container_prefix}  Get Container Name Prefix   gnb_index=${gnb_index}    vdu_index=${vdu_index}
    ${start_with_prefix}   set variable  ${ctr_abbr.startswith("${container_prefix}")}
    return from keyword if   "${start_with_prefix}"=="${True}"      ${ctr_abbr}

    ${full_ctr_name}   set variable  ${container_prefix}${ctr_abbr}
    [Return]  ${full_ctr_name}


Get Pod Name Prefix
    [Arguments]     ${vdu_index}=0
    [Documentation]   Get Pod Name Prefix
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | vdu_index         | No | vdu_index. Default value is 0 |
    ...
    ...    *RETURN VALUE*
    ...    Pod Name Prefix, e.g, po-cran1-
    ...
    ...    Example
    ...    | ${pod_prefix} | Get Pod Name Prefix |
    ...    | ${pod_prefix} | Get Pod Name Prefix | vdu_index=0 |
    ...
    ${r}  ${out}  run keyword and ignore error   set variable   ${_G_POD_PREFIX}
    return from keyword if  "${r}"=="PASS"   ${_G_POD_PREFIX}

    ${_G_POD_PREFIX}   _Get Pod Name Prefix Internal Use
    set suite variable   ${_G_POD_PREFIX}

    [Return]  ${_G_POD_PREFIX}


_Get Pod Name Prefix Internal Use
    [Arguments]   ${gnb_index}=0  ${vdu_index}=0
    [Teardown]  run keyword and ignore error  fast_disconnect  alias=${alias}
    [Documentation]   _Get Pod Name Prefix Internal Use
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    *History Change*:
    ...    | date | who |what and how |
    ...    | 14.8.2021 | chris.l.cao@nokia-sbell.com | change from tenant to admin account to adapt OCP |
    ...    | 15.7.2022 | lingting.sun@nokia-sbell.com| adaption for multi gnb |
    ...    | 23.12.2022 | rui.3.li@nokia-sbell.com | adaption for multi pod |
    ...    *Argument Description*
    ...    |  Input Parameters | Man. | Description |
    ...    | vdu_index         | No | vdu_index. Default value is 0 |
    ...
    ...    *RETURN VALUE*
    ...    Pod Name Prefix, e.g, po-cran1-
    ...
    ...    *Example*
    ...    | ${pod_prefix} | _Get Pod Name Prefix Internal Use |
    ...    | ${pod_prefix} | _Get Pod Name Prefix Internal Use | vdu_index=0 |
    ...
    ${alias}  get unique id
    fast_connect_to_k8s_master  gnb_index=${gnb_index}  vdu_index=${vdu_index}  alias=${alias}
    ${command}  Set Variable  kubectl get pod
    ${with_pipeline_command}  Set Variable  |grep -E \"\\-oamext\\-\"|awk -F \"-oamext-\" '{print $1 }'
    ${pod_prefix}  fast_execute   command=${command}  with_pipeline_command=${with_pipeline_command}
     ...   gnb_index=${gnb_index}  vdu_index=${vdu_index}  alias=${alias}
    ${pod_prefix_list}   Split String    ${pod_prefix}   \n
    ${pod_prefix}   Set Variable   ${pod_prefix_list}[0]
    ${pod_prefix}   set variable if   ${pod_prefix.__len__()>0}   ${pod_prefix}-   ${EMPTY}
    [Return]  ${pod_prefix}


Get Container Name Prefix
    [Arguments]     ${vdu_index}=0   ${gnb_index}=0
    [Documentation]   Get Container Name Prefix
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: 15.7.2022,lingting.sun@nokia-sbell.com, adaption for multi gnb
    ...    |  Input Parameters | Man. | Description |
    ...    | vdu_index         | No | vdu_index. Default value is 0 |
    ...
    ...    *RETURN VALUE*
    ...    Container Name Prefix, e.g, ctr-cran1-
    ...
    ...    *Example*
    ...    | ${container_prefix} | Get Container Name Prefix |
    ...    | ${container_prefix} | Get Container Name Prefix | vdu_index=0 |
    ...
#    ${r}  ${out}  run keyword and ignore error   set variable   ${_G_CONTAINER_PREFIX}
#    return from keyword if  "${r}"=="PASS"   ${_G_CONTAINER_PREFIX}

    ${_G_CONTAINER_PREFIX}   _Get Container Name Prefix Internal Use   gnb_index=${gnb_index}   vdu_index=${vdu_index}
    set suite variable   ${_G_CONTAINER_PREFIX}

    [Return]  ${_G_CONTAINER_PREFIX}


_Get Container Name Prefix Internal Use
    [Arguments]   ${gnb_index}=0   ${vdu_index}=0
    [Teardown]  run keyword and ignore error  fast_disconnect  alias=${alias}
    [Documentation]   _Get Container Name Prefix Internal Use
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    *History Change*
    ...    | date | who | what and how |
    ...    | 14.8.2021 | chris.l.cao@nokia-sbell.com | change from tenant to admin account to adapt OCP |
    ...    | 15.7.2022 | lingting.sun@nokia-sbell.com| adaption for multi gnb |
    ...    *Argument Description*
    ...    | Input Parameters | Man. | Description |
    ...    | vdu_index         | No | vdu_index. Default value is 0 |
    ...    *RETURN VALUE*
    ...    Container Name Prefix, e.g, ctr-cran1-
    ...    *Example*
    ...    | ${container_prefix} | _Get Container Name Prefix Internal Use |
    ...    | ${container_prefix} | _Get Container Name Prefix Internal Use | vdu_index=0 |
    ...
    ${pod_prefix}   _Get Pod Name Prefix Internal Use    gnb_index=${gnb_index}  vdu_index=${vdu_index}

    ${alias}  get unique id
    fast_connect_to_k8s_master  gnb_index=${gnb_index}  vdu_index=${vdu_index}  alias=${alias}
    ${container_prefix}   _Get Container prefix   ${alias}   ${pod_prefix}   pm   pmcore   ${gnb_index}   ${vdu_index}
    Run Keyword If   '''NotFound''' in '''${container_prefix}'''   Fail   get container prefix failure.
    [Return]  ${container_prefix}

_Get Container prefix
    [Arguments]   ${alias}   ${pod_prefix}  ${pod_name}=up   ${container_name}=l2hi   ${gnb_index}=0   ${vdu_index}=0
    ${command}  Set Variable  kubectl describe pod ${pod_prefix}${pod_name}-0
    ${with_pipeline_command}  Set Variable  |grep ${container_name}:|head -n 1|awk -F ${container_name} '{print $1}'
    ${container_prefix}  fast_execute   command=${command}  with_pipeline_command=${with_pipeline_command}
     ...   gnb_index=${gnb_index}  vdu_index=${vdu_index}  alias=${alias}
     [Return]   ${container_prefix}


RU Should Be Pingable
    [Arguments]  ${gnb_index}=0  ${vdu_index}=0   ${fhgw_index}=0    ${ru_index}=1   ${count}=3   ${alias}=default
    [Teardown]  run keyword and ignore error  Disconnect Interactive Connection  alias=${alias}
    [Documentation]   RU Should Be Pingable
    ...    If it's not pingable, report FAIL.
    ...    *AUTHOR* chris.l.cao
    ...    | Input Parameters | Man. | Description |
    ...    |  gnb_index        |  no | gnb_index, default value is 0 |
    ...    | vdu_index        |  no | vdu_index, default value is 0 |
    ...    | fhgw_index       |  no | fhgw_index, default value is 0 |
    ...    | count            | No | count, default value is 3 |
    ...    | ru_index         | No | ru_index, default value is 1, it's value of 'x' of 'radio-x' returned from command 'nokiacli radio list' |
    ...    | alias            | No | alias name, default value is default |
    ...
    ...    *RETURN VALUE*
    ...    None.
    ...
    ...    Example
    ...    | RU Should Be Pingable |
    ...
    ${ru_ip}   Get Radio Unit Ip Address  ru_index=${ru_index}
    ${alias}  get unique id
    connect to ruproxy  gnb_index=${gnb_index}  vdu_index=${vdu_index}   fhgw_index=${fhgw_index}   ru_index=${ru_index}  alias=${alias}
    ${out}   issh.Execute  command=setcapability ping ${ru_ip} -c ${count}   alias=${alias}
    log to console  ${out}


Prepare To Reinstall VDU
    [Arguments]  ${vdu_index}=0
    [Documentation]   Prepare To Reinstall VDU
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...	  | vdu_index | no | vdu_index, default is 0 |
    ...
    ...   *RETURN VALUE*
    ...    build number of current running VDU
    ...
    ...   Example
    ...   | ${current_build_number} |  Prepare To Reinstall VDU |
    ${tmp_current_build_number}   Get Running Build Number   vdu_index=${vdu_index}
    [Return]  ${tmp_current_build_number}


Construct VDU Scf File Name
    [Arguments]  ${build_number}=None
    ${build_number}   Run Keyword If   '${build_number}'=='None'   Get Current vDU Version
    ...   ELSE   Set Variable   ${build_number}
    ${sub_number_list}   set variable   ${build_number.split(".")}
    # vDU_SCF_0.300.xml
    ${scf_file_name}   set variable   vDU_SCF_${sub_number_list[0]}.${sub_number_list[1]}.xml
    [Return]    ${scf_file_name}


Clear Agent Flag
    [Documentation]   Clear Agent Flag
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...   | Input Parameters    | Man. | Description |
    ...   None
    ...
    ...   *RETURN VALUE*
    ...
    ...
    ...   Example
    ...  | Clear Agent Flag |
    ...
    log to console  Clear Agent Flag...
    ${agent_flag_file}   OperatingSystem.Join Path   ${OUTPUT_DIR}   agent_flag.txt
    Initialize Agent Flag File   agent_flag_file=${agent_flag_file}


Initialize Agent Flag File
    [Arguments]  ${agent_flag_file}
    [Teardown]  run keyword and ignore error  disconnect interactive connection  alias=${alias}
    ${alias}   get unique id
    connect to ute locally  alias=${alias}

    ${found}   issh.is_file   ${agent_flag_file}   alias=${alias}
    ${out}   run keyword if  "${found}"=="${True}"   issh.Execute   command=cat ${agent_flag_file}   alias=${alias}
    return from keyword if  "${found}"=="${True}"

    ${out}  issh.Execute   command=echo redeploy=0 > ${agent_flag_file}    alias=${alias}
    ${out}  issh.Execute   command=cat ${agent_flag_file}   alias=${alias}


Need Redeploy VDU
    [Documentation]   Need Redeploy VDU
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...   | Input Parameters    | Man. | Description |
    ...   None
    ...
    ...   *RETURN VALUE*
    ...   ${True} or ${False}
    ...
    ...   Example
    ...  | Need Redeploy VDU |
    ...
    ${redeploy_flag}   set variable    ${False}
    #return from keyword  ${False}

    ${r}  ${out}   run keyword and ignore error   OAM Precondition Cell Should Be Onair
    log to console  OAM Precondition Cell Should Be Onair:${r}
    return from keyword if  "${r}"!="PASS"   ${True}

    ${r}  ${out}   run keyword and ignore error   Should Have Power On All RUs
    log to console  Should Have Power On All RUs:${r}
    return from keyword if  "${r}"!="PASS"   ${True}

    [Return]  ${redeploy_flag}


Get UTE Type
    [Documentation]    Get UTE Type
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...   | Input Parameters    | Man. | Description |
    ...   None
    ...
    ...   *RETURN VALUE*
    ...   JENKINS  or  UTE_CLOUD
    ...
    ...   Example
    ...  | ${ute_type} | Get UTE Type |
    ...
     ${r}   ${out}   Run Keyword And Ignore Error    Environment Variable Should Be Set    JENKINS_URL
     return from keyword if   "${r}"=="PASS"   JENKINS

     ${a}   OperatingSystem.Run   ls -l /opt/ute/agent_env_py3/bin/activate
     return from keyword if   "No such file or directory" not in """${a}"""    JENKINS

     [Return]  UTE_CLOUD


Get Ruproxy Container ID
    [Arguments]   ${ru_index}=1  ${alias}=default
    [Documentation]   Get Ruproxy Container ID
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    modified by:       <10-14-2021>, <hongysun>, <initial created>
    ...    |  Input Parameters | Man. | Description |
    ...    | container_name    |  yes | container_name |
    ...    | ru_index         |  no | ru_index, default value is 1 |
    ...    | alias            | No | alias name, default value is default |
    ...
    ...    *RETURN VALUE*
    ...    container id
    ...
    ...    Example
    ...    | Connect to FHGW |
    ...    | ${container_id} | Get Ruproxy Container ID |
    ...    | ${container_id} | Get Ruproxy Container ID | ru_index=1 | alias=default |
    ...    | Disconnect Interactive Connection |
    ...
    ${cmd}    set variable   docker ps |grep -v POD|grep ruproxy-${ru_index}|awk '{print $1}'
    ${out}   issh.execute  command=${cmd}  alias=${alias}
    ${lines}   split to lines  ${out}
    ${container_id}   set variable if  ${lines.__len__()}>=2   ${lines[1]}   ${EMPTY}
    [Return]  ${container_id}


Get RU Version via CLI
    [Arguments]   ${gnb_index}=0   ${vdu_index}=0   ${fhgw_index}=0   ${ru_index}=1
    [Teardown]  Run Keyword And Ignore Error  Disconnect Interactive Connection  alias=${alias}
    [Documentation]   Get RU Version via CLI
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    |  gnb_index        |  no | gnb_index, default value is 0 |
    ...    | vdu_index        |  no | vdu_index, default value is 0 |
    ...    | fhgw_index       |  no | fhgw_index, default value is 0 |
    ...    | ru_index         | No | ru_index, default value is 1, it's value of 'x' of 'radio-x' returned from command 'nokiacli radio list' |

    ...
    ...    *RETURN VALUE*
    ...   RU version, type is string
    ...
    ...    Example
    ...   | ${ru_version} | Get RU Version via CLI |
    ...
    ${alias}  get unique id
    connect to radio unit    gnb_index=${gnb_index}  vdu_index=${vdu_index}   fhgw_index=${fhgw_index}   ru_index=${ru_index}   alias=${alias}
    ${out}   issh.Execute  command=cat /etc/version |awk '{print $1}'   alias=${alias}
    ${out}   strip prompt  ${out}
    ${unitBldVersion}   set variable  ${out.strip()}
    [Return]   ${unitBldVersion}


Downgrade RU To Pre-Defined RU Version
    [Arguments]    ${vdu_index}=0
    [Documentation]   Downgrade RU To Pre-Defined RU Version
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    *Change History*
    ...    | date | who | waht or how |
    ...    | 2022-7-10 | chris.l.cao | change to retry 3 times for downgrade RU to predefined versin |
    ...
    ...   | Input Parameters    | Man. | Description |
    ...	  | vdu_index | no | vdu_index, default is 0|
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...   | Downgrade RU To Pre-Defined RU Version |
    ...
    ${r}   ${out}   run keyword and ignore error
      ...   wait until keyword succeeds  3x  400   _Downgrade RU To Pre-Defined RU Version Once    vdu_index=${vdu_index}
    RU Should Be Pingable   count=10
    should be true  "${r}"=="PASS"


_Downgrade RU To Pre-Defined RU Version Once
    [Arguments]    ${vdu_index}=0
    [Documentation]   _Downgrade RU To Pre-Defined RU Version Once
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...	  | vdu_index | no | vdu_index, default is 0|
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...   | _Downgrade RU To Pre-Defined RU Version Once |
    ...
    log to console   _Downgrade RU To Pre-Defined RU Version Once

    Upload Tools To Ruproxy
    Wait Unitil RU IS Up   timeout=600
    Copy RU Image From Ruproxy to RU
    ${chksum}   ${file_version}  Get RU Image Chksum and File Version
    Install RU Image   ${chksum}   ${file_version}


Copy RU Image From Ruproxy to RU
    [Arguments]   ${gnb_index}=0  ${vdu_index}=0   ${fhgw_index}=0   ${ru_index}=1
    [Documentation]   Copy RU Image From Ruproxy to RU
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...    | gnb_index        |  no | gnb_index, default value is 0 |
    ...    | vdu_index        |  no | vdu_index, default value is 0 |
    ...    | fhgw_index       |  no | fhgw_index, default value is 0 |
    ...    | ru_index         | No | ru_index, default value is 1, it's value of 'x' of 'radio-x' returned from command 'nokiacli radio list' |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...   | Copy RU Image From Ruproxy to RU   |
    ...
    ${rf_image_file}   Get RU Image File Name
#    ${src}  OperatingSystem.join Path   ${TOOLS_INFO["work_folder_data"]}    ${rf_image_file}
    ${src}  OperatingSystem.join Path   ${TOOLS_INFO["ruproxy_work_folder_data"]}    ${rf_image_file}

    ${dst}  OperatingSystem.join Path   /run    ${rf_image_file}

    Delete File In RU   dst=${dst}    ru_index=${ru_index}

    Copy File From Ruproxy to RU  src=${src}    dst=${dst}   timeout=600   gnb_index=${gnb_index}
    ...    vdu_index=${vdu_index}   fhgw_index=${fhgw_index}   ru_index=${ru_index}


Get RU Image Chksum and File Version
    [Teardown]  run keyword and ignore error  disconnect interactive connection  alias=${alias}
    [Documentation]    Get RU Image Chksum and File Version
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   None
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...   | ${chksum} | ${file_version} | Get RU Image Chksum and File Version  |
    ...
    ${alias}   get unique id
    Connect to FHGW  alias=${alias}
    ${out}   issh.Execute    command=cd ${TOOLS_INFO["work_folder_data"]}    alias=${alias}
    ${ru_image_file}   Get RU Image File Name

    ${ru_checksum_tool}   OperatingSystem.join Path   ${TOOLS_INFO["work_folder_tool"]}     ${TOOLS_INFO["ru_checksum"]}
    ${out}   issh.Execute   command=python ${ru_checksum_tool} ${ru_image_file}   alias=${alias}

    ${out}  strip prompt  ${out}
    ${Chksum}  strip prompt  ${out}   remove_first_line=${False}
    log to console  RU image:Chksum:${Chksum}

    ${matches}   get regexp matches   ${ru_image_file}   .*_(\\d+?)-.*   1
    ${file_version}   set variable if   ${matches}   ${matches[0]}
    log to console  ${file_version}

    [Return]  ${Chksum}   ${file_version}


Install RU Image
    [Arguments]  ${chksum}   ${file_version}  ${ru_index}=1
    [Teardown]   run keywords  run keyword and ignore error  issh.Execute    command=cat /etc/version   alias=${alias}
    ...   AND   run keyword and ignore error    disconnect interactive connection  alias=${alias}
    [Documentation]   Install RU Image
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   None
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...   | Install RU Image | ${chksum} | ${file_version} |
    ...
    ${alias}   get unique id
    Connect to Radio Unit  alias=${alias}   timeout=180
    ${out}   issh.Execute    command=cat /etc/version   alias=${alias}

    ${ru_image_file}   Get RU Image File Name

    ${old_timeout}   issh.set_timeout   timeout=900   alias=${alias}
    ${cmd}   set variable    SWmanShellCommand -s /ram/${ru_image_file} 0x${chksum} ${file_version} ""
    #${out}   issh.Execute    command=${cmd}    alias=${alias}
    ${out}    wait until keyword succeeds   3x   5s   issh.Execute    command=${cmd}    alias=${alias}
    should contain   ${out}   OK

    ${cmd}   set variable    SWmanShellCommand -a ${ru_image_file} ${file_version} ${ru_image_file} ${file_version}
    #${out}   issh.Execute    command=${cmd}    alias=${alias}
    ${out}    wait until keyword succeeds   3x   5s     issh.Execute    command=${cmd}    alias=${alias}
    should contain   ${out}   OK

    issh.set_timeout   timeout=${old_timeout}   alias=${alias}
    ${out}   issh.Execute    command=cat /etc/version   alias=${alias}
    sleep   1


UnDeploy Default vDU For OCP
    [Arguments]   ${vdu_index}=0  ${gnb_index}=0   ${login_account}=core
    [Documentation]   UnDeploy Default vDU For OCP
    ...   *AUTHOR* yun.1.wang@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...   | UnDeploy Default vDU For NCS |
    ...
    ${vdu_chart_name}   Get Chart Name    chart_name=vdu   login_account=${login_account}
    ${ns}  Get VDU Namespace From TestLine  ${vdu_index}  ${gnb_index}
    run keyword if     "${login_account}"=="core"   vDU Cluster Login With Admin    ${vdu_index}   ${gnb_index}
    ...   ELSE   vDU Cluster Login With Tenant    ${vdu_index}  ${gnb_index}
    run keyword and ignore error     helm.helm3_delete    ${vdu_chart_name}  ${ns}  helm_cmd=helm
    Wait Until Keyword Succeeds  300   30s    Make Sure Chart Is Deleted   vdu_index=${vdu_index}  chart_name=vdu
    ...   ns=${ns}   login_account=${login_account}
    sleep  2min
    Wait Until Keyword Succeeds   120  30s  _Make Sure Pod Is Deleted
    [Teardown]    run keyword and ignore error  helm.helm_master_close

_Make Sure Pod Is Deleted
	${pods_info}=    vDU Get Pods Full Info
	Should Be Empty  ${pods_info}

UnDeploy Default Prerequisite For OCP
    [Arguments]   ${vdu_index}=0  ${gnb_index}=0   ${login_account}=core
    [Documentation]   UnDeploy Default Prerequisite For OCP
    ...   *AUTHOR* yun.1.wang@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...   | UnDeploy Default Prerequisite For OCP |
    ...
    ${prerequisite_chart_name}  Get Chart Name  chart_name=prerequisite   login_account=${login_account}
    ${ns}  Get VDU Namespace From TestLine  ${vdu_index}  ${gnb_index}
    run keyword if     "${login_account}"=="core"   vDU Cluster Login With Admin    ${vdu_index}   ${gnb_index}
    ...   ELSE   vDU Cluster Login With Tenant    ${vdu_index}  ${gnb_index}
    run keyword and ignore error     helm.helm3_delete    ${prerequisite_chart_name}  ${ns}  helm_cmd=helm
    Wait Until Keyword Succeeds  120   10s    Make Sure Chart Is Deleted   vdu_index=${vdu_index}  chart_name=${prerequisite_chart_name}
    ...   ns=${ns}   login_account=${login_account}
    [Teardown]    run keyword and ignore error  helm.helm_master_close

UnDeploy Default Preparation For OCP
    [Arguments]   ${vdu_index}=0  ${gnb_index}=0   ${login_account}=core
    [Documentation]   UnDeploy Default Preparation For OCP
    ...   *AUTHOR* yun.1.wang@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...   | UnDeploy Default Preparation For OCP |
    ...
    ${preparation_chart_name}  Get Chart Name  chart_name=preparation   login_account=${login_account}
    ${ns}  Get VDU Namespace From TestLine  ${vdu_index}  ${gnb_index}
    run keyword if     "${login_account}"=="core"   vDU Cluster Login With Admin    ${vdu_index}   ${gnb_index}
    ...   ELSE   vDU Cluster Login With Tenant    ${vdu_index}  ${gnb_index}
    run keyword and ignore error     helm.helm3_delete    ${preparation_chart_name}  ${ns}  helm_cmd=helm
    Wait Until Keyword Succeeds  120   10s    Make Sure Chart Is Deleted   vdu_index=${vdu_index}  chart_name=${preparation_chart_name}
    ...   ns=${ns}   login_account=${login_account}
    [Teardown]    run keyword and ignore error  helm.helm_master_close

Make Sure Chart Is Deleted
    [Arguments]     ${chart_name}    ${vdu_index}=0    ${ns}=cran1    ${login_account}=core
    [Teardown]  Run Keyword And Ignore Error  Disconnect Interactive Connection  alias=${alias}
    [Documentation]  Make Sure Chart Is Deleted
        ...   *AUTHOR* sophie.jiang@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...   | Make Sure Chart Is Deleted |
    ...
    ${chart_release_name}    Get Chart Name  chart_name=${chart_name}   login_account=${login_account}
    should not contain  ${chart_release_name}   ${chart_name}


Get Chart Name
    [Arguments]     ${chart_name}    ${gnb_index}=0   ${vdu_index}=0   ${login_account}=core
    [Teardown]  Run Keyword And Ignore Error  Disconnect Interactive Connection  alias=${alias}
    [Documentation]   Get Chart Name
    ...   *AUTHOR* sophie.jiang@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...   | Get Prerequisite Name |
    ...
    ${platform_name}   Set Variable    OCP
    ${helm_name}    Set Variable If   "${platform_name}"=="NCS"  helm3    helm
    ${grep_name}    Set Variable If   "${chart_name}"=="vdu"  aic-vdu-0
    ...  "${chart_name}"=="prerequisite"   aic-vdu-prerequisite
    ...  "${chart_name}"=="preparation"  aic-vdu-cluster
    ${alias}  Get Unique Id
    run keyword if     "${login_account}"=="core"
    ...   Connect To K8s Master Interactively   vdu_index=${vdu_index}  gnb_index=${gnb_index}   alias=${alias}
    ...   ELSE   Connect To K8s Master With Tenant Interactively   vdu_index=${vdu_index}  gnb_index=${gnb_index}  alias=${alias}
    ${ns}   get vdu namespace from testline   vdu_index=${vdu_index}
    ${cmd}=   Set Variable     ${helm_name} list -n ${ns}|grep ${grep_name} |grep -v rbac|awk '{print $1}'
    log to console  ${cmd}
    ${out}  issh.Execute    command=${cmd}   alias=${alias}
    log to console  ${out}
    ${release_name}  Strip Prompt  ${out}
    ${tmp_list}  Split To Lines   ${release_name}
    ${tmp_list_length}   get length    ${tmp_list}

    [Return]  ${release_name}


Upload Image
    [Arguments]  ${vdu_index}=0  ${gnb_index}=0  ${build_number}=0.300.903  ${namespace}=cran1  ${la}=core
    [Documentation]    Do some common thing for every postcondition of cases
    ...    *AUTHOR* yun.1.wang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Upload Image | build_number=0.300.800|
    run keyword if     "${la}"=="core"   vDU Cluster Login With Admin    ${vdu_index}  ${gnb_index}
    ...   ELSE   vDU Cluster Login With Tenant    ${vdu_index}  ${gnb_index}
    ${package_prefix}    Get Package Prefix From Global Variables File    ${build_number}
    ${full_package_name}    Set Variable    ${package_prefix}_${build_number}
    helm.download_onboard_app_tool    target_path=/var/home/${la}/${build_number}/Image    chart_version=${full_package_name}
    helm.execute_command_on_master_cluster
    ...    cp /var/home/${la}/${build_number}/Image/onBoardingApp/loadImages.sh /var/home/${la}/${build_number}/Image/
    helm.execute_command_on_master_cluster
    ...    cp /var/home/${la}/${build_number}/Image/onBoardingApp/images.properties* /var/home/${la}/${build_number}/Image/
    helm.execute_command_on_master_cluster    cd /var/home/${la}/${build_number}/Image;chmod 777 *;./loadImages.sh -n ${namespace}
    log    upload images done    console=true
    [Teardown]    helm.helm_master_close


Create Cluster-preparation and Verify Prerequisite Creation
    [Arguments]  ${vdu_index}=0  ${gnb_index}=0   ${remote_dst_file}=values-override.yaml
    ...   ${remote_dst_path}=/home/core/HelmChart/aic-vdu-cluster-preparation  ${fail_on_error}=false
    ...   ${helm_cmd}=helm  ${login_account}=core
    [Documentation]    Create Cluster-preparation and Verify Prerequisite creation
    ...    *AUTHOR* hongyuan.sun@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...	   | remote_dst_file | Yes | remote_dst_file on OE |
    ...	   | remote_dst_path | Yes | remote_dst_path on OE |
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Create Cluster-preparation and Verify Prerequisite creation | remote_dst_file=values-override.yaml | remote_dst_path=home/core/aic-vdu |
    ...
    ${ns}  Get VDU Namespace From TestLine  ${vdu_index}  ${gnb_index}
    ${pre_release_name}   Get Cluster-preparation Release Name From Testline  ${gnb_index}  ${vdu_index}
    run keyword if    "${login_account}"=="core"  vDU Cluster Login With Admin   ${vdu_index}  ${gnb_index}
    ...    ELSE    vDU Cluster Login With Tenant   ${vdu_index}  ${gnb_index}
    helm.helm3_install
    ...   ${pre_release_name}
    ...   ${remote_dst_path}
    ...   ${ns}
    ...   value_files=${remote_dst_file}
    ...   helm_cmd=${helm_cmd}
    log    Deploy Cluster-preparation done    console=true
    [Teardown]    helm.helm_master_close


Create Preparation and Verify Preparation creation
    [Arguments]  ${vdu_index}=0  ${gnb_index}=0   ${remote_dst_file}=values-override.yaml   ${login_account}=core
    ...   ${remote_dst_path}=/home/core/HelmChart/aic-vdu-cluster-preparation   ${fail_on_error}=false  ${helm_cmd}=helm
    [Documentation]    Create Preparation and Verify Preparation creation
    ...    *AUTHOR* yun.1.wang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...	   | remote_dst_file | Yes | remote_dst_file on OE |
    ...	   | remote_dst_path | Yes | remote_dst_path on OE |
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Create Preparation and Verify Preparation creation | remote_dst_file=values-override.yaml |
    ...     remote_dst_path=home/core/aic-vdu |
    ...
    ${ns}  Get VDU Namespace From TestLine  ${vdu_index}  ${gnb_index}
    ${preparation_release_name}   Get Preparation Release Name From Testline  ${gnb_index}  ${vdu_index}
    run keyword if     "${login_account}"=="core"   vDU Cluster Login With Admin    ${vdu_index}   ${gnb_index}
    ...   ELSE   vDU Cluster Login With Tenant    ${vdu_index}  ${gnb_index}
    helm.helm3_install
    ...   ${preparation_release_name}
    ...   ${remote_dst_path}
    ...   ${ns}
    ...   value_files=${remote_dst_file}
    ...   helm_cmd=${helm_cmd}
    log    Deploy Preparation done    console=true
    [Teardown]    helm.helm_master_close


Create Prerequisite and Verify Prerequisite creation
    [Arguments]  ${vdu_index}=0  ${gnb_index}=0   ${remote_dst_file}=values-override.yaml   ${login_account}=core
    ...   ${remote_dst_path}=/home/core/HelmChart/aic-vdu-prerequisite   ${fail_on_error}=false  ${helm_cmd}=helm
    [Documentation]    Create Prerequisite and Verify Prerequisite creation
    ...    *AUTHOR* yun.1.wang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...	   | remote_dst_file | Yes | remote_dst_file on OE |
    ...	   | remote_dst_path | Yes | remote_dst_path on OE |
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Create Prerequisite and Verify Prerequisite creation | remote_dst_file=values-override.yaml |
    ...     remote_dst_path=home/core/aic-vdu |
    ...
    ${ns}  Get VDU Namespace From TestLine  ${vdu_index}  ${gnb_index}
    ${pre_release_name}   Get Prerequisite Release Name From Testline  ${gnb_index}  ${vdu_index}
    run keyword if     "${login_account}"=="core"   vDU Cluster Login With Admin    ${vdu_index}   ${gnb_index}
    ...   ELSE   vDU Cluster Login With Tenant    ${vdu_index}  ${gnb_index}
    helm.helm3_install
    ...   ${pre_release_name}
    ...   ${remote_dst_path}
    ...   ${ns}
    ...   value_files=${remote_dst_file}
    ...   helm_cmd=${helm_cmd}
    log    Deloy Prerequisite done    console=true
    [Teardown]    helm.helm_master_close


Create VDU and Verify VDU creation
    [Arguments]  ${vdu_index}=0  ${gnb_index}=0   ${remote_dst_file}=values-override.yaml   ${login_account}=core
    ...   ${remote_dst_path}=/home/core/HelmChart/aic-vdu   ${timeout}=${900}  ${pod_number}=21  ${helm_cmd}=helm
    [Documentation]    Create VDU and Verify VDU creation
    ...    *AUTHOR* yun.1.wang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...	   | remote_dst_file | Yes | remote_dst_file on OE |
    ...	   | remote_dst_path | Yes | remote_dst_path on OE |
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Create VDU and Verify VDU creation | remote_dst_file=values-override.yaml | remote_dst_path=home/core/aic-vdu |
    ...
    ${ns}  Get VDU Namespace From TestLine  ${vdu_index}  ${gnb_index}
    run keyword if     "${login_account}"=="core"   vDU Cluster Login With Admin    ${vdu_index}   ${gnb_index}
    ...   ELSE   vDU Cluster Login With Tenant    ${vdu_index}  ${gnb_index}
    helm.helm3_install_wait_until_ready
    ...   vdu
    ...   ${remote_dst_path}
    ...   ${ns}
    ...   value_files=${remote_dst_file}
    ...   timeout=${timeout}
    ...   pod_number=${pod_number}
    ...   helm_cmd=${helm_cmd}
    log    Deloy vDU done    console=true
    [Teardown]    helm.helm_master_close

Deploy VDU For OCP
    [Arguments]   ${gnb_index}=0  ${vdu_index}=0  ${build_number}=None  ${login_account}=core   ${pod_number}=21
    ...    ${cluster_values_path}=None    ${prerequisite_values_path}=None    ${vdu_values_path}=None
    [Documentation]    Download vdu zip file and upload images and create intnet,pvc,vdu
    ...    *AUTHOR* yun.1.wang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...	   | build_number | Yes | build_number |
    ...    *RETURN VALUE*
    ...    None
    ...    |2022.6.23 jianlin.zhang@nokia-sbell.com update the kw to adaption for CRAN tenant login |
    ...    |2022.11.4 jinbo.yu@nokia-sbell.com use values-override.yaml from current helm release |
    ...
    ...    Example
    ...    | Deploy VDU For NCS | build_number=0.300.903 |
    ...
    ${build_number}   Run Keyword If   '${build_number}'=='None'  Get Current vDU Version   ${login_account}
    ...   ELSE   Set Variable   ${build_number}
    run keyword if     "${login_account}"=="core"   vDU Cluster Login With Admin    ${vdu_index}
    ...   ELSE   vDU Cluster Login With Tenant    ${vdu_index}  ${gnb_index}
    ${ns}  Get VDU Namespace From TestLine  ${vdu_index}  ${gnb_index}
    ${output}=    helm.execute_command_on_master_cluster    test -d /var/home/${login_account}/${build_number}
    _Clean Old Releases And Download New Vdu Package  ${build_number}   ${login_account}
    Upload Image   build_number=${build_number}  namespace=${ns}    la=${login_account}

    ${vdu_release_name}   Set Variable    vdu
    ${pre_release_name}   Set Variable    prerequisite

    Set Test Variable  ${Build_folder}  /var/home/${login_account}/${build_number}/HelmChart

    run keyword if     "${login_account}"=="core"   vDU Cluster Login With Admin    ${vdu_index}
    ...   ELSE   vDU Cluster Login With Tenant    ${vdu_index}  ${gnb_index}

    ${cp_str}=    Set Variable    cp ${prerequisite_values_path} ${Build_folder}/aic-vdu-prerequisite/;
    ${cp_str}=    Set Variable    ${cp_str}cp ${vdu_values_path} ${Build_folder}/aic-vdu/;
    ${cp_str}=    Set Variable    ${cp_str}cp ${cluster_values_path} ${Build_folder}/aic-vdu-cluster-preparation/
    ${_}    ${prerequisite_file_name}=    Split Path	${prerequisite_values_path}
    ${_}    ${cluster_file_name}=    Split Path    ${cluster_values_path}
    ${_}    ${vdu_values_file_name}=    Split Path    ${vdu_values_path}
    ${prerequisite_file_path}=    Join Path    ${Build_folder}/aic-vdu-prerequisite/    ${prerequisite_file_name}
    ${cluster_file_path}=    Join Path    ${Build_folder}/aic-vdu-cluster-preparation/    ${cluster_file_name}
    ${vdu_values_path}=    Join Path    ${Build_folder}/aic-vdu/    ${vdu_values_file_name}

    ${output}=    helm.execute_command_on_master_cluster    ${cp_str}
    Should Be Empty  ${output.stderr}

    Create Preparation and Verify Preparation creation
    ...    remote_dst_file=${cluster_file_path}
    ...    login_account=${login_account}
    ...    remote_dst_path=/var/home/${login_account}/${build_number}/HelmChart/aic-vdu-cluster-preparation
    ...    fail_on_error=false
    ...    helm_cmd=helm
    Create Prerequisite and Verify Prerequisite creation
    ...    remote_dst_file=${prerequisite_file_path}
    ...    login_account=${login_account}
    ...    remote_dst_path=/var/home/${login_account}/${build_number}/HelmChart/aic-vdu-prerequisite
    ...    fail_on_error=false
    ...    helm_cmd=helm
    Create VDU and Verify VDU creation
    ...    remote_dst_file=${vdu_values_path}
    ...    login_account=${login_account}
    ...    remote_dst_path=/var/home/${login_account}/${build_number}/HelmChart/aic-vdu
    ...    pod_number=${pod_number}
    ...    helm_cmd=helm


Deploy VDU For OCP With Updated Yaml File
    [Arguments]   ${gnb_index}=0  ${vdu_index}=0  ${build_number}=0.300.903   ${original_vdu_override_file}=${EMPTY}
    ...   ${updated_override_yaml_dict}=${EMPTY}   ${timeout}=${1200}  ${pod_number}=21  ${login_account}=core
    [Documentation]    Download vdu zip file and upload images and create intnet,pvc,vdu
    ...    *AUTHOR* jianlin.zhang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...	   | build_number | Yes | build_number |
    ...    | updated_override_yaml_file | no | tmp/vdu/charts/values-override.yaml |
    ...    * RETURN VALUE *
    ...    None
    ...    -01.02.2022,jianlin.zhang@nokia-sbell.com, update for OCP deploy with updated yaml
    ...
    ...    Example
    ...    | Deploy VDU For OCP With Updated Yaml File | build_number=0.300.903 | tmp/vdu/charts/values-override.yaml |
    ...
    Run Keyword If  '${login_account}'=='core'  vDU Cluster Login With Admin    ${vdu_index}  ${gnb_index}
    ...  ELSE  vDU Cluster Login With Tenant  ${vdu_index}  ${gnb_index}
    ${ns}  Get VDU Namespace From TestLine  ${vdu_index}  ${gnb_index}
    _Clean Old Releases And Download New Vdu Package  build_number=${build_number}  login_account=${login_account}
    Upload Image   build_number=${build_number}  namespace=${ns}  la=${login_account}
    Set Test Variable  ${Kuashaw_folder}  /var/home/${login_account}/One_Click_Deployment_WS/Kuashaw-oneClick/Kuashaw-oneClick-lcm/cnf
    ${conf_dict_vdu}   yaml_file_to_dictionary   ${original_vdu_override_file}
    Set Test Variable  ${Build_folder}  /var/home/${login_account}/${build_number}/HelmChart
    Run Keyword If  '${login_account}'=='core'  vDU Cluster Login With Admin    ${vdu_index}  ${gnb_index}
    ...  ELSE  vDU Cluster Login With Tenant  ${vdu_index}  ${gnb_index}
    ${cmd_1}  set variable  cp ${Kuashaw_folder}/*.yaml ${Build_folder}/aic-vdu-prerequisite/;
    ${cmd_2}  set variable  ${cmd_1}cp ${Kuashaw_folder}/*.yaml ${Build_folder}/aic-vdu/;
    ${cmd}  set variable  ${cmd_2}cp ${Kuashaw_folder}/*.yaml ${Build_folder}/aic-vdu-cluster-preparation/;
    ${output}=    helm.execute_command_on_master_cluster   ${cmd}
    Should Be Empty  ${output.stderr}
    ${original_override_path}  ${original_file_name}=  split path   ${original_vdu_override_file}
    ${new_vdu_override_yaml} =    Get A File  ${original_override_path}/redeploy_vdu_override.yaml
    run keyword if  "${updated_override_yaml_dict}"!="${EMPTY}"   Print A Dictionary  ${updated_override_yaml_dict}
    run keyword if  "${updated_override_yaml_dict}"!="${EMPTY}"   Print A Dictionary  ${conf_dict_vdu}
    run keyword if  "${updated_override_yaml_dict}"!="${EMPTY}"
    ...   Update_Dictionary   src_dict=${updated_override_yaml_dict}   dst_dict=${conf_dict_vdu}
    run keyword if  "${updated_override_yaml_dict}"!="${EMPTY}"   Print A Dictionary  ${conf_dict_vdu}
    dictionary_to_yaml_file   ${conf_dict_vdu}   ${new_vdu_override_yaml}
    ${alias_k8s_master}   Get Unique ID
    Run Keyword If  '${login_account}'=='core'  Connect To K8s Master Interactively  alias=${alias_k8s_master}
    ...  ELSE  Connect To K8s Master With Tenant Interactively  alias=${alias_k8s_master}
    issh.Upload File  local_path=${new_vdu_override_yaml}
    ...    remote_path=/var/home/${login_account}/${build_number}/HelmChart/aic-vdu
    ...    alias=${alias_k8s_master}
    sleep  80s
    log    upload file done    console=true
    ${preparation_remote_dst_file}  set variable
    ...  /var/home/${login_account}/${build_number}/HelmChart/aic-vdu-cluster-preparation/values-override.aic-cluster-preparation.yaml
    Create Cluster-preparation and Verify Prerequisite Creation
    ...    remote_dst_file=${preparation_remote_dst_file}
    ...    remote_dst_path=/var/home/${login_account}/${build_number}/HelmChart/aic-vdu-cluster-preparation
    ...    fail_on_error=false
    ...    helm_cmd=helm
    ...    login_account=${login_account}
    Create Prerequisite and Verify Prerequisite creation
    ...    remote_dst_file=/var/home/${login_account}/${build_number}/HelmChart/aic-vdu-prerequisite/values-override.aic-prerequisite.yaml
    ...    remote_dst_path=/var/home/${login_account}/${build_number}/HelmChart/aic-vdu-prerequisite
    ...    fail_on_error=false
    ...    helm_cmd=helm
    ...    login_account=${login_account}
    Create VDU and Verify VDU creation
    ...    remote_dst_file=/var/home/${login_account}/${build_number}/HelmChart/aic-vdu/redeploy_vdu_override.yaml
    ...    remote_dst_path=/var/home/${login_account}/${build_number}/HelmChart/aic-vdu
    ...    timeout=${timeout}
    ...    pod_number=${pod_number}
    ...    helm_cmd=helm
    ...    login_account=${login_account}

_Get Install Package Fuzzy Name
    [Arguments]   ${build_number}
    ${info}   Split String    ${build_number}   .
    ${fuzzy_name}   set variable  *.${info}[1].*
    [Return]   ${fuzzy_name}

_Get Install Package Branch Pre Name
    [Arguments]   ${build_number}
    ${info}   Split String    ${build_number}   .
    ${Pre_name}   set variable  ${info}[0]
    [Return]   ${Pre_name}

_Get Prerequisite Build Number From Manifest
    [Arguments]   ${path}
    ${cmd}    set variable  cat ${path}/manifest.json | grep -o "aic-vdu-prerequisite-*.*.tgz"
    ${out}   helm.execute_command_on_master_cluster    ${cmd}
    ${prerequisite_build}  ${postfix}   Split String From Right    ${out.stdout.split('-')[-1]}   .    1
    [Return]   ${prerequisite_build}

_Get Cluster Preparation Build Number From Manifest
    [Arguments]   ${path}
    ${cmd}    set variable  cat ${path}/manifest.json | grep -o "aic-vdu-cluster-preparation-*.*.tgz"
    ${out}   helm.execute_command_on_master_cluster    ${cmd}
    ${prerequisite_build}  ${postfix}   Split String From Right    ${out.stdout.split('-')[-1]}   .    1
    [Return]   ${prerequisite_build}

_Clean Old Releases And Download New Vdu Package
    [Arguments]   ${build_number}    ${login_account}=core
    ${fuzzy_name}   _Get Install Package Fuzzy Name   ${build_number}
    helm.execute_command_on_master_cluster    cd /var/home/${login_account};rm -rf ${fuzzy_name}
    helm.execute_command_on_master_cluster    mkdir ${build_number}
    ${Pre_name}  _Get Install Package Branch Pre Name   ${build_number}
    ${package_prifix}    Get Package Prefix From Global Variables File   ${build_number}
    Set Test Variable  ${repository}  https://artifactory-hz1.int.net.nokia.com/artifactory/mnp5g-central-public-remote/System_Release/
#    run keyword if  '${Pre_name}'=='14'  helm.helm_download_cnf_package    /var/home/${login_account}/${build_number}
#    ...  vDUCNF22R2  ${build_number}  ${repository}
#    ...  ELSE   helm.helm_download_cnf_package    /var/home/${login_account}/${build_number}  vDUCNF  ${build_number}  ${repository}
#    helm.execute_command_on_master_cluster
    helm.helm_download_cnf_package    /var/home/${login_account}/${build_number}   ${package_prifix}   ${build_number}  ${repository}
    ${prerequisite_build_number}    _Get Prerequisite Build Number From Manifest    /var/home/${login_account}/${build_number}
    ${cluster-preparation_build_number}    _Get Cluster Preparation Build Number From Manifest    /var/home/${login_account}/${build_number}
    helm.execute_command_on_master_cluster
    ...  cd /var/home/${login_account}/${build_number}/HelmChart;tar -xzvf aic-vdu-${build_number}.tgz;
    helm.execute_command_on_master_cluster
    ...  cd /var/home/${login_account}/${build_number}/HelmChart;tar -xzvf aic-vdu-prerequisite-${prerequisite_build_number}.tgz
    helm.execute_command_on_master_cluster
    ...  cd /var/home/${login_account}/${build_number}/HelmChart;tar -xzvf aic-vdu-cluster-preparation-${cluster-preparation_build_number}.tgz


UnDeploy VDU For OCP
    [Arguments]   ${vdu_index}=0  ${gnb_index}=0   ${login_account}=core
    [Documentation]    Undeploy VDU, PVC, Intnet
    ...    *AUTHOR* yun.1.wang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...    *RETURN VALUE*
    ...    None
    ...    |2022.6.23 jianlin.zhang@nokia-sbell.com update the kw to adaption for CRAN tenant login|
    ...
    ...    Example
    ...    | UnDeploy VDU For NCS |
    ...
    UnDeploy Default vDU For OCP  vdu_index=${vdu_index}  gnb_index=${gnb_index}   login_account=${login_account}
    UnDeploy Default Prerequisite For OCP  vdu_index=${vdu_index}  gnb_index=${gnb_index}  login_account=${login_account}
    UnDeploy Default Preparation For OCP  vdu_index=${vdu_index}  gnb_index=${gnb_index}  login_account=${login_account}


UnDeploy VDU For OCP NEW
    [Arguments]   ${vdu_index}=0  ${gnb_index}=0
    ${alias}  get unique id
    Connect To K8s Master With Tenant Interactively  alias=${alias}
    ${ns}   Get vDU Namespace From TestLine  ${vdu_index}  ${gnb_index}
    ${cmd}  set variable  helm list -n ${ns} | grep -v
    ${cmd}  set variable  helm list -n ${ns} | awk '{print $1}'
    ${out}  issh.execute  command=${cmd}  alias=${alias}
    ${helm_list}  strip prompt  ${out}
    ${helm_list_tmp}  remove_value_info  value=${helm_list}  index=0  split_info=\n
    ${helm_list_split}  Split String  ${helm_list_tmp}  \n
    ${helm_list_now}  reverse_list_value  list_info=${helm_list_split}

    FOR  ${item}  IN  @{helm_list_now}
        log to console  ${item} undeploy......
        ${cmd}  set variable  helm uninstall ${item} -n ${ns}
        Wait Until Keyword Succeeds  300s  30s  issh.execute  command=${cmd}  alias=${alias}
    END
    [Teardown]  Disconnect Interactive Connections


All DUs Container Status Should Be Normal
    [Arguments]  ${vdu_index}=0   ${gnb_index}=0
    [Teardown]  Run Keyword And Ignore Error   fast_disconnect  alias=${alias}
    ${pod_abbr_list}   set variable  ${AIC_VDU_PODS.keys()}
    ${alias}  Get Unique Id
    fast_connect_to_k8s_master   vdu_index=${vdu_index}    alias=${alias}   gnb_index=${gnb_index}

    FOR   ${pod_abbr}  IN  @{pod_abbr_list}
       vDU Special Pod Status And Container Number Should Be Expected   pod_abbr=${pod_abbr}    status=Running  vdu_index=${vdu_index}
    ...   alias=${alias}
    END

Get vDU Vnf Config Dictionary From Agent
    [Arguments]  ${gnb_index}=0   ${vdu_index}=0
    [Documentation]  Get vDU Vnf Config Dictionary From Agent
    ...  author: hongping.rao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...   Dictionary of vDU Vnf Config
    ...
    ...    Example
    ...    | ${conf_dict}     | Get vDU Vnf Config Dictionary From Agent   |
    ...
    ${alias}   get unique id
    Connect To K8s Master With Tenant Interactively  vdu_index=${vdu_index}  alias=${alias}   gnb_index=${gnb_index}
    ${vdu_info}  get_k8s_tenant_ssh_connection_info  gnb_index=${gnb_index}  vdu_index=${vdu_index}
    ${lcm_path}=  Set Variable
    ...  /var/home/${vdu_info['username']}/One_Click_Deployment_WS/Kuashaw-oneClick/Kuashaw-oneClick-lcm/
    issh.execute    command=cd ${lcm_path}   alias=${alias}
    ${remote_cnf}  Set Variable   ${lcm_path}cnf/values-override.aic-cnf.yaml
    issh.execute  command=python kuashaw_lcm.py convert   alias=${alias}
    ${local_path_to_cnf}   Get A File   cnf  vdu_cnf_${alias}.xml
    issh.download_file  remote_path=${remote_cnf}
    ...  local_path=${local_path_to_cnf}   alias=${alias}
    disconnect interactive connection   ${alias}
    File Should Exist   ${local_path_to_cnf}
    ${dictionary_content}   yaml_file_to_dictionary   ${local_path_to_cnf}
    [Return]   ${dictionary_content}

Get Kubeconfig From DU
    [Arguments]   ${gnb_index}=0   ${vdu_index}=0
    [Documentation]  Get Kubeconfig From DU
    ...    *Author:* rui.3.li@nokia-sbell.com
    ...    *Change History*
    ...    | date | who | waht or how |
    ...    | 2022-2-21 | r3li | init create |
    ...    | 2022-4-22 | r3li | reomove prompt info of return value |
    ...    *Arguments Description*
    ...    | Input Parameters | Man. | Description |
    ...    | gnb_index | No | int, gnb index. |
    ...    | vdu_index | No | int, vdu index. |
    ...    *Example*
    ...    | Get Kubeconfig From DU | 0 | 0 |
    ...    *Return*
    ...    - string, Kubeconfig file content encode base64
    [Return]    ${base64_out}
    ${alias}   get unique id
    Connect To K8s Master With Tenant Interactively   ${gnb_index}   ${alias}   ${vdu_index}
    ${cran_user}    set variable    ${tl.gnbs[0].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.username}
    ${out}    issh.execute    command=base64 -w 0 /var/home/${cran_user}/.kube/config   alias=${alias}
    ${base64_out}   set variable   ${out}
    ${out_list}     Split String     ${base64_out}     [
    ${base64_out}    set variable    ${out_list}[0]
    ${out_list}     Split String     ${base64_out}     \n
    ${base64_out}    set variable    ${out_list}[1]
    [Teardown]   disconnect interactive connection   ${alias}


Get ImageRegistry From VDU
    [Arguments]   ${gnb_index}=0   ${vdu_index}=0
    [Documentation]  Get ImageRegistry From VDU
    ...    *Author:* rui.3.li@nokia-sbell.com
    ...    *Change History*
    ...    | date | who | waht or how |
    ...    | 2022-2-21 | r3li | init create |
    ...    *Arguments Description*
    ...    | Input Parameters | Man. | Description |
    ...    | gnb_index | No | int, gnb index. |
    ...    | vdu_index | No | int, vdu index. |
    ...    *Example*
    ...    | Get ImageRegistry From VDU | 0 | 0 |
    ...    *Return*
    ...    - string, imageRegistry in du
    ${conn}   vDU Cluster Login With Admin
    ${command}   set variable   oc get route default-route -n openshift-image-registry --template='{{ .spec.host }}'
    ${out}   helm.execute_command_on_master_cluster   ${command}
    ${ns}  get vdu namespace from testline
    ${out}   set variable    ${out.stdout}/${ns}
    [Return]    ${out}
    [Teardown]  helm.helm_master_close


Get ImageRegistry Password From vDU
    [Arguments]  ${gnb_index}=0  ${vdu_index}=0
    [Return]    ${out}
    ${conn}   vDU Cluster Login With Tenant
    ${command}   set variable   oc whoami -t
    ${out}   helm.execute_command_on_master_cluster   ${command}
    ${out}   Strip String   ${out.stdout}
    [Teardown]  helm.helm_master_close


Get Package Prefix From Global Variables File
    [Arguments]    ${build_number}
    [Documentation]  Get Package Prefix From Global Variables File
    ...    author: luofei.tu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | build_number | Yes | build_number. eg: 0.300.001 or 14.300.001|
    ...
    ...    *RETURN VALUE*
    ...    package_prefix
    ...
    ...    Example
    ...    | ${package_prefix} | Get Package Prefix From Global Variables File | ${build_number} |

    ${SW_version_list1}    split string  ${build_number}    .
	${trunk_or_branch}    Set Variable    ${SW_version_list1}[:2]
	${trunk_or_branch}    Evaluate    '.'.join(${trunk_or_branch})
	${package_prefix}    set variable   ${PACKAGE_PRE_MAPPING}[${trunk_or_branch}]
	[Return]    ${package_prefix}


Get Capability From K8S
    [Arguments]  ${ctr_abbr}=oambb
    [Teardown]  Run Keyword And Ignore Error   Disconnect Interactive Connection  alias=${alias}
    [Documentation]   Get Capability From K8S
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ctr_abbr  | No | contrainer abbreviation, default value is oambb  |
    ...
    ...    *RETURN VALUE*
    ...   list of Capability
    ...
    ...    Example
    ...   | ${cap_list} | Get Capability From K8S | ctr_abbr=oambb |
    ...
    ${alias}   Get Unique ID
    Connect To K8s Master With Tenant Interactively  alias=${alias}
    ${full_pod_name}   Get Full Pod Name By Container Abbreviation Interactively   container_abbr=${ctr_abbr}
    ${out}   issh.Execute   command=kubectl get pods ${full_pod_name} -o json | jq -M '.spec.containers[].securityContext'   alias=${alias}

    ${out}  Strip Prompt  ${out}
    ${r}  ${out}  Run Keyword And Ignore Error  Evaluate   json.loads("""${out}""")  modules=json
    Log to console  ${out}
    ${cap_list}  Set Variable  ${out["capabilities"]["add"]}
    Sort List  ${cap_list}
    [Return]  ${cap_list}


Get Capability From Container
    [Arguments]  ${ctr_abbr}=oambb   ${program}=/opt/nokia/SS_OAM/HAS/HAS
    [Teardown]  Run Keyword And Ignore Error   Disconnect Interactive Connection  alias=${alias}
    [Documentation]   Get Capability From Container
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ctr_abbr  | No | contrainer abbreviation, default value is oambb  |
    ...    | program  | No | program name, default value is /opt/nokia/SS_OAM/HAS/HAS  |
    ...
    ...    *RETURN VALUE*
    ...   list of Capability
    ...
    ...    Example
    ...   | ${cap_list} | Get Capability From Container | program=/opt/nokia/SS_OAM/HAS/HAS |
    ...
    ${alias}   Get Unique Id
    Connect To VDU Container With Tenant Interactively   ctr_abbr=${ctr_abbr}     alias=${alias}
    ${out}   issh.Execute
    ...   command=getcap ${program} |cut -d ' ' -f2 |cut -d '=' -f 1 |sed s/cap_//g
    ...   alias=${alias}

    ${out}  Strip Prompt  ${out}
    ${out}  Set Variable  ${out.upper()}
    ${cap_list}  String.Split String  string=${out}   separator=,
    Sort List  ${cap_list}
    [Return]  ${cap_list}

Get L2HI mac address
    [Arguments]    ${pod_abbr}=up   ${container}=l2hi   ${vdu_index}=0   ${gnb_index}=0
    [Documentation]  judging pod restart time should be as expected
    ...    *Author*: tingting.xiao@nokia-sbell.com
    ...    *Change History*
    ...    | who | date | how or what |
    ...    | tixiao | 02-23-2023 | create |
    ...    *Parameter Description*
    ...    | Input Parameters | Man. | Description |
    ...    | pod_abbr | No. | pod name |
    ...	   | container | No. | container name |
    ...    | vdu_index | No | int, gnb index. |
    ...    | gnb_index | No | int, vdu index. |
    ...    *Example*
    ...    | Get L2HI mac address |

    ${alias_l2hi}  Get Unique Id
    Connect To VDU Container With Tenant Interactively  pod_abbr=${pod_abbr}  ctr_abbr=${container}  alias=${alias_l2hi}
    ${out}   issh.Execute  command=dpdk-cli show port table   check_result=${False}  alias=${alias_l2hi}
    ${matches}  Get Regexp Matches   ${out}   l2biphi\\s+BIP\\s+(\\w+:)+\\w+\\.\\d+\\s+(\\w+:)+\\w+
    ${mac_l2hi}  Get Regexp Matches   ${matches}[0]   (\\w+:){5}\\w+
    [Return]    ${mac_l2hi}    ${alias_l2hi}


_Set Pod And Container Name Prefix
    ${_G_POD_PREFIX}   _Get Pod Name Prefix Internal Use
    set suite variable   ${_G_POD_PREFIX}

    ${_G_CONTAINER_PREFIX}   _Get Container Name Prefix Internal Use
    set suite variable   ${_G_CONTAINER_PREFIX}

Get Values from OE
    [Arguments]     ${gnb_index}=0    ${vdu_index}=0     ${login_account}=cranuser1
    [Teardown]    helm.helm_master_close
    run keyword if     "${login_account}"=="core"   vDU Cluster Login With Admin    ${vdu_index}
    ...   ELSE   vDU Cluster Login With Tenant    ${vdu_index}  ${gnb_index}
    ${ns}  Get VDU Namespace From TestLine  ${vdu_index}  ${gnb_index}
    ${vdu_values_path}    ${prerequisite_values_path}    ${cluster_values_path}=    Get Values-Override From Target OE
    ...    ${ns}
    [Return]    ${vdu_values_path}    ${prerequisite_values_path}    ${cluster_values_path}


Get Values-Override From Target OE
    [Arguments]    ${namespace}
    [Documentation]    download values-override and return from current VDU/VCU
    ...    *AUTHOR* jinbo.yu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | namespace | no | namespace which VDU/VCU reside in |
    ...	   | ne_type | no | should be VDU or VCU |
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | vdu_values-override_path | prerequisite_values-override_path | cluster_values-override_path |
    ...    | ... | Get Values-Override From Target OE | cran1 |
    ...

    ${cnf_release}=   helm.execute_command_on_master_cluster
    ...    helm list -n ${namespace} | grep -v cluster | grep -v prerequisite | grep -v NAME | awk '{print $1}'
    ${cnf_release_name}=    Strip String    ${cnf_release.stdout}
    ${cnf_cluster_release}=   helm.execute_command_on_master_cluster    helm list -n ${namespace} | grep cluster-preparation | awk '{print $1}'
    ${cnf_cluster_release_name}=    Strip String    ${cnf_cluster_release.stdout}
    ${cnf_prerequisite}=   helm.execute_command_on_master_cluster    helm list -n ${namespace} | grep prerequisite | awk '{print $1}'
    ${cnf_prerequisite_name}=    Strip String    ${cnf_prerequisite.stdout}
    helm.execute_command_on_master_cluster
    ...    helm get values ${cnf_release_name} -n ${namespace} > /tmp/${cnf_release_name}_values-overrride.yaml
    helm.execute_command_on_master_cluster
    ...    helm get values ${cnf_cluster_release_name} -n ${namespace} > /tmp/${cnf_cluster_release_name}_values-overrride.yaml
    helm.execute_command_on_master_cluster
    ...    helm get values ${cnf_prerequisite_name} -n ${namespace} > /tmp/${cnf_prerequisite_name}_values-overrride.yaml
    [Return]     /tmp/${cnf_release_name}_values-overrride.yaml    /tmp/${cnf_prerequisite_name}_values-overrride.yaml
    ...    /tmp/${cnf_cluster_release_name}_values-overrride.yaml


Generate And Update Pod Container Name
    [Arguments]  ${vdu_index}=${0}   ${gnb_index}=${0}
    [Documentation]  Generate And Update Pod Container Name
    ...  return lingting.sun@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...       | vdu index | Yes. | the vdu index config on TL |
    ...       | gnb index | Yes. | the gnb index config on TL |
    ...    *RETURN VALUE*
    ...    Example
    ...    |  Generate And Update Pod Container Name   |
    ${pod_list}=   get dictionary keys    ${AIC_VDU_PODS}
    ${container_prefix}=   Get Container Name Prefix   vdu_index=${0}
    FOR  ${pod}  IN  @{pod_list}
       ${container_abbr_list}=   get from dictionary   ${AIC_VDU_PODS}   ${pod}
       ${container_full_name_list}=  _Generate And Update Pod Container Name Private   ${container_abbr_list}
    ...    ${container_prefix}
       set to dictionary    ${AIC_VDU_PODS}    ${pod}=${container_full_name_list}
    END


_Generate And Update Pod Container Name Private
    [Arguments]  ${container_abbr_list}   ${container_prefix}
    ${container_full_name_list}    create list
    FOR  ${container_abbr}  IN  @{container_abbr_list}
      ${container_full_name}    set variable    ${container_prefix}${container_abbr}
      #${container_full_name}    set variable    ${container_prefix}-${container_abbr}
      append to list     ${container_full_name_list}    ${container_full_name}
    END
    [Return]  ${container_full_name_list}

Get Values For ImagePullSecret
    [Arguments]     ${gnb_index}=0    ${vdu_index}=0
    [Teardown]    helm.helm_master_close
    log to console    Get Values For ImagePullSecret
    vDU Cluster Login With Tenant    ${vdu_index}  ${gnb_index}
    ${cnf_release}=   helm.execute_command_on_master_cluster
    ...    helm list -n ${Namespace} | grep -v cluster | grep -v prerequisite | grep -v NAME | awk '{print $1}'
    ${cnf_release_name}=    Strip String    ${cnf_release.stdout}
    ${secrets_output}=    helm.execute_command_on_master_cluster
    ...    kubectl get secrets -n ${Namespace} |grep -i default-docker | awk '{print $1}'
    ${secrets_name}=    Strip String    ${secrets_output.stdout}
    log to console    ${secrets_name}
    [Return]    ${secrets_name}

Change Values For ImagePullSecret
    [Arguments]     ${secrets_name}    ${vdu_values_path}
    log to console    Change Values For ImagePullSecret
    ${command}=    Set Variable    sed -i 's/imagePullSecret:.*/imagePullSecret: ${secrets_name}/g' ${vdu_values_path}
    log to console    ${command}
    ${alias}   Get Unique Id
    Connect To K8s Master With Tenant Interactively  alias=${alias}
    issh.Execute     command=${command}    alias=${alias}
    [Teardown]   Run Keyword And Ignore Error   Disconnect Interactive Connection  alias=${alias}

Get VDU Pod Number
    [Arguments]    ${vdu_index}=0  ${gnb_index}=0
    [Documentation]   Get VDU Pods Number
    ...    *AUTHOR* sophie.jiang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | vdu_index  | No | vdu index, default value is 0  |
    ...    | gnb_index  | No | gnb index, default value is 0  |
    ...
    ...    *RETURN VALUE*
    ...   number of vdu pod
    ${alias}  get unique id
    Connect To K8s Master With Tenant Interactively  alias=${alias}
    ${ns}   Get vDU Namespace From TestLine  ${vdu_index}  ${gnb_index}
    vDU Cluster Login With Tenant  ${vdu_index}
    ${pods_name_list}=  get_vdu_pods_name_list    namespace=${ns}
    ${pod_number}=    get length    ${pods_name_list}
    helm.helm_master_close
    [Return]  ${pod_number}
