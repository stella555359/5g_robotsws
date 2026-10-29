*** Settings ***
Force Tags  QCD_MN_RAN  QCP_RAN_ST  SRAN  CLOUD_SRAN_LWG_10761_1ASIA_3ABIA_1MDEA_1ExtASIB_2FXDB_3FRGU_2FXED_1FRMF  STATE_COMMISSIONED
Library           XML  use_lxml=True
Resource    ../../../test_resources/CIT/CM_CABLE_SPEED_CHANGE.robot
Resource    ../../../test_resources/CIT/CM_Cell_Addition_LTE.robot
Resource    ../../../test_resources/CIT/CM_Cell_Removal_LTE.robot
Resource    ../../../test_resources/CIT/CM__Commissioning__Configuration_reset.robot
Resource    ../../../test_resources/CIT/CM__Commissioning__Planned_commissioning.robot
Resource    ../../../test_resources/CIT/CM__Recommissioning_with_BTS_reset.robot
Resource    ../../../test_resources/CIT/CM__Recommissioning_delta_commissioning_with_reset.robot
Resource    ../../../test_resources/CIT/CM__Recommissioning_delta_commissioning_without_reset.robot
Resource    ../../../test_resources/FM/FM__RF_hot_remove_hot_insert.robot
Resource    ../../../test_resources/FM/FM__Recovery_whole_multiple_Link_Break.robot
Resource    ../../../test_resources/CIT/LOGS__Memory_dump_files_creation_in_case_of_DSP_crash.robot
Resource    ../../../test_resources/CIT/LOGS__Postmortem_files_creation_in_snapshot_content_for_SMOD.robot
Resource    ../../../test_resources/CIT/LOGS__Snapshot.robot
Resource    ../../../test_resources/CIT/PM__LTE_counters_are_available_on_ram_disk_versus_NIDD_counter_list.robot
Resource    ../../../test_resources/CIT/PM__TNL_counters_are_available_on_ram_disk_versus_NIDD_counter_list.robot
Resource    ../../../test_resources/CIT/PM__WBTS_counters_are_available_on_ram_disk_versus_NIDD_counter_list.robot
Resource    ../../../test_resources/CIT/STATE__GSM_BCF_lock_unlock_from_BSC.robot
Resource    ../../../test_resources/CIT/STATE__GSM_BCF_reset_from_BSC.robot
Resource    ../../../test_resources/CIT/STATE__GSM_BTS_lock_unlock_from_BSC.robot
Resource    ../../../test_resources/CIT/STATE__GSM_TRX_block_unblock_from_ADMIN.robot
Resource    ../../../test_resources/CIT/STATE__GSM_TRX_lock_unlock_from_BSC.robot
Resource    ../../../test_resources/CIT/STATE__LTE_RAT_reset__parameter_change__ADMIN.robot
Resource    ../../../test_resources/CIT/STATE__LTE_RAT_reset_from_ADMIN.robot
Resource    ../../../test_resources/CIT/STATE__LTE_S1_Lock_Unlock.robot
Resource    ../../../test_resources/CIT/STATE__LTE_cell_block_unblock_from_ADMIN.robot
Resource    ../../../test_resources/CIT/STATE__LTE_cell_lock_unlock_from_ADMIN.robot
Resource    ../../../test_resources/CIT/STATE__Radio_module_reset_from_admin.robot
Resource    ../../../test_resources/CIT/STATE__S1_lock_reset_unlock.robot
Resource    ../../../test_resources/CIT/STATE__Site_power_reset.robot
Resource    ../../../test_resources/CIT/STATE__Site_reset.robot
Resource    ../../../test_resources/CIT/STATE__WCDMA_RAT_reset__parameter_change__ADMIN.robot
Resource    ../../../test_resources/CIT/STATE__WCDMA_RAT_reset_from_ADMIN.robot
Resource    ../../../test_resources/CIT/STATE__WCDMA_cell_block_unblock.robot
Resource    ../../../test_resources/CIT/STATE__WCDMA_cell_lock_unlock_from_RNC.robot
Resource    ../../../test_resources/CIT/STATE__sbts_block_unblock.robot
Resource    ../../../test_resources/CIT/SWM__Local_Software_Activation.robot
Resource    ../../../test_resources/CIT/SWM__Local_Software_Download.robot
Resource    ../../../test_resources/CIT/SWM__Local_Software_Download_Cancel.robot
Resource    ../../../test_resources/CIT/SWM__SBTS_SOAM_rollback_to_SBTS_SOAM.robot
Resource    ../../../test_resources/CIT/SWM__SCF_validation_errors_check.robot
Resource    ../../../test_resources/CIT/SWM__SW_download_and_activation__SBTS_to_SBTS.robot
Resource    ../../../test_resources/CIT/SWM__SW_update_for_RMOD_with_fault_23.robot
Resource    ../../../test_resources/CIT/SWM__Upload_swconfig.robot
Resource    ../../../test_resources/CIT/CIT_Test_Line_Recovery.robot
Resource    ../../../test_resources/CIT/BS-SM__GSM_RAT_reset_from_ADMIN.robot
Resource    ../../../test_resources/FM/FM__LTE_CCplane_crash_RAT_recovery_reset.robot
Resource    ../../../test_resources/FM/FM__LTE_DSP_crash_DSP_recovery_reset.robot
Resource    ../../../test_resources/FM/FM__RAT_reset_actForceAutoReset_true_enabled_cells.robot
Resource    ../../../test_resources/FM/FM__RAT_reset_counter_exceeded__multi_RAT.robot
Resource    ../../../test_resources/FM/FM__SC_hot_remove_hot_insert.robot
Resource    ../../../test_resources/FM/FM__SC_late_startup_actForceAutoReset_true.robot
Resource    ../../../test_resources/FM/FM__Site_reset_actForceAutoReset_false_enabled_cell.robot
Resource    ../../../test_resources/FM/FM__Site_reset_actForceAutoReset_true_enabled_cell.robot
Resource    ../../../test_resources/FM/FM__Site_reset_counter_cleared_timer_exceeded.robot
Resource    ../../../test_resources/FM/FM__Site_reset_counter_exceeded.robot
Resource    ../../../test_resources/FM/FM__WCDMA_Cplane_fault_RAT_recovery_reset.robot
Resource    ../../../test_resources/FM/FM__WCDMA_DSP_crash_RAT_recovery_reset.robot
Resource    ../../../test_resources/FM/FM__WCDMA_VN_crash_RAT_recovery_reset.robot
Resource    ../../../test_resources/FM/FM__fault_handling_LTE_CPlane.robot


Suite Setup      Set Library Search Order  coam   ute_admin   hran_frame_sbts_taf   hran_frame_sbts_siso   ca_CIT_general   ca_swm_general


*** Variables ***
${SCF_ID}    01
${HW_LOCATION_CODE}      Timisoara
${ENB_BUILD}    SBTS00_ENB_9999_211207_000006
${REQUEST_SCF_SCOUT}    ${TRUE}
${SCOUT_TL_NAME}    10_18_UTESRANCLOUD1761


*** Test Cases ***
[1]Automated__STATE__WCDMA_cell_block_unblock
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${CELL_ID}    
    ...    AND    Set Test Variable    ${ADDITIONAL_IGNORED_ALARMS}    
    ...    [['faultId', '4655', ' alarmId ', '7220'], ['faultId', '4654', 'alarmId', '7220']]
    
    ...    AND    Modify Resource Search Order    STATE__WCDMA_cell_block_unblock
    ...    AND    STATE__WCDMA_cell_block_unblock.TC Setup
    TC__STATE__WCDMA_cell_block_unblock
    [Teardown]    Run Keywords    STATE__WCDMA_cell_block_unblock.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  Run Keyword  CIT Recover Test Line By Power Reset


[1]Automated__STATE__WCDMA_cell_lock_unlock_from_RNC
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${WBTS_NUMBER}    10761
    ...    AND    Set Test Variable    ${WCELL_NUMBER}    37612
    ...    AND    Set Test Variable    ${OMS_IP_ADDRESS}    
    ...    AND    Set Test Variable    ${OMS_USERNAME}    Nemuadmin
    ...    AND    Set Test Variable    ${OMS_PASSWORD}    Nokia@123
    ...    AND    Set Test Variable    ${ADDITIONAL_IGNORED_ALARMS}    
    ...    [['faultId', '4655', ' alarmId ', '7220'], ['faultId', '4654', 'alarmId', '7220']]
    ...    AND    Modify Resource Search Order    STATE__WCDMA_cell_lock_unlock_from_RNC
    ...    AND    STATE__WCDMA_cell_lock_unlock_from_RNC.TC Setup
    TC__STATE__WCDMA_cell_lock_unlock_from_RNC
    [Teardown]    Run Keywords    STATE__WCDMA_cell_lock_unlock_from_RNC.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  Run Keyword  CIT Recover Test Line By Power Reset


[1]FM__WCDMA_Cplane_fault_RAT_recovery_reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    
    ...    AND    FM__WCDMA_Cplane_fault_RAT_recovery_reset.TC Setup
    ...    AND    Modify Resource Search Order    FM__WCDMA_Cplane_fault_RAT_recovery_reset
    TC__FM__WCDMA_Cplane_fault_RAT_recovery_reset
    [Teardown]    Run Keywords    FM__WCDMA_Cplane_fault_RAT_recovery_reset.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__WCDMA_DSP_crash_RAT_recovery_reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    
    ...    AND    FM__WCDMA_DSP_crash_RAT_recovery_reset.TC Setup
    ...    AND    Modify Resource Search Order    FM__WCDMA_DSP_crash_RAT_recovery_reset
    TC__FM__WCDMA_DSP_crash_RAT_recovery_reset
    [Teardown]    Run Keywords    FM__WCDMA_DSP_crash_RAT_recovery_reset.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__WCDMA_VN_crash_RAT_recovery_reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600
    
    ...    AND    FM__WCDMA_VN_crash_RAT_recovery_reset.TC Setup
    ...    AND    Modify Resource Search Order    FM__WCDMA_VN_crash_RAT_recovery_reset
    TC__FM__WCDMA_VN_crash_RAT_recovery_reset
    [Teardown]    Run Keywords    FM__WCDMA_VN_crash_RAT_recovery_reset.TC Teardown
    ...    AND    Restore Resource Search Order
