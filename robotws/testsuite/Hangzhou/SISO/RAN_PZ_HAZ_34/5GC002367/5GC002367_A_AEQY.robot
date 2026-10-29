*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           SISO Coam Test Setup    fail_with_alarms=${True}
Test Teardown        SISO Coam Test Teardown
Test Timeout         100 min

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_RF_module_power_reset.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_BTS_reset_with_RF_power_reset.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_Configuration_BPF_and_TargetBD_support_for_RF_module.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_BTS_startup_with_RF_delayed_startup.robot
Resource    ${BASIC_PATH_5G}/Cell/E2E_SiSo_Cell_block_and_unblock_gNB.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_LED_states_management_basic.robot
Resource    ${BASIC_PATH_5G}/5GC000560/5GC000560_eLLF_sync_generic_startup_at_RU.robot
Resource    ${BASIC_PATH_5G}/5GC000560/5GC000560_eLLF_sync_generic_startup_at_RU.robot
Resource    ${BASIC_PATH_5G}/BTS/General_SiSo_Peak_with_Given_Information.robot
Resource    ${BASIC_PATH_5G}/E2E_SiSo_RU_lock_and_unlock_gNB.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_NR-ARFCN_check.robot
Resource    ${BASIC_PATH_5G}/General_gnb_can_be_on_air_with_Given_Information.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_Fault_1900_EFaultId_FrConfiguringFailed_PMAX.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_Commissioning_BTS_Template_Commissioning.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_RF_module_reset_from_GUI.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_RF_module_IP_adress_allocation.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_RF_alarms_with_recovery.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_RF_alarms_without_recovery.robot
Resource    ${BASIC_PATH_5G}/ALD/General_SiSo_ALD_Configuration_Management_ALD_site_commissioning.robot
Resource    ${BASIC_PATH_5G}/ALD/General_SiSo_ALD_HW_inventory_ALD_HW_properties_retrieval_and_visualization.robot
Resource    ${BASIC_PATH_5G}/ALD/General_SiSo_ALD_State_Management_ALD_state_management_handling_and_visibility.robot
Resource    ${BASIC_PATH_5G}/ALD/General_SiSo_ALD_FM_Antenna_Line_Device_faulty_notification_recovery_action_indication_and_visualization.robot
Resource    ${BASIC_PATH_5G}/5GC000399/5GC000399_eCPRI_FREERUN_state_handling.robot
Resource    ${BASIC_PATH_5G}/5GC000561/5GC000561_eCPRI_sync_generic_startup_at_RAU.robot
Resource    ${BASIC_PATH_5G}/5GC000561/5GC000561_eCPRI_sync_counters.robot
Resource    ${BASIC_PATH_5G}/General_Stability_Test_Case.robot
Resource    ${BASIC_PATH_5G}/5GC000560/5GC000560_eLLF_PTP_Failure.robot
Resource    ${BASIC_PATH_5G}/5GC000399/5GC000399_eCPRI_Carier_activation.robot
Resource    ${BASIC_PATH_5G}/5GC000399/5GC000399_eCPRI_Basic_configuration_over_RP1.robot
Resource    ${BASIC_PATH_5G}/RF/General_SiSo_Beamforming_calibration.robot
Resource    ${BASIC_PATH_5G}/5GC000399/5GC000399_eCPRI_FREERUN_state_handling.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_Counter_Number_of_UEs_per_beam.robot
Resource    ${BASIC_PATH_5G}/General_RU_Module_Certificate_Integrity.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_Link_Diagnostic_and_Monitoring.robot
Resource    ${BASIC_PATH_5G}/DL_4x4_MIMO_256QAM_PDCCH_precoding_matrix_One_X_Pol_beams_Repetition.robot
Resource    ${BASIC_PATH_5G}/DL_4x4_MIMO_256QAM_PDCCH_precoding_matrix_One_X_Pol_beams_Repetition.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_Auto_Automatic_RAT_SW_upgrade.robot
Resource    ${BASIC_PATH_5G}/RF/Genaral_SiSo_MAA_radio_Pipe_failure_alarm_handling_validation_based_on_CNI-51714.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/nr_feature_on.robot

Variables    TestData/variables.py

Documentation
...    Author: zhihao shi
...    Contact: zhihao.shi@nokia-sbell.com
...    squad group:SG_04
...    Feature 5GC002367-A in 5G20B program

*** Variables ***

*** Test Cases ***
[1]5GC002367_A_AEQY_eCPRI_General_SiSo_RF_module_power_reset
    [Tags]    SBTS00    CIT
    ${fault_list}    Create List    10    4589
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    General_SiSo_RF_module_power_reset

[1]5GC002367_A_AEQY_eCPRI_General_SiSo_BTS_reset_with_RF_power_reset
    [Tags]    CIT_22R4    SBTS00    CIT
    ${fault_list}    Create List    10    4589
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    General_SiSo_BTS_reset_with_RF_power_reset

[1]5GC002367_A_AEQY_eCPRI_General_SiSo_Configuration_BPF_and_TargetBD_support_for_RF_module
    [Tags]    SBTS00    CIT
    General_SiSo_Configuration_BPF_and_TargetBD_support_for_RF_module

[1]5GC002367_A_AEQY_eCPRI_General_SiSo_BTS_startup_with_RF_delayed_startup
    [Tags]    SBTS00    CIT
    ${fault_list}    Create List    10    4589    4590
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    General_SiSo_BTS_startup_with_RF_delayed_startup

[1]5GC002367_A_AEQY_eCPRI_General_SiSo_Cell_block_and_unblock_1S
    [Tags]    CIT_22R4    SBTS00    CIT
    ${fault_list}    Create List    49
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    E2E_SiSo_Cell_block_and_unblock_gNB

[1]5GC002367_A_AEQY_eCPRI_General_SiSo_LED_states_management_basic
    [Tags]    SBTS00    CIT
    ${fault_list}    Create List    10    4589
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    General_SiSo_LED_states_management_basic

[1]5GC002367_A_AEQY_eCPRI_5GC000560_eLLF_sync_generic_startup_at_RU
    [Tags]    SBTS00    CIT
    5GC000560_eLLF_sync_generic_startup_at_RU

[1][1.0] 5GC001473-KG_03_peak_Tput_with_Cbw_90Mhz_256QAM_eCPRI
    [Tags]    CIT_22R4    SBTS00    CIT
    General_SiSo_Peak_with_Given_Information    band=90    frame_structure=1070_GP1_A3    prach_index=7
    ...    suite_name=${SUITE NAME}    test_name=${TEST NAME}

[1]5GC002367_A_AEQY_eCPRI_General_SiSo_RU_lock_unlock
    [Tags]    CIT_22R4    SBTS00    CIT
    E2E_SiSo_RU_lock_and_unlock_gNB

[1][1.0] CB006154_AEQY_04_gnb_can_be_on_air_with_Cbw_70Mhz_ECPRI
    [Tags]    CIT_22R4    SBTS00    CIT
    General_gnb_can_be_on_air_with_Given_Information    band=70    frame_structure=1116_3ms_GP1_A5

[1]5GC002367_A_AEQY_eCPRI_General_SiSo_NR-ARFCN_check
    [Tags]    CRT_TRUNK    SBTS00    CRT_UTE
    ${fault_list}    Create List    1900
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    General_SiSo_NR-ARFCN_check

[1]5GC002367_A_AEQY_eCPRI_5GC000399_eCPRI_Carier_activation_conducted
    [Tags]    CRT_TRUNK
    5GC000399_eCPRI_Carier_activation

[1]5GC002367_A_AEQY_eCPRI_5GC000399_eCPRI_Basic_configuration_over_RP1
    [Tags]    CRT_TRUNK
    5GC000399_eCPRI_Basic_configuration_over_RP1

[1][1.0] 5GC002367_A_AEQY_eCPRI_General_SiSo_E2E_system_setup_with_data_transfer_conducted_100m_Fiber_100MHz
    [Tags]    CRT_TRUNK    SBTS00    CRT_UTE
    General_SiSo_Peak_with_Given_Information    band=100    frame_structure=1208_GP1_A1    prach_index=149
    ...    suite_name=${SUITE NAME}    test_name=${TEST NAME}

[1][1.0] 5GC002367_A_AEQY_eCPRI_Counter_Number_of UEs_per_beam
    [Tags]    CRT_TRUNK
    General_SiSo_Counter_Number_of_UEs_per_beam

[1][1.0] 5GC002367_A_AEQY_eCPRI_5GC001870_L_001_OL_DL_4x4_MIMO_256QAM_PDCCH_precoding_matrix_One_X_Pol_beams_Repetition
    [Tags]    CRT_TRUNK
    DL_4x4_MIMO_256QAM_PDCCH_precoding_matrix_One_X_Pol_beams_Repetition    dlMimoMode_value=4x4 or 4x2 Open Loop Spatial Multiplexing

[1]5GC002367_AEQY_Genaral_SiSo_MAA_radio_Pipe_failure_alarm_handling_validation_based_on_CNI-51714
    ${fault_list}    Create List    1907    1911    1920
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    Genaral_SiSo_MAA_radio_Pipe_failure_alarm_handling_validation_based_on_CNI-51714

[1]5GC002367_AEQY_Timing_offset_online_activation_and_modification_L3Call
    [Documentation]
    ...    *****************
    ...    Feature Owner: Fang Yi
    ...    Add FID4606 into alarm watchdog whitelist,please refer to https://jiradc.ext.net.nokia.com/browse/WESTLAKE-10270.
    ${fault_list}    Create List    4606
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    Timing_offset_online_activation_and_modification_L3Call

#[1]5GC002367_A_AEQY_eCPRI_General_SiSo_Fault_1900_EFaultId_FrConfiguringFailed_PMAX
#    General_SiSo_Fault_1900_EFaultId_FrConfiguringFailed_PMAX
#
#[1]5GC002367_A_AEQY_eCPRI_General_SiSo_Commissioning_BTS_Template_Commissioning_1S
#    General_SiSo_Commissioning_BTS_Template_Commissioning
#
#[1]5GC002367_A_AEQY_eCPRI_General_SiSo_RF_module_reset_from_GUI
#    General_SiSo_RF_module_reset_from_GUI
#
#[1]5GC002367_A_AEQY_eCPRI_General_SiSo_RF_module_IP_adress_allocation
#    General_SiSo_RF_module_IP_adress_allocation
#
#[1]5GC002367_A_AEQY_eCPRI_General_SiSo_RF_alarms_with_recovery
#    General_SiSo_RF_alarms_with_recovery
#
#[1]5GC002367_A_AEQY_eCPRI_General_SiSo_RF_alarms_without_recovery
#    General_SiSo_RF_alarms_without_recovery
#
#[1]5GC002367_A_AEQY_eCPRI_General_SiSo_ALD_Configuration_Management_ALD_site_commissioning
#    General_SiSo_ALD_Configuration_Management_ALD_site_commissioning
#
#[1]5GC002367_A_AEQY_eCPRI_General_SiSo_ALD_HW_inventory_ALD_HW_properties_retrieval_and_visualization
#    General_SiSo_ALD_HW_inventory_ALD_HW_properties_retrieval_and_visualization
#
#[1]5GC002367_A_AEQY_eCPRI_General_SiSo_ALD_State_Management_ALD_state_management_handling_and_visibility
#    General_SiSo_ALD_State_Management_ALD_state_management_handling_and_visibility
#
#[1]5GC002367_A_AEQY_eCPRI_General_SiSo_ALD_FM_Antenna_Line_Device_faulty_notification_recovery_action_indication_and_visualization
#    General_SiSo_ALD_FM_Antenna_Line_Device_faulty_notification_recovery_action_indication_and_visualization
#
#[1]5GC002367_A_AEQY_eCPRI_5GC000399_eCPRI_FREERUN_state_handling
#    5GC000399_eCPRI_FREERUN_state_handling
#
#[1]5GC002367_A_AEQY_eCPRI_5GC000561_eCPRI_sync_generic_startup_at_RAU
#    5GC000561_eCPRI_sync_generic_startup_at_RAU
#
#[1]5GC002367_A_AEQY_eCPRI_5GC000561_eCPRI_sync_counters
#    5GC000561_eCPRI_sync_counters
#
#[1]5GC002367_A_AEQY_eCPRI_General_SiSo_Auto_Automatic_RAT_SW_upgrade
#    [Timeout]    3h
#    General_SiSo_Auto_Automatic_RAT_SW_upgrade
#
#[1]5GC002367_A_AEQY_eCPRI_General_SiSo_Auto_Cell_lock_and_unlock
#    [Tags]    stability
#    [Timeout]    12h
#    Set Log Level    INFO
#    General_Stability_Test_Case    case_name=General_SiSo_Cell_lock_and_unlock    times=${5}    pass=${4}
#
#[1]5GC002367_A_AEQY_eCPRI_OAM_KPI_651_SiSo_Auto_RF_reset_success_rate_from_WebUI
#    [Tags]    stability
#    [Timeout]    12h
#    Set Log Level    INFO
#    General_Stability_Test_Case    case_name=General_SiSo_RF_module_reset_from_GUI    times=${34}    pass=${33}
#
#[1]5GC002367_A_AEQY_eCPRI_OAM_KPI_61a_SiSo_Auto_BTS_site_reset_1S
#    [Tags]    stability
#    [Timeout]    8h
#    Set Log Level    INFO
#    General_Stability_Test_Case    case_name=General_SiSo_Auto_BTS_site_reset    times=${20}    pass=${19}
#
#[1]5GC002367_A_AEQY_eCPRI_OAM_KPI_64_SiSo_Auto_RU_SW_upgrade_success_rate
#    [Tags]    stability
#    [Timeout]    15h
#    Set Log Level    INFO
#    General_Stability_Test_Case    case_name=General_SiSo_Auto_Automatic_RAT_SW_upgrade    times=${20}    pass=${19}
#
#[1]5GC002367_A_AEQY_eCPRI_5GC000560_eLLF_PTP_Failure
#    5GC000560_eLLF_PTP_Failure
#
#[1][1.0] 5GC002367_A_AEQY_eCPRI_General_SiSo_E2E_system_setup_with_data_transfer_conducted_20km_Fiber_100MHz
#    General_SiSo_Peak_with_Given_Information    band=100    frame_structure=1208_GP1_A1    prach_index=149
#
#[1][1.0] 5GC002367_A_AEQY_eCPRI_peak Tput _with 4x4MIMO
#    General_SiSo_Peak_with_Given_Information    band=100    frame_structure=1116_0ms_GP1_A8    prach_index=156
#
#[1][1.0] 5GC002367_A_AEQY_eCPRI_basic L3 call _with 4x4MIMO
#    General_SiSo_Peak_with_Given_Information    band=100    frame_structure=1116_0ms_GP1_A8    prach_index=156
#
#[1][1.0] 5GC002367_A_AEQY_eCPRI_L3_Call_with_Configurable_1208_A_Structure
#    General_SiSo_Peak_with_Given_Information    band=100    frame_structure=1208_GP1_B1    prach_index=203
#
#[1][1.0] 5GC002367_A_AEQY_eCPRI_L3_Call_with_Configurable_1070_A_Structure
#    General_SiSo_Peak_with_Given_Information    band=100    frame_structure=1070_GP1_A3    prach_index=203
#
#[1][1.0] 5GC002367_A_AEQY_eCPRI_L3_Call_with_Configurable_1116_D_Structure
#    General_SiSo_Peak_with_Given_Information    band=100    frame_structure=1116_3ms_GP1_A5    prach_index=149
#
#[1][1.0] 5GC002367_A_AEQY_eCPRI_L3_Call_with_Configurable_1116_C_Structure
#    General_SiSo_Peak_with_Given_Information    band=100    frame_structure=1116_3ms_GP2_B6    prach_index=192
#
#[1][1.0] 5GC002367_A_AEQY_eCPRI_L3_Call_with_Configurable_1116_B_Structure
#    General_SiSo_Peak_with_Given_Information    band=100    frame_structure=1116_0ms_GP2_A7    prach_index=206
#
#[1][1.0] 5GC002367_A_AEQY_eCPRI_L3_Call_with_Configurable_1116_A_Structure
#    General_SiSo_Peak_with_Given_Information    band=100    frame_structure=1116_0ms_GP1_A8    prach_index=195
#
#[1][1.0] 5GC002367_A_AEQY_eCPRI_5GC001304_B4_Format_Call_Setup_with_1116_0ms_PRACH_Config_Index_156
#    General_SiSo_Peak_with_Given_Information    band=100    frame_structure=1116_0ms_GP1_A8    prach_index=156
#
#[1][1.0] 5GC002367_A_AEQY_eCPRI_General_SiSo_Beamforming_calibration
#    General_SiSo_Beamforming_calibration
#
#[1][1.0] 5GC002367_A_AEQY_eCPRI_5GC000584_RU_Module_Certificate_Integrity
#    General_RU_Module_Certificate_Integrity
#
#[1][1.0] 5GC002367_A_AEQY_eCPRI_General_SiSo_Link_Diagnostic_and_Monitoring
#    General_SiSo_Link_Diagnostic_and_Monitoring
#
#[1][1.0] 5GC002367_A_AEQY_eCPRI_5GC001856_L_008_CL_DL_4x4_MIMO_256QAM_PDCCH_precoding_matrix_One_X_Pol_beams_Repetition
#    DL_4x4_MIMO_256QAM_PDCCH_precoding_matrix_One_X_Pol_beams_Repetition    dlMimoMode_value=4x4 or 4x2 Closed Loop Spatial Multiplexing

*** Keywords ***
Timing_offset_online_activation_and_modification_L3Call
    Selenium Login And Disable Screen Lock
    ${cell_list}    get all cell id
    NR Feature CB007597 OFF and Check
    NR Feature CB007597 ON and Check    cell_id_list=${cell_list}    frameStartOffset=3000    sfnOffset=1
    Get UE From Init File and Make call    cell_list=${cell_list}    with_peak=${True}
    ...    duration=${300}    loop_times=${2}
    NR Feature CB007597 ON and Check    cell_id_list=${cell_list}    frameStartOffset=4000    sfnOffset=-1
    Get UE From Init File and Make call    cell_list=${cell_list}    with_peak=${True}
    ...    duration=${300}    loop_times=${2}
    [Teardown]  selenium logout and close browser
