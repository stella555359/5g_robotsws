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
[1]FM_low_VoltUnstable_recovered_fault_4680_cleared
    [Tags]  QC_236194
    Setup Scout  10_18_UTESRANCLOUD1328
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM_high_VoltUnstableThreshold_updated_fault_4680_cleared
    [Tags]  QC_236195
    Setup Scout  10_18_UTESRANCLOUD1328
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM__A_L1_5G_Loki_autonomous_reset_on_critical_failure
    [Tags]  QC_236196
    Setup Scout  10_18_UTESRANCLOUD1328
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM__C_Capacity_core_unit_5G_L3_SW_reset_escalation
    [Tags]  QC_236197
    Setup Scout  10_18_UTESRANCLOUD1328
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]OAM_Binary_recovery
    [Tags]  QC_259708
    Setup Scout  10_18_UTESRANCLOUD1328
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM__E_Capacity_core_unit_5G_L2_RT_SW_reset_escalation
    [Tags]  QC_348827
    Setup Scout  10_18_UTESRANCLOUD1328
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]CB007952_D_FM_Report_alarms_triggered_on_SMOD_CELL_to_ONAP
    [Tags]  QC_380086
    Setup Scout  10_18_UTESRANCLOUD1328
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]CB007952_E_FM_Rebuild_alarms_table_by_reset_site_IPv4
    [Tags]  QC_380085
    Setup Scout  10_18_UTESRANCLOUD1328
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM__D_L1Soc_LTE_UL_DSP_unsuccessful_recovery_reset_loop_detection
    [Tags]  QC_439149
    Setup Scout  10_18_UTESRANCLOUD1328
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM__B_L1Soc_NR_UL_DSP_successful_recovery
    [Tags]  QC_447797
    Setup Scout  10_18_UTESRANCLOUD1328
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM__C_L1Soc_NR_DL_DSP_successful_recovery
    [Tags]  QC_454772
    Setup Scout  10_18_UTESRANCLOUD1328
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM__D_VES_HeartBeat_transmission_failure_handling
    [Tags]  QC_468198
    Setup Scout  10_18_UTESRANCLOUD1328
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM__D_VES_alarm_events_configuration_and_transmission
    [Tags]  QC_468199
    Setup Scout  10_18_UTESRANCLOUD1328
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM__D_VES_alarm_events_buffering_and_eventId_handling
    [Tags]  QC_468200
    Setup Scout  10_18_UTESRANCLOUD1328
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM__D_VES_alarm_events_buffer_overflow
    [Tags]  QC_468201
    Setup Scout  10_18_UTESRANCLOUD1328
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM__D_Alarm_event_enrichment
    [Tags]  QC_468202
    Setup Scout  10_18_UTESRANCLOUD1328
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM__E_Check_VES_alarm_events_and_compare_with_NetConf
    [Tags]  QC_468203
    Setup Scout  10_18_UTESRANCLOUD1328
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM__E_Check_AlarmLis_content_on_O-RAN_O1_NetConf_interface
    [Tags]  QC_468204
    Setup Scout  10_18_UTESRANCLOUD1328
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM__5G cell graceful shutdown before recovery BTS reset
    [Tags]  QC_70582
    Setup Scout  10_18_UTESRANCLOUD1723
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM__Category alarms - cells affected cannot be determined
    [Tags]  QC_70583
    Setup Scout  10_18_UTESRANCLOUD1723
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM__Primary core power off-on - fault signature
    [Tags]  QC_70584
    Setup Scout  10_18_UTESRANCLOUD1723
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM__5G RAT reset executed as autonomous recovery action
    [Tags]  QC_70585
    Setup Scout  10_18_UTESRANCLOUD1723
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM_Activate_EnhX2LinkSupervision_fault_7324_reported
    [Tags]  QC_85037
    Setup Scout  10_18_UTESRANCLOUD1723
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM_deactivate_EnhX2LinkSupervision_feature_fault_7324_cleared
    [Tags]  QC_85038
    Setup Scout  10_18_UTESRANCLOUD1723
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Site_reset_without_HWF_in_loop
    [Tags]  QC_136608
    Setup Scout  10_18_UTESRANCLOUD1723
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM__link_break_GTPU
    [Tags]  QC_165798
    Setup Scout  10_18_UTESRANCLOUD1723
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM__SC_reset_counter_cleared_-_manual_site_reset
    [Tags]  QC_165800
    Setup Scout  10_18_UTESRANCLOUD1723
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM__fault_handling_WCDMA_UPlane
    [Tags]  QC_165799
    Setup Scout  10_18_UTESRANCLOUD1723
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM__SC_late_startup_actForceAutoReset_true
    [Tags]  QC_176554
    Setup Scout  10_18_UTESRANCLOUD1723
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM__LTE_DSP_reset_actForceUnitAutoReset_false_faulty_cells_6709
    [Tags]  QC_176563
    Setup Scout  10_18_UTESRANCLOUD1723
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM__BBPOOL_reset_allowBbPoolRecoveryReset_true_faulty_cell
    [Tags]  QC_176559
    Setup Scout  10_18_UTESRANCLOUD1723
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__FM__GSM_DSP_crash_RAT_recovery_reset
    [Tags]  QC_176558
    Setup Scout  10_18_UTESRANCLOUD1723
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__FM__RAT_reset_counter_exceeded__multi_RAT
    [Tags]  QC_176557
    Setup Scout  10_18_UTESRANCLOUD1723
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM__SC_reset_actForceAutoReset_false_faulty_cells
    [Tags]  QC_176556
    Setup Scout  10_18_UTESRANCLOUD1723
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Autonomous_recovery_reset_counter_with_BBMOD_fault
    [Tags]  QC_259713
    Setup Scout  10_18_UTESRANCLOUD1723
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM__FSP_recovery_fault_243_regression
    [Tags]  QC_381030
    Setup Scout  10_18_UTESRANCLOUD1723
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM_ BTS_Alarm_monitoring_with_NMS-Alarm_Event_Notification
    [Tags]  QC_417369
    Setup Scout  10_18_UTESRANCLOUD1723
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM_Triggering_alarm_upload_based_on_connectivity_status
    [Tags]  QC_417371
    Setup Scout  10_18_UTESRANCLOUD1723
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM_ BTS_alarm_upload-Alarm_Synchronization
    [Tags]  QC_417370
    Setup Scout  10_18_UTESRANCLOUD1723
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM__D_L1Soc_LTE_UL_DSP_successful_recovery
    [Tags]  QC_439150
    Setup Scout  10_18_UTESRANCLOUD1723
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM__B_L1Soc_NR_UL_DSP_feature_deactivated
    [Tags]  QC_447827
    Setup Scout  10_18_UTESRANCLOUD1723
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM__LTE_DSP_reset_actForceUnitAutoReset_false_faulty_cells_6709
    [Tags]  QC_70268
    Setup Scout  10_18_UTESRANCLOUD1348
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM__RMOD_hot_remove_hot_insert_locked_RMOD
    [Tags]  QC_70270
    Setup Scout  10_18_UTESRANCLOUD1348
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM__SC_late_startup_actForceAutoReset_false
    [Tags]  QC_70280
    Setup Scout  10_18_UTESRANCLOUD1348
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__FM__fault_handling_LTE_CPlane
    [Tags]  QC_70297
    Setup Scout  10_18_UTESRANCLOUD1348
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__FM__link_break_Abis_startup
    [Tags]  QC_70303
    Setup Scout  10_18_UTESRANCLOUD1348
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__FM__GSM_faults_handling_fault_2412
    [Tags]  QC_70300
    Setup Scout  10_18_UTESRANCLOUD1348
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__FM__link_break_IuB_DNBAP_short
    [Tags]  QC_70307
    Setup Scout  10_18_UTESRANCLOUD1348
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__FM__link_break_IuB_CNBAP_short
    [Tags]  QC_70305
    Setup Scout  10_18_UTESRANCLOUD1348
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__FM__link_break_IuB_short
    [Tags]  QC_70309
    Setup Scout  10_18_UTESRANCLOUD1348
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__FM__FHNET_crash_VN_recovery_reset_AS
    [Tags]  QC_70298
    Setup Scout  10_18_UTESRANCLOUD1348
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__FM__GSM_DSP_crash_RAT_recovery_reset
    [Tags]  QC_70299
    Setup Scout  10_18_UTESRANCLOUD1348
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__FM__link_break_SBTS_short
    [Tags]  QC_70314
    Setup Scout  10_18_UTESRANCLOUD1348
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__FM__link_break_Abis_short
    [Tags]  QC_70302
    Setup Scout  10_18_UTESRANCLOUD1348
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__FM__link_break_S1_short
    [Tags]  QC_70312
    Setup Scout  10_18_UTESRANCLOUD1348
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__FM__link_break_IuB_startup
    [Tags]  QC_70310
    Setup Scout  10_18_UTESRANCLOUD1348
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__FM__link_break_IuB_CNBAP
    [Tags]  QC_70304
    Setup Scout  10_18_UTESRANCLOUD1348
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__FM__link_break_IuB_long
    [Tags]  QC_70308
    Setup Scout  10_18_UTESRANCLOUD1348
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__FM__link_break_IuB_DNBAP
    [Tags]  QC_70306
    Setup Scout  10_18_UTESRANCLOUD1348
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__FM__LTE_CCplane_crash_RAT_recovery_reset
    [Tags]  QC_70315
    Setup Scout  10_18_UTESRANCLOUD1348
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__FM__link_break_Abis_long
    [Tags]  QC_70301
    Setup Scout  10_18_UTESRANCLOUD1348
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__FM__RAT_reset_counter_exceeded__multi_RAT
    [Tags]  QC_70318
    Setup Scout  10_18_UTESRANCLOUD1348
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__FM__link_break_SBTS_long
    [Tags]  QC_70313
    Setup Scout  10_18_UTESRANCLOUD1348
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__FM__Site_reset_actForceAutoReset_true_enabled_cell
    [Tags]  QC_70324
    Setup Scout  10_18_UTESRANCLOUD1348
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__FM__link_break_S1_long
    [Tags]  QC_70311
    Setup Scout  10_18_UTESRANCLOUD1348
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__FM__LTE_DSP_crash_DSP_recovery_reset
    [Tags]  QC_70316
    Setup Scout  10_18_UTESRANCLOUD1348
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__FM__RF_module_alarm_with_reco_reset
    [Tags]  QC_70319
    Setup Scout  10_18_UTESRANCLOUD1348
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__FM__WCDMA_VN_crash_RAT_recovery_reset
    [Tags]  QC_70329
    Setup Scout  10_18_UTESRANCLOUD1348
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__FM__RMOD_hot_remove_hot_insert
    [Tags]  QC_70321
    Setup Scout  10_18_UTESRANCLOUD1348
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__FM__Site_reset_counter_exceeded
    [Tags]  QC_70325
    Setup Scout  10_18_UTESRANCLOUD1348
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM__Site_reset_counter_cleared__manual_site_reset
    [Tags]  QC_70362
    Setup Scout  10_18_UTESRANCLOUD1348
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM__RAT_reset_actForceAutoreset_true_enabled_cell
    [Tags]  QC_70363
    Setup Scout  10_18_UTESRANCLOUD1348
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__FM__RMOD_fault_without_recovery
    [Tags]  QC_70320
    Setup Scout  10_18_UTESRANCLOUD1348
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__FM__LTE_L3_crash_VN_recovery_reset
    [Tags]  QC_70317
    Setup Scout  10_18_UTESRANCLOUD1348
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__FM__RMOD_spontaneous_reset
    [Tags]  QC_70322
    Setup Scout  10_18_UTESRANCLOUD1348
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__FM__VN_CCplane_LTE_reset_counter_exceeded
    [Tags]  QC_70326
    Setup Scout  10_18_UTESRANCLOUD1348
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM__SC_reset_actForceAutoReset_true_enabled_cell
    [Tags]  QC_70364
    Setup Scout  10_18_UTESRANCLOUD1348
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]LTE656 - Suppression of toggling radio alarm
    [Tags]  QC_70376
    Setup Scout  10_18_UTESRANCLOUD1348
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM__SC_reset_actForceAutoReset_false_enabled_cell
    [Tags]  QC_70365
    Setup Scout  10_18_UTESRANCLOUD1348
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]LTE656 - Suppression of toggling transport alarms
    [Tags]  QC_70377
    Setup Scout  10_18_UTESRANCLOUD1348
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM__RAT_reset_actForceAutoreset_true_degraded_cell
    [Tags]  QC_70366
    Setup Scout  10_18_UTESRANCLOUD1348
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]RP002086_Alarm_From_Blocked_Cell_Not_Reported_To_NetAct
    [Tags]  QC_70378
    Setup Scout  10_18_UTESRANCLOUD1348
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__FM__SC_hot_remove_hot_insert
    [Tags]  QC_70323
    Setup Scout  10_18_UTESRANCLOUD1348
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__FM__WCDMA_CPlane_fault_RAT_recovery_reset
    [Tags]  QC_70327
    Setup Scout  10_18_UTESRANCLOUD1348
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM__RAT_reset_counter_cleared__manual_site_reset
    [Tags]  QC_70367
    Setup Scout  10_18_UTESRANCLOUD1348
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]RP002086_Change_S1_connection_failure_alarm_severity_and_status_sync
    [Tags]  QC_70379
    Setup Scout  10_18_UTESRANCLOUD1348
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Add_configure_remove_all_external_alarms
    [Tags]  QC_70368
    Setup Scout  10_18_UTESRANCLOUD1348
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__FM__WCDMA_DSP_crash_RAT_recovery_reset
    [Tags]  QC_70328
    Setup Scout  10_18_UTESRANCLOUD1348
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM__RAT_reset_actForceAutoReset_false_enabled_cells
    [Tags]  QC_70361
    Setup Scout  10_18_UTESRANCLOUD1348
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM__E_L1Soc_LTE_DL_DSP_unsuccessful_recovery_reset_loop_detection
    [Tags]  QC_439151
    Setup Scout  10_18_UTESRANCLOUD1348
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM__B_L1Soc_NR_UL_DSP_recovery_escalation_procedure
    [Tags]  QC_447828
    Setup Scout  10_18_UTESRANCLOUD1348
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM__SC_reset_actForceAutoReset_true_enabled_cell
    [Tags]  QC_70382
    Setup Scout  10_18_UTESRANCLOUD1625
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM__SC_late_startup_actForceAutoReset_true
    [Tags]  QC_70384
    Setup Scout  10_18_UTESRANCLOUD1625
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__FM__fault_handling_LTE_CPlane
    [Tags]  QC_70386
    Setup Scout  10_18_UTESRANCLOUD1625
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__FM__FHNET_crash_VN_recovery_reset_AS
    [Tags]  QC_70387
    Setup Scout  10_18_UTESRANCLOUD1625
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__FM__GSM_DSP_crash_RAT_recovery_reset
    [Tags]  QC_70388
    Setup Scout  10_18_UTESRANCLOUD1625
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__FM__GSM_faults_handling_fault_2412
    [Tags]  QC_70389
    Setup Scout  10_18_UTESRANCLOUD1625
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__FM__link_break_Abis_short
    [Tags]  QC_70391
    Setup Scout  10_18_UTESRANCLOUD1625
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__FM__link_break_Abis_startup
    [Tags]  QC_70392
    Setup Scout  10_18_UTESRANCLOUD1625
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__FM__link_break_Abis_long
    [Tags]  QC_70390
    Setup Scout  10_18_UTESRANCLOUD1625
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__FM__link_break_IuB_CNBAP_short
    [Tags]  QC_70394
    Setup Scout  10_18_UTESRANCLOUD1625
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__FM__link_break_IuB_CNBAP
    [Tags]  QC_70393
    Setup Scout  10_18_UTESRANCLOUD1625
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__FM__link_break_IuB_DNBAP
    [Tags]  QC_70395
    Setup Scout  10_18_UTESRANCLOUD1625
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__FM__link_break_IuB_long
    [Tags]  QC_70397
    Setup Scout  10_18_UTESRANCLOUD1625
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__FM__link_break_IuB_short
    [Tags]  QC_70398
    Setup Scout  10_18_UTESRANCLOUD1625
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__FM__link_break_IuB_DNBAP_short
    [Tags]  QC_70396
    Setup Scout  10_18_UTESRANCLOUD1625
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__FM__link_break_S1_short
    [Tags]  QC_70401
    Setup Scout  10_18_UTESRANCLOUD1625
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__FM__link_break_S1_long
    [Tags]  QC_70400
    Setup Scout  10_18_UTESRANCLOUD1625
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__FM__link_break_IuB_startup
    [Tags]  QC_70399
    Setup Scout  10_18_UTESRANCLOUD1625
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__FM__LTE_CCplane_crash_RAT_recovery_reset
    [Tags]  QC_70404
    Setup Scout  10_18_UTESRANCLOUD1625
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__FM__LTE_DSP_crash_DSP_recovery_reset
    [Tags]  QC_70405
    Setup Scout  10_18_UTESRANCLOUD1625
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__FM__link_break_SBTS_long
    [Tags]  QC_70402
    Setup Scout  10_18_UTESRANCLOUD1625
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__FM__LTE_L3_crash_VN_recovery_reset
    [Tags]  QC_70406
    Setup Scout  10_18_UTESRANCLOUD1625
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__FM__RMOD_hot_remove_hot_insert
    [Tags]  QC_70410
    Setup Scout  10_18_UTESRANCLOUD1625
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__FM__RF_module_alarm_with_reco_reset
    [Tags]  QC_70408
    Setup Scout  10_18_UTESRANCLOUD1625
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__FM__RAT_reset_counter_exceeded__multi_RAT
    [Tags]  QC_70407
    Setup Scout  10_18_UTESRANCLOUD1625
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__FM__link_break_SBTS_short
    [Tags]  QC_70403
    Setup Scout  10_18_UTESRANCLOUD1625
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__FM__WCDMA_CPlane_fault_RAT_recovery_reset
    [Tags]  QC_70416
    Setup Scout  10_18_UTESRANCLOUD1625
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__FM__Site_reset_actForceAutoReset_true_enabled_cell
    [Tags]  QC_70413
    Setup Scout  10_18_UTESRANCLOUD1625
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__FM__WCDMA_VN_crash_RAT_recovery_reset
    [Tags]  QC_70418
    Setup Scout  10_18_UTESRANCLOUD1625
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__FM__RMOD_spontaneous_reset
    [Tags]  QC_70411
    Setup Scout  10_18_UTESRANCLOUD1625
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__FM__SC_hot_remove_hot_insert
    [Tags]  QC_70412
    Setup Scout  10_18_UTESRANCLOUD1625
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__FM__VN_CCplane_LTE_reset_counter_exceeded
    [Tags]  QC_70415
    Setup Scout  10_18_UTESRANCLOUD1625
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__FM__WCDMA_DSP_crash_RAT_recovery_reset
    [Tags]  QC_70417
    Setup Scout  10_18_UTESRANCLOUD1625
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__FM__Site_reset_counter_exceeded
    [Tags]  QC_70414
    Setup Scout  10_18_UTESRANCLOUD1625
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM__RAT_reset_actForceAutoreset_true_enabled_cell
    [Tags]  QC_70476
    Setup Scout  10_18_UTESRANCLOUD1625
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM__Secondary_core_power_off_on
    [Tags]  QC_70477
    Setup Scout  10_18_UTESRANCLOUD1625
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM__link_break_X2_long
    [Tags]  QC_70478
    Setup Scout  10_18_UTESRANCLOUD1625
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Alarm_synchronization_after_reconnecting_to_NetAct
    [Tags]  QC_70490
    Setup Scout  10_18_UTESRANCLOUD1625
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM__link_break_X2_short
    [Tags]  QC_70479
    Setup Scout  10_18_UTESRANCLOUD1625
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Ping_lost_between_node_CC&S_and_application_FSM_BTSOM
    [Tags]  QC_70491
    Setup Scout  10_18_UTESRANCLOUD1625
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM__VN_reset_counter_cleared__manual_site_reset
    [Tags]  QC_70480
    Setup Scout  10_18_UTESRANCLOUD1625
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM__Site_reset_actForceAutoReset_false_enabled_cell
    [Tags]  QC_70481
    Setup Scout  10_18_UTESRANCLOUD1625
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Ping_lost_between_node_CC&S_and_application_FSM_RROM
    [Tags]  QC_70493
    Setup Scout  10_18_UTESRANCLOUD1625
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__Admin_CLI_get_alarm_history_remote
    [Tags]  QC_70482
    Setup Scout  10_18_UTESRANCLOUD1625
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM__SC_reset_actForceAutoReset_false_enabled_cell
    [Tags]  QC_70473
    Setup Scout  10_18_UTESRANCLOUD1625
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]LTE656 - Suppression of toggling external alarm
    [Tags]  QC_70485
    Setup Scout  10_18_UTESRANCLOUD1625
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM__Site_reset_counter_cleared__manual_site_reset
    [Tags]  QC_70474
    Setup Scout  10_18_UTESRANCLOUD1625
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM_FSP_recovery_fault_242
    [Tags]  QC_236086
    Setup Scout  10_18_UTESRANCLOUD1625
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM__E_L1Soc_LTE_DL_DSP_successful_recovery
    [Tags]  QC_439152
    Setup Scout  10_18_UTESRANCLOUD1625
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM__B_L1Soc_NR_UL_DSP_unsuccessful_recovery_reset_loop_detection
    [Tags]  QC_447829
    Setup Scout  10_18_UTESRANCLOUD1625
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]LTE3342_Improved_combined_FM_Service_with_multiple_alarms
    [Tags]  QC_466949
    Setup Scout  10_18_UTESRANCLOUD1625
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__FM__RMOD_hot_remove_hot_insert
    [Tags]  QC_407227
    Setup Scout  10_18_UTESRANCLOUD1327
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__FM__Site_reset_counter_exceeded
    [Tags]  QC_407228
    Setup Scout  10_18_UTESRANCLOUD1327
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__FM__LTE_CCplane_crash_RAT_recovery_reset
    [Tags]  QC_407229
    Setup Scout  10_18_UTESRANCLOUD1327
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM__A_L1_5G_Loki_autonomous_reset_on_critical_failure
    [Tags]  QC_407231
    Setup Scout  10_18_UTESRANCLOUD1327
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM__E_Capacity_core_unit_5G_L2_RT_SW_reset_escalation
    [Tags]  QC_407232
    Setup Scout  10_18_UTESRANCLOUD1327
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM__Primary_core_power_off_on
    [Tags]  QC_407230
    Setup Scout  10_18_UTESRANCLOUD1327
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM__RMOD_reset_counter_exceeded_FID1901
    [Tags]  QC_439058
    Setup Scout  10_18_UTESRANCLOUD1327
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM__RMOD_reset_counter_exceeded_FID1907
    [Tags]  QC_439057
    Setup Scout  10_18_UTESRANCLOUD1327
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM_RMOD_reset_counter_exceeded_FID1900
    [Tags]  QC_439060
    Setup Scout  10_18_UTESRANCLOUD1327
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM_RMOD_power_off_on_FID4589
    [Tags]  QC_439055
    Setup Scout  10_18_UTESRANCLOUD1327
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM__RMOD_reset_counter_exceeded_FID1981
    [Tags]  QC_439064
    Setup Scout  10_18_UTESRANCLOUD1327
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM_RMOD_crash_FID4590
    [Tags]  QC_439056
    Setup Scout  10_18_UTESRANCLOUD1327
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM__C_L1Soc_NR_DL_DSP_unsuccessful_recovery_reset_loop_detection
    [Tags]  QC_454773
    Setup Scout  10_18_UTESRANCLOUD1327
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

*** Keywords ***