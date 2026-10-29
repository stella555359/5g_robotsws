*** Settings ***
Documentation  Maintainers: @I_SRAN_PROD_SISO_WRO_CRTDEV_GMS

Resource    ../Resources/Setup/setup_and_teardown.robot
#Resource    ../../robotlte_legacy/tc_scenarios.robot

#Resource  ../../robotlte_legacy/Test_Cases/Fault_Management/Automated_SiSo_FM_Fault_Signature_FID_1901.robot
#Resource  ../../robotlte_legacy/Test_Cases/Ul_Comp/Automated_SiSo_Deactivation_Activation_LTE_UL_CoMp.robot
#Resource  ../../robotlte_legacy/Test_Cases/Ul_Comp/Automated_SiSo_CM_LTE_Configuring_UL_CoMp.robot
#Resource  ../../robotlte_legacy/Test_Cases/Ul_Comp/Automated_SiSo_Startup_LTE_Ulcomp_without_HWF.robot
#Resource  ../../robotlte_legacy/Test_Cases/Ul_Comp/Automated_SiSo_CM_LTE_Removing_And_Adding_A_Carrier_To_Ul_CoMp_Pool.robot
#Resource  ../../robotlte_legacy/Test_Cases/Ul_Comp/Automated_SiSo_Removing_And_Adding_An_LTE_UL_CoMp_Pool.robot
#Resource  ../../robotlte_legacy/Test_Cases/Manual_Allocation_Cells/Allocation_of_cells_to_baseband_pools_using_manual_mode.robot
#Resource  ../../robotlte_legacy/Test_Cases/Manual_Allocation_Cells/delta_manual_alloc_resource.robot
#Resource  ../../robotlte_legacy/Test_Cases/Automated_SiSo_Encrypting_and_storing_configured_and_detected_location_data_into_black_box.robot
#Resource  ../../robotlte_legacy/hran_ta/SiSo_REC_LTE_Cell_Degraded_On_One_RMOD_With_Data_Transfer.robot
#Resource  ../../robotlte_legacy/hran_ta/SiSo_RU_Lock_Unlock_ASIR_HUB_From_WebEM.robot
#Resource  ../../robotlte_legacy/hran_ta/SiSo_PM_BTS_Backhaul_SFP_Static_Parameters_Monitoring.robot
#Resource  ../../robotlte_legacy/hran_ta/SiSo_CM_Delta_Recommissioning_With_Site_Reset.robot
#Resource  ../../robotlte_legacy/hran_ta/SiSo_SM_RU_Secondary_link_break_in_chaining.robot
#Resource  ../../robotlte_legacy/hran_ta/SiSo_PM_Load_Based_MIMO_Muting_For_EE.robot
#Resource  ../../robotlte_legacy/hran_ta/SiSo_PM_BTS_Fronthaul_SFP_Static_Parameters_Monitoring.robot
#Resource  ../../robotlte_legacy/hran_ta/SiSo_REC_RU_Safe_Mode_Improper_Voltage_Input.robot
#Resource  ../../robotlte_legacy/hran_ta/SiSo_Test_Dedicated_State.robot
#Resource  ../../robotlte_legacy/hran_ta/SiSo_REC_LTE_Cell_Degraded_On_Two_RMODs_With_Data_Transfer.robot
#Resource  ../../robotlte_legacy/hran_ta/SiSo_REC_5G_Cell_Degraded_On_One_RMOD_With_Data_Transfer.robot
#Resource  ../../robotlte_legacy/hran_ta/SiSo_SM_RU_Primary_link_break_without_recovery.robot
#Resource  ../../robotlte_legacy/hran_ta/SiSo_CM_Commission_Change_Linkspeed_CPRI.robot
#Resource  ../../robotlte_legacy/hran_ta/SiSo_BS_SM_OTN_Optical_Link_Recovery_Calient.robot
#Resource  ../../robotlte_legacy/hran_ta/SiSo_RU_ASIR_Block_One_pRRH_From_ASIRWebEM_Not_Impact_Call_On_Other_pRRH.robot
#Resource  ../../robotlte_legacy/hran_ta/SiSo_REC_5G_Cell_Degraded_On_Two_RMODs_With_Data_Transfer.robot
#Resource  ../../robotlte_legacy/hran_ta/SiSo_FM_NR_PIMC_Faults_Triggering.robot
#Resource  ../../robotlte_legacy/hran_ta/SiSo_SM_RU_Secondary_link_break.robot
#Resource  ../../robotlte_legacy/hran_ta/Siso_CM_Delta_Recommissioning_With_Object_Locking.robot
#Resource  ../../robotlte_legacy/hran_ta/SiSo_SM_RU_Primary_link_break.robot
#Resource  ../../robotlte_legacy/hran_ta/SiSo_REC_Multiple_Changes_Of_Long_Optical_Fiber.robot
#Resource  ../../robotlte_legacy/hran_ta/SiSo_REC_Cross-Cabling_between_TwoRadios.robot
#Resource  ../../robotlte_legacy/hran_ta/SiSo_REC_Cell_Degraded_On_Secondary_Cablink_Two_RMODs_With_Data_Transfer.robot
#Resource  ../../robotlte_legacy/hran_ta/SiSo_RU_ASIR_Block_Unblock_pRRH_From_ASIRWebEM.robot
#Resource  ../../robotlte_legacy/hran_ta/SiSo_REC_Cross-Cabling_between_TheSameRadio.robot
#Resource  ../../robotlte_legacy/hran_ta/SiSo_PM_PIMC_Counters.robot
#Resource  ../../robotlte_legacy/hran_ta/Siso_CM_Delta_Recommissioning_With_RAT_Reset.robot
#Resource  ../../robotlte_legacy/hran_ta/SiSo_REC_Cross-Cabling_between_TwoRadios_withCapacityLink.robot
#Resource  ../../robotlte_legacy/hran_ta/Siso_CM_Delta_Recommissioning_With_Online_Modification.robot
#Resource  ../../robotlte_legacy/hran_ta/SiSo_SM_RU_Primary_link_break_in_chaining.robot
#Resource  ../../robotlte_legacy/hran_ta/SiSo_REC_Cell_Degraded_On_Primary_Cablink_Two_RMODs_With_Data_Transfer.robot
#Resource  ../../robotlte_legacy/hran_ta/SiSo_PM_Embedded_Power_Meter_Counters.robot
#Resource  ../../robotlte_legacy/hran_ta/SiSo_RU_ASIR_Reset_pRRH_From_ASIRWebEM.robot
#Resource  ../../robotlte_legacy/hran_ta/SiSo_RU_ASIR_Unplug_Plug_pRRH.robot
#Resource  ../../robotlte_legacy/hran_ta/SiSo_SM_RU_Secondary_link_break_with_changed_time_delay.robot
#Resource  ../../robotlte_legacy/hran_ta/SiSo_PM_Antenna_Path_Delay_Measurement_CPRI-A.robot
#Resource    testsuite/Wroclaw/SISO/SRAN/REAL_HW/robotlte_legacy/Test_Cases/fh_reset.robot
#Resource    testsuite/Wroclaw/SISO/SRAN/REAL_HW/robotlte_legacy/Test_Cases/FHS_Power_Break_PDU.robot

#Suite Setup       Suite Precondition
#Suite Teardown    Suite Postcondition

*** Variables ***
${CONFIGURATION_STARTUP_TIMEOUT}=    600

*** Test Cases ***
[1][3.0] Automated_SiSo_BTS_Startup_Multiple_Site_Reset
  [Setup]  Run Keywords
  ...  Configuration Precondition  CN=REF_10_16_UTESRANSISO909
  ...  AND  Set Test Variable  ${CUSTOM_EXPECTED_SITE_RESET_TIME}  350
  Execute Test In Loop  Execute Site Reset On Every Node
  [Teardown]  Configuration Postcondition

#[1][2.0] Automated__SiSo__Configuration_Template_Commissioning_with_Configuration_reset
#  [Setup]  Run Keywords
#  ...  Configuration Precondition  CN=REF_10_16_UTESRANSISO909
#  ...  AND  Set Test Variable  ${CONFIGURATION_STARTUP_TIMEOUT}  600
#  Execute Test In Loop  Execute Recommissioning With Configuration Reset On Every Node
#  [Teardown]  Configuration Postcondition
#
#[ftx][x.0] Parallel Site Reset
#  [Setup]  Run Keywords
#  ...  Configuration Precondition  CN=REF_10_16_UTESRANSISO909
#  ...  AND  Set Test Variable  ${CONFIGURATION_STARTUP_TIMEOUT}  600
#  ...  AND  Set Test Variable  ${CUSTOM_EXPECTED_SITE_RESET_TIME}  350
#  Execute Test In Loop  Execute Parallel Site Reset On Every Node
#  [Teardown]  Configuration Postcondition
#
#[1][1.0] Automated__SiSo__BTS_Block_Unblock_without_call
#    [Setup]  Run Keywords
#    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO909
#    ...  AND  Set Test Variable  ${CONFIGURATION_STARTUP_TIMEOUT}     600
#    ...  AND  Set Test Variable  ${CUSTOM_EXPECTED_SITE_RESET_TIME}     350
#    Execute Test In Loop  Execute Block BTS On Every Node
#    [Teardown]  Configuration Postcondition
#
#[1][4.0] Automated__SiSo__Configuration_Testing_SW Download and Activation
#    [Setup]  Run Keywords
#    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO909
#    ...  AND  Set Test Variable  ${CONFIGURATION_STARTUP_TIMEOUT}     600
#    ...  AND  Set Test Variable  ${${CONFIGURATION_SWUPDATE_TIMEOUT}}     350
#    Execute Test In Loop  Execute SW Upgrade On Every Node
#    [Teardown]  Configuration Postcondition
#
#[1][1.0] Automated_SiSo_SM_NR_RAT_reset
#    [Setup]  Run Keywords
#    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO909
#    ...  AND  Set Test Variable  ${CONFIGURATION_STARTUP_TIMEOUT}     600
#    ...  AND  Set Test Variable  ${CUSTOM_EXPECTED_SITE_RESET_TIME}     800
#    ...  AND  Set Test Variable  ${NR_RAT_RESET_TIMEOUT}     180
#    ...  AND  Set Test Variable  ${RAT_IMPACT}     LTE
#    Execute Test In Loop  NR RAT reset from ADMIN
#    [Teardown]  Configuration Postcondition
#
#[1][1.0] Automated_SiSo_SM_LTE_RAT_reset
#    [Setup]  Run Keywords
#    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO909
#    ...  AND  Set Test Variable  ${CONFIGURATION_STARTUP_TIMEOUT}     600
#    ...  AND  Set Test Variable  ${CUSTOM_EXPECTED_SITE_RESET_TIME}     350
#    ...  AND  Set Test Variable  ${LTE_RAT_reset_timeout}     180
#    ...  AND  Set Test Variable  ${RAT_IMPACT}     NR
#    Execute Test In Loop  LTE RAT reset from ADMIN
#    [Teardown]  Configuration Postcondition
#
#[1][3.0] Automated_SiSo_BTS_Startup_Multiple_Power_Reset
#    [Setup]  Run Keywords
#    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO909
#    ...  AND  Set Test Variable  ${CONFIGURATION_STARTUP_TIMEOUT}     600
#    Execute Test In Loop  Power Reset On Node
#    [Teardown]  Configuration Postcondition
#
#[1][2.0] Automated_SiSo_Reset_of_BB card_WebEM
#    [Setup]  Run Keywords
#    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO909
#    ...  AND  Set Test Variable  ${CONFIGURATION_STARTUP_TIMEOUT}     600
#    ...  AND  Set Test Variable  ${CUSTOM_EXPECTED_SITE_RESET_TIME}     350
#    ...  AND  Set Test Variable  @{BB_LIST}     L123456
#    Execute Test In Loop  BB Reset On Every Node
#    [Teardown]  Configuration Postcondition
#
#[1][1.0] Automated_SiSo_SM_Cell_Block_Unblock
#    [Setup]  Run Keywords
#    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO909
#    ...  AND  Set Test Variable  ${CONFIGURATION_STARTUP_TIMEOUT}     600
#    ...  AND  Set Test Variable  ${CUSTOM_EXPECTED_SITE_RESET_TIME}     350
#    ...  AND  Set Test Variable  ${CELL_LIST}     12  23  24  25
#    Execute Test In Loop  Execute Cell Block Unblock On Every Node
#    [Teardown]  Configuration Postcondition
#
#[1][2.0] Automated__SiSo__Recovery_Warm_Reset_of_Individual_Capacity_Module_BBPool_WebEM
#    [Setup]  Run Keywords
#    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO909
#    ...  AND  Set Test Variable  ${CONFIGURATION_STARTUP_TIMEOUT}     600
#    ...  AND  Set Test Variable  ${CUSTOM_EXPECTED_SITE_RESET_TIME}     350
#    Execute Test In Loop  Execute BB Pool Reset On Every Node
#    [Teardown]  Configuration Postcondition
#
#[1][2.0] Automated_SiSo_FHS Link Hot Remove Insert
#    [Setup]  Run Keywords
#    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO909
#    ...  AND  Set Test Variable  ${CONFIGURATION_STARTUP_TIMEOUT}     600
#    ...  AND  Set Test Variable  ${optical_switch_alt_conf}  ${optical_switch_alt_conf}
#    Execute Test In Loop  FHS Link Hot Remove Insert
#    [Teardown]  Configuration Postcondition
#
#[1][5.0] SiSo_State_Management_HW_resource_locking_and_unlocking_RF_Module
#    [Setup]  Run Keywords
#    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO909
#    ...  AND  Set Test Variable  ${CONFIGURATION_STARTUP_TIMEOUT}     600
#    ...  AND  Set Test Variable  @{CUSTOM_RADIO_UNIT_LIST}     L12345  L123456
#    Execute Test In Loop  Execute RU Block Unblock On Every Node
#    [Teardown]  Configuration Postcondition
#
#[1][3.0] Automated_SiSo_RU_Startup_Multiple_Power_Reset
#    [Setup]  Run Keywords
#    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO909
#    ...  AND  Set Test Variable  ${CONFIGURATION_STARTUP_TIMEOUT}     600
#    ...  AND  Set Test Variable  ${FAULT_10_TIMEOUT}     20
#    ...  AND  Set Test Variable  ${FR_AVAILABILITY_TIMEOUT}     150
#    ...  AND  Set Test Variable  @{CUSTOM_RADIO_UNIT_LIST}     L12345  L123456
#    ...  AND  Set Test Variable  ${RU_STARTUP_TIMEOUT}     180
#    Execute Test In Loop  Execute RU Power Hot Remove Insert On Every Node
#    [Teardown]  Configuration Postcondition
#
#[1.0] Automated_SiSo_STARTUP_BTS_Startup_RF_Delayed_Startup
#    [Setup]  Run Keywords
#    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO909
#    ...  AND  Set Test Variable  ${CONFIGURATION_STARTUP_TIMEOUT}     600
#    ...  AND  Set Test Variable  @{CUSTOM_RADIO_UNIT_LIST}     L12345  L123456
#    ...  AND  Set Test Variable  ${FAULT_10_TIMEOUT}     20
#    ...  AND  Set Test Variable  ${FR_AVAILABILITY_TIMEOUT}     150
#    Execute Test In Loop  Automated_SiSo_STARTUP_BTS_Startup_RF_Delayed_Startup
#    [Teardown]  Configuration Postcondition
#
#[1.0] Automated_SiSo_TEST_Stability_Without_Reset
#    [Setup]  Run Keywords
#    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO909
#    ...  AND  Set Test Variable  ${CONFIGURATION_STARTUP_TIMEOUT}     600
#    ...  AND  Set Test Variable  ${Total_Time}     600
#    ...  AND  Set Test Variable  ${Interval}     600
#    Execute Test In Loop  Automated_SiSo_TEST_Stability_Without_Reset
#    [Teardown]  Configuration Postcondition
#
#[2.0] Automated_SiSo_Delta recommissioning
#    [Setup]  Run Keywords
#    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO909
#    ...  AND  Set Test Variable  ${CONFIGURATION_STARTUP_TIMEOUT}
#    ...  AND  Set Test Variable  ${DELTA}     delta
#    ...  AND  Set Test Variable  ${DELTA_RESET}    True
#    Execute Test In Loop  Delta Recommissioning
#    [Teardown]  Configuration Postcondition
#
#[4.0] Automated__SiSo__Configuration_Testing_SW Download and Activation
#        [Setup]  Run Keywords
#    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO909
#    ...  AND  Set Test Variable  ${CONFIGURATION_SWUPDATE_TIMEOUT}     600
#    Execute Test In Loop  Execute SW Upgrade On Every Node With Rollback
#    [Teardown]  Configuration Postcondition
#
#[1.0] Automated_SiSo_CALL_LTE_Data_Transfer
#        [Setup]  Run Keywords
#    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO909
#    ...  AND  Set Test Variable  @{SELECTED_CELLS}   377623    377663
#    ...  AND  Set Test Variable  ${LOGS_DIR}   ${cfg.test_logs_path}
#    Execute Test In Loop  SiSo Basic L3 Call
#    [Teardown]  Configuration Postcondition
#
#[1.0] SiSo_State_Management_Pmax_Verification
#    [Setup]  Run Keywords
#    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO909
#    ...  AND  Set Test Variable  ${CONFIGURATION_STARTUP_TIMEOUT}     600
#    ...  AND  Set Test Variable  @{CUSTOM_RADIO_UNIT_LIST}     L12345  L123456
#    Execute Test In Loop  Perform_Pmax_Verification
#    [Teardown]  Configuration Postcondition
#
#[1.0] Automated__SiSo__RTWP_check
#    [Setup]  Run Keywords
#    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO909
#    ...  AND  Set Test Variable  ${RTWP_measuring_time}     600
#    ...  AND  Set Test Variable  ${RTWP_min}     -110
#    ...  AND  Set Test Variable  ${RTWP_min}     -70
#    ...  AND  Set Test Variable  ${CUSTOM_PERFORM_RESET}     ${TRUE}
#    ...  AND  Set Test Variable  ${BTS_stability_time}     15 min
#    ...  AND  Set Test Variable  @{CUSTOM_RADIO_UNIT_LIST}     L123456
#    Execute Test In Loop  Automated__SiSo__RTWP_check
#    [Teardown]  Configuration Postcondition
#
#[2.0] Automated__BS_FV_SFP monitoring_static_parameters
#        [Setup]  Run Keywords
#    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO909
#    ...  AND  Set Test Variable  ${sfp_filename}   sfp_AAHF1.yaml
#    Execute Test In Loop  Automated__SiSo__SFP_Monitoring_static_parameters
#    [Teardown]  Configuration Postcondition
#
##[1.0] Automated__SiSo__FV_Testing_RET_status
##        [Setup]  Run Keywords
##    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO909
##    ...  AND  Set Test Variable  @{CUSTOM_RADIO_UNIT_LIST}     L12345
##    Execute Test In Loop  Automated__SiSo__FV_Testing_RET_status
##    [Teardown]  Configuration Postcondition
#
#[1.0] Automated__SiSo__FV_Testing_RET_status
#        [Setup]  Run Keywords
#    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO909
#    ...  AND  Set Test Variable  @{CUSTOM_RADIO_UNIT_LIST}     L12345
#    Execute Test In Loop  Automated__SiSo__FV_Testing_RET_RF_specific_status
#    [Teardown]  Configuration Postcondition
#
#[1.0] Automated__SiSo__FV_Testing_MHA_status
#        [Setup]  Run Keywords
#    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO909
#    ...  AND  Set Test Variable  @{CUSTOM_RADIO_UNIT_LIST}     L12345
#    ...  AND  Set Test Variable  ${CONFIGURATION_STARTUP_TIMEOUT}     600
#    Execute Test In Loop  Automated__SiSo__FV_Testing_MHA_status
#    [Teardown]  Configuration Postcondition
#
#[1.0] Automated__SiSo__FV_Testing_Fiber_length
#        [Setup]  Run Keywords
#    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO909
#    ...  AND  Set Test Variable  @{CUSTOM_RADIO_UNIT_LIST}     L12345
#    ...  AND  Set Test Variable  ${CONFIGURATION_STARTUP_TIMEOUT}     600
#    Execute Test In Loop  Automated__SiSo__FV_Testing_Fiber_length
#    [Teardown]  Configuration Postcondition
#
#[1.0] Automatet_SiSo_cell_allocation_acording_to_logical_group_L1balance
#        [Setup]  Run Keywords
#    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO909
#    ...  AND  Set Test Variable  ${CONFIGURATION_STARTUP_TIMEOUT}     600
#    ...  AND  Set Test Variable  @{BB_LIST}     L12345
#    ...  AND  Set Test Variable  ${ABIO_delta_directory_path}     /home/ute/MN/UTE/robotlte/testsuite/WMP/GVe/Wroclaw/AiFSiteS/CRT/CLOUD3832/ABIO
#    Execute Test In Loop  Automated_SiSo_cell_allocation_acording_to_logical_group_L1balance
#    [Teardown]  Configuration Postcondition
#
#[1.0] RF module Avoiding reset loops in case of service failure at startup
#        [Setup]  Run Keywords
#    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO909
#    ...  AND  Set Test Variable  ${CONFIGURATION_STARTUP_TIMEOUT}     600
#    ...  AND  Set Test Variable  @{CUSTOM_RADIO_UNIT_LIST}     L12345
#    Execute Test In Loop    Radio List Recovery Reset Counter Exceeded Cleared
#    [Teardown]  Configuration Postcondition
#
#[1.0] Automated__SiSo__Static_Power_Saving_for_ABIO_and_ASOE
#        [Setup]  Run Keywords
#    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO909
#    ...  AND  Set Test Variable  ${CONFIGURATION_STARTUP_TIMEOUT}     600
#    Execute Test In Loop  Static Power Saving For ABIO And ASOE
#    [Teardown]  Configuration Postcondition
#
#[3.0] FHS Link Hot Remove Insert
#        [Setup]  Run Keywords
#    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO909
#    ...  AND  Set Test Variable  ${CONFIGURATION_STARTUP_TIMEOUT}     600
#    ...  AND  Set Test Variable  ${optical_switch_alt_conf}  ${optical_switch_alt_conf}
#    Execute Test In Loop  FHS Link Hot Remove Insert
#    [Teardown]  Configuration Postcondition
#
#Allocation of cells to baseband pools using manual mode tc
#        [Setup]  Run Keywords
#    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO909
#    ...  AND  Set Test Variable  ${CONFIGURATION_STARTUP_TIMEOUT}     600
#    Execute Test In Loop  Allocation of cells to baseband pools using manual mode tc
#    [Teardown]  Configuration Postcondition
#
#[1.0] Automated_SiSo_Encrypting_and_storing_configured_and_detected_location_data_into_black_box
#        [Setup]  Run Keywords
#    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO909
#    ...  AND  Set Test Variable  @{CUSTOM_FHS_UNIT_LIST}     L12345
#    ...  AND  Set Test Variable  @{CUSTOM_RADIO_UNIT_LIST}     L12345
#    Execute Test In Loop  Check Location Information In Black Box File
#    [Teardown]  Configuration Postcondition
#
#[1.0] Memory consumption with maximum Cells
#        [Setup]  Run Keywords
#    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO909
#    ...  AND  Set Test Variable  ${CONFIGURATION_STARTUP_TIMEOUT}     600
#    Execute Test In Loop  BOAM Memory Consumption
#    [Teardown]  Configuration Postcondition
#
#[1.0] Automated_SiSo_FM_Fault_Signature_FID_4590
#    [Setup]  Run Keywords
#    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO909
#    ...  AND  Set Test Variable  @{CUSTOM_RADIO_UNIT_LIST}     L12345
#    Execute Test In Loop  RF Fault Signature FID4590
#    [Teardown]  Configuration Postcondition
#
#[1.0] Automated_SiSo_FHS_Reset_by_WebEM
#    [Setup]  Run Keywords
#    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO909
#    ...  AND  Set Test Variable  ${CONFIGURATION_STARTUP_TIMEOUT}     600
#    ...  AND  Set Test Variable  &{FHS_SNs}  SN000000001  SN000000002  SN000000003
#    Execute Test In Loop  FHS Reset
#    [Teardown]  Configuration Postcondition
#
#[3.0] Automated_SiSo_FHS_PDU_Power_Break
#    [Setup]  Run Keywords
#    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO909
#    ...  AND  Set Test Variable  ${CONFIGURATION_STARTUP_TIMEOUT}     600
#    Execute Test In Loop  FHS Power Break PDU
#    [Teardown]  Configuration Postcondition
#
#[1.0] Automated_SiSo_REC_Hot_remove_insert_FHS_sync_link
#    [Setup]  Run Keywords
#    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO909
#    ...  AND  Set Test Variable  ${CONFIGURATION_STARTUP_TIMEOUT}     600
#    ...  AND  Set Test Variable  ${OS_ALT_CONF_FHS_SYNC_FH1}     ${OS_ALT_CONF_FHS_SYNC_FH1}
#    ...  AND  Set Test Variable  ${OS_ALT_CONF_FHS_SYNC_FH2}     ${OS_ALT_CONF_FHS_SYNC_FH2}
#    Execute Test In Loop  FHS Sync Link Hot Remove Insert
#    [Teardown]  Configuration Postcondition
#
#[1.0] Automated_SiSo_FM_Fault_Signature_FID_1981
#    [Setup]  Run Keywords
#    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO909
#    ...  AND  Set Test Variable  ${CONFIGURATION_STARTUP_TIMEOUT}     600
#    ...  AND  Set Test Variable  ${node}  ${cfg.active_bts_list}[0]
#    Execute Test In Loop  RF Fault Signature FID1981
#    [Teardown]  Configuration Postcondition
#
#[1.0] Automated_SiSo_Fault_Managament_PIMc_Alarm_Trigerring_on_RF_module
#    [Setup]  Run Keywords
#    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO909
#    ...  AND  Set Test Variable  @{CUSTOM_RADIO_UNIT_LIST}     L12345
#    Execute Test In Loop  Automated_SiSo_Fault_Managament_PIMc_Alarm_Trigerring_on_RF_module
#    [Teardown]  Configuration Postcondition
#
#[1.0] Automated__SiSo_Fault_Managament_PIMc_enabling_on_supported_and_unsupported_radio_modules
#    [Setup]  Run Keywords
#    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO909
#    ...  AND  Set Test Variable  ${CONFIGURATION_STARTUP_TIMEOUT}     600
#    Execute Test In Loop  Automated__SiSo_Fault_Managament_PIMc_enabling_on_unsupported_radio_module
#    [Teardown]  Configuration Postcondition
#####
#[1.0] Automated_SiSo_REC_Hot_remove_insert_RU_primary_link_with_FHS
#    [Setup]  Run Keywords
#    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO909
#    ...  AND  Set Test Variable  ${CONFIGURATION_STARTUP_TIMEOUT}     600
#    ...  AND  Set Test Variable  &{CB007779_SYNC_DOWN}   RMOD_SN=1:1-x,2-x,3-x,4-x,5-x,6-x
#    Execute Test In Loop  Primary Link Break For OBSAI RMOD
#    [Teardown]  Configuration Postcondition
#
#[1.0] Automated_SiSo_REC_Hot_remove_insert_RU_secondary_link_with_FHS
#    [Setup]  Run Keywords
#    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO909
#    ...  AND  Set Test Variable  ${CONFIGURATION_STARTUP_TIMEOUT}     600
#    ...  AND  Set Test Variable  &{CB007779_DATA_DOWN}    RMOD_SN=1:1-x,2-x,3-x,4-x,5-x,6-x
#    Execute Test In Loop  Secondary Link Break For OBSAI RMOD
#    [Teardown]  Configuration Postcondition
#
#[2.0] SiSo_Performance_Slim_Carrier_With_Dedicated_Filters
#    [Setup]  Run Keywords
#    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO909
#    ...  AND  Set Test Variable    ${CONFIGURATION_STARTUP_TIMEOUT}     600
#    ...  AND  Set Test Variable    @{SELECTED_CELLS}    353794
#    ...  AND  Set Test Variable    ${numBlankDlPrbsDown}    6
#    ...  AND  Set Test Variable    ${numBlankDlPrbsUp}      6
#    ...  AND  Set Test Variable    ${slimChBw}     17.5
#    Execute Test In Loop  Slim Carrier L3 Call
#    [Teardown]  Configuration Postcondition
#

#[2.0] SiSo_Performance_Slim_Carrier_With_Dedicated_Filters NR  ??
#    [Setup]  Run Keywords
#    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO909
#    ...  AND  Set Test Variable    ${CONFIGURATION_STARTUP_TIMEOUT}     600
#    ...  AND  Set Test Variable    @{SELECTED_CELLS}    353794
#    ...  AND  Set Test Variable    ${slimRfFilterDL}    6
#    ...  AND  Set Test Variable    ${slimRfFilterUL}      6
#    ...  AND  Set Test Variable    ${ChBw}     17.5
#    Execute Test In Loop  Slim Carrier L3 NR
#    [Teardown]  Configuration Postcondition



#[2.0] Automated__SiSo__optical_link_recovery_after_link_break_shorter than_OTN_recovery period_0s_10s
#    [Setup]  Run Keywords
#    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO909
#    ...  AND  Set Test Variable  ${CELLS_YAML_PATH}    /home/ute/testline_configuration/10_16_UTESRANSISOxxx/ue_config_fullobsai.yaml
#    ...  AND  Set Test Variable  ${SISO_L3_CALL}  True
#    ...  AND  Set Test Variable  ${loc_link_break_min}  0
#    ...  AND  Set Test Variable  ${loc_link_break_max}  10000
#    ...  AND  Set Test Variable  ${loc_sn_rf_test}  L1131612345
#    ...  AND  Set Test Variable  ${ip_switch_tl1}  10.42.201.14
#    ...  AND  Set Test Variable  ${switch_port_link_break}  4.4.1
#    Execute Test In Loop  TC_SiSo_BS_SM_OTN_Optical_Link_Recovery_Calient
#    [Teardown]  Configuration Postcondition
#
#[1.0] Automated_SiSo_CM_Commission_Change_Linkspeed_CPRI
#    [Setup]  Run Keywords
#    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO909
#    ...  AND  Set Test Variable  @{CUSTOM_RADIO_UNIT_LIST}     L12345
#    ...  AND  Set Test Variable  ${CELLS_YAML_PATH}    /home/ute/testline_configuration/10_16_UTESRANSISOxxx/ue_config_fullobsai.yaml
#    ...  AND  Set Test Variable  ${SISO_L3_CALL}  True
#    Execute Test In Loop  TC_SiSo_CM_Commission_Change_Linkspeed_CPRI
#    [Teardown]  Configuration Postcondition
#
#TC__Siso_CM_Delta_Recommissioning_With_Object_Locking
#    [Setup]  Run Keywords
#    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO909
#    ...  AND  Set Test Variable  ${STARTUP_TIMEOUT}     600
#    ...  AND  Set Test Variable  ${TESTED_IDS}     1234 3456
#    ...  AND  Set Test Variable  ${DELTA_JSON_PATH}     <custom_name>.json
#    ...  AND  Set Test Variable  ${BTS_ID}     1999
#    ...  AND  Set Test Variable  ${RECOMMISSIONING_TIMEOUT}     600
#    ...  AND  Set Test Variable  ${IGNORE_ERRORS}     1404
#    Execute Test In Loop  TC__Siso_CM_Delta_Recommissioning_With_Object_Locking
#    [Teardown]  Configuration Postcondition
#
#TC__Siso_CM_Delta_Recommissioning_With_Online_Modification
#    [Setup]  Run Keywords
#    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO909
#    ...  AND  Set Test Variable  ${STARTUP_TIMEOUT}     600
#    ...  AND  Set Test Variable  ${DELTA_JSON_PATH}     <custom_name>.json
#    ...  AND  Set Test Variable  ${BTS_ID}     1999
#    ...  AND  Set Test Variable  ${RECOMMISSIONING_TIMEOUT}     600
#    ...  AND  Set Test Variable  ${IGNORE_ERRORS}     1404
#    Execute Test In Loop  TC__Siso_CM_Delta_Recommissioning_With_Online_Modification
#    [Teardown]  Configuration Postcondition
#
#TC__CM_Delta_Recommissioning_With_RAT_Reset
#    [Setup]  Run Keywords
#    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO909
#    ...  AND  Set Test Variable  ${RAT_SIGN}    <LN, WN, GN, NR>. Default is LN.
#    ...  AND  Set Test Variable  ${STARTUP_TIMEOUT}     600
#    ...  AND  Set Test Variable  ${DELTA_JSON_PATH}     <custom_name>.json
#    ...  AND  Set Test Variable  ${BTS_ID}     1998
#    ...  AND  Set Test Variable  ${RECOMMISSIONING_TIMEOUT}     1999
#    ...  AND  Set Test Variable  ${IGNORE_ERRORS}     1404
#    Execute Test In Loop  TC__CM_Delta_Recommissioning_With_RAT_Reset
#    [Teardown]  Configuration Postcondition
#
#TC__Siso_CM_Delta_Recommissioning_With_Site_Reset
#    [Setup]  Run Keywords
#    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO909
#    ...  AND  Set Test Variable  ${STARTUP_TIMEOUT}     600
#    ...  AND  Set Test Variable  ${DELTA_JSON_PATH}     <custom_name>.json
#    ...  AND  Set Test Variable  ${BTS_ID}     1998
#    ...  AND  Set Test Variable  ${RECOMMISSIONING_TIMEOUT}     1999
#    ...  AND  Set Test Variable  ${IGNORE_ERRORS}     1404
#    Execute Test In Loop  TC__Siso_CM_Delta_Recommissioning_With_Site_Reset
#    [Teardown]  Configuration Postcondition
#
#[1.0] Automated_SiSo_FM_NR_PIMC_Faults_Triggering
#    [Setup]  Run Keywords
#    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO909
#    ...  AND  Set Test Variable  ${RMOD_SN}  BL2220N403V
#    ...  AND  Set Test Variable  ${node}  ${cfg.active_bts_list}[0]
#    ...  AND  TC__SiSo_FM_NR_PIMC_Faults_Triggering
#    Execute Test In Loop  TC__SiSo_FM_NR_PIMC_Faults_Triggering
#    [Teardown]  Configuration Postcondition
#
#TC__SiSo_PM_Antenna_Path_Delay_Measurement_CPRI-A
#    [Setup]  Run Keywords
#    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO909
#    ...  AND  Set Test Variable  ${RMOD_SN}     BL2220N403V
#    ...  AND  Set Test Variable  ${ANTENNA_LINES}   1,2
#    ...  AND  Set Test Variable  ${node}  ${cfg.active_bts_list}[0]
#    Execute Test In Loop  TC__SiSo_PM_Antenna_Path_Delay_Measurement_CPRI-A
#    [Teardown]  Configuration Postcondition
#
#
#[1.0] SiSo_PM_BTS_Backhaul_SFP_Static_Parameters_Monitoring
#    [Setup]  Run Keywords
#    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO909
#    ...  AND  Set Test Variable  ${node}  ${cfg.active_bts_list}[0]
#    ...  AND  Set Test Variable  ${SFP_YAML_PATH}
#    ...  /home/ute/MN/UTE/robotlte/testsuite/WMP/GVe/Wroclaw/AiFSiteS/CRT_5G/10_16_UTESRANSISOxxx/SFP_BACKHAUL.yaml
#    Execute Test In Loop  TC__SiSo_PM_BTS_Backhaul_SFP_Static_Parameters_Monitoring
#    [Teardown]  Configuration Postcondition
#
#[1.0] SiSo_PM_BTS_Fronthaul_SFP_Static_Parameters_Monitoring
#    [Setup]  Run Keywords
#    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO909
#    ...  AND  Set Test Variable  ${node}  ${cfg.active_bts_list}[0]
#    ...  AND  Set Test Variable  ${SFP_YAML_PATH}
#    ...  /home/ute/MN/UTE/robotlte/testsuite/WMP/GVe/Wroclaw/AiFSiteS/CRT_5G/10_16_UTESRANSISOxxx/SFP_FRONTHAUL_trunk.yaml
#    Execute Test In Loop  TC__SiSo_PM_BTS_Fronthaul_SFP_Static_Parameters_Monitoring
#    [Teardown]  Configuration Postcondition
#
#[1.0] Automated_SiSo_PM_Embedded_Power_Meter_Counters
#    [Setup]  Run Keywords
#    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO909
#    ...  AND  Set Test Variable  ${node}  ${cfg.active_bts_list}[0]
#    Execute Test In Loop  TC__SiSo_PM_Embedded_Power_Meter_Counters
#    [Teardown]  Configuration Postcondition
#
#[1.0] Automated_SiSo_PM_Load_Based_MIMO_Muting_For_EE
#    [Setup]  Run Keywords
#    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO909
#    ...  AND  Set Test Variable  ${CELL_ID}  37901
#    ...  AND  Set Test Variable  ${node}  ${cfg.active_bts_list}[0]
#    Execute Test In Loop  TC__SiSo_PM_Load_Based_MIMO_Muting_For_EE
#    [Teardown]  Configuration Postcondition
#
#[2.0] Automated_SiSo_PM_PIMC_Counters
#    [Setup]  Run Keywords
#    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO909
#    ...  AND  Set Test Variable  ${RMOD_SN}  K9175039258
#    ...  AND  Set Test Variable  ${node}  ${cfg.active_bts_list}[0]
#    Execute Test In Loop  TC__SiSo_PM_PIMC_Counters
#    [Teardown]  Configuration Postcondition
#
#TC__SiSo_REC_5G_Cell_Degraded_On_One_RMOD_With_Data_Transfer
#    [Setup]  Run Keywords
#    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO909
#    ...  AND  Set Test Variable  ${node}  ${cfg.active_bts_list}[0]
#    ...  AND  Set Test Variable  ${RMOD_SN}  K9175039258
#    ...  AND  Set Test Variable  ${PIPE_NUMBER}  ${cfg.active_bts_list}[0]
#    Execute Test In Loop  TC__SiSo_REC_5G_Cell_Degraded_On_One_RMOD_With_Data_Transfer
#    [Teardown]  Configuration Postcondition
#
#[1.0] Automated_SiSo_Degraded_Cells_Checking_with_power_of_radio_and_call_processing
#    [Setup]  Run Keywords
#    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO909
#    ...  AND  Set Test Variable    @{SELECTED_CELLS}    24182785
#    ...  AND  Set Test Variable   ${RMODS_SN}  EA213054911 EA224851072
#    Execute Test In Loop  TC__SiSo_REC_5G_Cell_Degraded_On_Two_RMODs_With_Data_Transfer
#    [Teardown]  Configuration Postcondition
#
#TC__SiSo_REC_Cell_Degraded_On_Primary_Cablink_Two_RMODs_With_Data_Transfer
#    [Setup]  Run Keywords
#    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO909
#    ...  AND  Set Test Variable  ${node}  ${cfg.active_bts_list}[0]
#    Execute Test In Loop  TC__SiSo_REC_Cell_Degraded_On_Primary_Cablink_Two_RMODs_With_Data_Transfer
#    [Teardown]  Configuration Postcondition
#
#TC__SiSo_REC_Cell_Degraded_On_Secondary_Cablink_Two_RMODs_With_Data_Transfer
#    [Setup]  Run Keywords
#    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO909
#    ...  AND  Set Test Variable  ${node}  ${cfg.active_bts_list}[0]
#    Execute Test In Loop  TC__SiSo_REC_Cell_Degraded_On_Secondary_Cablink_Two_RMODs_With_Data_Transfer
#    [Teardown]  Configuration Postcondition
#
#TC_SiSo_REC_Cross-Cabling_between_TheSameRadio
#    [Setup]  Run Keywords
#    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO909
#    ...  AND  Set Test Variable  ${node}  ${cfg.active_bts_list}[0]
#    Execute Test In Loop  TC_SiSo_REC_Cross-Cabling_between_TheSameRadio
#    [Teardown]  Configuration Postcondition
#
#TC_SiSo_REC_Cross-Cabling_between_TwoRadios
#    [Setup]  Run Keywords
#    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO909
#    ...  AND  Set Test Variable  ${node}  ${cfg.active_bts_list}[0]
#    Execute Test In Loop  TC_SiSo_REC_Cross-Cabling_between_TwoRadios
#    [Teardown]  Configuration Postcondition
#
#SW Upgrade From Older Branch For SM And Factory For RM
#    [Setup]  Run Keywords
#    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO909
#    ...  AND  Set Test Variable  @{CUSTOM_RADIO_UNIT_LIST}  EA213054911  EA224851072
#    Execute Test In Loop  SW Upgrade From Older Branch For SM And Factory For RM
#    [Teardown]  Configuration Postcondition
#
#[1.0] Automated__SiSo__FV_Testing_RF_Factory_SW_update
#      [Setup]  Run Keywords
#    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO909
#    ...  AND  Set Test Variable  @{CUSTOM_RADIO_UNIT_LIST}  L123456
#    ...  AND  Set Test Variable  ${FACTORYSW}  factory
#    Execute Test In Loop  Incompatible Software Detection and Update
#    [Teardown]  Configuration Postcondition


#[1.0] Automated__SiSo__FV_Testing_Incompatible_FR_SW
#      [Setup]  Run Keywords
#    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO909
#    ...  AND  Set Test Variable  @{CUSTOM_RADIO_UNIT_LIST}  L123456
#    ...  AND  Set Test Variable  ${FACTORYSW}  factory
#    Execute Test In Loop  Incompatible Software Detection and Update
#    [Teardown]  Configuration Postcondition
#
#[1.0] Automated_SiSo_FM_Fault_Signature_FID_1901
#    [Setup]  Run Keywords
#    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO909
#    ...  AND  Set Test Variable  @{CUSTOM_RADIO_UNIT_LIST}  L123456
#    Execute Test In Loop  RF Fault Signature FID1901
#  [Teardown]  Configuration Postcondition
#
#[1.0] Automated_SiSo_FM_Fault_Signature_FID_1907
#    [Setup]  Run Keywords
#    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO909
#    ...  AND  Set Test Variable  @{CUSTOM_RADIO_UNIT_LIST}  L123456
#    Execute Test In Loop  RF Fault Signature FID1907
#  [Teardown]  Configuration Postcondition
#
#[1.0] Automated_SiSo_FM_Fault_Signature_FID_1911
#      [Setup]  Run Keywords
#    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO909
#    ...  AND  Set Test Variable  @{CUSTOM_RADIO_UNIT_LIST}  L123456
#    Execute Test In Loop  RF Fault Signature FID1911
#  [Teardown]  Configuration Postcondition
#
#[1.0] Automated_SiSo_FM_Fault_Signature_FID_1981
#  [Setup]  Run Keywords
#    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO909
#    ...  AND  Set Test Variable  @{CUSTOM_RADIO_UNIT_LIST}  L123456
#    Execute Test In Loop  RF Fault Signature FID1981
#  [Teardown]  Configuration Postcondition
#
#[1.0] Automated_SiSo_FM_Fault_Signature_FID_4589
#  [Setup]  Run Keywords
#    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO909
#    ...  AND  Set Test Variable  @{CUSTOM_RADIO_UNIT_LIST}  L123456
#    Execute Test In Loop  RF Fault Signature FID4589
#  [Teardown]  Configuration Postcondition
#
#[1.0] Automated_SiSo_FM_Fault_Signature_FID_4590
#      [Setup]  Run Keywords
#    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO909
#    ...  AND  Set Test Variable  @{CUSTOM_RADIO_UNIT_LIST}  L123456
#    Execute Test In Loop  RF Fault Signature FID4590
#  [Teardown]  Configuration Postcondition
#
#[1.0] Automated_SiSo_CM_LTE_Configuring_UL_CoMp
#      [Setup]  Run Keywords
#    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO909
#    ...  AND  Set Test Variable  ${UL_COMP_LIST}  ${BASIC_UL_COMP_LIST}
#    ...  AND  Set Test Variable  ${DELTA}  L123456
#    ...  AND  Set Test Variable  ${DELTA_RESET}  ${False}
#    Execute Test In Loop  Configuring UL CoMP
#  [Teardown]  Configuration Postcondition
#
#[1.0] Automated_SiSo_CM_LTE_Removing_And_Adding_A_Carrier_To_Ul_CoMp_Pool
#      [Setup]  Configuration Precondition    CN=REF_10_16_UTESRANSISO909
#    Execute Test In Loop  Removing And Adding Carrier In UL CoMP Pools
#  [Teardown]  Configuration Postcondition
#
#[1] Deactivating Activating UL CoMP
#      [Setup]  Configuration Precondition    CN=REF_10_16_UTESRANSISO909
#    Execute Test In Loop  Deactivating Activating UL CoMP
#  [Teardown]  Configuration Postcondition
#
#[1.0] Automated_SiSo_CM_LTE_Removing_And_Adding_An_UL_CoMp_Pool
#      [Setup]  Run Keywords
#    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO909
#    ...  AND  Set Test Variable  ${UL_COMP_LIST}  ${BASIC_UL_COMP_LIST}
#    Execute Test In Loop  Removing And Adding UL CoMP Pools
#  [Teardown]  Configuration Postcondition
#
#[1.0] Automated_SiSo_Startup_LTE_Ulcomp_without_HWF
#    [Setup]  Run Keywords
#    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO909
#    ...  AND  Set Test Variable  ${node}  ${cfg.active_bts_list}[0]
#    Execute Test In Loop  Startup Ul Comp Without HWF
#  [Teardown]  Configuration Postcondition
#
#[1.0] Automated__SiSo__Alarm__RF_1837_CPRIA
#  [Setup]  Run Keywords
#    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO909
#    ...  AND  Set Test Variable  ${alias}  ${cfg.primary_node_bts_id}
#    ...  AND  Set Test Variable  ${rf_serial_number}  L123456
#    ...  AND  Set Test Variable  ${fault_count}  1
#    ...  AND  Set Test Variable  ${WAY_OF_GENERATION_FAULT}  SendFault
#    ...  AND  Set Test Variable  ${FR_UNDER_TEST_PRODUCT_TYPE}=      CPRI
#    Execute Test In Loop  Automated__SiSo__Alarm__RF_1837
#  [Teardown]  Configuration Postcondition
#
#[1.0] Automated__SiSo__Alarm__RF_1838_CPRIA
#      [Setup]  Run Keywords
#    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO909
#    ...  AND  Set Test Variable  ${alias}  ${cfg.primary_node_bts_id}
#    ...  AND  Set Test Variable  ${rf_serial_number}  L123456
#    ...  AND  Set Test Variable  ${fault_count}  1
#    ...  AND  Set Test Variable  ${WAY_OF_GENERATION_FAULT}  SendFault
#    ...  AND  Set Test Variable  ${FR_UNDER_TEST_PRODUCT_TYPE}=      CPRI
#    Execute Test In Loop  Automated__SiSo__Alarm__RF_1838
#  [Teardown]  Configuration Postcondition
#

#[2.0] Automated__SiSo__Alarm__RF_1837
#  [Setup]  Run Keywords
#    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO909
#    ...  AND  Set Test Variable  ${alias}  ${cfg.primary_node_bts_id}
#    ...  AND  Set Test Variable  ${rf_serial_number}  L123456
#    ...  AND  Set Test Variable  ${fault_count}  1
#    ...  AND  Set Test Variable  ${WAY_OF_GENERATION_FAULT}  SendFault
#    ...  AND  Set Test Variable  ${FR_UNDER_TEST_PRODUCT_TYPE}=      OBSAI
#    Execute Test In Loop  Automated__SiSo__Alarm__RF_1837
#  [Teardown]  Configuration Postcondition
#
#[2.0] Automated__SiSo__Alarm__RF_1838
#      [Setup]  Run Keywords
#    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO909
#    ...  AND  Set Test Variable  ${alias}  ${cfg.primary_node_bts_id}
#    ...  AND  Set Test Variable  ${rf_serial_number}  L123456
#    ...  AND  Set Test Variable  ${fault_count}  1
#    ...  AND  Set Test Variable  ${WAY_OF_GENERATION_FAULT}  SendFault
#    ...  AND  Set Test Variable  ${FR_UNDER_TEST_PRODUCT_TYPE}=      OBSAI
#    Execute Test In Loop  Automated__SiSo__Alarm__RF_1838
#  [Teardown]  Configuration Postcondition


#[1.0] Automated__SiSo__Alarm__RF_1923
#      [Setup]  Run Keywords
#    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO909
#    ...  AND  Set Test Variable  ${alias}  ${cfg.primary_node_bts_id}
#    ...  AND  Set Test Variable  ${rf_serial_number}  L123456
#    ...  AND  Set Test Variable  ${WAY_OF_GENERATION_FAULT}  Normal
#    Execute Test In Loop  Automated__SiSo__Alarm__RF_1923
#  [Teardown]  Configuration Postcondition
#
#[1.0] Automated__SiSo__Alarm__RF_1932
#      [Setup]  Run Keywords
#    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO909
#    ...  AND  Set Test Variable  ${alias}  ${cfg.primary_node_bts_id}
#    ...  AND  Set Test Variable  ${rf_serial_number}  L123456
#    Execute Test In Loop  Automated__SiSo__Alarm__RF_1932
#  [Teardown]  Configuration Postcondition
#
#[1.0] Automated__SiSo__Alarm__RF_1933
#      [Setup]  Run Keywords
#    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO909
#    ...  AND  Set Test Variable  ${alias}  ${cfg.primary_node_bts_id}
#    ...  AND  Set Test Variable  ${rf_serial_number}  L123456
#    Execute Test In Loop  Automated__SiSo__Alarm__RF_1933
#  [Teardown]  Configuration Postcondition
#
#[1.0] Automated__SiSo__Alarm__RF_1934
#  [Setup]  Run Keywords
#    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO909
#    ...  AND  Set Test Variable  ${alias}  ${cfg.primary_node_bts_id}
#    ...  AND  Set Test Variable  ${rf_serial_number}  L123456
#    ...  AND  Set Test Variable  ${WAY_OF_GENERATION_FAULT}  Normal
#    Execute Test In Loop  Automated__SiSo__Alarm__RF_1934
#  [Teardown]  Configuration Postcondition
#
#[1.0] Automated__SiSo__Alarm__RF_1936
#      [Setup]  Run Keywords
#    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO909
#    ...  AND  Set Test Variable  ${alias}  ${cfg.primary_node_bts_id}
#    ...  AND  Set Test Variable  ${rf_serial_number}  L123456
#    ...  AND  Set Test Variable  ${WAY_OF_GENERATION_FAULT}  Normal
#    Execute Test In Loop  Automated__SiSo__Alarm__RF_1936
#  [Teardown]  Configuration Postcondition
#
#[1.0] Automated__SiSo__Alarm__RF_1937
#      [Setup]  Run Keywords
#    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO909
#    ...  AND  Set Test Variable  ${alias}  ${cfg.primary_node_bts_id}
#    ...  AND  Set Test Variable  ${rf_serial_number}  L123456
#    ...  AND  Set Test Variable  ${H_CONFIG}
#    ...  AND  Set Test Variable  ${fault_count}  1
#    ...  AND  Set Test Variable  ${WAY_OF_GENERATION_FAULT}  SendFault
#    Execute Test In Loop  Automated__SiSo__Alarm__RF_1937
#  [Teardown]  Configuration Postcondition
#
#[1.0] Automated__SiSo__Alarm__RF_1938
#      [Setup]  Run Keywords
#    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO909
#    ...  AND  Set Test Variable  ${alias}  ${cfg.primary_node_bts_id}
#    ...  AND  Set Test Variable  ${rf_serial_number}  L123456
#    ...  AND  Set Test Variable  ${H_CONFIG}
#    ...  AND  Set Test Variable  ${fault_count}  1
#    ...  AND  Set Test Variable  ${WAY_OF_GENERATION_FAULT}  SendFault
#    Execute Test In Loop  Automated__SiSo__Alarm__RF_1938
#  [Teardown]  Configuration Postcondition
#
#[1.0] Automated__SiSo__Alarm__RF_1957
#      [Setup]  Run Keywords
#    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO909
#    ...  AND  Set Test Variable  ${alias}  ${cfg.primary_node_bts_id}
#    ...  AND  Set Test Variable  ${rf_serial_number}  L123456
#    Execute Test In Loop  Automated__SiSo__Alarm__RF_1957
#  [Teardown]  Configuration Postcondition
#
#[1.0] Automated_SiSo_RU_BlackBox_enhancements_testing
#      [Setup]  Run Keywords
#    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO909
#    ...  AND  Set Test Variable  ${CONFIGURATION_SWUPDATE_TIMEOUT}  1200
#    ...  AND  Set Test Variable  @{CUSTOM_RADIO_UNIT_LIST}  L123456
#    Execute Test In Loop  Bbox combo
#  [Teardown]  Configuration Postcondition
#
#[1.0] Automated_ SiSo_RU_ASIR_Block_Unblock_pRRH_From_ASIRWebEM
#      [Setup]  Run Keywords
#    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO909
#    ...  AND  Set Test Variable  @{CUSTOM_RADIO_UNIT_LIST}  L123456
#    TC_SiSo_RU_ASIR_Block_Unblock_pRRH_From_ASIRWebEM
#  [Teardown]  Configuration Postcondition
#
#Automated__SiSo_RU_ASIR_Block_One_pRRH_From_ASIRWebEM_Not_Impact_Call_On_Other_pRRH
#      [Setup]  Run Keywords
#    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO909
#    ...  AND  Set Test Variable  @{CUSTOM_RADIO_UNIT_LIST}  L123456
#    TC_SiSo_RU_ASIR_Block_One_pRRH_From_ASIRWebEM_Not_Impact_Call_On_Other_pRRH
#  [Teardown]  Configuration Postcondition
#
#[1.0] Automated_SiSo_RU_ASIR_Reset_pRRH_From_ASIRWebEM
#      [Setup]  Run Keywords
#    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO909
#    ...  AND  Set Test Variable  @{CUSTOM_RADIO_UNIT_LIST}  L123456
#    TC_SiSo_RU_ASIR_Reset_pRRH_From_ASIRWebEM
#  [Teardown]  Configuration Postcondition
#
#
#[1.0] Automated_ SiSo_RU_ASIR_Unplug_Plug_pRRH
#      [Setup]  Run Keywords
#    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO909
#    ...  AND  Set Test Variable  @{CUSTOM_RADIO_UNIT_LIST}  L123456
#    TC_SiSo_RU_ASIR_Unplug_Plug_pRRH
#  [Teardown]  Configuration Postcondition
#
#[1.0] Automated_SiSo_Fault_Management_RF_EAC_check
#      [Setup]  Configuration Precondition    CN=REF_10_16_UTESRANSISO909
#    Automated_SiSo_Fault_Management_RF_EAC_check
#  [Teardown]  Configuration Postcondition
#
#[1.0] TC_SiSo_RU_Lock_Unlock_ASIR_HUB_From_WebEM
#      [Setup]  Configuration Precondition    CN=REF_10_16_UTESRANSISO909
#    TC_SiSo_RU_Lock_Unlock_ASIR_HUB_From_WebEM
#  [Teardown]  Configuration Postcondition
#
#[1.0] TC_SiSo_SM_RU_Primary_link_break_in_chaining
#      [Setup]  Configuration Precondition    CN=REF_10_16_UTESRANSISO909
#    TC_SiSo_SM_RU_Primary_link_break_in_chaining
#  [Teardown]  Configuration Postcondition
#
#[1.0] TC_SiSo_SM_RU_Primary_link_break
#      [Setup]  Configuration Precondition    CN=REF_10_16_UTESRANSISO909
#    TC_SiSo_SM_RU_Primary_link_break
#  [Teardown]  Configuration Postcondition
#
#[1.0] TC_SiSo_SM_RU_Primary_link_break_without_recovery
#      [Setup]  Configuration Precondition    CN=REF_10_16_UTESRANSISO909
#    TC_SiSo_SM_RU_Primary_link_break_without_recovery
#  [Teardown]  Configuration Postcondition
#
#[1.0] TC_SiSo_SM_RU_Secondary_link_break
#      [Setup]  Configuration Precondition    CN=REF_10_16_UTESRANSISO909
#    TC_SiSo_SM_RU_Secondary_link_break
#  [Teardown]  Configuration Postcondition
#
#[1.0] TC_SiSo_SM_RU_Secondary_link_break_in_chaining
#      [Setup]  Configuration Precondition    CN=REF_10_16_UTESRANSISO909
#    TC_SiSo_SM_RU_Secondary_link_break_in_chaining
#  [Teardown]  Configuration Postcondition
#
#
#[1.0] TC__SiSo_REC_RU_Safe_Mode_Improper_Voltage_Input
#      [Setup]  Configuration Precondition    CN=REF_10_16_UTESRANSISO909
#    TC__SiSo_REC_RU_Safe_Mode_Improper_Voltage_Input
#  [Teardown]  Configuration Postcondition
#
#[1.0] Automated__SiSo__Alarm__FHS_1932
#      [Setup]  Configuration Precondition    CN=REF_10_16_UTESRANSISO909
#    Automated__SiSo__Alarm__FHS_1932
#  [Teardown]  Configuration Postcondition
#
#[1.0] Automated__SiSo__Alarm__FHS_1933
#      [Setup]  Configuration Precondition    CN=REF_10_16_UTESRANSISO909
#    Automated__SiSo__Alarm__FHS_1933
#  [Teardown]  Configuration Postcondition
#
#[1.0] Automated__SiSo__Alarm__FHS_1936
#      [Setup]  Configuration Precondition    CN=REF_10_16_UTESRANSISO909
#    Automated__SiSo__Alarm__FHS_1937
#  [Teardown]  Configuration Postcondition
#
#[1.0] Automated__SiSo__Alarm__FHS_1937
#      [Setup]  Configuration Precondition    CN=REF_10_16_UTESRANSISO909
#    Automated__SiSo__Alarm__FHS_1936
#  [Teardown]  Configuration Postcondition
#
#[1.0] SiSo_Antenna Line Management_Overcurrent_alarm_with_MHA
#      [Setup]  Configuration Precondition    CN=REF_10_16_UTESRANSISO909
#    Automated SiSo_Antenna Line Management_Overcurrent_alarm_with_MHA
#  [Teardown]  Configuration Postcondition
