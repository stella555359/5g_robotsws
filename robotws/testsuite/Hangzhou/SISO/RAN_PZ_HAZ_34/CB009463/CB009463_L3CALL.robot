*** Settings ***
Suite Setup          SISO Suite Setup
Suite Teardown       SISO Suite Teardown
#Test Setup           SISO Test Setup
#Test Teardown        SISO Test Teardown
Test Timeout         600 min

Resource      Resource/CB009463_old_siso_Resource.robot

Documentation
...    Author:Frank Luo
...    contact:frank.s.luo@nokia-sbell.com
...    squad group:SG_01
...    Feature CB005845 in 5G22R2 program

Force Tags            RAN_5G    RAN_5G_TDD    STATE_SW_UPLOADED  SBTS00
...    CLOUD_5G_CLASSICAL_QC_SA_ASILL_ABINB1_2xAEQE    PY36

##*** Variables ***

*** Test Cases ***
TC.x85
    TC.x85

TC.Manual_SiSo_STARTUP_BTS_Power_Reset
    [Tags]    L3call
    [Setup]    SISO Test Setup
    [Teardown]  SISO Test Teardown
    [Timeout]  60min
    CommonCase.Manual_SiSo_STARTUP_BTS_Power_Reset    scf_file=${CFGFILE_PATH}/${casescf}

TC.Manual_SiSo_SM_RF_Module_lock_unlock
    [Tags]     L3call    CIT_TRUNK
    [Setup]    SISO Test Setup
    [Teardown]  SISO Test Teardown
    [Timeout]  60min
    CommonCase.Manual_SiSo_SM_RF_Module_lock_unlock   scf_file=${CFGFILE_PATH}/${casescf}

TC.Manual_SiSo_SM_BTS_Site_Reset
    [Tags]     L3call
    [Setup]    SISO Test Setup
    [Teardown]  SISO Test Teardown
    [Timeout]  60min
    CommonCase.Manual_SiSo_SM_BTS_Site_Reset   scf_file=${CFGFILE_PATH}/${casescf}

[1][2.0] General_SiSo_Cell_block_and_unblock_with_L3call
    [Tags]     L3call
    [Setup]    SISO Test Setup
    [Teardown]  SISO Test Teardown
    [Timeout]  60min
    TC.62_Manual_SiSo_SM_LTE Cell_block_unblock   scf_file=${CFGFILE_PATH}/${casescf}

[1][1.0] General_SiSo_E2E_system_setup_with_data_transfer_conducted_Band_50M_with_4T4R
    [Tags]     L3call    CRT_TRUNK
    [Setup]    SISO Test Setup
    [Teardown]  SISO Test Teardown
    TC.24_General_SiSo_E2E_system_setup_with_data_transfer    TCID=50M_with_4T4R   ul=10   dl=25
    ...   scf=${CFGFILE_PATH}/${Band_50M_with_4T4R}    peak_use_tool=${TCCB009463_INPUT['E2E_with_data_transfer']['peak_use_tool']}

[1][1.0] General_SiSo_E2E_system_setup_with_data_transfer_conducted_Band_100M_with_4T4R
    [Tags]     L3call    CRT_TRUNK
    [Setup]    SISO Test Setup
    [Teardown]  SISO Test Teardown For CB009509
    TC.General_SiSo_E2E_system_setup_with_data_transfer_For_Streams    ul=10   dl=25
     ...    scf1=${CFGFILE_PATH}/TL_BASE_SCF_NR.xml      scf2=${CFGFILE_PATH}/CB009509_BASE_SCF_NR.xml
     ...    scf3=${CFGFILE_PATH}/CB009509_BASE_SCF_NR.xml

[1][1.0] General_SiSo_E2E_system_setup_with_data_transfer_conducted_Band_40M_with_4T4R
    [Tags]     L3call
    [Setup]    SISO Test Setup
    [Teardown]  SISO Test Teardown
    TC.24_General_SiSo_E2E_system_setup_with_data_transfer    TCID=40M_with_4T4R   ul=5   dl=5
    ...   scf=${CFGFILE_PATH}/${Band_40M_with_4T4R}

[1][1.0] General_SiSo_E2E_system_setup_with_data_transfer_conducted_Band_30M_with_4T4R
    [Tags]     L3call
    [Setup]    SISO Test Setup
    [Teardown]  SISO Test Teardown
    TC.24_General_SiSo_E2E_system_setup_with_data_transfer    TCID=30M_with_4T4R   ul=5   dl=5
    ...   scf=${CFGFILE_PATH}/${Band_30M_with_4T4R}

[1][1.0] General_SiSo_E2E_system_setup_with_data_transfer_conducted_Band_20M_with_4T4R
    [Tags]     L3call
    [Setup]    SISO Test Setup
    [Teardown]  SISO Test Teardown
    TC.24_General_SiSo_E2E_system_setup_with_data_transfer    TCID=20M_with_4T4R   ul=5   dl=5
    ...   scf=${CFGFILE_PATH}/${Band_20M_with_4T4R}

[1][1.0] General_SiSo_E2E_system_setup_with_data_transfer_conducted__Band_10M_with_4T4R
    [Tags]     L3call
    [Setup]    SISO Test Setup
    [Teardown]  SISO Test Teardown
    TC.24_General_SiSo_E2E_system_setup_with_data_transfer    TCID=10M_with_4T4R   ul=5   dl=5
    ...   scf=${CFGFILE_PATH}/${Band_10M_with_4T4R}

#General_SiSo_E2E_system_setup_with_data_transfer_conducted_with_single_carrier_40M_with_4T4R_without_split_mode
#    [Tags]     L3call
#    [Timeout]  60min
#    TC.Peak throughput with DL 256QAM Modulation on different bandwidth    TCID=40M_with_4T4R   ul=5   dl=5
#    ...   scf=${CFGFILE_PATH}/${Band_40M_4T4R}


###################################3
#[1][1.0] OAM_KPI_61a_SiSo_Auto_BTS_site_reset
#    [Tags]    Case_29    sky_ready    sky_bts   AWHKB   2ccPASS
#    TC.28_OAM_KPI_61a_SiSo_Auto_BTS_site_reset


#
#[1][2.0] General_SiSo_RU_module_reset_from_GUI_2cc_100M
#    [Tags]    Case_12    PASS   CRT_TRUNK   AWHKB(pass)    2cc(PASS)    CIT_22R4
#    TC.12_General_SiSo_RF_module_reset_from_GUI   scf_file=${CFGFILE_PATH}/${casescf_2cc_100m}
#
#
#

#
#[1][2.0] General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot_2cc_100m
#    [Tags]    Case_26    PASS_ON_CPRI    AEQN_miss_1011_journal_startup.zip
#    ...     CRT_UTE   AWHKB(pass)   2ccPASS    CRT_TRUNK   CIT_22R4
#    TC.25_General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot   scf_file=${CFGFILE_PATH}/${casescf_2cc_100m}
#
#
##[1][1.0] General_SiSo_Commissioning_BTS_Template_Commissioning_2cc_100m
##    [Tags]    Case_02    PASS   AWHKB(pass)   2ccPASS
##    TC.02_General_SiSo_Commissioning_BTS_Template_Commissioning   scf_file=${CFGFILE_PATH}/${casescf_2cc_100m}
#
#[1][1.0] General_SiSo_LED_states_management_basic
#    [Tags]    Case_20    PASS   AWHKB(pass)   2ccPASS    pass
#    TC.20_General_SiSo_LED_states_management_basic
#
##[1][1.0] General_SiSo_RU_lock_unlock
##    [Tags]    Case_17    FAIL    not-ready            CRT_UTE   AWHKB   invalid
##    TC.17_General_SiSo_RU_lock_unlock    scf_file=${CFGFILE_PATH}/${casescf}
###
###[1][1.0] General_SiSo_RU_lock_unlock_2cc_20m
###    [Tags]    Case_17    FAIL    not-ready            CRT_UTE   AWHKB    invalid
###    TC.17_General_SiSo_RU_lock_unlock   scf_file=${CFGFILE_PATH}/${casescf_2cc_20m}
##
#[1][1.0] OAM_KPI_651_SiSo_Auto_RF_reset_success_rate_from_WebUI_with_L3Call
#    [Tags]    Case_28    sky_ready    sky_rf   AWHKB   2ccPASS
#    TC.27_OAM_KPI_651_SiSo_Auto_RF_reset_success_rate_from_WebUI_with_L3Call
#
#
##
#[1][1.0] General_SiSo_Auto_Cell_lock_and_unlock_with_L3call
#    [Tags]    Case_38    sky_ready    sky_lock    AWHKB
#    TC.60_General_SiSo_Auto_Cell_lock_and_unlock_with_L3call    scf_file=${CFGFILE_PATH}/${casescf}
#
#[1][1.0] General_SiSo_Auto_Cell_lock_and_unlock_with_L3call_2cc_100m
#    [Tags]    Case_38    sky_ready    sky_lock    AWHKB
#    TC.60_General_SiSo_Auto_Cell_lock_and_unlock_with_L3call    scf_file=${CFGFILE_PATH}/${casescf_2cc_100m}
#
#
#
#[1][2.0] General_SiSo_Cell_block_and_unblock_with_L3call_2cc_100m
#    [Tags]    CRT_TRUNK   OAM    OAM_10   OAM_PASS
#    [Timeout]  60min
#    TC.62_Manual_SiSo_SM_LTE Cell_block_unblock   scf_file=${CFGFILE_PATH}/${casescf_2cc_100m}
#

##
##[1][1.0] General_SiSo_BTS_startup_with_RF_delayed_startup_2cc_100m
##    [Tags]    Case_15    PASS        CRT_UTE    pass
##    TC.15_General_SiSo_BTS_startup_with_RF_delayed_startup   scf_file=${CFGFILE_PATH}/${casescf_2cc_100m}
#
#
#
#[1][1.0] 5GC000560_eCPRI_sync_generic_startup_at_RU
#    [Tags]    Case_41    PASS
#    TC.51_5GC000560_eLLF_sync_generic_startup_at_RU
#
#
#
#
#
#
#
#
#
#
#
#
####################################################################################
##[1][1.0] General_SiSo_SOAP_RP1_verification
##    [Tags]    Case_09    PASS    CPRI   AWHKB(pass)   2cc(PASS)
##    TC.09_General_SiSo_SOAP_RP1_verification
##
#
##
##[1][1.0] General_SiSo_Cell_lock_and_unlock
##    [Tags]    Case_16    PASS   CRT_TRUNK    feiqi   AWHKB(pass)
##    TC.16_General_SiSo_Cell_lock_and_unlock
##
##[1][1.0] General_SiSo_RF_alarms_with_recovery
##    [Tags]    Case_21    PASS    CRT_UTE   AWHKB(pass)   2ccPASS
##    TC.21_General_SiSo_RF_alarms_with_recovery
##
##
#
##
###[1][1.0] General_SiSo_stability_with_L3Call
###    [Tags]    Case_25    sky_ready    sky_st    AWHKB
###    TC.61_General_SiSo_stability_with_L3Call
###    #TC.24_General_SiSo_E2E_system_setup_with_data_transfer
##
##
##
##
###[1][1.0] OAM_KPI_64_SiSo_Auto_RU_SW_upgrade_success_rate
###    [Tags]    Case_30    sky_ready    sky_sw    AWHKB(TA not suitable ,maual test)    2cc(PR649175)
###    TC.29_OAM_KPI_64_SiSo_Auto_RU_SW_upgrade_success_rate
##
##[1][1.0] General_SiSo_Link_Diagnostic_and_Monitoring
##    [Tags]    Case_31    PASS    AWHKB(PASS manual test)    2cc(PASS manual test)
##    TC.30_General_SiSo_Link_Diagnostic_and_Monitoring
##
###[1][1.0] 5GC000584_RU_Module_Certificate_Integrity
###    [Tags]    Case_32    PASS    AWHKB(Fail function not support)
###    TC.31_General_RU_Module_Certificate_Integrity
##
##[1][1.0] General_SiSo_Online_Cell_addition_deletion
##    [Tags]    Case_18    not-ready    AWHKB(pass)   2CC(pass)
##    TC.18_General_SiSo_Online_Cell_addition_deletion
##
##[1][1.0] General_SiSo_LED_states_management_additional_scenarios
##    [Tags]    Case_43    PASS   AWHKB(pass)
##    TC.55_General_SiSo_LED_states_management_additional_scenarios
##
#####################################################################
#
#
###
###[1][1.0] 5GC000399_eCPRI_U-plane_Fast_C-plane_counters
###    [Tags]    Case_05    PASS    ECPRI
###    TC.05_General_SiSo_U-plane_Fast_C-plane_counters
###
###[1][1.0] 5GC000399_eCPRI_FREERUN_state_handling
###    [Tags]    Case_06        PASS    ECPRI
###    TC.06_5GC000399_eCPRI_FREERUN_state_handling
###
###[1][1.0] 5GC000561_eCPRI_sync_generic_startup_at_RAU
###    [Tags]    Case_07    PASS    ECPRI
###    TC.07_5GC000561_eCPRI_sync_generic_startup_at_RAU
###
###[1][1.0] 5GC000561_eCPRI_sync_counters
###    [Tags]    Case_08    ECPRI    FAIL    not-ready
###    TC.08_5GC000561_eCPRI_sync_counters
###
###
###[1][1.0] General_SiSo_Automatic_RAT_SW_upgrade
###    [Tags]    Case_10    not-ready
###    TC.10_General_SiSo_Auto_Automatic_RAT_SW_upgrade
###
###
###[1][1.0] General_SiSo_RF_module_reset_triggered_by_user_as_part_of_BTS_reset
###    [Tags]    Case_13    FAIL    not-ready
###    TC.13_General_SiSo_RF_module_reset_triggered_by_user_as_part_of_BTS_reset
###
###[1][1.0] General_SiSo_BTS_reset_with_RF_power_reset
###    [Tags]    Case_14    PASS
###    TC.14_General_SiSo_BTS_reset_with_RF_power_reset
###
##
##
###
#
###
###
###[1][1.0] General_SiSo_RF_module_IP_address_allocation
###    [Tags]    Case_27    PASS
###    TC.26_General_SiSo_RF_module_IP_adress_allocation
###
###
###
###[1][1.0] General_SiSo_ALD_Configuration_Management_ALD_site_commissioning
###    [Tags]    Case_33    PASS    CPRI
###    TC.32_General_SiSo_ALD_Configuration_Management_ALD_site_commissioning
###
###[1][1.0] General_SiSo_ALD_HW_inventory_ALD_HW_properties_retrieval_and_visualization
###    [Tags]    Case_34    PASS    CPRI
###    TC.33_General_SiSo_ALD_HW_inventory_ALD_HW_properties_retrieval_and_visualization
###
###[1][1.0] General_SiSo_ALD_State_Management_ALD_state_management_handling_and_visibility
###    [Tags]    Case_35    PASS    CPRI
###    TC.34_General_SiSo_ALD_State_Management_ALD_state_management_handling_and_visibility
###
###[1][1.0] General_SiSo_ALD_FM_Antenna_Line_Device_faulty_notification_recovery_action_indication_and_visualization
###    [Tags]    Case_36    PASS    CPRI
###    TC.35_General_SiSo_ALD_FM_Antenna_Line_Device_faulty_notification_recovery_action_indication_and_visualization
###
###[1][1.0] 5GC000560_eLLF_PTP_Failure
###    [Tags]    Case_37    PASS    ECPRI
###    TC.44_5GC000560_eLLF_PTP_Failure
###
###[1][1.0] 5GC000399_eCPRI_RP1_Supervision_failure
###    [Tags]    Case_39    not-ready
###    TC.52_5GC000399_eCPRI_RP1_Supervision_failure
###
##
###[1][1.0] General_SiSo_eCPRI_synchronization_status_NIDD_parameters
###    [Tags]    Case_40    PASS    ECPRI
###    TC.53_General_SiSo_eCPRI_synchronization_status_NIDD_parameters
###
###[1][1.0] General_SiSo_Automatic_factory_RFSW_update
###    [Tags]    Case_42    PASS
###    TC.54_General_SiSo_Automatic_factory_RFSW_update
###
###
###
###[1][1.0] General_SiSo_ALD_SW_Management_Create_ALD_Build_Descriptor_file
###    [Tags]    Case_44    PASS    CPRI
###    TC.56_General_SiSo_ALD_SW_Management_Create_ALD_Build_Descriptor_file
###
###[1][1.0] General_SiSo_ALD_Configuration_Management_RET_calibration_via_command
###    [Tags]    Case_45    PASS    CPRI
###    TC.57_General_SiSo_ALD_Configuration_Management_RET_calibration_via_command
###
###[1][1.0] General_SiSo_ALD_SW_Management_ALD_SW_Download_and_Activation
###    [Tags]    Case_46    PASS    CPRI
###    TC.58_General_SiSo_ALD_SW_Management_ALD_SW_Download_and_Activation
###
###[1][1.0] General_SiSo_ALD_Configuration_Management_RET_tilt_modification
###    [Tags]    Case_47    PASS    CPRI
###    TC.59_General_SiSo_ALD_Configuration_Management_RET_tilt_modification
###
###[1][1.0] General_SiSo_RF_module_addition_in_BIM_and_WebUI
###    [Tags]    Case_48    PASS
###    TC.36_General_SiSo_RF_module_addition_in_BIM_and_WebUI
##
#
#
