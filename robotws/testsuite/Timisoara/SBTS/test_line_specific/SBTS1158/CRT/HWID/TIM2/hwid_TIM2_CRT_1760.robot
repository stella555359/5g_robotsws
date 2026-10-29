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
	
*** Keywords ***