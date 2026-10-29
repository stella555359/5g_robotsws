*** Settings ***
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/rf_diagnostic_test.robot

Documentation
...    author: Shufei Chen
...    contact: shufei.chen@nokia-sbell.com
...    Group: HGZ_SG8

*** Variables ***
@{cell_list}    ${1}

*** Keywords ***
CNI-88795 Check General Test Information
    [Arguments]    ${cell_id}=1    ${forward_expected_result}=Pass    ${reverse_expected_result}=Pass
    ...    ${expected_outcome}=Pass    ${expected_low}=-1     ${expected_high}=120    ${stream}=SBTS00
    ${boundary}    get the boundary of stream    stream=${stream}
    ${general_result}    selenium_coam.get_general_test_information    cell_id=${cell_id}
    FOR    ${item}    IN    @{general_result}
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

General_SiSo_Initiate_RF_diagnostic_test_from_BTS_Element_Manager_with_L3Call_AZQF
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this case is to verify that RF diagnostic test can be run by WebEM and test
    ...    result can be gotten successfully in BTS.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 08.05.2021 - - Created
    ...    *******************
    ...    Owner_zhihao.shi@nokia-sbell.com
    [Arguments]  ${tput_info}    ${ue_index}=${0}    ${ui_version}=default    ${pci}=${0}    ${protocol}=udp    ${connection}=GNB_OAM
    ...    ${tput_from}=tool    ${target_avg_percent}=0.5    ${min_percent}=0.2    ${duration}=300
    ${tput_info_total}    create dictionary
    FOR  ${cell_index}  IN  @{cell_list}
        ${tput_cell}    run keyword if    '${tput_from}'=='tool'    get_tput_info_by_tool
        ...    cell_id=${cell_index}    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
        ...    duration=${duration}    connection=${connection}    ELSE    set variable    ${tput_info[${cell_index}]}
        log to console    tput info for cell ${cell_index} is: ${tput_cell}
        set to dictionary    ${tput_info_total}    ${cell_index}    ${tput_cell}
    END
    Set PA Value For Pointed Port    PA_Port_List=${PA_OUT_PORTS_88795}    value=${15}
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    Selenium Login And Disable Screen Lock    version=${stream}
    ${port_type}  COAM get ru port type
    Delete RFTHLD If Exist
#    Modify actRemoteRfDiag Parameter
    Set default value for RFTHLD If Feature 956 Enabled
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    run keyword and ignore error    Wait Until Keyword Succeeds    8x     20s    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
    ...    ui_version=${ui_version}
    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}    attach_mode=5G_${gNb_CuType}    pci=${pci}
    ${iperf_type}  set variable if  '${ue_type}'=='huawei'    via_app    via_command
    ${cell_id}    set variable    ${1}
    ${dl_tp}    set variable    ${tput_cell['dl_tp']}
    #${ul_tp}    set variable    ${tput_956[${cell_id}]['ul_tp']}
    ${dl_exp}    set variable    ${tput_cell['dl_exp']}
    #${ul_exp}    set variable    ${tput_956[${cell_id}]['ul_exp']}
    ${process_num_dl}    set variable if      '${protocol}'=='udp'    ${1}    ${16}
    log to console    start dl traffic...
    Wait Until Keyword Succeeds    5x     20s    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${dl_tp}
    ...    protocol=udp    duration=1200    ue_index=${ue_index}    process_num=${process_num_dl}    ue_mode=${gNb_CuType}
    sleep   2min
    ${freqBandIndicatorNR}    get_freqbandindicatornr_via_admin
    ${freqBandIndicatorNR}    Convert to string    ${freqBandIndicatorNR}
    ${bands_thresholds_temp}    create list    ${freqBandIndicatorNR}    100    3
    ${bands_thresholds}    create list    ${bands_thresholds_temp}
    ${stream}    get stream from version    ${Active_SW_version}
    ${test_cell}=    Set Variable If
    ...     '${stream}'=='11.800'        All cells
    ...     All NR cells
	${bands_thresholds_input}=    Set Variable If
    ...     '${stream}'=='SBTS22R2'       ${bands_thresholds}
    ...     ${None}
    RF Diagnostic Test Setup AZQF    cell=${test_cell}    bands_thresholds=${bands_thresholds_input}
    sleep  30
    Check Detailed Antenna AZQF    stream=${stream}
    Run Keyword If  '${port_type}'!='PHYANT'    Check VSWR With L3 Call
    CNI-88795 Check General Test Information    stream=${stream}
    ${cell_mapping}    get_relation_mapping_between_cell_index_and_nrCellIdentity    connection_alias=${connection}
    ${cell_id_1}    Convert To String    ${cell_mapping[${cell_id}]['nrCellIdentity']}
    ${cell_id_list}    Create List    ${cell_id_1}
    ${tput_log}    power_ue.Collect Tput    ue_type=nokia_fastmile    duration=120    check_source=Aasyslog
    #${output}    power_ue.Check Bi Tput   ue_type=nokia_fastmile    log=${tput_log}    cells=${cell_id_list}   ultarget_throughput=${ul_exp}
    #...    dltarget_throughput=${dl_exp}
    power_ue.Check Tput    ue_type=${ue_type}    direction=dl    log=${tput_log}    cells=${cell_id_list}    target_throughput=${dl_exp}
    ...    target_avg_percent=${0.85}    min_percent=${0.8}
    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    ue_index=${ue_index}
    #power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    ue_index=${ue_index}
    power_ue.UE Detach  ue_type=${ue_type}    ue_index=${ue_index}
    [Teardown]    Run keywords    selenium logout and close browser    AND    Set PA Value For Pointed Port
    ...    PA_Port_List=${PA_OUT_PORTS_88795}    value=${0}

Check Detailed Antenna AZQF
    [Arguments]    ${cell_id}=1    ${expected_low}=-1     ${expected_high}=120   ${error_low}=-8    ${error_high}=8
    ...    ${RSSI_low}=-180    ${RSSI_high}=-30    ${RTWP_low}=-180    ${RTWP_high}=-30    ${SINR_low}=-21    ${SINR_high}=41
    ...    ${total_low}=-1    ${total_high}=120    ${stream}=SBTS00
    ${boundary}    get the boundary of stream    stream=${stream}
    ${detail_result}    selenium_coam.get_detailed_result_for_each_antenna    cell_id=${cell_id}
    ${radio_protocol}    get_radio_protocal_via_admin
    FOR    ${item}    IN    @{detail_result}
#        ${value_VSWR}    get from dictionary    ${item}    VSWR
#        should be equal    ${value_VSWR}     0
        ${value_RTWP}    get from dictionary    ${item}    RTWP (dBm)
        Run Keyword If  '${radio_protocol}'=='CPRI'    should be true    ${RTWP_low} < ${value_RTWP} < ${RTWP_high}
        ${value_RSSI}    get from dictionary    ${item}    RSSI (dBm)
        Run Keyword If  '${boundary}'=='new_version'
        ...     should be true    ${RSSI_low} < ${value_RSSI} < ${RSSI_high}
        ${value_SINR}    get from dictionary    ${item}    SINR (dB)
        Run Keyword If  '${boundary}'=='new_version'
        ...     should be true    ${SINR_low} < ${value_SINR} < ${SINR_high}
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

General_SiSo_Initiate_RF_diagnostic_test_from_BTS_Element_Manager_without_L3Call_AZQF
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this case is to verify that RF diagnostic test can be run by WebEM and test
    ...    result can be gotten successfully in BTS.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 26.04.2021 - - Created
    ...    *******************
    ...    Owner_zhihao.shi@nokia-sbell.com
    [Arguments]  ${low_RSSI}=${-140}    ${low_RTWP}=${-140}    &{kwargs}
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    Selenium Login And Disable Screen Lock    version=${stream}
    Delete RFTHLD If Exist
#    Modify actRemoteRfDiag Parameter
    Set default value for RFTHLD If Feature 956 Enabled
    ${freqBandIndicatorNR}    get_freqbandindicatornr_via_admin
    ${freqBandIndicatorNR}    Convert to string    ${freqBandIndicatorNR}
    ${bands_thresholds_temp}    create list    ${freqBandIndicatorNR}    100    3
    ${bands_thresholds}    create list    ${bands_thresholds_temp}
    ${bts_thresholds}    create dictionary    Low RSSI threshold=${low_RSSI}    RTWP low threshold=${low_RTWP}
    ${stream}    get stream from version    ${Active_SW_version}
    ${test_cell}=    Set Variable If
    ...     '${stream}'=='11.800'        All cells
    ...     All NR cells
    RF Diagnostic Test Setup AZQF    cell=${test_cell}
    sleep  30
    Check Detailed Antenna    RSSI_low=-160    stream=${stream}
    Check General Test Information    stream=${stream}
    [Teardown]  selenium logout and close browser

RF Diagnostic Test Setup AZQF
    [Arguments]    ${cell}=All NR cells    ${bts_thresholds}=${None}     ${bands_thresholds}=${None}
    Log To Console    RF Diagnostic Test Setup AZQF
    ${modify_params}  create list
    ${dist_name}   Set Variable  MRBTS-${mrbtsID}/MNL-1/MNLENT-1/TEST-1/RFTHLD-1
    ${item}  create dictionary  dist_name=${dist_name}
    ...    filter_param=Low RSSI threshold  p_name=rxAntennaRSSILowThreshold  value=${-115}
    append to list  ${modify_params}  ${item}
    Modify Parameters On Webem  modify_params=${modify_params}  is_activate=${True}
    run keyword if  ${bands_thresholds}!=${None} or ${bts_thresholds}!=${None}      selenium_coam.save_thresholds
    selenium_coam.configure_rf_diagnostic_test    cell=${cell}    bts_thresholds=${bts_thresholds}
    ...    bands_thresholds=${bands_thresholds}    technology=NR
    selenium_coam.start_rf_diagnostic_test
