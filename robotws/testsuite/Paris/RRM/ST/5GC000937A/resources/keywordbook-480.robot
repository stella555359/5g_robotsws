*** Settings ***

*** Variables ***
${SSH_OAM_AUTHENTICATION_TIMEOUT}       10 min
${SSH_AUTHENTICATION_RETRY_INTERVAL}    5 s
${SSH_AUTHENTICATION_TIMEOUT}           5 min

${coam_pm_file_path}   gnb_pm_counters
${path_CU_pm_files}     /mnt/services/PM9/storage/results


*** Keywords ***

replace pdn_ip in set_bearer
   [Documentation]    [PRIVATE]    replace $PDN_IP in set bearer command with ip configured in set PDN_IP command
    ...       :Autor: Sylvia Schneider
   [Arguments]   ${pdn_line}    ${set_bearer}
   ${pdn_part}    Split String       ${pdn_line}   "
   ${pdn}         set variable        ${pdn_part}[1]
   ${pdn_tmp}     Split String      ${pdn}    .
   ${pdn_ip}      set variable      ${pdn_tmp}[3]
   ${set_bearer}  replace string   ${set_bearer}   $PDN_IP    ${pdn}
   [Return]     ${set_bearer}


Get testline specific data
    [Documentation]    [PRIVATE]    get specific data for testline: bts_type, gnb_sw_version, oam_type, ue_type, eNB data
    ...       :Autor: Sylvia Schneider
    Check TL Infos
    # range: cloud, classical    -- info from init: CloudBts, ClassicalBts
    ${bts_type}    Get from dictionary          ${P_GNBTYPE}    gnb_0
    set suite variable    ${bts_type}
    log to console    \nbts_type contains "${bts_type}"

    #range: coam, cloud_coam
    ${oam_type}    Get from dictionary          ${P_OAMTYPE}    gnb_0
    set suite variable    ${oam_type}
    log to console    \noam_type contains "${oam_type}"

    #sw version from DU
    Run Keyword If   '${oam_type}' == 'cloud_coam'    Fetch cloud COAM SW version of all DUs
    Run Keyword If   '${oam_type}' == 'cloud_coam'    show DU sw version
    ...         ELSE                                  show classical sw version

    #sw version from CU
    Run Keyword If         '${oam_type}' == 'cloud_coam'       Get and display sw version from CU

    #range: viavi, qualcomm, airphone   -- info from init: TM500, Android, Airphone
    ${ue_type}    Get from dictionary          ${P_UETYPE}    ue_0
    set suite variable    ${ue_type}
    log to console    \nue_type contains "${ue_type}"

    #param realEnb set - range: true, false
    Get eNB data

Get and display sw version from CU
    [Documentation]    [PRIVATE]     get sw version of cloud gnb CU and display
    ...     :Autor: Sylvia Schneider
    Fetch cloud COAM SW version of CU
    ${cu_swVersion}    Get from dictionary          ${P_GNBSWVERSION}    gnb_0_cu
    set suite variable    ${cu_swVersion}
    log to console    \ncu sw version is "${cu_swVersion}"


show classical sw version
    [Documentation]    [PRIVATE]     show sw version of classical gnb and set suite variable
    ...     :Autor: Sylvia Schneider
    ...     :param ${nb_id}:      gnb instance in init file
    [Arguments]    ${gnb_id}=0
    ${gnb_swVersion}    Get from dictionary    ${P_GNBSWVERSION}    gnb_0
    set suite variable    ${gnb_swVersion}
    log to console    \ngnb_swVersion contains "${gnb_swVersion}"


show DU sw version
    [Documentation]    [PRIVATE]     show sw version of all cloud coam DU and set suite variable
    ...     :Autor: Sylvia Schneider
    ...     :param ${gnb_id}:      gnb instance in init file
    [Arguments]    ${gnb_id}=0

    ${du_num}=    Get length    ${tl.gnbs[${gnb_id}].dus}
    FOR    ${du_id}    IN RANGE    ${du_num}
       ${swversion}   Get from dictionary    ${P_GNBSWVERSION}    gnb_${gnb_id}_du_${du_id}
       set suite variable    ${gnb_swVersion_du${du_id}}    ${swversion}
       log to console    \ngnb_swVersion DU-${du_id} contains "${gnb_swVersion_du${du_id}}"
    END

get nrbts distname from SCF
    [Documentation]    [PRIVATE]     extract nrbts distname from SCF
    ...     :Autor: Sylvia Schneider
    ...     :param ${scf_file}: SCF file with path
    ...     :param ${unit}:  used only for cloud coam gnb - CU or DU
    ...     :param ${du_id}: used only for cloud coam DU - DU instance
    [Arguments]    ${scf_file}     ${unit}=${EMPTY}      ${du_id}=${EMPTY}

    ${parsed_SCF}    parse xml     ${scf_file}
    ${xpath}         get from dictionary    ${xpath_vars_SCF}    distName_NRBTS
    ${nrbts_dist}    get element attribute    ${parsed_SCF}    distName    xpath=${xpath}

    Run Keyword If        '${oam_type}' == 'cloud_coam' and '${unit}' == 'CU'   set suite variable   ${CU_bts_distName}   ${nrbts_dist}
    ...         ELSE IF   '${oam_type}' == 'cloud_coam' and '${unit}' == 'DU'   set suite variable   ${DU${du_id}_bts_distName}   ${nrbts_dist}
    ...         ELSE                                                            set suite variable   ${bts_distName}      ${nrbts_dist}
    log to console    \n${unit} bts_distName: "${nrbts_dist}"

get pmcadm distname from SCF
    [Documentation]    [PRIVATE]     extract pmcadm distname from SCF
    ...     :Autor: Sylvia Schneider
    ...     :param ${scf_file}: SCF file with path
    ...     :param ${unit}: used only for cloud coam gnb - CU or DU
    ...     :param ${du_id}: used only for cloud coam DU - DU instance
    [Arguments]    ${scf_file}     ${unit}=${EMPTY}     ${du_id}=${EMPTY}
    ${parsed_SCF}    parse xml     ${scf_file}
    ${xpath}         get from dictionary    ${xpath_vars_SCF}    distName_PMCADM
    ${pmcadm_dist}    get element attribute    ${parsed_SCF}    distName    xpath=${xpath}
    Run Keyword If        '${oam_type}' == 'cloud_coam' and '${unit}' == 'CU'   set suite variable   ${CU_pmcadm_distName}    ${pmcadm_dist}
    ...         ELSE IF   '${oam_type}' == 'cloud_coam' and '${unit}' == 'DU'   set suite variable   ${DU${du_id}_pmcadm_distName}    ${pmcadm_dist}
    ...         ELSE                                                            set suite variable   ${pmcadm_distName}    ${pmcadm_dist}
    log to console    \n${unit}${du_id} pmcadm_distName: "${pmcadm_dist}"

set distname for commissioning
    [Documentation]    [PRIVATE]     prepare correct from of distname for commissioning
    ...     :Autor: Sylvia Schneider
    ...     :param ${dist_in}: distname as stated in SCF
    ...     :return ${dist_in} if coam, otherwise ${dist_in_short} in which 1st is removed
    [Arguments]    ${dist_in}
    Return From Keyword If   '${oam_type}'=='coam'    ${dist_in}
    ${part}    Split String   ${dist_in}    /
    ${dist_in_short}   Remove String    ${dist_in}   ${part}[0]/
    [Return]   ${dist_in_short}

Get and display eNB SW version string
    [Documentation]    [PRIVATE]     get sw version from real eNB
    ...     :Autor: Sylvia Schneider
    ${enb_sw}    Get eNB SW Version
    BuiltIn.Log To Console     \neNB sw version: ${enb_sw}

Get eNB data
    [Documentation]    [PRIVATE]
    ...     :Autor: Sylvia Schneider
    ...     check if real or simulated eNB
    ...     suite variable  ${realEnb} returns true or false
    ${status}    run keyword and return status    variable should exist     ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
    ${realEnb}   Set Variable If   '${status}' == 'True'     true     false
    set suite variable    ${realEnb}

Get eNB IP
    [Documentation]    [PRIVATE]
    ...     :Autor: Sylvia Schneider
    ...     get enb ip address
    ...         if real eNB, take address from __init__.py
    ...         if WTS simulated eNB, find ENB1_X2_ADDR in wts config file set in __init__.py
    ...     siute variable  ${enb_ip} returns the ip address
    Run Keyword If     '${realEnb}' == 'true'    get_enb_data_from_real_eNB
    ...         ELSE                             get_enb_data_from_simulated_eNB

get_enb_data_from_real_eNB
    [Documentation]    [PRIVATE]
    ...     :Autor: Sylvia Schneider
    set suite variable    ${enb_ip}     ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
    log to console    \nrealEnb available, enb_ip: ${enb_ip}
    Get and display eNB SW version string

get_enb_data_from_simulated_eNB
    [Documentation]    [PRIVATE]
    ...     :Autor: Sylvia Schneider
    ${file}     Get File     ${tl.core.dir_path}/${tl.core.cfg_filename}
    ${matched_line}    Get Lines Containing String     ${file}    ENB1_X2_ADDR="
    ${tmp}    split string     ${matched_line}     "
    set suite variable     ${enb_ip}     ${tmp}[1]
    log to console    \nno realEnb available, simulated enb_ip: ${enb_ip}


get scf coam
    [Documentation]    [PRIVATE]     get config scf from classical gNB
    ...     :Autor: Sylvia Schneider
    ...     :param ${dir}: directory where the file is stored
    ...     :param ${scf}: name of stored scf file
    [Arguments]    ${dir}=${resultDir}    ${scf}=SCFC.xml
    BuiltIn.log to console     \nstarting coam_get_scf ${tl.gnbs[0].cu.oam_http_connection_details.addr}
    BuiltIn.log to console     \n saving file to ${dir}/${scf}
    admin.connect_to
    ...    bts_host=${tl.gnbs[0].cu.oam_http_connection_details.addr}
    ...    name=gnb
    BuiltIn.Log To Console     \nget scf started
    ${path_SCF}     admin.get current scf file
    ...    ${dir}
    ...    ${scf}
    ...    timeout=10
    ...    connection=gnb
    BuiltIn.Log To Console     \nget scf finished
    [Teardown]        admin.teardown    connection=gnb


get scf cloud_coam
    [Documentation]    [PRIVATE]    get config scf of CU and DU from cloud gNB coam
    ...     :Autor: Sylvia Schneider
    ...     :name of uploaded CU SCF:    CU_${scf}
    ...     :name of uploaded DU SCF:    DU<du_id>_${scf}
    ...     :param ${dir}: directory where the file is stored
    ...     :param ${scf}: name of stored scf file
    [Arguments]    ${dir}=${resultDir}    ${scf}=SCFC.xml
    upload cloud coam SCF CU       ${dir}    ${scf}
    upload cloud coam all SCF DU   ${dir}    ${scf}


upload cloud coam all SCF DU
    [Documentation]    [PRIVATE]    get config of all DU from cloud gNB coam
    ...     :Autor: Sylvia Schneider
    ...     :name of uploaded DU SCF:    DU<du_id>_${scf}
    ...     :param ${dir}: directory where the file is stored
    ...     :param ${scf}: name of stored scf file
    ...     :param ${gnb_id}: gnb instance in init file
    [Arguments]     ${dir}    ${scf}    ${gnb_id}=0
    ${du_num}=    Get length    ${tl.gnbs[${gnb_id}].dus}
    FOR    ${du_id}    IN RANGE    ${du_num}
        upload cloud coam SCF DU  ${dir}    ${scf}   gnb_id=${gnb_id}  du_id=${du_id}
    END


upload cloud coam SCF DU
    [Documentation]    [PRIVATE]    get config of all DU from cloud gNB coam
    ...     :Autor: Sylvia Schneider
    ...     :name of uploaded DU SCF:    DU<du_id>_${scf}
    ...     :param ${dir}: directory where the file is stored
    ...     :param ${scf}: name of stored scf file
    ...     :param ${gnb_id}: gnb instance in init file
    ...     :param ${du_id}: du instance
    [Arguments]     ${dir}    ${scf}    ${gnb_id}      ${du_id}
    BuiltIn.log to console     \nstarting coam_get_scf for DU${du_id}
    BuiltIn.log to console     \n saving file to ${dir}/DU${du_id}_${scf}
    ${alias_du}    connect oam DU   gnb_id=${gnb_id}   du_id=${du_id}
    BuiltIn.Log To Console     \nget DU ${du_id} scf started
    ${path_SCF}     admin.get current scf file
    ...    ${dir}
    ...    DU${du_id}_${scf}
    ...    timeout=10
    ...    connection=${alias_du}
    BuiltIn.Log To Console     \nget DU ${du_id} scf finished
    [Teardown]        disconnect oam DU    alias_du=${alias_du}


upload cloud coam SCF CU
    [Documentation]    [PRIVATE]    upload SCF from cloud gNB coam CU
    ...     :Autor: Sylvia Schneider
    ...     :name of uploaded CU SCF:    CU_${scf}
    ...     :param ${dir}: directory where the file is stored
    ...     :param ${scf}: name of stored scf file
    [Arguments]     ${dir}    ${scf}    ${gnb_id}=0
    BuiltIn.log to console     \nstarting coam_get_scf for CU ${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.addr}
    BuiltIn.log to console     \n saving file to ${dir}/CU_${scf}
    ${oam_alias}   connect.Setup OAM session    gnb_id=${gnb_id}    component=CU
    BuiltIn.Log To Console     \nget CU scf started
    coam_cu.get_current_plan_file    path=${dir}/CU_${scf}    timeout=180     connection=${oam_alias}
    BuiltIn.Log To Console     \nget CU scf finished
    [Teardown]     Teardown OAM session    component=CU    connection=${oam_alias}


json delta commissioning
    [Documentation]    [PRIVATE] will be removed after all TCs are updated
    ...     :Autor: Sylvia Schneider
    [Arguments]     ${param_list}
    json delta commissioning coam         ${param_list}


json delta commissioning coam
    [Documentation]    [PRIVATE]   delta commissioning coam
    ...     :Autor: Sylvia Schneider
    ...     :param ${param_list}: list of dictionaries containing parameters and values, which are updated
    [Arguments]     ${param_list}
    admin.connect_to
    ...    bts_host=${tl.gnbs[0].cu.oam_http_connection_details.addr}
    ...    name=gnb
    BuiltIn.Log To Console    \ndelta commissioning started
    ${update_status}    ${delta_store_file}    Update List of SCF parameters
    ...    parameters=${param_list}
    ...    timeout=600
    ...    alias=gnb
    admin.teardown    connection=gnb
    BuiltIn.Log To Console    \ndelta commissioning finished
    synchronize gnb radio
    Wait until coam gNB to be onair state and cells enabled

connect oam DU
    [Documentation]    [PRIVATE]    connect to DU oam
    ...     :Autor: Sylvia Schneider
    ...     :param ${gnb_id}=0: du instance id
    ...     :param ${du_id}: du instance id
    ...     :return: alias name for connection
    [Arguments]     ${gnb_id}=0    ${du_id}=0
    ${DU_ip}    gnb_lib.Get Gnb Du Host Ip    ${tl.gnbs[${gnb_id}].dus[${du_id}]}
    admin.connect_to
    ...    bts_host=${DU_ip}
    ...    name=oam_gnb${gnb_id}_du${du_id}
    [Return]    oam_gnb${gnb_id}_du${du_id}

disconnect oam DU
    [Arguments]     ${alias_du}
    admin.teardown    connection=${alias_du}

json delta commissioning coam DU
    [Documentation]    [PRIVATE]    delta commissioning on DU with instance ${du_id}
    ...     :Autor: Sylvia Schneider
    ...     :param ${param_list_DU}: list containing dictionaries for parameters to be changed
    ...     :param ${du_id}: du instance id
    ...     :param ${gnb_id}: gNB instance id
    [Arguments]     ${param_list_DU}    ${du_id}=0    ${gnb_id}=0
    BuiltIn.Log To Console    \ndelta commissioning on gnb-${gnb_id} DU-${du_id} started
    ${alias_du}    connect oam DU   gnb_id=${gnb_id}   du_id=${du_id}
    ${update_status}    ${delta_store_file}    Update List of SCF parameters
    ...    parameters=${param_list_DU}
    ...    timeout=600
    ...    alias=${alias_du}
    disconnect oam DU    alias_du=${alias_du}
    BuiltIn.Log To Console    \ndelta commissioning on gnb-${gnb_id} DU-${du_id} finished


Generating Delta Plan Operation Should Be Successful
    [Arguments]   ${action_id}   ${gnb_id}=0
    ${oam_alias}   connect.Setup OAM session    gnb_id=${gnb_id}    component=CU
    ${res}   coam_cu.get_action_state_of_generating_delta_plan   action_id=${action_id}    connection=${oam_alias}
    should be equal as strings  ${res['status']}  success
    [Teardown]     Teardown OAM session    component=CU    connection=${oam_alias}


create plan for delta commissioning
    [Documentation]    [PRIVATE]    create a delta plan for delta commissioning CU
    ...     :Autor: Sylvia Schneider
    ...     :param ${delta_plan_name}: name of delta plan
    ...     :param ${gnb_id}: gNB instance id
    [Arguments]     ${delta_plan_name}    ${gnb_id}=0
    ${oam_alias}   connect.Setup OAM session    gnb_id=${gnb_id}    component=CU
    BuiltIn.Log To Console    \ncreation of delta plan for CU commissioning with name ${delta_plan_name}
    ${delta_plan_list}     coam_cu.get_delta_plan_list    connection=${oam_alias}
    Run Keyword If  ${delta_plan_list}  coam_cu.delete_delta_plan  plan_id=${delta_plan_list[0]['plan_id']}    connection=${oam_alias}
    ${dict_plan}   coam_cu.generate_delta_plan
    ...    plan_name=${delta_plan_name}
    ...    connection=${oam_alias}
    set test variable  ${delta_plan_id}    ${dict_plan['plan_id']}
    Teardown OAM session    component=CU    connection=${oam_alias}
    Wait until keyword succeeds  3x  2s
    ...  Generating Delta Plan Operation Should Be Successful    ${dict_plan['action_id']}


save delta plan
    [Documentation]    [PRIVATE]    save a delta plan for delta commissioning CU
    ...     :Autor: Sylvia Schneider
    ...     :param ${deltaPlanName}: name of delta plan
    ...     :param ${gnb_id}: gNB instance id
    [Arguments]     ${delta_plan_name}     ${gnb_id}=0
    BuiltIn.Log To Console    \nsaving delta plan started
    ${oam_alias}   connect.Setup OAM session    gnb_id=${gnb_id}    component=CU
    coam_cu.save_delta_plan_file      plan_id=${delta_plan_id}     path=${resultBaseDir}/${delta_plan_name}   connection=${oam_alias}
    BuiltIn.Log To Console    \nsaving delta plan finished: ${resultBaseDir}/${delta_plan_name}
    [Teardown]       Teardown OAM session    component=CU    connection=${oam_alias}

check if param up to date
    [Documentation]    [PRIVATE]    verify for delta commissioning CU, if a paramter is already set correctly in CU SCF
    ...     :Autor: Sylvia Schneider
    ...     :param ${obj}: distname where the parameter is located
    ...     :param ${param}: parameter name
    ...     :param ${value}: value of the parameter
    [Arguments]   ${obj}  ${param}   ${value}
    ${xpath_param}    set variable    .//managedObject[@distName="${obj}"]/p[@name="${param}"]
    ${act_value}    get element text    ${parsed_SCF}    xpath=${xpath_param}
    ${action}   set variable if     '${act_value}'=='${value}'   valuePresent     valueNeedsSetting
    [Return]    ${action}



check if param already up to date
    [Documentation]    [PRIVATE]    verify for delta commissioning CU, if a paramter is already set correctly in CU SCF
    ... will be removed in next releases
    ...     :Autor: Sylvia Schneider
    ...     :param ${value}: name of delta plan
    ...     :param ${gnb_id}: gNB instance id
    [Arguments]    ${param}       ${value}     ${gnb_id}=0
    ${oam_alias}   connect.Setup OAM session    gnb_id=${gnb_id}    component=CU
    &{found}    coam_cu.search_parameters_of_current_plan     parameter_name=${param}
    ${total}    Get from dictionary    ${found}        total
    Run Keyword If      '${total}'=='0'    Fail    Parameter ${param} not found in current plan
    @{act_value}     Get from dictionary    ${found}    items
    ${temp}          set variable     ${act_value}[0]
    ${act_value1}    Get from dictionary    ${temp}    parameter
    ${act_value2}    Get from dictionary    ${act_value1}    simple_parameter
    ${act_value3}    Get from dictionary    ${act_value2}    value
    ${action}       set variable if     '${act_value3}'=='${value}'   valuePresent     valueNeedsSetting
    Teardown OAM session    component=CU    connection=${oam_alias}
    [Return]    ${action}


Update Parameters Operation Should Be Successful
    [Arguments]   ${plan_id}  ${action_id}   ${gnb_id}=0
    ${oam_alias}   connect.Setup OAM session    gnb_id=${gnb_id}    component=CU
    ${res}   coam_cu.get_action_state_of_updating_parameters_of_delta_plan  plan_id=${plan_id}  action_id=${action_id}    connection=${oam_alias}
    should be equal as strings  ${res['status']}  success
    [Teardown]      Teardown OAM session    component=CU    connection=${oam_alias}


Get CU Specifical MO UUID
    [Arguments]   ${plan_id}  ${mo_dn}
    @{name_list}=   split_string    ${mo_dn}   /
    set test variable  ${parent_mouuid}    ${EMPTY}
    FOR  ${name}  IN  @{name_list}
        ${mouuid}   Get CU Specifical MO UUID via DN Name   ${plan_id}  ${name}
    END
    [Return]   ${mouuid}


Get CU Specifical MO UUID via DN Name
    [Arguments]   ${plan_id}  ${name}   ${gnb_id}=0
    ${oam_alias}   connect.Setup OAM session    gnb_id=${gnb_id}    component=CU
    &{delta_plan_tree}   coam_cu.get_delta_plan_tree_diff   plan_id=${plan_id}   connection=${oam_alias}
    Teardown OAM session    component=CU    connection=${oam_alias}
    @{plan_tree}        set variable  ${delta_plan_tree["created"]}
    FOR  ${mo_info}  IN  @{plan_tree}
       run keyword if  '${mo_info["parent_mo_uuid"]}'=='${parent_mouuid}' and '${mo_info["name"]}'=='${name}'  run keywords
       ...  set test variable  ${parent_mouuid}  ${mo_info["mo_uuid"]}  AND  exit for loop
    END
    [Return]   ${parent_mouuid}


json delta commissioning coam CU
    [Documentation]    [PRIVATE]   delta commissioning cloud coam CU - update delta plan
    ...     :Autor: Sylvia Schneider
    ...     :param ${mo}: name of delta plan for delta commissioning CU
    ...     :param ${param_list_CU}: list containing dictionary of paramters to be changed
    ...     :param ${gnb_id}: gNB instance id
    [Arguments]     ${mo}     ${param_list_CU}     ${gnb_id}=0

    BuiltIn.Log To Console    \nupdating CU parameter in delta plan
    ${uuid}   Get CU Specifical MO UUID   plan_id=${delta_plan_id}    mo_dn=${mo}
    ${oam_alias}   connect.Setup OAM session    gnb_id=${gnb_id}    component=CU
    ${dict_para_change}=  coam_cu.update_parameters_of_delta_plan   plan_id=${delta_plan_id}  mo_uuid=${uuid}
    ...   parameter_change_list=${param_list_CU}
    ...   connection=${oam_alias}
    Teardown OAM session    component=CU    connection=${oam_alias}
    Wait until keyword succeeds  5x  5s
    ...  Update Parameters Operation Should Be Successful    plan_id=${delta_plan_id}  action_id=${dict_para_change['action_id']}

msg set
    [Documentation]    [PRIVATE]    show that parameter was updated in CU plan file
    ...     :Autor: Sylvia Schneider
    BuiltIn.Log To Console    -- set in delta plan file

msg not set
    [Documentation]    [PRIVATE]    show that parameter was not updated in CU plan file - error occured
    ...     :Autor: Sylvia Schneider
    Fail   -- not set in delta plan file, error occured


Validating Delta Plan Operation Should Be Successful
    [Arguments]  ${plan_id}  ${action_id}   ${gnb_id}=0
    ${oam_alias}   connect.Setup OAM session    gnb_id=${gnb_id}    component=CU
    ${res}     coam_cu.get_action_state_of_validating_delta_plan   ${plan_id}  ${action_id}   connection=${oam_alias}
    should be equal as strings  ${res['status']}  success
    [Teardown]      Teardown OAM session    component=CU    connection=${oam_alias}


Activating Delta Plan Operation Should Be Successful
    [Arguments]  ${plan_id}  ${operation_id}   ${gnb_id}=0
    ${oam_alias}   connect.Setup OAM session    gnb_id=${gnb_id}    component=CU
    ${res}   coam_cu.get_operation_state_of_activating_delta_plan   ${plan_id}  ${operation_id}   connection=${oam_alias}
    should be equal as strings  ${res['status']}  success
    [Teardown]        Teardown OAM session    component=CU    connection=${oam_alias}


validate and activate plan for delta commissioning
    [Documentation]    [PRIVATE]   delta commissioning cloud coam CU - validate and activate delta plan
    ...     :Autor: Sylvia Schneider
    ...     :param ${gnb_id}: gNB instance id
    [Arguments]     ${gnb_id}=0
    BuiltIn.Log To Console    \nvalidation of delta plan
    ${oam_alias}   connect.Setup OAM session    gnb_id=${gnb_id}    component=CU
    ${dict_validate}=   coam_cu.validate_delta_plan   plan_id=${delta_plan_id}   connection=${oam_alias}
    Teardown OAM session    component=CU    connection=${oam_alias}
    Wait until keyword succeeds  5x  5s
    ...  Validating Delta Plan Operation Should Be Successful    plan_id=${delta_plan_id}  action_id=${dict_validate['action_id']}
    BuiltIn.Log To Console    \nactivation of delta plan
    ${oam_alias}   connect.Setup OAM session    gnb_id=${gnb_id}    component=CU
    ${dict_active}=   coam_cu.activate_delta_plan   plan_id=${delta_plan_id}   connection=${oam_alias}
    Teardown OAM session    component=CU    connection=${oam_alias}
    Wait until keyword succeeds  3x  30s
    ...  Activating Delta Plan Operation Should Be Successful   plan_id=${delta_plan_id}   operation_id=${dict_active['operation_id']}


Get OAM time
    BuiltIn.Wait Until Keyword Succeeds    ${SSH_AUTHENTICATION_TIMEOUT}    ${SSH_AUTHENTICATION_RETRY_INTERVAL}
    ...    ssh.connect to    ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    ...                      ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
    ...                      ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
    ...                      alias=OAM-local-conn
    ${OAM_time} =    ssh.execute    date "+%F %T"    connection=OAM-local-conn
    ${OAM_time}    get line    ${OAM_time}    0
    [Return]    ${OAM_time}

wait for next measurement interval
    [Arguments]    ${additional-waiting-time}=70s
    @{act_time}    Get Time    hour min sec
    ${min}    set variable    ${act_time[1]}
    ${minute}    convert to integer    ${min}
    ${int}    Evaluate    int(${minute}/${measurement_period_in_min})
    ${CSV-creation-interval-begin}    Evaluate    int(${minute}/${measurement_period_in_min}) * ${measurement_period_in_min}
    ${waiting-time}    Evaluate    ${CSV-creation-interval-begin}+${measurement_period_in_min}-${minute}
    Sleep    ${waiting-time} minutes
    Sleep    ${additional-waiting-time}

Collect PM Counters
    [Documentation]    [PRIVATE]   collect pm counter files
    ...     :Autor: Sylvia Schneider
    [Arguments]    ${time_before_detach}=${EMPTY}
    Run Keyword If    '${oam_type}' == 'coam'             Collect PM Counters file and filter last file coam
    ...         ELSE                                      Collect PM Counters file CU DU


Collect PM Counters file and filter last file coam
    [Documentation]    [PRIVATE]   collect pm counter files for coam classical gnb
    ...     :Autor: Sylvia Schneider
    Collect PM Counters file coam
    Filter last PM Counters file coam

Collect PM Counters file CU DU
    [Documentation]    [PRIVATE]   collect pm counter files for coam cloud gnb
    ...     :Autor: Sylvia Schneider
   Collect pm counter file CU
   Collect pm counter file for all DU


Collect pm counter file for all DU
    [Documentation]    [PRIVATE]   collect pm counter files for coam cloud gnb for all DUs
    ...     :Autor: Sylvia Schneider
    ...     :param ${gnb_id}: gNB instance id
    [Arguments]    ${gnb_id}=0
    ${du_num}=    Get length    ${tl.gnbs[${gnb_id}].dus}
    FOR    ${du_id}    IN RANGE    ${du_num}
        Create Directory    ${resultDir}/counter_DU${du_id}
        Collect pm counter file DU      ${du_id}
    END

Collect pm counter file DU
    [Documentation]    [PRIVATE]   collect pm counter files for coam cloud gnb for single DU
    ...     :Autor: Sylvia Schneider
    ...     :param ${du_id}: DU instance id
    [Arguments]    ${du_id}=0    ${gnb_id}=0

    BuiltIn.Log To Console    \nuploading pm file from coam DU ${du_id} and store in directory ${resultDir}/counter_DU${du_id}
    Create Directory    ${resultDir}/counter_DU${du_id}
    ${DU_ip}    gnb_lib.Get Gnb Du Host Ip    ${tl.gnbs[${gnb_id}].dus[${du_id}]}
    ${webservice}    Create Dictionary
    ...            host=${DU_ip}
    ...            user=Nemuadmin
    ...            password=nemuuser
    ...            port=443

    tafpmcounters.create pm collector
    ...    name=gnb_pm_counters
    ...    webservice=${webservice}
    ...    oam_type=coam
    tafpmcounters.setup collectors
    ...    names=gnb_pm_counters
    tafpmcounters.collect collectors
    ...    names=gnb_pm_counters
    ...    target_dir=${resultDir}/counter_DU${du_id}
    tafpmcounters.teardown collectors
    ...    names=gnb_pm_counters


Collect pm counter file CU
    [Documentation]    [PRIVATE]   collect pm counter files for coam cloud gnb for CU
    ...     :Autor: Sylvia Schneider
    BuiltIn.Log To Console    \nuploading pm file from coam CU and store in directory ${resultDir}/counter_CU
    Create Directory    ${resultDir}/counter_CU
    BuiltIn.Wait Until Keyword Succeeds    30    5
    ...    ssh.connect to    ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    ...                      ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
    ...                      ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
    ...                      alias=OAM-local-conn
    ssh.execute  ls -r ${path_CU_pm_files} > /tmp/dir_allPmFileCu.txt  connection=OAM-local-conn
    ssh.Download File    /tmp/dir_allPmFileCu.txt   ${resultDir}/counter_CU/dir_allPmFileCu.txt      connection=OAM-local-conn
    ${pm_file_list}    Get File     ${resultDir}/counter_CU/dir_allPmFileCu.txt
    ${last_pm_file_name}   Get Line     ${pm_file_list}     2
    ${last_pm_file_dateTime}   Get Regexp Matches    ${last_pm_file_name}     -(\\d{8}\\.\\d{4})+
    ssh.execute    cd ${path_CU_pm_files}; tar cvf /tmp/cu_pm.tar -C ${path_CU_pm_files}/ *${last_pm_file_dateTime}[0]*   connection=OAM-local-conn
    ssh.Download File    /tmp/cu_pm.tar   ${resultDir}/counter_CU/cu_pm.tar      connection=OAM-local-conn
    ${rc}    Run And Return Rc    cd ${resultDir}/counter_CU; tar xvf cu_pm.tar
    ${result}    set variable if    '${rc}'=='${0}'    pass    fail
    run keyword if     '${result}'=='fail'    Fail    ERROR - counter CU PM file
    ${local_pm_gz_files}    List Files In Directory    ${resultDir}/counter_CU     *.gz
    FOR    ${file}   IN    @{local_pm_gz_files}
         Run    gunzip ${resultDir}/counter_CU/${file}
    END
    [Teardown]    BuiltIn.Run Keyword And Ignore Error    ssh.disconnect    connection=OAM-local-conn


Filter PM Counters file coam CU ${meas_type}
    [Documentation]    [PRIVATE]   filter last pm counter files for coam cloud gnb for CU
    ...     :Autor: Sylvia Schneider
    ${local_pm_xml_files}    List Files In Directory    ${resultDir}/counter_CU     *.xml
    ${result}    set Variable       ${EMPTY}
    FOR    ${file}   IN    @{local_pm_xml_files}
       ${result}       OperatingSystem.Grep File     ${resultDir}/counter_CU/${file}     ${meas_type}
       ${length_result}        Get Length        ${result}
       Continue For Loop If         ${length_result}==0
       Set Test Variable     ${pmCounter_xml_file_CU_${meas_type}}     ${resultDir}/counter_CU/${file}
       Exit For Loop
    END
    Variable Should Exist   ${pmCounter_xml_file_CU_${meas_type}}     ERROR - no counter CU ${meas_type} PM file
    BuiltIn.Log To Console    \nCU counter ${meas_type} pm file: ${pmCounter_xml_file_CU_${meas_type}}



Collect PM Counters file coam
    [Documentation]    [PRIVATE]   collect pm counter files for coam classical gnb
    ...     :Autor: Sylvia Schneider
    BuiltIn.Log To Console    \nuploading pm file from coam
    ${webservice}    Create Dictionary
    ...            host=${tl.gnbs[0].cu.oam_http_connection_details.addr}
    ...            user=${tl.gnbs[0].cu.oam_http_connection_details.username}
    ...            password=${tl.gnbs[0].cu.oam_http_connection_details.password}
    ...            port=443

    tafpmcounters.create pm collector
    ...    name=gnb_pm_counters
    ...    webservice=${webservice}
    ...    oam_type=coam
    tafpmcounters.setup collectors
    ...    names=gnb_pm_counters
    tafpmcounters.collect collectors
    ...    names=gnb_pm_counters
    ...    target_dir=${resultDir}
    tafpmcounters.teardown collectors
    ...    names=gnb_pm_counters


Filter last PM Counters file coam
    [Documentation]    [PRIVATE]   filter last pm counter files for coam classical gnb
    ...     :Autor: Sylvia Schneider
    ${rc}    ${all_pm_file}    Run And Return Rc And Output    ls -r ${resultDir}/${coam_pm_file_path}/ | grep PM.*ANY.xml
    ${result}    set variable if    '${rc}'=='${0}'    pass    fail
    run keyword if     '${result}'=='fail'    Fail    no measurement file available
    ${temp}    split to lines    ${all_pm_file}
    ${pm_file_name}    set variable    ${temp[0]}
    ${pm_file_name_with_path}    set variable    ${resultDir}/${coam_pm_file_path}/${pm_file_name}

    Move File    ${pm_file_name_with_path}    ${resultDir}/
    Empty Directory    ${resultDir}/${coam_pm_file_path}
    Move File    ${resultDir}/${pm_file_name}   ${resultDir}/${coam_pm_file_path}/

    ${file_string}   Get Binary File   ${pm_file_name_with_path}
    ${file_string}  Replace String    ${file_string}  ><  >\n<   count=-1
    Create File    ${resultDir}/pm.xml    ${file_string}

    BuiltIn.Set Test Variable    ${pmCounter_xml_file}    ${resultDir}/pm.xml
    [Return]     ${pmCounter_xml_file}


Filter last PM Counters file coam DU
    [Documentation]    [PRIVATE]   filter last pm counter files for coam cloud gnb for DU
    ...     :Autor: Sylvia Schneider
    ...     :param ${du_id}: DU instance id
    [Arguments]    ${du_id}=0
    ${rc}    ${all_pm_file}    Run And Return Rc And Output    ls -r ${resultDir}/counter_DU${du_id}/gnb_pm_counters/ | grep PM.*ANY.xml
    ${result}    set variable if    '${rc}'=='${0}'    pass    fail
    run keyword if     '${result}'=='fail'    Fail    no measurement file available on DU ${du_id}
    ${temp}    split to lines    ${all_pm_file}
    ${pm_file_name}    set variable    ${temp[0]}
    ${pm_file_name_with_path}    set variable    ${resultDir}/counter_DU${du_id}/gnb_pm_counters/${pm_file_name}

    Move File    ${pm_file_name_with_path}    ${resultDir}/
    Empty Directory    ${resultDir}/counter_DU${du_id}/gnb_pm_counters
    Move File    ${resultDir}/${pm_file_name}   ${resultDir}/counter_DU${du_id}/gnb_pm_counters/

    ${file_string}   Get Binary File   ${pm_file_name_with_path}
    ${file_string}  Replace String    ${file_string}  ><  >\n<   count=-1
    Create File    ${resultDir}/pm${du_id}.xml    ${file_string}

    BuiltIn.Set Test Variable    ${pmCounter_xml_file}    ${resultDir}/pm${du_id}.xml


Verify Counter
    [Documentation]    [PRIVATE]   verify counter expected value and value from pm file
    ...     :Autor: Sylvia Schneider
    ...     :param ${counterName}: name of counter e.g M55114C00001
    ...     :param ${counterList}: list containing details of counter
    ...     :param ${parsed_PmFile}: pm file in which counter is searched for
    ...     :param ${unit}: empty if classical gnb, CU if cloud coam CU, DU if cloud coam DU
    ...     :param ${du_id}: DU instance id
    [Arguments]    ${counterName}    ${counterList}    ${parsed_PmFile}      ${unit}=${EMPTY}      ${du_id}=0
    ${counter_text}    Set Variable    ${counterList}[0]
    ${counter_expectedValue}    Set Variable    ${counterList}[1]
    ${counter_cell}    Set Variable    ${counterList}[2]
    ${counter_meastype}    Set Variable    ${counterList}[3]
    ${counter_distName}
    ...    Run Keyword If   '${oam_type}' == 'cloud_coam' and '${unit}' == 'CU'   Set Variable   PLMN-PLMN/${CU_bts_distName}/${counter_cell}
    ...    ELSE IF   '${oam_type}' == 'cloud_coam' and '${unit}' == 'DU'   Set Variable    PLMN-PLMN/${DU${du_id}_bts_distName}/${counter_cell}
    ...    ELSE                                                            Set Variable    PLMN-PLMN/${bts_distName}/${counter_cell}

    ${xpath_param}    get from dictionary    ${xpath_vars_pmCounter}    counter_pmFile_${oam_type}${unit}
    ${xpath_param}    replace variables    ${xpath_param}
    ${counter_value_from_pm_xml}    get element text     ${parsed_PmFile}        xpath=${xpath_param}
    ${result}       Set Variable If    ${counter_value_from_pm_xml}==${counter_expectedValue}    Passed    Failed
    ${msg1}         Set Variable      \ncounter ${counterName} "${counter_text}" for cell ${counter_cell}
    ${msg2}         Set Variable      pm file value ${counter_value_from_pm_xml} == expectedValue ${counter_expectedValue}\n
    Run Keyword If    '${result}'=='Passed'    BuiltIn.Log to console    ${msg1} passed: ${msg2}
    Run Keyword If    '${result}'=='Failed'    Run Keyword And Continue On Failure    Fail    ${msg1} failed: ${msg2}
    report pm counter
    ...   id=${counterName}
    ...   value=${counter_value_from_pm_xml}
    ...   result=${result}


Attach UE
    [Arguments]    ${actual_UE}
    BuiltIn.Log to Console    \nAttach UE ${actual_UE}
    Attach UE to LTE    ue_id=${actual_UE}
    BuiltIn.Sleep    2s
    Trigger LTE-NR dual connectivity for bearers    ue_id=${actual_UE}    bearer_id=2


Attach UE unsuccessful gNB addition
    [Documentation]    [PRIVATE]   attach UE is expected to fail
    ...     :Autor: Sylvia Schneider
    ...     :param ${UE}:   number of UE
    [Arguments]     ${UE}
    Attach UE to LTE    ue_id=${UE}
    BuiltIn.Sleep    2s
    run keyword and ignore error    ute_wtssim.execute egate command and wait for data
    ...           cmd=ue_dc_enb_start ue=${UE} target_gnb=2 target_cells=1 bearer=2 type=split_scg   alias=ap_egate
    BuiltIn.Sleep    2s


Detach UE
    [Arguments]    ${actual_UE}
    BuiltIn.Log to Console    \nDetach UE ${actual_UE}
    ute_wtssim.execute egate command and wait for data    cmd=ue_detach id=${actual_UE}    alias=ap_egate


Create a Test Scenario Folder
    ${tc_name}    Fetch From Right   ${TEST NAME}     ${SPACE}
    Builtin.Set Test Variable      ${resultDir}    ${resultBaseDir}/${tc_name}
    create directory    ${resultDir}
    Builtin.Set Test Variable      ${traceDir}    ${resultDir}/traces
    create directory    ${traceDir}


Get test variables and upload start SCF
    ${allGlobalVariables} =    Get Variables
    Get testline specific data
    run keyword     get scf ${oam_type}    ${resultBaseDir}    SCFC_start.xml
    extract nrbts distname from SCF
    extract pmcadm distname from SCF

extract nrbts distname from SCF
    [Documentation]    [PRIVATE]
    ...     :Autor: Sylvia Schneider
    Run Keyword If      '${oam_type}' == 'cloud_coam'       get nrbts distname from SCF CU DU
    ...         ELSE    get nrbts distname from SCF      ${resultBaseDir}/SCFC_start.xml

extract pmcadm distname from SCF
    [Documentation]    [PRIVATE]
    ...     :Autor: Sylvia Schneider
    Run Keyword If      '${oam_type}' == 'cloud_coam'       get pmcadm distname from SCF CU DU
    ...         ELSE    get pmcadm distname from SCF      ${resultBaseDir}/SCFC_start.xml

get nrbts distname from SCF CU DU
    [Documentation]    [PRIVATE]    for coam cloud gnb
    ...     :Autor: Sylvia Schneider
    ...     :param ${gnb_id}: gNB instance id
    [Arguments]    ${gnb_id}=0
    get nrbts distname from SCF      ${resultBaseDir}/CU_SCFC_start.xml    CU
    ${du_num}=    Get length    ${tl.gnbs[${gnb_id}].dus}
    FOR    ${du_id}    IN RANGE    ${du_num}
        get nrbts distname from SCF      ${resultBaseDir}/DU${du_id}_SCFC_start.xml    DU    ${du_id}
    END

get pmcadm distname from SCF CU DU
    [Documentation]    [PRIVATE]    for coam cloud gnb
    ...     :Autor: Sylvia Schneider
    ...     :param ${gnb_id}: gNB instance id
    [Arguments]    ${gnb_id}=0
    get pmcadm distname from SCF      ${resultBaseDir}/CU_SCFC_start.xml    CU
    ${du_num}=    Get length    ${tl.gnbs[${gnb_id}].dus}
    FOR    ${du_id}    IN RANGE    ${du_num}
        get pmcadm distname from SCF      ${resultBaseDir}/DU${du_id}_SCFC_start.xml    DU    ${du_id}
    END

Create Test Suite Folders
    ${timeStamp}    robot.libraries.DateTime.get current date    result_format=%Y%m%d_%H%M%S
    BuiltIn.Set Suite Variable    ${resultBaseDir}    ${OUTPUT_DIR}/${SUITE_NAME}/0000/${timeStamp}
    create directory    ${resultBaseDir}

update new nrarfcn in gNB
    [Documentation]    [PRIVATE]    for coam classical gnb
    ...     :Autor: Sylvia Schneider
    ...     :param ${gnb_id}: gNB instance id
    ${d_nrarfcn_cell1}    create dictionary
    ...    dist_name   ${bts_distName}/${cell1_distName}
    ...    parameter   nrarfcn
    ...    value   ${nrarfcn_cell1}
    ${d_nrarfcn_cell2}    create dictionary
    ...    dist_name   ${bts_distName}/${cell2_distName}
    ...    parameter   nrarfcn
    ...    value   ${nrarfcn_cell2}
    ${d_nrarfcn_cell3}    create dictionary
    ...    dist_name   ${bts_distName}/${cell3_distName}
    ...    parameter   nrarfcn
    ...    value   ${nrarfcn_cell3}
    ${d_nrarfcn_cell4}    create dictionary
    ...    dist_name   ${bts_distName}/${cell4_distName}
    ...    parameter   nrarfcn
    ...    value   ${nrarfcn_cell4}

    ${nrarfcn_list}    Create List
    ...     ${d_nrarfcn_cell1}
    ...     ${d_nrarfcn_cell2}
    ...     ${d_nrarfcn_cell3}
    ...     ${d_nrarfcn_cell4}

   json delta commissioning coam     ${nrarfcn_list}


synchronize gnb radio
    [Documentation]    synchronization for radio card
    ...     :Autor: Sylvia Schneider
    ${radio_type_defined}   run keyword and return status    variable should exist      ${tl.gnbs[0].dus[0].rus[0].radio_type}
    Return From Keyword If           '${radio_type_defined}'=='False'
    Run Keyword If    '${tl.gnbs[0].dus[0].rus[0].radio_type}'=='AEUD'    synchronize gnb AEUD

synchronize gnb AEUD
    [Documentation]    [PRIVATE]      synchronization for radio card AEUD
    ...     :Autor: Sylvia Schneider
    ${cmd}    Set Variable    /sbin/devmem 0xa0205030 32 0x0
    ${change_container_cmd}    Set Variable     lxc-attach -n 0x1018
    ${loginAEUD}   Set Variable
    ...    ssh ${tl.gnbs[0].dus[0].rus[0].default_ssh_connection_details.username}\@${tl.gnbs[0].dus[0].rus[0].default_ssh_connection_details.addr}
    ${loginAEUD_slave}   Set Variable    ssh ${tl.gnbs[0].dus[0].rus[0].default_ssh_connection_details.username}@192.168.100.2

    BuiltIn.Log To Console    synchronization for radio card AEUD started
    ${gNBCommUnit_alias}    wait until keyword succeeds
    ...    ${SSH_AUTHENTICATION_TIMEOUT}   ${SSH_AUTHENTICATION_RETRY_INTERVAL}
    ...    Connect to gNB Common Unit
    sleep    2s
    ssh.Send Command    ${change_container_cmd}    timeout=60s     get_pty=True   connection=${gNBCommUnit_alias}
    ssh.Read Output Until   ${SPACE}>    timeout=10   connection=${gNBCommUnit_alias}
    ssh.Write Input     ${loginAEUD}${\n}           connection=${gNBCommUnit_alias}
    ssh.Read Output Until   password:${SPACE}    timeout=240   connection=${gNBCommUnit_alias}
    ssh.Write Input     ${tl.gnbs[0].dus[0].rus[0].default_ssh_connection_details.password}${\n}    connection=${gNBCommUnit_alias}
    ssh.Read Output Until   $${SPACE}    timeout=10   connection=${gNBCommUnit_alias}
    ssh.Write Input     ${cmd}${\n}   connection=${gNBCommUnit_alias}
    ssh.Read Output Until   $${SPACE}    timeout=10   connection=${gNBCommUnit_alias}
    ssh.Write Input     ${loginAEUD_slave}${\n}   connection=${gNBCommUnit_alias}
    ssh.Read Output Until   $${SPACE}    timeout=10   connection=${gNBCommUnit_alias}
    ssh.Write Input     ${cmd}${\n}   connection=${gNBCommUnit_alias}
    ssh.Read Output Until   $${SPACE}    timeout=10   connection=${gNBCommUnit_alias}
    ssh.Write Input    exit${\n}   connection=${gNBCommUnit_alias}
    ssh.Read Output Until   $${SPACE}    timeout=10   connection=${gNBCommUnit_alias}
    ssh.Write Input    exit${\n}   connection=${gNBCommUnit_alias}
    ssh.Read Output Until   ${SPACE}>    timeout=10   connection=${gNBCommUnit_alias}
    ssh.Send Command    exit${\n}   connection=${gNBCommUnit_alias}
    BuiltIn.Log To Console    synchronization for radio card AEUD finished
    [Teardown]    ssh.Disconnect   connection=${gNBCommUnit_alias}


Start wireshark for X2 and F1 IFs
    Run Keyword If    '${realEnb}'=='true'     Start wireshark LTE
    ...         ELSE                           Start wireshark gnb_${bts_type}


Start wireshark gnb_classical
    [Documentation]    for simulated LTE eNB using UTE
    Start Tcpdump on TestPc
    ...  interface=any
    ...  option=sctp or icmp
    ...  collector=dump_testpc

Start wireshark gnb_cloud
    [Documentation]    for simulated LTE eNB
    &{gnb_oam_ssh}    Create Dictionary
    ...  host=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    ...  user=${tl.gnbs[0].cu.oam_ssh_connection_details.username}
    ...  password=${tl.gnbs[0].cu.oam_ssh_connection_details.password}
    &{gnb_cpif_ssh}    Create Dictionary
    ...  host=cpif-0.local
    ...  user=${tl.gnbs[0].cu.oam_ssh_connection_details.username}
    ...  password=${tl.gnbs[0].cu.oam_ssh_connection_details.password}
    ...  proxy=${gnb_oam_ssh}

    tcpdump.create_tcpdump_collector
    ...     name=gnb_x2_dump
    ...     options=-i any
    ...     executor=${gnb_cpif_ssh}

    tcpdump.Create Collector Group
    ...  name=tshark_grp
    ...  members=gnb_x2_dump
    tcpdump.Set Suite Alias     tshark_grp

    tcpdump.setup_collectors
    ...    names=tshark_grp
    tcpdump.start_collectors
    ...    names=tshark_grp

Start wireshark LTE
    [Documentation]    for real LTE eNB
    &{lte_oam_ssh}    Create Dictionary
    ...  host=${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
    ...  user=${tl.enbs[0].airscale.common_units[0].lmp_connection.username}
    ...  password=${tl.enbs[0].airscale.common_units[0].lmp_connection.password}

    tcpdump.create_tcpdump_collector
    ...     name=lte_x2_dump
    ...     options=-i br1 -s0 sctp or icmp
    ...     executor=${lte_oam_ssh}

    tcpdump.Set Suite Alias     lte_x2_dump

    tcpdump.setup_collectors
    ...    names=lte_x2_dump
    tcpdump.start_collectors
    ...    names=lte_x2_dump


Stop wireshark for X2 and F1 IFs
    Run Keyword If    '${realEnb}'=='true'     Stop wireshark LTE
    ...         ELSE                           Stop wireshark gnb_${bts_type}


Stop wireshark gnb_classical
    Stop Tcpdump on TestPc
    ...  interface=any
    ...  collector=dump_testpc
    ...  target_dir=${resultDir}
    Run Keyword And Continue On Failure  Move File    ${resultDir}/dump_testpc/dump_testpc.pcap    ${resultDir}/X2.pcap


Stop wireshark gnb_cloud
    Run Keyword And Continue On Failure  tcpdump.stop_collectors
    ...    names=tshark_grp
    BuiltIn.Sleep    1s
    Run Keyword And Continue On Failure  tcpdump.collect_collectors
    ...    names=tshark_grp
    ...    target_dir=${resultDir}
    Run Keyword And Continue On Failure  tcpdump.teardown_collectors
    ...    names=tshark_grp
    Run Keyword And Continue On Failure  Move File    ${resultDir}/tshark_grp/gnb_x2_dump/gnb_x2_dump.pcap    ${resultDir}/X2.pcap


Stop wireshark LTE
    Run Keyword And Continue On Failure  tcpdump.stop_collectors
    ...    names=lte_x2_dump
    BuiltIn.Sleep    1s
    Run Keyword And Continue On Failure  tcpdump.collect_collectors
    ...    names=lte_x2_dump
    ...    target_dir=${resultDir}
    Run Keyword And Continue On Failure  tcpdump.teardown_collectors
    ...    names=lte_x2_dump
    Run Keyword And Continue On Failure  Move File    ${resultDir}/lte_x2_dump/lte_x2_dump.pcap    ${resultDir}/X2.pcap


Wait until coam CU all cells enabled
    [Documentation]    [PRIVATE]   on cloud gnb CU check and wait, that all created cells are enabled
    ...     :Autor: Sylvia Schneider
    ...     :param ${gnb_id}: gNB instance id
    [Arguments]   ${gnb_id}=0
    ${oam_alias}   connect.Setup OAM session    gnb_id=${gnb_id}    component=CU
    ${cell_status}    coam_cu.get_cells_statuses   connection=${oam_alias}
    Teardown OAM session    component=CU    connection=${oam_alias}
    ${num_of_cells}    get length       ${cell_status}
    Wait Cell Enabled with COAM    ${num_of_cells}


Wait until coam gNB to be onair state and cells enabled
    [Documentation]    [PRIVATE]   on classical gnb check and wait, that all created cells are enabled
    ...     :Autor: Sylvia Schneider
    admin.connect_to
    ...    bts_host=${tl.gnbs[0].cu.oam_http_connection_details.addr}
    ...    name=gnb
    ${scf_content}     admin.get_scf  parameters_save_variant=actualValues    connection=gnb    timeout=${30}
    ${list_cells}      string.Get Regexp Matches    ${scf_content}    class="com.nokia.srbts.nrbts:NRCELL"
    ${num_of_cells}    collections.Count Values In List  ${list_cells}   class="com.nokia.srbts.nrbts:NRCELL"
    Wait Cell Enabled with COAM    ${num_of_cells}
    [Teardown]  admin.teardown    connection=gnb


Wait Cell Enabled with COAM
    [Documentation]    [PRIVATE]   check and wait, that all created cells are enabled
    ...     :Autor: Sylvia Schneider
    ...     :param ${num_of_cells}: number of created cells
    ...     :param ${timeout}: max time until cells must be enabled
    [Arguments]     ${num_of_cells}    ${timeout}=1200 sec
    BuiltIn.Log To Console     \nwaiting for all cells having operationalState Enabled
    Wait until keyword succeeds     ${timeout}      20 sec
    ...     Compare number of enabled cells with number of cells with ${oam_type}   ${num_of_cells}


Compare number of enabled cells with number of cells with coam
    [Documentation]    [PRIVATE]   on classical gnb verify if all created cells are enabled
    ...     :Autor: Sylvia Schneider
    ...     :param ${num_of_cells}: number of created cells
    [Arguments]     ${num_of_cells}
    BuiltIn.Log To Console     .   no_newline=true
    @{cell_status}=     admin.get_cells_info     connection=gnb
    ${num_of_enabled_cells}    set variable   ${0}
    FOR    ${index}    IN RANGE    ${num_of_cells}
        &{temp}    set variable  ${cell_status}[${index}]
        &{temp1}    get from dictionary    ${temp}    status
        Dictionary should contain item    ${temp1}    operationalState      Enabled
        ${num_of_enabled_cells}    Evaluate             ${num_of_enabled_cells}+1
    END
    Should Be True   '${num_of_cells}'=='${num_of_enabled_cells}'    msg=${num_of_enabled_cells} Cell(s) of ${num_of_cells} Enabled


Compare number of enabled cells with number of cells with cloud_coam
    [Documentation]    [PRIVATE]   on cloud gnb CU verify if all created cells are enabled
    ...     :Autor: Sylvia Schneider
    ...     :param ${num_of_cells}: number of created cells
    ...     :param ${gnb_id}: gNB instance id
    [Arguments]     ${num_of_cells}     ${gnb_id}=0
    BuiltIn.Log To Console     .   no_newline=true
    ${oam_alias}   connect.Setup OAM session    gnb_id=${gnb_id}    component=CU
    ${cell_status}    coam_cu.get_cells_statuses   connection=${oam_alias}
    Teardown OAM session    component=CU   connection=${oam_alias}
    ${num_of_enabled_cells}    set variable   ${0}
    FOR    ${index}    IN RANGE    ${num_of_cells}
        &{temp}    set variable  ${cell_status}[${index}]
        Dictionary should contain item    ${temp}    operational_state      enabled
        ${num_of_enabled_cells}    Evaluate             ${num_of_enabled_cells}+1
    END
    Should Be True   '${num_of_cells}'=='${num_of_enabled_cells}'    msg=${num_of_enabled_cells} Cell(s) of ${num_of_cells} Enabled

restore parameter values with full commissioning
    [Documentation]    [PRIVATE]
    ...     :Autor: Sylvia Schneider
    Run Keyword If    '${oam_type}' == 'coam'     restore SCF coam
    ...         ELSE                              restore SCF CU DU


restore SCF coam
    [Documentation]    [PRIVATE] restore SCF on classical gnb
    ...     :Autor: Sylvia Schneider
    admin.connect_to
    ...    bts_host=${tl.gnbs[0].cu.oam_http_connection_details.addr}
    ...    name=gnb
    admin.perform_commissioning
    ...   scf_file=${resultBaseDir}/SCFC_start.xml
    ...   skip_parameter_relation_errors=True
    ...   should_activate=${TRUE}
    ...   timeout=660
    ...   connection=gnb
    admin.teardown    connection=gnb


check if CU Plan Upload successful
    [Arguments]  ${operation_id}   ${gnb_id}=0
    ${oam_alias}   connect.Setup OAM session    gnb_id=${gnb_id}    component=CU
    ${operation_response}=  coam_cu.get_operation_state_of_uploading_plan    operation_id=${operation_id}   connection=${oam_alias}
    should be equal as strings  ${operation_response["status"]}   success
    [Teardown]   Teardown OAM session    component=CU    connection=${oam_alias}


check if CU Plan Validate successful
    [Arguments]   ${plan_id}  ${operation_id}   ${gnb_id}=0
    ${oam_alias}   connect.Setup OAM session    gnb_id=${gnb_id}    component=CU
    ${operation_response}  coam_cu.get_operation_state_of_validating_plan  plan_id=${plan_id}  operation_id=${operation_id}  connection=${oam_alias}
    should be equal as strings  ${operation_response["status"]}   success
    [Teardown]   Teardown OAM session    component=CU    connection=${oam_alias}


check if CU Plan Activate successful
    [Arguments]   ${plan_id}  ${operation_id}   ${gnb_id}=0
    ${oam_alias}   connect.Setup OAM session    gnb_id=${gnb_id}    component=CU
    ${operation_response}  coam_cu.get_operation_state_of_activating_plan  plan_id=${plan_id}  operation_id=${operation_id}  connection=${oam_alias}
    should be equal as strings  ${operation_response["status"]}   success
    [Teardown]   Teardown OAM session    component=CU    connection=${oam_alias}


restore SCF CU DU
    [Documentation]    [PRIVATE] restore SCFs on cloud coam gnb
    ...     :Autor: Sylvia Schneider
    restore SCF CU
    restore SCF all DU

restore SCF CU
    [Documentation]    [PRIVATE]    restore CU SCF
    ...     :Autor: Sylvia Schneider
    ...     :param ${gnb_id}: gNB instance id
    [Arguments]     ${gnb_id}=0
    BuiltIn.Log To Console     \nfull commissioning of CU
    BuiltIn.Log To Console     ${SPACE*3}using CU SCF ${resultBaseDir}/CU_SCFC_start.xml
    BuiltIn.Log To Console     ${SPACE*3}starting upload to gNB
    ${oam_alias}   connect.Setup OAM session    gnb_id=${gnb_id}    component=CU
    ${result_upload}    coam_cu.upload_plan_file    ${resultBaseDir}/CU_SCFC_start.xml   connection=${oam_alias}
    Teardown OAM session    component=CU    connection=${oam_alias}
    wait until keyword succeeds    60s   5s  check if CU Plan Upload successful
    ...    ${result_upload["action_id"]}
    BuiltIn.Log To Console     ${SPACE*3}starting validate of plan file
    ${oam_alias}   connect.Setup OAM session    gnb_id=${gnb_id}    component=CU
    ${validate_result}   coam_cu.plan_validation    ${result_upload["plan_id"]}   connection=${oam_alias}
    Teardown OAM session    component=CU    connection=${oam_alias}
    wait until keyword succeeds    60s   5s  check if CU Plan Validate successful
    ...    ${result_upload["plan_id"]}
    ...    ${validate_result["action_id"]}
    BuiltIn.Log To Console     ${SPACE*3}starting activation of plan file
    ${oam_alias}   connect.Setup OAM session    gnb_id=${gnb_id}    component=CU
    ${activate_result}   coam_cu.plan_activation   ${result_upload["plan_id"]}   connection=${oam_alias}
    Teardown OAM session    component=CU    connection=${oam_alias}
    wait until keyword succeeds    300s   30s  check if CU Plan Activate successful
    ...    ${result_upload["plan_id"]}
    ...    ${activate_result["id"]}
    BuiltIn.Log To Console     full commissioning of CU SCF finished


restore SCF all DU
    [Documentation]    [PRIVATE]    restore all DU SCF
    ...     :Autor: Sylvia Schneider
    ...     :param ${gnb_id}: gNB instance id
    [Arguments]    ${gnb_id}=0
    ${du_num}=    Get length    ${tl.gnbs[${gnb_id}].dus}
    FOR    ${du_id}    IN RANGE    ${du_num}
       restore SCF DU    ${gnb_id}   ${du_id}
    END

restore SCF DU
    [Documentation]    [PRIVATE]    restore SCF on DU with instance ${du_id}
    ...     :Autor: Sylvia Schneider
    ...     :param ${gnb_id}: gNB instance id
    ...     :param ${du_id}: du instance id
    [Arguments]    ${gnb_id}=0   ${du_id}=0
    builtIn.Log To Console    \nfull commissioning on gnb-${gnb_id} DU-${du_id} started
    ${alias_du}    connect oam DU   gnb_id=${gnb_id}   du_id=${du_id}
    admin.perform_commissioning
    ...   scf_file=${resultBaseDir}/DU${du_id}_SCFC_start.xml
    ...   skip_parameter_relation_errors=True
    ...   should_activate=${TRUE}
    ...   timeout=660
    ...   connection=${alias_du}
    builtIn.Log To Console    \nfull commissioning on gnb-${gnb_id} DU-${du_id} finished
    [Teardown]    disconnect oam DU    alias_du=${alias_du}


Collect snapshot
    [Documentation]    [PRIVATE]
    ...     :Autor: Sylvia Schneider
    Run Keyword If     '${realEnb}'=='false'    generate AP sosReport
    Create Directory    ${resultBaseDir}/snapshot
    BuiltIn.Log To Console     \nsnapshot save directory "${resultBaseDir}/snapshot"
    Run Keyword If    '${oam_type}' == 'coam'             Collect snapshot coam
    ...         ELSE                                      Collect snapshot CU DU

generate AP sosReport
    [Documentation]    [PRIVATE]
    ...     :Autor: Sylvia Schneider
    BuiltIn.Log To Console     \nstarting sos report in order to get AP logs, save directory "${resultBaseDir}/sosreport"
    Create Directory    ${resultBaseDir}/sosreport
    Collect sos report logs   target_dir=${resultBaseDir}/sosreport
    BuiltIn.Log To Console     \nsos report finished

Collect snapshot CU DU
    [Documentation]    [PRIVATE]   collect snapshot on cloud coam gnb for CU and all DUs
    ...     :Autor: Sylvia Schneider
    ...     :param ${gnb_id}: gNB instance id
    [Arguments]    ${gnb_id}=0
    ${oam_alias}   connect.Setup OAM session    gnb_id=${gnb_id}    component=CU
    BuiltIn.Log To Console     \nsnapshot on CU started
    coam_cu.get_local_snapshot    ${resultBaseDir}/snapshot    180     600   connection=${oam_alias}
    BuiltIn.Log To Console     \nsnapshot on CU finished
    Teardown OAM session   component=CU    connection=${oam_alias}
    collect snapshot all DU


collect snapshot all DU
    [Documentation]    [PRIVATE]   collect snapshot on cloud coam gnb for all DUs
    ...     :Autor: Sylvia Schneider
    ...     :param ${gnb_id}: gNB instance id
    [Arguments]    ${gnb_id}=0
    ${du_num}=    Get length    ${tl.gnbs[${gnb_id}].dus}
    FOR    ${du_id}    IN RANGE    ${du_num}
       collect snapshot DU    ${gnb_id}   ${du_id}
    END

collect snapshot DU
    [Documentation]    [PRIVATE]  collect snapshot on DU with instance ${du_id}
    ...     :Autor: Sylvia Schneider
    ...     :param ${gnb_id}: gNB instance id
    ...     :param ${du_id}: du instance id
    [Arguments]    ${gnb_id}=0   ${du_id}=0
    builtIn.Log To Console    \nsnapshot on DU ${du_id} started
    ${alias_du}    connect oam DU   gnb_id=${gnb_id}   du_id=${du_id}
    ${path_SCF}     admin.get snapshot
    ...    target_file_name=${resultBaseDir}/snapshot/DU${du_id}_snapshot.zip
    ...    coverage=Full
    ...    force=True
    ...    timeout=600
    ...    connection=${alias_du}
    disconnect oam DU    alias_du=${alias_du}
    BuiltIn.Log To Console    \nsnapshot on DU ${du_id} finished


Collect snapshot coam
    [Documentation]    [PRIVATE]   collect snapshot on classical coam gnb
    ...     :Autor: Sylvia Schneider
    builtIn.Log To Console    \nsnapshot coam started
    admin.connect_to
    ...    bts_host=${tl.gnbs[0].cu.oam_http_connection_details.addr}
    ...    name=gnb

    ${path_SCF}     admin.get snapshot
    ...    target_file_name=${resultBaseDir}/snapshot/snapshot.zip
    ...    coverage=Full
    ...    force=True
    ...    timeout=240
    ...    connection=gnb

    admin.teardown    connection=gnb
    BuiltIn.Log To Console    \nsnapshot coam finished

