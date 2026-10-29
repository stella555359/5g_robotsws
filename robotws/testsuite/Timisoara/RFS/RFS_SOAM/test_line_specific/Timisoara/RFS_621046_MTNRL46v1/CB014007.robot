*** Settings ***
Documentation  Test Suite
Resource    ../../../test_resources/SBTS_SBTS_SBTS_SBTS__CM__Planned_Recommissioning_template.robot
Resource    ../../../test_resources/SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_Lock_Unlock_Site_Reset.robot
Resource    ../../../test_resources/SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM.robot
Resource    ../../../test_resources/SBTS_SBTS_SBTS_SBTS__STATE__RM_Power_Off_On.robot
Resource    ../../../test_resources/SBTS_SBTS_SBTS_SBTS__STATE__Site_Reset_without_RU_reset_CB012446.robot
Resource    ../../../test_resources/UUF_ACTIVATION_RESET.robot
Resource    ../../../test_resources/UUF_SW_UPGRADE_ROLLBACK.robot
Force Tags    QCD_MN_RAN    QCP_RAN_VRF    CLOUD_10_18_UTESRANRFSMTNRL46    SBTS00    STATE_SKIP_AGENT    CRT




*** Variables ***
${SCF_ID}    01
${ALM_PTH}    ${CURDIR}/../../../test_resources/tc_variables



*** Test Cases ***
[1]UUF_SW_UPGRADE_ROLLBACK
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${BTS1_testline_object}    ${tl.enbs[0]}
    ...    AND    Set Test Variable    ${BTS2_testline_object}    ${tl.enbs[1]}
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
    ...    AND    Set Test Variable    ${BTS1_temporary_allowed_alarms}    7300,7513,7511,7509,6351,4452,16,4298,6202,7525
    ...    AND    Set Test Variable    ${BTS2_temporary_allowed_alarms}    7300,7513,7511,7509,6351,4452,16,4298,6202,7525
    ...    AND    Set Test Variable    ${BTS3_temporary_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS4_temporary_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS1_custom_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS2_custom_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS3_custom_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS4_custom_allowed_alarms}
    ...    AND    Set Test Variable    &{BTS1_node_parameters}    &{EMPTY}
    ...    AND    Set Test Variable    &{BTS2_node_parameters}    &{EMPTY}
    ...    AND    Set Test Variable    &{BTS3_node_parameters}    &{EMPTY}
    ...    AND    Set Test Variable    &{BTS4_node_parameters}    &{EMPTY}
    ...    AND    Set Test Variable    ${SYNCHRONIZE_SW_ON_PASSIVE}    True
    ...    AND    Set Test Variable    ${TEST_NODES_DETAILS_LIST}    ALL
    ...    AND    Set Test Variable    ${ROLLBACK_REVERSE_ORDER}    False
    ...    AND    Set Test Variable    ${RESTORE_TO_TARGET_SW}    True
    ...    AND    Set Test Variable    ${ITERATIONS_PER_NODE}    1
    ...    AND    Set Test Variable    ${CUSTOMERS_LIST}    Generic
    ...    AND    Set Test Variable    ${CALCULATE_KPI}    True
    ...    AND    Set Test Variable    ${KPI_NAMES}
    ...    AND    Set Test Variable    ${KPI_THRESHOLDS}
    ...    AND    Set Test Variable    ${ADDITIONAL_KPI}
    ...    AND    Set Test Variable    ${SWCONFIG_MODIFICATION}    True
    ...    AND    Set Test Variable    ${HW_FILE_MIGRATION_CHECK}    True
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
    ...    AND    Set Test Variable    ${RP_LOCATION}    VRF_TSR2
    ...    AND    Set Test Variable    ${RP_ORGANIZATION}    VRF_TSR2_T06
    ...    AND    Set Test Variable    &{TEST_PARAMETERS}    &{EMPTY}

    ...    AND    UUF_SW_UPGRADE_ROLLBACK.TC Setup
    ...    AND    Modify Resource Search Order    UUF_SW_UPGRADE_ROLLBACK
    ...    AND    Set Library Search Order    UUF_SW_UPGRADE_ROLLBACK
    TC__UUF_SW_UPGRADE_ROLLBACK
    [Teardown]    Run Keywords    UUF_SW_UPGRADE_ROLLBACK.TC Teardown
    ...    AND    Restore Resource Search Order



[1]UUF_ACTIVATION_RESET
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${BTS1_testline_object}    ${tl.enbs[0]}
    ...    AND    Set Test Variable    ${BTS2_testline_object}    ${tl.enbs[1]}
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
    ...    AND    Set Test Variable    ${BTS1_temporary_allowed_alarms}    7300,7513,7511,7509,6351,4452,16,4298,6202,7525
    ...    AND    Set Test Variable    ${BTS2_temporary_allowed_alarms}    7300,7513,7511,7509,6351,4452,16,4298,6202,7525
    ...    AND    Set Test Variable    ${BTS3_temporary_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS4_temporary_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS1_custom_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS2_custom_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS3_custom_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS4_custom_allowed_alarms}
    ...    AND    Set Test Variable    &{BTS1_node_parameters}    &{EMPTY}
    ...    AND    Set Test Variable    &{BTS2_node_parameters}    &{EMPTY}
    ...    AND    Set Test Variable    &{BTS3_node_parameters}    &{EMPTY}
    ...    AND    Set Test Variable    &{BTS4_node_parameters}    &{EMPTY}
    ...    AND    Set Test Variable    ${TEST_NODES_DETAILS_LIST}    ALL
    ...    AND    Set Test Variable    ${ITERATIONS_PER_NODE}    1
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
    ...    AND    Set Test Variable    ${RP_LOCATION}    VRF_TSR2
    ...    AND    Set Test Variable    ${RP_ORGANIZATION}    VRF_TSR2_T06
    ...    AND    Set Test Variable    &{TEST_PARAMETERS}    &{EMPTY}

    ...    AND    UUF_ACTIVATION_RESET.TC Setup
    ...    AND    Modify Resource Search Order    UUF_ACTIVATION_RESET
    ...    AND    Set Library Search Order    UUF_ACTIVATION_RESET
    TC__UUF_ACTIVATION_RESET
    [Teardown]    Run Keywords    UUF_ACTIVATION_RESET.TC Teardown
    ...    AND    Restore Resource Search Order



[1]SBTS_SBTS__STATE__SharedRM_Power_Off_On
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__state__rm_power_off_on_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${RMOD_SERIAL_NUMBER_LIST}    ALL
    ...    AND    Set Test Variable    ${RMOD_SHARING_INFO}    ALL
    ...    AND    Set Test Variable    ${RMOD_POWER_ON_WRN_THR}    240
    ...    AND    Set Test Variable    ${RMOD_POWER_MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${RMOD_RESET_TIME_INTERVAL}    480
    ...    AND    Set Test Variable    ${LTE_IOT_check}    True
    ...    AND    Set Test Variable    ${CB005763_CHECK}    False
    ...    AND    Set Test Variable    ${CB005763_EXEMPTED_RMOD_SERIAL_NUMBER_LIST}

    ...    AND    SBTS_SBTS_SBTS_SBTS__STATE__RM_Power_Off_On.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS_SBTS_SBTS__STATE__RM_Power_Off_On
    ...    AND    Set Library Search Order    SBTS_SBTS_SBTS_SBTS__STATE__RM_Power_Off_On
    TC__SBTS_SBTS_SBTS_SBTS__STATE__RM_Power_Off_On
    [Teardown]    Run Keywords    SBTS_SBTS_SBTS_SBTS__STATE__RM_Power_Off_On.TC Teardown
    ...    AND    Restore Resource Search Order



[1]SBTS_SBTS__STATE__Site_Reset_without_RU_reset_CB012446
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__state__site_reset_without_ru_reset_cb012446_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${BTS_LIST}    All
    ...    AND    Set Test Variable    ${cntrldResetMplaneBreakTimeSite}    300
    ...    AND    Set Test Variable    ${BTS1_RESET_WRN_THR}    600
    ...    AND    Set Test Variable    ${BTS2_RESET_WRN_THR}    600
    ...    AND    Set Test Variable    ${BTS3_RESET_WRN_THR}    600
    ...    AND    Set Test Variable    ${BTS4_RESET_WRN_THR}    600
    ...    AND    Set Test Variable    ${BTS_MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${GRACEFUL_CELL_SHUTDOWN}    True
    ...    AND    Set Test Variable    ${CB007447_SHARED_RM_SN_EXCEPTIONS_LIST}
    ...    AND    Set Test Variable    ${CB012446_SHARED_RM_SN_EXCEPTIONS_LIST}

    ...    AND    SBTS_SBTS_SBTS_SBTS__STATE__Site_Reset_without_RU_reset_CB012446.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS_SBTS_SBTS__STATE__Site_Reset_without_RU_reset_CB012446
    ...    AND    Set Library Search Order    SBTS_SBTS_SBTS_SBTS__STATE__Site_Reset_without_RU_reset_CB012446
    TC__SBTS_SBTS_SBTS_SBTS__STATE__Site_Reset_without_RU_reset_CB012446
    [Teardown]    Run Keywords    SBTS_SBTS_SBTS_SBTS__STATE__Site_Reset_without_RU_reset_CB012446.TC Teardown
    ...    AND    Restore Resource Search Order



[1]SBTS_SBTS__STATE__Cell_Block_Unblock_Lock_Unlock_Site_Reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__state__cell_block_unblock_lock_unlock_site_reset_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${BTS_RESET_LIST}
    ...    AND    Set Test Variable    ${BTS1_NR_GLOBAL_CELL_ID_BLOCK_LIST}
    ...    AND    Set Test Variable    ${BTS1_NR_GLOBAL_CELL_ID_LOCK_LIST}
    ...    AND    Set Test Variable    ${BTS1_LTE_GLOBAL_CELL_ID_BLOCK_LIST}
    ...    AND    Set Test Variable    ${BTS1_LTE_GLOBAL_CELL_ID_LOCK_LIST}
    ...    AND    Set Test Variable    ${BTS2_NR_GLOBAL_CELL_ID_BLOCK_LIST}
    ...    AND    Set Test Variable    ${BTS2_NR_GLOBAL_CELL_ID_LOCK_LIST}
    ...    AND    Set Test Variable    ${BTS2_LTE_GLOBAL_CELL_ID_BLOCK_LIST}
    ...    AND    Set Test Variable    ${BTS2_LTE_GLOBAL_CELL_ID_LOCK_LIST}
    ...    AND    Set Test Variable    ${BTS3_NR_GLOBAL_CELL_ID_BLOCK_LIST}
    ...    AND    Set Test Variable    ${BTS3_NR_GLOBAL_CELL_ID_LOCK_LIST}
    ...    AND    Set Test Variable    ${BTS3_LTE_GLOBAL_CELL_ID_BLOCK_LIST}
    ...    AND    Set Test Variable    ${BTS3_LTE_GLOBAL_CELL_ID_LOCK_LIST}
    ...    AND    Set Test Variable    ${BTS4_NR_GLOBAL_CELL_ID_BLOCK_LIST}
    ...    AND    Set Test Variable    ${BTS4_NR_GLOBAL_CELL_ID_LOCK_LIST}
    ...    AND    Set Test Variable    ${BTS4_LTE_GLOBAL_CELL_ID_BLOCK_LIST}
    ...    AND    Set Test Variable    ${BTS4_LTE_GLOBAL_CELL_ID_LOCK_LIST}
    ...    AND    Set Test Variable    ${CELL_MAX_WAIT_TIME}    200
    ...    AND    Set Test Variable    ${BTS_MAX_WAIT_TIME}    900

    ...    AND    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_Lock_Unlock_Site_Reset.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_Lock_Unlock_Site_Reset
    ...    AND    Set Library Search Order    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_Lock_Unlock_Site_Reset
    TC__SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_Lock_Unlock_Site_Reset
    [Teardown]    Run Keywords    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_Lock_Unlock_Site_Reset.TC Teardown
    ...    AND    Restore Resource Search Order



[1]SBTS_SBTS_SBTS__STATE__Cell_BlockUnblock_from_WEBEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__state__cell_block_unblock_from_webem_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${BTS_LIST}    ALL
    ...    AND    Set Test Variable    ${RAT_LIST}    ALL
    ...    AND    Set Test Variable    ${LTE_IOT_SA_action}    True
    ...    AND    Set Test Variable    ${LTE_IOT_check}    True
    ...    AND    Set Test Variable    ${NR_CELL_BLOCK_WRN_THR}    10
    ...    AND    Set Test Variable    ${NR_CELL_UNBLOCK_WRN_THR}    10
    ...    AND    Set Test Variable    ${LTE_CELL_BLOCK_WRN_THR}    10
    ...    AND    Set Test Variable    ${LTE_CELL_UNBLOCK_WRN_THR}    10
    ...    AND    Set Test Variable    ${WCDMA_CELL_BLOCK_WRN_THR}    10
    ...    AND    Set Test Variable    ${WCDMA_CELL_UNBLOCK_WRN_THR}    10
    ...    AND    Set Test Variable    ${GSM_CELL_BLOCK_WRN_THR}    130
    ...    AND    Set Test Variable    ${GSM_CELL_UNBLOCK_WRN_THR}    10
    ...    AND    Set Test Variable    ${CELL_BLOCK_MAX_WAIT_TIME}    200
    ...    AND    Set Test Variable    ${CELL_UNBLOCK_MAX_WAIT_TIME}    200

    ...    AND    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM
    ...    AND    Set Library Search Order    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM
    TC__SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM
    [Teardown]    Run Keywords    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM.TC Teardown
    ...    AND    Restore Resource Search Order



[1]SBTS_SBTS__CM__Planned_Recommissioning_template
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__cm__planned_recommissioning_template_alarms_definitions.py
    ...    AND    Set Test Variable    ${RECOMMISSIONING_BTS1}    CURRENT
    ...    AND    Set Test Variable    ${RECOMMISSIONING_BTS2}    NONE
    ...    AND    Set Test Variable    ${RECOMMISSIONING_BTS3}    NONE
    ...    AND    Set Test Variable    ${RECOMMISSIONING_BTS4}    NONE
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${RESET_CONFIGURATION}    False
    ...    AND    Set Test Variable    ${BTS_SCF_VALIDATION}    True
    ...    AND    Set Test Variable    ${BTS_MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${RECOVER_INITIAL_SCF}    True
    ...    AND    Set Test Variable    ${KPI_LIST}    kpi12a
    ...    AND    Set Test Variable    ${BTS_RESET_WRN_THR_LIST}    600

    ...    AND    SBTS_SBTS_SBTS_SBTS__CM__Planned_Recommissioning_template.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS_SBTS_SBTS__CM__Planned_Recommissioning_template
    ...    AND    Set Library Search Order    SBTS_SBTS_SBTS_SBTS__CM__Planned_Recommissioning_template
    TC__SBTS_SBTS_SBTS_SBTS__CM__Planned_Recommissioning_template
    [Teardown]    Run Keywords    SBTS_SBTS_SBTS_SBTS__CM__Planned_Recommissioning_template.TC Teardown
    ...    AND    Restore Resource Search Order

