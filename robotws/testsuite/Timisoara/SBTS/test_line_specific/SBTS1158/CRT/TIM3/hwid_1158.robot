*** Settings ***
Force Tags  QCD_MN_RAN  QCP_RAN_ST  SBTS00  SRAN  CLOUD_SRAN_LG_1FSMF_1FBBC_2FXDB_2FRMA_1FRHC  STATE_SKIP_AGENT
Library  XML  use_lxml=True
Library  taf.sw.scout
Library  String
Suite Setup      Set Library Search Order  coam   ute_admin   hran_frame_sbts_taf   hran_frame_sbts_siso   ca_CIT_general   ca_swm_general


*** Variables ***
${SCF_ID}    01
${HW_LOCATION_CODE}      Timisoara


*** Test Cases ***
[1]WebEM__RF_successful_start_up_notification_in_Web_Element_Manager
    [Tags]  QC_136686
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API
	
	
[1]WebEM__5G_Show Cells part status in BTS Start-up view for 5G
    [Tags]  QC_95677
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

	
[1]Automated__CM__Commissioning_planned_commissioning
    [Tags]  QC_70252
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API
	
	
[1]Automated__STATE__WCDMA_RAT_reset_from_ADMIN
    [Tags]  QC_70261 
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

	
[1]Automated__FM__Recovery_whole_multiple_Link_Break
    [Tags]  QC_70259 
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API
	
	
[1]Automated__STATE__Site_reset
    [Tags]  QC_70258 
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

	
[1]Automated__STATE__LTE_RAT_reset_from_ADMIN
    [Tags]  QC_70264 
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API
	
	
[1]Automated__STATE__GSM_BCF_lock_unlock_from_BSC
    [Tags]  QC_70257
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API
	
	
[1]Automated__STATE__GSM_BCF_block_unblock_from_ADMIN
    [Tags]  QC_70253 
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

	
[1]Automated__STATE__RF_Module_lock_unlock
    [Tags]  QC_70251 
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API
	
	
[1]SFP_Monitoring_via_Diagnostic_tab
    [Tags]  QC_231867 
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API
	
[1]Run_RF_Diagnostic_test_using_WebEM_all_retrieved_measurements_do_fall_within_the_thresholds
    [Tags]  QC_90746 
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API
	
	
[1]CB005958-D_M55601C01002_Number_cell_planned_unavailable_with_modification_of parameters_requiring_object_locking_WebUI_004
    [Tags]  QC_90747
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API
	
	
[1]Trigger and clear FID 181
    [Tags]  QC_83494 
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

	
[1]WebEM__5G_cells_graceful_shutdown
    [Tags]  QC_90194 
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API
	
	
[1]WebEM__Mobile_Simplified_Site_View_Performing_Operations_on_Selected_Units
    [Tags]  QC_105941 
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API
	
	
[1]WebEM__Wizard_Deleting_WCDMA_RAT
    [Tags]  QC_416671
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API
	
	
[1]WebEM__Basic_Sanity_Check_Simplified_Site_View_Operations
    [Tags]  QC_111356
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

	
[1]5G RAT Block_Unblock
    [Tags]  QC_112121
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API
	
	
[1]5G RAT reset via ADMIN
    [Tags]  QC_112122 
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

	
[1]Automated__CM__Commissioning_planned_commissioning
    [Tags]  QC_70263 
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API
	
	
[1]Automated__STATE__Site_reset
    [Tags]  QC_70255 
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

	
[1]Site_reset_without_HWF_in_loop
    [Tags]  QC_133125
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API
	
	
[1]Site_reset_without_HWF_in_loop
    [Tags]  QC_136522
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API
	
	
[1]WebEM__Antenna_Line_Monitoring
    [Tags]  QC_164214 
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

	
[1]WebEM__Check_operational_state_of_each_RAT_and_BTS
    [Tags]  QC_227134 
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API
	
	
[1]WebEM__Description_of_HW_units_based_on_their_Product_Code
    [Tags]  QC_227135
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API
	
[1]WebEM__Reset_operation_for_BBMOD
    [Tags]  QC_227136 
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API
	
	
[1]WebEM__Simplified_Site_View_BBMOD_and_SMOD_visualization
    [Tags]  QC_227137
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API
	
	
[1]WebEM__Simplified_Site_View_sorting_and_ordering_capabilities
    [Tags]  QC_227138 
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

	
[1]WebEM__Check_appLoginBannerText
    [Tags]  QC_231835 
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API
	
	
[1]WebEM__Check_login_banner_text_file_permission
    [Tags]  QC_231836 
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API
	
	
[1]WebEM__Check_platLoginBannerText
    [Tags]  QC_94498
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API
	
	
[1]WebEM__Empty_platLoginBannerText
    [Tags]  QC_231837
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

	
[1]WebEM__Show_BTS_Start-up_view_automatically
    [Tags]  QC_178120
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API
	
	
[1]WebEM__5G_Delta_plan_activation_for_parameters
    [Tags]  QC_184083 
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

	
[1]WebEM__Site_Report
    [Tags]  QC_195783 
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API
	
	
[1]WebEM__Baseband_module_lock_unlock
    [Tags]  QC_226451
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

	
[1]WebEM__Viewing_BTS_Performance_Counter_for_5G
    [Tags]  QC_226452
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API
	
	
[1]WebEM__Check_operational_state_of_each_RAT_and_BTS
    [Tags]  QC_227134
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API
	
	
[1]WebEM__Description_of_HW_units_based_on_their_Product_Code
    [Tags]  QC_227135 
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

	
[1]WebEM__Reset_operation_for_BBMOD
    [Tags]  QC_227136
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API
	
	
[1]WebEM__Simplified_Site_View_BBMOD_and_SMOD_visualization
    [Tags]  QC_227137 
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API
	
[1]WebEM__Simplified_Site_View_sorting_and_ordering_capabilities
    [Tags]  QC_227138
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API
	
	
[1]WebEM__SFP_Monitoring_via_Diagnostic_tab
    [Tags]  QC_231867
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API
	
	
[1]WebEM__Get_Tuning_History_Report_with_Mozilla_and_Chrome
    [Tags]  QC_231868 
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

	
[1]WebEM__Filtering_active_alarms
    [Tags]  QC_264319 
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API
	
	
[1]WebEM__Automatically_log_off_and_Session_Lock
    [Tags]  QC_264320 
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API
	
	
[1]WebEM__Description_of_HW_units_based_on_their_Product_Code
    [Tags]  QC_227135
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API
	
	
[1]WebEM__SW_Rollback
    [Tags]  QC_264322
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

	
[1]WebEM__User_rights_downgrade
    [Tags]  QC_264323
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API
	
	
[1]WebEM__Navigation_Menu
    [Tags]  QC_264324
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

	
[1]WebEM__Simplified_Site_View_cell_groups_visualization
    [Tags]  QC_264325 
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API
	
	
[1]WebEM__Simplified_Site_View_cells_visualization
    [Tags]  QC_264326
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

	
[1]WebEM__Simplified_Site_View_Master_Mode_visualization
    [Tags]  QC_264327
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API
	
	
[1]SWM__SCF_validation_errors_check
    [Tags]  QC_237264
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API
	
	
[1]WebEM__Enable_Disable_Energy_Consumption_Measurement_Collectection
    [Tags]  QC_264318 
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

	
[1]WebEM Navigation Menu_ Mirroring activation
    [Tags]  QC_363429
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API
	
	
[1]WebEM Navigation Menu_ Saving BTS Technical Report
    [Tags]  QC_363430 
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API
	
[1]WebEM__Filtering_active_historical_BTS_alarm_list
    [Tags]  QC_270900 
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API
	
	
[1]WebEM__Admin_CLI_Radio_Reset
    [Tags]  QC_270919
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API
	
	
[1]WebEM_Admin_CLI_getActiveAlarms
    [Tags]  QC_276904 
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

	
[1]WebEM__Admin_CLI_getRmodMeasurementsById
    [Tags]  QC_322966 
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API
	
	
[1]WebEM__BTS_Block_Unblock
    [Tags]  QC_322967 
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API
	
	
[1]WebEM__Debug_tracing_when_5G_and_4G_are_not_commissioned
    [Tags]  QC_333232
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API
	
	
[1]WebEM__Configuration_reset
    [Tags]  QC_342735 
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

	
[1]WebEM__Activation_of_Energy_Consumption_Measurement_collection
    [Tags]  QC_351160
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API
	
	
[1]WebEM__LTEL2CellConfigurationCollector_script
    [Tags]  QC_408076 
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API
	
[1]WebEM__Mobile_Simplified_Site_View_for_ASOE
    [Tags]  QC_384251
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API
	
	
[1]WebEM Remote Tool - getLoglinkList
    [Tags]  QC_392505
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API
	
	
[1]WebEM__Loading_duration_until_runtime_view
    [Tags]  QC_411445 
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

	
[1]WebEM__Admin_CLI_Get_RAD_SW_Domains
    [Tags]  QC_440018
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API
	
	
[1]WebEM__RAD_debug_parameters
    [Tags]  QC_442284 
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API
	
	
*** Keywords ***
