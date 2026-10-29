# *** Settings ***
# Documentation
# ...    author: Shi Ming
# ...    contact: ming.shi@nokia-sbell.com
# ...    squal group: SG03
# ...    feature: CB008200-E
# 
# Force Tags  CA_5G_RRM
# ...    PY36
# Suite Setup    Run Keywords    Common Suite Setup for COAM    AND
# ...                            Setup for Env cell on-air    tl_scf_file_name=${tl_scf_file_name1}    AND
# ...                            Common UE parameter setup
# 
# Suite Teardown    Run Keyword    robot_common_operations.Common Suite Teardown
# 
# 
# Resource     Resources/CB008200_common_keywords.robot
# Variables    Resources/CB008200_variables.py
# 
# 
# *** Variables ***
# ${tl_scf_dir_path}    /opt/workspace/CRT/Master/SCF_file/golden SCF/
# ${tl_scf_file_name1}    Configuration_scf_GNB1_CB008698.xml
# ${tl_scf_file_name2}    Configuration_scf_GNB2_CB008698.xml
# ${log_name_E_001_1}    log_name_E_001_1.pcap
# ${log_name_E_001_2}    log_name_E_001_2.pcap
# 
# ${ue_type}    huawei
# 
# ${enb_instance}     ${tl.enbs[0].instance_id}
# @{enb_dist_name}    MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-1
# @{enb_dist_name2}    MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-0
# @{enb_para}    administrativeState
# @{enb_value}    unlocked    locked
# ${vendor}                    ${tl.attenuators[0].vendor}
# @{att_connection_port2}      ${5Gcell1_ANT3}    ${5Gcell1_ANT4}
# @{gnb_ips}    ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}    ${tl.gnbs[1].cu.oam_ssh_connection_details.addr}
# 
# *** Test Cases ***
# [1]CB008200_5G_E_SA_Utilization_counter_001_Average_Peak_Number_of_Connected_5QI-1_UEs
#     [Documentation]    This User Scenario is aimed at defining the Average Number of SA 5QI-1 Ues
#     ...    connected in the network. The counter uses the logic of ref. 5G_CP_ARC_ALG_370.
#     [Tags]    CB008200-C    CRT_TRUNK    CRT_22R2    CRT_22R3    CRT_22R4
#     [Timeout]    1 hour
#     [Setup]    robot_common_operations.Common Case Setup
# #    Online modify parmeters    parameters_to_update=${PARAM_8200_E_001}
#     set enb cell for E001    value=@{enb_value}[1]
#     Lock cells for test
#     ####set gnb1 cell1 PA to 0
# #    Recover attenuation to trigger
#     Step1: UE attach    ue_type=${ue_type}
#     Step1: UE attach    ue_type=${ue_type}    ue_index=${1}
#     Prepare with PM counter time to caculate    period=start
#     Start capture gNB log on master    filename=${log_name_E_001_1}
#     Step2: UE setup VoNR call
#     sleep    20s
#     check voice call status    status=${2}
#     Stop and download Logs on gNB on master    filename=${log_name_E_001_1}
#     Start capture gNB log on master    filename=${log_name_E_001_2}
#     Step2: UE setup VoNR call    ue_index=${1}
#     sleep    20s
#     check voice call status    ue_index=${1}    status=${2}
#     Stop and download Logs on gNB on master    filename=${log_name_E_001_2}
#     Prepare with PM counter time to caculate    period=end
#     Check counter for 001_1
#     Prepare with PM counter time to caculate    period=start
#     Repeat Keyword    5 times    Repeat check voice call status
#     Prepare with PM counter time to caculate    period=end
#     Check counter for 001_2
#     Prepare with PM counter time to caculate    period=start
#     check voice call status    status=${2}
#     check voice call status    ue_index=${1}    status=${2}
#     Step3: UE hang up VoNR call
#     Step3: UE hang up VoNR call    ue_index=${1}
#     sleep    20s
#     check voice call status    status=${0}
#     check voice call status    ue_index=${1}    status=${0}
#     Prepare with PM counter time to caculate    period=end
#     Check counter for 001_3
#     Check wireshark log for 001
#     [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown    AND
#     ...    Step3: UE hang up VoNR call    AND    check voice call status    status=${0}    AND
#     ...    Step4: Detach UE    ue_type=${ue_type}    AND
#     ...    Step3: UE hang up VoNR call    ue_index=${1}    AND    check voice call status    ue_index=${1}    status=${0}    AND
#     ...    Step4: Detach UE    ue_type=${ue_type}    ue_index=${1}    AND
#     ...    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_E_001_1}    AND
#     ...    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_E_001_2}    AND
# #    ...    check hanging resource for per UE on gnb    gnb_ips=@{gnb_ips}    UE_Type_Index=${2}    AND
#     ...    Check hanging resource for gnb    gnb_ips=${gnb_ips}    AND
# #    ...    Online modify parmeters    parameters_to_update=${PARAM_8200_recover_E_001}    AND
#     ...    Unlock cells for test    AND    set enb cell for E001    AND
#     ...    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
# 
# *** Keywords ***
# 
# set enb cell for E001
#     [Arguments]    ${dist_name}=@{enb_dist_name}[0]    ${dist_name1}=@{enb_dist_name2}[0]    ${parameter}=@{enb_para}[0]
# ...    ${value}=@{enb_value}[0]
#     Modify parameter on enb    dist_name=${dist_name}    parameter=${parameter}    value=${value}
# 
# #set enb cell for E001
# #    [Arguments]    ${dist_name}=@{enb_dist_name}[0]    ${dist_name1}=@{enb_dist_name2}[0]    ${parameter}=@{enb_para}[0
# ...]    ${value}=@{enb_value}[0]
# #    Run keyword if    '${enb_instance}'=='${911}'   Modify parameter on enb    dist_name=${dist_name1}    parameter=${parameter}    value=${value}
# #    ...    ELSE    Modify parameter on enb    dist_name=${dist_name}    parameter=${parameter}    value=${value}
# 
# Repeat check voice call status
#     check voice call status    status=${2}
#     check voice call status    ue_index=${1}    status=${2}
#     sleep    1m
# 
# ###check wireshar log
# Check wireshark log for 001
#     Check VoNR success message    logname=${log_name_E_001_1}
#     Check VoNR success message    logname=${log_name_E_001_2}
# 
# ####check counter on WEBUI
# Check counter for 001_1
#     sleep    40s
#     Check gnb counter as expected_value
#     ...    counter_id=${PEAK_NUMBER_OF_UE_5QI1['counter_id']}
#     ...    dic_path=${PEAK_NUMBER_OF_UE_5QI1['dic_path']}
#     ...    expected_value=${2}
#     ...    gnb_id=${PEAK_NUMBER_OF_UE_5QI1['gnb_id']}
#     Check gnb counter greater expected_value
#     ...    counter_id=${AVE_NUMBER_OF_UE_5QI1['counter_id']}
#     ...    dic_path=${AVE_NUMBER_OF_UE_5QI1['dic_path']}
#     ...    expected_value=${1}
#     ...    gnb_id=${AVE_NUMBER_OF_UE_5QI1['gnb_id']}
#     Check gnb counter as expected_value
#     ...    counter_id=${AVE_NUMBER_OF_UE_5QI1_DENOM['counter_id']}
#     ...    dic_path=${AVE_NUMBER_OF_UE_5QI1_DENOM['dic_path']}
#     ...    expected_value=${300}
#     ...    gnb_id=${AVE_NUMBER_OF_UE_5QI1_DENOM['gnb_id']}
# 
# Check counter for 001_2
#     sleep    40s
#     Check gnb counter as expected_value
#     ...    counter_id=${PEAK_NUMBER_OF_UE_5QI1['counter_id']}
#     ...    dic_path=${PEAK_NUMBER_OF_UE_5QI1['dic_path']}
#     ####    2022/10/13 02611195,chart with 8200Spec,according to PR,modify counter from 0 to 2:when VONR keep ongiong,counter will also keep.
#     ...    expected_value=${2}
#     ...    gnb_id=${PEAK_NUMBER_OF_UE_5QI1['gnb_id']}
#     Check gnb counter as expected_value
#     ...    counter_id=${AVE_NUMBER_OF_UE_5QI1['counter_id']}
#     ...    dic_path=${AVE_NUMBER_OF_UE_5QI1['dic_path']}
#     ...    expected_value=${600}
#     ...    gnb_id=${AVE_NUMBER_OF_UE_5QI1['gnb_id']}
#     Check gnb counter as expected_value
#     ...    counter_id=${AVE_NUMBER_OF_UE_5QI1_DENOM['counter_id']}
#     ...    dic_path=${AVE_NUMBER_OF_UE_5QI1_DENOM['dic_path']}
#     ...    expected_value=${300}
#     ...    gnb_id=${AVE_NUMBER_OF_UE_5QI1_DENOM['gnb_id']}
# 
# Check counter for 001_3
#     sleep    40s
#     Check gnb counter as expected_value
#     ...    counter_id=${PEAK_NUMBER_OF_UE_5QI1['counter_id']}
#     ...    dic_path=${PEAK_NUMBER_OF_UE_5QI1['dic_path']}
#     ...    expected_value=${2}
#     ...    gnb_id=${PEAK_NUMBER_OF_UE_5QI1['gnb_id']}
#     Check gnb counter greater expected_value
#     ...    counter_id=${AVE_NUMBER_OF_UE_5QI1['counter_id']}
#     ...    dic_path=${AVE_NUMBER_OF_UE_5QI1['dic_path']}
#     ...    expected_value=${1}
#     ...    gnb_id=${AVE_NUMBER_OF_UE_5QI1['gnb_id']}
#     Check gnb counter as expected_value
#     ...    counter_id=${AVE_NUMBER_OF_UE_5QI1_DENOM['counter_id']}
#     ...    dic_path=${AVE_NUMBER_OF_UE_5QI1_DENOM['dic_path']}
#     ...    expected_value=${300}
#     ...    gnb_id=${AVE_NUMBER_OF_UE_5QI1_DENOM['gnb_id']}
# 
# Change Attenuation value for 343 Cell1
#     [Arguments]    ${cell}    ${value}
#     Adjust the attenuation value for Topyoung    ports1=${${cell}_ANT3}    ports2=${${cell}_ANT4}    value=${value}
# 
# Adjust the attenuation value for Topyoung
#     [Arguments]      ${value}=${value}    ${ports1}=${ports1}    ${ports2}=${ports2}
#     atten.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
#     ...    attenuation_port_numbers=${att_connection_port2}    max_attenuation=${HBTE_max_value}    vendor=${vendor}
#     atten.set_attenuation     port=${ports1}    value=${value}
#     atten.set_attenuation     port=${ports2}    value=${value}
#     ${value_port1}    atten.read_attenuation    port=${ports1}
#     should be equal    ${value_port1}    ${value}
#     ${value_port2}    atten.read_attenuation    port=${ports2}
#     should be equal    ${value_port2}    ${value}