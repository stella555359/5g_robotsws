*** Settings ***
Library           XML  use_lxml=True
Resource    ../../COMPA/test_resources/COMPA__CM_Setup_environment.robot
Resource    ../../COMPA/test_resources/DEV__SBTS_SOAM_installing_using_YAFT.robot
Resource    ../../CIT/test_resources/SWM__SW_update_for_new_RF_unit_uncommissioned.robot
Resource    ../../CIT/test_resources/CM__Commissioning__Planned_commissioning.robot
Resource    ../../CIT/test_resources/SWM__SCF_validation_errors_check.robot
Resource    ../../CIT/test_resources/LOGS__Snapshot.robot
Resource    ../../COMPA/test_resources/COMPA__SSH_snapshot.robot
Resource    ../../CIT/test_resources/SWM__SW_download_and_activation__SBTS_to_SBTS.robot
Resource    ../../COMPA/test_resources/SWM__DC_SBTS_SOAM_fallback_to_SBTS_SOAM_CONS_RLC.robot
Resource    ../../COMPA/test_resources/DEV__DC_SBTS_SOAM_installing_using_YAFT.robot
Resource    ../../COMPA/test_resources/DEV__Commissioning_for_SBTS_with_alarms.robot
Resource    ../../CIT/test_resources/CM__Commissioning__Planned_commissioning_without_initial_SBTS_verification.robot
Resource    ../../COMPA/test_resources/DEV__SBTS_Testline_recovery.robot
Resource    ../../COMPA/test_resources/COMPA__Uboot_downgrade.robot
Resource    ../../CIT/test_resources/SWM__SW_update_without_SBTS_verifications.robot
Resource    ../../CIT/test_resources/SWM__Upload_swconfig.robot
Resource    ../../COMPA/test_resources/SWM__SW_update_for_new_RF_unit.robot
Documentation  Compa tests.

Suite Setup   Run keywords    Map BuildShareTimi01

*** Variables ***
${Compa_TL_NAME}    10_18_UTESRANCLOUD602


*** Test Cases ***
COMPA__CM_Setup_environment
    TC__COMPA__CM_Setup_environment


_1___DEV__DC_SBTS_SOAM_installing_using_YAFT
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${SW_DIRECTORY}    /home/ute/CLEANING_SW
    ...    AND    Set Test Variable    ${SWCONFIG_PATH}
    ...    /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS1602/swconfigs/swconfig.txt
    ...    AND    Set Test Variable    ${PING_STABLE_TIMEOUT}    401
    ...    AND    Modify Resource Search Order    DEV__DC_SBTS_SOAM_installing_using_YAFT
    ...    AND    DEV__DC_SBTS_SOAM_installing_using_YAFT.TC Setup
    TC__DEV__DC_SBTS_SOAM_installing_using_YAFT
    [Teardown]    Run Keywords    DEV__DC_SBTS_SOAM_installing_using_YAFT.TC Teardown
    ...    AND    Restore Resource Search Order


_2___DEV__Commissioning_for_SBTS_with_alarms
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${COMMISSIONING_TIMEOUT}    1200
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    16
    ...    AND    Set Test Variable    ${PING_STABLE_TIMEOUT}    401
    ...    AND    Modify Resource Search Order    DEV__Commissioning_for_SBTS_with_alarms
    ...    AND    DEV__Commissioning_for_SBTS_with_alarms.TC Setup
    TC__DEV__Commissioning_for_SBTS_with_alarms
    [Teardown]    Run Keywords    DEV__Commissioning_for_SBTS_with_alarms.TC Teardown
    ...    AND    Restore Resource Search Order

_3___CM__Commissioning__Planned_commissioning_without_initial_SBTS_verification
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${COMMISSIONING_TIMEOUT}    601
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    15
    ...    AND    Set Test Variable    ${SKIP_PARAM_RELATION_ERRORS}    ${TRUE}
    ...    AND    Set Test Variable    ${POST_CHECK_ONLY_ALARMS}    ${FALSE}
    ...    AND    Set Test Variable    ${POST_ALARMS_IGNORED_PATTERN}    ${EMPTY}
    ...    AND    Set Test Variable    ${ALT_SCF_PATH}    ${EMPTY}
    ...    AND    Modify Resource Search Order    CM__Commissioning__Planned_commissioning_without_initial_SBTS_verification
    ...    AND    CM__Commissioning__Planned_commissioning_without_initial_SBTS_verification.TC Setup
    TC__CM__Commissioning__Planned_commissioning_without_initial_SBTS_verification
    [Teardown]    Run Keywords    CM__Commissioning__Planned_commissioning_without_initial_SBTS_verification.TC Teardown
    ...    AND    Restore Resource Search Order


_4___SWM__SW_update_for_new_RF_unit
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${SW Update Timeout}    900
    ...    AND    Set Test Variable    ${onAir Check Number}    120
    ...    AND    Set Test Variable    ${Target SW dir}    /home/ute/CLEANING_SW
    ...    AND    Modify Resource Search Order    SWM__SW_update_for_new_RF_unit
    ...    AND    SWM__SW_update_for_new_RF_unit.TC Setup
    TC__SWM__SW_update_for_new_RF_unit
    [Teardown]    Run Keywords    SWM__SW_update_for_new_RF_unit.TC Teardown
    ...    AND    Restore Resource Search Order


_5___SWM__SW_update_for_new_RF_unit
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${SW Update Timeout}    900
    ...    AND    Set Test Variable    ${onAir Check Number}    120
    ...    AND    Set Test Variable    ${Target SW dir}    /home/ute/CLEANING_SW
    ...    AND    Modify Resource Search Order    SWM__SW_update_for_new_RF_unit
    ...    AND    SWM__SW_update_for_new_RF_unit.TC Setup
    TC__SWM__SW_update_for_new_RF_unit
    [Teardown]    Run Keywords    SWM__SW_update_for_new_RF_unit.TC Teardown
    ...    AND    Restore Resource Search Order

_6___SWM__SW_update_without_SBTS_verifications____CLEANING_SW
    [Setup]    Run Keywords    Set Test Variable    ${TARGET_SW_NAME}    ${None}
    ...    AND    Set Test Variable    ${TARGET_SW_DIR}    /home/ute/CLEANING_SW
    ...    AND    Set Test Variable    ${SW_UPDATE_TIMEOUT}    3601
    ...    AND    Set Test Variable    ${ONAIR_TIMEOUT}    901
    ...    AND    Modify Resource Search Order    SWM__SW_update_without_SBTS_verifications
    [Timeout]    90 minutes
    TC__SWM__SW_update_without_SBTS_verifications

_7___DEV__SBTS_Testline_recovery
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${ONAIR_TIMEOUT}    16
    ...    AND    Modify Resource Search Order    DEV__SBTS_Testline_recovery
    ...    AND    DEV__SBTS_Testline_recovery.TC Setup
    TC__DEV__SBTS_Testline_recovery
    [Teardown]    Run Keywords    DEV__SBTS_Testline_recovery.TC Teardown
    ...    AND    Restore Resource Search Order


_8___SWM__SW_update_for_new_RF_unit
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${SW Update Timeout}    900
    ...    AND    Set Test Variable    ${onAir Check Number}    120
    ...    AND    Set Test Variable    ${Target SW dir}    /home/ute/CLEANING_SW
    ...    AND    Modify Resource Search Order    SWM__SW_update_for_new_RF_unit
    ...    AND    SWM__SW_update_for_new_RF_unit.TC Setup
    TC__SWM__SW_update_for_new_RF_unit
    [Teardown]    Run Keywords    SWM__SW_update_for_new_RF_unit.TC Teardown
    ...    AND    Restore Resource Search Order


_9___SWM__SW_update_without_SBTS_verifications_____________CLEANING_SW
    [Setup]    Run Keywords    Set Test Variable    ${TARGET_SW_NAME}    ${None}
    ...    AND    Set Test Variable    ${TARGET_SW_DIR}    /home/ute/CLEANING_SW
    ...    AND    Set Test Variable    ${SW_UPDATE_TIMEOUT}    3600
    ...    AND    Set Test Variable    ${ONAIR_TIMEOUT}    900
    ...    AND    Modify Resource Search Order    SWM__SW_update_without_SBTS_verifications

    [Timeout]    90 minutes
    TC__SWM__SW_update_without_SBTS_verifications


_10___CM__Commissioning__Planned_commissioning
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${COMMISSIONING_TIMEOUT}    601
    ...    AND    Set Test Variable    ${EXPECTED_BTS_STATUS}    (?i)NotCommissioned|OnAir
    ...    AND    Modify Resource Search Order    CM__Commissioning__Planned_commissioning
    ...    AND    CM__Commissioning__Planned_commissioning.TC Setup
    TC__CM__Commissioning__Planned_commissioning
    [Teardown]    Run Keywords    CM__Commissioning__Planned_commissioning.TC Teardown
    ...    AND    Restore Resource Search Order

_11___SWM__Upload_swconfig
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${SWCONFIG_PATH}
    ...    /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS1602/swconfigs/swconfig.txt
    ...    AND    Set Test Variable    ${ADDITIONAL_IGNORED_ALARMS}
    ...    [['faultId', '4655', ' alarmId ', '7220'], ['faultId', '4654', 'alarmId', '7220']]
    ...    AND    Modify Resource Search Order    SWM__Upload_swconfig
    ...    AND    SWM__Upload_swconfig.TC Setup
    TC__SWM__Upload_swconfig
    [Teardown]    Run Keywords    SWM__Upload_swconfig.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  CIT Recover Test Line By Power Reset

_12___SWM__SW_download_and_activation__SBTS_to_SBTS______BASE_SW
    [Setup]    Run Keywords    Set Test Variable    ${Target SW name}    ${None}
    ...    AND    Set Test Variable    ${Target SW dir}    /home/ute/BASE_SW
    ...    AND    Set Test Variable    ${SW Update Timeout}    3600
    ...    AND    Set Test Variable    ${Ping loss timeout}    900
    ...    AND    Set Test Variable    ${Ping regain timeout}    1900
    ...    AND    Set Test Variable    ${Ping stable timeout}    370
    ...    AND    Set Test Variable    ${onAir Check Number}    150
    ...    AND    Set Test Variable    ${First Cell On Air Timeout}    35
    ...    AND    Set Test Variable    ${Test Timeout}    139
    ...    AND    Modify Resource Search Order    SWM__SW_download_and_activation__SBTS_to_SBTS
    ...    AND    SWM__SW_download_and_activation__SBTS_to_SBTS.TC Setup

    [Timeout]    90 minutes
    TC__SWM__SW_download_and_activation__SBTS_to_SBTS
    [Teardown]    Run Keywords    SWM__SW_download_and_activation__SBTS_to_SBTS.TC Teardown
    ...    AND    Restore Resource Search Order

_13___SWM__SW_update_without_SBTS_verifications_______BASE_SW
    [Setup]    Run Keywords    Set Test Variable    ${TARGET_SW_NAME}    ${None}
    ...    AND    Set Test Variable    ${TARGET_SW_DIR}    /home/ute/BASE_SW
    ...    AND    Set Test Variable    ${SW_UPDATE_TIMEOUT}    3600
    ...    AND    Set Test Variable    ${ONAIR_TIMEOUT}    900
    ...    AND    Modify Resource Search Order    SWM__SW_update_without_SBTS_verifications

    [Timeout]    90 minutes
    TC__SWM__SW_update_without_SBTS_verifications

_14___SWM__SCF_validation_errors_check
    [Timeout]    14401
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${SKIP_PARAM_RELATION_ERRORS}    ${TRUE}
    ...    AND    SWM__SCF_validation_errors_check.TC Setup
    ...    AND    Modify Resource Search Order    SWM__SCF_validation_errors_check
    TC__SWM__SCF_validation_errors_check
    [Teardown]    Run Keywords    SWM__SCF_validation_errors_check.TC Teardown
    ...    AND    Restore Resource Search Order


_19___COMPA__Uboot_downgrade
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Modify Resource Search Order    COMPA__Uboot_downgrade
    ...    AND    COMPA__Uboot_downgrade.TC Setup
    TC__COMPA__Uboot_downgrade
    [Teardown]    Run Keywords    COMPA__Uboot_downgrade.TC Teardown
    ...    AND    Restore Resource Search Order

_20___SWM__SCF_validation_errors_check
    [Timeout]    14401
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${SKIP_PARAM_RELATION_ERRORS}    ${TRUE}
    ...    AND    SWM__SCF_validation_errors_check.TC Setup
    ...    AND    Modify Resource Search Order    SWM__SCF_validation_errors_check
    ...    AND    Run  sudo ls -l /home/ute/CLEANING_SW
    ...    AND    Run  sudo rm -rf /home/ute/CLEANING_SW
    ...    AND    Run  sudo df -h
    ...    AND    Run  sudo ls -l /home/ute/TARGET_SW
    ...    AND    Run  sudo rm -rf /home/ute/TARGET_SW/*
    TC__SWM__SCF_validation_errors_check
    [Teardown]    Run Keywords    SWM__SCF_validation_errors_check.TC Teardown
    ...    AND    Restore Resource Search Order
    Get Build To VM  ${TARGET_SW_2}  /home/ute/TARGET_SW


_21___SWM__SW_download_and_activation__SBTS_to_SBTS____TARGET_SW
    [Setup]    Run Keywords    Set Test Variable    ${Target SW name}    ${None}
    ...    AND    Set Test Variable    ${Target SW dir}    /home/ute/TARGET_SW
    ...    AND    Set Test Variable    ${SW Update Timeout}    3600
    ...    AND    Set Test Variable    ${Ping loss timeout}    900
    ...    AND    Set Test Variable    ${Ping regain timeout}    1900
    ...    AND    Set Test Variable    ${Ping stable timeout}    370
    ...    AND    Set Test Variable    ${onAir Check Number}    150
    ...    AND    Set Test Variable    ${First Cell On Air Timeout}    35
    ...    AND    Set Test Variable    ${Test Timeout}    139
    ...    AND    Modify Resource Search Order    SWM__SW_download_and_activation__SBTS_to_SBTS
    ...    AND    SWM__SW_download_and_activation__SBTS_to_SBTS.TC Setup

    [Timeout]    90 minutes
    TC__SWM__SW_download_and_activation__SBTS_to_SBTS
    [Teardown]    Run Keywords    SWM__SW_download_and_activation__SBTS_to_SBTS.TC Teardown
    ...    AND    Restore Resource Search Order

_22___SWM__SCF_validation_errors_check
    [Timeout]    14401
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${SKIP_PARAM_RELATION_ERRORS}    ${TRUE}
    ...    AND    SWM__SCF_validation_errors_check.TC Setup
    ...    AND    Modify Resource Search Order    SWM__SCF_validation_errors_check
    TC__SWM__SCF_validation_errors_check
    [Teardown]    Run Keywords    SWM__SCF_validation_errors_check.TC Teardown
    ...    AND    Restore Resource Search Order

_23___LOGS__Snapshot
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${SNAPSHOT_TIMEOUT}    1200
    ...    AND    Set Test Variable    ${ADDITIONAL_IGNORED_ALARMS}
    ...    [['faultId', '4655', ' alarmId ', '7220'], ['faultId', '4654', 'alarmId', '7220']]
    ...    AND    Modify Resource Search Order    LOGS__Snapshot
    ...    AND    LOGS__Snapshot.TC Setup
    TC__LOGS__Snapshot
    [Teardown]    Run Keywords    LOGS__Snapshot.TC Teardown
    ...    AND    Restore Resource Search Order

_24___SWM__DC_SBTS_SOAM_fallback_to_SBTS_SOAM_CONS_RLC__BASE_SW
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${sw_package_path}    /home/ute/BASE_SW
    ...    AND    Set Test Variable    ${SW Update Timeout}    2000
    ...    AND    Set Test Variable    ${BTS is busy timeout for SWR Slave}   901
    ...    AND    Set Test Variable    ${ping_loss_timeout}  301
    ...    AND    Set Test Variable    ${ping_regain_timeout}   901
    ...    AND    Set Test Variable    ${restore_timeout}      601
    ...    AND    Set Test Variable    ${FAULT_4001_TIMEOUT}    15
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    602
    ...    AND    Set Test Variable    ${SKIP_META_CHECK}    True
    ...    AND    Set Test Variable    ${SKIP_BM_CHECK}    True
    ...    AND    Modify Resource Search Order    SWM__DC_SBTS_SOAM_fallback_to_SBTS_SOAM_CONS_RLC
    ...    AND    SWM__DC_SBTS_SOAM_fallback_to_SBTS_SOAM_CONS_RLC.TC Setup
    TC__SWM__DC_SBTS_SOAM_fallback_to_SBTS_SOAM_CONS_RLC
    [Teardown]    Run Keywords    SWM__DC_SBTS_SOAM_fallback_to_SBTS_SOAM_CONS_RLC.TC Teardown
    ...    AND    Restore Resource Search Order

_25___LOGS__Snapshot
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${SNAPSHOT_TIMEOUT}    1200
    ...    AND    Set Test Variable    ${ADDITIONAL_IGNORED_ALARMS}
    ...    [['faultId', '4655', ' alarmId ', '7220'], ['faultId', '4654', 'alarmId', '7220']]
    ...    AND    Set Test Variable    ${cells_LTE_expected_states}
    ...    administrativeState=unlocked, operationalState=enabled, availabilityStatus=degraded, blockingState=Unblocked
    ...    AND    Set Test Variable    ${cells_WCDMA_expected_states}
    ...    operationalState=enabled, availabilityStatus=degraded, blockingState=Unblocked, usageState=Active
    ...    AND    Set Test Variable    ${cells_GSM_expected_states}
    ...    administrativeState=Unlocked, operationalState=enabled, availabilityStatus=degraded, blockingState=Unblocked, usageState=Active
    ...    AND    Modify Resource Search Order    LOGS__Snapshot
    ...    AND    LOGS__Snapshot.TC Setup
    TC__LOGS__Snapshot
    [Teardown]    Run Keywords    LOGS__Snapshot.TC Teardown
    ...    AND    Restore Resource Search Order

_26___COMPA__SSH_snapshot
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    COMPA__SSH_snapshot.TC Setup
    ...    AND    Modify Resource Search Order    COMPA__SSH_snapshot
    TC__COMPA__SSH_snapshot
    [Teardown]    Run Keywords    COMPA__SSH_snapshot.TC Teardown
    ...    AND    Restore Resource Search Order

*** Keywords ***

Map BuildShareTimi01
    Run  sudo mkdir -p /media/BuildShareTimi01
    Run  sudo chown ute:ute /media/BuildShareTimi01
    ${sudo_command}  Catenate  SEPARATOR=  sudo sh -c "echo //10.5.16.78/BuildShareTimi01 /media/BuildShareTimi01/ cifs _netdev,
    ...  noperm,username=userbuild,,nosuid,noexec,password=Aikon_123456*8 0 0 >>/etc/fstab"
    Run  ${sudo_command}
    Run  sudo mount -a
    Run  sudo cp -r /home/ute/testline_configuration/10_18_UTESRANCLOUD1602 /home/ute/
    Run  sudo cp -r /home/ute/testline_configuration/10_18_UTESRANCLOUD1692 /home/ute/
    Run  sudo cp -r /home/ute/testline_configuration/10_18_UTESRANCLOUD1698 /home/ute/
    Run  sudo cp -r /home/ute/testline_configuration/10_18_UTESRANCLOUD1442 /home/ute/
    Run  sudo cp -r /home/ute/testline_configuration/10_18_UTESRANCLOUD1359 /home/ute/
