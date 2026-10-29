*** Settings ***
Force Tags  QCD_MN_RAN  QCP_RAN_ST  SRAN  CLOUD_SRAN_LWG_1ASIA_3ABIA_1ASIA_3ABIA_3FRIJ_1FRPA_2FXCB_2FXFC  STATE_COMMISSIONED
Library           XML  use_lxml=True
# Resource    ../../CIT/test_resources/CM__Commissioning__Configuration_reset.robot
Resource    ../../CIT/test_resources/CM__Recommissioning_with_BTS_reset.robot
Resource    ../../CIT/test_resources/CM__Recommissioning_delta_commissioning_with_reset.robot
Resource    ../../CIT/test_resources/CM__Recommissioning_delta_commissioning_without_reset.robot
Resource    ../../FM/test_resources/FM__RF_hot_remove_hot_insert.robot
Resource    ../../FM/test_resources/FM__Recovery_whole_multiple_Link_Break.robot
Resource    ../../FM/test_resources/FM__RAT_reset_actForceAutoReset_true_enabled_cells.robot
Resource    ../../FM/test_resources/FM__Site_reset_actForceAutoReset_true_enabled_cell.robot
Resource    ../../FM/test_resources/FM__WCDMA_Cplane_fault_RAT_recovery_reset.robot
Resource    ../../FM/test_resources/FM__WCDMA_DSP_crash_RAT_recovery_reset.robot
Resource    ../../FM/test_resources/FM__WCDMA_VN_crash_RAT_recovery_reset.robot
Resource    ../../FM/test_resources/FM__LTE_CCplane_crash_RAT_recovery_reset.robot
Resource    ../../FM/test_resources/FM__LTE_DSP_crash_DSP_recovery_reset.robot
Resource    ../../FM/test_resources/FM__FSP_Lom_Fault_Service_crash.robot
Resource    ../../FM/test_resources/FM__Secondary_core_power_off_on.robot
# Resource    ../../FM/test_resources/FM__SC_hot_remove_hot_insert.robot
# Resource    ../../FM/test_resources/FM__SC_late_startup_actForceAutoReset_true.robot
Resource    ../../CIT/test_resources/STATE__Radio_module_reset_from_admin.robot
Resource    ../../CIT/test_resources/STATE__S1_lock_reset_unlock.robot
Resource    ../../CIT/test_resources/STATE__Site_power_reset.robot
Resource    ../../CIT/test_resources/STATE__Site_reset.robot
Resource    ../../CIT/test_resources/STATE__sbts_block_unblock.robot
Resource    ../../CIT/test_resources/STATE__WCDMA_cell_block_unblock.robot
Resource    ../../CIT/test_resources/STATE__WCDMA_cell_lock_unlock_from_RNC.robot
Resource    ../../CIT/test_resources/STATE__GSM_BCF_lock_unlock_from_BSC.robot
Resource    ../../CIT/test_resources/STATE__GSM_BCF_reset_from_BSC.robot
Resource    ../../CIT/test_resources/STATE__GSM_BTS_lock_unlock_from_BSC.robot
Resource    ../../CIT/test_resources/STATE__GSM_TRX_block_unblock_from_ADMIN.robot
Resource    ../../CIT/test_resources/STATE__GSM_TRX_lock_unlock_from_BSC.robot
Resource    ../../CIT/test_resources/STATE__LTE_S1_Lock_Unlock.robot
Resource    ../../CIT/test_resources/STATE__LTE_cell_block_unblock_from_ADMIN.robot
Resource    ../../CIT/test_resources/STATE__LTE_cell_lock_unlock_from_ADMIN.robot
Resource    ../../CIT/test_resources/SWM__SW_download_and_activation__SBTS_to_SBTS.robot
Resource    ../../CIT/test_resources/SWM__Local_Software_Activation.robot
Resource    ../../CIT/test_resources/SWM__Local_Software_Download.robot
Resource    ../../CIT/test_resources/SWM__Local_Software_Download_Cancel.robot
Resource    ../../CIT/test_resources/SWM__SBTS_SOAM_rollback_to_SBTS_SOAM.robot
Resource    ../../CIT/test_resources/SWM__SW_update_for_RMOD_with_fault_23.robot
Resource    ../../CIT/test_resources/BS-SM__GSM_RAT_reset_from_ADMIN.robot
Resource    ../../KPI/test_resources/KPI__BBMOD_Reset_From_WebEM.robot

Suite Setup      Set Library Search Order  coam   ute_admin   hran_frame_sbts_taf   hran_frame_sbts_siso   ca_CIT_general   ca_swm_general

*** Variables ***
${SCF_ID}    01
${HW_LOCATION_CODE}      Timisoara
${ENB_BUILD}    SBTS00_ENB_9999_211207_000006
${REQUEST_SCF_SCOUT}    ${TRUE}
${SCOUT_TL_NAME}    10_18_UTESRANCLOUD1228
${SKIP_RU_POWER_CHECK}    ${TRUE}
# ${DISABLE_WATCHDOG}    ${TRUE}

*** Test Cases ***
[1]Automated__SWM__SW_download_and_activation__SBTS_to_SBTS
    [Tags]    STOPONFAIL
    [Setup]    Run Keywords    Set Test Variable    ${Target SW name}    ${None}
    ...    AND    Set Test Variable    ${Target SW dir}    /home/ute/TARGET_SW
    ...    AND    Set Test Variable    ${SW Update Timeout}    3600
    ...    AND    Set Test Variable    ${Ping loss timeout}    900
    ...    AND    Set Test Variable    ${Ping regain timeout}    1900
    ...    AND    Set Test Variable    ${onAir Check Number}    150
    ...    AND    Set Test Variable    ${First Cell On Air Timeout}    35
    ...    AND    Set Test Variable    ${Ping stable timeout}    409
    ...    AND    Set Test Variable    ${Test Timeout}    120
    ...    AND    Modify Resource Search Order    SWM__SW_download_and_activation__SBTS_to_SBTS
    ...    AND    SWM__SW_download_and_activation__SBTS_to_SBTS.TC Setup

    Run  mkdir ${Target SW dir}
    Run  sudo chmod 777 ${Target SW dir} -R
    Run  wget files.ute.nsn-rdnet.net/builds/enb/base/${ENB_BUILD}/${ENB_BUILD}_release_BTSSM_downloadable.zip -P ${Target SW dir}
    [Timeout]    60 minutes
    TC__SWM__SW_download_and_activation__SBTS_to_SBTS
    [Teardown]    Run Keywords    SWM__SW_download_and_activation__SBTS_to_SBTS.TC Teardown
    ...    AND    Restore Resource Search Order


# [1]Automated__CM__Commissioning__Configuration_reset
#     [Timeout]    20000
#     [Setup]    Run Keywords
#     ...    No Operation
#     ...    AND    Set Test Variable    ${Configuration Reset Timeout}    1200
#     ...    AND    Set Test Variable    ${Conf_reset_by_AdminAPI}    ${TRUE}
#     ...    AND    Set Test Variable    ${RM_DETECTION_TIMEOUT}    35 min
#     ...    AND    Set Test Variable    ${SMOD2_CHECK_TIMEOUT}    25 min
#     ...    AND    Set Test Variable    ${ADDITIONAL_IGNORED_ALARMS}    
#     ...    [['faultId', '4655', ' alarmId ', '7220'], ['faultId', '4654', 'alarmId', '7220']]
    
#     ...    AND    Modify Resource Search Order    CM__Commissioning__Configuration_reset
#     ...    AND    CM__Commissioning__Configuration_reset.TC Setup
#     TC__CM__Commissioning__Configuration_reset
#     [Teardown]    Run Keywords    CM__Commissioning__Configuration_reset.TC Teardown
#     ...    AND    Restore Resource Search Order
#     ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  Run Keyword  CIT Recover Test Line By Power Reset
    

[1]Automated__CM__Recommissioning_with_BTS_reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${PARAMETER_SCF_DIST_NAME}    MRBTS-10228/MNL-1/MNLENT-1/SYNC-1/TIME-1
    ...    AND    Set Test Variable    ${PARAMETER_IM_DIST_NAME}    //TIME_A-1
    ...    AND    Set Test Variable    ${PARAMETER_ABBREVIATION}    timeZone
    ...    AND    Set Test Variable    ${PARAMETER_OPERATION}    update
    ...    AND    Set Test Variable    ${PARAMETER_VALUE}    (GMT+1) Europe/Vienna
    ...    AND    Set Test Variable    ${SKIP_PARAM_RELATION_ERRORS}    ${TRUE}
    ...    AND    Set Test Variable    ${RECOMMISSIONING_TIMEOUT}    3600
    ...    AND    Modify Resource Search Order    CM__Recommissioning_with_BTS_reset
    ...    AND    CM__Recommissioning_with_BTS_reset.TC Setup
    
    TC__CM__Recommissioning_with_BTS_reset
    [Teardown]    Run Keywords    CM__Recommissioning_with_BTS_reset.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  Run Keyword  CIT Recover Test Line By Power Reset


[1]Automated__CM__Recommissioning_delta_commissioning_without_reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${DELTA_JSON_FILE_PATH}
    ...    /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS1228/json/name_delta.json
    ...    AND    Set Test Variable    ${SKIP_PARAM_RELATION_ERRORS}    ${TRUE}
    ...    AND    Set Test Variable    ${RECOMMISSIONING_TIMEOUT}    900
    ...    AND    Set Test Variable    ${ADDITIONAL_IGNORED_ALARMS}    
    ...    [['faultId', '4655', ' alarmId ', '7220'], ['faultId', '4654', 'alarmId', '7220']]
    
    ...    AND    Modify Resource Search Order    CM__Recommissioning_delta_commissioning_without_reset
    ...    AND    CM__Recommissioning_delta_commissioning_without_reset.TC Setup
    TC__CM__Recommissioning_delta_commissioning_without_reset
    [Teardown]    Run Keywords    CM__Recommissioning_delta_commissioning_without_reset.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  Run Keyword  CIT Recover Test Line By Power Reset


[1]Automated__CM__Recommissioning_delta_commissioning_with_reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${DELTA_JSON_FILE_PATH}
    ...    /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS1228/json/time_zone_delta.json
    ...    AND    Set Test Variable    ${SKIP_PARAM_RELATION_ERRORS}    ${TRUE}
    ...    AND    Set Test Variable    ${RECOMMISSIONING_TIMEOUT}    601
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    25
    ...    AND    Set Test Variable    ${ADDITIONAL_IGNORED_ALARMS}    
    ...    [['faultId', '4655', ' alarmId ', '7220'], ['faultId', '4654', 'alarmId', '7220']]
    
    ...    AND    Modify Resource Search Order    CM__Recommissioning_delta_commissioning_with_reset
    ...    AND    CM__Recommissioning_delta_commissioning_with_reset.TC Setup
    TC__CM__Recommissioning_delta_commissioning_with_reset
    [Teardown]    Run Keywords    CM__Recommissioning_delta_commissioning_with_reset.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  Run Keyword  CIT Recover Test Line By Power Reset


[1]Automated__FM__RF_hot_remove_hot_insert
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_SN}    EA171181437
    ...    AND    Set Test Variable    ${PING_RMOD_TIMEOUT}    720
    ...    AND    Set Test Variable    ${CELLS_ONLINE_TIMEOUT}    720
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_ID}    10
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_NAME}    No connection to unit
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_ID}    7116
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_NAME}    BASE STATION SERVICE PROBLEM
    ...    AND    Set Test Variable    ${SEVERITY}    Critical
    ...    AND    Set Test Variable    ${CHECK_NA_ALARM}    False
    ...    AND    Set Test Variable    ${ADDITIONAL_IGNORED_ALARMS}    
    ...    [['faultId', '4655', ' alarmId ', '7220'], ['faultId', '4654', 'alarmId', '7220']]
    ...    AND    Modify Resource Search Order    FM__RF_hot_remove_hot_insert
    ...    AND    FM__RF_hot_remove_hot_insert.TC Setup
    TC__FM__RF_hot_remove_hot_insert
    [Teardown]    Run Keywords    FM__RF_hot_remove_hot_insert.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  Run Keyword  CIT Recover Test Line By Power Reset


[1]Automated__FM__Recovery_whole_multiple_Link_Break
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${NUMBER_OF_LOOPS}    6
    ...    AND    Set Test Variable    ${TIMEOUT_AFTER_RESTOR}    3600
    ...    AND    Set Test Variable    ${ADDITIONAL_IGNORED_ALARMS}    
    ...    [['faultId', '4655', ' alarmId ', '7220'], ['faultId', '4654', 'alarmId', '7220']]
    ...    AND    Modify Resource Search Order    FM__Recovery_whole_multiple_Link_Break
    ...    AND    FM__Recovery_whole_multiple_Link_Break.TC Setup
    TC__FM__Recovery_whole_multiple_Link_Break
    [Teardown]    Run Keywords    FM__Recovery_whole_multiple_Link_Break.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  Run Keyword  CIT Recover Test Line By Power Reset


[1]FM__RAT_reset_actForceAutoReset_true_enabled_cells
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    360
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    660
    
    ...    AND    FM__RAT_reset_actForceAutoReset_true_enabled_cells.TC Setup
    ...    AND    Modify Resource Search Order    FM__RAT_reset_actForceAutoReset_true_enabled_cells
    TC__FM__RAT_reset_actForceAutoReset_true_enabled_cells
    [Teardown]    Run Keywords    FM__RAT_reset_actForceAutoReset_true_enabled_cells.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__Site_reset_actForceAutoReset_true_enabled_cell
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    180
    ...    AND    Set Test Variable    ${PING_TIMEOUT}    120
    
    ...    AND    FM__Site_reset_actForceAutoReset_true_enabled_cell.TC Setup
    ...    AND    Modify Resource Search Order    FM__Site_reset_actForceAutoReset_true_enabled_cell
    TC__FM__Site_reset_actForceAutoReset_true_enabled_cell
    [Teardown]    Run Keywords    FM__Site_reset_actForceAutoReset_true_enabled_cell.TC Teardown
    ...    AND    Restore Resource Search Order


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


[1]FM__FSP_LOM_Fault_service_crash_handling
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${BBMOD_TYPE}    ABIA
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    900
    
    ...    AND    FM__FSP_Lom_Fault_Service_crash.TC Setup
    ...    AND    Modify Resource Search Order    FM__FSP_Lom_Fault_Service_crash
    TC__FM__FSP_Lom_Fault_Service_crash
    [Teardown]    Run Keywords    FM__FSP_Lom_Fault_Service_crash.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__Secondary_core_power_off_on
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${EXPECTED_FAULT}    4590

    ...    AND    FM__Secondary_core_power_off_on.TC Setup
    ...    AND    Modify Resource Search Order    FM__Secondary_core_power_off_on
    TC__FM__Secondary_Core_power_off_on
    [Teardown]    Run Keywords    FM__Secondary_core_power_off_on.TC Teardown
    ...    AND    Restore Resource Search Order


[1]Automated__STATE__Radio_module_reset_from_Admin
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_SERIAL_NUMBER}    EA171181437
    ...    AND    Set Test Variable    ${RESET_TIMEOUT}    3600
    ...    AND    Set Test Variable    ${RESETTYPE}    Warm
    ...    AND    Set Test Variable    ${BCF_VERIFICATION_TIMEOUT}    5 minutes
    ...    AND    Set Test Variable    ${ADDITIONAL_IGNORED_ALARMS}    
    ...    [['faultId', '4655', ' alarmId ', '7220'], ['faultId', '4654', 'alarmId', '7220']]
    
    ...    AND    Modify Resource Search Order    STATE__Radio_module_reset_from_admin
    ...    AND    STATE__Radio_module_reset_from_admin.TC Setup
    TC__STATE__Radio_module_reset_from_admin
    [Teardown]    Run Keywords    STATE__Radio_module_reset_from_admin.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  Run Keyword  CIT Recover Test Line By Power Reset


[1]Automated__STATE__S1_Lock_Reset_Unlock
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
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    10
    ...    AND    Set Test Variable    ${ADDITIONAL_IGNORED_ALARMS}    
    ...    [['faultId', '4655', ' alarmId ', '7220'], ['faultId', '4654', 'alarmId', '7220']]
    
    ...    AND    Modify Resource Search Order    STATE__S1_lock_reset_unlock
    ...    AND    STATE__S1_lock_reset_unlock.TC Setup
    TC__STATE__S1_Lock_Reset_Unlock
    [Teardown]    Run Keywords    STATE__S1_lock_reset_unlock.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  Run Keyword  CIT Recover Test Line By Power Reset


[1]Automated__STATE__Site_power_reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    60
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    False
    ...    AND    Set Test Variable    ${ADDITIONAL_IGNORED_ALARMS}    
    ...    [['faultId', '4655', ' alarmId ', '7220'], ['faultId', '4654', 'alarmId', '7220']]
    
    ...    AND    Modify Resource Search Order    STATE__Site_power_reset
    ...    AND    STATE__Site_power_reset.TC Setup
    TC__STATE__Site_power_reset
    [Teardown]    Run Keywords    STATE__Site_power_reset.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  Run Keyword  CIT Recover Test Line By Power Reset


[1]Automated__STATE__Site_reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    60
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    False
    ...    AND    Set Test Variable    ${ADDITIONAL_IGNORED_ALARMS}    
    ...    [['faultId', '4655', ' alarmId ', '7220'], ['faultId', '4654', 'alarmId', '7220']]
    
    ...    AND    Modify Resource Search Order    STATE__Site_reset
    ...    AND    STATE__Site_reset.TC Setup
    TC__STATE__Site_reset
    [Teardown]    Run Keywords    STATE__Site_reset.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  Run Keyword  CIT Recover Test Line By Power Reset


[1]Automated__STATE__SBTS_block_unblock
    [Timeout]    14400 
    [Setup]    Run Keywords
    ...    Set Test Variable    ${CUSTOM_BLOCKED_BTS_DISTNAME}    
    ...    AND    Set Test Variable    ${CELLS_TIMEOUT_BEFORE_BLOCK}    301
    ...    AND    Set Test Variable    ${CELLS_TIMEOUT_AFTER_BLOCK}    301
    ...    AND    Set Test Variable    ${CELLS_TIMEOUT_AFTER_UNBLOCK}    1200

    ...    AND    Set Test Variable    ${bts_host}    192.168.255.129
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    False
    ...    AND    Set Test Variable    ${ADDITIONAL_IGNORED_ALARMS}    
    ...    [['faultId', '4655', ' alarmId ', '7220'], ['faultId', '4654', 'alarmId', '7220']]
    
    ...    AND    Modify Resource Search Order    STATE__sbts_block_unblock
    ...    AND    STATE__sbts_block_unblock.TC Setup
    TC__STATE__SBTS_block_unblock
    [Teardown]    Run Keywords    STATE__sbts_block_unblock.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  Run Keyword  CIT Recover Test Line By Power Reset


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
    ...    AND    Set Test Variable    ${WBTS_NUMBER}    10228
    ...    AND    Set Test Variable    ${WCELL_NUMBER}    32280
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


[1]Automated__STATE__GSM_BCF_lock_unlock_from_BSC
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    10
    ...    AND    Set Test Variable    ${ADDITIONAL_IGNORED_ALARMS}    
    ...    [['faultId', '4655', ' alarmId ', '7220'], ['faultId', '4654', 'alarmId', '7220']]
    
    ...    AND    Modify Resource Search Order    STATE__GSM_BCF_lock_unlock_from_BSC
    ...    AND    STATE__GSM_BCF_lock_unlock_from_BSC.TC Setup
    TC__STATE__GSM_BCF_lock_unlock_from_BSC
    [Teardown]    Run Keywords    STATE__GSM_BCF_lock_unlock_from_BSC.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  Run Keyword  CIT Recover Test Line By Power Reset


[1]Automated__STATE__GSM_BCF_reset_from_BSC
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${ADDITIONAL_IGNORED_ALARMS}    
    ...    [['faultId', '4655', ' alarmId ', '7220'], ['faultId', '4654', 'alarmId', '7220']]
    ...    AND    Modify Resource Search Order    STATE__GSM_BCF_reset_from_BSC
    ...    AND    STATE__GSM_BCF_reset_from_BSC.TC Setup
    TC__STATE__GSM_BCF_reset_from_BSC
    [Teardown]    Run Keywords    STATE__GSM_BCF_reset_from_BSC.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  Run Keyword  CIT Recover Test Line By Power Reset


[1]Automated__STATE__GSM_BTS_lock_unlock_from_BSC
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${BCF_SECTOR_TO_LOCK}    
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    5
    ...    AND    Set Test Variable    ${ADDITIONAL_IGNORED_ALARMS}    
    ...    [['faultId', '4655', ' alarmId ', '7220'], ['faultId', '4654', 'alarmId', '7220']]
    
    ...    AND    Modify Resource Search Order    STATE__GSM_BTS_lock_unlock_from_BSC
    ...    AND    STATE__GSM_BTS_lock_unlock_from_BSC.TC Setup
    TC__STATE__GSM_BTS_lock_unlock_from_BSC
    [Teardown]    Run Keywords    STATE__GSM_BTS_lock_unlock_from_BSC.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  Run Keyword  CIT Recover Test Line By Power Reset


[1]Automated__STATE__GSM_TRX_block_unblock_from_ADMIN
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    60
    ...    AND    Set Test Variable    ${GSM_BTS_ID}    2283
    ...    AND    Set Test Variable    ${CHANNEL_GROUP_ID}    ${None}
    ...    AND    Set Test Variable    ${TRX_LOCK_TIMEOUT}    20
    ...    AND    Set Test Variable    ${ADDITIONAL_IGNORED_ALARMS}    
    ...    [['faultId', '4655', ' alarmId ', '7220'], ['faultId', '4654', 'alarmId', '7220']]
    
    ...    AND    Modify Resource Search Order    STATE__GSM_TRX_block_unblock_from_ADMIN
    ...    AND    STATE__GSM_TRX_block_unblock_from_ADMIN.TC Setup
    TC__STATE__GSM_TRX_block_unblock_from_ADMIN
    [Teardown]    Run Keywords    STATE__GSM_TRX_block_unblock_from_ADMIN.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  Run Keyword  CIT Recover Test Line By Power Reset


[1]Automated__STATE__GSM_TRX_lock_unlock_from_BSC
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${TRX_ID}    
    ...    AND    Set Test Variable    ${BTS_ID}    
    ...    AND    Set Test Variable    ${ADDITIONAL_IGNORED_ALARMS}    
    ...    [['faultId', '4655', ' alarmId ', '7220'], ['faultId', '4654', 'alarmId', '7220']]
    
    ...    AND    Modify Resource Search Order    STATE__GSM_TRX_lock_unlock_from_BSC
    ...    AND    STATE__GSM_TRX_lock_unlock_from_BSC.TC Setup
    TC__STATE__GSM_TRX_lock_unlock_from_BSC
    [Teardown]    Run Keywords    STATE__GSM_TRX_lock_unlock_from_BSC.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  Run Keyword  CIT Recover Test Line By Power Reset


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
    ...    AND    Set Test Variable    ${CELL_ID}    15115
    ...    AND    Set Test Variable    ${ADDITIONAL_IGNORED_ALARMS}    
    ...    [['faultId', '4655', ' alarmId ', '7220'], ['faultId', '4654', 'alarmId', '7220']]
    
    ...    AND    Modify Resource Search Order    STATE__LTE_cell_lock_unlock_from_ADMIN
    ...    AND    STATE__LTE_cell_lock_unlock_from_ADMIN.TC Setup
    TC__STATE__LTE_cell_lock_unlock_from_ADMIN
    [Teardown]    Run Keywords    STATE__LTE_cell_lock_unlock_from_ADMIN.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  Run Keyword  CIT Recover Test Line By Power Reset



[1]Automated__SWM__Local_Software_Download
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${Target SW name}    ${None}
    ...    AND    Set Test Variable    ${Target SW dir}    /home/ute/TARGET_SW_T1
    ...    AND    Set Test Variable    ${SW Download Timeout}    3600
    ...    AND    Set Test Variable    ${ADDITIONAL_IGNORED_ALARMS}    
    ...    [['faultId', '4655', ' alarmId ', '7220'], ['faultId', '4654', 'alarmId', '7220']]
    ...    AND    Modify Resource Search Order    SWM__Local_Software_Download
    ...    AND    SWM__Local_Software_Download.TC Setup
    ${cat_command_1}  Catenate  cat ../testline_init_results/node1/logs/INFO_log.txt | grep BTSSM-based |
    ...  tail -1 | awk -F 'from ' '{print $2}' | awk -F '.zip' '{print $1}'
    ${cat_command_2}  Catenate  cat ../testline_init_results/logs/INFO_log.txt | grep BTSSM-based |
    ...  tail -1 | awk -F 'from ' '{print $2}' | awk -F '.zip' '{print $1}'
    ${package}=  Run Keyword If  ${SMOD2_exists}  run  ${cat_command_1}
    ...  ELSE   run   ${cat_command_2}
    Log to console  Download SW packages ${package}_testpackage_T1.zip
    run  mkdir ${Target SW dir}
    run  sudo chmod 777 ${Target SW dir} -R
    run  wget files.ute.nsn-rdnet.net/builds/enb/base/${ENB_BUILD}/${ENB_BUILD}_release_BTSSM_downloadable_testpackage_T1.zip -P ${Target SW dir}
    TC__SWM__Local_Software_Download
    [Teardown]    Run Keywords    SWM__Local_Software_Download.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  Run Keyword  CIT Recover Test Line By Power Reset


[1]Automated__SWM__Local_Software_Activation
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${Target SW name}    ${None}
    ...    AND    Set Test Variable    ${Target SW dir}    /home/ute/TARGET_SW_T1
    ...    AND    Set Test Variable    ${SW Activation Timeout}    7200
    ...    AND    Set Test Variable    ${Ping loss timeout}    800
    ...    AND    Set Test Variable    ${Ping regain timeout}    800
    ...    AND    Set Test Variable    ${Ping stable timeout}    800
    ...    AND    Set Test Variable    ${BTS_OnAir_Timeout}    120
    ...    AND    Set Test Variable    ${Test_Timeout}    120
    ...    AND    Set Test Variable    ${ADDITIONAL_IGNORED_ALARMS}    
    ...    [['faultId', '4655', ' alarmId ', '7220'], ['faultId', '4654', 'alarmId', '7220']]
    
    ...    AND    Modify Resource Search Order    SWM__Local_Software_Activation
    ...    AND    SWM__Local_Software_Activation.TC Setup

    TC__SWM__Local_Software_Activation
    [Teardown]    Run Keywords    SWM__Local_Software_Activation.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  Run Keyword  CIT Recover Test Line By Power Reset



[1]Automated__SWM__SW_update_for_RMOD_with_fault_23
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${Target SW name}    ${None}
    ...    AND    Set Test Variable    ${Target SW dir}    /home/ute/TARGET_SW
    ...    AND    Set Test Variable    ${SW Update Timeout}    3600
    ...    AND    Set Test Variable    ${Ping loss timeout}    240
    ...    AND    Set Test Variable    ${Ping regain timeout}    600
    ...    AND    Set Test Variable    ${Test Timeout}    90
    ...    AND    Set Test Variable    ${EXPECTED_BTS_STATUS}    OnAir
    ...    AND    Set Test Variable    ${onAir Check Number}    60
    ...    AND    Set Test Variable    ${RM_DETECTION_TIMEOUT}    15 min
    ...    AND    Set Test Variable    ${HW_OFF_ID_LIST}    RMOD_F7164834697
    ...    AND    Set Test Variable    ${NUMBER_OF_RMODS_TO_TURN_OFF}    1
    ...    AND    Set Test Variable    ${ADDITIONAL_IGNORED_ALARMS}    
    ...    [['faultId', '4655', ' alarmId ', '7220'], ['faultId', '4654', 'alarmId', '7220']]
    ...    AND    Modify Resource Search Order    SWM__SW_update_for_RMOD_with_fault_23
    ...    AND    SWM__SW_update_for_RMOD_with_fault_23.TC Setup
    Run  mkdir ${Target SW dir}
    Run  sudo chmod 777 ${Target SW dir} -R
    Run  wget files.ute.nsn-rdnet.net/builds/enb/base/${ENB_BUILD}/${ENB_BUILD}_release_BTSSM_downloadable.zip -P ${Target SW dir}
    
    TC__SWM__SW_update_for_RMOD_with_fault_23
    [Teardown]    Run Keywords    SWM__SW_update_for_RMOD_with_fault_23.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  Run Keyword  CIT Recover Test Line By Power Reset




[1]Automated__SWM__SBTS_SOAM_rollback_to_SBTS_SOAM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${PASSIVE_SW_STATE}    commissioned
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    30m
    ...    AND    Set Test Variable    ${CONNECTION_RESET_ON_DEMAND}    ${FALSE}
    ...    AND    Set Test Variable    ${PING_LOSS_TIMEOUT}    600
    ...    AND    Set Test Variable    ${PING_REGAIN_TIMEOUT}    600
    ...    AND    Set Test Variable    ${ADDITIONAL_IGNORED_ALARMS}    
    ...    [['faultId', '4655', ' alarmId ', '7220'], ['faultId', '4654', 'alarmId', '7220']]
    
    ...    AND    Modify Resource Search Order    SWM__SBTS_SOAM_rollback_to_SBTS_SOAM
    ...    AND    SWM__SBTS_SOAM_rollback_to_SBTS_SOAM.TC Setup
    TC__SWM__SBTS_SOAM_rollback_to_SBTS_SOAM
    [Teardown]    Run Keywords    SWM__SBTS_SOAM_rollback_to_SBTS_SOAM.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  Run Keyword  CIT Recover Test Line By Power Reset



[1]Automated__SWM__Local_Software_Download_Cancel
    [Timeout]    14400
   [Setup]    Run Keywords    Set Test Variable    ${Target SW name}    ${None}
    ...    AND    Set Test Variable    ${Target SW dir}    /home/ute/TARGET_SW_T2
    ...    AND    Set Test Variable    ${SLEEP_BEFORE_CANCEL}    90
    ...    AND    Set Test Variable    ${DOWNLOAD_TIMEOUT}    600
    ...    AND    Set Test Variable    ${RM_DETECTION_TIMEOUT}    15 min
    ...    AND    Set Test Variable    ${ADDITIONAL_IGNORED_ALARMS}    
    ...    [['faultId', '4655', ' alarmId ', '7220'], ['faultId', '4654', 'alarmId', '7220']]
    
    ...    AND    Modify Resource Search Order    SWM__Local_Software_Download_Cancel
    ...    AND    SWM__Local_Software_Download_Cancel.TC Setup
    Run  mkdir ${Target SW dir}
    Run  sudo chmod 777 ${Target SW dir} -R
    Run  wget files.ute.nsn-rdnet.net/builds/enb/base/${ENB_BUILD}/${ENB_BUILD}_release_BTSSM_downloadable_testpackage_T2.zip -P ${Target SW dir}
    
    TC__SWM__Local_Software_Download_Cancel
    [Teardown]    Run Keywords    SWM__Local_Software_Download_Cancel.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  Run Keyword  CIT Recover Test Line By Power Reset



[1]Automated__BS-SM__GSM_RAT_reset_from_ADMIN
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${GSM_RAT_RESET_TIMEOUT}    600
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    False
    
    ...    AND    BS-SM__GSM_RAT_reset_from_ADMIN.TC Setup
    ...    AND    Modify Resource Search Order    BS-SM__GSM_RAT_reset_from_ADMIN
    TC__BS-SM__GSM_RAT_reset_from_ADMIN
    [Teardown]    Run Keywords    BS-SM__GSM_RAT_reset_from_ADMIN.TC Teardown
    ...    AND    Restore Resource Search Order


[1]KPI__BBMOD_Reset_From_WebEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    False
    ...    AND    Set Test Variable    ${BBMOD_SERIAL_NUMBER}    L1162601207 
    ...    AND    Set Test Variable    ${RESET_TIMEOUT}    180
    ...    AND    Set Test Variable    ${RESET_TYPE}    Warm
    
    ...    AND    KPI__BBMOD_Reset_From_WebEM.TC Setup
    ...    AND    Modify Resource Search Order    KPI__BBMOD_Reset_From_WebEM
    TC__KPI__BBMOD_Reset_From_WebEM
    [Teardown]    Run Keywords    KPI__BBMOD_Reset_From_WebEM.TC Teardown
    ...    AND    Restore Resource Search Order
