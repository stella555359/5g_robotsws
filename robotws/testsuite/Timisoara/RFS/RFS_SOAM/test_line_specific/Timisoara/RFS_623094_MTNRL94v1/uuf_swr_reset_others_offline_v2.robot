*** Settings ***
Documentation  Test Suite
Resource    ../../../test_resources/UUF_SITE_RESET_WITHOUT_HWF.robot
Resource    ../../../test_resources/UUF_SW_UPGRADE_ROLLBACK.robot

Resource    ../../../test_resources/SBTS__STATE__RAT_Block_Unblock_from_WEBEM.robot
Resource    ../../../test_resources/SBTS__STATE__RAT_Reset_from_WEBEM.robot

Resource    ../../../test_resources/SBTS__STATE__RM_Reset_from_WEBEM.robot
Resource    ../../../test_resources/SBTS_SBTS_SBTS_SBTS__STATE__RM_LockUnlock.robot
Resource    ../../../test_resources/SBTS__STATE__RM_Power_Off_On.robot

Resource    ../../../test_resources/SBTS__STATE__Site_Block_Unblock_from_WEBEM.robot

Resource    ../../../test_resources/SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM.robot

Resource    ../../../test_resources/SBTS__STATE__SBTS_Power_Off_On.robot
Resource    ../../../test_resources/SBTS__STATE__Site_Reset_from_WEBEM.robot








Force Tags    CA_VRF_TSR2    QCD_MN_RAN    QCP_RAN_VRF    CLOUD_HRAN_RFS_ASOE_MTNRL94_3xAQQJ_1xAHPB_1xAHPJ

*** Variables ***
${SCF_ID}    01
${ALM_PTH}    ${CURDIR}/../../../test_resources/tc_variables



*** Test Cases ***
[1][1.0] Automated_RFS_UUF_SW_UPGRADE_ROLLBACK
    [Timeout]    144000
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${BTS1_testline_object}    ${tl.enbs[0]}
    ...    AND    Set Test Variable    ${BTS2_testline_object}
    ...    AND    Set Test Variable    ${BTS3_testline_object}
    ...    AND    Set Test Variable    ${BTS4_testline_object}
    ...    AND    Set Test Variable    ${BTS1_source_sw}    SBTS00_ENB_9999_250407_000011
    ...    AND    Set Test Variable    ${BTS2_source_sw}
    ...    AND    Set Test Variable    ${BTS3_source_sw}
    ...    AND    Set Test Variable    ${BTS4_source_sw}
    ...    AND    Set Test Variable    ${BTS1_target_sw}    SBTS00_ENB_9999_250408_000009
    ...    AND    Set Test Variable    ${BTS2_target_sw}
    ...    AND    Set Test Variable    ${BTS3_target_sw}
    ...    AND    Set Test Variable    ${BTS4_target_sw}
    ...    AND    Set Test Variable    ${BTS1_temporary_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS2_temporary_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS3_temporary_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS4_temporary_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS1_custom_allowed_alarms}    61649,61524,4654,61652,4655
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
    ...    AND    Set Test Variable    ${ITERATIONS_PER_NODE}    5
    ...    AND    Set Test Variable    ${CUSTOMERS_LIST}    Generic
    ...    AND    Set Test Variable    ${CALCULATE_KPI}    True
    ...    AND    Set Test Variable    ${KPI_NAMES}
    ...    AND    Set Test Variable    ${KPI_THRESHOLDS}
    ...    AND    Set Test Variable    ${USE_DCAP}    False
    ...    AND    Set Test Variable    ${L3_CALL_METHOD}    None
    ...    AND    Set Test Variable    ${STOP_TEST_AFTER_FAIL}    False
    ...    AND    Set Test Variable    ${REPORT}    True
    ...    AND    Set Test Variable    ${QC_PROJECT}    QCP_RAN_VRF
    ...    AND    Set Test Variable    ${QC_DOMAIN}    QCD_MN_RAN
    ...    AND    Set Test Variable    ${QC_ID}    161063
    ...    AND    Set Test Variable    ${SW_BUILD}    ${None}
    ...    AND    Set Test Variable    ${TOPOLOGY}    CLOUD_HRAN_RFS_ASOE_MTNRL94_3xAQQJ_1xAHPB_1xAHPJ
    ...    AND    Set Test Variable    ${RP_CA}    VRF_SiSo
    ...    AND    Set Test Variable    ${RP_LOCATION}    VRF_TSR2
    ...    AND    Set Test Variable    ${RP_ORGANIZATION}    VRF_TSR2_T03
    ...    AND    Set Test Variable    &{TEST_PARAMETERS}    &{EMPTY}

    ...    AND    UUF_SW_UPGRADE_ROLLBACK.TC Setup
    ...    AND    Modify Resource Search Order    UUF_SW_UPGRADE_ROLLBACK
    ...    AND    Set Library Search Order    UUF_SW_UPGRADE_ROLLBACK
    TC__UUF_SW_UPGRADE_ROLLBACK
    [Teardown]    Run Keywords    UUF_SW_UPGRADE_ROLLBACK.TC Teardown
    ...    AND    Restore Resource Search Order





[1][1.0] Automated_RFS_UUF_SITE_RESET_WITHOUT_HWF
    [Timeout]    144000
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${BTS1_testline_object}    ${tl.enbs[0]}
    ...    AND    Set Test Variable    ${BTS2_testline_object}
    ...    AND    Set Test Variable    ${BTS3_testline_object}
    ...    AND    Set Test Variable    ${BTS4_testline_object}
    ...    AND    Set Test Variable    ${BTS1_source_sw}    SBTS00_ENB_9999_250408_000009
    ...    AND    Set Test Variable    ${BTS2_source_sw}
    ...    AND    Set Test Variable    ${BTS3_source_sw}
    ...    AND    Set Test Variable    ${BTS4_source_sw}
    ...    AND    Set Test Variable    ${BTS1_target_sw}    SBTS00_ENB_9999_250408_000009
    ...    AND    Set Test Variable    ${BTS2_target_sw}
    ...    AND    Set Test Variable    ${BTS3_target_sw}
    ...    AND    Set Test Variable    ${BTS4_target_sw}
    ...    AND    Set Test Variable    ${BTS1_temporary_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS2_temporary_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS3_temporary_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS4_temporary_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS1_custom_allowed_alarms}    61649,61524,4654,61652,4655
    ...    AND    Set Test Variable    ${BTS2_custom_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS3_custom_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS4_custom_allowed_alarms}
    ...    AND    Set Test Variable    &{BTS1_node_parameters}    &{EMPTY}
    ...    AND    Set Test Variable    &{BTS2_node_parameters}    &{EMPTY}
    ...    AND    Set Test Variable    &{BTS3_node_parameters}    &{EMPTY}
    ...    AND    Set Test Variable    &{BTS4_node_parameters}    &{EMPTY}
    ...    AND    Set Test Variable    ${TEST_NODES_DETAILS_LIST}    ALL
    ...    AND    Set Test Variable    ${ITERATIONS_PER_NODE}    20
    ...    AND    Set Test Variable    ${CUSTOMERS_LIST}    Generic
    ...    AND    Set Test Variable    ${CALCULATE_KPI}    True
    ...    AND    Set Test Variable    ${KPI_NAMES}
    ...    AND    Set Test Variable    ${KPI_THRESHOLDS}
    ...    AND    Set Test Variable    ${USE_DCAP}    False
    ...    AND    Set Test Variable    ${L3_CALL_METHOD}    None
    ...    AND    Set Test Variable    ${STOP_TEST_AFTER_FAIL}    False
    ...    AND    Set Test Variable    ${REPORT}    True
    ...    AND    Set Test Variable    ${QC_PROJECT}    QCP_RAN_VRF
    ...    AND    Set Test Variable    ${QC_DOMAIN}    QCD_MN_RAN
    ...    AND    Set Test Variable    ${QC_ID}    161064
    ...    AND    Set Test Variable    ${SW_BUILD}    ${None}
    ...    AND    Set Test Variable    ${TOPOLOGY}    CLOUD_HRAN_RFS_ASOE_MTNRL94_3xAQQJ_1xAHPB_1xAHPJ
    ...    AND    Set Test Variable    ${RP_CA}    VRF_SiSo
    ...    AND    Set Test Variable    ${RP_LOCATION}    VRF_TSR2
    ...    AND    Set Test Variable    ${RP_ORGANIZATION}    VRF_TSR2_T03
    ...    AND    Set Test Variable    &{TEST_PARAMETERS}    &{EMPTY}

    ...    AND    UUF_SITE_RESET_WITHOUT_HWF.TC Setup
    ...    AND    Modify Resource Search Order    UUF_SITE_RESET_WITHOUT_HWF
    ...    AND    Set Library Search Order    UUF_SITE_RESET_WITHOUT_HWF
    TC__UUF_SITE_RESET_WITHOUT_HWF
    [Teardown]    Run Keywords    UUF_SITE_RESET_WITHOUT_HWF.TC Teardown
    ...    AND    Restore Resource Search Order




[1]SBTS__STATE__RM_Reset_from_WEBEM
    [Timeout]    144000
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts__state__rm_reset_from_webem_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    10
    ...    AND    Set Test Variable    ${HW_RESET_TIME_INTERVAL}    480
    ...    AND    Set Test Variable    ${HW_RESET_WRN_THR}    235
    ...    AND    Set Test Variable    ${HW_RESET_MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${GRACEFUL_CELL_SHUTDOWN}    True

    ...    AND    SBTS__STATE__RM_Reset_from_WEBEM.TC Setup
    ...    AND    Modify Resource Search Order    SBTS__STATE__RM_Reset_from_WEBEM
    ...    AND    Set Library Search Order    SBTS__STATE__RM_Reset_from_WEBEM
    TC__SBTS__STATE__RM_Reset_from_WEBEM
    [Teardown]    Run Keywords    SBTS__STATE__RM_Reset_from_WEBEM.TC Teardown
    ...    AND    Restore Resource Search Order


[1]SBTS__STATE__Site_Block_Unblock_from_WEBEM
    [Timeout]    144000
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts__state__site_block_unblock_from_webem_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    10
    ...    AND    Set Test Variable    ${SBTS_RESET_WRN_THR}    225
    ...    AND    Set Test Variable    ${SBTS_MAX_WAIT_TIME}    900

    ...    AND    SBTS__STATE__Site_Block_Unblock_from_WEBEM.TC Setup
    ...    AND    Modify Resource Search Order    SBTS__STATE__Site_Block_Unblock_from_WEBEM
    ...    AND    Set Library Search Order    SBTS__STATE__Site_Block_Unblock_from_WEBEM
    TC__SBTS__STATE__Site_Block_Unblock_from_WEBEM
    [Teardown]    Run Keywords    SBTS__STATE__Site_Block_Unblock_from_WEBEM.TC Teardown
    ...    AND    Restore Resource Search Order





[1]SBTS__STATE__RAT_Block_Unblock_from_WEBEM
    [Timeout]    144000
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts__state__rat_block_unblock_from_webem_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    10
    ...    AND    Set Test Variable    ${RAT_TECH}

    ...    AND    SBTS__STATE__RAT_Block_Unblock_from_WEBEM.TC Setup
    ...    AND    Modify Resource Search Order    SBTS__STATE__RAT_Block_Unblock_from_WEBEM
    ...    AND    Set Library Search Order    SBTS__STATE__RAT_Block_Unblock_from_WEBEM
    TC__SBTS__STATE__RAT_Block_Unblock_from_WEBEM
    [Teardown]    Run Keywords    SBTS__STATE__RAT_Block_Unblock_from_WEBEM.TC Teardown
    ...    AND    Restore Resource Search Order





[1]SBTS__STATE__RAT_Soft_Reset_from_WEBEM
    [Timeout]    144000
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts__state__rat_reset_from_webem_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    10
    ...    AND    Set Test Variable    ${RAT_TECH}    all
    ...    AND    Set Test Variable    ${NR_RESET_WRN_THR}    165
    ...    AND    Set Test Variable    ${LTE_RESET_WRN_THR}    120
    ...    AND    Set Test Variable    ${WCDMA_RESET_WRN_THR}    120
    ...    AND    Set Test Variable    ${GSM_RESET_WRN_THR}    120
    ...    AND    Set Test Variable    ${MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${RESET_TYPE}    Soft
    ...    AND    Set Test Variable    ${GRACEFUL_CELL_SHUTDOWN}    True

    ...    AND    SBTS__STATE__RAT_Reset_from_WEBEM.TC Setup
    ...    AND    Modify Resource Search Order    SBTS__STATE__RAT_Reset_from_WEBEM
    ...    AND    Set Library Search Order    SBTS__STATE__RAT_Reset_from_WEBEM
    TC__SBTS__STATE__RAT_Reset_from_WEBEM
    [Teardown]    Run Keywords    SBTS__STATE__RAT_Reset_from_WEBEM.TC Teardown
    ...    AND    Restore Resource Search Order




[1]SBTS__STATE__RAT_Hard_Reset_from_WEBEM
    [Timeout]    144000
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts__state__rat_reset_from_webem_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    10
    ...    AND    Set Test Variable    ${RAT_TECH}    all
    ...    AND    Set Test Variable    ${NR_RESET_WRN_THR}    250
    ...    AND    Set Test Variable    ${LTE_RESET_WRN_THR}    120
    ...    AND    Set Test Variable    ${WCDMA_RESET_WRN_THR}    120
    ...    AND    Set Test Variable    ${GSM_RESET_WRN_THR}    120
    ...    AND    Set Test Variable    ${MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${RESET_TYPE}    Hard
    ...    AND    Set Test Variable    ${GRACEFUL_CELL_SHUTDOWN}    True

    ...    AND    SBTS__STATE__RAT_Reset_from_WEBEM.TC Setup
    ...    AND    Modify Resource Search Order    SBTS__STATE__RAT_Reset_from_WEBEM
    ...    AND    Set Library Search Order    SBTS__STATE__RAT_Reset_from_WEBEM
    TC__SBTS__STATE__RAT_Reset_from_WEBEM
    [Teardown]    Run Keywords    SBTS__STATE__RAT_Reset_from_WEBEM.TC Teardown
    ...    AND    Restore Resource Search Order





[1]SBTS__STATE__RM_LockUnlock_from_WEBEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__state__rm_lockunlock_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    10
    ...    AND    Set Test Variable    ${RMOD_SERIAL_NUMBER_LIST}    ALL
    ...    AND    Set Test Variable    ${RMOD_SHARING_INFO}    ALL
    ...    AND    Set Test Variable    ${RMOD_LOCK_MAX_WAIT_TIME}    300
    ...    AND    Set Test Variable    ${RMOD_UNLOCK_MAX_WAIT_TIME}    300
    ...    AND    Set Test Variable    ${LTE_IOT_check}    True

    ...    AND    SBTS_SBTS_SBTS_SBTS__STATE__RM_LockUnlock.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS_SBTS_SBTS__STATE__RM_LockUnlock
    ...    AND    Set Library Search Order    SBTS_SBTS_SBTS_SBTS__STATE__RM_LockUnlock
    TC__SBTS_SBTS_SBTS_SBTS__STATE__RM_LockUnlock
    [Teardown]    Run Keywords    SBTS_SBTS_SBTS_SBTS__STATE__RM_LockUnlock.TC Teardown
    ...    AND    Restore Resource Search Order


[1]SBTS__STATE__RM_Power_Off_On
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts__state__rm_power_off_on_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    5
    ...    AND    Set Test Variable    ${OPERATION_ORDER}    ONE_BY_ONE
    ...    AND    Set Test Variable    ${HW_RESET_TIME_INTERVAL}    480
    ...    AND    Set Test Variable    ${HW_POWER_ON_WRN_THR}    200
    ...    AND    Set Test Variable    ${HW_POWER_MAX_WAIT_TIME}    900

    ...    AND    SBTS__STATE__RM_Power_Off_On.TC Setup
    ...    AND    Modify Resource Search Order    SBTS__STATE__RM_Power_Off_On
    ...    AND    Set Library Search Order    SBTS__STATE__RM_Power_Off_On
    TC__SBTS__STATE__RM_Power_Off_On
    [Teardown]    Run Keywords    SBTS__STATE__RM_Power_Off_On.TC Teardown
    ...    AND    Restore Resource Search Order


[1]SBTS__STATE__SBTS_Power_Off_On
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts__state__sbts_power_off_on_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    5
    ...    AND    Set Test Variable    ${Objects_To_Power_Off}    SM
    ...    AND    Set Test Variable    ${SBTS_POWER_ON_WRN_THR}    200
    ...    AND    Set Test Variable    ${SBTS_POWER_ON_MAX_WAIT_TIME}    600

    ...    AND    SBTS__STATE__SBTS_Power_Off_On.TC Setup
    ...    AND    Modify Resource Search Order    SBTS__STATE__SBTS_Power_Off_On
    ...    AND    Set Library Search Order    SBTS__STATE__SBTS_Power_Off_On
    TC__SBTS__STATE__SBTS_Power_Off_On
    [Teardown]    Run Keywords    SBTS__STATE__SBTS_Power_Off_On.TC Teardown
    ...    AND    Restore Resource Search Order


[1]SBTS__STATE__Site_Reset_from_WEBEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts__state__site_reset_from_webem_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    5
    ...    AND    Set Test Variable    ${SBTS_RESET_WRN_THR}    315
    ...    AND    Set Test Variable    ${SBTS_MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${SWCONFIG_CHANGE_FLAG}    False
    ...    AND    Set Test Variable    ${SWCONFIG_FLAG_ACTION}    add
    ...    AND    Set Test Variable    ${SWCONFIG_FLAG_LIST}    0x4F0214
    ...    AND    Set Test Variable    ${GRACEFUL_CELL_SHUTDOWN}    True

    ...    AND    SBTS__STATE__Site_Reset_from_WEBEM.TC Setup
    ...    AND    Modify Resource Search Order    SBTS__STATE__Site_Reset_from_WEBEM
    ...    AND    Set Library Search Order    SBTS__STATE__Site_Reset_from_WEBEM
    TC__SBTS__STATE__Site_Reset_from_WEBEM
    [Teardown]    Run Keywords    SBTS__STATE__Site_Reset_from_WEBEM.TC Teardown
    ...    AND    Restore Resource Search Order


[1]SBTS__STATE__Cell_BlockUnblock_from_WEBEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__state__cell_block_unblock_from_webem_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    5
    ...    AND    Set Test Variable    ${BTS_LIST}    ALL
    ...    AND    Set Test Variable    ${RAT_LIST}    ALL
    ...    AND    Set Test Variable    ${LTE_IOT_SA_action}    True
    ...    AND    Set Test Variable    ${LTE_IOT_check}    True
    ...    AND    Set Test Variable    ${NR_CELL_BLOCK_WRN_THR}    12
    ...    AND    Set Test Variable    ${NR_CELL_UNBLOCK_WRN_THR}    17
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



