# *** Settings ***
# Documentation     author: xingjing && Cindy jin
# ...               contact: jing.1.xing@nokia-sbell.com && cindy.1.jin@nokia-sbell.com
# ...               squad group: SG_03
# ...               feature : 5GC000710_A
# 
# Force Tags    CA_5G_RRM
# ...    PY36
# Resource    ../Resources/5GC000710_common_keyword.robot
# Resource    ../Resources/5GC000710_nsa_common_keywords.robot
# Library    taf.analyzer.pcap     WITH NAME    cap
# 
# 
# Suite Setup    Run Keywords
# ...           Run Keyword And Ignore Error    Common Suite Setup for COAM    AND
# ...           Set suite variables    AND
# ...           Precondition for power UE    ue_type=${ue_type}    AND
# ...           Prepare the gNB cells onair status    gnb_index=${0}     tl_scf_file_name=${tl_scf_file_name_gnb1_710A}    AND
# ...           Prepare the gNB cells onair status    gnb_index=${1}     tl_scf_file_name=${tl_scf_file_name_gnb2_710A}
# 
# Suite Teardown    Run Keywords
# ...        Run Keyword If Any Tests Failed
# ...       Run Keyword And Ignore Error    Delete all NRADJGNB object      AND
# ...       Run Keyword And Ignore Error    Common Suite Teardown for COAM    gnb_index=${0}     AND
# ...       Run Keyword And Ignore Error    Common Suite Teardown for COAM    gnb_index=${1}
# 
# 
# *** Variables ***
# ${x2logname_01}    gnb_x2_015_01.pcap
# ${x2logname_02}    gnb_x2_016_01.pcap
# ${x2logname_03}    gnb_x2_010_01.pcap
# ${x2logname_04}    gnb_x2_012_01.pcap
# ${x2logname_05}    gnb_x2_013_01.pcap
# ${gnb_path}    /tmp/
# ${tshark_path}              /usr/bin/tshark
# ${min}                       ${0}
# #${triggger_handover}         ${30}
# ${max}                       ${127}
# ${counter_path}     BTS/CELLS/NRCELL-1/NRMOP
# ${counter_path_cell3}     BTS/CELLS/NRCELL-3/NRMOP
# ${counter_MP32}    M55157C00032 
# ${counter_MP2}    M55157C00002
# ${counter_MP1}    M55157C00001
# ${triggger_A2}    ${20}
# ${ui_version}     S20UI2.5
# ${epc_log_path}     /home/ute/TAF/cindy/710A_log/
# ${dl_throughput_p}    810M
# ${ul_throughput_p}     60M
# ${ul_tp_expect_p}    54
# ${dl_tp_expect_p}    795
# 
# *** Test Cases ***
# [1]5GC000710_A_015_Successful_Inter-Freq_Inter-gNB_PSCell_change_based_on_A5_measurement_report
#     [Documentation]
#     ...    To verify the successful inter-Frequency Inter-gNB PSCell change without SRB3 procedure with mobility
#     ...    profile selection on target cell on receipt of inter-frequency A3/A5 measurement report
#     [Tags]    CRT_22R2   CRT_TRUNK    CRT_22R1    5GC000710    CRT_22R3    CRT_22R4    CRT_23R1
#     [Timeout]    1 hour
#     [Setup]
#     #RUN KEYWORD IF    '${cell_status}'=='False'    Prepare the gNB cells onair status
#     should be equal    '${cell_status}'    'True'
#     Online modify parmeters    parameters_to_update=${PARAMS_TO_MODIFY_710_A15_1_trunk}    gnb_index=${1}
#     Precondition for attn    value1=${${min}}
#     sleep    10s
#     Set nrcellid suit varaible    cellid=${1}
#     Start Capture Classical enb x2 Logs    x2logname=${x2logname_01}
#     Attach and check power UE    ue_type=${ue_type}    4G_check=${True}
#     Start DL UL traffic and monitor throughput
#     adjust PA to trigger HO    value1=${${triggger_handover}}
#     sleep    3s
#     Set nrcellid suit varaible    cellid=${1}    gnb_index=${1}
#     Evaluate throughput on target cell    gnb_index=${1}
#     Stop and Save classical enb x2 Logs    x2logname=${x2logname_01}
#     Check initial A2 measurement config    x2logname=${x2logname_01}
#     Check measgap setup    x2logname=${x2logname_01}
#     Analysis wireshark log for case015    x2logname=${x2logname_01}
#     wait until keyword succeeds    5 min    20 sec   Check PM the counter Result   counter_id=${counter_MP32}    dic_path=${counter_path}
#     wait until keyword succeeds    10 min    20 sec   Check PM the counter Result   counter_id=${counter_MP2}    dic_path=${counter_path}
#     ...    gnb_index=${1}
#     [Teardown]    Run keywords
#     ...    Run Keyword And Ignore Error     Online modify parmeters    parameters_to_update=${PARAMS_TO_MODIFY_710_A15_2_trunk}
#     ...    gnb_index=${1}    AND
#     ...    Run Keyword And Ignore Error    Tests Recovery    x2logname=${x2logname_01}
# 
# 
# #[1]5GC000710_A_016_Successful_Inter-Freq_Intra-gNB_PSCell_change_with_measurement_configuration_update
# #    [Documentation]
# #    ...   To verify the successful inter-Frequency Intra-gNB PSCell change without SRB3 procedure with SPID update
# #    ...   before A3/A5 measurement reported
# #    [Tags]    5GC000710
# #    [Timeout]    1 hour
# #    [Setup]
# #    #RUN KEYWORD IF    '${cell_status}'=='False'   Prepare the gNB cells onair status
# #    should be equal    '${cell_status}'    'True'
# #    Online modify parmeters    parameters_to_update=${PARAMS_TO_MODIFY_710_A16_1_trunk}
# #    Precondition for attn    value1=${${min}}
# #    sleep    10s
# #    Set nrcellid suit varaible    cellid=${1}
# #    Start Capture Classical enb x2 Logs    x2logname=${x2logname_02}
# #    Attach and check power UE    ue_type=${ue_type}    4G_check=${True}
# #    Start DL UL traffic and monitor throughput
# #    sleep    3s
# #    adjust PA to trigger HO    value1=${${triggger_handover}}    value2=${${max}}
# #    Online modify parmeters    parameters_to_update=${PARAMS_TO_MODIFY_710_A16_2_trunk}
# #    adjust PA to trigger HO    value1=${${min}}    value2=${${max}}    Att_port_1=${${gnb1_cell3_port_1}}
# #    ...    Att_port_2=${${gnb1_cell3_port_2}}
# #    Set nrcellid suit varaible    cellid=${3}
# #    Evaluate throughput on target cell    gnb_index=${0}
# #    Stop and Save classical enb x2 Logs    x2logname=${x2logname_02}
# #    Check initial A2 measurement config    x2logname=${x2logname_02}
# #    Check measgap setup    x2logname=${x2logname_02}
# #    Check measgap release     x2logname=${x2logname_02}
# #    Analysis wireshark log for case016    x2logname=${x2logname_02}
# #    wait until keyword succeeds    10 min    20 sec   Check PM the counter Result   counter_id=${counter_MP2}
# #    ...    dic_path=${counter_path_cell3}
# #    Online modify parmeters    parameters_to_update=${PARAMS_TO_MODIFY_710_A16_3_trunk}
# #    Precondition for attn    value1=${${min}}
# #    sleep    10s
# #    Start Capture Classical enb x2 Logs    x2logname=${x2logname_03}
# #    Attach and check power UE    ue_type=${ue_type}    4G_check=${True}
# #    Set nrcellid suit varaible    cellid=${1}
# #    Start DL UL traffic and monitor throughput
# #    sleep    3s
# #    Online modify parmeters    parameters_to_update=${PARAMS_TO_MODIFY_710_A10_1_trunk}
# #    adjust PA to trigger HO    value1=${${triggger_handover}}    value2=${${min}}    Att_port_9=${${gnb1_cell3_port_1}}
# #    ...     Att_port_10=${${gnb1_cell3_port_1}}
# #    Set nrcellid suit varaible    cellid=${3}
# #    Evaluate throughput on target cell    gnb_index=${0}
# #    Stop and Save classical enb x2 Logs    x2logname=${x2logname_03}
# #    Check initial A2 measurement config    x2logname=${x2logname_03}
# #    Check measgap setup    x2logname=${x2logname_03}
# #    Check measgap release     x2logname=${x2logname_03}
# #    Analysis wireshark log for case010    x2logname=${x2logname_03}
# #    [Teardown]    Run keywords
# #    ...    Online modify parmeters    parameters_to_update=${PARAMS_TO_MODIFY_710_A10_2_trunk}    AND
# #    ...    Run Keyword And Ignore Error    Tests Recovery    x2logname=${x2logname_03}
# #    #...    Online modify parmeters    parameters_to_update=${PARAMS_TO_MODIFY_710_A16_3_trunk}    AND
# #    #...    Run Keyword And Ignore Error    Tests Recovery    x2logname=${x2logname_02}
# 
# 
# #[1]5GC000710_A_010_online_modification_of_mobility_profile_between_A2_measurement_setup_and_A2_Report
# #    [Documentation]
# #    ...   To verify that when the mobility profile is modified between A2 configuration in the UE and RRC
# #    ...    measurement report for event A2,
# #    ...    the new kind of measurement defined in the mobility profile selected for the UE is used
# #    [Tags]       5GC000710
# #    [Timeout]    1 hour
# #    [Setup]
# #    #RUN KEYWORD IF    '${cell_status}'=='False'    Prepare the gNB cells onair status
# #    should be equal    '${cell_status}'    'True'
# #    Precondition for attn    value1=${${min}}
# #    sleep    10s
# #    Start Capture Classical enb x2 Logs    x2logname=${x2logname_03}
# #    Attach and check power UE    ue_type=${ue_type}    4G_check=${True}
# #    Set nrcellid suit varaible    cellid=${1}
# #    Start DL UL traffic and monitor throughput
# #    sleep    3s
# #    Online modify parmeters    parameters_to_update=${PARAMS_TO_MODIFY_710_A10_1_trunk}
# #    adjust PA to trigger HO    value1=${${triggger_handover}}    value2=${${min}}    Att_port_9=${${gnb1_cell3_port_1}}
# #    ...     Att_port_10=${${gnb1_cell3_port_1}}
# #    Set nrcellid suit varaible    cellid=${3}
# #    Evaluate throughput on target cell    gnb_index=${0}
# #    Stop and Save classical enb x2 Logs    x2logname=${x2logname_03}
# #    Check initial A2 measurement config    x2logname=${x2logname_03}
# #    Check measgap setup    x2logname=${x2logname_03}
# #    Check measgap release     x2logname=${x2logname_03}
# #    Analysis wireshark log for case010    x2logname=${x2logname_03}
# #    [Teardown]    Run keywords
# #    ...    Online modify parmeters    parameters_to_update=${PARAMS_TO_MODIFY_710_A10_2_trunk}    AND
# #    ...    Run Keyword And Ignore Error    Tests Recovery    x2logname=${x2logname_03}
# 
# #[1]5GC000710_A_013_Successful_configuration_of_A2_measurement_and_removal_of_A1_A3orA5_measurement
# #    [Documentation]
# #    ...   To verify the successful removal of Inter-frequency A3 and/or A5 and configuration of A2 measurement
# #    ...    from mobility profile selected after receipt of A1 Measurement report.
# #    [Tags]    5GC000710
# #    [Timeout]    1 hour
# #    [Setup]
# #    #RUN KEYWORD IF    '${cell_status}'=='False'    Prepare the gNB cells onair status
# #    should be equal    '${cell_status}'    'True'
# #    Precondition for attn    value1=${${min}}
# #    sleep    10s
# #    Online modify parmeters    parameters_to_update=${PARAMS_TO_MODIFY_710_A13_1_trunk}
# #    Start Capture Classical enb x2 Logs    x2logname=${x2logname_05}
# #    Attach and check power UE    ue_type=${ue_type}    4G_check=${True}
# #    Set nrcellid suit varaible    cellid=${1}
# #    Start DL UL traffic and monitor throughput
# #    sleep    3s
# #    adjust PA to trigger HO    value1=${${triggger_handover}}    value2=${${max}}
# #    sleep    3s
# #    adjust PA to trigger HO    value1=${${min}}    value2=${${max}}
# #    Stop and Save classical enb x2 Logs    x2logname=${x2logname_05}
# #    Evaluate throughput on source cell
# #    Check initial A2 measurement config    x2logname=${x2logname_05}
# #    Check measgap setup    x2logname=${x2logname_05}
# #    Check measgap release     x2logname=${x2logname_05}
# #    Analysis wireshark log for case013    x2logname=${x2logname_05}
# #    wait until keyword succeeds    10 min    20 sec   Check PM the counter Result   counter_id=${counter_MP1}
# #    ...     dic_path=${counter_path}
# #    [Teardown]    Run keywords
# #    ...    Online modify parmeters    parameters_to_update=${PARAMS_TO_MODIFY_710_A13_2_trunk}    AND
# #    ...    Run Keyword And Ignore Error    Tests Recovery    x2logname=${x2logname_05}
# 
# #[1]5GC000710_A_012_online_deletion_of_the_selected_mobility_profile_between_A2_measurement_setup_and_A2_Report
# #    [Documentation]
# #    ...   To verify that when the selected mobility profile is deleted between A2 configuration in the UE and
# #    ...   RRC measurement report for event A2,the default mobility profile is used.
# #    [Tags]    5GC000710
# #    [Timeout]    1 hour
# #    [Setup]
# #    #RUN KEYWORD IF    '${cell_status}'=='False'    Prepare the gNB cells onair status
# #    should be equal    '${cell_status}'    'True'
# #    Run Keyword if    '${release_info}' != 'SBTS21B_ENB_0000'
# #    ...    set cells lock and unlock
# #    ...    ELSE    sleep    1s
# #    Precondition for attn    value1=${${min}}
# #    sleep    10s
# #    Start Capture Classical enb x2 Logs    x2logname=${x2logname_04}
# #    Attach and check power UE    ue_type=${ue_type}    4G_check=${True}
# #    Set nrcellid suit varaible    cellid=${1}
# #    Run Keyword if    '${release_info}' != 'SBTS21B_ENB_0000'
# #    ...    Start DL UL traffic and monitor throughput for peak
# #    ...    ELSE    Start DL UL traffic and monitor throughput
# #    Online delete objects    parameters_to_update=${PARAMS_TO_MODIFY_710_A12_1_trunk}   gnb_index=${0}
# #    Online modify parmeters    parameters_to_update=${PARAMS_TO_MODIFY_710_A12_2_trunk}
# #    adjust PA to trigger HO    value1=${${triggger_handover}}    value2=${${max}}
# #    adjust PA to trigger HO    value1=${${min}}    value2=${${max}}    Att_port_1=${${gnb1_cell3_port_1}}
# #    ...    Att_port_2=${${gnb1_cell3_port_2}}
# #    Set nrcellid suit varaible    cellid=${3}
# #    Run Keyword if    '${release_info}' != 'SBTS21B_ENB_0000'
# #    ...    Evaluate throughput on target cell for peak    gnb_index=${0}
# #    ...    ELSE    Evaluate throughput on target cell   gnb_index=${0}
# #    Stop and Save classical enb x2 Logs    x2logname=${x2logname_04}
# #    Check initial A2 measurement config    x2logname=${x2logname_04}
# #    Check measgap setup    x2logname=${x2logname_04}
# #    Check measgap release     x2logname=${x2logname_04}
# #    Analysis wireshark log for case012    x2logname=${x2logname_04}
# #    [Teardown]    Run Keyword And Ignore Error   Tests Recovery    x2logname=${x2logname_04}
# 
# 
# *** Keywords ***
# Set suite variables
#     ${release_info} =    Get gnb release
#     set suite variable    ${release_info}
#     set suite variable    ${tl_scf_file_name_gnb1_710A}    ${para_store['${release_info}']['tl_scf_file_name_gnb1_710A']}
#     set suite variable    ${tl_scf_file_name_gnb2_710A}    ${para_store['${release_info}']['tl_scf_file_name_gnb2_710A']}
#     set suite variable    ${gnb1_cell1_port_1}    ${para_store['${release_info}']['gnb1_cell1_port_1']}
#     set suite variable    ${gnb1_cell1_port_2}    ${para_store['${release_info}']['gnb1_cell1_port_2']}
#     set suite variable    ${gnb1_cell3_port_1}    ${para_store['${release_info}']['gnb1_cell3_port_1']}
#     set suite variable    ${gnb1_cell3_port_2}    ${para_store['${release_info}']['gnb1_cell3_port_2']}
#     set suite variable    ${gnb2_cell1_port_1}    ${para_store['${release_info}']['gnb2_cell1_port_1']}
#     set suite variable    ${gnb2_cell1_port_2}    ${para_store['${release_info}']['gnb2_cell1_port_2']}
#     set suite variable    ${SPID_VAULUE}    ${para_store['${release_info}']['SPID']}
#     set suite variable    ${triggger_handover}    ${para_store['${release_info}']['triggger_handover']}
# 
# set cells lock and unlock
#     Online modify parmeters    parameters_to_update=${PARAMS_TO_MODIFY_710_A12_1_lock}
#     sleep    60s
#     Online modify parmeters    parameters_to_update=${PARAMS_TO_MODIFY_710_A12_1_unlock}
#     sleep    60s
#     RUN KEYWORD IF    '${cell_status}'=='False'    Prepare the gNB cells onair status
#     should be equal    '${cell_status}'    'True'
# 
# Check the cells status not on air
#     [Arguments]     ${bts_host}    ${connection}
#     ${cell_status}    run keyword and return status    Check the cells status on air
#     ...                   bts_host=${bts_host}    connection=${connection}
#     should be equal    '${cell_status}'    'False'
# 
# Start DL UL traffic and monitor throughput for peak
#     [Arguments]    ${cell_id}=${nrcellid}    ${ue_index}=${0}    ${gnb_index}=${0}
#     power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${dl_throughput_p}    duration=1200s    ue_index=${ue_index}
#     ...     iperf_port=${DL_PORT}    process_num=${1}
#     power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=${ul_throughput_p}    duration=1200s    ue_index=${ue_index}
#     ...     iperf_port=${UL_PORT}
#     Evaluate throughput on source cell    cell_id=${cell_id}    ue_index=${ue_index}
# 
# Evaluate throughput on target cell for peak
#     [Arguments]    ${cell_id}=${nrcellid}     ${ue_index}=${0}    ${gnb_index}=${1}
#     wait until keyword succeeds    2min    30s    power_ue.Check throughput    ue_type=${ue_type}    direction=ul    throughput=${ul_tp_expect_p}
#     ...    ue_index=${ue_index}    gnb_index=${gnb_index}    sample=${6}    start_offset=${3}    sleep_time=${30}    cellid=${cell_id}
#     wait until keyword succeeds    2min    30s    power_ue.Check throughput    ue_type=${ue_type}    direction=dl    throughput=${dl_tp_expect_p}
#     ...    ue_index=${ue_index}    gnb_index=${gnb_index}     sample=${6}    start_offset=${3}    sleep_time=${30}    cellid=${cell_id}
# 
# Precondition for attn
#     [Arguments]    ${value1}    ${value2}=${127}
#     Run Keyword if    '${release_info}' == 'SBTS21B_ENB_0000'   Precondition for attn 21B    value1=${value1}    value2=${value2}
#     ...    ELSE     Precondition for attn Trunk    value1=${value1}    value2=${value2}
# 
# Precondition for attn Trunk
#     [Arguments]    ${value1}    ${value2}=${127}
#     Adjust the PA attenuation value    value_1=${value1}     value_2=${value1}    value_3=${value1}     value_4=${value1}
#     ...     att_port_1=${att_port_1}      att_port_2=${att_port_2}    att_port_3=${att_port_7}
#     ...     att_port_4=${att_port_8}    atten_ip=${atten_ip}
#     Adjust the PA attenuation value    value_1=${value2}     value_2=${value2}    value_3=${value2}     value_4=${value2}
#     ...     att_port_1=${att_port_3}      att_port_2=${att_port_4}    att_port_3=${att_port_5}
#     ...     att_port_4=${att_port_6}    atten_ip=${atten_ip}
#     Adjust the PA attenuation value    value_1=${value2}     value_2=${value2}    value_3=${value2}     value_4=${value2}
#     ...     att_port_1=${att_port_9}      att_port_2=${att_port_10}
# 
# Precondition for attn 21B
#     [Arguments]    ${value1}    ${value2}=${127}
#     Adjust the PA attenuation value    value_1=${value1}     value_2=${value1}    value_3=${value1}     value_4=${value1}
#     ...     att_port_1=${att_port_9}      att_port_2=${att_port_10}    att_port_3=${att_port_15}
#     ...     att_port_4=${att_port_16}    atten_ip=${atten_ip}
#     Adjust the PA attenuation value    value_1=${value2}     value_2=${value2}    value_3=${value2}     value_4=${value2}
#     ...     att_port_1=${att_port_3}      att_port_2=${att_port_4}    att_port_3=${att_port_5}
#     ...     att_port_4=${att_port_6}    atten_ip=${atten_ip}
#     Adjust the PA attenuation value    value_1=${value2}     value_2=${value2}    value_3=${value2}     value_4=${value2}
#     ...     att_port_1=${att_port_7}      att_port_2=${att_port_8}    att_port_3=${att_port_11}
#     ...     att_port_4=${att_port_12}    atten_ip=${atten_ip}
#     Adjust the PA attenuation value    value_1=${value2}     value_2=${value2}    value_3=${value2}     value_4=${value2}
#     ...     att_port_1=${att_port_13}      att_port_2=${att_port_14}    att_port_3=${att_port_1}
#     ...     att_port_4=${att_port_2}    atten_ip=${atten_ip}
# 
# Analysis wireshark log for case015
#     [Arguments]    ${x2logname}
#     ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${x2logname}    tshark_path=${tshark_path}
#     ...                command_template=${command_template_H}
#     ${SPID_Fliter} =    Catenate    x2ap.SubscriberProfileIDforRFP == ${SPID_VAULUE} and x2ap.procedureCode == 27 and x2ap.X2AP_PDU == 0
#     ${SPID_event} =    parser.filter_packets_by_expression    filter_expression=${SPID_Fliter}
#     ${SPID} =    parser.get_field_value_by_xpath    pdml_list=${SPID_event}    xpath=.//x2ap.SubscriberProfileIDforRFP
#     should be equal    ${SPID[0]}    ${SPID_VAULUE}
#     should be equal    ${SPID[1]}    ${SPID_VAULUE}
#     ${A1andA5_Fliter} =    Catenate     x2ap.X2AP_PDU == 0 and x2ap.procedureCode == 34
#     ${A1A5} =    parser.filter_packets_by_expression    filter_expression=${A1andA5_Fliter}
#     ${freq} =    parser.get_field_value_by_xpath    pdml_list=${A1A5}    xpath=.//nr-rrc.ssbFrequency
#     should be equal    ${freq[1]}    126270
#     ${A1ENVET} =    parser.get_field_value_by_xpath    pdml_list=${A1A5}    xpath=.//nr-rrc.eventId
#     should be equal    ${A1ENVET[0]}    0
#     should be equal    ${A1ENVET[1]}    4
#     ${a1_Threshold} =    parser.get_field_value_by_xpath    pdml_list=${A1A5}    xpath=.//nr-rrc.a1_Threshold
#     should be equal    ${a1_Threshold[0]}    0
#     ${a5_Threshold1} =    parser.get_field_value_by_xpath    pdml_list=${A1A5}    xpath=.//nr-rrc.a5_Threshold1
#     should be equal    ${a5_Threshold1[0]}    0
#     ${a5_Threshold2} =    parser.get_field_value_by_xpath    pdml_list=${A1A5}    xpath=.//nr-rrc.a5_Threshold2
#     should be equal    ${a5_Threshold2[0]}    0
#     ${rsrp} =    parser.get_field_value_by_xpath    pdml_list=${A1A5}    xpath=.//nr-rrc.measTriggerQuantity.rsrp
#     should be equal    ${rsrp[0]}    100
#     should be equal    ${rsrp[1]}    77
#     should be equal    ${rsrp[2]}    65
#     ${A5_MR_Fliter} =    Catenate     x2ap.X2AP_PDU == 0 and x2ap.procedureCode == 35 and nr-rrc.measId == 3
#     ${A5_MR} =    parser.filter_packets_by_expression    filter_expression=${A5_MR_Fliter}
#     ${A5_MEASREPORT} =    parser.get_field_value_by_xpath    pdml_list=${A5_MR}    xpath=.//nr-rrc.measId
#     should be equal    ${A5_MEASREPORT[0]}    3
#     ${Ho_Fliter} =    Catenate     x2ap.procedureCode == 34 and x2ap.X2AP_PDU == 0
#     ${Ho_req} =    parser.filter_packets_by_expression    filter_expression=${Ho_Fliter}
#     ${Ho_req_value} =    parser.get_field_value_by_xpath    pdml_list=${Ho_req}    xpath=.//x2ap.procedureCode
#     should be equal    ${Ho_req_value[0]}    34
#     ${HC_Fliter} =    Catenate     x2ap.procedureCode == 34 and x2ap.X2AP_PDU == 1
#     ${HC_req} =    parser.filter_packets_by_expression    filter_expression=${Ho_Fliter}
#     ${HC_req_value} =    parser.get_field_value_by_xpath    pdml_list=${HC_req}    xpath=.//x2ap.procedureCode
#     should be equal    ${HC_req_value[0]}    34
#     ${A2_Target_Fliter} =    Catenate     x2ap.procedureCode == 27 and x2ap.X2AP_PDU == 1 and ip.src == ${PEER_MASTER_IP}
#     ${A2_Target} =    parser.filter_packets_by_expression    filter_expression=${A2_Target_Fliter}
#     ${A2_Target_value} =    parser.get_field_value_by_xpath    pdml_list=${A2_Target}    xpath=.//nr-rrc.eventId
#     should be empty    ${A2_Target_value}
#     ${SgNBRelease_Required_Fliter} =  Catenate    x2ap.X2AP_PDU == 0 and x2ap.procedureCode == 32
#     ${SgNBRelease_Required} =    parser.filter_packets_by_expression
#     ...    filter_expression=${SgNBRelease_Required_Fliter}
#     ${SgNBRelease_Required_value} =    parser.get_field_value_by_xpath    pdml_list=${SgNBRelease_Required}
#     ...    xpath=.//x2ap.procedureCode
#     should be empty     ${SgNBRelease_Required_value}
#     ${UEContext_Release_fliter} =  Catenate    x2ap.X2AP_PDU == 0 and x2ap.procedureCode == 5 and ip.dst == ${PEER_MASTER_IP}
#     ${UEContext_Release} =    parser.filter_packets_by_expression
#     ...    filter_expression=${UEContext_Release_fliter}
#     ${UEContext_Release_Value} =    parser.get_field_value_by_xpath    pdml_list=${UEContext_Release}
#     ...    xpath=.//x2ap.procedureCode
#     should be empty    ${UEContext_Release_Value}
# 
# 
# Analysis wireshark log for case016
#     [Arguments]    ${x2logname}
#     ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${x2logname}    tshark_path=${tshark_path}
#     ...                command_template=${command_template_H}
#     ${SPID_Fliter} =    Catenate    x2ap.SubscriberProfileIDforRFP == ${SPID_VAULUE} and x2ap.procedureCode == 27 and x2ap.X2AP_PDU == 0
#     ${SPID_event} =    parser.filter_packets_by_expression    filter_expression=${SPID_Fliter}
#     ${SPID} =    parser.get_field_value_by_xpath    pdml_list=${SPID_event}    xpath=.//x2ap.SubscriberProfileIDforRFP
#     should be equal    ${SPID[0]}    ${SPID_VAULUE}
#     ${A1andA5_Fliter} =    Catenate     x2ap.X2AP_PDU == 1 and x2ap.procedureCode == 29
#     ${A1A5} =    parser.filter_packets_by_expression    filter_expression=${A1andA5_Fliter}
#     ${freq} =    parser.get_field_value_by_xpath    pdml_list=${A1A5}    xpath=.//nr-rrc.ssbFrequency
#     should contain    ${freq}    126270
#     should contain    ${freq}    518910
#     ${A1ENVET} =    parser.get_field_value_by_xpath    pdml_list=${A1A5}    xpath=.//nr-rrc.eventId
#     should be equal    ${A1ENVET[0]}    0
#     should be equal    ${A1ENVET[1]}    4
#     should be equal    ${A1ENVET[2]}    2
#     ${a1_Threshold} =    parser.get_field_value_by_xpath    pdml_list=${A1A5}    xpath=.//nr-rrc.a1_Threshold
#     should be equal    ${a1_Threshold[0]}    1
#     ${a5_Threshold1} =    parser.get_field_value_by_xpath    pdml_list=${A1A5}    xpath=.//nr-rrc.a5_Threshold1
#     should be equal    ${a5_Threshold1[0]}    0
#     ${a5_Threshold2} =    parser.get_field_value_by_xpath    pdml_list=${A1A5}    xpath=.//nr-rrc.a5_Threshold2
#     should be equal    ${a5_Threshold2[0]}    0
#     ${a3_Threshold} =    parser.get_field_value_by_xpath    pdml_list=${A1A5}    xpath=.//nr-rrc.a3_Offset
#     should be equal    ${a3_Threshold[0]}    0
#     ${rsrq} =    parser.get_field_value_by_xpath    pdml_list=${A1A5}    xpath=.//nr-rrc.rsrq
#     should be equal    ${rsrq[0]}    85
#     ${rsrp} =    parser.get_field_value_by_xpath    pdml_list=${A1A5}    xpath=.//nr-rrc.rsrp
#     should be equal    ${rsrp[2]}    77
#     should be equal    ${rsrp[3]}    65
#     should be equal    ${rsrp[6]}    2
#     ${timetotigger} =    parser.get_field_value_by_xpath    pdml_list=${A1A5}    xpath=.//nr-rrc.timeToTrigger
#     should be equal    ${timetotigger[0]}    7
#     should be equal    ${timetotigger[1]}    5
#     should be equal    ${timetotigger[2]}    8
#     ${measuredFrequency} =    parser.get_field_value_by_xpath    pdml_list=${A1A5}    xpath=.//nr-rrc.measuredFrequency
#     should be equal    ${measuredFrequency[0]}    124330
#     should be equal    ${measuredFrequency[1]}    126270
#     should be equal    ${measuredFrequency[2]}    518910
#     ${A3_MR_Fliter} =    Catenate     x2ap.X2AP_PDU == 0 and x2ap.procedureCode == 35 and nr-rrc.measId == 4
#     ${A3_MR} =    parser.filter_packets_by_expression    filter_expression=${A3_MR_Fliter}
#     ${A3_MEASREPORT} =    parser.get_field_value_by_xpath    pdml_list=${A3_MR}    xpath=.//nr-rrc.measId
#     should be equal    ${A3_MEASREPORT[0]}    4
#     ${A2_Target_Fliter} =    Catenate     x2ap.procedureCode == 30 and x2ap.X2AP_PDU == 0
#     ${A2_Target} =    parser.filter_packets_by_expression    filter_expression=${A2_Target_Fliter}
#     ${A2_Target_value} =    parser.get_field_value_by_xpath    pdml_list=${A2_Target}    xpath=.//nr-rrc.eventId
#     should be equal    ${A2_Target_value[0]}    1
#     ${A2_Target_rsrp} =    parser.get_field_value_by_xpath    pdml_list=${A2_Target}    xpath=.//nr-rrc.rsrp
#     should be equal    ${A2_Target_rsrp[0]}    70
#     ${timetotigger} =    parser.get_field_value_by_xpath    pdml_list=${A2_Target}    xpath=.//nr-rrc.timeToTrigger
#     should be equal    ${timetotigger[0]}    10
#     ${SgNBRelease_Required_Fliter} =  Catenate    x2ap.X2AP_PDU == 0 and x2ap.procedureCode == 32
#     ${SgNBRelease_Required} =    parser.filter_packets_by_expression
#     ...    filter_expression=${SgNBRelease_Required_Fliter}
#     ${SgNBRelease_Required_value} =    parser.get_field_value_by_xpath    pdml_list=${SgNBRelease_Required}
#     ...    xpath=.//x2ap.procedureCode
#     should be empty     ${SgNBRelease_Required_value}
#     ${UEContext_Release_fliter} =  Catenate    x2ap.X2AP_PDU == 0 and x2ap.procedureCode == 5
#     ${UEContext_Release} =    parser.filter_packets_by_expression
#     ...     filter_expression=${UEContext_Release_fliter}
#     ${UEContext_Release_Value} =    parser.get_field_value_by_xpath    pdml_list=${UEContext_Release}
#     ...     xpath=.//x2ap.procedureCode
#     should be empty    ${UEContext_Release_Value}
# 
# Analysis wireshark log for case010
#     [Arguments]    ${x2logname}
#     ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${x2logname}    tshark_path=${tshark_path}
#     ...                command_template=${command_template_H}
#     ${A1andA5_Fliter} =    Catenate     x2ap.X2AP_PDU == 1 and x2ap.procedureCode == 29
#     ${A1A5} =    parser.filter_packets_by_expression    filter_expression=${A1andA5_Fliter}
#     ${freq} =    parser.get_field_value_by_xpath    pdml_list=${A1A5}    xpath=.//nr-rrc.ssbFrequency
#     should be equal    ${freq[0]}    518910
#     ${A1ENVET} =    parser.get_field_value_by_xpath    pdml_list=${A1A5}    xpath=.//nr-rrc.eventId
#     should be equal    ${A1ENVET[0]}    0
#     should be equal    ${A1ENVET[1]}    2
#     ${a1_Threshold} =    parser.get_field_value_by_xpath    pdml_list=${A1A5}    xpath=.//nr-rrc.a1_Threshold
#     should be equal    ${a1_Threshold[0]}    0
#     ${a3_Threshold} =    parser.get_field_value_by_xpath    pdml_list=${A1A5}    xpath=.//nr-rrc.a3_Offset
#     should be equal    ${a3_Threshold[0]}    0
#     ${rsrp} =    parser.get_field_value_by_xpath    pdml_list=${A1A5}    xpath=.//nr-rrc.rsrp
#     should be equal    ${rsrp[0]}    100
#     should be equal    ${rsrp[3]}    2
#     ${timetotigger} =    parser.get_field_value_by_xpath    pdml_list=${A1A5}    xpath=.//nr-rrc.timeToTrigger
#     should be equal    ${timetotigger[0]}    9
#     should be equal    ${timetotigger[1]}    8
#     ${measuredFrequency} =    parser.get_field_value_by_xpath    pdml_list=${A1A5}    xpath=.//nr-rrc.measuredFrequency
#     should be equal    ${measuredFrequency[0]}    124330
#     should be equal    ${measuredFrequency[1]}    518910
#     ${A3_MR_Fliter} =    Catenate     x2ap.X2AP_PDU == 0 and x2ap.procedureCode == 35 and nr-rrc.measId == 3
#     ${A3_MR} =    parser.filter_packets_by_expression    filter_expression=${A3_MR_Fliter}
#     ${A3_MEASREPORT} =    parser.get_field_value_by_xpath    pdml_list=${A3_MR}    xpath=.//nr-rrc.measId
#     should be equal    ${A3_MEASREPORT[0]}    3
#     ${A2_Target_Fliter} =    Catenate     x2ap.procedureCode == 30 and x2ap.X2AP_PDU == 0
#     ${A2_Target} =    parser.filter_packets_by_expression    filter_expression=${A2_Target_Fliter}
#     ${A2_Target_value} =    parser.get_field_value_by_xpath    pdml_list=${A2_Target}    xpath=.//nr-rrc.eventId
#     should be empty    ${A2_Target_value}
#     ${SgNBRelease_Required_Fliter} =  Catenate    x2ap.X2AP_PDU == 0 and x2ap.procedureCode == 32
#     ${SgNBRelease_Required} =    parser.filter_packets_by_expression
#     ...    filter_expression=${SgNBRelease_Required_Fliter}
#     ${SgNBRelease_Required_value} =    parser.get_field_value_by_xpath    pdml_list=${SgNBRelease_Required}
#     ...    xpath=.//x2ap.procedureCode
#     should be empty     ${SgNBRelease_Required_value}
#     ${UEContext_Release_fliter} =  Catenate    x2ap.X2AP_PDU == 0 and x2ap.procedureCode == 5
#     ${UEContext_Release} =    parser.filter_packets_by_expression
#     ...    filter_expression=${UEContext_Release_fliter}
#     ${UEContext_Release_Value} =    parser.get_field_value_by_xpath    pdml_list=${UEContext_Release}
#     ...    xpath=.//x2ap.procedureCode
#     should be empty    ${UEContext_Release_Value}
# 
# Check measgap setup
#     [Arguments]    ${x2logname}
#     ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${x2logname}    tshark_path=${tshark_path}
#     ...                command_template=${command_template_H}
#     ${measgap_Fliter} =    Catenate     x2ap.X2AP_PDU == 0 and x2ap.procedureCode == 29
#     ${measgap} =    parser.filter_packets_by_expression    filter_expression=${measgap_Fliter}
#     ${MG} =    parser.get_field_value_by_xpath    pdml_list=${measgap}    xpath=.//nr-rrc.measGapConfig
#     should be equal    ${MG[0]}    1
#     ${MG_gapoffset} =    parser.get_field_value_by_xpath    pdml_list=${measgap}    xpath=.//nr-rrc.gapOffset
#     should be equal    ${MG_gapoffset[0]}    19
#     ${MG_mgl} =    parser.get_field_value_by_xpath    pdml_list=${measgap}    xpath=.//nr-rrc.mgl
#     should be equal    ${MG_mgl[0]}    5
#     ${MG_mgrp} =    parser.get_field_value_by_xpath    pdml_list=${measgap}    xpath=.//nr-rrc.mgrp
#     should be equal    ${MG_mgrp[0]}    1
#     ${MG_mgta} =    parser.get_field_value_by_xpath    pdml_list=${measgap}    xpath=.//nr-rrc.mgta
#     should be equal    ${MG_mgta[0]}    0
# 
# Check initial A2 measurement config
#     [Arguments]    ${x2logname}
#     ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${x2logname}    tshark_path=${tshark_path}
#     ...                command_template=${command_template_H}
#     ${int_measconfig_Fliter} =    Catenate    x2ap.X2AP_PDU == 1 and x2ap.procedureCode == 27
#     ${A2_event} =    parser.filter_packets_by_expression    filter_expression=${int_measconfig_Fliter}
#     ${A2} =    parser.get_field_value_by_xpath    pdml_list=${A2_event}    xpath=.//nr-rrc.eventId
#     should be equal    ${A2[0]}    1
#     ${A2_mode} =    parser.get_field_value_by_xpath    pdml_list=${A2_event}    xpath=.//nr-rrc.a2_Threshold
#     should be equal    ${A2_mode[0]}    0
#     ${A2_rsrp} =    parser.get_field_value_by_xpath    pdml_list=${A2_event}    xpath=.//nr-rrc.measTriggerQuantity.rsrp
#     should be equal    ${A2_rsrp[0]}    77
#     ${A2_hysteresis} =    parser.get_field_value_by_xpath    pdml_list=${A2_event}    xpath=.//nr-rrc.hysteresis
#     should be equal    ${A2_hysteresis[0]}    0
#      ${A2_timeToTrigger} =    parser.get_field_value_by_xpath    pdml_list=${A2_event}    xpath=.//nr-rrc.timeToTrigger
#     should be equal    ${A2_timeToTrigger[0]}    9
#     ${A2_MR_Fliter} =    Catenate     x2ap.X2AP_PDU == 0 and x2ap.procedureCode == 35 and nr-rrc.measId == 1
#     ${A2_MR} =    parser.filter_packets_by_expression    filter_expression=${A2_MR_Fliter}
#     ${A2_MEASREPORT} =    parser.get_field_value_by_xpath    pdml_list=${A2_MR}    xpath=.//nr-rrc.measId
#     should be equal    ${A2_MEASREPORT[0]}    1
# 
# Check measgap release
#     [Arguments]    ${x2logname}
#     ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${x2logname}    tshark_path=${tshark_path}
#     ...                command_template=${command_template_H}
#     ${measgap_Fliter} =    Catenate     x2ap.X2AP_PDU == 0 and x2ap.procedureCode == 29 and nr-rrc.measGapConfig == 0
#     ${measgap} =    parser.filter_packets_by_expression    filter_expression=${measgap_Fliter}
#     ${MG} =    parser.get_field_value_by_xpath    pdml_list=${measgap}    xpath=.//nr-rrc.measGapConfig
#     should be equal    ${MG[0]}    0
# 
# 
# Analysis wireshark log for case013
#     [Arguments]    ${x2logname}
#     ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${x2logname}    tshark_path=${tshark_path}
#     ...                command_template=${command_template_H}
#     ${A1andA5_Fliter} =    Catenate     x2ap.X2AP_PDU == 1 and x2ap.procedureCode == 29
#     ${A1A5} =    parser.filter_packets_by_expression    filter_expression=${A1andA5_Fliter}
#     ${freq} =    parser.get_field_value_by_xpath    pdml_list=${A1A5}    xpath=.//nr-rrc.ssbFrequency
#     should be equal    ${freq[0]}    518910
#     ${A1ENVET} =    parser.get_field_value_by_xpath    pdml_list=${A1A5}    xpath=.//nr-rrc.eventId
#     should be equal    ${A1ENVET[0]}    0
#     should be equal    ${A1ENVET[1]}    0
#     should be equal    ${A1ENVET[2]}    2
#     ${a1_Threshold} =    parser.get_field_value_by_xpath    pdml_list=${A1A5}    xpath=.//nr-rrc.a1_Threshold
#     should be equal    ${a1_Threshold[0]}    0
#     should be equal    ${a1_Threshold[1]}    1
#     ${a3_Threshold} =    parser.get_field_value_by_xpath    pdml_list=${A1A5}    xpath=.//nr-rrc.a3_Offset
#     should be equal    ${a3_Threshold[0]}    0
#     ${rsrp} =    parser.get_field_value_by_xpath    pdml_list=${A1A5}    xpath=.//nr-rrc.rsrp
#     should be equal    ${rsrp[0]}    80
#     should be equal    ${rsrp[5]}    2
#     ${rsrq} =    parser.get_field_value_by_xpath    pdml_list=${A1A5}    xpath=.//nr-rrc.rsrq
#     should be equal    ${rsrq[2]}    85
#     ${timetotigger} =    parser.get_field_value_by_xpath    pdml_list=${A1A5}    xpath=.//nr-rrc.timeToTrigger
#     should be equal    ${timetotigger[0]}    9
#     should be equal    ${timetotigger[1]}    7
#     should be equal    ${timetotigger[2]}    8
#     ${measuredFrequency} =    parser.get_field_value_by_xpath    pdml_list=${A1A5}    xpath=.//nr-rrc.measuredFrequency
#     should be equal    ${measuredFrequency[0]}    124330
#     should be equal    ${measuredFrequency[1]}    518910
#     ${A1_MR_Fliter} =    Catenate     x2ap.X2AP_PDU == 0 and x2ap.procedureCode == 35 and nr-rrc.measId == 2
#     ${A1_MR} =    parser.filter_packets_by_expression    filter_expression=${A1_MR_Fliter}
#     ${A1_MEASREPORT} =    parser.get_field_value_by_xpath    pdml_list=${A1_MR}    xpath=.//nr-rrc.measId
#     should be equal    ${A1_MEASREPORT[0]}    2
#     ${A2_Target_Fliter} =    Catenate     x2ap.procedureCode == 29 and x2ap.X2AP_PDU == 1
#     ${A2_Target} =    parser.filter_packets_by_expression    filter_expression=${A2_Target_Fliter}
#     ${A2_Target_value} =    parser.get_field_value_by_xpath    pdml_list=${A2_Target}    xpath=.//nr-rrc.eventId
#     should be equal    ${A2_Target_value[3]}     1
#     ${RM_ITEM_value} =    parser.get_field_value_by_xpath    pdml_list=${A2_Target}    xpath=.//nr-rrc.measIdToRemoveList
#     should be equal    ${RM_ITEM_value[1]}     3
#     ${SgNBRelease_Required_Fliter} =  Catenate    x2ap.X2AP_PDU == 0 and x2ap.procedureCode == 32
#     ${SgNBRelease_Required} =    parser.filter_packets_by_expression
#     ...     filter_expression=${SgNBRelease_Required_Fliter}
#     ${SgNBRelease_Required_value} =    parser.get_field_value_by_xpath    pdml_list=${SgNBRelease_Required}
#     ...    xpath=.//x2ap.procedureCode
#     should be empty     ${SgNBRelease_Required_value}
#     ${UEContext_Release_fliter} =  Catenate    x2ap.X2AP_PDU == 0 and x2ap.procedureCode == 5
#     ${UEContext_Release} =    parser.filter_packets_by_expression
#     ...     filter_expression=${UEContext_Release_fliter}
#     ${UEContext_Release_Value} =    parser.get_field_value_by_xpath    pdml_list=${UEContext_Release}
#     ...    xpath=.//x2ap.procedureCode
#     should be empty    ${UEContext_Release_Value}
# 
# Analysis wireshark log for case012
#     [Arguments]    ${x2logname}
#     ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${x2logname}    tshark_path=${tshark_path}
#     ...                command_template=${command_template_H}
#     ${A1andA5_Fliter} =    Catenate     x2ap.X2AP_PDU == 1 and x2ap.procedureCode == 29
#     ${A1A5} =    parser.filter_packets_by_expression    filter_expression=${A1andA5_Fliter}
#     ${freq} =    parser.get_field_value_by_xpath    pdml_list=${A1A5}    xpath=.//nr-rrc.ssbFrequency
#     should be equal    ${freq[0]}    518910
#     ${A1ENVET} =    parser.get_field_value_by_xpath    pdml_list=${A1A5}    xpath=.//nr-rrc.eventId
#     should be equal    ${A1ENVET[0]}    0
#     should be equal    ${A1ENVET[1]}    0
#     should be equal    ${A1ENVET[2]}    2
#     ${a1_Threshold} =    parser.get_field_value_by_xpath    pdml_list=${A1A5}    xpath=.//nr-rrc.a1_Threshold
#     should be equal    ${a1_Threshold[0]}    0
#     should be equal    ${a1_Threshold[1]}    1
#     ${a3_Threshold} =    parser.get_field_value_by_xpath    pdml_list=${A1A5}    xpath=.//nr-rrc.a3_Offset
#     should be equal    ${a3_Threshold[0]}    0
#     ${rsrp} =    parser.get_field_value_by_xpath    pdml_list=${A1A5}    xpath=.//nr-rrc.rsrp
#     should be equal    ${rsrp[0]}    100
#     should be equal    ${rsrp[5]}    2
#     ${rsrq} =    parser.get_field_value_by_xpath    pdml_list=${A1A5}    xpath=.//nr-rrc.rsrq
#     should be equal    ${rsrq[2]}    85
#     ${timetotigger} =    parser.get_field_value_by_xpath    pdml_list=${A1A5}    xpath=.//nr-rrc.timeToTrigger
#     should be equal    ${timetotigger[0]}    9
#     should be equal    ${timetotigger[1]}    7
#     should be equal    ${timetotigger[2]}    8
#     ${measuredFrequency} =    parser.get_field_value_by_xpath    pdml_list=${A1A5}    xpath=.//nr-rrc.measuredFrequency
#     should be equal    ${measuredFrequency[0]}    124330
#     should be equal    ${measuredFrequency[1]}    518910
#     ${A3_MR_Fliter} =    Catenate     x2ap.X2AP_PDU == 0 and x2ap.procedureCode == 35 and nr-rrc.measId == 4
#     ${A3_MR} =    parser.filter_packets_by_expression    filter_expression=${A3_MR_Fliter}
#     ${A3_MEASREPORT} =    parser.get_field_value_by_xpath    pdml_list=${A3_MR}    xpath=.//nr-rrc.measId
#     should be equal    ${A3_MEASREPORT[0]}    4
#     ${A2_Target_Fliter} =    Catenate     x2ap.procedureCode == 30 and x2ap.X2AP_PDU == 0 and nr-rrc.measIdToRemoveList == 3
#     ${A2_Target} =    parser.filter_packets_by_expression    filter_expression=${A2_Target_Fliter}
#     ${A2_Target_value} =    parser.get_field_value_by_xpath    pdml_list=${A2_Target}    xpath=.//nr-rrc.eventId
#     should be empty    ${A2_Target_value}
#     ${RM_ITEM_value} =    parser.get_field_value_by_xpath    pdml_list=${A2_Target}    xpath=.//nr-rrc.measIdToRemoveList
#     should be equal    ${RM_ITEM_value[0]}     3
#     ${SgNBRelease_Required_Fliter} =  Catenate    x2ap.X2AP_PDU == 0 and x2ap.procedureCode == 32
#     ${SgNBRelease_Required} =    parser.filter_packets_by_expression
#     ...     filter_expression=${SgNBRelease_Required_Fliter}
#     ${SgNBRelease_Required_value} =    parser.get_field_value_by_xpath    pdml_list=${SgNBRelease_Required}
#     ...    xpath=.//x2ap.procedureCode
#     should be empty     ${SgNBRelease_Required_value}
#     ${UEContext_Release_fliter} =  Catenate    x2ap.X2AP_PDU == 0 and x2ap.procedureCode == 5
#     ${UEContext_Release} =    parser.filter_packets_by_expression
#     ...     filter_expression=${UEContext_Release_fliter}
#     ${UEContext_Release_Value} =    parser.get_field_value_by_xpath    pdml_list=${UEContext_Release}
#     ...    xpath=.//x2ap.procedureCode
#     should be empty    ${UEContext_Release_Value}
