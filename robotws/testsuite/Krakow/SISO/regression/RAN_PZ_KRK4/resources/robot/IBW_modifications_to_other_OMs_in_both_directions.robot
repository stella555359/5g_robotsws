*** Settings ***
Documentation
...    Implementation of IBW_modifications_to_other_OMs_in_both_directions test case
...    author: Rafal Kawa
...    contact: rafal.kawa@nokia.com

Resource  taf/rfrl/procedures/resources/robot/Connections.robot
Resource  taf/rfrl/procedures/resources/robot/BtsConfiguration.robot

Library     taf.rfrl.bts.devices.du.du_operations.GnbDuOperations    WITH NAME      gnbbbu
Library     taf.rfrl.bts.devices.ru.ru_operations.GnbRuOperations    WITH NAME      gnbru
Library     taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations    WITH NAME      gnbcell
Library     taf.rfrl.bts.devices.du.alarm_verification.GnbAlarmVerification    WITH NAME    gnbalarm
Library     taf.rfrl.procedures.resources.python.webui.webui    WITH NAME  webui
Library     ../python/RadioOperations.py   WITH NAME    radio_keywords
Library     ../python/ScfObjectOperations.py   WITH NAME    scf_obj
Library     taf.rfrl.procedures.resources.python.json_delta_scf.JsonDeltaCommissioning  WITH NAME  json_delta


*** Keywords ***
IBW_modifications_to_other_OMs_in_both_directions
    [Documentation]
    ...    Test verifies BTS behavior after IBW modifications.
    ...    ARGS:
    ...    - ibw_reconfiguration_flow (dict, mandatory): Dict containing IBW reconfiguration flow with its details.
    ...        Example:
    ...        {'STEP_1': {'fr2_operation_mode': 'One_Sector_1600MHz_IBW_2T2R_SU_MIMO',
    ...                    'reconfigure_sectors': 'deletion',
    ...                    'reset_bts': False},
    ...        'STEP_2': {'fr2_operation_mode': 'One_Sector_3200MHz_IBW_2T2R_SU_MIMO',
    ...                   'reconfigure_sectors': None,
    ...                    'reset_bts': False},
    ...        'STEP_3': {'fr2_operation_mode': 'Two_Sector_1600MHz_PER_SECTOR_IBW_2T2R_SU_MIMO',
    ...                   'reconfigure_sectors': 'addition',
    ...                    'reset_bts': False}}
    ...    - ru_id (int, optional): The id of radio unit based on Test Line configuration. Defaults to 0.
    ...    - path_scf_one_sector (str, optional): Path to SCF with one sector. Input for sector reconfiguration
    ...      delta file. Specify it if any reconfigure_sectors param from ibw_reconfiguration_flow is not None.
    ...      Defaults to None.
    ...    - path_scf_two_sectors (str, optional): Path to SCF with two sectors. Input for sector reconfiguration
    ...      delta file. Must be specified if any reconfigure_sectors param from ibw_reconfiguration_flow is not None.
    ...      Defaults to None.
    ...    - log_path (str, optional): Log path. Defaults to LOG_PATH.
    [Arguments]
    ...    ${ibw_reconfiguration_flow}
    ...    ${ru_id}=${0}
    ...    ${path_scf_one_sector}=${None}
    ...    ${path_scf_two_sectors}=${None}
    ...    ${log_path}=${LOG_PATH}

    FOR  ${reconfiguration}  IN  @{ibw_reconfiguration_flow}
        ${reconfiguration_details}=    Get From Dictionary    ${ibw_reconfiguration_flow}    ${reconfiguration}
        Run Keyword If    '${reconfiguration_details['reset_bts']}' == '${True}'
        ...    Reset BTS And Wait For OnAir
        Modify IBW And Check Fault Radio Autonomous Reset
        ...    ru_id=${ru_id}
        ...    fr2_operation_mode=${reconfiguration_details['fr2_operation_mode']}
        ...    reconfigure_sectors=${reconfiguration_details['reconfigure_sectors']}
        ...    path_scf_one_sector=${path_scf_one_sector}
        ...    path_scf_two_sectors=${path_scf_two_sectors}
        ...    log_path=${log_path}
    END

Modify IBW And Check Fault Radio Autonomous Reset
    [Arguments]
    ...    ${ru_id}
    ...    ${fr2_operation_mode}
    ...    ${log_path}
    ...    ${reconfigure_sectors}=${None}
    ...    ${path_scf_one_sector}=${None}
    ...    ${path_scf_two_sectors}=${None}
    ...    ${timeout}=${1200}

    Allow RU Reset Alarms
    Reconfigure FR2 Operation Mode
    ...    ru_id=${ru_id}
    ...    operation_mode=${fr2_operation_mode}
    ...    log_path=${log_path}
    ...    reconfigure_sectors=${reconfigure_sectors}
    ...    path_scf_one_sector=${path_scf_one_sector}
    ...    path_scf_two_sectors=${path_scf_two_sectors}
    Wait Until Keyword Succeeds    15x    2s    gnbalarm.verify_alarm_is_active
    ...    fault_name=Radio autonomous reset as recovery action
    gnbru.wait_for_all_radio_unit_statuses    availability_status=online    timeout=${timeout}
    gnbbbu.wait for site to be onair    timeout=${timeout}
    gnbcell.wait_for_all_cells_to_be_onair    timeout=${timeout}
    Disallow RU Reset Alarms

Reconfigure FR2 Operation Mode
    [Arguments]
    ...    ${ru_id}
    ...    ${operation_mode}
    ...    ${log_path}
    ...    ${reconfigure_sectors}=${None}
    ...    ${path_scf_one_sector}=${None}
    ...    ${path_scf_two_sectors}=${None}
    Create admin session with default alias
    ${connection}=    connections.get_default_admin_connection_alias
    Create Selenium Session    admin_connection=${connection}

    ${cell_distnames}=     radio_keywords.get_cell_info_from_ru    ru_id=${ru_id}
    ...                                                            info=dn
    FOR  ${dist_name}  IN  @{cell_distnames}
         webui.set_parameter_value
         ...    dist_name=${dist_name}
         ...    filter_param=Operation mode for FR2 RU
         ...    abbr=fr2OperationMode
         ...    new_value=${operation_mode}
    END
    Run Keyword If    '${reconfigure_sectors}' != '${None}'
    ...    Reconfigure Sectors
    ...    sector_reconfiguration_type=${reconfigure_sectors}
    ...    path_scf_two_sectors=${path_scf_two_sectors}
    ...    path_scf_one_sector=${path_scf_one_sector}
    ...    log_path=${log_path}
    Is BTS not busy
    webui.validate_plan
    ${activation_succeded}
    ...    webui.activate_plan
    ...    timeout=120
    Run Keyword If    not ${activation_succeded}
    ...    Fail    msg=Plan activation failed! Please verify delta and scf files.
    [Teardown]    Close Selenium Session

Reconfigure Sectors
    [Arguments]
    ...    ${sector_reconfiguration_type}
    ...    ${log_path}
    ...    ${path_scf_two_sectors}=${None}
    ...    ${path_scf_one_sector}=${None}
    ${delta}=    json_delta.generate_json_delta
    ...    base_scf=${path_scf_one_sector}
    ...    custom_scf=${path_scf_two_sectors}
    ...    delta_file=delta_add_sector
    ...    hostname=${log_path}

    ${sw_stream}=    gnbbbu.get_bts_sw_release_name
    ${config_index}=    Set Variable  ${1}
    ${plan_name}=    Set Variable If  """${sw_stream}""">="""SBTS25R2"""
    ...              CONF-${config_index}_${delta.split("/")[-1].split(".")[0]}
    ...              CONF-${config_index}

    Run Keyword If    '${sector_reconfiguration_type}' == 'addition'
    ...    Add Sector
    ...    path_to_delta=${delta}
    ...    path_to_scf=${path_scf_one_sector}
    ...    plan_to_copy_from=${plan_name}
    ...    log_path=${log_path}
    ...    ELSE IF    '${sector_reconfiguration_type}' == 'deletion'
    ...    Remove Sector
    ...    path_to_delta=${delta}
    ...    ELSE    Fail
    ...    Unknown sector_reconfiguration_type given: '${sector_reconfiguration_type}'.
    ...    Supported types: 'addition' and 'deletion'.

Add Sector
    [Arguments]
    ...    ${path_to_scf}
    ...    ${plan_to_copy_from}
    ...    ${log_path}
    ...    ${path_to_delta}=${None}
    ...    ${delta_operation}=added
    ${new_scf_path}=    Run keyword If  '${delta_operation}'!='removed'
    ...    json_delta.inject_delta_to_commissioning
    ...    json_delta=${path_to_delta}
    ...    output_path=${log_path}/
    ...    file_name=${path_to_scf}
    ...    ELSE    Set Variable    ${path_to_scf}
    webui.load_commissioning_file_and_check_load_status
    ...    file_path=${new_scf_path}
    Private Add Cell Object
    ...    path_to_delta=${path_to_delta}
    ...    plan_to_copy_from=${plan_to_copy_from}
    ...    delta_operation=${delta_operation}
    Private Add Cell Relations
    ...    path_to_delta=${path_to_delta}
    ...    plan_to_copy_from=${plan_to_copy_from}
    ...    delta_operation=${delta_operation}
    Private Add Cell Groups
    ...    path_to_delta=${path_to_delta}
    ...    plan_to_copy_from=${plan_to_copy_from}
    ...    delta_operation=${delta_operation}
    Add NR Power Saving Group
    ...    path_to_delta=${path_to_delta}
    ...    plan_to_copy_from=${plan_to_copy_from}
    ...    delta_operation=${delta_operation}

Remove Sector
    [Arguments]
    ...    ${path_to_delta}
    ...    ${delta_operation}=added
    Private Remove Cell Object
    ...    path_to_delta=${path_to_delta}
    ...    delta_operation=${delta_operation}
    Private Remove Cell Relations
    ...    path_to_delta=${path_to_delta}
    ...    delta_operation=${delta_operation}
    Private Remove Cell Groups
    ...    path_to_delta=${path_to_delta}
    ...    delta_operation=${delta_operation}
    Remove NR Power Saving Group
    ...    path_to_delta=${path_to_delta}
    ...    delta_operation=${delta_operation}

Remove NR Power Saving Group
    [Arguments]
    ...    ${path_to_delta}
    ...    ${delta_operation}
    ...    ${pattern}=(NRPGRP-)[^/]*$
    ${nrpgrp_objects}    scf_obj.get_object_info_form_delta    json_delta_file=${path_to_delta}
    ...                                                        pattern=${pattern}
    ...                                                        operation=${delta_operation}

    FOR  ${dist_name}  IN  @{nrpgrp_objects}
         webui.remove_object    object_name=${dist_name}
         ...                    timeout=120
    END

Add NR Power Saving Group
    [Arguments]
    ...    ${path_to_delta}
    ...    ${delta_operation}
    ...    ${plan_to_copy_from}
    ...    ${pattern}=(NRPGRP-)[^/]*$

    ${nrpgrp_objects}    scf_obj.get_object_info_form_delta    json_delta_file=${path_to_delta}
    ...                                                        pattern=${pattern}
    ...                                                        operation=${delta_operation}

    FOR  ${dist_name}  IN  @{nrpgrp_objects}
         webui.add_object    object_name=${nrpgrp_objects['${dist_name}']['object_name']}
         ...                 object_class_name=${nrpgrp_objects['${dist_name}']['object_class']}
         ...                 plan_to_copy_from=${plan_to_copy_from}
         ...                 copy_from=${dist_name}
         ...                 include_subobject=${True}
         ...                 id_value=${nrpgrp_objects['${dist_name}']['id']}
         ...                 is_load_default_values=${False}
         ...                 timeout=120
    END

Reset BTS And Wait For OnAir
    [Arguments]
    ...    ${onair_timeout}=1200
    gnbalarm.allow alarm    alarm=BTS Reset Cause
    gnbalarm.allow alarm    alarm=No X2 link available
    gnbalarm.allow alarm    alarm=No X2 link available for a specific LTEENB
    gnbbbu.reset_bts
    gnbcell.wait_for_all_cells_to_be_onair    timeout=${onair_timeout}
    gnbalarm.disallow alarm    alarm=No X2 link available
    gnbalarm.disallow alarm    alarm=No X2 link available for a specific LTEENB

Allow RU Reset Alarms
    gnbalarm.allow_alarm    alarm=Radio autonomous reset as recovery action
    gnbalarm.allow alarm    alarm=No X2 link available
    gnbalarm.allow alarm    alarm=No X2 link available for a specific LTEENB

Disallow RU Reset Alarms
    gnbalarm.disallow alarm    alarm=Radio autonomous reset as recovery action
    gnbalarm.disallow alarm    alarm=No X2 link available
    gnbalarm.disallow alarm    alarm=No X2 link available for a specific LTEENB
