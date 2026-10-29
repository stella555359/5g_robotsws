# *** Settings ***
# Documentation      author: Ji Jian
# ...                contact: jian.ji@nokia-sbell.com
# ...                Group: HGZ_SG2
# Force Tags         5G_RRM
# ...    PY36
# 
# Suite Setup    Common Suite Setup for COAM
# Suite Teardown    Common Suite Teardown for COAM
# 
# Resource           Resources/5GC001655_common_keyword.robot
# 
# *** Variables ***
# ${scf_file}                   common_4x4.xml
# ${data_transfer_dl}           1200M
# ${data_transfer_ul}           200M
# ${Expected_Throughput_DL}     200
# ${Expected_Throughput_UL}     20
# @{abbr_list}                 actDl256Qam              actDlDataDmrsFdm                               dlMimoMode
# @{filter_param_list}    Activate 256QAM in DL    Activate downlink data and DMRS FDM             Downlink MIMO Mode
# @{parameter_case1}                true                      false                      4x4 or 4x2 Closed Loop Spatial Multiplexing
# @{parameter_case2}                false                     true                       4x4 or 4x2 Closed Loop Spatial Multiplexing
# @{parameter_case3}                true                      true                       4x4 or 4x2 Closed Loop Spatial Multiplexing
# &{5GC001347_A_001}             SBTS22R2=QC_203076    SBTS22R3=QC_402750    SBTS22R4=QC_361888    SBTS23R1=QC_56888
# 
# *** Test Cases ***
# [1]5GC001116_0ms_case1_actDl256Qam_TRUE_dlMimoMode_4X4_actDlDataDmrsFdm_FALSE_Bandwidth_60M
#     [Tags]     5GC001178     CRT_22R3    ${5GC001347_A_001['${program}']}
#     [Setup]     Case Setup
#     Create Update Parameter List    value_list=${parameter_case1}
#     Run Keyword And Continue On Failure     COAM Update several parameters via webUI
#     ...    parameters_to_update_via_webui=${PARAMS_list}
#     ...    download_dir=${TS_CASE_LOG_PATH}
#     ...    is_need_to_check_validation_errors=True
#     ...    is_gnb_restrat_after_online_modify=True
#     Start DLUL traffic and Capture BIP     data_transfer_dl=${data_transfer_dl}
#     ...    data_transfer_ul=${data_transfer_ul}
#     ...    Expected_Throughput_DL=${Expected_Throughput_DL}
#     ...    Expected_Throughput_UL=${Expected_Throughput_UL}
#     ...    bip_log=${bip_log}
#     [Teardown]     Case Teardown
# 
# [2]5GC001116_0ms_case2_actDl256Qam_FALSE_dlMimoMode_2X2_actDlDataDmrsFdm_TRUE_Bandwidth_60M
#     [Tags]     5GC001178     CRT_22R3
#     [Setup]     Case Setup
#     Create Update Parameter List    value_list=${parameter_case2}
#     Run Keyword And Continue On Failure     COAM Update several parameters via webUI
#     ...    parameters_to_update_via_webui=${PARAMS_list}
#     ...    download_dir=${TS_CASE_LOG_PATH}
#     ...    is_need_to_check_validation_errors=True
#     ...    is_gnb_restrat_after_online_modify=True
#     Start DLUL traffic and Capture BIP     data_transfer_dl=${data_transfer_dl}
#     ...    data_transfer_ul=${data_transfer_ul}
#     ...    Expected_Throughput_DL=${Expected_Throughput_DL}
#     ...    Expected_Throughput_UL=${Expected_Throughput_UL}
#     ...    bip_log=${bip_log}
#     [Teardown]     Case Teardown
# 
# [3]5GC001116_0ms_case3_actDl256Qam_TRUE_dlMimoMode_2X2_actDlDataDmrsFdm_TRUE_Bandwidth_60M
#     [Tags]     5GC001178     CRT_22R3
#     [Setup]     Case Setup
#     Create Update Parameter List    value_list=${parameter_case3}
#     Run Keyword And Continue On Failure     COAM Update several parameters via webUI
#     ...    parameters_to_update_via_webui=${PARAMS_list}
#     ...    download_dir=${TS_CASE_LOG_PATH}
#     ...    is_need_to_check_validation_errors=True
#     ...    is_gnb_restrat_after_online_modify=True
#     Start DLUL traffic and Capture BIP     data_transfer_dl=${data_transfer_dl}
#     ...    data_transfer_ul=${data_transfer_ul}
#     ...    Expected_Throughput_DL=${Expected_Throughput_DL}
#     ...    Expected_Throughput_UL=${Expected_Throughput_UL}
#     ...    bip_log=${bip_log}
#     [Teardown]     Case Teardown
