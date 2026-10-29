*** Settings ***
Force Tags  QCD_MN_RAN  QCP_RAN_ST  SBTS00  SRAN  CLOUD_SRAN_LG_1FSMF_1FBBC_2FXDB_2FRMA_1FRHC  STATE_SKIP_AGENT
Library  XML  use_lxml=True
Library  taf.sw.scout
Library  String
Suite Setup      Set Library Search Order  coam   ute_admin   hran_frame_sbts_taf   hran_frame_sbts_siso   ca_CIT_general   ca_swm_general

Resource    ../../CIT/test_resources/STATE__Site_reset.robot

*** Variables ***
${SCF_ID}    01
${HW_LOCATION_CODE}      Timisoara

*** Test Cases ***
[1]SWM__SCF_validation_errors_check
    [Tags]  QC_237264
    Setup Scout  10_18_UTESRANCLOUD1745
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__CM__Commissioning_planned_commissioning
    [Tags]  QC_124326
    Setup Scout  10_18_UTESRANCLOUD1312
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__Site_reset
    [Tags]  QC_124327
    Setup Scout  10_18_UTESRANCLOUD1312
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]WebEM__Mobile_Simplified_Site_View_for_ASOE
    [Tags]  QC_384251
    Setup Scout  10_18_UTESRANCLOUD1302
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]WebEM__LTEL2CellConfigurationCollector_script
    [Tags]  QC_408076
    Setup Scout  10_18_UTESRANCLOUD1302
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]WebEM__Admin_CLI_Get_RAD_SW_Domains
    [Tags]  QC_440018
    Setup Scout  10_18_UTESRANCLOUD1302
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]WebEM__RAD_debug_parameters
    [Tags]  QC_442284
    Setup Scout  10_18_UTESRANCLOUD1302
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]WebEM Remote Tool - getLoglinkList
    [Tags]  QC_392505
    Setup Scout  10_18_UTESRANCLOUD1327
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]SFP_Monitoring_via_Diagnostic_tab
    [Tags]  QC_407298
    Setup Scout  10_18_UTESRANCLOUD1327
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]LTE NBIOT Cell_L1_IQ_Capture
    [Tags]  QC_461298
    Setup Scout  10_18_UTESRANCLOUD1414
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]WebEM__OAM_Basic_Site_Commission_for_LTE
    [Tags]  QC_461571
    Setup Scout  10_18_UTESRANCLOUD1414
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Run_RF_Diagnostic_test_using_WebEM_all_retrieved_measurements_do_fall_within_the_thresholds
    [Tags]  QC_90746
    Setup Scout  10_18_UTESRANCLOUD1709
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]CB005958-D_M55601C01002_Number_cell_planned_unavailable_with_modification_of parameters_requiring_object_locking_WebUI_004
    [Tags]  QC_90747
    Setup Scout  10_18_UTESRANCLOUD1709
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]WebEM Navigation Menu_ Mirroring activation
    [Tags]  QC_363429
    Setup Scout  10_18_UTESRANCLOUD1709
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]WebEM Navigation Menu_ Saving BTS Technical Report
    [Tags]  QC_363430
    Setup Scout  10_18_UTESRANCLOUD1709
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]WebEM__5G_cells_graceful_shutdown
    [Tags]  QC_90194
    Setup Scout  10_18_UTESRANCLOUD1722
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]5G RAT Block_Unblock
    [Tags]  QC_112121
    Setup Scout  10_18_UTESRANCLOUD1722
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]5G RAT reset via ADMIN
    [Tags]  QC_112122
    Setup Scout  10_18_UTESRANCLOUD1722
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]WebEM__IP_Connectivity_test
    [Tags]  QC_136684
    Setup Scout  10_18_UTESRANCLOUD1722
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]WebEM__Antenna_Line_Monitoring
    [Tags]  QC_164214
    Setup Scout  10_18_UTESRANCLOUD1722
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]WebEM__Show_BTS_Start-up_view_automatically
    [Tags]  QC_178120
    Setup Scout  10_18_UTESRANCLOUD1722
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]WebEM__5G_Delta_plan_activation_for_parameters
    [Tags]  QC_184083
    Setup Scout  10_18_UTESRANCLOUD1722
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]WebEM__Site_Report
    [Tags]  QC_195783
    Setup Scout  10_18_UTESRANCLOUD1722
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]WebEM__Viewing_BTS_Performance_Counter_for_5G
    [Tags]  QC_226452
    Setup Scout  10_18_UTESRANCLOUD1722
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]WebEM__Baseband_module_lock_unlock
    [Tags]  QC_226451
    Setup Scout  10_18_UTESRANCLOUD1722
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]WebEM__SFP_Monitoring_via_Diagnostic_tab
    [Tags]  QC_231867
    Setup Scout  10_18_UTESRANCLOUD1722
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]WebEM__Get_Tuning_History_Report_with_Mozilla_and_Chrome
    [Tags]  QC_231868
    Setup Scout  10_18_UTESRANCLOUD1722
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]WebEM__Filtering_active_alarms
    [Tags]  QC_264319
    Setup Scout  10_18_UTESRANCLOUD1722
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]WebEM__Automatically_log_off_and_Session_Lock
    [Tags]  QC_264320
    Setup Scout  10_18_UTESRANCLOUD1722
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]WebEM__Description_of_HW_units_based_on_their_Product_Code
    [Tags]  QC_264321
    Setup Scout  10_18_UTESRANCLOUD1722
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]WebEM__SW_Rollback
    [Tags]  QC_264322
    Setup Scout  10_18_UTESRANCLOUD1722
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]WebEM__User_rights_downgrade
    [Tags]  QC_264323
    Setup Scout  10_18_UTESRANCLOUD1722
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]WebEM__Navigation_Menu
    [Tags]  QC_264324
    Setup Scout  10_18_UTESRANCLOUD1722
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]WebEM__Simplified_Site_View_cell_groups_visualization
    [Tags]  QC_264325
    Setup Scout  10_18_UTESRANCLOUD1722
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]WebEM__Simplified_Site_View_cells_visualization
    [Tags]  QC_264326
    Setup Scout  10_18_UTESRANCLOUD1722
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]WebEM__Simplified_Site_View_Master_Mode_visualization
    [Tags]  QC_264327
    Setup Scout  10_18_UTESRANCLOUD1722
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]WebEM__Filtering_active_historical_BTS_alarm_list
    [Tags]  QC_270900
    Setup Scout  10_18_UTESRANCLOUD1722
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]WebEM__BTS_Block_Unblock
    [Tags]  QC_322967
    Setup Scout  10_18_UTESRANCLOUD1722
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]WebEM__Debug_tracing_when_5G_and_4G_are_not_commissioned
    [Tags]  QC_333232
    Setup Scout  10_18_UTESRANCLOUD1722
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]WebEM__Configuration_reset
    [Tags]  QC_342735
    Setup Scout  10_18_UTESRANCLOUD1722
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]WebEM__Activation_of_Energy_Consumption_Measurement_collection
    [Tags]  QC_351160
    Setup Scout  10_18_UTESRANCLOUD1722
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]WebEM__Wizard_Deleting_WCDMA_RAT
    [Tags]  QC_416671
    Setup Scout  10_18_UTESRANCLOUD1722
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]WebEM__RF_Monitoring
    [Tags]  QC_466160
    Setup Scout  10_18_UTESRANCLOUD1722
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]WebEM__Basic_Sanity_Check_Simplified_Site_View_Operations
    [Tags]  QC_111356
    Setup Scout  10_18_UTESRANCLOUD1744
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Site_reset_without_HWF_in_loop
    [Tags]  QC_133125
    Setup Scout  10_18_UTESRANCLOUD1744
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]WebEM__RF_successful_start_up_notification_in_Web_Element_Manager
    [Tags]  QC_136686
    Setup Scout  10_18_UTESRANCLOUD1744
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]WebEM__Check_operational_state_of_each_RAT_and_BTS
    [Tags]  QC_227146
    Setup Scout  10_18_UTESRANCLOUD1744
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]WebEM__Reset_operation_for_BBMOD
    [Tags]  QC_227148
    Setup Scout  10_18_UTESRANCLOUD1744
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]WebEM__Description_of_HW_units_based_on_their_Product_Code
    [Tags]  QC_227147
    Setup Scout  10_18_UTESRANCLOUD1744
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]WebEM__Simplified_Site_View_BBMOD_and_SMOD_visualization
    [Tags]  QC_227149
    Setup Scout  10_18_UTESRANCLOUD1744
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]WebEM__Simplified_Site_View_sorting_and_ordering_capabilities
    [Tags]  QC_227150
    Setup Scout  10_18_UTESRANCLOUD1744
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]WebEM__Empty_platLoginBannerText
    [Tags]  QC_231838
    Setup Scout  10_18_UTESRANCLOUD1744
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]WebEM__Check_platLoginBannerText
    [Tags]  QC_231837
    Setup Scout  10_18_UTESRANCLOUD1744
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]WebEM__Check_appLoginBannerText
    [Tags]  QC_231835
    Setup Scout  10_18_UTESRANCLOUD1744
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]WebEM__Check_login_banner_text_file_permission
    [Tags]  QC_231836
    Setup Scout  10_18_UTESRANCLOUD1744
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]WebEM__Enable_Disable_Energy_Consumption_Measurement_Collectection
    [Tags]  QC_264318
    Setup Scout  10_18_UTESRANCLOUD1744
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]WebEM__5G_Show Cells part status in BTS Start-up view for 5G
    [Tags]  QC_95677
    Setup Scout  10_18_UTESRANCLOUD1745
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]WebEM__Mobile_Simplified_Site_View_Performing_Operations_on_Selected_Units
    [Tags]  QC_105941
    Setup Scout  10_18_UTESRANCLOUD1745
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]WebEM__Check_operational_state_of_each_RAT_and_BTS
    [Tags]  QC_227134
    Setup Scout  10_18_UTESRANCLOUD1745
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]WebEM__Simplified_Site_View_BBMOD_and_SMOD_visualization
    [Tags]  QC_227137
    Setup Scout  10_18_UTESRANCLOUD1745
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]WebEM__Description_of_HW_units_based_on_their_Product_Code
    [Tags]  QC_227135
    Setup Scout  10_18_UTESRANCLOUD1745
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]WebEM__Reset_operation_for_BBMOD
    [Tags]  QC_227136
    Setup Scout  10_18_UTESRANCLOUD1745
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]WebEM__Simplified_Site_View_sorting_and_ordering_capabilities
    [Tags]  QC_227138
    Setup Scout  10_18_UTESRANCLOUD1745
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]WebEM__Admin_CLI_Radio_Reset
    [Tags]  QC_270919
    Setup Scout  10_18_UTESRANCLOUD1745
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]WebEM_Admin_CLI_getActiveAlarms
    [Tags]  QC_276904
    Setup Scout  10_18_UTESRANCLOUD1745
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]WebEM__Admin_CLI_getRmodMeasurementsById
    [Tags]  QC_322966
    Setup Scout  10_18_UTESRANCLOUD1745
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]WebEM__Loading_duration_until_runtime_view
    [Tags]  QC_411445
    Setup Scout  10_18_UTESRANCLOUD1745
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]WebEM__ Lock_Unlock_LANE
    [Tags]  QC_466101
    Setup Scout  10_18_UTESRANCLOUD1745
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]WebEM__Get_User_Login_Info
    [Tags]  QC_466102
    Setup Scout  10_18_UTESRANCLOUD1745
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]WebEM__Get_Synchronization_Information_via_WebEM_Remote_Tool
    [Tags]  QC_466107
    Setup Scout  10_18_UTESRANCLOUD1745
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]WebEM__activationAndDeactivationOf_C_U_PlaneDebugTraces_via_recommission
    [Tags]  QC_471620
    Setup Scout  10_18_UTESRANCLOUD1745
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]WebEM__Command_Specific_Error_Codes_Verification
    [Tags]  QC_471621
    Setup Scout  10_18_UTESRANCLOUD1745
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]WebEM__configure_CPlaneTraces
    [Tags]  QC_471622
    Setup Scout  10_18_UTESRANCLOUD1745
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]WebEM__start_stopUPlaneL2Trace
    [Tags]  QC_471623
    Setup Scout  10_18_UTESRANCLOUD1745
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__WCDMA_RAT_reset_from_ADMIN
    [Tags]  QC_70261
    Setup Scout  10_18_UTESRANCLOUD1303
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__CM__Commissioning_planned_commissioning
    [Tags]  QC_70262
    Setup Scout  10_18_UTESRANCLOUD1303
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__GSM_BCF_lock_unlock_from_BSC
    [Tags]  QC_70257
    Setup Scout  10_18_UTESRANCLOUD1413
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__Site_reset
    [Tags]  QC_70258
    Setup Scout  10_18_UTESRANCLOUD1413
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__FM__Recovery_whole_multiple_Link_Break
    [Tags]  QC_70259
    Setup Scout  10_18_UTESRANCLOUD1413
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__CM__Commissioning_planned_commissioning
    [Tags]  QC_70260
    Setup Scout  10_18_UTESRANCLOUD1413
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__CM__Commissioning_planned_commissioning
    [Tags]  QC_70252
    Setup Scout  10_18_UTESRANCLOUD1315
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__GSM_BCF_block_unblock_from_ADMIN
    [Tags]  QC_70253
    Setup Scout  10_18_UTESRANCLOUD1315
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__Site_reset
    [Tags]  QC_70255
    Setup Scout  10_18_UTESRANCLOUD1315
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__RF_Module_lock_unlock
    [Tags]  QC_70256
    Setup Scout  10_18_UTESRANCLOUD1315
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__CM__Commissioning_planned_commissioning
    [Tags]  QC_70247
    Setup Scout  10_18_UTESRANCLOUD1323
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__GSM_BCF_lock_unlock_from_BSC
    [Tags]  QC_70248
    Setup Scout  10_18_UTESRANCLOUD1323
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__WCDMA_RAT_reset_from_ADMIN
    [Tags]  QC_70250
    Setup Scout  10_18_UTESRANCLOUD1323
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__RF_Module_lock_unlock
    [Tags]  QC_70251
    Setup Scout  10_18_UTESRANCLOUD1323
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Site_reset_without_HWF_in_loop
    [Tags]  QC_136522
    Setup Scout  10_18_UTESRANCLOUD1323
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__CM__Commissioning_planned_commissioning
    [Tags]  QC_70263
    Setup Scout  10_18_UTESRANCLOUD1337
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__LTE_RAT_reset_from_ADMIN
    [Tags]  QC_70264
    Setup Scout  10_18_UTESRANCLOUD1337
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Trigger and clear FID 181
    [Tags]  QC_83494
    Setup Scout  10_18_UTESRANCLOUD1615
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Checking ims2 from Snapshot after SC reset due to alarm
    [Tags]  QC_70212
    Setup Scout  10_18_UTESRANCLOUD1307
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]CNI-38910 Automatic log off timer configured from Parameter Editor for single user_C_Windows
    [Tags]  QC_69739
    Setup Scout  10_18_UTESRANCLOUD1487
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]CNI-39615_Multiband.Output.Power.Watts check for LW RAT
    [Tags]  QC_69743
    Setup Scout  10_18_UTESRANCLOUD1413
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]CNI-39615_Tx.Carrier.Max.Pa.Power check for LW RAT
    [Tags]  QC_69744
    Setup Scout  10_18_UTESRANCLOUD1413
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]CNI-39615_Output.Power.Watts check for LWG RAT
    [Tags]  QC_70121
    Setup Scout  10_18_UTESRANCLOUD1413
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]CNI-39615_Tx.Power.Group check for LWG RAT
    [Tags]  QC_70123
    Setup Scout  10_18_UTESRANCLOUD1413
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]CNI-40550-Removing all objects of selected class in whole configuration
    [Tags]  QC_70125
    Setup Scout  10_18_UTESRANCLOUD1487
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Proper display for PDL validation errors severity of PDL validation error
    [Tags]  QC_124312
    Setup Scout  10_18_UTESRANCLOUD1307
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]SFP Monitoring
    [Tags]  QC_70126
    Setup Scout  10_18_UTESRANCLOUD1487
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Browser refresh not lead to frozen mode
    [Tags]  QC_70138
    Setup Scout  10_18_UTESRANCLOUD1487
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]SFP_Monitoring_from_Runtime_View
    [Tags]  QC_70141
    Setup Scout  10_18_UTESRANCLOUD1487
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]BSC_RNC_EPC_visualization in Site View and Detailed Site View
    [Tags]  QC_111986
    Setup Scout  10_18_UTESRANCLOUD1487
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]EIF_visualization_in_Runtime_View
    [Tags]  QC_70130
    Setup Scout  10_18_UTESRANCLOUD1487
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Wizard__Creating new_removing configuration for not existing_not detected hardware_C_Windows
    [Tags]  QC_70146
    Setup Scout  10_18_UTESRANCLOUD1307
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Wizard__Creating_removing physical topology links in configuration between System Modules_Baseband Modules and Radio Modules_C_Windows
    [Tags]  QC_70148
    Setup Scout  10_18_UTESRANCLOUD1307
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Error case_Missing TargetDB file in SW package
    [Tags]  QC_70149
    Setup Scout  10_18_UTESRANCLOUD1307
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Wizard__Commissioning Wizard Moving across all commissioning steps
    [Tags]  QC_111996
    Setup Scout  10_18_UTESRANCLOUD1307
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Wizard__Commissioning Wizard for uncommissioned ASIA+FSMF in Online mode based on detected hardware
    [Tags]  QC_111999
    Setup Scout  10_18_UTESRANCLOUD1307
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]RP001407_Password validation for toor4nsn and serviceuser
    [Tags]  QC_111989
    Setup Scout  10_18_UTESRANCLOUD1487
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Wizard__Change of MPLANE address
    [Tags]  QC_70156
    Setup Scout  10_18_UTESRANCLOUD1487
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]User_account_management__Update alias name for any local user
    [Tags]  QC_111975
    Setup Scout  10_18_UTESRANCLOUD1487
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Commissioning Report creating and saving via WebEM
    [Tags]  QC_111970
    Setup Scout  10_18_UTESRANCLOUD1487
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]User_account_management__Notify user while login when password is expired_C_Windows
    [Tags]  QC_70162
    Setup Scout  10_18_UTESRANCLOUD1487
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Verify ADMIN GUI roles for local user accounts
    [Tags]  QC_111981
    Setup Scout  10_18_UTESRANCLOUD1487
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Exceptional_RF Fiber Insert&Removal Long_Break_Primary_Link
    [Tags]  QC_70170
    Setup Scout  10_18_UTESRANCLOUD1303
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Exceptional_RF Fiber Removal&Insert Secondary_then_Primary
    [Tags]  QC_70167
    Setup Scout  10_18_UTESRANCLOUD1323
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Exceptional_RF Fiber Removal&Insert Secondary_then_Primary
    [Tags]  QC_70174
    Setup Scout  10_18_UTESRANCLOUD1337
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Local_Software_Download_and_Activation_error_cases
    [Tags]  QC_70180
    Setup Scout  10_18_UTESRANCLOUD1337
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Availability of Fix Errors functionality
    [Tags]  QC_70187
    Setup Scout  10_18_UTESRANCLOUD1487
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Configuration validation against parameters relation rules and against detected hardware capability or compatibility (PDL validation)
    [Tags]  QC_70189
    Setup Scout  10_18_UTESRANCLOUD1487
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Ethernet Link OAM information display in Diagnostics view
    [Tags]  QC_70192
    Setup Scout  10_18_UTESRANCLOUD1487
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Ethernet Service OAM information display for a Maintenance Association
    [Tags]  QC_70194
    Setup Scout  10_18_UTESRANCLOUD1487
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Creating and configuring network slice configurations
    [Tags]  QC_70214
    Setup Scout  10_18_UTESRANCLOUD1307
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]BER_Threhsold_major_alarm_UL
    [Tags]  QC_124300
    Setup Scout  10_18_UTESRANCLOUD1414
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]BER_Threhsold_minor_alarm_UL
    [Tags]  QC_124301
    Setup Scout  10_18_UTESRANCLOUD1414
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Show Hardware part status for Baseband modules detection
    [Tags]  QC_70199
    Setup Scout  10_18_UTESRANCLOUD1487
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Show Cells part status for 3G Cells in BTS Start-up view
    [Tags]  QC_70204
    Setup Scout  10_18_UTESRANCLOUD1487
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Show Hardware part status for Radio modules detection
    [Tags]  QC_70206
    Setup Scout  10_18_UTESRANCLOUD1487
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]TRSIV_SR002398_Commissioning SBTS by online(LMP) mode
    [Tags]  QC_70208
    Setup Scout  10_18_UTESRANCLOUD1487
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]TRSIV_SR002398_Download, validate and Activation and Edit commissioning parameters (NCF) and Save NCF
    [Tags]  QC_70210
    Setup Scout  10_18_UTESRANCLOUD1487
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Notify user while login when password is expired
    [Tags]  QC_69728
    Setup Scout  10_18_UTESRANCLOUD1487
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Show Cells part status in BTS Start-up view
    [Tags]  QC_69729
    Setup Scout  10_18_UTESRANCLOUD1487
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Show Configuration part status in BTS Start-up view
    [Tags]  QC_69737
    Setup Scout  10_18_UTESRANCLOUD1487
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]WebEM User Access Control Permissions – 5G - Mobile
    [Tags]  QC_70220
    Setup Scout  10_18_UTESRANCLOUD1432
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Cell addition to the blocked RAT
    [Tags]  QC_70222
    Setup Scout  10_18_UTESRANCLOUD1432
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Activate and deactivate internal trace
    [Tags]  QC_70226
    Setup Scout  10_18_UTESRANCLOUD1432
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]NR FDD Basic Cell Settings step
    [Tags]  QC_70231
    Setup Scout  10_18_UTESRANCLOUD1432
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]WebEM usability for large configurations
    [Tags]  QC_70234
    Setup Scout  10_18_UTESRANCLOUD1432
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Start_Stop UPlane L1 stream trace
    [Tags]  QC_70238
    Setup Scout  10_18_UTESRANCLOUD1432
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]5G Test Models – Running Performance Test Show in R&D Mode (PRACH)
    [Tags]  QC_112025
    Setup Scout  10_18_UTESRANCLOUD1432
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]5G Test Models - Running 5G Downlink Test
    [Tags]  QC_112028
    Setup Scout  10_18_UTESRANCLOUD1432
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

*** Keywords ***