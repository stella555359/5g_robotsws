# *** Settings ***
# #Suite Setup          Run Keywords    RJIO Suite Setup    AND    Commissioning SCF And Check On Air    scf_path=${Golden_SCF_Path}
# Suite Setup          RJIO Suite Setup
# Suite Teardown       SISO Coam Suite Teardown
# Test Setup           SISO Coam Test Setup
# Test Teardown        Run Keywords    save full snapshot    AND    RJIO Test Teardown
# 
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
# Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
# Resource    ${BASIC_PATH_5G}/General_SiSo_RF_module_power_reset.robot
# Resource    ${BASIC_PATH_5G}/General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot.robot
# Resource    ${BASIC_PATH_5G}/General_SiSo_RF_module_reset_from_GUI.robot
# Resource    ${BASIC_PATH_5G}/General_SiSo_Auto_BTS_site_reset.robot
# Resource    ./Resources/Rjio_keywords.robot
# Library    ./TestData/Rjio_variables.py
# 
# 
# Documentation
# ...    Author: Melinda
# ...    Contact: meinda.gao@nokia-sbell.com
# ...    squad group:SG_08
# ...    E2E Rjio
# 
# Force Tags    PY36
# 
# 
# *** Variables ***
# @{cell_id63}    ${63}
# 
# @{PA_Port_list_15}    ${15}
# @{PA_Port_list_5_6}    ${5}  ${6}
# @{PA_Port_list_1_2}    ${1}  ${2}
# @{PA_Port_list_8_11_12_13_14}    ${8}  ${11}  ${12}  ${13}  ${14}
# @{PA_Port_list_11_12_13_14}    ${11}  ${12}  ${13}  ${14}
# 
# ${CRT_flag}    ${True}
# *** Test Cases ***
# [1]Rjio_E2E_35_Power_Saving_BWP_Switch
#     PowerSaving BWP switch    ue_index=2
# 
# [1]Rjio_E2E_03_Power_Reset_Rf
#     FOR   ${index}   IN RANGE   0    1
#         General_SiSo_RF_module_reset_from_GUI
#     END
# 
# [1]Rjio_E2E_05_Radio_Lock_Unlock
#     FOR   ${index}   IN RANGE   0    1
#         RU_lock_unlock_execute    CRT_flag=${CRT_flag}
#     END
# 
# [1]Rjio_E2E_06_Cell_Block_Unblock
#     FOR   ${index}   IN RANGE   0    1
#         cell_block_unblock_execute    CRT_flag=${CRT_flag}
#     END
# 
# [1]Rjio_E2E_19_Beamforming_Calibration
#     FOR   ${index}   IN RANGE   0    1
#         General_SiSo_Beamforming_calibration_ASOE
#         check_unexpected_alarms
#     END
# 
# [1]Rjio_E2E_21_Snapshot_Content_Compare
#     FOR   ${index}   IN RANGE   0    1
#         General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
#         check_unexpected_alarms
#     END
# 
# [1]Rjio_E2E_24_Site_Reset_With_L3_Call
#     FOR   ${index}   IN RANGE   0    1
#         Site_reset_with_call    CRT_flag=${CRT_flag}
#     END
# 
# [1]Rjio_E2E_74_Cell_Lock_Unlock
#     Rjio_E2E_74_Cell_Lock_Unlock    CRT_flag=${CRT_flag}
# 
# [1]Rjio_E2E_67_Mobility_UE_based_ANR_for_EUTRA_Neighbor
#     Rjio_E2E_67_Mobility_UE_based_ANR_for_EUTRA_Neighbor
# 
# [1]Rjio_E2E_64_Mobility_IRAT_Data_HO_With_N26
#     Rjio_E2E_67_Mobility_UE_based_ANR_for_EUTRA_Neighbor-64
# 
# [1]Rjio_E2E_63_Mobility_UE_based_ANR
#     Rjio_E2E_63_Mobility_UE_based_ANR_for_NR_Neighbor-34    check_HO=${False}    ue_index=${2}
# 
# [1]Rjio_E2E_34_Intra-Frequency_And_Inter-Gnb_Ho_Ng_Based_With_Feature_IWK
#     Rjio_E2E_63_Mobility_UE_based_ANR_for_NR_Neighbor-34    check_HO=${True}    ue_index=${2}
# 
# [1]Rjio_E2E_11_Commission_Netact
#     Rjio_E2E_11_Parameter_Modification_Netact
# 
# #[1]Rjio_E2E_10_SW_Upgrade
# #    FOR   ${index}   IN RANGE   0    1
# #        Perform_SW_rollback
# #        Perform_SW_rollback
# #    END
# 
# #[1]Rjio_E2E_16_Prach_Index_190_And_L3_Call
# #    FOR   ${index}   IN RANGE   0    1
# #        TDD_prach_index_190_L3_call
# #    END
# 
# #[1]Rjio_E2E_22_Initiate_Sfp_Monitoring_From_Webem_For_Ru_Dynamic_Data
# #    FOR   ${index}   IN RANGE   0    1
# #        Rjio_Initiate_SFP_Monitoring_from_WebEM_for_RU(dynamic_data)
# #    END
# 
# #[1]Rjio_E2E_23_PTP_Failure_Between_SM_And_RM_Reference
# #    FOR   ${index}   IN RANGE   0    1
# #        PTP failure between SM and RM reference
# #    END
# 
# *** Keywords ***
