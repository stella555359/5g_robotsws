# *** Settings ***
# Suite Setup          Run Keywords    SISO Coam Suite Setup
# #...                  AND  replace_commission_scf_to_current_bts_scf
# Suite Teardown       SISO Coam Suite Teardown
# Test Setup           SISO Coam Test Setup
# Test Teardown        run keyword and ignore error    SISO Coam Test Teardown    is_case_teardown=False
# 
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
# Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
# Resource    ${BASIC_PATH_5G}/General_SiSo_RF_module_power_reset.robot
# Resource    ${BASIC_PATH_5G}/General_BTS_startup_management.robot
# Resource    ${BASIC_PATH_5G}/General_SiSo_Auto_BTS_site_reset.robot
# Resource    ${BASIC_PATH_5G}/General_SiSo_Commissioning_BTS_Template_Commissioning.robot
# Resource    Resources/Bharti_keywords.robot
# 
# 
# Documentation
# ...    Author: Wu Fangmin
# ...    Contact: fangmin.wu@nokia-sbell.com
# ...    squad group:PZ3_SG3
# 
# Force Tags    PY36
# 
# 
# *** Variables ***
# @{cell_id63}    ${63}
# ${if_commissioning}    False
# *** Test Cases ***
# reset_RF_by_power
#     FOR   ${index}   IN RANGE   0    1
#         Get initial Alarm and fault
#         General_SiSo_RF_module_power_reset
#         sleep    30s
#         Adjust HBTE ATT Values    ${ATTENUATION_VALUE_default}
#         Make call on NR cell
#         Run Keyword And Continue On Failure    Check UE DL and UL peak TP
#         ${fault_id_list_new}      Get Alarm Info from WebUI      timeout=10s
#         ${fault_id_list_new_length}    Get Length    ${fault_id_list_new}
# 	    Run keyword and continue on failure    should be true    ${fault_id_list_new_length}<=${fault_id_list_0_length}
#     END
# #
# reset_site_power
#     FOR   ${index}   IN RANGE   0    1
#         Get initial Alarm and fault
#         General_BTS_startup_management
#         sleep    30s
#         Make call on NR cell
#         Run Keyword And Continue On Failure    Check UE DL and UL peak TP
#         ${fault_id_list_new}      Get Alarm Info from WebUI      timeout=10s
#         ${fault_id_list_new_length}    Get Length    ${fault_id_list_new}
# 	    Run keyword and continue on failure    should be true    ${fault_id_list_new_length}<=${fault_id_list_0_length}
# 
#     END
# #
# reset_site_WeBUI
#     FOR   ${index}   IN RANGE   0    1
#         Get initial Alarm and fault
#         General_SiSo_Auto_BTS_site_reset
#         sleep    30s
#         Make call on NR cell
#         Run Keyword And Continue On Failure    Check UE DL and UL peak TP
#         ${fault_id_list_new}      Get Alarm Info from WebUI      timeout=10s
#         ${fault_id_list_new_length}    Get Length    ${fault_id_list_new}
# 	    Run keyword and continue on failure    should be true    ${fault_id_list_new_length}<=${fault_id_list_0_length}
#     END
# #
# RU_lock_unlock
#    FOR   ${index}   IN RANGE   0    1
#         RU_lock_unlock
#    END
# #
# cell_block_unblock
#     FOR   ${index}   IN RANGE   0    1
#         cell_block_unblock_execute_new
#     END
# 
# 
# Continuous_collect_snapshot_check_unexpected_alarms
#     FOR   ${index}   IN RANGE   0    3
#         Get initial Alarm and fault
#         ${snapshot_zip_file_full}    Save Full Snapshot
#         Make call on NR cell
#         Run Keyword And Continue On Failure    Check UE DL and UL peak TP
#         ${fault_id_list_new}      Get Alarm Info from WebUI      timeout=10s
#         ${fault_id_list_new_length}    Get Length    ${fault_id_list_new}
# 	    Run keyword and continue on failure    should be true    ${fault_id_list_new_length}<=${fault_id_list_0_length}
#     END
# 
# conmission_scf
#     FOR   ${index}   IN RANGE   0    1
#         Get initial Alarm and fault
#         General_SiSo_Commissioning_BTS_Template_Commissioning
#         Wait Until Keyword Succeeds    20min    20s    Verify all cells should be onair    connection=GNB_OAM
#         ${fault_id_list_new}      Get Alarm Info from WebUI      timeout=10s
#         ${fault_id_list_new_length}    Get Length    ${fault_id_list_new}
# 	    Run keyword and continue on failure    should be true    ${fault_id_list_new_length}<=${fault_id_list_0_length}
#     END
# #   
# #
# #reset_RF_by_WEBUI
# #    FOR   ${index}   IN RANGE   0    1
# #        General_SiSo_RF_module_reset_from_GUI
# #    END
# 
# #PTP_Failure
# #    FOR   ${index}   IN RANGE   0    10
# #        5GC000560_eLLF_PTP_Failure
# #    END
# #
# #Collect_RFSW_logs_from_RU_into_BTS_Snapshot
# #    FOR   ${index}   IN RANGE   0    1
# #        General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
# #        check_unexpected_alarms
# #    END
# #
# ##Continuous_collect_RFSW_log_check_unexpected_alarms
# ##    FOR   ${index}   IN RANGE   0    10
# ##        collect_RFSW_log_Continuous_check_unexpected_alarms
# ##    END
# #
# #Beamforming_calibration
# #    FOR   ${index}   IN RANGE   0    1
# #        General_SiSo_Beamforming_calibration_ASOE
# #        check_unexpected_alarms
# #    END
# #
# #SW_upgrade
# #    FOR   ${index}   IN RANGE   0    1
# #        Perform_SW_rollback
# #        Perform_SW_rollback
# #    END
# #
# #Rjio_E2E_18_Radio_Unit_Restart_After_The_Software_Upgrade(_Minor)
# #    FOR   ${index}   IN RANGE   0    1
# #        Rjio_E2E_18_Radio_Unit_Restart_After_The_Software_Upgrade(_Minor)
# #    END
# #
# #Initiate_SFP_Monitoring_from_WebEM_for_RU(dynamic_data)
# #    FOR   ${index}   IN RANGE   0    1
# #        Rjio_Initiate_SFP_Monitoring_from_WebEM_for_RU(dynamic_data)
# #    END
# #
# #PRACH190_L3_CALL
# #    FOR   ${index}   IN RANGE   0    1
# #        prach_index_190_L3_call_cell63
# #    END
# #
# #eLLF_PTP_Failure_with_call
# #    FOR   ${index}   IN RANGE   0    1
# #        PTP failure between SM and RM reference
# #    END
# #
# #Reset_site_WebEM_with_call
# #    FOR   ${index}   IN RANGE   0    10
# #        Site_reset_with_call
# #    END
# #
# ##Rjio_E2E_25_Data_Call_Dl_Ul_Throughput_Check
# ##    Rjio_E2E_25_Data_Call_Dl_Ul_Throughput_Check
# 
# *** Keywords ***
