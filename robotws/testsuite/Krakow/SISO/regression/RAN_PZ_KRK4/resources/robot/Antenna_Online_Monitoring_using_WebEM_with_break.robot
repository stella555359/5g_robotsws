*** Settings ***
Documentation
...    Implementation of Antenna_Online_Monitoring_using_WebEM_with_break test case
...    author: Rafal Kawa
...    contact: rafal.kawa@nokia.com

Library     taf.rfrl.bts.devices.du.du_operations.GnbDuOperations    WITH NAME      gnbbbu
Library     taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations    WITH NAME      gnbcell
Library     taf.rfrl.bts.devices.du.alarm_verification.GnbAlarmVerification    WITH NAME    gnbalarm
Library     taf.rfrl.bts.devices.ru.ru_operations.GnbRuOperations    WITH NAME      gnbru
Library     ../python/DataTransferOperations.py    WITH NAME    data_transfer
Library     ../python/CellOperations.py   WITH NAME    cell_keywords
Library     ../python/antenna_monitoring_validator.py   WITH NAME    validator


*** Keywords ***
Antenna_Online_Monitoring_using_WebEM_with_break
    [Documentation]
    ...    Test verifies BTS behavior during antenna online monitoring. Supported measurements: ETP, RTWP, RSSI.
    ...    ARGS:
    ...    - validation_data (dict, mandatory): Dictionary containing data to validate monitoring output, where
    ...         keys are measurement names to validate and values are dicts containing validation data:
    ...         -expected_value (dict): Dictionary containing the expected value and allowed deviation.
    ...         -carrier_type (str): The antenna line monitoring csv output parameter, channel direction: RX or TX.
    ...         Example:
    ...         {"RTWP": {
    ...         "expected_value": {"call_event": {'value': -50, 'deviation': 20},
    ...                            "break_event": {'value': "-", 'deviation': None}},
    ...                            "idle_state": {'value': -80, 'deviation': 10},
    ...         "carrier_type": "RX",
    ...         },
    ...         "RSSI": {
    ...         "expected_value": {"call_event": {'value': -60, 'deviation': 20},
    ...                            "break_event": {'value': "-", 'deviation': None}},
    ...                            "idle_state": {'value': "-", 'deviation': None},
    ...         "carrier_type": "RX",
    ...         }}
    ...         Example:
    ...    - dt_info (dict, mandatory): Dictionary containing data transfer details for L3 Call.
    ...         Example:
    ...         {"SECTOR_0": {
    ...         "nrcellgrp_id": "0",
    ...         "lnrelgnbcell_id": "1",
    ...         "lncel_id": "1",
    ...         "downlink": "4300 Mbits/sec",
    ...         "uplink": "570 Mbits/sec",
    ...         "deviation": "20"
    ...         },
    ...         "SECTOR_1": {
    ...         "nrcellgrp_id": "1",
    ...         "lnrelgnbcell_id": "2",
    ...         "lncel_id": "1",
    ...         "downlink": "4300 Mbits/sec",
    ...         "uplink": "570 Mbits/sec",
    ...         "deviation": "20"
    ...         }}
    ...    - dt_duration (str, optional): Data Transfer duration in seconds. Defaults to 60s.
    ...    - break_event_name (str, optional): The name of break event triggered during antenna monitoring.
    ...      Available break events: "Block_Cells", "Reset_Radio_Units". Defaults to "Block_Cells".
    [Arguments]
    ...    ${validation_data}
    ...    ${dt_info}
    ...    ${dt_duration}=60s
    ...    ${break_event_name}=Block_Cells
    ${random_sector}=    validator.select_random_dict_element    input_dict=${dt_info}
    Start Antenna Online Monitoring During Event    event_name=L3_Call
    ...    validation_data=${validation_data}
    ...    break_event=${False}
    ...    dt_info=${random_sector}
    ...    dt_duration=${dt_duration}
    Start Antenna Online Monitoring During Event    event_name=${break_event_name}
    ...    validation_data=${validation_data}
    ...    break_event=${True}

Start Antenna Online Monitoring During Event
    [Arguments]
    ...    ${event_name}
    ...    ${validation_data}
    ...    ${break_event}=${None}
    ...    ${dt_info}=${None}
    ...    ${dt_duration}=${None}
    gnbbbu.select_antenna_lines_for_monitoring_via_gui
    gnbbbu.start_antenna_line_monitoring_via_gui
    ${time}=    Run Keyword If    '${event_name}' == 'L3_Call'
    ...    Start Data Transfer DL and UL    dt_info=${dt_info}    dt_duration=${dt_duration}
    ...    ELSE IF    '${event_name}' == 'Block_Cells'
    ...    Block Unblock All Cells And Wait For OnAir
    ...    ELSE IF    '${event_name}' == 'Reset_Radio_Units'
    ...    Reset All Radio Units And Wait For OnAir
    gnbbbu.stop_antenna_line_monitoring_via_gui
    ${path_csv}=    gnbbbu.export_monitored_value_to_csv_via_gui
    ${parsed_data}=    validator.parse_antenna_monitoring_output    path_csv_file=${path_csv}

    FOR  ${measurement_name}  IN  @{validation_data}
        ${meas_monitoring_data}=    Get From Dictionary    ${parsed_data}    ${measurement_name}
        ${meas_validation_data}=    Get From Dictionary    ${validation_data}    ${measurement_name}
        ${cell_ids}=    Run Keyword If    '${break_event}' == '${True}'
        ...    cell_keywords.get_current_cells_dist_name    base_cell_name=${True}
        ...    ELSE    cell_keywords.get_cell_ids_with_specific_channel_direction
        ...    direction=${meas_validation_data['carrier_type']}
        ...    cell_group_id=${dt_info['nrcellgrp_id']}
        ${l3_call_time}=    Run Keyword If    '${event_name}' == 'L3_Call'
        ...    validator.extract_data_transfer_time_related_to_measurement
        ...    time=${time}
        ...    carrier_type=${meas_validation_data['carrier_type']}
        ${event_time} =	Set Variable If	'${event_name}' == 'L3_Call'    ${l3_call_time}    ${time}
        Run Keyword And Continue On Failure    Check Antenna Monitoring Output Data
        ...    monitoring_data=${meas_monitoring_data}
        ...    cells_to_check=${cell_ids}
        ...    event_time=${event_time}
        ...    expected_value=${meas_validation_data['expected_value']}
        ...    break_event=${break_event}
        ...    carrier_type=${meas_validation_data['carrier_type']}
    END

Check Antenna Monitoring Output Data
    [Arguments]
    ...    ${monitoring_data}
    ...    ${cells_to_check}
    ...    ${event_time}
    ...    ${expected_value}
    ...    ${break_event}
    ...    ${carrier_type}
    Run Keyword And Continue On Failure    validator.check_cells_in_antenna_monitoring_data
    ...    monitoring_data=${monitoring_data}
    ...    carrier_type=${carrier_type}
    IF    '${break_event}' == '${True}'
        validator.check_antenna_monitoring_values_during_event
        ...    monitoring_data=${monitoring_data}
        ...    event_time=${event_time}
        ...    expected=${expected_value['break_event']}
        ...    cells=${cells_to_check}
        ...    carrier_type=${carrier_type}
        ...    event_delay=${0}
    ELSE
        validator.check_antenna_monitoring_values_during_event
        ...    monitoring_data=${monitoring_data}
        ...    event_time=${event_time}
        ...    expected=${expected_value['call_event']}
        ...    cells=${cells_to_check}
        ...    carrier_type=${carrier_type}
        ...    idle_state=${False}
        validator.check_antenna_monitoring_values_during_event
        ...    monitoring_data=${monitoring_data}
        ...    event_time=${event_time}
        ...    expected=${expected_value['idle_state']}
        ...    cells=${cells_to_check}
        ...    carrier_type=${carrier_type}
        ...    idle_state=${True}
    END

Start Data Transfer DL and UL
    [Arguments]
    ...    ${dt_info}
    ...    ${dt_duration}
    &{event_time} =	data_transfer.start_tcp_data_transfer    duration=${dt_duration}
    ...    expected_dl_tput=${dt_info['downlink']}
    ...    expected_ul_tput=${dt_info['uplink']}
    ...    tolerance=${dt_info['deviation']}
    ...    lnrelgnbcell_id=${dt_info['lnrelgnbcell_id']}
    ...    lncel_id=${dt_info['lncel_id']}
    Save Monitoring Data After Event
    [Return]    &{event_time}

Save Monitoring Data After Event
    [Arguments]    ${duration}=60
    BuiltIn.sleep    ${duration}

Block Unblock All Cells And Wait For OnAir
    [Arguments]
    ...    ${onair_timeout}=600
    ...    ${interval}=10
    ...    ${sleep_intervals}=6
    Allow No X2 Alarms
    gnbalarm.allow_alarm    alarm=Cell blocked
    gnbcell.block_all_cells
    gnbcell.verify_all_cells_are_blocked
    Wait For Next Monitoring Interval    interval=${interval}
    ${start_time}=    validator.get_current_bts_datetime
    ${time_to_wait} =	Evaluate  int(${sleep_intervals}) * int(${interval})
    Wait For Next Monitoring Interval    interval=${time_to_wait}
    gnbcell.unblock_all_cells
    ${end_time}=    validator.get_current_bts_datetime
    gnbcell.wait_for_all_cells_to_be_onair    timeout=${onair_timeout}
    Disallow No X2 Alarms
    gnbalarm.disallow alarm    alarm=Cell blocked
    &{event_time} =	Create Dictionary    start_time=${start_time}    end_time=${end_time}
    [Return]    &{event_time}

Reset All Radio Units And Wait For OnAir
    [Arguments]
    ...    ${onair_timeout}=600
    ...    ${reset_timeout}=300
    ...    ${interval}=10
    Allow No X2 Alarms
    gnbru.reset_all_radio_unit  timeout=${reset_timeout}
    Wait For Next Monitoring Interval    interval=${interval}
    ${start_time}=    validator.get_current_bts_datetime
    gnbru.wait_for_all_radio_units_to_be_online
    ${end_time}=    validator.get_current_bts_datetime
    gnbcell.wait_for_all_cells_to_be_onair    timeout=${onair_timeout}
    Disallow No X2 Alarms
    &{event_time} =	Create Dictionary    start_time=${start_time}    end_time=${end_time}
    [Return]    &{event_time}

Wait For Next Monitoring Interval
    [Arguments]
    ...    ${interval}=10
    builtin.sleep    ${interval}

Allow No X2 Alarms
    gnbalarm.allow alarm    alarm=No X2 link available
    gnbalarm.allow alarm    alarm=No X2 link available for a specific LTEENB

Disallow No X2 Alarms
    gnbalarm.disallow alarm    alarm=No X2 link available
    gnbalarm.disallow alarm    alarm=No X2 link available for a specific LTEENB
