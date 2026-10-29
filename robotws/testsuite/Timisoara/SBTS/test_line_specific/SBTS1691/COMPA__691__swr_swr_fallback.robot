*** Settings ***
Library           XML  use_lxml=True
Resource    ../../COMPA/test_resources/COMPA__CM_Setup_environment.robot
Resource    ../../COMPA/test_resources/DEV__SBTS_SOAM_installing_using_YAFT.robot
Resource    ../../CIT/test_resources/SWM__SW_update_for_new_RF_unit_uncommissioned.robot
Resource    ../../COMPA/test_resources/COMPA__FDSW_installing_using_YAFT.robot
Resource    ../../COMPA/test_resources/COMPA__FDSW_upgrade_to_SBTS_SOAM.robot
Resource    ../../CIT/test_resources/CM__Commissioning__Planned_commissioning.robot
Resource    ../../COMPA/test_resources/SWM__SW_update_for_new_RF_unit.robot
Resource    ../../CIT/test_resources/SWM__SCF_validation_errors_check.robot
Resource    ../../CIT/test_resources/LOGS__Snapshot.robot
Resource    ../../COMPA/test_resources/COMPA__SBTS_SOAM_fallback_to_FDSW_RLC.robot
Resource    ../../COMPA/test_resources/COMPA__FDSW_snapshot.robot
Resource    ../../COMPA/test_resources/COMPA__SSH_snapshot.robot
Resource    ../../CIT/test_resources/SWM__SW_download_and_activation__SBTS_to_SBTS.robot
Resource    ../../COMPA/test_resources/SWM__SBTS_SOAM_fallback_to_SBTS_SOAM_CONS_RLC.robot
Resource    ../../CIT/test_resources/CM__Commissioning__Planned_commissioning_without_initial_SBTS_verification.robot
Resource    ../../COMPA/test_resources/COMPA__Uboot_downgrade.robot
Resource    ../../CIT/test_resources/SWM__SW_update_without_SBTS_verifications.robot
Resource    ../../CIT/test_resources/SWM__Upload_swconfig.robot
Documentation  Compa tests.
Suite Setup   Run keywords    Map BuildShareTimi01

*** Variables ***
${SCF_ID}    01
# ${DISABLE_WATCHDOG}    ${TRUE}


*** Test Cases ***
COMPA__CM_Setup_environment
    TC__COMPA__CM_Setup_environment

__1__SWM__Upload_swconfig
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${SWCONFIG_PATH}
    ...    /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS1691/swconfigs/swconfig.txt
    ...    AND    Set Test Variable    ${ADDITIONAL_IGNORED_ALARMS}
    ...    [['faultId', '4655', ' alarmId ', '7220'], ['faultId', '4654', 'alarmId', '7220']]
    ...    AND    Modify Resource Search Order    SWM__Upload_swconfig
    ...    AND    SWM__Upload_swconfig.TC Setup
    TC__SWM__Upload_swconfig
    [Teardown]    Run Keywords    SWM__Upload_swconfig.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  CIT Recover Test Line By Power Reset

__2__SWM__SW_update_without_SBTS_verifications__BASE_SW
    [Setup]    Run Keywords    Set Test Variable    ${TARGET_SW_NAME}    ${None}
    ...    AND    Set Test Variable    ${TARGET_SW_DIR}    /home/ute/BASE_SW
    ...    AND    Set Test Variable    ${SW_UPDATE_TIMEOUT}    3600
    ...    AND    Set Test Variable    ${ONAIR_TIMEOUT}    900
    ...    AND    Modify Resource Search Order    SWM__SW_update_without_SBTS_verifications

    [Timeout]    90 minutes
    TC__SWM__SW_update_without_SBTS_verifications

__3__SWM__SCF_validation_errors_check
    [Timeout]    14401
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${SKIP_PARAM_RELATION_ERRORS}    ${TRUE}
    ...    AND    SWM__SCF_validation_errors_check.TC Setup
    ...    AND    Modify Resource Search Order    SWM__SCF_validation_errors_check
    TC__SWM__SCF_validation_errors_check
    [Teardown]    Run Keywords    SWM__SCF_validation_errors_check.TC Teardown
    ...    AND    Restore Resource Search Order

__4__SWM__SCF_validation_errors_check
    [Timeout]    14401
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${SKIP_PARAM_RELATION_ERRORS}    ${TRUE}
    ...    AND    SWM__SCF_validation_errors_check.TC Setup
    ...    AND    Modify Resource Search Order    SWM__SCF_validation_errors_check
    TC__SWM__SCF_validation_errors_check
    [Teardown]    Run Keywords    SWM__SCF_validation_errors_check.TC Teardown
    ...    AND    Restore Resource Search Order


__10__COMPA__Uboot_downgrade
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Modify Resource Search Order    COMPA__Uboot_downgrade
    ...    AND    COMPA__Uboot_downgrade.TC Setup
    TC__COMPA__Uboot_downgrade
    [Teardown]    Run Keywords    COMPA__Uboot_downgrade.TC Teardown
    ...    AND    Restore Resource Search Order


__11__SWM__SCF_validation_errors_check
    [Timeout]    14401
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${SKIP_PARAM_RELATION_ERRORS}    ${TRUE}
    ...    AND    SWM__SCF_validation_errors_check.TC Setup
    ...    AND    Modify Resource Search Order    SWM__SCF_validation_errors_check
    TC__SWM__SCF_validation_errors_check
    [Teardown]    Run Keywords    SWM__SCF_validation_errors_check.TC Teardown
    ...    AND    Restore Resource Search Order


__12__SWM__SW_download_and_activation__SBTS_to_SBTS___TARGET_SW
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

__13__SWM__SCF_validation_errors_check
    [Timeout]    14401
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${SKIP_PARAM_RELATION_ERRORS}    ${TRUE}
    ...    AND    SWM__SCF_validation_errors_check.TC Setup
    ...    AND    Modify Resource Search Order    SWM__SCF_validation_errors_check
    TC__SWM__SCF_validation_errors_check
    [Teardown]    Run Keywords    SWM__SCF_validation_errors_check.TC Teardown
    ...    AND    Restore Resource Search Order

__14__LOGS__Snapshot
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

__15__SWM__SBTS_SOAM_fallback_to_SBTS_SOAM_CONS_RLC
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${MODULES_RESTORE_TIMEOUT}    7m
    ...    AND    Set Test Variable    ${CELLS_RESTORE_TIMEOUT}    8m
   ...    AND    Set Test Variable    ${PING_STABLE_TIMEOUT}    901
    ...    AND    Modify Resource Search Order    SWM__SBTS_SOAM_fallback_to_SBTS_SOAM_CONS_RLC
    ...    AND    SWM__SBTS_SOAM_fallback_to_SBTS_SOAM_CONS_RLC.TC Setup
    TC__SWM__SBTS_SOAM_fallback_to_SBTS_SOAM_CONS_RLC
    [Teardown]    Run Keywords    SWM__SBTS_SOAM_fallback_to_SBTS_SOAM_CONS_RLC.TC Teardown
    ...    AND    Restore Resource Search Order

__16__LOGS__Snapshot
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


__17__COMPA__SSH_snapshot
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
    Run  sudo cp -r /home/ute/testline_configuration/10_18_UTESRANCLOUD1691 /home/ute/
