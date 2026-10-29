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
	
*** Keywords ***