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
	
*** Keywords ***