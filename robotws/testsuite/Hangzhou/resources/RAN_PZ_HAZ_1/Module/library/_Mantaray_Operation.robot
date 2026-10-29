*** Settings ***
Documentation
...    Author: Dante?He
...    Email address: Dante.1.he@nokia-sbell.com
...    Maintainer: Dante?He
...    Email address:  Dante.1.he@nokia-sbell.com
...    Common KWs use Mantaray to operate the bts
...    All the bugs/new keyword needs/improvement should be raised in Jira and assign to the Maintainer.
...    Jira link: https://jiradc.ext.net.nokia.com/projects/PZ1HAZTA/issues
...    Guidelines for user: https://confluence.ext.net.nokia.com/display/SRANPRODHZHTA/11.+Module+of+Mantaray+Operation
...    Examples: https://wrgitlab.int.net.nokia.com/RAN/robotws/-/tree/master/testsuite/Hangzhou/resources/RAN_PZ_HAZ_1/Module/Module_Test

Library             String
Library             BuiltIn
Library             Collections
Library             DateTime
Library             json
Library             OperatingSystem
Library             Process
Library             taf.sbts.oam.coam.admin  WITH NAME  mantaray_module_admin
Library             taf.nms.netact      WITH NAME  mantaray_module_netact
Library               taf.transport.ssh  WITH NAME  mantaray_module_ssh
Library             Mantaray/mantaray.py
*** Variables ***
${scm_server}  https://artifactory-hz1.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-remote
@{HZ_NA_list}     10.110.144.154  10.107.183.26  10.68.84.15  10.110.188.146  10.108.248.82   10.56.3.18

*** Keywords ***
Common Mantaray Operation
    [Arguments]
    ...    ${operation}
    ...    ${product_type}
    ...    ${mantaray_name}
    #...    ${alias}=${None}
    ...    ${command}=${None}
    ...    ${timeout}=${None}
    ...    &{kwargs}
    ${origin_conn}=     Set Test Variable    ${connection}      mantaray_oper
    #???
    Mantaray Precondition   ${mantaray_name}    ${connection}
    #????
    ${is_supported_operation}    Set Variable    ${None}
    #?????
     ${is_supported_operation}    is_supported_operation    common       ${operation}
     #??????
     Run Keyword If
     ...     '${is_supported_operation}'=='${None}' or '${is_supported_operation}'=='${False}'
     ...    Fail    msg=Your operation no support yet. Please contact the model owner
     Run keyword if    '${product_type}'=='enb' or '${product_type}'=='gnb'     Set Test Variable  ${cloud_or_classical}
     ...    classical
     ...    ELSE     Set Test Variable   ${cloud_or_classical}    cloud
     ${real_operation}=      find_operation    common     ${cloud_or_classical}     ${operation}
     ${command_exist}=      Run Keyword And Return Status     Should Be String     ${command}
     Run Keyword If     ${command_exist}     Run Keyword    ${real_operation}
     ...    command= ${command}
     ...    connection=${connection}
     ...    mantaray_name=${mantaray_name}
     ...    timeout=${timeout}
     ...    ELSE    Run Keyword    ${real_operation}
     ...    connection=${connection}
     ...    btsid=${btsid}
     ...    btsip=${btsip}
     ...    current_release=${current_release}
     ...    mantaray_name=${mantaray_name}
     ...    timeout=${timeout}
    Mantaray Postcondition    ${mantaray_name}      ${connection}

get current bts release
    mantaray_module_admin.connect_to     bts_host=192.168.255.129    name=get_software
    ${sw_released_admin}=      mantaray_module_admin.get_sw_release_name      connection=get_software
    ${current_sw}=          mantaray_module_admin.get_sw_version      connection=get_software

    mantaray_module_admin.teardown      connection=get_software
    ${R3_status}=      Run Keyword and Return Status      Should Contain     ${current_sw}      FSM3
    ${sw_released_admin}=      Run Keyword If    ${R3_status}==${True}
    ...     Set Variable      ${sw_released_admin}FSM3
    ...     ELSE      Set Variable      ${sw_released_admin}
    Set suite Variable      ${is_R3}     ${R3_status}
    [Return]    ${sw_released_admin}


Parse Variable from user product
    [Arguments]   ${mantaray_name}     ${product_type}     ${bts_index}=${0}      ${cudu_index}=${0}
    Log    ${mantaray_name}
    ${largest_branch_release}=     get_last_release     ${product_type}
    ${trunk_release}=     find trunk release      ${largest_branch_release}
    Set Test Variable      ${trunk_release}     ${trunk_release}

    ${release}=      Run Keyword If      '${product_type}'=='gnb' or '${product_type}'=='enb'     get current bts release
    ...    ELSE        Set Variable     ${trunk_release}

    Run keyword if  '${product_type}'=='vcu'
    ...  Run Keywords    Set test Variable   ${btsip}    ${tl.gnbs[${bts_index}].cu.oam_http_connection_details.addr}
    ...  AND  Set test Variable   ${btsid}   ${tl.gnbs[${bts_index}].global_bts_id}
    ...  AND   Set test Variable   ${current_release}   ${release}VCU
    ...   AND    Set test Variable   ${ENB_ID}       PLMN-PLMN/MRBTS-${btsid}-VCU
    ...  ELSE IF    '${product_type}'=='vdu'
    ...  Run Keywords     Set test Variable   ${btsip}    ${tl.gnbs[${bts_index}].dus[${cudu_index}].oam_http_connection_details.addr}
    ...  AND  Set test Variable   ${btsid}      ${tl.gnbs[${bts_index}].global_bts_id}
    ...  AND   Set test Variable   ${current_release}   ${release}VDU
    ...   AND    Set test Variable   ${ENB_ID}     PLMN-PLMN/MRBTS-${btsid}-VDU
    ...  ELSE IF    '${product_type}'=='fhgw'
    ...  Run Keywords     Set test Variable   ${btsip}    ${tl.gnbs[${bts_index}].cu.oam_http_connection_details.addr}
    ...  AND  Set test Variable   ${btsid} ${tl.gnbs[${bts_index}].dus[${cudu_index}].cloud_deployment.cloud_hosting.namespace}
    ...  AND   Set test Variable   ${current_release}   FHGW${release}
     ...   AND    Set test Variable   ${ENB_ID}   PLMN-PLMN/FHGW-${btsid}
    ...  ELSE IF     '${product_type}'=='gnb'
    ...  Run Keywords     Set test Variable   ${btsip}    ${tl.gnbs[${bts_index}].cu.backhaul_site_oam_ip.v4}
    ...  AND  Set test Variable   ${btsid}   ${tl.gnbs[${bts_index}].global_bts_id}
    ...  AND   Set test Variable   ${current_release}   ${release}
    ...   AND    Set test Variable   ${ENB_ID}   PLMN-PLMN/MRBTS-${btsid}
    ...  ELSE IF     '${product_type}'=='enb'  Run Keywords
    ...  Set test Variable   ${btsip}    ${tl.enbs[${bts_index}].oam_ip.v4}
    ...  AND  Set test Variable   ${btsid}   ${tl.enbs[${bts_index}].instance_id}
    ...  AND   Set test Variable   ${current_release}    ${release}
    ...  AND    Set test Variable   ${ENB_ID}   PLMN-PLMN/MRBTS-${btsid}

    Log To Console      ${ENB_ID}
    Log To Console      ${current_release}
    Log To Console     ${btsid}
    Log To Console    ${btsip}
    Import Variables      /home/ute/MN/UTE/robotws/testsuite/Hangzhou/resources/RAN_PZ_HAZ_1/Module/config/Mantaray_lab_info.py
    #${select_lab}=   Set Test Variable      ${mantaray_lab_info}[${mantaray_name}]


is_supported_operation
    [Arguments]    ${handle_type}    ${operation}
    ${handle}    Run Keyword    get_${handle_type}_mantaray_operation
    ${is_valid_operation}    Run Keyword And Return Status
    ...    Dictionary Should Contain Key    ${handle}    ${operation}
    [Return]    ${is_valid_operation}

find_operation
    [Arguments]    ${handle_type}   ${product_type}    ${operation}
    Run Keyword if  '${handle_type}'=='common' and '${product_type}'=='classical'
    ...      Set Test Variable    ${product_type_handle}    ${EMPTY}
    ...      ELSE IF    '${product_type}'=='no need'      Set Test Variable    ${product_type_handle}    ${EMPTY}
    ...      ELSE IF    '${handle_type}'=='get' and '${product_type}'=='classical'    Set Test Variable    ${product_type_handle}
    ...    ${EMPTY}
    ...      ELSE     Set Test Variable    ${product_type_handle}    cloud
    ${handle}=     Run Keyword     get_${handle_type}_mantaray_operation_${product_type_handle}
    [Return]    ${handle}[${operation}]

get_common_mantaray_operation_cloud
    &{handle}    Create Dictionary
    ...    integration=_common_cloud_Intergration
    ...    deintegration=_common_cloud_Deintergration
    ...    vcu_deploy=common_vcu_deploy
    ...    login_to_mantaray_commander=_connect to mantaray CMD
    ...    cmd_execute_command=_execute_command_to_mantaray_via_ssh
    ...    login_out_mantaray_commander=_log_out_from_mantaray_via_ssh
    [Return]    ${handle}

get_common_mantaray_operation
    &{handle}    Create Dictionary
    ...    integration=_common_classical_Integration
    ...    deintegration=_common_classical_Deintergration
    ...    login_to_mantaray_commander=_connect to mantaray CMD
    ...    cmd_execute_command=_execute_command_to_mantaray_via_ssh
    ...    login_out_mantaray_commander=_log_out_from_mantaray_via_ssh
    [Return]    ${handle}


_execute_command_to_mantaray_via_ssh
    [Arguments]       ${command}      ${connection}         ${mantaray_name}       ${timeout}
    Log     ${mantaray_name}
    ${result}=   mantaray_module_ssh.Execute      ${command}      connection=CMD_MANTARAY_${connection}
    ...  timeout=${timeout}
    Log To Console        ${result}
    [Return]    ${result}


_connect to mantaray CMD
    [Arguments]       ${connection}     ${btsid}      ${btsip}           ${current_release}     ${mantaray_name}    ${timeout}
    log    ${btsid},${btsip},${current_release}
    ${netact_connection}=    mantaray_module_ssh.connect_to    ${${mantaray_name}_info.IP}     ${${mantaray_name}_info.USERNAME}
    ...    ${${mantaray_name}_info.PASSWORD}
    ...    timeout=${timeout}   alias=CMD_MANTARAY_${connection}
    Set Suite Variable    ${CMD_connection}        CMD_MANTARAY_${connection}
    [Return]    ${CMD_connection}

_log_out_from_mantaray_via_ssh
    [Arguments]       ${connection}     ${btsid}      ${btsip}           ${current_release}     ${mantaray_name}     ${timeout}
    log    ${btsid},${btsip},${current_release},${timeout},
    log     ${mantaray_name}
    ${result}=    mantaray_module_ssh.Disconnect     connection=CMD_MANTARAY_${connection}
    Log To Console      Successfullt Logged out
    [Return]    ${result}

Mantaray Precondition
    [Arguments]    ${mantaray_name}     ${alias}=default
    Run keyword and ignore error    Mantaray Postcondition     ${mantaray_name}      ${alias}=${alias}
    mantaray_module_netact.Add Node    cmwas    ${${mantaray_name}_info.IP}    ${${mantaray_name}_info.USERNAME}
    ...  ${${mantaray_name}_info.PASSWORD}    ${alias}
    ${web_url}=    mantaray_module_netact.Detect WEB URL     alias=${alias}
    mantaray_module_netact.Add WEB URL    ${${mantaray_name}_info.URL}     ${${mantaray_name}_info.USERNAME}
    ...  ${${mantaray_name}_info.PASSWORD}     alias=${alias}
    Log To Console     Mantaray connection setup successful!!

Mantaray Postcondition
    [Arguments]    ${mantaray_name}       ${alias}=default
    log    ${mantaray_name}
    mantaray_module_netact.Delete Node    cmwas      ${alias}
    mantaray_module_netact.Clean All    ${alias}
    Log To Console     Mantaray connection break successful!!

SSH to mantaray CMD
    [Arguments]      ${connectionid}=0
    ${netact_connection}=    mantaray_module_ssh.connect_to    ${${mantaray_name}_info.IP}     ${${mantaray_name}_info.USERNAME}
    ...    ${${mantaray_name}_info.PASSWORD}
    ...    timeout=7200s    alias=CMD_MANTARAY${connectionid}
    Set Suite Variable    ${CMD_connection}        CMD_MANTARAY${connectionid}
    [Return]    ${CMD_connection}

_common_classical_Integration
   [Arguments]   ${connection}      ${btsid}      ${btsip}       ${current_release}     ${mantaray_name}    ${timeout}
   log   ${btsid},${timeout}
   ${mrbts_address}=      Set Variable       ${btsip}
   ${ENB_ID}=       Set Variable         ${ENB_ID}
   ${MRBTS_MO_MR} =     Set Variable       ${${mantaray_name}_info.MR}
   ${MRBTS_MO_RELEASE}=      Set Variable         ${current_release}
   ${SECURITY_MODE} =      Set Variable        no TLS
   ${integration_output}=    mantaray_module_netact.Integrate Mrbts With Netact   release=${MRBTS_MO_RELEASE}
  ...  mr=${MRBTS_MO_MR}    mrbts_address=${mrbts_address}    dist_name=${ENB_ID}    security_mode=${SECURITY_MODE}
  ...   alias=${connection}
   Log    \n${integration_output}    console=${TRUE}

_common_classical_Deintergration
    [Arguments]     ${connection}      ${btsid}      ${btsip}       ${current_release}      ${mantaray_name}        ${timeout}
    log   ${btsid},${timeout},${btsip},${current_release},${mantaray_name}
    ${deintegration_output}=    mantaray_module_netact.DeIntegrate Mrbts From Netact    dist_name=${ENB_ID}
    ...    alias=${connection}
    Log    \n${deintegration_output}    console=${TRUE}


_common_cloud_Intergration
  [Arguments]    ${connection}      ${btsid}      ${btsip}       ${current_release}      ${mantaray_name}        ${timeout}
   log     ${btsid},${timeout}
   ${mrbts_address} =      Set Variable         ${btsip}
   ${ENB_ID}=       Set Variable         ${ENB_ID}
   ${MRBTS_MO_MR}=      Set Variable            ${${mantaray_name}_info.MR_CLOUD}
   ${MRBTS_MO_RELEASE}=      Set Variable      ${current_release}
   ${SECURITY_MODE} =       Set Variable         no TLS
  ${integration_output}=    mantaray_module_netact.Integrate Mrbts With Netact    release=${MRBTS_MO_RELEASE}
  ...  mr=${MRBTS_MO_MR}    mrbts_address=${mrbts_address}    dist_name=${ENB_ID}    security_mode=${SECURITY_MODE}
  ...   alias=${connection}
  Log    \n${integration_output}    console=${TRUE}

_common_cloud_Deintergration
  [Arguments]    ${connection}      ${btsid}      ${btsip}       ${current_release}      ${mantaray_name}        ${timeout}
  log   ${btsid},${btsip},${current_release},${mantaray_name},${timeout}
  ${integration_output}=    mantaray_module_netact.DeIntegrate Cloud   cloud_dn=${ENB_ID}     alias=${connection}
    ...    alias=${connection}
  Log    \n${deintegration_output}    console=${TRUE}


################################ CM operation #################################
Configuration Mantaray Operation
    [Arguments]
    ...    ${operation}
    ...    ${bts_index}=${0}
    ...    ${cudu_index}=${0}
    ...    ${mantaray_name}=${None}
    ...    ${plan_name}=${None}
    ...    ${editor_parameters}=${None}
    ...    ${editor_distname}=${None}
    ...    ${editor_operation}=${None}
    ...    ${file_path}=${None}
    ...    ${timeout}=${None}
    ...    &{kwargs}
    Log       ${editor_parameters}
    Log       ${editor_distname}
    Log       ${editor_operation}
    ${Variable_exist}=      Run Keyword and return Status     Variable Should Exist      ${plan_name_after}
    ${plan_name_after}=	      Set Variable If	   ${Variable_exist}==${True}     ${plan_name_after}	${None}
    log      ${bts_index},${cudu_index}
    Set Test Variable         ${mantaray_name}       ${mantaray_name}
    Set Test Variable         ${dist_names}    ${plan_name}
    ${timestamp}=    DateTime.Get Current Date    result_format=%Y%m%d%H%M%S
    Run Keyword If     '${plan_name}' == '${None}' and 'cm_importplan' == '${operation}'
    ...    Set Suite Variable     ${plan_name_after}      ${btsid}_for_mantary_module_${timestamp}
    ...    ELSE IF   '${plan_name}' == '${None}' and 'cm_importscf' =='${operation}'
    ...    Set Suite Variable     ${plan_name_after}      ${btsid}_for_mantary_module_${timestamp}
    ...    ELSE IF   '${plan_name}' != '${None}'     Set Suite Variable           ${plan_name_after}    ${plan_name}
    ...     ELSE IF   'editor' in '${operation}'    Log     skip this if
    ...    ELSE    Set Test Variable     ${plan_name_after}      ${plan_name_after}
    ${evaluate1}=      Evaluate       'import' not in '${operation}' or 'editor' not in '${operation}'
    Run Keyword If      '${plan_name_after}' == '${None}' and ${evaluate1} == ${False}
    ...    FAIl     plan name should not empty in this operation.
    ${origin_conn}=      Set Test Variable    ${connection}      mantaray_oper
    Mantaray Precondition     ${mantaray_name}    ${connection}
    ${is_supported_operation}    Set Variable    ${None}
    ${software_path}    Set Variable    ${None}
    ${is_supported_operation}    is_supported_operation    cm
    ...        ${operation}
    Run Keyword If
    ...     '${is_supported_operation}'=='${None}' or '${is_supported_operation}'=='${False}'
    ...    Fail    msg=Your operation no support yet. Please contact the model owner
     ${operation}=    Convert To Lowercase    ${operation}
     ${real_operation}=     find_operation    cm     no need      ${operation}
     Set Test Variable        ${real_operation}      ${real_operation}
     Run Keyword    ${real_operation}
        ...    editor_operation=${editor_operation}
        ...    editor_distname=${editor_distname}
        ...    editor_parameters=${editor_parameters}
        ...    file_path=${file_path}
        ...    ENB_ID=${ENB_ID}
        #...    plan_name=${plan_name_after}
        ...    mantaray_name=${mantaray_name}
        ...    connection=${connection}
        ...    timeout=${timeout}
    [Teardown]    Mantaray Postcondition     ${mantaray_name}      ${connection}

get_cm_mantaray_operation
    &{handle}    Create Dictionary
    ...    cm_exportplan=_export CM plan from mantaray
    ...    cm_edit_paramter_by_editor=_CM Edit Paramter By Editor
    ...    cm_exportactualplan=_export CM plan from mantaray
    ...    cm_importplan=_import CM plan to mantaray
    ...    cm_importscf=_import CM SCF to mantaray
    ...    cm_provisionplan=_Provsion Plan from mantaray
    ...    cm_prevalidateplan=_Validate Plan from mantaray
    ...    cm_deleteplan=_Delete Plan from mantaray
     ...   cm_validateplan=_Validate Plan on mantaray
    ...    cm_upload=_upload CM to mantaray
    [Return]    ${handle}

_Delete Plan from mantaray
     [Arguments]    ${parameters}     ${file_path}     ${ENB_ID}       ${mantaray_name}         ${connection}    ${timeout}
     ...     ${plan_name}=${plan_name_after}
     log    ${parameters},${file_path},${ENB_ID},${mantaray_name},${timeout}
     ${result}=    Run Keyword And Return Status    mantaray_module_netact.Delete Plan
     ...    plan_name=${plan_name}     	alias=${connection}
     Run Keyword If    ${result}
     ...   log to console     Plan ${plan_name}  succesffully impoted
     ...    ELSE    Run Keywords     log to console    Plan not ${plan_name} succesffully delete
     ...    AND    Fail    Plan ${plan_name} not succesffully delete

_Provsion Plan from mantaray
     [Arguments]     ${parameters}      ${file_path}     ${ENB_ID}         ${mantaray_name}         ${connection}    ${timeout}
     ...     ${plan_name}=${plan_name_after}
     log    ${parameters},${file_path},${ENB_ID},${mantaray_name},${timeout}
     ${result}=    Run Keyword And Return Status    mantaray_module_netact.Provision Plan
     ...    plan_name=${plan_name}     	alias=${connection}
     Run Keyword If    ${result}
     ...  log to console    Plan  ${plan_name}  succesffully impoted
     ...    ELSE    Run Keywords    log to console    Plan not ${file_path} succesffully provsioned
     ...    AND    Fail   plan provision not success,for detail please check the information on mantaray lab.

_Validate Plan on mantaray
     [Arguments]         ${file_path}     ${ENB_ID}            ${mantaray_name}         ${connection}    ${timeout}
     ...    ${plan_name}=${plan_name_after}
     log     ${file_path},${ENB_ID},${mantaray_name},${timeout}
     ${result}=      mantaray_module_netact.validate Plan
     ...    plan_name=${plan_name}    dist_names=${ENB_ID}     	alias=${connection}
     log to console   *************************************************************************
     log to console    Validate result: ${result}
     log to console   *************************************************************************

_upload CM to mantaray
    [Arguments]        ${file_path}      ${ENB_ID}         ${mantaray_name}        ${connection}    ${timeout}
    ...    ${plan_name}=${plan_name_after}
    log    ${file_path},${ENB_ID},${mantaray_name},${timeout},${plan_name}
    ${parameters_1}=   Create Dictionary    -lteHwContentInUse=${TRUE}    -sranBtsHwContentInUse=${TRUE}
    ${status}=    Run Keyword And Return Status    mantaray_module_netact.upload_configuration   dist_names=${ENB_ID}
     ...     parameters=${parameters_1}      alias=${connection}
     Run Keyword If    ${status}
     ...  log to console    CM upload successful
     ...    ELSE     Run Keywords     log to console     something wrong happens while cm upload
     ...      Fail   something wrong happens while cm upload

_import CM plan to mantaray
     [Arguments]          ${file_path}     ${ENB_ID}           ${mantaray_name}         ${connection}    ${timeout}
     ...    ${plan_name}=${plan_name_after}
     log    ${file_path},${ENB_ID},${mantaray_name},${timeout}
     ${status}=    Run Keyword And Return Status    OperatingSystem.File Should Exist    ${file_path}
     Run Keyword if    ${status}==${False}     Fail      file ${file_path} not exist!!!!!!
     #${file_path_after}=     Run Keyword If    '.xml' in '${file_path}'     Set Variable    ${file_path}
     #...    ELSE      Set Variable    ${file_path}/${plan_name}.xml
     ${actual_file_name}=      Fetch From Right    ${file_path}     /
     ${actual_path}=      Fetch From Left     ${file_path}     ${actual_file_name}
     ${result}=    Run Keyword And Return Status    mantaray_module_netact.Import Configuration
     ...   file_name=${actual_file_name}    local_dir=${actual_path} 		plan_name=${plan_name}    	ui_values=${TRUE}	verbose=${TRUE}
     ...    alias=${connection}
     Run Keyword If    ${result}
     ...  log to console     file ${file_path} with name ${plan_name} succesffully impoted
     ...    ELSE    Run Keywords    log to console    Plan not ${file_path} succesffully impoted
     ...    AND    Fail    file ${file_path} succesffully impoted



_import CM scf to mantaray
     [Arguments]          ${file_path}     ${ENB_ID}         ${mantaray_name}         ${connection}    ${timeout}
     ...    ${plan_name}=${plan_name_after}
     log    ${file_path},${ENB_ID},${mantaray_name},${timeout}
     ${status}=    Run Keyword And Return Status    OperatingSystem.File Should Exist    ${file_path}
     ${file_path_after}=     Run Keyword If    '.xml' in '${file_path}'     Set Variable    ${file_path}
     ...    ELSE      Set Variable    ${file_path}/${plan_name}.xml
     ${actual_file_name}=      Fetch From Right    ${file_path_after}     /
     ${actual_path}=      Fetch From Left     ${file_path_after}     ${actual_file_name}
     ${result}=    Run Keyword And Return Status    mantaray_module_netact.Import SCF
     ...    plan_name=${plan_name}    file_name=${actual_file_name}
     ...    local_dir=${actual_path}   dn_prefix=${ENB_ID} 	 verbose=${TRUE}
     ...    alias=${connection}
     Run Keyword If    ${result}
     ...   log to console     SCF ${file_path} succesffully impoted
     ...    ELSE    Run Keywords     log to console    SCF not ${file_path} succesffully impoted
     ...    AND    Fail    SCF ${file_path} succesffully impoted



_export CM plan from mantaray
     [Arguments]       ${file_path}     ${ENB_ID}         ${mantaray_name}         ${connection}    ${timeout}
     ...     ${plan_name}=${plan_name_after}
     log    ${file_path},${ENB_ID},${mantaray_name},${timeout}
     ${operation_type}=      Run Keyword If    'actual' in '${real_operation}'    Set Variable    actual
     ...     ELSE     Set Variable    plan
     ${file_path_after}=     Run Keyword If    '.xml' in '${file_path}'     Set Variable    ${file_path}
     ...    ELSE      Set Variable    ${file_path}/${plan_name}.xml
     ${status}=    Run Keyword And Return Status    OperatingSystem.Directory Should Exist    ${file_path}

     ${actual_file_name}=      Fetch From Right    ${file_path_after}     /
     ${actual_path}=      Fetch From Left     ${file_path_after}     ${actual_file_name}
     ${status}=    Run Keyword And Return Status    mantaray_module_netact.Export Configuration    local_dir=${file_path}
     ...  file_name=${plan_name}       dist_names=${ENB_ID}    operation_type=${operation_type}    plan_name=${plan_name}
     ...    alias=${connection}
     ${status}=    Run Keyword And Return Status    OperatingSystem.File Should Exist    ${file_path}/${plan_name}
     Run Keyword If    ${status}
     ...  Log    Plan ${plan_name} available at ${file_path}/${plan_name}    level=INFO    console=Truel
     ...    ELSE    Run Keywords    Log    Plan ${plan_name} not available at ${file_path}/${plan_name}    level=ERROR
     ...    AND    Fail    Plan ${plan_name} not available at ${file_path}/${plan_name}



Get Actual Configuration MO Data
    [Arguments]    ${mo_id}     ${connection}
    ${actual_conf}=    mantaray_module_netact.Get Actual Configuration    alias=${connection}
    ${managed_object}=    mantaray_module_netact.Get Managed Object    ${actual_conf}    ${mo_id}    alias=${connection}
    Log    \nManaged Object: ${managed_object}    console=${TRUE}
    Log    Meta Class: ${managed_object.meta_class}    console=${TRUE}
    Log    Meta Version: ${managed_object.meta_version}    console=${TRUE}
    Log    Parameters: ${managed_object.parameters}    console=${TRUE}
    [Return]    ${managed_object.meta_class}     ${managed_object.meta_version}    ${managed_object.parameters}


_CM Edit Paramter By Editor
    [Arguments]   ${editor_parameters}     ${editor_distname}     ${editor_operation}      ${file_path}     ${ENB_ID}       ${mantaray_name}
    ...    ${connection}    ${timeout}
    Log     ${file_path}
    Log     ${mantaray_name}
    Log     ${timeout}
    ${timestamp}=    DateTime.Get Current Date    result_format=%Y%m%d%H%M%S
    ${plan_name}=    Set Variable    ditor_1234-${ENB_ID}-${timestamp}
    ${PLAN_DESCRIPTION}=     Set Variable     a pretty good plan
    ${status}    ${plan}=    Run Keyword And Ignore Error    mantaray_module_netact.Get Plan Configuration    ${plan_name}    alias=${connection}
    Run Keyword If    '${status}' == 'PASS'    mantaray_module_netact.Delete Plan    ${plan_name}    alias=${connection}
    ${plan_conf}=    mantaray_module_netact.Create Plan Configuration    ${plan_name}    ${PLAN_DESCRIPTION}    alias=${connection}
    ${contains_splitter}=    Evaluate    '+++' in '${editor_parameters}'
    Run Keyword If    ${contains_splitter}    Process Multiple Creates   ${plan_conf}    ${editor_parameters}    ${editor_distname}
    ...    ${editor_operation}      ${connection}
    ...    ELSE    Process Single Create  ${plan_conf}    ${editor_parameters}    ${editor_distname}
    ...    ${editor_operation}        ${connection}
    ${status_provision}=     Run Keyword and Return Status    Provision Plan    ${plan_name}-${ENB_ID}      ${ENB_ID}
    ...     backup_plan_name=${plan_name}-${ENB_ID}-backup
    ...      create_backup_plan=${TRUE}    provisioning_operation=activate    alias=${connection}
    Run Keyword If      ${status_provision}     Log to console     editor plan ${plan_name} has been uploaded to bts!
    ...    ELSE    FAIL     Something wrong happend while provision plan ${plan_name}


Process Single Create
    [Arguments]    ${plan_conf}    ${parameters}    ${editor_distname}    ${editor_operation}    ${connection}
    ${pattern}=    Define Pattern    ${parameters}
    ${abbrevation}=     Get Editor Keyword     ${parameters}
    ${result}=    Run Keyword If    '${pattern}' == 'is_dict'    Create Dict MO    ${parameters}
    ...    ELSE IF    '${pattern}' == 'is_list'    Create List MO    ${parameters}
    ...    ELSE IF    '${pattern}' == 'is_value'    Create Value MO    ${parameters}
    ...    ELSE IF    'empty' in '${pattern}'    Set Variable    ${EMPTY}
    ...    ELSE    Fail    Unsupported format for parameters: ${parameters}
    ${meta_class}     ${meta_version}    ${parameters}=    Get Actual Configuration MO Data     ${editor_distname}    ${connection}
    ${managed_object}=    mantaray_module_netact.Create Managed Object    plan=${plan_conf}    meta_class=${meta_class}
    ...    meta_version=${meta_version}    mo_id=${editor_distname}    operation=${editor_operation}
    ...    alias=${connection}      ${abbrevation}=${result}

Process Multiple Creates
    [Arguments]    ${plan_conf}    ${parameters}    ${editor_distname}    ${editor_operation}    ${connection}
    ${split_parameters}=    Split String    ${parameters}    +++
    ${split_operations}=    Split String    ${editor_operation}    ,
    ${split_distnames}=    Split String    ${editor_distname}    ,
    ${lenth_of_input}=     Get Length      ${split_parameters}
    FOR    ${index}    IN RANGE    0      ${lenth_of_input}
        ${current_part}=    Set Variable    ${split_parameters[${index}]}
        ${current_operation}=    Set Variable    ${split_operations[${index}]}
        ${current_distname}=    Set Variable    ${split_distnames[${index}]}
        ${current_abbrevation}=     Get Editor Keyword     ${current_part}
        ${pattern}=    Define Pattern    ${current_part}
        ${result}=    Run Keyword If    '${pattern}' == 'is_dict'    Create Dict MO    ${current_part}
        ...    ELSE IF    '${pattern}' == 'is_list'    Create List MO    ${current_part}
        ...    ELSE IF    '${pattern}' == 'is_value'    Create Value MO    ${current_part}
        ...    ELSE IF    'empty' in '${pattern}'    Set Variable    ${EMPTY}
        ...    ELSE    Fail    Unsupported format for part: ${current_part}
        ${meta_class}     ${meta_version}    ${parameters}=    Get Actual Configuration MO Data     ${current_distname}    ${connection}
        ${managed_object}=    mantaray_module_netact.Create Managed Object    plan=${plan_conf}    meta_class=${meta_class}
        ...    meta_version=${meta_version}
        ...    mo_id=${current_distname}    operation=${current_operation}      alias=${connection}      ${current_abbrevation}=${result}
    END



Get Editor Keyword
    [Arguments]    ${parameters}
    ${pattern}=    Set Variable    EDItor_(\\w+)
    ${matches}=    Evaluate    re.findall(r"${pattern}", """${parameters}""")
    Log To Console    Matches: ${matches}
    [Return]    ${matches[0]}

Create Dict MO
    [Arguments]    ${parameters}
    [Documentation]    ?EDItor_total{{parameter_A:"33333",paraete_B:'444444',parameter_C:"44444"},{parameter_A:"11111",paraete_B:'22222',
    ...    parameter_C:"d"},{parameter_A:"ssss",paraete_B:'dddd',parameter_C:"d"}}
    ${matches}=    Evaluate    re.findall(r"EDItor_\\w+\\{\\{(.*)\\}\\}", """${parameters}""")
    ${content}=    Set Variable    ${matches[0]}
    ${items}=    Split String    ${content}    },{
    ${result}=    Create List
    FOR    ${item}    IN    @{items}
        ${cleaned_item}=    Replace String    ${item}    {    ${EMPTY}
        ${cleaned_item}=    Replace String    ${cleaned_item}    }    ${EMPTY}
        ${key_value_pairs}=    Split String    ${cleaned_item}    ,
        ${dict}=    Create Dictionary
        FOR    ${pair}    IN    @{key_value_pairs}
            ${key}=    Run Keyword    Extract Key From Pair    ${pair}
            ${value}=    Run Keyword    Extract Value From Pair    ${pair}
            Set To Dictionary    ${dict}    ${key}    ${value}
        END
        Append To List    ${result}    ${dict}
    END

    [Return]    ${result}

Extract Key From Pair
    [Arguments]    ${pair}
    ${key}=    Run Keyword    Parse Key Or Value    ${pair}    0
    [Return]    ${key}

Extract Value From Pair
    [Arguments]    ${pair}
    ${value}=    Run Keyword    Parse Key Or Value    ${pair}    1
    [Return]    ${value}

Parse Key Or Value
    [Arguments]    ${pair}    ${index}
    ${split_pair}=    Split String    ${pair}    :
    ${result}=    Strip String    ${split_pair[${index}]}
    ${result}=    Replace String    ${result}    "    ${EMPTY}
    ${result}=    Replace String    ${result}    '    ${EMPTY}
    [Return]    ${result}

Create List MO
    [Arguments]    ${parameters}
    [Documentation]   EDItor_ntpServerIpAddrOrFqdnList{"1.1.1.1","10.56.126.22","3.3.3.3"}
    ${matches}=    Evaluate    re.findall(r"EDItor_\\w+\\{(.*?)\\}", """${parameters}""")
    Run Keyword If    len(${matches}) == 0    Fail    Input does not match the expected format: ${parameters}
    ${content}=    Set Variable    ${matches[0]}
    ${items}=    Split String    ${content}    ,
    ${result}=    Create List
    FOR    ${item}    IN    @{items}
        ${cleaned_item}=    Strip String    ${item}
        ${cleaned_item}=    Replace String    ${cleaned_item}    "    ${EMPTY}
        ${cleaned_item}=    Replace String    ${cleaned_item}    '    ${EMPTY}
        Append To List    ${result}    ${cleaned_item}
    END

    [Return]    ${result}

Create Value MO
    [Arguments]    ${parameters}
    [Documentation]    EDItor_btsName{"vttk"}
    ${matches}=    Evaluate    re.findall(r"EDItor_(\\w+)\\{\\"(.*?)\\"\\}", """${parameters}""")
    Run Keyword If    len(${matches}) == 0    Fail    Input does not match the expected format: ${parameters}
    ${value}=    Set Variable    ${matches[0][1]}
    [Return]    ${value}

Create Empty MO
    [Arguments]    ${parameters}
    [Documentation]    EDItor_btsName{""}
    ${matches}=    Evaluate    re.findall(r"EDItor_(\\w+)\\{\\"(.*?)\\"\\}", """${parameters}""")
    Run Keyword If    len(${matches}) == 0    Fail    Input does not match the expected format: ${parameters}
    ${value}=    Set Variable    ${matches[0][1]}
    [Return]    ${value}


Define Pattern
    [Arguments]    ${parameters}
    [Documentation]    ?EDItor_total{{parameter_A:33333,paraete_B:444444},{parameter_A:11111,paraete_B:22222}}
    ...    EDItor_ntpServerIpAddrList{parameter_A:"33333",paraete_B:'444444'}
    ...      EDItor_ntpServerIpAddrList{"33333333"}
    ${is_dict}=    Run Keyword And Return Status    Should Match Regexp    ${parameters}    ^EDItor_\\w+\\{\\{.*?\\}\\}$
    ${is_empty_dict}=    Run Keyword And Return Status    Should Match Regexp    ${parameters}    ^EDItor_\\w+\\{\\{\\}\\}$
    ${is_list}=    Run Keyword And Return Status    Should Match Regexp    ${parameters}     ^EDItor_\\w+\\{".*?"(,\\s*".*?")+\\}$
    ${is_empty_list}=    Run Keyword And Return Status    Should Match Regexp    ${parameters}    ^EDItor_\\w+\\{\\}$
    ${is_value}=    Run Keyword And Return Status    Should Match Regexp   ${parameters}    ^EDItor_\\w+\\{".*?"\\}$
    ${is_empty_value}=    Run Keyword And Return Status    Should Match Regexp    ${parameters}    ^EDItor_\\w+\\{\\}$
    ${Pattern_type}=     Run Keyword If     ${is_dict}==${True}      Set Variable    is_dict
    ...    ELSE IF     ${is_list}==${True}    Set Variable   is_list
    ...    ELSE IF      ${is_value}==${True}    Set Variable     is_value
    ...    ELSE IF     ${is_empty_dict}==${True}    Set Variable   is_empty_dict
    ...    ELSE IF      ${is_empty_list}==${True}    Set Variable     is_empty_list
    ...    ELSE IF      ${is_empty_value}==${True}    Set Variable     is_empty_value
    ...    ELSE       Fail    Input does not match any expected format: dict, list, or value.
    [Return]     ${Pattern_type}


################################ SWM operation #################################
SWM Mantaray Operation
    [Arguments]
    ...    ${operation}
    ...    ${bts_index}=${0}
    ...    ${cudu_index}=${0}
    ...    ${mantaray_name}=${None}
    ...    ${software_build}=${None}
    ...    ${timeout}=${None}
    ...    &{kwargs}
    log    ${bts_index},${cudu_index}
    Set Test Variable         ${mantaray_name}       ${mantaray_name}
    Set Test Variable         ${software_build}       ${software_build}
    ${origin_conn}=      Set Test Variable    ${connection}      mantaray_oper
    Mantaray Precondition     ${mantaray_name}    ${connection}
    ${is_supported_operation}    Set Variable    ${None}
    ${software_path}    Set Variable    ${None}
    ${is_supported_operation}    is_supported_operation   swm
    ...        ${operation}
    #download the sw if sw version provided
    Run Keyword If
    ...     '${is_supported_operation}'=='${None}' or '${is_supported_operation}'=='${False}'
    ...    Fail    msg=Your operation no support yet. Please contact the model owner
     ${real_operation}=     find_operation    swm    no need     ${operation}
     Set Test Variable        ${real_operation}      ${real_operation}
     #rusw, cloud,knife has to be local file
    ${judger} =      Evaluate      '${operation}'=='swm_rollback' or '${operation}'=='swm_upload'
    Run Keyword if   ${judger}==${True}      Set Variable     ${software_path}     ${EMPTY}
    ...    ELSE        precheck for swm operation
    Run Keyword    ${real_operation}
        ...    software_path=${software_path}
        ...    ENB_ID=${ENB_ID}
        ...    mantaray_name=${mantaray_name}
        ...    connection=${connection}
        ...    timeout=${timeout}
    [Teardown]    Mantaray Postcondition     ${mantaray_name}      ${connection}


precheck for swm operation
    ${is_RUSW}=   Run Keyword And Return Status     Should Contain      ${software_build}      RUSW
    ${is_cloud_build}=   Run Keyword And Return Status     Should Contain      ${software_build}     CNF
    ${is_given_local}=   Run Keyword And Return Status     Should Contain      ${software_build}     /
    ${is_not_knife_file}=         Validate knife build      ${software_build}
    ${is_local_file}=      Run Keyword and return Status     OperatingSystem.File Should Exist       ${software_build}
    ${is_T1}=      Run Keyword and return Status     Should Contain      ${software_build}      T1
    ${is_T2}=      Run Keyword and return Status     Should Contain      ${software_build}      T2
    Set Test Variable      ${is_T1}     ${is_T1}
    Set Test Variable      ${is_T2}     ${is_T2}
    Run Keyword If     ${is_local_file}==${False} and ${is_RUSW}==${True}
    ...    FAIL     RUSW build have to provided file path.Please check you software_build argument.
    ...   ELSE IF      ${is_local_file}==${False} and ${is_cloud_build}==${True}
    ...    FAIL     Cloud build have to provided file path.Please check you software_build argument.
    ...   ELSE IF      ${is_local_file}==${False} and ${is_not_knife_file}==${False}
    ...    FAIL     Knife build have to provided file path.Please check you software_build argument.

    #Run keyword if       ${is_T1}==${True} or ${is_T2}==${True}      Find real build if T1 and T2      ${software_build}

    #no matter T1 or T2 or org, build name user original one
    Run keyword if       ${is_local_file}==${True}
    ...     Set Test Variable    ${software_path}      ${software_build}
    ...      ELSE IF      ${is_local_file}==${False} and ${is_T1}==${True}
    ...     Find real build if T1 and T2      ${software_build}      T1
    ...      ELSE IF      ${is_local_file}==${False} and ${is_T2}==${True}
    ...     Find real build if T1 and T2      ${software_build}      T2
    ...     ELSE      Set Test Variable    ${software_path}  /${software_build}_release_BTSSM_downloadable_A54.zip
    #Set Test Variable    ${software_path}  /${software_build}_release_BTSSM_downloadable_A54_T1.zip
    #classical, vcu,bdu trunk build
    #vCUCNF00_0.250.19886.zip
    ${tmp_bool} =     Evaluate   ('SBTS00' in '${software_path}') or ('vCUCNF00' in '${software_path}') or ('vDUCNF00' in '${software_path}')
    ${tmp_bool_1} =     Evaluate     ('SBTS' in '${software_path}') and ('SBTS00' not in '${software_path}')

    ${build_for_precheck}=     Run Keyword If      ${tmp_bool}
    ...  change path to mantaray package name with accurate release     ${software_path}
    #classical branch build
    ...    ELSE IF    ${tmp_bool_1}
    ...     change path to mantaray package name with branch build     ${software_path}
    #vcu,vdu branch release and  rusw release
    ...   ELSE      fetch relaese name for vcuvdu branch release and rusw build      ${software_path}
    ${import_checker}=      check provided software is already imported      ${build_for_precheck}     ${connection}
    #fail if sw not imported, ask for import the build first before sw operation
    Run Keyword If     ${import_checker}==${False} and '${real_operation}'!='_import SW to mantaray'
    ...     FAIL     Need import the given before your action



Find real build if T1 and T2
    [Arguments]     ${org_build}     ${T_value}
    ${build_name}=      Fetch From Left     ${org_build}   ${T_value}
    Set Test Variable     ${software_path}     /${build_name}_release_BTSSM_downloadable_A54.zip






fetch relaese name for vcuvdu branch release and rusw build
    [Arguments]    ${build}
    ${build}=      Fetch From Right     ${build}     /
    ${build}=      Run Keyword If   'RUSW' in '${build}'    Fetch From Left     ${build}     -l
    ...    ELSE     Set Variable     ${build}
    ${build}=      Fetch From Left     ${build}     .zip
    [Return]      ${build}

Validate knife build
    [Arguments]    ${build}
     ${build}=            Fetch From right               ${build}      SBTS
     ${addition_if_path_given}=            Fetch From left               ${build}      .zip
     @{list_of_build}     Split String     ${build}      _
     #${status_trunk}=       Run Keyword and return status     Should contain      ${build}      9999
     #${status_T1}=       Run Keyword and return status     Should contain      ${build}      T1
     #${status_T2}=       Run Keyword and return status     Should contain      ${build}      T2
#     ${build}=      	Run Keyword If    ${status_trunk}==${FALSE} and ${status_T1}==${FALSE} and ${status_T1}==${FALSE}
#     ...    Get Substring	 ${build}	     23      28
#     ...   ELSE      Get Substring	      ${build}	     20      25
     ${status}=       Run Keyword And return Status      should contain     ${list_of_build}][4]     0000
     #${build}=      	Run Keyword If    ${status_trunk}==${FALSE} and ${status_T1}==${FALSE} and ${status_T1}==${FALSE}
     [Return]      ${Status}

find trunk release
    [Arguments]    ${largest_branch_release}
    #Log To Console    ${largest_branch_release}
    ${prefix} =    Fetch From Left    ${largest_branch_release}    R
    ${suffix} =    Fetch From Right    ${largest_branch_release}    R
    ${new_suffix} =    Evaluate    ${suffix} + 1 if ${suffix} != 3 else 1
    ${new_prefix} =    Evaluate    str('${prefix[:-2]}')+ str(int(eval('${prefix[-2:]}')) + 1) if ${suffix} == 3 else '${prefix}'
    ${trunk_release}=    Catenate    ${new_prefix}R${new_suffix}
    ${trunk_release}=      Run Keyword If     'SBTS' in '${trunk_release}'     Fetch From Right    ${trunk_release}    SBTS
    ...     ELSE IF    'CNF' in '${trunk_release}'     Fetch From Right    ${trunk_release}    CNF
    ...    ELSE IF    'FHGW' in '${trunk_release}'       Fetch From Right    ${trunk_release}    FHGW
    [return]	  ${trunk_release}


Download_Specify_Build_on_SpecifyHost_module_version
    [Arguments]    ${enb_build}    ${Package_type}   ${IP}  ${port}  ${usr}  ${pwd}   ${copy_build_to_local}
    ...   ${target_local_path}=/home/ute/sw_bak
    [Documentation]
    ...  |  This KW is about downloading specify package to specify server by speed-up.
    ...  |  parameter1: enb_build (string) ? e.g. SBTS00_ENB_9999_200727_000001
    ...  | parameter2: Package_type(string) ? e.g. Basic | T1 | T2
    ...  | If Basic, SBTS00_ENB_9999_200727_000001__release_BTSSM_downloadable_A54.zip
    ...  | If T1, \ SBTS00_ENB_9999_200727_000001_release_BTSSM_downloadable_testpackage_T1_A54.zip
    ...  | If T2, \ SBTS00_ENB_9999_200727_000001_release_BTSSM_downloadable_testpackage_T2_A54.zip
    ...  | parameter3,4,5: IP,port,usr,pwd, all these parameter type is string. Info of specify host,
    ...    eg:banglore_server(10.41.146.248 22 root Nokia_150)
    ...  | parameter: copy_build_to_local, type is boolean, Indicates whether to copy the package from the specified
    ...    server to the local, the default value is false
    ...  | parameter: target_local_path(string),if copy_build_to_local is set true, need to set local path for copy,
    ...    default value is /home/ute/sw_bak
    log     ${port}
    ${enb_build}=    Run Keyword If    '9999' in '${enb_build}'    Replace String Using Regexp    ${enb_build}
    ...    SBTS\\d{2,2}\\w[0-9]?_    SBTS00_
    ...    ELSE    Set variable    ${enb_build}
   ${platform_R3}  Run keyword and return status  Should be true  'FSM3' in '${enb_build}'
    ${release}  Run keyword if  ${platform_R3}  Run Keyword  Should Match Regexp  ${enb_build}
    ...  [SBTS]{4}[0-5]{2}[R]{0,1}[0-5]{0,1}_[FSM3]{0,4}  flags=IGNORECASE
    ...   ELSE  Run Keyword  Fetch from left    ${enb_build}    _
	${num}    Should Match Regexp    ${release}    [0-9][0-9]
	${scm_server}    Set variable
	...  ${scm_server}/build/${release}/${enb_build}
    ${download_path}    Run Keyword If    '9999' in '${enb_build}'
    ...  Set variable    /home/ute/HZOAM/01_BTS_SW/New_Trunk
    ...    ELSE    Set variable    /home/ute/HZOAM/01_BTS_SW/${release}
    ${build_match_no}    Run keyword if    'SBTS00' in '${release}'    Set variable    A54
	...    ELSE IF    '${num}'>='21'    Set variable    A54
    ...    ELSE IF    '${num}'>='20' and ('C' in '${release}')    Set variable    A54
    ...    ELSE IF    '${num}'<='20' and ('00' not in '${release}') and ('C' not in '${release}')    Set variable    A53
    ${build_url}    Set Variable If
    ...  '${Package_type}'=='Basic'
    ...  ${scm_server}/${enb_build}_release_BTSSM_downloadable_${build_match_no}.zip
    ...  '${Package_type}'=='T1'
    ...  ${scm_server}/${enb_build}_release_BTSSM_downloadable_testpackage_T1_${build_match_no}.zip
    ...  '${Package_type}'=='T2'
    ...  ${scm_server}/${enb_build}_release_BTSSM_downloadable_testpackage_T2_${build_match_no}.zip
    ${remote_full_path}    Set Variable If    '${Package_type}'=='Basic'
    ...   ${download_path}${/}${enb_build}_release_BTSSM_downloadable_${build_match_no}.zip
    ...  '${Package_type}'=='T1'
    ...  ${download_path}${/}${enb_build}_release_BTSSM_downloadable_testpackage_T1_${build_match_no}.zip
    ...  '${Package_type}'=='T2'
    ...  ${download_path}${/}${enb_build}_release_BTSSM_downloadable_testpackage_T2_${build_match_no}.zip
    set test Variable    ${cm1}  --all-proxy="" --continue --max-connection-per-server=16
    set test Variable    ${cmd1}
    ...  aria2c \ --file-allocation=none ${cm1} --split=16 ${build_url} -d ${download_path}
    mantaray_module_ssh.Connect To      ${IP}      ${usr}    ${pwd}     alias=download_build_to_remote
    ${rc}=    mantaray_module_ssh.File Exists     ${remote_full_path}     connection=download_build_to_remote
    Run keyword if    ${rc}==${FALSE}
    ...  Wait Until Keyword Succeeds    60 minutes    5 secs    mantaray_module_ssh.Execute    ${cmd1}
    ...    connection=download_build_to_remote
    Sleep     5min
    Set test Variable    ${local_path}    ${target_local_path}
    ${status_curl}=    Run Keyword And Ignore Error    OperatingSystem.Directory Should Exist    ${local_path}
    Run Keyword If    '${status_curl[0]}'=='FAIL'    Create Directory    ${local_path}
    OperatingSystem.Directory Should Exist    ${local_path}
    ${local_full_path}    Set Variable If    '${Package_type}'=='Basic'
    ...  ${local_path}/${enb_build}_release_BTSSM_downloadable_${build_match_no}.zip
    ...  '${Package_type}'=='T1'
    ...  ${local_path}/${enb_build}_release_BTSSM_downloadable_testpackage_T1_${build_match_no}.zip
    ...  '${Package_type}'=='T2'
    ...  ${local_path}/${enb_build}_release_BTSSM_downloadable_testpackage_T2_${build_match_no}.zip
    ${build_exist_local_before}   Run keyword and return status    File should exist    ${local_full_path}
    ${copy_build_to_local}  Evaluate  '${copy_build_to_local}'.lower()
    Run keyword if     '${build_exist_local_before}'=='False' and '${copy_build_to_local}'=='true'
    ...  Run keywords  mantaray module internal sftp download   ${IP}  ${usr}    ${pwd}    ${remote_full_path}     ${local_full_path}
    ...  AND    BuiltIn.Log To Console    Finished download ${Package_type} build to ${local_path}/
    mantaray_module_ssh.Disconnect    connection=download_build_to_remote
    [Return]    ${remote_full_path}    ${local_full_path}

get_swm_mantaray_operation
    &{handle}    Create Dictionary
    ...    swm_precheck=_precheck SW from mantaray
    ...    swm_postcheck=_postcheck SW from mantaray
    ...    swm_import_build=_import SW to mantaray
    ...    swm_activation=_activate SW from mantaray
    ...    swm_rollback=_rollback SW from mantaray
    ...    swm_download=_download SW from mantaray
    ...    swm_provision=_provision SW from mantaray
    ...    swm_upload=_upload SW configuration from mantaray
    [Return]    ${handle}

_download SW from mantaray
    [Arguments]     ${software_path}    ${mantaray_name}      ${ENB_ID}       ${connection}    ${timeout}
    Log To Console     Start sw download
    ${software}=     change path to mantaray package name with accurate release    ${software_path}
    ${log}=     mantaray_module_netact.download_sw      dist_names=${ENB_ID}    package_name=${software}
    ...    timeout=${timeout}     alias=${connection}
    Should Contain    ${log}    SUCCESS
    Log To Console     ${log}
    [Teardown]    Mantaray Postcondition     ${mantaray_name}      ${connection}

_provision SW from mantaray
    [Arguments]        ${software_path}     ${mantaray_name}         ${ENB_ID}       ${connection}    ${timeout}
    Log To Console     Start sw provision
    ${software}=     change path to mantaray package name with accurate release    ${software_path}
    ${log}    mantaray_module_netact.provision_sw    dist_names=${ENB_ID}    package_name=${software}
    ...    timeout=${timeout}     alias=${connection}
    Should Contain    ${log}    SUCCESS
    Log To Console     ${log}
    [Teardown]   Mantaray Postcondition     ${mantaray_name}      ${connection}

_activate SW from mantaray
    [Arguments]     ${software_path}    ${mantaray_name}        ${ENB_ID}       ${connection}    ${timeout}
    Log To Console     Start sw activation
    ${software}=     change path to mantaray package name with accurate release    ${software_path}
    ${log}    mantaray_module_netact.activate_sw    dist_names=${ENB_ID}    package_name=${software}
    ...    timeout=${timeout}     alias=${connection}
    Should Contain    ${log}    SUCCESS
    Log To Console     ${log}
    [Teardown]    Mantaray Postcondition     ${mantaray_name}      ${connection}

_postcheck SW from mantaray
    [Arguments]        ${software_path}    ${mantaray_name}        ${ENB_ID}       ${connection}    ${timeout}
    Log To Console     Start sw postcheck
    ${software}=     change path to mantaray package name with accurate release    ${software_path}
    ${log}    mantaray_module_netact.postcheck_sw      dist_names=${ENB_ID}    package_name=${software}
    ...    timeout=${timeout}     alias=${connection}
    Should Contain    ${log}    SUCCESS
    Log To Console     ${log}
    [Teardown]    Mantaray Postcondition     ${mantaray_name}      ${connection}


_precheck SW from mantaray
    [Arguments]        ${software_path}     ${mantaray_name}        ${ENB_ID}       ${connection}    ${timeout}
    Log To Console     Start sw precheck
    &{prechec_attri} =	Create Dictionary	precheckType=fullCheck
    ${software}=     change path to mantaray package name with accurate release    ${software_path}
    ${log}    mantaray_module_netact.precheck_sw      dist_names=${ENB_ID}    package_name=${software}
    ...    custom_attributes=${prechec_attri}  timeout=${timeout}     alias=${connection}
    Should Contain    ${log}    SUCCESS
    Log To Console     ${log}
    [Teardown]    Mantaray Postcondition     ${mantaray_name}      ${connection}

_upload SW configuration from mantaray
    [Arguments]        ${software_path}     ${mantaray_name}        ${ENB_ID}       ${connection}    ${timeout}
    log    ${software_path}
    Log To Console     Start sw upload
    ${log}    Upload SW     ${ENB_ID}       timeout=${timeout}      alias=${connection}
    Should Contain    ${log}    SUCCESS
    Log To Console     ${log}
    [Teardown]    Mantaray Postcondition     ${mantaray_name}      ${connection}

_rollback SW from mantaray
    [Arguments]        ${software_path}     ${mantaray_name}        ${ENB_ID}       ${connection}    ${timeout}
    log    ${software_path}
    Log To Console     Start sw rollback
    ${log}    mantaray_module_netact.rollback_sw      ${ENB_ID}       ${timeout}     ${connection}
    Should Contain    ${log}    SUCCESS
    Log To Console     ${log}
    [Teardown]    Mantaray Postcondition     ${mantaray_name}      ${connection}

_import SW to mantaray
	[Arguments]     ${software_path}     ${mantaray_name}      ${ENB_ID}       ${connection}    ${timeout}
    #Check build in Netact otherwise Import
    log    ${ENB_ID},${timeout}
    ${build}=      Fetch From Right      ${software_path}     SBTS
    @{get_build_id}=      	Split String	${build}	_
    ${is_not_knife_file}=   Run Keyword And Return Status     Should Contain      ${get_build_id}[4]      0000
    ${is_not_RUSW}=   Run Keyword And Return Status     Should Not Contain      ${get_build_id}[0]      RUSW

    ${software_with_release}=     change path to mantaray package name with accurate release    ${software_path}
    ${release_NUM}=     Fetch From Left     ${software_with_release}     _
    ${release_NUM}=     Fetch From RIGHT     ${release_NUM}     SBTS
    ${software_with_no_release}=     change path to mantaray package name with branch build     ${software_path}
    ${Mid_Server}  ${Mid_Server_usr}  ${Mid_Server_pwd}=  Select_mid_server_between_hz_bangalore  ${${mantaray_name}_info.IP}
    ${T}=     Run Keyword If    ${is_T1}==${True}     Set Variable     T1
    ...    ELSE IF    ${is_T2}==${True}      Set Variable     T2
    ...    ELSE     Set Variable     Basic
    ${build_with_no_Tvalue}=       Run Keyword If    ${is_T1}==${True}
    ...    Fetch From Left      ${software_with_no_release}     T1
    ...    ELSE IF     ${is_T2}==${True}       Fetch From Left      ${software_with_no_release}     T2
    ...    ELSE    Set Variable     ${software_with_no_release}



    Run Keyword if    ${is_not_knife_file}==${TRUE} and ${is_not_RUSW}==${True}    upload_and_import_to_mantaray_via_choosen_server
                                                            ...  target_sw=${build_with_no_Tvalue}
                                                            ...  release_NUM=${release_NUM}
                                                            ...   sw_type=${T}
                                                            ...  remote_ip=${Mid_Server}
                                                            ...  remote_usr=${Mid_Server_usr}
                                                            ...  remote_pwd=${Mid_Server_pwd}
                                                            ...  alias=${connection}

    ...      ELSE     Run Keywords      Upload file to Mantaray from local    ${software_path}   ${software_with_release}
    ...    ${${mantaray_name}_info.IP}       ${${mantaray_name}_info.USERNAME}    ${${mantaray_name}_info.PASSWORD}
    ...     AND    mantaray_module_netact.Import Build    ${software_with_release}.zip      alias=${connection}
    Log      Success Imported!    console=true
    [Teardown]    Mantaray Postcondition     ${mantaray_name}      ${connection}




################################ SWM helper KW #################################
change path to mantaray package name with accurate release
    [Arguments]        ${software_path}
    ${build_file_name}=  Fetch From Right     ${software_path}      /
    ${build_name}=  Run Keyword If      '_release' in '${build_file_name}'    Fetch From Left     ${build_file_name}      _release
    ...    ELSE       Fetch From Left      ${build_file_name}      .zip
    ${enb_build}=    Run Keyword If    'SBTS00' in '${build_name}'
    ...  Replace String    ${build_name}     SBTS00    SBTS${trunk_release}
    ...    ELSE IF    'vCUCNF00' in '${build_name}'     Replace String    ${build_name}     vCUCNF00    vCUCNF${trunk_release}
    ...    ELSE IF    'vDUCNF00' in '${build_name}'     Replace String    ${build_name}     vDUCNF00    vDUCNF${trunk_release}
    ...    ELSE    Set variable    ${build_name}
    ${enb_build}=      Run keyword If     ${is_T1}==${True}      combine to T1 and T2      ${enb_build}     T1
    ...    ELSE IF     ${is_T2}==${True}      combine to T1 and T2      ${enb_build}     T2
    ...    ELSE       Set variable    ${enb_build}
    [Return]     ${enb_build}

combine to T1 and T2
     [Arguments]        ${software_path}     ${T_value}
     ${final_part}=     Fetch From Left      ${software_path}      .zip
     ${final_part}=      Catenate	      SEPARATOR=     ${final_part}     ${T_value}
     [Return]     ${final_part}


change path to mantaray package name with branch build
    [Arguments]        ${software_path}
    ${build_file_name}=  Fetch From Right     ${software_path}      /
    ${build_name}=  Fetch From Left     ${build_file_name}      _release
    ${enb_build}=      Run keyword If     ${is_T1}==${True}      combine to T1 and T2      ${build_name}     T1
    ...   ELSE IF       ${is_T2}==${True}      combine to T1 and T2      ${build_name}     T2
    ...    ELSE       Set variable    ${build_name}
    [Return]     ${enb_build}

mantaray module internal sftp upload
    [Arguments]   ${hostname}  ${user}  ${password}  ${source_filepath}  ${desnation_filepath}  ${alias}=default
    [Documentation]  This keyword is used to upload local file to remote server
        ...
    ...
    ...    |Input Parameters| Man. | Description|
    ...    | hostname | Yes | the ip of destination server  |
    ...    | user   | Yes  | the username of destination server  |
    ...    | password | Yes | the password of destination server  |
    ...    | source_filepath   | Yes  | local file path |
    ...    | desnation_filepath | Yes | remote destination paht  |
    ...    | alias   | No  | default alias is used:"default" |
    ...   Example
    ...  | Sftp Upload | /etc/hosts | /home/TheUser/hosts_from_remote|
    mantaray_module_ssh.Connect To    ${hostname}    ${user}    ${password}   alias=${alias}
    mantaray_module_ssh.Upload File    ${source_filepath}  ${desnation_filepath}   connection=${alias}
    mantaray_module_ssh.Disconnect    connection=${alias}

mantaray module internal sftp download
    [Arguments]   ${hostname}  ${user}  ${password}  ${source_filepath}  ${desnation_filepath}  ${alias}=default
    [Documentation]  This keyword is used to download local file from remote server
        ...
    ...
    ...    |Input Parameters| Man. | Description|
    ...    | hostname | Yes | the ip of destination server  |
    ...    | user   | Yes  | the username of destination server  |
    ...    | password | Yes | the password of destination server  |
    ...    | source_filepath   | Yes  | local file path |
    ...    | desnation_filepath | Yes | remote destination paht  |
    ...    | alias   | No  | default alias is used:"default" |
    ...   Example
    ...  | Sftp Upload | /etc/hosts | /home/TheUser/hosts_from_remote|
    mantaray_module_ssh.Connect To    ${hostname}    ${user}    ${password}   alias=${alias}
    mantaray_module_ssh.Download File    ${source_filepath}  ${desnation_filepath}   connection=${alias}
    mantaray_module_ssh.Disconnect    connection=${alias}

Select_mid_server_between_hz_bangalore
    [Arguments]  ${IP}
    Run keyword if  str("""${IP}""") in @{HZ_NA_list}
    ...  Run keywords
                  ...  set test variable  ${Mid_Server}  10.108.184.40
                  ...  AND  set test variable  ${Mid_Server_usr}  ute
                  ...  AND  set test variable  ${Mid_Server_pwd}  ute
    ...  ELSE
    ...  Run keywords
                  ...  set test variable  ${Mid_Server}  10.41.146.248
                  ...  AND  set test variable  ${Mid_Server_usr}  root
                  ...  AND  set test variable  ${Mid_Server_pwd}  Nokia_150
    [Return]  ${Mid_Server}  ${Mid_Server_usr}  ${Mid_Server_pwd}

upload_and_import_to_mantaray_via_choosen_server
    [Arguments]   ${target_sw}
             ...  ${release_NUM}
             ...  ${sw_type}=Basic
             ...  ${remote_ip}=10.41.146.248
             ...  ${remote_usr}=root
             ...  ${remote_pwd}=Nokia_150
             ...  ${copy_build_to_local}=False
             ...  ${alias}=${connection}
    log     ${release_NUM}
    ${remote_full_path}    ${local_full_path}    Download_Specify_Build_on_SpecifyHost_module_version
    ...    ${target_sw}    ${sw_type}   ${remote_ip}  22  ${remote_usr}   ${remote_pwd}  ${copy_build_to_local}
    ${sw_release_changed}    Run keyword if
    ...    '9999'in '${target_sw}'    Replace String    ${target_sw}    SBTS00    SBTS${release_NUM}
    ...    ELSE    set variable    ${target_sw}
    set test variable  ${sw_release_changed}
    ${rename_package}  set variable if
    ...   '${sw_type}'=='Basic'  ${sw_release_changed}
    ...   ${sw_release_changed}${sw_type}
    set test variable  ${rename_package}
    ${sw_fullname}   Run keyword if
    ...  '${sw_type}'=='Basic'  set variable  ${target_sw}_release_BTSSM_downloadable_A54.zip
    ...  ELSE    set variable    ${target_sw}_release_BTSSM_downloadable_testpackage_${sw_type}_A54.zip
    Sleep     5min
    ${status}    mantaray_module_netact.Is Imported    ${rename_package}      alias=${alias}
    Run keyword if   '${status}'=='False'
    ...  Run keywords    Put_buid_from_mid_to_mantaray_temp_folder
    ...  ${remote_ip}   ${remote_usr}   ${remote_pwd}  ${remote_full_path}
    ...  ${sw_fullname}  ${target_sw}    ${release_NUM}
    #...    AND  set test variable    ${sw_release}    ${target_sw}
    ...    AND      mantaray_module_netact.Import Build    build_or_file_path=${rename_package}.zip
    ...   version_id=${rename_package}     alias=${connection}
    ...    ELSE	  set test variable    ${rename_package}


Put_buid_from_mid_to_mantaray_temp_folder
    [Arguments]    ${remote_ip}   ${remote_usr}   ${remote_pwd}  ${build_path_server}
    ...   ${sw_fullname}  ${sw_release}	 ${release_NUM}
    Log    ${release_NUM}
    ${sw_release_match}  Fetch from right  ${sw_release}  S
    ${netact_connection}=      SSH to mantaray CMD      0
    mantaray_module_ssh.Execute  cd /d/oss/global/swmanager/swm_temp/      connection=${netact_connection}
    mantaray_module_ssh.Execute  pwd     connection=${netact_connection}
    #sleep  2s
    ${output}=     mantaray_module_ssh.Execute    cd/d/oss/global/swmanager/swm_temp/&&du -h *${sw_release_match}*
    ...    connection=${netact_connection}
    #${output}=  mantaray_module_ssh.Read Output    connection=${netact_connection}
    @{info}  split string  ${output}  \t
    ${size}  Fetch from left  ${info[0]}  G
    ${status_include1}  ${msg1}=  Run keyword and ignore error   Evaluate   ${size}>8
    Run keyword if  '${status_include1}' == 'FAIL'
    ...  Run Keywords
        ...  upload build between two remotes servers   ${remote_ip}   ${remote_usr}   ${remote_pwd}
        ...  ${${mantaray_name}_info.IP}      ${${mantaray_name}_info.USERNAME}    ${${mantaray_name}_info.PASSWORD}
        ...  ${build_path_server}  /d/oss/global/swmanager/swm_temp
        #...  AND     mantaray_module_ssh.Execute    cd /d/oss/global/swmanager/swm_temp/      connection=${netact_connection}
        ...  AND      Sleep     2min
        ...  AND    mantaray_module_ssh.Execute
        ...  mv /d/oss/global/swmanager/swm_temp/${sw_fullname} /d/oss/global/swmanager/swm_temp/${rename_package}.zip
        ...    connection=${netact_connection}
        ...  AND    mantaray_module_ssh.Execute       chmod 777 /d/oss/global/swmanager/swm_temp/${rename_package}.zip
        ...    connection=${netact_connection}
        ...  AND    set test variable    ${rename_package}

    Run keyword if  '${status_include1}' == 'PASS' and '${rename_package}.zip' not in '''${output}'''
    ...  mantaray_module_ssh.Execute
    ...  mv /d/oss/global/swmanager/swm_temp/${sw_fullname} /d/oss/global/swmanager/swm_temp/${rename_package}.zip
    ...  connection=${netact_connection}
    [Teardown]  Run keyword and ignore error      mantaray_module_ssh.Disconnect       connection=${netact_connection}


upload build between two remotes servers
    [Arguments]  ${serverA_ip}   ${serverA_usr}   ${serverA_pwd}   ${serverB_ip}
    ...          ${serverB_usr}   ${serverB_pwd}   ${serverA_full_path}  ${serverB_path}
    mantaray_module_ssh.Connect to     ${serverA_ip}     ${serverA_usr}    ${serverA_pwd}     alias=remote_from_server

    Log      Uploading file to Mantaray      console=true
    ${out}=      mantaray_module_ssh.Execute
    ...    sshpass -p '${serverB_pwd}' scp ${serverA_full_path} ${serverB_usr}@${serverB_ip}:${serverB_path}
    ...    connection=remote_from_server
    Log       File Uploaded       console=true
    #mantaray_module_ssh.Send Command      exit   connection=remote_from_server
    [Teardown]  mantaray_module_ssh.Disconnect       connection=remote_from_server

Get imported package name
    #Trunk version changed, the verion number for ${sw_changed} also need changed.
    ${file}    get newest file from directory    ${TARGET_SW_DIR}  *.zip
    ${SW_package}    Get regexp Matches    ${file}    SBTS([09]{0,2}).+
    ${SW_package}    Get regexp Matches    ${SW_package[0]}
    ...  SBTS[0-9]{0,2}[A-Z]?[0-9]?_ENB_([0-9]{0,4})_([0-9]{0,6})_([0-9]{0,6})
    ${SW_package}    set variable    ${SW_package[0]}
    ${sw_changed}=    Run Keyword If    '9999' in '${SW_package}'
    ...  Replace String Using Regexp    ${SW_package}    SBTS00_    ${current_release}
    ...    ELSE    Set variable    ${SW_package}
    [Return]    ${SW_package}    ${sw_changed}

Upload file to Mantaray from local
    [Arguments]    ${local_path}   ${sw_release}    ${mantaray_ip}     ${mantaray_usr}    ${mantaray_pass}

    mantaray_module_ssh.Connect to     ${mantaray_ip}      ${mantaray_usr}    ${mantaray_pass}     alias=local_to_mantaray
    mantaray_module_ssh.Upload File   ${local_path}     /d/oss/global/swmanager/swm_temp/${sw_release}.zip     connection=local_to_mantaray

    mantaray_module_ssh.Assert File Exists     /d/oss/global/swmanager/swm_temp/${sw_release}.zip     connection=local_to_mantaray

    [Teardown]       mantaray_module_ssh.Disconnect       connection=local_to_mantaray


check provided software is already imported
    [Arguments]  ${sw_release}    ${connection}
    ${sw_list}=  mantaray_module_netact.get_list_of_imported_builds       alias=${connection}
    ${Status}=   Run Keyword And Return Status     list should contain value  ${sw_list}  ${sw_release}
    [Return]     ${Status}



##################################################################################
# check operation or status part
#################################################################################

Mantaray Get Operation
    [Arguments]
    ...    ${operation}
    ...    ${bts_index}=${0}
    ...    ${cudu_index}=${0}
    ...    ${mantaray_name}=${None}
    ...    ${software_build}=${None}
    ...    ${command}=${None}
    ...    ${timeout}=${None}
    ...    &{kwargs}
    log  ${bts_index},${cudu_index},${command},${software_build},${timeout}
    Set Test Variable         ${mantaray_name}       ${mantaray_name}
    ${origin_conn}=      Set Test Variable    ${connection}      mantaray_oper
    Mantaray Precondition     ${mantaray_name}    ${connection}
    #????
    ${is_supported_operation}    Set Variable    ${None}
    ${software_path}    Set Variable    ${None}
    #?????
    ${is_supported_operation}    is_supported_operation   get        ${operation}
         #??????
    Run Keyword If
    ...     '${is_supported_operation}'=='${None}' or '${is_supported_operation}'=='${False}'
    ...    Fail    msg=Your operation no support yet. Please contact the model owner

    ${real_operation}=     find_operation    get    classical    ${operation}
    Run Keyword    ${real_operation}
        ...    ENB_ID=${ENB_ID}
        ...    mantaray_name=${mantaray_name}
        ...    connection=${connection}
        ...    timeout=${timeout}

    [Teardown]    Mantaray Postcondition     ${mantaray_name}      ${connection}

get_get_mantaray_operation
    &{handle}    Create Dictionary
    ...    get_provision_status=_get_Provison_Tiggered_Status

    [Return]    ${handle}

_get_Provison_Tiggered_Status
    [Arguments]           ${ENB_ID}     ${mantaray_name}    ${connection}    ${timeout}
	log       ${timeout}
	${output}    mantaray_module_netact.Get Mo Status    dist_names=${ENB_ID}      alias=${connection}
    log    ${output}
    ${result}    Get From Dictionary    ${output}     ${ENB_ID}
    ${last_sw_op}    Get From Dictionary    ${result}    last_sw_op
    Should Be Equal    ${last_sw_op}    SWProvision
    ${last_op_status}    Get From Dictionary    ${result}    last_op_status
    #Should Be Equal    ${last_op_status}    SUCCESS
    Return From Keyword     ${last_op_status}
    Log To Console     ${last_op_status}
	[Teardown]    Mantaray Postcondition     ${mantaray_name}      ${connection}


################################ FM operation #################################

################################ PM operation #################################
