*** Settings ***
Force Tags  QCD_MN_RAN  QCP_RAN_ST  SRAN  CLOUD_SRAN_LWG_1ASIA_3ABIA_2AHEB_1AHED_3AHEGA  STATE_COMMISSIONED
Library           XML  use_lxml=True
Resource    ../../CIT/test_resources/BS-RF__CPRI_Chaining_Deactivation_Activation_via_WebEM__RP001099__Automated.robot
Resource    ../../CIT/test_resources/BS-RF__Embedded_Power_Meter_EEM_act_deact_in_WebEM__RP000951__Automated.robot
Resource    ../../CIT/test_resources/CM_CABLE_SPEED_CHANGE.robot
Resource    ../../CIT/test_resources/CM__Commissioning__Configuration_reset.robot
Resource    ../../CIT/test_resources/CM__Commissioning__Planned_commissioning.robot
Resource    ../../CIT/test_resources/CM__Recommissioning_with_BTS_reset.robot
Resource    ../../CIT/test_resources/CM__Recommissioning_delta_commissioning_with_reset.robot
Resource    ../../CIT/test_resources/CM__Recommissioning_delta_commissioning_without_reset.robot
Resource    ../../FM/test_resources/FM__RF_hot_remove_hot_insert.robot
Resource    ../../FM/test_resources/FM__Recovery_whole_multiple_Link_Break.robot
Resource    ../../CIT/test_resources/LOGS__Memory_dump_files_creation_in_case_of_DSP_crash.robot
Resource    ../../CIT/test_resources/LOGS__Snapshot.robot
Resource    ../../CIT/test_resources/PM__LTE_counters_are_available_on_ram_disk_versus_NIDD_counter_list.robot
Resource    ../../CIT/test_resources/PM__TNL_counters_are_available_on_ram_disk_versus_NIDD_counter_list.robot
Resource    ../../CIT/test_resources/PM__WBTS_counters_are_available_on_ram_disk_versus_NIDD_counter_list.robot
Resource    ../../CIT/test_resources/STATE__GSM_BCF_lock_unlock_from_BSC.robot
Resource    ../../CIT/test_resources/STATE__GSM_BCF_reset_from_BSC.robot
Resource    ../../CIT/test_resources/STATE__GSM_BTS_lock_unlock_from_BSC.robot
Resource    ../../CIT/test_resources/STATE__GSM_TRX_block_unblock_from_ADMIN.robot
Resource    ../../CIT/test_resources/STATE__GSM_TRX_lock_unlock_from_BSC.robot
Resource    ../../CIT/test_resources/STATE__LTE_RAT_reset__parameter_change__ADMIN.robot
Resource    ../../CIT/test_resources/STATE__LTE_RAT_reset_from_ADMIN.robot
Resource    ../../CIT/test_resources/STATE__LTE_S1_Lock_Unlock.robot
Resource    ../../CIT/test_resources/STATE__LTE_cell_block_unblock_from_ADMIN.robot
Resource    ../../CIT/test_resources/STATE__LTE_cell_lock_unlock_from_ADMIN.robot
Resource    ../../CIT/test_resources/STATE__RF_Module_block_unblock.robot
Resource    ../../CIT/test_resources/STATE__Radio_module_reset_from_admin.robot
Resource    ../../CIT/test_resources/STATE__S1_lock_reset_unlock.robot
Resource    ../../CIT/test_resources/STATE__Site_power_reset.robot
Resource    ../../CIT/test_resources/STATE__Site_reset.robot
Resource    ../../CIT/test_resources/STATE__WCDMA_RAT_reset__parameter_change__ADMIN.robot
Resource    ../../CIT/test_resources/STATE__WCDMA_RAT_reset_from_ADMIN.robot
Resource    ../../CIT/test_resources/STATE__WCDMA_cell_block_unblock.robot
Resource    ../../CIT/test_resources/STATE__WCDMA_cell_lock_unlock_from_RNC.robot
Resource    ../../CIT/test_resources/STATE__sbts_block_unblock.robot
Resource    ../../CIT/test_resources/SWM__Local_Software_Activation.robot
Resource    ../../CIT/test_resources/SWM__Local_Software_Download.robot
Resource    ../../CIT/test_resources/SWM__Local_Software_Download_Cancel.robot
Resource    ../../CIT/test_resources/SWM__SBTS_SOAM_rollback_to_SBTS_SOAM.robot
Resource    ../../CIT/test_resources/SWM__SCF_validation_errors_check.robot
Resource    ../../CIT/test_resources/SWM__SW_download_and_activation__SBTS_to_SBTS.robot
Resource    ../../CIT/test_resources/SWM__SW_download_and_activation__SBTS_to_SBTS_uncommissioned.robot
Resource    ../../CIT/test_resources/SWM__SW_update_for_new_RF_unit_uncommissioned.robot
Resource    ../../CIT/test_resources/SWM__Upload_swconfig.robot
Resource    ../../CIT/test_resources/CIT_Test_Line_Recovery.robot


Suite Setup   Run keywords
...  Set Library Search Order  coam   ute_admin   hran_frame_sbts_taf   hran_frame_sbts_siso   ca_CIT_general   ca_swm_general
...  AND  Map BuildShareTimi01 and move counters folder in test line specific

*** Variables ***
${SCF_ID}    01
${HW_LOCATION_CODE}      Timisoara
${SBTS_SW_tested}    SBTS00_ENB_9999_211012_000007
${REQUEST_SCF_SCOUT}    ${TRUE}
${SCOUT_TL_NAME}    10_18_UTESRANCLOUD1441
${COMMISSIONING_PATH}    /home/ute/testline_configuration/10_18_UTESRANCLOUD1441/node1/BTS_CLOUD_SRAN_LWG_1ASIA_3ABIA_2AHEB_1AHED_3AHEGA_SBTS00.xml


*** Test Cases ***

    
[1]Automated__SWM__SW_download_and_activation__SBTS_to_SBTS
    [Tags]    STOPONFAIL
    [Setup]    Run Keywords    Set Test Variable    ${COMMISSIONING_PATH}
    ...    /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS1441/commissioning/SCF_01_TRUNK.xml
    ...    AND    Set Test Variable    ${Target SW name}    ${None}
    ...    AND    Set Test Variable    ${Target SW dir}    /home/ute/TARGET_SW
    ...    AND    Set Test Variable    ${SW Update Timeout}    3600
    ...    AND    Set Test Variable    ${Ping loss timeout}    900
    ...    AND    Set Test Variable    ${Ping regain timeout}    1900
    ...    AND    Set Test Variable    ${onAir Check Number}    150
    ...    AND    Set Test Variable    ${First Cell On Air Timeout}    35
    ...    AND    Set Test Variable    ${Test Timeout}    120
    ...    AND    Modify Resource Search Order    SWM__SW_download_and_activation__SBTS_to_SBTS
    ...    AND    SWM__SW_download_and_activation__SBTS_to_SBTS.TC Setup

    Run  mkdir ${Target SW dir}
    Run  sudo chmod 777 ${Target SW dir} -R
    Download and check software package  ${ENB_BUILD}  ${Target SW dir}
    
    TC__SWM__SW_download_and_activation__SBTS_to_SBTS
    [Teardown]    Run Keywords    SWM__SW_download_and_activation__SBTS_to_SBTS.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__SWM__SCF_validation_errors_check
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${SKIP_PARAM_RELATION_ERRORS}    ${TRUE}
    
    ...    AND    Modify Resource Search Order    SWM__SCF_validation_errors_check
    ...    AND    SWM__SCF_validation_errors_check.TC Setup
    TC__SWM__SCF_validation_errors_check
    [Teardown]    Run Keywords    SWM__SCF_validation_errors_check.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  Run Keyword  CIT Recover Test Line By Power Reset


[1]Automated__CM__Commissioning__Configuration_reset
    [Timeout]    20000
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${Configuration Reset Timeout}    1200
    ...    AND    Set Test Variable    ${Conf_reset_by_AdminAPI}    ${TRUE}
    ...    AND    Set Test Variable    ${RM_DETECTION_TIMEOUT}    35 min
    ...    AND    Set Test Variable    ${SMOD2_CHECK_TIMEOUT}    25 min
    
    ...    AND    Modify Resource Search Order    CM__Commissioning__Configuration_reset
    ...    AND    CM__Commissioning__Configuration_reset.TC Setup
    TC__CM__Commissioning__Configuration_reset
    [Teardown]    Run Keywords    CM__Commissioning__Configuration_reset.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  Run Keyword  CIT Recover Test Line By Power Reset


[1]Automated__CM__Commissioning_planned_commissioning
    [Timeout]    20000
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${COMMISSIONING_PATH}    
    ...    AND    Set Test Variable    ${SKIP_PARAM_RELATION_ERRORS}    ${TRUE}
    ...    AND    Set Test Variable    ${COMMISSIONING_TIMEOUT}    1200
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    20
    ...    AND    Set Test Variable    ${IPSEC_INSTALL}    ${FALSE}
    ...    AND    Set Test Variable    ${POST_CHECK_ONLY_ALARMS}    ${FALSE}
    ...    AND    Set Test Variable    ${POST_ALARMS_IGNORED_PATTERN}    ${EMPTY}
    ...    AND    Set Test Variable    ${ALT_SCF_PATH}    ${EMPTY}
    
    ...    AND    Modify Resource Search Order    CM__Commissioning__Planned_commissioning
    ...    AND    CM__Commissioning__Planned_commissioning.TC Setup
    TC__CM__Commissioning__Planned_commissioning
    [Teardown]    Run Keywords    CM__Commissioning__Planned_commissioning.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  Run Keyword  CIT Recover Test Line By Power Reset



[1]Automated__STATE__Site_reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    60
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    False
    
    ...    AND    Modify Resource Search Order    STATE__Site_reset
    ...    AND    STATE__Site_reset.TC Setup
    TC__STATE__Site_reset
    [Teardown]    Run Keywords    STATE__Site_reset.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  Run Keyword  CIT Recover Test Line By Power Reset

[1]Automated__FM__RF_hot_remove_hot_insert
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_SN}    ${EMPTY}
    ...    AND    Set Test Variable    ${PING_RMOD_TIMEOUT}    720
    ...    AND    Set Test Variable    ${CELLS_ONLINE_TIMEOUT}    720
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_ID}    10
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_NAME}    No connection to unit
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_ID}    7116
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_NAME}    BASE STATION SERVICE PROBLEM
    ...    AND    Set Test Variable    ${SEVERITY}    Critical
    ...    AND    Set Test Variable    ${CHECK_NA_ALARM}    False
    ...    AND    Modify Resource Search Order    FM__RF_hot_remove_hot_insert
    ...    AND    FM__RF_hot_remove_hot_insert.TC Setup
    TC__FM__RF_hot_remove_hot_insert
    [Teardown]    Run Keywords    FM__RF_hot_remove_hot_insert.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  Run Keyword  CIT Recover Test Line By Power Reset

[1]Automated__CM__Recommissioning_with_BTS_reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${PARAMETER_SCF_DIST_NAME}    MRBTS-10441/MNL-1/MNLENT-1/SYNC-1/TIME-1
    ...    AND    Set Test Variable    ${PARAMETER_IM_DIST_NAME}    //TIME_A-1
    ...    AND    Set Test Variable    ${PARAMETER_ABBREVIATION}    timeZone
    ...    AND    Set Test Variable    ${PARAMETER_OPERATION}    update
    ...    AND    Set Test Variable    ${PARAMETER_VALUE}    (GMT+1) Europe/Vienna
    ...    AND    Set Test Variable    ${SKIP_PARAM_RELATION_ERRORS}    ${TRUE}
    ...    AND    Set Test Variable    ${RECOMMISSIONING_TIMEOUT}    600
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
    ...    /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS1441/json/name_delta.json
    ...    AND    Set Test Variable    ${SKIP_PARAM_RELATION_ERRORS}    ${TRUE}
    ...    AND    Set Test Variable    ${RECOMMISSIONING_TIMEOUT}    900
    
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
    ...    /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS1441/json/time_zone_delta.json
    ...    AND    Set Test Variable    ${SKIP_PARAM_RELATION_ERRORS}    ${TRUE}
    ...    AND    Set Test Variable    ${RECOMMISSIONING_TIMEOUT}    601
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    25
    
    ...    AND    Modify Resource Search Order    CM__Recommissioning_delta_commissioning_with_reset
    ...    AND    CM__Recommissioning_delta_commissioning_with_reset.TC Setup
    TC__CM__Recommissioning_delta_commissioning_with_reset
    [Teardown]    Run Keywords    CM__Recommissioning_delta_commissioning_with_reset.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  Run Keyword  CIT Recover Test Line By Power Reset


[1]Automated__STATE__SBTS_block_unblock
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${CUSTOM_BLOCKED_BTS_DISTNAME}    
    ...    AND    Set Test Variable    ${CELLS_TIMEOUT_BEFORE_BLOCK}    300
    ...    AND    Set Test Variable    ${CELLS_TIMEOUT_AFTER_BLOCK}    300
    ...    AND    Set Test Variable    ${CELLS_TIMEOUT_AFTER_UNBLOCK}    1200
    ...    AND    Set Test Variable    ${bts_host}    192.168.255.129
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    False
    
    ...    AND    Modify Resource Search Order    STATE__SBTS_block_unblock
    ...    AND    STATE__sbts_block_unblock.TC Setup
    TC__STATE__SBTS_block_unblock
    [Teardown]    Run Keywords    STATE__sbts_block_unblock.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  Run Keyword  CIT Recover Test Line By Power Reset


[1]Automated__STATE__Radio_module_reset_from_Admin
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_SERIAL_NUMBER}    
    ...    AND    Set Test Variable    ${RESET_TIMEOUT}    3600
    ...    AND    Set Test Variable    ${RESETTYPE}    Warm
    ...    AND    Set Test Variable    ${BCF_VERIFICATION_TIMEOUT}    5 minutes
    
    ...    AND    Modify Resource Search Order    STATE__Radio_module_reset_from_admin
    ...    AND    STATE__Radio_module_reset_from_admin.TC Setup
    TC__STATE__Radio_module_reset_from_admin
    [Teardown]    Run Keywords    STATE__Radio_module_reset_from_admin.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  Run Keyword  CIT Recover Test Line By Power Reset


[1]Automated__STATE__LTE_RAT_reset_from_ADMIN
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${LTE_RAT_RESET_TIMEOUT}    3600
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    False
    
    ...    AND    Modify Resource Search Order    STATE__LTE_RAT_reset_from_ADMIN
    ...    AND    STATE__LTE_RAT_reset_from_ADMIN.TC Setup
    TC__STATE__LTE_RAT_reset_from_ADMIN
    [Teardown]    Run Keywords    STATE__LTE_RAT_reset_from_ADMIN.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  Run Keyword  CIT Recover Test Line By Power Reset


[1]Automated__STATE__WCDMA_RAT_reset_from_ADMIN
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${WCDMA_RAT_RESET_TIMEOUT}    180
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    False
    ...    AND    Modify Resource Search Order    STATE__WCDMA_RAT_reset_from_ADMIN
    ...    AND    STATE__WCDMA_RAT_reset_from_ADMIN.TC Setup
    TC__STATE__WCDMA_RAT_reset_from_ADMIN
    [Teardown]    Run Keywords    STATE__WCDMA_RAT_reset_from_ADMIN.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  Run Keyword  CIT Recover Test Line By Power Reset


[1]Automated__STATE__WCDMA_cell_block_unblock
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${CELL_ID}    ${EMPTY}
    
    ...    AND    Modify Resource Search Order    STATE__WCDMA_cell_block_unblock
    ...    AND    STATE__WCDMA_cell_block_unblock.TC Setup
    TC__STATE__WCDMA_cell_block_unblock
    [Teardown]    Run Keywords    STATE__WCDMA_cell_block_unblock.TC Teardown
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
    
    ...    AND    Modify Resource Search Order    STATE__LTE_S1_Lock_Unlock
    ...    AND    STATE__LTE_S1_Lock_Unlock.TC Setup
    TC__STATE__LTE_S1_Lock_Unlock
    [Teardown]    Run Keywords    STATE__LTE_S1_Lock_Unlock.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  Run Keyword  CIT Recover Test Line By Power Reset


[1]Automated__STATE__LTE_RAT_reset__parameter_change__ADMIN
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${PARAMETER_SCF_DIST_NAME}    MRBTS-10441/LNBTS-10441
    ...    AND    Set Test Variable    ${PARAMETER_ABBREVIATION}    cPlaneDscp
    ...    AND    Set Test Variable    ${PARAMETER_VALUE}    47
    ...    AND    Set Test Variable    ${SKIP_PARAM_RELATION_ERRORS}    ${TRUE}
    ...    AND    Set Test Variable    ${RECOMMISSIONING_TIMEOUT}    600
    ...    AND    Set Test Variable    ${LTE_OPERATIONAL_TIMEOUT}    360
    
    ...    AND    Modify Resource Search Order    STATE__LTE_RAT_reset__parameter_change__ADMIN
    ...    AND    STATE__LTE_RAT_reset__parameter_change__ADMIN.TC Setup
    TC__STATE__LTE_RAT_reset__parameter_change__ADMIN
    [Teardown]    Run Keywords    STATE__LTE_RAT_reset__parameter_change__ADMIN.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  Run Keyword  CIT Recover Test Line By Power Reset


[1]Automated__STATE__WCDMA_RAT_reset__parameter_change__ADMIN
    [Timeout]    20000
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${PARAMETER_SCF_DIST_NAME}    MRBTS-10441/WNBTS-1
    ...    AND    Set Test Variable    ${PARAMETER_ABBREVIATION}    midIubDelayThreshold
    ...    AND    Set Test Variable    ${PARAMETER_VALUE}    160
    ...    AND    Set Test Variable    ${SKIP_PARAM_RELATION_ERRORS}    ${TRUE}
    ...    AND    Set Test Variable    ${RECOMMISSIONING_TIMEOUT}    600
    ...    AND    Set Test Variable    ${WCDMA_OPERATIONAL_TIMEOUT}    600
    
    ...    AND    Modify Resource Search Order    STATE__WCDMA_RAT_reset__parameter_change__ADMIN
    ...    AND    STATE__WCDMA_RAT_reset__parameter_change__ADMIN.TC Setup
    TC__STATE__WCDMA_RAT_reset__parameter_change__ADMIN
    [Teardown]    Run Keywords    STATE__WCDMA_RAT_reset__parameter_change__ADMIN.TC Teardown
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
    ...    AND    Set Test Variable    ${LOG_TX_POWER}    False
    
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
    ...    AND    Set Test Variable    ${CELL_ID}    44411
    ...    AND    Modify Resource Search Order    STATE__LTE_cell_lock_unlock_from_ADMIN
    ...    AND    STATE__LTE_cell_lock_unlock_from_ADMIN.TC Setup
    TC__STATE__LTE_cell_lock_unlock_from_ADMIN
    [Teardown]    Run Keywords    STATE__LTE_cell_lock_unlock_from_ADMIN.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  Run Keyword  CIT Recover Test Line By Power Reset


[1]Automated__STATE__GSM_TRX_block_unblock_from_ADMIN
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    60
    ...    AND    Set Test Variable    ${GSM_BTS_ID}    4000
    ...    AND    Set Test Variable    ${CHANNEL_GROUP_ID}    1
    ...    AND    Set Test Variable    ${TRX_LOCK_TIMEOUT}    30
    
    ...    AND    Modify Resource Search Order    STATE__GSM_TRX_block_unblock_from_ADMIN
    ...    AND    STATE__GSM_TRX_block_unblock_from_ADMIN.TC Setup
    TC__STATE__GSM_TRX_block_unblock_from_ADMIN
    [Teardown]    Run Keywords    STATE__GSM_TRX_block_unblock_from_ADMIN.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  Run Keyword  CIT Recover Test Line By Power Reset


[1][1.0] [3.2]Automated__LOGS__Memory_dump_files_creation_in_case_of_DSP_crash
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${DSP_ID}    ${Empty}
    ...    AND    Set Test Variable    ${SITE_RESET}    False
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    60
    ...    AND    Set Test Variable    ${FAULT_TIMEOUT}    15
    ...    AND    Set Test Variable    ${CHECK_FILES_ON_SBTS}    False
    ...    AND    Set Test Variable    ${SNAPSHOT_COLLECTION_TIMEOUT}    3600s
    ...    AND    Set Test Variable    ${VERIFICATION_TIMEOUT}    60
    ...    AND    Set Test Variable    ${MEMDUMP_PATTERN}    (\\d{4})\\w+MEMDUMP\\.bin\\.xz$
    ...    AND    Set Test Variable    ${DSP_MEMDUMPER_PATTERN}    memdumper_{}.+\\.log\\.xz$
    ...    AND    Set Test Variable    ${MEM_DUMPS_PATH}    /ffs/run/logs/dspdumps/5/A
    ...    AND    Set Test Variable    ${DSP_RUNTIME_PATTERN}    [1-2]011_crash_{}00_RT\\.log\\.zip$
    ...    AND    Set Test Variable    ${DSP_MEMDUMP_PATTERN}    {}00\\w+MEMDUMP\\.bin.*
    ...    AND    Set Test Variable    ${SRIO_DIO_INTERFACE_PATERN}    riomemfs-logdump
    
    ...    AND    Modify Resource Search Order    LOGS__Memory_dump_files_creation_in_case_of_DSP_crash
    ...    AND    LOGS__Memory_dump_files_creation_in_case_of_DSP_crash.TC Setup
    TC__LOGS__Memory_dump_files_creation_in_case_of_DSP_crash
    [Teardown]    Run Keywords    LOGS__Memory_dump_files_creation_in_case_of_DSP_crash.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  Run Keyword  CIT Recover Test Line By Power Reset


[1]Automated__FM__Recovery_whole_multiple_Link_Break
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${NUMBER_OF_LOOPS}    6
    ...    AND    Set Test Variable    ${TIMEOUT_AFTER_RESTOR}    3600
    ...    AND    Modify Resource Search Order    FM__Recovery_whole_multiple_Link_Break
    ...    AND    FM__Recovery_whole_multiple_Link_Break.TC Setup
    TC__FM__Recovery_whole_multiple_Link_Break
    [Teardown]    Run Keywords    FM__Recovery_whole_multiple_Link_Break.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  Run Keyword  CIT Recover Test Line By Power Reset


[1]Automated__BS-RF__Embedded_Power_Meter_EEM_act_deact_in_WebEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${INTERVAL}    15
    ...    AND    Set Test Variable    ${RMODS}    6
    
    ...    AND    Modify Resource Search Order    BS-RF__Embedded_Power_Meter_EEM_act_deact_in_WebEM__RP000951__Automated
    ...    AND    BS-RF__Embedded_Power_Meter_EEM_act_deact_in_WebEM__RP000951__Automated.TC Setup
    TC__BS-RF__Embedded_Power_Meter_EEM_act_deact_in_WebEM__RP000951__Automated
    [Teardown]    Run Keywords    BS-RF__Embedded_Power_Meter_EEM_act_deact_in_WebEM__RP000951__Automated.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  Run Keyword  CIT Recover Test Line By Power Reset


[1]Automated__BS-RF__CPRI_Chaining_Deactivation_Activation_via_WebEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    
    ...    AND    Modify Resource Search Order    BS-RF__CPRI_Chaining_Deactivation_Activation_via_WebEM__RP001099__Automated
    ...    AND    BS-RF__CPRI_Chaining_Deactivation_Activation_via_WebEM__RP001099__Automated.TC Setup
    TC__BS-RF__CPRI_Chaining_Deactivation_Activation_via_WebEM__RP001099__Automated
    [Teardown]    Run Keywords    BS-RF__CPRI_Chaining_Deactivation_Activation_via_WebEM__RP001099__Automated.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  Run Keyword  CIT Recover Test Line By Power Reset


[1]Automated__PM__LTE_counters_are_available_on_ram_disk_versus_NIDD_counter_list
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${MEASUREMENT_PATH}
    ...    /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS1441/counters/SBTS19A_Counters_2019-07-01_limited.xlsx
    ...    AND    Set Test Variable    ${ABBREVIATION_DICT_PATH}
    ...    /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS1441/counters/LTE_Abbreviations.xlsx
    ...    AND    Set Test Variable    ${TO_FILTRATE_KEYS}    Product_types,Category,Document_state
    ...    AND    Set Test Variable    ${TO_FILTRATE_VALUES}    Flexi_SBTS|Flexi_AirScale,Customer,Published
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    15
    
    ...    AND    Modify Resource Search Order    PM__LTE_counters_are_available_on_ram_disk_versus_NIDD_counter_list
    ...    AND    PM__LTE_counters_are_available_on_ram_disk_versus_NIDD_counter_list.TC Setup
    run  sudo mkdir -p /media/BuildShareTimi01
    run  sudo chown ute:ute /media/BuildShareTimi01
    ${sudo_command}  Catenate  SEPARATOR=
    ...  sudo sh -c "echo //10.5.16.78/BuildShareTimi01 /media/BuildShareTimi01/ cifs _netdev,noperm,username=userbuild,,
    ...  nosuid,noexec,password=Aikon_123456*8 0 0 >>/etc/fstab"
    run  ${sudo_command}
    run  sudo mount -a
    ${cp_command}  Catenate  SEPARATOR=
    ...  cp /media/BuildShareTimi01/SBTS/Trunk/counters_for_CIT_Trunk/10441/* /home/ute/MN/UTE/robotws/testsuite/
    ...  Timisoara/SBTS/test_line_specific/SBTS1441/counters/
    run  ${cp_command}

    TC__PM__LTE_counters_are_available_on_ram_disk_versus_NIDD_counter_list
    [Teardown]    Run Keywords    PM__LTE_counters_are_available_on_ram_disk_versus_NIDD_counter_list.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  Run Keyword  CIT Recover Test Line By Power Reset


[1]Automated__PM__TNL_counters_are_available_on_ram_disk_versus_NIDD_counter_list
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${MEASUREMENT_PATH}
    ...    /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS1441/counters/TRS_few_groups.xlsm
    ...    AND    Set Test Variable    ${ABBREVIATION_DICT_PATH}
    ...    /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS1441/counters/TNL_Abbreviations.xlsx
    ...    AND    Set Test Variable    ${TO_FILTRATE_KEYS}    Product_types,Category,Document_state
    ...    AND    Set Test Variable    ${TO_FILTRATE_VALUES}    Flexi_SBTS|Flexi_AirScale,Customer,Published
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    15
    
    ...    AND    Modify Resource Search Order    PM__TNL_counters_are_available_on_ram_disk_versus_NIDD_counter_list
    ...    AND    PM__TNL_counters_are_available_on_ram_disk_versus_NIDD_counter_list.TC Setup

    TC__PM__TNL_counters_are_available_on_ram_disk_versus_NIDD_counter_list
    [Teardown]    Run Keywords    PM__TNL_counters_are_available_on_ram_disk_versus_NIDD_counter_list.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  Run Keyword  CIT Recover Test Line By Power Reset


[1]Automated__PM__WBTS_counters_are_available_on_ram_disk_versus_NIDD_counter_list
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${MEASUREMENT_PATH}
    ...    /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS1441/counters/WCDMA_few_groups.xlsm
    ...    AND    Set Test Variable    ${ABBREVIATION_DICT_PATH}
    ...    /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS1441/counters/WCDMA_Abbreviations.xlsx
    ...    AND    Set Test Variable    ${WCDMA_TRS_COUNTERS}    M51\\d{2}C\\d+
    ...    AND    Set Test Variable    ${TO_FILTRATE_KEYS}    Product_types,Category,Document_state
    ...    AND    Set Test Variable    ${TO_FILTRATE_VALUES}    Flexi_SBTS|Flexi_AirScale,Customer,Published
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    15
    
    ...    AND    Modify Resource Search Order    PM__WBTS_counters_are_available_on_ram_disk_versus_NIDD_counter_list
    ...    AND    PM__WBTS_counters_are_available_on_ram_disk_versus_NIDD_counter_list.TC Setup

    TC__PM__WBTS_counters_are_available_on_ram_disk_versus_NIDD_counter_list
    [Teardown]    Run Keywords    PM__WBTS_counters_are_available_on_ram_disk_versus_NIDD_counter_list.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  Run Keyword  CIT Recover Test Line By Power Reset


[1]Automated__LOGS__Snapshot
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${SNAPSHOT_TIMEOUT}    1200
    
    ...    AND    Modify Resource Search Order    LOGS__Snapshot
    ...    AND    LOGS__Snapshot.TC Setup
    TC__LOGS__Snapshot
    [Teardown]    Run Keywords    LOGS__Snapshot.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  Run Keyword  CIT Recover Test Line By Power Reset


[1]Automated__CM_CABLE_SPEED_CHANGE
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${TIMEOUT}    900
    ...    AND    Modify Resource Search Order    CM_CABLE_SPEED_CHANGE
    ...    AND    CM_CABLE_SPEED_CHANGE.TC Setup
    TC__CM_Cable_Speed_Change
    [Teardown]    Run Keywords    CM_CABLE_SPEED_CHANGE.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  Run Keyword  CIT Recover Test Line By Power Reset


[1]Automated__SWM__Local_Software_Download
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${Target SW name}    ${None}
    ...    AND    Set Test Variable    ${Target SW dir}    /home/ute/TARGET_SW_T2
    ...    AND    Set Test Variable    ${SW Download Timeout}    1200
    ...    AND    Modify Resource Search Order    SWM__Local_Software_Download
    ...    AND    SWM__Local_Software_Download.TC Setup
    ${command}  Catenate  cat ../testline_init_results/node1/logs/INFO_log.txt | grep BTSSM-based | tail -1 |
    ...  awk -F 'from ' '{print $2}' | awk -F '.zip' '{print $1}'
    ${package}=  Run Keyword If  ${SMOD2_exists}
    ...  run   ${command}
	...  ELSE   run
	...  cat ../testline_init_results/logs/INFO_log.txt | grep BTSSM-based | tail -1 | awk -F 'from ' '{print $2}' | awk -F '.zip' '{print $1}'
    Log to console  Download SW packages ${package}_testpackage_T1.zip
    run  mkdir ${Target SW dir}
    run  sudo chmod 777 ${Target SW dir} -R
    
    Download and check software package  ${ENB_BUILD}  ${Target SW dir}  testpackage_T1_A54
    # Run Keyword If  ${SMOD2_exists}  run
#    ...  ssh ute@${PC_IP2} "mkdir ${Target SW dir}; sudo chmod 777 ${Target SW dir} -R; wget ${package}_testpackage_T2.zip -P ${Target SW dir}"
    TC__SWM__Local_Software_Download
    [Teardown]    Run Keywords    SWM__Local_Software_Download.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  Run Keyword  CIT Recover Test Line By Power Reset


[1]Automated__SWM__Local_Software_Activation
    [Timeout]    ${Test_Timeout} minutes
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${Target SW name}    ${None}
    ...    AND    Set Test Variable    ${Target SW dir}    /home/ute/TARGET_SW_T2
    ...    AND    Set Test Variable    ${SW Activation Timeout}    150
    ...    AND    Set Test Variable    ${Ping loss timeout}    420
    ...    AND    Set Test Variable    ${Ping regain timeout}    600
    ...    AND    Set Test Variable    ${BTS_OnAir_Timeout}    15
    ...    AND    Set Test Variable    ${Test_Timeout}    30
    
    ...    AND    Modify Resource Search Order    SWM__Local_Software_Activation
    ...    AND    SWM__Local_Software_Activation.TC Setup
    TC__SWM__Local_Software_Activation
    [Teardown]    Run Keywords    SWM__Local_Software_Activation.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  Run Keyword  CIT Recover Test Line By Power Reset


[1]Automated__STATE__GSM_BCF_reset_from_BSC
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    
    ...    AND    Modify Resource Search Order    STATE__GSM_BCF_reset_from_BSC
    ...    AND    STATE__GSM_BCF_reset_from_BSC.TC Setup
    TC__STATE__GSM_BCF_reset_from_BSC
    [Teardown]    Run Keywords    STATE__GSM_BCF_reset_from_BSC.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  Run Keyword  CIT Recover Test Line By Power Reset


[1]Automated__STATE__GSM_TRX_lock_unlock_from_BSC
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${TRX_ID}    
    ...    AND    Set Test Variable    ${GSM_SECTOR_ID}    
    
    ...    AND    Modify Resource Search Order    STATE__GSM_TRX_lock_unlock_from_BSC
    ...    AND    STATE__GSM_TRX_lock_unlock_from_BSC.TC Setup
    TC__STATE__GSM_TRX_lock_unlock_from_BSC
    [Teardown]    Run Keywords    STATE__GSM_TRX_lock_unlock_from_BSC.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  Run Keyword  CIT Recover Test Line By Power Reset


[1]Automated__STATE__GSM_BCF_lock_unlock_from_BSC
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    10
    
    ...    AND    Modify Resource Search Order    STATE__GSM_BCF_lock_unlock_from_BSC
    ...    AND    STATE__GSM_BCF_lock_unlock_from_BSC.TC Setup
    TC__STATE__GSM_BCF_lock_unlock_from_BSC
    [Teardown]    Run Keywords    STATE__GSM_BCF_lock_unlock_from_BSC.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  Run Keyword  CIT Recover Test Line By Power Reset


[1]Automated__STATE__GSM_BTS_lock_unlock_from_BSC
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${BCF_SECTOR_TO_LOCK}    
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    5
    
    ...    AND    Modify Resource Search Order    STATE__GSM_BTS_lock_unlock_from_BSC
    ...    AND    STATE__GSM_BTS_lock_unlock_from_BSC.TC Setup
    TC__STATE__GSM_BTS_lock_unlock_from_BSC
    [Teardown]    Run Keywords    STATE__GSM_BTS_lock_unlock_from_BSC.TC Teardown
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
    
    ...    AND    Modify Resource Search Order    SWM__SBTS_SOAM_rollback_to_SBTS_SOAM
    ...    AND    SWM__SBTS_SOAM_rollback_to_SBTS_SOAM.TC Setup
    TC__SWM__SBTS_SOAM_rollback_to_SBTS_SOAM
    [Teardown]    Run Keywords    SWM__SBTS_SOAM_rollback_to_SBTS_SOAM.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  Run Keyword  CIT Recover Test Line By Power Reset



[2]Automated__CM__Commissioning__Configuration_reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${Configuration Reset Timeout}    500
    ...    AND    Set Test Variable    ${Conf_reset_by_AdminAPI}    ${TRUE}
    ...    AND    Set Test Variable    ${RM_DETECTION_TIMEOUT}    10 min
    ...    AND    Set Test Variable    ${SMOD2_CHECK_TIMEOUT}    5 min
    ...    AND    Modify Resource Search Order    CM__Commissioning__Configuration_reset
    ...    AND    CM__Commissioning__Configuration_reset.TC Setup
    TC__CM__Commissioning__Configuration_reset
    [Teardown]    Run Keywords    CM__Commissioning__Configuration_reset.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  Run Keyword  CIT Recover Test Line By Power Reset


[1]Automated__SWM__SW_download_and_activation_SBTS_to_SBTS_uncommissioned
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${Target SW name}    ${None}
    ...    AND    Set Test Variable    ${Target SW dir}    /home/ute/TARGET_SW_T1
    ...    AND    Set Test Variable    ${SW Update Timeout}    2500
    ...    AND    Set Test Variable    ${Ping loss timeout}    240
    ...    AND    Set Test Variable    ${Ping regain timeout}    600
    ...    AND    Set Test Variable    ${DISABLE_RMODS}    True
    ...    AND    Set Test Variable    ${RM_DETECTION_TIMEOUT}    20
    ...    AND    Set Test Variable    ${Test_Timeout}    60
    ...    AND    Modify Resource Search Order    SWM__SW_download_and_activation__SBTS_to_SBTS_uncommissioned
    ...    AND    SWM__SW_download_and_activation__SBTS_to_SBTS_uncommissioned.TC Setup
	${command}  Catenate  cat ../testline_init_results/node1/logs/INFO_log.txt | grep BTSSM-based | tail -1 |
    ...  awk -F 'from ' '{print $2}' | awk -F '.zip' '{print $1}'
    ${package}=  Run Keyword If  ${SMOD2_exists}
    ...  run   ${command}
	...  ELSE   run
	...  cat ../testline_init_results/logs/INFO_log.txt | grep BTSSM-based | tail -1 | awk -F 'from ' '{print $2}' | awk -F '.zip' '{print $1}'
    Log to console  Download SW packages ${package}_testpackage_T1.zip
    run  mkdir ${Target SW dir}
    run  sudo chmod 777 ${Target SW dir} -R
    # run  wget ${package}_testpackage_T1.zip -P ${Target SW dir}
    run  wget files.ute.nsn-rdnet.net/builds/enb/base/${ENB_BUILD}/${ENB_BUILD}_release_BTSSM_downloadable_testpackage_T1.zip -P ${Target SW dir}
    # Run Keyword If  ${SMOD2_exists}  run
#    ...  ssh ute@${PC_IP2} "mkdir ${Target SW dir}; sudo chmod 777 ${Target SW dir} -R; wget ${package}_testpackage_T1.zip -P ${Target SW dir}"
    [Timeout]    45 minutes
    TC__SWM__SW_download_and_activation__SBTS_to_SBTS_uncommissioned
    [Teardown]    Run Keywords    SWM__SW_download_and_activation__SBTS_to_SBTS_uncommissioned.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  Run Keyword  CIT Recover Test Line By Power Reset


[1]Automated__SWM__SW_update_for_new_RF_unit_uncommissioned
    [Timeout]    30 minutes
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${SW Update Timeout}    400
    ...    AND    Set Test Variable    ${proceduralStatus Check Number}    60
    ...    AND    Set Test Variable    ${Target SW dir}    /home/ute/TARGET_SW_T1
    ...    AND    Set Test Variable    &{IGNORED_ALARM}    faultId=23
    ...    AND    Set Test Variable    @{IGNORED_ALARMS}    ${IGNORED_ALARM}
    
    ...    AND    Modify Resource Search Order    SWM__SW_update_for_new_RF_unit_uncommissioned
    ...    AND    SWM__SW_update_for_new_RF_unit_uncommissioned.TC Setup
    TC__SWM__SW_update_for_new_RF_unit_uncommissioned
    [Teardown]    Run Keywords    SWM__SW_update_for_new_RF_unit_uncommissioned.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  Run Keyword  CIT Recover Test Line By Power Reset


[2]Automated__CM__Commissioning_planned_commissioning
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${COMMISSIONING_PATH}    
    ...    AND    Set Test Variable    ${SKIP_PARAM_RELATION_ERRORS}    ${TRUE}
    ...    AND    Set Test Variable    ${COMMISSIONING_TIMEOUT}    600
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    15
    ...    AND    Set Test Variable    ${IPSEC_INSTALL}    ${FALSE}
    ...    AND    Set Test Variable    ${POST_CHECK_ONLY_ALARMS}    ${FALSE}
    ...    AND    Set Test Variable    ${POST_ALARMS_IGNORED_PATTERN}    ${EMPTY}
    ...    AND    Set Test Variable    ${ALT_SCF_PATH}    ${EMPTY}
    ...    AND    Modify Resource Search Order    CM__Commissioning__Planned_commissioning
    ...    AND    CM__Commissioning__Planned_commissioning.TC Setup
    TC__CM__Commissioning__Planned_commissioning
    [Teardown]    Run Keywords    CM__Commissioning__Planned_commissioning.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  Run Keyword  CIT Recover Test Line By Power Reset

[1]Automated__SWM__Local_Software_Download_Cancel
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${Target SW name}    ${None}
    ...    AND    Set Test Variable    ${Target SW dir}    /home/ute/TARGET_SW_T2
    ...    AND    Set Test Variable    ${SLEEP_BEFORE_CANCEL}    90
    ...    AND    Set Test Variable    ${DOWNLOAD_TIMEOUT}    600
    ...    AND    Set Test Variable    ${RM_DETECTION_TIMEOUT}    15 min
    
    ...    AND    Modify Resource Search Order    SWM__Local_Software_Download_Cancel
    ...    AND    SWM__Local_Software_Download_Cancel.TC Setup
    run  mkdir ${Target SW dir}
    run  sudo chmod 777 ${Target SW dir} -R
    run  wget files.ute.nsn-rdnet.net/builds/enb/base/${ENB_BUILD}/${ENB_BUILD}_release_BTSSM_downloadable_testpackage_T2.zip -P ${Target SW dir}
    TC__SWM__Local_Software_Download_Cancel
    [Teardown]    Run Keywords    SWM__Local_Software_Download_Cancel.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  Run Keyword  CIT Recover Test Line By Power Reset


[1]SWM__Upload_swconfig
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${SWCONFIG_PATH}
    ...    /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS1441/swconfigs/swconfig_HWF/swconfig.txt
    ...    AND    Set Test Variable    ${ADDITIONAL_IGNORED_ALARMS}
    ...    [['faultId', '4655', ' alarmId ', '7220'], ['faultId', '4654', 'alarmId', '7220']]
    
    ...    AND    Modify Resource Search Order    SWM__Upload_swconfig
    ...    AND    SWM__Upload_swconfig.TC Setup
    TC__SWM__Upload_swconfig
    [Teardown]    Run Keywords    SWM__Upload_swconfig.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  Run Keyword  CIT Recover Test Line By Power Reset


[2][UUF4ALL]Site_reset_without_HWF_in_loop
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

[1][UUF4ALL]Site_reset_without_HWF_in_loop
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
    
[3][UUF4ALL]Site_reset_without_HWF_in_loop
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
    
[4][UUF4ALL]Site_reset_without_HWF_in_loop
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

[5][UUF4ALL]Site_reset_without_HWF_in_loop
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
    
    
[2]SWM__Upload_swconfig
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${SWCONFIG_PATH}
    ...    /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS1441/swconfigs/swconfig_clean/swconfig.txt
    ...    AND    Set Test Variable    ${ADDITIONAL_IGNORED_ALARMS}
    ...    [['faultId', '4655', ' alarmId ', '7220'], ['faultId', '4654', 'alarmId', '7220']]
    
    ...    AND    Modify Resource Search Order    SWM__Upload_swconfig
    ...    AND    SWM__Upload_swconfig.TC Setup
    TC__SWM__Upload_swconfig
    [Teardown]    Run Keywords    SWM__Upload_swconfig.TC Teardown
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
    
    ...    AND    Modify Resource Search Order    STATE__Site_power_reset
    ...    AND    STATE__Site_power_reset.TC Setup
    TC__STATE__Site_power_reset
    [Teardown]    Run Keywords    STATE__Site_power_reset.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  Run Keyword  CIT Recover Test Line By Power Reset


[1][UUF4ALL]SW upgrade in loop
    [Setup]    Run Keywords    Set Test Variable    ${COMMISSIONING_PATH}
    ...    /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS1441/commissioning/SCF_01_TRUNK.xml
    ...    AND    Set Test Variable    ${Target SW name}    ${None}
    ...    AND    Set Test Variable    ${Target SW dir}    /home/ute/TARGET_SW_T2
    ...    AND    Set Test Variable    ${SW Update Timeout}    3600
    ...    AND    Set Test Variable    ${Ping loss timeout}    900
    ...    AND    Set Test Variable    ${Ping regain timeout}    1900
    ...    AND    Set Test Variable    ${onAir Check Number}    150
    ...    AND    Set Test Variable    ${First Cell On Air Timeout}    35
    ...    AND    Set Test Variable    ${Test Timeout}    120
    ...    AND    Modify Resource Search Order    SWM__SW_download_and_activation__SBTS_to_SBTS
    ...    AND    SWM__SW_download_and_activation__SBTS_to_SBTS.TC Setup

    [Timeout]    60 minutes
    TC__SWM__SW_download_and_activation__SBTS_to_SBTS
    [Teardown]    Run Keywords    SWM__SW_download_and_activation__SBTS_to_SBTS.TC Teardown
    ...    AND    Restore Resource Search Order


[2][UUF4ALL]SW upgrade in loop
    [Setup]    Run Keywords    Set Test Variable    ${COMMISSIONING_PATH}
    ...    /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS1441/commissioning/SCF_01_TRUNK.xml
    ...    AND    Set Test Variable    ${Target SW name}    ${None}
    ...    AND    Set Test Variable    ${Target SW dir}    /home/ute/TARGET_SW
    ...    AND    Set Test Variable    ${SW Update Timeout}    3600
    ...    AND    Set Test Variable    ${Ping loss timeout}    900
    ...    AND    Set Test Variable    ${Ping regain timeout}    1900
    ...    AND    Set Test Variable    ${onAir Check Number}    150
    ...    AND    Set Test Variable    ${First Cell On Air Timeout}    35
    ...    AND    Set Test Variable    ${Test Timeout}    120
    ...    AND    Modify Resource Search Order    SWM__SW_download_and_activation__SBTS_to_SBTS
    ...    AND    SWM__SW_download_and_activation__SBTS_to_SBTS.TC Setup

    [Timeout]    60 minutes
    TC__SWM__SW_download_and_activation__SBTS_to_SBTS
    [Teardown]    Run Keywords    SWM__SW_download_and_activation__SBTS_to_SBTS.TC Teardown
    ...    AND    Restore Resource Search Order

[3][UUF4ALL]SW upgrade in loop
    [Setup]    Run Keywords    Set Test Variable    ${COMMISSIONING_PATH}
    ...    /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS1441/commissioning/SCF_01_TRUNK.xml
    ...    AND    Set Test Variable    ${Target SW name}    ${None}
    ...    AND    Set Test Variable    ${Target SW dir}    /home/ute/TARGET_SW_T1
    ...    AND    Set Test Variable    ${SW Update Timeout}    3600
    ...    AND    Set Test Variable    ${Ping loss timeout}    900
    ...    AND    Set Test Variable    ${Ping regain timeout}    1900
    ...    AND    Set Test Variable    ${onAir Check Number}    150
    ...    AND    Set Test Variable    ${First Cell On Air Timeout}    35
    ...    AND    Set Test Variable    ${Test Timeout}    120
    ...    AND    Modify Resource Search Order    SWM__SW_download_and_activation__SBTS_to_SBTS
    ...    AND    SWM__SW_download_and_activation__SBTS_to_SBTS.TC Setup

    [Timeout]    60 minutes
    TC__SWM__SW_download_and_activation__SBTS_to_SBTS
    [Teardown]    Run Keywords    SWM__SW_download_and_activation__SBTS_to_SBTS.TC Teardown
    ...    AND    Restore Resource Search Order


*** Keywords ***

Map BuildShareTimi01 and move counters folder in test line specific
    Run  sudo mkdir -p /media/BuildShareTimi01
    Run  sudo chown ute:ute /media/BuildShareTimi01
    ${sudo_command}  Catenate  SEPARATOR=  sudo sh -c "echo //10.5.16.78/BuildShareTimi01 /media/BuildShareTimi01/ cifs _netdev,
    ...  noperm,username=userbuild,,nosuid,noexec,password=Aikon_123456*8 0 0 >>/etc/fstab"
    Run  ${sudo_command}
    Run  sudo mount -a
    ${cp_command}  Catenate  cp /media/BuildShareTimi01/SBTS/Trunk/counters_for_CIT_Trunk/counter_files/*
    ...  /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS1441/counters/
    run   ${cp_command}
