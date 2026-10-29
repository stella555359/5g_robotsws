*** Settings ***
Documentation
...     19.03.2025 -- RF5.0 & :FOR
Library     OperatingSystem
Library     Collections
Library     String
Library     XML
Library     taf.ul.vdu.helm                      WITH NAME    helm
Library     taf.transport.ssh.interface.ssh      WITH NAME    ssh
Library     taf.pdu                              WITH NAME    pdu
Library     taf.gnb.oam.coam.vdu.interface.Vdu   WITH NAME    vdu
Library     taf.gnb.oam.coam.cu                WITH NAME    coam_cu
#Library           taf.ul.vdu.helm                       WITH NAME    helm
#Library           OperatingSystem
Library           Process
Library           SeleniumLibrary
Library           taf.transport.ssh                     WITH NAME    tafssh

*** Variables ***
${LOG_PATH}    ${OUTPUT DIR}${/}Logs


*** Keywords ***
Case Precondition
    log to console  \n Case Precondition deploy vCU and onair
    vCU Cluster Login With Admin
    ${workspace}    Create Workspace
    set test variable   ${workspace}
    ${new_kuafu_dir}    vCU Get Kuafu   workspace_dir=${workspace}  kuafu_version=master   config_file=${NEW_KUAFU_FILE}
    set test variable   ${new_kuafu_dir}
    VCU Undeployment By Kuafu   ${new_kuafu_dir}
    Prepare New Version
    Install Old Version
    vDU SSH Login
    ${vdu_kuafu_dir}    Get Kuafu
    set test variable   ${vdu_kuafu_dir}
    wait until keyword succeeds   10min   1min  Check RF Power By Kuafu   ${vdu_kuafu_dir}
    [Teardown]    helm.helm_master_close

Case Postcondition
    log to console  Case Postcondition
    vCU Cluster Login With Admin
    tafssh.Execute    command=cd /home/${G_USER}/; rm -rf TA_Workspace
    vDU SSH Login
    tafssh.Execute    command=cd /home/${G_USER}/; rm -rf TA_Workspace
    [Teardown]    helm.helm_master_close

vCU Cluster Login With Admin
    [Arguments]  ${gnb_index}=0
    ${conn}=  helm.helm_master_connect
    ...  ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.ip_addr}
    ...  ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.port}
    ...  ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.username}
    ...  ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.password}
    [Return]   ${conn}

vCU Get Kuafu
    [Arguments]     ${workspace_dir}    ${kuafu_version}=master    ${config_file}=kuafu_vcu_config.ini   ${gnb_index}=0
    log to console  \n Downloading Kuafu...
    run keyword if  """${kuafu_version}"""=="""master"""    Download Kuafu Master   ${workspace_dir}    ELSE
    ...     Download Kuafu Specified Verision   ${workspace_dir}    ${kuafu_version}
    ${kuafu}    tafssh.Execute  command=cd ${workspace_dir}/kuafu-${kuafu_version};ls
    should contain  ${kuafu}    20-vcu-l3call-test.sh
    ${kuafu_dir}   Set Variable   ${workspace_dir}/kuafu-${kuafu_version}
    log to console  \n Kuafu Download Success
    ${return}   tafssh.Execute  command=cd ${kuafu_dir};. ./20-vcu-l3call-test.sh
    should contain  ${return}   10-config-vcu-deploy.sh
    tafssh.Send Command  command=cd ${kuafu_dir}/scenarios/vcu_l3call;./10-config-vcu-deploy.sh
    ${return}   tafssh.Send Command  command=ZZ
    ${remote_file_version}  tafssh.Execute  command=cat ${kuafu_dir}/artifacts/vcu_config.ini | grep -w version
    ${kuafu_config_file}   OperatingSystem.Join Path    ${tl.gnbs[${gnb_index}].cloud_deployment.default_cfg_dir}
    ...     ${config_file}
    tafssh.Upload file   local_path=${kuafu_config_file}    remote_path=${kuafu_dir}/artifacts/vcu_config.ini
    ${local_file_version}   tafssh.Execute  command=cat ${kuafu_dir}/artifacts/vcu_config.ini | grep -w version
    should be equal     ${remote_file_version}      ${local_file_version}
    log to console  \n vcu_config.ini Replace Complete
    [Return]    ${kuafu_dir}

Download Kuafu Master
    [Arguments]     ${workspace_dir}
    tafssh.Execute  command=cd ${workspace_dir};git clone https://gitlabe2.ext.net.nokia.com/kuafu/kuafu.git
    tafssh.Execute  command=cd ${workspace_dir};mv kuafu kuafu-master

Download Kuafu Specified Verision
    [Arguments]    ${workspace_dir}     ${version}
    tafssh.Execute
    ...     cd ${workspace_dir};wget https://gitlabe2.ext.net.nokia.com/kuafu/kuafu/-/archive/${version}/kuafu-${version}.tar.gz
    tafssh.Execute  command=cd ${workspace_dir};tar -xzf kuafu-${version}.tar.gz
    tafssh.Execute  command=cd ${workspace_dir};rm kuafu-${version}.tar.gz

VCU Undeployment By Kuafu
    [Arguments]     ${kuafu_dir}    ${gnb_index}=0
    log to console     \n ***----Starting undeploy vCU by kuafu...
    ${ns}  Get vCU Namespace From TestLine  ${gnb_index}
    ${current_chart_name}=     tafssh.Execute    command=helm list -n ${ns} |grep 'aic-vcu-cnf'|awk '{print $1}'|tr -d '\r\n'
    Change Value In Kuafu vCU Config File   ${kuafu_dir}    value_name=chart_name     new_value=${current_chart_name}
    log to console  \n chart_name Replace Complete
    ${return}   tafssh.Execute  command=cd ${kuafu_dir};. ./20-vcu-l3call-test.sh
    should contain  ${return}   20-delete-vcu-and-pvc.sh
    ${return}   tafssh.Execute  command=cd ${kuafu_dir}/scenarios/vcu_l3call;./20-delete-vcu-and-pvc.sh
    should contain  ${return}   [INFO] vCU deletion successful
    ${return}   tafssh.Execute  command=helm list -n ${ns}
    should not contain  ${return}   deployed
    log to console  \n [INFO] vCU deletion successful

VCU Onboard By Kuafu
    [Arguments]     ${kuafu_dir}    ${build_version}
	log to console     \n ***----Starting onboard vCU by kuafu...
    Change Value In Kuafu vCU Config File   ${kuafu_dir}    value_name=build_version     new_value=${build_version}
    ${return}   tafssh.Execute  command=cd ${kuafu_dir};. ./20-vcu-l3call-test.sh
    should contain  ${return}   16-onboard-vcu.sh
    ${return}    tafssh.Execute  command=cd ${kuafu_dir}/scenarios/vcu_l3call;./16-onboard-vcu.sh
    should not contain  ${return}   build is not supported

VCU deployment By Kuafu
    [Arguments]     ${kuafu_dir}    ${chart_name}=${G_VCU_NAME}
    log to console     \n ***----Starting deploy vCU by kuafu...
    Change Value In Kuafu vCU Config File   ${kuafu_dir}    value_name=chart_name     new_value=${chart_name}
    Deployment type for vCU    ${kuafu_dir}   ${CNF_LAYOUT}   ${CPUE_COUNT}   ${UPUE_COUNT}   ${MIN_CPUE}   ${MIN_UPUE}
    ${return}   tafssh.Execute  command=cd ${kuafu_dir};. ./20-vcu-l3call-test.sh
    should contain  ${return}   21-create-vcu.sh
    ${return}   tafssh.Execute  command=cd ${kuafu_dir}/scenarios/vcu_l3call;./21-create-vcu.sh
    should contain  ${return}   [INFO] vCU creation successful
    log to console  \n [INFO] vCU creation successful

Deployment type for vCU
    [Arguments]     ${kuafu_dir}   ${cnf_layout}  ${cpue_count}   ${upue_count}   ${min_capacity_cpue}   ${min_capacity_upue}
    log to console    \n     Set vCU deployment type
    Change Value In Kuafu vCU Config File   ${kuafu_dir}    value_name=cnf_layout       new_value=${cnf_layout}
    Change Value In Kuafu vCU Config File   ${kuafu_dir}    value_name=cpue_count       new_value=${cpue_count}
    Change Value In Kuafu vCU Config File   ${kuafu_dir}    value_name=upue_count       new_value=${upue_count}
    Change Value In Kuafu vCU Config File   ${kuafu_dir}    value_name=min_capacity_cpue       new_value=${min_capacity_cpue}
    Change Value In Kuafu vCU Config File   ${kuafu_dir}    value_name=min_capacity_upue       new_value=${min_capacity_upue}

VCU Load And Active SCF By Kuafu
    [Arguments]     ${kuafu_dir}    ${scf_file}     ${gnb_index}=0
    log to console     \n ***----Starting load and active scf by kuafu...
    ${local_scf_file}   OperatingSystem.Join Path    ${tl.gnbs[${gnb_index}].cloud_deployment.default_cfg_dir}
    ...     ${scf_file}
    tafssh.Upload file   local_path=${local_scf_file}   remote_path=${kuafu_dir}/scf/vcu/${scf_file}
    Change Value In Kuafu vCU Config File   ${kuafu_dir}    value_name=scf_file_name   new_value=${scf_file}
    log to console  \n SCF Add To Kuafu Complete
    ${return}   tafssh.Execute  command=cd ${kuafu_dir};. ./20-vcu-l3call-test.sh
    should contain  ${return}   42-auto-load-SCF-and-activate.sh
    ${return}   tafssh.Execute  command=cd ${kuafu_dir}/scenarios/vcu_l3call;./42-auto-load-SCF-and-activate.sh
    should contain  ${return}   [INFO] Activate SCF file successfully
    log to console  \n [INFO] Activate SCF file successfully

Change Value In Kuafu vCU Config File
    [Arguments]     ${kuafu_dir}    ${value_name}    ${new_value}
    ${current_value}    tafssh.Execute
    ...     cat ${kuafu_dir}/artifacts/vcu_config.ini | grep -w ${value_name} | grep -v '#' | tr -d '\r\n'
    tafssh.Execute  command=sed -i 's/${current_value}/${value_name}=${new_value}/g' ${kuafu_dir}/artifacts/vcu_config.ini

VCU Undeployment
    [Arguments]  ${gnb_index}=0
    [Documentation]    VCU Undeployment
    ...    *AUTHOR* miao.a.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    None
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...   | VCU Undeployment |
    log to console     \n ***----Starting undeploy vCU...
    ${ns}  Get vCU Namespace From TestLine  ${gnb_index}
    ${vcu_release_name}=     tafssh.Execute
    ...    command=helm list -n ${ns} |grep 'aic-vcu-cnf-0.250'|awk '{print $1}'|tr -d '\r\n'
    ${vcu_pre_name}=     tafssh.Execute
    ...    command=helm list -n ${ns} |grep 'aic-vcu-prerequisite'|awk '{print $1}'|tr -d '\r\n'
    run keyword and ignore error   tafssh.Execute   command=helm uninstall ${vcu_release_name} -n ${ns}
    Wait Until Keyword Succeeds     10x  15s     Check vCU pod empty   ${ns}
    Log To Console     \n UnDeploy CNF done.
    run keyword and ignore error   tafssh.Execute   command=helm uninstall ${vcu_pre_name} -n ${ns}
    Sleep    30s

Get vCU Namespace From TestLine
    [Arguments]  ${gnb_index}=0
    [Documentation]  get vdu namespace from testline init config file
    ...  return the value correct get from TL
    ...  author: miao.a.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | vdu index | Yes. | the vdu index config on TL |
    ...    *RETURN VALUE*
    ...    namespace
    ${vcu_namespace}=   set variable
    ...   ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.namespace}
    [Return]   ${vcu_namespace}

VCU Deployment And Check Pods Status
    [Arguments]   ${vCU_VERSION}   #${ADD_OAMFH_FLAG}=no  ${Image_Tag}=no
    [Documentation]    VDU Deployment And Check Pods Status
    ...    *AUTHOR* miao.a.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | vDU_VERSION     | yes | vDU_VERSION, e.g, 0.250.1285 |
    ...    | Image_Tag    | no | default is none |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...   | VDU Deployment And Check Pods Status | vDU_VERSION=0.390.1671 |
    log to console     \n ***----Starting deploy vCU via OCP
    vCU Docker Images Uploading    ${vCU_VERSION}    ${workspace_dir}
    Upload Yaml File And Install VCU    ${workspace_dir}   ${vCU_VERSION}
    Wait Until Keyword Succeeds    1min  10s    check healing controller status

Create Workspace
    [Arguments]     ${gnb_index}=0
    [Documentation]  create local directory in vCU cluster to store the onBoardingApp and chart
    ...  the directory is consisted of testline > timestamp
    ...  author: miao.a.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...    /tmp/TA_Workspace
    ...
    ...    Example
    ...   | Create Local Chart Directory In vDU Eituser |
    ${USER}=    set variable        ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.username}
    ${CRANUSER}=   set variable     ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.namespace}
    Set Test Variable    ${workspace_dir}    /home/${USER}/TA_Workspace-${CRANUSER}
#    Set Test Variable    ${workspace_dir}    /tmp/TA_Workspace
    tafssh.Execute    command=rm -rf ${workspace_dir}
    tafssh.Execute    command=mkdir -p ${workspace_dir}
    [Return]    ${workspace_dir}

vCU Docker Images Uploading
    [Arguments]   ${vcu_version}  ${saving_tool_path}  ${gnb_index}=0
    [Documentation]  Upload packages and images to vdu.
    ...  If you use this kwyworkd, images will be uploaded and all files are here.
    ...  author: miao.a.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | vDU_VERSION     | yes | vDU_VERSION, e.g, 0.250.1285 |
    ...    | saving_tool_path    | yes | saving_tool_path, e.g, /tmp/TA_Workspace |
    ...    | vdu_index     | no | vdu_index, default value is 0 |
    ...    | gnb_index     | no | gnb_index, default value is 0 |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...   | vDU Docker Images Uploading | vdu_version=0.250.1671 | saving_tool_path=/tmp/TA_Workspace |
    ${ns}  Get vCU Namespace From TestLine  ${gnb_index}
    Set Suite Variable    ${DOWNLOAD_LINK}    https://artifactory-hz1.int.net.nokia.com/artifactory/mnp5g-central-public-remote/System_Release
    log to console    Starting download ${vCU_VERSION} packages...
    tafssh.Execute    command=cd ${saving_tool_path}; wget ${DOWNLOAD_LINK}/${vCU_VERSION}/CU_CNF-${vCU_VERSION}.zip
    tafssh.Execute    command=cd ${saving_tool_path}; wget ${DOWNLOAD_LINK}/${vCU_VERSION}/artifacts/onBoardingApp.tgz
    log to console    Starting unzip ${vCU_VERSION} packages...
    tafssh.Execute    command=cd ${saving_tool_path}; tar -zxvf onBoardingApp.tgz
    tafssh.Execute    command=cd ${saving_tool_path}; unzip CU_CNF-${vCU_VERSION}.zip
    tafssh.Execute    command=chmod -R 777 ${saving_tool_path}
    tafssh.Execute    command=cp ${saving_tool_path}/onBoardingApp/images.properties.OCP ${saving_tool_path}/Image
    tafssh.Execute    command=cp ${saving_tool_path}/onBoardingApp/loadImages.sh ${saving_tool_path}/Image
    tafssh.Execute    command=cd ${saving_tool_path}/HelmChart; tar -zxvf aic-vcu-${vCU_VERSION}.tgz
    tafssh.Execute    command=chmod -R 777 ${saving_tool_path}/HelmChart
    tafssh.Execute    command=cd ${saving_tool_path}/HelmChart; tar -zxvf aic-vcu-prerequisite-${vCU_VERSION}.tgz
    log to console    Starting upload ${vCU_VERSION} images ...
    helm.execute_command_on_master_cluster     cd ${saving_tool_path}/Image/ && sh loadImages.sh -n ${ns}   fail_on_error=True

Upload Yaml File And Install VCU
    [Arguments]   ${saving_tool_path}  ${vcu_chart_name}=vcu1   #${vCU_VERSION}
    [Documentation]  Upload Yaml File And Install VDU
    ...  author: miao.a.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | vDU_VERSION     | yes | vDU_VERSION, e.g, 0.250.1285 |
    ...    | saving_tool_path    | yes | saving_tool_path, e.g, /tmp/TA_Workspace |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...   | Upload Yaml File And Install VDU | saving_tool_path=/tmp/TA_Workspace | vdu_version=0.390.1671 |
    log to console    starting install intnet pvc vcu ...
    Set Test Variable    ${vcu_chart_dir}    HelmChart/aic-vcu-cnf
    Set Test Variable    ${vcu_pvc_dir}    HelmChart/aic-vcu-prerequisite/charts/aic-vcu-pvc/
    Set Test Variable    ${vcu_rbac_dir}    HelmChart/aic-vcu-prerequisite/charts/aic-vcu-rbac/
    Set Test Variable    ${cfg_dir}     ${tl.gnbs[0].cloud_deployment.default_cfg_dir}
    ${pvc_yaml_file}    OperatingSystem.Join Path    ${cfg_dir}     DEP_SCF_FILES/CU_0/values-pvc.yaml
    ${rbac_yaml_file}    OperatingSystem.Join Path    ${cfg_dir}     DEP_SCF_FILES/CU_0/values-rbac.yaml
    ${cnf_yaml_file}    set variable    ${tl.gnbs[0].cloud_deployment.vnfs[0].yaml_file}
    tafssh.Upload file   local_path=${cnf_yaml_file}    remote_path=${saving_tool_path}/${vcu_chart_dir}/values-override.yaml
    tafssh.Upload file   local_path=${pvc_yaml_file}    remote_path=${saving_tool_path}/${vcu_pvc_dir}/values.yaml
    tafssh.Upload file   local_path=${rbac_yaml_file}    remote_path=${saving_tool_path}/${vcu_rbac_dir}/values.yaml
    ${return}   tafssh.Execute
    ...     command=cd ${saving_tool_path}/${vcu_rbac_dir}/;helm install ${vcu_chart_name}-rbac ./ -f values.yaml -n ${CLUSTER_NAME}
    should contain  ${return}   STATUS: deployed
    log to console  aic-rbac install complete \n
    ${return}   tafssh.Execute
    ...     command=cd ${saving_tool_path}/${vcu_pvc_dir}/;helm install ${vcu_chart_name}-pvc ./ -f values.yaml -n ${CLUSTER_NAME}
    should contain  ${return}   STATUS: deployed
    log to console  aic-pvc install complete \n
    tafssh.Execute
    ...     command=cd ${saving_tool_path}/${vcu_chart_dir}/;helm install ${vcu_chart_name} ./ -f values-override.yaml -n ${CLUSTER_NAME}
    should contain  ${return}   STATUS: deployed
    log to console    aic-vcu install complete \n

Modify vCU Chart Value Yaml File For NCIR
    [Arguments]  ${vcu_chart_name}   ${gnb_index}=0  #${vcu_version}
    helm.helm_merge_values_file
    ...  ${tl.gnbs[${gnb_index}].cloud_deployment.vnfs[0].yaml_file}
    ...  ${workspace_dir}/${vcu_chart_name}/values-override.yaml

Save vcu journal logs
    [Documentation]    collect all pods journal and startup_default logs
    Log To Console     \n\t\t- - - Saving vCU journal logs [...] - - -
    Get vCU pod name
    ssh.connect_to     hostname=${vcu_k8s_addr}    username=${vcu_k8s_usr}    password=${vcu_k8s_pwd}    alias=vcu
    ssh.execute        cd ${vCU_LOG_PATH} && rm -rf vcu_log && mkdir vcu_log
    ...                connection=vcu
    @{pod_list}        Create List    cpue  cpnrt  cpnb  cpif  cpcl  oampm  oamfm  oamext  oamconfig  oamcm  oamasm  upue
    @{oamext_cont}     Create List    oamagent
    @{oamasm_cont}     Create List    oamasm
    @{oamcm_cont}      Create List    oamcm
    @{oamconfig_cont}  Create List    oamconfig
    @{oamfm_cont}      Create List    oamfm
    @{oampm_cont}      Create List    oampm
    @{cpif_cont}       Create List    cpif
    @{cpue_cont}       Create List    cpue
    @{cpcl_cont}       Create List    cpcl
    @{cpnb_cont}       Create List    cpnb
    @{cpnrt_cont}      Create List    cpnrt
    @{upue_cont}       Create List    l2hicu
    ${container}       Create Dictionary   ${cpue_pod}=@{cpue_cont}       ${cpnrt_pod}=@{cpnrt_cont}           ${cpif_pod}=@{cpif_cont}
    ...                                    ${cpcl_pod}=@{cpcl_cont}       ${oampm_pod}=@{oampm_cont}           ${oamfm_pod}=@{oamfm_cont}
    ...                                    ${oamext_pod}=@{oamext_cont}   ${oamconfig_pod}=@{oamconfig_cont}   ${oamcm_pod}=@{oamcm_cont}
    ...                                    ${oamasm_pod}=@{oamasm_cont}   ${upue_pod}=@{upue_cont}             ${cpnb_pod}=@{cpnb_cont}
    FOR    ${cm}    IN    @{pod_list}
        ${container_key}    Set Variable    ${${cm}_pod}
        Collect journal and startup logs for cm    cm=${cm}   list=${container['${container_key}']}
    END
    ssh.execute        command=cd ${vCU_LOG_PATH} && tar -zcvf log.tar.gz vcu_log/    connection=vcu
    ssh.download_file  ${vCU_LOG_PATH}/log.tar.gz    ${LOG_PATH}/log.tar.gz           connection=vcu
    Log To Console     \t\t- - - Saving vCU journal logs [DONE] - - -

Collect vCU Container Logs
    [Arguments]    ${pod_name}    ${container_name}     ${log_path}=/home/${G_USER}
    [Documentation]  Collect Container Logs
    ...  author: yingguo.ying@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | chart_path    | yes | chart_path, e.g, HelmChart/aic-vdu |
    ...    | ns    | yes | namespace, e.g, eituser1 |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...   | Collect Container Logs | pod_name=po-eit1-oam-0 | container_name=oam |
    tafssh.Execute      command=mkdir ${log_path}
    wait until keyword succeeds  2min   60s   tafssh.Execute
    ...     kubectl logs ${pod_name} -c ${container_name} -n ${CLUSTER_NAME} > ${log_path}/${G_VCU_NAME}.${container_name}.log

Collect journal and startup logs for cm
    [Arguments]  ${cm}    ${list}
    FOR    ${cont}    IN    @{list}
        ssh.connect_to    hostname=${vcu_k8s_addr}    username=${vcu_k8s_usr}    password=${vcu_k8s_pwd}    alias=vcu
        ssh.execute       kubectl logs -n ${namespace} ${${cm}_pod} -c ctr-${namespace}-${cont} > ${vCU_LOG_PATH}/vcu_log/${cm}_journal.log
        ...               connection=vcu
        Sleep             3s
        ${startup_def}    Catenate    kubectl cp -n ${namespace} ${${cm}_pod}:/tmp/startup_DEFAULT.log
        ...                           ${vCU_LOG_PATH}/vcu_log/${cm}_startup_DEFAULT.log -c ${cont} > /dev/null 2>&1
        ssh.execute       ${startup_def}    connection=vcu
    END

Remove all unused docker images
    [Documentation]    clean up all unused images after testing
    ssh.connect_to     hostname=${vcu_k8s_addr}    username=${vcu_k8s_usr}    password=${vcu_k8s_pwd}    alias=vcu
    ssh.execute        command=sudo docker system prune -a --force
    ...                connection=vcu

check healing controller status
    ${ns}  Get vCU Namespace From TestLine
    ${output}          Wait Until Keyword Succeeds    1min  10s    helm.execute_command_on_master_cluster
    ...                                                            kubectl get pods -n ${ns}
    Should Contain     ${output.stdout}    healing-controller
    Log To Console     Deploy cnf done.\t\t\t\t\t\t\t \n    no_newline=True

Check vCU pod empty
    [Documentation]    Check pod empty
    [Arguments]  ${ns}
    ${output}          helm.execute_command_on_master_cluster    kubectl get pods -n ${ns}
    Should Be Empty    ${output.stdout}

Get vCU pod name
    [Documentation]    Get pod name
    ${result}          kubectl_get_pods    namespace=${namespace}    conn=vcu
    #@{result}          Split String    ${result}    \r\n
    Remove From List   ${result}    0
    Remove From List   ${result}    -1
    Log                ${result}
    ${length}          Get Length    ${result}
    Set Suite Variable  @{pod_name_list}    @{EMPTY}
    FOR    ${n}    IN RANGE    ${length}
        @{podname}   Split String    ${result[${n}]}   ${SPACE}   1
        Log    ${podname[0]}
        Append To List    ${pod_name_list}    ${podname[0]}
        Run Keyword If    "upue" in "${podname[0]}"           Set Suite Variable   ${upue_pod}           ${podname[0]}
        Run Keyword If    "oamasm" in "${podname[0]}"         Set Suite Variable   ${oamasm_pod}         ${podname[0]}
        Run Keyword If    "oamcm" in "${podname[0]}"          Set Suite Variable   ${oamcm_pod}          ${podname[0]}
        Run Keyword If    "oamconfig" in "${podname[0]}"      Set Suite Variable   ${oamconfig_pod}      ${podname[0]}
        Run Keyword If    "oamext" in "${podname[0]}"         Set Suite Variable   ${oamext_pod}         ${podname[0]}
        Run Keyword If    "oamfm" in "${podname[0]}"          Set Suite Variable   ${oamfm_pod}          ${podname[0]}
        Run Keyword If    "oampm" in "${podname[0]}"          Set Suite Variable   ${oampm_pod}          ${podname[0]}
        Run Keyword If    "cpcl" in "${podname[0]}"           Set Suite Variable   ${cpcl_pod}           ${podname[0]}
        Run Keyword If    "cpif" in "${podname[0]}"           Set Suite Variable   ${cpif_pod}           ${podname[0]}
        Run Keyword If    "cpnb" in "${podname[0]}"           Set Suite Variable   ${cpnb_pod}           ${podname[0]}
        Run Keyword If    "cpnrt" in "${podname[0]}"          Set Suite Variable   ${cpnrt_pod}          ${podname[0]}
        Run Keyword If    "cpue" in "${podname[0]}"           Set Suite Variable   ${cpue_pod}           ${podname[0]}
        Run Keyword If    "lwsd" in "${podname[0]}"           Set Suite Variable   ${lwsd_pod}           ${podname[0]}
        Run Keyword If    "pm" in "${podname[0]}"             Set Suite Variable   ${pm_pod}             ${podname[0]}
        Run Keyword If    "rcpfm" in "${podname[0]}"          Set Suite Variable   ${rcpfm_pod}          ${podname[0]}
        Run Keyword If    "rcpsdl-0" in "${podname[0]}"       Set Suite Variable   ${rcpsdl-0_pod}       ${podname[0]}
        Run Keyword If    "rcpsdl-1" in "${podname[0]}"       Set Suite Variable   ${rcpsdl-1_pod}       ${podname[0]}
        Run Keyword If    "rcpsdl-2" in "${podname[0]}"       Set Suite Variable   ${rcpsdl-2_pod}       ${podname[0]}
        Run Keyword If    "rcpum" in "${podname[0]}"          Set Suite Variable   ${rcpum_pod}          ${podname[0]}
        Run Keyword If    "securestorage" in "${podname[0]}"  Set Suite Variable   ${securestorage_pod}  ${podname[0]}
        Run Keyword If    "logservice" in "${podname[0]}"     Set Suite Variable   ${logservice_pod}     ${podname[0]}
        Run Keyword If    "trsconfig" in "${podname[0]}"      Set Suite Variable   ${trsconfig_pod}      ${podname[0]}
    END
    Sleep              2s

Check vCU container
    [Documentation]    Do some common thing for every postcondition of cases
    [Arguments]        ${pod_name}
    ${result}          helm.execute_command_on_master_cluster    kubectl describe pod ${pod_name} -n ${namespace}
    @{list}            Split String    ${result.stdout}    Containers:     2
    ${length}          Get Length      ${list}
    @{list1}           Split String    ${list[${length}-1]}    Conditions:    1
    ${length}          Get Length      ${list1}
    ${num1}            Get Count       ${list1[0]}    Running
    ${num2}            Get Count       ${list1[0]}    State:
    ${num3}            Get Count       ${list1[0]}    Last State:
    Should Be True     ${num2} != 0
    Should Be True     ${num1} == ${num2}-${num3}

Load And Activate SCF
    [Arguments]        ${oam_web_ip}    ${filepath}   ${cu_du}=vCU  #${WEBUI_USERNAME}    ${WEBUI_PASSWORD}
    [Documentation]    Upload SCF to CU WebEM and activation SCF
    Log To Console     \n Load And Activate SCF on ${cu_du}: ${oam_web_ip}
    ${short}           Split String    ${filepath}    /
    ${short}           Catenate    SEPARATOR=/    ${short[-5]}  ${short[-4]}  ${short[-3]}  ${short[-2]}  ${short[-1]}
    Log To Console     ${short}
    ${upload_plan_response}        vdu.upload_plan    ${filepath}   #vdu_connection=None
    Wait Until Keyword Succeeds    10s  2s    Upload Vcu Plan Operation Should Be Successful
    ...                                         ${upload_plan_response['action_id']}
    ${validate_plan_response}      vdu.validate_plan    ${upload_plan_response['plan_id']}   #vdu_connection=None
    Wait Until Keyword Succeeds    10s  2s    Validate Vcu Plan Operation Should Be Successful
    ...                                         ${upload_plan_response['plan_id']}
    ...                                         ${validate_plan_response['action_id']}
    ${activate_plan_response}      vdu.activate_plan    ${upload_plan_response['plan_id']}   #vdu_connection=None
    Sleep                          3m
    Wait Until Keyword Succeeds    20m  45s    Activate Vcu Plan Operation Should Be Successful
    ...                                          ${upload_plan_response['plan_id']}
    ...                                          ${activate_plan_response['id']}
    Run Keyword And Ignore Error   vdu.get_current_plan_file    local_dir_path=${SCF_PATH}       #${OUTPUT_DIR}/
    ...                                                         filename=cran8.xml  #lSCF_from_${cu_du}_${tl.tl_cloud_topology}.xml
    ...                                                         timeout=120s

Upload Vcu Plan Operation Should Be Successful
    [Arguments]  ${upload_action_id}
    [Documentation]   checking upload plan operation status should be successful
    ...    *AUTHOR*  miao.a.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | upload_action_id | yes | upload action id, get from upload_plan |
    ...    *RETURN VALUE*
    ...    None
    ${upload_operation_response}    vdu.get_upload_plan_operation_status    ${upload_action_id}
    Should Be Equal As Strings      ${upload_operation_response['status']}    success
    Log To Console     Upload Plan Success

Validate Vcu Plan Operation Should Be Successful
    [Arguments]  ${plan_id}  ${action_id}
    [Documentation]   checking validate plan operation status should be successful
    ...    *AUTHOR*  calla.wang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | plan_id | yes | the plan file id, get from upload_plan |
    ...    | action_id | Yes | the validate action id, get from validate_plan |
    ...    *RETURN VALUE*
    ...    None
    ${validate_plan_response}     vdu.get_validate_plan_operation_status    ${plan_id}    ${action_id}
    Should Be Equal As Strings    ${validate_plan_response['status']}  success
    Log To Console     Validate Plan Success

Activate Vcu Plan Operation Should Be Successful
    [Arguments]  ${plan_id}  ${action_id}
    [Documentation]   checking activate plan operation status should be successful
    ...    *AUTHOR*  calla.wang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | plan_id | yes | the plan file id, get from upload_plan |
    ...    | action_id | Yes | the activate action id, get from activate_plan |
    ...    *RETURN VALUE*
    ...    None
    ${activate_plan_response}     vdu.get_activate_plan_operation_status    ${plan_id}    ${action_id}
    Should Be Equal As Strings    ${activate_plan_response['status']}    success
    Log To Console     Activate Plan Success \t\t\t\t\t\t    no_newline=True

Check CNF SCF Activation Status
    [Documentation]    This keyword will Check SCF Activation Status for CNF CU about coam cloudbts.
    ${output}          ssh.execute    command=cd ${vCU_LOG_PATH}; rm -rf vcu_log; mkdir vcu_log
    ...                               connection=vcu
    Get vCU pod name
    ssh.connect_to     hostname=${vcu_k8s_addr}    username=${vcu_k8s_usr}    password=${vcu_k8s_pwd}    alias=vcu
    ssh.execute        kubectl logs -n ${namespace} ${oamconfig_pod} -c ctr-${namespace}-oamconfig > ${vCU_LOG_PATH}/vcu_log/oamconfig_journal.log
    ...                connection=vcu
    ${check}           ssh.execute    sudo tac ${vCU_LOG_PATH}/vcu_log/oamconfig_journal.log | grep -i "NRBTS_L operational state" -m 1
    ...                connection=vcu
    Should Contain     ${check}    Enabled


Check VCU Delete Status
    ${pod_status}=     tafssh.Execute    command=kubectl get pod -n ${CLUSTER_NAME}
    should contain      ${pod_status}    No resources found in ${CLUSTER_NAME} namespace

Modify vCU Chart new Value Yaml File For NCIR
    [Arguments]  ${new_yaml}  ${vcu_chart_name}=aic-vcu-cn  #${gnb_index}=0  #${vcu_index}=0
    helm.helm_merge_values_file
    ...  ${new_yaml}
    ...  ${workspace_dir}/${vcu_chart_name}/values-override.yaml

vCU Full Commission
#    ${oam_web_ip}     set variable    ${tl.gnbs[0].dus[0].oam_http_connection_details.addr}
#    ${WEBUI_USERNAME}   set variable    ${tl.gnbs[0].dus[0].oam_http_connection_details.username}
#    ${WEBUI_PASSWORD}   set variable    ${tl.gnbs[0].dus[0].oam_http_connection_details.password}
    ${oam_web_ip}     set variable    ${tl.gnbs[0].cu.oam_http_connection_details.addr}
    ${WEBUI_USERNAME}   set variable    ${tl.gnbs[0].cu.oam_http_connection_details.username}
    ${WEBUI_PASSWORD}   set variable    ${tl.gnbs[0].cu.oam_http_connection_details.password}
    Wait Until Keyword Succeeds    22min  30s    Load And Activate SCF    ${oam_web_ip}    ${SCF_PATH}   ${WEBUI_USERNAME}   ${WEBUI_PASSWORD}


Verify Vcu Cell setup
    [Tags]    CELL    ONAIR    ONAIR_CALL    postcom
    log to console  check cell on air
    Wait Until Keyword Succeeds    10min  1min   vCU_Ecpri_ru_power_check

vCU_Ecpri_ru_power_check
    [Documentation]    Ecpri_ru_power_check
    ...    *AUTHOR* yingguo.ying@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    21.07.2021,yingguo.ying@nokia-sbell.com, create
    ...
    ...    | Input Parameters | Man. | Description |
    ...
    ...    *RETURN VALUE*
    ...    none
    ...    Example
    ...    | Ecpri_ru_power_check |
    ${command}=  catenate    kubectl exec -n ${CLUSTER_NAME} ${VDU_OAMFH_PODS_NAME} -c ctr-${CLUSTER_NAME}-oamfh -- bash
    ...    -c "{ echo \\"aasyscomgw -r\\";sleep 1;echo \\"quit\\"; } | telnet 0 15067;" 2>&1 | grep -a "192.168" | awk \'{print $7}\'
    ${ru_ip_list} =    tafssh.execute   ${command}
    should not be empty    ${ru_ip_list}
    #@{ru_ip_list}=    Split To Lines    ${ru_ip_list}
    log to console    ${ru_ip_list}

    tafssh.Execute    command=sudo ip link add link ens1f1 name rutest.295 type vlan id 295
    tafssh.Execute    command=sudo ip addr add 192.168.254.60/26 dev rutest.295
    tafssh.Execute    command=sudo ip link set dev rutest.295 up
    ${serviceuser_psw}=    set variable  bobuWrUHk7Xq7WPpY9ZcjEi8zNdX3plZ+/y420RZ7W4=
    ${internal_ru_ip}=    set variable  192.168.101.2
    FOR   ${ru_ip}  IN   @{ru_ip_list}
        ${made}=    Set Variable    "ssh -q -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@${internal_ru_ip} /usr/bin/dapd -pwr 0"

        ${power}=    tafssh.Execute
        ...    sshpass -p ${serviceuser_psw} ssh -q -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no serviceuser@${ru_ip} ${made}

        Log To Console    ${power}

        Should Not Contain    ${power}    0.0
        Should Not Contain    ${power}    -inf
        Should Not Contain    ${power}    Fail
        Should Not Contain    ${power}    Aborted
        Should Not Contain    ${power}    exception
    END

    tafssh.Execute    command=sudo ip link del rutest.295 type vlan


Prepare vCU new version package
    tafssh.Execute    command=cd /home/cbis-admin/TA_Workspace && rm -r NEW_VERSION
    tafssh.Execute    command=cd /home/cbis-admin/TA_Workspace && mkdir NEW_VERSION
    Set Test Variable   ${workspace_dir}  /home/cbis-admin/TA_Workspace/NEW_VERSION
    vCU Docker Images Uploading    ${vCU_NEW_VERSION}    ${workspace_dir}
    Set Test Variable    ${vcu_chart_dir}    HelmChart/aic-vcu-cnf
    Modify vCU Chart new Value Yaml File For NCIR   ${NEW_YAML}   ${vcu_chart_dir}
    vCU Cluster Login With Admin
    tafssh.Execute    command=cd /home/core/TA_Workspace/NEW_VERSION && rm CU_CNF-0.250.*
    tafssh.Execute    command=cd /home/core/TA_Workspace/NEW_VERSION && rm -r Image

Get Vcu Active Alarm Fault
    [Documentation]  Login WebUI And Get Alarm Fault by Jenknis
    ...  can be used on jenkins
    ...  author: miao.a.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | OAM_IP | yes | e.g, 10.56.126.210 |
    ...    | USER | yes | e.g, Nemuadmin |
    ...    | PASSWORD | yes | e.g, nemuuser |
    ...
    ...    *RETURN VALUE*
    ...    alarms
    ...
    ...    Example
    ...    | alarms= Login WebUI And Get Alarm Fault by Jenknis | OAM_IP=10.56.125.210 | USER=Nemuadmin | PASSWORD=nemuuser |
    ${active_alarms}      coam_cu.get_active_alarms
    Log To Console    Active alarms:
    ${alarms}    Get From Dictionary     ${active_alarms}    alarms
    FOR    ${his_alarm}    IN    @{alarms}
        Log To Console   FaultId: ${his_alarm['fault_id']}; FaultName: ${his_alarm['fault_name']}; AlarmId: ${his_alarm['alarm_id']};
        ...     AlarmName: ${his_alarm['alarm_name']}; AlarmingObject: ${his_alarm['alarming_object']}; Severity: ${his_alarm['severity']}
    END
    [Return]        ${alarms}

Login vCU Webem
   Log To Console    login vcu webem
   ${WEBUI_URL}     set variable    ${tl.gnbs[0].cu.oam_http_connection_details.addr}
   ${WEBUI_USERNAME}   set variable    ${tl.gnbs[0].cu.oam_http_connection_details.username}
   ${WEBUI_PASSWORD}   set variable    ${tl.gnbs[0].cu.oam_http_connection_details.password}
   Wait Until Keyword Succeeds    5 min    20 s    coam_cu.connect_to
   ...            ${WEBUI_URL}    ${EMPTY}    ${WEBUI_USERNAME}    ${WEBUI_PASSWORD}    cuoam_19b    ${TRUE}

vCU Rest Login
    [Arguments]  ${restapi_version}=cuoam_19b  ${gnb_index}=0  ${alias}=default  #${vcu_index}=0
    [Documentation]  login vdu webem.
    ...  history change:
    ...  author:miao.a.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...
    ${oam_httpaddr}   set variable   ${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}
    ${oam_web_ip}   set variable if   ':' in '''${oam_httpaddr}'''   [${oam_httpaddr}]    ${oam_httpaddr}
    run keyword and ignore error  vCU Rest Logout
    ${vdu_connection}=   Run Keyword If  '${restapi_version}'=='cuoam_19b'  vdu.connect to
    ...  host=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}
    ...  port=${EMPTY}
    ...  username=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...  password=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    ...  secure=True
    ...  connection_name=${alias}
    ...  ELSE  vdu.connect to
    ...  host=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}
    ...  port=8081
    ...  username=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...  password=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}

vCU Rest Logout
    [Arguments]  ${alias}=default
    [Documentation]  vCU Rest Logout
    ...  history change:
    ...  author:miao.a.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   4.09.2020,chris.l.cao@nokia-sbell.com, add check for OAM up or down
    ...   11.9.2020,chris.l.cao@nokia-sbell.com, change to use 'Wait Until VDU OAM Up'
    ...
    vdu.disconnect  ${alias}

vCU Cluster Login With Tenant
    [Arguments]  ${vcu_index}=0  ${gnb_index}=0
    ${conn}=    helm.helm_master_connect
    ...  ${tl.gnbs[${gnb_index}].dus[${vcu_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.addr}
    ...  22
    ...  ${tl.gnbs[${gnb_index}].dus[${vcu_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.username}
    ...  ${tl.gnbs[${gnb_index}].dus[${vcu_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.password}
    [Return]   ${conn}
