*** Settings ***
Documentation
...    Implementation of Switching_On_Cell_NR test case
...    author: Rafal Kawa
...    contact: rafal.kawa@nokia.com

Library   DateTime
Library   taf.rfrl.bts.devices.du.pm_counters.GnbPmCounter    WITH NAME      gnbcounter
Library   taf.rfrl.bts.devices.du.pm_counters.ComparePmCounters    WITH NAME      comparecounter
Library   taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations    WITH NAME      gnbcell
Library   taf.rfrl.bts.devices.du.commissioning.GnbCommissioning    WITH NAME    gnbscf
Library   taf.rfrl.bts.devices.du.du_operations.GnbDuOperations    WITH NAME      gnbbbu
Library   taf.rfrl.procedures.resources.python.json_delta_scf.JsonDeltaCommissioning  WITH NAME  json_delta
Library   taf/rfrl/procedures/resources/python/delta_configurator/interface.py    WITH NAME  delta
Library   ../python/DataTransferOperations.py    WITH NAME    data_transfer
Library   ../python/CellOperations.py   WITH NAME    cell_keywords
Library   ../python/ScfObjectOperations.py   WITH NAME    scf_obj

Resource    taf/rfrl/procedures/resources/robot/Commissioning.robot


*** Keywords ***
Switching_On_Cell_NR
    [Documentation]
    ...    Test verifies BTS behavior during NR cells switching on procedure.
    ...    ARGS:
    ...    - path_delta_nrpgrp (json, default): Path to json delta file with NRPGRP object pre-configured for PSG
    ...      Control Logic Improvement functionality (5G_RAN_USR_COM_16915).
    ...    - dt_info (dict, default): Dictionary containing data transfer details for L3 Call with Cells defined in
    ...      lbpsCellList of NRPGRP object provided in path_delta_nrpgrp.
    ...         Example:
    ...         {"lncel_id": "1",
    ...         "lnrelgnbcell_id": "0",
    ...         "downlink": "4300 Mbits/sec"}
    ...    - delta_enable_power_saving (list, default): List containg delta file to activate Cells Power Saving.
    ...         Example:
    ...         [{'distName': 'MRBTS-{}/NRBTS-{}',
    ...           'operation': 'update',
    ...           'parameters': [{'operation': 'update',
    ...                           'parameterName': 'actLbpsCtrlLogicEnh',
    ...                           'value': 'true'}]},
    ...          {'distName': 'MRBTS-{}/NRBTS-{}',
    ...           'operation': 'update',
    ...           'parameters': [{'operation': 'update',
    ...           'parameterName': 'actNrLBPowerSaving',
    ...           'value': 'true'}]},
    ...          {'distName': 'MRBTS-{}/NRBTS-{}',
    ...           'operation': 'update',
    ...           'parameters': [{'operation': 'update',
    ...           'parameterName': 'actCoordinated4g5gPowerSaving',
    ...           'value': 'cellDeactAndReact'}]}] ]
    ...    - delta_disable_power_saving (list, default): List containg delta file to deactivate Cells Power Saving.
    ...         Example:
    ...         [{'distName': 'MRBTS-{}/NRBTS-{}',
    ...           'operation': 'update',
    ...           'parameters': [{'operation': 'update',
    ...                           'parameterName': 'actLbpsCtrlLogicEnh',
    ...                           'value': 'false'}]},
    ...          {'distName': 'MRBTS-{}/NRBTS-{}',
    ...           'operation': 'update',
    ...           'parameters': [{'operation': 'update',
    ...           'parameterName': 'actNrLBPowerSaving',
    ...           'value': 'false'}]},
    ...          {'distName': 'MRBTS-{}/NRBTS-{}',
    ...           'operation': 'update',
    ...           'parameters': [{'operation': 'update',
    ...           'parameterName': 'actCoordinated4g5gPowerSaving',
    ...           'value': 'disabled'}]}] ]
    ...    - path_scf_base (str, optional): Path to default SCF. Defaults to scf_local_path.
    ...    - log_path (str, optional): Log path. Defaults to LOG_PATH.
    ...    - nrpgrp_id (str, optional): The ID of NRPGRP object.
    ...    - nrpmrnl_id (str, optional): The ID of NRPMRNL object.
    ...    - dt_deviation (str, optional): The deviation of data transfer performed during switching cell on procedure.
    ...    - cell_id (str, optional): The ID of cell to be used for verification of switching off/on procedure.
    ...          If 'random', random cell from lbpsCellList of NRPGRP object will be selected. Defaults to 'random'.
    [Arguments]
    ...    ${path_delta_nrpgrp}
    ...    ${dt_info}
    ...    ${delta_enable_power_saving}
    ...    ${delta_disable_power_saving}
    ...    ${path_scf_base}=${scf_local_path}
    ...    ${log_path}=${LOG_PATH}
    ...    ${nrpgrp_id}=1
    ...    ${nrpmrnl_id}=1
    ...    ${dt_deviation}=70
    ...    ${cell_id}=random

    Set Energy Saving Parameters    delta=${delta_disable_power_saving}
    Perform Online Json Delta Commissioning
    ...    delta=${path_delta_nrpgrp}
    ${scf_custom_nrpgrp}=    gnbbbu.get_bts_configuration_file
    ...    local_dir=${log_path}
    ...    config_type=configuration
    ...    filename=GNB_SCF_WITH_CUSTOM_NRPGRP.xml
    ${switch_on_load_window}=    scf_obj.get_param_from_scf_object
    ...    param_name=lbpsMonWinForCellSOn
    ...    object_class_name=com.nokia.srbts.nrbts:NRPGRP
    ...    object_dist_name_pattern=NRPGRP-${nrpgrp_id}
    ${switch_off_load_window}=    scf_obj.get_param_from_scf_object
    ...    param_name=lbpsMonWinForCellSOff
    ...    object_class_name=com.nokia.srbts.nrbts:NRPGRP
    ...    object_dist_name_pattern=NRPGRP-${nrpgrp_id}
    ${cell_to_switch_off}=    Run Keyword If    '${cell_id}' == 'random'
    ...    Set Random Cell To Switch Off    nrpgrp_id=${nrpgrp_id}
    ...    ELSE    Set Variable    ${cell_id}
    ${pm_interval}=    scf_obj.get_param_from_scf_object
    ...    param_name=miNrCellAvailability
    ...    object_class_name=com.nokia.srbts.nrbts:NRPMRNL
    ...    object_dist_name_pattern=NRPMRNL-${nrpmrnl_id}

    ${counters_before_test}=    Get Power Saving Counters
    Set Energy Saving Parameters    delta=${delta_enable_power_saving}
    cell_keywords.wait_for_cell_energy_saving_status
    ...    cell_id=${cell_to_switch_off}
    ...    energy_saving_state=EnergySaving
    ...    timeout=${switch_off_load_window}
    ...    interval=${5}
    ${dt_start_time}=    DateTime.get_current_date
    data_transfer.start_tcp_data_transfer
    ...    duration=${switch_on_load_window}s
    ...    expected_dl_tput=${dt_info['downlink']}
    ...    tolerance=${dt_deviation}
    ...    lnrelgnbcell_id=${dt_info['lnrelgnbcell_id']}
    ...    lncel_id=${dt_info['lncel_id']}
    ${dt_finish_time}=    DateTime.get_current_date
    gnbcell.verify_cell_energy_saving_state
    ...    cell_id=${cell_to_switch_off}
    ...    energy_saving_state=notEnergySaving
    gnbcell.verify_cell_statuses
    ...    cell_id=${cell_to_switch_off}
    ...    operational_state=enabled

    Set Energy Saving Parameters    delta=${delta_disable_power_saving}
    gnbcounter.wait_for_next_pm_period    interval=${pm_interval}    delay=${60}
    ${counters_after_test}=    Get Power Saving Counters
    ${exp_cell_psm_time}=    Evaluate Expected Cell Power Saving Mode Time
    ...    dt_kw_start_time=${dt_start_time}
    ...    dt_kw_finish_time=${dt_finish_time}
    Run Keyword And Continue On Failure    Check Power Saving Counter    counter_id=M55601C00502
    ...    cell_id=${cell_to_switch_off}
    ...    counters_initial=${counters_before_test}
    ...    counters_final=${counters_after_test}
    ...    expected_value=${1}
    ...    tolerance=${0}
    Check Power Saving Counter    counter_id=M55601C00501
    ...    cell_id=${cell_to_switch_off}
    ...    counters_initial=${counters_before_test}
    ...    counters_final=${counters_after_test}
    ...    expected_value=${exp_cell_psm_time}
    ...    tolerance=${switch_on_load_window}
    [Teardown]    Perform Online Json Delta Commissioning With Delta Generator
    ...    base_scf=${scf_custom_nrpgrp}
    ...    custom_scf=${path_scf_base}
    ...    delta_file_name=json_delta_default_nrpgrp
    ...    delta_result_file_path=${log_path}

Set Random Cell To Switch Off
    [Arguments]
    ...    ${nrpgrp_id}
    ${random_cell_to_switch_off}=    scf_obj.get_nested_param_from_scf_structure
    ...    nested_param_name=nrCellId
    ...    structure_name=lbpsCellList
    ...    object_class_name=com.nokia.srbts.nrbts:NRPGRP
    ...    object_dist_name_pattern=NRPGRP-${nrpgrp_id}
    scf_obj.set_lowermost_value_to_power_saving_cell_switch_off_order
    ...    cell_id=${random_cell_to_switch_off}
    ...    nrpgrp_dist_name_pattern=NRPGRP-${nrpgrp_id}
    [Return]    ${random_cell_to_switch_off}

Get Power Saving Counters
    ${counter_names}=	Create List    M55601C00501    M55601C00502
    ${counters}=    gnbcounter.get_simplified_cell_pm_counters_result    counter_list=${counter_names}
    [Return]    ${counters}

Evaluate Expected Cell Power Saving Mode Time
    [Arguments]
    ...    ${dt_kw_start_time}
    ...    ${dt_kw_finish_time}
    ${kw_dt_time}=    DateTime.subtract_date_from_date
    ...    date1=${dt_kw_finish_time}
    ...    date2=${dt_kw_start_time}
    ...    exclude_millis=${True}
    ${cell_pm_time}=    Evaluate    int(${kw_dt_time})
    [Return]    ${cell_pm_time}

Check Power Saving Counter
    [Arguments]
    ...    ${cell_id}
    ...    ${counter_id}
    ...    ${counters_initial}
    ...    ${counters_final}
    ...    ${expected_value}
    ...    ${tolerance}=${0}
    ${cell_list}=	Create List    NRCELL-${cell_id}
    ${counter_list}=	Create List    ${counter_id}
    ${expected_value_int}=    Evaluate    int(${expected_value})
    ${diff}=    comparecounter.calculate_pm_counter_diff
    ...    simplified_result1=${counters_initial}
    ...    simplified_result2=${counters_final}
    comparecounter.verify_pm_counter_diff
    ...    counter_diff_dict=${diff}
    ...    counter_ids_to_check=${counter_list}
    ...    cell_ids_to_check=${cell_list}
    ...    expected_diff=${expected_value_int}
    ...    tolerance=${tolerance}

Set Energy Saving Parameters
    [Arguments]
    ...    ${delta}
    gnbscf.perform_bts_delta_commissioning    delta=${delta}

Perform Online Json Delta Commissioning
    [Arguments]
    ...    ${delta}
    ...    ${bts_type}=GNB
    ...    ${use_proxy}=${False}
    ...    ${timeout}=180
    delta.perform_online_delta_commissioning   path_to_delta=${delta}
    ...                                        bts_type=${bts_type}
    ...                                        use_proxy=${use_proxy}
    ...                                        timeout=${timeout}

Perform Online Json Delta Commissioning With Delta Generator
    [Arguments]
    ...    ${base_scf}
    ...    ${custom_scf}
    ...    ${delta_result_file_path}
    ...    ${delta_file_name}=json_delta
    ...    ${bts_type}=GNB
    ...    ${use_proxy}=${False}
    ...    ${timeout}=180
    ${delta}=    json_delta.generate_json_delta
    ...    base_scf=${base_scf}
    ...    custom_scf=${custom_scf}
    ...    delta_file=${delta_file_name}
    ...    hostname=${delta_result_file_path}
    Perform Online Json Delta Commissioning    delta=${delta}
    ...                                        bts_type=${bts_type}
    ...                                        use_proxy=${use_proxy}
    ...                                        timeout=${timeout}
