*** Settings ***
Documentation    Testsuite

Resource    ../../../test_resources/UUF_SW_UPGRADE.robot
Resource    ../../../test_resources/UUF_SW_UPGRADE_ROLLBACK.robot
Resource    ../../../test_resources/RRM__RFS__NR_NSA_Data_Transfer_Taf_Ue.robot
Resource    ../../../test_resources/SBTS_SBTS__SWM__SW_Fallback.robot
Resource    ../../../test_resources/SBTS_SBTS__STATE__Enable_Disable_PIMC_Bypass_Mode.robot
Resource    ../../../test_resources/UUF_ACTIVATION_RESET.robot
Resource    ../../../test_resources/SBTS_SBTS_SBTS_SBTS__STATE__RM_Power_Off_On.robot
Resource    ../../../test_resources/SBTS_SBTS__SWM__RU_SW_Upgrade.robot
Resource    ../../../test_resources/SBTS_SBTS__STATE__Robustness.robot

Force Tags    QCD_MN_RAN    QCP_RAN_VRF    CLOUD_10_18_UTESRANRFSMTNRL32
...    SBTS00  STATE_SKIP_AGENT    CRT

*** Variables ***
${SCF_ID}    01
${ALM_PTH}    ${CURDIR}/../../../test_resources/tc_variables


*** Test Cases ***
[1][1.0] Automated_RFS_UUF_SW_UPGRADE
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${BTS1_testline_object}    ${tl.gnbs[0]}
    ...    AND    Set Test Variable    ${BTS2_testline_object}    ${tl.enbs[0]}
    ...    AND    Set Test Variable    ${BTS1_source_sw}
    ...    AND    Set Test Variable    ${BTS2_source_sw}
    ...    AND    Set Test Variable    ${BTS1_target_sw}
    ...    AND    Set Test Variable    ${BTS2_target_sw}
    ...    AND    Set Test Variable    ${BTS1_temporary_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS2_temporary_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS1_custom_allowed_alarms}    4700,4773,1898,6134,6132,6129,7513,7511,7509,7107,1815,62003
    ...    AND    Set Test Variable    ${BTS2_custom_allowed_alarms}    4700,4773,1898,6134,6132,6129,7513,7511,7509,7107,1815,62003
    ...    AND    Set Test Variable    ${SYNCHRONIZE_SW_ON_PASSIVE}    True
    ...    AND    Set Test Variable    ${TEST_NODES_DETAILS_LIST}    ALL
    ...    AND    Set Test Variable    ${ITERATIONS_PER_NODE}    1
    ...    AND    Set Test Variable    ${CUSTOMERS_LIST}    Generic
    ...    AND    Set Test Variable    ${CALCULATE_KPI}    True
    ...    AND    Set Test Variable    ${USE_DCAP}    False
    ...    AND    Set Test Variable    ${L3_CALL_METHOD}    None
    ...    AND    Set Test Variable    ${STOP_TEST_AFTER_FAIL}    False
    ...    AND    Set Test Variable    ${REPORT}    True
    ...    AND    Set Test Variable    ${QC_PROJECT}    ${None}
    ...    AND    Set Test Variable    ${QC_DOMAIN}    ${None}
    ...    AND    Set Test Variable    ${QC_ID}    ${None}
    ...    AND    Set Test Variable    ${SW_BUILD}    ${None}
    ...    AND    Set Test Variable    ${TOPOLOGY}    ${None}
    ...    AND    Set Test Variable    ${TAGS}    CA_VRF_TSR2
    ...    AND    Set Test Variable    ${RP_CA}    VRF_SiSo
    ...    AND    Set Test Variable    ${RP_LOCATION}    VRF_TSR
    ...    AND    Set Test Variable    ${RP_ORGANIZATION}    VRF_TSR_T06

    ...    AND    UUF_SW_UPGRADE.TC Setup
    ...    AND    Modify Resource Search Order    UUF_SW_UPGRADE
    ...    AND    Set Library Search Order    UUF_SW_UPGRADE
    TC__UUF_SW_UPGRADE
    [Teardown]    Run Keywords    UUF_SW_UPGRADE.TC Teardown
    ...    AND    Restore Resource Search Order


[1][1.0] Automated_RFS_UUF_SW_UPGRADE_ROLLBACK
    [Timeout]    43200
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${BTS1_testline_object}    ${tl.gnbs[0]}
    ...    AND    Set Test Variable    ${BTS2_testline_object}    ${tl.enbs[0]}
    ...    AND    Set Test Variable    ${BTS3_testline_object}
    ...    AND    Set Test Variable    ${BTS4_testline_object}
    ...    AND    Set Test Variable    ${BTS1_source_sw}
    ...    AND    Set Test Variable    ${BTS2_source_sw}
    ...    AND    Set Test Variable    ${BTS3_source_sw}
    ...    AND    Set Test Variable    ${BTS4_source_sw}
    ...    AND    Set Test Variable    ${BTS1_target_sw}
    ...    AND    Set Test Variable    ${BTS2_target_sw}
    ...    AND    Set Test Variable    ${BTS3_target_sw}
    ...    AND    Set Test Variable    ${BTS4_target_sw}
    ...    AND    Set Test Variable    ${BTS1_temporary_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS2_temporary_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS3_temporary_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS4_temporary_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS1_custom_allowed_alarms}    4700,4773,1898,6134,6132,6129,7513,7511,7509,7107,1815,62003
    ...    AND    Set Test Variable    ${BTS2_custom_allowed_alarms}    4700,4773,1898,6134,6132,6129,7513,7511,7509,7107,1815,62003
    ...    AND    Set Test Variable    ${BTS3_custom_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS4_custom_allowed_alarms}
    ...    AND    Set Test Variable    &{BTS1_node_parameters}    &{EMPTY}
    ...    AND    Set Test Variable    &{BTS2_node_parameters}    &{EMPTY}
    ...    AND    Set Test Variable    &{BTS3_node_parameters}    &{EMPTY}
    ...    AND    Set Test Variable    &{BTS4_node_parameters}    &{EMPTY}
    ...    AND    Set Test Variable    ${SYNCHRONIZE_SW_ON_PASSIVE}    True
    ...    AND    Set Test Variable    ${TEST_NODES_DETAILS_LIST}    ALL
    ...    AND    Set Test Variable    ${ROLLBACK_REVERSE_ORDER}    True
    ...    AND    Set Test Variable    ${RESTORE_TO_TARGET_SW}    True
    ...    AND    Set Test Variable    ${ITERATIONS_PER_NODE}    3
    ...    AND    Set Test Variable    ${CUSTOMERS_LIST}    Generic
    ...    AND    Set Test Variable    ${CALCULATE_KPI}    True
    ...    AND    Set Test Variable    ${KPI_NAMES}
    ...    AND    Set Test Variable    ${KPI_THRESHOLDS}
    ...    AND    Set Test Variable    ${USE_DCAP}    False
    ...    AND    Set Test Variable    ${L3_CALL_METHOD}    None
    ...    AND    Set Test Variable    ${STOP_TEST_AFTER_FAIL}    False
    ...    AND    Set Test Variable    ${REPORT}    True
    ...    AND    Set Test Variable    ${QC_PROJECT}    ${None}
    ...    AND    Set Test Variable    ${QC_DOMAIN}    ${None}
    ...    AND    Set Test Variable    ${QC_ID}    ${None}
    ...    AND    Set Test Variable    ${SW_BUILD}    ${None}
    ...    AND    Set Test Variable    ${TOPOLOGY}    ${None}
    ...    AND    Set Test Variable    ${RP_CA}    VRF_SiSo
    ...    AND    Set Test Variable    ${RP_LOCATION}    VRF_TSR
    ...    AND    Set Test Variable    ${RP_ORGANIZATION}    VRF_TSR_T06
    ...    AND    Set Test Variable    &{TEST_PARAMETERS}    &{EMPTY}

    ...    AND    UUF_SW_UPGRADE_ROLLBACK.TC Setup
    ...    AND    Modify Resource Search Order    UUF_SW_UPGRADE_ROLLBACK
    ...    AND    Set Library Search Order    UUF_SW_UPGRADE_ROLLBACK
    TC__UUF_SW_UPGRADE_ROLLBACK
    [Teardown]    Run Keywords    UUF_SW_UPGRADE_ROLLBACK.TC Teardown
    ...    AND    Restore Resource Search Order

[1][1.0] SW_Activation_Reset_in_loops
    [Timeout]    36000
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${BTS1_testline_object}    ${tl.gnbs[0]}
    ...    AND    Set Test Variable    ${BTS2_testline_object}    ${tl.enbs[0]}
    ...    AND    Set Test Variable    ${BTS3_testline_object}
    ...    AND    Set Test Variable    ${BTS4_testline_object}
    ...    AND    Set Test Variable    ${BTS1_source_sw}
    ...    AND    Set Test Variable    ${BTS2_source_sw}
    ...    AND    Set Test Variable    ${BTS3_source_sw}
    ...    AND    Set Test Variable    ${BTS4_source_sw}
    ...    AND    Set Test Variable    ${BTS1_target_sw}
    ...    AND    Set Test Variable    ${BTS2_target_sw}
    ...    AND    Set Test Variable    ${BTS3_target_sw}
    ...    AND    Set Test Variable    ${BTS4_target_sw}
    ...    AND    Set Test Variable    ${BTS1_temporary_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS2_temporary_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS3_temporary_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS4_temporary_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS1_custom_allowed_alarms}    4700,4773,1898,6134,6132,6129,7513,7511,7509,7107,1815,62003
    ...    AND    Set Test Variable    ${BTS2_custom_allowed_alarms}    4700,4773,1898,6134,6132,6129,7513,7511,7509,7107,1815,62003
    ...    AND    Set Test Variable    ${BTS3_custom_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS4_custom_allowed_alarms}
    ...    AND    Set Test Variable    &{BTS1_node_parameters}    &{EMPTY}
    ...    AND    Set Test Variable    &{BTS2_node_parameters}    &{EMPTY}
    ...    AND    Set Test Variable    &{BTS3_node_parameters}    &{EMPTY}
    ...    AND    Set Test Variable    &{BTS4_node_parameters}    &{EMPTY}
    ...    AND    Set Test Variable    ${TEST_NODES_DETAILS_LIST}    ALL
    ...    AND    Set Test Variable    ${ITERATIONS_PER_NODE}    10
    ...    AND    Set Test Variable    ${CUSTOMERS_LIST}    Generic
    ...    AND    Set Test Variable    ${CALCULATE_KPI}    True
    ...    AND    Set Test Variable    ${KPI_NAMES}
    ...    AND    Set Test Variable    ${KPI_THRESHOLDS}
    ...    AND    Set Test Variable    ${USE_DCAP}    False
    ...    AND    Set Test Variable    ${L3_CALL_METHOD}    None
    ...    AND    Set Test Variable    ${STOP_TEST_AFTER_FAIL}    False
    ...    AND    Set Test Variable    ${REPORT}    True
    ...    AND    Set Test Variable    ${QC_PROJECT}    ${None}
    ...    AND    Set Test Variable    ${QC_DOMAIN}    ${None}
    ...    AND    Set Test Variable    ${QC_ID}    ${None}
    ...    AND    Set Test Variable    ${SW_BUILD}    ${None}
    ...    AND    Set Test Variable    ${TOPOLOGY}    ${None}
    ...    AND    Set Test Variable    ${RP_CA}    VRF_SiSo
    ...    AND    Set Test Variable    ${RP_LOCATION}    VRF_TSR
    ...    AND    Set Test Variable    ${RP_ORGANIZATION}    VRF_TSR_T06
    ...    AND    Set Test Variable    &{TEST_PARAMETERS}    &{EMPTY}

    ...    AND    UUF_ACTIVATION_RESET.TC Setup
    ...    AND    Modify Resource Search Order    UUF_ACTIVATION_RESET
    ...    AND    Set Library Search Order    UUF_ACTIVATION_RESET
    TC__UUF_ACTIVATION_RESET
    [Teardown]    Run Keywords    UUF_ACTIVATION_RESET.TC Teardown
    ...    AND    Restore Resource Search Order


[1][1.0] RFS_SBTS_SBTS_SWFallback_with_WebEM
    [Timeout]    43200
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__swm__sw_fallback_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${BTS_SW_Fallback}    BTS1
    ...    AND    Set Test Variable    ${Target SW dir}    /home/ute/Fallback
    ...    AND    Set Test Variable    ${Target SW name}    None
    ...    AND    Set Test Variable    ${SW Update Timeout}    3000
    ...    AND    Set Test Variable    ${FORCE_CURRENT_SW_DL}    True
    ...    AND    Set Test Variable    ${Remote target SW path}    None
    ...    AND    Set Test Variable    ${RFS_CUSTOM_SHARE_SW_DL}    False
    ...    AND    Set Test Variable    ${CB015052_CHECK}    False
    ...    AND    Set Test Variable    ${tempRadioMasterTriggerTime}    0
    ...    AND    Set Test Variable    ${RESTORE_INITIAL_BTS_SW}    False
    ...    AND    Set Test Variable    ${BTS_MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${BTS1_reset_number}    1
    ...    AND    Set Test Variable    ${BTS2_reset_number}    0
    ...    AND    Set Test Variable    ${swFallbackTimer}    30
    ...    AND    Set Test Variable    ${BTS1_EIF_down}    M32-EIF-down
    ...    AND    Set Test Variable    ${BTS1_EIF_pass_down}    EIF-down-m32
    ...    AND    Set Test Variable    ${BTS1_EIF_up}    M32-EIF-up
    ...    AND    Set Test Variable    ${BTS1_EIF_pass_up}    EIF-up-m32
    ...    AND    Set Test Variable    ${BTS1_EIF_Switch_IpAddress}    10.255.10.217
    ...    AND    Set Test Variable    ${BTS2_EIF_down}
    ...    AND    Set Test Variable    ${BTS2_EIF_pass_down}
    ...    AND    Set Test Variable    ${BTS2_EIF_up}
    ...    AND    Set Test Variable    ${BTS2_EIF_pass_up}
    ...    AND    Set Test Variable    ${BTS2_EIF_Switch_IpAddress}

    ...    AND    SBTS_SBTS__SWM__SW_Fallback.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__SWM__SW_Fallback
    ...    AND    Set Library Search Order    SBTS_SBTS__SWM__SW_Fallback
    TC__SBTS_SBTS__SWM__SW_Fallback
    [Teardown]    Run Keywords    SBTS_SBTS__SWM__SW_Fallback.TC Teardown
    ...    AND    Restore Resource Search Order

[1][1.0] Automated_L3_call_with_UL_DL_Throughput
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__robustness_alarms_definitions.py
    ...    AND    Set Test Variable    ${BTS}    BTS1
    ...    AND    Set Test Variable    ${OAM_OPERATION}    Block
    ...    AND    Set Test Variable    ${RESOURCE}    NRCEL
    ...    AND    Set Test Variable    ${HW_SN_LIST}
    ...    AND    Set Test Variable    ${CELL_ID_LIST}    1
    ...    AND    Set Test Variable    ${RAT_LIST}
    ...    AND    Set Test Variable    ${RAT_RESET_TYPE}    Soft
    ...    AND    Set Test Variable    ${GRACEFUL_CELL_SHUTDOWN}    True
    ...    AND    Set Test Variable    ${RESET_WITHOUT_RU}    False
    ...    AND    Set Test Variable    ${OAM_OPERATION_TIMEOUT}    100
    ...    AND    Set Test Variable    ${BTS_STABLE_TIME}    10
    ...    AND    Set Test Variable    ${CRITICAL_FAULT_ID_LIST}
    ...    AND    Set Test Variable    ${LOAD_HISTORY}    False
    ...    AND    Set Test Variable    ${SNAPSHOT_COLLECT}    False

    ...    AND    SBTS_SBTS__STATE__Robustness.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__STATE__Robustness
    ...    AND    Set Library Search Order    SBTS_SBTS__STATE__Robustness
    TC__SBTS_SBTS__STATE__Robustness
    [Teardown]    Run Keywords    SBTS_SBTS__STATE__Robustness.TC Teardown
    ...    AND    Restore Resource Search Order

Robustness
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__robustness_alarms_definitions.py
    ...    AND    Set Test Variable    ${BTS}    BTS1
    ...    AND    Set Test Variable    ${OAM_OPERATION}    Unblock
    ...    AND    Set Test Variable    ${RESOURCE}    NRCEL
    ...    AND    Set Test Variable    ${HW_SN_LIST}
    ...    AND    Set Test Variable    ${CELL_ID_LIST}    1
    ...    AND    Set Test Variable    ${RAT_LIST}
    ...    AND    Set Test Variable    ${RAT_RESET_TYPE}    Soft
    ...    AND    Set Test Variable    ${GRACEFUL_CELL_SHUTDOWN}    True
    ...    AND    Set Test Variable    ${RESET_WITHOUT_RU}    False
    ...    AND    Set Test Variable    ${OAM_OPERATION_TIMEOUT}    100
    ...    AND    Set Test Variable    ${BTS_STABLE_TIME}    10
    ...    AND    Set Test Variable    ${CRITICAL_FAULT_ID_LIST}
    ...    AND    Set Test Variable    ${LOAD_HISTORY}    False
    ...    AND    Set Test Variable    ${SNAPSHOT_COLLECT}    False

    ...    AND    SBTS_SBTS__STATE__Robustness.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__STATE__Robustness
    ...    AND    Set Library Search Order    SBTS_SBTS__STATE__Robustness
    TC__SBTS_SBTS__STATE__Robustness
    [Teardown]    Run Keywords    SBTS_SBTS__STATE__Robustness.TC Teardown
    ...    AND    Restore Resource Search Order


[1][4.0] Automated_RFS_SBTS_SBTS__STATE__SharedRM_Power_Off_On
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__state__rm_power_off_on_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${RMOD_SERIAL_NUMBER_LIST}    ALL
    ...    AND    Set Test Variable    ${RMOD_SHARING_INFO}    shared
    ...    AND    Set Test Variable    ${RMOD_POWER_ON_WRN_THR}   320
    ...    AND    Set Test Variable    ${RMOD_POWER_MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${RMOD_RESET_TIME_INTERVAL}    480
    ...    AND    Set Test Variable    ${LTE_IOT_check}    False
    ...    AND    Set Test Variable    ${CB005763_CHECK}    True
    ...    AND    Set Test Variable    ${CB005763_EXEMPTED_RMOD_SERIAL_NUMBER_LIST}    L1205002760, L1204110673, L1204110677

    ...    AND    SBTS_SBTS_SBTS_SBTS__STATE__RM_Power_Off_On.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS_SBTS_SBTS__STATE__RM_Power_Off_On
    ...    AND    Set Library Search Order    SBTS_SBTS_SBTS_SBTS__STATE__RM_Power_Off_On
    TC__SBTS_SBTS_SBTS_SBTS__STATE__RM_Power_Off_On
    [Teardown]    Run Keywords    SBTS_SBTS_SBTS_SBTS__STATE__RM_Power_Off_On.TC Teardown
    ...    AND    Restore Resource Search Order

[1][1.0] Automated_RFS_SBTS_SBTS__STATE__Enable_Disable_PIMC_Bypass_Mode
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__enable_disable_pimc_bypass_mode_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${ALLOWED_RMOD_SN_LIST}
    ...    K9183920950, K9181816201, K9181717463, BL2135V0JZ9, BL2135V0K0L, BL2135V0JUB, BL2032V0I40
    ...    AND    Set Test Variable    ${DELTA_POWER_THR}    30, 30, 30, 30, 30, 30, 30

    ...    AND    SBTS_SBTS__STATE__Enable_Disable_PIMC_Bypass_Mode.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__STATE__Enable_Disable_PIMC_Bypass_Mode
    ...    AND    Set Library Search Order    SBTS_SBTS__STATE__Enable_Disable_PIMC_Bypass_Mode
    TC__SBTS_SBTS__STATE__Enable_Disable_PIMC_Bypass_Mode
    [Teardown]    Run Keywords    SBTS_SBTS__STATE__Enable_Disable_PIMC_Bypass_Mode.TC Teardown
    ...    AND    Restore Resource Search Order

[1][1.0] Automated_SBTS_SBTS__SWM__RU_SW_Upgrade_Simultaneous
    [Timeout]    14400
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
    ...    AND    Set Test Variable    ${CB013660_ruPhaseSwActivationResetPolicy}    Simultaneous
    ...    AND    Set Test Variable    ${CB010780_NO_UPGRADE_RM_SN_LIST}
    ...    AND    Set Test Variable    ${CB013660_NO_UPGRADE_RM_SN_LIST}
    ...    AND    Set Test Variable    ${CB013660_DU_RM_SN_LIST}
    ...    AND    Set Test Variable    ${CB013660_RU_RM_SN_LIST}
    ...    AND    Set Test Variable    ${RU_FIRST_GROUP_RESET_RM_SN_LIST}
    ...    AND    Set Test Variable    ${RU_SECOND_GROUP_RESET_RM_SN_LIST}
    ...    AND    Set Test Variable    ${CHANGE_RM_UPGRADE_PARAMETER}    False
    ...    AND    Set Test Variable    ${CB007447_SHARED_RM_SN_EXCEPTIONS_LIST}
    ...    AND    Set Test Variable    ${RECOVER_BTS_SW}    False
    ...    AND    Set Test Variable    ${SECONDARY_CONTROLLER_BTS_SW_UPDATE}    False

    ...    AND    SBTS_SBTS__SWM__RU_SW_Upgrade.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__SWM__RU_SW_Upgrade
    ...    AND    Set Library Search Order    SBTS_SBTS__SWM__RU_SW_Upgrade
    TC__SBTS_SBTS__SWM__RU_SW_Upgrade
    [Teardown]    Run Keywords    SBTS_SBTS__SWM__RU_SW_Upgrade.TC Teardown
    ...    AND    Restore Resource Search Order



[1][1.0] Automated_SBTS_SBTS__SWM__RU_SW_Upgrade_Sequential
    [Timeout]    14400
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
    ...    AND    Set Test Variable    ${CB013660_ruPhaseSwActivationResetPolicy}    Sequential
    ...    AND    Set Test Variable    ${CB010780_NO_UPGRADE_RM_SN_LIST}
    ...    AND    Set Test Variable    ${CB013660_NO_UPGRADE_RM_SN_LIST}
    ...    AND    Set Test Variable    ${CB013660_DU_RM_SN_LIST}
    ...    AND    Set Test Variable    ${CB013660_RU_RM_SN_LIST}
    ...    AND    Set Test Variable    ${RU_FIRST_GROUP_RESET_RM_SN_LIST}
    ...    AND    Set Test Variable    ${RU_SECOND_GROUP_RESET_RM_SN_LIST}
    ...    AND    Set Test Variable    ${CHANGE_RM_UPGRADE_PARAMETER}    False
    ...    AND    Set Test Variable    ${CB007447_SHARED_RM_SN_EXCEPTIONS_LIST}
    ...    AND    Set Test Variable    ${RECOVER_BTS_SW}    False
    ...    AND    Set Test Variable    ${SECONDARY_CONTROLLER_BTS_SW_UPDATE}    False

    ...    AND    SBTS_SBTS__SWM__RU_SW_Upgrade.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__SWM__RU_SW_Upgrade
    ...    AND    Set Library Search Order    SBTS_SBTS__SWM__RU_SW_Upgrade
    TC__SBTS_SBTS__SWM__RU_SW_Upgrade
    [Teardown]    Run Keywords    SBTS_SBTS__SWM__RU_SW_Upgrade.TC Teardown
    ...    AND    Restore Resource Search Order
