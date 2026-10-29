
*** Settings ***
Force tags    QCD_MN_RAN    QCP_RAN_VRF    SBTS00    CLOUD_HRAN_RFS_MTNRL12
Documentation  Test Suite
Resource    ../../../test_resources/SBTS_SBTS__SWM__RU_SW_Upgrade.robot
Resource    ../../../test_resources/SBTS_SBTS__STATE__Access_to_BTS_via_Shared_RMOD_CB013910.robot
Resource    ../../../test_resources/SBTS_SBTS__STATE__Checking_mandatory_parameter_converted_to_optional_CB013033.robot
Resource    ../../../test_resources/SBTS_SBTS__SWM__SW_Update_Rollback_memory_consumption_CB015315_using_Admin_CLI.robot

*** Variables ***
${SCF_ID}    01
${ALM_PTH}    ${CURDIR}/../../../test_resources/tc_variables
${SCOUT_TL_NAME}    10_18_UTESRANRFSMTNRL12_1
&{IGNORED_ALARM1}    faultId=4401


*** Test Cases ***


[1][1.0] Automated_SBTS_SBTS__SWM__RU_SW_Upgrade_Together_per_band
    [Timeout]    28800
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__swm__ru_sw_upgrade_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
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
    ...    AND    Set Test Variable    ${RECOVER_BTS_SW}    True
    ...    AND    Set Test Variable    ${SECONDARY_CONTROLLER_BTS_SW_UPDATE}    False
    ...    AND    Append To List  ${test_alarms_list}[MASTER_IGNORED_ALARMS_CNI_127210]  ${IGNORED_ALARM1}
    ...    AND    Append To List  ${test_alarms_list}[SLAVE_IGNORED_ALARMS_CNI_127210]  ${IGNORED_ALARM1}

    ...    AND    SBTS_SBTS__SWM__RU_SW_Upgrade.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__SWM__RU_SW_Upgrade
    ...    AND    Set Library Search Order    SBTS_SBTS__SWM__RU_SW_Upgrade
    TC__SBTS_SBTS__SWM__RU_SW_Upgrade
    [Teardown]    Run Keywords    SBTS_SBTS__SWM__RU_SW_Upgrade.TC Teardown
    ...    AND    Restore Resource Search Order

[1][1.0] Automated_SBTS_SBTS__SWM__RU_SW_Upgrade_by_user_configuration
    [Timeout]    28800
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__swm__ru_sw_upgrade_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
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
    ...    AND    Set Test Variable    ${RECOVER_BTS_SW}    True
    ...    AND    Set Test Variable    ${SECONDARY_CONTROLLER_BTS_SW_UPDATE}    False
    ...    AND    Append To List  ${test_alarms_list}[MASTER_IGNORED_ALARMS_CNI_127210]  ${IGNORED_ALARM1}
    ...    AND    Append To List  ${test_alarms_list}[SLAVE_IGNORED_ALARMS_CNI_127210]  ${IGNORED_ALARM1}

    ...    AND    SBTS_SBTS__SWM__RU_SW_Upgrade.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__SWM__RU_SW_Upgrade
    ...    AND    Set Library Search Order    SBTS_SBTS__SWM__RU_SW_Upgrade
    TC__SBTS_SBTS__SWM__RU_SW_Upgrade
    [Teardown]    Run Keywords    SBTS_SBTS__SWM__RU_SW_Upgrade.TC Teardown
    ...    AND    Restore Resource Search Order

[1][2.0] Memory used by CLI for SW upgrade command with SW activation
    [Timeout]    28800
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__swm__sw_update_rollback_memory_consumption_cb015315_using_admin_cli_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${BTS SW Update}    BTS1
    ...    AND    Set Test Variable    ${BTS_SW_Rollback}    BTS1
    ...    AND    Set Test Variable    ${Target SW name BTS1}    None
    ...    AND    Set Test Variable    ${Target SW dir BTS1}    /home/ute/btsauto/TARGET_SW_MASTER
    ...    AND    Set Test Variable    ${Target SW name BTS2}    None
    ...    AND    Set Test Variable    ${Target SW dir BTS2}    /home/ute/btsauto/TARGET_SW_SLAVE
    ...    AND    Set Test Variable    ${Target SW name BTS3}    None
    ...    AND    Set Test Variable    ${Target SW dir BTS3}    /home/ute/btsauto/TARGET_SW_SLAVE1
    ...    AND    Set Test Variable    ${Target SW name BTS4}    None
    ...    AND    Set Test Variable    ${Target SW dir BTS4}    /home/ute/btsauto/TARGET_SW_SLAVE2
    ...    AND    Set Test Variable    ${Activate SW}    True
    ...    AND    Set Test Variable    ${SW Update Timeout}    3000
    ...    AND    Set Test Variable    ${BTS_RESET_UPDATE_WRN_THR}    900
    ...    AND    Set Test Variable    ${BTS_RESET_ROLLBACK_WRN_THR}    900
    ...    AND    Set Test Variable    ${BTS_MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${BTS_SCF_VALIDATION}    True
    ...    AND    Set Test Variable    ${FORCE_TARGET_BTS_SW_DL}    True
    ...    AND    Set Test Variable    ${WFT_BTS1_target_sw}
    ...    AND    Set Test Variable    ${WFT_BTS2_target_sw}
    ...    AND    Set Test Variable    ${WFT_BTS3_target_sw}
    ...    AND    Set Test Variable    ${WFT_BTS4_target_sw}
    ...    AND    Set Test Variable    ${Remote target SW path BTS1}    None
    ...    AND    Set Test Variable    ${Remote target SW path BTS2}    None
    ...    AND    Set Test Variable    ${Remote target SW path BTS3}    None
    ...    AND    Set Test Variable    ${Remote target SW path BTS4}    None
    ...    AND    Set Test Variable    ${RFS_CUSTOM_SHARE_SW_DL}    False
    ...    AND    Set Test Variable    ${CB015052_CHECK}    False
    ...    AND    Set Test Variable    ${tempRadioMasterTriggerTime}    0
    ...    AND    Set Test Variable    ${RESTORE_TARGET_SW}    False
    ...    AND    Set Test Variable    ${MEMORY_THRESHOLD}    10
    ...    AND    Append To List  ${test_alarms_list}[MASTER_IGNORED_ALARMS_CNI_127210]  ${IGNORED_ALARM1}
    ...    AND    Append To List  ${test_alarms_list}[SLAVE_IGNORED_ALARMS_CNI_127210]  ${IGNORED_ALARM1}

    ...    AND    SBTS_SBTS__SWM__SW_Update_Rollback_memory_consumption_CB015315_using_Admin_CLI.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__SWM__SW_Update_Rollback_memory_consumption_CB015315_using_Admin_CLI
    ...    AND    Set Library Search Order    SBTS_SBTS__SWM__SW_Update_Rollback_memory_consumption_CB015315_using_Admin_CLI
    TC__SBTS_SBTS__SWM__SW_Update_Rollback_memory_consumption_CB015315_using_Admin_CLI
    [Teardown]    Run Keywords    SBTS_SBTS__SWM__SW_Update_Rollback_memory_consumption_CB015315_using_Admin_CLI.TC Teardown
    ...    AND    Restore Resource Search Order


[1][1.0] Automated_RFS_SBTS_SBTS_SSH_Access_to_BTS_via_Shared_RU_Fronthaul_Network_CB013910
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__access_to_bts_via_shared_rmod_cb013910_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${BTS_LIST}    ALL
    ...    AND    Set Test Variable    ${RM_SERIAL_NUMBER_LIST}    ALL
    ...    AND    Set Test Variable    ${BTS1_EIF_down}    M12-vlan51-down
    ...    AND    Set Test Variable    ${BTS1_EIF_pass_down}    vlan-down-M12
    ...    AND    Set Test Variable    ${BTS1_EIF_up}    M12-vlan51-up
    ...    AND    Set Test Variable    ${BTS1_EIF_pass_up}    vlan-up-M12
    ...    AND    Set Test Variable    ${BTS1_EIF_Switch_IpAddress}    10.255.10.24
    ...    AND    Set Test Variable    ${BTS2_EIF_down}    M12-vlan41-down
    ...    AND    Set Test Variable    ${BTS2_EIF_pass_down}    vlan-down-M12
    ...    AND    Set Test Variable    ${BTS2_EIF_up}    M12-vlan41-up
    ...    AND    Set Test Variable    ${BTS2_EIF_pass_up}    vlan-up-M12
    ...    AND    Set Test Variable    ${BTS2_EIF_Switch_IpAddress}    10.255.10.24
    ...    AND    Set Test Variable    ${ERROR_CASE_BTS_LIST}    BTS2

    ...    AND    SBTS_SBTS__STATE__Access_to_BTS_via_Shared_RMOD_CB013910.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__STATE__Access_to_BTS_via_Shared_RMOD_CB013910
    ...    AND    Set Library Search Order    SBTS_SBTS__STATE__Access_to_BTS_via_Shared_RMOD_CB013910
    TC__SBTS_SBTS__STATE__Access_to_BTS_via_Shared_RMOD_CB013910
    [Teardown]    Run Keywords    SBTS_SBTS__STATE__Access_to_BTS_via_Shared_RMOD_CB013910.TC Teardown
    ...    AND    Restore Resource Search Order

[1][1.0] Automated_RFS_SBTS_SBTS_STATE_Checking_mandatory_parameter_converted_to_optional_CB013033
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__checking_mandatory_parameter_converted_to_optional_CB013033.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${BTS_LIST}    ALL
    ...    AND    Set Test Variable    ${RAT_LIST}    ALL

    ...    AND    SBTS_SBTS__STATE__Checking_mandatory_parameter_converted_to_optional_CB013033.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__STATE__Checking_mandatory_parameter_converted_to_optional_CB013033
    ...    AND    Set Library Search Order    SBTS_SBTS__STATE__Checking_mandatory_parameter_converted_to_optional_CB013033
    TC__SBTS_SBTS__STATE__Checking_mandatory_parameter_converted_to_optional_CB013033
    [Teardown]    Run Keywords    SBTS_SBTS__STATE__Checking_mandatory_parameter_converted_to_optional_CB013033.TC Teardown
    ...    AND    Restore Resource Search Order