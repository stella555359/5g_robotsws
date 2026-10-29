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
[1]Mobile_Simplified_Site_View_for_ASOE
    [Tags]  QC_172802
    Setup Scout  10_18_UTESRANCLOUD1317
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]WebEM__Show_BTS_Start-up_view_automatically
    [Tags]  QC_178967
    Setup Scout  10_18_UTESRANCLOUD1317
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Check_test_dedicated_state
    [Tags]  QC_195768
    Setup Scout  10_18_UTESRANCLOUD1317
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM__Primary_core_power_off_on
    [Tags]  QC_452446
    Setup Scout  10_18_UTESRANCLOUD1317
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM__E_Capacity_core_unit_5G_L2_RT_SW_reset_escalation
    [Tags]  QC_454531
    Setup Scout  10_18_UTESRANCLOUD1317
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM__SoC_reset_criteria_if_actForceUnitAutoReset=false_and_the_same_fault_appeared_for_the_SoC_in_pas_one_hour
    [Tags]  QC_467209
    Setup Scout  10_18_UTESRANCLOUD1317
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM__SoC_reset_counter_exceeded
    [Tags]  QC_467207
    Setup Scout  10_18_UTESRANCLOUD1317
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM__5GC000952_ASOE_Check_if_4th_Site_recovery_reset_within_1_hour_is_not_executed
    [Tags]  QC_467206
    Setup Scout  10_18_UTESRANCLOUD1317
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM__SoC_reset_counter_cleared_after_one_hour
    [Tags]  QC_467208
    Setup Scout  10_18_UTESRANCLOUD1317
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM__SoC_reset_criteria_is_not_allowed_when_allowBbPoolRecoveryReset=false
    [Tags]  QC_467211
    Setup Scout  10_18_UTESRANCLOUD1317
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM__SoC_reset_criteria_if_actForceUnitAutoReset=true_in_the_same_fault_appeared_for_the_same_SoC_in_past_one_hour
    [Tags]  QC_467210
    Setup Scout  10_18_UTESRANCLOUD1317
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__WCDMA_cell_lock_unlock_from_RNC
    [Tags]  QC_69678
    Setup Scout  10_18_UTESRANCLOUD1441
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__Site_reset
    [Tags]  QC_69679
    Setup Scout  10_18_UTESRANCLOUD1441
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__WCDMA_RAT_reset_from_ADMIN
    [Tags]  QC_69680
    Setup Scout  10_18_UTESRANCLOUD1441
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__GSM_BCF_lock_unlock_from_BSC
    [Tags]  QC_69681
    Setup Scout  10_18_UTESRANCLOUD1441
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__Site_power_reset
    [Tags]  QC_69682
    Setup Scout  10_18_UTESRANCLOUD1441
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__CM__Recommissioning_delta_commissioning_without_reset
    [Tags]  QC_69683
    Setup Scout  10_18_UTESRANCLOUD1441
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__CM__Recommissioning_delta_commissioning_with_reset
    [Tags]  QC_69684
    Setup Scout  10_18_UTESRANCLOUD1441
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__SBTS_block_unblock
    [Tags]  QC_69685
    Setup Scout  10_18_UTESRANCLOUD1441
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__FM__RF_hot_remove_hot_insert
    [Tags]  QC_69686
    Setup Scout  10_18_UTESRANCLOUD1441
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__SWM__SW_download_and_activation__SBTS_to_SBTS
    [Tags]  QC_69688
    Setup Scout  10_18_UTESRANCLOUD1441
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__SWM__SCF_validation_errors_check
    [Tags]  QC_69687
    Setup Scout  10_18_UTESRANCLOUD1441
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__LOGS__Memory_dump_files_creation_in_case_of_DSP_crash
    [Tags]  QC_69692
    Setup Scout  10_18_UTESRANCLOUD1441
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__SWM__Local_Software_Activation
    [Tags]  QC_69691
    Setup Scout  10_18_UTESRANCLOUD1441
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__LTE_cell_lock_unlock_from_ADMIN
    [Tags]  QC_69694
    Setup Scout  10_18_UTESRANCLOUD1441
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__GSM_TRX_lock_unlock_from_BSC
    [Tags]  QC_69695
    Setup Scout  10_18_UTESRANCLOUD1441
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__LTE_RAT_reset__parameter_change__ADMIN
    [Tags]  QC_69693
    Setup Scout  10_18_UTESRANCLOUD1441
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__CM__Commissioning_planned_commissioning
    [Tags]  QC_69699
    Setup Scout  10_18_UTESRANCLOUD1441
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__LTE_cell_block_unblock_from_ADMIN
    [Tags]  QC_69701
    Setup Scout  10_18_UTESRANCLOUD1441
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__BS-RF__Embedded_Power_Meter_EEM_act_deact_in_WebEM
    [Tags]  QC_69702
    Setup Scout  10_18_UTESRANCLOUD1441
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__BS-RF__CPRI_Chaining_Deactivation_Activation_via_WebEM
    [Tags]  QC_69703
    Setup Scout  10_18_UTESRANCLOUD1441
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__LOGS__Snapshot
    [Tags]  QC_69708
    Setup Scout  10_18_UTESRANCLOUD1441
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__PM__TNL_counters_are_available_on_ram_disk_versus_NIDD_counter_list
    [Tags]  QC_69706
    Setup Scout  10_18_UTESRANCLOUD1441
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__SWM__Local_Software_Download
    [Tags]  QC_69704
    Setup Scout  10_18_UTESRANCLOUD1441
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__PM__WBTS_counters_are_available_on_ram_disk_versus_NIDD_counter_list
    [Tags]  QC_69705
    Setup Scout  10_18_UTESRANCLOUD1441
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__SWM__Local_Software_Download_Cancel
    [Tags]  QC_69700
    Setup Scout  10_18_UTESRANCLOUD1441
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__PM__LTE_counters_are_available_on_ram_disk_versus_NIDD_counter_list
    [Tags]  QC_69707
    Setup Scout  10_18_UTESRANCLOUD1441
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__S1_Lock_Reset_Unlock
    [Tags]  QC_69713
    Setup Scout  10_18_UTESRANCLOUD1441
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__GSM_TRX_block_unblock_from_ADMIN
    [Tags]  QC_69710
    Setup Scout  10_18_UTESRANCLOUD1441
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__SWM__SW_download_and_activation_SBTS_to_SBTS_uncommissioned
    [Tags]  QC_69717
    Setup Scout  10_18_UTESRANCLOUD1441
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__CM__Commissioning__Configuration_reset
    [Tags]  QC_69719
    Setup Scout  10_18_UTESRANCLOUD1441
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__GSM_BCF_reset_from_BSC
    [Tags]  QC_69715
    Setup Scout  10_18_UTESRANCLOUD1441
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__WCDMA_RAT_reset__parameter_change__ADMIN
    [Tags]  QC_69709
    Setup Scout  10_18_UTESRANCLOUD1441
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__WCDMA_cell_block_unblock
    [Tags]  QC_69712
    Setup Scout  10_18_UTESRANCLOUD1441
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__SWM__SBTS_SOAM_rollback_to_SBTS_SOAM
    [Tags]  QC_69722
    Setup Scout  10_18_UTESRANCLOUD1441
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__GSM_BTS_lock_unlock_from_BSC
    [Tags]  QC_69720
    Setup Scout  10_18_UTESRANCLOUD1441
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__SWM__SW_update_for_new_RF_unit_uncommissioned
    [Tags]  QC_69718
    Setup Scout  10_18_UTESRANCLOUD1441
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__CM_CABLE_SPEED_CHANGE
    [Tags]  QC_69714
    Setup Scout  10_18_UTESRANCLOUD1441
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__FM__Recovery_whole_multiple_Link_Break
    [Tags]  QC_69716
    Setup Scout  10_18_UTESRANCLOUD1441
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__LTE_S1_Lock_Unlock
    [Tags]  QC_69711
    Setup Scout  10_18_UTESRANCLOUD1441
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__LTE_RAT_reset_from_ADMIN
    [Tags]  QC_69723
    Setup Scout  10_18_UTESRANCLOUD1441
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__Radio_module_reset_from_Admin
    [Tags]  QC_69721
    Setup Scout  10_18_UTESRANCLOUD1441
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Site_reset_without_HWF_in_loop
    [Tags]  QC_111760
    Setup Scout  10_18_UTESRANCLOUD1441
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]SW upgrade in loop
    [Tags]  QC_260948
    Setup Scout  10_18_UTESRANCLOUD1441
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__WCDMA_cell_lock_unlock_from_RNC
    [Tags]  QC_69585
    Setup Scout  10_18_UTESRANCLOUD1228
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__LTE_RAT_reset__parameter_change__ADMIN
    [Tags]  QC_69586
    Setup Scout  10_18_UTESRANCLOUD1228
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__Site_reset
    [Tags]  QC_69587
    Setup Scout  10_18_UTESRANCLOUD1228
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__CM__Commissioning__Configuration_reset
    [Tags]  QC_69588
    Setup Scout  10_18_UTESRANCLOUD1228
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__Site_power_reset
    [Tags]  QC_69589
    Setup Scout  10_18_UTESRANCLOUD1228
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__LOGS__Snapshot_content__postmortem_files_creation_for_SMOD
    [Tags]  QC_69590
    Setup Scout  10_18_UTESRANCLOUD1228
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__WCDMA_RAT_reset__parameter_change__ADMIN
    [Tags]  QC_69591
    Setup Scout  10_18_UTESRANCLOUD1228
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__SWM__SW_update_for_RMOD_with_fault_23
    [Tags]  QC_69595
    Setup Scout  10_18_UTESRANCLOUD1228
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__SBTS_block_unblock
    [Tags]  QC_69596
    Setup Scout  10_18_UTESRANCLOUD1228
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__FM__RF_hot_remove_hot_insert
    [Tags]  QC_69599
    Setup Scout  10_18_UTESRANCLOUD1228
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__CM__Recommissioning_with_BTS_reset
    [Tags]  QC_69598
    Setup Scout  10_18_UTESRANCLOUD1228
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__LTE_cell_lock_unlock_from_ADMIN
    [Tags]  QC_69597
    Setup Scout  10_18_UTESRANCLOUD1228
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__SWM__Local_Software_Download
    [Tags]  QC_69601
    Setup Scout  10_18_UTESRANCLOUD1228
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__SWM__Local_Software_Activation
    [Tags]  QC_69600
    Setup Scout  10_18_UTESRANCLOUD1228
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__LTE_cell_block_unblock_from_ADMIN
    [Tags]  QC_69604
    Setup Scout  10_18_UTESRANCLOUD1228
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__CM__Recommissioning_delta_commissioning_with_reset
    [Tags]  QC_69603
    Setup Scout  10_18_UTESRANCLOUD1228
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__CM_CABLE_SPEED_CHANGE
    [Tags]  QC_69609
    Setup Scout  10_18_UTESRANCLOUD1228
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__CM__Recommissioning_delta_commissioning_without_reset
    [Tags]  QC_69606
    Setup Scout  10_18_UTESRANCLOUD1228
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__FM__RF_module_alarm_with_reco_reset
    [Tags]  QC_69610
    Setup Scout  10_18_UTESRANCLOUD1228
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__GSM_TRX_lock_unlock_from_BSC
    [Tags]  QC_69614
    Setup Scout  10_18_UTESRANCLOUD1228
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__S1_Lock_Reset_Unlock
    [Tags]  QC_69612
    Setup Scout  10_18_UTESRANCLOUD1228
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__SWM__Local_Software_Download_Cancel
    [Tags]  QC_69611
    Setup Scout  10_18_UTESRANCLOUD1228
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__PM__WBTS_counters_are_available_on_ram_disk_versus_NIDD_counter_list
    [Tags]  QC_69613
    Setup Scout  10_18_UTESRANCLOUD1228
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__CM__Commissioning_planned_commissioning
    [Tags]  QC_69607
    Setup Scout  10_18_UTESRANCLOUD1228
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__CM_Cell_Removal_LTE
    [Tags]  QC_69608
    Setup Scout  10_18_UTESRANCLOUD1228
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__WCDMA_RAT_reset_from_ADMIN
    [Tags]  QC_69620
    Setup Scout  10_18_UTESRANCLOUD1228
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__GSM_BCF_lock_unlock_from_BSC
    [Tags]  QC_69617
    Setup Scout  10_18_UTESRANCLOUD1228
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__LTE_S1_Lock_Unlock
    [Tags]  QC_69622
    Setup Scout  10_18_UTESRANCLOUD1228
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__PM__TNL_counters_are_available_on_ram_disk_versus_NIDD_counter_list
    [Tags]  QC_69626
    Setup Scout  10_18_UTESRANCLOUD1228
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__GSM_BCF_reset_from_BSC
    [Tags]  QC_69615
    Setup Scout  10_18_UTESRANCLOUD1228
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__GSM_BTS_lock_unlock_from_BSC
    [Tags]  QC_69616
    Setup Scout  10_18_UTESRANCLOUD1228
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__LTE_RAT_reset_from_ADMIN
    [Tags]  QC_69631
    Setup Scout  10_18_UTESRANCLOUD1228
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__LOGS__Snapshot
    [Tags]  QC_69619
    Setup Scout  10_18_UTESRANCLOUD1228
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__SWM__SCF_validation_errors_check
    [Tags]  QC_69629
    Setup Scout  10_18_UTESRANCLOUD1228
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__Radio_module_reset_from_Admin
    [Tags]  QC_69627
    Setup Scout  10_18_UTESRANCLOUD1228
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__WCDMA_cell_block_unblock
    [Tags]  QC_69621
    Setup Scout  10_18_UTESRANCLOUD1228
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__PM__LTE_counters_are_available_on_ram_disk_versus_NIDD_counter_list
    [Tags]  QC_69625
    Setup Scout  10_18_UTESRANCLOUD1228
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__CM__LTE_Cell_reconfiguration_to_different_antenna_port
    [Tags]  QC_69623
    Setup Scout  10_18_UTESRANCLOUD1228
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__FM__Recovery_whole_multiple_Link_Break
    [Tags]  QC_69618
    Setup Scout  10_18_UTESRANCLOUD1228
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__SWM__SW_download_and_activation__SBTS_to_SBTS
    [Tags]  QC_69630
    Setup Scout  10_18_UTESRANCLOUD1228
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__SWM__SBTS_SOAM_rollback_to_SBTS_SOAM
    [Tags]  QC_69628
    Setup Scout  10_18_UTESRANCLOUD1228
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Site_reset_without_HWF_in_loop
    [Tags]  QC_111762
    Setup Scout  10_18_UTESRANCLOUD1228
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]SW upgrade in loop
    [Tags]  QC_260944
    Setup Scout  10_18_UTESRANCLOUD1228
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__SWM__Local_Software_Download_Cancel
    [Tags]  QC_69632
    Setup Scout  10_18_UTESRANCLOUD1210
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__SWM__SCF_validation_errors_check
    [Tags]  QC_69633
    Setup Scout  10_18_UTESRANCLOUD1210
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__WCDMA_cell_lock_unlock_from_RNC
    [Tags]  QC_69634
    Setup Scout  10_18_UTESRANCLOUD1210
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__LTE_cell_block_unblock_from_ADMIN
    [Tags]  QC_69635
    Setup Scout  10_18_UTESRANCLOUD1210
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__LTE_S1_Lock_Unlock
    [Tags]  QC_69636
    Setup Scout  10_18_UTESRANCLOUD1210
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__S1_Lock_Reset_Unlock
    [Tags]  QC_69637
    Setup Scout  10_18_UTESRANCLOUD1210
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__Site_reset
    [Tags]  QC_69638
    Setup Scout  10_18_UTESRANCLOUD1210
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__Site_power_reset
    [Tags]  QC_69639
    Setup Scout  10_18_UTESRANCLOUD1210
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__CM__Commissioning_planned_commissioning
    [Tags]  QC_69640
    Setup Scout  10_18_UTESRANCLOUD1210
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__SWM__SBTS_SOAM_rollback_to_SBTS_SOAM
    [Tags]  QC_69642
    Setup Scout  10_18_UTESRANCLOUD1210
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__SWM__Local_Software_Activation
    [Tags]  QC_69643
    Setup Scout  10_18_UTESRANCLOUD1210
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__CM__Recommissioning_delta_commissioning_with_reset
    [Tags]  QC_69641
    Setup Scout  10_18_UTESRANCLOUD1210
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__SWM__SW_update_for_RMOD_with_fault_23
    [Tags]  QC_69645
    Setup Scout  10_18_UTESRANCLOUD1210
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__SWM__Local_Software_Download
    [Tags]  QC_69644
    Setup Scout  10_18_UTESRANCLOUD1210
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__GSM_TRX_lock_unlock_from_BSC
    [Tags]  QC_69646
    Setup Scout  10_18_UTESRANCLOUD1210
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__FM__RF_hot_remove_hot_insert
    [Tags]  QC_69652
    Setup Scout  10_18_UTESRANCLOUD1210
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__PM__TNL_counters_are_available_on_ram_disk_versus_NIDD_counter_list
    [Tags]  QC_69655
    Setup Scout  10_18_UTESRANCLOUD1210
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__PM__LTE_counters_are_available_on_ram_disk_versus_NIDD_counter_list
    [Tags]  QC_69656
    Setup Scout  10_18_UTESRANCLOUD1210
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__CM__Recommissioning_with_BTS_reset
    [Tags]  QC_69653
    Setup Scout  10_18_UTESRANCLOUD1210
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__LOGS__Snapshot_content__postmortem_files_creation_for_SMOD
    [Tags]  QC_69657
    Setup Scout  10_18_UTESRANCLOUD1210
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__WCDMA_RAT_reset_from_ADMIN
    [Tags]  QC_69661
    Setup Scout  10_18_UTESRANCLOUD1210
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__LOGS__Memory_dump_files_creation_in_case_of_DSP_crash
    [Tags]  QC_69659
    Setup Scout  10_18_UTESRANCLOUD1210
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__LOGS__Snapshot
    [Tags]  QC_69658
    Setup Scout  10_18_UTESRANCLOUD1210
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__LTE_RAT_reset__parameter_change__ADMIN
    [Tags]  QC_69660
    Setup Scout  10_18_UTESRANCLOUD1210
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__PM__WBTS_counters_are_available_on_ram_disk_versus_NIDD_counter_list
    [Tags]  QC_69654
    Setup Scout  10_18_UTESRANCLOUD1210
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__CM__Commissioning__Configuration_reset
    [Tags]  QC_69667
    Setup Scout  10_18_UTESRANCLOUD1210
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__SBTS_block_unblock
    [Tags]  QC_69664
    Setup Scout  10_18_UTESRANCLOUD1210
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__GSM_BCF_lock_unlock_from_BSC
    [Tags]  QC_69671
    Setup Scout  10_18_UTESRANCLOUD1210
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__CM_CABLE_SPEED_CHANGE
    [Tags]  QC_69669
    Setup Scout  10_18_UTESRANCLOUD1210
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__WCDMA_RAT_reset__parameter_change__ADMIN
    [Tags]  QC_69662
    Setup Scout  10_18_UTESRANCLOUD1210
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__GSM_BCF_reset_from_BSC
    [Tags]  QC_69673
    Setup Scout  10_18_UTESRANCLOUD1210
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__CM__Recommissioning_delta_commissioning_without_reset
    [Tags]  QC_69663
    Setup Scout  10_18_UTESRANCLOUD1210
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__LTE_cell_lock_unlock_from_ADMIN
    [Tags]  QC_69666
    Setup Scout  10_18_UTESRANCLOUD1210
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__SWM__SW_download_and_activation__SBTS_to_SBTS
    [Tags]  QC_69676
    Setup Scout  10_18_UTESRANCLOUD1210
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__FM__Recovery_whole_multiple_Link_Break
    [Tags]  QC_69674
    Setup Scout  10_18_UTESRANCLOUD1210
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__WCDMA_cell_block_unblock
    [Tags]  QC_69668
    Setup Scout  10_18_UTESRANCLOUD1210
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__GSM_BTS_lock_unlock_from_BSC
    [Tags]  QC_69672
    Setup Scout  10_18_UTESRANCLOUD1210
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__CM_Cell_Removal_LTE
    [Tags]  QC_69670
    Setup Scout  10_18_UTESRANCLOUD1210
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__GSM_TRX_block_unblock_from_ADMIN
    [Tags]  QC_69665
    Setup Scout  10_18_UTESRANCLOUD1210
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__LTE_RAT_reset_from_ADMIN
    [Tags]  QC_69677
    Setup Scout  10_18_UTESRANCLOUD1210
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__Radio_module_reset_from_Admin
    [Tags]  QC_69675
    Setup Scout  10_18_UTESRANCLOUD1210
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Site_reset_without_HWF_in_loop
    [Tags]  QC_111763
    Setup Scout  10_18_UTESRANCLOUD1210
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]SW upgrade in loop
    [Tags]  QC_259173
    Setup Scout  10_18_UTESRANCLOUD1210
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__BS-SM_GSM_RAT_reset_from_ADMIN
    [Tags]  QC_268900
    Setup Scout  10_18_UTESRANCLOUD1210
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__SWM__SW_download_and_activation__SBTS_to_SBTS
    [Tags]  QC_69479
    Setup Scout  10_18_UTESRANCLOUD1603
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__SWM__SBTS_SOAM_rollback_to_SBTS_SOAM
    [Tags]  QC_69480
    Setup Scout  10_18_UTESRANCLOUD1603
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__Site_reset
    [Tags]  QC_69481
    Setup Scout  10_18_UTESRANCLOUD1603
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__WCDMA_cell_lock_unlock_from_RNC
    [Tags]  QC_69483
    Setup Scout  10_18_UTESRANCLOUD1603
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__S1_Lock_Reset_Unlock
    [Tags]  QC_69484
    Setup Scout  10_18_UTESRANCLOUD1603
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__LTE_RAT_reset__parameter_change__ADMIN
    [Tags]  QC_69485
    Setup Scout  10_18_UTESRANCLOUD1603
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__CM__Recommissioning_with_BTS_reset
    [Tags]  QC_69486
    Setup Scout  10_18_UTESRANCLOUD1603
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__Site_power_reset
    [Tags]  QC_69487
    Setup Scout  10_18_UTESRANCLOUD1603
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__CM__Commissioning_planned_commissioning
    [Tags]  QC_69489
    Setup Scout  10_18_UTESRANCLOUD1603
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__FM__RF_hot_remove_hot_insert
    [Tags]  QC_69490
    Setup Scout  10_18_UTESRANCLOUD1603
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__CM__Recommissioning_delta_commissioning_without_reset
    [Tags]  QC_69488
    Setup Scout  10_18_UTESRANCLOUD1603
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__SWM__SCF_validation_errors_check
    [Tags]  QC_69491
    Setup Scout  10_18_UTESRANCLOUD1603
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__FM__Recovery_whole_multiple_Link_Break
    [Tags]  QC_69495
    Setup Scout  10_18_UTESRANCLOUD1603
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__PM__WBTS_counters_are_available_on_ram_disk_versus_NIDD_counter_list
    [Tags]  QC_69496
    Setup Scout  10_18_UTESRANCLOUD1603
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__SWM__SW_update_for_RMOD_with_fault_23
    [Tags]  QC_69494
    Setup Scout  10_18_UTESRANCLOUD1603
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__SWM__Local_Software_Activation
    [Tags]  QC_69499
    Setup Scout  10_18_UTESRANCLOUD1603
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__SWM__Local_Software_Download_Cancel
    [Tags]  QC_69498
    Setup Scout  10_18_UTESRANCLOUD1603
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__PM__LTE_counters_are_available_on_ram_disk_versus_NIDD_counter_list
    [Tags]  QC_69497
    Setup Scout  10_18_UTESRANCLOUD1603
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__LTE_cell_lock_unlock_from_ADMIN
    [Tags]  QC_69503
    Setup Scout  10_18_UTESRANCLOUD1603
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__LOGS__Snapshot_content__postmortem_files_creation_for_SMOD
    [Tags]  QC_69500
    Setup Scout  10_18_UTESRANCLOUD1603
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__SWM__Local_Software_Download
    [Tags]  QC_69504
    Setup Scout  10_18_UTESRANCLOUD1603
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__CM_Cell_Removal_LTE
    [Tags]  QC_69506
    Setup Scout  10_18_UTESRANCLOUD1603
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__LTE_cell_block_unblock_from_ADMIN
    [Tags]  QC_69505
    Setup Scout  10_18_UTESRANCLOUD1603
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__CM_CABLE_SPEED_CHANGE
    [Tags]  QC_69507
    Setup Scout  10_18_UTESRANCLOUD1603
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__LOGS__Snapshot
    [Tags]  QC_69501
    Setup Scout  10_18_UTESRANCLOUD1603
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__WCDMA_RAT_reset__parameter_change__ADMIN
    [Tags]  QC_69502
    Setup Scout  10_18_UTESRANCLOUD1603
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__CM__Recommissioning_delta_commissioning_with_reset
    [Tags]  QC_69514
    Setup Scout  10_18_UTESRANCLOUD1603
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__CM__Commissioning__Configuration_reset
    [Tags]  QC_69511
    Setup Scout  10_18_UTESRANCLOUD1603
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__LTE_S1_Lock_Unlock
    [Tags]  QC_69516
    Setup Scout  10_18_UTESRANCLOUD1603
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__WCDMA_RAT_reset_from_ADMIN
    [Tags]  QC_69513
    Setup Scout  10_18_UTESRANCLOUD1603
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__WCDMA_cell_block_unblock
    [Tags]  QC_69515
    Setup Scout  10_18_UTESRANCLOUD1603
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__SBTS_block_unblock
    [Tags]  QC_69512
    Setup Scout  10_18_UTESRANCLOUD1603
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__Radio_module_reset_from_Admin
    [Tags]  QC_69535
    Setup Scout  10_18_UTESRANCLOUD1603
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__LTE_RAT_reset_from_ADMIN
    [Tags]  QC_69536
    Setup Scout  10_18_UTESRANCLOUD1603
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Site_reset_without_HWF_in_loop
    [Tags]  QC_111761
    Setup Scout  10_18_UTESRANCLOUD1603
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]SW upgrade in loop
    [Tags]  QC_268157
    Setup Scout  10_18_UTESRANCLOUD1603
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__BS_SM_RP001906 SFP speeds in Cli and Infomodel
    [Tags]  QC_410482
    Setup Scout  10_18_UTESRANCLOUD1750
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__BS-SM_RP001906_Output_file_format
    [Tags]  QC_410483
    Setup Scout  10_18_UTESRANCLOUD1750
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__Admin_CLI_get_snapshot_remote
    [Tags]  QC_410484
    Setup Scout  10_18_UTESRANCLOUD1750
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__S1_Lock_Reset_Unlock
    [Tags]  QC_410486
    Setup Scout  10_18_UTESRANCLOUD1750
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__Admin_CLI_site_reset_remote
    [Tags]  QC_410485
    Setup Scout  10_18_UTESRANCLOUD1750
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__SWM__Local_Software_Download_Cancel
    [Tags]  QC_410490
    Setup Scout  10_18_UTESRANCLOUD1750
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__Site_power_reset
    [Tags]  QC_410487
    Setup Scout  10_18_UTESRANCLOUD1750
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Site_reset_without_HWF_in_loop
    [Tags]  QC_410489
    Setup Scout  10_18_UTESRANCLOUD1750
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]SW upgrade in loop
    [Tags]  QC_410488
    Setup Scout  10_18_UTESRANCLOUD1750
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__SWM__SBTS_SOAM_rollback_to_SBTS_SOAM
    [Tags]  QC_410491
    Setup Scout  10_18_UTESRANCLOUD1750
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__PM__TNL_counters_are_available_on_ram_disk_versus_NIDD_counter_list
    [Tags]  QC_410492
    Setup Scout  10_18_UTESRANCLOUD1750
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__SWM__Local_Software_Activation
    [Tags]  QC_410495
    Setup Scout  10_18_UTESRANCLOUD1750
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__SWM__SW_update_for_RMOD_with_fault_23
    [Tags]  QC_410494
    Setup Scout  10_18_UTESRANCLOUD1750
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__PM__LTE_counters_are_available_on_ram_disk_versus_NIDD_counter_list
    [Tags]  QC_410493
    Setup Scout  10_18_UTESRANCLOUD1750
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__CM_CABLE_SPEED_CHANGE
    [Tags]  QC_410498
    Setup Scout  10_18_UTESRANCLOUD1750
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__SWM__Local_Software_Download
    [Tags]  QC_410496
    Setup Scout  10_18_UTESRANCLOUD1750
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__LOGS__Snapshot
    [Tags]  QC_410499
    Setup Scout  10_18_UTESRANCLOUD1750
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__CM_Cell_Removal_LTE
    [Tags]  QC_410497
    Setup Scout  10_18_UTESRANCLOUD1750
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__LOGS__Snapshot_content__postmortem_files_creation_for_SMOD
    [Tags]  QC_410500
    Setup Scout  10_18_UTESRANCLOUD1750
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__FM__Recovery_whole_multiple_Link_Break
    [Tags]  QC_410501
    Setup Scout  10_18_UTESRANCLOUD1750
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__LTE_cell_lock_unlock_from_ADMIN
    [Tags]  QC_410503
    Setup Scout  10_18_UTESRANCLOUD1750
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__LOGS__Memory_dump_files_creation_in_case_of_DSP_crash
    [Tags]  QC_410502
    Setup Scout  10_18_UTESRANCLOUD1750
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__LTE_RAT_reset__parameter_change__ADMIN
    [Tags]  QC_410504
    Setup Scout  10_18_UTESRANCLOUD1750
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__LTE_S1_Lock_Unlock
    [Tags]  QC_410505
    Setup Scout  10_18_UTESRANCLOUD1750
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__LTE_RAT_reset_from_ADMIN
    [Tags]  QC_410506
    Setup Scout  10_18_UTESRANCLOUD1750
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__Radio_module_reset_from_Admin
    [Tags]  QC_410507
    Setup Scout  10_18_UTESRANCLOUD1750
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__SBTS_block_unblock
    [Tags]  QC_410508
    Setup Scout  10_18_UTESRANCLOUD1750
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__CM__Recommissioning_delta_commissioning_with_reset
    [Tags]  QC_410509
    Setup Scout  10_18_UTESRANCLOUD1750
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__CM__Recommissioning_delta_commissioning_without_reset
    [Tags]  QC_410510
    Setup Scout  10_18_UTESRANCLOUD1750
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__CM__Recommissioning_with_BTS_reset
    [Tags]  QC_410511
    Setup Scout  10_18_UTESRANCLOUD1750
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__Site_reset
    [Tags]  QC_410513
    Setup Scout  10_18_UTESRANCLOUD1750
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__SWM__SCF_validation_errors_check
    [Tags]  QC_410516
    Setup Scout  10_18_UTESRANCLOUD1750
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__FM__RF_hot_remove_hot_insert
    [Tags]  QC_410512
    Setup Scout  10_18_UTESRANCLOUD1750
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__CM__Commissioning_planned_commissioning
    [Tags]  QC_410514
    Setup Scout  10_18_UTESRANCLOUD1750
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__CM__Commissioning__Configuration_reset
    [Tags]  QC_410515
    Setup Scout  10_18_UTESRANCLOUD1750
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]5G RAT reset via ADMIN
    [Tags]  QC_410519
    Setup Scout  10_18_UTESRANCLOUD1750
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__LTE_cell_block_unblock_from_ADMIN
    [Tags]  QC_410518
    Setup Scout  10_18_UTESRANCLOUD1750
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__SWM__SW_download_and_activation__SBTS_to_SBTS
    [Tags]  QC_410517
    Setup Scout  10_18_UTESRANCLOUD1750
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]WebEM__Enable_Disable_Energy_Consumption_Measurement_Collectection
    [Tags]  QC_446194
    Setup Scout  10_18_UTESRANCLOUD1750
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]WebEM__Admin_CLI_Radio_Reset
    [Tags]  QC_446195
    Setup Scout  10_18_UTESRANCLOUD1750
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__FM__Recovery_whole_multiple_Link_Break
    [Tags]  QC_434474
    Setup Scout  10_18_UTESRANCLOUD1760
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__SWM__SW_update_for_RMOD_with_fault_23
    [Tags]  QC_434473
    Setup Scout  10_18_UTESRANCLOUD1760
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__SWM__Local_Software_Download_Cancel
    [Tags]  QC_434475
    Setup Scout  10_18_UTESRANCLOUD1760
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__FM__RF_hot_remove_hot_insert
    [Tags]  QC_434476
    Setup Scout  10_18_UTESRANCLOUD1760
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__SWM__SCF_validation_errors_check
    [Tags]  QC_434477
    Setup Scout  10_18_UTESRANCLOUD1760
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__SWM__Local_Software_Download
    [Tags]  QC_434478
    Setup Scout  10_18_UTESRANCLOUD1760
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__SWM__SW_download_and_activation__SBTS_to_SBTS
    [Tags]  QC_434479
    Setup Scout  10_18_UTESRANCLOUD1760
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__SWM__Local_Software_Activation
    [Tags]  QC_434480
    Setup Scout  10_18_UTESRANCLOUD1760
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]SW upgrade in loop
    [Tags]  QC_434481
    Setup Scout  10_18_UTESRANCLOUD1760
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__CM__Commissioning__Configuration_reset
    [Tags]  QC_434482
    Setup Scout  10_18_UTESRANCLOUD1760
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__CM__Recommissioning_delta_commissioning_with_reset
    [Tags]  QC_434483
    Setup Scout  10_18_UTESRANCLOUD1760
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__CM__Recommissioning_delta_commissioning_without_reset
    [Tags]  QC_434484
    Setup Scout  10_18_UTESRANCLOUD1760
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__PM__LTE_counters_are_available_on_ram_disk_versus_NIDD_counter_list
    [Tags]  QC_434487
    Setup Scout  10_18_UTESRANCLOUD1760
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__CM_Cell_Removal_LTE
    [Tags]  QC_434488
    Setup Scout  10_18_UTESRANCLOUD1760
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__LOGS__Snapshot_content__postmortem_files_creation_for_SMOD
    [Tags]  QC_434490
    Setup Scout  10_18_UTESRANCLOUD1760
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__LOGS__Memory_dump_files_creation_in_case_of_DSP_crash
    [Tags]  QC_434492
    Setup Scout  10_18_UTESRANCLOUD1760
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__LTE_cell_block_unblock_from_ADMIN
    [Tags]  QC_434494
    Setup Scout  10_18_UTESRANCLOUD1760
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__LTE_cell_lock_unlock_from_ADMIN
    [Tags]  QC_434493
    Setup Scout  10_18_UTESRANCLOUD1760
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Site_reset_without_HWF_in_loop
    [Tags]  QC_434489
    Setup Scout  10_18_UTESRANCLOUD1760
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__S1_Lock_Reset_Unlock
    [Tags]  QC_434491
    Setup Scout  10_18_UTESRANCLOUD1760
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__LTE_RAT_reset__parameter_change__ADMIN
    [Tags]  QC_434495
    Setup Scout  10_18_UTESRANCLOUD1760
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__LTE_S1_Lock_Unlock
    [Tags]  QC_434496
    Setup Scout  10_18_UTESRANCLOUD1760
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__LTE_RAT_reset_from_ADMIN
    [Tags]  QC_434497
    Setup Scout  10_18_UTESRANCLOUD1760
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__SBTS_block_unblock
    [Tags]  QC_434499
    Setup Scout  10_18_UTESRANCLOUD1760
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__CM__Recommissioning_with_BTS_reset
    [Tags]  QC_434500
    Setup Scout  10_18_UTESRANCLOUD1760
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__LOGS__Snapshot
    [Tags]  QC_434501
    Setup Scout  10_18_UTESRANCLOUD1760
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__Radio_module_reset_from_Admin
    [Tags]  QC_434498
    Setup Scout  10_18_UTESRANCLOUD1760
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__Site_reset
    [Tags]  QC_434503
    Setup Scout  10_18_UTESRANCLOUD1760
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__CM_CABLE_SPEED_CHANGE
    [Tags]  QC_434502
    Setup Scout  10_18_UTESRANCLOUD1760
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__SWM__SBTS_SOAM_rollback_to_SBTS_SOAM
    [Tags]  QC_434504
    Setup Scout  10_18_UTESRANCLOUD1760
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__CM__Commissioning_planned_commissioning
    [Tags]  QC_434505
    Setup Scout  10_18_UTESRANCLOUD1760
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__Site_power_reset
    [Tags]  QC_434485
    Setup Scout  10_18_UTESRANCLOUD1760
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__PM__TNL_counters_are_available_on_ram_disk_versus_NIDD_counter_list
    [Tags]  QC_434486
    Setup Scout  10_18_UTESRANCLOUD1760
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM_RMOD_power_off_on_FID4589
    [Tags]  QC_454859
    Setup Scout  10_18_UTESRANCLOUD1760
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM__RMOD_reset_counter_exceeded_FID1901
    [Tags]  QC_454861
    Setup Scout  10_18_UTESRANCLOUD1760
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM_RMOD_reset_counter_exceeded_FID1900
    [Tags]  QC_454863
    Setup Scout  10_18_UTESRANCLOUD1760
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__LTE_cell_lock_unlock_from_ADMIN
    [Tags]  QC_69357
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[2]Automated__STATE__LTE_cell_lock_unlock_from_ADMIN
    [Tags]  QC_69358
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[3]Automated__STATE__LTE_cell_lock_unlock_from_ADMIN
    [Tags]  QC_69359
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[4]Automated__STATE__LTE_cell_lock_unlock_from_ADMIN
    [Tags]  QC_69360
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[5]Automated__STATE__LTE_cell_lock_unlock_from_ADMIN
    [Tags]  QC_69361
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[6]Automated__STATE__LTE_cell_lock_unlock_from_ADMIN
    [Tags]  QC_69362
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[7]Automated__STATE__LTE_cell_lock_unlock_from_ADMIN
    [Tags]  QC_69363
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[8]Automated__STATE__LTE_cell_lock_unlock_from_ADMIN
    [Tags]  QC_69365
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[9]Automated__STATE__LTE_cell_lock_unlock_from_ADMIN
    [Tags]  QC_69364
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__SBTS_block_unblock
    [Tags]  QC_69367
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[2]Automated__STATE__SBTS_block_unblock
    [Tags]  QC_69368
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[10]Automated__STATE__LTE_cell_lock_unlock_from_ADMIN
    [Tags]  QC_69366
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[3]Automated__STATE__SBTS_block_unblock
    [Tags]  QC_69371
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[4]Automated__STATE__SBTS_block_unblock
    [Tags]  QC_69370
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[5]Automated__STATE__SBTS_block_unblock
    [Tags]  QC_69369
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[6]Automated__STATE__SBTS_block_unblock
    [Tags]  QC_69372
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[7]Automated__STATE__SBTS_block_unblock
    [Tags]  QC_69374
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__Cell_block_unblock_F
    [Tags]  QC_69377
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[8]Automated__STATE__SBTS_block_unblock
    [Tags]  QC_69373
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[9]Automated__STATE__SBTS_block_unblock
    [Tags]  QC_69376
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[10]Automated__STATE__SBTS_block_unblock
    [Tags]  QC_69375
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[2]Automated__STATE__Cell_block_unblock_F
    [Tags]  QC_69380
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[3]Automated__STATE__Cell_block_unblock_F
    [Tags]  QC_69381
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[4]Automated__STATE__Cell_block_unblock_F
    [Tags]  QC_69382
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[5]Automated__STATE__Cell_block_unblock_F
    [Tags]  QC_69383
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[6]Automated__STATE__Cell_block_unblock_F
    [Tags]  QC_69378
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[7]Automated__STATE__Cell_block_unblock_F
    [Tags]  QC_69386
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[8]Automated__STATE__Cell_block_unblock_F
    [Tags]  QC_69384
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[9]Automated__STATE__Cell_block_unblock_F
    [Tags]  QC_69385
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[10]Automated__STATE__Cell_block_unblock_F
    [Tags]  QC_69379
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__WCDMA_RAT_reset_from_ADMIN
    [Tags]  QC_69392
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[2]Automated__STATE__WCDMA_RAT_reset_from_ADMIN
    [Tags]  QC_69389
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[3]Automated__STATE__WCDMA_RAT_reset_from_ADMIN
    [Tags]  QC_69396
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[4]Automated__STATE__WCDMA_RAT_reset_from_ADMIN
    [Tags]  QC_69394
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__LTE_RAT_reset_from_ADMIN
    [Tags]  QC_69398
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[5]Automated__STATE__WCDMA_RAT_reset_from_ADMIN
    [Tags]  QC_69387
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[6]Automated__STATE__WCDMA_RAT_reset_from_ADMIN
    [Tags]  QC_69388
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[7]Automated__STATE__WCDMA_RAT_reset_from_ADMIN
    [Tags]  QC_69391
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[2]Automated__STATE__LTE_RAT_reset_from_ADMIN
    [Tags]  QC_69403
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[3]Automated__STATE__LTE_RAT_reset_from_ADMIN
    [Tags]  QC_69406
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[4]Automated__STATE__LTE_RAT_reset_from_ADMIN
    [Tags]  QC_69401
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[5]Automated__STATE__LTE_RAT_reset_from_ADMIN
    [Tags]  QC_69399
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[8]Automated__STATE__WCDMA_RAT_reset_from_ADMIN
    [Tags]  QC_69393
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[6]Automated__STATE__LTE_RAT_reset_from_ADMIN
    [Tags]  QC_69397
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[9]Automated__STATE__WCDMA_RAT_reset_from_ADMIN
    [Tags]  QC_69395
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[7]Automated__STATE__LTE_RAT_reset_from_ADMIN
    [Tags]  QC_69404
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[10]Automated__STATE__WCDMA_RAT_reset_from_ADMIN
    [Tags]  QC_69390
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__RF_Module_block_unblock
    [Tags]  QC_69407
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[8]Automated__STATE__LTE_RAT_reset_from_ADMIN
    [Tags]  QC_69402
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[2]Automated__STATE__RF_Module_block_unblock
    [Tags]  QC_69413
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__Site_reset
    [Tags]  QC_69422
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[9]Automated__STATE__LTE_RAT_reset_from_ADMIN
    [Tags]  QC_69400
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[10]Automated__STATE__LTE_RAT_reset_from_ADMIN
    [Tags]  QC_69405
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[3]Automated__STATE__RF_Module_block_unblock
    [Tags]  QC_69408
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[2]Automated__STATE__Site_reset
    [Tags]  QC_69418
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[4]Automated__STATE__RF_Module_block_unblock
    [Tags]  QC_69410
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[3]Automated__STATE__Site_reset
    [Tags]  QC_69423
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[5]Automated__STATE__RF_Module_block_unblock
    [Tags]  QC_69414
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[4]Automated__STATE__Site_reset
    [Tags]  QC_69419
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[6]Automated__STATE__RF_Module_block_unblock
    [Tags]  QC_69409
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[5]Automated__STATE__Site_reset
    [Tags]  QC_69424
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[7]Automated__STATE__RF_Module_block_unblock
    [Tags]  QC_69411
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[8]Automated__STATE__RF_Module_block_unblock
    [Tags]  QC_69415
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[6]Automated__STATE__Site_reset
    [Tags]  QC_69420
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[7]Automated__STATE__Site_reset
    [Tags]  QC_69425
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[9]Automated__STATE__RF_Module_block_unblock
    [Tags]  QC_69412
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[10]Automated__STATE__RF_Module_block_unblock
    [Tags]  QC_69416
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[8]Automated__STATE__Site_reset
    [Tags]  QC_69421
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[9]Automated__STATE__Site_reset
    [Tags]  QC_69426
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[10]Automated__STATE__Site_reset
    [Tags]  QC_69417
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__CM__Commissioning__Configuration_reset
    [Tags]  QC_367871
    Setup Scout  10_18_UTESRANCLOUD1318
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__LTE_cell_lock_unlock_from_ADMIN
    [Tags]  QC_367873
    Setup Scout  10_18_UTESRANCLOUD1318
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__CM__Commissioning_planned_commissioning
    [Tags]  QC_367874
    Setup Scout  10_18_UTESRANCLOUD1318
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Site_reset_without_HWF_in_loop
    [Tags]  QC_367877
    Setup Scout  10_18_UTESRANCLOUD1318
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__RF_Module_lock_unlock
    [Tags]  QC_367876
    Setup Scout  10_18_UTESRANCLOUD1318
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__Site_reset
    [Tags]  QC_367878
    Setup Scout  10_18_UTESRANCLOUD1318
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__SWM__SBTS_SOAM_rollback_to_SBTS_SOAM
    [Tags]  QC_395463
    Setup Scout  10_18_UTESRANCLOUD1318
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__SWM__SW_download_and_activation__SBTS_to_SBTS
    [Tags]  QC_395462
    Setup Scout  10_18_UTESRANCLOUD1318
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__4G_RRM__LTE_data_transfer
    [Tags]  QC_408908
    Setup Scout  10_18_UTESRANCLOUD1318
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]WebEM__LTEL2CellConfigurationCollector_script
    [Tags]  QC_380768
    Setup Scout  10_18_UTESRANCLOUD1318
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__SWM__SBTS_SOAM_rollback_to_SBTS_SOAM
    [Tags]  QC_405103
    Setup Scout  10_18_UTESRANCLOUD1319
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__SWM__SW_download_and_activation__SBTS_to_SBTS
    [Tags]  QC_405104
    Setup Scout  10_18_UTESRANCLOUD1319
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__Site_reset
    [Tags]  QC_405105
    Setup Scout  10_18_UTESRANCLOUD1319
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Site_reset_without_HWF_in_loop
    [Tags]  QC_405106
    Setup Scout  10_18_UTESRANCLOUD1319
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__CM__Commissioning_planned_commissioning
    [Tags]  QC_405108
    Setup Scout  10_18_UTESRANCLOUD1319
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__LTE_cell_lock_unlock_from_ADMIN
    [Tags]  QC_405109
    Setup Scout  10_18_UTESRANCLOUD1319
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__RF_Module_lock_unlock
    [Tags]  QC_405107
    Setup Scout  10_18_UTESRANCLOUD1319
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__CM__Commissioning__Configuration_reset
    [Tags]  QC_405110
    Setup Scout  10_18_UTESRANCLOUD1319
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]WebEM__Troubleshooting_scripts_menu
    [Tags]  QC_380769
    Setup Scout  10_18_UTESRANCLOUD1319
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]WebEM__Troubleshooting_scripts_cli
    [Tags]  QC_380770
    Setup Scout  10_18_UTESRANCLOUD1319
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]WebEM__Script_naming_rule
    [Tags]  QC_380771
    Setup Scout  10_18_UTESRANCLOUD1319
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__CM__Commissioning__Configuration_reset
    [Tags]  QC_367887
    Setup Scout  10_18_UTESRANCLOUD1470
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__LTE_cell_lock_unlock_from_ADMIN
    [Tags]  QC_367888
    Setup Scout  10_18_UTESRANCLOUD1470
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__RF_Module_lock_unlock
    [Tags]  QC_367889
    Setup Scout  10_18_UTESRANCLOUD1470
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__Site_reset
    [Tags]  QC_367891
    Setup Scout  10_18_UTESRANCLOUD1470
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Site_reset_without_HWF_in_loop
    [Tags]  QC_367890
    Setup Scout  10_18_UTESRANCLOUD1470
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__CM__Commissioning_planned_commissioning
    [Tags]  QC_367892
    Setup Scout  10_18_UTESRANCLOUD1470
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__SWM__SW_download_and_activation__SBTS_to_SBTS
    [Tags]  QC_401236
    Setup Scout  10_18_UTESRANCLOUD1470
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__SWM__SBTS_SOAM_rollback_to_SBTS_SOAM
    [Tags]  QC_401237
    Setup Scout  10_18_UTESRANCLOUD1470
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__SWM__SBTS_SOAM_rollback_to_SBTS_SOAM
    [Tags]  QC_409268
    Setup Scout  10_18_UTESRANCLOUD1472
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__SWM__SW_download_and_activation__SBTS_to_SBTS
    [Tags]  QC_409269
    Setup Scout  10_18_UTESRANCLOUD1472
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__CM__Commissioning__Configuration_reset
    [Tags]  QC_409272
    Setup Scout  10_18_UTESRANCLOUD1472
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Site_reset_without_HWF_in_loop
    [Tags]  QC_409271
    Setup Scout  10_18_UTESRANCLOUD1472
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__CM__Commissioning_planned_commissioning
    [Tags]  QC_409270
    Setup Scout  10_18_UTESRANCLOUD1472
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__RF_Module_lock_unlock
    [Tags]  QC_409274
    Setup Scout  10_18_UTESRANCLOUD1472
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__Site_reset
    [Tags]  QC_409273
    Setup Scout  10_18_UTESRANCLOUD1472
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__SWM__SW_download_and_activation__SBTS_to_SBTS
    [Tags]  QC_409275
    Setup Scout  10_18_UTESRANCLOUD1471
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__SWM__SBTS_SOAM_rollback_to_SBTS_SOAM
    [Tags]  QC_409276
    Setup Scout  10_18_UTESRANCLOUD1471
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__RF_Module_lock_unlock
    [Tags]  QC_409279
    Setup Scout  10_18_UTESRANCLOUD1471
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Site_reset_without_HWF_in_loop
    [Tags]  QC_409277
    Setup Scout  10_18_UTESRANCLOUD1471
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__LTE_cell_lock_unlock_from_ADMIN
    [Tags]  QC_409280
    Setup Scout  10_18_UTESRANCLOUD1471
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__Site_reset
    [Tags]  QC_409278
    Setup Scout  10_18_UTESRANCLOUD1471
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__CM__Commissioning__Configuration_reset
    [Tags]  QC_409281
    Setup Scout  10_18_UTESRANCLOUD1471
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__CM__Commissioning_planned_commissioning
    [Tags]  QC_409282
    Setup Scout  10_18_UTESRANCLOUD1471
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__CM__Commissioning__Configuration_reset
    [Tags]  QC_409496
    Setup Scout  10_18_UTESRANCLOUD1305
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__Site_reset
    [Tags]  QC_409497
    Setup Scout  10_18_UTESRANCLOUD1305
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__RF_Module_lock_unlock
    [Tags]  QC_409499
    Setup Scout  10_18_UTESRANCLOUD1305
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__CM__Commissioning_planned_commissioning
    [Tags]  QC_409498
    Setup Scout  10_18_UTESRANCLOUD1305
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__SWM__SW_download_and_activation__SBTS_to_SBTS
    [Tags]  QC_409494
    Setup Scout  10_18_UTESRANCLOUD1305
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__LTE_cell_lock_unlock_from_ADMIN
    [Tags]  QC_409495
    Setup Scout  10_18_UTESRANCLOUD1305
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__SWM__SBTS_SOAM_rollback_to_SBTS_SOAM
    [Tags]  QC_409493
    Setup Scout  10_18_UTESRANCLOUD1305
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Site_reset_without_HWF_in_loop
    [Tags]  QC_409500
    Setup Scout  10_18_UTESRANCLOUD1305
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__SWM__SBTS_SOAM_rollback_to_SBTS_SOAM
    [Tags]  QC_409485
    Setup Scout  10_18_UTESRANCLOUD1346
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__SWM__SW_download_and_activation__SBTS_to_SBTS
    [Tags]  QC_409486
    Setup Scout  10_18_UTESRANCLOUD1346
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__LTE_cell_lock_unlock_from_ADMIN
    [Tags]  QC_409487
    Setup Scout  10_18_UTESRANCLOUD1346
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__CM__Commissioning__Configuration_reset
    [Tags]  QC_409488
    Setup Scout  10_18_UTESRANCLOUD1346
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__CM__Commissioning_planned_commissioning
    [Tags]  QC_409490
    Setup Scout  10_18_UTESRANCLOUD1346
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__Site_reset
    [Tags]  QC_409489
    Setup Scout  10_18_UTESRANCLOUD1346
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__RF_Module_lock_unlock
    [Tags]  QC_409491
    Setup Scout  10_18_UTESRANCLOUD1346
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Site_reset_without_HWF_in_loop
    [Tags]  QC_409492
    Setup Scout  10_18_UTESRANCLOUD1346
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM_RMOD_power_off_on_FID4589
    [Tags]  QC_454850
    Setup Scout  10_18_UTESRANCLOUD1346
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM_RMOD_reset_counter_exceeded_FID1900
    [Tags]  QC_454854
    Setup Scout  10_18_UTESRANCLOUD1346
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM__RMOD_reset_counter_exceeded_FID1901
    [Tags]  QC_454852
    Setup Scout  10_18_UTESRANCLOUD1346
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Site_reset_without_HWF_in_loop
    [Tags]  QC_367903
    Setup Scout  10_18_UTESRANCLOUD1482
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__RF_Module_lock_unlock
    [Tags]  QC_367904
    Setup Scout  10_18_UTESRANCLOUD1482
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__CM__Commissioning_planned_commissioning
    [Tags]  QC_367907
    Setup Scout  10_18_UTESRANCLOUD1482
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__Site_reset
    [Tags]  QC_367908
    Setup Scout  10_18_UTESRANCLOUD1482
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__CM__Commissioning__Configuration_reset
    [Tags]  QC_367909
    Setup Scout  10_18_UTESRANCLOUD1482
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__LTE_cell_lock_unlock_from_ADMIN
    [Tags]  QC_367910
    Setup Scout  10_18_UTESRANCLOUD1482
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__SWM__SW_download_and_activation__SBTS_to_SBTS
    [Tags]  QC_407342
    Setup Scout  10_18_UTESRANCLOUD1482
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__SWM__SBTS_SOAM_rollback_to_SBTS_SOAM
    [Tags]  QC_407343
    Setup Scout  10_18_UTESRANCLOUD1482
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__CM__Commissioning_planned_commissioning
    [Tags]  QC_367880
    Setup Scout  10_18_UTESRANCLOUD1344
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__LTE_cell_lock_unlock_from_ADMIN
    [Tags]  QC_367881
    Setup Scout  10_18_UTESRANCLOUD1344
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__CM__Commissioning__Configuration_reset
    [Tags]  QC_367882
    Setup Scout  10_18_UTESRANCLOUD1344
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__Site_reset
    [Tags]  QC_367883
    Setup Scout  10_18_UTESRANCLOUD1344
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__RF_Module_lock_unlock
    [Tags]  QC_367886
    Setup Scout  10_18_UTESRANCLOUD1344
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Site_reset_without_HWF_in_loop
    [Tags]  QC_367885
    Setup Scout  10_18_UTESRANCLOUD1344
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__SWM__SBTS_SOAM_rollback_to_SBTS_SOAM
    [Tags]  QC_395461
    Setup Scout  10_18_UTESRANCLOUD1344
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__SWM__SW_download_and_activation__SBTS_to_SBTS
    [Tags]  QC_395460
    Setup Scout  10_18_UTESRANCLOUD1344
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__2G_RRM__AMR_over_GSM
    [Tags]  QC_408904
    Setup Scout  10_18_UTESRANCLOUD1344
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__2G_RRM__GSM_data_transfer
    [Tags]  QC_408905
    Setup Scout  10_18_UTESRANCLOUD1344
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__4G_RRM__LTE_data_transfer
    [Tags]  QC_408906
    Setup Scout  10_18_UTESRANCLOUD1344
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__SWM__SBTS_SOAM_rollback_to_SBTS_SOAM
    [Tags]  QC_405150
    Setup Scout  10_18_UTESRANCLOUD1481
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__SWM__SW_download_and_activation__SBTS_to_SBTS
    [Tags]  QC_405149
    Setup Scout  10_18_UTESRANCLOUD1481
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Site_reset_without_HWF_in_loop
    [Tags]  QC_405151
    Setup Scout  10_18_UTESRANCLOUD1481
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__RF_Module_lock_unlock
    [Tags]  QC_405152
    Setup Scout  10_18_UTESRANCLOUD1481
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__Site_reset
    [Tags]  QC_405153
    Setup Scout  10_18_UTESRANCLOUD1481
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__CM__Commissioning__Configuration_reset
    [Tags]  QC_405154
    Setup Scout  10_18_UTESRANCLOUD1481
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__LTE_cell_lock_unlock_from_ADMIN
    [Tags]  QC_405155
    Setup Scout  10_18_UTESRANCLOUD1481
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__CM__Commissioning_planned_commissioning
    [Tags]  QC_405156
    Setup Scout  10_18_UTESRANCLOUD1481
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__SWM__SW_download_and_activation__SBTS_to_SBTS
    [Tags]  QC_446064
    Setup Scout  10_18_UTESRANCLOUD1320
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Site_reset_without_HWF_in_loop
    [Tags]  QC_446063
    Setup Scout  10_18_UTESRANCLOUD1320
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__RF_Module_lock_unlock
    [Tags]  QC_446061
    Setup Scout  10_18_UTESRANCLOUD1320
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__CM__Commissioning__Configuration_reset
    [Tags]  QC_446065
    Setup Scout  10_18_UTESRANCLOUD1320
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__Site_reset
    [Tags]  QC_446066
    Setup Scout  10_18_UTESRANCLOUD1320
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__CM__Commissioning_planned_commissioning
    [Tags]  QC_446068
    Setup Scout  10_18_UTESRANCLOUD1320
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__SWM__SBTS_SOAM_rollback_to_SBTS_SOAM
    [Tags]  QC_446067
    Setup Scout  10_18_UTESRANCLOUD1320
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

*** Keywords ***