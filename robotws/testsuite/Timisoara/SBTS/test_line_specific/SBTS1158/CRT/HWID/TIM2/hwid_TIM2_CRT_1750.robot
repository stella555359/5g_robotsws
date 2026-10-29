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
	
*** Keywords ***