*** Settings ***
Documentation
...    Author: Michal Lys, Jakub Klein
...    Maintainer: Michal Lys, Jakub Klein
...    Group in charge: 5G_PZ_1_WRO_6_SG
...    This group of keywords are related with checking state of components.
...    Availiable keywords:
...    Check if BTS is on OnAir state
...    Check if BTS is ready for commisioning   ${connection}
...    Check specific status on selected component    ${component_name}     ${dictionary_parameter_value}
...    Check Component Status In Infomodel    ${path_to_im_object}    ${parameter_with_status}  ${connection}
...    --------------------------
...    Example usage of keywords:
...    ${expected_statuses}    Create dictionary    operationalState=Enabled  availabilityStatus=Online  administrativeState=Unlocked
...    ${path_to_component}    Set Variable   /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/NRBTS_R-50340/NRCELL_R-1
...    ${exclude_component_list}   Create list   RMOD-2/SFP-OPT_IF2
...    Check Component Status In Infomodel        ${path_to_component}    ${expected_statuses}  ${connection}
...    Check specific status on selected component  RMOD_R-1              ${expected_statuses}  ${connection}
...    Check specific status on selected component  RMOD-All              ${expected_statuses}  ${connection}
...    Check specific status on selected component  RMOD_R-1/SFP-OPT_IF2  ${expected_statuses}  ${connection}
...    Check specific status on selected component  RMOD-ALL/SFP_R-alL    ${expected_statuses}   ${exclude_component_list}  ${connection}
...    ${exclude_component_list}   Create list   NRCELL-1  NRCELL-5
...    Check specific status on selected component  NRCELL-All            ${expected_statuses}   ${exclude_component_list}  ${connection}
...    WIP: Check if BTS is on OnAir state   ${exclude_component_list}    #${exclude_component_list} only:SMOD, BBMOD, RMOD, NRCELL and can't be All

Library     taf.sbts.oam.coam.admin   WITH NAME   admin_cli
Variables   component_states_variables.py

*** Variables ***
@{special_MOCs}=    SFP

*** Keywords ***
Check if BTS is OnAir state
    [Documentation]
    ...  This keyword check status for all basic BTS's objects: SMOD  BBMOD  RMOD NRCELL related with Onair state.
    ...  BTS should be configured before kw useage.
    ...  Kw allows provide optionaly parameter 'exclude_component_list' which status are not verified.
    [Arguments]    ${exclude_component_list}=@{EMPTY}    ${connection}=default
#    ${link_status}   run keyword and return status   admin_cli.check_link_status
#    run keyword unless  ${link_status}   admin_cli.connect_to
    ${bts_info_for_Check_if_BTS_is_OnAir_or_ready_for_commisioning}    admin_cli.get_bts_info   connection=${connection}
    Set suite variable    ${bts_info_for_Check_if_BTS_is_OnAir_or_ready_for_commisioning}
#    ${is_not_EMPTY}    run keyword and return status    Should be true   ${exclude_component_list}
    ${is_EMPTY}    run keyword and return status    Should be empty   ${exclude_component_list}
    ${exclude_component_dict}  Run keyword if  ${is_EMPTY}   Create dictionary   SMOD=[]  BBMOD=[]  RMOD=[]  NRCELL=[]
    ...   ELSE    Sort exclude component list  ${exclude_component_list}    ${connection}
    &{expected_status}    create dictionary    availabilityStatus=online    operationalState=enabled    administrativeState=unlocked
    ${is_SMOD_ok}    run keyword and return status
    ...              Check specific status on selected component     SMOD_R-all    ${expected_status}   ${exclude_component_dict}[SMOD]
    ...              ${connection}
    ${is_BBMOD_ok}   run keyword and return status
    ...              Check specific status on selected component    BBMOD_R-all    ${expected_status}   ${exclude_component_dict}[BBMOD]
    ...              ${connection}
    ${is_RMOD_ok}    run keyword and return status
    ...              Check specific status on selected component     RMOD_R-all    ${expected_status}   ${exclude_component_dict}[RMOD]
    ...              ${connection}
    ${is_NRCELL_ok}  run keyword and return status
    ...              Check specific status on selected component   NRCELL_R-all    ${expected_status}   ${exclude_component_dict}[NRCELL]
    ...              ${connection}
    FOR  ${moc}  IN  SMOD_R  BBMOD_R  RMOD_R  NRCELL_R
        admin_cli.get_managed_objects   ${moc}  connection=${connection}
    END
    ${smod_name}  Get SMOD product name     ${connection}
    Run keyword if  '${smod_name}'!='ASOE'  Should be true   ${is_SMOD_ok} and ${is_BBMOD_ok} and ${is_RMOD_ok} and ${is_NRCELL_ok}
    ...  ELSE                               Should be true   ${is_SMOD_ok} and ${is_RMOD_ok} and ${is_NRCELL_ok}
    [Teardown]  Set suite variable  ${bts_info_for_Check_if_BTS_is_OnAir_or_ready_for_commisioning}  ${EMPTY}
#    [Teardown]  Run keywords  Set suite variable  ${bts_info_for_Check_if_BTS_is_OnAir_or_ready_for_commisioning}  ${EMPTY}  AND
#    ...                       run keyword unless  ${link_status}  admin_cli.teardown

Sort exclude component list
    [Documentation]
    ...  The keyword sort exclude component list
    [Arguments]     ${exclude_component_list}   ${connection}=default
    ${exclude_obj_splited_list}=   Create List
    FOR  ${exclude_obj}  IN  @{exclude_component_list}
        ${exclude_obj}          convert to uppercase    ${exclude_obj}
        ${exclude_split_list}   Split String	        ${exclude_obj}    /
        append to list    ${exclude_obj_splited_list}   ${exclude_split_list}
    END
    ${combine_DN_list}   Collect exclude objects DN list   ${exclude_obj_splited_list}  ${connection}
    ${exclude_DN_component_list}  Get DNs Belong To Exclude Modules  ${combine_DN_list}     ${connection}
    ${exclude_component_dict}  Divide DNs for modules   ${exclude_DN_component_list}
    [Return]    ${exclude_component_dict}

Divide DNs for modules
    [Documentation]    Keyword split DNs for modules.
    [Arguments]    ${exclude_DN_component_list}
    ${smod_list}    Create list
    ${bbmod_list}   Create list
    ${rmod_list}    Create list
    ${nrcell_list}  Create list
    ${exclude_obj_dict}  Create dictionary
    FOR  ${dn}  IN   @{exclude_DN_component_list}
        ${obj}    Fetch from right      ${dn}     /
        ${moc}    Get Regexp Matches    ${obj}    ^[A-Z]+
        Run keyword if  '${moc}[0]'=='SMOD'     Append To List  ${smod_list}    ${obj}
        ...  ELSE IF       '${moc}[0]'=='BBMOD'    Append To List  ${bbmod_list}   ${obj}
        ...  ELSE IF       '${moc}[0]'=='RMOD'     Append To List  ${rmod_list}    ${obj}
        ...  ELSE IF       '${moc}[0]'=='NRCELL'   Append To List  ${nrcell_list}  ${obj}
        ...  ELSE          Fail   msg=Module '${moc}[0]' is not supported in kw "Check if BTS is on OnAir state" .
    END
    Set To Dictionary	${exclude_obj_dict}	  SMOD=${smod_list}  BBMOD=${bbmod_list}  RMOD=${rmod_list}  NRCELL=${nrcell_list}
    [Return]    ${exclude_obj_dict}

Check if BTS is ready for commisioning
    [Documentation]
    ...  The keyword check status of BTS for commisioning.
    ...  This mean all SMOD's and BBMOD's are green and ready for load configuration.
    [Arguments]     ${connection}=default
#    ${link_status}   run keyword and return status   admin_cli.check_link_status
#    run keyword unless  ${link_status}   admin_cli.connect_to
    ${bts_info_for_Check_if_BTS_is_OnAir_or_ready_for_commisioning}    admin_cli.get_bts_info   connection=${connection}
    Set suite variable    ${bts_info_for_Check_if_BTS_is_OnAir_or_ready_for_commisioning}
    &{expected_status}    create dictionary   availabilityStatus=online    operationalState=enabled    administrativeState=unlocked
    ${is_SMOD_ok}    run keyword and return status    Check specific status on selected component     SMOD_R-all    ${expected_status}  ${connection}
    ${is_BBMOD_ok}   run keyword and return status    Check specific status on selected component    BBMOD_R-all    ${expected_status}  ${connection}
    FOR  ${moc}  IN  SMOD_R  BBMOD_R
        admin_cli.get_managed_objects   ${moc}  connection=${connection}
    END
    ${smod_name}     Get SMOD product name  ${connection}
    Run keyword if  '${smod_name}'!='ASOE'  Should be true   ${is_SMOD_ok} and ${is_BBMOD_ok}
    ...  ELSE                               Should be true   ${is_SMOD_ok}
    [Teardown]  Set suite variable  ${bts_info_for_Check_if_BTS_is_OnAir_or_ready_for_commisioning}  ${EMPTY}

Check specific status on selected component
    [Documentation]
    ...  Kw check specific status given as dictionary parameter_value for component e.g. RMOD or SMOD.
    ...  For special components like: '@{special_MOCs}' should be provided additional atributive object like RMOD, BBMOD e.g. BBMOD_R/SFP_R
    ...  Kw allows provide optionaly parameter 'exclude_component_list' which status are not verified.
    [Arguments]   ${object}     ${parameter_value}    ${exclude_component_list}=@{EMPTY}    ${connection}=default
#    ${link_status}   run keyword and return status   admin_cli.check_link_status
#    run keyword unless  ${link_status}   admin_cli.connect_to
    ${isSet_variable}    run keyword and return status    Should not be empty    ${bts_info_for_Check_if_BTS_is_OnAir_or_ready_for_commisioning}
    ${bts_info_for_check_specific_status}   run keyword if  ${isSet_variable}
    ...         Set variable  ${bts_info_for_Check_if_BTS_is_OnAir_or_ready_for_commisioning}
    ...  ELSE   admin_cli.get_bts_info  connection=${connection}
    Set Suite Variable    ${bts_info_for_check_specific_status}
    ${object_split_list}    ${exclude_object_split_list}    Precondition check    ${object}    ${parameter_value}    ${exclude_component_list}
    ${dn_internal_list}            Collect objects DN list            ${object_split_list}      ${connection}
    ${exclude_dn_internal_list}    Collect exclude objects DN list    ${exclude_object_split_list}  ${connection}
    Remove Values From List	  ${dn_internal_list}   @{exclude_dn_internal_list}
    ${isAnyObjToCheck}    run keyword and return status
    ...    Should not be empty    ${dn_internal_list}
    ...    msg=There is nothing to check for ${dn_internal_list}. Probably exclude obj arguments are too wide.
    Run keyword if  ${isAnyObjToCheck}    Verify finale check    ${dn_internal_list}   ${parameter_value}   ${connection}
#    ...  ELSE    Log   There is nothing to check for ${dn_internal_list}. Probably exclude obj arguments are too wide.   WARN
   [Teardown]    Set suite variable  ${bts_info_for_check_specific_status}  ${EMPTY}
#    [Teardown]  Run keyword unless    ${link_status}    admin_cli.teardown

Check Component Status In Infomodel
    [Documentation]    This keyword compare status of object in infomodel from given path with given status
    [Arguments]    ${path_to_im_object}    ${parameter_with_status}     ${connection}=default
    ${unexpected_status}=    Create Dictionary
    FOR    ${key}    IN    @{parameter_with_status.keys()}
        ${user_status}=    Convert User Data    ${parameter_with_status["${key}"]}
        Set Suite Variable    ${dictionary_with_supported_values}    ${common_statuses}[${key}]
        ${status_from_im}=    admin_cli.get parameters    ${path_to_im_object}    ${key}    connection=${connection}
        ${status_from_im}=    Check If Only stateInfo    ${status_from_im}
        ${supported_status}=    Get From Dictionary    ${dictionary_with_supported_values}    ${user_status}
	    ${status}=    Run Keyword And Return Status    List Should Contain Value    ${supported_status}    ${status_from_im["${key}"]}
	    Run Keyword If    '${status}'=='False'    Set To Dictionary    ${unexpected_status}    ${key}    ${status_from_im["${key}"]}
    END
    Return From Keyword If    ${unexpected_status}=={}    ${status}
    [Return]    ${unexpected_status}

###########################################################################################################

Collect objects DN list
    [Documentation]    Keyword collect runtime DN of object(s). \$\{proper_structure\} and \$\{special_MOCs\} are gets from variable.py
    [Arguments]    ${object_list}   ${connection}=default
    ${regex}    create list   ${EMPTY}
    FOR    ${obj}    IN    @{object_list}
        ${output}    fetch from left    ${obj}       -
        ${moc}       fetch from left    ${output}    _R
        dictionary should contain key    ${proper_structure}    ${moc}
        ...    msg=KW not support MOC:${moc} structure yet. Please add them to proper_structure of variables.
        ${is_special_obj}    run keyword and return status    should contain any    ${obj}    @{special_MOCs}
        ${id_internal_list}    Run keyword if    ${is_special_obj}
        ...            Find Special Object Id    ${regex}   ${obj}  ${connection}
        ...    ELSE    Find Object Id            ${regex}   ${obj}   ${proper_structure}[${moc}]
        ${regex}    set variable    ${id_internal_list}
    END
    [Return]   ${id_internal_list}

Find Object Id
    [Documentation]    Kw return runtime dn for object.
    [Arguments]   ${regex_list}    ${obj}    ${btsInfo_obj_structure}
    ${out_id_internal}    create list
    FOR   ${regex}    IN  @{regex_list}
        ${id_internal_list}    Loop over regex in Object Id    ${regex}    ${obj}    ${btsInfo_obj_structure}
        ${out_id_internal}    combine lists    ${out_id_internal}    ${id_internal_list}
    END
    [Return]    ${out_id_internal}

Loop over regex in Object Id
    [Documentation]    Kw return runtime dn for object. \$\{bts_info_for_check_specific_status\} is Suite a variable.
    [Arguments]   ${regex}    ${obj}    ${btsInfo_obj_structure}
    ${regex_match}    set variable    ${false}
    ${obj_Id_match}    set variable    ${false}
    ${is_runtime_obj}   Run keyword and return status   Should contain   ${obj}  _R
    ${id_internal_list}    create list
    ${obj_id}      fetch from right    ${obj}    -
    ${is_ALL}    run keyword and return status    should be equal    ${obj_id}    ALL
    ${isSet_variable}    run keyword and return status
    ...  Should not be empty    ${bts_info_for_Check_if_BTS_is_OnAir_or_ready_for_commisioning}
    run keyword if  ${isSet_variable}
    ...  Set suite variable  ${bts_info_for_check_specific_status}   ${bts_info_for_Check_if_BTS_is_OnAir_or_ready_for_commisioning}
    FOR   ${btsInfo_obj}    IN   @{bts_info_for_check_specific_status${btsInfo_obj_structure}}  #Suite Variable
        Log    ${is_runtime_obj}
        Log    ${btsInfo_obj}
        ${id_from_btsInfo}    Run Keyword If   ${is_runtime_obj}    fetch from right    ${btsInfo_obj}[id][internal]    -
        ...    ELSE    fetch from right    ${btsInfo_obj}[id][configuration]    -
        ${id_match}    run keyword and return status    should be equal    ${id_from_btsInfo}    ${obj_id}
        ${regex_match}    Run Keyword If   ${is_ALL}    append to list  ${id_internal_list}   ${btsInfo_obj}[id][internal]
        ...    ELSE IF    ${is_runtime_obj}    run keyword and return status    Should Contain Any    ${btsInfo_obj}[id][internal]   ${regex}
        ...    ELSE       run keyword and return status    Should Contain Any    ${btsInfo_obj}[id][configuration]    ${regex}
        Run Keyword If   ${regex_match} and ${id_match}    Run keywords
        ...    append to list  ${id_internal_list}   ${btsInfo_obj}[id][internal]    AND
        ...    exit for loop
    END
    should not be empty    ${id_internal_list}    msg=Cannot find object ${regex}${obj}.
    [Return]    ${id_internal_list}

Precondition check
    [Documentation]     The KW setup suite variable and check corrections of input KW parametes
    [Arguments]   ${object}    ${parameter_value}    ${exclude_object_list}
    ${object}                     convert to uppercase    ${object}
    ${object_split_list}=    Split String	  ${object}    /
    ${is_not_EMPTY}    run keyword and return status    Should be true   ${exclude_object_list}
    ${exclude_split_object_list}    run keyword if   ${is_not_EMPTY}    Validate exclude objects   ${object}    ${exclude_object_list}
    ...    ELSE     Create list   @{EMPTY}
    ${is_RNL_MOC}=    run keyword and return status    Should Contain Any	${object_list[-1]}	 LNCEL    CARRIERGROUPC    GNCEL    WNCEL
    ${RNL_msg}=    Catenate
    ...    for RNL MOCs, there is no equipment to be installed, so NotInstalled did not make any sense even before CNI-61110;
    ...    After the CNI-61110, if you have availability stautus missing ( or with None) it means that everything is ok
    ...    (equivalent with Online value before CNI-61110)
    ${items}=   Get Dictionary Items    ${parameter_value}
    FOR    ${key}    ${value}    IN    @{items}
        ${isApplicable}   run keyword and return status   should not contain any  ${value}    ${None}  NotInstalled   not installed
        Run keyword if  '${key}'=='availabilityStatus' and ${isApplicable} and ${is_RNL_MOC}    FAIL    msg=${RNL_msg}
    END
    ${is_special_obj}    run keyword and return status    should contain any    ${object_split_list}[0]     @{special_MOCs}
    Run keyword if    ${is_special_obj}   fail    msg=${object} object needs additional object e.g. SMOD, BBMOD, RMOD
    [Return]    ${object_split_list}    ${exclude_split_object_list}

Validate exclude objects
    [Documentation]    Kw validate if excluded object are same as search objects and return splited list of excluded objects.
    [Arguments]    ${object}   ${exclude_object_list}
    ${retrn_list}=   Create List
    ${object_split}=    Split String	  ${object}    /
    ${template_name_list}  Get object name   ${object_split}
    FOR  ${exclude_obj}  IN  @{exclude_object_list}
        ${exclude_obj}          convert to uppercase    ${exclude_obj}
        ${exclude_split_list}   Split String	        ${exclude_obj}    /
        ${exclude_name_list}    Get object name         ${exclude_split_list}
        lists should be equal   ${template_name_list}   ${exclude_name_list}   msg=KW arguments: 'object' and 'exclude objects' should be same.
        append to list    ${retrn_list}   ${exclude_split_list}
    END
    [Return]    ${retrn_list}

Get object name
    [Arguments]    ${object_list}
    ${name_list}=   Create List
    FOR  ${obj}  IN  @{object_list}
        ${obj_name}      fetch from left    ${obj}         -
        ${obj_name}      fetch from left    ${obj_name}    _R
        append to list   ${name_list}    ${obj_name}
    END
    [Return]    ${name_list}

Find Special Object Id
    [Documentation]    Kw return runtime dn for object.
    [Arguments]   ${regex_list}    ${obj}   ${connection}=default
    ${out_id_internal}    create list
    ${obj_id}      fetch from right    ${obj}         -
    ${obj_name}    fetch from left     ${obj}         -
    ${moc}         fetch from left     ${obj_name}    _R
    ${bts_managed_objects_list}   admin_cli.get_managed_objects    ${moc}_R     connection=${connection}
    FOR   ${regex}    IN  @{regex_list}
        ${id_internal_list}    loop over regex in Special Object Id    ${regex}   ${obj_name}   ${obj_id}   ${bts_managed_objects_list}
        ${out_id_internal}     combine lists    ${out_id_internal}    ${id_internal_list}
    END
    [Return]    ${out_id_internal}

Loop over regex in Special Object Id
    [Documentation]    Kw return runtime dn for special objects(like SFP), whitch need for cleary identifaction other objects e.g. RMOD/SFP
    [Arguments]    ${regex}    ${obj_name}   ${obj_id}   ${bts_managed_objects_list}
    ${is_runtime_obj}   Run keyword and return status   Should contain   ${obj_name}    _R
    ${id_internal_list}    create list
    FOR   ${mng_obj}   IN    @{bts_managed_objects_list}
        ${is_search_match}    Run Keyword If   '${obj_id}'=='ALL'
        ...            run keyword and return status    Should Contain    ${mng_obj}[distName]    ${regex}
        ...    ELSE IF    ${is_runtime_obj}
        ...            run keyword and return status    Should Contain    ${mng_obj}[distName]    ${regex}/${obj_name}-${obj_id}
        ...    ELSE    run keyword and return status    Run keywords
        ...            Should Contain    ${mng_obj}[distName]   ${regex}    AND
        ...            should be equal as strings    ${mng_obj}[parameters][physicalPort]   ${obj_id}
        Run Keyword If   ${is_search_match}    append to list    ${id_internal_list}   ${mng_obj}[distName]
        Run Keyword If   ${is_search_match} and '${obj_id}'!='ALL'   exit for loop
    END
    should not be empty    ${id_internal_list}
    ...  msg=Cannot find ${regex}/${obj_name}-${obj_id}. Check if ${obj_name}-${obj_id} exist or its special obj required determining pre-object.
    [Return]    ${id_internal_list}

Collect exclude objects DN list
    [Documentation]    Kw expect list of splited objects e.g. [[SMOD-1], [RMOD_R-1, SFP_R-2]]
    [Arguments]     ${exclude_split_object_list}    ${connection}=default
    ${exclude_dn_internal_list}  Create list
    FOR  ${exclude_object}  IN   @{exclude_split_object_list}
        ${dn_exclude_list}   Collect objects DN list    ${exclude_object}   ${connection}
        ${exclude_dn_internal_list}   Combine Lists   ${exclude_dn_internal_list}    ${dn_exclude_list}
    END
    [Return]        ${exclude_dn_internal_list}

Verify finale check
    [Documentation]    Kw verify statuses for objects lists
    [Arguments]     ${dn_internal_list}     ${parameter_value}  ${connection}=default
    ${object_R}    fetch from right    ${dn_internal_list}[0]    /
    ${object_R}    fetch from left     ${object_R}               -
    ${items}   Get Dictionary Items    ${parameter_value}
    ${tmp_parameter_value}=    create dictionary
    FOR    ${key}    ${value}    IN    @{items}
        ${value}    Set variable if    '${key}'=='availabilityStatus' and '${value}'=='${None}'    online    ${value}
        ${value}    Set variable if    '${key}'=='administrativeState' and '${value}'=='${None}'   notknown  ${value}
        ${value}    Set variable if    '${key}'=='usageState' and '${value}'=='${None}'            busy      ${value}
        ${is_CNI_61110_param}   run keyword and return status    dictionary should contain key   ${common_statuses}    ${key}
        ${value}    Run keyword if    ${is_CNI_61110_param}    convert to lowercase   ${value}
        ...  ELSE    Set variable    ${value}
        ${value}    Run keyword if    ${is_CNI_61110_param}    remove string    ${value}    ${SPACE}
        ...  ELSE    Set variable    ${value}
        set to dictionary    ${tmp_parameter_value}    ${key}=${value}
    END
    ${bts_managed_objects_list}  admin_cli.get_managed_objects  ${object_R}     connection=${connection}
    Should not be empty  ${bts_managed_objects_list}   msg=Managed_objects_list for ${object_R} is empty. Check if object exist.
    ${check_list}=  create list
    FOR    ${dn_internal}    IN    @{dn_internal_list}
        ${check_list}  Check object status over parameters  ${dn_internal}  ${parameter_value}  ${tmp_parameter_value}
        ...                                                 ${bts_managed_objects_list}  ${check_list}
    END
    FOR  ${item}  IN    @{check_list}
        ${status}  Fetch from right  ${item}   --
        Should be equal   ${status}   PASSED    msg=${item}
    END

Check object status over parameters
    [Arguments]    ${id_internal}    ${parameter_value}   ${tmp_parameter_value}   ${bts_managed_objects_list}   ${check_list}
    ${items}=   Get Dictionary Items    ${tmp_parameter_value}
    FOR    ${key}    ${value}    IN    @{items}
        ${out}    Check obj status    ${id_internal}    ${key}    ${value}  ${parameter_value}  ${bts_managed_objects_list}
        append to list    ${check_list}    ${out}
    END
    [Return]    ${check_list}

Check obj status
    [Documentation]    Kw check if expected object parameter value is in list of acepted values defined in "common_statuses" dictionary.
    [Arguments]   ${dn}    ${expect_param}    ${expect_value}  ${origin_param_value}   ${bts_managed_objects_list}
    ${is_object_exist}=    set variable    ${false}
    ${is_status_match}=    set variable    ${false}
    FOR  ${obj}  IN  @{bts_managed_objects_list}
        ${is_object_exist}     run keyword and return status    should be equal    ${obj}[distName]    ${dn}
        ${parameter_status}    run keyword if    ${is_object_exist}
        ...  Loop for check obj status  ${obj}    ${dn}    ${expect_param}    ${expect_value}  ${origin_param_value}   ${bts_managed_objects_list}
        run keyword if    ${is_object_exist}    exit for loop
    END
    [Return]    ${parameter_status}

Loop for check obj status
    [Documentation]    Kw is For loop for kw Check obj status
    [Arguments]  ${obj}   ${dn}    ${expect_param}    ${expect_value}  ${origin_param_value}   ${bts_managed_objects_list}
#    ${is_stateInfo_exist}   run keyword and return status    dictionary should contain key    ${obj}[parameters]    stateInfo
    ${is_parameter_in_parameters_exist}   run keyword and return status    Dictionary should contain key
    ...   ${obj}[parameters]  ${expect_param}             msg=Object doesn't contain '${expect_param}'-->:${obj}[parameters]
    ${is_parameter_in_stateInfo_exist}    run keyword and return status    Dictionary should contain key
    ...   ${obj}[parameters][stateInfo]  ${expect_param}  msg=Object doesn't contain '${expect_param}'-->:${obj}[parameters][stateInfo]
#    ${is_double_parameter_exist}  run keyword and return status
#    ...  Should not be equal  ${is_parameter_in_stateInfo_exist}  ${is_parameter_in_parameters_exist}
#    ...    msg=Parameter '${expect_param}' shoud not be duplicated in object structure
#    run keyword if   ${is_double_parameter_exist}    Log    Parameter '${expect_param}' shoud not be duplicated in object structure  WARN
    ${is_CNI_61110_param}   run keyword and return status    dictionary should contain key    ${common_statuses}   ${expect_param}
#    ${is_status_match_in_parameters}      Run Keyword If
    ${is_status_match}      Run Keyword If
    ...            ${is_parameter_in_parameters_exist} and ${is_CNI_61110_param}   run keyword and return status
    ...  List Should Contain Value  ${common_statuses}[${expect_param}][${expect_value}]    ${obj}[parameters][${expect_param}]
    ...  ELSE IF    ${is_parameter_in_parameters_exist} and ${is_CNI_61110_param}==${False}  run keyword and return status
    ...  Should be equal    ${expect_value}   ${obj}[parameters][${expect_param}]
#    ${is_status_match_in_stateInfo}      Run Keyword If
    ...  ELSE IF    ${is_parameter_in_stateInfo_exist} and ${is_CNI_61110_param}    run keyword and return status
    ...  List Should Contain Value  ${common_statuses}[${expect_param}][${expect_value}]    ${obj}[parameters][stateInfo][${expect_param}]
    ...  ELSE IF    ${is_parameter_in_stateInfo_exist} and ${is_CNI_61110_param}==${False}   run keyword and return status
    ...  Should be equal    ${expect_value}   ${obj}[parameters][stateInfo][${expect_param}]
    ...  ELSE   Set variable  ${False}

    ${parameter_status}   run keyword if
    ...             ${is_status_match} and ${is_parameter_in_parameters_exist}
    ...  Set variable
    ...  ${dn}:'${expect_param}'='${obj}[parameters][${expect_param}]'--Expected:'${origin_param_value}[${expect_param}]'--PASSED
    ...  ELSE IF    ${is_status_match}==${False} and ${is_parameter_in_parameters_exist}
    ...  Set variable
    ...  ${dn}:'${expect_param}'='${obj}[parameters][${expect_param}]'--Expected:'${origin_param_value}[${expect_param}]'--FALSE
    ...  ELSE IF    ${is_status_match} and ${is_parameter_in_stateInfo_exist}
    ...  Set variable
    ...  ${dn}:'${expect_param}'='${obj}[parameters][stateInfo][${expect_param}]'--Expected:'${origin_param_value}[${expect_param}]'--PASSED
    ...  ELSE IF    ${is_status_match}==${False} and ${is_parameter_in_stateInfo_exist}
    ...  Set variable
    ...  ${dn}:'${expect_param}'='${obj}[parameters][stateInfo][${expect_param}]'--Expected:'${origin_param_value}[${expect_param}]'--FALSE
    ...  ELSE   FAIL   msg=Component '${dn}' hasn't got '${expect_param}':'${expect_value}'.\nVerify expected status parameters
    [Return]    ${parameter_status}

Get SMOD product name
    [Documentation]    This keyword check SM product name
    [Arguments]     ${connection}=default
    ${smod_info}  admin_cli.get_managed_objects  SMOD_R     connection=${connection}
    ${smod_name}  Fetch from left  ${smod_info[0]}[parameters][productName]   ${SPACE}
    [Return]    ${smod_name}

Check If Only stateInfo
    [Documentation]    This keyword return new dictionary if statuses are given only under statInfo level
    [Arguments]    ${status_from_im}
    ${comparelist}=    Create List    stateInfo
    ${keylist}=    Get Dictionary keys    ${status_from_im}
    ${status}=    Run keyword and return status   Lists Should Be Equal  ${keylist}    ${comparelist}
    ${new_status_from_im}=    Run Keyword If    '${status}'=='True'    Convert to Dictionary    ${status_from_im["stateInfo"]}
    Return From Keyword If    '${status}'=='True'    ${new_status_from_im}
    [Return]    ${status_from_im}

Convert User Data
    [Documentation]    This keyword remove spaces in and change all upper case to lower case of status introduced by user
    [Arguments]  ${some_string}
    ${some_string}=    Remove String Using Regexp    ${some_string}  \\s
    ${some_string}=    Convert to lower case  ${some_string}
    [Return]  ${some_string}
######################kw taken from 470-159 need optymalization###################3

Get DNs Belong To Exclude Modules
    [Documentation]
    ...    Description: kw return distname tree for provided DNs
    [Arguments]  ${testing_component_dn_list}   ${connection}=default
    ${BTS_tree_list}  Create list
    FOR  ${item}  IN  @{testing_component_dn_list}
       ${tree_list}  Get DNs tree under BTS component   ${item}     ${connection}
       ${BTS_tree_list}  Combine Lists	${BTS_tree_list}  ${tree_list}
    END
    [Return]   ${BTS_tree_list}

Get DNs tree under BTS component
    [Documentation]
    ...    Description: kw return distname tree for provided obj DN
    [Arguments]  ${testing_component_dn}    ${connection}=default
    @{tree_list}  Create List  @{EMPTY}
    ${modul}   Fetch From Right   ${testing_component_dn}   /
    ${modul}   Fetch From Left  ${modul}   _
	${is_list}=     Evaluate     isinstance($testing_component_dn, list)
    Run Keyword Unless  ${is_list}   Set test variable   @{testing_component_dn}  ${testing_component_dn}

    @{BBMOD_list}  Run keyword if  '${modul}' == 'SMOD'
    ...  Get DNs tree under SMOD_BBMOD  ${testing_component_dn}     ${connection}
    @{RMOD_list}  Run keyword if  '${modul}' == 'SMOD'
    ...  Get DNs tree under SMOD_BBMOD  ${BBMOD_list}   ${connection}
    @{CELL_list}  Run keyword if  '${modul}' == 'SMOD'
    ...  Get DNs under RMOD  ${RMOD_list}   ${connection}
    @{tree_list_SMOD}  Run keyword if  '${modul}' == 'SMOD'
    ...  Combine Lists	${BBMOD_list}  ${RMOD_list}  ${CELL_list}  ${testing_component_dn}

    @{RMOD_list}  Run keyword if  '${modul}' == 'BBMOD'
    ...  Get DNs tree under SMOD_BBMOD  ${testing_component_dn}     ${connection}
    @{CELL_list}  Run keyword if  '${modul}' == 'BBMOD'
    ...  Get DNs under RMOD  ${RMOD_list}   ${connection}
    @{tree_list_BBMOD}  Run keyword if  '${modul}' == 'BBMOD'
    ...  Combine Lists	${RMOD_list}  ${CELL_list}  ${testing_component_dn}

    @{CELL_list}  Run keyword if  '${modul}' == 'RMOD'
    ...  Get DNs under RMOD  ${testing_component_dn}    ${connection}
    @{tree_list_RMOD}  Run keyword if  '${modul}' == 'RMOD'
    ...  Combine Lists	${CELL_list}  ${testing_component_dn}

    @{tree_list_NRCELL}  Run keyword if  '${modul}' == 'NRCELL'
    ...  Combine Lists	${testing_component_dn}

    ${tree_list}  Combine Lists	 ${tree_list}  ${tree_list_SMOD}  ${tree_list_BBMOD}  ${tree_list_RMOD}  ${tree_list_NRCELL}
    [Return]   ${tree_list}

Get DNs tree under SMOD_BBMOD
    [Documentation]
    ...    Description: kw return list of bbmod disNames belong to system module
    [Arguments]  ${testing_cp_dn_list}  ${connection}=default
    ${Cablink_statuses_response}  admin_cli.Get Managed Objects  CABLINK_R  connection=${connection}
    @{BBMOD_or_SMOD_list}  Create List	 @{EMPTY}
    FOR  ${cablink}  IN   @{Cablink_statuses_response}
       ${pass}  Run Keyword And Return Status  List Should Contain Value   ${testing_cp_dn_list}  ${cablink['parameters']['firstEndpointDN']}
       Run Keyword if  ${pass}   Append to List  ${BBMOD_or_SMOD_list}  ${cablink['parameters']['secondEndpointDN']}
    END
    [Return]   ${BBMOD_or_SMOD_list}

Get DNs under RMOD
    [Documentation]
    ...    Description: kw return list of cells disNames belong to rmod
    [Arguments]  ${testing_cp_dn_list}  ${connection}=default
    ${Cells_statuses_response}   admin_cli.get_cells_info   connection=${connection}
    @{CELL_list}  Create List	 @{EMPTY}
    FOR  ${item}  IN  @{Cells_statuses_response}
        ${output_c}   Fetch From Left   ${item['carrierList'][0]['antennaLineId']['internal']}   /ANTL_R-
        ${output_c}   Fetch From Left   ${output_c}   /PHYANT_R-
        ${pass}       Run Keyword And Return Status  List Should Contain Value   ${testing_cp_dn_list}  ${output_c}
        Run Keyword if    ${pass}   Append to List  ${CELL_list}  ${item['id']['internal']}
    END
    [Return]   ${CELL_list}
