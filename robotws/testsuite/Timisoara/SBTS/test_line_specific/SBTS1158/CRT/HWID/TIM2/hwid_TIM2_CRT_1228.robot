*** Settings ***
Force Tags  QCD_MN_RAN  QCP_RAN_ST  SBTS00  SRAN  CLOUD_SRAN_LG_1FSMF_1FBBC_2FXDB_2FRMA_1FRHC  STATE_SKIP_AGENT
Library  XML  use_lxml=True
Library  taf.sw.scout
Library  String
Suite Setup      Set Library Search Order  coam   ute_admin   hran_frame_sbts_taf   hran_frame_sbts_siso   ca_CIT_general   ca_swm_general

Resource    ../../../test_resources/CIT/STATE__Site_reset.robot

*** Variables ***
${SCF_ID}    01
${HW_LOCATION_CODE}      Timisoara

*** Test Cases ***
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
	
*** Keywords ***