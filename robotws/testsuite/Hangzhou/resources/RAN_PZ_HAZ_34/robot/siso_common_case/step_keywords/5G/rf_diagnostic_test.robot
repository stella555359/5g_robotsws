*** Settings ***
Documentation    This is common keywords for siso ALD related cases
...              Please do not modify the file without notification to author
...              Author: zhihao.shi
...              Contact: zhihao.shi@nokia-sbell.com
...              Squard: HZ SG4

Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot

*** Keywords ***
Delete RFTHLD If Exist
    ${activate_plan_despite_errors}    set variable if    ${if_pdl_check}    ${False}    ${True}
    ${object_list}    selenium_coam.get_object_name_list    object_name=TEST
    ${test_num}   Get Length   ${object_list}
    FOR    ${object}    IN    @{object_list}
        Exit For Loop If  ${test_num}==${0}
        selenium_coam.remove_object    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/${object}    timeout=15
    END
    Run Keyword If  ${test_num}!=${0}    selenium_coam.validate_plan
    Run Keyword If  ${test_num}!=${0}    selenium_coam.activate_plan    activate_plan_despite_errors=${activate_plan_despite_errors}

Set default value for RFTHLD If Feature 956 Enabled
    ${activate_plan_despite_errors}    set variable if    ${if_pdl_check}    ${False}    ${True}
    ${Active_SW_version}    Get Active SW Version
    ${status}  run keyword and return status  Should Contain any  ${Active_SW_version}  SBTS24R2  SBTS24R3  SBTS25R1
	${activate_plan_despite_errors}    set variable if    ${if_pdl_check}    ${False}    ${True}
    selenium_coam.add_object    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1
    ...    object_class_name=TEST    id_value=${1}    timeout=15
    selenium_coam.add_object    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/TEST-1
    ...    object_class_name=RFTHLD    is_load_default_values=${True}    id_value=${1}    timeout=15
    Run keyword if  ${status}    selenium_coam.remove_element
        ...    dist_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/TEST-1/RFTHLD-1
        ...    abbr=bandRfTestThresholds    filter_param=LTE band RF test thresholds
        ...    node_index=${0}
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=${activate_plan_despite_errors}

Verify value for RFTHLD If Feature 956 Enabled
    [Arguments]  ${totalRFPowerHighThreshold}=${120}    ${totalRFPowerLowThreshold}=${0.1}    ${rFPowerErrorHighThreshold}=${8}
    ...    ${rFPowerErrorLowThreshold}=${-8}    ${rxAntennaRSSIHighThreshold}=${-30}    ${rxAntennaRSSILowThreshold}=${-110}
    ...    ${rxAntennaRTWPHighThreshold}=${-30}    ${rxAntennaRTWPLowThreshold}=${-110}    ${txAntennaVSWRHighThreshold}=${3}
    ${modify_params}  create list
    ${dist_name}   Set Variable  MRBTS-${mrbtsID}/MNL-1/MNLENT-1/TEST-1/RFTHLD-1
    ${item}  create dictionary  dist_name=${dist_name}
    ...    filter_param=Total RF power high threshold  p_name=totalRFPowerHighThreshold  value=${totalRFPowerHighThreshold}
    append to list  ${modify_params}  ${item}
    ${item}  create dictionary  dist_name=${dist_name}
    ...    filter_param=Total RF power low threshold  p_name=totalRFPowerLowThreshold  value=${totalRFPowerLowThreshold}
    append to list  ${modify_params}  ${item}
    ${item}  create dictionary  dist_name=${dist_name}
    ...    filter_param=RF power error high threshold  p_name=rFPowerErrorHighThreshold  value=${rFPowerErrorHighThreshold}
    append to list  ${modify_params}  ${item}
    ${item}  create dictionary  dist_name=${dist_name}
    ...    filter_param=RF Power error low threshold  p_name=rFPowerErrorLowThreshold  value=${rFPowerErrorLowThreshold}
    append to list  ${modify_params}  ${item}
    ${item}  create dictionary  dist_name=${dist_name}
    ...    filter_param=High RSSI threshold  p_name=rxAntennaRSSIHighThreshold  value=${rxAntennaRSSIHighThreshold}
    append to list  ${modify_params}  ${item}
    ${item}  create dictionary  dist_name=${dist_name}
    ...    filter_param=Low RSSI threshold  p_name=rxAntennaRSSILowThreshold  value=${rxAntennaRSSILowThreshold}
    append to list  ${modify_params}  ${item}
    ${item}  create dictionary  dist_name=${dist_name}
    ...    filter_param=RTWP high threshold  p_name=rxAntennaRTWPHighThreshold  value=${rxAntennaRTWPHighThreshold}
    append to list  ${modify_params}  ${item}
    ${item}  create dictionary  dist_name=${dist_name}
    ...    filter_param=RTWP low threshold  p_name=rxAntennaRTWPLowThreshold  value=${rxAntennaRTWPLowThreshold}
    append to list  ${modify_params}  ${item}
    ${item}  create dictionary  dist_name=${dist_name}
    ...    filter_param=TX antenna VSWR high threshold  p_name=txAntennaVSWRHighThreshold  value=${txAntennaVSWRHighThreshold}
    append to list  ${modify_params}  ${item}
    Modify Parameters On Webem  modify_params=${modify_params}  is_activate=${False}
    ${defErrs_dic}    run keyword and continue on failure    selenium_coam.get_definition_errors
    ${list_num}   Get Length   ${defErrs_dic}
    Should be true    ${list_num}==${11}
    selenium_coam.undo_changes

Modify actRemoteRfDiag Parameter
    [Arguments]    ${actRemoteRfDiag}=true
    ${currect_status}    selenium_coam.get_parameter_value    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...    filter_param=Activate remote RF diagnostic test
    ...    abbr=actRemoteRfDiag
    ${modify_params}  create list
    ${item}  create dictionary  dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...    filter_param=Activate remote RF diagnostic test  p_name=actRemoteRfDiag  value=${actRemoteRfDiag}
    append to list  ${modify_params}  ${item}
    Run Keyword If    '${currect_status}'!='${actRemoteRfDiag}'    Modify Parameters On Webem    modify_params=${modify_params}

RF Diagnostic Test Setup
    [Arguments]    ${cell}=All NR cells    ${bts_thresholds}=${None}     ${bands_thresholds}=${None}
    Log To Console    RF Diagnostic Test Setup
    selenium_coam.configure_rf_diagnostic_test    cell=${cell}    bts_thresholds=${bts_thresholds}
    ...    bands_thresholds=${bands_thresholds}
    run keyword if  ${bands_thresholds}!=${None} or ${bts_thresholds}!=${None}      selenium_coam.save_thresholds
    selenium_coam.start_rf_diagnostic_test    timeout=${180}

RF statistics diagnostic test setup
    [Arguments]    ${radio_id}=${1}    ${bts_thresholds}=${None}
    Log To Console    RF statistics diagnostic test setup
    selenium_coam.configure_rf_diagnostic_test    bts_thresholds=${bts_thresholds}    cell=All NR cells
    run keyword if  ${bts_thresholds}!=${None}      selenium_coam.save_thresholds
    selenium_coam.configure_statistics_diagnostic_test    radio=RMOD-${radio_id}
    selenium_coam.start_statistics_diagnostic_test

Check General Test Information
    [Arguments]    ${cell_id}=1    ${forward_expected_result}=Pass    ${reverse_expected_result}=Pass
    ...    ${expected_outcome}=Pass    ${expected_low}=-1     ${expected_high}=120    ${stream}=SBTS00
    ${boundary}    get the boundary of stream    stream=${stream}
    ${general_result}    selenium_coam.get_general_test_information    cell_id=${cell_id}
    FOR    ${item}    IN    @{general_result}
        ${start_time}    get from dictionary    ${item}    BTS test start time GMT +0800
        ${stop_time}    get from dictionary    ${item}    BTS test stop time GMT +0800
        ${start_time_value}    split string    ${start_time}    ${SPACE}
        ${stop_time_value}    split string    ${stop_time}    ${SPACE}
        ${time_differ}    robot.libraries.DateTime.subtract_time_from_time    ${stop_time_value}[-1]    ${start_time_value}[-1]
        #${time}    evaluate    abs(${time_differ})
        #should be equal   ${time}    ${1.0}
        should be true    ${time_differ} < ${30.0}
        ${forward_result}    get from dictionary    ${item}    Forward test disposition
        should be equal    ${forward_result}    ${forward_expected_result}
        ${reverse_result}    get from dictionary    ${item}    Reverse test disposition
        should be equal    ${reverse_result}    ${reverse_expected_result}
        ${outcome}    get from dictionary    ${item}    Outcome
        should be equal    ${outcome}    ${expected_outcome}
        ${result}    get from dictionary    ${item}   Result
        should be equal    ${result}    success
        ${value_forward_expected}   Run Keyword If  '${boundary}'=='new_version'
        ...     get from dictionary    ${item}   Forward expected transmit RF power
        Run Keyword If  '${boundary}'=='new_version'
        ...     should be true    ${expected_low} < ${value_forward_expected} < ${expected_high}
    END

Check Statistics General Information
    [Arguments]    ${radio_id}=1    ${outcome}=Pass
    ${general_detail_result}    selenium_coam.get_statistics_general_test_information    radio_id=RMOD-${radio_id}
    FOR    ${item}    IN    @{general_detail_result}
        ${start_time}    get from dictionary    ${item}   BTS test start time GMT +0800
        ${stop_time}      get from dictionary    ${item}   BTS test stop time GMT +0800
        ${start_time_value}    split string    ${start_time}    ${SPACE}
        ${stop_time_value}    split string    ${stop_time}    ${SPACE}
        ${differ}    robot.libraries.DateTime.subtract_time_from_time    ${stop_time_value}[-1]    ${start_time_value}[-1]
        #${time}    evaluate    abs(${differ})
        should be true    ${differ} < ${30.0}
        ${result}    get from dictionary    ${item}   Result
        should be equal    ${result}    success
        ${outcome_value}    get from dictionary    ${item}    Outcome
        should be equal    ${outcome_value}    ${outcome}
        ${uptime}    get from dictionary    ${item}    Uptime (sec)
        should be true    0 < ${uptime}
    END

Check RF Temperature Supervision
    [Arguments]    ${radio_id}=1    ${min_temperature}=-5    ${max_temperature}=80
    ${rf_temperature_supervision_result}    selenium_coam.get_rf_temperature_supervision    radio_id=RMOD-${radio_id}
    ${temperature_value}    get from dictionary    ${rf_temperature_supervision_result}[0]    Temperature value
    should be true    ${min_temperature} < ${temperature_value} < ${max_temperature}

Check RF Ethernet Packet Monitoring
    [Arguments]    ${radio_id}=1    ${rf_port_id}=0
    ${rf_eth_packet_monitoring_result}    selenium_coam.get_rf_ethernet_packet_monitoring    radio_id=RMOD-${radio_id}
    FOR    ${item}    IN    @{rf_eth_packet_monitoring_result}
        ${port_id_in_list}    Set Variable    ${item['Port']}
        ${index}    Get Index From List    ${rf_eth_packet_monitoring_result}    ${item}
        ${status}    Evaluate    "${port_id_in_list}"=="${rf_port_id}"
        Exit For Loop If    "${status}"=="True"
    END
    ${Received_errored_frames_value}    get from dictionary    ${rf_eth_packet_monitoring_result}[${index}]    Received errored frames
    should be equal    ${Received_errored_frames_value}     0
    ${Received_frames_value}    get from dictionary    ${rf_eth_packet_monitoring_result}[${index}]    Received frames
    should be true    0 < ${Received_frames_value}
    ${Received_multicast_frames_value}    get from dictionary    ${rf_eth_packet_monitoring_result}[${index}]    Received multicast frames
    should be true    0 < ${Received_multicast_frames_value}
    ${Received_octets_value}    get from dictionary    ${rf_eth_packet_monitoring_result}[${index}]    Received octets
    should be true    0 < ${Received_octets_value}
    ${type_frames_value}    get from dictionary    ${rf_eth_packet_monitoring_result}[${index}]    Received unknown type frames
    should be equal    ${type_frames_value}     0
    ${vlan_frames_value}    get from dictionary    ${rf_eth_packet_monitoring_result}[${index}]    Received unknown VLAN frames
    should be equal    ${vlan_frames_value}     0
    ${Transmitted_frames_value}    get from dictionary    ${rf_eth_packet_monitoring_result}[${index}]    Transmitted frames
    should be true    0 < ${Transmitted_frames_value}
    ${Transmitted_multicast_frames_value}    get from dictionary    ${rf_eth_packet_monitoring_result}[${index}]    Transmitted multicast frames
    should be true    0 < ${Transmitted_multicast_frames_value}
    ${Transmitted_octets_value}    get from dictionary    ${rf_eth_packet_monitoring_result}[${index}]    Transmitted octets
    should be true    0 < ${Transmitted_octets_value}

Check Detailed Antenna
    [Arguments]    ${cell_id}=1    ${expected_low}=-1     ${expected_high}=120   ${error_low}=-8    ${error_high}=8
    ...    ${RSSI_low}=-180    ${RSSI_high}=-30    ${RTWP_low}=-180    ${RTWP_high}=-30    ${SINR_low}=-21    ${SINR_high}=41
    ...    ${total_low}=-1    ${total_high}=120    ${stream}=SBTS00
    ${boundary}    get the boundary of stream    stream=${stream}
    ${boundary_rtwp}  get the boundary of stream with 24R2   stream=${stream}
    ${detail_result}    selenium_coam.get_detailed_result_for_each_antenna    cell_id=${cell_id}
    ${rtwp_result}    selenium_coam.get_general_test_information    cell_id=${cell_id}
    ${radio_protocol}    get_radio_protocal_via_admin
    FOR    ${item}    IN    @{detail_result}
        ${value_VSWR}    get from dictionary    ${item}    VSWR
        should be equal    ${value_VSWR}     0
        ${value_RTWP}    Run Keyword If  '${radio_protocol}'=='CPRI' and '${boundary_rtwp}'=='old_version'
        ...   get from dictionary    ${item}    RTWP (dBm)
        Run Keyword If  '${radio_protocol}'=='CPRI' and '${boundary_rtwp}'=='old_version'
        ...   should be true    ${RTWP_low} < ${value_RTWP} < ${RTWP_high}
        ${value_RSSI}    get from dictionary    ${item}    RSSI (dBm)
        Run Keyword If  '${boundary}'=='new_version'
        ...     should be true    ${RSSI_low} < ${value_RSSI} <= ${RSSI_high}
        ${value_SINR}    get from dictionary    ${item}    SINR (dB)
        Run Keyword If  '${boundary}'=='new_version'
        ...     should be true    ${SINR_low} <= ${value_SINR} < ${SINR_high}
        ${dict_forward_total}   Run Keyword If  '${boundary}'=='old_version'
        ...     get from dictionary    ${item}   Forward total transmit RF power
        ${value_forward_total}   Run Keyword If  '${boundary}'=='old_version'
        ...     get from dictionary    ${dict_forward_total}     dBm
        Run Keyword If  '${boundary}'=='old_version'
        ...    should be true    ${total_low} < ${value_forward_total} < ${total_high}
        ${dict_forward_expected}   Run Keyword If  '${boundary}'=='old_version'
        ...     get from dictionary    ${item}   Forward expected transmit RF power
        ${value_forward_expected}   Run Keyword If  '${boundary}'=='old_version'
        ...     get from dictionary    ${dict_forward_expected}     dBm
        Run Keyword If  '${boundary}'=='old_version'
        ...    should be true    ${expected_low} < ${value_forward_expected} < ${expected_high}
        ${value_forward_error}   Run Keyword If  '${boundary}'=='old_version'
        ...     get from dictionary    ${item}    Forward transmit RF power error (dB)
        Run Keyword If  '${boundary}'=='old_version'
        ...    should be true    ${error_low} < ${value_forward_error} < ${error_high}
    END
    FOR    ${item}    IN    @{rtwp_result}
        ${value_RTWP}    Run Keyword If  '${radio_protocol}'=='CPRI' and '${boundary_rtwp}'=='new_version'
        ...   get from dictionary    ${item}    RTWP (dBm)
        Run Keyword If  '${radio_protocol}'=='CPRI' and '${boundary_rtwp}'=='new_version'
        ...   should be true    ${RTWP_low} < ${value_RTWP} < ${RTWP_high}
    END

Return RF Temoerature value
    [Arguments]    ${radio_id}=1
    ${rf_temperature_supervision_result}    selenium_coam.get_rf_temperature_supervision    radio_id=RMOD-${radio_id}
    ${temperature_value}    get from dictionary    ${rf_temperature_supervision_result}[0]    Temperature value
    [Return]    ${temperature_value}

Return Ethernet Packet Received Frame value
    [Arguments]    ${radio_id}=1
    ${ethernet_packet_result}    selenium_coam.get_rf_ethernet_packet_monitoring    radio_id=RMOD-${radio_id}
    ${received_frame_value}    get from dictionary    ${ethernet_packet_result}[0]    Received frames
    [Return]    ${received_frame_value}

Return RU Uptime value
    [Arguments]    ${radio_id}=1
    ${general_detail_result}    selenium_coam.get_statistics_general_test_information    radio_id=RMOD-${radio_id}
    ${uptime}    get from dictionary    ${general_detail_result}[0]    Uptime (sec)
    [Return]    ${uptime}

Verify Latest Statistics Outcome
    [Arguments]    ${radio_id}=1    ${outcome}=Pass
    ${general_detail_result}    selenium_coam.get_statistics_general_test_information    radio_id=RMOD-${radio_id}
    ${outcome_result}    get from dictionary    ${general_detail_result}[0]    Outcome
    should be equal    ${outcome_result}    ${outcome}

Check VSWR With L3 Call
    [Arguments]    ${cell_id}=1    ${VSWR_high}=3
    Log To Console    Check VSWR With L3 Call
    ${detail_result}    selenium_coam.get_detailed_result_for_each_antenna    cell_id=${cell_id}
    FOR    ${item}    IN    @{detail_result}
        ${value_VSWR}    get from dictionary    ${item}    VSWR
        should be true    0 < ${value_VSWR} < ${VSWR_high}
    END
