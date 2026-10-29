*** Settings ***
Force Tags  QCD_MN_SRAN  QCP_SRAN_SBTS  SRAN  CLOUD_SRAN_LWG_10440_1ASIA_2ABIA_1FXDB_1FXJB  STATE_COMMISSIONED
Library           XML  use_lxml=True
Resource    ../../COMPA/test_resources/COMPA__CM_Setup_environment.robot
Resource    ../../COMPA/test_resources/DEV__SBTS_SOAM_installing_using_YAFT.robot
Resource    ../../CIT/test_resources/SWM__SW_update_for_new_RF_unit_uncommissioned.robot
Resource    ../../COMPA/test_resources/COMPA__FDSW_installing_using_YAFT.robot
Resource    ../../COMPA/test_resources/COMPA__FDSW_upgrade_to_SBTS_SOAM.robot
Resource    ../../CIT/test_resources/CM__Commissioning__Planned_commissioning.robot
Resource    ../../CIT/test_resources/CM__Commissioning__Planned_commissioning_without_initial_SBTS_verification.robot
Resource    ../../COMPA/test_resources/SWM__SW_update_for_new_RF_unit.robot
Resource    ../../CIT/test_resources/SWM__SCF_validation_errors_check.robot
Resource    ../../CIT/test_resources/LOGS__Snapshot.robot
Resource    ../../COMPA/test_resources/COMPA__SBTS_SOAM_fallback_to_FDSW_RLC.robot
Resource    ../../COMPA/test_resources/COMPA__FDSW_snapshot.robot
Resource    ../../COMPA/test_resources/COMPA__SSH_snapshot.robot
Resource    ../../CIT/test_resources/SWM__SW_download_and_activation__SBTS_to_SBTS.robot
Resource    ../../CIT/test_resources/SWM__Upload_swconfig.robot
Resource    ../../COMPA/test_resources/DEV__Commissioning_for_SBTS_with_alarms.robot
Resource    ../../COMPA/test_resources/DEV__SBTS_Testline_recovery.robot
Resource    ../../COMPA/test_resources/COMPA__Uboot_downgrade.robot
Resource    ../../CIT/test_resources/SWM__SW_update_without_SBTS_verifications.robot
Documentation  UUF tests.
Suite Setup   Run keywords    Map BuildShareTimi01

*** Variables ***
${HW_LOCATION_CODE}      Timisoara
${REQUEST_SCF_SCOUT}    ${FALSE}
${SCOUT_TL_NAME}    10_18_UTESRANCLOUD440


*** Test Cases ***
__0__COMPA__CM_Setup_environment
    TC__COMPA__CM_Setup_environment

__1__DEV__SBTS_SOAM_installing_using_YAFT___CLEANING_SW
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${TARGET_SW_DIRECTORY}    /home/ute/CLEANING_SW
    ...    AND    Set Test Variable    ${SWCONFIG_PATH}
    ...    /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS1440/swconfigs/swconfig.txt
    ...    AND    Set Test Variable    ${WAIT_SBTS_REBOOT}    300
    ...    AND    Modify Resource Search Order    DEV__SBTS_SOAM_installing_using_YAFT
    ...    AND    DEV__SBTS_SOAM_installing_using_YAFT.TC Setup
    TC__DEV__SBTS_SOAM_installing_using_YAFT
    [Teardown]    Run Keywords    DEV__SBTS_SOAM_installing_using_YAFT.TC Teardown
    ...    AND    Restore Resource Search Order

__2__SWM__SW_update_for_new_RF_unit_uncommissioned___CLEANING_SW
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${SW Update Timeout}    401
    ...    AND    Set Test Variable    ${proceduralStatus Check Number}    61
    ...    AND    Set Test Variable    ${Target SW dir}    /home/ute/CLEANING_SW
    ...    AND    Set Test Variable    ${PING_STABLE_TIMEOUT}    403
    ...    AND    Modify Resource Search Order    SWM__SW_update_for_new_RF_unit_uncommissioned
    ...    AND    SWM__SW_update_for_new_RF_unit_uncommissioned.TC Setup
    TC__SWM__SW_update_for_new_RF_unit_uncommissioned
    [Teardown]    Run Keywords    SWM__SW_update_for_new_RF_unit_uncommissioned.TC Teardown
    ...    AND    Restore Resource Search Order

__3__CM__Commissioning__Planned_commissioning_without_initial_SBTS_verification
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

__4__SWM__SW_update_for_new_RF_unit___CLEANING_SW
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

__5__SWM__SCF_validation_errors_check
    [Timeout]    14401
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${SKIP_PARAM_RELATION_ERRORS}    ${TRUE}
    ...    AND    SWM__SCF_validation_errors_check.TC Setup
    ...    AND    Modify Resource Search Order    SWM__SCF_validation_errors_check
    TC__SWM__SCF_validation_errors_check
    [Teardown]    Run Keywords    SWM__SCF_validation_errors_check.TC Teardown
    ...    AND    Restore Resource Search Order

__6__SWM__Upload_swconfig
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${SWCONFIG_PATH}
    ...    /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS1440/swconfigs/swconfig.txt
    ...    AND    Set Test Variable    ${ADDITIONAL_IGNORED_ALARMS}
    ...    [['faultId', '4655', ' alarmId ', '7220'], ['faultId', '4654', 'alarmId', '7220']]
    ...    AND    Modify Resource Search Order    SWM__Upload_swconfig
    ...    AND    SWM__Upload_swconfig.TC Setup
    TC__SWM__Upload_swconfig
    [Teardown]    Run Keywords    SWM__Upload_swconfig.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  CIT Recover Test Line By Power Reset

__7__COMPA__FDSW_installing_using_YAFT___BASE_SW
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${SOFTWARE_PATTERN}    FDSW
    ...    AND    Set Test Variable    ${SOFTWARE_DIRECTORY}    /home/ute/BASE_SW/
    ...    AND    Set Test Variable    ${SWCONFIG_PATH}
    ...    /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS1440/swconfigs/swconfig.txt
    ...    AND    Set Test Variable    ${TIMEOUT_FOR_RESET_WAITING}   369
    ...    AND    Modify Resource Search Order    COMPA__FDSW_installing_using_YAFT
    ...    AND    COMPA__FDSW_installing_using_YAFT.TC Setup
    TC__COMPA__FDSW_installing_using_YAFT
    [Teardown]    Run Keywords    COMPA__FDSW_installing_using_YAFT.TC Teardown
    ...    AND    Restore Resource Search Order

__8__COMPA__FDSW_installing_using_YAFT___BASE_SW
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${SOFTWARE_PATTERN}    FDSW
    ...    AND    Set Test Variable    ${SOFTWARE_DIRECTORY}    /home/ute/BASE_SW
    ...    AND    Set Test Variable    ${SWCONFIG_PATH}
    ...    /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS1440/swconfigs/swconfig.txt
    ...    AND    Set Test Variable    ${TIMEOUT_FOR_RESET_WAITING}   369
    ...    AND    Modify Resource Search Order    COMPA__FDSW_installing_using_YAFT
    ...    AND    COMPA__FDSW_installing_using_YAFT.TC Setup
    TC__COMPA__FDSW_installing_using_YAFT
    [Teardown]    Run Keywords    COMPA__FDSW_installing_using_YAFT.TC Teardown
    ...    AND    Restore Resource Search Order


__10__COMPA__FDSW_upgrade_to_SBTS_SOAM___TARGET_SW
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${TARGET_SW_DIR}    /home/ute/TARGET_SW
    ...    AND    Set Test Variable    ${SWCONFIG_PATH}
    ...    /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS1440/swconfigs/swconfig.txt
    ...    AND    Set Test Variable    ${ADMIN_SETUP_TIMEOUT}    2401
    ...    AND    Set Test Variable    ${RM_DETECTION_TIMEOUT}    21 min
    ...    AND    Set Test Variable    ${UPGRADE_TIMEOUT_ASYNC}    2001
    ...    AND    Modify Resource Search Order    COMPA__FDSW_upgrade_to_SBTS_SOAM
    ...    AND    COMPA__FDSW_upgrade_to_SBTS_SOAM.TC Setup
    TC__COMPA__FDSW_upgrade_to_SBTS_SOAM
    [Teardown]    Run Keywords    COMPA__FDSW_upgrade_to_SBTS_SOAM.TC Teardown
    ...    AND    Restore Resource Search Order


__11__SWM__SW_update_for_new_RF_unit_uncommissioned___TARGET_SW
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${SW Update Timeout}    401
    ...    AND    Set Test Variable    ${proceduralStatus Check Number}    61
    ...    AND    Set Test Variable    ${Target SW dir}    /home/ute/TARGET_SW
    ...    AND    Set Test Variable    ${PING_STABLE_TIMEOUT}    403
    ...    AND    Modify Resource Search Order    SWM__SW_update_for_new_RF_unit_uncommissioned
    ...    AND    SWM__SW_update_for_new_RF_unit_uncommissioned.TC Setup
    TC__SWM__SW_update_for_new_RF_unit_uncommissioned
    [Teardown]    Run Keywords    SWM__SW_update_for_new_RF_unit_uncommissioned.TC Teardown
    ...    AND    Restore Resource Search Order



__12__CM__Commissioning__Planned_commissioning_without_initial_SBTS_verification
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


__13__SWM__SW_update_for_new_RF_unit___TARGET_SW
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${TARGET_SW_DIR}    /home/ute/TARGET_SW/
    ...    AND    Set Test Variable    ${SW Update Timeout}    401
    ...    AND    Set Test Variable    ${onAir Check Number}    401
    ...    AND    Set Test Variable    ${RM_DETECTION_TIMEOUT}    15 min
    ...    AND    Modify Resource Search Order    SWM__SW_update_for_new_RF_unit
    ...    AND    SWM__SW_update_for_new_RF_unit.TC Setup
    TC__SWM__SW_update_for_new_RF_unit
    [Teardown]    Run Keywords    SWM__SW_update_for_new_RF_unit.TC Teardown
    ...    AND    Restore Resource Search Order


__14__SWM__SCF_validation_errors_check
    [Timeout]    14401
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${SKIP_PARAM_RELATION_ERRORS}    ${TRUE}
    ...    AND    SWM__SCF_validation_errors_check.TC Setup
    ...    AND    Modify Resource Search Order    SWM__SCF_validation_errors_check
    TC__SWM__SCF_validation_errors_check
    [Teardown]    Run Keywords    SWM__SCF_validation_errors_check.TC Teardown
    ...    AND    Restore Resource Search Order


__15__Automated__LOGS__Snapshot
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


__16__Automated__COMPA__SBTS_SOAM_fallback_to_FDSW_RLC
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${PING_REGAIN_TIMEOUT}    241
    ...    AND    Set Test Variable    ${MAX_DOWNTIME}    361
    ...    AND    Modify Resource Search Order    COMPA__SBTS_SOAM_fallback_to_FDSW_RLC
    ...    AND    COMPA__SBTS_SOAM_fallback_to_FDSW_RLC.TC Setup
    TC__COMPA__SBTS_SOAM_fallback_to_FDSW_RLC
    [Teardown]    Run Keywords    COMPA__SBTS_SOAM_fallback_to_FDSW_RLC.TC Teardown
    ...    AND    Restore Resource Search Order

__17__Automated__COMPA__FDSW_Snapshot
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Modify Resource Search Order    COMPA__FDSW_Snapshot
    ...    AND    COMPA__FDSW_Snapshot.TC Setup
    TC__COMPA__FDSW_Snapshot
    [Teardown]    Run Keywords    COMPA__FDSW_Snapshot.TC Teardown
    ...    AND    Restore Resource Search Order

__18__COMPA__SSH_snapshot
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
    Run  sudo cp -r /home/ute/testline_configuration/10_18_UTESRANCLOUD1440 /home/ute/
