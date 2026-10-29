*** Settings ***
Documentation
  ...   Author: larisa.lupea@nokia
  ...   Description: BOAM SBTS10338


Force Tags  QCD_MN_RAN  QCP_RAN_ST  SRAN  CLOUD_SRAN_LWG_10338_1ASIB_2ABIA_1ASIB_3ABIA_3AHEGC_3AHDB  STATE_COMMISSIONED
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
# Resource    ../../KPI/test_resources/KPI__BBMOD_Reset_From_WebEM.robot

Suite Setup      Set Library Search Order  coam   ute_admin   hran_frame_sbts_taf   hran_frame_sbts_siso   ca_CIT_general   ca_swm_general

*** Variables ***
${SCF_ID}    01
${HW_LOCATION_CODE}      Timisoara
${ENB_BUILD}    SBTS00_ENB_9999_211207_000006
${REQUEST_SCF_SCOUT}    ${TRUE}
${SCOUT_TL_NAME}    10_18_UTESRANCLOUD1338
${SKIP_RU_POWER_CHECK}    ${TRUE}
${DISABLE_WATCHDOG}    ${TRUE}

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
    Download and check software package  ${ENB_BUILD}  ${Target SW dir}
    [Timeout]    60 minutes
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
    ${package}=  Run Keyword If  ${SMOD2_exists}  run
    ...  cat ../testline_init_results/node1/logs/INFO_log.txt | grep BTSSM-based | tail -1 | awk -F 'from ' '{print $2}' | awk -F '.zip' '{print $1}'
    ...  ELSE   run
    ...  cat ../testline_init_results/logs/INFO_log.txt | grep BTSSM-based | tail -1 | awk -F 'from ' '{print $2}' | awk -F '.zip' '{print $1}'
    Log to console  Download SW packages ${package}_testpackage_T1.zip
    run  mkdir ${Target SW dir}
    run  sudo chmod 777 ${Target SW dir} -R
    Download and check software package  ${ENB_BUILD}  ${Target SW dir}  testpackage_T1_A54
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
    ...    AND    Set Test Variable    ${HW_OFF_ID_LIST}
    ...    AND    Set Test Variable    ${NUMBER_OF_RMODS_TO_TURN_OFF}    1
    ...    AND    Set Test Variable    ${ADDITIONAL_IGNORED_ALARMS}
    ...    [['faultId', '4655', ' alarmId ', '7220'], ['faultId', '4654', 'alarmId', '7220']]
    ...    AND    Modify Resource Search Order    SWM__SW_update_for_RMOD_with_fault_23
    ...    AND    SWM__SW_update_for_RMOD_with_fault_23.TC Setup
    Run  sudo rm -rf ${Target SW dir}
    Run  mkdir ${Target SW dir}
    Run  sudo chmod 777 ${Target SW dir} -R
    Download and check software package  ${ENB_BUILD}  ${Target SW dir}
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


[1][UUF4ALL]SW upgrade in loop
    [Setup]    Run Keywords    Set Test Variable    ${Target SW name}    ${None}
    ...    AND    Set Test Variable    ${Target SW dir}    /home/ute/TARGET_SW_T2
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
    Download and check software package  ${ENB_BUILD}  ${Target SW dir}  testpackage_T2_A54
    [Timeout]    60 minutes
    TC__SWM__SW_download_and_activation__SBTS_to_SBTS
    Run  rm -rf ${Target SW dir}
    [Teardown]    Run Keywords    SWM__SW_download_and_activation__SBTS_to_SBTS.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  Run Keyword  CIT Recover Test Line By Power Reset

[2][UUF4ALL]SW upgrade in loop
    [Setup]    Run Keywords    Set Test Variable    ${Target SW name}    ${None}
    ...    AND    Set Test Variable    ${Target SW dir}    /home/ute/TARGET_SW_T1
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
    Download and check software package  ${ENB_BUILD}  ${Target SW dir}  testpackage_T1_A54

    [Timeout]    60 minutes
    TC__SWM__SW_download_and_activation__SBTS_to_SBTS
    Run  rm -rf ${Target SW dir}
    [Teardown]    Run Keywords    SWM__SW_download_and_activation__SBTS_to_SBTS.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  Run Keyword  CIT Recover Test Line By Power Reset

[3][UUF4ALL]SW upgrade in loop
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
    Run  sudo rm -rf ${Target SW dir}
    Run  mkdir ${Target SW dir}
    Run  sudo chmod 777 ${Target SW dir} -R
    Download and check software package  ${ENB_BUILD}  ${Target SW dir}

    [Timeout]    60 minutes
    TC__SWM__SW_download_and_activation__SBTS_to_SBTS
    [Teardown]    Run Keywords    SWM__SW_download_and_activation__SBTS_to_SBTS.TC Teardown
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

