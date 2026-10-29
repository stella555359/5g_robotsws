*** Settings ***
Documentation
    ...    Author: yin.4.chen@nokia-sbell.com

Resource   Common.robot


*** Keywords ***
NetAct SWM Operation
    [Arguments]   ${dist_name}   ${operation}   ${package_version}=${None}   ${alias}=${NETACT_IP}   ${custom_attributes}=${None}

    ${vm_ip}   Get Variable Value   ${NETACT_IP}   ${EMPTY}
    ${service_user}   Get Variable Value   ${netact_global_configuration["${NETACT_IP}"]["ssh_username"]}   ${EMPTY}
    ${service_password}   Get Variable Value   ${netact_global_configuration["${NETACT_IP}"]["ssh_password"]}   ${EMPTY}

    ${url}   Get Variable Value   ${netact_global_configuration["${NETACT_IP}"]["url"]}   ${EMPTY}
    ${http_username}   Get Variable Value   ${netact_global_configuration["${NETACT_IP}"]["http_username"]}   ${EMPTY}
    ${http_password}   Get Variable Value   ${netact_global_configuration["${NETACT_IP}"]["http_password"]}   ${EMPTY}

    Return From Keyword If   "${NETACT_IP}"=="" or "${NETACT_IP}"=="${None}" or "${url}"==""

    nms.add_node   service_name=cmwas   hostname=${vm_ip}   username=${service_user}   password=${service_password}   alias=${alias}
    nms.add_web_url   web_url=${url}   username=${http_username}   password=${http_password}   alias=${alias}
    ${operation_id}   nms.start_swm_operation
    ...   operation_type=${operation}
    ...   dist_names=PLMN-PLMN/${dist_name}
    ...   package=${package_version}
    ...   custom_attributes=${custom_attributes}
    ...   alias=${alias}

    ${success}   Wait Until Keyword Succeeds   75m   1m   NetAct SWM Operation Finished   operation_id=${operation_id}   alias=${alias}
    Run Keyword If   not ${success}   Log To Console   NetAct SWM Operation: ${operation} Failed. Wait 5mins TIMEOUT_SUCCESS.
    Run Keyword If   not ${success}
    ...   Wait Until Keyword Succeeds   5m   1m   NetAct SWM Operation Success   operation_id=${operation_id}   alias=${alias}

    [Teardown]   Run Keywords
    ...   Run Keyword And Ignore Error   nms.delete_node   cmwas   alias=${alias}
    ...   AND
    ...   Run Keyword And Ignore Error   nms.clean_all    alias=${alias}


NetAct SWM Operation Finished
    [Arguments]   ${operation_id}   ${alias}=${NETACT_IP}
    ${progress}   nms.get_progress_of_swm_operation   operation_id=${operation_id}   alias=${alias}
    ${Successful}   Get Variable Value   ${progress["Successful"]}
    Return From Keyword If   "${Successful}"=="1"   ${True}

    ${status}   Get Variable Value   ${progress["Status"]}
    Run Keyword If   "${status}" not in ["SUCCESS", "TIMEOUT_SUCCESS", "FAILED"]   FAIL   msg=NetAct Operation Ongoing.

    Return From Keyword If   "${status}" in ["SUCCESS", "TIMEOUT_SUCCESS"]   ${True}
    Return From Keyword If   "${status}" in ["FAILED"]   ${False}


NetAct SWM Operation Success
    [Arguments]   ${operation_id}   ${alias}=${NETACT_IP}
    ${progress}   nms.get_progress_of_swm_operation   operation_id=${operation_id}   alias=${alias}
    ${Successful}   Get Variable Value   ${progress["Successful"]}
    Return From Keyword If   "${Successful}"=="1"   ${True}

    ${status}   Get Variable Value   ${progress["Status"]}
    Run Keyword If   "${status}" not in ["SUCCESS", "TIMEOUT_SUCCESS"]
    ...   FAIL   msg=NetAct SWM Operation Failed. Please Check Netact Web Page.


UUF NetAct Operation Setup
    [Timeout]   5m
    [Arguments]   ${alias}=${NETACT_IP}

    ${vm_ip}   Get Variable Value   ${NETACT_IP}   ${EMPTY}
    ${service_user}   Get Variable Value   ${netact_global_configuration["${NETACT_IP}"]["ssh_username"]}   ${EMPTY}
    ${service_password}   Get Variable Value   ${netact_global_configuration["${NETACT_IP}"]["ssh_password"]}   ${EMPTY}

    ${url}   Get Variable Value   ${netact_global_configuration["${NETACT_IP}"]["url"]}   ${EMPTY}
    ${http_username}   Get Variable Value   ${netact_global_configuration["${NETACT_IP}"]["http_username"]}   ${EMPTY}
    ${http_password}   Get Variable Value   ${netact_global_configuration["${NETACT_IP}"]["http_password"]}   ${EMPTY}

    Return From Keyword If   "${NETACT_IP}"=="" or "${NETACT_IP}"=="${None}" or "${url}"==""
    Return From Keyword If   "${vm_ip}"=="" or "${vm_ip}"=="${None}"

    nms.add_node   service_name=cmwas   hostname=${vm_ip}   username=${service_user}   password=${service_password}   alias=${alias}
    nms.add_node   service_name=fmwas   hostname=${vm_ip}   username=${service_user}   password=${service_password}   alias=${alias}
    # nms.add_node   service_name=was   hostname=${vm_ip}   username=${service_user}   password=${service_password}   alias=${alias}

    nms.add_web_url   web_url=${url}   username=${http_username}   password=${http_password}   alias=${alias}


UUF NetAct Operation Teardown
    [Arguments]   ${alias}=${NETACT_IP}
    nms.delete_node   cmwas   alias=${alias}
    nms.delete_node   fmwas   alias=${alias}
    # nms.delete_node   was   alias=${alias}
    nms.clean_all   alias=${alias}


UUF CM Upload
    [Arguments]   ${testline}   ${alias}=${NETACT_IP}
    ${dist_name}   Get Variable Value   ${ALL_CONFIG_SCF["${testline}"]["dist_name"]}

    ${output}   nms.upload_configuration   dist_names=PLMN-PLMN/${dist_name}   alias=${alias}   timeout=${180}
    Should Contain   ${output}   The operation was successfully completed.:Upload is Successful


UUF CM Provision
    [Arguments]   ${testline}   ${alias}=${NETACT_IP}
    ${dist_name}   Get Variable Value   ${ALL_CONFIG_SCF["${testline}"]["dist_name"]}

    ${time}    DateTime.Get Current Date    UTC    + 8 hours    result_format=%Y-%m-%d-%H_%M_%S

    ${actual_configuration}   nms.get_actual_configuration   alias=${alias}
    ${actual_managed_object}   nms.get_managed_object   configuration=${actual_configuration}   mo_id=PLMN-PLMN/${dist_name}   alias=${alias}
    Log   ${actual_managed_object}
    Log   ${actual_managed_object.meta_class}
    Log   ${actual_managed_object.meta_version}

    ${plan_configuration}   nms.create_plan_configuration   name=${dist_name}_${time}   alias=${alias}
    ${new_managed_object}   nms.create_managed_object
    ...   plan=${plan_configuration}
    ...   mo_id=PLMN-PLMN/${dist_name}
    ...   meta_class=${actual_managed_object.meta_class}
    ...   meta_version=${actual_managed_object.meta_version}
    ...   operation=UPDATE
    ...   alias=${alias}
    ...   btsName=CM_Provision_${time}

    ${output}   nms.provision_plan
    ...   plan_name=${dist_name}_${time}
    ...   dist_names=PLMN-PLMN/${dist_name}
    ...   backup_plan_name=${dist_name}_${time}_backup
    ...   create_backup_plan=${True}
    ...   provisioning_operation=activate
    ...   alias=${alias}
    ...   timeout=${180}
    Should Contain   ${output}   Provision of the plan was successful


UUF FM Auto Upload
    [Arguments]   ${testline}   ${alias}=${NETACT_IP}
    ${dist_name}   Get Variable Value   ${ALL_CONFIG_SCF["${testline}"]["dist_name"]}

    ${alarms_list}   nms.get_alarms   dist_name=PLMN-PLMN/${dist_name}   alias=${alias}
    Should Not Be Empty   ${alarms_list}


UUF FM Manual Upload
    [Arguments]   ${testline}   ${alias}=${NETACT_IP}
    ${dist_name}   Get Variable Value   ${ALL_CONFIG_SCF["${testline}"]["dist_name"]}

    ${output}   nms.upload_alarms   dist_name=PLMN-PLMN/${dist_name}   alias=${alias}
    Should Contain   ${output}   Alarm Upload: SUCCESS


UUF SWM Upload
    [Arguments]   ${testline}   ${alias}=${NETACT_IP}
    ${dist_name}   Get Variable Value   ${ALL_CONFIG_SCF["${testline}"]["dist_name"]}

    ${output}   nms.upload_sw   dist_names=PLMN-PLMN/${dist_name}   alias=${alias}   timeout=${180}
    Should Contain   ${output}   SUCCESS


UUF SWM Precheck
    [Arguments]   ${testline}   ${package_version}   ${precheckType}=fullCheck   ${alias}=${NETACT_IP}

    ${vm_ip}   Get Variable Value   ${NETACT_IP}   ${EMPTY}
    ${service_user}   Get Variable Value   ${netact_global_configuration["${NETACT_IP}"]["ssh_username"]}   ${EMPTY}
    ${service_password}   Get Variable Value   ${netact_global_configuration["${NETACT_IP}"]["ssh_password"]}   ${EMPTY}

    ${url}   Get Variable Value   ${netact_global_configuration["${NETACT_IP}"]["url"]}   ${EMPTY}
    ${http_username}   Get Variable Value   ${netact_global_configuration["${NETACT_IP}"]["http_username"]}   ${EMPTY}
    ${http_password}   Get Variable Value   ${netact_global_configuration["${NETACT_IP}"]["http_password"]}   ${EMPTY}

    Return From Keyword If   "${NETACT_IP}"=="" or "${NETACT_IP}"=="${None}" or "${url}"==""

    nms.add_node   service_name=cmwas   hostname=${vm_ip}   username=${service_user}   password=${service_password}   alias=${alias}
    nms.add_web_url   web_url=${url}   username=${http_username}   password=${http_password}   alias=${alias}


    ${dist_name}   Get Variable Value   ${ALL_CONFIG_SCF["${testline}"]["dist_name"]}
    &{custom_attributes}   Create Dictionary   precheckType=${precheckType}

    ${output}   nms.precheck_sw
    ...   dist_names=PLMN-PLMN/${dist_name}
    ...   package_name=${package_version}
    ...   custom_attributes=${custom_attributes}
    ...   timeout=${180}
    ...   alias=${alias}
    Should Contain   ${output}   SUCCESS

    [Teardown]   Run Keywords
    ...   Run Keyword And Ignore Error   nms.delete_node   cmwas   alias=${alias}
    ...   AND
    ...   Run Keyword And Ignore Error   nms.clean_all    alias=${alias}
