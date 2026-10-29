*** Settings ***
Library           XML  use_lxml=True
Resource    ../../COMPA/test_resources/COMPA__CM_Setup_environment.robot
Resource    ../../CIT/test_resources/SWM__SCF_validation_errors_check.robot
Resource    ../../CIT/test_resources/LOGS__Snapshot.robot
Resource    ../../COMPA/test_resources/COMPA__SSH_snapshot.robot
Resource    ../../CIT/test_resources/SWM__SW_download_and_activation__SBTS_to_SBTS.robot
Resource    ../../COMPA/test_resources/SWM__DC_SBTS_SOAM_fallback_to_SBTS_SOAM_CONS_RLC.robot
Resource    ../../COMPA/test_resources/COMPA__Uboot_downgrade.robot
Resource    ../../CIT/test_resources/SWM__Upload_swconfig.robot
Resource    ../../CIT/test_resources/SWM__Check_swconfig_file_presence.robot
Resource    ../../CIT/test_resources/SWM__SW_update_without_SBTS_verifications.robot
Documentation  Compa tests.

Suite Setup   Run keywords    Map BuildShareTimi01

*** Variables ***
@{CUSTOMERS_LIST}         GENERIC
# ${DISABLE_WATCHDOG}    ${TRUE}

*** Test Cases ***
_0___COMPA__CM_Setup_environment
    TC__COMPA__CM_Setup_environment

_1_Upload_swconfig
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${SWCONFIG_PATH}
    ...    /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS1442/swconfigs/swconfig.txt
    ...    AND    Set Test Variable    ${ADDITIONAL_IGNORED_ALARMS}
    ...    [['faultId', '4655', ' alarmId ', '7220'], ['faultId', '4654', 'alarmId', '7220']]
    ...    AND    Modify Resource Search Order    SWM__Upload_swconfig
    ...    AND    SWM__Upload_swconfig.TC Setup
    TC__SWM__Upload_swconfig
    [Teardown]    Run Keywords    SWM__Upload_swconfig.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  CIT Recover Test Line By Power Reset

_2_check_swconfig
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Modify Resource Search Order    SWM__Check_swconfig_file_presence
    ...    AND    SWM__Check_swconfig_file_presence.TC Setup
    TC__SWM__Check_swconfig_file_presence
    [Teardown]    Run Keywords    SWM__Check_swconfig_file_presence.TC Teardown
    ...    AND    Restore Resource Search Order

_3___SWM__SW_update_without_SBTS_verifications______BASE_SW
    [Setup]    Run Keywords    Set Test Variable    ${TARGET_SW_NAME}    ${None}
    ...    AND    Set Test Variable    ${TARGET_SW_DIR}    /home/ute/BASE_SW
    ...    AND    Set Test Variable    ${SW_UPDATE_TIMEOUT}    3600
    ...    AND    Set Test Variable    ${ONAIR_TIMEOUT}    900
    ...    AND    Modify Resource Search Order    SWM__SW_update_without_SBTS_verifications
    [Timeout]    90 minutes
    TC__SWM__SW_update_without_SBTS_verifications


_4___SWM__SCF_validation_errors_check
    [Timeout]    14401
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${SKIP_PARAM_RELATION_ERRORS}    ${TRUE}
    ...    AND    SWM__SCF_validation_errors_check.TC Setup
    ...    AND    Modify Resource Search Order    SWM__SCF_validation_errors_check
    TC__SWM__SCF_validation_errors_check
    [Teardown]    Run Keywords    SWM__SCF_validation_errors_check.TC Teardown
    ...    AND    Restore Resource Search Order

_5___COMPA__Uboot_downgrade
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
    TC__SWM__SCF_validation_errors_check
    [Teardown]    Run Keywords    SWM__SCF_validation_errors_check.TC Teardown
    ...    AND    Restore Resource Search Order


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
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    3
    ...    AND    Set Test Variable    ${SKIP_META_CHECK}    True
    ...    AND    Set Test Variable    ${SKIP_BM_CHECK}    True
    ...    AND    Set Test Variable    ${PING_STABLE_TIMEOUT}   403
    ...    AND    Set Test Variable    ${SECOND_RESET_AFTER_FALLBACK_TIMEOUT}   651
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
    Run  sudo cp -r /home/ute/testline_configuration/10_18_UTESRANCLOUD1442 /home/ute/
