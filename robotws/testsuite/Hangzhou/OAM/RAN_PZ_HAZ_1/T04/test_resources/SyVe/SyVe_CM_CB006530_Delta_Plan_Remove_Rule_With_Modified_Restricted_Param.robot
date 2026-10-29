*** Settings ***
Documentation       Test case for xxx
...                 Author: xxx
...                 Contact: xxx.xx@nokia.com
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${SRNCLAB}      SRNCLAB1019    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}
${TEST_DATA_FILE}    /home/ute/btsauto/hran_ta/config/${HW_LOCATION_CODE}/${TESTLINE_NAME}/testdata/restriction_parameters.yaml
${origin_scf_path}      /home/ute/btsauto/hran_ta/config/${HW_LOCATION_CODE}/${TESTLINE_NAME}/commissioning/SCF_01_SBTS18.xml

*** Keywords ***
SyVe_CM_CB006530_Delta_Plan_Remove_Rule_With_Modified_Restricted_Param
    [Documentation]    [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-22035
    ...    *****************
    ...    Basic information
    ...    *****************
    ...    Test for Airscale_SRAN_SyVe_CB006530_006__Removal_of_an_element_in_restriction_list_and_modification_of_that
    ...    _parameter_in_the_same_delta_plan_via_WebEM_with_“Nemuadmin”_role_and_NetAct:
    ...    When restriction rule exist, remove existing rule with the restricted parameter updating will be provision success
    ...
    ...    The main steps performed for the test are:
    ...    TC Parameters Check
    ...    Check initial BTS state
    ...    Check initial alarms status from WebEM
    ...    Check initial alarms status from Netact
    ...    Upload configuration status
    ...    Generate Random Restriction Rule For All Cell MO
    ...    Create And Edit Plan With Restriction Rule
    ...    Provision The Plan To Create Restriction Rule
    ...    Check Restriction Rule Parameters From NetAct
    ...    Create And Provision Plan To Remove Rule With Param Modified
    ...    Provision the backup plan
    ...    Check final alarms status from WebEM
    ...    Check final alarms status from Netact
    ...    Check final BTS state
    ...    Check final number and state of Cells and RMs
    ...
    ...    Pass criteria: Remove existing  restriction rule with parameter modified will be provision successful
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 12.10.2021 - https://jira3.int.net.nokia.com/browse/TAT-22035 -
    ...    SyVe_CM_Delta_Plan_Remove_Rule_With_Modified_Restricted_Param_CB006530
    ...    - 23.03.2022 - Modified by Kang Lixin - https://jira3.ext.net.nokia.com/browse/TAT-22847 -
    ...    Update case for switching ute_admin to taf.sbts.oam.coam.admin
    ...
    ...    *******************
    ...    Test case flowchart
    ...    *******************
    ...    .. image:: http://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SYVE/
    ...    TAT-22035_SyVe_CM_Delta_Plan_Remove_Rule_With_Modified_Restricted_Param_CB006530.png

    Set Tags    AUTHOR-lixin.kang@nokia-sbell.com    Maintainer–I_MN_SRAN_HZ_PROD_SRAN_SQUAD3@internal.nsn.com
    Step 1: TC Parameters Check
    Step 2: Check initial BTS state
    Step 3: Check initial alarms status from WebEM
    Step 4: Check initial alarms status from Netact
    Step 5: Upload configuration status
    Step 6: Generate Random Restriction Rule For All Cell MO
    Step 7: Create And Edit Plan With Restriction Rule
    Step 8: Provision The Plan To Create Restriction Rule
    Step 9: Check Restriction Rule Parameters From NetAct
    Step 10: Create And Provision Plan To Remove Rule With Param Modified
    Step 11: Provision the backup plan
    Step 12: Check final alarms status from WebEM
    Step 13: Check final alarms status from Netact
    Step 14: Check final BTS state
    Step 15: Check final number and state of Cells and RMs

Step ${index}: TC Parameters Check
    Log    Step ${index}: TC Parameters Check    console=True
    ${mrbts_id}    Should Match Regexp    ${MRBTS_DN}    \\d+
    Set Test Variable    ${mrbts_id}
    Set Test Variable    ${mo_id}    ${MRBTS_DN}/MNL-1/MNLENT-1/FEATCADM-1
    Set Test Variable    ${scf_distName}    MRBTS-${mrbts_id}/MNL-1/MNLENT-1/FEATCADM-1
    ${no_rule_exist}=    Run Keyword And Return Status     Check Actual Configuration Parameters    dist_name=${mo_id}
    ...    preventParamModifList=&{EMPTY}
    Set Test Variable    ${no_rule_exist}
    Run Keyword If    '${no_rule_exist}'=='True'    Log    TC parameters successfully checked    console=True
    ...    ELSE    Run Keywords    Log    TC parameters checking warning, already exist rules, will clean rules now
    ...    console=True    level=WARN
    ...    AND    Run Keyword And Continue On Failure    Clean Existing Restriction Rule

Step ${index}: Check ${when} BTS state
    [Documentation]    BTS each RAT procedural state is checked to be OnAir (at least one cell operational)
    ...    BTS State is checked according to ute_admin get parameters for all BTS. The JSON returned contains informations
    ...    such as btsName, btsId, btsProceduralstate
    ...    KW checks if BTS State is onAir. If not, it will fail with received state.
    Log    Step ${index}: Check ${when} BTS state    console=True
    Wait Until Keyword Succeeds    3 min    10 sec    Check BTS RAT Procedural State
    Admin Check Overall BTS Procedural State TAF

Step ${index}: Check ${when} alarms status from WebEM
    Log    Step ${index}: Check ${when} alarms status from WebEM    console=True
    Get and Check Alarms SyVe    source=Bts    expected_alarms=@{EMPTY}    ignored_alarms=${IGNORED_ALARMS}
    ...    critical_alarms=${CRITICAL_ALARMS}

Step ${index}: Check ${when} alarms status from Netact
    Log    Step ${index}: Check ${when} alarms status from Netact    console=True
    Get and Check Alarms SyVe    source=Netact    expected_alarms=@{EMPTY}    ignored_alarms=${IGNORED_ALARMS}
    ...    critical_alarms=${CRITICAL_ALARMS}    dist_name=${MRBTS_DN}

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]    Check if number of configured cells and radio modules in SCF are properly mapped on BTS running view.
    ...    Check operational states for cells and radio modules
    Log    Step ${index}: Check final number and state of Cells and RMs    console=True
    Final Checks SyVe

Step ${index}: Upload configuration status
    [Documentation]    Uploads configuration data from the network is checked
    Log    Step ${index}: Upload configuration status    console=True
    NetAct CM Upload    dist_names=${MRBTS_DN}

Step ${index}: Create And Edit Plan With Restriction Rule
    [Documentation]    Create and edit plan SyVe based on selected PLAN_x define in netact_plan.yaml
    Log    Step ${index}: Create And Edit Plan With Restriction Rule    console=True
    ${year}    ${month}    ${day}    ${hour}    ${min}    ${sec}=    Get Time    format=year,month,day,hour,min,sec
    ${timestamp}=    Set Variable    ${year}-${month}-${day}_${hour}-${min}-${sec}
    Should Be String    MRBTS-${mrbts_id}_${timestamp}
    Set Test Variable    ${create_rule_plan_name}    CB006530_Create_Prevent_Rule_MRBTS-${mrbts_id}_${timestamp}
    # e.g. preventParamModifList= WNCEL-actEirpControl    WNCEL-picPool
    # preventParamModifTargetDN=MRBTS-1818/WNBTS-1/WNCEL-19191
    ${prevent_param_dn_dic}    Run Keyword If    len(${selected_cell_dn})!=0    Create Dictionary
    ...    preventParamModifList=${selected_parameters_rules}    preventParamModifTargetDN=${selected_cell_dn}
    ...    ELSE    Create Dictionary    preventParamModifList=${selected_parameters_rules}
    ${plan}=    NetAct Create And Edit Plan    name=${create_rule_plan_name}    description=Automation SyVe for MRBTS-${mrbts_id}
    ...    mo_id=${mo_id}    scf_distName=${scf_distName}    &{prevent_param_dn_dic}
    Set Test Variable    ${plan}
    Set Test Variable    ${prevent_param_dn_dic}
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${create_rule_plan_name}.csv    dist_names=${MRBTS_DN}
    ...    plan_name=${create_rule_plan_name}    operation_type=plan

Step ${index}: Provision The Plan To Create Restriction Rule
    Log    Step ${index}: Provision The Plan To Create Restriction Rule    console=True
    NetAct Provision Plan    plan_name=${create_rule_plan_name}    dist_names=${MRBTS_DN}
    ...   backup_plan_name=${create_rule_plan_name}_backup    create_backup_plan=True    provisioning_operation=activate

Provision The Plan And Verify Message
    Log    Provision The Plan And Verify Message    console=True
    ${status}    ${message}    Run Keyword And Ignore Error    netact.Provision Plan    plan_name=${create_rule_with_param_modify_plan_name}
    ...    dist_names=${MRBTS_DN}    backup_plan_name=None
    ...    create_backup_plan=False    provisioning_operation=activate
    Run Keyword If    '${cnt_param_exist_in_rule}'=='1' and '${cnt_dn_exist_in_rule}'=='1'   Verify Provision Fail
    ...   ${status}    ${message}
    ...    ELSE    Run Keywords    Verify Provision Success    ${status}    ${message}
    ...    AND    NetAct Check Actual Configuration Parameters    dist_name=PLMN-PLMN/${${remove_rule_type}_dn_to_set}    &{param_dic}

Verify Provision Success
    [Arguments]    ${status}    ${message}
    Should Be True    '${status}'=='PASS'
    Should Contain    ${message}    5G/LTE/SRAN plan provision finished
    Should Contain    ${message}    The operation was successfully completed

Verify Provision Fail
    [Arguments]    ${status}    ${message}
    Should Be True    '${status}'=='FAIL'
    Should Contain    ${message}    5G/LTE/SRAN plan provision failed
    ${type_param}    Set Variable    ${selected_${remove_rule_type}_parameter_to_modify}
    ${param}    Fetch From Right    ${type_param}    -
    ${formatted_param}    Convert To String    ${param}
    ${formatted_type}     Fetch From Right    ${${remove_rule_type}_dn_to_set}    /
    Log    Modification of restricted parameter ${formatted_type}-${formatted_param} is not allowed
    Should Contain   ${message}    Modification of restricted parameter ${formatted_type}-\[${formatted_param}\] is not allowed

Step ${index}: Check Restriction Rule Parameters From NetAct
    Log    Step ${index}: Check Restriction Rule Parameters From NetAct    console=True
    ${prevent_param_dn_dic}    Create Dictionary    preventParamModifList=${selected_parameters_rules}
    ...    preventParamModifTargetDN=${selected_cell_dn}
    Check Actual Configuration Parameters    dist_name=${mo_id}    &{prevent_param_dn_dic}

Step ${index}: Provision the backup plan
    Log    Step ${index}: Provision the backup plan    console=True
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${create_rule_plan_name}_backup.csv
    ...    dist_names=${MRBTS_DN}    plan_name=${create_rule_plan_name}_backup    operation_type=plan
    NetAct Provision Plan    plan_name=${create_rule_plan_name}_backup    dist_names=${MRBTS_DN}    backup_plan_name=None
    ...    create_backup_plan=False    provisioning_operation=activate

Step ${index}: Generate Random Restriction Rule For All Cell MO
    Log    Step ${index}: Generate Random Restriction Rule For All Cell MO    console=True
    Generate Rule Data From Json
    ${selected_parameters_rules}    Create List
    ${all_rules_list}    Create List
    Set Test Variable    ${all_rules_list}
    Set Test Variable    ${selected_parameters_rules}
    Generate Random DN Rule
    FOR    ${type}    IN    @{all_mo_type}
         Run Keyword If    ${ALL_${type}_DN}    Run Keywords    Generate All Restriction Rules    ${type}    ${all_rules_list}
         ...    AND    Generate Random Restriction Rule For ${type}
    END

Step ${index}: Create And Provision Plan To Remove Rule With Param Modified
    Log    Step ${index}: Create And Provision Plan To Remove Rule With Param Modified    console=True
    Create NetAct Plan With Selected Rule Removed And Param Update
    Provision The Plan And Verify Message
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${create_rule_with_param_modify_plan_name}

Clean Existing Restriction Rule
    ${year}    ${month}    ${day}    ${hour}    ${min}    ${sec}=    Get Time    format=year,month,day,hour,min,sec
    ${timestamp}=    Set Variable    ${year}-${month}-${day}_${hour}-${min}-${sec}
    Should Be String    MRBTS-${mrbts_id}_${timestamp}
    Set Test Variable    ${clean_rules}    CB006530_Clean_Prevent_Rule_MRBTS-${mrbts_id}_${timestamp}
    ${param_dic_emtpy}    Create Dictionary    preventParamModifList=${EMPTY}    preventParamModifTargetDN=${EMPTY}
    ${delete_rule_plan}=    NetAct Create And Edit Plan    name=${clean_rules}
    ...    description=Automation SyVe for MRBTS-${mrbts_id}    mo_id=${mo_id}    scf_distName=${scf_distName}
    ...    &{param_dic_emtpy}
    NetAct Provision Plan    plan_name=${clean_rules}    dist_names=${MRBTS_DN}    backup_plan_name=None
    ...    create_backup_plan=False    provisioning_operation=activate

Generate Random DN Rule
    ${selected_cell_dn}    Create List
    Set Test Variable    ${selected_cell_dn}
    Generate Cells DN List By RAT
    FOR    ${type}    IN    @{all_mo_type}
         ${selected_dn}    Run Keyword If   ${ALL_${type}_DN}    Generate Random DN For ${ALL_${type}_DN}
         Set Test Variable    ${selected_${type}_dn}    ${selected_dn}
    END

Generate All Restriction Rules
    [Arguments]     ${type}    ${all_rules_list}
    FOR    ${item}    IN    @{${type}_rule_list}
        Append To List    ${all_rules_list}    ${item}
    END

Generate Random Restriction Rule For ${tech}
    ${rule_num}    Get Length     ${${tech}_rule_list}
    ${max_num}    Set Variable If    ${rule_num}>9    9    ${rule_num}
    ${rule_count}    Evaluate    random.randint(1, ${max_num})    modules=random, sys
    ${selected_param_rule_for_tech}    Create List
    FOR    ${step}    IN RANGE    1    ${rule_count+1}
        ${selected_rule}    Evaluate    random.choice(${${tech}_rule_list})    modules=random, sys
        Append To List    ${selected_parameters_rules}    ${selected_rule}
        Append To List    ${selected_param_rule_for_tech}    ${selected_rule}
        Remove Values From List    ${${tech}_rule_list}    ${selected_rule}
        Remove Values From List     ${all_rules_list}    ${selected_rule}
    END
    Set Test Variable    ${${tech}_selected_parameters_rules}    ${selected_param_rule_for_tech}

Generate Random DN For ${tech_cells_dn}
    ${selected_dn}    Set Variable    ${EMPTY}
    ${rule_count}    Evaluate    random.randint(0, 1)    modules=random, sys
    FOR    ${step}    IN RANGE    1    ${rule_count+1}
        ${selected_dn}    Evaluate    random.choice(${tech_cells_dn})    modules=random, sys
        Append To List     ${selected_cell_dn}    ${selected_dn}
    END
    [Return]    ${selected_dn}

Generate Rule Data From Json
    ${file_content}    OperatingSystem.Get File    ${TEST_DATA_FILE}
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

Generate Cells DN List By RAT
    FOR    ${type}    IN    @{all_mo_type}
        ${status}    Run Keyword And Return Status    Should Not Contain    ${type}    _
        Run Keyword If    ${status}    Get Non FDD TDD DN    ${type}
        Run Keyword If    '${type}'=='LNCEL_FDD'    Get FDD TDD DN    ${type}    NOKLTE:LNCEL_FDD
        Run Keyword If    '${type}'=='LNCEL_TDD'    Get FDD TDD DN    ${type}    NOKLTE:LNCEL_TDD
        Run Keyword If    '${type}'=='NRCELL_FDD'    Get FDD TDD DN    ${type}    com.nokia.srbts.nrbts:NRCELL_FDD
    END

Get Non FDD TDD DN
     [Arguments]    ${type}
     ${rat_type}    Set Variable If
     ...    '${type}'=='GNCEL'    GSM
     ...    '${type}'=='WNCEL'    WCDMA
     ...    '${type}'=='LNCEL'    LTE
     ...    '${type}'=='NRCELL'    NRBTS
     ${dn}    Get Cells DN For ${rat_type}
     Set Test Variable    ${ALL_${type}_DN}    ${dn}

Get FDD TDD DN
    [Arguments]   ${type}    ${class_name}
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${BTS_scf_content}=    coam.Get SCF
    ${scf_xml}=    L_XML.Parse Xml    ${BTS_scf_content}
    ${xml_elements}=    L_XML.Get Elements    ${scf_xml}    .//managedObject[contains(@class,"${class_name}")]
    ${dn}    Create List
    FOR    ${obj}    IN    @{xml_elements}
        ${obj_dn}    L_XML.Get Element Attribute    ${obj}    distName
        Append To List    ${dn}    ${obj_dn}
    END
    Set Test Variable    ${ALL_${type}_DN}    ${dn}

Get Cells DN For ${tech}
    ${cells_dn_mapping}    Fetch ID Mapping From Admin For Cells    ${tech}
    ${cells_dn}    Create List
    FOR    ${item}    IN     @{cells_dn_mapping}
        ${dn}    Get From Dictionary    ${item}    configuration
        Append To List    ${cells_dn}    ${dn}
    END
    [Return]    ${cells_dn}

Create NetAct Plan With Selected Rule Removed And Param Update
    ${remove_rule}     Evaluate    random.choice(${selected_parameters_rules})    modules=random, sys
    ${remove_rule_type}    Fetch From Left    ${remove_rule}    -
    ${origin_param}    Fetch From Right    ${remove_rule}    -
    ${sub_param}    Fetch From Right    ${origin_param}    .
    ${value_list}    Set Variable    ${${remove_rule_type}_parameters_pool["${origin_param}"]}
    ${dn_to_set}    Evaluate    random.choice(${ALL_${remove_rule_type}_DN})    modules=random, sys
    Remove Values From List    ${selected_parameters_rules}     ${remove_rule}
    Remove Values From List    ${${remove_rule_type}_selected_parameters_rules}    ${remove_rule}
    Set Test Variable    ${remove_rule_type}
    Set Test Variable    ${${remove_rule_type}_dn_to_set}    ${dn_to_set}
    Set Test Variable    ${selected_${remove_rule_type}_parameter_to_modify}    ${remove_rule}

    ${status}    ${target_param}    Run Keyword And Ignore Error    Get From Dictionary
    ...    ${${remove_rule_type}_special_param_mapping}    ${origin_param}
    ${converted_param}    Set Variable If    '${status}'=='PASS'    ${target_param}    ${sub_param}
    # Parameter need value:
    Run Keyword If    len(${value_list})!=0    Get Param And Value For Primary Parameter   ${dn_to_set}
    ...    ${origin_param}    ${converted_param}    ${value_list}
    # Parameter is structure and no need value:
    ...    ELSE    Get Param And Value For Sub Parameter    ${dn_to_set}    ${origin_param}

    ${year}    ${month}    ${day}    ${hour}    ${min}    ${sec}=    Get Time    format=year,month,day,hour,min,sec
    ${timestamp}=    Set Variable    ${year}-${month}-${day}_${hour}-${min}-${sec}
    Should Be String    MRBTS-${mrbts_id}_${timestamp}
    Set Test Variable    ${create_rule_with_param_modify_plan_name}
    ...    CB006530_Create_New_Prevent_Rule_With_Param_Update_MRBTS-${mrbts_id}_${timestamp}

    # e.g. No restriction DN about LNCEL exist, remove LNCEL-paramxx and modify paramxx under LNCEL-1
    # -> modify paramxx under LNCEL-x suceess
    #      LNCEL-x is DN restricted (rule LNCEL-paramxxx2 is exist), remove LNCEL-paramxx and modify paramxx under LNCEL-1
    # -> modify paramxx under LNCEL-x success
    #      LNCEL-x is DN restricted (no any other LNCEL rule exist), remove LNCEL-paramxx and modify paramxx under LNCEL-x
    # -> Should remove LNCEL-x DN also,  modify paramxx under LNCEL-x success
    #      The parent param is still in the rule list, remove LNCEL-parent.paramxx and modify paramxx under LNCEL-x
    # ->  modify parent.paramxx under is not allowed
    #      the child param is still in the rule list,  LNCEL-parent is remove from rule list,
    # the selected to modify param is the child param ->  modify parent.paramxx under is not allowed

    Run Keyword If    len(${${remove_rule_type}_selected_parameters_rules})==0
    ...    Remove Values From List    ${selected_cell_dn}    ${selected_${remove_rule_type}_dn}
    ${new_rule_dic}    Run Keyword If    len(${${remove_rule_type}_selected_parameters_rules})==0
    ...    Create Dictionary    preventParamModifList=${selected_parameters_rules}    preventParamModifTargetDN=${selected_cell_dn}
    ...    ELSE    Create Dictionary    preventParamModifList=${selected_parameters_rules}

    ${new_plan}    NetAct Create And Edit Plan    name=${create_rule_with_param_modify_plan_name}
    ...    description=Automation SyVe for MRBTS-${mrbts_id}    mo_id=${mo_id}    scf_distName=${scf_distName}    &{new_rule_dic}
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}    L_XML.Parse xml    ${BTS_scf_initial}
    ${MO_items}    L_XML.Get Element Attributes    ${scf_xml}    .//managedObject[@distName="${dn_to_set}"]
    netact.Create Managed Object    plan=${new_plan}    meta_class=${MO_items['class']}    meta_version=${MO_items['version']}
    ...    mo_id=PLMN-PLMN/${dn_to_set}    &{param_dic}
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${create_rule_with_param_modify_plan_name}.csv
    ...    dist_names=${MRBTS_DN}    plan_name=${create_rule_with_param_modify_plan_name}    operation_type=plan

Get Param And Value For Primary Parameter
     [Arguments]    ${dn}    ${origin_param}    ${converted_param}    ${value_list}
     ${cnt_true}    Count Values In List    ${value_list}    true
     ${cnt_false}    Count Values In List    ${value_list}    false
     ${ui_value}    Set Variable If    ${cnt_true}!=0 or ${cnt_false}!=0    true    false
     ${value}    Random Select Value For Parameter    ${dn}    ${converted_param}    ${value_list}
     ${param_dic}     Create Dictionary    ${converted_param}=${value}
     Set Test Variable    ${param_dic}
     ${parent_param}    Fetch From Left    ${origin_param}    .
     ${cnt_param_exist_in_rule}    Run Keyword If    '${parent_param}'!='${origin_param}'    Count Values In List
     ...    ${selected_parameters_rules}    ${remove_rule_type}-${parent_param}
     ...    ELSE    Set Variable    0
     Set Test Variable    ${cnt_param_exist_in_rule}
     ${cnt_dn_exist_in_rule}    Run Keyword If    '${parent_param}'!='${origin_param}' and len(${selected_cell_dn})!=0
     ...    Count Values In List    ${selected_cell_dn}    ${dn}
     ...    ELSE IF     len(${selected_cell_dn})==0    Set Variable    1
     ...    ELSE    Set Variable    0
     Set Test Variable    ${cnt_dn_exist_in_rule}

Get Param And Value For Sub Parameter
     [Arguments]     ${dn}    ${origin_param}
     ${sub_param_list}     Get From Dictionary    ${${remove_rule_type}_relation_mapping}    ${origin_param}
     ${random_param}    Evaluate    random.choice(${sub_param_list})    modules=random, sys
     ${value_list}     Set Variable    ${${remove_rule_type}_parameters_pool["${origin_param}.${random_param}"]}
     ${cnt_true}    Count Values In List    ${value_list}    true
     ${cnt_false}    Count Values In List    ${value_list}    false
     ${ui_value}    Set Variable If    ${cnt_true}!=0 or ${cnt_false}!=0    true    false
     ${status}    ${target_param}    Run Keyword And Ignore Error    Get From Dictionary
     ...    ${${remove_rule_type}_special_param_mapping}    ${origin_param}.${random_param}
     ${converted_param}    Set Variable If    '${status}'=='PASS'    ${target_param}    ${random_param}
     ${value}    Random Select Value For Parameter    ${dn}    ${converted_param}    ${value_list}
     ${param_dic}     Create Dictionary    ${converted_param}=${value}
     Set Test Variable    ${param_dic}
     Remove Values From List     ${selected_parameters_rules}    ${remove_rule_type}-${origin_param}.${random_param}
     ${cnt_param_exist_in_rule}     Count Values In List    ${selected_parameters_rules}
     ...    ${remove_rule_type}-${origin_param}.${random_param}
     Set Test Variable    ${cnt_param_exist_in_rule}
     ${cnt_dn_exist_in_rule}     Run Keyword If    len(${selected_cell_dn})!=0    Count Values In List
     ...    ${selected_cell_dn}    ${dn}
     ...    ELSE    Set Variable    1
     Set Test Variable    ${cnt_dn_exist_in_rule}

Random Select Value For Parameter
     [Arguments]    ${dn}    ${param}    ${value_list}    ${ui_value}=false
     # a: current  parameter is not empty in system. remove current value from value list and random select 1 value from the left
     ${status}    ${current_value}    Run Keyword And Ignore Error    Get Actual Parameter Value From NetAct
     ...    PLMN-PLMN/${dn}    ${param}    ${ui_value}
     Run Keyword If     '${status}' == 'PASS'    Remove Values From List    ${value_list}    ${current_value}
     ### b: current  parameter is not set in system. random select 1 value from value list
     ${value}    Evaluate    random.choice(${value_list})    modules=random, sys
     [Return]    ${value}

Particular Teardown
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${create_rule_plan_name}
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${create_rule_plan_name}_backup
    ${actual_rule}=    Run Keyword And Return Status    Check Actual Configuration Parameters    dist_name=${mo_id}
    ...    preventParamModifList=&{EMPTY}
    Run Keyword If   '${actual_rule}'=='False'    Run Keywords    Log
    ...  Parameters were not reset to initial values! Probably backup plan was not provisioned! Will perform commissioning with initial scf!
    ...  level=WARN
    ...    AND    coam.Perform Commissioning    bts_id=${mrbts_id}
    ...    scf_file=${BTS_scf_initial}
    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=400
    ...    AND    Wait Until Keyword Succeeds    20 min    30 sec    Check SBTS SMOD RMOD Cells Alarms
    Common Test Teardown

TC Setup
    Common Test Setup

TC Teardown
    Particular Teardown