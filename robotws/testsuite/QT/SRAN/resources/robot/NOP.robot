*** Settings ***
Documentation     This is a test suite for NOPs installation
Library           OperatingSystem
Library           Collections
Library           Telnet
Library           String
Library           taf.transport.ssh.interface.ssh            WITH NAME    ssh
Library           ${CURDIR}/../python/nop.py

*** Keywords ***
NOP Update Suite Setup
    Log To Console      =========================== [ SUITE SETUP ] ===========================\n
    Create Directory    ${OUTPUT DIR}/Full_Run
    Common variables Setup
    ${tl.tl_cloud_topology}    Get Variable Value    ${tl.tl_cloud_topology}    NotKnown
    Log To Console      \t- TestLine: ${tl.tl_cloud_topology}
    IF    not ${is_LTE}    Log To Console      \t- CU k8s info: ${CU_k8s_addr}/${CU_k8s_user}/${CU_k8s_pwd} : ${CU_tenant}
    Log To Console      \t- DU k8s info: ${DU_k8s_addr}/${DU_k8s_user}/${DU_k8s_pwd} : ${DU_tenant}
    ${pre_flag}    Set Variable If
    ...   'vDU' in '${STREAM}'    vdu
    ...   'VDU' in '${STREAM}'    vdu
    ...    'CU' in '${STREAM}'    vcu
    ${vCU_build_flag}    Set Variable If    'CU' in '${STREAM}'    True    False
    ${vDU_build_flag}    Set Variable If
    ...   'vDU' in '${STREAM}'    True
    ...   'VDU' in '${STREAM}'    True
    ...   False
    ${par_prefix}   Set Variable If
    ...   'vDU' in '${STREAM}'    DU
    ...   'VDU' in '${STREAM}'    DU
    ...    'CU' in '${STREAM}'    CU
    Set Suite Variable     ${par_prefix}
    Set Suite Variable      ${pre_flag}
    Set Suite Variable    ${vCU_build_flag}
    Set Suite Variable    ${vDU_build_flag}
    Get controller host name
    Wait Until Keyword Succeeds    5min   30s    OE Authentication    par_prefix=${par_prefix}
    Log To Console      \n========================= [ SUITE SETUP DOWN ] =========================
    Log To Console      ------------------------------------------------------------------------

NOP Update Suite Teardown
    Log To Console     ========================== [ SUITE TEARDOWN ] ==========================\n
    Log To Console       \t- - - Start to check if TLs need to be turned off - - -
    Create File        ${OUTPUT_DIR}/data_after_test.txt    ${EMPTY}
    ${offline}    Get Variable Value     ${offline}    ${false}
    ${comment}    Get Variable Value     ${comment}    ${EMPTY}
    Append To File    ${OUTPUT_DIR}/data_after_test.txt    offline=${offline}\ncomment=${comment}
    Log To Console      \n========================== [ SUITE TEARDOWN DONE ] =====================
    Log To Console      ----------------------------------------------------------------------

Run wget command and print the output
    [Arguments]  ${download_url}  ${nop_name}    ${VM_download_dir}
    ${VM_download_dir_exists}    Run Keyword And Return Status    Directory Should Exist    ${VM_download_dir}
    Run Keyword If    not ${VM_download_dir_exists}    Create Directory    ${VM_download_dir}
    Run     cd ${VM_download_dir} && wget ${download_url} > ${VM_download_dir}/${nop_name}_download.log 2>&1
    FOR    ${_}    IN RANGE    11
        ${console_log}    Run    command=tail -n 5 ${VM_download_dir}/${nop_name}_download.log
        Log To Console      * * * * * * * * * * * * * * * Download Ongoing* * * * * * * * * * * * * * * * \n\n ${console_log}
        ${check_error}    Run
        ...    cat ${VM_download_dir}/${nop_name}_download.log|grep -E "wget: error while loading|command not found|Connection refused"
        IF    ${{len($check_error)}}>0
            Fail    wget not installed in VM!!!
        END
        ${check_download_finished_str}    Run
        ...    cat ${VM_download_dir}/${nop_name}_download.log|grep -E 'saved|FINISHED'
        IF    ${{len($check_download_finished_str)}}>0
            set test variable    ${check_download_finished}    ${True}
            RETURN
        END
        IF    "ERROR" in """${console_log}"""
            FAIL   Download error!!!
        END
        BuiltIn.Sleep           45s
    END
    [Teardown]  Run    rm ${VM_download_dir}/${nop_name}_download.log

Download and Uncompress NOP file
    [Arguments]    ${nop_file}    ${nop_name}    ${VM_download_dir}=~/Downloads
    ssh.Connect to    hostname=${${par_prefix}_k8s_addr}
    ...               username=${${par_prefix}_k8s_user}
    ...               password=${${par_prefix}_k8s_pwd}
    ...               alias=RM_alias
    ssh.execute    command=rm -rf /tmp/${nop_name}/;mkdir -p /tmp/${nop_name}   connection=RM_alias
    Run    rm ${VM_download_dir}/${nop_name}*zip
    ${target_path_nop}=    Set Variable    /tmp/${nop_name}
    Set Suite Variable    ${target_path_nop}
    ${download_url}=    Catenate    SEPARATOR=/  https://artifactory-espoo1.ext.net.nokia.com/artifactory/rcp-infra-local/${nop_name}
    ...    ${nop_file}
    Log To Console    \n---> Start to download zip pkg
    Run wget command and print the output    ${download_url}    ${nop_name}    ${VM_download_dir}
    Run     ssh-keyscan ${${par_prefix}_k8s_addr} >> ~/.ssh/known_hosts
    ${scp_cmd}    Catenate
    ...    sshpass -p ${${par_prefix}_k8s_pwd} scp ${VM_download_dir}/${nop_file}
    ...    ${${par_prefix}_k8s_user}@${${par_prefix}_k8s_addr}:${target_path_nop}/${nop_file}
    Run    ${scp_cmd}
    ${check_download_finished}    Get Variable Value    ${check_download_finished}    ${False}
    Run Keyword If    ${check_download_finished}    Log To Console   ---> Download zip pkg done and start to uncompress pkg.
    ...       ELSE    Run Keywords
    ...               Set Suite Variable    ${comment}    ${nop_file} pkg download failed
    ...        AND    Fail    ${nop_file} pkg preparation failed, test will be interrupted!
    FOR    ${index}    IN RANGE    0    2
        ${uncompress_zip}=    ssh.execute    command=cd ${target_path_nop}&&unzip -o ${nop_file}    connection=RM_alias
        ${res_bool}=    Run Keyword And Return Status
        ...       Should Not Contain Any    ${uncompress_zip}    fail    error    command not found
        Run Keyword If    '${res_bool}' == 'False'    Run Keywords
        ...                                           Set Suite Variable    ${comment}    Unzip ${nop_file} failed
        ...        AND                                Fail    ${nop_file} pkg preparation failed, test will be interrupted!
    END
    ${output}=  ssh.execute  command=ls ${target_path_nop}/HelmChart  connection=RM_alias
    @{tmp_nop_file}=    Get Regexp Matches   ${output}   ${nop_name}-\\w.*.tgz
    ${tmp_nop_file_str}=    Convert To String    ${tmp_nop_file[0]}
    ${nop_tgz_name}=    Strip String    ${tmp_nop_file_str}
    Set Suite Variable    ${nop_tgz_name}

Check If NOP Installed
    [Arguments]   ${nop_namespace}
    ${achieved_namespace}=   ssh.execute  command=kubectl get namespaces ${nop_namespace}  connection=RM_alias
    ${is_nop_namespace_created}=   Run Keyword And Return Status
    ...    Should Not Contain    ${achieved_namespace}   Error from server (NotFound)
    Run Keyword If    not ${is_nop_namespace_created}
    ...    ssh.execute  command=kubectl create namespace ${nop_namespace}  connection=RM_alias
    ${res}=  ssh.execute  command=helm list -a -A -n ${nop_namespace}|grep ${nop_namespace}  connection=RM_alias
    ${check_nop_exists}    Get Regexp Matches    ${res}    ${nop_namespace}
    IF    ${check_nop_exists}
        Set Test Variable    ${is_nop_installed}    ${True}
    ELSE
        Set Test Variable    ${is_nop_installed}    ${False}
    END

Create CNF CCR Creds
    [Arguments]   ${nop_namespace}
    ${achieved_creds}   ssh.execute  command=kubectl get secret nokia-cnf-ccr-creds -n ${nop_namespace}
    ...                              connection=RM_alias
    ${is_nop_creds_created}=   Run Keyword And Return Status
    ...    Should Not Contain    ${achieved_creds}   Error from server (NotFound)
    IF    ${is_nop_creds_created}
        ssh.execute    command=oc delete secret nokia-cnf-ccr-creds -n ${nop_namespace}
        ...            connection=RM_alias
    END
    ${cmd}    Catenate    oc create secret docker-registry nokia-cnf-ccr-creds
    ...    --from-file=.dockerconfigjson=/sysroot/ostree/deploy/rhcos/var/lib/kubelet/config.json
    ...    -n ${nop_namespace}
    ${res}    ssh.execute  command=${cmd}   connection=RM_alias
    ${match}    Get Regexp Matches    ${res}    nokia-cnf-ccr-creds created
    IF    not ${match}    Fail    oc create secret nokia-cnf-ccr-cred fails!!!

Uninstall NOP
    [Arguments]    ${nop_name}    ${nop_namespace}
    ssh.Connect to    hostname=${${par_prefix}_k8s_addr}
    ...               username=${${par_prefix}_k8s_user}
    ...               password=${${par_prefix}_k8s_pwd}
    ...               alias=RM_alias
    TRY
        ${output}=    ssh.execute    command=helm uninstall ${nop_name} -n ${nop_namespace} --timeout 3m
        ...           connection=RM_alias
        Should Contain    ${output}    uninstalled
        ${check_if_nop_deleted}=    ssh.execute    command=helm list -n ${nop_namespace}|awk 'NR==2'    connection=RM_alias
        ${check_if_nop_deleted}    Strip String    ${check_if_nop_deleted}
        Should Be Empty    ${check_if_nop_deleted}
    EXCEPT    AS    ${error}
        ${timeout}    Get Regexp Matches    ${error}    CommandOutputTimeoutError|timed out
        IF    ${timeout}
            ssh.execute    command=mkdir -p /tmp/${tl.tl_cloud_topology}
            ...           connection=RM_alias
            Wait Until Keyword Succeeds    3x    10s   Recover CNF Undeploy Timeout Issue
            ...    ${nop_name}
            ...    ${nop_namespace}
        ELSE
            Fail    Undeploy ${nop_name} failed due to ${error}
        END
    END
    Log To Console    ---> Uninstall ${nop_name} done

Uninstall koredump-operator under koredump namespace
    Check If NOP Installed    nop_namespace=koredump
    Create CNF CCR Creds    nop_namespace=koredump
    IF    ${is_nop_installed}
        Log To Console   ---> Start to Uninstall koredump-operator under koredump namespace
        Wait Until Keyword Succeeds    2x    10s    Uninstall NOP     koredump-operator    koredump
    END

Install NOP
    [Arguments]    ${nop_name}
    ssh.Connect to    hostname=${${par_prefix}_k8s_addr}
    ...               username=${${par_prefix}_k8s_user}
    ...               password=${${par_prefix}_k8s_pwd}
    ...               alias=RM_alias
    Log To Console   ---> Start to install ${nop_name}
    FOR    ${index}     IN RANGE    0    2
        TRY
            IF    '${index}' == '0'
                ${image_registry_url}     Set Variable
                ...    rcp-docker-containers-local.artifactory-espoo1.int.net.nokia.com
            ELSE
                ${image_registry_url}     Set Variable    ${${site}_local_registry_url}
                #Push Image
                ssh.upload file    local_path=${CURDIR}/../scripts/nop-install.sh
                ...    remote_path=${target_path_nop}/nop-install.sh
                ...    connection=RM_alias
                ssh.execute   command=chmod +x ${target_path_nop}/nop-install.sh  connection=RM_alias
                ssh.execute   command=cd ${target_path_nop}&&./nop-install.sh ${nop_name} ${${site}_local_registry_url} ${${site}_local_registry_auth}
                ...           connection=RM_alias
            END
            Log to console     \n\t--- CCR Address: ${image_registry_url} ---\n
            ${set_image_registry_cmd}    Set Variable If    '${nop_name}'=='ran-nic-sw-controller'
            ...    --set image.registry
            ...    --set global.image.registry
            ${installation_cmd}=  Catenate  cd ${target_path_nop} &&
            ...    helm install ${nop_name} -n ${nop_name}
            ...    ${set_image_registry_cmd}=${image_registry_url}/${nop_name}
            ...    ./HelmChart/${nop_tgz_name}
            Log    ${nop_name} installation command: ${installation_cmd}
            Deploy NOP    nop_name=${nop_name}    nop_installation_cmd=${installation_cmd}
        EXCEPT    AS    ${err}
            ${pull_image_error}    Get Regexp Matches    ${err}    ImagePullBackOff|ErrImagePull
            IF    ${pull_image_error}
                log_events_of_image_pull_backoff_pods    ${nop_name}
                IF    '${index}' == '0'
                    Log To Console   ---> ${nop_name} installation failed due to image pull error, will retry with local harbor...
                    Wait Until Keyword Succeeds    2x    10s    Uninstall NOP     ${nop_name}    ${nop_name}
                    CONTINUE
                END
            END
            ${offline}     Get Variable Value    ${offline}    false
            IF    '${offline}' == 'false'    Handle NOP Installation Exception    nop_name=${nop_name}    err=${err}
        END
        BREAK
    END
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    ssh.execute  command=rm -rf ${target_path_nop}  connection=RM_alias
    ...                    AND    Run Keyword And Ignore Error    ssh.disconnect   connection=RM_alias

Reinstall NOP
    [Arguments]    ${nop_name}    ${nop_installation_cmd}
    Log To Console   ---> Start to Uninstall ${nop_name}
    Wait Until Keyword Succeeds    2x    10s    Uninstall NOP     ${nop_name}    ${nop_name}
    TRY
        Deploy NOP    nop_name=${nop_name}    nop_installation_cmd=${nop_installation_cmd}
    EXCEPT    AS    ${err}
        Handle NOP Installation Exception    nop_name=${nop_name}    err=${err}
    END

Handle NOP Installation Exception
    [Arguments]    ${nop_name}    ${err}
    Set Suite Variable    ${offline}    true
    Set Suite Variable    ${comment}    ${nop_name} installation failed
    Fail  !!Warning!!! ${nop_name} installation failed due to ${err}, please manually check!

Download NOP
    [Arguments]    ${nop_file}    ${nop_name}
    Download and Uncompress NOP file    ${nop_file}    ${nop_name}
    Check If NOP Installed    ${nop_name}
    Create CNF CCR Creds    ${nop_name}
    IF  ${is_nop_installed}
        Log To Console   ---> Start to Uninstall ${nop_name}
        Wait Until Keyword Succeeds    2x    10s     Uninstall NOP     ${nop_name}    ${nop_name}
    END

####################################Start of RAN NIC SW controller####################################
Check and Collect RanNicNodeConfig log
    ssh.Connect to   hostname=${DU_k8s_addr}   username=${DU_k8s_user}   password=${DU_k8s_pwd}  alias=RM_alias
    ${rannic_config_name}=  ssh.execute
    ...  command=kubectl -n ran-nic-sw-controller get rannicnodeconfigs --no-headers -o custom-columns=Name:metadata.name
    ...  connection=RM_alias  timeout=30s
    ${rannic_error}    Get Regexp Matches    ${rannic_config_name}    (e|E)rror
    IF    ${rannic_error}
        Fail   RanNicNodeConfig is not found, please check if ran-nic-sw-controller is installed!\n${rannic_config_name}
    END
    ${rannic_config_name}=  Strip String  ${rannic_config_name}
    ${rannic_config_status}=  ssh.execute
    ...  command=kubectl -n ran-nic-sw-controller get rannicnodeconfigs ${rannic_config_name} -o yaml|grep configStatus|awk 'NR==1{print}'
    ...  connection=RM_alias  timeout=60s
    ${rannic_config_status}=  Strip String  ${rannic_config_status}
    ${cmd}=  catenate  cd /tmp/${tl.tl_cloud_topology}/; chmod +x ran-nic-sw-controller-log.sh;
    ...  ./ran-nic-sw-controller-log.sh ${DU_tenant} >>rannic_log.txt
    Run Keyword If    'Failed' in '${rannic_config_status}'  Run Keywords
    ...  Log to console  ----> ${\n}RanNicNodeConfig status is ${rannic_config_status}, start to collect logs...
    ...  AND  ssh.upload file    local_path=${CURDIR}/../scripts/ran-nic-sw-controller-log.sh
    ...  remote_path=/tmp/${tl.tl_cloud_topology}/ran-nic-sw-controller-log.sh
    ...  connection=RM_alias
    ...  AND  ssh.execute  command=${cmd}  connection=RM_alias  timeout=180
    ...  AND  ssh.download file    remote_path=/tmp/${tl.tl_cloud_topology}/ran-nic-sw-controller-troubleshooting-logs.tgz
    ...  local_path=${LOG_PATH}/ran-nic-sw-controller-troubleshooting-logs.tgz
    ...  connection=RM_alias
    ...  AND  Run Keyword And Ignore Error  ssh.execute
    ...  command=cd /tmp/${tl.tl_cloud_topology};rm -rf ran-nic-sw-controller-*  connection=RM_alias  timeout=30s
    ...  AND  Log to console  ----> RanNicNodeConfig log collection done.
    ...  ELSE  Log to console  ----> RanNicNodeConfig status is OK. ${\n}

Check rannic sw controller pod status
    ssh.Connect to   hostname=${DU_k8s_addr}   username=${DU_k8s_user}   password=${DU_k8s_pwd}  alias=RM_alias
    ${result}=  ssh.execute  command=kubectl get pod -n ran-nic-sw-controller|awk '{print $3}'   connection=RM_alias  timeout=30s
    @{rannic_result_list}   Split String   ${result}   \r\n
    Remove From List  ${rannic_result_list}  0
    Remove From List  ${rannic_result_list}  -1
    set test variable  ${rannic_result_list}
    ${length}=  Get Length   ${rannic_result_list}
    ${num}=  Get Count   ${rannic_result_list}   Running
    Should Not Be Equal As Integers    ${0}    ${num}
    Should Be Equal   ${length}     ${num}

Check rannic sw controller status
    [Documentation]  if rannic-sw-controller is nok then it will lead to ahm pod always in pending status during deployment process
    ...  this kw is to avoid this env issue during deployment.
     ${res_bool}=   Run Keyword And Return Status   Check rannic sw controller pod status
     Run Keyword If  not ${res_bool}  Run Keywords
     ...  Log To Console   ----> !!!Warning!!! rannic sw controller status is nok and it will be reinstalled!${\n}   WARN
     ...  AND  Install rannic sw controller
     [Teardown]  Run Keyword And Ignore Error   ssh.disconnect   connection=RM_alias

Install rannic sw controller
    [Documentation]  uninstall and install rannic sw controller
    ssh.Connect to   hostname=${DU_k8s_addr}   username=${DU_k8s_user}   password=${DU_k8s_pwd}  alias=RM_alias
    ${rannic_namespace}=   ssh.execute  command=kubectl get namespaces ran-nic-sw-controller   connection=RM_alias  timeout=30s
    ${is_rannic_namespace_created}=    Run Keyword And Return Status
    ...    Should Not Contain    ${rannic_namespace}    Error from server (NotFound)
    Run Keyword If    not ${is_rannic_namespace_created}
    ...    ssh.execute  command=kubectl create namespace ran-nic-sw-controller   connection=RM_alias  timeout=30s
    ${rannic_app_ver}=  ssh.execute  command=helm list -n ran-nic-sw-controller|awk 'NR==2'|awk '{print $9}'   connection=RM_alias  timeout=30s
    ${rannic_app_ver}=  Strip String   ${rannic_app_ver}
    ${is_rannic_exists}=  Run Keyword And Return Status  Should Not Be Empty  ${rannic_app_ver}
    ${rannic_version}=    Get Variable Value   ${rannic_version}    ${rannic_app_ver}
    ${is_rannic_version_exists}=  Run Keyword And Return Status  Should Not Be Empty  ${rannic_version}
    set test variable  ${is_rannic_exists}
    set test variable  ${rannic_version}
    Run Keyword If  ${is_rannic_version_exists}  Reinstall rannic sw controller  ${rannic_version}
    ...  ELSE  Log To Console   ----> !!!Warning!!! rannic sw controller installation will be skipped as rannic version is empty!

Uninstall rannic sw controller
    ${uninstall_rannic_cmd}=  set variable  helm uninstall ran-nic-sw-controller -n ran-nic-sw-controller
    ${remove_associated_CRDs_cmd}=  set variable  kubectl delete crd rannicconfigs.rannic.nokia.com rannicnodeconfigs.rannic.nokia.com
    ${result}=  ssh.execute  command=${uninstall_rannic_cmd};${remove_associated_CRDs_cmd}   connection=RM_alias  timeout=30s
    should contain any   ${result}   uninstalled   Release not loaded

Reinstall rannic sw controller
    [Arguments]  ${rannic_version}
    Uninstall rannic sw controller
    ${rannic_sw_controller_version}    Replace String    ${rannic_version}    controller-    controller_
    ${rannic_version_numbers}=    Set Variable    ${rannic_version.split('-')[-1]}
    ${is_new_rannic}=    Evaluate    tuple(map(int, ${rannic_version_numbers.split('.')})) >= (3, 9, 0)
    IF    ${is_new_rannic}
        Set Suite Variable    ${rannic_sw_controller_file}    ${rannic_sw_controller_version}-amd64.zip
    ELSE
        Set Suite Variable    ${rannic_sw_controller_file}    ${rannic_sw_controller_version}.zip
    END
    Download NOP
    ...    nop_file=${rannic_sw_controller_file}    nop_name=ran-nic-sw-controller
    Install NOP    nop_name=ran-nic-sw-controller

Check And Recover RanNicConfig CR
    [Documentation]  Sometimes RanNicConfig CR is still hanging after vdu helm charts deleted. this kw is to force delete
    ...   RanNicConfig CR if status is failed.
    ssh.Connect to   hostname=${DU_k8s_addr}   username=${DU_k8s_user}   password=${DU_k8s_pwd}  alias=RM_alias
    ${rannic_update_version}=    Get Variable Value   ${rannic_version}    None
    ${res}=  ssh.execute  command=kubectl get rnc -n ${DU_tenant}  connection=RM_alias  timeout=30s
    @{res_list}=    Split To Lines    ${res}
    ${res_length}=  Get Length  ${res_list}
    @{res_1}=  Split String  ${res_list}[-1]
    Run Keyword If  ${res_length}==2 and '${res_1}[1]'=='Failed'  Run Keywords
    ...    Log to console    Rannic CR status is NOK, force deletion starts: ${\n} ${res}
    ...    AND     Delete Failed RanNicConfig CR  ${res_1}[0]
    ...    AND     Run Keyword If  '${rannic_update_version}'=='None'  Install rannic sw controller
    [Teardown]  Run Keyword And Ignore Error   ssh.disconnect   connection=RM_alias

Delete Failed RanNicConfig CR
    [Arguments]  ${CR_name}
    ${output}=  ssh.execute  command=kubectl patch rnc ${CR_name} -p '{"metadata":{"finalizers":[]}}' --type=merge -n ${DU_tenant}
    ...  connection=RM_alias  timeout=30s
    ${output}=  Strip String   ${output}
    Should Not Contain Any   ${output}  failed  error
####################################END of RAN NIC SW controller ####################################
