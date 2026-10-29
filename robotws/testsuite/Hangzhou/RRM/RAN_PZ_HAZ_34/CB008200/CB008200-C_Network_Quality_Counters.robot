# *** Settings ***
# Documentation
# ...    author: Shi Ming
# ...    contact: ming.shi@nokia-sbell.com
# ...    squal group: SG03
# ...    feature: CB008200-C
# 
# Force Tags  CA_5G_RRM    RAN_5G    RAN_5G_TDD    CLOUD_5G_CLASSICAL_ANDROID_ASIKL_ABILB1_AAHF_RF_SHARING_ENB
# ...         STATE_SW_UPLOADED    PY36
# Suite Setup    Run Keywords    Setup Env for test    AND
# ...                            Common Suite Setup for COAM    AND
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
# ${log_name_C_001}    log_name_C_001.pcap
# 
# ${ue_type}    samsung
# 
# ${enb_instance}     ${tl.enbs[0].instance_id}
# @{enb_dist_name}    MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-3
# @{enb_para}    administrativeState
# @{enb_value}    unlocked    locked
# @{gnb_ips}    ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
# 
# *** Test Cases ***
# [1]CB008200_5G_C_Performance_Measurements_002_CQI_counters_when_only_256QAM_table_configuted
#     [Documentation]    PM Counter update for VoNR Wideband CQI per cell for cloud and classical gNB.
#     [Tags]    CB008200-C    CRT_TRUNK    CRT_22R2    SBTS00    CRT_UTE    CRT_22R3    CRT_22R4
#     [Timeout]    1 hour
#     [Setup]    robot_common_operations.Common Case Setup
#     Online modify parmeters    parameters_to_update=${PARAM_8200_C_001}
#     set enb cell    value=@{enb_value}[1]
#     ####set gnb1 cell1 PA to 0
#     Recover HBTE attenuation to trigger RLF
#     Step1: UE attach    ue_type=${ue_type}
#     Start capture gNB log on slave    filename=${log_name_C_001}
#     Step2: UE setup VoNR call
#     sleep    20s
#     check voice call status    status=${2}
#     Stop and download the Logs on slave    filename=${log_name_C_001}
#     Prepare with PM counter time to caculate    period=start
# #    Repeat Keyword    5 times    Repeat set HBTE attenuation
#     sleep    5m
#     Prepare with PM counter time to caculate    period=end
#     Check wireshark log for 001
#     Check counter for 001
#     [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown    AND
#     ...    Step3: UE hang up VoNR call    AND    check voice call status    status=${0}    AND
#     ...    Step4: Detach UE    ue_type=${ue_type}    AND
#     ...    Run Keyword And Ignore Error    Stop and download the Logs on slave    filename=${log_name_C_001}    AND
#     ...    check hanging resource for per UE on gnb    gnb_ips=@{gnb_ips}    UE_Type_Index=${1}    ute_log_path=${epc_log_path}    AND
#     ...    Online modify parmeters    parameters_to_update=${PARAM_8200_recover_C_001}    AND
#     ...    set enb cell    AND
#     ...    Recover HBTE attenuation to trigger RLF    AND
#     ...    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
# 
# 
# 
# *** Keywords ***
# ###check wireshar log
# Check wireshark log for 001
#     Check VoNR success message    logname=${log_name_C_001}
# 
# ####check counter on WEBUI
# #Check counter for 001
# ##    Check gnb counter greater expected_value
# ##    ...    counter_id=${WB_CQI_256TBL_5QI1_CQI15['counter_id']}
# ##    ...    dic_path=${WB_CQI_256TBL_5QI1_CQI15['dic_path']}
# ##    ...    expected_value=${100}
# ##    ...    gnb_id=${WB_CQI_256TBL_5QI1_CQI15['gnb_id']}
# ##    Check gnb counter as expected_value
# ##    ...    counter_id=${WB_CQI_64TBL_5QI1_CQI15['counter_id']}
# ##    ...    dic_path=${WB_CQI_64TBL_5QI1_CQI15['dic_path']}
# ##    ...    expected_value=${0}
# ##    ...    gnb_id=${WB_CQI_64TBL_5QI1_CQI15['gnb_id']}
# #
# ####20230831 TL029 Config SCF change 2UL2DL to 2UL4DL,radiao condition change,
# ####UE not reach to CQI 15,so change counter to 12 and 13
# #    Check gnb counter greater expected_value
# #    ...    counter_id=${WB_CQI_256TBL_5QI1_CQI12['counter_id']}
# #    ...    dic_path=${WB_CQI_256TBL_5QI1_CQI12['dic_path']}
# #    ...    expected_value=${100}
# #    ...    gnb_id=${WB_CQI_256TBL_5QI1_CQI12['gnb_id']}
# #    Check gnb counter as expected_value
# #    ...    counter_id=${WB_CQI_64TBL_5QI1_CQI12['counter_id']}
# #    ...    dic_path=${WB_CQI_64TBL_5QI1_CQI12['dic_path']}
# #    ...    expected_value=${0}
# #    ...    gnb_id=${WB_CQI_64TBL_5QI1_CQI12['gnb_id']}
# ####20231114 TL029 after move UE,only trigger CQI12
# ##    Check gnb counter greater expected_value
# ##    ...    counter_id=${WB_CQI_256TBL_5QI1_CQI13['counter_id']}
# ##    ...    dic_path=${WB_CQI_256TBL_5QI1_CQI13['dic_path']}
# ##    ...    expected_value=${100}
# ##    ...    gnb_id=${WB_CQI_256TBL_5QI1_CQI13['gnb_id']}
# ##    Check gnb counter as expected_value
# ##    ...    counter_id=${WB_CQI_64TBL_5QI1_CQI13['counter_id']}
# ##    ...    dic_path=${WB_CQI_64TBL_5QI1_CQI13['dic_path']}
# ##    ...    expected_value=${0}
# ##    ...    gnb_id=${WB_CQI_64TBL_5QI1_CQI13['gnb_id']}
# 
# Check counter for 001
# #    Check gnb counter greater expected_value
# #    ...    counter_id=${WB_CQI_256TBL_5QI1_CQI15['counter_id']}
# #    ...    dic_path=${WB_CQI_256TBL_5QI1_CQI15['dic_path']}
# #    ...    expected_value=${100}
# #    ...    gnb_id=${WB_CQI_256TBL_5QI1_CQI15['gnb_id']}
# #    Check gnb counter as expected_value
# #    ...    counter_id=${WB_CQI_64TBL_5QI1_CQI15['counter_id']}
# #    ...    dic_path=${WB_CQI_64TBL_5QI1_CQI15['dic_path']}
# #    ...    expected_value=${0}
# #    ...    gnb_id=${WB_CQI_64TBL_5QI1_CQI15['gnb_id']}
# 
# ###20230831 TL029 Config SCF change 2UL2DL to 2UL4DL,radiao condition change,
# ###UE not reach to CQI 15,so change counter to 12 and 13
#     Check gnb counter greater expected_value
#     ...    counter_id=${Trunk_WB_CQI_256TBL_5QI1_CQI12['counter_id']}
#     ...    dic_path=${Trunk_WB_CQI_256TBL_5QI1_CQI12['dic_path']}
#     ...    expected_value=${100}
#     ...    gnb_id=${Trunk_WB_CQI_256TBL_5QI1_CQI12['gnb_id']}
#     Check gnb counter as expected_value
#     ...    counter_id=${Trunk_WB_CQI_64TBL_5QI1_CQI12['counter_id']}
#     ...    dic_path=${Trunk_WB_CQI_64TBL_5QI1_CQI12['dic_path']}
#     ...    expected_value=${0}
#     ...    gnb_id=${Trunk_WB_CQI_64TBL_5QI1_CQI12['gnb_id']}
# ###20231114 TL029 after move UE,only trigger CQI12
# #    Check gnb counter greater expected_value
# #    ...    counter_id=${WB_CQI_256TBL_5QI1_CQI13['counter_id']}
# #    ...    dic_path=${WB_CQI_256TBL_5QI1_CQI13['dic_path']}
# #    ...    expected_value=${100}
# #    ...    gnb_id=${WB_CQI_256TBL_5QI1_CQI13['gnb_id']}
# #    Check gnb counter as expected_value
# #    ...    counter_id=${WB_CQI_64TBL_5QI1_CQI13['counter_id']}
# #    ...    dic_path=${WB_CQI_64TBL_5QI1_CQI13['dic_path']}
# #    ...    expected_value=${0}
# #    ...    gnb_id=${WB_CQI_64TBL_5QI1_CQI13['gnb_id']}