*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...      == MAINTAINER ==
...      Marek Kieltyka <marek.kieltyka@nokia.com>
...      I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>

Library    taf.gnb.oam.coam.vdu.interface.Vdu  WITH NAME  vdu
Library    taf.gnb.oam.coam.cu.interface.cu  WITH NAME  vcu

*** Variables ***
${VRAN_AP_UPLOAD_XML_SH_SCRIPT}    /home/ute/MN/UTE/robotlte/resources/DevKr/vran_ap_upload_xml.sh

*** Keywords ***
Setup VRAN devices aliases
    Create UEs alias  alias=UE  id_type=wts_5g
    Create eNB device with alias 'eNB1' identified by ip=10.0.1.21
    Create AMF device with alias 'AMF1' identified by ip=10.0.11.1
    Create gNB device with alias 'gNB2' identified by ip=10.0.11.10
    Create GNB device with alias 'gNB3_XN' identified by ip=10.0.12.31

Setup VRAN libraries
    vcu.Connect to  host=${vCU_admin}  port=443  username=Nemuadmin  password=Nokia@123  secure=True
    vdu.Connect to  host=${vDU_admin}  port=443  username=Nemuadmin  password=Nokia@123  secure=True

VRAN Upload AirPhone XML And Reboot
    [Arguments]    ${iphy_xml}
    ${result}    Run Process    ${VRAN_AP_UPLOAD_XML_SH_SCRIPT}    ${iphy_xml}

Send CU delta commissioning
    [Arguments]    ${input_filepath}
    [Documentation]  Usage example:
    ...  vcu.Connect to  host=${vCU_admin}  port=443  username=Nemuadmin  password=Nokia@123  secure=True
    ...  Send CU delta commissioning   input_filepath=/home/ute/robotws/testsuite/Krakow/RRM/DevKr/CB006999/config/VRAN/basic_enabler_3AMFs.json

    ${json_file_content}    OperatingSystem.Get File    ${input_filepath}
    @{delta_json_list}    Convert To List From JSON String    ${json_file_content}

    ${delta_plan_list}     vcu.get_delta_plan_list
    Run Keyword If   ${delta_plan_list}  vcu.delete_delta_plan  ${delta_plan_list[0]['plan_id']}

    ${delta_res}=  vcu.Generate delta plan  plan_name=DELTA-PLAN-1
    ${plan_id}     Set variable    ${delta_res['plan_id']}
    Wait until keyword succeeds  3x  2s    Check if delta plan was created on CU    ${delta_res['action_id']}

    FOR  ${moc_dict}  IN  @{delta_json_list}
        ${mo_parameters}=    Run Keyword And Ignore Error    vcu.get_parameters    dist_name=${moc_dict["distName"]}
        Run keyword if    "${moc_dict["operation_type"]}" == "add" and "${mo_parameters[0]}" == "FAIL"  # check if MO exists in CURRENT_PLAN
        ...     Create MO in CU delta plan    plan_id=${plan_id}    dist_name=${moc_dict["distName"]}

        ${mo_uuid}    Get CU Specifical MO UUID    plan_id=${plan_id}  mo_dn=${moc_dict["distName"]}

        ${parameters_count}    Get length    ${moc_dict["parameters"]}
        Run keyword if    ${parameters_count} > 0
        ...     Update parameters in CU delta plan    plan_id=${plan_id}    mo_uuid=${mo_uuid}    parameters_list=${moc_dict["parameters"]}
    END

    #TODO: NRDRB_5QI  ${moc["state"]}'=='changed' even if there's no changes
    ${cu_delta_is_identical_as_current_plan}    Check if CU delta plan is identical as current plan    plan_id=${plan_id}

    Run keyword if    ${cu_delta_is_identical_as_current_plan} == ${True}
    ...    Log to console    CU delta commissioning will not be sent because it does not change any parameter

    Run keyword if    ${cu_delta_is_identical_as_current_plan} == ${False}
    ...    Validate and activate CU delta plan    plan_id=${plan_id}

Change CU parameter on ${MOC} ${parameter}=${new_value}
    [Documentation]  Usage example:
    ...  vcu.Connect to  host=${vCU_admin}  port=443  username=Nemuadmin  password=Nokia@123  secure=True
    ...  Change CU parameter on MRBTS-1/NRBTS-1 drbInactivityTimerSA=10
    ...  Change CU parameter on MRBTS-1/NRBTS-1 cipherPrefL/nea0=9
    ...  Change CU parameter on MRBTS-1/NRBTS-1/SERVEDAMF-3 administrativeState=Locked
    ...  Change CU parameter on MRBTS-1/NRBTS-1/NRCELL-1 actNonVoNRGbrService=true

    ${current_value}    Get value of CU MOC parameter   ${MOC}    ${parameter}
    Run Keyword If   '${current_value}' != '${new_value}'
    ...  Make change for CU parameter ${MOC} ${parameter}=${new_value}

Make change for CU parameter ${MOC} ${parameter}=${new_value}
    ${delta_plan_list}     vcu.get_delta_plan_list
    Run Keyword If   ${delta_plan_list}  vcu.delete_delta_plan  ${delta_plan_list[0]['plan_id']}

    ${delta_res}=  vcu.Generate delta plan  plan_name=DELTA-PLAN-1
    ${plan_id}     Set variable    ${delta_res['plan_id']}
    Wait until keyword succeeds  3x  2s    Check if delta plan was created on CU    ${delta_res['action_id']}

    ${mo_uuid}    Get CU Specifical MO UUID    plan_id=${plan_id}  mo_dn=${MOC}
    &{params_dict}=   Create Dictionary   operation_type=replace    parameter_path=/${parameter}   value=${new_value}
    @{params_list}    Create List    ${params_dict}
    Update parameters in CU delta plan    plan_id=${plan_id}    mo_uuid=${mo_uuid}    parameters_list=${params_list}

    ${delta_act}=  vcu.Activate Delta Plan  ${plan_id}
    Wait until keyword succeeds  15x  2s    Check if delta plan was activated on CU    ${plan_id}    ${delta_act['operation_id']}

    ${current_value}    Get value of CU MOC parameter   ${MOC}    ${parameter}
    Should be equal   ${current_value}    ${new_value}    msg=Changing ${parameter} on ${MOC} failed

Check if delta plan was created on CU
    [Arguments]    ${action_id}
    ${delta_gen}=  vcu.get_action_state_of_generating_delta_plan   ${action_id}
    Should be true    '${delta_gen['status']}'=='success' or '${delta_gen['status']}'=='failure'
    Run keyword if    '${delta_gen['status']}'=='failure'
    ...    Fail    CU delta plan creation failed

Check if delta plan was updated on CU
    [Arguments]    ${plan_id}     ${action_id}
    ${delta_upd}=  vcu.get_action_state_of_updating_parameters_of_delta_plan    ${plan_id}    ${action_id}
    Should be true    '${delta_upd['status']}'=='success' or '${delta_upd['status']}'=='failure'
    Run keyword if    '${delta_upd['status']}'=='failure'
    ...    Fail    CU delta plan update failed

Check if delta plan was validated on CU
    [Arguments]    ${plan_id}     ${action_id}
    ${delta_validation}=  vcu.get_action_state_of_validating_delta_plan    ${plan_id}    ${action_id}
    Should be true    '${delta_validation['status']}'=='success' or '${delta_validation['status']}'=='failure'
    Run keyword if    '${delta_validation['status']}'=='failure'
    ...    Fail    CU delta plan validation failed

Check if delta plan was activated on CU
    [Arguments]    ${plan_id}     ${operation_id}
    ${delta_act}=  vcu.get_operation_state_of_activating_delta_plan    ${plan_id}    ${operation_id}
    Should be true    '${delta_act['status']}'=='success' or '${delta_act['status']}'=='failure'
    Run keyword if    '${delta_act['status']}'=='failure'
    ...    Fail    CU delta plan activation failed

Check if MO was created on CU
    [Arguments]    ${plan_id}     ${action_id}
    ${create_mo}=  vcu.get_create_managed_object_action_result    ${plan_id}    ${action_id}
    Should be true    '${create_mo['status']}'=='success' or '${create_mo['status']}'=='failure'
    Run keyword if    '${create_mo['status']}'=='failure'
    ...    Fail    CU object creation failed

Check if CU delta plan is identical as current plan
    [Arguments]    ${plan_id}
    &{delta_plan_tree_diff}    vcu.get_delta_plan_tree_diff    plan_id=${plan_id}
    ${cu_delta_is_identical_as_current_plan}    Set variable     ${True}

    FOR    ${moc}    IN    @{delta_plan_tree_diff["created"]}
       ${cu_delta_is_identical_as_current_plan}  Set variable if  '${moc["state"]}'=='changed' or '${moc["state"]}'=='new'   ${False}    ${True}
        Exit for loop if    ${cu_delta_is_identical_as_current_plan} == ${False}
    END
    [Return]   ${cu_delta_is_identical_as_current_plan}

Update parameters in CU delta plan
    [Arguments]    ${plan_id}    ${mo_uuid}    ${parameters_list}
    ${update_res}     vcu.Update parameters of delta plan     ${plan_id}     ${mo_uuid}     ${parameters_list}
    Wait until keyword succeeds  3x  1s    Check if delta plan was updated on CU    ${plan_id}    ${update_res['action_id']}

Validate and activate CU delta plan
    [Arguments]    ${plan_id}
    ${delta_validation}=    vcu.validate_delta_plan    ${plan_id}
    Wait until keyword succeeds  10x  2s    Check if delta plan was validated on CU    ${plan_id}    ${delta_validation['action_id']}

    ${delta_act}=    vcu.Activate Delta Plan    ${plan_id}
    Wait until keyword succeeds  24x  10s    Check if delta plan was activated on CU    ${plan_id}    ${delta_act['operation_id']}

Create MO in CU delta plan
    [Arguments]    ${plan_id}    ${dist_name}

    ${uuid}   Get CU parent MO UUID   plan_id=${plan_id}    dist_name=${dist_name}
    ${nidd_id}    Get CU NIDD ID for MO from local dictionary    dist_name=${dist_name}
    ${instance_id}    Get instance ID for MO    dist_name=${dist_name}
    ${nidd}  Convert to string  ${nidd_id}

    ${create_res}=   vcu.create_managed_object_of_delta_plan
    ...    plan_id=${plan_id}
    ...    parent_mo_uuid=${uuid}
    ...    nidd_id=${nidd}
    ...    instance_id=${instance_id}
    ...    include_defaults=${True}
    Wait until keyword succeeds  3x  2s    Check if MO was created on CU    ${plan_id}    ${create_res['action_id']}

Get CU parent MO UUID
    [Arguments]    ${plan_id}    ${dist_name}

    ${parent_mo}    Get parent MO path   ${dist_name}
    ${mo_uuid}    Get CU Specifical MO UUID    plan_id=${plan_id}   mo_dn=${parent_mo}

    [Return]    ${mo_uuid}

Get CU NIDD ID for MO from local dictionary
    [Arguments]    ${dist_name}

    ${mo_name}    Get last MO name from path    ${dist_name}
    ${nidd_id}    Get From Dictionary    ${MO_CLASS_TO_CU_NIDD_ID_MAPPING}   ${mo_name}

    [Return]   ${nidd_id}

Get CU NIDD ID for MO from CU library
    [Arguments]    ${dist_name}

    ${mo_name}    Get last MO name from path    ${dist_name}
    ${mo_name}    Catenate    SEPARATOR=    com.nokia.srbts.nrbts:    ${mo_name}   # TODO: change com.nokia.srbts.nrbts: prefix to generic
    ${robot_variables}    Get variables
    Run keyword unless    '\${CU_NIDD_SAVED}' in @{robot_variables}
    ...    Save CU NIDD for suite

    FOR    ${each_nidd}    IN    @{all_nidd}
       ${nidd_id}  set variable if  '${each_nidd["adaptation_id"]}'=='${mo_name}'   ${each_nidd["nidd_id"]}
        exit for loop if    '${each_nidd["adaptation_id"]}'=='${mo_name}'
    END
    [Return]   ${nidd_id}

Save CU NIDD for suite
    @{all_nidd}      vcu.get_nidd
    Set Suite Variable    ${CU_NIDD_SAVED}    ${True}
    Set Suite Variable    ${all_nidd}

Get CU Specifical MO UUID
    [Arguments]    ${plan_id}    ${mo_dn}
    @{name_list}=   split_string    ${mo_dn}   /

#    ${CU_software_version}    vcu.get_active_software_version
#    ${isTrunkCUBuildLoaded}    Run Keyword And Return Status    Should Contain    ${CU_software_version}    _0.250
#    Set suite variable  ${cu_parent_mouuid}    ${EMPTY}
#    Run keyword if    ${isTrunkCUBuildLoaded}
#    ...    Set suite variable  ${cu_parent_mouuid}    None

    Set suite variable  ${cu_parent_mouuid}    None

    FOR  ${name}  IN  @{name_list}
        ${mouuid}   Get CU Specifical MO UUID via DN Name   ${plan_id}  ${name}
    END
    [Return]   ${mouuid}

Get CU Specifical MO UUID via DN Name   # TODO: try to make it faster
    [Arguments]    ${plan_id}    ${name}
    &{delta_plan_tree}   vcu.get_delta_plan_tree_diff   plan_id=${plan_id}
    @{plan_tree}        set variable  ${delta_plan_tree["created"]}
    FOR  ${mo_info}  IN  @{plan_tree}
       run keyword if  '${mo_info["parent_mo_uuid"]}'=='${cu_parent_mouuid}' and '${mo_info["name"]}'=='${name}'  run keywords
       ...  Set suite variable  ${cu_parent_mouuid}  ${mo_info["mo_uuid"]}  AND  exit for loop
    END
    [Return]   ${cu_parent_mouuid}

Get CU PM counters last timestamp
    ${counter}     vcu.Get counter
    ...    measurement_id=None
    ...    dimension_dist_name=MRBTS-1/NRBTS-1/NRCELL-1
    ...    counter_id=M55125C00001  # MRBTS-1/NNGCC/M55125C00001 (NNGCC_INIT_UE_MSG_SENT)

    ${all_counter_values}    Get From Dictionary    ${counter}    values
    ${last_timestamp}    Get From Dictionary    ${all_counter_values[-1]}    start_time
    [Return]    ${last_timestamp}

Check if new CU PM counters are saved
    ${current_cu_counter_values_timestamp}    Get CU PM counters last timestamp
    Should not be equal   ${current_cu_counter_values_timestamp}    ${previous_cu_counter_values_timestamp}

Wait until CU PM counters file is ready and saved
    [Documentation]  Verification example:
    ...  vcu.Connect to  host=${vCU_admin}  port=443  username=Nemuadmin  password=Nokia@123  secure=True
    ...  Wait until CU PM counters file is ready and saved
    ...  Execute egate command  cmd=ue_register id=1
    ...  Wait until CU PM counters file is ready and saved
    ...  Verify CU counter value on NRCELL-1 for M55125C00001 - NNGCC_INIT_UE_MSG_SENT equals 1
    ${previous_cu_counter_values_timestamp}    Get CU PM counters last timestamp
    Set test variable  ${previous_cu_counter_values_timestamp}
    Log to console    Waiting for next full CU pm file...
    Wait until keyword succeeds  30x  15s    Check if new CU PM counters are saved

Verify CU counter value on ${moc} for ${pi_id} - ${NetAct_name} equals ${occurences:>?\d+}
    [Documentation]  Verification example:
    ...  vcu.Connect to  host=${vCU_admin}  port=443  username=Nemuadmin  password=Nokia@123  secure=True
    ...  Wait until CU PM counters file is ready and saved
    ...  Execute egate command  cmd=ue_register id=1
    ...  Wait until CU PM counters file is ready and saved
    ...  Verify CU counter value on NRCELL-1 for M55125C00001 - NNGCC_INIT_UE_MSG_SENT equals 1
    ...  Verify CU counter value on NRCELL-1/NRPMQAP-1 for M55161C00001 - AVE_NUMBER_OF_SA_RRC_PMQAP equals >0

    ${counter}     vcu.Get counter
    ...    measurement_id=None
    ...    dimension_dist_name=MRBTS-1/NRBTS-1/${moc}
    ...    counter_id=${pi_id}

    ${all_counter_values}    Get From Dictionary    ${counter}    values
    Run Keyword If    ${all_counter_values}==[]    Fail    No counter value right now for MRBTS-1/NRBTS-1/${moc}
    ${latest_value}    Get From Dictionary    ${all_counter_values[-1]}    value

    ${cu_counter_value_correct}     Check if VRAN counter value is correct     ${latest_value}    ${occurences}
    Should be true   ${cu_counter_value_correct}    msg=${NetAct_name}: expected ${occurences}, result ${latest_value}

Verify CU counter value on ${moc} for ${pi_id} - ${NetAct_name} is in range ${lower:\d+} - ${higher:\d+}
    [Documentation]  Verification example:
    ...  vcu.Connect to  host=${vCU_admin}  port=443  username=Nemuadmin  password=Nokia@123  secure=True
    ...  Wait until CU PM counters file is ready and saved
    ...  Execute egate command  cmd=ue_register id=1
    ...  Wait until CU PM counters file is ready and saved
    ...  Verify CU counter value on NRCELL-1 for M55124C08501 - ACC_UAI_RRC_REL_PREF_CONF_UES is in range 1 - 10

    ${counter}     vcu.Get counter
    ...    measurement_id=None
    ...    dimension_dist_name=MRBTS-1/NRBTS-1/${moc}
    ...    counter_id=${pi_id}

    ${all_counter_values}    Get From Dictionary    ${counter}    values
    Run Keyword If    ${all_counter_values}==[]    Fail    No counter value right now for MRBTS-1/NRBTS-1/${moc}
    ${latest_value}    Get From Dictionary    ${all_counter_values[-1]}    value
    ${cu_counter_value_in_range}     Check if counter value is in range    ${latest_value}    ${lower}    ${higher}
    Should be true   ${cu_counter_value_in_range}    msg=${NetAct_name}: expected range=${lower}-${higher}, result=${latest_value}




Send DU delta commissioning
    [Arguments]    ${input_filepath}
    [Documentation]  Usage example:
    ...  vdu.Connect to  host=${vDU_admin}  port=443  username=Nemuadmin  password=Nokia@123  secure=True
    ...  Send DU delta commissioning   input_filepath=/home/ute/robotws/testsuite/Krakow/RRM/DevKr/CB006999/config/VRAN/basic_enabler_3AMFs.json

    ${json_file_content}    OperatingSystem.Get File    ${input_filepath}
    @{delta_json_list}    Convert To List From JSON String    ${json_file_content}

    ${delta_plan_list}     vdu.get_delta_plan_info_list
    Run Keyword If   ${delta_plan_list}  vdu.delete_delta_plan_file  ${delta_plan_list[0]['plan_id']}

    ${delta_res}    vdu.Generate delta plan  plan_name=DELTA-PLAN-1  timeout=10
    ${plan_id}     Set variable    ${delta_res['plan_id']}
    Wait until keyword succeeds  3x  2s    Check if delta plan was created on DU    ${delta_res['action_id']}

    FOR  ${moc_dict}  IN  @{delta_json_list}
        ${mo_parameters}=    Run Keyword And Ignore Error
        ...    vdu.search_parameter_of_current_plan
        ...    mo_dn=${moc_dict["distName"]}
        ...    para_name=${moc_dict["parameters"][0]["parameter_path"]}

        Run keyword if    "${moc_dict["operation_type"]}" == "add" and "${mo_parameters[0]}" == "FAIL"  # check if MO exists in CURRENT_PLAN
        ...    Create MO in DU delta plan    plan_id=${plan_id}    dist_name=${moc_dict["distName"]}

        ${dict_of_params_add}        Get dict of parameters for VRAN DU delta    params_list=${moc_dict["parameters"]}    op_type=add
        ${dict_of_params_replace}    Get dict of parameters for VRAN DU delta    params_list=${moc_dict["parameters"]}    op_type=replace

        ${parameters_to_add_count}        Get length    ${dict_of_params_add}
        ${parameters_to_replace_count}    Get length    ${dict_of_params_replace}

        ${mo_uuid}    get_du_specifical_mo_uuid_via_dn    plan_id=${plan_id}    full_mo_dn=${moc_dict["distName"]}

        Run keyword if    ${parameters_to_add_count} > 0
        ...    Update parameters in DU delta plan
        ...    plan_id=${plan_id}
        ...    mo_dn=${moc_dict["distName"]}
        ...    updated_paras_dict=${dict_of_params_add}
        ...    operation=add
        ...    mo_uuid=${mo_uuid}

        Run keyword if    ${parameters_to_replace_count} > 0
        ...    Update parameters in DU delta plan
        ...    plan_id=${plan_id}
        ...    mo_dn=${moc_dict["distName"]}
        ...    updated_paras_dict=${dict_of_params_replace}
        ...    operation=replace
        ...    mo_uuid=${mo_uuid}
    END

    ${du_delta_is_different}    Check if DU delta plan is different from current plan    plan_id=${plan_id}

    Run keyword if    ${du_delta_is_different} == ${False}
    ...    Log to console    DU delta commissioning will not be sent because it does not change any parameter

    Run keyword if    ${du_delta_is_different} == ${True}
    ...    Validate and activate DU delta plan    plan_id=${plan_id}

Change DU parameter on ${MOC} ${parameter}=${new_value}
    [Documentation]  Usage example:
    ...  vdu.Connect to  host=${vDU_admin}  port=443  username=Nemuadmin  password=Nokia@123  secure=True
    ...  Change DU parameter on MRBTS-1/NRBTS-1/NRCELL-1 actNonVoNRGbrService=true

    ${current_value}    vdu.search_parameter_of_current_plan    mo_dn=${MOC}    para_name=${parameter}
    Run Keyword If   '${current_value}' != '${new_value}'
    ...  Make change for DU parameter ${MOC} ${parameter}=${new_value}

Make change for DU parameter ${MOC} ${parameter}=${new_value}
    ${delta_plan_list}     vdu.get_delta_plan_info_list
    Run Keyword If   ${delta_plan_list}  vdu.delete_delta_plan_file  ${delta_plan_list[0]['plan_id']}

    ${delta_res}=  vdu.Generate delta plan  plan_name=DELTA-PLAN-1  timeout=10
    ${plan_id}     Set variable    ${delta_res['plan_id']}
    Wait until keyword succeeds  3x  2s    Check if delta plan was created on DU    ${delta_res['action_id']}

    ${mo_uuid}    get_du_specifical_mo_uuid_via_dn    plan_id=${plan_id}    full_mo_dn=${MOC}

    &{params_dict}=   Create Dictionary   /${parameter}=${new_value}
    Update parameters in DU delta plan
    ...    plan_id=${plan_id}
    ...    mo_dn=${MOC}
    ...    updated_paras_dict=${params_dict}
    ...    operation=replace
    ...    mo_uuid=${mo_uuid}

    Validate and activate DU delta plan    plan_id=${plan_id}

    ${current_value}    vdu.search_parameter_of_current_plan    mo_dn=${MOC}    para_name=${parameter}
    Should be equal   ${current_value}    ${new_value}    msg=Changing ${parameter} on ${MOC} failed

Check if delta plan was created on DU
    [Arguments]    ${action_id}
    ${delta_gen}=  vdu.get_delta_plan_generated_action_status    ${action_id}
    Should be true    '${delta_gen['status']}'=='success' or '${delta_gen['status']}'=='failure'
    Run keyword if    '${delta_gen['status']}'=='failure'
    ...    Fail    DU delta plan creation failed

Check if delta plan was updated on DU
    [Arguments]    ${plan_id}     ${action_id}
    ${delta_upd}=  vdu.get_update_paras_action_status_of_delta_plan    ${plan_id}    ${action_id}
    Should be true    '${delta_upd['status']}'=='success' or '${delta_upd['status']}'=='failure'
    Run keyword if    '${delta_upd['status']}'=='failure'
    ...    Fail    DU delta plan update failed

Check if delta plan was validated on DU
    [Arguments]    ${plan_id}     ${action_id}
    ${delta_validation}=  vdu.get_validate_plan_operation_status    ${plan_id}    ${action_id}
    Should be true    '${delta_validation['status']}'=='success' or '${delta_validation['status']}'=='failure'
    Run keyword if    '${delta_validation['status']}'=='failure'
    ...    Fail    DU delta plan validation failed

Check if delta plan was activated on DU
    [Arguments]    ${plan_id}     ${operation_id}
    ${delta_act}=  vdu.get_activate_delta_plan_operation_status    ${plan_id}    ${operation_id}
    Should be true    '${delta_act['status']}'=='success' or '${delta_act['status']}'=='failure'
    Run keyword if    '${delta_act['status']}'=='failure'
    ...    Fail    DU delta plan activation failed

Check if MO was created on DU
    [Arguments]    ${plan_id}     ${action_id}
    ${create_mo}=  vdu.get_create_vdu_object_action_status_of_staged_plan    ${plan_id}    ${action_id}
    Should be true    '${create_mo['status']}'=='success' or '${create_mo['status']}'=='failure'
    Run keyword if    '${create_mo['status']}'=='failure'
    ...    Fail    DU object creation failed

Check if DU delta plan is different from current plan
#    [Arguments]    ${plan_id}
    ${delta_plan_info}    vdu.get_delta_plan_info_list
    ${du_delta_plan_is_different}    Get From Dictionary    ${delta_plan_info[0]}    is_changed
    [Return]   ${du_delta_plan_is_different}

Update parameters in DU delta plan
    [Arguments]    ${plan_id}    ${mo_dn}    ${updated_paras_dict}    ${operation}    ${mo_uuid}
    ${update_res}     vdu.update_vdu_parameter_of_delta_plan
    ...  plan_id=${plan_id}
    ...  mo_dn=${mo_dn}
    ...  updated_paras_dict=${updated_paras_dict}
    ...  operation=${operation}
    ...  mo_uuid=${mo_uuid}

    Wait until keyword succeeds  3x  1s    Check if delta plan was updated on DU    ${plan_id}    ${update_res['action_id']}

Validate and activate DU delta plan
    [Arguments]    ${plan_id}
    ${delta_validation}=    vdu.validate_delta_plan    ${plan_id}
    Wait until keyword succeeds  10x  2s    Check if delta plan was validated on DU    ${plan_id}    ${delta_validation['action_id']}

    ${delta_act}=    vdu.Activate Delta Plan    ${plan_id}
    Wait until keyword succeeds  24x  10s    Check if delta plan was activated on DU    ${plan_id}    ${delta_act['id']}

Create MO in DU delta plan
    [Arguments]    ${plan_id}    ${dist_name}

    ${parent_mo_dn}    Get parent MO path   ${dist_name}
    ${mo_name}    Get last MO name with ID from path    ${dist_name}

    ${create_res}=   vdu.create_vdu_object_of_delta_plan
    ...    delta_plan_id=${plan_id}
    ...    parent_mo_dn=${parent_mo_dn}
    ...    mo_name=${mo_name}

    Wait until keyword succeeds  3x  2s    Check if MO was created on DU    ${plan_id}    ${create_res['action_id']}

Get DU PM counters values count
    ${all_counter_values}     vdu.get_counter_values
    ...    counter_id=M55139C00001  # NRCELL-1/RSADU/M55139C00001 (SGNB_SA_DU_ADMISSION_REQ)
    ...    dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1

    ${all_counter_values_length}=  Get length    ${all_counter_values}
    [Return]    ${all_counter_values_length}

Check if new DU PM counters are saved
    ${current_du_counter_values_length}    Get DU PM counters values count
    Should be true     ${current_du_counter_values_length} != ${previous_du_counter_values_length}

Wait until DU PM counters file is ready and saved
    ${previous_du_counter_values_length}    Get DU PM counters values count
    Set test variable  ${previous_du_counter_values_length}
    Log to console    Waiting for next full DU pm file...
    Wait until keyword succeeds  30x  15s    Check if new DU PM counters are saved

Verify DU counter value on ${moc} for ${pi_id} - ${NetAct_name} equals ${occurences:>?\d+}
    [Documentation]  Verification example:
    ...  vdu.Connect to  host=${vDU_admin}  port=443  username=Nemuadmin  password=Nokia@123  secure=True
    ...  Wait until DU PM counters file is ready and saved
    ...  Execute egate command  cmd=ue_register id=1
    ...  Wait until DU PM counters file is ready and saved
    ...  Verify DU counter value on NRCELL-1 for M55139C00001 - SGNB_SA_DU_ADMISSION_REQ equals 1

    ${all_counter_values}     vdu.get_counter_values
    ...    counter_id=${pi_id}
    ...    dimension_dn=MRBTS-1/NRBTS-1/${moc}

    Run Keyword If    ${all_counter_values}==[]    Fail    No counter value right now.
    ${latest_value}    Get From Dictionary    ${all_counter_values[-1]}    value
    ${du_counter_value_correct}     Check if VRAN counter value is correct     ${latest_value}    ${occurences}
    Should be true   ${du_counter_value_correct}    msg=${NetAct_name}: expected ${occurences}, result ${latest_value}

Verify DU counter value on ${moc} for ${pi_id} - ${NetAct_name} is in range ${lower:\d+} - ${higher:\d+}
    [Documentation]  Verification example:
    ...  vdu.Connect to  host=${vDU_admin}  port=443  username=Nemuadmin  password=Nokia@123  secure=True
    ...  Wait until DU PM counters file is ready and saved
    ...  Execute egate command  cmd=ue_register id=1
    ...  Wait until DU PM counters file is ready and saved
    ...  Verify DU counter value on NRCELL-1 for M55304C00001 - MEAS_PERIOD_NR_MAC_PDU_TPUT is in range 1 - 100

    ${all_counter_values}     vdu.get_counter_values
    ...    counter_id=${pi_id}
    ...    dimension_dn=MRBTS-1/NRBTS-1/${moc}

    Run Keyword If    ${all_counter_values}==[]    Fail    No counter value right now for MRBTS-1/NRBTS-1/${moc}
    ${latest_value}    Get From Dictionary    ${all_counter_values[-1]}    value
    ${du_counter_value_in_range}     Check if counter value is in range    ${latest_value}    ${lower}    ${higher}
    Should be true   ${du_counter_value_in_range}    msg=${NetAct_name}: expected range=${lower}-${higher}, result=${latest_value}


*** Variables ***
${vCU_admin}                192.168.100.129
${vDU_admin}                192.168.255.129
${DEFAULT_DELTA_PLAN_ID}    dp_00000000

&{MO_CLASS_TO_CU_NIDD_ID_MAPPING}     ADJ_NRPLMNSET_NSA=255314
...   ADJ_NRPLMNSET_SA=255316
...   BWP_PROFILE=235180
...   LTEENB=200274
...   NRADJECELL=241398
...   NRADJGNB=241284
...   NRADJNRCELL=255312
...   NRANR=253320
...   NRANRPR=253322
...   NRANRPRE=267488
...   NRCAIMP=262464
...   NRCAIMS=262466
...   NRCELL_FDD=215454
...   NRCELL=199438
...   NRCELLGRP=199440
...   NRCONNECTMODE_PROFILE=255650
...   NRCTRLTS=219476
...   NRCUUP=215266
...   NRDRB_5QI=235368
...   NRDRB_PDCP=235372
...   NRDRB_QCI=235374
...   NRDRB=235366
...   NRDSSLTE=238848
...   NRDU=199442
...   NRHOIF=216826
...   NRHOIR=241400
...   NRIAFIM=235190
...   NRIRFIM=235192
...   NRLIM=235194
...   NRMEASCFG_IR=258880
...   NRMOIMP_SA=262468
...   NRMOPR_NSA=258180
...   NRMOPR_SA=258882
...   NRMOPRMA_NSA=258182
...   NRMOPRMA_SA=258884
...   NRMORED=258886
...   NRMTRACECU=219480
...   NRMULTIBANDINFO_PROFILE=257640
...   NRNSPMAX_PROFILE=257642
...   NRNWSLICE_NSA=252112
...   NRPLMN=238850
...   NRPLMNSET_NSA=238852
...   NRPLMNSET_SA=238854
...   NRPMQAP=265428
...   NRPMRNL=199444
...   NRPRIOACC_PROFILE=287510
...   NRREDRT=216990
...   NRREL=215240
...   NRRELE=241402
...   NRRELLTE=218583
...   NRRESOURCECU=252852
...   NRSCTP=211448
...   NRSTRACECU=266044
...   NRSYSINFO_PROFILE=235182
...   SERVEDAMF=214142
...   SNSSAI=219486
...   TAC=154730
...   TCE=242898  # com.nokia.srbts.mnl:TCE
...   TCEADM=242896  # com.nokia.srbts.mnl:TCE
...   TRACKINGAREA=219488
...   XNLINK=215244
