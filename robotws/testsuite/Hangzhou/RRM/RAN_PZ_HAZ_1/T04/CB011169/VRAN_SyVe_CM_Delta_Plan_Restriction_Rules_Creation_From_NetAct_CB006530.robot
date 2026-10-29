*** Settings ***
Documentation
...    VRF HAZ 1 Common Resources.

Resource          ../../Resources/Cloud/AIC_Common_Resource.robot
Resource          ../Resources/AIC_Utils.robot

*** Variables ***
${test_data_file_cb006530}    /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T04/TestData/restriction_parameters_vdu.yaml

*** Keywords ***
TC__VRAN_SyVe_CM_Delta_Plan_Restriction_Rules_Creation_From_NetAct_CB006530
    [Documentation]
    ...    Author: lixin.kang@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    21.02.2024, lixin.kang@nokia-sbell.com, draft
    ...    Description: This robot cases is for Airscale_SRAN_SyVe_CB006530_005__Creation_of_restriction_rules_in_a_delta_plan_via_WebEM_with_
    ...   "Nemuadmin"_role_and_NetAct on vRAN:
    ...    Create restriction rule and modify parameter to see whether the restricted parameter is prevent to update

    Log To Console    ${TEST_NAME} start.
    Step 1: TC Parameters Check
    Step 2: Generate Random Restriction Rule For All Cell MO
    Step 3: Create And Edit Plan With Restriction Rule
    Step 4: Provision The Plan To Create Restriction Rule
    Step 5: Check Restriction Rule Parameters From NetAct
    Step 6: Create And Provision Plan With Random Parameters In Restriction
    Step 7: Provision the backup plan

Step ${index}: TC Parameters Check
    Log To Console    ${index}
    Log To Console    TC parameters check started
    Set Test Variable    ${mo_id}    PLMN-PLMN/MRBTS-${vDU_id}/MNL-1/MNLENT-1/FEATCADM-1
    Set Test Variable    ${scf_distName}    MRBTS-${vDU_id}/MNL-1/MNLENT-1/FEATCADM-1
    NetAct CM Upload    dist_names=PLMN-PLMN/MRBTS-${vDU_id}
    ${no_rule_exist}    Run Keyword And Return Status     NetAct Check Actual Configuration Parameters    PLMN-PLMN/MRBTS-${vDU_id}
    ...    ${mo_id}    &{EMPTY}
    Run Keyword If    '${no_rule_exist}'=='True'    Log    TC parameters successfully checked    console=True
    ...    ELSE    Run Keywords    Log    TC parameters checking warning, already exist rules, will clean rules now
    ...    console=True    level=WARN
    ...    AND    Run Keyword And Continue On Failure
    ...    Clean Existing Restriction Rule    ${mo_id}    ${scf_distName}    ${backup_vDU_scf_file}

Step ${index}: Generate Random Restriction Rule For All Cell MO
    Log To Console    Step ${index}: Generate Random Restriction Rule For All Cell MO
    Generate Rule Data From Json
    FOR    ${type}    IN    @{all_mo_type}
        ${mo_dn_list}    Get MO DN From SCF    ${backup_vDU_scf_file}    .//managedObject[@class="com.nokia.srbts.nrbts:${type}"]
        Set Test Variable    ${ALL_${type}_DN}    ${mo_dn_list}
    END
    Generate Random DN Rule
    ${selected_parameters_rules}    Create List
    Set Test Variable    ${selected_parameters_rules}
    FOR    ${type}    IN    @{all_mo_type}
        Run Keyword If    ${ALL_${type}_DN}    Run Keywords    Generate Random Restriction Rule For ${type}
        ...    AND    Generate Random Parameter To Modify For ${type}
    END

Step ${index}: Create And Edit Plan With Restriction Rule
    [Documentation]    Create and edit plan SyVe based on selected PLAN_x define in netact_plan.yaml
    Log To Console    Step ${index}: Create And Edit Plan With Restriction Rule
    ${timestamp}    AIC_NetAct.Generate Formatted Timestamp
    Should Be String    MRBTS-${vDU_id}_${timestamp}
    Set Test Variable    ${create_rule_plan_name}    CB006530_Create_Prevent_Rule_MRBTS-${vDU_id}_${timestamp}
    # e.g. preventParamModifList= NRCELL-tmpActFeat1    NRCELL_FDD-actAsymBwGuardband
    # preventParamModifTargetDN=MRBTS-11084/NRBTS-11084/NRCELL-1
    ${prevent_param_dn_dic}    Run Keyword If    len(${all_selected_cell_dn_list})!=0    Create Dictionary
    ...    preventParamModifList=${selected_parameters_rules}    preventParamModifTargetDN=${all_selected_cell_dn_list}
    ...    ELSE    Create Dictionary    preventParamModifList=${selected_parameters_rules}
    ${plan}    NetAct Create And Edit Plan    BTS_scf_initial=${backup_vDU_scf_file}    name=${create_rule_plan_name}
    ...    description=Automation SyVe for MRBTS-${vDU_id}    mo_id=${mo_id}    scf_distName=${scf_distName}    &{prevent_param_dn_dic}
    Set Test Variable    ${prevent_param_dn_dic}
    NetAct Export Plan    local_dir=${TEST_LOG_DIRECTORY}/NetActLogs   file_name=${create_rule_plan_name}.csv
    ...    dist_names=PLMN-PLMN/MRBTS-${vDU_id}    plan_name=${create_rule_plan_name}    operation_type=plan

Step ${index}: Provision The Plan To Create Restriction Rule
    Log To Console    Step ${index}: Provision The Plan To Create Restriction Rule
    NetAct Provision Plan    plan_name=${create_rule_plan_name}    dist_names=PLMN-PLMN/MRBTS-${vDU_id}
    ...    backup_plan_name=${create_rule_plan_name}_backup    create_backup_plan=True    provisioning_operation=activate

Step ${index}: Check Restriction Rule Parameters From NetAct
    Log To Console    Step ${index}: Check Restriction Rule Parameters From NetAct
    NetAct Check Actual Configuration Parameters    PLMN-PLMN/MRBTS-${vDU_id}    ${mo_id}    &{prevent_param_dn_dic}

Step ${index}: Provision the backup plan
    Log To Console     ${index}: Provision the backup plan
    NetAct Export Plan    local_dir=${TEST_LOG_DIRECTORY}/NetActLogs    file_name=${create_rule_plan_name}_backup.csv
    ...    dist_names=PLMN-PLMN/MRBTS-${vDU_id}   plan_name=${create_rule_plan_name}_backup    operation_type=plan
    NetAct Provision Plan    plan_name=${create_rule_plan_name}_backup    dist_names=PLMN-PLMN/MRBTS-${vDU_id}   backup_plan_name=None
    ...   create_backup_plan=False    provisioning_operation=activate

Step ${index}: Create And Provision Plan With Random Parameters In Restriction
    Log To Console    Step ${index}: Create And Provision Plan With Random Parameters In Restriction
    FOR    ${type}    IN    @{all_mo_type}
        Run Keyword If    ${ALL_${type}_DN}    Run Keywords    Create NetAct Plan With Random Selected Restricted Parameters    ${type}
        ...    AND    NetAct Export Plan    local_dir=${TEST_LOG_DIRECTORY}/NetActLogs    file_name=${modify_param_plan_name}.csv
        ...    dist_names=PLMN-PLMN/MRBTS-${vDU_id}    plan_name=${modify_param_plan_name}    operation_type=plan
        ...    AND    Provision The Plan To Modify Restricted Parameters And Verify Error Message For ${type}
        ...    AND    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${modify_param_plan_name}
    END

Generate Rule Data From Json
    ${file_content}    OperatingSystem.Get File    ${test_data_file_cb006530}
    ${data}    Evaluate    ${file_content}
    ${keys}    Get Dictionary Keys   ${data}
    FOR    ${key}    IN    @{keys}
        ${item}  Get From Dictionary    ${data}    ${key}
        ${parameter_dic}    Get From Dictionary    ${item}    parameters
        Set Test Variable    ${${key}_parameters_pool}    ${parameter_dic}
        ${rule_parameters}    Get Dictionary Keys    ${parameter_dic}
        ${moc_rule_list}    Generate MOC Rule Data    ${key}    ${rule_parameters}
        Set Test Variable     ${${key}_rule_list}    ${moc_rule_list}
        ${relation_dic}    Get From Dictionary    ${item}    relation
        Set Test Variable    ${${key}_relation_mapping}    ${relation_dic}
        ${special_param_mapping}    Get From Dictionary    ${item}    special_parameter_mapping
        Set Test Variable    ${${key}_special_param_mapping}    ${special_param_mapping}
    END
    Set Test Variable    ${all_mo_type}    ${keys}

Generate MOC Rule Data
    [Arguments]    ${MOC}    ${rule_parameters_list}
    ${rule_list}    Create List
    FOR    ${item}    IN    @{rule_parameters_list}
        Append To List    ${rule_list}    ${MOC}-${item}
    END
    [Return]    ${rule_list}

Generate Random DN Rule
    ${all_selected_cell_dn_list}    Create List
    Set Test Variable    ${all_selected_cell_dn_list}
    FOR    ${type}    IN    @{all_mo_type}
        ${selected_for_modify_dn}    Run Keyword If   ${ALL_${type}_DN}    Generate Random DN For Specific Tech Type    ${ALL_${type}_DN}
        Set Test Variable    ${selected_${type}_for_modify_dn}    ${selected_for_modify_dn}
    END

Generate Random DN For Specific Tech Type
    [Arguments]     ${specific_tech_cells_dn_list}
    [Documentation]   Random select dn for specific tech type (e.g. NRCELL, NRCELL_FDD), and combined the selected dns to one
    ...    list <all_selected_cell_dn_list>.
    ...    The random choise result can be empty means no dn selected for specific technical type.
    ...    The last selected dn is stored in <selected_for_modify_dn> as the dn for parmater modify,
    ...    it can be also empty if no dn selected for specific technical type (means <all_selected_cell_dn_list> is empty).
    ${selected_for_modify_dn}    Set Variable    ${EMPTY}
    ${rule_count}    Evaluate    random.randint(0, 1)    modules=random, sys
    FOR    ${step}    IN RANGE    1    ${rule_count+1}
        ${selected_for_modify_dn}    Evaluate    random.choice(${specific_tech_cells_dn_list})    modules=random, sys
        Append To List     ${all_selected_cell_dn_list}    ${selected_for_modify_dn}
    END
    [Return]    ${selected_for_modify_dn}

Generate Random Restriction Rule For ${tech}
    ${rule_num}    Get Length     ${${tech}_rule_list}
    ${max_num}    Set Variable If    ${rule_num}>10    10    ${rule_num}
    ${rule_count}    Evaluate    random.randint(1, ${max_num})    modules=random, sys
    ${selected_param_rule_for_tech}    Create List
    FOR    ${step}    IN RANGE    1    ${rule_count+1}
        ${selected_rule}    Evaluate    random.choice(${${tech}_rule_list})    modules=random, sys
        Append To List    ${selected_parameters_rules}    ${selected_rule}
        Append To List    ${selected_param_rule_for_tech}    ${selected_rule}
        Remove Values From List    ${${tech}_rule_list}    ${selected_rule}
    END
    Set Test Variable    ${${tech}_selected_parameters_rules}    ${selected_param_rule_for_tech}

Generate Random Parameter To Modify For ${type}
     ${selected_parameter}    Evaluate    random.choice(${${type}_selected_parameters_rules})    modules=random, sys
     Set Test Variable    ${selected_${type}_parameter_to_modify}    ${selected_parameter}
     Remove Values From List    ${${type}_selected_parameters_rules}    ${selected_parameter}

Provision The Plan To Modify Restricted Parameters And Verify Error Message For ${type}
    Log To Console    Provision The Plan To Modify Restricted Parameters And Verify Error Message
    ${message}    NetAct Provision Plan Failure   plan_name=${modify_param_plan_name}    dist_names=PLMN-PLMN/MRBTS-${vDU_id}
    ...    backup_plan_name=None    create_backup_plan=False    provisioning_operation=activate
    ${type_param}    Set Variable    ${selected_${type}_parameter_to_modify}
    ${param}    Fetch From Right    ${type_param}    -
    ${formatted_param}    Convert To String    ${param}
    # classical is NRCELL-1-[tmpActFeat2] is not allowed, vran currently is MRBTS-11084/NRBTS-11084/NRCELL-1-tmpActFeat2
    # ${formatted_type}     Fetch From Right    ${${type}_dn_to_set}    /
    Log    Modification of restricted parameter ${${type}_dn_to_set}-${formatted_param} is not allowed
    Should Contain   ${message}    Modification of restricted parameter ${${type}_dn_to_set}-${formatted_param} is not allowed

Create NetAct Plan With Random Selected Restricted Parameters
    [Arguments]     ${type}
    ${origin_param}    Fetch From Right    ${selected_${type}_parameter_to_modify}    -
    ${sub_param}    Fetch From Right    ${origin_param}    .
    ${value_list}    Set Variable    ${${type}_parameters_pool["${origin_param}"]}
    ${dn_to_set}    Run Keyword If    '${selected_${type}_for_modify_dn}'    Set Variable    ${selected_${type}_for_modify_dn}
    ...    ELSE    Evaluate    random.choice(${ALL_${type}_DN})    modules=random, sys
    Set Test Variable    ${${type}_dn_to_set}    ${dn_to_set}

    ${status}    ${target_param}    Run Keyword And Ignore Error    Get From Dictionary    ${${type}_special_param_mapping}
    ...   ${origin_param}
    ${converted_param}    Set Variable If    '${status}'=='PASS'    ${target_param}    ${sub_param}
    # Parameter need value:
    Run Keyword If    len(${value_list})!=0    Get Param And Value For Primary Parameter   ${dn_to_set}    ${origin_param}
    ...    ${converted_param}    ${value_list}
    # Parameter is structure and no need value:
    ...    ELSE    Get Param And Value For Sub Parameter    ${dn_to_set}   ${type}    ${origin_param}
    ${delta_plan}     Create The Update Parameter Plan
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}    L_XML.Parse xml    ${backup_vDU_scf_file}
    ${MO_items}    L_XML.Get Element Attributes    ${scf_xml}    .//managedObject[@distName="${dn_to_set}"]
    netact.Create Managed Object    plan=${delta_plan}    meta_class=${MO_items['class']}    meta_version=${MO_items['version']}
    ...    mo_id=PLMN-PLMN/${dn_to_set}    &{param_dic}

Get Param And Value For Primary Parameter
     [Arguments]    ${dn}    ${origin_param}    ${converted_param}    ${value_list}
     Log To Console    ${origin_param}
     ${cnt_true}    Count Values In List    ${value_list}    true
     ${cnt_false}    Count Values In List    ${value_list}    false
     ${ui_value}    Set Variable If    ${cnt_true}!=0 or ${cnt_false}!=0    true    false
     ${value}    Random Select Value For Parameter    ${dn}    ${converted_param}    ${value_list}    ${ui_value}
     ${param_dic}     Create Dictionary    ${converted_param}=${value}
     Set Test Variable    ${param_dic}

Get Param And Value For Sub Parameter
     [Arguments]     ${dn}    ${type}    ${origin_param}
     ${sub_param_list}     Get From Dictionary    ${${type}_relation_mapping}    ${origin_param}
     ${random_param}    Evaluate    random.choice(${sub_param_list})    modules=random, sys
     ${value_list}     Set Variable    ${${type}_parameters_pool["${origin_param}.${random_param}"]}
     ${cnt_true}    Count Values In List    ${value_list}    true
     ${cnt_false}    Count Values In List    ${value_list}    false
     ${ui_value}    Set Variable If    ${cnt_true}!=0 or ${cnt_false}!=0    true    false
     ${status}    ${target_param}    Run Keyword And Ignore Error    Get From Dictionary    ${${type}_special_param_mapping}
     ...    ${origin_param}.${random_param}
     ${converted_param}    Set Variable If    '${status}'=='PASS'    ${target_param}    ${random_param}
     ${value}    Random Select Value For Parameter    ${dn}    ${converted_param}    ${value_list}    ${ui_value}
     ${param_dic}     Create Dictionary    ${converted_param}=${value}
     Set Test Variable    ${param_dic}
     Set Test Variable    ${selected_${type}_parameter_to_modify}    ${type}-${origin_param}.${random_param}
     Remove Values From List     ${${type}_selected_parameters_rules}    ${type}-${origin_param}.${random_param}

Random Select Value For Parameter
     [Arguments]    ${dn}    ${param}    ${value_list}    ${ui_value}=false
     ### a: current  parameter is not empty in system. remove current value from value list and random select 1 value from the left
     ${status}    ${current_value}    Run Keyword And Ignore Error    Get Actual Configuration Parameters
     ...    ne=PLMN-PLMN/MRBTS-${vDU_id}    dist_name=PLMN-PLMN/${dn}    param=${param}    ui_values=${ui_value}
     Run Keyword If     '${status}' == 'PASS'    Remove Values From List    ${value_list}    ${current_value}
     ### b: current  parameter is not set in system. random select 1 value from value list
     ${value}    Evaluate    random.choice(${value_list})    modules=random, sys
     [Return]    ${value}

Create The Update Parameter Plan
     ${timestamp}    AIC_NetAct.Generate Formatted Timestamp
     Should Be String    MRBTS-${mrbts_id}_${timestamp}
     Set Test Variable    ${modify_param_plan_name}    CB006530_Update_Prevented_Param_MRBTS-${mrbts_id}_${timestamp}
     ${delta_plan}    NetAct Create Plan    name=${modify_param_plan_name}  description=CB006530 automation SyVe for MRBTS-${mrbts_id}
     [Return]    ${delta_plan}

Case Precondition
    [Arguments]    ${ReIntegrate_vCU}=False    ${ReIntegrate_vDU}=False
    Log To Console    Case Precondition
    Common Test Setup For AIC
    Setup NetAct    ${NETACT}
    #ReIntegrate NE
    Run Keyword If    ${ReIntegrate_vCU}    Wait Until Keyword Succeeds    2x    15s
    ...    Integrate NE To NetAct    ${cu_ip}    PLMN-PLMN/MRBTS-${vCU_id}    ${cu_release}    ${cu_mr}
    Run Keyword If    ${ReIntegrate_vDU}    Wait Until Keyword Succeeds    2x    15s
    ...    Integrate NE To NetAct    ${du_ip}    PLMN-PLMN/MRBTS-${vDU_id}    ${du_release}    ${du_mr}
    ${status}    Run Keyword And Return Status    OperatingSystem.File Should Exist    ${TEST_LOG_DIRECTORY}/backup_scf/scf_backup.xml
    ${backup_vDU_scf_file}   Run Keyword If    ${status}    Set Variable    ${TEST_LOG_DIRECTORY}/backup_scf/scf_backup.xml
    ...    ELSE    vDU Backup SCF From Test Line
    Set Test Variable    ${backup_vDU_scf_file}

Case Postcondition
    Log To Console    Case Postcondition
    Particular Teardown
    Common Test Teardown For AIC
    Teardown NetAct

Particular Teardown
    Log    Particular Teardown    console=True
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${create_rule_plan_name}
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${create_rule_plan_name}_backup
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${modify_param_plan_name}
    Run Keyword And Continue On Failure    Clean Existing Restriction Rule    ${mo_id}    ${scf_distName}    ${backup_vDU_scf_file}

