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
[1]Automated__STATE__LTE_S1_Lock_Unlock
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${LTE_STATES}    
    ...    availabilityStatus=Online, blockingState=Unblocked, administrativeState=Unlocked, operationalState=Enabled
    ...    AND    Set Test Variable    ${LTE_STATES_S1_LOCKED}    
    ...    availabilityStatus=Offline, blockingState=Unblocked, administrativeState=Unlocked, operationalState=Disabled
    ...    AND    Set Test Variable    ${WCDMA_STATES}    
    ...    availabilityStatus=Online, blockingState=Unblocked, operationalState=Enabled, usageState=Active
    ...    AND    Set Test Variable    ${GSM_STATES}    
    ...    administrativeState=Unlocked, availabilityStatus=Online, blockingState=Unblocked, operationalState=Enabled, usageState=Active
    ...    AND    Set Test Variable    ${RMOD_STATES}    
    ...    administrativeState=Unlocked, availabilityStatus=Online, blockingState=Unblocked, operationalState=Enabled, usageState=Active
    ...    AND    Set Test Variable    ${ADDITIONAL_IGNORED_ALARMS}    
    ...    [['faultId', '4655', ' alarmId ', '7220'], ['faultId', '4654', 'alarmId', '7220']]
    
    ...    AND    Modify Resource Search Order    STATE__LTE_S1_Lock_Unlock
    ...    AND    STATE__LTE_S1_Lock_Unlock.TC Setup
    TC__STATE__LTE_S1_Lock_Unlock
    [Teardown]    Run Keywords    STATE__LTE_S1_Lock_Unlock.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  Run Keyword  CIT Recover Test Line By Power Reset


[1]Automated__STATE__LTE_cell_block_unblock_from_ADMIN
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${CELL_ID}    ${EMPTY}
    ...    AND    Set Test Variable    ${STATES_ON_BLOCK}
    ...    administrativeState=Unlocked, availabilityStatus=Offline, blockingState=Blocked, operationalState=Disabled
    ...    AND    Set Test Variable    ${STATES_ON_UNBLOCK_LTE}
    ...    administrativeState=Unlocked, availabilityStatus=Online, blockingState=Unblocked, operationalState=Enabled
    ...    AND    Set Test Variable    ${STATES_ON_UNBLOCK_WCDMA}
    ...    availabilityStatus=Online, blockingState=Unblocked, operationalState=Enabled
    ...    AND    Set Test Variable    ${STATES_ON_UNBLOCK_GSM}
    ...    administrativeState=Unlocked, availabilityStatus=Online, blockingState=Unblocked, operationalState=Enabled
    ...    AND    Set Test Variable    ${LOG_TX_POWER}    True
    ...    AND    Set Test Variable    ${ADDITIONAL_IGNORED_ALARMS}    
    ...    [['faultId', '4655', ' alarmId ', '7220'], ['faultId', '4654', 'alarmId', '7220']]
    
    ...    AND    Modify Resource Search Order    STATE__LTE_cell_block_unblock_from_ADMIN
    ...    AND    STATE__LTE_cell_block_unblock_from_ADMIN.TC Setup
    TC__STATE__LTE_cell_block_unblock_from_ADMIN
    [Teardown]    Run Keywords    STATE__LTE_cell_block_unblock_from_ADMIN.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  Run Keyword  CIT Recover Test Line By Power Reset


[1]Automated__STATE__LTE_cell_lock_unlock_from_ADMIN
    [Timeout]    60 minutes
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${CELL_ID}    4
    ...    AND    Set Test Variable    ${ADDITIONAL_IGNORED_ALARMS}    
    ...    [['faultId', '4655', ' alarmId ', '7220'], ['faultId', '4654', 'alarmId', '7220']]
    
    ...    AND    Modify Resource Search Order    STATE__LTE_cell_lock_unlock_from_ADMIN
    ...    AND    STATE__LTE_cell_lock_unlock_from_ADMIN.TC Setup
    TC__STATE__LTE_cell_lock_unlock_from_ADMIN
    [Teardown]    Run Keywords    STATE__LTE_cell_lock_unlock_from_ADMIN.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  Run Keyword  CIT Recover Test Line By Power Reset


[1]FM__LTE_CCplane_crash_RAT_recovery_reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    300
    
    ...    AND    FM__LTE_CCplane_crash_RAT_recovery_reset.TC Setup
    ...    AND    Modify Resource Search Order    FM__LTE_CCplane_crash_RAT_recovery_reset
    TC__FM__LTE_CCplane_crash_RAT_recovery_reset
    [Teardown]    Run Keywords    FM__LTE_CCplane_crash_RAT_recovery_reset.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__LTE_DSP_crash_DSP_recovery_reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    120
    
    ...    AND    FM__LTE_DSP_crash_DSP_recovery_reset.TC Setup
    ...    AND    Modify Resource Search Order    FM__LTE_DSP_crash_DSP_recovery_reset
    TC__FM__LTE_DSP_crash_DSP_recovery_reset
    [Teardown]    Run Keywords    FM__LTE_DSP_crash_DSP_recovery_reset.TC Teardown
    ...    AND    Restore Resource Search Order


[1]CM_Cell_Addition_LTE
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${TIMEOUT}    360
    ...    AND    Set Test Variable    ${CELL_ID}    
    ...    AND    Set Test Variable    ${DELTA_PATH}    
    ...    AND    Set Test Variable    ${CALL_BEFORE}    ${FALSE}
    ...    AND    Set Test Variable    ${CALL_AFTER}    ${FALSE}
    ...    AND    Set Test Variable    ${FTP_LABEL}    FTP_SERVER
    ...    AND    Set Test Variable    ${OLD_CELL_UE_SERIAL}    8f544f9b
    ...    AND    Set Test Variable    ${NEW_CELL_UE_SERIAL}    ca67e07a
    ...    AND    Set Test Variable    ${BANDWIDTH}    150M
    ...    AND    Set Test Variable    ${OLD_DL_MAX}    105000000
    ...    AND    Set Test Variable    ${OLD_DL_MIN}    80000000
    ...    AND    Set Test Variable    ${OLD_UL_MAX}    53000000
    ...    AND    Set Test Variable    ${OLD_UL_MIN}    40000000
    ...    AND    Set Test Variable    ${NEW_DL_MAX}    150000000
    ...    AND    Set Test Variable    ${NEW_DL_MIN}    80000000
    ...    AND    Set Test Variable    ${NEW_UL_MAX}    53000000
    ...    AND    Set Test Variable    ${NEW_UL_MIN}    40000000
    
    ...    AND    CM_Cell_Addition_LTE.TC Setup
    ...    AND    Modify Resource Search Order    CM_Cell_Addition_LTE
    TC__CM_Cell_Addition_LTE
    [Teardown]    Run Keywords    CM_Cell_Addition_LTE.TC Teardown
    ...    AND    Restore Resource Search Order


[1]Automated__CM_Cell_Removal_LTE
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${TIMEOUT}    360
    ...    AND    Set Test Variable    ${CELL_ID}    4      
    ...    AND    Set Test Variable    ${ADDITIONAL_IGNORED_ALARMS}    
    ...    [['faultId', '4655', ' alarmId ', '7220'], ['faultId', '4654', 'alarmId', '7220']]
    ...    AND    Modify Resource Search Order    CM_Cell_Removal_LTE
    ...    AND    CM_Cell_Removal_LTE.TC Setup
    TC__CM_Cell_Removal_LTE
    [Teardown]    Run Keywords    CM_Cell_Removal_LTE.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  Run Keyword  CIT Recover Test Line By Power Reset
