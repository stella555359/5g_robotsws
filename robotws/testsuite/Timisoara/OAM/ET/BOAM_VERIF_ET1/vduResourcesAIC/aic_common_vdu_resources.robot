*** Settings ***
Documentation
...     17.02.2025 -- solved :FOR and RF5.0 issues

Resource          aic_common_resources.robot
Library           SeleniumLibrary



*** Variables ***
${G_VDU_NAME}           vdu1
${CLUSTER_NAME}         cran1
${G_WEBUI_USER_NAME}    Nemuadmin
${G_WEBUI_PASSWORD}     nemuuser
${G_OAM_PODS_NAME}      po-${CLUSTER_NAME}-oam-0
${G_CPRT_PODS_NAME}     po-${CLUSTER_NAME}-cprt-0
${G_USER}               core
${VCU_DESTINATION_IP}   10.110.158.0/24
${F1_GW}                10.56.125.193
${MRBTS_ID}             11
${NRBTS_ID}             11

*** Keywords ***
NCIR19 Is Deployed Successfully And Kubectl Command Can Be Excuted
    vDU Cluster Login With Tenant
    ${config_info}    tafssh.Execute    kubectl config view
    Should Contain    ${config_info}    apiVersion
    log    ${config_info}
    [Teardown]    helm.helm_master_close

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
    vDU Cluster Login With Admin
    ${ns}  Get VDU Namespace From TestLine  ${vdu_index}  ${gnb_index}
    ${vdu_release_name}=     tafssh.Execute    command=helm list -n ${ns} |grep 'aic-vdu-0.300'|awk '{print $1}'|tr -d '\r\n'
    ${vdu_rbac_release_name}=     tafssh.Execute    command=helm list -n ${ns} |grep 'aic-vdu-rbac'|awk '{print $1}'|tr -d '\r\n'
    ${pvc_release_name}=      tafssh.Execute    command=helm list -n ${ns} |grep 'aic-pvc'|awk '{print $1}'|tr -d '\r\n'
    run keyword and ignore error   helm.helm_delete    ${vdu_release_name}  ${ns}
    run keyword and ignore error   helm.helm_delete    ${vdu_rbac_release_name}  ${ns}
    run keyword and ignore error   helm.helm_delete    ${pvc_release_name}  ${ns}
    Wait Until Keyword Succeeds  300   10s    Check VDU PVC Delete Status

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
    vDU Cluster Login With Admin
    ${ns}  Get VDU Namespace From TestLine  ${vdu_index}  ${gnb_index}
    ${pod_status}=     tafssh.Execute    command=kubectl get pod -n ${ns}
    should contain      ${pod_status}    No resources found in ${ns} namespace
    ${vdu_rbac_release_name}=     tafssh.Execute    command=helm list -n ${ns} |grep 'aic-vdu-rbac'|awk '{print $1}'|tr -d '\r\n'
    should be true  ${vdu_rbac_release_name.__len__()}==0
    ${pvc_release_name}=      tafssh.Execute    command=helm list -n ${ns} |grep 'aic-pvc'|awk '{print $1}'|tr -d '\r\n'
    should be true  ${pvc_release_name.__len__()}==0
    [Teardown]    tafssh.Disconnect

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
    vDU Cluster Login With Admin
    ${Download_Local_Dir}=    Create Local Chart Directory In vDU Eituser   ${vDU_VERSION}
    vDU Docker Images Uploading    ${vDU_VERSION}    ${Download_Local_Dir}
    run keyword if    '${ADD_OAMFH_FLAG}' == 'yes'    Add oamfh flag   ${vDU_VERSION}   ${Download_Local_Dir}   ${Image_Tag}
    Upload Yaml File And Install VDU    ${Download_Local_Dir}   ${vDU_VERSION}
    wait until keyword succeeds    3min    30s    vDU Pod Status Should Be As Expected    Running

Create Local Chart Directory In vDU Eituser
    #[Arguments]   ${vDU_VERSION}
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
    Set Test Variable    ${Download_Local_Dir}    /home/core/TA_Workspace
    tafssh.Execute    command=rm -rf ${Download_Local_Dir}
    tafssh.Execute    command=mkdir -p ${Download_Local_Dir}

    [Return]    ${Download_Local_Dir}

vDU Docker Images Uploading
    [Arguments]   ${vdu_version}  ${saving_tool_path}  #${vdu_index}=0  ${gnb_index}=0
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
    vDU Cluster Login With Admin
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
#    vDU Cluster Login With Admin    ${vdu_index}
    log to console    Starting upload ${vDU_VERSION} images ...
    helm.execute_command_on_master_cluster     cd ${saving_tool_path}/Image/ && sh loadImages.sh -n ${CLUSTER_NAME}    fail_on_error=True
    [Teardown]    helm.helm_master_close

Get file name
    [Arguments]     ${file_params}    ${connection}
    Send command    command=find ${${file_params}.compressed_file_path} -type f -name ${${file_params}.compressed_file_name_regex}
    ...    connection=${connection}    timeout=15 s
    ${output} =    Read output    connection=${connection}
    ${path_elements} =    Split String From Right    ${output}    /
    ${path_elements_length} =    Get Length    ${path_elements}
    ${path_elements_length} =    Evaluate    ${path_elements_length}-1
    ${file_name} =     Get From List    ${path_elements}    ${path_elements_length}
    ${file_name} =     Set Variable    ${file_name.replace("\n", "").replace("\r", "")}
    [Return]    ${file_name}


Upload Yaml File And Install VDU
    [Arguments]   ${saving_tool_path}   ${vDU_VERSION}
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
    Set Test Variable    ${intnet_chart_dir}    HelmChart/aic-intnet
    Modify vDU Chart Value Yaml File For NCIR   ${vDU_VERSION}   0    0    ${vdu_chart_dir}
    ${cfg_dir}     set variable    ${tl.gnbs[0].dus[0].cloud_deployment.default_cfg_dir}
    vDU Cluster Login With Admin
    ${yaml_file_name}   OperatingSystem.Join Path    ${cfg_dir}   aic-pvc-values-override.yaml
    tafssh.Upload file   local_path=${yaml_file_name}
    ...    remote_path=${saving_tool_path}/HelmChart/aic-vdu-prerequisite/charts/aic-pvc/values-override.yaml
    helm.helm install  pvc1  ${saving_tool_path}/HelmChart/aic-vdu-prerequisite/charts/aic-pvc/  ${CLUSTER_NAME}
    ...    ${saving_tool_path}/HelmChart/aic-vdu-prerequisite/charts/aic-pvc/values-override.yaml
#    tafssh.Execute
#    ...    command=cd ${saving_tool_path}/HelmChart/aic-vdu-prerequisite/charts/aic-pvc && helm install pvc1 ./ -f values-override.yaml -n cran1
    log to console  PVC install complete \n
    helm.helm install  vdu1-rbac  ${saving_tool_path}/HelmChart/aic-vdu-prerequisite/charts/aic-vdu-rbac  ${CLUSTER_NAME}
    log to console  aic-vdu-rbac install complete \n
    log To Console    vDU install started... please wait \n
    helm.helm install  vdu1  ${saving_tool_path}/HelmChart/aic-vdu/  ${CLUSTER_NAME}   ${saving_tool_path}/HelmChart/aic-vdu/values-override.yaml
#    tafssh.Execute    command=cd ${saving_tool_path}/HelmChart/aic-vdu && helm install vdu1 ./ -f values-override.yaml -n cran1
    log to console    vDU install complete \n
    [Teardown]    tafssh.Disconnect

Modify vDU Yaml File For NCIR
    [Arguments]    ${saving_tool_path}  ${vdu_index}=0  ${gnb_index}=0         #${vdu_version}  ${vdu_chart_name}=aic-vdu
    [Documentation]  Modify vDU Yaml File For NCIR,Merge yaml files after pacakge 0.390.1221
    ...  author: wei.zuo@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | vdu_version     | yes | vdu_version, e.g, 0.390.1285 |
    ...    | saving_tool_path    | yes | saving_tool_path, e.g, /tmp/TA_Workspace |
    ...    | vdu_index     | no | vdu_index, default value is 0 |
    ...    | gnb_index     | no | gnb_index, default value is 0 |
    ...    | vdu_chart_name | no | vdu_chart_name, default value is aic-vdu |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...   | Modify vDU Yaml File For NCIR | vdu_version=0.390.1284 | saving_tool_path=/tmp/TA_Workspace |
    vDU Cluster Login With Admin  ${vdu_index}  ${gnb_index}
    helm.helm_merge_values_file
    ...  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.vnfs[0].yaml_file}
    ...  ${saving_tool_path}/HelmChart/aic-vdu/values-override.yaml
    [Teardown]    helm.helm_master_close

Create vDU Release For NCIR New
    [Arguments]  ${saving_tool_path}  ${vdu_index}=0  ${vdu_chart_name}=aic-vdu  ${gnb_index}=0
    [Documentation]  Create vDU Release For NCIR New, install vdu.
    ...  author: wei.zuo@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | saving_tool_path    | yes | saving_tool_path, e.g, /tmp/TA_Workspace |
    ...    | vdu_index     | no | vdu_index, default value is 0 |
    ...    | gnb_index     | no | gnb_index, default value is 0 |
    ...    | vdu_chart_name | no | vdu_chart_name, default value is aic-vdu |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...   | Modify vDU Yaml File For NCIR | saving_tool_path=/tmp/TA_Workspace | vdu_chart_name=aic-vdu |
    vDU Cluster Login With Admin  ${vdu_index}  ${gnb_index}
    helm.helm_install_wait_until_ready
    ...  release_name=${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.vnfs[0].name}
    ...  chart_path=${saving_tool_path}/HelmChart/${vdu_chart_name}
    ...  namespace=${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.namespace}
    ...  value_files=${saving_tool_path}/HelmChart/${vdu_chart_name}/values-override.yaml
    [Teardown]    helm.helm_master_close


Check Alarm Should Not contain Fault via seleumin
    [Arguments]  ${FAULT_ID}
    [Documentation]  Check Alarm Should Not contain Fault via seleumin
    ...  just run via selenium, can't run on jenkins
    ...  author: wei.zuo@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | FAULT_ID    | yes | FAULT_ID, e.g, 23 |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...   | Check Alarm Should Not contain Fault via seleumin | FAULT_ID=23 |
    wait until keyword succeeds    1min    10s    Open WEBEM and Login    ${WEBUI_URL}    ${WEBUI_USER}   ${WEBUI_PASSWORD}
    sleep    10s
    @{output_alarms}    svdu.get_active_alarm_info
    log to console    alarm=@{output_alarms}
    Should Not Contain    '@{output_alarms}'    u'Fault ID': u'${FAULT_ID}'
    svdu.logout

Check Alarm Should contain Fault via seleumin
    [Arguments]  ${FAULT_ID}
    [Documentation]  Check Alarm Should contain Fault via seleumin
    ...  author: wei.zuo@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | FAULT_ID    | yes | FAULT_ID, e.g, 23 |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...   | Check Alarm Should contain Fault via seleumin | FAULT_ID=23 |
    wait until keyword succeeds    1min    10s    Open WEBEM and Login    ${WEBUI_URL}    ${WEBUI_USER}   ${WEBUI_PASSWORD}
    sleep    10s
    @{output_alarms}    svdu.get_active_alarm_info
    log to console    alarm=@{output_alarms}
    should contain    '@{output_alarms}'    u'Fault ID': u'${FAULT_ID}'
    svdu.logout

Check History Alarm Should contain Fault via seleumin
    [Arguments]  ${FAULT_ID}
    [Documentation]  Check History Alarm Should contain Fault via seleumin
    ...  author: wei.zuo@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | FAULT_ID    | yes | FAULT_ID, e.g, 23 |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...   | Check History Alarm Should contain Fault via seleumin | FAULT_ID=23 |
    wait until keyword succeeds  1min   10s   Open WEBEM and Login    ${WEBUI_URL}    ${WEBUI_USER}   ${WEBUI_PASSWORD}
    sleep    10s
    ${output_alarms}    svdu.get_history_alarm_info
    log to console    alarm=${output_alarms}
    should contain    '${output_alarms}'    u'Fault ID': u'${FAULT_ID}'
    svdu.logout

Check toggling Alarm Should contain Fault via seleumin
    [Arguments]    ${status}    ${FAULT_ID}        ${flag}      #${TOGGLING_ID}
    [Documentation]  Check toggling Alarm Should contain Fault via seleumin
    ...  author: miao.a.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | status    | yes | status, e.g, Inactive |
    ...    | FAULT_ID    | yes | FAULT_ID, e.g, 4298 |
    ...    | TOGGLING_ID    | yes | TOGGLING_ID, e.g, 4026 |
    ...    | flag    | yes | flag, e.g, true |
    ...
    ...    *RETURN VALUE*
    ...    datetime
    ...
    ...    Example
    ...   | Check toggling Alarm Should contain Fault via seleumin | Inactive | 4298 | 4026 | true |
    ${output_alarms}=  Login WebUI And Get Active Alarm Fault
    log to console    alarm=@{output_alarms}
    run keyword if    ${flag}== True    Should Contain    '@{output_alarms}'    'Fault ID': u'4026'
    run keyword if    ${flag}== False    Should Not Contain    '@{output_alarms}'    'Fault ID': u'4026'
    @{fault_toggle_alarm}    svdu.get_fault_toggling_history
    log to console    alarm=@{fault_toggle_alarm}
    should contain    '@{fault_toggle_alarm}'    'Fault ID': u'${FAULT_ID}'
    should contain   '@{fault_toggle_alarm}'    'State': u'${status}'
    svdu.logout

Login WebUI And Get Active Alarm Fault
    [Documentation]  Login WebUI And Get Alarm Fault by Jenknis
    ...  can be used on jenkins
    ...  author: qixuan.zhang@nokia-sbell.com
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
    vDU WebEM Page Login
    ${vdu_get_active_alarms}    vdu.vdu_get_active_alarms
    Log To Console    Active alarms:
    ${alarms}    Get From Dictionary    ${vdu_get_active_alarms}    alarms
    FOR    ${his_alarm}    IN    @{alarms}
        Log To Console   FaultId: ${his_alarm['fault_id']}; FaultName: ${his_alarm['fault_name']}; AlarmId: ${his_alarm['alarm_id']};
        ...     AlarmName: ${his_alarm['alarm_name']}; AlarmingObject: ${his_alarm['alarming_object']}; Severity: ${his_alarm['severity']}
    END
    [Return]        ${alarms}
    [Teardown]      vdu.disconnect

Login WebUI And Get Historical Alarm Fault
    [Documentation]  Login WebUI And Get Alarm Fault by Jenknis
    ...  author: qixuan.zhang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | OAM_IP | yes | e.g, 10.56.126.210 |
    ...    | USER | yes | e.g, Nemuadmin |
    ...    | PASSWORD | yes | e.g, nemuuser |
    ...
    ...    *RETURN VALUE*
    ...    alarms
    ...
    ...    Example
    ...   | alarms= Login WebUI And Get Historical Alarm Fault by Jenknis | OAM_IP=10.56.125.210 | USER=Nemuadmin | PASSWORD=nemuuser |
    vDU WebEM Page Login
    ${vdu_get_historical_alarms}    vdu.vdu_get_historical_alarms
    Log To Console    Historical alarms:
    ${alarms}    Get From Dictionary    ${vdu_get_historical_alarms}    alarms
    FOR    ${his_alarm}    IN    @{alarms}
        Log To Console   FaultId: ${his_alarm['fault_id']}; FaultName: ${his_alarm['fault_name']}; AlarmId: ${his_alarm['alarm_id']};
        ...     AlarmName: ${his_alarm['alarm_name']}; AlarmingObject: ${his_alarm['alarming_object']}; Severity: ${his_alarm['severity']}
    END
    [Return]        ${alarms}
    [Teardown]      vdu.disconnect

Check Active Alarm Should contain Fault
    [Arguments]     ${FAULT_ID}
    [Documentation]  Check Active Alarm Should contain Fault
    ...  author: qixuan.zhang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...   | Check Active Alarm Should contain Fault | FAULT_ID=23 |
    ${alarm_list}=  Login WebUI And Get Active Alarm Fault
    should contain    '@{alarm_list}'    'fault_id': u'${FAULT_ID}'

Check Active Alarm Should Not contain Fault
    [Arguments]     ${FAULT_ID}
    [Documentation]  Check Active Alarm Should Not contain Fault
    ...  author: qixuan.zhang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...   | Check Active Alarm Should Not contain Fault | FAULT_ID=23 |
    ${alarm_list}=  Login WebUI And Get Active Alarm Fault
    should not contain    '@{alarm_list}'    'fault_id': u'${FAULT_ID}'

Check Historical Alarm Should contain Fault
    [Arguments]     ${FAULT_ID}
    [Documentation]  Check Historical Alarm Should contain Fault
    ...  author: qixuan.zhang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...   | Check Historical Alarm Should contain Fault | FAULT_ID=23 |
    ${alarm_list}=  Login WebUI And Get Historical Alarm Fault
    should contain    '@{alarm_list}'    'fault_id': '${FAULT_ID}'

Check Historical Alarm Should Not contain Fault
    [Arguments]     ${FAULT_ID}
    [Documentation]  Check Historical Alarm Should Not contain Fault
    ...  author: qixuan.zhang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...   | Check Historical Alarm Should Not contain Fault | FAULT_ID=23 |
    ${alarm_list}=  Login WebUI And Get Historical Alarm Fault
    should not contain    '@{alarm_list}'    'fault_id': '${FAULT_ID}'

vDU WebEM Page Login
    [Timeout]    1min
        [Documentation]  vDU WebEM Login
    ...  author: wei.zuo@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...   | vDU WebEM Login |
    run keyword and ignore error    vdu.disconnect
    ${vdu_connection}=    vdu.connect to    host=${OAM_IP}    username=${WEBUI_USER}    password=${WEBUI_PASSWORD}    port=${EMPTY}    secure=True

Collect Logs
    [Arguments]    ${endswith}=${TEST NAME}
    [Documentation]  Collect Logs
    ...  author: miao.a.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | endswith    | yes | endswith, e.g, test name |
    ...
    ...    *RETURN VALUE*
    ...    datetime
    ...
    ...    Example
    ...   | Collect Logs | endswith=testname |
    ${time}=    Get Current Date
    ${datetime}=    Convert Date    ${time}    result_format=%Y%m%d%H%M%S
    ${case_name}=    Convert Case Name    ${endswith}
    Create Directory    ${CURDIR}/../results/${datetime}_${case_name}
    [Return]    ${datetime}

Collect Logs And Teardown
    [Timeout]    60s
    [Documentation]  Collect Logs And Teardown
    ...  author: miao.a.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...   | Collect Logs And Teardown |
    Run Keyword If Test Failed    Collect OAM Logs
    ${case_name}=    Convert Case Name    ${TEST NAME}
    Run Keyword If Test Passed    Run    rm -rf ${CURDIR}/../results/*${case_name}

Collect OAM Logs
    [Documentation]  Collect OAM Logs
    ...  author: miao.a.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...   | Collect OAM Logs |
    csn.Connect To   ${ncir_addr}   ${ncir_tenant}   ${ncir_password}   alias=collect_log
    ${case_name}=    Convert Case Name    ${TEST NAME}
    ${config_info}   csn.Execute   kubectl logs ${G_OAM_PODS_NAME} -c oam >> /home/eituser1/${case_name}.${G_OAM_PODS_NAME}.log
    ...    connection=collect_log

Collect vDU Snapshot
    [Arguments]      ${SNAPSHOT}
    vDU WebEM Page Login
    vdu.Get_Local_Snapshot  ${SNAPSHOT}


Get vDU Host IP
    [Documentation]  Get vDU Host IP
    ...  author: miao.a.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...    host_info_list
    ...
    ...    Example
    ...   | Get vDU Host IP |
    csn.Connect To   ${ncir_addr}   ${ncir_tenant}   ${ncir_password}   alias=vDU_get_host_ip
    ${host_info}   csn.Execute    kubectl exec -it ${G_OAM_PODS_NAME} -c oam -- ifconfig -v oam3 |grep inet    connection=vDU_get_host_ip
    ${host_info_list}    Split String     ${host_info}
    [return]    ${host_info_list[1]}

Check vDU Containers Application Status Should Be As Expected
    [Arguments]  ${pod_name}  ${container_name}  ${vdu_index}=0  ${gnb_index}=0
    [Documentation]  check vdu application status should be as expected
    ...  author: qixuan.zhang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | pod_name | Yes. | the pods name that containers belong to |
    ...	   | container_name | Yes. | the container name |
    ...    *RETURN VALUE*
    ...    None
    vDU Cluster Login With Tenant  ${vdu_index}  ${gnb_index}
    ${app_and_status_dict}=   set variable   ${ALL_CONTAINER_APP.${container_name}}
    ${program_list}=  Get Dictionary Keys  ${app_and_status_dict}
    For  ${program}  IN  @{program_list}
      ${result}=  helm.execute_command_on_master_cluster
    ...   kubectl exec -it ${pod_name} -c ctr-${CLUSTER_NAME}-${container_name} -n ${CLUSTER_NAME} -- netstat -anp|grep -i ${program}
      Should Contain  ${result.stdout}  ${app_and_status_dict.${program}}
    [Teardown]  helm.helm_master_close

####2190 keywords

Modify vDU Chart image
    [Arguments]
    ...   ${value_yaml}=${Download_Local_Dir}/aic-vdu_${timestamp}/aic-vdu/values.yaml
    ...   ${l1_configmap}=${Download_Local_Dir}/aic-vdu_${timestamp}/aic-vdu/templates/l1-configmap.yaml
    [Documentation]  Modify vDU Chart image
    ...  author: yingguo.ying@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | value_yaml    | yes | value_yaml, e.g, values.yaml |
     ...    | l1_configmap    | yes | l1_configmap, e.g, l1-configmap.yaml |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...   | Modify vDU Chart image |
    vDU Cluster Login With Admin
    #make new image with oamfh flag
    tafssh.Execute    mkdir oamfh
    tafssh.Execute    touch oamfh/swconfig.txt; touch oamfh/Dockerfile
    tafssh.Execute    echo -e '245\=2\n252\=2' > oamfh/swconfig.txt
    tafssh.Execute    echo -e 'FROM registry.kube-system.svc.nokia.net:5555/dep/oamfh:${VDU_VERSION}' > oamfh/Dockerfile
    tafssh.Execute    sed -i '$a ADD oamfh/swconfig.txt /opt/nokia/SS_RCPCCSMCU/swconfig.txt' oamfh/Dockerfile
    tafssh.Execute    sed -i '$a RUN chmod +r /opt/nokia/SS_RCPCCSMCU/swconfig.txt' oamfh/Dockerfile
    tafssh.Execute    sed -i '$a RUN sed -i s/run_vdu.sh/run.sh/g /opt/nokia/SS_RCPCCSMCU/AppDef.txt' oamfh/Dockerfile
    tafssh.Execute    sed -i '$a RUN microdnf install sshpass oamfh/Dockerfile
    tafssh.Execute    sed -i '$a ADD config /root/.ssh/ oamfh/Dockerfile
    tafssh.Execute    sed -i '$a RUN chmod 644 /root/.ssh/config oamfh/Dockerfile
    tafssh.Execute    docker build -f ./oamfh/Dockerfile -t registry.kube-system.svc.nokia.net:5555/dep/oamfh:${VDU_VERSION}_${IMAGE_TAG} .
    tafssh.Execute    docker push registry.kube-system.svc.nokia.net:5555/dep/oamfh:${VDU_VERSION}_${IMAGE_TAG}
    ${image_check}    tafssh.Execute    docker image list |grep -i ${VDU_VERSION}_${IMAGE_TAG}
    Should Contain    ${image_check}    ${VDU_VERSION}_${IMAGE_TAG}
    # replace 4th matched line :a;N;$!ba;
    tafssh.Execute    sed -i ':a;N;$!ba;s/${VDU_VERSION}/${VDU_VERSION}_${IMAGE_TAG}/4' ${value_yaml}
    ${image}    tafssh.Execute    cat ${value_yaml} |grep -i ${VDU_VERSION}_${IMAGE_TAG}
    Should Contain    ${image}    ${VDU_VERSION}_${IMAGE_TAG}
    tafssh.Execute    sed -i '/CCSRT_CONTAINER_TYPE: "L1"/a\\\ \ FHP_RECIEVE_WIN_ENABLE: "FALSE"' ${l1_configmap}
    [Teardown]    helm.helm_master_close

Deploy vDU with flag
    [Arguments]
    ...   ${chart_path}=${Download_Local_Dir}/aic-vdu_${timestamp}/aic-vdu
    ...   ${ns}=${tl.gnbs[0].dus[0].cloud_deployment.cloud_hosting.namespace}
    [Documentation]  Deploy vDU with flag
    ...  author: yingguo.ying@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | chart_path    | yes | chart_path, e.g, HelmChart/aic-vdu |
    ...    | ns    | yes | namespace, e.g, eituser1 |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...   | Deploy vDU with flag |
    vDU Cluster Login With Admin
    tafssh.Execute    helm install ${chart_path}/ -f ${chart_path}/values-override.yaml --name ${G_VDU_NAME} --namespace ${ns}
#    Sleep    90s
    wait until keyword succeeds    2min    30s    vDU Pod Status Should Be As Expected    Running
    [Teardown]    helm.helm_master_close


Check RU upgrade successfully
    [Documentation]  Check RU upgrade successfully
    ...  author: yingguo.ying@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...   | Check RU upgrade successfully |
    vDU Cluster Login With Tenant
    ${command}=  catenate  SEPARATOR=  kubectl exec -it ${G_OAM_PODS_NAME} -c ctr-${CLUSTER_NAME}-oamfh -n ${CLUSTER_NAME} -- cat /mnt/services/
    ...     SS_OAMDU/OAMFH/working_dir/fileHost/RegisteredRU.json
    ${IsUpgrade}    tafssh.Execute   ${command}
    Should Contain    ${IsUpgrade}    "ruUpgradeStatus" : "successful"
    [Teardown]    helm.helm_master_close

Collect Container Logs
    [Arguments]    ${pod_name}    ${container_name}
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
    wait until keyword succeeds  2min   60s   tafssh.Execute
    ...     kubectl logs ${pod_name} -c ${container_name} -n ${CLUSTER_NAME} > /home/${G_USER}/${G_VDU_NAME}.${container_name}.log

Check RMOD Status
    [Documentation]  Check RMOD Status
    ...  author: yingguo.ying@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...   | Check RMOD Status |
    Collect Container Logs    ${G_OAM_PODS_NAME}   ctr-${CLUSTER_NAME}-oamfh
    ${status} =   tafssh.execute    cat /home/${G_USER}/${G_VDU_NAME}.ctr-${CLUSTER_NAME}-oamfh.log |grep -i 'operationalState: 1 - Enabled'
    Should Contain    ${status}    RMOD_L-1 | operationalState: 1 - Enabled

Check F1 interface and x2 connection
    [Documentation]  Check F1 interface and x2 connection
    ...  author: yingguo.ying@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...   | Check F1 interface and x2 connection |
    Collect Container Logs    ${G_CPRT_PODS_NAME}    ctr-${CLUSTER_NAME}-cprt
    ${F1CLinkStatusDU_status} =   tafssh.execute
    ...     cat /home/${G_USER}/${G_VDU_NAME}.ctr-${CLUSTER_NAME}-cprt.log |grep -i 'F1 setup successfully'
    Should Contain    ${F1CLinkStatusDU_status}    F1 setup successfully
    ${X2LinkStatusDU_status} =   tafssh.execute
    ...     cat /home/${G_USER}/${G_VDU_NAME}.ctr-${CLUSTER_NAME}-cprt.log |grep -i 'GnbCuConfigurationUpdate'
    Should Contain    ${X2LinkStatusDU_status}       f1ap::GnbCuConfigurationUpdateAck to CU

Check Carrier Configuration
    [Documentation]  Check Carrier Configuration
    ...  author: yingguo.ying@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...   | Check Carrier Configuration |
    Collect Container Logs    ${G_OAM_PODS_NAME}    ctr-${CLUSTER_NAME}-oamfh
    ${localAddress} =   tafssh.execute
    ...     cat /home/${G_USER}/${G_VDU_NAME}.ctr-${CLUSTER_NAME}-oamfh.log |grep -i '<parameterName>localAddress</parameterName>'
    Should Contain    ${localAddress}    <newValue>0</newValue>    <newValue>1</newValue>    <newValue>8</newValue>
    ...    <newValue>9</newValue>
    ${localAddressMask} =   tafssh.execute
    ...     cat /home/${G_USER}/${G_VDU_NAME}.ctr-${CLUSTER_NAME}-oamfh.log |grep -i '<parameterName>localAddressMask</parameterName>'
    Should Contain    ${localAddressMask}    <newValue>16383</newValue>
    ${supportedSectionType} =   tafssh.execute    cat /home/${G_USER}/${G_VDU_NAME}.ctr-${CLUSTER_NAME}-oamfh.log |grep -i 'supportedSectionType'
    Should Contain    ${supportedSectionType}    <sectionType>1</sectionType>    <sectionType>3</sectionType>
    ${TxArrayCarrier} =   tafssh.execute    cat /home/${G_USER}/${G_VDU_NAME}.ctr-${CLUSTER_NAME}-oamfh.log |grep -i 'defaultSubcarrierSpacing'
    Should Contain    ${TxArrayCarrier}    <newValue>KHZ_15</newValue>
    ...     <parameterName>fftSamplingOffset</parameterName><newValue>32</newValue>
    ...    <parameterName>cyclicPrefix</parameterName><newValue>NORMAL_CP</newValue>
    ${sfnOffsets} =   tafssh.execute
    ...     cat /home/${G_USER}/${G_VDU_NAME}.ctr-${CLUSTER_NAME}-oamfh.log |grep -i '<parameterName>sfnOffsets</parameterName>'
    Should Contain    ${sfnOffsets}    <newValue><alpha>0</alpha><beta>0</beta></newValue>
    ${remoteAddress} =   tafssh.execute
    ...     cat /home/${G_USER}/${G_VDU_NAME}.ctr-${CLUSTER_NAME}-oamfh.log |grep -i '<parameterName>remoteAddress</parameterName>'
    Should Contain    ${remoteAddress}    <newValue>0</newValue>    <newValue>1</newValue>    <newValue>8</newValue>
    ...    <newValue>9</newValue>
    ${format} =   tafssh.execute
    ...     cat /home/${G_USER}/${G_VDU_NAME}.ctr-${CLUSTER_NAME}-oamfh.log |grep -i '<parameterName>format</parameterName>'
    Should Contain    ${format}    <newValue>IQ16</newValue>
    ${carrier_status} =   tafssh.execute
    ...     cat /home/${G_USER}/${G_VDU_NAME}.ctr-${CLUSTER_NAME}-oamfh.log |grep -i '<parameterName>active</parameterName>'
    Should Contain    ${carrier_status}    <newValue>TRUE</newValue>

Check RF Power for VDU
    [Arguments]  ${ru_index}=1  ${type}=AHCA
    [Documentation]  Check RF Power for VDU
    ...  author: yingguo.ying@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...   | Check RF Power for VDU |
    Connect to Radio Unit    alias=default  ru_index=${ru_index}
    ${output0}   run keyword if  """${type}"""=="""AHCA"""    issh.Execute    command=/usr/bin/dapd -pwr 0    alias=default
    ...     ELSE    issh.Execute    command=/usr/bin/dapd -pwr 2    alias=default
    ${output1}   run keyword if  """${type}"""=="""AHCA"""    issh.Execute    command=/usr/bin/dapd -pwr 1    alias=default
    ...     ELSE    issh.Execute    command=/usr/bin/dapd -pwr 3    alias=default
    log to console      \n${output0}
    log to console      \n${output1}
    should not contain    ${output0}    =0.0
    should not contain    ${output0}    -inf
    should not contain    ${output1}    =0.0
    should not contain    ${output1}    -inf
    [Teardown]    issh.Disconnect

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
    vDU Cluster Login With Admin
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
    wait until keyword succeeds    30min    30s     Check RU upgrade successfully

Add Route and F1 Setup
    [Arguments]     ${VCU_DESTINATION_IP}   ${F1_GW}
    [Documentation]  Add Route and F1 Setup
    ...  author: qixuan.zhang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | VCU_DESTINATION_IP  | yes | VCU_DESTINATION_IP, e.g, 10.110.158.0/24 |
    ...    | F1_GW | yes | F1_GW, e.g, 10.56.125.193 |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Add Route and F1 Setup | VCU_DESTINATION_IP=10.110.158.0/24 | F1_GW=10.56.125.193 |
    log to console    Add Route and F1 Setup
    vDU Cluster Login With Tenant
    tafssh.Execute    kubectl exec -it ${G_OAM_PODS_NAME} -c ctr-${CLUSTER_NAME}-nwmgmt -- ip route add ${VCU_DESTINATION_IP} via ${F1_GW}
    ${ip_route}    tafssh.Execute    kubectl exec -it ${G_OAM_PODS_NAME} -c ctr-${CLUSTER_NAME}-nwmgmt -- ip route
    run keyword and ignore error    should Contain   ${ip_route}     ${VCU_DESTINATION_IP} via ${F1_GW}

Check cell onair
    [Arguments]  ${rf_type}=AHCA
    [Documentation]  Check cell onair
    ...  author: qixuan.zhang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...   | Check cell onair |
    log to console    Check Cell onair
    Check RF Power for vDU      type=${rf_type}

Check multicell onair
    [Arguments]  ${cell_num}=2
    [Documentation]  Check cell onair
    ...  author: qixuan.zhang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...   | Check cell onair |
    log to console    Check Cell onair
    FOR    ${ru_index}    IN RANGE   1   ${cell_num}+1
       Check RF Power for vDU     ru_index=${ru_index}
    END

Open Browser
    [Arguments]     ${URL}
    [Documentation]  Open Browser
    ...  author: qixuan.zhang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | URL| yes | e.g, https://10.56.125.120 |
    ...
    ...    *RETURN VALUE*
    ...    Parameter Value
    ...
    ...    Example
    ...    | Open Browser | URL=https://10.56.125.120 |
    ${chrome options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys, selenium.webdriver
    Call Method    ${chrome options}    add_argument    --ignore-certificate-errors
    Call Method    ${chrome options}    add_argument    --window-size\=1900,1200
    Call Method    ${chrome options}    add_argument    --headless
    Call Method    ${chrome options}    add_argument    --no-sandbox
    Create Webdriver    Chrome    chrome_options=${chrome options}
    Goto    ${URL}

Open WEBEM and Login
    [Arguments]     ${URL}    ${USER}   ${PASSWORD}
    [Documentation]  Open WEBEM and Login
    ...  author: qixuan.zhang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | URL  | yes | e.g, 10.110.125.210 |
    ...    | USER | yes | e.g, Nemuadmin |
    ...    | PASSWORD | yes | e.g, nemuuser |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Open WEBEM and Login | URL=10.110.125.210 | USER=Nemuadmin | PASSWORD=nemuuser |
    Open Browser    ${URL}
    Wait Until Element Is Visible
    ...     xpath=/html/body/vdu-webem-root/div/div/webem-login-page/div/div[1]/p-card/div/div[2]/div/form/div[1]/input
    input text
    ...     xpath=/html/body/vdu-webem-root/div/div/webem-login-page/div/div[1]/p-card/div/div[2]/div/form/div[1]/input  ${USER}
    sleep   3s
    input text      xpath=//div[2]/div/input     ${PASSWORD}
    sleep   3s
    Click Element   xpath=//*[@id="login-button"]/button
    sleep   3s
    run keyword and ignore error  Wait Until Element Is Visible
    ...     xpath=/html/body/p-dynamicdialog/div/div/div[2]/ui-webem-legal-notice-modal/div[2]/p-footer/ui-webem-button[1]/p-button
    run keyword and ignore error  Click Element
    ...     xpath=/html/body/p-dynamicdialog/div/div/div[2]/ui-webem-legal-notice-modal/div[2]/p-footer/ui-webem-button[1]/p-button

Delete F1 route
    [Documentation]  Delete F1 route
    ...  author: xin.6.wang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...   | Delete F1 route |
    vDU Cluster Login With Tenant
    tafssh.Execute
    ...     kubectl exec -it ${G_CPRT_PODS_NAME} -c ctr-eit1-nwmgmt -n eit1 -- ip route delete ${VCU_DESTINATION_IP} via ${F1_GW}

Check F1 status
    [Documentation]  Check F1 status
    ...  author: xin.6.wang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...   | Check F1 status |
    vDU Cluster Login With Tenant
    ${F1_status} =   tafssh.execute
    ...  kubectl exec -it ${G_CPRT_PODS_NAME} -c ctr-eit1-cprt -n eit1 -- cat tmp/startup_DEFAULT.log | grep -i 'F1 setup'
    Should Contain    ${F1_status}    F1 setup successfully

Check VDU restart times
    [Arguments]  ${Restart_Time}
    [Documentation]  Check VDU restart times
    ...  author: xin.6.wang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | Restart_Time | yes | e.g, |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...   | Check VDU restart times |
    vDU Cluster Login With Tenant
    ${oam_json}    tafssh.Execute
    ...  kubectl exec -it ${G_OAM_PODS_NAME} -c ctr-eit1-oam -n eit1 -- cat /mnt/services/SS_OAM/OAMAGENT/recoveryCounter.json | grep "retries"
    Should Contain    ${oam_json}        "retries" : ${Restart_Time}

Get Parameter Value
    [Arguments]     ${Abbreviation}
    [Documentation]  Get Parameter Value
    ...  author: qixuan.zhang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | Abbreviation | yes | e.g, miNrEcpriUpFCp |
    ...
    ...    *RETURN VALUE*
    ...    Parameter Value
    ...
    ...    Example
    ...    | Parameter Value= | Get Parameter Value | Abbreviation=miNrEcpriUpFCp |
    ${xpath}=  catenate  SEPARATOR=   xpath=/html/body/vdu-webem-root/div/div/webem-single-column-layout/webem-page-layout/div/
    ...     webem-page-header/div/webem-quick-menu/ui-webem-routed-menu/ui-webem-button[3]
    Wait Until Element Is Visible   ${xpath}
    sleep   3s
    Click Element   ${xpath}
    Wait Until Element Is Visible   xpath=//*[@id="parameter-search-input"]/div/input
    sleep   3s
    input text      xpath=//*[@id="parameter-search-input"]/div/input       ${Abbreviation}
    Click Element   xpath=//*[@id="parameter-search-input"]/div/div
    Wait Until Element Is Visible   xpath=//*[@id="global-search-table"]/div[2]/p-treetable/div/div[1]/table/tbody/tr/td[4]/div
    ${Parameter_Value}=   get text  xpath=//*[@id="global-search-table"]/div[2]/p-treetable/div/div[1]/table/tbody/tr/td[4]/div
    sleep   3s
    [Return]    ${Parameter_Value}

Do WA Before Deploy vDU
    [Arguments]     ${vDU_VERSION}
    [Documentation]  Do WA Before Deploy vDU
    ...  author: qixuan.zhang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | vDU_VERSION | yes | 0.390.1980 |
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Do WA Before Deploy vDU | vDU_VERSION=0.390.1980 |
    log to console    Do WA Before Deploy vDU
    vDU Cluster Login With Admin
    Set Suite Variable  ${DOWNLOAD_LINK}  https://artifactory-hz1.int.net.nokia.com/artifactory/mnp5g-central-public-remote/System_Release
    tafssh.Execute    command=cd /home/cbis-admin/; wget ${DOWNLOAD_LINK}/${vDU_VERSION}/artifacts/aicClusterResource.tgz
    tafssh.Execute    command=cd /home/cbis-admin/; tar -xzf aicClusterResource.tgz
    tafssh.Execute    command=cd /home/cbis-admin/aicClusterResource/; chmod +x aicClusterResource.sh
#    tafssh.Execute    command=cd /home/cbis-admin/aicClusterResource/; ./aicClusterResource.sh pv delete -n cran1
    tafssh.Execute    command=rm -r /home/cbis-admin/aicClusterResource; rm aicClusterResource.tgz
#    tafssh.Execute    command=cd /home/cbis-admin/; ./clear_resource.sh
    sleep   10s
    [Teardown]    helm.helm_master_close

Find Route Info
    [Arguments]   ${MO}  ${search_value1}     ${basic_para1}        #${search_value2}
    [Documentation]  Find Route Info
    ...  author: qixuan.zhang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | MO | yes | MRBTS-0/TNLSVC-1/TNL-1/IPNO-1/IPRT-1/IPRT_R-1 |
    ...    | search_value1 | yes | 10.0.85.170 |
    ...    | search_value2 | yes | 10.1.1.1 |
    ...    | basic_para1 | yes | destIpAddr |
    ...    | basic_para2 | yes | gateway |
    ...    *RETURN VALUE*
    ...    route_count
    ...
    ...    Example
    ...    | ${count} | Find Route Info | MRBTS-0/TNLSVC-1/TNL-1/IPNO-1/IPRT-1/IPRT_R-1 | 10.0.85.170 | 10.1.1.1 | destIpAddr | gateway |
    ENDFor     ${route_count}     IN RANGE     0   10
       ${value1}   Get VDU Parameter Value Online    ${MO}   forwardingEntries/${route_count}/${basic_para1}
#       ${value2}   Get VDU Parameter Value Online    ${MO}   forwardingEntries/${route_count}/${basic_para2}
#       run keyword if    "${value1}"=="${search_value1}"   Exit For Loop If   "${value2}"=="${search_value2}"
       Exit For Loop If   "${value1}"=="${search_value1}"
       run keyword if      ${route_count}==10      fail
    END
    [Return]       ${route_count}

Activate Delta Plan Without Saving
    [Arguments]  ${plan_id}   ${force_reset}=${True}   ${auto_lock_cells}=${True}   ${wait_vdu_up}=${False}   ${timeout}=60
    [Documentation]  Activate Delta Plan Without Saving
    ...  author: qixuan.zhang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | plan_id | yes | dp_00000000 |
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | ${plan_id} | ${action_id} | Generate delta plan | DELTA-PLAN-1 |
    ...    | Validate Delta Plan By REST | ${plan_id} |
    ...    | Activate Delta Plan Without Saving | ${plan_id} |
    ${out}   vdu.activate_delta_plan   delta_plan_id=${plan_id}
     ...   force_reset=${force_reset}   auto_lock_cells=${auto_lock_cells}   timeout=${timeout}
    Activate Delta Plan Status Should Be Successful   operation_id=${out['id']}   plan_id=${plan_id}
    run keyword if  "${wait_vdu_up}"=="${True}"   wait until keyword succeeds   600  20   OAM Precondition Cell Should Be Onair

Check parameter value via SCF
    [Arguments]     ${MO}     ${para_name}     ${SCF}
    [Documentation]  Check parameter value via SCF
    ...  author: qixuan.zhang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | MO | yes | MRBTS-0/TNLSVC-1/TNL-1/IPNO-1/IPRT-1/IPRT_R-1 |
    ...    | para_name | yes | underLyingInterface |
    ...    | SCF | yes | scf path |
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Check parameter value via SCF | MRBTS-0/TNLSVC-1/TNL-1/ETHSVC-1/ETHLK-1 | underLyingInterface | ${SCF_PATH} |
    vDU Rest Login
    ${para_value}     Get VDU Parameter Value Online       ${MO}     ${para_name}
    ${MO_content}   Get MO Content      ${SCF}    ${MO}
    log to console     ${MO_content}
    should contain     ${MO_content}    ${para_value}
    [Teardown]  vDU Rest Logout

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

Check TDD RMOD Status
    [Documentation]  Check RMOD Status
    ...  author: lingjiao.feng@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...   | Check TDD RMOD Status |
    Collect Container Logs    ${G_OAM_PODS_NAME}   ctr-${CLUSTER_NAME}-oamfh
    ${status} =   tafssh.execute    cat /home/${G_USER}/${G_VDU_NAME}.ctr-${CLUSTER_NAME}-oamfh.log |grep -i 'operationalState'
    Should Contain    ${status}    - - -      "operationalState" : "enabled"

Check Parameters Modified Successfully
    [Arguments]  ${mo_dn}   ${Abbreviation}   ${check_value}
    [Documentation]  Check parameters modifiction
    ...  author: miao.a.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...   | Check parameters detail info |
    ${paramters_value}   Get VDU Parameter Value Online      ${mo_dn}      ${Abbreviation}
    should be equal     ${paramters_value}     ${check_value}

Download File From VDU via OCP
    [Arguments]     ${pod_name}   ${container_name}   ${file_path}  ${file_name}  ${store_path}     #${vdu_index}
    [Documentation]    download file from vDU specifical container to ute
    ...    *AUTHOR* luofei.tu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    21.07.2021,qixuan.zhang@nokia-sbell.com, create
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | vdu_index | yes | the vdu index is specified in init.py |
    ...    | pod_name | yes | like oam, up |
    ...    | container_name | yes | oam, oamfh |
    ...    | file_path | yes | your need download file path in vDU |
    ...    | store_path | yes | the target file you need download |
    ...    *RETURN VALUE*
    ...    none
    ...    Example
    ...    |Download file from vDU | index=0 | pod_name=oam | container_name=oamfh | file_path=/tmp |  file_name=start.log
    ...    |stroe_path=/home/ute
    tafssh.Reset_Cache
#    ${alias}     Connect To VDU Node    pod_abbr=${pod_name}  master_alias=MASTER   node_alias=NODE
    vDU Cluster Login With Admin
    ${command}=     catenate  SEPARATOR=    kubectl cp -n ${CLUSTER_NAME} -c ${container_name} po-${CLUSTER_NAME}-${pod_name}-0:
    ...     ${file_path}/${file_name} /home/${G_USER}/${file_name} connection=NODE timeout=5
    tafssh.Execute       ${command}
    tafssh.File_Exists     /home/${G_USER}/${file_name}
    tafssh.Execute     command=sudo chmod 777 /home/${G_USER}/${file_name}       timeout=5
    tafssh.Download_File   remote_path=/home/${G_USER}/${file_name}    local_path=${store_path}/${file_name}
    tafssh.Reset_Cache

Ecpri_ru_power_check
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

    vDU Cluster Login With Tenant
    ${command}=  catenate    kubectl exec -n ${CLUSTER_NAME} ${G_OAMFH_PODS_NAME} -c ctr-${CLUSTER_NAME}-oamfh -- bash
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
        ${made}=    set variable
    ...     "ssh -q -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@${internal_ru_ip} /usr/bin/dapd -pwr 0"
        ${power}=    tafssh.execute
    ...    sshpass -p ${serviceuser_psw} ssh -q -o UserKnownHostsFile\=/dev/null -o StrictHostKeyChecking\=no serviceuser@${ru_ip} ${made}
        log to console    ${power}
        should not contain    ${power}    0.0
        should not contain    ${power}    -inf
        should not contain    ${power}    Fail
        should not contain    ${power}    Aborted
        should not contain    ${power}    exception
    END
    tafssh.Execute    command=sudo ip link del rutest.295 type vlan

Copy Existing Object
    [Arguments]  ${object_name}     ${object_class_name}    ${plan_name}    ${object_distinguished_name}
    ...    ${copy_object_with_subtree}=${True}      ${id_value}=None     ${timeout}=60
    [Documentation]  Copy Existing Object
    ...  author: qixuan.zhang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | object_name      | yes  | where object will be added in |
    ...    | object_class_name| yes  | name of object class |
    ...    | plan_name        | yes  | plan name that object to be copied |
    ...    | object_distinguished_name | yes  | object_distinguished_name |
    ...    | copy_object_with_subtree | no  | Boolean , copying subtree elements |
    ...    | id_value | no  | default is None |
    ...    | timeout | no  | timeout for the element be available to click |
    ...    *RETURN VALUE*
    ...    none
    ...
    ...    Example
    ...    |Copy Existing Object | object_name=MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1 | object_class_name=LCELNR |plan_name=DELTA-PLAN-1
    ...    |object_distinguished_name=MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1 | copy_object_with_subtree=${True} | id_value=2 |
    svdu.login      url=${WEBUI_URL}    username=${WEBUI_USER}   password=${WEBUI_PASSWORD}   version=${WEBUI_VERSION}
    svdu.choose_plan    plan_name=DELTA-PLAN-1
    ${timeout}   convert to integer  ${timeout}
    svdu.copy_object     ${object_name}     ${object_class_name}    ${plan_name}    ${object_distinguished_name}
    ...    ${copy_object_with_subtree}     ${id_value}     ${timeout}
    [Teardown]  svdu.logout

Get TNL match relationship
    [Documentation]  Get TNL match relationship
    ...  author: qixuan.zhang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    *RETURN VALUE*
    ...    none
    ...
    ...    Example
    ...    | Get TNL match relationship |
    ${TNL-4_match}   Get VDU Parameter Value Online      MRBTS-${MRBTS_ID}/TNLSVC-1/TNL-4/IPNO-1/IPIF-1/IPADDRESSV4-1    uniqueIpAddressIdentifier
    ${TNL_OAM}      run keyword if  """${TNL-4_match}"""=="""certman-server oam"""  set variable      TNL-4
    run keyword if  """${TNL-4_match}"""=="""certman-server oam"""  set test variable   ${TNL_OAM}
    ${TNL_CPRT}     run keyword if  """${TNL-4_match}"""=="""F1-C"""                set variable      TNL-4
    run keyword if  """${TNL-4_match}"""=="""F1-C"""    set test variable   ${TNL_CPRT}
    ${TNL_UP}       run keyword if  """${TNL-4_match}"""=="""F1-U"""                set variable      TNL-4
    run keyword if  """${TNL-4_match}"""=="""F1-U"""    set test variable   ${TNL_UP}
    ${TNL-5_match}   Get VDU Parameter Value Online      MRBTS-${MRBTS_ID}/TNLSVC-1/TNL-5/IPNO-1/IPIF-1/IPADDRESSV4-1    uniqueIpAddressIdentifier
    ${TNL_OAM}      run keyword if  """${TNL-5_match}"""=="""certman-server oam"""  set variable      TNL-5
    run keyword if  """${TNL-5_match}"""=="""certman-server oam"""  set test variable   ${TNL_OAM}
    ${TNL_CPRT}     run keyword if  """${TNL-5_match}"""=="""F1-C"""                set variable      TNL-5
    run keyword if  """${TNL-5_match}"""=="""F1-C"""    set test variable   ${TNL_CPRT}
    ${TNL_UP}       run keyword if  """${TNL-5_match}"""=="""F1-U"""                set variable      TNL-5
    run keyword if  """${TNL-5_match}"""=="""F1-U"""    set test variable   ${TNL_UP}
    ${TNL-6_match}   Get VDU Parameter Value Online      MRBTS-${MRBTS_ID}/TNLSVC-1/TNL-6/IPNO-1/IPIF-1/IPADDRESSV4-1    uniqueIpAddressIdentifier
    ${TNL_OAM}      run keyword if  """${TNL-6_match}"""=="""certman-server oam"""  set variable      TNL-6
    run keyword if  """${TNL-6_match}"""=="""certman-server oam"""  set test variable   ${TNL_OAM}
    ${TNL_CPRT}     run keyword if  """${TNL-6_match}"""=="""F1-C"""                set variable      TNL-6
    run keyword if  """${TNL-6_match}"""=="""F1-C"""    set test variable   ${TNL_CPRT}
    ${TNL_UP}       run keyword if  """${TNL-6_match}"""=="""F1-U"""                set variable      TNL-6
    run keyword if  """${TNL-6_match}"""=="""F1-U"""    set test variable   ${TNL_UP}

Get RMOD Status
    [Documentation]  Get TNL match relationship
    ...  author: qixuan.zhang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    *RETURN VALUE*
    ...    list of dicts with cells info with keys
    ...
    ...    Example
    ...    | @{ru_status} | Get RMOD Status |
    vDU Rest Login
    ${rmod_status}=     vdu.get_rmods_status
    log to console  ${rmod_status}
    [Return]    ${rmod_status}
    [Teardown]  vDU Rest Logout

Check RU Enabled
    [Documentation]  Get TNL match relationship
    ...  author: qixuan.zhang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    *RETURN VALUE*
    ...    none
    ...
    ...    Example
    ...    | Check RU Enabled |
    @{ru_status}=   Get RMOD Status
    #&{ru_status}=   set variable    @{ru_status}[0]
    should be equal  ${ru_status.operational_state}    enabled

Check RU Disabled
    [Documentation]  Get TNL match relationship
    ...  author: qixuan.zhang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    *RETURN VALUE*
    ...    none
    ...
    ...    Example
    ...    | Check RU Disabled |
    @{ru_status}=   Get RMOD Status
    #&{ru_status}=   set variable    @{ru_status}[0]
    should be equal  ${ru_status.operational_state}    disabled
