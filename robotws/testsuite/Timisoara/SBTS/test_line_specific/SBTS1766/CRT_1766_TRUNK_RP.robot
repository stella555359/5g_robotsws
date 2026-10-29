*** Settings ***
Force Tags  QCD_MN_RAN  QCP_RAN_VRF  SRAN  CLOUD_SRAN_L_10766_1ASIA_2ABIA_1ExtASIK_1AAHF  STATE_COMMISSIONED
Library           XML  use_lxml=True

Resource    ../../CIT/test_resources/SWM__SW_download_and_activation__SBTS_to_SBTS.robot
Resource    ../../CIT/test_resources/CM__Commissioning__Configuration_reset.robot
Resource    ../../CIT/test_resources/CM__Commissioning__Planned_commissioning.robot
Resource    ../../CIT/test_resources/STATE__LTE_cell_block_unblock_from_ADMIN.robot
Resource    ../../CIT/test_resources/STATE__LTE_RAT_reset__parameter_change__ADMIN.robot
Resource    ../../CIT/test_resources/STATE__LTE_S1_Lock_Unlock.robot
Resource    ../../CIT/test_resources/STATE__sbts_block_unblock.robot
Resource    ../../FM/test_resources/FM__RF_hot_remove_hot_insert.robot
Resource    ../../CIT/test_resources/STATE__LTE_RAT_reset_from_ADMIN.robot
Resource    ../../CIT/test_resources/LOGS__Postmortem_files_creation_in_snapshot_content_for_SMOD.robot
Resource    ../../CIT/test_resources/SWM__Local_Software_Activation.robot
Resource    ../../CIT/test_resources/SWM__Local_Software_Download.robot
Resource    ../../CIT/test_resources/SWM__Local_Software_Download_Cancel.robot
Resource    ../../CIT/test_resources/SWM__SBTS_SOAM_rollback_to_SBTS_SOAM.robot
Resource    ../../CIT/test_resources/SWM__SW_update_for_RMOD_with_fault_23.robot


Suite Setup      Set Library Search Order  coam   ute_admin   hran_frame_sbts_taf   hran_frame_sbts_siso   ca_CIT_general   ca_swm_general

*** Variables ***
${SCF_ID}    01
${HW_LOCATION_CODE}      Timisoara
${ENB_BUILD}    SBTS00_ENB_9999_211207_000006
${REQUEST_SCF_SCOUT}    ${TRUE}
${SCOUT_TL_NAME}    10_18_UTESRANCLOUD1766
${SKIP_RU_POWER_CHECK}    ${TRUE}

*** Test Cases ***
[1]Automated__SWM__SW_download_and_activation__SBTS_to_SBTS
    [Tags]    STOPONFAIL  QC_37029
    [Timeout]    14400
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
    TC__SWM__SW_download_and_activation__SBTS_to_SBTS
    [Teardown]    Run Keywords    SWM__SW_download_and_activation__SBTS_to_SBTS.TC Teardown
    ...    AND    Restore Resource Search Order


[1]Automated__CM__Commissioning__Configuration_reset
    [Tags]  QC_37038
    Setup Scout  10_18_UTESRANCLOUD1766
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API


[1]Automated__CM__Commissioning_planned_commissioning
    [Tags]  QC_37037
    Setup Scout  10_18_UTESRANCLOUD1766
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API




[1]Automated__STATE__LTE_cell_block_unblock_from_ADMIN
    [Tags]  QC_37030
    Setup Scout  10_18_UTESRANCLOUD1766
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API


[1]Automated__STATE__LTE_RAT_reset__parameter_change__ADMIN
    [Tags]  QC_37031
    Setup Scout  10_18_UTESRANCLOUD1766
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API


[1]Automated__STATE__LTE_S1_Lock_Unlock
    [Tags]  QC_37032
    Setup Scout  10_18_UTESRANCLOUD1766
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API


[1]Automated__STATE__SBTS_block_unblock
    [Tags]  QC_37033
    Setup Scout  10_18_UTESRANCLOUD1766
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API


[1]Automated__FM__RF_hot_remove_hot_insert
    [Tags]  QC_37034
    Setup Scout  10_18_UTESRANCLOUD1766
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API


[1]Automated__STATE__LTE_RAT_reset_from_ADMIN
    [Tags]  QC_37035
    Setup Scout  10_18_UTESRANCLOUD1766
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API


[1]Automated__LOGS__Snapshot_content__postmortem_files_creation_for_SMOD
    [Tags]  QC_37036
    Setup Scout  10_18_UTESRANCLOUD1766
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API


[1]Automated__SWM__SBTS_SOAM_rollback_to_SBTS_SOAM
    [Tags]  QC_37039
    Setup Scout  10_18_UTESRANCLOUD1766
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API


[1][UUF4ALL]SW upgrade in loop
    [Tags]  QC_37040
    Setup Scout  10_18_UTESRANCLOUD1766
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API
