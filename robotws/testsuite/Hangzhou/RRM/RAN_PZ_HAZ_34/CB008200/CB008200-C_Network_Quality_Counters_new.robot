# *** Settings ***
# Documentation
# ...    author: Shi Ming
# ...    contact: ming.shi@nokia-sbell.com
# ...    squal group: SG03
# ...    feature: CB008200-C
# 
# Force Tags  CA_5G_RRM    RAN_5G    RAN_5G_TDD    CLOUD_5G_CLASSICAL_ANDROID_ASIKL_ABILB1_AAHF_RF_SHARING_ENB
# ...         STATE_SW_UPLOADED    PY36
# Suite Setup    Run Keywords    Setup Env for test for cell on air    AND
# ...                            Common Suite Setup for COAM    AND
# ...                            Common UE parameter setup
# 
# Suite Teardown    Run Keyword    robot_common_operations.Common Suite Teardown
# 
# 
# Resource     Resources/CB008200_common_keywords_new.robot
# Variables    Resources/CB008200_variables_new.py
# 
# 
# *** Variables ***
# ${log_name_C_001}    log_name_C_001.pcap
# 
# ${ue_type}    samsung
# @{ues_type}    huawei    samsung
# 
# ${enb_instance}     ${tl.enbs[0].instance_id}
# @{enb_dist_name}    MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-1
# @{enb_para}    administrativeState
# @{enb_value}    unlocked    locked
# 
# @{PA_list}    ${0}    ${30}    ${45}    ${127}
# 
# *** Test Cases ***
# [1]CB008200_5G_C_Performance_Measurements_002_CQI_counters_when_only_256QAM_table_configuted
#     [Documentation]    PM Counter update for VoNR Wideband CQI per cell for cloud and classical gNB.
#     [Tags]    CB008200-C    CRT_TRUNK    CRT_22R2    SBTS00    CRT_UTE    CRT_22R3    CRT_22R4
#     [Timeout]    1 hour
#     [Setup]    robot_common_operations.Common Case Setup
#     Online modify parmeters    parameters_to_update=${PARAM_8200_C_001}
#     Comment    set gnb1 cell2 PA to 0
#     Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=@{PA_list}[3]    gnb1_cell2_value=@{PA_list}[0]
#     ...    gnb2_cell1_value=@{PA_list}[3]    enb_cell1_value=@{PA_list}[3]
#     Step1: UE attach    ue_type=@{ues_type}[1]    ue_index=${2}
#     Run Keyword If    '${enb_instance}'=='@{diffTL_enb_ID}[1]'    Sleep    1s
#     ...    ELSE    make WA with Samsung S21    ue_index=${2}
#     Start capture gNB log on master    filename=${log_name_C_001}
#     Run Keyword If    '${enb_instance}'=='@{diffTL_enb_ID}[1]'    Step2: UE setup VoNR call    ue_index=${2}
#     ...    ELSE    Step2: Samsung UE setup VoNR call    ue_index=${2}
#     sleep    20s
#     check voice call status    status=${2}    ue_index=${2}
#     Stop and download Logs on gNB on master    filename=${log_name_C_001}
#     Prepare with PM counter time to caculate    period=start
#     sleep    5m
#     Prepare with PM counter time to caculate    period=end
#     Check wireshark log for 001
#     Check counter for 001
#     [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown    AND
#     ...    Run Keyword If    '${enb_instance}'=='@{diffTL_enb_ID}[1]'    Step3: UE hang up VoNR call    ue_index=${2}
#     ...    ELSE    Step3: Samsung UE hang up VoNR call    ue_index=${2}    AND
#     ...    sleep    10s    AND
#     ...    check voice call status    status=${0}    ue_index=${2}    AND
#     ...    Run Keyword If    '${enb_instance}'=='@{diffTL_enb_ID}[1]'    Sleep    1s
#     ...    ELSE    make WA with Samsung S21    ue_index=${2}    AND
#     ...    Step4: Detach UE    ue_type=@{ues_type}[1]    ue_index=${2}    AND
#     ...    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_C_001}    AND
#     ...    Check hanging resource for gnb    gnb_ips=${gnb_ips}    AND
#     ...    Online modify parmeters    parameters_to_update=${PARAM_8200_recover_C_001}    AND
#     ...    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=@{PA_list}[0]    gnb1_cell2_value=@{PA_list}[0]
#     ...    gnb2_cell1_value=@{PA_list}[0]    enb_cell1_value=@{PA_list}[0]    AND
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
# Check counter for 001
# #    Add PM counter list for case    pm_counters=${WB_CQI_64TBL_5QI1_CQI}
# #    Get greater than all counters    expected_value=${1}
# #    Add PM counter list for case    pm_counters=${WB_CQI_256TBL_5QI1_CQI}
# #    Get equal than all counters    expected_value=${0}
#     Check gnb counter greater expected_value
#     ...    counter_id=${WB_CQI_256TBL_5QI1_CQI15['counter_id']}
#     ...    dic_path=${WB_CQI_256TBL_5QI1_CQI15['dic_path']}
#     ...    expected_value=${100}
#     ...    gnb_id=${WB_CQI_256TBL_5QI1_CQI15['gnb_id']}
#     Check gnb counter as expected_value
#     ...    counter_id=${WB_CQI_64TBL_5QI1_CQI15['counter_id']}
#     ...    dic_path=${WB_CQI_64TBL_5QI1_CQI15['dic_path']}
#     ...    expected_value=${0}
#     ...    gnb_id=${WB_CQI_64TBL_5QI1_CQI15['gnb_id']}
