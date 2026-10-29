# *** Settings ***
# Documentation     author: Wang Yishuang && Xing Jing
# ...                 contact: yishuang.wang@nokia-sbell.com && jing.1.xing@nokia-sbell.com
# ...                 squad group: SG_03
# ...                 feature : 5GC000710
# 
# Force Tags    CA_5G_RRM
# ...    PY36
# Resource    ../Resources/5GC000710_common_keyword.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# 
# Suite Setup    Run Keywords    robot_common_operations.Common Suite Setup    AND
# ...                            Common Suite Setup for COAM    AND
# ...                            Set suite variables    AND
# ...                            Precondition for cell on air    gnb_index=${0}    tl_scf_file_name=${tl_scf_file_name_gnb1}    AND
# ...                            Precondition for cell on air    gnb_index=${1}    tl_scf_file_name=${tl_scf_file_name_gnb2}    AND
# ...                            Precondition for power UE    ue_type=${ue_type}
# 
# Suite Teardown    Run keywords    robot_common_operations.Common Suite Teardown    AND
# ...               Run Keyword If Any Tests Failed
# ...               Run Keyword And Ignore Error    Common Suite Teardown for COAM    gnb_index=${0}   AND
# ...               Run Keyword And Ignore Error    Delete all NRADJGNB object
# 
# *** Variables ***
# ${gNB1_logname_C16}          gNB1_710C16.pcap
# ${gNB2_logname_C16}          gNB2_710C16.pcap
# ${gNB1_logname_C20}          gNB1_710C20.pcap
# ${gNB2_logname_C20}          gNB2_710C20.pcap
# ${gNB1_logname_C20_1}          gNB1_710C20_1.pcap
# ${gNB2_logname_C20_1}          gNB2_710C20_1.pcap
# ${gNB1_logname_C21}          gNB1_710C21.pcap
# ${gNB2_logname_C21}          gNB2_710C21.pcap
# ${gNB1_logname_C14}          gNB1_710C14.pcap
# ${gNB1_logname_C13}          gNB1_710C13.pcap
# ${eNB_logname_C13}          eNB_710C13.pcap
# ${dlexpect_tput}            15
# ${ulexpect_tput}            8
# ${profile_counter_path}    BTS/CELLS/NRCELL-1/NRMOP
# 
# *** Test Cases ***
# #[1]5GC000710_C_020_Successful_configuration_of_A2_for_redirection_with_selected_profile_in_target_gNB_after_Intra-F_Inter-gNB_HO
# #    [Documentation]    This user scenario To verifies successful A2 measurement for redirection that
# #    ...    all related redirection parameters provided in target gnb NRcell configuration, after_Successful_Intra-frequency_Inter-gNB_handover
# #    [Tags]    5GC000710
# #    [Setup]
# #    Precondition for attn    value1=${${source_value}}
# #    Online modify parmeters    parameters_to_update=${PARAMS_TO_MODIFY_710_C20_1}    gnb_index=${1}
# #	#gNB1_Cell1(PA port 9,10) Handover to gNB2_Cell1(PA port1,2)
# #    Trigger IntraFreq IntergNB Handover    logname1=${gNB1_logname_C20}    logname2=${gNB2_logname_C20}
# #	#
# #    Trigger Redirection to 5G    logname1=${gNB2_logname_C20_1}    logname2=${gNB1_logname_C20_1}
# #    Wait until keyword succeeds    5min    30s
# #    ...    Check PM counter Result    counter_id=M55157C00063    dic_path=${profile_counter_path}    gnb_index=${0}   counter_end=${counter_end}
# #    Wait until keyword succeeds    5min    30s
# #    ...    Check PM counter Result    counter_id=M55157C00035    dic_path=${profile_counter_path}    gnb_index=${1}   counter_end=${counter_end}
# #    Check intergNB HO process on source gNB with RFSP on    log_name=${gNB1_logname_C20}
# #    Check intergNB HO process on target gNB    log_name=${gNB2_logname_C20}
# #    Check A2 configuration on source gNB    log_name=${gNB1_logname_C20}
# #    Check A2 rsrp configuration on target gNB    log_name=${gNB2_logname_C20}
# #    Check A2 redirection to 5G successfully    log_name1=${gNB2_logname_C20_1}    log_name2=${gNB1_logname_C20_1}
# #    [Teardown]    run keywords
# #    ...           run keyword and ignore error    Test recover    AND
# #    ...           run keyword and ignore error    Online modify parmeters    parameters_to_update=${PARAMS_TO_MODIFY_710_C20_2}    gnb_index=${1}
# 
# [1]5GC000710_C_021_Successful_configuration_of_A2_for_redirection_with_default_profile_in_target_gNB_after_Intra-F_Inter-gNB_HO
#     [Documentation]    This user scenario To verifies successful A2 measurement for redirection that
#     ...    all related redirection parameters provided in target gnb NRcell configuration, after_Successful_Intra-frequency_Inter-gNB_handover
#     [Tags]    CIT_TRUNK    CDRT_22R1    CRT_22R1    CRT_22R2    5GC000710    CRT_22R3    CIT_22R4    CIT_23R1
#     [Setup]
#     robot_common_operations.Common Case Setup
#     Precondition for attn    value1=${${source_value}}
#     Online modify parmeters    parameters_to_update=${${PARAMS_CASEC21_1}}    gnb_index=${0}
#     Online modify parmeters    parameters_to_update=${${PARAMS_CASEC21_2}}    gnb_index=${1}
#     Trigger IntraFreq IntergNB Handover    logname1=${gNB1_logname_C21}    logname2=${gNB2_logname_C21}
#     Wait until keyword succeeds    5min    30s
#     ...    Check PM counter Result    counter_id=M55157C00036    dic_path=${profile_counter_path}    gnb_index=${1}    counter_end=${counter_end}
#     Check intergNB HO process on source gNB with RFSP on    log_name=${gNB1_logname_C21}
#     Check intergNB HO process on target gNB    log_name=${gNB2_logname_C21}
#     Check no A2 configuration on source gNB    log_name=${gNB1_logname_C21}
#     Check A2 rsrq configuration on target gNB    log_name=${gNB2_logname_C21}
#     [Teardown]    run keywords
#     ...           robot_common_operations.Common Case Teardown    AND
#     ...           run keyword and ignore error    Test recover    AND
#     ...           run keyword and ignore error    Online modify parmeters    parameters_to_update=${${PARAMS_CASEC21_3}}    gnb_index=${0}    AND
#     ...           run keyword and ignore error    Online modify parmeters    parameters_to_update=${${PARAMS_CASEC21_4}}    gnb_index=${1}
# 
# #[1]5GC000710_C_016_NRCELL_configuration_for_redirection_with_selected_profile_in_target_gNB_after_Intra-F_Inter-gNB_HO
# #    [Documentation]    This user scenario To verifies successful A2 measurement for redirection that
# #    ...    all related redirection parameters provided in target gnb NRcell configuration, after_Successful_Intra-frequency_Inter-gNB_handover
# #    [Tags]        5GC000710
# #    [Setup]
# #    Precondition for attn    value1=${${source_value}}
# #    Online modify parmeters    parameters_to_update=${PARAMS_TO_MODIFY_710_C16_1}    gnb_index=${0}
# #    Online modify parmeters    parameters_to_update=${PARAMS_TO_MODIFY_710_C16_2}    gnb_index=${1}
# #    Online delete parmeters    parameters_to_update=${PARAMS_TO_MODIFY_710_C16_3}    gnb_index=${1}
# #    Trigger IntraFreq IntergNB Handover    logname1=${gNB1_logname_C16}    logname2=${gNB2_logname_C16}
# #    Check intergNB HO process on source gNB with RFSP off    log_name=${gNB1_logname_C16}
# #    Check intergNB HO process on target gNB    log_name=${gNB2_logname_C16}
# #    Check A2 nrcell configuration on target gNB    log_name=${gNB2_logname_C16}
# #    Wait until keyword succeeds    5min    30s
# #    ...    Check PM counter Result    counter_id=M55157C00035    dic_path=${profile_counter_path}    gnb_index=${1}    counter_end=${counter_end}
# #    [Teardown]    run keywords
# #    ...           run keyword and ignore error    Test recover    AND
# #    ...           run keyword and ignore error    Online modify parmeters    parameters_to_update=${PARAMS_TO_MODIFY_710_C16_4}    gnb_index=${0}
# 
# #[1]5GC000710_C_014_No_Redirection_to_target_when_Nrcell_NRREDRT_deleted_before_A2_measurement_report
# #    [Documentation]    This user scenario To verifies successful A2 measurement for redirection that all related redirection parameters provided
# #    ...    in RRC message  are correspond one of Mobility Profile
# #    [Tags]    5GC000710
# #    [Setup]
# #    Precondition for attn    value1=${${source_value}}
# #    Online modify parmeters    parameters_to_update=${PARAMS_TO_MODIFY_710_C14_1}    gnb_index=${0}
# #    Start Capture Wireshark Logs on gNB    nglogname=${gNB1_logname_C14}    gnb_index=${0}
# #    Attach and check power UE    ue_type=${ue_type}
# #    Power UE Start DL traffic    dl_throughput=20M
# #    Power UE Start UL traffic    ul_throughput=10M
# #    Check the cell DLUL throughput    cellid=${1}    gnb_index=${0}
# #    Online delete objects    parameters_to_update=${PARAMS_TO_MODIFY_710_C14_2}    gnb_index=${0}
# #    sleep    5s
# #    Adjust RU Attenuation for RED    value1=${${red_gnb1_value_start}}    value2=${${red_gnb1_value_end}}
# #    sleep    5s
# #    Stop Capture Wireshark Logs on gNB    nglogname=${gNB1_logname_C14}    gnb_index=${0}
# #    Check A2 configuration on source gNB    log_name=${gNB1_logname_C14}
# #    Check no redirection on source gNB    log_name=${gNB1_logname_C14}
# #    [Teardown]    run keywords
# #    ...           run keyword and ignore error    Test recover    AND
# #    ...           run keyword and ignore error    Online modify parmeters    parameters_to_update=${PARAMS_TO_MODIFY_710_C14_3}    gnb_index=${0}
# 
# #[1]5GC000710_C_013_Redirection_to_target_with_default_profile_when_seleted_profile_deleted_before_A2_measurement_report
# #    [Documentation]    This user scenario To verifies  Redirection to target with default Mobility profile configuration when selected
# #    ...    in mobility profile deleted before A2 measurement reports
# #    [Tags]    5GC000710
# #    [Setup]
# #    Precondition for attn    value1=${${source_value}}
# #    Online modify parmeters    parameters_to_update=${PARAMS_TO_MODIFY_710_C13_1}    gnb_index=${0}
# #    Start Capture Wireshark Logs on gNB    nglogname=${gNB1_logname_C13}    gnb_index=${0}
# #    Attach and check power UE    ue_type=${ue_type}
# #    Power UE Start DL traffic    dl_throughput=20M
# #    Power UE Start UL traffic    ul_throughput=10M
# #    Check the cell DLUL throughput    cellid=${1}    gnb_index=${0}
# #    Online delete objects    parameters_to_update=${PARAMS_TO_MODIFY_710_C13_2}    gnb_index=${0}
# #    Start to collect the X2 log on eNB    port=br1    x2_log_name=${eNB_logname_C13}
# #    sleep    5s
# #    Adjust RU Attenuation for RED to LTE    value1=${${red_lte_value}}    value2=${${red_gnb1_value_start}}    value3=${${red_gnb1_value_end}}
# #    sleep    5s
# #    Stop Capture Wireshark Logs on gNB    nglogname=${gNB1_logname_C13}    gnb_index=${0}
# #    Stop and download X2 Logs on eNB    x2_log_name=${eNB_logname_C13}    log_path=${epc_log_path}
# #    Check A2 configuration on source gNB    log_name=${gNB1_logname_C13}
# #    Check A2 redirection to LTE successfully    log_name1=${gNB1_logname_C13}    log_name2=${eNB_logname_C13}
# #    Wait until keyword succeeds    5min    30s
# #    ...    Check PM counter Result    counter_id=M55157C00063    dic_path=${profile_counter_path}    gnb_index=${0}    counter_end=${counter_end}
# #    Check PM counter Result    counter_id=M55157C00064    dic_path=${profile_counter_path}    gnb_index=${0}
# #    ...    counter_end=${counter_end}    counter_increase=False
# #    [Teardown]    run keyword and ignore error    Test recover
# 
# 
# *** Keywords ***
# Set suite variables
#     ${release_info} =    Get gnb release
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
#     set suite variable    ${tl_scf_file_name_gnb1}    ${para_store['${release_info}']['tl_scf_file_name_gnb1_710C']}
#     set suite variable    ${tl_scf_file_name_gnb2}    ${para_store['${release_info}']['tl_scf_file_name_gnb2_710C']}
#     set suite variable    ${PARAMS_CASEC21_1}    ${para_store['${release_info}']['PARAMS_CASEC21_1']}
#     set suite variable    ${PARAMS_CASEC21_2}    ${para_store['${release_info}']['PARAMS_CASEC21_2']}
#     set suite variable    ${PARAMS_CASEC21_3}    ${para_store['${release_info}']['PARAMS_CASEC21_3']}
#     set suite variable    ${PARAMS_CASEC21_4}    ${para_store['${release_info}']['PARAMS_CASEC21_4']}
# 
# Test recover
#     power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}
#     run keyword and ignore error    Stop ul dl data transfer
# 
# Precondition for attn
#     [Arguments]    ${value1}
#     Run Keyword if    '${release_info}' == 'SBTS22R4_ENB_0000'    Precondition for attn 22R4    value1=${value1}
#     ...    ELSE IF     '${release_info}' == 'SBTS22R3_ENB_0000'    Precondition for attn 22R3    value1=${value1}
#     ...    ELSE IF     '${release_info}' == 'SBTS22R2_ENB_0000'    Precondition for attn 22R4    value1=${value1}
#     ...    ELSE    Precondition for attn Trunk    value1=${value1}
# 
# Precondition for attn Trunk
#     [Arguments]    ${value1}    ${value3}=${127}
#     adjust the HBTE attenuation value    value=${value1}    att_port_1=${att_port_1}    att_port_2=${att_port_2}    atten_ip=${atten_ip}
#     adjust the HBTE attenuation value    value=${value3}    att_port_1=${att_port_3}    att_port_2=${att_port_4}    atten_ip=${atten_ip}
#     adjust the HBTE attenuation value    value=${value3}    att_port_1=${att_port_5}    att_port_2=${att_port_6}    atten_ip=${atten_ip}
#     adjust the HBTE attenuation value    value=${value3}    att_port_1=${att_port_7}    att_port_2=${att_port_8}    atten_ip=${atten_ip}
#     adjust the HBTE attenuation value    value=${value3}    att_port_1=${att_port_9}    att_port_2=${att_port_10}    atten_ip=${atten_ip}
# 
# Precondition for attn 22R3
#     [Arguments]    ${value1}    ${value3}=${127}
#     adjust the HBTE attenuation value    value=${value1}    att_port_1=${att_port_1}    att_port_2=${att_port_2}    atten_ip=${atten_ip}
#     adjust the HBTE attenuation value    value=${value3}    att_port_1=${att_port_3}    att_port_2=${att_port_4}    atten_ip=${atten_ip}
#     adjust the HBTE attenuation value    value=${value3}    att_port_1=${att_port_5}    att_port_2=${att_port_6}    atten_ip=${atten_ip}
#     adjust the HBTE attenuation value    value=${value3}    att_port_1=${att_port_7}    att_port_2=${att_port_8}    atten_ip=${atten_ip}
#     adjust the HBTE attenuation value    value=${value3}    att_port_1=${att_port_9}    att_port_2=${att_port_10}    atten_ip=${atten_ip}
# 
# Precondition for attn 22R4
#     [Arguments]    ${value1}    ${value3}=${127}
#     adjust the HBTE attenuation value    value=${value1}    att_port_1=${att_port_1}    att_port_2=${att_port_2}    atten_ip=${atten_ip}
#     adjust the HBTE attenuation value    value=${value3}    att_port_1=${att_port_3}    att_port_2=${att_port_4}    atten_ip=${atten_ip}
#     adjust the HBTE attenuation value    value=${value3}    att_port_1=${att_port_5}    att_port_2=${att_port_6}    atten_ip=${atten_ip}
#     adjust the HBTE attenuation value    value=${value3}    att_port_1=${att_port_7}    att_port_2=${att_port_8}    atten_ip=${atten_ip}
#     adjust the HBTE attenuation value    value=${value3}    att_port_1=${att_port_9}    att_port_2=${att_port_10}    atten_ip=${atten_ip}
# 
# Adjust RU Attenuation for MR
#     [Arguments]    ${value1}    ${value2}    ${value3}
#     Run Keyword if    '${release_info}' == 'SBTS22R4_ENB_0000'    Adjust RU Attenuation for MR 22R4
#     ...    start_value=${value1}    end_value=${value2}    value3=${value3}
#     ...    ELSE IF     '${release_info}' == 'SBTS22R3_ENB_0000'    Adjust RU Attenuation for MR 22R3
#     ...    start_value=${value1}    end_value=${value2}    value3=${value3}
#     ...    ELSE IF     '${release_info}' == 'SBTS22R2_ENB_0000'    Adjust RU Attenuation for MR 22R4
#     ...    start_value=${value1}    end_value=${value2}    value3=${value3}
#     ...    ELSE    Adjust RU Attenuation for MR Trunk    start_value=${value1}    end_value=${value2}    value3=${value3}
# 
# Adjust RU Attenuation for MR 22R4
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
# Adjust RU Attenuation for MR 22R3
#     [Arguments]    ${start_value}    ${end_value}    ${value3}
#     adjust the HBTE attenuation value    value=${value3}    att_port_1=${att_port_9}    att_port_2=${att_port_10}    atten_ip=${atten_ip}
#     adjust the HBTE attenuation value by step    start_value=${start_value}    end_value=${end_value}
#     ...    att_port_1=${att_port_1}    att_port_2=${att_port_2}    atten_ip=${atten_ip}
# 
# Adjust RU Attenuation for RED to 5G
#     [Arguments]    ${value1}    ${value2}
#     Run Keyword if    '${release_info}' == 'SBTS22R2_ENB_0000'    Adjust RU Attenuation for RED to 5G 22R2    value1=${value1}    value2=${value2}
#     ...    ELSE IF     '${release_info}' == 'SBTS22R1_ENB_0000'    Adjust RU Attenuation for RED to 5G 22R1    value1=${value1}    value2=${value2}
#     ...    ELSE    Adjust RU Attenuation for RED to 5G Trunk    value1=${value1}    value2=${value2}
# 
# Adjust RU Attenuation for RED to 5G 22R2
#     [Arguments]    ${value1}    ${value2}
#     adjust the HBTE attenuation value    value=${value1}    att_port_1=${att_port_3}    att_port_2=${att_port_4}    atten_ip=${atten_ip}
#     adjust the HBTE attenuation value    value=${value2}    att_port_1=${att_port_9}    att_port_2=${att_port_10}    atten_ip=${atten_ip}
# 
# Adjust RU Attenuation for RED to 5G Trunk
#     [Arguments]    ${value1}    ${value2}
#     adjust the HBTE attenuation value    value=${value1}    att_port_1=${att_port_3}    att_port_2=${att_port_4}    atten_ip=${atten_ip}
#     adjust the HBTE attenuation value    value=${value2}    att_port_1=${att_port_9}    att_port_2=${att_port_10}    atten_ip=${atten_ip}
# 
# Adjust RU Attenuation for RED to 5G 22R1
#     [Arguments]    ${value1}    ${value2}
#     adjust the HBTE attenuation value    value=${value1}    att_port_1=${att_port_3}    att_port_2=${att_port_4}    atten_ip=${atten_ip}
#     adjust the HBTE attenuation value    value=${value2}    att_port_1=${att_port_9}    att_port_2=${att_port_10}    atten_ip=${atten_ip}
# 
# Adjust RU Attenuation for RED
#     [Arguments]    ${value1}    ${value2}
#     Run Keyword if    '${release_info}' == 'SBTS22R2_ENB_0000'    Adjust RU Attenuation for RED 22R2    start_value=${va
# ...lue1}    end_value=${value2}
#     ...    ELSE IF     '${release_info}' == 'SBTS22R1_ENB_0000'    Adjust RU Attenuation for RED 22R1    start_value=${v
# ...alue1}    end_value=${value2}
#     ...    ELSE    Adjust RU Attenuation for RED Trunk    start_value=${value1}    end_value=${value2}
# 
# Adjust RU Attenuation for RED 22R2
#     [Arguments]    ${start_value}    ${end_value}
#     adjust the HBTE attenuation value by step    start_value=${start_value}    end_value=${end_value}
#     ...    att_port_1=${att_port_1}    att_port_2=${att_port_2}    atten_ip=${atten_ip}
# 
# Adjust RU Attenuation for RED Trunk
#     [Arguments]    ${start_value}    ${end_value}
#     adjust the HBTE attenuation value by step    start_value=${start_value}    end_value=${end_value}
#     ...    att_port_1=${att_port_1}    att_port_2=${att_port_2}    atten_ip=${atten_ip}
# 
# Adjust RU Attenuation for RED 22R1
#     [Arguments]    ${start_value}    ${end_value}
#     adjust the HBTE attenuation value by step    start_value=${start_value}    end_value=${end_value}
#     ...    att_port_1=${att_port_1}    att_port_2=${att_port_2}    atten_ip=${atten_ip}
# 
# Adjust RU Attenuation for RED to LTE
#     [Arguments]    ${value1}    ${value2}    ${value3}
#     Run Keyword if    '${release_info}' == 'SBTS22R2_ENB_0000'    Adjust RU Attenuation for RED to LTE 22R2
#     ...    value1=${value1}    start_value=${value2}    end_value=${value3}
#     ...    ELSE IF     '${release_info}' == 'SBTS22R1_ENB_0000'    Adjust RU Attenuation for RED to LTE 22R1
#     ...    value1=${value1}    start_value=${value2}    end_value=${value3}
#     ...    ELSE    Adjust RU Attenuation for RED to LTE Trunk
#     ...    value1=${value1}    start_value=${value2}    end_value=${value3}
# 
# Adjust RU Attenuation for RED to LTE 22R2
#     [Arguments]    ${value1}    ${start_value}    ${end_value}
#     adjust the HBTE attenuation value    value=${value1}    att_port_1=${att_port_7}    att_port_2=${att_port_8}    atten_ip=${atten_ip}
#     adjust the HBTE attenuation value by step    start_value=${start_value}    end_value=${end_value}
#     ...    att_port_1=${att_port_1}    att_port_2=${att_port_2}    atten_ip=${atten_ip}
# 
# Adjust RU Attenuation for RED to LTE Trunk
#     [Arguments]    ${value1}    ${start_value}    ${end_value}
#     adjust the HBTE attenuation value    value=${value1}    att_port_1=${att_port_7}    att_port_2=${att_port_8}    atten_ip=${atten_ip}
#     adjust the HBTE attenuation value by step    start_value=${start_value}    end_value=${end_value}
#     ...    att_port_1=${att_port_1}    att_port_2=${att_port_2}    atten_ip=${atten_ip}
# 
# Adjust RU Attenuation for RED to LTE 22R1
#     [Arguments]    ${value1}    ${start_value}    ${end_value}
#     adjust the HBTE attenuation value    value=${value1}    att_port_1=${att_port_7}    att_port_2=${att_port_8}    atten_ip=${atten_ip}
#     adjust the HBTE attenuation value by step    start_value=${start_value}    end_value=${end_value}
#     ...    att_port_1=${att_port_1}    att_port_2=${att_port_2}    atten_ip=${atten_ip}
# 
# Trigger IntraFreq IntergNB Handover
#     [Arguments]    ${logname1}    ${logname2}
#     Start Capture Wireshark Logs on gNB    nglogname=${logname1}    gnb_index=${0}
#     Attach and check power UE    ue_type=${ue_type}
#     Power UE Start DL traffic    dl_throughput=20M
#     Power UE Start UL traffic    ul_throughput=10M
#     Check the cell DLUL throughput    cellid=${1}    gnb_index=${0}
#     Start Capture Wireshark Logs on gNB    nglogname=${logname2}    gnb_index=${1}
#     sleep    5s
#     Adjust RU Attenuation for MR    value1=${${source_ho_value_start}}    value2=${${source_ho_value_end}}    value3=${${target_value}}
#     sleep    5s
#     Check the cell DLUL throughput    cellid=${1}    gnb_index=${1}
#     Stop Capture Wireshark Logs on gNB    nglogname=${logname1}    gnb_index=${0}
#     Stop Capture Wireshark Logs on gNB    nglogname=${logname2}    gnb_index=${1}
# 
# Trigger Redirection to 5G
#     [Arguments]    ${logname1}    ${logname2}
#     Start Capture Wireshark Logs on gNB    nglogname=${logname1}    gnb_index=${1}
#     Start Capture Wireshark Logs on gNB    nglogname=${logname2}    gnb_index=${0}
#     Adjust RU Attenuation for RED to 5G    value1=${${red_target_value}}    value2=${${red_source_value}}
#     sleep    5s
#     Stop Capture Wireshark Logs on gNB    nglogname=${logname1}    gnb_index=${1}
#     Stop Capture Wireshark Logs on gNB    nglogname=${logname2}    gnb_index=${0}
# 
# Check intergNB HO process on source gNB with RFSP on
#     [Arguments]    ${log_name}
#     ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${log_name}    tshark_path=${tshark_path}
#     ...                command_template=${command_template_Y}
#     ${RFSP_expression}=     Catenate    ngap.NGAP_PDU == 0 and ngap.procedureCode == 14
#     ${RFSP_packets}=    parser.filter_packets_by_expression    filter_expression=${RFSP_expression}
#     ${RFSP_value_in_ICS}=     parser.get_field_value_by_xpath    pdml_list=${RFSP_packets}    xpath=.//ngap.IndexToRFSP
#     should be equal    ${RFSP_value_in_ICS[0]}    ${RFSP_value}
#     ${all_packets1}=    parser.load_pcap_file    pcap_file=${epc_log_path}${log_name}    tshark_path=${tshark_path}
#     ...                command_template=${command_template_Z}
#     ${HO_Request_expression}=     Catenate    xnap.procedureCode == 0 and xnap.radioNetwork == 1
#     ${HO_Request_packets}=    parser.filter_packets_by_expression    filter_expression=${HO_Request_expression}
#     ${RFSP_value_in_HO_Request}=     parser.get_field_value_by_xpath    pdml_list=${HO_Request_packets}
#     ...    xpath=.//xnap.UEContextInfoHORequest_element/xnap.indexToRatFrequencySelectionPriority
#     should be equal    ${RFSP_value_in_HO_Request[0]}    ${RFSP_value}
#     ${HO_Request_Ack_expression}=     Catenate    xnap.XnAP_PDU == 1 and xnap.procedureCode == 0
#     ${HO_Request_Ack_packets}=    parser.filter_packets_by_expression    filter_expression=${HO_Request_Ack_expression}
#     ${HO_Request_Ack}=    parser.get_field_value_by_xpath    pdml_list=${HO_Request_Ack_packets}    xpath=.//xnap.procedureCode
#     should be equal    ${HO_Request_Ack[0]}    0
# 
# Check intergNB HO process on source gNB with RFSP off
#     [Arguments]    ${log_name}
#     ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${log_name}    tshark_path=${tshark_path}
#     ...                command_template=${command_template_Z}
#     ${HO_Request_expression}=     Catenate    xnap.procedureCode == 0 and xnap.radioNetwork == 1
#     ${HO_Request_packets}=    parser.filter_packets_by_expression    filter_expression=${HO_Request_expression}
#     ${HO_Request}=     parser.get_field_value_by_xpath    pdml_list=${HO_Request_packets}    xpath=.//xnap.radioNetwork
#     should be equal    ${HO_Request[0]}    1
#     ${HO_Request_Ack_expression}=     Catenate    xnap.XnAP_PDU == 1 and xnap.procedureCode == 0
#     ${HO_Request_Ack_packets}=    parser.filter_packets_by_expression    filter_expression=${HO_Request_Ack_expression}
#     ${HO_Request_Ack}=    parser.get_field_value_by_xpath    pdml_list=${HO_Request_Ack_packets}    xpath=.//xnap.procedureCode
#     should be equal    ${HO_Request_Ack[0]}    0
# 
# Check intergNB HO process on target gNB
#     [Arguments]    ${log_name}
#     ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${log_name}    tshark_path=${tshark_path}
#     ...                command_template=${command_template_Z}
#     ${HO_Request_expression}=     Catenate    xnap.procedureCode == 0 and xnap.radioNetwork == 1
#     ${HO_Request_packets}=    parser.filter_packets_by_expression    filter_expression=${HO_Request_expression}
#     ${HO_Request}=     parser.get_field_value_by_xpath    pdml_list=${HO_Request_packets}    xpath=.//xnap.radioNetwork
#     should be equal    ${HO_Request[0]}    1
#     ${HO_Request_Ack_expression}=     Catenate    xnap.XnAP_PDU == 1 and xnap.procedureCode == 0
#     ${HO_Request_Ack_packets}=    parser.filter_packets_by_expression    filter_expression=${HO_Request_Ack_expression}
#     ${HO_Request_Ack}=    parser.get_field_value_by_xpath    pdml_list=${HO_Request_Ack_packets}    xpath=.//xnap.procedureCode
#     should be equal    ${HO_Request_Ack[0]}    0
# 
# Check A2 configuration on source gNB
#     [Arguments]    ${log_name}
#     ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${log_name}    tshark_path=${tshark_path}
#     ...                command_template=${command_template_X}
#     ${UCS_expression}=     Catenate    f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 5
#     ${UCS_packets}=    parser.filter_packets_by_expression    filter_expression=${UCS_expression}
#     ${eventA2}=    parser.get_field_value_by_xpath    pdml_list=${UCS_packets}    xpath=.//nr-rrc.eventId
#     should be equal    ${eventA2[0]}    1
#     should be equal    ${eventA2[1]}    1
#     ${a2_Threshold}=    parser.get_field_value_by_xpath    pdml_list=${UCS_packets}    xpath=.//nr-rrc.eventA2_element/nr-rrc.a2_Threshold
#     should be equal     ${a2_Threshold[0]}    0
#     should be equal     ${a2_Threshold[1]}    1
#     ${A2_rsrp}=    parser.get_field_value_by_xpath    pdml_list=${UCS_packets}    xpath=.//nr-rrc.eventA2_element/nr-rrc.a2_Threshold/nr-rrc.rsrp
#     should be equal    ${A2_rsrp[0]}    67
#     ${A2_rsrq}=    parser.get_field_value_by_xpath    pdml_list=${UCS_packets}    xpath=.//nr-rrc.eventA2_element/nr-rrc.a2_Threshold/nr-rrc.rsrq
#     should be equal    ${A2_rsrq[0]}    40
#     ${A2_hysteresis}=    parser.get_field_value_by_xpath    pdml_list=${UCS_packets}    xpath=.//nr-rrc.eventA2_element/nr-rrc.hysteresis
#     should be equal    ${A2_hysteresis[0]}    0
#     should be equal    ${A2_hysteresis[1]}    0
#     ${A2_timeToTrigger}=    parser.get_field_value_by_xpath    pdml_list=${UCS_packets}    xpath=.//nr-rrc.eventA2_element/nr-rrc.timeToTrigger
#     should be equal    ${A2_timeToTrigger[0]}    10
#     should be equal    ${A2_timeToTrigger[1]}    9
# 
# Check no A2 configuration on source gNB
#     [Arguments]    ${log_name}
#     ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${log_name}    tshark_path=${tshark_path}
#     ...                command_template=${command_template_X}
#     ${UCS_expression}=     Catenate    f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 5
#     ${UCS_packets}=    parser.filter_packets_by_expression    filter_expression=${UCS_expression}
#     ${eventA2}=    parser.get_field_value_by_xpath    pdml_list=${UCS_packets}    xpath=.//nr-rrc.eventId
#     should not contain    ${eventA2}    1
# 
# Check A2 rsrp configuration on target gNB
#     [Arguments]    ${log_name}
#     ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${log_name}    tshark_path=${tshark_path}
#     ...                command_template=${command_template_X}
#     ${UCS_expression}=     Catenate    f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 5
#     ${UCS_packets}=    parser.filter_packets_by_expression    filter_expression=${UCS_expression}
#     ${eventA2}=    parser.get_field_value_by_xpath    pdml_list=${UCS_packets}    xpath=.//nr-rrc.eventId
#     should be equal    ${eventA2[0]}    1
#     ${a2_Threshold}=    parser.get_field_value_by_xpath    pdml_list=${UCS_packets}    xpath=.//nr-rrc.eventA2_element/nr-rrc.a2_Threshold
#     should be equal     ${a2_Threshold[0]}    0
#     ${A2_rsrp}=    parser.get_field_value_by_xpath    pdml_list=${UCS_packets}    xpath=.//nr-rrc.eventA2_element/nr-rrc.a2_Threshold/nr-rrc.rsrp
#     should be equal    ${A2_rsrp[0]}    70
#     ${A2_hysteresis}=    parser.get_field_value_by_xpath    pdml_list=${UCS_packets}    xpath=.//nr-rrc.eventA2_element/nr-rrc.hysteresis
#     should be equal    ${A2_hysteresis[0]}    0
#     ${A2_timeToTrigger}=    parser.get_field_value_by_xpath    pdml_list=${UCS_packets}    xpath=.//nr-rrc.eventA2_element/nr-rrc.timeToTrigger
#     should be equal    ${A2_timeToTrigger[0]}    9
# 
# Check A2 rsrq configuration on target gNB
#     [Arguments]    ${log_name}
#     ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${log_name}    tshark_path=${tshark_path}
#     ...                command_template=${command_template_X}
#     ${UCS_expression}=     Catenate    f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 5
#     ${UCS_packets}=    parser.filter_packets_by_expression    filter_expression=${UCS_expression}
#     ${eventA2}=    parser.get_field_value_by_xpath    pdml_list=${UCS_packets}    xpath=.//nr-rrc.eventId
#     should be equal    ${eventA2[0]}    1
#     ${a2_Threshold}=    parser.get_field_value_by_xpath    pdml_list=${UCS_packets}    xpath=.//nr-rrc.eventA2_element/nr-rrc.a2_Threshold
#     should be equal     ${a2_Threshold[0]}    1
#     ${A2_rsrq}=    parser.get_field_value_by_xpath    pdml_list=${UCS_packets}
#     ...    xpath=.//nr-rrc.eventA2_element/nr-rrc.a2_Threshold/nr-rrc.measTriggerQuantity.rsrq
#     should be equal    ${A2_rsrq[0]}    48
#     ${A2_hysteresis}=    parser.get_field_value_by_xpath    pdml_list=${UCS_packets}    xpath=.//nr-rrc.eventA2_element/nr-rrc.hysteresis
#     should be equal    ${A2_hysteresis[0]}    0
#     ${A2_timeToTrigger}=    parser.get_field_value_by_xpath    pdml_list=${UCS_packets}    xpath=.//nr-rrc.eventA2_element/nr-rrc.timeToTrigger
#     should be equal    ${A2_timeToTrigger[0]}    5
# 
# Check A2 nrcell configuration on target gNB
#     [Arguments]    ${log_name}
#     ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${log_name}    tshark_path=${tshark_path}
#     ...                command_template=${command_template_X}
#     ${UCS_expression}=     Catenate    f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 5
#     ${UCS_packets}=    parser.filter_packets_by_expression    filter_expression=${UCS_expression}
#     ${eventA2}=    parser.get_field_value_by_xpath    pdml_list=${UCS_packets}    xpath=.//nr-rrc.eventId
#     should be equal    ${eventA2[0]}    1
#     should be equal    ${eventA2[1]}    1
#     ${a2_Threshold}=    parser.get_field_value_by_xpath    pdml_list=${UCS_packets}    xpath=.//nr-rrc.eventA2_element/nr-rrc.a2_Threshold
#     should be equal     ${a2_Threshold[0]}    0
#     should be equal     ${a2_Threshold[1]}    1
#     ${A2_rsrp}=    parser.get_field_value_by_xpath    pdml_list=${UCS_packets}    xpath=.//nr-rrc.eventA2_element/nr-rrc.a2_Threshold/nr-rrc.rsrp
#     should be equal    ${A2_rsrp[0]}    70
#     ${A2_rsrq}=    parser.get_field_value_by_xpath    pdml_list=${UCS_packets}    xpath=.//nr-rrc.eventA2_element/nr-rrc.a2_Threshold/nr-rrc.rsrq
#     should be equal    ${A2_rsrq[0]}    48
#     ${A2_hysteresis}=    parser.get_field_value_by_xpath    pdml_list=${UCS_packets}    xpath=.//nr-rrc.eventA2_element/nr-rrc.hysteresis
#     should be equal    ${A2_hysteresis[0]}    0
#     should be equal    ${A2_hysteresis[1]}    0
#     ${A2_timeToTrigger}=    parser.get_field_value_by_xpath    pdml_list=${UCS_packets}    xpath=.//nr-rrc.eventA2_element/nr-rrc.timeToTrigger
#     should be equal    ${A2_timeToTrigger[0]}    9
#     should be equal    ${A2_timeToTrigger[1]}    5
# 
# Check A2 redirection to 5G successfully
#     [Arguments]    ${log_name1}    ${log_name2}
#     ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${log_name1}    tshark_path=${tshark_path}
#     ...                command_template=${command_template_Y}
#     ${UE_Release_Request_expression}=    Catenate    ngap.NGAP_PDU == 0 and ngap.procedureCode == 42
#     ${UE_Release_Request_packets}=    parser.filter_packets_by_expression
#     ...    filter_expression=${UE_Release_Request_expression}
#     ${Cause}=    parser.get_field_value_by_xpath    pdml_list=${UE_Release_Request_packets}    xpath=.//ngap.radioNetwork
#     should be equal    ${Cause[0]}    41
#     ${UE_Release_Command_expression}=    Catenate    ngap.NGAP_PDU == 0 and ngap.procedureCode == 41
#     ${UE_Release_Command_packets}=    parser.filter_packets_by_expression
#     ...    filter_expression=${UE_Release_Command_expression}
#     ${Cause}=    parser.get_field_value_by_xpath    pdml_list=${UE_Release_Command_packets}    xpath=.//ngap.radioNetwork
#     should be equal    ${Cause[0]}    41
#     ${all_packets1}=    parser.load_pcap_file    pcap_file=${epc_log_path}${log_name2}    tshark_path=${tshark_path}
#     ...                command_template=${command_template_Y}
#     ${ICS_Request_expression}=    Catenate    ngap.NGAP_PDU == 0 and ngap.procedureCode == 14
#     ${ICS_Request_packets}=    parser.filter_packets_by_expression    filter_expression=${ICS_Request_expression}
#     ${ICS_Request}=    parser.get_field_value_by_xpath    pdml_list=${ICS_Request_packets}    xpath=.//ngap.procedureCode
#     should be equal    ${ICS_Request[0]}    14
#     ${ICS_Response_expression}=    Catenate    ngap.NGAP_PDU == 1 and ngap.procedureCode == 14
#     ${ICS_Response_packets}=    parser.filter_packets_by_expression    filter_expression=${ICS_Response_expression}
#     ${ICS_Response}=    parser.get_field_value_by_xpath    pdml_list=${ICS_Response_packets}    xpath=.//ngap.procedureCode
#     should be equal    ${ICS_Response[0]}    14
# 
# Check no redirection on source gNB
#     [Arguments]    ${log_name}
#     ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${log_name}    tshark_path=${tshark_path}
#     ...                command_template=${command_template_Y}
#     ${UE_Release_Request_expression}=    Catenate    ngap.NGAP_PDU == 0 and ngap.procedureCode == 42
#     ${UE_Release_Request_packets}=    parser.filter_packets_by_expression
#     ...    filter_expression=${UE_Release_Request_expression}
#     ${UE_Release_Request}=    parser.get_field_value_by_xpath    pdml_list=${UE_Release_Request_packets}    xpath=.//ngap.procedureCode
#     should be empty    ${UE_Release_Request}
# 
# Check A2 redirection to LTE successfully
#     [Arguments]    ${log_name1}    ${log_name2}
#     ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${log_name1}    tshark_path=${tshark_path}
#     ...                command_template=${command_template_Y}
#     ${UE_Release_Request_expression}=    Catenate    ngap.NGAP_PDU == 0 and ngap.procedureCode == 42
#     ${UE_Release_Request_packets}=    parser.filter_packets_by_expression
#     ...    filter_expression=${UE_Release_Request_expression}
#     ${Cause}=    parser.get_field_value_by_xpath    pdml_list=${UE_Release_Request_packets}    xpath=.//ngap.radioNetwork
#     should be equal    ${Cause[0]}    41
#     ${UE_Release_Command_expression}=    Catenate    ngap.NGAP_PDU == 0 and ngap.procedureCode == 41
#     ${UE_Release_Command_packets}=    parser.filter_packets_by_expression
#     ...    filter_expression=${UE_Release_Command_expression}
#     ${Cause}=    parser.get_field_value_by_xpath    pdml_list=${UE_Release_Command_packets}    xpath=.//ngap.radioNetwork
#     should be equal    ${Cause[0]}    41
#     ${all_packets1}=    parser.load_pcap_file    pcap_file=${epc_log_path}${log_name2}    tshark_path=${tshark_path}
#     ...                command_template=${command_template_W}
#     ${TAU_accept_expression}=    Catenate    s1ap.procedureCode == 9 and nas_eps.nas_msg_emm_type == 73
#     ${TAU_accept_packets}=    parser.filter_packets_by_expression    filter_expression=${TAU_accept_expression}
#     ${TAU_accept}=    parser.get_field_value_by_xpath    pdml_list=${TAU_accept_packets}    xpath=.//nas_eps.nas_msg_emm_type
#     should be equal    ${TAU_accept[0]}    73
#     ${TAU_complete_expression}=    Catenate    s1ap.procedureCode == 13 and nas_eps.nas_msg_emm_type == 74
#     ${TAU_complete_packets}=    parser.filter_packets_by_expression    filter_expression=${TAU_complete_expression}
#     ${TAU_complete}=    parser.get_field_value_by_xpath    pdml_list=${TAU_complete_packets}    xpath=.//nas_eps.nas_msg_emm_type
#     should be equal    ${TAU_complete[0]}    74