*** Settings ***
Documentation
...    Author: Xiang Liangliang; Cao Ge
...    Email address: liang.xiang@nokia-sbell.com; ge.cao@nokia-sbell.com;
...    Maintainer: Xiang Liangliang;    Cao Ge
...    Email address: liang.xiang@nokia-sbell.com;    ge.cao@nokia-sbell.com;
...    Common KWs for modify parameter of AIC NE.
...    All the bugs/new keyword needs/improvement should be raised in Jira and assign to the Maintainer
...    Jira link: https://jiradc.ext.net.nokia.com/projects/PZ1HAZTA/issues
...    Guideline: https://confluence.ext.net.nokia.com/display/SRANPRODHZHTA/09.+AIC+Common+Resource+Supporting+Mode+Improvement

Library           Collections
Library           BuiltIn
Library           OperatingSystem
Library           re
Library           DateTime
Library           String
Library           yaml
Library           XML
Library           Telnet
Library           json
Library             ./module_utils/module_utils.py
Library           taf.sbts.oam.coam.admin               WITH NAME    coam_param
Library           parameter_worker/params_ulti.py       WITH NAME    ulti
Library           taf.transport.ssh                     WITH NAME    tafssh
Library           taf.hw.fhgw.cli                       WITH NAME    issh
Library           taf.gnb.oam.coam.vdu.interface.Vdu    WITH NAME    param_vdu
Library           taf.gnb.oam.coam.cu.interface.cu      WITH NAME    param_cu
Resource          taf/rfrl/cbts/robot/vdu/vdu_cm.robot
Resource          taf/rfrl/cbts/robot/vcu/vcu_cm.robot




*** Keywords ***
Parameter Operation Internal
    [Arguments]  ${operation}   ${ne_type}   ${ne_index}=${0}   ${gnb_index}=${0}   ${delta_file_path}=${None}
    ...          ${para_list}=${None}   ${value_list}=${None}   ${mo_list}=${None}   ${scf_path}=${None}
    ...          ${timeout}=${600}     &{kwargs}
    [Documentation]   Parameter Operation Internal
#    Param Excution Precondition
    @{operation_type_list}   create list   parameter_value_check   delta_plan_update   parameter_update   full_commission
    ...     activate_plan     check_delta_plan_status
    Should Contain   ${operation_type_list}   ${operation}
    ${is_input_should_activate}    Run Keyword And Return Status
    ...    Dictionary Should Contain Key    ${kwargs}[kwargs]    should_activate
    ${should_activate}   Set Variable If   ${is_input_should_activate}    ${kwargs['kwargs']['should_activate']}   ${True}
    ${is_input_plan_id}    Run Keyword And Return Status
    ...    Dictionary Should Contain Key    ${kwargs}[kwargs]    plan_id
    ${plan_id}   Set Variable If   ${is_input_plan_id}    ${kwargs['kwargs']['plan_id']}   ${None}
    ${is_modify_operation}    Run Keyword And Return Status
    ...    Dictionary Should Contain Key    ${kwargs}[kwargs]    modify_operation
    ${classical_type}   create list  gnb  enb
    ${aic_type}   create list    vdu    vcu
    ${modify_operation}   Set Variable If   ${is_modify_operation}
    ...     ${kwargs['kwargs']['modify_operation']}   replace
    ${is_wait_for_completion}    Run Keyword And Return Status
    ...    Dictionary Should Contain Key    ${kwargs}[kwargs]    wait_for_completion
    ${wait_for_completion}   Set Variable If   ${is_wait_for_completion}    ${kwargs['kwargs']['wait_for_completion']}
    ...     ${True}
    ${is_check_time}    Run Keyword And Return Status
    ...    Dictionary Should Contain Key    ${kwargs}[kwargs]    check_time
    ${check_time}   Set Variable If   ${is_check_time}    ${kwargs['kwargs']['check_time']}
    ...     1200s
    ${is_expect_status}    Run Keyword And Return Status
    ...    Dictionary Should Contain Key    ${kwargs}[kwargs]    expect_status
    ${expect_status}   Set Variable If    ${is_expect_status}    ${kwargs['kwargs']['expect_status']}
    ...     success
    ${is_backhaul_site_oam_ip}    Run Keyword And Return Status
    ...    Dictionary Should Contain Key    ${kwargs}[kwargs]    backhaul_site_oam_ip
    ${backhaul_site_oam_ip}   Set Variable If    ${is_backhaul_site_oam_ip}    ${kwargs['kwargs']['backhaul_site_oam_ip']}
    ...     ${None}
#    ${is_input_conn_alias}    Run Keyword And Return Status
#    ...    Dictionary Should Contain Key    ${kwargs}[kwargs]    alias
#    ${alias}   Set Variable If   ${is_input_conn_alias}    ${kwargs['kwargs']['alias']}   ${None}
    ${out}   Run Keyword If   "${operation}"=="parameter_value_check"   _Online Get Parameter Value   ne_type=${ne_type}
    ...      vdu_index=${ne_index}   gnb_index=${gnb_index}   para_list=${para_list}   mo_list=${mo_list}   timeout=${timeout}
    Return From Keyword If   "${out}"!="${None}"   ${out}
#    ${out}   Run Keyword If   "${operation}"=="parameter_update" and "${ne_type}"=="vdu"   VDU Online Change Parameters
    ${out}   Run Keyword If   "${operation}"=="parameter_update" and "${ne_type}"=="vdu"   VDU Online Change Parameters By M2M
    ...       para_list=${para_list}   value_list=${value_list}   mo_list=${mo_list}  vdu_index=${ne_index}   gnb_index=${gnb_index}
    ...       should_activate=${should_activate}    operation=${modify_operation}   wait_for_completion=${wait_for_completion}
    Return From Keyword If   "${out}"!="${None}"   ${out}
#    ${out}   Run Keyword If   "${operation}"=="parameter_update" and "${ne_type}"=="vcu"   VCU Online Change Parameters
    ${out}   Run Keyword If   "${operation}"=="parameter_update" and "${ne_type}"=="vcu"   VCU Online Change Parameters By M2M
    ...       para_list=${para_list}   value_list=${value_list}   mo_list=${mo_list}   gnb_index=${gnb_index}
    ...      should_activate=${should_activate}    operation=${modify_operation}    wait_for_completion=${wait_for_completion}
    Return From Keyword If   "${out}"!="${None}"   ${out}
    ${out}   Run Keyword If   "${operation}"=="parameter_update" and "${ne_type}" in "${classical_type}"
    ...   Online Change Parameters For Classical    para_list=${para_list}   value_list=${value_list}   mo_list=${mo_list}
    ...   ne_type=${ne_type}   gnb_index=${gnb_index}    should_activate=${should_activate}   operation=${modify_operation}
    ...    backhaul_site_oam_ip=${backhaul_site_oam_ip}
    Return From Keyword If   "${out}"!="${None}"   ${out}
    ${out}   Run Keyword If   "${operation}"=="full_commission"   Update Full SCF By Rest
    ...       ne_type=${ne_type}   scf_path=${scf_path}  vdu_index=${ne_index}    gnb_index=${gnb_index}   timeout=${timeout}
    ...      should_activate=${should_activate}
    Return From Keyword If   "${out}"!="${None}"   ${out}
    ${out}   Run Keyword If   "${operation}"=="activate_plan"   _activate_plan_operation   ne_type=${ne_type}
    ...      plan_id=${plan_id}    gnb_index=${gnb_index}
    Return From Keyword If   "${out}"!="${None}"   ${out}
    ${out}   Run Keyword If   "${operation}"=="check_delta_plan_status"   _check_delta_plan_status_for_aic   ne_type=${ne_type}
    ...      vdu_index=${ne_index}    gnb_index=${gnb_index}    plan_id=${plan_id}    should_activate=${should_activate}
    ...      check_time=${check_time}    expect_status=${expect_status}
    Return From Keyword If   "${operation}"=="check_delta_plan_status"    ${out}
    ${out}   Run Keyword If   "${operation}"=="delta_plan_update"
    ...       _Delta Commissioning For Modify Parameter   ne_type=${ne_type}   delta_file_path=${delta_file_path}
    ...        vdu_index=${ne_index}   gnb_index=${gnb_index}   timeout=${timeout}    should_activate=${should_activate}
    ...       wait_for_completion=${wait_for_completion}     backhaul_site_oam_ip=${backhaul_site_oam_ip}
    [Return]  ${out}

################################## classical parameter operation ##################################
#Classical SBTS Login For Gnb
#    [Arguments]    ${gnb_index}=${0}    ${bts_port}=${443}    ${log_dir}=/home/ute/test_results   ${alias}=COAM
#    ${bts_host}    set variable    ${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}
#    ${username}    set variable    ${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
#    ${password}    set variable    ${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
#    coam_param.connect_to
#    ...    bts_host=${bts_host}
#    ...    bts_port=${bts_port}
#    ...    username=${username}
#    ...    password=${password}
#    ...    admin_api_log_dir=${log_dir}
#    ...    name=${alias}

_classical_bts.login
    [Arguments]   ${gnb_index}=${0}    ${product_type}=gnb    ${alias}=COAM    ${backhaul_site_oam_ip}=${None}
    ${site_info}    get_site_info    product_type=${product_type}
    ...    info_type=oam
    ...    bts_index=${gnb_index}    backhaul_site_oam_ip=${backhaul_site_oam_ip}
    coam.connect_to    bts_host=${site_info.addr}
    ...    username=${site_info.username}
    ...    password=${site_info.password}
    ...    admin_api_log_dir=${OUTPUT_DIR}
    ...    use_ssl=${True}
    ...    update_interval=${5000}
    ...    name=${alias}
    [Return]    ${alias}


#Classical SBTS Login For Enb
#    [Arguments]    ${gnb_index}=${0}
#    ...           ${ENB_USERNAME}=Nemuadmin
#    ...           ${ENB_PASSWORD}=nemuuser
#    ...           ${bts_port}=${443}    ${log_dir}=/home/ute/test_results   ${alias}=COAM
#    ${bts_host}   set variable   ${tl.enbs[${gnb_index}].airscale.common_units[0].lmp_connection.addr}
#    coam_param.connect_to
#    ...    bts_host=${bts_host}
#    ...    bts_port=${bts_port}
#    ...    username=${ENB_USERNAME}
#    ...    password=${ENB_PASSWORD}
#    ...    admin_api_log_dir=${log_dir}
#    ...    name=${alias}

Admin Collect scf.xml with timestamp TAF For Classical
    [Arguments]  ${alias}=default  ${folder_path}=/home/ute/btsauto/logs  ${export_type}=${None}
    [Documentation]   Admin Collect scf.xml with timestamp TAF For Classical
    ...  | export_type | No   | configuration, configurationAndRuntimeObjects or runtimeObjects.
    ...                         None means default Admin API behavior.
    ...                         By default is None |
    ${time}=  Get Time
    Set Test Variable  ${scf_path}  ${folder_path}/scf_${time}.xml
    coam_param.get_current_scf_file  local_dir_path=${folder_path}  file_name=scf_${time}.xml
    ...    timeout=60  connection=${alias}  export_type=${export_type}

    [Return]  ${scf_path}

Get Parameters Value By SCF For Classical
    [Arguments]  ${scf_distName}   ${param_name}   ${ne_type}   ${gnb_index}=${0}    ${export_type}=configurationAndRuntimeObjects
    ...          ${folder_path}=${OUTPUT_DIR}     ${connection}=COAM     ${backhaul_site_oam_ip}=${None}
    _classical_bts.login    gnb_index=${gnb_index}   product_type=${ne_type}   alias=${connection}
    ...     backhaul_site_oam_ip=${backhaul_site_oam_ip}
    ${BTS_scf}=    Admin Collect scf.xml with timestamp TAF For Classical    alias=${connection}
    ...            folder_path=${folder_path}    export_type=${export_type}
    Import Library    XML    use_lxml=True    WITH NAME    L_XML_param
    ${value}  run keyword if   "/" in "${param_name}"   _Get_stage_param_value_from_scf   scf_distName=${scf_distName}
    ...     param_name=${param_name}   BTS_scf=${BTS_scf}
    ...    ELSE   _Get_normal_param_value_from_scf   scf_distName=${scf_distName}   param_name=${param_name}   BTS_scf=${BTS_scf}
    [Return]  ${value}
    [Teardown]   Run Keyword And Ignore Error     coam_param.teardown    connection=${connection}

_Get_normal_param_value_from_scf
    [Arguments]   ${scf_distName}   ${param_name}    ${BTS_scf}
    ${scf_xml}=    L_XML_param.Parse xml    ${BTS_scf}
    @{result_value}=    L_XML_param.Get Elements    ${scf_xml}    .//managedObject[@distName="${scf_distName}"]/p
    &{result_value_dict}=    Create dictionary
    ${expect_value}   set variable  ${None}
    FOR   ${item}  IN  @{result_value}
        ${key}   L_XML_param.Get Element Attribute    ${item}    name
        ${value}    L_XML_param.Get Element Text    ${item}
        ${expect_value}    set variable if    "${key}"=="${param_name}"    ${value}
        exit for loop if   "${key}"=="${param_name}"
    END
    [Return]  ${expect_value}

_Get_stage_param_value_from_scf
    [Arguments]   ${scf_distName}   ${param_name}   ${BTS_scf}
    ${scf_xml}=    L_XML_param.Parse xml    ${BTS_scf}
    @{param_list}   Split String   ${param_name}   /
    ${stage_param_name}   set variable   ${param_list[${0}]}
    ${stage_param_index}   set variable   ${param_list[${1}]}
    ${stage_param_index}   evaluate   ${stage_param_index}+1
    ${sub_param_name}   set variable   ${param_list[-1]}
    @{result_value}=    L_XML_param.Get Elements    ${scf_xml}
    ...     .//managedObject[@distName="${scf_distName}"]/list[@name="${stage_param_name}"]/item[${stage_param_index}]/p
    ${expect_value}   set variable  ${None}
    FOR   ${item}  IN  @{result_value}
        ${key}   L_XML_param.Get Element Attribute    ${item}    name
        ${value}    L_XML_param.Get Element Text    ${item}
        ${expect_value}    set variable if    "${key}"=="${sub_param_name}"    ${value}
        exit for loop if   "${key}"=="${sub_param_name}"
    END
    [Return]  ${expect_value}

Perform Delta Recommission For Classical
    [Arguments]    ${delta_file_path}   ${ne_type}   ${gnb_index}=${0}    ${connection}=COAM   ${should_activate}=${True}
    ...    ${timeout}=${600}     ${backhaul_site_oam_ip}=${None}
    _classical_bts.login    gnb_index=${gnb_index}  product_type=${ne_type}   alias=${connection}
    ...     backhaul_site_oam_ip=${backhaul_site_oam_ip}
    ${res}   coam_param.perform_delta_recommissioning
    ...    delta_file=${delta_file_path}
    ...    skip_parameter_relation_errors=${true}
    ...    should_activate=${should_activate}
    ...    timeout=${timeout}
    ...    connection=${connection}
    [Return]  ${res}
    [Teardown]   Run Keyword And Ignore Error     coam_param.teardown    connection=${connection}

COAM Commission with scf file For Param
    [Arguments]    ${ne_type}   ${scf_file_path}    ${gnb_index}=${0}    ${connection}=COAM    ${timeout}=600
    ...    ${is_pdl_checking_needed}=${True}    ${should_activate}=${True}
    _classical_bts.login   gnb_index=${gnb_index}  product_type=${ne_type}  alias=${connection}
    &{result}    coam_param.perform_commissioning    scf_file=${scf_file_path}
    ...    timeout=${timeout}    skip_parameter_relation_errors=${True}    connection=${connection}
    return from keyword if    "${should_activate}"=="${False}"   ${result}
    Should be equal as strings    ${result['commissioningResult']['activationResult']['resultNode']['parameters']['result']}    Success
    ...    msg=Commissioned with error exists, activation result is not in success status.    ignore_case=${True}
    Should be equal as strings    ${result['validationResult']['niddValidationResult']['status']}    OK
    ...    msg=Commissioned with error exists, nidd validation result is not in OK status    ignore_case=${True}
    Run keyword if    ${is_pdl_checking_needed}==${True}
    ...    Should be equal as strings    ${result['validationResult']['pdlValidationResult']['status']}    OK
    ...    msg=Commissioned with error exists, pdl validation result is not in OK status.    ignore_case=${True}
    ${res}    set variable    ${result['commissioningResult']['activationResult']['resultNode']['parameters']['result']}
    [Return]    ${res}
    [Teardown]   Run Keyword And Ignore Error     coam_param.teardown    connection=${connection}


Get Parameter Value Online For Multiple MO For Classical
    [Arguments]   ${para_list}  ${mo_list}  ${ne_type}   ${gnb_index}=${0}   ${connection}=COAM
    ...     ${backhaul_site_oam_ip}=${None}
    ${origin_para_value_dict}   Create Dictionary
    ${length}   Get Length    ${para_list}
    FOR    ${i}    IN RANGE    0     ${length}
        ${mo}  Set Variable   ${mo_list[${i}]}
        ${mo_keys}   Evaluate  list(${origin_para_value_dict})
        ${mo_dict}   Run Keyword If   "${mo}" in ${mo_keys}  Set Variable  ${origin_para_value_dict["${mo}"]}
            ...  ELSE   Create Dictionary
        ${para}  Set Variable   ${para_list[${i}]}
        @{tmp_para_list}  Split String  ${para}  /
        ${is_number}  ulti.is_numeric   ${tmp_para_list[-1]}
        ${para}  Set Variable If   "${is_number}"=="${True}"   ${tmp_para_list[0]}    ${para}

        ${status}  ${value}   Run Keyword And Ignore Error   Get Parameters Value By SCF For Classical   scf_distName=${mo}
        ...      param_name=${para}    ne_type=${ne_type}    gnb_index=${gnb_index}    connection=${connection}
        ...     backhaul_site_oam_ip=${backhaul_site_oam_ip}
        ${value_current}  Set Variable If  '${status}'=='PASS'   ${value}  ${None}
        ${is_a_list}  _Is List For Param   ${value_current}
        ${r}   ${value_current}  Run Keyword And Ignore Error  Set Variable If  '${is_a_list}'=='${True}' and "${is_number}"=="${True}"
             ...   ${value_current[${tmp_para_list[-1]}]}   ${value_current}
        ${value_current}  Set Variable If  "${r}"=="PASS"  ${value_current}  ${None}
        Set to Dictionary  ${mo_dict}   ${para_list[${i}]}   ${value_current}
        Set to Dictionary  ${origin_para_value_dict}  ${mo}   ${mo_dict}
    END
    [Return]  ${origin_para_value_dict}


Online Change Parameters By Delta Plan REST For Classical
    [Arguments]   ${updated_para_value_dict}   ${ne_type}      ${gnb_index}=${0}    ${operation}=update
    ...            ${timeout}=${800}    ${connection}=COAM
    ...            ${skip_parameter_relation_errors}=false    ${should_activate}=${true}
    ...            ${backhaul_site_oam_ip}=${None}
    _classical_bts.login   gnb_index=${gnb_index}    product_type=${ne_type}    alias=${connection}
    ...    backhaul_site_oam_ip=${backhaul_site_oam_ip}
    @{distname_list}  Get Dictionary Keys    ${updated_para_value_dict}
    @{value}     Get Dictionary Values    ${updated_para_value_dict}
    @{param_name_list}  Create List
    @{value_list}    Create List
    ${value_len}    get length    ${value}
    FOR  ${index}  IN RANGE    ${value_len}
         @{inital_param_list}    Get Dictionary Keys    ${value[${index}]}
         @{inital_value_list}  Get Dictionary Values    ${value[${index}]}
         Append To List  ${param_name_list}    ${inital_param_list}
         Append To List  ${value_list}    ${inital_value_list}
    END
    ${res}   _For_Modify_Multi_Param   dist_name=${distname_list}   key_list=${param_name_list}   value_list=${value_list}
    ...       operation=${operation}    timeout=${timeout}   connection=${connection}
    ...     skip_parameter_relation_errors=${skip_parameter_relation_errors}   should_activate=${should_activate}
    ${res}    set variable if    "${should_activate}"=="${true}"
    ...    ${res["commissioningResult"]["activationResult"]["resultNode"]["parameters"]["result"]}
    ...    ${res["commissioningResult"]["deltaDn"]}
#    log to console   ${res["commissioningResult"]["activationResult"]["resultNode"]["parameters"]["result"]}
    [Return]  ${res}
    [Teardown]   Run Keyword And Ignore Error     coam_param.teardown    connection=${connection}


_For_Modify_Multi_Param
    [Arguments]   ${dist_name}   ${key_list}   ${value_list}   ${operation}=update
    ...            ${timeout}=${800}    ${connection}=COAM
    ...            ${skip_parameter_relation_errors}=true    ${should_activate}=${true}
        ${len_param}  get length   ${dist_name}
        ${time}    Get Time    epoch
        ${delta_id}    set variable    enableFeature_${time}
        coam_param.create_delta    delta_id=${delta_id}
        Log  ${operation}
        FOR  ${index}   IN RANGE   ${len_param}
            coam_param.append_managed_object_to_delta    ${dist_name[${index}]}    update    ${delta_id}
            add_parameter_to_delta    ${dist_name[${index}]}
            ...    ${key_list[${index}]}    ${value_list[${index}]}    ${delta_id}
        END
        ${delta_json}    coam_param.get_delta    delta_id=${delta_id}
        ${res}   coam_param.perform_delta_recommissioning    ${delta_json}
        ...      skip_parameter_relation_errors=${skip_parameter_relation_errors}
        ...      should_activate=${should_activate}    timeout=${timeout}    connection=${connection}
    [Return]  ${res}


add_parameter_to_delta
    [Arguments]   ${dist_name}    ${key_list}    ${value_list}    ${delta_id}
    ${len_param_for_single_mo}  get length   ${key_list}
    FOR    ${index}  IN RANGE    ${len_param_for_single_mo}
        run keyword if   "${value_list[${index}]}"!="${None}"  coam_param.append_parameter_update_to_delta    ${dist_name}
        ...    ${key_list[${index}]}    ${value_list[${index}]}    ${delta_id}
        ...    ELSE IF    "${value_list[${index}]}"=="${None}"  coam_param.append_parameter_delete_to_delta    ${dist_name}
        ...    ${key_list[${index}]}     ${delta_id}
    END


Online Change Parameters For Classical
    [Arguments]    ${para_list}   ${value_list}   ${mo_list}   ${ne_type}
    ...           ${gnb_index}=0    ${should_activate}=${True}   ${operation}=update     ${backhaul_site_oam_ip}=${None}
    ${operation}    set variable if    "${operation}"=="replace"   update    ${operation}
    ${operation}    set variable if    "${operation}"=="remove"   delete    ${operation}
    log to console    Online Change Parameters For Classical...
    should not be empty   ${para_list}   msg="para_list" can't be empty
    should not be empty   ${value_list}   msg="value_list" can't be empty
    should not be empty   ${mo_list}   msg="mo_list" can't be empty
    ${origin_para_value_dict}    Get Parameter Value Online For Multiple MO For Classical   para_list=${para_list}
    ...    mo_list=${mo_list}    ne_type=${ne_type}   gnb_index=${gnb_index}    backhaul_site_oam_ip=${backhaul_site_oam_ip}
    ${updated_para_value_dict}    _Convert Parameters From List To Dict For Multiple MO
      ...   para_list=${para_list}  value_list=${value_list}  mo_list=${mo_list}   origin_para_value_dict=${origin_para_value_dict}

    ${compare_result}  run keyword and return status   dictionaries should be equal    ${origin_para_value_dict}  ${updated_para_value_dict}
    ${need_update}  Set Variable If  "${operation}"=="update" and "${compare_result}"=="${True}"  ${False}  ${True}
    log to console   ${updated_para_value_dict}
    ${res}   run keyword if     "${need_update}"== "${True}"    Online Change Parameters By Delta Plan REST For Classical
     ...  updated_para_value_dict=${updated_para_value_dict}   ne_type=${ne_type}   gnb_index=${gnb_index}   operation=${operation}
     ...    should_activate=${should_activate}      backhaul_site_oam_ip=${backhaul_site_oam_ip}
    [Return]   ${res}

################################## Case Precondition ##################################
#Parameter Operation Create Case Directory
#    ${timestamp}=    DateTime.Get Current Date    result_format=%Y%m%d%H%M%S
#    ${tc_name}=    Replace String    ${TEST_NAME}    ${SPACE}    _
#    ${case_log_path}    Join path    ${SUITE_LOG_DIRECTORY}    ${tc_name}_${timestamp}
#    Set Suite Variable    ${TEST_LOG_DIRECTORY}    ${case_log_path}
#    Create directory    ${TEST_LOG_DIRECTORY}
#    Log to Console    \n***Test Case Log Directory ${TEST_LOG_DIRECTORY}***
#
#Test Setup For Param
#    ${out}   ${msg}   Run keyword and ignore error  variable should not exist   ${TEST_LOG_DIRECTORY}
#    run keyword if   "${out}"=="PASS"   Parameter Operation Create Case Directory
#
#Parameter Operation Create Suite Directory
#    ${suite_name}=    Replace String    ${SUITE NAME}    ${SPACE}    _
#    ${timestamp}=    DateTime.Get Current Date    result_format=%Y%m%d%H%M%S
#    ${suite_log_path}    Join path    ${OUTPUT_DIR}    ${suite_name}_${timestamp}
#    Set Suite Variable    ${SUITE_LOG_DIRECTORY}    ${suite_log_path}
#    Create directory    ${SUITE_LOG_DIRECTORY}
#    Log to Console    \n***Suite Log Directory ${SUITE_LOG_DIRECTORY}***
#
#
#Suite Setup For Param
#    ${out}   ${msg}   Run keyword and ignore error   variable should not exist   ${SUITE_LOG_DIRECTORY}
#    run keyword if   "${out}"=="PASS"   Parameter Operation Create Suite Directory
#
#Param Excution Precondition
#    Suite Setup For Param
#    Test Setup For Param

################################## AIC Parameter Operation ##################################
_Delta Commissioning For Modify Parameter
    [Arguments]  ${ne_type}  ${delta_file_path}=/home/ute/Delta_configuration_scf_MRBTS-10868.xml
    ...          ${vdu_index}=${0}   ${gnb_index}=${0}  ${timeout}=${300}    ${should_activate}=${True}  ${wait_for_completion}=${True}
    ...          ${backhaul_site_oam_ip}=${None}
    should not be empty    ${delta_file_path}   msg="delta_file_path" can't be empty
#    Run Keyword If   "${ne_type}"=="vcu"   Upload delta vCU   ${delta_file_path}   gnb_index=${gnb_index}   timeout=${timeout}
    ${res}    Run Keyword If   "${ne_type}"=="vcu"   Upload delta vCU By M2M   ${delta_file_path}   gnb_index=${gnb_index}
    ...     should_activate=${should_activate}   wait_for_completion=${wait_for_completion}
#    Run Keyword If   "${ne_type}"=="vdu"   Upload delta vDU   ${delta_file_path}   vdu_index=${vdu_index}
    ...    ELSE IF    "${ne_type}"=="vdu"   Upload delta vDU By M2M   ${delta_file_path}   vdu_index=${vdu_index}
    ...     should_activate=${should_activate}  wait_for_completion=${wait_for_completion}
    ...  ELSE IF    "${ne_type}"=="gnb" or "${ne_type}"=="enb"   Perform Delta Recommission For Classical
    ...   ${delta_file_path}  ne_type=${ne_type}   gnb_index=${gnb_index}   timeout=${timeout}   should_activate=${should_activate}
    ...    backhaul_site_oam_ip=${backhaul_site_oam_ip}
    RETURN    ${res}

Update Full SCF By Rest
    [Arguments]  ${ne_type}  ${scf_path}   ${vdu_index}=${0}   ${gnb_index}=${0}    ${timeout}=600    ${should_activate}=${True}
#    ${res}   Run Keyword If   "${ne_type}"=="vdu"   Update Full SCF By Rest For VDU   scf_path=${scf_path}  vdu_index=${vdu_index}
    ${res}   Run Keyword If   "${ne_type}"=="vdu"   Update Full SCF By Rest For VDU By M2M   scf_path=${scf_path}  vdu_index=${vdu_index}
    ...       should_activate=${should_activate}
#    ...      ELSE IF  "${ne_type}"=="vcu"   Update Full SCF By Rest For VCU   scf_path=${scf_path}
    ...      ELSE IF  "${ne_type}"=="vcu"   Update Full SCF By Rest For VCU By M2M   scf_path=${scf_path}
    ...      should_activate=${should_activate}
    ...      ELSE IF  "${ne_type}"=="gnb" or "${ne_type}"=="enb"   COAM Commission with scf file For Param   ne_type=${ne_type}
    ...          scf_file_path=${scf_path}    gnb_index=${gnb_index}  timeout=${timeout}    should_activate=${should_activate}
    [Return]  ${res}



VCU Connection
   [Arguments]   ${gnb_index}=0   ${alias}=${None}
    ${host}    set variable  ${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}
    run keyword and ignore error    VCU Disconnection
    param_cu.connect_to    host=${host}
    ...    port=${EMPTY}
    ...    username=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...    password=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    ...    secure=${True}
    ...    alias=${alias}
    [Return]  ${alias}

VCU Disconnection
    [Arguments]    ${connection}=${None}
    param_cu.disconnect    connection=${connection}

Update Full SCF By Rest For VCU
    [Arguments]    ${scf_path}   ${plan_name}=TA_plan_file
    [Documentation]   Send BTS commission via rest.
    VCU Connection
    log to console   \n*** Start plan upload operation ***
    ${upload_operation_info}=   param_cu.upload_plan_file     ${scf_path}   plan_name=${plan_name}
    log to console   \n*** Wait plan upload operation success ***
    wait until keyword succeeds    60s   5s  _CU Check Full SCF Plan Upload Status Should Be As Expected
    ...    ${upload_operation_info["action_id"]}    success
    log to console   \n*** Start plan validate operation ***
    ${validate_operaition_info}=  param_cu.plan_validation    ${upload_operation_info["plan_id"]}
    log to console   \n*** Wait plan validate operation success ***
    wait until keyword succeeds    180s   10s  _CU Check Full SCF Plan Validate Status Should Be As Expected
    ...    ${upload_operation_info["plan_id"]}   ${validate_operaition_info["action_id"]}    success
    log to console   \n*** Start plan activate operation ***
    ${activate_operaition_info}=  param_cu.plan_activation   ${upload_operation_info["plan_id"]}
    log to console   \n*** Wait plan activate operation success in 10 mins ***
    ${res}   wait until keyword succeeds    600s   30s  _CU Check Full SCF Plan Activate Status Should Be As Expected
    ...    ${upload_operation_info["plan_id"]}  ${activate_operaition_info["id"]}    success
    [Return]  ${res}
    [Teardown]    run keyword and ignore error    VCU Disconnection

_CU Check Full SCF Plan Upload Status Should Be As Expected
    [Arguments]  ${operation_id}   ${expected_status}
    ${operation_response}=  param_cu.get_operation_state_of_uploading_plan    ${operation_id}
    should be true    "${operation_response["status"]}"=="${expected_status}"

_CU Check Full SCF Plan Validate Status Should Be As Expected
   [Arguments]   ${plan_id}  ${operation_id}  ${expected_status}
   ${operation_response}=  param_cu.get_operation_state_of_validating_plan     ${plan_id}    ${operation_id}
   should be true    "${operation_response["status"]}"=="${expected_status}"

_CU Check Full SCF Plan Activate Status Should Be As Expected
    [Arguments]   ${plan_id}  ${operation_id}  ${expected_status}
    ${operation_response}=  param_cu.get_operation_state_of_activating_plan    ${plan_id}   ${operation_id}
    should be true    "${operation_response["status"]}"=="${expected_status}"
    [Return]  ${operation_response["status"]}


##########################VDU by internal########################
Update Full SCF By Rest For VDU
    [Arguments]    ${scf_path}   ${vdu_index}=0    ${fix_errors}=false
    log to console    \n*** start send commission on vdu ***
    _VDU Connection    ${vdu_index}
    ${upload_plan_response}=    param_vdu.upload_plan    ${scf_path}
    wait until keyword succeeds    2min    5s    _Check Upload Full Plan Status Should Be Expected
    ...                                                        ${upload_plan_response['action_id']}
    ${validate_plan_response}=   param_vdu.validate_plan    ${upload_plan_response['plan_id']}
    ${validate_plan_response}=   wait until keyword succeeds   2min   5s   _Check Validate Full Plan Status Should Be Expected
    ...                           ${upload_plan_response['plan_id']}
    ...                           ${validate_plan_response['action_id']}

    ${errors}=    param_vdu.get_staged_plan_validation_results
    ...           ${upload_plan_response['plan_id']}
    ...           ${validate_plan_response['validation_id']}

    ${errors}=    Run Keyword If    ${errors['total']}>0 and '${fix_errors}'=='true'
        ...           Fix Error and Get Plan Validation Result
        ...                            ${upload_plan_response['plan_id']}
    ...    ELSE
        ...     Set Variable     ${errors}

    Should Be True    ${errors['total']}==0

    ${activate_plan_response}=    param_vdu.activate_plan    ${upload_plan_response['plan_id']}
    sleep    90s    reason=Wait for activate sucessful
    ${res}   wait until keyword succeeds    10min    20s    _Check Activate Full Plan Status Should Be Expected
    ...    ${upload_plan_response['plan_id']}
    ...    ${activate_plan_response['id']}
    [Return]  ${res}
    [Teardown]    _vDU Disconnection

##########################VDU By M2M ########################
Update Full SCF By Rest For VDU By M2M
    [Arguments]    ${scf_path}   ${vdu_index}=0    ${should_activate}=${True}
    log to console    \n*** start send commission on vdu ***
    _VDU Connection    ${vdu_index}
    ${res}    param_vdu.perform_commissioning  scf_file=${scf_path}   timeout=1200     wait_for_completion=${True}
    ...     should_activate=${should_activate}
    ${result}    run keyword if  "${should_activate}"=="${False}"   param_vdu.get_status_of_perform_commissioning
    ...     operation_id=${res["id"]}     should_activate=${False}
    ${status}    set variable if    "${should_activate}"=="${False}"    ${result["status"]}     ${res["status"]}
    [Return]      ${status}
    [Teardown]    _vDU Disconnection


Fix Error and Get Plan Validation Result
    [Arguments]    ${plan_id}
    ${fix_error_response}=    param_vdu.fix_vdu_staged_plan_error    stage_plan_id=${plan_id}
    ${action_id}    Set Variable    ${fix_error_response['action_id']}
    wait until keyword succeeds    2min    5s    _Check Fix Error Status Should Be Expected
    ...                                          ${plan_id}    ${action_id}

    ${validate_plan_response}=    param_vdu.validate_plan    ${plan_id}
    ${action_id}    Set Variable    ${validate_plan_response['action_id']}
    ${validate_plan_response}=    wait until keyword succeeds    2min    5s    _Check Validate Full Plan Status Should Be Expected
    ...                                          ${plan_id}    ${action_id}

    ${validation_id}    Set Variable    ${validate_plan_response['validation_id']}
    ${errors}=    param_vdu.get_staged_plan_validation_results
    ...           ${plan_id}    ${validation_id}
    [Return]    ${errors}

_Check Fix Error Status Should Be Expected
    [Arguments]    ${plan_id}    ${action_id}
    ${fix_error_response}=    param_vdu.get_fix_vdu_staged_plan_operation_status    ${plan_id}    ${action_id}
    should be equal as strings    ${fix_error_response['status']}    success
    [Return]    ${fix_error_response}

_Check Activate Full Plan Status Should Be Expected
    [Arguments]    ${plan_id}    ${action_id}
    ${activate_plan_response}=    param_vdu.get_activate_plan_operation_status    ${plan_id}    ${action_id}
    should be equal as strings    ${activate_plan_response['status']}    success
    [Return]   ${activate_plan_response['status']}

_Check Upload Full Plan Status Should Be Expected
    [Arguments]    ${upload_action_id}
    ${upload_operation_response}=    param_vdu.get_upload_plan_operation_status    ${upload_action_id}
    should be equal as strings    ${upload_operation_response['status']}    success

_Check Validate Full Plan Status Should Be Expected
    [Arguments]    ${plan_id}    ${action_id}
    ${validate_plan_response}=    param_vdu.get_validate_plan_operation_status    ${plan_id}    ${action_id}
    should be equal as strings    ${validate_plan_response['status']}    success
    [Return]    ${validate_plan_response}

_Online Get Parameter Value
    [Arguments]   ${ne_type}   ${para_list}   ${mo_list}   ${vdu_index}=${0}   ${gnb_index}=${0}
    ...           ${timeout}=60
    [Documentation]   Get Parameter Value Online
    ${timeout}   convert to integer  ${timeout}
    should not be empty    ${para_list}   msg="para_list" can't be empty
    should not be empty    ${mo_list}   msg="mo_list" can't be empty
    ${out}  Run Keyword If   "${ne_type}"=="vdu"   Get VDU Parameters Value Online For Multi MO    vdu_index=${vdu_index}
    ...                gnb_index=${gnb_index}    para_list=${para_list}   mo_list=${mo_list}
    ...      ELSE IF   "${ne_type}"=="vcu"   Get VCU Parameter Value Online For Multiple MO   para_list=${para_list}
    ...                mo_list=${mo_list}  gnb_index=${gnb_index}
    ...      ELSE IF   "${ne_type}"=="gnb" or "${ne_type}"=="enb"  Get Parameter Value Online For Multiple MO For Classical
    ...                para_list=${para_list}   mo_list=${mo_list}  ne_type=${ne_type}   gnb_index=${gnb_index}
    [Return]  ${out}

Upload delta vCU By M2M
    [Arguments]    ${delta_vcu}    ${gnb_index}=${0}    ${should_activate}=${True}  ${wait_for_completion}=${True}
    ${alias}   VCU Connection    ${gnb_index}
    ${status}  ${out}     run keyword and ignore error     param_cu.perform_delta_recommissioning   delta_file=${delta_vcu}
    ...      wait_for_completion=${wait_for_completion}    connection=${alias}     should_activate=${should_activate}
    ${operation_info_dict}    run keyword if    "${status}"!="PASS"    Extract Operation Info     ${out}
    ${operation_id}   run keyword if  "${status}"!="PASS"  Extract Operation ID    ${out}
    ${error_info}    set variable if    "${status}"=="PASS"   ${None}     ${operation_info_dict}
    Run Keyword If    "${status}"!="PASS"    Fail    ${error_info}
    ${status}    set variable if    "${should_activate}"=="${False}" or "${wait_for_completion}"=="${False}"   ${out["id"]}    success
#    ${out}    run keyword if    "${wait_for_completion}"=="${False}"  Wait until keyword succeeds    1200    60s
#    ...    Check VCU Delta Plan Commission Success    operation_id=${out["id"]}    should_activate=${should_activate}
#    ${res}    set variable if    "${out}"!="${None}"    ${out}    ${status}
    RETURN    ${status}
    [Teardown]   run keyword and ignore error    VCU Disconnection


Update Full SCF By Rest For VCU By M2M
    [Arguments]    ${scf_path}    ${should_activate}=${True}
    log to console    \n*** start send commission on vdu ***
    ${alias}   VCU Connection
    ${res}    param_cu.perform_commissioning    scf_file=${scf_path}   timeout=1200    wait_for_completion=${True}
    ...     should_activate=${should_activate}
    ${result}    run keyword if  "${should_activate}"=="${False}"   param_cu.get_status_of_perform_commissioning
    ...     operation_id=${res["id"]}    should_activate=${False}
    ${status}    set variable if    "${should_activate}"=="${False}"    ${result["status"]}     ${res["status"]}
    [Return]     ${status}
    [Teardown]   run keyword and ignore error    VCU Disconnection


Upload delta vCU
    [Arguments]    ${delta_vcu}   ${use_m2m}=${True}   ${gnb_index}=${0}   ${timeout}=${300}
    [Documentation]    Sends JSON/XML delta commissioning file to vcu in vran deployment.
    ...    Author: Xiang Liang,gcao
    ...    Contact: liang.xiang@nokia-sbell.com,ge.cao@nokia-sbell.com
    ...   | Input Parameters | Man. | Description |
    ...   | delta_vcu | Yes | Path of delta file |
    ...   | use_m2m | NO | Whether use M2M API, if the actCli is disabled, it should be set to False, default is True. |
    ...   | gnb_index | No |  gnb index in testline configurtion file. Default is 0. |
    ...   | timeout | NO | Timeout for the delta commission finished, default is 300s. |
    ...
    ...   | Return Value | Description |
    ...   | None | NA |
    ...
    ...    Example
    ...    | Upload delta vCU | delta_vcu=/home/ute/testline_configuration/Delta_configuration_scf_MRBTS-10868.xml
    ...
    OperatingSystem.File Should Exist    ${delta_vcu}
    Log To Console    Uploading new delta: ${delta_vcu}
    ${path}   ${extension}=    Split Extension     ${delta_vcu}
    Run Keyword If    '${extension}' == 'json'    vcu_cm.Fast Delta Commissioning With Delta Json File   ${delta_vcu}
    ...                use_m2m=${use_m2m}   gnb_index=${gnb_index}   timeout=${timeout}
    Run Keyword If    '${extension}' == 'xml'     vcu_cm.Fast Delta Commissioning With Delta XML File   ${delta_vcu}
    ...                use_m2m=${use_m2m}   gnb_index=${gnb_index}   timeout=${timeout}


Upload delta vDU By M2M
    [Arguments]    ${delta_vdu}   ${vdu_index}=${0}    ${should_activate}=${True}  ${wait_for_completion}=${True}
    [Documentation]    Sends JSON/XML delta commissioning file
    _VDU Connection    ${vdu_index}
    ${status}    ${out}   run keyword and ignore error   param_vdu.perform_delta_recommissioning
    ...    delta_file=${delta_vdu}    wait_for_completion=${wait_for_completion}    should_activate=${should_activate}
    ${operation_info_dict}    run keyword if    "${status}"!="PASS"    Extract Operation Info     ${out}
    ${operation_id}   run keyword if  "${status}"!="PASS"  Extract Operation ID    ${out}
    ${error_info}    set variable if    "${status}"=="PASS"   ${None}     ${operation_info_dict}
    Run Keyword If    "${status}"!="PASS"    Fail    ${error_info}
    ${status}    set variable if    "${should_activate}"=="${False}" or "${wait_for_completion}"=="${False}"   ${out["id"]}    success
#    ${out}    run keyword if    "${wait_for_completion}"=="${False}"  Wait until keyword succeeds    1200    60s
#    ...    Check VDU Delta Plan Commission Success    operation_id=${out["id"]}    should_activate=${should_activate}
#    ${res}    set variable if    "${out}"!="${None}"    ${out}    ${status}

    [Return]   ${status}
    [Teardown]    run keyword and ignore error   _vDU Disconnection



_check_delta_plan_status_for_aic
    [Arguments]    ${ne_type}     ${vdu_index}   ${gnb_index}    ${plan_id}    ${should_activate}=${True}
    ...    ${check_time}=1200s    ${expect_status}=success
    ${res}    Run Keyword If   "${ne_type}"=="vcu"   _check_delta_plan_status_for_VCU    gnb_index=${gnb_index}
    ...    plan_id=${plan_id}    check_time=${check_time}   expect_status=${expect_status}    should_activate=${should_activate}
    ...    ELSE IF   "${ne_type}"=="vdu"   _check_delta_plan_status_for_VDU    vdu_index=${vdu_index}
    ...    plan_id=${plan_id}   check_time=${check_time}    expect_status=${expect_status}    should_activate=${should_activate}
    RETURN   ${res}

_check_delta_plan_status_for_VDU
    [Arguments]    ${vdu_index}   ${plan_id}   ${check_time}   ${expect_status}    ${should_activate}=${True}
    _VDU Connection    ${vdu_index}
#    ${excute_status}    ${out}    Wait until keyword succeeds    ${check_time}    60s
#    ...    Check VDU Delta Plan Commission Success    operation_id=${plan_id}    should_activate=${should_activate}
    ${status}    ${out}   run keyword and ignore error    continuous_checking_delta_plan_status_for_vDU    plan_id=${plan_id}
    ...     check_time=${check_time}   should_activate=${should_activate}
#    ${expect_status}    set variable if   "${expect_status}"=="success"   PASS   FAIL
    should be true    "${out["status"]}"=="${expect_status}"
    ${res}    set variable if    "${out["status"]}"=="failure"   ${out["validationErrors"]}    success
    RETURN   ${res}
    [Teardown]    run keyword and ignore error   _vDU Disconnection

continuous_checking_delta_plan_status_for_vDU
    [Arguments]    ${plan_id}   ${check_time}   ${should_activate}=${True}
    ${check_time}    Replace String    ${check_time}    s    ${EMPTY}
    ${check_time}    convert to integer    ${check_time}
    ${excute_times}    evaluate    (${check_time}+60)//60
    FOR    ${i}    IN RANGE    ${excute_times}
        ${status}    ${out}   run keyword and ignore error    Check VDU Delta Plan Commission Success    operation_id=${plan_id}
        ...    should_activate=${should_activate}
        sleep    50s
        continue for loop if    "${status}"=="FAIL"
        exit for loop if    "${out["status"]}"=="success" or "${out["status"]}"=="failure"
    END
    RETURN   ${out}


_check_delta_plan_status_for_VCU
    [Arguments]    ${gnb_index}    ${plan_id}   ${check_time}   ${expect_status}    ${should_activate}=${True}
    ${alias}   VCU Connection    ${gnb_index}
#    ${excute_status}    ${out}    run keyword and ignore error    Wait until keyword succeeds    ${check_time}    60s
#    ...    Check VCU Delta Plan Commission Success    operation_id=${plan_id}    should_activate=${should_activate}
    ${status}    ${out}   run keyword and ignore error    continuous_checking_delta_plan_status_for_vCU   plan_id=${plan_id}
    ...     check_time=${check_time}   should_activate=${should_activate}
    should be true    "${out["status"]}"=="${expect_status}"
    ${res}    set variable if    "${out["status"]}"=="failure"   ${out["validationErrors"]}    success
    RETURN   ${res}
    [Teardown]   run keyword and ignore error    VCU Disconnection    connection=${alias}


continuous_checking_delta_plan_status_for_vCU
    [Arguments]    ${plan_id}   ${check_time}    ${should_activate}=${True}
    ${check_time}    Replace String    ${check_time}    s    ${EMPTY}
    ${check_time}    convert to integer    ${check_time}
    ${excute_times}    evaluate    (${check_time}+60)//60
    FOR    ${i}    IN RANGE    ${excute_times}
        ${status}    ${out}   run keyword and ignore error    Check VCU Delta Plan Commission Success    operation_id=${plan_id}
        ...    should_activate=${should_activate}
        sleep    50s
        continue for loop if    "${status}"=="FAIL"
        exit for loop if    "${out["status"]}"=="success" or "${out["status"]}"=="failure"
    END
    RETURN   ${out}


Upload delta vDU
    [Arguments]    ${delta_vdu}   ${use_m2m}=${True}   ${vdu_index}=${0}  ${gnb_index}=${0}   ${timeout}=${300}
    [Documentation]    Sends JSON/XML delta commissioning file to vdu in vran deployment.
    ...    Author: Xiang Liang,gcao
    ...    Contact: liang.xiang@nokia-sbell.com,ge.cao@nokia-sbell.com
    ...   | Input Parameters | Man. | Description |
    ...   | delta_vdu | Yes | Path of delta file |
    ...   | use_m2m | NO | Whether use M2M API, if the actCli is disabled, it should be set to False, default is True. |
    ...   | vdu_index | No  | vdu index in testline configuration file. Default is 0. |
    ...   | gnb_index | No |  gnb index in testline configurtion file. Default is 0. |
    ...   | timeout | NO | Timeout for the delta commission finished, default is 300s. |
    ...
    ...   | Return Value | Description |
    ...   | None | NA |
    ...
    ...    Example
    ...    | Upload delta vDU | delta_vdu=/home/ute/testline_configuration/Delta_configuration_scf_MRBTS-10868.xml
    ...
    OperatingSystem.File Should Exist    ${delta_vdu}
    Log To Console    Uploading new delta: ${delta_vdu}
    ${path}   ${extension}=    Split Extension     ${delta_vdu}
    Run Keyword If    '${extension}' == 'json'    vdu_cm.Fast Delta Commissioning With Delta Json File   ${delta_vdu}
    ...                use_m2m=${use_m2m}   vdu_index=${vdu_index}   gnb_index=${gnb_index}   timeout=${timeout}
    Run Keyword If    '${extension}' == 'xml'     vdu_cm.Fast Delta Commissioning With Delta XML File   ${delta_vdu}
    ...                use_m2m=${use_m2m}   vdu_index=${vdu_index}   gnb_index=${gnb_index}   timeout=${timeout}


#######################VCU by internal ####################
VCU Online Change Parameters
    [Arguments]    ${para_list}   ${value_list}   ${mo_list}   ${gnb_index}=0    ${should_activate}=${True}
    ...     ${operation}=update
    [Documentation]  VCU Online Change Parameters, it will not change parameters if its original value is same as new one, it supports multiple MO
    Log To Console    VCU Online Change Parameters...
    should not be empty   ${para_list}   msg="para_list" can't be empty
    should not be empty   ${value_list}   msg="value_list" can't be empty
    should not be empty   ${mo_list}   msg="mo_list" can't be empty
    ${para_list}   _Add Backslash   ${para_list}
    log to console    ${operation}
    ${origin_para_value_dict}   Get VCU Parameter Value Online For Multiple MO
      ...   para_list=${para_list}   mo_list=${mo_list}  gnb_index=${gnb_index}
    ${updated_para_value_dict}    _Convert Parameters From List To Dict For Multiple MO
      ...   para_list=${para_list}  value_list=${value_list}  mo_list=${mo_list}  origin_para_value_dict=${origin_para_value_dict}

    ${compare_result}  Run Keyword And Return Status   Dictionaries Should Be Equal    ${origin_para_value_dict}  ${updated_para_value_dict}
    ${need_update}  Set Variable If  "${compare_result}"=="${True}"  ${False}  ${True}
    VCU Connection    ${gnb_index}
    ${updated_paras_list}   Generate Delta Parameters For Multiple MO For VCU   updated_para_value_dict=${updated_para_value_dict}
        ...   origin_para_value_dict=${origin_para_value_dict}
    ${res}   run keyword if     "${need_update}"== "${True}"    VCU Online Change Parameters Without Checking
    ...   para_list=${updated_paras_list}     should_activate=${should_activate}

#    ${ret_dict}   Create Dictionary   need_update=${need_update}
#      ...   origin_para_value_dict=${origin_para_value_dict}
#      ...   updated_para_value_dict=${updated_para_value_dict}
    [Return]       ${res}
    [Teardown]    run keyword and ignore error   VCU Disconnection


#######################VCU by M2M ####################
VCU Online Change Parameters By M2M
    [Arguments]    ${para_list}   ${value_list}   ${mo_list}   ${gnb_index}=0    ${should_activate}=${True}
    ...     ${operation}=update       ${wait_for_completion}=${True}
    [Documentation]  VCU Online Change Parameters, it will not change parameters if its original value is same as new one, it supports multiple MO
    Log To Console    VCU Online Change Parameters...
    should not be empty   ${para_list}   msg="para_list" can't be empty
    should not be empty   ${value_list}   msg="value_list" can't be empty
    should not be empty   ${mo_list}   msg="mo_list" can't be empty
#    ${para_list}   _Add Backslash   ${para_list}
    log to console    ${operation}
    ${origin_para_value_dict}   Get VCU Parameter Value Online For Multiple MO
      ...   para_list=${para_list}   mo_list=${mo_list}  gnb_index=${gnb_index}
    ${updated_para_value_dict}    _Convert Parameters From List To Dict For Multiple MO
      ...   para_list=${para_list}  value_list=${value_list}  mo_list=${mo_list}  origin_para_value_dict=${origin_para_value_dict}

    ${compare_result}  Run Keyword And Return Status   Dictionaries Should Be Equal    ${origin_para_value_dict}  ${updated_para_value_dict}
    ${need_update}  Set Variable If  "${compare_result}"=="${True}"  ${False}  ${True}
    VCU Connection    ${gnb_index}
#    ${updated_paras_list}   Generate Delta Parameters For Multiple MO For VCU   updated_para_value_dict=${updated_para_value_dict}
#        ...   origin_para_value_dict=${origin_para_value_dict}

    ${updated_paras_list}   ulti.generate_delta_parameters_for_multiple_mo_for_m2m   updated_para_value_dict=${updated_para_value_dict}
      ...   origin_para_value_dict=${origin_para_value_dict}
    ${updated_paras_data}     Convert JSON Data To String    ${updated_paras_list}
    log to console    ${updated_paras_data}
    ${res}   run keyword if     "${need_update}"== "${True}"    VCU Online Change Parameters Without Checking By M2M
    ...   should_activate=${should_activate}     para_list=${updated_paras_data}  wait_for_completion=${wait_for_completion}
    [Return]       ${res}
    [Teardown]    run keyword and ignore error   VCU Disconnection



VCU Online Change Parameters Without Checking By M2M
    [Arguments]   ${should_activate}     ${para_list}     ${alias}=${None}       ${wait_for_completion}=${True}
    ${status}  ${out}     run keyword and ignore error     param_cu.perform_delta_recommissioning      delta_file=${para_list}
    ...         wait_for_completion=${wait_for_completion}    should_activate=${should_activate}    connection=${alias}
    ${operation_info_dict}    run keyword if    "${status}"!="PASS"    Extract Operation Info     ${out}
    ${operation_id}   run keyword if  "${status}"!="PASS"  Extract Operation ID    ${out}
    ${error_info}    set variable if    "${status}"=="PASS"   ${None}     ${operation_info_dict}
    Run Keyword If    "${status}"!="PASS"    Fail    ${error_info}
    ${status}    set variable if    "${should_activate}"=="${False}" or "${wait_for_completion}"=="${False}"   ${out["id"]}    success
#    ${out}    run keyword if    "${wait_for_completion}"=="${False}"  Wait until keyword succeeds    1200    60s
#    ...    Check VCU Delta Plan Commission Success    operation_id=${out["id"]}    should_activate=${should_activate}
#    ${res}    set variable if    "${out}"!="${None}"    ${out}    ${status}
    RETURN   ${status}

Check VCU Delta Plan Commission Success
    [Arguments]    ${operation_id}    ${should_activate}
    ${out}    param_cu.get_status_of_perform_delta_recommissioning    operation_id=${operation_id}
    ...    should_activate=${should_activate}
#    Should Be True  "${out["status"]}"=="success"
    RETURN    ${out}



VCU Check Current Parameter Value As Expected
    [Arguments]   ${mo_list}    ${para_list}    ${expected_value_list}    ${gnb_index}=0
    [Documentation]    Check Current Parameter Value As Expected, suggest use it after "VDU Online Change Parameters"
    ...   *AUTHOR* ge.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...
    ...   | Input Parameters    | Man. | Description |
    ...   | ${para_list}  |  Yes   | Create List  | staticRoutes/0/destIpAddr |
    ...   | ${expected_value_list} |  Yes |  Create List |  1.1.1.1 |
    ...   | ${mo_list}    |  Yes | Create List  |  MRBTS-${bts_id}/TNLSVC-1/TNL-2/IPNO-1/IPRT-1 |
    ...
    ...    *RETURN VALUE*
    ...    compare_result, True or False
    ...
    ...  Example
    ...  | ${mo}        | Set Variable | MRBTS-123/TNLSVC-1/TNL-3/ETHSVC-1/ETHIF-1 |
    ...  | ${para_list} | Create List | enableShaping    | sirTotal | sbsTotal | shapingOverhead |
    ...  | ${value_list} | Create List | true            | 10000    | 20000    | Ethernet frame |
    ...  | ${mo_list} |  Create List   | ${mo}           | ${mo}    | ${mo}    | ${mo}          |
    ...  | ${ret} |  VCU Online Change Parameters | para_list=${para_list} | value_list=${value_list} | mo_list=${mo_list} |
    ...  | VCU Check Current Parameter Value As Expected | para_list=${para_list} | expected_value_list=${expected_value_list} | mo_list=${mo_list} |
    ...  | VCU Online Restore Parameters | ${ret} |
    ...
    ${para_list}   _Add Backslash   ${para_list}
    ${origin_para_value_dict}    Get VCU Parameter Value Online For Multiple MO
      ...   para_list=${para_list}   mo_list=${mo_list}  gnb_index=${gnb_index}
    ${updated_para_value_dict}   _Convert Parameters From List To Dict For Multiple MO
      ...   para_list=${para_list}  value_list=${expected_value_list}  mo_list=${mo_list}   convert_empty_to_none=${True}
    ${compare_result}  run keyword and return status   dictionaries should be equal    ${origin_para_value_dict}  ${updated_para_value_dict}
    Should Be True   "${compare_result}"=="${True}"
    [Return]   ${compare_result}

_Adjust List Witout Parameter Name For Add Operation
    [Arguments]   ${origin_para_value_dict}  ${updated_para_value_dict}
    [Documentation]  For 'add' operation for <list name="freqBandIndicatorEutra"><p>1</p></list>, we need check the case
    ...   that user tries to add an existing value in the list. In this case, we should not submit delta plan for it.
    ...
    ...   *AUTHOR* ge.cao@nokia-sbell.com
    ...  Change History
    ...
    ${mo_keys}   Get Dictionary Keys  ${updated_para_value_dict}
    FOR    ${mo}    IN     @{mo_keys}
        ${one_mo_para_value_info_original}  Set Variable   ${origin_para_value_dict["${mo}"]}
        ${one_mo_para_value_info_updated}   Set Variable   ${updated_para_value_dict["${mo}"]}
        _Adjust List Witout Parameter Name For Add Operation For One Mo
           ...   mo=${mo}   origianl=${one_mo_para_value_info_original}
           ...   updated=${one_mo_para_value_info_updated}
    END


_Remove Duplicated Items
    [Arguments]   ${origin_para_value_dict}  ${updated_para_value_dict}
    [Documentation]  _Remove Duplicated Items
    ...
    ...   *AUTHOR* ge.cao@nokia-sbell.com
    ...  Change History
    ...  2023.12.31 ,ge.cao@nokia-sbell.com, support try to add an existing value for <list name="freqBandIndicatorEutra"><p>1</p></list>
    ...
    ${mo_keys}   Get Dictionary Keys  ${updated_para_value_dict}
    FOR    ${mo}    IN     @{mo_keys}
        ${one_mo_para_value_info_original}  Set Variable   ${origin_para_value_dict["${mo}"]}
        ${one_mo_para_value_info_updated}   Set Variable   ${updated_para_value_dict["${mo}"]}
        _Remove Duplicated Items For One Mo
           ...   origianl=${one_mo_para_value_info_original}   updated=${one_mo_para_value_info_updated}
    END

    FOR    ${mo}    IN     @{mo_keys}
        ${one_mo_para_value_info_original}  Set Variable   ${origin_para_value_dict["${mo}"]}
        ${one_mo_para_value_info_updated}   Set Variable   ${updated_para_value_dict["${mo}"]}
        Run Keyword If   ${one_mo_para_value_info_original.__len__()}==0  Remove From Dictionary   ${origin_para_value_dict}  ${mo}
        Run Keyword If   ${one_mo_para_value_info_updated.__len__()}==0  Remove From Dictionary   ${updated_para_value_dict}  ${mo}
    END


_Remove Duplicated Items For One Mo
    [Arguments]   ${origianl}   ${updated}
    ${dict_keys}   Get Dictionary Keys  ${origianl}
    FOR  ${tmp_key}  IN  @{dict_keys}
        ${original_value}  Set Variable  ${origianl["${tmp_key}"]}
        ${updated_value}  Set Variable  ${updated["${tmp_key}"]}
        Run Keyword If  "${original_value}"=="${updated_value}"  Remove From Dictionary   ${origianl}  ${tmp_key}
        Run Keyword If  "${original_value}"=="${updated_value}"  Remove From Dictionary   ${updated}  ${tmp_key}
    END


_Adjust List Witout Parameter Name For Add Operation For One Mo
    [Arguments]   ${mo}   ${origianl}   ${updated}
    ${dict_keys}   Get Dictionary Keys  ${origianl}
    FOR  ${tmp_key}  IN  @{dict_keys}
        ${para_path}  Set Variable  ${tmp_key}
        @{para_list}  Split String  ${para_path}  /
        ${original_value}  Set Variable  ${origianl["${para_path}"]}
        ${need_handle}   Evaluate  ${para_list.__len__()}==3 and "${original_value}"=="${None}"
        Continue For Loop If   "${need_handle}"=="${False}"

        ${updated_value}  Set Variable  ${updated["${para_path}"]}
        ${status}  ${para_list_value}     Get VCU Parameter Value Online
         ...  dn=${mo}  parameter_path=${para_path}    return_list=${True}

        ${value_count}   Count Values In List   ${para_list_value}  value=${updated_value}
        Run Keyword If   ${value_count}>=1
           ...   Set To Dictionary  ${origianl}   ${tmp_key}   ${updated_value}
    END

_Add Backslash
   [Arguments]  ${para_list}
   ${rtn}   Create List
   FOR  ${i}   IN  @{para_list}
       ${start_with_backslash}   Set Variable   ${i.startswith("/")}
       ${tmp}  Set Variable If  "${start_with_backslash}"=="${True}"   ${i}   /${i}
       Append To List   ${rtn}   ${tmp}
   END
   [Return]  ${rtn}

_Is List For Param
    [Arguments]    ${input}
    ${result}    Run Keyword And Return Status    Should Be True    isinstance(${input}, list)
    [Return]    ${result}


Get VCU Parameter Value Online For Multiple MO
    [Arguments]   ${para_list}    ${mo_list}    ${gnb_index}=0
    [Documentation]   Get VCU Parameter Value Online For Multiple MO
    ...   *AUTHOR* ge.cao@nokia-sbell.com
    ...  Change History
    ...
    ...   | Input Parameters    | Man. | Description |
    ...   | para_list    | yes | the names of parameters list |
    ...   | mo_list    | yes | the mo distname list that contains the parameter like MRBTS-3218/NRBTS-1/NRCELL-1 |
    ...
    ...   *RETURN VALUE*
    ...   | origin_para_value_dict    | yes | the parameters and value in testline |
    ...
    ...   Example
    ...   | ${para_list} | Create List | btsName | btsAccountLockoutDuration |
    ...   | ${mo_list} | Create List | MRBTS-1234 | MRBTS-1234/MNL-1/AMGR-1/LUAC-1 |
    ...  | ${para_value_dict} | Get VCU Parameter Value Online For Multiple MO | para_list=${para_list} | mo_list=${mo_list} |
    ...
    ${origin_para_value_dict}   Create Dictionary
    ${length}=   Get Length    ${para_list}
    run keyword and ignore error   param_cu.disconnect    connection=${None}
    ${alias}   VCU Connection    ${gnb_index}
    FOR    ${i}    IN RANGE    0     ${length}
        ${mo}  Set Variable   ${mo_list[${i}]}
        ${mo_keys}   Evaluate  list(${origin_para_value_dict})
        ${mo_dict}   Run Keyword If   "${mo}" in ${mo_keys}  Set Variable  ${origin_para_value_dict["${mo}"]}
         ...  ELSE   Create Dictionary
        ${status}  ${value}   Run Keyword And Ignore Error   Get VCU Parameter Value Online
         ...  dn=${mo}  parameter_path=${para_list[${i}]}      alias=${alias}
        ${value_current}  Set Variable If  '${status}'=='PASS'   ${value}  ${None}
        ${is_a_list}  _Is List For Param   ${value_current}
        ${value_current}  Set Variable If  '${is_a_list}'=='${True}'   ${value_current[0]}  ${value_current}
        Set to Dictionary  ${mo_dict}   ${para_list[${i}]}   ${value_current}
        Set to Dictionary  ${origin_para_value_dict}  ${mo}   ${mo_dict}
    END
    [Teardown]    run keyword and ignore error   param_cu.disconnect    connection=${None}
    [Return]  ${origin_para_value_dict}

_Convert Parameters From List To Dict For Multiple MO
    [Arguments]   ${para_list}   ${value_list}  ${mo_list}   ${origin_para_value_dict}=${None}   ${convert_empty_to_none}=${False}
    [Documentation]   Convert Updating Parameters From List To Dict For Multiple MO
    ...   *AUTHOR* ge.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | para_list    | yes | the names of parameters list |
    ...   | value_list   | yes | the values of parameters list, must be one-to-one match between the parameter value and the parameter name|
    ...   | mo_list     | yes | mo list |
    ...
    ...   *RETURN VALUE*
    ...  dictionray of MO
    ...
    ...   Example
    ...  | ${Updated_Paras_Dict}=    Convert Updating Parameters From List To Dict | para_list=${para_list} | value_list=${value_list} |
    ...
    ${ret_dict}    Create Dictionary
    ${length}=   Get Length    ${para_list}
    FOR    ${i}    IN RANGE    0     ${length}
        ${mo}  Set Variable   ${mo_list[${i}]}
        ${mo_keys}   Evaluate  list(${ret_dict})
        ${mo_dict}   Run Keyword If   "${mo}" in ${mo_keys}  Set Variable  ${ret_dict["${mo}"]}
                    ...  ELSE   Create Dictionary
        ${value_for_update}    Set Variable    ${value_list[${i}]}
        ${origin_value}   Set Variable   ${origin_para_value_dict["${mo}"]["${para_list[${i}]}"]}
        ${value_for_ramdon_list}    Run Keyword If     "||" in "${value_for_update}"    _Choice Random List Parameter
        ...    random_list=${value_for_update}    origin_value=${origin_value}
        ${value_for_update}   Set Variable If   "${value_for_ramdon_list}"=="${None}"   ${value_for_update}    ${value_for_ramdon_list}
        ${value}  Set Variable If  "${convert_empty_to_none}"=="${True}" and """${value_for_update}"""=="""${EMPTY}"""  ${None}  ${value_for_update}
        Set to Dictionary  ${mo_dict}   ${para_list[${i}]}   ${value}
        Set to Dictionary  ${ret_dict}  ${mo}   ${mo_dict}
    END
    [Return]  ${ret_dict}

_Choice Random List Parameter
    [Arguments]   ${random_list}    ${origin_value}
    @{random_list_new}   Split string    ${random_list}     separator=||
    Remove Values From List   ${random_list_new}   ${origin_value}
    ${new_value}   Evaluate    random.choice(${random_list_new})   modules=random
    [Return]  ${new_value}

Get VCU Parameter Value Online
   [Arguments]   ${dn}    ${parameter_path}    ${return_list}=${False}    ${alias}=${None}
    [Documentation]   Get VCU Parameter Value Online
    ...  author:   *AUTHOR* ge.cao@nokia-sbell.com
    ...  Change History
    ...
    ...    | Input Parameters | Man. | Description |
    ...    |  dn             | Yes   |  Distname of parameter  |
    ...    |  parameter_path |  Yes  |  simple and simple list parameter given like btsName or nrCellList |
    ...                             |  complex parameter given the struncture like staticRoutes/1/destIpAddr
    ...    |  gnb_index      | No   |  gnb_index, default is 0  |
    ...    |  return_list    | No |  ${True}-return list, otherwise return list member, default is ${False} |
    ...
    ...    *RETURN VALUE*
    ...    parameter value, if it's simple or complex parameter, returns string type
    ...    if it's a simple list type parameter, it will return a list.
    ...
    ...    Example
    ...  | ${btsid} | Get MRBTS Id From vCU SCF |
    ...  | Get VCU Parameter Value Online | dn=MRBTS-${btsid}     |   parameter_path=btsName  |
    ...  | Get VCU Parameter Value Online | dn=MRBTS-${btsid}     |   parameter_path=/btsName  |
    ...  | Get VCU Parameter Value Online | dn=MRBTS-${btsid}/NRBTS-5247/NRCELLGRP-0 | parameter_path=nrCellList |
    ...  | Get VCU Parameter Value Online | dn=MRBTS-${btsid}/NRBTS-5247/NRCELLGRP-0 | parameter_path=/nrCellList |
    ...  | Get VCU Parameter Value Online | dn=MRBTS-${btsid}/TNLSVC-1/TNL-3/IPNO-1/IPRT-1 | parameter_path=staticRoutes/1/destIpAddr |
    ...  | Get VCU Parameter Value Online | dn=MRBTS-${btsid}/TNLSVC-1/TNL-3/IPNO-1/IPRT-1 | parameter_path=/staticRoutes/1/destIpAddr |
    ...
    ${dn}   Set Variable   ${dn.strip()}
    ${parameter_path}   Set Variable   ${parameter_path.strip()}
    @{para_list}  Split String  ${parameter_path}  /

    ${is_number}  ulti.is_numeric   ${para_list[-1]}
    ${index}   Set Variable If   "${is_number}"=="${True}"   -2  -1

    ${paras_info}=   param_cu.search_parameters_of_current_plan   parameter_name=${para_list[${index}]}  items_per_page=${2000}  connection=${alias}

    ${starts_with_root}   Set Variable   ${parameter_path.startswith("/")}
    ${para_struct_path}  Run Keyword If  "${starts_with_root}"=="${True}"   Set Variable   ${parameter_path.replace("/", "", 1)}
    ...    ELSE   Set Variable   ${parameter_path}

    ${value}   ulti.get_online_parameter_value  paras_info=${paras_info}  dn=${dn}  para_struct_path=${para_struct_path}  return_list=${return_list}

    ${list_para_index}   Set Variable If   "${is_number}"=="${True}"   ${para_list[-1]}
    ${value}  Set Variable If     "${is_number}"=="${True}" and ${list_para_index}<${value.__len__()}    ${value[${list_para_index}]}
       ...    "${is_number}"=="${True}"   ${None}
       ...    ${value}
    [Return]  ${value}




Generate Delta Parameters For Multiple MO For VCU
    [Arguments]   ${updated_para_value_dict}  ${origin_para_value_dict}
    [Documentation]   Generate Delta Parameters For Multiple MO For VCU
    ${ret_list}    Create List
    ${mo_keys}   Get Dictionary Keys  ${updated_para_value_dict}
    FOR    ${mo}    IN     @{mo_keys}
        ${one_mo_para_value_info}  Set Variable   ${updated_para_value_dict["${mo}"]}
        ${one_mo_to_be_updated}   Copy Dictionary   ${one_mo_para_value_info}
        ${one_mo_to_be_updated_list}   _Handle One MO For Generate Delta Parameters For Changing Value   mo_dn=${mo}
            ...   one_mo_para_value_info=${one_mo_to_be_updated}   origin_para_value_dict=${origin_para_value_dict}
         Append To List   ${ret_list}   ${one_mo_to_be_updated_list}
    END
    [Return]  ${ret_list}

_Handle One MO For Generate Delta Parameters For Changing Value
    [Arguments]  ${mo_dn}   ${one_mo_para_value_info}  ${origin_para_value_dict}
    [Documentation]   _Handle One MO For Generate Delta Parameters For Changing Value
    ${one_mo_para_list}   Create List
    ${para_keys}   Get Dictionary Keys  ${one_mo_para_value_info}
    FOR   ${para}   IN   @{para_keys}
        ${new_parameter_value}   Set Variable   ${one_mo_para_value_info["${para}"]}

        #get operation
        ${original_mo_value}  Get From Dictionary   ${origin_para_value_dict}   ${mo_dn}
        ${original_parameter_value}   Set Variable   ${original_mo_value["${para}"]}
        ${operation}   Set Variable If   "${original_parameter_value}"!="${None}" and "${new_parameter_value}"!="${None}"  replace
           ...  "${original_parameter_value}"!="${None}" and "${new_parameter_value}"=="${None}"   remove
           ...  "${original_parameter_value}"=="${None}" and "${new_parameter_value}"!="${None}"   add   remove
        ${tmp_dict}    Create Dictionary   parameter_path=${para}   value=${new_parameter_value}   operation_type=${operation}

        @{para_list}  Split String  ${para}  /
        ${is_first_para_of_list}  ulti.is_numeric   ${para_list[-1]}
        # for "remove" operation, it does not need "/staticRoutes/4", but need "/freqBandIndicatorEutra/4"
#        ${add_to_list}   Run Keyword If   "${operation}"=="remove" and "${is_first_para_of_list}"=="${True}"
#           ...  _Need Add To List  para=${para}  para_keys=${para_keys}
#           ...  ELSE   Set Variable   ${True}
#
#        Run Keyword If  "${add_to_list}"=="${True}"   Append To List   ${one_mo_para_list}   ${tmp_dict}
        Append To List   ${one_mo_para_list}   ${tmp_dict}
    END
    ${one_mo_ret_dict}   Create Dictionary   mo_dn=${mo_dn}  one_mo_para_list=${one_mo_para_list}
    [Return]  ${one_mo_ret_dict}

VCU Online Change Parameters Without Checking
    [Arguments]     ${para_list}     ${delta_plan_name}=delta_plan    ${alias}=${None}   ${should_activate}=${True}
    [Documentation]   VCU Online Change Parameters Without Checking, it supports to change multiple MOs' parameters.
    ${para_list}   _Add Backslash For Parameter   ${para_list}

    ${delta_plan_list}     param_cu.get_delta_plan_list
    Run Keyword If  ${delta_plan_list}  param_cu.delete_delta_plan  ${delta_plan_list[0]['plan_id']}   connection=${alias}
    ${delta_res}=  param_cu.generate_delta_plan  plan_name=${delta_plan_name}   connection=${alias}
    ${delta_plan_id}=  Set Variable  ${delta_res['plan_id']}
    Wait until keyword succeeds  3x  2s   _Generating Delta Plan Operation Should Be Successful    ${delta_res['action_id']}
    ...  alias=${alias}

    FOR  ${one_mo}  IN   @{para_list}
       _VCU Handle One Mo Parameters  one_mo=${one_mo}   delta_plan_id=${delta_plan_id}     alias=${alias}
    END

	${validate_res}=   param_cu.validate_delta_plan   plan_id=${delta_plan_id}     connection=${alias}
    Wait until keyword succeeds  5x  5s
    ...  _Validating Delta Plan Operation Should Be Successful   plan_id=${delta_plan_id}  action_id=${validate_res['action_id']}
    ...   alias=${alias}
    ${res}   run keyword if    "${should_activate}"=="${True}"
    ...  activate_cu_delta_plan   plan_id=${delta_plan_id}
    ${res}    set variable if    "${res}"!="${None}"     ${res}    ${delta_plan_id}
    [Return]  ${res}


activate_cu_delta_plan
    [Arguments]   ${gnb_index}=${0}    ${plan_id}=dp_00000000
    run keyword and ignore error    VCU Connection    gnb_index=${gnb_index}
    ${active_res}=   param_cu.activate_delta_plan   plan_id=${plan_id}
    ${res}   Wait until keyword succeeds  600  30
	...     _Check Plan Activate Status Should Be As Expected For VCU   plan_id=${plan_id}
	...     operation_id=${active_res['operation_id']}    expected_status=success
	[Teardown]    run keyword and ignore error   VCU Disconnection
	[Return]    ${res}

activate_classical_delta_plan
    [Arguments]   ${ne_type}    ${plan_id}    ${gnb_index}=${0}
    run keyword and ignore error     _classical_bts.login    gnb_index=${gnb_index}
    ...    product_type=${ne_type}
    ${active_res}   coam_param.activate_plan   plan_id=${plan_id}
    should be equal    ${active_res['commissioningResult']['activationResult']['resultNode']['parameters']['result']}
    ...    Success
    [Return]  ${active_res['commissioningResult']['activationResult']['resultNode']['parameters']['result']}
    [Teardown]   Run Keyword And Ignore Error     coam_param.teardown


_activate_plan_operation
    [Arguments]   ${ne_type}    ${plan_id}   ${gnb_index}=${0}
    ${classical_type}   create list  gnb  enb
    ${res}   run keyword if   "${ne_type}"=="vdu"   activate_du_delta_plan
    ...    plan_id=${plan_id}
    ...    ELSE IF   "${ne_type}"=="vcu"   activate_cu_delta_plan   gnb_index=${gnb_index}   plan_id=${plan_id}
    ...    ELSE IF   "${ne_type}" in ${classical_type}   activate_classical_delta_plan  ${ne_type}   ${plan_id}
    ...    gnb_index=${gnb_index}
    [Return]    ${res}


_Check Plan Activate Status Should Be As Expected For VCU
    [Arguments]   ${plan_id}  ${operation_id}  ${expected_status}
    ${operation_response}=  param_cu.get_operation_state_of_activating_plan    ${plan_id}   ${operation_id}
    should be true    "${operation_response["status"]}"=="${expected_status}"
    [Return]  ${operation_response["status"]}


_Generating Delta Plan Operation Should Be Successful
    [Arguments]   ${action_id}   ${alias}=default
    [Documentation]   _Generating Delta Plan Operation Should Be Successful
    ...  author: ge.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | action_id | yes | Generating delta plan's action id|
    ...    *RETURN VALUE*  None
    ...    Example
    ...    | _Generating Delta Plan Operation Should Be Successful | action_id=xxx |
	${res}   param_cu.get_action_state_of_generating_delta_plan   ${action_id}   connection=${alias}
	should be equal as strings  ${res['status']}  success

_VCU Handle One Mo Parameters
    [Arguments]   ${one_mo}   ${delta_plan_id}   ${alias}=${None}
    ${mo_dn}   Set Variable   ${one_mo["mo_dn"]}
    ${one_mo_para_list}   Set Variable   ${one_mo["one_mo_para_list"]}
    _VCU Online Change Single Mo Parameters Without Activate   delta_plan_id=${delta_plan_id}   para_list=${one_mo_para_list}
    ...   mo_dn=${mo_dn}   alias=${alias}

#_Activating Delta Plan Operation Should Be Successful
#    [Arguments]  ${plan_id}  ${operation_id}   ${alias}=default
#    [Documentation]   _Activating Delta Plan Operation Should Be Successful
#    ...   *Author*: ge.cao@nokia-sbell.com
#    ...   *Change History*
#    ...    *Parameter Description*
#    ...    | Input Parameters | Man. | Description |
#    ...    | plan_id | yes | delta plan id |
#    ...    | operation_id | yes | active delta plan feedback id |
#    ...    *RETURN VALUE*  None
#    ...    *Example*
#    ...    | _Activating Delta Plan Operation Should Be Successful | plan_id=xxx | operation_id=xxx |
#    ${res}=   param_cu.get_delta_plan_list   connection=${alias}
#    FOR   ${r}   IN   @{res}
#        ${r_plan_id}   Set Variable   ${r}[plan_id]
#        Should Not Be Equal As Strings   ${r_plan_id}   ${plan_id}
#    END

_Validating Delta Plan Operation Should Be Successful
    [Arguments]  ${plan_id}  ${action_id}   ${alias}=default
    [Documentation]   _Validating Delta Plan Operation Should Be Successful
    ...  author: ge.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | plan_id | yes | delta plan id |
    ...    | action_id | yes | Update parameter operation feedback action id |
    ...    *RETURN VALUE*  None
    ...    Example
    ...    | _Validating Delta Plan Operation Should Be Successful  | plan_id=xxx | action_id=xxx |
    ${res}=    param_cu.get_action_state_of_validating_delta_plan   ${plan_id}  ${action_id}   connection=${alias}
	should be equal as strings  ${res['status']}  success

_VCU Online Change Single Mo Parameters Without Activate
    [Arguments]    ${delta_plan_id}   ${para_list}    ${mo_dn}   ${alias}=${None}
    [Documentation]   CU Online Change Single Mo Parameters via rest.
    ...  author: ge.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | delta_plan_id    | yes | delta_plan_id |
    ...    | para_list        | yes | modify parameters list |
    ...    | mo_dn            | yes | needed modify parameters's modn |
    ...    *RETURN VALUE*  None
    ...
    ...    Example
    ...
    ${uuid}   _Get CU Specifical MO UUID   plan_id=${delta_plan_id}    mo_dn=${mo_dn}   alias=${alias}
    ${update_res}=  param_cu.update_parameters_of_delta_plan   plan_id=${delta_plan_id}  mo_uuid=${uuid}
    ...   parameter_change_list=${para_list}   connection=${alias}
    Wait until keyword succeeds  5x  5s
	...  _Update Parameters Operation Should Be Successful	plan_id=${delta_plan_id}  action_id=${update_res['action_id']}
	...  alias=${alias}

_Get CU Specifical MO UUID
    [Arguments]   ${plan_id}  ${mo_dn}   ${alias}=default
    [Documentation]   _Get CU Specifical MO UUID
    ...  author: ge.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | plan_id | yes | delta plan id|
    ...    | mo_dn | yes | needed modify parameters's modn |
    ...    *RETURN VALUE*  ${mouuid}
    ...    Example
    ...    |  ${mouuid} | _Get CU Specifical MO UUID | plan_id=${delta_plan_id} | mo_dn=MRBTS-1/NRBTS-1|

    @{name_list}=   split_string    ${mo_dn}   /
    set suite variable  ${parent_mouuid}    ${EMPTY}
    FOR  ${name}  IN  @{name_list}
         ${mouuid}  _Get CU Specifical MO UUID via DN Name   ${plan_id}  ${name}   alias=${alias}
    END
    [Return]   ${mouuid}

_Update Parameters Operation Should Be Successful
    [Arguments]   ${plan_id}  ${action_id}   ${alias}=default
    [Documentation]   CU Online Parameter Change By Rest
    ...  author: ge.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | plan_id | yes | delta plan id |
    ...    | action_id | yes | Update parameter operation feedback action id |
    ...    *RETURN VALUE*  None
    ...    Example
    ...    | _Update Parameters Operation Should Be Successful  | plan_id=xxx | action_id=xxx |
	${res}=  param_cu.get_action_state_of_updating_parameters_of_delta_plan  plan_id=${plan_id}  action_id=${action_id}
	...   connection=${alias}
	should be equal as strings  ${res['status']}  success

_Get CU Specifical MO UUID via DN Name
    [Arguments]   ${plan_id}  ${name}   ${alias}=default
    [Documentation]  _Get CU Specifical MO UUID via DN Name
    ...  author: ge.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | plan_id | yes | modify parameters list |
    ...    | name | yes | needed modify parameters modn's name  |
    ...    *RETURN VALUE*   ${parent_mouuid}
    ...    Example
    ...    |  ${parent_mouuid} | _Get CU Specifical MO UUID via DN Name | plan_id=${delta_plan_id} | name=${name}|

    &{delta_plan_tree}   param_cu.get_delta_plan_tree_diff   plan_id=${plan_id}   connection=${alias}
    @{plan_tree}=  Set Variable  ${delta_plan_tree["created"]}
    FOR  ${mo_info}  IN  @{plan_tree}
      run keyword if  '${mo_info["parent_mo_uuid"]}'=='${parent_mouuid}' and '${mo_info["name"]}'=='${name}'
      ...  run keywords  set suite variable  ${parent_mouuid}  ${mo_info["mo_uuid"]}  AND  exit for loop
      run keyword if  '${mo_info["parent_mo_uuid"]}'=='None' and '${mo_info["name"]}'=='${name}'  run keywords
      ...  set suite variable  ${parent_mouuid}  ${mo_info["mo_uuid"]}  AND  exit for loop
    END
    [Return]   ${parent_mouuid}

_Add Backslash For Parameter
   [Arguments]  ${para_list}
   ${rtn}   Create List
   FOR  ${i}   IN  @{para_list}
        ${tmp_dict}  _Add Backslash For Parameters For One MO   mo_dict=${i}
       Append To List   ${rtn}   ${tmp_dict}
   END
   [Return]  ${rtn}

_Add Backslash For Parameters For One MO
    [Arguments]  ${mo_dict}
    ${mo_dn}             Set Variable   ${mo_dict["mo_dn"]}
    ${one_mo_para_list}  Set Variable   ${mo_dict["one_mo_para_list"]}
    ${one_mo_para_list_new}  Create List
    FOR  ${one_para_dict}  IN  @{one_mo_para_list}
        ${parameter_path}  Set Variable   ${one_para_dict["parameter_path"]}
        ${value}  Set Variable   ${one_para_dict["value"]}
        ${operation_type}  Set Variable   ${one_para_dict["operation_type"]}

        ${start_with_backslash}   Set Variable   ${parameter_path.startswith("/")}
        ${parameter_path_new}  Run Keyword If  "${start_with_backslash}"=="${True}"   Set Variable   ${parameter_path}
           ...   ELSE   Set Variable  /${parameter_path}
        ${tmp_dict}  Create Dictionary   parameter_path=${parameter_path_new}   value=${value}  operation_type=${operation_type}
        Append To List   ${one_mo_para_list_new}  ${tmp_dict}
    END
    ${rtn_for_one_mo_para_dict}   Create Dictionary  mo_dn=${mo_dn}  one_mo_para_list=${one_mo_para_list_new}
    [Return]  ${rtn_for_one_mo_para_dict}

#########################################VDU by internal##################################
VDU Online Change Parameters
    [Arguments]    ${para_list}   ${value_list}   ${mo_list}   ${wait_vdu_up}=${False}  ${vdu_index}=0   ${gnb_index}=0
    ...    ${should_activate}=${True}    ${operation}=replace
    [Documentation]   VDU Online Change Parameters, it will not change parameters if its original value is same as new one, it supports multiple MO
    log to console    VDU Online Change Parameters...
    should not be empty   ${para_list}   msg="para_list" can't be empty
    should not be empty   ${value_list}   msg="value_list" can't be empty
    should not be empty   ${mo_list}   msg="mo_list" can't be empty
    ${origin_para_value_dict}    Get VDU Parameters Value Online For Multi MO    vdu_index=${vdu_index}   gnb_index=${gnb_index}
      ...   para_list=${para_list}   mo_list=${mo_list}
    ${updated_para_value_dict}    _Convert Parameters From List To Dict For Multiple MO
      ...   para_list=${para_list}  value_list=${value_list}  mo_list=${mo_list}   origin_para_value_dict=${origin_para_value_dict}

    ${compare_result}  run keyword and return status   dictionaries should be equal    ${origin_para_value_dict}  ${updated_para_value_dict}
    ${need_update}  Set Variable If  "${compare_result}"=="${True}" and "${operation}"=="replace"   ${False}    ${True}
    _VDU Connection   vdu_index=${vdu_index}    gnb_index=${gnb_index}
    ${updated_paras_list}   ulti.generate_delta_parameters_for_multiple_mo   updated_para_value_dict=${updated_para_value_dict}
      ...   origin_para_value_dict=${origin_para_value_dict}
    ${res}   run keyword if     "${need_update}"=="${True}"    VDU Online Change Parameters By Delta Plan REST
     ...   updated_paras_list=${updated_paras_list}   operation=${operation}   activate=${should_activate}  wait_vdu_up=${wait_vdu_up}

#    ${ret_dict}   Create Dictionary   need_update=${need_update}
#      ...   origin_para_value_dict=${origin_para_value_dict}
#      ...   updated_para_value_dict=${updated_para_value_dict}
    [Return]   ${res}



#########################################VDU by m2m ###########################
VDU Online Change Parameters By M2M
    [Arguments]    ${para_list}   ${value_list}   ${mo_list}   ${vdu_index}=0   ${gnb_index}=0
    ...    ${should_activate}=${True}     ${operation}=replace     ${wait_for_completion}=${True}
    [Documentation]   VDU Online Change Parameters, it will not change parameters if its original value is same as new one, it supports multiple MO
    log to console    VDU Online Change Parameters...
    should not be empty   ${para_list}   msg="para_list" can't be empty
    should not be empty   ${value_list}   msg="value_list" can't be empty
    should not be empty   ${mo_list}   msg="mo_list" can't be empty
    ${origin_para_value_dict}    Get VDU Parameters Value Online For Multi MO    vdu_index=${vdu_index}   gnb_index=${gnb_index}
      ...   para_list=${para_list}   mo_list=${mo_list}
    ${updated_para_value_dict}    _Convert Parameters From List To Dict For Multiple MO
      ...   para_list=${para_list}  value_list=${value_list}  mo_list=${mo_list}   origin_para_value_dict=${origin_para_value_dict}

    ${compare_result}  run keyword and return status   dictionaries should be equal    ${origin_para_value_dict}  ${updated_para_value_dict}
    ${need_update}  Set Variable If  "${compare_result}"=="${True}" and "${operation}"=="replace"   ${False}    ${True}
    _VDU Connection   vdu_index=${vdu_index}    gnb_index=${gnb_index}
    ${updated_paras_list}   ulti.generate_delta_parameters_for_multiple_mo_for_m2m   updated_para_value_dict=${updated_para_value_dict}
      ...   origin_para_value_dict=${origin_para_value_dict}

    ${updated_paras_data}     Convert JSON Data To String    ${updated_paras_list}
    log to console    ${updated_paras_data}
    ${res}   run keyword if     "${need_update}"=="${True}"    VDU Change Parameters By M2M
     ...   should_activate=${should_activate}    updated_paras_list=${updated_paras_data}      wait_for_completion=${wait_for_completion}
    [Teardown]    param_vdu.disconnect
    [Return]   ${res}

Convert JSON Data To String
    [Arguments]    ${json_data}
    ${json_str}=    Evaluate    json.dumps(${json_data})    json
    [Return]    ${json_str}


Extract Operation Info
    [Arguments]    ${detail_info}
    ${operation_info}    Get Regexp Matches    ${detail_info}    Operation info: (.*)\'
    ${operation_info}    Set Variable    ${operation_info[0]}
    ${cleaned_info}    Replace String    ${operation_info}    \\    ${EMPTY}
    ${cleaned_info}    remove string    ${cleaned_info}    '
    ${operation_info}    split string    ${cleaned_info}    Operation info:
    ${operation_info}    strip string    ${operation_info[${1}]}
    [Return]    ${operation_info}

Extract Operation ID
    [Arguments]    ${detail_info}
    ${operation_info}    Get Regexp Matches    ${detail_info}    Operation (.*?) failed
    ${operation_info}    Set Variable    ${operation_info[0]}
    ${operation_info}    split string    ${operation_info}     ${SPACE}
    ${type_o}    evaluate    type(${operation_info})
    [Return]    ${operation_info[${1}]}


VDU Change Parameters By M2M
    [Arguments]   ${should_activate}    ${updated_paras_list}        ${wait_for_completion}=${True}
    ${status}    ${out}   run keyword and ignore error   param_vdu.perform_delta_recommissioning
    ...           delta_file=${updated_paras_list}    should_activate=${should_activate}
    ...           wait_for_completion=${wait_for_completion}
    ${operation_info_dict}    run keyword if    "${status}"!="PASS"    Extract Operation Info     ${out}
    ${operation_id}   run keyword if  "${status}"!="PASS"  Extract Operation ID    ${out}
    ${error_info}    set variable if    "${status}"=="PASS"   ${None}     ${operation_info_dict}
    Run Keyword If    "${status}"!="PASS"    Fail    ${error_info}
    ${status}    set variable if    "${should_activate}"=="${False}" or "${wait_for_completion}"=="${False}"   ${out["id"]}    success
#    ${out}    run keyword if    "${wait_for_completion}"=="${False}"  Wait until keyword succeeds    1200    60s
#    ...    Check VDU Delta Plan Commission Success    operation_id=${out["id"]}    should_activate=${should_activate}
#    ${res}    set variable if    "${out}"!="${None}"    ${out}    ${status}
    [Return]   ${status}

_vDU Disconnection
    [Arguments]   ${alias}=default
    param_vdu.disconnect    ${alias}



Check VDU Delta Plan Commission Success
    [Arguments]    ${operation_id}    ${should_activate}
    ${out}    param_vdu.get_status_of_perform_delta_recommissioning
    ...    operation_id=${operation_id}
    ...    should_activate=${should_activate}
#    Should Be True  "${out["status"]}"=="success"
    RETURN    ${out}

_VDU Connection
    [Arguments]   ${vdu_index}=0    ${gnb_index}=0    ${alias}=default
    ${oam_httpaddr}    set variable    ${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.addr}
    ${oam_web_ip}    set variable    ${oam_httpaddr}
    Run keyword and ignore error    _vDU Disconnection
    param_vdu.connect to
    ...  host=${oam_web_ip}
    ...  port=${EMPTY}
    ...  username=${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.username}
    ...  password=${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.password}
    ...  secure=True
    ...  connection_name=${alias}

Get VDU Parameters Value Online For Multi MO
    [Arguments]   ${para_list}    ${mo_list}        ${gnb_index}=${0}   ${vdu_index}=${0}
    [Documentation]   Get VDU Parameters Value Online For Multi MO
    ...   *AUTHOR* ge.cao@nokia-sbell.com
    ...  Change History
    ...
    ...   | Input Parameters    | Man. | Description |
    ...   | para_list    | yes | the names of parameters list |
    ...   | mo_list    | yes | the mo distname list that contains the parameter like MRBTS-3218/NRBTS-1/NRCELL-1 |
    ...
    ...   *RETURN VALUE*
    ...   dictionary like,
    ...  {
    ...   'MRBTS-1234': {'btsName': '5gvDU-108201'}
    ...   'MRBTS-1234/MNL-1/AMGR-1/LUAC-1': {'btsAccountLockoutDuration': '0'}
    ...  }
    ...
    ...   Example
    ...  | ${para_list} | Create List | btsName | btsAccountLockoutDuration |
    ...  | ${mo_list} | Create List | MRBTS-1234 | MRBTS-1234/MNL-1/AMGR-1/LUAC-1 |
    ...  | ${para_value_dict} | Get VDU Parameters Value Online For Multi MO | para_list=${para_list} | mo_list=${mo_list} |
    ...
    ${origin_para_value_dict}   Create Dictionary
    _VDU Connection       gnb_index=${gnb_index}   vdu_index=${vdu_index}


    ${length}=   Get Length    ${para_list}
    FOR    ${i}    IN RANGE    0     ${length}
        ${mo}  Set Variable   ${mo_list[${i}]}
        ${mo_keys}   Evaluate  list(${origin_para_value_dict})
        ${mo_dict}   Run Keyword If   "${mo}" in ${mo_keys}  Set Variable  ${origin_para_value_dict["${mo}"]}
            ...  ELSE   Create Dictionary
        ${para}  Set Variable   ${para_list[${i}]}
        @{tmp_para_list}  Split String  ${para}  /
        ${is_number}  ulti.is_numeric   ${tmp_para_list[-1]}
#        ${is_number_2}  is_numeric   ${tmp_para_list[-2]}
        ${para}  Set Variable If   "${is_number}"=="${True}"   ${tmp_para_list[0]}    ${para}

        ${status}  ${value}   Run Keyword And Ignore Error   Get VDU Parameter Value Online   ${mo}  ${para}
        ${value_current}  Set Variable If  '${status}'=='PASS'   ${value}  ${None}

        ${is_a_list}  _Is List For Param   ${value_current}
        ${r}   ${value_current}  Run Keyword And Ignore Error  Set Variable If  '${is_a_list}'=='${True}' and "${is_number}"=="${True}"
             ...   ${value_current[${tmp_para_list[-1]}]}   ${value_current}
        ${value_current}  Set Variable If  "${r}"=="PASS"  ${value_current}  ${None}

        Set to Dictionary  ${mo_dict}   ${para_list[${i}]}   ${value_current}
        Set to Dictionary  ${origin_para_value_dict}  ${mo}   ${mo_dict}
    END
    [Return]  ${origin_para_value_dict}


Get Unique ID For Param
    [Arguments]  ${prefix}=${EMPTY}   ${suffix}=${EMPTY}   ${precise}=HIGH
    ${precise}  Set Variable  ${precise.upper()}
    ${rtn}  Run Keyword If  "${precise}"=="HIGH"  _Get Unique ID High Precise For Param  prefix=${prefix}   suffix=${suffix}
    ...   ELSE IF  "${precise}"=="LOW"    _Get Unique ID LOW Precise For Param   prefix=${prefix}   suffix=${suffix}
    ...   ELSE IF   "${precise}"=="FORMAT_DATETIME"   _Get Unique ID Format Datetime For Param   prefix=${prefix}   suffix=${suffix}
    ...   ELSE IF   "${precise}"=="HIGH_WITH_FORMAT_DATETIME_EPOCH"
                 ...   _Get Unique ID Format High Precise Plus Datetime Epoch For Param   prefix=${prefix}   suffix=${suffix}
    [Return]    ${rtn}

_Get Unique ID High Precise For Param
    [Arguments]  ${prefix}=${EMPTY}   ${suffix}=${EMPTY}
    ${unique_id}    Evaluate    str(uuid.uuid4())    modules=uuid
    ${unique_id}    String.Replace String    ${unique_id}    -    ${EMPTY}
    [Return]    ${prefix}${unique_id}${suffix}


_Get Unique ID LOW Precise For Param
    [Arguments]  ${prefix}=${EMPTY}   ${suffix}=${EMPTY}
    ${unique_id}    Evaluate    str(time.time())    modules=time
    ${unique_id}    String.Replace String    ${unique_id}    .    ${EMPTY}
    [Return]    ${prefix}${unique_id}${suffix}


_Get Unique ID Format Datetime For Param
    [Arguments]  ${prefix}=${EMPTY}   ${suffix}=${EMPTY}
    ${unique_id_part1}    Evaluate    time.strftime("%Y%m%d_%H%M%S", time.localtime())    modules=time

    ${unique_id_part2}    Evaluate     str(time.time())    modules=time
    ${unique_id_part2}   set variable  ${unique_id_part2.split(".")[-1]}

    ${unique_id}    set variable   ${unique_id_part1}_${unique_id_part2}
    [Return]    ${prefix}${unique_id}${suffix}


_Get Unique ID Format High Precise Plus Datetime Epoch For Param
    [Arguments]  ${prefix}=${EMPTY}   ${suffix}=${EMPTY}
    ${unique_id_part1}    Evaluate    str(uuid.uuid4())    modules=uuid
    ${unique_id_part1}    String.Replace String    ${unique_id_part1}    -    ${EMPTY}

    ${unique_id_part2}    Evaluate    time.strftime("%Y%m%d_%H%M%S", time.localtime())    modules=time

    ${unique_id}    set variable   ${unique_id_part1}_${unique_id_part2}
    [Return]    ${prefix}${unique_id}${suffix}


VDU Online Change Parameters By Delta Plan REST
    [Arguments]     ${mo_dn}=${EMPTY}   ${updated_paras_list}=${EMPTY}   ${operation}=replace   ${activate}=${True}
    ...   ${force_reset}=${True}   ${auto_lock_cells}=${True}    ${wait_vdu_up}=${False}    ${timeout}=60
    [Documentation]   VDU Online Change Parameters By Delta Plan REST
    ...   *AUTHOR* ge.cao@nokia-sbell.com
    ...  Change History
    ...
    ...   | Input Parameters    | Man. | Description |
    ...   | mo_dn                | yes | the mo distname that contains the parameter like MRBTS-3218/NRBTS-1/NRCELL-1 |
    ...   | updated_paras_list   | yes | parameters values, type is dict,  e.g, |
    ...   |                      |     | {'f1Cplane/0/ipV4AddressDN1':'MRBTS-5240/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1', 'para2':'value2'} |
    ...   | operation           | no |  the operation - add, replace, remove, revert. The default is replace |
    ...   | activate           | no | if ${True} to activate plan, if ${False} not to activate it. The default is ${True} |
    ...   | force_reset       | no | default is ${True} |
    ...   | auto_lock_cells   | no | default is ${True} |
    ...   | wait_vdu_up       | no | default is ${False} |
    ...   | timeout           | no | default is 60 (seconds) |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...   | VDU Rest Login |
    ...   | ${mo} |  set variable |  MRBTS-5240/NRBTS-1/NRDU-1 |
    ...   | ${added_dict} | create dictionary | f1Cplane/0/ipV4AddressDN1=MRBTS-5240/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1 |
    ...   | VDU Online Change Parameters By Delta Plan REST | mo_dn=${mo} | updated_paras_list=${added_dict} |
    ...
    ...   | ${added_dict1} | Create Dictionary | btsName=btsName1 | mo_dn=MRBTS-123 | operation=replace |
    ...   | ${added_dict2} | Create Dictionary | ipNodeStatisticsInterval=30min | mo_dn=MRBTS-123/TNLSVC-1/PMTNLINT-1 | operation=replace |
    ...   | ${mo_dict_list} | Create List | ${added_dict1} | ${added_dict2} |
    ...   | VDU Online Change Parameters By Delta Plan REST | updated_paras_list=${mo_dict_list} | activate=${True} |
    ...   | VDU Rest Logout |
    ...
    ...   Without activate it:
    ...   | VDU Online Change Parameters By Delta Plan REST | mo_dn=${mo} | updated_paras_list=${added_dict} | activate=${False} |
    ...
    ${timeout}   convert to integer  ${timeout}

    Check Maximum Delta Plan Number And Delete One If Reach Maximum Number

    ${delta_plan_name}   Get Unique ID For Param  prefix=TA_delta_plan   precise=LOW
    ${plan_id}   ${action_id}   Generate Delta Plan   plan_name=${delta_plan_name}  plan_description=TA

    ${out}  Run Keyword If  "${mo_dn}"!="${EMPTY}"
        ...   Update Delta Plan Parameter  plan_id=${planid}  mo_dn=${mo_dn}  updated_paras_dict=${updated_paras_list}   operation=${operation}
        ...   ELSE   _VDU Online Change Parameters By Delta Plan REST Multiple MO   plan_id=${planid}   updated_paras_list=${updated_paras_list}
        ...       operation=${operation}

    ${validation_id}  Validate Delta Plan By REST  plan_id=${planid}

    Logging vDU Delta Plan Validation Error   plan_id=${planid}  validation_id=${validation_id}
    ${res}   run keyword if    "${activate}"=="${True}"
    ...    activate_du_delta_plan    plan_id=${plan_id}    force_reset=${force_reset}
    ...    auto_lock_cells=${auto_lock_cells}    timeout=${timeout}    wait_vdu_up=${wait_vdu_up}
    ${res}    set variable if    "${res}"!="${None}"     ${res}    ${plan_id}
    [Return]   ${res}


activate_du_delta_plan
    [Arguments]   ${plan_id}=dp_00000000    ${force_reset}=${True}
    ...           ${auto_lock_cells}=${True}    ${timeout}=60   ${wait_vdu_up}=${False}
    [Documentation]   Activate Delta Plan By REST
    ...   Author: ge.cao@nokia-sbell.com
    ...   Contact: ge.cao@nokia-sbell.com
    ...   | Input Parameters | Man. | Description |
    ...   | plan_id          | yes | delta plan id |
    ...   | force_reset      | no | default is ${True} |
    ...   | auto_lock_cells  | no | default is ${True} |
    ...   | wait_vdu_up      | no | if ${True}, will wait for VDU on-air, default is ${False} |
    ...   | timeout          | no | default is 60 (seconds) |
    ...
    ...   | Return Value | Description |
    ...   | None | NA |
    ...
    ...   Example
    ...   | Activate Delta Plan By REST In vDU |  ${plan_id} |
    ...
#    run keyword and ignore error    _VDU Connection       gnb_index=${gnb_index}   vdu_index=${vdu_index}  alias=${alias}
    ${temp_path}    ulti.create_a_directory_for_param    log_path=${OUTPUT_DIR}    directory_name=delta_plan
    ${tmp_file_id}    Get Unique ID For Param    precise=LOW
#    ${delta_scf_fullpath}    param_vdu.save_delta_plan_file    local_path=${temp_path}    local_filename=${tmp_file_id}.xml
#    ...     vdu_connection=${alias}
    ${out}    param_vdu.activate_delta_plan    delta_plan_id=${plan_id}
     ...   force_reset=${force_reset}    auto_lock_cells=${auto_lock_cells}    timeout=${timeout}
    ${rtn}    Wait until keyword succeeds    600    30s
     ...   _Check Activate Delta Plan Status Should Be Expected For VDU    operation_id=${out['id']}    plan_id=${plan_id}
     ...                                                        expected_status=success
    Run keyword if    "${wait_vdu_up}"=="${True}"    wait until keyword succeeds    600    20
    ...                           _vDU Check All Cells Status Should Be Onair For All DUs On Param module
#    [Teardown]    run keyword and ignore error    param_vdu.disconnect    ${alias}
    [Return]   ${rtn}

_Check Activate Delta Plan Status Should Be Expected For VDU
    [Arguments]    ${operation_id}    ${plan_id}    ${expected_status}
    ${out}    param_vdu.Get_Activate_Delta_Plan_Operation_Status    operation_id=${operation_id}    delta_plan_id=${plan_id}
    Should Be True  "${out["status"]}"=="${expected_status}"
    [Return]  ${out["status"]}


_Get vDU Number For Param
    [Arguments]   ${gnb_index}=0
    [Documentation]  Get vDU Number
    ...    Author: ge.cao@nokia-sbell.com
    ...    Contact: ge.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...
    ...    | Return Value | Description |
    ...    | ${vDU_number}  | return vdu number |
    ...
    ...    Example
    ...    | ${vDU_number} | Get vDU Number |
    ...
    ${vDU_number}    get length    ${tl.gnbs[${gnb_index}].dus}
    [Return]    ${vDU_number}

_vDU Check All Cells Status Should Be Onair For All DUs On Param module
    [Arguments]    ${gnb_index}=${0}
    [Documentation]    vDU Check All Cells Status Should Be Onair For All DUs
    ...    Author: ge.cao@nokia-sbell.com
    ...    Contact: ge.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | gnb_index | Yes. | gnb_index, default is 0 |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | vDU Check All Cells Status Should Be Onair For All DUs |
    ...
    ${du_number}    _Get vDU Number For Param    gnb_index=${gnb_index}
    FOR    ${i}    IN RANGE    ${du_number}
        _vDU Check All Cells Status Should Be Onair For Param    vdu_index=${i}    gnb_index=${gnb_index}
    END

_vDU Check All Cells Status Should Be Onair For Param
    [Arguments]    ${vdu_index}=0    ${gnb_index}=0
    [Documentation]    vDU Verify Cells Status Should Be Onair With Expected Cell Number
    ...    Author: ge.cao@nokia-sbell.com
    ...    Contact: ge.cao@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | vdu_index | No. | specify which vdu needs to be check if the testline configed multi vdus |
    ...    | gnb_index | No. | specify which vdu needs to be check if the testline configed multi vdus |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | vDU Verify Cells Status Should Be Onair With Expected Cell Number |
    ...
    ${cell_number}    _Get VDU Cell Number From SCF For Param    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    ${alias}=    Get Unique ID For Param
    _VDU Connection    vdu_index=${vdu_index}    gnb_index=${gnb_index}    alias=${alias}
    ${vdu_cells_summary}=    param_vdu.get_vdu_cells_summary    vdu_connection=${alias}
    Should Be Equal As Numbers    ${vdu_cells_summary['basic_cells_summary']['operational_state']['disabled']}    0
    Should Be Equal As Numbers    ${vdu_cells_summary['basic_cells_summary']['administrative_state']['locked']}    0
    Should Be Equal As Numbers    ${vdu_cells_summary['basic_cells_summary']['administrative_state']['shutting_down']}  0
    ${on_line}    set variable    ${vdu_cells_summary['availability_status']['on_line']}
    should be true    ${on_line}==${cell_number}
    [Teardown]  param_vdu.disconnect    ${alias}

_Get VDU Cell Number From SCF For Param
    [Arguments]  ${vdu_index}=0   ${gnb_index}=0
    [Documentation]   Get VCU Cell Number From SCF
    ...    Author: ge.cao@nokia-sbell.com
    ...    Contact: ge.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | gnb_index | no | gnb index to indicate which gnb will be used, default is 0  |
    ...
    ...    | Return Value | Description |
    ...    | ${cell_number} | return cell number |
    ...
    ...    Example
    ...    | ${cell_number} | Get VCU Cell Number From TestLine |
    ...
    _VDU Connection    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    ${tmpid1}    Get Unique ID For Param    precise=LOW    prefix=Get_VDU_Cell_Number_From_SCF
    ${tmp_scf_path}    ulti.create_a_directory_for_param    log_path=${OUTPUT_DIR}    directory_name=${tmpid1}
    ${tmp_scf_file}    param_vdu.get_current_plan_file    local_dir_path=${tmp_scf_path}   filename=scf.xml
    ...                include_runtime_data=${False}
    ${scf_content}    OperatingSystem.Get File    ${tmp_scf_file}
    ${result}    Get Regexp Matches    ${scf_content}    .*NRCELL"\\s+distName="MRBTS-(\\d+)/NRBTS-(\\d+)/NRCELL-(\\d+)"\\s+.*   3
    ${cell_number}    Set Variable    ${result.__len__()}
    [Return]   ${cell_number}
    [Teardown]   run keyword and ignore error  _vDU Disconnection


Logging vDU Delta Plan Validation Error
  [Arguments]  ${plan_id}  ${validation_id}
  ${validation_result}   param_vdu.get_delta_plan_validation_results   plan_id=${plan_id}  validation_id=${validation_id}
  log dictionary   ${validation_result}


Check Maximum Delta Plan Number And Delete One If Reach Maximum Number
    [Arguments]   ${alias}=${None}
    [Documentation]   Check Maximum Delta Plan Number And delete one if reach Maximum number
    ...   *AUTHOR* ge.cao@nokia-sbell.com
    ...  Change History
    ...
    ...   | Input Parameters    | Man. | Description |
    ...   None
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...  | ${alias}  VDU Rest Login |
    ...  | Check Maximum Delta Plan Number And delete one if reach Maximum number | alias=${alias} |
    ...
    ${all_plans}   param_vdu.Get_Delta_Plan_Info_List  vdu_connection=${alias}
    Run Keyword If  ${all_plans.__len__()}==1   Delete Delta Plan By Plan Id   plan_id=${all_plans[0]["plan_id"]}  alias=${alias}




Generate Delta Plan
    [Arguments]    ${plan_name}  ${plan_description}=${EMPTY}  ${delete_old_one}=${True}   ${alias}=${None}
    [Documentation]   Generate Delta Plan
    ...   *AUTHOR* ge.cao@nokia-sbell.com
    ...  Change History
    ...
    ...   | Input Parameters    | Man. | Description |
    ...   | plan_name    | yes | plan_name |
    ...   | plan_description | no | plan_description, default is ${EMPTY} |
    ...   | delete_old_one   | no | delete_old_one , if ${true}, old delta plan will be deleted, default is ${True} |
    ...
    ...   *RETURN VALUE*
    ...    Return (<plan_id>, <action_id>)
    ...
    ...   Example
    ...  | ${alias} | VDU Rest Login |
    ...  | ${plan_id} | ${action_id} | Generate Delta Plan | plan_name=my_plan_name |  alias=${alias} |
    ...
    run keyword if  "${delete_old_one}"=="${True}"   Check Maximum Delta Plan Number And Delete One If Reach Maximum Number  alias=${alias}

    ${out}  param_vdu.Generate_Delta_Plan  plan_name=${plan_name}   plan_description=${plan_description}  vdu_connection=${alias}

    ${temp_plan_id}   Set Variable  ${out["plan_id"]}
    ${temp_action_id}   Set Variable  ${out["action_id"]}

    Generate Delta Plan Status Should Be Successful  action_id=${temp_action_id}   alias=${alias}
    [Return]   ${temp_plan_id}   ${temp_action_id}

Generate Delta Plan Status Should Be Successful
    [Arguments]  ${action_id}   ${alias}=${None}
    [Documentation]   Generate Delta Plan Status Should Be Successful
    ...   *AUTHOR* ge.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | action_id    | yes | action_id |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | Generate Delta Plan Status Should Be Successful | action_id=<my_action_id> |
    ...
    Wait Until Keyword Succeeds  30   3  _Generate Delta Plan Status Should Be Expected   action_id=${action_id}
    ...    expected_status=success    alias=${alias}

_Generate Delta Plan Status Should Be Expected
    [Arguments]  ${action_id}   ${expected_status}   ${alias}=${None}
    [Documentation]   _Generate Delta Status Should Be Expected
    ...   *AUTHOR* ge.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | action_id       | yes | operation_id |
    ...   | expected_status | yes | expected_status |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | _Upload Status Should Be Expected | action_id=<my_operation_id> | expected_status=success |
    ...
    ${out}   param_vdu.Get_Delta_Plan_Generated_Action_Status   action_id=${action_id}   vdu_connection=${alias}
    Should Be True  "${out["status"]}"=="${expected_status}"

Update Delta Plan Parameter
    [Arguments]  ${plan_id}   ${mo_dn}   ${updated_paras_dict}  ${operation}=replace  ${mo_uuid}=${None}  ${timeout}=30   ${alias}=${None}
    [Documentation]   Update Staged Plan Parameter, it support multiple parameters change for one MO
    ...   *AUTHOR* ge.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | plan_id    | yes | plan_id |
    ...   | mo_dn      | yes | mo_dn   |
    ...   | updated_paras_dict | yes | updated_paras_dict   |
    ...   | operation          | no | operation: add, replace, remove, revert   |
    ...   | mo_uuid            | no | mo_uuid, default is ${None}  |
    ...   | timeout           | no | timeout, default is 30, unit is second   |
    ...
    ...   *RETURN VALUE*
    ...    status dictionary of operation, its content as below,
    ...    {'status': 'success', 'error_message': None, 'revision': '1594282403383843372',
    ...     'links': None, 'action_id': 'a_0b884e65-83a3-445c-a1ff-1fadc26cd767'  }
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | ${added_dict} |  create dictionary  | f1SctpProfileIdOfDu=5 | sctpProfile/0/sctpHeartbeatInterval=21 |
    ...  | ${validation_id} | Update Delta Plan Parameter | plan_id=<my_plan_id> | mo_dn=MRBTS-5240/MNL-1/MNLENT-1/MPLANENW-2 |
    ...  | ... | updated_paras_dict=${added_dict} | operation=add |
    ...
    ...  | ${validation_id} | Update Delta Plan Parameter | plan_id=<my_plan_id> | mo_dn=MRBTS-5240/MNL-1/MNLENT-1/MPLANENW-2 |
    ...  | ... | updated_paras_dict=${added_dict} | operation=replace |
    ...
    ${timeout}   convert to integer  ${timeout}
    ${out}  param_vdu.update_vdu_parameter_of_delta_plan   plan_id=${plan_id}  mo_dn=${mo_dn}
     ...   updated_paras_dict=${updated_paras_dict}   operation=${operation}   mo_uuid=${mo_uuid}  timeout=${timeout}
     ...   vdu_connection=${alias}

    ${action_id}  set variable  ${out["action_id"]}
    ${out}    Update Delta Plan Parameter Should Be Successful   plan_id=${plan_id}   action_id=${action_id}  alias=${alias}
    [Return]  ${out}


Update Delta Plan Parameter Should Be Successful
    [Arguments]  ${plan_id}   ${action_id}  ${alias}=${None}
    [Documentation]   Update Delta Plan Parameter Should Be Successful
    ...   *AUTHOR* ge.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | operation_id    | yes | operation_id |
    ...   | plan_id         | yes | plan_id |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | Update Delta Plan Parameter Should Be Successful | plan_id=<my_plan_id> | operation_id=<my_operation_id> |
    ...
    ${rtn}  wait until keyword succeeds  20   2
    ...   _Update Delta Plan Parameter Should Be Expected   plan_id=${plan_id}   action_id=${action_id}   expected_status=success
    ...   alias=${alias}
    [Return]  ${rtn}

_Update Delta Plan Parameter Should Be Expected
    [Arguments]   ${plan_id}   ${action_id}   ${expected_status}    ${alias}=${None}
    [Documentation]    _Update Delta Plan Parameter Should Be Expected
    ...   *AUTHOR* ge.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | expected_status | yes | expected_status |
    ...   | plan_id         | yes | plan_id |
    ...   | action_id    | yes | action_id |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | Validate Plan Status Should Be Expected | plan_id=<my_plan_id> | action_id=<my_action_id> | expected_status=success |
    ...

    ${out}   param_vdu.get_update_paras_action_status_of_delta_plan   plan_id=${plan_id}  action_id=${action_id}
    ...      vdu_connection=${alias}
    Should Be True  "${out["status"]}"=="${expected_status}"
    [Return]  ${out}


_VDU Online Change Parameters By Delta Plan REST Multiple MO
    [Arguments]  ${plan_id}   ${updated_paras_list}       ${operation}
    ${mo_number}  Get Length   ${updated_paras_list}
    FOR   ${one_mo_dict}   IN   @{updated_paras_list}
       ${updated_paras_dict}  Copy Dictionary  ${one_mo_dict}
       ${r}  ${operation}   Run Keyword And Ignore Error   Get From Dictionary  ${updated_paras_dict}   operation
       ${operation}  Set Variable If   "${r}"=="PASS"   ${operation}   replace
       Run Keyword If   "${r}"=="PASS"   Remove From Dictionary   ${updated_paras_dict}   operation
       ${mo_dn}  Get From Dictionary  ${updated_paras_dict}   mo_dn
       Remove From Dictionary   ${updated_paras_dict}   mo_dn
       Update Delta Plan Parameter  plan_id=${planid}  mo_dn=${mo_dn}  updated_paras_dict=${updated_paras_dict}
       ...    operation=${operation}
    END

Validate Delta Plan By REST
    [Arguments]  ${plan_id}    ${alias}=${None}
    [Documentation]   Validate Delta Plan By REST
    ...   *AUTHOR* ge.cao@nokia-sbell.com
    ...  Change History
    ...
    ...   | Input Parameters    | Man. | Description |
    ...   | plan_id    | yes | plan_id |
    ...   | alias    | No | alias, default is ${None} |
    ...
    ...   *RETURN VALUE*
    ...    Return validation_id
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | Check Maximum Delta Plan Number And Delete One If Reach Maximum Number |
    ...  | ${delta_plan_name} | get unique id | prefix=TA_delta_plan | precise=LOW |
    ...  | ${plan_id} | ${action_id} | Generate Delta Plan | plan_name=${delta_plan_name} | plan_description=TA |
    ...  | ${TCE_Info_1} | create dictionary | tceIpAddress=1.1.1.1 | tcePortNumber=5000 |
    ...  | ${mo} | set variable | MRBTS-5200/MNL-1/TCEADM-1/TCE-1 |
    ...  | Update Delta Plan Parameter | plan_id=${plan_id} | mo_dn=${mo} | updated_paras_dict=${TCE_Info_1} | operation=add |
    ...  |  ${validation_id} | Validate Delta Plan By REST | plan_id=${planid} |
    ...  | Activate Delta Plan By REST | ${plan_id} | wait_vdu_up=${True} |
    ...

    ${out}  param_vdu.Validate_Delta_Plan   delta_plan_id=${plan_id}    vdu_connection=${alias}
    ${action_id}   Set Variable  ${out["action_id"]}
    ${out}    Validate Delta Plan Status Should Be Successful   action_id=${action_id}  plan_id=${plan_id}   alias=${alias}
    ${validation_id}  Set Variable   ${out["validation_id"]}
    [Return]   ${validation_id}

Validate Delta Plan Status Should Be Successful
    [Arguments]  ${action_id}   ${plan_id}   ${alias}=${None}
    [Documentation]   Validate Delta Plan Status Should Be Successful
    ...   *AUTHOR* ge.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | operation_id    | yes | operation_id |
    ...   | plan_id         | yes | plan_id |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | Upload Plan Status Should Be Successful | action_id=<my_action_id> | plan_id=<my_plan_id> |
    ...
    ${rtn}  Wait Until Keyword Succeeds  20   2
     ...   _Validate Delta Plan Status Should Be Expected   action_id=${action_id}    plan_id=${plan_id}   expected_status=success
     ...   alias=${alias}
    [Return]  ${rtn}

_Validate Delta Plan Status Should Be Expected
    [Arguments]  ${action_id}   ${expected_status}   ${plan_id}  ${alias}=${None}
    ${out}   param_vdu.Get_Validate_Delta_Plan_Operation_Status   action_id=${action_id}   delta_plan_id=${plan_id}
    ...      vdu_connection=${alias}
    Should Be True  "${out["status"]}"=="${expected_status}"
    [Return]  ${out}

Delete Delta Plan By Plan Id
    [Arguments]  ${plan_id}  ${alias}=${None}
    [Documentation]   Delete Delta Plan By Plan Id
    ...   *AUTHOR* ge.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | plan_id             | yes | delta plan id |
    ...   | force_reset       | no | default is ${True} |
    ...   | auto_lock_cells   | no | default is ${True} |
    ...   | timeout           | no | default is 60 (seconds) |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...   | VDU Rest Login |
    ...   | Delete Delta Plan By Plan Id | plan_id=my_plan_id |
    ...   | VDU Rest Logout |
    ...
    ${out}    param_vdu.delete_delta_plan_file   plan_id=${plan_id}  vdu_connection=${alias}
    wait until keyword succeeds  60   5   _Make Sure Delta Plan Is Deleted Once  alias=${alias}


_Make Sure Delta Plan Is Deleted Once
    [Arguments]  ${alias}=${None}
    ${all_plans}   param_vdu.Get_Delta_Plan_Info_List  vdu_connection=${alias}
    Should Be True  ${all_plans.__len__()}==0

Get VDU Parameter Value Online
    [Arguments]  ${mo_dn}   ${para_name}    ${timeout}=60   ${vdu_connection}=${None}
    [Documentation]   Get VDU Parameter Value Online
    ...    *AUTHOR* ge.cao@nokia-sbell.com
    ...    If the searched parameter is under list/item, please set the para_name with something like 'list_name/item_number/parameter_name'
    ...  Change History
    ...
    ...    *Argument Description*
    ...    | Input Parameters    | Man. | Description |
    ...    | mo_dn     | yes | the distname of given parameter |
    ...    | para_name | yes | parameter name   |
    ...    | timeout   | no | timeout, default is 60, unit is second   |
    ...
    ...    *RETURN VALUE*
    ...    the parameter value getting from current plan
    ...
    ...   *Example*
    ...   | vdu rest login |
    ...   | ${para_value} | Get VDU Parameter Value Online | mo_dn=MRBTS-5233/TNLSVC-1/TNL-1/IPNO-1/PINGREQ-1/PINGRES-1 | para_name=packetsLost |
    ...   | ${para_value} | Get VDU Parameter Value Online | mo_dn=MRBTS-5233/TNLSVC-1/TNL-1/IPNO-1/IPRT-1 | para_name=staticRoutes/0/gateway |
    ...
    ...   | ${alias} | vdu rest login | gnb_index=0 | vdu_index=1 |
    ...   | ${para_value} | Get VDU Parameter Value Online | mo_dn=MRBTS-5233 | para_name=btsName | vdu_connection=${alias} |
    ...
    ...   | ${alias} | vdu rest login | gnb_index=1 | vdu_index=1 |
    ...   | ${para_value} | Get VDU Parameter Value Online | mo_dn=MRBTS-5233 | para_name=btsName | vdu_connection=${alias} |
    ...
    ...  | ${mo}          | Set Variable | MRBTS-1234/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1/TOPP-1 |
    ...  | ${list_name}   | Set Variable | acceptedClockClass |
    ...  | VDU Rest Login |
    ...  | ${value}       | Get VDU Parameter Value Online | mo_dn=${mo} | para_name=acceptedClockClass |
    ...
    ${timeout}   convert to integer  ${timeout}
    ${out}  param_vdu.search_parameter_of_current_plan   mo_dn=${mo_dn}   para_name=${para_name}   timeout=${timeout}
    ...     vdu_connection=${vdu_connection}
    [Return]  ${out}
