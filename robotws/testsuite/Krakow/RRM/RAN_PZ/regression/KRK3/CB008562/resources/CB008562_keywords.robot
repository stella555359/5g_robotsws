*** Settings ***
Documentation    This is for CB008562 keywords
...              Authors: Krzysztof Domino
...              Contact: krzysztof.domino@nokia.com
...              squad: 5G_PZ_KRK_3_SG

Library    DateTime
Library    testsuite.Krakow.RRM.RAN_PZ.regression.KRK3.CB008562.resources.8562_resources.Measuring    WITH NAME    measuring
Resource    taf/rfrl/ue/robot/REAL_UE.robot
Resource    taf/rfrl/bts/robot/gnb.robot
Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py


*** Variables ***
${antenna_lines_CSV_file_cli}  results
${capabilities}    REAL_UE
${deviation}     25%
${size_packet_ul}    1320B
${parallel_streams_ul}    2
${buffer_client_ul_udp}    2M
${buffer_server_ul_udp}    2M
${interval}    1
${protocol}    udp
${duration}    4min
${COLLECT_LOGS_DURING_DATA_TRANSFER}  False
${alias}  UE


*** Keywords ***
General_SiSo_Auto_Initiate_RF_Diagnostic_test_from_WebEM_normal_mode_with_L3_call
    [Arguments]  ${cell_id}
    Start traffic
    measuring.set_and_start_rf_diagnostic_via_gui
    ${test_result}  ${RSSI}  measuring.check_diagnostic_test_results_via_gui  ${cell_id}
    Check for tput
    should be equal  ${test_result}  Pass
    should not be equal  ${RSSI}  0
    [Teardown]    measuring.remove_diagnostic_test_objects

General_SiSo_Auto_Antenna_Online_Monitoring_using_WebEM_with_break
    [Arguments]  ${cell_id}  ${break_keyword}
    Set test variable  ${cell_id}
    Start traffic
    measuring.start_antenna_line_monitoring_via_gui
    ${monitor_start_time}    DateTime.Get Current Date    result_format=timestamp
    ${end1_time}  Check for tput
    Run keyword  ${break_keyword}
    wait until keyword succeeds     15 min  1 min  Verify gNB Cell is onAir  cell_id=${cell_id}
    Start traffic
    ${second_call_time}    DateTime.Get Current Date    result_format=timestamp
    sleep  30s
    ${antenna_lines_CSV_file}   measuring.stop_antl_monitoring_and_export_to_csv
    ${stop_time}    DateTime.Get Current Date    result_format=timestamp
    Check for tput
    ${RSSI_list}  measuring.check_RSSI_in_csv_file  ${antenna_lines_CSV_file}  ${cell_id}
    ${elapsed_monitor_call1_time}    DateTime.Subtract Date From Date   ${end1_time}  ${monitor_start_time}
    ${elapsed_monitor_call2_time}    DateTime.Subtract Date From Date   ${stop_time}  ${second_call_time}
    ${judge_call1}  measuring.check_positive_RSSI_value  ${elapsed_monitor_call1_time}  ${elapsed_monitor_call2_time}  ${RSSI_list}
    should be equal  ${judge_call1}  True

General_SiSo_Auto_Antenna_Online_Monitoring_using_CLI_commands_with_break
    [Arguments]  ${cell_id}  ${break_keyword}
    Set test variable  ${cell_id}
    Start traffic
    measuring.start_antl_monitoring_via_CLI  cell_id=${cell_id}
    ${monitor_start_time}    DateTime.Get Current Date    result_format=timestamp
    ${end1_time}  Check for tput
    Run keyword  ${break_keyword}
    wait until keyword succeeds     15 min  1 min  Verify gNB Cell is onAir
    Start traffic
    ${second_call_time}    DateTime.Get Current Date    result_format=timestamp
    sleep  30s
    measuring.stop_antl_monitoring_via_CLI  output_file_name=${antenna_lines_CSV_file_cli}
    ${stop_time}    DateTime.Get Current Date    result_format=timestamp
    Check for tput
    ${RSSI_list}  measuring.check_RSSI_in_csv_file_CLI  ${antenna_lines_CSV_file_cli}  ${cell_id}
    ${elapsed_monitor_call1_time}    DateTime.Subtract Date From Date   ${end1_time}  ${monitor_start_time}
    ${elapsed_monitor_call2_time}    DateTime.Subtract Date From Date   ${stop_time}  ${second_call_time}
    ${judge_call1}  measuring.check_positive_RSSI_value  ${elapsed_monitor_call1_time}  ${elapsed_monitor_call2_time}  ${RSSI_list}
    should be equal  ${judge_call1}  True

Start traffic
    Perform Attach and Verify UE Properly Attached  alias=${alias}
    Start Data Transfer on Real UE    dt_name=DT_UL  ue_alias=${alias}  direction=ul  protocol=${protocol}  duration=${duration}
    ...  tput=${tput_ul}  parallel_streams=${parallel_streams_ul}  size_packet=${size_packet_ul}  buffer_client=${buffer_client_ul_udp}
    ...  buffer_server=${buffer_server_ul_udp}  interval=${interval}
    Wait for truput stabilization

Check for tput
    ue.Check Data Transfer is Alive     dt_name=DT_UL
    ue.Await Data Transfer Finish       dt_name=DT_UL
    ${call_finish}  DateTime.Get Current Date    result_format=timestamp
    ue.Verify Average Throughput With Deviation   dt_name=DT_UL   tput=${tput_ul}   deviation=${deviation}
    [Teardown]    ue.Detach UE   ${alias}
    [Return]  ${call_finish}

Block unblock gnb cell
    gnbcell.Block cell  cell_id=${cell_id}
    gnbcell.Unblock cell  cell_id=${cell_id}

Reset bbmod and sleep
    measuring.reset bbmod  abil_index=1
    sleep  20s

Reset RU and Verify Alarm
    [Arguments]  @{mandatory_alarms}
    Reset gNB Radio Unit
    wait until keyword succeeds  15 min  1 min  Verify Mandatory Alarms on gNB  mandatory_alarms=@{mandatory_alarms}

Allow alarms on BTS during test
    gnb_alarm.Allow Alarm         Cell blocked
    gnb_alarm.Allow Alarm         Diagnostic Files collected
    gnb_alarm.Allow Alarm         LMP connectivity detected
    gnb_alarm.Allow Alarm         NRRELNotConfiguredA3A5
    gnb_alarm.Allow Alarm         BTS Reset Cause
    gnb_alarm.Allow Alarm         Sanity Check Error
    gnb_alarm.Allow Alarm         Diagnostic Check Error

Disallow alarms on BTS after test
    gnb_alarm.Disallow Alarm      Cell blocked

