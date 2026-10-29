# *** Settings ***
# Documentation     author: xingjing && yuegong
# ...                 contact: jing.1.xing@nokia-sbell.com && yue.1.gong@nokia-sbell.com
# ...                 squad group: SG_03
# ...                 feature : 5GC000710 5GC000710_E_Mobility_Profiles_for_Inter-frequency_handover
# 
# 
# Force Tags    CA_5G_RRM
# ...    PY36
# Resource    ../Resources/5GC000710_common_keyword.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Atten.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# 
# 
# Suite Setup    Run Keywords    robot_common_operations.Common Suite Setup    AND
# ...            5GC000710_common_keyword.Common Suite Setup for COAM    AND
# ...            Set suite variables    AND
# ...            Precondition for cell on air    gnb_index=${0}    tl_scf_file_name=${tl_scf_file_name_gnb1}    AND
# ...            Precondition for cell on air    gnb_index=${1}    tl_scf_file_name=${tl_scf_file_name_gnb2}    AND
# ...            Precondition for power UE    ue_type=${ue_type}    ue_index=${0}
# 
# Suite Teardown    Run Keywords    robot_common_operations.Common Suite Teardown    AND
# ...               Run Keyword And Ignore Error
# ...               Common Suite Teardown for COAM    gnb_index=${0}
# 
# *** Variables ***
# 
# ${gNB1_logname_E01}    gNB1_710E01.pcap
# ${gNB1_logname_E03}    gNB1_710E03.pcap
# ${gNB1_logname_E04}    gNB1_710E04.pcap
# ${gNB1_logname_E05}    gNB1_710E05.pcap
# ${gNB1_logname_E06}    gNB1_710E06.pcap
# ${gNB1_logname_E09}    gNB1_710E09.pcap
# #${gNB1_logname_E09_2}    gNB1_710E09_2.pcap
# 
# 
# ${gNB2_logname_E04}    gNB2_710E04.pcap
# ${gNB2_logname_E05}    gNB2_710E05.pcap
# 
# ${dlexpect_tput}            15
# ${ulexpect_tput}            8
# ${enb_path}    /tmp
# ${profile_counter_path}    BTS/CELLS/NRCELL-1/NRMOP
# ${profile_counter_path_2}    BTS/CELLS/NRCELL-2/NRMOP
# ${profile_counter_path_3}    BTS/CELLS/NRCELL-3/NRMOP
# ${counter_end}     19
# ${749A08_01_status}    False
# #${epc_log_path}       /tmp/
# 
# @{update_ports}    ${att_port_9}    ${att_port_10}
# @{update_ports_values}    ${2}    ${2}
# 
# @{step_att_ports}    ${att_port_1}    ${att_port_2}
# ${origin_value}    ${10}
# ${target_value_005}    ${33}
# 
# *** Test Cases ***
# #[1]CB008146_E_001_Successful_configuration_of_A2_measurement_and_removal_of_A1_A3orA5_measurement
# #    [Documentation]
# #    ...    To verify the successful removal of Inter-frequency A3 and/or A5 and configuration of A2 measurement from
# #    ...    mobility profile selected after receipt of A1 Measurement report
# #    [Tags]    5GC000710
# #    [Timeout]    1 hour
# #    [Setup]
# #    prepare UE AND PA    value1=${3}    value2=${127}    value3=${127}    value4=${127}    value5=${127}
# #    UE attach and DL UL traffic on gnb1    gnb_index=${0}    logname=${gNB1_logname_E01}
# #    Precondition for attn    value1=${26}    value2=${127}    value3=${127}    value4=${127}    value5=${127}
# #    sleep    5s
# #    Precondition for attn    value1=${0}    value2=${127}    value3=${127}    value4=${127}    value5=${127}
# #    sleep    5s
# #    Check the cell DLUL throughput    cellid=${1}    gnb_index=${0}
# #    stop gnb1 wireshark log     logname1=${gNB1_logname_E01}
# #    Check A1A2 OK on gNB    log_name=${gNB1_logname_E01}
# #    Wait until keyword succeeds    1min    30s    Check PM counter Result
# #    ...    counter_id=M55157C00035    dic_path=${profile_counter_path}    gnb_index=${0}    counter_end=${20}
# #    [Teardown]    run keyword and ignore error    Test recover
# 
# 
# 
# #[1]CB008146_E_006_Successful_configuration_of_A2_measurement_based_on_NRCELL_configuration
# #    [Documentation]
# #    ...    To verify the successful configuration of A2 measurement based on nrcell configuration
# #    [Tags]    5GC000710
# #    [Timeout]    1 hour
# #    [Setup]
# #    Online delete parmeters    parameters_to_update=${PARAMS_TO_MODIFY_710_E06_1}    gnb_index=${0}
# #    prepare UE AND PA    value1=${0}    value2=${127}    value3=${127}    value4=${127}    value5=${127}
# #    UE attach and DL UL traffic on gnb1    gnb_index=${0}    logname=${gNB1_logname_E06}
# #    Precondition for attn    value1=${26}    value2=${127}    value3=${127}    value4=${127}    value5=${127}
# #    sleep    5s
# #    Check the cell DLUL throughput    cellid=${1}    gnb_index=${0}
# #    stop gnb1 wireshark log     logname1=${gNB1_logname_E06}
# #    Check NRCELLA2 OK on gNB    log_name=${gNB1_logname_E06}
# #    Wait until keyword succeeds    1min    30s    Check PM counter Result
# #    ...    counter_id=M55157C00035    dic_path=${profile_counter_path}    gnb_index=${0}    counter_end=${20}
# #    [Teardown]    run keywords
# #    ...           run keyword and ignore error    Test recover    AND
# #    ...           run keyword and ignore error    Online modify parmeters    parameters_to_update=${PARAMS_TO_MODIFY_710_E06_2}    gnb_index=${0}
# 
# #[1]CB008146_E_003_Successful_Inter-Freq_Intra-gNB_PSCell_change_with_mobility_profile_update
# #    [Documentation]
# #    ...    To verify the successful Inter-frequency Intra-DU Intra-gNB handover, with measurement configuration updated
# #    ...    between A2 configuration in the UE and RRC measurement report for event A2
# #    [Tags]    5GC000710
# #    [Timeout]    1 hour
# #    [Setup]
# #    prepare UE AND PA    value1=${3}    value2=${127}    value3=${127}    value4=${127}    value5=${127}
# #    UE attach and DL UL traffic on gnb1    gnb_index=${0}    logname=${gNB1_logname_E03}
# #    Online modify parmeters    parameters_to_update=${PARAMS_TO_MODIFY_710_E03_1}    gnb_index=${0}
# #    Precondition for attn    value1=${26}    value2=${127}    value3=${127}    value4=${127}    value5=${127}
# #    sleep    3s
# #    Precondition for attn    value1=${26}    value2=${2}    value3=${127}    value4=${127}    value5=${127}
# #    sleep    3s
# #    Precondition for attn    value1=${127}    value2=${2}    value3=${127}    value4=${127}    value5=${127}
# #    sleep    1s
# #    Check the cell DLUL throughput    cellid=${2}    gnb_index=${0}
# #    stop gnb1 wireshark log     logname1=${gNB1_logname_E03}
# #    Check intraG interF HO OK on gNB 03    log_name=${gNB1_logname_E03}
# #    Wait until keyword succeeds    1min    30s    Check PM counter Result
# #    ...    counter_id=M55157C00035    dic_path=${profile_counter_path}    gnb_index=${0}    counter_end=${20}
# #    Wait until keyword succeeds    1min    30s    Check PM counter Result
# #    ...    counter_id=M55157C00035    dic_path=${profile_counter_path_2}    gnb_index=${0}    counter_end=${20}
# #    [Teardown]    run keywords
# #    ...           run keyword and ignore error    Test recover    AND
# #    ...           run keyword and ignore error    Online modify parmeters    parameters_to_update=${PARAMS_TO_MODIFY_710_E03_2}    gnb_index=${0}
# 
# 
# #[1]CB008146_E_009_Successful_Inter-Freq_Intra-gNB_PSCell_change_with_mobility_profile_configuration_update
# #    [Documentation]
# #    ...    To verify the successful Inter-frequency Intra-DU Intra-gNB handover, with measurement configuration updated
# #    ...    between A2 configuration in the UE and RRC measurement report for event A3/A5
# #    [Tags]    5GC000710
# #    [Timeout]    1 hour
# #    [Setup]
# #    prepare UE AND PA    value1=${3}    value2=${127}    value3=${127}    value4=${127}    value5=${127}
# #    UE attach and DL UL traffic on gnb1    gnb_index=${0}    logname=${gNB1_logname_E09}
# #    Precondition for attn    value1=${26}    value2=${127}    value3=${127}    value4=${127}    value5=${127}
# #    sleep    2s
# #    Online modify parmeters    parameters_to_update=${PARAMS_TO_MODIFY_710_E09_1}    gnb_index=${0}
# #    Precondition for attn    value1=${26}    value2=${127}    value3=${5}    value4=${127}    value5=${127}
# #    sleep    2s
# #    Precondition for attn    value1=${127}    value2=${127}    value3=${5}    value4=${127}    value5=${127}
# #    sleep    1
# #    Online modify parmeters    parameters_to_update=${PARAMS_TO_MODIFY_710_E09_2}    gnb_index=${0}
# #    Precondition for attn    value1=${127}    value2=${127}    value3=${25}    value4=${127}    value5=${127}
# #    sleep    5s
# #    Check the cell DLUL throughput    cellid=${3}    gnb_index=${0}
# #    stop gnb1 wireshark log     logname1=${gNB1_logname_E09}
# #    Check intraG interF HO OK on gNB E09   log_name=${gNB1_logname_E09}
# #    Wait until keyword succeeds    1min    30s    Check PM counter Result
# #    ...    counter_id=M55157C00035    dic_path=${profile_counter_path}    gnb_index=${0}    counter_end=${20}
# #    Wait until keyword succeeds    1min    30s    Check PM counter Result
# #    ...    counter_id=M55157C00034    dic_path=${profile_counter_path_3}    gnb_index=${0}    counter_end=${20}
# #    [Teardown]    run keywords
# #    ...           run keyword and ignore error    Test recover    AND
# #    ...           run keyword and ignore error    Online modify parmeters    parameters_to_update=${PARAMS_TO_MODIFY_710_E09_3}    gnb_index=${0}
# 
# [1]CB008146_E_005_Successful_Inter-Freq_Inter-gNB_PSCell_change_with_5QI1
#     [Documentation]
#     ...    To verify the successful Inter-frequency Inter-gNB handover with 5QI and 5QI5.
# 
#     [Tags]    5GC000710    CIT_TRUNK    CDRT_22R1    CRT_22R1    CRT_22R2    CIT_22R4    CRT_22R3    CIT_23R1
#     [Timeout]    1 hour
#     [Setup]
#     robot_common_operations.Common Case Setup
#     prepare UE AND PA    value1=${3}    value2=${127}    value3=${127}    value4=${127}    value5=${127}
#     Online modify parmeters    parameters_to_update=${PARAMS_TO_MODIFY_710_E03_1}    gnb_index=${0}
#     UE attach and DL traffic on gnb1    gnb_index=${0}    logname=${gNB1_logname_E05}
#     Make a voice call on UE
#     Power UE Start UL traffic    ul_throughput=10M
#     Check the cell DLUL throughput    cellid=${1}    gnb_index=${0}
#     Start Capture Wireshark Logs on target gnb    gnb_index=${1}    logname=${gNB2_logname_E05}
#     Set the attenuation value    att_ports=${update_ports}    values=${update_ports_values}
#     Adjust attenuation value via steps    att_ports=${step_att_ports}    origin_value=${origin_value}
#     ...    target_value=${target_value_005}    step=${3}
#     Check the cell DLUL throughput    cellid=${1}    gnb_index=${1}
#     End a call on UE
#     sleep    2s
#     stop gnb1 wireshark log     logname1=${gNB1_logname_E05}
#     stop gnb2 wireshark log     logname1=${gNB2_logname_E05}
#     Check intrerG interF HO OK on gNB1 E05   log_name=${gNB1_logname_E05}
#     Check intrerG interF HO OK on gNB2 E05   log_name=${gNB2_logname_E05}
#     Check VONR DRX gNB1 E05   log_name=${gNB1_logname_E05}
#     Check VONR DRX gNB2 E05   log_name=${gNB2_logname_E05}
#     Wait until keyword succeeds    1min    30s    Check PM counter Result
#     ...    counter_id=M55157C00035    dic_path=${profile_counter_path}    gnb_index=${0}    counter_end=${20}
#     Wait until keyword succeeds    5min    30s    Check PM counter Result
#     ...    counter_id=M55157C00033    dic_path=${profile_counter_path}    gnb_index=${1}    counter_end=${20}
#     [Teardown]    run keywords
#     ...           robot_common_operations.Common Case Teardown    AND
#     ...           run keyword and ignore error    Test recover    AND
#     ...           run keyword and ignore error    Online modify parmeters    parameters_to_update=${PARAMS_TO_MODIFY_710_E03_2}    gnb_index=${0}
# 
# #[1]CB008146_E_004_Successful_Inter-Freq_Inter-gNB_PSCell_change_based_on_A3_measurement_report
# #    [Documentation]
# #    ...    To verify the successful Inter-frequency Inter-gNB handover based on A3 measurements.
# #    [Tags]    5GC000710
# #    [Timeout]    1 hour
# #    [Setup]
# #    prepare UE AND PA    value1=${3}    value2=${127}    value3=${127}    value4=${127}    value5=${127}
# #    UE attach and DL UL traffic on gnb1    gnb_index=${0}    logname=${gNB1_logname_E04}
# #    Online delete objects    parameters_to_update=${PARAMS_TO_MODIFY_710_E04_1}    gnb_index=${0}
# #    Online modify parmeters    parameters_to_update=${PARAMS_TO_MODIFY_710_E04_2}    gnb_index=${1}
# #    Start Capture Wireshark Logs on target gnb    gnb_index=${1}    logname=${gNB2_logname_E04}
# #    Precondition for attn    value1=${30}    value2=${127}    value3=${127}    value4=${127}    value5=${127}
# #    sleep    3s
# #    Precondition for attn    value1=${30}    value2=${127}    value3=${127}    value4=${2}    value5=${127}
# #    sleep    1s
# #    Check the cell DLUL throughput    cellid=${1}    gnb_index=${1}
# #    Precondition for attn    value1=${127}    value2=${127}    value3=${127}    value4=${26}    value5=${127}
# #    sleep    1s
# #    stop gnb1 wireshark log     logname1=${gNB1_logname_E04}
# #    stop gnb2 wireshark log     logname1=${gNB2_logname_E04}
# #    Check intrerG interF HO OK on gNB1 E04   log_name=${gNB1_logname_E04}
# #    Check intrerG interF HO OK on gNB2 E04   log_name=${gNB2_logname_E04}
# #    Wait until keyword succeeds    1min    30s    Check PM counter Result
# #    ...    counter_id=M55157C00035    dic_path=${profile_counter_path}    gnb_index=${0}    counter_end=${20}
# #    Wait until keyword succeeds    5min    30s    Check PM counter Result
# #    ...    counter_id=M55157C00033    dic_path=${profile_counter_path}    gnb_index=${1}    counter_end=${20}
# #    [Teardown]    run keywords
# #    ...           run keyword and ignore error    Test recover    AND
# #    ...           run keyword and ignore error    Online modify parmeters    parameters_to_update=${PARAMS_TO_MODIFY_710_E04_3}    gnb_index=${0}
# #    ...    AND    run keyword and ignore error    Online modify parmeters    parameters_to_update=${PARAMS_TO_MODIFY_710_E04_4}    gnb_index=${1}
# 
# *** Keywords ***
# 
# Set suite variables
#     ${release_info} =    5GC000710_common_keyword.Get gnb release
#     set suite variable    ${release_info}
#     set suite variable    ${source_value}    ${para_store['${release_info}']['source_value']}
#     set suite variable    ${target_value}    ${para_store['${release_info}']['target_value']}
#     set suite variable    ${source_ho_value_start}    ${para_store['${release_info}']['source_ho_value_start']}
#     set suite variable    ${source_ho_value_end}    ${para_store['${release_info}']['source_ho_value_end']}
#     set suite variable    ${red_target_value}    ${para_store['${release_info}']['red_target_value']}
#     set suite variable    ${red_source_value}    ${para_store['${release_info}']['red_source_value']}
#     set suite variable    ${red_gnb1_value_start}    ${para_store['${release_info}']['red_gnb1_value_start']}
#     set suite variable    ${red_gnb1_value_end}    ${para_store['${release_info}']['red_gnb1_value_end']}
#     set suite variable    ${red_lte_value}    ${para_store['${release_info}']['red_lte_value']}
#     set suite variable    ${RFSP_value}    ${para_store['${release_info}']['RFSP']}
#     set suite variable    ${counter_end}    ${para_store['${release_info}']['counter_end']}
#     set suite variable    ${counter_end}    ${para_store['${release_info}']['counter_end']}
#     set suite variable    ${tl_scf_file_name_gnb1}    ${para_store['${release_info}']['tl_scf_file_name_gnb1_710E']}
#     set suite variable    ${tl_scf_file_name_gnb2}    ${para_store['${release_info}']['tl_scf_file_name_gnb2_710E']}
#     set suite variable    ${PARAMS_CASEC21_1}    ${para_store['${release_info}']['PARAMS_CASEC21_1']}
#     set suite variable    ${PARAMS_CASEC21_2}    ${para_store['${release_info}']['PARAMS_CASEC21_2']}
#     set suite variable    ${PARAMS_CASEC21_3}    ${para_store['${release_info}']['PARAMS_CASEC21_3']}
#     set suite variable    ${PARAMS_CASEC21_4}    ${para_store['${release_info}']['PARAMS_CASEC21_4']}
#     set suite variable    ${cell_2}    ${para_store['${release_info}']['cell_2']}
#     set suite variable    ${cell_3}    ${para_store['${release_info}']['cell_3']}
#     set suite variable    ${cell_4}    ${para_store['${release_info}']['cell_4']}
# 
# 
# Test recover
#     power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}
#     run keyword and ignore error    Stop ul dl data transfer
# 
# prepare UE AND PA
#     [Arguments]    ${value1}    ${value2}    ${value3}    ${value4}    ${value5}
#    Precondition for attn    value1=${value1}    value2=${value2}    value3=${value3}    value4=${value4}    value5=${value5}
# 
# UE attach and DL UL traffic on gnb1
#     [Arguments]    ${gnb_index}    ${logname}
#     Start Capture Wireshark Logs on gNB   nglogname=${logname}    gnb_index=${gnb_index}
#     Precondition for power UE    ue_type=${ue_type}
#     Attach and check power UE    ue_type=${ue_type}
#     Power UE Start DL traffic    dl_throughput=20M
#     Power UE Start UL traffic    ul_throughput=10M
#     Check the cell DLUL throughput    cellid=${1}    gnb_index=${0}
# 
# UE attach on gnb1
#     [Arguments]    ${gnb_index}    ${logname}
#     Start Capture Wireshark Logs on gNB   nglogname=${logname}    gnb_index=${gnb_index}
#     Precondition for power UE    ue_type=${ue_type}
#     Attach and check power UE    ue_type=${ue_type}
# 
# 
# 
# UE attach and DL traffic on gnb1
#     [Arguments]    ${gnb_index}    ${logname}
#     Start Capture Wireshark Logs on gNB   nglogname=${logname}    gnb_index=${gnb_index}
#     Precondition for power UE    ue_type=${ue_type}
#     Attach and check power UE    ue_type=${ue_type}
#     Power UE Start DL traffic    dl_throughput=20M
# #    Power UE Start UL traffic    ul_throughput=10M
# #    Check the cell DLUL throughput    cellid=${1}    gnb_index=${0}
# 
# Start Capture Wireshark Logs on target gnb
#     [Arguments]    ${gnb_index}    ${logname}
#     Start Capture Wireshark Logs on gNB   nglogname=${logname}    gnb_index=${gnb_index}
# 
# 
# Adjust RU Attenuation for MR
#     [Arguments]    ${value1}    ${value2}    ${value3}
#     Run Keyword if    '${release_info}' == 'SBTS22R2_ENB_0000'    Adjust RU Attenuation for MR 22R2
#     ...    start_value=${value1}    end_value=${value2}    value3=${value3}
#     ...    ELSE IF     '${release_info}' == 'SBTS22R1_ENB_0000'    Adjust RU Attenuation for MR 22R1
#     ...    start_value=${value1}    end_value=${value2}    value3=${value3}
#     ...    ELSE    Adjust RU Attenuation for MR Trunk    start_value=${value1}    end_value=${value2}    value3=${value3}
# 
# Adjust RU Attenuation for MR 22R2
#     [Arguments]    ${start_value}    ${end_value}    ${value3}
#     adjust the HBTE attenuation value    value=${value3}    att_port_1=${att_port_9}    att_port_2=${att_port_10}    atten_ip=${atten_ip}
#     adjust the HBTE attenuation value by step    start_value=${start_value}    end_value=${end_value}
#     ...    att_port_1=${att_port_1}    att_port_2=${att_port_2}    atten_ip=${atten_ip}
# 
# Adjust RU Attenuation for MR Trunk
#     [Arguments]    ${start_value}    ${end_value}    ${value3}
#     adjust the HBTE attenuation value    value=${value3}    att_port_1=${att_port_9}    att_port_2=${att_port_10}    atten_ip=${atten_ip}
#     adjust the HBTE attenuation value by step    start_value=${start_value}    end_value=${end_value}
#     ...    att_port_1=${att_port_1}    att_port_2=${att_port_2}    atten_ip=${atten_ip}
# 
# Adjust RU Attenuation for MR 22R1
#     [Arguments]    ${start_value}    ${end_value}    ${value3}
#     adjust the HBTE attenuation value    value=${value3}    att_port_1=${att_port_9}    att_port_2=${att_port_10}    atten_ip=${atten_ip}
#     adjust the HBTE attenuation value by step    start_value=${start_value}    end_value=${end_value}
#     ...    att_port_1=${att_port_1}    att_port_2=${att_port_2}    atten_ip=${atten_ip}
# 
# Make +6688 call for redirection
#     [Arguments]   ${value1}    ${value2}    ${value3}    ${enblogname1}
#     Precondition for attn    value1=${value1}    value2=${value2}    value3=${value3}
#     Start to collect the X2 log on eNB    port=any    x2_log_name=${enblogname1}
#     Make a voice call on UE
# 
# Make 911 call for redirection
#     [Arguments]   ${value1}    ${value2}    ${value3}     ${enblogname1}
#     Precondition for attn    value1=${value1}    value2=${value2}    value3=${value3}
#     Start to collect the X2 log on eNB    port=any    x2_log_name=${enblogname1}
#     Make an emergency call on UE
# 
# 
# stop gnb1 wireshark log
#     [Arguments]    ${logname1}
#     Run Keyword if    '${release_info}' != 'SBTS21B_ENB_0000'
#     ...    Stop Capture Wireshark Logs on gNB    nglogname=${logname1}    gnb_index=${0}
#     ...    ELSE    Stop and download Wireshark Logs on gNB Slave    gnb_index=${0}    logname=${logname1}
# 
# stop gnb2 wireshark log
#     [Arguments]    ${logname1}
#     Run Keyword if    '${release_info}' != 'SBTS21B_ENB_0000'
#     ...    Stop Capture Wireshark Logs on gNB    nglogname=${logname1}    gnb_index=${1}
#     ...    ELSE    Stop and download Wireshark Logs on gNB Slave    gnb_index=${1}    logname=${logname1}
# 
# Check A1A2 OK on gNB
#     [Arguments]    ${log_name}
#     ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${log_name}    tshark_path=${tshark_path}
#     ...                command_template=${command_template_X}
#     ${A21_expression}=     Catenate    f1ap.procedureCode == 5 and nr-rrc.eventId == 1
#     ${A21_packets}=    parser.filter_packets_by_expression    filter_expression=${A21_expression}
#     ${A21_1}=    parser.get_field_value_by_xpath    pdml_list=${A21_packets}    xpath=.//nr-rrc.eventId
#     should be equal    ${A21_1[0]}    1
#     ${A21_2}=    parser.get_field_value_by_xpath    pdml_list=${A21_packets}    xpath=.//nr-rrc.eventId
#     should be equal    ${A21_2[1]}    1
#     ${A13_expression}=     Catenate    f1ap.procedureCode == 12 and nr-rrc.eventId == 0 and nr-rrc.eventId == 2
#     ${A13_packets}=    parser.filter_packets_by_expression    filter_expression=${A13_expression}
#     ${A1_1}=    parser.get_field_value_by_xpath    pdml_list=${A13_packets}    xpath=.//nr-rrc.eventId
#     should be equal    ${A1_1[0]}    0
#     ${A1_3}=    parser.get_field_value_by_xpath    pdml_list=${A13_packets}    xpath=.//nr-rrc.eventId
#     should be equal    ${A1_3[1]}    2
#     ${A22_expression}=     Catenate    nr-rrc.reportConfigToAddModList == 1
#     ${A22_packets}=    parser.filter_packets_by_expression    filter_expression=${A22_expression}
#     ${A22_2}=    parser.get_field_value_by_xpath    pdml_list=${A22_packets}    xpath=.//nr-rrc.eventId
#     should be equal    ${A22_2[0]}    1
# 
# Check NRCELLA2 OK on gNB
#     [Arguments]    ${log_name}
#     ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${log_name}    tshark_path=${tshark_path}
#     ...                command_template=${command_template_X}
#     ${A21_expression}=     Catenate    f1ap.procedureCode == 5 and nr-rrc.a2_Threshold == 1 and nr-rrc.a2_Threshold == 0
#     ${A21_packets}=    parser.filter_packets_by_expression    filter_expression=${A21_expression}
#     ${A21_1}=    parser.get_field_value_by_xpath    pdml_list=${A21_packets}    xpath=.//nr-rrc.eventId
#     should be equal    ${A21_1[0]}    1
#     ${A2T_packets}=    parser.filter_packets_by_expression    filter_expression=${A21_expression}
#     ${A2T_1}=    parser.get_field_value_by_xpath    pdml_list=${A2T_packets}    xpath=.//nr-rrc.timeToTrigger
#     should be equal    ${A2T_1[0]}    10
#     ${A15_expression}=     Catenate    f1ap.procedureCode == 7 and nr-rrc.eventId == 0 and nr-rrc.carrierFreq == 1025
#     ${A15_packets}=    parser.filter_packets_by_expression    filter_expression=${A15_expression}
#     ${A15_1}=    parser.get_field_value_by_xpath    pdml_list=${A15_packets}    xpath=.//nr-rrc.carrierFreq
#     should be equal    ${A15_1[0]}    1025
#     ${A5B_packets}=    parser.filter_packets_by_expression    filter_expression=${A15_expression}
#     ${A5B_1}=    parser.get_field_value_by_xpath    pdml_list=${A5B_packets}    xpath=.//nr-rrc.freqBandIndicatorNR
#     should be equal    ${A5B_1[1]}    41
# 
# Check intraG interF HO OK on gNB 03
#      [Arguments]    ${log_name}
#     ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${log_name}    tshark_path=${tshark_path}
#     ...                command_template=${command_template_X}
#     ${A15_expression}=     Catenate    f1ap.procedureCode == 12 and nr-rrc.eventId == 0
#     ${A15_packets}=    parser.filter_packets_by_expression    filter_expression=${A15_expression}
#     ${A15_1}=    parser.get_field_value_by_xpath    pdml_list=${A15_packets}    xpath=.//nr-rrc.eventId
#     should be equal    ${A15_1[1]}    4
#     ${A5B_packets}=    parser.filter_packets_by_expression    filter_expression=${A15_expression}
#     ${A5B_1}=    parser.get_field_value_by_xpath    pdml_list=${A5B_packets}    xpath=.//nr-rrc.freqBandIndicatorNR
#     should be equal    ${A5B_1[0]}    71
#     ${SSBF_packets}=    parser.filter_packets_by_expression    filter_expression=${A15_expression}
#     ${SSBF_2}=    parser.get_field_value_by_xpath    pdml_list=${SSBF_packets}    xpath=.//nr-rrc.ssbFrequency
#     should be equal    ${SSBF_2[0]}    124810
#     ${MR_expression}=     Catenate    f1ap.procedureCode == 13 and nr-rrc.physCellId == ${cell_2}
#     ${Tcell_packets}=    parser.filter_packets_by_expression    filter_expression=${MR_expression}
#     ${Tc_1}=    parser.get_field_value_by_xpath    pdml_list=${Tcell_packets}    xpath=.//nr-rrc.physCellId
#     should be equal    ${Tc_1[1]}    ${cell_2}
#     ${HO_expression}=     Catenate    f1ap.procedureCode == 12 and nr-rrc.measObjectToRemoveList == 1
#     ${A35_packets}=    parser.filter_packets_by_expression    filter_expression=${HO_expression}
#     ${A3_1}=    parser.get_field_value_by_xpath    pdml_list=${A35_packets}    xpath=.//nr-rrc.eventId
#     should be equal    ${A3_1[0]}    2
#     ${A5_1}=    parser.get_field_value_by_xpath    pdml_list=${A35_packets}    xpath=.//nr-rrc.eventId
#     should be equal    ${A5_1[1]}    4
#     ${sc_1}=    parser.get_field_value_by_xpath    pdml_list=${A35_packets}    xpath=.//nr-rrc.physCellId
#     should be equal    ${sc_1[0]}    ${cell_2}
#     ${Spa_1}=    parser.get_field_value_by_xpath    pdml_list=${A35_packets}    xpath=.//nr-rrc.absoluteFrequencyPointA
#     should be equal    ${Spa_1[0]}    123478
#     ${nA2_1}=    parser.get_field_value_by_xpath    pdml_list=${A35_packets}    xpath=.//nr-rrc.a2_Threshold
#     should be empty     ${nA2_1}
# 
# 
# Check intraG interF HO OK on gNB E09
#     [Arguments]    ${log_name}
#     ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${log_name}    tshark_path=${tshark_path}
#     ...                command_template=${command_template_X}
#     ${A21_expression}=     Catenate    f1ap.procedureCode == 5 and nr-rrc.a2_Threshold == 1
#     ${A21_packets}=    parser.filter_packets_by_expression    filter_expression=${A21_expression}
#     ${A21_1}=    parser.get_field_value_by_xpath    pdml_list=${A21_packets}    xpath=.//nr-rrc.eventId
#     should be equal    ${A21_1[0]}    1
#     ${A13_expression}=     Catenate    f1ap.procedureCode == 12 and nr-rrc.eventId == 0
#     ${A13_packets}=    parser.filter_packets_by_expression    filter_expression=${A13_expression}
#     ${A13_1}=    parser.get_field_value_by_xpath    pdml_list=${A13_packets}    xpath=.//nr-rrc.eventId
#     should be equal    ${A13_1[1]}    2
#     ${Tband_1}=    parser.get_field_value_by_xpath    pdml_list=${A13_packets}    xpath=.//nr-rrc.freqBandIndicatorNR
#     should be equal    ${Tband_1[0]}    41
#     ${SSBF_1}=    parser.get_field_value_by_xpath    pdml_list=${A13_packets}    xpath=.//nr-rrc.ssbFrequency
#     should be equal    ${SSBF_1[0]}    518910
#     ${Ree_expression}=     Catenate    f1ap.procedureCode == 11 and nr-rrc.c1 == 2
#     ${Ree_packets}=    parser.filter_packets_by_expression    filter_expression=${Ree_expression}
#     ${Ree_1}=    parser.get_field_value_by_xpath    pdml_list=${Ree_packets}    xpath=.//nr-rrc.physCellId
#     should be empty    ${Ree_1}
#     ${MR_expression}=     Catenate    f1ap.procedureCode == 13 and nr-rrc.physCellId == ${cell_3}
#     ${Tcell_packets}=    parser.filter_packets_by_expression    filter_expression=${MR_expression}
#     ${Tc_1}=    parser.get_field_value_by_xpath    pdml_list=${Tcell_packets}    xpath=.//nr-rrc.physCellId
#     should be equal    ${Tc_1[1]}    ${cell_3}
#     ${HO_expression}=     Catenate    f1ap.procedureCode == 12 and nr-rrc.measObjectToRemoveList == 1
#     ${A23_packets}=    parser.filter_packets_by_expression    filter_expression=${HO_expression}
#     ${A2_1}=    parser.get_field_value_by_xpath    pdml_list=${A23_packets}    xpath=.//nr-rrc.eventId
#     should be equal    ${A2_1[0]}    1
#     ${A3_1}=    parser.get_field_value_by_xpath    pdml_list=${A23_packets}    xpath=.//nr-rrc.eventId
#     should be equal    ${A3_1[1]}    2
#     ${sc_1}=    parser.get_field_value_by_xpath    pdml_list=${A23_packets}    xpath=.//nr-rrc.physCellId
#     should be equal    ${sc_1[0]}    ${cell_3}
#     ${Spa_1}=    parser.get_field_value_by_xpath    pdml_list=${A23_packets}    xpath=.//nr-rrc.absoluteFrequencyPointA
#     should be equal    ${Spa_1[0]}    509172
#     ${noA13_expression}=     Catenate    f1ap.procedureCode == 12 and nr-rrc.ReportConfigId == 7
#     ${noA13_packets}=    parser.filter_packets_by_expression    filter_expression=${noA13_expression}
#     ${noA1_1}=    parser.get_field_value_by_xpath    pdml_list=${noA13_packets}    xpath=.//nr-rrc.a1_Threshold
#     should be empty     ${noA1_1}
#     ${noA3_1}=    parser.get_field_value_by_xpath    pdml_list=${noA13_packets}    xpath=.//nr-rrc.a3_Threshold
#     should be empty     ${noA3_1}
#     ${Reid_1}=    parser.get_field_value_by_xpath    pdml_list=${noA13_packets}    xpath=.//nr-rrc.ReportConfigId
#     should be equal    ${Reid_1[0]}    7
# 
# 
# Check intrerG interF HO OK on gNB1 E04
#     [Arguments]    ${log_name}
#     ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${log_name}    tshark_path=${tshark_path}
#     ...                command_template=${command_template_X}
#     ${A21_expression}=     Catenate    f1ap.procedureCode == 5 and nr-rrc.eventId == 1
#     ${A21_packets}=    parser.filter_packets_by_expression    filter_expression=${A21_expression}
#     ${A21_1}=    parser.get_field_value_by_xpath    pdml_list=${A21_packets}    xpath=.//nr-rrc.eventId
#     should be equal    ${A21_1[0]}    1
#     ${A3_1}=    parser.get_field_value_by_xpath    pdml_list=${A21_packets}    xpath=.//nr-rrc.eventId
#     should be equal    ${A3_1[3]}    2
#     ${A15_expression}=     Catenate    f1ap.procedureCode == 12 and nr-rrc.eventId == 0
#     ${A15_packets}=    parser.filter_packets_by_expression    filter_expression=${A15_expression}
#     ${A15_1}=    parser.get_field_value_by_xpath    pdml_list=${A15_packets}    xpath=.//nr-rrc.eventId
#     should Contain    ${A15_1}    4
#     ${B2_1}=    parser.get_field_value_by_xpath    pdml_list=${A15_packets}    xpath=.//nr-rrc.eventId
#     should Contain    ${B2_1}    1
#     ${4G_1}=    parser.get_field_value_by_xpath    pdml_list=${A15_packets}    xpath=.//nr-rrc.carrierFreq
#     should be equal    ${4G_1[0]}    1055
#     ${Tband_1}=    parser.get_field_value_by_xpath    pdml_list=${A15_packets}    xpath=.//nr-rrc.freqBandIndicatorNR
#     should be equal    ${Tband_1[0]}    71
#     ${SSBF_1}=    parser.get_field_value_by_xpath    pdml_list=${A15_packets}    xpath=.//nr-rrc.ssbFrequency
#     should Contain    ${SSBF_1}    124810
#     ${Ree_expression}=     Catenate    f1ap.procedureCode == 11 and nr-rrc.c1 == 2
#     ${Ree_packets}=    parser.filter_packets_by_expression    filter_expression=${Ree_expression}
#     ${Ree_1}=    parser.get_field_value_by_xpath    pdml_list=${Ree_packets}    xpath=.//nr-rrc.physCellId
#     should be empty    ${Ree_1}
#     ${MR_expression}=     Catenate    f1ap.procedureCode == 13 and nr-rrc.physCellId == ${cell_4}
#     ${Tcell_packets}=    parser.filter_packets_by_expression    filter_expression=${MR_expression}
#     ${Tc_1}=    parser.get_field_value_by_xpath    pdml_list=${Tcell_packets}    xpath=.//nr-rrc.physCellId
#     should be equal    ${Tc_1[1]}    ${cell_4}
#     ${Rel_expression}=     Catenate    f1ap.procedureCode == 6 and f1ap.radioNetwork == 10
#     ${Rel_packets}=    parser.filter_packets_by_expression    filter_expression=${Rel_expression}
#     ${Rel_1}=    parser.get_field_value_by_xpath    pdml_list=${Rel_packets}    xpath=.//f1ap.radioNetwork
#     should be equal    ${Rel_1[0]}    10
#     ${XN_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${log_name}    tshark_path=${tshark_path}
#     ...                command_template=${command_template_Z}
#     ${XNHO_expression}=     Catenate    xnap.procedureCode == 0 and xnap.radioNetwork == 1
#     ${HOreq_packets}=    parser.filter_packets_by_expression    filter_expression=${XNHO_expression}
#     ${HOreq_1}=    parser.get_field_value_by_xpath    pdml_list=${HOreq_packets}    xpath=.//xnap.radioNetwork
#     should be equal    ${HOreq_1[0]}    1
#     ${XNHOa_expression}=     Catenate    xnap.procedureCode == 0 and xnap.id == 77
#     ${HOa_packets}=    parser.filter_packets_by_expression    filter_expression=${XNHOa_expression}
#     ${HOa_s}=    parser.get_field_value_by_xpath    pdml_list=${HOa_packets}    xpath=.//xnap.id
#     should be equal    ${HOa_s[0]}    73
#     ${HOa_t}=    parser.get_field_value_by_xpath    pdml_list=${HOa_packets}    xpath=.//xnap.id
#     should be equal    ${HOa_t[1]}    79
# 
# Check intrerG interF HO OK on gNB2 E04
#     [Arguments]    ${log_name}
#     ${XN_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${log_name}    tshark_path=${tshark_path}
#     ...                command_template=${command_template_Z}
#     ${HOR_expression}=     Catenate    xnap.procedureCode == 0 and xnap.radioNetwork == 1
#     ${HOR_packets}=    parser.filter_packets_by_expression    filter_expression=${HOR_expression}
#     ${HOR_1}=    parser.get_field_value_by_xpath    pdml_list=${HOR_packets}    xpath=.//xnap.radioNetwork
#     should be equal    ${HOR_1[0]}    1
#     ${SNS_expression}=     Catenate    xnap.procedureCode == 1
#     ${SNS_packets}=    parser.filter_packets_by_expression    filter_expression=${SNS_expression}
#     ${SNS_s}=    parser.get_field_value_by_xpath    pdml_list=${SNS_packets}    xpath=.//xnap.id
#     should be equal    ${SNS_s[0]}    73
#     ${SNS_t}=    parser.get_field_value_by_xpath    pdml_list=${SNS_packets}    xpath=.//xnap.id
#     should be equal    ${SNS_t[1]}    79
#     ${UER_expression}=     Catenate    xnap.procedureCode == 6
#     ${UER_packets}=    parser.filter_packets_by_expression    filter_expression=${UER_expression}
#     ${UER_s}=    parser.get_field_value_by_xpath    pdml_list=${UER_packets}    xpath=.//xnap.id
#     should be equal    ${UER_s[0]}    73
#     ${UER_t}=    parser.get_field_value_by_xpath    pdml_list=${UER_packets}    xpath=.//xnap.id
#     should be equal    ${UER_t[1]}    79
#     ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${log_name}    tshark_path=${tshark_path}
#     ...                command_template=${command_template_X}
#     ${SETUP_expression}=     Catenate    f1ap.procedureCode == 5 and nr-rrc.physCellId == ${cell_4}
#     ${Tcell_packets}=    parser.filter_packets_by_expression    filter_expression=${SETUP_expression}
#     ${Tc_1}=    parser.get_field_value_by_xpath    pdml_list=${Tcell_packets}    xpath=.//nr-rrc.physCellId
#     should Contain    ${Tc_1}    ${cell_4}
#     ${A3_1}=    parser.get_field_value_by_xpath    pdml_list=${Tcell_packets}    xpath=.//nr-rrc.eventId
#     should be equal    ${A3_1[0]}    2
#     ${nA2_1}=    parser.get_field_value_by_xpath    pdml_list=${Tcell_packets}    xpath=.//nr-rrc.a2_Threshold
#     should be empty     ${nA2_1}
#     ${SSBF_1}=    parser.get_field_value_by_xpath    pdml_list=${Tcell_packets}    xpath=.//nr-rrc.ssbFrequency
#     should be equal    ${SSBF_1[0]}    124810
# 
# Check VONR DRX gNB1 E05
#     [Arguments]    ${log_name}
#     ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${log_name}    tshark_path=${tshark_path}
#     ...                command_template=${command_template_X}
#     ${DRX_expression}=     Catenate    f1ap.procedureCode == 12 and nr-rrc.drx_InactivityTimer == 14
#     ${DRX_packets}=    parser.filter_packets_by_expression    filter_expression=${DRX_expression}
#     ${DRX_IN}=    parser.get_field_value_by_xpath    pdml_list=${DRX_packets}    xpath=.//nr-rrc.drx_InactivityTimer
#     should be equal    ${DRX_IN[0]}    14
#     ${DRX_mil}=    parser.get_field_value_by_xpath    pdml_list=${DRX_packets}    xpath=.//nr-rrc.milliSeconds
#     should be equal    ${DRX_mil[0]}    7
#     ${DRX_long}=    parser.get_field_value_by_xpath    pdml_list=${DRX_packets}    xpath=.//nr-rrc.drx_LongCycleStartOffset
#     should be equal    ${DRX_long[0]}    9
#     ${DRXV_expression}=     Catenate    f1ap.procedureCode == 12 and nr-rrc.drx_InactivityTimer == 4
#     ${DRXV_packets}=    parser.filter_packets_by_expression    filter_expression=${DRXV_expression}
#     ${DRXV_IN}=    parser.get_field_value_by_xpath    pdml_list=${DRXV_packets}    xpath=.//nr-rrc.drx_InactivityTimer
#     should be equal    ${DRXV_IN[0]}    4
# #    ${DRXV_mil}=    parser.get_field_value_by_xpath    pdml_list=${DRXV_packets}    xpath=.//nr-rrc.milliSeconds
# #    should be equal    ${DRXV_mil[0]}    7
#     ${DRXV_long}=    parser.get_field_value_by_xpath    pdml_list=${DRXV_packets}    xpath=.//nr-rrc.drx_LongCycleStartOffset
#     should be equal    ${DRXV_long[0]}    3
# 
# Check VONR DRX gNB2 E05
#     [Arguments]    ${log_name}
#     ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${log_name}    tshark_path=${tshark_path}
#     ...                command_template=${command_template_X}
#     ${DRX_expression}=     Catenate    f1ap.procedureCode == 12 and nr-rrc.drx_InactivityTimer == 14
#     ${DRX_packets}=    parser.filter_packets_by_expression    filter_expression=${DRX_expression}
#     ${DRX_IN}=    parser.get_field_value_by_xpath    pdml_list=${DRX_packets}    xpath=.//nr-rrc.drx_InactivityTimer
#     should be equal    ${DRX_IN[0]}    14
# #    ${DRX_mil}=    parser.get_field_value_by_xpath    pdml_list=${DRX_packets}    xpath=.//nr-rrc.milliSeconds
# #    should be equal    ${DRX_mil[0]}    7
#     ${DRX_long}=    parser.get_field_value_by_xpath    pdml_list=${DRX_packets}    xpath=.//nr-rrc.drx_LongCycleStartOffset
#     should be equal    ${DRX_long[0]}    9
#     ${DRXV_expression}=     Catenate    f1ap.procedureCode == 12 and nr-rrc.drx_InactivityTimer == 4
#     ${DRXV_packets}=    parser.filter_packets_by_expression    filter_expression=${DRXV_expression}
#     ${DRXV_IN}=    parser.get_field_value_by_xpath    pdml_list=${DRXV_packets}    xpath=.//nr-rrc.drx_InactivityTimer
#     should be equal    ${DRXV_IN[0]}    4
# #    ${DRXV_mil}=    parser.get_field_value_by_xpath    pdml_list=${DRXV_packets}    xpath=.//nr-rrc.milliSeconds
# #    should be equal    ${DRXV_mil[0]}    7
#     ${DRXV_long}=    parser.get_field_value_by_xpath    pdml_list=${DRXV_packets}    xpath=.//nr-rrc.drx_LongCycleStartOffset
#     should be equal    ${DRXV_long[0]}    3
# 
# Check intrerG interF HO OK on gNB1 E05
#     [Arguments]    ${log_name}
#     ${NG_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${log_name}    tshark_path=${tshark_path}
#     ...                command_template=${command_template_Y}
#     ${5QI5_expression}=     Catenate    ngap.fiveQI == 5 and ngap.priorityLevelARP == 5
#     ${5QI5_packets}=    parser.filter_packets_by_expression    filter_expression=${5QI5_expression}
#     ${ims_5QI5}=    parser.get_field_value_by_xpath    pdml_list=${5QI5_packets}    xpath=.//ngap.fiveQI
#     should be equal    ${ims_5QI5[0]}    5
#     ${5QI1_expression}=     Catenate    ngap.fiveQI == 1 and ngap.priorityLevelARP == 3
#     ${5QI1_packets}=    parser.filter_packets_by_expression    filter_expression=${5QI1_expression}
#     ${ims_5QI1}=    parser.get_field_value_by_xpath    pdml_list=${5QI1_packets}    xpath=.//ngap.fiveQI
#     should be equal    ${ims_5QI1[0]}    1
#     ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${log_name}    tshark_path=${tshark_path}
#     ...                command_template=${command_template_X}
#     ${A21_expression}=     Catenate    f1ap.procedureCode == 12 and nr-rrc.timeToTrigger == 12
#     ${A21_packets}=    parser.filter_packets_by_expression    filter_expression=${A21_expression}
#     ${A21_v}=    parser.get_field_value_by_xpath    pdml_list=${A21_packets}    xpath=.//nr-rrc.eventId
#     should be equal    ${A21_v[0]}    1
#     ${A22_expression}=     Catenate    f1ap.procedureCode == 5 and nr-rrc.a2_Threshold == 1
#     ${A22_packets}=    parser.filter_packets_by_expression    filter_expression=${A22_expression}
#     ${A22_h}=    parser.get_field_value_by_xpath    pdml_list=${A22_packets}    xpath=.//nr-rrc.eventId
#     should be equal    ${A22_h[0]}    1
#     ${A15_expression}=     Catenate    f1ap.procedureCode == 12 and nr-rrc.eventId == 0
#     ${A15_packets}=    parser.filter_packets_by_expression    filter_expression=${A15_expression}
#     ${A1_h}=    parser.get_field_value_by_xpath    pdml_list=${A15_packets}    xpath=.//nr-rrc.hysteresis
#     should be equal    ${A1_h[0]}    2
#     ${A15_1}=    parser.get_field_value_by_xpath    pdml_list=${A15_packets}    xpath=.//nr-rrc.eventId
#     should be equal    ${A15_1[1]}    4
#     ${A15_T}=    parser.get_field_value_by_xpath    pdml_list=${A15_packets}    xpath=.//nr-rrc.timeToTrigger
#     should be equal    ${A15_T[1]}    11
#     ${A5B_packets}=    parser.filter_packets_by_expression    filter_expression=${A15_expression}
#     ${A5B_1}=    parser.get_field_value_by_xpath    pdml_list=${A5B_packets}    xpath=.//nr-rrc.freqBandIndicatorNR
#     should be equal    ${A5B_1[0]}    71
#     ${SSBF_packets}=    parser.filter_packets_by_expression    filter_expression=${A15_expression}
#     ${SSBF_2}=    parser.get_field_value_by_xpath    pdml_list=${SSBF_packets}    xpath=.//nr-rrc.ssbFrequency
#     should be equal    ${SSBF_2[1]}    124810
#     ${MR_expression}=     Catenate    f1ap.procedureCode == 13 and nr-rrc.physCellId == ${cell_4}
#     ${Tcell_packets}=    parser.filter_packets_by_expression    filter_expression=${MR_expression}
#     ${Tc_1}=    parser.get_field_value_by_xpath    pdml_list=${Tcell_packets}    xpath=.//nr-rrc.physCellId
#     should be equal    ${Tc_1[1]}    ${cell_4}
#     ${Ree_expression}=     Catenate    f1ap.procedureCode == 11 and nr-rrc.c1 == 2
#     ${Ree_packets}=    parser.filter_packets_by_expression    filter_expression=${Ree_expression}
#     ${Ree_1}=    parser.get_field_value_by_xpath    pdml_list=${Ree_packets}    xpath=.//nr-rrc.physCellId
#     should be empty    ${Ree_1}
#     ${Rel_expression}=     Catenate    f1ap.procedureCode == 6 and f1ap.radioNetwork == 10
#     ${Rel_packets}=    parser.filter_packets_by_expression    filter_expression=${Rel_expression}
#     ${Rel_1}=    parser.get_field_value_by_xpath    pdml_list=${Rel_packets}    xpath=.//f1ap.radioNetwork
#     should be equal    ${Rel_1[0]}    10
#     ${XN_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${log_name}    tshark_path=${tshark_path}
#     ...                command_template=${command_template_Z}
#     ${HOR_expression}=     Catenate    xnap.procedureCode == 0 and xnap.radioNetwork == 1
#     ${HOR_packets}=    parser.filter_packets_by_expression    filter_expression=${HOR_expression}
#     ${HOR_1}=    parser.get_field_value_by_xpath    pdml_list=${HOR_packets}    xpath=.//xnap.radioNetwork
#     should be equal    ${HOR_1[0]}    1
#     ${SNS_expression}=     Catenate    xnap.procedureCode == 1
#     ${SNS_packets}=    parser.filter_packets_by_expression    filter_expression=${SNS_expression}
#     ${SNS_s}=    parser.get_field_value_by_xpath    pdml_list=${SNS_packets}    xpath=.//xnap.id
#     should be equal    ${SNS_s[0]}    73
#     ${SNS_t}=    parser.get_field_value_by_xpath    pdml_list=${SNS_packets}    xpath=.//xnap.id
#     should be equal    ${SNS_t[1]}    79
#     ${UER_expression}=     Catenate    xnap.procedureCode == 6
#     ${UER_packets}=    parser.filter_packets_by_expression    filter_expression=${UER_expression}
#     ${UER_s}=    parser.get_field_value_by_xpath    pdml_list=${UER_packets}    xpath=.//xnap.id
#     should be equal    ${UER_s[0]}    73
#     ${UER_t}=    parser.get_field_value_by_xpath    pdml_list=${UER_packets}    xpath=.//xnap.id
#     should be equal    ${UER_t[1]}    79
#     #${gtptunel}=        Catenate   ngap.procedureCode == 26 and ngap.qosFlowAddOrModifyResponseList
#     #${gtptunel_packet}    parser.filter_packets_by_expression    filter_expression=${gtptunel}
#     #${gtptunel_value}=    parser.get_field_value_by_xpath    pdml_list=${gtptunel_packet}
#     #...    xpath=.// xnap.pduSessionLevelDLDataForwardingInfo
#     #should not be empty     ${gtptunel_value}
# 
# Check intrerG interF HO OK on gNB2 E05
#     [Arguments]    ${log_name}
#     ${XN_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${log_name}    tshark_path=${tshark_path}
#     ...                command_template=${command_template_Z}
#     ${HOR_expression}=     Catenate    xnap.procedureCode == 0 and xnap.radioNetwork == 1
#     ${HOR_packets}=    parser.filter_packets_by_expression    filter_expression=${HOR_expression}
#     ${HOR_1}=    parser.get_field_value_by_xpath    pdml_list=${HOR_packets}    xpath=.//xnap.radioNetwork
#     should be equal    ${HOR_1[0]}    1
#     ${SNS_expression}=     Catenate    xnap.procedureCode == 1
#     ${SNS_packets}=    parser.filter_packets_by_expression    filter_expression=${SNS_expression}
#     ${SNS_s}=    parser.get_field_value_by_xpath    pdml_list=${SNS_packets}    xpath=.//xnap.id
#     should be equal    ${SNS_s[0]}    73
#     ${SNS_t}=    parser.get_field_value_by_xpath    pdml_list=${SNS_packets}    xpath=.//xnap.id
#     should be equal    ${SNS_t[1]}    79
#     ${UER_expression}=     Catenate    xnap.procedureCode == 6
#     ${UER_packets}=    parser.filter_packets_by_expression    filter_expression=${UER_expression}
#     ${UER_s}=    parser.get_field_value_by_xpath    pdml_list=${UER_packets}    xpath=.//xnap.id
#     should be equal    ${UER_s[0]}    73
#     ${UER_t}=    parser.get_field_value_by_xpath    pdml_list=${UER_packets}    xpath=.//xnap.id
#     should be equal    ${UER_t[1]}    79
#     ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${log_name}    tshark_path=${tshark_path}
#     ...                command_template=${command_template_X}
#     ${A21_expression}=     Catenate    f1ap.procedureCode == 5 and nr-rrc.timeToTrigger == 11
#     ${A21_packets}=    parser.filter_packets_by_expression    filter_expression=${A21_expression}
#     ${A21_v}=    parser.get_field_value_by_xpath    pdml_list=${A21_packets}    xpath=.//nr-rrc.eventId
#     should be equal    ${A21_v[0]}    1
#     ${A21_h}=    parser.get_field_value_by_xpath    pdml_list=${A21_packets}    xpath=.//nr-rrc.hysteresis
#     should be equal    ${A21_h[0]}    4
#     ${A2d_expression}=     Catenate    f1ap.procedureCode == 12 and nr-rrc.timeToTrigger == 9
#     ${A2d_packets}=    parser.filter_packets_by_expression    filter_expression=${A2d_expression}
#     ${A2d_d}=    parser.get_field_value_by_xpath    pdml_list=${A2d_packets}    xpath=.//nr-rrc.eventId
#     should Contain    ${A2d_d}    1
#     ${A22_h}=    parser.get_field_value_by_xpath    pdml_list=${A2d_packets}    xpath=.//nr-rrc.hysteresis
#     should Contain    ${A22_h}    0
#     ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${log_name}    tshark_path=${tshark_path}
#     ...                command_template=${command_template_Y}
#     ${VOR_expression}=     Catenate    ngap.procedureCode == 26 and ngap.nas == 0
#     ${VOR_packets}=    parser.filter_packets_by_expression    filter_expression=${VOR_expression}
#     ${VOR_s}=    parser.get_field_value_by_xpath    pdml_list=${VOR_packets}    xpath=.//ngap.nas
#     should Contain    ${VOR_s}    0
#     #${gtptunel}=        Catenate   ngap.procedureCode == 26 and ngap.qosFlowAddOrModifyResponseList
#     #${gtptunel_packet}    parser.filter_packets_by_expression    filter_expression=${gtptunel}
#     #${gtptunel_value}=    parser.get_field_value_by_xpath    pdml_list=${gtptunel_packet}
#     #...    xpath=.// xnap.pduSessionLevelDLDataForwardingInfo
#     #should not be empty     ${gtptunel_value}
# 
# Precondition for attn
#     [Arguments]    ${value1}    ${value2}    ${value3}    ${value4}    ${value5}
#     Run Keyword if    '${release_info}' == 'SBTS22R3_ENB_0000'    Precondition for attn 22R3    value1=${value1}    value2=${value2}
#     ...    value3=${value3}    value4=${value4}    value5=${value5}
#     ...    ELSE IF     '${release_info}' == 'SBTS23R1_ENB_0000'    Precondition for attn Trunk    value1=${value1}    value2=${value2}
#     ...    value3=${value3}    value4=${value4}    value5=${value5}
#     ...    ELSE    Precondition for attn 22R4    value1=${value1}    value2=${value2}    value3=${value3}
#     ...    value4=${value4}    value5=${value5}
# 
# Precondition for attn Trunk
#     [Arguments]    ${value1}    ${value2}    ${value3}    ${value4}    ${value5}=${127}
#     adjust the HBTE attenuation value    value=${value1}    att_port_1=${att_port_1}    att_port_2=${att_port_2}    atten_ip=${atten_ip}
#     adjust the HBTE attenuation value    value=${value2}    att_port_1=${att_port_3}    att_port_2=${att_port_4}    atten_ip=${atten_ip}
#     adjust the HBTE attenuation value    value=${value3}    att_port_1=${att_port_5}    att_port_2=${att_port_6}    atten_ip=${atten_ip}
#     adjust the HBTE attenuation value    value=${value5}    att_port_1=${att_port_7}    att_port_2=${att_port_8}    atten_ip=${atten_ip}
#     adjust the HBTE attenuation value    value=${value4}    att_port_1=${att_port_9}    att_port_2=${att_port_10}    atten_ip=${atten_ip}
# 
# Precondition for attn 22R4
#     [Arguments]    ${value1}    ${value2}    ${value3}    ${value4}    ${value5}=${127}
#     adjust the HBTE attenuation value    value=${value1}    att_port_1=${att_port_1}    att_port_2=${att_port_2}    atten_ip=${atten_ip}
#     adjust the HBTE attenuation value    value=${value2}    att_port_1=${att_port_3}    att_port_2=${att_port_4}    atten_ip=${atten_ip}
#     adjust the HBTE attenuation value    value=${value3}    att_port_1=${att_port_5}    att_port_2=${att_port_6}    atten_ip=${atten_ip}
#     adjust the HBTE attenuation value    value=${value5}    att_port_1=${att_port_7}    att_port_2=${att_port_8}    atten_ip=${atten_ip}
#     adjust the HBTE attenuation value    value=${value4}    att_port_1=${att_port_9}    att_port_2=${att_port_10}    atten_ip=${atten_ip}
# 
# Precondition for attn 22R3
#     [Arguments]    ${value1}    ${value2}    ${value3}    ${value4}    ${value5}=${127}
#     adjust the HBTE attenuation value    value=${value1}    att_port_1=${att_port_1}    att_port_2=${att_port_2}    atten_ip=${atten_ip}
#     adjust the HBTE attenuation value    value=${value2}    att_port_1=${att_port_3}    att_port_2=${att_port_4}    atten_ip=${atten_ip}
#     adjust the HBTE attenuation value    value=${value3}    att_port_1=${att_port_5}    att_port_2=${att_port_6}    atten_ip=${atten_ip}
#     adjust the HBTE attenuation value    value=${value5}    att_port_1=${att_port_7}    att_port_2=${att_port_8}    atten_ip=${atten_ip}
#     adjust the HBTE attenuation value    value=${value4}    att_port_1=${att_port_9}    att_port_2=${att_port_10}    atten_ip=${atten_ip}
# 
# Make a voice call on UE
#     [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
#     Make a call on UE(dial +6688 on UE)    ue_index=${ue_index}    serial_number=${serial_number}
# 
# 
# Make a call on UE(dial +6688 on UE)
#     [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
#     csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
#     ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
#     ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
#     sleep   5s
#     Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input keyevent 82
#     ...    connection=cygwin${ue_index}
#     sleep   2s
#     Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input swipe 500 2050 500 800
#     ...    connection=cygwin${ue_index}
#     sleep   2s
#     csn.send_command    command=adb -s ${serial_number} shell am start -a android.intent.action.CALL tel:+6688
#     ...    connection=cygwin${ue_index}
#     sleep   15s
# 
# End a call on UE
#     [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
#     csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
#     ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
#     ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
#     sleep   5s
#     Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input keyevent 82
#     ...    connection=cygwin${ue_index}
#     sleep   2s
#     Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input swipe 500 2050 500 800
#     ...    connection=cygwin${ue_index}
#     sleep   2s
#     csn.send_command    command=adb -s ${serial_number} shell input keyevent 6    connection=cygwin${ue_index}
#     sleep   2s
#     csn.disconnect      connection=cygwin${ue_index}
# 
# #Attach and check power UE
# #    [Arguments]    ${ue_type}    ${ue_index}=${0}    ${4G_check}=False
# #     ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}
# #     sleep   15s
# #    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    ue_index=${ue_index}    4G_check=${4G_check}
# 
# Check the cell DL throughput
#     [Arguments]    ${cellid}    ${gnb_index}=${0}
#     Set nrcellid suit varaible    cellid=${cellid}    gnb_index=${gnb_index}
#     Wait Until Keyword Succeeds   5x    10s    power_ue.Check Throughput    sample=${6}    gnb_index=${gnb_index}
#     ...    ue_type=${ue_type}    direction=dl    throughput=${dlexpect_tput}    cellid=${nrcellid}    sleep_time=${20}
# #    Wait Until Keyword Succeeds   5x    10s    power_ue.Check Throughput    sample=${6}    gnb_index=${gnb_index}
# #    ...    ue_type=${ue_type}    direction=ul    throughput=${ulexpect_tput}    cellid=${nrcellid}    sleep_time=${20}
