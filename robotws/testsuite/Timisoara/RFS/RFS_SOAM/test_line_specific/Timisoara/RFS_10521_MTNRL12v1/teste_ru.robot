*** Settings ***
Force tags    QCD_MN_RAN    QCP_RAN_VRF    SBTS00    CLOUD_HRAN_RFS_MTNRL12
Documentation  Test Suite
Resource    ../../../test_resources/SBTS_SBTS__SWM__RU_SW_Upgrade.robot


*** Variables ***
${SCF_ID}    01
${ALM_PTH}    ${CURDIR}/../../../test_resources/tc_variables
${SCOUT_TL_NAME}    10_18_UTESRANRFSMTNRL12_1



*** Test Cases ***


[1][1.0] Automated_SBTS_SBTS__SWM__RU_SW_Upgrade_Together_per_band
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__swm__ru_sw_upgrade_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    1
    ...    AND    Set Test Variable    ${Target SW dir}    /home/ute/Downloads
    ...    AND    Set Test Variable    ${Target SW name}
    ...    AND    Set Test Variable    ${Initial SW name}    ${SW_1}
    ...    AND    Set Test Variable    ${Intermediate SW name}    ${SW_2}
    ...    AND    Set Test Variable    ${SW Update Timeout}    3000
    ...    AND    Set Test Variable    ${BTS_MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${FORCE_CURRENT_SW_DL}    True
    ...    AND    Set Test Variable    ${Remote target SW path}    None
    ...    AND    Set Test Variable    ${RFS_CUSTOM_SHARE_SW_DL}    False
    ...    AND    Set Test Variable    ${BTS_SCF_VALIDATION}    True
    ...    AND    Set Test Variable    ${CB010780_sequentialRuSwUpgrade}    false
    ...    AND    Set Test Variable    ${CB013660_ruPhaseSwActivationResetPolicy}    Together per band
    ...    AND    Set Test Variable    ${CB010780_NO_UPGRADE_RM_SN_LIST}
    ...    AND    Set Test Variable    ${CB013660_NO_UPGRADE_RM_SN_LIST}
    ...    AND    Set Test Variable    ${CB013660_DU_RM_SN_LIST}
    ...    AND    Set Test Variable    ${CB013660_RU_RM_SN_LIST}
    ...    AND    Set Test Variable    ${RU_FIRST_GROUP_RESET_RM_SN_LIST}
    ...    AND    Set Test Variable    ${RU_SECOND_GROUP_RESET_RM_SN_LIST}
    ...    AND    Set Test Variable    ${CHANGE_RM_UPGRADE_PARAMETER}    False
    ...    AND    Set Test Variable    ${CB007447_SHARED_RM_SN_EXCEPTIONS_LIST}
    ...    AND    Set Test Variable    ${RECOVER_BTS_SW}    False
    ...    AND    Set Test Variable    ${SECONDARY_CONTROLLER_BTS_SW_UPDATE}    True

    ...    AND    SBTS_SBTS__SWM__RU_SW_Upgrade.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__SWM__RU_SW_Upgrade
    ...    AND    Set Library Search Order    SBTS_SBTS__SWM__RU_SW_Upgrade
    TC__SBTS_SBTS__SWM__RU_SW_Upgrade
    [Teardown]    Run Keywords    SBTS_SBTS__SWM__RU_SW_Upgrade.TC Teardown
    ...    AND    Restore Resource Search Order

[1][1.0] Automated_SBTS_SBTS__SWM__RU_SW_Upgrade_by_user_configuration
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__swm__ru_sw_upgrade_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    1
    ...    AND    Set Test Variable    ${Target SW dir}    /home/ute/Documents
    ...    AND    Set Test Variable    ${Target SW name}
    ...    AND    Set Test Variable    ${Initial SW name}    ${SW_1}
    ...    AND    Set Test Variable    ${Intermediate SW name}    ${SW_2}
    ...    AND    Set Test Variable    ${SW Update Timeout}    3000
    ...    AND    Set Test Variable    ${BTS_MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${FORCE_CURRENT_SW_DL}    True
    ...    AND    Set Test Variable    ${Remote target SW path}    None
    ...    AND    Set Test Variable    ${RFS_CUSTOM_SHARE_SW_DL}    False
    ...    AND    Set Test Variable    ${BTS_SCF_VALIDATION}    True
    ...    AND    Set Test Variable    ${CB010780_sequentialRuSwUpgrade}    false
    ...    AND    Set Test Variable    ${CB013660_ruPhaseSwActivationResetPolicy}    User configuration
    ...    AND    Set Test Variable    ${CB010780_NO_UPGRADE_RM_SN_LIST}
    ...    AND    Set Test Variable    ${CB013660_NO_UPGRADE_RM_SN_LIST}
    ...    AND    Set Test Variable    ${CB013660_DU_RM_SN_LIST}
    ...    AND    Set Test Variable    ${CB013660_RU_RM_SN_LIST}
    ...    AND    Set Test Variable    ${RU_FIRST_GROUP_RESET_RM_SN_LIST}
    ...    AND    Set Test Variable    ${RU_SECOND_GROUP_RESET_RM_SN_LIST}
    ...    AND    Set Test Variable    ${CHANGE_RM_UPGRADE_PARAMETER}    False
    ...    AND    Set Test Variable    ${CB007447_SHARED_RM_SN_EXCEPTIONS_LIST}
    ...    AND    Set Test Variable    ${RECOVER_BTS_SW}    False
    ...    AND    Set Test Variable    ${SECONDARY_CONTROLLER_BTS_SW_UPDATE}    True

    ...    AND    SBTS_SBTS__SWM__RU_SW_Upgrade.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__SWM__RU_SW_Upgrade
    ...    AND    Set Library Search Order    SBTS_SBTS__SWM__RU_SW_Upgrade
    TC__SBTS_SBTS__SWM__RU_SW_Upgrade
    [Teardown]    Run Keywords    SBTS_SBTS__SWM__RU_SW_Upgrade.TC Teardown
    ...    AND    Restore Resource Search Order

