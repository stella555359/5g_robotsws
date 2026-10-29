*** Settings ***

Documentation
...    Author: delia.margulescu@nokia.com
...    Description: CRT

Force Tags  QCD_MN_RAN  QCP_RAN_VRF  RAN_MRAT  SRAN  CLOUD_SRAN_NLG_10680_1ASOG_2AHEGA
...    SBTS00    STATE_SKIP_AGENT
Library           XML  use_lxml=True


Resource    ../../CIT/test_resources/CM_CABLE_SPEED_CHANGE.robot
Resource    ../../CIT/test_resources/CM_Cell_Addition_LTE.robot
Resource    ../../CIT/test_resources/CM_Cell_Removal_LTE.robot
Resource    ../../CIT/test_resources/CM__Commissioning__Configuration_reset.robot
Resource    ../../CIT/test_resources/CM__Commissioning__Planned_commissioning.robot
Resource    ../../CIT/test_resources/CM__Recommissioning_with_BTS_reset.robot
Resource    ../../CIT/test_resources/CM__Recommissioning_delta_commissioning_with_reset.robot
Resource    ../../CIT/test_resources/CM__Recommissioning_delta_commissioning_without_reset.robot
Resource    ../../FM/test_resources/FM__RF_hot_remove_hot_insert.robot
Resource    ../../FM/test_resources/FM__Recovery_whole_multiple_Link_Break.robot
Resource    ../../CIT/test_resources/LOGS__Memory_dump_files_creation_in_case_of_DSP_crash.robot
Resource    ../../CIT/test_resources/LOGS__Postmortem_files_creation_in_snapshot_content_for_SMOD.robot
Resource    ../../CIT/test_resources/LOGS__Snapshot.robot
Resource    ../../CIT/test_resources/PM__LTE_counters_are_available_on_ram_disk_versus_NIDD_counter_list.robot
Resource    ../../CIT/test_resources/PM__TNL_counters_are_available_on_ram_disk_versus_NIDD_counter_list.robot
Resource    ../../CIT/test_resources/PM__WBTS_counters_are_available_on_ram_disk_versus_NIDD_counter_list.robot
Resource    ../../CIT/test_resources/STATE__LTE_RAT_reset__parameter_change__ADMIN.robot
Resource    ../../CIT/test_resources/STATE__LTE_RAT_reset_from_ADMIN.robot
Resource    ../../CIT/test_resources/STATE__LTE_S1_Lock_Unlock.robot
Resource    ../../CIT/test_resources/STATE__LTE_cell_block_unblock_from_ADMIN.robot
Resource    ../../CIT/test_resources/STATE__LTE_cell_lock_unlock_from_ADMIN.robot
Resource    ../../CIT/test_resources/STATE__Radio_module_reset_from_admin.robot
Resource    ../../CIT/test_resources/STATE__S1_lock_reset_unlock.robot
Resource    ../../CIT/test_resources/STATE__Site_power_reset.robot
Resource    ../../CIT/test_resources/STATE__Site_reset.robot
Resource    ../../CIT/test_resources/STATE__sbts_block_unblock.robot
Resource    ../../CIT/test_resources/SWM__Local_Software_Activation.robot
Resource    ../../CIT/test_resources/SWM__Local_Software_Download.robot
Resource    ../../CIT/test_resources/SWM__Local_Software_Download_Cancel.robot
Resource    ../../CIT/test_resources/SWM__SBTS_SOAM_rollback_to_SBTS_SOAM.robot
Resource    ../../CIT/test_resources/SWM__SCF_validation_errors_check.robot
Resource    ../../CIT/test_resources/SWM__SW_download_and_activation__SBTS_to_SBTS.robot
Resource    ../../CIT/test_resources/SWM__SW_update_for_RMOD_with_fault_23.robot
Resource    ../../CIT/test_resources/SWM__Upload_swconfig.robot
Resource    ../../CIT/test_resources/CIT_Test_Line_Recovery.robot
Resource    ../../FM/test_resources/FM__LTE_CCplane_crash_RAT_recovery_reset.robot
Resource    ../../FM/test_resources/FM__LTE_DSP_crash_DSP_recovery_reset.robot
Resource    ../../FM/test_resources/FM__RAT_reset_actForceAutoReset_true_enabled_cells.robot
Resource    ../../FM/test_resources/FM__RAT_reset_counter_exceeded__multi_RAT.robot
Resource    ../../FM/test_resources/FM__SC_hot_remove_hot_insert.robot
Resource    ../../FM/test_resources/FM__SC_late_startup_actForceAutoReset_true.robot
Resource    ../../FM/test_resources/FM__Site_reset_actForceAutoReset_false_enabled_cell.robot
Resource    ../../FM/test_resources/FM__Site_reset_actForceAutoReset_true_enabled_cell.robot
Resource    ../../FM/test_resources/FM__Site_reset_counter_cleared_timer_exceeded.robot
Resource    ../../FM/test_resources/FM__Site_reset_counter_exceeded.robot
Resource    ../../FM/test_resources/FM__fault_handling_LTE_CPlane.robot
Resource    ../../FM/test_resources/FM__FSP_common_reset_counter_exceeded.robot
Resource    ../../FM/test_resources/FM__RMOD_crash_fault_signature_check.robot




Suite Setup      Run keywords
...              Set Library Search Order  coam   ute_admin   hran_frame_sbts_taf   hran_frame_sbts_siso   ca_CIT_general   ca_swm_general
...              AND  Map BuildShareTimi01 and move counters folder in test_line_specific

*** Variables ***
${SCF_ID}    01
${HW_LOCATION_CODE}      Timisoara
${ENB_BUILD}    SBTS00_ENB_9999_211207_000006
${REQUEST_SCF_SCOUT}    ${TRUE}
${SCOUT_TL_NAME}    10_18_UTESRANCLOUD1680

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

[1]5G RAT reset via ADMIN
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${NR_RAT_RESET_TIMEOUT}    1800
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    False

    ...    AND    STATE__5G_RAT_Reset_From_WebEM.TC Setup
    ...    AND    Modify Resource Search Order    STATE__5G_RAT_Reset_From_WebEM
    TC__STATE__5G_RAT_Reset_From_WebEM
    [Teardown]    Run Keywords    STATE__5G_RAT_Reset_From_WebEM.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  Run Keyword  CIT Recover Test Line By Power Reset


[1]Automated__FM__RF_hot_remove_hot_insert
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_SN}
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


[1]FM_RMOD_power_off_on_FID4589
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_TYPE}    AHPMDG
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    360
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_ID}    4589
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_NAME}    Unit power reset
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_ID}    7115
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_NAME}    BASE STATION INFORMATION
    ...    AND    Set Test Variable    ${SEVERITY}    Warning

    ...    AND    FM__RMOD_crash_fault_signature_check.TC setup
    ...    AND    Modify Resource Search Order    FM__RMOD_crash_fault_signature_check
    FM__RMOD_crash_fault_signature_check
    [Teardown]    Run Keywords    FM__RMOD_crash_fault_signature_check.TC Teardown
    ...    AND    Restore Resource Search Order


[1]Automated__CM__Recommissioning_with_BTS_reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${PARAMETER_SCF_DIST_NAME}    MRBTS-10680/MNL-1
    ...    AND    Set Test Variable    ${PARAMETER_IM_DIST_NAME}    //MNL_A-1
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
    ...    /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS1680/json/name_delta.json
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
    ...    /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS1680/json/time_zone_delta.json
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
    ...    [['faultId', '4655', ' alarmId ', '7220'], ['faultId', '4654', 'alarmId', '7220'], ['faultId', '7319', ' alarmId ', '7107']]
    ...    AND    Modify Resource Search Order    STATE__sbts_block_unblock
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
    ...    AND    Set Test Variable    ${ADDITIONAL_IGNORED_ALARMS}
    ...    [['faultId', '4655', ' alarmId ', '7220'], ['faultId', '4654', 'alarmId', '7220']]
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
    ...    AND    Set Test Variable    ${ADDITIONAL_IGNORED_ALARMS}
    ...    [['faultId', '4655', ' alarmId ', '7220'], ['faultId', '4654', 'alarmId', '7220']]
    ...    AND    Modify Resource Search Order    STATE__LTE_RAT_reset_from_ADMIN
    ...    AND    STATE__LTE_RAT_reset_from_ADMIN.TC Setup
    TC__STATE__LTE_RAT_reset_from_ADMIN
    [Teardown]    Run Keywords    STATE__LTE_RAT_reset_from_ADMIN.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  Run Keyword  CIT Recover Test Line By Power Reset



[1]Automated__STATE__LTE_RAT_reset__parameter_change__ADMIN
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${PARAMETER_SCF_DIST_NAME}    MRBTS-10680/LNBTS-10680
    ...    AND    Set Test Variable    ${PARAMETER_ABBREVIATION}    cPlaneDscp
    ...    AND    Set Test Variable    ${PARAMETER_VALUE}    47
    ...    AND    Set Test Variable    ${SKIP_PARAM_RELATION_ERRORS}    ${TRUE}
    ...    AND    Set Test Variable    ${RECOMMISSIONING_TIMEOUT}    600
    ...    AND    Set Test Variable    ${LTE_OPERATIONAL_TIMEOUT}    360
    ...    AND    Set Test Variable    ${ADDITIONAL_IGNORED_ALARMS}
    ...    [['faultId', '4655', ' alarmId ', '7220'], ['faultId', '4654', 'alarmId', '7220']]
    ...    AND    Modify Resource Search Order    STATE__LTE_RAT_reset__parameter_change__ADMIN
    ...    AND    STATE__LTE_RAT_reset__parameter_change__ADMIN.TC Setup
    TC__STATE__LTE_RAT_reset__parameter_change__ADMIN
    [Teardown]    Run Keywords    STATE__LTE_RAT_reset__parameter_change__ADMIN.TC Teardown
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
    ...    AND    Set Test Variable    ${STATES_ON_UNBLOCK_WCDMA}    availabilityStatus=Online, blockingState=Unblocked, operationalState=Enabled
    ...    AND    Set Test Variable    ${STATES_ON_UNBLOCK_GSM}
    ...    administrativeState=Unlocked, availabilityStatus=Online, blockingState=Unblocked, operationalState=Enabled
    ...    AND    Set Test Variable    ${LOG_TX_POWER}    False
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


[1]Automated__LOGS__Snapshot_content__postmortem_files_creation_for_SMOD
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${SNAPSHOT_FILE_PATH}    /tmp/uri/DIAGN_FILES/
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    10
    ...    AND    Set Test Variable    ${SNAPSHOT_TIMEOUT}    600
    ...    AND    Set Test Variable    ${ADDITIONAL_IGNORED_ALARMS}
    ...    [['faultId', '4655', ' alarmId ', '7220'], ['faultId', '4654', 'alarmId', '7220']]
    ...    AND    Modify Resource Search Order    LOGS__Postmortem_files_creation_in_snapshot_content_for_SMOD
    ...    AND    LOGS__Postmortem_files_creation_in_snapshot_content_for_SMOD.TC Setup
    TC__LOGS__Postmortem_files_creation_in_snapshot_content_for_SMOD
    [Teardown]    Run Keywords    LOGS__Postmortem_files_creation_in_snapshot_content_for_SMOD.TC Teardown
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
    ${first_cat_command}   Catenate  cat ../testline_init_results/node1/logs/INFO_log.txt | grep BTSSM-based |
    ...                              tail -1 | awk -F 'from ' '{print $2}' | awk -F '.zip' '{print $1}'
    ${second_cat_command}  Catenate  cat ../testline_init_results/logs/INFO_log.txt | grep BTSSM-based |
    ...                              tail -1 | awk -F 'from ' '{print $2}' | awk -F '.zip' '{print $1}'
    ${package}=  Run Keyword If  ${SMOD2_exists}  run   ${first_cat_command}
    ...  ELSE   run    ${second_cat_command}
    Log to console  Download SW packages ${package}_testpackage_T1.zip
    run  mkdir ${Target SW dir}
    run  sudo chmod 777 ${Target SW dir} -R
    Download and check software package  ${ENB_BUILD}  ${Target SW dir}  testpackage_T1_A54
    TC__SWM__Local_Software_Download
    [Teardown]    Run Keywords    SWM__Local_Software_Download.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  CIT Recover Test Line By Power Reset


[1]Automated__SWM__Local_Software_Activation
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${Target SW name}    ${None}
    ...    AND    Set Test Variable    ${Target SW dir}    /home/ute/TARGET_SW_T1
    ...    AND    Set Test Variable    ${SW Activation Timeout}    1200
    ...    AND    Set Test Variable    ${Ping loss timeout}    420
    ...    AND    Set Test Variable    ${Ping regain timeout}    600
    ...    AND    Set Test Variable    ${BTS_OnAir_Timeout}    15
    ...    AND    Set Test Variable    ${Test_Timeout}    30
    ...    AND    Set Test Variable    ${ADDITIONAL_IGNORED_ALARMS}
    ...    [['faultId', '4655', ' alarmId ', '7220'], ['faultId', '4654', 'alarmId', '7220']]
    ...    AND    Modify Resource Search Order    SWM__Local_Software_Activation
    ...    AND    SWM__Local_Software_Activation.TC Setup

    TC__SWM__Local_Software_Activation
    [Teardown]    Run Keywords    SWM__Local_Software_Activation.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  CIT Recover Test Line By Power Reset


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
    ...    AND    Set Test Variable    ${HW_OFF_ID_LIST}    RMOD_K9194200562
    ...    AND    Set Test Variable    ${NUMBER_OF_RMODS_TO_TURN_OFF}    1
    ...    AND    Set Test Variable    ${ADDITIONAL_IGNORED_ALARMS}
    ...    [['faultId', '4655', ' alarmId ', '7220'], ['faultId', '4654', 'alarmId', '7220']]
    ...    AND    Modify Resource Search Order    SWM__SW_update_for_RMOD_with_fault_23
    ...    AND    SWM__SW_update_for_RMOD_with_fault_23.TC Setup
    Run  mkdir ${Target SW dir}
    Run  sudo chmod 777 ${Target SW dir} -R
    Download and check software package  ${ENB_BUILD}  ${Target SW dir}
    TC__SWM__SW_update_for_RMOD_with_fault_23
    [Teardown]    Run Keywords    SWM__SW_update_for_RMOD_with_fault_23.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  CIT Recover Test Line By Power Reset


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


*** Keywords ***
Map BuildShareTimi01 and move counters folder in test_line_specific
    Run  sudo mkdir -p /media/BuildShareTimi01
    Run  sudo chown ute:ute /media/BuildShareTimi01
    ${sudo_command}  Catenate  SEPARATOR=  sudo sh -c "echo //10.5.16.78/BuildShareTimi01 /media/BuildShareTimi01/ cifs _netdev,
    ...                                    noperm,username=userbuild,,nosuid,noexec,password=Aikon_123456*8 0 0 >>/etc/fstab"
    Run  ${sudo_command}
    Run  sudo mount -a
    ${cp_command}  Catenate  cp /media/BuildShareTimi01/SBTS/Trunk/counters_for_CIT_Trunk/1688/*
    ...                      /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS10688/counters/
    Run  ${cp_command}
