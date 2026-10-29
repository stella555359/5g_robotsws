*** Settings ***

Library           taf.transport.ssh                     WITH NAME    tafssh
Library           taf.ul.vdu.helm                       WITH NAME    helm
Library           taf.gnb.oam.coam.vdu.interface.Vdu    WITH NAME    vdu
Library           taf.ul.vdu.helm                       WITH NAME    helm
Library           OperatingSystem
Library           Process
Library           SeleniumLibrary
Library           String
Library           taf.selenium.gnb.oam.coam.vdu         WITH NAME    svdu
Library           Collections

Resource          vdu_oam_cm.robot
Resource          common_setup_teardown.robot
Resource          aic_vdu_cell_status.robot
Resource          aic_vdu_oam.robot
Resource          aic_vdu_oam_cm.robot
Resource          aic_vdu_oam_status.robot
Resource          aic_vdu_ru_status.robot
Resource          aic_vdu_webem.robot

*** Variables ***
${G_VDU_NAME}           vdu
${CLUSTER_NAME}         cran1
${G_USER}               core

*** Keywords ***
#Case Precondition
Deployment_vDU
    log to console  Case Precondition deploy vDU and onair
    vDU SSH Login
    ${kuafu_dir}    Get Kuafu
    set test variable   ${kuafu_dir}
#    ${REDEPLOY}     Check if vDU need to redeploy with kuafu    ${kuafu_dir}
#    run keyword if  """${REDEPLOY}"""=="""True"""
    run keywords     VDU Undeployment By Kuafu   ${kuafu_dir}
    ...   AND   VDU Onboard By Kuafu    ${kuafu_dir}    build_version=${vDU_VERSION}
    ...   AND   VDU deployment By Kuafu     ${kuafu_dir}    chart_name=${G_VDU_NAME}
    ...   AND   Load And Active SCF By Kuafu    ${kuafu_dir}    ${SCF_FILE}
#    wait until keyword succeeds   40min   2min  Check RF Power By Kuafu   ${kuafu_dir}
    Set Test variable    ${MRBTS_ID}    ${tl.gnbs[0].instance_id}
    Set Test variable    ${NS}    ${tl.gnbs[0].dus[0].cloud_deployment.cloud_hosting.namespace}
    [Teardown]    helm.helm_master_close

Case Postcondition
    log to console  \n Case Postcondition
    vDU SSH Login
    tafssh.Execute    command=rm -rf /home/${G_USER}/TA_Workspace
    [Teardown]    helm.helm_master_close

OCP Is Deployed Successfully And Kubectl Command Can Be Excuted
    ${config_info}    tafssh.Execute    kubectl config view
    Should Contain    ${config_info}    apiVersion
    log    ${config_info}

Get Kuafu
    [Arguments]     ${gnb_index}=0      ${vdu_index}=0
    log to console  \n Downloading Kuafu...
    ${Download_Local_Dir}=  Create Local Chart Directory In vDU
    tafssh.Execute  command=cd ${Download_Local_Dir};git clone https://gitlabe2.ext.net.nokia.com/kuafu/kuafu.git
    ${kuafu}    tafssh.Execute  command=cd ${Download_Local_Dir}/kuafu;ls
    should contain  ${kuafu}    10-vdu-l3call-test.sh
    ${kuafu_dir}   Set Variable   ${Download_Local_Dir}/kuafu
    log to console  \n Kuafu Download Success
    ${return}   tafssh.Execute  command=cd ${kuafu_dir};. ./10-vdu-l3call-test.sh
    should contain  ${return}   10-config-vdu-deploy.sh
    tafssh.Send Command  command=cd ${kuafu_dir}/scenarios/vdu_l3call;./10-config-vdu-deploy.sh
    ${return}   tafssh.Send Command  command=ZZ
    ${remote_file_version}  tafssh.Execute  command=cat ${kuafu_dir}/artifacts/vdu_config.ini | grep -w version
    ${kuafu_config_file}   OperatingSystem.Join Path    ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.default_cfg_dir}
    ...     kuafu_vdu_config.yaml
    tafssh.Upload file   local_path=${kuafu_config_file}    remote_path=${kuafu_dir}/artifacts/vdu_config.ini
    ${local_file_version}   tafssh.Execute  command=cat ${kuafu_dir}/artifacts/vdu_config.ini | grep -w version
    should be equal     ${remote_file_version}      ${local_file_version}
    log to console  \n vdu_config.ini Replace Complete
    [Return]    ${kuafu_dir}

VDU Undeployment
    [Arguments]  ${vdu_index}=0  ${gnb_index}=0
    [Documentation]    VDU Undeployment
    ...    *AUTHOR* qixuan.zhang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    None
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...   | VDU Undeployment |
    log to console     \n ***----Starting undeploy vDU...
    ${ns}  set variable  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.namespace}
    ${vdu_release_name}=     tafssh.Execute    command=helm list -n ${ns} |grep 'aic-vdu-0.300'|awk '{print $1}'|tr -d '\r\n'
    ${vdu_rbac_release_name}=     tafssh.Execute    command=helm list -n ${ns} |grep 'aic-vdu-rbac'|awk '{print $1}'|tr -d '\r\n'
    ${pvc_release_name}=      tafssh.Execute    command=helm list -n ${ns} |grep 'aic-pvc'|awk '{print $1}'|tr -d '\r\n'
    run keyword and ignore error   helm.helm_delete    ${vdu_release_name}  ${ns}
    run keyword and ignore error   helm.helm_delete    ${vdu_rbac_release_name}  ${ns}
    run keyword and ignore error   helm.helm_delete    ${pvc_release_name}  ${ns}
    Wait Until Keyword Succeeds  300   10s    Check VDU PVC Delete Status

VDU Undeployment By Kuafu
    [Arguments]     ${kuafu_dir}    ${vdu_index}=0  ${gnb_index}=0
    log to console     \n ***----Starting undeploy vDU by kuafu...
    ${ns}  set variable  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.namespace}
    ${current_chart_name}=     tafssh.Execute    command=helm list -n ${ns} |grep -e aic-vdu-16.300 -e aic-vdu-0.300|awk '{print $1}'|tr -d '\r\n'
    Change Value In Kuafu vDU Config File   ${kuafu_dir}    value_name=chart_name     new_value=${current_chart_name}
    log to console  \n chart_name Replace Complete
    ${return}   tafssh.Execute  command=cd ${kuafu_dir};. ./10-vdu-l3call-test.sh
    should contain  ${return}   20-delete-vdu.sh
    ${return}   tafssh.Execute  command=cd ${kuafu_dir}/scenarios/vdu_l3call;./20-delete-vdu.sh
    should contain  ${return}   [INFO] vDU deletion successful
    log to console  \n [INFO] vDU deletion successful

VDU Onboard By Kuafu
    [Arguments]     ${kuafu_dir}    ${build_version}
	log to console     \n ***----Starting onboard vDU by kuafu...
    Change Value In Kuafu vDU Config File   ${kuafu_dir}    value_name=build_version     new_value=${build_version}
    ${return}   tafssh.Execute  command=cd ${kuafu_dir};. ./10-vdu-l3call-test.sh
    should contain  ${return}   16-onboard-vdu.sh
    ${return}    tafssh.Execute  command=cd ${kuafu_dir}/scenarios/vdu_l3call;./16-onboard-vdu.sh
    should not contain  ${return}   build is not supported

VDU deployment By Kuafu
    [Arguments]     ${kuafu_dir}    ${chart_name}=${G_VDU_NAME}
    log to console     \n ***----Starting deploy vDU by kuafu...
    Change Value In Kuafu vDU Config File   ${kuafu_dir}    value_name=chart_name     new_value=${chart_name}
    ${return}   tafssh.Execute  command=cd ${kuafu_dir};. ./10-vdu-l3call-test.sh
    should contain  ${return}   21-create-vdu.sh
    ${return}   tafssh.Execute  command=cd ${kuafu_dir}/scenarios/vdu_l3call;./21-create-vdu.sh
    should contain  ${return}   [INFO] vDU creation successful
    log to console  \n [INFO] vDU creation successful

Load And Active SCF By Kuafu
    [Arguments]     ${kuafu_dir}    ${scf_file}     ${gnb_index}=0      ${vdu_index}=0
    log to console     \n ***----Starting load and active scf by kuafu...
    ${local_scf_file}   OperatingSystem.Join Path    ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.default_cfg_dir}
    ...     ${scf_file}
    tafssh.Upload file   local_path=${local_scf_file}   remote_path=${kuafu_dir}/scf/vdu/${scf_file}
    Change Value In Kuafu vDU Config File   ${kuafu_dir}    value_name=scf_file_name   new_value=${scf_file}
    log to console  \n SCF Add To Kuafu Complete
    ${return}   tafssh.Execute  command=cd ${kuafu_dir};. ./10-vdu-l3call-test.sh
    should contain  ${return}   42-auto-load-SCF-and-activate.sh
    ${return}   tafssh.Execute  command=cd ${kuafu_dir}/scenarios/vdu_l3call;./42-auto-load-SCF-and-activate.sh
    should contain  ${return}   [INFO] Activate SCF file successfully
    log to console  \n [INFO] Activate SCF file successfully

Change Value In Kuafu vDU Config File
    [Arguments]     ${kuafu_dir}    ${value_name}    ${new_value}
    ${current_value}    tafssh.Execute
    ...     cat ${kuafu_dir}/artifacts/vdu_config.ini | grep -w ${value_name} | grep -v '#' | tr -d '\r\n'
    tafssh.Execute  command=sed -i 's/${current_value}/${value_name}=${new_value}/g' ${kuafu_dir}/artifacts/vdu_config.ini

Check VDU PVC Delete Status
    [Arguments]  ${vdu_index}=0  ${gnb_index}=0
    [Documentation]   Check VDU PVC Delete Status
    ...   *AUTHOR* qixuan.zhang@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...	   None
    ...   *RETURN VALUE*
    ...    None
    ...   Example
    ...   | Check VDU PVC Delete Status |
    ${ns}  set variable  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.namespace}
    ${pod_status}=     tafssh.Execute    command=kubectl get pod -n ${ns}
    should contain      ${pod_status}    No resources found in ${ns} namespace
    ${vdu_rbac_release_name}=     tafssh.Execute    command=helm list -n ${ns} |grep 'aic-vdu-rbac'|awk '{print $1}'|tr -d '\r\n'
    should be true  ${vdu_rbac_release_name.__len__()}==0
    ${pvc_release_name}=      tafssh.Execute    command=helm list -n ${ns} |grep 'aic-pvc'|awk '{print $1}'|tr -d '\r\n'
    should be true  ${pvc_release_name.__len__()}==0

VDU Deployment And Check Pods Status
    [Arguments]   ${vDU_VERSION}   ${ADD_OAMFH_FLAG}=no  ${Image_Tag}=no
    [Documentation]    VDU Deployment And Check Pods Status
    ...    *AUTHOR* wei.zuo@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | vDU_VERSION     | yes | vDU_VERSION, e.g, 0.390.1285 |
    ...    | Image_Tag    | no | default is none |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...   | VDU Deployment And Check Pods Status | vDU_VERSION=0.390.1671 |
    log to console     \n ***----Starting deploy vDU via OCP
    ${Download_Local_Dir}=    Create Local Chart Directory In vDU
    vDU Docker Images Uploading    ${vDU_VERSION}    ${Download_Local_Dir}
    run keyword if    '${ADD_OAMFH_FLAG}' == 'yes'    Add oamfh flag   ${vDU_VERSION}   ${Download_Local_Dir}   ${Image_Tag}
    Upload Yaml File And Install VDU    ${Download_Local_Dir}   ${vDU_VERSION}
    wait until keyword succeeds    3min    30s    vDU Pod Status Should Be As Expected    Running

Create Local Chart Directory In vDU
    [Documentation]  create local directory in vDU cluster to store the onBoardingApp and chart
    ...  the directory is consisted of testline > timestamp
    ...  author: wei.zuo@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...    /tmp/TA_Workspace
    ...
    ...    Example
    ...   | Create Local Chart Directory In vDU Eituser |
    Set Test Variable    ${Download_Local_Dir}    /home/${G_USER}/TA_Workspace
    tafssh.Execute    command=rm -rf ${Download_Local_Dir}
    tafssh.Execute    command=mkdir -p ${Download_Local_Dir}
    [Return]    ${Download_Local_Dir}

vDU Docker Images Uploading
    [Arguments]   ${vdu_version}  ${saving_tool_path}  ${vdu_index}=0  ${gnb_index}=0
    [Documentation]  Upload packages and images to vdu.
    ...  If you use this kwyworkd, images will be uploaded and all files are here.
    ...  author: wei.zuo@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | vDU_VERSION     | yes | vDU_VERSION, e.g, 0.390.1285 |
    ...    | saving_tool_path    | yes | saving_tool_path, e.g, /tmp/TA_Workspace |
    ...    | vdu_index     | no | vdu_index, default value is 0 |
    ...    | gnb_index     | no | gnb_index, default value is 0 |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...   | vDU Docker Images Uploading | vdu_version=0.390.1671 | saving_tool_path=/tmp/TA_Workspace |
    Set Suite Variable    ${DOWNLOAD_LINK}    https://artifactory-hz1.int.net.nokia.com/artifactory/mnp5g-central-public-remote/System_Release
    log to console    Starting download ${vDU_VERSION} packages...
    tafssh.Execute    command=cd ${saving_tool_path}; wget ${DOWNLOAD_LINK}/${vDU_VERSION}/vDU-${vDU_VERSION}.zip
    tafssh.Execute    command=cd ${saving_tool_path}; wget ${DOWNLOAD_LINK}/${vDU_VERSION}/artifacts/onBoardingApp.tgz
    log to console    Starting unzip ${vDU_VERSION} packages...
    tafssh.Execute    command=cd ${saving_tool_path}; tar -zxvf onBoardingApp.tgz
    tafssh.Execute    command=cd ${saving_tool_path}; unzip vDU-${vDU_VERSION}.zip
    tafssh.Execute    command=chmod -R 777 ${saving_tool_path}
    tafssh.Execute    command=cp ${saving_tool_path}/onBoardingApp/images.properties.OCP ${saving_tool_path}/Image
    tafssh.Execute    command=cp ${saving_tool_path}/onBoardingApp/loadImages.sh ${saving_tool_path}/Image
    tafssh.Execute    command=cd ${saving_tool_path}/HelmChart; tar -zxvf aic-vdu-${vDU_VERSION}.tgz
    tafssh.Execute    command=chmod -R 777 ${saving_tool_path}/HelmChart
    tafssh.Execute    command=cd ${saving_tool_path}/HelmChart; tar -zxvf aic-vdu-prerequisite-${vDU_VERSION}.tgz
    log to console    Starting upload ${vDU_VERSION} images ...
    helm.execute_command_on_master_cluster     cd ${saving_tool_path}/Image/ && sh loadImages.sh -n ${CLUSTER_NAME}    fail_on_error=True

Upload Yaml File And Install VDU
    [Arguments]   ${saving_tool_path}   ${vDU_VERSION}   ${gnb_index}=0  ${vdu_index}=0
    [Documentation]  Upload Yaml File And Install VDU
    ...  author: wei.zuo@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | vDU_VERSION     | yes | vDU_VERSION, e.g, 0.390.1285 |
    ...    | saving_tool_path    | yes | saving_tool_path, e.g, /tmp/TA_Workspace |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...   | Upload Yaml File And Install VDU | saving_tool_path=/tmp/TA_Workspace | vdu_version=0.390.1671 |
    log to console    starting install intnet pvc vdu ...
    Set Test Variable    ${vdu_chart_dir}    HelmChart/aic-vdu
    Set Test Variable    ${pvc_chart_dir}    HelmChart/aic-vdu-prerequisite/charts/aic-pvc
    Set Test Variable    ${rbac_chart_dir}    HelmChart/aic-vdu-prerequisite/charts/aic-rbac
    helm.helm_merge_values_file
    ...  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.vnfs[0].yaml_file}
    ...  ${Download_Local_Dir}/aic-vdu/values-override.yaml
    ${cfg_dir}     set variable    ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.default_cfg_dir}
    ${yaml_file_name}   OperatingSystem.Join Path    ${cfg_dir}   aic-pvc-values-override.yaml
    tafssh.Upload file   local_path=${yaml_file_name}
    ...    remote_path=${saving_tool_path}/${pvc_chart_dir}/values-override.yaml
    helm.helm install  ${G_VDU_NAME}-pvc  ${saving_tool_path}/${pvc_chart_dir}/  ${CLUSTER_NAME}
    ...    ${saving_tool_path}/${pvc_chart_dir}/values-override.yaml
    log to console  PVC install complete \n
    helm.helm install  ${G_VDU_NAME}-rbac  ${saving_tool_path}/${rbac_chart_dir}  ${CLUSTER_NAME}
    log to console  aic-vdu-rbac install complete \n
    log To Console    vDU install started... please wait \n
    helm.helm install  ${G_VDU_NAME}  ${saving_tool_path}/${vdu_chart_dir}/  ${CLUSTER_NAME}
    ...     ${saving_tool_path}/${vdu_chart_dir}/values-override.yaml
    log to console    vDU install complete \n

Add oamfh flag
    [Arguments]     ${vdu_version}    ${saving_tool_path}     ${Image_Tag}
    ...    ${value_yaml}=${saving_tool_path}/HelmChart/aic-vdu/values.yaml
    [Documentation]  Add oamfh flag
    ...  author: qixuan.zhang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | vdu_version    | yes | vdu_version, e.g, 0.390.1761 |
    ...    | saving_tool_path    | yes | e.g, /tmp |
    ...    | Image_Tag    | yes | knife0 |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...   | Add oamfh flag | vdu_version=0.390.1671 | saving_tool_path=/tmp | Image_Tag=knife0 |
    log to console  Add oamfh flag
    tafssh.Execute    mkdir oamfh
    tafssh.Execute    touch oamfh/swconfig.txt; touch oamfh/Dockerfile
    tafssh.Execute    echo -e '245\=2\n252\=2' > oamfh/swconfig.txt
    tafssh.Execute    echo -e 'FROM image-registry.openshift-image-registry.svc:5000/${CLUSTER_NAME}/oamfh:${vdu_version}' > oamfh/Dockerfile
    tafssh.Execute    sed -i '$a ADD swconfig.txt /opt/nokia/SS_RCPCCSMCU/swconfig.txt' oamfh/Dockerfile
    tafssh.Execute    sed -i '$a RUN chmod +r /opt/nokia/SS_RCPCCSMCU/swconfig.txt' oamfh/Dockerfile
    tafssh.Execute    podman login image-registry.openshift-image-registry.svc:5000 -u admin -p $(oc whoami -t)
    tafssh.Execute    cd oamfh; podman build -t image-registry.openshift-image-registry.svc:5000/${CLUSTER_NAME}/oamfh:${vdu_version}_${Image_Tag} .
    tafssh.Execute    podman push image-registry.openshift-image-registry.svc:5000/${CLUSTER_NAME}/oamfh:${vdu_version}_${Image_Tag}
    ${image_check}    tafssh.Execute    podman images |grep -i ${vdu_version}_${Image_Tag}
    Should Contain    ${image_check}    ${vdu_version}_${Image_Tag}
    tafssh.Execute    sed -i '/repository: \"oamfh\"/{n;s/${vdu_version}/${vdu_version}_${Image_Tag}/;}' ${value_yaml}
    ${image}    tafssh.Execute    cat ${value_yaml} |grep -i ${vdu_version}_${Image_Tag}
    Should Contain    ${image}    ${vdu_version}_${Image_Tag}

Load SCF And Active SCF
    [Arguments]     ${scf_path}
    [Documentation]  Load SCF And Active SCF
    ...  author: qixuan.zhang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | scf_path    | yes | e.g, /tmp|
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Load SCF And Active SCF | scf_path=/tmp/xxxx.scf |
    log to console    Load SCF And Active SCF
    sleep    120s
    wait until keyword succeeds    20min    120s    vDU Send Commission By RestApi  ${scf_path}

Check if vDU need to redeploy
    [Arguments]  ${RF_TYPE}=AHCA
    [Documentation]  Check if vDU need to redeploy
    ...  author: qixuan.zhang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    *RETURN VALUE*
    ...    flag
    ...
    ...    Example
    ...    | ${REDPLOY} | Check if vDU need to redeploy |
    ...    | run keyword if | """${REDPLOY}"""=="""True""" | VDU Undeployment |
    ${result}   run keyword and ignore error     Check cell onair   rf_type=${RF_TYPE}
    ${flag}   set variable if  '''${result[0]}'''=='''FAIL'''    True    '''${result[0]}'''=='''PASS'''     False
    [Return]    ${flag}


Check if vDU need to redeploy with kuafu
    [Arguments]   ${kuafu_dir}
    [Documentation]  Check if vDU need to redeploy
    ...  author: miao.a.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    *RETURN VALUE*
    ...    flag
    ...
    ...    Example
    ...    | ${REDPLOY} | Check if vDU need to redeploy |
    ...    | run keyword if | """${REDPLOY}"""=="""True""" | VDU Undeployment |
    ${result}   run keyword and ignore error     Check RF Power By Kuafu    ${kuafu_dir}
    ${flag}   set variable if  '''${result[0]}'''=='''FAIL'''    True    '''${result[0]}'''=='''PASS'''     False
    [Return]    ${flag}

Check if vDU multi-cell need to redeploy
    [Arguments]  ${cell}=2
    [Documentation]  Check if vDU multi-cell need to redeploy
    ...  author: qixuan.zhang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    *RETURN VALUE*
    ...    flag
    ...
    ...    Example
    ...    | ${REDPLOY} | Check if vDU multi-cell need to redeploy | cell=2 |
    ...    | run keyword if | """${REDPLOY}"""=="""True""" | VDU Undeployment |
    ${result}   run keyword and ignore error     Check multicell onair   cell_num=${cell}
    ${flag}   set variable if  '''${result[0]}'''=='''FAIL'''    True    '''${result[0]}'''=='''PASS'''     False
    [Return]    ${flag}
