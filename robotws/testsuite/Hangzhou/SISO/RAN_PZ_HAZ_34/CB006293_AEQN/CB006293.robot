# *** Settings ***
# Suite Setup          SISO Coam Suite Setup
# Suite Teardown       SISO Coam Suite Teardown
# Test Setup           SISO Coam Test Setup
# Test Teardown        SISO Coam Test Teardown
# Test Timeout         12h
# 
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
# Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
# Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_log.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/recommissioning_and_make_throughput.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/rf_diagnostic_test.robot
# 
# Documentation
# ...    Author: Chen Liang; Li Xiaofei
# ...    contact: liang.6.chen@nokia-sbell.com; xiaofei.li@nokia-sbell.com
# ...    squad group:SG_07
# ...    Feature CB006293 in 22R3 program
# 
# Force Tags            5G_RAN    5G_RAN_TDD    RAN_5G_TDD    RAN_5G
# 
# *** Variables ***
# ${if_commissioning}   False
# ${if_teardown_commissioning}   False
# ${if_pdl_check}       False
# ${ue_index}   0
# #${rf_port_id}   1
# #${ute_env}   False
# #${testline_name}   7_5_UTE5G402T807
# ${ru_type_init}   AEQN
# 
# *** Test Cases ***
# [1]CB006293_AEQN_009_Initiate_RF_Statistics_diagnostic_test_withL3call
#     [Tags]    CRT_TRUNK
#     Run Keyword And Ignore Error   Check Extra Reset From Blackbox
#     log to console   ${if_commissioning} ${if_teardown_commissioning} ${if_pdl_check}
#     General_SiSo_Initiate_RF_Statistics_diagnostic_test_withL3call_AEQN
#     ...   radio_id=2   min_temperature=40   max_temperature=100   rf_port_id=0
#     Check Extra Reset From Blackbox
# 
# [1]CB006293_AEQN_003_Initiate_RF_diagnostic_test_RSSI_SINR_test_withL3call
#     [Tags]    CRT_TRUNK
#     Run Keyword And Ignore Error   Check Extra Reset From Blackbox
#     General_SiSo_Initiate_RF_diagnostic_test_from_BTS_Element_Manager_with_L3Call_AEQN
#     Check Extra Reset From Blackbox
# 
# #[1]CB006293_5G_Amber_04_Initiate_RF_diagnostic_test_SINR_per_cell_test_withL3call
# #    General_SiSo_Initiate_RF_diagnostic_test_from_BTS_Element_Manager_with_L3Call_AEQN
# 
# 
# *** Keywords ***
# General_SiSo_Initiate_RF_diagnostic_test_from_BTS_Element_Manager_with_L3Call_AEQN
#     [Documentation]
#     ...    *****************
#     ...    [TEST PURPOSE] The purpose of this case is to verify that RF diagnostic test can be run by WebEM and test
#     ...    result can be gotten successfully in BTS.
#     ...    ******************
#     ...    History of changes
#     ...    ******************
#     ...    - 08.05.2021 - - Created
#     ...    *******************
#     ...    Owner_liang.6.chen@nokia-sbell.com; Owner_xiaofei.li@nokia-sbell.com
#     [Arguments]  ${ue_index}=${0}
#     Selenium Login with version
#     ${port_type}  COAM get ru port type
#     Delete RFTHLD If Exist
#     Modify actRemoteRfDiag Parameter
#     Set default value for RFTHLD If Feature 956 Enabled
#     ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
#     ${ue_type}   Set Variable If   '${ue_type}'=='honor'   huawei   ${ue_type}
#     power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
#     ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}
#     power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=300M
#     ...    protocol=udp    duration=600    ue_index=${ue_index}
# #    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=100M
# #    ...    protocol=udp    duration=600    ue_index=${ue_index}
#     sleep   5min
#     ${freqBandIndicatorNR}    get_freqbandindicatornr_via_admin
#     ${freqBandIndicatorNR}    Convert to string    ${freqBandIndicatorNR}
#     ${bands_thresholds_temp}    create list    ${freqBandIndicatorNR}    100    3
#     ${bands_thresholds}    create list    ${bands_thresholds_temp}
#     ${stream}    get stream from version    ${Active_SW_version}
#     ${test_cell}=    Set Variable If
#     ...     '${stream}'=='11.800'        All cells
#     ...     All NR cells
#     RF Diagnostic Test Setup for CB006293    cell=${test_cell}
#     sleep  30
#     Check Detailed Antenna for CB006293
#     Run Keyword If  '${port_type}'!='PHYANT'    Check VSWR With L3 Call
#     Check General Test Information for CB006293   cell_id=1
#     run keyword and ignore error   power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    ue_index=${ue_index}
# #    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    ue_index=${ue_index}
#     run keyword and ignore error   power_ue.UE Detach  ue_type=${ue_type}    ue_index=${ue_index}
#     Perform BTS Site Reset
#     Sleep    30s
#     COAM Wait gnb And Cells ready    timeout=15min    gnb_type='${gNb_CuType}'
#     Selenium Login with version
#     Check Detailed Antenna for CB006293
#     Run Keyword If  '${port_type}'!='PHYANT'    Check VSWR With L3 Call
#     Check General Test Information for CB006293   cell_id=1
#     [Teardown]  selenium logout and close browser
# 
# General_SiSo_Initiate_RF_Statistics_diagnostic_test_withL3call_AEQN
#     [Documentation]
#     ...    *****************
#     ...    [TEST PURPOSE] The purpose of this case is to verify that RF statistics diagnostic test can be run by WebEM
#     ...    and test result can be gotten successfully in BTS.
#     ...    ******************
#     ...    History of changes
#     ...    ******************
#     ...    - 24.03.2022 - - Created
#     ...    *******************
#     ...    Owner_liang.6.chen@nokia-sbell.com; Owner_xiaofei.li@nokia-sbell.com
#     [Arguments]  ${ue_index}=${0}    ${radio_id}=${1}    ${RF_temperature_high_threshold}=${90}
#     ...          ${min_temperature}=40    ${max_temperature}=100    ${rf_port_id}=0
#     Selenium Login with version
#     Delete RFTHLD If Exist
#     Modify actRemoteRfDiag Parameter
#     Set default value for RFTHLD If Feature 956 Enabled
#     ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
#     ${ue_type}   Set Variable If   '${ue_type}'=='honor'   huawei   ${ue_type}
#     power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
#     ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}
#     power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=300M
#     ...    protocol=udp    duration=600    ue_index=${ue_index}
# #    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=100M
# #    ...    protocol=udp    duration=600    ue_index=${ue_index}
#     sleep   5min
#     ${bts_thresholds}    create dictionary    RF temperature high threshold=${RF_temperature_high_threshold}
#     RF statistics diagnostic test setup for CB006293    bts_thresholds=${bts_thresholds}    radio_id=${radio_id}
#     sleep  30
#     Check Statistics General Information    radio_id=${radio_id}
#     Check RF Temperature Supervision    radio_id=${radio_id}    min_temperature=${min_temperature}    max_temperature=${max_temperature}
#     Check RF Ethernet Packet Monitoring All Port    radio_id=${radio_id}
#     run keyword and ignore error   power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    ue_index=${ue_index}
# #    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    ue_index=${ue_index}
#     run keyword and ignore error   power_ue.UE Detach  ue_type=${ue_type}    ue_index=${ue_index}
#     [Teardown]  selenium logout and close browser
# 
# Check RF Ethernet Packet Monitoring All Port
#     [Arguments]    ${radio_id}=1
#     ${Received_errored_frames_value}    Set Variable    0
#     ${Received_frames_value}    Set Variable    0
#     ${Received_multicast_frames_value}    Set Variable    0
#     ${Received_octets_value}    Set Variable    0
#     ${type_frames_value}    Set Variable    0
#     ${vlan_frames_value}    Set Variable    0
#     ${Transmitted_frames_value}    Set Variable    0
#     ${Transmitted_multicast_frames_value}    Set Variable    0
#     ${Transmitted_octets_value}    Set Variable    0
#     ${rf_eth_packet_monitoring_result}    selenium_coam.get_rf_ethernet_packet_monitoring    radio_id=RMOD-${radio_id}
#     FOR    ${item}    IN    @{rf_eth_packet_monitoring_result}
#         ${index}    Get Index From List    ${rf_eth_packet_monitoring_result}    ${item}
#         ${Received_errored_frames_value}    Evaluate
#         ...    ${Received_errored_frames_value}+${rf_eth_packet_monitoring_result}[${index}][Received errored frames]
#         ${Received_frames_value}    Evaluate
#         ...    ${Received_frames_value}+${rf_eth_packet_monitoring_result}[${index}][Received frames]
#         ${Received_multicast_frames_value}    Evaluate
#         ...    ${Received_multicast_frames_value}+${rf_eth_packet_monitoring_result}[${index}][Received multicast frames]
#         ${Received_octets_value}    Evaluate
#         ...    ${Received_octets_value}+${rf_eth_packet_monitoring_result}[${index}][Received octets]
#         ${type_frames_value}    Evaluate
#         ...    ${type_frames_value}+${rf_eth_packet_monitoring_result}[${index}][Received unknown type frames]
#         ${vlan_frames_value}    Evaluate
#         ...    ${vlan_frames_value}+${rf_eth_packet_monitoring_result}[${index}][Received unknown VLAN frames]
#         ${Transmitted_frames_value}    Evaluate
#         ...    ${Transmitted_frames_value}+${rf_eth_packet_monitoring_result}[${index}][Transmitted frames]
#         ${Transmitted_multicast_frames_value}    Evaluate
#         ...    ${Transmitted_multicast_frames_value}+${rf_eth_packet_monitoring_result}[${index}][Transmitted multicast frames]
#         ${Transmitted_octets_value}    Evaluate
#         ...    ${Transmitted_octets_value}+${rf_eth_packet_monitoring_result}[${index}][Transmitted octets]
#     END
#     should be equal as integers    ${Received_errored_frames_value}     0
#     should be true    0 < ${Received_frames_value} < 18446744073709551615
#     should be true    0 < ${Received_multicast_frames_value} < 18446744073709551615
#     should be true    0 < ${Received_octets_value} < 18446744073709551615
#     should be equal as integers    ${type_frames_value}     0
#     should be equal as integers    ${vlan_frames_value}     0
#     should be true    0 < ${Transmitted_frames_value} < 18446744073709551615
#     should be true    0 < ${Transmitted_multicast_frames_value} < 18446744073709551615
#     should be true    0 < ${Transmitted_octets_value} < 18446744073709551615
# 
# RF statistics diagnostic test setup for CB006293
#     [Arguments]    ${radio_id}=${1}    ${bts_thresholds}=${None}
#     Log To Console    RF statistics diagnostic test setup
#     selenium_coam.configure_rf_diagnostic_test    bts_thresholds=${bts_thresholds}    cell=All NR cells
# #    run keyword if  ${bts_thresholds}!=${None}      selenium_coam.save_thresholds
#     selenium_coam.configure_statistics_diagnostic_test    radio=RMOD-${radio_id}
#     selenium_coam.start_statistics_diagnostic_test
# 
# RF Diagnostic Test Setup for CB006293
#     [Arguments]    ${cell}=All NR cells    ${bts_thresholds}=${None}     ${bands_thresholds}=${None}
#     Log To Console    RF Diagnostic Test Setup
#     selenium_coam.configure_rf_diagnostic_test    cell=${cell}    bts_thresholds=${bts_thresholds}
#     ...    bands_thresholds=${bands_thresholds}    technology=NR
# #    selenium_coam.save_thresholds
#     selenium_coam.start_rf_diagnostic_test    timeout=180
# 
# Check Detailed Antenna for CB006293
#     [Arguments]    ${cell_id}=1    ${expected_low}=-1     ${expected_high}=120   ${error_low}=-8    ${error_high}=8
#     ...    ${RSSI_low}=-180    ${RSSI_high}=-30    ${RTWP_low}=-180    ${RTWP_high}=-30    ${SINR_low}=-21    ${SINR_high}=41
#     ...    ${total_low}=-1    ${total_high}=120    ${stream}=SBTS00
#     ${detail_result}    selenium_coam.get_detailed_result_for_each_antenna    cell_id=${cell_id}
#     ${radio_protocol}    get_radio_protocal_via_admin
#     FOR    ${item}    IN    @{detail_result}
#         ${value_VSWR}    get from dictionary    ${item}    VSWR
#         should be equal    ${value_VSWR}     0
#         ${value_RTWP}    get from dictionary    ${item}    RTWP (dBm)
#         Run Keyword If  '${radio_protocol}'=='CPRI'    should be true    ${RTWP_low} < ${value_RTWP} < ${RTWP_high}
#         ${value_RSSI}    get from dictionary    ${item}    RSSI (dBm)
#         Run Keyword If  '${stream}'=='SBTS00' or '${stream}'=='SBTS22R3'
#         ...     should be true    ${RSSI_low} < ${value_RSSI} < ${RSSI_high}
#         ${value_SINR}    get from dictionary    ${item}    SINR (dB)
#         Run Keyword If  '${stream}'=='SBTS00' or '${stream}'=='SBTS22R3'
#         ...     should be true    ${SINR_low} < ${value_SINR} < ${SINR_high}
# #        ${dict_forward_total}    get from dictionary    ${item}   Forward total transmit RF power
# #        ${value_forward_total}    get from dictionary    ${dict_forward_total}     dBm
# #        should be true    ${total_low} < ${value_forward_total} < ${total_high}
# #        ${dict_forward_expected}   Run Keyword If  '${stream}'!='SBTS00' and '${stream}'!='SBTS22R3'
# #        ...     get from dictionary    ${item}   Forward expected transmit RF power
# #        ${value_forward_expected}   Run Keyword If  '${stream}'!='SBTS00' and '${stream}'!='SBTS22R3'
# #        ...     get from dictionary    ${dict_forward_expected}     dBm
# #        Run Keyword If  '${stream}'!='SBTS00' and '${stream}'!='SBTS22R3'
# #        ...    should be true    ${expected_low} < ${value_forward_expected} < ${expected_high}
# #        ${value_forward_error}    get from dictionary    ${item}    Forward transmit RF power error (dB)
# #        should be true    ${error_low} < ${value_forward_error} < ${error_high}
#     END
# 
# Check General Test Information for CB006293
#     [Arguments]    ${cell_id}=1    ${forward_expected_result}=Pass    ${reverse_expected_result}=Pass
#     ...    ${expected_outcome}=Pass    ${expected_low}=-1     ${expected_high}=120    ${stream}=SBTS00
#     ${general_result}    selenium_coam.get_general_test_information    cell_id=${cell_id}
#     FOR    ${item}    IN    @{general_result}
#         ${start_time}    get from dictionary    ${item}    BTS test start time GMT +0800
#         ${stop_time}    get from dictionary    ${item}    BTS test stop time GMT +0800
#         ${start_time_value}    split string    ${start_time}    ${SPACE}
#         ${stop_time_value}    split string    ${stop_time}    ${SPACE}
#         ${time_differ}    robot.libraries.DateTime.subtract_time_from_time    ${start_time_value}[-1]     ${stop_time_value}[-1]
#         ${time}    evaluate    abs(${time_differ})
#         should be true   ${time}>${0}
#         ${forward_result}    get from dictionary    ${item}    Forward test disposition
#         should be equal    ${forward_result}    ${forward_expected_result}
#         ${reverse_result}    get from dictionary    ${item}    Reverse test disposition
#         should be equal    ${reverse_result}    ${reverse_expected_result}
#         ${outcome}    get from dictionary    ${item}    Outcome
#         should be equal    ${outcome}    ${expected_outcome}
#         ${result}    get from dictionary    ${item}   Result
#         should be equal    ${result}    success
#         ${value_forward_expected}   Run Keyword If  '${stream}'=='SBTS00' or '${stream}'=='SBTS22R3'
#         ...     get from dictionary    ${item}   Forward expected transmit RF power
#         Run Keyword If  '${stream}'=='SBTS00' or '${stream}'=='SBTS22R3'
#         ...     should be true    ${expected_low} < ${value_forward_expected} < ${expected_high}
#     END
