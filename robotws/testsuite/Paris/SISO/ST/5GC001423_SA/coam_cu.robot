*** Settings ***
Documentation    This is for COAM CU Webem application, it's focus on webem operations with selenium
...              Please do not modify the file without notification to author
...              Author: Rashmi R
Library    taf.selenium.gnb.oam.coam.cu   WITH NAME   coam_cu

*** Keywords ***
Create cOAM CU session
    [Documentation]  Author: Rashmi R
    ...              Description: Login into coam cu WebEM as Web Element Manager.
    ...              param url: str, url to coam cu WebEM
    ...              param username: str, username
    ...              param password: str, password
    ...              param browser: str, Default browser will be "Chrome", if user wants it to run via from Firefox
    ...              then then change the browser parameter to "Firefox"
    ...              param timeout: int, timeout for the element be available to click
    [Arguments]    ${gnb_id}=0   ${browser}=Chrome    ${timeout}=60
    coam_cu.enable_virtual_display
    coam_cu.login   url=https://${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.addr}
    ...               username=${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.username}
    ...               password=${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.password}
    ...               browser=${browser}     timeout=${timeout}

Teardown cOAM CU session
    [Documentation]  Author: Rashmi R
    ...              Description: Logout from coam cu Webem
    ...              param timeout: int, timeout for the element be available to click
    [Arguments]    ${timeout}=60
    run keyword and ignore error        coam_cu.logout   timeout=${timeout}
    coam_cu.disable_virtual_display

Load cOAM CU Commissioning File And Check Load Status
    [Documentation]  Author: Rashmi R
    ...              Description: Keyword for loading commissioning file and check load status.
    ...              file_path: scf file path
    ...              plan_name: optional parameter, to edit the default plan name while loading scf
    ...              validate_plan: optional parameter, default value is "yes"
    ...              if user doesn't want to validate plan during load scf give validate plan as "no"
    ...              param timeout: int, timeout for the element be available to click
    [Arguments]    ${file_path}     ${plan_name}=${None}   ${validate_plan}=${None}    ${timeout}=60
    coam_cu.load_commissioning_file_and_check_load_status
    ...                    file_path=${file_path}
    ...                    plan_name=${plan_name}
    ...                    validate_plan=${validate_plan}
    ...                    timeout=${timeout}

Delete cOAM CU Plan
    [Documentation]    Author: Rashmi R
    ...                Description: Keyword for delete plan changes of Configuration page.
    ...                param timeout: int, timeout for the element be available to click
    [Arguments]     ${timeout}=60
    coam_cu.delete_plan    timeout=${timeout}

Validate cOAM CU Plan
    [Documentation]    Author: Rashmi R
    ...                Description: Keyword for validating plan of Configuration page.
    ...                param timeout: int, timeout for the element be available to click
    [Arguments]     ${timeout}=60
    coam_cu.validate_plan    timeout=${timeout}

Activate cOAM CU Plan
    [Documentation]    Author: Rashmi R
    ...                Description: Activate plan after loading scf file.
    ...                download_plan_without_activation: boolean, if False, download plan without
    ...                activation will not be selected, default False
    ...                activate_plan_despite_reset: boolean, if True, activate plan despite of reset will be
    ...                selected, default False
    ...                activate_plan_despite_cell_locking: boolean, if True, activate plan despite of
    ...                 cell locking will be selected, default False
    ...                param timeout: int, timeout for the element be available to click
    [Arguments]    ${download_plan_without_activation}=${None}   ${activate_plan_despite_reset}=${None}
    ...            ${activate_plan_despite_cell_locking}=${None}   ${timeout}=60
    coam_cu.activate_plan     ${download_plan_without_activation}
    ...                       ${activate_plan_despite_reset}
    ...                       ${activate_plan_despite_cell_locking}    timeout=${timeout}

Create cOAM CU Plan
    [Documentation]    Author: Rashmi R
    ...                Description: Keyword for Create plan to load scf file.
    ...                choose_plan: str, filename to create plan
    ...                plan_name: optional parameter, to edit the default plan name while loading scf
    ...                param timeout: int, timeout for the element be available to click
    [Arguments]    ${choose_plan}     ${plan_name}=${None}    ${timeout}=60
    coam_cu.create_plan     ${choose_plan}    ${plan_name}    timeout=${timeout}

Create cOAM CU Delta Plan
    [Documentation]    Author: Rashmi R
    ...                Description: Keyword for Create delta plan.
    ...                plan_name: optional parameter, to edit the default plan name while loading scf
    ...                param timeout: int, timeout for the element be available to click
    [Arguments]    ${plan_name}=${None}   ${timeout}=60
    Log    ${plan_name}
    coam_cu.create_delta_plan    timeout=${timeout}

Save cOAM CU Bts Configuration
    [Documentation]    Author: Rashmi R
    ...                Description: Keyword for saving bts configuration.
    ...                save_configuration_type: int, type of save bts configuration type
    ...                0: Save SCF - configuration only
    ...                1: Save delta SCF - delta configuration only
    ...                2: Save BTS runtime information only
    ...                param timeout: int, timeout for the element be available to click
    [Arguments]    ${save_configuration_type}=0
    coam_cu.save_bts_configuration    ${save_configuration_type}

cOAM CU Snapshot Collection Settings
    [Documentation]    Author: Rashmi R
    ...                Description: Keyword for setting snapshot collection in 'Snapshot' page.
    ...                coverage: str, only support "All logs" and "Most important log files"
    ...                save_location: str, only support "Local" and "Remote"
    ...                filter_by_regex: str, filter by Regex
    ...                notes: str, additional settings Notes
    [Arguments]    ${coverage}     ${save_location}    ${filter_by_regex}=${None}    ${notes}=${None}
    coam_cu.snapshot_collection_settings     ${coverage}
    ...             ${save_location}
    ...             ${filter_by_regex}    ${notes}

Collect cOAM CU Snapshot
    [Documentation]    Author: Rashmi R
    ...                Description: Keyword for clicking 'Collect Snapshot' button and download
    ...                snapshot file in 'Snapshot' page.
    ...                param timeout: int, timeout for the element be available to click
    [Arguments]     ${timeout}=1200
    coam_cu.collect_snapshot    snapshot_waiting_timeout=${timeout}

Change Local User Name For cOAM CU
    [Documentation]    Author: Rashmi R
    ...                Description: Keyword for changing the Local username in user account.
    ...                new_user_name: str, new use name to need to changed to
    ...                current_password: str, Current password of the local user
    [Arguments]    ${new_user_name}    ${current_password}
    coam_cu.change_local_user_name   ${new_user_name}    ${current_password}

Change Local Users Password For cOAM CU
    [Documentation]    Author: Rashmi R
    ...                Description: Keyword for changing the Local password in user account.
    ...                current_password: str, Current password of the local user
    ...                new_password: str, new password of the local user
    [Arguments]    ${current_password}    ${new_password}
    coam_cu.change_local_users_password   ${current_password}    ${new_password}

Change Local Users User Name And Password For cOAM CU
    [Documentation]    Author: Rashmi R
    ...                Description: Keyword for changing the Local username and password in user account.
    ...                new_user_name: str, new use name to need to changed to
    ...                current_password: str, Current password of the local user
    ...                new_password: str, new password of the local user
    [Arguments]    ${new_user_name}    ${current_password}   ${new_password}
    coam_cu.change_local_users_user_name_and_password   ${new_user_name}    ${current_password}   ${new_password}

Choose Plan For cOAM CU
    [Documentation]    Author: Rashmi R
    ...                Description: This keyword to choose the plan to be updated.
    ...                plan_name: str, plan that need to be selected
    ...                inactive_configurations:  boolean, if True, checks whether the plan is ready to be activated
    ...                selected, default False
    ...                param timeout: int, timeout for the element be available to click
    [Arguments]    ${plan_name}    ${inactive_configurations}=${None}    ${timeout}=60
    coam_cu.choose_plan    ${plan_name}     ${inactive_configurations}    timeout=${timeout}

Add cOAM CU Object
    [Documentation]    Author: Rashmi R
    ...                Description: Keyword to add new Model object to existing tree of  selected plan.
    ...                dist_name: Model object in which parameter need to removed
    ...                object_class_name : str, object class name of the new model object
    ...                is_load_default_values: bool, bool input to load default values or not
    ...                id_value: int id value of new object
    ...                param timeout: int, timeout for the element be available to click
    [Arguments]    ${dist_name}  ${object_class_name}  ${is_load_default_values}=${None}  ${id_value}=${None}
    ...            ${timeout}=60
    coam_cu.add_object    ${dist_name}    ${object_class_name}
    ...                   ${is_load_default_values}   ${id_value}    timeout=${timeout}

Remove cOAM CU Object
    [Documentation]    Author: Rashmi R
    ...                Description: Keyword to delete Model object from selected plan.
    ...                object_name: Model object in which parameter need to removed
    ...                param timeout: int, timeout for the element be available to click
    [Arguments]    ${object_name}    ${timeout}=60
    coam_cu.remove_object    ${object_name}     timeout=${timeout}

Get cOAM CU Parameter Value
    [Documentation]    Author: Rashmi R
    ...                Description: Keyword getting configured parameter values of given parameter in
    ...                selected Model object.
    ...                object_name: Model object in which parameter need to removed
    ...                filter_param: str, parameter name
    ...                abbreviation: str , abbreviation of the parameter
    ...                param timeout: int, timeout for the element be available to click
    [Arguments]    ${object_name}    ${filter_param}    ${abbreviation}=${None}    ${timeout}=60
    coam_cu.get_parameter_value    ${object_name}    ${filter_param}    ${abbreviation}    timeout=${timeout}

Set cOAM CU Parameter Value
    [Documentation]    Author: Rashmi R
    ...                Description: Keyword setting parameter values or editing existing parameter values
    ...                of given Model object.
    ...                object_name: Model object in which parameter need to removed
    ...                filter_param: str, parameter name
    ...                new_value : str, new value
    ...                abbreviation: str , abbreviation of the parameter
    ...                param timeout: int, timeout for the element be available to click
    [Arguments]    ${object_name}  ${filter_param}  ${new_value}=${None}  ${abbreviation}=${None}
    ...            ${timeout}=60
    coam_cu.set_parameter_value    ${object_name}    ${filter_param}
    ...                            ${new_value}    ${abbreviation}   timeout=${timeout}

Add cOAM CU Element
    [Documentation]    Author: Rashmi R
    ...                Description: Keyword for Adding structure in the parameter under given MO present
    ...                in the plan that has been selected.
    ...                object_name: Model object in which parameter need to removed
    ...                filter_param: str, parameter name
    ...                abbreviation: str , abbreviation of the parameter
    ...                param timeout: int, timeout for the element be available to click
    [Arguments]    ${object_name}    ${filter_param}    ${abbreviation}=${None}   ${timeout}=60
    coam_cu.add_element    ${object_name}    ${filter_param}    ${abbreviation}   timeout=${timeout}

Remove cOAM CU Element
    [Documentation]    Author: Rashmi R
    ...                Description: Keyword for deleting structure in the parameter under given MO present
    ...                in the plan that has been selected.
    ...                object_name: Model object in which parameter need to removed
    ...                filter_param: str, parameter name
    ...                abbreviation: str , abbreviation of the parameter
    ...                param timeout: int, timeout for the element be available to click
    [Arguments]    ${object_name}    ${filter_param}    ${abbreviation}=${None}    ${timeout}=60
    coam_cu.remove_element    ${object_name}    ${filter_param}    ${abbreviation}    timeout=${timeout}

Delete cOAM CU Parameter
    [Documentation]    Author: Rashmi R
    ...                Description: Keyword for deleting a parameter under given MO present in the
    ...                plan that has been selected.
    ...                object_name: Model object in which parameter need to removed
    ...                filter_param: str, parameter name
    ...                abbreviation: str , abbreviation of the parameter
    ...                param timeout: int, timeout for the element be available to click
    [Arguments]    ${object_name}    ${filter_param}    ${abbreviation}=${None}    ${timeout}=60
    coam_cu.delete_parameter    ${object_name}    ${filter_param}    ${abbreviation}    timeout=${timeout}

Get cOAM CU Active Alarm Info
    [Documentation]    Author: Rashmi R
    ...                Description: Keyword for getting active alarm information shown in Active Alarms page.
    ...                alarm_filter: str, default is None if no filter element input, all alarm info will be captured
    ...                param timeout: int, timeout for the element be available to click
    [Arguments]    ${alarm_filter}=${None}     ${timeout}=60
    coam_cu.get_active_alarm_info    ${alarm_filter}    timeout=${timeout}

Save cOAM CU Current Alarms
    [Documentation]    Author: Rashmi R
    ...                Description: Keyword for saving current alarms file.
    ...                alarm_filter: str, alarm filter
    [Arguments]    ${alarm_filter}=${None}
    coam_cu.save_current_alarms    ${alarm_filter}

Get cOAM CU History Alarm Info
    [Documentation]    Author: Rashmi R
    ...                Description: Keyword for getting history alarm information shown in Alarm History page.
    ...                alarm_filter: str, default is None if no filter element input, all alarm info will be captured
    ...                param timeout: int, timeout for the element be available to click
    [Arguments]    ${alarm_filter}=${None}     ${timeout}=60
    coam_cu.get_history_alarm_info    ${alarm_filter}     timeout=${timeout}

Save cOAM CU Historical Alarms
    [Documentation]    Author: Rashmi R
    ...                Description: Keyword for saving historical alarms file.
    ...                alarm_filter: str, alarm filter
    [Arguments]    ${alarm_filter}=${None}
    coam_cu.save_historical_alarms    ${alarm_filter}

Fix cOAM CU Errors
    [Documentation]    Author: Rashmi R
    ...                Description: keyword to fix erors in webem and return feedback.
    ...                param create_all_missing_mandatory_objects: boolean, if False, create all missing mandatory
    ...                objects will not be selected, default False
    ...                param create_all_missing_mandatory_parameters: boolean, if False, create all missing mandatory
    ...                parameters will not be selected, default False
    ...                param timeout: int, timeout for the element be available to click
    [Arguments]    ${create_all_missing_mandatory_objects}=${None}   ${create_all_missing_mandatory_parameters}=${None}
    ...            ${timeout}=60
    coam_cu.fix_errors    ${create_all_missing_mandatory_objects}    ${create_all_missing_mandatory_parameters}
    ...            timeout=${timeout}

Copy cOAM CU Object
    [Documentation]    Author: Rashmi R
    ...                Description: copy a object under the selected plan to different plan with given arguments
    ...                param object_name: str, where object will be added in
    ...                param object_class_name: str, name of object class
    ...                param plan_name: str, plan name that object to be copied
    ...                param object_distinguished_name: str, object_distinguished_name
    ...                param copy_object_with_subtree:Boolean , FOr copying subtree elements
    ...                param id_value: str, default is None
    ...                param timeout: int, timeout for the element be available to click
    [Arguments]    ${object_name}      ${object_class_name}    ${plan_name}     ${object_distinguished_name}
    ...            ${copy_object_with_subtree}=${None}    ${id_value}=${None}     ${timeout}=60
    coam_cu.copy_object    ${object_name}      ${object_class_name}    ${plan_name}     ${object_distinguished_name}
    ...            ${copy_object_with_subtree}    ${id_value}     timeout=${timeout}

Undo Delta Plan Changes At Object Level For cOAM CU
    [Documentation]    Author: Rashmi R
    ...                Description: Undo changes done for objects under delta plans
    ...                param object_name: str, object will be removed
    ...                param timeout: int, timeout for the element be available to click
    [Arguments]    ${object_name}      ${timeout}=60
    coam_cu.undo_delta_plan_changes_at_object_level    ${object_name}    timeout=${timeout}

Undo Delta Plan Changes At Parameter Level For cOAM CU
    [Documentation]    Author: Rashmi R
    ...                Description: Keyword for undo the changes at parameter level under child node of one object
    ...                param object_name: str, dist name for parameters to filter, cannot be none
    ...                param filter_param: str, param to locate target parameter, cannot be none
    ...                param abbr: str, optional, abbreviation to further locate target parameter
    ...                param timeout: int, timeout for the element be available to click
    [Arguments]    ${object_name}      ${filter_param}   ${abbr}=${None}     ${timeout}=60
    coam_cu.undo_delta_plan_changes_at_parameter_level    ${object_name}    ${filter_param}
    ...             ${abbr}    timeout=${timeout}

Compare And Overwrite All Parameters Left To Right For cOAM CU
    [Documentation]    Author: Rashmi R
    ...                Description: This keyword compare all parameter values of the given two objects and overwrite
    ...                object_to_be_compared parameters values with object_name parameter values
    ...                param object_name: str, The Base object(object_name) that has been select for comparison
    ...                param object_to_be_compared: str, Object selected in run time that has been compared
    ...                with base_object
    ...                param timeout:int, timeout for the element be available to click
    [Arguments]    ${object_name}      ${object_to_be_compared}     ${timeout}=60
    coam_cu.compare_and_overwrite_all_parameters_left_to_right    ${object_name}
    ...        ${object_to_be_compared}   timeout=${timeout}

Compare And Overwrite All Parameters Right To Left For cOAM CU
    [Documentation]    Author: Rashmi R
    ...                Description: This keyword compare all parameter values of the given two objects and overwrite
    ...                base_object(object_name) parameters vales with object_to_be_compared parameter values
    ...                param object_name: str, The Base object(object_name) that has been select for comparison
    ...                param object_to_be_compared: str, Object selected in run time that has been compared
    ...               with base_object
    ...                param timeout:int, timeout for the element be available to click
    [Arguments]    ${object_name}      ${object_to_be_compared}     ${timeout}=60
    coam_cu.compare_and_overwrite_all_parameters_right_to_left    ${object_name}
    ...        ${object_to_be_compared}   timeout=${timeout}

Compare And Overwrite Selected Parameter Right To Left For cOAM CU
    [Documentation]    Author: Rashmi R
    ...                Description: This keyword compare given parameter value of base object compare with selected
    ...                object(object_to_be_compared)
    ...                and overwrite parameter from selected object to base object
    ...                param base_object: str, The Base object that has been select for comparison
    ...                param object_to_be_compared: str, Object selected in run time that has been compared with
    ...                base_object parameter
    ...                param parameter: str, Parameter that has been compared and overwrite
    ...                param timeout:int, timeout for the element be available to click
    [Arguments]    ${base_object}      ${object_to_be_compared}     ${parameter}    ${timeout}=$60
    coam_cu.compare_and_overwrite_selected_parameter_right_to_left    ${base_object}      ${object_to_be_compared}
    ...             ${parameter}    timeout=${timeout}

Compare And Overwrite Selected Parameter Left To Right For cOAM CU
    [Documentation]    Author: Rashmi R
    ...                Description: This keyword compare given parameter value of base object compare with selected
    ...                object(object_to_be_compared)
    ...                and overwrite parameter from base object to selected object
    ...                param base_object: str, The Base object that has been select for comparison
    ...                param object_to_be_compared: str, Object selected in run time that has been compared with
    ...                base_object parameter
    ...                param parameter: str, Parameter that has been compared and overwrite
    ...                param timeout:int, timeout for the element be available to click
    [Arguments]    ${base_object}      ${object_to_be_compared}     ${parameter}    ${timeout}=60
    coam_cu.compare_and_overwrite_selected_parameter_left_to_right    ${base_object}      ${object_to_be_compared}
    ...              ${parameter}    timeout=${timeout}

Show cOAM CU Hierarchy Of Current Plan
    [Documentation]    Author: Rashmi R
    ...                Description: Keyword to show the hierarchy of the current plan.
    ...                param object_name: Model object in which parameter need to removed
    ...                param timeout: int, timeout for the element be available to click
    [Arguments]    ${object_name}    ${timeout}=60
    coam_cu.show_hierarchy_of_current_plan    ${object_name}    timeout=${timeout}

Get cOAM CU All Plans Info
    [Documentation]    Author: Rashmi R
    ...                Description: This keyword returns all the available plans in system and count as the
    ...                plane type wise
    ...                param timeout: int, timeout for the element be available to click
    [Arguments]     ${timeout}=60
    coam_cu.get_all_plans       timeout=${timeout}

Expand Model Object Tree For cOAM CU
    [Documentation]    Author: Rashmi R
    ...                Description: This Keyword will expand the MO Tree till the MO Structure given in the object name
    ...                param object_name: Model object in which parameter till the MO tree should expand
    ...                param timeout: int, timeout for the element be available to click
    [Arguments]    ${object_name}    ${timeout}=60
    coam_cu.expand_model_object_tree    ${object_name}    timeout=${timeout}

Collapse Model Object For cOAM CU
    [Documentation]    Author: Rashmi R
    ...                Description: This Keyword will collapse the MO Tree from  the MO Structure given in the
    ...                object name
    ...                param object_name: Model object in which parameter from the MO tree should collapse
    ...                param timeout: int, timeout for the element be available to click
    [Arguments]    ${object_name}    ${timeout}=60
    coam_cu.collapse_model_object    ${object_name}    timeout=${timeout}

Is Delta Parameter Edited For cOAM CU
    [Documentation]    Author: Rashmi R
    ...                Description: This keyword will return the status of delta parameter of given filter is
    ...                edited or not
    ...                param object_name: Model object in which parameter need to verified
    ...                param filter_param: str, parameter name
    ...                param abbreviation: str , abbreviation of the parameter
    ...                param timeout: int, timeout for the element be available to click
    [Arguments]    ${object_name}    ${filter_param}    ${abbreviation}=${None}    ${timeout}=60
    coam_cu.is_delta_parameter_edited    ${object_name}    ${filter_param}    ${abbreviation}    timeout=${timeout}

Get cOAM CU Parameter Details
    [Documentation]    Author: Rashmi R
    ...                Description: This keyword will return details and description of the parameter selected based
    ...                on the filter given
    ...                param object_name: Model object in which parameter need to be fetched
    ...                param filter_param: str, parameter name
    ...                param abbreviation: str , abbreviation of the parameter
    ...                param timeout: int, timeout for the element be available to click
    [Arguments]    ${object_name}    ${filter_param}    ${abbreviation}=${None}    ${timeout}=60
    coam_cu.get_parameter_details    ${object_name}    ${filter_param}    ${abbreviation}    timeout=${timeout}

Get cOAM CU Dus Status Info
    [Documentation]    Author: Rashmi R
    ...                Description: Keyword for getting DUs information under DUs status page
    coam_cu.get_dus_status_info

Get cOAM CU Cells Status Info
    [Documentation]    Author: Rashmi R
    ...                Description: Keyword for getting Cells information under Cells status page
    coam_cu.get_cells_status_info

Get cOAM CU VMs Status Info
    [Documentation]    Author: Rashmi R
    ...                Description: Keyword for getting VMs information under VMs status page
    coam_cu.get_VMs_status_info

Get cOAM CU X2 Link Status Info
    [Documentation]    Author: Rashmi R
    ...                Description: Keyword for getting X2 link information under X2 link status page
    coam_cu.get_X2_link_status_info

Get cOAM CU Properties Status Info
    [Documentation]    Author: Rashmi R
    ...                Description: Keyword for getting Cu Properties information under Cu Properties status page
    coam_cu.get_cu_properties_status_info

Set Remove Or Jump From Parameter Error Tab For cOAM CU
    [Documentation]    Author: Rashmi R
    ...                Description: Keyword for setting default parameter or removing parameter or to jump to parameter
    ...                editor page from parameter errors tab.
    ...                param abbreviation: str , abbreviation of the parameter
    ...                param error_type: str, by default it will be 'set'
    ...                if user wants to remove or jump then give error_type as 'remove' or 'jump' accordingly
    ...                param timeout: int, timeout for the element be available to click
    [Arguments]    ${abbreviation}    ${error_type}    ${timeout}=60
    coam_cu.set_remove_or_jump_from_parameter_error_tab    ${abbreviation}    ${error_type}    timeout=${timeout}

Save cOAM CU Configuration
    [Documentation]    Author: Rashmi R
    ...                Description: Keyword for saving cu configuration
    ...                param timeout: int, timeout for the element be available to click
    [Arguments]     ${timeout}=60
    coam_cu.save_cu_configuration    timeout=${timeout}

Reset cOAM CU
    [Documentation]    Author: Rashmi R
    ...                Description: This keyword will reset the cu form dash board page
    ...                param timeout: int, timeout for the element be available to click
    [Arguments]     ${timeout}=60
    coam_cu.reset_cu    timeout=${timeout}

Lock cOAM CU Dus
    [Documentation]    Author: Rashmi R
    ...                Description: This keyword will lock the given DU object
    ...                param object_name: DU object that needs to be locked
    ...                param timeout: int, timeout for the element be available to click
    [Arguments]     ${object_name}   ${timeout}=60
    coam_cu.lock_dus    ${object_name}    timeout=${timeout}

Unlock cOAM CU Dus
    [Documentation]    Author: Rashmi R
    ...                Description: This keyword will unlock the given DU object
    ...                param object_name: DU object that needs to be unlocked
    ...                param timeout: int, timeout for the element be available to click
    [Arguments]     ${object_name}   ${timeout}=60
    coam_cu.unlock_dus    ${object_name}    timeout=${timeout}

Lock cOAM CU Cells
    [Documentation]    Author: Rashmi R
    ...                Description: This keyword will lock the given cells object
    ...                param object_name: cells object that needs to be locked
    ...                param timeout: int, timeout for the element be available to click
    [Arguments]     ${object_name}   ${timeout}=60
    coam_cu.lock_cells    ${object_name}    timeout=${timeout}

Unlock cOAM CU Cells
    [Documentation]    Author: Rashmi R
    ...                Description: This keyword will unlock the given cells object
    ...                param object_name: cells object that needs to be unlocked
    ...                param timeout: int, timeout for the element be available to click
    [Arguments]     ${object_name}   ${timeout}=60
    coam_cu.unlock_cells    ${object_name}    timeout=${timeout}

Lock cOAM CU Cell Groups
    [Documentation]    Author: Rashmi R
    ...                Description: This keyword will lock the given cell_groups object
    ...                param object_name: cell_groups object that needs to be locked
    ...                param timeout: int, timeout for the element be available to click
    [Arguments]     ${object_name}   ${timeout}=60
    coam_cu.lock_cell_groups    ${object_name}    timeout=${timeout}


Unlock cOAM CU Cell Groups
    [Documentation]    Author: Rashmi R
    ...                Description: This keyword will unlock the given cell_groups object
    ...                param object_name: cell_groups object that needs to be unlocked
    ...                param timeout: int, timeout for the element be available to click
    [Arguments]     ${object_name}   ${timeout}=60
    coam_cu.unlock_cell_groups    ${object_name}    timeout=${timeout}

Lock cOAM CU X2 Links
    [Documentation]    Author: Rashmi R
    ...                Description: This keyword will lock the given x2_links object
    ...                param object_name: x2_links object that needs to be locked
    ...                param timeout: int, timeout for the element be available to click
    [Arguments]     ${object_name}   ${timeout}=60
    coam_cu.lock_x2_links    ${object_name}    timeout=${timeout}

Unlock cOAM CU X2 Links
    [Documentation]    Author: Rashmi R
    ...                Description: This keyword will unlock the given x2_links object
    ...                param object_name: x2_links object that needs to be unlocked
    ...                param timeout: int, timeout for the element be available to click
    [Arguments]     ${object_name}   ${timeout}=60
    coam_cu.unlock_x2_links    ${object_name}    timeout=${timeout}

cOAM CU CPlane Route Configuration Settings
	[Documentation]    Author: Rashmi R
    ...                Description: This keyword is used to set the CPlane Route Configuration based on the given info
    ...                param destination_IP_address: str, valid IPv4 or IPv6 IP address
    ...                param gateway_IP_address: str, valid IPv4 or IPv6 gateway IP address
    ...                param destination_subnet_mask_length: str , destination IP valid prefix length
    ...                param timeout: str, timeout for the element be available to click
    [Arguments]     ${destination_IP_address}   ${gateway_IP_address}
	...             ${destination_subnet_mask_length}   ${timeout}=60
	coam_cu.cplane_route_configuration    ${destination_IP_address}   ${gateway_IP_address}
	...             ${destination_subnet_mask_length}   timeout=${timeout}
