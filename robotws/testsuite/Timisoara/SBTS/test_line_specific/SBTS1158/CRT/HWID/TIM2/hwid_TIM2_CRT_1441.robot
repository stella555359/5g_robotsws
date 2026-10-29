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
	
*** Keywords ***