# #*** Settings ***
# #Suite Setup          SBTS Suite Setup
# #Suite Teardown       SBTS Suite Teardown
# #Test Setup           SBTS Test Setup
# #Test Teardown        SBTS Test Teardown
# #Test Timeout         12h
# #
# #Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_LTE.robot
# #Resource    ${BASIC_PATH_COMMON}/SBTS_Setup_And_Teardown.robot
# #Resource    ${BASIC_PATH_COMMON}/General_KPI_Test_Case.robot
# #Resource    ${BASIC_PATH_LTE}/General_SiSo_LED_states_management_basic.robot
# #Resource    ${BASIC_PATH_LTE}/General_SiSo_Fault_1900_EFaultId_FrConfiguringFailed.robot
# #Resource    ${BASIC_PATH_LTE}/General_SiSo_Commissioning_BTS_Template_Commissioning.robot
# #Resource    ${BASIC_PATH_LTE}/5GC000560_eLLF_PTP_Failure.robot
# #Resource    ${BASIC_PATH_LTE}/5GC000561_eCPRI_sync_generic_startup_at_RAU.robot
# #Resource    ${BASIC_PATH_LTE}/5GC000561_eCPRI_sync_counters.robot
# #Resource    ${BASIC_PATH_LTE}/5GC000560_eCPRI_sync_generic_startup_at_RU.robot
# #Resource    ${BASIC_PATH_LTE}/General_SiSo_Configuration_BPF_and_TargetBD_support_for_RF_module.robot
# #Resource    ${BASIC_PATH_LTE}/General_SiSo_SOAP_RP1_verification.robot
# #Resource    ${BASIC_PATH_LTE}/Manual_SiSo_REC_Radio_Module_power_reset.robot
# #Resource    ${BASIC_PATH_LTE}/Manual_SiSo_SM_LTE_Cell_block_unblock.robot
# #Resource    ${BASIC_PATH_LTE}/Manual_SiSo_SM_RF_Module_lock_unlock.robot
# #Resource    ${BASIC_PATH_LTE}/Manual_SiSo_TEST_Black_Box.robot
# #Resource    ${BASIC_PATH_LTE}/Manual_SiSo_SM_BTS_Site_Reset.robot
# #Resource    ${BASIC_PATH_LTE}/General_SiSo_RF_alarms_with_recovery.robot
# #Resource    ${BASIC_PATH_LTE}/General_SiSo_RF_alarms_without_recovery.robot
# #Resource    ${BASIC_PATH_LTE}/General_SiSo_RU_module_reset_from_GUI_with_L3call.robot
# #Resource    ${BASIC_PATH_COMMON}/General_Power_Meter_counter_update_for_energy_consumption.robot
# #Resource    ${BASIC_PATH_LTE}/General_SiSo_Peak_with_Given_Information.robot
# #Resource    ${BASIC_PATH_LTE}/General_SiSo_Snapshot_Showing_Radio_Last_Reset_Cause.robot
# #Resource    ${BASIC_PATH_LTE}/General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot_enhance.robot
# #Resource    ${BASIC_PATH_LTE}/KPI/KPI_17_Manual_block_unblock_cell_duration.robot
# #Resource    ${BASIC_PATH_LTE}/General_SiSo_Carrier_Aggregation_with_contiguous_carriers.robot
# #Resource    ${BASIC_PATH_LTE}/General_SiSo_Beamforming_Calibration_Cal_Software_Component_Operation_Verification.robot
# #Resource    ${BASIC_PATH_LTE}/General_SiSo_RF_temperature_management_FrTempHigh.robot
# #Resource    ${BASIC_PATH_LTE}/General_SiSo_MU_MIMO_DL_8_layer_with_Tapreing.robot
# #Resource    ${BASIC_PATH_LTE}/General_SiSo_Activate_RuProtectEnabled_from_RuProtectDisabled_via_WebEM.robot
# #Resource    ${BASIC_PATH_LTE}/SiSo_Testability_E-UTRA_Test_Model_1.robot
# #
# #Documentation
# #...    Author:zhihao shi
# #...    contact:zhihao.shi@nokia-sbell.com
# #...    squad group:SG_04
# #...    Feature SRAN in 22R3 program
# #
# #Force Tags            5G_RAN    5G_RAN_TDD    RAN_5G_TDD    RAN_5G    STATE_SW_UPLOADED   CLOUD_5G_CLASSICAL_SA_ASIBL_ABIOB1_AQQA
# #...    PY36
# #
# #*** Variables ***
# #
# #*** Test Cases ***
# ##Tl318
# #[1]CB007499_SR_A_a_SISO_AQQA_01_General_SiSo_Configuration_BPF_and_TargetBD_support_for_RF_module
# #    [Tags]    CRT_TRUNK
# #    General_SiSo_Configuration_BPF_and_TargetBD_support_for_RF_module
# #
# #[1]CB007499_SR_A_c_SISO_AQQA_02_General_SiSo_RU_module_reset_from_GUI
# #    [Tags]    CRT_TRUNK
# #    General_SiSo_RF_module_reset_from_GUI
# #
# #[1]CB007499_SR_A_d_SISO_AQQA_02_Manual_SiSo_SM_RF_Module_lock_unlock
# #    [Tags]    CRT_TRUNK
# #    Manual_SiSo_SM_RF_Module_lock_unlock
# #
# #[1]CB007499_SR_A_b_SISO_AQQA_02_Manual_SiSo_SM_LTE_Cell_block_unblock
# #    [Tags]    CRT_TRUNK
# #    Manual_SiSo_SM_LTE_Cell_block_unblock
# #
# #[1]CB007499_SR_A_a_SISO_AQQA_11_5GC000560_eCPRI_PTP_Failure
# #    [Tags]    CRT_TRUNK
# #    5GC000560_eLLF_PTP_Failure
# #
# #[1]CB007499_SR_A_a_SISO_AQQA_14_General_SiSo_LED_states_management_basic
# #    [Tags]    CRT_TRUNK
# #    General_SiSo_LED_states_management_basic
# #
# #[1]CB007499_SR_A_c_SISO_AQQA_11_General_SiSo_RF_alarms_with_recovery
# #    [Tags]    CRT_TRUNK
# #    General_SiSo_RF_alarms_with_recovery
# #
# #[1]CB007499_SR_A_c_SISO_AQQA_12_General_SiSo_RF_alarms_without_recovery
# #    [Tags]    CRT_TRUNK
# #    General_SiSo_RF_alarms_without_recovery
# #
# #[1]CB007499_SR_A_c_SISO_AQQA_03_Manual_SiSo_SM_BTS_Site_Reset
# #    [Tags]    CRT_TRUNK
# #    Manual_SiSo_SM_BTS_Site_Reset
# #
# #[1]CB007499_SR_A_c_SISO_AQQA_18_KPI_17_Manual_block_unblock_cell_duration
# #    [Timeout]    4h
# #    Set Log Level    INFO
# #    General_KPI_Test_Case    case_name=KPI_17_Manual_block_unblock_cell_duration    times=${10}    pass=${10}
# #
# #[1]CB007499_SR_A_c_SISO_AQQA_13_General_SiSo_Power_Meter_counter_update_for_energy_consumption
# #    [Tags]    CRT_TRUNK
# #    General_Power_Meter_counter_update_for_energy_consumption
# #
# #[1]CB007499_SR_A_a_L3int_AQQA_02_L3call_1CC_TM3
# #    General_SiSo_Peak_with_Given_Information    mimo_mode=TM3    frame_structure=2/7    prach_index=4
# #    ...    dl_tp=135.7    ul_tp=11.6    target_avg_percent=0.95    duration=180
# #
# #[1]CB007499_SR_A_c_L3int_AQQA_02_L3call_1CC_TM7
# #    General_SiSo_Peak_with_Given_Information    mimo_mode=TM7    frame_structure=2/7    prach_index=4
# #    ...    dl_tp=61.6    ul_tp=12    target_avg_percent=0.95    duration=180
# #
# #[1]CB007499_SR_A_a_SISO_AQQA_23_General_SiSo_Snapshot_Showing_Radio_Last_Reset_Cause
# #    [Tags]    CRT_TRUNK
# #    General_SiSo_Snapshot_Showing_Radio_Last_Reset_Cause
# #
# #[1]CB007499_SR_A_a_SISO_AQQA_16_General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
# #    [Tags]    CRT_TRUNK
# #    General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot_enhance
# #
# ## suggest we run this case in TL308
# #[1]CB007499_SR_A_c_RRM_AQQA_01_Different_frame_structeres_configuraiton_without_eNB_timing_shifter
# #    General_SiSo_Peak_with_Given_Information    mimo_mode=TM8    frame_structure=2/5    prach_index=3
# #    ...    timing_shifter=OFF
# #    ...    dl_tp=105.5    ul_tp=11.6    target_avg_percent=0.95    duration=180
# #    General_SiSo_Peak_with_Given_Information    mimo_mode=TM8    frame_structure=2/5    prach_index=4
# #    ...    timing_shifter=OFF
# #    ...    dl_tp=105.5    ul_tp=11.6    target_avg_percent=0.95    duration=180
# #    General_SiSo_Peak_with_Given_Information    mimo_mode=TM8    frame_structure=2/5    prach_index=6
# #    ...    timing_shifter=OFF
# #    ...    dl_tp=105.5    ul_tp=10.5    target_avg_percent=0.95    duration=180
# #    General_SiSo_Peak_with_Given_Information    mimo_mode=TM8    frame_structure=2/6    prach_index=3
# #    ...    timing_shifter=OFF
# #    ...    dl_tp=120.7    ul_tp=11.6    target_avg_percent=0.95    duration=180
# #    General_SiSo_Peak_with_Given_Information    mimo_mode=TM8    frame_structure=2/6    prach_index=4
# #    ...    timing_shifter=OFF
# #    ...    dl_tp=120.7    ul_tp=11.6    target_avg_percent=0.95    duration=180
# #    General_SiSo_Peak_with_Given_Information    mimo_mode=TM8    frame_structure=2/6    prach_index=6
# #    ...    timing_shifter=OFF
# #    ...    dl_tp=120.7    ul_tp=10.5    target_avg_percent=0.95    duration=180
# #    General_SiSo_Peak_with_Given_Information    mimo_mode=TM8    frame_structure=2/7    prach_index=3
# #    ...    timing_shifter=OFF
# #    ...    dl_tp=123.2    ul_tp=11.6    target_avg_percent=0.95    duration=180
# #    General_SiSo_Peak_with_Given_Information    mimo_mode=TM8    frame_structure=2/7    prach_index=4
# #    ...    timing_shifter=OFF
# #    ...    dl_tp=123.2    ul_tp=11.6    target_avg_percent=0.95    duration=180
# #    General_SiSo_Peak_with_Given_Information    mimo_mode=TM8    frame_structure=2/7    prach_index=6
# #    ...    timing_shifter=OFF
# #    ...    dl_tp=123.2    ul_tp=10.5    target_avg_percent=0.95    duration=180
# #
# #[1]CB007499_SR_A_c_RRM_AQQA_02_Different_frame_structeres_configuraiton_with_eNB_timing_shifter
# #    run keyword and continue on failure    General_SiSo_Peak_with_Given_Information    mimo_mode=TM8    frame_structure=2/7    prach_index=4
# #    ...    timing_shifter=ON
# #    ...    dl_tp=123.2    ul_tp=11.6    target_avg_percent=0.95    duration=180
# #    Site General Modify via Webem    timing_shifter=OFF
# #
# #[1]CB007499_SR_A_d_RRM_AQQA_01_Peak_throughput_with_DL_64QAM_and_UL_64QAM_Modulation
# #    run keyword and continue on failure    General_SiSo_Peak_with_Given_Information    mimo_mode=TM8    frame_structure=2/7    prach_index=4
# #    ...    scheme_dl=64QAM
# #    ...    dl_tp=88.08    ul_tp=11.6    target_avg_percent=0.95    duration=180
# #    Site General Modify via Webem    timing_shifter=256QAM
# #
# #[1]CB007499_SR_A_c_SISO_AQQA_25_General_SiSo_Beamforming_CalibrationCal_Software_Component_Operation_Verification
# #    [Tags]    CRT_TRUNK
# #    General_SiSo_Beamforming_calibration_Cal_Software_Component_Operation_Verification
# #
# #[1]CB007499_SR_A_c_SISO_AQQA_33_BS_RF__RF_temperature_management_FrTempHigh
# #    [Tags]    CRT_TRUNK
# #    General_SiSo_RF_temperature_management_FrTempHigh
# #
# #[1]CB007499_SR_A_a_SISO_AQQA_19_General_SiSo_Activate_RuProtectEnabled_from_RuProtectDisabled_via_WebEM
# #    [Tags]    CRT_TRUNK
# #    General_SiSo_Activate_RuProtectEnabled_from_RuProtectDisabled_via_WebEM
# #
# #[1]CB007499_SR_A_b_SISO_AQQA_04_SiSo_Testability_E-UTRA_Test_Model_1
# #    SiSo_Testability_E-UTRA_Test_Model_1
# #
# #[1]CB007499_SR_A_d_RRM_AQQA_12_2CC_Carrier_Aggregation_with_contiguous_carriers
# #    [Tags]    1S-2CC-1D-1U_CA    CRT_TRUNK
# #    General_SiSo_Carrier_Aggregation_with_contiguous_carriers
# #
# ##need mcs, run this case only in TL308
# #[1]CB007499_SR_A_d_RRM_AQQA_10_MU_MIMO_DL_8_layer_with_Tapreing
# #    [Tags]    1S-1CC-1D-1U
# #    General_SiSo_MU_MIMO_DL_8_layer_with_Tapreing
# 
# #[1]CB007499_SR_A_a_SISO_AQQA_06_5GC000399_eCPRI_RP1_Supervision_failure
# #[1]CB007499_SR_A_a_SISO_AQQA_08_5GC000561_eCPRI_sync_loss_at_RAU
# #[1]CB007499_SR_A_b_SISO_AQQA_05_SiSo_Testability_E-UTRA_Test_model_2
# #[1]CB007499_SR_A_b_SISO_AQQA_06_SiSo_Testability_E-UTRA_Test_model_3
# #[1]CB007499_SR_A_c_RRM_AQQA_04_attach_SR_on_different_Prach_configuration_recommison
# #[1]CB007499_SR_A_c_RRM_AQQA_05_attach_SR_on_different_Prach_FreqOffset_chagne
# #[1]CB007499_SR_A_c_RRM_AQQA_07_SRS_NDM_SRS_Quality_and_Channel_check
# #[1]CB007499_SR_A_c_SISO_AQQA_17_KPI_54_Power_on_RU_startup_availability
# #[1]CB007499_SR_A_d_RRM_AQQA_11_MU_MIMO_UL_4_layer_with_CA
# 
# #[1]CB007499_SR_A_a_SISO_AQQA_02_General_SiSo_Commissioning_BTS_Template_Commissioning
# #    [Tags]    CRT_TRUNK
# #    General_SiSo_Commissioning_BTS_Template_Commissioning
# #
# #[1]CB007499_SR_A_a_SISO_AQQA_07_5GC000561_eCPRI_sync_generic_startup_at_RAU
# #    [Tags]    CRT_TRUNK
# #    5GC000561_eCPRI_sync_generic_startup_at_RAU
# #
# #[1]CB007499_SR_A_a_SISO_AQQA_10_5GC000560_eCPRI_sync_generic_startup_at_RU
# #    [Tags]    CRT_TRUNK
# #    5GC000560_eCPRI_sync_generic_startup_at_RU
# #
# #[1]CB007499_SR_A_a_SISO_AQQA_21_General_SiSo_Fault_1900_EFaultId_FrConfiguringFailed
# #    [Tags]    CRT_TRUNK
# #    General_SiSo_Fault_1900_EFaultId_FrConfiguringFailed_PMAX
# #
# #[1]CB007499_SR_A_c_SISO_AQQA_01_CB007499_4G_AA_General_SiSo_RF_module_power_reset
# #    [Tags]    CRT_TRUNK
# #    Manual_SiSo_REC_Radio_Module_power_reset
# #
# #[1]CB007499_SR_A_a_SISO_AQQA_09_5GC000561_eCPRI_sync_counters
# #    [Tags]    CRT_TRUNK
# #    5GC000561_eCPRI_sync_counters    TNL_ETHLK=TNL-2/ETHLK/ETHLK-2
# #
# #[1]CB007499_SR_A_a_SISO_AQQA_12_General_SiSo_SOAP_RP1_verification
# #    General_SiSo_SOAP_RP1_verification
# #
# #[1]CB007499_SR_A_a_SISO_AQQA_24_Manual_SiSo_TEST_Black_Box
# #    Manual_SiSo_TEST_Black_Box
# 
# #[1]CB007499_SR_A_d_SISO_AQQA_09_Loopback_for_C_U_plane_connectivity_check_support_for_SOAP_RP1
# #[1]CB007499_SR_A_d_SISO_AQQA_01_General_SiSo_BTS_startup_with_delayed_RF_link_setup
# #[1]CB007499_SR_A_c_SISO_AQQA_02_CB007499_4G_AA_General_SiSo_RU_module_reset_from_GUI
# #[1]CB007499_SR_A_d_L3int_AQQA_01_2CC_Beamforming_Calibration
# #[1]CB007499_SR_A_c_L3int_AQQA_01_1CC_Beamforming_Calibration
# #[1]CB007499_SR_A_a_L3int_AQQA_01_cell_setup_1CC_TM3
# #[1]CB007499_SR_A_d_L3int_AQQA_02_L3call_2CC_TM7_and_TM8
# #[1]CB007499_SR_A_b_RRM_AQQA_01_Peak_throughput_with_DL_64QAM_and_UL_ 64QAM_ Modulation
# #[1]CB007499_SR_A_b_RRM_AQQA_02_Peak_throughput_with_DL_256QAM_and_UL_64QAM Modulation
# #[1]CB007499_SR_A_d_SISO_AQQA_11_CB008222_Fault_4680_trigger_and_recover
# #[1]CB007499_SR_A_c_L3int_AQQA_03_L3call_1CC_TM8
# #[1]CB007499_SR_A_d_SISO_AQQA_10_Operation_with_TSN_fronthaul
# #[1]CB007499_SR_A_c_SISO_AQQA_35_Manual_SiSo_CALL_LTE_data_call_OTA
# #[1]CB007499_SR_A_b_SISO_AQQA_03_Manual_SiSo_SM_LTE_RAT_reset
# #[1]CB007499_SR_A_c_SISO_AQQA_31_BS_RF__RF_temperature_management_FrDangerouslyOverheat
# #[1]CB007499_SR_A_d_SISO_AQQA_07_BS-RF_LTE_Transmitted_carrier_power_min_max_allowed_power
# #[1]CB007499_SR_A_a_SISO_AQQA_31_5GC000584_RU_Module_Certificate_Integrity
# #[1]CB007499_SR_A_c_SISO_AQQA_32_BS_RF__RF_temperature_management_FrPipeOverheat
# #[1]CB007499_SR_A_d_SISO_AQQA_06_BS-RF_LTE_cell_lock_unlock_administrative_state_change_from_WebEm
# #[1]CB007499_SR_A_c_SISO_AQQA_30_BS_RF__RF_temperature_management_FrFanBroken
# #[1]CB007499_SR_A_d_SISO_AQQA_04_Multi_Carrier_Commission_and_Throughput_with_DL_interference
# #[1]CB007499_SR_A_c_SISO_AQQA_26_General_SiSo_Beamforming_calibration_RF_measurements
# #[1]CB007499_SR_A_d_RRM_AQQA_02_Peak_throughput_with_DL_256QAM_and_UL_64QAM Modulation
# #[1]CB007499_SR_A_a_SISO_AQQA_22_General_SiSo_Snapshot_Showing_RU_Logs_For_a_Failure_After_Radio_Reset
# #[1]CB007499_SR_A_a_SISO_AQQA_20_General_SiSo_Link_Diagnostic_and_Monitoring
# #[1]CB007499_SR_A_c_SISO_AQQA_19_KPI_5_Manual_capacity_module_reset_downtime
# #[1]CB007499_SR_A_a_SISO_AQQA_18_General_SiSo_Static_HW_Capabilities_Validation
# #[1]CB007499_SR_A_c_SISO_AQQA_16_KPI_51_SiSo_Manual RU_reset_downtime
# #[1]CB007499_SR_A_c_SISO_AQQA_10_Manual_SiSo_STARTUP_Start_up_and_Detection_of_RF_Module
# #[1]CB007499_SR_A_c_SISO_AQQA_05_CB007499_4G_AA_Manual_SiSo_SM_BTS_Power_Reset
# #[1]CB007499_SR_A_a_SISO_AQQA_04_5GC000399_eCPRI_FREERUN_state_handling
# #[1]CB007499_SR_A_c_SISO_AQQA_07_Manual_SiSo_ALD_Detect_and_setup_AL_devices_Start-up
# #[1]CB007499_SR_A_a_SISO_AQQA_03_5GC000399_eCPRI_Basic_configuration_over_RP1
# 
# #*** Keywords ***
