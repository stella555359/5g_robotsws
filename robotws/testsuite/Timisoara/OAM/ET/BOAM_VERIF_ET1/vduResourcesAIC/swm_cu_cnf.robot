*** Settings ***
Documentation
...  author: luofei.tu@nokia-sbell.com



#*** Variables ***


*** Keywords ***

======== vCU CNF Deploy Start ========

Check vCU Pods and Containers Status With Tenant
    #[Arguments]    ${gnb_index}=0
    [Documentation]  Check vCU pods and containers status
        ...  author: luofei.tu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    SCF file name
    ...
    ...    Example
    ...    | ${vcu_scf} | Get VCU Scf File From Test Line |
    ...
    ${pods_info}=    vCU Get Pods Full Info
    ${itmes}   get dictionary items  ${pods_info}
    FOR  ${pod}  ${pods_values}  IN  @{itmes}
        Should Be Equal    ${pods_values}[status]   Running
        @{split_ready}=    Split String    ${pods_values}[ready]    /
        Should Be Equal    ${split_ready[0]}     ${split_ready[1]}
    END


_vCU Recommission via REST API
    [Arguments]  ${build_number}
    [Documentation]  _vCU Recommission via REST API
    ...  author: luofei.tu@nokia-sbell.com
    ${scf_file_name_of_current_branch}  Construct vCU Scf File Name  build_number=${build_number}
    ${SCF_PATH}   Get vCU Scf File From Test Line   file_name=${scf_file_name_of_current_branch}
    wait until keyword succeeds   10min  30s  Recommission vCU with new SCF  ${SCF_PATH}  ${scf_file_name_of_current_branch}

Construct VCU Scf File Name
    [Arguments]  ${build_number}=0.250.2526
    [Documentation]  Construct VCU Scf File Name
    ...  author: luofei.tu@nokia-sbell.com
    ${sub_number_list}   set variable   ${build_number.split(".")}
    ${scf_file_name}   set variable   CU_SCF_${sub_number_list[0]}.${sub_number_list[1]}.xml
    [Return]    ${scf_file_name}

Get VCU Scf File From Test Line
    [Arguments]  ${gnb_index}=0  ${file_name}=vCU_SCF_0.250.xml
    [Documentation]  Get VCU Scf File From Test Line
    ...  author: luofei.tu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    SCF file name
    ...
    ...    Example
    ...    | ${vcu_scf} | Get VCU Scf File From Test Line |
    ...
    ${cfg_dir}     set variable    ${tl.gnbs[${gnb_index}].cloud_deployment.default_cfg_dir}
    ${vcu_scf_file_name}   OperatingSystem.Join Path    ${cfg_dir}
       ...   DEP_SCF_FILES/CU_${gnb_index}/${file_name}
    OperatingSystem.File Should Exist   ${vcu_scf_file_name}

    [Return]   ${vcu_scf_file_name}

#Recommission vCU with new SCF
#    [Arguments]   ${NEW_SCF}  ${plan_name}
#    [Documentation]   It will replace xmlns="raml21.xsd" with ${EMPTY}
#    ...    *AUTHOR* luofei.tu@nokia-sbell.com
#    ...
#    ...    | Input Parameters | Man. | Description |
#    ...    | NEW_SCF         | Yes | New SCF file  |
#    ...
#    ...
#    ...   *RETURN VALUE*
#    ...    None
#    ...
#    ...   Example
#    ...   | Recommission vCU with new SCF | NEW_SCF=my_NEW_SCF |
#
#    Check vCU Maximum Plan Number And Delete One If Reach Maximum Number    #########this keyword should be verify
#    CU Full Commssion By Rest    path_of_commission_file=${NEW_SCF}  plan_name=${plan_name}  gnb_index=0


Get Running vCU Build Number Via Admin
    [Arguments]   ${gnb_index}=0
    [Teardown]  run keyword and ignore error  disconnect interactive connection  alias=${alias}
    [Documentation]   Get Running vCU Build Number Via Admin
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   11.9.2021,chris.l.cao@nokia-sbell.com, get vcu build number via vcu admin account
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | gnb_index      | No | gnb_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    get running vCU build number, e.g, 0.250.928
    ...
    ...    Example
    ...    |  ${build_number}  | Get Running vCU Build Number Via Admin  |
    ...
    ${vcu_nf_type}   Get VCU NF Type   gnb_index=${gnb_index}
    Run Keyword If    "${vcu_nf_type}"=="VNF"   Fail  This KW does not support VNF!

    ${platform_name}    Get vCU Platform Name From One Click Config  gnb_index=${gnb_index}

    ${build_number}   run keyword if   "${platform_name}"=="NCS"  _Get Running vCU Build Number Via Admin NCS   gnb_index=${gnb_index}

    [Return]  ${build_number}


_Get Running vCU Build Number Via Admin NCS
    [Arguments]   ${gnb_index}=0
    [Teardown]  run keyword and ignore error  disconnect interactive connection  alias=${alias}
    [Documentation]   Get vCU Running Build Number
    ...    *AUTHOR* luofei.tu@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | gnb_index      | No | gnb_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    get vCU running build number, e.g, 0.250.928
    ...
    ...    Example
    ...    |  ${build_number}  | Get vCU Running Build Number |
    ...
    ${alias}    Connect To CU K8S Master With Admin    gnb_index=${gnb_index}
    ${ns}   Get CU Namespace From Testline  ${gnb_index}

    ${out}  issh.Execute   command=sudo helm3 list -n ${ns}|grep aic-vcu-cnf|grep -v grep|awk '{print $9}'   alias=${alias}
    ${out}  Strip Prompt  ${out}
    ${build_number}  set variable  ${out.split("-")[-1]}
    [Return]  ${build_number}


Get Running vCU Build Number
    #[Arguments]   ${gnb_index}=0
    [Teardown]  run keyword and ignore error  disconnect interactive connection  alias=${alias}
    [Documentation]   Get Running Build Number
    ...    *AUTHOR* luofei.tu@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | gnb_index      | No | gnb_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    get running vCU build number, e.g, 0.250.928
    ...
    ...    Example
    ...    |  ${build_number}  | Get Running vCU Build Number |
    ...
    ${platform_name}    Get vCU Platform Name
    ${build_number}   run keyword if   "${platform_name}"=="NCS" or "${platform_name}"=="OCP"
    ...   _Get vCU Running Build Number NCS

    [Return]  ${build_number}


_Get vCU Running Build Number NCS
    [Arguments]   ${gnb_index}=0
    [Teardown]  run keyword and ignore error  disconnect interactive connection  alias=${alias}
    [Documentation]   Get vCU Running Build Number
    ...    *AUTHOR* luofei.tu@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | gnb_index      | No | gnb_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    get vCU running build number, e.g, 0.250.928
    ...
    ...    Example
    ...    |  ${build_number}  | Get vCU Running Build Number |
    ...
    ${alias}    Connect To CU K8S Master With Tenant    gnb_index=${gnb_index}
    ${ns}  Get CU Namespace From Testline
    ${out}  issh.Execute   command=helm list -n ${ns} |grep aic-vcu-cnf|awk '{print $9}'  check_result=${False}   alias=${alias}
    ${out}  Strip Prompt  ${out}
    ${build_number}  set variable  ${out.split("-")[-1]}
    [Return]  ${build_number}



UnDeploy vCU
    #[Arguments]   ${gnb_index}=0
    [Documentation]    Undeploy VCU, PVC, Intnet
    ...    *AUTHOR* luofei.tu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | UnDeploy VCU For NCS |
    ...

    UnDeploy Default vCU prerequisite
    UnDeploy Default vCU


UnDeploy Default vCU
    #[Arguments]   ${gnb_index}=0
    [Documentation]   UnDeploy Default vCU For NCS
    ...   *AUTHOR* luofei.tu@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...   | UnDeploy Default vCU For NCS |
    ...

    ${vcu_release_name}   Get vCU Release Name
    ${ns}  Get CU Namespace From Testline
    vCU Cluster helm Login With Tenant
    run keyword and ignore error     helm.helm_delete    ${vcu_release_name}  ${ns}
    Wait Until Keyword Succeeds  300   10s    Make Sure VCU Is Deleted
    [Teardown]   helm.helm_master_close

Make Sure VCU Is Deleted
    #[Arguments]     ${gnb_index}=0
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

UnDeploy Default vCU prerequisite
    #[Arguments]    ${gnb_index}=0
    [Documentation]   UnDeploy Default vCU PVC For NCS
    ...   *AUTHOR* luofei.tu@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...   | UnDeploy Default vCU PVC For NCS |
    ...
    ${Prerequisite_release_name}   Get vCU Prerequisite Release Name
    ${ns}  Get CU Namespace From Testline
    vCU Cluster helm Login With Tenant
    run keyword and ignore error     helm.helm_delete    ${Prerequisite_release_name}   ${ns}
    Wait Until Keyword Succeeds  120   2s    Make Sure vCU Prerequisite Is Deleted
#    Wait Until Keyword Succeeds  90   2s    Make Sure vCU PVC Is Deleted From Disk
    [Teardown]    helm.helm_master_close

Make Sure vCU Prerequisite Is Deleted
    #[Arguments]     ${gnb_index}=0
    [Documentation]  Make Sure VCU PVC Is Deleted
    ...    *AUTHOR* luofei.tu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Make Sure VCU Network Is Deleted |
    ...
    ${Prerequisite_release_name}   Get vCU Prerequisite Release Name
    should be true  ${Prerequisite_release_name.__len__()}==0


Make Sure vCU PVC Is Deleted From Disk
    #[Arguments]     ${gnb_index}=0
    [Documentation]  Make Sure VCU PVC Is Deleted
    ...    *AUTHOR* luofei.tu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Make Sure VCU PVC Is Deleted |
    ...

     Make Sure vCU PVC Is As Expected From Disk   expected_number=0

Make Sure vCU PVC Is As Expected From Disk
    [Arguments]   ${expected_number}=1   #${gnb_index}=0
    [Teardown]  Run Keyword And Ignore Error  Disconnect Interactive Connection  alias=${alias}
    [Documentation]  Make Sure VCU PVC Is As Expected From Disk
    ...    *AUTHOR* luofei.tu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Make Sure VCU PVC Is As Expected From Disk |
    ...
    ${alias}    Connect To CU K8S Master With Tenant
    ${out}  issh.Execute   command=ls -l /mnt/dynamic-local-storage/   alias=${alias}
    ${out}  issh.Execute   command=ls -l /mnt/dynamic-local-storage/ |wc -l   alias=${alias}
    ${num}  strip prompt  ${out}
    should be true  ${num}==${expected_number}


Get vCU Network Release Name
    #[Arguments]      ${gnb_index}=0
    [Documentation]   Get vCU Network Release Name
    ...    *AUTHOR* tuluofei.tu@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | gnb_index      | No | gnb_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    vcu network release name, eg, aic-vcu-network
    ...
    ...    Example
    ...    | ${network_release_name} | Get vCU Network Release Name |
    ...
    ${platform_name}    Get vCU Platform Name
    ${release_name}   run keyword if   "${platform_name}"=="NCS"  _Get VCU Network Release Name NCS
    [Return]  ${release_name}


_Get VCU Network Release Name NCS
    #[Arguments]     ${gnb_index}=0
    [Teardown]  Run Keyword And Ignore Error  Disconnect Interactive Connection  alias=${alias}
    [Documentation]   _Get VCU Network Release Name NCS
    ...    *AUTHOR* luofei.tu@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | gnb_index      | No | gnb_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    vCU Network release name
    ...
    ...    Example
    ...    | ${network_release_name} | Get VCU Network Release Name |
    ...
    ${alias}    Connect To CU K8S Master With Tenant
    ${out}  issh.Execute   command=helm3 list |grep aic-vcu-network|grep -v aic-vcu-cnf|grep -v aic-vcu-pvc|awk '{print $1}'   alias=${alias}
    ${network_release_name}  Strip Prompt  ${out}
    [Return]  ${network_release_name}

Get vCU Release Name
    #[Arguments]      ${gnb_index}=0
    [Documentation]   Get vCU Release Name
    ...    *AUTHOR* tuluofei.tu@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | gnb_index      | No | gnb_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    vcu release name, eg, aic-vcu
    ...
    ...    Example
    ...    | ${vcu_release_name} | Get vCU Release Name |
    ...
    ${platform_name}    Get vCU Platform Name
    ${release_name}   run keyword if   "${platform_name}"=="NCS" or "${platform_name}"=="OCP"  _Get vCU Release Name NCS OCP

    [Return]  ${release_name}

_Get vCU Release Name NCS OCP
    #[Arguments]     ${gnb_index}=0
    [Teardown]  Run Keyword And Ignore Error  Disconnect Interactive Connection  alias=${alias}
    [Documentation]   _Get VCU release name NCS OCP
    ...    *AUTHOR* luofei.tu@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | gnb_index      | No | gnb_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    vcu release name, eg, aic-vcu
    ...
    ...    Example
    ...    | ${vcu_release_name} | Get VCU release name NCS |
    ...
    ${alias}    Connect To CU K8S Master With Tenant
    ${ns}  Get CU Namespace From Testline
    ${out}  issh.Execute   command=helm list -n ${ns} |grep aic-vcu-cnf|grep -v aic-vcu-prerequisite|awk '{print $1}'   alias=${alias}
    ${release_name}  Strip Prompt  ${out}
    [Return]  ${release_name}


Get vCU Prerequisite Release Name
    #[Arguments]      ${gnb_index}=0
    [Documentation]   Get vCU Prerequisite Release Name
    ...    *AUTHOR* tuluofei.tu@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | gnb_index      | No | gnb_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    vcu pvc release name, eg, aic-vcu-pvc
    ...
    ...    Example
    ...    | ${pvc_release_name} | Get vCU Prerequisite Release Name |
    ...
    ${platform_name}    Get vCU Platform Name
    ${release_name}   run keyword if   "${platform_name}"=="NCS" or "${platform_name}"=="OCP"
    ...   _Get VCU Prerequisite Name
    [Return]  ${release_name}


_Get VCU Prerequisite Name
    #[Arguments]     ${gnb_index}=0
    [Teardown]  Run Keyword And Ignore Error  Disconnect Interactive Connection  alias=${alias}
    [Documentation]   _Get VCU Prerequisite Name
    ...    *AUTHOR* luofei.tu@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | gnb_index      | No | gnb_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    Prerequisite name
    ...
    ...    Example
    ...    | ${pvc_release_name} | Get VCU Prerequisite Name |
    ...
    ${alias}    Connect To CU K8S Master With Tenant
    ${ns}  Get CU Namespace From Testline
    ${out}  issh.Execute   command=helm list -n ${ns} |grep aic-vcu-prerequisite |grep -v aic-vcu-cnf|awk '{print $1}'   alias=${alias}
    ${prerequisite_name}  Strip Prompt  ${out}
    [Return]  ${prerequisite_name}

Get VCU Tenant Name
    [Arguments]     ${gnb_index}=0
    [Documentation]   Get VCU Tenant Name
    ...    *AUTHOR* luofei.tu@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | gnb_index      | No | gnb_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    tenant_name
    ...
    ...    Example
    ...    | ${pvc_release_name} | Get VCU PVC Release Name |
    ...
    ${tenant_name}  Set Variable   ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.username}
    [Return]   ${tenant_name}

Deploy VCU
    [Arguments]  ${build_number}=0.250.300  ${cnflayout}=basic  ${package_name}=CU_CNF  #${gnb_index}=0
    [Documentation]    Deploy VCU
    ...    *AUTHOR* luofei.tu@nokia-sbell.com
    ${conf_dic}     Get VCU One Click Config Dictionary From TestLine
    ${platform_name}    Get vCU Platform Name
    ${release_name}   run keyword if   "${platform_name}"=="NCS"   Deploy VCU For NCS    build_number=${build_number}
    ...   cnflayout=${cnflayout}   deploymentmode=${conf_dic.["deploymentmode"]}
    ...   ELSE IF    "${platform_name}"=="OCP"   Deploy VCU For OCP    build_number=${build_number}  package_name=${package_name}
    ...   cnflayout=${cnflayout}  deploymentmode=${conf_dic["deploymentmode"]}


Deploy VCU For NCS
    [Arguments]   ${gnb_index}=0  ${build_number}=0.250.300   ${cnflayout}=basic   ${deploymentmode}=SA    ${package_name}=CU_CNF
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
    vCU Cluster helm Login With Tenant
    ${tenant_name}     Get VCU Tenant Name
    ${output}=    helm.execute_command_on_master_cluster    test -d /home/${tenant_name}/${build_number}
    run keyword if    '${output.status}'=='1'    _Clean Old Releases And Download New vCU Package  ${build_number}
    ...    tenant_name=${tenant_name}  package_name=${package_name}
    ...    ELSE   log    "vCU package already present at cluster"
    Upload vCU Image To Repository For NCS   tenant_name=${tenant_name}    gnb_index=0  image_check=False   build_number=${build_number}
    ${pvc_yaml_file}      Get vCU PVC Vnf Config Yaml From TestLine   gnb_index=${gnb_index}
    ${vcu_yaml_file}    Get vCU Vnf Config Yaml From TestLine  gnb_index=${gnb_index}
    run keyword if   "${cnflayout}" == "basic"    yaml_modify_content    file_path=${vcu_yaml_file}
    ...   key=global  modify_content=basic  child_key=cnfLayout
    ...    ELSE   yaml_modify_content    file_path=${vcu_yaml_file}
    ...   key=global  modify_content=redundant  child_key=cnfLayout
    run keyword if   "${deploymentmode}" == "SA"    yaml_modify_content    file_path=${vcu_yaml_file}
    ...   key=global  modify_content=SA  child_key=deploymentmode
    ...    ELSE   yaml_modify_content    file_path=${vcu_yaml_file}
    ...   key=global  modify_content=NSA  child_key=deploymentmode
    ${vcu_release_name}   Get VCU Release Name From Testline  gnb_index=${gnb_index}
    ${Prerequisite_release_name}  Get VCU Prerequisite Release Name From Testline  gnb_index=${gnb_index}
    ${alias_k8s_tenant}   Connect To CU K8S Master With Tenant
    issh.Upload File  local_path=${pvc_yaml_file}
    ...    remote_path=/home/${tenant_name}/${build_number}/HelmChart/${Prerequisite_release_name}/
    ...    alias=${alias_k8s_tenant}
    issh.Upload File  local_path=${vcu_yaml_file}
    ...    remote_path=/home/${tenant_name}/${build_number}/HelmChart/${Prerequisite_release_name}/
    ...    alias=${alias_k8s_tenant}

    Create vCU PVC and Verify PVC creation
    ...    remote_dst_file=/home/${tenant_name}/${build_number}/HelmChart/${Prerequisite_release_name}/aic_pvc_values_override_0.yaml
    ...    remote_dst_path=/home/${tenant_name}/${build_number}/HelmChart/${Prerequisite_release_name}
    Create vCU cnf and Verify
    ...    remote_dst_file=/home/${tenant_name}/${build_number}/HelmChart/${vcu_release_name}/aic_vcu_values_override_0.yaml
    ...    remote_dst_path=/home/${tenant_name}/${build_number}/HelmChart/${vcu_release_name}


Deploy VCU For OCP
    [Arguments]   ${gnb_index}=0  ${build_number}=0.250.300   ${cnflayout}=basic  ${deploymentmode}=SA    ${package_name}=CU_CNF
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
    vCU Cluster helm Login With Tenant
    ${tenant_name}     Get VCU Tenant Name
    ${output}=    helm.execute_command_on_master_cluster    test -d /var/home/${tenant_name}/${build_number}
    run keyword if    '${output.status}'=='1'    _Clean Old Releases And Download New vCU Package  ${build_number}
    ...    tenant_name=${tenant_name}  package_name=${package_name}
    ...    ELSE   log    "vCU package already present at cluster"
    Upload vCU Image To Repository For OCP   tenant_name=${tenant_name}    gnb_index=0  image_check=False   build_number=${build_number}
    ${pvc_yaml_file}      Get vCU PVC Vnf Config Yaml From TestLine   gnb_index=${gnb_index}
    ${vcu_yaml_file}    Get vCU Vnf Config Yaml From TestLine  gnb_index=${gnb_index}
    run keyword if   "${cnflayout}" == "basic"    yaml_modify_content    file_path=${vcu_yaml_file}
    ...   key=global  modify_content=basic  child_key=cnfLayout
    ...    ELSE   yaml_modify_content    file_path=${vcu_yaml_file}
    ...   key=global  modify_content=redundant  child_key=cnfLayout
#    ${vcu_yaml_file}    Get vCU Vnf Config Yaml From TestLine  gnb_index=0
    run keyword if   "${deploymentmode}" == "SA"    yaml_modify_content    file_path=${vcu_yaml_file}
    ...   key=global  modify_content=SA  child_key=deploymentmode
    ...    ELSE   yaml_modify_content    file_path=${vcu_yaml_file}
    ...   key=global  modify_content=NSA  child_key=deploymentmode
    ${vcu_value_yaml_file}  Get vCU value Vnf Config Yaml From TestLine  gnb_index=${gnb_index}
    ${vcu_release_name}   Get VCU Release Name From Testline  gnb_index=${gnb_index}
    ${Prerequisite_release_name}  Get VCU Prerequisite Release Name From Testline  gnb_index=${gnb_index}
    ${alias_k8s_tenant}   Connect To CU K8S Master With Tenant
    issh.Upload File  local_path=${pvc_yaml_file}
    ...    remote_path=/var/home/${tenant_name}/${build_number}/HelmChart/${Prerequisite_release_name}/
    ...    alias=${alias_k8s_tenant}
    issh.Upload File  local_path=${vcu_yaml_file}
    ...    remote_path=/var/home/${tenant_name}/${build_number}/HelmChart/${vcu_release_name}/
    ...    alias=${alias_k8s_tenant}
    issh.Upload File  local_path=${vcu_value_yaml_file}
    ...    remote_path=/var/home/${tenant_name}/${build_number}/HelmChart/${vcu_release_name}/
    ...    alias=${alias_k8s_tenant}

    Create vCU PVC and Verify PVC creation
    ...    remote_dst_file=/var/home/${tenant_name}/${build_number}/HelmChart/${Prerequisite_release_name}/aic_pvc_values_override_0.yaml
    ...    remote_dst_path=/var/home/${tenant_name}/${build_number}/HelmChart/${Prerequisite_release_name}
    Create vCU cnf and Verify
    ...    remote_dst_file=/var/home/${tenant_name}/${build_number}/HelmChart/${vcu_release_name}/aic_vcu_values_override_0.yaml
    ...    remote_dst_path=/var/home/${tenant_name}/${build_number}/HelmChart/${vcu_release_name}


_Clean Old Releases And Download New vCU Package
    [Arguments]   ${build_number}  ${tenant_name}  ${package_name}=CU_CNF
    [Documentation]  _Clean Old Releases And Download New vCU Package
    ...  author: luofei.tu@nokia-sbell.com
    helm.execute_command_on_master_cluster    cd /var/home/${tenant_name};rm -rf 0.250.*
    helm.execute_command_on_master_cluster    mkdir ${build_number}
    helm.helm_download_cnf_package    /var/home/${tenant_name}/${build_number}  ${package_name}  ${build_number}
    helm.execute_command_on_master_cluster
    ...    cd /var/home/${tenant_name}/${build_number}/HelmChart;tar -zxvf aic-vcu-${build_number}.tgz
    helm.execute_command_on_master_cluster
    ...    cd /var/home/${tenant_name}/${build_number}/HelmChart;tar -zxvf aic-vcu-prerequisite-${build_number}.tgz


Upload vCU Image To Repository For NCS
    [Arguments]  ${tenant_name}  ${gnb_index}=0  ${image_check}=False  ${build_number}=0.250.903
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

    run keyword if  ${image_check}==False  Upload vCU Image NCS  tenant_name=${tenant_name}  gnb_index=${gnb_index}  build_number=${build_number}
    run keyword if  ${image_check}==True  log  images already exist  console=true

Upload vCU Image NCS
    [Arguments]  ${tenant_name}    ${build_number}=0.250.903    #${gnb_index}=0
    [Documentation]    Upload vCU Image
    ...    *AUTHOR* luofei.tu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Upload Image | build_number=0.250.800|

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
    [Arguments]  ${tenant_name}  ${gnb_index}=0  ${image_check}=False  ${build_number}=0.250.903
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

    run keyword if  ${image_check}==False  Upload vCU Image OCP  tenant_name=${tenant_name}  gnb_index=${gnb_index}  build_number=${build_number}
    run keyword if  ${image_check}==True  log  images already exist  console=true

Upload vCU Image OCP
    [Arguments]  ${tenant_name}  ${build_number}=0.250.903    #${gnb_index}=0
    [Documentation]    Upload vCU Image
    ...    *AUTHOR* luofei.tu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Upload Image | build_number=0.250.800|

    vCU Cluster helm Login With Tenant
    helm.download_onboard_app_tool    target_path=/home/${tenant_name}/${build_number}/Image    chart_version=${build_number}
    helm.execute_command_on_master_cluster
    ...    cp /home/${tenant_name}/${build_number}/Image/onBoardingApp/loadImages.sh /home/${tenant_name}/${build_number}/Image/
    helm.execute_command_on_master_cluster
    ...    cp /home/${tenant_name}/${build_number}/Image/onBoardingApp/images.properties.OCP /home/${tenant_name}/${build_number}/Image/
    helm.execute_command_on_master_cluster    cd /home/${tenant_name}/${build_number}/Image;chmod 777 *;./loadImages.sh
    log    upload images done    console=true
    [Teardown]    helm.helm_master_close



Get VCU One Click Config Yaml From TestLine
    [Arguments]  ${gnb_index}=0
    [Documentation]  Get VCU One Click Config Yaml From TestLine
    ...  author: chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...   Yaml file of VCU One Click Config defined in cnf_parameters.yaml
    ...
    ...    Example
    ...    | ${yaml_file}     | Get vDU One Click Config Yaml From TestLine  |
    ...
    #${cfg_dir}     set variable    ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.default_cfg_dir}
    ${cfg_dir}     set variable    ${tl.gnbs[${gnb_index}].cloud_deployment.default_cfg_dir}
    ${yaml_file_name}   OperatingSystem.Join Path    ${cfg_dir}
       ...   DEP_SCF_FILES/CU_${gnb_index}/cnf_parameters.yaml

    [Return]   ${yaml_file_name}


Get VCU One Click Config Dictionary From TestLine
    [Arguments]  ${gnb_index}=0
    [Documentation]   Get VCU One Click Config Dictionary From TestLine
    ...  author: chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...   Dictionary of cnf_parameters.yaml . If there is no this file, return {}
    ...
    ...    Example
    ...    | ${conf_dict}     | Get VCU One Click Config Dictionary From TestLine |
    ...
    ${empty_dict}   create dictionary
    ${yaml_file}   Get VCU One Click Config Yaml From TestLine  gnb_index=${gnb_index}
    ${r}   ${dummy}  run keyword and ignore error  OperatingSystem.File Should Exist   ${yaml_file}
    return from keyword if  "${r}"=="FAIL"   ${empty_dict}

    ${dictionary_content}   yaml_file_to_dictionary   ${yaml_file}
    [Return]   ${dictionary_content}


Get vCU PVC Vnf Config Yaml From TestLine
    [Arguments]  ${gnb_index}=0
    [Documentation]  Get vCU Network Vnf Config Yaml From TestLine
    ...  author: luofei.tu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...   Yaml file of vCU PVC Vnf Config defined in __init__.py
    ...
    ...    Example
    ...    | ${yaml_file}     | Get vCU PVC Vnf Config Yaml From TestLine  |
    ...
    ${cfg_dir}     set variable    ${tl.gnbs[${gnb_index}].cloud_deployment.default_cfg_dir}
    ${yaml_file_name}   OperatingSystem.Join Path    ${cfg_dir}
       ...   DEP_SCF_FILES/CU_${gnb_index}/aic_pvc_values_override_0.yaml

    [Return]   ${yaml_file_name}

Get vCU value Vnf Config Yaml From TestLine
    [Arguments]  ${gnb_index}=0
    [Documentation]  Get vCU value Vnf Config Yaml From TestLine
    ...  author: luofei.tu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...   Yaml file of vCU PVC Vnf Config defined in __init__.py
    ...
    ...    Example
    ...    | ${yaml_file}     | Get vCU value Vnf Config Yaml From TestLine  |
    ...
    ${cfg_dir}     set variable    ${tl.gnbs[${gnb_index}].cloud_deployment.default_cfg_dir}
    ${yaml_file_name}   OperatingSystem.Join Path    ${cfg_dir}
       ...   DEP_SCF_FILES/CU_${gnb_index}/values.yaml

    [Return]   ${yaml_file_name}

Get vCU PVC Vnf Config Dictionary From TestLine
    [Arguments]  ${gnb_index}=0
    [Documentation]  Get vCU PVC Vnf Config Dictionary From TestLine
    ...  author: luofei.tu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...   Dictionary of vCU PVC Vnf Config defined in __init__.py
    ...
    ...    Example
    ...    | ${conf_dict}     | Get vCU PVC Vnf Config Dictionary From TestLine   |
    ...
    ${yaml_file}      Get vCU PVC Vnf Config Yaml From TestLine   gnb_index=${gnb_index}
    ${dictionary_content}   yaml_file_to_dictionary   ${yaml_file}
    [Return]   ${dictionary_content}

Get vCU Network Vnf Config Yaml From TestLine
    [Arguments]  ${gnb_index}=0
    [Documentation]  Get vCU Network Vnf Config Yaml From TestLine
    ...  author: luofei.tu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...   Yaml file of vCU Network Vnf Config defined in __init__.py
    ...
    ...    Example
    ...    | ${yaml_file}     | Get vCU Network Vnf Config Yaml From TestLine  |
    ...
    ${yaml_file_name}    set variable  ${tl.gnbs[${gnb_index}].cloud_deployment.networks[0].yaml_file}
    [Return]   ${yaml_file_name}


Get vCU Network Vnf Config Dictionary From TestLine
    [Arguments]  ${gnb_index}=0
    [Documentation]  Get vCU Network Vnf Config Dictionary From TestLine
    ...  author: luofei.tu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...   Dictionary of vCU Vnf Config defined in __init__.py
    ...
    ...    Example
    ...    | ${conf_dict}     | Get vCU Network Vnf Config Dictionary From TestLine   |
    ...
    ${yaml_file}      Get vCU Network Vnf Config Yaml From TestLine   gnb_index=${gnb_index}
    ${dictionary_content}   yaml_file_to_dictionary   ${yaml_file}
    [Return]   ${dictionary_content}

Get vCU Vnf Config Yaml From TestLine
    [Arguments]  ${gnb_index}=0
    [Documentation]  Get vCU Vnf Config Yaml From TestLine
    ...  author: luofei.tu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...   Yaml file of vCU Vnf Config defined in __init__.py
    ...
    ...    Example
    ...    | ${yaml_file}     | Get vCU Vnf Config Yaml From TestLine  |
    ...
    ${yaml_file_name}    set variable  ${tl.gnbs[${gnb_index}].cloud_deployment.vnfs[0].yaml_file}
    [Return]   ${yaml_file_name}


Get vCU Vnf Config Dictionary From TestLine
    [Arguments]  ${gnb_index}=0
    [Documentation]  Get vCU Vnf Config Dictionary From TestLine
    ...  author: luofei.tu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...   Dictionary of vCU Vnf Config defined in __init__.py
    ...
    ...    Example
    ...    | ${conf_dict}     | Get vCU Vnf Config Dictionary From TestLine   |
    ...
    ${yaml_file}      Get vCU Vnf Config Yaml From TestLine   gnb_index=${gnb_index}
    ${dictionary_content}   yaml_file_to_dictionary   ${yaml_file}
    [Return]   ${dictionary_content}


Get vCU Vnf Values Config Yaml From TestLine
    [Arguments]  ${gnb_index}=0
    [Documentation]   Get vCU Vnf Values Config Yaml From TestLine
    ...  author: luofei.tu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...   Yaml file of vCU values.yaml
    ...
    ...    Example
    ...    | ${yaml_file}     | Get vCU Vnf Values Config Yaml From TestLine  |
    ...
    ${yaml_file_name}    set variable  ${tl.gnbs[${gnb_index}].cloud_deployment.vnfs[0].yaml_file}
    ${conf_path}   ${dummy}   OperatingSystem.Split Path   ${yaml_file_name}
    ${yaml_file_name_DEBUG}   OperatingSystem.Join Path    ${conf_path}   aic_vcu_values_0.yaml
    [Return]   ${yaml_file_name_DEBUG}

Create vCU network and Verify network creation
    [Arguments]   ${gnb_index}=0  ${remote_dst_file}=values-override.yaml
    ...    ${remote_dst_path}=/home/cranuserxxx/aic-vcu-network
    [Documentation]    Create network and Verify network creation
    ...    *AUTHOR* luofei.tu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...	   | remote_dst_file | Yes | remote_dst_file on OE |
    ...	   | remote_dst_path | Yes | remote_dst_path on OE |
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Create network and Verify network creation | remote_dst_file=values-override.yaml | remote_dst_path=home/cranuserxxx/aic-vcu-network |
    ...
    ${network_release_name}  Get VCU Network Release Name From Testline  ${gnb_index}
    vCU Cluster helm Login With Tenant
    ${ns}    Get CU Namespace From Testline
    helm.helm3_install
    ...  ${network_release_name}
    ...  ${remote_dst_path}
    ...  ${ns}
    ...  value_files=${remote_dst_file}
    log    Deloy network done    console=true
    [Teardown]    helm.helm_master_close

Create vCU PVC and Verify PVC creation
    [Arguments]  ${remote_dst_file}=values-override.yaml    #${gnb_index}=0
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
    [Arguments]   ${remote_dst_file}=values-override.yaml   #${gnb_index}=0
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


vCU Get Pods Full Info
    [Arguments]    ${pod_name}=all   #${gnb_index}=0
    [Documentation]  get pods full infomation
    ...  author: luofei.tu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | pod_name | No. | the pods name that containers belong to, default value is all pods |
    ...    | namespace | No. | the namespace that the pod belongs to, if not given, using the tenant namespace |
    ...    *RETURN VALUE*
    ...    pods info dict
    vCU Cluster helm Login With Tenant
    ${ns}    Get CU Namespace From Testline
    ${pods_info}=    get_vdu_pods_info    ${pod_name}    namespace=${ns} # just use get_vdu_pods_info to get vCU pods info
    Set Test Variable    ${Pods_Info}    ${pods_info}
    [Return]  ${Pods_Info}
    [Teardown]    helm.helm_master_close

Get VCU Release Name From Testline
    [Arguments]    ${gnb_index}=0
    [Documentation]   Get VCU Release Name From Testline
    ...    *AUTHOR* luofei.tu@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    VCU Release Name From Testline
    ...
    ...    Example
    ...    | ${vcu_release_name} | Get VCU Release Name From Testline |
    ...
    ${release_name}   set variable  ${tl.gnbs[${gnb_index}].cloud_deployment.vnfs[0].name}
    [Return]  ${release_name}


Get VCU Prerequisite Release Name From Testline
    #[Arguments]    ${gnb_index}=0
    [Documentation]   Get VCU PVC Release Name From Testline
    ...    *AUTHOR* luofei.tu@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    VCU PVC Release Name From Testline
    ...
    ...    Example
    ...    | ${vcu_pvc_release_name} | Get VCU PVC Release Name From Testline |
    ...
    ${vcu_prerequisite_release_name}   set variable  aic-vcu-prerequisite
    [Return]  ${vcu_prerequisite_release_name}


Get VCU Network Release Name From Testline
    [Arguments]    ${gnb_index}=0
    [Documentation]   Get VCU Network Release Name From Testline
    ...    *AUTHOR* luofei.tu@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    VCU Network Release Name From Testline
    ...
    ...    Example
    ...    | ${vcu_release_name} | Get VCU Network Release Name From Testline |
    ...
    ${release_name}   set variable  ${tl.gnbs[${gnb_index}].cloud_deployment.networks[0].name}
    [Return]  ${release_name}

Get vCU Platform Name
    [Documentation]   This keywork only support aic product, Get vCU Platform Name
    ...   *AUTHOR* luofei.tu@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...
    ...   *RETURN VALUE*
    ...    OSP or NCIR or NCS or OCP
    ...
    ...   Example
    ...   | ${platform} | Get vCU Platform Name|
    ...
    ${tl_cloud_topology}   set variable  ${tl.tl_cloud_topology}
    should be true  ${tl_cloud_topology.startswith("CLOUD_5G_AIC")}
    ${vcu_platform}   set variable  ${tl_cloud_topology.split("_")[3]}
    [Return]  ${vcu_platform}


Get vCU Platform Name From One Click Config
    [Arguments]  ${gnb_index}=0
    [Documentation]   Get vCU Platform Name From One Click Config
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   22.9.2021,chris.l.cao@nokia-sbell.com, initialization
    ...
    ...   | Input Parameters    | Man. | Description |
    ...    | gnb_index     |  No | gnb_index, default value is 0 |
    ...
    ...   *RETURN VALUE*
    ...    NCS or OCP, otherwise KW fails.
    ...
    ...   Example
    ...   | ${platform} | Get vCU Platform Name From One Click Config |
    ...
    ${conf}   Get VCU One Click Config Dictionary From TestLine  gnb_index=${gnb_index}
    ${platform}   set variable if  "OCP" in "${conf["misc"]["platform_type"]}"    OCP
     ...   "NCS" in "${conf["misc"]["platform_type"]}"   NCS    UNKNOWN_PLATFORM

    Run Keyword If   "${platform}"=="UNKNOWN_PLATFORM"
         ...   Fail   VCU platform name should be OCP or NCS, they are defined in one click config file.

    [Return]  ${platform}

CU OCP OC Login Auth
    #[Arguments]   ${gnb_index}=0
    _CU OC Login Auth With OCP Admin
    _CU OC Login Auth With OCP Tenant

_CU OC Login Auth With OCP Admin
    #[Arguments]   ${gnb_index}=0
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
    ${alias}    Connect To CU K8S Master With Admin
    ${out}  issh.Execute   command=oc login -u nokiaadmin -p nokiaadmin --insecure-skip-tls-verify=true
    ...   alias=${alias}
    [Teardown]   issh.disconnect   alias=${alias}

_CU OC Login Auth With OCP Tenant
    #[Arguments]   ${gnb_index}=0
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
    ${out}  issh.Execute   command=oc login -u nokiaadmin -p nokiaadmin --insecure-skip-tls-verify=true
    ...   alias=${alias}
    [Teardown]   issh.disconnect   alias=${alias}

======= vCU CNF Deploy End =======
